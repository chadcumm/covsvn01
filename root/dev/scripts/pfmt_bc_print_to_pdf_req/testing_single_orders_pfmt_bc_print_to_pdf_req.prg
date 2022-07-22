/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   pfmt_bc_print_to_pdf_req.prg
  Object name:        pfmt_bc_print_to_pdf_req
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/20/2020  Chad Cummings			REMOVE OR UPDATE AFTER POC
001   10/01/2019  Chad Cummings			Initial Release
002   09/28/2020  Chad Cummings			additional order qualifiers for not cancel
003   09/29/2020  Chad Cummings			updated reschedule logic
004   10/01/2020  Chad Cummings			added distinquish between future initiate and addtophase
005   10/02/2020  Chad Cummings			removed section causing additional AMB Phlebtomy entries
006   09/29/2020  Chad Cummings			updated reschedule logic to silent updates
007   10/13/2020  Chad Cummings			included specific req types for scheduling location
008   10/13/2020  Chad Cummings			excluded ORDERED status
009   10/13/2020  Chad Cummings			included activated order action
010	  10/14/2020  Chad Cummings			corrected multiple d/c in PowerPlan
011   10/15/2020  Chad Cummings			add to phase updates
012   10/15/2020  Chad Cummings			added update to reference_nbr
013   10/15/2020  Chad Cummings			reversed modfiy action when document isn't found
014   10/16/2020  Chad Cummings			Updated modified section to correct requisition name
015   10/16/2020  Chad Cummings			Added Voided (deleted)
016   10/16/2020  Chad Cummings			Required all non-lab orders to be in their own group
017   10/19/2020  Chad Cummings			Updated description for plans
018   10/20/2020  Chad Cummings			ATTEMPT to get MI on some plans to work
019   10/20/2020  Chad Cummings			corrected issue where single orders and plans don't mix
020   10/20/2020  Chad Cummings			modify one requisition no longer updates all reqs in single phase
021   10/20/2020  Chad Cummings			single orders produce multiple reqs per format
022	  10/21/2020  Chad Cummings		    corrected pathway_id assigned to orders
023	  10/22/2020  Chad Cummings		    removing duplicate req creation by suppressing non-lab DOT protocol orders
024	  10/22/2020  Chad Cummings		    using new field for reference_nbr
025   10/23/2020  Chad Cummings			removed counter reset on single orders
026   10/24/2020  Chad Cummings			additional changes to allow multiple reqs of same type
027   10/25/2020  Chad Cummings			reset print_prsnl_id to 1 to accomodate scripting in requisitions,MI,REF child orders
028   11/27/2020  Chad Cummings			Updated single orders to allow child orders to qualify
******************************************************************************/
drop program pfmt_bc_print_to_pdf_req:dba go
create program pfmt_bc_print_to_pdf_req:dba

call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(1)	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0)	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0)

select into "nl:"
from
	 code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "PRINTTOPDF"
	and   cvs.code_set > 0.0
join cv
	where cv.code_set = cvs.code_set
	and   cv.active_ind 	= 1
	and   cv.cdf_meaning	= "LOGGING"
order by
	 cv.begin_effective_dt_tm desc
	,cv.cdf_meaning
head report
	stat = 0
head cv.cdf_meaning
	if (cnvtint(cv.definition) > 0)
		rec_to_file = 1
		nologvar = 0
	endif
with nocounter

set modify maxvarlen 268435456 ;increases max file size

if (not validate(requestin->request,0))
	go to exit_script_no_log
else
	if (requestin->request->personid = 0.0)
		go to exit_script_no_log
	endif
endif

%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc

call bc_custom_code_set(0)
call bc_log_level(0)
call bc_check_validation(0)
call bc_pdf_event_code(0)
call bc_pdf_content_type(0)
call bc_get_multi_ord_requisitions(0)
;call bc_get_task_definition(0)
call bc_get_included_locations(0)
call bc_get_scheduling_fields(0)

call writeLog(build2("* Check to see whether we got requestin-request or just requestin"))

if(not validate(requestin->request,0))
   call writeLog(build2("->Order was processed by async order server and request 560200.  Therefore we got requestin as requestin"))
   set bc_common->person_id = requestin->personid
   set bc_common->requestin_ind = 0	;requestin as requestin
else
   call writeLog(build2("->Order was processed by sync order server and request 560201. requestin as requestin->request."))
   set bc_common->person_id = requestin->request->personid
   set bc_common->requestin_ind = 1	;requestin as requestin->request
endif

call writeLog(build2("->bc_common->person_id =",trim(cnvtstring(bc_common->person_id))))



free set t_rec
record t_rec
(
	1 cnt						= i4
	1 temp_valid_ind			= i2
	1 requestin_ind				= i2
	1 identifier				= vc
	1 sysdate_string			= vc
	1 general_lab_cd			= f8
	1 radiology_cd				= f8
	1 ambulatory_referrals_cd	= f8
	1 future_status_cd			= f8
	1 print_dir					= vc
	1 log_filename_a			= vc
	1 log_filename_request		= vc
	1 prsnl_id 					= f8
	1 identifier 				= vc
	1 pass_count				= i2
	1 temp_event_cnt			= i2
	1 temp_eventlist[*] 
	 2 event_id					= f8
	1 temp_orderlist_cnt		= i2
	1 temp_powerplan_flag		= i2
	1 temp_orderlist[*]
		2 order_id				= f8
		2 pathway_catalog_id	= f8
		2 order_mnemonic		= vc
		2 encntr_id 			= f8
		2 action_type_cd		= f8
		2 action_type_mean		= vc
		2 orig_action_type_mean = vc ;006
		2 requisition_format_cd	= f8
		2 requisition_format	= vc
		2 info					= vc
		2 event_id				= f8
		2 processed				= i2
		2 reference_nbr			= vc
		2 normal_ref_range_txt	= vc ;024
		2 event_title_text      = vc ;003
		2 sONCOLOGY_POWERPLAN_ORDER = i2
		2 sCHILD_ORDER = i2
	 	2 sLAB_DOT_ORDER = i2
	1 temp_cnt 					= i2
	1 temp_list[*]
		2 order_id				= f8
		2 pathway_catalog_id	= f8
		2 order_mnemonic		= vc
		2 encntr_id 			= f8
		2 action_type_cd		= f8
		2 action_type_mean		= vc
		2 orig_action_type_mean = vc ;006
		2 requisition_format_cd	= f8
		2 requisition_format	= vc
		2 info					= vc
		2 event_id				= f8
		2 reference_nbr			= vc
		2 normal_ref_range_txt	= vc ;024
		2 sONCOLOGY_POWERPLAN_ORDER = i2
		2 sCHILD_ORDER = i2
	 	2 sLAB_DOT_ORDER = i2
	1 group_cnt 				= i2
	1 grouplist[*]
		2 order_cnt 				= i2
		2 plan_name 				= vc
		2 group_desc 				= vc
		2 req_desc					= vc
		2 pathway_id 				= f8
		2 identifier				= vc
		2 single_order				= i2
		2 reference_nbr				= vc
		2 normal_ref_range_txt	= vc ;024
		2 event_id					= f8
		2 task_id					= f8
		2 event_title_text			= vc
		2 printer_name 				= vc
		2 requisition_script		= vc
		2 action_type				= vc
		2 orig_action_type			= vc ;006
		2 group_dt					= vc
		2 orderlist[*]
		 3 plan_name 				= vc
		 3 group_id 				= i2
	     3 order_id 				= f8
	     3 order_mnemonic			= vc
	     3 encntr_id 				= f8
	     3 conversation_id 			= f8
	     3 pathway_id 				= f8
	     3 pathway_catalog_id		= f8
	     3 printer_name 			= vc
	     3 action_cd				= f8
	     3 requisition_cd			= f8
	     3 parent_event_id			= f8
	     3 event_id					= f8
	     3 requisition_script		= vc
	     3 task_id					= f8
	     3 blob_event_id			= f8
	     3 event_title_text			= vc
	     3 leave_authenticated		= i2
	     3 order_dt					= vc
	     3 pathway_desc				= vc
)

set t_rec->general_lab_cd 			= uar_get_code_by("MEANING",6000,"GENERAL LAB")
set t_rec->radiology_cd				= uar_get_code_by("MEANING",6000,"RADIOLOGY")
set t_rec->ambulatory_referrals_cd	= uar_get_code_by("MEANING",6000,"AMB REFERRAL")
set t_rec->future_status_cd			= uar_get_code_by("MEANING",6004,"FUTURE")
set t_rec->print_dir 				= concat(
												 "/cerner/d_"
												,trim(cnvtlower(curdomain))
												,"/print/"
											)
set t_rec->sysdate_string 			= format(sysdate,"yyyymmddhhmmss;;d") 
set t_rec->log_filename_request 	= concat ("cclscratch:requestin_560201_" ,t_rec->sysdate_string ,".dat" )
set t_rec->log_filename_a 			= concat ("cclscratch:req_560201_records_" ,t_rec->sysdate_string ,".dat" )

declare notfnd = vc with constant("<not found>")
declare order_string = vc with noconstant(" ")


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Validate Patient ************************************"))

select into "nl:"
from person p
plan p where p.person_id = bc_common->person_id
detail
	call writeLog(build2("--->",trim(p.name_full_formatted)))
	;THIS WILL NOT PROCESS PLAY PATIENTS, Turning off name validation for this script
	/*
	if (p.name_first_key = "PDF*")
		bc_common->valid_ind = 0
	endif
	if (p.name_last_key = "CSTPDF*")
		bc_common->valid_ind = 0
		t_rec->temp_valid_ind = 0
	endif
	
	if ((p.name_first_key = "PLAY*") and (p.name_last_key = "CSTPDF*"))
		bc_common->valid_ind = 1
	endif
	*/
with nocounter

;Pass all Patients by Name
set bc_common->valid_ind = 1

call writeLog(build2("* Validate Location=",cnvtstring(bc_common->location_cnt)))
call writeLog(build2("* orderlist=",cnvtstring(size(requestin->request->orderlist,5))))
call writeLog(build2("* 1st encounter id=",cnvtstring(requestin->request->orderlist[1].originatingencounterid)))
call writeLog(build2("* encounter id=",cnvtstring(requestin->request->ENCNTRID)))

if ((bc_common->location_cnt > 0) and (bc_common->valid_ind = 1))
	call writelog(build2("*bc_common->location_qual[1].code_value=",cnvtstring(bc_common->location_qual[1].code_value)))
	set bc_common->valid_ind = 0


/*	select into "nl:"
	from (dummyt d1 with seq=size(requestin->request->orderlist,5))
		,encounter e
	plan d1
		where requestin->request->orderlist[d1.seq].originatingencounterid > 0.0
	join e where e.encntr_id = requestin->request->orderlist[d1.seq].originatingencounterid
	head report
		call writeLog(build2("->Inside Order Location Query"))
		cnt = 0
	detail
		call writeLog(build2("requestin->request->orderlist[d1.seq].originatingencounterid=",
			cnvtstring(requestin->request->orderlist[d1.seq].originatingencounterid)))
			call writeLog(build2("looping through locations"))
			for (cnt=1 to bc_common->location_cnt)
				if (bc_common->location_qual[cnt].code_value = e.loc_nurse_unit_cd)
					bc_common->valid_ind = 1
				endif
			endfor
			call writeLog(build2("finished looping through locations"))
	foot report
		call writeLog(build2("<-Leaving Order Location Query"))
	with nocounter,nullreport
*/
	select into "nl:"
	from
		(dummyt d1 with seq=size(requestin->request->orderlist,5))
		,encounter e
		,orders o
	plan d1
		where requestin->request->orderlist[d1.seq].orderid > 0.0
	join o
		where o.order_id = requestin->request->orderlist[d1.seq].orderid
	join e
		where e.encntr_id = o.originating_encntr_id
		;and expand(cnt,1,bc_common->location_cnt,e.loc_nurse_unit_cd,bc_common->location_qual[cnt].code_value)
	order by
		 e.loc_nurse_unit_cd
		,e.encntr_id
	head report
		call writeLog(build2("->Inside Encounter Location Query"))
		cnt = 0
	head e.loc_nurse_unit_cd
		cnt = 0
		call writeLog(build2("looping through locations"))
		call writeLog(build2("checking=",cnvtstring(e.encntr_id)))
		
		
		call writeLog(build2("checking=",uar_get_code_display(e.loc_nurse_unit_cd)))
			for (cnt=1 to bc_common->location_cnt)
				if (bc_common->location_qual[cnt].code_value = e.loc_nurse_unit_cd)
					bc_common->valid_ind = 1
					call writeLog(build2("MATCHED=",uar_get_code_display(e.loc_nurse_unit_cd)))
				endif
			endfor
			call writeLog(build2("finished looping through locations"))
	foot e.loc_nurse_unit_cd
		stat = 0
	foot report
		call writeLog(build2("<-Leaving Encounter Location Query"))
	with nocounter,nullreport
	
else
	call writeLog(build2("*No Locations Found"))
endif

if (bc_common->valid_ind = 0)
	call writeLog(build2("--->INVALID PATIENT, go to exit_script"))
	if (t_rec->temp_valid_ind = 1)
		call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
		call echojson(requestin,t_rec->log_filename_request)
	endif
	go to exit_script
else
	call writeLog(build2("--->PATIENT PASSED"))
	call writeLog(build2("*-> Valid Patient, starting ",trim(t_rec->log_filename_a)," with requestin"))
	if (validate(requestin))
		call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
		call echojson(requestin,t_rec->log_filename_request)
		;call echojson(requestin,t_rec->log_filename_a)
	endif
endif

call writeLog(build2("* END Validate Patient ************************************"))
call writeLog(build2("*************************************************************"))

set k = 0
set pos = 0
set j = 0
set ii = 0

set pass_ind = 0

#start_script
call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Add Orders to Temp **********************************"))

call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->request->orderlist,5)))))

for (i=1 to size(requestin->request->orderlist,5))
	call writeLog(build2("--->order_id=",trim(cnvtstring(requestin->request->orderlist[i].orderid))))
	call writeLog(build2("--->action_type_cd=",trim(cnvtstring(requestin->request->orderlist[i].ACTIONTYPECD))))
	call writeLog(build2("--->action_type=",trim(uar_get_code_display(requestin->request->orderlist[i].ACTIONTYPECD))))
	call writeLog(build2("--->requisition_format_cd=",trim(cnvtstring(requestin->request->orderlist[i].REQUISITIONFORMATCD))))
	
	if (requestin->request->orderlist[i].ACTIONTYPECD in(
															 value(uar_get_code_by("MEANING",6003,"ORDER"))
															,value(uar_get_code_by("MEANING",6003,"CANCEL"))
															,value(uar_get_code_by("MEANING",6003,"DELETE")) ;015
															,value(uar_get_code_by("MEANING",6003,"CANCEL DC"))
															,value(uar_get_code_by("MEANING",6003,"MODIFY"))
															,value(uar_get_code_by("MEANING",6003,"RESCHEDULE"))
															,value(uar_get_code_by("MEANING",6003,"ACTIVATE")) ;009
														))
		
		call writeLog(build2("---->checking requisitions"))
		set pass_ind = 0
		for (j=1 to bc_common->requisition_cnt)
			if (requestin->request->orderlist[i].REQUISITIONFORMATCD = bc_common->requisition_qual[j].requisition_format_cd)
				set pass_ind = 1
			endif
		endfor
		
		;if (pass_ind = 1)
		/*start 007*/
		call writeLog(build2("---->first requisition check, pass_ind=",pass_ind))
		if (uar_get_code_meaning(requestin->request->orderlist[i].REQUISITIONFORMATCD) in(
																							"AMBREFERREQ"
																							,"PROVECHOREQ"
																							,"CRDASTATREQ"
																							,"MIREQUISITN"))
			for (j=1 to size(requestin->request->orderlist[i]->detaillist,5))
				if (requestin->request->orderlist[i]->detaillist[j].oefieldid in(bc_common->scheduling_location_field_id,
					bc_common->scheduling_location_field_non_radiology_id))
					call writeLog(build2("----->found oef=",requestin->request->orderlist[i]->detaillist[j].oefieldid))
					call writeLog(build2("----->found oef value=",requestin->request->orderlist[i]->detaillist[j].oefieldvalue))
					if (requestin->request->orderlist[i]->detaillist[j].oefieldvalue 
						not in(bc_common->print_to_paper_cd,bc_common->paper_referral_cd))
						if (requestin->request->orderlist[i]->detaillist[j].oefieldvalue > 0.0)
							set pass_ind = 0
						endif
					endif
				endif
			endfor
		endif
		/*end 007*/
		;endif
		call writeLog(build2("---->finished checking requisitions, pass_ind=",pass_ind))
		if (pass_ind = 1)
			call writeLog(build2("----->inside pass_ind = 1"))
				set t_rec->temp_orderlist_cnt = (t_rec->temp_orderlist_cnt + 1)
				set stat = alterlist(t_rec->temp_orderlist,t_rec->temp_orderlist_cnt)
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].order_id = requestin->request->orderlist[i].orderid
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id	= requestin->request->orderlist[i].PATHWAYCATALOGID
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].encntr_id = requestin->request->orderlist[i].ORIGINATINGENCOUNTERID
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_cd = requestin->request->orderlist[i].ACTIONTYPECD
				/* start 015 */
				if (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_cd=value(uar_get_code_by("MEANING",6003,"DELETE")))
					set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_cd = value(uar_get_code_by("MEANING",6003,"CANCEL"))
				endif
				/* end 015 */
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].requisition_format_cd 
						= requestin->request->orderlist[i].REQUISITIONFORMATCD
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].requisition_format 
						= uar_get_code_display(requestin->request->orderlist[i].REQUISITIONFORMATCD)
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean 
				;015	= uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD)
					= uar_get_code_meaning(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_cd) ;015
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].orig_action_type_mean 	 ;006
						= t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean	 ;006
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].order_mnemonic = 
					requestin->request->orderlist[i].PRIMARYMNEMONIC
				; double check PATHWAYCATALOGID, some requestin doesn't appear to send it
				if (requestin->request->orderlist[i].PATHWAYCATALOGID = 0.0)
					select into "nl:"
					from orders o where o.order_id = requestin->request->orderlist[i].orderid
					detail
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id = o.pathway_catalog_id
					with nocounter
					
					set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = "pathwaycatalog_id was = 0"
					
				endif
				
				; double check new order with a pathway_catalog to see if it's adding to a phase, some requestin doesn't appear to send it
				call writeLog(build2("->looking for add to phase step 1"))
				if (	(requestin->request->orderlist[i].PATHWAYCATALOGID > 0.0) and 
						(size(requestin->request->orderlist[i].PROTOCOLINFO,5) > 0) and ;set to 0 if not DOT
						(uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD) in("ORDER")))
						
						select into "nl:"
						from 
							 act_pw_comp apc
							,pathway p 
						where 	apc.parent_entity_id = requestin->request->orderlist[i].orderid
						and 	p.pathway_id = apc.pathway_id 
						and 	apc.created_dt_tm > p.order_dt_tm 
						detail
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = concat(
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info, "apc.created_dt_tm = ",
							format(apc.created_dt_tm,";;q")," p.order_dt_tm=",format(p.order_dt_tm,";;q"))
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
							call writeLog(build2("-->setting meaning 1=",t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean))
						with nocounter
						
						set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = concat(
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info, " protocol > 0, order action ",
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean)
						
						;if (curqual = 0)
						;	set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
						;endif
				endif
				
				call writeLog(build2("->looking for add to phase step 2"))
				if (	(requestin->request->orderlist[i].PATHWAYCATALOGID > 0.0) and 
						(size(requestin->request->orderlist[i].PROTOCOLINFO,5) = 0) and ;set to 0 if not DOT
						(uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD) in("ORDER")))
						
						select into "nl:"
						from 
							 act_pw_comp apc
							,pathway p 
						where 	apc.parent_entity_id = requestin->request->orderlist[i].orderid
						and 	p.pathway_id = apc.pathway_id 
						and 	( (apc.created_dt_tm > p.order_dt_tm) or (apc.unlink_start_dt_tm_ind = 1) )
						detail
							;011 if (apc.pathway_uuid = "") ;004
								t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
								call writeLog(build2("-->setting meaning 2=",t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean))
							;011 endif ;004
							
						with nocounter
						
						set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = concat("protocol = 0, order ",
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean)
						
						;TO-DO need to add in a section/sub routine to find the existing document at this point.  If 
						;that is not found then change this back to a new order.
						if (curqual = 0)
							;testing setting to order, this was MODIFY
							set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "ORDER"
						endif
				endif
				
				
				if (
						(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id > 0.0) and
						;003 (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL"))
						;009 (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL","RESCHEDULE")) ;003
						(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL","RESCHEDULE" ;009
							,"ACTIVATE")) ;009
						)
					set t_rec->temp_powerplan_flag = (t_rec->temp_powerplan_flag + 1)
					/*start 002*/
					call writeLog(build2("------>inside pathway and MODFIY/CANCEL"))
					select into "nl:"
					from
						clinical_Event ce 
					where 	ce.person_id = bc_common->person_id
					and		ce.event_cd = bc_common->pdf_event_cd
					and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
					and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
					and     ce.result_status_cd in(
														  value(uar_get_code_by("MEANING",8,"AUTH"))
														 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
														 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
		
													)	
					;and     cnvtreal(ce.reference_nbr) = t_rec->grouplist[i].orderlist[j].order_id
					;start 024
					and ( (parser(concat(^ce.reference_nbr="*^,trim(cnvtstring(requestin->request->orderlist[i].orderid)),^*"^))) 
					    or (parser(concat(^ce.normal_ref_range_txt="*^,trim(cnvtstring(requestin->request->orderlist[i].orderid)),^*"^)))
					    )
					 ;end 024
					order by
						 ce.reference_nbr
						,ce.event_id
						,ce.valid_from_dt_tm desc
					head report
						call writeLog(build2("-->inside event query to find document for modify<--"))
					head ce.event_id
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id = ce.event_id
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr = ce.reference_nbr
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].normal_ref_range_txt = ce.normal_ref_range_txt ;024
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_title_text = ce.event_title_text ;003
						call writeLog(build2("t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id=",
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id))
						call writeLog(build2("t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr=",
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr))
					foot report
						call writeLog(build2("-->leaving event query<--"))
					with nocounter
					/*end 002*/
					
					/*start 013*/
					if (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].orig_action_type_mean = "ORDER")
						if (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY")
							if (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id = 0.0)
								call writeLog(build2("-->Order was flipped to modify but document not found"))
								call writeLog(build2("-->setting back to order"))
								set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean="ORDER"
							endif
						endif
					endif
					/*end 013*/
				endif
				
				if (
						(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id = 0.0) and
						;003 (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL"))
						;009 (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL","RESCHEDULE")) ;003
						(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL","RESCHEDULE" ;009
							,"ACTIVATE")) ;009
						)
					call writeLog(build2("------>inside no pathway and MODFIY/CANCEL"))
					select into "nl:"
					from
						clinical_Event ce 
					where 	ce.person_id = bc_common->person_id
					and		ce.event_cd = bc_common->pdf_event_cd
					and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
					and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
					and     ce.result_status_cd in(
														  value(uar_get_code_by("MEANING",8,"AUTH"))
														 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
														 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
		
													)	
					;and     cnvtreal(ce.reference_nbr) = t_rec->grouplist[i].orderlist[j].order_id
					;start 024
					and ( (parser(concat(^ce.reference_nbr="*^,trim(cnvtstring(requestin->request->orderlist[i].orderid)),^*"^))) 
					    or (parser(concat(^ce.normal_ref_range_txt="*^,trim(cnvtstring(requestin->request->orderlist[i].orderid)),^*"^)))
					    )
					 ;end 024
					order by
						 ce.reference_nbr
						,ce.event_id
						,ce.valid_from_dt_tm desc
					head report
						call writeLog(build2("-->inside event query to find document for modify,cancel,reschedule<--"))
					head ce.event_id
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id = ce.event_id
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr = ce.reference_nbr
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].normal_ref_range_txt = ce.normal_ref_range_txt ;024
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_title_text = ce.event_title_text ;003
						call writeLog(build2("t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id=",
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id))
						call writeLog(build2("t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr=",
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr))
					foot report
						call writeLog(build2("-->leaving event query<--"))
					with nocounter
					
					;003 if (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id > 0.0)
					if ((t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].event_id > 0.0) and
						 (t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean not in("RESCHEDULE")));003
						call writeLog(build2("-->inside event_id is populated<--"))
						set k = 1
						;024set order_string = piece(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr,":",k,notfnd)
						set order_string = piece(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].normal_ref_range_txt,":",k,notfnd);024
						call writeLog(build2("order_string=",order_string))
						while (order_string != notfnd)
							;024set order_string = piece(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].reference_nbr,":",k,notfnd)
							set order_string = piece(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].normal_ref_range_txt,":",k,notfnd) 
							call writeLog(build2("-->inside while order_string=",order_string))
							
							set pos = locateval(j,1,t_rec->temp_orderlist_cnt,cnvtreal(order_string),t_rec->temp_orderlist[j].
							order_id)
							call writeLog(build2("-->inside while pos=",pos))
							if ((pos = 0) and (cnvtreal(order_string) > 0))
								set t_rec->temp_cnt = (t_rec->temp_cnt + 1)
								set stat = alterlist(t_rec->temp_list,t_rec->temp_cnt)
								set t_rec->temp_list[t_rec->temp_cnt].order_id = cnvtreal(order_string)
								set t_rec->temp_list[t_rec->temp_cnt].pathway_catalog_id	= 0.0
								set t_rec->temp_list[t_rec->temp_cnt].encntr_id = requestin->request->orderlist[i].ORIGINATINGENCOUNTERID
								set t_rec->temp_list[t_rec->temp_cnt].action_type_cd = value(uar_get_code_by("MEANING",6003,"MODIFY"))
												;requestin->request->orderlist[i].ACTIONTYPECD
								set t_rec->temp_list[t_rec->temp_cnt].requisition_format_cd 
										= requestin->request->orderlist[i].REQUISITIONFORMATCD
								set t_rec->temp_list[t_rec->temp_cnt].requisition_format 
										= uar_get_code_display(requestin->request->orderlist[i].REQUISITIONFORMATCD)
								set t_rec->temp_list[t_rec->temp_cnt].action_type_mean 
										= "MODIFY" ;uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD)
										
							endif
							set k = (k + 1)
						endwhile
					endif
				endif	
				
			endif ;requisition match, pass_ind = 1
			
		;endfor;requisition_loop
	endif
endfor; orders_loop

/*

data = dm.info_char
  loc_desc_str = piece(data, ',', num, notfnd)
  loc_cd_str = piece(data, ',', num + 1, notfnd)
  while (loc_desc_str != notfnd)
    ;call echo(build("$5=", $5))
    ;call echo(build("loc_cd_str=", loc_cd_str))
    if ($5 = "" or ichar($5) = 160 or $5 = "Any (\*)" or $5 = "\*" or cnvtreal($5) = cnvtreal(loc_cd_str))
*/

if (t_rec->temp_cnt > 0)
	for (i=1 to t_rec->temp_cnt)
		set t_rec->temp_orderlist_cnt = (t_rec->temp_orderlist_cnt + 1)
		set stat = alterlist(t_rec->temp_orderlist,t_rec->temp_orderlist_cnt)
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].order_id = t_rec->temp_list[i].order_id
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id	= t_rec->temp_list[i].pathway_catalog_id
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].encntr_id = t_rec->temp_list[i].encntr_id
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_cd = t_rec->temp_list[i].action_type_cd
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].requisition_format_cd 
						= t_rec->temp_list[i].requisition_format_cd
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].requisition_format 
						= uar_get_code_display(t_rec->temp_list[i].requisition_format_cd)
		set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean 
						= uar_get_code_meaning(t_rec->temp_list[i].action_type_cd)	
	endfor
endif

call writeLog(build2("* END Add Orders to Temp ************************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START running bc_all_all_std_routines ********************************"))
call writeLog(build2("execute bc_all_all_std_routines"))
execute bc_all_all_std_routines
for (i=1 to t_rec->temp_orderlist_cnt)
	set t_rec->temp_orderlist[i].sONCOLOGY_POWERPLAN_ORDER = sONCOLOGY_POWERPLAN_ORDER(t_rec->temp_orderlist[i].order_id)
	set t_rec->temp_orderlist[i].sLAB_DOT_ORDER = sLAB_DOT_ORDER(t_rec->temp_orderlist[i].order_id)
	set t_rec->temp_orderlist[i].sCHILD_ORDER = sCHILD_ORDER(t_rec->temp_orderlist[i].order_id)
	
	 if (t_rec->temp_orderlist[i].requisition_format in( "AMB_REFERRAL_REQ","CARD_ALLSTATUS_ORDER_REQ","CARD_PROV_ECHO"))
		if ((t_rec->temp_orderlist[i].sCHILD_ORDER = 1) and (t_rec->temp_orderlist[i].sONCOLOGY_POWERPLAN_ORDER = 0))
			set t_rec->temp_orderlist[i].sLAB_DOT_ORDER = 1
		endif
	endif
		
	if (t_rec->temp_orderlist[i].action_type_mean = "RESCHEDULE")
		call writeLog(build2("RESCHEDULE Order Action Found")) ;003
		call writeLog(build2("checking document title=",t_rec->temp_orderlist[i].event_title_text))  ;003
		;006 if (substring(1,9,t_rec->temp_orderlist[i].event_title_text) in("ACTIONED:","MODIFIED:"))  ;003
		;006 	set t_rec->temp_orderlist[i].action_type_mean = ""		  ;003
		;006 	set t_rec->temp_orderlist[i].action_type_cd = 0.0 ;003
		;006 	set  t_rec->temp_orderlist[i].order_id = 0.0 ;003
		;006 else ;003
			set t_rec->temp_orderlist[i].action_type_mean = "MODIFY"		
			set t_rec->temp_orderlist[i].action_type_cd = value(uar_get_code_by("MEANING",6003,"MODIFY"))
		;006 endif
	endif
	
	/*start 028*/
	if (t_rec->temp_orderlist[i].action_type_mean = "ACTIVATE")
		call writeLog(build2("ACTIVATE Order Action Found")) ;003
		call writeLog(build2("checking document title=",t_rec->temp_orderlist[i].event_title_text))  ;003
		;006 if (substring(1,9,t_rec->temp_orderlist[i].event_title_text) in("ACTIONED:","MODIFIED:"))  ;003
		;006 	set t_rec->temp_orderlist[i].action_type_mean = ""		  ;003
		;006 	set t_rec->temp_orderlist[i].action_type_cd = 0.0 ;003
		;006 	set  t_rec->temp_orderlist[i].order_id = 0.0 ;003
		;006 else ;003
			set t_rec->temp_orderlist[i].action_type_mean = "MODIFY"		
			set t_rec->temp_orderlist[i].action_type_cd = value(uar_get_code_by("MEANING",6003,"MODIFY"))
		;006 endif
	endif
	/*end 028*/
endfor
call writeLog(build2("* END running bc_all_all_std_routines ********************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Adding Single Orders ********************************"))
call writelog(build2("t_rec->temp_orderlist_cnt=",t_rec->temp_orderlist_cnt))
call writelog(build2("t_rec->temp_orderlist_cnt (size)=",size(t_rec->temp_orderlist,5)))

for (i=1 to t_rec->temp_orderlist_cnt)
	call writelog(build2("t_rec->temp_orderlist[",trim(cnvtstring(i)),"].order_id=",trim(cnvtstring(t_rec->temp_orderlist[i].
	order_id))))
endfor

select into "nl:"
	action_type = t_rec->temp_orderlist[d1.seq].action_type_cd
from
	 (dummyt d1 with seq=t_rec->temp_orderlist_cnt)
	,orders o
	,order_catalog oc
	,encounter e
plan d1
join o
/*start 028
	where o.order_id	= t_rec->temp_orderlist[d1.seq].order_id
	and   o.pathway_catalog_id = 0.0
	and   (o.protocol_order_id = 0.0 and o.template_order_id= 0.0) ;suppress the child orders
	and   o.order_status_cd not in(	
								 value(uar_get_code_by("MEANING",6004,"CANCELED"))
								,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
								,value(uar_get_code_by("MEANING",6004,"DELETED"))
								,value(uar_get_code_by("MEANING",6004,"ORDERED")) ;008
							)
end 028 */
/*start 028 */
	where (	
		   (	(o.order_id	= t_rec->temp_orderlist[d1.seq].order_id)
		   	and (o.pathway_catalog_id = 0.0)
			and (o.protocol_order_id = 0.0 and o.template_order_id= 0.0) ;suppress the child orders
			and (o.order_status_cd not in(	
								 value(uar_get_code_by("MEANING",6004,"CANCELED"))
								,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
								,value(uar_get_code_by("MEANING",6004,"DELETED"))
								,value(uar_get_code_by("MEANING",6004,"ORDERED")) ;008
							))
			)
		  or 
		  	(	(o.protocol_order_id	= t_rec->temp_orderlist[d1.seq].order_id)
		   	and (o.pathway_catalog_id = 0.0)
			and (o.order_status_cd not in(	
								 value(uar_get_code_by("MEANING",6004,"CANCELED"))
								,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
								,value(uar_get_code_by("MEANING",6004,"DELETED"))
								,value(uar_get_code_by("MEANING",6004,"ORDERED")) ;008
							))
			)
		)
/*end 028 */
join oc
	where oc.catalog_cd	= o.catalog_cd
join e
	where e.encntr_id	= o.originating_encntr_id
order by
	 action_type
	,oc.requisition_format_cd
	,o.order_id
head report
	cnt = 0
	pass_ind = 0 ;028
	pos = 0 ;028
	;019 gcnt = 0
	gcnt = t_rec->group_cnt ;019
	call writeLog(build2("---->inside order selection query Adding Single Orders"))
head action_type
	call writeLog(build2("---->inside action type=",trim(uar_get_code_display(action_type))))
	cnt = 0
head oc.requisition_format_cd
	call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
	gcnt = (gcnt + 1)
	cnt = 0
	stat = alterlist(t_rec->grouplist,gcnt)
	t_rec->group_cnt = gcnt
head o.order_id
	pass_ind = 0 ;028
	call writeLog(build2("---->inside the d.seq=",trim(cnvtstring(d1.seq))))
	call writeLog(build2("---->inside the order_id=",trim(cnvtstring(o.order_id))))
	call writeLog(build2("---->inside the order=",trim(trim(o.order_mnemonic))))
	bc_common->encntr_id = o.originating_encntr_id
	;016 start
	call writeLog(build2("---->t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
	if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
		call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
	endif
	call writeLog(build2("---->after t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
	;016 end
	call writeLog(build2("----->o.protocol_order_id=",trim(trim(cnvtstring(o.protocol_order_id)))))
	call writeLog(build2("----->o.template_order_id=",trim(trim(cnvtstring(o.template_order_id)))))
	if ((o.protocol_order_id = 0.0) and (o.template_order_id = 0.0)) ;028
			pass_ind = 1 ;028
			call writeLog(build2("------>setting first pass_ind=",trim(trim(cnvtstring(pass_ind)))))
	else	;028
		pos = locateval(j,1,t_rec->grouplist[gcnt].order_cnt,o.protocol_order_id,t_rec->grouplist[gcnt].orderlist[j].order_id)
		call writeLog(build2("------>setting pos=",trim(trim(cnvtstring(pos)))))
		if (pos > 0)
			pass_ind = 0
		else
			pass_ind = 1
		endif
		call writeLog(build2("------>setting pass_ind=",trim(trim(cnvtstring(pass_ind)))))
	endif ;028
 if (pass_ind = 1) ;028	
	cnt = (cnt + 1)
	t_rec->grouplist[gcnt].order_cnt = cnt
	stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
	t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
	t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
	t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
	t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
	t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
	t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
	t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= t_rec->temp_orderlist[d1.seq].action_type_cd

	/*for (j=1 to bc_common->requisition_cnt)
		if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
			
			t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
			t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
			
		endif
	endfor*/

	;t_rec->grouplist[gcnt].group_desc 			= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
 endif ;028
foot o.order_id	
 if (pass_ind = 1) ;028	
	stat = 0
;021 foot oc.requisition_format_cd
	t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
													,trim(format(sysdate,"hhmmss;;d") ),".pdf")
	;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
	;010 t_rec->grouplist[gcnt].single_order			= 1
	t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
	t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d1.seq].orig_action_type_mean ;006
	for (j=1 to bc_common->requisition_cnt)
		if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
			
			t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object
			t_rec->grouplist[gcnt].group_desc 			 = bc_common->requisition_qual[j].requisition_title
			t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			
		endif
	endfor
	;025 cnt = 0
	/*start 028*/
	if ((o.protocol_order_id != 0.0) or (o.template_order_id != 0.0))
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd = value(uar_get_code_by("MEANING",6003,"MODIFY"))
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(t_rec->grouplist[gcnt].orderlist[cnt].action_cd)
		if (o.protocol_order_id > 0.0)
			t_rec->grouplist[gcnt].orderlist[cnt].order_id = o.protocol_order_id
		elseif (o.template_order_id > 0.0)
			t_rec->grouplist[gcnt].orderlist[cnt].order_id = o.template_order_id
		endif
	endif
	/*end 028*/
 endif ;028
 pass_ind = 0 ;028
foot action_type
	call writeLog(build2("<-----exiting action selection query"))
foot report
	t_rec->group_cnt = gcnt
	cnt = 0
	call writeLog(build2("<-----exiting order selection query"))
with nocounter

call writeLog(build2("-->finished first single order selection and t_rec->grouplist[gcnt].order_cnt="))

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		if (t_rec->grouplist[i].order_cnt > 1)
			for (j=1 to t_rec->grouplist[i].order_cnt)
				if (t_rec->grouplist[i].orderlist[j].action_cd = value(uar_get_code_by("MEANING",6003,"MODIFY")))
					set t_rec->grouplist[i].action_type = "MODIFY"
				endif
			endfor
		endif
	endfor
else
	call writeLog(build2("-->inside else since group_cnt was 0"))
	call writeLog(build2("-->getting cancelled, active,voided orders"))
	select into "nl:"
		action_type = t_rec->temp_orderlist[d1.seq].action_type_cd
	from
		 (dummyt d1 with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
	plan d1
	join o
		where o.order_id	= t_rec->temp_orderlist[d1.seq].order_id
		and   o.pathway_catalog_id = 0.0
		and   (o.protocol_order_id = 0.0 and o.template_order_id= 0.0) ;suppress the child orders
		and   o.order_status_cd in(	
									 value(uar_get_code_by("MEANING",6004,"CANCELED"))
									,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
									,value(uar_get_code_by("MEANING",6004,"DELETED"))
									,value(uar_get_code_by("MEANING",6004,"ORDERED")) ;008
								)
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join e
		where e.encntr_id	= o.originating_encntr_id
	order by
		 action_type
		,oc.requisition_format_cd
		,o.order_id
	head report
		cnt = 0
		;019 gcnt = 0
		gcnt = t_rec->group_cnt ;019
		call writeLog(build2("---->inside order selection query"))
	head action_type
		call writeLog(build2("---->inside action type=",trim(uar_get_code_display(action_type))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
	head o.order_id
		 /*start 023*/
	 if  (
				(t_rec->temp_orderlist[d1.seq].requisition_format = "LAB_OUTPATIENT_REQ")
			       or 
			        (			(t_rec->temp_orderlist[d1.seq].requisition_format != "LAB_OUTPATIENT_REQ")
			        	 and 	(
			        	 			(		(t_rec->temp_orderlist[d1.seq].sCHILD_ORDER = 1) 
			        	 				and (t_rec->temp_orderlist[d1.seq].sLAB_DOT_ORDER = 1))
			        	 		 or (		(t_rec->temp_orderlist[d1.seq].sCHILD_ORDER = 0) 
			        	 				and (t_rec->temp_orderlist[d1.seq].sLAB_DOT_ORDER = 0))
			        	 		)
			        )
			  )
	/*end 023*/
		call writeLog(build2("---->inside the d1.seq=",trim(cnvtstring(d1.seq))))
		call writeLog(build2("---->inside the order_id=",trim(cnvtstring(o.order_id))))
		call writeLog(build2("---->inside the order=",trim(trim(o.order_mnemonic))))
		bc_common->encntr_id = o.originating_encntr_id
		;016 start
		call writeLog(build2("---->t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
		if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
			call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
		endif
		;016 end
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= t_rec->temp_orderlist[d1.seq].action_type_cd
	
		/*for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				
				t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
				t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
				
			endif
		endfor*/
	
		;t_rec->grouplist[gcnt].group_desc 			= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
	endif ;023
	foot o.order_id	
		stat = 0
	foot oc.requisition_format_cd
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 1
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
		t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d1.seq].orig_action_type_mean ;006
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object
				t_rec->grouplist[gcnt].group_desc 			 = bc_common->requisition_qual[j].requisition_title
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
				
			endif
		endfor
		cnt = 0
	foot action_type
		call writeLog(build2("<-----exiting action selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order selection query"))
	with nocounter
endif

call writeLog(build2("* END Adding Single Orders ********************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Adding PowerPlan Orders ******************************"))
call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->request->orderlist,5)))))

if (t_rec->temp_powerplan_flag = 0) ;MIGHT NEED TO RESET TO = 0
									;until grouping logic is added back in above, this should always be true ( 0 )
	call writeLog(build2("->t_rec->temp_powerplan_flag=",trim(cnvtstring(t_rec->temp_powerplan_flag))))
	call writeLog(build2("->sLAB_DOT_ORDER in(0,2)"))
	select into "nl:"
		 apc.pathway_id
		,action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		,order_dt = format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
		,act_pw_comp apc
		,pathway_comp pc1
		,pathway_catalog pc2
		,pathway_catalog pc3
		,pathway p
	plan d
		where t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER in(0,2)
	join o
		where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		and   o.pathway_catalog_id > 0.0
		;and   o.protocol_order_id = 0.0
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join pc3
		where pc3.pathway_catalog_id = o.pathway_catalog_id
	join e
		where e.encntr_id	= o.originating_encntr_id
	join apc
		where apc.parent_entity_id = o.order_id
	join pc1
		where pc1.pathway_comp_id =  apc.pathway_comp_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		 apc.pathway_id
		,oc.requisition_format_cd
		,order_dt  ;updated for date split
		,o.order_id
	head report
		cnt = 0
		;019 gcnt = 0
		gcnt = t_rec->group_cnt ;019
		call writeLog(build2("---->inside order selection sLAB_DOT_ORDER (0,2) query"))
	head apc.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc.pathway_id))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
		cnt = 0 ;026
	head order_dt ;updated for date split	
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
	head o.order_id
		call writeLog(build2("----> entering o.order_id=",cnvtstring(o.order_id)))
			/*start 023*/
	 	if  (
				(t_rec->temp_orderlist[d.seq].requisition_format = "LAB_OUTPATIENT_REQ")
			       or 
			        (			(t_rec->temp_orderlist[d.seq].requisition_format != "LAB_OUTPATIENT_REQ")
			        	 and 	(
			        	 			(		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 1) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 1))
			        	 		 or (		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 0))
								 or (		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 2))
			        	 		)
			        )
			  )
		/*end 023*/
		bc_common->encntr_id = o.originating_encntr_id
		;016 start
		call writeLog(build2("---->checking t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
		if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
			call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
		endif
		;016 end
		call writeLog(build2("----> starting o.order_id=",cnvtstring(o.order_id)))
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc.pathway_id
		t_rec->grouplist[gcnt].orderlist[cnt].order_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_catalog_id	= o.pathway_catalog_id
		t_rec->temp_orderlist[d.seq].processed = 1 ;010
		endif ;023
	;026 foot oc.requisition_format_cd
		foot o.order_id ;026
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
		t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
	    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		;026 cnt = 0
		t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
		call writeLog(build2("---->t_rec->grouplist[gcnt].group_desc=",trim(t_rec->grouplist[gcnt].group_desc)))
		call writeLog(build2("---->pc2.description=",trim(pc2.description)))
		call writeLog(build2("---->p.description=",trim(p.description)))
		call writeLog(build2("---->p.pw_group_desc=",trim(p.pw_group_desc)))
		if (trim(pc2.description) = trim(p.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
			call writeLog(build2("---->findstring(trim(pc2.description),p.description)="
				,trim(cnvtstring(findstring(trim(pc2.description),p.description)))))
			if (findstring(trim(pc2.description),p.description) = 0)
	
				t_rec->grouplist[gcnt].plan_name = concat(
							t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
			;017 else ;017
			;017 	t_rec->grouplist[gcnt].plan_name = p.description ;017
			endif 
			
		endif
		call writeLog(build2("---->t_rec->grouplist[gcnt].action_type=",trim(t_rec->grouplist[gcnt].action_type)))
		call writeLog(build2("---->t_rec->grouplist[gcnt].orig_action_type=",trim(t_rec->grouplist[gcnt].orig_action_type)))
		call writeLog(build2("----> leaving o.order_id=",cnvtstring(o.order_id)))
	foot apc.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order selection query sLAB_DOT_ORDER"))
	with nocounter
	
	call writeLog(build2("->sLAB_DOT_ORDER=1, sCHILD_ORDER=1"))
	select into "nl:"
		 apc.pathway_id
		,action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		,order_dt = format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
		,act_pw_comp apc
		,pathway_comp pc1
		,pathway_catalog pc2
		,pathway_catalog pc3
		,pathway p
	plan d
		where t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 1
		and t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 1
	join o
		where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		and   o.pathway_catalog_id > 0.0
		and   o.protocol_order_id > 0.0
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join pc3
		where pc3.pathway_catalog_id = o.pathway_catalog_id
	join e
		where e.encntr_id	= o.originating_encntr_id
	join apc
		;021 where apc.parent_entity_id = o.protocol_order_id
		where apc.parent_entity_id = o.order_id
	join pc1
		where pc1.pathway_comp_id =  apc.pathway_comp_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		 apc.pathway_id
		,oc.requisition_format_cd
		,order_dt  ;updated for date split
		,o.order_id
	head report
		cnt = 0
		gcnt = t_rec->group_cnt
		call writeLog(build2("---->inside order selection sLAB_DOT_ORDER,sCHILD_ORDER query"))
	head apc.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc.pathway_id))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
	head order_dt ;updated for date split	
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
		call writeLog(build2("----->added group=",trim(order_dt)))
	head o.order_id
		call writeLog(build2("----->added order_id=",trim(cnvtstring(o.order_id))))
		bc_common->encntr_id = o.originating_encntr_id
		;016 start
		call writeLog(build2("---->t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
		if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
			call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
			
		endif
		;016 end		
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= action_type ;013
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc.pathway_id
		t_rec->grouplist[gcnt].orderlist[cnt].order_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_catalog_id	= o.pathway_catalog_id
		t_rec->temp_orderlist[d.seq].processed = 1 ;010
	foot order_dt
		
	;REMOVED TO GET CHILD BREAK foot oc.requisition_format_cd
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
		t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
	    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
		if (trim(pc2.description) = trim(p.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
			
			if (findstring(trim(pc2.description),p.description) = 0)
				t_rec->grouplist[gcnt].plan_name = concat(
							t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
			endif
			
		endif
		call writeLog(build2("<-----leaving group=",trim(order_dt)))
	;t_rec->grouplist[gcnt].group_desc = concat("",t_rec->grouplist[gcnt].group_desc)		
	foot apc.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order sLAB_DOT_ORDER,sCHILD_ORDER selection query"))
	with nocounter
	
	/*start 018*/
	call writeLog(build2("->sLAB_DOT_ORDER=1, sCHILD_ORDER=0,not CARD_ALLSTATUS_ORDER_REQ"))
	select into "nl:"
		 apc.pathway_id
		,action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		,order_dt = format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
		,act_pw_comp apc
		,pathway_comp pc1
		,pathway_catalog pc2
		,pathway_catalog pc3
		,pathway p
	plan d
		where t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 1
		and t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0
		and t_rec->temp_orderlist[d.seq].requisition_format not in("CARD_ALLSTATUS_ORDER_REQ") ;023
	join o
		where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		and   o.pathway_catalog_id > 0.0
		;and   o.protocol_order_id > 0.0
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join pc3
		where pc3.pathway_catalog_id = o.pathway_catalog_id
	join e
		where e.encntr_id	= o.originating_encntr_id
	join apc
		where apc.parent_entity_id = o.order_id
	join pc1
		where pc1.pathway_comp_id =  apc.pathway_comp_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		 apc.pathway_id
		,oc.requisition_format_cd
		,order_dt  ;updated for date split
		,o.order_id
	head report
		cnt = 0
		gcnt = t_rec->group_cnt
		call writeLog(build2("---->inside order selection sLAB_DOT_ORDER,sCHILD_ORDER query"))
	head apc.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc.pathway_id))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
	head order_dt ;updated for date split	
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
		call writeLog(build2("----->added group=",trim(order_dt)))
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
		t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
	    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
		if (trim(pc2.description) = trim(p.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
			
			if (findstring(trim(pc2.description),p.description) = 0)
				t_rec->grouplist[gcnt].plan_name = concat(
							t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
			endif
			
		endif
	head o.order_id
		call writeLog(build2("----->added order_id=",trim(cnvtstring(o.order_id))))
		bc_common->encntr_id = o.originating_encntr_id
		;016 start
		call writeLog(build2("---->t_rec->grouplist[",trim(cnvtstring(gcnt)),"].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
		if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
			call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
			t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
			;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
			t_rec->grouplist[gcnt].single_order			= 0
			t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
			t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
		    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
			for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
					t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
				endif
			endfor
			cnt = 0
			t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
			if (trim(pc2.description) = trim(p.pw_group_desc))
				t_rec->grouplist[gcnt].plan_name = ""
			else
				t_rec->grouplist[gcnt].plan_name = pc2.description
				
				if (findstring(trim(pc2.description),p.description) = 0)
					t_rec->grouplist[gcnt].plan_name = concat(
								t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
				endif
				
			endif
		endif
		;016 end	
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= action_type ;013
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc.pathway_id
		t_rec->grouplist[gcnt].orderlist[cnt].order_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_catalog_id	= o.pathway_catalog_id
		t_rec->temp_orderlist[d.seq].processed = 1 ;010
	foot order_dt
		
	;REMOVED TO GET CHILD BREAK foot oc.requisition_format_cd
		
		call writeLog(build2("<-----leaving group=",trim(order_dt)))
	;t_rec->grouplist[gcnt].group_desc = concat("",t_rec->grouplist[gcnt].group_desc)		
	foot apc.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order sLAB_DOT_ORDER,sCHILD_ORDER selection query"))
	with nocounter
	/*end 018*/
	
	
	/*start 027*/
	call writeLog(build2("->sLAB_DOT_ORDER=0, sCHILD_ORDER=1,MI_REQ_FUTURE,AMB_REFERRAL_REQ,ORDRES_ECG_ORDER_REQ,LAB_BONE_MARROW"))
	select into "nl:"
		 apc.pathway_id
		,action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		,order_dt = format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
		,act_pw_comp apc
		,pathway_comp pc1
		,pathway_catalog pc2
		,pathway_catalog pc3
		,pathway p
	plan d
		where t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 0
		and t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 1	
		and t_rec->temp_orderlist[d.seq].requisition_format in("MI_REQ_FUTURE","AMB_REFERRAL_REQ","ORDRES_ECG_ORDER_REQ"
			,"LAB_BONE_MARROW") ;023
	join o
		where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		and   o.pathway_catalog_id > 0.0
		;and   o.protocol_order_id > 0.0
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join pc3
		where pc3.pathway_catalog_id = o.pathway_catalog_id
	join e
		where e.encntr_id	= o.originating_encntr_id
	join apc
		where apc.parent_entity_id = o.order_id
	join pc1
		where pc1.pathway_comp_id =  apc.pathway_comp_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		 apc.pathway_id
		,oc.requisition_format_cd
		,order_dt  ;updated for date split
		,o.order_id
	head report
		cnt = 0
		gcnt = t_rec->group_cnt
		call writeLog(build2("---->inside order selection sLAB_DOT_ORDER,sCHILD_ORDER,MI_REQ_FUTURE,AMB_REFERRAL_REQ query"))
	head apc.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc.pathway_id))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
	head order_dt ;updated for date split	
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
		call writeLog(build2("----->added group=",trim(order_dt)))
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
		t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
	    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
		if (trim(pc2.description) = trim(p.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
			
			if (findstring(trim(pc2.description),p.description) = 0)
				t_rec->grouplist[gcnt].plan_name = concat(
							t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
			endif
			
		endif
	head o.order_id
		call writeLog(build2("----->added order_id=",trim(cnvtstring(o.order_id))))
		bc_common->encntr_id = o.originating_encntr_id
		;016 start
		call writeLog(build2("---->t_rec->grouplist[",trim(cnvtstring(gcnt)),"].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
		if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
			call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
			t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
			;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
			t_rec->grouplist[gcnt].single_order			= 0
			t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
			t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
		    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
			for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
					t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
				endif
			endfor
			cnt = 0
			t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
			if (trim(pc2.description) = trim(p.pw_group_desc))
				t_rec->grouplist[gcnt].plan_name = ""
			else
				t_rec->grouplist[gcnt].plan_name = pc2.description
				
				if (findstring(trim(pc2.description),p.description) = 0)
					t_rec->grouplist[gcnt].plan_name = concat(
								t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
				endif
				
			endif
		endif
		;016 end	
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= action_type ;013
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc.pathway_id
		t_rec->grouplist[gcnt].orderlist[cnt].order_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_catalog_id	= o.pathway_catalog_id
		t_rec->temp_orderlist[d.seq].processed = 1 ;010
	foot order_dt
		
	;REMOVED TO GET CHILD BREAK foot oc.requisition_format_cd
		
		call writeLog(build2("<-----leaving group=",trim(order_dt)))
	;t_rec->grouplist[gcnt].group_desc = concat("",t_rec->grouplist[gcnt].group_desc)		
	foot apc.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order sLAB_DOT_ORDER,sCHILD_ORDER selection query"))
	with nocounter
	/*end 027*/
	
	/* 005 start
	select into "nl:"
		 apc.pathway_id
		,action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		,order_dt = format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
		,act_pw_comp apc
		,pathway_comp pc1
		,pathway_catalog pc2
		,pathway_catalog pc3
		,pathway p
	plan d
		where t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 1
		and t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0
		and t_rec->temp_orderlist[d.seq].sONCOLOGY_POWERPLAN_ORDER = 0
	join o
		where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		and   o.pathway_catalog_id > 0.0
		
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join pc3
		where pc3.pathway_catalog_id = o.pathway_catalog_id
	join e
		where e.encntr_id	= o.originating_encntr_id
	join apc
		where apc.parent_entity_id = o.order_id
	join pc1
		where pc1.pathway_comp_id =  apc.pathway_comp_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		 apc.pathway_id
		,oc.requisition_format_cd
		,order_dt  ;updated for date split
		,o.order_id
	head report
		cnt = 0
		gcnt = t_rec->group_cnt
		call writeLog(build2("---->inside order selection query"))
	head apc.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc.pathway_id))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
	head order_dt ;updated for date split	
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
	head o.order_id
		bc_common->encntr_id = o.originating_encntr_id
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc.pathway_id
		t_rec->grouplist[gcnt].orderlist[cnt].order_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q")
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_catalog_id	= o.pathway_catalog_id

	foot order_dt
	;REMOVED TO GET CHILD BREAK foot oc.requisition_format_cd
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 2
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
	    t_rec->grouplist[gcnt].group_dt				= format(o.current_start_dt_tm,"DD-MMM-YYYY;;Q") ;updated for date split
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
		if (trim(pc2.description) = trim(p.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
			
			if (findstring(trim(pc2.description),p.description) = 0)
				t_rec->grouplist[gcnt].plan_name = concat(
							t_rec->grouplist[gcnt].plan_name," (",trim(p.description),")")
			endif
			
		endif
	t_rec->grouplist[gcnt].group_desc = concat("2. ",t_rec->grouplist[gcnt].group_desc)	
	foot apc.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order selection query"))
	with nocounter
;005 end */
	
else
	call writeLog(build2("-> (else) t_rec->temp_powerplan_flag=",trim(cnvtstring(t_rec->temp_powerplan_flag))))
	call writeLog(build2("--> first query finding all orders for the plan"))
	select into "nl:"
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o1
		,orders o2
		,act_pw_comp apc1
		,act_pw_comp apc2
		,pathway_comp pc1
		,order_catalog oc2
		,pathway_catalog pc
		,pathway_catalog pc2
		,pathway p2
	plan d
		;start 023 
		/*
		where (
				(t_rec->temp_orderlist[d.seq].requisition_format = "LAB_OUTPATIENT_REQ")
			       or 
			        (			(t_rec->temp_orderlist[d.seq].requisition_format != "LAB_OUTPATIENT_REQ")
			        	 and 	(
			        	 			(		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 1) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 1))
			        	 		 or (		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 0))
			        	 		)
			        )
			  )
			  */
		;end 023
	join o1 
		where o1.order_id =   t_rec->temp_orderlist[d.seq].order_id
		/* start 02 */
		/* end 02 */
	join apc1
		where apc1.parent_entity_id = o1.order_id
	join apc2
		where apc2.pathway_id = apc1.pathway_id
	join o2
		where o2.order_id = apc2.parent_entity_id
		and   o2.order_id > 0.0
		and   o2.order_status_cd not in(
											 value(uar_get_code_by("MEANING",6004,"CANCELED"))
											,value(uar_get_code_by("MEANING",6004,"COMPLETED"))
											,value(uar_get_code_by("MEANING",6004,"DELETED"))
											,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
											,value(uar_get_code_by("MEANING",6004,"ORDERED")) ;008
										)
	join oc2
		where oc2.catalog_cd = o2.catalog_cd
		and oc2.requisition_format_cd = t_rec->temp_orderlist[d.seq].requisition_format_cd  ;020
	join p2
		where p2.pathway_id = apc2.pathway_id
	join pc1
		where pc1.pathway_comp_id = apc2.pathway_comp_id
	join pc
		where pc.pathway_catalog_id = p2.pathway_catalog_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	order by
		 apc2.pathway_id
		,oc2.requisition_format_cd
		,o2.order_id
	head report
		cnt = 0
		;019 gcnt = 0
		gcnt = t_rec->group_cnt ;019
		call writeLog(build2("---->inside order selection query"))
	head apc2.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc2.pathway_id))))
		call writeLog(build2("looking apc2.pathway_id=",trim(cnvtstring(apc2.pathway_id))))
		call writeLog(build2("looking at ",trim(p2.description)))
		call writeLog(build2("------>p2.pw_group_desc=",trim(substring(1,25,p2.pw_group_desc))))
		call writeLog(build2("------>p2.description=",trim(substring(1,25,p2.description))))
		call writeLog(build2("------>pc.description=",trim(substring(1,25,pc.description))))
		call writeLog(build2("------>pc2.description=",trim(substring(1,25,pc2.description))))
		cnt = 0
	head oc2.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc2.requisition_format_cd))))
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
	head o2.order_id
	 /*start 023*/
	 if  (
				(t_rec->temp_orderlist[d.seq].requisition_format = "LAB_OUTPATIENT_REQ")
			       or 
			        (			(t_rec->temp_orderlist[d.seq].requisition_format != "LAB_OUTPATIENT_REQ")
			        	 and 	(
			        	 			(		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 1) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 1))
			        	 		 or (		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 0))
			        	 		 or (		(t_rec->temp_orderlist[d.seq].sCHILD_ORDER = 0) 
			        	 				and (t_rec->temp_orderlist[d.seq].sLAB_DOT_ORDER = 2))
			        	 		)
			        )
			  )
	/*end 023*/
		bc_common->encntr_id = o2.originating_encntr_id
		;016 start
		call writeLog(build2("---->t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
		if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc2.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
			call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
		endif
		;016 end
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o2.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o2.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o2.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc2.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= value(uar_get_code_by("MEANING",6003,"MODIFY"))
		;;t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd ;013
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc2.pathway_id
		t_rec->temp_orderlist[d.seq].processed = 1
		call writeLog(build2("addded t_rec->grouplist[gcnt].orderlist[cnt].order_id="
			,trim(cnvtstring(t_rec->grouplist[gcnt].orderlist[cnt].order_id))))
	 endif ;023
	foot oc2.requisition_format_cd
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o2.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		;013 t_rec->grouplist[gcnt].action_type			= "MODIFY" 
		t_rec->grouplist[gcnt].action_type	= uar_get_code_meaning(t_rec->grouplist[gcnt].orderlist[cnt].action_cd) ;013
		t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean ;006
		
		/*start 013*/
		/*end 013*/
		
		for (j=1 to bc_common->requisition_cnt)
			if (oc2.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
				t_rec->grouplist[gcnt].req_desc 			 = bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p2.pw_group_desc
		t_rec->grouplist[gcnt].pathway_id = p2.pathway_id
		;not needed for modify (?)
		;if (trim(pc2.description) = trim(p2.pw_group_desc))
		;	t_rec->grouplist[gcnt].plan_name = ""
		;else
		;	t_rec->grouplist[gcnt].plan_name = pc2.description
		;endif
		;start 014
		if (trim(pc.description) = trim(p2.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""	
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
			
			if (findstring(trim(pc2.description),pc.description) = 0)
				t_rec->grouplist[gcnt].plan_name = concat(
							t_rec->grouplist[gcnt].plan_name," (",trim(pc.description),")")
			endif
			
		endif
		;end 014
	foot apc2.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order selection query"))
	with nocounter
	call writeLog(build2("--> finished first query finding all orders for the plan"))
	
	if (t_rec->group_cnt = 0)
		call writeLog(build2("t_rec->group_cnt=0, assume all orders in plan are canceled"))
		select into "nl:"
			action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		from
			 (dummyt d with seq=t_rec->temp_orderlist_cnt)
			,orders o
			,order_catalog oc
			,encounter e
		plan d
		join o
			where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		join oc
			where oc.catalog_cd	= o.catalog_cd
		join e
			where e.encntr_id	= o.originating_encntr_id
		order by
			 action_type
			,oc.requisition_format_cd
			,o.order_id
		head report
			cnt = 0
			;019 gcnt = 0
			gcnt = t_rec->group_cnt ;019
			call writeLog(build2("---->inside order selection query"))
		head action_type
			call writeLog(build2("---->inside action type=",trim(uar_get_code_display(action_type))))
			cnt = 0
		head oc.requisition_format_cd
			call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			t_rec->group_cnt = gcnt
		head o.order_id
			bc_common->encntr_id = o.originating_encntr_id
			;016 start
			call writeLog(build2("---->t_rec->grouplist[gcnt].order_cnt=",cnvtstring(t_rec->grouplist[gcnt].order_cnt)))
			if ((t_rec->grouplist[gcnt].order_cnt > 0) and (trim(uar_get_code_display(oc.requisition_format_cd)) != "LAB_OUTPATIENT_REQ"))
				call writeLog(build2("------>not the lab format and more than one order, increasing group count"))
				gcnt = (gcnt + 1)
				cnt = 0
				stat = alterlist(t_rec->grouplist,gcnt)
				t_rec->group_cnt = gcnt
			endif
			;016 end
			cnt = (cnt + 1)
			t_rec->grouplist[gcnt].order_cnt = cnt
			stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
			t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
			t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
			t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
			t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
			t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
			t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
			t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd
		
			/*for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					
					t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
					t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
					
				endif
			endfor*/
		
			;t_rec->grouplist[gcnt].group_desc 			= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
		foot oc.requisition_format_cd
			t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
															,trim(format(sysdate,"hhmmss;;d") ),".pdf")
			;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
			t_rec->grouplist[gcnt].single_order			= 1
			t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
			t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean  ;006
			for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					
					t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object
					t_rec->grouplist[gcnt].group_desc 			 = bc_common->requisition_qual[j].requisition_title
					
				endif
			endfor
			cnt = 0
		foot action_type
			call writeLog(build2("<-----exiting action selection query"))
		foot report
			t_rec->group_cnt = gcnt
			cnt = 0
			call writeLog(build2("<-----exiting order selection query"))
		with nocounter
	else
		/* start 002*/
		call writeLog(build2("-->t_rec->group_cnt=",trim(cnvtstring(t_rec->group_cnt ))))
		call writeLog(build2("-->checking if any documents need removal"))
	for (i=1 to t_rec->temp_orderlist_cnt)
		call writeLog(build2("--->i=",trim(cnvtstring(i))))
	 if ((t_rec->temp_orderlist[i].event_id > 0.0) and (t_rec->temp_orderlist[i].processed = 0))
		select into "nl:"
			action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		from
			(dummyt d with seq=t_rec->temp_orderlist_cnt)
			,orders o
			,order_catalog oc
			,encounter e
			,clinical_event ce
			,(dummyt d2)
		plan d
			where t_rec->temp_orderlist[d.seq].event_id = t_rec->temp_orderlist[i].event_id
		join ce
			where ce.event_id = t_rec->temp_orderlist[d.seq].event_id
			and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
			and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
			and     ce.result_status_cd in(
														  value(uar_get_code_by("MEANING",8,"AUTH"))
														 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
														 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
		
													)	
		join d2
		join o
			where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
			and   o.order_id > 0.0
			and   o.order_status_cd  in(
											 value(uar_get_code_by("MEANING",6004,"CANCELED"))
											,value(uar_get_code_by("MEANING",6004,"COMPLETED"))
											,value(uar_get_code_by("MEANING",6004,"DELETED"))
											,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
											,value(uar_get_code_by("MEANING",6004,"ORDERED")) ;008
										)
		join oc
			where oc.catalog_cd	= o.catalog_cd
		join e
			where e.encntr_id	= o.originating_encntr_id
		order by
			 action_type
			,ce.event_id
			,o.order_id
		head report
			cnt = 0
			;019 gcnt = 0
			gcnt = t_rec->group_cnt ;019
			empty = 0
			call writeLog(build2("---->inside order selection query"))
		head action_type
			call writeLog(build2("---->inside action type=",trim(uar_get_code_display(action_type))))
			cnt = 0
		head ce.event_id
			call writeLog(build2("---->inside ce.event=",trim(cnvtstring(ce.event_id))))
			empty = 0
			call writeLog(build2("----->empty=",trim(cnvtstring(empty))))
		head o.order_id
			call writeLog(build2("----->active order, o.order_id=",trim(cnvtstring(o.order_id))))
			if (o.order_id > 0.0)
			empty = (empty + 1)
		    
			call writeLog(build2("----->active order, empty=",trim(cnvtstring(empty))))
			endif
			/*for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					
					t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
					t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
					
				endif
			endfor*/
		
			;t_rec->grouplist[gcnt].group_desc 			= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
		foot ce.event_id

			call writeLog(build2("----->checking empty=",trim(cnvtstring(empty))))
		 if (empty > 0) 
		 	call writeLog(build2("------>setting up event removal"))
			gcnt = t_rec->group_cnt
			gcnt = (gcnt + 1)
			cnt = 0
			stat = alterlist(t_rec->grouplist,gcnt)
			cnt = (cnt + 1)
			t_rec->grouplist[gcnt].order_cnt = cnt
			stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
			t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
			t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
			t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
			t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
			t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
			t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
			t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= t_rec->temp_orderlist[d.seq].action_type_cd
			t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
															,trim(format(sysdate,"hhmmss;;d") ),".pdf")
			;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
			t_rec->grouplist[gcnt].single_order			= 1
			t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
			t_rec->grouplist[gcnt].orig_action_type		= t_rec->temp_orderlist[d.seq].orig_action_type_mean  ;006
			for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					
					t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object
					t_rec->grouplist[gcnt].group_desc 			 = bc_common->requisition_qual[j].requisition_title
					
				endif
			endfor
			cnt = 0
			t_rec->group_cnt = gcnt
			call writeLog(build2("---->leaving ce.event=",trim(cnvtstring(ce.event_id))))
		 endif
		foot action_type
			call writeLog(build2("<-----exiting action selection query"))
		foot report
			
			cnt = 0
			call writeLog(build2("<-----exiting order selection query"))
		with nocounter,outerjoin=d2
	   endif
	  endfor
		call writeLog(build2("-->t_rec->group_cnt=",trim(cnvtstring(t_rec->group_cnt ))))
		call writeLog(build2("-->leaving if any documents need removal"))
		/*end 002*/
		
	endif
	
endif

;017 checking plan names
call writeLog(build2("start checking plan names for requisition titles"))
if (t_rec->group_cnt > 0)
call writeLog(build2("t_rec->group_cnt=",t_rec->group_cnt))
select
	p.pw_group_desc
	,pc1.description
	,order_id=apc.parent_entity_id
from
	 pathway p
	,pathway_comp pc
	,act_pw_comp apc
	,pathway_catalog pc1
	,(dummyt d1 with seq=t_rec->group_cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,t_rec->grouplist[d1.seq].order_cnt)
join d2
	where t_rec->grouplist[d1.seq].orderlist[d2.seq].pathway_id > 0.0
join p
	where p.pathway_id = t_rec->grouplist[d1.seq].orderlist[d2.seq].pathway_id
join apc 
	where apc.pathway_id = p.pathway_id
join pc
	where pc.pathway_comp_id = apc.pathway_comp_id
join pc1
	where pc1.pathway_catalog_id = pc.pathway_catalog_id
	and   pc1.pathway_catalog_id > 0.0
head report
	call writeLog(build2("->insidie plan name query"))
detail
;head order_id
	call writeLog(build2("-->found plan pc1.description=",trim(substring(1,25,pc1.description))))
	call writeLog(build2("-->found plan p.description=",trim(substring(1,25,p.description))))
	call writeLog(build2("-->found plan order_id=",cnvtstring(order_id)))
	if (pc1.description = t_rec->grouplist[d1.seq].group_desc)
		call writeLog(build2("-->no change"))
		stat = 0 ;no change
	elseif (trim(p.description) = trim(pc1.description))
		t_rec->grouplist[d1.seq].plan_name = trim(pc1.description)
		call writeLog(build2("-->option 2=",t_rec->grouplist[d1.seq].plan_name))
	elseif (findstring(trim(pc1.description),trim(p.description)))
		t_rec->grouplist[d1.seq].plan_name = trim(p.description)
		call writeLog(build2("-->option 3=",t_rec->grouplist[d1.seq].plan_name))
	else
		t_rec->grouplist[d1.seq].plan_name = concat(trim(pc1.description)," (",trim(p.description),")")
		call writeLog(build2("-->option 4=",t_rec->grouplist[d1.seq].plan_name))
	endif
foot report
	call writeLog(build2("<-leaving plan name query"))
with nocounter
endif
call writeLog(build2("finished checking plan names for requisition titles"))
;end 017

call writeLog(build2("* END Adding PowerPlan Orders *******************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("bc_common->person_id=",trim(cnvtstring(bc_common->person_id))))
call writeLog(build2("bc_common->encntr_id=",trim(cnvtstring(bc_common->encntr_id))))

set t_rec->pass_count = (t_rec->pass_count + 1)

if ((t_rec->group_cnt = 0) and (t_rec->pass_count <= 5))
	set t_rec->temp_orderlist_cnt = 0
	set stat = alterlist(t_rec->temp_orderlist,t_rec->temp_orderlist_cnt)
	set stat = alterlist(t_rec->temp_list,t_rec->temp_orderlist_cnt)
	call writeLog(build2("t_rec->pass_count=",trim(cnvtstring(t_rec->pass_count))))
	call writeLog(build2("-->RESTARTING"))
	call pause(1)
	go to start_script
endif

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Find Existing Order Document ************************"))

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		for (j=1 to t_rec->grouplist[i].order_cnt)
			call writeLog(build2("-->Starting Query for existing document")) 
			call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].order_id=",trim(
				cnvtstring(t_rec->grouplist[i].orderlist[j].order_id))))
			
			select into "nl:"
			from
				clinical_Event ce 
			where 	ce.person_id = bc_common->person_id
			and		ce.event_cd = bc_common->pdf_event_cd
			and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
			and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
			and     ce.result_status_cd in(
												  value(uar_get_code_by("MEANING",8,"AUTH"))
												 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
												 ,value(uar_get_code_by("MEANING",8,"ALTERED"))

											)	
			;and     cnvtreal(ce.reference_nbr) = t_rec->grouplist[i].orderlist[j].order_id
								;start 024
					and ( (parser(concat(^ce.reference_nbr="*^,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id)),^*"^))) 
					    or (parser(concat(^ce.normal_ref_range_txt="*^,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id)),^*"^)))
					    )
					 ;end 024
			order by
				 ce.reference_nbr
				,ce.event_id
				,ce.valid_from_dt_tm desc
			head report
				call writeLog(build2("-->inside event query<--"))
			head ce.event_id
				t_rec->grouplist[i].orderlist[j].event_id = ce.event_id
				t_rec->grouplist[i].orderlist[j].parent_event_id = ce.parent_event_id
				call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].event_id=",trim(
				cnvtstring(ce.event_id))))
				t_rec->grouplist[i].orderlist[j].event_title_text = ce.event_title_text
			foot report
				call writeLog(build2("-->leaving event query<--"))
			with nocounter
			
			select into "nl:"
			from 
				ce_blob_result ceb
				,clinical_event ce
			plan ce
				where ce.parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
			join ceb
				where ceb.event_id = ce.event_id
			    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
			detail
				t_rec->grouplist[i].orderlist[j].blob_event_id = ceb.event_id
				call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].blob_event_id=",trim(
				cnvtstring(ceb.event_id))))
			with nocounter
		endfor
		/*start 013*/
		set pos = 0
		for (j=1 to t_rec->grouplist[i].order_cnt)
			
			if (t_rec->grouplist[i].orderlist[j].event_id > 0.0)
				set pos = 1
			endif
		endfor
		if (pos = 0)
			if (t_rec->grouplist[i].action_type = "MODIFY")
				if (t_rec->grouplist[i].orig_action_type = "ORDER")
					call writeLog(build2("-->NO DOCUMENT FOUND FOR MODIFY, RESETTING TO ORDER"))
					set t_rec->grouplist[i].action_type = "ORDER"
				endif
			endif
		endif
		/*end 013*/
			
	endfor
endif

call writeLog(build2("* Added Existing orders to order_list *********************"))
;TO-DO ADD IN STEP HERE TO PARSE the REFERENCE_NBR to get list of orders to group back into requisition.  

call writeLog(build2("* END Find Existing Order Document ***********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Add Orders to Request for Requisitions ************"))

call echorecord(t_rec)

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		if (t_rec->grouplist[i].order_cnt > 0)
 			
			set stat = initrec(req_request)
			call echorecord(req_request)
			set req_request->person_id 			= bc_common->person_id
			;027 set req_request->print_prsnl_id 	= reqinfo->updt_id
			set req_request->print_prsnl_id 	= 1.0 ;027
			set req_request->printer_name 		= t_rec->grouplist[i].printer_name
			set req_request->pdf_name			= req_request->printer_name 
			set req_request->printer_name 		= replace(req_request->printer_name,".pdf",".ps",2)
			set req_request->cnt = 0
			
			if (t_rec->grouplist[i].action_type in("MODIFY","ORDER"))
				call writeLog(build2(^t_rec->grouplist[i].action_type in("MODIFY","ORDER")^))
				for (j=1 to t_rec->grouplist[i].order_cnt)
						set req_request->cnt = (req_request->cnt + 1)
						set stat = alterlist(req_request->order_qual,req_request->cnt)
						set req_request->order_qual[req_request->cnt].order_id 			= t_rec->grouplist[i].orderlist[j].order_id
						set req_request->order_qual[req_request->cnt].encntr_id 		= t_rec->grouplist[i].orderlist[j].encntr_id
						set req_request->order_qual[req_request->cnt].conversation_id 	= 0.0
						;set req_request->order_qual[j].conversation_id 	= t_rec->grouplist[i].orderlist[1].conversation_id
						set req_request->requisition_script 				= t_rec->grouplist[i].requisition_script
						if (j=1)
							set t_rec->grouplist[i].reference_nbr			= trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id))
						else
							set t_rec->grouplist[i].reference_nbr			= concat(	trim(t_rec->grouplist[i].reference_nbr),":",
																			    		trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id
																			    		)))
						endif													
						call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(req_request->cnt)),"].order_id=",
							trim(cnvtstring(req_request->order_qual[req_request->cnt].order_id))))
						call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(req_request->cnt)),"].encntr_id=",
							trim(cnvtstring(req_request->order_qual[req_request->cnt].encntr_id))))
						call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(req_request->cnt)),"].conversation_id=",
							trim(cnvtstring(req_request->order_qual[req_request->cnt].conversation_id))))
						call writeLog(build2("-->adding:req_request->printer_name=",trim(req_request->printer_name)))
						call writeLog(build2("-->adding:req_request->requisition_script=",trim(req_request->requisition_script)))
						call writeLog(build2("-->adding:t_rec->grouplist[i].reference_nbr=",trim(t_rec->grouplist[i].reference_nbr)))
						
						call writeLog(build2("-->sONCOLOGY_POWERPLAN_ORDER([req_request->cnt ].order_id )="
							,trim(cnvtstring(sONCOLOGY_POWERPLAN_ORDER(req_request->order_qual[req_request->cnt ].order_id)))))
								
						call writeLog(build2("-->sLAB_DOT_ORDER([req_request->cnt ].order_id )="
								,trim(cnvtstring(sLAB_DOT_ORDER(req_request->order_qual[req_request->cnt ].order_id )))))
						
						          if (sONCOLOGY_POWERPLAN_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 1 )
						            set req_request->order_qual[req_request->cnt ].conversation_id = 1.00
						            
						            if (sONCOLOGY_DOT_PP_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 0 )
						              set req_request->order_qual[req_request->cnt ].conversation_id = 4.00
						            endif
						           
						          elseif (sLAB_DOT_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 1 ) 
						            ;Day of Treatment
						            set req_request->order_qual[req_request->cnt ].conversation_id = 2.00      
						          elseif (sLAB_DOT_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 2 )
						            ;Single & Multi-phase
						            set req_request->order_qual[req_request->cnt ].conversation_id = 3.00      
						          else
						            set req_request->order_qual[req_request->cnt ].conversation_id = 0.00
						          endif
          /*		
						  if (sONCOLOGY_POWERPLAN_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 1 )
           				 		set req_request->order_qual[req_request->cnt].conversation_id  = 1.00
         				  elseif (sLAB_DOT_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 1 ) 
            					;Day of Treatment
            					set req_request->order_qual[req_request->cnt].conversation_id = 2.00   
            					
            					if (t_rec->grouplist[i].single_order = 2)
            						set req_request->order_qual[req_request->cnt].conversation_id = 3.00
            					endif	
            					  
          				  elseif (sLAB_DOT_ORDER(req_request->order_qual[req_request->cnt ].order_id ) = 2 ) 
            					;Single & Multi-phase
            					set req_request->order_qual[req_request->cnt].conversation_id  = 3.00     
            					 
         					 else
         					 	;Single Order
            					set req_request->order_qual[req_request->cnt].conversation_id  = 0.00
          					endif
          	*/				
          					select into "nl:"
                 				o.current_start_dt_tm
            				from orders o
           					where o.order_id = req_request->order_qual[req_request->cnt ].order_id
 							detail
            					req_request->order_qual[req_request->cnt].order_dttm = format(o.current_start_dt_tm, "DD-MMM-YYYY;;Q" )
            				with nocounter
				endfor	
				if (req_request->requisition_script > " ")
					free set temp_request 
					set stat = copyrec(req_request,temp_request,1)
					
					set req_request->execute_statement =
						build2(^execute ^,trim(req_request->requisition_script),^ with replace("REQUEST",temp_request,5) go^)  
					call writeLog(build2(req_request->execute_statement))
					call parser(req_request->execute_statement)  
				endif
	 			
	 			set req_request->find_file_stat = findfile(req_request->printer_name)
	 			if (validate(req_request))
					call writeLog(build2("->writing req_request to ",trim(t_rec->log_filename_a)))
					call echojson(req_request,t_rec->log_filename_a,1)
					call echorecord(req_request)
				endif
				call writeLog(build2("->req_request->find_file_stat=",trim(cnvtstring(req_request->find_file_stat))))
				if (req_request->find_file_stat = 1)
					 set dclcom = build2(^gs -o ^
									,req_request->pdf_name,^ ^
  									,^-sDEVICE=pdfwrite ^
  									,^-dPDFSETTINGS=/screen ^
  									,^-dHaveTrueTypes=true ^
  									,^-dEmbedAllFonts=true ^
  									,^-dBufferSpace=2000000000 ^
  									,^-dNumRenderingThreads=6 ^
  									,^-dSubsetFonts=false ^
  									,^-c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams" ^
  									,^-f ^
  									,req_request->printer_name) 
  					/*
  					set dclcom = build2(^cp ^
  									,req_request->printer_name, ^ ^
									,req_request->pdf_name
									)
					*/
					set dclstat = 0
					
					call writeLog(build2( "dclcom=",trim(dclcom)))
					call dcl(dclcom, size(trim(dclcom)), dclstat) 
					call writeLog(build2( "dclstat=",trim(cnvtstring(dclstat))))
					
					set stat = initrec(mmf_store_reply)
					set stat = initrec(mmf_store_request)
					
		 
					set mmf_store_request->filename 			= concat(req_request->pdf_name)
					set mmf_store_request->mediatype 			= "application/pdf"
					

					
					set mmf_store_request->contenttype 			= bc_common->pdf_content_type
					
					set mmf_store_request->name 				= concat("Requisition ",trim(format(sysdate,";;q")))
					set mmf_store_request->personid 			= bc_common->person_id
					set mmf_store_request->encounterid 			= bc_common->encntr_id
	 
	
	 				call echorecord(mmf_store_request)
	 			
		 			call writeLog(build2(^--->execute mmf_store_object_with_xref^))
		 			call echojson(mmf_store_request,t_rec->log_filename_a,1)
					execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request), replace("REPLY",mmf_store_reply)
		 			call echojson(mmf_store_reply,t_rec->log_filename_a,1)
		 			
		 			set t_rec->identifier = mmf_store_reply->identifier
		 			set t_rec->grouplist[i].identifier = mmf_store_reply->identifier
		 			call writeLog(build2("---->set t_rec->identifier=",t_rec->identifier))
					call writeLog(build2("---->set t_rec->grouplist[i].identifier=",t_rec->grouplist[i].identifier))
				
					if (t_rec->grouplist[i].action_type in("MODIFY"))
						call writeLog(build2(^t_rec->grouplist[i].action_type in("MODIFY")^))
						call writeLog(build2("* looking to update Document Due to Modify *****************************"))
						for (j=1 to t_rec->grouplist[i].order_cnt)
							if (t_rec->grouplist[i].orderlist[j].event_id > 0.0)
								call writeLog(build2("* START Updating Document Due to Modify *****************************"))
								call writeLog(build2("-->substring(1,9,t_rec->grouplist[i].orderlist[j].event_title_text)=",
									substring(1,9,t_rec->grouplist[i].orderlist[j].event_title_text)))
									
								if (substring(1,9,t_rec->grouplist[i].orderlist[j].event_title_text) not in("ACTIONED:"))
									set t_rec->grouplist[i].orderlist[j].leave_authenticated = 1
								endif
								
								
								if (substring(1,9,t_rec->grouplist[i].orderlist[j].event_title_text) in("MODIFIED:","ACTIONED:"))
									set t_rec->grouplist[i].orderlist[j].event_title_text = trim(substring(10,200,
										t_rec->grouplist[i].orderlist[j].event_title_text))
								endif 
								
								call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].leave_authenticated=",
									cnvtstring(t_rec->grouplist[i].orderlist[j].leave_authenticated)))
									
								if (t_rec->grouplist[i].orderlist[j].leave_authenticated = 1)
									call writeLog(build2("-->inside leave_authenticated = 1"))
									/*
									update into clinical_Event 							
									set 
									;result_status_cd = value(uar_get_code_by("MEANING",8,"MODIFIED")), leave status alone
									  event_title_text		= concat("MODIFIED:",trim(t_rec->grouplist[i].orderlist[j].event_title_text)),
									  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
									  updt_id               = reqinfo->updt_id,
								      updt_task             = reqinfo->updt_task,
									  updt_cnt              = 0,
									  updt_applctx          = reqinfo->updt_applctx
									where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
									commit
									*/
									;006 start
									if (t_rec->grouplist[i].orig_action_type = "RESCHEDULE")
									call writeLog(build2("-->updating due to reschedule"))
									update into clinical_Event 							
										set ;event_end_dt_tm		= cnvtdatetime(curdate, curtime3),
										  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
										  updt_id               = reqinfo->updt_id,
									      updt_task             = reqinfo->updt_task,
										  updt_cnt              = 0,
										  updt_applctx          = reqinfo->updt_applctx,
										  reference_nbr			= substring(1,100,t_rec->grouplist[i].reference_nbr), ;012
										  normal_ref_range_txt	= t_rec->grouplist[i].reference_nbr ;024
										where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
										and view_level = 1 ;012
										commit
									else ;006 end
									call writeLog(build2("-->updating due to other than reschedule 1"))
									update into clinical_Event 							
										set event_end_dt_tm		= cnvtdatetime(curdate, curtime3),
										  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
										  updt_id               = reqinfo->updt_id,
									      updt_task             = reqinfo->updt_task,
										  updt_cnt              = 0,
										  updt_applctx          = reqinfo->updt_applctx,
										  reference_nbr			= substring(1,100,t_rec->grouplist[i].reference_nbr), ;012
										  normal_ref_range_txt	= t_rec->grouplist[i].reference_nbr ;024
										where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
										and view_level = 1 ;012
										commit								
									endif ;006
								else
									;006 start
									call writeLog(build2("-->inside leave_authenticated = 0"))
									if (t_rec->grouplist[i].orig_action_type = "RESCHEDULE")
										call writeLog(build2("-->updating due to reschedule"))
										update into clinical_Event 							
										set result_status_cd = value(uar_get_code_by("MEANING",8,"MODIFIED")),
										  ;event_title_text		= concat("MODIFIED:",trim(t_rec->grouplist[i].orderlist[j].event_title_text)),
										 ; event_end_dt_tm		= cnvtdatetime(curdate, curtime3),
										  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
										  updt_id               = reqinfo->updt_id,
									      updt_task             = reqinfo->updt_task,
										  updt_cnt              = 0,
										  updt_applctx          = reqinfo->updt_applctx
										where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
										and view_level = 1 ;012
										commit
									else
									;006 end
										call writeLog(build2("-->updating due to other than reschedule"))
										update into clinical_Event 							
										set result_status_cd = value(uar_get_code_by("MEANING",8,"MODIFIED")),
										  event_title_text		= concat("MODIFIED:",trim(t_rec->grouplist[i].orderlist[j].event_title_text)),
										  event_end_dt_tm		= cnvtdatetime(curdate, curtime3),
										  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
										  updt_id               = reqinfo->updt_id,
									      updt_task             = reqinfo->updt_task,
										  updt_cnt              = (updt_cnt +1),
										  updt_applctx          = reqinfo->updt_applctx,
										  reference_nbr			= substring(1,100,t_rec->grouplist[i].reference_nbr), ;012
										  normal_ref_range_txt	= t_rec->grouplist[i].reference_nbr ;024
										where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
										and view_level = 1 ;012
										commit
									endif ;006
								endif
							
								update into ce_blob_result 
								set blob_handle 		= t_rec->grouplist[i].identifier,
								  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
								  updt_id               = reqinfo->updt_id,
							      updt_task             = reqinfo->updt_task,
								  updt_cnt              = 0,
								  updt_applctx          = reqinfo->updt_applctx
								where event_id = t_rec->grouplist[i].orderlist[j].blob_event_id
								and   valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
								commit
								
								/*start 010*/
								call writeLog(build2("->checking if other groups have the same document"))
								call writeLog(build2("->current group=",i))
								for (kk=(i+1) to t_rec->group_cnt)
									call writeLog(build2("->starting group=",kk))
									if (t_rec->grouplist[kk].order_cnt > 0)
										for (jj=1 to t_rec->grouplist[kk].order_cnt)
										 if (t_rec->grouplist[i].orderlist[j].event_id = t_rec->grouplist[kk].orderlist[jj].event_id)
										 	call writeLog(build2("--->found another group with same document, removing"))
										 	set t_rec->grouplist[kk].orderlist[jj].event_id = 0.0
										 endif
										endfor
									endif
								endfor
								/*end 010*/
								
								call writeLog(build2("* END   Updating Document ************************************"))
					    
						    call writeLog(build2("* START  Adding Document Action ************************************"))
							set stat = initrec(ensure_request)
							set stat = alterlist(ensure_request->req, 1) 
							set ensure_request->req[1].ensure_type 			 		= 2 
							set ensure_request->req[1].version_dt_tm_ind 			= 1 
							set ensure_request->req[1].event_prsnl.event_id 		= t_rec->grouplist[i].orderlist[j].event_id
							set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"MODIFY"))  
							set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
							set ensure_request->req[1].event_prsnl.action_prsnl_id 	= reqinfo->updt_id
							set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
							set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
							set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
							set ensure_request->req[1].event_prsnl.action_comment = concat("")
							
							set update_ind = 1
							for (ii=1 to t_rec->temp_event_cnt)
								if (t_rec->grouplist[i].orderlist[j].event_id = t_rec->temp_eventlist[ii].event_id)
									set update_ind = 0
								endif
							endfor
							
							if (update_ind = 1)
								call writeLog(build2("-->execute inn_event_prsnl_batch_ensure"))
								execute inn_event_prsnl_batch_ensure 
									with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
								set t_rec->temp_event_cnt = (t_rec->temp_event_cnt + 1)
								set stat = alterlist(t_rec->temp_eventlist,t_rec->temp_event_cnt)
								set t_rec->temp_eventlist[t_rec->temp_event_cnt].event_id = t_rec->grouplist[i].orderlist[j].event_id 
								
								update into clinical_event ce 
								set ce.normal_ref_range_txt = t_rec->grouplist[i].reference_nbr
								where ce.event_id = t_rec->grouplist[i].orderlist[j].event_id
								commit
								
							else
								call writeLog(build2("-->SKIPPING inn_event_prsnl_batch_ensure, event already has action"))
							endif ;update_ind = 1
							endif ;t_rec->grouplist[i].orderlist[j].event_id > 0.0
							
							/*
							call writeLog(build2("** Finding TASK_ID *"))
							select into "nl:"
								from 
									task_activity ta
								plan ta
									where ta.event_id = t_rec->grouplist[i].orderlist[j].event_id
									and   ta.task_id > 0.0
									and   ta.task_status_cd = value(uar_get_code_by("MEANING",79,"PENDING"))
								order by
									ta.active_status_dt_tm
								head report
									cnt = 0
								detail
									t_rec->grouplist[i].orderlist[j].task_id = ta.task_id
								with nocounter
							call writeLog(build2("**t_rec->grouplist[i].orderlist[j].task_id=",
								trim(cnvtstring(t_rec->grouplist[i].orderlist[j].task_id))))
								
							if (t_rec->grouplist[i].orderlist[j].task_id > 0.0)
								call writeLog(build2("*--->task id found and updating task*"))
								set stat = 1
								update into task_activity ta
								set ta.scheduled_dt_tm =  cnvtdatetime(curdate,curtime3)
								    ,ta.task_dt_tm = cnvtdatetime(curdate,curtime3)
								     where ta.task_id = t_rec->grouplist[i].orderlist[j].task_id
								 commit 
							else
								set stat = 1
								call writeLog(build2("* START Adding Task for Modify ********************************"))
		
						set stat = initrec(560300_request)
						set 560300_request->person_id				= bc_common->person_id
						set 560300_request->encntr_id				= bc_common->encntr_id
						set 560300_request->stat_ind				= 0
						set 560300_request->task_class_cd 			= value(uar_get_code_by("MEANING",6025,"SCH")) 
						set 560300_request->reference_task_id 		= bc_common->reference_task_id
						set 560300_request->task_type_cd			= value(uar_get_code_by("DISPLAY",6026,"Print to PDF"))
						set 560300_request->task_activity_cd 		= value(uar_get_code_by("MEANING",6027,"CHART RESULT"))
						set 560300_request->task_status_cd 			= value(uar_get_code_by("MEANING",79,"PENDING"))
						set 560300_request->task_dt_tm				= cnvtdatetime(curdate,curtime3)
						
						call writeLog(build2(^560300_request->person_id=^,trim(cnvtstring(560300_request->person_id))))
						call writeLog(build2(^560300_request->encntr_id=^,trim(cnvtstring(560300_request->encntr_id))))
						call writeLog(build2(^560300_request->reference_task_id=^,trim(cnvtstring(560300_request->reference_task_id))))
						call writeLog(build2(^560300_request->task_type_cd=^,trim(cnvtstring(560300_request->task_type_cd))))
						call writeLog(build2(^560300_request->task_activity_cd=^,trim(cnvtstring(560300_request->task_activity_cd))))
						call writeLog(build2(^560300_request->task_status_cd=^,trim(cnvtstring(560300_request->task_status_cd))))
						
						call writeLog(build2(^execute dcp_add_task with replace("REQUEST",560300_request), replace("REPLY",560300_reply)^))
						
						execute dcp_add_task with replace("REQUEST",560300_request), replace("REPLY",560300_reply)  
						call writeLog(build2(cnvtrectojson(560300_reply)))
						call writeLog(build2(^560300_reply->task_id=^,trim(cnvtstring(560300_reply->task_id))))
						
						if (560300_reply->task_id > 0)
							call writeLog(build2(^updating task for modify^))
							call writeLog(build2(^t_rec->grouplist[i].orderlist[j].event_title_text=^
							,t_rec->grouplist[i].orderlist[j].event_title_text))
							
							call writeLog(build2(^t_rec->grouplist[i].orderlist[j].parent_event_id=^,
								cnvtstring(t_rec->grouplist[i].orderlist[j].parent_event_id)))
							update into 
								task_activity ta 
							set  ta.task_class_cd = value(uar_get_code_by("MEANING",6025,"SCH"))
								;,ta.msg_subject = "updated from order script"
								,ta.msg_subject = concat("MODIFIED:",trim(t_rec->grouplist[i].orderlist[j].event_title_text))
								,ta.event_id = t_rec->grouplist[i].orderlist[j].parent_event_id
								,ta.updt_id = 999
								,ta.updt_dt_tm = cnvtdatetime(curdate,curtime3)
								,ta.updt_cnt = (ta.updt_cnt + 1)
							where ta.task_id = 560300_reply->task_id
							call writeLog(build2(^finished updating task^))
							commit 
							call writeLog(build2(^finished commiting task^))
						endif
						 
						 
						call writeLog(build2("* END   Adding Task for modify ****************************************"))
							endif
							*/
							
						endfor;looping through modify orders
						call writeLog(build2(^-->ending modify logig^))		
					endif ;end MODIFY logic
				
				if (t_rec->grouplist[i].action_type in("ORDER"))
					call writeLog(build2(^t_rec->grouplist[i].action_type in("ORDER")^))
					set stat = initrec(mmf_publish_ce_request)
					set stat = initrec(mmf_publish_ce_reply)
		
		 			set mmf_publish_ce_request->documenttype_key 			= bc_common->pdf_display_key
					set mmf_publish_ce_request->service_dt_tm 				= cnvtdatetime(curdate, curtime3)
					set mmf_publish_ce_request->personId 					= bc_common->person_id
					set mmf_publish_ce_request->encounterId 				= bc_common->encntr_id
					
					set stat = alterlist(mmf_publish_ce_request->mediaObjects,1)
					set mmf_publish_ce_request->mediaObjects[1]->display 	= 'Requisition Attachment 1'
					set mmf_publish_ce_request->mediaObjects[1]->identifier = t_Rec->identifier
		
					set mmf_publish_ce_request->title = nullterm(
																	concat(
																				trim(t_rec->grouplist[i].group_desc), " ",
																				trim(t_rec->grouplist[i].plan_name)
																			)
																)
					if (t_rec->grouplist[i].group_desc != t_rec->grouplist[i].req_desc)
						set mmf_publish_ce_request->title = concat(mmf_publish_ce_request->title," - ",t_rec->grouplist[i].req_desc)
					endif
					
					set mmf_publish_ce_request->noteformat = 'AS'
					set mmf_publish_ce_request->publishAsNote=1
					set mmf_publish_ce_request->debug=1
					
					;FOR TESTING
					set mmf_publish_ce_request->title = concat(mmf_publish_ce_request->title,"")
					
					if (t_rec->grouplist[i].single_order = 1)
						set mmf_publish_ce_request->order_id =t_rec->grouplist[i].orderlist[1].order_id
					endif
					set mmf_publish_ce_request->reference_nbr = substring(1,100,build(trim(t_rec->grouplist[i].reference_nbr)))
					;024
					;set mmf_publish_ce_request->normal_ref_range_txt = substring(1,2000,build(trim(t_rec->grouplist[i].reference_nbr)))
					;024
					set stat = alterlist(mmf_publish_ce_request->personnel,4)
					
					;027 set mmf_publish_ce_request->personnel[1]->id 		= req_request->print_prsnl_id
					set mmf_publish_ce_request->personnel[1]->id 		= reqinfo->updt_id ;027
					set mmf_publish_ce_request->personnel[1]->action 	= 'PERFORM'
					set mmf_publish_ce_request->personnel[1]->status 	= 'COMPLETED'
					
					set mmf_publish_ce_request->personnel[2]->id 		=  reqinfo->updt_id ;027
					set mmf_publish_ce_request->personnel[2]->action 	= 'SIGN'
					set mmf_publish_ce_request->personnel[2]->status 	= 'COMPLETED'
					
					set mmf_publish_ce_request->personnel[3]->id 		=  reqinfo->updt_id ;027
					set mmf_publish_ce_request->personnel[3]->action 	= 'VERIFY'
					set mmf_publish_ce_request->personnel[3]->status 	= 'COMPLETED'
					
					set mmf_publish_ce_request->personnel[4]->id 		=  reqinfo->updt_id ;027
					set mmf_publish_ce_request->personnel[4]->action 	= 'ORDER'
					set mmf_publish_ce_request->personnel[4]->status 	= 'COMPLETED'
		
					if (validate(mmf_publish_ce_request))
						call echojson(mmf_publish_ce_request,t_rec->log_filename_a,1)
						call echorecord(mmf_publish_ce_request)
					endif
		 			
		 			call writeLog(build2(^--->execute bc_mmf_publish_ce^))
					execute bc_mmf_publish_ce with replace("REQUEST",mmf_publish_ce_request),replace("REPLY",mmf_publish_ce_reply)
					
					call writeLog(build2(^--->mmf_publish_ce_reply->parentEventId=^,trim(cnvtstring(mmf_publish_ce_reply->parentEventId))))
		 			
		 			;024
		 				if (mmf_publish_ce_reply->parentEventId > 0.0)
		 					update into clinical_Event 							
										set 
										  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
										  updt_id               = reqinfo->updt_id,
									      updt_task             = reqinfo->updt_task,
										  updt_cnt              = 0,
										  updt_applctx          = reqinfo->updt_applctx,
										  normal_ref_range_txt	= t_rec->grouplist[i].reference_nbr ;024
										where parent_event_id = mmf_publish_ce_reply->parentEventId
										and view_level = 1
										commit				
		 				endif
		 			;024
		 			
		 			if (validate(mmf_publish_ce_reply))
						call echojson(mmf_publish_ce_reply,t_rec->log_filename_a,1)
						call echorecord(mmf_publish_ce_reply)
					endif
					
					/*
					call writeLog(build2("* START Adding Task ****************************************"))
	
					set stat = initrec(560300_request)
					set 560300_request->person_id				= bc_common->person_id
					set 560300_request->encntr_id				= bc_common->encntr_id
					set 560300_request->stat_ind				= 0
					set 560300_request->task_class_cd 			= value(uar_get_code_by("MEANING",6025,"SCH")) 
					set 560300_request->reference_task_id 		= bc_common->reference_task_id
					set 560300_request->task_type_cd			= value(uar_get_code_by("DISPLAY",6026,"Print to PDF"))
					set 560300_request->task_activity_cd 		= value(uar_get_code_by("MEANING",6027,"CHART RESULT"))
					set 560300_request->task_status_cd 			= value(uar_get_code_by("MEANING",79,"PENDING"))
					set 560300_request->task_dt_tm				= cnvtdatetime(curdate,curtime3)
					
					call writeLog(build2(^560300_request->person_id=^,trim(cnvtstring(560300_request->person_id))))
					call writeLog(build2(^560300_request->encntr_id=^,trim(cnvtstring(560300_request->encntr_id))))
					call writeLog(build2(^560300_request->reference_task_id=^,trim(cnvtstring(560300_request->reference_task_id))))
					call writeLog(build2(^560300_request->task_type_cd=^,trim(cnvtstring(560300_request->task_type_cd))))
					call writeLog(build2(^560300_request->task_activity_cd=^,trim(cnvtstring(560300_request->task_activity_cd))))
					call writeLog(build2(^560300_request->task_status_cd=^,trim(cnvtstring(560300_request->task_status_cd))))
					
					call writeLog(build2(^execute dcp_add_task with replace("REQUEST",560300_request), replace("REPLY",560300_reply)^))
					
					execute dcp_add_task with replace("REQUEST",560300_request), replace("REPLY",560300_reply)  
					call writeLog(build2(cnvtrectojson(560300_reply)))
					call writeLog(build2(^560300_reply->task_id=^,trim(cnvtstring(560300_reply->task_id))))
					
					if (560300_reply->task_id > 0)
						update into 
							task_activity ta 
						set  ta.task_class_cd = value(uar_get_code_by("MEANING",6025,"SCH"))
							,ta.msg_subject =  mmf_publish_ce_request->title
							,ta.event_id = mmf_publish_ce_reply->parentEventId
						where ta.task_id = 560300_reply->task_id 
						commit 
					endif
					 
					 
					call writeLog(build2("* END   Adding Task ****************************************"))
					*/
				endif ;ORDER action
				
			endif ;req_request->find_file_stat = 1	
			
			
			elseif (t_rec->grouplist[i].action_type in("CANCEL")) ;Other was for action type order/modify
				call writeLog(build2("**Entering Cancel Mode"))
				
				for (j=1 to t_rec->grouplist[i].order_cnt)
					
					call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].order_id="
						,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id))))
					call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].event_id="
						,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].event_id))))
					
					call writeLog(build2("* START Adding Action ************************************"))
					if ((t_rec->grouplist[i].orderlist[j].order_id > 0.0) and
						(t_rec->grouplist[i].orderlist[j].event_id > 0.0))
						call writeLog(build2("-->order_id and event_id passed, adding action"))
						set stat = initrec(ensure_request)
						set stat = alterlist(ensure_request->req, 1) 
						set ensure_request->req[1].ensure_type 			 		= 2 
						set ensure_request->req[1].version_dt_tm_ind 			= 1 
						set ensure_request->req[1].event_prsnl.event_id 		= t_rec->grouplist[i].orderlist[j].event_id
						set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"CANCEL"))  
						set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
						set ensure_request->req[1].event_prsnl.action_prsnl_id 	= reqinfo->updt_id
						set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
						set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
						set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
						set ensure_request->req[1].event_prsnl.action_comment = concat("Order Canceled","")
						
						
						set update_ind = 1
						for (ii=1 to t_rec->temp_event_cnt)
							if (t_rec->grouplist[i].orderlist[j].event_id = t_rec->temp_eventlist[ii].event_id)
								set update_ind = 0
							endif
						endfor
						
						if (update_ind = 1)
							call writeLog(build2("-->execute inn_event_prsnl_batch_ensure"))
							execute inn_event_prsnl_batch_ensure 
								with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
							set t_rec->temp_event_cnt = (t_rec->temp_event_cnt + 1)
							set stat = alterlist(t_rec->temp_eventlist,t_rec->temp_event_cnt)
							set t_rec->temp_eventlist[t_rec->temp_event_cnt].event_id = t_rec->grouplist[i].orderlist[j].event_id 
						else
							call writeLog(build2("-->SKIPPING inn_event_prsnl_batch_ensure, event already has action"))
						endif ;update_ind = 1
						
						
					endif
					
					call writeLog(build2("* END Adding Action ************************************"))
					/*
					call writeLog(build2("* START Updating Task ************************************"))
						
					select into "nl:"
					from 
						task_activity ta
					plan ta
						where ta.event_id = t_rec->grouplist[i].orderlist[j].event_id
						and   ta.task_id > 0.0
						and   ta.task_status_cd in(
													value(uar_get_code_by("MEANING",79,"PENDING"))
												  )
					order by
						ta.active_status_dt_tm
					head report
						cnt = 0
					detail
						t_rec->grouplist[i].orderlist[j].task_id = ta.task_id
					with nocounter
					
					call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].task_id="
								,t_rec->grouplist[i].orderlist[j].task_id))
						
					if (t_rec->grouplist[i].orderlist[j].task_id > 0.0)
						set stat = initrec(dcp_request)
						call writeLog(build2("--->dcp_request initialized"))
						select into "nl:"
						 from task_activity ta 
						 where ta.task_id = t_rec->grouplist[i].orderlist[j].task_id
						head report 
							cnt = 0
							call writeLog(build2("------>inside query for task"))
						detail
						    cnt = (cnt + 1)
                                stat = alterlist (dcp_request->task_list, 1) 
                                dcp_request->task_list[cnt].task_id = ta.task_id
                                dcp_request->task_list[cnt]->person_id             = ta.person_id 
                                dcp_request->task_list[cnt]->catalog_type_cd         = ta.catalog_type_cd 
                                dcp_request->task_list[cnt]->order_id = ta.order_id
                                dcp_request->task_list[cnt]->encntr_id = ta.encntr_id
                                dcp_request->task_list[cnt]->reference_task_id = ta.reference_task_id
                                dcp_request->task_list[cnt]->task_type_cd = ta.task_type_cd
                                dcp_request->task_list[cnt]->task_class_cd = ta.task_class_cd
                                dcp_request->task_list[cnt]->prev_task_status_cd =    ta.task_status_cd
                                dcp_request->task_list[cnt]->task_dt_tm = cnvtdatetime(ta.task_dt_tm) 
                                dcp_request->task_list[cnt]->task_tz = ta.task_tz
                                dcp_request->task_list[cnt]->task_activity_cd = ta.task_activity_cd
                                dcp_request->task_list[cnt]->catalog_cd = ta.catalog_cd
                                dcp_request->task_list[cnt]->task_status_reason_cd = ta.task_status_reason_cd
                                dcp_request->task_list[cnt]->reschedule_ind = ta.reschedule_ind 
                                dcp_request->task_list[cnt]->reschedule_reason_cd = ta.reschedule_reason_cd
                                dcp_request->task_list[cnt]->med_order_type_cd = ta.med_order_type_cd
                                dcp_request->task_list[cnt]->task_priority_cd = ta.task_priority_cd
                                dcp_request->task_list[cnt]->charted_by_agent_cd = ta.charted_by_agent_cd
                                dcp_request->task_list[cnt]->charting_context_reference = ta.charting_context_reference 
                                dcp_request->task_list[cnt]->scheduled_dt_tm = cnvtdatetime(ta.scheduled_dt_tm)
                                dcp_request->task_list[cnt]->result_set_id = ta.result_set_id
                                dcp_request->task_list[cnt].task_status_cd = value(uar_get_code_by("MEANING",79,"CANCELED"))
                                dcp_request->task_list[cnt].msg_subject = ta.msg_subject
                            foot report
                                call writeLog(build2("<------leaving query for task"))
                            with nocounter
                            
                            call writeLog(build2("-----size(dcp_request->task_list,5)="
                                ,trim(cnvtstring(size(dcp_request->task_list,5)))))
                            for (k=1 to size(dcp_request->task_list,5))
                            	if (substring(1,9,dcp_request->task_list[k].msg_subject) in("MODIFIED:","ACTIONED:"))
									set dcp_request->task_list[k].msg_subject = trim(substring(10,200,
										dcp_request->task_list[k].msg_subject))
								endif 
                                call writeLog(build2("-------->inside task action for task=",
                                    trim(cnvtstring(dcp_request->task_list[k]->task_id))))
                                insert into task_action tac
                                set
                                  tac.seq = 1,
                                  tac.task_id               = dcp_request->task_list[k]->task_id,
                                  tac.task_action_seq       = seq(carenet_seq,nextval),
                                  tac.task_status_cd        = dcp_request->task_list[k]->prev_task_status_cd,
                                  tac.task_dt_tm            = cnvtdatetime (dcp_request->task_list[k]->task_dt_tm),
                                  tac.task_tz               = dcp_request->task_list[k]->task_tz,
                                
                                  tac.task_status_reason_cd = dcp_request->task_list[k]->task_status_reason_cd,
                                  tac.reschedule_reason_cd  = dcp_request->task_list[k]->reschedule_reason_cd,
                                  tac.scheduled_dt_tm       = cnvtdatetime(dcp_request->task_list[k]->scheduled_dt_tm),
                                  tac.updt_dt_tm            = cnvtdatetime(curdate, curtime3),
                                  tac.updt_id               = reqinfo->updt_id,
                                  tac.updt_task             = reqinfo->updt_task,
                                  tac.updt_cnt              = 0,
                                  tac.updt_applctx          = reqinfo->updt_applctx
                                with nocounter
                                call writeLog(build2("<-------leaving task action for task"))
                                commit  
                                call writeLog(build2("-------->inside task activity for task=",
                                trim(cnvtstring(dcp_request->task_list[k]->task_id))))
                                update into task_activity ta
                                set ta.task_status_cd = dcp_request->task_list[k].task_status_cd,
                                  ta.msg_subject		   = concat("CANCELED:",trim(dcp_request->task_list[k].msg_subject)),
                                  ta.updt_dt_tm            = cnvtdatetime(curdate, curtime3),
                                  ta.updt_id               = reqinfo->updt_id,
                                  ta.updt_task             = reqinfo->updt_task,
                                  ta.updt_cnt              = 0,
                                  ta.updt_applctx          = reqinfo->updt_applctx
                                where ta.task_id = dcp_request->task_list[k]->task_id
                                call writeLog(build2("<-------leaving task activity for task"))
                                commit
                            endfor
						endif ;task_id > 0.0
						*/
						
						if (t_rec->grouplist[i].orderlist[j].event_id > 0.0)
							call writeLog(build2("* START Updating Document ************************************"))
							
							if (substring(1,9,t_rec->grouplist[i].orderlist[j].event_title_text) in("MODIFIED:","ACTIONED:"))
								set t_rec->grouplist[i].orderlist[j].event_title_text = trim(substring(10,200,
									t_rec->grouplist[i].orderlist[j].event_title_text))
							endif 
							
							update into clinical_Event 
							set result_status_cd = value(uar_get_code_by("MEANING",8,"INERROR")),
							event_title_text		= concat("CANCELED:",trim(t_rec->grouplist[i].orderlist[j].event_title_text)),
							  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
							  updt_id               = reqinfo->updt_id,
								 updt_task             = reqinfo->updt_task,
							  updt_cnt              = 0,
							  updt_applctx          = reqinfo->updt_applctx
							where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
							commit
							
							update into ce_blob_result 
							set blob_handle 		= "",
							  valid_until_dt_tm		= cnvtdatetime(curdate, curtime3),
							  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
							  updt_id               = reqinfo->updt_id,
						      updt_task             = reqinfo->updt_task,
							  updt_cnt              = 0,
							  updt_applctx          = reqinfo->updt_applctx
							where event_id         = t_rec->grouplist[i].orderlist[j].blob_event_id
							and   valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
							commit
							
							call writeLog(build2("* END   Updating Document ************************************"))
						endif
							
						call writeLog(build2("* END   Updating Task ************************************"))
					
					endfor;exit cancel mode loop
				call writeLog(build2("**Exiting Cancel Mode"))
			endif ;ORDER or MODIFY
		endif ;order_cnt > 0
	endfor ;group list loop
endif ;group_cnt > 0

call writeLog(build2("* END   Add Orders to Requests ******************************"))



#exit_script
if (bc_common->valid_ind = 1)
	;if (validate(requestin))
	;	call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
;		call echojson(requestin,t_rec->log_filename_a);
;		call echorecord(requestin)
;	endif
	
	if (validate(request))
		call echojson(request,t_rec->log_filename_a,1)
		call echorecord(request)
	endif
	if (validate(reqinfo))
		call echojson(reqinfo,t_rec->log_filename_a,1)
		call echorecord(reqinfo)
	endif
	if (validate(bc_common))
		call echojson(bc_common,t_rec->log_filename_a,1)
		call echorecord(bc_common)
	endif
	if (validate(t_rec))
		call echojson(t_rec,t_rec->log_filename_a,1)
		call echorecord(t_rec)
	endif
endif
call writeLog(build2("* END SCRIPT"))
call exitScript(null)

#exit_script_no_log

end
go
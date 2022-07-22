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
001   11/10/2020  Chad Cummings			Added check for Paper Referral to determine if modify is actually new
******************************************************************************/
drop program pfmt_test_s_print_to_pdf_req:dba go
create program pfmt_test_s_print_to_pdf_req:dba

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
call bc_get_single_ord_requisitions(0)
;call bc_get_task_definition(0)
call bc_get_included_locations(0)
call bc_get_scheduling_fields(0)

free record t_request
record t_request
(
	1 cnt 						= i2
	1 qual[*]
	 2 skipind					= i2
	 2 orderid					= f8
	 2 actiontypecd				= f8
	 2 requisitionformatcd		= f8
	 2 detaillist_cnt			= i2
	 2 detaillist[*]
	  3 oefieldid				= f8
	  3 oefieldvalue			= f8
)	

free record t_rec
record t_rec
(
	1 cnt						= i4
	1 temp_valid_ind			= i2
	1 requestin_ind				= i2
	1 identifier				= vc
	1 sysdate_string			= vc
	1 future_status_cd			= f8
	1 print_dir					= vc
	1 log_filename_a			= vc
	1 log_filename_request		= vc
	1 prsnl_id 					= f8
	1 patient_name				= vc
)

free record temp_orders
record temp_orders
(
	1 cnt						= i2
	1 qual[*]
	 2 skip_ind					= i2
	 2 processed_ind			= i2
	 2 order_id					= f8
	 2 order_mnemonic			= vc
	 2 order_status_cd			= f8
	 2 dept_status_cd			= f8
	 2 pathway_id				= f8
	 2 pathway_comp_id			= f8
	 2 pathway_type_mean		= vc
	 2 pathway_catalog_id		= f8
	 2 template_order_id		= f8
	 2 protocol_order_id		= f8
	 2 template_order_flag		= i2
	 2 encntr_id				= f8
	 2 originating_encntr_id	= f8
	 2 person_id				= f8
	 2 catalog_cd				= f8
	 2 requsition_format_cd		= f8
	 2 action_type_cd			= f8
	 2 original_action_type_cd	= f8
	 2 paper_requisition_ind	= f8	;indicates that the order has the paper OEF	;001
)

free record single_wip
record single_wip
(
	1 cnt						= i2
	1 qual[*]
	 2 skip_ind					= i2
	 2 processed_ind			= i2
	 2 event_title_text			= vc
	 2 current_event_title_text = vc
	 2 new_event_title_text		= vc
	 2 current_document_status	= vc
	 2 current_document_dt_tm	= dq8
	 2 new_document_dt_tm		= dq8
	 2 new_document_status		= vc
	 2 normal_ref_range_txt		= vc
	 2 requisition_format_cd	= f8
	 2 requisition_script		= vc
	 2 requisition_title		= vc
	 2 plan_desc				= vc
	 2 cycle_desc				= vc
	 2 phase_desc				= vc
	 2 day_desc					= vc
	 2 action_type				= vc
	 2 order_mnemonic			= vc
	 2 order_id					= f8
	 2 template_order_id		= f8
	 2 protocol_order_id		= f8
	 2 postscript_filename		= vc
	 2 pdf_filename				= vc
	 2 person_id				= f8
	 2 encntr_id				= f8	
	 2 event_id					= f8
	 2 blob_event_id			= f8
	 2 parent_event_id			= f8
	 2 pathway_id				= f8 
	 2 type_mean				= vc
	 2 identifier				= vc
	 2 print_prsnl_id			= f8
	 2 conversation_id			= f8
	 2 use_protocol_ind			= i2
	 2 use_template_ind			= i2
	 2 paper_requisition_ind	= f8	;indicates that the order has the paper OEF ;001
)

set t_rec->future_status_cd			= uar_get_code_by("MEANING",6004,"FUTURE")
set t_rec->print_dir 				= concat(
												 "/cerner/d_"
												,trim(cnvtlower(curdomain))
												,"/print/"
											)
set t_rec->sysdate_string 			= format(sysdate,"yyyymmddhhmmss;;d") 
set t_rec->log_filename_request 	= concat ("cclscratch:requestin_560201_" ,t_rec->sysdate_string ,".dat" )
set t_rec->log_filename_a 			= concat ("cclscratch:test_s_560201_records_" ,t_rec->sysdate_string ,".dat" )

declare notfnd = vc with constant("<not found>")
declare order_string = vc with noconstant(" ")
declare phase_desc = vc with noconstant(" ")

call writeLog(build2("* Check to see whether we got requestin-request or just requestin"))

if(not validate(requestin->request,0))
   call writeLog(build2("->Order was processed by async order server and request 560200.  Therefore we got requestin as requestin"))
   set bc_common->person_id = requestin->personid
   set bc_common->requestin_ind = 0	;requestin as requestin
   set t_rec->log_filename_request 	= replace(t_rec->log_filename_request,"560201","560200")
   set t_rec->log_filename_a 		= replace(t_rec->log_filename_request,"560201","560200")
else
   call writeLog(build2("->Order was processed by sync order server and request 560201. requestin as requestin->request."))
   set bc_common->person_id 		= requestin->request->personid
   set bc_common->requestin_ind 	= 1	;requestin as requestin->request
endif

call writeLog(build2("->bc_common->person_id =",trim(cnvtstring(bc_common->person_id))))

call writeLog(build2("**Global Process *********************************************"))
call writeLog(build2("* START Add Orders to Temp (t_request) **********************"))

if (bc_common->requestin_ind = 1)
	call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->request->orderlist,5)))))
	for (i=1 to size(requestin->request->orderlist,5))
		set t_request->cnt = (t_request->cnt + 1)
		set stat = alterlist(t_request->qual,t_request->cnt)
		set t_request->qual[t_request->cnt].orderid					= requestin->request->orderlist[i].orderid
		set t_request->qual[t_request->cnt].requisitionformatcd		= requestin->request->orderlist[i].requisitionformatcd
		set t_request->qual[t_request->cnt].actiontypecd			= requestin->request->orderlist[i].actiontypecd
		for (j=1 to size(requestin->request->orderlist[i]->detaillist,5))
			if (requestin->request->orderlist[i]->detaillist[j].oefieldid in(bc_common->scheduling_location_field_id,
						bc_common->scheduling_location_field_non_radiology_id))
				set t_request->qual[t_request->cnt].detaillist_cnt = (t_request->qual[t_request->cnt].detaillist_cnt + 1)
				set stat = alterlist(t_request->qual[t_request->cnt].detaillist,t_request->qual[t_request->cnt].detaillist_cnt)
				set t_request->qual[t_request->cnt].detaillist[t_request->qual[t_request->cnt].detaillist].oefieldid = 
					requestin->request->orderlist[i]->detaillist[j].oefieldid
				set t_request->qual[t_request->cnt].detaillist[t_request->qual[t_request->cnt].detaillist].oefieldvalue = 
					requestin->request->orderlist[i]->detaillist[j].oefieldvalue
			endif
		endfor
	endfor
else
	call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->orderlist,5)))))
	for (i=1 to size(requestin->orderlist,5))
		set t_request->cnt = (t_request->cnt + 1)
		set stat = alterlist(t_request->qual,t_request->cnt)
		set t_request->qual[t_request->cnt].orderid					= requestin->orderlist[i].orderid
		set t_request->qual[t_request->cnt].requisitionformatcd		= requestin->orderlist[i].requisitionformatcd
		set t_request->qual[t_request->cnt].actiontypecd			= requestin->orderlist[i].actiontypecd
		for (j=1 to size(requestin->orderlist[i]->detaillist,5))
			if (requestin->orderlist[i]->detaillist[j].oefieldid in(bc_common->scheduling_location_field_id,
						bc_common->scheduling_location_field_non_radiology_id))
				set t_request->qual[t_request->cnt].detaillist_cnt = (t_request->qual[t_request->cnt].detaillist_cnt + 1)
				set stat = alterlist(t_request->qual[t_request->cnt].detaillist,t_request->qual[t_request->cnt].detaillist_cnt)
				set t_request->qual[t_request->cnt].detaillist[t_request->qual[t_request->cnt].detaillist].oefieldid = 
					requestin->orderlist[i]->detaillist[j].oefieldid
				set t_request->qual[t_request->cnt].detaillist[t_request->qual[t_request->cnt].detaillist].oefieldvalue = 
					requestin->orderlist[i]->detaillist[j].oefieldvalue
			endif
		endfor
	endfor
endif

call echorecord(t_request)

call writeLog(build2("* END Add Orders to Temp (t_request) ************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("**Global Process *********************************************"))
call writeLog(build2("* START Validate Patient ************************************"))

select into "nl:"
from 
	person p
plan p 
	where p.person_id = bc_common->person_id
detail
	call writeLog(build2("--->",trim(p.name_full_formatted)))
	;THIS WILL NOT PROCESS PLAY PATIENTS, Turning off name validation for this script
	t_rec->patient_name = p.name_full_formatted
	if (p.name_first_key = "PDF*")
		bc_common->valid_ind = 1
	endif
	if (p.name_last_key = "CSTPDF*")
		bc_common->valid_ind = 1
		t_rec->temp_valid_ind = 1
	endif
	/*
	if ((p.name_first_key = "PLAY*") and (p.name_last_key = "CSTPDF*"))
		bc_common->valid_ind = 0
	endif
	bc_common->valid_ind = 0
	if ((p.name_first_key = "TESTONE") and (p.name_last_key = "CSTPDF*"))
		bc_common->valid_ind = 1
	endif
		if ((p.name_first_key = "TESTDOT") and (p.name_last_key = "CSTPDF*"))
		bc_common->valid_ind = 1
	endif
	*/
with nocounter

if ((bc_common->location_cnt > 0) and (bc_common->valid_ind = 1))
	
	set bc_common->valid_ind = 0

	select into "nl:"
	from
		(dummyt d1 with seq=t_request->cnt)
		,encounter e
		,orders o
	plan d1
		where t_request->qual[d1.seq].orderid > 0.0
	join o
		where o.order_id = t_request->qual[d1.seq].orderid
	join e
		where e.encntr_id = o.originating_encntr_id
	order by
		 e.loc_nurse_unit_cd
		,e.encntr_id
	head report
		call writeLog(build2("->Inside Encounter Location Query"))
		cnt = 0
	head e.loc_nurse_unit_cd
		cnt = 0
		call writeLog(build2("looping through locations"))
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
		if (rec_to_file = 1)
			call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
			call echojson(requestin,t_rec->log_filename_request)
		endif
	endif
	go to exit_script
else
	call writeLog(build2("--->PATIENT PASSED"))
	call writeLog(build2("*-> Valid Patient, starting ",trim(t_rec->log_filename_a)," with requestin"))
	if (validate(requestin) and (rec_to_file = 1))
		call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_request)))
		call echojson(requestin,t_rec->log_filename_request)
	endif
endif

if (validate(t_request) and (rec_to_file = 1))
	call echojson(t_request,t_rec->log_filename_a,1)
endif


call writeLog(build2("* END Validate Patient **************************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("**Global Process *********************************************"))
call writeLog(build2("* START Getting Order Information (temp_orders) *************"))
call writeLog(build2("->getting orders information (1)"))
select into "nl:"
from
	 orders o
	,order_catalog oc
	,(dummyt d1 with seq=t_request->cnt)
plan d1
	where t_request->qual[d1.seq].orderid > 0.0
	and	  t_request->qual[d1.seq].skipind = 0
join o
	where o.order_id = t_request->qual[d1.seq].orderid
join oc
	where oc.catalog_cd = o.catalog_cd
order by
	o.order_id
head report
	call writeLog(build2("-->inside orders information (1)"))
	cnt = temp_orders->cnt
head o.order_id	
	call writeLog(build2("--->inside order_id=",trim(cnvtstring(o.order_id))))
	call writeLog(build2("--->order_mnemonic=",trim(o.order_mnemonic)))
	cnt = (cnt + 1)
	stat = alterlist(temp_orders->qual,cnt)
	temp_orders->qual[cnt].order_id					= o.order_id
	temp_orders->qual[cnt].catalog_cd				= o.catalog_cd
	temp_orders->qual[cnt].encntr_id				= o.encntr_id
	temp_orders->qual[cnt].originating_encntr_id	= o.originating_encntr_id
	temp_orders->qual[cnt].pathway_catalog_id		= o.pathway_catalog_id
	temp_orders->qual[cnt].person_id				= o.person_id
	temp_orders->qual[cnt].protocol_order_id		= o.protocol_order_id
	temp_orders->qual[cnt].template_order_id		= o.template_order_id
	temp_orders->qual[cnt].template_order_flag		= o.template_order_flag
	temp_orders->qual[cnt].order_status_cd			= o.order_status_cd
	temp_orders->qual[cnt].dept_status_cd			= o.dept_status_cd
	temp_orders->qual[cnt].order_mnemonic			= o.order_mnemonic
	
	temp_orders->qual[cnt].requsition_format_cd		= oc.requisition_format_cd
foot o.order_id
	temp_orders->qual[cnt].action_type_cd			= t_request->qual[d1.seq].actiontypecd
	temp_orders->qual[cnt].original_action_type_cd	= t_request->qual[d1.seq].actiontypecd
	
	if (o.order_status_cd not in(
									value(uar_get_code_by("MEANING",6004,"FUTURE"))
								))
		temp_orders->qual[cnt].skip_ind = 1
	endif
	
	if (uar_get_code_meaning(oc.requisition_format_cd) in("AMBREFERREQ","PROVECHOREQ","CRDASTATREQ","MIREQUISITN"))
		for (j=1 to t_request->qual[d1.seq].detaillist_cnt)
			if (t_request->qual[d1.seq].detaillist[j].oefieldid in(	bc_common->scheduling_location_field_id,
																	bc_common->scheduling_location_field_non_radiology_id))
				if (
							(t_request->qual[d1.seq].detaillist[j].oefieldvalue 
								not in(bc_common->print_to_paper_cd,bc_common->paper_referral_cd))
					 	and (t_request->qual[d1.seq].detaillist[j].oefieldvalue > 0.0)
					)
						temp_orders->qual[cnt].skip_ind = 1
				else
					temp_orders->qual[cnt].paper_requisition_ind = t_request->qual[d1.seq].detaillist[j].oefieldid ;001
				endif
			endif
		endfor
	endif
	call writeLog(build2("<---leaving order_id=",trim(cnvtstring(o.order_id))))
foot report
	temp_orders->cnt = cnt
	call writeLog(build2("<--leaving orders information (1)"))
with nocounter,nullreport


call writeLog(build2("->getting pathway information (1)"))
select into "nl:"
from
	orders o
	,act_pw_comp apc
	,pathway p
	,(dummyt d1 with seq=temp_orders->cnt)
plan d1
	where temp_orders->qual[d1.seq].order_id > 0.0
	and	  temp_orders->qual[d1.seq].skip_ind = 0
join o
	where o.order_id = temp_orders->qual[d1.seq].order_id
join apc
	where apc.parent_entity_id = o.order_id
join p
	where p.pathway_id = apc.pathway_id
order by
	o.order_id
head report
	call writeLog(build2("-->inside pathway information (1)"))
head o.order_id
	call writeLog(build2("--->inside order_id=",trim(cnvtstring(o.order_id))))
	temp_orders->qual[d1.seq].pathway_id 		= apc.pathway_id
	temp_orders->qual[d1.seq].pathway_comp_id	= apc.pathway_comp_id
	temp_orders->qual[d1.seq].pathway_type_mean	= p.type_mean
foot o.order_id	
	call writeLog(build2("<---leaving order_id=",trim(cnvtstring(o.order_id))))
foot report
	call writeLog(build2("<--leaving pathway information (1)"))
with nocounter,nullreport

if (validate(temp_orders) and (rec_to_file = 1))
	call echojson(temp_orders,t_rec->log_filename_a,1)
endif

call writeLog(build2("* END   Getting Order Information (temp_orders) *************"))
call writeLog(build2("*************************************************************"))

call echorecord(temp_orders)

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Building Single Order WIP (single_wip) **************"))

call writeLog(build2("->getting single req orders information (1)"))
select into "nl:"
	 order_id = temp_orders->qual[d1.seq].order_id
	,template_order_flag = temp_orders->qual[d1.seq].template_order_flag
	,protocol_order_id = temp_orders->qual[d1.seq].protocol_order_id
from
	(dummyt d1 with seq=temp_orders->cnt)
plan d1
	where temp_orders->qual[d1.seq].order_id > 0.0
	and	  temp_orders->qual[d1.seq].skip_ind = 0
order by
	 order_id
	,template_order_flag
	,protocol_order_id
head report
	call writeLog(build2("-->inside single req orders information (1)"))
	pass_ind = 0
	cnt = single_wip->cnt
detail
	call writeLog(build2("--->inside order_id=",trim(cnvtstring(temp_orders->qual[d1.seq].order_id))))
	call writeLog(build2("--->inside order_mnemonic=",trim(temp_orders->qual[d1.seq].order_mnemonic)))
	pass_ind = 0
	for (j=1 to bc_common->requisition_cnt)
		if (
				(temp_orders->qual[d1.seq].requsition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
			and (bc_common->requisition_qual[j].collation_seq = 1)
			)
				pass_ind = 1
			endif
		endfor
	call writeLog(build2("---->after req format check=",trim(cnvtstring(pass_ind))))	
	if (pass_ind = 1)
		;check for DOT and child
		if (
					(temp_orders->qual[d1.seq].pathway_type_mean in("DOT","PHASE"))
				and (temp_orders->qual[d1.seq].template_order_flag != 0)
			)
			pass_ind = 0
		endif
		;TESTING, allow if DOT and Group and Screen
		if (
					(temp_orders->qual[d1.seq].pathway_type_mean in("PHASE"))
				and (temp_orders->qual[d1.seq].template_order_flag != 0)
				and (temp_orders->qual[d1.seq].requsition_format_cd 
								in(uar_get_code_by("DISPLAY",6002,"GROUP_SCREEN_REQUISITION")))
			)
			pass_ind = 1
		endif
	endif
	/*
	if (pass_ind = 1)
		call writeLog(build2("---->If protocol or template, skip if parent is already added"))
		if (
					(temp_orders->qual[d1.seq].template_order_id > 0.0)
				or	(temp_orders->qual[d1.seq].protocol_order_id > 0.0)
			)
			call writeLog(build2("----->protocol_order_id=",cnvtstring(temp_orders->qual[d1.seq].protocol_order_id)))
			call writeLog(build2("----->template_order_id=",cnvtstring(temp_orders->qual[d1.seq].template_order_id)))
			for (j=1 to single_wip->cnt)
				call writeLog(build2("------>comparing=",cnvtstring(single_wip->qual[j].order_id)))
				if (
						(single_wip->qual[j].order_id = temp_orders->qual[d1.seq].protocol_order_id)
					 or	(single_wip->qual[j].order_id = temp_orders->qual[d1.seq].template_order_flag))
					call writeLog(build2("------>parent order already added, setting pass_ind = 0"))
					pass_ind = 0
				endif
			endfor
		endif
	endif
	*/
	call writeLog(build2("---->after check for DOT and child=",trim(cnvtstring(pass_ind))))
	if (pass_ind = 1)
		cnt = (cnt + 1)
		stat = alterlist(single_wip->qual,cnt)
		single_wip->qual[cnt].action_type					= uar_get_code_meaning(temp_orders->qual[d1.seq].action_type_cd)
		single_wip->qual[cnt].encntr_id						= temp_orders->qual[d1.seq].encntr_id
		if (single_wip->qual[cnt].encntr_id = 0.0)
			single_wip->qual[cnt].encntr_id					= temp_orders->qual[d1.seq].originating_encntr_id
		endif
		single_wip->qual[cnt].order_id						= temp_orders->qual[d1.seq].order_id
		single_wip->qual[cnt].template_order_id				= temp_orders->qual[d1.seq].template_order_id
		single_wip->qual[cnt].protocol_order_id				= temp_orders->qual[d1.seq].protocol_order_id
		single_wip->qual[cnt].order_mnemonic				= temp_orders->qual[d1.seq].order_mnemonic
		single_wip->qual[cnt].person_id						= temp_orders->qual[d1.seq].person_id
		single_wip->qual[cnt].requisition_format_cd			= temp_orders->qual[d1.seq].requsition_format_cd
		single_wip->qual[cnt].pathway_id					= temp_orders->qual[d1.seq].pathway_id
		single_wip->qual[cnt].type_mean						= temp_orders->qual[d1.seq].pathway_type_mean
		single_wip->qual[cnt].normal_ref_range_txt			= cnvtstring(temp_orders->qual[d1.seq].order_id)
		single_wip->qual[cnt].paper_requisition_ind			= temp_orders->qual[d1.seq].paper_requisition_ind
		for (j=1 to bc_common->requisition_cnt)
			if (temp_orders->qual[d1.seq].requsition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				single_wip->qual[cnt].requisition_script	= bc_common->requisition_qual[j].requisition_object
				single_wip->qual[cnt].requisition_title		= bc_common->requisition_qual[j].requisition_title
			endif
		endfor
		single_wip->qual[cnt].print_prsnl_id = reqinfo->updt_id
		single_wip->qual[cnt].postscript_filename 
			= concat(t_rec->print_dir,"req_ps_",trim(cnvtstring(single_wip->qual[cnt].order_id)),".ps")
		single_wip->qual[cnt].pdf_filename 		  
			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(single_wip->qual[cnt].order_id)),".pdf")
	endif
	single_wip->cnt = cnt
	call writeLog(build2("<---leaving order_id=",trim(cnvtstring(temp_orders->qual[d1.seq].order_id))))
foot report
	single_wip->cnt = cnt
	call writeLog(build2("<--leaving single req orders information (1)"))
with nocounter,nullreport


call writeLog(build2("* END   Buidling Single Order WIP (single_wip) **************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Getting Single Order Requisition Title (single_wip) *"))
call writeLog(build2("->getting single order req title information (1)"))
select into "nl:"
from
	(dummyt d1 with seq=single_wip->cnt)
	,orders o
	,act_pw_comp apc
	,pathway_comp pc
	,pathway p
	,pathway_catalog pcat
plan d1
	where single_wip->qual[d1.seq].order_id > 0.0
	and	  single_wip->qual[d1.seq].pathway_id > 0.0
	and	  single_wip->qual[d1.seq].skip_ind = 0
join o
	where o.order_id = single_wip->qual[d1.seq].order_id
join apc 
	where apc.parent_entity_id = o.order_id
join p
	where p.pathway_id = apc.pathway_id
join pc
	where pc.pathway_comp_id = apc.pathway_comp_id
join pcat
	where pcat.pathway_catalog_id = pc.pathway_catalog_id
order by
	o.order_id
head report
	call writeLog(build2("-->inside single order req title information (1)"))
head o.order_id
	call writeLog(build2("--->inside order_id=",trim(cnvtstring(o.order_id))))
	call writeLog(build2("--->inside order_mnemonic=",trim(single_wip->qual[d1.seq].order_mnemonic)))
	single_wip->qual[d1.seq].plan_desc 		= ""
	single_wip->qual[d1.seq].cycle_desc 	= p.pw_group_desc
	single_wip->qual[d1.seq].phase_desc		= pcat.description
	single_wip->qual[d1.seq].day_desc		= p.description
foot report
	call writeLog(build2("<--leaving single order req title information (1)"))
with nocounter,nullreport

call writeLog(build2("->getting missing phase description single order req title information (1.5)"))
select into "nl:"
from
	(dummyt d1 with seq=single_wip->cnt)
	,act_pw_comp apc
	,pathway_comp pc
	,pathway p
	,pathway_catalog pcat
plan d1
	where single_wip->qual[d1.seq].order_id > 0.0
	and	  single_wip->qual[d1.seq].pathway_id > 0.0
	and	  single_wip->qual[d1.seq].skip_ind = 0
	and   single_wip->qual[d1.seq].cycle_desc > " "
	and   single_wip->qual[d1.seq].day_desc > " "
join p
	where p.pathway_id = single_wip->qual[d1.seq].pathway_id
join apc 
	where apc.pathway_id = p.pathway_id
join pc
	where pc.pathway_comp_id = apc.pathway_comp_id
join pcat
	where pcat.pathway_catalog_id = pc.pathway_catalog_id
order by
	p.pathway_id
head report
	call writeLog(build2("-->getting missing phase description single order req title information (1.5)"))
	phase_desc = " "
head p.pathway_id
	phase_desc = pcat.description
detail
	call writeLog(build2("--->inside pathway_id=",trim(cnvtstring(p.pathway_id))))
	call writeLog(build2("--->inside order_mnemonic=",trim(single_wip->qual[d1.seq].order_mnemonic)))
	call writeLog(build2("--->inside order_id=",trim(cnvtstring(single_wip->qual[d1.seq].order_id))))
	call writeLog(build2("--->inside pcat.description=",trim(pcat.description)))
	if (pcat.description > " ")
		single_wip->qual[d1.seq].phase_desc		= pcat.description
	endif
	call writeLog(build2("--->inside phase_desc=",trim(single_wip->qual[d1.seq].phase_desc)))
foot p.pathway_id
	phase_desc = " "
foot report
	call writeLog(build2("<--leaving missing phase description single order req title information (1.5)"))
with nocounter,nullreport

call writeLog(build2("->building single order req title information (2)"))
select into "nl:"
from
	(dummyt d1 with seq=single_wip->cnt)
plan d1
	where single_wip->qual[d1.seq].order_id > 0.0
	and	  single_wip->qual[d1.seq].pathway_id > 0.0
	and	  single_wip->qual[d1.seq].skip_ind = 0
head report
	call writeLog(build2("-->building single order req title information (2)"))
detail
	if (single_wip->qual[d1.seq].type_mean	in("DOT"))
		single_wip->qual[d1.seq].event_title_text = concat(
															 trim(single_wip->qual[d1.seq].cycle_desc)
															," "
															,trim(single_wip->qual[d1.seq].phase_desc)
															," "
															,"("
															,trim(single_wip->qual[d1.seq].day_desc)
															,")"
															," - "
															,trim(single_wip->qual[d1.seq].requisition_title)
															)
	else
		if (		(single_wip->qual[d1.seq].cycle_desc > " ")
				and (single_wip->qual[d1.seq].cycle_desc != single_wip->qual[d1.seq].day_desc)
			)
			single_wip->qual[d1.seq].event_title_text = concat(
															trim(single_wip->qual[d1.seq].cycle_desc)
															," "
															,trim(single_wip->qual[d1.seq].day_desc)
															," - "
															,trim(single_wip->qual[d1.seq].requisition_title)
														  )
		else
		
			single_wip->qual[d1.seq].event_title_text = concat(
															trim(single_wip->qual[d1.seq].day_desc)
															," - "
															,trim(single_wip->qual[d1.seq].requisition_title)
														  )
		endif
																
	endif
foot report
	call writeLog(build2("<--building single order req title information (2)"))
with nocounter,nullreport
	
call writeLog(build2("->getting single order req title information (3)"))
select into "nl:"
	order_id = single_wip->qual[d1.seq].order_id
from
	(dummyt d1 with seq=single_wip->cnt)
plan d1
	where single_wip->qual[d1.seq].order_id > 0.0
	and	  single_wip->qual[d1.seq].pathway_id = 0.0
	and	  single_wip->qual[d1.seq].skip_ind = 0
head report
	call writeLog(build2("-->inside single order req title information (3)"))
head order_id
	call writeLog(build2("--->inside order_id=",trim(cnvtstring(order_id))))
	single_wip->qual[d1.seq].event_title_text = concat(trim(single_wip->qual[d1.seq].requisition_title))
foot order_id
	call writeLog(build2("<---leaving order_id=",trim(cnvtstring(order_id))))
foot report
	call writeLog(build2("<--leaving single order req title information (3)"))
with nocounter,nullreport


call writeLog(build2("* END Getting Single Order Requisition Title (single_wip) *"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("**************************************************************"))
call writeLog(build2("* START Getting Single Order Existing Documents (single_wip) *"))
call writeLog(build2("->getting single order req title information (1)"))
for (i=1 to single_wip->cnt)
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where 	ce.person_id = single_wip->qual[i].person_id
		and		ce.event_cd = bc_common->pdf_event_cd
		and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
		and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
		and     ce.result_status_cd in(
											 value(uar_get_code_by("MEANING",8,"AUTH"))
											,value(uar_get_code_by("MEANING",8,"MODIFIED"))
											,value(uar_get_code_by("MEANING",8,"ALTERED"))
										)
		and ( 
				(parser(concat(^ce.normal_ref_range_txt="*^,trim(cnvtstring(single_wip->qual[i].order_id)),^*"^)))
			)
	order by
		 ce.reference_nbr
		,ce.event_id
		,ce.valid_from_dt_tm desc
	head report
		call writeLog(build2("-->inside single order req title information (1)"))
	head ce.event_id		
		single_wip->qual[i].event_id 					= ce.event_id
		single_wip->qual[i].parent_event_id				= ce.parent_event_id
		single_wip->qual[i].current_event_title_text 	= ce.event_title_text
		single_wip->qual[i].current_document_status 	= substring(1,8,ce.event_title_text)
		single_wip->qual[i].current_document_dt_tm		= ce.event_end_dt_tm
		if (single_wip->qual[i].current_document_status not in("CANCELED","MODIFIED","ACTIONED"))
			single_wip->qual[i].current_document_status = "PENDING"
		endif
	foot report
		call writeLog(build2("<--leaving single order req title information (1)"))
	with nocounter,nullreport
	
	call writeLog(build2("->getting single order req blob information (2)"))
	select into "nl:"
	from 
		ce_blob_result ceb
		,clinical_event ce
	plan ce
		where ce.parent_event_id = single_wip->qual[i].parent_event_id
	join ceb
		where ceb.event_id = ce.event_id
		and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	head report
		call writeLog(build2("-->inside single order req blob information (2)"))
	detail
		single_wip->qual[i].blob_event_id = ceb.event_id
	foot report
		call writeLog(build2("<--leaving single order req blob information (2)"))
	with nocounter,nullreport
	
	;start 001
	call writeLog(build2("**Checking if a paper order and document not found*")) 
	if (
				(single_wip->qual[i].paper_requisition_ind > 0.0) 
			and (single_wip->qual[i].event_id = 0.0)
			and (single_wip->qual[i].action_type in("MODIFY"))
		)
		call writeLog(build2("-->found a missing document when paper OEF was chosen")) 
		call writeLog(build2("-->order_id=",trim(cnvtstring(single_wip->qual[i].order_id)))) 
		set single_wip->qual[i].action_type = "ORDER"
		call writeLog(build2("-->setting action type to=",single_wip->qual[i].action_type)) 
	endif
	;end 001
	
endfor
call writeLog(build2("* END  Getting Single Order Existing Documents (single_wip) *"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("*************************************************************************"))
call writeLog(build2("* START Special Processing For Single Order Requisitions (single_wip) ***"))

call writeLog(build2("->getting special order processing (1)"))
call writeLog(build2("execute bc_all_all_std_routines"))
execute bc_all_all_std_routines
for (i=1 to single_wip->cnt)
	if (single_wip->qual[i].requisition_format_cd in(value(uar_get_code_by("DISPLAY",6002,"GROUP_SCREEN_REQUISITION"))))
		call writeLog(build2("--->inside order_id=",trim(cnvtstring(single_wip->qual[i].order_id))))
		call writeLog(build2("--->inside order_mnemonic=",trim(single_wip->qual[i].order_mnemonic)))
		call writeLog(build2("--->inside sLAB_DOT_ORDER=",trim(cnvtstring(sLAB_DOT_ORDER(single_wip->qual[i].order_id)))))
		if (sLAB_DOT_ORDER(single_wip->qual[i].order_id) = 1)
          ;Day of Treatment
          set single_wip->qual[i].conversation_id = 2.00
        elseif (sLAB_DOT_ORDER(single_wip->qual[i].order_id) = 2)
          ;Single & Multi-phase
          set single_wip->qual[i].conversation_id = 3.00
        endif
	endif
	
	if (	(single_wip->qual[i].pathway_id > 0.0)
		and	((single_wip->qual[i].template_order_id > 0.0)
		or	(single_wip->qual[i].protocol_order_id > 0.0))
		)
		call writeLog(build2("----->protocol_order_id=",cnvtstring(single_wip->qual[i].protocol_order_id)))
		call writeLog(build2("----->template_order_id=",cnvtstring(single_wip->qual[i].template_order_id)))
		for (j=1 to single_wip->cnt)
			call writeLog(build2("------>comparing=",cnvtstring(single_wip->qual[j].order_id)))
			if (
					(single_wip->qual[j].order_id = single_wip->qual[i].protocol_order_id)
				 or	(single_wip->qual[j].order_id = single_wip->qual[i].template_order_id))
				call writeLog(build2("------>parent order already added, setting skip_ind = 1 for parent"))
				call writeLog(build2("------>child order use protocol_ind = 1"))
				set single_wip->qual[j].skip_ind = 1
				set single_wip->qual[i].use_protocol_ind = 1
				/*
				set single_wip->qual[j].day_desc = single_wip->qual[i].day_desc
				set single_wip->qual[j].event_title_text = concat(
															 trim(single_wip->qual[j].cycle_desc)
															," "
															,trim(single_wip->qual[j].phase_desc)
															," "
															,"("
															,trim(single_wip->qual[j].day_desc)
															,")"
															," - "
															,trim(single_wip->qual[j].requisition_title)
															)
				*/
			endif
		endfor
	endif
endfor


call writeLog(build2("* END   Special Processing For Single Order Requisitions (single_wip) ***"))
call writeLog(build2("*************************************************************************"))


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Generating Single Order Requisitions (single_wip) ***"))
for (i=1 to single_wip->cnt)
 if (single_wip->qual[i].skip_ind = 0)
	if (single_wip->qual[i].action_type in("ORDER","MODIFY"))
		call writeLog(build2("*->entering ORDER/MODIFY mode"))
		set stat = initrec(req_request)
		set req_request->person_id 			= single_wip->qual[i].person_id
		
		if (single_wip->qual[i].action_type in("MODIFY"))
			set req_request->print_prsnl_id 	= single_wip->qual[i].print_prsnl_id
		else
			set req_request->print_prsnl_id 	= 1.0
		endif
		
		set req_request->printer_name 		= single_wip->qual[i].postscript_filename
		set req_request->pdf_name	 		= single_wip->qual[i].pdf_filename
		set req_request->requisition_script	= single_wip->qual[i].requisition_script
		
		set req_request->cnt = (req_request->cnt + 1)
		set stat = alterlist(req_request->order_qual,req_request->cnt)
		set req_request->order_qual[req_request->cnt].order_id 			= single_wip->qual[i].order_id
		if (single_wip->qual[i].use_protocol_ind = 1)
			set req_request->order_qual[req_request->cnt].order_id		= single_wip->qual[i].protocol_order_id
		endif
		set req_request->order_qual[req_request->cnt].encntr_id 		= single_wip->qual[i].encntr_id
		set req_request->order_qual[req_request->cnt].conversation_id 	= single_wip->qual[i].conversation_id
		
		free record temp_request 
		set stat = copyrec(req_request,temp_request,1)			
		set req_request->execute_statement =
				build2(^execute ^,trim(req_request->requisition_script),^ with replace("REQUEST",temp_request,5) go^)  
		call writeLog(build2(req_request->execute_statement))
		call parser(req_request->execute_statement)
		
		set req_request->find_file_stat = findfile(req_request->printer_name)
	 	
	 	if (validate(req_request) and (rec_to_file = 1))
			call echojson(req_request,t_rec->log_filename_a,1)
		endif
		
	 	call writeLog(build2("->req_request->find_file_stat=",trim(cnvtstring(req_request->find_file_stat))))
		if (req_request->find_file_stat = 1)
			set dclcom = build2(^gs -o ^
									,trim(req_request->pdf_name),^ ^
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
  			call writeLog(build2("-->dclcom=",trim(dclcom)))
			call dcl(dclcom, size(trim(dclcom)), dclstat) 
			call writeLog(build2( "-->dclstat=",trim(cnvtstring(dclstat))))
			
			set stat = initrec(mmf_store_reply)
			set stat = initrec(mmf_store_request)
			set mmf_store_request->filename 			= concat(req_request->pdf_name)
			set mmf_store_request->mediatype 			= "application/pdf"
			set mmf_store_request->contenttype 			= bc_common->pdf_content_type
			set mmf_store_request->name 				= concat("Requisition ",trim(format(sysdate,";;q")))
			set mmf_store_request->personid 			= single_wip->qual[i].person_id
			set mmf_store_request->encounterid 			= single_wip->qual[i].encntr_id
	 
	 		call writeLog(build2(^--->execute mmf_store_object_with_xref^))
			execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request), replace("REPLY",mmf_store_reply)
		 	set single_wip->qual[i].identifier = mmf_store_reply->identifier
		 	
		 	if (validate(mmf_store_request) and (rec_to_file = 1))
				call echojson(mmf_store_request,t_rec->log_filename_a,1)
			endif
		 	if (validate(mmf_store_reply) and (rec_to_file = 1))
				call echojson(mmf_store_reply,t_rec->log_filename_a,1)
			endif
		 			 	
		 	if ((single_wip->qual[i].action_type = "ORDER") and (single_wip->qual[i].identifier > " "))
		 		call writeLog(build2("*-->entering ORDER specific mode"))
		 		set stat = initrec(mmf_publish_ce_request)
				set stat = initrec(mmf_publish_ce_reply)
		 		set mmf_publish_ce_request->documenttype_key 			= bc_common->pdf_display_key
				set mmf_publish_ce_request->service_dt_tm 				= cnvtdatetime(curdate, curtime3)
				set mmf_publish_ce_request->personId 					= single_wip->qual[i].person_id
				set mmf_publish_ce_request->encounterId 				= single_wip->qual[i].encntr_id
					
				set stat = alterlist(mmf_publish_ce_request->mediaObjects,1)
				set mmf_publish_ce_request->mediaObjects[1]->display 	= 'Requisition Attachment 1'
				set mmf_publish_ce_request->mediaObjects[1]->identifier = single_wip->qual[i].identifier
				set mmf_publish_ce_request->title = nullterm(single_wip->qual[i].event_title_text)	
				set mmf_publish_ce_request->noteformat = 'AS'
				set mmf_publish_ce_request->publishAsNote=1
				set mmf_publish_ce_request->debug=1
				
				set mmf_publish_ce_request->order_id = single_wip->qual[i].order_id
				set mmf_publish_ce_request->reference_nbr = substring(1,100,build(trim(single_wip->qual[i].normal_ref_range_txt)))
				set stat = alterlist(mmf_publish_ce_request->personnel,4)
				set mmf_publish_ce_request->personnel[1]->id 		= reqinfo->updt_id 
				set mmf_publish_ce_request->personnel[1]->action 	= 'PERFORM'
				set mmf_publish_ce_request->personnel[1]->status 	= 'COMPLETED'
				set mmf_publish_ce_request->personnel[2]->id 		=  reqinfo->updt_id 
				set mmf_publish_ce_request->personnel[2]->action 	= 'SIGN'
				set mmf_publish_ce_request->personnel[2]->status 	= 'COMPLETED'
				set mmf_publish_ce_request->personnel[3]->id 		=  reqinfo->updt_id
				set mmf_publish_ce_request->personnel[3]->action 	= 'VERIFY'
				set mmf_publish_ce_request->personnel[3]->status 	= 'COMPLETED'
				set mmf_publish_ce_request->personnel[4]->id 		=  reqinfo->updt_id
				set mmf_publish_ce_request->personnel[4]->action 	= 'ORDER'
				set mmf_publish_ce_request->personnel[4]->status 	= 'COMPLETED'
		
				call writeLog(build2(^--->execute bc_mmf_publish_ce^))
				execute bc_mmf_publish_ce with replace("REQUEST",mmf_publish_ce_request),replace("REPLY",mmf_publish_ce_reply)
					
				call writeLog(build2(^--->mmf_publish_ce_reply->parentEventId=^,trim(cnvtstring(mmf_publish_ce_reply->parentEventId))))
		 		set single_wip->qual[i].parent_event_id = mmf_publish_ce_reply->parentEventId
		 		if (single_wip->qual[i].parent_event_id > 0.0)
		 			update into clinical_Event 							
					set 
					  	updt_dt_tm            = cnvtdatetime(curdate, curtime3),
						updt_id               = reqinfo->updt_id,
						updt_task             = reqinfo->updt_task,
					  	updt_cnt              = 0,
					  	updt_applctx          = reqinfo->updt_applctx,
						normal_ref_range_txt	= single_wip->qual[i].normal_ref_range_txt
					where  parent_event_id = single_wip->qual[i].parent_event_id
					and view_level = 1
					commit				
		 		endif
		 	elseif ((single_wip->qual[i].action_type = "MODIFY") and (single_wip->qual[i].identifier > " "))
		 		call writeLog(build2("*-->entering MODIFY specific mode"))
		 		call writeLog(build2("*--->=current_document_status=",single_wip->qual[i].current_document_statu))
		 		if (single_wip->qual[i].current_document_status in("PENDING"))
		 			set single_wip->qual[i].new_document_status = ""
		 			set single_wip->qual[i].new_event_title_text = single_wip->qual[i].event_title_text	 			
		 			set single_wip->qual[i].new_document_dt_tm = cnvtdatetime(curdate,curtime3)
		 		elseif (single_wip->qual[i].current_document_status in("ACTIONED","MODIFIED"))
		 			set single_wip->qual[i].new_document_status = "MODIFIED:"
		 			set single_wip->qual[i].new_event_title_text = concat(	 trim(single_wip->qual[i].new_document_status)
		 																	,trim(single_wip->qual[i].event_title_text)
		 																  )
		 			set single_wip->qual[i].new_document_dt_tm = cnvtdatetime(curdate,curtime3)
		 		else ;currently the same as ACTIONED/MODIFIED
		 			set single_wip->qual[i].new_document_status = "MODIFIED:"
		 			set single_wip->qual[i].new_event_title_text = concat(	 trim(single_wip->qual[i].new_document_status)
		 																	,trim(single_wip->qual[i].event_title_text)
		 																  )
		 			set single_wip->qual[i].new_document_dt_tm = cnvtdatetime(curdate,curtime3)
		 		endif
		 		
		 		set stat = initrec(ensure_request)
		 		set stat = initrec(ensure_reply)
				set stat = alterlist(ensure_request->req, 1) 
				set ensure_request->req[1].ensure_type 			 		= 2 
				set ensure_request->req[1].version_dt_tm_ind 			= 1 
				set ensure_request->req[1].event_prsnl.event_id 		= single_wip->qual[i].event_id
				set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"MODIFY"))  
				set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
				set ensure_request->req[1].event_prsnl.action_prsnl_id 	= reqinfo->updt_id
				set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
				set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
				set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
				set ensure_request->req[1].event_prsnl.action_comment = concat("")
		 		call writeLog(build2("*--->adding MODIFY action"))
		 		execute inn_event_prsnl_batch_ensure 
									with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
				call writeLog(build2("*--->correcting order list, document title"))
				
				update into clinical_event ce 
				set 
				  ce.normal_ref_range_txt = single_wip->qual[i].normal_ref_range_txt
				 ,ce.event_end_dt_tm = cnvtdatetime(single_wip->qual[i].new_document_dt_tm)
				 ,ce.event_title_text = trim(single_wip->qual[i].new_event_title_text)
				where ce.event_id = single_wip->qual[i].event_id
				commit
				call writeLog(build2("*--->updating blob reference"))
		 		update into ce_blob_result 
				set blob_handle 		= single_wip->qual[i].identifier,
				  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
				  updt_id               = reqinfo->updt_id,
			      updt_task             = reqinfo->updt_task,
				  updt_cnt              = (updt_cnt +1),
				  updt_applctx          = reqinfo->updt_applctx
				where event_id = single_wip->qual[i].blob_event_id
				and   valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
				commit
		 	endif
  		endif
  	elseif (single_wip->qual[i].action_type in("CANCEL"))
  		call writeLog(build2("*->entering CANCEL mode"))
	endif
 endif
endfor
call writeLog(build2("* END   Generating Single Order Requisitions (single_wip) ***"))
call writeLog(build2("*************************************************************"))

call echorecord(single_wip)

#exit_script

if (validate(bc_common) and (rec_to_file = 1))
	call echojson(bc_common,t_rec->log_filename_a,1)
endif

if (validate(t_rec) and (rec_to_file = 1))
	call echojson(t_rec,t_rec->log_filename_a,1)
endif

if (validate(single_wip) and (rec_to_file = 1))
	call echojson(single_wip,t_rec->log_filename_a,1)
endif

call writeLog(build2("* END SCRIPT"))
call exitScript(null)

#exit_script_no_log

end 
go


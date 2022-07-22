/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_cardiology_results_endorse.prg
	Object name:		cov_cardiology_results_endorse
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	09/12/2020  Chad Cummings			Initial Release
001     10/22/202   Chad Cummings			added valid date and times to update
002     11/30/2020  Chad Cummings			updated list of encounter types and restricted for current encounter
003     05/03/2021  Chad Cummings			expanded order search to a year
******************************************************************************/

drop program cov_cardiology_results_endorse:dba go
create program cov_cardiology_results_endorse:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)



record t_rec
(	
	1 cnt					= i4
	1 beg_orig_order_dt_tm	= dq8
	1 beg_dt_tm				= dq8
	1 end_dt_tm     		= dq8
	1 output_var			= vc
	1 output_filename 		= vc
	1 prompt_outdev 		= vc
	1 dminfo
	 2 info_domain		= vc
	 2 info_name		= vc
	 2 info_date		= dq8
	1 catalog_cnt			= i2
	1 catalog_qual[*]
	 2 catalog_cd			= f8
	 2 order_mnemonic		= vc
	1 order_cnt				= i2
	1 order_qual[*]
	 2 order_id				= f8
	 2 encntr_id			= f8
	 2 loc_facility_cd		= f8
	 2 encntr_type_cd		= f8
	 2 orig_encntr_type_cd	= f8
	 2 alias				= vc
	 2 orig_fin				= vc
	 2 person_id			= f8
	 2 name_full_formatted  = vc
	 2 order_status_cd		= f8
	 2 orig_order_dt_tm		= dq8
	 2 orig_encntr_id		= f8
	 2 outside_location_ind	= i2
	 2 updt_dt_tm			= dq8
	 2 catalog_cd			= f8
	 2 activity_type_cd		= f8
	 2 catalog_type_cd		= f8
	 2 ordering_provider_id	= f8
	 2 ordering_provider	= vc
	 2 order_completed_event= i2
	 2 order_complete_ce_id	= f8 ;001
	 2 event_id				= f8
	 2 event_end_dt_tm		= dq8
	 2 document_title		= vc
	 2 performing_provider_id	= f8
	 2 preforming_provider		= vc
	 2 perform_dt_tm			= dq8
	 2 ordering_endorse_ind	= i2
	 2 endorse_list			= vc
	 2 ensure_reply			= vc
	 2 procesed_ind			= i2
) with protect

set t_rec->prompt_outdev = $OUTDEV

declare parser_param = vc with noconstant("")

set t_rec->output_filename = concat(trim(cnvtlower(program_log->curprog)),"_",trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".csv")
;set t_rec->beg_orig_order_dt_tm = cnvtdatetime("08-OCT-2020 00:00:00")
set t_rec->beg_orig_order_dt_tm = datetimefind(cnvtlookbehind("12,M",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
call addEmailLog("chad.cummings@covhlth.com")	

if (program_log->run_from_ops = 0)
	if (t_rec->prompt_outdev = "OPS")
		set program_log->run_from_ops = 1
		set program_log->display_on_exit = 0
	endif
endif

if (program_log->run_from_ops = 0)
	set t_rec->output_var = t_rec->prompt_outdev
else	
	set t_rec->output_var = concat("cclscratch:",trim(t_rec->output_filename))
endif

set program_log->email.subject = concat(
											 program_log->curdomain
											," "
											,trim(check(cnvtlower(program_log->curprog)))
											," "
											,format(sysdate,"yyyy-mm-dd hh:mm:ss;;d")
										)

if (program_log->run_from_ops = 1)
	set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
	set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
	set t_rec->dminfo.info_date		= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
	
	if (t_rec->dminfo.info_date = 0.0)
		call writeLog(build2("->No start date and time found, setting to yesterday"))
		;set t_rec->beg_dt_tm = cnvtdatetime("08-OCT-2020 00:00:00")
		set t_rec->beg_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	else
		set t_rec->beg_dt_tm = t_rec->dminfo.info_date
	endif
	set t_rec->end_dt_tm = cnvtdatetime(curdate,curtime3)
else
	;set t_rec->beg_dt_tm = datetimefind(cnvtlookbehind("7,D",cnvtdatetime("08-OCT-2020 00:00:00")), 'D', 'B', 'B')	
	set t_rec->beg_dt_tm = cnvtdatetime("08-OCT-2020 00:00:00")
	set t_rec->beg_dt_tm = datetimefind(cnvtlookbehind("5,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif


call writeLog(build2("-->t_rec->beg_orig_order_dt_tm=",format(t_rec->beg_orig_order_dt_tm,";;q")))
call writeLog(build2("-->t_rec->beg_dt_tm=",format(t_rec->beg_dt_tm,";;q")))
call writeLog(build2("-->t_rec->end_dt_tm=",format(t_rec->end_dt_tm,";;q")))


declare ordering_provider_id = f8 with noconstant(0.0)
declare event_id = f8 with noconstant(0.0)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Catalog Items ******************************"))
select into "nl:"
from
	 order_catalog oc
	,code_value cv
plan cv
	where cv.code_set = 200
	and   cv.active_ind = 1
	and   cv.display in(
							 "NM*"
							,"CA*"
							,"US*"
						)
	and   cv.display not in(
								"CA Master TEE Echo+"
								,"CA Stress MPS Supervision Only"
								,"CA Cath Lab Case"
								,"US Prostate Transrectal"
								,"US Retroperitoneal Complete"
								,"US Pelvis Limited"
							)
join oc
	where oc.catalog_cd = cv.code_value
	and   oc.catalog_type_cd in(value(uar_get_code_by("MEANING",6000,"RADIOLOGY")))
order by
	 oc.primary_mnemonic
	,oc.catalog_cd
head report
	call writeLog(build2("<-Entering Query"))
head oc.catalog_cd
	t_rec->catalog_cnt = (t_rec->catalog_cnt + 1)
	stat = alterlist(t_rec->catalog_qual,t_rec->catalog_cnt)
	t_rec->catalog_qual[t_rec->catalog_cnt].catalog_cd		= oc.catalog_cd
	t_rec->catalog_qual[t_rec->catalog_cnt].order_mnemonic  = oc.primary_mnemonic
foot report
	call writeLog(build2("->Leaving Query"))
with nocounter, nullreport
;  CA Stress MPS Supervision Only need to exclude 
call writeLog(build2("* END   Finding Catalog Items ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Completed Orders ***************************"))
select into "nl:"
from
	 orders o
	,order_action oa
	,prsnl p1
	;002 ,encounter e
	,encounter e1 ;002
	,encounter e2 ;002
plan o
	where o.updt_dt_tm between cnvtdatetime(t_rec->beg_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and   o.order_status_cd in(
									value(uar_get_code_by("MEANING",6004,"COMPLETED"))
								)
	and   o.order_id > 0.0
	and   o.orig_order_dt_tm > cnvtdatetime(t_rec->beg_orig_order_dt_tm)
	and   expand(i,1,t_rec->catalog_cnt,o.catalog_cd,t_rec->catalog_qual[i].catalog_cd)
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd in(
									value(uar_get_code_by("MEANING",6003,"ORDER"))
								)
join p1
	where p1.person_id = oa.order_provider_id
/*start 002
join e
	where ((e.encntr_id = o.originating_encntr_id) or (e.encntr_id = o.encntr_id))
	
	and   e.encntr_type_cd in(
								 value(uar_get_code_by(^DISPLAY^,71,^Cardiac Diagnostics^))
								,value(uar_get_code_by(^DISPLAY^,71,^Cheyenne Outpatient Clinic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Clinic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Contract Film Read Only^))
								,value(uar_get_code_by(^DISPLAY^,71,^Diagnostic Center Outpatient^))
								,value(uar_get_code_by(^DISPLAY^,71,^Multi-Day OP Diagnostic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Non-Patient Lab Specimen^))
								,value(uar_get_code_by(^DISPLAY^,71,^Outpatient^))
								,value(uar_get_code_by(^DISPLAY^,71,^Outpatient in a Bed^))
								,value(uar_get_code_by(^DISPLAY^,71,^Phone Message^))
								,value(uar_get_code_by(^DISPLAY^,71,^Preadmit^))
								,value(uar_get_code_by(^DISPLAY^,71,^Quick Lab Registration^))
								,value(uar_get_code_by(^DISPLAY^,71,^Recurring^))
								,value(uar_get_code_by(^DISPLAY^,71,^Results Only^))
								,value(uar_get_code_by(^DISPLAY^,71,^Sleep Lab Recurring^))
							)
 end 002 */
/*start 002*/
join e1
	where e1.encntr_id = o.originating_encntr_id
	
	and   e1.encntr_type_cd in(
								 value(uar_get_code_by(^DISPLAY^,71,^Clinic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Phone Message^))
							) 
join e2
	where e2.encntr_id = o.encntr_id
	
	and   e2.encntr_type_cd in(
								 value(uar_get_code_by(^DISPLAY^,71,^Cardiac Diagnostics^))
								,value(uar_get_code_by(^DISPLAY^,71,^Cheyenne Outpatient Clinic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Clinic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Contract Film Read Only^))
								,value(uar_get_code_by(^DISPLAY^,71,^Diagnostic Center Outpatient^))
								,value(uar_get_code_by(^DISPLAY^,71,^Multi-Day OP Diagnostic^))
								,value(uar_get_code_by(^DISPLAY^,71,^Non-Patient Lab Specimen^))
								,value(uar_get_code_by(^DISPLAY^,71,^Outpatient^))
								,value(uar_get_code_by(^DISPLAY^,71,^Outpatient in a Bed^))
								,value(uar_get_code_by(^DISPLAY^,71,^Phone Message^))
								,value(uar_get_code_by(^DISPLAY^,71,^Preadmit^))
								,value(uar_get_code_by(^DISPLAY^,71,^Quick Lab Registration^))
								,value(uar_get_code_by(^DISPLAY^,71,^Recurring^))
								,value(uar_get_code_by(^DISPLAY^,71,^Results Only^))
								,value(uar_get_code_by(^DISPLAY^,71,^Sleep Lab Recurring^))
							) 
/*end 002*/
order by
	o.order_id
head report
	call writeLog(build2("<-Entering Query"))
head o.order_id
	t_rec->order_cnt = (t_rec->order_cnt + 1)
	stat = alterlist(t_rec->order_qual,t_rec->order_cnt)
	call writeLog(build2("-->adding order cnt (",trim(cnvtstring(t_rec->order_cnt)),") order_id=",trim(cnvtstring(o.order_id))))
	t_rec->order_qual[t_rec->order_cnt].order_id 				= o.order_id
	t_rec->order_qual[t_rec->order_cnt].catalog_cd 				= o.catalog_cd
	t_rec->order_qual[t_rec->order_cnt].order_id 				= o.order_id
	t_rec->order_qual[t_rec->order_cnt].encntr_id 				= o.encntr_id
	t_rec->order_qual[t_rec->order_cnt].orig_encntr_id			= o.originating_encntr_id
	t_rec->order_qual[t_rec->order_cnt].order_status_cd 		= o.order_status_cd
	t_rec->order_qual[t_rec->order_cnt].person_id				= o.person_id
	t_rec->order_qual[t_rec->order_cnt].orig_order_dt_tm		= o.orig_order_dt_tm
	t_rec->order_qual[t_rec->order_cnt].updt_dt_tm				= o.updt_dt_tm
	t_rec->order_qual[t_rec->order_cnt].ordering_provider_id	= oa.order_provider_id
	t_rec->order_qual[t_rec->order_cnt].ordering_provider		= p1.name_full_formatted
	t_rec->order_qual[t_rec->order_cnt].activity_type_cd		= o.activity_type_cd
	t_rec->order_qual[t_rec->order_cnt].catalog_type_cd			= o.catalog_type_cd
foot o.order_id
	if (t_rec->order_qual[t_rec->order_cnt].orig_encntr_id = 0.0)
		t_rec->order_qual[t_rec->order_cnt].orig_encntr_id = t_rec->order_qual[t_rec->order_cnt].encntr_id
	endif
foot report
	call writeLog(build2("->Leaving Query"))
with nocounter, nullreport, expand = 1

if (t_rec->order_cnt <= 0)
	go to exit_script
endif

call writeLog(build2("* END   Finding Completed Orders ***************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START FIN ************************************************"))
select into "nl:"
from
	 encntr_alias ea
	,person p
	,encounter e
	,(dummyt d1 with seq=t_rec->order_cnt)
plan d1
join e
	where e.encntr_id = t_rec->order_qual[d1.seq].orig_encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
head report
	call writeLog(build2("<-Entering Query"))
detail
	call writeLog(build2("-->found FIN=",trim(ea.alias)," for encntr_id=",trim(cnvtstring(ea.encntr_id))))
	t_rec->order_qual[d1.seq].orig_fin			  	= cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->order_qual[d1.seq].name_full_formatted 	= p.name_full_formatted
	t_rec->order_qual[d1.seq].loc_facility_cd 		= e.loc_facility_cd
	t_rec->order_qual[d1.seq].orig_encntr_type_cd	= e.encntr_type_cd
foot report
	call writeLog(build2("->Leaving Query"))
with nocounter, nullreport

select into "nl:"
from
	 encntr_alias ea
	,person p
	,encounter e
	,(dummyt d1 with seq=t_rec->order_cnt)
plan d1
join e
	where e.encntr_id = t_rec->order_qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
head report
	call writeLog(build2("<-Entering Query"))
detail
	call writeLog(build2("-->found FIN=",trim(ea.alias)," for encntr_id=",trim(cnvtstring(ea.encntr_id))))
	t_rec->order_qual[d1.seq].alias				  	= cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->order_qual[d1.seq].encntr_type_cd		= e.encntr_type_cd
foot report
	call writeLog(build2("->Leaving Query"))
with nocounter, nullreport

call writeLog(build2("* END   FIN ************************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Outside Locations **************************"))
select into "nl:"
from
	 order_detail od
	,orders o
	,order_entry_fields oef
	,oe_format_fields off
	,(dummyt d1 with seq=t_rec->order_cnt)
plan d1
join o
	where o.order_id  = t_rec->order_qual[d1.seq].order_id
join od
	where od.order_id = o.order_id
join oef
	where oef.oe_field_id = od.oe_field_id
	and   oef.description = "Scheduling Location"
join off
	where off.oe_field_id = od.oe_field_id
	and   off.oe_format_id = o.oe_format_id
head report
	call writeLog(build2("<-Entering Query"))
detail
	call writeLog(build2("-->checking order_id=",trim(cnvtstring(o.order_id))))
	if (od.oe_field_display_value = "Outside Location")
		t_rec->order_qual[d1.seq].outside_location_ind = 1
	endif
foot report
	call writeLog(build2("->Leaving Query"))
with nocounter, nullreport
call writeLog(build2("* END    Finding Outside Locations *************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Endorsements *******************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Clinical Events ****************************"))
select into "nl:"
from
	 clinical_event ce
	,(dummyt d1 with seq=t_rec->order_cnt)
plan d1
join ce
	where ce.order_id  = t_rec->order_qual[d1.seq].order_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.view_level = 1
head report
	call writeLog(build2("<-Entering Query"))
detail
	call writeLog(build2("-->adding event_id=",trim(cnvtstring(ce.event_id))," for order_id=",trim(cnvtstring(ce.order_id))))
	t_rec->order_qual[d1.seq].event_id = ce.event_id
	t_rec->order_qual[d1.seq].event_end_dt_tm = ce.event_end_dt_tm
	t_rec->order_qual[d1.seq].performing_provider_id = ce.performed_prsnl_id
	t_rec->order_qual[d1.seq].perform_dt_tm = ce.performed_dt_tm
	t_rec->order_qual[d1.seq].document_title = ce.event_tag
foot report
	call writeLog(build2("->Leaving Query"))
with nocounter, nullreport
call writeLog(build2("* END   Finding Clinical Events ****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Endorsements *******************************"))

select into "nl:"
	 cep.action_dt_tm
	,ce.event_id
	,order_id = t_rec->order_qual[d1.seq].order_id
from
	 clinical_event ce
	,ce_event_prsnl cep
	,prsnl p1
	,(dummyt d1 with seq=t_rec->order_cnt)
plan d1
join cep
	where cep.event_id =  t_rec->order_qual[d1.seq].event_id
	and   cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   cep.valid_from_dt_tm <= cnvtdatetime(curdate, curtime3)
	and   cep.action_type_cd in(
									value(uar_get_code_by("MEANING",21,"ENDORSE"))
								)
join p1
	where p1.person_id = cep.action_prsnl_id
join ce
	where ce.event_id = cep.event_id
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate, curtime3)
order by
	 cep.action_dt_tm
	,ce.event_id
	,order_id
head report
	call writeLog(build2("<-Entering Query"))
	 ordering_endorse_ind = 0
	 doc_cnt = 0
head order_id
	ordering_endorse_ind = 0
	doc_cnt = 0
head ce.event_id
	call writeLog(build2("-->Looking at document=",trim(ce.event_title_text)))
	doc_cnt = (doc_cnt + 1)
detail
	if (cep.action_prsnl_id = t_rec->order_qual[d1.seq].ordering_provider_id)
		ordering_endorse_ind = 1
	endif
	if (doc_cnt > 1)
		t_rec->order_qual[d1.seq].endorse_list = concat(t_rec->order_qual[d1.seq].endorse_list,";")
	endif
	t_rec->order_qual[d1.seq].endorse_list = concat(t_rec->order_qual[d1.seq].endorse_list,
													concat(
															trim(p1.name_full_formatted), " [",
															format(cep.action_dt_tm,"dd-mmm-yyyy hh:mm;;d")
															,"]")
													)
foot ce.event_id
	stat = 0
foot order_id
	t_rec->order_qual[d1.seq].ordering_endorse_ind = ordering_endorse_ind
foot report
	call writeLog(build2("->Leaving Query"))
with format(date,";;q"),uar_code(d)


select into "nl:"
	 cep.action_dt_tm
	,ce.event_id
	,order_id = t_rec->order_qual[d1.seq].order_id
from
	 clinical_event ce
	,ce_event_prsnl cep
	,prsnl p1
	,(dummyt d1 with seq=t_rec->order_cnt)
plan d1
join cep
	where cep.event_id =  t_rec->order_qual[d1.seq].event_id
	and   cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   cep.valid_from_dt_tm <= cnvtdatetime(curdate, curtime3)
	and   cep.action_type_cd in(
									value(uar_get_code_by("MEANING",21,"ORDER"))
								)
	and   cep.action_status_cd in(
									value(uar_get_code_by("MEANING",103,"COMPLETED"))
								)
join p1
	where p1.person_id = cep.action_prsnl_id
	and   p1.person_id = t_rec->order_qual[d1.seq].ordering_provider_id
join ce
	where ce.event_id = cep.event_id
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate, curtime3)
order by
	 cep.action_dt_tm
	,ce.event_id
	,order_id
head report
	call writeLog(build2("<-Entering Query"))
	 order_complete_ind = 0
head order_id
	order_complete_ind = 0
head ce.event_id
	order_complete_ind = 1
foot ce.event_id
	stat = 0
foot order_id
	t_rec->order_qual[d1.seq].order_completed_event = order_complete_ind
	if (ce.view_level = 1)
		t_rec->order_qual[d1.seq].order_complete_ce_id = ce.clinical_event_id
	endif
foot report
	call writeLog(build2("->Leaving Query"))
with format(date,";;q"),uar_code(d)

call writeLog(build2("* END   Finding Endorsements *******************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Processing Results *********************************"))

if (program_log->run_from_ops = 1)
for (i=1 to t_rec->order_cnt)
	if (
					(t_rec->order_qual[i].ordering_provider_id > 0.0)
			and		(t_rec->order_qual[i].event_id > 0.0)
			and		(t_rec->order_qual[i].order_complete_ce_id > 0.0)
			and		(t_rec->order_qual[i].ordering_endorse_ind = 0)
			and		(t_rec->order_qual[i].outside_location_ind = 0)
		)
			call writeLog(build2("* -->Updating event_id=",cnvtstring(t_rec->order_qual[i].event_id)))
			call writeLog(build2("* -->Updating order_complete_ce_id=",cnvtstring(t_rec->order_qual[i].order_complete_ce_id)))

			update into clinical_event 
			set	 performed_prsnl_id = 1
				,verified_prsnl_id = 1 
				,updt_id = 1
				,updt_cnt = (updt_cnt + 1)
				,updt_dt_tm = cnvtdatetime(curdate,curtime3)
			where clinical_event_id = value(t_rec->order_qual[i].order_complete_ce_id)
			and valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
			and valid_from_dt_tm <= cnvtdatetime(curdate, curtime3)
			commit
		
		    set parser_param = " "
		    set parser_param = build(
										^execute cov_add_ce_event_action ^
										,^ "MINE"^
										,^,^
										,value(t_rec->order_qual[i].event_id)
										,^,^
										,value(t_rec->order_qual[i].ordering_provider_id)
										,^,^
										,^"ORDER","COMPLETED" go^
									)
			
			if (parser_param > " ")
				call writeLog(build2("->parser_param=",parser_param))
				call parser(parser_param)
				set t_rec->order_qual[i].procesed_ind = 1
			endif
		
		endif
endfor
endif

call writeLog(build2("* END   Processing Results *********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Create Output **************************************"))

select 
	if (program_log->run_from_ops = 1)
		with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
	else
		with nocounter,separator = " ", format,maxcol=32000
	endif
into value(t_rec->output_var)
	 facility 				= uar_get_code_display(t_rec->order_qual[d1.seq].loc_facility_cd)
	,originating_type		= uar_get_code_display(t_rec->order_qual[d1.seq].orig_encntr_type_cd)
	,originating_encounter	= substring(1,20,t_rec->order_qual[d1.seq].orig_fin)
	,encntr_type			= uar_get_code_display(t_rec->order_qual[d1.seq].encntr_type_cd)
	,activated_encounter	= substring(1,20,t_rec->order_qual[d1.seq].alias)
	,name_full_formatted   	= substring(1,70,t_rec->order_qual[d1.seq].name_full_formatted)
	,orderable       		= uar_get_code_display(t_rec->order_qual[d1.seq].catalog_cd)
	,order_date_time		= substring(1,20,format(t_rec->order_qual[d1.seq].orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;q"))
	,ordering_provider		= substring(1,70,t_rec->order_qual[d1.seq].ordering_provider)
	,document_title			= substring(1,70,t_rec->order_qual[d1.seq].document_title)
	,endorse_list			= substring(1,200,t_rec->order_qual[d1.seq].endorse_list)
	,document_date_time		= substring(1,20,format(t_rec->order_qual[d1.seq].event_end_dt_tm,"dd-mmm-yyyy hh:mm;;q"))
	,ordering_endorsed_ind	= if (t_rec->order_qual[d1.seq].ordering_endorse_ind = 1) "Yes" else "No" endif
	,order_completed_event	= if (t_rec->order_qual[d1.seq].order_completed_event = 1) "Yes" else "No" endif
	,outside_location		= if (t_rec->order_qual[d1.seq].outside_location_ind = 1) "Yes" else "No" endif
	,processed				= if (t_rec->order_qual[d1.seq].procesed_ind = 1) "Yes" else "No" endif
	,ensure_reply			= substring(1,2,t_rec->order_qual[d1.seq].ensure_reply)
	,order_id      			= t_rec->order_qual[d1.seq].order_id
	,event_id      			= t_rec->order_qual[d1.seq].event_id
	,order_complete_ce_id	= t_rec->order_qual[d1.seq].order_complete_ce_id
	,encntr_id     			= t_rec->order_qual[d1.seq].encntr_id
	,person_id     			= t_rec->order_qual[d1.seq].person_id
	,ordering_provider_id	= t_rec->order_qual[d1.seq].ordering_provider_id
from
	(dummyt d1 with seq=t_rec->order_cnt)	
plan d1
order by
	 facility
	,ordering_provider
	,originating_encounter
with nocounter,separator = " ", format,maxcol=32000

if (program_log->run_from_ops = 1)
	call writeLog(build2("->copying file to astream"))
	call writeLog(build2("->t_rec->output_var=",t_rec->output_var))
	call writeLog(build2("-->replaced t_rec->output_var=",trim(replace(t_rec->output_var,"cclscratch:",""))))
	call addAttachment(program_log->files.file_path, replace(t_rec->output_var,"cclscratch:",""))
	execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_var,"cclscratch:",""),"","CP"	
endif

set reply->status_data.status = "S"

call writeLog(build2("* END   Create Output **************************************"))
call writeLog(build2("************************************************************"))

#exit_script

if (reply->status_data.status in("Z","S"))
	if (program_log->run_from_ops = 1)
		call writeLog(build2("* START Set Date Range ************************************"))
		call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->end_dt_tm)
		call writeLog(build2("* END Set Date Range ************************************v1"))
	endif
endif
if (reply->status_data.status = "F")
	set program_log->display_on_exit = 1
	call writeLog(build2(cnvtrectojson(t_rec)))
	call writeLog(build2(cnvtrectojson(reply)))
endif
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go

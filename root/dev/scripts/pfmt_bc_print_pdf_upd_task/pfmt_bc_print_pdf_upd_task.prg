/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   pfmt_bc_print_pdf_upd_task.prg
  Object name:        pfmt_bc_print_pdf_upd_task
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   10/01/2019  Chad Cummings			Initial Release
******************************************************************************/
drop program pfmt_bc_print_pdf_upd_task:dba go
create program pfmt_bc_print_pdf_upd_task:dba
call echo(build("loading script:",curprog))

if ((requestin->requests.provider_prsnl_id = 0.0) or (requestin->requests.request_prsnl_id = 0.0))
	go to exit_script
endif

set nologvar = 0	;do not create log = 1		, create log = 0
set debug_ind = 2	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000

%i cust_script:bc_common_routines.inc

/*  Commenting out for POC Purposes.
	Values are hard coded until custom code set is approved and built	;000
	
call bc_custom_code_set(0)
call bc_log_level(0)
call bc_check_validation(0)
call bc_pdf_event_code(0)
call bc_pdf_content_type(0)
call bc_get_requisitions(0)
call bc_get_task_definition(0)

if (bc_common->log_level >= 1)
	if (validate(requestin))
		call writeLog(build2(cnvtrectojson(requestin)))
	endif
endif


*/	;000
set bc_common->log_level = 2
set bc_common->log_level = 2								;000
set bc_common->pdf_event_cd 		= 2595426677.00			;000
set bc_common->reference_task_id 	= 2595731141.00			;000
set bc_common->pdf_content_type		= "PATIENT_PROVIDED"	;000

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section 1 ************************************"))

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

free set t_rec
record t_rec
(
	1 cnt				= i4
	1 event_id			= f8
	1 template_updt_ind	= i2
	1 template_id		= f8
	1 sysdate_string	= vc
	1 log_filename_a	= vc
	1 new_title			= vc
	1 updt_ind			= i2
	1 cancel_ind		= i2
	1 request_prsnl_id  = f8
	1 provider_prsnl_id = f8
	1 task_id   		= f8
	1 report_request_id = f8
)
set t_rec->sysdate_string 			= format(sysdate,"yyyymmddhhmmss;;d")
set t_rec->log_filename_a 			= concat ("cclscratch:requestin_1370009_" ,t_rec->sysdate_string ,".dat" )
set t_rec->report_request_id 		= requestin->reply.requests.report_Request_id

call writeLog(build2("->report_request_id= ",trim(cnvtstring(t_Rec->report_request_id))))

;if (validate(requestin))
		call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
		call echojson(requestin,t_rec->log_filename_a)
		;call echorecord(requestin)
;endif
call writeLog(build2("* START Finding Event v3 ******************************************"))
call writeLog(build2(cnvtrectojson(requestin)))
call writeLog(build2("requestin->requests.events[1].event_id=",requestin->requests.events[1].event_id))
call writeLog(build2("requestin->requests.template_id=",requestin->requests.template_id))
;call writeLog(build2("requestin->events[1].event_id=",requestin->events[1].event_id))

set t_rec->event_id 			= requestin->requests.events[1].event_id
set t_rec->provider_prsnl_id 	= requestin->requests.provider_prsnl_id
set t_rec->request_prsnl_id 	= requestin->requests.request_prsnl_id

if (t_rec->request_prsnl_id = 0.0)
	go to exit_script
endif

set t_rec->template_id =  2550819527.00

select into "nl:"
from
	clinical_event ce
plan ce
	where ce.event_id = t_rec->event_id
detail
	if ((ce.event_cd = bc_common->pdf_event_cd) and (requestin->requests.template_id != t_rec->template_id))
		t_rec->template_updt_ind = 1
	endif
with nocounter

call writeLog(build2("t_rec->template_updt_ind=",trim(cnvtstring(t_rec->template_updt_ind))))

if (t_rec->template_updt_ind = 1)
	call writeLog(build2("updating=",trim(cnvtstring(t_rec->report_request_id))))
 	update into cr_report_Request set template_id = t_rec->template_id,updt_id=12345 where report_request_id= t_Rec->report_request_id
 commit 
endif

select into "nl:"
from
	clinical_event ce
plan ce
	where ce.event_id = t_rec->event_id
	and   ce.event_cd = bc_common->pdf_event_cd
detail
	bc_common->person_id = ce.person_id
	bc_common->encntr_id = ce.encntr_id
	call writeLog(build2("-->Inside Detail Section"))
	call writeLog(build2("--->",trim(ce.event_title_text)))
	if (ce.event_title_text != "ACTIONED:*")
		t_rec->updt_ind = 1
	endif
	if (substring(1,9,ce.event_title_text) in("CANCELED:"))
		t_rec->updt_ind = 0
		t_rec->cancel_ind = 1
	endif
	
	call writeLog(build2("--->checking:",trim(substring(1,9,ce.event_title_text))))
	if (substring(1,9,ce.event_title_text) in("MODIFIED:"))
		t_rec->new_title = trim(substring(10,200,ce.event_title_text))
	else
		t_rec->new_title = trim(ce.event_title_text)
	endif
	call writeLog(build2("--->after check t_rec->new_title",trim(t_rec->new_title)))
	
	t_rec->new_title = build2("ACTIONED:",trim(t_rec->new_title))
	
	call writeLog(build2("--->after concat t_rec->new_title",trim(t_rec->new_title)))
	call writeLog(build2("-->",uar_get_code_display(ce.event_cd)))
	call writeLog(build2("<--Exit Detail Section"))
with nocounter

select into "nl:"
from 
	task_activity ta
plan ta
	where ta.event_id = t_rec->event_id
	and   ta.task_id > 0.0
	and   ta.task_status_cd = value(uar_get_code_by("MEANING",79,"PENDING"))
order by
	ta.active_status_dt_tm
head report
	cnt = 0
detail
	t_rec->task_id = ta.task_id
with nocounter


if (bc_common->person_id = 0.0)
	set bc_common->person_id = requestin->requests.PERSON_ID
	set bc_common->encntr_id = requestin->requests.encntr_id
endif

call writeLog(build2("bc_common->person_id=",trim(cnvtstring(bc_common->person_id))))
call writeLog(build2("bc_common->encntr_id=",trim(cnvtstring(bc_common->encntr_id))))

call writeLog(build2("*-->Updating Event ***************************************"))
call writeLog(build2("t_rec->event_id=",trim(cnvtstring(t_rec->event_id))))
if ((t_rec->event_id > 0.0) and (t_rec->updt_ind = 1))
	update into clinical_event ce 
	set ce.event_title_text = t_rec->new_title, 
		result_status_cd = value(uar_get_code_by("MEANING",8,"AUTH"))
	where ce.event_id = t_rec->event_id
	commit 
endif

call writeLog(build2("*-->Updating Task ***************************************"))
call writeLog(build2("t_rec->task_id=",trim(cnvtstring(t_rec->task_id))))

if (t_rec->task_id > 0.0)
free record dcp_request
record dcp_request
(
   1 task_list [*]
      2  task_id = f8
      2  person_id = f8
      2  catalog_type_cd = f8
      2  order_id = f8
      2  encntr_id = f8
      2  reference_task_id = f8
      2  task_type_cd = f8
      2  task_class_cd = f8
      2  task_status_cd = f8
      2 prev_task_status_cd = f8
      2 task_tz = i4
      2  task_dt_tm = dq8
      2  updt_cnt = i4
      2  event_id = f8
      2  task_activity_cd = f8
      2  catalog_cd = f8
      2  task_status_reason_cd = f8
      2  reschedule_ind = i2
      2  reschedule_reason_cd = f8
      2  med_order_type_cd = f8
      2  task_priority_cd = f8
      2  charted_by_agent_cd = f8
      2  charted_by_agent_identifier = vc
      2  charting_context_reference = vc
      2  scheduled_dt_tm = dq8
      2  result_set_id = f8
) 

select into "nl:"
 from task_activity ta 
 where ta.task_id = t_rec->task_id
head report 
	cnt = 0
detail
cnt = (cnt + 1)
stat = alterlist (dcp_request->task_list, 1) 
dcp_request->task_list[cnt].task_id = ta.task_id
dcp_request->task_list[cnt]->person_id 			= ta.person_id 
dcp_request->task_list[cnt]->catalog_type_cd 		= ta.catalog_type_cd 
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
dcp_request->task_list[cnt].task_status_cd = value(uar_get_code_by("MEANING",79,"COMPLETE"))
with nocounter

for (i=1 to size(dcp_request->task_list,5))
insert into task_action tac
set
  tac.seq = 1,
  tac.task_id               = dcp_request->task_list[i]->task_id,
  tac.task_action_seq       = seq(carenet_seq,nextval),
  tac.task_status_cd        = dcp_request->task_list[i]->prev_task_status_cd,
  tac.task_dt_tm            = cnvtdatetime (dcp_request->task_list[i]->task_dt_tm),
  tac.task_tz               = dcp_request->task_list[i]->task_tz,

  tac.task_status_reason_cd = dcp_request->task_list[i]->task_status_reason_cd,
  tac.reschedule_reason_cd  = dcp_request->task_list[i]->reschedule_reason_cd,
  tac.scheduled_dt_tm       = cnvtdatetime(dcp_request->task_list[i]->scheduled_dt_tm),
  tac.updt_dt_tm            = cnvtdatetime(curdate, curtime3),
  tac.updt_id               = reqinfo->updt_id,
  tac.updt_task             = reqinfo->updt_task,
  tac.updt_cnt              = 0,
  tac.updt_applctx          = reqinfo->updt_applctx
with nocounter
commit  

update into task_activity
	set updt_dt_tm = cnvtdatetime(curdate,curtime3)  
	where task_id               = dcp_request->task_list[i]->task_id
with nocounter
commit
endfor

if ((t_rec->task_id > 0.0) and (t_rec->updt_ind = 1))
	update into task_activity ta
	set ta.task_status_cd =         419.00 
		,ta.msg_subject = t_rec->new_title
	where ta.task_id = t_rec->task_id
	commit 
endif
endif


call writeLog(build2("* END   Finding Event *******************************************"))


call writeLog(build2("* START Adding Action ************************************"))

free record ensure_request 
free record ensure_reply 
 
record ensure_request (
   1 req                   [*]
      2 ensure_type           = i2
      2 version_dt_tm         = dq8
      2 version_dt_tm_ind     = i2
      2 event_prsnl
         3 event_prsnl_id        = f8
         3 person_id             = f8
         3 event_id              = f8
         3 action_type_cd        = f8
         3 request_dt_tm         = dq8
         3 request_dt_tm_ind     = i2
         3 request_prsnl_id      = f8
         3 request_prsnl_ft      = vc
         3 request_comment       = vc
         3 action_dt_tm          = dq8
         3 action_dt_tm_ind      = i2
         3 action_prsnl_id       = f8
         3 action_prsnl_ft       = vc
         3 proxy_prsnl_id        = f8
         3 proxy_prsnl_ft        = vc
         3 action_status_cd      = f8
         3 action_comment        = vc
         3 change_since_action_flag  = i2
         3 change_since_action_flag_ind  = i2
         3 action_prsnl_pin      = vc
         3 defeat_succn_ind      = i2
         3 ce_event_prsnl_id     = f8
         3 valid_from_dt_tm      = dq8
         3 valid_from_dt_tm_ind  = i2
         3 valid_until_dt_tm     = dq8
         3 valid_until_dt_tm_ind  = i2
         3 updt_dt_tm            = dq8
         3 updt_dt_tm_ind        = i2
         3 updt_task             = i4
         3 updt_task_ind         = i2
         3 updt_id               = f8
         3 updt_cnt              = i4
         3 updt_cnt_ind          = i2
         3 updt_applctx          = i4
         3 updt_applctx_ind      = i2
         3 long_text_id          = f8
         3 linked_event_id       = f8
         3 request_tz            = i4
         3 action_tz             = i4
         3 system_comment        = vc
         3 event_action_modifier_list  [*]
            4 ce_event_action_modifier_id  = f8
            4 event_action_modifier_id  = f8
            4 event_id              = f8
            4 event_prsnl_id        = f8
            4 action_type_modifier_cd  = f8
            4 valid_from_dt_tm      = dq8
            4 valid_from_dt_tm_ind  = i2
            4 valid_until_dt_tm     = dq8
            4 valid_until_dt_tm_ind  = i2
            4 updt_dt_tm            = dq8
            4 updt_dt_tm_ind        = i2
            4 updt_task             = i4
            4 updt_task_ind         = i2
            4 updt_id               = f8
            4 updt_cnt              = i4
            4 updt_cnt_ind          = i2
            4 updt_applctx          = i4
            4 updt_applctx_ind      = i2
         3 ensure_type           = i2
         3 digital_signature_ident  = vc
         3 action_prsnl_group_id  = f8
         3 request_prsnl_group_id  = f8
         3 receiving_person_id   = f8
         3 receiving_person_ft   = vc
      2 ensure_type2          = i2
      2 clinsig_updt_dt_tm_flag  = i2
      2 clinsig_updt_dt_tm    = dq8
      2 clinsig_updt_dt_tm_ind  = i2
   1 message_item
      2 message_text          = vc
      2 subject               = vc
      2 confidentiality       = i2
      2 priority              = i2
      2 due_date              = dq8
      2 sender_id             = f8
   1 user_id               = f8
) 
 
record ensure_reply (
   1 rep                   [*]
      2 event_prsnl_id        = f8
      2 event_id              = f8
      2 action_prsnl_id       = f8
      2 action_type_cd        = f8
      2 sb
         3 severityCd            = i4
         3 statusCd              = i4
         3 statusText            = vc
         3 subStatusList         [*]
            4 subStatusCd           = i4
   1 sb
      2 severityCd            = i4
      2 statusCd              = i4
      2 statusText            = vc
      2 subStatusList         [*]
         3 subStatusCd           = i4
 
%i cclsource:status_block.inc
) 

set stat = alterlist(ensure_request->req, 1) 
set ensure_request->req[1].ensure_type 			 		= 2 
set ensure_request->req[1].version_dt_tm_ind 			= 1 
set ensure_request->req[1].event_prsnl.event_id 		= t_rec->event_id 
set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"CONFIRM"))  
set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
set ensure_request->req[1].event_prsnl.updt_dt_tm 		= cnvtdatetime(curdate,curtime3)
set ensure_request->req[1].event_prsnl.action_prsnl_id 	= t_rec->request_prsnl_id
set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
;set ensure_request->req[1].event_prsnl.action_comment = "Example Comment, cancelled order" 

if (t_Rec->cancel_ind = 0)
	execute inn_event_prsnl_batch_ensure with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
endif 

call writeLog(build2("* END Adding Action ************************************"))

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
	if (validate(t_rec))
		call echojson(t_rec,t_rec->log_filename_a,1)
		call echorecord(t_rec)
	endif
	if (validate(ensure_request))
		call echojson(ensure_request,t_rec->log_filename_a,1)
		call echorecord(ensure_request)
	endif
	if (validate(ensure_reply))
		call echojson(ensure_reply,t_rec->log_filename_a,1)
		call echorecord(ensure_reply)
	endif
call exitScript(null)


end 
go

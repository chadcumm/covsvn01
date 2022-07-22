/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_add_ce_action.prg
  Object name:        bc_all_mp_add_ce_action
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
drop program bc_all_mp_add_ce_action:dba go
create program bc_all_mp_add_ce_action:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENT_ID" = 0 

with OUTDEV, EVENT_ID

free record t_rec
record t_rec
(
	1 event_id = f8
	1 cancel_ind = i2
	1 updt_ind = i2
	1 request_prsnl_id = f8
	1 new_title = vc
	1 normal_ref_range_txt = vc
)

if (validate(request->blob_in))
    if (request->blob_in > " ")
        set stat =  cnvtjsontorec(request->blob_in)
        if (validate(resultdata->event_id))
        	set t_rec->event_id = resultdata->parent_event_id
        	call echorecord(resultdata)
        	call echo(t_rec->event_id)
        endif
    else
        set _memory_reply_string = "request->blob_in NOT valid."
        go to exit_script
    endif
else
    set _memory_reply_string = "request->blob_in NOT valid."
    go to exit_script
endif

set t_rec->request_prsnl_id	= reqinfo->updt_id


select into "nl:"
from
	clinical_event ce
plan ce
	where ce.event_id = t_rec->event_id
detail
	call echo(build2("-->Inside Detail Section"))
	call echo(build2("--->",trim(ce.event_title_text)))
	t_rec->normal_ref_range_txt = ce.normal_ref_range_txt
	if (ce.event_title_text != "ACTIONED:*")
		t_rec->updt_ind = 1
	endif
	if (substring(1,9,ce.event_title_text) in("CANCELED:"))
		t_rec->updt_ind = 0
		t_rec->cancel_ind = 1
	endif
	
	call echo(build2("--->checking:",trim(substring(1,9,ce.event_title_text))))
	if (substring(1,9,ce.event_title_text) in("MODIFIED:"))
		t_rec->new_title = trim(substring(10,200,ce.event_title_text))
	else
		t_rec->new_title = trim(ce.event_title_text)
	endif
	call echo(build2("--->after check t_rec->new_title",trim(t_rec->new_title)))
	
	t_rec->new_title = build2("ACTIONED:",trim(t_rec->new_title))
	
	call echo(build2("--->after concat t_rec->new_title",trim(t_rec->new_title)))
	call echo(build2("-->",uar_get_code_display(ce.event_cd)))
	call echo(build2("<--Exit Detail Section"))
with nocounter

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
set ensure_request->req[1].event_prsnl.action_comment 	= "Document Printed" 

if (t_rec->cancel_ind = 0)
	execute inn_event_prsnl_batch_ensure with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
	update into clinical_event ce 
	set ce.normal_ref_range_txt = t_rec->normal_ref_range_txt
	where ce.event_id = t_rec->event_id
	commit 
endif 

if ((t_rec->event_id > 0.0) and (t_rec->updt_ind = 1))
	update into clinical_event ce 
	set ce.event_title_text = t_rec->new_title, 
		ce.result_status_cd = value(uar_get_code_by("MEANING",8,"AUTH"))
	where ce.event_id = t_rec->event_id
	commit 
endif

call echorecord(t_rec)

end go

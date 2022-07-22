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
drop program cov_add_ce_event_action:dba go
create program cov_add_ce_event_action:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENT_ID" = 0
	, "PRSNL_ID" = 0
	, "ACTION_TYPE" = ""
	, "ACTION_STATUS" = "" 

with OUTDEV, EVENT_ID, PRSNL_ID, ACTION_TYPE, ACTION_STATUS

record t_rec
(
	1 event_id 					= f8
	1 action_type 				= vc
	1 action_type_cd		 	= f8
	1 action_status 			= vc
	1 action_status_cd			= f8
	1 updt_ind 					= i2
	1 request_prsnl_id 			= f8
	1 new_title 				= vc
	1 cancel_ind 				= i2
) with protect



set t_rec->request_prsnl_id		= $PRSNL_ID
set t_rec->event_id 			= $EVENT_ID
set t_rec->action_status 		= $ACTION_STATUS
set t_rec->action_type 			= $ACTION_TYPE

set t_rec->action_status_cd = uar_get_code_by("MEANING",103,nullterm(t_rec->action_status))
set t_rec->action_type_cd 	= uar_get_code_by("MEANING",21,nullterm(t_rec->action_type))


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
set ensure_request->req[1].event_prsnl.action_type_cd 	= t_rec->action_type_cd  
set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
set ensure_request->req[1].event_prsnl.updt_dt_tm 		= cnvtdatetime(curdate,curtime3)
set ensure_request->req[1].event_prsnl.action_prsnl_id 	= t_rec->request_prsnl_id
set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
set ensure_request->req[1].event_prsnl.action_status_cd = t_rec->action_status_cd
set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
set ensure_request->req[1].event_prsnl.action_comment 	= "" 

if (t_rec->cancel_ind = 0)
 if (t_rec->event_id > 0.0)
 	call echo(build("t_rec->event_id=",t_rec->event_id))
	/*
	update into clinical_event 
			set	 performed_prsnl_id = 1
				,verified_prsnl_id = 1 
				,updt_id = 1
				,updt_cnt = (updt_cnt + 1)
				,updt_dt_tm = cnvtdatetime(curdate,curtime3)
			where event_id = t_rec->event_id

			and valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
			and valid_from_dt_tm <= cnvtdatetime(curdate, curtime3)
			commit
	*/			
	execute inn_event_prsnl_batch_ensure "MINE" with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
 endif

endif 



call echorecord(t_rec)

end go

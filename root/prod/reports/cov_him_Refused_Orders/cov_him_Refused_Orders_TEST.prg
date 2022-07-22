/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:		04/04/2019
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_Refused_Orders.prg
	Object name:		cov_him_Refused_Orders
	Request #:			?, 12922
 
	Program purpose:	Lists message center entries for refusal items.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/25/2022	Todd A. Blanchard		Changed structure of CCL to use 
										request/reply logic from ProFile Letters.
 
******************************************************************************/
 
drop program cov_him_Refused_Orders_TEST go
create program cov_him_Refused_Orders_TEST

prompt 
	"Output to File/Printer/MINE" = "MINE" 

with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")), protect
declare onhold_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 79, "ONHOLD")), protect
declare opened_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 79, "OPENED")), protect
declare pending_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 79, "PENDING")), protect
declare msg_category_config_id		= f8 with constant(2865819261.00), protect
declare application_number			= i4 with constant(600005), protect
declare provider_id					= f8 with noconstant(0.0), protect

 
/**************************************************************
; DVDev Start Coding
**************************************************************/

; Retrieve_Orders_By_Receiver
record 967706_request (
  1 receiver  
    2 provider_id = f8   
    2 pool_id = f8   
  1 patient_id = f8   
  1 status_codes [3]   
    2 status_cd = f8   
  1 date_range  
    2 begin_dt_tm = dq8   
    2 end_dt_tm = dq8   
  1 configuration  
    2 msg_category_config_id = f8   
    2 msg_subcategory_config_id = f8   
    2 application_number = i4   
    2 config_id = f8   
  1 load  
    2 names_ind = i2   
    2 only_unassigned_pool_items_ind = i2   
    2 filter_out_pool_items = i2   
    2 location_information = i2   
  1 action_prsnl_id = f8   
) 

record 967706_reply (
  1 transaction_status  
    2 success_ind = i2   
    2 debug_error_message = vc  
  1 transaction_uid = vc  
  1 orders [*]   
    2 task_id = f8   
    2 order_notification_id = f8   
    2 order_id = f8   
    2 person_id = f8   
    2 person_name = c100  
    2 encounter_id = f8   
    2 msg_sender_id = f8   
    2 msg_sender_name = vc  
    2 originator_id = f8   
    2 originator_name = c100  
    2 loc_facility_cd = f8   
    2 task_status_cd = f8   
    2 notification_type_cd = f8   
    2 stop_type_cd = f8   
    2 action_type_cd = f8   
    2 med_order_type_cd = f8   
    2 order_mnemonic = c100  
    2 hna_order_mnemonic = vc  
    2 ordered_as_mnenomic = vc  
    2 detail_display = c100  
    2 notification_comment = c100  
    2 order_comment = c100  
    2 creation_dt_tm = dq8   
    2 creation_tz = i4   
    2 updated_dt_tm = dq8   
    2 stop_dt_tm = dq8   
    2 stop_tz = i4   
    2 version = i4   
    2 caused_by_flag = i4   
    2 msg_sender_pool_id = f8   
    2 msg_sender_pool_name = vc  
    2 to_prsnls [*]   
      3 to_prsnl_id = f8   
      3 to_prsnl_name = vc  
    2 to_pools [*]   
      3 to_pool_id = f8   
      3 to_pool_name = vc  
      3 assigned_prsnl_id = f8   
      3 assigned_prsnl_name = vc  
    2 location_information  
      3 loc_facility_cd = f8   
      3 loc_ward_cd = f8   
    2 task_uid = vc  
  1 order_limit_exceeded_ind = i2   
  1 proposal_notifications [*]   
    2 person_id = f8   
    2 person_name = vc  
    2 encounter_id = f8   
    2 notifications [*]   
      3 order_proposal_notif_id = f8   
      3 order_proposal_id = f8   
      3 order_id = f8   
      3 msg_sender_id = f8   
      3 msg_sender_name = vc  
      3 msg_sender_pool_id = f8   
      3 msg_sender_pool_name = vc  
      3 originator_id = f8   
      3 originator_name = vc  
      3 forward_comment = vc  
      3 task_status_cd = f8   
      3 notification_type_cd = f8   
      3 detail_display = vc  
      3 created_dt_tm = dq8   
      3 created_tz = i4   
      3 updated_dt_tm = dq8   
      3 version = i4   
      3 origin_flag = i2   
      3 to_prsnls [*]   
        4 to_prsnl_id = f8   
        4 to_prsnl_name = vc  
      3 to_pools [*]   
        4 to_pool_id = f8   
        4 to_pool_name = vc  
        4 assigned_prsnl_id = f8   
        4 assigned_prsnl_name = vc  
      3 available_actions  
        4 can_accept = i2   
        4 can_reject = i2   
        4 can_withdraw = i2   
  1 phase_notifications [*]   
    2 phase_id = f8   
    2 phase_name = vc  
    2 person_id = f8   
    2 person_name = vc  
    2 encounter_id = f8   
    2 msg_sender_id = f8   
    2 msg_sender_name = vc  
    2 msg_sender_pool_id = f8   
    2 msg_sender_pool_name = vc  
    2 originator_id = f8   
    2 originator_name = vc  
    2 forward_comment = vc  
    2 created_dt_tm = dq8   
    2 created_tz = i4   
    2 to_prsnls [*]   
      3 to_prsnl_id = f8   
      3 to_prsnl_name = vc  
    2 to_pools [*]   
      3 to_pool_id = f8   
      3 to_pool_name = vc  
      3 assigned_prsnl_id = f8   
      3 assigned_prsnl_name = vc  
    2 phase_notification_id = f8   
    2 encounters [*]   
      3 encounter_id = f8   
  1 daily_review_notifications [*]   
    2 person_id = f8   
    2 person_name = vc  
    2 encounter_id = f8   
    2 notifications [*]   
      3 responsible_personnel_id = f8   
      3 responsible_personnel_name = vc  
      3 order_id = f8   
      3 review_date  
        4 year = i4   
        4 month = i4   
        4 day = i4   
      3 daily_review_order_status  
        4 is_overdue = i2   
        4 is_pending = i2   
      3 due_date = dq8   
      3 responsible_pool_id = f8   
      3 responsible_pool_name = vc  
      3 assign_personnel_id = f8   
      3 assign_personnel_name = vc  
      3 daily_review_version = i4   
      3 daily_review_id = f8   
) 


/**************************************************************/
; select provider data
select into "NL:"
from
	PRSNL per

where
	per.username = "HIMREFUSAL"
	and per.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and per.active_ind = 1
	
detail
	provider_id = per.person_id
	
with nocounter


/**************************************************************/
; select orders data

set 967706_request->receiver.provider_id						= provider_id
set 967706_request->receiver.pool_id							= 0
set 967706_request->patient_id									= 0
set 967706_request->status_codes [1].status_cd					= onhold_var
set 967706_request->status_codes [2].status_cd					= opened_var
set 967706_request->status_codes [3].status_cd					= pending_var
set 967706_request->date_range.begin_dt_tm						= cnvtdatetime("22-MAY-2018 000000") ; go-live date
set 967706_request->date_range.end_dt_tm						= cnvtdatetime(curdate, curtime)
set 967706_request->configuration.msg_category_config_id		= msg_category_config_id
set 967706_request->configuration.msg_subcategory_config_id		= 0
set 967706_request->configuration.application_number			= application_number
set 967706_request->configuration.config_id						= 0
set 967706_request->load.names_ind								= 1
set 967706_request->load.only_unassigned_pool_items_ind			= 0
set 967706_request->load.filter_out_pool_items					= 0
set 967706_request->load.location_information					= 1
set 967706_request->action_prsnl_id								= reqinfo->updt_id

set stat = tdbexecute(600005, 967100, 967706, "REC", 967706_request, "REC", 967706_reply)

call echorecord(967706_request)
call echorecord(967706_reply)


/**************************************************************/
; select data
select into value($OUTDEV)
	facility					= trim(org.org_name, 3)
	, patient_name				= trim(967706_reply->orders[d.seq].person_name, 3)
	, fin						= trim(ea.alias, 3)
	, order_name				= trim(967706_reply->orders[d.seq].order_mnemonic, 3)
	, order_id					= 967706_reply->orders[d.seq].order_id
	, details					= trim(replace(replace(967706_reply->orders[d.seq].detail_display, char(10), ""), char(13), ""), 3)
	, order_comment				= trim(replace(replace(967706_reply->orders[d.seq].order_comment, char(10), ""), char(13), ""), 3)
	, originator_name			= trim(967706_reply->orders[d.seq].originator_name, 3)
	, create_date				= 967706_reply->orders[d.seq].creation_dt_tm "mm/dd/yyyy hh:mm;;q"
	, notification_comment		= trim(replace(replace(967706_reply->orders[d.seq].notification_comment, char(10), ""), char(13), ""), 3)
	, stop_date					= 967706_reply->orders[d.seq].stop_dt_tm "mm/dd/yyyy hh:mm;;q"
	, stop_type					= trim(uar_get_code_display(967706_reply->orders[d.seq].stop_type_cd), 3)
	, updated_date				= 967706_reply->orders[d.seq].updated_dt_tm "mm/dd/yyyy hh:mm;;q"
	, status					= trim(uar_get_code_display(967706_reply->orders[d.seq].task_status_cd), 3)
	, order_action				= trim(uar_get_code_display(967706_reply->orders[d.seq].action_type_cd), 3)
	, type						= trim(uar_get_code_display(967706_reply->orders[d.seq].notification_type_cd), 3)
	, from_name					= trim(967706_reply->orders[d.seq].msg_sender_name, 3)

from 
	(dummyt d with seq = size(967706_reply->orders, 5))
	, LOCATION l
	, ORGANIZATION org
	, ENCNTR_ALIAS ea
	, dummyt d2

plan d

join l
where
	l.location_cd = 967706_reply->orders[d.seq].loc_facility_cd
	
join org
where
	org.organization_id = l.organization_id

join d2

join ea
where
	ea.encntr_id = 967706_reply->orders[d.seq].encounter_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1

order by
	facility
	, patient_name
	, fin
	, order_id

with nocounter, outerjoin = d2, separator = " ", format
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exit_script

end
go

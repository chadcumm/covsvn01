/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_wh_find_appt.prg
  Object name:        cov_wh_find_appt
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_wh_find_appt:dba go
create program cov_wh_find_appt:dba

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 search_dt_tm = dq8
	1 cnt = i2
	1 qual[*]
	 2 sch_event_id = f8
	 2 schedule_id = f8
	 2 candidate_id = f8
	 2 appt_scheme_id = f8
)

;651001 - sch_chgw_event_state
record 651001_request (
  1 call_echo_ind = i2   
  1 action_dt_tm = dq8   
  1 conversation_id = f8   
  1 skip_post_event_ind = i2   
  1 product_cd = f8   
  1 product_meaning = c12  
  1 comment_partial_ind = i2   
  1 comment_qual_cnt = i4   
  1 comment_qual [*]   
    2 action = i2   
    2 text_type_cd = f8   
    2 text_type_meaning = vc  
    2 sub_text_cd = f8   
    2 sub_text_meaning = vc  
    2 text_action = i2   
    2 text = vc  
    2 text_id = f8   
    2 text_updt_cnt = i4   
    2 text_active_ind = i2   
    2 text_active_status_cd = f8   
    2 text_force_updt_ind = i2   
    2 updt_cnt = i4   
    2 version_ind = i2   
    2 force_updt_ind = i2   
    2 candidate_id = f8   
    2 active_ind = i2   
    2 active_status_cd = f8   
  1 summary_partial_ind = i2   
  1 summary_qual_cnt = i4   
  1 summary_qual [*]   
    2 action = i2   
    2 sch_notify_id = f8   
    2 base_route_id = f8   
    2 sch_report_id = f8   
    2 output_dest_id = f8   
    2 to_prsnl_id = f8   
    2 suffix = vc  
    2 email = vc  
    2 transmit_dt_tm = dq8   
    2 nbr_copies = i4   
    2 source_type_cd = f8   
    2 source_type_meaning = vc  
    2 report_type_cd = f8   
    2 report_type_meaning = vc  
    2 requested_dt_tm = dq8   
    2 printed_dt_tm = dq8   
    2 updt_cnt = i4   
    2 version_ind = i2   
    2 force_updt_ind = i2   
    2 candidate_id = f8   
    2 active_ind = i2   
    2 active_status_cd = f8   
  1 itinerary_partial_ind = i2   
  1 itinerary_qual_cnt = i4   
  1 itinerary_qual [*]   
    2 action = i2   
    2 sch_notify_id = f8   
    2 base_route_id = f8   
    2 sch_report_id = f8   
    2 output_dest_id = f8   
    2 to_prsnl_id = f8   
    2 suffix = vc  
    2 email = vc  
    2 transmit_dt_tm = dq8   
    2 nbr_copies = i4   
    2 source_type_cd = f8   
    2 source_type_meaning = vc  
    2 report_type_cd = f8   
    2 report_type_meaning = vc  
    2 report_table = vc  
    2 report_id = f8   
    2 beg_dt_tm = dq8   
    2 end_dt_tm = dq8   
    2 requested_dt_tm = dq8   
    2 printed_dt_tm = dq8   
    2 updt_cnt = i4   
    2 version_ind = i2   
    2 force_updt_ind = i2   
    2 candidate_id = f8   
    2 active_ind = i2   
    2 active_status_cd = f8   
  1 allow_partial_ind = i2   
  1 qual [*]   
    2 sch_event_id = f8   
    2 skip_tofollow_ind = i2   
    2 schedule_seq = i4   
    2 schedule_id = f8   
    2 request_action_id = f8   
    2 sch_action_cd = f8   
    2 action_meaning = vc  
    2 sch_reason_cd = f8   
    2 reason_meaning = vc  
    2 sch_state_cd = f8   
    2 state_meaning = vc  
    2 sch_action_id = f8   
    2 lock_flag = i2   
    2 unlock_action_id = f8   
    2 sch_lock_id = f8   
    2 appt_scheme_id = f8   
    2 perform_dt_tm = dq8   
    2 verify_flag = i2   
    2 ver_interchange_id = f8   
    2 ver_status_cd = f8   
    2 ver_status_meaning = c12  
    2 verify_action_id = f8   
    2 abn_flag = i2   
    2 retain_review_ind = i2   
    2 abn_conv_id = f8   
    2 abn_action_id = f8   
    2 move_appt_ind = i2   
    2 move_appt_dt_tm = dq8   
    2 tci_dt_tm = dq8   
    2 version_dt_tm = dq8   
    2 updt_cnt = i4   
    2 version_ind = i2   
    2 force_updt_ind = i2   
    2 candidate_id = f8   
    2 cancel_order_flag = i2   
    2 comment_partial_ind = i2   
    2 comment_qual_cnt = i4   
    2 comment_qual [*]   
      3 action = i2   
      3 sch_action_id = f8   
      3 text_type_cd = f8   
      3 text_type_meaning = vc  
      3 sub_text_cd = f8   
      3 sub_text_meaning = vc  
      3 text_action = i2   
      3 text = vc  
      3 text_id = f8   
      3 text_updt_cnt = i4   
      3 text_active_ind = i2   
      3 text_active_status_cd = f8   
      3 text_force_updt_ind = i2   
      3 updt_cnt = i4   
      3 version_ind = i2   
      3 force_updt_ind = i2   
      3 candidate_id = f8   
      3 active_ind = i2   
      3 active_status_cd = f8   
      3 predefined_comm_cd = f8   
    2 detail_partial_ind = i2   
    2 detail_qual_cnt = i4   
    2 detail_qual [*]   
      3 action = i2   
      3 sch_action_id = f8   
      3 oe_field_id = f8   
      3 oe_field_value = f8   
      3 oe_field_display_value = vc  
      3 oe_field_dt_tm_value = dq8   
      3 oe_field_meaning = vc  
      3 oe_field_meaning_id = f8   
      3 value_required_ind = i2   
      3 group_seq = i4   
      3 field_seq = i4   
      3 modified_ind = i2   
      3 updt_cnt = i4   
      3 version_ind = i2   
      3 force_updt_ind = i2   
      3 candidate_id = f8   
      3 active_ind = i2   
      3 active_status_cd = f8   
    2 attach_partial_ind = i2   
    2 attach_qual_cnt = i4   
    2 attach_qual [*]   
      3 action = i2   
      3 primary_ind = i2   
      3 order_seq_nbr = i4   
      3 concurrent_ind = i2   
      3 sch_attach_id = f8   
      3 attach_type_cd = f8   
      3 attach_type_meaning = vc  
      3 order_status_cd = f8   
      3 order_status_meaning = vc  
      3 seq_nbr = i4   
      3 order_id = f8   
      3 sch_state_cd = f8   
      3 state_meaning = c12  
      3 beg_schedule_seq = i4   
      3 end_schedule_seq = i4   
      3 event_dt_tm = dq8   
      3 order_dt_tm = dq8   
      3 updt_cnt = i4   
      3 version_ind = i2   
      3 force_updt_ind = i2   
      3 candidate_id = f8   
      3 active_ind = i2   
      3 active_status_cd = f8   
      3 synonym_id = f8   
      3 description = vc  
      3 attach_source_flag = i2   
    2 option_pass_ind = i2   
    2 option_qual_cnt = i4   
    2 option_qual [*]   
      3 sch_option_cd = f8   
      3 option_meaning = vc  
    2 notification_pass_ind = i2   
    2 notification_partial_ind = i2   
    2 notification_qual_cnt = i4   
    2 notification_qual [*]   
      3 action = i2   
      3 sch_action_id = f8   
      3 sch_notify_id = f8   
      3 base_route_id = f8   
      3 sch_report_id = f8   
      3 output_dest_id = f8   
      3 to_prsnl_id = f8   
      3 suffix = vc  
      3 email = vc  
      3 transmit_dt_tm = dq8   
      3 nbr_copies = i4   
      3 source_type_cd = f8   
      3 source_type_meaning = vc  
      3 report_type_cd = f8   
      3 report_type_meaning = vc  
      3 requested_dt_tm = dq8   
      3 printed_dt_tm = dq8   
      3 updt_cnt = i4   
      3 version_ind = i2   
      3 force_updt_ind = i2   
      3 candidate_id = f8   
      3 active_ind = i2   
      3 active_status_cd = f8   
    2 schedule_partial_ind = i2   
    2 schedule_qual_cnt = i4   
    2 schedule_qual [*]   
      3 schedule_id = f8   
      3 sch_state_cd = f8   
      3 state_meaning = vc  
      3 unconfirm_count = i4   
      3 appt_partial_ind = i2   
      3 appt_qual_cnt = i4   
      3 appt_qual [*]   
        4 sch_appt_id = f8   
        4 sch_state_cd = f8   
        4 state_meaning = vc  
    2 warning_partial_ind = i2   
    2 warning_qual_cnt = i4   
    2 warning_qual [*]   
      3 action = i2   
      3 sch_warn_id = f8   
      3 warn_type_cd = f8   
      3 warn_type_meaning = vc  
      3 warn_batch_cd = f8   
      3 warn_batch_meaning = vc  
      3 warn_level_cd = f8   
      3 warn_level_meaning = vc  
      3 warn_class_cd = f8   
      3 warn_class_meaning = vc  
      3 warn_reason_cd = f8   
      3 warn_reason_meaning = vc  
      3 warn_state_cd = f8   
      3 warn_state_meaning = vc  
      3 warn_option_cd = f8   
      3 warn_option_meaning = vc  
      3 bit_mask = i4   
      3 sch_appt_id = f8   
      3 sch_appt_index = i4   
      3 sch_action_id = f8   
      3 sch_action_index = i4   
      3 warn_prsnl_id = f8   
      3 warn_dt_tm = dq8   
      3 updt_cnt = i4   
      3 version_ind = i2   
      3 force_updt_ind = i2   
      3 candidate_id = f8   
      3 active_ind = i2   
      3 active_status_cd = f8   
      3 option_partial_ind = i2   
      3 option_qual_cnt = i4   
      3 option_qual [*]   
        4 action = i2   
        4 sch_option_id = f8   
        4 warn_reason_cd = f8   
        4 warn_reason_meaning = vc  
        4 warn_option_cd = f8   
        4 warn_option_meaning = vc  
        4 warn_level_cd = f8   
        4 warn_level_meaning = vc  
        4 warn_class_cd = f8   
        4 warn_class_meaning = vc  
        4 warn_prsnl_id = f8   
        4 warn_dt_tm = dq8   
        4 updt_cnt = i4   
        4 version_ind = i2   
        4 force_updt_ind = i2   
        4 candidate_id = f8   
        4 active_ind = i2   
        4 active_status_cd = f8   
        4 comment_partial_ind = i2   
        4 comment_qual_cnt = i4   
        4 comment_qual [*]   
          5 action = i2   
          5 text_type_cd = f8   
          5 text_type_meaning = vc  
          5 sub_text_cd = f8   
          5 sub_text_meaning = vc  
          5 text_action = i2   
          5 text = vc  
          5 text_id = f8   
          5 text_updt_cnt = i4   
          5 text_active_ind = i2   
          5 text_active_status_cd = f8   
          5 text_force_updt_ind = i2   
          5 updt_cnt = i4   
          5 version_ind = i2   
          5 force_updt_ind = i2   
          5 candidate_id = f8   
          5 active_ind = i2   
          5 active_status_cd = f8   
    2 requests_pass_ind = i2   
    2 requests_qual_cnt = i4   
    2 requests_qual [*]   
      3 request_action_id = f8   
      3 sch_action_cd = f8   
      3 action_meaning = c12  
    2 move_criteria_partial_ind = i2   
    2 move_criteria_qual_cnt = i4   
    2 move_criteria_qual [*]   
      3 action = i2   
      3 move_flag = i2   
      3 move_pref_beg_tm = i4   
      3 move_pref_end_tm = i4   
      3 move_requestor = c255  
      3 updt_cnt = i4   
      3 version_ind = i2   
      3 force_updt_ind = i2   
      3 candidate_id = f8   
      3 active_ind = i2   
      3 active_status_cd = f8   
      3 comment_partial_ind = i2   
      3 comment_qual_cnt = i4   
      3 comment_qual [*]   
        4 action = i2   
        4 text_type_cd = f8   
        4 text_type_meaning = vc  
        4 sub_text_cd = f8   
        4 sub_text_meaning = vc  
        4 text_action = i2   
        4 text = vc  
        4 text_id = f8   
        4 text_updt_cnt = i4   
        4 text_active_ind = i2   
        4 text_active_status_cd = f8   
        4 text_force_updt_ind = i2   
        4 updt_cnt = i4   
        4 version_ind = i2   
        4 force_updt_ind = i2   
        4 candidate_id = f8   
        4 active_ind = i2   
        4 active_status_cd = f8   
    2 link_partial_ind = i2   
    2 link_qual_cnt = i4   
    2 link_qual [*]   
      3 action = i2   
      3 sch_link_id = f8   
      3 sch_event_id = f8   
      3 force_updt_ind = i2   
      3 active_ind = i2   
      3 updt_cnt = i4   
      3 auto_generated_ind = i2   
    2 offer_qual_cnt = i4   
    2 offer_qual [*]   
      3 pm_offer_id = f8   
      3 encntr_id = f8   
      3 schedule_id = f8   
      3 arrived_on_time_ind = i2   
      3 reasonable_offer_ind = i2   
      3 remove_from_wl_ind = i2   
      3 pat_initiated_ind = i2   
      3 attendance_cd = f8   
      3 admit_offer_outcome_cd = f8   
      3 offer_type_cd = f8   
      3 outcome_of_attendance_cd = f8   
      3 sch_reason_cd = f8   
      3 wl_reason_for_removal_cd = f8   
      3 offer_dt_tm = dq8   
      3 offer_made_dt_tm = dq8   
      3 tci_dt_tm = dq8   
      3 wl_removal_dt_tm = dq8   
      3 appt_dt_tm = dq8   
      3 cancel_dt_tm = dq8   
      3 dna_dt_tm = dq8   
      3 episode_activity_status_cd = f8   
    2 grp_desc = vc  
    2 grp_capacity = i4   
    2 grp_flag = i2   
    2 grpsession_id = f8   
    2 grpsession_cancel_ind = i2   
    2 grp_shared_ind = i2   
    2 grp_closed_ind = i2   
    2 grp_beg_dt_tm = dq8   
    2 grp_end_dt_tm = dq8   
    2 hcv_flag = i2   
    2 hcv_interchange_id = f8   
    2 hcv_ver_status_cd = f8   
    2 hcv_ver_status_meaning = c12  
    2 hcv_action_id = f8   
    2 orig_action_prsnl_id = f8   
    2 cab_flag = i2   
    2 abn_total_price = f8   
    2 abn_total_price_format = vc  
    2 susp_phys_ovr_cnt = i4   
    2 susp_phys_ovr [*]   
      3 physician_type_cd = f8   
      3 physician_prsnl_id = f8   
      3 authorized_prsnl_id = f8   
      3 comment_text = vc  
    2 contact_follow_up_dt_tm = dq8   
  1 displacement_ind = i2   
  1 program_name = vc  
  1 pm_output_dest_cd = f8   
  1 deceased_skip_notify_ind = i2   
) 


set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif


set t_rec->search_dt_tm = cnvtdatetime(curdate,curtime3)

select into "nl:"
	cdr.result_dt_tm
from 
	 clinical_event ce 
	,ce_date_result cdr
plan ce
	where ce.event_cd in(
							select cv.code_value 
							from code_value cv 
							where cv.concept_cki = "CERNER!ASYr9AEYvUr1YoPTCqIGfQ"
						)
	and ce.person_id = t_rec->patient.person_id
	and ce.encntr_id = t_rec->patient.encntr_id
	and ce.event_end_dt_tm >= cnvtdatetime(curdate,0)
join cdr
	where cdr.event_id = ce.event_id
	and   cnvtdatetime(curdate,curtime3) between cdr.valid_from_dt_tm and cdr.valid_until_dt_tm
order by
	 ce.event_cd
	,ce.event_end_dt_tm
head ce.event_cd
	t_rec->search_dt_tm = cdr.result_dt_tm
with nocounter


/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

select into "nl;"
	sa.sch_appt_id
from
	 encounter e
	,sch_appt sa
	,sch_event se
plan e
	where e.encntr_id = t_rec->patient.encntr_id
join sa
	where sa.person_id = e.person_id
	and   sa.beg_dt_tm >= cnvtdatetime(t_rec->search_dt_tm)
	and   sa.state_meaning = "CONFIRMED"
join se
	where se.sch_event_id = sa.sch_event_id
	and   se.appt_type_cd in(
								     value(uar_get_code_by("DISPLAY",14230,"OB Amniocentesis"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Cerclage Removal"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Fetal Non-Stress Test"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Induction"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Induction (Fetal Demise)"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Methotrexate Injection"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Misc"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Preadmit"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Steroid Injection 1st"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Steroid Injection 2nd"))
									,value(uar_get_code_by("DISPLAY",14230,"OB Version"))
									/*
									OB Amniocentesis
									OB Cerclage Removal
									OB Fetal Non-Stress Test
									OB Induction
									OB Induction (Fetal Demise)
									OB Methotrexate Injection
									OB Misc
									OB Preadmit
									OB Steroid Injection 1st
									OB Steroid Injection 2nd
									OB Version
									*/
							)
order by
	 sa.beg_dt_tm
	,sa.sch_event_id
head report
	stat = 0
head sa.sch_event_id
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].sch_event_id = se.sch_event_id
	t_rec->qual[t_rec->cnt].schedule_id = sa.schedule_id
	t_rec->qual[t_rec->cnt].candidate_id = sa.candidate_id
	t_rec->qual[t_rec->cnt].appt_scheme_id = sa.appt_scheme_id
foot report
	stat = 0
with nocounter
	
if (t_rec->cnt > 0)
	set t_rec->return_value = "TRUE"
else
	set t_rec->return_value = "FALSE"
endif

if (t_rec->return_value = "TRUE")
 for (i=1 to size(t_rec->qual,5))
	set stat = initrec(651001_request)
	free set 651001_reply
	set stat = alterlist(651001_request->qual,1)
	set 651001_request->qual[1].sch_event_id  = t_rec->qual[i].sch_event_id
	set 651001_request->qual[1].skip_tofollow_ind  = 1
	set 651001_request->qual[1].schedule_id = t_rec->qual[i].schedule_id
	set 651001_request->qual[1].sch_action_cd = 4518
	set 651001_request->qual[1].action_meaning = "CANCEL"
	set 651001_request->qual[1].sch_reason_cd = 2902509
	set 651001_request->qual[1].sch_state_cd = 4535
	set 651001_request->qual[1].state_meaning = "CANCELED"
	set 651001_request->qual[1].appt_scheme_id = t_rec->qual[i].appt_scheme_id
	set 651001_request->qual[1].force_updt_ind = 1
	set 651001_request->qual[1].candidate_id = t_rec->qual[i].candidate_id
	set 651001_request->qual[1].comment_qual_cnt = 1
	set stat = alterlist(651001_request->qual[1].comment_qual,1)
	set 651001_request->qual[1].comment_qual[1].action = 1
	set 651001_request->qual[1].comment_qual[1].sch_action_id = -1
	set 651001_request->qual[1].comment_qual[1].text = "Canceled from a rule per documentation"
	set 651001_request->qual[1].comment_qual[1].text_active_ind = 1
	set 651001_request->qual[1].comment_qual[1].active_ind = 1
	
	call echorecord(651001_request)
	
	set stat = tdbexecute(650001,650551,651001,"REC",651001_request,"REC",651001_reply)
	
	call echorecord(651001_reply)
 endfor
endif


#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),"<new>;",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go

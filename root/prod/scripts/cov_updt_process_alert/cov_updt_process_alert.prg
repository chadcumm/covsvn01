/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       01/21/2020
  Solution:           Perioperative
  Source file name:   cov_updt_process_alert.prg
  Object name:        cov_updt_process_alert
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   01/21/2020  Chad Cummings
******************************************************************************/
drop program cov_updt_process_alert go
create program cov_updt_process_alert

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

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

/*
free set pmrequest 
record pmrequest (
  1 person_patient_qual = i4   
  1 esi_ensure_type = c3  
  1 mode = i2   
  1 person_patient [*]   
    2 action_type = c3  
    2 new_person = c1  
    2 person_id = f8   
    2 pm_hist_tracking_id = f8   
    2 transaction_dt_tm = dq8   
    2 active_ind_ind = i2   
    2 active_ind = i2   
    2 active_status_cd = f8   
    2 active_status_dt_tm = dq8   
    2 active_status_prsnl_id = f8   
    2 beg_effective_dt_tm = dq8   
    2 end_effective_dt_tm = dq8   
    2 adopted_cd = f8   
    2 bad_debt_cd = f8   
    2 baptised_cd = f8   
    2 birth_multiple_cd = f8   
    2 birth_order_ind = i2   
    2 birth_order = i4   
    2 birth_length_ind = i4   
    2 birth_length = f8   
    2 birth_length_units_cd = f8   
    2 birth_name = c100  
    2 birth_weight_ind = i4   
    2 birth_weight = f8   
    2 birth_weight_units_cd = f8   
    2 church_cd = f8   
    2 credit_hrs_taking_ind = i2   
    2 credit_hrs_taking = i4   
    2 cumm_leave_days_ind = i2   
    2 cumm_leave_days = i4   
    2 current_balance_ind = i4   
    2 current_balance = f8   
    2 current_grade_ind = i2   
    2 current_grade = i4   
    2 custody_cd = f8   
    2 degree_complete_cd = f8   
    2 diet_type_cd = f8   
    2 family_income_ind = i4   
    2 family_income = f8   
    2 family_size_ind = i2   
    2 family_size = i4   
    2 highest_grade_complete_cd = f8   
    2 immun_on_file_cd = f8   
    2 interp_required_cd = f8   
    2 interp_type_cd = f8   
    2 microfilm_cd = f8   
    2 nbr_of_brothers_ind = i2   
    2 nbr_of_brothers = i4   
    2 nbr_of_sisters_ind = i2   
    2 nbr_of_sisters = i4   
    2 organ_donor_cd = f8   
    2 parent_marital_status_cd = f8   
    2 smokes_cd = f8   
    2 tumor_registry_cd = f8   
    2 last_bill_dt_tm = dq8   
    2 last_bind_dt_tm = dq8   
    2 last_discharge_dt_tm = dq8   
    2 last_event_updt_dt_tm = dq8   
    2 last_payment_dt_tm = dq8   
    2 last_atd_activity_dt_tm = dq8   
    2 data_status_cd = f8   
    2 data_status_dt_tm = dq8   
    2 data_status_prsnl_id = f8   
    2 contributor_system_cd = f8   
    2 student_cd = f8   
    2 living_dependency_cd = f8   
    2 living_arrangement_cd = f8   
    2 living_will_cd = f8   
    2 nbr_of_pregnancies_ind = i2   
    2 nbr_of_pregnancies = i4   
    2 last_trauma_dt_tm = dq8   
    2 mother_identifier = c100  
    2 mother_identifier_cd = f8   
    2 disease_alert_cd = f8   
    2 disease_alert_list_ind = i2   
    2 disease_alert [*]   
      3 value_cd = f8   
    2 process_alert_cd = f8   
    2 process_alert_list_ind = i2   
    2 process_alert [*]   
      3 value_cd = f8   
    2 updt_cnt = i4   
    2 contact_list_cd = f8   
    2 gest_age_at_birth = i4   
    2 gest_age_method_cd = f8   
    2 contact_method_cd = f8   
    2 contact_time = c255  
    2 callback_consent_cd = f8   
    2 written_format_cd = f8   
    2 birth_order_cd = f8   
    2 prev_contact_ind = i2  
    2 source_sync_level_flag = i2
    2 iqh_participant_cd = f8
    2 source_version_number = cv
    2 source_last_sync_dt_tm = dq8
    2 family_income_source_cd = f8
    2 family_nbr_of_minors_cnt = i4
    2 fin_statement_verified_dt_tm = dq8
    2 fin_statement_expire_dt_tm = dq8
) 
*/
free set pmrequest 
record pmrequest (
  1 person_patient_qual = i4
  1 esi_ensure_type = c3
  1 mode = i2
  1 person_patient [*]
    2 action_type = c3
    2 new_person = c1
    2 person_id = f8
    2 pm_hist_tracking_id = f8
    2 transaction_dt_tm = dq8
    2 active_ind_ind = i2
    2 active_ind = i2
    2 active_status_cd = f8
    2 active_status_dt_tm = dq8
    2 active_status_prsnl_id = f8
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 adopted_cd = f8
    2 bad_debt_cd = f8
    2 baptised_cd = f8
    2 birth_multiple_cd = f8
    2 birth_order_ind = i2
    2 birth_order = i4
    2 birth_length_ind = i4
    2 birth_length = f8
    2 birth_length_units_cd = f8
    2 birth_name = c100
    2 birth_weight_ind = i4
    2 birth_weight = f8
    2 birth_weight_units_cd = f8
    2 church_cd = f8
    2 credit_hrs_taking_ind = i2
    2 credit_hrs_taking = i4
    2 cumm_leave_days_ind = i2
    2 cumm_leave_days = i4
    2 current_balance_ind = i4
    2 current_balance = f8
    2 current_grade_ind = i2
    2 current_grade = i4
    2 custody_cd = f8
    2 degree_complete_cd = f8
    2 diet_type_cd = f8
    2 family_income_ind = i4
    2 family_income = f8
    2 family_size_ind = i2
    2 family_size = i4
    2 highest_grade_complete_cd = f8
    2 immun_on_file_cd = f8
    2 interp_required_cd = f8
    2 interp_type_cd = f8
    2 microfilm_cd = f8
    2 nbr_of_brothers_ind = i2
    2 nbr_of_brothers = i4
    2 nbr_of_sisters_ind = i2
    2 nbr_of_sisters = i4
    2 organ_donor_cd = f8
    2 parent_marital_status_cd = f8
    2 smokes_cd = f8
    2 tumor_registry_cd = f8
    2 last_bill_dt_tm = dq8
    2 last_bind_dt_tm = dq8
    2 last_discharge_dt_tm = dq8
    2 last_event_updt_dt_tm = dq8
    2 last_payment_dt_tm = dq8
    2 last_atd_activity_dt_tm = dq8
    2 data_status_cd = f8
    2 data_status_dt_tm = dq8
    2 data_status_prsnl_id = f8
    2 contributor_system_cd = f8
    2 student_cd = f8
    2 living_dependency_cd = f8
    2 living_arrangement_cd = f8
    2 living_will_cd = f8
    2 nbr_of_pregnancies_ind = i2
    2 nbr_of_pregnancies = i4
    2 last_trauma_dt_tm = dq8
    2 mother_identifier = c100
    2 mother_identifier_cd = f8
    2 disease_alert_cd = f8
    2 disease_alert_list_ind = i2
    2 disease_alert [*]
      3 value_cd = f8
    2 process_alert_cd = f8
    2 process_alert_list_ind = i2
    2 process_alert [*]
      3 value_cd = f8
    2 updt_cnt = i4
    2 contact_list_cd = f8
    2 gest_age_at_birth = i4
    2 gest_age_method_cd = f8
    2 contact_method_cd = f8
    2 contact_time = c255
    2 callback_consent_cd = f8
    2 written_format_cd = f8
    2 birth_order_cd = f8
    2 prev_contact_ind = i2
    2 source_sync_level_flag = i2
    2 iqh_participant_cd = f8
    2 source_version_number = cv
    2 source_last_sync_dt_tm = dq8
    2 family_income_source_cd = f8
    2 family_nbr_of_minors_cnt = i4
    2 fin_statement_verified_dt_tm = dq8
    2 fin_statement_expire_dt_tm = dq8
)

record pmreply
(  1 person_patient_qual            =    I2
   1 person_patient[*]
     2 person_id                    =    F8.0
     2 pm_hist_tracking_id          =    F8
%i cclsource:status_block.inc
)


    
set pmrequest->person_patient_qual = 1 
set pmrequest->esi_ensure_type = 'UPT' 
set pmrequest->mode = 0 
set stat = alterlist(pmrequest->person_patient,1) 
set pmrequest->person_patient[1]->action_type = 'UPT' 
set pmrequest->person_patient[1]->new_person = '' 
set pmrequest->person_patient[1]->person_id =  t_rec->patient.person_id
set pmrequest->person_patient[1]->transaction_dt_tm = cnvtdatetime( curdate,curtime3 ) 
set pmrequest->person_patient[1]->process_alert_cd = value(uar_get_code_by("DISPLAY",19350,"Hearing Impaired")) 
set pmrequest->person_patient[1]->process_alert_list_ind = 1 
set stat = alterlist(pmrequest->person_patient[1]->process_alert,1) 
set pmrequest->person_patient[1]->process_alert[1]->value_cd = value(uar_get_code_by("DISPLAY",19350,"Hearing Impaired")) 

execute pm_ens_person_patient with replace("REQUEST",PMREQUEST,5), replace("REPLY",PMREPLY,5)
call echorecord(pmreply)
commit 
set t_rec->log_message = concat(
									 t_rec->log_message
									,trim(cnvtrectojson(pmreply))
								)

								
execute cov_send_a31_by_encntr_id "MINE",value(t_rec->patient.encntr_id)

set t_rec->return_value = "TRUE"

set t_rec->log_message = concat(
									 t_rec->log_message
									,trim(cnvtrectojson(t_rec))
								)
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
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end go


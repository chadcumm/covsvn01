/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   cov_updt_pregnancy.prg
  Object name:        cov_updt_pregnancy
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
drop program cov_updt_pregnancy:dba go
create program cov_updt_pregnancy:dba

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
	1 cv_12031_confirmed = f8
	1 cv_12030_active = f8
)

free set 640101_request
record 640101_request (
  1 patient_id = f8   
  1 confirmation_dt_tm = dq8   
  1 confirmation_method_cd = f8   
  1 problem_data [*]   
    2 problem_id = f8   
    2 confirmation_status_cd = f8   
    2 life_cycle_status_cd = f8   
    2 onset_dt_tm = dq8   
    2 problem_prsnl_id = f8   
    2 problem_comment [*]   
      3 problem_comment_id = f8   
      3 comment_prsnl_id = f8   
      3 comment_prsnl_name = vc  
      3 problem_comment_text = vc  
    2 onset_tz = i4   
  1 diagnosis_data [*]   
    2 diagnosis_id = f8   
    2 encntr_id = f8   
  1 nomen_source_id = vc  
  1 nomen_vocab_mean = c12  
  1 org_id = f8   
  1 encntr_id = f8   
  1 org_sec_override = i2   
  1 action_tz = i4   
  1 classification_cd = f8   
  1 confirmation_tz = i4   
) 

free set 640101_reply
record 640101_reply
(
	1 pregnancy_id			= f8
	1 problem_id			= f8
%i cclsource:status_block.inc
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

set t_rec->cv_12031_confirmed  	= uar_get_code_by("MEANING",12031,"CONFIRMED")
set t_rec->cv_12030_active 		= uar_get_code_by("MEANING",12030,"ACTIVE")

set 640101_request->patient_id 								= t_rec->patient.person_id 
set 640101_request->confirmation_dt_tm 						= cnvtdatetime(curdate,curtime3) 
set 640101_request->confirmation_method_cd 					= 0.0 

set stat = alterlist(640101_request->problem_data, 1) 

set 640101_request->problem_data[1].problem_id 				= 0 
set 640101_request->problem_data[1].confirmation_status_cd 	= t_rec->cv_12031_confirmed 
set 640101_request->problem_data[1].onset_dt_tm 			= cnvtdatetime(curdate,curtime3)
set 640101_request->problem_data[1].life_cycle_status_cd 	= t_rec->cv_12030_active 

; nomenclature (this should stay constant)
set 640101_request->nomen_source_id = "429859012" 
set 640101_request->nomen_vocab_mean = "SNMCT" 

set stat = tdbexecute(600005, 640001, 640101, "REC", 640101_request, "REC", 640101_reply)

set t_rec->return_value = "FALSE"

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

end 
go

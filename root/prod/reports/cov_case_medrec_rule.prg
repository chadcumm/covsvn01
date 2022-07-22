 
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Paramasivam
	Date Written:		Dec'28
	Solution:			Nursing/Case management
	Source file name:	      cov_case_medrec_rule.prg
	Object name:		cov_case_medrec_rule
	Request#:
 	Program purpose:	      Part of Discharge Med rec rule
 	Executing from:		Rule
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_case_medrec_rule:dba go
create program cov_case_medrec_rule:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; VARIABLE DECLARATION
**************************************************************/
 
declare encntrid_var = f8 with noconstant(0.0), protect
declare personid_var = f8 with noconstant(0.0), protect
declare userid_var    = f8 with noconstant(0.0), protect
declare log_message = vc with noconstant('')
declare log_misc1   = vc with noconstant('')
declare alert_id_var  = f8 with noconstant(0.0)
declare dsch_inst_dt_var  = dq8
declare alert_dt_var      = dq8
declare user_alert_dt_var = dq8
declare med_modify_dt_var = dq8
 
;set personid_var = trigger_personid
set encntrid_var = trigger_encntrid 
set userid_var   = reqinfo->updt_id 
set retval = 1
 
 
/**************************************************************
; CCL SCRIPT STARTS HERE
**************************************************************/
 
 
;Case Mgmnt Med alert
 
select distinct into 'NL:'
ce.encntr_id, ce.event_end_dt_tm, eh.send_dt_tm, eh.alert_id, eh.*
 
from clinical_event ce, eks_alert_esc_hist eh
 
;Dsch Summ printed?
plan ce where ce.encntr_id = encntrid_var
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Discharge Summary"))
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
				where ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
				and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
				group by ce1.encntr_id, ce1.event_cd )
 
;Is there an alert after printing dsch summ?
join eh where eh.encntr_id = ce.encntr_id
	and eh.send_dt_tm > ce.event_end_dt_tm
	and eh.alert_id = (select max(eh2.alert_id) from eks_alert_esc_hist eh2
				where eh2.encntr_id = eh.encntr_id
				and eh2.msg_type_cd = value(uar_get_code_by("DISPLAY", 30420, "Notify"))
				and eh2.subject_text = '*Discharge Medication Alert - Case Management'
				and eh2.alert_source = 'COV_DSCH_MEDREC_TSK'
				group by eh2.encntr_id)
Detail
	alert_id_var = eh.alert_id
	alert_dt_var = eh.send_dt_tm
  	dsch_inst_dt_var = ce.event_end_dt_tm

with nocounter
;------------------------------------------------------------------------------------------------
 
;User received the alert?
 
if(alert_dt_var != null) 

set user_alert_dt_var = null

select distinct into 'nl:'
eh.*
from eks_alert_esc_hist eh
 
plan eh where eh.encntr_id = encntrid_var
	and eh.alert_id = (select max(eh2.alert_id) from eks_alert_esc_hist eh2
			where eh2.encntr_id = eh.encntr_id
			and eh2.parent_entity_id = userid_var
			and eh2.parent_entity_name = 'PERSON'
			and eh2.send_dt_tm >= cnvtdatetime(dsch_inst_dt_var)
			group by eh2.encntr_id, eh2.parent_entity_id)
Detail
	user_alert_dt_var = eh.send_dt_tm
with nocounter

endif	 
 
;------------------------------------------------------------------------------------------------
 
;Finalize
 
if( (alert_id_var = 0.0) and (alert_dt_var = null))
	set retval = 0
 	set log_misc1 = ' '
	set log_message = 'No alert after dcsh Summ print'
elseif( user_alert_dt_var = null)
	set log_misc1 = ' '
 	set log_message = build2('Alert the user ', log_misc1 )
 	set retval = 100
else
	set log_misc1 = format(user_alert_dt_var, 'dd-mmm-yyyy hh:mm:ss;;q')
 	set log_message = build2('User Alert found On ', log_misc1 )
 	set retval = 0
endif
 
;return(log_message)
;return(retval)
 
call echo(build2('log message = ',log_message, '--  retval = ', retval))
 
 
 
end go
 
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 

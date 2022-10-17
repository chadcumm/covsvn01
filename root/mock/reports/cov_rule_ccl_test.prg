 
drop program cov_rule_ccl_test:dba go
create program cov_rule_ccl_test:dba
 
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
 
set encntrid_var =   125199206.00  ;trigger_encntrid ;125457611
;set userid_var   = 16489162.00 ;reqinfo->updt_id ;12428721.00
set log_retval = 1
 
 
/**************************************************************
; CCL SCRIPT STARTS HERE
**************************************************************/
 
 
 
 
/* 
select into "nl:" 
from 
	clinical_event ce
plan ce
	where ce.encntr_id = encntrid_var ;@ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val = "VTE Close Chart - Not Responsible Provider"   ;"*Not Responsible Provider"
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Not Responsible Provider - Not Found"
	log_retval = 0
detail
	log_message = build2("Not Responsible Provider Found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")	
	log_retval = 100
with nocounter;, nullreport go
 
 
 
/*
select into 'nl:'
ea.alias
from encntr_alias ea
where ea.encntr_id = 125338413 ;trigger_encntrid
	and ea.encntr_alias_type_cd = value(uar_get_code_by("DISPLAY", 319, "FIN NBR"))
	and ea.active_ind = 1
Head report
	log_message = "No Alias found"
	log_retval = 0
	log_misc1 = ' '
Detail
 	log_retval = 100
 	log_misc1 = ea.alias
 	log_message = concat( 'Alias Found - ', log_misc1)
with nocounter;, nullreport go
 */
 
 
 /*
select ;into 'nl:'
eh.encntr_id, eh.send_dt_tm, eh.alert_id, eh.updt_dt_tm, aid = cnvtstring(eh.alert_id)
from eks_alert_esc_hist eh
plan eh where eh.encntr_id = 125359334 ;trigger_encntrid
	and eh.updt_dt_tm between cnvtlookbehind("3,m") and cnvtdatetime(curdate,curtime3)
	and eh.msg_type_cd = value(uar_get_code_by("DISPLAY", 30420, "Notify"))
	and eh.subject_text = '*Discharge Medication Alert - Case Management'
	and eh.alert_source IN('COV_DSCH_MEDREC_TSK', 'COV_DSCH_MEDREC_TSK_REMIN')
order by eh.encntr_id, eh.alert_id
 
Head report
	log_message = "No Alerts found"
	log_retval = 0
	log_misc1 = ' '
Detail
 	log_retval = 100
 	log_misc1 = concat('Case Management Alert - ', aid)
 	log_message = concat( 'Alert Found - ', log_misc1)
with nocounter;, nullreport go
 */
 
call echo(build2('log message = ',log_message, '--  retval = ', log_retval))
 
 
 
end go
 
 

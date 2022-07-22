drop program cov_gstest2 go
create program cov_gstest2
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/*
select into $outdev
 from clinical_event ce
 where ce.encntr_id =   116690002.00 ;trigger_encntrid
 and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 and ce.result_status_cd in (34.00, 25.00, 35.00)
 
 and c.task_assay_cd = value(uar_get_code_by("DISPLAY", 14003, "SN - CTm - Patient - Out Room Time"))
 order by c.case_time_dt_tm desc
 head report
 if(c.case_time_dt_tm < CNVTLOOKBEHIND("24,H")) log_misc1 = format(c.case_time_dt_tm, 'dd-mmm-yyyy;;q') log_retval = 100 else log_retval = 0 log_message = 'Case Time Within 24 Hours' endif with nullreport go
 
;-----------------------------
select
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val       = "Open Chart"
	and   ce.event_end_dt_tm >= cnvtlookbehind("15,MIN",systimestamp)
	and   ce.verified_prsnl_id = reqinfo->updt_id
head report
	log_message = "Not Open Chart Defer found"
	log_retval = 0
detail
	log_message = concat("Open Chart Defer found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
with nocounter, nullreport go
 
 select into 'nl:'
 from surgical_case s, case_times c
 where s.encntr_id = trigger_encntrid and s.active_ind =1
 and s.surg_case_id = c.surg_case_id
 and c.task_assay_cd = value(uar_get_code_by("DISPLAY", 14003, "SN - CTm - Patient - Out Room Time"))
 order by c.case_time_dt_tm desc
 head report
 if(c.case_time_dt_tm < CNVTLOOKBEHIND("24,H")) log_misc1 = format(c.case_time_dt_tm, 'dd-mmm-yyyy;;q') log_retval = 100 else log_retval = 0 log_message = 'Case Time Within 24 Hours' endif with nullreport go
 
 */
;-----------------------------------------------------------
 
select into $outdev
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.result_val
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, minutes = datetimediff(cnvtdatetime(curdate,curtime3), ce.event_end_dt_tm ,4)
 
from	clinical_event ce
 
plan ce where ce.encntr_id =   116690002.00 ;trigger_encntrid
	and ce.event_cd in(value(uar_get_code_by("DISPLAY",72,"Temperature Oral")))
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 		and ce1.result_status_cd in (34.00, 25.00, 35.00)
		and ce1.event_tag != "Date\Time Correction"
		and cnvtreal(ce1.result_val) >= 38.0
		group by ce1.encntr_id, ce1.event_cd)
		and ce.event_end_dt_tm < CNVTLOOKBEHIND("24,H")
 
with nocounter, separator=" ", format
 
;and datetimediff(cnvtdatetime(curdate,curtime3), cnvtdatetime(ce.event_end_dt_tm) ,4) <= 1440.00
/*
c.case_time_dt_tm < CNVTLOOKBEHIND("24,H")
 
 
     703526.00	Temperature Tympanic
     703530.00	Temperature Rectal
     703535.00	Temperature Axillary
   28214345.00	Temperature Core
     703558.00	Temperature Oral
    2700535.00	Temperature Bladder
    4157752.00	Temperature Temporal Artery
 
 
 
 
 
/*
select into $outdev
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_status_cd
from
	clinical_event ce
plan ce
	where ce.encntr_id = 110455838.00 ;@ENCOUNTERID:1
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-Sepsis Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
	;and   ce.verified_prsnl_id = reqinfo->updt_id
	;and   ce.event_end_dt_tm >= cnvtdatetime("@EVENTENDDTTM:{RA}:1")
 
;with nocounter, seperator = "", format
 
head report
	log_message = "Not Dismiss Value found"
	log_retval = 0
	call echo(build('log_message in Head = ',log_message))
detail
	log_message = concat("Dismiss found on ",format(ce.event_end_dt_tm,";;q"))
	log_retval = 100
	call echo(build('log_message in Detail = ',log_message))
with nocounter, nullreport
 
 
 
end
go
*/
 
;-----------------------------------------------------------------------------------------
/*select into $outdev
c.encntr_id
from clinical_event c
where c.encntr_id =   110363086.00 ;trigger_encntrid
;and c.person_id = trigger_personid
and c.event_cd = value(uar_get_code_by("DISPLAY", 72, "D-VTE Override Recommendation Reason"))
and c.result_val = 'Primary service to address prophylaxis orders'
;and c.performed_prsnl_id = reqinfo->updt_id
 
head report
 
log_retval =0
log_message = 'Override Reason of Primary Service to Address Not Found'
 
detail
 
log_retval = 100
 
if(c.result_val = 'Primary service to address prophylaxis orders')
	log_misc1 = 'Got it'
elseif(c.result_val = 'Primary service orders')
	log_misc1 = 'Primary service orders'
endif
 
 
;log_misc1 = format(c.event_end_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
log_message = concat( 'Override Reason of Primary Service to Address Found from ', log_misc1)
 
call echo(build2(' log_misc1 = ', log_misc1))
 
;with nocounter
with nullreport ;go
 */
;-----------------------------------------------------------------------------------------
 
 
;VTE Scratchpad - Defer Advisor
/*
select into "nl:"
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val
from
	clinical_event ce
plan ce
	;where ce.encntr_id = @ENCOUNTERID:1
	where ce.encntr_id = 116734581
	and   ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"D-VTE Open Chart"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val = "Open Chart"
	and   ce.event_end_dt_tm >= cnvtlookbehind("15,MIN",systimestamp)
	and   ce.verified_prsnl_id = reqinfo->updt_id
 
head report
	log_message = "Open Chart Not Found"
	log_retval = 0
detail
	log_message = build2("Open Chart found on ",format(ce.event_end_dt_tm,";;q"))
	log_misc1 = format(ce.event_end_dt_tm,";;q")
	log_retval = 100
 
foot report
	call echo(build2('log_message = ', log_message));,'-',log_misc1))
	call echo(format(cnvtlookbehind("1,hun",systimestamp),"dd-mmm-yyyy hh.mm.ss.cc;;d"))
	call echo(format(cnvtlookbehind("1,H",systimestamp),"dd-mmm-yyyy hh.mm.ss.cc;;d"))
 
	;, '---', format(ce.event_end_dt_tm,";;q")
with nocounter;, nullreport go
 
;-----------------------------------------------------------------------------------------
 
*/
 
end go

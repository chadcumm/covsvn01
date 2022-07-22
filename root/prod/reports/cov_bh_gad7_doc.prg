/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan'2021
	Solution:			BH
	Source file name:		cov_bh_gad7_doc.prg
	Object name:		cov_bh_gad7_doc
 	Request#:			8782
	Program purpose:
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  Mod Nbr	Mod Date	Developer			Comment
----------------------------------------------------------------------------
 
******************************************************************************/
 
drop program cov_bh_gad7_doc:dba go
create program cov_bh_gad7_doc:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Clinic List" = 0 

with OUTDEV, start_datetime, end_datetime, clinic
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare gad7_severity_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'GAD7 Problem Severity')),protect
declare gad7_score_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'GAD7 Score')),protect
;declare phq9_severity_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Total Severity Score')),protect
;declare phq9_score_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Total Symptom Score')),protect
 
declare max2_eventid_var   = f8
declare opr_clinic_var     = vc with noconstant("")
declare score_var = f8 with noconstant(0.0)
declare severity_var = f8 with noconstant(0.0)
 
;Evaluate and Assign report type
 
;if($repo_type = 1)
	set score_var = gad7_score_var
	set severity_var = gad7_severity_var
;elseif($repo_type = 2)
;	set score_var = phq9_score_var
;	set severity_var = phq9_severity_var
;endif
 
call echo(build2('score_var = ', score_var, '--- -- severity_var = ', severity_var))
 
 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($clinic),0))) = "L");multiple values were selected
	set opr_clinic_var = "in"
elseif(parameter(parameter2($clinic),1)= 0.0) ;all[*] values were selected
	set opr_clinic_var = "!="
else								  ;a single value was selected
	set opr_clinic_var = "="
endif
 
;-------------------------------------------------------------
 
Record scor(
	1 plist[*]
		2 clinic = vc
		2 personid = f8
		2 age = vc
		2 pat_name = vc
		2 initial_score = vc
		2 initial_severity = vc
		2 initial_dt = vc
		2 initial_fin = vc
		2 final_score = vc
		2 final_severity = vc
		2 final_dt = vc
		2 final_fin = vc
)
 
;------------------- Helpers ------------------------------
Record pat(
	1 list[*]
		2 clinic = f8
		2 pat_name = vc
		2 personid = f8
		2 person_max_pri = i4
		2 age = vc
		2 events[*]
			3 encntrid = f8
			3 event = vc
			3 result_value = vc
			3 event_dt = dq8
			3 eventcd = f8
			3 eventid = f8
			3 event_priority = i4
			3 min1_eventid = f8 ;score
			3 min1_fin = vc
			3 min2_eventid = f8 ;severity
			3 min2_fin = vc
			3 max1_eventid = f8
			3 max1_fin = vc
	 )
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Patient pool
select into $outdev
 
loc = uar_get_code_display(e.location_cd)
,fin = ea.alias, e.person_id, e.encntr_id, p.name_full_formatted
,event_dta = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from encounter e
	,person p
	,encntr_alias ea
	,clinical_event ce
 
plan e where operator(e.location_cd, opr_clinic_var, $clinic)
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 	and ce.event_cd in(score_var, severity_var)
 	and ce.event_tag != 'Date\Time Correction'
 	and ce.result_val != ' '
	and ce.result_status_cd in (25,34,35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	/*and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			and ce.event_tag != 'Date\Time Correction'
 			and ce.result_val != ' '
			and ce.result_status_cd in (25,34,35)
			and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
			group by ce1.encntr_id, ce1.event_cd)*/
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join ea where ea.encntr_id = ce.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by ce.person_id, ce.event_id

;with nocounter, separator=" ", format
;go to exitscript

 
Head report
	pcnt = 0
Head ce.person_id
	pcnt += 1
	call alterlist(pat->list, pcnt)
	pat->list[pcnt].clinic = e.loc_facility_cd
	pat->list[pcnt].pat_name = p.name_full_formatted
	pat->list[pcnt].personid = ce.person_id
	pat->list[pcnt].age = cnvtage(p.birth_dt_tm, e.reg_dt_tm,0)
	ecnt = 0
Head ce.event_id
	ecnt += 1
	call alterlist(pat->list[pcnt].events, ecnt)
	pat->list[pcnt].events[ecnt].encntrid = ce.encntr_id
	pat->list[pcnt].events[ecnt].eventcd = ce.event_cd
	pat->list[pcnt].events[ecnt].eventid = ce.event_id
	pat->list[pcnt].events[ecnt].event = event_dta
	pat->list[pcnt].events[ecnt].result_value = ce.result_val
	pat->list[pcnt].events[ecnt].event_dt = ce.event_end_dt_tm
	pat->list[pcnt].events[ecnt].event_priority = ecnt
	if(ce.event_cd = score_var)
		pat->list[pcnt].events[ecnt].min1_fin = fin
		pat->list[pcnt].events[ecnt].min1_eventid = ce.event_id
	elseif(ce.event_cd = severity_var)
		pat->list[pcnt].events[ecnt].min2_fin = fin
		pat->list[pcnt].events[ecnt].min2_eventid = ce.event_id
	endif
 
Foot ce.person_id
	if(pat->list[pcnt].events[ecnt].min2_eventid != 0.0);severity
		pat->list[pcnt].events[ecnt].max1_eventid = pat->list[pcnt].events[ecnt].min2_eventid
		pat->list[pcnt].events[ecnt].max1_fin = pat->list[pcnt].events[ecnt].min2_fin
	elseif(pat->list[pcnt].events[ecnt].min1_eventid != 0.0);score
		pat->list[pcnt].events[ecnt].max1_eventid = pat->list[pcnt].events[ecnt].min1_eventid
		pat->list[pcnt].events[ecnt].max1_fin = pat->list[pcnt].events[ecnt].min1_fin
	endif
 
	pat->list[pcnt].person_max_pri = ecnt
 
with nocounter
 
;call echorecord(pat)
;go to exitscript
 
;----------------------------------------------------------------------
;Assign to Master RS
select into $outdev
	lclinic = pat->list[d1.seq].clinic
	, lpat_name = substring(1, 50, pat->list[d1.seq].pat_name)
	, lpersonid = pat->list[d1.seq].personid
	, lage = substring(1, 3, pat->list[d1.seq].age)
	, lencntrid = pat->list[d1.seq].events[d2.seq].encntrid
	, levent = substring(1, 50, pat->list[d1.seq].events[d2.seq].event)
	, levent_code = pat->list[d1.seq].events[d2.seq].eventcd
	, levent_id = pat->list[d1.seq].events[d2.seq].eventid
	, lresult_value = substring(1, 30, pat->list[d1.seq].events[d2.seq].result_value)
	, levent_dt = pat->list[d1.seq].events[d2.seq].event_dt ';;q'
	, levent_priority = pat->list[d1.seq].events[d2.seq].event_priority
	, lmin1_eventid = pat->list[d1.seq].events[d2.seq].min1_eventid
	, lmin1_fin = substring(1, 10, pat->list[d1.seq].events[d2.seq].min1_fin)
	, lmin2_eventid = pat->list[d1.seq].events[d2.seq].min2_eventid
	, lmin2_fin = substring(1, 10, pat->list[d1.seq].events[d2.seq].min2_fin)
	, lmax1_eventid = pat->list[d1.seq].events[d2.seq].max1_eventid
	, lmax1_fin = substring(1, 10, pat->list[d1.seq].events[d2.seq].max1_fin)
	, lperson_max_pri = pat->list[d1.seq].person_max_pri
 
FROM
	(dummyt   d1  with seq = size(pat->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(pat->list[d1.seq].events, 5))
join d2
 
order by lclinic, lpersonid, levent_priority
 
;with nocounter, separator=" ", format
;go to exitscript

Head report
	cnt = 0
Head lpersonid
	cnt += 1
	call alterlist(scor->plist, cnt)
	scor->plist[cnt].clinic = uar_get_code_display(lclinic)
	scor->plist[cnt].pat_name = lpat_name
	scor->plist[cnt].personid = lpersonid
	scor->plist[cnt].age = lage
	if(lperson_max_pri = 1)
		max2_eventid_var = lperson_max_pri
	else
		max2_eventid_var = lperson_max_pri - 1
	endif
 
Head levent_priority
	;Initial Score
		call echo(build2(lpersonid,'Initial Score - levent_priority = ', levent_priority,
		'--levent_id = ',levent_id,'--lmin1_eventid = ',lmin1_eventid,'-- score_var = ',score_var))

	if(levent_id = lmin1_eventid and levent_code = score_var and levent_priority = 1)
		call echo('inside1') 
		scor->plist[cnt].initial_score = trim(lresult_value)
		scor->plist[cnt].initial_dt = format(levent_dt, 'mm/dd/yyyy hh:mm:ss ;;d')
		scor->plist[cnt].initial_fin = lmin1_fin
	elseif(levent_id = lmin2_eventid and levent_code = severity_var and(levent_priority = 1 or levent_priority = 2))
		;call echo(build(' in test - lmin2_eventid = ', lmin2_eventid, '--result = ',lresult_value))
		scor->plist[cnt].initial_severity = trim(lresult_value)
		if(scor->plist[cnt].initial_dt = ' ' and scor->plist[cnt].initial_severity != ' ')
			scor->plist[cnt].initial_dt = format(levent_dt, 'mm/dd/yyyy hh:mm:ss ;;d')
		endif
		if(scor->plist[cnt].initial_fin = ' ' and scor->plist[cnt].initial_severity != ' ')
			scor->plist[cnt].initial_fin = lmin2_fin
		endif
	endif
 
	;Final Score
		call echo(build2(lpersonid,'Final Score - levent_priority = ', levent_priority,
		'--max2_eventid_var = ',max2_eventid_var,'--levent_code = ',levent_code,'-- score_var = ',score_var))

	if((levent_priority = max2_eventid_var or levent_id = lmax1_eventid) and levent_code = score_var)
		call echo('inside final') 
		scor->plist[cnt].final_score = trim(lresult_value)
		scor->plist[cnt].final_dt = format(levent_dt, 'mm/dd/yyyy hh:mm:ss ;;d')
		scor->plist[cnt].final_fin = lmax1_fin
	elseif(levent_id = lmax1_eventid and levent_code = severity_var)
		scor->plist[cnt].final_severity = trim(lresult_value)
		if(scor->plist[cnt].final_dt = ' ' and scor->plist[cnt].final_severity != ' ')
			scor->plist[cnt].final_dt = format(levent_dt, 'mm/dd/yyyy hh:mm:ss ;;d')
		endif
		if(scor->plist[cnt].final_fin = ' ' and scor->plist[cnt].final_severity != ' ')
			scor->plist[cnt].final_fin = lmax1_fin
		endif
	endif
 
with nocounter
 
call echorecord(scor)

;---------------------------------------------------------------------
;Final result
select into $outdev
	repo_type = 'GAD-7' ; if($repo_type = 1) 'GAD-7' else 'PHQ-9' endif
	, clinic = trim(substring(1, 100, scor->plist[d1.seq].clinic))
	, patient_name = trim(substring(1, 70, scor->plist[d1.seq].pat_name))
	, age = trim(substring(1, 3, scor->plist[d1.seq].age))
	;, person_id =  scor->plist[d1.seq].personid
	, initial_result_fin = trim(substring(1, 20, scor->plist[d1.seq].initial_fin))
	, initial_score = trim(substring(1, 3, scor->plist[d1.seq].initial_score))
	, initial_severity = trim(substring(1, 50, scor->plist[d1.seq].initial_severity))
	, initial_result_dt = trim(substring(1, 30, scor->plist[d1.seq].initial_dt))
	, final_result_fin = trim(substring(1, 20, scor->plist[d1.seq].final_fin))
	, final_score = trim(substring(1, 5, scor->plist[d1.seq].final_score))
	, final_severity = trim(substring(1, 50, scor->plist[d1.seq].final_severity))
	, final_result_dt = trim(substring(1, 30, scor->plist[d1.seq].final_dt))
 
from
	(dummyt   d1  with seq = size(scor->plist, 5))
 
plan d1
 
order by clinic, patient_name
 
with nocounter, separator=" ", format
 
 
;---------------------------------------------------------------------
 
 
#exitscript
 
end go
 
 
/*
 
SELECT cv1.code_value,CV1.DISPLAY, CV1.DESCRIPTION, CV1.CDF_MEANING
from   CODE_VALUE   CV1
WHERE CV1.DISPLAY like 'PB*' ;change to match what you are looking for
AND   CV1.ACTIVE_IND = 1
AND   CV1.CODE_SET = 220
AND   CV1.CDF_MEANING IN ('BUILDING', 'FACILITY','NURSEUNIT', 'AMBULATORY')
 
 
 2553766251.00	PBB BCG	PBB BLOUNT CLINIC
 2553766283.00	PBLH KCG	PBLH KNOX CLINIC
 2553766299.00	PBL LCG	PBL LOUDON CLINIC
 2553766315.00	PBS SOG	PBS SEVIER CLINIC
 
*/

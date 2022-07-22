 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Sep'2020
	Solution:			Quality
	Source file name:	      cov_phq_cvl_activity.prg
	Object name:		cov_phq_cvl_activity
	Request#:			8510
	Program purpose:	      Corporate Team - Analysis
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_cvl_activity:dba go
create program cov_phq_cvl_activity:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, acute_facility_list, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare cvl_activity_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Central Line Activity.')), protect
declare art_type_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Arteriovenous Access Type:')), protect
declare cvl_type_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Central Line Access Type')), protect
 
declare opr_facility_var = vc with noconstant("")
declare cnt = i4
declare tmp = i4
 
;Set Facility variable
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "L");multiple values were selected
	set opr_facility_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0) ;all[*] values were selected
	set opr_facility_var = "!="
else				  ;a single value was selected
	set opr_facility_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record tube(
	1 plist[*]
		2 facility = vc
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_name = vc
		2 cvl_activity[*]
			3 eventid = f8
			3 event_name = vc
			3 result_val = vc
			3 event_date = dq8
			3 nurse_unit_cd = f8
			3 nurse_unit = vc
			3 nurse_unit_eliminated = vc
			3 result_time_6_1659 = vc
			3 result_time_17_559 = vc
		2 cvl_type[*]
			3 eventid = f8
			3 event_name = vc
			3 result_val = vc
			3 event_date = dq8
		2 arteri_type[*]
			3 eventid = f8
			3 event_name = vc
			3 result_val = vc
			3 event_date = dq8

	)
 
;-------------------------------------------------------------------------------------------------
;Central line activity - population
select into $outdev
 
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val
,event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,hour = datetimepart(cnvtdatetime(ce.event_end_dt_tm),4)
,minute = datetimepart(cnvtdatetime(ce.event_end_dt_tm),5)
 
from encounter e
	,clinical_event ce
 
plan e where operator(e.loc_facility_cd, opr_facility_var, $acute_facility_list)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd = cvl_activity_var
	and cnvtlower(ce.result_val) = 'insert'
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
order by ce.encntr_id, ce.event_id
 
Head Report
	cnt = 0
Head ce.encntr_id
	cnt += 1
	call alterlist(tube->plist, cnt)
	tube->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	tube->plist[cnt].encntrid = e.encntr_id
	tube->plist[cnt].personid = e.person_id
	ecnt = 0
Head ce.event_id
	ecnt += 1
	call alterlist(tube->plist[cnt].cvl_activity, ecnt)
Detail
	tube->plist[cnt].cvl_activity[ecnt].event_name = event
	tube->plist[cnt].cvl_activity[ecnt].eventid = ce.event_id
	tube->plist[cnt].cvl_activity[ecnt].result_val = trim(ce.result_val)
	tube->plist[cnt].cvl_activity[ecnt].event_date = ce.event_end_dt_tm
	tube->plist[cnt].cvl_activity[ecnt].result_time_6_1659 =
		if(hour >= 6)
			if(hour <= 16 and minute <= 59) event_dt else ' ' endif
		endif
	tube->plist[cnt].cvl_activity[ecnt].result_time_17_559 = if(hour >= 17 or hour <= 5) event_dt else ' ' endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Arteriovenous Access Type

select into $outdev
 
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val
,event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from (dummyt d1 with seq = size(tube->plist, 5))
	,clinical_event ce
 
plan d1
 
join ce where ce.encntr_id = tube->plist[d1.seq].encntrid
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd = art_type_var
	and cnvtlower(ce.result_val) = 'double lumen catheter'
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
order by ce.encntr_id, ce.event_id

;with nocounter, separator=" ", format
 
Head ce.encntr_id
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist, 5) ,ce.encntr_id ,tube->plist[num].encntrid)
	ecnt = 0
Head ce.event_id
	if(idx > 0)
		ecnt += 1
		call alterlist(tube->plist[idx].arteri_type, ecnt)
		tube->plist[idx].arteri_type[ecnt].event_name = event
		tube->plist[idx].arteri_type[ecnt].eventid = ce.event_id
		tube->plist[idx].arteri_type[ecnt].result_val = trim(ce.result_val)
		tube->plist[idx].arteri_type[ecnt].event_date = ce.event_end_dt_tm
	endif		
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Central Line Access Type
select into $outdev
 
enc = tube->plist[d1.seq].encntrid
, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_id
,event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')

from (dummyt d1 with seq = size(tube->plist, 5))
	,clinical_event ce
 
plan d1

join ce where ce.encntr_id = tube->plist[d1.seq].encntrid
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd = cvl_type_var
	and cnvtlower(ce.result_val) != 'peripherally inserted central catheter (picc)*'
	and cnvtlower(ce.result_val) != 'non-tunneled dialysis'
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
order by enc, ce.event_id

Head enc
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist, 5) ,enc ,tube->plist[num].encntrid)
	ecnt = 0
Head ce.event_id
	if(idx > 0)
		ecnt += 1
		call alterlist(tube->plist[idx].cvl_type, ecnt)
		tube->plist[idx].cvl_type[ecnt].event_name = event
		tube->plist[idx].cvl_type[ecnt].eventid = ce.event_id
		tube->plist[idx].cvl_type[ecnt].result_val = trim(ce.result_val)
		tube->plist[idx].cvl_type[ecnt].event_date = ce.event_end_dt_tm
	endif	
with nocounter
 
;-----------------------------------------------------------------------------------------------------
;Get Fin
select into $outdev
 
from (dummyt d1 with seq = size(tube->plist, 5))
	,encntr_alias ea
 
plan d1
 
join ea where ea.encntr_id = tube->plist[d1.seq].encntrid
	and ea.encntr_alias_type_cd =	1077
	and ea.active_ind = 1
 
order by ea.encntr_id
 
Head ea.encntr_id
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist, 5) ,ea.encntr_id ,tube->plist[num].encntrid)
	if(idx > 0)
		tube->plist[idx].fin = trim(ea.alias)
	endif
with nocounter
 
;-----------------------------------------------------------------------------------------------------
;Encounter location/Nurse unit
select into $outdev
 
encntrid = tube->plist[d1.seq].encntrid
,event_id = tube->plist[d1.seq].cvl_activity[d2.seq].eventid
,event_dt = tube->plist[d1.seq].cvl_activity[d2.seq].event_date "@SHORTDATETIME"
,nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,beg = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME"
 
from (dummyt d1 with seq = size(tube->plist, 5))
	,(dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(tube->plist[d1.seq].cvl_activity, 5))
join d2
 
join elh where elh.encntr_id = tube->plist[d1.seq].encntrid
	and (cnvtdatetime(tube->plist[d1.seq].cvl_activity[d2.seq].event_date)
		between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, event_id
 
Head event_id
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist[d1.seq].cvl_activity, 5) ,event_id ,tube->plist[d1.seq].cvl_activity.eventid)
	if(idx > 0)
		tube->plist[d1.seq].cvl_activity[num].nurse_unit_cd = elh.loc_nurse_unit_cd
		tube->plist[d1.seq].cvl_activity[num].nurse_unit = uar_get_code_description(elh.loc_nurse_unit_cd)
	endif
with nocounter
 
;---------------------------------------------------------------------------------------------------------------------
;Eliminate/Flag ED and Surgery units
select into $outdev
 
 enc = tube->plist[d1.seq].encntrid
, event_id = tube->plist[d1.seq].cvl_activity[d2.seq].eventid
, nurse_unit = substring(1, 50, tube->plist[d1.seq].cvl_activity[d2.seq].nurse_unit)
 
from
	(dummyt   d1  with seq = size(tube->plist, 5))
	, (dummyt   d2  with seq = 1)
	, code_value cv1
 
plan d1 where maxrec(d2, size(tube->plist[d1.seq].cvl_activity, 5))
 
join d2
 
join cv1 where cv1.code_value = tube->plist[d1.seq].cvl_activity[d2.seq].nurse_unit_cd
		and cv1.code_set =  220 and cv1.active_ind = 1
		and(cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*EMERGENCY DEPARTMENT*')
		and cnvtupper(cv1.cdf_meaning) in('NURSEUNIT', 'AMBULATORY')
 
order by event_id
 
Head event_id
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist[d1.seq].cvl_activity, 5) ,event_id ,tube->plist[d1.seq].cvl_activity[num].eventid)
	if(idx > 0)
		tube->plist[d1.seq].cvl_activity[num].nurse_unit_eliminated = '*'
	endif
with nocounter
 
call echorecord(tube)
 
;----------------------------------------------------------------------------------------------------------------------
 
select into $outdev

	facility = trim(substring(1, 30, tube->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, tube->plist[d1.seq].fin))
	, nurse_unit = trim(substring(1, 50, tube->plist[d1.seq].cvl_activity[d2.seq].nurse_unit))
	, cvl_type = substring(1, 100, tube->plist[d1.seq].cvl_type[d3.seq].result_val)
	, central_line_activity = trim(substring(1, 100, tube->plist[d1.seq].cvl_activity[d2.seq].result_val))
	, result_time_0600_to_1659 = substring(1, 30, tube->plist[d1.seq].cvl_activity[d2.seq].result_time_6_1659)
	, result_time_1700_to_0559 = substring(1, 30, tube->plist[d1.seq].cvl_activity[d2.seq].result_time_17_559)
 
	;, event_date = format(tube->plist[d1.seq].cvl_activity[d2.seq].event_date,'mm/dd/yyyy hh:mm:ss;;q')
	;, enc = tube->plist[d1.seq].encntrid
	;, eventid = tube->plist[d1.seq].cvl_activity[d2.seq].eventid
	
	;No data so leaving this off as per Lori's inst.
	;, arteri_type_result_val = substring(1, 30, tube->plist[d1.seq].arteri_type[d4.seq].result_val)

from
	(dummyt   d1  with seq = size(tube->plist, 5))
	, (dummyt   d2  with seq = 1)
	, (dummyt   d3  with seq = 1)
	;, (dummyt   d4  with seq = 1)

plan d1 where maxrec(d2, size(tube->plist[d1.seq].cvl_activity, 5))
	and tube->plist[d1.seq].facility != 'COV CORP HOSP'
	;and maxrec(d3, size(tube->plist[d1.seq].cvl_type, 5))
	;and maxrec(d4, size(tube->plist[d1.seq].arteri_type, 5))
	
join d2 where tube->plist[d1.seq].cvl_activity[d2.seq].nurse_unit_eliminated = ' '

join d3 
;join d4

with nocounter, separator=" ", format

 
 
 
 
#exitscript
 
 
end
go
 
 
;---------------------------------------------------------------------------------------------------
/*
SELECT
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
	,CV1.DISPLAY_KEY
	,CV1.CKI
	,CV1.DEFINITION
 FROM CODE_VALUE CV1
 
WHERE CV1.CODE_SET =  220 AND CV1.ACTIVE_IND = 1
and(cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*EMERGENCY DEPARTMENT*')
;and cnvtupper(cv1.display) = '*ED'
and CV1.CDF_MEANING in('NURSEUNIT', 'AMBULATORY')
WITH  FORMAT, TIME = 60
 
 
/*
join d2 where tube->plist[d1.seq].event[d2.seq].nurse_unit_cd not in(28170721.00 , 2553912779.00
		 , 2553913483.00 , 2553913493.00, 2553913757.00 , 2554024621.00 , 2552516661.00 ,32012115.00
		 , 2556758093.00 , 2556760437.00, 2556761187.00 , 2557552253.00 , 2552516785.00
		 , 2557555261.00 , 2552516941.00)
		;'FSR ED','MMC ED','MMC EB','RMC ED','RMC EB','LCMC ED','FLMC EB','FSR EB',
		;'FLMC ED','PW EB','PW ED','LCMC EB','MHHS EB','MHHS ED','ED'
 
 
 
 
;---------------------------------------------------------------------------------------------------
 

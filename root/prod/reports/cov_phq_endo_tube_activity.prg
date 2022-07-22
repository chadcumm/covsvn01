/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Sep'2020
	Solution:			Quality
	Source file name:	      cov_phq_endo_tube_activity.prg
	Object name:		cov_phq_endo_tube_activity
	Request#:			8509
	Program purpose:	      Corporate Team - Analysis
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_endo_tube_activity:dba go
create program cov_phq_endo_tube_activity:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, acute_facility_list, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

;Intubation 
declare endo_tube_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Endotracheal Tube Activity:')), protect
declare ventilator_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Ventilator Activity')), protect

;RRT DTA's
declare arrival_time_res_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Arrival Time Rapid Response')), protect
declare staff_concrn_res_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Staff Concern Rapid Response')), protect
declare interven_res_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Interventions Rapid Response')), protect
declare bld_gluco_interven_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Blood Glucose Interventions')), protect
declare code_blue_called_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Code Blue Called Rapid Response')), protect
declare pat_dispo_res_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Patient Disposition Rapid Response')), protect
declare depart_time_res_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Departure Time Rapid Response')), protect
declare rrt_nurse_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, 'RRT Nurse')), protect
declare rrt_provider_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, 'RRT Provider')), protect
declare rrt_therapist_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'RRT Respiratory Therapist')), protect
declare provider_note_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Provider Notification Reason')), protect

declare opr_facility_var = vc with noconstant("")
declare temp_var = i4 with noconstant(0)
declare cnt = i4 with noconstant(0)
declare rcnt = i4 with noconstant(0)
 
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
		2 event_cnt = i4
		2 event[*]
			3 eventid = f8
			3 event_name = vc
			3 result_val = vc
			3 event_date = dq8
			3 nurse_unit_cd = f8
			3 nurse_unit = vc
			3 rrt_flag = vc
			3 rrt_location = vc
			3 nurse_unit_eliminated = vc
			3 result_time_6_1659 = vc
			3 result_time_17_559 = vc
	)
 
Record rrt(
	1 rrt_cnt = i4
	1 plist[*]
		2 rrt_fin = vc
		2 rrt_facility = vc
		2 rrt_encntrid = f8
		2 rrt_called_dt = dq8
		2 rrt_location = vc
	)
 
 
;-------------------------------------------------------------------------------------------------
;Intubation Patient Population
select into $outdev
 
e.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val
,event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,hour = datetimepart(cnvtdatetime(ce.event_end_dt_tm),4)
,minute = datetimepart(cnvtdatetime(ce.event_end_dt_tm),5)
 
from encounter e
	,encntr_alias ea
	,clinical_event ce
 
plan e where operator(e.loc_facility_cd, opr_facility_var, $acute_facility_list)
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd =	1077
	and ea.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd in(endo_tube_var, ventilator_var)
	and cnvtlower(ce.result_val) in('intubated', 'reintubated', 'ventilator initiate')
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
order by ce.encntr_id, ce.event_id
 
Head Report
	cnt = 0
Head ce.encntr_id
	cnt += 1
	call alterlist(tube->plist, cnt)
	tube->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	tube->plist[cnt].fin = ea.alias
	tube->plist[cnt].encntrid = e.encntr_id
	tube->plist[cnt].personid = e.person_id
	ecnt = 0
Head ce.event_id
	ecnt += 1
	tube->plist[cnt].event_cnt = ecnt
	call alterlist(tube->plist[cnt].event, ecnt)
Detail
	tube->plist[cnt].event[ecnt].event_name = event
	tube->plist[cnt].event[ecnt].eventid = ce.event_id
	tube->plist[cnt].event[ecnt].result_val = trim(ce.result_val)
	tube->plist[cnt].event[ecnt].event_date = ce.event_end_dt_tm
	tube->plist[cnt].event[ecnt].result_time_6_1659 =
		if(hour >= 6)
			if(hour <= 16 and minute <= 59) event_dt else ' ' endif
		endif
	tube->plist[cnt].event[ecnt].result_time_17_559 = if(hour >= 17 or hour <= 5) event_dt else ' ' endif
 
with nocounter

;==========================  RRT Start ==========================================================================
;RRT patient population
select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
, pat_loc = build2(trim(uar_get_code_display(e.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(e.loc_room_cd)),'; ', trim(uar_get_code_display(e.loc_bed_cd)))
 
from  encounter e
	,clinical_event ce
	, ce_date_result cdr
 
plan e where operator(e.loc_facility_cd, opr_facility_var, $acute_facility_list)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_cd in(arrival_time_res_var, staff_concrn_res_var, code_blue_called_var
		,pat_dispo_res_var, depart_time_res_var, rrt_nurse_var, rrt_provider_var, rrt_therapist_var)
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
	and cdr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head report
	rr_cnt = 0
Head ce.encntr_id
	rr_cnt += 1
	rrt->rrt_cnt = rr_cnt
	call alterlist(rrt->plist, rr_cnt)
	rrt->plist[rr_cnt].rrt_encntrid = ce.encntr_id
	rrt->plist[rr_cnt].rrt_facility = uar_get_code_display(e.loc_facility_cd)
	
with nocounter

;---------------------------------------------------------------------------------------------------------
;Get other RRT clinical events - RRT team activation
select into 'nl:'
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from (dummyt d WITH seq = value(size(rrt->plist,5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = rrt->plist[d.seq].rrt_encntrid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = provider_note_var
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	intervention = fillstring(1000," ")
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,rrt->rrt_cnt ,ce.encntr_id ,rrt->plist[icnt].rrt_encntrid)
 
Detail
      if(idx > 0)
		if(ce.result_val = 'Rapid response team/medical emergency team activation')
			rrt->plist[idx].rrt_called_dt = ce.event_end_dt_tm
		endif
	endif

with nocounter

;---------------------------------------------------------------------------------------------------------
;Patient location at time of RRT called
select into 'nl:'
 
elh.encntr_id, beg = format(elh.beg_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, en = format(elh.end_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, rrt_called_dt = format(rrt->plist[d.seq].rrt_called_dt, 'mm/dd/yyyy hh:mm;;d')
, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = rrt->rrt_cnt)
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = rrt->plist[d.seq].rrt_encntrid
	and (cnvtdatetime(rrt->plist[d.seq].rrt_called_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id
 
Head elh.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,rrt->rrt_cnt ,elh.encntr_id ,rrt->plist[cnt].rrt_encntrid)
	if(idx > 0)
		rrt->plist[idx].rrt_location = pat_loc
 	endif
 
with nocounter

;---------------------------------------------------------------------------------------------------------
;Get intubation charting for RRT patients
select into $outdev

rrt_enc = rrt->plist[d1.seq].rrt_encntrid, fac = rrt->plist[d1.seq].rrt_facility
,rrt_loc = rrt->plist[d1.seq].rrt_location
,ce.event_id,event = uar_get_code_display(ce.event_cd), ce.result_val
,event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,hour = datetimepart(cnvtdatetime(ce.event_end_dt_tm),4)
,minute = datetimepart(cnvtdatetime(ce.event_end_dt_tm),5)

from (dummyt d1 with seq = rrt->rrt_cnt) 
	,encntr_alias ea
	,encounter e
	,clinical_event ce
 
plan d1
 
join e where e.encntr_id = rrt->plist[d1.seq].rrt_encntrid
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd =	1077
	and ea.active_ind = 1
 
join ce where ce.encntr_id = ea.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd in(endo_tube_var, ventilator_var)
	and cnvtlower(ce.result_val) in('intubated', 'reintubated', 'ventilator initiate')
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
order by ce.encntr_id, ce.event_id

;with nocounter, separator=" ", format

Head ce.encntr_id
	enum = 0
	eidx = 0
      eidx = locateval(enum ,1 ,size(tube->plist, 5),ce.encntr_id ,tube->plist[enum].encntrid)
Head ce.event_id
	ecnt = 0
	if(eidx = 0) ;No existing encounter
		cnt += 1
		call alterlist(tube->plist, cnt)
		tube->plist[cnt].facility = fac
		tube->plist[cnt].fin = trim(ea.alias)
		tube->plist[cnt].encntrid = ce.encntr_id
		tube->plist[cnt].personid = ce.person_id
		ecnt += 1
		call alterlist(tube->plist[cnt].event, ecnt)
		tube->plist[cnt].event[ecnt].rrt_flag = 'Yes'
		tube->plist[cnt].event[ecnt].rrt_location = rrt_loc
		tube->plist[cnt].event[ecnt].event_name = event
		tube->plist[cnt].event[ecnt].eventid = ce.event_id
		tube->plist[cnt].event[ecnt].result_val = trim(ce.result_val)
		tube->plist[cnt].event[ecnt].event_date = ce.event_end_dt_tm
		tube->plist[cnt].event[ecnt].result_time_6_1659 =
			if(hour >= 6)
				if(hour <= 16 and minute <= 59) event_dt else ' ' endif
			endif
		tube->plist[cnt].event[ecnt].result_time_17_559 = if(hour >= 17 or hour <= 5) event_dt else ' ' endif
		
	else; there is an existing encounter (eidx > 0)
		ecnt = tube->plist[enum].event_cnt
		num = 0
		idx = 0
	      idx = locateval(num ,1 ,size(tube->plist[eidx].event, 5),ce.event_id ,tube->plist[eidx].event[num].eventid)
		if(idx = 0)
			ecnt += 1
			call alterlist(tube->plist[eidx].event, ecnt)
			tube->plist[eidx].event[ecnt].rrt_flag = 'Yes'
			tube->plist[eidx].event[ecnt].rrt_location = rrt_loc
			tube->plist[eidx].event[ecnt].event_name = event
			tube->plist[eidx].event[ecnt].eventid = ce.event_id
			tube->plist[eidx].event[ecnt].result_val = trim(ce.result_val)
			tube->plist[eidx].event[ecnt].event_date = ce.event_end_dt_tm
			tube->plist[eidx].event[ecnt].result_time_6_1659 =
				if(hour >= 6)
					if(hour <= 16 and minute <= 59) event_dt else ' ' endif
				endif
			tube->plist[eidx].event[ecnt].result_time_17_559 = if(hour >= 17 or hour <= 5) event_dt else ' ' endif
		else
			tube->plist[eidx].event[idx].rrt_flag = 'Yes'
			tube->plist[eidx].event[idx].rrt_location = rrt_loc
		endif	
	endif

with nocounter

;call echorecord(tube)

;go to exitscript

 
;=============================  RRT End ======================================================================

;Encounter location/Nurse unit
select into $outdev
 
encntrid = tube->plist[d1.seq].encntrid
,event_id = tube->plist[d1.seq].event[d2.seq].eventid
,event_dt = tube->plist[d1.seq].event[d2.seq].event_date "@SHORTDATETIME"
,nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,beg = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME"
 
from (dummyt d1 with seq = size(tube->plist, 5))
	,(dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(tube->plist[d1.seq].event, 5))
join d2
 
join elh where elh.encntr_id = tube->plist[d1.seq].encntrid
	and (cnvtdatetime(tube->plist[d1.seq].event[d2.seq].event_date)
		between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, event_id
 
Head event_id
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist[d1.seq].event, 5) ,event_id ,tube->plist[d1.seq].event[num].eventid)
	if(idx > 0)
		tube->plist[d1.seq].event[num].nurse_unit_cd = elh.loc_nurse_unit_cd
		tube->plist[d1.seq].event[num].nurse_unit = uar_get_code_description(elh.loc_nurse_unit_cd)
	endif
with nocounter

;---------------------------------------------------------------------------------------------------------------
;Eliminate ED and Surgery units

select into $outdev
 
 enc = tube->plist[d1.seq].encntrid
, event_id = tube->plist[d1.seq].event[d2.seq].eventid
, nurse_unit = substring(1, 50, tube->plist[d1.seq].event[d2.seq].nurse_unit)
 
from
	(dummyt   d1  with seq = size(tube->plist, 5))
	, (dummyt   d2  with seq = 1)
	, code_value cv1
 
plan d1 where maxrec(d2, size(tube->plist[d1.seq].event, 5))
 
join d2
 
join cv1 where cv1.code_value = tube->plist[d1.seq].event[d2.seq].nurse_unit_cd
	and tube->plist[d1.seq].event[d2.seq].rrt_flag != 'Yes'
	and cv1.code_set =  220 and cv1.active_ind = 1
	and(cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*EMERGENCY DEPARTMENT*')
	and cnvtupper(cv1.cdf_meaning) in('NURSEUNIT', 'AMBULATORY')
 
order by event_id
 
Head event_id
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(tube->plist[d1.seq].event, 5) ,event_id ,tube->plist[d1.seq].event[num].eventid)
	if(idx > 0)
		tube->plist[d1.seq].event[num].nurse_unit_eliminated = '*'
	endif
with nocounter
 
call echorecord(tube)
 
 
;----------------------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = trim(substring(1, 30, tube->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, tube->plist[d1.seq].fin))
	, nurse_unit = trim(substring(1, 50, tube->plist[d1.seq].event[d2.seq].nurse_unit))
	, RRT_flag = trim(substring(1, 3, tube->plist[d1.seq].event[d2.seq].rrt_flag))
	, event_name = trim(substring(1, 100, tube->plist[d1.seq].event[d2.seq].event_name))
	, event_result = trim(substring(1, 30, tube->plist[d1.seq].event[d2.seq].result_val))
	, result_time_0600_to_1659 = substring(1, 30, tube->plist[d1.seq].event[d2.seq].result_time_6_1659)
	, result_time_1700_to_0559 = substring(1, 30, tube->plist[d1.seq].event[d2.seq].result_time_17_559)

	;, RRT_location = trim(substring(1, 50, tube->plist[d1.seq].event[d2.seq].rrt_location))
		;comment out as no data found - 09/28/20
	;, event_date = format(tube->plist[d1.seq].event[d2.seq].event_date,'mm/dd/yyyy hh:mm:ss;;q')
	;, enc = tube->plist[d1.seq].encntrid
	;, eventid = tube->plist[d1.seq].event[d2.seq].eventid
 
from
	(dummyt   d1  with seq = size(tube->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(tube->plist[d1.seq].event, 5))
	and tube->plist[d1.seq].facility != 'COV CORP HOSP'
 
join d2 where tube->plist[d1.seq].event[d2.seq].nurse_unit_eliminated = ' '
 
order by facility, fin, tube->plist[d1.seq].event[d2.seq].event_date
 
with nocounter, separator=" ", format
 
#exitscript
 
 
end
go
 
 
;---------------------------------------------------------------------------------------------------
 

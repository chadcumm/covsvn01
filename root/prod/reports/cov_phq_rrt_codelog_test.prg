/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jul'2019
	Solution:			Quality
	Source file name:	      cov_phq_rrt_codelog.prg
	Object name:		cov_phq_rrt_codelog
	Request#:			1200
	Program purpose:		Rapid Response(RRT) code log
	Executing from:		DA2
 	Special Notes:		Report No.1 (spec have 3 reports)
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
--------------------------------------------------------------------------------------------------------------------------------
Apr'28	Geetha CR# 7538 - The Cov Stroke Rapid Response and the Cov Rapid Response Reports are not capturing pts.
				Resolution - removed the qual based on 'Provider Notification Reason'. Added new qual based on
				all RRT DTA's.
10-12-21    Geetha CR# 11340 - Provider Notification reason DTA added as a different section of the patient pool 
06-17-22    Geetha CR# 13009 - New column to identify if code blue occured within 1hr from arrival to the unit.
********************************************************************************************************************************/
 
drop program cov_phq_rrt_codelog_test:dba go
create program cov_phq_rrt_codelog_test:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
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
declare rapid_risk_score_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Rapid Response Risk Score')), protect
declare provider_note_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Provider Notification Reason')), protect
declare pre_assess_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Pre-assessment Performed')), protect
declare 12hr_post_assess_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, '12 hr. Post-assessment Performed')), protect
declare 24hr_post_assess_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, '24 hr. Post-assessment Performed')), protect
declare 48hr_post_assess_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, '48 hr. Post-assessment Performed')), protect
 
declare admit_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Admitting Physician')), protect
declare atten_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Attending Physician')), protect

declare staff_concrn = vc with noconstant(' '),public
declare code_blue = vc with noconstant(' '),public
declare pat_disposition  = vc with noconstant(' '),public
declare idx = i4 with noconstant(0),public
declare cnt = i4 with noconstant(0),public


/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record rapid(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 encntrid = f8
		2 personid = f8
		2 fin = vc
		2 pat_name = vc
		2 pat_age = vc
		2 admit_md = vc
		2 pat_rrt_location = vc
		2 eventid = f8
		2 rrt_provider_notify = vc
		2 rrt_called_dt = dq8
		2 arrival_time_res = vc
		2 arrival_time_res_dq8 = dq8
		2 staff_concrn_res = vc
		2 code_blue_provider_notify = vc
		2 code_blue_notify_dt = dq8
		2 code_blue_called = vc
		2 pat_dispo_res = vc
		2 depart_time_res = vc
		2 rrt_nurse = vc
		2 rrt_provider = vc
		2 rrt_therapist = vc
		2 recent_risk_score = vc
		2 recent_risk_score_dt = vc
		2 risk_score_before_rrt = vc
		2 risk_score_before_rrt_dt = vc
		2 pre_assessment_dt = vc
		2 12hr_post_assess_dt = vc
		2 24hr_post_assess_dt = vc
		2 48hr_post_assess_dt = vc
		2 intervention_rrt = vc
		2 unit_beg_time = dq8
		2 unit_end_time = dq8
		2 code_blue_1hr = vc
)
 

;------------------------------------------------------------------------------------------------------------
;Qualify patient population - RRT activation

select into 'nl:'
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
, pat_loc = build2(trim(uar_get_code_display(e.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(e.loc_room_cd)),'; ', trim(uar_get_code_display(e.loc_bed_cd)))
 
from  encounter e
	,clinical_event ce
	, ce_date_result cdr
 
plan e where e.loc_facility_cd = $acute_facility_list
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
	cnt = 0
Head e.encntr_id
	cnt += 1
	rapid->rec_cnt = cnt
	call alterlist(rapid->plist, cnt)
	rapid->plist[cnt].personid = e.person_id
	rapid->plist[cnt].encntrid = e.encntr_id
	rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	rapid->plist[cnt].pat_rrt_location = pat_loc ;set default location
	staff_concrn = fillstring(1000," "), code_blue = fillstring(1000," "),pat_disposition = fillstring(1000," ")
Detail
	case(ce.event_cd)
		of arrival_time_res_var:
			rapid->plist[cnt].arrival_time_res = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
			rapid->plist[cnt].arrival_time_res_dq8 = cdr.result_dt_tm
		of depart_time_res_var:
			rapid->plist[cnt].depart_time_res = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		of staff_concrn_res_var:
			staff_concrn = build2(trim(staff_concrn),trim(ce.result_val),",", ';')
		of code_blue_called_var:
			code_blue = build2(trim(code_blue),trim(ce.result_val),",", ';')
		of pat_dispo_res_var:
			pat_disposition = build2(trim(pat_disposition),trim(ce.result_val),",", ';')
		of rrt_nurse_var:
			rapid->plist[cnt].rrt_nurse = ce.result_val
		of rrt_provider_var:
			rapid->plist[cnt].rrt_provider = ce.result_val
		of rrt_therapist_var:
			rapid->plist[cnt].rrt_therapist = ce.result_val
	endcase
 
Foot ce.encntr_id
	rapid->plist[cnt].staff_concrn_res = replace(replace(trim(staff_concrn),";","",2),",","",2)
	rapid->plist[cnt].code_blue_called = replace(replace(trim(code_blue),";","",2),",","",2)
	rapid->plist[cnt].pat_dispo_res = replace(replace(trim(pat_disposition),";","",2),",","",2)
Foot report
	call alterlist(rapid->plist, cnt)
 
with nocounter

;-------------------------------------------------------------------------------------
;Provider Notification

select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
, pat_loc = build2(trim(uar_get_code_display(e.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(e.loc_room_cd)),'; ', trim(uar_get_code_display(e.loc_bed_cd)))
 
from  encounter e
	,clinical_event ce
	, ce_date_result cdr
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_cd = provider_note_var
	and ce.result_val = 'Rapid response team/medical emergency team activation'
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
	and cdr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
	if(idx = 0)
		cnt += 1
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		rapid->plist[cnt].pat_rrt_location = pat_loc ;set default location
		rapid->plist[cnt].rrt_provider_notify = trim(ce.result_val)
		rapid->plist[cnt].rrt_called_dt = ce.event_end_dt_tm
	else 
		rapid->plist[idx].rrt_provider_notify = trim(ce.result_val)
		rapid->plist[idx].rrt_called_dt = ce.event_end_dt_tm
	endif	
with nocounter

;-------------------------------------------------------------------------------------
;Get other clinical events
 
select into 'nl:'
 
ce.encntr_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from (dummyt d WITH seq = value(size(rapid->plist,5)))
	, clinical_event ce
	, ce_date_result cdr
 
plan d
 
join ce where ce.encntr_id = rapid->plist[d.seq].encntrid
	and ce.person_id = rapid->plist[d.seq].personid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd in(interven_res_var, pre_assess_var, 12hr_post_assess_var, 24hr_post_assess_var
			,48hr_post_assess_var)
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
	and cdr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	intervention = fillstring(1000," ")
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[cnt].encntrid)
 
Detail
      if(idx > 0)
		case(ce.event_cd)
			of interven_res_var:
				intervention = build2(trim(intervention),trim(ce.result_val),",", ';')
	 		of pre_assess_var:
	 			rapid->plist[idx].pre_assessment_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
			of 12hr_post_assess_var:
				rapid->plist[idx].12hr_post_assess_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
			of 24hr_post_assess_var:
				rapid->plist[idx].24hr_post_assess_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
			of 48hr_post_assess_var:
				rapid->plist[idx].48hr_post_assess_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		endcase
	endif
 
Foot ce.encntr_id
 	rapid->plist[cnt].intervention_rrt = replace(replace(trim(intervention),";","",2),",","",2)
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Get Code Blue documentation
select into 'nl:'
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from	(dummyt d WITH seq = value(size(rapid->plist,5)))
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = rapid->plist[d.seq].encntrid
	and ce.person_id = rapid->plist[d.seq].personid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = provider_note_var
	and ce.result_val = 'Code blue activation'
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[cnt].encntrid)
      if(idx > 0)
      	rapid->plist[idx].code_blue_provider_notify = ce.result_val
      	rapid->plist[idx].code_blue_notify_dt = ce.event_end_dt_tm
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Get rapid risk score - most recent
select into 'nl:'
 
ce.encntr_id, ce.event_cd
, risk_score_date = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from  (dummyt d WITH seq = value(size(rapid->plist,5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = rapid->plist[d.seq].encntrid
	and ce.person_id = rapid->plist[d.seq].personid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = rapid_risk_score_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[cnt].encntrid)
 
      if(idx > 0)
		rapid->plist[idx].recent_risk_score = ce.result_val
		rapid->plist[idx].recent_risk_score_dt = risk_score_date
    	endif
 
Foot ce.encntr_id
    null
 
With nocounter
 
;------------------------------------------------------------------------------------------------------------
;Get rapid risk score - before arrival time.
select into 'nl:'
 
ce.encntr_id, ce.event_cd
, risk_score_date = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from  (dummyt d WITH seq = value(size(rapid->plist,5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = outerjoin(rapid->plist[d.seq].encntrid)
	and ce.person_id = outerjoin(rapid->plist[d.seq].personid)
	and ce.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00" ))
	and ce.view_level = outerjoin(1) ;active
      and ce.publish_flag = outerjoin(1) ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = rapid_risk_score_var
	and (ce.event_end_dt_tm < cnvtdatetime(rapid->plist[d.seq].arrival_time_res))
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[cnt].encntrid)
 
      if(idx > 0)
		rapid->plist[idx].risk_score_before_rrt = ce.result_val
		rapid->plist[idx].risk_score_before_rrt_dt = risk_score_date
    	endif
 
Foot ce.encntr_id
    null
 
With nocounter
 
;----------------------------------------------------------------------------------------------------
;Get demographic info
select into 'nl:'
 
from  (dummyt d WITH seq = value(size(rapid->plist,5)))
	, encntr_alias ea
	, person p
 
plan d
 
join ea where ea.encntr_id = rapid->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = rapid->plist[d.seq].personid
	and p.active_ind = 1
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,ea.encntr_id ,rapid->plist[cnt].encntrid)
       if(idx > 0)
       	rapid->plist[idx].fin = ea.alias
		rapid->plist[idx].pat_name = p.name_full_formatted
		rapid->plist[idx].pat_age = cnvtage(p.birth_dt_tm)
    	endif
 
Foot ea.encntr_id
    null
 
With nocounter
 
;-------------------------------------------------------------------------------------------
;Admitting MD
select into 'nl:'
 
epr.encntr_id, pr.name_full_formatted, epr.encntr_prsnl_r_cd
 
from	(dummyt d WITH seq = value(size(rapid->plist,5)))
	, encntr_prsnl_reltn epr
	, prsnl pr
 
plan d
 
join epr where epr.encntr_id = rapid->plist[d.seq].encntrid
	and epr.active_ind = 1
	and epr.encntr_prsnl_r_cd = admit_phys_var ;atten_phys_var
 
join pr where pr.person_id = outerjoin(epr.prsnl_person_id)
	and pr.active_ind = outerjoin(1)
 
order by epr.encntr_id
 
Head epr.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,epr.encntr_id ,rapid->plist[cnt].encntrid)
	if(idx > 0)
		rapid->plist[idx].admit_md = pr.name_full_formatted
 	endif
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------
;Patient location at time of RRT called
select into 'nl:'
 
elh.encntr_id, beg = format(elh.beg_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, en = format(elh.end_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, rrt_called_dt = format(rapid->plist[d.seq].rrt_called_dt, 'mm/dd/yyyy hh:mm;;d')
, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = value(size(rapid->plist,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = rapid->plist[d.seq].encntrid
	;and (cnvtdatetime(rapid->plist[d.seq].rrt_called_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and (cnvtdatetime(rapid->plist[d.seq].arrival_time_res_dq8) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id
 
Head elh.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,elh.encntr_id ,rapid->plist[cnt].encntrid)
	if(idx > 0)
		rapid->plist[idx].pat_rrt_location = pat_loc ;overwrite the default/admit location
		rapid->plist[idx].unit_beg_time = elh.beg_effective_dt_tm
		rapid->plist[idx].unit_end_time = elh.end_effective_dt_tm
 	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Code blue within 1 hour?

select into $outdev
 
fin_no = trim(substring(1, 10, rapid->plist[d1.seq].fin))
, rrt_dt = format(rapid->plist[d1.seq].arrival_time_res_dq8, 'mm/dd/yy hh:mm:ss;;d')
, pat_unit = rapid->plist[d1.seq].pat_rrt_location
, beg_time = format(rapid->plist[d1.seq].unit_beg_time, 'mm/dd/yy hh:mm:ss;;d')
, end_time = format(rapid->plist[d1.seq].unit_end_time, 'mm/dd/yy hh:mm:ss;;d')
 
from	(dummyt   d1  with seq = size(rapid->plist, 5))
 
plan d1 

order by fin_no, pat_unit, rrt_dt

Head fin_no
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,rapid->rec_cnt ,fin_no ,rapid->plist[icnt].fin)
Head rrt_dt
	if(rapid->plist[d1.seq].arrival_time_res_dq8 != null
			and rapid->plist[d1.seq].code_blue_1hr = ' ' 
			and rapid->plist[d1.seq].pat_rrt_location != ' ' )	

		if(cnvtdatetime(rapid->plist[d1.seq].arrival_time_res_dq8)between rapid->plist[d1.seq].unit_beg_time
			and rapid->plist[d1.seq].unit_end_time
		  )		
		  hr_diff = datetimediff(rapid->plist[d1.seq].arrival_time_res_dq8, rapid->plist[d1.seq].unit_beg_time ,4)				
		endif
	
		if(hr_diff <= 60 or hr_diff = 0)
			rapid->plist[d1.seq].code_blue_1hr = 'Yes'
		endif	
	endif

with nocounter

;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
;go to exitscript
 
;------------------------------------------------------------------------------------------------------------ 
 
call echorecord(rapid)
 
;------------------------------------------------------------------------------------------------------------
 
 select into $outdev
	facility = trim(substring(1, 30, rapid->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, rapid->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, rapid->plist[d1.seq].pat_name))
	, patient_age = trim(substring(1, 5, rapid->plist[d1.seq].pat_age))
	, admitting_md = trim(substring(1, 50, rapid->plist[d1.seq].admit_md))
	, patient_location_rrt = trim(substring(1, 30, rapid->plist[d1.seq].pat_rrt_location))
	, unit_arrival_time = format(rapid->plist[d1.seq].unit_beg_time, 'mm/dd/yyyy hh:mm:ss;;d')
	, rrt_within_1hr = trim(substring(1, 30, rapid->plist[d1.seq].code_blue_1hr))
	, rrt_arrival_dt = trim(substring(1, 30, rapid->plist[d1.seq].arrival_time_res))
	, rrt_depart_dt = trim(substring(1, 30, rapid->plist[d1.seq].depart_time_res))
	, rrt_called_dt = format(rapid->plist[d1.seq].rrt_called_dt, 'mm/dd/yyyy hh:mm:ss;;d')
	, reason_for_rrt = trim(substring(1, 500, rapid->plist[d1.seq].staff_concrn_res))
	, rrt_provider_notification = trim(substring(1, 300, rapid->plist[d1.seq].rrt_provider_notify))
	, intervention_rrt = trim(substring(1, 300, rapid->plist[d1.seq].intervention_rrt))
	, code_blue_provider_notify = trim(substring(1, 300, rapid->plist[d1.seq].code_blue_provider_notify))
	, code_blue_notify_dt = format(rapid->plist[d1.seq].code_blue_notify_dt, 'mm/dd/yyyy hh:mm:ss;;d')
	, code_blue_called_with_rrt = trim(substring(1, 300, rapid->plist[d1.seq].code_blue_called))
	, patient_disposition = trim(substring(1, 300, rapid->plist[d1.seq].pat_dispo_res))
	, rrt_nurse = trim(substring(1, 30, rapid->plist[d1.seq].rrt_nurse))
	, rrt_provider = trim(substring(1, 30, rapid->plist[d1.seq].rrt_provider))
	, rrt_therapist = trim(substring(1, 30, rapid->plist[d1.seq].rrt_therapist))
	, recent_risk_score = trim(substring(1, 30, rapid->plist[d1.seq].recent_risk_score))
	, recent_risk_score_dt = trim(substring(1, 30, rapid->plist[d1.seq].recent_risk_score_dt))
	, risk_score_before_rrt = trim(substring(1, 30, rapid->plist[d1.seq].risk_score_before_rrt))
	, risk_score_before_rrt_dt = trim(substring(1, 30, rapid->plist[d1.seq].risk_score_before_rrt_dt))
	, pre_assessment_dt = trim(substring(1, 30, rapid->plist[d1.seq].pre_assessment_dt))
	, 12hr_post_assess_dt = trim(substring(1, 30, rapid->plist[d1.seq].12hr_post_assess_dt))
	, 24hr_post_assess_dt = trim(substring(1, 30, rapid->plist[d1.seq].24hr_post_assess_dt))
	, 48hr_post_assess_dt = trim(substring(1, 30, rapid->plist[d1.seq].48hr_post_assess_dt))
 
from
	(dummyt   d1  with seq = size(rapid->plist, 5))
 
plan d1
 
order by
	facility
	, patient_name
	, fin
 
with nocounter, separator=" ", format
 
#exitscript
 
end go
 
 

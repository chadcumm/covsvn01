/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Apr'2022
	Solution:			Quality
	Source file name:	      cov_phq_codeblue_neonate.prg
	Object name:		cov_phq_codeblue_neonate
	Request#:			12705
	Program purpose:		Code Blue Rapid Response(RRT)
	Executing from:		DA2
 	Special Notes:		Report No.3 (spec contains 3 reports)
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	----------------------------------------------------------------------------
22/04/22    Geetha     	CR#12705	Initial release
06/16/22    Geetha                  Lori's approval to remove code_notification_time from all code blue reports.
****************************************************************************************************************/
 
 
drop program cov_phq_codeblue_neonate:dba go
create program cov_phq_codeblue_neonate:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare provider_note_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Provider Notification Reason')), protect
declare provider_note_det_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Provider Notification Details')), protect
declare cardio_arrest_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Date, Time of Cardiopulmonary Arrest')), protect
declare resuci_outcome_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Resuscitation Outcome')), protect
declare dispo_after_cardio_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Disposition After Cardiopulmonary Arrest')), protect
declare paper_codeblu_var   	  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Paper Code Blue Record on Chart')), protect
declare admit_phys_var   	  = f8 with constant(uar_get_code_by('DISPLAY', 333,'Admitting Physician')), protect
declare enc_type_var            = f8 with constant(uar_get_code_by('DISPLAY', 71, 'Newborn')), protect
 
;call echo(build('paper_codeblu_var = ', paper_codeblu_var))
 
declare resu_outcome = vc with noconstant(' '),public
declare dispo_cardio = vc with noconstant(' '),public
declare cnt = i4
declare fcnt = i4 with noconstant(0)
declare ecnt_cnt = i4
declare opr_nu_var = vc with noconstant(''), public
declare opr_fac_var = vc with noconstant(''), public
 
 
;Facility variable
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "l");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0) ;all[*] values were selected
	set opr_fac_var = "!="
else									 ;a single value was selected
	set opr_fac_var = "="
endif
 
 /*
;Nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "l");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else									 ;a single value was selected
	set opr_nu_var = "="
endif */
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

Record blue(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 encntrid = f8
		2 personid = f8
		2 fin = vc
		2 admit_unit = f8
		2 pat_name = vc
		2 pat_age = vc
		2 disch_dt = vc
		2 admit_md = vc
		2 disch_dispo = vc
		2 ecnt_cnt = i4
		2 events[*]
			3 event_dt = dq8
			3 code_blue_called_dt = dq8
			3 pat_code_blue_location = vc
			3 code_blue_provider_notify = vc
			3 cardio_arrest_dt = dq8
			3 resuci_outcome = vc
			3 dispo_after_cardio = vc
			3 rrt_prior_code_blue_dt = vc
			3 paper_codeblu = vc
)
 


;------------------ Helpers -------------------------------
Record rapid(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 encntrid = f8
		2 personid = f8
		2 fin = vc
		2 admit_unit = f8
		2 pat_name = vc
		2 pat_age = vc
		2 disch_dt = vc
		2 admit_md = vc
		2 disch_dispo = vc
		2 ecnt_cnt = i4
		2 events[*]
			3 eventcd = f8
			3 eventid = f8
			3 event_dt = dq8
			3 code_blue_provider_notify = vc
			3 code_blue_called_dt = dq8
			3 pat_code_blue_location = vc
			3 cardio_arrest_dt = dq8
			3 resuci_outcome = vc
			3 dispo_after_cardio = vc
			3 rrt_prior_code_blue_dt = vc
			3 paper_codeblu = vc
)
 
 
 
Record unit(
	1 list[*]
		2 unit_cd = f8
		2 unit_des = vc
)
 
;--------------------------------------------------------------------------------------------------------
;Selected units
 
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
 
from nurse_unit nu, location l
 
where l.location_cd = nu.loc_facility_cd
and l.location_cd = $acute_facility_list
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 
order by nurse_unit
 
Head report
	ncnt = 0
Detail
	ncnt += 1
	call alterlist(unit->list, ncnt)
	unit->list[ncnt].unit_cd = nurse_unit_cd
	unit->list[ncnt].unit_des = unit_desc
with nocounter
 
 
;==================================================================================================================
;Qualify Patient Population - Code Blue documentation
 
select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
, ce.event_end_dt_tm, ce.event_id
 
from 	encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	and e.encntr_type_cd = enc_type_var
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
      and ce.publish_flag = 1
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_cd = provider_note_var
	and cnvtlower(ce.result_val) = 'code blue activation'
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head report
	cnt = 0
Head ce.encntr_id
	cnt += 1
	rapid->rec_cnt = cnt
	call alterlist(rapid->plist, cnt)
	rapid->plist[cnt].personid = e.person_id
	rapid->plist[cnt].encntrid = e.encntr_id
	rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
	rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	rapid->plist[cnt].admit_unit = e.loc_nurse_unit_cd
	rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
	ecnt = 0
Head ce.event_id
	ecnt += 1
	rapid->plist[cnt].ecnt_cnt = ecnt
	call alterlist(rapid->plist[cnt].events, ecnt)
	rapid->plist[cnt].events[ecnt].eventid = ce.event_id
	rapid->plist[cnt].events[ecnt].eventcd = ce.event_cd
	rapid->plist[cnt].events[ecnt].event_dt = ce.event_end_dt_tm   
     	rapid->plist[cnt].events[ecnt].code_blue_provider_notify = ce.result_val
     	rapid->plist[cnt].events[ecnt].code_blue_called_dt = ce.event_end_dt_tm
 
with nocounter
 
 
;-----------------------------------------------------------------------------------------
;Provider notification details
select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	and e.encntr_type_cd = enc_type_var 
	
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
      and ce.publish_flag = 1
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_cd = provider_note_det_var
	and cnvtlower(ce.result_val) = 'called code blue'
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
	recloc = 0
	idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
	recloc = idx
      if(idx = 0)
		cnt += 1
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		rapid->plist[cnt].admit_unit = e.loc_nurse_unit_cd
		rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
		recloc = cnt
	endif
	ecnt = rapid->plist[recloc].ecnt_cnt
Head ce.event_id
	ecnt += 1
	call alterlist(rapid->plist[recloc].events, ecnt)
	rapid->plist[recloc].ecnt_cnt = ecnt
	rapid->plist[recloc].events[ecnt].eventid = ce.event_id
	rapid->plist[recloc].events[ecnt].eventcd = ce.event_cd
	rapid->plist[recloc].events[ecnt].event_dt = ce.event_end_dt_tm
	rapid->plist[recloc].events[ecnt].code_blue_called_dt = ce.event_end_dt_tm
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Cardio arrest
 
select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
 
from encounter e
	,clinical_event ce
	,ce_date_result cdr
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	and e.encntr_type_cd = enc_type_var 	
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
      and ce.publish_flag = 1
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_cd = cardio_arrest_var
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
	and cdr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
	recloc = 0
	idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
	recloc = idx
      if(idx = 0)
		cnt += 1
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		rapid->plist[cnt].admit_unit = e.loc_nurse_unit_cd
		rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
		recloc = cnt
	endif
	ecnt = rapid->plist[recloc].ecnt_cnt
Head ce.event_id
	ecnt += 1
	call alterlist(rapid->plist[recloc].events, ecnt)
	rapid->plist[recloc].ecnt_cnt = ecnt
	rapid->plist[recloc].events[ecnt].eventid = ce.event_id
	rapid->plist[recloc].events[ecnt].eventcd = ce.event_cd
	rapid->plist[recloc].events[ecnt].event_dt = ce.event_end_dt_tm
	rapid->plist[recloc].events[ecnt].cardio_arrest_dt = cdr.result_dt_tm;format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Resu and peper code
select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
, ce.event_end_dt_tm, ce.event_id
 
from encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	and e.encntr_type_cd = enc_type_var 	
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
      and ce.publish_flag = 1
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_cd in(resuci_outcome_var, paper_codeblu_var)
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

Head ce.encntr_id
	idx = 0
	icnt = 0
	recloc = 0
	resu_outcome = fillstring(1000," ")
	idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
	recloc = idx
	if(idx = 0)
		cnt += 1
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		rapid->plist[cnt].admit_unit = e.loc_nurse_unit_cd
		rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
		recloc = cnt
	endif
	ecnt = rapid->plist[recloc].ecnt_cnt
Head ce.event_id
	ecnt += 1
	call alterlist(rapid->plist[recloc].events, ecnt)
	rapid->plist[recloc].ecnt_cnt = ecnt
	rapid->plist[recloc].events[ecnt].eventid = ce.event_id
	rapid->plist[recloc].events[ecnt].eventcd = ce.event_cd
	rapid->plist[recloc].events[ecnt].event_dt = ce.event_end_dt_tm
     	rapid->plist[recloc].events[ecnt].code_blue_called_dt = ce.event_end_dt_tm
	case(ce.event_cd)
		of paper_codeblu_var:
			rapid->plist[recloc].events[ecnt].paper_codeblu = trim(ce.result_val)
		of resuci_outcome_var:
			rapid->plist[recloc].events[ecnt].resuci_outcome = trim(ce.result_val)
	endcase
with nocounter

;-----------------------------------------------------------------------------------------
;Resucitation and disposition
select distinct into $outdev
 
ce.encntr_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val, ce.event_end_dt_tm
 
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
	and ce.event_cd in(dispo_after_cardio_var);resuci_outcome_var
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
	and cdr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id
 
Head ce.encntr_id
	idx = 0
	cnt = 0
	dispo_cardio = fillstring(1000," ")
	idx = locateval(cnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[cnt].encntrid)
	ecnt = rapid->plist[idx].ecnt_cnt
Head ce.event_id
      if(idx > 0)
     		ecnt += 1
		call alterlist(rapid->plist[idx].events, ecnt)
		rapid->plist[idx].ecnt_cnt = ecnt
		rapid->plist[idx].events[ecnt].eventid = ce.event_id
		rapid->plist[idx].events[ecnt].eventcd = ce.event_cd
		rapid->plist[idx].events[ecnt].event_dt = ce.event_end_dt_tm
		rapid->plist[idx].events[ecnt].dispo_after_cardio = trim(ce.result_val)
	endif
with nocounter
 
;----------------------------------------------------------------------------------------------------
;Demographic
 
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
;Admitting
 
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
;Patient location at time of code blue called
 
select into $outdev
 
elh.encntr_id, beg = format(elh.beg_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, en = format(elh.end_effective_dt_tm,'mm/dd/yyyy hh:mm;;d'), eventid = rapid->plist[d1.seq].events[d2.seq].eventid
, code_blue_dt = format(rapid->plist[d1.seq].events[d2.seq].code_blue_called_dt,'mm/dd/yyyy hh:mm;;d')
, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from	(dummyt   d1  with seq = size(rapid->plist, 5))
	, (dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(rapid->plist[d1.seq].events, 5))
 
join d2
 
join elh where elh.encntr_id = rapid->plist[d1.seq].encntrid
	;and (cnvtdatetime(rapid->plist[d1.seq].events[d2.seq].code_blue_called_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and (cnvtdatetime(rapid->plist[d1.seq].events[d2.seq].event_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, eventid
 
Head eventid
	rapid->plist[d1.seq].events[d2.seq].code_blue_called_dt = rapid->plist[d1.seq].events[d2.seq].event_dt
	rapid->plist[d1.seq].events[d2.seq].pat_code_blue_location = pat_loc
with nocounter
 
;-------------------------------------------------------------------------------------------------------

;Format final data 

select into $outdev

fin_no = trim(substring(1, 10, rapid->plist[d1.seq].fin))
, eve_dt = format(rapid->plist[d1.seq].events[d2.seq].event_dt, 'mm/dd/yy hh:mm:ss;;d')
, eve_id = rapid->plist[d1.seq].events[d2.seq].eventid
, eve_cd = rapid->plist[d1.seq].events[d2.seq].eventcd

from	(dummyt   d1  with seq = size(rapid->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(rapid->plist[d1.seq].events, 5))
	and trim(substring(1, 10, rapid->plist[d1.seq].fin))!= ''
join d2

order by fin_no, eve_dt, eve_id

Head fin_no
	fcnt += 1
	blue->rec_cnt = fcnt
	call alterlist(blue->plist, fcnt)
	blue->plist[fcnt].facility = trim(substring(1, 30, rapid->plist[d1.seq].facility))
	blue->plist[fcnt].admit_unit = rapid->plist[d1.seq].admit_unit
	blue->plist[fcnt].fin = trim(substring(1, 10, rapid->plist[d1.seq].fin))
	blue->plist[fcnt].pat_name = trim(substring(1, 50, rapid->plist[d1.seq].pat_name))
	blue->plist[fcnt].pat_age = trim(substring(1, 5, rapid->plist[d1.seq].pat_age))
	blue->plist[fcnt].disch_dt = trim(substring(1, 30, rapid->plist[d1.seq].disch_dt))
	blue->plist[fcnt].admit_md = trim(substring(1, 50, rapid->plist[d1.seq].admit_md))
	blue->plist[fcnt].disch_dispo = trim(substring(1, 100, rapid->plist[d1.seq].disch_dispo))
	dcnt = 0
Head eve_dt	
	dcnt += 1
	call alterlist(blue->plist[fcnt].events, dcnt)
	blue->plist[fcnt].events[dcnt].event_dt = rapid->plist[d1.seq].events[d2.seq].event_dt
	blue->plist[fcnt].events[dcnt].code_blue_called_dt = rapid->plist[d1.seq].events[d2.seq].code_blue_called_dt
	blue->plist[fcnt].events[dcnt].pat_code_blue_location = trim(substring(1, 30, rapid->plist[d1.seq].events[d2.seq].pat_code_blue_location))
Head eve_id	
	case(eve_cd)
		of provider_note_var:
			blue->plist[fcnt].events[dcnt].code_blue_provider_notify = substring(1, 50, rapid->plist[d1.seq].events[d2.seq].code_blue_provider_notify)	
		of provider_note_det_var:   
			blue->plist[fcnt].events[dcnt].code_blue_called_dt = rapid->plist[d1.seq].events[d2.seq].code_blue_called_dt
		of cardio_arrest_var:
		      blue->plist[fcnt].events[dcnt].cardio_arrest_dt = rapid->plist[d1.seq].events[d2.seq].cardio_arrest_dt
		of resuci_outcome_var:
			blue->plist[fcnt].events[dcnt].resuci_outcome = trim(substring(1, 300, rapid->plist[d1.seq].events[d2.seq].resuci_outcome))      
		of dispo_after_cardio_var:  
			blue->plist[fcnt].events[dcnt].dispo_after_cardio = trim(substring(1, 300, rapid->plist[d1.seq].events[d2.seq].dispo_after_cardio))
		of paper_codeblu_var:   	
			blue->plist[fcnt].events[dcnt].paper_codeblu = trim(substring(1, 300, rapid->plist[d1.seq].events[d2.seq].paper_codeblu))
	endcase		
	
with nocounter

;------------------------------------------------------------------------------------------------------------

call echorecord(blue)

;-------------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = substring(1, 30, blue->plist[d1.seq].facility)
	, admit_unit = uar_get_code_display(blue->plist[d1.seq].admit_unit)
	, fin = substring(1, 30, blue->plist[d1.seq].fin)
	, patient_name = substring(1, 50, blue->plist[d1.seq].pat_name)
	, patient_age = substring(1, 30, blue->plist[d1.seq].pat_age)
	, discharge_dt = substring(1, 30, blue->plist[d1.seq].disch_dt)
	, admitting_md = substring(1, 50, blue->plist[d1.seq].admit_md)
	, patient_location_code_blue = substring(1, 50, blue->plist[d1.seq].events[d2.seq].pat_code_blue_location)
	, code_blue_provider_notify = substring(1, 50, blue->plist[d1.seq].events[d2.seq].code_blue_provider_notify)
	;, code_notification_time = format(blue->plist[d1.seq].events[d2.seq].code_blue_called_dt, 'mm/dd/yyyy hh:mm;;d')
	, cardio_arrest_dt = format(blue->plist[d1.seq].events[d2.seq].cardio_arrest_dt, 'mm/dd/yyyy hh:mm;;d')
	, resuscitation_outcome = substring(1, 300, blue->plist[d1.seq].events[d2.seq].resuci_outcome)
	, disposition_after_cardio_arrest = substring(1, 300, blue->plist[d1.seq].events[d2.seq].dispo_after_cardio)
	, paper_code_blue_rec_chart = substring(1, 30, blue->plist[d1.seq].events[d2.seq].paper_codeblu)
	, discharge_disposition = substring(1, 100, blue->plist[d1.seq].disch_dispo)
	;, rrt_prior_code_blue_dt = substring(1, 30, blue->plist[d1.seq].events[d2.seq].rrt_prior_code_blue_dt); ***dta not found for this

from
	(dummyt   d1  with seq = size(blue->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(blue->plist[d1.seq].events, 5))
	and trim(substring(1, 10, blue->plist[d1.seq].fin))!= ''
join d2
 
order by facility, admit_unit, patient_name, blue->plist[d1.seq].events[d2.seq].code_blue_called_dt
 
with nocounter, separator=" ", format 
 
 
 
#exitscript
 
end go
 
 
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
;go to exitscript

 
 

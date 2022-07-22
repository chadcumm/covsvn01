/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jul'2019
	Solution:			Quality
	Source file name:	      cov_phq_code_blue_responses.prg
	Object name:		cov_phq_code_blue_responses
	Request#:			1200
	Program purpose:		Code Blue Rapid Response(RRT)
	Executing from:		DA2
 	Special Notes:		Report No.3 (spec contains 3 reports)
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
11/22/21    Geetha     	CR#11571	Add Neonatal into the report 
01/07/22    Geetha     	CR#11912	Add Discharge Disposition and all facility prompt
 
******************************************************************************/

 
drop program cov_phq_code_blue_responses:dba go
create program cov_phq_code_blue_responses:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Select Nurse Unit" = 0 

with OUTDEV, start_datetime, end_datetime, acute_facility_list, nurse_unit
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare provider_note_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Provider Notification Reason')), protect
declare provider_note_det_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Provider Notification Details')), protect
declare cardio_arrest_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Date, Time of Cardiopulmonary Arrest')), protect
declare resuci_outcome_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Resuscitation Outcome')), protect
declare dispo_after_cardio_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Disposition After Cardiopulmonary Arrest')), protect
declare paper_codeblu_var   	  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Paper Code Blue Record on Chart')), protect
declare admit_phys_var   	  = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Admitting Physician')), protect

call echo(build('paper_codeblu_var = ', paper_codeblu_var))

declare resu_outcome = vc with noconstant(' '),public
declare dispo_cardio = vc with noconstant(' '),public
declare cnt = i4  
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


;Nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "l");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else									 ;a single value was selected
	set opr_nu_var = "="
endif
 

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
		2 disch_dt = vc
		2 admit_md = vc
		2 eventid = f8
		2 code_blue_provider_notify = vc
		2 code_blue_called_dt = dq8
		2 pat_code_blue_location = vc
		2 cardio_arrest_dt = vc
		2 resuci_outcome = vc
		2 dispo_after_cardio = vc
		2 rrt_prior_code_blue_dt = vc
		2 paper_codeblu = vc
		2 disch_dispo = vc
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
;, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
;		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from ;(dummyt d with seq = size(unit->list, 5))
	encounter e
	;,encntr_loc_hist elh
	,clinical_event ce
 
;plan d

plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = provider_note_var
	and cnvtlower(ce.result_val) = 'code blue activation'

/*join elh where elh.encntr_id = ce.encntr_id
	and operator(elh.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and ce.event_end_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.active_ind = 1*/
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

Head report
	cnt = 0
 
Head e.encntr_id
	cnt += 1
	rapid->rec_cnt = cnt
	call alterlist(rapid->plist, cnt)
	rapid->plist[cnt].personid = e.person_id
	rapid->plist[cnt].encntrid = e.encntr_id
	rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d') 
	rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
     	rapid->plist[cnt].code_blue_provider_notify = ce.result_val
     	rapid->plist[cnt].code_blue_called_dt = ce.event_end_dt_tm
	;rapid->plist[cnt].pat_code_blue_location = pat_loc 
	rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
Foot report
	call alterlist(rapid->plist, cnt)
 
with nocounter 
 
;-----------------------------------------------------------------------------------------
;Provider notification details
select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
;, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
;		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d with seq = size(unit->list, 5))
	,encounter e
	;,encntr_loc_hist elh
	,clinical_event ce
 
plan d

join e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = provider_note_det_var
	and cnvtlower(ce.result_val) = 'called code blue'

/*join elh where elh.encntr_id = ce.encntr_id
	and operator(elh.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and ce.event_end_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.active_ind = 1*/
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

Head ce.encntr_id
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
Detail
      if(idx = 0)
		cnt += 1
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	     	rapid->plist[cnt].code_blue_called_dt = ce.event_end_dt_tm
		;rapid->plist[cnt].pat_code_blue_location = pat_loc
		rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
	endif 
with nocounter 

;-----------------------------------------------------------------------------------------
;Cardio arrest

select into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
;, elh.loc_nurse_unit_cd, ucd = unit->list[d.seq].unit_cd, unit_dis = uar_get_code_display(elh.loc_nurse_unit_cd) 
;, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
;		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d with seq = size(unit->list, 5))
	,encounter e
	;,encntr_loc_hist elh
	,clinical_event ce
	,ce_date_result cdr
 
plan d

join e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1

join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd = cardio_arrest_var
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
	and cdr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))

/*join elh where elh.encntr_id = ce.encntr_id
	and operator(elh.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and ce.event_end_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.active_ind = 1*/
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

Head ce.encntr_id
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
Detail
      if(idx > 0)
		rapid->plist[icnt].cardio_arrest_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
	else
		cnt += 1
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		;rapid->plist[cnt].pat_code_blue_location = pat_loc 
		rapid->plist[cnt].cardio_arrest_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
	endif
 
with nocounter

;-----------------------------------------------------------------------------------------
;Neonatal
select distinct into $outdev
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
;, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
;		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d with seq = size(unit->list, 5))
	,encounter e
	;,encntr_loc_hist elh
	,clinical_event ce
 
plan d

join e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
	and ce.event_cd in(resuci_outcome_var, paper_codeblu_var)

/*join elh where elh.encntr_id = ce.encntr_id
	and operator(e.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and ce.event_end_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.active_ind = 1*/
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

Head ce.event_id
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[icnt].encntrid)
	resu_outcome = fillstring(1000," "), rs_cnt = 0
	call echo(build2('enc = ', ce.encntr_id,'-- ', event,'-- ',ce.result_val))
      if(idx > 0)
      	rs_cnt = idx
	     	rapid->plist[idx].code_blue_called_dt = ce.event_end_dt_tm
		;rapid->plist[idx].pat_code_blue_location = pat_loc
      else
		cnt += 1
		rs_cnt = cnt
		rapid->rec_cnt = cnt
		call alterlist(rapid->plist, cnt)
		rapid->plist[cnt].personid = e.person_id
		rapid->plist[cnt].encntrid = e.encntr_id
		rapid->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;d')
		rapid->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	     	rapid->plist[cnt].code_blue_called_dt = ce.event_end_dt_tm
		;rapid->plist[cnt].pat_code_blue_location = pat_loc
		rapid->plist[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
	endif 

	case(ce.event_cd)
		of paper_codeblu_var:
			rapid->plist[rs_cnt].paper_codeblu = trim(ce.result_val)
		of resuci_outcome_var:	
			resu_outcome = build2(trim(resu_outcome),trim(ce.result_val),",", ';')
			rapid->plist[rs_cnt].resuci_outcome = replace(replace(trim(resu_outcome),";","",2),",","",2)
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
	;resu_outcome = fillstring(1000," ")
	dispo_cardio = fillstring(1000," ")
	idx = locateval(cnt ,1 ,rapid->rec_cnt ,ce.encntr_id ,rapid->plist[cnt].encntrid)
 
Detail
      if(idx > 0)
		case(ce.event_cd)
			of dispo_after_cardio_var:
				dispo_cardio = build2(trim(dispo_cardio),trim(ce.result_val),",", ';')
			;of resuci_outcome_var:
				;resu_outcome = build2(trim(resu_outcome),trim(ce.result_val),",", ';')
		endcase
	endif
Foot ce.encntr_id
	;rapid->plist[cnt].resuci_outcome = replace(replace(trim(resu_outcome),";","",2),",","",2)
	rapid->plist[cnt].dispo_after_cardio = replace(replace(trim(dispo_cardio),";","",2),",","",2)
 
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
 
select into 'nl:'
 
elh.encntr_id, beg = format(elh.beg_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, en = format(elh.end_effective_dt_tm,'mm/dd/yyyy hh:mm;;d')
, pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),'; '
		,trim(uar_get_code_display(elh.loc_room_cd)),'; ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = value(size(rapid->plist,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = rapid->plist[d.seq].encntrid
	and (cnvtdatetime(rapid->plist[d.seq].code_blue_called_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id
 
Head elh.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,rapid->rec_cnt ,elh.encntr_id ,rapid->plist[cnt].encntrid)
	if(idx > 0)
		rapid->plist[idx].pat_code_blue_location = pat_loc
 	endif
 
with nocounter 
 
call echorecord(rapid)
 
;------------------------------------------------------------------------------------------------------------
 
select into $outdev
 
	facility = trim(substring(1, 30, rapid->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, rapid->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, rapid->plist[d1.seq].pat_name))
	, patient_age = trim(substring(1, 5, rapid->plist[d1.seq].pat_age))
	, discharge_dt = trim(substring(1, 30, rapid->plist[d1.seq].disch_dt))
	, admitting_md = trim(substring(1, 50, rapid->plist[d1.seq].admit_md))
	, patient_location_code_blue = trim(substring(1, 30, rapid->plist[d1.seq].pat_code_blue_location))
	, code_notification_time = format(rapid->plist[d1.seq].code_blue_called_dt, 'mm/dd/yyyy hh:mm;;d')
	, cardio_arrest_dt = trim(substring(1, 30, rapid->plist[d1.seq].cardio_arrest_dt))
	, resuscitation_outcome = trim(substring(1, 300, rapid->plist[d1.seq].resuci_outcome))
	, disposition_after_cardio_arrest = trim(substring(1, 300, rapid->plist[d1.seq].dispo_after_cardio))
	, rrt_prior_to_code_blue = trim(substring(1, 30, rapid->plist[d1.seq].rrt_prior_code_blue_dt)) ; ***dta not found for this
	, paper_code_blue_rec_chart = trim(substring(1, 300, rapid->plist[d1.seq].paper_codeblu))
 	, discharge_disposition = trim(substring(1, 100, rapid->plist[d1.seq].disch_dispo))
 
from
	(dummyt   d1  with seq = size(rapid->plist, 5))
 
plan d1 where trim(substring(1, 10, rapid->plist[d1.seq].fin))!= ''
 
order by
	facility
	, patient_name
	, fin
 
with nocounter, separator=" ", format
 
#exitscript 
 
end go
 
 
 
 

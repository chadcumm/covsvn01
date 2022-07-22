/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jun'2021
	Solution:			Quality
	Source file name:	      cov_phq_leader_safety_round.prg
	Object name:		cov_phq_leader_safety_round
	Request#:			10673
	Program purpose:
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------*/
 
 
drop program cov_gstest3:dba go
create program cov_gstest3:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Nurse Unit" = 0
 
with OUTDEV, facility_list, nurse_unit
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()      = c100
declare opr_unit_var   = vc with noconstant("")
declare diagnosis_list = vc with noconstant('')
declare alert_var      = vc with noconstant('')
 
declare central_line_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Activity.'))), protect
declare central_site_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Insertion Site:'))), protect
declare cvl_indication_var   = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Indication.'))), protect
declare cvl_type_var         = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Access Type'))), protect
declare cvl_dressing_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'CL Dressing Activity'))), protect
 
declare urinary_cath_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Activity:'))), protect
declare urinary_site_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Insertion Site:'))),protect
declare foley_indication_var = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Indications:'))), protect
declare foley_type_var       = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Type:'))), protect
declare chg_treat_var        = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Chlorohexidine treatment'))), protect
declare fall_score_var       = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Morse Fall Score'))), protect
declare mental_stat_var      = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Fall Intervention Mental Status'))), protect
declare vacin_admin_INF_var  = f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'INF Admin Influenza Vaccine'))),protect
declare vacin_admin_inact_var= f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'influenza virus vaccine, inactivated'))),protect
 
declare endo_tube_var        = f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'Endotracheal Tube Activity:'))), protect
declare trach_tube_var       = f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'Tracheostomy Tube Activity'))), protect
declare phary_tube_var       = f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'Pharyngeal Airway Activity:'))), protect
 
declare isolation_var        = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Patient Isolation'))), protect
declare cdiff_toxin_var      = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Clostridium difficile GDH/Toxin+'))), protect
declare cdiff_var            = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'C.Diff Day 1-3 Screening'))), protect
declare suicide_preca_var    = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Precaution Suicide'))), protect
declare clo_restraint_var    = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Nursing CLO Non-Violent Restraint'))), protect
declare sep_ip_alert_var     = f8 with constant(value(uar_get_code_by("DISPLAY", 200, "Severe Sepsis IP Alert"))),protect
declare sep_ed_alert_var     = f8 with constant(value(uar_get_code_by("DISPLAY", 200, "Severe Sepsis ED Alert"))),protect
declare sep_ed_triage_var    = f8 with constant(value(uar_get_code_by("DISPLAY", 200, "ED Triage Sepsis Alert"))),protect
declare sep_advisor_var      = f8 with constant(value(uar_get_code_by("DISPLAY", 200, "Sepsis Advisor"))),protect
declare septic_shock_var     = f8 with constant(value(uar_get_code_by("DISPLAY", 200, "Septic Shock Alert"))),protect
declare dnr_var              = f8 with constant(value(uar_get_code_by("DISPLAY", 200, "Resuscitation Status/Medical Interventions"))),protect
declare attach_type_var      = f8 with constant(value(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))),protect
 
;Set clinic variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_unit_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_unit_var = "!="
else								  ;a single value was selected
	set opr_unit_var = "="
endif
 
;----------------------------------------------------------------------------------------------
 
RECORD pat(
	1 rec_cnt = i4
	1 report_ran_by = vc
	1 plist[*]
		2 facility_cd = f8
		2 fin = vc
		2 personid = f8
 		2 encntrid = f8
		2 pat_name = vc
		2 nu_unit = vc
		2 room = vc
		2 bed_rs = vc
		2 tele_ordr_dt = vc
		2 dnr_rs = vc
		2 diagnos = vc
		2 iso_ordr = vc
		2 chg_dt = vc
		2 bed_alarm_rs = vc
		2 restraint = vc
		2 sepsis_alert_rs = vc
		2 sepsis_alert_stat = vc
		2 cdiff = vc
		2 procedure = vc
		2 fall_scor = vc
		2 fall_risk_rs = vc
		2 fall_risk_status = vc
		2 suicid_ordr = vc
		2 endo_tube_rs = vc
		2 trach_tube_rs = vc
		2 invasiv_line = vc
		2 cvl[*]
			3 cvl_name = vc
			3 cvl_dyn_labelid = f8
			3 cvl_days_rs = vc
			3 cvl_reason_rs = vc
			3 cvl_dt = vc
			3 cvl_dresing = vc
			3 cvl_dresing_dt = vc
			3 cvl_action_rs = vc
		2 foley[*]	
			3 foley_name = vc
			3 foley_dyn_labelid = f8
			3 foley_days_rs = vc
			3 foley_reason_rs = vc
			3 foley_dt = vc
			3 foley_action_rs = vc
	)
 
;------------------------ Helpers ---------------------------------------------------
Record cvl_labl(
	1 list[*]
		2 encntrid = f8
		2 cvl_eventcd = f8
		2 cvl[*]
			3 cl_lbl_id = f8
			3 cl_lbl_min_eventid = f8
			3 cl_action = vc
			3 cl_name = vc
			3 cl_days = vc
			3 cl_reason = vc
			3 cl_dt = vc
			3 cl_dresing = vc
			3 cl_dresing_dt = vc
	)

Record fol_labl(
	1 list[*]
		2 encntrid = f8
		2 fol_eventcd = f8
		2 fol[*]
			3 fl_lbl_id = f8
			3 fl_lbl_min_eventid = f8
			3 fl_action = vc
			3 fl_name = vc
			3 fl_days = vc
			3 fl_reason = vc
			3 fl_dt = vc
			3 fl_dresing = vc
			3 fl_dresing_dt = vc
	)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get user in action
select into "NL:"
 
usr_name = initcap(p.username)
 
from	prsnl p
where p.person_id = reqinfo->updt_id
 
detail
	pat->report_ran_by = usr_name
with nocounter
 
 
;------------------------------------------------------------------------------------------
;Active patients
select into $outdev
 
fin = ea.alias, e.encntr_id, pat_nam = initcap(p.name_full_formatted)
 
from
	encounter e
	, encntr_loc_hist elh
	, encntr_alias ea
	, person p
 
plan elh where operator(elh.loc_nurse_unit_cd, opr_unit_var, $nurse_unit)
	and elh.active_ind = 1
	and elh.active_status_cd = 188 ;active
	and (elh.beg_effective_dt_tm <= sysdate and elh.end_effective_dt_tm >= sysdate)
 
join e where e.encntr_id = elh.encntr_id
	and e.encntr_status_cd = 854.00 ;Active
	and e.disch_dt_tm is null
	and e.encntr_status_cd != 856.00 ;Discharged
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->plist, cnt)
Detail
	pat->plist[cnt].facility_cd = e.loc_facility_cd
	pat->plist[cnt].fin = ea.alias
	pat->plist[cnt].personid = e.person_id
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].pat_name = pat_nam
	pat->plist[cnt].nu_unit = uar_get_code_description(elh.loc_nurse_unit_cd)
	pat->plist[cnt].room = if(elh.loc_room_cd != 0) uar_get_code_display(elh.loc_room_cd) else ' ' endif
	pat->plist[cnt].bed_rs = if(elh.loc_bed_cd != 0) uar_get_code_display(elh.loc_bed_cd) else ' ' endif
with nocounter
 
 
if(pat->rec_cnt > 0)
 
;----------------------------------------------------------------------------------------------------------------
;chlorhexidine treatment
 
select into $outdev
 nu = pat->plist[d.seq].nu_unit, ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd =  chg_treat_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					and ce.result_val not in("Not done due to patient allergy, Patient refused" , "Not done due to patient allergy" , "Patient refused")
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
	pat->plist[idx].chg_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;CVL Start...
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid 
	and ce.event_cd = central_line_var ;urinary_cath_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and cnvtlower(ce.result_val) in('present on admission','present on admission.','insert',
		'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.',
		'cl access port', 'assessment','cl assessment')
	and not exists (select ce2.encntr_id from clinical_event ce2
			where(ce2.encntr_id = ce.encntr_id
			and ce2.event_cd = ce.event_cd
			and ce2.ce_dynamic_label_id = ce.ce_dynamic_label_id
			and cnvtlower(ce2.result_val) = "discontinued"))
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_end_dt_tm
 
Head report
	ecnt = 0
Head ce.encntr_id
	ecnt += 1
	call alterlist(cvl_labl->list, ecnt)
	cvl_labl->list[ecnt].encntrid = ce.encntr_id
	cvl_labl->list[ecnt].cvl_eventcd = ce.event_cd
	lcnt = 0
Head ce.ce_dynamic_label_id
	lcnt += 1
	call alterlist(cvl_labl->list[ecnt].cvl, lcnt)
	cvl_labl->list[ecnt].cvl[lcnt].cl_lbl_id = ce.ce_dynamic_label_id
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;Calculate cvl days
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), cvl_action = ce.result_val, ce.event_end_dt_tm ';;q'
,cvldays = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) ), ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce

plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2

join ce where ce.encntr_id = cvl_labl->list[d1.seq].encntrid
	and cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	and ce.event_cd = cvl_labl->list[d1.seq].cvl_eventcd
	and ce.event_id = (select min(ce1.event_id) from clinical_event ce1
				where ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
				and ce1.event_tag != "Date\Time Correction"
				and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
				and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
				group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_id
 
Head ce.ce_dynamic_label_id	
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_min_eventid = ce.event_id
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_action = trim(ce.result_val)
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_days = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) )
 
with nocounter 

;------------------------------------------------------------------------------------------------------------------
;Cvl indication & type
 
select into $outdev
 
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce

plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2

join ce where ce.encntr_id = cvl_labl->list[d1.seq].encntrid
	and cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	and ce.event_cd in(cvl_indication_var, cvl_type_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.event_tag != "Date\Time Correction"
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.ce_dynamic_label_id, ce.event_cd

Head ce.ce_dynamic_label_id
	tt = 0
Head ce.event_cd
	case(ce.event_cd)
      	of cvl_indication_var:
      		cvl_labl->list[d1.seq].cvl[d2.seq].cl_reason = trim(ce.result_val)
		of cvl_type_var:
			cvl_labl->list[d1.seq].cvl[d2.seq].cl_name = trim(ce.result_val)
	endcase
 
with nocounter 
 
;------------------------------------------------------------------------------------------------------------------
;Cvl dressing
 
select into $outdev
 
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce

plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2

join ce where ce.encntr_id = cvl_labl->list[d1.seq].encntrid
	and cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	and ce.event_cd = cvl_dressing_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
					and ce1.event_tag != "Date\Time Correction"
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					and cnvtlower(ce1.result_val) in('applied', 'changed')
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.ce_dynamic_label_id, ce.event_cd

Head ce.ce_dynamic_label_id
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_dresing = trim(ce.result_val)
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_dresing_dt = format(ce.event_end_dt_tm, 'mm/dd/yy ;;q')
with nocounter 

;-------------------------------------------------------------------------------------------------------------
;Move CVL data to Master RS

select into $outdev
enc = cvl_labl->list[d1.seq].encntrid
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)

plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2 where cnvtlower(cvl_labl->list[d1.seq].cvl[d2.seq].cl_name)!= "straight/intermittent"

order by enc
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Detail
	lcnt += 1
	call alterlist(pat->plist[idx].cvl, lcnt)
	pat->plist[idx].cvl[lcnt].cvl_dyn_labelid = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	pat->plist[idx].cvl[lcnt].cvl_action_rs = cvl_labl->list[d1.seq].cvl[d2.seq].cl_action
	pat->plist[idx].cvl[lcnt].cvl_days_rs = cvl_labl->list[d1.seq].cvl[d2.seq].cl_days
	pat->plist[idx].cvl[lcnt].cvl_dresing = cvl_labl->list[d1.seq].cvl[d2.seq].cl_dresing
	pat->plist[idx].cvl[lcnt].cvl_dresing_dt = cvl_labl->list[d1.seq].cvl[d2.seq].cl_dresing_dt
	pat->plist[idx].cvl[lcnt].cvl_dt = cvl_labl->list[d1.seq].cvl[d2.seq].cl_dt
	pat->plist[idx].cvl[lcnt].cvl_name = cvl_labl->list[d1.seq].cvl[d2.seq].cl_name
	pat->plist[idx].cvl[lcnt].cvl_reason_rs = cvl_labl->list[d1.seq].cvl[d2.seq].cl_reason
 
with nocounter

;-------------------------------------------------------------------------------------------------------------
;Foley Start...
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid 
	and ce.event_cd = urinary_cath_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
		'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.', 'sn - cath - inserted',
		'uc inserted in surgery/procedure', 'assessment')
	and not exists (select ce2.encntr_id from clinical_event ce2
			where(ce2.encntr_id = ce.encntr_id
			and ce2.event_cd = ce.event_cd
			and ce2.ce_dynamic_label_id = ce.ce_dynamic_label_id
			and cnvtlower(ce2.result_val) = "discontinued"))
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_end_dt_tm

Head report
	ecnt = 0
Head ce.encntr_id
	ecnt += 1
	call alterlist(fol_labl->list, ecnt)
	fol_labl->list[ecnt].encntrid = ce.encntr_id
	fol_labl->list[ecnt].fol_eventcd = ce.event_cd
	lcnt = 0
Head ce.ce_dynamic_label_id
	lcnt += 1
	call alterlist(fol_labl->list[ecnt].fol, lcnt)
	fol_labl->list[ecnt].fol[lcnt].fl_lbl_id = ce.ce_dynamic_label_id
 
with nocounter 
 
;-------------------------------------------------------------------------------------------------------------
;Calculate Foley days
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
,foleydays = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) ), ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce

plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2

join ce where ce.encntr_id = fol_labl->list[d1.seq].encntrid
	and fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id
	and ce.event_cd = fol_labl->list[d1.seq].fol_eventcd
	and ce.event_id = (select min(ce1.event_id) from clinical_event ce1
				where ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
				and ce1.event_tag != "Date\Time Correction"
				and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
				and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
				group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_id
 
Head ce.ce_dynamic_label_id	
	fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_min_eventid = ce.event_id
	fol_labl->list[d1.seq].fol[d2.seq].fl_action = trim(ce.result_val)
	fol_labl->list[d1.seq].fol[d2.seq].fl_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
	fol_labl->list[d1.seq].fol[d2.seq].fl_days = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) )
 
with nocounter 
 
;------------------------------------------------------------------------------------------------------------------
;Foley indication & type
 
select into $outdev
 
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce

plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2

join ce where ce.encntr_id = fol_labl->list[d1.seq].encntrid
	and fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id
	and ce.event_cd in(foley_indication_var, foley_type_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					;and cnvtlower(ce1.result_val)!= "straight/intermittent"
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.ce_dynamic_label_id, ce.event_cd

Head ce.ce_dynamic_label_id
	tt = 0
Head ce.event_cd
	case(ce.event_cd)
      	of foley_indication_var:
      		fol_labl->list[d1.seq].fol[d2.seq].fl_reason = trim(ce.result_val)
		of foley_type_var:
			fol_labl->list[d1.seq].fol[d2.seq].fl_name = trim(ce.result_val)
	endcase
 
with nocounter 
 
;----------------------------------------------------------------------------------------------------------------
;Move Foley data to Master RS

select into $outdev
enc = fol_labl->list[d1.seq].encntrid
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)

plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where cnvtlower(fol_labl->list[d1.seq].fol[d2.seq].fl_name)!= "straight/intermittent"

order by enc
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Detail
	lcnt += 1
	call alterlist(pat->plist[idx].foley, lcnt)
	pat->plist[idx].foley[lcnt].foley_dyn_labelid = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id
	pat->plist[idx].foley[lcnt].foley_action_rs = fol_labl->list[d1.seq].fol[d2.seq].fl_action
	pat->plist[idx].foley[lcnt].foley_days_rs = fol_labl->list[d1.seq].fol[d2.seq].fl_days
	pat->plist[idx].foley[lcnt].foley_dt = fol_labl->list[d1.seq].fol[d2.seq].fl_dt
	pat->plist[idx].foley[lcnt].foley_name = fol_labl->list[d1.seq].fol[d2.seq].fl_name
	pat->plist[idx].foley[lcnt].foley_reason_rs = fol_labl->list[d1.seq].fol[d2.seq].fl_reason

with nocounter

;----------------------------------------------------------------------------------------------------------------
;DNR - Resucitation Status
 
select into $outdev
 o.encntr_id, o.orig_order_dt_tm, o.ordered_as_mnemonic, o.order_id, o.catalog_cd, o.order_status_cd
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
	, order_detail od
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.order_id = (select max(o2.order_id) from orders o2
			where o2.encntr_id = o.encntr_id
			and o2.catalog_cd = dnr_var
			and o2.active_ind = 1
			group by o2.encntr_id, o2.catalog_cd)
 
join od where od.order_id = o.order_id
	and od.oe_field_meaning = 'RESUSCITATIONSTATUS'
	and od.oe_field_display_value = '*DNR*'
 
 
order by o.encntr_id
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
	pat->plist[idx].dnr_rs = trim(od.oe_field_display_value)
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Telemetry Order
 
select into $outdev
 o.encntr_id, o.orig_order_dt_tm ';;q', o.order_mnemonic, o.ordered_as_mnemonic, o.hna_order_mnemonic
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd =  3713507.00 ;Cardiac Monitoring
	and o.order_status_cd = 2550.00 ;Ordered
 
order by o.encntr_id
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
	pat->plist[idx].tele_ordr_dt = format(o.orig_order_dt_tm, 'mm/dd/yy ;;q')
 
with nocounter

;----------------------------------------------------------------------------------------------------------------
;Isolation Order

select into $outdev
 o.encntr_id, o.order_id, od.oe_field_display_value
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
	, order_detail od
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd = isolation_var
	and o.order_status_cd = 2550
 
join od where od.order_id = o.order_id
	and od.oe_field_meaning = 'ISOLATIONCODE'
 
order by o.encntr_id, od.oe_field_display_value
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
      iso_oef_var = fillstring(1000," ")
Head od.oe_field_display_value
      iso_oef_var = build2(trim(iso_oef_var),trim(od.oe_field_display_value),',')
Foot od.oe_field_display_value
	pat->plist[idx].iso_ordr = replace(trim(iso_oef_var),",","",2)
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;CDiff Order
 
select into $outdev
 o.encntr_id, o.orig_order_dt_tm, o.ordered_as_mnemonic, o.order_id, o.catalog_cd, o.order_status_cd
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.order_status_cd = 2550.00 ;Ordered
	and o.order_id = (select distinct o2.template_order_id from orders o2
			where o2.encntr_id = o.encntr_id
			and o2.catalog_cd in(cdiff_toxin_var, cdiff_var)
			and o2.order_status_cd = 2550.00 ;Ordered
			and o2.active_ind = 1)
 
order by o.encntr_id
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
	pat->plist[idx].cdiff = 'Yes'
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Fall/Morse Score
 
select into $outdev
 
enc = pat->plist[d.seq].encntrid, ce.event_cd, ce.result_val, ce.event_end_dt_tm
 
from
	(dummyt d with seq = size(pat->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = pat->plist[d.seq].personid
	and ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(fall_score_var, mental_stat_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	      and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.event_cd
	case(ce.event_cd)
		of fall_score_var:
			pat->plist[idx].fall_scor = trim(ce.result_val)
		   	if(cnvtint(trim(ce.result_val)) > 40)
		   		pat->plist[idx].fall_risk_status = build2('Yes,', trim(ce.result_val))
		   	endif
		of mental_stat_var:
		   	pat->plist[idx].bed_alarm_rs = trim(ce.result_val)
      endcase
with nocounter
 
 
;----------------------------------------------------------------------------------------------------------------
;Suicide Precaution Order
 
select into $outdev
 o.encntr_id, o.orig_order_dt_tm ';;q', o.order_mnemonic, o.ordered_as_mnemonic, o.hna_order_mnemonic
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd in(suicide_preca_var, clo_restraint_var)
	and o.order_status_cd = 2550
 
order by o.encntr_id, o.catalog_cd
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
Head o.catalog_cd
      case(o.catalog_cd)
      of suicide_preca_var:
      	pat->plist[idx].suicid_ordr = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
      of clo_restraint_var:
		pat->plist[idx].restraint = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
 	endcase
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Diagnosis
select into $outdev
 
dg.encntr_id, dg.diagnosis_display, dg_dt1 = format(dg.diag_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	(dummyt d with seq = size(pat->plist, 5))
	, diagnosis dg
 
plan d
 
join dg where dg.encntr_id = pat->plist[d.seq].encntrid
	and dg.active_ind = 1
	and (dg.beg_effective_dt_tm <= sysdate and dg.end_effective_dt_tm >= sysdate)
	and dg.beg_effective_dt_tm = (select max(dg1.beg_effective_dt_tm) from diagnosis dg1 where dg1.encntr_id = dg.encntr_id
			and dg1.diagnosis_display = dg.diagnosis_display
			group by dg1.diagnosis_display)
 
order by dg.encntr_id, dg.diag_priority asc
 
Head dg.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,pat->rec_cnt ,dg.encntr_id ,pat->plist[cnt].encntrid)
      dg_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(dg.diagnosis_display),',')
	endif
Foot dg.encntr_id
	pat->plist[idx].diagnos = replace(trim(dg_list_var),",","",2)
 
with nocounter
 
 
;----------------------------------------------------------------------------------------------------------------
;Sepsis alerts
select into $outdev
o.encntr_id, o.catalog_cd, orderable = uar_get_code_display(o.catalog_cd), o.orig_order_dt_tm
 
from 	(dummyt d with seq = size(pat->plist, 5))
	,orders o
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd in(sep_ip_alert_var, sep_ed_alert_var, sep_ed_triage_var, sep_advisor_var, septic_shock_var)
	and o.active_ind = 1
	and (datetimediff(cnvtdatetime(curdate, curtime), o.orig_order_dt_tm) <= 1)
 
order by o.encntr_id, o.order_id
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
	sepsis_orders_var = fillstring(3000," "), alert_var = ''
 
Head o.order_id
	if((datetimediff(cnvtdatetime(curdate, curtime), o.orig_order_dt_tm) <= 1))
		if(alert_var = '')
 			alert_var = 'Yes'
 		endif
 	endif
 
	sepsis_orders_var = build2(trim(sepsis_orders_var),'[' ,trim(orderable)
				, ' - ', format(o.orig_order_dt_tm,"mm-dd-yy hh:mm;;d"),']',',')
Foot o.encntr_id
	pat->plist[idx].sepsis_alert_rs = replace(trim(sepsis_orders_var),",","",2)
 	pat->plist[idx].sepsis_alert_stat = alert_var
 	
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Procedures - Scheduled for next 24 hrs
 
select into $outdev
sa.encntr_id, sa.sch_appt_id, sa.sch_event_id, trim(o.order_mnemonic), apt_dt = format(sa.beg_dt_tm, 'mm/dd/yy hh:mm ;;q')
 
from  (dummyt d with seq = size(pat->plist, 5))
	, sch_appt sa
	, sch_event_attach sea
	, orders o
 
plan d
 
join sa where sa.encntr_id = pat->plist[d.seq].encntrid
	and (sa.beg_dt_tm between cnvtdatetime(curdate, curtime) and (cnvtlookahead("24, H", cnvtdatetime(curdate, curtime))))
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED")
	and sa.active_ind = 1
 
join sea where sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.active_ind = 1
 
join o where o.order_id = sea.order_id
	and o.active_ind = 1
 
order by sa.encntr_id, o.order_id
 
Head sa.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,sa.encntr_id ,pat->plist[icnt].encntrid)
      pro_var = fillstring(3000," ")
 
Head o.order_id
      pro_var = build2(trim(pro_var),trim(o.order_mnemonic),'-',apt_dt,',')
 
Foot o.encntr_id
	pat->plist[idx].procedure = replace(trim(pro_var),",","",2)
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Endo and Trach tube - Invasiv line
 
select into $outdev
 
ce.encntr_id, ce.event_cd, ce.result_val, ce.event_end_dt_tm
 
from
	(dummyt d with seq = size(pat->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = pat->plist[d.seq].personid
	and ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(endo_tube_var, trach_tube_var, phary_tube_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		;and cnvtlower(ce1.result_val) in('intubated', 'reintubated', 'ventilator initiate')
		and cnvtlower(ce1.result_val) != 'tube removed'
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	      and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
 
	and not exists (select ce1.encntr_id from clinical_event ce1
				where(ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and cnvtlower(ce1.result_val) = "discontinued"))
 
order by ce.encntr_id, ce.event_cd, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
      line_var = fillstring(3000," ")
Head ce.event_cd
	case(ce.event_cd)
	      of endo_tube_var:
	      	pat->plist[idx].endo_tube_rs = trim(ce.result_val)
	      	line_var = build2(trim(line_var),'Endo - ',trim(ce.result_val),',')
	      of trach_tube_var:
	      	pat->plist[idx].trach_tube_rs = trim(ce.result_val)
	      	line_var = build2(trim(line_var),'Trach - ',trim(ce.result_val),',')
	      of phary_tube_var:
	      	line_var = build2(trim(line_var),'Phary - ',trim(ce.result_val),',')
      endcase
Foot ce.encntr_id
		pat->plist[idx].invasiv_line = replace(trim(line_var),",","",2)
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
call echorecord(pat)
 
;----------------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = trim(uar_get_code_display(pat->plist[d1.seq].facility_cd))
	, fin = trim(substring(1, 30, pat->plist[d1.seq].fin))
	, personid = pat->plist[d1.seq].personid
	, encntrid = pat->plist[d1.seq].encntrid
	, pat_name = trim(substring(1, 50, pat->plist[d1.seq].pat_name))
	, nurse_unit = trim(substring(1, 30, pat->plist[d1.seq].nu_unit))
	, room = trim(substring(1, 5, pat->plist[d1.seq].room))
	, bed = trim(substring(1, 5, pat->plist[d1.seq].bed_rs))
	, telemetry = trim(substring(1, 300, pat->plist[d1.seq].tele_ordr_dt))
	, dnr = trim(substring(1, 300, pat->plist[d1.seq].dnr_rs))
	, Diagnosis = trim(substring(1, 3000, pat->plist[d1.seq].diagnos))
	, isolation = trim(substring(1, 300, pat->plist[d1.seq].iso_ordr))
	, chg_date = trim(substring(1, 30, pat->plist[d1.seq].chg_dt))
	;, cvl_dyn_labelid = pat->plist[d1.seq].cvl[d2.seq].cvl_dyn_labelid
	, cvl_action = trim(substring(1, 300, pat->plist[d1.seq].cvl[d2.seq].cvl_action_rs))
	, cvl_name = trim(substring(1, 300, pat->plist[d1.seq].cvl[d2.seq].cvl_name))
	, cvl_date = trim(substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_dt))
	, cvl_days = trim(substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_days_rs))
	, cvl_reason = trim(substring(1, 300, pat->plist[d1.seq].cvl[d2.seq].cvl_reason_rs))
	, cvl_dresing = trim(substring(1, 100, pat->plist[d1.seq].cvl[d2.seq].cvl_dresing))
	, cvl_dresing_dt = trim(substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_dresing_dt))
	;, foley_dyn_labelid = pat->plist[d1.seq].foley[d3.seq].foley_dyn_labelid
	, foley_action_rs = trim(substring(1, 300, pat->plist[d1.seq].foley[d3.seq].foley_action_rs))
	, foley_name = trim(substring(1, 300, pat->plist[d1.seq].foley[d3.seq].foley_name))
	, foley_reason = trim(substring(1, 300, pat->plist[d1.seq].foley[d3.seq].foley_reason_rs))
	, foley_days = trim(substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_days_rs))
	, foley_date = trim(substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_dt))
	, fall_score = trim(substring(1, 30, pat->plist[d1.seq].fall_scor))
	, fall_risk = trim(substring(1, 300, pat->plist[d1.seq].fall_risk_status))
	, bed_alarm = trim(substring(1, 300, pat->plist[d1.seq].bed_alarm_rs))
	, restraint = trim(substring(1, 300, pat->plist[d1.seq].restraint))
	, sepsis_alert = trim(substring(1, 3000, pat->plist[d1.seq].sepsis_alert_rs))
	, sepsis_alert_fired = trim(substring(1, 5, pat->plist[d1.seq].sepsis_alert_stat))
	, cdiff = trim(substring(1, 300, pat->plist[d1.seq].cdiff))
	, procedures = trim(substring(1, 3000, pat->plist[d1.seq].procedure))
	, suicide_precaution = trim(substring(1, 300, pat->plist[d1.seq].suicid_ordr))
	, Endo_tube = trim(substring(1, 100, pat->plist[d1.seq].endo_tube_rs))
	, trach_tube = trim(substring(1, 100, pat->plist[d1.seq].trach_tube_rs))
	, active_invasiv_line = trim(substring(1, 3000, pat->plist[d1.seq].invasiv_line))

from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)
	, (dummyt   d3  with seq = 1)

plan d1 where maxrec(d2, size(pat->plist[d1.seq].cvl, 5))
	and maxrec(d3, size(pat->plist[d1.seq].foley, 5))

join d2 
join d3
 
order by nurse_unit, room, fin
 
with nocounter, separator=" ", format
 
 
 
endif
 
#exitscript
 
end go
 
 
/* 
 
 SELECT
	PLIST_FACILITY_CD = PAT->plist[D1.SEQ].facility_cd
	, PLIST_FIN = SUBSTRING(1, 30, PAT->plist[D1.SEQ].fin)
	
	, cvl_name = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_name)
	, cvl_dyn_labelid = pat->plist[d1.seq].cvl[d2.seq].cvl_dyn_labelid
	, cvl_days_rs = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_days_rs)
	, cvl_reason_rs = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_reason_rs)
	, cvl_dt = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_dt)
	, cvl_dresing = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_dresing)
	, cvl_dresing_dt = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_dresing_dt)
	, cvl_action_rs = substring(1, 30, pat->plist[d1.seq].cvl[d2.seq].cvl_action_rs)
	, foley_name = substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_name)
	, foley_dyn_labelid = pat->plist[d1.seq].foley[d3.seq].foley_dyn_labelid
	, foley_days_rs = substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_days_rs)
	, foley_reason_rs = substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_reason_rs)
	, foley_dt = substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_dt)
	, foley_action_rs = substring(1, 30, pat->plist[d1.seq].foley[d3.seq].foley_action_rs)

from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)
	, (dummyt   d3  with seq = 1)

plan d1 where maxrec(d2, size(pat->plist[d1.seq].cvl, 5))
	and maxrec(d3, size(pat->plist[d1.seq].foley, 5))
join d2 
join d3

with nocounter, separator=" ", format

 
 
 
 
 
 
 

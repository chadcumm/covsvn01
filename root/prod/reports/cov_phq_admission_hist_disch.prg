 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan'2020
	Solution:			Quality
	Source file name:	      cov_phq_admission_hist_disch.prg
	Object name:		cov_phq_admission_hist_disch
	Request#:			6909
	Program purpose:	      Admission History Compliance for discharged patients
	Executing from:		DA2
 	Special Notes:          DataSet script used in Facility prompt : cov_autoset_suicide_assess
 
***************************************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***************************************************************************************************************
 
 CR#	  Mod Date	 Developer			Comment
------  ---------  -----------  ---------------------------------------------------------------------------------
 7063   02/13/20    Geetha 	 Prevent Behavioral Health reports from being ran by non BH employees
   					 Aso, we don't want Parkwest BH to see Morristown's BH units and vise versa.
 8447   08/24/20    Geetha     Duplicate rows
 10284  05/24/21    Geetha     New admission forms as a part of ECD project
****************************************************************************************************************/
 
drop program cov_phq_admission_hist_disch:dba go
create program cov_phq_admission_hist_disch:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Nurse Unit" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list, nurse_unit
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()  = c100
declare adult_pat_his_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Adult Patient History Form')),protect
declare procedure_chklist_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Preprocedure Checklist Form')),protect
declare OB_triage_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Triage')),protect
declare OB_pat_his_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Patient History Form')),protect
declare OB_pat_his1_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Patient History')),protect
declare pre_admit_asses_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Pre-Admission Assessment')),protect
declare preop_chklist_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Perioperative Preprocedure Checklist')),protect
declare pedi_hist_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Admission History Pediatric Form')),protect
declare OB_admission_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Admission History Form')),protect
declare adult_EBP_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Adult Patient History EBP Form')),protect
declare adult_EBN_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Adult Patient History EBN Form')),protect
declare newborn_hist_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Newborn Admission History - Text')),protect
declare newborn_hist1_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Newborn Admission')),protect
declare resident_hist_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Resident Admission History Form')),protect
declare BEH_hist_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, 'BEH Admission History Adult Form')),protect
declare BH_admit_hist_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'BH Nursing History Adult Form')),protect
declare advance_dir_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Advance Directive')),protect
declare newborn_hist2_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Newborn Admission History Form')),protect
declare adult_pat_his1_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Adult Patient History')),protect
declare OB_triage1_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Triage Form')),protect
 
;New Forms ECD Project - 05/24/21
declare pre_procedure_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PreProcedure Admission - Form')),protect
declare nurse_admit_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Nurse Admission - Workflow Form')),protect
declare obe_admit_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Observation Admission - Workflow - Form')),protect
declare ob_admit_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Admission - Workflow Form')),protect
declare nurse_peds_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Nurse Peds Admission - Workflow - Form')),protect
declare bh_nurse_ped_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'BH Nurse Ped Admission - Workflow - Form')),protect
declare bh_nurse_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, 'BH Nurse Admission - Workflow - Form')),protect
declare res_ltc_var            = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Resident LTC Admission - Workflow - Form')),protect
declare nurse_pnrc_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Nurse Admission PNRC - Workflow - Form')),protect
declare hospice_admit_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Hospice Admission - Workflow - Form')),protect
declare ob_triage_wflo_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'OB Triage - Workflow Form')),protect
declare admit_hist_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Admission History Workflow Nursing')),protect
 
declare admission_form = vc with noconstant('')
declare procedure_chklist_form = vc with noconstant('')
declare opr_nu_var    = vc with noconstant("")
 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record tob(
	1 reccnt = i4
	1 plist[*]
		2 facility = vc
		2 personid = f8
		2 encntrid = f8
		2 fin = vc
		2 pat_name = vc
		2 pat_type = vc
		2 arrive_dt = vc
		2 admit_dt = vc
		2 disch_dt = vc
		2 updt_dt = vc
		2 nurse_unit = vc
		2 room = vc
		2 bed_number = vc
		2 procedure_chklist = vc
		2 admit_hist_wfl = vc
		2 form_name = vc
		2 form_dt = vc
		2 dta[*]
			3 dta_used = vc
			3 dta_response = vc
			3 dta_dt = vc
			3 nurse_completed = vc
	)
 
;----------------------------------------------------------------------------------------------------------
;Get all encounters
select into $outdev
 
e.encntr_id, e.person_id, e.encntr_type_cd, elh.loc_nurse_unit_cd, e.arrive_dt_tm, e.reg_dt_tm
, e.loc_facility_cd, ea.alias, p.name_full_formatted, elh.loc_bed_cd, elh.loc_room_cd, e.updt_dt_tm, e.disch_dt_tm
 
from encounter e,
	encntr_loc_hist elh,
	encntr_alias ea,
	person p
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.disch_dt_tm is not null
	and e.encntr_id != 0.0
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00, 19962820.00, 2555267433.00, 309311.00, 2555137051.00)
			;Inpatient, Observation, Outpatient in a Bed, Newborn, Day Surgery, Behavioral Health
 
join elh where elh.encntr_id = e.encntr_id
	and operator(elh.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and elh.active_ind = 1
	and elh.active_status_cd = 188 ;active
	;and elh.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	;and (elh.beg_effective_dt_tm <= sysdate and elh.end_effective_dt_tm >= sysdate)
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head report
 	cnt = 0
Head e.encntr_id
 	cnt += 1
 	tob->reccnt = cnt
 	call alterlist(tob->plist, cnt)
Detail
 	tob->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
 	tob->plist[cnt].personid = e.person_id
 	tob->plist[cnt].encntrid = e.encntr_id
 	tob->plist[cnt].fin = ea.alias
	tob->plist[cnt].pat_name = trim(p.name_full_formatted)
	tob->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	tob->plist[cnt].arrive_dt = format(e.arrive_dt_tm, "mm/dd/yy hh:mm;;d")
	tob->plist[cnt].admit_dt = if(e.reg_dt_tm is not null) format(e.reg_dt_tm, "mm/dd/yy hh:mm;;d")
						else format(e.updt_dt_tm, "mm/dd/yy hh:mm;;d") endif
	tob->plist[cnt].disch_dt = format(e.disch_dt_tm, "mm/dd/yy hh:mm;;d")
	tob->plist[cnt].updt_dt = format(e.updt_dt_tm, "mm/dd/yy hh:mm;;d")
	tob->plist[cnt].nurse_unit = uar_get_code_description(elh.loc_nurse_unit_cd)
	tob->plist[cnt].room = if(elh.loc_room_cd != 0) uar_get_code_display(elh.loc_room_cd) else ' ' endif
	tob->plist[cnt].bed_number = if(elh.loc_bed_cd != 0) uar_get_code_display(elh.loc_bed_cd) else ' ' endif
 
with nocounter
 
call echorecord(tob)
 
;-------------------------------------------------------------------------------------------------------------
;Get Admission form details
select into $outdev
 
ce.encntr_id;, fin = tob->plist[d.seq].fin
, event =  uar_get_code_display(ce.event_cd)
, verified_dt = format(ce.verified_dt_tm, "mm/dd/yy hh:mm;;d")
;, nu = tob->plist[d.seq].nurse_unit, ce.event_id
 
from (dummyt d with seq = value(size(tob->plist,5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = tob->plist[d.seq].encntrid
	and ce.person_id = tob->plist[d.seq].personid
	and ce.result_status_cd in (25,34,35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.event_cd in (adult_pat_his_var, procedure_chklist_var, OB_triage_var, OB_pat_his_var, pre_admit_asses_var,
			preop_chklist_var, pedi_hist_var, OB_admission_var, newborn_hist_var,resident_hist_var, BEH_hist_var,
			BH_admit_hist_var,OB_pat_his1_var, newborn_hist1_var,adult_pat_his1_var, newborn_hist2_var, OB_triage1_var,
			pre_procedure_var, nurse_admit_var, obe_admit_var, ob_admit_var, nurse_peds_var, bh_nurse_ped_var,
			bh_nurse_var, res_ltc_var,nurse_pnrc_var, hospice_admit_var, ob_triage_wflo_var, admit_hist_var)
 
order by ce.encntr_id, ce.event_cd, ce.event_id
 
Head ce.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(tob->plist, 5) ,ce.encntr_id ,tob->plist[cnt].encntrid)
 	admission_form = fillstring(3000," ")
 	procedure_chklist_form = fillstring(500," ")
 
Head ce.event_id
 	case (ce.event_cd)
		of adult_pat_his_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of procedure_chklist_var:
			procedure_chklist_form = build2(trim(procedure_chklist_form),'[' ,trim(event),'-',verified_dt,']',',')
		of OB_triage_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of OB_pat_his_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of pre_admit_asses_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of preop_chklist_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of pedi_hist_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of OB_admission_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of adult_EBP_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of adult_EBN_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of newborn_hist_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of resident_hist_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of BEH_hist_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of BH_admit_hist_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of OB_pat_his1_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of newborn_hist1_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of adult_pat_his1_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of newborn_hist2_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of OB_triage1_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of pre_procedure_var:
			procedure_chklist_form = build2(trim(procedure_chklist_form),'[' ,trim(event),'-',verified_dt,']',',')
		of nurse_admit_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of obe_admit_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of ob_admit_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of nurse_peds_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of bh_nurse_ped_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of bh_nurse_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of res_ltc_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of nurse_pnrc_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of hospice_admit_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of ob_triage_wflo_var:
			admission_form = build2(trim(admission_form),'[' ,trim(event),'-',verified_dt,']',',')
		of admit_hist_var:
			tob->plist[idx].admit_hist_wfl = build2(trim(event),'-',verified_dt)
 
	endcase
 
foot ce.encntr_id
	tob->plist[idx].form_name = replace(trim(admission_form),",","",2)
	tob->plist[idx].procedure_chklist = replace(trim(procedure_chklist_form),",","",2)
with nocounter
 
;call echorecord(tob)
 
;-------------------------------------------------------------------------------------------------------------
/*Removed as per Lori on 12/03/19
;Get DTA responses
 
select into 'nl:'
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.performed_dt_tm "@SHORTDATETIME"
 
from (dummyt d with seq = size(tob->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = tob->plist[d.seq].encntrid
 	and ce.result_status_cd in (25,34,35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and (cnvtlower(ce.result_val) = 'unable to obtain'
		OR(cnvtlower(ce.result_val) = 'unable due to cognitive impairment/mental health status'))
 
order by ce.encntr_id, ce.event_cd, ce.event_id, ce.performed_dt_tm
 
Head ce.encntr_id
	dcnt = 0
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(tob->plist, 5) ,ce.encntr_id ,tob->plist[cnt].encntrid)
Head ce.event_id
	dcnt += 1
	call alterlist(tob->plist[idx].dta, dcnt)
	tob->plist[idx].dta[dcnt].dta_used = trim(uar_get_code_display(ce.event_cd))
	tob->plist[idx].dta[dcnt].dta_response = trim(ce.result_val)
 	tob->plist[idx].dta[dcnt].dta_dt = format(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
 
with nocounter
 
call echorecord(tob)*/
 
;-------------------------------------------------------------------------------------------------------------
 
 
select distinct into $outdev
	facility = trim(substring(1, 100, tob->plist[d1.seq].facility))
	, fin = substring(1, 10, tob->plist[d1.seq].fin)
	, patient_name = trim(substring(1, 50, tob->plist[d1.seq].pat_name))
	, nurse_unit = trim(substring(1, 50, tob->plist[d1.seq].nurse_unit))
	, room = trim(substring(1, 50, tob->plist[d1.seq].room))
	, Bed = trim(substring(1, 10, tob->plist[d1.seq].bed_number))
	, patient_type = trim(substring(1, 50, tob->plist[d1.seq].pat_type))
	, admit_dt = trim(substring(1, 20, tob->plist[d1.seq].admit_dt))
	, discharge_dt = trim(substring(1, 20, tob->plist[d1.seq].disch_dt))
	, pre_procedure_checklist_form = trim(substring(1, 500, tob->plist[d1.seq].procedure_chklist))
	, admission_form = if(substring(1,10, tob->plist[d1.seq].form_name) != ' ')
					trim(substring(1, 3000, tob->plist[d1.seq].form_name))
				else 'NO FORM AVAILABLE' endif
	, admission_history_Nursing_form = trim(substring(1, 500, tob->plist[d1.seq].admit_hist_wfl))
 
	;, dta_charted = trim(substring(1, 200, tob->plist[d1.seq].dta[d2.seq].dta_used))
	;, dta_response = trim(substring(1, 300, tob->plist[d1.seq].dta[d2.seq].dta_response))
	;, dta_dt = trim(substring(1, 20, tob->plist[d1.seq].dta[d2.seq].dta_dt))
 
from
	(dummyt   d1  with seq = size(tob->plist, 5))
	;, (dummyt   d2  with seq = 1)
 
plan d1 ;where maxrec(d2, size(tob->plist[d1.seq].dta, 5))
;join d2
 
order by nurse_unit, admit_dt, patient_name
 
with nocounter, separator=" ", format
 
#exitscript
 
end go
 
 
 
 
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Oct'2019
	Solution:			Quality
	Source file name:	      cov_phq_stroke_gwtg_feed.prg
	Object name:		cov_phq_stroke_gwtg_feed
	Request#:			6420
	Program purpose:	      Stroke feed for Patient Management Tool
	Executing from:		Ops
 	Special Notes:          As per Stroke PMT Uploader 2.0 Coding Instructions
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_stroke_gwtg_feed go
create program cov_phq_stroke_gwtg_feed
 
prompt
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE"
	, "FacilityListBox" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;Final clinical diagnosis related to stroke
declare stk2_ischemic_var      = vc with constant('ischemic stroke'), protect
declare stk3_transient_var     = vc with constant('transient ischemic attack (< 24 hours)'), protect
declare stk4_subarachnoid_var  = vc with constant('subarachnoid hemorrhage'), protect
declare stk5_intracerebral_var = vc with constant('intracerebral hemorrhage'), protect
declare stk6_stroke_not_var    = vc with constant('stroke not otherwise specified'), protect
;declare stk7_no_stroke_var     = vc with constant('no stroke related diagnosis'), protect
declare stk8_elective_var      = vc with constant('elective carotid intervention only'), protect
 
;No Stroke Related Diagnosis
declare 1_migraine_var    = vc with constant('migraine'), protect
declare 2_seizure_var     = vc with constant('seizure'), protect
declare 3_delirium_var    = vc with constant('delirium'), protect
declare 4_electrolyte_var = vc with constant('electrolyte or metabolic imbalance'), protect
declare 5_functional_var  = vc with constant('functional disorder'), protect
declare 6_other_var       = vc with constant('other'), protect
declare 7_uncertain_var   = vc with constant('uncertain'), protect
declare no_stk_diagnosis  = vc with noconstant(' ')
 
;Comfort Measure
declare comfort_meas_var  = f8 with constant(uar_get_code_by("DISPLAY", 200, "Comfort Measures")),protect
 
;Discharge Disposition
declare 1_home_var            = f8 with constant(638671.00),protect  ;**Home or Self Care 01
declare 2_hospic_var          = f8 with constant(312910.00),protect  ;Home Hospice 50
declare 3_health_care_var     = f8 with constant(638672.00),protect  ;*Home Health Care Visits (not DME) 06
declare 4_acute_care_var      = f8 with constant(638660),protect	   ;Other Healthcare Faciltiy Not Defined 70
declare 5_short_hospital_var  = f8 with constant(2554367765.00),protect	;*Short-term Gen Hospital for InptCare 02
declare 5_skilled_nursing_var = f8 with constant(4190893.00),protect ;*Skilled Nursing Facility (SNF) 03
declare 5_inpatient_rehab_var = f8 with constant(312913.00),protect  ;*Inpatient Acute Rehab 62
declare 5_longterm_care_var   = f8 with constant(312911.00),protect  ;Long Term Acute Care Hospital 63
declare 5_Intermediate_var    = f8 with constant(638673.00),protect  ;Intermediate Care FacilityNon-skilled 04
declare 5_childerns_hosp_var  = f8 with constant(4510195),protect    ;Transfer to Childrens Hospital 05
declare 5_VA_hosp_var         = f8 with constant(4225260),protect	   ;VA Hospital or VA Nursing Home 43
declare 5_psych_hosp_var      = f8 with constant(685148),protect	   ;*Psych Unit or Psych Hospital 65
declare 5_resident_hosp_var   = f8 with constant(638663),protect	   ;Residential Hospice (Inpatient) 51
declare 6_expired_var         = f8 with constant(638666.00),protect  ;*Expired 20
declare 7_left_against_var    = f8 with constant(312916.00),protect  ;*Left Against Medical Advice 07
;8 - Not Documented or Unable to Determine (UTD)
 
 
declare discharge_disposition = vc with noconstant('')
declare other_facility = vc with noconstant('')
declare final_diagnosis = vc with noconstant(' ')
declare diag_dt = dq8 with noconstant(0)
declare diag_dt = f8 with noconstant(0)
 
;-----------------------------------------------------------------------------------------------
 
Record stroke(
	1 plist[*]
		2 encntrid = f8
		2 admit_reason = vc
		2 patient_os_id = vc
		2 stroke_diagnosis = vc
		2 gs_stroketype = vc
		2 stroke_diag_dt = dq8
		2 stroke_diag_id = f8
		2 gs_mimics = vc
		2 cryp_etiology = vc
		2 cryp_stetio = vc
		2 jc_principaldiagnosis = vc
		2 jc_princicd10diagnosis = vc
		2 gs_comfortonly = vc
		2 jc_disposition = vc
		2 gs_othfacility = vc
		2 jc_clinical = vc
		2 jc_carotid  = vc
		2 gs_symptomlocation = vc
		2 gs_patientarrival = vc
 		2 jc_edpatient = vc
 		2 gs_placercd = vc
 		2 gs_admitfrom = vc
 		2 gs_prehosp_ems = vc
 		2 jc_arrdatetime = vc
 		2 jc_arrdatetime_precision = vc
 
)
 
;----------------- Helper ---------------------------------------
Record pat(
	1 list[*]
		2 facility_cd = f8
		2 fin = vc
		2 admit_dt = dq8
		2 admit_reason = vc
		2 personid = f8
		2 encntrid = f8
		2 pat_name = vc
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get all Discharged patients
select into 'nl:'
 
from
	 encounter e
	 , person p
	 , encntr_alias ea
 
plan e where e.loc_facility_cd = $facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.disch_dt_tm is not null
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by e.encntr_id
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	call alterlist(pat->list, cnt)
Detail
	pat->list[cnt].facility_cd = e.loc_facility_cd
	pat->list[cnt].personid = p.person_id
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].pat_name = p.name_full_formatted
	pat->list[cnt].fin = ea.alias
	pat->list[cnt].admit_dt = if(e.reg_dt_tm is not null) e.reg_dt_tm else e.arrive_dt_tm endif
	pat->list[cnt].admit_reason = e.reason_for_visit
 
with nocounter
 
;--------------------------------------------------------------------------------------
;Load into Stroke record structure
select into 'nl:'
enc = pat->list[d.seq].encntrid
 
from (dummyt d with seq = value(size(pat->list, 5)))
 
order by enc
 
Head report
	scnt = 0
Head enc
	scnt += 1
	call alterlist(stroke->plist, scnt)
Detail
	stroke->plist[scnt].patient_os_id = cnvtstring(enc)
	stroke->plist[scnt].encntrid = enc
	stroke->plist[scnt].admit_reason = pat->list[d.seq].admit_reason
	;assign default value
 	stroke->plist[scnt].gs_comfortonly = '4'
 	stroke->plist[scnt].gs_stroketype = '7'
 
with nocounter
 
;--------------------------------------------------------------------------------------
;Final clinical diagnosis related to stroke  ***** gs_stroketype *****
 
select into 'nl:'
 
d.encntr_id, diag_type = uar_get_code_display(d.diag_type_cd), d.diag_type_cd
, d.diagnosis_display, d.diag_priority
, n.source_string, icd = uar_get_code_display(n.source_vocabulary_cd)
 
from (dummyt d1 with seq = value(size(pat->list, 5)))
	, diagnosis d
	, nomenclature n
 
plan d1
 
join d where d.encntr_id = pat->list[d1.seq].encntrid
	and d.active_ind = 1
	and d.diag_type_cd = 88 ;Discharge ;89 Final not documented for these variables
	and cnvtlower(d.diagnosis_display) in(stk2_ischemic_var, stk3_transient_var, stk4_subarachnoid_var,
			stk5_intracerebral_var, stk6_stroke_not_var,  stk8_elective_var)
	and d.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 
join n where n.nomenclature_id = d.nomenclature_id
 
order by d.encntr_id
 
Head d.encntr_id
	final_diagnosis = '', diag_dt = 0, diag_id = 0
      num = 0
      idx = 0
	idx = locateval(num, 1, size(stroke->plist,5), d.encntr_id, stroke->plist[num].encntrid)
Detail
	if(idx > 0)
		case(cnvtlower(d.diagnosis_display))
			of stk2_ischemic_var:
				if(final_diagnosis = '')
					final_diagnosis = '2'
					diag_dt = d.diag_dt_tm
					diag_id = d.diagnosis_id
				endif
			of stk3_transient_var:
				if(final_diagnosis = '')
					final_diagnosis = '3'
					diag_dt = d.diag_dt_tm
					diag_id = d.diagnosis_id
				endif
			of stk4_subarachnoid_var:
				if(final_diagnosis = '')
					final_diagnosis = '4'
					diag_dt = d.diag_dt_tm
					diag_id = d.diagnosis_id
				endif
			of stk5_intracerebral_var:
				if(final_diagnosis = '')
					final_diagnosis = '5'
					diag_dt = d.diag_dt_tm
					diag_id = d.diagnosis_id
				endif
			of stk6_stroke_not_var:
				if(final_diagnosis = '')
					final_diagnosis = '6'
					diag_dt = d.diag_dt_tm
					diag_id = d.diagnosis_id
				endif
			of stk8_elective_var:
				if(final_diagnosis = '')
					final_diagnosis = '8'
					diag_dt = d.diag_dt_tm
					diag_id = d.diagnosis_id
				endif
		endcase
	endif
 
Foot d.encntr_id
	stroke->plist[idx].stroke_diagnosis = d.diagnosis_display
	stroke->plist[idx].gs_stroketype = final_diagnosis
 	stroke->plist[idx].stroke_diag_dt = diag_dt
 	stroke->plist[idx].stroke_diag_id = diag_id
with nocounter
 
;--------------------------------------------------------------------------------------------------
;No Stroke Related Diagnosis ***** gs_mimics *****
 
select into 'nl:'
 
d.encntr_id, diag_type = uar_get_code_display(d.diag_type_cd), d.diag_type_cd
, d.diagnosis_display, d.diag_priority
, n.source_string, icd = uar_get_code_display(n.source_vocabulary_cd)
 
from (dummyt d1 with seq = value(size(pat->list, 5)))
	, diagnosis d
	, nomenclature n
 
plan d1
 
join d where d.encntr_id = pat->list[d1.seq].encntrid
	and d.active_ind = 1
	and cnvtlower(d.diagnosis_display) in(1_migraine_var, 2_seizure_var, 3_delirium_var, 4_electrolyte_var,
				5_functional_var, 6_other_var, 7_uncertain_var, no_stk_diagnosis)
 
join n where n.nomenclature_id = d.nomenclature_id
 
order by d.encntr_id
 
Head d.encntr_id
	no_stk_diagnosis = ''
      num = 0
      idx = 0
	idx = locateval(num, 1, size(stroke->plist,5), d.encntr_id, stroke->plist[num].encntrid)
Detail
	if(idx > 0)
		case(cnvtlower(d.diagnosis_display))
			of 1_migraine_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '1' endif
			of 2_seizure_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '2' endif
			of 3_delirium_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '3' endif
			of 4_electrolyte_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '4' endif
			of 5_functional_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '5' endif
			of 6_other_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '6' endif
			of 7_uncertain_var:
				if(no_stk_diagnosis = '') no_stk_diagnosis = '7' endif
		endcase
	endif
 
Foot d.encntr_id
	stroke->plist[idx].gs_mimics = no_stk_diagnosis
 
with nocounter
 
;---------------------------------------------------------------------------------------------------
;Select documented stroke etiology (select all that apply):
 
;Get with Lori - how to identify this in patients chart
 
/*1: Large-artery atherosclerosis (e.g., carotid or basilar artery stenosis)
2: Cardioembolism (e.g., atrial fibrillation/flutter, prosthetic heart valve, recent MI)
3: Small-vessel occlusion (e.g., Subcortical or brain stem lacunar infarction <1.5 cm)
4: Stroke of other determined etiology (e.g., dissection, vasculopathy, hypercoagulable or hematologic disorders.
5: Cryptogenic Stroke (Stroke of undetermined etiology)*/
 
 
;--------------------------------------------------------------------------------------------------
;Was the stroke etiology documented in the patient medical record  ***** cryp_etiology  *****
 
;Yes/No
 
;--------------------------------------------------------------------------------------------------
;ICD-9-CM Principal Diagnosis Code  ***** jc_principaldiagnosis *****
 
 
;--------------------------------------------------------------------------------------------------
;ICD-10-CM Principal Diagnosis Code ***** jc_princicd10diagnosis *****
 
select into 'nl:'
 
d.encntr_id, diag_type = uar_get_code_display(d.diag_type_cd), d.diag_type_cd
, d.diagnosis_display, d.clinical_diag_priority, icd10 = n.source_identifier
, n.source_string, n.source_vocabulary_cd, icd = uar_get_code_display(n.source_vocabulary_cd)
 
from (dummyt d1 with seq = value(size(pat->list, 5)))
	, diagnosis d
	, nomenclature n
 
plan d1
 
join d where d.encntr_id = pat->list[d1.seq].encntrid
	and d.active_ind = 1
	and d.clinical_diag_priority = 1 ;Principal diagnosis
 
join n where n.nomenclature_id = d.nomenclature_id
	and n.source_vocabulary_cd = 19350056.00	;ICD-10-CM
 
order by d.encntr_id
 
Head d.encntr_id
      num = 0
      idx = 0
	idx = locateval(num, 1, size(stroke->plist,5), d.encntr_id, stroke->plist[num].encntrid)
Detail
	if(idx > 0)
		stroke->plist[idx].jc_princicd10diagnosis = trim(n.source_identifier)
	endif
 
with nocounter
 
;--------------------------------------------------------------------------------------------------
;When is the earliest documentation of comfort measures only? *** gs_comfortonly ***
select into 'nl:'
 
 enc = pat->list[d1.seq].encntrid, o.encntr_id
, o.order_mnemonic
, catalog = uar_get_code_description(o.catalog_cd), o.catalog_cd
, admit_dt = format(pat->list[d1.seq].admit_dt, 'mm/dd/yyyy;;d')
, ord_dt = format(o.orig_order_dt_tm, "MM/DD/YYYY")
, zero_day = format(pat->list[d1.seq].admit_dt, 'mm/dd/yyyy;;d')
, first_day = format(datetimeadd(cnvtdatetime(pat->list[d1.seq].admit_dt), 1), 'mm/dd/yyyy;;d')
, second_day = format(datetimeadd(cnvtdatetime(pat->list[d1.seq].admit_dt), 2), 'mm/dd/yyyy;;d')
 
from (dummyt d1 with seq = value(size(pat->list, 5)))
	, orders o
 
plan d1
 
join o where o.encntr_id = pat->list[d1.seq].encntrid
	and o.active_ind = 1
	and o.catalog_type_cd = 2515.00 ;Patient Care
	and o.catalog_cd = comfort_meas_var
	and o.order_id = (select min(o1.order_id) from orders o1 where o.catalog_cd = o1.catalog_cd
				 group by o1.encntr_id, o1.catalog_cd)
order by enc
 
Head enc
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(stroke->plist,5), enc, stroke->plist[cnt].encntrid)
	;call echo(build2('enc = ', enc, '--ord_dt = ', ord_dt,'----- admit = ',admit_dt, '0day = ', zero_day
	;, '--1day =',first_day,'--2day = ', second_day))
Detail
	if(idx > 0 )
		stroke->plist[idx].gs_comfortonly =
		 if(ord_dt = zero_day or ord_dt = first_day ) '1'
		 elseif(ord_dt = second_day or o.orig_order_dt_tm > cnvtdatetime(pat->list[d1.seq].admit_dt)) '2'
		 elseif(o.orig_order_dt_tm < cnvtdatetime(pat->list[d1.seq].admit_dt)) '3'
		 endif
	endif
 
With nocounter;, outerjoin = d1
 
;-------------------------------------------------------------------------------------------------------
;What was the patient’s discharge disposition on the day of discharge?
select into 'nl:'
 
e.encntr_id, dispo = uar_get_code_display(e.disch_disposition_cd), e.disch_disposition_cd
 
from (dummyt d1 with seq = value(size(pat->list, 5)))
	, encounter e
 
plan d1
 
join e where e.encntr_id = pat->list[d1.seq].encntrid
	and e.active_ind = 1
 
order by e.encntr_id
 
Head e.encntr_id
	discharge_disposition = '', other_facility = ''
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(stroke->plist,5), e.encntr_id, stroke->plist[cnt].encntrid)
Detail
	case(e.disch_disposition_cd)
		of 1_home_var:
			discharge_disposition = '1'
		of 2_hospic_var:
			discharge_disposition = '2'
		of 3_health_care_var:
			discharge_disposition = '3'
		of 4_acute_care_var:
			discharge_disposition = '4'
		of 5_skilled_nursing_var:
			discharge_disposition = '5'
			other_facility = '1'
		of 5_inpatient_rehab_var:
			discharge_disposition = '5'
			other_facility = '2'
		of 5_longterm_care_var:
			discharge_disposition = '5'
			other_facility = '3'
		of 5_Intermediate_var:
			discharge_disposition = '5'
			other_facility = '4'
		of 5_short_hospital_var:
			discharge_disposition = '5'
			other_facility = '5'
		of 5_childerns_hosp_var:
			discharge_disposition = '5'
			other_facility = '5'
		of 5_VA_hosp_var:
			discharge_disposition = '5'
			other_facility = '5'
		of 5_psych_hosp_var:
			discharge_disposition = '5'
			other_facility = '5'
		of 5_resident_hosp_var:
			discharge_disposition = '5'
			other_facility = '5'
		of 6_expired_var:
			discharge_disposition = '6'
		of 7_left_against_var:
			discharge_disposition = '7'
		else
			discharge_disposition = '8'
	endcase
 
Foot e.encntr_id
	stroke->plist[idx].jc_disposition = discharge_disposition
	stroke->plist[idx].gs_othfacility = other_facility
 
with nocounter
;---------------------------------------------------------------------------------------------------------------
;Clinical Trial
 
 
;---------------------------------------------------------------------------------------------------------------
;Was this patient admitted for the sole purpose of performance of elective carotid intervention?
 
 
;---------------------------------------------------------------------------------------------------------------
;Patient location when stroke symptoms discovered  *** gs_symptomlocation ***
 
select distinct into $outdev
 
 enc = stroke->plist[d2.seq].encntrid, stroke_type = stroke->plist[d2.seq].gs_stroketype
, diag = trim(substring(1,300, stroke->plist[d2.seq].stroke_diagnosis))
 ,stroke_pat_loc = trim(uar_get_code_display(elh.loc_facility_cd)), admit_reason = stroke->plist[d2.seq].admit_reason
 
from (dummyt d2 with seq = value(size(stroke->plist,5)))
	, diagnosis d
	,(left join encntr_loc_hist elh on (elh.encntr_id = d.encntr_id
		and (cnvtdatetime(stroke->plist[d2.seq].stroke_diag_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
		and elh.active_ind = 1))
 
plan d2 where stroke->plist[d2.seq].gs_stroketype != '7'
 
join d where d.encntr_id = stroke->plist[d2.seq].encntrid

join elh
 
order by enc
 
with nocounter, separator=" ", format

*** Above query is pulling correct patient stroke location - move to record structure once below statment is confirmed.
*** AS of 10/25/19 meeting with Lori and Jutanna - no need to map this to PMT database value as per 
*** GWTG guidelines(abstractors will do this).  
 
/*
 
Head d.encntr_id
	;Since we have access to see only Covenant hospitals flagging all stroke patients to '4' or '9'
	if(stroke_pat_loc != '')
		stroke->plist[d2.seq].gs_symptomlocation = '4'
	else
		stroke->plist[d2.seq].gs_symptomlocation = '9'
	endif
 
with nocounter
 
 
 
call echorecord(stroke)
;with nocounter, separator=" ", format
 
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 
 
/*
select * from nomenclature n where cnvtlower(n.source_string) in(
		'Ischemic stroke', 'Transient Ischemic Attack (< 24 hours)',  'Subarachnoid Hemorrhage',
 		'Intracerebral Hemorrhage',  'Stroke not otherwise specified', 'No stroke related diagnosis',
 		'Elective Carotid Intervention only')
 

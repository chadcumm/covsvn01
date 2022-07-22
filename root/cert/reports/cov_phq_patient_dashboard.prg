/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Mar'2019
	Solution:			Quality/INA
	Source file name:	      cov_phq_patient_dashboard.prg
	Object name:		cov_phq_patient_dashboard
	Request#:			3805
	Program purpose:	      Snapshot of patient documentation
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_gstest3:dba go
create program cov_gstest3:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	;<<hidden>>"Select Facility" = 0
	, "Select Nurse Unit" = 0 

with OUTDEV, nurse_unit
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare inpatient_var    = f8 with constant(uar_get_code_by('DISPLAY', 71, 'Inpatient')), protect
declare emergency_var    = f8 with constant(uar_get_code_by('DISPLAY', 71, 'Emergency')), protect
declare day_surg_var     = f8 with constant(uar_get_code_by('DISPLAY', 71, 'Day Surgery')), protect
declare observatn_var    = f8 with constant(uar_get_code_by('DISPLAY', 71, 'Observation')), protect
declare outpat_bed_var   = f8 with constant(uar_get_code_by('DISPLAY', 71, 'Outpatient in a Bed')), protect
 
declare admit_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Admitting Physician')), protect
declare atten_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Attending Physician')), protect
declare cnslt_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Consulting Physician')), protect
declare pcp_var          = f8 with constant(uar_get_code_by("DISPLAYKEY",331,"PRIMARYCAREPHYSICIAN")),protect
 
declare adls_var         = f8 with constant(uar_get_code_by('DISPLAY', 72, 'ADLs')), protect
declare ambu_assist_var  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Ambulation Assistance')), protect
declare bath_adl_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Bathing ADL Index')), protect
declare dress_adl_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Dressing ADL Index')), protect
declare toilet_adl_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Toileting ADL Index')), protect
declare conti_adl_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Continence ADL Index')), protect
declare feed_adl_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Feeding ADL Index')), protect
declare bed_assist_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Bed Mobility Assistance')), protect
declare transfer_bed_var = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Transferring Bed or Chair ADL Index')), protect
 
declare advance_dir_var  = f8 with constant(uar_get_code_by('DISPLAY', 72,  'Advance Directive')), protect
declare assit_device_var = f8 with constant(uar_get_code_by('DISPLAY', 72,  'Assistive Device')), protect
declare spec_device_var  = f8 with constant(uar_get_code_by('DISPLAY', 72,  'Special Orthopedic Devices')), protect
 
declare resucite_var     = f8 with constant(uar_get_code_by('DESCRIPTION', 200, 'Resuscitation Status/Medical Interventions')), protect
;declare resucite_var     = f8 with constant(2958523.00)
declare pat_isolat_var   = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Patient Isolation')), protect
declare dish_isolat_var  = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Discharge Isolation')), protect
declare ed_isolat_var    = f8 with constant(uar_get_code_by('DISPLAY', 200, 'ED Place Patient in Designated Isolation')), protect
declare seizr_pre_var    = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Precaution Seizure')), protect
declare ed_seizr_pre_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'ED Seizure Precaution')), protect
 
declare intpre_svrc_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Interpretation Type')), protect
  ;42963519.00	Interpretation Type
declare pref_mode_comm_var  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Preferred Mode of Communication')), protect
   ;37125793.00	Preferred Mode of Communication
declare language_var        = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Preferred Spoken Language')), protect
   ;2562390221.00	Preferred Spoken Language
 
 
declare intpre_sevrc_cmt_var = f8 with constant(uar_get_code_by('DISPLAY',72, 'Interpreter Services Comment')), protect
declare chief_complnt_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Chief Complaint')), protect
 
declare env_safety_var      = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Environmental Safety Implemented')), protect
declare mng_sensory_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Manage Sensory Impairment')), protect
declare activity_status_var = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Activity Status ADL')), protect
declare pat_position_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Patient Position')), protect
declare head_bed_pos_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Head of Bed Position')), protect
declare head_contra_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Head of Bed Contraindications')), protect
declare tm_dang_bed_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Time Dangled at Bedside')), protect
declare tm_up_chair_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Time Up in Chair')), protect
declare ambu_pat_efrt_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Ambulation Patient Effort')), protect
declare ambu_mins_var       = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Ambulation Minutes')), protect
declare urinary_elim_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Urinary Elimination')), protect
 
declare f_hist_fall_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'History of Fall in Last 3 Months Morse')), protect
declare f_second_dig_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Presence of Secondary Diagnosis Morse')), protect
declare f_ambu_aid_var      = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Use of Ambulatory Aid Morse')), protect
declare f_ivhep_fall_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'IV/Heparin Lock Fall Risk Morse')), protect
declare f_gait_weak_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Gait Weak or Impaired Fall Risk Morse')), protect
declare f_mental_stat_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Mental Status Fall Risk Morse')), protect
declare f_fall_high_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Falls High Risk Safety Precautions')), protect
declare f_age_85_var        = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Age over 85 & frail interventions')), protect
declare f_bone_dis_var      = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Bone Disorders Interventions')), protect
declare f_coagu_disord_var  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Coagulation Disorder Interventions')), protect
declare f_surg_anes_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Surgery/Recent Anesthesia Interventions')), protect
declare f_fall_score_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Morse Fall Score')), protect
declare f_sph_score_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'SPH Fall Risk Score')), protect
 
;Allergies
declare severe_var      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12022,"SEVERE")),PROTECT
declare food_var	      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12020,"FOOD")),PROTECT
declare drug_var	      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12020,"DRUG")),PROTECT
declare env_var	      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12020,"ENVIRONMENT")),PROTECT
 
; No need to show as per Lori
/*declare numeric_scale_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Numeric Rating Pain Scale")),protect
declare faces_scale_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "FACES Pain Scale Rating")),protect
declare cpot_scale_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "CPOT Total Score")),protect
declare flacc_scale_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "FLACC Score")),protect
declare nips_scale_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "NIPS Pain Assessment Score")),protect*/
 
;Protocols
declare calci_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Calcium Replacement Protocol')), protect
declare magne_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Magnesium Replacement Protocol')), protect
declare phos_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Phosphorus Replacement Protocol')), protect
declare pota_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Potassium Replacement Protocol')), protect
declare cr_calci_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'CRRT Calcium Replacement Protocol')), protect
declare cr_magne_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'CRRT Magnesium Replacement Protocol')), protect
declare cr_phos_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'CRRT Phosphorous Replacement Protocol')), protect
declare cr_pota_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'CRRT Potassium Replacement Protocol')), protect
declare cv_surg_mag_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'CV Surgery Magnesium Replacement Protocol')), protect
declare cv_surg_pota_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'CV Surgery Potassium Replacement Protocol')), protect
declare dka_pota_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'DKA Potassium Replacement Protocol')), protect
declare hypo_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Hypoglycemia Protocol')), protect
declare hypo_insu_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Hypoglycemia Protocol for Insulin Drip')), protect
declare rt_eval_var = f8 with constant(uar_get_code_by('DESCRIPTION', 200, 'Initiate RT Evaluate and Treat per Protocol')), protect
declare oxy_var = f8 with constant(uar_get_code_by('DESCRIPTION', 200, 'Initiate Oxygen Therapy Per Protocol (RT)')), protect
;declare vent_var = f8 with constant(uar_get_code_by('DESCRIPTION', 200, 'Initiate Vent Weaning per Protocol')), protect
declare vent_var = f8 with constant(2553568051.00) ;Initiate Vent Weaning Per Protocol
declare cv_vent_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Initiate CV Vent Weaning Per Protocol')), protect
declare awak_var = f8 with constant(uar_get_code_by('DESCRIPTION', 200, 'Initiate Spontaneous Awakening Trial (SAT) Protocol')), protect
declare move_var = f8 with constant(uar_get_code_by('DISPLAY', 200, 'Initiate MOVE ME Protocol')), protect
 
declare isolat_name      = vc with noconstant(' '), protect
declare isolat_detail    = vc with noconstant(' '), protect
declare isolat_dt        = vc with noconstant(' '), protect
declare seizure_preca    = vc with noconstant(' '), protect
declare seizure_preca_dt = vc with noconstant(' '), protect
declare asst_device      = vc with noconstant(' '), protect
declare asst_device_dt   = vc with noconstant(' '), protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD mas(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 fin = vc
		2 mrn = vc
		2 personid = f8
 		2 encntrid = f8
		2 pat_name = vc
		2 pat_pin = vc
		2 nurse_unit = vc
		2 room = vc
		2 bed = vc
		2 age = vc
		2 dob = vc
		2 gender = vc
		2 admit_dt = vc
		2 target_disch_dt = vc
		2 pat_type = vc
		2 encntr_class = vc
		2 encntr_class_type = vc
		2 reason_visit = vc
		2 admit_prsnl = vc
		2 attend_prsnl = vc
		2 consult_prsnl = vc
		2 pcp_prsnl = vc
		2 med_service = vc
		2 med_service_dt = vc
		2 advance_dir = vc
		2 advance_dir_dt = vc
		2 diet = vc
		2 diet_detail = vc
		2 diet_order_dt = vc
		2 resucite = vc
		2 resucite_detail = vc
		2 resucite_dt = vc
		2 isolation = vc
		2 isolation_detail = vc
		2 isolation_dt = vc
		2 assit_device = vc
		2 assit_device_dt = vc
		2 spec_device = vc
		2 spec_device_dt = vc
		2 seizr_precaution = vc
		2 seizr_precaution_detail = vc
		2 seizr_precaution_dt = vc
		2 intpre_service = vc
		2 intpre_service_dt = vc
		2 intpre_service_cmt = vc
		2 intpre_service_cmt_dt = vc
		2 language = vc
		2 pref_mode_comm = vc
		2 chief_compliant = vc
		2 chief_compliant_dt = vc
		2 urinary_elim =  vc
		2 urinary_elim_dt =  vc
		2 living = vc ;activities of daily living
		2 ambulation = vc ;ambulation
		2 activity_orders = vc ;activity orders
		2 fall = vc ;fall interventions
		2 diagnoses = vc ;diagnoses
		2 allergy = vc ;allergy
 		2 protocol = vc ;protocols
 
		/*2 living[*] ;activities of daily living
			3 event = vc
			3 result = vc
			3 event_dt = vc
		2 ambu[*] ;ambulation
			3 event = vc
			3 result = vc
			3 event_dt = vc
		2 oalist[*] ;activity orders
			3 activity = vc
			3 activity_detail = vc
			3 activity_dt = vc
		2 fall[*] ;fall interventions
			3 event = vc
			3 result = vc
			3 event_dt = vc
		2 dg[*] ;diagnoses
			3 dg_name = vc
			3 dg_dt = vc
			3 priority = i4
		2 allergy[*]
			3 allergy_base = vc
			3 substance_type = vc
 			3 severity_level = vc
 		2 protocol[*]
 			3 protocol_type = vc
 			3 order_dt = vc*/
)
 
/*Looking good in layout builder - used Fall field as an example. Use below to escape/add some cahrs. Header box should repeat every page.
replace(replace(trim(PLIST_FALL),'-',char(32),0),';', char(13),0)*/
 
;------------------------------------------------------------------------------------------
;Main Qualification
select into 'nl:'
 
fin = ea.alias, e.encntr_id
, e_class = uar_get_code_display(e.encntr_class_cd)
, e_type_class = uar_get_code_display(e.encntr_type_class_cd)
, pin = if( trim(lt.long_text)!= '0' or trim(lt.long_text)!= ' ')	trim(lt.long_text) else ' ' endif
 
from
	encounter e
	, encntr_loc_hist elh
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, encntr_info ei
	, long_text lt
 
plan elh where elh.loc_nurse_unit_cd = $nurse_unit ;elh.encntr_id = 114036785
	and elh.active_ind = 1
	and elh.active_status_cd = 188 ;active
	and (elh.beg_effective_dt_tm <= sysdate and elh.end_effective_dt_tm >= sysdate)
 
join e where e.encntr_id = elh.encntr_id
	and e.encntr_status_cd = 854.00 ;Active
	and e.disch_dt_tm is null
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1079
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join ei where ei.encntr_id = outerjoin(e.encntr_id)
	and ei.info_sub_type_cd = outerjoin(2560968823.00) ;Patient PIN
	and ei.active_ind = outerjoin(1)
 
join lt where lt.long_text_id = outerjoin(ei.long_text_id)
	and lt.active_ind = outerjoin(1)
 
order by e.encntr_id
 
Head report
	cnt = 0
	call alterlist(mas->plist, 100)
 
Head e.encntr_id
	cnt += 1
	mas->rec_cnt = cnt
	call alterlist(mas->plist, cnt)
Detail
	mas->plist[cnt].facility = uar_get_code_description(e.loc_facility_cd)
	mas->plist[cnt].fin = ea.alias
	mas->plist[cnt].mrn = ea1.alias
	mas->plist[cnt].personid = e.person_id
	mas->plist[cnt].encntrid = e.encntr_id
	mas->plist[cnt].pat_name = p.name_full_formatted
	mas->plist[cnt].pat_pin = pin
	mas->plist[cnt].nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	mas->plist[cnt].room = if(elh.loc_room_cd != 0) uar_get_code_display(elh.loc_room_cd) else ' ' endif
	mas->plist[cnt].bed = if(elh.loc_bed_cd != 0) uar_get_code_display(elh.loc_bed_cd) else ' ' endif
	mas->plist[cnt].age = cnvtage(p.birth_dt_tm)
	mas->plist[cnt].dob = format(p.birth_dt_tm, 'mm/dd/yyyy;;q')
	mas->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	mas->plist[cnt].target_disch_dt = format(e.est_depart_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	mas->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	mas->plist[cnt].gender = uar_get_code_display(p.sex_cd)
	mas->plist[cnt].encntr_class = uar_get_code_display(e.encntr_class_cd)
	mas->plist[cnt].encntr_class_type = uar_get_code_display(e.encntr_type_class_cd)
	mas->plist[cnt].reason_visit = e.reason_for_visit
	mas->plist[cnt].med_service = uar_get_code_display(e.med_service_cd)
 	/*mas->plist[cnt].med_service_dt =
 	if(e.arrive_dt_tm is not null) format(e.arrive_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	 	elseif(e.reg_dt_tm is not null) format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	 	elseif(e.pre_reg_dt_tm is not null) format(e.pre_reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 	endif*/
 
Foot e.encntr_id
	call alterlist(mas->plist, cnt)
 
with nocounter
 
if(mas->rec_cnt > 0)
 
;-------------------------------------------------------------------------------------------
;Care Team
select into 'nl:'
 
epr.encntr_id, pr.name_full_formatted, epr.encntr_prsnl_r_cd
 
from
	(dummyt d with seq = size(mas->plist, 5))
	, encntr_prsnl_reltn epr
	, prsnl pr
	, person_prsnl_reltn ppr
	, prsnl pr1
 
plan d
 
join epr where epr.encntr_id = mas->plist[d.seq].encntrid
	and epr.active_ind = 1
	and epr.encntr_prsnl_r_cd in(admit_phys_var, atten_phys_var, cnslt_phys_var)
 
join pr where pr.person_id = epr.prsnl_person_id
	and pr.active_ind = 1
 
join ppr where ppr.person_id = mas->plist[d.seq].personid
	and ppr.active_ind = 1
      and ppr.person_prsnl_r_cd = pcp_var
      and ppr.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
 
join pr1 where pr1.person_id = ppr.prsnl_person_id
 
order by epr.encntr_id
 
Head epr.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,epr.encntr_id ,mas->plist[cnt].encntrid)
	mas->plist[idx].pcp_prsnl = pr1.name_full_formatted
Detail
	case (epr.encntr_prsnl_r_cd)
		of admit_phys_var:
			mas->plist[idx].admit_prsnl = pr.name_full_formatted
		of atten_phys_var:
			mas->plist[idx].attend_prsnl = pr.name_full_formatted
		of cnslt_phys_var:
			mas->plist[idx].consult_prsnl = pr.name_full_formatted
 	endcase
 
with nocounter
 
;------------------------------------------------------------------------------------
;Clinical events for various DTA's
select into 'nl:' ;$outdev
 
fin = mas->plist[d.seq].fin, nu = mas->plist[d.seq].nurse_unit
, event = uar_get_code_display(ce.event_cd)
, ce.result_val
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	(dummyt d with seq = size(mas->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = mas->plist[d.seq].personid
	and ce.encntr_id = mas->plist[d.seq].encntrid
	and ce.event_cd in(advance_dir_var, assit_device_var, spec_device_var, intpre_svrc_var, intpre_sevrc_cmt_var
	    ,language_var, pref_mode_comm_var, chief_complnt_var, urinary_elim_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_id
 
;with nocounter, separator=" ", format, time = 120
 
Head ce.encntr_id
 	cnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,ce.encntr_id ,mas->plist[cnt].encntrid)
Detail
	case(ce.event_cd)
		of advance_dir_var:
			mas->plist[idx].advance_dir = ce.result_val
			mas->plist[idx].advance_dir_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of assit_device_var:
			mas->plist[idx].assit_device = ce.result_val
			mas->plist[idx].assit_device_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of spec_device_var :
			mas->plist[idx].spec_device = ce.result_val
			mas->plist[idx].spec_device_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of intpre_svrc_var:
			mas->plist[idx].intpre_service = ce.result_val
			mas->plist[idx].intpre_service_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of intpre_sevrc_cmt_var:
			mas->plist[idx].intpre_service_cmt = ce.result_val
			mas->plist[idx].intpre_service_cmt_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of language_var:
			mas->plist[idx].language = ce.result_val
		of pref_mode_comm_var:
			mas->plist[idx].pref_mode_comm = ce.result_val
		of chief_complnt_var:
			mas->plist[idx].chief_compliant = replace(trim(ce.result_val),concat(char(13),char(10)), " ",0)
			mas->plist[idx].chief_compliant_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of urinary_elim_var:
			mas->plist[idx].urinary_elim = ce.result_val
			mas->plist[idx].urinary_elim_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	endcase
 
with 	nocounter
 
;-------------------------------------------------------------------------------
;Diet Orders
 
select into 'nl:'
o.encntr_id, fin = mas->plist[d.seq].fin
, o.order_id, o.order_mnemonic
, status = uar_get_code_display(o.order_status_cd)
, o.order_detail_display_line
 
from 	(dummyt d with seq = size(mas->plist, 5))
	, orders o
	, order_action oa
 
plan d
 
join o where o.encntr_id = mas->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.activity_type_cd = 681598.00
	and o.active_status_cd = 188
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
	and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
order by o.encntr_id
 
Head o.encntr_id
 	cnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,o.encntr_id ,mas->plist[cnt].encntrid)
Detail
	if(idx > 0)
		mas->plist[d.seq].diet = o.order_mnemonic
		mas->plist[d.seq].diet_detail = o.order_detail_display_line
		mas->plist[d.seq].diet_order_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
	endif
 
with nocounter
 
;-------------------------------------------------------------------------------
;Resuscitation,  Isolation, Seizure, patient activity
 
select into 'nl:'
o.encntr_id, fin = mas->plist[d.seq].fin
, o.order_id, o.order_mnemonic
, status = uar_get_code_display(o.order_status_cd)
, o.order_detail_display_line
 
from 	(dummyt d with seq = size(mas->plist, 5))
	, orders o
	, order_action oa
 
plan d
 
join o where o.encntr_id = mas->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.catalog_cd in(resucite_var, pat_isolat_var, dish_isolat_var, ed_isolat_var,seizr_pre_var, ed_seizr_pre_var)
	and o.order_id = (select max(o1.order_id) from orders o1
		where o1.encntr_id = o.encntr_id and o.catalog_cd = o1.catalog_cd
		and o1.active_status_cd = 188
		and o1.order_status_cd = 2550.00 ;Ordered
		and o1.current_start_dt_tm <= sysdate
		and (o1.projected_stop_dt_tm > sysdate or o1.projected_stop_dt_tm is null))
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
order by o.encntr_id
 
Head o.encntr_id
 	isolat_name = '', isolat_detail = '', isolat_dt = '', seisure_preca = '', seisure_preca_dt = '', seisure_preca_detail = ''
 	cnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,o.encntr_id ,mas->plist[cnt].encntrid)
Detail
	case(o.catalog_cd)
		of resucite_var:
			mas->plist[d.seq].resucite = o.order_mnemonic
			mas->plist[d.seq].resucite_detail = o.order_detail_display_line
			mas->plist[d.seq].resucite_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		of pat_isolat_var:
			isolat_name = o.order_mnemonic
			isolat_detail = o.order_detail_display_line
			isolat_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		of dish_isolat_var:
			isolat_name = o.order_mnemonic
			isolat_detail = o.order_detail_display_line
			isolat_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		of ed_isolat_var:
			isolat_name = o.order_mnemonic
			isolat_detail = o.order_detail_display_line
			isolat_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		of seizr_pre_var:
			seizr_preca = o.order_mnemonic
			seizr_preca_detail = o.order_detail_display_line
			seizr_preca_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		of ed_seizr_pre_var:
			seizr_preca = o.order_mnemonic
			seizr_preca_detail = o.order_detail_display_line
			seizr_preca_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
	endcase
 
Foot o.encntr_id
		mas->plist[d.seq].isolation = isolat_name
		mas->plist[d.seq].isolation_detail = isolat_detail
		mas->plist[d.seq].isolation_dt = isolat_dt
		mas->plist[d.seq].seizr_precaution = seizr_preca
		mas->plist[d.seq].seizr_precaution_detail = seizr_preca_detail
		mas->plist[d.seq].seizr_precaution_dt = seizr_preca_dt
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Patient activity orders - new
select into 'nl:'
 
o.encntr_id, o.order_mnemonic, o.order_id, fin = mas->plist[d.seq].fin
, order_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from 	(dummyt d with seq = size(mas->plist, 5))
	, orders o
	, order_action oa
 
plan d
 
join o where o.encntr_id = mas->plist[d.seq].encntrid
	and o.order_id = (select max(o1.order_id) from orders o1
	where o1.encntr_id = o.encntr_id
	and o1.order_mnemonic = o.order_mnemonic
	and o1.active_ind = 1
	and o1.activity_type_cd = 703
	and o1.active_status_cd = 188
	and o1.order_status_cd = 2550.00 ;Ordered
	and o1.current_start_dt_tm <= sysdate
	and (o1.projected_stop_dt_tm > sysdate or o1.projected_stop_dt_tm is null)
	group by o1.encntr_id, o1.order_mnemonic)
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
order by o.encntr_id, o.order_id, oa.order_dt_tm
 
Head o.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,o.encntr_id ,mas->plist[cnt].encntrid)
     	ao_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		ao_list_var = build2(trim(ao_list_var),trim(o.order_mnemonic),",", ';')
 
		/*ocnt += 1
		call alterlist(mas->plist[cnt].oalist, ocnt)
		mas->plist[idx].oalist[ocnt].activity = o.order_mnemonic
		mas->plist[idx].oalist[ocnt].activity_detail = o.order_detail_display_line
		mas->plist[idx].oalist[ocnt].activity_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;q')*/
	endif
 
Foot o.encntr_id
	mas->plist[idx].activity_orders = replace(trim(ao_list_var),";","",2)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Fall Risk Interventions
 
select into 'nl:'
 
fin = mas->plist[d.seq].fin, nu = mas->plist[d.seq].nurse_unit
, event1 = uar_get_code_display(ce.event_cd)
, ce.result_val
, event_dt1 = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	(dummyt d with seq = size(mas->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = mas->plist[d.seq].personid
	and ce.encntr_id = mas->plist[d.seq].encntrid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
	and ce.event_cd in(f_hist_fall_var, f_second_dig_var, f_ambu_aid_var, f_ivhep_fall_var, f_gait_weak_var, f_mental_stat_var
		,f_fall_high_var, f_age_85_var, f_bone_dis_var, f_coagu_disord_var, f_surg_anes_var, f_fall_score_var, f_sph_score_var )
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_id, event_dt1
 
Head ce.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,ce.encntr_id ,mas->plist[cnt].encntrid)
     	fall_list_var = fillstring(1500," ")
 
Detail
	if(idx > 0)
		fall_list_var = build2(trim(fall_list_var),trim(event1),':-[' ,trim(ce.result_val),']',';')
		/*ocnt += 1
		call alterlist(mas->plist[cnt].fall, ocnt)
		mas->plist[idx].fall[ocnt].event = event1
		mas->plist[idx].fall[ocnt].result = ce.result_val
		mas->plist[idx].fall[ocnt].event_dt = event_dt1*/
	endif
Foot ce.encntr_id
	mas->plist[idx].fall = trim(fall_list_var)
	;mas->plist[idx].fall = replace(trim(fall_list_var),";","",2)
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Diagnosis
select into 'nl:'
 
fin = mas->plist[d.seq].fin, nu = mas->plist[d.seq].nurse_unit
, dg.encntr_id
, dg.diagnosis_display
, dg_dt1 = format(dg.diag_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	(dummyt d with seq = size(mas->plist, 5))
	, diagnosis dg
 
plan d
 
join dg where dg.encntr_id = mas->plist[d.seq].encntrid
	and dg.active_ind = 1
	and (dg.beg_effective_dt_tm <= sysdate and dg.end_effective_dt_tm >= sysdate)
	and dg.beg_effective_dt_tm = (select max(dg1.beg_effective_dt_tm) from diagnosis dg1 where dg1.encntr_id = dg.encntr_id
			and dg1.diagnosis_display = dg.diagnosis_display
			group by dg1.diagnosis_display)
 
order by dg.encntr_id, dg_dt1 ;dg.beg_effective_dt_tm
 
Head dg.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,dg.encntr_id ,mas->plist[cnt].encntrid)
      dg_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(dg.diagnosis_display),';')
		/*ocnt += 1
		call alterlist(mas->plist[cnt].dg, ocnt)
		mas->plist[idx].dg[ocnt].dg_name = dg.diagnosis_display
		mas->plist[idx].dg[ocnt].dg_dt = dg_dt1
		mas->plist[idx].dg[ocnt].priority = dg.clinical_diag_priority*/
	endif
Foot dg.encntr_id
	mas->plist[idx].diagnoses = replace(trim(dg_list_var),";","",2)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Ambulation
select into 'nl:'
 
fin = mas->plist[d.seq].fin, nu = mas->plist[d.seq].nurse_unit
, event1 = uar_get_code_display(ce.event_cd)
, ce.result_val
, event_dt1 = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	(dummyt d with seq = size(mas->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = mas->plist[d.seq].personid
	and ce.encntr_id = mas->plist[d.seq].encntrid
	and ce.event_cd in(adls_var, ambu_assist_var, bath_adl_var, dress_adl_var, toilet_adl_var, conti_adl_var
		,feed_adl_var, bed_assist_var, transfer_bed_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_id, event_dt1
 
Head ce.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,ce.encntr_id ,mas->plist[cnt].encntrid)
      amb_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		amb_list_var = build2(trim(amb_list_var),trim(event1),'-[' ,trim(ce.result_val),']',';')
		/*ocnt += 1
		call alterlist(mas->plist[cnt].ambu, ocnt)
		mas->plist[idx].ambu[ocnt].event = event1
		mas->plist[idx].ambu[ocnt].result = ce.result_val
		mas->plist[idx].ambu[ocnt].event_dt = event_dt1*/
	endif
Foot ce.encntr_id
		mas->plist[idx].ambulation = replace(trim(amb_list_var),";","",2)
with nocounter
 
;------------------------------------------------------------------------------------------------------
;Activities of daily living
select into 'nl:'
 
fin = mas->plist[d.seq].fin, nu = mas->plist[d.seq].nurse_unit
, event1 = uar_get_code_display(ce.event_cd)
, ce.result_val
, event_dt1 = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	(dummyt d with seq = size(mas->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = mas->plist[d.seq].personid
	and ce.encntr_id = mas->plist[d.seq].encntrid
	and ce.event_cd in(env_safety_var, mng_sensory_var, activity_status_var, pat_position_var, head_bed_pos_var, head_contra_var
		,tm_dang_bed_var, tm_up_chair_var, ambu_pat_efrt_var, ambu_mins_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_id, event_dt1
 
Head ce.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,ce.encntr_id ,mas->plist[cnt].encntrid)
      liv_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		liv_list_var = build2(trim(liv_list_var),trim(event1),'-[' ,trim(ce.result_val),']',';')
		/*ocnt += 1
		call alterlist(mas->plist[cnt].living, ocnt)
		mas->plist[idx].living[ocnt].event = event1
		mas->plist[idx].living[ocnt].result = ce.result_val
		mas->plist[idx].living[ocnt].event_dt = event_dt1*/
	endif
Foot ce.encntr_id
		mas->plist[idx].living = replace(trim(liv_list_var),";","",2)
with nocounter
 
;call echorecord(mas)
 
;----------------------------------------------------------------------------------------------
;Allergy
select into "nl:"
 
  a.encntr_id, n.source_string
  ,severity = uar_get_code_display(a.severity_cd)
  ,substance =  uar_get_code_display(a.substance_type_cd)
 
, sort_order =
 if(a.severity_cd = severe_var) 1
	elseif (a.substance_type_cd = food_var) 2
	elseif (a.substance_type_cd = drug_var) 3
	elseif (a.substance_type_cd = env_var)  4
	else 5
endif
 
from (dummyt d with seq = size(mas->plist, 5))
	, allergy a
	, nomenclature n
 
plan d
 
join a where a.person_id = mas->plist[d.seq].personid
	and a.active_ind = 1
	and a.active_status_cd = 188
	and a.beg_effective_dt_tm <= sysdate
	and a.end_effective_dt_tm >= sysdate
	and (a.cancel_dt_tm is null or a.cancel_dt_tm > sysdate)
 
join n where n.nomenclature_id = outerjoin(a.substance_nom_id)
	and n.active_ind = outerjoin(1)
 
order by a.encntr_id, sort_order, n.source_string
 
Head a.encntr_id
	cnt = 0
	acnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,a.encntr_id ,mas->plist[cnt].encntrid)
      algry_list_var = fillstring(1000," ")
      free_text_algry = fillstring(500," ")
Detail
	if(idx > 0)
		algry_list_var = build2(trim(algry_list_var),trim(n.source_string),',')
		if (a.substance_ftdesc != ' ' and a.substance_ftdesc != 'No Known Allergies' and a.substance_ftdesc != 'No Allergies' )
			free_text_algry = build(trim(free_text_algry), trim(a.substance_ftdesc),", ")
		endif
 
		;algry_list_var = build2(trim(algry_list_var),trim(n.source_string),'[',trim(severity),']',trim(substance),';')
		/*acnt += 1
		call alterlist(mas->plist[cnt].allergy, acnt)
		mas->plist[idx].allergy[acnt].allergy_base = trim(n.source_string)
		mas->plist[idx].allergy[acnt].severity_level = uar_get_code_display(a.severity_cd)
		mas->plist[idx].allergy[acnt].substance_type = uar_get_code_display(a.substance_type_cd)*/
	endif
Foot a.encntr_id
	if(free_text_algry != ' ')
		algry_list_var = build(algry_list_var, free_text_algry)
	endif
	mas->plist[idx].allergy = replace(trim(algry_list_var),",","",2)
with nocounter
 
;----------------------------------------------------------------------------------------
;Protocols
select into 'nl:'
 
o.encntr_id, o.order_mnemonic, o.order_status_cd, o.order_id, ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from (dummyt d with seq = size(mas->plist, 5))
	,orders o
 
plan d
 
join o where o.encntr_id = mas->plist[d.seq].encntrid
	and o.person_id = mas->plist[d.seq].personid
	and o.catalog_cd in(calci_var, magne_var, phos_var, pota_var, cr_calci_var, cr_magne_var, cr_phos_var, cr_pota_var
		, cv_surg_mag_var, cv_surg_pota_var, dka_pota_var, hypo_var, hypo_insu_var, rt_eval_var, oxy_var
		, vent_var, cv_vent_var, awak_var, move_var)
	and o.active_ind = 1
 	and o.active_status_cd = 188
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
	and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
 
order by o.encntr_id, o.order_id
 
Head o.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,mas->rec_cnt ,o.encntr_id ,mas->plist[cnt].encntrid)
      proto_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		proto_list_var = build2(trim(proto_list_var),trim(o.order_mnemonic),';')
		/*ocnt += 1
		call alterlist(mas->plist[cnt].protocol, ocnt)
		mas->plist[idx].protocol[ocnt].protocol_type = o.order_mnemonic
		mas->plist[idx].protocol[ocnt].order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')*/
	endif
Foot o.encntr_id
		mas->plist[idx].protocol = replace(trim(proto_list_var),";","",2)
 
with nocounter
 
call echorecord(mas)
;--------------------------------------------------------------------------------------------------
 
SELECT DISTINCT INTO $OUTDEV
 
	 FIN = SUBSTRING(1, 30, MAS->plist[D1.SEQ].fin)
	, MRN = SUBSTRING(1, 30, MAS->plist[D1.SEQ].mrn)
	, PAT_NAME = SUBSTRING(1, 50, MAS->plist[D1.SEQ].pat_name)
	, PATIENT_PIN = SUBSTRING(1, 30, MAS->plist[D1.SEQ].pat_pin)
	, NURSE_UNIT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].nurse_unit)
	, ROOM = SUBSTRING(1, 30, MAS->plist[D1.SEQ].room)
	, BED = SUBSTRING(1, 30, MAS->plist[D1.SEQ].bed)
	, AGE = SUBSTRING(1, 30, MAS->plist[D1.SEQ].age)
	, DOB = SUBSTRING(1, 30, MAS->plist[D1.SEQ].dob)
	, GENDER = SUBSTRING(1, 30, MAS->plist[D1.SEQ].gender)
	, ADMIT_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].admit_dt)
	, TARGET_DISCH_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].target_disch_dt)
	, PAT_TYPE = SUBSTRING(1, 30, MAS->plist[D1.SEQ].pat_type)
	, REASON_VISIT = SUBSTRING(1, 100, MAS->plist[D1.SEQ].reason_visit)
	, ADMIT_PRSNL = SUBSTRING(1, 50, MAS->plist[D1.SEQ].admit_prsnl)
	, ATTEND_PRSNL = SUBSTRING(1, 50, MAS->plist[D1.SEQ].attend_prsnl)
	, CONSULT_PRSNL = SUBSTRING(1, 50, MAS->plist[D1.SEQ].consult_prsnl)
	, PCP_PRSNL = SUBSTRING(1, 50, MAS->plist[D1.SEQ].pcp_prsnl)
	, MED_SERVICE = SUBSTRING(1, 30, MAS->plist[D1.SEQ].med_service)
	;, MED_SERVICE_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].med_service_dt)
	, ADVANCE_DIR = SUBSTRING(1, 30, MAS->plist[D1.SEQ].advance_dir)
	;, ADVANCE_DIR_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].advance_dir_dt)
	, DIET = trim(SUBSTRING(1, 100, MAS->plist[D1.SEQ].diet))
	, DIET_DETAIL = trim(SUBSTRING(1, 300, MAS->plist[D1.SEQ].diet_detail))
	;, DIET_ORDER_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].diet_order_dt)
	, RESUCITE = trim(SUBSTRING(1, 100, MAS->plist[D1.SEQ].resucite))
	, RESUCITE_DETAIL = trim(SUBSTRING(1, 300, MAS->plist[D1.SEQ].resucite_detail))
	;, RESUCITE_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].resucite_dt)
	, ISOLATION = trim(SUBSTRING(1, 100, MAS->plist[D1.SEQ].isolation))
	, ISOLATION_DETAIL = trim(SUBSTRING(1, 300, MAS->plist[D1.SEQ].isolation_detail))
	;, ISOLATION_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].isolation_dt)
	, ASSIT_DEVICE = trim(SUBSTRING(1, 50, MAS->plist[D1.SEQ].assit_device))
	;, ASSIT_DEVICE_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].assit_device_dt)
	;, SPEC_DEVICE = trim(SUBSTRING(1, 50, MAS->plist[D1.SEQ].spec_device))
	;, SPEC_DEVICE_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].spec_device_dt)
	, SEIZR_PRECAUTION = trim(SUBSTRING(1, 300, MAS->plist[D1.SEQ].seizr_precaution))
	, SEIZR_PRECAUTION_DETAIL = SUBSTRING(1, 100, MAS->plist[D1.SEQ].seizr_precaution_detail)
	;, SEIZR_PRECAUTION_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].seizr_precaution_dt)
	, INTPRE_SERVICE = SUBSTRING(1, 30, MAS->plist[D1.SEQ].intpre_service)
	;, INTPRE_SERVICE_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].intpre_service_dt)
	, INTPRE_SERVICE_CMT = trim(SUBSTRING(1, 100, MAS->plist[D1.SEQ].intpre_service_cmt))
	;, INTPRE_SERVICE_CMT_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].intpre_service_cmt_dt)
	, PREFERED_MODE_COMMUNICATION = SUBSTRING(1, 50, MAS->plist[D1.SEQ].pref_mode_comm)
	, LANGUAGE = SUBSTRING(1, 30, MAS->plist[D1.SEQ].language)
	, CHIEF_COMPLIANT = trim(SUBSTRING(1, 300, MAS->plist[D1.SEQ].chief_compliant))
	;, CHIEF_COMPLIANT_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].chief_compliant_dt)
	, URINARY_ELIM = trim(SUBSTRING(1, 100, MAS->plist[D1.SEQ].urinary_elim))
	;, URINARY_ELIM_DT = SUBSTRING(1, 30, MAS->plist[D1.SEQ].urinary_elim_dt)
	, ACTIVITIES_DAILY_LIVING = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].living))
	, AMBULATION = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].ambulation))
	, ACTIVITY_ORDERS = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].activity_orders))
	, FALL_INTERVENTION = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].fall))
	, DIAGNOSES = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].diagnoses))
	, ALLERGY = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].allergy))
	, PROTOCOLS = trim(SUBSTRING(1, 500, MAS->plist[D1.SEQ].protocol))
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(MAS->plist, 5))
 
PLAN D1
 
ORDER BY NURSE_UNIT, PAT_NAME, FIN
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
endif ;rec_cnt 
 
end
go
 
 
/*
The med protocol orderables are:
Calcium Replacement Protocol
Magnesium Replacement Protocol
Phosphorus Replacement Protocol
Potassium Replacement Protocol
CRRT Calcium Replacement Protocol
CRRT Magnesium Replacement Protocol
CRRT Phosphorus Replacement Protocol
CRRT Potassium Replacement Protocol
CV Surgery Magnesium Replacement Protocol
CV Surgery Potassium Replacement Protocol
DKA Potassium Replacement Protocol
Hypoglycemia Protocol
Hypoglycemia Protocol for Insulin Drip
 
Nursing Protocals:
Initiate RT Eval and Treat Protocol
Initiate Oxygen Therapy per Protocol
Initiate Vent Weaning per  Protocol
CV Vent Weaning Protocol
Initiate Spontaneous Awakening Protocol
Initiate Move Me Protocol
 
*/
 

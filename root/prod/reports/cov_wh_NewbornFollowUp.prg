/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			    Geetha Saravanan
	Date Written:		Dec'2017
	Solution:			Womens Health
	Source file name:	cov_wh_NewbornFollowUp.prg
	Object name:		cov_wh_NewbornFollowUp
	Request #:			21
 
	Prompt Form Used :  cov_PromptLibrary.forms
 	Program purpose:	Newborn Follow Up - Printed from baby's chart and given to the Peds providers who are not in the CovHlth system.
 					    This information is used by the follow up provider to provide outpatient care of the newborn
 
 	Executing from:		CCL
  	Special Notes:		On demand; Individul chart only with baby's fin
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_wh_NewbornFollowUp:DBA go
create program cov_wh_NewbornFollowUp:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = ""
 
with OUTDEV, fin

/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
%i cust_script:cov_CommonLibrary.inc 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare initcap() = c100 
declare facility_code_var    = f8 with constant(get_FacilityCode($fin)), protect ; write sub on test2
declare mrn_alias_pool_var   = f8 with constant(get_AliasPoolCode(facility_code_var)), protect ; write sub on test2
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare cmrn_var             = f8 with constant(uar_get_code_by("DISPLAY", 4, "Community Medical Record Number")),protect
declare cmrn_alias_pool_var  = f8 with constant(uar_get_code_by("DISPLAY", 263, "CMRN")),protect
declare relation_var         = f8 with constant(uar_get_code_by("DISPLAY", 40,  "Child")),protect
declare relation_type_var1   = f8 with constant(uar_get_code_by("DISPLAY", 351,  "Default Guarantor")),protect
declare relation_type_var2   = f8 with constant(uar_get_code_by("DISPLAY", 351,  "Family Member")),protect
declare mom_enter_type_var   = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")),protect ;309308.00
 
 
;********* Baby ***********************
 
;Newborn Information
declare encounter_type_var   = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NEWBORN")),protect
declare infant_gender_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gender")),protect
declare delivery_dt_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date, Time of Birth")),protect
declare delivery_phys_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Physician")),protect
declare other_provider_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Assistant Physician #1")),protect
declare delivery_method_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Type, Birth")),protect
declare attend_phys_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Attending Physician:")),protect
declare Resuscitation_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Resuscitation at Birth")),protect
declare comp_abnal_finds_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Complications")),protect
declare feed_pref_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Feeding Plans")),protect
declare feeding_type_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Feeding Type Newborn")),protect
declare admit_to_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Transferred To")),protect
declare birth_weight_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Weight")),protect
declare birth_length_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Length")),protect
declare birth_head_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Head Circumference")),protect
declare apgar_1min_var       = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR1MINUTEBYHISTORY")),protect
declare apgar_5min_var       = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR5MINUTEBYHISTORY")),protect
declare apgar_10min_var      = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR10MINUTEBYHISTORY")),protect
declare apgar_15min_var      = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR15MINUTEBYHISTORY")),protect
declare apgar_20min_var      = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR20MINUTEBYHISTORY")),protect
declare disch_feed_pref_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Discharge Feeding Type")),protect
 
;Routine Newborn Medications Given
declare vmin_K_dt_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Vitamin K Dose")),protect
declare hep_B_dt_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Hepatitis B Date of Vaccination")),protect
declare abx_eye_dt_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "erythromycin")),protect
declare hbig_dt_var          = f8 with constant(null),protect
 
;Routine Newborn Testing Completed
declare systolic_bp_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Systolic BP")),protect
declare diastolic_bp_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Diastolic BP")),protect
declare bp_location_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Blood Pressure Location")),protect
declare coombs_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "DAT Immediate Spin")),protect
declare high_bili_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bili Total")),protect
declare bili_direct_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bili Direct")),protect
declare bili_indirect_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bili Indirect")),protect
declare hear_scrn_dt_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Test Performed Date, Time")),protect
declare otostic_rslt_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Otoacoustic Emissions Result")),protect
declare audibrain_rslt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Auditory Brainstem Response Result")),protect
declare metabo_scrn_dt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Metabolic Screening Date, Time Drawn")),protect
declare newbrn_scrn_form_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Screening Form #")),protect
declare carseat_chalng_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Car Seat Challenge Result")),protect
declare blood_type_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "ABO/Rh")),protect
;declare blood_type_var       = f8 with constant(35289669) 
 
declare dsch_bili_var        = f8 with constant(null),protect
declare mthd_bili_serum_var  = f8 with constant(null),protect
declare cchd_rslt_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn CCHD Result")),protect
declare refr_cardio_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Referred to Cardiology")),protect
declare drug_scrn_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Drug Screen Results")),protect
declare cord_stat_rslt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord Tissue Drug Screen")),protect
declare cord_blood_gas_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Arterial Cord Blood Gases w Meas O2 Sat")),protect 
 
;Newborn Procedures
declare phototherapy_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Phototherapy Activity")),protect
declare circumcision_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Circumcision")),protect
declare other_procedure_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bedside Procedure Type")),protect
 
;Discharge Information
declare disch_dt_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Clinical Discharge Date and Time")),protect
declare follup_provider_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Follow-Up Physician")),protect
declare provider_phone_var   = f8 with constant(null),protect
declare appointment_dt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Physician Appt Date, Time")),protect
declare addnl_folup_dt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Follow-Up Clinic Appt Date, Time")),protect
declare disch_weight_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Weight Measured")),protect
declare disch_head_cirm_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Head Circumference")),protect
 
;********** Mother ***********
 
;Maternal Information
declare mom_blood_type_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Blood Type")),protect
declare hbsag_var            = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Hepatitis B")),protect 
declare gbs_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed GBS")),protect
declare gbs_abx_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Antibiotic")),protect
declare doses_abx_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Intrapartum Antibiotics")),protect
 
;antibiotic type ::
declare intra_abx_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Intrapartum Antibiotics")),protect
declare toxi_scrn_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Toxicology Screen")),protect
declare alcohol_use_var      = f8 with constant(null),protect
declare cocaine_use_var      = f8 with constant(null),protect
declare mom_drug_scrn_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Drug Screen Results")),protect
declare preg_risk_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Risk Factors in Utero")),protect
declare med_preg_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Medications During Pregnancy")),protect
declare preg_risk_other_var  = f8 with constant(null),protect
declare preg_risk_dtl_var    = f8 with constant(null),protect
declare ega_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "EGA at Birth")),protect
declare rubella_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Rubella")),protect
declare rpr_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed RPR/VDRL/Serology")),protect
declare hepatitis_c_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Hepatitis C")),protect
declare hsv_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HSV")),protect
declare hiv_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HIV")),protect
declare gonorhea_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gonorrhea, Transcribed")),protect
declare chlamydia_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Chlamydia, Transcribed")),protect
declare tobacco_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Tobacco use")),protect
declare drug_var             = f8 with constant(null),protect
declare marijuana_var        = f8 with constant(null),protect
declare dcs_nitified_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Type of DCS Notification")),protect
 
;Labor and delivery Information
declare rom_dt_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM Date, Time")),protect
declare rom_deli_tot_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "ROM to Delivery Total Time:")),protect
declare lngh_rom_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "ROM to Delivery Hours Calc:")),protect
declare deli_anes_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Anesthesia")),protect
declare med_labor_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Medications During Labor")),protect
declare dt_norcotic_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time Narcotic Last Adminsitered")),protect
declare name_abx_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Antibiotic")),protect
declare ld_complica_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Complications")),protect
 
 
 
 
;Create Recore Structure
Record Newborn_followUp(
	1 events[*]
		2 facility_name    = vc
		2 street_addr      = vc
		2 city             = vc
		2 state            = vc
		2 zipcode          = vc
		2 baby_fin         = vc
		2 baby_mrn         = vc
		2 baby_cmrn        = vc
		2 baby_regdt       = dq8
		2 baby_encntr_id   = f8
		2 infant_name      = vc
		2 Birth_date       = dq8
		2 infant_gender    = vc
		2 method_delivery  = vc
		2 provider_hosp    = vc
		2 attend_phys      = vc
		2 other_provider   = vc
		2 Resuscitation    = vc
		2 comp_abnal_finds = vc
		2 feed_pref        = vc
		2 feeding_type     = vc
		2 admit_to   	 = vc
		2 birth_weight     = f8
		2 birth_length     = vc
		2 birth_head       = vc
		2 apgar_1min       = vc
		2 apgar_5min       = vc
		2 apgar_10min      = vc
		2 apgar_15min      = vc
		2 apgar_20min      = vc
		2 disch_feed_pref  = vc
		2 vmin_K_dt        = vc
		2 hep_B_dt         = vc
		2 abx_eye_dt       = vc
		2 hbig_dt          = vc
		2 systolic_bp      = vc
		2 diastolic_bp     = vc
		2 bp_location      = vc
		2 coombs           = vc
		2 high_bili        = vc
		2 bili_direct      = vc
		2 bili_indirect    = vc
		2 hear_scrn_dt     = vc
		2 otostic_rslt     = vc
		2 audibrain_rslt   = vc
		2 metabo_scrn_dt   = vc
		2 newbrn_scrn_form = vc
		2 carseat_chalng   = vc
		2 blood_type       = vc
		2 dsch_bili        = vc
		2 mthd_bili_serum  = vc
		2 cchd_rslt        = vc
		2 refr_cardio      = vc
		2 drug_scrn        = vc
		2 cord_stat_rslt   = vc
		2 phototherapy     = vc
		2 circumcision     = vc
		2 other_procedure  = vc
		2 disch_dt         = vc
		2 follup_provider  = vc
		2 provider_phone   = vc
		2 appointment_dt   = vc
		2 addnl_folup_dt   = vc
		2 disch_weight     = vc
		2 disch_head_cirm  = vc
		;Mother
		2 mom_encntr_id    = f8
		2 mom_fin          = vc
		2 mom_name         = vc
		2 mom_dob          = dq8
		2 mom_regdt        = dq8
		2 mom_blood_type   = vc
		2 hbsag            = vc
		2 gbs              = vc
		2 gbs_abx          = vc
		2 doses_abx        = vc
		2 intra_abx        = vc
		2 toxi_scrn        = vc
		2 alcohol_use      = vc
		2 cocaine_use      = vc
		2 mom_drug_scrn    = vc
		2 preg_risk        = vc
		2 med_preg         = vc
		2 preg_risk_other  = vc
		2 preg_risk_dtl    = vc
		2 ega              = vc
		2 rubella          = vc
		2 rpr              = vc
		2 hepatitis_c      = vc
		2 hsv              = vc
		2 hiv              = vc
		2 gonorhea         = vc
		2 chlamydia        = vc
		2 tobacco          = vc
		2 drug             = vc
		2 marijuana        = vc
		2 dcs_nitified     = vc
		2 rom_dt           = vc
		2 rom_deli_tot     = vc
		2 lngh_rom         = vc
		2 deli_anes        = vc
		2 med_labor        = vc
		2 dt_norcotic      = vc
		2 name_abx         = vc
		2 ld_complica      = vc
		2 cord_blood_gas   = vc
 	)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
  
;get Baby info.
SELECT DISTINCT INTO "NL:"
    e.encntr_id
    , e.loc_facility_cd
 	, street           = max(a.street_addr)
 	, city             = max(a.city)
 	, state            = max(a.state)
 	, zipcode          = max(a.zipcode)
	, baby_mrn         = max(ea1.alias)
	, baby_cmrn        = max(pa.alias)
 	, facility_name    = uar_get_code_description(e.loc_facility_cd)
	, infant_name      = initcap(max(pe.name_full_formatted));baby
	, baby_regdt       = max(e.reg_dt_tm )
	, Birth_date       = max(pe.birth_dt_tm)
	, infant_gender    = max(evaluate(ce.event_cd, infant_gender_var,   ce.result_val, 0, ""))
	, method_delivery  = max(evaluate(ce.event_cd, delivery_method_var, ce.result_val, 0, ""))
 	, provider_hosp    = initcap(max(evaluate(ce.event_cd, delivery_phys_var,   ce.result_val, 0, "")))
	, attend_phys      = initcap(max(i.name_full_formatted))
 	, other_provider   = initcap(max(evaluate(ce.event_cd, other_provider_var,  ce.result_val, 0, "")))
	, Resuscitation    = max(evaluate(ce.event_cd, Resuscitation_var,   ce.result_val, 0, ""))
	, comp_abnal_finds = max(evaluate(ce.event_cd, comp_abnal_finds_var,ce.result_val, 0, ""))
	, feed_pref        = max(evaluate(ce.event_cd, feed_pref_var,       ce.result_val, 0, ""))
    , feeding_type     = max(evaluate(ce.event_cd, feeding_type_var,    ce.result_val, 0, ""))
    , admit_to         = max(evaluate(ce.event_cd, admit_to_var,        ce.result_val, 0, ""))
 	, birth_weight     = max(evaluate(ce.event_cd, birth_weight_var,    cnvtreal(ce.result_val)) * 1000)
 	, birth_length     = max(evaluate(ce.event_cd, birth_length_var,    ce.result_val, 0, ""))
	, birth_head       = max(evaluate(ce.event_cd, birth_head_var,      ce.result_val, 0, ""))
	, apgar_1min       = max(evaluate(ce.event_cd, apgar_1min_var,      ce.result_val, 0, ""))
	, apgar_5min       = max(evaluate(ce.event_cd, apgar_5min_var,      ce.result_val, 0, ""))
	, apgar_10min      = max(evaluate(ce.event_cd, apgar_10min_var,     ce.result_val, 0, ""))
	, apgar_15min      = max(evaluate(ce.event_cd, apgar_15min_var,     ce.result_val, 0, ""))
	, apgar_20min      = max(evaluate(ce.event_cd, apgar_20min_var,     ce.result_val, 0, ""))
	, disch_feed_pref  = max(evaluate(ce.event_cd, disch_feed_pref_var, ce.result_val, 0, ""))
	, vmin_K_dt        = max(evaluate(ce.event_cd, vmin_K_dt_var,       ce.result_val, 0, ""))
	, hep_B_dt         = max(evaluate(ce.event_cd, hep_B_dt_var,        ce.result_val, 0, ""))
	, abx_eye_dt       = max(evaluate(ce.event_cd, abx_eye_dt_var,      ce.result_val, 0, ""))
	, hbig_dt          = max(evaluate(ce.event_cd, hbig_dt_var,         ce.result_val, 0, ""))
    , systolic_bp      = max(evaluate(ce.event_cd, systolic_bp_var,     ce.result_val, 0, ""))
	, diastolic_bp     = max(evaluate(ce.event_cd, diastolic_bp_var ,   ce.result_val, 0, ""))
	, bp_location      = max(evaluate(ce.event_cd, bp_location_var,     ce.result_val, 0, ""))
	, coombs           = max(evaluate(ce.event_cd, coombs_var,          ce.result_val, 0, ""))
	, high_bili        = max(evaluate(ce.event_cd, high_bili_var,       ce.result_val, 0, ""))
	, bili_direct      = max(evaluate(ce.event_cd, bili_direct_var,     ce.result_val, 0, ""))
	, bili_indirect    = max(evaluate(ce.event_cd, bili_indirect_var,   ce.result_val, 0, ""))
	, hear_scrn_dt     = max(evaluate(ce.event_cd, hear_scrn_dt_var,    ce.result_val, 0, ""))
	, otostic_rslt     = max(evaluate(ce.event_cd, otostic_rslt_var,    ce.result_val, 0, ""))
	, audibrain_rslt   = max(evaluate(ce.event_cd, audibrain_rslt_var,  ce.result_val, 0, ""))
	, metabo_scrn_dt   = max(evaluate(ce.event_cd, metabo_scrn_dt_var,  ce.result_val, 0, ""))
	, newbrn_scrn_form = max(evaluate(ce.event_cd, newbrn_scrn_form_var,ce.result_val, 0, ""))
	, carseat_chalng   = max(evaluate(ce.event_cd, carseat_chalng_var,  ce.result_val, 0, ""))
 	, blood_type       = max(evaluate(ce.event_cd, blood_type_var,      ce.result_val, 0, ""))
 	, dsch_bili        = max(evaluate(ce.event_cd, dsch_bili_var,       ce.result_val, 0, ""))
	, mthd_bili_serum  = max(evaluate(ce.event_cd, mthd_bili_serum_var, ce.result_val, 0, ""))
	, cchd_rslt        = max(evaluate(ce.event_cd, cchd_rslt_var,       ce.result_val, 0, ""))
	, refr_cardio      = max(evaluate(ce.event_cd, refr_cardio_var,     ce.result_val, 0, ""))
	, drug_scrn        = max(evaluate(ce.event_cd, drug_scrn_var,       ce.result_val, 0, ""))
	, cord_stat_rslt   = max(evaluate(ce.event_cd, cord_stat_rslt_var,  ce.result_val, 0, ""))
	, phototherapy     = max(evaluate(ce.event_cd, phototherapy_var,    ce.result_val, 0, ""))
	, circumcision     = max(evaluate(ce.event_cd, circumcision_var,    ce.result_val, 0, ""))
	, other_procedure  = max(evaluate(ce.event_cd, other_procedure_var, ce.result_val, 0, ""))
	, disch_dt         = max(evaluate(ce.event_cd, disch_dt_var,        ce.result_val, 0, ""))
	, follup_provider  = max(evaluate(ce.event_cd, follup_provider_var, ce.result_val, 0, ""))
	, provider_phone   = max(evaluate(ce.event_cd, provider_phone_var , ce.result_val, 0, ""))
	, appointment_dt   = max(evaluate(ce.event_cd, appointment_dt_var , ce.result_val, 0, ""))
	, addnl_folup_dt   = max(evaluate(ce.event_cd, addnl_folup_dt_var , ce.result_val, 0, ""))
	, disch_weight     = max(evaluate(ce.event_cd, disch_weight_var   , ce.result_val, 0, ""))
	, disch_head_cirm  = max(evaluate(ce.event_cd, disch_head_cirm_var, ce.result_val, 0, ""))
	, cord_blood_gas   = max(evaluate(ce.event_cd, cord_blood_gas_var , ce.result_val, 0, ""))
	
 
 
FROM
	encntr_alias   ea
	, encounter   e
	, encntr_alias ea1
	, address a
	, person   pe
	, person_alias pa
	, clinical_event ce
	, (;inline table to get attending physician
		(select pr.name_full_formatted, ea.alias
			from encntr_alias ea, encounter e, encntr_prsnl_reltn epr, prsnl pr
			where ea.alias = $fin
			and ea.encntr_alias_type_cd = fin_var
			and ea.active_ind = 1
			and e.encntr_id = ea.encntr_id
			and e.encntr_type_cd = encounter_type_var ;2555267433.00
			and e.active_ind = 1
			and epr.encntr_id = e.encntr_id
			and epr.prsnl_person_id = pr.person_id
			and epr.encntr_prsnl_r_cd = 1119 ;-attend ,(1116 - admit)
			and epr.active_ind = 1
			and pr.active_ind = 1
		 WITH SQLTYPE("VC50", "VC20")
		)i
	  )
 
plan i
 
join ea where outerjoin(ea.alias) = i.alias
	and ea.alias = $fin ;"1731400012"
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	 and e.encntr_type_cd = encounter_type_var ;2555267433.00
	 and e.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	  and ea1.alias_pool_cd =  mrn_alias_pool_var
	  and ea1.encntr_alias_type_cd = mrn_var
	  and ea1.active_ind = 1
 
join a where outerjoin(e.organization_id) = a.parent_entity_id
	 and a.active_ind = outerjoin(1)
 
join pe where pe.person_id = e.person_id
	 and pe.active_ind = 1
 
join pa where outerjoin(e.person_id) = pa.person_id
	 and pa.alias_pool_cd = outerjoin(cmrn_alias_pool_var)
	 and pa.person_alias_type_cd = outerjoin(cmrn_var)
	 and pa.active_ind = outerjoin(1)
 
join ce where ce.encntr_id = e.encntr_id
	  and ce.event_cd in(
	  delivery_dt_var, delivery_phys_var, other_provider_var, delivery_method_var, attend_phys_var, Resuscitation_var,
	  infant_gender_var,
	  comp_abnal_finds_var, feed_pref_var, feeding_type_var, admit_to_var, birth_weight_var, birth_length_var, birth_head_var, apgar_1min_var,
	  apgar_5min_var, apgar_10min_var, apgar_15min_var, apgar_20min_var, disch_feed_pref_var, vmin_K_dt_var, hep_B_dt_var,
	  abx_eye_dt_var, hbig_dt_var, systolic_bp_var, diastolic_bp_var, bp_location_var, coombs_var, high_bili_var, cord_blood_gas_var,
	  bili_direct_var, bili_indirect_var, hear_scrn_dt_var, otostic_rslt_var, audibrain_rslt_var, metabo_scrn_dt_var,
	  newbrn_scrn_form_var, carseat_chalng_var, blood_type_var, dsch_bili_var, mthd_bili_serum_var, cchd_rslt_var,
	  refr_cardio_var, drug_scrn_var, cord_stat_rslt_var, phototherapy_var, circumcision_var, other_procedure_var, disch_dt_var,
	  follup_provider_var, provider_phone_var, appointment_dt_var, addnl_folup_dt_var, disch_weight_var, disch_head_cirm_var
	  )
 
 
group by e.encntr_id, e.loc_facility_cd
 
order by e.encntr_id, e.loc_facility_cd
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
 
;Populate record structure with baby events
HEAD REPORT
 
	cnt = 0
	call alterlist(Newborn_followUp->events, 100)
 
DETAIL
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(Newborn_followUp->events, cnt+9)
	endif
	Newborn_followUp->events[cnt].facility_name    = facility_name
	Newborn_followUp->events[cnt].street_addr      = street
	Newborn_followUp->events[cnt].city             = city
	Newborn_followUp->events[cnt].state            = state
	Newborn_followUp->events[cnt].zipcode          = zipcode
 	Newborn_followUp->events[cnt].baby_fin         = $fin
 	Newborn_followUp->events[cnt].baby_encntr_id   = e.encntr_id
 	Newborn_followUp->events[cnt].baby_mrn         = baby_mrn
 	Newborn_followUp->events[cnt].baby_cmrn        = baby_cmrn
	Newborn_followUp->events[cnt].baby_regdt       = baby_regdt
	Newborn_followUp->events[cnt].infant_name      = infant_name
	Newborn_followUp->events[cnt].Birth_date       = Birth_date
	Newborn_followUp->events[cnt].infant_gender    = infant_gender
	Newborn_followUp->events[cnt].method_delivery  = method_delivery
	Newborn_followUp->events[cnt].provider_hosp    = provider_hosp
	Newborn_followUp->events[cnt].attend_phys      = attend_phys
	Newborn_followUp->events[cnt].other_provider   = other_provider
	Newborn_followUp->events[cnt].Resuscitation    = Resuscitation
	Newborn_followUp->events[cnt].comp_abnal_finds = comp_abnal_finds
	Newborn_followUp->events[cnt].feed_pref        = feed_pref
	Newborn_followUp->events[cnt].feeding_type     = feeding_type
	Newborn_followUp->events[cnt].admit_to   	     = admit_to
	Newborn_followUp->events[cnt].birth_weight     = birth_weight
	Newborn_followUp->events[cnt].birth_length     = birth_length
	Newborn_followUp->events[cnt].birth_head       = birth_head
	Newborn_followUp->events[cnt].apgar_1min       = apgar_1min
	Newborn_followUp->events[cnt].apgar_5min       = apgar_5min
	Newborn_followUp->events[cnt].apgar_10min      = apgar_10min
	Newborn_followUp->events[cnt].apgar_15min      = apgar_15min
	Newborn_followUp->events[cnt].apgar_20min      = apgar_20min
	Newborn_followUp->events[cnt].disch_feed_pref  = disch_feed_pref
	Newborn_followUp->events[cnt].vmin_K_dt        = vmin_K_dt
	Newborn_followUp->events[cnt].hep_B_dt         = hep_B_dt
	Newborn_followUp->events[cnt].abx_eye_dt       = abx_eye_dt
	Newborn_followUp->events[cnt].hbig_dt          = hbig_dt
	Newborn_followUp->events[cnt].systolic_bp      = systolic_bp
	Newborn_followUp->events[cnt].diastolic_bp     = diastolic_bp
	Newborn_followUp->events[cnt].bp_location      = bp_location
	Newborn_followUp->events[cnt].coombs           = bp_location
	Newborn_followUp->events[cnt].high_bili        = high_bili
	Newborn_followUp->events[cnt].bili_direct      = bili_direct
	Newborn_followUp->events[cnt].bili_indirect    = bili_indirect
	Newborn_followUp->events[cnt].hear_scrn_dt     = hear_scrn_dt
	Newborn_followUp->events[cnt].otostic_rslt     = otostic_rslt
	Newborn_followUp->events[cnt].audibrain_rslt   = audibrain_rslt
	Newborn_followUp->events[cnt].metabo_scrn_dt   = metabo_scrn_dt
	Newborn_followUp->events[cnt].newbrn_scrn_form = newbrn_scrn_form
	Newborn_followUp->events[cnt].carseat_chalng   = carseat_chalng
	Newborn_followUp->events[cnt].blood_type       = blood_type
	Newborn_followUp->events[cnt].dsch_bili        = dsch_bili
	Newborn_followUp->events[cnt].mthd_bili_serum  = mthd_bili_serum
	Newborn_followUp->events[cnt].cchd_rslt        = cchd_rslt
	Newborn_followUp->events[cnt].refr_cardio      = refr_cardio
	Newborn_followUp->events[cnt].drug_scrn        = drug_scrn
	Newborn_followUp->events[cnt].cord_stat_rslt   = cord_stat_rslt
	Newborn_followUp->events[cnt].phototherapy     = phototherapy
	Newborn_followUp->events[cnt].circumcision     = circumcision
	Newborn_followUp->events[cnt].other_procedure  = other_procedure
	Newborn_followUp->events[cnt].disch_dt         = disch_dt
	Newborn_followUp->events[cnt].follup_provider  = follup_provider
	Newborn_followUp->events[cnt].provider_phone   = provider_phone
	Newborn_followUp->events[cnt].appointment_dt   = appointment_dt
	Newborn_followUp->events[cnt].addnl_folup_dt   = addnl_folup_dt
	Newborn_followUp->events[cnt].disch_weight     = disch_weight
	Newborn_followUp->events[cnt].disch_head_cirm  = disch_head_cirm
 	Newborn_followUp->events[cnt].cord_blood_gas   = cord_blood_gas
 
 
FOOT REPORT
 	call alterlist(Newborn_followUp->events, cnt)
 
WITH nocounter
 
 
;****** Get Mother Events **************
 
SELECT INTO "NL:"
 
	ea.alias
 	, e.encntr_id
 	, mom_fin             = max(ea.alias)
 	, mom_name            = initcap(max(pe.name_full_formatted))
 	, mom_dob             = max(pe.birth_dt_tm)
 	, mom_regdt           = max(e.reg_dt_tm)
	, mom_blood_type      = max(evaluate(ce.event_cd, mom_blood_type_var  ,      ce.result_val, 0, ""))
	, hbsag               = max(evaluate(ce.event_cd, hbsag_var           ,      ce.result_val, 0, ""))
	, gbs                 = max(evaluate(ce.event_cd, gbs_var             ,      ce.result_val, 0, ""))
	, gbs_abx             = max(evaluate(ce.event_cd, gbs_abx_var         ,      ce.result_val, 0, ""))
	, doses_abx           = max(evaluate(ce.event_cd, doses_abx_var       ,      ce.result_val, 0, ""))
	, intra_abx           = max(evaluate(ce.event_cd, intra_abx_var       ,      ce.result_val, 0, ""))
	, toxi_scrn           = max(evaluate(ce.event_cd, toxi_scrn_var       ,      ce.result_val, 0, ""))
	, alcohol_use         = max(evaluate(ce.event_cd, alcohol_use_var     ,      ce.result_val, 0, ""))
	, cocaine_use         = max(evaluate(ce.event_cd, cocaine_use_var     ,      ce.result_val, 0, ""))
	, mom_drug_scrn       = max(evaluate(ce.event_cd, drug_scrn_var       ,      ce.result_val, 0, ""))
	, preg_risk           = max(evaluate(ce.event_cd, preg_risk_var       ,      ce.result_val, 0, ""))
	, med_preg            = max(evaluate(ce.event_cd, med_preg_var        ,      ce.result_val, 0, ""))
	, preg_risk_other     = max(evaluate(ce.event_cd, preg_risk_other_var ,      ce.result_val, 0, ""))
	, preg_risk_dtl       = max(evaluate(ce.event_cd, preg_risk_dtl_var   ,      ce.result_val, 0, ""))
	, ega                 = max(evaluate(ce.event_cd, ega_var             ,      ce.result_val, 0, ""))
	, rubella             = max(evaluate(ce.event_cd, rubella_var         ,      ce.result_val, 0, ""))
	, rpr                 = max(evaluate(ce.event_cd, rpr_var             ,      ce.result_val, 0, ""))
	, hepatitis_c         = max(evaluate(ce.event_cd, hepatitis_c_var     ,      ce.result_val, 0, ""))
	, hsv                 = max(evaluate(ce.event_cd, hsv_var             ,      ce.result_val, 0, ""))
	, hiv                 = max(evaluate(ce.event_cd, hiv_var             ,      ce.result_val, 0, ""))
	, gonorhea            = max(evaluate(ce.event_cd, gonorhea_var        ,      ce.result_val, 0, ""))
	, chlamydia           = max(evaluate(ce.event_cd, chlamydia_var       ,      ce.result_val, 0, ""))
	, tobacco             = max(evaluate(ce.event_cd, tobacco_var         ,      ce.result_val, 0, ""))
	, drug                = max(evaluate(ce.event_cd, drug_var            ,      ce.result_val, 0, ""))
	, marijuana           = max(evaluate(ce.event_cd, marijuana_var       ,      ce.result_val, 0, ""))
	, dcs_nitified        = max(evaluate(ce.event_cd, dcs_nitified_var    ,      ce.result_val, 0, ""))
	, rom_dt              = max(evaluate(ce.event_cd, rom_dt_var          ,      ce.result_val, 0, ""))
	, rom_deli_tot        = max(evaluate(ce.event_cd, rom_deli_tot_var    ,      ce.result_val, 0, ""))
	, lngh_rom            = max(evaluate(ce.event_cd, lngh_rom_var        ,      ce.result_val, 0, ""))
	, deli_anes           = max(evaluate(ce.event_cd, deli_anes_var       ,      ce.result_val, 0, ""))
	, med_labor           = max(evaluate(ce.event_cd, med_labor_var       ,      ce.result_val, 0, ""))
	, dt_norcotic         = max(evaluate(ce.event_cd, dt_norcotic_var     ,      ce.result_val, 0, ""))
	, name_abx            = max(evaluate(ce.event_cd, name_abx_var        ,      ce.result_val, 0, ""))
	, ld_complica         = max(evaluate(ce.event_cd, ld_complica_var     ,      ce.result_val, 0, ""))
 
FROM 
     encounter e
     ,person pe
     ,encntr_alias ea
     ,clinical_event ce
 
plan ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
 
join pe where pe.person_id = 
	(select pp.related_person_id 
		from person_person_reltn pp, encntr_alias ea, encounter e
		where ea.alias = $fin
		and e.encntr_id = ea.encntr_id
		and pp.person_id = e.person_id
		and pp.person_reltn_cd = 156 ;Mother
		and pp.active_ind = 1)
	and pe.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id 
	and ce.event_cd in(
 		mom_blood_type_var, hbsag_var, gbs_var, gbs_abx_var, doses_abx_var, intra_abx_var,toxi_scrn_var, alcohol_use_var, cocaine_use_var,
 		mom_drug_scrn_var, preg_risk_var, med_preg_var, preg_risk_other_var, preg_risk_dtl_var, ega_var, rubella_var, rpr_var, hepatitis_c_var,
 		hsv_var, hiv_var, gonorhea_var, chlamydia_var, tobacco_var, drug_var, marijuana_var, dcs_nitified_var, rom_dt_var, rom_deli_tot_var,
 		lngh_rom_var, deli_anes_var, med_labor_var, dt_norcotic_var, name_abx_var, ld_complica_var
	)
 
group by ea.alias, e.encntr_id
 
order by ea.alias, e.encntr_id
 
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
;Populate Mother events in the record structure
 
 
HEAD ea.alias
 
	num = 0
	idx = 0
 
	idx = locateval(num, 1, size(Newborn_followUp->events, 5), ea.alias, Newborn_followUp->events[num].baby_fin)
 
	if(idx > 0)
		Newborn_followUp->events[idx].mom_encntr_id    = e.encntr_id
		Newborn_followUp->events[idx].mom_fin          = mom_fin ;ea1.alias
		Newborn_followUp->events[idx].mom_name         = mom_name
		Newborn_followUp->events[idx].mom_dob          = mom_dob
		Newborn_followUp->events[idx].mom_regdt        = mom_regdt
		Newborn_followUp->events[idx].mom_blood_type   = mom_blood_type
		Newborn_followUp->events[idx].hbsag            = hbsag
		Newborn_followUp->events[idx].gbs              = gbs
		Newborn_followUp->events[idx].gbs_abx          = gbs_abx
		Newborn_followUp->events[idx].doses_abx        = doses_abx
		Newborn_followUp->events[idx].intra_abx        = intra_abx
		Newborn_followUp->events[idx].toxi_scrn        = toxi_scrn
		Newborn_followUp->events[idx].alcohol_use      = alcohol_use
		Newborn_followUp->events[idx].cocaine_use      = cocaine_use
		Newborn_followUp->events[idx].mom_drug_scrn    = mom_drug_scrn
		Newborn_followUp->events[idx].preg_risk        = preg_risk
		Newborn_followUp->events[idx].med_preg         = med_preg
		Newborn_followUp->events[idx].preg_risk_other  = preg_risk_other
		Newborn_followUp->events[idx].preg_risk_dtl    = preg_risk_dtl
		Newborn_followUp->events[idx].ega              = ega
		Newborn_followUp->events[idx].rubella          = rubella
		Newborn_followUp->events[idx].rpr              = rpr
		Newborn_followUp->events[idx].hepatitis_c      = hepatitis_c
		Newborn_followUp->events[idx].hsv              = hsv
		Newborn_followUp->events[idx].hiv              = hiv
		Newborn_followUp->events[idx].gonorhea         = gonorhea
		Newborn_followUp->events[idx].chlamydia        = chlamydia
		Newborn_followUp->events[idx].tobacco          = tobacco
		Newborn_followUp->events[idx].drug             = drug
		Newborn_followUp->events[idx].marijuana        = marijuana
		Newborn_followUp->events[idx].dcs_nitified     = dcs_nitified
		Newborn_followUp->events[idx].rom_dt           = rom_dt
		Newborn_followUp->events[idx].rom_deli_tot     = rom_deli_tot
		Newborn_followUp->events[idx].lngh_rom         = lngh_rom
		Newborn_followUp->events[idx].deli_anes        = deli_anes
		Newborn_followUp->events[idx].med_labor        = med_labor
		Newborn_followUp->events[idx].dt_norcotic      = dt_norcotic
		Newborn_followUp->events[idx].name_abx         = name_abx
		Newborn_followUp->events[idx].ld_complica      = ld_complica
	endif
 
WITH nocounter
 
;CALL ECHORECORD(Newborn_followUp)
 
 
 
end
go
 
 
 
 
 
 
/*CODE VALUES USED
 
   1077.00	FIN NBR
   1079.00	MRN
   2554138243.00	CMRN
   2554143671.00	STAR MRN - MMC  (Alias_pool_cd)
   2553023875.00 - STAR (contributor_system_cd)
   670847.00 CHILD - relation
   1150.00	Default Guarantor - RELATION TYPE
   1153.00	Family Member - RELATION TYPE
   2555267433.00	Newborn  - encounter type
 
;Baby
 
;4156878.00	  Attending Physician
17022064.00	Attending Physician:
832672.00	  Resuscitation at Birth
16728628.00	  Neonate Complications
273404141.00  Newborn Feeding Plans
21102688.00	  Date, Time of Birth
21102625.00	  Maternal Delivery Physician
21102639.00	  Maternal Assistant Physician #1
21102674.00	  Delivery Type, Birth
21102562.00	  Maternal Induction Methods
--Oxytocin
27931307.00	  Maternal Delivery Complications
--;21102862	  EGA at Birth
273388755.00  D-EGA at Documented Date, Time
4169756.00	  Gender
712070.00	  Birth Weight
712073.00	  Birth Length
16766540.00	  Birth Head Circumference
832675.00	  Apgar 5 Minute, by History
832678.00	  Apgar 1 Minute, by History
3338829.00	  Apgar 10 Minute, by History
3338832.00	  APGAR20MINUTEBYHISTORY
16766588.00	  APGAR15MINUTEBYHISTORY
21103070.00	  Neonate Transferred To
16728628.00	  Neonate Complications
4169630.00	  Cord Blood Sent to Lab
27931941.00	  Nursing Shoulder Dystocia
21812605.00	  Maternal Anesthesia Type
40124799.00   Discharge Feeding Type
2797710.00	erythromycin
;2797923.00	hepatitis B vaccine
19923639.00	Hepatitis B Date of Vaccination
 
44629883.00	Vitamin K Dose
703501.00	Systolic Blood Pressure
703516.00	Diastolic Blood Pressure
29887333.00	Blood Pressure Location
21705360.00	Bilirubin Total
21705560.00	Bilirubin Direct
21705242.00	Bilirubin Indirect
27782171.00	Test Performed Date, Time
18752019.00	Otoacoustic Emissions Result
18752026.00	Auditory Brainstem Response Result
18752054.00	   Metabolic Screening Date, Time Drawn
2558942835.00  Newborn Screening Form #
22828550.00	   Car Seat Challenge Result
;2553902529.00  Neonatal ABORh
35289669.00	Maternal Transcribed Blood Type
 
2562410493.00	Newborn CCHD Result
2820509.00	   Cardiology Consultation
2553202125.00  Newborn Drug Screen Results
51256981.00	   Cord Blood Gas Results
16762175.00	Phototherapy Activity
3906499.00	Circumcision
23819802.00	Clinical Discharge Date and Time
3320167.00	Follow-Up Physician
273988183.00	Newborn Physician Appt Date, Time
23819862.00	Follow-Up Clinic Appt Date, Time
2553875897.00	Coombs (Direct)
 
 
;Mother events
 
;Maternal Information
35289669.00	Maternal Transcribed Blood Type
35289733.00	Maternal Transcribed Hepatitis B
35289707.00	Maternal Transcribed GBS
2554390279.00	Name of Antibiotic:
16766581.00	Maternal Intrapartum Antibiotics
273386939.00	Maternal Toxicology Screen
2552741027.00	Toxicology Results Mother
832666.00	Risk Factors in Utero Maternal
832663.00	Maternal Medications During Pregnancy
21102862.00	EGA at Birth
35289695.00	Maternal Transcribed Rubella
35289755.00	Maternal Transcribed RPR/VDRL/Serology
35289761.00	Maternal Transcribed HSV
35289701.00	Maternal Transcribed HIV
2552739133.00	Gonorrhea, Transcribed
2552739093.00	Chlamydia, Transcribed
35286097.00	Tobacco use
2553199599.00	Date and Time DCS Notified:
 
;Labor and delivery Information
16804852.00	ROM Date, Time
16865362.00	ROM to Delivery Total Time:
16865369.00	ROM to Delivery Hours Calc:
2553185553.00	Delivery Anesthesia
2554390667.00	Medications During Labor:
2553185653.00	Date/Time Narcotic Last Adminsitered
2554390279.00	Name of Antibiotic:
20597757.00	Maternal Delivery Complications:
 
 
 
*/

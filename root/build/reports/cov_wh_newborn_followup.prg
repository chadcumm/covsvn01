 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:		        Geetha Saravanan
	Date Written:		Oct'2017
	Solution:			Womens Health
	Source file name:	cov_wh_newborn_followup.prg
	Object name:		cov_wh_newborn_followup
	Request#:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  Mod Date	    Developer			    Comment
  ----------	--------------------	------------------------------------------
  11-2018	    Dan Herren	            CR2819
 
******************************************************************************/
drop program cov_wh_newborn_followup:DBA go
create program cov_wh_newborn_followup:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "1815000015"
 
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
declare hep_B_dt_var          = vc with constant("hepatitis B pediatric/adolescent vaccine"),protect
declare abx_eye_dt_var        = vc with constant("erythromycin ophthalmic"),protect
declare vmin_K_dt_var         = vc with constant("phytonadione"),protect ;Vitamin K1
declare hbig_dt_var           = vc with constant("hepatitis B immune globulin"),protect
 
;Routine Newborn Testing Completed
declare systolic_bp_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Systolic BP")),protect
declare diastolic_bp_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Diastolic BP")),protect
declare bp_location_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Blood Pressure Location")),protect
declare coombs_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord DAT")),protect
declare high_bili_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bilirubin Total")),protect
declare bili_direct_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bilirubin Direct")),protect
declare bili_indirect_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bilirubin Indirect")),protect
declare bili_tq_var			 = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Transcutaneous Bilirubin Result")),protect
 
declare hear_scrn_dt_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Test Performed Date, Time")),protect
declare otostic_rslt_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Otoacoustic Emissions Result")),protect
declare audibrain_rslt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Auditory Brainstem Response Result")),protect
declare metabo_scrn_dt_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Metabolic Screening Date, Time Drawn")),protect
declare newbrn_scrn_form_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Screening Form #")),protect
declare carseat_chalng_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Car Seat Challenge Result")),protect
declare blood_type_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord ABORh")),protect
;declare blood_type_var       = f8 with constant(35289669)
 
declare dsch_bili_var        = f8 with constant(null),protect
declare mthd_bili_serum_var  = f8 with constant(null),protect
declare cchd_rslt_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn CCHD Result")),protect
declare refr_cardio_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Referred to Cardiology")),protect
;declare drug_scrn_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Toxicology Screen on Mother")),protect
;declare drug_scrn_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Drug Screen Results")),protect
declare drug_scrn_var        = f8 with constant(null),protect
 
 
declare cord_stat_rslt_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord Tissue Drug Screen")),protect
;declare cord_blood_gas_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "O2 Sat Art Cord Bld")),protect
declare cord_blood_gas_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "pH Art Cord Bld")),protect ; Arterial
declare cord_venous_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "pH Ven Cord Bld")),protect ;Venous
declare cord_seg_var			= f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord Segment Disposition")), protect
 
;Newborn Procedures
declare phototherapy_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Phototherapy Activity")),protect
declare circumcision_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Circumcision")),protect
declare other_procedure_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Bedside Procedure Type")),protect
 
;Discharge Information
declare disch_dt_var         = f8 ;with constant(uar_get_code_by("DISPLAY", 72, "Clinical Discharge Date and Time")),protect
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
;Maternal Drug Screen Results	 2552811919.00
 
declare preg_risk_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Risk Factors in Utero Maternal")),protect
declare med_preg_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Medications During Pregnancy")),protect
declare preg_risk_other_var  = f8 with constant(null),protect
declare preg_risk_dtl_var    = f8 with constant(null),protect
declare ega_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "EGA at Birth")),protect
declare rubella_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Rubella")),protect
declare rpr_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed RPR/VDRL/Serology")),protect
declare hepatitis_c_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Hepatitis C")),protect
declare hsv_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HSV")),protect
declare hiv_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HIV")),protect
declare tobacco_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Tobacco use")),protect
declare drug_var             = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Drug Screen Results")),protect
declare marijuana_var        = f8 with constant(null),protect
declare dcs_nitified_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Type of DCS Notification")),protect
 
;declare gonorhea_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gonorrhea, Transcribed")),protect
;declare chlamydia_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Chlamydia, Transcribed")),protect
declare gonorhea_var         = f8 with constant(2555366839.00),protect
declare chlamydia_var        = f8 with constant(2555366899.00),protect
 
 
;Labor and delivery Information
declare rom_dt_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM Date, Time")),protect
declare rom_deli_tot_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM to Delivery Total Tm")),protect
declare lngh_rom_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM to Delivery Hr Calc")),protect
declare deli_anes_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Anesthesia")),protect
declare med_labor_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Medications During Labor")),protect
declare dt_norcotic_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time Narcotic Last Adminsitered")),protect
declare name_abx_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Antibiotic")),protect
declare ld_complica_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Complications")),protect
 
 
;Problem/DX vocabulary (code set 400)
DECLARE ICD10_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!56781"))
DECLARE FINAL_DX_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"FINAL"))
DECLARE PRINCIPAL_DX_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"PRINCIPAL"))
DECLARE VISITREASON_DX_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"REASONFORVISIT"))
DECLARE ADMIT_DX_CD         = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"ADMITTING"))
DECLARE DISCH_DX_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"DISCHARGE"))
DECLARE WORKING_DX_CD		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"WORKING"))
DECLARE ICD10PCS_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4101496118"))
DECLARE ICD10CM_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4101498946"))
 
 
 
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
		2 deli_date        = vc
		2 infant_gender    = vc
		2 method_delivery  = vc
		2 provider_hosp    = vc
		2 attend_phys      = vc
		2 other_provider   = vc
		2 Resuscitation    = vc
		2 comp_abnal_finds = vc
		2 feed_pref        = vc
		2 feeding_type     = vc
		2 admit_to   	   = vc
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
		2 bili_tq		   = vc
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
		2 cord_venous      = vc
		2 cord_seg         = vc
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
		2 preg_risk        = c250
		2 med_preg         = vc
		2 preg_risk_other  = c250
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
		2 disch_dx		   = vc
 	) with persistscript
 
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
	, deli_dt  		   = max(evaluate(i2.event_cd, delivery_dt_var,   i2.result_val, 0, ""))
	, infant_gender    = max(evaluate(i2.event_cd, infant_gender_var,   i2.result_val, 0, ""))
	, method_delivery  = max(evaluate(i2.event_cd, delivery_method_var, i2.result_val, 0, ""))
 	, provider_hosp    = initcap(max(evaluate(i2.event_cd, delivery_phys_var,   i2.result_val, 0, "")))
	, attend_phys      = initcap(max(i.name_full_formatted))
 	, other_provider   = initcap(max(evaluate(i2.event_cd, other_provider_var,  i2.result_val, 0, "")))
	, Resuscitation    = max(evaluate(i2.event_cd, Resuscitation_var,   i2.result_val, 0, ""))
	, comp_abnal_finds = max(evaluate(i2.event_cd, comp_abnal_finds_var,i2.result_val, 0, ""))
	, feed_pref        = max(evaluate(i2.event_cd, feed_pref_var,       i2.result_val, 0, ""))
    , feeding_type     = max(evaluate(i2.event_cd, feeding_type_var,    i2.result_val, 0, ""))
    , admit_to         = max(evaluate(i2.event_cd, admit_to_var,        i2.result_val, 0, ""))
; 	, birth_weight     = max(evaluate(i2.event_cd, birth_weight_var,    cnvtreal(i2.result_val)) * 1000)
 	, birth_weight     = max(evaluate(i2.event_cd, birth_weight_var,    i2.result_val, 0, ""))
 	, birth_length     = max(evaluate(i2.event_cd, birth_length_var,    i2.result_val, 0, ""))
	, birth_head       = max(evaluate(i2.event_cd, birth_head_var,      i2.result_val, 0, ""))
	, apgar_1min       = max(evaluate(i2.event_cd, apgar_1min_var,      i2.result_val, 0, ""))
	, apgar_5min       = max(evaluate(i2.event_cd, apgar_5min_var,      i2.result_val, 0, ""))
	, apgar_10min      = max(evaluate(i2.event_cd, apgar_10min_var,     i2.result_val, 0, ""))
	, apgar_15min      = max(evaluate(i2.event_cd, apgar_15min_var,     i2.result_val, 0, ""))
	, apgar_20min      = max(evaluate(i2.event_cd, apgar_20min_var,     i2.result_val, 0, ""))
	, disch_feed_pref  = max(evaluate(i2.event_cd, disch_feed_pref_var, i2.result_val, 0, ""))
	, systolic_bp      = max(evaluate(i2.event_cd, systolic_bp_var,     i2.result_val, 0, ""))
	, diastolic_bp     = max(evaluate(i2.event_cd, diastolic_bp_var ,   i2.result_val, 0, ""))
	, bp_location      = max(evaluate(i2.event_cd, bp_location_var,     i2.result_val, 0, ""))
	, coombs           = max(evaluate(i2.event_cd, coombs_var,          i2.result_val, 0, ""))
	, high_bili        = max(evaluate(i2.event_cd, high_bili_var,       i2.result_val, 0, ""))
	, bili_direct      = max(evaluate(i2.event_cd, bili_direct_var,     i2.result_val, 0, ""))
	, bili_indirect    = max(evaluate(i2.event_cd, bili_indirect_var,   i2.result_val, 0, ""))
	, bili_tq    	   = max(evaluate(i2.event_cd, bili_tq_var,   		i2.result_val, 0, ""))
	, hear_scrn_dt     = max(evaluate(i2.event_cd, hear_scrn_dt_var,    i2.result_val, 0, ""))
	, otostic_rslt     = max(evaluate(i2.event_cd, otostic_rslt_var,    i2.result_val, 0, ""))
	, audibrain_rslt   = max(evaluate(i2.event_cd, audibrain_rslt_var,  i2.result_val, 0, ""))
	, metabo_scrn_dt   = max(evaluate(i2.event_cd, metabo_scrn_dt_var,  i2.result_val, 0, ""))
	, newbrn_scrn_form = max(evaluate(i2.event_cd, newbrn_scrn_form_var,i2.result_val, 0, ""))
	, carseat_chalng   = max(evaluate(i2.event_cd, carseat_chalng_var,  i2.result_val, 0, ""))
 	, blood_type       = max(evaluate(i2.event_cd, blood_type_var,      i2.result_val, 0, ""))
 	, dsch_bili        = max(evaluate(i2.event_cd, dsch_bili_var,       i2.result_val, 0, ""))
	, mthd_bili_serum  = max(evaluate(i2.event_cd, mthd_bili_serum_var, i2.result_val, 0, ""))
	, cchd_rslt        = max(evaluate(i2.event_cd, cchd_rslt_var,       i2.result_val, 0, ""))
	, refr_cardio      = max(evaluate(i2.event_cd, refr_cardio_var,     i2.result_val, 0, ""))
	, drug_scrn        = max(evaluate(i2.event_cd, drug_scrn_var,       i2.result_val, 0, ""))
	, cord_stat_rslt   = max(evaluate(i2.event_cd, cord_stat_rslt_var,  i2.result_val, 0, ""))
	, phototherapy     = max(evaluate(i2.event_cd, phototherapy_var,    i2.result_val, 0, ""))
	, circumcision     = max(evaluate(i2.event_cd, circumcision_var,    i2.result_val, 0, ""))
	, other_procedure  = max(evaluate(i2.event_cd, other_procedure_var, i2.result_val, 0, ""))
	, disch_dt         = format(max(e.disch_dt_tm), "MM/DD/YYYY;;D")
	, follup_provider  = max(evaluate(i2.event_cd, follup_provider_var, i2.result_val, 0, ""))
	, provider_phone   = max(evaluate(i2.event_cd, provider_phone_var , i2.result_val, 0, ""))
	, appointment_dt   = max(evaluate(i2.event_cd, appointment_dt_var , i2.result_val, 0, ""))
	, addnl_folup_dt   = max(evaluate(i2.event_cd, addnl_folup_dt_var , i2.result_val, 0, ""))
	, disch_weight     = max(evaluate(i2.event_cd, disch_weight_var   , i2.result_val, 0, ""))
	, disch_head_cirm  = max(evaluate(i2.event_cd, disch_head_cirm_var, i2.result_val, 0, ""))
	, cord_blood_gas   = max(evaluate(i2.event_cd, cord_blood_gas_var , i2.result_val, 0, ""))
	, cord_seg		   = max(evaluate(i2.event_cd, cord_seg_var , i2.result_val, 0, ""))
  	, mom_fin          = ""
 	, mom_name         = initcap(max(pe1.name_full_formatted))
 	, mom_dob          = max(pe1.birth_dt_tm)
 	, mom_regdt        = max(e.reg_dt_tm)
	, mom_blood_type   = max(evaluate(i2.event_cd, mom_blood_type_var  ,      i2.result_val, 0, ""))
	, hbsag            = max(evaluate(i2.event_cd, hbsag_var           ,      i2.result_val, 0, ""))
	, gbs              = max(evaluate(i2.event_cd, gbs_var             ,      i2.result_val, 0, ""))
	, gbs_abx          = max(evaluate(i2.event_cd, gbs_abx_var         ,      i2.result_val, 0, ""))
	, doses_abx        = max(evaluate(i2.event_cd, doses_abx_var       ,      i2.result_val, 0, ""))
	, intra_abx        = max(evaluate(i2.event_cd, intra_abx_var       ,      i2.result_val, 0, ""))
	, toxi_scrn        = max(evaluate(i2.event_cd, toxi_scrn_var       ,      i2.result_val, 0, ""))
	, alcohol_use      = max(evaluate(i2.event_cd, alcohol_use_var     ,      i2.result_val, 0, ""))
	, cocaine_use      = max(evaluate(i2.event_cd, cocaine_use_var     ,      i2.result_val, 0, ""))
	, mom_drug_scrn    = max(evaluate(i2.event_cd, mom_drug_scrn_var   ,      i2.result_val, 0, ""))
	, preg_risk        = max(evaluate(i2.event_cd, preg_risk_var       ,      i2.result_val, 0, ""))
	, med_preg         = max(evaluate(i2.event_cd, med_preg_var        ,      i2.result_val, 0, ""))
	, preg_risk_other  = max(evaluate(i2.event_cd, preg_risk_other_var ,      i2.result_val, 0, ""))
	, preg_risk_dtl    = max(evaluate(i2.event_cd, preg_risk_dtl_var   ,      i2.result_val, 0, ""))
	, ega              = max(evaluate(i2.event_cd, ega_var             ,      i2.result_val, 0, ""))
	, rubella          = max(evaluate(i2.event_cd, rubella_var         ,      i2.result_val, 0, ""))
	, rpr              = max(evaluate(i2.event_cd, rpr_var             ,      i2.result_val, 0, ""))
	, hepatitis_c      = max(evaluate(i2.event_cd, hepatitis_c_var     ,      i2.result_val, 0, ""))
	, hsv              = max(evaluate(i2.event_cd, hsv_var             ,      i2.result_val, 0, ""))
	, hiv              = max(evaluate(i2.event_cd, hiv_var             ,      i2.result_val, 0, ""))
	, gonorhea         = max(evaluate(i2.event_cd, gonorhea_var        ,      i2.result_val, 0, ""))
	, chlamydia        = max(evaluate(i2.event_cd, chlamydia_var       ,      i2.result_val, 0, ""))
	, tobacco          = max(evaluate(i2.event_cd, tobacco_var         ,      i2.result_val, 0, ""))
	, drug             = max(evaluate(i2.event_cd, drug_var            ,      i2.result_val, 0, ""))
	, marijuana        = max(evaluate(i2.event_cd, marijuana_var       ,      i2.result_val, 0, ""))
	, dcs_nitified     = max(evaluate(i2.event_cd, dcs_nitified_var    ,      i2.result_val, 0, ""))
	, rom_dt           = max(evaluate(i2.event_cd, rom_dt_var          ,      i2.result_val, 0, ""))
	, rom_deli_tot     = max(evaluate(i2.event_cd, rom_deli_tot_var    ,      i2.result_val, 0, ""))
	, lngh_rom         = max(evaluate(i2.event_cd, lngh_rom_var        ,      i2.result_val, 0, ""))
	, deli_anes        = max(evaluate(i2.event_cd, deli_anes_var       ,      i2.result_val, 0, ""))
	, med_labor        = max(evaluate(i2.event_cd, med_labor_var       ,      i2.result_val, 0, ""))
	, dt_norcotic      = max(evaluate(i2.event_cd, dt_norcotic_var     ,      i2.result_val, 0, ""))
	, name_abx         = max(evaluate(i2.event_cd, name_abx_var        ,      i2.result_val, 0, ""))
	, ld_complica      = max(evaluate(i2.event_cd, ld_complica_var     ,      i2.result_val, 0, ""))
	, cord_venous      = max(evaluate(i2.event_cd, cord_venous_var     ,      i2.result_val, 0, ""))
 	, vmin_K_dt        = max(evaluate(i3.hna_order_mnemonic, vmin_K_dt_var,  format(i3.valid_dose_dt_tm, "mm/dd/yyyy;;d")))
 	, hep_B_dt         = max(evaluate(i3.hna_order_mnemonic, hep_B_dt_var,   format(i3.valid_dose_dt_tm, "mm/dd/yyyy;;d")))
	, abx_eye_dt       = max(evaluate(i3.hna_order_mnemonic, abx_eye_dt_var, format(i3.valid_dose_dt_tm, "mm/dd/yyyy;;d")))
	, hbig_dt          = max(evaluate(i3.hna_order_mnemonic, hbig_dt_var,    format(i3.valid_dose_dt_tm, "mm/dd/yyyy;;d")))
 
FROM
	encntr_alias   ea
	, encounter   e
	, encntr_alias ea1
	, address a
	, person   pe
	, person pe1
	, person_alias pa
 
	, (;inline table to get attending physician
		(select pr.name_full_formatted, ea.alias, e.encntr_id
			from encntr_alias ea, encounter e, encntr_prsnl_reltn epr, prsnl pr
			where ea.alias = $fin
			and ea.encntr_alias_type_cd = fin_var
			and ea.active_ind = 1
			and e.encntr_id = ea.encntr_id
			and e.active_ind = 1
			and epr.encntr_id = e.encntr_id
			and epr.prsnl_person_id = pr.person_id
			and epr.encntr_prsnl_r_cd = 1119 ;-attend ,(1116 - admit)
			and epr.active_ind = 1
			and pr.active_ind = 1
		 WITH SQLTYPE("VC50", "VC20", "f8")
		)i
	  )
 
   ,(
		( select distinct ce.encntr_id, ce.event_cd, ce.result_val, ce.updt_dt_tm, ce.result_status_cd
			, ordext2 = dense_rank() over (partition by ce.event_cd order by ce.updt_dt_tm desc)
 
			from encntr_alias ea, clinical_event ce, encounter e
 			where ea.alias = $fin
			and ea.encntr_alias_type_cd = fin_var
			and ea.active_ind = 1
			and e.encntr_id = ea.encntr_id
			and e.active_ind = 1
			and ce.person_id = e.person_id
			and ce.encntr_id = e.encntr_id
			and ce.result_status_cd in(25,34,35)
			and ce.event_cd in(
			  delivery_dt_var, delivery_phys_var, other_provider_var, delivery_method_var, attend_phys_var, Resuscitation_var,
			  infant_gender_var,bili_tq_var	,
			  comp_abnal_finds_var, feed_pref_var, feeding_type_var, admit_to_var, birth_weight_var,
			  birth_length_var, birth_head_var,
			  apgar_1min_var,
			  apgar_5min_var, apgar_10min_var, apgar_15min_var, apgar_20min_var, disch_feed_pref_var, cord_venous_var,
			  systolic_bp_var, diastolic_bp_var, bp_location_var, coombs_var, high_bili_var, cord_blood_gas_var,
			  bili_direct_var, bili_indirect_var, hear_scrn_dt_var, otostic_rslt_var, audibrain_rslt_var, metabo_scrn_dt_var,
			  newbrn_scrn_form_var, carseat_chalng_var, blood_type_var, dsch_bili_var, mthd_bili_serum_var, cchd_rslt_var,
			  refr_cardio_var, drug_scrn_var, cord_stat_rslt_var, phototherapy_var, circumcision_var, other_procedure_var, disch_dt_var,
			  follup_provider_var, provider_phone_var, appointment_dt_var, addnl_folup_dt_var, disch_weight_var, disch_head_cirm_var,
 			  mom_blood_type_var, hbsag_var, gbs_var, gbs_abx_var, doses_abx_var, intra_abx_var,toxi_scrn_var, alcohol_use_var,
 			  cocaine_use_var, cord_seg_var,
 			  mom_drug_scrn_var, preg_risk_var, med_preg_var, preg_risk_other_var, preg_risk_dtl_var, ega_var, rubella_var, rpr_var,
 			  hepatitis_c_var,
	 		  hsv_var, hiv_var, gonorhea_var, chlamydia_var, tobacco_var, drug_var, marijuana_var, dcs_nitified_var,
	 		  rom_dt_var, rom_deli_tot_var,
	 		  lngh_rom_var, deli_anes_var, med_labor_var, dt_norcotic_var, name_abx_var, ld_complica_var
			  )
 
			order by ce.encntr_id, ce.event_cd, ce.updt_dt_tm
			with sqltype("f8", "f8", "vc", "dq8", "f8", "i4")
 
			)i2
		)
	,(
 		(select distinct o.encntr_id, o.hna_order_mnemonic, o.valid_dose_dt_tm
 			, ordext3 = dense_rank() over (partition by o.hna_order_mnemonic order by o.valid_dose_dt_tm desc)
 			from orders o, encntr_alias ea, encounter e, order_action ac
 			where ea.alias = $fin
 			and e.encntr_id = ea.encntr_id
 			and o.encntr_id = e.encntr_id
 			and ac.order_id = o.order_id
 			and ac.order_status_cd = 2543 ;completed
 			and ac.action_sequence = (select max(action_sequence) from order_action where order_id = ac.order_id)
 			and o.active_ind = 1
 			;nd o.hna_order_mnemonic in(hep_B_dt_var, abx_eye_dt_var, vmin_K_dt_var, hbig_dt_var)
 			order by o.encntr_id, o.hna_order_mnemonic
 			with sqltype("f8","vc", "dq8", "i4")
 	 	)i3
 	)
 
plan i2 where i2.ordext2 = 1
	and i2.result_status_cd in(25,34,35)
 
join i where i.encntr_id = outerjoin(i2.encntr_id)
 
join i3 where outerjoin(i3.encntr_id) = i2.encntr_id
  	and i3.ordext3 = outerjoin(1)
 
join ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	 and e.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	  and ea1.alias_pool_cd =  mrn_alias_pool_var
	  and ea1.encntr_alias_type_cd = mrn_var
	  and ea1.active_ind = 1
 
join a where outerjoin(e.organization_id) = a.parent_entity_id
	 and a.active_ind = outerjoin(1)
 
join pe where pe.person_id = e.person_id
	 and pe.active_ind = 1
 
join pe1 where pe1.person_id =
	(select pp.related_person_id
		from person_person_reltn pp, encntr_alias ea, encounter e
		where ea.alias = $fin
		and e.encntr_id = ea.encntr_id
		and pp.person_id = e.person_id
		and pp.person_reltn_cd = 156 ;Mother
		and pp.active_ind = 1)
	and pe1.active_ind = 1
 
join pa where outerjoin(e.person_id) = pa.person_id
	 and pa.alias_pool_cd = outerjoin(cmrn_alias_pool_var)
	 and pa.person_alias_type_cd = outerjoin(cmrn_var)
	 and pa.active_ind = outerjoin(1)
 
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
	Newborn_followUp->events[cnt].deli_date        = deli_dt
	Newborn_followUp->events[cnt].infant_gender    = infant_gender
	Newborn_followUp->events[cnt].method_delivery  = method_delivery
	Newborn_followUp->events[cnt].provider_hosp    = provider_hosp
	Newborn_followUp->events[cnt].attend_phys      = attend_phys
	Newborn_followUp->events[cnt].other_provider   = other_provider
	Newborn_followUp->events[cnt].Resuscitation    = Resuscitation
	Newborn_followUp->events[cnt].comp_abnal_finds = comp_abnal_finds
	Newborn_followUp->events[cnt].feed_pref        = feed_pref
	Newborn_followUp->events[cnt].feeding_type     = feeding_type
	Newborn_followUp->events[cnt].admit_to   	   = admit_to
 	Newborn_followUp->events[cnt].birth_weight     = cnvtreal(birth_weight)
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
	Newborn_followUp->events[cnt].coombs           = coombs
	Newborn_followUp->events[cnt].high_bili        = high_bili
	Newborn_followUp->events[cnt].bili_direct      = bili_direct
	Newborn_followUp->events[cnt].bili_indirect    = bili_indirect
	Newborn_followUp->events[cnt].bili_tq		   = bili_tq
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
	Newborn_followUp->events[cnt].cord_seg		   = cord_seg
	Newborn_followUp->events[cnt].phototherapy     = phototherapy
	Newborn_followUp->events[cnt].circumcision     = circumcision
	Newborn_followUp->events[cnt].other_procedure  = other_procedure
	Newborn_followUp->events[cnt].disch_dt         = disch_dt
	Newborn_followUp->events[cnt].follup_provider  = follup_provider
	Newborn_followUp->events[cnt].provider_phone   = replace(provider_phone, char(94), char(32))
	Newborn_followUp->events[cnt].appointment_dt   = appointment_dt
	Newborn_followUp->events[cnt].addnl_folup_dt   = addnl_folup_dt
	Newborn_followUp->events[cnt].disch_weight     = disch_weight
	Newborn_followUp->events[cnt].disch_head_cirm  = disch_head_cirm
 	Newborn_followUp->events[cnt].cord_blood_gas   = cord_blood_gas
 	Newborn_followUp->events[cnt].cord_venous      = cord_venous
 	Newborn_followUp->events[cnt].mom_encntr_id    = 0 ;e.encntr_id
	Newborn_followUp->events[cnt].mom_fin          = "" ;mom_fin ;ea1.alias
	Newborn_followUp->events[cnt].mom_name         = mom_name
	Newborn_followUp->events[cnt].mom_dob          = mom_dob
	Newborn_followUp->events[cnt].mom_regdt        = mom_regdt
	Newborn_followUp->events[cnt].mom_blood_type   = mom_blood_type
	Newborn_followUp->events[cnt].hbsag            = hbsag
	Newborn_followUp->events[cnt].gbs              = gbs
	Newborn_followUp->events[cnt].gbs_abx          = gbs_abx
	Newborn_followUp->events[cnt].doses_abx        = doses_abx
	Newborn_followUp->events[cnt].intra_abx        = intra_abx
	Newborn_followUp->events[cnt].toxi_scrn        = toxi_scrn
	Newborn_followUp->events[cnt].alcohol_use      = alcohol_use
	Newborn_followUp->events[cnt].cocaine_use      = cocaine_use
	Newborn_followUp->events[cnt].mom_drug_scrn    = mom_drug_scrn
	Newborn_followUp->events[cnt].preg_risk        = preg_risk
	Newborn_followUp->events[cnt].med_preg         = med_preg
	Newborn_followUp->events[cnt].preg_risk_other  = preg_risk_other
	Newborn_followUp->events[cnt].preg_risk_dtl    = preg_risk_dtl
	Newborn_followUp->events[cnt].ega              = ega
	Newborn_followUp->events[cnt].rubella          = rubella
	Newborn_followUp->events[cnt].rpr              = rpr
	Newborn_followUp->events[cnt].hepatitis_c      = hepatitis_c
	Newborn_followUp->events[cnt].hsv              = hsv
	Newborn_followUp->events[cnt].hiv              = hiv
	Newborn_followUp->events[cnt].gonorhea         = gonorhea
	Newborn_followUp->events[cnt].chlamydia        = chlamydia
	Newborn_followUp->events[cnt].tobacco          = tobacco
	Newborn_followUp->events[cnt].drug             = drug
	Newborn_followUp->events[cnt].marijuana        = marijuana
	Newborn_followUp->events[cnt].dcs_nitified     = dcs_nitified
	Newborn_followUp->events[cnt].rom_dt           = rom_dt
	Newborn_followUp->events[cnt].rom_deli_tot     = rom_deli_tot
	Newborn_followUp->events[cnt].lngh_rom         = lngh_rom
	Newborn_followUp->events[cnt].deli_anes        = deli_anes
	Newborn_followUp->events[cnt].med_labor        = med_labor
	Newborn_followUp->events[cnt].dt_norcotic      = dt_norcotic
	Newborn_followUp->events[cnt].name_abx         = name_abx
	Newborn_followUp->events[cnt].ld_complica      = ld_complica
 
FOOT REPORT
 	call alterlist(Newborn_followUp->events, cnt)
 
WITH nocounter
 
;Get discharge dx information
 
 SELECT distinct INTO "NL:"
;select distinct into value ($outdev)
	 dx.encntr_id
	,dx.diagnosis_id
	,testingdx = replace(trim(n.source_string,3), char(44), "")
	,dxdisp  = replace(trim(dx.diagnosis_display,3), char(44), "")
	,type = uar_get_code_display(dx.diag_type_cd)
	,source = uar_get_code_display(n.source_vocabulary_cd)
 
FROM
	 encounter e
	, encntr_alias ea
	, DIAGNOSIS Dx
	, NOMENCLATURE N
 
plan ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
join e where e.encntr_id = ea.encntr_id
	and ea.active_ind = 1
join dx
	WHERE dx.encntr_id = e.encntr_id
	AND Dx.ACTIVE_IND = 1
	AND Dx.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
	AND Dx.DIAG_TYPE_CD in (DISCH_DX_CD)
 
	;AND D.DIAG_PRSNL_ID > 0.0 ;Only qualifies those entered by a clinician
 
join N
	WHERE N.NOMENCLATURE_ID =  dx.NOMENCLATURE_ID
	AND N.SOURCE_VOCABULARY_CD = ICD10CM_CD
 
 
order by
		 DX.diag_priority
		,Dx.DIAGNOSIS_ID
 
;load DX data
Head report
	cnt = 0
	call alterlist(Newborn_followUp->events, 100)
 
detail
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(Newborn_followUp->events, cnt+9)
	endif
	Newborn_followUp->events[cnt].disch_dx = dxdisp
 
Foot report
 	call alterlist(Newborn_followUp->events, cnt)
 
with nocounter
 
 
 
;Get discharge information from Discharge M-Page;
select into "NL:"
;select into value ($outdev)
      pe.encntr_id
    , pe.person_id
    , fol_provider = initcap(p.provider_name)
    , addr = initcap(l.long_text)
; 	, phone = substring(textlen(trim(l.long_text))-13, 13, l.long_text)
    , apt_dt = format(p.fol_within_dt_tm, "mm/dd/yyyy hh:mm;;d")
    , P_ADDRESS_TYPE_DISP = UAR_GET_CODE_DISPLAY(P.ADDRESS_TYPE_CD)
	, p.ADD_LONG_TEXT_ID
	, p.CMT_LONG_TEXT_ID
	, p.DAYS_OR_WEEKS
	, p.FOLLOWUP_NEEDED_IND
	, p.FOL_WITHIN_DAYS
	, p.FOL_WITHIN_DT_TM
	, p.FOL_WITHIN_RANGE
	, p.LAST_UTC_TS
	, P_LOCATION_DISP = UAR_GET_CODE_DISPLAY(P.LOCATION_CD)
	, p.ORGANIZATION_ID
	, p.PAT_ED_DOC_FOLLOWUP_ID
	, p.PAT_ED_DOC_ID
	, p.PROVIDER_ID
	, p.PROVIDER_NAME
	, P_QUICK_PICK_DISP = UAR_GET_CODE_DISPLAY(P.QUICK_PICK_CD)
	, p.RECIPIENT_LONG_TEXT_ID
	, p.ROWID
	, p.TXN_ID_TEXT
 
 from
	 encounter e
	 , encntr_alias ea
     , pat_ed_doc_followup p
     , pat_ed_document pe
     , long_text l
     , long_text l2

plan ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and ea.active_ind = 1
 
join pe where pe.person_id = e.person_id
	and pe.encntr_id = e.encntr_id
 
join p where PE.PAT_ED_DOCUMENT_ID = P.PAT_ED_DOC_ID
	and p.fol_within_dt_tm is not null
 
join l where p.add_long_text_id =  l.long_text_id
 
join l2 where P.CMT_LONG_TEXT_ID =   l2.long_text_id
 
 
;load Discharge data
Head report
	cnt = 0
	call alterlist(Newborn_followUp->events, 100)
Detail
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(Newborn_followUp->events, cnt+9)
	endif
	Newborn_followUp->events[cnt].follup_provider = fol_provider
	Newborn_followUp->events[cnt].provider_phone  = replace(replace(trim(addr), char(94), char(32)), char(59), char(32))
	Newborn_followUp->events[cnt].appointment_dt  = apt_dt
	
Foot report
 	call alterlist(Newborn_followUp->events, cnt)
 
with nocounter ;, separator = " ", format, check
 
 
 
;CALL ECHORECORD(Newborn_followUp)
 
 
end
go
 
 

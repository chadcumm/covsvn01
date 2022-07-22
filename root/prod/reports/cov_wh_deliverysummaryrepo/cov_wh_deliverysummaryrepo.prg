 
 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			    Geetha Saravanan
	Date Written:		Oct'2017
	Solution:			Womens Health
	Source file name:	cov_wh_deliverysummary.prg
	Object name:		cov_wh_deliverysummary
	Request#:			20
 
	Program purpose:	Post delivery information for OB providers to assist in the continum of care.
 
	Executing from:		CCL
 
 	Special Notes:		Printed from mother's chart and placed on Newborn's chart.
 					    OB/GYN may also take copy of Delivery Summary for Office Chart.
 
 					    Printed for Individual chart only.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_wh_deliverysummaryrepo:DBA go
create program cov_wh_deliverysummaryrepo:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Enter  FIN" = ""
 
with OUTDEV, FIN
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
declare initcap() = c100
declare facility_code_var        = f8 with constant(get_FacilityCode($fin)), protect
declare mrn_alias_pool_var       = f8 with constant(get_AliasPoolCode(facility_code_var)), protect
declare mrn_var                  = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")), protect
declare fin_var                  = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")), protect
declare relation_var             = f8 with constant(uar_get_code_by("DISPLAYKEY", 40,"CHILD")), protect
declare encounter_type_var       = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NEWBORN")), protect
declare admit_type_var           = f8 with constant(uar_get_code_by("DISPLAYKEY", 3, "Elective")), protect
;declare vbac_var                = f8 with constant(uar_get_code_by("DISPLAYkEY", 4002119, "VBAC")), protect
declare vbac_var                 = f8 with constant(uar_get_code_by("DISPLAY", 72, "Previous Cesarean Delivery")), protect
declare delivery_type_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Type:")), protect
 
;Maternal/Labor/Delivary information
declare deli_doctor_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Physician:")), protect
declare anesthesiologist_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Anesthesiologist Attending Delivery:")), protect
declare anesthetist_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Anesthetist/ CRNA:")), protect
declare deli_anesthesia_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Anesthesia:")), protect
declare labor_anes_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Medications During Labor:")), protect
declare anes_medication_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Anesthesia Medication:")), protect
declare dt_anes_admins_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Anesthesia Medication, Administered:")), protect
declare med_during_labor_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Medications During Labor:")), protect
declare dt_norcotic_given_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time Narcotic Last Administered:")), protect
declare onset_labor_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Labor Onset, Date, Time:")), protect
 
declare complete_dilation_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Complete Cervical Dilation Date/Time")), protect
declare rom_method_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Membrane Status:")), protect
declare oxytocin_var             = f8 with constant(uar_get_code_by("DISPLAY", 72, "oxytocin")), protect
declare group_beta_strep_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Group B Strep, Transcribed")), protect
declare antibio_num_dose_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Intrapartum Antibiotics, Transcribed")), protect
declare antibio_dose_last_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Intrapartum Antibiotics Given Date/Time:")), protect
declare name_antibio_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Antibiotic:")), protect
declare steroids_given_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Antepartum Steroids, Transcribed")), protect
declare resn_strid_not_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Reason Antenatal Steroids Not Given")), protect
declare resn_not_other_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Reg PC Reason for No Ant Steroids Other")), protect
 
;G/P/T/Pt/SAB/LAB/L
declare gravida_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gravida")), protect
declare para_full_var		     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Para Full Term")), protect
declare para_premat_var		     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Para Premature")), protect
declare para_var                 = f8 with constant(uar_get_code_by("DISPLAY", 72, "Para")), protect
declare para_spon_var            = f8 with constant(uar_get_code_by("DISPLAY", 72, "Spontaneous Abortions Pregnancy Hx")), protect
declare para_indu_abx_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Induced Abortions Pregnancy History")), protect
declare para_liv_chi_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Living Children Pregnancy History")), protect
 
;Baby
declare baby_nurse_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Nursery/Baby Nurse:")), protect
declare scrub_nurse_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Scrub Nurse")), protect
declare labor_nurse_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery RN #1:")), protect
declare other_personnel_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Other Delivery Clinicians:")), protect
declare scrub_personnel_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Scrub Tech:")), protect
declare no_babies_womp_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Multiple Gestation Description:")), protect
declare amntc_fluid_color_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Amniotic Fluid Color/Description:")), protect
declare amntc_fluid_odor_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Amniotic Fluid Abnormal Odor:")), protect
declare amntc_fluid_cultur_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Amniotic Fluid Cultures Sent:")), protect
declare amntc_fluid_amt_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Amniotic Fluid Amount:")), protect
 
declare cervic_rip_agent_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Agent Cervical Ripening Type")), protect
declare other_rip_agent_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Mechanical Cervical Ripening Type")), protect
declare placenta_cultred_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Placenta Disposition:")), protect
declare ebl_var                  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery EBL")), protect
declare reasn_induction_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Indication for Induction Documented")), protect
declare stage1_labor_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Length of Labor, 1st Stage Hrs Calc:")), protect
declare stage2_labor_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Length of Labor, 2nd Stage:")), protect
declare stage3_labor_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Length of Labor, 3rd Stage:")), protect
declare total_labor_time_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Total Length of Labor Hr Calc:")), protect
declare meds_delivery_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Medications During L&D")), protect
 
;Vaginal Delivery
declare laceration_type_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Laceration Degree Transcribed")), protect
declare laceration_loc_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Laceration Location Transcribed")), protect
declare episiotomy_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Episiotomy Transcribed")), protect
declare episiotomy_loc_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Episiotomy Location Transcribed")), protect
declare laceration_repair_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Laceration Repair Transcribed")), protect
declare other_laceration_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Laceration Laceration Other Location")), protect
declare repair_note_var		     = f8 with constant(null), protect
declare pre_deli_cnt_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Pre-Delivery Counts Performed")), protect
declare post_deli_cnt_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Post-Delivery Counts Performed")), protect
declare cnt_correct_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Counts Correct")), protect
 
;Maternal complications
declare deli_comp_var            = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Complications:")), protect
declare other_deli_comp_var      = f8 with constant(null), protect
 
;Delivery comments
declare rn_comnts_var            = f8 with constant(uar_get_code_by("DISPLAY", 72, "RN Comments")), protect
declare provider_comnts_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "OB Provider Delivery Comments")), protect
 
;Baby A - delivery information
declare delivery_dt_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date, Time of Birth:")), protect
declare method_deli_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Type:")), protect
declare born_en_route_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Location of Birth")), protect
 
declare forcep_type_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Forceps Type:")), protect
declare forcep_activity_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Forceps Activity:")), protect
declare vacum_type_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Vacuum Type:")), protect
declare vacum_activity_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Vacuum Activity:")), protect
declare shoulder_dystocia_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Shoulder Dystocia Nursing Interventions:")), protect
declare ga_at_deli_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "D-EGA at Delivery:")), protect
declare neonate_outcome_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Outcome:")), protect
declare neonate_condition_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Infant Condition at Birth")), protect
declare gender_var               = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gender:")), protect
declare birth_weight_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Weight:")), protect
 
;delivery summary
declare presentation_var         = f8  with constant(uar_get_code_by("DISPLAY", 72, "Presenting Part")), protect
declare length_var               = f8  with constant(uar_get_code_by("DISPLAY", 72, "Birth Length:")), protect
declare rom_dt_var               = f8  with constant(uar_get_code_by("DISPLAY", 72, "ROM Date, Time:")), protect
declare length_repture_var       = f8  with constant(uar_get_code_by("DISPLAY", 72, "ROM to Delivery Hours Calc:")), protect
declare plcnta_deli_time_var     = dq8 with constant(uar_get_code_by("DISPLAY", 72, "Placenta Delivery Date, Time:")), protect
declare plcnta_deli_mthod_var    = f8  with constant(uar_get_code_by("DISPLAY", 72, "Placenta Delivery Method:")), protect
declare plcnta_status_var        = f8  with constant(uar_get_code_by("DISPLAY", 72, "Placenta Status")), protect
declare plcnta_disposn_var       = f8  with constant(uar_get_code_by("DISPLAY", 72, "Placenta Dispostion:")), protect
declare cord_vessels_var         = f8  with constant(uar_get_code_by("DISPLAY", 72, "Umbilical Cord Description:")), protect
declare nuchal_cord_var          = f8  with constant(uar_get_code_by("DISPLAY", 72, "Nuchal Cord Times:")), protect
declare nucl_cord_tension_var    = f8  with constant(uar_get_code_by("DISPLAY", 72, "Nuchal Cord Tension:")), protect
 
declare cord_ph_var              = f8  with constant(uar_get_code_by("DISPLAY", 72, "OB Provider Cord Blood Gas pH")), protect
declare cord_ph_obtained_var     = f8  with constant(uar_get_code_by("DISPLAY", 72, "Cord Blood pH Drawn:")), protect
declare cord_bld_taken_var       = f8  with constant(uar_get_code_by("DISPLAY", 72, "Cord Blood Sent to Lab:")), protect
declare bank_donate_var          = f8  with constant(uar_get_code_by("DISPLAY", 72, "Cord Blood Banking:")), protect
declare cord_sgmnt_colecd_var    = f8  with constant(uar_get_code_by("DISPLAY", 72, "Cord Segment Collected:")), protect
declare cord_sgmnt_dispo_var     = f8  with constant(uar_get_code_by("DISPLAY", 72, "Cord Segment Disposition:")), protect
declare suction_var              = f8  with constant(uar_get_code_by("DISPLAY", 72, "Suction:")), protect
declare suction_amount_var       = f8  with constant(uar_get_code_by("DISPLAY", 72, "Sputum Amount:")), protect
declare color_suctioned_var      = f8  with constant(uar_get_code_by("DISPLAY", 72, "Sputum Color:")), protect
declare void_output_var          = f8  with constant(uar_get_code_by("DISPLAY", 72, "Newborn Output:")), protect
declare stool_output_var         = f8  with constant(uar_get_code_by("DISPLAY", 72, "Newborn Output")), protect
 
;Apgars
declare apgar_1min_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Apgar Score 1 Minute:")), protect
declare apgar_5min_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Apgar Score 5 Minute:")), protect
declare apgar_10min_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Apgar Score 10 Minute:")), protect
declare apgar_15min_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Apgar Score 15 Minute:")), protect
declare apgar_20min_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Apgar Score 20 Minute:")), protect
 
;Assessment
declare infant_comp_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Complications:")), protect
declare resprn_type_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Respirations:")), protect
declare neonatlogy_called_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonatology Called")), protect
declare infant_care_by_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Examination By:")), protect
declare neonate_death_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "OB Loss Date, Time of Neonatal Death:")), protect
declare neonate_trans_to_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Transferred To:")), protect
declare skn_to_skin_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Skin to Skin Contact Initiated:")), protect
declare skn_to_skn_time_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Amount of Time for Skin to Skin Contact:")), protect
 										
;Medications
declare vitamin_K_dt_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Vitamin K Dose")), protect
declare antibio_eye_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "erythromycin")), protect
 
;identification Information
declare id_band_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "ID Band Number:")), protect
declare id_band_loc_var         = f8 with constant(null), protect
declare id_band_read_by_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "ID Band Verified By:")), protect
declare sensor_aplied_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Security Tag Applied:")), protect
declare sensor_nbr_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Security Tag Number:")), protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;Create Record Structure
RECORD delivery_summary(
	1 events[*]
	 	2 street_address        = vc
	 	2 city_name             = vc
	 	2 state_name            = vc
	 	2 zip_code              = vc
		2 facility              = vc
		2 mom_fin               = vc
		2 mom_mrn               = vc
		2 mom_age               = vc
		2 mom_person_id         = f8
		2 mom_encntr_id         = f8
		2 mom_dob               = vc
		2 mom_admit_dt          = vc
		2 mom_name              = vc
 		2 deli_doctor           = vc
 		2 mom_gravida           = vc
 		2 para_fullterm         = vc
		2 para_premature        = vc
		2 para                  = vc
		2 para_spon_abortion    = vc
		2 para_induced_abortion = vc
		2 para_living_children  = vc
		2 med_during_labor      = vc
		2 antibio_num_dose      = vc
		2 scrub_nurse           = vc
		2 amntc_fluid_odor      = vc
		2 stage1_labor          = vc
		2 episiotomy            = vc
		2 rn_comnts             = vc
		2 length_repture        = vc
		2 cord_sgmnt_dispo      = vc
		2 anesthesiologist      = vc
		2 dt_norcotic_given     = vc
		2 antibio_dose_last     = vc
		2 labor_nurse           = vc
		2 amntc_fluid_amt       = vc
		2 stage2_labor          = vc
		2 episiotomy_loc        = vc
		2 provider_comnts       = vc
		2 plcnta_deli_time      = vc
		2 suction               = vc
		2 anesthetist           = vc
		2 onset_labor           = vc
		2 name_antibio          = vc
		2 other_personnel       = vc
		2 cervic_rip_agent      = vc
		2 stage3_labor          = vc
		2 laceration_repair     = vc
		2 presentation          = vc
		2 plcnta_deli_mthod     = vc
		2 cord_ph               = vc
		2 suction_amount        = vc
		2 deli_anesthesia       = vc
		2 complete_dilation     = vc
		2 pre_deli_cnt          = vc
		2 post_deli_cnt         = vc
		2 cnt_correct           = vc
		2 steroids_given        = vc
		2 scrub_personnel       = vc
		2 other_rip_agent       = vc
		2 total_labor_time      = vc
		2 other_laceration      = vc
		2 length                = vc
		2 plcnta_status         = vc
		2 cord_ph_obtained      = vc
		2 color_suctioned       = vc
		2 labor_anes            = vc
		2 rom_method            = vc
		2 resn_strid_not        = vc
		2 no_babies_womp        = vc
		2 placenta_cultred      = vc
		2 meds_delivery         = vc
		2 repair_note           = vc
		2 plcnta_disposn        = vc
		2 cord_bld_taken        = vc
		2 anes_medication       = vc
		2 oxytocin              = vc
		2 resn_not_other        = vc
		2 vbac_attempted        = vc
		2 ebl                   = vc
		2 laceration_type       = vc
		2 deli_comp             = vc
		2 nucal_cord_tenson     = vc
		2 cord_vessels          = vc
		2 bank_donate           = vc
		2 dt_anes_admins        = vc
		2 group_beta_strep      = vc
		2 baby_nurse            = vc
		2 amntc_fluid_color     = vc
		2 amntc_fluid_cultur    = vc
		2 reasn_induction       = vc
		2 laceration_loc        = vc
		2 other_deli_comp       = vc
		2 rom_dt                = vc
		2 nuchal_cord           = vc
		2 cord_sgmnt_colecd     = vc
		2 delivery_type         = vc
		2 baby_encounter_id	    = f8
		2 void_output           = vc
		2 stool_output          = vc
 		2 apgar_1min            = vc
		2 apgar_5min            = vc
		2 apgar_10min           = vc
		2 apgar_15min           = vc
		2 apgar_20min           = vc
		2 neonatlogy_called     = vc
		2 antibio_eye           = vc
		2 delivery_dt           = vc
		2 vacum_activity        = vc
		2 infant_care_by        = vc
		2 id_band               = vc
		2 method_deli           = vc
		2 shoulder_dystocia     = vc
		2 infant_comp           = vc
		2 neonate_death         = vc
		2 born_en_route         = vc
		2 ga_at_deli            = vc
		2 neonate_trans_to      = vc
		2 id_band_read_by       = vc
		2 forcep_type           = vc
		2 neonate_outcome       = vc
		2 skn_to_skin           = vc
		2 sensor_aplied         = vc
		2 forcep_activity       = vc
		2 neonate_condition     = vc
		2 skn_to_skn_time       = vc
		2 sensor_nbr            = vc
		2 vacum_type            = vc
		2 gender                = vc
		2 resprn_type           = vc
		2 vitamin_K_dt          = vc
		2 birth_weight          = vc
		2 vbac                  = vc
	)
 
;Find Mother events
SELECT DISTINCT INTO "NL:"
 
  	  a.street_addr
 	, a.city
 	, a.state
 	, a.zipcode
	, e.loc_facility_cd
	, e.person_id
	, e.encntr_id
	, pe.birth_dt_tm
	, facility_name        = uar_get_code_description(e.loc_facility_cd)
 	, patient_dob          = format(max(pe.birth_dt_tm), "MM/DD/YYYY;;D")
 	, admit_date           = format(max(e.reg_dt_tm), "MM/DD/YYYY;;D")
 	, age                  = cnvtage(pe.birth_dt_tm)
 	, patient_name         = max(initcap(pe.name_full_formatted))
 	, latest_update        = format(max(ce.updt_dt_tm), "MM/DD/YYYY  HH:MM;;D")
 	, vbac                 = uar_get_code_display(pc.delivery_method_cd)
 	, mrn                  = max(evaluate(ea1.encntr_alias_type_cd, mrn_var,  ea1.alias, 0, ""))
 	, mom_gravi            = max(evaluate(ce.event_cd, gravida_var,            ce.result_val, 0, ""))
 	, onset_labor          = max(evaluate(ce.event_cd, onset_labor_var,        ce.result_val, 0, ""))
 	, complete_dilation    = max(evaluate(ce.event_cd, complete_dilation_var,  ce.result_val, 0, ""))
 	, plcnta_deli_time     = max(evaluate(ce.event_cd, plcnta_deli_time_var,   ce.result_val, 0, ""))
 	, deli_doctor          = max(evaluate(ce.event_cd, deli_doctor_var,        initcap(ce.result_val), 0, ""))
 	, anesthesiologist     = max(evaluate(ce.event_cd, anesthesiologist_var,   ce.result_val, 0, ""))
 	, anesthetist          = max(evaluate(ce.event_cd, anesthetist_var,        ce.result_val, 0, ""))
 	, deli_anesthesia      = max(evaluate(ce.event_cd, deli_anesthesia_var,    ce.result_val, 0, ""))
 	, labor_anes           = max(evaluate(ce.event_cd, labor_anes_var,         ce.result_val, 0, ""))
 	, anes_medication      = max(evaluate(ce.event_cd, anes_medication_var,    ce.result_val, 0, ""))
 	, dt_anes_admins       = max(evaluate(ce.event_cd, dt_anes_admins_var,     ce.result_val, 0, ""))
 	, med_during_labor     = max(evaluate(ce.event_cd, med_during_labor_var,   ce.result_val, 0, ""))
 	, dt_norcotic_given    = max(evaluate(ce.event_cd, dt_norcotic_given_var,  ce.result_val, 0, ""))
 	, rom_method           = max(evaluate(ce.event_cd, rom_method_var,         ce.result_val, 0, ""))
 	, oxytocin             = max(evaluate(ce.event_cd, oxytocin_var,           ce.result_val, 0, ""))
 	, group_beta_strep     = max(evaluate(ce.event_cd, group_beta_strep_var,   ce.result_val, 0, ""))
 	, antibio_num_dose     = max(evaluate(ce.event_cd, antibio_num_dose_var,   ce.result_val, 0, ""))
 	, antibio_dose_last    = max(evaluate(ce.event_cd, antibio_dose_last_var,  ce.result_val, 0, ""))
 	, pre_deli_count       = max(evaluate(ce.event_cd, pre_deli_cnt_var,       ce.result_val, 0, ""))
	, post_deli_count      = max(evaluate(ce.event_cd, post_deli_cnt_var,      ce.result_val, 0, ""))
	, count_correct        = max(evaluate(ce.event_cd, cnt_correct_var,        ce.result_val, 0, ""))
 	, name_antibio         = max(evaluate(ce.event_cd, name_antibio_var,       ce.result_val, 0, ""))
 	, steroids_given       = max(evaluate(ce.event_cd, steroids_given_var,     ce.result_val, 0, ""))
 	, resn_strid_not       = max(evaluate(ce.event_cd, resn_strid_not_var,     ce.result_val, 0, ""))
 	, resn_not_other       = max(evaluate(ce.event_cd, resn_not_other_var,     ce.result_val, 0, ""))
 	, baby_nurse           = max(evaluate(ce.event_cd, baby_nurse_var,         initcap(ce.result_val), 0, ""))
 	, scrub_nurse          = max(evaluate(ce.event_cd, scrub_nurse_var,        ce.result_val, 0, ""))
 	, labor_nurse          = max(evaluate(ce.event_cd, labor_nurse_var,        initcap(ce.result_val), 0, ""))
 	, other_personnel      = max(evaluate(ce.event_cd, other_personnel_var,    initcap(ce.result_val), 0, ""))
 	, scrub_personnel      = max(evaluate(ce.event_cd, scrub_personnel_var,    initcap(ce.result_val), 0, ""))
 	, no_babies_womp       = max(evaluate(ce.event_cd, no_babies_womp_var,     ce.result_val, 0, ""))
 	, amntc_fluid_color    = max(evaluate(ce.event_cd, amntc_fluid_color_var,  ce.result_val, 0, ""))
 	, amntc_fluid_odor     = max(evaluate(ce.event_cd, amntc_fluid_odor_var,   ce.result_val, 0, ""))
 	, amntc_fluid_cultur   = max(evaluate(ce.event_cd, amntc_fluid_cultur_var, ce.result_val, 0, ""))
 	, amntc_fluid_amt      = max(evaluate(ce.event_cd, amntc_fluid_amt_var,    ce.result_val, 0, ""))
 	, cervic_rip_agent     = max(evaluate(ce.event_cd, cervic_rip_agent_var,   ce.result_val, 0, ""))
 	, other_rip_agent      = max(evaluate(ce.event_cd, other_rip_agent_var,    ce.result_val, 0, ""))
 	, placenta_cultred     = max(evaluate(ce.event_cd, placenta_cultred_var,   ce.result_val, 0, ""))
 	, ebl                  = max(evaluate(ce.event_cd, ebl_var,                ce.result_val, 0, ""))
 	, reasn_induction      = max(evaluate(ce.event_cd, reasn_induction_var,    ce.result_val, 0, ""))
 	, stage1_labor         = max(evaluate(ce.event_cd, stage1_labor_var,       ce.result_val, 0, ""))
 	, stage2_labor         = max(evaluate(ce.event_cd, stage2_labor_var,       ce.result_val, 0, ""))
 	, stage3_labor         = max(evaluate(ce.event_cd, stage3_labor_var,       ce.result_val, 0, ""))
 	, total_labor_time     = max(evaluate(ce.event_cd, total_labor_time_var,   ce.result_val, 0, ""))
 	, meds_delivery        = max(evaluate(ce.event_cd, meds_delivery_var,      ce.result_val, 0, ""))
 	, laceration_type      = max(evaluate(ce.event_cd, laceration_type_var,    ce.result_val, 0, ""))
 	, laceration_loc       = max(evaluate(ce.event_cd, laceration_loc_var,     ce.result_val, 0, ""))
 	, episiotomy           = max(evaluate(ce.event_cd, episiotomy_var,         ce.result_val, 0, ""))
 	, episiotomy_loc       = max(evaluate(ce.event_cd, episiotomy_loc_var,     ce.result_val, 0, ""))
 	, laceration_repair    = max(evaluate(ce.event_cd, laceration_repair_var,  ce.result_val, 0, ""))
 	, other_laceration     = max(evaluate(ce.event_cd, other_laceration_var,   ce.result_val, 0, ""))
 	, repair_note          = max(evaluate(ce.event_cd, repair_note_var,        ce.result_val, 0, ""))
 	, deli_comp            = max(evaluate(ce.event_cd, deli_comp_var,          ce.result_val, 0, ""))
 	, other_deli_comp      = max(evaluate(ce.event_cd, other_deli_comp_var,    ce.result_val, 0, ""))
 	, rn_comnts            = max(evaluate(ce.event_cd, rn_comnts_var,          ce.result_val, 0, ""))
 	, provider_comnts      = max(evaluate(ce.event_cd, provider_comnts_var,    ce.result_val, 0, ""))
 	, presentation         = max(evaluate(ce.event_cd, presentation_var,       ce.result_val, 0, ""))
 	, length               = max(evaluate(ce.event_cd, length_var,             ce.result_val, 0, ""))
 	, rom_dt               = max(evaluate(ce.event_cd, rom_dt_var,             ce.result_val, 0, ""))
	, length_repture       = max(evaluate(ce.event_cd, length_repture_var,     ce.result_val, 0, ""))
 	, plcnta_deli_mthod    = max(evaluate(ce.event_cd, plcnta_deli_mthod_var,  ce.result_val, 0, ""))
 	, plcnta_status        = max(evaluate(ce.event_cd, plcnta_status_var,      ce.result_val, 0, ""))
 	, plcnta_disposn       = max(evaluate(ce.event_cd, plcnta_disposn_var,     ce.result_val, 0, ""))
 	, nuchal_cord          = max(evaluate(ce.event_cd, nuchal_cord_var,        ce.result_val, 0, ""))
 	, nucal_tension        = max(evaluate(ce.event_cd, nucl_cord_tension_var,  ce.result_val, 0, ""))
  	, cord_ph              = max(evaluate(ce.event_cd, cord_ph_var,            ce.result_val, 0, ""))
 	, cord_ph_obtained     = max(evaluate(ce.event_cd, cord_ph_obtained_var,   ce.result_val, 0, ""))
 	, cord_bld_taken       = max(evaluate(ce.event_cd, cord_bld_taken_var,     ce.result_val, 0, ""))
 	, bank_donate          = max(evaluate(ce.event_cd, bank_donate_var,        ce.result_val, 0, ""))
 	, cord_sgmnt_colecd    = max(evaluate(ce.event_cd, cord_sgmnt_colecd_var,  ce.result_val, 0, ""))
 	, cord_sgmnt_dispo     = max(evaluate(ce.event_cd, cord_sgmnt_dispo_var,   ce.result_val, 0, ""))
 	, suction              = max(evaluate(ce.event_cd, suction_var,            ce.result_val, 0, ""))
	, suction_amount       = max(evaluate(ce.event_cd, suction_amount_var,     ce.result_val, 0, ""))
 	, color_suctioned      = max(evaluate(ce.event_cd, color_suctioned_var,    ce.result_val, 0, ""))
 	, delivery_type        = max(evaluate(ce.event_cd, delivery_type_var,      ce.result_val, 0, ""))
 	, ga_at_deli           = max(evaluate(ce.event_cd, ga_at_deli_var,         ce.result_val, 0, ""))
 	, neonate_outcome      = max(evaluate(ce.event_cd, neonate_outcome_var,    ce.result_val, 0, ""))
  	, para_fullterm        = max(evaluate(ce.event_cd, para_full_var,	       ce.result_val, 0, ""))
 	, para_premature       = max(evaluate(ce.event_cd, para_premat_var,	       ce.result_val, 0, ""))
 	, para                 = max(evaluate(ce.event_cd, para_var,               ce.result_val, 0, ""))
	, para_spon_abortion   = max(evaluate(ce.event_cd, para_spon_var,          ce.result_val, 0, ""))
	, para_induced_abortion = max(evaluate(ce.event_cd, para_indu_abx_var,     ce.result_val, 0, ""))
	, para_living_children  = max(evaluate(ce.event_cd, para_liv_chi_var,      ce.result_val, 0, ""))
 
from
	  encntr_alias   ea
	, encntr_alias   ea1
	, encounter   e
	, address a
	, person   pe
	, pregnancy_child pc
	, clinical_event ce
 
plan ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
 
join a where outerjoin(e.organization_id) = a.parent_entity_id
	 and a.active_ind = outerjoin(1)
 
join ea1 where ea1.encntr_id = e.encntr_id
	  and ea1.alias_pool_cd =  mrn_alias_pool_var
	  and ea1.encntr_alias_type_cd = mrn_var
	  and ea1.active_ind = 1
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join pc where outerjoin(e.person_id) = pc.person_id
	and pc.active_ind = outerjoin(1)
 
join ce where ce.encntr_id = ea.encntr_id
	and ce.event_cd in
	(
 	deli_doctor_var, anesthesiologist_var, anesthetist_var, deli_anesthesia_var, labor_anes_var, anes_medication_var, dt_anes_admins_var,
	med_during_labor_var, dt_norcotic_given_var, onset_labor_var, complete_dilation_var, rom_method_var, oxytocin_var, group_beta_strep_var,
	antibio_num_dose_var, antibio_dose_last_var, name_antibio_var, steroids_given_var, resn_strid_not_var, resn_not_other_var, baby_nurse_var,
	scrub_nurse_var, labor_nurse_var, other_personnel_var, scrub_personnel_var, no_babies_womp_var, amntc_fluid_color_var,amntc_fluid_cultur_var,
	amntc_fluid_odor_var, amntc_fluid_amt_var, cervic_rip_agent_var, other_rip_agent_var, placenta_cultred_var, ebl_var, reasn_induction_var,
	stage1_labor_var, stage2_labor_var, stage3_labor_var, total_labor_time_var, meds_delivery_var, laceration_type_var, laceration_loc_var,
	episiotomy_var, episiotomy_loc_var, laceration_repair_var, other_laceration_var, repair_note_var, deli_comp_var,other_deli_comp_var,
	rn_comnts_var, provider_comnts_var,	presentation_var, length_var, rom_dt_var,
	length_repture_var, plcnta_deli_time_var, plcnta_deli_mthod_var, plcnta_status_var, plcnta_disposn_var, nuchal_cord_var,
	nucl_cord_tension_var, cord_ph_var, cord_ph_obtained_var, cord_bld_taken_var, bank_donate_var, cord_sgmnt_colecd_var,
	cord_sgmnt_dispo_var, suction_var, suction_amount_var, color_suctioned_var, delivery_type_var, ga_at_deli_var, gravida_var,
	neonate_outcome_var, pre_deli_cnt_var, post_deli_cnt_var, cnt_correct_var,
	para_full_var, para_premat_var, para_var, para_spon_var, para_indu_abx_var , para_liv_chi_var
	)
	and ce.updt_dt_tm = (select max(c2.updt_dt_tm) from clinical_event c2
				where c2.event_cd = ce.event_cd and c2.encntr_id = ce.encntr_id)
 
 
group by a.street_addr, a.city, a.state, a.zipcode, e.loc_facility_cd, e.person_id, e.encntr_id, pe.birth_dt_tm
 
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
;Populate record structure with Mother events
HEAD REPORT
 
	cnt = 0
	call alterlist(delivery_summary->events, 100)
 
DETAIL
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(delivery_summary->events, cnt+9)
	endif
 
	delivery_summary->events[cnt]. street_address     = a.street_addr
 	delivery_summary->events[cnt]. city_name          = a.city
 	delivery_summary->events[cnt]. state_name         = a.state
 	delivery_summary->events[cnt]. zip_code           = a.zipcode
 	delivery_summary->events[cnt]. facility           = facility_name
	delivery_summary->events[cnt]. mom_fin            = $fin
	delivery_summary->events[cnt]. mom_mrn            = mrn
	delivery_summary->events[cnt]. mom_person_id      = e.person_id
	delivery_summary->events[cnt]. mom_encntr_id      = e.encntr_id
	delivery_summary->events[cnt]. mom_age            = age
	delivery_summary->events[cnt]. mom_dob            = patient_dob
	delivery_summary->events[cnt]. mom_name           = patient_name
	delivery_summary->events[cnt]. mom_gravida        = mom_gravi
	delivery_summary->events[cnt]. mom_admit_dt       = admit_date
	delivery_summary->events[cnt]. deli_doctor        = deli_doctor
	delivery_summary->events[cnt]. med_during_labor   = med_during_labor
	delivery_summary->events[cnt]. antibio_num_dose   = antibio_num_dose
	delivery_summary->events[cnt]. scrub_nurse        = scrub_nurse
	delivery_summary->events[cnt]. amntc_fluid_odor   = amntc_fluid_odor
	delivery_summary->events[cnt]. amntc_fluid_cultur = amntc_fluid_cultur
	delivery_summary->events[cnt]. stage1_labor       = stage1_labor
	delivery_summary->events[cnt]. episiotomy         = episiotomy
	delivery_summary->events[cnt]. rn_comnts          = rn_comnts
 	delivery_summary->events[cnt]. length_repture     = length_repture
	delivery_summary->events[cnt]. cord_sgmnt_dispo   = cord_sgmnt_dispo
	delivery_summary->events[cnt]. anesthesiologist   = anesthesiologist
	delivery_summary->events[cnt]. dt_norcotic_given  = dt_norcotic_given
	delivery_summary->events[cnt]. antibio_dose_last  = antibio_dose_last
	delivery_summary->events[cnt]. labor_nurse        = labor_nurse
	delivery_summary->events[cnt]. amntc_fluid_amt    = amntc_fluid_amt
	delivery_summary->events[cnt]. stage2_labor       = stage2_labor
	delivery_summary->events[cnt]. episiotomy_loc     = episiotomy_loc
	delivery_summary->events[cnt]. provider_comnts    = provider_comnts
	delivery_summary->events[cnt]. plcnta_deli_time   = plcnta_deli_time
	delivery_summary->events[cnt]. suction            = suction
	delivery_summary->events[cnt]. anesthetist        = anesthetist
	delivery_summary->events[cnt]. onset_labor        = onset_labor
	delivery_summary->events[cnt]. name_antibio       = name_antibio
	delivery_summary->events[cnt]. other_personnel    = other_personnel
	delivery_summary->events[cnt]. cervic_rip_agent   = cervic_rip_agent
	delivery_summary->events[cnt]. stage3_labor       = stage3_labor
	delivery_summary->events[cnt]. laceration_repair  = laceration_repair
	delivery_summary->events[cnt]. presentation       = presentation
	delivery_summary->events[cnt]. plcnta_deli_mthod  = plcnta_deli_mthod
	delivery_summary->events[cnt]. cord_ph            = cord_ph
	delivery_summary->events[cnt]. suction_amount     = suction_amount
	delivery_summary->events[cnt]. pre_deli_cnt       = pre_deli_count
	delivery_summary->events[cnt]. post_deli_cnt      = post_deli_count
	delivery_summary->events[cnt]. cnt_correct        = count_correct
	delivery_summary->events[cnt]. nucal_cord_tenson  = nucal_tension
	delivery_summary->events[cnt]. deli_anesthesia    = deli_anesthesia
	delivery_summary->events[cnt]. complete_dilation  = complete_dilation
	delivery_summary->events[cnt]. steroids_given     = steroids_given
	delivery_summary->events[cnt]. scrub_personnel    = scrub_personnel
	delivery_summary->events[cnt]. other_rip_agent    = other_rip_agent
	delivery_summary->events[cnt]. total_labor_time   = total_labor_time
	delivery_summary->events[cnt]. other_laceration   = other_laceration
	delivery_summary->events[cnt]. length             = length
	delivery_summary->events[cnt]. plcnta_status      = plcnta_status
	delivery_summary->events[cnt]. cord_ph_obtained   = cord_ph_obtained
	delivery_summary->events[cnt]. color_suctioned    = color_suctioned
	delivery_summary->events[cnt]. labor_anes         = labor_anes
	delivery_summary->events[cnt]. rom_method         = rom_method
	delivery_summary->events[cnt]. resn_strid_not     = resn_strid_not
	delivery_summary->events[cnt]. no_babies_womp     = no_babies_womp
	delivery_summary->events[cnt]. placenta_cultred   = placenta_cultred
	delivery_summary->events[cnt]. meds_delivery      = meds_delivery
	delivery_summary->events[cnt]. repair_note        = repair_note
	delivery_summary->events[cnt]. plcnta_disposn     = plcnta_disposn
	delivery_summary->events[cnt]. cord_bld_taken     = cord_bld_taken
	delivery_summary->events[cnt]. anes_medication    = anes_medication
	delivery_summary->events[cnt]. oxytocin           = oxytocin
	delivery_summary->events[cnt]. resn_not_other     = resn_not_other
	if(vbac = "VBAC")
		delivery_summary->events[cnt]. vbac_attempted = "Yes"
	else
		delivery_summary->events[cnt]. vbac_attempted = "No"
	endif
	delivery_summary->events[cnt]. ebl                = ebl
	delivery_summary->events[cnt]. laceration_type    = laceration_type
	delivery_summary->events[cnt]. deli_comp          = deli_comp
	delivery_summary->events[cnt]. neonate_outcome    = neonate_outcome
	delivery_summary->events[cnt]. bank_donate        = bank_donate
	delivery_summary->events[cnt]. dt_anes_admins     = dt_anes_admins
	delivery_summary->events[cnt]. group_beta_strep   = group_beta_strep
	delivery_summary->events[cnt]. baby_nurse         = baby_nurse
	delivery_summary->events[cnt]. amntc_fluid_color  = amntc_fluid_color
	delivery_summary->events[cnt]. reasn_induction    = reasn_induction
	delivery_summary->events[cnt]. laceration_loc     = laceration_loc
	delivery_summary->events[cnt]. other_deli_comp    = other_deli_comp
	delivery_summary->events[cnt]. rom_dt             = rom_dt
	delivery_summary->events[cnt]. nuchal_cord        = nuchal_cord
	delivery_summary->events[cnt]. cord_sgmnt_colecd  = cord_sgmnt_colecd
	delivery_summary->events[cnt]. delivery_type      = delivery_type
	delivery_summary->events[cnt]. vbac               = vbac
	delivery_summary->events[cnt]. ga_at_deli         = ga_at_deli
	delivery_summary->events[cnt]. para_fullterm           = para_fullterm
	delivery_summary->events[cnt]. para_premature          = para_premature
	delivery_summary->events[cnt]. para                    = para
	delivery_summary->events[cnt]. para_spon_abortion      = para_spon_abortion
	delivery_summary->events[cnt]. para_induced_abortion   = para_induced_abortion
	delivery_summary->events[cnt]. para_living_children    = para_living_children
 
FOOT REPORT
 	call alterlist(delivery_summary->events, cnt)
 
WITH nocounter
 
 
;Get Baby events
SELECT DISTINCT INTO "NL:"
 
	  ea.alias
	, ce.encntr_id
	, baby_encounter_id       = ce.encntr_id
 	, latest_update           = format(max(ce.updt_dt_tm), "MM/DD/YYYY  HH:MM;;D")
 	, void_output             = max(evaluate(ce.event_cd, void_output_var,        ce.result_val, 0, ""))
 	, stool_output            = max(evaluate(ce.event_cd, stool_output_var,       ce.result_val, 0, ""))
 	, apgar_1min              = max(evaluate(ce.event_cd, apgar_1min_var,         ce.result_val, 0, ""))
 	, apgar_5min      	      = max(evaluate(ce.event_cd, apgar_5min_var,         ce.result_val, 0, ""))
 	, apgar_10min      	      = max(evaluate(ce.event_cd, apgar_10min_var,        ce.result_val, 0, ""))
	, apgar_15min  	          = max(evaluate(ce.event_cd, apgar_15min_var,        ce.result_val, 0, ""))
	, apgar_20min             = max(evaluate(ce.event_cd, apgar_20min_var,        ce.result_val, 0, ""))
	, infant_comp   	      = max(evaluate(ce.event_cd, infant_comp_var,        ce.result_val, 0, ""))
	, resprn_type 		      = max(evaluate(ce.event_cd, resprn_type_var,        ce.result_val, 0, ""))
	, neonatlogy_called 	  = max(evaluate(ce.event_cd, neonatlogy_called_var,  ce.result_val, 0, ""))
	, infant_care_by          = max(evaluate(ce.event_cd, infant_care_by_var,     initcap(ce.result_val), 0, ""))
	, neonate_death           = max(evaluate(ce.event_cd, neonate_death_var,      ce.result_val, 0, ""))
	, neonate_trans_to        = max(evaluate(ce.event_cd, neonate_trans_to_var,   ce.result_val, 0, ""))
	, skn_to_skin             = max(evaluate(ce.event_cd, skn_to_skin_var,        ce.result_val, 0, ""))
	, skn_to_skn_time         = max(evaluate(ce.event_cd, skn_to_skn_time_var,    ce.result_val, 0, ""))
	, vitamin_K_dt            = max(evaluate(ce.event_cd, vitamin_K_dt_var,       ce.result_val, 0, ""))
	, antibio_eye             = max(evaluate(ce.event_cd, antibio_eye_var,        ce.result_val, 0, ""))
	, id_band                 = max(evaluate(ce.event_cd, id_band_var,            ce.result_val, 0, ""))
	, id_band_read_by         = max(evaluate(ce.event_cd, id_band_read_by_var,    initcap(ce.result_val), 0, ""))
	, sensor_aplied           = max(evaluate(ce.event_cd, sensor_aplied_var,      ce.result_val, 0, ""))
	, sensor_nbr              = max(evaluate(ce.event_cd, sensor_nbr_var,         ce.result_val, 0, ""))
 	, delivery_dt             = max(evaluate(ce.event_cd, delivery_dt_var,        ce.result_val, 0, ""))
 	, method_deli             = max(evaluate(ce.event_cd, method_deli_var,        ce.result_val, 0, ""))
 	, born_en_route           = max(evaluate(ce.event_cd, born_en_route_var,      ce.result_val, 0, ""))
 	, forcep_type             = max(evaluate(ce.event_cd, forcep_type_var,        ce.result_val, 0, ""))
 	, forcep_activity         = max(evaluate(ce.event_cd, forcep_activity_var,    ce.result_val, 0, ""))
 	, vacum_type              = max(evaluate(ce.event_cd, vacum_type_var,         ce.result_val, 0, ""))
	, vacum_activity          = max(evaluate(ce.event_cd, vacum_activity_var,     ce.result_val, 0, ""))
	, shoulder_dystocia       = max(evaluate(ce.event_cd, shoulder_dystocia_var,  ce.result_val, 0, ""))
	, neonate_condition       = max(evaluate(ce.event_cd, neonate_condition_var,  ce.result_val, 0, ""))
	, gender                  = max(evaluate(ce.event_cd, gender_var,             ce.result_val, 0, ""))
	, birth_weight            = max(evaluate(ce.event_cd, birth_weight_var,       ce.result_val, 0, ""))
	, cord_vessels            = max(evaluate(ce.event_cd, cord_vessels_var,       ce.result_val, 0, ""))
 
from
        encntr_alias ea
      , encounter e
     ; , encounter e1
     ; , person_person_reltn pp
      , clinical_event ce
 
 
plan ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
 
/*join pp where pp.person_id = e.person_id
	and pp.person_reltn_cd =  relation_var
	and pp.active_ind = 1
 
join e1 where e1.person_id = pp.related_person_id
	and e1.encntr_type_cd = encounter_type_var
	and e1.active_ind = 1 */
 
join ce where ce.encntr_id = e.encntr_id ;e1.encntr_id
	and ce.event_cd in
	(
	void_output_var, stool_output_var, apgar_1min_var, apgar_5min_var, apgar_10min_var, ;id_band_loc_var
	apgar_15min_var, apgar_20min_var, infant_comp_var, resprn_type_var,
	neonatlogy_called_var, infant_care_by_var, neonate_death_var, neonate_trans_to_var, skn_to_skin_var, skn_to_skn_time_var, vitamin_K_dt_var,
	antibio_eye_var, id_band_var, id_band_read_by_var, sensor_aplied_var, sensor_nbr_var,
 	delivery_dt_var, method_deli_var, born_en_route_var, forcep_type_var, forcep_activity_var, vacum_type_var,
	vacum_activity_var, shoulder_dystocia_var, neonate_condition_var, gender_var, birth_weight_var, cord_vessels_var
	)
 
group by ea.alias, ce.encntr_id
 
 
 
 
;Populate record structure with baby events
 
HEAD ea.alias
	num = 0
	idx = 0
 
	idx = locateval(num, 1, size(delivery_summary->events, 5), ea.alias, delivery_summary->events[num].mom_fin)
 
	if(idx > 0)
		delivery_summary->events[idx].baby_encounter_id     = baby_encounter_id
	 	delivery_summary->events[idx].void_output           = void_output
	 	delivery_summary->events[idx].stool_output          = stool_output
	 	delivery_summary->events[idx].apgar_1min            = apgar_1min
		delivery_summary->events[idx].apgar_5min            = apgar_5min
		delivery_summary->events[idx].apgar_10min           = apgar_10min
		delivery_summary->events[idx].apgar_15min           = apgar_15min
		delivery_summary->events[idx].apgar_20min           = apgar_20min
		delivery_summary->events[idx].neonatlogy_called     = neonatlogy_called
		delivery_summary->events[idx].antibio_eye           = antibio_eye
		delivery_summary->events[idx].delivery_dt           = delivery_dt
		delivery_summary->events[idx].vacum_activity        = vacum_activity
		delivery_summary->events[idx].infant_care_by        = infant_care_by
		delivery_summary->events[idx].id_band               = id_band
		delivery_summary->events[idx].method_deli           = method_deli
		delivery_summary->events[idx].shoulder_dystocia     = shoulder_dystocia
		delivery_summary->events[idx].infant_comp           = infant_comp
		delivery_summary->events[idx].neonate_death         = neonate_death
		delivery_summary->events[idx].born_en_route         = born_en_route
		delivery_summary->events[idx].neonate_trans_to      = neonate_trans_to
		delivery_summary->events[idx].id_band_read_by       = id_band_read_by
		delivery_summary->events[idx].forcep_type           = forcep_type
		delivery_summary->events[idx].skn_to_skin           = skn_to_skin
		delivery_summary->events[idx].sensor_aplied         = sensor_aplied
		delivery_summary->events[idx].forcep_activity       = forcep_activity
		delivery_summary->events[idx].neonate_condition     = neonate_condition
		delivery_summary->events[idx].skn_to_skn_time       = skn_to_skn_time
		delivery_summary->events[idx].sensor_nbr            = sensor_nbr
		delivery_summary->events[idx].vacum_type            = vacum_type
		delivery_summary->events[idx].gender                = gender
		delivery_summary->events[idx].resprn_type           = resprn_type
		delivery_summary->events[idx].vitamin_K_dt          = vitamin_K_dt
		delivery_summary->events[idx].birth_weight          = birth_weight
		delivery_summary->events[idx]. cord_vessels         = cord_vessels
	endif
 
 
WITH nocounter
 
 
 
;CALL ECHOJSON(delivery_summary, "rec.out", 0)
 
;call echorecord(delivery_summary)
 
 
 
end
go
 
 
 
 
 
/*
 
 ;Code Values used  - Mother event code would have :
 
 loc_facility_cd codeset = 220
 
   1077.00	FIN NBR
   1079.00	MRN
   2554143671.00	STAR MRN - MMC  (Alias_pool_cd)
   2553023875.00 - STAR (contributor_system_cd)
   670847.00 CHILD - relation type code
   2555267433.00	Newborn  - encounter type
 
 
Maternal/Labor/Delivery information
 
    710919.00	Gravida
 
 
   ;21102625.00	Maternal Delivery Physician
   17022066		Delivery Physician:
   16865504.00	Anesthesiologist Attending Delivery:
   ;21102653.00	Maternal Anesthetist
   17022074.00	Anesthetist:
   2554390525.00	Delivery Anesthesia:
 
   17022168.00	Neonate Outcome:
   21102786.00	Maternal Anesthesiologist Attending Del
   2554390547.00	Anesthesia Medication:
   D/T Administered - not found
   2554390667.00	Medications During Labor:
 
Baby - G/P/T/Pt/SAB/IAB/L
   2554390599.00	Date/Time Narcotic Last Administered:
   17022036.00	Labor Onset, Date, Time:   4159944.00	Complete Cervical Dilation Date/Time
   ROM Method -
   21102562.00	Maternal Induction Methods ;Oxytocin
   ;35289707.00	Maternal Transcribed GBS
   273387529	Group B Strep, Transcribed
 
 
   38267857.00	Intrapartum Antibiotics Given: - Antibiotic # of Doses
   2554390223.00	Intrapartum Antibiotics Given Date/Time: - Antibiotic last Dose
   2554390279.00	Name of Antibiotic:
 
   ;16766574.00	Maternal Antepartum Steroids
   273387673	Antepartum Steroids, Transcribed
 
 
   43007837.00	Reason Antenatal Steroids Not Given
   57532413.00	Reg PC Reason for No Ant Steroids Other
 
   2553185805.00	Nursery/Baby Nurse:
   2558942689.00	Scrub Nurse
   ;4169869.00	      Delivery RN #1
   17022076		Delivery RN #1:
   16865560.00	Other Delivery Clinicians:
   16865553.00	Scrub Tech:
   16866018.00	Multiple Gestation Description:
   VBAC attempted - get from inline table
   20597736.00	Amniotic Fluid Color/Description:
   2552734033.00	Amniotic Fluid Abnormal Odor:
   20597729.00	Amniotic Fluid Amount:
   2559549197.00	Agent Cervical Ripening Type
 
   Placenta Cultured -
   269502805.00	Delivery EBL
   269502887.00	Indication for Induction Documented
   21102548.00	Maternal Length of Labor 1st Stage Hrs
   21102576.00	Maternal Length of Labor, 2nd Stage Hrs
   21180430.00	Maternal Length of Labor, 3rd Stage
   21102583.00	Maternal Total Length of Labor Hr
   832681.00	      Maternal Medications During L&D
 
 VAGINAL DELIVERY
  16865341.00	Delivery Type: -- To identify vaginal Delivery
  273388571.00	Laceration Degree Transcribed
  273388583.00	Laceration Location Transcribed
  273388607.00	Episiotomy Transcribed
  273388619.00	Episiotomy Location Transcribed
  273388595.00	Laceration Repair Transcribed
  21156483.00	Laceration Other Location
  Repair Note -
 
MATERNAL COMPLICATION
  20597757.00	Maternal Delivery Complications:
  Other Complications -
 
DELIVERY COMMENTS
  47711009.00	Delivery Comments
  22961509.00	RN Comments
 
Baby A
  21102688.00	Date, Time of Birth
Delivery Information
  21102674.00	Delivery Type, Birth
  Born en Route -
  VBAC -- baby???????? -
  21102702.00	Delivery Forceps Type
  21102807.00	Delivery Forceps Activity
  21102814.00	Delivery Vacuum Type
  21102821.00	Delivery Vacuum Activity
  27931941.00	Nursing Shoulder Dystocia Interventions
  273388777.00	D-EGA at Delivery:
 
  Condition -
  4169756.00	Gender
  712070.00	      Birth Weight
 
DELIVERY SUMMARY
  Presentation -
  Length -
  Cephalic Position -
  Breech Position -
  Vertex Position -
  17022082.00	ROM Date, Time:
  16865369.00	ROM to Delivery Hours Calc:
  17022096.00	Placenta Delivery Date, Time:
  20598043.00	Placenta Delivery Method:
  2559549233.00	Placenta Status
  2554391107.00	Placenta Dispostion:
  4169621.00	Umbilical Cord Description
  16865405.00	Nuchal Cord Times:
  51256981.00	Cord Blood Gas Results
  273386393.00	Cord Blood pH Drawn:
  ;4169630.00	Cord Blood Sent to Lab
  17022104		Cord Blood Sent to Lab:
  16865412.00	Nuchal Cord Tension:
 
 2553185785.00	Anesthetist/ CRNA:
 2554390667.00	Medications During Labor:
 2554390567.00	Anesthesia Medication, Administered:
 20597583.00	Membrane Status:
 2798399.00	oxytocin
 273387685.00	Intrapartum Antibiotics, Transcribed
 2559386209.00   Previous Cesarean Delivery ;VBAC
 
 
20597750.00	Amniotic Fluid Cultures Sent:
21182594.00	Pre-Delivery Counts Performed
21182598.00	Post-Delivery Counts Performed
16865483.00	Counts Correct
 
  ;21102768.00	Cord Blood Banking
  16865434		Cord Blood Banking:
  ;2553185745.00	Cord Segment Collected
  2554391139	Cord Segment Collected:
  ;2553185765.00	Cord Segment Disposition
  2554391159	Cord Segment Disposition:
  17022146.00	Suction:
  23939853.00	Sputum Color:
  23939851.00	Sputum Amount:
 
  21102903.00	Newborn Output  ----void
  21102903.00	Newborn Output  ----stool
 
APGARS
  832678.00	Apgar 1 Minute, by History
  832675.00	Apgar 5 Minute, by History
  3338829.00	Apgar 10 Minute, by History
  16766588.00	Apgar 15 Minute, by History
  3338832.00	Apgar 20 Minute, by History
Assessment
  16728628.00	Neonate Complications
  other Complication -
  Physical Findings -
  Other Physical Findings -
  21102945.00	Birth Respirations
  2558942667.00	Neonatology Called
  21102910.00	Newborn Examination By
  20597994.00	OB Loss Date, Time of Neonatal Death:
  21103070.00	Neonate Transferred To
  273386839.00	Skin to Skin Contact Initiated
  273386851.00	Amount of Time for Skin to Skin Contact
Medications
  44629883.00	Vitamin K Dose
  2797710.00	erythromycin
  3320106.00	ID Band Number
  ID Band Location - ; removed as per TJ
  21102966.00	ID Band Verified By
  16766560.00	Security Tag Applied
  21102973.00	Security Tag Number
  Sensor Location - not found
 
*/
 
 

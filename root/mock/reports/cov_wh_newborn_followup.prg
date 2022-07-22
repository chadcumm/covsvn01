 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:		        Geetha Saravanan
	Date Written:		Oct'2017
	Solution:			Womens Health
	Source file name:	COV_WH_Newborn_Followup.prg
	Object name:		COV_WH_Newborn_Followup
	Layout Builder:		COV_WH_Newborn_Followup_LB
	Request#:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:
 
*******************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
*******************************************************************************************
 
Mod Date	    Developer			    Comment
--- -------	    --------------------	---------------------------------------------------
001 11-2018	    Dan Herren	            CR2819
002 02-2019     Dan Herren              CR4242 Add hep B vaccine results
003 03-2019     Dan Herren				Get Attending Physician, most recent event results,
										replacing 'updt_dt_tm' with 'end_event_dt_tm'.
004 06-2019		Dan Herren				CR5157
005 08-2019     Dan Herren				CR4872
006 08-2019		Dan Herren				#IN909217 - Beth Absher Email
007 01-2020		Dan Herren				CR6837 - HSV additions
 
*******************************************************************************************/
 
drop program cov_wh_newborn_followup:DBA go
create program cov_wh_newborn_followup:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = ""
 
with OUTDEV, FIN
 
 
;Create Recore Structure
record Newborn_followUp(
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
		2 baby_order_id    = f8
		2 infant_name      = vc
		2 birth_date       = dq8
		2 deli_date        = vc
		2 infant_gender    = vc
		2 method_delivery  = vc
		2 provider_hosp    = vc
		2 attend_phys      = vc
		2 other_provider   = vc
		2 resuscitation    = vc
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
		2 vmin_K_result	   = vc ;002
		2 vmin_K_dt        = vc
		2 hep_B_result     = vc ;002
		2 hep_B_dt         = vc
		2 abx_eye_result   = vc ;002
		2 abx_eye_dt       = vc
		2 hbig_result      = vc ;002
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
		2 hsv_serology     = vc ;007
		2 hsv_type1        = vc ;007
		2 hsv_type2        = vc ;007
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
 
 
free record med
record med (
	1	rec_cnt=i4
	1	qual[*]
		2 encntrid 	   	   = f8
		2 vmin_K_dt        = vc
		2 hep_B_dt         = vc
		2 abx_eye_dt       = vc
		2 hbig_dt          = vc
	)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
%i cust_script:cov_CommonLibrary.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare facility_code_var		= f8 with constant(get_FacilityCode($FIN)), protect ; write sub on test2
declare mrn_alias_pool_var   	= f8 with constant(get_AliasPoolCode(facility_code_var)), protect ; write sub on test2
declare mrn_var              	= f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              	= f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare cmrn_var             	= f8 with constant(uar_get_code_by("DISPLAY", 4,   "Community Medical Record Number")),protect
declare cmrn_alias_pool_var  	= f8 with constant(uar_get_code_by("DISPLAY", 263, "CMRN")),protect
declare relation_var         	= f8 with constant(uar_get_code_by("DISPLAY", 40,  "Child")),protect
declare relation_type_var1   	= f8 with constant(uar_get_code_by("DISPLAY", 351, "Default Guarantor")),protect
declare relation_type_var2   	= f8 with constant(uar_get_code_by("DISPLAY", 351, "Family Member")),protect
declare mom_enter_type_var   	= f8 with constant(uar_get_code_by("DISPLAY", 71,  "Inpatient")),protect
;
;=============================
; BABY - Newborn Information
;=============================
declare encounter_type_var   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NEWBORN")),protect
declare infant_gender_var    	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Gender")),protect
declare delivery_dt_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Date, Time of Birth")),protect
declare delivery_phys_var    	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Physician")),protect
declare other_provider_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Assistant Physician #1")),protect
declare delivery_method_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Type, Birth")),protect
declare attend_phys_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Attending Physician:")),protect
declare resuscitation_var    	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Resuscitation at Birth")),protect
declare comp_abnal_finds_var 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Complications")),protect
declare feed_pref_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Feeding Plans")),protect
declare feeding_type_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Feeding Type Newborn")),protect
declare admit_to_var         	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Transferred To")),protect
declare birth_weight_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Weight")),protect
declare birth_length_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Length")),protect
declare birth_head_var       	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Head Circumference")),protect
declare disch_feed_pref_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Discharge Feeding Type")),protect
declare apgar_1min_var       	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR1MINUTEBYHISTORY")),protect
declare apgar_5min_var       	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR5MINUTEBYHISTORY")),protect
declare apgar_10min_var      	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR10MINUTEBYHISTORY")),protect
declare apgar_15min_var      	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR15MINUTEBYHISTORY")),protect
declare apgar_20min_var      	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR20MINUTEBYHISTORY")),protect
;
;Routine Newborn Medications Given
declare vmin_K_var   		 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "phytonadione")),protect ;002
;declare vmin_K_dt_var        	= vc with constant("phytonadione"),protect ;Vitamin K1
declare hep_b_var    		 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "hepatitis B pediatric vaccine")),protect  ;002
;declare hep_B_dt_var         	= vc with constant("hepatitis B pediatric/adolescent vaccine"),protect
declare abx_eye_var  		 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "erythromycin ophthalmic")),protect ;002
;declare abx_eye_dt_var       	= vc with constant("erythromycin ophthalmic"),protect
declare hbig_var     		 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "hepatitis B immune globulin")),protect ;002
;declare hbig_dt_var          	= vc with constant("hepatitis B immune globulin"),protect
;
;Med Catalog ;002
declare vit_k_cd             	= f8 with constant(uar_get_code_by('DISPLAYKEY',200,'PHYTONADIONE')),protect
declare hepB_vacc_cd         	= f8 with constant(uar_get_code_by('DISPLAYKEY',200,'HEPATITISBPEDIATRICADOLESCENTVACCINE')),protect
declare hepb_igg_cd          	= f8 with constant(uar_get_code_by('DISPLAYKEY',200,'HEPATITISBIMMUNEGLOBULIN')),protect
declare abx_eye_cd           	= f8 with constant(uar_get_code_by('DISPLAYKEY',200,'ERYTHROMYCINOPHTHALMIC')),protect
declare encntr_id            	= f8 with noconstant(0.0),protect
declare person_id            	= f8 with noconstant(0.0),protect
;
;Routine Newborn Testing Completed
declare systolic_bp_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Systolic BP")),protect
declare diastolic_bp_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Diastolic BP")),protect
declare bp_location_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Blood Pressure Location")),protect
declare coombs_dat_var       	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord DAT")),protect  ;001 005
declare coombs_neo_var       	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonatal DAT")),protect  ;001 005
declare high_bili_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Bilirubin Total")),protect
declare bili_direct_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Bilirubin Direct")),protect
declare bili_indirect_var    	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Bilirubin Indirect")),protect
declare bili_tq_var			 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Transcutaneous Bilirubin Result")),protect
;
declare hear_scrn_dt_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Test Performed Date, Time")),protect
declare otostic_rslt_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Otoacoustic Emissions Result")),protect
declare audibrain_rslt_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Auditory Brainstem Response Result")),protect
declare metabo_scrn_dt_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Metabolic Screening Date, Time Drawn")),protect
declare newbrn_scrn_form_var 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Screening Form #")),protect
declare carseat_chalng_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Car Seat Challenge Result")),protect
declare blood_type_cord_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord ABORh")),protect  ;005
declare blood_type_neon_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonatal ABORh")),protect  ;005
;declare blood_type_var       	= f8 with constant(35289669)
;
declare dsch_bili_var        	= f8 with constant(null),protect
declare mthd_bili_serum_var  	= f8 with constant(null),protect
declare cchd_rslt_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn CCHD Result")),protect
declare refr_cardio_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Referred to Cardiology")),protect
;declare drug_scrn_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Toxicology Screen on Mother")),protect
;declare drug_scrn_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Drug Screen Results")),protect
declare drug_scrn_var        	= f8 with constant(null),protect
;
declare cord_stat_rslt_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord Tissue Drug Screen")),protect
;declare cord_blood_gas_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "O2 Sat Art Cord Bld")),protect
declare cord_blood_gas_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "pH Art Cord Bld")),protect ; Arterial
declare cord_venous_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "pH Ven Cord Bld")),protect ;Venous
declare cord_seg_var		 	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord Segment Disposition")), protect
;
;Newborn Procedures
declare phototherapy_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Phototherapy Activity")),protect
declare circumcision_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Circumcision")),protect
declare other_procedure_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Bedside Procedure Type")),protect
;
;Discharge Information
declare disch_dt_var         	= f8 ;with constant(uar_get_code_by("DISPLAY", 72, "Clinical Discharge Date and Time")),protect
declare follup_provider_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Follow-Up Physician")),protect
declare provider_phone_var   	= f8 with constant(null),protect
declare appointment_dt_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Physician Appt Date, Time")),protect
declare addnl_folup_dt_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Follow-Up Clinic Appt Date, Time")),protect
declare disch_weight_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Weight Measured")),protect
declare disch_head_cirm_var  	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Head Circumference")),protect
;
;===========
; MOTHER
;===========
;Maternal Information
declare mom_blood_type_var   	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Blood Type")),protect
declare hbsag_var            	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Hepatitis B")),protect
declare gbs_var              	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed GBS")),protect
declare gbs_abx_var          	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Antibiotic")),protect
declare doses_abx_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Intrapartum Antibiotics")),protect
;
;Antibiotic Type
declare intra_abx_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Intrapartum Antibiotics")),protect
declare toxi_scrn_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Toxicology Screen")),protect
declare alcohol_use_var      	= f8 with constant(null),protect
declare cocaine_use_var      	= f8 with constant(null),protect
declare mom_drug_scrn_var    	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Drug Screen Results")),protect
;Maternal Drug Screen Results	 2552811919.00
;
declare preg_risk_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Risk Factors in Utero Maternal")),protect
declare med_preg_var         	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Medications During Pregnancy")),protect
declare preg_risk_other_var  	= f8 with constant(null),protect
declare preg_risk_dtl_var    	= f8 with constant(null),protect
declare ega_var              	= f8 with constant(uar_get_code_by("DISPLAY", 72, "EGA at Birth")),protect
declare rubella_var          	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Rubella")),protect
declare rpr_var              	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed RPR/VDRL/Serology")),protect
declare hepatitis_c_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed Hepatitis C")),protect
declare hsv_var              	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HSV")),protect
declare hsv_serology_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Transcribed HSV (Serology)")),protect ;007
;declare hsv_type1_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HSV")),protect ;FOR PROD 
declare hsv_type1_var          	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HSV Type 1")),protect ;007
declare hsv_type2_var          	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HSV Type 2")),protect ;007
declare hiv_var              	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Transcribed HIV")),protect
declare tobacco_var          	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Tobacco use")),protect
declare drug_var             	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Newborn Drug Screen Results")),protect
declare marijuana_var        	= f8 with constant(null),protect
declare dcs_nitified_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Type of DCS Notification")),protect
;
;declare gonorhea_var         	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Gonorrhea, Transcribed")),protect
;declare chlamydia_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Chlamydia, Transcribed")),protect
declare gonorhea_var			= f8 with constant(2555366839.00),protect
declare chlamydia_var        	= f8 with constant(2555366899.00),protect
;
;Labor and Delivery Information
declare rom_dt_var           	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM Date, Time")),protect
declare rom_deli_tot_var     	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM to Delivery Total Tm")),protect
declare lngh_rom_var         	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal ROM to Delivery Hr Calc")),protect
declare deli_anes_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Anesthesia")),protect
declare med_labor_var        	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Medications During Labor")),protect
declare dt_norcotic_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time Narcotic Last Adminsitered")),protect
declare name_abx_var         	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Antibiotic")),protect
declare ld_complica_var      	= f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Complications")),protect
;
;Problem/DX Vocabulary
declare DISCH_DX_CD			 	= f8 with constant(uar_get_code_by("DISPLAYKEY",17,"DISCHARGE"))
declare FINAL_DX_CD 		 	= f8 with constant(uar_get_code_by("DISPLAYKEY",17,"FINAL"))
declare PRINCIPAL_DX_CD 	 	= f8 with constant(uar_get_code_by("DISPLAYKEY",17,"PRINCIPAL"))
declare VISITREASON_DX_CD 	 	= f8 with constant(uar_get_code_by("DISPLAYKEY",17,"REASONFORVISIT"))
declare ADMIT_DX_CD          	= f8 with constant(uar_get_code_by("DISPLAYKEY",17,"ADMITTING"))
declare WORKING_DX_CD		 	= f8 with constant(uar_get_code_by("DISPLAYKEY",17,"WORKING"))
;
declare ICD10CM_CD			 	= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"))
declare ICD10PCS_CD			 	= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!4101496118"))
declare ICD10_CD			 	= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!56781"))
;
declare initcap() 			 	= c100
declare	idx					 	= i4
declare num					 	= i4 with noconstant(0)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;GET BABY INFO
select distinct into "NL:"
	 e.encntr_id
	,ord.order_id
    ,e.loc_facility_cd
 	,street           = max(a.street_addr)
 	,city             = max(a.city)
 	,state            = max(a.state)
 	,zipcode          = max(a.zipcode)
	,baby_mrn         = max(ea1.alias)
	,baby_cmrn        = max(pa.alias)
 	,facility_name    = uar_get_code_description(e.loc_facility_cd)
	,infant_name      = initcap(max(pe.name_full_formatted));baby
	,baby_regdt       = max(e.reg_dt_tm )
	,birth_date       = max(pe.birth_dt_tm)
	,deli_dt  		  = max(evaluate(i2.event_cd, delivery_dt_var,   	i2.result_val, 0, ""))
	,infant_gender    = max(evaluate(i2.event_cd, infant_gender_var,   	i2.result_val, 0, ""))
	,method_delivery  = max(evaluate(i2.event_cd, delivery_method_var, 	i2.result_val, 0, ""))
 	,provider_hosp    = initcap(max(evaluate(i2.event_cd, delivery_phys_var, i2.result_val, 0, "")))
	,attend_phys      = initcap(max(i.name_full_formatted))
 	,other_provider   = initcap(max(evaluate(i2.event_cd, other_provider_var, i2.result_val, 0, "")))
	,resuscitation    = max(evaluate(i2.event_cd, resuscitation_var,   	i2.result_val, 0, ""))
	,comp_abnal_finds = max(evaluate(i2.event_cd, comp_abnal_finds_var,	i2.result_val, 0, ""))
	,feed_pref        = max(evaluate(i2.event_cd, feed_pref_var,       	i2.result_val, 0, ""))
    ,feeding_type     = max(evaluate(i2.event_cd, feeding_type_var,    	i2.result_val, 0, ""))
    ,admit_to         = max(evaluate(i2.event_cd, admit_to_var,        	i2.result_val, 0, ""))
 	,birth_weight     = max(evaluate(i2.event_cd, birth_weight_var,    	i2.result_val, 0, ""))
 	,birth_length     = max(evaluate(i2.event_cd, birth_length_var,    	i2.result_val, 0, ""))
	,birth_head       = max(evaluate(i2.event_cd, birth_head_var,      	i2.result_val, 0, ""))
	,apgar_1min       = max(evaluate(i2.event_cd, apgar_1min_var,      	i2.result_val, 0, ""))
	,apgar_5min       = max(evaluate(i2.event_cd, apgar_5min_var,      	i2.result_val, 0, ""))
	,apgar_10min      = max(evaluate(i2.event_cd, apgar_10min_var,     	i2.result_val, 0, ""))
	,apgar_15min      = max(evaluate(i2.event_cd, apgar_15min_var,     	i2.result_val, 0, ""))
	,apgar_20min      = max(evaluate(i2.event_cd, apgar_20min_var,     	i2.result_val, 0, ""))
	,disch_feed_pref  = max(evaluate(i2.event_cd, disch_feed_pref_var, 	i2.result_val, 0, ""))
	,systolic_bp      = max(evaluate(i2.event_cd, systolic_bp_var,     	i2.result_val, 0, ""))
	,diastolic_bp     = max(evaluate(i2.event_cd, diastolic_bp_var,   	i2.result_val, 0, ""))
	,bp_location      = max(evaluate(i2.event_cd, bp_location_var,     	i2.result_val, 0, ""))
	,coombs_dat       = max(evaluate(i2.event_cd, coombs_dat_var,		i2.result_val, 0, "")) ;001 005
	,coombs_neo       = max(evaluate(i2.event_cd, coombs_neo_var,		i2.result_val, 0, "")) ;001 005
	,high_bili        = max(evaluate(i2.event_cd, high_bili_var,       	i2.result_val, 0, ""))
	,bili_direct      = max(evaluate(i2.event_cd, bili_direct_var,     	i2.result_val, 0, ""))
	,bili_indirect    = max(evaluate(i2.event_cd, bili_indirect_var,   	i2.result_val, 0, ""))
	,bili_tq    	  = max(evaluate(i2.event_cd, bili_tq_var,   		i2.result_val, 0, ""))
	,hear_scrn_dt     = max(evaluate(i2.event_cd, hear_scrn_dt_var,    	i2.result_val, 0, ""))
	,otostic_rslt     = max(evaluate(i2.event_cd, otostic_rslt_var,    	i2.result_val, 0, ""))
	,audibrain_rslt   = max(evaluate(i2.event_cd, audibrain_rslt_var,  	i2.result_val, 0, ""))
	,metabo_scrn_dt   = max(evaluate(i2.event_cd, metabo_scrn_dt_var,  	i2.result_val, 0, ""))
	,newbrn_scrn_form = max(evaluate(i2.event_cd, newbrn_scrn_form_var,	i2.result_val, 0, ""))
	,carseat_chalng   = max(evaluate(i2.event_cd, carseat_chalng_var, 	i2.result_val, 0, ""))
 	,blood_type_cord  = max(evaluate(i2.event_cd, blood_type_cord_var,	i2.result_val, 0, "")) ;005
 	,blood_type_neon  = max(evaluate(i2.event_cd, blood_type_neon_var,	i2.result_val, 0, "")) ;005
 	,dsch_bili        = max(evaluate(i2.event_cd, dsch_bili_var,       	i2.result_val, 0, ""))
	,mthd_bili_serum  = max(evaluate(i2.event_cd, mthd_bili_serum_var, 	i2.result_val, 0, ""))
	,cchd_rslt        = max(evaluate(i2.event_cd, cchd_rslt_var,       	i2.result_val, 0, ""))
	,refr_cardio      = max(evaluate(i2.event_cd, refr_cardio_var,     	i2.result_val, 0, ""))
	,drug_scrn        = max(evaluate(i2.event_cd, drug_scrn_var,       	i2.result_val, 0, ""))
	,cord_stat_rslt   = max(evaluate(i2.event_cd, cord_stat_rslt_var,  	i2.result_val, 0, ""))
	,phototherapy     = max(evaluate(i2.event_cd, phototherapy_var,    	i2.result_val, 0, ""))
	,circumcision     = max(evaluate(i2.event_cd, circumcision_var,    	i2.result_val, 0, ""))
	,other_procedure  = max(evaluate(i2.event_cd, other_procedure_var, 	i2.result_val, 0, ""))
	,disch_dt         = format(max(e.disch_dt_tm), "MM/DD/YYYY;;D")
	,follup_provider  = max(evaluate(i2.event_cd, follup_provider_var, 	i2.result_val, 0, ""))
	,provider_phone   = max(evaluate(i2.event_cd, provider_phone_var, 	i2.result_val, 0, ""))
	,appointment_dt   = max(evaluate(i2.event_cd, appointment_dt_var, 	i2.result_val, 0, ""))
	,addnl_folup_dt   = max(evaluate(i2.event_cd, addnl_folup_dt_var, 	i2.result_val, 0, ""))
	,disch_weight     = max(evaluate(i2.event_cd, disch_weight_var, 	i2.result_val, 0, ""))
	,disch_head_cirm  = max(evaluate(i2.event_cd, disch_head_cirm_var, 	i2.result_val, 0, ""))
	,cord_blood_gas   = max(evaluate(i2.event_cd, cord_blood_gas_var, 	i2.result_val, 0, ""))
	,cord_seg		  = max(evaluate(i2.event_cd, cord_seg_var, 		i2.result_val, 0, ""))
  	,mom_fin          = ""
 	,mom_name         = initcap(max(pe1.name_full_formatted))
 	,mom_dob          = max(pe1.birth_dt_tm)
 	,mom_regdt        = max(e.reg_dt_tm)
	,mom_blood_type   = max(evaluate(i2.event_cd, mom_blood_type_var, 	i2.result_val, 0, ""))
	,hbsag            = max(evaluate(i2.event_cd, hbsag_var, 			i2.result_val, 0, ""))
	,gbs              = max(evaluate(i2.event_cd, gbs_var, 				i2.result_val, 0, ""))
	,gbs_abx          = max(evaluate(i2.event_cd, gbs_abx_var, 			i2.result_val, 0, ""))
	,doses_abx        = max(evaluate(i2.event_cd, doses_abx_var, 		i2.result_val, 0, ""))
	,intra_abx        = max(evaluate(i2.event_cd, intra_abx_var, 		i2.result_val, 0, ""))
	,toxi_scrn        = max(evaluate(i2.event_cd, toxi_scrn_var, 		i2.result_val, 0, ""))
	,alcohol_use      = max(evaluate(i2.event_cd, alcohol_use_var, 		i2.result_val, 0, ""))
	,cocaine_use      = max(evaluate(i2.event_cd, cocaine_use_var, 		i2.result_val, 0, ""))
	,mom_drug_scrn    = max(evaluate(i2.event_cd, mom_drug_scrn_var, 	i2.result_val, 0, ""))
	,preg_risk        = max(evaluate(i2.event_cd, preg_risk_var, 		i2.result_val, 0, ""))
	,med_preg         = max(evaluate(i2.event_cd, med_preg_var, 		i2.result_val, 0, ""))
	,preg_risk_other  = max(evaluate(i2.event_cd, preg_risk_other_var, 	i2.result_val, 0, ""))
	,preg_risk_dtl    = max(evaluate(i2.event_cd, preg_risk_dtl_var, 	i2.result_val, 0, ""))
	,ega              = max(evaluate(i2.event_cd, ega_var, 				i2.result_val, 0, ""))
	,rubella          = max(evaluate(i2.event_cd, rubella_var, 			i2.result_val, 0, ""))
	,rpr              = max(evaluate(i2.event_cd, rpr_var, 				i2.result_val, 0, ""))
	,hepatitis_c      = max(evaluate(i2.event_cd, hepatitis_c_var, 		i2.result_val, 0, ""))
	,hsv              = max(evaluate(i2.event_cd, hsv_var, 				i2.result_val, 0, ""))
	,hsv_serology	  = max(evaluate(i2.event_cd, hsv_serology_var,		i2.result_val, 0, "")) ;007
	,hsv_type1	      = max(evaluate(i2.event_cd, hsv_type1_var,		i2.result_val, 0, "")) ;007
	,hsv_type2        = max(evaluate(i2.event_cd, hsv_type2_var,		i2.result_val, 0, "")) ;007
	,hiv              = max(evaluate(i2.event_cd, hiv_var, 				i2.result_val, 0, ""))
	,gonorhea         = max(evaluate(i2.event_cd, gonorhea_var, 		i2.result_val, 0, ""))
	,chlamydia        = max(evaluate(i2.event_cd, chlamydia_var, 		i2.result_val, 0, ""))
	,tobacco          = max(evaluate(i2.event_cd, tobacco_var, 			i2.result_val, 0, ""))
	,drug             = max(evaluate(i2.event_cd, drug_var, 			i2.result_val, 0, ""))
	,marijuana        = max(evaluate(i2.event_cd, marijuana_var, 		i2.result_val, 0, ""))
	,dcs_nitified     = max(evaluate(i2.event_cd, dcs_nitified_var, 	i2.result_val, 0, ""))
	,rom_dt           = max(evaluate(i2.event_cd, rom_dt_var, 			i2.result_val, 0, ""))
	,rom_deli_tot     = max(evaluate(i2.event_cd, rom_deli_tot_var, 	i2.result_val, 0, ""))
	,lngh_rom         = max(evaluate(i2.event_cd, lngh_rom_var, 		i2.result_val, 0, ""))
	,deli_anes        = max(evaluate(i2.event_cd, deli_anes_var, 		i2.result_val, 0, ""))
	,med_labor        = max(evaluate(i2.event_cd, med_labor_var, 		i2.result_val, 0, ""))
	,dt_norcotic      = max(evaluate(i2.event_cd, dt_norcotic_var, 		i2.result_val, 0, ""))
	,name_abx         = max(evaluate(i2.event_cd, name_abx_var, 		i2.result_val, 0, ""))
	,ld_complica      = max(evaluate(i2.event_cd, ld_complica_var, 		i2.result_val, 0, ""))
	,cord_venous      = max(evaluate(i2.event_cd, cord_venous_var, 		i2.result_val, 0, ""))
	,vmin_K_result    = max(evaluate(i2.event_cd, vmin_K_var, 			i2.event_tag,  0, ""))  ;002
	,hep_B_result     = max(evaluate(i2.event_cd, hep_b_var, 			i2.event_tag,  0, ""))  ;002
	,abx_eye_result   = max(evaluate(i2.event_cd, abx_eye_var, 			i2.event_tag,  0, ""))  ;002
	,hbig_result      = max(evaluate(i2.event_cd, hbig_var, 			i2.event_tag,  0, ""))  ;002
; 	, vmin_K_dt        = max(evaluate(i3.hna_order_mnemonic, vmin_K_dt_var,  format(i3.valid_dose_dt_tm,
;"mm/dd/yyyy hh:mm;;d"))) ;002
; 	, hep_B_dt         = max(evaluate(i3.hna_order_mnemonic, hep_B_dt_var,   format(i3.valid_dose_dt_tm,
;"mm/dd/yyyy hh:mm;;d"))) ;002
;	, abx_eye_dt       = max(evaluate(i3.hna_order_mnemonic, abx_eye_dt_var, format(i3.valid_dose_dt_tm,
;"mm/dd/yyyy hh:mm;;d"))) ;002
;	, hbig_dt          = max(evaluate(i3.hna_order_mnemonic, hbig_dt_var,    format(i3.valid_dose_dt_tm,
;"mm/dd/yyyy hh:mm;;d"))) ;002
 
from
	 ENCOUNTER    	e
	,ENCNTR_ALIAS 	ea
	,ENCNTR_ALIAS 	ea1
	,ADDRESS 		a
	,PERSON   		pe
	,PERSON 		pe1
	,PERSON_ALIAS 	pa
	,ORDERS			ord
 
	, (;inline table to get attending physician
		(	select pr.name_full_formatted, ea.alias, e.encntr_id
			from encntr_alias ea, encounter e, encntr_prsnl_reltn epr, prsnl pr
			where ea.alias = $FIN
				and ea.encntr_alias_type_cd = fin_var
				and ea.active_ind = 1
				and e.encntr_id = ea.encntr_id
				and e.active_ind = 1
				and epr.encntr_id = e.encntr_id
				and epr.prsnl_person_id = pr.person_id
				and epr.encntr_prsnl_r_cd = 1119 ;Attending Physician
				and epr.end_effective_dt_tm > sysdate ;003
				and epr.active_ind = 1
				and pr.active_ind = 1
		 	with sqltype("VC50", "VC20", "f8")
		)i
	  )
 
   ,(
		(	select distinct ce.encntr_id, ce.event_cd, ce.result_val, ce.event_end_dt_tm, ce.updt_dt_tm, ce.result_status_cd,
				ce.event_tag, ordext2 = dense_rank() over (partition by ce.event_cd order by ce.event_end_dt_tm desc,
				ce.updt_dt_tm desc) ;003
			from encntr_alias ea, clinical_event ce, encounter e
 			where ea.alias = $FIN
				and ea.encntr_alias_type_cd = fin_var
				and ea.active_ind = 1
				and e.encntr_id = ea.encntr_id
				and e.active_ind = 1
				and ce.person_id = e.person_id
				and ce.encntr_id = e.encntr_id
				and ce.result_status_cd in(25,34,35,36)
				and ce.event_class_cd != 654645.00  ;Place Holder ;006
				and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)  ;004
				and ce.event_cd in (
					delivery_dt_var, delivery_phys_var, other_provider_var, delivery_method_var, attend_phys_var,
					resuscitation_var, infant_gender_var, bili_tq_var, comp_abnal_finds_var, feed_pref_var,
					feeding_type_var, admit_to_var, birth_weight_var, birth_length_var, birth_head_var, apgar_1min_var,
				  	apgar_5min_var, apgar_10min_var, apgar_15min_var, apgar_20min_var, disch_feed_pref_var, cord_venous_var,
				  	systolic_bp_var, diastolic_bp_var, bp_location_var, coombs_dat_var, coombs_neo_var, high_bili_var,
					cord_blood_gas_var, bili_direct_var, bili_indirect_var, hear_scrn_dt_var, otostic_rslt_var,
					audibrain_rslt_var, metabo_scrn_dt_var, newbrn_scrn_form_var, carseat_chalng_var,
					blood_type_cord_var, blood_type_neon_var, dsch_bili_var, mthd_bili_serum_var,  cchd_rslt_var,
				  	refr_cardio_var, drug_scrn_var, cord_stat_rslt_var, phototherapy_var, circumcision_var,
					other_procedure_var, disch_dt_var, follup_provider_var, provider_phone_var, appointment_dt_var,
					addnl_folup_dt_var, disch_weight_var, disch_head_cirm_var, mom_blood_type_var, hbsag_var, gbs_var,
					gbs_abx_var, doses_abx_var, intra_abx_var,toxi_scrn_var, alcohol_use_var, cocaine_use_var, cord_seg_var,
					mom_drug_scrn_var, preg_risk_var, med_preg_var, preg_risk_other_var, preg_risk_dtl_var,
	 			  	ega_var, rubella_var, rpr_var, hepatitis_c_var, hsv_var, hsv_serology_var, hsv_type1_var, hsv_type2_var,
	 			  	hiv_var, gonorhea_var, chlamydia_var, tobacco_var, drug_var, marijuana_var, dcs_nitified_var, rom_dt_var,
	 			  	rom_deli_tot_var, lngh_rom_var, deli_anes_var, med_labor_var, dt_norcotic_var, name_abx_var,
	 			  	ld_complica_var, vmin_K_var, hep_b_var, abx_eye_var, hbig_var
				  ) ;002 005
			order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.updt_dt_tm ;003
			with sqltype("f8", "f8", "vc", "dq8", "f8", "f8", "vc", "i4")
			)i2
		)
;	,(   ;002
; 		(	select distinct o.encntr_id, o.hna_order_mnemonic, o.valid_dose_dt_tm, o.status_dt_tm, o.order_id
;; 			,ordext3 = dense_rank() over (partition by o.hna_order_mnemonic, o.order_id order by o.valid_dose_dt_tm desc)
;; 			,ordext3 = dense_rank() over (partition by o.hna_order_mnemonic order by o.status_dt_tm )  ;djh
; 			from orders o, encntr_alias ea, encounter e ;, order_action ac
; 			where ea.alias = $FIN
;	 			and e.encntr_id = ea.encntr_id
;	 			and o.encntr_id = e.encntr_id
;;	 			and ac.order_id = o.order_id
;	 			and o.order_status_cd = 2543 ;completed
;;				and ac.action_sequence = (select max(action_sequence) from order_action where order_id = ac.order_id)
;	 			and o.last_action_sequence = (select max(last_action_sequence) from orders where order_id = o.order_id) ;djh
;	 			and o.active_ind = 1
;;	 		    and ac.action_type_cd = 2529 ;complete  ;djh
;	 			and o.hna_order_mnemonic in (hep_B_dt_var, abx_eye_dt_var, vmin_K_dt_var, hbig_dt_var)
; 			order by o.encntr_id, o.hna_order_mnemonic, o.last_action_sequence desc
; 			with sqltype("f8","vc", "dq8", "dq8", "f8");, "i4")
; 	 	)i3
; 	)
 
plan i2 where i2.ordext2 = 1
	and i2.result_status_cd in (25,34,35,36)
 
join i where i.encntr_id = outerjoin(i2.encntr_id)
 
;join i3 where i3.encntr_id = outerjoin(i2.encntr_id)  ;002
;  	and i3.ordext3 = outerjoin(1)
 
join ea where ea.alias = $FIN
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.alias_pool_cd = mrn_alias_pool_var
	and ea1.encntr_alias_type_cd = mrn_var
	and ea1.active_ind = 1
 
join a where outerjoin(e.organization_id) = a.parent_entity_id
	and a.active_ind = outerjoin(1)
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join pe1 where pe1.person_id =
	(select pp.related_person_id
		from person_person_reltn pp, encntr_alias ea, encounter e
		where ea.alias = $FIN
		and e.encntr_id = ea.encntr_id
		and pp.person_id = e.person_id
		and pp.person_reltn_cd = 156 ;Mother
		and pp.active_ind = 1)
	and pe1.active_ind = 1
 
join pa where outerjoin(e.person_id) = pa.person_id
	and pa.alias_pool_cd = outerjoin(cmrn_alias_pool_var)
	and pa.person_alias_type_cd = outerjoin(cmrn_var)
	and pa.active_ind = outerjoin(1)
 
join ord where ord.encntr_id = e.encntr_id
	and ord.person_id = pe.person_id
	and ord.active_ind = 1
 
group by e.encntr_id, e.loc_facility_cd, ord.order_id
 
order by e.encntr_id, e.loc_facility_cd
 
 
;Populate record structure with baby events
head report
 
	cnt = 0
	call alterlist(Newborn_followUp->events, 100)
 
detail
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(Newborn_followUp->events, cnt+9)
	endif
	Newborn_followUp->events[cnt].facility_name    = facility_name
	Newborn_followUp->events[cnt].street_addr      = street
	Newborn_followUp->events[cnt].city             = city
	Newborn_followUp->events[cnt].state            = state
	Newborn_followUp->events[cnt].zipcode          = zipcode
 	Newborn_followUp->events[cnt].baby_fin         = $FIN
 	Newborn_followUp->events[cnt].baby_encntr_id   = e.encntr_id
 	Newborn_followUp->events[cnt].baby_order_id    = ord.order_id
 	Newborn_followUp->events[cnt].baby_mrn         = baby_mrn
 	Newborn_followUp->events[cnt].baby_cmrn        = baby_cmrn
	Newborn_followUp->events[cnt].baby_regdt       = baby_regdt
	Newborn_followUp->events[cnt].infant_name      = infant_name
	Newborn_followUp->events[cnt].birth_date       = birth_date
	Newborn_followUp->events[cnt].deli_date        = deli_dt
	Newborn_followUp->events[cnt].infant_gender    = infant_gender
	Newborn_followUp->events[cnt].method_delivery  = method_delivery
	Newborn_followUp->events[cnt].provider_hosp    = provider_hosp
	Newborn_followUp->events[cnt].attend_phys      = attend_phys
	Newborn_followUp->events[cnt].other_provider   = other_provider
	Newborn_followUp->events[cnt].resuscitation    = resuscitation
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
 	Newborn_followUp->events[cnt].vmin_K_result    = vmin_K_result  ;002
	Newborn_followUp->events[cnt].hep_B_result     = hep_B_result   ;002
 	Newborn_followUp->events[cnt].abx_eye_result   = abx_eye_result ;002
	Newborn_followUp->events[cnt].hbig_result      = hbig_result    ;002
 	Newborn_followUp->events[cnt].systolic_bp      = systolic_bp
	Newborn_followUp->events[cnt].diastolic_bp     = diastolic_bp
	Newborn_followUp->events[cnt].bp_location      = bp_location
	Newborn_followUp->events[cnt].coombs	       = evaluate2(if(coombs_dat != null) coombs_dat
														else coombs_neo endif) ;001 005
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
	Newborn_followUp->events[cnt].blood_type	   = evaluate2(if(blood_type_cord != null) blood_type_cord
														else blood_type_neon endif) ;001 005
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
	Newborn_followUp->events[cnt].hsv_serology     = hsv_serology ;007
	Newborn_followUp->events[cnt].hsv_type1        = hsv_type1 ;007
	Newborn_followUp->events[cnt].hsv_type2        = hsv_type2 ;007
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
 
foot report
 	call alterlist(Newborn_followUp->events, cnt)
 
with nocounter
 
 
/**************************************************************
;GET MEDICATIONS INFORMATION    ;002
**************************************************************/
if (size(Newborn_followUp->events,5) > 0) ;prevents overflow array error when no main record.
 
	select into 'nl:'
	from  ENCNTR_ALIAS ea
		 ,ENCOUNTER    e
 
	plan ea where ea.alias = $FIN
		and ea.encntr_alias_type_cd = 1077.00
		and ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
	join e where e.encntr_id = ea.encntr_id
		and e.active_ind = 1
 
	detail
		encntr_id = ea.encntr_id
		person_id = e.person_id
 
	with nocounter
 
 
	select into 'nl:'
	from  ORDERS         o
		 ,CLINICAL_EVENT ce
		 ,CE_MED_RESULT  cmr
 
	plan o where person_id = o.person_id
		and o.catalog_cd IN (vit_k_cd, hepB_vacc_cd, hepb_igg_cd, abx_eye_cd)
		and o.encntr_id = encntr_id
		and o.order_status_cd = 2543  ;Completed
		and o.active_ind = 1
 
	join ce where ce.order_id = o.order_id
		and ce.result_status_cd in (25,34,35,36) ;Auth (Verified), Altered, Modified, Not Done
		and ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
	join cmr where outerjoin(ce.event_id) = cmr.event_id
 
	head report
		cnt = 0
 
	head o.encntr_id
		cnt = cnt + 1
 
		if (mod(cnt,10) = 1 or cnt = 10)
			stat = alterlist(med->qual, cnt  + 9)
		endif
 
		med->qual[cnt].encntrid = o.encntr_id
 
	detail
		case (o.catalog_cd)
			of (vit_k_cd):
				if (size(med->qual[cnt].vmin_K_dt) = 0)
					med->qual[cnt].vmin_K_dt = format(cmr.admin_start_dt_tm, "mm/dd/yyyy;;q")
					newborn_followup->events[1].vmin_K_dt = BUILD2(med->qual[cnt].vmin_K_dt,' ',
					newborn_followup->events[1].vmin_K_result)
				endif
 
			of (hepB_vacc_cd):
				if (size(med->qual[cnt].hep_B_dt) = 0)
					med->qual[cnt].hep_B_dt = format(cmr.admin_start_dt_tm, "mm/dd/yyyy;;q")
					newborn_followup->events[1].hep_B_dt = BUILD2(med->qual[cnt].hep_B_dt,' ',
					newborn_followup->events[1].hep_B_result)
	 			endif
			of (hepb_igg_cd):
				if (size(med->qual[cnt].hbig_dt) = 0)
					med->qual[cnt].hbig_dt = format(cmr.admin_start_dt_tm, "mm/dd/yyyy;;q")
					newborn_followup->events[1].hbig_dt = BUILD2(med->qual[cnt].hbig_dt,' ',
					newborn_followup->events[1].hbig_result)
	 			endif
			of (abx_eye_cd):
				if (size(med->qual[cnt].abx_eye_dt) = 0)
					med->qual[cnt].abx_eye_dt = format(cmr.admin_start_dt_tm, "mm/dd/yyyy;;q")
					newborn_followup->events[1].abx_eye_dt = BUILD2(med->qual[cnt].abx_eye_dt,' ',
					newborn_followup->events[1].abx_eye_result)
	 			endif
		endcase
 
		med->rec_cnt = cnt
 
	foot o.encntr_id
		stat = alterlist(med->qual, cnt)
 
	with nocounter
 
endif
 
;call echorecord(med)
;go to exitscript
 
 
/**************************************************************
;GET DISCHARGE DX INFORMATION
**************************************************************/
select distinct into "NL:"
	 dx.encntr_id
	,dx.diagnosis_id
	,testingdx	= replace(trim(n.source_string,3), char(44), "")
	,dxdisp  	= replace(trim(dx.diagnosis_display,3), char(44), "")
	,type 		= uar_get_code_display(dx.diag_type_cd)
	,source 	= uar_get_code_display(n.source_vocabulary_cd)
 
from
	 ENCOUNTER    e
	,ENCNTR_ALIAS ea
	,DIAGNOSIS    dx
	,NOMENCLATURE n
 
plan ea where ea.alias = $FIN
	and ea.encntr_alias_type_cd = fin_var ;1077
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and ea.active_ind = 1
	and e.encntr_id > 0.00
	and expand(num, 1, size(Newborn_followUp->events, 5), e.encntr_id, Newborn_followUp->events[num].baby_encntr_id)
 
join dx
	where dx.encntr_id = e.encntr_id
	and dx.active_ind = 1
	and dx.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and dx.diag_type_cd in (DISCH_DX_CD) ;88
 
join n
	where n.nomenclature_id =  dx.nomenclature_id
	and n.source_vocabulary_cd = ICD10CM_CD  ;19350056
 
order by
	 dx.encntr_id
	,dx.diagnosis_id
 
;load DX data
head report
	cnt = 0
	idx = 0
 
head dx.encntr_id
 	idx = locateval(cnt,1,size(Newborn_followUp->events,5), e.encntr_id, Newborn_followUp->events[cnt].baby_encntr_id)
 
 	dx_var = fillstring(400," ")
	dx_out = fillstring(400," ")
 
detail
	dx_out = dxdisp
	dx_var = build2(trim(dx_var),trim(dx_out),"; ")
 
foot dx.encntr_id
	Newborn_followUp->events[idx].disch_dx = replace(trim(dx_var),";"," ",2)
	Newborn_followUp->events[idx].disch_dx = replace(Newborn_followUp->events[idx].disch_dx,";","; ",0)
 
with nocounter, expand = 1
 
 
/**************************************************************
;GET DISCHARGE INFORMATION FROM DISCHARGE M-PAGE
**************************************************************/
select into "NL:"
     pe.encntr_id
    ,pe.person_id
    ,fol_provider = initcap(p.provider_name)
    ,addr = initcap(l.long_text)
; 	,phone = substring(textlen(trim(l.long_text))-13, 13, l.long_text)
    ,apt_dt = format(p.fol_within_dt_tm, "mm/dd/yyyy hh:mm;;d")
    ,p_address_type_disp = uar_get_code_display(p.address_type_cd)
	,p.add_long_text_id
	,p.cmt_long_text_id
	,p.days_or_weeks
	,p.followup_needed_ind
	,p.fol_within_days
	,p.fol_within_dt_tm
	,p.fol_within_range
	,p.last_utc_ts
	,p_location_disp = uar_get_code_display(p.location_cd)
	,p.organization_id
	,p.pat_ed_doc_followup_id
	,p.pat_ed_doc_id
	,p.provider_id
	,p.provider_name
	,p_quick_pick_disp = uar_get_code_display(p.quick_pick_cd)
	,p.recipient_long_text_id
	,p.rowid
	,p.txn_id_text
 
from
	 ENCOUNTER 				e
	,ENCNTR_ALIAS 			ea
    ,PAT_ED_DOC_FOLLOWUP 	p
    ,PAT_ED_DOCUMENT     	pe
    ,LONG_TEXT			 	l
    ,LONG_TEXT 				l2
 
plan ea where ea.alias = $FIN
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and ea.active_ind = 1
 
join pe where pe.person_id = e.person_id
	and pe.encntr_id = e.encntr_id
 
join p where pe.pat_ed_document_id = p.pat_ed_doc_id
	and p.fol_within_dt_tm is not null
;	and p.provider_id != 0.00
 
join l where p.add_long_text_id =  l.long_text_id
 
join l2 where p.cmt_long_text_id = l2.long_text_id
 
order by apt_dt desc
 
;load Discharge data
head report
	cnt = 0
	call alterlist(Newborn_followUp->events, 100)
 
detail
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(Newborn_followUp->events, cnt+9)
	endif
 
	Newborn_followUp->events[cnt].follup_provider = fol_provider
	Newborn_followUp->events[cnt].provider_phone  = replace(replace(trim(addr), char(94), char(32)), char(59), char(32))
	Newborn_followUp->events[cnt].appointment_dt  = apt_dt
 
foot report
 	call alterlist(Newborn_followUp->events, cnt)
 
with maxrec=1, nocounter ;, separator = " ", format, check
 
CALL ECHORECORD(Newborn_followUp)
 
;====================================================
; REPORT OUTPUT
;====================================================
select distinct into value ($OUTDEV)
	 facility_name		= Newborn_followUp->events[d.seq].facility_name
	,street				= Newborn_followUp->events[d.seq].street_addr
	,city				= Newborn_followUp->events[d.seq].city
	,state				= Newborn_followUp->events[d.seq].state
	,zipcode			= Newborn_followUp->events[d.seq].zipcode
 	,fin				= Newborn_followUp->events[d.seq].baby_fin
 	,encntr_id			= Newborn_followUp->events[d.seq].baby_encntr_id
; 	,order_id			= Newborn_followUp->events[d.seq].baby_order_id
 	,baby_mrn			= Newborn_followUp->events[d.seq].baby_mrn
 	,baby_cmrn			= Newborn_followUp->events[d.seq].baby_cmrn
	,baby_regdt			= Newborn_followUp->events[d.seq].baby_regdt
	,infant_name		= Newborn_followUp->events[d.seq].infant_name
	,birth_date			= Newborn_followUp->events[d.seq].birth_date
	,deli_dt			= Newborn_followUp->events[d.seq].deli_date
	,infant_gender		= Newborn_followUp->events[d.seq].infant_gender
	,method_delivery 	= Newborn_followUp->events[d.seq].method_delivery
	,provider_hosp		= Newborn_followUp->events[d.seq].provider_hosp
	,attend_phys		= Newborn_followUp->events[d.seq].attend_phys
	,other_provider		= Newborn_followUp->events[d.seq].other_provider
	,resuscitation		= Newborn_followUp->events[d.seq].resuscitation
	,comp_abnal_finds 	= Newborn_followUp->events[d.seq].comp_abnal_finds
	,feed_pref			= Newborn_followUp->events[d.seq].feed_pref
	,feeding_type		= Newborn_followUp->events[d.seq].feeding_type
	,admit_to			= Newborn_followUp->events[d.seq].admit_to
 	,birth_weight		= Newborn_followUp->events[d.seq].birth_weight
 	,birth_length		= Newborn_followUp->events[d.seq].birth_length
	,birth_head			= Newborn_followUp->events[d.seq].birth_head
	,apgar_1min			= Newborn_followUp->events[d.seq].apgar_1min
	,apgar_5min			= Newborn_followUp->events[d.seq].apgar_5min
	,apgar_10min		= Newborn_followUp->events[d.seq].apgar_10min
	,apgar_15min		= Newborn_followUp->events[d.seq].apgar_15min
	,apgar_20min		= Newborn_followUp->events[d.seq].apgar_20min
	,disch_feed_pref 	= Newborn_followUp->events[d.seq].disch_feed_pref
 	,vmin_K_result		= Newborn_followUp->events[d.seq].vmin_K_result
	,hep_B_result		= Newborn_followUp->events[d.seq].hep_B_result
 	,abx_eye_result		= Newborn_followUp->events[d.seq].abx_eye_result
	,hbig_result		= Newborn_followUp->events[d.seq].hbig_result
 	,systolic_bp		= Newborn_followUp->events[d.seq].systolic_bp
	,diastolic_bp		= Newborn_followUp->events[d.seq].diastolic_bp
	,bp_location		= Newborn_followUp->events[d.seq].bp_location
	,coombs				= Newborn_followUp->events[d.seq].coombs
	,high_bili			= Newborn_followUp->events[d.seq].high_bili
	,bili_direct		= Newborn_followUp->events[d.seq].bili_direct
	,bili_indirect		= Newborn_followUp->events[d.seq].bili_indirect
	,bili_tq			= Newborn_followUp->events[d.seq].bili_tq
	,hear_scrn_dt		= Newborn_followUp->events[d.seq].hear_scrn_dt
	,otostic_rslt		= Newborn_followUp->events[d.seq].otostic_rslt
	,audibrain_rslt		= Newborn_followUp->events[d.seq].audibrain_rslt
	,metabo_scrn_dt		= Newborn_followUp->events[d.seq].metabo_scrn_dt
	,newbrn_scrn_form 	= Newborn_followUp->events[d.seq].newbrn_scrn_form
	,carseat_chalng		= Newborn_followUp->events[d.seq].carseat_chalng
	,blood_type			= Newborn_followUp->events[d.seq].blood_type
	,dsch_bili			= Newborn_followUp->events[d.seq].dsch_bili
	,mthd_bili_serum 	= Newborn_followUp->events[d.seq].mthd_bili_serum
	,cchd_rslt			= Newborn_followUp->events[d.seq].cchd_rslt
	,refr_cardio		= Newborn_followUp->events[d.seq].refr_cardio
	,drug_scrn			= Newborn_followUp->events[d.seq].drug_scrn
	,cord_stat_rslt		= Newborn_followUp->events[d.seq].cord_stat_rslt
	,cord_seg			= Newborn_followUp->events[d.seq].cord_seg
	,phototherapy		= Newborn_followUp->events[d.seq].phototherapy
	,circumcision		= Newborn_followUp->events[d.seq].circumcision
	,other_procedure 	= Newborn_followUp->events[d.seq].other_procedure
	,disch_dt			= Newborn_followUp->events[d.seq].disch_dt
	,follup_provider 	= Newborn_followUp->events[d.seq].follup_provider
	,provider_phone		= Newborn_followUp->events[d.seq].provider_phone
	,appointment_dt		= Newborn_followUp->events[d.seq].appointment_dt
	,addnl_folup_dt		= Newborn_followUp->events[d.seq].addnl_folup_dt
	,disch_weight		= Newborn_followUp->events[d.seq].disch_weight
	,disch_head_cirm 	= Newborn_followUp->events[d.seq].disch_head_cirm
 	,cord_blood_gas		= Newborn_followUp->events[d.seq].cord_blood_gas
 	,cord_venous		= Newborn_followUp->events[d.seq].cord_venous
 	,mom_encntr_id		= Newborn_followUp->events[d.seq].mom_encntr_id
	,mom_fin			= Newborn_followUp->events[d.seq].mom_fin
	,mom_name			= Newborn_followUp->events[d.seq].mom_name
	,mom_dob			= Newborn_followUp->events[d.seq].mom_dob
	,mom_regdt			= Newborn_followUp->events[d.seq].mom_regdt
	,mom_blood_type		= Newborn_followUp->events[d.seq].mom_blood_type
	,hbsag				= Newborn_followUp->events[d.seq].hbsag
	,gbs				= Newborn_followUp->events[d.seq].gbs
	,gbs_abx			= Newborn_followUp->events[d.seq].gbs_abx
	,doses_abx			= Newborn_followUp->events[d.seq].doses_abx
	,intra_abx			= Newborn_followUp->events[d.seq].intra_abx
	,toxi_scrn			= Newborn_followUp->events[d.seq].toxi_scrn
	,alcohol_use		= Newborn_followUp->events[d.seq].alcohol_use
	,cocaine_use		= Newborn_followUp->events[d.seq].cocaine_use
	,mom_drug_scrn		= Newborn_followUp->events[d.seq].mom_drug_scrn
	,preg_risk			= Newborn_followUp->events[d.seq].preg_risk
	,med_preg			= Newborn_followUp->events[d.seq].med_preg
	,preg_risk_other 	= Newborn_followUp->events[d.seq].preg_risk_other
	,preg_risk_dtl		= Newborn_followUp->events[d.seq].preg_risk_dtl
	,ega				= Newborn_followUp->events[d.seq].ega
	,rubella			= Newborn_followUp->events[d.seq].rubella
	,rpr				= Newborn_followUp->events[d.seq].rpr
	,hepatitis_c		= Newborn_followUp->events[d.seq].hepatitis_c
	,hsv				= Newborn_followUp->events[d.seq].hsv
	,hsv_serology		= Newborn_followUp->events[d.seq].hsv_serology
	,hsv_type1			= Newborn_followUp->events[d.seq].hsv_type1
	,hsv_type2			= Newborn_followUp->events[d.seq].hsv_type2
	,hiv				= Newborn_followUp->events[d.seq].hiv
	,gonorhea			= Newborn_followUp->events[d.seq].gonorhea
	,chlamydia			= Newborn_followUp->events[d.seq].chlamydia
	,tobacco			= Newborn_followUp->events[d.seq].tobacco
	,drug				= Newborn_followUp->events[d.seq].drug
	,marijuana			= Newborn_followUp->events[d.seq].marijuana
	,dcs_nitified		= Newborn_followUp->events[d.seq].dcs_nitified
	,rom_dt				= Newborn_followUp->events[d.seq].rom_dt
	,rom_deli_tot		= Newborn_followUp->events[d.seq].rom_deli_tot
	,lngh_rom			= Newborn_followUp->events[d.seq].lngh_rom
	,deli_anes			= Newborn_followUp->events[d.seq].deli_anes
	,med_labor			= Newborn_followUp->events[d.seq].med_labor
	,dt_norcotic		= Newborn_followUp->events[d.seq].dt_norcotic
	,name_abx			= Newborn_followUp->events[d.seq].name_abx
	,ld_complica		= Newborn_followUp->events[d.seq].ld_complica
	,vmin_K_dt			= Newborn_followUp->events[d.seq].vmin_K_dt
	,vmin_K_result		= Newborn_followUp->events[d.seq].vmin_K_result
	,hep_B_dt			= Newborn_followUp->events[d.seq].hep_B_dt
	,hep_B_result		= Newborn_followUp->events[d.seq].hep_B_result
	,hbig_dt			= Newborn_followUp->events[d.seq].hbig_dt
	,hbig_result		= Newborn_followUp->events[d.seq].hbig_result
	,abx_eye_dt			= Newborn_followUp->events[d.seq].abx_eye_dt
	,abx_eye_result		= Newborn_followUp->events[d.seq].abx_eye_result
	,disch_dx			= Newborn_followUp->events[d.seq].disch_dx
	,follup_provider 	= Newborn_followUp->events[d.seq].follup_provider
	,provider_phone		= Newborn_followUp->events[d.seq].provider_phone
	,appointment_dt		= Newborn_followUp->events[d.seq].appointment_dt
 
from
	(DUMMYT d with seq = value(size(Newborn_followUp->events,5)))
 
plan d
 
order by encntr_id
 
with nocounter, format, check, separator = " "
 
#exitscript
end
go
 
 

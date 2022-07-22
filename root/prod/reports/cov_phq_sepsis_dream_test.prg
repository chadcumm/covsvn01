/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Jan'2019
	Solution:			Quality
	Source file name:	      cov_phq_sepsis_dream_test.prg (cov_phq_sepsis_dream)
	Object name:		cov_phq_sepsis_dream_test
	Request#:			3176
	Program purpose:	      Sepsis analysis
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------	------------------------------------------
10/09/19    Geetha  CR# 6493 - Script update to exclude expired Lactic acid orders and include new lab orders
02/24/21    Geetha  CR# 8678 - add a new ICD code based on yearly health check  
06/30/21    Geetha  CR# 10630 - Add a new lactic acid order

******************************************************************************/
 
drop program cov_phq_sepsis_dream_test:dba go
create program cov_phq_sepsis_dream_test:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End  Discharge  Date/Time" = "SYSDATE"
	, "Acute Facility List" = 0
	, "Screen Display" = 1
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list, to_file
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare sep_quality_meas_var  = f8 with constant(uar_get_code_by("DISPLAY", 200, "Sepsis Quality Measures")),protect
declare sep_ip_alert_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Severe Sepsis IP Alert")),protect
declare sep_ed_alert_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Severe Sepsis ED Alert")),protect
declare sep_ed_triage_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, "ED Triage Sepsis Alert")),protect
declare sep_advisor_var       = f8 with constant(uar_get_code_by("DISPLAY", 200, "Sepsis Advisor")),protect
 
declare shock_hypotension_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "LH_QM_SHOCK_ALERT_CUSTOM")),protect
declare weight_dosing_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Weight Dosing")),protect
declare ed_triage_time_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "ED Triage Note")),protect
declare sepsis_present_dt_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Reg Severe Sepsis Presentation Dt Tm")),protect
declare septic_present_dt_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Reg Septic Shock Presentation Dt Tm")),protect
declare comfort_meas_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Comfort Measures")),protect
declare Resus_status_var      = f8 with constant(uar_get_code_by("DESCRIPTION", 200, "Resuscitation Status/Medical Interventions")),protect
 
/*old/expired orders - deactivated as of 10/9/19 -  need to be included for data back load
declare lact_acid_var         = f8 with constant(uar_get_code_by("DISPLAY", 200, "Lactic Acid, Plasma")),protect
declare sep_lact_acid_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, "Sepsis Lactic Acid, Plasma")),protect
declare ref_sep_lact_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Reflex Sepsis Lactic Acid, Plasma")),protect
;Part of old and new - need to be included for data back load and going forward as of 10/9/19
declare ref_lact_var          = f8 with constant(uar_get_code_by("DISPLAY", 200, "Reflex Lactic Acid w/ Reflex, Plasma")),protect
*/
 
;New/active Lactic acid orders as of 10/9/19
declare lact_acid_var         = f8 with constant(uar_get_code_by("DISPLAY", 200, "Lactic Acid with Reflex")),protect
declare ref_lact_var          = f8 with constant(uar_get_code_by("DISPLAY", 200, "Reflex Lactic Acid w/ Reflex, Plasma")),protect
declare non_ref_lact_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Non-Reflex Lactic Acid")),protect
declare arterial_lact_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, "Arterial Blood Gases with Lactic Acid w/Reflex+")),protect
declare venous_lact_var       = f8 with constant(uar_get_code_by("DISPLAY", 200, "Venous Blood Gases with Lactic Acid w/Reflex+")),protect
declare ed_lact_var           = f8 with constant(uar_get_code_by("DISPLAY", 200, "ED POC Lactate")),protect 
 
declare ord_bld_cult_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Blood Culture")),protect
declare ord_sep_bld_cult_var  = f8 with constant(uar_get_code_by("DISPLAY", 200, "Sepsis Blood Culture")),protect
declare blood_cult_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Blood Culture")),protect
declare sep_blood_cult_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Sepsis Blood Culture")),protect
 
declare volume_dose           = vc with protect ,noconstant ("" )
declare volume_dose_unit      = vc with protect ,noconstant ("" )
declare volumedose_var        = f8 with protect ,constant (12718.00 )
declare volumedose_unit_var   = f8 with protect ,constant (12719.00 )
 
declare pcnt                  = i4 with noconstant(0)
declare fac_var               = vc with noconstant(' ')
declare idx                   = i4 with noconstant(0)
declare no_blood_culture_var  = vc with noconstant('N')
declare anti_found_var        = i2 with noconstant(0)
declare anti_med_var          = vc with noconstant(' ')
declare diff6_result 		= f8 with noconstant(0.0)
declare diff3_result 		= f8 with noconstant(0.0)
declare diff_6hr_dt 		= dq8 with noconstant(0)
declare diff_3hr_dt 		= dq8 with noconstant(0)
 
;************* OPS SETUP ******************
declare output_orders = vc
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
 
;Testing - test process (only in test script)
declare filename_var  = vc with constant('cer_temp:sepsis_backload_july_31.txt'), protect
declare ccl_filepath_var = vc WITH constant('$cer_temp/sepsis_backload_july_31.txt'), PROTECT
 
;Feed to SpotFire - Prod process (only in PROD)
;declare filename_var = vc WITH constant('cer_temp:cov_phq_sepsis_dream.txt'), PROTECT
;declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_phq_sepsis_dream.txt'), PROTECT
declare astream_filepath_var = vc with constant("/cerner/w_custom/p0665_cust/to_client_site/Quality/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
 
RECORD sepsis(
	1 med_rec_cnt = i4
	1 plist[*]
		2 facility = f8
		2 strata_facility_cd = vc
		2 encntrid = f8
		2 personid = f8
		2 fin = vc
		2 mrn = vc
		2 orderid = f8
		2 order_mnemonic = vc
		2 tmp6_dt = dq8
		2 tmp3_dt = dq8
		2 tmp_pri = i4
		2 provider_dignosis = vc
		2 diagnosis_dt = dq8
		2 pat_name = vc
		2 encntr_type = vc
		2 reg_dt = vc
		2 disch_dt = vc
		2 los = f8
 		2 pat_dosing_weight = vc
		2 admit_nurse_unit = vc
		2 attending_phys_id = f8
 		2 attending_phys = vc
 		2 physician_attribute = vc
 		2 ed_checkin_dt = vc
 		2 ed_checkout_dt = vc
		2 ed_los = f8
		2 ed_provider_id = f8
 		2 ed_provider = vc
		2 ed_arrival_dt = vc
		2 ed_triage_time = vc
		2 ed_nurse_triage_screen = vc
		2 sep_adviser_alert_dt = dq8
		2 sep_quality_meas_ord_dt = dq8
		2 sep_IP_alert_dt = dq8
		2 sep_ED_alert_dt = dq8
		2 sep_ED_triage_alert_dt = dq8
		2 source_infect_doc_dt = dq8
		2 sepsis_event_present_dt = dq8
		2 septic_event_present_dt = dq8
		2 sepsis_present_dt = dq8
		2 septic_present_dt = dq8
		2 comfort_meas_dt = vc
		2 ini_lact_collect_dt = dq8
		2 ini_lact_result = f8
		2 lact_order_dt = vc
		2 lact_order_pr = vc
		2 lact_order_loc = vc
		2 lact_order_complete_loc = vc
		2 ini_lact_3hr_sep_presn = f8
		2 repeat_lact_order_dt = vc
		2 repeat_lact_order_pr = vc
		2 repeat_lact_order_loc = vc
		2 repeat_lact_dt = dq8
		2 repeat_lact_order_complete_loc = vc
		2 repeat_lact_result = vc
		2 repeat_lact_6hr_sep_presn = f8
		2 bld_cult_order_dt = vc
		2 bld_cult_order_pr = vc
		2 bld_cult_order_loc = vc
		2 bld_cult_order_complete_loc = vc
 		2 bld_cult_collect_dt = dq8
 		2 bld_cult_result = vc
 		2 bld_cult_result_dt = dq8
 		2 bld_cult_colct_3hrs_sep_presn = f8
 		2 bld_cult_colct_prior_antibio = vc
 		2 crys_fluid_dt = dq8
 		2 crys_fluid_name = vc
		2 crys_order_dt = vc
		2 crys_order_pr = vc
		2 crys_order_loc = vc
		2 crys_order_complete_loc = vc
 		2 crys_fluid_ml_admin = vc
 		2 crys_fluid_3hrs_sep_presn = f8
 		2 antibio_name = vc
 		2 antibio_admin_dt = dq8
 		2 antibiotic_non_cms = vc
 		2 antibiotic_non_cms_dt = vc
 		2 antibiotic_mono = vc
		2 anti_mono_order_dt = vc
		2 anti_mono_order_pr = vc
		2 anti_mono_order_loc = vc
		2 anti_mono_order_complete_loc = vc
 		2 antibiotic_mono_dt = vc
 		2 antibiotic_combination_a = vc
		2 anti_combA_order_dt = vc
		2 anti_combA_order_pr = vc
		2 anti_combA_order_loc = vc
		2 anti_combA_order_complete_loc = vc
 		2 antibiotic_combination_a_dt = vc
 		2 antibiotic_combination_b = vc
		2 anti_combB_order_dt = vc
		2 anti_combB_order_pr = vc
		2 anti_combB_order_loc = vc
		2 anti_combB_order_complete_loc = vc
 		2 antibiotic_combination_b_dt = vc
 		2 antibio_admin_3hrs_sep_presn = f8
 		2 vaso_admin_dt = dq8
 		2 vaso_name = vc
		2 vaso_order_dt = vc
		2 vaso_order_pr = vc
		2 vaso_order_loc = vc
		2 vaso_order_complete_loc = vc
 		2 vaso_admin_6hrs_sep_presn = f8
 		2 sep_hypotension_dt = vc
 		2 Septic_Shock_Repeat_Volume_Status = vc
)
 
/********************************
	Helpers
********************************/
 
RECORD lactic(
	1 lac_rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 enc_ord_cnt = i4
		2 ini_lact_dt = dq8
		2 olist[*]
			3 order_priority = i4
			3 use_in_sepsis = i4
			3 lact_orderid = f8
			3 lact_order_dt = dq8
			3 lact_order_pr = vc
			3 lact_order_loc = vc
			3 lact_order_complete_dt = dq8
			3 lact_order_complete_loc = vc
			3 ori_order_dt = vc
			3 lact_collect_dt = dq8
			3 lact_result = vc
			3 lact_result_dt = dq8
	)
 
RECORD crys_master(
	1 list[*]
		2 drug_identifier = vc
		2 mltum_category_id1 = f8
		2 parent_category = vc
		2 mltum_category_id2 = f8
		2 sub_category = vc
		2 mltum_category_id3 = f8
		2 sub_sub_category = vc
)
 
RECORD crys_master_stat(
	1 list[*]
		2 med_name = vc
)
 
;Create a static list of Crystaloids
select from dummyt d
Head report
	call alterlist(crys_master_stat->list, 7)
	crys_master_stat->list[1].med_name = '0.9% Saline Solution'
	crys_master_stat->list[2].med_name = '0.9% Sodium Chloride Solution'
	crys_master_stat->list[3].med_name = 'Isolyte'
	crys_master_stat->list[4].med_name = 'Lactated Ringers Solution'
	crys_master_stat->list[5].med_name = 'normal saline'
	crys_master_stat->list[6].med_name = 'Normosol'
	crys_master_stat->list[7].med_name = 'PlasmaLyte'
with nocounter
 
 
RECORD crys(
	1 crys_rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 event_id = f8
		2 crys_order_qualifier = vc
		2 crys_order_id = f8
		2 crys_order_dt = dq8
		2 crys_order_pr = vc
		2 crys_order_loc = vc
		2 crys_order_complete_dt = dq8
		2 crys_order_complete_loc = vc
		2 order_mnemonic = vc
		2 order_priority = i4
		2 event_end_dt = dq8
		2 volume = f8
		2 volume_unit = vc
)
 
RECORD antibio_master(
	1 list[*]
		2 drug_identifier = vc
		2 mltum_category_id1 = f8
		2 parent_category = vc
		2 mltum_category_id2 = f8
		2 sub_category = vc
		2 mltum_category_id3 = f8
		2 sub_sub_category = vc
)
 
RECORD antibio(
	1 anti_rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 test = vc
		2 enc_ord_cnt = i4
		2 olist[*]
			3 drug_id = vc
			3 anti_order_id = f8
			3 anti_order_dt = dq8
			3 anti_order_pr = vc
			3 anti_order_loc = vc
			3 anti_order_complete_dt = dq8
			3 anti_order_complete_loc = vc
			3 antibio_name = vc
			3 order_priority = i4
			3 anti_admin_dt = dq8
			3 anti_admin_dt_vc = vc
	)
 
RECORD vaso_master(
	1 list[*]
		2 drug_identifier = vc
		2 mltum_category_id1 = f8
		2 parent_category = vc
		2 mltum_category_id2 = f8
		2 sub_category = vc
		2 mltum_category_id3 = f8
		2 sub_sub_category = vc
)
 
RECORD vaso_master_stat(
	1 list[*]
		2 med_name = vc
)
;Create a static list of Vasopressors
select from dummyt d
Head report
	call alterlist(vaso_master_stat->list, 9)
	vaso_master_stat->list[1].med_name = 'Norepinephrine'
	vaso_master_stat->list[2].med_name = 'Epinephrine'
	vaso_master_stat->list[3].med_name = 'Phenylephrine'
	vaso_master_stat->list[4].med_name = 'Dopamine'
	vaso_master_stat->list[5].med_name = 'Vasopressin'
	vaso_master_stat->list[6].med_name = 'Levophed'
	vaso_master_stat->list[7].med_name = 'Adrenalin'
	vaso_master_stat->list[8].med_name = 'Neosynephrine'
	vaso_master_stat->list[9].med_name = 'Vazculep'
 
with nocounter
 
RECORD vaso(
	1 vaso_rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 vaso_order_id = f8
		2 vaso_order_dt = dq8
		2 vaso_order_pr = vc
		2 vaso_order_loc = vc
		2 vaso_order_complete_dt = dq8
		2 vaso_order_complete_loc = vc
		2 order_mnemonic = vc
		2 order_priority = i4
		2 event_end_dt = dq8
)
 
RECORD bcult(
	1 bcult_rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 bcult_order_priority = i4
		2 bcult_order_id = f8
		2 bcult_order_mnemonic = vc
		2 bcult_order_dt = dq8
		2 bcult_collect_dt = dq8
		2 bcult_result = vc
		2 bcult_result_dt = dq8
		2 bcult_order_pr = vc
		2 bcult_order_loc = vc
		2 bcult_order_complete_dt = dq8
		2 bcult_order_complete_loc = vc
)
 
 
RECORD cms(
	1 list[*]
		2 med_col_a_name = vc
)
 
RECORD cms_comb_A(
	1 list[*]
		2 med_col_a_name = vc
)
 
RECORD cms_comb_B(
	1 list[*]
		2 med_col_b_name = vc
)
 
;Create CMS Static list - Antibiotic Monotherapy, Sepsis
select from dummyt d
 
Head report
	call alterlist(cms->list, 34)
	cms->list[1].med_col_a_name = 'Avelox'
	cms->list[2].med_col_a_name = 'Avycaz'
	cms->list[3].med_col_a_name = 'Ceftriaxone'
	cms->list[4].med_col_a_name = 'Claforan'
	cms->list[5].med_col_a_name = 'Doribax'
	cms->list[6].med_col_a_name = 'Fortaz'
	cms->list[7].med_col_a_name = 'Invanz'
	cms->list[8].med_col_a_name = 'Levaquin'
	cms->list[9].med_col_a_name = 'Maxipime'
	cms->list[10].med_col_a_name = 'Merrem'
	cms->list[11].med_col_a_name = 'Primaxin'
	cms->list[12].med_col_a_name = 'Teflaro'
	cms->list[13].med_col_a_name = 'Unasyn'
	cms->list[14].med_col_a_name = 'Zerbaxa'
	cms->list[15].med_col_a_name = 'Zosyn'
	cms->list[16].med_col_a_name = 'Moxifoxacin'
	cms->list[17].med_col_a_name = 'Ceftazidime-avibactam'
	cms->list[18].med_col_a_name = 'Ceftriaxone'
	cms->list[19].med_col_a_name = 'Cefotaxime'
	cms->list[20].med_col_a_name = 'Doripenem'
	cms->list[21].med_col_a_name = 'Ceftazidime'
	cms->list[22].med_col_a_name = 'Ertapenem'
	cms->list[23].med_col_a_name = 'Levofloxacin'
	cms->list[24].med_col_a_name = 'Cefepime'
	cms->list[25].med_col_a_name = 'Meropenem'
	cms->list[26].med_col_a_name = 'Imipenem-Cilastatin'
	cms->list[27].med_col_a_name = 'Ceftaroline fosamil'
	cms->list[28].med_col_a_name = 'Ampicillin-sulbactam'
	cms->list[29].med_col_a_name = 'Ceftolozane-tazobactam'
	cms->list[30].med_col_a_name = 'piperacillin-tazobactam'
	cms->list[31].med_col_a_name = 'Oral Vancomycin'
	cms->list[32].med_col_a_name = 'Rectal vancomycin'
	cms->list[33].med_col_a_name = 'IV metronidazole'
	cms->list[34].med_col_a_name = 'Flagyl'
 
with nocounter
 
;Create CMS combination therapy col A - Static list (Antibiotic, Sepsis)
select from dummyt d
Head report
	call alterlist(cms_comb_A->list, 7)
	cms_comb_A->list[1].med_col_a_name = 'Amikacin'
	cms_comb_A->list[2].med_col_a_name = 'Gentamicin'
	cms_comb_A->list[3].med_col_a_name = 'Kanamycin'
	cms_comb_A->list[4].med_col_a_name = 'Tobramycin'
	cms_comb_A->list[5].med_col_a_name = 'Azactam'
	cms_comb_A->list[6].med_col_a_name = 'Ciprofloxacin'
	cms_comb_A->list[7].med_col_a_name = 'Aztreonam'
with nocounter
 
;Create CMS combination therapy col B - Static list (Antibiotic, Sepsis)
select from dummyt d
Head report
	call alterlist(cms_comb_B->list, 31)
	cms_comb_B->list[1].med_col_b_name = 'Ancef'
	cms_comb_B->list[2].med_col_b_name = 'Cefotan'
	cms_comb_B->list[3].med_col_b_name = 'Cefuroxime'
	cms_comb_B->list[4].med_col_b_name = 'Mefoxin'
	cms_comb_B->list[5].med_col_b_name = 'Targocid'
	cms_comb_B->list[6].med_col_b_name = 'Vancocin'
	cms_comb_B->list[7].med_col_b_name = 'Vibativ'
	cms_comb_B->list[8].med_col_b_name = 'Erythocin'
	cms_comb_B->list[9].med_col_b_name = 'Sumamed'
	cms_comb_B->list[10].med_col_b_name = 'Xithrone'
	cms_comb_B->list[11].med_col_b_name = 'Zithromax'
	cms_comb_B->list[12].med_col_b_name = 'Ampicillin'
	cms_comb_B->list[13].med_col_b_name = 'Nafcillin'
	cms_comb_B->list[14].med_col_b_name = 'Oxacillin'
	cms_comb_B->list[15].med_col_b_name = 'Penicillin G'
	cms_comb_B->list[16].med_col_b_name = 'Cleocin Clindamycin'
	cms_comb_B->list[17].med_col_b_name = 'Daptomycin Cubicin Daptomycin'
	cms_comb_B->list[18].med_col_b_name = 'Zyvox Linezolid'
 	cms_comb_B->list[19].med_col_b_name = 'Cefazolin'
	cms_comb_B->list[20].med_col_b_name = 'Cefotetan'
	cms_comb_B->list[21].med_col_b_name = 'Cefuroxime'
	cms_comb_B->list[22].med_col_b_name = 'Cefoxitin'
	cms_comb_B->list[23].med_col_b_name = 'Teicoplanin'
	cms_comb_B->list[24].med_col_b_name = 'Vancomycin'
	cms_comb_B->list[25].med_col_b_name = 'Telavancin'
	cms_comb_B->list[26].med_col_b_name = 'Erythromycin'
	cms_comb_B->list[27].med_col_b_name = 'Azithromycin'
	cms_comb_B->list[28].med_col_b_name = 'Ampicillin'
	cms_comb_B->list[29].med_col_b_name = 'Nafcillin'
	cms_comb_B->list[30].med_col_b_name = 'Oxacillin'
	cms_comb_B->list[31].med_col_b_name = 'Penicillin'
 
with nocounter
 
 
/**************************************************************
; DVDev Data Qualification
**************************************************************/
;Qualification - sepsis find via orders
select into 'nl:'
 
e.encntr_id, o.order_mnemonic, O.order_id
 
from
	encounter e
	, orders o
 
plan e where e.loc_facility_cd = $acute_facility_list ;parser(fac_var)
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00);ED, Inpatient, Observation, Outpatient in a Bed
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and e.disch_dt_tm is not null
 
join o where o.person_id = e.person_id
	and o.encntr_id = e.encntr_id
	and o.catalog_type_cd = 2515.00 ;Patient Care
	and o.catalog_cd in(sep_quality_meas_var, sep_ip_alert_var, sep_ed_alert_var, sep_ed_triage_var, sep_advisor_var)
	and o.active_ind = 1
	and o.active_status_cd = 188.00 ;Active
 
order by e.person_id, e.encntr_id, o.order_id
 
Head report
	pcnt = 0
	call alterlist(sepsis->plist, 100)
 
Head e.encntr_id
	 pcnt += 1
	 sepsis->med_rec_cnt = pcnt
 	call alterlist(sepsis->plist, pcnt)
 
	sepsis->plist[pcnt].facility = e.loc_facility_cd
	sepsis->plist[pcnt].encntrid = e.encntr_id
	sepsis->plist[pcnt].personid = e.person_id
	sepsis->plist[pcnt].orderid = o.order_id
	sepsis->plist[pcnt].order_mnemonic = o.order_mnemonic
 
Head o.order_id
	null
 
Detail
	if(o.order_mnemonic = 'Sepsis Advisor')
		if(sepsis->plist[pcnt].sep_adviser_alert_dt = 0)
			sepsis->plist[pcnt].sep_adviser_alert_dt = o.orig_order_dt_tm;format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		endif
	elseif(o.order_mnemonic = 'Sepsis Quality Measures')
		if(sepsis->plist[pcnt].sep_quality_meas_ord_dt = 0)
			sepsis->plist[pcnt].sep_quality_meas_ord_dt = o.orig_order_dt_tm ;format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		endif
	elseif(o.order_mnemonic = 'Severe Sepsis IP Alert')
		if(sepsis->plist[pcnt].sep_IP_alert_dt = 0)
			sepsis->plist[pcnt].sep_IP_alert_dt = o.orig_order_dt_tm ;format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		endif
	elseif(o.order_mnemonic = 'Severe Sepsis ED Alert')
		if(sepsis->plist[pcnt].sep_ED_alert_dt = 0)
			sepsis->plist[pcnt].sep_ED_alert_dt = o.orig_order_dt_tm ;format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		endif
	elseif(o.order_mnemonic = 'ED Triage Sepsis Alert')
		if(sepsis->plist[pcnt].sep_ED_triage_alert_dt = 0)
			sepsis->plist[pcnt].sep_ED_triage_alert_dt = o.orig_order_dt_tm ;format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		endif
	endif
 
Foot e.encntr_id
	/*sepsis->plist[pcnt].source_infect_doc_dt =
		if(sepsis->plist[pcnt].sep_adviser_alert_dt != 0) sepsis->plist[pcnt].sep_adviser_alert_dt
			elseif(sepsis->plist[pcnt].sep_ED_triage_alert_dt != 0) sepsis->plist[pcnt].sep_ED_triage_alert_dt
			elseif(sepsis->plist[pcnt].sep_quality_meas_ord_dt != 0) sepsis->plist[pcnt].sep_quality_meas_ord_dt
			elseif(sepsis->plist[pcnt].sep_IP_alert_dt != 0) sepsis->plist[pcnt].sep_IP_alert_dt
			elseif(sepsis->plist[pcnt].sep_ED_alert_dt != 0) sepsis->plist[pcnt].sep_ED_alert_dt
		endif*/
 
 	call alterlist(sepsis->plist, pcnt)
 
with nocounter
 
;call echorecord(sepsis)
 
;-------------------------------------------------------------------------------------------------------------------------------
;Qualification - sepsis find via Provider Diagnosis - accounts not in orders
select into 'nl:'
 
dg.encntr_id, dg.diagnosis_display, n.source_identifier
 
from
	 encounter e
	, diagnosis dg
	, nomenclature n
 
plan e where  e.loc_facility_cd = $acute_facility_list ;parser(fac_var)
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00);ED, Inpatient, Observation, Outpatient in a Bed
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and e.disch_dt_tm is not null
 
join dg where dg.encntr_id = e.encntr_id
	and dg.active_ind = 1
	and dg.active_status_cd = 188
	and dg.diagnosis_display != ''
 
join n where n.nomenclature_id = dg.nomenclature_id
	;and n.source_vocabulary_cd = 19350056.00 ;ICD-10-CM
	and n.active_ind = 1
	and n.end_effective_dt_tm > sysdate
	and n.active_status_cd = 188
	and n.source_identifier in ('A02.1', 'A22.7', 'A26.7', 'A32.7', 'A40.0', 'A40.1', 'A40.3', 'A40.8', 'A40.9', 'A41.01', 'A41.02',
					'A41.1', 'A41.2', 'A41.3', 'A41.4', 'A41.50', 'A41.51', 'A41.52', 'A41.53', 'A41.59', 'A41.8', 'A41.81',
					'A41.89', 'A41.9', 'A42.7', 'A54.86', 'R65.20', 'R65.21','B37.7')
 
order by e.person_id, e.encntr_id
 
;append rows into the Sepsis resord structure if it not in their already OR update Provider diagnosis if exists.
Head e.encntr_id
	cnt = 0
 	edx = 0
 	edx = locateval(cnt,1,size(sepsis->plist,5), e.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	if(edx = 0) ;add new row
		pcnt = pcnt + 1
		sepsis->med_rec_cnt = pcnt
		call alterlist(sepsis->plist, pcnt)
		sepsis->plist[pcnt].facility = e.loc_facility_cd
		sepsis->plist[pcnt].encntrid = e.encntr_id
		sepsis->plist[pcnt].personid = e.person_id
		sepsis->plist[pcnt].provider_dignosis = dg.diagnosis_display
		sepsis->plist[pcnt].diagnosis_dt = dg.diag_dt_tm
	else
	 	sepsis->plist[edx].provider_dignosis = dg.diagnosis_display
	 	sepsis->plist[edx].diagnosis_dt = dg.diag_dt_tm
	endif
 
Foot e.encntr_id
	if(edx = 0);update existing row
 		call alterlist(sepsis->plist, pcnt)
 	endif
 
with nocounter
 
;---------------------------------------------------------------------------------------------------------------------------------
if(sepsis->med_rec_cnt > 0)
 
;Patient info
select into 'nl:'
 
  e.encntr_id, ea.alias, ea1.alias
, p.name_full_formatted
, enc_type = uar_get_code_display(e.encntr_type_cd)
, nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
, los = datetimediff(e.disch_dt_tm, e.reg_dt_tm,3)
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,encounter e
	,(left join encntr_prsnl_reltn epr on epr.encntr_id = e.encntr_id
		and epr.active_ind = 1
		and epr.encntr_prsnl_r_cd = 1119.00) ;Attending Physician
 
	,encntr_alias ea
	,encntr_alias ea1
	,person p
	,prsnl pr
 
plan d
 
join e where e.person_id =  sepsis->plist[d.seq].personid
	and e.encntr_id =  sepsis->plist[d.seq].encntrid
 
join epr
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;FIN
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1079 ;MRN
	and ea1.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pr where pr.person_id = epr.prsnl_person_id
	and pr.active_ind = 1
 
order by e.person_id, e.encntr_id
 
Head e.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), e.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].fin = ea.alias
	sepsis->plist[idx].mrn = ea1.alias
	sepsis->plist[idx].pat_name = p.name_full_formatted
	sepsis->plist[idx].reg_dt = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
	sepsis->plist[idx].disch_dt = format(e.disch_dt_tm, "mm/dd/yyyy hh:mm;;d")
	sepsis->plist[idx].los = los
	sepsis->plist[idx].admit_nurse_unit = nurse_unit
	sepsis->plist[idx].encntr_type = enc_type
	sepsis->plist[idx].attending_phys_id = pr.person_id
	sepsis->plist[idx].attending_phys = pr.name_full_formatted
 
  	sepsis->plist[idx].strata_facility_cd =
		if(e.loc_facility_cd = 21250403.00) '20' ;FSR
		 	elseif(e.loc_facility_cd = 2552503613.00) '24' ;MMC
		 	elseif(e.loc_facility_cd = 2553765579.00) '65' ;G
		 	elseif(e.loc_facility_cd = 2552503635.00) '28' ;FLMC
		 	elseif(e.loc_facility_cd = 2552503639.00) '25' ;MHHS
			elseif(e.loc_facility_cd = 2552503645.00) '22' ;PW
		 	elseif(e.loc_facility_cd = 2552503649.00) '27' ;RMC
		 	elseif(e.loc_facility_cd = 2552503653.00) '26' ;LCMC
		endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;get Physician attribute
 
select into 'nl:'
 
pgr.person_id, pg.prsnl_group_name
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	 , prsnl_group_reltn pgr
	 , prsnl_group pg
 
plan d
 
join pgr where pgr.person_id = sepsis->plist[d.seq].attending_phys_id
	and pgr.active_ind = 1
 
join pg where pg.prsnl_group_id = pgr.prsnl_group_id
	and pg.active_ind = 1
	and pg.prsnl_group_type_cd in(2559389385.00, 2559553249.00)	;TEAMHEALTH HOSPITAL MED, STATCARE HOSPITALIST GRP
 
order by pgr.person_id, pg.prsnl_group_name
 
Head pgr.person_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), pgr.person_id, sepsis->plist[cnt].attending_phys_id)
Detail
	sepsis->plist[idx].physician_attribute = pg.prsnl_group_name
 
With nocounter
 
;------------------------------------------------------------------------------------------------------------
;ED assessments
select into 'nl:'
 
  ti.person_id
, ti.encntr_id
, checkin_dt_tm = format(tc.checkin_dt_tm, "mm/dd/yyyy hh:mm;;d")
, checkout_dt_tm = format(tc.checkout_dt_tm, "mm/dd/yyyy hh:mm;;d")
, los_hrs	  = datetimediff(tc.checkout_dt_tm, tc.checkin_dt_tm,3)
, ed_doctor_id = if(pr.person_id is not null) pr.person_id else pr1.person_id endif
, ed_doctor = if(pr.name_full_formatted != '') pr.name_full_formatted else pr1.name_full_formatted endif
, secondary_ed_doc = pr1.name_full_formatted
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	 , tracking_checkin tc
	 , tracking_item ti
	 , tracking_prsnl tp
	 , prsnl pr
	 , prsnl pr1
 
plan d
 
join ti where ti.encntr_id = sepsis->plist[d.seq].encntrid
	and ti.active_ind = 1
 
join tc where tc.tracking_id = ti.tracking_id
	and tc.active_ind = 1
	and tc.acuity_level_id != 0
 
join tp where tp.tracking_group_cd = tc.tracking_group_cd
	and tp.def_encntr_prsnl_r_cd = 3362683.00
 
join pr where pr.person_id = tc.primary_doc_id
 
join pr1 where pr1.person_id = tc.secondary_doc_id
 
order by ti.person_id, ti.encntr_id
 
Head ti.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), ti.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].ed_arrival_dt = checkin_dt_tm
	sepsis->plist[idx].ed_checkin_dt = checkin_dt_tm
	sepsis->plist[idx].ed_checkout_dt = checkout_dt_tm
	sepsis->plist[idx].ed_los = los_hrs
	sepsis->plist[idx].ed_provider = ed_doctor
 
With nocounter
 
;------------------------------------------------------------------------------------------------------------
;Clinical_events
 
select into 'nl:'
 
ce.encntr_id
, event = uar_get_code_display(ce.event_cd)
, verify_dt = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,clinical_event ce
	, ce_date_result cdr
 
plan d
 
join ce where ce.person_id = sepsis->plist[d.seq].personid
	and ce.encntr_id = sepsis->plist[d.seq].encntrid
	and ce.event_cd in(ed_triage_time_var, sepsis_present_dt_var, septic_present_dt_var, weight_dosing_var, shock_hypotension_var)
	and ce.result_status_cd in(25, 34,35)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
					and ce1.result_status_cd in(25,34,35)
					group by ce1.encntr_id)
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
 
order by ce.person_id, ce.encntr_id, ce.event_cd
 
Head ce.encntr_id
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), ce.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	case(ce.event_cd)
		of ed_triage_time_var:
			sepsis->plist[idx].ed_triage_time = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")
		of sepsis_present_dt_var:
			if(cdr.result_dt_tm is not null)
				sepsis->plist[idx].sepsis_event_present_dt = cdr.result_dt_tm ;format(cdr.result_dt_tm, "mm/dd/yyyy hh:mm;;d")
			endif
		of septic_present_dt_var:
			if(cdr.result_dt_tm is not null)
				sepsis->plist[idx].septic_event_present_dt = cdr.result_dt_tm ;format(cdr.result_dt_tm, "mm/dd/yyyy hh:mm;;d")
				sepsis->plist[idx].septic_present_dt = cdr.result_dt_tm ;format(cdr.result_dt_tm, "mm/dd/yyyy hh:mm;;d")
			endif
		of weight_dosing_var:
			sepsis->plist[idx].pat_dosing_weight = build2(trim(ce.result_val), ' ', uar_get_code_display(ce.result_units_cd))
 
		of shock_hypotension_var:
			sepsis->plist[idx].sep_hypotension_dt = format(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;d")
	endcase
Foot ce.encntr_id
	sepsis->plist[idx].ed_nurse_triage_screen = if(sepsis->plist[idx].ed_triage_time != '') 'Y' else 'N' endif
 
With nocounter
 
;call echorecord(sepsis)
 
;------------------------------------------------------------------------------------------------------------
;Comfort Measures from orders
 
select into 'nl:'
 
o.encntr_id, o.order_mnemonic
, catalog = uar_get_code_description(o.catalog_cd), o.catalog_cd
, c_type = uar_get_code_display(o.catalog_type_cd)
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	, orders o
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.catalog_type_cd = 2515.00 ;Patient Care
	and o.catalog_cd in(comfort_meas_var) ;, Resus_status_var) removed as per Lori.
 
order by o.encntr_id, o.order_mnemonic
 
Head o.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), o.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].comfort_meas_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
 
With nocounter
 
;--------------------------SEPSIS PRESENT ZERO TIME --------------------------------------------------------------------------------
;Get sepsis alert/diagnosis zero time
select into 'nl:'
 
e.encntr_id
,sep_ED_triage_alert_dt = if(cnvtreal(sepsis->plist[d.seq].sep_ED_triage_alert_dt) = 0)
		cnvtdatetime("31-DEC-2100 00:00:00") else	sepsis->plist[d.seq].sep_ED_triage_alert_dt endif
,sep_IP_alert_dt = if(cnvtreal(sepsis->plist[d.seq].sep_IP_alert_dt) = 0)
		cnvtdatetime("31-DEC-2100 00:00:00") else sepsis->plist[d.seq].sep_IP_alert_dt endif
,sep_ED_alert_dt = if(cnvtreal(sepsis->plist[d.seq].sep_ED_alert_dt) = 0)
		 cnvtdatetime("31-DEC-2100 00:00:00") else sepsis->plist[d.seq].sep_ED_alert_dt endif
,sep_advisor_alert_dt = if(cnvtreal(sepsis->plist[d.seq].sep_adviser_alert_dt) = 0)
		cnvtdatetime("31-DEC-2100 00:00:00") else sepsis->plist[d.seq].sep_adviser_alert_dt endif
,sep_diagnosis_dt = if(cnvtreal(sepsis->plist[d.seq].diagnosis_dt) = 0)
		cnvtdatetime("31-DEC-2100 00:00:00") else sepsis->plist[d.seq].diagnosis_dt endif
,sep_eve_prsnt_dt = if(cnvtreal(sepsis->plist[d.seq].sepsis_event_present_dt) = 0)
		cnvtdatetime("31-DEC-2100 00:00:00") else sepsis->plist[d.seq].sepsis_event_present_dt endif
,sept_eve_prsnt_dt = if(cnvtreal(sepsis->plist[d.seq].septic_event_present_dt) = 0)
		cnvtdatetime("31-DEC-2100 00:00:00") else sepsis->plist[d.seq].septic_event_present_dt endif
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,encounter e
 
plan d
 
join e where e.encntr_id = sepsis->plist[d.seq].encntrid
 
order by e.encntr_id
 
Head e.encntr_id
	cnt = 0, idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), e.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	if(idx > 0)
		sepsis->plist[idx].sepsis_present_dt = least(cnvtreal(sep_ED_triage_alert_dt), cnvtreal(sep_IP_alert_dt)
			,cnvtreal(sep_ED_alert_dt), cnvtreal(sep_advisor_alert_dt), cnvtreal(sep_diagnosis_dt)
			,cnvtreal(sep_eve_prsnt_dt), cnvtreal(sept_eve_prsnt_dt))
 
		sepsis->plist[idx].source_infect_doc_dt = sepsis->plist[idx].sepsis_present_dt
	endif
 
With nocounter
 
;---------------------------------------  LACTATE COLLECTION ---------------------------------------------------------------------
;Initial Lactate collection - New logic as of 04/29/2019
 
select into 'nl:'
o.encntr_id, o.order_id, o.hna_order_mnemonic, o.last_action_sequence
, ori_ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, oa.dept_status_cd, stat = uar_get_code_display(oa.dept_status_cd), oa.action_dt_tm "@SHORTDATETIME"
;, collect_dt = if(cte.drawn_dt_tm != 0) cte.drawn_dt_tm else cte.event_dt_tm endif
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,orders o
	,(left join clinical_event ce on ce.order_id = o.order_id
		and ce.event_cd = 2556643417.00 ;Lactic Acid Lvl
		and ce.result_status_cd in(25,34,35)
		and ce.view_level = 1
		and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			group by ce1.encntr_id, ce1.order_id))
 
 	, order_action oa
 	, order_action oa1
	;,order_serv_res_container osr
	;,container_event cte
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.catalog_cd in(lact_acid_var, ref_lact_var, non_ref_lact_var, arterial_lact_var, venous_lact_var, ed_lact_var)
		;in(lact_acid_var, sep_lact_acid_var, ref_lact_var, ref_sep_lact_var) ;deactivated as of 10/9/19
	and o.active_ind = 1
	and o.order_status_cd = 2543 ;completed
 
join ce
 
join oa where oa.order_id = o.order_id
	and oa.dept_status_cd = 9311.00 ;Collected
 
join oa1 where oa1.order_id = o.order_id
	and oa1.dept_status_cd = 9322.00 ;In-Lab - qualify In_lab status
 
/*join osr where osr.order_id = o.order_id
 
join cte where cte.container_id = osr.container_id
      and cte.event_type_cd = 1794.00 ;Collected
      and cte.event_sequence = (select min(cte1.event_sequence) from container_event cte1
      		where cte1.container_id = cte.container_id
      		and cte1.event_type_cd = 1794.00 ;Collected
      		group by cte1.container_id)*/
 
order by o.encntr_id, oa.action_dt_tm ;, o.order_id
;***** As per trouble shooting regarding Lyle's question - findings - 10/21/19
 ;Collection_dt not sequential like original order placed dt ; having order by as collection_dt(oa.action_dt_tm) will fix the issue
 
 
Head report
	lcnt = 0
	call alterlist(lactic->list, 100)
Head o.encntr_id
	lcnt += 1
	lactic->lac_rec_cnt = lcnt
 	call alterlist(lactic->list, lcnt)
	ocnt = 0
	diff6_result = 0.0, diff3_result = 0.0, diff6 = 10000.00, diff3 = 10000.00, tmp_ord3 = 0, tmp_ord6 = 0
Head o.order_id
	ocnt += 1
 	call alterlist(lactic->list[lcnt].olist, ocnt)
Detail
	lactic->list[lcnt].encntrid = o.encntr_id
	lactic->list[lcnt].olist[ocnt].order_priority = ocnt
	lactic->list[lcnt].olist[ocnt].lact_orderid = o.order_id
	lactic->list[lcnt].olist[ocnt].ori_order_dt = ori_ord_dt
	lactic->list[lcnt].olist[ocnt].lact_order_dt = o.orig_order_dt_tm
 	lactic->list[lcnt].olist[ocnt].lact_collect_dt = oa.action_dt_tm ;collect_dt
 	lactic->list[lcnt].olist[ocnt].lact_result = ce.result_val
 	lactic->list[lcnt].olist[ocnt].lact_result_dt = ce.event_end_dt_tm
 	lactic->list[lcnt].olist[ocnt].lact_order_complete_dt = oa.action_dt_tm ;collect_dt
 
 	if(trim(ce.result_val) != '' and trim(ce.result_val) != '0.00')
		if(oa.action_dt_tm < sepsis->plist[d.seq].sepsis_present_dt)
			diff6 = datetimediff(cnvtdatetime(sepsis->plist[d.seq].sepsis_present_dt),cnvtdatetime(oa.action_dt_tm),4)
			diff3 = 10000.00
		elseif(oa.action_dt_tm > sepsis->plist[d.seq].sepsis_present_dt)
			diff3 = datetimediff(cnvtdatetime(oa.action_dt_tm), cnvtdatetime(sepsis->plist[d.seq].sepsis_present_dt),4)
			diff6 = 10000.00
 		endif
 		if(diff6 <= 360.00 and cnvtreal(ce.result_val) > diff6_result)
 			diff6_result = cnvtreal(ce.result_val)
 			sepsis->plist[d.seq].tmp6_dt = oa.action_dt_tm
			tmp_ord6 = ocnt
 		elseif(diff3 <= 180.00 and cnvtreal(ce.result_val) > diff3_result)
 			diff3_result = cnvtreal(ce.result_val)
 			sepsis->plist[d.seq].tmp3_dt = oa.action_dt_tm
			tmp_ord3 = ocnt
 		endif
 	endif
 
Foot o.encntr_id
	if(diff6_result != 0)
		sepsis->plist[d.seq].Ini_lact_collect_dt = sepsis->plist[d.seq].tmp6_dt
		sepsis->plist[d.seq].Ini_lact_result = diff6_result
		sepsis->plist[d.seq].tmp_pri = tmp_ord6
	elseif(diff3_result != 0)
		sepsis->plist[d.seq].Ini_lact_collect_dt = sepsis->plist[d.seq].tmp3_dt
		sepsis->plist[d.seq].Ini_lact_result = diff3_result
		sepsis->plist[d.seq].tmp_pri = tmp_ord3
	endif
 
	if(sepsis->plist[d.seq].sepsis_present_dt != 0.0)
		sepsis->plist[d.seq].ini_lact_3hr_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[d.seq].ini_lact_collect_dt), cnvtdatetime(sepsis->plist[d.seq].sepsis_present_dt),3)
	elseif(sepsis->plist[d.seq].septic_present_dt != 0.0)
		sepsis->plist[d.seq].ini_lact_3hr_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[d.seq].ini_lact_collect_dt), cnvtdatetime(sepsis->plist[d.seq].
		septic_present_dt),3)
	endif
	lactic->list[lcnt].enc_ord_cnt = ocnt
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Lactic - ordering provider
select into 'nl:'
	enc = lactic->list[d1.seq].encntrid
	, lact_orderid = lactic->list[d1.seq].olist[d2.seq].lact_orderid
 
from	 (dummyt   d1  with seq = size(lactic->list, 5))
	,(dummyt   d2  with seq = 1)
	, order_action   oa
	, prsnl   pr
 
plan d1 where maxrec(d2, size(lactic->list[d1.seq].olist, 5))
join d2
 
join oa where oa.order_id = lactic->list[d1.seq].olist[d2.seq].lact_orderid
	and oa.action_sequence = 1
 
join pr where pr.person_id = oa.order_provider_id
 
order by oa.order_id
 
Head oa.order_id
 
	lactic->list[d1.seq].olist[d2.seq].lact_order_pr = trim(pr.name_full_formatted)
 
 	/*cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(lactic->list,5), oa.order_id, lactic->list[d1.seq].olist[cnt].lact_orderid)
	if(idx > 0)
		lactic->list[d1.seq].olist[idx].lact_order_pr = trim(pr.name_full_formatted)
	endif*/
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Lactic - Patient location at time of order
select into 'nl:'
 
elh.encntr_id, ord_id = lactic->list[d1.seq].olist[d2.seq].lact_orderid
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from	 (dummyt   d1  with seq = size(lactic->list, 5))
	,(dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(lactic->list[d1.seq].olist, 5))
join d2
 
join elh where elh.encntr_id = lactic->list[d1.seq].encntrid
	and lactic->list[d1.seq].olist[d2.seq].lact_order_dt != 0
	and (cnvtdatetime(lactic->list[d1.seq].olist[d2.seq].lact_order_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 
	lactic->list[d1.seq].olist[d2.seq].lact_order_loc = order_pat_loc
 
 	/*cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(lactic->list,5), ord_id, lactic->list[d1.seq].olist[cnt].lact_orderid)
	if(idx > 0)
		lactic->list[d1.seq].olist[idx].lact_order_loc = order_pat_loc
	endif*/
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Lactic - Patient location at time of order complete
 
select into 'nl:'
 
elh.encntr_id, ord_id = lactic->list[d1.seq].olist[d2.seq].lact_orderid
, order_complet_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from	 (dummyt   d1  with seq = size(lactic->list, 5))
	,(dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(lactic->list[d1.seq].olist, 5))
join d2
 
join elh where elh.encntr_id = lactic->list[d1.seq].encntrid
	and lactic->list[d1.seq].olist[d2.seq].lact_order_complete_dt != 0
	and (cnvtdatetime(lactic->list[d1.seq].olist[d2.seq].lact_order_complete_dt)
		 between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 
	lactic->list[d1.seq].olist[d2.seq].lact_order_complete_loc = order_complet_pat_loc
 
 	/*cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(lactic->list,5), ord_id, lactic->list[d1.seq].olist[cnt].lact_orderid)
	if(idx > 0)
		lactic->list[d1.seq].olist[idx].lact_order_complete_loc = order_complet_pat_loc
	endif*/
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Assign Lactate results to sepsis list
select into 'nl:'
enc = lactic->list[d2.seq].encntrid
 
from	(dummyt d1 with seq = size(sepsis->plist, 5))
	,(dummyt d2 with seq = size(lactic->list, 5))
	,(dummyt d3 with seq = 1)
 
plan d1
 
join d2 where maxrec(d3, size(lactic->list[d2.seq].olist, 5))
	and sepsis->plist[d1.seq].encntrid = lactic->list[d2.seq].encntrid
 
join d3 where lactic->list[d2.seq].olist[d3.seq].order_priority = sepsis->plist[d1.seq].tmp_pri
 
order by enc
 
Head enc
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), enc, sepsis->plist[cnt].encntrid)
Detail
	if(idx > 0)
		sepsis->plist[idx].lact_order_dt = format(lactic->list[d2.seq].olist[d3.seq].lact_order_dt, 'mm/dd/yyyy hh:mm;;q')
		sepsis->plist[idx].lact_order_loc = lactic->list[d2.seq].olist[d3.seq].lact_order_loc
		sepsis->plist[idx].lact_order_pr = lactic->list[d2.seq].olist[d3.seq].lact_order_pr
		sepsis->plist[idx].lact_order_complete_loc = lactic->list[d2.seq].olist[d3.seq].lact_order_complete_loc
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Get Repeat lactate
select into 'nl:'
	e.encntr_id
	, plist_fin = substring(1, 30, sepsis->plist[d1.seq].fin)
	, plist_mrn = substring(1, 30, sepsis->plist[d1.seq].mrn)
	, olist_lact_collect_dt = lactic->list[d2.seq].olist[d3.seq].lact_collect_dt
	, olist_lact_result = substring(1, 30, lactic->list[d2.seq].olist[d3.seq].lact_result)
 
from
	(dummyt d1 with seq = size(sepsis->plist, 5))
	, (dummyt d2 with seq = size(lactic->list, 5))
	, (dummyt d3 with seq = 1)
	, encounter e
 
plan d1
join d2 where maxrec(d3, size(lactic->list[d2.seq].olist, 5))
	and sepsis->plist[d1.seq].encntrid = lactic->list[d2.seq].encntrid
 
join d3 where lactic->list[d2.seq].olist[d3.seq].order_priority = sepsis->plist[d1.seq].tmp_pri + 1
	and sepsis->plist[d1.seq].tmp_pri > 0
	;.order_priority = 2 ;changed to above on 9/17/19 as per Lori's approval
 
join e where e.encntr_id = sepsis->plist[d1.seq].encntrid
 
order by e.encntr_id
 
Head e.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), e.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].repeat_lact_dt = lactic->list[d2.seq].olist[d3.seq].lact_collect_dt
	sepsis->plist[idx].repeat_lact_result = lactic->list[d2.seq].olist[d3.seq].lact_result
	sepsis->plist[idx].repeat_lact_order_dt = format(lactic->list[d2.seq].olist[d3.seq].lact_order_dt, 'mm/dd/yyyy hh:mm;;d')
	sepsis->plist[idx].repeat_lact_order_loc = lactic->list[d2.seq].olist[d3.seq].lact_order_loc
	sepsis->plist[idx].repeat_lact_order_pr = lactic->list[d2.seq].olist[d3.seq].lact_order_pr
	sepsis->plist[idx].repeat_lact_order_complete_loc = lactic->list[d2.seq].olist[d3.seq].lact_order_complete_loc
 
Foot e.encntr_id
	if(sepsis->plist[idx].sepsis_present_dt != 0.0)
		sepsis->plist[idx].repeat_lact_6hr_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].repeat_lact_dt), cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)
	elseif(sepsis->plist[idx].septic_present_dt != 0.0)
		sepsis->plist[idx].repeat_lact_6hr_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].repeat_lact_dt), cnvtdatetime(sepsis->plist[idx].septic_present_dt),3)
	endif
 
with nocounter
 
call echorecord(lactic)
 
;----------------------------------------------------------------------------------------------------------------
/*
;Get Initial lactate - logic before 04/29/2019
select distinct into 'nl:'
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(lactic->list, 5)))
	, encounter e
 
plan d
 
join e where e.encntr_id = sepsis->plist[d.seq].encntrid
 
join d1 where lactic->list[d1.seq].encntrid = e.encntr_id
	and lactic->list[d1.seq].order_priority = 1
 
order by e.encntr_id
 
 
Head e.encntr_id
      cnt = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), e.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].Ini_lact_collect_dt = lactic->list[d1.seq].lact_collect_dt
	sepsis->plist[idx].Ini_lact_result = lactic->list[d1.seq].lact_result
 
Foot e.encntr_id
	if(sepsis->plist[idx].sepsis_present_dt != 0.0)
		sepsis->plist[idx].ini_lact_3hr_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].ini_lact_collect_dt), cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)
	elseif(sepsis->plist[idx].septic_present_dt != 0.0)
		sepsis->plist[idx].ini_lact_3hr_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].ini_lact_collect_dt), cnvtdatetime(sepsis->plist[idx].septic_present_dt),3)
	endif
 
with nocounter
*/ ;logic before 04/29/2019
 
 
;-------------------------------- BLOOD CULTURE -----------------------------------------------------------------
;Blood Culture collection
 
select into 'nl:'
o.encntr_id, o.order_id, o.hna_order_mnemonic, o.last_action_sequence
, ori_ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_tag
;, drawn_dt = format(cte.drawn_dt_tm, 'mm/dd/yyyy hh:mm;;d')
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,orders o
	,(left join clinical_event ce on ce.order_id = o.order_id
		and ce.event_cd in(blood_cult_var, sep_blood_cult_var)
		and ce.result_status_cd in(25,34,35)
		and ce.view_level = 1
		and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			group by ce1.encntr_id, ce1.order_id))
 
 	, order_action oa
 	, order_action oa1
	;,order_serv_res_container osr
	;,container_event cte
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.catalog_cd in(ord_bld_cult_var, ord_sep_bld_cult_var)
	and o.active_ind = 1
	and o.order_status_cd = 2543.00 ;Completed
	and o.order_id = (select min(o1.order_id) from orders o1
				where o1.order_id = o.order_id and o1.catalog_cd = o.catalog_cd and o1.active_ind = 1
				group by o1.encntr_id, o1.order_id)
 
join ce
 
join oa where oa.order_id = o.order_id
	and oa.dept_status_cd = 9311.00 ;Collected
 
join oa1 where oa1.order_id = o.order_id
	and oa1.dept_status_cd = 9322.00 ;In-Lab - qualify In_lab status
 
/*join osr where osr.order_id = o.order_id
 
join cte where cte.container_id = osr.container_id
      and cte.event_type_cd = 1794.00 ;Collected
      and cte.event_sequence = (select min(cte1.event_sequence) from container_event cte1
      		where cte1.container_id = cte.container_id
      		and cte1.event_type_cd = cte.event_type_cd
      		group by cte1.container_id)*/
 
order by o.encntr_id, o.orig_order_dt_tm, o.order_id
 
Head report
	bcnt = 0
	call alterlist(bcult->list, 100)
Head o.encntr_id
	ocnt = 0
Head o.order_id
	 ocnt += 1
	 bcnt += 1
	 bcult->bcult_rec_cnt = bcnt
 	call alterlist(bcult->list, bcnt)
Detail
	bcult->list[bcnt].bcult_order_priority = ocnt
	bcult->list[bcnt].encntrid = o.encntr_id
	bcult->list[bcnt].bcult_order_id = o.order_id
	bcult->list[bcnt].bcult_order_mnemonic = trim(o.order_mnemonic)
	bcult->list[bcnt].bcult_order_dt = o.orig_order_dt_tm
	bcult->list[bcnt].bcult_collect_dt = oa.action_dt_tm;cte.drawn_dt_tm
	bcult->list[bcnt].bcult_result_dt = ce.event_end_dt_tm
	bcult->list[bcnt].bcult_order_complete_dt = oa.action_dt_tm ;cte.drawn_dt_tm
	if(trim(ce.result_val) != '')
		bcult->list[bcnt].bcult_result = trim(ce.result_val)
	else
		bcult->list[bcnt].bcult_result = trim(ce.event_tag)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Blood Culture - ordering provider
select into 'nl:'
 
from (dummyt d WITH seq = value(size(bcult->list,5)))
	,order_action oa
	,prsnl pr
 
plan d
 
join oa where oa.order_id = bcult->list[d.seq].bcult_order_id
	and oa.action_sequence = 1
 
join pr where pr.person_id = oa.order_provider_id
 
order by oa.order_id
 
Head oa.order_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bcult->list,5), oa.order_id, bcult->list[cnt].bcult_order_id)
	if(idx > 0)
		bcult->list[idx].bcult_order_pr = trim(pr.name_full_formatted)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Blood Culture - Patient location at time of order
select into 'nl:'
 
elh.encntr_id, ord_id = bcult->list[d.seq].bcult_order_id
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = value(size(bcult->list,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = bcult->list[d.seq].encntrid
	and bcult->list[d.seq].bcult_order_dt != 0
	and (cnvtdatetime(bcult->list[d.seq].bcult_order_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bcult->list,5), ord_id, bcult->list[cnt].bcult_order_id)
	if(idx > 0)
		bcult->list[idx].bcult_order_loc = order_pat_loc
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Blood Culture - Patient location at time of order complete
 
select into 'nl:'
 
elh.encntr_id, ord_id = bcult->list[d.seq].bcult_order_id
, order_complet_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = value(size(bcult->list,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = bcult->list[d.seq].encntrid
	and bcult->list[d.seq].bcult_order_complete_dt != 0
	and (cnvtdatetime(bcult->list[d.seq].bcult_order_complete_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bcult->list,5), ord_id, bcult->list[cnt].bcult_order_id)
	if(idx > 0)
		bcult->list[idx].bcult_order_complete_loc = order_complet_pat_loc
	endif
 
with nocounter
 
;call echorecord(bcult)
 
;--------------------------------------------------------------------------
;Assign Blood Culture results into Sepsis list
 
select into 'nl:'
 
enc = bcult->list[d1.seq].encntrid
 
from (dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 WITH seq = value(size(bcult->list,5)))
 
plan d
 
join d1 where bcult->list[d1.seq].encntrid = sepsis->plist[d.seq].encntrid
	and bcult->list[d1.seq].bcult_order_priority = 1
 
order by enc
 
Head enc
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), enc, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].bld_cult_collect_dt = bcult->list[d1.seq].bcult_collect_dt
	sepsis->plist[idx].bld_cult_result_dt = bcult->list[d1.seq].bcult_result_dt
	sepsis->plist[idx].bld_cult_result = bcult->list[d1.seq].bcult_result
	sepsis->plist[idx].bld_cult_order_dt = format(bcult->list[d1.seq].bcult_order_dt, 'mm/dd/yyyy hh:mm;;d')
	sepsis->plist[idx].bld_cult_order_pr = bcult->list[d1.seq].bcult_order_pr
	sepsis->plist[idx].bld_cult_order_loc = bcult->list[d1.seq].bcult_order_loc
	sepsis->plist[idx].bld_cult_order_complete_loc = bcult->list[d1.seq].bcult_order_complete_loc
 
Foot enc
	if(sepsis->plist[idx].sepsis_present_dt != 0.0)
		sepsis->plist[idx].bld_cult_colct_3hrs_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].bld_cult_collect_dt), cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)
	elseif(sepsis->plist[idx].septic_present_dt != 0.0)
		sepsis->plist[idx].bld_cult_colct_3hrs_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].bld_cult_collect_dt), cnvtdatetime(sepsis->plist[idx].septic_present_dt),3)
	endif
 
with nocounter
 
;----------------------------- CRYSTALLOID -------------------------------------------------------------------
 
;Crystalloid Fluids Master find *** this data not used since there is a difference in spec and class code data
 
select into 'nl:'
  mcdx.drug_identifier
  ,multum_category_id1 = dc1.multum_category_id ,
   parent_category = substring (1 ,50 ,dc1.category_name ) ,
   multum_category_id2 = dc2.multum_category_id ,
   sub_category = substring (1 ,50 ,dc2.category_name ) ,
   multum_category_id3 = dc3.multum_category_id ,
   sub_sub_category = substring (1 ,50 ,dc3.category_name )
 
from
	 mltm_category_drug_xref mcdx
	, mltm_drug_categories dc1
      , mltm_category_sub_xref dcs1
      , mltm_drug_categories dc2
	, mltm_category_sub_xref dcs2
      , mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id )))
	and dc1.multum_category_id = 115 ;nutritional products
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id and dc2.multum_category_id = 121 ;intravenous nutritional products
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id )
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
 
order by mcdx.drug_identifier
 
Head report
	lcnt = 0
	call alterlist(crys_master->list, 100)
 
Head mcdx.drug_identifier
	lcnt += 1
 	call alterlist(crys_master->list, lcnt)
Detail
	crys_master->list[lcnt].drug_identifier = mcdx.drug_identifier
	crys_master->list[lcnt].mltum_category_id1 = dc1.multum_category_id
	crys_master->list[lcnt].parent_category = parent_category
	crys_master->list[lcnt].mltum_category_id2 = dc2.multum_category_id
	crys_master->list[lcnt].sub_category = sub_category
	crys_master->list[lcnt].mltum_category_id3 = dc3.multum_category_id
	crys_master->list[lcnt].sub_sub_category = sub_sub_category
 
Foot report
  	call alterlist(crys_master->list, lcnt)
 
with nocounter
 
;call echorecord(crys_master)
 
;---------------------------------------------------------------------------------------------------------------------
;Crystalloid orders
 
select into 'nl:'
 
o.encntr_id, o.order_id, ce.event_id
,order_comp_dt = ce.event_end_dt_tm ; if(ce.event_start_dt_tm != 0) ce.event_start_dt_tm else ce.event_end_dt_tm endif
 
/*if(mae.beg_dt_tm != 0) mae.beg_dt_tm
	elseif(ce.event_start_dt_tm != 0) ce.event_start_dt_tm
	else ce.event_end_dt_tm
endif*/
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	, orders o
	, code_value cv1
	, clinical_event ce
	, med_admin_event mae
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.cki != ''
	and o.catalog_cd in(2778917.00, 2778889.00, 2778897.00, 2778811.00, 21268163.00, 187677209.00, 173223437.00, 24859265.00,
  				57527829.00, 2778899.00, 38238125.00, 2778895.00, 2778773.00, 2778783.00)
 
join cv1 where cv1.code_value = o.catalog_cd
	and cv1.code_set = 200
 	and cv1.data_status_cd = 25 ;Auth Verified
 
;Continus infusion need to pull very first instance
join ce where ce.order_id = o.order_id
	and trim(cnvtupper(ce.event_title_text)) not in('IVPARENT')
	and ce.result_status_cd in(25,34,35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
	and ce.publish_flag = 1
	and ce.event_tag_set_flag = 1
	and ce.event_end_dt_tm = (select min(ce1.event_end_dt_tm) from clinical_event ce1
		where ce1.order_id = ce.order_id
		group by ce1.encntr_id, ce1.order_id)
 
join mae where mae.event_id = outerjoin(ce.event_id)
 
order by o.encntr_id, order_comp_dt, o.order_id
 
Head report
	lcnt = 0
	call alterlist(crys->list, 100)
 
Head o.encntr_id
	ocnt = 0
Head o.order_id
	 ocnt += 1
	 lcnt += 1
	 crys->crys_rec_cnt = lcnt
 	call alterlist(crys->list, lcnt)
Detail
	crys->list[lcnt].encntrid = o.encntr_id
	crys->list[lcnt].event_id = ce.event_id
	;crys->list[lcnt].order_priority = ocnt
	crys->list[lcnt].crys_order_id = o.order_id
	crys->list[lcnt].crys_order_dt = o.orig_order_dt_tm
	crys->list[lcnt].order_mnemonic = o.hna_order_mnemonic
	crys->list[lcnt].event_end_dt = ce.event_end_dt_tm
 	crys->list[lcnt].crys_order_complete_dt = order_comp_dt
 
Foot o.order_id
 
 	call alterlist(crys->list, lcnt)
 
with nocounter
 
if(crys->crys_rec_cnt > 0)
 
;------------------------------------------------------------------------------------------------
; Crystalloid - ordering provider
select into 'nl:'
 
  encid = crys->list[d.seq].encntrid
 
from (dummyt d WITH seq = value(size(crys->list,5)))
	,order_action oa
	,prsnl pr
 
plan d
 
join oa where oa.order_id = crys->list[d.seq].crys_order_id
	and oa.action_sequence = 1
 
join pr where pr.person_id = oa.order_provider_id
 
order by oa.order_id
 
Head oa.order_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(crys->list,5), oa.order_id, crys->list[cnt].crys_order_id)
	if(idx > 0)
		crys->list[idx].crys_order_pr = trim(pr.name_full_formatted)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Crystalloid - Patient location at time of order
select into 'nl:'
 
elh.encntr_id, ord_id = crys->list[d.seq].crys_order_id
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = value(size(crys->list,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = crys->list[d.seq].encntrid
	and crys->list[d.seq].crys_order_dt != 0
	and (cnvtdatetime(crys->list[d.seq].crys_order_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(crys->list,5), ord_id, crys->list[cnt].crys_order_id)
	if(idx > 0)
		crys->list[idx].crys_order_loc = order_pat_loc
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Crystalloid - Patient location at time of order complete
 
select into 'nl:'
 
elh.encntr_id, ord_id = crys->list[d.seq].crys_order_id
, order_complet_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
 
from (dummyt d WITH seq = value(size(crys->list,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = crys->list[d.seq].encntrid
	and crys->list[d.seq].crys_order_complete_dt != 0
	and (cnvtdatetime(crys->list[d.seq].crys_order_complete_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(crys->list,5), ord_id, crys->list[cnt].crys_order_id)
	if(idx > 0)
		crys->list[idx].crys_order_complete_loc = order_complet_pat_loc
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Get Order Details for Crystalloid Fluids
select into 'nl:'
 
encntrid = crys->list[d.seq].encntrid
 
,ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
		over (partition by crys->list[d.seq].encntrid, od.order_id, od.oe_field_id)
 
from
	(dummyt d WITH seq = value(size(crys->list,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = crys->list[d.seq].crys_order_id
    and od.oe_field_id IN (volumedose_var ,volumedose_unit_var)
 
order by encntrid, od.order_id, od.oe_field_id
 
Head od.order_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(crys->list,5),od.order_id, crys->list[cnt].crys_order_id)
 	volume_dose = '', volume_dose_unit = ''
 
Head od.oe_field_id
	CASE (od.oe_field_id )
	     OF volumedose_var :
	     		volume_dose = replace(trim(ord,3),",","",2)
	     OF volumedose_unit_var :
     			volume_dose_unit = trim(ord,3)
	ENDCASE
 
Foot od.order_id
	while(idx > 0)
	     	crys->list[idx].volume = cnvtreal(volume_dose)
		crys->list[idx].volume_unit = volume_dose_unit
		idx = locateval(cnt,(idx+1),size(crys->list,5),od.order_id, crys->list[cnt].crys_order_id)
	endwhile
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Dosage info
select into 'nl:'
 
from
	(dummyt d with seq = value(size(crys->list, 5)))
	,ce_med_result cmr
 
plan d
 
join cmr where cmr.event_id = crys->list[d.seq].event_id
 
order by cmr.event_id
 
Head cmr.event_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(crys->list,5), cmr.event_id, crys->list[d.seq].event_id)
Detail
 	if(crys->list[idx].volume = 0.00)
	     	crys->list[idx].volume = cmr.admin_dosage
     	endif
	if(crys->list[idx].volume_unit = '') crys->list[idx].volume_unit = volume_dose_unit endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Assign order qualifier
 
select into 'nl:'
	encntrid = crys->list[d1.seq].encntrid
	, crys_order_id = crys->list[d1.seq].crys_order_id
	, volume = crys->list[d1.seq].volume
	, crys_order_mnemonic = crys->list[d1.seq].order_mnemonic
 
from
	(dummyt   d1  with seq = size(crys->list, 5))
 
plan d1 where trim(cnvtlower(crys->list[d1.seq].order_mnemonic)) = '*sodium chloride*'
	and (trim(cnvtlower(crys->list[d1.seq].order_mnemonic)) != 'sodium chloride 0.9% 1,000 mL'
		or trim(cnvtlower(crys->list[d1.seq].order_mnemonic)) != 'sodium chloride 0.9% 1000 mL')
	and (crys->list[d1.seq].volume != 0.00 and crys->list[d1.seq].volume < 1000.00)
 
order by encntrid, crys_order_id
 
Detail
	crys->list[d1.seq].crys_order_qualifier = 'NO'
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Assign order priority into Crys list
 
select into 'nl:'
	encntrid = crys->list[d1.seq].encntrid
	, crys_order_id = crys->list[d1.seq].crys_order_id
	, order_complete_dt = format(crys->list[d1.seq].crys_order_complete_dt, 'mm/dd/yyyy hh:mm;;d')
from
	(dummyt   d1  with seq = size(crys->list, 5))
 
plan d1 where crys->list[d1.seq].crys_order_qualifier = ''
 
order by encntrid, order_complete_dt, crys_order_id
 
Head encntrid
	ocnt = 0
Head crys_order_id
	ocnt += 1
	crys->list[d1.seq].order_priority = ocnt
 
with nocounter
 
;call echorecord(crys)
 
;------------------------------------------------------------------------------------------------
;Get initial Crystalloid administration info
 
select into 'nl:'
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(crys->list, 5)))
	, encounter e
 
plan d
 
join e where e.encntr_id = sepsis->plist[d.seq].encntrid
 
join d1 where crys->list[d1.seq].encntrid = e.encntr_id
	and crys->list[d1.seq].order_priority = 1
 
order by e.encntr_id
 
Head e.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), e.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].crys_fluid_dt = crys->list[d1.seq].crys_order_complete_dt
	sepsis->plist[idx].crys_fluid_name = trim(crys->list[d1.seq].order_mnemonic)
	sepsis->plist[idx].crys_order_pr = trim(crys->list[d1.seq].crys_order_pr)
	sepsis->plist[idx].crys_order_dt = format(crys->list[d1.seq].crys_order_dt, 'mm/dd/yyyy hh:mm;;d')
	sepsis->plist[idx].crys_order_loc = trim(crys->list[d1.seq].crys_order_loc)
	sepsis->plist[idx].crys_order_complete_loc = trim(crys->list[d1.seq].crys_order_complete_loc)
 
	if(crys->list[d1.seq].volume != 0.00)
		sepsis->plist[idx].crys_fluid_ml_admin = build2(trim(cnvtstring(crys->list[d1.seq].volume)),''
				,trim(crys->list[d1.seq].volume_unit))
	endif
 
 ;call echo(build('cluid = ',sepsis->plist[idx].crys_fluid_ml_admin))
 
Foot e.encntr_id
	if(sepsis->plist[idx].sepsis_present_dt != 0.0)
		sepsis->plist[idx].crys_fluid_3hrs_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].crys_fluid_dt), cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)
	elseif(sepsis->plist[idx].septic_present_dt != 0.0)
		sepsis->plist[idx].crys_fluid_3hrs_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].crys_fluid_dt), cnvtdatetime(sepsis->plist[idx].septic_present_dt),3)
	endif
 
with nocounter
 
endif ;crys_rec_cnt
 
 
;-------------------------------- ANTIBIOTICS  ----------------------------------------------------------------
;Get all Antibiotics from mltum
 
select into 'nl:'
 
  mcdx.drug_identifier
   ,multum_category_id1 = dc1.multum_category_id ,
   parent_category = substring (1 ,50 ,dc1.category_name ) ,
   multum_category_id2 = dc2.multum_category_id ,
   sub_category = substring (1 ,50 ,dc2.category_name ) ,
   multum_category_id3 = dc3.multum_category_id ,
   sub_sub_category = substring (1 ,50 ,dc3.category_name )
 
from
	 mltm_category_drug_xref mcdx
	, mltm_drug_categories dc1
      , mltm_category_sub_xref dcs1
      , mltm_drug_categories dc2
	, mltm_category_sub_xref dcs2
      , mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id )))
	and dc1.multum_category_id = 1 ;anti-infectives (antibiotics for sepsis)
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id )
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
 
order by mcdx.drug_identifier
 
Head report
	lcnt = 0
	call alterlist(antibio_master->list, 100)
 
Head mcdx.drug_identifier
	lcnt += 1
 	call alterlist(antibio_master->list, lcnt)
Detail
	antibio_master->list[lcnt].drug_identifier = mcdx.drug_identifier
	antibio_master->list[lcnt].mltum_category_id1 = dc1.multum_category_id
	antibio_master->list[lcnt].parent_category = parent_category
	antibio_master->list[lcnt].mltum_category_id2 = dc2.multum_category_id
	antibio_master->list[lcnt].sub_category = sub_category
	antibio_master->list[lcnt].mltum_category_id3 = dc3.multum_category_id
	antibio_master->list[lcnt].sub_sub_category = sub_sub_category
 
Foot report
  	call alterlist(antibio_master->list, lcnt)
 
with nocounter
 
;call echorecord(antibio)
 
;-----------------------------------------------------------------------------------------------
;Antibiotic lookup in Orders - dynamic list based on class code
select into 'nl:'
 
o.encntr_id, o.order_id, o.hna_order_mnemonic
,drug_id = antibio_master->list[d1.seq].drug_identifier
, med_admin_dt =
	if(mae.beg_dt_tm != 0) mae.beg_dt_tm
 		elseif(ce.event_start_dt_tm != 0) ce.event_start_dt_tm
 		else ce.event_end_dt_tm
	endif
 
 
,min_med_dt =  min(ce.event_end_dt_tm) keep (dense_rank first order by ce.event_end_dt_tm ASC)
		over (partition by ce.encntr_id, ce.order_id)
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(antibio_master->list, 5)))
	, orders o
	, clinical_event ce
	, med_admin_event mae
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.cki != ' '
 
join d1 where antibio_master->list[d1.seq].drug_identifier = trim(substring(( findstring("!" ,o.cki) + 1 ) ,textlen(o.cki) ,o.cki))
 
join ce where ce.order_id = o.order_id
	and ce.result_status_cd in(25,34,35)
      and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.task_assay_cd = 0
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 
join mae where mae.event_id = outerjoin(ce.event_id)
 
order by o.encntr_id, med_admin_dt, o.order_id
 
Head report
	lcnt = 0
	call alterlist(antibio->list, 100)
 
Head o.encntr_id
	lcnt += 1
 	antibio->anti_rec_cnt = lcnt
	call alterlist(antibio->list, lcnt)
	ocnt = 0
 
Head o.order_id
	ocnt += 1
  	call alterlist(antibio->list[lcnt].olist, ocnt)
Detail
	antibio->list[lcnt].olist[ocnt].order_priority = ocnt
	antibio->list[lcnt].olist[ocnt].anti_order_id = o.order_id
	antibio->list[lcnt].olist[ocnt].anti_order_dt = o.orig_order_dt_tm
	antibio->list[lcnt].olist[ocnt].drug_id = trim(substring(( findstring("!" ,o.cki) + 1 ) ,textlen(o.cki) ,o.cki))
	antibio->list[lcnt].olist[ocnt].anti_admin_dt  = med_admin_dt
	antibio->list[lcnt].olist[ocnt].anti_admin_dt_vc = format(med_admin_dt, 'mm/dd/yyyy hh:mm;;d')
	antibio->list[lcnt].olist[ocnt].antibio_name  = o.hna_order_mnemonic
	antibio->list[lcnt].olist[ocnt].anti_order_complete_dt = med_admin_dt
 
Foot o.encntr_id
	antibio->list[lcnt].encntrid = o.encntr_id
 	antibio->list[lcnt].enc_ord_cnt = ocnt
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Antibiotics - ordering provider
select into 'nl:'
	list_encntrid = antibio->list[d1.seq].encntrid
	, olist_anti_order_id = antibio->list[d1.seq].olist[d2.seq].anti_order_id
 
from	(dummyt   d1  with seq = size(antibio->list, 5))
	, (dummyt   d2  with seq = 1)
	, order_action oa
	, prsnl pr
 
plan d1 where maxrec(d2, size(antibio->list[d1.seq].olist, 5))
join d2
 
join oa where oa.order_id = antibio->list[d1.seq].olist[d2.seq].anti_order_id
	and oa.action_sequence = 1
 
join pr where pr.person_id = oa.order_provider_id
 
order by oa.order_id
 
Head oa.order_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(antibio->list,5), oa.order_id, antibio->list[d1.seq].olist[cnt].anti_order_id)
	if(idx > 0)
		antibio->list[d1.seq].olist[idx].anti_order_pr = trim(pr.name_full_formatted)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Antibiotics - Patient location at time of order
select into 'nl:'
 
elh.encntr_id, ord_id = antibio->list[d1.seq].olist[d2.seq].anti_order_id
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from	(dummyt   d1  with seq = size(antibio->list, 5))
	, (dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(antibio->list[d1.seq].olist, 5))
join d2
 
join elh where elh.encntr_id = antibio->list[d1.seq].encntrid
	and antibio->list[d1.seq].olist[d2.seq].anti_order_dt != 0
	and (cnvtdatetime(antibio->list[d1.seq].olist[d2.seq].anti_order_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(antibio->list,5), ord_id, antibio->list[d1.seq].olist[cnt].anti_order_id)
	if(idx > 0)
		antibio->list[d1.seq].olist[idx].anti_order_loc = order_pat_loc
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Antibiotics - Patient location at time of order complete
 
select into 'nl:'
 
elh.encntr_id, ord_id = antibio->list[d1.seq].olist[d2.seq].anti_order_id
, order_complet_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from	(dummyt   d1  with seq = size(antibio->list, 5))
	, (dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(antibio->list[d1.seq].olist, 5))
join d2
 
join elh where elh.encntr_id = antibio->list[d1.seq].encntrid
	and antibio->list[d1.seq].olist[d2.seq].anti_order_complete_dt != 0
	and (cnvtdatetime(antibio->list[d1.seq].olist[d2.seq].anti_order_complete_dt)
			between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(antibio->list,5), ord_id, antibio->list[d1.seq].olist[cnt].anti_order_id)
	if(idx > 0)
		antibio->list[d1.seq].olist[idx].anti_order_complete_loc = order_complet_pat_loc
	endif
 
with nocounter
 
;call echorecord(antibio)
 
 
;-----------------------------------------------------------------------------------------------
/* Antibiotics lookup in Orders - static list(3) - (some orders are premixed with additives/diluent so it may come with different
class code or drug_identifier that are not listed in the dynamic list) - wild card search with med name */
/****
 
Not completed 100% bcs noticed order exist with proper antibio name eventhough it is mixed with diluent. There are two orders in
clinical_event - 1)antibitics 2)diluent as a seperate order. ** need to add this section if above said is not the case **
Issue need to be fixed in this section : record structure showing orders under a wrong encntr_id
 
select distinct into 'nl:'
 
o.encntr_id, o.order_id, o.hna_order_mnemonic
,drug_id = antibio_master->list[d1.seq].drug_identifier
, med_admin_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
,min_med_dt =  min(ce.event_end_dt_tm) keep (dense_rank first order by ce.event_end_dt_tm ASC)
		over (partition by ce.encntr_id, ce.order_id)
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(cms->list, 5)))
	;,(dummyt d2 with seq = value(size(cms_comb_A->list, 5)))
	;,(dummyt d3 with seq = value(size(cms_comb_B->list, 5)))
	, orders o
	, clinical_event ce
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.cki != ' '
 
join d1 where findstring(cnvtlower(cms->list[d1.seq].med_col_a_name), cnvtlower(o.order_mnemonic)) >= 1
 
join ce where ce.order_id = o.order_id
	and ce.result_status_cd in(25,34,35)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
		and ce.result_status_cd in(25,34,35)
		and ce.view_level = 1
		group by ce.encntr_id, ce.event_id)
 
order by o.encntr_id, o.order_id, med_admin_dt
 
;with nocounter, separator=" ", format
 
;Append the list
Head o.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(antibio->list,5), o.encntr_id, antibio->list[cnt].encntrid)
 
Head o.order_id
      cnt1 = 0
      idx1 = 0
	idx1 = locateval(cnt,1,size(antibio->list->olist,5), o.order_id, antibio->list->olist[cnt1].anti_order_id)
	 if(idx1 = 0) ;order shouldn't exist
	 	if(idx = 0) ;encntr_id did not exist
	 		lcnt = antibio->anti_rec_cnt + 1
		      call alterlist(antibio->list, lcnt)
		      antibio->list[lcnt].encntrid = o.encntr_id
		      antibio->list[lcnt].test = 'here'
     	 		antibio->anti_rec_cnt = lcnt
			ocnt = 0
		else ;encntr_id exist
		      ocnt = antibio->list[idx].enc_ord_cnt
		endif
		ocnt += 1
	  	call alterlist(antibio->list[lcnt].olist, ocnt)
		antibio->list[lcnt].olist[ocnt].order_priority = ocnt
		antibio->list[lcnt].olist[ocnt].anti_order_id = o.order_id
		antibio->list[lcnt].olist[ocnt].anti_admin_dt  = ce.event_end_dt_tm
		antibio->list[lcnt].olist[ocnt].antibio_name  = build2('test - ',o.hna_order_mnemonic)
	endif
Foot o.encntr_id
	;antibio->list[lcnt].encntrid = o.encntr_id
 	antibio->list[lcnt].enc_ord_cnt = ocnt
 
with nocounter
 
call echorecord(antibio) *******/
 
;--------------------------------------Antibiotics To Sepsis ---------------------------------------------------------------------------------
 
;Assign antibiotics to sepsis list
 
if(antibio->anti_rec_cnt > 0)
 
;Look for Monotherapy medication in patients med admin list
select into 'nl:'
  enc = sepsis->plist[d1.seq].encntrid
,bld_cltr_rslt = sepsis->plist[d1.seq].bld_cult_result
,bld_cltr_rslt_dt = sepsis->plist[d1.seq].bld_cult_result_dt
,antibio_name = trim(substring(1, 100, antibio->list[d2.seq].olist[d3.seq].antibio_name))
,anti_admin_dt = format(antibio->list[d2.seq].olist[d3.seq].anti_admin_dt, 'mm/dd/yyyy hh:mm;;q')
,order_priority = antibio->list[d2.seq].olist[d3.seq].order_priority
,anti_order_id = antibio->list[d2.seq].olist[d3.seq].anti_order_id
 
from
	(dummyt d1 with seq = size(sepsis->plist, 5))
	, (dummyt d2 with seq = size(antibio->list, 5))
	, (dummyt d3 with seq = 1)
 
plan d1
join d2 where maxrec(d3, size(antibio->list[d2.seq].olist, 5))
	and sepsis->plist[d1.seq].encntrid = antibio->list[d2.seq].encntrid
join d3
 
order by enc, anti_admin_dt, anti_order_id
 
Head enc
	tmp24 = 0.00
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), enc, sepsis->plist[cnt].encntrid)
	anti_found_var = 0
 	anti_med_var = ''
 
	if(idx > 0)
	   	cms_size = size(cms->list, 5) ;Monotherapy medication list
		ord_cnt = antibio->list[d2.seq].enc_ord_cnt
		j = 1
		while(j <= ord_cnt)
			i = 1
			while(i <= cms_size)
				if(cnvtlower(cms->list[i].med_col_a_name) = cnvtlower(antibio->list[d2.seq].olist[j].antibio_name)
					/*;Med admin after blood culture collect
					and(antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].bld_cult_collect_dt
						and sepsis->plist[idx].bld_cult_collect_dt != null)*/
					;Med admin before sepsis time zero
					and(antibio->list[d2.seq].olist[j].anti_admin_dt < sepsis->plist[idx].sepsis_present_dt)
					;Med admin Prior 24 hrs of time zero
					and(datetimediff(cnvtdatetime(antibio->list[d2.seq].olist[j].anti_admin_dt)
						,cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)<= 24.00)
				  )
					  sepsis->plist[idx].antibiotic_mono = antibio->list[d2.seq].olist[j].antibio_name
					  sepsis->plist[idx].antibiotic_mono_dt = antibio->list[d2.seq].olist[j].anti_admin_dt_vc
					  sepsis->plist[idx].anti_mono_order_dt = format(antibio->list[d2.seq].olist[j].anti_order_dt
													,'mm/dd/yyyy hh:mm;;q')
					  sepsis->plist[idx].anti_mono_order_pr = antibio->list[d2.seq].olist[j].anti_order_pr
					  sepsis->plist[idx].anti_mono_order_loc = antibio->list[d2.seq].olist[j].anti_order_loc
					  sepsis->plist[idx].anti_mono_order_complete_loc = antibio->list[d2.seq].olist[j].anti_order_complete_loc
					  anti_found_var = 1
 
				elseif(cnvtlower(cms->list[i].med_col_a_name) = cnvtlower(antibio->list[d2.seq].olist[j].antibio_name)
					/*;Med admin after blood culture collect
					and(antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].bld_cult_collect_dt
								and sepsis->plist[idx].bld_cult_collect_dt != null)*/
					;Med admin after sepsis time zero
					and (antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].sepsis_present_dt)
					;Med admin after 3 hrs
					and(datetimediff(cnvtdatetime(antibio->list[d2.seq].olist[j].anti_admin_dt)
						,cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)<= 3.00)
					)
					  sepsis->plist[idx].antibiotic_mono = antibio->list[d2.seq].olist[j].antibio_name
					  sepsis->plist[idx].antibiotic_mono_dt = antibio->list[d2.seq].olist[j].anti_admin_dt_vc
					  sepsis->plist[idx].anti_mono_order_dt = format(antibio->list[d2.seq].olist[j].anti_order_dt
					  								,'mm/dd/yyyy hh:mm;;q')
					  sepsis->plist[idx].anti_mono_order_pr = antibio->list[d2.seq].olist[j].anti_order_pr
					  sepsis->plist[idx].anti_mono_order_loc = antibio->list[d2.seq].olist[j].anti_order_loc
					  sepsis->plist[idx].anti_mono_order_complete_loc = antibio->list[d2.seq].olist[j].anti_order_complete_loc
					  anti_found_var = 1
				endif
 
				if(anti_found_var = 1)
					i = cms_size + 1 ;exit i loop
					j = ord_cnt + 1 ;exit j loop
				else
					i += 1
				endif
			endwhile
			j += 1
		endwhile
	endif
 
With nocounter
;----------------------------------------------------------
; Look for Combination Therapy medication in patients med admin list - List A
 
select into 'nl:'
 enc = sepsis->plist[d1.seq].encntrid
,antibio_name = trim(substring(1, 100, antibio->list[d2.seq].olist[d3.seq].antibio_name))
,anti_admin_dt = format(antibio->list[d2.seq].olist[d3.seq].anti_admin_dt, 'mm/dd/yyyy hh:mm;;q')
,order_priority = antibio->list[d2.seq].olist[d3.seq].order_priority
,anti_order_id = antibio->list[d2.seq].olist[d3.seq].anti_order_id
 
from
	(dummyt d1 with seq = size(sepsis->plist, 5))
	, (dummyt d2 with seq = size(antibio->list, 5))
	, (dummyt d3 with seq = 1)
 
plan d1
join d2 where maxrec(d3, size(antibio->list[d2.seq].olist, 5))
	and sepsis->plist[d1.seq].encntrid = antibio->list[d2.seq].encntrid
join d3
 
order by enc, anti_admin_dt, anti_order_id
 
Head enc
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), enc, sepsis->plist[cnt].encntrid)
	anti_found_var = 0
 	anti_med_var = ''
 
	if(idx > 0)
		;loop thru list 2 col A - combination therapy - A
	   	cms_size = size(cms_comb_A->list, 5)
		ord_cnt = antibio->list[d2.seq].enc_ord_cnt
		j = 1
		while(j <= ord_cnt)
			i = 1
			while(i <= cms_size)
				if(cnvtlower(cms_comb_A->list[i].med_col_a_name) = cnvtlower(antibio->list[d2.seq].olist[j].antibio_name)
					/*;Med admin after blood culture collect
					and(antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].bld_cult_collect_dt
							and sepsis->plist[idx].bld_cult_collect_dt != null)*/
					;Med admin before sepsis time zero
					and(antibio->list[d2.seq].olist[j].anti_admin_dt < sepsis->plist[idx].sepsis_present_dt)
					;Med admin Prior 24 hrs of time zero
					and(datetimediff(cnvtdatetime(antibio->list[d2.seq].olist[j].anti_admin_dt)
						,cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)<= 24.00)
				  )
					  sepsis->plist[idx].antibiotic_combination_a = antibio->list[d2.seq].olist[j].antibio_name
					  sepsis->plist[idx].antibiotic_combination_a_dt = antibio->list[d2.seq].olist[j].anti_admin_dt_vc
  					  sepsis->plist[idx].anti_combA_order_dt = format(antibio->list[d2.seq].olist[j].anti_order_dt
  					  								,'mm/dd/yyyy hh:mm;;q')
					  sepsis->plist[idx].anti_combA_order_pr = antibio->list[d2.seq].olist[j].anti_order_pr
					  sepsis->plist[idx].anti_combA_order_loc = antibio->list[d2.seq].olist[j].anti_order_loc
					  sepsis->plist[idx].anti_combA_order_complete_loc = antibio->list[d2.seq].olist[j].anti_order_complete_loc
					  anti_found_var = 1
 
				elseif(cnvtlower(cms_comb_A->list[i].med_col_a_name) = cnvtlower(antibio->list[d2.seq].olist[j].antibio_name)
					/*;Med admin after blood culture collect
					and(antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].bld_cult_collect_dt
							and sepsis->plist[idx].bld_cult_collect_dt != null)*/
					;Med admin after sepsis time zero
					and (antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].sepsis_present_dt)
					;Med admin after 3 hrs
					and(datetimediff(cnvtdatetime(antibio->list[d2.seq].olist[j].anti_admin_dt)
						,cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)<= 3.00)
					)
					  sepsis->plist[idx].antibiotic_combination_a = antibio->list[d2.seq].olist[j].antibio_name
					  sepsis->plist[idx].antibiotic_combination_a_dt = antibio->list[d2.seq].olist[j].anti_admin_dt_vc
  					  sepsis->plist[idx].anti_combA_order_dt = format(antibio->list[d2.seq].olist[j].anti_order_dt
  					  								,'mm/dd/yyyy hh:mm;;q')
					  sepsis->plist[idx].anti_combA_order_pr = antibio->list[d2.seq].olist[j].anti_order_pr
					  sepsis->plist[idx].anti_combA_order_loc = antibio->list[d2.seq].olist[j].anti_order_loc
					  sepsis->plist[idx].anti_combA_order_complete_loc = antibio->list[d2.seq].olist[j].anti_order_complete_loc
 					  anti_found_var = 1
				endif
 
				if(anti_found_var = 1)
					i = cms_size + 1 ;exit i loop
					j = ord_cnt + 1 ;exit j loop
				else
					i += 1
				endif
			endwhile
			j += 1
		endwhile
	endif
 
With nocounter
 
;----------------------------------------------------------
; Look for Combination Therapy medication - list B
select into 'nl:'
 enc = sepsis->plist[d1.seq].encntrid
,antibio_name = trim(substring(1, 100, antibio->list[d2.seq].olist[d3.seq].antibio_name))
,anti_admin_dt = format(antibio->list[d2.seq].olist[d3.seq].anti_admin_dt, 'mm/dd/yyyy hh:mm;;q')
,order_priority = antibio->list[d2.seq].olist[d3.seq].order_priority
,anti_order_id = antibio->list[d2.seq].olist[d3.seq].anti_order_id
 
from
	(dummyt d1 with seq = size(sepsis->plist, 5))
	, (dummyt d2 with seq = size(antibio->list, 5))
	, (dummyt d3 with seq = 1)
 
plan d1
join d2 where maxrec(d3, size(antibio->list[d2.seq].olist, 5))
	and sepsis->plist[d1.seq].encntrid = antibio->list[d2.seq].encntrid
join d3
 
order by enc, anti_admin_dt, anti_order_id
 
Head enc
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), enc, sepsis->plist[cnt].encntrid)
	anti_found_var = 0
 	anti_med_var = ''
 
	if(idx > 0)
		;loop thru list 3 col B - combination therapy - B
	   	cms_size = size(cms_comb_B->list, 5)
		ord_cnt = antibio->list[d2.seq].enc_ord_cnt
		j = 1
		while(j <= ord_cnt)
			i = 1
			while(i <= cms_size)
				if(cnvtlower(cms_comb_B->list[i].med_col_b_name) = cnvtlower(antibio->list[d2.seq].olist[j].antibio_name)
					/*;Med admin after blood culture collect
					and(antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].bld_cult_collect_dt
						and sepsis->plist[idx].bld_cult_collect_dt != null)*/
					;Med admin before sepsis time zero
					and(antibio->list[d2.seq].olist[j].anti_admin_dt < sepsis->plist[idx].sepsis_present_dt)
					;Med admin Prior 24 hrs of time zero
					and(datetimediff(cnvtdatetime(antibio->list[d2.seq].olist[j].anti_admin_dt)
						,cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)<= 24.00)
				  )
					  sepsis->plist[idx].antibiotic_combination_b = antibio->list[d2.seq].olist[j].antibio_name
					  sepsis->plist[idx].antibiotic_combination_b_dt = antibio->list[d2.seq].olist[j].anti_admin_dt_vc
    					  sepsis->plist[idx].anti_combB_order_dt = format(antibio->list[d2.seq].olist[j].anti_order_dt
    					  									,'mm/dd/yyyy hh:mm;;q')
					  sepsis->plist[idx].anti_combB_order_pr = antibio->list[d2.seq].olist[j].anti_order_pr
					  sepsis->plist[idx].anti_combB_order_loc = antibio->list[d2.seq].olist[j].anti_order_loc
					  sepsis->plist[idx].anti_combB_order_complete_loc = antibio->list[d2.seq].olist[j].anti_order_complete_loc
					  anti_found_var = 1
 
				elseif(cnvtlower(cms_comb_B->list[i].med_col_b_name) = cnvtlower(antibio->list[d2.seq].olist[j].antibio_name)
					/*;Med admin after blood culture collect
					and(antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].bld_cult_collect_dt
							and sepsis->plist[idx].bld_cult_collect_dt != null)*/
					;Med admin after sepsis time zero
					and (antibio->list[d2.seq].olist[j].anti_admin_dt > sepsis->plist[idx].sepsis_present_dt)
					;Med admin after 3 hrs
					and(datetimediff(cnvtdatetime(antibio->list[d2.seq].olist[j].anti_admin_dt)
						,cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)<= 3.00)
					)
					  sepsis->plist[idx].antibiotic_combination_b = antibio->list[d2.seq].olist[j].antibio_name
					  sepsis->plist[idx].antibiotic_combination_b_dt = antibio->list[d2.seq].olist[j].anti_admin_dt_vc
     					  sepsis->plist[idx].anti_combB_order_dt = format(antibio->list[d2.seq].olist[j].anti_order_dt
     					  								,'mm/dd/yyyy hh:mm;;q')
					  sepsis->plist[idx].anti_combB_order_pr = antibio->list[d2.seq].olist[j].anti_order_pr
					  sepsis->plist[idx].anti_combB_order_loc = antibio->list[d2.seq].olist[j].anti_order_loc
					  sepsis->plist[idx].anti_combB_order_complete_loc = antibio->list[d2.seq].olist[j].anti_order_complete_loc
					  anti_found_var = 1
				endif
 
				if(anti_found_var = 1)
					i = cms_size + 1 ;exit i loop
					j = ord_cnt + 1 ;exit j loop
				else
					i += 1
				endif
			endwhile
			j += 1
		endwhile
	endif
 
With nocounter
 
endif ;anti_rec_cnt
 
;call echorecord(antibio)
 
;---------------------------  VASSOPRESSORS ---------------------------------------------------------------------
;vassopressors from mltum
 
select into 'nl:'
 
  mcdx.drug_identifier
   ,multum_category_id1 = dc1.multum_category_id ,
   parent_category = substring (1 ,50 ,dc1.category_name ) ,
   multum_category_id2 = dc2.multum_category_id ,
   sub_category = substring (1 ,50 ,dc2.category_name ) ,
   multum_category_id3 = dc3.multum_category_id ,
   sub_sub_category = substring (1 ,50 ,dc3.category_name )
 
from
	 mltm_category_drug_xref mcdx
	, mltm_drug_categories dc1
      , mltm_category_sub_xref dcs1
      , mltm_drug_categories dc2
	, mltm_category_sub_xref dcs2
      , mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id )))
	and dc1.multum_category_id = 40
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id and dc2.multum_category_id = 54
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id )
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
 
order by mcdx.drug_identifier
 
Head report
	lcnt = 0
	call alterlist(vaso_master->list, 100)
 
Head mcdx.drug_identifier
	lcnt += 1
 	call alterlist(vaso_master->list, lcnt)
Detail
	vaso_master->list[lcnt].drug_identifier = mcdx.drug_identifier
	vaso_master->list[lcnt].mltum_category_id1 = dc1.multum_category_id
	vaso_master->list[lcnt].parent_category = parent_category
	vaso_master->list[lcnt].mltum_category_id2 = dc2.multum_category_id
	vaso_master->list[lcnt].sub_category = sub_category
	vaso_master->list[lcnt].mltum_category_id3 = dc3.multum_category_id
	vaso_master->list[lcnt].sub_sub_category = sub_sub_category
 
Foot report
  	call alterlist(vaso_master->list, lcnt)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Vaso lookup in Orders with dynamic vaso list
select into 'nl:'
 
o.encntr_id, o.order_id, o.hna_order_mnemonic
,drug_id = vaso_master->list[d1.seq].drug_identifier
,cki = trim(substring(( findstring("!" ,o.cki) + 1 ) ,textlen(o.cki) ,o.cki))
,med_admin_dt = ce.event_end_dt_tm
 
/*if(mae.beg_dt_tm != 0) mae.beg_dt_tm
 		elseif(ce.event_start_dt_tm != 0) ce.event_start_dt_tm
 		else ce.event_end_dt_tm
 		endif*/
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(vaso_master->list, 5)))
	, orders o
	, clinical_event ce
	, med_admin_event mae
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.cki != ' '
 
join d1 where vaso_master->list[d1.seq].drug_identifier = trim(substring(( findstring("!" ,o.cki) + 1 ) ,textlen(o.cki) ,o.cki))
 
;Continus infusion need to pull very first instance
join ce where ce.order_id = o.order_id
	and trim(cnvtupper(ce.event_title_text)) not in('IVPARENT')
	and ce.result_status_cd in(25,34,35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
	and ce.publish_flag = 1
	and ce.event_tag_set_flag = 1
	and ce.event_end_dt_tm = (select min(ce1.event_end_dt_tm) from clinical_event ce1
		where ce1.order_id = ce.order_id
		group by ce1.encntr_id, ce1.order_id)
 
 
join mae where mae.event_id = outerjoin(ce.event_id)
 
order by o.encntr_id, med_admin_dt
 
Head report
	lcnt = 0
	call alterlist(vaso->list, 100)
 
Head o.encntr_id
	ocnt = 0
 
Head o.order_id
	 ocnt += 1
	 lcnt += 1
 	 vaso->vaso_rec_cnt = lcnt
 	call alterlist(vaso->list, lcnt)
Detail
	vaso->list[lcnt].encntrid = o.encntr_id
	;vaso->list[lcnt].order_priority = ocnt
	vaso->list[lcnt].vaso_order_id = o.order_id
	vaso->list[lcnt].vaso_order_dt = o.orig_order_dt_tm
	vaso->list[lcnt].event_end_dt = ce.event_end_dt_tm
	vaso->list[lcnt].order_mnemonic = o.hna_order_mnemonic
	vaso->list[lcnt].vaso_order_complete_dt = med_admin_dt
 
Foot o.order_id
  	call alterlist(vaso->list, lcnt)
 
with nocounter
 
;----------------------------------------------------------
/*Vaso lookup in Orders with static vaso list - (some orders are premixed with additives/diluent so it may come with different
class code or drug_identifier that are not listed in the dynamic list) - wild card search with med name*/
select into 'nl:'
 
o.encntr_id, o.order_id, o.hna_order_mnemonic
,drug_name = vaso_master_stat->list[d1.seq].med_name
,med_admin_dt = ce.event_end_dt_tm
/*if(mae.beg_dt_tm != 0) mae.beg_dt_tm
 		elseif(ce.event_start_dt_tm != 0) ce.event_start_dt_tm
 		else ce.event_end_dt_tm
 		endif*/
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(vaso_master_stat->list, 5)))
	, orders o
	, clinical_event ce
	, med_admin_event mae
 
plan d
 
join o where o.encntr_id = sepsis->plist[d.seq].encntrid
	and o.active_ind = 1
 
join d1 where findstring(cnvtlower(vaso_master_stat->list[d1.seq].med_name), cnvtlower(o.order_mnemonic)) >= 1
 
;Continus infusion need to pull very first instance
join ce where ce.order_id = o.order_id
	and trim(cnvtupper(ce.event_title_text)) not in('IVPARENT')
	and ce.result_status_cd in(25,34,35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
	and ce.publish_flag = 1
	and ce.event_tag_set_flag = 1
	and ce.event_end_dt_tm = (select min(ce1.event_end_dt_tm) from clinical_event ce1
		where ce1.order_id = ce.order_id
		group by ce1.encntr_id, ce1.order_id)
 
join mae where mae.event_id = outerjoin(ce.event_id)
 
order by o.encntr_id, o.order_id
 
;Append the list
Head o.order_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(vaso->list,5), o.order_id, vaso->list[cnt].vaso_order_id)
	 if(idx = 0) ;order shouldn't exist
		lcnt += 1
	 	vaso->vaso_rec_cnt = lcnt
	 	call alterlist(vaso->list, lcnt)
		vaso->list[lcnt].encntrid = o.encntr_id
		vaso->list[lcnt].vaso_order_id = o.order_id
		vaso->list[lcnt].vaso_order_dt = o.orig_order_dt_tm
		vaso->list[lcnt].event_end_dt = ce.event_end_dt_tm
		vaso->list[lcnt].vaso_order_complete_dt = med_admin_dt
		vaso->list[lcnt].order_mnemonic = drug_name ;o.hna_order_mnemonic
	 endif
Foot o.order_id
  	call alterlist(vaso->list, lcnt)
 
with nocounter
 
;-----------------------------------------------------------------
if(vaso->vaso_rec_cnt > 0)
;Assign order priority
select into 'nl:'
	encntrid = vaso->list[d1.seq].encntrid
	, vaso_order_id = vaso->list[d1.seq].vaso_order_id
	, order_mnemonic = trim(substring(1, 300, vaso->list[d1.seq].order_mnemonic))
	, order_priority = vaso->list[d1.seq].order_priority
	, order_complete_dt = format(vaso->list[d1.seq].vaso_order_complete_dt, 'mm/dd/yyyy hh:mm;;d')
from
	(dummyt   d1  with seq = size(vaso->list, 5))
 
plan d1
 
order by encntrid, order_complete_dt, vaso_order_id
 
Head vaso_order_id
	ocnt = 0
Detail
	ocnt += 1
	vaso->list[d1.seq].order_priority = ocnt
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Vasopressors - ordering provider
select into 'nl:'
 
  encid = vaso->list[d.seq].encntrid
 
from (dummyt d WITH seq = value(size(vaso->list,5)))
	,order_action oa
	,prsnl pr
 
plan d
 
join oa where oa.order_id = vaso->list[d.seq].vaso_order_id
	and oa.action_sequence = 1
 
join pr where pr.person_id = oa.order_provider_id
 
order by oa.order_id
 
Head oa.order_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(vaso->list,5), oa.order_id, vaso->list[cnt].vaso_order_id)
	if(idx > 0)
		vaso->list[idx].vaso_order_pr = trim(pr.name_full_formatted)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Vasopressors - Patient location at time of order
select into 'nl:'
 
elh.encntr_id, ord_id = vaso->list[d.seq].vaso_order_id
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = value(size(vaso->list,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = vaso->list[d.seq].encntrid
	and vaso->list[d.seq].vaso_order_dt != 0
	and (cnvtdatetime(vaso->list[d.seq].vaso_order_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(vaso->list,5), ord_id, vaso->list[cnt].vaso_order_id)
	if(idx > 0)
		vaso->list[idx].vaso_order_loc = order_pat_loc
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Vasopressors - Patient location at time of order complete
 
select into 'nl:'
 
elh.encntr_id, ord_id = vaso->list[d.seq].vaso_order_id
, order_complet_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
 
from (dummyt d WITH seq = value(size(vaso->list,5)))
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = vaso->list[d.seq].encntrid
	and vaso->list[d.seq].vaso_order_complete_dt != 0
	and (cnvtdatetime(vaso->list[d.seq].vaso_order_complete_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(vaso->list,5), ord_id, vaso->list[cnt].vaso_order_id)
	if(idx > 0)
		vaso->list[idx].vaso_order_complete_loc = order_complet_pat_loc
	endif
 
with nocounter
 
;call echorecord(vaso)
 
;------------------------------------------------------------------------------------------
 
;Assign Vasopressor to Sepsis list
select into 'nl:'
enc = sepsis->plist[d.seq].encntrid
 
from
	(dummyt d with seq = value(size(sepsis->plist, 5)))
	,(dummyt d1 with seq = value(size(vaso->list, 5)))
 
plan d
 
join d1 where vaso->list[d1.seq].encntrid = sepsis->plist[d.seq].encntrid
	and vaso->list[d1.seq].order_priority = 1
 
order by enc
 
Head enc
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), enc, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].vaso_admin_dt = vaso->list[d1.seq].vaso_order_complete_dt
	sepsis->plist[idx].vaso_name = vaso->list[d1.seq].order_mnemonic
	sepsis->plist[idx].vaso_order_dt = format(vaso->list[d1.seq].vaso_order_dt, 'mm/dd/yyyy hh:mm;;d')
	sepsis->plist[idx].vaso_order_pr = vaso->list[d1.seq].vaso_order_pr
	sepsis->plist[idx].vaso_order_loc = vaso->list[d1.seq].vaso_order_loc
	sepsis->plist[idx].vaso_order_complete_loc = vaso->list[d1.seq].vaso_order_complete_loc
 
Foot enc
	if(sepsis->plist[idx].sepsis_present_dt != 0.0)
		sepsis->plist[idx].vaso_admin_6hrs_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].vaso_admin_dt), cnvtdatetime(sepsis->plist[idx].sepsis_present_dt),3)
	elseif(sepsis->plist[idx].septic_present_dt != 0.0)
		sepsis->plist[idx].vaso_admin_6hrs_sep_presn =
		datetimediff(cnvtdatetime(sepsis->plist[idx].vaso_admin_dt), cnvtdatetime(sepsis->plist[idx].septic_present_dt),3)
	endif
 
With nocounter
 
endif ;vaso_rec_cnt
 
;-------------------------------------- Repeat Volume Status --------------------------------------------------------------------
;Repeat Volume Status
 
select into 'nl:' ;no data as of 2/20/19
 
;cov_tob_powerform_activity.prg
;select * from dcp_forms_ref dfr where dfr.dcp_forms_ref_id = 192588095.00 and dfr.active_ind = 1
;select * from dcp_forms_activity where dcp_forms_ref_id = 192588095.00
;event =  2563737601.00	QM Septic Shock Post Fluid Bolus Form
 
 
ce.person_id, ce.encntr_id, ce.result_val
 
from (dummyt d with seq = value(size(sepsis->plist, 5)))
	,dcp_forms_activity dfa
	,clinical_event ce
 
plan d
 
join dfa where dfa.person_id = sepsis->plist[d.seq].personid
	and dfa.encntr_id = sepsis->plist[d.seq].encntrid
 
join ce where ce.person_id = dfa.person_id
	and ce.encntr_id = dfa.encntr_id
	and ce.event_cd = 2563737601.00
	and cnvtlower(ce.result_val) = 'yes'
	 ;QM Septic Shock Post Fluid Bolus Form (QM Septic Shock Repeat Volume Status and Tissue Perfusion Assessment)
 
order by dfa.person_id, dfa.encntr_id
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120;, MAXREC = 10000
 
Head ce.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(sepsis->plist,5), ce.encntr_id, sepsis->plist[cnt].encntrid)
Detail
	sepsis->plist[idx].Septic_Shock_Repeat_Volume_Status = ce.result_val
 
With nocounter
 
;-----------------------------------------
call echorecord(sepsis)
;-----------------------------------------
 
 
/************** Ops Job *****************/
 
;if(iOpsInd = 1) ;Ops
  if($to_file = 0)  ;To File
 
   Select into value(filename_var)
 
	from (dummyt d WITH seq = value(size(sepsis->plist,5)))
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
			wrap3("Start dt")
			,wrap3("End dt")
			,wrap3("Facility Cd")
			,wrap3("nurse unit")
			,wrap3("Fin")
			,wrap3("MRN")
			,wrap3("order_id")
			,wrap3("Patient Name")
			,wrap3("ED Arriv dt")
  			,wrap3("ED Phys")
  			,wrap3("Attend Phys")
  			,wrap3("Hosp Phys Atrib")
  			,wrap3("ED LOS")
		  	,wrap3("Enc Tot LOS")
		  	,wrap3("ED Tri tm")
		  	,wrap3("ED nurse tri scrn")
		  	,wrap3("Seps advisor alrt dt")
		  	,wrap3("Seps qlty meas dt")
		  	,wrap3("Seps IP alrt dt")
		  	,wrap3("Seps ED alrt dt")
		  	,wrap3("Seps ED tri alrt dt")
		    	,wrap3("Phys Sep shock diag")
		    	,wrap3("Phys Sep diag dt")
		  	,wrap3("Src infec doc dt")
		  	,wrap3("sep pres dt")
		  	,wrap3("sept pres dt")
		  	,wrap3("Cmfrt meas dt")
		  	,wrap3("lactate_order_dt")
			,wrap3("lactate_order_provider")
			,wrap3("lactate_order_loc")
			,wrap3("lactate_order_complete_loc")
		  	,wrap3("Ini Lact col dt")
		  	,wrap3("Ini Lact rslt")
		  	,wrap3("Ini Lact col 3hr sep pres")
		  	,wrap3("blood_culture_order_dt")
			,wrap3("blood_culture_order_pr")
			,wrap3("blood_culture_order_loc")
			,wrap3("blood_culture_order_complete_loc")
		  	,wrap3("Bld cul col dt")
		  	,wrap3("Bld cul rslt")
		  	,wrap3("Bld cul col 3hr sep pres")
		  	,wrap3("Anti admin dt")
		  	,wrap3("Anti name")
		  	,wrap3("Anti admin 3hr sep pres")
		  	,wrap3("antibiotic_mono")
		  	,wrap3("anti_mono_order_dt")
			,wrap3("anti_mono_order_pr")
			,wrap3("anti_mono_order_loc")
			,wrap3("anti_mono_order_complete_loc")
			,wrap3("antibiotic_mono_dt")
			,wrap3("antibiotic_combination_a")
			,wrap3("anti_comb_a_order_dt")
			,wrap3("anti_comb_a_order_pr")
			,wrap3("anti_comb_a_order_loc")
			,wrap3("anti_comb_a_order_complete_loc")
			,wrap3("antibiotic_combination_a_dt")
			,wrap3("antibiotic_combination_b")
			,wrap3("anti_comb_b_order_dt")
			,wrap3("anti_comb_b_order_pr")
			,wrap3("anti_comb_b_order_loc")
			,wrap3("anti_comb_b_order_complete_loc")
			,wrap3("antibiotic_combination_b_dt")
			,wrap3("repeat_lactate_order_dt")
			,wrap3("repeat_lactate_order_provider")
			,wrap3("repeat_lactate_order_loc")
			,wrap3("repeat_lactate_order_complete_loc")
		  	,wrap3("Rep Lact col dt")
		  	,wrap3("Rep Lact rslt")
		  	,wrap3("Rep Lact 6hr sep pres")
		  	,wrap3("Crys fld dt")
		  	,wrap3("Crys fld admin amt")
		  	,wrap3("pat dosg wgt")
		  	,wrap3("Crys fld name")
		  	,wrap3("crystalloid_order_dt")
			,wrap3("crystalloid_order_provider")
			,wrap3("crystalloid_order_loc")
			,wrap3("crystalloid_complete_loc")
			,wrap3("Crys fld 3hr sep pres")
		  	,wrap3("Vaso admin dt")
		  	,wrap3("vasopressors_order_dt")
			,wrap3("vasopressors_order_provider")
			,wrap3("vasopressors_order_loc")
			,wrap3("vasopressors_order_complete_loc")
			,wrap3("Vaso name")
		  	,wrap3("Vaso admin 6hr sep pres")
		  	,wrap3("Shk hypo dt")
		  	,wrap3("Sept Shk Rep Vol St")
			,wrap3("patient_id")
			,wrap1("encounter_id") )
 
	col 0 file_header_var
	row + 1
 
 	Head d.seq
		output_orders = ""
		output_orders = build(output_orders
			,wrap3(format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].strata_facility_cd)
			,wrap3(sepsis->plist[d.seq].admit_nurse_unit)
			,wrap3(sepsis->plist[d.seq].fin)
			,wrap3(sepsis->plist[d.seq].mrn)
			,wrap3(cnvtstring(sepsis->plist[d.seq].orderid))
			,wrap3(sepsis->plist[d.seq].pat_name)
			,wrap3(sepsis->plist[d.seq].ed_arrival_dt)
			,wrap3(sepsis->plist[d.seq].ed_provider)
			,wrap3(sepsis->plist[d.seq].attending_phys)
			,wrap3(sepsis->plist[d.seq].physician_attribute)
			,wrap3(cnvtstring(sepsis->plist[d.seq].ed_los))
			,wrap3(cnvtstring(sepsis->plist[d.seq].los))
			,wrap3(sepsis->plist[d.seq].ed_triage_time)
			,wrap3(sepsis->plist[d.seq].ed_nurse_triage_screen)
			,wrap3(format(sepsis->plist[d.seq].sep_adviser_alert_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].sep_quality_meas_ord_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].sep_IP_alert_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].sep_ED_alert_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].sep_ED_triage_alert_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].provider_dignosis)
			,wrap3(format(sepsis->plist[d.seq].diagnosis_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].source_infect_doc_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].sepsis_present_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(sepsis->plist[d.seq].septic_present_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].comfort_meas_dt)
			,wrap3(sepsis->plist[d.seq].lact_order_dt)
			,wrap3(sepsis->plist[d.seq].lact_order_pr)
			,wrap3(sepsis->plist[d.seq].lact_order_loc)
			,wrap3(sepsis->plist[d.seq].lact_order_complete_loc)
			,wrap3(format(sepsis->plist[d.seq].ini_lact_collect_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(cnvtstring(sepsis->plist[d.seq].ini_lact_result,15,2))
			,wrap3(cnvtstring(sepsis->plist[d.seq].ini_lact_3hr_sep_presn, 15,2))
			,wrap3(sepsis->plist[d.seq].bld_cult_order_dt)
			,wrap3(sepsis->plist[d.seq].bld_cult_order_pr)
			,wrap3(sepsis->plist[d.seq].bld_cult_order_loc)
			,wrap3(sepsis->plist[d.seq].bld_cult_order_complete_loc)
			,wrap3(format(sepsis->plist[d.seq].bld_cult_collect_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].bld_cult_result)
			,wrap3(cnvtstring(sepsis->plist[d.seq].bld_cult_colct_3hrs_sep_presn,15,2))
			,wrap3(format(sepsis->plist[d.seq].antibio_admin_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].antibio_name)
			,wrap3(cnvtstring(sepsis->plist[d.seq].antibio_admin_3hrs_sep_presn,15,2))
			,wrap3(sepsis->plist[d.seq].antibiotic_mono)
			,wrap3(sepsis->plist[d.seq].anti_mono_order_dt)
			,wrap3(sepsis->plist[d.seq].anti_mono_order_pr)
			,wrap3(sepsis->plist[d.seq].anti_mono_order_loc)
			,wrap3(sepsis->plist[d.seq].anti_mono_order_complete_loc)
			,wrap3(sepsis->plist[d.seq].antibiotic_mono_dt)
			,wrap3(sepsis->plist[d.seq].antibiotic_combination_a)
			,wrap3(sepsis->plist[d.seq].anti_comba_order_dt)
			,wrap3(sepsis->plist[d.seq].anti_comba_order_pr)
			,wrap3(sepsis->plist[d.seq].anti_comba_order_loc)
			,wrap3(sepsis->plist[d.seq].anti_comba_order_complete_loc)
			,wrap3(sepsis->plist[d.seq].antibiotic_combination_a_dt)
			,wrap3(sepsis->plist[d.seq].antibiotic_combination_b)
			,wrap3(sepsis->plist[d.seq].anti_combb_order_dt)
			,wrap3(sepsis->plist[d.seq].anti_combb_order_pr)
			,wrap3(sepsis->plist[d.seq].anti_combb_order_loc)
			,wrap3(sepsis->plist[d.seq].anti_combb_order_complete_loc)
			,wrap3(sepsis->plist[d.seq].antibiotic_combination_b_dt)
			,wrap3(sepsis->plist[d.seq].repeat_lact_order_dt)
			,wrap3(sepsis->plist[d.seq].repeat_lact_order_pr)
			,wrap3(sepsis->plist[d.seq].repeat_lact_order_loc)
			,wrap3(sepsis->plist[d.seq].repeat_lact_order_complete_loc)
			,wrap3(format(sepsis->plist[d.seq].repeat_lact_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].repeat_lact_result)
			,wrap3(cnvtstring(sepsis->plist[d.seq].repeat_lact_6hr_sep_presn,15,2))
			,wrap3(format(sepsis->plist[d.seq].crys_fluid_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].crys_fluid_ml_admin)
			,wrap3(sepsis->plist[d.seq].pat_dosing_weight)
			,wrap3(sepsis->plist[d.seq].crys_fluid_name)
			,wrap3(sepsis->plist[d.seq].crys_order_dt)
			,wrap3(sepsis->plist[d.seq].crys_order_pr)
			,wrap3(sepsis->plist[d.seq].crys_order_loc)
			,wrap3(sepsis->plist[d.seq].crys_order_complete_loc)
			,wrap3(cnvtstring(sepsis->plist[d.seq].crys_fluid_3hrs_sep_presn,15,2))
			,wrap3(format(sepsis->plist[d.seq].vaso_admin_dt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(sepsis->plist[d.seq].vaso_order_dt)
			,wrap3(sepsis->plist[d.seq].vaso_order_pr)
			,wrap3(sepsis->plist[d.seq].vaso_order_loc)
			,wrap3(sepsis->plist[d.seq].vaso_order_complete_loc)
			,wrap3(sepsis->plist[d.seq].vaso_name)
			,wrap3(cnvtstring(sepsis->plist[d.seq].vaso_admin_6hrs_sep_presn,15,2))
			,wrap3(sepsis->plist[d.seq].sep_hypotension_dt)
			,wrap3(sepsis->plist[d.seq].Septic_Shock_Repeat_Volume_Status)
			,wrap3(cnvtstring(sepsis->plist[d.seq].personid))
			,wrap1(cnvtstring(sepsis->plist[d.seq].encntrid))  )
 
		output_orders = trim(output_orders, 3)
		output_orders = replace(replace(output_orders ,char(13)," "),char(10)," ")
 
	 Foot d.seq
	 	col 0 output_orders
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none;, maxrow = 0
 
	;Move file to Astream folder
  	;set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var) ;to move only in prod
  	set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var) ;to copy only for testing
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 
  endif ;To File
;endif ;ops
 
;---------------------------------------------------------------------------------------------------------------------
 
If($to_file = 1) ;Screen Display
 
SELECT DISTINCT INTO VALUE($OUTDEV)
	FACILITY = uar_get_code_display(SEPSIS->plist[D1.SEQ].facility)
	, FIN = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].fin))
	, MRN = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].mrn))
	, ENCNTRID = SEPSIS->plist[D1.SEQ].encntrid
	;, ORDERID = SEPSIS->plist[D1.SEQ].orderid
	, PATIENT_NAME = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].pat_name))
	, ADMIT_DATE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].reg_dt))
	, DISCHARGE_DATE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].disch_dt))
	, ED_ARRIVAL_DATE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].ed_checkin_dt))
	, PATIENT_ENCOUNTER_TYPE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].encntr_type))
	, ADMIT_NURSE_UNIT = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].admit_nurse_unit))
	, ED_PROVIDER = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].ed_provider))
	, ATTENDING_PROVIDER = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].attending_phys))
	, HOSPITAL_PHYSICIAN_ATTRIBUTE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].physician_attribute))
	, ED_LOS = SEPSIS->plist[D1.SEQ].ed_los
	, ENCOUNTER_TOTAL_LOS = SEPSIS->plist[D1.SEQ].los
	, ED_TRIAGE_TIME = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].ed_triage_time))
	, ED_NURSE_TRIAGE_SCREEN = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].ed_nurse_triage_screen))
	, SEPSIS_ADVISER_ALERT_FIRED_DATE = format(SEPSIS->plist[D1.SEQ].sep_adviser_alert_dt, 'mm/dd/yyyy hh:mm;;d')
	, SEPSIS_QUALITY_MEASURE_ORDER_DATE = format(SEPSIS->plist[D1.SEQ].sep_quality_meas_ord_dt, 'mm/dd/yyyy hh:mm;;d')
	, SEPSIS_IP_ALERT_DATE = format(SEPSIS->plist[D1.SEQ].sep_IP_alert_dt, 'mm/dd/yyyy hh:mm;;d')
	, SEPSIS_ED_ALERT_DATE = format(SEPSIS->plist[D1.SEQ].sep_ED_alert_dt, 'mm/dd/yyyy hh:mm;;d')
	, SEPSIS_ED_TRIAGE_ALERT_DATE = format(SEPSIS->plist[D1.SEQ].sep_ED_triage_alert_dt, 'mm/dd/yyyy hh:mm;;d')
	, PROVIDER_SEPSIS_SEPTICSHOCK_DIGNOSIS = trim(SUBSTRING(1, 100, SEPSIS->plist[D1.SEQ].provider_dignosis))
	, PROVIDER_DIGNOSIS_DT = format(SEPSIS->plist[D1.SEQ].diagnosis_dt, 'mm/dd/yyyy hh:mm;;d')
	, SOURCE_INFECTION_DOCUMENTED_DATE = format(SEPSIS->plist[D1.SEQ].source_infect_doc_dt, 'mm/dd/yyyy hh:mm;;d')
	, SEPSIS_PRESENTATION_DATE = format(SEPSIS->plist[D1.SEQ].sepsis_present_dt, 'mm/dd/yyyy hh:mm;;d')
	, SEVERE_SEPTIC_PRESENTATION_DATE = format(SEPSIS->plist[D1.SEQ].septic_present_dt, 'mm/dd/yyyy hh:mm;;d')
	, COMFORT_MEASURE_ORDER_DATE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].comfort_meas_dt))
	, INITIAL_LACTATE_order_dt = trim(substring(1,30, SEPSIS->plist[D1.SEQ].lact_order_dt))
	, INITIAL_LACTATE_order_provider = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].lact_order_pr))
	, INITIAL_LACTATE_order_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].lact_order_loc))
	, INITIAL_LACTATE_RESULT = SEPSIS->plist[D1.SEQ].ini_lact_result
	, INITIAL_LACTATE_COLLECTION_DATE = format(SEPSIS->plist[D1.SEQ].ini_lact_collect_dt, 'mm/dd/yyyy hh:mm;;d')
	, INITIAL_LACTATE_order_complete_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].lact_order_complete_loc))
	, INITIAL_LACTATE_COLLECTED_WITHIN_3HRS_OF_SEPSIS_PRESENTATION = SEPSIS->plist[D1.SEQ].ini_lact_3hr_sep_presn
	, REPEAT_LACTATE_order_dt = trim(substring(1,30, SEPSIS->plist[D1.SEQ].repeat_lact_order_dt))
	, REPEAT_LACTATE_order_provider = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].repeat_lact_order_pr))
	, REPEAT_LACTATE_order_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].repeat_lact_order_loc))
	, REPEAT_LACTATE_COLLECTION_DATE = format(SEPSIS->plist[D1.SEQ].repeat_lact_dt, 'mm/dd/yyyy hh:mm;;d')
	, REPEAT_LACTATE_RESULT = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].repeat_lact_result))
	, REPEAT_LACTATE_order_complete_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].repeat_lact_order_complete_loc))
	, REPEAT_LACTATE_WITHIN_6HRS_OF_SEPSIS_PRESENTATION = SEPSIS->plist[D1.SEQ].repeat_lact_6hr_sep_presn
	, BLOOD_CULTURE_ORDER_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].bld_cult_order_dt)
	, BLOOD_CULTURE_ORDER_PR = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].bld_cult_order_pr)
	, BLOOD_CULTURE_ORDER_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].bld_cult_order_loc)
	, BLOOD_CULTURE_COLLECTED_DATE = format(SEPSIS->plist[D1.SEQ].bld_cult_collect_dt, 'mm/dd/yyyy hh:mm;;d')
	, BLOOD_CULTURE_RESULT = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].bld_cult_result))
	, BLOOD_CULTURE_RESULT_dt = format(SEPSIS->plist[D1.SEQ].bld_cult_result_dt, 'mm/dd/yyyy hh:mm;;d')
	, BLOOD_CULTURE_ORDER_COMPLETE_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].bld_cult_order_complete_loc)
	, BLOOD_CULTURE_COLLECTED_WITHIN_3HRS_OF_SEPSIS_PRESENTATION = SEPSIS->plist[D1.SEQ].bld_cult_colct_3hrs_sep_presn
	;, ANTIBIOTICS_ADMINISTRATION_DATE = format(SEPSIS->plist[D1.SEQ].antibio_admin_dt, 'mm/dd/yyyy hh:mm;;d')
	;, ANTIBIOTICS_NAME = trim(SUBSTRING(1, 300, SEPSIS->plist[D1.SEQ].antibio_name))
	;, ANTIBIOTICS_ADMIN_WITHIN_3HRS_SEPSIS_PRESENTATION = SEPSIS->plist[D1.SEQ].antibio_admin_3hrs_sep_presn
	;, ANTIBIOTIC_NON_CMS = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_non_cms);do not have query
	;, ANTIBIOTIC_NON_CMS_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_non_cms_dt);do not have query
	, ANTIBIOTIC_MONO = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_mono)
	, ANTI_MONO_ORDER_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_mono_order_dt)
	, ANTI_MONO_ORDER_PR = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_mono_order_pr)
	, ANTI_MONO_ORDER_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_mono_order_loc)
	, ANTIBIOTIC_MONO_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_mono_dt)
	, ANTI_MONO_ORDER_COMPLETE_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_mono_order_complete_loc)
	, ANTIBIOTIC_COMBINATION_A = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_combination_a)
	, ANTI_COMB_A_ORDER_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combA_order_dt)
	, ANTI_COMB_A_ORDER_PR = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combA_order_pr)
	, ANTI_COMB_A_ORDER_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combA_order_loc)
	, ANTIBIOTIC_COMBINATION_A_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_combination_a_dt)
	, ANTI_COMB_A_ORDER_COMPLETE_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combA_order_complete_loc)
	, ANTIBIOTIC_COMBINATION_B = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_combination_b)
	, ANTI_COMB_B_ORDER_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combB_order_dt)
	, ANTI_COMB_B_ORDER_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combB_order_loc)
	, ANTI_COMB_B_ORDER_PR = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combB_order_pr)
	, ANTIBIOTIC_COMBINATION_B_DT = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].antibiotic_combination_b_dt)
	, ANTI_COMB_B_ORDER_COMPLETE_LOC = SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].anti_combB_order_complete_loc)
	, Crystalloid_FLUID_NAME = trim(SUBSTRING(1, 300, SEPSIS->plist[D1.SEQ].crys_fluid_name))
	, Crystalloid_FLUID_ADMINISTERED_AMOUNT = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].crys_fluid_ml_admin))
	, Crystalloid_order_provider = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].crys_order_pr))
	, Crystalloid_order_dt = trim(substring(1,30, SEPSIS->plist[D1.SEQ].crys_order_dt))
	, Crystalloid_order_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].crys_order_loc))
	, Crystalloid_FLUID_DATE = format(SEPSIS->plist[D1.SEQ].crys_fluid_dt, 'mm/dd/yyyy hh:mm;;d')
	, Crystalloid_complete_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].crys_order_complete_loc))
	, Crystalloid_FLUID_WITHIN_3HRS_SEPSIS_PRESENTATION = SEPSIS->plist[D1.SEQ].crys_fluid_3hrs_sep_presn
	, PATIENT_DOSING_WEIGHT = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].pat_dosing_weight))
	, VASOPRESSORS_NAME = trim(SUBSTRING(1, 300, SEPSIS->plist[D1.SEQ].vaso_name))
	, VASOPRESSORS_order_provider = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].vaso_order_pr))
	, VASOPRESSORS_order_dt = trim(substring(1,30, SEPSIS->plist[D1.SEQ].vaso_order_dt))
	, VASOPRESSORS_order_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].vaso_order_loc))
	, VASOPRESSORS_ADMINISTRATION_DATE = format(SEPSIS->plist[D1.SEQ].vaso_admin_dt, 'mm/dd/yyyy hh:mm;;d')
	, VASOPRESSORS_order_complete_loc = trim(SUBSTRING(1, 50, SEPSIS->plist[D1.SEQ].vaso_order_complete_loc))
	, VASOPRESSORS_ADMIN_WITHIN_6HRS_SEPSIS_PRESENTATION = SEPSIS->plist[D1.SEQ].vaso_admin_6hrs_sep_presn
	, SHOCK_HYPOTENSION_ALERT_DATE = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].sep_hypotension_dt))
	, Septic_Shock_Repeat_Volume_Status = trim(SUBSTRING(1, 30, SEPSIS->plist[D1.SEQ].Septic_Shock_Repeat_Volume_Status))
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(SEPSIS->plist, 5))
 
PLAN D1
 
ORDER BY
	FACILITY
	, FIN
	, DISCHARGE_DATE
	, PATIENT_NAME
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
endif
 
endif ;rec_cnt
 
 
/*****************************************************************************
	;Subroutins
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 
 
 
;-------------------------------------------------------------------------------------------------
 
/*
 
**** Diagnosis Table ****
 
select N.SOURCE_STRING, n.SOURCE_IDENTIFIER from nomenclature n
where n.source_vocabulary_cd = 19350056.00	;ICD-10-CM
and cnvtlower(N.SOURCE_STRING) in(
'salmonella sepsis',
'anthrax sepsis',
'erysipelothrix sepsis',
'listerial sepsis',
'sepsis due to streptococcus, group a',
'sepsis due to streptococcus, group b',
'sepsis due to streptococcus pneumoniae',
'other streptococcal sepsis',
'streptococcal sepsis, unspecified',
'sepsis due to methicillin susceptible staphylococcus aureus',
'sepsis due to methicillin resistant staphylococcus aureus',
'sepsis due to other specified staphylococcus',
'sepsis due to unspecified staphylococcus',
'sepsis due to hemophilus influenzae',
'sepsis due to anaerobes',
'gram-negative sepsis, unspecified',
'sepsis due to escherichia coli [e. coli]',
'sepsis due to pseudomonas',
'sepsis due to serratia',
'other gram-negative sepsis',
'sepsis due to enterococcus',
'other specified sepsis',
'sepsis, unspecified organism',
'actinomycotic sepsis',
'gonococcal sepsis',
'severe sepsis without septic shock',
'severe sepsis with septic shock')
 
**************************************************************
4154123.00		Weight Dosing
274144103.00	Sepsis Quality Measures
2552493947.00	Severe Sepsis IP Alert
272717111.00	Severe Sepsis ED Alert
2559151171.00	ED Triage Sepsis Alert
271709609.00	Sepsis Advisor
2820591.00	      ED Triage Note
274144529.00	Reg Severe Sepsis Presentation Dt Tm
2557500017.00	Reg Septic Shock Presentation Dt Tm
2958523.00        Resuscitation Status/Medical Interventio
3976784.00        Comfort Measures
 
 
    2778917.00	sodium chloride 0.9%
    2778889.00	Dextrose 5% with Electrolytes (Isolyte P) intravenous soluti
    2778897.00	Dextrose 5% with Electrolytes (Isolyte S)
    2778811.00	Lactated Ringers Injection
   21268163.00	Premix Lactated Ringers
  187677209.00	thiamine in lactated ringers IV drip 100 mg/1000 mL
  173223437.00	LACTATED RINGERS 1000 ML J7120250
   24859265.00	Dextrose 5% in Lactated Ringers with potassium chloride 40 m
   57527829.00	00409-7953-09 LACTATED RINGERS 10
    2778899.00	dextrose 5% in lactated ringers
   38238125.00	heparin IV drip 1 unit/mL in Normosol-R
    2778895.00	Dextrose 5% with Electrolytes (Normosol R/Plasma-Lyte 148)
    2778773.00	Electrolyte Solution (Plasma-Lyte/Normosol-R/Isolyte S)
    2778783.00	Dextrose 5% with Electrolytes (Normosol-M/Plasma-Lyte 56) in
 
 */
 
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/02/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_mak_defic_by_phys_driver_2.prg
	Object name:		cov_mak_defic_by_phys_driver_2
	Request #:			8330
 
	Program purpose:	Lists deficiencies assigned to physicians, as well as
						non-deficiencies completed within a specified timeframe.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_mak_defic_by_phys_driver_2:dba go
create program cov_mak_defic_by_phys_driver_2:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"                  ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Physician(s)" = 0
	, "Latest Communication Type" = VALUE(0.0           )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 0 

with OUTDEV, ORGANIZATIONS, PHYSICIANS, COMM_TYPE, START_DATETIME, END_DATETIME, 
	REPORT_TYPE
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

declare getcaetdata((data = vc (ref))) = null with protect
declare getdatafromprompt((parameternumber = i1), (data = vc (ref))) = null with protect
declare fillqualwithfacilitynames((organizations = vc (ref))) = null with protect
declare himgetnamesfromtable((data = vc (ref)), (tablename = vc), (name = vc), (id = vc)) = null with protect
declare himrendernodatareport((datasize = i4), (outputdevice = vc)) = i1 with protect
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare stardoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))
declare orgdoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR"))
declare order_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER")), protect
declare dOTG_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG"))
declare dDOC_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC"))

declare pstatus_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 103, "PENDING"))
declare rstatus_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 103, "REQUESTED"))
declare cstatus_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 103, "COMPLETED"))
declare istatus_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 103, "INERROR"))

declare sign_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "SIGN"))
declare cosign_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "COSIGN"))
declare perform_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM"))
declare modify_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "MODIFY"))
declare transcribe_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "TRANSCRIBE"))

declare inerror_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 8, "INERROR"))
declare inerrornomut_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 8, "INERRNOMUT"))
declare inerrornoview_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 8, "INERRNOVIEW"))
declare authverified_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 8, "AUTHVERIFIED"))

declare i1multifacilitylogicind		= i1 with noconstant(0), protect
declare i2multifacilitylogicind		= i2 with noconstant(0), protect

declare continue_var			= i2 with noconstant(0)
  
declare physician_parser 		= vc with noconstant(" ")
declare op_comm_type_var		= vc with noconstant(" "), protect
declare op_report_type_var		= vc with noconstant(" "), protect
 

/**************************************************************
; DVDev Start Coding
**************************************************************/    
 
free record organizations
record organizations (
	1 qual [*]
		2 item_id = f8
		2 item_name = vc
)
with persistscript

free record physicians
record physicians (
	1 qual [*]
		2 item_id = f8
		2 item_name = vc
)
with persistscript

free record data
record data (
	1 qual [*]
		2 patient_name = c100
		2 patient_id = f8
		2 patient_type_cd = f8
		2 organization_name = c100
		2 organization_id = f8
		2 mrn = c20
		2 fin = c20
		2 physician_name = c100
		2 physician_id = f8
		2 encntr_id = f8
		2 chart_alloc_dt_tm = dq8
		2 chart_age = i4
		2 disch_dt_tm = dq8
		2 location = c40
		2 patient_abs_birth_dt_tm = dq8
		2 patient_active_ind = i2
		2 patient_active_status_cd = f8
		2 patient_active_status_dt_tm = dq8
		2 patient_active_status_prsnl_id = f8
		2 patient_archive_env_id = f8
		2 patient_archive_status_cd = f8
		2 patient_archive_status_dt_tm = dq8
		2 patient_autopsy_cd = f8
		2 patient_beg_effective_dt_tm = dq8
		2 patient_birth_dt_cd = f8
		2 patient_birth_dt_tm = dq8
		2 patient_birth_prec_flag = i2
		2 patient_birth_tz = i4
		2 patient_cause_of_death = c100
		2 patient_cause_of_death_cd = f8
		2 patient_citizenship_cd = f8
		2 patient_conception_dt_tm = dq8
		2 patient_confid_level_cd = f8
		2 patient_contributor_system_cd = f8
		2 patient_create_dt_tm = dq8
		2 patient_create_prsnl_id = f8
		2 patient_data_status_cd = f8
		2 patient_data_status_dt_tm = dq8
		2 patient_data_status_prsnl_id = f8
		2 patient_deceased_cd = f8
		2 patient_deceased_dt_tm = dq8
		2 patient_deceased_source_cd = f8
		2 patient_end_effective_dt_tm = dq8
		2 patient_ethnic_grp_cd = f8
		2 patient_ft_entity_id = f8
		2 patient_ft_entity_name = c32
		2 patient_language_cd = f8
		2 patient_language_dialect_cd = f8
		2 patient_last_accessed_dt_tm = dq8
		2 patient_last_encntr_dt_tm = dq8
		2 patient_marital_type_cd = f8
		2 patient_military_base_location = c100
		2 patient_military_rank_cd = f8
		2 patient_military_service_cd = f8
		2 patient_mother_maiden_name = c100
		2 patient_name_first = c200
		2 patient_name_first_key = c100
		2 patient_name_first_key_nls = c202
		2 patient_name_first_phonetic = c8
		2 patient_name_first_synonym_id = f8
		2 patient_name_full_formatted = c100
		2 patient_name_last = c200
		2 patient_name_last_key = c100
		2 patient_name_last_key_nls = c202
		2 patient_name_last_phonetic = c8
		2 patient_name_middle = c200
		2 patient_name_middle_key = c100
		2 patient_name_middle_key_nls = c202
		2 patient_name_phonetic = c8
		2 patient_nationality_cd = f8
		2 patient_next_restore_dt_tm = dq8
		2 patient_person_id = f8
		2 patient_person_type_cd = f8
		2 patient_race_cd = f8
		2 patient_religion_cd = f8
		2 patient_sex_age_change_ind = i2
		2 patient_sex_cd = f8
		2 patient_species_cd = f8
		2 patient_updt_dt_tm = dq8
		2 patient_updt_id = f8
		2 patient_updt_task = i4
		2 patient_vet_military_status_cd = f8
		2 patient_vip_cd = f8
		2 physician_active_ind = i2
		2 physician_active_status_cd = f8
		2 physician_active_status_dt_tm = dq8
		2 physician_active_status_prsnl_id = f8
		2 physician_beg_effective_dt_tm = dq8
		2 physician_contributor_system_cd = f8
		2 physician_create_dt_tm = dq8
		2 physician_create_prsnl_id = f8
		2 physician_data_status_cd = f8
		2 physician_data_status_dt_tm = dq8
		2 physician_data_status_prsnl_id = f8
		2 physician_email = c100
		2 physician_end_effective_dt_tm = dq8
		2 physician_ft_entity_id = f8
		2 physician_ft_entity_name = c32
		2 physician_name_first = c200
		2 physician_name_first_key = c100
		2 physician_name_first_key_nls = c202
		2 physician_name_full_formatted = c100
		2 physician_name_last = c200
		2 physician_name_last_key = c100
		2 physician_name_last_key_nls = c202
		2 physician_password = c100
		2 physician_person_id = f8
		2 physician_physician_ind = i2
		2 physician_physician_status_cd = f8
		2 physician_position_cd = f8
		2 physician_prim_assign_loc_cd = f8
		2 physician_prsnl_type_cd = f8
		2 physician_updt_dt_tm = dq8
		2 physician_updt_id = f8
		2 physician_updt_task = i4
		2 physician_username = c50
		2 physician_star_id = c20
		2 encntr_accommodation_cd = f8
		2 encntr_accommodation_reason_cd = f8
		2 encntr_accommodation_request_cd = f8
		2 encntr_accomp_by_cd = f8
		2 encntr_active_ind = i2
		2 encntr_active_status_cd = f8
		2 encntr_active_status_dt_tm = dq8
		2 encntr_active_status_prsnl_id = f8
		2 encntr_admit_mode_cd = f8
		2 encntr_admit_src_cd = f8
		2 encntr_admit_type_cd = f8
		2 encntr_admit_with_medication_cd = f8
		2 encntr_alc_decomp_dt_tm = dq8
		2 encntr_alc_reason_cd = f8
		2 encntr_alt_lvl_care_cd = f8
		2 encntr_alt_lvl_care_dt_tm = dq8
		2 encntr_ambulatory_cond_cd = f8
		2 encntr_archive_dt_tm_act = dq8
		2 encntr_archive_dt_tm_est = dq8
		2 encntr_arrive_dt_tm = dq8
		2 encntr_assign_to_loc_dt_tm = dq8
		2 encntr_bbd_procedure_cd = f8
		2 encntr_beg_effective_dt_tm = dq8
		2 encntr_chart_complete_dt_tm = dq8
		2 encntr_confid_level_cd = f8
		2 encntr_contract_status_cd = f8
		2 encntr_contributor_system_cd = f8
		2 encntr_courtesy_cd = f8
		2 encntr_create_dt_tm = dq8
		2 encntr_create_prsnl_id = f8
		2 encntr_data_status_cd = f8
		2 encntr_data_status_dt_tm = dq8
		2 encntr_data_status_prsnl_id = f8
		2 encntr_depart_dt_tm = dq8
		2 encntr_diet_type_cd = f8
		2 encntr_disch_disposition_cd = f8
		2 encntr_disch_dt_tm = dq8
		2 encntr_disch_to_loctn_cd = f8
		2 encntr_doc_rcvd_dt_tm = dq8
		2 encntr_encntr_class_cd = f8
		2 encntr_encntr_complete_dt_tm = dq8
		2 encntr_encntr_financial_id = f8
		2 encntr_encntr_id = f8
		2 encntr_encntr_status_cd = f8
		2 encntr_encntr_type_cd = f8
		2 encntr_encntr_type_class_cd = f8
		2 encntr_end_effective_dt_tm = dq8
		2 encntr_est_arrive_dt_tm = dq8
		2 encntr_est_depart_dt_tm = dq8
		2 encntr_est_length_of_stay = i4
		2 encntr_financial_class_cd = f8
		2 encntr_guarantor_type_cd = f8
		2 encntr_info_given_by = c100
		2 encntr_inpatient_admit_dt_tm = dq8
		2 encntr_isolation_cd = f8
		2 encntr_location_cd = f8
		2 encntr_loc_bed_cd = f8
		2 encntr_loc_building_cd = f8
		2 encntr_loc_facility_cd = f8
		2 encntr_loc_nurse_unit_cd = f8
		2 encntr_loc_room_cd = f8
		2 encntr_loc_temp_cd = f8
		2 encntr_med_service_cd = f8
		2 encntr_mental_category_cd = f8
		2 encntr_mental_health_dt_tm = dq8
		2 encntr_organization_id = f8
		2 encntr_parent_ret_criteria_id = f8
		2 encntr_patient_classification_cd = f8
		2 encntr_pa_current_status_cd = f8
		2 encntr_pa_current_status_dt_tm = dq8
		2 encntr_person_id = f8
		2 encntr_placement_auth_prsnl_id = f8
		2 encntr_preadmit_testing_cd = f8
		2 encntr_pre_reg_dt_tm = dq8
		2 encntr_pre_reg_prsnl_id = f8
		2 encntr_program_service_cd = f8
		2 encntr_psychiatric_status_cd = f8
		2 encntr_purge_dt_tm_act = dq8
		2 encntr_purge_dt_tm_est = dq8
		2 encntr_readmit_cd = f8
		2 encntr_reason_for_visit = c255
		2 encntr_referral_rcvd_dt_tm = dq8
		2 encntr_referring_comment = c100
		2 encntr_refer_facility_cd = f8
		2 encntr_region_cd = f8
		2 encntr_reg_dt_tm = dq8
		2 encntr_reg_prsnl_id = f8
		2 encntr_result_accumulation_dt_tm = dq8
		2 encntr_safekeeping_cd = f8
		2 encntr_security_access_cd = f8
		2 encntr_service_category_cd = f8
		2 encntr_sitter_required_cd = f8
		2 encntr_specialty_unit_cd = f8
		2 encntr_trauma_cd = f8
		2 encntr_trauma_dt_tm = dq8
		2 encntr_triage_cd = f8
		2 encntr_triage_dt_tm = dq8
		2 encntr_updt_dt_tm = dq8
		2 encntr_updt_id = f8
		2 encntr_updt_task = i4
		2 encntr_valuables_cd = f8
		2 encntr_vip_cd = f8
		2 encntr_visitor_status_cd = f8
		2 encntr_zero_balance_dt_tm = dq8
		2 encntr_mrn_active_ind = i2
		2 encntr_mrn_active_status_cd = f8
		2 encntr_mrn_active_status_dt_tm = dq8
		2 encntr_mrn_active_status_prsnl_id = f8
		2 encntr_mrn_alias = c20
		2 encntr_mrn_alias_pool_cd = f8
		2 encntr_mrn_assign_authority_sys_cd = f8
		2 encntr_mrn_beg_effective_dt_tm = dq8
		2 encntr_mrn_check_digit = i4
		2 encntr_mrn_check_digit_method_cd = f8
		2 encntr_mrn_contributor_system_cd = f8
		2 encntr_mrn_data_status_cd = f8
		2 encntr_mrn_data_status_dt_tm = dq8
		2 encntr_mrn_data_status_prsnl_id = f8
		2 encntr_mrn_encntr_alias_id = f8
		2 encntr_mrn_encntr_alias_type_cd = f8
		2 encntr_mrn_encntr_id = f8
		2 encntr_mrn_end_effective_dt_tm = dq8
		2 encntr_mrn_updt_dt_tm = dq8
		2 encntr_mrn_updt_id = f8
		2 encntr_mrn_updt_task = i4
		2 encntr_fin_active_ind = i2
		2 encntr_fin_active_status_cd = f8
		2 encntr_fin_active_status_dt_tm = dq8
		2 encntr_fin_active_status_prsnl_id = f8
		2 encntr_fin_alias = c20
		2 encntr_fin_alias_pool_cd = f8
		2 encntr_fin_assign_authority_sys_cd = f8
		2 encntr_fin_beg_effective_dt_tm = dq8
		2 encntr_fin_check_digit = i4
		2 encntr_fin_check_digit_method_cd = f8
		2 encntr_fin_contributor_system_cd = f8
		2 encntr_fin_data_status_cd = f8
		2 encntr_fin_data_status_dt_tm = dq8
		2 encntr_fin_data_status_prsnl_id = f8
		2 encntr_fin_encntr_alias_id = f8
		2 encntr_fin_encntr_alias_type_cd = f8
		2 encntr_fin_encntr_id = f8
		2 encntr_fin_end_effective_dt_tm = dq8
		2 encntr_fin_updt_dt_tm = dq8
		2 encntr_fin_updt_id = f8
		2 encntr_fin_updt_task = i4
		2 him_visit_abstract_complete_ind = i2
		2 him_visit_active_ind = i2
		2 him_visit_active_status_cd = f8
		2 him_visit_active_status_dt_tm = dq8
		2 him_visit_active_status_prsnl_id = f8
		2 him_visit_allocation_dt_flag = i2
		2 him_visit_allocation_dt_modifier = i4
		2 him_visit_allocation_dt_tm = dq8
		2 him_visit_beg_effective_dt_tm = dq8
		2 him_visit_chart_process_id = f8
		2 him_visit_chart_status_cd = f8
		2 him_visit_chart_status_dt_tm = dq8
		2 him_visit_encntr_id = f8
		2 him_visit_end_effective_dt_tm = dq8
		2 him_visit_person_id = f8
		2 him_visit_updt_dt_tm = dq8
		2 him_visit_updt_id = f8
		2 him_visit_updt_task = i4
		2 org_active_ind = i2
		2 org_active_status_cd = f8
		2 org_active_status_dt_tm = dq8
		2 org_active_status_prsnl_id = f8
		2 org_beg_effective_dt_tm = dq8
		2 org_contributor_source_cd = f8
		2 org_contributor_system_cd = f8
		2 org_data_status_cd = f8
		2 org_data_status_dt_tm = dq8
		2 org_data_status_prsnl_id = f8
		2 org_end_effective_dt_tm = dq8
		2 org_federal_tax_id_nbr = c100
		2 org_ft_entity_id = f8
		2 org_ft_entity_name = c32
		2 org_organization_id = f8
		2 org_org_class_cd = f8
		2 org_org_name = c100
		2 org_org_name_key = c100
		2 org_org_name_key_nls = c202
		2 org_org_status_cd = f8
		2 org_updt_dt_tm = dq8
		2 org_updt_id = f8
		2 org_updt_task = i4
		2 defic_qual [*]
			3 deficiency_name = c100
			3 status = c40
			3 alloc_dt_tm = dq8
			3 defic_age = f8
			3 event_id = f8
			3 order_id = f8
			3 action_sequence = i4
			3 deficiency_flag = i2
			3 otg_id = i2
			3 scanning_prsnl = c100
			3 scanning_prsnl_id = f8
			3 reject_prsnl = c100
			3 reject_reason = c255
			3 doc_qual [*]
				4 him_event_action_type_cd = f8
				4 him_event_action_status_cd = f8
				4 him_event_allocation_dt_tm = dq8
				4 him_event_beg_effective_dt_tm = dq8
				4 him_event_completed_dt_tm = dq8
				4 him_event_encntr_id = f8
				4 him_event_end_effective_dt_tm = dq8
				4 him_event_event_cd = f8
				4 him_event_event_id = f8
				4 him_event_him_event_allocation_id = f8
				4 him_event_prsnl_id = f8
				4 him_event_request_dt_tm = dq8
				4 him_event_updt_dt_tm = dq8
				4 him_event_updt_id = f8
				4 him_event_updt_task = f8
				4 him_event_active_status_cd = f8
				4 him_event_active_dt_tm = dq8
				4 him_event_active_ind = i2
				4 him_event_active_status_cd = f8
				4 him_event_active_status_prsnl_id = f8
				4 him_event_active_status_dt_tm = dq8
			3 order_qual [*]
				4 orders_active_ind = i4
				4 orders_active_status_cd = f8
				4 orders_active_status_dt_tm = dq8
				4 orders_active_status_prsnl_id = f8
				4 orders_activity_type_cd = f8
				4 orders_ad_hoc_order_flag = i4
				4 orders_catalog_cd = f8
				4 orders_catalog_type_cd = f8
				4 orders_cki = c255
				4 orders_clinical_display_line = c255
				4 orders_comment_type_mask = i4
				4 orders_constant_ind = i4
				4 orders_contributor_system_cd = f8
				4 orders_cs_flag = i4
				4 orders_cs_order_id = f8
				4 orders_current_start_dt_tm = dq8
				4 orders_current_start_tz = i4
				4 orders_dcp_clin_cat_cd = f8
				4 orders_dept_misc_line = c255
				4 orders_dept_status_cd = f8
				4 orders_discontinue_effective_dt_tm = dq8
				4 orders_discontinue_effective_tz = i4
				4 orders_discontinue_ind = i4
				4 orders_discontinue_type_cd = f8
				4 orders_encntr_financial_id = f8
				4 orders_encntr_id = f8
				4 orders_eso_new_order_ind = i4
				4 orders_frequency_id = f8
				4 orders_freq_type_flag = i4
				4 orders_group_order_flag = i4
				4 orders_group_order_id = f8
				4 orders_hide_flag = i4
				4 orders_hna_order_mnemonic = c100
				4 orders_incomplete_order_ind = i4
				4 orders_ingredient_ind = i4
				4 orders_interest_dt_tm = dq8
				4 orders_interval_ind = i4
				4 orders_iv_ind = i4
				4 orders_last_action_sequence = i4
				4 orders_last_core_action_sequence = i4
				4 orders_last_ingred_action_sequence = i4
				4 orders_last_update_provider_id = f8
				4 orders_latest_communication_type_cd = f8
				4 orders_latest_communication_type = c40
				4 orders_link_nbr = f8
				4 orders_link_order_flag = i4
				4 orders_link_order_id = f8
				4 orders_link_type_flag = i4
				4 orders_med_order_type_cd = f8
				4 orders_modified_start_dt_tm = dq8
				4 orders_need_doctor_cosign_ind = i4
				4 orders_need_nurse_review_ind = i4
				4 orders_need_physician_validate_ind = i4
				4 orders_need_rx_verify_ind = i4
				4 orders_oe_format_id = f8
				4 orders_orderable_type_flag = i4
				4 orders_ordered_as_mnemonic = c100				
				4 orders_order_action_dt_tm = dq8
				4 orders_order_age = f8				
				4 orders_order_comment_ind = i4
				4 orders_order_detail_display_line = c255
				4 orders_order_id = f8
				4 orders_order_mnemonic = c100
				4 orders_order_provider_id = f8
				4 orders_order_provider = c100
				4 orders_order_provider_position_cd = f8
				4 orders_order_status_cd = f8
				4 orders_orig_order_convs_seq = i4
				4 orders_orig_order_dt_tm = dq8
				4 orders_orig_order_tz = i4
				4 orders_orig_ord_as_flag = i4
				4 orders_override_flag = i4
				4 orders_pathway_catalog_id = f8
				4 orders_pathway_description = c100
				4 orders_person_id = f8
				4 orders_prn_ind = i4
				4 orders_product_id = f8
				4 orders_projected_stop_dt_tm = dq8
				4 orders_projected_stop_tz = i4
				4 orders_ref_text_mask = i4
				4 orders_remaining_dose_cnt = i4
				4 orders_resume_effective_dt_tm = dq8
				4 orders_resume_effective_tz = i4
				4 orders_resume_ind = i4
				4 orders_rx_mask = i4
				4 orders_sch_state_cd = f8
				4 orders_soft_stop_dt_tm = dq8
				4 orders_soft_stop_tz = i4
				4 orders_status_dt_tm = dq8
				4 orders_status_prsnl_id = f8
				4 orders_stop_type_cd = f8
				4 orders_suspend_effective_dt_tm = dq8
				4 orders_suspend_effective_tz = i4
				4 orders_suspend_ind = i4
				4 orders_synonym_id = f8
				4 orders_template_core_action_sequence = i4
				4 orders_template_order_flag = i4
				4 orders_template_order_id = f8
				4 orders_updt_dt_tm = dq8
				4 orders_updt_id = f8
				4 orders_updt_task = i4
				4 orders_valid_dose_dt_tm = dq8
				4 order_review_action_sequence = i4
				4 order_review_dept_cd = f8
				4 order_review_digital_signature_ident = c64
				4 order_review_location_cd = f8
				4 order_review_order_id = f8
				4 order_review_provider_id = f8
				4 order_review_proxy_personnel_id = f8
				4 order_review_proxy_reason_cd = f8
				4 order_review_reject_reason_cd = f8
				4 order_review_reviewed_status_flag = i2
				4 order_review_review_dt_tm = dq8
				4 order_review_review_personnel_id = f8
				4 order_review_review_reqd_ind = i2
				4 order_review_review_sequence = i4
				4 order_review_review_type_flag = i2
				4 order_review_review_tz = i4
				4 order_review_updt_dt_tm = dq8
				4 order_review_updt_id = f8
				4 order_review_updt_task = i4
				4 order_notif_action_sequence = i4
				4 order_notif_caused_by_flag = i2
				4 order_notif_from_prsnl_id = f8
				4 order_notif_notification_comment = c255
				4 order_notif_notification_dt_tm = dq8
				4 order_notif_notification_reason_cd = f8
				4 order_notif_notification_status_flag = i2
				4 order_notif_notification_type_flag = i2
				4 order_notif_notification_tz = i4
				4 order_notif_order_id = f8
				4 order_notif_order_notification_id = f8
				4 order_notif_parent_order_notification_id = f8
				4 order_notif_status_change_dt_tm = dq8
				4 order_notif_status_change_tz = i4
				4 order_notif_to_prsnl_id = f8
				4 order_notif_updt_dt_tm = dq8
				4 order_notif_updt_id = f8
				4 order_notif_updt_task = i4
	1 max_defic_qual_count = i4
)
with persistscript

free record data2
record data2 (
	1 qual [*]
		2 patient_name = c100
		2 patient_id = f8
		2 organization_name = c100
		2 organization_id = f8
		2 mrn = c20
		2 fin = c20
		2 encntr_id = f8
		2 encntr_type_cd = f8
		2 encntr_reg_dt_tm = dq8
		2 encntr_disch_dt_tm = dq8
		2 doc_qual [*]
			3 event_action_type_cd = f8
			3 event_action_status_cd = f8
			3 event_completed_dt_tm = dq8
			3 event_encntr_id = f8
			3 event_event_cd = f8
			3 event_event_id = f8
			3 event_physician_name = c100
			3 event_physician_person_id = f8
			3 event_physician_position_cd = f8
			3 event_physician_star_id = c20
			3 deficiency_name = c100
			3 status = c40
		2 order_qual [*]
			3 orders_catalog_cd = f8
			3 orders_catalog_type_cd = f8
			3 orders_current_start_dt_tm = dq8
			3 orders_encntr_id = f8
			3 orders_latest_communication_type_cd = f8
			3 orders_latest_communication_type = c40		
			3 orders_order_action_dt_tm = dq8
			3 orders_order_age = f8
			3 orders_order_id = f8
			3 orders_order_mnemonic = c100
			3 orders_order_provider_id = f8
			3 orders_order_provider = c100
			3 orders_order_provider_position_cd = f8
			3 orders_order_provider_star_id = c20
			3 orders_order_status_cd = f8
			3 orders_orig_order_dt_tm = dq8
			3 orders_pathway_catalog_id = f8
			3 orders_pathway_description = c100
			3 orders_person_id = f8
			3 orders_template_order_id = f8
			3 orders_updt_dt_tm = dq8
			3 orders_updt_id = f8
			3 order_notif_order_notification_id = f8
			3 deficiency_name = c100
			3 status = c40
)
with persistscript
 
 
/**************************************************************/
; select system paramter data
select into "nl:"
from
	HIM_SYSTEM_PARAMS h
where 
	h.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3)
	and h.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3)
	and h.active_ind = 1
    
head report
   i2multifacilitylogicind = h.facility_logic_ind
   
with nocounter
 
 
/**************************************************************/
; select security data      
if (i2multifacilitylogicind != 0)
	set i1multifacilitylogicind = 1
else
	select into "nl:"
		sec_ind = cnvtint(d.info_number)
	from
		DM_INFO d
	where 
		d.info_domain = "SECURITY"
		and d.info_name = "SEC_ORG_RELTN"

	detail
		i1multifacilitylogicind = sec_ind
	
	with nocounter

	if (i1multifacilitylogicind != 0)
		set i1multifacilitylogicind = 1
	endif
endif


 ; define operator for $REPORT_TYPE
if (substring(1, 1, reflect(parameter(parameter2($REPORT_TYPE), 0))) = "L") ; multiple values selected
    set op_report_type_var = "IN"
else ; single value selected
    set op_report_type_var = "="
endif
 
 
if (i1multifacilitylogicind)
	call getdatafromprompt(2, organizations)
	call himgetnamesfromtable(organizations, "organization", "org_name", "organization_id")
endif


;call echorecord(organizations)
 

; determine if processing CAET providers
if (operator(3, op_report_type_var, $REPORT_TYPE))
	if (parameter(parameter2($PHYSICIANS), 1) = 0.0) ; any selected
		; populate record structure with all CAET values
		call getcaetdata(physicians)
	else
		; populate record structure with selected CAET values
		call getdatafromprompt(3, physicians)
	endif
else
	; populate record structure with standard values
	call getdatafromprompt(3, physicians)
endif

call himgetnamesfromtable(physicians, "prsnl", "name_full_formatted", "person_id")


;call echorecord(physicians)


 ; define operator for $COMM_TYPE
if (substring(1, 1, reflect(parameter(parameter2($COMM_TYPE), 0))) = "L") ; multiple values selected
    set op_comm_type_var = "IN"
elseif (parameter(parameter2($COMM_TYPE), 1) = 0.0) ; any selected
    set op_comm_type_var = ">="
else ; single value selected
    set op_comm_type_var = "="
endif


/**************************************************************/ 
; select deficiency data
execute him_mak_defic_by_phys_driver
 
;if (himrendernodatareport(size(data->qual, 5), $OUTDEV))
;	return
;endif

;call echorecord(data)
 
 
/**************************************************************/ 
; select personnel alias data
select into "nl:"
	pa.alias
from 
	(dummyt d with seq = value(size(data->qual, 5)))
	, prsnl_alias pa
	
plan d 
where d.seq > 0

join pa 
where 
	pa.person_id = outerjoin(data->qual[d.seq]->physician_person_id)
	and pa.active_ind = outerjoin(1)
	and pa.alias_pool_cd = outerjoin(stardoc_var)
	and pa.prsnl_alias_type_cd = outerjoin(orgdoc_var)
	and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
	and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
      
detail
	data->qual[d.seq]->physician_star_id = pa.alias
 
with nocounter
 
 
/**************************************************************/ 
; select document data
select into "nl:"
from 
	(dummyt d with seq = value(size(data->qual, 5)))
	, (dummyt ddefic with seq = value(data->max_defic_qual_count))
	, ce_blob_result cbr
	
plan d 
where d.seq > 0

join ddefic 
where ddefic.seq <= size(data->qual[d.seq].defic_qual, 5)

join cbr 
where
	cbr.event_id = data->qual[d.seq]->defic_qual[ddefic.seq].event_id 
	and cbr.storage_cd = dOTG_var 
	and cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    
detail
	data->qual[d.seq]->defic_qual[ddefic.seq].otg_id = 1

with nocounter
 
 
/**************************************************************/ 
; select transcription data
select into "nl:"
from 
	(dummyt d with seq = value(size(data->qual, 5)))
	, (dummyt ddefic with seq = value(data->max_defic_qual_count))
	, ce_event_prsnl cbr
	, prsnl p
	
plan d 
where d.seq > 0

join ddefic 
where ddefic.seq <= size(data->qual[d.seq].defic_qual, 5)

join cbr 
where
	cbr.event_id = data->qual[d.seq]->defic_qual[ddefic.seq].event_id 
	and cbr.action_type_cd = value(uar_get_code_by("MEANING", 21, "TRANSCRIBE"))

join p 
where p.person_id = cbr.action_prsnl_id
	
order by
	cbr.event_id
	, cbr.action_dt_tm
	
head cbr.event_id
	data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl_id = cbr.action_prsnl_id
	data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl = p.name_full_formatted

with nocounter
 
 
/**************************************************************/ 
; select reject reason data
select into "nl:"
from 
	(dummyt d with seq = value(size(data->qual, 5)))
	, (dummyt ddefic with seq = value(data->max_defic_qual_count))
	, ce_event_prsnl cbr
	, prsnl p
	
plan d
where 
	d.seq > 0
	and data->qual[d.seq].physician_username = "HIMREFUSAL"
	
join ddefic 
where ddefic.seq <= size(data->qual[d.seq].defic_qual, 5)
	
join cbr 
where
	cbr.event_id = data->qual[d.seq]->defic_qual[ddefic.seq].event_id
	and cbr.request_prsnl_id > 0.0
	
join p
where 
	p.person_id = cbr.request_prsnl_id
	and p.physician_ind = 1
	
order by
	cbr.event_id
	, cbr.valid_until_dt_tm desc
	, cbr.valid_from_dt_tm desc
	
head cbr.event_id
	data->qual[d.seq]->defic_qual[ddefic.seq].reject_reason = cbr.request_comment
	data->qual[d.seq]->defic_qual[ddefic.seq].reject_prsnl = p.name_full_formatted

with nocounter
 
 
/**************************************************************/ 
; select reject reason data
select into "nl:"
from 
	(dummyt d1 with seq = value(size(data->qual, 5)))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, prsnl p
	
plan d1
where 
	maxrec(d2, size(data->qual[d1.seq].defic_qual, 5))
	and data->qual[d1.seq].physician_username = "HIMREFUSAL"
	
join d2 
where maxrec(d3, size(data->qual[d1.seq].defic_qual[d2.seq].order_qual, 5))
	
join d3

join p 
where p.person_id = data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].order_notif_from_prsnl_id
	
detail
	data->qual[d1.seq]->defic_qual[d2.seq].reject_reason =
		data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].order_notif_notification_comment
	
	data->qual[d1.seq]->defic_qual[d2.seq].reject_prsnl = p.name_full_formatted

with nocounter
 
 
/**************************************************************/ 
; select communication type data
select into "nl:"
from
	(dummyt d1 with seq = value(size(data->qual, 5)))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, orders o
	
plan d1	
where maxrec(d2, size(data->qual[d1.seq].defic_qual, 5))

join d2	
where maxrec(d3, size(data->qual[d1.seq].defic_qual[d2.seq].order_qual, 5))

join d3

join o 
where o.order_id = data->qual[d1.seq].defic_qual[d2.seq].order_id

detail
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_latest_communication_type_cd = 
		o.latest_communication_type_cd
		
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_latest_communication_type = 
		uar_get_code_display(o.latest_communication_type_cd)

with nocounter
 
 
/**************************************************************/ 
; select pathway data 
select into "nl:"
from
	(dummyt d1 with seq = value(size(data->qual, 5)))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, pathway_catalog pc
	
plan d1	
where maxrec(d2, size(data->qual[d1.seq].defic_qual, 5))
	
join d2	
where maxrec(d3, size(data->qual[d1.seq].defic_qual[d2.seq].order_qual, 5))
	
join d3

join pc	
where pc.pathway_catalog_id = data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_pathway_catalog_id
	
detail
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_pathway_description = pc.description

with nocounter
 
 
/**************************************************************/ 
; select order action data 
select into "nl:"
from
	(dummyt d1 with seq = value(size(data->qual, 5)))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, order_action oa
	, prsnl per_oa
	
plan d1	
where maxrec(d2, size(data->qual[d1.seq].defic_qual, 5))
	
join d2	
where maxrec(d3, size(data->qual[d1.seq].defic_qual[d2.seq].order_qual, 5))
	
join d3

join oa	
where 
	oa.order_id = data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_order_id
	and oa.action_type_cd = order_var
	and oa.action_sequence > 0
	
join per_oa
where per_oa.person_id = oa.order_provider_id
	
detail
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_order_provider_id = oa.order_provider_id
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_order_provider = per_oa.name_full_formatted	
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_order_provider_position_cd = per_oa.position_cd	
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_order_action_dt_tm = oa.action_dt_tm
	data->qual[d1.seq].defic_qual[d2.seq].order_qual[d3.seq].orders_order_age = datetimediff(sysdate, oa.action_dt_tm, 3)

with nocounter


/**************************************************************/
; declare variables for subsequent queries
declare mrn_var 					= f8 with constant(uar_get_code_by("MEANING", 319, "MRN")), protect
declare fin_var 					= f8 with constant(uar_get_code_by("MEANING", 319, "FIN NBR")), protect
declare inpatient_var 				= f8 with constant(uar_get_code_by("MEANING", 71, "INPATIENT")), protect
declare observation_var 			= f8 with constant(uar_get_code_by("MEANING", 71, "OBSERVATION")), protect
declare los_var						= i4 with constant(48), protect
 
declare template_flag_none 			= i2 with constant (0)
declare template_flag_template 		= i2 with constant (1)
declare review_type_flag_doctor		= i2 with constant (2)
declare review_sts_flag_noreview	= i2 with constant (0)
declare review_sts_flag_accepted 	= i2 with constant (1)
declare review_sts_flag_rejected 	= i2 with constant (2)
declare review_sts_flag_noneeded 	= i2 with constant (3)
declare review_sts_flag_supercd 	= i2 with constant (4)
declare review_sts_flag_reviewed 	= i2 with constant (5)
declare notif_sts_flag_pending 		= i2 with constant (1)
declare notif_sts_flag_complete 	= i2 with constant (2)
declare notif_sts_flag_refused 		= i2 with constant (3)
declare notif_sts_flag_forward 		= i2 with constant (4)
declare notif_sts_flag_admin 		= i2 with constant (5)
declare notif_sts_flag_notneeded 	= i2 with constant (6)
declare notif_type_flag_cosign 		= i2 with constant (2)

declare iloop 						= i2 with noconstant(0)
declare phys_cnt					= i4 with noconstant(0)
declare org_cnt 					= i4 with noconstant(0)
declare num							= i4 with noconstant(0)


set phys_cnt = size(physicians->qual, 5)
set org_cnt = size(organizations->qual, 5)


/**************************************************************/ 
; select inpatient/observation data
if (operator(1, op_report_type_var, $REPORT_TYPE))
	select into "nl:"
	from
		encounter e
		, organization org
		, person patient
		, encntr_alias ea_mrn
		, encntr_alias ea_fin
		, dummyt d
	 
	plan e
	where
		e.encntr_id > 0.0
		and e.encntr_type_cd in (inpatient_var, observation_var)
		and (
			e.reg_dt_tm between cnvtdatetime($START_DATETIME) and cnvtdatetime($END_DATETIME)		
			or e.disch_dt_tm between cnvtdatetime($START_DATETIME) and cnvtdatetime($END_DATETIME)
			or (
				e.reg_dt_tm <= cnvtdatetime($END_DATETIME)
				and nullval(e.disch_dt_tm, cnvtdatetime("31-DEC-2100 00:00:00")) = cnvtdatetime("31-DEC-2100 00:00:00")
			)
		)
		and (
			i1multifacilitylogicind = 0
			or expand(iloop, 1, org_cnt, e.organization_id, organizations->qual[iloop].item_id)
		)
		and e.beg_effective_dt_tm <= cnvtdatetime(curdate ,curtime3)
		and e.end_effective_dt_tm >= cnvtdatetime(curdate ,curtime3)
		and e.active_ind = 1
	
	join org
	where org.organization_id = e.organization_id
	
	join patient
	where patient.person_id = e.person_id
	
	join ea_mrn
	where 
		ea_mrn.encntr_alias_type_cd = outerjoin(mrn_var)
		and ea_mrn.encntr_id = outerjoin(e.encntr_id)
		and ea_mrn.active_ind = outerjoin(1)
	   
	join ea_fin
	where 
		ea_fin.encntr_alias_type_cd = outerjoin(fin_var)
		and ea_fin.encntr_id = outerjoin(e.encntr_id)
		and ea_fin.active_ind = outerjoin(1)
	    
	join d
	where	
		if (datetimediff(e.disch_dt_tm, e.reg_dt_tm, 3) = 0)
			datetimediff(cnvtdatetime(curdate, curtime), e.reg_dt_tm, 3)
		else
			datetimediff(e.disch_dt_tm, e.reg_dt_tm, 3)
		endif > los_var
		
	order by 
		e.encntr_id
		
	head report
		cnt = size(data2->qual, 5)
	
	head e.encntr_id
		cnt = cnt + 1
		
		call alterlist(data2->qual, cnt)
		
		data2->qual[cnt]->patient_name = patient.name_full_formatted
		data2->qual[cnt]->patient_id = patient.person_id
		data2->qual[cnt]->organization_name = org.org_name
		data2->qual[cnt]->organization_id = org.organization_id
		data2->qual[cnt]->mrn = cnvtalias(ea_mrn.alias, ea_mrn.alias_pool_cd)
		data2->qual[cnt]->fin = cnvtalias(ea_fin.alias, ea_fin.alias_pool_cd)
		data2->qual[cnt]->encntr_id = e.encntr_id
		data2->qual[cnt]->encntr_type_cd = e.encntr_type_cd
		data2->qual[cnt]->encntr_reg_dt_tm = e.reg_dt_tm
		data2->qual[cnt]->encntr_disch_dt_tm = e.disch_dt_tm
	 
	with nocounter

;	call echorecord(data2)
endif


/**************************************************************/ 
; select inpatient/observation non-deficiency document data
if (operator(1, op_report_type_var, $REPORT_TYPE))
	select into "nl:"
	from
		clinical_event ce
		, ce_event_prsnl cep
		, prsnl physician
		, prsnl_alias pa
		, encounter e
		, dummyt d
		
	plan ce
	where expand(num, 1, size(data2->qual, 5), ce.encntr_id, data2->qual[num].encntr_id)
		; progress notes
		and ce.event_cd in (
			select cv.code_value
			from code_value cv
			where
				cv.code_set = 72
				and cv.display_key in ("*PROG*NOTE")
				and cv.active_ind = 1
			order by
				cv.display
		)
	    and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	    and ce.result_status_cd = authverified_var
	
	join cep
	where cep.event_id = ce.event_id
		and cep.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	    and cep.action_type_cd in (sign_var)
		and cep.action_status_cd in (cstatus_var)
		and cep.action_prsnl_id > 0.0
	
	join physician
	where physician.person_id = cep.action_prsnl_id
	
	join pa 
	where 
		pa.person_id = outerjoin(physician.person_id)
		and pa.active_ind = outerjoin(1)
		and pa.alias_pool_cd = outerjoin(stardoc_var)
		and pa.prsnl_alias_type_cd = outerjoin(orgdoc_var)
		and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
		and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
		
	join e
	where
		e.encntr_id = ce.encntr_id
		
	join d
	where
		(
			; not discharged
			datetimediff(e.disch_dt_tm, e.reg_dt_tm, 3) = 0
			; look back 1 day from today
			and cep.valid_from_dt_tm between 
				cnvtlookbehind("1 D", cnvtdatetime(curdate, 000000))
				and cnvtlookbehind("1 D", cnvtdatetime(curdate, 235959))
		)
		or (
			; discharged
			datetimediff(e.disch_dt_tm, e.reg_dt_tm, 3) > 0
			; look back 1 day from discharge date
			and cep.valid_from_dt_tm between 
				cnvtdatetime(datetimefind(cnvtlookbehind("1 D", e.disch_dt_tm), "D", "B", "B"))
				and cnvtdatetime(datetimefind(cnvtlookbehind("1 D", e.disch_dt_tm), "D", "E", "E"))
		)
		
	order by
		ce.encntr_id
		, ce.event_id
		
	head report
		idx = 0
		
	head ce.encntr_id
		dcnt = 0
		
		idx = locateval(num, 1, size(data2->qual, 5), ce.encntr_id, data2->qual[num].encntr_id)
	
	detail
		dcnt = dcnt + 1
		
		call alterlist(data2->qual[idx]->doc_qual, dcnt)
		
		data2->qual[idx]->doc_qual[dcnt]->event_action_type_cd = cep.action_type_cd
		data2->qual[idx]->doc_qual[dcnt]->event_action_status_cd = cep.action_status_cd
		data2->qual[idx]->doc_qual[dcnt]->event_completed_dt_tm = cep.valid_from_dt_tm
		data2->qual[idx]->doc_qual[dcnt]->event_encntr_id = ce.encntr_id
		data2->qual[idx]->doc_qual[dcnt]->event_event_cd = ce.event_cd
		data2->qual[idx]->doc_qual[dcnt]->event_event_id = ce.event_id
		data2->qual[idx]->doc_qual[dcnt]->event_physician_name = physician.name_full_formatted
		data2->qual[idx]->doc_qual[dcnt]->event_physician_person_id = physician.person_id
		data2->qual[idx]->doc_qual[dcnt]->event_physician_position_cd = physician.position_cd
		data2->qual[idx]->doc_qual[dcnt]->event_physician_star_id = pa.alias
		data2->qual[idx]->doc_qual[dcnt]->deficiency_name = uar_get_code_display(ce.event_cd)
		data2->qual[idx]->doc_qual[dcnt]->status = uar_get_code_display(cep.action_type_cd)
		
	with nocounter

;	call echorecord(data2)
endif


/**************************************************************/ 
; select non-deficiency order data
if (operator(2, op_report_type_var, $REPORT_TYPE))
	if (phys_cnt = 0)
		set dummyt_count = 1
		set physician_parser = " "
	else
		set dummyt_count = phys_cnt
		set physician_parser = "o_n.to_prsnl_id = physicians->qual[d.seq].item_id and "
	endif

	set physician_parser = concat(physician_parser,
	  " o_n.notification_status_flag = notif_sts_flag_complete",
	  " and o_n.notification_type_flag = notif_type_flag_cosign")
 
 
	select into "nl:"
	from 
		(dummyt d with seq = dummyt_count)
		, order_notification o_n
		, order_review o_r
		, orders o
		, order_action oa
		, prsnl per_oa
		, pathway_catalog pc
		, encounter e
		, prsnl physician
		, prsnl_alias pa
		, organization org
		, person patient
		, encntr_alias ea_mrn
		, encntr_alias ea_fin
		, dm_flags dm
	
	plan d
	
	join o_n
	where 
		parser(physician_parser)
		and o_n.to_prsnl_id > 0.0
	
	join o_r
	where 
		o_r.order_id = o_n.order_id
		and o_r.action_sequence = o_n.action_sequence
		and o_r.review_type_flag = review_type_flag_doctor
		and o_r.reviewed_status_flag = review_sts_flag_accepted
	
	join o
	where 
		o.order_id = o_r.order_id
		and o.template_order_flag in (template_flag_none, template_flag_template)
		and o.need_doctor_cosign_ind > 0
		and operator(o.latest_communication_type_cd, op_comm_type_var, $COMM_TYPE)

	join oa	
	where 
		oa.order_id = o.order_id
		and oa.action_type_cd = order_var
		and oa.action_sequence > 0
		and oa.action_dt_tm between cnvtdatetime($START_DATETIME) and cnvtdatetime($END_DATETIME)
		
	join per_oa
	where per_oa.person_id = oa.order_provider_id
	
	join pc	
	where pc.pathway_catalog_id = o.pathway_catalog_id
	
	join e
	where 
		e.encntr_id = o.encntr_id
		and (
			i1multifacilitylogicind = 0
			or expand(iloop, 1, org_cnt, e.organization_id, organizations->qual[iloop].item_id)
		)
		and e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3)
		and e.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3)
		and e.active_ind = 1
	
	join physician
	where physician.person_id = o_n.to_prsnl_id
	
	join pa 
	where 
		pa.person_id = outerjoin(physician.person_id)
		and pa.active_ind = outerjoin(1)
		and pa.alias_pool_cd = outerjoin(stardoc_var)
		and pa.prsnl_alias_type_cd = outerjoin(orgdoc_var)
		and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
		and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))

	join org
	where org.organization_id = e.organization_id
	
	join patient
	where patient.person_id = e.person_id
	
	join ea_mrn
	where 
		ea_mrn.encntr_alias_type_cd = outerjoin(mrn_var)
		and ea_mrn.encntr_id = outerjoin(e.encntr_id)
		and ea_mrn.active_ind = outerjoin(1)
	   
	join ea_fin
	where 
		ea_fin.encntr_alias_type_cd = outerjoin(fin_var)
		and ea_fin.encntr_id = outerjoin(e.encntr_id)
		and ea_fin.active_ind = outerjoin(1)
	
	join dm
	where
		dm.flag_value = o_r.reviewed_status_flag
		and dm.table_name = "ORDER_REVIEW"
		and dm.column_name = "REVIEWED_STATUS_FLAG"
	
	order by 
		e.organization_id
		, o_n.to_prsnl_id
		, e.encntr_id
	
	head report
		cnt = size(data2->qual, 5)
		
	head e.encntr_id
		ocnt = 0
		
		cnt = cnt + 1
		
		call alterlist(data2->qual, cnt)
		
		data2->qual[cnt]->patient_name = patient.name_full_formatted
		data2->qual[cnt]->patient_id = patient.person_id
		data2->qual[cnt]->organization_name = org.org_name
		data2->qual[cnt]->organization_id = org.organization_id
		data2->qual[cnt]->mrn = cnvtalias(ea_mrn.alias, ea_mrn.alias_pool_cd)
		data2->qual[cnt]->fin = cnvtalias(ea_fin.alias, ea_fin.alias_pool_cd)
		data2->qual[cnt]->encntr_id = e.encntr_id
		data2->qual[cnt]->encntr_type_cd = e.encntr_type_cd
		data2->qual[cnt]->encntr_reg_dt_tm = e.reg_dt_tm
		data2->qual[cnt]->encntr_disch_dt_tm = e.disch_dt_tm

	detail
		ocnt = ocnt + 1
		
		call alterlist(data2->qual[cnt]->order_qual, ocnt)
		
		data2->qual[cnt]->order_qual[ocnt]->orders_catalog_cd = o.catalog_cd
		data2->qual[cnt]->order_qual[ocnt]->orders_catalog_type_cd = o.catalog_type_cd
		data2->qual[cnt]->order_qual[ocnt]->orders_current_start_dt_tm = o.current_start_dt_tm
		data2->qual[cnt]->order_qual[ocnt]->orders_encntr_id = o.encntr_id
		data2->qual[cnt]->order_qual[ocnt]->orders_latest_communication_type_cd = o.latest_communication_type_cd
		data2->qual[cnt]->order_qual[ocnt]->orders_latest_communication_type = uar_get_code_display(o.latest_communication_type_cd)
		data2->qual[cnt]->order_qual[ocnt]->orders_order_action_dt_tm = oa.action_dt_tm
		data2->qual[cnt]->order_qual[ocnt]->orders_order_age = datetimediff(o_r.review_dt_tm, oa.action_dt_tm, 3)
		data2->qual[cnt]->order_qual[ocnt]->orders_order_id = o.order_id
		data2->qual[cnt]->order_qual[ocnt]->orders_order_mnemonic = o.order_mnemonic
		data2->qual[cnt]->order_qual[ocnt]->orders_order_provider_id = oa.order_provider_id
		data2->qual[cnt]->order_qual[ocnt]->orders_order_provider = per_oa.name_full_formatted
		data2->qual[cnt]->order_qual[ocnt]->orders_order_provider_position_cd = per_oa.position_cd
		data2->qual[cnt]->order_qual[ocnt]->orders_order_provider_star_id = pa.alias
		data2->qual[cnt]->order_qual[ocnt]->orders_order_status_cd = o.order_status_cd
		data2->qual[cnt]->order_qual[ocnt]->orders_orig_order_dt_tm = o.orig_order_dt_tm
		data2->qual[cnt]->order_qual[ocnt]->orders_pathway_catalog_id = o.pathway_catalog_id
		data2->qual[cnt]->order_qual[ocnt]->orders_pathway_description = pc.description
		data2->qual[cnt]->order_qual[ocnt]->orders_person_id = o.person_id
		data2->qual[cnt]->order_qual[ocnt]->orders_template_order_id = o.template_order_id
		data2->qual[cnt]->order_qual[ocnt]->orders_updt_dt_tm = o.updt_dt_tm
		data2->qual[cnt]->order_qual[ocnt]->orders_updt_id = o.updt_id
		data2->qual[cnt]->order_qual[ocnt]->order_notif_order_notification_id = o_n.order_notification_id
		data2->qual[cnt]->order_qual[ocnt]->deficiency_name = o.hna_order_mnemonic
		data2->qual[cnt]->order_qual[ocnt]->status = substring(1, 40, dm.description)
	 
	with nocounter

	;call echorecord(data2)
endif


;call echorecord(data2)


if (himrendernodatareport(size(data->qual, 5), $OUTDEV) and 
	himrendernodatareport(size(data2->qual, 5), $OUTDEV))
	
	return
endif
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

subroutine getcaetdata(data)
	select into "nl:"
	from 
		CODE_VALUE cv
		
		, (inner join CODE_VALUE_EXTENSION cve on cve.code_set = cv.code_set
			and cve.code_value = cv.code_value
			and cve.field_name = "STAR_ID")
			
		, (inner join PRSNL_ALIAS pa on pa.alias = cve.field_value
			and pa.prsnl_alias_type_cd = orgdoc_var
			and pa.end_effective_dt_tm > sysdate
			and pa.active_ind = 1)			
	where 
		cv.code_set = 100506
		and cv.cdf_meaning = "CAET"
		and cv.active_ind = 1
		
	head report
		cnt = 0
		
	detail
		cnt = cnt + 1
		
		call alterlist(data->qual, cnt)
		
		data->qual[cnt].item_id = pa.person_id
		
	with nocounter
end
  
subroutine getdatafromprompt(parameternumber, data)
	set inputnum = parameternumber
	set ctype = reflect(parameter(inputnum, 0))
	set parnum = 0
	set nstop = cnvtint(substring(2, 19, ctype))

	if (nstop > 0)
		case (substring(1, 1, ctype))
			of "C" :
				set vcparameterdata = parameter(inputnum, parnum)
				
				if (vcparameterdata != "")
					set stat = alterlist(data->qual, 1)
					set data->qual[1].item_name = vcparameterdata
				endif
			of "F" :
				set f8parameterdata = parameter(inputnum, parnum)
				
				if (f8parameterdata != 0)
					set stat = alterlist(data->qual, 1)
					set data->qual[1].item_id = f8parameterdata
				endif
			of "I" :
				set i4parameterdata = parameter(inputnum, parnum)
				
				if (i4parameterdata != 0)
					set stat = alterlist(data->qual, 1)
					set data->qual[1].item_id = i4parameterdata
				endif
			of "L" :
				set stat = alterlist(data->qual, nstop)
				
				while (parnum < nstop)
					set parnum = (parnum + 1)
					set data->qual[parnum].item_id = parameter(inputnum, parnum)
				endwhile
			else
				set nothing = null
		endcase
	endif
end

subroutine fillqualwithfacilitynames(organizations)
	call himgetnamesfromtable(organizations, "organization", "org_name", "organization_id")
end

subroutine himgetnamesfromtable(data, tablename, name, id)
	declare i4datacount = i4 with noconstant(size(data->qual, 5)), protect
	declare i4dataindex = i4 with noconstant(0), protect
	
	call parser(build2('select into "nl:"', " DATA_NAME = substring(1, 200, d.", name, ")", 
		", DATA_ID = d.", id, " ", " from ", tablename, " d ", " where ", 
		"expand(i4DataIndex, 1, i4DataCount,", "d.", id, ", data->qual[i4DataIndex].item_id)", 
		" order DATA_NAME, DATA_ID ", " head report ", "		i4DataIndex = 0 ", " head DATA_ID ", 
		" i4DataIndex = i4DataIndex + 1 ", " data->qual[i4DataIndex].item_name = DATA_NAME ", 
		" data->qual[i4DataIndex].item_id = DATA_ID ", " detail row+0 with nocounter go"))
end

subroutine himrendernodatareport(datasize, outputdevice)
	if (datasize = 0)
		execute reportrtl
		
		select into $OUTDEV
		from dual d
		    
		head report
			col 0 "No data found."
		
		with nocounter
		
		return (1)
	else
		return (0)
	endif
end
 

end go
 
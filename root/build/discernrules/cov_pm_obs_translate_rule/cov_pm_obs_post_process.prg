DROP PROGRAM cov_pm_obs_post_process :dba GO
CREATE PROGRAM cov_pm_obs_post_process :dba
 IF ((validate (last_mod ,"NO_MOD" ) = "NO_MOD" ) )
  DECLARE last_mod = c6 WITH noconstant ("" ) ,private
 ENDIF
 SET last_mod = "340501"
 SET last_mod = "344297"
 SET last_mod = "377070"
 SET last_mod = "492967"
 SET last_mod = "502402"
 SET last_mod = "560077"
 IF ((validate (reply->status_data.status ) = 0 ) )
  RECORD reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 RECORD pft_upt_condition_codes_req (
   1 encntr_id = f8
   1 options = vc
   1 code [* ]
     2 condition_cd = f8
     2 options = vc
 )
 RECORD pft_upt_condition_codes_reply (
   1 code [* ]
     2 condition_code_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pm_ens_transaction_request
 RECORD pm_ens_transaction_request (
   1 pm_hist_tracking_id = f8
   1 transaction_id = f8
   1 transaction = vc
   1 transaction_dt_tm = dq8
   1 hl7_event = vc
   1 person_id = f8
   1 encntr_id = f8
   1 contributor_system_cd = f8
   1 transaction_reason = vc
   1 transaction_reason_cd = f8
   1 task_number = i4
   1 trans
     2 transaction_id = f8
     2 activity_dt_tm = dq8
     2 transaction = c4
     2 n_person_id = f8
     2 o_person_id = f8
     2 n_encntr_id = f8
     2 o_encntr_id = f8
     2 n_encntr_fin_id = f8
     2 o_encntr_fin_id = f8
     2 n_mrn = c20
     2 o_mrn = c20
     2 n_fin_nbr = c20
     2 o_fin_nbr = c20
     2 n_name_last = c20
     2 o_name_last = c20
     2 n_name_first = c20
     2 o_name_first = c20
     2 n_name_middle = c20
     2 o_name_middle = c20
     2 n_name_formatted = c30
     2 o_name_formatted = c30
     2 n_birth_dt_cd = f8
     2 o_birth_dt_cd = f8
     2 n_birth_dt_tm = dq8
     2 o_birth_dt_tm = dq8
     2 n_person_sex_cd = f8
     2 o_person_sex_cd = f8
     2 n_ssn = c15
     2 o_ssn = c15
     2 n_person_type_cd = f8
     2 o_person_type_cd = f8
     2 n_autopsy_cd = f8
     2 o_autopsy_cd = f8
     2 n_conception_dt_tm = dq8
     2 o_conception_dt_tm = dq8
     2 n_cause_of_death = c40
     2 o_cause_of_death = c40
     2 n_deceased_cd = f8
     2 o_deceased_cd = f8
     2 n_deceased_dt_tm = dq8
     2 o_deceased_dt_tm = dq8
     2 n_ethnic_grp_cd = f8
     2 o_ethnic_grp_cd = f8
     2 n_language_cd = f8
     2 o_language_cd = f8
     2 n_marital_type_cd = f8
     2 o_marital_type_cd = f8
     2 n_race_cd = f8
     2 o_race_cd = f8
     2 n_religion_cd = f8
     2 o_religion_cd = f8
     2 n_sex_age_chg_ind_ind = i2
     2 n_sex_age_chg_ind = i2
     2 o_sex_age_chg_ind_ind = i2
     2 o_sex_age_chg_ind = i2
     2 n_lang_dialect_cd = f8
     2 o_lang_dialect_cd = f8
     2 n_species_cd = f8
     2 o_species_cd = f8
     2 n_confid_level_cd = f8
     2 o_confid_level_cd = f8
     2 n_person_vip_cd = f8
     2 o_person_vip_cd = f8
     2 n_citizenship_cd = f8
     2 o_citizenship_cd = f8
     2 n_vet_mil_stat_cd = f8
     2 o_vet_mil_stat_cd = f8
     2 n_mthr_maid_name = c20
     2 o_mthr_maid_name = c20
     2 n_nationality_cd = f8
     2 o_nationality_cd = f8
     2 n_encntr_class_cd = f8
     2 o_encntr_class_cd = f8
     2 n_encntr_type_cd = f8
     2 o_encntr_type_cd = f8
     2 n_encntr_type_class_cd = f8
     2 o_encntr_type_class_cd = f8
     2 n_encntr_status_cd = f8
     2 o_encntr_status_cd = f8
     2 n_pre_reg_dt_tm = dq8
     2 o_pre_reg_dt_tm = dq8
     2 n_pre_reg_prsnl_id = f8
     2 o_pre_reg_prsnl_id = f8
     2 n_reg_dt_tm = dq8
     2 o_reg_dt_tm = dq8
     2 n_reg_prsnl_id = f8
     2 o_reg_prsnl_id = f8
     2 n_est_arrive_dt_tm = dq8
     2 o_est_arrive_dt_tm = dq8
     2 n_est_depart_dt_tm = dq8
     2 o_est_depart_dt_tm = dq8
     2 n_arrive_dt_tm = dq8
     2 o_arrive_dt_tm = dq8
     2 n_depart_dt_tm = dq8
     2 o_depart_dt_tm = dq8
     2 n_admit_type_cd = f8
     2 o_admit_type_cd = f8
     2 n_admit_src_cd = f8
     2 o_admit_src_cd = f8
     2 n_admit_mode_cd = f8
     2 o_admit_mode_cd = f8
     2 n_admit_with_med_cd = f8
     2 o_admit_with_med_cd = f8
     2 n_refer_comment = c40
     2 o_refer_comment = c40
     2 n_disch_disp_cd = f8
     2 o_disch_disp_cd = f8
     2 n_disch_to_loctn_cd = f8
     2 o_disch_to_loctn_cd = f8
     2 n_preadmit_nbr = c20
     2 o_preadmit_nbr = c20
     2 n_preadmit_test_cd = f8
     2 o_preadmit_test_cd = f8
     2 n_readmit_cd = f8
     2 o_readmit_cd = f8
     2 n_accom_cd = f8
     2 o_accom_cd = f8
     2 n_accom_req_cd = f8
     2 o_accom_req_cd = f8
     2 n_alt_result_dest_cd = f8
     2 o_alt_result_dest_cd = f8
     2 n_amb_cond_cd = f8
     2 o_amb_cond_cd = f8
     2 n_courtesy_cd = f8
     2 o_courtesy_cd = f8
     2 n_diet_type_cd = f8
     2 o_diet_type_cd = f8
     2 n_isolation_cd = f8
     2 o_isolation_cd = f8
     2 n_med_service_cd = f8
     2 o_med_service_cd = f8
     2 n_result_dest_cd = f8
     2 o_result_dest_cd = f8
     2 n_encntr_vip_cd = f8
     2 o_encntr_vip_cd = f8
     2 n_encntr_sex_cd = f8
     2 o_encntr_sex_cd = f8
     2 n_disch_dt_tm = dq8
     2 o_disch_dt_tm = dq8
     2 n_guar_type_cd = f8
     2 o_guar_type_cd = f8
     2 n_loc_temp_cd = f8
     2 o_loc_temp_cd = f8
     2 n_reason_for_visit = c40
     2 o_reason_for_visit = c40
     2 n_fin_class_cd = f8
     2 o_fin_class_cd = f8
     2 n_location_cd = f8
     2 o_location_cd = f8
     2 n_loc_facility_cd = f8
     2 o_loc_facility_cd = f8
     2 n_loc_building_cd = f8
     2 o_loc_building_cd = f8
     2 n_loc_nurse_unit_cd = f8
     2 o_loc_nurse_unit_cd = f8
     2 n_loc_room_cd = f8
     2 o_loc_room_cd = f8
     2 n_loc_bed_cd = f8
     2 o_loc_bed_cd = f8
     2 n_admit_doc_name = c30
     2 o_admit_doc_name = c30
     2 n_admit_doc_id = f8
     2 o_admit_doc_id = f8
     2 n_attend_doc_name = c30
     2 o_attend_doc_name = c30
     2 n_attend_doc_id = f8
     2 o_attend_doc_id = f8
     2 n_consult_doc_name = c30
     2 o_consult_doc_name = c30
     2 n_consult_doc_id = f8
     2 o_consult_doc_id = f8
     2 n_refer_doc_name = c30
     2 o_refer_doc_name = c30
     2 n_refer_doc_id = f8
     2 o_refer_doc_id = f8
     2 n_admit_doc_nbr = c16
     2 o_admit_doc_nbr = c16
     2 n_attend_doc_nbr = c16
     2 o_attend_doc_nbr = c16
     2 n_consult_doc_nbr = c16
     2 o_consult_doc_nbr = c16
     2 n_refer_doc_nbr = c16
     2 o_refer_doc_nbr = c16
     2 n_per_home_address_id = f8
     2 o_per_home_address_id = f8
     2 n_per_home_addr_street = c100
     2 o_per_home_addr_street = c100
     2 n_per_home_addr_city = c40
     2 o_per_home_addr_city = c40
     2 n_per_home_addr_state = c20
     2 o_per_home_addr_state = c20
     2 n_per_home_addr_zipcode = c20
     2 o_per_home_addr_zipcode = c20
     2 n_per_bus_address_id = f8
     2 o_per_bus_address_id = f8
     2 n_per_bus_addr_street = c100
     2 o_per_bus_addr_street = c100
     2 n_per_bus_addr_city = c40
     2 o_per_bus_addr_city = c40
     2 n_per_bus_addr_state = c20
     2 o_per_bus_addr_state = c20
     2 n_per_bus_addr_zipcode = c20
     2 o_per_bus_addr_zipcode = c20
     2 n_per_home_phone_id = f8
     2 o_per_home_phone_id = f8
     2 n_per_home_ph_format_cd = f8
     2 o_per_home_ph_format_cd = f8
     2 n_per_home_ph_number = c20
     2 o_per_home_ph_number = c20
     2 n_per_home_ext = c10
     2 o_per_home_ext = c10
     2 n_per_bus_phone_id = f8
     2 o_per_bus_phone_id = f8
     2 n_per_bus_ph_format_cd = f8
     2 o_per_bus_ph_format_cd = f8
     2 n_per_bus_ph_number = c20
     2 o_per_bus_ph_number = c20
     2 n_per_bus_ext = c10
     2 o_per_bus_ext = c10
     2 n_per_home_addr_street2 = c100
     2 o_per_home_addr_street2 = c100
     2 n_per_bus_addr_street2 = c100
     2 o_per_bus_addr_street2 = c100
     2 n_per_home_addr_county = c20
     2 o_per_home_addr_county = c20
     2 n_per_home_addr_country = c20
     2 o_per_home_addr_country = c20
     2 n_per_bus_addr_county = c20
     2 o_per_bus_addr_county = c20
     2 n_per_bus_addr_country = c20
     2 o_per_bus_addr_country = c20
     2 n_encntr_complete_dt_tm = dq8
     2 o_encntr_complete_dt_tm = dq8
     2 n_organization_id = f8
     2 o_organization_id = f8
     2 n_contributor_system_cd = f8
     2 o_contributor_system_cd = f8
     2 hl7_event = c10
     2 n_assign_to_loc_dt_tm = dq8
     2 o_assign_to_loc_dt_tm = dq8
     2 n_alt_lvl_care_cd = f8
     2 o_alt_lvl_care_cd = f8
     2 n_program_service_cd = f8
     2 o_program_service_cd = f8
     2 n_specialty_unit_cd = f8
     2 o_specialty_unit_cd = f8
     2 n_birth_tz = i4
     2 o_birth_tz = i4
     2 abs_n_birth_dt_tm = dq8
     2 abs_o_birth_dt_tm = dq8
     2 n_service_category_cd = f8
     2 o_service_category_cd = f8
     2 n_person_birth_sex_cd = f8
     2 o_person_birth_sex_cd = f8
 )
 FREE SET pm_trans_reply
 RECORD pm_trans_reply (
   1 trans
     2 transaction_id = f8
     2 pm_hist_tracking_id = f8
     2 activity_dt_tm = dq8
     2 transaction_dt_tm = dq8
     2 transaction = c4
     2 n_person_id = f8
     2 o_person_id = f8
     2 n_encntr_id = f8
     2 o_encntr_id = f8
     2 n_encntr_fin_id = f8
     2 o_encntr_fin_id = f8
     2 n_mrn = c20
     2 o_mrn = c20
     2 n_fin_nbr = c20
     2 o_fin_nbr = c20
     2 n_name_last = c20
     2 o_name_last = c20
     2 n_name_first = c20
     2 o_name_first = c20
     2 n_name_middle = c20
     2 o_name_middle = c20
     2 n_name_formatted = c30
     2 o_name_formatted = c30
     2 n_birth_dt_cd = f8
     2 o_birth_dt_cd = f8
     2 n_birth_dt_tm = dq8
     2 o_birth_dt_tm = dq8
     2 n_person_sex_cd = f8
     2 o_person_sex_cd = f8
     2 n_ssn = c15
     2 o_ssn = c15
     2 n_person_type_cd = f8
     2 o_person_type_cd = f8
     2 n_autopsy_cd = f8
     2 o_autopsy_cd = f8
     2 n_conception_dt_tm = dq8
     2 o_conception_dt_tm = dq8
     2 n_cause_of_death = c40
     2 o_cause_of_death = c40
     2 n_deceased_cd = f8
     2 o_deceased_cd = f8
     2 n_deceased_dt_tm = dq8
     2 o_deceased_dt_tm = dq8
     2 n_ethnic_grp_cd = f8
     2 o_ethnic_grp_cd = f8
     2 n_language_cd = f8
     2 o_language_cd = f8
     2 n_marital_type_cd = f8
     2 o_marital_type_cd = f8
     2 n_race_cd = f8
     2 o_race_cd = f8
     2 n_religion_cd = f8
     2 o_religion_cd = f8
     2 n_sex_age_chg_ind_ind = i2
     2 n_sex_age_chg_ind = i2
     2 o_sex_age_chg_ind_ind = i2
     2 o_sex_age_chg_ind = i2
     2 n_lang_dialect_cd = f8
     2 o_lang_dialect_cd = f8
     2 n_species_cd = f8
     2 o_species_cd = f8
     2 n_confid_level_cd = f8
     2 o_confid_level_cd = f8
     2 n_person_vip_cd = f8
     2 o_person_vip_cd = f8
     2 n_citizenship_cd = f8
     2 o_citizenship_cd = f8
     2 n_vet_mil_stat_cd = f8
     2 o_vet_mil_stat_cd = f8
     2 n_mthr_maid_name = c20
     2 o_mthr_maid_name = c20
     2 n_nationality_cd = f8
     2 o_nationality_cd = f8
     2 n_encntr_class_cd = f8
     2 o_encntr_class_cd = f8
     2 n_encntr_type_cd = f8
     2 o_encntr_type_cd = f8
     2 n_encntr_type_class_cd = f8
     2 o_encntr_type_class_cd = f8
     2 n_encntr_status_cd = f8
     2 o_encntr_status_cd = f8
     2 n_pre_reg_dt_tm = dq8
     2 o_pre_reg_dt_tm = dq8
     2 n_pre_reg_prsnl_id = f8
     2 o_pre_reg_prsnl_id = f8
     2 n_reg_dt_tm = dq8
     2 o_reg_dt_tm = dq8
     2 n_reg_prsnl_id = f8
     2 o_reg_prsnl_id = f8
     2 n_est_arrive_dt_tm = dq8
     2 o_est_arrive_dt_tm = dq8
     2 n_est_depart_dt_tm = dq8
     2 o_est_depart_dt_tm = dq8
     2 n_arrive_dt_tm = dq8
     2 o_arrive_dt_tm = dq8
     2 n_depart_dt_tm = dq8
     2 o_depart_dt_tm = dq8
     2 n_admit_type_cd = f8
     2 o_admit_type_cd = f8
     2 n_admit_src_cd = f8
     2 o_admit_src_cd = f8
     2 n_admit_mode_cd = f8
     2 o_admit_mode_cd = f8
     2 n_admit_with_med_cd = f8
     2 o_admit_with_med_cd = f8
     2 n_refer_comment = c40
     2 o_refer_comment = c40
     2 n_disch_disp_cd = f8
     2 o_disch_disp_cd = f8
     2 n_disch_to_loctn_cd = f8
     2 o_disch_to_loctn_cd = f8
     2 n_preadmit_nbr = c20
     2 o_preadmit_nbr = c20
     2 n_preadmit_test_cd = f8
     2 o_preadmit_test_cd = f8
     2 n_readmit_cd = f8
     2 o_readmit_cd = f8
     2 n_accom_cd = f8
     2 o_accom_cd = f8
     2 n_accom_req_cd = f8
     2 o_accom_req_cd = f8
     2 n_alt_result_dest_cd = f8
     2 o_alt_result_dest_cd = f8
     2 n_amb_cond_cd = f8
     2 o_amb_cond_cd = f8
     2 n_courtesy_cd = f8
     2 o_courtesy_cd = f8
     2 n_diet_type_cd = f8
     2 o_diet_type_cd = f8
     2 n_isolation_cd = f8
     2 o_isolation_cd = f8
     2 n_med_service_cd = f8
     2 o_med_service_cd = f8
     2 n_result_dest_cd = f8
     2 o_result_dest_cd = f8
     2 n_encntr_vip_cd = f8
     2 o_encntr_vip_cd = f8
     2 n_encntr_sex_cd = f8
     2 o_encntr_sex_cd = f8
     2 n_disch_dt_tm = dq8
     2 o_disch_dt_tm = dq8
     2 n_guar_type_cd = f8
     2 o_guar_type_cd = f8
     2 n_loc_temp_cd = f8
     2 o_loc_temp_cd = f8
     2 n_reason_for_visit = c40
     2 o_reason_for_visit = c40
     2 n_fin_class_cd = f8
     2 o_fin_class_cd = f8
     2 n_location_cd = f8
     2 o_location_cd = f8
     2 n_loc_facility_cd = f8
     2 o_loc_facility_cd = f8
     2 n_loc_building_cd = f8
     2 o_loc_building_cd = f8
     2 n_loc_nurse_unit_cd = f8
     2 o_loc_nurse_unit_cd = f8
     2 n_loc_room_cd = f8
     2 o_loc_room_cd = f8
     2 n_loc_bed_cd = f8
     2 o_loc_bed_cd = f8
     2 n_admit_doc_name = c30
     2 o_admit_doc_name = c30
     2 n_admit_doc_id = f8
     2 o_admit_doc_id = f8
     2 n_attend_doc_name = c30
     2 o_attend_doc_name = c30
     2 n_attend_doc_id = f8
     2 o_attend_doc_id = f8
     2 n_consult_doc_name = c30
     2 o_consult_doc_name = c30
     2 n_consult_doc_id = f8
     2 o_consult_doc_id = f8
     2 n_refer_doc_name = c30
     2 o_refer_doc_name = c30
     2 n_refer_doc_id = f8
     2 o_refer_doc_id = f8
     2 n_admit_doc_nbr = c16
     2 o_admit_doc_nbr = c16
     2 n_attend_doc_nbr = c16
     2 o_attend_doc_nbr = c16
     2 n_consult_doc_nbr = c16
     2 o_consult_doc_nbr = c16
     2 n_refer_doc_nbr = c16
     2 o_refer_doc_nbr = c16
     2 n_per_home_address_id = f8
     2 o_per_home_address_id = f8
     2 n_per_home_addr_street = c100
     2 o_per_home_addr_street = c100
     2 n_per_home_addr_city = c40
     2 o_per_home_addr_city = c40
     2 n_per_home_addr_state = c20
     2 o_per_home_addr_state = c20
     2 n_per_home_addr_zipcode = c20
     2 o_per_home_addr_zipcode = c20
     2 n_per_bus_address_id = f8
     2 o_per_bus_address_id = f8
     2 n_per_bus_addr_street = c100
     2 o_per_bus_addr_street = c100
     2 n_per_bus_addr_city = c40
     2 o_per_bus_addr_city = c40
     2 n_per_bus_addr_state = c20
     2 o_per_bus_addr_state = c20
     2 n_per_bus_addr_zipcode = c20
     2 o_per_bus_addr_zipcode = c20
     2 n_per_home_phone_id = f8
     2 o_per_home_phone_id = f8
     2 n_per_home_ph_format_cd = f8
     2 o_per_home_ph_format_cd = f8
     2 n_per_home_ph_number = c20
     2 o_per_home_ph_number = c20
     2 n_per_home_ext = c10
     2 o_per_home_ext = c10
     2 n_per_bus_phone_id = f8
     2 o_per_bus_phone_id = f8
     2 n_per_bus_ph_format_cd = f8
     2 o_per_bus_ph_format_cd = f8
     2 n_per_bus_ph_number = c20
     2 o_per_bus_ph_number = c20
     2 n_per_bus_ext = c10
     2 o_per_bus_ext = c10
     2 n_per_home_addr_street2 = c100
     2 o_per_home_addr_street2 = c100
     2 n_per_bus_addr_street2 = c100
     2 o_per_bus_addr_street2 = c100
     2 n_per_home_addr_county = c20
     2 o_per_home_addr_county = c20
     2 n_per_home_addr_country = c20
     2 o_per_home_addr_country = c20
     2 n_per_bus_addr_county = c20
     2 o_per_bus_addr_county = c20
     2 n_per_bus_addr_country = c20
     2 o_per_bus_addr_country = c20
     2 n_encntr_complete_dt_tm = dq8
     2 o_encntr_complete_dt_tm = dq8
     2 n_organization_id = f8
     2 o_organization_id = f8
     2 n_contributor_system_cd = f8
     2 o_contributor_system_cd = f8
     2 n_assign_to_loc_dt_tm = dq8
     2 o_assign_to_loc_dt_tm = dq8
     2 n_alt_lvl_care_cd = f8
     2 o_alt_lvl_care_cd = f8
     2 n_program_service_cd = f8
     2 o_program_service_cd = f8
     2 n_specialty_unit_cd = f8
     2 o_specialty_unit_cd = f8
     2 n_birth_tz = i4
     2 o_birth_tz = i4
     2 abs_n_birth_dt_tm = dq8
     2 abs_o_birth_dt_tm = dq8
     2 n_service_category_cd = f8
     2 o_service_category_cd = f8
     2 output_dest_cd = f8
     2 n_person_birth_sex_cd = f8
     2 o_person_birth_sex_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD lookup
 RECORD lookup (
   1 med_service_cd = f8
   1 los_codeset = i4
   1 los_cd = f8
   1 accom_cd = f8
   1 order_physician_id = f8
   1 admit_physician_id = f8
   1 admit_reltn_id = f8
   1 attend_physician_id = f8
   1 attend_reltn_id = f8
   1 cur_facility_cd = f8
 )
 FREE RECORD temp_req
 RECORD temp_req (
   1 encntr_id = f8
   1 person_id = f8
   1 order_id = f8
   1 patient_event_qual = i4
   1 patient_event [* ]
     2 action = vc
     2 event_dt_tm = dq8
     2 event_type_cd = f8
     2 patient_event_id = f8
     2 event_detail [* ]
       3 action = vc
       3 patient_event_detail_id = f8
       3 value_meaning = vc
       3 value_dt_tm = dq8
       3 value_numeric = i4
       3 value_string = vc
       3 value_cd = f8
       3 value_id = f8
       3 value_name = vc
   1 order_mode = vc
 )
 FREE RECORD temp_rep
 RECORD temp_rep (
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD encntr_req
 RECORD encntr_req (
   1 encounter_qual = i4
   1 esi_ensure_type = c3
   1 mode = i2
   1 encounter [* ]
     2 mental_health_cd = f8
     2 mental_health_dt_tm = dq8
     2 action_type = c3
     2 new_person = c1
     2 pm_hist_tracking_id = f8
     2 transaction_dt_tm = dq8
     2 transaction_reason_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 encntr_class_cd = f8
     2 encntr_type_cd = f8
     2 encntr_type_class_cd = f8
     2 encntr_status_cd = f8
     2 pre_reg_dt_tm = dq8
     2 pre_reg_prsnl_id = f8
     2 reg_dt_tm = dq8
     2 reg_prsnl_id = f8
     2 est_arrive_dt_tm = dq8
     2 est_depart_dt_tm = dq8
     2 arrive_dt_tm = dq8
     2 depart_dt_tm = dq8
     2 admit_type_cd = f8
     2 admit_src_cd = f8
     2 admit_mode_cd = f8
     2 admit_with_medication_cd = f8
     2 referring_comment = c100
     2 disch_disposition_cd = f8
     2 disch_to_loctn_cd = f8
     2 preadmit_nbr = c100
     2 preadmit_testing_cd = f8
     2 preadmit_testing_list_ind = i2
     2 preadmit_testing [* ]
       3 value_cd = f8
     2 readmit_cd = f8
     2 accommodation_cd = f8
     2 accommodation_request_cd = f8
     2 alt_result_dest_cd = f8
     2 ambulatory_cond_cd = f8
     2 courtesy_cd = f8
     2 diet_type_cd = f8
     2 isolation_cd = f8
     2 med_service_cd = f8
     2 result_dest_cd = f8
     2 confid_level_cd = f8
     2 vip_cd = f8
     2 name_last_key = c200
     2 name_first_key = c200
     2 name_full_formatted = c200
     2 name_last = c200
     2 name_first = c200
     2 name_phonetic = c200
     2 sex_cd = f8
     2 birth_dt_cd = f8
     2 birth_dt_tm = dq8
     2 species_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 location_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 disch_dt_tm = dq8
     2 guarantor_type_cd = f8
     2 loc_temp_cd = f8
     2 organization_id = f8
     2 esiorgalias [* ]
       3 alias_pool_cd = f8
       3 alias_type_cd = f8
       3 alias = c200
     2 def_organization_id = f8
     2 reason_for_visit = c500
     2 encntr_financial_id = f8
     2 name_first_synonym_id = f8
     2 financial_class_cd = f8
     2 bbd_procedure_cd = f8
     2 info_given_by = c100
     2 safekeeping_cd = f8
     2 trauma_cd = f8
     2 triage_cd = f8
     2 triage_dt_tm = dq8
     2 visitor_status_cd = f8
     2 valuables_cd = f8
     2 valuables_list_ind = i2
     2 valuables [* ]
       3 value_cd = f8
     2 security_access_cd = f8
     2 refer_facility_cd = f8
     2 trauma_dt_tm = dq8
     2 accomp_by_cd = f8
     2 accommodation_reason_cd = f8
     2 program_service_cd = f8
     2 specialty_unit_cd = f8
     2 updt_cnt = i4
     2 chart_complete_dt_tm = dq8
     2 encntr_complete_dt_tm = dq8
     2 zero_balance_dt_tm = dq8
     2 archive_dt_tm_est = dq8
     2 archive_dt_tm_act = dq8
     2 purge_dt_tm_est = dq8
     2 purge_dt_tm_act = dq8
     2 pa_current_status_dt_tm = dq8
     2 pa_current_status_cd = f8
     2 parent_ret_criteria_id = f8
     2 service_category_cd = f8
     2 transaction_dt_tm_old = dq8
     2 encntr_fin_hist_type_cd = f8
     2 est_length_of_stay = i4
     2 contract_status_cd = f8
     2 attend_prsnl_id = f8
     2 assign_to_loc_dt_tm = dq8
     2 alt_lvl_care_cd = f8
     2 alt_lvl_care_dt_tm = dq8
     2 alc_reason_cd = f8
     2 alc_decomp_dt_tm = dq8
     2 region_cd = f8
     2 sitter_required_cd = f8
     2 doc_rcvd_dt_tm = dq8
     2 referral_rcvd_dt_tm = dq8
     2 place_auth_prsnl_id = f8
     2 patient_classification_cd = f8
     2 mental_category_cd = f8
     2 psychiatric_status_cd = f8
     2 inpatient_admit_dt_tm = dq8
     2 result_acc_dt_tm = dq8
     2 pregnancy_status_cd = f8
     2 expected_delivery_dt_tm = dq8
     2 last_menstrual_period_dt_tm = dq8
     2 onset_dt_tm = dq8
     2 level_of_service_cd = f8
     2 abn_status_cd = f8
   1 encntrlochistoverride = i2
 )
 FREE RECORD encntr_reply
 RECORD encntr_reply (
   1 encounter_qual = i2
   1 encounter [* ]
     2 encntr_id = f8
     2 pm_hist_tracking_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE add_modify_person = i4 WITH protect ,constant (100 )
 DECLARE modify_person = i4 WITH protect ,constant (101 )
 DECLARE view_person = i4 WITH protect ,constant (102 )
 DECLARE remove_person = i4 WITH protect ,constant (103 )
 DECLARE add_modify_encounter = i4 WITH protect ,constant (200 )
 DECLARE modify_encounter = i4 WITH protect ,constant (201 )
 DECLARE view_encounter = i4 WITH protect ,constant (202 )
 DECLARE cancel_encounter = i4 WITH protect ,constant (203 )
 DECLARE add_newborn = i4 WITH protect ,constant (204 )
 DECLARE reactivate_cancelled_encounter = i4 WITH protect ,constant (205 )
 DECLARE add_modify_pending_encounter = i4 WITH protect ,constant (206 )
 DECLARE modify_pending_encounter = i4 WITH protect ,constant (207 )
 DECLARE cancel_pending_encounter = i4 WITH protect ,constant (208 )
 DECLARE complete_pending_encounter = i4 WITH protect ,constant (209 )
 DECLARE reactivate_cancelled_pending_encounter_action = i4 WITH protect ,constant (210 )
 DECLARE reactivate_pending_arrival_action = i4 WITH protect ,constant (211 )
 DECLARE transfer_encounter = i4 WITH protect ,constant (300 )
 DECLARE request_encounter_transfer = i4 WITH protect ,constant (301 )
 DECLARE approve_encounter_transfer = i4 WITH protect ,constant (302 )
 DECLARE complete_encounter_transfer = i4 WITH protect ,constant (303 )
 DECLARE cancel_encounter_transfer = i4 WITH protect ,constant (304 )
 DECLARE cancel_requested_encounter_transfer = i4 WITH protect ,constant (305 )
 DECLARE bed_swap = i4 WITH protect ,constant (306 )
 DECLARE update_pending_transfer_action = i4 WITH protect ,constant (307 )
 DECLARE discharge_encounter = i4 WITH protect ,constant (400 )
 DECLARE request_encounter_discharge = i4 WITH protect ,constant (401 )
 DECLARE approve_encounter_discharge = i4 WITH protect ,constant (402 )
 DECLARE complete_encounter_discharge = i4 WITH protect ,constant (403 )
 DECLARE cancel_encounter_discharge = i4 WITH protect ,constant (404 )
 DECLARE cancel_requested_encounter_discharge = i4 WITH protect ,constant (405 )
 DECLARE update_pending_discharge_action = i4 WITH protect ,constant (406 )
 DECLARE reactivate_pending_discharge_action = i4 WITH protect ,constant (407 )
 DECLARE leave_of_absence = i4 WITH protect ,constant (500 )
 DECLARE cancel_leave_of_absence = i4 WITH protect ,constant (501 )
 DECLARE encounter_return = i4 WITH protect ,constant (502 )
 DECLARE upt_encounter_leave = i4 WITH protect ,constant (503 )
 DECLARE upt_encounter_return = i4 WITH protect ,constant (504 )
 DECLARE add_modify_wait_list = i4 WITH protect ,constant (800 )
 DECLARE modify_wait_list_action = i4 WITH protect ,constant (801 )
 DECLARE pmhnareg_add_modify_person = i4 WITH protect ,constant (900 )
 DECLARE pmhnareg_modify_person = i4 WITH protect ,constant (901 )
 DECLARE pmhnareg_add_modify_encounter = i4 WITH protect ,constant (902 )
 DECLARE pmhnareg_modify_encounter = i4 WITH protect ,constant (903 )
 DECLARE pmhnareg_view_person = i4 WITH protect ,constant (904 )
 DECLARE pmhnareg_view_encounter = i4 WITH protect ,constant (905 )
 DECLARE inpatient_encntr_type_class_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,69 ,
   "INPATIENT" ) ) ,protect
 DECLARE preadmit_encntr_type_class_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,69 ,
   "PREADMIT" ) ) ,protect
 DECLARE getoutboundmessagetrigger ((lconvtype = i4 ) ,(dprevencntrtypeclass = f8 ) ,(
  dnewencntrclass = f8 ) ) = vc
 SUBROUTINE  getoutboundmessagetrigger (lconvtype ,dprevencntrtypeclass ,dnewencntrclass )
  IF ((((lconvtype = modify_encounter ) ) OR ((((lconvtype = pmhnareg_modify_encounter ) ) OR ((((
  lconvtype = modify_wait_list_action ) ) OR ((((lconvtype = upt_encounter_leave ) ) OR ((lconvtype
  = upt_encounter_return ) )) )) )) )) )
   IF ((dprevencntrtypeclass = preadmit_encntr_type_class_cd ) )
    IF ((dnewencntrclass = inpatient_encntr_type_class_cd ) )
     RETURN ("A01" )
    ELSE
     RETURN ("A04" )
    ENDIF
   ELSE
    IF ((dnewencntrclass = dprevencntrtypeclass ) )
     RETURN ("A08" )
    ELSEIF ((dnewencntrclass = inpatient_encntr_type_class_cd ) )
     RETURN ("A06" )
    ELSEIF ((dnewencntrclass = preadmit_encntr_type_class_cd ) )
     RETURN ("A11" )
    ELSEIF ((dnewencntrclass != inpatient_encntr_type_class_cd ) )
     RETURN ("A07" )
    ENDIF
   ENDIF
  ENDIF
  RETURN ("" )
 END ;Subroutine
 IF ((validate (isend_outbound_exists ,- (999 ) ) = - (999 ) ) )
  IF ((validate (last_mod ,"NOMOD2" ) = "NOMOD2" ) )
   DECLARE last_mod = c6 WITH noconstant (" " ) ,private
  ENDIF
  SET last_mod = "167192"
  SET last_mod = "166264"
  SET last_mod = "195711"
  SET last_mod = "204250"
  SET last_mod = "241981"
  SET last_mod = "239737"
  DECLARE dmovementid = f8
  DECLARE dmovement_event_cd = f8
  DECLARE dpostmovement = f8
  DECLARE send_outbound ((ob_person_id = f8 ) ,(ob_encntr_id = f8 ) ,(ob_subtype = f8 ) ,(ob_trigger
   = vc ) ) = null
  DECLARE pm_destroy_handles ((idummy = i2 ) ) = null
  DECLARE send_outbound2 ((ob_person_id = f8 ) ,(ob_encntr_id = f8 ) ,(ob_subtype = f8 ) ,(
   ob_trigger = vc ) ,(ob_movementid = f8 ) ,(ob_movement_event = f8 ) ) = null
  SET dpostmovement = uar_get_code_by ("MEANING" ,207902 ,"POSTMOVEMENT" )
  IF (NOT (validate (err ,0 ) ) )
   FREE RECORD err
   RECORD err (
     1 list [* ]
       2 msg = vc
   )
  ENDIF
  EXECUTE si_esocallsrtl
  SUBROUTINE  send_outbound (ob_person_id ,ob_encntr_id ,ob_subtype ,ob_trigger )
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE so_x = i4
   DECLARE so_cnt = i4
   DECLARE so_status = c1
   DECLARE so_continue_yn = c1
   DECLARE so_err_cnt = i4
   DECLARE isend_outbound_exists = i2 WITH public ,noconstant (1 )
   DECLARE so_create_reply_err_msg = vc
   DECLARE so_happ = i4
   DECLARE so_hreply = i4
   DECLARE so_htask = i4
   DECLARE so_hreq = i4
   DECLARE so_crmstatus = i2
   DECLARE so_appnum = i4
   DECLARE so_tasknum = i4
   DECLARE so_reqnum = i4
   DECLARE so_hstep = i4
   DECLARE so_hstatus = i4
   DECLARE so_hlist = i4
   DECLARE dallaliasoutbnd = f8 WITH noconstant (0.0 )
   IF ((validate (bdebugsendoutbndsub ,- (9 ) ) = - (9 ) ) )
    DECLARE bdebugsendoutbndsub = i2 WITH noconstant (false )
   ENDIF
   SET so_continue_yn = "Y"
   SET so_appnum = 100000
   SET so_tasknum = 100000
   SET so_crmstatus = uar_crmbeginapp (so_appnum ,so_happ )
   IF ((so_crmstatus = 0 ) )
    SET so_crmstatus = uar_crmbegintask (so_happ ,so_tasknum ,so_htask )
    IF ((so_crmstatus != 0 ) )
     SET so_create_reply_err_msg = concat ("BEGINTASK=" ,cnvtstring (so_crmstatus ) )
     CALL uar_crmendapp (so_happ )
    ENDIF
   ELSE
    SET so_create_reply_err_msg = concat ("BEGINAPP=" ,cnvtstring (so_crmstatus ) )
   ENDIF
   IF ((((so_crmstatus != 0 ) ) OR ((so_htask = 0 ) )) )
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = trim (so_create_reply_err_msg )
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "app/task 100000"
    SET so_err_cnt = (so_err_cnt + 1 )
    SET stat = alterlist (err->list ,so_err_cnt )
    SET err->list[so_err_cnt ].msg = "%Error -- Beginning App/Task 100000"
    CALL pm_destroy_handles (1 )
    RETURN
   ENDIF
   IF ((ob_encntr_id != 0.0 ) )
    SET action = 201
   ELSE
    SET action = 101
   ENDIF
   IF ((so_htask != 0 ) )
    SET so_reqnum = 114604
    SET so_all_person_aliases = 0
    SET so_crmstatus = uar_crmbeginreq (so_htask ,"" ,so_reqnum ,so_hstep )
    IF ((so_crmstatus = 0 ) )
     SET so_hreq = uar_crmgetrequest (so_hstep )
     SET stat = uar_srvsetdouble (so_hreq ,"person_id" ,ob_person_id )
     SET stat = uar_srvsetdouble (so_hreq ,"encntr_id" ,ob_encntr_id )
     SET stat = uar_srvsetshort (so_hreq ,"action" ,action )
     SET stat = uar_get_meaning_by_codeset (207902 ,"ALLALIASOUT" ,1 ,dallaliasoutbnd )
     IF ((dallaliasoutbnd > 0 ) )
      SET stat = uar_srvsetshort (so_hreq ,"all_person_aliases" ,1 )
     ELSE
      SET stat = uar_srvsetshort (so_hreq ,"all_person_aliases" ,0 )
     ENDIF
     IF (bdebugsendoutbndsub )
      CALL uar_crmlogmessage (so_hreq ,"pm_req114604.dat" )
     ENDIF
     SET stat = uar_crmperform (so_hstep )
     IF ((stat != 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = build ("%Error -- Calling Pm_get_patient_data(encntr_id = " ,
       ob_encntr_id ," ,person_id = " ,ob_person_id ,")" )
     ENDIF
     SET so_hreply = uar_crmgetreply (so_hstep )
     IF ((so_hreply = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = build ("%Error -- Pm_get_patient_data Reply (encntr_id = " ,
       ob_encntr_id ," ,person_id = " ,ob_person_id ,")" )
     ENDIF
     IF (bdebugsendoutbndsub )
      CALL uar_crmlogmessage (so_hreply ,"pm_rep114604.dat" )
     ENDIF
     SET so_hpatpersoninfo = uar_srvgetstruct (so_hreply ,"person" )
     SET so_hpatencntrinfo = uar_srvgetstruct (so_hreply ,"encounter" )
     IF ((so_hpatpersoninfo = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = build (
       "%Error --Pm_get_patient_data person info(encntr_id = " ,ob_encntr_id ," ,person_id = " ,
       ob_person_id ,")" )
     ENDIF
    ELSE
     SET so_continue_yn = "N"
     SET so_err_cnt = (so_err_cnt + 1 )
     SET stat = alterlist (err->list ,so_err_cnt )
     SET err->list[so_err_cnt ].msg = concat ("BEGINREQ=" ,cnvtstring (so_crmstatus ) )
    ENDIF
   ENDIF
   IF ((so_continue_yn = "Y" ) )
    DECLARE so_hmsgstruct = i4
    DECLARE so_hcqminfostruct = i4
    DECLARE so_htriginfostruct = i4
    DECLARE so_htransinfostruct = i4
    DECLARE so_hpersonstruct = i4
    DECLARE so_hencntrstruct = i4
    DECLARE so_hesoinfo = i4
    DECLARE so_hreqstruct = i4
    DECLARE so_hmovmntstruct = i4
    DECLARE so_hmsg = i4
    DECLARE so_hreqmsg = i4
    DECLARE so_hcqmmsg = i4
    DECLARE so_hcqminfo = i4
    DECLARE so_htriginfo = i4
    DECLARE so_htemp1 = i4
    DECLARE so_htemp2 = i4
    DECLARE so_htemp3 = i4
    DECLARE so_htemp4 = i4
    DECLARE isiesostatus = i4
    DECLARE dqueueid = f8
    DECLARE esiesonotcalled = i4 WITH noconstant (0 )
    DECLARE esiesosuccess = i4 WITH noconstant (1 )
    DECLARE esiesosrvexecfail = i4 WITH noconstant (2 )
    DECLARE esiesomemfail = i4 WITH noconstant (3 )
    DECLARE esiesosrvoutmem = i4 WITH noconstant (4 )
    DECLARE esiesocopyfail = i4 WITH noconstant (5 )
    DECLARE esiesocompressfail = i4 WITH noconstant (6 )
    DECLARE esiesoscriptfail = i4 WITH noconstant (7 )
    DECLARE esiesoinvalidmsg = i4 WITH noconstant (8 )
    DECLARE esiesosrvfail = i4 WITH noconstant (9 )
    DECLARE esiesoinvalidalias = i4 WITH noconstant (10 )
    DECLARE esiesoroutefail = i4 WITH noconstant (11 )
    DECLARE esiesodbfail = i4 WITH noconstant (12 )
    DECLARE esiesogenericerr = i4 WITH noconstant (13 )
    SET so_hreqmsg = uar_srvselectmessage (1215013 )
    IF ((so_hreqmsg = 0 ) )
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname =
     "Unable to obtain message for TDB 1215013"
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "req1215013"
     SET so_err_cnt = (so_err_cnt + 1 )
     SET stat = alterlist (err->list ,so_err_cnt )
     SET err->list[so_err_cnt ].msg = "Unable to obtain message for TDB 1215013"
     CALL pm_destroy_handles (1 )
     RETURN
    ENDIF
    SET so_hreqstruct = uar_srvcreaterequest (so_hreqmsg )
    CALL uar_srvdestroymessage (so_hreqmsg )
    SET so_hmsgstruct = uar_srvgetstruct (so_hreqstruct ,"message" )
    SET so_hcqminfostruct = uar_srvgetstruct (so_hmsgstruct ,"cqminfo" )
    SET date_disp = format (cnvtdatetime (curdate ,curtime3 ) ,";;Q" )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"AppName" ,"FSIESO" )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"ContribAlias" ,"PM_TRANSACTION" )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"ContribRefnum" ,"114700" )
    SET stat = uar_srvsetdate (so_hcqminfostruct ,"ContribDtTm" ,cnvtdatetime (curdate ,curtime3 ) )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"Class" ,"PM_TRANS" )
    SET stat = uar_srvsetlong (so_hcqminfostruct ,"Priority" ,99 )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"Type" ,"ADT" )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"Subtype" ,nullterm (ob_trigger ) )
    SET stat = uar_srvsetlong (so_hcqminfostruct ,"Verbosity_Flag" ,1 )
    SET stat = uar_srvsetstring (so_hcqminfostruct ,"subtype_detail" ,nullterm (trim (cnvtstring (
        ob_subtype ) ,5 ) ) )
    SET so_hesoinfostruct = uar_srvgetstruct (so_hmsgstruct ,"ESOInfo" )
    IF ((so_hesoinfostruct = 0 ) )
     SET so_continue_yn = "N"
     SET so_err_cnt = (so_err_cnt + 1 )
     SET stat = alterlist (err->list ,so_err_cnt )
     SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> ESOInfo"
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     IF (NOT (validate (longlist ,0 ) ) )
      RECORD longlist (
        1 qual [4 ]
          2 val = i4
          2 str = vc
      )
     ENDIF
     SET longlist->qual[1 ].val = 0
     SET longlist->qual[1 ].str = "person first event"
     IF ((ob_encntr_id != 0.0 ) )
      SET longlist->qual[2 ].val = 0
     ELSE
      SET longlist->qual[2 ].val = 1
     ENDIF
     SET longlist->qual[2 ].str = "encntr first event"
     IF ((ob_encntr_id != 0.0 ) )
      SET longlist->qual[3 ].val = 1
     ELSE
      SET longlist->qual[3 ].val = 0
     ENDIF
     SET longlist->qual[3 ].str = "encntr event ind"
     SET longlist->qual[4 ].val = action
     SET longlist->qual[4 ].str = "action type"
     FOR (xyz = 1 TO 4 )
      SET so_hlist = uar_srvadditem (so_hesoinfostruct ,"longList" )
      IF ((so_hlist > 0 ) )
       SET stat = uar_srvsetlong (so_hlist ,"lVal" ,longlist->qual[xyz ].val )
       SET stat = uar_srvsetstring (so_hlist ,"StrMeaning" ,nullterm (longlist->qual[xyz ].str ) )
      ELSE
       SET so_continue_yn = "N"
       SET so_err_cnt = (so_err_cnt + 1 )
       SET stat = alterlist (err->list ,so_err_cnt )
       SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> longList"
       SET xyz = 4
      ENDIF
     ENDFOR
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     SET so_htriginfostruct = uar_srvgetstruct (so_hmsgstruct ,"TRIGInfo" )
     IF ((so_htriginfostruct = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> triginfo"
     ENDIF
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     SET stat = uar_srvsetshort (so_htriginfostruct ,"transaction_type" ,201 )
     SET so_htransinfostruct = uar_srvgetstruct (so_htriginfostruct ,"transaction_info" )
     IF ((so_htransinfostruct = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> transaction_info"
     ENDIF
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     SET stat = uar_srvsetdouble (so_htransinfostruct ,"prsnl_id" ,reqinfo->updt_id )
     SET stat = uar_srvsetlong (so_htransinfostruct ,"applctx" ,reqinfo->updt_applctx )
     SET stat = uar_srvsetlong (so_htransinfostruct ,"updt_task" ,reqinfo->updt_task )
     SET stat = uar_srvsetdate (so_htransinfostruct ,"trans_dt_tm" ,cnvtdatetime (curdate ,curtime3
       ) )
     SET stat = uar_srvsetshort (so_htransinfostruct ,"print_doc_ind" ,0 )
     SET so_hpersonstruct = uar_srvgetstruct (so_htriginfostruct ,"person" )
     IF ((so_hpersonstruct = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> person"
     ENDIF
     SET so_hencntrstruct = uar_srvgetstruct (so_htriginfostruct ,"encounter" )
     IF ((so_hencntrstruct = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> encounter"
     ENDIF
     SET so_hmovmntstruct = uar_srvgetstruct (so_hpatencntrinfo ,"movement" )
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     SET stat = uar_srvcopy (so_hpersonstruct ,so_hpatpersoninfo )
     SET stat = uar_srvcopy (so_hencntrstruct ,so_hpatencntrinfo )
     SET so_hsubpersonstruct = uar_srvgetstruct (so_hpersonstruct ,"person" )
     IF ((so_hsubpersonstruct = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = "%Error -- Retrieving Reply --> person --> person"
     ENDIF
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     SET chk_pid = uar_srvgetdouble (so_hsubpersonstruct ,"person_id" )
     IF ((chk_pid = 0 ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = concat ("%Error -- Srv Copy Failed Person_id = 0" )
     ENDIF
    ENDIF
    IF ((so_continue_yn = "Y" ) )
     IF ((dpostmovement > 0.0 ) )
      IF ((checkprg ("ADM_ADT_MOUV_OUTBOUND" ) > 0 ) )
       EXECUTE adm_adt_mouv_outbound
      ENDIF
     ENDIF
     SET so_hmsg = uar_srvselectmessage (1215001 )
     IF ((so_hmsg = 0 ) )
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1 ].operationname =
      "Unable to obtain message for TDB 1215001"
      SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
      SET reply->status_data.subeventstatus[1 ].targetobjectname = "req1215001"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = "Unable to obtain message for TDB 1215001"
      CALL pm_destroy_handles (1 )
      RETURN
     ENDIF
     SET so_hreqmsg = uar_srvselectmessage (1215013 )
     SET so_hreply = uar_srvcreatereply (so_hreqmsg )
     CALL uar_srvdestroymessage (so_hreqmsg )
     SET isiesostatus = 0
     SET isiesostatus = uar_siscriptesocompdttrig (so_hreqstruct ,dqueueid )
     IF ((isiesostatus != esiesosuccess ) )
      SET so_continue_yn = "N"
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      SET err->list[so_err_cnt ].msg = build (
       "%Error --Error sending outbound message (encntr_id = " ,ob_encntr_id ," ,person_id = " ,
       ob_person_id ,")" )
      SET so_err_cnt = (so_err_cnt + 1 )
      SET stat = alterlist (err->list ,so_err_cnt )
      CASE (isiesostatus )
       OF esiesonotcalled :
        SET err->list[so_err_cnt ].msg = "    Si ESO Not Called"
       OF esiesosrvexecfail :
        SET err->list[so_err_cnt ].msg = "    ESO SrvExecute returned a status of Fail"
       OF esiesomemfail :
        SET err->list[so_err_cnt ].msg = "    ESO Failed to allocate memory for compression buffer"
       OF esiesosrvoutmem :
        SET err->list[so_err_cnt ].msg = "    Memory failure occurred in ESO server"
       OF esiesocopyfail :
        SET err->list[so_err_cnt ].msg = "    ESO Server Failed to copy trigger to downtime request"
       OF esiesocompressfail :
        SET err->list[so_err_cnt ].msg = "    ESO Server Failed to compress trigger"
       OF esiesoscriptfail :
        SET err->list[so_err_cnt ].msg = "    ESO Script Faile"
       OF esiesoinvalidmsg :
        SET err->list[so_err_cnt ].msg = "    ESO Missing CQM structure in downtime request"
       OF esiesosrvfail :
        SET err->list[so_err_cnt ].msg = "    ESO Failed to set SRV"
       OF esiesoinvalidalias :
        SET err->list[so_err_cnt ].msg = "    ESO returned contributor alias invalid"
       OF esiesoroutefail :
        SET err->list[so_err_cnt ].msg = "    Routing error occurred within ESO"
       OF esiesodbfail :
        SET err->list[so_err_cnt ].msg = "    ESO returned database failure"
       OF esiesogenericerr :
        SET err->list[so_err_cnt ].msg = "    Generic Error encountered when calling ESO"
      ENDCASE
     ENDIF
    ENDIF
   ENDIF
   CALL pm_destroy_handles (1 )
  END ;Subroutine
  SUBROUTINE  pm_destroy_handles (idummy )
   IF ((validate (so_hreply ,- (999 ) ) != - (999 ) ) )
    IF (so_hreply )
     CALL uar_srvdestroyinstance (so_hreply )
     SET so_hreply = 0
    ENDIF
   ENDIF
   IF ((validate (so_hreqstruct ,- (999 ) ) != - (999 ) ) )
    IF (so_hreqstruct )
     CALL uar_srvdestroyinstance (so_hreqstruct )
     SET so_hreqstruct = 0
    ENDIF
   ENDIF
   IF ((validate (so_hreq ,- (999 ) ) != - (999 ) ) )
    IF (so_hreq )
     CALL uar_crmendreq (so_hreq )
     SET so_hreq = 0
    ENDIF
   ENDIF
   IF ((validate (so_hreqmsg ,- (999 ) ) != - (999 ) ) )
    IF (so_hreqmsg )
     SET stat = uar_srvdestroymessage (so_hreqmsg )
     SET so_hreqmsg = 0
    ENDIF
   ENDIF
   IF ((validate (so_hmsg ,- (999 ) ) != - (999 ) ) )
    IF (so_hmsg )
     SET stat = uar_srvdestroymessage (so_hmsg )
     SET so_hmsg = 0
    ENDIF
   ENDIF
   IF ((validate (so_hstep ,- (999 ) ) != - (999 ) ) )
    IF (so_hstep )
     CALL uar_crmendreq (so_hstep )
     SET so_hstep = 0
    ENDIF
   ENDIF
   IF ((validate (so_htask ,- (999 ) ) != - (999 ) ) )
    IF (so_htask )
     CALL uar_crmendtask (so_htask )
     SET so_htask = 0
    ENDIF
   ENDIF
   IF ((validate (so_happ ,- (999 ) ) != - (999 ) ) )
    IF (so_happ )
     CALL uar_crmendapp (so_happ )
     SET so_happ = 0
    ENDIF
   ENDIF
  END ;Subroutine
  SUBROUTINE  send_outbound2 (ob_person_id ,ob_encntr_id ,ob_subtype ,ob_trigger ,ob_movementid ,
   ob_movement_event )
   SET dmovementid = ob_movementid
   SET dmovement_event_cd = ob_movement_event
   CALL echo (build ("dMovement_Event_cd = " ,dmovement_event_cd ) )
   CALL send_outbound (ob_person_id ,ob_encntr_id ,ob_subtype ,ob_trigger )
  END ;Subroutine
 ENDIF
 IF ((validate (pm_helper_subs_include ,- (99 ) ) = - (99 ) ) )
  DECLARE pm_helper_subs_include = i4 WITH constant (1 )
  DECLARE setreplystatusblock ((soperationname = vc ) ,(soperationstatus = vc ) ,(stargetobjectname
   = vc ) ,(stargetobjectvalue = vc ) ) = null
  SUBROUTINE  setreplystatusblock (soperationname ,soperationstatus ,stargetobjectname ,
   stargetobjectvalue )
   SET reply->status_data.subeventstatus[1 ].operationname = soperationname
   SET reply->status_data.subeventstatus[1 ].operationstatus = soperationstatus
   SET reply->status_data.subeventstatus[1 ].targetobjectname = stargetobjectname
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = stargetobjectvalue
  END ;Subroutine
 ENDIF
 IF ((validate (dq_parser_rec->buffer_count ,- (99 ) ) = - (99 ) ) )
  CALL echo ("*****inside pm_dynamic_query include file *****" )
  FREE RECORD dq_parser_rec
  RECORD dq_parser_rec (
    1 buffer_count = i2
    1 plan_count = i2
    1 set_count = i2
    1 table_count = i2
    1 with_count = i2
    1 buffer [* ]
      2 line = vc
  )
  SET dq_parser_rec->buffer_count = 0
  SET dq_parser_rec->plan_count = 0
  SET dq_parser_rec->set_count = 0
  SET dq_parser_rec->table_count = 0
  SET dq_parser_rec->with_count = 0
  DECLARE dq_add_detail (dqad_dummy ) = null
  DECLARE dq_add_footer (dqaf_target ) = null
  DECLARE dq_add_header (dqah_target ) = null
  DECLARE dq_add_line (dqal_line ) = null
  DECLARE dq_get_line (dqgl_idx ) = vc
  DECLARE dq_upt_line (dqul_idx ,dqul_line ) = null
  DECLARE dq_add_planjoin (dqap_range ) = null
  DECLARE dq_add_set (dqas_to ,dqas_from ) = null
  DECLARE dq_add_table (dqat_table_name ,dqat_table_alias ) = null
  DECLARE dq_add_with (dqaw_control_option ) = null
  DECLARE dq_begin_insert (dqbi_dummy ) = null
  DECLARE dq_begin_select (dqbs_distinct_ind ,dqbs_output_device ) = null
  DECLARE dq_begin_update (dqbu_dummy ) = null
  DECLARE dq_echo_query (dqeq_level ) = null
  DECLARE dq_end_query (dqes_dummy ) = null
  DECLARE dq_execute (dqe_reset ) = null
  DECLARE dq_reset_query (dqrb_dummy ) = null
  SUBROUTINE  dq_add_detail (dqad_dummy )
   CALL dq_add_line ("detail" )
  END ;Subroutine
  SUBROUTINE  dq_add_footer (dqaf_target )
   IF ((size (trim (dqaf_target ) ,1 ) > 0 ) )
    CALL dq_add_line (concat ("foot " ,dqaf_target ) )
   ELSE
    CALL dq_add_line ("foot report" )
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_add_header (dqah_target )
   IF ((size (trim (dqah_target ) ,1 ) > 0 ) )
    CALL dq_add_line (concat ("head " ,dqah_target ) )
   ELSE
    CALL dq_add_line ("head report" )
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_add_line (dqal_line )
   SET dq_parser_rec->buffer_count = (dq_parser_rec->buffer_count + 1 )
   IF ((mod (dq_parser_rec->buffer_count ,10 ) = 1 ) )
    SET stat = alterlist (dq_parser_rec->buffer ,(dq_parser_rec->buffer_count + 9 ) )
   ENDIF
   SET dq_parser_rec->buffer[dq_parser_rec->buffer_count ].line = trim (dqal_line ,3 )
  END ;Subroutine
  SUBROUTINE  dq_get_line (dqgl_idx )
   IF ((dqgl_idx > 0 )
   AND (dqgl_idx <= size (dq_parser_rec->buffer ,5 ) ) )
    RETURN (dq_parser_rec->buffer[dqgl_idx ].line )
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_upt_line (dqul_idx ,dqul_line )
   IF ((dqul_idx > 0 )
   AND (dqul_idx <= size (dq_parser_rec->buffer ,5 ) ) )
    SET dq_parser_rec->buffer[dqul_idx ].line = dqul_line
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_add_planjoin (dqap_range )
   DECLARE dqap_str = vc WITH private ,noconstant (" " )
   IF ((dq_parser_rec->plan_count > 0 ) )
    SET dqap_str = "join"
   ELSE
    SET dqap_str = "plan"
   ENDIF
   IF ((size (trim (dqap_range ) ,1 ) > 0 ) )
    CALL dq_add_line (concat (dqap_str ," " ,dqap_range ," where" ) )
    SET dq_parser_rec->plan_count = (dq_parser_rec->plan_count + 1 )
   ELSE
    CALL dq_add_line ("where " )
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_add_set (dqas_to ,dqas_from )
   IF ((dq_parser_rec->set_count > 0 ) )
    CALL dq_add_line (concat ("," ,dqas_to ," = " ,dqas_from ) )
   ELSE
    CALL dq_add_line (concat ("set " ,dqas_to ," = " ,dqas_from ) )
   ENDIF
   SET dq_parser_rec->set_count = (dq_parser_rec->set_count + 1 )
  END ;Subroutine
  SUBROUTINE  dq_add_table (dqat_table_name ,dqat_table_alias )
   DECLARE dqat_str = vc WITH private ,noconstant (" " )
   IF ((dq_parser_rec->table_count > 0 ) )
    SET dqat_str = concat (" , " ,dqat_table_name )
   ELSE
    SET dqat_str = concat (" from " ,dqat_table_name )
   ENDIF
   IF ((size (trim (dqat_table_alias ) ,1 ) > 0 ) )
    SET dqat_str = concat (dqat_str ," " ,dqat_table_alias )
   ENDIF
   SET dq_parser_rec->table_count = (dq_parser_rec->table_count + 1 )
   CALL dq_add_line (dqat_str )
  END ;Subroutine
  SUBROUTINE  dq_add_with (dqaw_control_option )
   IF ((dq_parser_rec->with_count > 0 ) )
    CALL dq_add_line (concat ("," ,dqaw_control_option ) )
   ELSE
    CALL dq_add_line (concat ("with " ,dqaw_control_option ) )
   ENDIF
   SET dq_parser_rec->with_count = (dq_parser_rec->with_count + 1 )
  END ;Subroutine
  SUBROUTINE  dq_begin_insert (dqbi_dummy )
   CALL dq_reset_query (1 )
   CALL dq_add_line ("insert" )
  END ;Subroutine
  SUBROUTINE  dq_begin_select (dqbs_distinct_ind ,dqbs_output_device )
   DECLARE dqbs_str = vc WITH noconstant (" " )
   CALL dq_reset_query (1 )
   IF ((dqbs_distinct_ind = 0 ) )
    SET dqbs_str = "select"
   ELSE
    SET dqbs_str = "select distinct"
   ENDIF
   IF ((size (trim (dqbs_output_device ) ,1 ) > 0 ) )
    SET dqbs_str = concat (dqbs_str ," into " ,dqbs_output_device )
   ENDIF
   CALL dq_add_line (dqbs_str )
  END ;Subroutine
  SUBROUTINE  dq_begin_update (dqbu_dummy )
   CALL dq_reset_query (1 )
   CALL dq_add_line ("update" )
  END ;Subroutine
  SUBROUTINE  dq_echo_query (dqeq_level )
   DECLARE dqeq_i = i4 WITH private ,noconstant (0 )
   DECLARE dqeq_j = i4 WITH private ,noconstant (0 )
   IF ((dqeq_level = 1 ) )
    CALL echo ("-------------------------------------------------------------------" )
    CALL echo ("Parser Buffer Echo:" )
    CALL echo ("-------------------------------------------------------------------" )
    FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count )
     CALL echo (dq_parser_rec->buffer[dqeq_i ].line )
    ENDFOR
    CALL echo ("-------------------------------------------------------------------" )
   ELSEIF ((dqeq_level = 2 ) )
    IF ((validate (reply->debug[1 ].line ,"-9" ) != "-9" ) )
     SET dqeq_j = size (reply->debug ,5 )
     SET stat = alterlist (reply->debug ,((dqeq_j + size (dq_parser_rec->buffer ,5 ) ) + 4 ) )
     SET reply->debug[(dqeq_j + 1 ) ].line =
     "-------------------------------------------------------------------"
     SET reply->debug[(dqeq_j + 2 ) ].line = "Parser Buffer Echo:"
     SET reply->debug[(dqeq_j + 3 ) ].line =
     "-------------------------------------------------------------------"
     FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count )
      SET reply->debug[((dqeq_j + dqeq_i ) + 3 ) ].line = dq_parser_rec->buffer[dqeq_i ].line
     ENDFOR
     SET reply->debug[((dqeq_j + dq_parser_rec->buffer_count ) + 4 ) ].line =
     "-------------------------------------------------------------------"
    ENDIF
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_end_query (dqes_dummy )
   CALL dq_add_line (" go" )
   SET stat = alterlist (dq_parser_rec->buffer ,dq_parser_rec->buffer_count )
  END ;Subroutine
  SUBROUTINE  dq_execute (dqe_reset )
   IF ((checkprg ("PM_DQ_EXECUTE_PARSER" ) > 0 ) )
    EXECUTE pm_dq_execute_parser WITH replace ("TEMP_DQ_PARSER_REC" ,"DQ_PARSER_REC" )
    IF ((dqe_reset = 1 ) )
     SET stat = initrec (dq_parser_rec )
    ENDIF
   ELSE
    DECLARE dqe_i = i4 WITH private ,noconstant (0 )
    FOR (dqe_i = 1 TO dq_parser_rec->buffer_count )
     CALL parser (dq_parser_rec->buffer[dqe_i ].line ,1 )
    ENDFOR
    IF ((dqe_reset = 1 ) )
     CALL dq_reset_query (1 )
    ENDIF
   ENDIF
  END ;Subroutine
  SUBROUTINE  dq_reset_query (dqrb_dummy )
   SET stat = alterlist (dq_parser_rec->buffer ,0 )
   SET dq_parser_rec->buffer_count = 0
   SET dq_parser_rec->plan_count = 0
   SET dq_parser_rec->set_count = 0
   SET dq_parser_rec->table_count = 0
   SET dq_parser_rec->with_count = 0
  END ;Subroutine
 ENDIF
 IF ((validate (pm_create_req_def ,- (9 ) ) = - (9 ) ) )
  DECLARE pm_create_req_def = i2 WITH constant (0 )
  DECLARE cr_hmsg = i4 WITH noconstant (0 )
  DECLARE cr_hmsgtype = i4 WITH noconstant (0 )
  DECLARE cr_hinst = i4 WITH noconstant (0 )
  DECLARE cr_hitem = i4 WITH noconstant (0 )
  DECLARE cr_llevel = i4 WITH noconstant (0 )
  DECLARE cr_lcnt = i4 WITH noconstant (0 )
  DECLARE cr_lcharlen = i4 WITH noconstant (0 )
  DECLARE cr_siterator = i4 WITH noconstant (0 )
  DECLARE cr_lfieldtype = i4 WITH noconstant (0 )
  DECLARE cr_sfieldname = vc WITH noconstant (" " )
  DECLARE cr_blist = i2 WITH noconstant (false )
  DECLARE cr_bfound = i2 WITH noconstant (false )
  DECLARE cr_esrvstring = i4 WITH constant (1 )
  DECLARE cr_esrvshort = i4 WITH constant (2 )
  DECLARE cr_esrvlong = i4 WITH constant (3 )
  DECLARE cr_esrvdouble = i4 WITH constant (6 )
  DECLARE cr_esrvasis = i4 WITH constant (7 )
  DECLARE cr_esrvlist = i4 WITH constant (8 )
  DECLARE cr_esrvstruct = i4 WITH constant (9 )
  DECLARE cr_esrvuchar = i4 WITH constant (10 )
  DECLARE cr_esrvulong = i4 WITH constant (12 )
  DECLARE cr_esrvdate = i4 WITH constant (13 )
  DECLARE cr_createrequest ((mode = i2 ) ,(req_id = i4 ) ,(req_name = vc ) ) = i2
  DECLARE cr_popstack ((dummyvar = i2 ) ) = null
  DECLARE cr_pushstack ((hval = i4 ) ,(sval = i4 ) ) = null
  FREE RECORD cr_stack
  RECORD cr_stack (
    1 list [10 ]
      2 hinst = i4
      2 siterator = i4
  )
  SUBROUTINE  cr_createrequest (mode ,req_id ,req_name )
   SET cr_llevel = 1
   CALL dq_reset_query (null )
   CALL dq_add_line (concat ("free record " ,req_name ," go" ) )
   CALL dq_add_line (concat ("record " ,req_name ) )
   CALL dq_add_line ("(" )
   SET cr_hmsg = uar_srvselectmessage (req_id )
   IF ((cr_hmsg != 0 ) )
    IF ((mode = 0 ) )
     SET cr_hinst = uar_srvcreaterequest (cr_hmsg )
    ELSE
     SET cr_hinst = uar_srvcreatereply (cr_hmsg )
    ENDIF
   ELSE
    SET reply->status_data.operationname = "INVALID_hMsg"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "CREATE_REQUEST"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "GET"
    RETURN (false )
   ENDIF
   IF ((cr_hinst > 0 ) )
    SET cr_sfieldname = uar_srvfirstfield (cr_hinst ,cr_siterator )
    SET cr_sfieldname = trim (cr_sfieldname ,3 )
    CALL cr_pushstack (cr_hinst ,cr_siterator )
   ELSE
    SET reply->status_data.operationname = "INVALID_hInst"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "CREATE_REQUEST"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "GET"
    IF (cr_hinst )
     CALL uar_srvdestroyinstance (cr_hinst )
     SET cr_hinst = 0
    ENDIF
    RETURN (false )
   ENDIF
   WHILE ((textlen (cr_sfieldname ) > 0 ) )
    SET cr_lfieldtype = uar_srvgettype (cr_stack->list[cr_lcnt ].hinst ,nullterm (cr_sfieldname ) )
    CASE (cr_lfieldtype )
     OF cr_esrvstruct :
      SET cr_hitem = 0
      SET cr_hitem = uar_srvgetstruct (cr_stack->list[cr_lcnt ].hinst ,nullterm (cr_sfieldname ) )
      IF ((cr_hitem > 0 ) )
       SET cr_siterator = 0
       CALL cr_pushstack (cr_hitem ,cr_siterator )
       CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ) )
       SET cr_llevel = (cr_llevel + 1 )
       SET cr_blist = true
      ELSE
       SET reply->status_data.operationname = "INVALID_hItem"
       SET reply->status_data.subeventstatus[1 ].targetobjectname = "CREATE_REQUEST"
       SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "GET"
       IF (cr_hinst )
        CALL uar_srvdestroyinstance (cr_hinst )
        SET cr_hinst = 0
       ENDIF
       RETURN (false )
      ENDIF
     OF cr_esrvlist :
      SET cr_hitem = 0
      SET cr_hitem = uar_srvadditem (cr_stack->list[cr_lcnt ].hinst ,nullterm (cr_sfieldname ) )
      IF ((cr_hitem > 0 ) )
       SET cr_siterator = 0
       CALL cr_pushstack (cr_hitem ,cr_siterator )
       CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ,"[*]" ) )
       SET cr_llevel = (cr_llevel + 1 )
       SET cr_blist = true
      ELSE
       SET reply->status_data.operationname = "INVALID_hInst"
       SET reply->status_data.subeventstatus[1 ].targetobjectname = "CREATE_REQUEST"
       SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "GET"
       IF (cr_hinst )
        CALL uar_srvdestroyinstance (cr_hinst )
        SET cr_hinst = 0
       ENDIF
       RETURN (false )
      ENDIF
     OF cr_esrvstring :
      SET cr_lcharlen = uar_srvgetstringmax (cr_stack->list[cr_lcnt ].hinst ,nullterm (cr_sfieldname
        ) )
      IF ((cr_lcharlen > 0 ) )
       CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = c" ,cnvtstring (
          cr_lcharlen ) ) )
      ELSE
       CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = vc" ) )
      ENDIF
     OF cr_esrvuchar :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = c1" ) )
     OF cr_esrvshort :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = i2" ) )
     OF cr_esrvlong :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = i4" ) )
     OF cr_esrvulong :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = ui4" ) )
     OF cr_esrvdouble :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = f8" ) )
     OF cr_esrvdate :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = dq8" ) )
     OF cr_esrvasis :
      CALL dq_add_line (concat (cnvtstring (cr_llevel ) ," " ,cr_sfieldname ," = gvc" ) )
     ELSE
      SET reply->status_data.operationname = "INVALID_SrvType"
      SET reply->status_data.subeventstatus[1 ].targetobjectname = "CREATE_REQUEST"
      SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "GET"
      IF (cr_hinst )
       CALL uar_srvdestroyinstance (cr_hinst )
       SET cr_hinst = 0
      ENDIF
      ,
      RETURN (false )
    ENDCASE
    SET cr_sfieldname = ""
    IF (cr_blist )
     SET cr_sfieldname = uar_srvfirstfield (cr_stack->list[cr_lcnt ].hinst ,cr_stack->list[cr_lcnt ].
      siterator )
     SET cr_sfieldname = trim (cr_sfieldname ,3 )
     SET cr_blist = false
    ELSE
     SET cr_sfieldname = uar_srvnextfield (cr_stack->list[cr_lcnt ].hinst ,cr_stack->list[cr_lcnt ].
      siterator )
     SET cr_sfieldname = trim (cr_sfieldname ,3 )
     IF ((textlen (cr_sfieldname ) <= 0 ) )
      SET cr_bfound = false
      WHILE ((cr_bfound != true ) )
       CALL cr_popstack (null )
       IF ((cr_stack->list[cr_lcnt ].hinst > 0 )
       AND (cr_lcnt > 0 ) )
        SET cr_sfieldname = uar_srvnextfield (cr_stack->list[cr_lcnt ].hinst ,cr_stack->list[cr_lcnt
         ].siterator )
        SET cr_sfieldname = trim (cr_sfieldname ,3 )
       ELSE
        SET cr_bfound = true
       ENDIF
       IF ((textlen (cr_sfieldname ) > 0 ) )
        SET cr_bfound = true
       ENDIF
      ENDWHILE
     ENDIF
    ENDIF
   ENDWHILE
   IF ((mode = 1 ) )
    CALL dq_add_line ("1  status_data" )
    CALL dq_add_line ("2  status  = c1" )
    CALL dq_add_line ("2  subeventstatus[1]" )
    CALL dq_add_line ("3  operationname = c15" )
    CALL dq_add_line ("3  operationstatus = c1" )
    CALL dq_add_line ("3  targetobjectname = c15" )
    CALL dq_add_line ("3  targetobjectvalue = vc" )
   ENDIF
   CALL dq_add_line (")  with persistscript" )
   CALL dq_end_query (null )
   CALL dq_execute (null )
   IF (cr_hinst )
    CALL uar_srvdestroyinstance (cr_hinst )
    SET cr_hinst = 0
   ENDIF
   RETURN (true )
  END ;Subroutine
  SUBROUTINE  cr_popstack (dummyvar )
   SET cr_lcnt = (cr_lcnt - 1 )
   SET cr_llevel = (cr_llevel - 1 )
  END ;Subroutine
  SUBROUTINE  cr_pushstack (hval ,lval )
   SET cr_lcnt = (cr_lcnt + 1 )
   IF ((mod (cr_lcnt ,10 ) = 1 )
   AND (cr_lcnt != 1 ) )
    SET stat = alterlist (cr_stack->list ,(cr_lcnt + 9 ) )
   ENDIF
   SET cr_stack->list[cr_lcnt ].hinst = hval
   SET cr_stack->list[cr_lcnt ].siterator = lval
  END ;Subroutine
 ENDIF
 IF ((validate (bdebugme ,- (9 ) ) = - (9 ) ) )
  DECLARE bdebugme = i2 WITH noconstant (false )
 ENDIF
 IF (NOT (validate (sch_log_message ,0 ) ) )
  DECLARE sch_log_message ((l_event = vc ) ,(l_script_name = vc ) ,(l_message = vc ) ,(l_loglevel =
   i2 ) ) = null
  DECLARE s_log_handle = i4 WITH protect ,noconstant (0 )
  DECLARE s_log_status = i4 WITH protect ,noconstant (0 )
  DECLARE s_message = vc WITH protect ,noconstant ("" )
  SUBROUTINE  sch_log_message (l_event ,l_script_name ,l_message ,l_loglevel )
   IF ((l_loglevel > - (1 ) )
   AND (textlen (trim (l_message ,3 ) ) > 0 ) )
    SET s_message = build ("script::" ,l_script_name ,", message::" ,l_message )
    CALL uar_syscreatehandle (s_log_handle ,s_log_status )
    IF ((s_log_handle != 0 ) )
     CALL uar_sysevent (s_log_handle ,l_loglevel ,nullterm (l_event ) ,nullterm (s_message ) )
     CALL uar_sysdestroyhandle (s_log_handle )
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 DECLARE log_level_error = i4 WITH constant (0 ) ,protect
 DECLARE log_level_warning = i4 WITH constant (1 ) ,protect
 DECLARE log_level_audit = i4 WITH constant (2 ) ,protect
 DECLARE log_level_info = i4 WITH constant (3 ) ,protect
 DECLARE log_level_debug = i4 WITH constant (0 ) ,protect
 DECLARE visit_type_codeset = i4 WITH constant (71 ) ,protect
 DECLARE visit_class_codeset = i4 WITH constant (69 ) ,protect
 DECLARE location_codeset = i4 WITH constant (220 ) ,protect
 DECLARE patient_event_codeset = i4 WITH constant (4002773 ) ,protect
 DECLARE observation_visit_class = f8 WITH constant (uar_get_code_by ("MEANING" ,visit_class_codeset
   ,"OBSERVATION" ) ) ,protect
 DECLARE inpatient_visit_class = f8 WITH constant (uar_get_code_by ("MEANING" ,visit_class_codeset ,
   "INPATIENT" ) ) ,protect
 DECLARE outpatient_visit_class = f8 WITH constant (uar_get_code_by ("MEANING" ,visit_class_codeset ,
   "OUTPATIENT" ) ) ,protect
 DECLARE observation_visit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,
   visit_type_codeset ,"OBSERVATION" ) ) ,protect
 DECLARE inpatient_visit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,visit_type_codeset ,
   "INPATIENT" ) ) ,protect
 DECLARE outpatient_visit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,visit_type_codeset
   ,"OUTPATIENT" ) ) ,protect
 DECLARE observation_patient_event = f8 WITH constant (uar_get_code_by ("MEANING" ,
   patient_event_codeset ,"STARTOBS" ) ) ,protect
 DECLARE inpatient_patient_event = f8 WITH constant (uar_get_code_by ("MEANING" ,
   patient_event_codeset ,"STARTINPAT" ) ) ,protect
 DECLARE outpatient_patient_event = f8 WITH constant (uar_get_code_by ("MEANING" ,
   patient_event_codeset ,"OUTPATINBED" ) ) ,protect
 DECLARE condition_code_44 = f8 WITH constant (uar_get_code_by ("MEANING" ,21790 ,"44" ) ) ,protect
 DECLARE hencntrretrep = i4 WITH noconstant (0 ) ,privateprotect
 DECLARE hencntrretreq = i4 WITH noconstant (0 ) ,privateprotect
 DECLARE hencntrretmsg = i4 WITH noconstant (0 ) ,privateprotect
 DECLARE dencountertypecd = f8 WITH noconstant (0.0 ) ,privateprotect
 DECLARE bmultiencntrtypeperfacility = i2 WITH noconstant (false ) ,protect
 DECLARE dhisttrackingid = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dcontributorsystemcd = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dpmtransactionid = f8 WITH noconstant (0.0 ) ,protect
 DECLARE blank_date = f8 WITH noconstant (cnvtdatetime ("01-JAN-1800 00:00:00.00" ) ) ,protect
 DECLARE lookupencountertype ((dpatienteventtypecd = f8 ) ) = f8
 DECLARE updateencounterinformation ((dencntrid = f8 ) ,(dpersonid = f8 ) ) = i2
 DECLARE cleanuphandles ((dummyvar = i2 ) ) = i2
 DECLARE writetransaction ((dummyvar = i4 ) ) = i2
 DECLARE posttransaction ((dummyvar = i4 ) ) = i2
 DECLARE getorderdetailinfo (null ) = null
 DECLARE getaccomcode (null ) = null
 DECLARE getencntrprsnlreltninfo (null ) = null
 DECLARE setencntrprsnlreltnreq (null ) = null
 SET reply->status_data.status = "F"
 SET stat = moverec (request ,temp_req )
 SET bmultiencntrtypeperfacility = false
 IF ((updateencounterinformation (request->encntr_id ,request->person_id ) = false ) )
  CALL sch_log_message ("UpdateEncounterInformation" ,curprog ,
   "Error calling Encounter Modify Service" ,0 )
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
#exit_script
 SUBROUTINE  updateencounterinformation (dencntrid ,dpersonid )
  DECLARE dencountertypecd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dpatienteventtypecd = f8 WITH noconstant (0.0 ) ,privateprotect
  DECLARE saction = vc WITH noconstant ("" ) ,privateprotect
  DECLARE deventdatetime = f8 WITH noconstant (0.0 ) ,privateprotect
  DECLARE bconditioncode44exists = i2 WITH noconstant (false ) ,protect
  DECLARE baddconditioncode44 = i2 WITH noconstant (false ) ,protect
  DECLARE lconditioncodecount = i4 WITH noconstant (0 ) ,protect
  DECLARE dnewencntrtypeclass = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dprevencntrtypeclass = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dprevencountertypecd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dcurencntrtypeclass = f8 WITH noconstant (0.0 ) ,protect
  DECLARE sadminnotification = vc WITH noconstant ("" ) ,protect
  DECLARE cur_order_mode = vc WITH constant (cnvtupper (trim (request->order_mode ,3 ) ) ) ,protect
  DECLARE transfer_order_mode = vc WITH constant ("TRANSFER_PATIENT_ORDER" ) ,protect
  DECLARE bcreatereq = i2 WITH noconstant (false ) ,protect
  DECLARE lprsnlidx = i4 WITH noconstant (0 ) ,protect
  DECLARE action_begin = i4 WITH noconstant (0 ) ,protect
  DECLARE action_end = i4 WITH noconstant (0 ) ,protect
  DECLARE emergency_type_class = f8 WITH constant (uar_get_code_by ("MEANING" ,visit_class_codeset ,
    "EMERGENCY" ) ) ,protect
  DECLARE edhold_attrib_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,17649 ,"EDHOLD" ) ) ,
  protect
  DECLARE facility_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"FACILITY" ) ) ,
  protect
  DECLARE building_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"BUILDING" ) ) ,
  protect
  DECLARE nurseunit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"NURSEUNIT" ) ) ,
  protect
  DECLARE room_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"ROOM" ) ) ,protect
  DECLARE bed_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"BED" ) ) ,protect
  DECLARE facility_level = i4 WITH constant (5 ) ,protect
  DECLARE building_level = i4 WITH constant (4 ) ,protect
  DECLARE nurse_unit_level = i4 WITH constant (3 ) ,protect
  DECLARE room_level = i4 WITH constant (2 ) ,protect
  DECLARE bed_level = i4 WITH constant (1 ) ,protect
  DECLARE dcurlocationlevel = i4 WITH noconstant (0 ) ,protect
  DECLARE dcurlocationcd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dcurfacilitycd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dcurbuildingcd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dcurnurseunitcd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dcurroomcd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dcurbedcd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE blocattribusageind = i2 WITH noconstant (false ) ,protect
  IF ((cur_order_mode = transfer_order_mode ) )
   CALL getorderdetailinfo (null )
   SELECT INTO "nl:"
    FROM (encounter e )
    WHERE (e.encntr_id = request->encntr_id )
    DETAIL
     dprevencntrtypeclass = e.encntr_type_class_cd ,
     lookup->cur_facility_cd = e.loc_facility_cd
    WITH nocounter
   ;end select
   IF ((dhisttrackingid <= 0.0 ) )
    SET dhisttrackingid = createhisttrackingrow (0 )
   ENDIF
   IF (bdebugme )
    CALL echo (build2 ("*** dHistTrackingId = " ,dhisttrackingid ,"***" ) )
   ENDIF
   SET stat = alterlist (encntr_req->encounter ,1 )
   SET encntr_req->encounter_qual = 1
   SET encntr_req->encounter[1 ].encntr_id = request->encntr_id
   SET encntr_req->encounter[1 ].person_id = request->person_id
   SET encntr_req->encounter[1 ].pm_hist_tracking_id = dhisttrackingid
   SET encntr_req->encounter[1 ].transaction_dt_tm = cnvtdatetime (curdate ,curtime3 )
   IF ((lookup->med_service_cd > 0.0 ) )
    SET encntr_req->encounter[1 ].med_service_cd = lookup->med_service_cd
   ELSE
    IF (bdebugme )
     CALL echo ("*** no update for Medical Service. ***" )
    ENDIF
    CALL sch_log_message ("Medical Service" ,curprog ,"no update for Medical Service" ,
     log_level_debug )
   ENDIF
   IF ((lookup->los_cd > 0.0 ) )
    CALL getaccomcode (null )
    IF ((lookup->accom_cd > 0.0 ) )
     SET encntr_req->encounter[1 ].accommodation_cd = lookup->accom_cd
    ENDIF
   ELSE
    IF (bdebugme )
     CALL echo ("*** no update for Level of Service. ***" )
    ENDIF
    CALL sch_log_message ("Level of Service" ,curprog ,"no update for Level of Service " ,
     log_level_debug )
   ENDIF
   FREE RECORD request
   SET bcreatereq = cr_createrequest (0 ,101305 ,"request" )
   IF ((bcreatereq != true ) )
    IF (bdebugme )
     CALL echo ("*** Create 101305 Request failed, stop updating prsnl. ***" )
    ENDIF
    CALL sch_log_message ("Create 101305 Request" ,curprog ,
     "Error occured while creating request 101305" ,log_level_error )
   ELSE
    CALL getencntrprsnlreltninfo (null )
    CALL setencntrprsnlreltnreq (null )
    FOR (lprsnlidx = 1 TO request->encntr_prsnl_reltn_qual )
     SET request->encntr_prsnl_reltn[lprsnlidx ].pm_hist_tracking_id = dhisttrackingid
     SET request->encntr_prsnl_reltn[lprsnlidx ].transaction_dt_tm = cnvtdatetime (curdate ,curtime3
      )
     SET request->encntr_prsnl_reltn[lprsnlidx ].encntr_id = temp_req->encntr_id
    ENDFOR
   ENDIF
   IF ((writetransaction (0 ) = false ) )
    IF (bdebugme )
     CALL echo ("*** WriteTransaction failed 1 ***" )
    ENDIF
    CALL sch_log_message ("WriteTransaction 1" ,curprog ,"WriteTransaction Failed" ,log_level_error
     )
    RETURN (false )
   ENDIF
   SET action_begin = 1
   SET action_end = 1
   call echo("CALLING EXECUTE PM UPDATE 1")
   EXECUTE pm_upt_encounter WITH replace ("REQUEST" ,encntr_req ) ,
   replace ("REPLY" ,encntr_reply )
   IF ((encntr_reply->status_data.status != "S" ) )
    IF (bdebugme )
     CALL echo ("*** Call to pm_upt_encounter failed ***" )
    ENDIF
    CALL sch_log_message ("pm_upt_encounter" ,curprog ,"pm_upt_encounter Failed" ,log_level_error )
    RETURN (false )
   ENDIF
   IF ((bcreatereq = true ) )
    SET stat = moverec (reply ,temp_rep )
    FREE RECORD reply
    RECORD reply (
      1 encntr_prsnl_reltn_qual = i4
      1 encntr_prsnl_reltn [* ]
        2 encntr_prsnl_reltn_id = f8
        2 pm_hist_tracking_id = f8
      1 status_data
        2 status = c1
        2 subeventstatus [1 ]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH persistscript
    EXECUTE pm_ens_encntr_prsnl_reltn
    IF ((reply->status_data.status != "S" ) )
     FREE RECORD reply
     RECORD reply (
       1 status_data
         2 status = c1
         2 subeventstatus [1 ]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH persistscript
     SET stat = moverec (temp_rep ,reply )
     IF (bdebugme )
      CALL echo ("*** Call to update Admitting/Attending Physician failed ***" )
     ENDIF
     CALL sch_log_message ("Admitting/Attending" ,curprog ,"update Physician failed" ,
      log_level_error )
     RETURN (false )
    ENDIF
    FREE RECORD reply
    RECORD reply (
      1 status_data
        2 status = c1
        2 subeventstatus [1 ]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH persistscript
    SET stat = moverec (temp_rep ,reply )
   ENDIF
   IF ((posttransaction (0 ) = false ) )
    IF (bdebugme )
     CALL echo ("*** PostTransaction failed 1 ***" )
    ENDIF
    CALL sch_log_message ("PostTransaction 1" ,curprog ,"PostTransaction Failed" ,log_level_error )
    RETURN (false )
   ENDIF
   SET sadminnotification = getoutboundmessagetrigger (modify_encounter ,dprevencntrtypeclass ,
    dprevencntrtypeclass )
   IF ((textlen (trim (sadminnotification ,3 ) ) > 0 ) )
    CALL send_outbound (temp_req->person_id ,temp_req->encntr_id ,temp_req->person_id ,
     sadminnotification )
   ENDIF
  ELSE
   IF ((size (request->patient_event ,5 ) > 0 ) )
    SET dpatienteventtypecd = request->patient_event[1 ].event_type_cd
    SET saction = request->patient_event[1 ].action
    SET deventdatetime = request->patient_event[1 ].event_dt_tm
    IF ((((dpatienteventtypecd <= 0.0 ) ) OR ((((textlen (trim (saction ,3 ) ) <= 0 ) ) OR ((
    deventdatetime <= 0.0 ) )) )) )
     IF (bdebugme )
      CALL echo ("*** Missing data - UpdateEncounterInformation - patient_event data" )
     ENDIF
     CALL sch_log_message ("UpdateEncounterInformation" ,curprog ,
      "*** Missing data - UpdateEncounterInformation - patient_event data" ,log_level_error )
     RETURN (false )
    ENDIF
   ENDIF
   IF ((((dpatienteventtypecd = observation_patient_event ) ) OR ((((dpatienteventtypecd =
   inpatient_patient_event ) ) OR ((dpatienteventtypecd = outpatient_patient_event ) )) )) )
    SET dencountertypecd = lookupencountertype (dpatienteventtypecd )
   ENDIF
   IF ((dencountertypecd <= 0 ) )
    IF (bdebugme )
     CALL echo (build2 ("ERROR: codeValue for encounterTypeCd = " ,dencountertypecd ," not found." )
      )
    ENDIF
    CALL sch_log_message ("UpdateEncounterInformation" ,curprog ,build2 (
      "ERROR: dEncounterTypeCd = " ,dencountertypecd ," not found." ) ,log_level_error )
    RETURN (false )
   ENDIF
   IF ((((request->encntr_id <= 0.0 ) ) OR ((request->person_id <= 0.0 ) )) )
    IF (bdebugme )
     CALL echo ("*** Missing data - UpdateEncounterInformation" )
    ENDIF
    CALL sch_log_message ("UpdateEncounterInformation" ,curprog ,build2 (
      "ERROR: request->encntr_id = " ,request->encntr_id ," and request->person_id = " ,request->
      person_id ) ,log_level_error )
    RETURN (false )
   ENDIF
   IF (bdebugme )
    CALL echo (build2 ("Updating encounter_id:" ,request->encntr_id ," " ,
      "Encounter Type to encntr_type_cd: " ,dencountertypecd ) )
    CALL sch_log_message ("UpdateEncounterInformation" ,curprog ,build2 ("Updating encounter_id:" ,
      request->encntr_id ," " ,"Encounter Type to encntr_type_cd: " ,dencountertypecd ) ,
     log_level_debug )
   ENDIF
   CASE (saction )
    OF "ADD" :
     SET bconditioncode44exists = false
     SELECT INTO "nl:"
      FROM (order_detail od )
      WHERE (od.order_id = request->order_id )
      DETAIL
       IF ((od.oe_field_meaning = "CONDITIONCODE44" ) )
        IF ((od.oe_field_value = 1.0 ) ) bconditioncode44exists = true
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (bconditioncode44exists )
      SET baddconditioncode44 = true
      SET lconditioncodecount = 0
      SELECT INTO "nl:"
       FROM (encntr_condition_code ecc )
       WHERE (ecc.encntr_id = request->encntr_id )
       AND (ecc.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (ecc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
       AND (ecc.active_ind = 1 )
       DETAIL
        IF ((ecc.condition_cd = condition_code_44 ) ) baddconditioncode44 = false
        ENDIF
        ,
        IF (baddconditioncode44 )
         IF ((mod (lconditioncodecount ,10 ) = 0 ) ) stat = alterlist (pft_upt_condition_codes_req->
           code ,(lconditioncodecount + 10 ) )
         ENDIF
         ,lconditioncodecount = (lconditioncodecount + 1 ) ,pft_upt_condition_codes_req->code[
         lconditioncodecount ].condition_cd = ecc.condition_cd
        ENDIF
       WITH nocounter
      ;end select
      IF (baddconditioncode44 )
       IF ((mod (lconditioncodecount ,10 ) = 0 ) )
        SET stat = alterlist (pft_upt_condition_codes_req->code ,(lconditioncodecount + 10 ) )
       ENDIF
       SET lconditioncodecount = (lconditioncodecount + 1 )
       SET pft_upt_condition_codes_req->encntr_id = request->encntr_id
       SET pft_upt_condition_codes_req->code[lconditioncodecount ].condition_cd = condition_code_44
       SET stat = alterlist (pft_upt_condition_codes_req->code ,lconditioncodecount )
       EXECUTE pft_upt_condition_codes WITH replace ("REQUEST" ,pft_upt_condition_codes_req ) ,
       replace ("REPLY" ,pft_upt_condition_codes_reply )
       IF ((pft_upt_condition_codes_reply->status_data.status = "F" ) )
        CALL sch_log_message ("pft_upt_condition_codes" ,curprog ,"pft_upt_condition_codes Failed" ,
         log_level_debug )
        CALL setreplystatusblock (pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].
         operationname ,pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].operationstatus
          ,pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].targetobjectname ,
         pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].targetobjectvalue )
        GO TO 9999_exit_program
       ENDIF
      ENDIF
     ENDIF
     ,
     CALL getorderdetailinfo (null )
     SELECT INTO "nl:"
      FROM (encounter e )
      WHERE (e.encntr_id = request->encntr_id )
      DETAIL
       dprevencntrtypeclass = e.encntr_type_class_cd ,
       dcontributorsystemcd = e.contributor_system_cd ,
       dcurlocationcd = e.location_cd ,
       dcurfacilitycd = e.loc_facility_cd ,
       dcurbuildingcd = e.loc_building_cd ,
       dcurnurseunitcd = e.loc_nurse_unit_cd ,
       dcurroomcd = e.loc_room_cd ,
       dcurbedcd = e.loc_bed_cd
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (code_value cv ),
       (code_value_group cvg )
      PLAN (cv
       WHERE (cv.code_set = visit_class_codeset )
       AND (cv.active_ind = 1 )
       AND (cv.begin_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (cv.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
       JOIN (cvg
       WHERE (cvg.parent_code_value = cv.code_value )
       AND (cvg.child_code_value = dencountertypecd ) )
      DETAIL
       dnewencntrtypeclass = cvg.parent_code_value
      WITH nocounter
     ;end select
     IF ((dnewencntrtypeclass <= 0.0 ) )
      IF (bdebugme )
       CALL echo (build2 ("ERROR: dNewEncntrTypeClass = " ,dnewencntrtypeclass ) )
      ENDIF
      CALL sch_log_message ("UpdateEncounterInformation" ,curprog ,build2 (
        "ERROR: dNewEncntrTypeClass = " ,dnewencntrtypeclass ) ,log_level_error )
      RETURN (false )
     ENDIF
     ,
     IF ((dhisttrackingid <= 0.0 ) )
      SET dhisttrackingid = createhisttrackingrow (0 )
     ENDIF
     ,
     IF (bdebugme )
      CALL echo (build2 ("*** dHistTrackingId = " ,dhisttrackingid ,"***" ) )
     ENDIF
     ,
     SET stat = alterlist (encntr_req->encounter ,1 )
     SET encntr_req->encounter_qual = 1
     SET encntr_req->encounter[1 ].encntr_id = request->encntr_id
     SET encntr_req->encounter[1 ].person_id = request->person_id
     SET encntr_req->encounter[1 ].encntr_type_cd = dencountertypecd
     SET encntr_req->encounter[1 ].encntr_type_class_cd = dnewencntrtypeclass
     SET encntr_req->encounter[1 ].pm_hist_tracking_id = dhisttrackingid
     SET encntr_req->encounter[1 ].transaction_dt_tm = cnvtdatetime (deventdatetime )
     IF ((lookup->med_service_cd > 0.0 ) )
      SET encntr_req->encounter[1 ].med_service_cd = lookup->med_service_cd
     ELSE
      IF (bdebugme )
       CALL echo ("*** no update for Medical Service. ***" )
      ENDIF
      CALL sch_log_message ("Medical Service" ,curprog ,"no update for Medical Service" ,
       log_level_debug )
     ENDIF
     ,
     IF ((lookup->los_cd > 0.0 ) )
      SET lookup->cur_facility_cd = dcurfacilitycd
      CALL getaccomcode (null )
      IF ((lookup->accom_cd > 0.0 ) )
       SET encntr_req->encounter[1 ].accommodation_cd = lookup->accom_cd
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo ("*** no update for Level of Service. ***" )
      ENDIF
      CALL sch_log_message ("Level of Service" ,curprog ,"no update for Level of Service " ,
       log_level_debug )
     ENDIF
     ,
     IF ((((dpatienteventtypecd = observation_patient_event ) ) OR ((dpatienteventtypecd =
     inpatient_patient_event ) ))
     AND (dprevencntrtypeclass = emergency_type_class )
     AND (dcurlocationcd > 0.0 )
     AND (edhold_attrib_type_cd > 0.0 ) )
      SELECT INTO "nl:"
       FROM (pm_loc_attrib pla )
       WHERE (pla.attrib_type_cd = edhold_attrib_type_cd )
       AND (pla.active_ind = 1 )
       AND (pla.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (pla.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
       DETAIL
        blocattribusageind = true
       WITH nocounter ,maxrec = 1
      ;end select
      IF ((blocattribusageind = true ) )
       SELECT INTO "nl:"
        FROM (location l )
        WHERE (l.location_cd = dcurlocationcd )
        AND (l.active_ind = 1 )
        AND (l.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
        AND (l.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
        DETAIL
         CASE (l.location_type_cd )
          OF facility_type_cd :
           dcurlocationlevel = facility_level
          OF building_type_cd :
           dcurlocationlevel = building_level
          OF nurseunit_type_cd :
           dcurlocationlevel = nurse_unit_level
          OF room_type_cd :
           dcurlocationlevel = room_level
          OF bed_type_cd :
           dcurlocationlevel = bed_level
         ENDCASE
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM (pm_loc_attrib pla )
        WHERE (pla.attrib_type_cd = edhold_attrib_type_cd )
        AND (pla.active_ind = 1 )
        AND (pla.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
        AND (pla.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
        DETAIL
         CASE (pla.location_cd )
          OF dcurfacilitycd :
           IF ((facility_level >= dcurlocationlevel ) ) encntr_req->encounter[1 ].loc_facility_cd =
            pla.value_cd
           ENDIF
          OF dcurbuildingcd :
           IF ((building_level >= dcurlocationlevel ) ) encntr_req->encounter[1 ].loc_building_cd =
            pla.value_cd
           ENDIF
          OF dcurnurseunitcd :
           IF ((nurse_unit_level >= dcurlocationlevel ) ) encntr_req->encounter[1 ].loc_nurse_unit_cd
             = pla.value_cd
           ENDIF
          OF dcurroomcd :
           IF ((room_level >= dcurlocationlevel ) ) encntr_req->encounter[1 ].loc_room_cd = pla
            .value_cd
           ENDIF
          OF dcurbedcd :
           IF ((bed_level >= dcurlocationlevel ) ) encntr_req->encounter[1 ].loc_bed_cd = pla
            .value_cd
           ENDIF
         ENDCASE
        WITH nocounter
       ;end select
       CASE (dcurlocationlevel )
        OF facility_level :
         IF ((encntr_req->encounter[1 ].loc_facility_cd > 0.0 ) )
          SET encntr_req->encounter[1 ].location_cd = encntr_req->encounter[1 ].loc_facility_cd
         ENDIF
        OF building_level :
         IF ((encntr_req->encounter[1 ].loc_building_cd > 0.0 ) )
          SET encntr_req->encounter[1 ].location_cd = encntr_req->encounter[1 ].loc_building_cd
         ENDIF
        OF nurse_unit_level :
         IF ((encntr_req->encounter[1 ].loc_nurse_unit_cd > 0.0 ) )
          SET encntr_req->encounter[1 ].location_cd = encntr_req->encounter[1 ].loc_nurse_unit_cd
         ENDIF
        OF room_level :
         IF ((encntr_req->encounter[1 ].loc_room_cd > 0.0 ) )
          SET encntr_req->encounter[1 ].location_cd = encntr_req->encounter[1 ].loc_room_cd
         ENDIF
        OF bed_level :
         IF ((encntr_req->encounter[1 ].loc_bed_cd > 0.0 ) )
          SET encntr_req->encounter[1 ].location_cd = encntr_req->encounter[1 ].loc_bed_cd
         ENDIF
       ENDCASE
      ELSE
       IF (bdebugme )
        CALL echo ("*** Location update failed. No ED Hold Attribute built up ***" )
       ENDIF
       CALL sch_log_message ("Location" ,curprog ,"Location update failed" ,log_level_error )
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo ("*** Location update failed. Scenario is not qualified or building issue ***" )
      ENDIF
      CALL sch_log_message ("Location" ,curprog ,"Location update failed" ,log_level_error )
     ENDIF
     ,
     CASE (dpatienteventtypecd )
      OF outpatient_patient_event :
      OF observation_patient_event :
       SET encntr_req->encounter[1 ].inpatient_admit_dt_tm = blank_date
      OF inpatient_patient_event :
       SELECT INTO "nl:"
        FROM (patient_event pe )
        WHERE (pe.encntr_id = request->encntr_id )
        AND (pe.active_ind = 1 )
        ORDER BY pe.transaction_dt_tm
        HEAD pe.encntr_id
         encntr_req->encounter[1 ].inpatient_admit_dt_tm = request->patient_event[1 ].event_dt_tm
        WITH nocounter
       ;end select
     ENDCASE
     ,
     FREE RECORD request
     SET bcreatereq = cr_createrequest (0 ,101305 ,"request" )
     IF ((bcreatereq != true ) )
      IF (bdebugme )
       CALL echo ("*** Create 101305 Request failed, stop updating prsnl. ***" )
      ENDIF
      CALL sch_log_message ("Create 101305 Request" ,curprog ,
       "Error occured while creating request 101305" ,log_level_error )
     ELSE
      CALL getencntrprsnlreltninfo (null )
      CALL setencntrprsnlreltnreq (null )
      FOR (lprsnlidx = 1 TO request->encntr_prsnl_reltn_qual )
       SET request->encntr_prsnl_reltn[lprsnlidx ].pm_hist_tracking_id = dhisttrackingid
       SET request->encntr_prsnl_reltn[lprsnlidx ].transaction_dt_tm = cnvtdatetime (curdate ,
        curtime3 )
       SET request->encntr_prsnl_reltn[lprsnlidx ].encntr_id = temp_req->encntr_id
      ENDFOR
     ENDIF
     ,
     IF ((writetransaction (0 ) = false ) )
      IF (bdebugme )
       CALL echo ("*** WriteTransaction failed 1 ***" )
      ENDIF
      CALL sch_log_message ("WriteTransaction 1" ,curprog ,"WriteTransaction Failed" ,
       log_level_error )
      RETURN (false )
     ENDIF
     ,
     SET action_begin = 1
     SET action_end = 1
     EXECUTE pm_upt_encounter WITH replace ("REQUEST" ,encntr_req ) ,
     replace ("REPLY" ,encntr_reply )
     IF ((encntr_reply->status_data.status != "S" ) )
      IF (bdebugme )
       CALL echo ("*** Call to pm_upt_encounter failed ***" )
      ENDIF
      CALL sch_log_message ("pm_upt_encounter" ,curprog ,"pm_upt_encounter Failed" ,log_level_error
       )
      RETURN (false )
     ENDIF
     ,
     IF ((bcreatereq = true ) )
      SET stat = moverec (reply ,temp_rep )
      FREE RECORD reply
      RECORD reply (
        1 encntr_prsnl_reltn_qual = i4
        1 encntr_prsnl_reltn [* ]
          2 encntr_prsnl_reltn_id = f8
          2 pm_hist_tracking_id = f8
        1 status_data
          2 status = c1
          2 subeventstatus [1 ]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      ) WITH persistscript
      EXECUTE pm_ens_encntr_prsnl_reltn
      IF ((reply->status_data.status != "S" ) )
       FREE RECORD reply
       RECORD reply (
         1 status_data
           2 status = c1
           2 subeventstatus [1 ]
             3 operationname = c25
             3 operationstatus = c1
             3 targetobjectname = c25
             3 targetobjectvalue = vc
       ) WITH persistscript
       SET stat = moverec (temp_rep ,reply )
       IF (bdebugme )
        CALL echo ("*** Call to update Admitting/Attending Physician failed ***" )
       ENDIF
       CALL sch_log_message ("Admitting/Attending" ,curprog ,"update Physician failed" ,
        log_level_error )
       RETURN (false )
      ENDIF
      FREE RECORD reply
      RECORD reply (
        1 status_data
          2 status = c1
          2 subeventstatus [1 ]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      ) WITH persistscript
      SET stat = moverec (temp_rep ,reply )
     ENDIF
     ,
     IF ((posttransaction (0 ) = false ) )
      IF (bdebugme )
       CALL echo ("*** PostTransaction failed 1 ***" )
      ENDIF
      CALL sch_log_message ("PostTransaction 1" ,curprog ,"PostTransaction Failed" ,log_level_error
       )
      RETURN (false )
     ENDIF
     ,
     SET sadminnotification = getoutboundmessagetrigger (modify_encounter ,dprevencntrtypeclass ,
      dnewencntrtypeclass )
     IF ((textlen (trim (sadminnotification ,3 ) ) > 0 ) )
      CALL send_outbound (temp_req->person_id ,temp_req->encntr_id ,temp_req->person_id ,
       sadminnotification )
     ENDIF
    OF "DEL" :
     SET bconditioncode44exists = false
     SELECT INTO "nl:"
      FROM (order_detail od )
      WHERE (od.order_id = request->order_id )
      AND (od.oe_field_meaning = "CONDITIONCODE44" )
      DETAIL
       IF ((od.oe_field_value = 1.0 ) ) bconditioncode44exists = true
       ENDIF
      WITH nocounter
     ;end select
     IF (bconditioncode44exists )
      SET lconditioncodecount = 0
      SET pft_upt_condition_codes_req->encntr_id = request->encntr_id
      SELECT INTO "nl:"
       FROM (encntr_condition_code ecc )
       WHERE (ecc.encntr_id = request->encntr_id )
       AND (ecc.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (ecc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
       AND (ecc.active_ind = 1 )
       DETAIL
        IF ((ecc.condition_cd != condition_code_44 ) )
         IF ((mod (lconditioncodecount ,10 ) = 0 ) ) stat = alterlist (pft_upt_condition_codes_req->
           code ,(lconditioncodecount + 10 ) )
         ENDIF
         ,lconditioncodecount = (lconditioncodecount + 1 ) ,pft_upt_condition_codes_req->code[
         lconditioncodecount ].condition_cd = ecc.condition_cd
        ENDIF
       WITH nocounter
      ;end select
      SET stat = alterlist (pft_upt_condition_codes_req->code ,lconditioncodecount )
      EXECUTE pft_upt_condition_codes WITH replace ("REQUEST" ,pft_upt_condition_codes_req ) ,
      replace ("REPLY" ,pft_upt_condition_codes_reply )
      IF ((pft_upt_condition_codes_reply->status_data.status = "F" ) )
       CALL sch_log_message ("pft_upt_condition_codes" ,curprog ,"pft_upt_condition_codes Failed" ,
        log_level_debug )
       CALL setreplystatusblock (pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].
        operationname ,pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].operationstatus
        ,pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].targetobjectname ,
        pft_upt_condition_codes_reply->status_data.subeventstatus[1 ].targetobjectvalue )
       GO TO 9999_exit_program
      ENDIF
     ENDIF
     ,
     SET dcurencntrtypeclass = 0.0
     SELECT INTO "nl:"
      FROM (encounter e )
      WHERE (e.encntr_id = request->encntr_id )
      DETAIL
       IF ((e.encntr_type_cd = dencountertypecd ) ) dcurencntrtypeclass = e.encntr_type_class_cd
       ENDIF
       ,dcontributorsystemcd = e.contributor_system_cd
      WITH nocounter
     ;end select
     IF ((dcurencntrtypeclass > 0.0 ) )
      SELECT INTO "nl:"
       FROM (encntr_flex_hist efh )
       WHERE (efh.encntr_id = request->encntr_id )
       AND (efh.active_ind = 1 )
       ORDER BY cnvtdatetime (efh.updt_dt_tm ) DESC
       DETAIL
        IF ((efh.encntr_type_cd != dencountertypecd )
        AND (dprevencountertypecd <= 0.0 ) ) dprevencountertypecd = efh.encntr_type_cd ,
         dprevencntrtypeclass = efh.encntr_type_class_cd
        ENDIF
       WITH nocounter
      ;end select
      IF ((dhisttrackingid <= 0.0 ) )
       SET dhisttrackingid = createhisttrackingrow (0 )
      ENDIF
      IF (bdebugme )
       CALL echo (build2 ("*** dHistTrackingId = " ,dhisttrackingid ,"***" ) )
      ENDIF
      SET stat = alterlist (encntr_req->encounter ,1 )
      SET encntr_req->encounter_qual = 1
      SET encntr_req->encounter[1 ].encntr_id = request->encntr_id
      SET encntr_req->encounter[1 ].person_id = request->person_id
      SET encntr_req->encounter[1 ].encntr_type_cd = dprevencountertypecd
      SET encntr_req->encounter[1 ].encntr_type_class_cd = dprevencntrtypeclass
      SET encntr_req->encounter[1 ].pm_hist_tracking_id = dhisttrackingid
      SET encntr_req->encounter[1 ].transaction_dt_tm = cnvtdatetime (deventdatetime )
      IF ((dpatienteventtypecd = inpatient_patient_event ) )
       SET encntr_req->encounter[1 ].inpatient_admit_dt_tm = blank_date
      ENDIF
      IF ((writetransaction (0 ) = false ) )
       IF (bdebugme )
        CALL echo ("*** WriteTransaction failed 2 ***" )
       ENDIF
       CALL sch_log_message ("WriteTransaction 2" ,curprog ,"WriteTransaction Failed" ,
        log_level_error )
       RETURN (false )
      ENDIF
      EXECUTE pm_upt_encounter WITH replace ("REQUEST" ,encntr_req ) ,
      replace ("REPLY" ,encntr_reply )
      IF ((encntr_reply->status_data.status != "S" ) )
       IF (bdebugme )
        CALL echo ("*** Call to pm_upt_encounter failed ***" )
       ENDIF
       CALL sch_log_message ("pm_upt_encounter" ,curprog ,"pm_upt_encounter Failed" ,log_level_error
        )
       RETURN (false )
      ENDIF
      IF ((posttransaction (0 ) = false ) )
       IF (bdebugme )
        CALL echo ("*** PostTransaction failed 2 ***" )
       ENDIF
       CALL sch_log_message ("PostTransaction 2" ,curprog ,"PostTransaction Failed" ,log_level_error
        )
       RETURN (false )
      ENDIF
      SET sadminnotification = getoutboundmessagetrigger (modify_encounter ,dprevencntrtypeclass ,
       dnewencntrtypeclass )
      IF ((textlen (trim (sadminnotification ,3 ) ) > 0 ) )
       CALL send_outbound (request->person_id ,request->encntr_id ,request->person_id ,
        sadminnotification )
      ENDIF
     ENDIF
   ENDCASE
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  cleanuphandles (dummyvar )
  IF (hencntrretreq )
   CALL uar_srvdestroyinstance (hencntrretreq )
  ENDIF
  IF (hencntrretrep )
   CALL uar_srvdestroyinstance (hencntrretrep )
  ENDIF
  IF (hencntrretmsg )
   CALL uar_srvdestroymessage (hencntrretmsg )
  ENDIF
 END ;Subroutine
 SUBROUTINE  lookupencountertype (dpatienteventtypecd )
  DECLARE dencountertypelookupcd = f8 WITH noconstant (- (1 ) ) ,protect
  DECLARE dfacilitycd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE dencounterclasscd = f8 WITH noconstant (0.0 ) ,protect
  IF ((bmultiencntrtypeperfacility = false ) )
   CASE (dpatienteventtypecd )
    OF observation_patient_event :
     SET dencountertypelookupcd = observation_visit_type_cd
    OF inpatient_patient_event :
     SET dencountertypelookupcd = inpatient_visit_type_cd
    OF outpatient_patient_event :
     SET dencountertypelookupcd = outpatient_visit_type_cd
   ENDCASE
  ELSE
   SELECT INTO "nl:"
    FROM (encounter e )
    WHERE (e.encntr_id = request->encntr_id )
    DETAIL
     dfacilitycd = e.loc_facility_cd
    WITH nocounter
   ;end select
   CASE (dpatienteventtypecd )
    OF observation_patient_event :
     SET dencounterclasscd = observation_visit_class
    OF inpatient_patient_event :
     SET dencounterclasscd = inpatient_visit_class
    OF outpatient_patient_event :
     SET dencounterclasscd = outpatient_visit_class
   ENDCASE
   IF ((dfacilitycd > 0.0 )
   AND (dencounterclasscd > 0.0 ) )
    SELECT INTO "nl:"
     FROM (code_value_group cvg ),
      (code_value cv ),
      (code_value_group cvg2 )
     PLAN (cvg
      WHERE (cvg.code_set = location_codeset )
      AND (cvg.child_code_value = dfacilitycd ) )
      JOIN (cv
      WHERE (cv.code_value = cvg.parent_code_value )
      AND (cv.code_set = visit_type_codeset ) )
      JOIN (cvg2
      WHERE (cvg2.child_code_value = cv.code_value )
      AND (cvg2.parent_code_value = dencounterclasscd ) )
     DETAIL
      dencountertypelookupcd = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  RETURN (dencountertypelookupcd )
 END ;Subroutine
 SUBROUTINE  writetransaction (dummyvar )
  SET stat = initrec (pm_ens_transaction_request )
  SET pm_ens_transaction_request->transaction_id = dpmtransactionid
  SET pm_ens_transaction_request->person_id = temp_req->person_id
  SET pm_ens_transaction_request->encntr_id = temp_req->encntr_id
  SET pm_ens_transaction_request->transaction_dt_tm = cnvtdatetime (curdate ,curtime3 )
  SET pm_ens_transaction_request->transaction = "UPDT"
  SET pm_ens_transaction_request->pm_hist_tracking_id = dhisttrackingid
  SET stat = initrec (pm_trans_reply )
  EXECUTE pm_ens_transaction WITH replace ("REQUEST" ,pm_ens_transaction_request ) ,
  replace ("REPLY" ,pm_trans_reply )
  IF ((pm_trans_reply->status_data.status = "S" ) )
   SET dpmtransactionid = pm_trans_reply->trans.transaction_id
  ELSE
   RETURN (false )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  posttransaction (dummyvar )
  IF ((writetransaction (0 ) = true ) )
   COMMIT
   EXECUTE pm_call_post_transaction WITH replace ("REQUEST" ,pm_trans_reply )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  createhisttrackingrow (dummyvar )
  FREE RECORD hist_tracking_req
  RECORD hist_tracking_req (
    1 action_flag = i2
    1 conv_task_number = i4
    1 transaction_dt_tm = dq8
    1 pm_hist_tracking_id = f8
    1 person_id = f8
    1 encntr_id = f8
    1 contributor_system_cd = f8
    1 transaction_reason_cd = f8
    1 transaction_reason_txt = c100
    1 transaction_type_txt = c4
    1 hl7_event = c10
  )
  SET hist_tracking_req->action_flag = 3
  SET hist_tracking_req->pm_hist_tracking_id = 0.0
  SET hist_tracking_req->person_id = request->person_id
  SET hist_tracking_req->encntr_id = request->encntr_id
  SET hist_tracking_req->contributor_system_cd = dcontributorsystemcd
  SET hist_tracking_req->transaction_dt_tm = cnvtdatetime (curdate ,curtime3 )
  SET hist_tracking_req->transaction_reason_txt = "UPDATE ENCOUNTER"
  SET hist_tracking_req->transaction_type_txt = "UPDT"
  IF ((validate (hist_tracking_reply->pm_hist_tracking_id ,- (99 ) ) = - (99 ) ) )
   RECORD hist_tracking_reply (
     1 pm_hist_tracking_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  EXECUTE pm_ens_hist_tracking WITH replace ("REQUEST" ,hist_tracking_req ) ,
  replace ("REPLY" ,hist_tracking_reply )
  IF ((hist_tracking_reply->status_data.status = "S" ) )
   RETURN (hist_tracking_reply->pm_hist_tracking_id )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getorderdetailinfo (null )
  DECLARE medservice_codeset = i4 WITH constant (34 ) ,protect
  DECLARE observation_los_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,20790 ,"OBSLOS" ) ) ,
  protect
  DECLARE attend_meaning_id = f8 WITH constant (6028.0 ) ,protect
  DECLARE admit_meaning_id = f8 WITH constant (6027.0 ) ,protect
  IF ((observation_los_cd > 0.0 ) )
   SELECT INTO "nl:"
    FROM (code_value_extension cve )
    WHERE (cve.code_set = 20790 )
    AND (cve.code_value = observation_los_cd )
    AND (cve.field_name = "OPTION" )
    DETAIL
     IF ((trim (cve.field_value ,3 ) != "" ) ) lookup->los_codeset = cnvtreal (trim (cve.field_value
        ,3 ) )
     ENDIF
    WITH nocounter
   ;end select
   IF (bdebugme )
    CALL echo (build2 ("Level of Service code set:" ,lookup->los_codeset ) )
   ENDIF
  ELSE
   IF (bdebugme )
    CALL echo ("OBSERVATION_LOS_CD <= 0.0" )
   ENDIF
   CALL sch_log_message ("Level of Service code set" ,curprog ,"code set is less or equal to 0.0" ,
    log_level_debug )
  ENDIF
  SELECT INTO "nl:"
   FROM (order_detail od ),
    (order_entry_fields oef )
   PLAN (od
    WHERE (od.order_id = request->order_id ) )
    JOIN (oef
    WHERE (oef.oe_field_id = od.oe_field_id ) )
   DETAIL
    IF ((oef.codeset = lookup->los_codeset )
    AND (lookup->los_codeset > 0.0 ) ) lookup->los_cd = od.oe_field_value
    ELSEIF ((oef.codeset = medservice_codeset ) ) lookup->med_service_cd = od.oe_field_value
    ENDIF
    ,
    IF ((oef.oe_field_meaning_id = attend_meaning_id ) ) lookup->attend_physician_id = od
     .oe_field_value
    ELSEIF ((oef.oe_field_meaning_id = admit_meaning_id ) ) lookup->admit_physician_id = od
     .oe_field_value
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getaccomcode (null )
  DECLARE accom_codeset = i4 WITH constant (10 ) ,protect
  DECLARE accomodation_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,30620 ,"CS10" ) ) ,
  protect
  DECLARE laccomcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE bpprusageind = i2 WITH noconstant (false ) ,protect
  DECLARE dtempaccomcd = f8 WITH noconstant (0.0 ) ,protect
  SELECT INTO "nl:"
   FROM (filter_entity_reltn fer )
   WHERE (fer.filter_type_cd = accomodation_type_cd )
   AND (fer.filter_entity1_id = lookup->cur_facility_cd )
   AND (fer.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (fer.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   DETAIL
    bpprusageind = true
   WITH nocounter ,maxrec = 1
  ;end select
  IF ((bpprusageind = true ) )
   SELECT INTO "nl:"
    FROM (code_value cv ),
     (code_value_group cvg ),
     (filter_entity_reltn fer )
    PLAN (cv
     WHERE (cv.code_set = lookup->los_codeset )
     AND (cv.code_value = lookup->los_cd ) )
     JOIN (cvg
     WHERE (cv.code_value = cvg.parent_code_value )
     AND (cvg.code_set = accom_codeset ) )
     JOIN (fer
     WHERE (fer.filter_type_cd = accomodation_type_cd )
     AND (fer.filter_entity1_id = lookup->cur_facility_cd )
     AND (fer.parent_entity_id = cvg.child_code_value )
     AND (fer.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (fer.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    HEAD REPORT
     laccomcnt = 0
    DETAIL
     laccomcnt = (laccomcnt + 1 ) ,
     dtempaccomcd = cvg.child_code_value
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (code_value cv ),
     (code_value_group cvg )
    PLAN (cv
     WHERE (cv.code_set = lookup->los_codeset )
     AND (cv.code_value = lookup->los_cd ) )
     JOIN (cvg
     WHERE (cv.code_value = cvg.parent_code_value )
     AND (cvg.code_set = accom_codeset ) )
    HEAD REPORT
     laccomcnt = 0
    DETAIL
     laccomcnt = (laccomcnt + 1 ) ,
     dtempaccomcd = cvg.child_code_value
    WITH nocounter
   ;end select
  ENDIF
  IF ((laccomcnt = 1 ) )
   SET lookup->accom_cd = dtempaccomcd
  ELSE
   IF (bdebugme )
    CALL echo ("*** Level of Service failed. More than one or nothing built up ***" )
    CALL echo (build2 ("lAccomCnt:" ,laccomcnt ) )
   ENDIF
   CALL sch_log_message ("Level of Service" ,curprog ,"Level of Service Failed" ,log_level_debug )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getencntrprsnlreltninfo (null )
  DECLARE attenddoc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,333 ,"ATTENDDOC" ) ) ,protect
  DECLARE admitdoc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,333 ,"ADMITDOC" ) ) ,protect
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr )
   WHERE (epr.encntr_id = temp_req->encntr_id )
   AND (epr.active_ind = 1 )
   AND (epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (epr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   ORDER BY epr.encntr_prsnl_r_cd ,
    epr.beg_effective_dt_tm
   DETAIL
    IF ((epr.encntr_prsnl_r_cd = attenddoc_cd ) ) lookup->attend_reltn_id = epr
     .encntr_prsnl_reltn_id
    ENDIF
    ,
    IF ((epr.encntr_prsnl_r_cd = admitdoc_cd ) ) lookup->admit_reltn_id = epr.encntr_prsnl_reltn_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (order_action oa )
   WHERE (oa.order_id = temp_req->order_id )
   ORDER BY oa.action_sequence DESC
   HEAD oa.action_sequence
    lookup->order_physician_id = oa.order_provider_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  setencntrprsnlreltnreq (null )
  DECLARE attenddoc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,333 ,"ATTENDDOC" ) ) ,protect
  DECLARE admitdoc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,333 ,"ADMITDOC" ) ) ,protect
  DECLARE lcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE dtempphysicianid = f8 WITH noconstant (0.0 ) ,protect
  CASE (cur_order_mode )
   OF transfer_order_mode :
    IF ((lookup->attend_physician_id > 0.0 ) )
     IF ((lookup->attend_reltn_id > 0.0 ) )
      SET lcnt = (lcnt + 1 )
      SET stat = alterlist (request->encntr_prsnl_reltn ,lcnt )
      SET request->encntr_prsnl_reltn[lcnt ].action_type = "UPT"
      SET request->encntr_prsnl_reltn[lcnt ].prsnl_person_id = lookup->attend_physician_id
      SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_reltn_id = lookup->attend_reltn_id
      SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_r_cd = attenddoc_cd
     ELSE
      SET lcnt = (lcnt + 1 )
      SET stat = alterlist (request->encntr_prsnl_reltn ,lcnt )
      SET request->encntr_prsnl_reltn[lcnt ].action_type = "ADD"
      SET request->encntr_prsnl_reltn[lcnt ].prsnl_person_id = lookup->attend_physician_id
      SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_r_cd = attenddoc_cd
     ENDIF
    ENDIF
   ELSE
    IF ((lookup->admit_reltn_id > 0.0 ) )
     SET lcnt = (lcnt + 1 )
     SET stat = alterlist (request->encntr_prsnl_reltn ,lcnt )
     SET request->encntr_prsnl_reltn[lcnt ].action_type = "UPT"
     SET request->encntr_prsnl_reltn[lcnt ].prsnl_person_id = evaluate (lookup->admit_physician_id ,
      0.0 ,lookup->order_physician_id ,lookup->admit_physician_id )
     SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_reltn_id = lookup->admit_reltn_id
     SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_r_cd = admitdoc_cd
    ELSE
     SET lcnt = (lcnt + 1 )
     SET stat = alterlist (request->encntr_prsnl_reltn ,lcnt )
     SET request->encntr_prsnl_reltn[lcnt ].action_type = "ADD"
     SET request->encntr_prsnl_reltn[lcnt ].prsnl_person_id = evaluate (lookup->admit_physician_id ,
      0.0 ,lookup->order_physician_id ,lookup->admit_physician_id )
     SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_r_cd = admitdoc_cd
    ENDIF
    ,
    SET dtempphysicianid = request->encntr_prsnl_reltn[lcnt ].prsnl_person_id
    IF ((lookup->attend_reltn_id > 0.0 ) )
     SET lcnt = (lcnt + 1 )
     SET stat = alterlist (request->encntr_prsnl_reltn ,lcnt )
     SET request->encntr_prsnl_reltn[lcnt ].action_type = "UPT"
     SET request->encntr_prsnl_reltn[lcnt ].prsnl_person_id = evaluate (lookup->attend_physician_id ,
      0.0 ,dtempphysicianid ,lookup->attend_physician_id )
     SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_reltn_id = lookup->attend_reltn_id
     SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_r_cd = attenddoc_cd
    ELSE
     SET lcnt = (lcnt + 1 )
     SET stat = alterlist (request->encntr_prsnl_reltn ,lcnt )
     SET request->encntr_prsnl_reltn[lcnt ].action_type = "ADD"
     SET request->encntr_prsnl_reltn[lcnt ].prsnl_person_id = evaluate (lookup->attend_physician_id ,
      0.0 ,dtempphysicianid ,lookup->attend_physician_id )
     SET request->encntr_prsnl_reltn[lcnt ].encntr_prsnl_r_cd = attenddoc_cd
    ENDIF
  ENDCASE
  SET request->encntr_prsnl_reltn_qual = size (request->encntr_prsnl_reltn ,5 )
 END ;Subroutine
 call echo(curprog)
END GO

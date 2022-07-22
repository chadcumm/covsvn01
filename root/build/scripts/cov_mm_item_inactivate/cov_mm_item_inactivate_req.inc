free set 900112_request
record 900112_request (
  1 total_ids_to_add = i4
  1 total_ids_to_chg = i4
  1 total_ids_to_del = i4
  1 total_ids_to_und = i4
  1 total_ids_to_rmv = i4
  1 add_id_qual [*]
    2 object_id = f8
    2 object_id_pe = c32
    2 object_type_cd = f8
    2 object_active_ind = i2
    2 id_type_cd = f8
    2 id_type_mean = c12
    2 value = vc
    2 primary_ind = i2
    2 primary_nbr_ind = i2
    2 active_ind = i2
    2 active_status_cd = f8
    2 sequence = i4
    2 vendor_manf_cd = f8
    2 package_type_id = f8
    2 salable_by_vendor_ind = i2
    2 salable_by_mfr_ind = i2
    2 tag1 = f8
    2 replacement_upn_id = f8
    2 replaced_upn_id = f8
    2 contributor_cd = f8
    2 item_level_flag = i2
    2 pha_type_flag = i2
  1 chg_id_qual [*]
    2 identifier_id = f8
    2 object_id = f8
    2 value = vc
    2 primary_ind = i2
    2 primary_nbr_ind = i2
    2 sequence = i4
    2 updt_cnt = i4
    2 package_type_id = f8
    2 salable_by_vendor_ind = i2
    2 salable_by_mfr_ind = i2
    2 replacement_upn_id = f8
    2 replaced_upn_id = f8
    2 contributor_cd = f8
  1 del_id_qual [*]
    2 identifier_id = f8
    2 object_id = f8
    2 active_status_cd = f8
    2 updt_cnt = i4
  1 und_id_qual [*]
    2 identifier_id = f8
    2 object_id = f8
    2 active_status_cd = f8
    2 updt_cnt = i4
  1 rmv_id_qual [*]
    2 identifier_id = f8
    2 object_id = f8
    2 active_status_cd = f8
    2 updt_cnt = i4
)
 
free set 900112_reply
record 900112_reply (
  1 qual [*]
    2 object_id = f8
    2 id_qual [*]
      3 identifier_id = f8
      3 updt_cnt = i4
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
free set 900060_request
record 900060_request (
  1 search_type_flag = i4
  1 vendor_cd = f8
  1 obj_type_qual [*]
    2 obj_type_cd = f8
    2 obj_type_mean = vc
  1 identifier_type_cd = f8
  1 identifier_type_mean = vc
  1 start_value = vc
  1 maxrec = i4
  1 search_location_ind = i2
  1 search_locator_ind = i2
  1 search_class_ind = i2
  1 search_sub_class_ind = i2
  1 location_cd = f8
  1 location_view_cd = f8
  1 search_sublocation_ind = i2
  1 relationship_type_mean = vc
  1 relationship_type_cd = f8
  1 class_node_id = f8
  1 parent_loc_cd = f8
  1 item_level_flag = i2
  1 item_level_qual_cnt = i4
  1 pha_type_qual_cnt = i4
  1 org_id = f8
  1 identifier_qual [*]
    2 identifier_type_cd = f8
    2 identifier_type_mean = vc
  1 active_status_qual [*]
    2 active_status_cd = f8
    2 active_status_mean = vc
  1 pha_type_qual [*]
    2 pha_type_flag = i2
  1 item_level_qual [*]
    2 item_level_flag = i2
  1 filter_qual [*]
    2 identifier_type_cd = f8
    2 identifier_type_mean = vc
  1 quick_add_ind = i2
  1 approved_ind = i2
  1 sort_ident_type_cd = f8
  1 sort_ident_type_mean = vc
  1 style_flag = i2
  1 retrieve_implant_only_ind = i2
  1 master_list_flag = i2
)
 
free set 900060_reply
record 900060_reply (
  1 qual [*]
    2 item_id = f8
    2 search_on_disp_spl = vc
    2 search_on_disp = vc
    2 search_on_disp_key = vc
    2 item_number = vc
    2 short_description = vc
    2 description = vc
    2 ndc = vc
    2 clin_description = vc
    2 vend_item_number = vc
    2 mfr_item_number = vc
    2 item_number_id = f8
    2 short_description_id = f8
    2 description_id = f8
    2 ndc_id = f8
    2 clin_description_id = f8
    2 vend_item_number_id = f8
    2 vend_item_number_type_cd = f8
    2 mfr_item_number_id = f8
    2 mfr_item_number_type_cd = f8
    2 item_type_cd = f8
    2 item_type_disp = c40
    2 item_type_desc = c60
    2 item_type_mean = c12
    2 active_ind = i2
    2 active_status_cd = f8
    2 active_status_disp = c40
    2 active_status_desc = c60
    2 active_status_mean = c12
    2 vendor_cd = f8
    2 vendor_disp = c40
    2 vendor_desc = c60
    2 vendor_mean = c12
    2 item_level_flag = i2
    2 pha_type_flag = i2
    2 price_type_cd = f8
    2 price_type_disp = c40
    2 price_type_desc = c60
    2 price_type_mean = c12
    2 vend_mfr_item_ind = i2
    2 upn_identifier_id = f8
    2 pkg_item_id = f8
    2 pkg_item_type_cd = f8
    2 pkg_type_id = f8
    2 pkg_qty = i4
    2 pkg_desc = vc
    2 pkg_uom_cd = f8
    2 pkg_uom_disp = c40
    2 pkg_uom_desc = c60
    2 pkg_uom_mean = c12
    2 pkg_base_ind = i2
  1 wherestring = c2000
  1 svendclasswherestr = c500
  1 ssubexecuted = c100
  1 loc_where = c4000
  1 org_id = f8
  1 start_value = vc
  1 total_records = i4
  1 autm_dspns_machn_cd = f8
  1 autm_dspns_machn_disp = c40
  1 autm_dspns_machn_desc = c60
  1 autm_dspns_machn_mean = c12
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
free set 900128_request
record 900128_request (
  1 qual [*]
    2 item_id = f8
    2 get_all_ids_ind = i2
    2 check_loc_template_exists_flag = i2
    2 id_qual [*]
      3 id_type_mean = c12
)
 
free set 900128_reply
record 900128_reply (
  1 ident_sync_pref = i4
  1 inv_factor_nbr = f8
  1 qual [*]
    2 item_id = f8
    2 item_type_cd = f8
    2 item_type_disp = c40
    2 item_type_desc = c60
    2 item_type_mean = c12
    2 approved_ind = i2
    2 quickadd_ind = i2
    2 substitution_ind = i2
    2 latex_ind = i2
    2 reusable_ind = i2
    2 base_issue_factor = f8
    2 component_ind = i2
    2 component_usage_ind = i2
    2 shelf_life = f8
    2 shelf_life_uom_cd = f8
    2 pre_exp_date_period_nbr = f8
    2 pre_exp_date_uom_cd = f8
    2 active_ind = i2
    2 logical_domain_id = f8
    2 lot_tracking_ind = i2
    2 multi_lot_transfer_ind = i2
    2 has_lot_qoh_ind = i2
    2 has_loc_associate_ind = i2
    2 chargeable_ind = i2
    2 active_status_cd = f8
    2 active_status_disp = c40
    2 active_status_desc = c60
    2 active_status_mean = c12
    2 active_status_dt_tm = dq8
    2 active_status_prsnl_id = f8
    2 create_dt_tm = dq8
    2 create_id = f8
    2 create_task = i4
    2 create_applctx = i4
    2 updt_dt_tm = dq8
    2 updt_id = f8
    2 updt_task = i4
    2 updt_applctx = i4
    2 updt_cnt = i4
    2 component_trans_ind = i2
    2 component_fill_return_ind = i2
    2 suppress_auto_fill_ind = i2
    2 implant_type_cd = f8
    2 min_temp_amt = f8
    2 max_temp_amt = f8
    2 temp_uom_cd = f8
    2 has_item_qoh_ind = i2
    2 udi_lot_nbr_ind = i2
    2 udi_serial_nbr_ind = i2
    2 udi_mfr_date_ind = i2
    2 udi_exp_date_ind = i2
    2 has_loc_template_associate_ind = i2
    2 sub_account_cd = f8
    2 cost_center_cd = f8
    2 storage_requirement_cd = f8
    2 sterilization_required_ind = i2
    2 critical_ind = i2
    2 schedulable_ind = i2
    2 countable_ind = i2
    2 fda_reportable_ind = i2
    2 vendor_cd = f8
    2 vendor_disp = c40
    2 vendor_desc = c60
    2 lead_time = f8
    2 lead_time_uom_cd = f8
    2 price_review_ind = i2
    2 manufacturer_cd = f8
    2 manufacturer_disp = c40
    2 manufacturer_desc = c60
    2 awp = f8
    2 awp_factor = f8
    2 cost1 = f8
    2 cost2 = f8
    2 safety_chk_ind = i2
    2 usage_uom_cd = f8
    2 usage_uom_disp = c60
    2 alternate_dispense_category_cd = f8
    2 default_par_doses = i4
    2 dispense_category_cd = f8
    2 divisible_ind = i2
    2 formulary_status_cd = f8
    2 form_cd = f8
    2 given_strength = c25
    2 legal_status_cd = f8
    2 max_par_supply = i4
    2 mdx_gfc_nomen_id = f8
    2 strength = f8
    2 strength_unit_cd = f8
    2 used_as_base_ind = i2
    2 volume = f8
    2 volume_unit_cd = f8
    2 order_sentence_id = f8
    2 med_type_flag = i2
    2 med_filter_ind = i2
    2 continuous_filter_ind = i2
    2 intermittent_filter_ind = i2
    2 oe_format_flag = i2
    2 comment1_id = f8
    2 comment1_type = i2
    2 comment1_text = vc
    2 comment2_id = f8
    2 comment2_type = i2
    2 comment2_text = vc
    2 order_alert1_cd = f8
    2 order_alert2_cd = f8
    2 compound_text_id = f8
    2 compound_text = vc
    2 price_sched_id = f8
    2 primary_manf_item_id = f8
    2 always_dispense_from_flag = i2
    2 meq_factor = f8
    2 mmol_factor = f8
    2 side_effect_code = c10
    2 cki = vc
    2 item_level_flag = i2
    2 pha_type_flag = i2
    2 id_qual [*]
      3 identifier_id = f8
      3 id_type_cd = f8
      3 id_type_disp = c40
      3 id_type_desc = c60
      3 id_type_mean = c12
      3 id_updt_cnt = i4
      3 object_id_updt_cnt = i4
      3 value = vc
      3 primary_ind = i2
      3 primary_nbr_ind = i2
      3 active_ind = i2
      3 active_status_cd = f8
      3 format = vc
      3 updt_cnt = i4
      3 updt_dt_tm = dq8
      3 updt_id = f8
      3 updt_task = i4
      3 updt_applctx = i4
      3 contributor_cd = f8
      3 package_type_id = f8
      3 salable_by_vendor_ind = i2
      3 salable_by_mfr_ind = i2
      3 replaced_upn_id = f8
      3 replacement_upn_id = f8
    2 pack_qual [*]
      3 package_type_id = f8
      3 uom_cd = f8
      3 uom_disp = c40
      3 uom_desc = c60
      3 uom_mean = c12
      3 description = vc
      3 qty = f8
      3 active_ind = i2
      3 active_status_cd = f8
      3 base_package_type_ind = i2
      3 updt_cnt = i4
      3 updt_dt_tm = dq8
      3 updt_id = f8
      3 updt_task = i4
      3 updt_applctx = i4
      3 has_qoh_ind = i2
    2 component_qual [*]
      3 component_id = f8
      3 sequence = i4
      3 package_type_id = f8
      3 package_desc = vc
      3 package_uom_cd = f8
      3 package_uom_disp = c40
      3 package_uom_desc = c60
      3 package_uom_mean = c12
      3 qty = i4
      3 updt_cnt = i4
      3 updt_dt_tm = dq8
      3 updt_id = f8
      3 updt_task = i4
      3 updt_applctx = i4
    2 org_qual [*]
      3 item_org_reltn_id = f8
      3 org_id = f8
      3 org_name = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
 
free set 900005_request
record 900005_request (
  1 qual [*]
    2 item_id = f8
  1 root_loc_cd = f8
  1 get_ic_ind = i2
  1 get_st_ind = i2
  1 get_ac_ind = i2
  1 get_qh_ind = i2
  1 get_qr_ind = i2
  1 get_parents_ind = i2
)
 
free set 900005_reply
record 900005_reply (
  1 qual [*]
    2 item_id = f8
    2 loc_qual [*]
      3 location_cd = f8
      3 location_disp = c40
      3 location_desc = c60
      3 location_mean = c12
      3 relationship_type_cd = f8
      3 relationship_type_disp = c40
      3 relationship_type_desc = c60
      3 relationship_type_mean = c12
      3 parent_qual [*]
        4 location_cd = f8
        4 location_disp = c40
        4 location_desc = c60
        4 location_mean = c12
      3 full_path = vc
      3 short_full_path = vc
      3 locator_path = vc
      3 short_locator_path = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
free set 900067_request
record 900067_request (
  1 qual [*]
    2 item_id = f8
    2 ic_dirty = i2
    2 ic_location_cd = f8
    2 stock_type_ind = i2
    2 stock_package_type_id = f8
    2 lot_tracking_level_cd = f8
    2 charge_type_cd = f8
    2 count_cycle_cd = f8
    2 instance_ind = i2
    2 abc_class_cd = f8
    2 cost_center_cd = f8
    2 sub_account_cd = f8
    2 ic_updt_cnt = i4
    2 list_role_id = f8
    2 sch_qty = i4
    2 countback_flag = i2
    2 ac_dirty = i2
    2 ac_location_cd = f8
    2 fill_location_cd = f8
    2 primary_vendor_cd = f8
    2 economic_order_qty = f8
    2 average_lead_time = i4
    2 average_lead_time_uom_cd = f8
    2 product_origin_cd = f8
    2 syscalc_eoq_ind = i2
    2 consignment_ind = i2
    2 primary_vendor_item_id = f8
    2 reorder_package_type_id = f8
    2 ac_updt_cnt = i4
    2 qr_dirty = i2
    2 qr_location_cd = f8
    2 reorder_point = f8
    2 reorder_type_cd = f8
    2 minimum_level = f8
    2 maximum_level = f8
    2 average_daily_usage = f8
    2 average_weeks_order_qty = f8
    2 acc_stockout_freq_cd = f8
    2 last_syscalc_dt_tm = dq8
    2 max_days_adu = i4
    2 min_days_adu = i4
    2 reorder_method_cd = f8
    2 safety_stock_qty = f8
    2 seasonal_item_ind = i2
    2 syscalc_freq_nbr_days = i4
    2 syscalc_par_level_ind = i2
    2 syscalc_abc_class_ind = i2
    2 syscalc_reorder_point_ind = i2
    2 syscalc_safety_stock_ind = i2
    2 qr_updt_cnt = i4
    2 locator_type_cd = f8
    2 locator_qty = f8
    2 fixed_order_qty = f8
    2 lock_ind = i2
    2 qh_dirty = i2
    2 qh_location_cd = f8
    2 qh_locator_cd = f8
    2 qoh_type_cd = f8
    2 package_type_id = f8
    2 qty = f8
    2 active_ind = i2
    2 active_status_cd = f8
    2 active_status_dt_tm = dq8
    2 qh_updt_cnt = i4
    2 upd_obj_ind = i2
    2 cascade_del_ind = i2
    2 st_dirty = i2
    2 st_location_cd = f8
    2 st_package_type_id = f8
    2 override_clsfctn_cd = f8
    2 lot_number_id = f8
    2 lot_number_txt = vc
    2 manuf_cd = f8
    2 lot_exp_dt_tm = dq8
    2 lot_manuf_dt_tm = dq8
    2 lot_action_flag = i2
    2 lot_upd_cnt = i4
    2 lot_qty = f8
    2 demand_refill_lvl_flag = i2
    2 demand_buffer_pct = i2
    2 demand_buffer_ind = i2
    2 lot_loc_upd_cnt = i4
    2 lot_loc_action_flag = i2
    2 return_to_stock_flag = i2
  1 add_locator_rollup [*]
    2 location_cd = f8
    2 locator_cd = f8
    2 item_id = f8
    2 rel_type_mean = vc
    2 package_type_id = f8
  1 del_locator_rollup [*]
    2 location_cd = f8
    2 locator_cd = f8
    2 item_id = f8
    2 rel_type_mean = vc
    2 package_type_id = f8
    2 del_child_locators_ind = i2
  1 nbr_of_add_locator = i2
  1 nbr_of_del_locator = i2
)
 
 
free set 900067_reply
record 900067_reply (
  1 locator_rollup [*]
    2 exists_ind = i2
  1 qual [*]
    2 lot_number_id = f8
    2 updt_cnt = i4
    2 lot_number_txt = vc
    2 location_cd = f8
    2 location_disp = c40
    2 package_type_id = f8
    2 lot_loc_upd_cnt = i4
  1 exception_data [*]
    2 lot_number_id = f8
    2 location_cd = f8
    2 location_disp = c40
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
free set 900146_request
record 900146_request (
  1 item_type_cd = f8
  1 qual [*]
    2 item_id = f8
    2 active_Status_cd = f8
    2 updt_cnt = i4
)
 
free set 900146_reply
record 900146_reply (
  1 status_data
    2 status = c1
    2 subeventstatus [1]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
 
 
 

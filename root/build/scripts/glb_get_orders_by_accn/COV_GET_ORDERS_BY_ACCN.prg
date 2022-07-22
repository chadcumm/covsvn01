DROP PROGRAM cov_get_orders_by_accn :dba GO
CREATE PROGRAM cov_get_orders_by_accn :dba
 RECORD temp_rsrc_security (
   1 l_cnt = i4
   1 list [* ]
     2 service_resource_cd = f8
     2 viewable_srvc_rsrc_ind = i2
 )
 DECLARE nres_sec_failed = i2 WITH protect ,constant (0 )
 DECLARE nres_sec_passed = i2 WITH protect ,constant (1 )
 DECLARE nres_sec_msg_type = i2 WITH protect ,constant (0 )
 DECLARE ncase_sec_msg_type = i2 WITH protect ,constant (1 )
 DECLARE ncorr_group_sec_msg_type = i2 WITH protect ,constant (2 )
 DECLARE sres_sec_error_msg = c23 WITH protect ,constant ("RESOURCE SECURITY ERROR" )
 DECLARE sres_sec_failed_msg = c24 WITH protect ,constant ("RESOURCE SECURITY FAILED" )
 DECLARE scase_sec_failed_msg = c20 WITH protect ,constant ("CASE SECURITY FAILED" )
 DECLARE scorr_group_sec_failed_msg = c24 WITH protect ,constant ("CORR GRP SECURITY FAILED" )
 DECLARE m_nressecind = i2 WITH protect ,noconstant (0 )
 DECLARE m_sressecstatus = c1 WITH protect ,noconstant ("S" )
 DECLARE m_nressecuarstatus = i2 WITH protect ,noconstant (0 )
 DECLARE m_nressecerrorind = i2 WITH protect ,noconstant (0 )
 DECLARE m_lressecfailedcnt = i4 WITH protect ,noconstant (0 )
 DECLARE m_lresseccheckedcnt = i4 WITH protect ,noconstant (0 )
 DECLARE m_nressecalterstatus = i2 WITH protect ,noconstant (0 )
 DECLARE m_lressecstatusblockcnt = i4 WITH protect ,noconstant (0 )
 DECLARE m_ntaskgrantedind = i2 WITH protect ,noconstant (0 )
 DECLARE m_sfailedmsg = c25 WITH protect
 SET temp_rsrc_security->l_cnt = 0
 EXECUTE cpmsrsrtl
 SUBROUTINE  (initresourcesecurity (resource_security_ind =i2 ) =null )
  IF ((resource_security_ind = 1 ) )
   SET m_nressecind = true
  ELSE
   SET m_nressecind = false
  ENDIF
 END ;Subroutine
 SUBROUTINE  (isresourceviewable (service_resource_cd =f8 ) =i2 )
  DECLARE srvc_rsrc_idx = i4 WITH protect ,noconstant (0 )
  DECLARE l_srvc_rsrc_pos = i4 WITH protect ,noconstant (0 )
  DECLARE temp_rsrc_alterstatus = i2 WITH protect ,noconstant (0 )
  SET m_lresseccheckedcnt +=1
  IF ((m_nressecind = false ) )
   RETURN (true )
  ENDIF
  IF ((m_nressecerrorind = true ) )
   RETURN (false )
  ENDIF
  IF ((service_resource_cd = 0 ) )
   RETURN (true )
  ENDIF
  IF ((temp_rsrc_security->l_cnt > 0 ) )
   SET l_srvc_rsrc_pos = locateval (srvc_rsrc_idx ,1 ,temp_rsrc_security->l_cnt ,service_resource_cd
    ,temp_rsrc_security->list[srvc_rsrc_idx ].service_resource_cd )
  ENDIF
  IF ((l_srvc_rsrc_pos > 0 ) )
   SET m_nressecuarstatus = temp_rsrc_security->list[l_srvc_rsrc_pos ].viewable_srvc_rsrc_ind
  ELSE
   SET m_nressecuarstatus = uar_srsprsnlhasaccess (reqinfo->updt_id ,reqinfo->position_cd ,
    service_resource_cd )
   SET temp_rsrc_security->l_cnt +=1
   SET temp_rsrc_alterstatus = alterlist (temp_rsrc_security->list ,temp_rsrc_security->l_cnt )
   SET temp_rsrc_security->list[temp_rsrc_security->l_cnt ].viewable_srvc_rsrc_ind =
   m_nressecuarstatus
   SET temp_rsrc_security->list[temp_rsrc_security->l_cnt ].service_resource_cd =
   service_resource_cd
  ENDIF
  CASE (m_nressecuarstatus )
   OF nres_sec_passed :
    RETURN (true )
   OF nres_sec_failed :
    SET m_lressecfailedcnt +=1
    RETURN (false )
   ELSE
    SET m_nressecerrorind = true
    RETURN (false )
  ENDCASE
 END ;Subroutine
 SUBROUTINE  (getresourcesecuritystatus (fail_all_ind =i2 ) =c1 )
  IF ((m_nressecerrorind = true ) )
   SET m_sressecstatus = "F"
  ELSEIF ((m_lresseccheckedcnt > 0 )
  AND (m_lresseccheckedcnt = m_lressecfailedcnt ) )
   SET m_sressecstatus = "Z"
  ELSEIF ((fail_all_ind = 1 )
  AND (m_lressecfailedcnt > 0 ) )
   SET m_sressecstatus = "Z"
  ELSE
   SET m_sressecstatus = "S"
  ENDIF
  RETURN (m_sressecstatus )
 END ;Subroutine
 SUBROUTINE  (populateressecstatusblock (message_type =i2 ) =null )
  IF ((((m_sressecstatus = "S" ) ) OR ((validate (reply->status_data.status ,"-1" ) = "-1" ) )) )
   RETURN
  ENDIF
  SET m_lressecstatusblockcnt = size (reply->status_data.subeventstatus ,5 )
  IF ((m_lressecstatusblockcnt = 1 )
  AND (trim (reply->status_data.subeventstatus[1 ].operationname ) = "" ) )
   SET m_ressecalterstatus = 0
  ELSE
   SET m_lressecstatusblockcnt +=1
   SET m_nressecalterstatus = alter (reply->status_data.subeventstatus ,m_lressecstatusblockcnt )
  ENDIF
  CASE (message_type )
   OF ncase_sec_msg_type :
    SET m_sfailedmsg = scase_sec_failed_msg
   OF ncorr_group_sec_msg_type :
    SET m_sfailedmsg = scorr_group_sec_failed_msg
   ELSE
    SET m_sfailedmsg = sres_sec_failed_msg
  ENDCASE
  CASE (m_sressecstatus )
   OF "F" :
    SET reply->status_data.subeventstatus[m_lressecstatusblockcnt ].operationname =
    sres_sec_error_msg
    SET reply->status_data.subeventstatus[m_lressecstatusblockcnt ].operationstatus = "F"
   OF "Z" :
    SET reply->status_data.subeventstatus[m_lressecstatusblockcnt ].operationname = m_sfailedmsg
    SET reply->status_data.subeventstatus[m_lressecstatusblockcnt ].operationstatus = "Z"
  ENDCASE
 END ;Subroutine
 SUBROUTINE  (istaskgranted (task_number =i4 ) =i2 )
  SET m_ntaskgrantedind = false
  SELECT INTO "nl:"
   FROM (application_group ag ),
    (task_access ta )
   PLAN (ag
    WHERE (ag.position_cd = reqinfo->position_cd )
    AND (ag.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (ag.end_effective_dt_tm >= cnvtdatetime (sysdate ) ) )
    JOIN (ta
    WHERE (ta.app_group_cd = ag.app_group_cd )
    AND (ta.task_number = task_number ) )
   DETAIL
    m_ntaskgrantedind = true
   WITH nocounter
  ;end select
  RETURN (m_ntaskgrantedind )
 END ;Subroutine
 SUBROUTINE  (getcodevaluebymeaning (code_set =i4 (value ) ,cdf_meaning =vc (value ) ) =f8 )
  DECLARE _code_set = i4 WITH noconstant (code_set ) ,protect
  DECLARE _code_value = f8 WITH noconstant (0.0 ) ,protect
  DECLARE _cdf_meaning = c12 WITH noconstant ,protect
  IF ((((code_set = 0 ) ) OR ((size (trim (cdf_meaning ,1 ) ,1 ) = 0 ) )) )
   RETURN (_code_value )
  ENDIF
  SET _cdf_meaning = fillstring (12 ," " )
  SET _cdf_meaning = cnvtupper (cdf_meaning )
  SET stat = uar_get_meaning_by_codeset (_code_set ,_cdf_meaning ,1 ,_code_value )
  IF ((_code_value = 0.0 ) )
   SELECT INTO "nl:"
    c.code_value
    FROM (code_value c )
    WHERE (c.code_set = _code_set )
    AND (c.cdf_meaning = _cdf_meaning )
    AND (c.active_ind = 1 )
    AND (c.begin_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (c.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
    HEAD REPORT
     _code_value = c.code_value
    WITH nocounter
   ;end select
  ENDIF
  RETURN (_code_value )
 END ;Subroutine
 FREE RECORD pcs_get_lt
 RECORD pcs_get_lt (
   1 parent_entity_name = c32
   1 rows [* ]
     2 qual_id = f8
     2 lt_found_ind = i2
     2 long_text = vc
     2 item_data1 = i4
     2 item_data2 = i4
     2 item_data3 = i4
     2 item_data4 = i4
     2 item_data5 = i4
 ) WITH protect
 DECLARE pcsgetlongtext () = i2
 SUBROUTINE  pcsgetlongtext (null )
  DECLARE lpcsgetltcnt = i4 WITH protect ,noconstant (0 )
  DECLARE leidx = i4 WITH protect ,noconstant (0 )
  DECLARE llocidx = i4 WITH protect ,noconstant (0 )
  DECLARE sltwhereclause = vc WITH protect ,noconstant ("" )
  DECLARE nstat = i2 WITH protect ,noconstant (0 )
  DECLARE serror = vc WITH protect
  CALL echo ("Begin PCSGetLongText execution" )
  SET lpcsgetltcnt = size (pcs_get_lt->rows ,5 )
  IF ((lpcsgetltcnt <= 0 ) )
   CALL echo ("No data found in request. pcs_get_lt->rows" )
   RETURN (1 )
  ELSE
   CALL echo (build ("Total request count =  " ,lpcsgetltcnt ) )
  ENDIF
  FOR (leidx = 1 TO lpcsgetltcnt )
   IF ((pcs_get_lt->rows[leidx ].qual_id = 0 ) )
    SET pcs_get_lt->rows[leidx ].qual_id = - (1000 )
   ENDIF
  ENDFOR
  IF ((size (trim (pcs_get_lt->parent_entity_name ) ) > 0 ) )
   SET sltwhereclause =
   "expand(lEIdx, 1, size(pcs_get_lt->rows,5), lt.parent_entity_id, pcs_get_lt->rows[lEIdx].qual_id)"
   SET sltwhereclause = concat (sltwhereclause ,
    " and lt.parent_entity_name = pcs_get_lt->parent_entity_name" )
  ELSE
   SET sltwhereclause =
   "expand(lEIdx, 1, size(pcs_get_lt->rows,5), lt.long_text_id, pcs_get_lt->rows[lEIdx].qual_id)"
  ENDIF
  CALL echo (build ("sLTWhereClause:" ,sltwhereclause ) )
  SELECT INTO "nl:"
   FROM (long_text lt )
   PLAN (lt
    WHERE parser (sltwhereclause ) )
   HEAD REPORT
    outbuf = fillstring (30000 ," " ) ,
    offset = 0 ,
    retlen = 0
   DETAIL
    IF ((lt.long_text_id > 0 ) )
     IF ((size (trim (pcs_get_lt->parent_entity_name ) ) > 0 ) ) llocidx = locateval (llocidx ,1 ,
       lpcsgetltcnt ,lt.parent_entity_id ,pcs_get_lt->rows[llocidx ].qual_id )
     ELSE llocidx = locateval (llocidx ,1 ,lpcsgetltcnt ,lt.long_text_id ,pcs_get_lt->rows[llocidx ].
       qual_id )
     ENDIF
     ,pcs_get_lt->rows[llocidx ].long_text = trim ("" ,3 ) ,pcs_get_lt->rows[llocidx ].lt_found_ind
     = 1 ,retlen = 1 ,offset = 0 ,
     WHILE ((retlen > 0 ) )
      retlen = blobget (outbuf ,offset ,lt.long_text ) ,pcs_get_lt->rows[llocidx ].long_text =
      notrim (concat (pcs_get_lt->rows[llocidx ].long_text ,outbuf ) ) ,offset +=30000
     ENDWHILE
     ,pcs_get_lt->rows[llocidx ].long_text = trim (pcs_get_lt->rows[llocidx ].long_text ,5 )
    ENDIF
   WITH nocounter ,rdbarrayfetch = 1 ,expand = 1
  ;end select
  IF ((error (serror ,0 ) > 0 ) )
   CALL echo (build ("pcs_get_longtext.inc encountered an error. errmsg = " ,serror ) )
   RETURN (0 )
  ENDIF
  CALL echo ("PCSGetLongText executed successfully" )
  RETURN (1 )
 END ;Subroutine
 DECLARE pcsgetlongtextcleanup () = null WITH protect
 SUBROUTINE  pcsgetlongtextcleanup (null )
  CALL echo ("Begin PCSGetLongTextCleanup" )
  FREE RECORD pcs_get_lt
 END ;Subroutine
 DECLARE lt_idx = i4 WITH protect ,noconstant (0 )
 DECLARE longtextflagrtf = i2 WITH protect ,constant (1 )
 DECLARE longtextflagprevrtf = i2 WITH protect ,constant (2 )
 IF ((validate (reply->status_data.status ,"U" ) = "U" ) )
  RECORD reply (
    1 accession_id = f8
    1 person_id = f8
    1 person_name = vc
    1 encntr_id = f8
    1 encntr_reg_dt_tm = dq8
    1 encntr_disch_dt_tm = dq8
    1 qual [* ]
      2 cs_order_id = f8
      2 order_id = f8
      2 updt_cnt = i4
      2 order_mnemonic = vc
      2 report_priority_cd = f8
      2 report_priority_disp = vc
      2 restrict_av_ind = i2
      2 report_priority_mean = c12
      2 review_required_ind = i2
      2 pending_review_ind = i2
      2 catalog_cd = f8
      2 catalog_type_cd = f8
      2 activity_type_cd = f8
      2 activity_type_disp = vc
      2 activity_type_mean = c12
      2 order_status_cd = f8
      2 order_status_disp = vc
      2 order_status_mean = c12
      2 last_action_sequence = i4
      2 last_update_provider_id = f8
      2 last_update_provider_name = vc
      2 order_comment_ind = i2
      2 order_comment_action_seq = i4
      2 order_note_action_seq = i4
      2 route_level = i2
      2 container_serv_res_cnt = i4
      2 container_serv_res [* ]
        3 container_id = f8
        3 in_lab_dt_tm = dq8
        3 organization_id = f8
        3 service_resource_cd = f8
        3 service_resource_disp = vc
        3 instr_service_resource_cd = f8
        3 status_flag = i2
        3 specimen_type_cd = f8
        3 drawn_dt_tm = dq8
        3 assays_cnt = i4
        3 assays [* ]
          4 task_assay_cd = f8
          4 ptr_sequence = i4
          4 delta_lvl_flag = i2
          4 rel_assay_ind = i2
          4 task_assay_mnemonic = vc
          4 display_sequence = i4
          4 restrict_display_ind = i2
          4 event_cd = f8
          4 pending_ind = i2
          4 default_result_type_cd = f8
          4 default_result_type_disp = vc
          4 default_result_type_mean = c12
          4 default_result_template_id = f8
          4 data_map_ind = i2
          4 max_digits = i4
          4 min_decimal_places = i4
          4 min_digits = i4
          4 rout_inst_data_map_ind = i2
          4 rout_inst_max_digits = i4
          4 rout_inst_min_decimal_places = i4
          4 rout_inst_min_digits = i4
          4 assay_service_resource_cd = f8
          4 assay_service_resource_disp = vc
          4 result_entry_format = i4
          4 instr_cnt = i4
          4 instr [* ]
            5 upld_assay_alias = c25
            5 process_sequence = i4
            5 default_result_type_cd = f8
            5 post_zero_result_ind = i2
            5 decimal_movement_nbr = i4
          4 next_repeat_nbr = i4
          4 results_cnt = i4
          4 results [* ]
            5 perform_result_id = f8
            5 repeat_nbr = i4
            5 result_id = f8
            5 result_status_cd = f8
            5 result_status_disp = vc
            5 result_status_mean = c12
            5 reference_range_factor_id = f8
            5 advanced_delta_id = f8
            5 normal_cd = f8
            5 normal_disp = vc
            5 normal_mean = vc
            5 critical_cd = f8
            5 critical_disp = vc
            5 critical_mean = vc
            5 review_cd = f8
            5 review_disp = vc
            5 review_mean = vc
            5 linear_cd = f8
            5 linear_disp = vc
            5 linear_mean = vc
            5 feasible_cd = f8
            5 feasible_disp = vc
            5 feasible_mean = vc
            5 dilution_factor = f8
            5 delta_cd = f8
            5 delta_disp = vc
            5 delta_mean = vc
            5 units_cd = f8
            5 units_disp = vc
            5 normal_range_flag = i2
            5 normal_low = f8
            5 normal_high = f8
            5 normal_alpha = vc
            5 critical_range_flag = i2
            5 critical_low = f8
            5 critical_high = f8
            5 result_type_cd = f8
            5 result_type_disp = vc
            5 result_type_mean = c12
            5 equation_id = f8
            5 nomenclature_id = f8
            5 result_value_numeric = f8
            5 numeric_raw_value = f8
            5 less_great_flag = i2
            5 result_value_alpha = vc
            5 result_value_dt_tm = dq8
            5 long_text_id = f8
            5 rtf_text = vc
            5 ascii_text = vc
            5 result_comment_ind = i2
            5 service_resource_cd = f8
            5 service_resource_disp = vc
            5 service_resource_desc = vc
            5 resource_error_codes = vc
            5 perform_personnel_id = f8
            5 perform_personnel_name = vc
            5 perform_dt_tm = dq8
            5 perform_tz = i4
            5 perform_result_updt_cnt = i4
            5 result_updt_cnt = i4
            5 qc_override_cd = f8
            5 qc_override_disp = c40
            5 qc_override_mean = c12
            5 use_units_ind = i2
            5 notify_cd = f8
            5 notify_disp = c40
            5 notify_mean = c12
            5 result_value_alpha_mnemonic = c25
            5 worklist_id = f8
            5 interface_flag = i2
            5 chartable_flag = i2
            5 av_codes [* ]
              6 auto_verify_cd = f8
          4 prev_task_assay_cd = f8
          4 prev_task_assay_disp = vc
          4 prev_perform_result_id = f8
          4 prev_result_id = f8
          4 prev_result_status_cd = f8
          4 prev_result_status_disp = vc
          4 prev_result_status_mean = c12
          4 prev_reference_range_factor_id = f8
          4 prev_delta_chk_flag = i2
          4 prev_advanced_delta_id = f8
          4 prev_delta_low = f8
          4 prev_delta_high = f8
          4 prev_delta_check_type_cd = f8
          4 prev_delta_minutes = i4
          4 prev_delta_value = f8
          4 prev_normal_cd = f8
          4 prev_critical_cd = f8
          4 prev_review_cd = f8
          4 prev_linear_cd = f8
          4 prev_feasible_cd = f8
          4 prev_dilution_factor = f8
          4 prev_delta_cd = f8
          4 prev_result_type_cd = f8
          4 prev_result_type_disp = vc
          4 prev_result_type_mean = c12
          4 prev_notify_cd = f8
          4 prev_notify_disp = c40
          4 prev_notify_mean = c12
          4 prev_nomenclature_id = f8
          4 prev_equation_id = f8
          4 prev_result_value_numeric = f8
          4 prev_numeric_raw_value = f8
          4 prev_less_great_flag = i2
          4 prev_result_value_alpha = vc
          4 prev_result_value_dt_tm = dq8
          4 prev_long_text_id = f8
          4 prev_rtf_text = vc
          4 prev_ascii_text = vc
          4 prev_collected_dt_tm = dq8
          4 prev_resource_error_codes = vc
          4 prev_qc_override_cd = f8
          4 sci_notation_ind = i2
          4 prev_service_resource_cd = f8
        3 accession_container_alpha = vc
      2 order_comment_text_blank_ind = i2
    1 fail_reason_flag = i2
    1 def_parent_order_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
#script
 SET cv_required_recs = 10
 DECLARE cv_cnt = i4
 SET activity_type_codeset = 106
 SET activity_type_glb_cdf = "GLB"
 SET activity_type_hla_cdf = "HLA"
 SET activity_type_hlx_cdf = "HLX"
 SET order_status_codeset = 6004
 SET order_status_canceled_cdf = "CANCELED"
 SET order_status_deleted_cdf = "DELETED"
 SET order_status_discontinued_cdf = "DISCONTINUED"
 SET order_comment_codeset = 14
 SET order_comment_cdf = "ORD COMMENT"
 SET order_note_cdf = "ORD NOTE"
 SET review_comment_cdf = "REVIEW"
 SET result_status_codeset = 1901
 SET result_status_verified_cdf = "VERIFIED"
 SET result_status_autoverified_cdf = "AUTOVERIFIED"
 SET result_status_corrected_cdf = "CORRECTED"
 SET data_map_type_flag = 0
 SET serv_res_type_codeset = 223
 SET serv_res_subsection_cdf = "SUBSECTION"
 SET default_min = 1
 SET default_max = 8
 SET default_dec = 0
 DECLARE order_status_canceled_cd = f8
 DECLARE order_status_deleted_cd = f8
 DECLARE order_status_discontinued_cd = f8
 DECLARE order_comment_cd = f8
 DECLARE order_note_cd = f8
 DECLARE review_comment_cd = f8
 DECLARE result_status_verified_cd = f8
 DECLARE result_status_autoverified_cd = f8
 DECLARE result_status_corrected_cd = f8
 DECLARE serv_res_subsection_cd = f8
 DECLARE q_cnt = i4
 DECLARE c_cnt = i4
 DECLARE a_cnt = i4
 DECLARE i_cnt = i4
 DECLARE r_cnt = i4
 DECLARE max_q_cnt = i4
 DECLARE max_c_cnt = i4
 DECLARE max_a_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE next_repeat_nbr = i4
 DECLARE dm_cnt = i4
 DECLARE qualcnt = i4
 DECLARE contcnt = i4
 DECLARE assaycnt = i4
 DECLARE taskassaycd = f8
 DECLARE qcnt = i4 WITH protect ,noconstant (0 )
 DECLARE qcntrep = i4 WITH protect ,noconstant (0 )
 DECLARE ccnt = i4 WITH protect ,noconstant (0 )
 DECLARE acnt = i4 WITH protect ,noconstant (0 )
 DECLARE lidx = i4 WITH protect ,noconstant (0 )
 DECLARE qualcntrep = i4 WITH protect ,noconstant (0 )
 DECLARE route_lvl_one_found = i2 WITH protect ,noconstant (0 )
 DECLARE route_lvl_two_found = i2 WITH protect ,noconstant (0 )
 DECLARE rel_assay_found_ind = i2 WITH protect ,noconstant (0 )
 DECLARE lookup_helix_ind = i2 WITH noconstant (0 ) ,protect
 DECLARE lookup_av_ind = i2 WITH noconstant (0 ) ,protect
 DECLARE dtoldestorig = dq8 WITH protect ,noconstant (cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
 DECLARE lerr = i4 WITH protect ,noconstant (0 )
 DECLARE valid_logical_domain_ind = i2 WITH noconstant (0 ) ,protect
 SET reply->status_data.status = "F"
 EXECUTE accrtl
 RECORD data_map_rec (
   1 list [* ]
     2 task_assay_cd = f8
     2 service_resource_cd = f8
     2 q_cnt = i4
     2 c_cnt = i4
     2 a_cnt = i4
 )
 RECORD req250220 (
   1 qual [* ]
     2 task_assay_cd = f8
     2 perform_result_id = f8
     2 qual_idx = i2
     2 serv_res_idx = i2
     2 assay_idx = i2
     2 result_idx = i2
 )
 RECORD req250145 (
   1 qual [* ]
     2 accession_id = f8
     2 order_id = f8
     2 task_assay_cd = f8
     2 service_resource_cd = f8
     2 data_map_type_flag = i2
 )
 DECLARE dservrescd = f8 WITH protect ,noconstant (0.0 )
 DECLARE is_resource_viewable = i2 WITH protect ,noconstant (0 )
 CALL initresourcesecurity (request->resource_security_ind )
 SET cv_cnt = 0
 SET order_status_canceled_cd = getcodevaluebymeaning (order_status_codeset ,
  order_status_canceled_cdf )
 IF ((order_status_canceled_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET order_status_deleted_cd = getcodevaluebymeaning (order_status_codeset ,order_status_deleted_cdf
  )
 IF ((order_status_deleted_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET order_status_discontinued_cd = getcodevaluebymeaning (order_status_codeset ,
  order_status_discontinued_cdf )
 IF ((order_status_discontinued_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET order_comment_cd = getcodevaluebymeaning (order_comment_codeset ,order_comment_cdf )
 IF ((order_comment_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET order_note_cd = getcodevaluebymeaning (order_comment_codeset ,order_note_cdf )
 IF ((order_note_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET review_comment_cd = getcodevaluebymeaning (order_comment_codeset ,review_comment_cdf )
 IF ((review_comment_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET result_status_verified_cd = getcodevaluebymeaning (result_status_codeset ,
  result_status_verified_cdf )
 IF ((result_status_verified_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET result_status_autoverified_cd = getcodevaluebymeaning (result_status_codeset ,
  result_status_autoverified_cdf )
 IF ((result_status_autoverified_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET result_status_corrected_cd = getcodevaluebymeaning (result_status_codeset ,
  result_status_corrected_cdf )
 IF ((result_status_corrected_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 SET serv_res_subsection_cd = getcodevaluebymeaning (serv_res_type_codeset ,serv_res_subsection_cdf
  )
 IF ((serv_res_subsection_cd > 0.0 ) )
  SET cv_cnt +=1
 ENDIF
 IF ((cv_cnt != cv_required_recs ) )
  SET reply->status_data.subeventstatus[1 ].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "CODE_VALUE TABLE"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
  "Unable to load all required code values for script execution"
  GO TO exit_script
 ENDIF
 IF ((((reqinfo->updt_task = 1250010 ) ) OR ((((reqinfo->updt_task = 250143 ) ) OR ((((validate (
  from_pfmt_gl_reeval_results ,0 ) = 1 ) ) OR ((validate (request->interface_flag ,0 ) > 0 ) )) ))
 )) )
  CALL echo ("Looking up Helix orders ..." )
  SET lookup_helix_ind = 1
 ENDIF
 IF ((validate (request->interface_flag ,0 ) > 0 )
 AND (validate (request->instr_service_resource_cd ,0 ) > 0 ) )
  CALL echo ("Validating Logical domain ..." )
  SET valid_logical_domain_ind = validatelogicaldomain (0 )
  IF ((valid_logical_domain_ind = 0 ) )
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "ORGANIZATION TABLE"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
   "The instr_service_resource_cd and accession don't belong to the same logical domain. "
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->instr_service_resource_cd > 0 )
 AND (validate (request->interface_flag ,0 ) > 0 ) )
  SET lerr = lockaccessionformdi (0 )
  IF ((lerr != 0 ) )
   CALL echo (build ("Error trying to lock accession table:" ,lerr ) )
  ENDIF
 ENDIF
 SET lookup_av_ind = validate (request->include_av_codes_ind ,0 )
 SET max_q_cnt = 0
 SELECT INTO "nl:"
  aor.seq ,
  o.seq ,
  cv.seq ,
  ol.seq ,
  p1.seq ,
  p.seq ,
  osrc.container_id ,
  osrc.order_id ,
  osrc.service_resource_cd ,
  ca.accession_container_nbr ,
  sr.organization_id ,
  c.seq ,
  d_oc.seq ,
  oc_exists = evaluate (nullind (oc.seq ) ,0 ,1 ,0 ) ,
  oc.action_sequence
  FROM (accession_order_r aor ),
   (orders o ),
   (encounter e ),
   (code_value cv ),
   (order_laboratory ol ),
   (person p1 ),
   (prsnl p ),
   (order_container_r ocr ),
   (order_serv_res_container osrc ),
   (container_accession ca ),
   (service_resource sr ),
   (container c ),
   (order_comment oc ),
   (long_text lt )
  PLAN (aor
   WHERE (aor.accession = request->accession )
   AND (aor.primary_flag = 0 ) )
   JOIN (o
   WHERE (o.order_id = aor.order_id )
   AND NOT ((o.order_status_cd IN (order_status_canceled_cd ,
   order_status_discontinued_cd ,
   order_status_deleted_cd ) ) ) )
   JOIN (e
   WHERE (e.encntr_id = o.encntr_id ) )
   JOIN (cv
   WHERE (cv.code_value = o.activity_type_cd )
   AND (((cv.cdf_meaning IN (activity_type_glb_cdf ,
   activity_type_hla_cdf ) ) ) OR ((cv.cdf_meaning = activity_type_hlx_cdf )
   AND (lookup_helix_ind = 1 ) )) )
   JOIN (ol
   WHERE (ol.order_id = o.order_id ) )
   JOIN (p1
   WHERE (p1.person_id = o.person_id ) )
   JOIN (p
   WHERE (p.person_id = o.last_update_provider_id ) )
   JOIN (ocr
   WHERE (ocr.order_id = o.order_id )
   AND (ocr.collection_status_flag != 7 ) )
   JOIN (osrc
   WHERE (osrc.order_id = ocr.order_id )
   AND (osrc.container_id = ocr.container_id ) )
   JOIN (ca
   WHERE (ca.accession_id = aor.accession_id )
   AND (ca.container_id = osrc.container_id ) )
   JOIN (sr
   WHERE (sr.service_resource_cd = osrc.service_resource_cd ) )
   JOIN (c
   WHERE (c.container_id = osrc.container_id ) )
   JOIN (oc
   WHERE (oc.order_id = Outerjoin(o.order_id )) )
   JOIN (lt
   WHERE (lt.long_text_id = Outerjoin(oc.long_text_id )) )
  ORDER BY o.catalog_cd ,
   osrc.order_id ,
   osrc.service_resource_cd ,
   ca.accession_container_nbr ,
   oc.action_sequence
  HEAD REPORT
   q_cnt = 0 ,
   c_cnt = 0 ,
   max_c_cnt = 0
  HEAD osrc.order_id
   q_cnt +=1 ,
   IF ((size (reply->qual ,5 ) < q_cnt ) ) stat = alterlist (reply->qual ,(q_cnt + 10 ) )
   ENDIF
   ,reply->accession_id = aor.accession_id ,reply->person_id = o.person_id ,reply->person_name = p1
   .name_full_formatted ,reply->encntr_id = o.encntr_id ,reply->encntr_reg_dt_tm = e.reg_dt_tm ,reply
   ->encntr_disch_dt_tm = e.disch_dt_tm ,reply->qual[q_cnt ].updt_cnt = o.updt_cnt ,reply->qual[
   q_cnt ].cs_order_id = o.cs_order_id ,reply->qual[q_cnt ].order_id = osrc.order_id ,reply->qual[
   q_cnt ].order_mnemonic = o.order_mnemonic ,reply->qual[q_cnt ].report_priority_cd = ol
   .report_priority_cd ,reply->qual[q_cnt ].restrict_av_ind = aor.restrict_av_ind ,reply->qual[q_cnt
   ].catalog_cd = o.catalog_cd ,reply->qual[q_cnt ].catalog_type_cd = o.catalog_type_cd ,reply->qual[
   q_cnt ].activity_type_cd = o.activity_type_cd ,reply->qual[q_cnt ].order_status_cd = o
   .order_status_cd ,reply->qual[q_cnt ].last_action_sequence = o.last_action_sequence ,reply->qual[
   q_cnt ].last_update_provider_id = o.last_update_provider_id ,reply->qual[q_cnt ].route_level = ol
   .resource_route_level_flag ,
   IF ((ol.resource_route_level_flag = 1 ) ) route_lvl_one_found = 1
   ELSEIF ((ol.resource_route_level_flag = 2 ) ) route_lvl_two_found = 1
   ENDIF
   ,reply->qual[q_cnt ].review_required_ind = ol.review_required_ind ,reply->qual[q_cnt ].
   pending_review_ind = ol.pending_review_ind ,
   IF ((p.person_id > 0.0 ) ) reply->qual[q_cnt ].last_update_provider_name = p.name_full_formatted
   ENDIF
   ,reply->qual[q_cnt ].order_comment_ind = 0 ,reply->qual[q_cnt ].order_comment_action_seq = 0 ,
   reply->qual[q_cnt ].order_note_action_seq = 0 ,reply->qual[q_cnt ].order_comment_text_blank_ind =
   0 ,
   IF ((((reply->def_parent_order_id = 0 ) ) OR ((((o.orig_order_dt_tm < dtoldestorig ) ) OR ((o
   .orig_order_dt_tm = dtoldestorig )
   AND (o.order_id < reply->def_parent_order_id ) )) )) ) reply->def_parent_order_id = o.order_id ,
    dtoldestorig = o.orig_order_dt_tm
   ENDIF
   ,c_cnt = 0
  HEAD osrc.service_resource_cd
   dservrescd = osrc.service_resource_cd ,is_resource_viewable = isresourceviewable (dservrescd ) ,
   IF ((is_resource_viewable = true ) ) c_cnt +=1 ,
    IF ((mod (c_cnt ,10 ) = 1 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res ,(c_cnt +
      10 ) )
    ENDIF
    ,
    IF ((c_cnt > max_c_cnt ) ) max_c_cnt = c_cnt
    ENDIF
    ,reply->qual[q_cnt ].container_serv_res_cnt = c_cnt ,reply->qual[q_cnt ].container_serv_res[
    c_cnt ].status_flag = - (1 )
   ENDIF
  HEAD ca.accession_container_nbr
   IF ((is_resource_viewable = true ) )
    IF ((((reply->qual[q_cnt ].container_serv_res[c_cnt ].status_flag = - (1 ) ) ) OR ((((reply->
    qual[q_cnt ].container_serv_res[c_cnt ].status_flag = 0 )
    AND (osrc.status_flag IN (1 ,
    2 ) ) ) OR ((((reply->qual[q_cnt ].container_serv_res[c_cnt ].status_flag = 3 )
    AND (((osrc.status_flag = 2 )
    AND (osrc.current_location_cd = osrc.location_cd ) ) OR ((osrc.status_flag = 1 ) )) ) OR ((reply
    ->qual[q_cnt ].container_serv_res[c_cnt ].status_flag = 2 )
    AND (osrc.status_flag = 1 ) )) )) )) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].
     container_id = osrc.container_id ,reply->qual[q_cnt ].container_serv_res[c_cnt ].in_lab_dt_tm =
     cnvtdatetime (osrc.in_lab_dt_tm ) ,reply->qual[q_cnt ].container_serv_res[c_cnt ].
     organization_id = sr.organization_id ,reply->qual[q_cnt ].container_serv_res[c_cnt ].
     service_resource_cd = osrc.service_resource_cd ,
     IF ((osrc.status_flag = 2 )
     AND (osrc.current_location_cd != osrc.location_cd ) ) reply->qual[q_cnt ].container_serv_res[
      c_cnt ].status_flag = 3
     ELSE reply->qual[q_cnt ].container_serv_res[c_cnt ].status_flag = osrc.status_flag
     ENDIF
     ,reply->qual[q_cnt ].container_serv_res[c_cnt ].specimen_type_cd = c.specimen_type_cd ,reply->
     qual[q_cnt ].container_serv_res[c_cnt ].drawn_dt_tm = c.drawn_dt_tm ,reply->qual[q_cnt ].
     container_serv_res[c_cnt ].assays_cnt = 0 ,reply->qual[q_cnt ].container_serv_res[c_cnt ].
     accession_container_alpha = char (uar_accgetcontaineralpha (ca.accession_container_nbr ) )
    ENDIF
   ENDIF
  DETAIL
   IF ((is_resource_viewable = true ) )
    IF ((oc_exists = 1 ) )
     IF ((oc.action_sequence <= o.last_action_sequence )
     AND (oc.comment_type_cd IN (order_comment_cd ,
     order_note_cd ,
     review_comment_cd ) ) ) reply->qual[q_cnt ].order_comment_ind = 1 ,
      IF ((oc.comment_type_cd = order_comment_cd ) ) reply->qual[q_cnt ].order_comment_action_seq =
       oc.action_sequence
      ENDIF
      ,
      IF ((oc.comment_type_cd = order_note_cd ) ) reply->qual[q_cnt ].order_note_action_seq = oc
       .action_sequence
      ENDIF
      ,
      IF ((oc.comment_type_cd = order_comment_cd )
      AND (lt.long_text_id > 0 ) )
       IF ((size (trim (lt.long_text ,3 ) ,1 ) = 0 ) ) reply->qual[q_cnt ].
        order_comment_text_blank_ind = 1
       ELSE reply->qual[q_cnt ].order_comment_text_blank_ind = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  ca.accession_container_nbr
   row + 0
  FOOT  osrc.service_resource_cd
   IF ((is_resource_viewable = true ) )
    IF ((reply->qual[q_cnt ].container_serv_res[c_cnt ].status_flag = 3 ) ) reply->qual[q_cnt ].
     container_serv_res[c_cnt ].status_flag = 2
    ENDIF
   ENDIF
  FOOT  osrc.order_id
   stat = alterlist (reply->qual[q_cnt ].container_serv_res ,c_cnt ) ,
   IF ((c_cnt = 0 ) ) q_cnt -=1
   ENDIF
  FOOT REPORT
   stat = alterlist (reply->qual ,q_cnt )
  WITH nocounter
 ;end select
 SET max_q_cnt = q_cnt
 IF ((q_cnt = 0 ) )
  SELECT INTO "nl:"
   aor.accession ,
   o.order_status_cd
   FROM (accession_order_r aor ),
    (orders o )
   PLAN (aor
    WHERE (aor.accession = request->accession ) )
    JOIN (o
    WHERE (o.order_id = aor.order_id ) )
   HEAD REPORT
    all_canceled_ind = 1 ,
    all_rescheduled_ind = 1 ,
    all_rescheduled_or_canceled_ind = 1
   DETAIL
    IF ((aor.primary_flag != 1 ) ) all_rescheduled_ind = 0
    ENDIF
    ,
    IF (NOT ((o.order_status_cd IN (order_status_canceled_cd ,
    order_status_discontinued_cd ,
    order_status_deleted_cd ) ) ) ) all_canceled_ind = 0
    ENDIF
    ,
    IF ((aor.primary_flag != 1 )
    AND NOT ((o.order_status_cd IN (order_status_canceled_cd ,
    order_status_discontinued_cd ,
    order_status_deleted_cd ) ) ) ) all_rescheduled_or_canceled_ind = 0
    ENDIF
   FOOT REPORT
    IF ((all_rescheduled_ind = 1 ) ) reply->fail_reason_flag = 2
    ELSEIF ((((all_canceled_ind = 1 ) ) OR ((all_rescheduled_or_canceled_ind = 1 ) )) ) reply->
     fail_reason_flag = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((((max_q_cnt = 0 ) ) OR ((max_c_cnt = 0 ) )) )
  GO TO resize_reply
 ENDIF
 IF ((route_lvl_one_found = 1 ) )
 call echo(build2("max_q_cnt=",max_q_cnt))
 call echo(build2("max_c_cnt=",max_c_cnt))
; call echorecord(reply)
  SELECT INTO "nl:"
   d1.seq
   FROM (dummyt d1 WITH seq = value (max_q_cnt ) ),
    (dummyt d2 WITH seq = value (max_c_cnt ) ),
    (profile_task_r ptr1 ),
    (discrete_task_assay dta1 ),
    (assay_processing_r apr1 )
   PLAN (d1 )
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d1.seq ].container_serv_res_cnt ) )
    JOIN (ptr1
    WHERE (reply->qual[d1.seq ].route_level = 1 )
    AND (ptr1.catalog_cd = reply->qual[d1.seq ].catalog_cd )
    AND (ptr1.active_ind = 1 ) )
    JOIN (dta1
    WHERE (dta1.task_assay_cd = ptr1.task_assay_cd )
    AND (dta1.active_ind = 1 ) )
    JOIN (apr1
    WHERE (apr1.service_resource_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].
    service_resource_cd )
    AND (apr1.task_assay_cd = ptr1.task_assay_cd ) )
   ORDER BY d1.seq ,
    d2.seq ,
    apr1.display_sequence ,
    ptr1.task_assay_cd
   HEAD REPORT
    q_cnt = 0 ,
    c_cnt = 0 ,
    a_cnt = 0
   HEAD d1.seq
    q_cnt = d1.seq
   HEAD d2.seq
    c_cnt = d2.seq ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays_cnt = 0 ,a_cnt = 0
   DETAIL
    a_cnt +=1 ,
    IF ((mod (a_cnt ,10 ) = 1 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].
      assays ,(a_cnt + 10 ) )
    ENDIF
    ,
    IF ((a_cnt > max_a_cnt ) ) max_a_cnt = a_cnt
    ENDIF
    ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays_cnt = a_cnt ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].task_assay_cd = ptr1.task_assay_cd
    ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].max_digits = default_max ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].min_digits = default_min ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].min_decimal_places = default_dec ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].ptr_sequence = ptr1.sequence ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].delta_lvl_flag = dta1
    .delta_lvl_flag ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].rel_assay_ind = dta1.rel_assay_ind
    ,
    IF ((dta1.rel_assay_ind = 1 ) ) rel_assay_found_ind = 1
    ENDIF
    ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].sci_notation_ind = dta1
    .sci_notation_ind ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].task_assay_mnemonic = dta1
    .mnemonic ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].display_sequence = apr1
    .display_sequence ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].event_cd = dta1.event_cd ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].pending_ind = ptr1.pending_ind ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].restrict_display_ind = ptr1
    .restrict_display_ind ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].default_result_type_cd = apr1
    .default_result_type_cd ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].default_result_template_id = apr1
    .default_result_template_id
   FOOT  d2.seq
    IF ((a_cnt > 0 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].assays ,
      a_cnt )
    ENDIF
   FOOT  d1.seq
    row + 0
   WITH nocounter
  ;end select
   call echorecord(reply)
 ENDIF
 IF ((route_lvl_two_found = 1 ) )
  SELECT INTO "nl:"
   d1.seq
   FROM (dummyt d1 WITH seq = value (max_q_cnt ) ),
    (dummyt d2 WITH seq = value (max_c_cnt ) ),
    (profile_task_r ptr2 ),
    (discrete_task_assay dta2 ),
    (order_procedure_exception ope ),
    (assay_processing_r apr2 )
   PLAN (d1 )
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d1.seq ].container_serv_res_cnt ) )
    JOIN (ptr2
    WHERE (reply->qual[d1.seq ].route_level = 2 )
    AND (ptr2.catalog_cd = reply->qual[d1.seq ].catalog_cd )
    AND (ptr2.active_ind = 1 ) )
    JOIN (dta2
    WHERE (dta2.task_assay_cd = ptr2.task_assay_cd )
    AND (dta2.active_ind = 1 ) )
    JOIN (ope
    WHERE (ope.order_id = reply->qual[d1.seq ].order_id )
    AND (ope.task_assay_cd = ptr2.task_assay_cd )
    AND (ope.service_resource_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].
    service_resource_cd ) )
    JOIN (apr2
    WHERE (apr2.service_resource_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].
    service_resource_cd )
    AND (apr2.task_assay_cd = ptr2.task_assay_cd ) )
   ORDER BY d1.seq ,
    d2.seq ,
    apr2.display_sequence ,
    ptr2.task_assay_cd
   HEAD REPORT
    q_cnt = 0 ,
    c_cnt = 0 ,
    a_cnt = 0
   HEAD d1.seq
    q_cnt = d1.seq
   HEAD d2.seq
    c_cnt = d2.seq ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays_cnt = 0 ,a_cnt = 0
   DETAIL
    a_cnt +=1 ,
    IF ((mod (a_cnt ,10 ) = 1 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].
      assays ,(a_cnt + 10 ) )
    ENDIF
    ,
    IF ((a_cnt > max_a_cnt ) ) max_a_cnt = a_cnt
    ENDIF
    ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays_cnt = a_cnt ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].task_assay_cd = ptr2.task_assay_cd
    ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].max_digits = default_max ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].min_digits = default_min ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].min_decimal_places = default_dec ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].ptr_sequence = ptr2.sequence ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].delta_lvl_flag = dta2
    .delta_lvl_flag ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].rel_assay_ind = dta2.rel_assay_ind
    ,
    IF ((dta2.rel_assay_ind = 1 ) ) rel_assay_found_ind = 1
    ENDIF
    ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].sci_notation_ind = dta2
    .sci_notation_ind ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].task_assay_mnemonic = dta2
    .mnemonic ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].display_sequence = apr2
    .display_sequence ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].event_cd = dta2.event_cd ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].pending_ind = ptr2.pending_ind ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].restrict_display_ind = ptr2
    .restrict_display_ind ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].default_result_type_cd = apr2
    .default_result_type_cd ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].default_result_template_id = apr2
    .default_result_template_id
   FOOT  d2.seq
    IF ((a_cnt > 0 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].assays ,
      a_cnt )
    ENDIF
   FOOT  d1.seq
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 SET dm_cnt = 0
 SET qualcnt = size (reply->qual ,5 )
 FOR (qcnt = 1 TO qualcnt )
  SET contcnt = size (reply->qual[qcnt ].container_serv_res ,5 )
  FOR (ccnt = 1 TO contcnt )
   SET assaycnt = size (reply->qual[qcnt ].container_serv_res[ccnt ].assays ,5 )
   FOR (acnt = 1 TO assaycnt )
    SELECT INTO "nl:"
     pr.perform_result_id ,
     pr.service_resource_cd
     FROM (result r ),
      (perform_result pr )
     PLAN (r
      WHERE (r.order_id = reply->qual[qcnt ].order_id )
      AND (r.task_assay_cd = reply->qual[qcnt ].container_serv_res[ccnt ].assays[acnt ].task_assay_cd
       ) )
      JOIN (pr
      WHERE (pr.result_id = r.result_id ) )
     ORDER BY pr.perform_result_id
     DETAIL
      reply->qual[qcnt ].container_serv_res[ccnt ].assays[acnt ].assay_service_resource_cd = pr
      .service_resource_cd
     WITH nocounter
    ;end select
    IF ((reply->qual[qcnt ].container_serv_res[ccnt ].assays[acnt ].assay_service_resource_cd = 0 )
    )
     SET reply->qual[qcnt ].container_serv_res[ccnt ].assays[acnt ].assay_service_resource_cd = reply
     ->qual[qcnt ].container_serv_res[ccnt ].service_resource_cd
    ENDIF
    IF ((request->instr_service_resource_cd > 0 )
    AND (validate (request->interface_flag ,0 ) > 0 ) )
     SET reply->qual[qcnt ].container_serv_res[ccnt ].assays[acnt ].assay_service_resource_cd =
     request->instr_service_resource_cd
    ENDIF
    IF ((reply->qual[qcnt ].container_serv_res[ccnt ].assays[acnt ].assay_service_resource_cd !=
    reply->qual[qcnt ].container_serv_res[ccnt ].service_resource_cd ) )
     SET dm_cnt +=1
     SET stat = alterlist (req250145->qual ,dm_cnt )
     SET req250145->qual[dm_cnt ].service_resource_cd = reply->qual[qcnt ].container_serv_res[ccnt ].
     service_resource_cd
     SET req250145->qual[dm_cnt ].task_assay_cd = reply->qual[qcnt ].container_serv_res[ccnt ].
     assays[acnt ].task_assay_cd
     SET req250145->qual[dm_cnt ].data_map_type_flag = 0
    ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 IF ((size (req250145->qual ,5 ) > 0 ) )
  SET trace = recpersist
  EXECUTE glb_get_data_map WITH replace ("REQUEST" ,"REQ250145" ) ,
  replace ("REPLY" ,"REP250145" )
  IF ((size (rep250145->qual ,5 ) > 0 ) )
   SET lidx = 0
   SET qualcntrep = size (reply->qual ,5 )
   FOR (qcntrep = 1 TO qualcntrep )
    SET contcnt = size (reply->qual[qcntrep ].container_serv_res ,5 )
    FOR (ccnt = 1 TO contcnt )
     SET assaycnt = size (reply->qual[qcntrep ].container_serv_res[ccnt ].assays ,5 )
     FOR (acnt = 1 TO assaycnt )
      SET taskassaycd = reply->qual[qcntrep ].container_serv_res[ccnt ].assays[acnt ].task_assay_cd
      SET ord_idx = locateval (lidx ,1 ,size (rep250145->qual ,5 ) ,taskassaycd ,rep250145->qual[
       lidx ].task_assay_cd )
      IF ((ord_idx > 0 )
      AND (rep250145->qual[ord_idx ].task_assay_cd = reply->qual[qcntrep ].container_serv_res[ccnt ].
      assays[acnt ].task_assay_cd ) )
       SET reply->qual[qcntrep ].container_serv_res[ccnt ].assays[acnt ].rout_inst_data_map_ind =
       rep250145->qual[ord_idx ].data_map_ind
       SET reply->qual[qcntrep ].container_serv_res[ccnt ].assays[acnt ].rout_inst_max_digits =
       rep250145->qual[ord_idx ].max_digits
       SET reply->qual[qcntrep ].container_serv_res[ccnt ].assays[acnt ].rout_inst_min_decimal_places
        = rep250145->qual[ord_idx ].min_decimal_places
       SET reply->qual[qcntrep ].container_serv_res[ccnt ].assays[acnt ].rout_inst_min_digits =
       rep250145->qual[ord_idx ].min_digits
      ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF ((((max_q_cnt = 0 ) ) OR ((((max_c_cnt = 0 ) ) OR ((max_a_cnt = 0 ) )) )) )
  GO TO resize_reply
 ENDIF
 SELECT INTO "nl:"
  join_path = decode (dm.seq ,"dm" ,r1.seq ,"r1" ,r2.seq ,"r2" ,"None" ) ,
  d1.seq ,
  d2.seq ,
  d3.seq ,
  d_dm.seq ,
  dm.seq ,
  dm_serv_res_mean = uar_get_code_meaning (dm.service_resource_cd ) ,
  d_r1.seq ,
  r1.seq ,
  pr1.seq ,
  ar_exists = decode (ar.seq ,"Y" ,"N" ) ,
  rrf1.seq ,
  pl1.seq ,
  d_rc1.seq ,
  result_comment_yn = decode (rc1.seq ,"Y" ,"N" ) ,
  rc1.seq ,
  d_r2.seq ,
  r2.seq ,
  pr2.seq ,
  c2.seq ,
  rrf2.seq ,
  ad2.seq
  FROM (dummyt d1 WITH seq = value (max_q_cnt ) ),
   (dummyt d2 WITH seq = value (max_c_cnt ) ),
   (dummyt d3 WITH seq = value (max_a_cnt ) ),
   (dummyt d_dm WITH seq = 1 ),
   (data_map dm ),
   (dummyt d_r1 WITH seq = 1 ),
   (result r1 ),
   (perform_result pr1 ),
   (reference_range_factor rrf1 ),
   (prsnl pl1 ),
   (nomenclature nc1 ),
   (dummyt d_rc1 WITH seq = 1 ),
   (result_comment rc1 ),
   (dummyt d_ar WITH seq = 1 ),
   (alpha_responses ar ),
   (dummyt d_r2 WITH seq = 1 ),
   (result r2 ),
   (perform_result pr2 ),
   (container c2 ),
   (reference_range_factor rrf2 ),
   (advanced_delta ad2 )
  PLAN (d1 )
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq ].container_serv_res_cnt ) )
   JOIN (d3
   WHERE (d3.seq <= reply->qual[d1.seq ].container_serv_res[d2.seq ].assays_cnt ) )
   JOIN (((d_dm
   WHERE (d_dm.seq = 1 ) )
   JOIN (dm
   WHERE (dm.task_assay_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].assays[d3.seq ].
   task_assay_cd )
   AND (dm.data_map_type_flag = data_map_type_flag )
   AND (dm.active_ind = 1 ) )
   ) ORJOIN ((((d_r1
   WHERE (d_r1.seq = 1 ) )
   JOIN (r1
   WHERE (r1.order_id = reply->qual[d1.seq ].order_id )
   AND (r1.task_assay_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].assays[d3.seq ].
   task_assay_cd ) )
   JOIN (pr1
   WHERE (pr1.result_id = r1.result_id )
   AND (pr1.result_status_cd = r1.result_status_cd ) )
   JOIN (rrf1
   WHERE (rrf1.reference_range_factor_id = pr1.reference_range_factor_id ) )
   JOIN (pl1
   WHERE (pl1.person_id = pr1.perform_personnel_id ) )
   JOIN (nc1
   WHERE (nc1.nomenclature_id = pr1.nomenclature_id ) )
   JOIN (d_rc1
   WHERE (d_rc1.seq = 1 ) )
   JOIN (rc1
   WHERE (rc1.result_id = pr1.result_id ) )
   JOIN (d_ar
   WHERE (d_ar.seq = 1 ) )
   JOIN (ar
   WHERE (ar.reference_range_factor_id = pr1.reference_range_factor_id )
   AND (ar.nomenclature_id = pr1.nomenclature_id ) )
   ) ORJOIN ((d_r2
   WHERE (d_r2.seq = 1 ) )
   JOIN (r2
   WHERE (r2.person_id = reply->person_id )
   AND (r2.task_assay_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].assays[d3.seq ].
   task_assay_cd )
   AND (r2.result_status_cd IN (result_status_verified_cd ,
   result_status_autoverified_cd ,
   result_status_corrected_cd ) ) )
   JOIN (pr2
   WHERE (pr2.result_id = r2.result_id )
   AND (pr2.result_status_cd = r2.result_status_cd ) )
   JOIN (c2
   WHERE (c2.container_id = pr2.container_id )
   AND (c2.drawn_dt_tm < cnvtdatetime (reply->qual[d1.seq ].container_serv_res[d2.seq ].drawn_dt_tm
    ) ) )
   JOIN (rrf2
   WHERE (rrf2.reference_range_factor_id = pr2.reference_range_factor_id ) )
   JOIN (ad2
   WHERE (ad2.advanced_delta_id = pr2.advanced_delta_id ) )
   )) ))
  HEAD REPORT
   q_cnt = 0 ,
   c_cnt = 0 ,
   a_cnt = 0 ,
   r_cnt = 0 ,
   data_map_level = 0 ,
   subsect_data_map_found = 0 ,
   rm_cnt = 0
  HEAD d1.seq
   q_cnt = d1.seq
  HEAD d2.seq
   c_cnt = d2.seq
  HEAD d3.seq
   next_repeat_nbr = - (1 ) ,a_cnt = d3.seq ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
   a_cnt ].data_map_ind = 0 ,data_map_level = 0 ,subsect_data_map_found = 0 ,r_cnt = 0
  DETAIL
   CASE (join_path )
    OF "dm" :
     IF ((data_map_level <= 2 )
     AND (dm.service_resource_cd > 0.0 )
     AND (dm.service_resource_cd = reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
     assay_service_resource_cd ) ) data_map_level = 3 ,reply->qual[q_cnt ].container_serv_res[c_cnt ]
      .assays[a_cnt ].data_map_ind = 1 ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ]
      .max_digits = dm.max_digits ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      min_digits = dm.min_digits ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      min_decimal_places = dm.min_decimal_places ,reply->qual[q_cnt ].container_serv_res[c_cnt ].
      assays[a_cnt ].result_entry_format = dm.result_entry_format
     ENDIF
     ,
     IF ((data_map_level = 0 )
     AND (dm.service_resource_cd = 0.0 ) ) data_map_level = 1 ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].data_map_ind = 1 ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].max_digits = dm.max_digits ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].min_digits = dm.min_digits ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].min_decimal_places = dm.min_decimal_places ,reply->
      qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].result_entry_format = dm
      .result_entry_format
     ENDIF
     ,
     IF ((subsect_data_map_found = 0 )
     AND (dm_serv_res_mean = serv_res_subsection_cdf ) ) subsect_data_map_found = 1
     ENDIF
    OF "r1" :
     r_cnt +=1 ,
     IF ((mod (r_cnt ,10 ) = 1 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].
       assays[a_cnt ].results ,(r_cnt + 10 ) )
     ENDIF
     ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results_cnt = r_cnt ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].perform_result_id
     = pr1.perform_result_id ,
     IF ((lookup_av_ind = 1 ) ) rm_cnt +=1 ,stat = alterlist (req250220->qual ,rm_cnt ) ,req250220->
      qual[rm_cnt ].task_assay_cd = reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      task_assay_cd ,req250220->qual[rm_cnt ].perform_result_id = pr1.perform_result_id ,req250220->
      qual[rm_cnt ].qual_idx = q_cnt ,req250220->qual[rm_cnt ].serv_res_idx = c_cnt ,req250220->qual[
      rm_cnt ].assay_idx = a_cnt ,req250220->qual[rm_cnt ].result_idx = r_cnt
     ENDIF
     ,
     IF ((pr1.repeat_nbr > next_repeat_nbr ) ) next_repeat_nbr = pr1.repeat_nbr
     ENDIF
     ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].repeat_nbr = pr1
     .repeat_nbr ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].result_id = r1
     .result_id ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].result_status_cd
     = r1.result_status_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].result_type_cd =
     pr1.result_type_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     resource_error_codes = pr1.resource_error_codes ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     reference_range_factor_id = pr1.reference_range_factor_id ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].advanced_delta_id
     = pr1.advanced_delta_id ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].equation_id = pr1
     .equation_id ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].normal_cd = pr1
     .normal_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].qc_override_cd =
     pr1.qc_override_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].critical_cd = pr1
     .critical_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].review_cd = pr1
     .review_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].linear_cd = pr1
     .linear_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].feasible_cd = pr1
     .feasible_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].dilution_factor =
     pr1.dilution_factor ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].delta_cd = pr1
     .delta_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].normal_range_flag
     = rrf1.normal_ind ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].normal_low = pr1
     .normal_low ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].normal_high = pr1
     .normal_high ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].normal_alpha = pr1
     .normal_alpha ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     critical_range_flag = rrf1.critical_ind ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].critical_low =
     rrf1.critical_low ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].critical_high =
     rrf1.critical_high ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].units_cd = pr1
     .units_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].nomenclature_id =
     pr1.nomenclature_id ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     result_value_numeric = pr1.result_value_numeric ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].numeric_raw_value
     = pr1.numeric_raw_value ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].result_value_alpha
      = pr1.result_value_alpha ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     result_value_alpha_mnemonic = nc1.mnemonic ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].result_value_dt_tm
      = pr1.result_value_dt_tm ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].long_text_id = pr1
     .long_text_id ,
     IF ((pr1.long_text_id > 0.0 ) ) lt_idx +=1 ,stat = alterlist (pcs_get_lt->rows ,lt_idx ) ,
      pcs_get_lt->rows[lt_idx ].qual_id = pr1.long_text_id ,pcs_get_lt->rows[lt_idx ].item_data1 =
      q_cnt ,pcs_get_lt->rows[lt_idx ].item_data2 = c_cnt ,pcs_get_lt->rows[lt_idx ].item_data3 =
      a_cnt ,pcs_get_lt->rows[lt_idx ].item_data4 = r_cnt ,pcs_get_lt->rows[lt_idx ].item_data5 =
      longtextflagrtf
     ENDIF
     ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].ascii_text = pr1
     .ascii_text ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].less_great_flag =
     pr1.less_great_flag ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     service_resource_cd = pr1.service_resource_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     perform_personnel_id = pr1.perform_personnel_id ,
     IF ((pl1.person_id > 0.0 ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      results[r_cnt ].perform_personnel_name = pl1.name_full_formatted
     ENDIF
     ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].perform_dt_tm =
     pr1.perform_dt_tm ,
     IF ((curutc = 1 ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt
      ].perform_tz = pr1.perform_tz
     ENDIF
     ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
     perform_result_updt_cnt = pr1.updt_cnt ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].result_updt_cnt =
     r1.updt_cnt ,
     IF ((result_comment_yn = "Y" ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      results[r_cnt ].result_comment_ind = 1
     ELSE reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].
      result_comment_ind = 0
     ENDIF
     ,
     IF ((ar_exists = "Y" ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[
      r_cnt ].use_units_ind = ar.use_units_ind
     ENDIF
     ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].notify_cd = pr1
     .notify_cd ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].worklist_id = pr1
     .worklist_id ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].interface_flag =
     pr1.interface_flag ,
     reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].chartable_flag =
     r1.chartable_flag
    OF "r2" :
     IF ((((reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_id <= 0.0 ) )
     OR ((reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_id > 0.0 )
     AND (cnvtdatetime (c2.drawn_dt_tm ) > cnvtdatetime (reply->qual[q_cnt ].container_serv_res[
      c_cnt ].assays[a_cnt ].prev_collected_dt_tm ) ) )) ) reply->qual[q_cnt ].container_serv_res[
      c_cnt ].assays[a_cnt ].prev_task_assay_cd = r2.task_assay_cd ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].prev_perform_result_id = pr2.perform_result_id ,reply
      ->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_id = r2.result_id ,reply->
      qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_status_cd = r2
      .result_status_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_reference_range_factor_id = pr2.reference_range_factor_id ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].prev_advanced_delta_id = pr2.advanced_delta_id ,reply
      ->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_normal_cd = pr2.normal_cd ,reply
      ->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_qc_override_cd = pr2
      .qc_override_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_critical_cd
       = pr2.critical_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_review_cd = pr2.review_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_notify_cd = pr2.notify_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_linear_cd = pr2.linear_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_feasible_cd = pr2.feasible_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
      a_cnt ].prev_dilution_factor = pr2.dilution_factor ,reply->qual[q_cnt ].container_serv_res[
      c_cnt ].assays[a_cnt ].prev_delta_cd = pr2.delta_cd ,reply->qual[q_cnt ].container_serv_res[
      c_cnt ].assays[a_cnt ].prev_result_type_cd = pr2.result_type_cd ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].prev_nomenclature_id = pr2.nomenclature_id ,reply->
      qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_equation_id = pr2.equation_id ,
      reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_value_numeric = pr2
      .result_value_numeric ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_numeric_raw_value = pr2.numeric_raw_value ,reply->qual[q_cnt ].container_serv_res[c_cnt ].
      assays[a_cnt ].prev_less_great_flag = pr2.less_great_flag ,reply->qual[q_cnt ].
      container_serv_res[c_cnt ].assays[a_cnt ].prev_result_value_alpha = pr2.result_value_alpha ,
      reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_value_dt_tm = pr2
      .result_value_dt_tm ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_long_text_id = pr2.long_text_id ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
      a_cnt ].prev_service_resource_cd = pr2.service_resource_cd ,
      IF ((pr2.long_text_id > 0.0 ) ) lt_idx +=1 ,stat = alterlist (pcs_get_lt->rows ,lt_idx ) ,
       pcs_get_lt->rows[lt_idx ].qual_id = pr2.long_text_id ,pcs_get_lt->rows[lt_idx ].item_data1 =
       q_cnt ,pcs_get_lt->rows[lt_idx ].item_data2 = c_cnt ,pcs_get_lt->rows[lt_idx ].item_data3 =
       a_cnt ,pcs_get_lt->rows[lt_idx ].item_data4 = 0 ,pcs_get_lt->rows[lt_idx ].item_data5 =
       longtextflagprevrtf
      ENDIF
      ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_ascii_text = pr2
      .ascii_text ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_collected_dt_tm
       = c2.drawn_dt_tm ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
      prev_resource_error_codes = pr2.resource_error_codes ,reply->qual[q_cnt ].container_serv_res[
      c_cnt ].assays[a_cnt ].prev_delta_chk_flag = rrf2.delta_chk_flag ,
      IF ((ad2.advanced_delta_id > 0 ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt
       ].prev_delta_low = ad2.delta_low ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt
       ].prev_delta_high = ad2.delta_high ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
       a_cnt ].prev_delta_check_type_cd = ad2.delta_check_type_cd ,reply->qual[q_cnt ].
       container_serv_res[c_cnt ].assays[a_cnt ].prev_delta_minutes = ad2.delta_minutes ,reply->qual[
       q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_delta_value = ad2.delta_value
      ELSEIF ((rrf2.delta_chk_flag > 0 ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
       a_cnt ].prev_delta_low = 0.0 ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
       prev_delta_high = 0.0 ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
       prev_delta_check_type_cd = rrf2.delta_check_type_cd ,reply->qual[q_cnt ].container_serv_res[
       c_cnt ].assays[a_cnt ].prev_delta_minutes = rrf2.delta_minutes ,reply->qual[q_cnt ].
       container_serv_res[c_cnt ].assays[a_cnt ].prev_delta_value = rrf2.delta_value
      ENDIF
     ENDIF
   ENDCASE
  FOOT  d3.seq
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].next_repeat_nbr = (next_repeat_nbr
   + 1 ) ,
   IF ((r_cnt > 0 ) ) stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ]
     .results ,r_cnt )
   ENDIF
   ,
   IF ((subsect_data_map_found = 1 )
   AND (data_map_level <= 2 ) ) cnt = size (data_map_rec->list ,5 ) ,cnt +=1 ,stat = alterlist (
     data_map_rec->list ,cnt ) ,data_map_rec->list[cnt ].task_assay_cd = reply->qual[d1.seq ].
    container_serv_res[d2.seq ].assays[d3.seq ].task_assay_cd ,data_map_rec->list[cnt ].
    service_resource_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].service_resource_cd ,
    data_map_rec->list[cnt ].q_cnt = q_cnt ,data_map_rec->list[cnt ].c_cnt = c_cnt ,data_map_rec->
    list[cnt ].a_cnt = a_cnt
   ENDIF
  FOOT  d2.seq
   row + 0
  FOOT  d1.seq
   row + 0
  WITH nocounter ,outerjoin = d3 ,outerjoin = d_dm ,dontcare = dm ,outerjoin = d_r1 ,outerjoin =
   d_rc1 ,dontcare = rc1 ,maxread (rc1 ,1 ) ,outerjoin = d_ar ,outerjoin = d_r2
 ;end select
 CALL echo (";* get the long text data from pcs_get_long_text.inc" )
 IF ((pcsgetlongtext (0 ) > 0 ) )
  FOR (lt_idx = 1 TO size (pcs_get_lt->rows ,5 ) )
   IF ((pcs_get_lt->rows[lt_idx ].lt_found_ind = 1 ) )
    SET q_cnt = pcs_get_lt->rows[lt_idx ].item_data1
    SET c_cnt = pcs_get_lt->rows[lt_idx ].item_data2
    SET a_cnt = pcs_get_lt->rows[lt_idx ].item_data3
    SET r_cnt = pcs_get_lt->rows[lt_idx ].item_data4
    IF ((pcs_get_lt->rows[lt_idx ].item_data5 = longtextflagrtf ) )
     SET reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].results[r_cnt ].rtf_text =
     pcs_get_lt->rows[lt_idx ].long_text
    ELSE
     SET reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_rtf_text = pcs_get_lt->
     rows[lt_idx ].long_text
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SET lt_idx = 0
 SET stat = initrec (pcs_get_lt )
 CALL echo ("Done with fetching long_text data. For LT1 and LT2" )
 SET max_cnt = size (data_map_rec->list ,5 )
 IF ((max_cnt > 0 ) )
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d WITH seq = value (max_cnt ) ),
    (data_map dm ),
    (resource_group rg )
   PLAN (d )
    JOIN (dm
    WHERE (dm.task_assay_cd = data_map_rec->list[d.seq ].task_assay_cd )
    AND (dm.service_resource_cd > 0.0 )
    AND (dm.data_map_type_flag = data_map_type_flag )
    AND (dm.active_ind = 1 ) )
    JOIN (rg
    WHERE (rg.parent_service_resource_cd = dm.service_resource_cd )
    AND (rg.child_service_resource_cd = data_map_rec->list[d.seq ].service_resource_cd )
    AND (rg.resource_group_type_cd = serv_res_subsection_cd )
    AND (rg.root_service_resource_cd = 0.0 ) )
   DETAIL
    q_cnt = data_map_rec->list[d.seq ].q_cnt ,
    c_cnt = data_map_rec->list[d.seq ].c_cnt ,
    a_cnt = data_map_rec->list[d.seq ].a_cnt ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].data_map_ind = 1 ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].max_digits = dm.max_digits ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].min_digits = dm.min_digits ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].min_decimal_places = dm
    .min_decimal_places ,
    reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].result_entry_format = dm
    .result_entry_format
   WITH nocounter
  ;end select
 ENDIF
 FOR (q_cnt = 1 TO max_q_cnt )
  FOR (c_cnt = 1 TO reply->qual[q_cnt ].container_serv_res_cnt )
   FOR (a_cnt = 1 TO reply->qual[q_cnt ].container_serv_res[c_cnt ].assays_cnt )
    IF ((reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].rel_assay_ind = 1 ) )
     SELECT INTO "nl:"
      r.result_id ,
      pr.perform_result_id ,
      c.container_id ,
      rrf.reference_range_factor_id ,
      ad.advanced_delta_id
      FROM (result r ),
       (perform_result pr ),
       (container c ),
       (reference_range_factor rrf ),
       (advanced_delta ad )
      PLAN (r
       WHERE (r.person_id = reply->person_id )
       AND (r.task_assay_cd IN (
       (SELECT
        task_assay_cd
        FROM (related_assay )
        WHERE (related_entity_id =
        (SELECT
         related_entity_id
         FROM (related_assay )
         WHERE (task_assay_cd = reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
         task_assay_cd ) ) ) ) ) )
       AND (r.result_status_cd IN (result_status_verified_cd ,
       result_status_autoverified_cd ,
       result_status_corrected_cd ) ) )
       JOIN (pr
       WHERE (pr.result_id = r.result_id )
       AND (pr.result_status_cd = r.result_status_cd ) )
       JOIN (c
       WHERE (c.container_id = pr.container_id ) )
       JOIN (rrf
       WHERE (rrf.reference_range_factor_id = pr.reference_range_factor_id ) )
       JOIN (ad
       WHERE (ad.advanced_delta_id = pr.advanced_delta_id ) )
      DETAIL
       IF ((cnvtdatetime (c.drawn_dt_tm ) < cnvtdatetime (reply->qual[q_cnt ].container_serv_res[
        c_cnt ].drawn_dt_tm ) ) )
        IF ((((reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_id <= 0.0 )
        ) OR ((reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_id > 0.0 )
        AND (cnvtdatetime (c.drawn_dt_tm ) > cnvtdatetime (reply->qual[q_cnt ].container_serv_res[
         c_cnt ].assays[a_cnt ].prev_collected_dt_tm ) ) )) ) reply->qual[q_cnt ].container_serv_res[
         c_cnt ].assays[a_cnt ].prev_task_assay_cd = r.task_assay_cd ,reply->qual[q_cnt ].
         container_serv_res[c_cnt ].assays[a_cnt ].prev_perform_result_id = pr.perform_result_id ,
         reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_id = r.result_id ,
         reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_status_cd = r
         .result_status_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
         prev_reference_range_factor_id = pr.reference_range_factor_id ,reply->qual[q_cnt ].
         container_serv_res[c_cnt ].assays[a_cnt ].prev_advanced_delta_id = pr.advanced_delta_id ,
         reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_normal_cd = pr.normal_cd
        ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_critical_cd = pr
         .critical_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_review_cd
         = pr.review_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_notify_cd
          = pr.notify_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
         prev_linear_cd = pr.linear_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ]
         .prev_feasible_cd = pr.feasible_cd ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
         a_cnt ].prev_dilution_factor = pr.dilution_factor ,reply->qual[q_cnt ].container_serv_res[
         c_cnt ].assays[a_cnt ].prev_delta_cd = pr.delta_cd ,reply->qual[q_cnt ].container_serv_res[
         c_cnt ].assays[a_cnt ].prev_result_type_cd = pr.result_type_cd ,reply->qual[q_cnt ].
         container_serv_res[c_cnt ].assays[a_cnt ].prev_nomenclature_id = pr.nomenclature_id ,reply->
         qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_equation_id = pr.equation_id ,
         reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_value_numeric = pr
         .result_value_numeric ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
         prev_numeric_raw_value = pr.numeric_raw_value ,reply->qual[q_cnt ].container_serv_res[c_cnt
         ].assays[a_cnt ].prev_less_great_flag = pr.less_great_flag ,reply->qual[q_cnt ].
         container_serv_res[c_cnt ].assays[a_cnt ].prev_result_value_alpha = pr.result_value_alpha ,
         reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_result_value_dt_tm = pr
         .result_value_dt_tm ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
         prev_long_text_id = pr.long_text_id ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
         a_cnt ].prev_service_resource_cd = pr.service_resource_cd ,
         IF ((pr.long_text_id > 0.0 ) ) lt_idx +=1 ,stat = alterlist (pcs_get_lt->rows ,lt_idx ) ,
          pcs_get_lt->rows[lt_idx ].qual_id = pr.long_text_id ,pcs_get_lt->rows[lt_idx ].item_data1
          = q_cnt ,pcs_get_lt->rows[lt_idx ].item_data2 = c_cnt ,pcs_get_lt->rows[lt_idx ].item_data3
           = a_cnt
         ENDIF
         ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_ascii_text = pr
         .ascii_text ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
         prev_collected_dt_tm = c.drawn_dt_tm ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
         a_cnt ].prev_delta_chk_flag = rrf.delta_chk_flag ,
         IF ((ad.advanced_delta_id > 0 ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
          a_cnt ].prev_delta_low = ad.delta_low ,reply->qual[q_cnt ].container_serv_res[c_cnt ].
          assays[a_cnt ].prev_delta_high = ad.delta_high ,reply->qual[q_cnt ].container_serv_res[
          c_cnt ].assays[a_cnt ].prev_delta_check_type_cd = ad.delta_check_type_cd ,reply->qual[
          q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_delta_minutes = ad.delta_minutes ,
          reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_delta_value = ad
          .delta_value
         ELSEIF ((rrf.delta_chk_flag > 0 ) ) reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[
          a_cnt ].prev_delta_low = 0.0 ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ]
          .prev_delta_high = 0.0 ,reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].
          prev_delta_check_type_cd = rrf.delta_check_type_cd ,reply->qual[q_cnt ].container_serv_res[
          c_cnt ].assays[a_cnt ].prev_delta_minutes = rrf.delta_minutes ,reply->qual[q_cnt ].
          container_serv_res[c_cnt ].assays[a_cnt ].prev_delta_value = rrf.delta_value
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     CALL echo (";* get the long text data from pcs_get_long_text.inc" )
     IF ((pcsgetlongtext (0 ) > 0 ) )
      FOR (lt_idx = 1 TO size (pcs_get_lt->rows ,5 ) )
       IF ((pcs_get_lt->rows[lt_idx ].lt_found_ind = 1 ) )
        SET q_cnt = pcs_get_lt->rows[lt_idx ].item_data1
        SET c_cnt = pcs_get_lt->rows[lt_idx ].item_data2
        SET a_cnt = pcs_get_lt->rows[lt_idx ].item_data3
        SET reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].prev_rtf_text = pcs_get_lt
        ->rows[lt_idx ].long_text
       ENDIF
      ENDFOR
     ENDIF
     SET lt_idx = 0
     SET stat = initrec (pcs_get_lt )
     CALL echo ("Done with fetching long_text data for req.qual.csr.assay.prev_rtf_text" )
    ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 CALL pcsgetlongtextcleanup (0 )
 IF ((lookup_av_ind = 1 )
 AND (size (req250220->qual ,5 ) > 0 ) )
  SET trace = recpersist
  EXECUTE glb_get_autoverify_codes WITH replace ("REQUEST" ,"REQ250220" ) ,
  replace ("REPLY" ,"REP250220" )
  SELECT INTO "nl:"
   q_idx = req250220->qual[d_req.seq ].qual_idx ,
   c_idx = req250220->qual[d_req.seq ].serv_res_idx ,
   a_idx = req250220->qual[d_req.seq ].assay_idx ,
   r_idx = req250220->qual[d_req.seq ].result_idx
   FROM (dummyt d_req WITH seq = size (req250220->qual ,5 ) ),
    (dummyt d_rep WITH seq = size (rep250220->qual ,5 ) ),
    (dummyt d_avc WITH seq = 1 )
   PLAN (d_req )
    JOIN (d_rep
    WHERE (req250220->qual[d_req.seq ].perform_result_id = rep250220->qual[d_rep.seq ].
    perform_result_id )
    AND maxrec (d_avc ,size (rep250220->qual[d_rep.seq ].av_codes ,5 ) ) )
    JOIN (d_avc )
   HEAD d_rep.seq
    stat = alterlist (reply->qual[q_idx ].container_serv_res[c_idx ].assays[a_idx ].results[r_idx ].
     av_codes ,size (rep250220->qual[d_rep.seq ].av_codes ,5 ) )
   DETAIL
    reply->qual[q_idx ].container_serv_res[c_idx ].assays[a_idx ].results[r_idx ].av_codes[d_avc.seq
    ].auto_verify_cd = rep250220->qual[d_rep.seq ].av_codes[d_avc.seq ].auto_verify_cd
   WITH nocounter
  ;end select
 ENDIF
 IF ((((max_q_cnt = 0 ) ) OR ((((max_c_cnt = 0 ) ) OR ((max_a_cnt = 0 ) )) )) )
  GO TO resize_reply
 ENDIF
 IF ((request->instr_service_resource_cd = 0.0 ) )
  GO TO resize_reply
 ENDIF
 SELECT INTO "nl:"
  d1.seq ,
  d2.seq ,
  d3.seq ,
  apr.seq ,
  art.seq
  FROM (dummyt d1 WITH seq = value (max_q_cnt ) ),
   (dummyt d2 WITH seq = value (max_c_cnt ) ),
   (dummyt d3 WITH seq = value (max_a_cnt ) ),
   (assay_processing_r apr ),
   (assay_resource_translation art )
  PLAN (d1 )
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq ].container_serv_res_cnt ) )
   JOIN (d3
   WHERE (d3.seq <= reply->qual[d1.seq ].container_serv_res[d2.seq ].assays_cnt ) )
   JOIN (apr
   WHERE (apr.service_resource_cd = request->instr_service_resource_cd )
   AND (apr.task_assay_cd = reply->qual[d1.seq ].container_serv_res[d2.seq ].assays[d3.seq ].
   task_assay_cd ) )
   JOIN (art
   WHERE (art.task_assay_cd = apr.task_assay_cd )
   AND ((art.service_resource_cd + 0 ) = apr.service_resource_cd )
   AND (art.active_ind > 0 ) )
  HEAD REPORT
   q_cnt = 0 ,
   c_cnt = 0 ,
   a_cnt = 0 ,
   i_cnt = 0
  HEAD d1.seq
   q_cnt = d1.seq
  HEAD d2.seq
   c_cnt = d2.seq
  HEAD d3.seq
   a_cnt = d3.seq ,i_cnt = 0
  DETAIL
   i_cnt +=1 ,
   stat = alterlist (reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr ,i_cnt ) ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr_cnt = i_cnt ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].instr_service_resource_cd = apr
   .service_resource_cd ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr[i_cnt ].upld_assay_alias = art
   .upld_assay_alias ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr[i_cnt ].process_sequence = art
   .process_sequence ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr[i_cnt ].decimal_movement_nbr
   = art.decimal_movement_nbr ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr[i_cnt ].default_result_type_cd
    = apr.default_result_type_cd ,
   reply->qual[q_cnt ].container_serv_res[c_cnt ].assays[a_cnt ].instr[i_cnt ].post_zero_result_ind
   = art.post_zero_result_ind
  WITH nocounter
 ;end select
 SUBROUTINE  (validatelogicaldomain (no_param =i2 (value ) ) =i2 )
  DECLARE serv_res_log_dom_id = f8 WITH noconstant (0 ) ,protect
  SELECT
   org.logical_domain_id
   FROM (service_resource sr ),
    (organization org )
   PLAN (sr
    WHERE (sr.service_resource_cd = request->instr_service_resource_cd ) )
    JOIN (org
    WHERE (org.organization_id = sr.organization_id ) )
   DETAIL
    serv_res_log_dom_id = org.logical_domain_id
   WITH nocounter
  ;end select
  DECLARE acc_log_dom_id = f8 WITH noconstant (0 ) ,protect
  SELECT
   org.logical_domain_id
   FROM (accession_order_r aor ),
    (orders o ),
    (encounter e ),
    (organization org )
   PLAN (aor
    WHERE (aor.accession = request->accession ) )
    JOIN (o
    WHERE (o.order_id = aor.order_id ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id ) )
    JOIN (org
    WHERE (e.organization_id = org.organization_id ) )
   DETAIL
    acc_log_dom_id = org.logical_domain_id
   WITH nocounter
  ;end select
  IF ((serv_res_log_dom_id = acc_log_dom_id ) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (lockaccessionformdi (no_param =i2 (value ) ) =i4 )
  DECLARE dsecondstowait = f8 WITH protect ,noconstant (30.0 )
  DECLARE lock_accn_info_domain = vc WITH protect ,constant ("PATHNET GENERAL LAB" )
  DECLARE lock_accn_info_name = vc WITH protect ,constant ("LOCK ACCESSION FOR MDI" )
  DECLARE serrormsg = c255 WITH protect ,noconstant ("" )
  DECLARE lerrornbr = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (dm_info di )
   PLAN (di
    WHERE (di.info_domain = lock_accn_info_domain )
    AND (di.info_name = lock_accn_info_name ) )
   DETAIL
    IF ((di.info_number > 0 ) ) dsecondstowait = di.info_number
    ENDIF
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (accession a )
   PLAN (a
    WHERE (a.accession = request->accession ) )
   WITH nocounter ,forupdatewait (a ) ,time = dsecondstowait
  ;end select
  SET lerrornbr = error (serrormsg ,1 )
  RETURN (lerrornbr )
 END ;Subroutine
#resize_reply
 IF ((getresourcesecuritystatus (0 ) != "S" ) )
  CALL populateressecstatusblock (0 )
  SET reply->status_data.status = getresourcesecuritystatus (0 )
 ELSEIF ((max_q_cnt > 0 ) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script

; FREE RECORD data_map_rec

 ;call echorecord(reply)
 ;call echorecord(data_map_rec)
 ;call echorecord(req250220)
 ;call echo(route_lvl_one_found)
END GO

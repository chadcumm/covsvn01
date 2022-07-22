
DROP PROGRAM him_mak_defic_by_phys_driver :dba GO
CREATE PROGRAM him_mak_defic_by_phys_driver :dba
 FREE SET visit_age_request
 RECORD visit_age_request (
   1 total_qual [* ]
     2 physician_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 starting_pos = i4
 )
 FREE SET visit_age_reply
 RECORD visit_age_reply (
   1 encntr_qual [* ]
     2 encntr_id = f8
     2 physician_id = f8
     2 chart_age = i2
     2 qualified_ind = i2
     2 starting_pos = i4
 )
 FREE SET doc_age_request
 RECORD doc_age_request (
   1 visit_hold_ind = i2
   1 phys_hold_ind = i2
   1 manual_alloc_ind = i2
   1 phys_qual [* ]
     2 physstart_pos = i4
     2 physician_id = f8
     2 organization_id = f8
     2 encntr_qual [* ]
       3 encstart_pos = i4
       3 encntr_id = f8
       3 organization_id = f8
       3 event_qual [* ]
         4 evnstart_pos = i4
         4 event_id = f8
         4 event_cd = f8
         4 action_type_cd = f8
         4 action_status_cd = f8
         4 alloc_dt_tm = dq8
         4 request_dt_tm = dq8
         4 completed_dt_tm = dq8
         4 d_dict_hours = i4
         4 d_sign_hours = i4
         4 s_dict_hours = i4
         4 s_sign_hours = i4
         4 trans_ind = i2
         4 t_start_dt_tm = dq8
         4 t_end_dt_tm = dq8
         4 hold_qual [* ]
           5 hold_start_dt_tm = dq8
           5 hold_stop_dt_tm = dq8
           5 hold_type = c1
           5 tran_hold_ind = i2
 )
 FREE SET doc_age_reply
 RECORD doc_age_reply (
   1 phys_qual [* ]
     2 physstart_pos = i4
     2 physician_id = f8
     2 organization_id = f8
     2 encntr_qual [* ]
       3 encstart_pos = i4
       3 encntr_id = f8
       3 organization_id = f8
       3 delinquent_docs = i4
       3 suspended_docs = i4
       3 event_qual [* ]
         4 evnstart_pos = i4
         4 event_id = f8
         4 document_age = i4
 )
 FREE SET order_struct
 RECORD order_struct (
   1 visit_hold_ind = i2
   1 phys_hold_ind = i2
   1 d_sign_hours = i4
   1 s_sign_hours = i4
   1 most_severe_ind = i2
   1 order_status_flag = i2
   1 phys_qual [* ]
     2 physstart_pos = i4
     2 physician_id = f8
     2 organization_id = f8
     2 encntr_qual [* ]
       3 encstart_pos = i4
       3 encntr_id = f8
       3 organization_id = f8
       3 delinquent_orders = i4
       3 suspended_orders = i4
       3 hold_qual [* ]
         4 hold_start_dt_tm = dq8
         4 hold_stop_dt_tm = dq8
         4 hold_type_cd = f8
       3 order_qual [* ]
         4 order_id = f8
         4 action_sequence = i4
         4 alloc_dt_tm = dq8
         4 order_age = i4
 )
 FREE RECORD order_age_reply
 RECORD order_age_reply (
   1 qual [* ]
     2 physician_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 action_sequence = i4
     2 total_age = i4
     2 age_level_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE encntr_pos = i4 WITH public ,noconstant (0 )
 DECLARE iloop = i2 WITH public ,noconstant (0 )
 DECLARE pn_ur_only_ind = i2 WITH private ,noconstant (0 )
 DECLARE gn_index = i2 WITH public ,noconstant (0 )
 DECLARE gl_phys_pos = i4 WITH public ,noconstant (0 )
 DECLARE gl_org_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_phys_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_data_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_encntr_pos = i4 WITH public ,noconstant (0 )
 DECLARE gl_event_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_encntr_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_visit_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_defic_pos = i4 WITH public ,noconstant (0 )
 DECLARE gl_phys_qual_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_event_qual_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_starting_pos = i4 WITH public ,noconstant (0 )
 DECLARE mc_mrn_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,319 ,"MRN" ) ) ,protect
 DECLARE mc_fin_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) ) ,protect
 DECLARE mc_first_pc_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE gc_dec_31st_2100 = vc WITH public ,constant ("31-DEC-2100 00:00:00.00" )
 DECLARE gc_physician_parser = vc WITH public ,noconstant (" " )
 DECLARE gl_ord_age_cnt = i4 WITH public ,noconstant (0 )
 DECLARE gl_loop_cnt = i4 WITH public ,noconstant (0 )
 DECLARE pf_first_pc_cd = f8 WITH private ,noconstant (0.0 )
 DECLARE i4ordqualcnt = i4 WITH public ,noconstant (0 )
 DECLARE i4defqualcnt = i4 WITH public ,noconstant (0 )
 DECLARE i4qualcount = i4 WITH public ,noconstant (0 )
 IF ((validate (him_r_system_params_inc ) = 0 ) )
  DECLARE him_r_system_params_inc = i2 WITH public ,noconstant (1 )
  DECLARE multifacility_ind = i2 WITH protect ,noconstant (0 )
  DECLARE tracking_orders_ind = i2 WITH protect ,noconstant (0 )
  DECLARE pending_signs_ind = i2 WITH protect ,noconstant (0 )
  DECLARE visit_aging_ind = i2 WITH protect ,noconstant (0 )
  DECLARE doc_aging_ind = i2 WITH protect ,noconstant (0 )
  DECLARE phys_hold_ind = i2 WITH protect ,noconstant (0 )
  DECLARE visit_hold_ind = i2 WITH protect ,noconstant (0 )
  DECLARE days_to_delinq = i4 WITH protect ,noconstant (0 )
  DECLARE days_to_suspend = i4 WITH protect ,noconstant (0 )
  DECLARE loading_letters = i2 WITH protect ,noconstant (0 )
  DECLARE loading_powervision = i2 WITH protect ,noconstant (0 )
  DECLARE order_delinq_hours = i2 WITH protect ,noconstant (0 )
  DECLARE order_susp_hours = i2 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (him_system_params hp )
   WHERE (hp.him_system_params_id > 0 )
   AND (hp.active_ind = 1 )
   DETAIL
    multifacility_ind = hp.facility_logic_ind ,
    tracking_orders_ind = hp.order_tracking_ind ,
    pending_signs_ind = hp.pending_signs_ind ,
    visit_aging_ind = hp.visitaging_ind ,
    doc_aging_ind = hp.docaging_ind ,
    phys_hold_ind = hp.docaging_phys_hold_ind ,
    visit_hold_ind = hp.docaging_visit_hold_ind ,
    days_to_suspend = hp.days_to_suspend ,
    days_to_delinq = hp.days_to_delinquent ,
    loading_letters = hp.loading_letters_ind ,
    loading_powervision = hp.loading_powervision_ind ,
    order_delinq_hours = (hp.order_delinquent_days * 24 ) ,
    order_susp_hours = (hp.order_suspension_days * 24 )
   WITH nocounter
  ;end select
  DECLARE him_multifacility_ind = i2 WITH public ,constant (multifacility_ind )
  DECLARE him_tracking_orders_ind = i2 WITH public ,constant (tracking_orders_ind )
  DECLARE him_pending_signs_ind = i2 WITH public ,constant (pending_signs_ind )
  DECLARE him_visit_aging_ind = i2 WITH public ,constant (visit_aging_ind )
  DECLARE him_doc_aging_ind = i2 WITH public ,constant (doc_aging_ind )
  DECLARE him_phys_hold_ind = i2 WITH public ,constant (phys_hold_ind )
  DECLARE him_visit_hold_ind = i2 WITH public ,constant (visit_hold_ind )
  DECLARE him_days_to_suspend = i4 WITH public ,constant (days_to_suspend )
  DECLARE him_days_to_delinq = i4 WITH public ,constant (days_to_delinq )
  DECLARE him_loading_letters_ind = i2 WITH public ,constant (loading_letters )
  DECLARE him_loading_pv_ind = i2 WITH public ,constant (loading_powervision )
  DECLARE him_order_delinq_hrs = i2 WITH public ,constant (order_delinq_hours )
  DECLARE him_order_susp_hrs = i2 WITH public ,constant (order_susp_hours )
 ENDIF
 IF ((validate (him_deficiency_cds_included ) = 0 ) )
  DECLARE him_deficiency_cds_included = i2 WITH public ,constant (1 )
  DECLARE perform_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE sign_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE cosign_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE modify_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE requested_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE pending_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE completed_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE inerror_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE transcribe_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE req_dict_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE req_sign_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE pend_sign_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE req_mod_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE pend_trans_cd = f8 WITH public ,noconstant (0.0 )
  DECLARE pend_age_ind = i2 WITH public ,noconstant (0 )
  SET stat = uar_get_meaning_by_codeset (21 ,"PERFORM" ,1 ,perform_cd )
  SET stat = uar_get_meaning_by_codeset (21 ,"SIGN" ,1 ,sign_cd )
  SET stat = uar_get_meaning_by_codeset (21 ,"COSIGN" ,1 ,cosign_cd )
  SET stat = uar_get_meaning_by_codeset (21 ,"MODIFY" ,1 ,modify_cd )
  SET stat = uar_get_meaning_by_codeset (21 ,"TRANSCRIBE" ,1 ,transcribe_cd )
  SET stat = uar_get_meaning_by_codeset (103 ,"REQUESTED" ,1 ,requested_cd )
  SET stat = uar_get_meaning_by_codeset (103 ,"PENDING" ,1 ,pending_cd )
  SET stat = uar_get_meaning_by_codeset (103 ,"INERROR" ,1 ,inerror_cd )
  SET stat = uar_get_meaning_by_codeset (103 ,"COMPLETED" ,1 ,completed_cd )
  SET stat = uar_get_meaning_by_codeset (14030 ,"PEND DICT" ,1 ,req_dict_cd )
  SET stat = uar_get_meaning_by_codeset (14030 ,"EXPECT SIGN" ,1 ,pend_sign_cd )
  SET stat = uar_get_meaning_by_codeset (14030 ,"PEND SIGN" ,1 ,req_sign_cd )
  SET stat = uar_get_meaning_by_codeset (14030 ,"PEND MODIFY" ,1 ,req_mod_cd )
  SET stat = uar_get_meaning_by_codeset (14030 ,"PEND TRANS" ,1 ,pend_trans_cd )
  DECLARE ireq_perform = i2 WITH protect ,constant (1 )
  DECLARE ipend_sign = i2 WITH protect ,constant (2 )
  DECLARE ireq_sign = i2 WITH protect ,constant (3 )
  DECLARE ireq_modify = i2 WITH protect ,constant (4 )
  DECLARE iundeclared = i2 WITH protect ,constant (99 )
  SELECT INTO "nl:"
   FROM (code_value_extension cve )
   WHERE (cve.code_set = 14030 )
   AND (cve.code_value = pend_sign_cd )
   AND (cve.field_name = "age_ind" )
   DETAIL
    pend_age_ind = cnvtint (cve.field_value )
   WITH nocounter
  ;end select
 ENDIF
 DECLARE vcorganizations = vc WITH noconstant ("" ) ,protect
 DECLARE i4orgqualindex = i4 WITH noconstant (0 ) ,protect
 DECLARE i4orgqualcount = i4 WITH noconstant (size (organizations->qual ,5 ) ) ,protect
 IF ((i1multifacilitylogicind = 1 )
 AND (i4orgqualcount = 0 ) )
  DECLARE getuserfacilities ((remove_trust_ind = i2 ) ) = i2 WITH protect
  IF ((validate (org_list ) != 1 ) )
   RECORD org_list (
     1 organizations [* ]
       2 organization_id = f8
       2 confid_cd = f8
       2 confid_level = i4
   )
  ENDIF
  SUBROUTINE  getuserfacilities (remove_trust_ind )
   DECLARE logon_type_flag = i2 WITH protect ,noconstant (0 )
   DECLARE org_cnt = i4 WITH protect ,noconstant (0 )
   DECLARE ret_stat = i4 WITH protect ,noconstant (0 )
   EXECUTE sac_get_user_organizations WITH replace ("REPLY" ,"ORG_LIST" )
   EXECUTE sacrtl
   SET logon_type_flag = uar_sacgetuserlogontype ()
   IF ((logon_type_flag = 1 )
   AND (remove_trust_ind = 1 ) )
    SET org_cnt = size (org_list->organizations ,5 )
    SET ret_stat = alterlist (org_list->organizations ,(org_cnt - 1 ) ,0 )
   ENDIF
  END ;Subroutine
  DECLARE batch_size = i2 WITH noconstant (20 ) ,protect
  DECLARE cur_list_size = i4 WITH noconstant (0 ) ,protect
  DECLARE new_list_size = i4 WITH noconstant (0 ) ,protect
  DECLARE nstart = i4 WITH noconstant (0 ) ,protect
  DECLARE idx = i4 WITH noconstant (0 ) ,protect
  DECLARE loop_cnt = i4 WITH noconstant (0 ) ,protect
  CALL getuserfacilities (1 )
  SET cur_list_size = size (org_list->organizations ,5 )
  IF ((cur_list_size > 0 ) )
   SET loop_cnt = ceil ((cnvtreal (cur_list_size ) / batch_size ) )
   SET new_list_size = (loop_cnt * batch_size )
   SET stat = alterlist (org_list->organizations ,new_list_size )
   SET nstart = 1
   SET idx = 0
   SET stat = alterlist (organizations->qual ,cur_list_size )
   FOR (idx = (cur_list_size + 1 ) TO new_list_size )
    SET org_list->organizations[idx ].organization_id = org_list->organizations[cur_list_size ].
    organization_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    organization_id = o.organization_id ,
    organization_name = substring (1 ,100 ,o.org_name )
    FROM (dummyt d WITH seq = value (loop_cnt ) ),
     (organization o )
    PLAN (d
     WHERE initarray (nstart ,evaluate (d.seq ,1 ,1 ,(nstart + batch_size ) ) ) )
     JOIN (o
     WHERE expand (idx ,nstart ,(nstart + (batch_size - 1 ) ) ,o.organization_id ,org_list->
      organizations[idx ].organization_id ) )
    ORDER BY organization_name ,
     organization_id
    DETAIL
     i4orgqualcount = (i4orgqualcount + 1 ) ,
     organizations->qual[i4orgqualcount ].item_id = organization_id ,
     organizations->qual[i4orgqualcount ].item_name = organization_name
    WITH nocounter
   ;end select
   IF ((curqual = 0 ) )
    SET vcorganizations = "o.organization_id = 0"
   ENDIF
  ENDIF
 ELSE
  SET vcorganizations = "o.organization_id != 0"
 ENDIF
 IF ((i4orgqualcount != 0 ) )
  SET vcorganizations = build2 ("expand(i4OrgQualIndex, 1, i4OrgQualCount, o.organization_id," ,
   "organizations->qual[i4OrgQualIndex].item_id)" )
 ENDIF
 IF ((validate (r_orders_included ) = 0 ) )
  DECLARE r_orders_included = i2 WITH public ,constant (1 )
  DECLARE template_flag_none = i2 WITH public ,constant (0 )
  DECLARE template_flag_template = i2 WITH public ,constant (1 )
  DECLARE review_type_flag_doctor = i2 WITH public ,constant (2 )
  DECLARE review_sts_flag_noreview = i2 WITH public ,constant (0 )
  DECLARE review_sts_flag_accepted = i2 WITH public ,constant (1 )
  DECLARE review_sts_flag_rejected = i2 WITH public ,constant (2 )
  DECLARE review_sts_flag_noneeded = i2 WITH public ,constant (3 )
  DECLARE review_sts_flag_supercd = i2 WITH public ,constant (4 )
  DECLARE review_sts_flag_reviewed = i2 WITH public ,constant (5 )
  DECLARE notif_sts_flag_pending = i2 WITH public ,constant (1 )
  DECLARE notif_sts_flag_complete = i2 WITH public ,constant (2 )
  DECLARE notif_sts_flag_refused = i2 WITH public ,constant (3 )
  DECLARE notif_sts_flag_forward = i2 WITH public ,constant (4 )
  DECLARE notif_sts_flag_admin = i2 WITH public ,constant (5 )
  DECLARE notif_sts_flag_notneeded = i2 WITH public ,constant (6 )
  DECLARE notif_type_flag_cosign = i2 WITH public ,constant (2 )
  DECLARE him_tracking_orders (null ) = i2
  SUBROUTINE  him_tracking_orders (null )
   DECLARE i2_tracking = i2 WITH protect ,noconstant (0 )
   SELECT INTO "nl:"
    FROM (him_system_params hp )
    WHERE (hp.him_system_params_id > 0 )
    DETAIL
     i2_tracking = hp.order_tracking_ind
    WITH nocounter
   ;end select
   RETURN (i2_tracking )
  END ;Subroutine
  DECLARE tracking_orders = i2 WITH public ,constant (him_tracking_orders (null ) )
  IF ((validate (i18nuar_def ,999 ) = 999 ) )
   CALL echo ("Declaring i18nuar_def" )
   DECLARE i18nuar_def = i2 WITH persist
   SET i18nuar_def = 1
   DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
   persist
   DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
   DECLARE uar_i18nbuildmessage () = vc WITH persist
   DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
    sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
   "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
   DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
     ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
     ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
   "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
   persist
   DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
   image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
  ENDIF
  DECLARE ihandle = i4 WITH private ,noconstant (0 )
  SET stat = uar_i18nlocalizationinit (ihandle ,curprog ,"" ,curcclrev )
  DECLARE i18npending = vc WITH public ,constant (uar_i18ngetmessage (ihandle ,"Pending" ,"Pending"
    ) )
 ENDIF
 SET gl_org_cnt = size (organizations->qual ,5 )
 SET gl_phys_cnt = size (physicians->qual ,5 )
 IF ((him_pending_signs_ind = 0 ) )
  SET pend_age_ind = 0
 ENDIF
 IF ((gl_phys_cnt = 0 ) )
  SET dummyt_count = 1
  SET gc_physician_parser = " "
 ELSE
  SET dummyt_count = gl_phys_cnt
  SET gc_physician_parser = "hea.prsnl_id = physicians->qual[d.seq].item_id and "
 ENDIF
 SET gc_physician_parser = concat (gc_physician_parser ,
  " hea.completed_dt_tm = cnvtdatetime(gc_dec_31st_2100) " ," and hea.request_dt_tm != null" ,
  " and hea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)" ,
  " and hea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)" ," and hea.active_ind = 1" )
 SET doc_age_request->visit_hold_ind = him_visit_hold_ind
 SET doc_age_request->phys_hold_ind = him_phys_hold_ind
 SELECT INTO "nl:"
  doc_name = substring (1 ,100 ,uar_get_code_display (hea.event_cd ) ) ,
  physician_active_ind = physician.active_ind ,
  physician_active_status_cd = physician.active_status_cd ,
  physician_active_status_dt_tm = physician.active_status_dt_tm ,
  physician_active_status_prsnl_id = physician.active_status_prsnl_id ,
  physician_beg_effective_dt_tm = physician.beg_effective_dt_tm ,
  physician_contributor_system_cd = physician.contributor_system_cd ,
  physician_create_dt_tm = physician.create_dt_tm ,
  physician_create_prsnl_id = physician.create_prsnl_id ,
  physician_data_status_cd = physician.data_status_cd ,
  physician_data_status_dt_tm = physician.data_status_dt_tm ,
  physician_data_status_prsnl_id = physician.data_status_prsnl_id ,
  physician_email = substring (1 ,100 ,physician.email ) ,
  physician_end_effective_dt_tm = physician.end_effective_dt_tm ,
  physician_ft_entity_id = physician.ft_entity_id ,
  physician_ft_entity_name = substring (1 ,32 ,physician.ft_entity_name ) ,
  physician_name_first = substring (1 ,200 ,physician.name_first ) ,
  physician_name_first_key = substring (1 ,100 ,physician.name_first_key ) ,
  physician_name_first_key_nls = substring (1 ,202 ,physician.name_first_key_nls ) ,
  physician_name_full_formatted = substring (1 ,100 ,physician.name_full_formatted ) ,
  physician_name_last = substring (1 ,200 ,physician.name_last ) ,
  physician_name_last_key = substring (1 ,100 ,physician.name_last_key ) ,
  physician_name_last_key_nls = substring (1 ,202 ,physician.name_last_key_nls ) ,
  physician_password = substring (1 ,100 ,physician.password ) ,
  physician_person_id = physician.person_id ,
  physician_physician_ind = physician.physician_ind ,
  physician_physician_status_cd = physician.physician_status_cd ,
  physician_position_cd = physician.position_cd ,
  physician_prim_assign_loc_cd = physician.prim_assign_loc_cd ,
  physician_prsnl_type_cd = physician.prsnl_type_cd ,
  physician_updt_dt_tm = physician.updt_dt_tm ,
  physician_updt_id = physician.updt_id ,
  physician_updt_task = physician.updt_task ,
  physician_username = substring (1 ,50 ,physician.username )
  FROM (dummyt d WITH seq = dummyt_count ),
   (him_event_allocation hea ),
   (prsnl physician ),
   (encounter e )
  PLAN (d )
   JOIN (hea
   WHERE parser (gc_physician_parser ) )
   JOIN (physician
   WHERE (physician.person_id = hea.prsnl_id ) )
   JOIN (e
   WHERE (e.encntr_id = hea.encntr_id )
   AND (((i1multifacilitylogicind = 0 ) ) OR (expand (gn_index ,1 ,gl_org_cnt ,e.organization_id ,
    organizations->qual[gn_index ].item_id ) ))
   AND (e.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) ) )
  ORDER BY e.organization_id ,
   hea.prsnl_id ,
   e.encntr_id ,
   hea.event_id
  HEAD e.organization_id
   row + 0
  HEAD hea.prsnl_id
   IF ((him_doc_aging_ind = 1 ) ) gl_phys_qual_cnt = (gl_phys_qual_cnt + 1 ) ,
    IF ((gl_phys_qual_cnt > size (doc_age_request->phys_qual ,5 ) ) ) stat = alterlist (
      doc_age_request->phys_qual ,(gl_phys_qual_cnt + 9 ) )
    ENDIF
    ,doc_age_request->phys_qual[gl_phys_qual_cnt ].physstart_pos = d.seq ,doc_age_request->phys_qual[
    gl_phys_qual_cnt ].physician_id = hea.prsnl_id ,doc_age_request->phys_qual[gl_phys_qual_cnt ].
    organization_id = e.organization_id
   ENDIF
   ,gl_encntr_cnt = 0
  HEAD e.encntr_id
   i4defqualcnt = 0 ,i4qualcount = (i4qualcount + 1 ) ,
   IF ((i4qualcount > size (data->qual ,5 ) ) ) stat = alterlist (data->qual ,(i4qualcount + 9 ) )
   ENDIF
   ,data->qual[i4qualcount ].encntr_id = e.encntr_id ,data->qual[i4qualcount ].disch_dt_tm = e
   .disch_dt_tm ,data->qual[i4qualcount ].patient_type_cd = e.encntr_type_cd ,data->qual[i4qualcount
   ].physician_id = physician.person_id ,data->qual[i4qualcount ].physician_name =
   physician_name_full_formatted ,data->qual[i4qualcount ].physician_active_ind =
   physician_active_ind ,data->qual[i4qualcount ].physician_active_status_cd =
   physician_active_status_cd ,data->qual[i4qualcount ].physician_active_status_dt_tm =
   physician_active_status_dt_tm ,data->qual[i4qualcount ].physician_active_status_prsnl_id =
   physician_active_status_prsnl_id ,data->qual[i4qualcount ].physician_beg_effective_dt_tm =
   physician_beg_effective_dt_tm ,data->qual[i4qualcount ].physician_contributor_system_cd =
   physician_contributor_system_cd ,data->qual[i4qualcount ].physician_create_dt_tm =
   physician_create_dt_tm ,data->qual[i4qualcount ].physician_create_prsnl_id =
   physician_create_prsnl_id ,data->qual[i4qualcount ].physician_data_status_cd =
   physician_data_status_cd ,data->qual[i4qualcount ].physician_data_status_dt_tm =
   physician_data_status_dt_tm ,data->qual[i4qualcount ].physician_data_status_prsnl_id =
   physician_data_status_prsnl_id ,data->qual[i4qualcount ].physician_email = physician_email ,data->
   qual[i4qualcount ].physician_end_effective_dt_tm = physician_end_effective_dt_tm ,data->qual[
   i4qualcount ].physician_ft_entity_id = physician_ft_entity_id ,data->qual[i4qualcount ].
   physician_ft_entity_name = physician_ft_entity_name ,data->qual[i4qualcount ].physician_name_first
    = physician_name_first ,data->qual[i4qualcount ].physician_name_first_key =
   physician_name_first_key ,data->qual[i4qualcount ].physician_name_first_key_nls =
   physician_name_first_key_nls ,data->qual[i4qualcount ].physician_name_full_formatted =
   physician_name_full_formatted ,data->qual[i4qualcount ].physician_name_last = physician_name_last
   ,data->qual[i4qualcount ].physician_name_last_key = physician_name_last_key ,data->qual[
   i4qualcount ].physician_name_last_key_nls = physician_name_last_key_nls ,data->qual[i4qualcount ].
   physician_password = physician_password ,data->qual[i4qualcount ].physician_person_id =
   physician_person_id ,data->qual[i4qualcount ].physician_physician_ind = physician_physician_ind ,
   data->qual[i4qualcount ].physician_physician_status_cd = physician_physician_status_cd ,data->
   qual[i4qualcount ].physician_position_cd = physician_position_cd ,data->qual[i4qualcount ].
   physician_prim_assign_loc_cd = physician_prim_assign_loc_cd ,data->qual[i4qualcount ].
   physician_prsnl_type_cd = physician_prsnl_type_cd ,data->qual[i4qualcount ].physician_updt_dt_tm
   = physician_updt_dt_tm ,data->qual[i4qualcount ].physician_updt_id = physician_updt_id ,data->
   qual[i4qualcount ].physician_updt_task = physician_updt_task ,data->qual[i4qualcount ].
   physician_username = physician_username ,
   IF ((him_doc_aging_ind = 1 ) ) gl_encntr_cnt = (gl_encntr_cnt + 1 ) ,
    IF ((gl_encntr_cnt > size (doc_age_request->phys_qual[gl_phys_qual_cnt ].encntr_qual ,5 ) ) )
     stat = alterlist (doc_age_request->phys_qual[gl_phys_qual_cnt ].encntr_qual ,(gl_encntr_cnt + 9
      ) )
    ENDIF
    ,doc_age_request->phys_qual[gl_phys_qual_cnt ].encntr_qual[gl_encntr_cnt ].encntr_id = e
    .encntr_id ,doc_age_request->phys_qual[gl_phys_qual_cnt ].encntr_qual[gl_encntr_cnt ].
    organization_id = e.organization_id ,doc_age_request->phys_qual[gl_phys_qual_cnt ].encntr_qual[
    gl_encntr_cnt ].encstart_pos = gl_encntr_cnt
   ENDIF
   ,gl_event_cnt = 0
  FOOT  hea.event_id
   i4defqualcnt = (i4defqualcnt + 1 ) ,
   IF ((i4defqualcnt > size (data->qual[i4qualcount ].defic_qual ,5 ) ) ) stat = alterlist (data->
     qual[i4qualcount ].defic_qual ,(i4defqualcnt + 9 ) )
   ENDIF
   ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].deficiency_name = doc_name ,data->qual[
   i4qualcount ].defic_qual[i4defqualcnt ].deficiency_flag = 1 ,data->qual[i4qualcount ].defic_qual[
   i4defqualcnt ].event_id = hea.event_id ,
   CASE (hea.action_type_cd )
    OF perform_cd :
     data->qual[i4qualcount ].defic_qual[i4defqualcnt ].status = uar_get_code_display (req_dict_cd )
    OF modify_cd :
     data->qual[i4qualcount ].defic_qual[i4defqualcnt ].status = uar_get_code_display (req_mod_cd )
    OF sign_cd :
     IF ((hea.action_status_cd = pending_cd ) ) data->qual[i4qualcount ].defic_qual[i4defqualcnt ].
      status = uar_get_code_display (pend_sign_cd )
     ELSE data->qual[i4qualcount ].defic_qual[i4defqualcnt ].status = uar_get_code_display (
       req_sign_cd )
     ENDIF
   ENDCASE
  FOOT  e.encntr_id
   stat = alterlist (data->qual[i4qualcount ].defic_qual ,i4defqualcnt ) ,
   IF ((i4defqualcnt > data->max_defic_qual_count ) ) data->max_defic_qual_count = i4defqualcnt
   ENDIF
   ,
   IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (doc_age_request->phys_qual[gl_phys_qual_cnt ].
     encntr_qual[gl_encntr_cnt ].event_qual ,gl_event_qual_cnt )
   ENDIF
  FOOT  hea.prsnl_id
   IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (doc_age_request->phys_qual[gl_phys_qual_cnt ].
     encntr_qual ,gl_encntr_cnt )
   ENDIF
  FOOT REPORT
   stat = alterlist (data->qual ,i4qualcount ) ,
   IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (doc_age_request->phys_qual ,gl_phys_qual_cnt )
   ENDIF
  WITH nocounter
 ;end select
 SET i4qualcount = 0
 SET gl_phys_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = dummyt_count ),
   (him_event_allocation hea ),
   (prsnl physician ),
   (encounter e ),
   (him_alloc_storage has ),
   (him_event_extension hee )
  PLAN (d )
   JOIN (hea
   WHERE parser (gc_physician_parser ) )
   JOIN (physician
   WHERE (physician.person_id = hea.prsnl_id ) )
   JOIN (e
   WHERE (e.encntr_id = hea.encntr_id )
   AND (((i1multifacilitylogicind = 0 ) ) OR (expand (gn_index ,1 ,gl_org_cnt ,e.organization_id ,
    organizations->qual[gn_index ].item_id ) ))
   AND (e.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) ) )
   JOIN (hee
   WHERE (hee.event_cd = hea.event_cd )
   AND (hee.active_ind = 1 )
   AND ((((hee.organization_id + 0 ) = e.organization_id ) ) OR (((hee.organization_id + 0 ) = 0 )
   AND NOT (EXISTS (
   (SELECT
    oe.organization_id
    FROM (org_event_set_reltn oe )
    WHERE (oe.organization_id = e.organization_id )
    AND (oe.active_ind = 1 ) ) ) ) )) )
   JOIN (has
   WHERE (has.event_id = outerjoin (hea.event_id ) )
   AND (has.active_ind = outerjoin (1 ) )
   AND (has.prsnl_id = outerjoin (hea.prsnl_id ) ) )
  ORDER BY e.organization_id ,
   hea.prsnl_id ,
   e.encntr_id ,
   hea.event_id
  HEAD e.organization_id
   row + 0
  HEAD hea.prsnl_id
   gl_phys_cnt = (gl_phys_cnt + 1 ) ,gl_encntr_cnt = 0
  HEAD e.encntr_id
   gl_encntr_cnt = (gl_encntr_cnt + 1 ) ,gl_event_cnt = 0 ,i4defqualcnt = 0 ,i4qualcount = (
   i4qualcount + 1 )
  HEAD hea.event_id
   temp_trans_start_time = cnvtdatetime ("" ) ,temp_trans_end_time = cnvtdatetime ("" ) ,
   temp_alloc_dt_tm = cnvtdatetime ("" ) ,temp_status_cd = 0 ,temp_type_cd = 0
  DETAIL
   IF ((him_doc_aging_ind = 1 ) )
    IF ((((pend_age_ind = 1 ) ) OR ((hea.action_status_cd != pending_cd ) )) ) temp_status_cd = hea
     .action_status_cd ,temp_type_cd = hea.action_type_cd ,
     IF ((hea.event_id > 0 ) )
      IF ((hea.action_type_cd = perform_cd ) ) temp_trans_start_time = hea.completed_dt_tm ,
       temp_trans_end_time = datetimeadd (cnvtdatetime (curdate ,0 ) ,1 )
      ENDIF
     ENDIF
     ,
     IF ((hea.action_type_cd = sign_cd )
     AND (hea.action_status_cd = requested_cd ) ) temp_trans_end_time = hea.request_dt_tm
     ENDIF
     ,
     IF ((has.event_id > 0 ) ) temp_alloc_dt_tm = has.allocation_dt_tm
     ELSE
      IF ((hea.request_dt_tm > temp_alloc_dt_tm ) ) temp_alloc_dt_tm = hea.request_dt_tm
      ENDIF
      ,
      IF ((hea.event_id > 0 ) )
       IF ((hea.request_dt_tm != null ) ) temp_alloc_dt_tm = hea.request_dt_tm
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  hea.event_id
   i4defqualcnt = (i4defqualcnt + 1 ) ,
   IF ((i4defqualcnt > size (data->qual[i4qualcount ].defic_qual ,5 ) ) ) stat = alterlist (data->
     qual[i4qualcount ].defic_qual ,(i4defqualcnt + 9 ) )
   ENDIF
   ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].alloc_dt_tm = temp_alloc_dt_tm ,stat =
   alterlist (data->qual[i4qualcount ].defic_qual[i4defqualcnt ].doc_qual ,1 ) ,data->qual[
   i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[1 ].him_event_action_type_cd = hea
   .action_type_cd ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[1 ].
   him_event_allocation_dt_tm = hea.allocation_dt_tm ,data->qual[i4qualcount ].defic_qual[
   i4defqualcnt ].doc_qual[1 ].him_event_beg_effective_dt_tm = hea.beg_effective_dt_tm ,data->qual[
   i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[1 ].him_event_completed_dt_tm = hea
   .completed_dt_tm ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[1 ].
   him_event_encntr_id = hea.encntr_id ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[
   1 ].him_event_end_effective_dt_tm = hea.end_effective_dt_tm ,data->qual[i4qualcount ].defic_qual[
   i4defqualcnt ].doc_qual[1 ].him_event_event_cd = hea.event_cd ,data->qual[i4qualcount ].
   defic_qual[i4defqualcnt ].doc_qual[1 ].him_event_event_id = hea.event_id ,data->qual[i4qualcount ]
   .defic_qual[i4defqualcnt ].doc_qual[1 ].him_event_him_event_allocation_id = hea
   .him_event_allocation_id ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[1 ].
   him_event_prsnl_id = hea.prsnl_id ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].doc_qual[1 ]
   .him_event_request_dt_tm = hea.request_dt_tm ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].
   doc_qual[1 ].him_event_updt_dt_tm = hea.updt_dt_tm ,data->qual[i4qualcount ].defic_qual[
   i4defqualcnt ].doc_qual[1 ].him_event_updt_id = hea.updt_id ,
   IF ((him_doc_aging_ind = 1 ) )
    IF ((temp_alloc_dt_tm > 0 ) ) gl_event_cnt = (gl_event_cnt + 1 ) ,
     IF ((gl_event_cnt > size (doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].
      event_qual ,5 ) ) ) stat = alterlist (doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[
       gl_encntr_cnt ].event_qual ,(gl_event_cnt + 9 ) )
     ENDIF
     ,doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].
     evnstart_pos = gl_event_cnt ,doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt
     ].event_qual[gl_event_cnt ].action_type_cd = temp_type_cd ,doc_age_request->phys_qual[
     gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].action_status_cd =
     temp_status_cd ,doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[
     gl_event_cnt ].alloc_dt_tm = temp_alloc_dt_tm ,doc_age_request->phys_qual[gl_phys_cnt ].
     encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].t_start_dt_tm = temp_trans_start_time ,
     doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].
     t_end_dt_tm = temp_trans_end_time ,doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[
     gl_encntr_cnt ].event_qual[gl_event_cnt ].event_id = hea.event_id ,doc_age_request->phys_qual[
     gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].event_cd = hea.event_cd ,
     doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].
     trans_ind = hee.tran_time_ind ,doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[
     gl_encntr_cnt ].event_qual[gl_event_cnt ].trans_ind = hee.tran_time_ind ,doc_age_request->
     phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].d_sign_hours = hee
     .dictation_turnaround_time ,doc_age_request->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ]
     .event_qual[gl_event_cnt ].s_dict_hours = hee.signature_delinquency_time
    ENDIF
   ENDIF
  FOOT  e.encntr_id
   stat = alterlist (data->qual[i4qualcount ].defic_qual ,i4defqualcnt ) ,
   IF ((i4defqualcnt > data->max_defic_qual_count ) ) data->max_defic_qual_count = i4defqualcnt
   ENDIF
   ,
   IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (doc_age_request->phys_qual[gl_phys_cnt ].
     encntr_qual[gl_encntr_cnt ].event_qual ,gl_event_cnt )
   ENDIF
  FOOT  hea.prsnl_id
   IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (doc_age_request->phys_qual[gl_phys_cnt ].
     encntr_qual ,gl_encntr_cnt )
   ENDIF
  FOOT REPORT
   stat = alterlist (data->qual ,i4qualcount ) ,
   IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (doc_age_request->phys_qual ,gl_phys_cnt )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1 WITH seq = value (size (doc_age_request->phys_qual ,5 ) ) ),
   (dummyt d2 WITH seq = 1 ),
   (dummyt d3 WITH seq = 1 ),
   (him_event_allocation hea )
  PLAN (d1
   WHERE maxrec (d2 ,size (doc_age_request->phys_qual[d1.seq ].encntr_qual ,5 ) ) )
   JOIN (d2
   WHERE maxrec (d3 ,size (doc_age_request->phys_qual[d1.seq ].encntr_qual[d2.seq ].event_qual ,5 )
    ) )
   JOIN (d3
   WHERE (doc_age_request->phys_qual[d1.seq ].encntr_qual[d2.seq ].event_qual[d3.seq ].event_id > 0
   ) )
   JOIN (hea
   WHERE (hea.event_id = doc_age_request->phys_qual[d1.seq ].encntr_qual[d2.seq ].event_qual[d3.seq ]
   .event_id )
   AND (hea.prsnl_id = doc_age_request->phys_qual[d1.seq ].physician_id )
   AND ((hea.action_type_cd + 0 ) = perform_cd )
   AND (hea.completed_dt_tm != cnvtdatetime (gc_dec_31st_2100 ) ) )
  HEAD hea.encntr_id
   doc_age_request->phys_qual[d1.seq ].encntr_qual[d2.seq ].event_qual[d3.seq ].request_dt_tm = hea
   .request_dt_tm ,doc_age_request->phys_qual[d1.seq ].encntr_qual[d2.seq ].event_qual[d3.seq ].
   completed_dt_tm = hea.completed_dt_tm
  WITH nocounter
 ;end select
 SET gl_data_cnt = size (data->qual ,5 )
 IF ((him_doc_aging_ind = 1 ) )
  EXECUTE him_get_doc_age WITH replace ("AGE_REQUEST" ,"DOC_AGE_REQUEST" ) ,
  replace ("AGE_REPLY" ,"DOC_AGE_REPLY" )
  SET gl_data_cnt = size (data->qual ,5 )
  FOR (gl_phys_cnt = 1 TO size (doc_age_reply->phys_qual ,5 ) )
   FOR (gl_encntr_cnt = 1 TO size (doc_age_reply->phys_qual[gl_phys_cnt ].encntr_qual ,5 ) )
    SET gl_encntr_pos = locateval (gn_index ,1 ,gl_data_cnt ,doc_age_reply->phys_qual[gl_phys_cnt ].
     physician_id ,data->qual[gn_index ].physician_id ,doc_age_reply->phys_qual[gl_phys_cnt ].
     encntr_qual[gl_encntr_cnt ].encntr_id ,data->qual[gn_index ].encntr_id )
    FOR (gl_event_cnt = 1 TO size (doc_age_reply->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ]
     .event_qual ,5 ) )
     SET gl_defic_pos = locateval (gn_index ,1 ,size (data->qual[gl_encntr_pos ].defic_qual ,5 ) ,
      doc_age_reply->phys_qual[gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].
      event_id ,data->qual[gl_encntr_pos ].defic_qual[gn_index ].event_id )
     SET data->qual[gl_encntr_pos ].defic_qual[gl_defic_pos ].defic_age = doc_age_reply->phys_qual[
     gl_phys_cnt ].encntr_qual[gl_encntr_cnt ].event_qual[gl_event_cnt ].document_age
    ENDFOR
   ENDFOR
  ENDFOR
 ENDIF
 SET phys_cnt = size (physicians->qual ,5 )
 IF ((phys_cnt = 0 ) )
  SET dummyt_count = 1
  SET gc_physician_parser = " "
 ELSE
  SET dummyt_count = phys_cnt
  SET gc_physician_parser = "o_n.to_prsnl_id = physicians->qual[d.seq].item_id and "
 ENDIF
 SET gc_physician_parser = concat (gc_physician_parser ,
  " o_n.notification_status_flag = NOTIF_STS_FLAG_PENDING" ,
  " and o_n.notification_type_flag = NOTIF_TYPE_FLAG_COSIGN" )
 IF ((him_tracking_orders_ind = 1 ) )
  IF ((him_doc_aging_ind = 1 ) )
   SET order_struct->visit_hold_ind = him_visit_hold_ind
   SET order_struct->phys_hold_ind = him_phys_hold_ind
   SET order_struct->d_sign_hours = him_order_delinq_hrs
   SET order_struct->s_sign_hours = him_order_susp_hrs
  ENDIF
  SELECT INTO "nl:"
   physician_active_ind = physician.active_ind ,
   physician_active_status_cd = physician.active_status_cd ,
   physician_active_status_dt_tm = physician.active_status_dt_tm ,
   physician_active_status_prsnl_id = physician.active_status_prsnl_id ,
   physician_beg_effective_dt_tm = physician.beg_effective_dt_tm ,
   physician_contributor_system_cd = physician.contributor_system_cd ,
   physician_create_dt_tm = physician.create_dt_tm ,
   physician_create_prsnl_id = physician.create_prsnl_id ,
   physician_data_status_cd = physician.data_status_cd ,
   physician_data_status_dt_tm = physician.data_status_dt_tm ,
   physician_data_status_prsnl_id = physician.data_status_prsnl_id ,
   physician_email = substring (1 ,100 ,physician.email ) ,
   physician_end_effective_dt_tm = physician.end_effective_dt_tm ,
   physician_ft_entity_id = physician.ft_entity_id ,
   physician_ft_entity_name = substring (1 ,32 ,physician.ft_entity_name ) ,
   physician_name_first = substring (1 ,200 ,physician.name_first ) ,
   physician_name_first_key = substring (1 ,100 ,physician.name_first_key ) ,
   physician_name_first_key_nls = substring (1 ,202 ,physician.name_first_key_nls ) ,
   physician_name_full_formatted = substring (1 ,100 ,physician.name_full_formatted ) ,
   physician_name_last = substring (1 ,200 ,physician.name_last ) ,
   physician_name_last_key = substring (1 ,100 ,physician.name_last_key ) ,
   physician_name_last_key_nls = substring (1 ,202 ,physician.name_last_key_nls ) ,
   physician_password = substring (1 ,100 ,physician.password ) ,
   physician_person_id = physician.person_id ,
   physician_physician_ind = physician.physician_ind ,
   physician_physician_status_cd = physician.physician_status_cd ,
   physician_position_cd = physician.position_cd ,
   physician_prim_assign_loc_cd = physician.prim_assign_loc_cd ,
   physician_prsnl_type_cd = physician.prsnl_type_cd ,
   physician_updt_dt_tm = physician.updt_dt_tm ,
   physician_updt_id = physician.updt_id ,
   physician_updt_task = physician.updt_task ,
   physician_username = substring (1 ,50 ,physician.username )
   FROM (dummyt d WITH seq = dummyt_count ),
    (order_notification o_n ),
    (order_review o_r ),
    (orders ord ),
    (encounter e ),
    (prsnl physician ),
    (him_alloc_storage has )
   PLAN (d )
    JOIN (o_n
    WHERE parser (gc_physician_parser )
    AND (o_n.to_prsnl_id > 0.0 ) )
    JOIN (o_r
    WHERE (o_r.order_id = o_n.order_id )
    AND (o_r.action_sequence = o_n.action_sequence )
    AND ((o_r.review_type_flag + 0 ) = review_type_flag_doctor )
    AND ((o_r.reviewed_status_flag + 0 ) = review_sts_flag_noreview ) )
    JOIN (ord
    WHERE (ord.order_id = o_r.order_id )
    AND ((((ord.template_order_flag + 0 ) = template_flag_none ) ) OR (((ord.template_order_flag + 0
    ) = template_flag_template ) ))
    AND (ord.need_doctor_cosign_ind > 0 ) )
    JOIN (e
    WHERE (e.encntr_id = ord.encntr_id )
    AND (((i1multifacilitylogicind = 0 ) ) OR (expand (iloop ,1 ,gl_org_cnt ,(e.organization_id + 0
     ) ,organizations->qual[iloop ].item_id ) ))
    AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.active_ind = 1 ) )
    JOIN (physician
    WHERE (physician.person_id = o_n.to_prsnl_id ) )
    JOIN (has
    WHERE (has.order_id = outerjoin (o_n.order_id ) )
    AND (has.action_sequence = outerjoin (o_n.action_sequence ) )
    AND (has.active_ind = outerjoin (1 ) )
    AND (has.prsnl_id = outerjoin (o_n.to_prsnl_id ) ) )
   ORDER BY e.organization_id ,
    o_n.to_prsnl_id ,
    e.encntr_id
   HEAD REPORT
    visitcnt = size (visit_age_request->total_qual ,5 ) ,
    gl_data_cnt = size (data->qual ,5 ) ,
    rec_num = 0
   HEAD e.organization_id
    row + 0
   HEAD o_n.to_prsnl_id
    IF ((him_doc_aging_ind = 1 ) ) rec_num = (rec_num + 1 ) ,
     IF ((rec_num > size (order_struct->phys_qual ,5 ) ) ) stat = alterlist (order_struct->phys_qual
       ,(rec_num + 9 ) )
     ENDIF
     ,order_struct->phys_qual[rec_num ].physstart_pos = d.seq ,order_struct->phys_qual[rec_num ].
     physician_id = o_n.to_prsnl_id ,order_struct->phys_qual[rec_num ].organization_id = e
     .organization_id
    ENDIF
    ,encntr_cnt = 0
   HEAD e.encntr_id
    encntr_pos = locateval (iloop ,1 ,gl_data_cnt ,e.encntr_id ,data->qual[iloop ].encntr_id ,o_n
     .to_prsnl_id ,data->qual[iloop ].physician_id ) ,
    IF ((encntr_pos <= 0 ) ) gl_data_cnt = (gl_data_cnt + 1 ) ,
     IF ((gl_data_cnt > size (data->qual ,5 ) ) ) stat = alterlist (data->qual ,(gl_data_cnt + 9 ) )
     ENDIF
     ,i4qualcount = gl_data_cnt ,data->qual[i4qualcount ].patient_type_cd = e.encntr_id ,data->qual[
     i4qualcount ].physician_name = physician_name_full_formatted ,data->qual[i4qualcount ].
     physician_id = physician.person_id ,data->qual[i4qualcount ].encntr_id = e.encntr_id ,data->
     qual[i4qualcount ].disch_dt_tm = e.disch_dt_tm ,data->qual[i4qualcount ].physician_active_ind =
     physician_active_ind ,data->qual[i4qualcount ].physician_active_status_cd =
     physician_active_status_cd ,data->qual[i4qualcount ].physician_active_status_dt_tm =
     physician_active_status_dt_tm ,data->qual[i4qualcount ].physician_active_status_prsnl_id =
     physician_active_status_prsnl_id ,data->qual[i4qualcount ].physician_beg_effective_dt_tm =
     physician_beg_effective_dt_tm ,data->qual[i4qualcount ].physician_contributor_system_cd =
     physician_contributor_system_cd ,data->qual[i4qualcount ].physician_create_dt_tm =
     physician_create_dt_tm ,data->qual[i4qualcount ].physician_create_prsnl_id =
     physician_create_prsnl_id ,data->qual[i4qualcount ].physician_data_status_cd =
     physician_data_status_cd ,data->qual[i4qualcount ].physician_data_status_dt_tm =
     physician_data_status_dt_tm ,data->qual[i4qualcount ].physician_data_status_prsnl_id =
     physician_data_status_prsnl_id ,data->qual[i4qualcount ].physician_email = physician_email ,data
     ->qual[i4qualcount ].physician_end_effective_dt_tm = physician_end_effective_dt_tm ,data->qual[
     i4qualcount ].physician_ft_entity_id = physician_ft_entity_id ,data->qual[i4qualcount ].
     physician_ft_entity_name = physician_ft_entity_name ,data->qual[i4qualcount ].
     physician_name_first = physician_name_first ,data->qual[i4qualcount ].physician_name_first_key
     = physician_name_first_key ,data->qual[i4qualcount ].physician_name_first_key_nls =
     physician_name_first_key_nls ,data->qual[i4qualcount ].physician_name_full_formatted =
     physician_name_full_formatted ,data->qual[i4qualcount ].physician_name_last =
     physician_name_last ,data->qual[i4qualcount ].physician_name_last_key = physician_name_last_key
    ,data->qual[i4qualcount ].physician_name_last_key_nls = physician_name_last_key_nls ,data->qual[
     i4qualcount ].physician_password = physician_password ,data->qual[i4qualcount ].
     physician_person_id = physician_person_id ,data->qual[i4qualcount ].physician_physician_ind =
     physician_physician_ind ,data->qual[i4qualcount ].physician_physician_status_cd =
     physician_physician_status_cd ,data->qual[i4qualcount ].physician_position_cd =
     physician_position_cd ,data->qual[i4qualcount ].physician_prim_assign_loc_cd =
     physician_prim_assign_loc_cd ,data->qual[i4qualcount ].physician_prsnl_type_cd =
     physician_prsnl_type_cd ,data->qual[i4qualcount ].physician_updt_dt_tm = physician_updt_dt_tm ,
     data->qual[i4qualcount ].physician_updt_id = physician_updt_id ,data->qual[i4qualcount ].
     physician_updt_task = physician_updt_task ,data->qual[i4qualcount ].physician_username =
     physician_username
    ELSE i4qualcount = encntr_pos
    ENDIF
    ,
    IF ((him_doc_aging_ind = 1 ) ) encntr_cnt = (encntr_cnt + 1 ) ,
     IF ((encntr_cnt > size (order_struct->phys_qual[rec_num ].encntr_qual ,5 ) ) ) stat = alterlist
      (order_struct->phys_qual[rec_num ].encntr_qual ,(encntr_cnt + 9 ) )
     ENDIF
     ,order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].encntr_id = e.encntr_id ,
     order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].organization_id = e.organization_id ,
     order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].encstart_pos = encntr_cnt ,
     gl_ord_age_cnt = 0
    ENDIF
    ,i4defqualcnt = size (data->qual[i4qualcount ].defic_qual ,5 )
   DETAIL
    i4defqualcnt = (i4defqualcnt + 1 ) ,
    IF ((i4defqualcnt > size (data->qual[i4qualcount ].defic_qual ,5 ) ) ) stat = alterlist (data->
      qual[i4qualcount ].defic_qual ,(i4defqualcnt + 9 ) )
    ENDIF
    ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].deficiency_name = ord.hna_order_mnemonic ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_id = ord.order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].action_sequence = o_r.action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].deficiency_flag = 2 ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].status = i18npending ,
    stat = alterlist (data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual ,1 ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_action_sequence =
    o_n.action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_caused_by_flag =
    o_n.caused_by_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_from_prsnl_id = o_n
    .from_prsnl_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_notif_notification_comment = substring (1 ,255 ,o_n.notification_comment ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_notification_dt_tm
    = o_n.notification_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_notif_notification_reason_cd = o_n.notification_reason_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_notif_notification_status_flag = o_n.notification_status_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_notif_notification_type_flag = o_n.notification_type_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_notification_tz =
    o_n.notification_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_order_id = o_n
    .order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_notif_order_notification_id = o_n.order_notification_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_notif_parent_order_notification_id = o_n.parent_order_notification_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_status_change_dt_tm
     = o_n.status_change_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_status_change_tz =
    o_n.status_change_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_to_prsnl_id = o_n
    .to_prsnl_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_updt_dt_tm = o_n
    .updt_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_updt_id = o_n
    .updt_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_notif_updt_task = o_n
    .updt_task ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_action_sequence =
    o_r.action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_dept_cd = o_r
    .dept_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_review_digital_signature_ident = substring (1 ,64 ,o_r.digital_signature_ident ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_location_cd = o_r
    .location_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_order_id = o_r
    .order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_provider_id = o_r
    .provider_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_proxy_personnel_id
     = o_r.proxy_personnel_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_proxy_reason_cd =
    o_r.proxy_reason_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_reject_reason_cd
    = o_r.reject_reason_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_review_reviewed_status_flag = o_r.reviewed_status_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_review_dt_tm = o_r
    .review_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    order_review_review_personnel_id = o_r.review_personnel_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_review_reqd_ind =
    o_r.review_reqd_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_review_sequence =
    o_r.review_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_review_type_flag
    = o_r.review_type_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_review_tz = o_r
    .review_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_updt_dt_tm = o_r
    .updt_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_updt_id = o_r
    .updt_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].order_review_updt_task = o_r
    .updt_task ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_active_ind = ord
    .active_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_active_status_cd = ord
    .active_status_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_active_status_dt_tm =
    ord.active_status_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_active_status_prsnl_id
    = ord.active_status_prsnl_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_activity_type_cd = ord
    .activity_type_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_ad_hoc_order_flag = ord
    .ad_hoc_order_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_catalog_cd = ord
    .catalog_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_catalog_type_cd = ord
    .catalog_type_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_cki = substring (1 ,255
     ,ord.cki ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_clinical_display_line =
    substring (1 ,255 ,ord.clinical_display_line ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_comment_type_mask = ord
    .comment_type_mask ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_constant_ind = ord
    .constant_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_contributor_system_cd =
    ord.contributor_system_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_cs_flag = ord.cs_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_cs_order_id = ord
    .cs_order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_current_start_dt_tm =
    ord.current_start_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_current_start_tz = ord
    .current_start_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_dcp_clin_cat_cd = ord
    .dcp_clin_cat_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_dept_misc_line =
    substring (1 ,255 ,ord.dept_misc_line ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_dept_status_cd = ord
    .dept_status_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    orders_discontinue_effective_dt_tm = ord.discontinue_effective_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_discontinue_effective_tz
     = ord.discontinue_effective_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_discontinue_ind = ord
    .discontinue_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_discontinue_type_cd =
    ord.discontinue_type_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_encntr_financial_id =
    ord.encntr_financial_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_encntr_id = ord
    .encntr_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_eso_new_order_ind = ord
    .eso_new_order_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_frequency_id = ord
    .frequency_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_freq_type_flag = ord
    .freq_type_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_group_order_flag = ord
    .group_order_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_group_order_id = ord
    .group_order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_hide_flag = ord
    .hide_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_hna_order_mnemonic =
    substring (1 ,100 ,ord.hna_order_mnemonic ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_incomplete_order_ind =
    ord.incomplete_order_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_ingredient_ind = ord
    .ingredient_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_interest_dt_tm = ord
    .interest_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_interval_ind = ord
    .interval_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_iv_ind = ord.iv_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_last_action_sequence =
    ord.last_action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    orders_last_core_action_sequence = ord.last_core_action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    orders_last_ingred_action_sequence = ord.last_ingred_action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_last_update_provider_id
    = ord.last_update_provider_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_link_nbr = ord.link_nbr
    ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_link_order_flag = ord
    .link_order_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_link_order_id = ord
    .link_order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_link_type_flag = ord
    .link_type_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_med_order_type_cd = ord
    .med_order_type_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_modified_start_dt_tm =
    ord.modified_start_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_need_doctor_cosign_ind
    = ord.need_doctor_cosign_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_need_nurse_review_ind =
    ord.need_nurse_review_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    orders_need_physician_validate_ind = ord.need_physician_validate_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_need_rx_verify_ind = ord
    .need_rx_verify_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_oe_format_id = ord
    .oe_format_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_orderable_type_flag =
    ord.orderable_type_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_ordered_as_mnemonic =
    substring (1 ,100 ,ord.ordered_as_mnemonic ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_order_comment_ind = ord
    .order_comment_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    orders_order_detail_display_line = substring (1 ,255 ,ord.order_detail_display_line ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_order_id = ord.order_id
    ,data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_order_mnemonic =
    substring (1 ,100 ,ord.order_mnemonic ) ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_order_status_cd = ord
    .order_status_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_orig_order_convs_seq =
    ord.orig_order_convs_seq ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_orig_order_dt_tm = ord
    .orig_order_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_orig_order_tz = ord
    .orig_order_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_orig_ord_as_flag = ord
    .orig_ord_as_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_override_flag = ord
    .override_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_pathway_catalog_id = ord
    .pathway_catalog_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_person_id = ord
    .person_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_prn_ind = ord.prn_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_product_id = ord
    .product_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_projected_stop_dt_tm =
    ord.projected_stop_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_projected_stop_tz = ord
    .projected_stop_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_ref_text_mask = ord
    .ref_text_mask ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_remaining_dose_cnt = ord
    .remaining_dose_cnt ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_resume_effective_dt_tm
    = ord.resume_effective_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_resume_effective_tz =
    ord.resume_effective_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_resume_ind = ord
    .resume_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_rx_mask = ord.rx_mask ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_sch_state_cd = ord
    .sch_state_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_soft_stop_dt_tm = ord
    .soft_stop_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_soft_stop_tz = ord
    .soft_stop_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_status_dt_tm = ord
    .status_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_status_prsnl_id = ord
    .status_prsnl_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_stop_type_cd = ord
    .stop_type_cd ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_suspend_effective_dt_tm
    = ord.suspend_effective_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_suspend_effective_tz =
    ord.suspend_effective_tz ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_suspend_ind = ord
    .suspend_ind ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_synonym_id = ord
    .synonym_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].
    orders_template_core_action_sequence = ord.template_core_action_sequence ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_template_order_flag =
    ord.template_order_flag ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_template_order_id = ord
    .template_order_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_updt_dt_tm = ord
    .updt_dt_tm ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_updt_id = ord.updt_id ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_updt_task = ord
    .updt_task ,
    data->qual[i4qualcount ].defic_qual[i4defqualcnt ].order_qual[1 ].orders_valid_dose_dt_tm = ord
    .valid_dose_dt_tm ,
    IF ((him_doc_aging_ind = 1 ) ) gl_ord_age_cnt = (gl_ord_age_cnt + 1 ) ,
     IF ((gl_ord_age_cnt > size (order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].
      order_qual ,5 ) ) ) stat = alterlist (order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt
       ].order_qual ,(gl_ord_age_cnt + 9 ) )
     ENDIF
     ,order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].order_qual[gl_ord_age_cnt ].order_id
      = ord.order_id ,order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].order_qual[
     gl_ord_age_cnt ].action_sequence = o_r.action_sequence ,
     IF ((has.allocation_dt_tm != null ) ) order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ]
      .order_qual[gl_ord_age_cnt ].alloc_dt_tm = has.allocation_dt_tm
     ELSE order_struct->phys_qual[rec_num ].encntr_qual[encntr_cnt ].order_qual[gl_ord_age_cnt ].
      alloc_dt_tm = o_n.notification_dt_tm
     ENDIF
    ENDIF
   FOOT  e.encntr_id
    stat = alterlist (data->qual[i4qualcount ].defic_qual ,i4defqualcnt ) ,
    IF ((i4defqualcnt > data->max_defic_qual_count ) ) data->max_defic_qual_count = i4defqualcnt
    ENDIF
    ,
    IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (order_struct->phys_qual[rec_num ].encntr_qual[
      encntr_cnt ].order_qual ,gl_ord_age_cnt )
    ENDIF
   FOOT  o_n.to_prsnl_id
    IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (order_struct->phys_qual[rec_num ].encntr_qual ,
      encntr_cnt )
    ENDIF
   FOOT REPORT
    stat = alterlist (data->qual ,gl_data_cnt ) ,
    IF ((him_doc_aging_ind = 1 ) ) stat = alterlist (order_struct->phys_qual ,rec_num )
    ENDIF
    ,
    IF ((him_visit_aging_ind = 1 ) ) stat = alterlist (visit_age_request->total_qual ,visitcnt )
    ENDIF
   WITH nocounter ,orahintcbo ("LEADING(O_N)" )
  ;end select
  IF ((him_doc_aging_ind = 1 ) )
   EXECUTE him_get_order_age WITH replace ("REPLY" ,"ORDER_AGE_REPLY" )
   FOR (phys_cnt = 1 TO size (order_struct->phys_qual ,5 ) )
    FOR (encntr_cnt = 1 TO size (order_struct->phys_qual[phys_cnt ].encntr_qual ,5 ) )
     SET encntr_pos = locateval (iloop ,1 ,gl_data_cnt ,order_struct->phys_qual[phys_cnt ].
      physician_id ,data->qual[iloop ].physician_id ,order_struct->phys_qual[phys_cnt ].encntr_qual[
      encntr_cnt ].encntr_id ,data->qual[iloop ].encntr_id )
     FOR (gl_ord_age_cnt = 1 TO size (order_struct->phys_qual[phys_cnt ].encntr_qual[encntr_cnt ].
      order_qual ,5 ) )
      SET gl_defic_pos = locateval (iloop ,1 ,size (data->qual[encntr_pos ].defic_qual ,5 ) ,
       order_struct->phys_qual[phys_cnt ].encntr_qual[encntr_cnt ].order_qual[gl_ord_age_cnt ].
       order_id ,data->qual[encntr_pos ].defic_qual[iloop ].order_id ,order_struct->phys_qual[
       phys_cnt ].encntr_qual[encntr_cnt ].order_qual[gl_ord_age_cnt ].action_sequence ,data->qual[
       encntr_pos ].defic_qual[iloop ].action_sequence )
      SET data->qual[encntr_pos ].defic_qual[gl_defic_pos ].defic_age = order_struct->phys_qual[
      phys_cnt ].encntr_qual[encntr_cnt ].order_qual[gl_ord_age_cnt ].order_age
     ENDFOR
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 IF ((size (data->qual ,5 ) > 0 ) )
  SET gl_data_cnt = size (data->qual ,5 )
  SELECT INTO "nl:"
   alloc_dt_tm =
   IF ((cp.allocation_dt_flag = 0 ) ) (cnvtdate (cp.allocation_dt_tm ) + cp.allocation_dt_modifier )
   ELSEIF ((cp.allocation_dt_flag = 1 ) ) (cnvtdate (e.reg_dt_tm ) + cp.allocation_dt_modifier )
   ELSEIF ((cp.allocation_dt_flag = 2 ) ) (cnvtdate (e.disch_dt_tm ) + cp.allocation_dt_modifier )
   ENDIF
   FROM (dummyt d1 WITH seq = value (gl_data_cnt ) ),
    (chart_process cp ),
    (encounter e )
   PLAN (d1 )
    JOIN (e
    WHERE (e.encntr_id = data->qual[d1.seq ].encntr_id )
    AND (((i1multifacilitylogicind = 0 ) ) OR (expand (gn_index ,1 ,gl_org_cnt ,e.organization_id ,
     organizations->qual[gn_index ].item_id ) ))
    AND (e.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (cp
    WHERE (cp.encntr_id = data->qual[d1.seq ].encntr_id )
    AND (cp.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (cp.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) ) )
   DETAIL
    data->qual[d1.seq ].chart_alloc_dt_tm = alloc_dt_tm ,
    data->qual[i4qualcount ].him_visit_abstract_complete_ind = cp.abstract_complete_ind ,
    data->qual[i4qualcount ].him_visit_active_ind = cp.active_ind ,
    data->qual[i4qualcount ].him_visit_active_status_cd = cp.active_status_cd ,
    data->qual[i4qualcount ].him_visit_active_status_dt_tm = cp.active_status_dt_tm ,
    data->qual[i4qualcount ].him_visit_active_status_prsnl_id = cp.active_status_prsnl_id ,
    data->qual[i4qualcount ].him_visit_allocation_dt_flag = cp.allocation_dt_flag ,
    data->qual[i4qualcount ].him_visit_allocation_dt_modifier = cp.allocation_dt_modifier ,
    data->qual[i4qualcount ].him_visit_allocation_dt_tm = cp.allocation_dt_tm ,
    data->qual[i4qualcount ].him_visit_beg_effective_dt_tm = cp.beg_effective_dt_tm ,
    data->qual[i4qualcount ].him_visit_chart_process_id = cp.chart_process_id ,
    data->qual[i4qualcount ].him_visit_chart_status_cd = cp.chart_status_cd ,
    data->qual[i4qualcount ].him_visit_chart_status_dt_tm = cp.chart_status_dt_tm ,
    data->qual[i4qualcount ].him_visit_encntr_id = cp.encntr_id ,
    data->qual[i4qualcount ].him_visit_end_effective_dt_tm = cp.end_effective_dt_tm ,
    data->qual[i4qualcount ].him_visit_person_id = cp.person_id ,
    data->qual[i4qualcount ].him_visit_updt_dt_tm = cp.updt_dt_tm ,
    data->qual[i4qualcount ].him_visit_updt_id = cp.updt_id ,
    data->qual[i4qualcount ].him_visit_updt_task = cp.updt_task ,
    IF ((him_visit_aging_ind = 1 )
    AND (cp.chart_process_id > 0 ) ) gl_visit_cnt = (gl_visit_cnt + 1 ) ,
     IF ((gl_visit_cnt > size (visit_age_request->total_qual ,5 ) ) ) stat = alterlist (
       visit_age_request->total_qual ,(gl_visit_cnt + 9 ) )
     ENDIF
     ,visit_age_request->total_qual[gl_visit_cnt ].encntr_id = e.encntr_id ,visit_age_request->
     total_qual[gl_visit_cnt ].physician_id = data->qual[d1.seq ].physician_id ,visit_age_request->
     total_qual[gl_visit_cnt ].organization_id = e.organization_id ,visit_age_request->total_qual[
     gl_visit_cnt ].starting_pos = d1.seq
    ENDIF
    ,event_cnt = 0
   WITH nocounter
  ;end select
  IF ((him_visit_aging_ind = 1 ) )
   SET stat = alterlist (visit_age_request->total_qual ,gl_visit_cnt )
  ENDIF
 ENDIF
 IF ((him_visit_aging_ind = 1 ) )
  EXECUTE him_get_chart_age WITH replace ("AGE_REQUEST_STRUCT" ,"VISIT_AGE_REQUEST" ) ,
  replace ("AGE_REPLY_STRUCT" ,"VISIT_AGE_REPLY" )
  SET gl_data_cnt = size (data->qual ,5 )
  FOR (encntr_cnt = 1 TO size (visit_age_reply->encntr_qual ,5 ) )
   SET encntr_pos = locateval (iloop ,1 ,gl_data_cnt ,visit_age_reply->encntr_qual[encntr_cnt ].
    encntr_id ,data->qual[iloop ].encntr_id ,visit_age_reply->encntr_qual[encntr_cnt ].physician_id ,
    data->qual[iloop ].physician_id )
   SET data->qual[encntr_pos ].chart_age = visit_age_reply->encntr_qual[encntr_cnt ].chart_age
  ENDFOR
 ENDIF
 SET gl_data_cnt = size (data->qual ,5 )
 SELECT INTO "nl:"
  mrn = substring (1 ,100 ,cnvtalias (ea_mrn.alias ,ea_mrn.alias_pool_cd ) ) ,
  fin = substring (1 ,100 ,cnvtalias (ea_fin.alias ,ea_fin.alias_pool_cd ) ) ,
  patient_abs_birth_dt_tm = patient.abs_birth_dt_tm ,
  patient_active_ind = patient.active_ind ,
  patient_active_status_cd = patient.active_status_cd ,
  patient_active_status_dt_tm = patient.active_status_dt_tm ,
  patient_active_status_prsnl_id = patient.active_status_prsnl_id ,
  patient_archive_env_id = patient.archive_env_id ,
  patient_archive_status_cd = patient.archive_status_cd ,
  patient_archive_status_dt_tm = patient.archive_status_dt_tm ,
  patient_autopsy_cd = patient.autopsy_cd ,
  patient_beg_effective_dt_tm = patient.beg_effective_dt_tm ,
  patient_birth_dt_cd = patient.birth_dt_cd ,
  patient_birth_dt_tm = patient.birth_dt_tm ,
  patient_birth_prec_flag = patient.birth_prec_flag ,
  patient_birth_tz = patient.birth_tz ,
  patient_cause_of_death = substring (1 ,100 ,patient.cause_of_death ) ,
  patient_cause_of_death_cd = patient.cause_of_death_cd ,
  patient_citizenship_cd = patient.citizenship_cd ,
  patient_conception_dt_tm = patient.conception_dt_tm ,
  patient_confid_level_cd = patient.confid_level_cd ,
  patient_contributor_system_cd = patient.contributor_system_cd ,
  patient_create_dt_tm = patient.create_dt_tm ,
  patient_create_prsnl_id = patient.create_prsnl_id ,
  patient_data_status_cd = patient.data_status_cd ,
  patient_data_status_dt_tm = patient.data_status_dt_tm ,
  patient_data_status_prsnl_id = patient.data_status_prsnl_id ,
  patient_deceased_cd = patient.deceased_cd ,
  patient_deceased_dt_tm = patient.deceased_dt_tm ,
  patient_deceased_source_cd = patient.deceased_source_cd ,
  patient_end_effective_dt_tm = patient.end_effective_dt_tm ,
  patient_ethnic_grp_cd = patient.ethnic_grp_cd ,
  patient_ft_entity_id = patient.ft_entity_id ,
  patient_ft_entity_name = substring (1 ,32 ,patient.ft_entity_name ) ,
  patient_language_cd = patient.language_cd ,
  patient_language_dialect_cd = patient.language_dialect_cd ,
  patient_last_accessed_dt_tm = patient.last_accessed_dt_tm ,
  patient_last_encntr_dt_tm = patient.last_encntr_dt_tm ,
  patient_marital_type_cd = patient.marital_type_cd ,
  patient_military_base_location = substring (1 ,100 ,patient.military_base_location ) ,
  patient_military_rank_cd = patient.military_rank_cd ,
  patient_military_service_cd = patient.military_service_cd ,
  patient_mother_maiden_name = substring (1 ,100 ,patient.mother_maiden_name ) ,
  patient_name_first = substring (1 ,200 ,patient.name_first ) ,
  patient_name_first_key = substring (1 ,100 ,patient.name_first_key ) ,
  patient_name_first_key_nls = substring (1 ,202 ,patient.name_first_key_nls ) ,
  patient_name_first_phonetic = substring (1 ,8 ,patient.name_first_phonetic ) ,
  patient_name_first_synonym_id = patient.name_first_synonym_id ,
  patient_name_full_formatted = substring (1 ,100 ,patient.name_full_formatted ) ,
  patient_name_last = substring (1 ,200 ,patient.name_last ) ,
  patient_name_last_key = substring (1 ,100 ,patient.name_last_key ) ,
  patient_name_last_key_nls = substring (1 ,202 ,patient.name_last_key_nls ) ,
  patient_name_last_phonetic = substring (1 ,8 ,patient.name_last_phonetic ) ,
  patient_name_middle = substring (1 ,200 ,patient.name_middle ) ,
  patient_name_middle_key = substring (1 ,100 ,patient.name_middle_key ) ,
  patient_name_middle_key_nls = substring (1 ,202 ,patient.name_middle_key_nls ) ,
  patient_name_phonetic = substring (1 ,8 ,patient.name_phonetic ) ,
  patient_nationality_cd = patient.nationality_cd ,
  patient_next_restore_dt_tm = patient.next_restore_dt_tm ,
  patient_person_id = patient.person_id ,
  patient_person_type_cd = patient.person_type_cd ,
  patient_race_cd = patient.race_cd ,
  patient_religion_cd = patient.religion_cd ,
  patient_sex_age_change_ind = patient.sex_age_change_ind ,
  patient_sex_cd = patient.sex_cd ,
  patient_species_cd = patient.species_cd ,
  patient_updt_dt_tm = patient.updt_dt_tm ,
  patient_updt_id = patient.updt_id ,
  patient_updt_task = patient.updt_task ,
  patient_vet_military_status_cd = patient.vet_military_status_cd ,
  patient_vip_cd = patient.vip_cd ,
  encntr_accommodation_cd = e.accommodation_cd ,
  encntr_accommodation_reason_cd = e.accommodation_reason_cd ,
  encntr_accommodation_request_cd = e.accommodation_request_cd ,
  encntr_accomp_by_cd = e.accomp_by_cd ,
  encntr_active_ind = e.active_ind ,
  encntr_active_status_cd = e.active_status_cd ,
  encntr_active_status_dt_tm = e.active_status_dt_tm ,
  encntr_active_status_prsnl_id = e.active_status_prsnl_id ,
  encntr_admit_mode_cd = e.admit_mode_cd ,
  encntr_admit_src_cd = e.admit_src_cd ,
  encntr_admit_type_cd = e.admit_type_cd ,
  encntr_admit_with_medication_cd = e.admit_with_medication_cd ,
  encntr_alc_decomp_dt_tm = e.alc_decomp_dt_tm ,
  encntr_alc_reason_cd = e.alc_reason_cd ,
  encntr_alt_lvl_care_cd = e.alt_lvl_care_cd ,
  encntr_alt_lvl_care_dt_tm = e.alt_lvl_care_dt_tm ,
  encntr_ambulatory_cond_cd = e.ambulatory_cond_cd ,
  encntr_archive_dt_tm_act = e.archive_dt_tm_act ,
  encntr_archive_dt_tm_est = e.archive_dt_tm_est ,
  encntr_arrive_dt_tm = e.arrive_dt_tm ,
  encntr_assign_to_loc_dt_tm = e.assign_to_loc_dt_tm ,
  encntr_bbd_procedure_cd = e.bbd_procedure_cd ,
  encntr_beg_effective_dt_tm = e.beg_effective_dt_tm ,
  encntr_chart_complete_dt_tm = e.chart_complete_dt_tm ,
  encntr_confid_level_cd = e.confid_level_cd ,
  encntr_contract_status_cd = e.contract_status_cd ,
  encntr_contributor_system_cd = e.contributor_system_cd ,
  encntr_courtesy_cd = e.courtesy_cd ,
  encntr_create_dt_tm = e.create_dt_tm ,
  encntr_create_prsnl_id = e.create_prsnl_id ,
  encntr_data_status_cd = e.data_status_cd ,
  encntr_data_status_dt_tm = e.data_status_dt_tm ,
  encntr_data_status_prsnl_id = e.data_status_prsnl_id ,
  encntr_depart_dt_tm = e.depart_dt_tm ,
  encntr_diet_type_cd = e.diet_type_cd ,
  encntr_disch_disposition_cd = e.disch_disposition_cd ,
  encntr_disch_dt_tm = e.disch_dt_tm ,
  encntr_disch_to_loctn_cd = e.disch_to_loctn_cd ,
  encntr_doc_rcvd_dt_tm = e.doc_rcvd_dt_tm ,
  encntr_encntr_class_cd = e.encntr_class_cd ,
  encntr_encntr_complete_dt_tm = e.encntr_complete_dt_tm ,
  encntr_encntr_financial_id = e.encntr_financial_id ,
  encntr_encntr_id = e.encntr_id ,
  encntr_encntr_status_cd = e.encntr_status_cd ,
  encntr_encntr_type_cd = e.encntr_type_cd ,
  encntr_encntr_type_class_cd = e.encntr_type_class_cd ,
  encntr_end_effective_dt_tm = e.end_effective_dt_tm ,
  encntr_est_arrive_dt_tm = e.est_arrive_dt_tm ,
  encntr_est_depart_dt_tm = e.est_depart_dt_tm ,
  encntr_est_length_of_stay = e.est_length_of_stay ,
  encntr_financial_class_cd = e.financial_class_cd ,
  encntr_guarantor_type_cd = e.guarantor_type_cd ,
  encntr_info_given_by = substring (1 ,100 ,e.info_given_by ) ,
  encntr_inpatient_admit_dt_tm = e.inpatient_admit_dt_tm ,
  encntr_isolation_cd = e.isolation_cd ,
  encntr_location_cd = e.location_cd ,
  encntr_loc_bed_cd = e.loc_bed_cd ,
  encntr_loc_building_cd = e.loc_building_cd ,
  encntr_loc_facility_cd = e.loc_facility_cd ,
  encntr_loc_nurse_unit_cd = e.loc_nurse_unit_cd ,
  encntr_loc_room_cd = e.loc_room_cd ,
  encntr_loc_temp_cd = e.loc_temp_cd ,
  encntr_med_service_cd = e.med_service_cd ,
  encntr_mental_category_cd = e.mental_category_cd ,
  encntr_mental_health_dt_tm = e.mental_health_dt_tm ,
  encntr_organization_id = e.organization_id ,
  encntr_parent_ret_criteria_id = e.parent_ret_criteria_id ,
  encntr_patient_classification_cd = e.patient_classification_cd ,
  encntr_pa_current_status_cd = e.pa_current_status_cd ,
  encntr_pa_current_status_dt_tm = e.pa_current_status_dt_tm ,
  encntr_person_id = e.person_id ,
  encntr_placement_auth_prsnl_id = e.placement_auth_prsnl_id ,
  encntr_preadmit_testing_cd = e.preadmit_testing_cd ,
  encntr_pre_reg_dt_tm = e.pre_reg_dt_tm ,
  encntr_pre_reg_prsnl_id = e.pre_reg_prsnl_id ,
  encntr_program_service_cd = e.program_service_cd ,
  encntr_psychiatric_status_cd = e.psychiatric_status_cd ,
  encntr_purge_dt_tm_act = e.purge_dt_tm_act ,
  encntr_purge_dt_tm_est = e.purge_dt_tm_est ,
  encntr_readmit_cd = e.readmit_cd ,
  encntr_reason_for_visit = substring (1 ,255 ,e.reason_for_visit ) ,
  encntr_referral_rcvd_dt_tm = e.referral_rcvd_dt_tm ,
  encntr_referring_comment = substring (1 ,100 ,e.referring_comment ) ,
  encntr_refer_facility_cd = e.refer_facility_cd ,
  encntr_region_cd = e.region_cd ,
  encntr_reg_dt_tm = e.reg_dt_tm ,
  encntr_reg_prsnl_id = e.reg_prsnl_id ,
  encntr_result_accumulation_dt_tm = e.result_accumulation_dt_tm ,
  encntr_safekeeping_cd = e.safekeeping_cd ,
  encntr_security_access_cd = e.security_access_cd ,
  encntr_service_category_cd = e.service_category_cd ,
  encntr_sitter_required_cd = e.sitter_required_cd ,
  encntr_specialty_unit_cd = e.specialty_unit_cd ,
  encntr_trauma_cd = e.trauma_cd ,
  encntr_trauma_dt_tm = e.trauma_dt_tm ,
  encntr_triage_cd = e.triage_cd ,
  encntr_triage_dt_tm = e.triage_dt_tm ,
  encntr_updt_dt_tm = e.updt_dt_tm ,
  encntr_updt_id = e.updt_id ,
  encntr_updt_task = e.updt_task ,
  encntr_valuables_cd = e.valuables_cd ,
  encntr_vip_cd = e.vip_cd ,
  encntr_visitor_status_cd = e.visitor_status_cd ,
  encntr_zero_balance_dt_tm = e.zero_balance_dt_tm ,
  encntr_mrn_active_ind = ea_mrn.active_ind ,
  encntr_mrn_active_status_cd = ea_mrn.active_status_cd ,
  encntr_mrn_active_status_dt_tm = ea_mrn.active_status_dt_tm ,
  encntr_mrn_active_status_prsnl_id = ea_mrn.active_status_prsnl_id ,
  encntr_mrn_alias = substring (1 ,200 ,ea_mrn.alias ) ,
  encntr_mrn_alias_pool_cd = ea_mrn.alias_pool_cd ,
  encntr_mrn_assign_authority_sys_cd = ea_mrn.assign_authority_sys_cd ,
  encntr_mrn_beg_effective_dt_tm = ea_mrn.beg_effective_dt_tm ,
  encntr_mrn_check_digit = ea_mrn.check_digit ,
  encntr_mrn_check_digit_method_cd = ea_mrn.check_digit_method_cd ,
  encntr_mrn_contributor_system_cd = ea_mrn.contributor_system_cd ,
  encntr_mrn_data_status_cd = ea_mrn.data_status_cd ,
  encntr_mrn_data_status_dt_tm = ea_mrn.data_status_dt_tm ,
  encntr_mrn_data_status_prsnl_id = ea_mrn.data_status_prsnl_id ,
  encntr_mrn_encntr_alias_id = ea_mrn.encntr_alias_id ,
  encntr_mrn_encntr_alias_type_cd = ea_mrn.encntr_alias_type_cd ,
  encntr_mrn_encntr_id = ea_mrn.encntr_id ,
  encntr_mrn_end_effective_dt_tm = ea_mrn.end_effective_dt_tm ,
  encntr_mrn_updt_dt_tm = ea_mrn.updt_dt_tm ,
  encntr_mrn_updt_id = ea_mrn.updt_id ,
  encntr_mrn_updt_task = ea_mrn.updt_task ,
  encntr_fin_active_ind = ea_fin.active_ind ,
  encntr_fin_active_status_cd = ea_fin.active_status_cd ,
  encntr_fin_active_status_dt_tm = ea_fin.active_status_dt_tm ,
  encntr_fin_active_status_prsnl_id = ea_fin.active_status_prsnl_id ,
  encntr_fin_alias = substring (1 ,200 ,ea_fin.alias ) ,
  encntr_fin_alias_pool_cd = ea_fin.alias_pool_cd ,
  encntr_fin_assign_authority_sys_cd = ea_fin.assign_authority_sys_cd ,
  encntr_fin_beg_effective_dt_tm = ea_fin.beg_effective_dt_tm ,
  encntr_fin_check_digit = ea_fin.check_digit ,
  encntr_fin_check_digit_method_cd = ea_fin.check_digit_method_cd ,
  encntr_fin_contributor_system_cd = ea_fin.contributor_system_cd ,
  encntr_fin_data_status_cd = ea_fin.data_status_cd ,
  encntr_fin_data_status_dt_tm = ea_fin.data_status_dt_tm ,
  encntr_fin_data_status_prsnl_id = ea_fin.data_status_prsnl_id ,
  encntr_fin_encntr_alias_id = ea_fin.encntr_alias_id ,
  encntr_fin_encntr_alias_type_cd = ea_fin.encntr_alias_type_cd ,
  encntr_fin_encntr_id = ea_fin.encntr_id ,
  encntr_fin_end_effective_dt_tm = ea_fin.end_effective_dt_tm ,
  encntr_fin_updt_dt_tm = ea_fin.updt_dt_tm ,
  encntr_fin_updt_id = ea_fin.updt_id ,
  encntr_fin_updt_task = ea_fin.updt_task ,
  org_active_ind = o.active_ind ,
  org_active_status_cd = o.active_status_cd ,
  org_active_status_dt_tm = o.active_status_dt_tm ,
  org_active_status_prsnl_id = o.active_status_prsnl_id ,
  org_beg_effective_dt_tm = o.beg_effective_dt_tm ,
  org_contributor_source_cd = o.contributor_source_cd ,
  org_contributor_system_cd = o.contributor_system_cd ,
  org_data_status_cd = o.data_status_cd ,
  org_data_status_dt_tm = o.data_status_dt_tm ,
  org_data_status_prsnl_id = o.data_status_prsnl_id ,
  org_end_effective_dt_tm = o.end_effective_dt_tm ,
  org_federal_tax_id_nbr = substring (1 ,100 ,o.federal_tax_id_nbr ) ,
  org_ft_entity_id = o.ft_entity_id ,
  org_ft_entity_name = substring (1 ,32 ,o.ft_entity_name ) ,
  org_organization_id = o.organization_id ,
  org_org_class_cd = o.org_class_cd ,
  org_org_name = substring (1 ,100 ,o.org_name ) ,
  org_org_name_key = substring (1 ,100 ,o.org_name_key ) ,
  org_org_name_key_nls = substring (1 ,202 ,o.org_name_key_nls ) ,
  org_org_status_cd = o.org_status_cd ,
  org_updt_dt_tm = o.updt_dt_tm ,
  org_updt_id = o.updt_id ,
  org_updt_task = o.updt_task
  FROM (dummyt d WITH seq = gl_data_cnt ),
   (encounter e ),
   (organization o ),
   (person patient ),
   (encntr_alias ea_mrn ),
   (encntr_alias ea_fin )
  PLAN (d )
   JOIN (e
   WHERE (e.encntr_id = data->qual[d.seq ].encntr_id ) )
   JOIN (patient
   WHERE (patient.person_id = e.person_id ) )
   JOIN (o
   WHERE (o.organization_id = e.organization_id ) )
   JOIN (ea_mrn
   WHERE (ea_mrn.encntr_alias_type_cd = outerjoin (mc_mrn_cd ) )
   AND (ea_mrn.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea_mrn.active_ind = outerjoin (1 ) ) )
   JOIN (ea_fin
   WHERE (ea_fin.encntr_alias_type_cd = outerjoin (mc_fin_cd ) )
   AND (ea_fin.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea_fin.active_ind = outerjoin (1 ) ) )
  ORDER BY d.seq
  HEAD d.seq
   i4qualcount = d.seq ,data->qual[i4qualcount ].organization_name = org_org_name ,data->qual[
   i4qualcount ].organization_id = o.organization_id ,data->qual[i4qualcount ].patient_id = patient
   .person_id ,data->qual[i4qualcount ].patient_name = patient_name_full_formatted ,data->qual[
   i4qualcount ].fin = fin ,data->qual[i4qualcount ].mrn = mrn ,data->qual[i4qualcount ].
   patient_abs_birth_dt_tm = patient_abs_birth_dt_tm ,data->qual[i4qualcount ].patient_active_ind =
   patient_active_ind ,data->qual[i4qualcount ].patient_active_status_cd = patient_active_status_cd ,
   data->qual[i4qualcount ].patient_active_status_dt_tm = patient_active_status_dt_tm ,data->qual[
   i4qualcount ].patient_active_status_prsnl_id = patient_active_status_prsnl_id ,data->qual[
   i4qualcount ].patient_archive_env_id = patient_archive_env_id ,data->qual[i4qualcount ].
   patient_archive_status_cd = patient_archive_status_cd ,data->qual[i4qualcount ].
   patient_archive_status_dt_tm = patient_archive_status_dt_tm ,data->qual[i4qualcount ].
   patient_autopsy_cd = patient_autopsy_cd ,data->qual[i4qualcount ].patient_beg_effective_dt_tm =
   patient_beg_effective_dt_tm ,data->qual[i4qualcount ].patient_birth_dt_cd = patient_birth_dt_cd ,
   data->qual[i4qualcount ].patient_birth_dt_tm = patient_birth_dt_tm ,data->qual[i4qualcount ].
   patient_birth_prec_flag = patient_birth_prec_flag ,data->qual[i4qualcount ].patient_birth_tz =
   patient_birth_tz ,data->qual[i4qualcount ].patient_cause_of_death = patient_cause_of_death ,data->
   qual[i4qualcount ].patient_cause_of_death_cd = patient_cause_of_death_cd ,data->qual[i4qualcount ]
   .patient_citizenship_cd = patient_citizenship_cd ,data->qual[i4qualcount ].
   patient_conception_dt_tm = patient_conception_dt_tm ,data->qual[i4qualcount ].
   patient_confid_level_cd = patient_confid_level_cd ,data->qual[i4qualcount ].
   patient_contributor_system_cd = patient_contributor_system_cd ,data->qual[i4qualcount ].
   patient_create_dt_tm = patient_create_dt_tm ,data->qual[i4qualcount ].patient_create_prsnl_id =
   patient_create_prsnl_id ,data->qual[i4qualcount ].patient_data_status_cd = patient_data_status_cd
   ,data->qual[i4qualcount ].patient_data_status_dt_tm = patient_data_status_dt_tm ,data->qual[
   i4qualcount ].patient_data_status_prsnl_id = patient_data_status_prsnl_id ,data->qual[i4qualcount
   ].patient_deceased_cd = patient_deceased_cd ,data->qual[i4qualcount ].patient_deceased_dt_tm =
   patient_deceased_dt_tm ,data->qual[i4qualcount ].patient_deceased_source_cd =
   patient_deceased_source_cd ,data->qual[i4qualcount ].patient_end_effective_dt_tm =
   patient_end_effective_dt_tm ,data->qual[i4qualcount ].patient_ethnic_grp_cd =
   patient_ethnic_grp_cd ,data->qual[i4qualcount ].patient_ft_entity_id = patient_ft_entity_id ,data
   ->qual[i4qualcount ].patient_ft_entity_name = patient_ft_entity_name ,data->qual[i4qualcount ].
   patient_language_cd = patient_language_cd ,data->qual[i4qualcount ].patient_language_dialect_cd =
   patient_language_dialect_cd ,data->qual[i4qualcount ].patient_last_accessed_dt_tm =
   patient_last_accessed_dt_tm ,data->qual[i4qualcount ].patient_last_encntr_dt_tm =
   patient_last_encntr_dt_tm ,data->qual[i4qualcount ].patient_marital_type_cd =
   patient_marital_type_cd ,data->qual[i4qualcount ].patient_military_base_location =
   patient_military_base_location ,data->qual[i4qualcount ].patient_military_rank_cd =
   patient_military_rank_cd ,data->qual[i4qualcount ].patient_military_service_cd =
   patient_military_service_cd ,data->qual[i4qualcount ].patient_mother_maiden_name =
   patient_mother_maiden_name ,data->qual[i4qualcount ].patient_name_first = patient_name_first ,data
   ->qual[i4qualcount ].patient_name_first_key = patient_name_first_key ,data->qual[i4qualcount ].
   patient_name_first_key_nls = patient_name_first_key_nls ,data->qual[i4qualcount ].
   patient_name_first_phonetic = patient_name_first_phonetic ,data->qual[i4qualcount ].
   patient_name_first_synonym_id = patient_name_first_synonym_id ,data->qual[i4qualcount ].
   patient_name_full_formatted = patient_name_full_formatted ,data->qual[i4qualcount ].
   patient_name_last = patient_name_last ,data->qual[i4qualcount ].patient_name_last_key =
   patient_name_last_key ,data->qual[i4qualcount ].patient_name_last_key_nls =
   patient_name_last_key_nls ,data->qual[i4qualcount ].patient_name_last_phonetic =
   patient_name_last_phonetic ,data->qual[i4qualcount ].patient_name_middle = patient_name_middle ,
   data->qual[i4qualcount ].patient_name_middle_key = patient_name_middle_key ,data->qual[
   i4qualcount ].patient_name_middle_key_nls = patient_name_middle_key_nls ,data->qual[i4qualcount ].
   patient_name_phonetic = patient_name_phonetic ,data->qual[i4qualcount ].patient_nationality_cd =
   patient_nationality_cd ,data->qual[i4qualcount ].patient_next_restore_dt_tm =
   patient_next_restore_dt_tm ,data->qual[i4qualcount ].patient_person_id = patient_person_id ,data->
   qual[i4qualcount ].patient_person_type_cd = patient_person_type_cd ,data->qual[i4qualcount ].
   patient_race_cd = patient_race_cd ,data->qual[i4qualcount ].patient_religion_cd =
   patient_religion_cd ,data->qual[i4qualcount ].patient_sex_age_change_ind =
   patient_sex_age_change_ind ,data->qual[i4qualcount ].patient_sex_cd = patient_sex_cd ,data->qual[
   i4qualcount ].patient_species_cd = patient_species_cd ,data->qual[i4qualcount ].patient_updt_dt_tm
    = patient_updt_dt_tm ,data->qual[i4qualcount ].patient_updt_id = patient_updt_id ,data->qual[
   i4qualcount ].patient_updt_task = patient_updt_task ,data->qual[i4qualcount ].
   patient_vet_military_status_cd = patient_vet_military_status_cd ,data->qual[i4qualcount ].
   patient_vip_cd = patient_vip_cd ,data->qual[i4qualcount ].encntr_accommodation_cd =
   encntr_accommodation_cd ,data->qual[i4qualcount ].encntr_accommodation_reason_cd =
   encntr_accommodation_reason_cd ,data->qual[i4qualcount ].encntr_accommodation_request_cd =
   encntr_accommodation_request_cd ,data->qual[i4qualcount ].encntr_accomp_by_cd =
   encntr_accomp_by_cd ,data->qual[i4qualcount ].encntr_active_ind = encntr_active_ind ,data->qual[
   i4qualcount ].encntr_active_status_cd = encntr_active_status_cd ,data->qual[i4qualcount ].
   encntr_active_status_dt_tm = encntr_active_status_dt_tm ,data->qual[i4qualcount ].
   encntr_active_status_prsnl_id = encntr_active_status_prsnl_id ,data->qual[i4qualcount ].
   encntr_admit_mode_cd = encntr_admit_mode_cd ,data->qual[i4qualcount ].encntr_admit_src_cd =
   encntr_admit_src_cd ,data->qual[i4qualcount ].encntr_admit_type_cd = encntr_admit_type_cd ,data->
   qual[i4qualcount ].encntr_admit_with_medication_cd = encntr_admit_with_medication_cd ,data->qual[
   i4qualcount ].encntr_alc_decomp_dt_tm = encntr_alc_decomp_dt_tm ,data->qual[i4qualcount ].
   encntr_alc_reason_cd = encntr_alc_reason_cd ,data->qual[i4qualcount ].encntr_alt_lvl_care_cd =
   encntr_alt_lvl_care_cd ,data->qual[i4qualcount ].encntr_alt_lvl_care_dt_tm =
   encntr_alt_lvl_care_dt_tm ,data->qual[i4qualcount ].encntr_ambulatory_cond_cd =
   encntr_ambulatory_cond_cd ,data->qual[i4qualcount ].encntr_archive_dt_tm_act =
   encntr_archive_dt_tm_act ,data->qual[i4qualcount ].encntr_archive_dt_tm_est =
   encntr_archive_dt_tm_est ,data->qual[i4qualcount ].encntr_arrive_dt_tm = encntr_arrive_dt_tm ,data
   ->qual[i4qualcount ].encntr_assign_to_loc_dt_tm = encntr_assign_to_loc_dt_tm ,data->qual[
   i4qualcount ].encntr_bbd_procedure_cd = encntr_bbd_procedure_cd ,data->qual[i4qualcount ].
   encntr_beg_effective_dt_tm = encntr_beg_effective_dt_tm ,data->qual[i4qualcount ].
   encntr_chart_complete_dt_tm = encntr_chart_complete_dt_tm ,data->qual[i4qualcount ].
   encntr_confid_level_cd = encntr_confid_level_cd ,data->qual[i4qualcount ].
   encntr_contract_status_cd = encntr_contract_status_cd ,data->qual[i4qualcount ].
   encntr_contributor_system_cd = encntr_contributor_system_cd ,data->qual[i4qualcount ].
   encntr_courtesy_cd = encntr_courtesy_cd ,data->qual[i4qualcount ].encntr_create_dt_tm =
   encntr_create_dt_tm ,data->qual[i4qualcount ].encntr_create_prsnl_id = encntr_create_prsnl_id ,
   data->qual[i4qualcount ].encntr_data_status_cd = encntr_data_status_cd ,data->qual[i4qualcount ].
   encntr_data_status_dt_tm = encntr_data_status_dt_tm ,data->qual[i4qualcount ].
   encntr_data_status_prsnl_id = encntr_data_status_prsnl_id ,data->qual[i4qualcount ].
   encntr_depart_dt_tm = encntr_depart_dt_tm ,data->qual[i4qualcount ].encntr_diet_type_cd =
   encntr_diet_type_cd ,data->qual[i4qualcount ].encntr_disch_disposition_cd =
   encntr_disch_disposition_cd ,data->qual[i4qualcount ].encntr_disch_dt_tm = encntr_disch_dt_tm ,
   data->qual[i4qualcount ].encntr_disch_to_loctn_cd = encntr_disch_to_loctn_cd ,data->qual[
   i4qualcount ].encntr_doc_rcvd_dt_tm = encntr_doc_rcvd_dt_tm ,data->qual[i4qualcount ].
   encntr_encntr_class_cd = encntr_encntr_class_cd ,data->qual[i4qualcount ].
   encntr_encntr_complete_dt_tm = encntr_encntr_complete_dt_tm ,data->qual[i4qualcount ].
   encntr_encntr_financial_id = encntr_encntr_financial_id ,data->qual[i4qualcount ].encntr_encntr_id
    = encntr_encntr_id ,data->qual[i4qualcount ].encntr_encntr_status_cd = encntr_encntr_status_cd ,
   data->qual[i4qualcount ].encntr_encntr_type_cd = encntr_encntr_type_cd ,data->qual[i4qualcount ].
   encntr_encntr_type_class_cd = encntr_encntr_type_class_cd ,data->qual[i4qualcount ].
   encntr_end_effective_dt_tm = encntr_end_effective_dt_tm ,data->qual[i4qualcount ].
   encntr_est_arrive_dt_tm = encntr_est_arrive_dt_tm ,data->qual[i4qualcount ].
   encntr_est_depart_dt_tm = encntr_est_depart_dt_tm ,data->qual[i4qualcount ].
   encntr_est_length_of_stay = encntr_est_length_of_stay ,data->qual[i4qualcount ].
   encntr_financial_class_cd = encntr_financial_class_cd ,data->qual[i4qualcount ].
   encntr_guarantor_type_cd = encntr_guarantor_type_cd ,data->qual[i4qualcount ].encntr_info_given_by
    = encntr_info_given_by ,data->qual[i4qualcount ].encntr_inpatient_admit_dt_tm =
   encntr_inpatient_admit_dt_tm ,data->qual[i4qualcount ].encntr_isolation_cd = encntr_isolation_cd ,
   data->qual[i4qualcount ].encntr_location_cd = encntr_location_cd ,data->qual[i4qualcount ].
   encntr_loc_bed_cd = encntr_loc_bed_cd ,data->qual[i4qualcount ].encntr_loc_building_cd =
   encntr_loc_building_cd ,data->qual[i4qualcount ].encntr_loc_facility_cd = encntr_loc_facility_cd ,
   data->qual[i4qualcount ].encntr_loc_nurse_unit_cd = encntr_loc_nurse_unit_cd ,data->qual[
   i4qualcount ].encntr_loc_room_cd = encntr_loc_room_cd ,data->qual[i4qualcount ].encntr_loc_temp_cd
    = encntr_loc_temp_cd ,data->qual[i4qualcount ].encntr_med_service_cd = encntr_med_service_cd ,
   data->qual[i4qualcount ].encntr_mental_category_cd = encntr_mental_category_cd ,data->qual[
   i4qualcount ].encntr_mental_health_dt_tm = encntr_mental_health_dt_tm ,data->qual[i4qualcount ].
   encntr_organization_id = encntr_organization_id ,data->qual[i4qualcount ].
   encntr_parent_ret_criteria_id = encntr_parent_ret_criteria_id ,data->qual[i4qualcount ].
   encntr_patient_classification_cd = encntr_patient_classification_cd ,data->qual[i4qualcount ].
   encntr_pa_current_status_cd = encntr_pa_current_status_cd ,data->qual[i4qualcount ].
   encntr_pa_current_status_dt_tm = encntr_pa_current_status_dt_tm ,data->qual[i4qualcount ].
   encntr_person_id = encntr_person_id ,data->qual[i4qualcount ].encntr_placement_auth_prsnl_id =
   encntr_placement_auth_prsnl_id ,data->qual[i4qualcount ].encntr_preadmit_testing_cd =
   encntr_preadmit_testing_cd ,data->qual[i4qualcount ].encntr_pre_reg_dt_tm = encntr_pre_reg_dt_tm ,
   data->qual[i4qualcount ].encntr_pre_reg_prsnl_id = encntr_pre_reg_prsnl_id ,data->qual[
   i4qualcount ].encntr_program_service_cd = encntr_program_service_cd ,data->qual[i4qualcount ].
   encntr_psychiatric_status_cd = encntr_psychiatric_status_cd ,data->qual[i4qualcount ].
   encntr_purge_dt_tm_act = encntr_purge_dt_tm_act ,data->qual[i4qualcount ].encntr_purge_dt_tm_est
   = encntr_purge_dt_tm_est ,data->qual[i4qualcount ].encntr_readmit_cd = encntr_readmit_cd ,data->
   qual[i4qualcount ].encntr_reason_for_visit = encntr_reason_for_visit ,data->qual[i4qualcount ].
   encntr_referral_rcvd_dt_tm = encntr_referral_rcvd_dt_tm ,data->qual[i4qualcount ].
   encntr_referring_comment = encntr_referring_comment ,data->qual[i4qualcount ].
   encntr_refer_facility_cd = encntr_refer_facility_cd ,data->qual[i4qualcount ].encntr_region_cd =
   encntr_region_cd ,data->qual[i4qualcount ].encntr_reg_dt_tm = encntr_reg_dt_tm ,data->qual[
   i4qualcount ].encntr_reg_prsnl_id = encntr_reg_prsnl_id ,data->qual[i4qualcount ].
   encntr_result_accumulation_dt_tm = encntr_result_accumulation_dt_tm ,data->qual[i4qualcount ].
   encntr_safekeeping_cd = encntr_safekeeping_cd ,data->qual[i4qualcount ].encntr_security_access_cd
   = encntr_security_access_cd ,data->qual[i4qualcount ].encntr_service_category_cd =
   encntr_service_category_cd ,data->qual[i4qualcount ].encntr_sitter_required_cd =
   encntr_sitter_required_cd ,data->qual[i4qualcount ].encntr_specialty_unit_cd =
   encntr_specialty_unit_cd ,data->qual[i4qualcount ].encntr_trauma_cd = encntr_trauma_cd ,data->
   qual[i4qualcount ].encntr_trauma_dt_tm = encntr_trauma_dt_tm ,data->qual[i4qualcount ].
   encntr_triage_cd = encntr_triage_cd ,data->qual[i4qualcount ].encntr_triage_dt_tm =
   encntr_triage_dt_tm ,data->qual[i4qualcount ].encntr_updt_dt_tm = encntr_updt_dt_tm ,data->qual[
   i4qualcount ].encntr_updt_id = encntr_updt_id ,data->qual[i4qualcount ].encntr_updt_task =
   encntr_updt_task ,data->qual[i4qualcount ].encntr_valuables_cd = encntr_valuables_cd ,data->qual[
   i4qualcount ].encntr_vip_cd = encntr_vip_cd ,data->qual[i4qualcount ].encntr_visitor_status_cd =
   encntr_visitor_status_cd ,data->qual[i4qualcount ].encntr_zero_balance_dt_tm =
   encntr_zero_balance_dt_tm ,data->qual[i4qualcount ].encntr_mrn_active_ind = encntr_mrn_active_ind
   ,data->qual[i4qualcount ].encntr_mrn_active_status_cd = encntr_mrn_active_status_cd ,data->qual[
   i4qualcount ].encntr_mrn_active_status_dt_tm = encntr_mrn_active_status_dt_tm ,data->qual[
   i4qualcount ].encntr_mrn_active_status_prsnl_id = encntr_mrn_active_status_prsnl_id ,data->qual[
   i4qualcount ].encntr_mrn_alias = encntr_mrn_alias ,data->qual[i4qualcount ].
   encntr_mrn_alias_pool_cd = encntr_mrn_alias_pool_cd ,data->qual[i4qualcount ].
   encntr_mrn_assign_authority_sys_cd = encntr_mrn_assign_authority_sys_cd ,data->qual[i4qualcount ].
   encntr_mrn_beg_effective_dt_tm = encntr_mrn_beg_effective_dt_tm ,data->qual[i4qualcount ].
   encntr_mrn_check_digit = encntr_mrn_check_digit ,data->qual[i4qualcount ].
   encntr_mrn_check_digit_method_cd = encntr_mrn_check_digit_method_cd ,data->qual[i4qualcount ].
   encntr_mrn_contributor_system_cd = encntr_mrn_contributor_system_cd ,data->qual[i4qualcount ].
   encntr_mrn_data_status_cd = encntr_mrn_data_status_cd ,data->qual[i4qualcount ].
   encntr_mrn_data_status_dt_tm = encntr_mrn_data_status_dt_tm ,data->qual[i4qualcount ].
   encntr_mrn_data_status_prsnl_id = encntr_mrn_data_status_prsnl_id ,data->qual[i4qualcount ].
   encntr_mrn_encntr_alias_id = encntr_mrn_encntr_alias_id ,data->qual[i4qualcount ].
   encntr_mrn_encntr_alias_type_cd = encntr_mrn_encntr_alias_type_cd ,data->qual[i4qualcount ].
   encntr_mrn_encntr_id = encntr_mrn_encntr_id ,data->qual[i4qualcount ].
   encntr_mrn_end_effective_dt_tm = encntr_mrn_end_effective_dt_tm ,data->qual[i4qualcount ].
   encntr_mrn_updt_dt_tm = encntr_mrn_updt_dt_tm ,data->qual[i4qualcount ].encntr_mrn_updt_id =
   encntr_mrn_updt_id ,data->qual[i4qualcount ].encntr_mrn_updt_task = encntr_mrn_updt_task ,data->
   qual[i4qualcount ].org_active_ind = org_active_ind ,data->qual[i4qualcount ].org_active_status_cd
   = org_active_status_cd ,data->qual[i4qualcount ].org_active_status_dt_tm =
   org_active_status_dt_tm ,data->qual[i4qualcount ].org_active_status_prsnl_id =
   org_active_status_prsnl_id ,data->qual[i4qualcount ].org_beg_effective_dt_tm =
   org_beg_effective_dt_tm ,data->qual[i4qualcount ].org_contributor_source_cd =
   org_contributor_source_cd ,data->qual[i4qualcount ].org_contributor_system_cd =
   org_contributor_system_cd ,data->qual[i4qualcount ].org_data_status_cd = org_data_status_cd ,data
   ->qual[i4qualcount ].org_data_status_dt_tm = org_data_status_dt_tm ,data->qual[i4qualcount ].
   org_data_status_prsnl_id = org_data_status_prsnl_id ,data->qual[i4qualcount ].
   org_end_effective_dt_tm = org_end_effective_dt_tm ,data->qual[i4qualcount ].org_federal_tax_id_nbr
    = org_federal_tax_id_nbr ,data->qual[i4qualcount ].org_ft_entity_id = org_ft_entity_id ,data->
   qual[i4qualcount ].org_ft_entity_name = org_ft_entity_name ,data->qual[i4qualcount ].
   org_organization_id = org_organization_id ,data->qual[i4qualcount ].org_org_class_cd =
   org_org_class_cd ,data->qual[i4qualcount ].org_org_name = org_org_name ,data->qual[i4qualcount ].
   org_org_name_key = org_org_name_key ,data->qual[i4qualcount ].org_org_name_key_nls =
   org_org_name_key_nls ,data->qual[i4qualcount ].org_org_status_cd = org_org_status_cd ,data->qual[
   i4qualcount ].org_updt_dt_tm = org_updt_dt_tm ,data->qual[i4qualcount ].org_updt_id = org_updt_id
   ,data->qual[i4qualcount ].org_updt_task = org_updt_task ,data->qual[i4qualcount ].
   patient_abs_birth_dt_tm = patient_abs_birth_dt_tm ,data->qual[i4qualcount ].patient_active_ind =
   patient_active_ind ,data->qual[i4qualcount ].patient_active_status_cd = patient_active_status_cd ,
   data->qual[i4qualcount ].patient_active_status_dt_tm = patient_active_status_dt_tm ,data->qual[
   i4qualcount ].patient_active_status_prsnl_id = patient_active_status_prsnl_id ,data->qual[
   i4qualcount ].patient_archive_env_id = patient_archive_env_id ,data->qual[i4qualcount ].
   patient_archive_status_cd = patient_archive_status_cd ,data->qual[i4qualcount ].
   patient_archive_status_dt_tm = patient_archive_status_dt_tm ,data->qual[i4qualcount ].
   patient_autopsy_cd = patient_autopsy_cd ,data->qual[i4qualcount ].patient_beg_effective_dt_tm =
   patient_beg_effective_dt_tm ,data->qual[i4qualcount ].patient_birth_dt_cd = patient_birth_dt_cd ,
   data->qual[i4qualcount ].patient_birth_dt_tm = patient_birth_dt_tm ,data->qual[i4qualcount ].
   patient_birth_prec_flag = patient_birth_prec_flag ,data->qual[i4qualcount ].patient_birth_tz =
   patient_birth_tz ,data->qual[i4qualcount ].patient_cause_of_death = patient_cause_of_death ,data->
   qual[i4qualcount ].patient_cause_of_death_cd = patient_cause_of_death_cd ,data->qual[i4qualcount ]
   .patient_citizenship_cd = patient_citizenship_cd ,data->qual[i4qualcount ].
   patient_conception_dt_tm = patient_conception_dt_tm ,data->qual[i4qualcount ].
   patient_confid_level_cd = patient_confid_level_cd ,data->qual[i4qualcount ].
   patient_contributor_system_cd = patient_contributor_system_cd ,data->qual[i4qualcount ].
   patient_create_dt_tm = patient_create_dt_tm ,data->qual[i4qualcount ].patient_create_prsnl_id =
   patient_create_prsnl_id ,data->qual[i4qualcount ].patient_data_status_cd = patient_data_status_cd
   ,data->qual[i4qualcount ].patient_data_status_dt_tm = patient_data_status_dt_tm ,data->qual[
   i4qualcount ].patient_data_status_prsnl_id = patient_data_status_prsnl_id ,data->qual[i4qualcount
   ].patient_deceased_cd = patient_deceased_cd ,data->qual[i4qualcount ].patient_deceased_dt_tm =
   patient_deceased_dt_tm ,data->qual[i4qualcount ].patient_deceased_source_cd =
   patient_deceased_source_cd ,data->qual[i4qualcount ].patient_end_effective_dt_tm =
   patient_end_effective_dt_tm ,data->qual[i4qualcount ].patient_ethnic_grp_cd =
   patient_ethnic_grp_cd ,data->qual[i4qualcount ].patient_ft_entity_id = patient_ft_entity_id ,data
   ->qual[i4qualcount ].patient_ft_entity_name = patient_ft_entity_name ,data->qual[i4qualcount ].
   patient_language_cd = patient_language_cd ,data->qual[i4qualcount ].patient_language_dialect_cd =
   patient_language_dialect_cd ,data->qual[i4qualcount ].patient_last_accessed_dt_tm =
   patient_last_accessed_dt_tm ,data->qual[i4qualcount ].patient_last_encntr_dt_tm =
   patient_last_encntr_dt_tm ,data->qual[i4qualcount ].patient_marital_type_cd =
   patient_marital_type_cd ,data->qual[i4qualcount ].patient_military_base_location =
   patient_military_base_location ,data->qual[i4qualcount ].patient_military_rank_cd =
   patient_military_rank_cd ,data->qual[i4qualcount ].patient_military_service_cd =
   patient_military_service_cd ,data->qual[i4qualcount ].patient_mother_maiden_name =
   patient_mother_maiden_name ,data->qual[i4qualcount ].patient_name_first = patient_name_first ,data
   ->qual[i4qualcount ].patient_name_first_key = patient_name_first_key ,data->qual[i4qualcount ].
   patient_name_first_key_nls = patient_name_first_key_nls ,data->qual[i4qualcount ].
   patient_name_first_phonetic = patient_name_first_phonetic ,data->qual[i4qualcount ].
   patient_name_first_synonym_id = patient_name_first_synonym_id ,data->qual[i4qualcount ].
   patient_name_full_formatted = patient_name_full_formatted ,data->qual[i4qualcount ].
   patient_name_last = patient_name_last ,data->qual[i4qualcount ].patient_name_last_key =
   patient_name_last_key ,data->qual[i4qualcount ].patient_name_last_key_nls =
   patient_name_last_key_nls ,data->qual[i4qualcount ].patient_name_last_phonetic =
   patient_name_last_phonetic ,data->qual[i4qualcount ].patient_name_middle = patient_name_middle ,
   data->qual[i4qualcount ].patient_name_middle_key = patient_name_middle_key ,data->qual[
   i4qualcount ].patient_name_middle_key_nls = patient_name_middle_key_nls ,data->qual[i4qualcount ].
   patient_name_phonetic = patient_name_phonetic ,data->qual[i4qualcount ].patient_nationality_cd =
   patient_nationality_cd ,data->qual[i4qualcount ].patient_next_restore_dt_tm =
   patient_next_restore_dt_tm ,data->qual[i4qualcount ].patient_person_id = patient_person_id ,data->
   qual[i4qualcount ].patient_person_type_cd = patient_person_type_cd ,data->qual[i4qualcount ].
   patient_race_cd = patient_race_cd ,data->qual[i4qualcount ].patient_religion_cd =
   patient_religion_cd ,data->qual[i4qualcount ].patient_sex_age_change_ind =
   patient_sex_age_change_ind ,data->qual[i4qualcount ].patient_sex_cd = patient_sex_cd ,data->qual[
   i4qualcount ].patient_species_cd = patient_species_cd ,data->qual[i4qualcount ].patient_updt_dt_tm
    = patient_updt_dt_tm ,data->qual[i4qualcount ].patient_updt_id = patient_updt_id ,data->qual[
   i4qualcount ].patient_updt_task = patient_updt_task ,data->qual[i4qualcount ].
   patient_vet_military_status_cd = patient_vet_military_status_cd ,data->qual[i4qualcount ].
   patient_vip_cd = patient_vip_cd ,data->qual[i4qualcount ].encntr_fin_active_ind =
   encntr_fin_active_ind ,data->qual[i4qualcount ].encntr_fin_active_status_cd =
   encntr_fin_active_status_cd ,data->qual[i4qualcount ].encntr_fin_active_status_dt_tm =
   encntr_fin_active_status_dt_tm ,data->qual[i4qualcount ].encntr_fin_active_status_prsnl_id =
   encntr_fin_active_status_prsnl_id ,data->qual[i4qualcount ].encntr_fin_alias = encntr_fin_alias ,
   data->qual[i4qualcount ].encntr_fin_alias_pool_cd = encntr_fin_alias_pool_cd ,data->qual[
   i4qualcount ].encntr_fin_assign_authority_sys_cd = encntr_fin_assign_authority_sys_cd ,data->qual[
   i4qualcount ].encntr_fin_beg_effective_dt_tm = encntr_fin_beg_effective_dt_tm ,data->qual[
   i4qualcount ].encntr_fin_check_digit = encntr_fin_check_digit ,data->qual[i4qualcount ].
   encntr_fin_check_digit_method_cd = encntr_fin_check_digit_method_cd ,data->qual[i4qualcount ].
   encntr_fin_contributor_system_cd = encntr_fin_contributor_system_cd ,data->qual[i4qualcount ].
   encntr_fin_data_status_cd = encntr_fin_data_status_cd ,data->qual[i4qualcount ].
   encntr_fin_data_status_dt_tm = encntr_fin_data_status_dt_tm ,data->qual[i4qualcount ].
   encntr_fin_data_status_prsnl_id = encntr_fin_data_status_prsnl_id ,data->qual[i4qualcount ].
   encntr_fin_encntr_alias_id = encntr_fin_encntr_alias_id ,data->qual[i4qualcount ].
   encntr_fin_encntr_alias_type_cd = encntr_fin_encntr_alias_type_cd ,data->qual[i4qualcount ].
   encntr_fin_encntr_id = encntr_fin_encntr_id ,data->qual[i4qualcount ].
   encntr_fin_end_effective_dt_tm = encntr_fin_end_effective_dt_tm ,data->qual[i4qualcount ].
   encntr_fin_updt_dt_tm = encntr_fin_updt_dt_tm ,data->qual[i4qualcount ].encntr_fin_updt_id =
   encntr_fin_updt_id ,data->qual[i4qualcount ].encntr_fin_updt_task = encntr_fin_updt_task
  WITH nocounter
 ;end select
 DECLARE idx = i4
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant (20 )
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 SET cur_list_size = size (data->qual ,5 )
 SET loop_cnt = ceil ((cnvtreal (cur_list_size ) / batch_size ) )
 SET new_list_size = (loop_cnt * batch_size )
 SET stat = alterlist (data->qual ,new_list_size )
 SET nstart = 1
 FOR (idx = (cur_list_size + 1 ) TO new_list_size )
  SET data->qual[idx ].encntr_id = data->qual[cur_list_size ].encntr_id
 ENDFOR
 SET pn_ur_only_ind = 1
 SET stat = uar_get_meaning_by_codeset (14029 ,"PC" ,1 ,pf_first_pc_cd )
 IF ((pf_first_pc_cd > 0 ) )
  SET pn_ur_only_ind = 0
 ENDIF
 IF ((pn_ur_only_ind = 1 ) )
  SELECT INTO "nl:"
   volume_nbr = m.volume_nbr ,
   location = uar_get_code_display (m.current_loc_cd )
   FROM (dummyt d1 WITH seq = value (loop_cnt ) ),
    (media_encntr_reltn mer ),
    (media_master m )
   PLAN (d1
    WHERE initarray (nstart ,evaluate (d1.seq ,1 ,1 ,(nstart + batch_size ) ) ) )
    JOIN (mer
    WHERE expand (idx ,nstart ,(nstart + (batch_size - 1 ) ) ,mer.encntr_id ,data->qual[idx ].
     encntr_id )
    AND (mer.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (mer.active_ind = 1 ) )
    JOIN (m
    WHERE (m.media_master_id = mer.media_master_id )
    AND (m.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (m.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (m.active_ind = 1 ) )
   ORDER BY mer.encntr_id ,
    volume_nbr DESC
   HEAD mer.encntr_id
    gl_starting_pos = 1 ,gl_encntr_pos = 1 ,gl_loop_cnt = 0 ,
    WHILE ((gl_encntr_pos > 0 )
    AND (gl_starting_pos <= gl_data_cnt )
    AND (gl_loop_cnt <= gl_data_cnt ) )
     gl_loop_cnt = (gl_loop_cnt + 1 ) ,gl_encntr_pos = locateval (gn_index ,gl_starting_pos ,
      gl_data_cnt ,mer.encntr_id ,data->qual[gn_index ].encntr_id ) ,
     IF ((gl_encntr_pos > 0 ) ) data->qual[gl_encntr_pos ].location = location
     ENDIF
     ,gl_starting_pos = (gl_encntr_pos + 1 )
    ENDWHILE
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   volume_nbr = m.volume_nbr ,
   location = uar_get_code_display (m.current_loc_cd )
   FROM (dummyt d1 WITH seq = value (loop_cnt ) ),
    (media_master m )
   PLAN (d1
    WHERE initarray (nstart ,evaluate (d1.seq ,1 ,1 ,(nstart + batch_size ) ) ) )
    JOIN (m
    WHERE expand (idx ,nstart ,(nstart + (batch_size - 1 ) ) ,m.encntr_id ,data->qual[idx ].encntr_id
      )
    AND (m.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (m.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (m.active_ind = 1 ) )
   ORDER BY m.encntr_id ,
    volume_nbr DESC
   HEAD m.encntr_id
    gl_starting_pos = 1 ,gl_encntr_pos = 1 ,gl_loop_cnt = 0 ,
    WHILE ((gl_encntr_pos > 0 )
    AND (gl_starting_pos <= gl_data_cnt )
    AND (gl_loop_cnt <= gl_data_cnt ) )
     gl_loop_cnt = (gl_loop_cnt + 1 ) ,gl_encntr_pos = locateval (gn_index ,gl_starting_pos ,
      gl_data_cnt ,m.encntr_id ,data->qual[gn_index ].encntr_id ) ,
     IF ((gl_encntr_pos > 0 ) ) data->qual[gl_encntr_pos ].location = location
     ENDIF
     ,gl_starting_pos = (gl_encntr_pos + 1 )
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
END GO

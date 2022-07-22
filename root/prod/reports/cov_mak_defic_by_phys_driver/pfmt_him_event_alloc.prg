
DROP PROGRAM pfmt_him_event_alloc :dba GO
CREATE PROGRAM pfmt_him_event_alloc :dba
 IF ((validate (reply->status_data.status ,"Z" ) = "Z" ) )
  RECORD reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD temp
 RECORD temp (
   1 qual [* ]
     2 event_id = f8
     2 encntr_id = f8
     2 action_type_cd = f8
     2 action_status_cd = f8
     2 prsnl_id = f8
     2 event_cd = f8
     2 requested_dt_tm = dq8
     2 completed_dt_tm = dq8
 )
 FREE RECORD profiledocs
 RECORD profiledocs (
   1 qual [* ]
     2 event_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 clinical_event_id = f8
 )
 FREE RECORD add_rec
 RECORD add_rec (
   1 him_event_allocation_id = f8
   1 updt_cnt = f8
 )
 FREE RECORD write_rec
 RECORD write_rec (
   1 event_id = f8
   1 encntr_id = f8
   1 action_type_cd = f8
   1 action_status_cd = f8
   1 prsnl_id = f8
   1 event_cd = f8
   1 requested_dt_tm = dq8
   1 pending_dt_tm = dq8
   1 completed_dt_tm = dq8
 )
 DECLARE perform_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE transcribe_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE sign_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE cosign_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE modify_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE rstatus_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE pstatus_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE cstatus_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE istatus_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE x = i4 WITH public ,noconstant (0 )
 DECLARE req_size = i4 WITH public ,noconstant (0 )
 DECLARE count = i4 WITH public ,noconstant (0 )
 DECLARE inerror_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE inerrornomut_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE inerrornoview_cd = f8 WITH public ,noconstant (0.0 )
 IF ((validate (gen_nbr_error ,- (1 ) ) != 3 ) )
  DECLARE gen_nbr_error = i2 WITH protect ,noconstant (3 )
 ENDIF
 IF ((validate (insert_error ,- (1 ) ) != 4 ) )
  DECLARE insert_error = i2 WITH protect ,noconstant (4 )
 ENDIF
 IF ((validate (update_error ,- (1 ) ) != 5 ) )
  DECLARE update_error = i2 WITH protect ,noconstant (5 )
 ENDIF
 IF ((validate (replace_error ,- (1 ) ) != 6 ) )
  DECLARE replace_error = i2 WITH protect ,noconstant (6 )
 ENDIF
 IF ((validate (delete_error ,- (1 ) ) != 7 ) )
  DECLARE delete_error = i2 WITH protect ,noconstant (7 )
 ENDIF
 IF ((validate (undelete_error ,- (1 ) ) != 8 ) )
  DECLARE undelete_error = i2 WITH protect ,noconstant (8 )
 ENDIF
 IF ((validate (remove_error ,- (1 ) ) != 9 ) )
  DECLARE remove_error = i2 WITH protect ,noconstant (9 )
 ENDIF
 IF ((validate (attribute_error ,- (1 ) ) != 10 ) )
  DECLARE attribute_error = i2 WITH protect ,noconstant (10 )
 ENDIF
 IF ((validate (lock_error ,- (1 ) ) != 11 ) )
  DECLARE lock_error = i2 WITH protect ,noconstant (11 )
 ENDIF
 IF ((validate (none_found ,- (1 ) ) != 12 ) )
  DECLARE none_found = i2 WITH protect ,noconstant (12 )
 ENDIF
 IF ((validate (select_error ,- (1 ) ) != 13 ) )
  DECLARE select_error = i2 WITH protect ,noconstant (13 )
 ENDIF
 IF ((validate (insert_duplicate ,- (1 ) ) != 14 ) )
  DECLARE version_insert_error = i2 WITH protect ,noconstant (16 )
 ENDIF
 IF ((validate (uar_error ,- (1 ) ) != 20 ) )
  DECLARE uar_error = i2 WITH protect ,noconstant (20 )
 ENDIF
 IF ((validate (failed ,- (1 ) ) != 0 ) )
  DECLARE failed = i2 WITH protect ,noconstant (false )
 ENDIF
 IF ((validate (table_name ,"ZZZ" ) = "ZZZ" ) )
  DECLARE table_name = vc WITH protect ,noconstant (" " )
 ELSE
  SET table_name = fillstring (50 ," " )
 ENDIF
 IF ((validate (error_value ,"ZZZ" ) = "ZZZ" ) )
  DECLARE error_value = vc WITH protect ,noconstant (fillstring (150 ," " ) )
 ENDIF
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
 DECLARE loading_ind = i2 WITH public ,noconstant (him_loading_letters_ind )
 DECLARE failed_ind = i2 WITH public ,noconstant (0 )
 IF ((reqinfo->updt_req = - (3091000 ) ) )
  SET loading_ind = 0
  SET stat = alterlist (profiledocs->qual ,1 )
  SET profiledocs->qual[1 ].encntr_id = requestin->clin_detail_list[1 ].encntr_id
  SET profiledocs->qual[1 ].event_id = requestin->clin_detail_list[1 ].event_id
  SET profiledocs->qual[1 ].clinical_event_id = requestin->clin_detail_list[1 ].clinical_event_id
 ELSE
  SET req_size = size (requestin->clin_detail_list ,5 )
  SET failed = false
  SELECT INTO "nl:"
   hee.event_cd
   FROM (dummyt d WITH seq = value (req_size ) ),
    (encounter e ),
    (him_event_extension hee )
   PLAN (d )
    JOIN (e
    WHERE (e.encntr_id = requestin->clin_detail_list[d.seq ].encntr_id )
    AND (e.active_ind = 1 ) )
    JOIN (hee
    WHERE (hee.event_cd = requestin->clin_detail_list[d.seq ].event_cd )
    AND (hee.active_ind = 1 )
    AND (((hee.organization_id = e.organization_id ) ) OR (((hee.organization_id + 0 ) = 0 )
    AND NOT (EXISTS (
    (SELECT
     oe.organization_id
     FROM (org_event_set_reltn oe )
     WHERE (oe.organization_id = e.organization_id )
     AND (oe.active_ind = 1 ) ) ) ) )) )
   HEAD REPORT
    doc_cnt = 0
   DETAIL
    doc_cnt = (doc_cnt + 1 ) ,
    IF ((doc_cnt > size (profiledocs->qual ,5 ) ) ) stat = alterlist (profiledocs->qual ,(doc_cnt +
      9 ) )
    ENDIF
    ,profiledocs->qual[doc_cnt ].encntr_id = e.encntr_id ,
    profiledocs->qual[doc_cnt ].event_id = requestin->clin_detail_list[d.seq ].event_id ,
    profiledocs->qual[doc_cnt ].clinical_event_id = requestin->clin_detail_list[d.seq ].
    clinical_event_id ,
    profiledocs->qual[doc_cnt ].event_cd = requestin->clin_detail_list[d.seq ].event_cd
   FOOT REPORT
    stat = alterlist (profiledocs->qual ,doc_cnt )
   WITH nocounter
  ;end select
 ENDIF
 IF ((size (profiledocs->qual ,5 ) = 0 )
 AND (size (requestin->clin_detail_list ,5 ) > 0 ) )
  DELETE FROM (dummyt d WITH seq = value (size (requestin->clin_detail_list ,5 ) ) ),
    (him_event_allocation hea )
   SET hea.seq = 1
   PLAN (d )
    JOIN (hea
    WHERE (hea.event_id = requestin->clin_detail_list[d.seq ].event_id )
    AND (hea.encntr_id = requestin->clin_detail_list[d.seq ].encntr_id ) )
   WITH nocounter
  ;end delete
  GO TO check_error
 ENDIF
 IF ((loading_ind = 1 ) )
  SET table_name = "HIM_TEMP_REQUEST_LOG"
  INSERT FROM (dummyt d WITH seq = value (size (profiledocs->qual ,5 ) ) ),
    (him_temp_request_log l )
   SET l.him_temp_request_log_id = seq (profile_deficiency_seq ,nextval ) ,
    l.encntr_id = profiledocs->qual[d.seq ].encntr_id ,
    l.event_id = profiledocs->qual[d.seq ].event_id ,
    l.table_id = profiledocs->qual[d.seq ].clinical_event_id ,
    l.source_flag = 1 ,
    l.request_nbr = 3091000 ,
    l.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
    l.updt_id = reqinfo->updt_id ,
    l.updt_applctx = reqinfo->updt_applctx ,
    l.updt_task = reqinfo->updt_task
   PLAN (d )
    JOIN (l )
   WITH nocounter
  ;end insert
  IF ((curqual != size (profiledocs->qual ,5 ) ) )
   SET failed = insert_error
  ENDIF
  GO TO check_error
 ENDIF
 SET table_name = "him_event_allocation"
 SET stat = uar_get_meaning_by_codeset (103 ,"PENDING" ,1 ,pstatus_cd )
 SET stat = uar_get_meaning_by_codeset (103 ,"REQUESTED" ,1 ,rstatus_cd )
 SET stat = uar_get_meaning_by_codeset (103 ,"COMPLETED" ,1 ,cstatus_cd )
 SET stat = uar_get_meaning_by_codeset (103 ,"INERROR" ,1 ,istatus_cd )
 SET stat = uar_get_meaning_by_codeset (21 ,"SIGN" ,1 ,sign_cd )
 SET stat = uar_get_meaning_by_codeset (21 ,"COSIGN" ,1 ,cosign_cd )
 SET stat = uar_get_meaning_by_codeset (21 ,"PERFORM" ,1 ,perform_cd )
 SET stat = uar_get_meaning_by_codeset (21 ,"MODIFY" ,1 ,modify_cd )
 SET stat = uar_get_meaning_by_codeset (21 ,"TRANSCRIBE" ,1 ,transcribe_cd )
 SET stat = uar_get_meaning_by_codeset (8 ,"INERROR" ,1 ,inerror_cd )
 SET stat = uar_get_meaning_by_codeset (8 ,"INERRNOMUT" ,1 ,inerrornomut_cd )
 SET stat = uar_get_meaning_by_codeset (8 ,"INERRNOVIEW" ,1 ,inerrornoview_cd )
 SET x = 0
 IF (him_pending_signs_ind )
  SELECT INTO "nl:"
   order_id = concat (build (ce.event_id ,cep.action_prsnl_id ,cep.action_type_cd ) )
   FROM (dummyt d WITH seq = size (profiledocs->qual ,5 ) ),
    (clinical_event ce ),
    (ce_event_prsnl cep )
   PLAN (d )
    JOIN (ce
    WHERE (ce.event_id = profiledocs->qual[d.seq ].event_id )
    AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (ce.result_status_cd != inerror_cd )
    AND (ce.result_status_cd != inerrornomut_cd )
    AND (ce.result_status_cd != inerrornoview_cd ) )
    JOIN (cep
    WHERE (cep.event_id = profiledocs->qual[d.seq ].event_id )
    AND (cep.action_type_cd IN (perform_cd ,
    transcribe_cd ,
    modify_cd ,
    sign_cd ) )
    AND (cep.action_status_cd IN (pstatus_cd ,
    rstatus_cd ,
    cstatus_cd ,
    istatus_cd ) )
    AND (cep.action_prsnl_id > 0 ) )
   ORDER BY order_id ,
    cep.event_prsnl_id ,
    cep.valid_from_dt_tm ,
    cep.ce_event_prsnl_id
   HEAD order_id
    write_rec->event_id = ce.event_id ,write_rec->encntr_id = ce.encntr_id ,write_rec->event_cd = ce
    .event_cd ,write_rec->action_type_cd = cep.action_type_cd ,write_rec->prsnl_id = cep
    .action_prsnl_id ,write_rec->requested_dt_tm = cnvtdatetime ("" ) ,write_rec->pending_dt_tm =
    cnvtdatetime ("" ) ,write_rec->completed_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ,
    active_request_ind = 0 ,active_pending_ind = 0 ,write_record = 0
   HEAD cep.event_prsnl_id
    action_requested_dt_tm = cnvtdatetime ("" ) ,action_pending_dt_tm = cnvtdatetime ("" ) ,
    action_completed_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ,action_active_request_ind =
    0
   DETAIL
    CASE (cep.action_status_cd )
     OF rstatus_cd :
      action_requested_dt_tm = cnvtdatetime (cep.valid_from_dt_tm ) ,
      IF ((cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) ) )
       action_active_request_ind = 1 ,action_completed_dt_tm = cnvtdatetime (
        "31-DEC-2100 00:00:00.00" ) ,write_rec->action_status_cd = cep.action_status_cd
      ENDIF
     OF pstatus_cd :
      IF ((cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) ) ) action_pending_dt_tm =
       cnvtdatetime (cep.valid_from_dt_tm ) ,active_pending_ind = 1
      ENDIF
     OF cstatus_cd :
      IF ((action_active_request_ind = 0 ) ) action_completed_dt_tm = cnvtdatetime (cep
        .valid_from_dt_tm )
      ENDIF
      ,
      IF ((active_request_ind = 0 ) ) write_rec->action_status_cd = cep.action_status_cd
      ENDIF
     OF istatus_cd :
      action_active_request_ind = 0 ,
      action_requested_dt_tm = cnvtdatetime ("" ) ,
      action_completed_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
    ENDCASE
   FOOT  cep.event_prsnl_id
    IF ((cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (cep.action_status_cd != istatus_cd ) )
     IF ((action_requested_dt_tm > write_rec->requested_dt_tm ) ) write_rec->requested_dt_tm =
      action_requested_dt_tm ,write_record = 1
     ENDIF
     ,
     IF ((action_pending_dt_tm > write_rec->pending_dt_tm ) ) write_rec->pending_dt_tm =
      action_pending_dt_tm
     ENDIF
     ,
     IF ((action_active_request_ind = 1 ) ) active_request_ind = 1 ,write_rec->completed_dt_tm =
      cnvtdatetime ("31-DEC-2100 00:00:00.00" )
     ELSE
      IF ((active_request_ind = 0 ) )
       IF ((action_completed_dt_tm != cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
       AND (((action_completed_dt_tm > write_rec->completed_dt_tm ) ) OR ((write_rec->completed_dt_tm
        = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )) ) write_rec->completed_dt_tm =
        action_completed_dt_tm ,write_record = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT  order_id
    IF ((write_record = 1 ) ) x = (x + 1 ) ,stat = alterlist (temp->qual ,x ) ,temp->qual[x ].
     event_id = write_rec->event_id ,temp->qual[x ].encntr_id = write_rec->encntr_id ,temp->qual[x ].
     event_cd = write_rec->event_cd ,temp->qual[x ].action_type_cd = write_rec->action_type_cd ,temp
     ->qual[x ].action_status_cd = write_rec->action_status_cd ,temp->qual[x ].prsnl_id = write_rec->
     prsnl_id ,temp->qual[x ].requested_dt_tm = write_rec->requested_dt_tm ,temp->qual[x ].
     completed_dt_tm = write_rec->completed_dt_tm
    ENDIF
    ,
    IF ((active_pending_ind = 1 ) ) x = (x + 1 ) ,stat = alterlist (temp->qual ,x ) ,temp->qual[x ].
     event_id = write_rec->event_id ,temp->qual[x ].encntr_id = write_rec->encntr_id ,temp->qual[x ].
     event_cd = write_rec->event_cd ,temp->qual[x ].action_type_cd = sign_cd ,temp->qual[x ].
     action_status_cd = pstatus_cd ,temp->qual[x ].prsnl_id = write_rec->prsnl_id ,temp->qual[x ].
     requested_dt_tm = write_rec->pending_dt_tm ,temp->qual[x ].completed_dt_tm = cnvtdatetime (
      "31-DEC-2100 00:00:00.00" )
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   order_id = concat (build (ce.event_id ,cep.action_prsnl_id ,cep.action_type_cd ) )
   FROM (dummyt d WITH seq = size (profiledocs->qual ,5 ) ),
    (clinical_event ce ),
    (ce_event_prsnl cep )
   PLAN (d )
    JOIN (ce
    WHERE (ce.event_id = profiledocs->qual[d.seq ].event_id )
    AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (ce.result_status_cd != inerror_cd )
    AND (ce.result_status_cd != inerrornomut_cd )
    AND (ce.result_status_cd != inerrornoview_cd ) )
    JOIN (cep
    WHERE (cep.event_id = profiledocs->qual[d.seq ].event_id )
    AND (cep.action_type_cd IN (perform_cd ,
    transcribe_cd ,
    modify_cd ,
    sign_cd ) )
    AND (cep.action_status_cd IN (rstatus_cd ,
    cstatus_cd ,
    istatus_cd ) )
    AND (cep.action_prsnl_id > 0 ) )
   ORDER BY order_id ,
    cep.event_prsnl_id ,
    cep.valid_from_dt_tm ,
    cep.ce_event_prsnl_id
   HEAD order_id
    write_rec->event_id = ce.event_id ,write_rec->encntr_id = ce.encntr_id ,write_rec->event_cd = ce
    .event_cd ,write_rec->action_type_cd = cep.action_type_cd ,write_rec->prsnl_id = cep
    .action_prsnl_id ,write_rec->requested_dt_tm = cnvtdatetime ("" ) ,write_rec->completed_dt_tm =
    cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ,active_request_ind = 0 ,write_record = 0
   HEAD cep.event_prsnl_id
    action_requested_dt_tm = cnvtdatetime ("" ) ,action_completed_dt_tm = cnvtdatetime (
     "31-DEC-2100 00:00:00.00" ) ,action_active_request_ind = 0
   DETAIL
    CASE (cep.action_status_cd )
     OF rstatus_cd :
      action_requested_dt_tm = cnvtdatetime (cep.valid_from_dt_tm ) ,
      IF ((cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) ) )
       action_active_request_ind = 1 ,action_completed_dt_tm = cnvtdatetime (
        "31-DEC-2100 00:00:00.00" )
      ENDIF
     OF cstatus_cd :
      IF ((action_active_request_ind = 0 ) ) action_completed_dt_tm = cnvtdatetime (cep
        .valid_from_dt_tm )
      ENDIF
     OF istatus_cd :
      action_active_request_ind = 0 ,
      action_requested_dt_tm = cnvtdatetime ("" ) ,
      action_completed_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
    ENDCASE
   FOOT  cep.event_prsnl_id
    IF ((cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (cep.action_status_cd != istatus_cd ) )
     IF ((action_requested_dt_tm > write_rec->requested_dt_tm ) ) write_rec->requested_dt_tm =
      action_requested_dt_tm ,write_record = 1
     ENDIF
     ,
     IF ((action_active_request_ind = 1 ) ) active_request_ind = 1 ,write_rec->completed_dt_tm =
      cnvtdatetime ("31-DEC-2100 00:00:00.00" )
     ELSE
      IF ((active_request_ind = 0 ) )
       IF ((((action_completed_dt_tm > write_rec->completed_dt_tm ) ) OR ((write_rec->completed_dt_tm
        = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )) ) write_rec->completed_dt_tm =
        action_completed_dt_tm ,write_record = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT  order_id
    IF ((write_record = 1 ) ) x = (x + 1 ) ,stat = alterlist (temp->qual ,x ) ,temp->qual[x ].
     event_id = write_rec->event_id ,temp->qual[x ].encntr_id = write_rec->encntr_id ,temp->qual[x ].
     event_cd = write_rec->event_cd ,temp->qual[x ].action_type_cd = write_rec->action_type_cd ,temp
     ->qual[x ].prsnl_id = write_rec->prsnl_id ,temp->qual[x ].requested_dt_tm = write_rec->
     requested_dt_tm ,temp->qual[x ].completed_dt_tm = write_rec->completed_dt_tm
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (z = 1 TO size (profiledocs->qual ,5 ) )
  DELETE FROM (him_event_allocation hea )
   WHERE (hea.event_id = profiledocs->qual[z ].event_id )
   WITH nocounter
  ;end delete
 ENDFOR
 SET count = size (temp->qual ,5 )
 IF ((count > 0 ) )
  INSERT FROM (dummyt d WITH seq = value (count ) ),
    (him_event_allocation hea )
   SET hea.him_event_allocation_id = seq (profile_deficiency_seq ,nextval ) ,
    hea.event_id = temp->qual[d.seq ].event_id ,
    hea.prsnl_id = temp->qual[d.seq ].prsnl_id ,
    hea.encntr_id = temp->qual[d.seq ].encntr_id ,
    hea.event_cd = temp->qual[d.seq ].event_cd ,
    hea.action_type_cd = temp->qual[d.seq ].action_type_cd ,
    hea.action_status_cd = temp->qual[d.seq ].action_status_cd ,
    hea.request_dt_tm = cnvtdatetime (temp->qual[d.seq ].requested_dt_tm ) ,
    hea.completed_dt_tm = cnvtdatetime (temp->qual[d.seq ].completed_dt_tm ) ,
    hea.allocation_dt_tm = cnvtdatetime ("" ) ,
    hea.updt_cnt = 0 ,
    hea.active_ind = true ,
    hea.active_status_cd = reqdata->active_status_cd ,
    hea.active_status_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
    hea.active_status_prsnl_id = reqinfo->updt_id ,
    hea.beg_effective_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
    hea.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) ,
    hea.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
    hea.updt_id = reqinfo->updt_id ,
    hea.updt_applctx = reqinfo->updt_applctx ,
    hea.updt_task = reqinfo->updt_task
   PLAN (d )
    JOIN (hea )
   WITH nocounter
  ;end insert
  IF ((curqual = 0 ) )
   SET failed = insert_error
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF ((failed = false ) )
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  COMMIT
 ELSE
  ROLLBACK
  SET reply->status_data.status = "F"
  CASE (failed )
   OF gen_nbr_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "GEN_NBR"
   OF insert_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "INSERT"
   OF update_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "UPDATE"
   OF replace_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "REPLACE"
   OF delete_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "DELETE"
   OF undelete_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "UNDELETE"
   OF remove_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "REMOVE"
   OF attribute_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "ATTRIBUTE"
   OF lock_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1 ].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
END GO

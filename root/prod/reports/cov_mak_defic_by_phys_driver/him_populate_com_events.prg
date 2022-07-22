
DROP PROGRAM him_populate_com_events :dba GO
CREATE PROGRAM him_populate_com_events :dba
 SET perform_cd = 0.0
 SET transcribe_cd = 0.0
 SET sign_cd = 0.0
 SET cosign_cd = 0.0
 SET modify_cd = 0.0
 SET rstatus_cd = 0.0
 SET cstatus_cd = 0.0
 SET istatus_cd = 0.0
 SET failed = false
 SET table_name = "Him_Event_Allocation"
 DECLARE inerror_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE inerrornomut_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE inerrornoview_cd = f8 WITH public ,noconstant (0.0 )
 SET reply->status_data.status = "F"
 FREE RECORD event
 RECORD event (
   1 qual [* ]
     2 event_id = f8
 )
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
 SELECT INTO "nl:"
  c.code_value ,
  cdf = cdf_meaning
  FROM (code_value c )
  WHERE (c.code_set = 103 )
  AND (c.active_ind = 1 )
  DETAIL
   CASE (cdf )
    OF "REQUESTED" :
     rstatus_cd = c.code_value
    OF "COMPLETED" :
     cstatus_cd = c.code_value
    OF "PENDING" :
     pstatus_cd = c.code_value
    OF "INERROR" :
     istatus_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv = code_value ,
  cdf = cdf_meaning
  FROM (code_value )
  WHERE (code_set = 21 )
  AND (active_ind = 1 )
  DETAIL
   CASE (cdf )
    OF "SIGN" :
     sign_cd = cv
    OF "COSIGN" :
     cosign_cd = cv
    OF "PERFORM" :
     perform_cd = cv
    OF "MODIFY" :
     modify_cd = cv
    OF "TRANSCRIBE" :
     transcribe_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv = code_value ,
  cdf = cdf_meaning
  FROM (code_value )
  WHERE (code_set = 8 )
  AND (active_ind = 1 )
  DETAIL
   CASE (cdf )
    OF "INERROR" :
     inerror_cd = cv
    OF "INERRNOMUT" :
     inerrornomut_cd = cv
    OF "INERRNOVIEW" :
     inerrornoview_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  hea.event_id
  FROM (him_event_allocation hea )
  WHERE (hea.completed_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
  AND (hea.active_ind = 1 )
  AND (hea.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
  AND (hea.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
  ORDER BY hea.event_id
  HEAD REPORT
   event_cnt = 0
  HEAD hea.event_id
   event_cnt = (event_cnt + 1 ) ,
   IF ((event_cnt > size (event->qual ,5 ) ) ) stat = alterlist (event->qual ,(event_cnt + 9 ) )
   ENDIF
   ,event->qual[event_cnt ].event_id = hea.event_id
  FOOT REPORT
   stat = alterlist (event->qual ,event_cnt )
  WITH nocounter
 ;end select
 SET event_size = size (event->qual ,5 )
 IF ((event_size = 0 ) )
  GO TO check_error
 ENDIF
 SET start_dt_tm = cnvtdatetime (curdate ,curtime3 )
 SET offset = 0
 SET seqnum = 0
 FOR (offset = 0 TO event_size BY 5000 )
  FREE RECORD temp_insert
  RECORD temp_insert (
    1 qual [* ]
      2 event_id = f8
      2 encntr_id = f8
      2 action_type_cd = f8
      2 action_status_cd = f8
      2 prsnl_id = f8
      2 event_cd = f8
      2 requested_dt_tm = dq8
      2 completed_dt_tm = dq8
      2 event_prsnl_id = f8
      2 ce_event_prsnl_id = f8
  )
  FREE RECORD temp_sign
  RECORD temp_sign (
    1 qual [* ]
      2 event_prsnl_id = f8
      2 hea_requested_dt_tm = dq8
  )
  FREE RECORD temp_update
  RECORD temp_update (
    1 qual [* ]
      2 event_id = f8
      2 action_prsnl_id = f8
      2 action_type_cd = f8
      2 action_status_cd = f8
      2 requested_dt_tm = dq8
  )
  IF (((event_size - offset ) < 5000 ) )
   SET seqnum = (event_size - offset )
  ELSE
   SET seqnum = 5000
  ENDIF
  CALL echo ("." )
  CALL echo (". Select ACTIVE COMPLETED for INSERT and REQUESTED UPDATE" )
  CALL echo ("." )
  SELECT INTO "nl:"
   hea_event_id = hea.event_id ,
   event_id = cep.event_id ,
   event_prsnl_id = cep.event_prsnl_id ,
   ce_event_prsnl_id = cep.ce_event_prsnl_id ,
   action_prsnl_id = cep.action_prsnl_id ,
   action_type_cd = cep.action_type_cd ,
   cep.updt_cnt ,
   order_id = concat (build (cep.event_id ,cep.action_prsnl_id ,cep.action_type_cd ) )
   FROM (dummyt d WITH seq = value (seqnum ) ),
    (ce_event_prsnl cep ),
    (clinical_event ce ),
    (him_event_allocation hea )
   PLAN (d )
    JOIN (cep
    WHERE (cep.event_id = event->qual[(d.seq + offset ) ].event_id )
    AND (cep.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND ((cep.action_status_cd + 0 ) = cstatus_cd )
    AND (((him_pending_signs_ind > 0 )
    AND ((cep.action_type_cd + 0 ) IN (perform_cd ,
    transcribe_cd ,
    modify_cd ,
    sign_cd ) ) ) OR ((him_pending_signs_ind = 0 )
    AND ((cep.action_type_cd + 0 ) IN (perform_cd ,
    modify_cd ,
    sign_cd ) ) )) )
    JOIN (ce
    WHERE (ce.event_id = cep.event_id )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND ((ce.result_status_cd + 0 ) != inerror_cd )
    AND ((ce.result_status_cd + 0 ) != inerrornomut_cd )
    AND ((ce.result_status_cd + 0 ) != inerrornoview_cd ) )
    JOIN (hea
    WHERE (hea.event_id = outerjoin (cep.event_id ) )
    AND (hea.prsnl_id = outerjoin (cep.action_prsnl_id ) )
    AND (hea.action_type_cd = outerjoin (cep.action_type_cd ) ) )
   ORDER BY order_id ,
    cep.valid_from_dt_tm ,
    ce_event_prsnl_id
   HEAD REPORT
    temp_cnt = 0 ,
    sign_cnt = 0
   HEAD order_id
    IF ((hea.event_id = 0 ) ) temp_cnt = (temp_cnt + 1 ) ,
     IF ((temp_cnt > size (temp_insert->qual ,5 ) ) ) stat = alterlist (temp_insert->qual ,(temp_cnt
       + 9 ) )
     ENDIF
     ,temp_insert->qual[temp_cnt ].event_id = ce.event_id ,temp_insert->qual[temp_cnt ].encntr_id =
     ce.encntr_id ,temp_insert->qual[temp_cnt ].event_cd = ce.event_cd ,temp_insert->qual[temp_cnt ].
     action_type_cd = cep.action_type_cd ,temp_insert->qual[temp_cnt ].action_status_cd = cep
     .action_status_cd ,temp_insert->qual[temp_cnt ].prsnl_id = cep.action_prsnl_id
    ENDIF
   DETAIL
    IF ((hea.event_id = 0 ) )
     IF ((cep.valid_from_dt_tm > cnvtdatetime (temp_insert->qual[temp_cnt ].completed_dt_tm ) ) )
      temp_insert->qual[temp_cnt ].completed_dt_tm = cnvtdatetime (cep.valid_from_dt_tm ) ,
      temp_insert->qual[temp_cnt ].event_prsnl_id = cep.event_prsnl_id ,temp_insert->qual[temp_cnt ].
      ce_event_prsnl_id = cep.ce_event_prsnl_id
     ENDIF
    ENDIF
    ,
    IF ((cep.action_type_cd = sign_cd )
    AND (cep.updt_cnt > 0 ) ) sign_cnt = (sign_cnt + 1 ) ,
     IF ((sign_cnt > size (temp_sign->qual ,5 ) ) ) stat = alterlist (temp_sign->qual ,(sign_cnt + 9
       ) )
     ENDIF
     ,temp_sign->qual[sign_cnt ].event_prsnl_id = cep.event_prsnl_id ,
     IF ((hea.event_id > 0 ) ) temp_sign->qual[sign_cnt ].hea_requested_dt_tm = cnvtdatetime (hea
       .request_dt_tm )
     ELSE temp_sign->qual[sign_cnt ].hea_requested_dt_tm = cnvtdatetime (cep.valid_from_dt_tm )
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (temp_insert->qual ,temp_cnt ) ,
    stat = alterlist (temp_sign->qual ,sign_cnt )
   WITH nocounter
  ;end select
  IF ((size (temp_insert->qual ,5 ) > 0 ) )
   CALL echo ("." )
   CALL echo (". Select REQUESTED for INSERT" )
   CALL echo ("." )
   SELECT INTO "nl:"
    event_id = cep.event_id ,
    event_prsnl_id = cep.event_prsnl_id
    FROM (dummyt d WITH seq = value (size (temp_insert->qual ,5 ) ) ),
     (ce_event_prsnl cep )
    PLAN (d )
     JOIN (cep
     WHERE (cep.event_prsnl_id = temp_insert->qual[d.seq ].event_prsnl_id )
     AND ((cep.action_status_cd + 0 ) = rstatus_cd ) )
    DETAIL
     temp_insert->qual[d.seq ].requested_dt_tm = cnvtdatetime (cep.valid_from_dt_tm )
    WITH nocounter
   ;end select
   CALL echo ("." )
   CALL echo (". Insert ACTIVE COMPLETED" )
   CALL echo ("." )
   INSERT FROM (dummyt d WITH seq = value (size (temp_insert->qual ,5 ) ) ),
     (him_event_allocation hea )
    SET hea.him_event_allocation_id = seq (profile_deficiency_seq ,nextval ) ,
     hea.event_id = temp_insert->qual[d.seq ].event_id ,
     hea.prsnl_id = temp_insert->qual[d.seq ].prsnl_id ,
     hea.encntr_id = temp_insert->qual[d.seq ].encntr_id ,
     hea.event_cd = temp_insert->qual[d.seq ].event_cd ,
     hea.action_type_cd = temp_insert->qual[d.seq ].action_type_cd ,
     hea.action_status_cd = temp_insert->qual[d.seq ].action_status_cd ,
     hea.request_dt_tm = cnvtdatetime (temp_insert->qual[d.seq ].requested_dt_tm ) ,
     hea.completed_dt_tm = cnvtdatetime (temp_insert->qual[d.seq ].completed_dt_tm ) ,
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
   IF ((curqual > 0 ) )
    SET failed = false
    COMMIT
   ENDIF
  ENDIF
  IF ((size (temp_sign->qual ,5 ) > 0 ) )
   CALL echo ("." )
   CALL echo (". Select REQUESTED for UPDATE" )
   CALL echo ("." )
   SELECT INTO "nl:"
    cep.event_id ,
    cep.action_prsnl_id ,
    cep.action_status_cd ,
    cep.valid_from_dt_tm ,
    order_id = concat (build (cep.event_id ,cep.action_prsnl_id ) )
    FROM (dummyt d WITH seq = value (size (temp_sign->qual ,5 ) ) ),
     (ce_event_prsnl cep )
    PLAN (d )
     JOIN (cep
     WHERE (cep.event_prsnl_id = temp_sign->qual[d.seq ].event_prsnl_id )
     AND (cep.valid_from_dt_tm > cnvtdatetime (temp_sign->qual[d.seq ].hea_requested_dt_tm ) )
     AND ((cep.action_status_cd + 0 ) = rstatus_cd ) )
    ORDER BY order_id ,
     cep.valid_from_dt_tm ,
     cep.event_prsnl_id
    HEAD REPORT
     update_cnt = 0
    FOOT  order_id
     update_cnt = (update_cnt + 1 ) ,
     IF ((update_cnt > size (temp_update->qual ,5 ) ) ) stat = alterlist (temp_update->qual ,(
       update_cnt + 9 ) )
     ENDIF
     ,temp_update->qual[update_cnt ].event_id = cep.event_id ,temp_update->qual[update_cnt ].
     action_prsnl_id = cep.action_prsnl_id ,temp_update->qual[update_cnt ].action_type_cd = cep
     .action_type_cd ,temp_update->qual[update_cnt ].action_status_cd = cep.action_status_cd ,
     temp_update->qual[update_cnt ].requested_dt_tm = cnvtdatetime (cep.valid_from_dt_tm )
    FOOT REPORT
     stat = alterlist (temp_update->qual ,update_cnt )
    WITH nocounter
   ;end select
   IF ((size (temp_update->qual ,5 ) > 0 ) )
    CALL echo ("." )
    CALL echo (". Update REQUESTED" )
    CALL echo ("." )
    UPDATE FROM (dummyt d WITH seq = value (size (temp_update->qual ,5 ) ) ),
      (him_event_allocation hea )
     SET hea.request_dt_tm = cnvtdatetime (temp_update->qual[d.seq ].requested_dt_tm ) ,
      hea.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      hea.updt_id = reqinfo->updt_id ,
      hea.updt_applctx = reqinfo->updt_applctx ,
      hea.updt_task = reqinfo->updt_task ,
      hea.updt_cnt = (hea.updt_cnt + 1 )
     PLAN (d )
      JOIN (hea
      WHERE (hea.event_id = temp_update->qual[d.seq ].event_id )
      AND (hea.prsnl_id = temp_update->qual[d.seq ].action_prsnl_id )
      AND (hea.action_type_cd = temp_update->qual[d.seq ].action_type_cd ) )
     WITH nocounter
    ;end update
    IF ((curqual > 0 ) )
     SET failed = false
     COMMIT
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
#check_error
 FREE RECORD event
 FREE RECORD temp_insert
 FREE RECORD temp_sign
 FREE RECORD temp_update
 IF ((failed = false ) )
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
 ENDIF
END GO

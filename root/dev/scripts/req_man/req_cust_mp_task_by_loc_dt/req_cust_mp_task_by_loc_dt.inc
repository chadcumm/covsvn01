 SUBROUTINE  log_message (logmsg ,loglvl )
  SET icrslloglvloverrideind = 0
  SET scrsllogtext = ""
  SET scrsllogevent = ""
  SET scrsllogtext = concat ("{{Script::" ,value (log_program_name ) ,"}} " ,logmsg )
  IF ((log_override_ind = 0 ) )
   SET icrslholdloglevel = loglvl
  ELSE
   IF ((crsl_msg_level < loglvl ) )
    SET icrslholdloglevel = crsl_msg_level
    SET icrslloglvloverrideind = 1
   ELSE
    SET icrslholdloglevel = loglvl
   ENDIF
  ENDIF
  IF ((icrslloglvloverrideind = 1 ) )
   SET scrsllogevent = "Script_Override"
  ELSE
   CASE (icrslholdloglevel )
    OF log_level_error :
     SET scrsllogevent = "Script_Error"
    OF log_level_warning :
     SET scrsllogevent = "Script_Warning"
    OF log_level_audit :
     SET scrsllogevent = "Script_Audit"
    OF log_level_info :
     SET scrsllogevent = "Script_Info"
    OF log_level_debug :
     SET scrsllogevent = "Script_Debug"
   ENDCASE
  ENDIF
  SET lcrsluarmsgwritestat = uar_msgwrite (crsl_msg_default ,0 ,nullterm (scrsllogevent ) ,
   icrslholdloglevel ,nullterm (scrsllogtext ) )
  CALL echo (logmsg )
 END ;Subroutine
 DECLARE error_message ((logstatusblockind = i2 ) ) = i2
 SUBROUTINE  error_message (logstatusblockind )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   IF (validate (reply ) )
    SET reply->status_data.status = "F"
   ENDIF
   CALL log_message (serrmsg ,log_level_audit )
   IF ((logstatusblockind = 1 ) )
    IF (validate (reply ) )
     CALL populate_subeventstatus ("EXECUTE" ,"F" ,"CCL SCRIPT" ,serrmsg )
    ENDIF
   ENDIF
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  RETURN (icrslerroroccured )
 END ;Subroutine
 DECLARE error_and_zero_check_rec ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit
  = i2 ) ,(zeroforceexit = i2 ) ,(recorddata = vc (ref ) ) ) = i2
 SUBROUTINE  error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,
  recorddata )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   CALL log_message (serrmsg ,log_level_audit )
   CALL populate_subeventstatus_rec (opname ,"F" ,serrmsg ,logmsg ,recorddata )
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  IF ((icrslerroroccured = 1 )
  AND (errorforceexit = 1 ) )
   SET recorddata->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((qualnum = 0 )
  AND (zeroforceexit = 1 ) )
   SET recorddata->status_data.status = "Z"
   CALL populate_subeventstatus_rec (opname ,"Z" ,"No records qualified" ,logmsg ,recorddata )
   GO TO exit_script
  ENDIF
  RETURN (icrslerroroccured )
 END ;Subroutine
 DECLARE error_and_zero_check ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit = i2
  ) ,(zeroforceexit = i2 ) ) = i2
 SUBROUTINE  error_and_zero_check (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
 END ;Subroutine
 DECLARE populate_subeventstatus_rec ((operationname = vc (value ) ) ,(operationstatus = vc (value )
  ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(recorddata = vc (ref )
  ) ) = i2
 SUBROUTINE  populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,recorddata )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].operationstatus ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectname ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectvalue ) ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt = (lcrslsubeventcnt + 1 )
    SET icrslloggingstat = alter (recorddata->status_data.subeventstatus ,lcrslsubeventcnt )
   ENDIF
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationname = substring (1 ,25 ,
    operationname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationstatus = substring (1 ,1 ,
    operationstatus )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectname = substring (1 ,25
    ,targetobjectname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectvalue =
   targetobjectvalue
  ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus ((operationname = vc (value ) ) ,(operationstatus = vc (value ) ) ,(
  targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ) = i2
 SUBROUTINE  populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue ,reply )
 END ;Subroutine
 DECLARE populate_subeventstatus_msg ((operationname = vc (value ) ) ,(operationstatus = vc (value )
  ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(loglevel = i2 (value )
  ) ) = i2
 SUBROUTINE  populate_subeventstatus_msg (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,loglevel )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue
   )
  CALL log_message (targetobjectvalue ,loglevel )
 END ;Subroutine
 DECLARE check_log_level ((arg_log_level = i4 ) ) = i2
 SUBROUTINE  check_log_level (arg_log_level )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 
  SUBROUTINE  getencntrreltn (dencntr_id ,dreltn_cd ,dprov_id )
  FREE RECORD epr_qual
  RECORD epr_qual (
    1 epr_cnt = i4
    1 res_chk = i2
    1 mpage_ind = i2
    1 qual [* ]
      2 epr_id = f8
      2 prsnl_person_id = f8
  ) WITH persistscript
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr )
   PLAN (epr
    WHERE (epr.encntr_id = dencntr_id )
    AND (epr.encntr_prsnl_r_cd = dreltn_cd )
    AND (epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (epr.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (epr.active_ind = 1 ) )
   DETAIL
    epr_qual->epr_cnt = (epr_qual->epr_cnt + 1 ) ,
    stat = alterlist (epr_qual->qual ,epr_qual->epr_cnt ) ,
    epr_qual->qual[epr_qual->epr_cnt ].epr_id = epr.encntr_prsnl_reltn_id ,
    epr_qual->qual[epr_qual->epr_cnt ].prsnl_person_id = epr.prsnl_person_id ,
    IF ((dprov_id = epr.prsnl_person_id ) ) epr_qual->res_chk = true
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr )
   PLAN (epr
    WHERE (epr.encntr_id = dencntr_id )
    AND (epr.encntr_prsnl_r_cd = dreltn_cd )
    AND (epr.active_status_cd IN (48_active ,
    48_inactive ) )
    AND (epr.contributor_system_cd = 89_powerchart ) )
   DETAIL
    epr_qual->mpage_ind = true
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
 SUBROUTINE  validatefxreltn (dencntr_id ,dprov_id )
  DECLARE ep_mufx_id = f8 WITH noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (lh_mu_fx_metrics mufx ),
    (lh_mu_ep_metrics_reltn epm ),
    (br_eligible_provider bep )
   PLAN (mufx
    WHERE (mufx.encntr_id = dencntr_id ) )
    JOIN (epm
    WHERE (epm.lh_mu_fx_metrics_id = mufx.lh_mu_fx_metrics_id ) )
    JOIN (bep
    WHERE (bep.br_eligible_provider_id = epm.br_eligible_provider_id )
    AND (bep.provider_id = dprov_id ) )
   DETAIL
    ep_mufx_id = epm.lh_mu_ep_metrics_reltn_id
   WITH nocounter
  ;end select
  RETURN (ep_mufx_id )
 END ;Subroutine
 SUBROUTINE  validatefx2reltn (dencntr_id ,dprov_id )
  DECLARE ep_mufx2_id = f8 WITH noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (lh_mu_fx_2_metrics mufx2 ),
    (lh_mu_fx_2_ep_reltn epm2 ),
    (br_eligible_provider bep )
   PLAN (mufx2
    WHERE (mufx2.encntr_id = dencntr_id )
    AND (mufx2.parent_entity_name = "ENCOUNTER" )
    AND (mufx2.lh_mu_fx_2_metrics_id != 0 ) )
    JOIN (epm2
    WHERE (epm2.lh_mu_fx_2_metrics_id = mufx2.lh_mu_fx_2_metrics_id ) )
    JOIN (bep
    WHERE (bep.br_eligible_provider_id = epm2.br_eligible_provider_id )
    AND (bep.provider_id = dprov_id ) )
   DETAIL
    ep_mufx2_id = epm2.lh_mu_fx_2_ep_reltn_id
   WITH nocounter
  ;end select
  RETURN (ep_mufx2_id )
 END ;Subroutine
 SUBROUTINE  validatecustomsettings (codeset ,encntrid ,cve_fieldparse )
  DECLARE validateoutcome = vc
  SET cveparser = concat ("cnvtupper(cve.field_name)= cnvtupper('" ,trim (cve_fieldparse ) ,"')" )
  SELECT INTO "nl:"
   cv_type = evaluate2 (
    IF ((cnvtupper (cv.cdf_meaning ) = "LOG_DOMAIN" ) ) 1
    ELSEIF ((cnvtupper (cv.cdf_meaning ) = "ORG" ) ) 2
    ELSEIF ((cnvtupper (cv.cdf_meaning ) = "LOC" ) ) 3
    ENDIF
    )
   FROM (encounter e ),
    (code_value cv ),
    (code_value_extension cve )
   PLAN (e
    WHERE (e.encntr_id = encntrid ) )
    JOIN (cv
    WHERE (cv.code_set = codeset )
    AND (cv.active_ind = 1 )
    AND (cv.cdf_meaning IN ("LOC" ,
    "ORG" ,
    "LOG_DOMAIN" ) )
    AND (((cnvtreal (cv.definition ) = e.organization_id ) ) OR ((((cnvtreal (cv.definition ) = e
    .loc_nurse_unit_cd ) ) OR ((cnvtreal (cv.definition ) =
    (SELECT
     org.logical_domain_id
     FROM (organization org )
     WHERE (org.organization_id = e.organization_id ) ) ) )) )) )
    JOIN (cve
    WHERE (cve.code_value = cv.code_value )
    AND parser (cveparser ) )
   ORDER BY cv_type
   HEAD cv_type
    null
   DETAIL
    IF ((isnumeric (cve.field_value ) = 1 ) ) validateoutcome = trim (cnvtstring (cve.field_value )
      )
    ELSE validateoutcome = trim (cve.field_value )
    ENDIF
   WITH nocounter
  ;end select
  RETURN (validateoutcome )
 END ;Subroutine
  SUBROUTINE  gathercomponentsettings (parentid )
  CALL log_message ("In gatherComponentSettings()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET position_bedrock_settings = 0
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_report br ),
    (br_datamart_report_filter_r bfr ),
    (br_datamart_filter bf ),
    (br_datamart_value bv ),
    (br_datamart_flex bx )
   PLAN (bdc
    WHERE (bdc.category_mean = "MP_CUSTOM_AMB_VIEW" ) )
    JOIN (br
    WHERE (br.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (br.report_mean IN ("MP_CUSTOM_AMB_VIEW_TASKS" ,
    "MP_CUSTOM_AMB_VIEW_PAGE" ) ) )
    JOIN (bfr
    WHERE (bfr.br_datamart_report_id = br.br_datamart_report_id ) )
    JOIN (bf
    WHERE (bf.br_datamart_filter_id = bfr.br_datamart_filter_id ) )
    JOIN (bv
    WHERE (bv.br_datamart_category_id = bf.br_datamart_category_id )
    AND (bv.br_datamart_filter_id = bf.br_datamart_filter_id ) )
    JOIN (bx
    WHERE (bx.br_datamart_flex_id = bv.br_datamart_flex_id )
    AND (bx.parent_entity_id = parentid ) )
   ORDER BY bf.filter_mean ,
    bv.value_seq ,
    bv.br_datamart_value_id
   HEAD REPORT
    a_status = 0 ,
    form_cnt = 0
   DETAIL
    CASE (bf.filter_mean )
     OF "AMB_VIEW_TASK_ACTIVE_TYPES" :
      a_status = (a_status + 1 ) ,
      stat = alterlist (task_stat->slist ,a_status ) ,
      task_stat->slist[a_status ].status_cd = bv.parent_entity_id ,
      task_stat->slist[a_status ].status = "Active"
     OF "AMB_VIEW_TASK_ADHOC_DISP" :
      record_data->form_ind = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_ADHOC_FORMS" :
      form_cnt = (form_cnt + 1 ) ,
      stat = alterlist (record_data->formslist ,form_cnt ) ,
      record_data->formslist[form_cnt ].form_id = bv.parent_entity_id
     OF "AMB_VIEW_TASK_CANCEL_TYPES" :
      a_status = (a_status + 1 ) ,
      stat = alterlist (task_stat->slist ,a_status ) ,
      task_stat->slist[a_status ].status_cd = bv.parent_entity_id ,
      task_stat->slist[a_status ].status = "Discontinued"
     OF "AMB_VIEW_TASK_COMPL_TYPES" :
      a_status = (a_status + 1 ) ,
      stat = alterlist (task_stat->slist ,a_status ) ,
      task_stat->slist[a_status ].status_cd = bv.parent_entity_id ,
      task_stat->slist[a_status ].status = "Complete"
     OF "AMB_VIEW_TASK_ENC_TYPES" :
      IF ((encntr_type_parser = "1=1" ) ) encntr_type_parser = concat (trim (cnvtstring (bv
          .parent_entity_id ) ,3 ) ,".00" )
      ELSE encntr_type_parser = concat (encntr_type_parser ,"," ,trim (cnvtstring (bv
          .parent_entity_id ) ,3 ) ,".00" )
      ENDIF
     OF "AMB_VIEW_TASK_INFO" :
      record_data->task_info_text = trim (bv.freetext_desc )
     OF "AMB_VIEW_TASK_TASK_TYPES" :
      IF ((task_type_parser = "1=1" ) ) task_type_parser = concat (trim (cnvtstring (bv
          .parent_entity_id ) ,3 ) ,".00" )
      ELSE task_type_parser = concat (task_type_parser ,"," ,trim (cnvtstring (bv.parent_entity_id )
         ,3 ) ,".00" )
      ENDIF
     OF "AMB_VIEW_TASK_REQPRINT_DISP" :
      record_data->allow_req_print = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_AUTOSPEC_LOGIN" :
      record_data->autolog_spec_ind = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_MPTL_DEPART" :
      record_data->allow_depart = cnvtint (bv.freetext_desc )
     OF "AMB_VIEW_TASK_DEPART_LABEL" :
      record_data->depart_label = trim (bv.freetext_desc )
     OF "AMB_VIEW_ADV_PRINT" :
      record_data->adv_print_ind = cnvtint (trim (bv.freetext_desc ) )
     OF "AMB_VIEW_ADV_PRINT_CSET" :
      record_data->adv_print_codeset = cnvtreal (trim (bv.freetext_desc ) )
    ENDCASE
   WITH nocounter
  ;end select
  IF ((cnvtint (curqual ) > 0 ) )
   SET position_bedrock_settings = 1
  ENDIF
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_GET" ,"gatherComponentSettings" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit gatherComponentSettings(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherpagecomponentsettings (parentid )
  CALL log_message ("In gatherPageComponentSettings()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET position_bedrock_settings = 0
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_report br ),
    (br_datamart_report_filter_r bfr ),
    (br_datamart_filter bf ),
    (br_datamart_value bv ),
    (br_datamart_flex bx )
   PLAN (bdc
    WHERE (bdc.category_mean = "MP_CUSTOM_AMB_VIEW" ) )
    JOIN (br
    WHERE (br.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (br.report_mean = "MP_CUSTOM_AMB_VIEW_PAGE" ) )
    JOIN (bfr
    WHERE (bfr.br_datamart_report_id = br.br_datamart_report_id ) )
    JOIN (bf
    WHERE (bf.br_datamart_filter_id = bfr.br_datamart_filter_id ) )
    JOIN (bv
    WHERE (bv.br_datamart_category_id = bf.br_datamart_category_id )
    AND (bv.br_datamart_filter_id = bf.br_datamart_filter_id ) )
    JOIN (bx
    WHERE (bx.br_datamart_flex_id = bv.br_datamart_flex_id )
    AND (bx.parent_entity_id = parentid ) )
   ORDER BY bf.filter_mean ,
    bv.value_seq ,
    bv.br_datamart_value_id
   DETAIL
    CASE (bf.filter_mean )
     OF "AMB_VIEW_ORDER_REQ_PRINT" :
      record_data->labreq_prg = trim (bv.freetext_desc )
     OF "AMB_VIEW_ADV_PRINT" :
      record_data->adv_print_ind = cnvtint (trim (bv.freetext_desc ) )
     OF "AMB_VIEW_ADV_PRINT_CSET" :
      record_data->adv_print_codeset = cnvtreal (trim (bv.freetext_desc ) )
    ENDCASE
   WITH nocounter
  ;end select
  IF ((cnvtint (curqual ) > 0 ) )
   SET position_bedrock_settings = 1
  ENDIF
  CALL log_message (build ("Exit gatherPageComponentSettings(), Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 
 SUBROUTINE  gatherorderdiags (dummy )
  CALL log_message ("In GatherOrderDiags()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SELECT INTO "nl:"
   FROM (dummyt d1 WITH seq = size (record_data->tlist ,5 ) ),
    (dcp_entity_reltn der ),
    (diagnosis d ),
    (nomenclature n )
   PLAN (d1
    WHERE (record_data->tlist[d1.seq ].task_type_ind != 3 )
    AND (d1.seq > 0 ) )
    JOIN (der
    WHERE (der.entity1_id = record_data->tlist[d1.seq ].order_id_real )
    AND (der.active_ind = 1 )
    AND (der.entity_reltn_mean = "ORDERS/DIAGN" ) )
    JOIN (d
    WHERE (d.diagnosis_id = der.entity2_id ) )
    JOIN (n
    WHERE (n.nomenclature_id = outerjoin (d.nomenclature_id ) ) )
   ORDER BY d1.seq ,
    der.rank_sequence
   HEAD d1.seq
    dcnt = 0
   DETAIL
    dcnt = (dcnt + 1 ) ,
    stat = alterlist (record_data->tlist[d1.seq ].dlist ,dcnt ) ,
    record_data->tlist[d1.seq ].dlist[dcnt ].rank_seq = cnvtstring (der.rank_sequence ) ,
    IF ((d.nomenclature_id = 0.0 )
    AND (d.diag_ftdesc != " " ) ) record_data->tlist[d1.seq ].dlist[dcnt ].diag = trim (d
      .diag_ftdesc )
    ELSE record_data->tlist[d1.seq ].dlist[dcnt ].diag = trim (d.diagnosis_display )
    ENDIF
    ,
    IF ((n.source_identifier != " " ) ) record_data->tlist[d1.seq ].dlist[dcnt ].code = trim (n
      .source_identifier )
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherOrderDiags" ,1 ,0 ,
   record_data )
  SELECT INTO "nl:"
   FROM (dummyt d1 WITH seq = size (record_data->tlist ,5 ) ),
    (dummyt d2 WITH seq = 1 ),
    (dcp_entity_reltn der ),
    (diagnosis d ),
    (nomenclature n )
   PLAN (d1
    WHERE (record_data->tlist[d1.seq ].task_type_ind = 3 )
    AND maxrec (d2 ,record_data->tlist[d1.seq ].order_cnt ) )
    JOIN (d2
    WHERE (d2.seq > 0 ) )
    JOIN (der
    WHERE (der.entity1_id = record_data->tlist[d1.seq ].olist[d2.seq ].order_id )
    AND (der.active_ind = 1 )
    AND (der.entity_reltn_mean = "ORDERS/DIAGN" ) )
    JOIN (d
    WHERE (d.diagnosis_id = der.entity2_id ) )
    JOIN (n
    WHERE (n.nomenclature_id = outerjoin (d.nomenclature_id ) ) )
   ORDER BY d1.seq ,
    d2.seq ,
    der.rank_sequence
   HEAD d1.seq
    dcnt = 0
   HEAD d2.seq
    dcnt = 0
   HEAD d.diagnosis_id
    dcnt = (dcnt + 1 ) ,stat = alterlist (record_data->tlist[d1.seq ].olist[d2.seq ].dlist ,dcnt ) ,
    record_data->tlist[d1.seq ].olist[d2.seq ].dlist[dcnt ].rank_seq = cnvtstring (der.rank_sequence
     ) ,
    IF ((d.nomenclature_id = 0.0 )
    AND (d.diag_ftdesc != " " ) ) record_data->tlist[d1.seq ].olist[d2.seq ].dlist[dcnt ].diag =
     trim (d.diag_ftdesc )
    ELSE record_data->tlist[d1.seq ].olist[d2.seq ].dlist[dcnt ].diag = trim (d.diagnosis_display )
    ENDIF
    ,
    IF ((n.source_identifier != " " ) ) record_data->tlist[d1.seq ].olist[d2.seq ].dlist[dcnt ].code
     = trim (n.source_identifier )
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_REFLAB_GET" ,"GatherOrderDiags" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit GatherOrderDiags(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
  SUBROUTINE  gathertasktypes (dummy )
  CALL log_message ("In GatherTaskTypes()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  /*
  SELECT INTO "nl:"
   type_name = trim (replace (cv.display ,"* " ,"" ,0 ) )
   FROM (code_value cv )
   WHERE (cv.code_set = 6026 )
   AND (cv.active_ind = 1 )
   AND (cv.cdf_meaning IN ("CLINPHARM" ,
   "INFUSEBILL" ,
   "MEDRECON" ,
   "NURSECOL" ,
   "RESPONSE" ,
   "PERSONAL" ,
   "SURGERY" ,
   "ASSESS" ,
   "PATCARE" ,
   "IV" ,
   "MED" ,
   "RAD" ,
   "LAB" ,
   "ANCILLARY" ) )
   AND parser (task_type_cv_parser )
   ORDER BY type_name
   HEAD REPORT
    tycnt = 0
   DETAIL
    tycnt = (tycnt + 1 ) ,
    stat = alterlist (record_data->type_list ,tycnt ) ,
    record_data->type_list[tycnt ].type = type_name ,
    record_data->type_list[tycnt ].selected = 0
   WITH nocounter
  ;end select
  */
  
 	select distinct
		cv1.display
	from
		code_value cv1
	plan cv1
	where cv1.code_set = 103507
	and   cv1.cdf_meaning = "REQUISITION"
	and	  cv1.active_ind = 1
	order by
		cv1.display
	head report
		tycnt = 0; size(record_data->type_list,5)
	head cv1.display
		tycnt = (tycnt + 1 ) ,
    	stat = alterlist (record_data->type_list ,tycnt ) ,
    	record_data->type_list[tycnt ].type =trim(cv1.display) ,
    	record_data->type_list[tycnt ].selected = 1
    	call echo(build("->adding requisition type=",trim(c1.display)))
	with nocounter
	CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherTaskTypes" ,1 ,0 ,record_data )
 	 CALL log_message (build ("Exit GatherTaskTypes(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 
 END ;Subroutine
 
  SUBROUTINE  gatheruserprefs (prsnl_id ,pref_id )
  CALL log_message ("In GatherUserPrefs()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET user_pref_string = ""
  SET user_pref_found = 0
  SELECT INTO "nl:"
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id = prsnl_id ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name = pref_id ) )
   ORDER BY n.sequence
   DETAIL
    user_pref_found = 1 ,
    user_pref_string = concat (user_pref_string ,trim (n.pvc_value ) )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherUserPrefs" ,1 ,0 , record_data )
  CALL log_message (build ("Exit GatherUserPrefs(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherpowerformname (dummy )
  CALL log_message ("In GatherPowerFormName()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SELECT INTO "nl:"
   FROM (dcp_forms_ref dfr ),
    (dummyt d WITH seq = size (record_data->formslist ,5 ) )
   PLAN (d )
    JOIN (dfr
    WHERE (dfr.dcp_forms_ref_id = record_data->formslist[d.seq ].form_id )
    AND (dfr.active_ind = 1 ) )
   DETAIL
    record_data->formslist[d.seq ].form_name = trim (dfr.definition )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherPowerFormName" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit GatherPowerFormName(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatheruserlockedchartsaccess (userid )
  CALL log_message ("In GatherUserLockedChartsAccess()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SELECT INTO "nl:"
   FROM (prsnl_org_reltn por ),
    (location l )
   PLAN (l
    WHERE (l.location_cd >  $LOC_PROMPT ) )
    JOIN (por
    WHERE (por.person_id = userid )
    AND (por.organization_id = l.organization_id )
    AND ((por.end_effective_dt_tm + 0 ) > sysdate )
    AND (por.active_ind = 1 ) )
   DETAIL
    confid_level = uar_get_collation_seq (por.confid_level_cd )
   WITH nocounter
 
  ;end select
  CALL log_message (build ("confid level " ,cnvtstring (confid_level ) ) ,log_level_debug )
  CALL error_and_zero_check_rec (curqual ,"REQ_CUST_MP_TASK_BY_LOC_DT_GET" ,
   "GatherUserLockedChartsAccess" ,1 ,0 ,record_data )
  CALL log_message (build ("Exit GatherUserLockedChartsAccess(), Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  gathernotdonereason (resultid )
  CALL log_message ("In GatherNotDoneReason()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET not_done_reason = ""
  SET not_done_reason_comm = ""
  SELECT INTO "nl:"
   blob_contents = l.long_blob
   FROM (ce_result_set_link cr ),
    (clinical_event ce ),
    (left
    JOIN ce_event_note c ON (c.event_id = ce.event_id ) ),
    (left
    JOIN long_blob l ON (l.parent_entity_id = c.ce_event_note_id )
    AND (l.parent_entity_name = "CE_EVENT_NOTE" ) )
   PLAN (cr
    WHERE (cr.result_set_id = resultid ) )
    JOIN (ce
    WHERE (cr.event_id = ce.event_id )
    AND (ce.result_status_cd != inerror )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ce.event_title_text != "Date\Time correction" )
    AND (ce.view_level = 1 )
    AND (ce.publish_flag = 1 ) )
    JOIN (c )
    JOIN (l )
   ORDER BY ce.event_end_dt_tm DESC
   HEAD REPORT
    goodblob = fillstring (1000 ," " ) ,
    xlen = 0
   DETAIL
    not_done_reason = trim (ce.result_val ) ,
    IF ((l.long_blob_id > 0 ) )
     IF ((c.compression_cd = ocfcomp_cd ) ) blob_out = fillstring (1000 ," " ) ,blob_out2 =
      fillstring (1000 ," " ) ,blob_ret_len = 0 ,
      CALL uar_ocf_uncompress (blob_contents ,1000 ,blob_out ,1000 ,blob_ret_len ) ,
      CALL uar_rtf (blob_out ,textlen (blob_out ) ,blob_out2 ,32000 ,32000 ,0 ) ,xlen = (findstring (
       "ocf_blob" ,blob_out2 ,1 ) - 1 ) ,
      IF ((xlen > 0 ) ) goodblob = notrim (substring (1 ,xlen ,blob_out2 ) ) ,not_done_reason_comm =
       goodblob
      ELSE not_done_reason_comm = blob_out2
      ENDIF
     ELSE blob_out2 = fillstring (32000 ," " ) ,
      CALL uar_rtf (blob_contents ,textlen (blob_contents ) ,blob_out2 ,32000 ,32000 ,0 ) ,xlen = (
      findstring ("ocf_blob" ,blob_out2 ,1 ) - 1 ) ,
      IF ((xlen > 0 ) ) goodblob = notrim (substring (1 ,xlen ,blob_out2 ) ) ,not_done_reason_comm =
       goodblob
      ELSE not_done_reason_comm = blob_out2
      ENDIF
      ,not_done_reason_comm = goodblob
     ENDIF
    ENDIF
   WITH nocounter ,maxrec = 1
  ;end select
  CALL log_message (build ("ExitGatherNotDoneReason(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherchartedforms (eventid )
  CALL log_message ("In GatherChartedForms()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET charted_form_id = 0.0
  SELECT INTO "nl:"
   FROM (clinical_event ce ),
    (dcp_forms_activity_comp dfac )
   PLAN (ce
    WHERE (ce.event_id = eventid )
    AND (ce.result_status_cd != inerror )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ce.event_title_text != "Date\Time correction" )
    AND (ce.view_level = 1 )
    AND (ce.publish_flag = 1 ) )
    JOIN (dfac
    WHERE (dfac.parent_entity_id = ce.parent_event_id )
    AND (dfac.parent_entity_name = "CLINICAL_EVENT" ) )
   DETAIL
    charted_form_id = dfac.dcp_forms_activity_id
   WITH nocounter ,maxrec = 1
  ;end select
  CALL log_message (build ("Exit GatherChartedForms(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
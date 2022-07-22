
DROP PROGRAM bed_aud_clinrpt_distributions :dba GO
CREATE PROGRAM bed_aud_clinrpt_distributions :dba
 DECLARE setdistdetails ((d = i4 ) ) = i4
 DECLARE setoperationdetails ((d = i4 ) ,(r = i4 ) ) = i4
 DECLARE is_logical_domain_enabled_ind = i2 WITH noconstant (0 )
 DECLARE personnel_logical_domain_id = f8 WITH noconstant (0.0 )
 DECLARE param_cr_req = i4 WITH constant (1370045 )
 DECLARE param_ch_req = i4 WITH constant (1300018 )
 DECLARE param_cr_prcs = i4 WITH constant (1300028 )
 DECLARE param_cp_prcs = i4 WITH constant (1300008 )
 IF (NOT (validate (request ,0 ) ) )
  RECORD request (
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist [* ]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist [* ]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF (NOT (validate (reply ,0 ) ) )
  RECORD reply (
    1 collist [* ]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist [* ]
      2 celllist [* ]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist [* ]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD distributions
 RECORD distributions (
   1 dist [* ]
     2 dist_id = f8
     2 description = vc
     2 dist_type_flag = i4
     2 days_till_chart = i4
     2 banner_page = vc
     2 reader_group = vc
     2 cutoff_ind = i4
     2 cutoff_ind_str = vc
     2 cutoff_pages = i4
     2 cutoff_days = i4
     2 initial_lookback_ind = i4
     2 initial_lookback_days = i4
     2 initial_lookback_date = dq8
     2 absolute_lookback_ind = i4
     2 absolute_lookback_days = i4
     2 absolute_lookback_date = dq8
     2 first_lookback_ind = i4
     2 first_lookback_days = i4
     2 first_lookback_date = dq8
     2 first_lookback_str = vc
     2 incl_excl_encntr_type = i2
     2 encntr_types [* ]
       3 description = vc
     2 incl_excl_client = i2
     2 clients [* ]
       3 description = vc
     2 incl_excl_provider = i2
     2 providers [* ]
       3 description = vc
       3 reltns [* ]
         4 display = vc
     2 incl_excl_location = i2
     2 locations [* ]
       3 description = vc
     2 incl_excl_med_service = i2
     2 med_services [* ]
       3 description = vc
     2 related_ops [* ]
       3 operations_id = f8
       3 batch_name = vc
       3 run_type_display = vc
       3 scope_flag = i2
       3 sort_seq_display = vc
       3 print_finals_ind = i2
       3 chart_format_id = f8
       3 chart_format_desc = vc
       3 dist_routing_flag = i2
       3 default_chart_ind = i2
       3 default_printer_id = f8
       3 default_printer_name = vc
       3 expire_ind = i2
       3 file_storage_display = vc
       3 activity_holds [* ]
         4 display = vc
       3 ord_stat_holds [* ]
         4 display = vc
       3 order_prov_flag = i2
       3 copy_to_prov_types [* ]
         4 code_value = f8
         4 display = vc
       3 incl_excl_providers = i2
       3 provider_routings [* ]
         4 name = vc
       3 related_jobs [* ]
         4 ops_task_id = f8
         4 journal_step_exists_ind = i2
         4 frequency_flag = i4
         4 day_interval = i4
         4 time_ind = i2
         4 time_interval = i4
         4 time_interval_ind = i2
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 days_of_week [* ]
           5 day_of_week = i4
         4 days_of_month [* ]
           5 day_of_month = i4
         4 months_of_year [* ]
           5 month_of_year = i4
         4 weeks_of_month [* ]
           5 week_of_month = i4
         4 ops_job_name = vc
         4 ops_task_name = vc
       3 report_template_desc = vc
       3 op_law_id = f8
       3 law_id = f8
       3 law_name = vc
       3 law_lookback = i4
       3 law_lookback_type = vc
       3 incl_excl_encntr_type = i2
       3 encntr_types [* ]
         4 description = vc
       3 incl_excl_client = i2
       3 clients [* ]
         4 description = vc
       3 incl_excl_provider = i2
       3 providers [* ]
         4 description = vc
         4 reltns [* ]
           5 display = vc
       3 incl_excl_location = i2
       3 locations [* ]
         4 description = vc
       3 incl_excl_med_service = i2
       3 med_services [* ]
         4 description = vc
       3 filename = vc
       3 filename_mask = f8
       3 network_file_dest = vc
       3 ftp_dest = vc
 )
 IF (NOT (validate (error_flag ) ) )
  DECLARE error_flag = vc WITH protect ,noconstant ("N" )
 ENDIF
 IF (NOT (validate (ierrcode ) ) )
  DECLARE ierrcode = i4 WITH protect ,noconstant (0 )
 ENDIF
 IF (NOT (validate (serrmsg ) ) )
  DECLARE serrmsg = vc WITH protect ,noconstant ("" )
 ENDIF
 IF (NOT (validate (discerncurrentversion ) ) )
  DECLARE discerncurrentversion = i4 WITH constant (cnvtint (build (currev ,currevminor ,
     currevminor2 ) ) )
 ENDIF
 IF ((validate (bedbeginscript ,char (128 ) ) = char (128 ) ) )
  DECLARE bedbeginscript ((dummyvar = i2 ) ) = null
  SUBROUTINE  bedbeginscript (dummyvar )
   SET reply->status_data.status = "F"
   SET serrmsg = fillstring (132 ," " )
   SET ierrcode = error (serrmsg ,1 )
   SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF ((validate (bederror ,char (128 ) ) = char (128 ) ) )
  DECLARE bederror ((errordescription = vc ) ) = null
  SUBROUTINE  bederror (errordescription )
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = errordescription
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF ((validate (bedexitsuccess ,char (128 ) ) = char (128 ) ) )
  DECLARE bedexitsuccess ((dummyvar = i2 ) ) = null
  SUBROUTINE  bedexitsuccess (dummyvar )
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF ((validate (bederrorcheck ,char (128 ) ) = char (128 ) ) )
  DECLARE bederrorcheck ((errordescription = vc ) ) = null
  SUBROUTINE  bederrorcheck (errordescription )
   SET ierrcode = error (serrmsg ,1 )
   IF ((ierrcode > 0 ) )
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
    CALL bederror (errordescription )
   ENDIF
  END ;Subroutine
 ENDIF
 IF ((validate (bedexitscript ,char (128 ) ) = char (128 ) ) )
  DECLARE bedexitscript ((commitind = i2 ) ) = null
  SUBROUTINE  bedexitscript (commitind )
   CALL bederrorcheck ("Descriptive error message not provided." )
   IF ((error_flag = "N" ) )
    SET reply->status_data.status = "S"
    IF (commitind )
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind )
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
   CALL echorecord (reply )
  END ;Subroutine
 ENDIF
 IF ((validate (bedlogmessage ,char (128 ) ) = char (128 ) ) )
  DECLARE bedlogmessage ((subroutinename = vc ) ,(message = vc ) ) = null
  SUBROUTINE  bedlogmessage (subroutinename ,message )
   CALL echo ("==================================================================" )
   CALL echo (build2 (curprog ," : " ,subroutinename ,"() :" ,message ) )
   CALL echo ("==================================================================" )
  END ;Subroutine
 ENDIF
 IF ((validate (bedgetlogicaldomain ,char (128 ) ) = char (128 ) ) )
  DECLARE bedgetlogicaldomain ((dummyvar = i2 ) ) = null
  SUBROUTINE  bedgetlogicaldomain (dummyvar )
   DECLARE logicaldomainid = f8 WITH protect ,noconstant (0 )
   IF ((validate (ld_concept_person ) = 0 ) )
    DECLARE ld_concept_person = i2 WITH public ,constant (1 )
   ENDIF
   IF ((validate (ld_concept_prsnl ) = 0 ) )
    DECLARE ld_concept_prsnl = i2 WITH public ,constant (2 )
   ENDIF
   IF ((validate (ld_concept_organization ) = 0 ) )
    DECLARE ld_concept_organization = i2 WITH public ,constant (3 )
   ENDIF
   IF ((validate (ld_concept_healthplan ) = 0 ) )
    DECLARE ld_concept_healthplan = i2 WITH public ,constant (4 )
   ENDIF
   IF ((validate (ld_concept_alias_pool ) = 0 ) )
    DECLARE ld_concept_alias_pool = i2 WITH public ,constant (5 )
   ENDIF
   IF ((validate (ld_concept_minvalue ) = 0 ) )
    DECLARE ld_concept_minvalue = i2 WITH public ,constant (1 )
   ENDIF
   IF ((validate (ld_concept_maxvalue ) = 0 ) )
    DECLARE ld_concept_maxvalue = i2 WITH public ,constant (5 )
   ENDIF
   RECORD acm_get_curr_logical_domain_req (
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep (
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain WITH replace ("REQUEST" ,acm_get_curr_logical_domain_req ) ,
   replace ("REPLY" ,acm_get_curr_logical_domain_rep )
   SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
   RETURN (logicaldomainid )
  END ;Subroutine
 ENDIF
 SUBROUTINE  logdebugmessage (message_header ,message )
  IF ((validate (debug ,0 ) = 1 ) )
   CALL bedlogmessage (message_header ,message )
  ENDIF
  RETURN (true )
 END ;Subroutine
 IF ((validate (bedgetexpandind ,char (128 ) ) = char (128 ) ) )
  DECLARE bedgetexpandind ((_reccnt = i4 (value ) ) ,(_bindcnt = i4 (value ,200 ) ) ) = i2
  SUBROUTINE  bedgetexpandind (_reccnt ,_bindcnt )
   DECLARE nexpandval = i4 WITH noconstant (1 )
   IF ((discerncurrentversion >= 8102 ) )
    SET nexpandval = 2
   ENDIF
   RETURN (evaluate (floor (((_reccnt - 1 ) / _bindcnt ) ) ,0 ,0 ,nexpandval ) )
  END ;Subroutine
 ENDIF
 CALL bedbeginscript (0 )
 SET order_doc_cd = 0.0
 SELECT INTO "NL:"
  FROM (code_value cv )
  WHERE (cv.cdf_meaning = "ORDERDOC" )
  AND (cv.code_set = 333 )
  AND (cv.active_ind = 1 )
  DETAIL
   order_doc_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dm_info d )
  WHERE (d.info_domain = "CLINICAL REPORTING XR" )
  AND (d.info_name = "Enable Logical Domain XR Dist" )
  DETAIL
   is_logical_domain_enabled_ind = d.info_number
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p.logical_domain_id
  FROM (prsnl p )
  WHERE (p.person_id = reqinfo->updt_id )
  DETAIL
   personnel_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind = 0 ) )
  SELECT INTO "NL:"
   FROM (chart_distribution cd ),
    (charting_operations co )
   PLAN (cd
    WHERE (cd.active_ind = 1 ) )
    JOIN (co
    WHERE (co.param = outerjoin (cnvtstring (cd.distribution_id ) ) )
    AND (co.param_type_flag = outerjoin (2 ) )
    AND (co.active_ind = outerjoin (1 ) ) )
   ORDER BY cd.distribution_id
   HEAD cd.distribution_id
    high_volume_cnt = (high_volume_cnt + 1 ) ,ops_cnt = 0
   DETAIL
    ops_cnt = (ops_cnt + 1 ) ,
    IF ((ops_cnt > 1 ) ) high_volume_cnt = (high_volume_cnt + 1 )
    ENDIF
   WITH nocounter
  ;end select
  CALL echo (high_volume_cnt )
  IF ((high_volume_cnt > 5000 ) )
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF ((high_volume_cnt > 3000 ) )
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((is_logical_domain_enabled_ind = 1 ) )
  SET where_clause = build2 (
   "cd.distribution_id > 0 and cd.active_ind = 1 and cd.logical_domain_id = personnel_logical_domain_id"
   )
 ELSE
  SET where_clause = build2 ("cd.distribution_id > 0 and cd.active_ind = 1" )
 ENDIF
 SET dcnt = 0
 SELECT INTO "NL:"
  FROM (chart_distribution cd )
  PLAN (cd
   WHERE parser (where_clause ) )
  ORDER BY cnvtupper (cd.dist_descr )
  HEAD REPORT
   stat = alterlist (distributions->dist ,200 ) ,
   dcnt = 0
  DETAIL
   dcnt = (dcnt + 1 ) ,
   IF ((mod (dcnt ,10 ) = 1 )
   AND (dcnt > 100 ) ) stat = alterlist (distributions->dist ,(dcnt + 9 ) )
   ENDIF
   ,distributions->dist[dcnt ].dist_id = cd.distribution_id ,
   distributions->dist[dcnt ].description = cd.dist_descr ,
   distributions->dist[dcnt ].dist_type_flag = cd.dist_type ,
   distributions->dist[dcnt ].days_till_chart = cd.days_till_chart ,
   distributions->dist[dcnt ].banner_page = cd.banner_page ,
   distributions->dist[dcnt ].incl_excl_encntr_type = 99 ,
   distributions->dist[dcnt ].incl_excl_client = 99 ,
   distributions->dist[dcnt ].incl_excl_provider = 99 ,
   distributions->dist[dcnt ].incl_excl_location = 99 ,
   distributions->dist[dcnt ].incl_excl_med_service = 99 ,
   distributions->dist[dcnt ].reader_group = cd.reader_group ,
   distributions->dist[dcnt ].cutoff_ind = cd.cutoff_and_or_ind ,
   IF ((distributions->dist[dcnt ].cutoff_ind != 0 ) )
    IF ((distributions->dist[dcnt ].cutoff_ind = 1 ) ) distributions->dist[dcnt ].cutoff_ind_str =
     "And"
    ELSEIF ((distributions->dist[dcnt ].cutoff_ind = 2 ) ) distributions->dist[dcnt ].cutoff_ind_str
     = "Or"
    ENDIF
    ,distributions->dist[dcnt ].cutoff_pages = cd.cutoff_pages ,distributions->dist[dcnt ].
    cutoff_days = cd.cutoff_days
   ENDIF
   ,distributions->dist[dcnt ].initial_lookback_ind = cd.max_lookback_ind ,
   IF ((distributions->dist[dcnt ].initial_lookback_ind = 0 ) ) distributions->dist[dcnt ].
    initial_lookback_date = cd.max_lookback_dt_tm
   ELSEIF ((distributions->dist[dcnt ].initial_lookback_ind = 3 ) ) distributions->dist[dcnt ].
    initial_lookback_days = cd.max_lookback_days
   ENDIF
   ,distributions->dist[dcnt ].absolute_lookback_ind = cd.absolute_lookback_ind ,
   IF ((distributions->dist[dcnt ].absolute_lookback_ind = 0 ) ) distributions->dist[dcnt ].
    absolute_lookback_date = cd.absolute_qualification_dt_tm
   ELSEIF ((distributions->dist[dcnt ].absolute_lookback_ind = 3 ) ) distributions->dist[dcnt ].
    absolute_lookback_days = cd.absolute_qualification_days
   ENDIF
   ,distributions->dist[dcnt ].first_lookback_ind = cd.print_lookback_ind ,
   IF ((distributions->dist[dcnt ].first_lookback_ind = 0 ) ) distributions->dist[dcnt ].
    first_lookback_date = cd.first_qualification_dt_tm
   ELSEIF ((distributions->dist[dcnt ].first_lookback_ind = 1 ) ) distributions->dist[dcnt ].
    first_lookback_str = "Previous Distribution Run"
   ELSEIF ((distributions->dist[dcnt ].first_lookback_ind = 2 ) ) distributions->dist[dcnt ].
    first_lookback_str = "Patient Admit Date"
   ELSEIF ((distributions->dist[dcnt ].first_lookback_ind = 3 ) ) distributions->dist[dcnt ].
    first_lookback_days = cd.first_qualification_days
   ENDIF
  FOOT REPORT
   stat = alterlist (distributions->dist ,dcnt )
  WITH nocounter
 ;end select
 IF ((dcnt > 0 ) )
  SELECT INTO "NL:"
   FROM (dummyt d WITH seq = dcnt ),
    (chart_dist_filter cdf )
   PLAN (d )
    JOIN (cdf
    WHERE (cdf.distribution_id = distributions->dist[d.seq ].dist_id )
    AND (cdf.active_ind = 1 ) )
   DETAIL
    IF ((cdf.type_flag = 0 ) ) distributions->dist[d.seq ].incl_excl_encntr_type = cdf.included_flag
    ELSEIF ((cdf.type_flag = 1 ) ) distributions->dist[d.seq ].incl_excl_client = cdf.included_flag
    ELSEIF ((cdf.type_flag = 2 ) ) distributions->dist[d.seq ].incl_excl_provider = cdf
     .included_flag
    ELSEIF ((cdf.type_flag = 3 ) ) distributions->dist[d.seq ].incl_excl_location = cdf
     .included_flag
    ELSEIF ((cdf.type_flag = 4 ) ) distributions->dist[d.seq ].incl_excl_med_service = cdf
     .included_flag
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d WITH seq = dcnt ),
    (chart_dist_filter_value cdfv ),
    (code_value cv )
   PLAN (d )
    JOIN (cdfv
    WHERE (cdfv.distribution_id = distributions->dist[d.seq ].dist_id )
    AND (cdfv.parent_entity_name = "CODE_VALUE" )
    AND (cdfv.type_flag IN (0 ,
    3 ,
    4 ) )
    AND (cdfv.active_ind = 1 ) )
    JOIN (cv
    WHERE (cv.code_value = cdfv.parent_entity_id )
    AND (cv.active_ind = 1 ) )
   ORDER BY d.seq ,
    cdfv.key_sequence
   HEAD d.seq
    enctype_cnt = 0 ,loc_cnt = 0 ,medserv_cnt = 0
   DETAIL
    IF ((cdfv.type_flag = 0 ) ) enctype_cnt = (enctype_cnt + 1 ) ,stat = alterlist (distributions->
      dist[d.seq ].encntr_types ,enctype_cnt ) ,distributions->dist[d.seq ].encntr_types[enctype_cnt
     ].description = cv.description
    ENDIF
    ,
    IF ((cdfv.type_flag = 3 ) ) loc_cnt = (loc_cnt + 1 ) ,stat = alterlist (distributions->dist[d
      .seq ].locations ,loc_cnt ) ,distributions->dist[d.seq ].locations[loc_cnt ].description = cv
     .description
    ENDIF
    ,
    IF ((cdfv.type_flag = 4 ) ) medserv_cnt = (medserv_cnt + 1 ) ,stat = alterlist (distributions->
      dist[d.seq ].med_services ,medserv_cnt ) ,distributions->dist[d.seq ].med_services[medserv_cnt
     ].description = cv.description
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d WITH seq = dcnt ),
    (chart_dist_filter_value cdfv ),
    (organization o )
   PLAN (d )
    JOIN (cdfv
    WHERE (cdfv.distribution_id = distributions->dist[d.seq ].dist_id )
    AND (cdfv.parent_entity_name = "ORGANIZATION" )
    AND (cdfv.type_flag = 1 )
    AND (cdfv.active_ind = 1 ) )
    JOIN (o
    WHERE (o.organization_id = cdfv.parent_entity_id )
    AND (o.active_ind = 1 ) )
   ORDER BY d.seq ,
    cdfv.key_sequence
   HEAD d.seq
    client_cnt = 0
   DETAIL
    client_cnt = (client_cnt + 1 ) ,
    stat = alterlist (distributions->dist[d.seq ].clients ,client_cnt ) ,
    distributions->dist[d.seq ].clients[client_cnt ].description = o.org_name
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d WITH seq = dcnt ),
    (chart_dist_filter_value cdfv ),
    (prsnl p ),
    (code_value cv )
   PLAN (d )
    JOIN (cdfv
    WHERE (cdfv.distribution_id = distributions->dist[d.seq ].dist_id )
    AND (cdfv.parent_entity_name = "PRSNL" )
    AND (cdfv.type_flag = 2 )
    AND (cdfv.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = cdfv.parent_entity_id )
    AND (p.active_ind = 1 ) )
    JOIN (cv
    WHERE (cv.code_value = cdfv.reltn_type_cd )
    AND (cv.active_ind = 1 ) )
   ORDER BY d.seq ,
    cdfv.parent_entity_id ,
    cdfv.key_sequence
   HEAD d.seq
    prov_cnt = 0
   HEAD cdfv.parent_entity_id
    prov_cnt = (prov_cnt + 1 ) ,stat = alterlist (distributions->dist[d.seq ].providers ,prov_cnt ) ,
    distributions->dist[d.seq ].providers[prov_cnt ].description = p.name_full_formatted ,reltn_cnt
    = 0
   DETAIL
    reltn_cnt = (reltn_cnt + 1 ) ,
    stat = alterlist (distributions->dist[d.seq ].providers[prov_cnt ].reltns ,reltn_cnt ) ,
    distributions->dist[d.seq ].providers[prov_cnt ].reltns[reltn_cnt ].display = cv.display
   WITH nocounter
  ;end select
  DECLARE param_scope = i4 WITH constant (1 )
  DECLARE param_distid = i4 WITH constant (2 )
  DECLARE param_runtype = i4 WITH constant (3 )
  DECLARE param_chartformat = i4 WITH constant (4 )
  DECLARE param_copytoprov = i4 WITH constant (6 )
  DECLARE param_printfinals = i4 WITH constant (7 )
  DECLARE param_distrouting = i4 WITH constant (9 )
  DECLARE param_defaultprinter = i4 WITH constant (10 )
  DECLARE param_acthold = i4 WITH constant (12 )
  DECLARE param_ordstathold = i4 WITH constant (13 )
  DECLARE param_filestoragecd = i4 WITH constant (14 )
  DECLARE param_sortsequence = i4 WITH constant (15 )
  DECLARE param_defaultchart = i4 WITH constant (16 )
  DECLARE param_orderprovflag = i4 WITH constant (19 )
  DECLARE param_provroutingflag = i4 WITH constant (20 )
  DECLARE param_expireind = i4 WITH constant (22 )
  DECLARE param_law = i4 WITH constant (18 )
  DECLARE param_network = i4 WITH constant (17 )
  DECLARE param_filename = i4 WITH constant (23 )
  DECLARE param_ftp = i4 WITH constant (24 )
  IF ((is_logical_domain_enabled_ind = 1 ) )
   SET where_clause = build2 (
    "co.active_ind = 1 and co.logical_domain_id = personnel_logical_domain_id" )
  ELSE
   SET where_clause = build2 ("co.active_ind = 1" )
  ENDIF
  SELECT DISTINCT INTO "NL:"
   FROM (dummyt d WITH seq = dcnt ),
    (charting_operations co )
   PLAN (d )
    JOIN (co
    WHERE (co.param = cnvtstring (distributions->dist[d.seq ].dist_id ) )
    AND (co.param_type_flag = param_distid )
    AND (co.charting_operations_id > 0 )
    AND parser (where_clause ) )
   ORDER BY d.seq ,
    co.batch_name
   HEAD d.seq
    ops_cnt = 0
   DETAIL
    ops_cnt = (ops_cnt + 1 ) ,
    stat = alterlist (distributions->dist[d.seq ].related_ops ,ops_cnt ) ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].operations_id = co.charting_operations_id ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].batch_name = co.batch_name ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].incl_excl_encntr_type = 99 ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].incl_excl_client = 99 ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].incl_excl_provider = 99 ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].incl_excl_location = 99 ,
    distributions->dist[d.seq ].related_ops[ops_cnt ].incl_excl_med_service = 99
   WITH nocounter
  ;end select
  FOR (d = 1 TO dcnt )
   SET rcnt = size (distributions->dist[d ].related_ops ,5 )
   IF ((rcnt > 0 ) )
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (charting_operations co ),
      (dummyt d1 ),
      (code_value cv )
     PLAN (d )
      JOIN (co
      WHERE (co.charting_operations_id = distributions->dist[d ].related_ops[d.seq ].operations_id )
      AND (co.active_ind = 1 ) )
      JOIN (d1 )
      JOIN (cv
      WHERE (co.param_type_flag IN (param_runtype ,
      param_sortsequence ,
      param_filestoragecd ,
      param_acthold ,
      param_ordstathold ,
      param_copytoprov ) )
      AND (cnvtstring (cv.code_value ) = co.param )
      AND (cv.active_ind = 1 ) )
     ORDER BY d.seq
     HEAD d.seq
      acnt = 0 ,ocnt = 0 ,pcnt = 0
     DETAIL
      IF ((co.param_type_flag = param_runtype ) ) distributions->dist[d ].related_ops[d.seq ].
       run_type_display = cv.display
      ELSEIF ((co.param_type_flag = param_scope ) ) distributions->dist[d ].related_ops[d.seq ].
       scope_flag = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_sortsequence ) ) distributions->dist[d ].related_ops[d.seq
       ].sort_seq_display = cv.display
      ELSEIF ((co.param_type_flag = param_printfinals ) ) distributions->dist[d ].related_ops[d.seq ]
       .print_finals_ind = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_chartformat ) ) distributions->dist[d ].related_ops[d.seq ]
       .chart_format_id = cnvtreal (co.param )
      ELSEIF ((co.param_type_flag = param_distrouting ) ) distributions->dist[d ].related_ops[d.seq ]
       .dist_routing_flag = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_defaultchart ) ) distributions->dist[d ].related_ops[d.seq
       ].default_chart_ind = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_defaultprinter ) ) distributions->dist[d ].related_ops[d
       .seq ].default_printer_id = cnvtreal (co.param )
      ELSEIF ((co.param_type_flag = param_expireind ) ) distributions->dist[d ].related_ops[d.seq ].
       expire_ind = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_filestoragecd ) ) distributions->dist[d ].related_ops[d
       .seq ].file_storage_display = cv.display
      ELSEIF ((co.param_type_flag = param_orderprovflag ) ) distributions->dist[d ].related_ops[d
       .seq ].order_prov_flag = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_provroutingflag ) ) distributions->dist[d ].related_ops[d
       .seq ].incl_excl_providers = cnvtint (co.param )
      ELSEIF ((co.param_type_flag = param_law ) ) distributions->dist[d ].related_ops[d.seq ].
       op_law_id = cnvtreal (co.param )
      ELSEIF ((co.param_type_flag = param_network ) ) distributions->dist[d ].related_ops[d.seq ].
       network_file_dest = co.param
      ELSEIF ((co.param_type_flag = param_filename ) ) distributions->dist[d ].related_ops[d.seq ].
       filename_mask = cnvtreal (co.param )
      ELSEIF ((co.param_type_flag = param_ftp ) )
       IF ((co.param != "0" ) ) distributions->dist[d ].related_ops[d.seq ].ftp_dest = co.param
       ENDIF
      ELSEIF ((co.param_type_flag = param_acthold )
      AND (cnvtreal (co.param ) > 0 ) ) acnt = (acnt + 1 ) ,stat = alterlist (distributions->dist[d ]
        .related_ops[d.seq ].activity_holds ,acnt ) ,distributions->dist[d ].related_ops[d.seq ].
       activity_holds[acnt ].display = cv.display
      ELSEIF ((co.param_type_flag = param_ordstathold )
      AND (cnvtreal (co.param ) > 0 ) ) ocnt = (ocnt + 1 ) ,stat = alterlist (distributions->dist[d ]
        .related_ops[d.seq ].ord_stat_holds ,ocnt ) ,distributions->dist[d ].related_ops[d.seq ].
       ord_stat_holds[ocnt ].display = cv.display
      ELSEIF ((co.param_type_flag = param_copytoprov ) )
       IF ((isnumeric (co.param ) > 0 ) )
        IF ((cnvtreal (co.param ) > 0 ) ) pcnt = (pcnt + 1 ) ,stat = alterlist (distributions->dist[
          d ].related_ops[d.seq ].copy_to_prov_types ,pcnt ) ,distributions->dist[d ].related_ops[d
         .seq ].copy_to_prov_types[pcnt ].code_value = cv.code_value ,distributions->dist[d ].
         related_ops[d.seq ].copy_to_prov_types[pcnt ].display = cv.display
        ENDIF
       ELSE pcnt = (pcnt + 1 ) ,stat = alterlist (distributions->dist[d ].related_ops[d.seq ].
         copy_to_prov_types ,pcnt ) ,distributions->dist[d ].related_ops[d.seq ].copy_to_prov_types[
        pcnt ].display = co.param
       ENDIF
      ENDIF
     WITH nocounter ,outerjoin = d1
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (cr_mask cm )
     PLAN (d )
      JOIN (cm
      WHERE (cm.cr_mask_id = distributions->dist[d ].related_ops[d.seq ].filename_mask ) )
     DETAIL
      distributions->dist[d ].related_ops[d.seq ].filename = cm.cr_mask_text
     WITH nocounter
    ;end select
    IF ((is_logical_domain_enabled_ind = 1 ) )
     SET where_clause = build2 (
      "cl.law_id > 0 and cl.logical_domain_id = personnel_logical_domain_id" )
    ELSE
     SET where_clause = build2 ("cl.law_id > 0" )
    ENDIF
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (chart_law cl )
     PLAN (d )
      JOIN (cl
      WHERE (cl.law_id = distributions->dist[d ].related_ops[d.seq ].op_law_id )
      AND parser (where_clause ) )
     DETAIL
      distributions->dist[d ].related_ops[d.seq ].law_id = cl.law_id ,
      distributions->dist[d ].related_ops[d.seq ].law_name = cl.law_descr ,
      distributions->dist[d ].related_ops[d.seq ].law_lookback = cl.lookback_days ,
      IF ((cl.lookback_type_ind = 1 ) ) distributions->dist[d ].related_ops[d.seq ].law_lookback_type
        = "Discharge Date/Time"
      ELSEIF ((cl.lookback_type_ind = 2 ) ) distributions->dist[d ].related_ops[d.seq ].
       law_lookback_type = "Clinical Activity Date/Time"
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (chart_law_filter clf )
     PLAN (d )
      JOIN (clf
      WHERE (clf.law_id = distributions->dist[d ].related_ops[d.seq ].law_id )
      AND (clf.active_ind = 1 ) )
     DETAIL
      IF ((clf.type_flag = 0 ) ) distributions->dist[d ].related_ops[d.seq ].incl_excl_encntr_type =
       clf.included_flag
      ELSEIF ((clf.type_flag = 1 ) ) distributions->dist[d ].related_ops[d.seq ].incl_excl_client =
       clf.included_flag
      ELSEIF ((clf.type_flag = 2 ) ) distributions->dist[d ].related_ops[d.seq ].incl_excl_provider
       = clf.included_flag
      ELSEIF ((clf.type_flag = 3 ) ) distributions->dist[d ].related_ops[d.seq ].incl_excl_location
       = clf.included_flag
      ELSEIF ((clf.type_flag = 4 ) ) distributions->dist[d ].related_ops[d.seq ].
       incl_excl_med_service = clf.included_flag
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (chart_law_filter_value clfv ),
      (code_value cv )
     PLAN (d )
      JOIN (clfv
      WHERE (clfv.law_id = distributions->dist[d ].related_ops[d.seq ].law_id )
      AND (clfv.parent_entity_name = "CODE_VALUE" )
      AND (clfv.type_flag IN (0 ,
      3 ,
      4 ) )
      AND (clfv.active_ind = 1 ) )
      JOIN (cv
      WHERE (cv.code_value = clfv.parent_entity_id )
      AND (cv.active_ind = 1 ) )
     ORDER BY d.seq ,
      clfv.key_sequence
     HEAD d.seq
      enctype_cnt = 0 ,loc_cnt = 0 ,medserv_cnt = 0
     DETAIL
      IF ((clfv.type_flag = 0 ) ) enctype_cnt = (enctype_cnt + 1 ) ,stat = alterlist (distributions->
        dist[d ].related_ops[d.seq ].encntr_types ,enctype_cnt ) ,distributions->dist[d ].
       related_ops[d.seq ].encntr_types[enctype_cnt ].description = cv.description
      ENDIF
      ,
      IF ((clfv.type_flag = 3 ) ) loc_cnt = (loc_cnt + 1 ) ,stat = alterlist (distributions->dist[d ]
        .related_ops[d.seq ].locations ,loc_cnt ) ,distributions->dist[d ].related_ops[d.seq ].
       locations[loc_cnt ].description = cv.description
      ENDIF
      ,
      IF ((clfv.type_flag = 4 ) ) medserv_cnt = (medserv_cnt + 1 ) ,stat = alterlist (distributions->
        dist[d ].related_ops[d.seq ].med_services ,medserv_cnt ) ,distributions->dist[d ].
       related_ops[d.seq ].med_services[medserv_cnt ].description = cv.description
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (chart_law_filter_value clfv ),
      (organization o )
     PLAN (d )
      JOIN (clfv
      WHERE (clfv.law_id = distributions->dist[d ].related_ops[d.seq ].law_id )
      AND (clfv.parent_entity_name = "ORGANIZATION" )
      AND (clfv.type_flag = 1 )
      AND (clfv.active_ind = 1 ) )
      JOIN (o
      WHERE (o.organization_id = clfv.parent_entity_id )
      AND (o.active_ind = 1 ) )
     ORDER BY d.seq ,
      clfv.key_sequence
     HEAD d.seq
      client_cnt = 0
     DETAIL
      client_cnt = (client_cnt + 1 ) ,
      stat = alterlist (distributions->dist[d ].related_ops[d.seq ].clients ,client_cnt ) ,
      distributions->dist[d ].related_ops[d.seq ].clients[client_cnt ].description = o.org_name
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (chart_law_filter_value clfv ),
      (prsnl p ),
      (code_value cv )
     PLAN (d )
      JOIN (clfv
      WHERE (clfv.law_id = distributions->dist[d ].related_ops[d.seq ].law_id )
      AND (clfv.parent_entity_name = "PRSNL" )
      AND (clfv.type_flag = 2 )
      AND (clfv.active_ind = 1 ) )
      JOIN (p
      WHERE (p.person_id = clfv.parent_entity_id )
      AND (p.active_ind = 1 ) )
      JOIN (cv
      WHERE (cv.code_value = clfv.reltn_type_cd )
      AND (cv.active_ind = 1 ) )
     ORDER BY d.seq ,
      clfv.parent_entity_id ,
      clfv.key_sequence
     HEAD d.seq
      prov_cnt = 0
     HEAD clfv.parent_entity_id
      prov_cnt = (prov_cnt + 1 ) ,stat = alterlist (distributions->dist[d ].related_ops[d.seq ].
       providers ,prov_cnt ) ,distributions->dist[d ].related_ops[d.seq ].providers[prov_cnt ].
      description = p.name_full_formatted ,reltn_cnt = 0
     DETAIL
      reltn_cnt = (reltn_cnt + 1 ) ,
      stat = alterlist (distributions->dist[d ].related_ops[d.seq ].providers[prov_cnt ].reltns ,
       reltn_cnt ) ,
      distributions->dist[d ].related_ops[d.seq ].providers[prov_cnt ].reltns[reltn_cnt ].display =
      cv.display
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (cr_report_template crt )
     PLAN (d )
      JOIN (crt
      WHERE (crt.template_id = distributions->dist[d ].related_ops[d.seq ].chart_format_id ) )
     DETAIL
      distributions->dist[d ].related_ops[d.seq ].report_template_desc = crt.template_name
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (chart_format cf )
     PLAN (d )
      JOIN (cf
      WHERE (cf.chart_format_id = distributions->dist[d ].related_ops[d.seq ].chart_format_id )
      AND (cf.active_ind = 1 ) )
     DETAIL
      distributions->dist[d ].related_ops[d.seq ].chart_format_desc = cf.chart_format_desc
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (output_dest od )
     PLAN (d )
      JOIN (od
      WHERE (od.output_dest_cd = distributions->dist[d ].related_ops[d.seq ].default_printer_id ) )
     DETAIL
      distributions->dist[d ].related_ops[d.seq ].default_printer_name = od.name
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (charting_operations_prsnl cop ),
      (prsnl p )
     PLAN (d )
      JOIN (cop
      WHERE (cop.charting_operations_id = distributions->dist[d ].related_ops[d.seq ].operations_id
      ) )
      JOIN (p
      WHERE (p.person_id = cop.prsnl_id )
      AND (p.active_ind = 1 )
      AND (p.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
      AND (((p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) ) OR ((p
      .end_effective_dt_tm = null ) )) )
     ORDER BY d.seq
     HEAD d.seq
      pcnt = 0
     DETAIL
      pcnt = (pcnt + 1 ) ,
      stat = alterlist (distributions->dist[d ].related_ops[d.seq ].provider_routings ,pcnt ) ,
      distributions->dist[d ].related_ops[d.seq ].provider_routings[pcnt ].name = p
      .name_full_formatted
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "NL:"
     FROM (dummyt d WITH seq = rcnt ),
      (ops_task ot ),
      (ops_schedule_param osp ),
      (ops_job oj ),
      (ops_job_step ojs )
     PLAN (d )
      JOIN (osp
      WHERE (osp.batch_selection = distributions->dist[d ].related_ops[d.seq ].batch_name )
      AND (osp.active_ind = 1 ) )
      JOIN (ot
      WHERE (ot.ops_task_id = osp.ops_task_id )
      AND (ot.active_ind = 1 ) )
      JOIN (ojs
      WHERE (ojs.ops_job_id = ot.ops_job_id )
      AND (ojs.request_number IN (param_cr_prcs ,
      param_cp_prcs ) )
      AND (ojs.active_ind = 1 ) )
      JOIN (oj
      WHERE (oj.ops_job_id = ot.ops_job_id ) )
     ORDER BY osp.ops_task_id ,
      osp.batch_selection
     HEAD d.seq
      job_cnt = 0
     DETAIL
      job_cnt = (job_cnt + 1 ) ,
      stat = alterlist (distributions->dist[d ].related_ops[d.seq ].related_jobs ,job_cnt ) ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].ops_task_id = ot
      .ops_task_id ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].frequency_flag = ot
      .frequency_type ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].day_interval = ot
      .day_interval ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].time_ind = ot.time_ind ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].time_interval = ot
      .time_interval ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].time_interval_ind = ot
      .time_interval_ind ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].beg_effective_dt_tm = ot
      .beg_effective_dt_tm ,
      distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].end_effective_dt_tm = ot
      .end_effective_dt_tm ,
      IF ((trim (ot.job_grp_name ) = "" ) ) distributions->dist[d ].related_ops[d.seq ].related_jobs[
       job_cnt ].ops_job_name = oj.name
      ELSE distributions->dist[d ].related_ops[d.seq ].related_jobs[job_cnt ].ops_job_name = concat (
        trim (ot.job_grp_name ) ,"(" ,trim (oj.name ) ,")" )
      ENDIF
     WITH nocounter
    ;end select
    FOR (r = 1 TO rcnt )
     SET jsize = size (distributions->dist[d ].related_ops[r ].related_jobs ,5 )
     SELECT INTO "NL:"
      FROM (dummyt d WITH seq = jsize ),
       (ops_day_of_week dow )
      PLAN (d
       WHERE (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].frequency_flag IN (3 ,
       5 ) ) )
       JOIN (dow
       WHERE (dow.ops_task_id = distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].
       ops_task_id )
       AND (dow.active_ind = 1 ) )
      HEAD d.seq
       dow_cnt = 0
      DETAIL
       dow_cnt = (dow_cnt + 1 ) ,
       stat = alterlist (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].days_of_week ,
        dow_cnt ) ,
       distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].days_of_week[dow_cnt ].
       day_of_week = dow.day_of_week
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d WITH seq = jsize ),
       (ops_day_of_month dom )
      PLAN (d
       WHERE (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].frequency_flag = 4 ) )
       JOIN (dom
       WHERE (dom.ops_task_id = distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].
       ops_task_id )
       AND (dom.active_ind = 1 ) )
      HEAD d.seq
       dom_cnt = 0
      DETAIL
       dom_cnt = (dom_cnt + 1 ) ,
       stat = alterlist (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].days_of_month ,
        dom_cnt ) ,
       distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].days_of_month[dom_cnt ].
       day_of_month = dom.day_of_month
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d WITH seq = jsize ),
       (ops_month_of_year moy )
      PLAN (d
       WHERE (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].frequency_flag IN (4 ,
       5 ) ) )
       JOIN (moy
       WHERE (moy.ops_task_id = distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].
       ops_task_id )
       AND (moy.active_ind = 1 ) )
      HEAD d.seq
       moy_cnt = 0
      DETAIL
       moy_cnt = (moy_cnt + 1 ) ,
       stat = alterlist (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].months_of_year
        ,moy_cnt ) ,
       distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].months_of_year[moy_cnt ].
       month_of_year = moy.month_of_year
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d WITH seq = jsize ),
       (ops_week_of_month wom )
      PLAN (d
       WHERE (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].frequency_flag = 5 ) )
       JOIN (wom
       WHERE (wom.ops_task_id = distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].
       ops_task_id )
       AND (wom.active_ind = 1 ) )
      HEAD d.seq
       wom_cnt = 0
      DETAIL
       wom_cnt = (wom_cnt + 1 ) ,
       stat = alterlist (distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].weeks_of_month
        ,wom_cnt ) ,
       distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].weeks_of_month[wom_cnt ].
       week_of_month = wom.week_of_month
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d WITH seq = jsize ),
       (ops_job_step ojs ),
       (ops_task ot ),
       (ops_job oj )
      PLAN (d )
       JOIN (ot
       WHERE (ot.ops_task_id = distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].
       ops_task_id ) )
       JOIN (oj
       WHERE (oj.ops_job_id = ot.ops_job_id ) )
       JOIN (ojs
       WHERE (ojs.ops_job_id = oj.ops_job_id )
       AND (ojs.request_number IN (param_ch_req ,
       param_cr_req ) )
       AND (ojs.active_ind = 1 ) )
      DETAIL
       distributions->dist[d ].related_ops[r ].related_jobs[d.seq ].journal_step_exists_ind = 1
      WITH nocounter
     ;end select
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 SET stat = alterlist (reply->collist ,57 )
 SET reply->collist[1 ].header_text = "Ops Job Name"
 SET reply->collist[1 ].data_type = 1
 SET reply->collist[1 ].hide_ind = 0
 SET reply->collist[2 ].header_text = "Ops Job Occurrence"
 SET reply->collist[2 ].data_type = 1
 SET reply->collist[2 ].hide_ind = 0
 SET reply->collist[3 ].header_text = "Ops Job Days Scheduled"
 SET reply->collist[3 ].data_type = 1
 SET reply->collist[3 ].hide_ind = 0
 SET reply->collist[4 ].header_text = "Ops Job Time"
 SET reply->collist[4 ].data_type = 1
 SET reply->collist[4 ].hide_ind = 0
 SET reply->collist[5 ].header_text = "Print a Journal"
 SET reply->collist[5 ].data_type = 1
 SET reply->collist[5 ].hide_ind = 0
 SET reply->collist[6 ].header_text = "Distribution Name"
 SET reply->collist[6 ].data_type = 1
 SET reply->collist[6 ].hide_ind = 0
 SET reply->collist[7 ].header_text = "Patient Discharge Status"
 SET reply->collist[7 ].data_type = 1
 SET reply->collist[7 ].hide_ind = 0
 SET reply->collist[8 ].header_text = "Days Until Chart"
 SET reply->collist[8 ].data_type = 1
 SET reply->collist[8 ].hide_ind = 0
 SET reply->collist[9 ].header_text = "Print a Banner Page"
 SET reply->collist[9 ].data_type = 1
 SET reply->collist[9 ].hide_ind = 0
 SET reply->collist[10 ].header_text = "Include/Exclude Client"
 SET reply->collist[10 ].data_type = 1
 SET reply->collist[10 ].hide_ind = 0
 SET reply->collist[11 ].header_text = "Qualify Based on Client"
 SET reply->collist[11 ].data_type = 1
 SET reply->collist[11 ].hide_ind = 0
 SET reply->collist[12 ].header_text = "Include/Exclude Encounter Type"
 SET reply->collist[12 ].data_type = 1
 SET reply->collist[12 ].hide_ind = 0
 SET reply->collist[13 ].header_text = "Qualify Based on Encounter Type"
 SET reply->collist[13 ].data_type = 1
 SET reply->collist[13 ].hide_ind = 0
 SET reply->collist[14 ].header_text = "Include/Exclude Location"
 SET reply->collist[14 ].data_type = 1
 SET reply->collist[14 ].hide_ind = 0
 SET reply->collist[15 ].header_text = "Qualify Based on Location"
 SET reply->collist[15 ].data_type = 1
 SET reply->collist[15 ].hide_ind = 0
 SET reply->collist[16 ].header_text = "Include/Exclude Medical Service"
 SET reply->collist[16 ].data_type = 1
 SET reply->collist[16 ].hide_ind = 0
 SET reply->collist[17 ].header_text = "Qualify Based on Medical Service"
 SET reply->collist[17 ].data_type = 1
 SET reply->collist[17 ].hide_ind = 0
 SET reply->collist[18 ].header_text = "Include/Exclude Provider"
 SET reply->collist[18 ].data_type = 1
 SET reply->collist[18 ].hide_ind = 0
 SET reply->collist[19 ].header_text = "Qualify Based on Provider"
 SET reply->collist[19 ].data_type = 1
 SET reply->collist[19 ].hide_ind = 0
 SET reply->collist[20 ].header_text = "Reader Group"
 SET reply->collist[20 ].data_type = 1
 SET reply->collist[20 ].hide_ind = 0
 SET reply->collist[21 ].header_text = "Cutoff Logic"
 SET reply->collist[21 ].data_type = 1
 SET reply->collist[21 ].hide_ind = 0
 SET reply->collist[22 ].header_text = "Initial distribution lookback"
 SET reply->collist[22 ].data_type = 1
 SET reply->collist[22 ].hide_ind = 0
 SET reply->collist[23 ].header_text = "First Qualification lookback"
 SET reply->collist[23 ].data_type = 1
 SET reply->collist[23 ].hide_ind = 0
 SET reply->collist[24 ].header_text = "Absolute lookback"
 SET reply->collist[24 ].data_type = 1
 SET reply->collist[24 ].hide_ind = 0
 SET reply->collist[25 ].header_text = "Operation Name"
 SET reply->collist[25 ].data_type = 1
 SET reply->collist[25 ].hide_ind = 0
 SET reply->collist[26 ].header_text = "Run Type"
 SET reply->collist[26 ].data_type = 1
 SET reply->collist[26 ].hide_ind = 0
 SET reply->collist[27 ].header_text = "Scope"
 SET reply->collist[27 ].data_type = 1
 SET reply->collist[27 ].hide_ind = 0
 SET reply->collist[28 ].header_text = "Chart Format"
 SET reply->collist[28 ].data_type = 1
 SET reply->collist[28 ].hide_ind = 0
 SET reply->collist[29 ].header_text = "Report Template"
 SET reply->collist[29 ].data_type = 1
 SET reply->collist[29 ].hide_ind = 0
 SET reply->collist[30 ].header_text = "Verified Results Only"
 SET reply->collist[30 ].data_type = 1
 SET reply->collist[30 ].hide_ind = 0
 SET reply->collist[31 ].header_text = "Copies to Provider Types"
 SET reply->collist[31 ].data_type = 1
 SET reply->collist[31 ].hide_ind = 0
 SET reply->collist[32 ].header_text = "Exclude Expired Physicians"
 SET reply->collist[32 ].data_type = 1
 SET reply->collist[32 ].hide_ind = 0
 SET reply->collist[33 ].header_text = "Default a Chart"
 SET reply->collist[33 ].data_type = 1
 SET reply->collist[33 ].hide_ind = 0
 SET reply->collist[34 ].header_text = "Include/Exclude Provider Routing"
 SET reply->collist[34 ].data_type = 1
 SET reply->collist[34 ].hide_ind = 0
 SET reply->collist[35 ].header_text = "Qualify Based on Provider Routing"
 SET reply->collist[35 ].data_type = 1
 SET reply->collist[35 ].hide_ind = 0
 SET reply->collist[36 ].header_text = "Distribution Routing"
 SET reply->collist[36 ].data_type = 1
 SET reply->collist[36 ].hide_ind = 0
 SET reply->collist[37 ].header_text = "Sort Sequence"
 SET reply->collist[37 ].data_type = 1
 SET reply->collist[37 ].hide_ind = 0
 SET reply->collist[38 ].header_text = "Default Device"
 SET reply->collist[38 ].data_type = 1
 SET reply->collist[38 ].hide_ind = 0
 SET reply->collist[39 ].header_text = "Print/File Storage Options"
 SET reply->collist[39 ].data_type = 1
 SET reply->collist[39 ].hide_ind = 0
 SET reply->collist[40 ].header_text = "Filename"
 SET reply->collist[40 ].data_type = 1
 SET reply->collist[40 ].hide_ind = 0
 SET reply->collist[41 ].header_text = "Network File Destination"
 SET reply->collist[41 ].data_type = 1
 SET reply->collist[41 ].hide_ind = 0
 SET reply->collist[42 ].header_text = "FTP Destination"
 SET reply->collist[42 ].data_type = 1
 SET reply->collist[42 ].hide_ind = 0
 SET reply->collist[43 ].header_text = "Activity and Order Status Hold"
 SET reply->collist[43 ].data_type = 1
 SET reply->collist[43 ].hide_ind = 0
 SET reply->collist[44 ].header_text = "Activity"
 SET reply->collist[44 ].data_type = 1
 SET reply->collist[44 ].hide_ind = 0
 SET reply->collist[45 ].header_text = "Order Status"
 SET reply->collist[45 ].data_type = 1
 SET reply->collist[45 ].hide_ind = 0
 SET reply->collist[46 ].header_text = "Cross-Encounter Law Name"
 SET reply->collist[46 ].data_type = 1
 SET reply->collist[46 ].hide_ind = 0
 SET reply->collist[47 ].header_text = "Law Lookback"
 SET reply->collist[47 ].data_type = 1
 SET reply->collist[47 ].hide_ind = 0
 SET reply->collist[48 ].header_text = "Law Include/Exclude Client"
 SET reply->collist[48 ].data_type = 1
 SET reply->collist[48 ].hide_ind = 0
 SET reply->collist[49 ].header_text = "Law Qualify Based on Client"
 SET reply->collist[49 ].data_type = 1
 SET reply->collist[49 ].hide_ind = 0
 SET reply->collist[50 ].header_text = "Law Include/Exclude Encounter Type"
 SET reply->collist[50 ].data_type = 1
 SET reply->collist[50 ].hide_ind = 0
 SET reply->collist[51 ].header_text = "Law Qualify Based on Encounter Type"
 SET reply->collist[51 ].data_type = 1
 SET reply->collist[51 ].hide_ind = 0
 SET reply->collist[52 ].header_text = "Law Include/Exclude Location"
 SET reply->collist[52 ].data_type = 1
 SET reply->collist[52 ].hide_ind = 0
 SET reply->collist[53 ].header_text = "Law Qualify Based on Location"
 SET reply->collist[53 ].data_type = 1
 SET reply->collist[53 ].hide_ind = 0
 SET reply->collist[54 ].header_text = "Law Include/Exclude Medical Service"
 SET reply->collist[54 ].data_type = 1
 SET reply->collist[54 ].hide_ind = 0
 SET reply->collist[55 ].header_text = "Law Qualify Based on Medical Service"
 SET reply->collist[55 ].data_type = 1
 SET reply->collist[55 ].hide_ind = 0
 SET reply->collist[56 ].header_text = "Law Include/Exclude Provider"
 SET reply->collist[56 ].data_type = 1
 SET reply->collist[56 ].hide_ind = 0
 SET reply->collist[57 ].header_text = "Law Qualify Based on Provider"
 SET reply->collist[57 ].data_type = 1
 SET reply->collist[57 ].hide_ind = 0
 IF ((dcnt = 0 ) )
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (d = 1 TO dcnt )
  SET row_nbr = (row_nbr + 1 )
  SET stat = alterlist (reply->rowlist ,row_nbr )
  SET stat = alterlist (reply->rowlist[row_nbr ].celllist ,57 )
  CALL setdistdetails (d )
  FOR (r = 1 TO size (distributions->dist[d ].related_ops ,5 ) )
   CALL setoperationdetails (d ,r )
   FOR (j = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs ,5 ) )
    IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 1 ) )
     SET reply->rowlist[row_nbr ].celllist[2 ].string_value = "One Time"
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 2 ) )
     SET reply->rowlist[row_nbr ].celllist[2 ].string_value = "Daily"
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 3 ) )
     SET reply->rowlist[row_nbr ].celllist[2 ].string_value = "Weekly"
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 4 ) )
     SET reply->rowlist[row_nbr ].celllist[2 ].string_value = "Day of Month"
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 5 ) )
     SET reply->rowlist[row_nbr ].celllist[2 ].string_value = "Week of Month"
    ENDIF
    IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 1 ) )
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = format (distributions->dist[d ].
      related_ops[r ].related_jobs[j ].beg_effective_dt_tm ,"MM/DD/YYYY HH:MM;;D" )
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 2 ) )
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 ("Every " ,trim (cnvtstring (
        distributions->dist[d ].related_ops[r ].related_jobs[j ].day_interval ) ) ," day(s)" )
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 3 ) )
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 ("Every " ,trim (cnvtstring (
        distributions->dist[d ].related_ops[r ].related_jobs[j ].day_interval ) ) ," week(s) on " )
     FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week ,5 ) )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week = 1
      ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Sun " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 2 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Mon " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 3 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Tue " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 4 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Wed " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 5 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Thu " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 6 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Fri " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 7 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Sat " )
      ENDIF
      IF ((x < size (distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week ,5 ) ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ,", " )
      ENDIF
     ENDFOR
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 4 ) )
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = "Day(s) "
     FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_month ,5 )
      )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_month[x ].day_of_month =
      32 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Last " )
      ELSE
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," " ,trim (cnvtstring (distributions->dist[d ].related_ops[r ].
          related_jobs[j ].days_of_month[x ].day_of_month ) ) )
      ENDIF
      IF ((x < size (distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_month ,5 ) ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ,", " )
      ENDIF
     ENDFOR
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[3 ].string_value ," of " )
     FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year ,5
      ) )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].month_of_year
      = 0 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," All Months " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 1 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Jan " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 2 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Feb " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 3 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Mar " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 4 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Apr " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 5 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," May " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 6 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Jun " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 7 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Jul " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 8 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Aug " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 9 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Sep " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 10 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Oct " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 11 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Nov " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 12 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Dec " )
      ENDIF
      IF ((x < size (distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year ,5 ) )
      )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ,", " )
      ENDIF
     ENDFOR
    ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 5 ) )
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = "The "
     FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month ,5
      ) )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month[x ].week_of_month
      = 1 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," 1st " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month[x ].
      week_of_month = 2 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," 2nd " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month[x ].
      week_of_month = 3 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," 3rd " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month[x ].
      week_of_month = 4 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," 4th " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month[x ].
      week_of_month = 5 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Last " )
      ENDIF
      IF ((x < size (distributions->dist[d ].related_ops[r ].related_jobs[j ].weeks_of_month ,5 ) )
      )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ,", " )
      ENDIF
     ENDFOR
     FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week ,5 ) )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week = 1
      ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Sun " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 2 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Mon " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 3 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Tue " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 4 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Wed " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 5 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Thu " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 6 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Fri " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week[x ].day_of_week
      = 7 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Sat " )
      ENDIF
      IF ((x < size (distributions->dist[d ].related_ops[r ].related_jobs[j ].days_of_week ,5 ) ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ,", " )
      ENDIF
     ENDFOR
     SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[3 ].string_value ," of " )
     FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year ,5
      ) )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].month_of_year
      = 0 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," All Months " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 1 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Jan " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 2 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Feb " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 3 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Mar " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 4 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Apr " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 5 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," May " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 6 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Jun " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 7 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Jul " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 8 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Aug " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 9 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Sep " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 10 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Oct " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 11 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Nov " )
      ELSEIF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year[x ].
      month_of_year = 12 ) )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ," Dec " )
      ENDIF
      IF ((x < size (distributions->dist[d ].related_ops[r ].related_jobs[j ].months_of_year ,5 ) )
      )
       SET reply->rowlist[row_nbr ].celllist[3 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[3 ].string_value ,", " )
      ENDIF
     ENDFOR
    ENDIF
    IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].frequency_flag = 1 ) )
     SET reply->rowlist[row_nbr ].celllist[4 ].string_value = " "
    ELSE
     IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].time_ind = 1 ) )
      SET reply->rowlist[row_nbr ].celllist[4 ].string_value = build2 ("Every " ,trim (cnvtstring (
         distributions->dist[d ].related_ops[r ].related_jobs[j ].time_interval ) ) )
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].time_interval_ind = 1 ) )
       SET reply->rowlist[row_nbr ].celllist[4 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[4 ].string_value ," hour(s) from " )
      ELSE
       SET reply->rowlist[row_nbr ].celllist[4 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[4 ].string_value ," minute(s) from " )
      ENDIF
      IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].end_effective_dt_tm <
      cnvtdatetime ("31-DEC-2500" ) ) )
       SET reply->rowlist[row_nbr ].celllist[4 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[4 ].string_value ," " ,format (cnvtdatetime (distributions->dist[d ].related_ops[r ]
          .related_jobs[j ].beg_effective_dt_tm ) ,"HH:MM;;D" ) ," to " ,format (cnvtdatetime (
          distributions->dist[d ].related_ops[r ].related_jobs[j ].end_effective_dt_tm ) ,"HH:MM;;D"
         ) )
      ELSE
       DECLARE time_string = vc
       DECLARE date_string = vc
       SET time_string = format (cnvtdatetime (distributions->dist[d ].related_ops[r ].related_jobs[
         j ].end_effective_dt_tm ) ,"HH:MM:SS;;D" )
       SET date_string = build2 ("31-DEC-2050 " ,time_string ," UTC" )
       SET reply->rowlist[row_nbr ].celllist[4 ].string_value = build2 (reply->rowlist[row_nbr ].
        celllist[4 ].string_value ," " ,format (cnvtdatetime (distributions->dist[d ].related_ops[r ]
          .related_jobs[j ].beg_effective_dt_tm ) ,"HH:MM;;D" ) ," to " ,format (cnvtdatetimeutc (
          date_string ) ,"HH:MM;;D" ) )
      ENDIF
     ELSE
      SET reply->rowlist[row_nbr ].celllist[4 ].string_value = format (distributions->dist[d ].
       related_ops[r ].related_jobs[j ].beg_effective_dt_tm ,"HH:MM;;D" )
     ENDIF
    ENDIF
    IF ((distributions->dist[d ].related_ops[r ].related_jobs[j ].journal_step_exists_ind = 1 ) )
     SET reply->rowlist[row_nbr ].celllist[5 ].string_value = "Yes"
    ELSE
     SET reply->rowlist[row_nbr ].celllist[5 ].string_value = "No"
    ENDIF
    SET reply->rowlist[row_nbr ].celllist[1 ].string_value = distributions->dist[d ].related_ops[r ].
    related_jobs[j ].ops_job_name
    IF ((j < size (distributions->dist[d ].related_ops[r ].related_jobs ,5 ) ) )
     SET row_nbr = (row_nbr + 1 )
     SET stat = alterlist (reply->rowlist ,row_nbr )
     SET stat = alterlist (reply->rowlist[row_nbr ].celllist ,57 )
     CALL setdistdetails (d )
     CALL setoperationdetails (d ,r )
    ENDIF
   ENDFOR
   IF ((r < size (distributions->dist[d ].related_ops ,5 ) ) )
    SET row_nbr = (row_nbr + 1 )
    SET stat = alterlist (reply->rowlist ,row_nbr )
    SET stat = alterlist (reply->rowlist[row_nbr ].celllist ,57 )
    CALL setdistdetails (d )
   ENDIF
  ENDFOR
 ENDFOR
 SUBROUTINE  setdistdetails (d )
  SET reply->rowlist[row_nbr ].celllist[6 ].string_value = distributions->dist[d ].description
  IF ((distributions->dist[d ].dist_type_flag = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[7 ].string_value = "Non-discharged Patients Only"
  ELSEIF ((distributions->dist[d ].dist_type_flag = 2 ) )
   SET reply->rowlist[row_nbr ].celllist[7 ].string_value = "Discharged Patients Only"
  ELSEIF ((distributions->dist[d ].dist_type_flag = 3 ) )
   SET reply->rowlist[row_nbr ].celllist[7 ].string_value =
   "Both Discharged and Non-discharged Patients"
  ENDIF
  IF ((distributions->dist[d ].dist_type_flag = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[8 ].string_value = " "
  ELSE
   SET reply->rowlist[row_nbr ].celllist[8 ].string_value = cnvtstring (distributions->dist[d ].
    days_till_chart )
  ENDIF
  SET reply->rowlist[row_nbr ].celllist[9 ].string_value = distributions->dist[d ].banner_page
  IF ((distributions->dist[d ].incl_excl_encntr_type = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[12 ].string_value = " "
  ELSEIF ((distributions->dist[d ].incl_excl_encntr_type = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[12 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].incl_excl_encntr_type = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[12 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].encntr_types ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[13 ].string_value = trim (distributions->dist[d ].
     encntr_types[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[13 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[13 ].string_value ,", " ,trim (distributions->dist[d ].encntr_types[x ].description )
     )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].incl_excl_client = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[10 ].string_value = " "
  ELSEIF ((distributions->dist[d ].incl_excl_client = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[10 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].incl_excl_client = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[10 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].clients ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[11 ].string_value = trim (distributions->dist[d ].clients[
     x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[11 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[11 ].string_value ,", " ,trim (distributions->dist[d ].clients[x ].description ) )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].incl_excl_provider = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[18 ].string_value = " "
  ELSEIF ((distributions->dist[d ].incl_excl_provider = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[18 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].incl_excl_provider = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[18 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].providers ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[19 ].string_value = trim (distributions->dist[d ].
     providers[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[19 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[19 ].string_value ,"; " ,trim (distributions->dist[d ].providers[x ].description ) )
   ENDIF
   SET reltn_cnt = size (distributions->dist[d ].providers[x ].reltns ,5 )
   FOR (y = 1 TO reltn_cnt )
    IF ((y = 1 )
    AND (reltn_cnt = 1 ) )
     SET reply->rowlist[row_nbr ].celllist[19 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[19 ].string_value ," (" ,trim (distributions->dist[d ].providers[x ].reltns[y ].
       display ) ,")" )
    ELSEIF ((y = 1 )
    AND (reltn_cnt > 1 ) )
     SET reply->rowlist[row_nbr ].celllist[19 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[19 ].string_value ," (" ,trim (distributions->dist[d ].providers[x ].reltns[y ].
       display ) )
    ELSEIF ((y = reltn_cnt ) )
     SET reply->rowlist[row_nbr ].celllist[19 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[19 ].string_value ,", " ,trim (distributions->dist[d ].providers[x ].reltns[y ].
       display ) ,")" )
    ELSE
     SET reply->rowlist[row_nbr ].celllist[19 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[19 ].string_value ,", " ,trim (distributions->dist[d ].providers[x ].reltns[y ].
       display ) )
    ENDIF
   ENDFOR
  ENDFOR
  IF ((distributions->dist[d ].incl_excl_location = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[14 ].string_value = " "
  ELSEIF ((distributions->dist[d ].incl_excl_location = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[14 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].incl_excl_location = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[14 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].locations ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[15 ].string_value = trim (distributions->dist[d ].
     locations[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[15 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[15 ].string_value ,", " ,trim (distributions->dist[d ].locations[x ].description ) )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].incl_excl_med_service = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[16 ].string_value = " "
  ELSEIF ((distributions->dist[d ].incl_excl_med_service = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[16 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].incl_excl_med_service = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[16 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].med_services ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[17 ].string_value = trim (distributions->dist[d ].
     med_services[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[17 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[17 ].string_value ,", " ,trim (distributions->dist[d ].med_services[x ].description )
     )
   ENDIF
  ENDFOR
  SET reply->rowlist[row_nbr ].celllist[20 ].string_value = distributions->dist[d ].reader_group
  IF ((distributions->dist[d ].cutoff_ind != 0 ) )
   SET reply->rowlist[row_nbr ].celllist[21 ].string_value = build2 (trim (cnvtstring (distributions
      ->dist[d ].cutoff_pages ) ) ," " ,"Pages" ," " ,trim (distributions->dist[d ].cutoff_ind_str )
    ," " ,trim (cnvtstring (distributions->dist[d ].cutoff_days ) ) ," " ,"Days" )
  ENDIF
  IF ((distributions->dist[d ].initial_lookback_ind = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[22 ].string_value = build2 (trim (format (distributions->
      dist[d ].initial_lookback_date ,"MM/DD/YYYY HH:MM;;D" ) ) )
  ELSEIF ((distributions->dist[d ].initial_lookback_ind = 3 ) )
   SET reply->rowlist[row_nbr ].celllist[22 ].string_value = build2 (trim (cnvtstring (distributions
      ->dist[d ].initial_lookback_days ) ) ," " ,"Days" )
  ENDIF
  IF ((distributions->dist[d ].first_lookback_ind = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[23 ].string_value = build2 (trim (format (distributions->
      dist[d ].first_lookback_date ,"MM/DD/YYYY HH:MM;;D" ) ) )
  ELSEIF ((((distributions->dist[d ].first_lookback_ind = 1 ) ) OR ((distributions->dist[d ].
  first_lookback_ind = 2 ) )) )
   SET reply->rowlist[row_nbr ].celllist[23 ].string_value = distributions->dist[d ].
   first_lookback_str
  ELSEIF ((distributions->dist[d ].first_lookback_ind = 3 ) )
   SET reply->rowlist[row_nbr ].celllist[23 ].string_value = build2 (trim (cnvtstring (distributions
      ->dist[d ].first_lookback_days ) ) ," " ,"Days" )
  ENDIF
  IF ((distributions->dist[d ].absolute_lookback_ind = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[24 ].string_value = build2 (trim (format (distributions->
      dist[d ].absolute_lookback_date ,"MM/DD/YYYY HH:MM;;D" ) ) )
  ELSEIF ((distributions->dist[dcnt ].absolute_lookback_ind = 3 ) )
   SET reply->rowlist[row_nbr ].celllist[24 ].string_value = build2 (trim (cnvtstring (distributions
      ->dist[d ].absolute_lookback_days ) ) ," " ,"Days" )
  ENDIF
  RETURN
 END ;Subroutine
 SUBROUTINE  setoperationdetails (d ,r )
  SET reply->rowlist[row_nbr ].celllist[26 ].string_value = distributions->dist[d ].related_ops[r ].
  run_type_display
  IF ((distributions->dist[d ].related_ops[r ].scope_flag = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[27 ].string_value = "Person Level"
  ELSEIF ((distributions->dist[d ].related_ops[r ].scope_flag = 2 ) )
   SET reply->rowlist[row_nbr ].celllist[27 ].string_value = "Encounter Level"
  ELSEIF ((distributions->dist[d ].related_ops[r ].scope_flag = 4 ) )
   SET reply->rowlist[row_nbr ].celllist[27 ].string_value = "Accession Level"
  ELSEIF ((distributions->dist[d ].related_ops[r ].scope_flag = 5 ) )
   SET reply->rowlist[row_nbr ].celllist[27 ].string_value = "Cross-Encounter Level"
  ELSEIF ((distributions->dist[d ].related_ops[r ].scope_flag = 6 ) )
   SET reply->rowlist[row_nbr ].celllist[27 ].string_value = "Document Level"
  ENDIF
  SET reply->rowlist[row_nbr ].celllist[37 ].string_value = distributions->dist[d ].related_ops[r ].
  sort_seq_display
  IF ((distributions->dist[d ].related_ops[r ].print_finals_ind = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[30 ].string_value = "Yes"
  ELSE
   SET reply->rowlist[row_nbr ].celllist[30 ].string_value = "No"
  ENDIF
  SET reply->rowlist[row_nbr ].celllist[28 ].string_value = distributions->dist[d ].related_ops[r ].
  chart_format_desc
  IF ((distributions->dist[d ].related_ops[r ].dist_routing_flag = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[36 ].string_value = "Assigned Device"
  ELSEIF ((distributions->dist[d ].related_ops[r ].dist_routing_flag = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[36 ].string_value = "Organization/Client"
  ELSEIF ((distributions->dist[d ].related_ops[r ].dist_routing_flag = 2 ) )
   SET reply->rowlist[row_nbr ].celllist[36 ].string_value = "Patient Location"
  ELSEIF ((distributions->dist[d ].related_ops[r ].dist_routing_flag = 3 ) )
   SET reply->rowlist[row_nbr ].celllist[36 ].string_value = "Order Location"
  ELSEIF ((distributions->dist[d ].related_ops[r ].dist_routing_flag = 4 ) )
   SET reply->rowlist[row_nbr ].celllist[36 ].string_value = "Patient Location at Time of Order"
  ELSEIF ((distributions->dist[d ].related_ops[r ].dist_routing_flag = 5 ) )
   SET reply->rowlist[row_nbr ].celllist[36 ].string_value = "Provider Types Selected"
  ENDIF
  DECLARE order_prov_disp = vc
  IF ((distributions->dist[d ].related_ops[r ].order_prov_flag = 0 ) )
   SET order_prov_disp = "Original Ordering Physician"
  ELSEIF ((distributions->dist[d ].related_ops[r ].order_prov_flag = 1 ) )
   SET order_prov_disp = "Current Ordering Physician"
  ELSEIF ((distributions->dist[d ].related_ops[r ].order_prov_flag = 2 ) )
   SET order_prov_disp = "Original and Current Ordering Physician"
  ELSEIF ((distributions->dist[d ].related_ops[r ].order_prov_flag = 3 ) )
   SET order_prov_disp = "All Ordering Physicians"
  ENDIF
  IF ((distributions->dist[d ].related_ops[r ].copy_to_prov_types[1 ].display = "ALL" ) )
   SET reply->rowlist[row_nbr ].celllist[31 ].string_value = build2 ("ALL (" ,order_prov_disp ,")" )
  ELSE
   FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].copy_to_prov_types ,5 ) )
    IF ((x = 1 ) )
     IF ((distributions->dist[d ].related_ops[r ].copy_to_prov_types[x ].code_value = order_doc_cd )
     )
      SET reply->rowlist[row_nbr ].celllist[31 ].string_value = build2 (trim (distributions->dist[d ]
        .related_ops[r ].copy_to_prov_types[x ].display ) ," (" ,order_prov_disp ,")" )
     ELSE
      SET reply->rowlist[row_nbr ].celllist[31 ].string_value = trim (distributions->dist[d ].
       related_ops[r ].copy_to_prov_types[x ].display )
     ENDIF
    ELSE
     IF ((distributions->dist[d ].related_ops[r ].copy_to_prov_types[x ].code_value = order_doc_cd )
     )
      SET reply->rowlist[row_nbr ].celllist[31 ].string_value = build2 (reply->rowlist[row_nbr ].
       celllist[31 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].
        copy_to_prov_types[x ].display ) ," (" ,order_prov_disp ,")" )
     ELSE
      SET reply->rowlist[row_nbr ].celllist[31 ].string_value = build2 (reply->rowlist[row_nbr ].
       celllist[31 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].
        copy_to_prov_types[x ].display ) )
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
  IF ((distributions->dist[d ].related_ops[r ].expire_ind = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[32 ].string_value = "Yes"
  ELSE
   SET reply->rowlist[row_nbr ].celllist[32 ].string_value = "No"
  ENDIF
  IF ((distributions->dist[d ].related_ops[r ].default_chart_ind = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[33 ].string_value = "Yes"
  ELSE
   SET reply->rowlist[row_nbr ].celllist[33 ].string_value = "No"
  ENDIF
  SET reply->rowlist[row_nbr ].celllist[38 ].string_value = distributions->dist[d ].related_ops[r ].
  default_printer_name
  SET reply->rowlist[row_nbr ].celllist[39 ].string_value = distributions->dist[d ].related_ops[r ].
  file_storage_display
  IF ((((size (distributions->dist[d ].related_ops[r ].activity_holds ,5 ) > 0 ) ) OR ((size (
   distributions->dist[d ].related_ops[r ].ord_stat_holds ,5 ) > 0 ) )) )
   SET reply->rowlist[row_nbr ].celllist[43 ].string_value = "Yes"
  ELSE
   SET reply->rowlist[row_nbr ].celllist[43 ].string_value = "No"
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].activity_holds ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[44 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].activity_holds[x ].display )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[44 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[44 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].activity_holds[
      x ].display ) )
   ENDIF
  ENDFOR
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].ord_stat_holds ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[45 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].ord_stat_holds[x ].display )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[45 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[45 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].ord_stat_holds[
      x ].display ) )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].related_ops[r ].incl_excl_providers = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[34 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_providers = 2 ) )
   SET reply->rowlist[row_nbr ].celllist[34 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].provider_routings ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[35 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].provider_routings[x ].name )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[35 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[35 ].string_value ,"; " ,trim (distributions->dist[d ].related_ops[r ].
      provider_routings[x ].name ) )
   ENDIF
  ENDFOR
  SET reply->rowlist[row_nbr ].celllist[25 ].string_value = distributions->dist[d ].related_ops[r ].
  batch_name
  SET reply->rowlist[row_nbr ].celllist[29 ].string_value = distributions->dist[d ].related_ops[r ].
  report_template_desc
  SET reply->rowlist[row_nbr ].celllist[46 ].string_value = distributions->dist[d ].related_ops[r ].
  law_name
  IF ((trim (distributions->dist[d ].related_ops[r ].law_name ) != "" ) )
   SET reply->rowlist[row_nbr ].celllist[47 ].string_value = build2 (distributions->dist[d ].
    related_ops[r ].law_lookback_type ,"  " ,trim (cnvtstring (distributions->dist[d ].related_ops[r
      ].law_lookback ) ) ," " ,"Days" )
  ENDIF
  SET reply->rowlist[row_nbr ].celllist[40 ].string_value = distributions->dist[d ].related_ops[r ].
  filename
  SET reply->rowlist[row_nbr ].celllist[41 ].string_value = distributions->dist[d ].related_ops[r ].
  network_file_dest
  SET reply->rowlist[row_nbr ].celllist[42 ].string_value = distributions->dist[d ].related_ops[r ].
  ftp_dest
  IF ((distributions->dist[d ].related_ops[r ].incl_excl_encntr_type = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[50 ].string_value = " "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_encntr_type = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[50 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_encntr_type = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[50 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].encntr_types ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[51 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].encntr_types[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[51 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[51 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].encntr_types[x ]
      .description ) )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].related_ops[r ].incl_excl_client = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[48 ].string_value = " "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_client = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[48 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_client = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[48 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].clients ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[49 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].clients[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[49 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[49 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].clients[x ].
      description ) )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].related_ops[r ].incl_excl_provider = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[56 ].string_value = " "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_provider = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[56 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_provider = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[56 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].providers ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[57 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].providers[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[57 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[57 ].string_value ,"; " ,trim (distributions->dist[d ].related_ops[r ].providers[x ].
      description ) )
   ENDIF
   SET reltn_cnt = size (distributions->dist[d ].related_ops[r ].providers[x ].reltns ,5 )
   FOR (y = 1 TO reltn_cnt )
    IF ((y = 1 )
    AND (reltn_cnt = 1 ) )
     SET reply->rowlist[row_nbr ].celllist[57 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[57 ].string_value ," (" ,trim (distributions->dist[d ].related_ops[r ].providers[x ].
       reltns[y ].display ) ,")" )
    ELSEIF ((y = 1 )
    AND (reltn_cnt > 1 ) )
     SET reply->rowlist[row_nbr ].celllist[57 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[57 ].string_value ," (" ,trim (distributions->dist[d ].related_ops[r ].providers[x ].
       reltns[y ].display ) )
    ELSEIF ((y = reltn_cnt ) )
     SET reply->rowlist[row_nbr ].celllist[57 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[57 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].providers[x ].
       reltns[y ].display ) ,")" )
    ELSE
     SET reply->rowlist[row_nbr ].celllist[57 ].string_value = build2 (reply->rowlist[row_nbr ].
      celllist[57 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].providers[x ].
       reltns[y ].display ) )
    ENDIF
   ENDFOR
  ENDFOR
  IF ((distributions->dist[d ].related_ops[r ].incl_excl_location = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[52 ].string_value = " "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_location = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[52 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_location = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[52 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].locations ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[53 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].locations[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[53 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[53 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].locations[x ].
      description ) )
   ENDIF
  ENDFOR
  IF ((distributions->dist[d ].related_ops[r ].incl_excl_med_service = 99 ) )
   SET reply->rowlist[row_nbr ].celllist[54 ].string_value = " "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_med_service = 1 ) )
   SET reply->rowlist[row_nbr ].celllist[54 ].string_value = "Include "
  ELSEIF ((distributions->dist[d ].related_ops[r ].incl_excl_med_service = 0 ) )
   SET reply->rowlist[row_nbr ].celllist[54 ].string_value = "Exclude "
  ENDIF
  FOR (x = 1 TO size (distributions->dist[d ].related_ops[r ].med_services ,5 ) )
   IF ((x = 1 ) )
    SET reply->rowlist[row_nbr ].celllist[55 ].string_value = trim (distributions->dist[d ].
     related_ops[r ].med_services[x ].description )
   ELSE
    SET reply->rowlist[row_nbr ].celllist[55 ].string_value = build2 (reply->rowlist[row_nbr ].
     celllist[55 ].string_value ,", " ,trim (distributions->dist[d ].related_ops[r ].med_services[x ]
      .description ) )
   ENDIF
  ENDFOR
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1 ,
 2 ) ) )
  SET reply->output_filename = build ("clinical_reporting_distributions_audit.csv" )
 ENDIF
 IF ((request->output_filename > " " ) )
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript (0 )
END GO


DROP PROGRAM cov_fb_get_clinical_events :dba GO
CREATE PROGRAM cov_fb_get_clinical_events :dba
 SET lvl_error = 0
 SET lvl_warning = 1
 SET lvl_audit = 2
 SET lvl_info = 3
 SET lvl_debug = 4
 SET log_to_reply = 1
 SET log_to_screen = 0
 SET log_msg = fillstring (100 ," " )
 DECLARE sn_log_message (log_level ,log_reply ,log_event ,log_mesg ) = null WITH protected
 SUBROUTINE  sn_log_message (log_level ,log_reply ,log_event ,log_mesg )
  SET sn_log_level = evaluate (log_level ,lvl_error ,"E" ,lvl_warning ,"W" ,lvl_audit ,"A" ,lvl_info
   ,"I" ,lvl_debug ,"D" ,"U" )
  IF ((log_reply = log_to_reply ) )
   SET num_event = size (reply->status_data.subeventstatus ,5 )
   IF ((num_event = 1 ) )
    IF ((trim (reply->status_data.subeventstatus[1 ].targetobjectname ) > "" ) )
     SET num_event = (num_event + 1 )
    ENDIF
   ELSE
    SET num_event = (num_event + 1 )
   ENDIF
   SET stat = alter (reply->status_data.subeventstatus ,num_event )
   SET reply->status_data.subeventstatus[num_event ].operationname = log_event
   SET reply->status_data.subeventstatus[num_event ].operationstatus = sn_log_level
   SET reply->status_data.subeventstatus[num_event ].targetobjectname = curprog
   SET reply->status_data.subeventstatus[num_event ].targetobjectvalue = log_mesg
  ELSE
   CALL echo ("-----------------" )
   CALL echo (build ("Event           :" ,log_event ) )
   CALL echo (build ("Status          :" ,sn_log_level ) )
   CALL echo (build ("Current Program :" ,curprog ) )
   CALL echo (build ("Message         :" ,log_mesg ) )
  ENDIF
 END ;Subroutine
 IF ((request->print_ind > 0 ) )
  IF (NOT (validate (reply ,0 ) ) )
   RECORD reply (
     1 user_id = f8
     1 segment_results [* ]
       2 input_form_cd = f8
       2 input_form_disp = vc
       2 input_form_version_nbr = i4
       2 event_cd = f8
       2 clinical_event_id = f8
       2 event_id = f8
       2 surg_proc_event_id = f8
       2 seg_cd = f8
       2 notes [* ]
         3 note = vc
         3 note_rtf = vc
         3 note_type_cd = f8
         3 note_type_disp = vc
         3 note_type_desc = vc
         3 note_type_mean = vc
         3 event_note_id = f8
         3 ce_event_note_id = f8
       2 entries [* ]
         3 result_status_flag = i2
         3 modified_by_disp = c20
         3 updt_id = f8
         3 updt_dt_tm = dq8
         3 groups [* ]
           4 group_cd = f8
           4 group_prompt = vc
           4 repeat_ind = i2
           4 controls [* ]
             5 task_assay_cd = f8
             5 task_assay_mean = c12
             5 event_cd = f8
             5 result_type_meaning = c5
             5 control_type_flag = i2
             5 field_prompt = vc
             5 required_flag = i2
             5 validation_codeset = i4
             5 result_parent_table = vc
             5 values [* ]
               6 val_id = vc
               6 val_disp = vc
               6 val_disp2 = vc
               6 event_id = f8
               6 val_dt_tm = dq8
             5 signatures [* ]
               6 event_id = f8
               6 cosign_ind = i2
               6 action_prsnl_id = f8
               6 action_dt_tm = dq8
               6 action_comment = vc
               6 action_prsnl_name = vc
       2 signatures [* ]
         3 event_id = f8
         3 cosign_ind = i2
         3 action_prsnl_id = f8
         3 action_dt_tm = dq8
         3 action_comment = vc
         3 action_prsnl_name = vc
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
 ELSE
  IF (NOT (validate (reply ,0 ) ) )
   RECORD reply (
     1 user_id = f8
     1 segment_results [* ]
       2 input_form_cd = f8
       2 input_form_version_nbr = i4
       2 event_cd = f8
       2 clinical_event_id = f8
       2 event_id = f8
       2 surg_proc_event_id = f8
       2 seg_cd = f8
       2 notes [* ]
         3 note = vc
         3 note_rtf = vc
         3 note_type_cd = f8
         3 note_type_disp = vc
         3 note_type_desc = vc
         3 note_type_mean = vc
         3 event_note_id = f8
         3 ce_event_note_id = f8
       2 entries [* ]
         3 updt_id = f8
         3 updt_dt_tm = dq8
         3 groups [* ]
           4 group_cd = f8
           4 group_prompt = vc
           4 repeat_ind = i2
           4 controls [* ]
             5 task_assay_cd = f8
             5 event_cd = f8
             5 field_prompt = vc
             5 task_assay_mean = c12
             5 result_type_meaning = c5
             5 control_type_flag = i2
             5 validation_codeset = i4
             5 result_parent_table = vc
             5 values [* ]
               6 val_id = vc
               6 val_disp = vc
               6 val_disp2 = vc
               6 event_id = f8
               6 val_dt_tm = dq8
             5 signatures [* ]
               6 event_id = f8
               6 cosign_ind = i2
               6 action_prsnl_id = f8
               6 action_dt_tm = dq8
               6 action_comment = vc
               6 action_prsnl_name = vc
       2 signatures [* ]
         3 event_id = f8
         3 cosign_ind = i2
         3 action_prsnl_id = f8
         3 action_dt_tm = dq8
         3 action_comment = vc
         3 action_prsnl_name = vc
       2 sup_cab_def_ind = i2
       2 default_data_present_ind = i2
       2 default_data_qual [* ]
         3 default_data_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
 ENDIF
 FREE RECORD tempreq
 RECORD tempreq (
   1 eventids [* ]
     2 event_id = f8
 )
 FREE RECORD tempreply
 RECORD tempreply (
   1 surgprocids [* ]
     2 dsurgprocid = f8
     2 modifier_string = vc
 )
 DECLARE getmodifiers ((param = i4 ) ) = null
 DECLARE getresultval ((descriptor = vc ) ) = vc
 SUBROUTINE  getmodifiers (param )
  DECLARE iproccnt = i4 WITH noconstant (0 )
  DECLARE mod_string = vc WITH noconstant
  DECLARE sz = i4 WITH noconstant (0 )
  SET sz = size (tempreq->eventids ,5 )
  SELECT INTO "nl:"
   ccr.event_id
   FROM (ce_coded_result ccr ),
    (surg_case_procedure scp ),
    (dummyt d1 WITH seq = value (sz ) )
   PLAN (d1 )
    JOIN (ccr
    WHERE (ccr.event_id = tempreq->eventids[d1.seq ].event_id )
    AND (ccr.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (ccr.event_id > 0.0 ) )
    JOIN (scp
    WHERE (scp.surg_case_proc_id > 0.0 )
    AND (scp.surg_case_proc_id = cnvtreal (ccr.descriptor ) ) )
   DETAIL
    iproccnt = (iproccnt + 1 ) ,
    stat = alterlist (tempreply->surgprocids ,iproccnt ) ,
    tempreply->surgprocids[iproccnt ].dsurgprocid = cnvtreal (ccr.descriptor ) ,
    IF ((((scp.sched_modifier != "" ) ) OR ((scp.sched_modifier != null ) ))
    AND (((scp.modifier = "" ) ) OR ((scp.modifier = null ) ))
    AND (scp.surg_proc_cd <= 0.0 ) ) tempreply->surgprocids[iproccnt ].modifier_string = scp
     .sched_modifier
    ELSE tempreply->surgprocids[iproccnt ].modifier_string = scp.modifier
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getresultval (descriptor )
  DECLARE proc_idx = i4 WITH noconstant (0 )
  DECLARE modi_idx = i4 WITH noconstant (0 )
  DECLARE resultval = vc WITH noconstant
  SET proc_idx = locateval (modi_idx ,1 ,size (tempreply->surgprocids ,5 ) ,cnvtreal (descriptor ) ,
   tempreply->surgprocids[modi_idx ].dsurgprocid )
  IF ((tempreply->surgprocids[proc_idx ].modifier_string != "" ) )
   SET resultval = build (trim (uar_get_code_display (ccr.result_cd ) ) ,"(" ,tempreply->surgprocids[
    proc_idx ].modifier_string ,")" )
  ELSE
   SET resultval = uar_get_code_display (ccr.result_cd )
  ENDIF
  RETURN (resultval )
 END ;Subroutine
 IF (NOT (validate (internal_idx ,0 ) ) )
  RECORD internal_idx (
    1 ids [* ]
      2 event_id = f8
      2 form_idx = i2
      2 entry_idx = i2
      2 grp_idx = i2
      2 cntrl_idx = i2
      2 result_type_meaning = vc
      2 result_units_cd = f8
      2 task_assay_mean = vc
  )
 ENDIF
 IF (NOT (validate (internal ,0 ) ) )
  RECORD internal (
    1 specialties [* ]
      2 event_id = f8
  )
 ENDIF
 FREE RECORD primsynidx
 RECORD primsynidx (
   1 idx [* ]
     2 f_idx = i2
     2 e_idx = i2
     2 g_idx = i2
     2 c_idx = i2
     2 value_cnt = i2
 )
 FREE RECORD all_events
 RECORD all_events (
   1 events [* ]
     2 event_id = f8
     2 form_idx = i4
     2 entry_idx = i4
     2 grp_idx = i4
     2 cntrl_idx = i4
     2 value_idx = i4
 )
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
 DECLARE i18nhandle = i4 WITH public ,noconstant (0 )
 SET h = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 DECLARE sno = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"Key1" ,"No" ) )
 DECLARE syes = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"Key2" ,"Yes" ) )
 DECLARE sna = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"Key3" ,"n/a" ) )
 IF (NOT (validate (format_only ,0 ) ) )
  SET format_only = "F"
 ENDIF
 IF ((validate (index_cnt ) = 0 ) )
  DECLARE index_cnt = i4 WITH noconstant (0 )
 ENDIF
 IF ((format_only = "F" ) )
  SET reply->status_data.status = "F"
  SET failure = "F"
  SET get_inventory = "F"
  SET get_coded_results = "F"
  SET get_string_results = "F"
  SET get_dates = "F"
  SET get_specialties = "F"
  SET index_cnt = 0
 ENDIF
 SET reference_nbr = concat (concat (trim (cnvtstring (request->doc_id ) ) ,request->mnemonic ) ,"*"
  )
 DECLARE m_s_proc_cpt = vc WITH protected ,constant ("PROC-CPT" )
 DECLARE m_s_prediag = vc WITH protected ,constant ("CSD-PREDESC" )
 DECLARE m_s_postdiag = vc WITH protected ,constant ("CSD-POSTDESC" )
 DECLARE m_s_assist_action = vc WITH protected ,constant ("ASSIST" )
 DECLARE m_s_sign_action = c4 WITH protected ,constant ("SIGN" )
 DECLARE m_s_cosign_action = c6 WITH protected ,constant ("COSIGN" )
 DECLARE m_s_author_action = vc WITH protected ,constant ("AUTHOR" )
 DECLARE assist_action_cd = f8 WITH protected ,noconstant (0.0 )
 DECLARE sign_action_cd = f8 WITH protected ,noconstant (0.0 )
 DECLARE cosign_action_cd = f8 WITH protected ,noconstant (0.0 )
 DECLARE primarysynonymcd = f8 WITH protected ,noconstant (0.0 )
 DECLARE m_c_delimiter = c1 WITH protected ,constant (char (160 ) )
 DECLARE m_c_separator = c1 WITH protected ,constant ("#" )
 DECLARE result = vc
 DECLARE text = vc
 DECLARE value_beg_ptr = i4
 DECLARE cur_char_ptr = i4
 DECLARE remove_delimiters_ind = i2
 SET cdf_meaning = fillstring (12 ," " )
 SET code_set = 89
 SET cdf_meaning = "POWERCHART"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET contributor_system_cd = code_value
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET record_status_cd = code_value
 SET code_set = 21
 SET cdf_meaning = m_s_sign_action
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET sign_action_cd = code_value
 SET code_set = 21
 SET cdf_meaning = m_s_cosign_action
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET cosign_action_cd = code_value
 SET code_set = 21
 SET cdf_meaning = m_s_author_action
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET action_type_cd = code_value
 SET primarysynonymcd = uar_get_code_by ("MEANING" ,6011 ,"PRIMARY" )
 IF ((format_only = "F" ) )
  DECLARE loc_idx = i4 WITH noconstant (0 )
  DECLARE idx = i4 WITH noconstant (0 )
  DECLARE reply_size = i4 WITH noconstant (0 )
  SET reply_size = size (reply->segment_results ,5 )
  SELECT INTO "nl:"
   child_ce.parent_event_id ,
   child_collating_seq = cnvtint (child_ce.collating_seq ) ,
   child_ce.event_cd ,
   child_ce.event_id
   FROM (clinical_event parent_ce ),
    (clinical_event child_ce )
   PLAN (parent_ce
    WHERE (parent_ce.reference_nbr = patstring (reference_nbr ) )
    AND (parent_ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (parent_ce.contributor_system_cd = contributor_system_cd )
    AND expand (idx ,1 ,reply_size ,parent_ce.event_cd ,reply->segment_results[idx ].event_cd )
    AND (parent_ce.record_status_cd = record_status_cd ) )
    JOIN (child_ce
    WHERE (child_ce.parent_event_id = parent_ce.event_id )
    AND (child_ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (child_ce.record_status_cd = record_status_cd ) )
   ORDER BY child_ce.parent_event_id ,
    child_collating_seq ,
    child_ce.event_cd ,
    child_ce.event_id
   HEAD REPORT
    syn_cnt = 0 ,
    entry_cnt = 0 ,
    group_cnt = 0 ,
    cntrl_cnt = 0 ,
    index_cnt = 0
   HEAD child_ce.parent_event_id
    entry_cnt = 0 ,loc_idx = locateval (idx ,1 ,reply_size ,child_ce.event_cd ,reply->
     segment_results[idx ].event_cd ) ,reply->segment_results[loc_idx ].clinical_event_id = parent_ce
    .clinical_event_id ,reply->segment_results[loc_idx ].event_id = parent_ce.event_id
   HEAD child_collating_seq
    IF ((child_collating_seq > 0 ) ) entry_cnt = (entry_cnt + 1 ) ,value_cnt = 0 ,
     IF ((entry_cnt > 1 ) ) stat = alterlist (reply->segment_results[loc_idx ].entries ,entry_cnt ) ,
      group_cnt = size (reply->segment_results[loc_idx ].entries[1 ].groups ,5 ) ,stat = alterlist (
       reply->segment_results[loc_idx ].entries[entry_cnt ].groups ,group_cnt ) ,
      FOR (x = 1 TO group_cnt )
       reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].group_prompt = reply->
       segment_results[loc_idx ].entries[1 ].groups[x ].group_prompt ,reply->segment_results[loc_idx
       ].entries[entry_cnt ].groups[x ].group_cd = reply->segment_results[loc_idx ].entries[1 ].
       groups[x ].group_cd ,reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].
       repeat_ind = reply->segment_results[loc_idx ].entries[1 ].groups[x ].repeat_ind ,cntrl_cnt =
       size (reply->segment_results[loc_idx ].entries[1 ].groups[x ].controls ,5 ) ,stat = alterlist
       (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls ,cntrl_cnt ) ,
       FOR (y = 1 TO cntrl_cnt )
        reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].field_prompt =
        reply->segment_results[loc_idx ].entries[1 ].groups[x ].controls[y ].field_prompt ,reply->
        segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].task_assay_cd = reply->
        segment_results[loc_idx ].entries[1 ].groups[x ].controls[y ].task_assay_cd ,reply->
        segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].task_assay_mean = reply
        ->segment_results[loc_idx ].entries[1 ].groups[x ].controls[y ].task_assay_mean ,reply->
        segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].result_type_meaning =
        reply->segment_results[loc_idx ].entries[1 ].groups[x ].controls[y ].result_type_meaning ,
        reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
        control_type_flag = reply->segment_results[loc_idx ].entries[1 ].groups[x ].controls[y ].
        control_type_flag
       ENDFOR
      ENDFOR
     ENDIF
     ,reply->segment_results[loc_idx ].entries[entry_cnt ].updt_id = child_ce.updt_id ,reply->
     segment_results[loc_idx ].entries[entry_cnt ].updt_dt_tm = child_ce.updt_dt_tm
    ENDIF
   HEAD child_ce.event_id
    IF ((child_collating_seq > 0 ) ) value_cnt = 0 ,prev_event_id = 0
    ENDIF
   DETAIL
    IF ((child_collating_seq > 0 ) )
     FOR (x = 1 TO size (reply->segment_results[loc_idx ].entries[entry_cnt ].groups ,5 ) )
      FOR (y = 1 TO size (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls ,
       5 ) )
       IF ((reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
       task_assay_cd = child_ce.task_assay_cd ) ) index_cnt = (index_cnt + 1 ) ,stat = alterlist (
         internal_idx->ids ,index_cnt ) ,internal_idx->ids[index_cnt ].event_id = child_ce.event_id ,
        internal_idx->ids[index_cnt ].form_idx = loc_idx ,internal_idx->ids[index_cnt ].entry_idx =
        entry_cnt ,internal_idx->ids[index_cnt ].grp_idx = x ,internal_idx->ids[index_cnt ].cntrl_idx
         = y ,internal_idx->ids[index_cnt ].result_type_meaning = reply->segment_results[loc_idx ].
        entries[entry_cnt ].groups[x ].controls[y ].result_type_meaning ,internal_idx->ids[index_cnt
        ].task_assay_mean = reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[
        y ].task_assay_mean ,internal_idx->ids[index_cnt ].result_units_cd = child_ce
        .result_units_cd ,stat = alterlist (all_events->events ,index_cnt ) ,all_events->events[
        index_cnt ].event_id = child_ce.event_id ,all_events->events[index_cnt ].form_idx = loc_idx ,
        all_events->events[index_cnt ].entry_idx = entry_cnt ,all_events->events[index_cnt ].grp_idx
        = x ,all_events->events[index_cnt ].cntrl_idx = y ,all_events->events[index_cnt ].value_idx
        = (size (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].values
         ,5 ) + 1 ) ,
        IF ((trim (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
         result_type_meaning ,3 ) = "15" )
        AND (size (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
         values ,5 ) = 0 ) )
         IF ((child_ce.catalog_cd != null ) ) syn_cnt = (syn_cnt + 1 ) ,
          IF ((syn_cnt > size (primsynidx->idx ,5 ) ) ) stat = alterlist (primsynidx->idx ,(syn_cnt
            + 9 ) )
          ENDIF
          ,primsynidx->idx[syn_cnt ].f_idx = loc_idx ,primsynidx->idx[syn_cnt ].e_idx = entry_cnt ,
          primsynidx->idx[syn_cnt ].g_idx = x ,primsynidx->idx[syn_cnt ].c_idx = y ,primsynidx->idx[
          syn_cnt ].value_cnt = (size (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x
           ].controls[y ].values ,5 ) + 1 )
         ENDIF
         ,
         IF ((child_ce.catalog_cd = null )
         AND (child_ce.result_val = null ) )
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ," " ," " ,"" ,0 )
         ELSEIF ((child_ce.catalog_cd != null )
         AND (child_ce.result_val = null ) )
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ,cnvtstring (child_ce
           .catalog_cd ) ," " ,"" ,0 )
         ELSEIF ((child_ce.catalog_cd = null )
         AND (child_ce.result_val != null ) )
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ," " ,trim (child_ce
           .result_val ) ,"" ,0 )
         ELSE
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ,cnvtstring (child_ce
           .catalog_cd ) ,trim (child_ce.result_val ) ,"" ,0 )
         ENDIF
        ELSEIF ((trim (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
         result_type_meaning ,3 ) = "18" )
        AND (size (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
         values ,5 ) = 0 ) )
         IF ((((findstring ("NO" ,cnvtupper (trim (child_ce.result_val ) ) ) > 0 ) ) OR ((findstring
         ("FALSE" ,cnvtupper (trim (child_ce.result_val ) ) ) > 0 ) )) )
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ,"0" ,sno ,"" ,0 )
         ELSEIF ((((findstring ("YES" ,cnvtupper (trim (child_ce.result_val ) ) ) > 0 ) ) OR ((
         findstring ("TRUE" ,cnvtupper (trim (child_ce.result_val ) ) ) > 0 ) )) )
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ,"1" ,syes ,"" ,0 )
         ELSEIF ((findstring ("N/A" ,cnvtupper (trim (child_ce.result_val ) ) ) > 0 ) )
          CALL insert_value (loc_idx ,entry_cnt ,x ,y ,child_ce.event_id ,"2" ,sna ,"" ,0 )
         ENDIF
        ELSE
         IF ((trim (reply->segment_results[loc_idx ].entries[entry_cnt ].groups[x ].controls[y ].
          task_assay_mean ) IN ("CSD_SPECIAL" ,
         "PROC-SERVICE" ) ) ) get_specialties = "T"
         ELSE
          CASE (trim (internal_idx->ids[index_cnt ].result_type_meaning ) )
           OF "6" :
           OF "10" :
           OF "11" :
            get_dates = "T"
           OF "16" :
            get_inventory = "T" ,
            get_string_results = "T"
           OF "2" :
            get_coded_results = "T"
           OF "3" :
           OF "7" :
            get_string_results = "T"
          ENDCASE
         ENDIF
        ENDIF
       ENDIF
      ENDFOR
     ENDFOR
    ENDIF
   FOOT REPORT
    stat = alterlist (primsynidx->idx ,syn_cnt )
   WITH nocounter
  ;end select
  CALL echo ("****************" )
  CALL echo (build ("get_dates           [" ,get_dates ,"]" ) )
  CALL echo (build ("get_specialties     [" ,get_specialties ,"]" ) )
  CALL echo (build ("get_inventory       [" ,get_inventory ,"]" ) )
  CALL echo (build ("get_coded_results   [" ,get_coded_results ,"]" ) )
  CALL echo (build ("get_string_resultes [" ,get_string_results ,"]" ) )
  CALL echo ("****************" )
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
    "No child clinical events found." )
   GO TO exit_script
  ENDIF
  DECLARE all_events_size = i4 WITH noconstant (0 )
  SET all_events_size = size (all_events->events ,5 )
  IF ((all_events_size > 0 ) )
   SELECT INTO "nl:"
    cep.event_id
    FROM (ce_event_prsnl cep ),
     (dummyt d1 WITH seq = size (all_events->events ,5 ) )
    PLAN (d1 )
     JOIN (cep
     WHERE (cep.event_id = all_events->events[d1.seq ].event_id )
     AND (cep.action_type_cd = action_type_cd ) )
    DETAIL
     reply->segment_results[all_events->events[d1.seq ].form_idx ].entries[all_events->events[d1.seq
     ].entry_idx ].updt_id = cep.action_prsnl_id ,
     reply->segment_results[all_events->events[d1.seq ].form_idx ].entries[all_events->events[d1.seq
     ].entry_idx ].updt_dt_tm = cep.action_dt_tm
    WITH nocounter
   ;end select
  ENDIF
  DECLARE nsize = i4 WITH constant (50 )
  IF (NOT (validate (idx ,0 ) ) )
   DECLARE idx = i4 WITH noconstant (0 )
  ENDIF
  IF (NOT (validate (reply_size ,0 ) ) )
   DECLARE reply_size = i4 WITH noconstant (0 )
  ENDIF
  IF (NOT (validate (loc_idx ,0 ) ) )
   DECLARE loc_idx = i4 WITH noconstant (0 )
  ENDIF
  SET reply_size = size (reply->segment_results ,5 )
  IF ((reply_size > 0 ) )
   SELECT INTO "nl:"
    cep.event_id
    FROM (ce_event_prsnl cep ),
     (prsnl p )
    PLAN (cep
     WHERE expand (idx ,1 ,reply_size ,cep.event_id ,reply->segment_results[idx ].event_id )
     AND (cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
     AND (cep.action_type_cd IN (sign_action_cd ,
     cosign_action_cd ) )
     AND (cep.event_id > 0 ) )
     JOIN (p
     WHERE (p.person_id = cep.action_prsnl_id ) )
    ORDER BY cep.event_id ,
     cep.action_dt_tm DESC
    HEAD cep.event_id
     sig_idx = 0
    DETAIL
     loc_idx = locateval (idx ,1 ,reply_size ,cep.event_id ,reply->segment_results[idx ].event_id ) ,
     WHILE ((loc_idx > 0 ) )
      sig_idx = (sig_idx + 1 ) ,stat = alterlist (reply->segment_results[loc_idx ].signatures ,
       sig_idx ) ,reply->segment_results[loc_idx ].signatures[sig_idx ].event_id = cep.event_id ,
      reply->segment_results[loc_idx ].signatures[sig_idx ].cosign_ind =
      IF ((cep.action_type_cd = cosign_action_cd ) ) 1
      ELSE 0
      ENDIF
      ,reply->segment_results[loc_idx ].signatures[sig_idx ].action_prsnl_id = cep.action_prsnl_id ,
      reply->segment_results[loc_idx ].signatures[sig_idx ].action_dt_tm = cep.action_dt_tm ,reply->
      segment_results[loc_idx ].signatures[sig_idx ].action_comment = cep.action_comment ,reply->
      segment_results[loc_idx ].signatures[sig_idx ].action_prsnl_name = trim (p.name_full_formatted
       ) ,loc_idx = locateval (idx ,(loc_idx + 1 ) ,reply_size ,cep.event_id ,reply->segment_results[
       idx ].event_id )
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((index_cnt > 0 ) )
  SET code_set = 21
  SET cdf_meaning = m_s_assist_action
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  SET assist_action_cd = code_value
  SELECT INTO "nl:"
   cep.event_id ,
   order_index = locateval (idx ,1 ,index_cnt ,cep.event_id ,internal_idx->ids[idx ].event_id )
   FROM (ce_event_prsnl cep ),
    (prsnl p )
   PLAN (cep
    WHERE expand (idx ,1 ,index_cnt ,cep.event_id ,internal_idx->ids[idx ].event_id )
    AND (cep.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (cep.action_type_cd IN (assist_action_cd ,
    sign_action_cd ,
    cosign_action_cd ) )
    AND (cep.event_id > 0 ) )
    JOIN (p
    WHERE (p.person_id = cep.action_prsnl_id ) )
   ORDER BY order_index
   HEAD REPORT
    sig_idx = 0
   DETAIL
    loc_idx = locateval (idx ,1 ,index_cnt ,cep.event_id ,internal_idx->ids[idx ].event_id ) ,
    WHILE ((loc_idx > 0 ) )
     form_idx = internal_idx->ids[loc_idx ].form_idx ,entry_idx = internal_idx->ids[loc_idx ].
     entry_idx ,grp_idx = internal_idx->ids[loc_idx ].grp_idx ,cntrl_idx = internal_idx->ids[loc_idx
     ].cntrl_idx ,
     CASE (cep.action_type_cd )
      OF assist_action_cd :
       IF ((p.name_full_formatted = null )
       AND (cep.action_prsnl_id = null ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[loc_idx ].
        event_id ," " ," " ,"" ,0 )
       ELSEIF ((p.name_full_formatted = null )
       AND (cep.action_prsnl_id != null ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[loc_idx ].
        event_id ,cnvtstring (cep.action_prsnl_id ) ," " ,"" ,0 )
       ELSEIF ((cep.action_prsnl_id = null )
       AND (p.name_full_formatted != null ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[loc_idx ].
        event_id ," " ,trim (p.name_full_formatted ,1 ) ,"" ,0 )
       ELSE
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[loc_idx ].
        event_id ,cnvtstring (cep.action_prsnl_id ) ,trim (p.name_full_formatted ,1 ) ,"" ,0 )
       ENDIF
      OF sign_action_cd :
      OF cosign_action_cd :
       sig_idx = (size (reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].
        controls[cntrl_idx ].signatures ,5 ) + 1 ) ,
       stat = alterlist (reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].
        controls[cntrl_idx ].signatures ,sig_idx ) ,
       reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
       signatures[sig_idx ].event_id = cep.event_id ,
       reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
       signatures[sig_idx ].cosign_ind =
       IF ((cep.action_type_cd = cosign_action_cd ) ) 1
       ELSE 0
       ENDIF
       ,
       reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
       signatures[sig_idx ].action_prsnl_id = cep.action_prsnl_id ,
       reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
       signatures[sig_idx ].action_dt_tm = cep.action_dt_tm ,
       reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
       signatures[sig_idx ].action_comment = cep.action_comment ,
       reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
       signatures[sig_idx ].action_prsnl_name = trim (p.name_full_formatted )
     ENDCASE
     ,loc_idx = locateval (idx ,(loc_idx + 1 ) ,index_cnt ,cep.event_id ,internal_idx->ids[idx ].
      event_id )
    ENDWHILE
   WITH nocounter
  ;end select
 ENDIF
 IF ((curqual = 0 ) )
  CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
   "No event personnel found documented." )
 ENDIF
 IF ((get_dates = "T" ) )
  SELECT INTO "nl:"
   cdr.event_id ,
   form_idx = internal_idx->ids[d1.seq ].form_idx ,
   entry_idx = internal_idx->ids[d1.seq ].entry_idx ,
   grp_idx = internal_idx->ids[d1.seq ].grp_idx ,
   cntrl_idx = internal_idx->ids[d1.seq ].cntrl_idx
   FROM (ce_date_result cdr ),
    (dummyt d1 WITH seq = value (index_cnt ) )
   PLAN (d1
    WHERE (trim (internal_idx->ids[d1.seq ].result_type_meaning ) IN ("6" ,
    "10" ,
    "11" ) ) )
    JOIN (cdr
    WHERE (cdr.event_id = internal_idx->ids[d1.seq ].event_id )
    AND (cdr.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (cdr.event_id > 0 ) )
   DETAIL
    IF ((cdr.result_dt_tm != null ) )
     IF ((internal_idx->ids[d1.seq ].result_type_meaning = "6" ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,format (cdr.result_dt_tm ,"YYYYMMDDHHMMSSCC" ) ,format (cdr.result_dt_tm ,"@SHORTDATE" ) ,""
      ,cnvtdatetime (cdr.result_dt_tm ) )
     ELSEIF ((internal_idx->ids[d1.seq ].result_type_meaning = "10" ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,format (cdr.result_dt_tm ,"YYYYMMDDHHMMSSCC" ) ,format (cdr.result_dt_tm ,"@TIMENOSECONDS" )
      ,"" ,cnvtdatetime (cdr.result_dt_tm ) )
     ELSE
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,format (cdr.result_dt_tm ,"YYYYMMDDHHMMSSCC" ) ,format (cdr.result_dt_tm ,"@SHORTDATETIME" )
      ,"" ,cnvtdatetime (cdr.result_dt_tm ) )
     ENDIF
    ELSE
     CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
     ," " ," " ,"" ,0 )
    ENDIF
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
    "No dates found documented." )
  ENDIF
 ENDIF
 IF ((get_inventory = "T" ) )
  SELECT INTO "nl:"
   cir.event_id ,
   form_idx = internal_idx->ids[d1.seq ].form_idx ,
   entry_idx = internal_idx->ids[d1.seq ].entry_idx ,
   grp_idx = internal_idx->ids[d1.seq ].grp_idx ,
   cntrl_idx = internal_idx->ids[d1.seq ].cntrl_idx
   FROM (ce_inventory_result cir ),
    (dummyt d1 WITH seq = value (index_cnt ) )
   PLAN (d1
    WHERE (trim (internal_idx->ids[d1.seq ].result_type_meaning ) = "16" ) )
    JOIN (cir
    WHERE (cir.event_id = internal_idx->ids[d1.seq ].event_id )
    AND (cir.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (cir.event_id > 0 ) )
   DETAIL
    IF ((cir.description = null )
    AND (cir.item_id = null ) )
     CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
     ," " ," " ,"" ,0 )
    ELSEIF ((cir.description = null )
    AND (cir.item_id != null ) )
     CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
     ,cnvtstring (cir.item_id ) ," " ,"" ,0 )
    ELSEIF ((cir.item_id = null )
    AND (cir.description != null ) )
     CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
     ," " ,trim (cir.description ) ,"" ,0 )
    ELSE
     CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
     ,cnvtstring (cir.item_id ) ,trim (cir.description ) ,trim (cir.item_nbr ) ,0 )
    ENDIF
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
    "No inventory items found documented." )
  ENDIF
 ENDIF
 IF ((get_specialties = "T" ) )
  SET specialty_cnt = 0
  SELECT INTO "nl:"
   ccr.event_id ,
   form_idx = internal_idx->ids[d1.seq ].form_idx ,
   entry_idx = internal_idx->ids[d1.seq ].entry_idx ,
   grp_idx = internal_idx->ids[d1.seq ].grp_idx ,
   cntrl_idx = internal_idx->ids[d1.seq ].cntrl_idx
   FROM (ce_coded_result ccr ),
    (prsnl_group pg ),
    (dummyt d1 WITH seq = value (index_cnt ) )
   PLAN (d1
    WHERE (trim (internal_idx->ids[d1.seq ].result_type_meaning ) = "2" ) )
    JOIN (ccr
    WHERE (ccr.event_id = internal_idx->ids[d1.seq ].event_id )
    AND (ccr.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (ccr.event_id > 0 ) )
    JOIN (pg
    WHERE (pg.prsnl_group_id = ccr.result_cd ) )
   DETAIL
    IF ((pg.prsnl_group_id > 0 )
    AND (reply->segment_results[form_idx ].entries[entry_idx ].groups[grp_idx ].controls[cntrl_idx ].
    task_assay_mean IN ("CSD_SPECIAL" ,
    "PROC-SERVICE" ) ) ) specialty_cnt = (specialty_cnt + 1 ) ,stat = alterlist (internal->
      specialties ,specialty_cnt ) ,internal->specialties[specialty_cnt ].event_id = ccr.event_id ,
     IF ((request->print_ind = 1 ) ) reply->segment_results[form_idx ].entries[entry_idx ].groups[
      grp_idx ].controls[cntrl_idx ].result_parent_table = "PRSNL_GROUP"
     ENDIF
     ,
     IF ((pg.prsnl_group_name = null )
     AND (pg.prsnl_group_id = null ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ," " ," " ,"" ,0 )
     ELSEIF ((pg.prsnl_group_name = null )
     AND (pg.prsnl_group_id != null ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,cnvtstring (pg.prsnl_group_id ) ," " ,"" ,0 )
     ELSEIF ((pg.prsnl_group_id = null )
     AND (pg.prsnl_group_name != null ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ," " ,trim (pg.prsnl_group_name ) ,"" ,0 )
     ELSE
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,cnvtstring (pg.prsnl_group_id ) ,trim (pg.prsnl_group_name ) ,"" ,0 )
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
    "No specialties found documented." )
  ENDIF
 ENDIF
 DECLARE idx = i4 WITH noconstant (0 )
 DECLARE event_cnt = i4 WITH noconstant (0 )
 DECLARE mod_str = vc
 FOR (idx = 1 TO value (index_cnt ) )
  IF ((trim (internal_idx->ids[idx ].result_type_meaning ) = "2" )
  AND (trim (internal_idx->ids[idx ].task_assay_mean ) = "CASEPROC" ) )
   SET event_cnt = (event_cnt + 1 )
   SET stat = alterlist (tempreq->eventids ,event_cnt )
   SET tempreq->eventids[event_cnt ].event_id = internal_idx->ids[idx ].event_id
  ENDIF
 ENDFOR
 CALL getmodifiers (0 )
 IF ((get_coded_results = "T" ) )
  SET specialty_exist_ind = 0
  SELECT INTO "nl:"
   ccr.event_id ,
   form_idx = internal_idx->ids[d1.seq ].form_idx ,
   entry_idx = internal_idx->ids[d1.seq ].entry_idx ,
   grp_idx = internal_idx->ids[d1.seq ].grp_idx ,
   cntrl_idx = internal_idx->ids[d1.seq ].cntrl_idx ,
   result_cd_display = uar_get_code_display (ccr.result_cd )
   FROM (ce_coded_result ccr ),
    (nomenclature n ),
    (dummyt d1 WITH seq = value (index_cnt ) )
   PLAN (d1
    WHERE (trim (internal_idx->ids[d1.seq ].result_type_meaning ) = "2" ) )
    JOIN (ccr
    WHERE (ccr.event_id = internal_idx->ids[d1.seq ].event_id )
    AND (ccr.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (ccr.event_id > 0 ) )
    JOIN (n
    WHERE (n.nomenclature_id = ccr.nomenclature_id ) )
   DETAIL
    specialty_exist_ind = 0 ,
    FOR (t = 1 TO value (size (internal->specialties ,5 ) ) )
     IF ((ccr.event_id = internal->specialties[t ].event_id ) ) specialty_exist_ind = 1 ,t = value (
       size (internal->specialties ,5 ) )
     ENDIF
    ENDFOR
    ,
    IF ((ccr.nomenclature_id > 0 ) )
     IF ((request->print_ind = 1 ) ) reply->segment_results[form_idx ].entries[entry_idx ].groups[
      grp_idx ].controls[cntrl_idx ].result_parent_table = "NOMENCLATURE"
     ENDIF
     ,
     IF ((n.source_string = null )
     AND (n.nomenclature_id = null ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ," " ," " ,"" ,0 )
     ELSEIF ((n.source_string = null )
     AND (n.nomenclature_id != null ) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,cnvtstring (n.nomenclature_id ) ," " ,"" ,0 )
     ELSEIF ((n.nomenclature_id = null )
     AND (n.source_string != null ) )
      IF ((((internal_idx->ids[d1.seq ].task_assay_mean = m_s_proc_cpt ) ) OR ((((internal_idx->ids[
      d1.seq ].task_assay_mean = m_s_prediag ) ) OR ((internal_idx->ids[d1.seq ].task_assay_mean =
      m_s_postdiag ) )) )) )
       IF ((request->cpt_display_flag = 1 ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ," " ,trim (n.source_identifier ) ,"" ,0 )
       ELSEIF ((request->cpt_display_flag = 2 ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ," " ,concat (trim (n.source_identifier ) ," " ,trim (n.source_string ) ) ,"" ,0 )
       ELSE
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ," " ,trim (n.source_string ) ,"" ,0 )
       ENDIF
      ELSE
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ," " ,trim (n.source_string ) ,"" ,0 )
      ENDIF
     ELSE
      IF ((((internal_idx->ids[d1.seq ].task_assay_mean = m_s_proc_cpt ) ) OR ((((internal_idx->ids[
      d1.seq ].task_assay_mean = m_s_prediag ) ) OR ((internal_idx->ids[d1.seq ].task_assay_mean =
      m_s_postdiag ) )) )) )
       IF ((request->cpt_display_flag = 1 ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ,cnvtstring (n.nomenclature_id ) ,trim (n.source_identifier ) ,"" ,0 )
       ELSEIF ((request->cpt_display_flag = 2 ) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ,cnvtstring (n.nomenclature_id ) ,concat (trim (n.source_identifier ) ," " ,trim (n
          .source_string ) ) ,"" ,0 )
       ELSE
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ,cnvtstring (n.nomenclature_id ) ,trim (n.source_string ) ,"" ,0 )
       ENDIF
      ELSE
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ,cnvtstring (n.nomenclature_id ) ,trim (n.source_string ) ,"" ,0 )
      ENDIF
     ENDIF
    ELSEIF ((ccr.result_cd > 0 ) )
     IF ((specialty_exist_ind = 0 ) )
      IF ((request->print_ind = 1 ) ) reply->segment_results[form_idx ].entries[entry_idx ].groups[
       grp_idx ].controls[cntrl_idx ].result_parent_table = "CODE_VALUE"
      ENDIF
      ,
      IF ((result_cd_display = null )
      AND (ccr.result_cd = null ) )
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ," " ," " ,"" ,0 )
      ELSEIF ((result_cd_display = null )
      AND (ccr.result_cd != null ) )
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ,cnvtstring (ccr.result_cd ) ," " ,"" ,0 )
      ELSEIF ((ccr.result_cd = null )
      AND (result_cd_display != null ) )
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ," " ,trim (result_cd_display ) ,"" ,0 )
      ELSEIF ((ccr.descriptor != "" )
      AND (ccr.descriptor != null ) ) mod_str = getresultval (ccr.descriptor ) ,
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ,build (cnvtstring (ccr.result_cd ) ,"-" ,ccr.descriptor ) ,mod_str ,"" ,0 )
      ELSE
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ,cnvtstring (ccr.result_cd ) ,trim (result_cd_display ) ,"" ,0 )
      ENDIF
     ENDIF
    ELSE
     CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
     ," " ," " ,"" ,0 )
    ENDIF
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
    "No coded results found documented." )
  ENDIF
 ENDIF
 IF ((get_string_results = "T" ) )
  SET remove_delimiters_ind = validate (fb_get_ce_call_origin ,1 )
  SELECT INTO "nl:"
   csr.event_id ,
   form_idx = internal_idx->ids[d1.seq ].form_idx ,
   entry_idx = internal_idx->ids[d1.seq ].entry_idx ,
   grp_idx = internal_idx->ids[d1.seq ].grp_idx ,
   cntrl_idx = internal_idx->ids[d1.seq ].cntrl_idx ,
   result_cd_display = uar_get_code_display (internal_idx->ids[d1.seq ].result_units_cd )
   FROM (ce_string_result csr ),
    (dummyt d1 WITH seq = value (index_cnt ) )
   PLAN (d1
    WHERE (trim (internal_idx->ids[d1.seq ].result_type_meaning ) IN ("3" ,
    "7" ,
    "16" ) ) )
    JOIN (csr
    WHERE (csr.event_id = internal_idx->ids[d1.seq ].event_id )
    AND (csr.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
    AND (csr.event_id > 0 ) )
   HEAD REPORT
    cur_char_ptr = 1 ,
    value_beg_ptr = 1 ,
    text = fillstring (1000 ," " ) ,
    text_char = " " ,
    text_value_len = size (trim (csr.string_result_text ,1 ) ) ,
    result = trim (csr.string_result_text ,1 )
   DETAIL
    cur_char_ptr = 1 ,
    value_beg_ptr = 1 ,
    text = fillstring (1000 ," " ) ,
    text_char = " " ,
    text_value_len = size (trim (csr.string_result_text ,1 ) ) ,
    result = trim (csr.string_result_text ,1 ) ,
    IF ((findstring (m_c_separator ,result ) = 0 )
    AND (((findstring (m_c_delimiter ,result ) = 0 ) ) OR ((remove_delimiters_ind = 0 ) )) )
     IF ((((size (trim (result ,3 ) ,1 ) = 0 ) ) OR ((result = null ) )) )
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ," " ," " ,"" ,0 )
     ELSEIF ((internal_idx->ids[d1.seq ].result_type_meaning = "3" ) )
      IF ((csr.unit_of_measure_cd > 0 ) )
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ,concat (trim (csr.string_result_text ) ," " ,cnvtstring (csr.unit_of_measure_cd ) )
       ,concat (trim (result ,1 ) ," " ,trim (result_cd_display ) ) ,"" ,0 )
      ELSE
       CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
       event_id ,trim (result ) ,trim (result ) ,"" ,0 )
      ENDIF
     ELSE
      CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].event_id
       ,trim (result ) ,trim (result ) ,"" ,0 )
     ENDIF
    ELSE
     WHILE ((cur_char_ptr <= (text_value_len + 1 ) ) )
      text_char = substring (cur_char_ptr ,1 ,result ) ,
      IF ((text_char = m_c_delimiter ) )
       IF ((remove_delimiters_ind = 1 ) ) front_of_str = notrim (substring (1 ,(cur_char_ptr - 1 ) ,
          result ) ) ,back_of_str = notrim (substring ((cur_char_ptr + 1 ) ,(text_value_len -
          cur_char_ptr ) ,result ) ) ,result = concat (front_of_str ,back_of_str ) ,text_value_len =
        size (result )
       ELSE cur_char_ptr = (cur_char_ptr + 1 )
       ENDIF
      ENDIF
      ,
      IF ((((text_char = m_c_separator ) ) OR ((cur_char_ptr > text_value_len ) )) ) text =
       substring (value_beg_ptr ,(cur_char_ptr - value_beg_ptr ) ,result ) ,
       IF ((((size (trim (text ,3 ) ,1 ) = 0 ) ) OR ((text = null ) )) )
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ," " ," " ,"" ,0 )
       ELSEIF ((internal_idx->ids[d1.seq ].result_type_meaning = "3" ) )
        IF ((csr.unit_of_measure_cd > 0 ) )
         CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
         event_id ,concat (trim (csr.string_result_text ) ," " ,cnvtstring (csr.unit_of_measure_cd )
          ) ,concat (trim (result ,1 ) ," " ,trim (result_cd_display ) ) ,"" ,0 )
        ELSE
         CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
         event_id ,trim (text ) ,trim (text ) ,"" ,0 )
        ENDIF
       ELSE
        CALL insert_value (form_idx ,entry_idx ,grp_idx ,cntrl_idx ,internal_idx->ids[d1.seq ].
        event_id ,trim (text ) ,trim (text ) ,"" ,0 )
       ENDIF
       ,text = fillstring (1000 ," " ) ,value_beg_ptr = (cur_char_ptr + 1 )
      ENDIF
      ,cur_char_ptr = (cur_char_ptr + 1 )
     ENDWHILE
    ENDIF
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"GET CLINICAL EVENTS" ,
    "No string results found documented." )
  ENDIF
 ENDIF
 IF ((size (primsynidx->idx ,5 ) > 0 ) )
  SELECT INTO "nl:"
   FROM (order_catalog_synonym ocs ),
    (dummyt d1 WITH seq = value (size (primsynidx->idx ,5 ) ) )
   PLAN (d1 )
    JOIN (ocs
    WHERE (ocs.active_ind = 1 )
    AND (ocs.mnemonic_type_cd = primarysynonymcd )
    AND (ocs.catalog_cd = cnvtreal (reply->segment_results[primsynidx->idx[d1.seq ].f_idx ].entries[
     primsynidx->idx[d1.seq ].e_idx ].groups[primsynidx->idx[d1.seq ].g_idx ].controls[primsynidx->
     idx[d1.seq ].c_idx ].values[primsynidx->idx[d1.seq ].value_cnt ].val_id ) ) )
   DETAIL
    reply->segment_results[primsynidx->idx[d1.seq ].f_idx ].entries[primsynidx->idx[d1.seq ].e_idx ].
    groups[primsynidx->idx[d1.seq ].g_idx ].controls[primsynidx->idx[d1.seq ].c_idx ].values[
    primsynidx->idx[d1.seq ].value_cnt ].val_disp = trim (ocs.mnemonic )
   WITH nocounter
  ;end select
 ENDIF
 DECLARE io_size = i4 WITH noconstant (0 )
 SET io_size = size (all_events->events ,5 )
 IF ((io_size > 0 ) )
  SELECT INTO "nl:"
   cior.io_result_id
   FROM (ce_intake_output_result cior ),
    (dummyt d1 WITH seq = value (size (all_events->events ,5 ) ) )
   PLAN (d1 )
    JOIN (cior
    WHERE (cior.event_id = all_events->events[d1.seq ].event_id ) )
   ORDER BY cior.io_result_id
   DETAIL
    reply->segment_results[all_events->events[d1.seq ].form_idx ].entries[all_events->events[d1.seq ]
    .entry_idx ].groups[all_events->events[d1.seq ].grp_idx ].controls[all_events->events[d1.seq ].
    cntrl_idx ].values[all_events->events[d1.seq ].value_idx ].val_disp2 = cnvtstring (cior
     .io_result_id )
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   CALL sn_log_message (lvl_warning ,log_to_reply ,"INTAKE_OUTPUT_RESULT" ,
    "No matching records found" )
  ENDIF
 ENDIF
 SUBROUTINE  insert_value (f_idx ,e_idx ,g_idx ,c_idx ,event_id ,val_id ,val_disp ,val_disp2 ,
  val_dt_tm )
  SET value_cnt = (size (reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[
   c_idx ].values ,5 ) + 1 )
  SET stat = alterlist (reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[c_idx
   ].values ,value_cnt )
  SET reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[c_idx ].values[
  value_cnt ].event_id = event_id
  SET reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[c_idx ].values[
  value_cnt ].val_id = val_id
  SET reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[c_idx ].values[
  value_cnt ].val_disp = val_disp
  SET reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[c_idx ].values[
  value_cnt ].val_disp2 = val_disp2
  SET reply->segment_results[f_idx ].entries[e_idx ].groups[g_idx ].controls[c_idx ].values[
  value_cnt ].val_dt_tm = val_dt_tm
 END ;Subroutine
#exit_script
 IF ((failure = "T" ) )
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo (build ("Return Status :" ,reply->status_data.status ) )
 call echorecord(reply)
END GO

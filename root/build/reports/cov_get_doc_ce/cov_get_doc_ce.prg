 
DROP PROGRAM cov_get_doc_ce :dba GO
CREATE PROGRAM cov_get_doc_ce :dba
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
 DECLARE fb_get_ce_call_origin = i2
 SET reply->status_data.status = "F"
 SET failure = "F"
 SET reply->user_id = reqinfo->updt_id
 SET cur_seg_cd = 0.0
 SET cur_seg_idx = 0
 SET cur_segment_header_id = 0.0
 SET cur_surg_case_id = 0.0
 SET surgical_procedures = "SURGPROCS"
 SET general_case_data = "CASEOVERVW"
 SET p_surgeon = "PROC-SURGEON"
 SET p_procedure = "PROC-PROCEDU"
 SET p_anesthesia_type = "PROC-ANES"
 SET p_wound_class = "PROC-WOUND"
 SET p_primary_proc = "PROC-PRIMARY"
 SET p_procedure_modifier = "PROC-MOD"
 SET p_procedure_specialty = "PROC-SERVICE"
 SET p_procedure_text = "PROC-COMM"
 SET gcd_or = "CSD-OR"
 SET gcd_specialty = "CSD_SPECIAL"
 SET gcd_wound_class = "CSD-WOUND"
 SET gcd_case_level = "CSD-CASELEVE"
 SET gcd_preop_diagnosis = "CSD-PREDESC"
 EXECUTE fb_get_form_definition
 IF ((reply->status_data.status = "F" ) )
  SET failure = "T"
  GO TO exit_script
 ENDIF
 SET fb_get_ce_call_origin = 0
 EXECUTE cov_fb_get_clinical_events
 IF ((reply->status_data.status = "F" ) )
  SET failure = "T"
  GO TO exit_script
 ENDIF
 IF ((request->mnemonic = "SN" )
 AND (reply->status_data.status = "S" ) )
  EXECUTE sn_get_ce_comments
  IF ((reply->status_data.status = "F" ) )
   SET failure = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (segment_header sh ),
   (dummyt d1 WITH seq = value (size (reply->segment_results ,5 ) ) )
  PLAN (d1 )
   JOIN (sh
   WHERE (sh.periop_doc_id = request->doc_id )
   AND (sh.input_form_cd = reply->segment_results[d1.seq ].input_form_cd ) )
  DETAIL
   reply->segment_results[d1.seq ].seg_cd = sh.seg_cd
  WITH nocounter
 ;end select
 IF ((request->print_ind = 0 ) )
  FOR (segidx = 1 TO size (reply->segment_results ,5 ) )
   CALL echo ("" )
   CALL echo (build ("Form :" ,reply->segment_results[segidx ].input_form_cd ," has event_id :" ,
     reply->segment_results[segidx ].event_id ) )
   CALL echo ("" )
   SET cur_seg_cd = reply->segment_results[segidx ].seg_cd
   SET cur_seg_idx = segidx
   SET cur_segment_header_id = 0.0
   SET seg_meaning = fillstring (12 ," " )
   SET seg_meaning = uar_get_code_meaning (cur_seg_cd )
   IF ((((reply->segment_results[segidx ].event_id = 0 ) ) OR ((seg_meaning = "CASETIMES" ) )) )
    CALL echo (build ("Segment Meaning :" ,seg_meaning ) )
    CASE (seg_meaning )
     OF surgical_procedures :
     OF general_case_data :
     OF "CASETIMES" :
      SELECT INTO "nl:"
       FROM (perioperative_document pd ),
        (segment_header sh )
       PLAN (pd
        WHERE (pd.periop_doc_id = request->doc_id ) )
        JOIN (sh
        WHERE (sh.seg_cd = cur_seg_cd )
        AND (sh.periop_doc_id = pd.periop_doc_id ) )
       HEAD REPORT
        cur_surg_case_id = pd.surg_case_id
       DETAIL
        cur_segment_header_id = sh.segment_header_id
       WITH nocounter
      ;end select
    ENDCASE
    CASE (seg_meaning )
     OF surgical_procedures :
      EXECUTE sn_init_doc_proc
      IF ((reply->status_data.status = "F" ) )
       SET failure = "T"
       GO TO exit_script
      ENDIF
     OF general_case_data :
      EXECUTE sn_init_doc_gcd
      IF ((reply->status_data.status = "F" ) )
       SET failure = "T"
       GO TO exit_script
      ENDIF
    ENDCASE
    EXECUTE cv_get_doc_cf
    SET failure = "F"
   ENDIF
   IF (validate (reply->segment_results[segidx ].sup_cab_def_ind ) )
    IF ((reply->segment_results[segidx ].sup_cab_def_ind = 1 ) )
     EXECUTE sn_init_supply_cabinet
     IF ((reply->status_data.status = "F" ) )
      SET failure = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   SET values_found = "F"
   FOR (z = 1 TO size (reply->segment_results[segidx ].entries ,5 ) )
    FOR (i = 1 TO size (reply->segment_results[segidx ].entries[z ].groups ,5 ) )
     FOR (j = 1 TO size (reply->segment_results[segidx ].entries[z ].groups[i ].controls ,5 ) )
      IF ((size (reply->segment_results[segidx ].entries[z ].groups[i ].controls[j ].values ,5 ) > 0
      ) )
       SET values_found = "T"
      ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
   IF ((values_found = "F" ) )
    SET stat = alterlist (reply->segment_results[segidx ].entries ,0 )
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 call echorecord(reply)
 IF ((failure = "T" ) )
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
 

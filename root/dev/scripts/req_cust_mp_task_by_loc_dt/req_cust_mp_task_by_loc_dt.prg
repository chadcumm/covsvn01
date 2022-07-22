DROP PROGRAM req_cust_mp_task_by_loc_dt GO
CREATE PROGRAM req_cust_mp_task_by_loc_dt
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "User ID:" = 0.0 ,
  "Position Cd:" = 0.0 ,
  "Start Date:" = "" ,
  "End Date:" = "" ,
  "Ignore Limit:" = "" ,
  "Encounter Only:" = "" ,
  "Location:" = 0.0
  WITH outdev ,user_id ,position_cd ,start_dt ,end_dt ,loc_prompt
 FREE RECORD record_data
 RECORD record_data (
   1 date_used = i2
   1 start_check = vc
   1 end_check = vc
   1 task_info_text = vc
   1 allow_req_print = i2
   1 labreq_prg = vc
   1 autolog_spec_ind = i2
   1 lock_chart_access = i2
   1 label_print_type = vc
   1 label_print_auto_off = vc
   1 allow_depart = i2
   1 depart_label = vc
   1 adv_print_ind = i2
   1 adv_print_codeset = f8
   1 form_ind = i2
   1 formslist [* ]
     2 form_id = f8
     2 form_name = vc
   1 tlist [* ]
     2 person_id = f8
     2 encounter_id = f8
     2 person_name = vc
     2 gender = vc
     2 gender_char = vc
     2 dob = vc
     2 age = vc
     2 task_type = vc
     2 task_id = f8
     2 task_type_ind = i2
     2 task_describ = vc
     2 task_display = vc
     2 task_prn_ind = i2
     2 task_date = vc
     2 task_overdue = i2
     2 task_time = vc
     2 task_dt_tm_num = dq8
     2 task_dt_tm_utc = vc
     2 task_form_id = f8
     2 charge_ind = i2
     2 task_status = vc
     2 display_status = vc
     2 inprocess_ind = i2
     2 order_id = vc
     2 order_id_real = f8
     2 ordered_as_name = vc
     2 order_cdl = vc
     2 orig_order_dt = vc
     2 order_dt_tm_utc = vc
     2 ordering_provider = vc
     2 ord_comment = vc
     2 task_note = vc
     2 task_resched_time = i2
     2 can_chart_ind = i2
     2 visit_loc = vc
     2 visit_date = vc
     2 visit_date_display = vc
     2 visit_dt_tm_num = dq8
     2 visit_dt_utc = vc
     2 charted_by = vc
     2 charted_dt = vc
     2 charted_dt_utc = vc
     2 not_done = i2
     2 result_set_id = f8
     2 not_done_reason = vc
     2 not_done_reason_comm = vc
     2 status_reason_cd = f8
     2 powerplan_ind = i2
     2 powerplan_name = vc
     2 event_id = f8
     2 dfac_activity_id = f8
     2 olist [* ]
       3 order_name = vc
       3 ordering_prov = vc
       3 order_id = f8
       3 dlist [* ]
         4 rank_seq = vc
         4 diag = vc
         4 code = vc
     2 dlist [* ]
       3 rank_seq = vc
       3 diag = vc
       3 code = vc
     2 asc_num = vc
     2 contain_list [* ]
       3 contain_sent = vc
       3 task_id = f8
     2 order_cnt = i2
     2 abn_track_ids = vc
     2 abn_list [* ]
       3 order_disp = vc
       3 alert_date = vc
       3 alert_state = vc
   1 status_list [* ]
     2 status = vc
     2 selected = i2
   1 type_pref_found = i2
   1 type_list [* ]
     2 type = vc
     2 selected = i2
   1 abn_form_list [* ]
     2 program_name = vc
     2 program_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD lab_list
 RECORD lab_list (
   1 llist [* ]
     2 task_id = f8
 )
 FREE RECORD order_id_list
 RECORD order_id_list (
   1 olist [* ]
     2 order_id = f8
 )
 FREE RECORD task_stat
 RECORD task_stat (
   1 slist [* ]
     2 status_cd = f8
     2 status = vc
 )
 RECORD abn_request (
   1 call_echo_ind = i2
   1 report_type_cd = f8
   1 report_type_meaning = c12
 )
 RECORD abn_reply (
   1 qual_cnt = i4
   1 qual [* ]
     2 sch_report_id = f8
     2 mnem = vc
     2 desc = vc
     2 program_name = vc
     2 report_type_cd = f8
     2 report_type_meaning = c12
     2 updt_cnt = i4
     2 active_ind = i2
     2 candidate_id = f8
     2 postscript_ind = i2
     2 advanced_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE log_program_name = vc WITH protect ,noconstant ("" )
 DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
 SET log_program_name = curprog
 SET log_override_ind = 1
 DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
 DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
 DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
 DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
 DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
 DECLARE hsys = i4 WITH protect ,noconstant (0 )
 DECLARE sysstat = i4 WITH protect ,noconstant (0 )
 DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
 DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
 DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle ()
 SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
 DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
 DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
 DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
 DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
 DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
 DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
 DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
 DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
 IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name
   ) ) > " " ) )) )
  SET log_override_ind = 1
 ENDIF
 DECLARE log_message ((logmsg = vc ) ,(loglvl = i4 ) ) = null
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
 DECLARE getencntrreltn ((dencntr_id = f8 ) ,(dreltn_cd = f8 ) ,(dprov_id = f8 ) ) = null
 DECLARE validatefxreltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
 DECLARE validatefx2reltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
 DECLARE validatecustomsettings ((codeset = f8 ) ,(encntrid = f8 ) ,(cve_fieldparse = vc ) ) = vc
 DECLARE subroutine_status = f8 WITH noconstant (0 ) ,protect
 IF ((validate (89_powerchart ,- (99 ) ) = - (99 ) ) )
  DECLARE 89_powerchart = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,89 ,"POWERCHART" ) )
 ENDIF
 IF ((validate (48_inactive ,- (99 ) ) = - (99 ) ) )
  DECLARE 48_inactive = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"INACTIVE" ) )
 ENDIF
 IF ((validate (48_active ,- (99 ) ) = - (99 ) ) )
  DECLARE 48_active = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
 ENDIF
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
 SET log_program_name = "REQ_CUST_MP_TASK_BY_LOC_DT"
 DECLARE gathercomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
 DECLARE gatherpagecomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
 DECLARE gathertasksbylocdt (dummy ) = null WITH protect ,copy
 DECLARE gatherlabsbylocdt (dummy ) = null WITH protect ,copy
 DECLARE gatherorderdiags (dummy ) = null WITH protect ,copy
 DECLARE gatherenctrorgsecurity ((persid = f8 ) ,(userid = f8 ) ) = null WITH protect ,copy
 DECLARE gathertasktypes (dummy ) = null WITH protect ,copy
 DECLARE gatheruserprefs ((prsnl_id = f8 ) ,(pref_id = vc ) ) = null WITH protect ,copy
 DECLARE gatherpowerformname (dummy ) = null WITH protect ,copy
 DECLARE gatheruserlockedchartsaccess ((userid = f8 ) ) = null WITH protect ,copy
 DECLARE gatherabnprogramnames (dummy ) = null WITH protect ,copy
 DECLARE gathernotdonereason ((resultid = f8 ) ) = null WITH protect ,copy
 DECLARE gatherchartedforms ((eventid = f8 ) ) = null WITH protect ,copy
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
 DECLARE 6025_cont = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3243" ) )
 DECLARE 6000_meds = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3079" ) )
 DECLARE 6000_eandm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!10700" ) )
 DECLARE 6000_charge = f8 WITH public ,constant (uar_get_code_by ("DISPLAYKEY" ,6000 ,"CHARGES" ) )
 DECLARE deleted = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17013" ) )
 DECLARE completed = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2791" ) )
 DECLARE inprocess = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2792" ) )
 DECLARE 222_fac = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
 DECLARE order_comment = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3944" ) )
 DECLARE task_note = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2936879" ) )
 DECLARE not_done = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17619" ) )
 DECLARE ocfcomp_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,120 ,"OCFCOMP" ) )
 DECLARE rtf_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"RTF" ) )
 DECLARE inerror = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) )
 DECLARE 27113_mednec = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27113 ,"MEDNEC" ) )
 DECLARE 27112_required = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27112 ,"REQUIRED" )
  )
 DECLARE abn_status_meaning = vc WITH constant ("ABNSTATUS" )
 DECLARE start_parser = vc WITH public ,noconstant ("0" )
 DECLARE end_parser = vc WITH public ,noconstant ("0" )
 DECLARE dtformat = vc WITH public ,constant ("MM/DD/YYYY" )
 DECLARE location_parser = vc WITH public ,noconstant ("" )
 DECLARE encntr_location_parser = vc WITH public ,noconstant ("1=1" )
 DECLARE task_type_parser = vc WITH public ,noconstant ("1=1" )
 DECLARE task_type_cv_parser = vc WITH public ,noconstant ("1=1" )
 DECLARE encntr_type_parser = vc WITH public ,noconstant ("1=1" )
 DECLARE not_done_reason = vc WITH public ,noconstant ("" )
 DECLARE not_done_reason_comm = vc WITH public ,noconstant ("" )
 DECLARE charted_form_id = f8 WITH public ,noconstant (0.0 )
 DECLARE position_bedrock_settings = i2
 DECLARE user_pref_string = vc
 DECLARE user_pref_found = i2
 DECLARE tasks_back = i4
 DECLARE task_max = i4
 DECLARE tcnt = i2
 DECLARE lcnt = i2
 DECLARE ignore_data = i2
 SET tasks_back = 200
 DECLARE confid_ind = i2
 DECLARE confid_level = i2
 DECLARE confid_security_parser = vc WITH public ,noconstant ("1=1" )
 DECLARE indx_type = i4 WITH protect ,noconstant (0 )
 DECLARE logging = i4 WITH protect ,noconstant (0 )
 CALL log_message (concat ("Begin script: " ,log_program_name ) ,log_level_debug )
 SET record_data->status_data.status = "F"
 CALL gathercomponentsettings ( $POSITION_CD )
 IF ((position_bedrock_settings = 0 ) )
  CALL gathercomponentsettings (0.00 )
 ENDIF
 CALL gatherpagecomponentsettings ( $POSITION_CD )
 IF ((position_bedrock_settings = 0 ) )
  CALL gatherpagecomponentsettings (0.00 )
 ENDIF
 IF ((record_data->labreq_prg = "" ) )
  SET record_data->allow_req_print = 0
 ENDIF
 SET record_data->end_check =  $END_DT
 SET record_data->start_check =  $START_DT
 SET stat = alterlist (record_data->status_list ,3 )
 SET record_data->status_list[1 ].status = "Active"
 SET record_data->status_list[1 ].selected = 1
 SET record_data->status_list[2 ].status = "Complete"
 SET record_data->status_list[2 ].selected = 1
 SET record_data->status_list[3 ].status = "Discontinued"
 SET record_data->status_list[3 ].selected = 0
 IF ((encntr_type_parser != "1=1" ) )
  SET encntr_type_parser = concat ("e.encntr_type_cd IN (" ,encntr_type_parser ,")" )
 ENDIF
 IF ((task_type_parser != "1=1" ) )
  SET task_type_cv_parser = concat ("cv.code_value IN (" ,task_type_parser ,")" )
  SET task_type_parser = concat ("ta.task_type_cd IN (" ,task_type_parser ,")" )
 ELSE
  SET task_type_cv_parser = "1=1"
 ENDIF
 SELECT INTO "nl:"
  FROM (dm_info di )
  PLAN (di
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name IN ("SEC_CONFID" ) ) )
  DETAIL
   IF ((di.info_name = "SEC_CONFID" )
   AND (di.info_number = 1 ) ) confid_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF ((confid_ind = 1 ) )
  ;CALL gatheruserlockedchartsaccess ( $USER_ID )
  IF ((confid_level = - (1 ) ) )
   SET confid_security_parser = "cv.collation_seq <= 0"
  ELSE
   SET confid_security_parser = concat ("cv.collation_seq <= " ,cnvtstring (confid_level ) )
  ENDIF
 ENDIF
 CALL gathertasktypes (0 )
 CALL gatheruserprefs ( $USER_ID ,"PWX_MPAGE_ORG_TASK_LIST_TYPES" )
 IF ((user_pref_found = 1 ) )
  SET record_data->type_pref_found = 1
  FOR (tseq = 1 TO size (record_data->type_list ,5 ) )
   SET record_data->type_list[tseq ].selected = 0
  ENDFOR
  DECLARE start_comma = i4 WITH protect ,noconstant (1 )
  DECLARE end_comma = i4 WITH protect ,noconstant (findstring ("|" ,user_pref_string ,start_comma )
   )
  DECLARE task_type_pref = vc
  WHILE ((start_comma > 0 ) )
   IF (NOT (end_comma ) )
    SET task_type_pref = substring ((start_comma + 1 ) ,(textlen (user_pref_string ) - start_comma )
     ,user_pref_string )
   ELSE
    SET task_type_pref = substring ((start_comma + 1 ) ,((end_comma - start_comma ) - 1 ) ,
     user_pref_string )
   ENDIF
   CALL log_message (task_type_pref ,log_level_debug )
   FOR (tseq = 1 TO size (record_data->type_list ,5 ) )
    IF ((record_data->type_list[tseq ].type = task_type_pref ) )
     SET record_data->type_list[tseq ].selected = 1
    ENDIF
   ENDFOR
   SET start_comma = end_comma
   IF (start_comma )
    SET end_comma = findstring ("|" ,user_pref_string ,(start_comma + 1 ) )
   ENDIF
  ENDWHILE
 ENDIF
 IF (( $LOC_PROMPT > 0 ) )
  IF ((checkdic ("AMB_CUST_LOCATION_ENCNTR_INDEX" ,"P" ,0 ) = 0 ) )
   CALL echo ("*** FAILURE ***" )
   CALL echo ("*** AMB_CUST_LOCATION_ENCNTR_INDEX program not in object library, exiting script.***"
    )
   CALL echo (
    "*** Validate AMB_CUST_LOCATION_ENCNTR_INDEX program is in the correct directory and included. ***"
    )
   GO TO exit_program
  ENDIF
  DECLARE location = f8 WITH constant ( $LOC_PROMPT )
  DECLARE location_name = vc WITH constant (uar_get_code_description (cnvtreal ( $LOC_PROMPT ) ) )
  DECLARE indx_type_name = vc WITH protect ,noconstant ("" )
  DECLARE num_seq = i4 WITH protect ,noconstant (0 )
  DECLARE loc_seq = i4 WITH protect ,noconstant (0 )
  FREE RECORD indx_reply
  RECORD indx_reply (
    1 indx_cnt = i4
    1 indx [* ]
      2 person_id = f8
      2 encntr_id = f8
    1 status_flag = c1
    1 indx_loc_cnt = i4
    1 indx_loc [* ]
      2 location_tier = i2
      2 location_cd = f8
    1 loc_status_flag = c1
  )
  EXECUTE amb_cust_location_encntr_index location ,
  indx_type ,
  logging WITH replace ("INDX_REC" ,"INDX_REPLY" )
  FREE RECORD indx_rec
  IF ((logging = 1 ) )
   IF ((indx_type = 0 ) )
    SET indx_type_name = "Location CD Only"
   ELSEIF ((indx_type = 1 ) )
    SET indx_type_name = "Person_id Only"
   ELSEIF ((indx_type = 2 ) )
    SET indx_type_name = "Encntr_id Only"
   ELSEIF ((indx_type = 3 ) )
    SET indx_type_name = "Person_id and Encntr_id"
   ENDIF
  ENDIF
  IF ((((indx_reply->status_flag = "F" )
  AND (indx_type != 0 ) ) OR ((indx_reply->loc_status_flag = "F" ) )) )
   GO TO exit_program
  ENDIF
  IF ((logging = 1 )
  AND (indx_type != 0 ) )
   CALL echo (build ("***Entering Expand indx_reply***" ) )
  ENDIF
  IF ((indx_type != 0 ) )
   SET actual_size = size (indx_reply->indx ,5 )
   SET expand_size = 200
   SET expand_stop = 200
   SET expand_start = 1
   SET expand_total = (actual_size + (expand_size - mod (actual_size ,expand_size ) ) )
   SET num = 0
   SET stat = alterlist (indx_reply->indx ,expand_total )
   FOR (idx = (actual_size + 1 ) TO expand_total )
    IF ((indx_type = 1 ) )
     SET indx_reply->indx[idx ].person_id = indx_reply->indx[actual_size ].person_id
    ELSEIF ((indx_type = 2 ) )
     SET indx_reply->indx[idx ].encntr_id = indx_reply->indx[actual_size ].encntr_id
    ELSEIF ((indx_type = 3 ) )
     SET indx_reply->indx[idx ].person_id = indx_reply->indx[actual_size ].person_id
     SET indx_reply->indx[idx ].encntr_id = indx_reply->indx[actual_size ].encntr_id
    ENDIF
   ENDFOR
  ENDIF
  IF ((logging = 1 ) )
   IF ((indx_type != 0 ) )
    CALL echo (build ("Actual Size: " ,actual_size ) )
    CALL echo (build ("Expand Total: " ,expand_total ) )
    CALL echo (build ("***Exiting Expand indx_reply***" ) )
   ENDIF
   CALL echo ("***VERIFIYING INDEX CREATED AS INDICATED***" )
   IF ((indx_type != 0 ) )
    CALL echo (build ("Index Type: " ,indx_type_name ,"--Count: " ,indx_reply->indx_cnt ) )
    CALL echo (build ("PERSON at POS 1: " ,indx_reply->indx[1 ].person_id ) )
    CALL echo (build ("ENCNTR at POS 1: " ,indx_reply->indx[1 ].encntr_id ) )
   ENDIF
   CALL echo (build ("LOCATION at POS 1: " ,indx_reply->indx_loc[1 ].location_cd ) )
   CALL echo ("***VERIFICATION COMPLETE***" )
  ENDIF
  IF ((indx_reply->loc_status_flag = "S" )
  AND (indx_reply->indx_loc_cnt > 0 ) )
   SET encntr_location_parser = ""
   FOR (loc_cnt = 0 TO indx_reply->indx_loc_cnt )
    IF ((indx_reply->indx_loc[loc_cnt ].location_tier <= 3 ) )
     IF ((location_parser = "" ) )
      SET location_parser = concat (trim (cnvtstring (indx_reply->indx_loc[loc_cnt ].location_cd ) ,
        3 ) ,".00" )
     ELSE
      SET location_parser = concat (location_parser ,"," ,trim (cnvtstring (indx_reply->indx_loc[
         loc_cnt ].location_cd ) ,3 ) ,".00" )
     ENDIF
    ENDIF
   ENDFOR
   SET location_parser = concat ("ta.location_cd IN (" ,location_parser ,")" )
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 CALL gathertasksbylocdt (0 )
 IF ((size (lab_list->llist ,5 ) > 0 ) )
  CALL gatherlabsbylocdt (0 )
 ENDIF
 SET stat = alterlist (record_data->tlist ,tcnt )
 IF ((size (record_data->tlist ,5 ) > 0 ) )
  IF ((record_data->adv_print_ind = 1 )
  AND (record_data->adv_print_codeset > 0 ) )
   SET record_data->label_print_type = validatecustomsettings (record_data->adv_print_codeset ,
    record_data->tlist[1 ].encounter_id ,"reflab_label_method" )
   SET record_data->label_print_auto_off = validatecustomsettings (record_data->adv_print_codeset ,
    record_data->tlist[1 ].encounter_id ,"reflab_label_auto_off" )
  ENDIF
  CALL gatherorderdiags (0 )
  FOR (eseq = 1 TO size (record_data->tlist ,5 ) )
   IF ((record_data->tlist[eseq ].result_set_id > 0 ) )
    CALL gathernotdonereason (record_data->tlist[eseq ].result_set_id )
    SET record_data->tlist[eseq ].not_done_reason = not_done_reason
    SET record_data->tlist[eseq ].not_done_reason_comm = not_done_reason_comm
   ENDIF
   IF ((record_data->tlist[eseq ].event_id > 0 )
   AND (record_data->tlist[eseq ].task_type_ind = 2 ) )
    CALL gatherchartedforms (record_data->tlist[eseq ].event_id )
    SET record_data->tlist[eseq ].dfac_activity_id = charted_form_id
   ENDIF
  ENDFOR
 ENDIF
 IF ((size (record_data->formslist ,5 ) > 0 ) )
  CALL gatherpowerformname (0 )
 ENDIF
 CALL gatherabnprogramnames (0 )
 SET record_data->status_data.status = "S"
 SET modify maxvarlen 20000000
 SET _memory_reply_string = cnvtrectojson (record_data )
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
 SUBROUTINE  gathertasksbylocdt (dummy )
  CALL log_message ("In GatherTasksByLocDt()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET start_parser = concat ("ta.task_dt_tm >= " ," cnvtdatetime(cnvtdate2('" , $START_DT ,"','" ,
   dtformat ,"'),0)" )
  SET end_parser = concat ("ta.task_dt_tm <= " ," cnvtdatetime(cnvtdate2('" , $END_DT ,"','" ,
   dtformat ,"'),2359)" )
  SET record_data->date_used = 1
  SELECT INTO "nl:"
   task_date = datetimezoneformat (ta.task_dt_tm ,ta.task_tz ,"MM/DD/YY" ) ,
   task_time = datetimezoneformat (ta.task_dt_tm ,ta.task_tz ,"hh:mm tt" ) ,
   order_date = datetimezoneformat (o.orig_order_dt_tm ,o.orig_order_tz ,"MM/DD/YY" ) ,
   order_time = datetimezoneformat (o.orig_order_dt_tm ,o.orig_order_tz ,"hh:mm tt" ) ,
   task_type = trim (uar_get_code_display (ta.task_type_cd ) )
   FROM (task_activity ta ),
    (person p ),
    (orders o ),
    (order_comment oc ),
    (order_detail od3 ),
    (long_text lt ),
    (eem_abn_check eem ),
    (order_task ot ),
    (prsnl pr ),
    (prsnl pr2 ),
    (encounter e ),
    (code_value cv ),
    (pathway_catalog pc ),
    (order_task_position_xref otpx )
   PLAN (ta
    WHERE parser (location_parser )
    AND parser (start_parser )
    AND parser (end_parser )
    AND parser (task_type_parser )
    AND (ta.task_class_cd != 6025_cont )
    AND (ta.task_status_cd != deleted )
    AND (ta.active_ind = 1 ) )
    JOIN (e
    WHERE (e.encntr_id = ta.encntr_id )
    AND parser (encntr_type_parser ) )
    JOIN (cv
    WHERE (cv.code_value = e.confid_level_cd )
    AND parser (confid_security_parser ) )
    JOIN (p
    WHERE (p.person_id = ta.person_id ) )
    JOIN (o
    WHERE (o.order_id = outerjoin (ta.order_id ) )
    AND (o.order_id > outerjoin (0 ) ) )
    JOIN (od3
    WHERE (od3.order_id = outerjoin (o.order_id ) )
    AND (od3.oe_field_meaning = outerjoin (abn_status_meaning ) ) )
    JOIN (pc
    WHERE (pc.pathway_catalog_id = outerjoin (o.pathway_catalog_id ) ) )
    JOIN (oc
    WHERE (oc.order_id = outerjoin (o.order_id ) ) )
    JOIN (lt
    WHERE (lt.long_text_id = outerjoin (oc.long_text_id ) ) )
    JOIN (eem
    WHERE (eem.parent1_id = outerjoin (o.order_id ) )
    AND (eem.parent1_id != outerjoin (0 ) )
    AND (eem.parent1_table = outerjoin ("ORDERS" ) )
    AND (eem.med_status_cd != outerjoin (27113_mednec ) )
    AND (eem.high_status_cd = outerjoin (27112_required ) ) )
    JOIN (ot
    WHERE (ot.reference_task_id = ta.reference_task_id ) )
    JOIN (otpx
    WHERE (otpx.reference_task_id = outerjoin (ot.reference_task_id ) )
    AND (otpx.position_cd = outerjoin ( $POSITION_CD ) ) )
    JOIN (pr
    WHERE (pr.person_id = outerjoin (o.last_update_provider_id ) ) )
    JOIN (pr2
    WHERE (pr2.person_id = outerjoin (ta.updt_id ) ) )
   ORDER BY ta.task_dt_tm ,
    ta.task_id ,
    lt.updt_dt_tm ,
    eem.updt_dt_tm DESC
   HEAD REPORT
    lcnt = 0 ,
    ignore_data = 0
   HEAD ta.task_id
    abncnt = 0 ,
    IF ((ta.container_id > 0 ) ) lcnt = (lcnt + 1 ) ,
     IF ((mod (lcnt ,100 ) = 1 ) ) stat = alterlist (lab_list->llist ,(lcnt + 99 ) )
     ENDIF
     ,lab_list->llist[lcnt ].task_id = ta.task_id ,ignore_data = 1
    ELSE ignore_data = 0 ,tcnt = (tcnt + 1 ) ,
     IF ((mod (tcnt ,100 ) = 1 ) ) stat = alterlist (record_data->tlist ,(tcnt + 99 ) )
     ENDIF
     ,record_data->tlist[tcnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/dd/yyyy" ) ,
     record_data->tlist[tcnt ].encounter_id = ta.encntr_id ,record_data->tlist[tcnt ].gender =
     uar_get_code_display (p.sex_cd ) ,record_data->tlist[tcnt ].gender_char = cnvtupper (substring (
       1 ,1 ,record_data->tlist[tcnt ].gender ) ) ,age_str = cnvtlower (trim (substring (1 ,12 ,
        cnvtage (p.birth_dt_tm ) ) ,4 ) ) ,
     IF ((findstring ("days" ,age_str ,0 ) > 0 ) ) days = findstring ("days" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,days ,age_str )
     ELSEIF ((findstring ("weeks" ,age_str ,0 ) > 0 ) ) weeks = findstring ("weeks" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,weeks ,age_str )
     ELSEIF ((findstring ("months" ,age_str ,0 ) > 0 ) ) months = findstring ("months" ,age_str ,0 )
     ,record_data->tlist[tcnt ].age = substring (1 ,months ,age_str )
     ELSEIF ((findstring ("years" ,age_str ,0 ) > 0 ) ) years = findstring ("years" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,years ,age_str )
     ENDIF
     ,record_data->tlist[tcnt ].person_id = p.person_id ,record_data->tlist[tcnt ].person_name =
     trim (p.name_full_formatted ) ,record_data->tlist[tcnt ].task_id = ta.task_id ,record_data->
     tlist[tcnt ].task_describ = trim (ot.task_description ) ,record_data->tlist[tcnt ].task_display
     = record_data->tlist[tcnt ].task_describ ,record_data->tlist[tcnt ].visit_loc = trim (
      uar_get_code_description (e.location_cd ) ) ,record_data->tlist[tcnt ].visit_date = format (
      cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YYYY;;d" ) ,record_data->tlist[tcnt ].visit_date_display =
     format (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YY;;d" ) ,record_data->tlist[tcnt ].visit_dt_tm_num
     = e.reg_dt_tm ,record_data->tlist[tcnt ].visit_dt_utc = build (replace (datetimezoneformat (
        cnvtdatetime (e.reg_dt_tm ) ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,
        curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].charted_by = trim (pr2
      .name_full_formatted ) ,record_data->tlist[tcnt ].charted_dt = format (ta.updt_dt_tm ,
      "MM/DD/YYYY;4;D" ) ,record_data->tlist[tcnt ].charted_dt_utc = build (replace (
       datetimezoneformat (cnvtdatetime (ta.updt_dt_tm ) ,datetimezonebyname ("UTC" ) ,
        "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].
     display_status = trim (uar_get_code_display (ta.task_status_cd ) ) ,
     IF ((ta.task_status_cd = inprocess ) ) record_data->tlist[tcnt ].inprocess_ind = 1
     ENDIF
     ,
     FOR (tseq = 1 TO size (task_stat->slist ,5 ) )
      IF ((ta.task_status_cd = task_stat->slist[tseq ].status_cd ) ) record_data->tlist[tcnt ].
       task_status = task_stat->slist[tseq ].status
      ENDIF
     ENDFOR
     ,
     IF ((ta.task_status_reason_cd = not_done ) ) record_data->tlist[tcnt ].not_done = 1 ,record_data
      ->tlist[tcnt ].result_set_id = ta.result_set_id
     ENDIF
     ,record_data->tlist[tcnt ].task_type = trim (replace (task_type ,"* " ,"" ,0 ) ) ,record_data->
     tlist[tcnt ].task_date = task_date ,record_data->tlist[tcnt ].task_dt_tm_num = datetimezone (ta
      .task_dt_tm ,ta.task_tz ) ,record_data->tlist[tcnt ].task_dt_tm_utc = build (replace (
       datetimezoneformat (cnvtdatetime (ta.task_dt_tm ) ,datetimezonebyname ("UTC" ) ,
        "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,
     IF ((ta.task_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) record_data->tlist[tcnt ].
      task_overdue = 1
     ENDIF
     ,
     IF ((o.prn_ind = 1 ) ) record_data->tlist[tcnt ].task_prn_ind = 1
     ENDIF
     ,record_data->tlist[tcnt ].task_time = task_time ,record_data->tlist[tcnt ].order_id = trim (
      cnvtstring (ta.order_id ) ) ,record_data->tlist[tcnt ].order_id_real = ta.order_id ,record_data
     ->tlist[tcnt ].ordered_as_name = trim (o.ordered_as_mnemonic ) ,record_data->tlist[tcnt ].
     orig_order_dt = concat (order_date ," " ,order_time ) ,record_data->tlist[tcnt ].order_dt_tm_utc
      = build (replace (datetimezoneformat (cnvtdatetime (o.orig_order_dt_tm ) ,datetimezonebyname (
         "UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[
     tcnt ].order_cdl = trim (o.order_detail_display_line ) ,
     IF ((ot.allpositionchart_ind = 1 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
     ELSEIF ((otpx.reference_task_id > 0 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
     ENDIF
     ,record_data->tlist[tcnt ].task_resched_time = ot.reschedule_time ,
     IF ((record_data->tlist[tcnt ].order_cdl = "" ) ) record_data->tlist[tcnt ].order_cdl = "--"
     ENDIF
     ,
     IF ((pr.person_id > 0 ) ) record_data->tlist[tcnt ].ordering_provider = trim (pr
       .name_full_formatted )
     ELSE record_data->tlist[tcnt ].ordering_provider = "--"
     ENDIF
     ,
     IF ((((o.catalog_type_cd = 6000_eandm ) ) OR ((o.catalog_type_cd = 6000_charge ) )) )
      record_data->tlist[tcnt ].charge_ind = 1
     ENDIF
     ,
     IF ((o.catalog_type_cd = 6000_meds ) ) record_data->tlist[tcnt ].task_type_ind = 1 ,record_data
      ->tlist[tcnt ].task_display = record_data->tlist[tcnt ].ordered_as_name ,record_data->tlist[
      tcnt ].order_cdl = trim (o.clinical_display_line )
     ENDIF
     ,
     IF ((ot.dcp_forms_ref_id > 0 ) ) record_data->tlist[tcnt ].task_form_id = ot.dcp_forms_ref_id ,
      record_data->tlist[tcnt ].task_type_ind = 2 ,
      IF ((ta.event_id > 0 ) ) record_data->tlist[tcnt ].event_id = ta.event_id
      ENDIF
     ENDIF
     ,
     IF ((o.pathway_catalog_id > 0 ) ) record_data->tlist[tcnt ].powerplan_ind = 1 ,record_data->
      tlist[tcnt ].powerplan_name = trim (pc.description )
     ENDIF
     ,
     IF ((eem.abn_tracking_id > 0 )
     AND (cnvtupper (od3.oe_field_display_value ) != "NOT REQUIRED" ) ) abncnt = (abncnt + 1 ) ,stat
      = alterlist (record_data->tlist[tcnt ].abn_list ,abncnt ) ,record_data->tlist[tcnt ].abn_list[
      abncnt ].alert_state = uar_get_code_display (eem.abn_state_cd ) ,record_data->tlist[tcnt ].
      abn_list[abncnt ].alert_date = format (eem.active_status_dt_tm ,"MM/DD/YYYY HH:MM:SS;;d" ) ,
      record_data->tlist[tcnt ].abn_list[abncnt ].order_disp = trim (o.ordered_as_mnemonic ) ,
      IF ((record_data->tlist[tcnt ].abn_track_ids = "" ) ) record_data->tlist[tcnt ].abn_track_ids
       = cnvtstring (eem.abn_tracking_id )
      ELSE record_data->tlist[tcnt ].abn_track_ids = concat (record_data->tlist[tcnt ].abn_track_ids
        ,"," ,cnvtstring (eem.abn_tracking_id ) )
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    IF ((ignore_data = 0 ) )
     IF ((oc.comment_type_cd = task_note ) ) record_data->tlist[tcnt ].task_note = trim (lt
       .long_text )
     ELSEIF ((oc.comment_type_cd = order_comment ) ) record_data->tlist[tcnt ].ord_comment = trim (lt
       .long_text )
     ENDIF
    ENDIF
   FOOT  ta.task_id
    IF ((ignore_data = 0 ) )
     IF ((record_data->tlist[tcnt ].ord_comment = "" ) ) record_data->tlist[tcnt ].ord_comment =
      "--"
     ENDIF
     ,
     IF ((record_data->tlist[tcnt ].task_note = "" ) ) record_data->tlist[tcnt ].task_note = "--"
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lab_list->llist ,lcnt )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherTasksByLocDt" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit GatherTasksByLocDt(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  gatherlabsbylocdt (dummy )
  CALL log_message ("In GatherLabsByLocDt()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SELECT INTO "nl:"
   task_date = datetimezoneformat (ta.task_dt_tm ,ta.task_tz ,"MM/DD/YY" ) ,
   task_time = datetimezoneformat (ta.task_dt_tm ,ta.task_tz ,"hh:mm tt" ) ,
   order_date = datetimezoneformat (o.orig_order_dt_tm ,o.orig_order_tz ,"MM/DD/YY" ) ,
   order_time = datetimezoneformat (o.orig_order_dt_tm ,o.orig_order_tz ,"hh:mm tt" ) ,
   specimen_container = trim (uar_get_code_display (c.spec_cntnr_cd ) ) ,
   specimen_type = trim (uar_get_code_display (c.specimen_type_cd ) ) ,
   collection_volume = trim (concat (trim (cnvtstring (c.volume ,11 ,1 ) ) ," " ,
     uar_get_code_display (sc.volume_units_cd ) ) ) ,
   storage_temp = trim (uar_get_code_display (c.coll_class_cd ) ) ,
   special_handling = trim (uar_get_code_display (c.spec_hndl_cd ) ) ,
   task_type = trim (uar_get_code_display (ta.task_type_cd ) ) ,
   task_status = trim (uar_get_code_display (ta.task_status_cd ) )
   FROM (dummyt d WITH seq = size (lab_list->llist ,5 ) ),
    (task_activity ta ),
    (person p ),
    (container c ),
    (container_accession ca ),
    (specimen_container sc ),
    (order_serv_res_container osrc ),
    (container_event ce ),
    (orders o ),
    (order_detail od3 ),
    (order_action oa ),
    (eem_abn_check eem ),
    (order_task ot ),
    (prsnl pr ),
    (prsnl pr2 ),
    (encounter e ),
    (pathway_catalog pc ),
    (order_task_position_xref otpx )
   PLAN (d )
    JOIN (ta
    WHERE (ta.task_id = lab_list->llist[d.seq ].task_id ) )
    JOIN (c
    WHERE (c.container_id = ta.container_id ) )
    JOIN (p
    WHERE (p.person_id = ta.person_id ) )
    JOIN (e
    WHERE (e.encntr_id = ta.encntr_id ) )
    JOIN (sc
    WHERE (sc.spec_cntnr_cd = c.spec_cntnr_cd ) )
    JOIN (ca
    WHERE (ca.container_id = c.container_id ) )
    JOIN (osrc
    WHERE (osrc.container_id = ca.container_id ) )
    JOIN (ce
    WHERE (ce.container_id = osrc.container_id )
    AND (ce.event_sequence =
    (SELECT
     max (ce1.event_sequence )
     FROM (container_event ce1 )
     WHERE (ce1.container_id = ce.container_id ) ) ) )
    JOIN (o
    WHERE (o.order_id = osrc.order_id ) )
    JOIN (od3
    WHERE (od3.order_id = outerjoin (o.order_id ) )
    AND (od3.oe_field_meaning = outerjoin (abn_status_meaning ) ) )
    JOIN (pc
    WHERE (pc.pathway_catalog_id = outerjoin (o.pathway_catalog_id ) ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence = 1 ) )
    JOIN (eem
    WHERE (eem.parent1_id = outerjoin (o.order_id ) )
    AND (eem.parent1_id != outerjoin (0 ) )
    AND (eem.parent1_table = outerjoin ("ORDERS" ) )
    AND (eem.med_status_cd != outerjoin (27113_mednec ) )
    AND (eem.high_status_cd = outerjoin (27112_required ) ) )
    JOIN (ot
    WHERE (ot.reference_task_id = ta.reference_task_id ) )
    JOIN (otpx
    WHERE (otpx.reference_task_id = outerjoin (ot.reference_task_id ) )
    AND (otpx.position_cd = outerjoin ( $POSITION_CD ) ) )
    JOIN (pr
    WHERE (pr.person_id = oa.order_provider_id ) )
    JOIN (pr2
    WHERE (pr2.person_id = ta.updt_id ) )
   ORDER BY ta.person_id ,
    ta.task_dt_tm DESC ,
    ca.accession DESC ,
    c.specimen_id ,
    task_status ,
    ta.container_id ,
    o.ordered_as_mnemonic ,
    o.order_id ,
    eem.updt_dt_tm DESC
   HEAD c.specimen_id
    ccnt = 0 ,ocnt = 0 ,abncnt = 0 ,stat = initrec (order_id_list ) ,tcnt = (tcnt + 1 ) ,
    IF ((mod (tcnt ,100 ) = 1 ) ) stat = alterlist (record_data->tlist ,(tcnt + 99 ) )
    ENDIF
    ,record_data->tlist[tcnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/dd/yyyy" ) ,
    record_data->tlist[tcnt ].encounter_id = ta.encntr_id ,record_data->tlist[tcnt ].gender =
    uar_get_code_display (p.sex_cd ) ,record_data->tlist[tcnt ].gender_char = cnvtupper (substring (
      1 ,1 ,record_data->tlist[tcnt ].gender ) ) ,age_str = cnvtlower (trim (substring (1 ,12 ,
       cnvtage (p.birth_dt_tm ) ) ,4 ) ) ,
    IF ((findstring ("days" ,age_str ,0 ) > 0 ) ) days = findstring ("days" ,age_str ,0 ) ,
     record_data->tlist[tcnt ].age = substring (1 ,days ,age_str )
    ELSEIF ((findstring ("weeks" ,age_str ,0 ) > 0 ) ) weeks = findstring ("weeks" ,age_str ,0 ) ,
     record_data->tlist[tcnt ].age = substring (1 ,weeks ,age_str )
    ELSEIF ((findstring ("months" ,age_str ,0 ) > 0 ) ) months = findstring ("months" ,age_str ,0 ) ,
     record_data->tlist[tcnt ].age = substring (1 ,months ,age_str )
    ELSEIF ((findstring ("years" ,age_str ,0 ) > 0 ) ) years = findstring ("years" ,age_str ,0 ) ,
     record_data->tlist[tcnt ].age = substring (1 ,years ,age_str )
    ENDIF
    ,record_data->tlist[tcnt ].person_id = p.person_id ,record_data->tlist[tcnt ].person_name = trim
    (p.name_full_formatted ) ,record_data->tlist[tcnt ].task_type_ind = 3 ,record_data->tlist[tcnt ].
    task_type = trim (replace (task_type ,"* " ,"" ,0 ) ) ,record_data->tlist[tcnt ].visit_loc =
    trim (uar_get_code_description (e.location_cd ) ) ,record_data->tlist[tcnt ].visit_date = format
    (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YYYY;;d" ) ,record_data->tlist[tcnt ].visit_date_display =
    format (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YY;;d" ) ,record_data->tlist[tcnt ].visit_dt_tm_num
    = e.reg_dt_tm ,record_data->tlist[tcnt ].visit_dt_utc = build (replace (datetimezoneformat (
       cnvtdatetime (e.reg_dt_tm ) ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,
       curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].task_date = task_date ,
    record_data->tlist[tcnt ].task_dt_tm_num = datetimezone (ta.task_dt_tm ,ta.task_tz ) ,record_data
    ->tlist[tcnt ].task_dt_tm_utc = build (replace (datetimezoneformat (cnvtdatetime (ta.task_dt_tm
        ) ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z"
     ) ,record_data->tlist[tcnt ].charted_by = trim (pr2.name_full_formatted ) ,record_data->tlist[
    tcnt ].charted_dt = format (ta.updt_dt_tm ,"MM/DD/YYYY;4;D" ) ,record_data->tlist[tcnt ].
    charted_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (ta.updt_dt_tm ) ,
       datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,
    IF ((ta.task_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) record_data->tlist[tcnt ].task_overdue
      = 1
    ENDIF
    ,
    IF ((o.prn_ind = 1 ) ) record_data->tlist[tcnt ].task_prn_ind = 1
    ENDIF
    ,record_data->tlist[tcnt ].task_time = task_time ,record_data->tlist[tcnt ].orig_order_dt =
    concat (order_date ," " ,order_time ) ,record_data->tlist[tcnt ].order_dt_tm_utc = build (
     replace (datetimezoneformat (cnvtdatetime (o.orig_order_dt_tm ) ,datetimezonebyname ("UTC" ) ,
       "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].
    asc_num = concat (cnvtacc (ca.accession ) ) ,record_data->tlist[tcnt ].display_status = trim (
     uar_get_code_display (ta.task_status_cd ) ) ,
    IF ((ta.task_status_cd = inprocess ) ) record_data->tlist[tcnt ].inprocess_ind = 1
    ENDIF
    ,
    FOR (tseq = 1 TO size (task_stat->slist ,5 ) )
     IF ((ta.task_status_cd = task_stat->slist[tseq ].status_cd ) ) record_data->tlist[tcnt ].
      task_status = task_stat->slist[tseq ].status
     ENDIF
    ENDFOR
    ,
    IF ((ta.task_status_reason_cd = not_done ) ) record_data->tlist[tcnt ].not_done = 1 ,record_data
     ->tlist[tcnt ].status_reason_cd = ta.task_status_reason_cd
    ENDIF
    ,
    IF ((ot.allpositionchart_ind = 1 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
    ELSEIF ((otpx.reference_task_id > 0 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
    ENDIF
    ,record_data->tlist[tcnt ].task_resched_time = ot.reschedule_time ,
    IF ((o.pathway_catalog_id > 0 ) ) record_data->tlist[tcnt ].powerplan_ind = 1 ,record_data->
     tlist[tcnt ].powerplan_name = trim (pc.description )
    ENDIF
   HEAD ta.container_id
    IF ((((record_data->tlist[tcnt ].display_status != task_status ) ) OR ((record_data->tlist[tcnt ]
    .status_reason_cd != ta.task_status_reason_cd ) )) ) ccnt = 0 ,ocnt = 0 ,abncnt = 0 ,stat =
     initrec (order_id_list ) ,tcnt = (tcnt + 1 ) ,
     IF ((mod (tcnt ,100 ) = 1 ) ) stat = alterlist (record_data->tlist ,(tcnt + 99 ) )
     ENDIF
     ,record_data->tlist[tcnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/dd/yyyy" ) ,
     record_data->tlist[tcnt ].encounter_id = ta.encntr_id ,record_data->tlist[tcnt ].gender =
     uar_get_code_display (p.sex_cd ) ,record_data->tlist[tcnt ].gender_char = cnvtupper (substring (
       1 ,1 ,record_data->tlist[tcnt ].gender ) ) ,age_str = cnvtlower (trim (substring (1 ,12 ,
        cnvtage (p.birth_dt_tm ) ) ,4 ) ) ,
     IF ((findstring ("days" ,age_str ,0 ) > 0 ) ) days = findstring ("days" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,days ,age_str )
     ELSEIF ((findstring ("weeks" ,age_str ,0 ) > 0 ) ) weeks = findstring ("weeks" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,weeks ,age_str )
     ELSEIF ((findstring ("months" ,age_str ,0 ) > 0 ) ) months = findstring ("months" ,age_str ,0 )
     ,record_data->tlist[tcnt ].age = substring (1 ,months ,age_str )
     ELSEIF ((findstring ("years" ,age_str ,0 ) > 0 ) ) years = findstring ("years" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,years ,age_str )
     ENDIF
     ,record_data->tlist[tcnt ].person_id = p.person_id ,record_data->tlist[tcnt ].person_name =
     trim (p.name_full_formatted ) ,record_data->tlist[tcnt ].task_type_ind = 3 ,record_data->tlist[
     tcnt ].ordering_provider = trim (pr.name_full_formatted ) ,record_data->tlist[tcnt ].task_type
     = trim (replace (task_type ,"* " ,"" ,0 ) ) ,record_data->tlist[tcnt ].visit_loc = trim (
      uar_get_code_description (e.location_cd ) ) ,record_data->tlist[tcnt ].visit_date = format (
      cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YYYY;;d" ) ,record_data->tlist[tcnt ].visit_date_display =
     format (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YY;;d" ) ,record_data->tlist[tcnt ].visit_dt_tm_num
     = e.reg_dt_tm ,record_data->tlist[tcnt ].visit_dt_utc = build (replace (datetimezoneformat (
        cnvtdatetime (e.reg_dt_tm ) ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,
        curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].task_date = task_date ,
     record_data->tlist[tcnt ].task_dt_tm_num = datetimezone (ta.task_dt_tm ,ta.task_tz ) ,
     record_data->tlist[tcnt ].task_dt_tm_utc = build (replace (datetimezoneformat (cnvtdatetime (ta
         .task_dt_tm ) ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,
       "T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].charted_by = trim (pr2.name_full_formatted ) ,
     record_data->tlist[tcnt ].charted_dt = format (ta.updt_dt_tm ,"MM/DD/YYYY;4;D" ) ,record_data->
     tlist[tcnt ].charted_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (ta.updt_dt_tm )
        ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,
     IF ((ta.task_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) record_data->tlist[tcnt ].
      task_overdue = 1
     ENDIF
     ,
     IF ((o.prn_ind = 1 ) ) record_data->tlist[tcnt ].task_prn_ind = 1
     ENDIF
     ,record_data->tlist[tcnt ].task_time = task_time ,record_data->tlist[tcnt ].orig_order_dt =
     concat (order_date ," " ,order_time ) ,record_data->tlist[tcnt ].order_dt_tm_utc = build (
      replace (datetimezoneformat (cnvtdatetime (o.orig_order_dt_tm ) ,datetimezonebyname ("UTC" ) ,
        "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].
     asc_num = concat (cnvtacc (ca.accession ) ) ,record_data->tlist[tcnt ].display_status = trim (
      uar_get_code_display (ta.task_status_cd ) ) ,
     IF ((ta.task_status_cd = inprocess ) ) record_data->tlist[tcnt ].inprocess_ind = 1
     ENDIF
     ,
     FOR (tseq = 1 TO size (task_stat->slist ,5 ) )
      IF ((ta.task_status_cd = task_stat->slist[tseq ].status_cd ) ) record_data->tlist[tcnt ].
       task_status = task_stat->slist[tseq ].status
      ENDIF
     ENDFOR
     ,
     IF ((ta.task_status_reason_cd = not_done ) ) record_data->tlist[tcnt ].not_done = 1 ,record_data
      ->tlist[tcnt ].status_reason_cd = ta.task_status_reason_cd
     ENDIF
     ,
     IF ((ot.allpositionchart_ind = 1 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
     ELSEIF ((otpx.reference_task_id > 0 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
     ENDIF
     ,record_data->tlist[tcnt ].task_resched_time = ot.reschedule_time ,
     IF ((o.pathway_catalog_id > 0 ) ) record_data->tlist[tcnt ].powerplan_ind = 1 ,record_data->
      tlist[tcnt ].powerplan_name = trim (pc.description )
     ENDIF
    ENDIF
    ,ccnt = (ccnt + 1 ) ,stat = alterlist (record_data->tlist[tcnt ].contain_list ,ccnt ) ,
    IF ((ccnt > 1 ) ) record_data->tlist[tcnt ].asc_num = concat (record_data->tlist[tcnt ].asc_num ,
      ", #" ,cnvtstring (ca.accession_container_nbr ) )
    ELSE record_data->tlist[tcnt ].asc_num = concat (record_data->tlist[tcnt ].asc_num ," #" ,
      cnvtstring (ca.accession_container_nbr ) )
    ENDIF
    ,record_data->tlist[tcnt ].contain_list[ccnt ].contain_sent = concat (trim (specimen_container )
     ,", " ,trim (collection_volume ) ,", " ,trim (specimen_type ) ,", " ,trim (storage_temp ) ) ,
    IF ((c.spec_hndl_cd > 0 ) ) record_data->tlist[tcnt ].contain_list[ccnt ].contain_sent = concat (
      record_data->tlist[tcnt ].contain_list[ccnt ].contain_sent ,", " ,trim (special_handling ) )
    ENDIF
    ,record_data->tlist[tcnt ].contain_list[ccnt ].task_id = ta.task_id ,record_data->tlist[tcnt ].
    not_done = ta.task_status_reason_cd
   HEAD o.order_id
    o_found = 0 ,
    FOR (oseq = 1 TO size (order_id_list->olist ,5 ) )
     IF ((order_id_list->olist[oseq ].order_id = o.order_id ) ) o_found = 1
     ENDIF
    ENDFOR
    ,
    IF ((o_found != 1 ) ) ocnt = (ocnt + 1 ) ,stat = alterlist (order_id_list->olist ,ocnt ) ,stat =
     alterlist (record_data->tlist[tcnt ].olist ,ocnt ) ,record_data->tlist[tcnt ].olist[ocnt ].
     order_id = o.order_id ,record_data->tlist[tcnt ].olist[ocnt ].order_name = trim (o
      .ordered_as_mnemonic ) ,record_data->tlist[tcnt ].olist[ocnt ].ordering_prov = trim (pr
      .name_full_formatted ) ,order_id_list->olist[ocnt ].order_id = o.order_id ,
     IF ((record_data->tlist[tcnt ].ordered_as_name = "" ) ) record_data->tlist[tcnt ].
      ordered_as_name = trim (o.ordered_as_mnemonic )
     ELSE record_data->tlist[tcnt ].ordered_as_name = concat (record_data->tlist[tcnt ].
       ordered_as_name ,", " ,trim (o.ordered_as_mnemonic ) )
     ENDIF
     ,record_data->tlist[tcnt ].order_cnt = ocnt ,record_data->tlist[tcnt ].task_display =
     record_data->tlist[tcnt ].ordered_as_name ,
     IF ((record_data->tlist[tcnt ].ordering_provider = "" ) ) record_data->tlist[tcnt ].
      ordering_provider = trim (pr.name_full_formatted )
     ELSE
      IF ((findstring (trim (pr.name_full_formatted ) ,record_data->tlist[tcnt ].ordering_provider )
      = 0 ) ) record_data->tlist[tcnt ].ordering_provider = concat (record_data->tlist[tcnt ].
        ordering_provider ," | " ,trim (pr.name_full_formatted ) )
      ENDIF
     ENDIF
     ,
     IF ((record_data->tlist[tcnt ].order_id = "" ) ) record_data->tlist[tcnt ].order_id = trim (
       cnvtstring (o.order_id ) )
     ELSE record_data->tlist[tcnt ].order_id = concat (record_data->tlist[tcnt ].order_id ,"," ,trim
       (cnvtstring (o.order_id ) ) )
     ENDIF
     ,
     IF ((eem.abn_tracking_id > 0 )
     AND (cnvtupper (od3.oe_field_display_value ) != "NOT REQUIRED" ) ) abncnt = (abncnt + 1 ) ,stat
      = alterlist (record_data->tlist[tcnt ].abn_list ,abncnt ) ,record_data->tlist[tcnt ].abn_list[
      abncnt ].alert_state = uar_get_code_display (eem.abn_state_cd ) ,record_data->tlist[tcnt ].
      abn_list[abncnt ].alert_date = format (eem.active_status_dt_tm ,"MM/DD/YYYY HH:MM:SS;;d" ) ,
      record_data->tlist[tcnt ].abn_list[abncnt ].order_disp = trim (o.ordered_as_mnemonic ) ,
      IF ((record_data->tlist[tcnt ].abn_track_ids = "" ) ) record_data->tlist[tcnt ].abn_track_ids
       = cnvtstring (eem.abn_tracking_id )
      ELSE record_data->tlist[tcnt ].abn_track_ids = concat (record_data->tlist[tcnt ].abn_track_ids
        ,"," ,cnvtstring (eem.abn_tracking_id ) )
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherLabsByLocDt" ,1 ,0 ,
   record_data )
  CALL log_message (build ("Exit GatherLabsByLocDt(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
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
    record_data->type_list[tycnt ].selected = 1
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherTaskTypes" ,1 ,0 ,
   record_data )
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
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherUserPrefs" ,1 ,0 ,
   record_data )
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
 SUBROUTINE  gatherabnprogramnames (dummy )
  CALL log_message ("In GatherABNProgramNames()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET abn_request->call_echo_ind = 0
  SET abn_request->report_type_cd = 0
  SET abn_request->report_type_meaning = "EEMABN"
  EXECUTE sch_get_report_by_type WITH replace ("REQUEST" ,"ABN_REQUEST" ) ,
  replace ("REPLY" ,"ABN_REPLY" )
  IF ((abn_reply->qual_cnt > 0 ) )
   DECLARE abn_cnt = i2
   SET stat = alterlist (record_data->abn_form_list ,abn_reply->qual_cnt )
   FOR (abn_cnt = 0 TO abn_reply->qual_cnt )
    SET record_data->abn_form_list[abn_cnt ].program_desc = abn_reply->qual[abn_cnt ].desc
    SET record_data->abn_form_list[abn_cnt ].program_name = abn_reply->qual[abn_cnt ].program_name
   ENDFOR
  ENDIF
  CALL log_message (build ("Exit GatherABNProgramNames(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
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
#exit_script
#exit_program
 CALL log_message (concat ("Exiting script: " ,log_program_name ) ,log_level_debug )
 CALL log_message (build ("Total time in seconds:" ,datetimediff (cnvtdatetime (curdate ,curtime3 ) ,
    current_date_time ,5 ) ) ,log_level_debug )
 FREE RECORD record_data
END GO

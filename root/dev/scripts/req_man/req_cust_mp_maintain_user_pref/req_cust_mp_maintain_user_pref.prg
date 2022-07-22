DROP PROGRAM req_cust_mp_maintain_user_pref GO
CREATE PROGRAM req_cust_mp_maintain_user_pref
 PROMPT
  "Output to File/Printer/MINE: " = "MINE" ,
  "Provider ID: " = 0.00 ,
  "Preference Identifier: " = "" ,
  "Preference String: " = ""
  WITH outdev ,providerid ,preferenceidentifier ,preferencestring
 DECLARE deleteexistinguserprefs (null ) = null WITH protect
 DECLARE maintainuserpreferences (null ) = null WITH protect
 DECLARE breakstring ((p1 = vc (val ) ) ,(p2 = vc (ref ) ) ,(p3 = vc (val ) ) ) = null WITH protect
 FREE RECORD json_return
 RECORD json_return (
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
 SET log_override_ind = 0
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
 SET log_program_name = "AMB_CUST_MP_MAINTAIN_USER_PREF"
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
 SET json_return->status_data.status = "F"
 CALL deleteexistinguserprefs (null )
 IF ((size (trim ( $PREFERENCESTRING ,3 ) ) > 0 ) )
  CALL maintainuserpreferences (null )
 ENDIF
 SET json_return->status_data.status = "S"
 SUBROUTINE  deleteexistinguserprefs (null )
  CALL log_message ("In DeleteExistingUserPrefs()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  RECORD dcp_reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD dcp_del_request (
    1 nv_cnt = i4
    1 nv [* ]
      2 name_value_prefs_id = f8
  )
  SELECT INTO "nl:"
   FROM (app_prefs a ),
    (name_value_prefs n )
   PLAN (a
    WHERE (a.prsnl_id =  $PROVIDERID )
    AND (a.application_number = reqinfo->updt_app ) )
    JOIN (n
    WHERE (n.parent_entity_id = a.app_prefs_id )
    AND (n.parent_entity_name = "APP_PREFS" )
    AND (n.pvc_name =  $PREFERENCEIDENTIFIER ) )
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt + 1 ) ,
    IF ((cnt > size (dcp_del_request->nv ,5 ) ) ) stat = alterlist (dcp_del_request->nv ,(cnt + 9 )
      )
    ENDIF
    ,dcp_del_request->nv[cnt ].name_value_prefs_id = n.name_value_prefs_id
   FOOT REPORT
    dcp_del_request->nv_cnt = cnt ,
    stat = alterlist (dcp_del_request->nv ,cnt )
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"APP_PREFS" ,"DeleteExistingUserPrefs" ,1 ,0 ,
   dcp_del_request )
  IF ((curqual > 0 ) )
   EXECUTE dcp_del_name_value WITH replace ("REQUEST" ,"DCP_DEL_REQUEST" ) ,
   replace ("REPLY" ,"DCP_REPLY" )
   IF ((dcp_reply->status_data.status = "F" ) )
    SET json_return->status_data.status = "F"
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (dcp_del_request )
   CALL echorecord (dcp_reply )
  ENDIF
  FREE RECORD dcp_reply
  FREE RECORD dcp_del_request
  CALL log_message (build ("Exit DeleteExistingUserPrefs(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  maintainuserpreferences (null )
  CALL log_message ("In MaintainUserPreferences()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  RECORD dcp_reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD dcp_add_request (
    1 application_number = i4
    1 position_cd = f8
    1 prsnl_id = f8
    1 nv [* ]
      2 pvc_name = c32
      2 pvc_value = vc
      2 sequence = i2
      2 merge_id = f8
      2 merge_name = vc
  )
  CALL breakstring ( $PREFERENCESTRING ,dcp_add_request , $PREFERENCEIDENTIFIER )
  SET dcp_add_request->application_number = reqinfo->updt_app
  SET dcp_add_request->prsnl_id =  $PROVIDERID
  EXECUTE dcp_add_app_prefs WITH replace ("REQUEST" ,"DCP_ADD_REQUEST" ) ,
  replace ("REPLY" ,"DCP_REPLY" )
  IF ((dcp_reply->status_data.status = "F" ) )
   SET json_return->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (dcp_add_request )
   CALL echorecord (dcp_reply )
  ENDIF
  FREE RECORD dcp_reply
  FREE RECORD dcp_add_request
  CALL log_message (build ("Exit MaintainUserPreferences(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  breakstring (string ,rec ,pvc_name )
  CALL log_message ("In BreakString()" ,log_level_debug )
  DECLARE begin_date_time = q8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE max_len = i4 WITH constant (256 ) ,protect
  DECLARE idx = i4 WITH noconstant (0 ) ,protect
  DECLARE curposition = i4 WITH noconstant (1 ) ,protect
  IF ((reqinfo->updt_app = 3202004 ) )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo ('~~~*** Replacing ^ with " ***~~~' )
   ENDIF
   SET string = replace (string ,"^" ,'"' ,0 )
  ENDIF
  SET totalstringsize = size (string )
  WHILE ((curposition <= totalstringsize ) )
   SET idx = (idx + 1 )
   SET stat = alterlist (rec->nv ,idx )
   SET rec->nv[idx ].sequence = idx
   SET rec->nv[idx ].pvc_name = pvc_name
   SET len = (totalstringsize - (curposition - 1 ) )
   IF ((len > max_len ) )
    SET len = max_len
    SET rec->nv[idx ].pvc_value = substring (curposition ,len ,string )
    SET curposition = (curposition + max_len )
   ELSE
    SET rec->nv[idx ].pvc_value = substring (curposition ,len ,string )
    SET curposition = (totalstringsize + 1 )
   ENDIF
  ENDWHILE
  CALL log_message (build ("Exit BreakString(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
#exit_script
 DECLARE strjson = vc
 DECLARE _memory_reply_string = vc
 SET strjson = cnvtrectojson (json_return )
 SET _memory_reply_string = strjson
END GO

DROP PROGRAM inn_ltc_ipoc_st :dba GO
CREATE PROGRAM inn_ltc_ipoc_st :dba
 SET rhead = concat ("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}" ,
  "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134" )
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\plain \f0 \fs18 \cb2 "
 SET wb = "\plain \f0 \fs18 \b \cb2 "
 SET wu = "\plain \f0 \fs18 \ul \b \cb2 "
 SET wbi = "\plain \f0 \fs18 \b \i \cb2 "
 SET ws = "\plain \f0 \fs18 \strike \cb2"
 SET hi = "\pard\fi-2340\li2340 "
 SET rtfeof = "}"
 FREE SET ipoc_doc
 RECORD ipoc_doc (
   1 ipoc_doc_cnt = i4
   1 ipoc_qual [* ]
     2 ipoc_cd = f8
 )
 FREE SET ipoc_list
 RECORD ipoc_list (
   1 ipoc_cnt = i4
   1 ipoc [* ]
     2 pathway_id = f8
     2 display = vc
     2 plan_description = vc
     2 multi_phase = i2
     2 phase_description = vc
     2 start_dt_tm = dq8
     2 initiate_by = vc
     2 create_dt_sort = dq8
     2 create_dt_tm = vc
     2 status = vc
     2 last_seq = i4
     2 outcome_cnt = i4
     2 outcomes [* ]
       3 outcome_id = f8
       3 outcome_disp = vc
       3 outcome_note = vc
       3 outcome_result = vc
       3 in_error = vc
       3 type_ind = i4
       3 parent_entity_id = f8
       3 performed_by = vc
       3 performed_dt_tm = vc
       3 target_date = vc
       3 target_update_prsn = vc
       3 target_update_dt = vc
       3 target_type = vc
       3 initiated_dt_tm = vc
       3 initiated_by = vc
       3 action_text_id = f8
       3 action_result = vc
       3 action_comm = vc
       3 reason_text_id = f8
       3 reason_result = vc
       3 reason_comm = vc
 )
 FREE SET ipoc_sort
 RECORD ipoc_sort (
   1 ipoc_cnt = i4
   1 ipoc [* ]
     2 pathway_id = f8
     2 display = vc
     2 plan_description = vc
     2 multi_phase = i2
     2 phase_description = vc
     2 start_dt_tm = dq8
     2 initiate_by = vc
     2 create_dt_sort = dq8
     2 create_dt_tm = vc
     2 status = vc
     2 last_seq = i4
     2 outcome_cnt = i4
     2 outcomes [* ]
       3 outcome_id = f8
       3 outcome_disp = vc
       3 outcome_note = vc
       3 outcome_result = vc
       3 in_error = vc
       3 type_ind = i4
       3 parent_entity_id = f8
       3 performed_by = vc
       3 performed_dt_tm = vc
       3 target_date = vc
       3 target_update_prsn = vc
       3 target_update_dt = vc
       3 target_type = vc
       3 initiated_dt_tm = vc
       3 initiated_by = vc
       3 action_text_id = f8
       3 action_result = vc
       3 action_comm = vc
       3 reason_text_id = f8
       3 reason_result = vc
       3 reason_comm = vc
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
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2
  SELECT INTO persist
  ;end select
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4
  SELECT INTO persist
  ;end select
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc
  SELECT INTO persist
  ;end select
  DECLARE uar_i18nbuildmessage () = vc
  SELECT INTO persist
  ;end select
 ENDIF
 DECLARE i18nhandle = i4
 SELECT INTO persistscript
 ;end select
 CALL uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
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
 DECLARE auth_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE altered_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE modified_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE initiatedcd = f8 WITH constant (uar_get_code_by ("MEANING" ,16769 ,"INITIATED" ) ) ,protect
 DECLARE ordervoid = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"DELETED" ) ) ,protect
 DECLARE orderdisc = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"DISCONTINUED" ) ) ,protect
 DECLARE ordercomm = f8 WITH constant (uar_get_code_by ("MEANING" ,14 ,"ORD COMMENT" ) ) ,protect
 DECLARE 30182_activated = f8 WITH constant (uar_get_code_by ("MEANING" ,30182 ,"ACTIVATED" ) ) ,
 protect
 DECLARE 16789_activated = f8 WITH constant (uar_get_code_by ("MEANING" ,16789 ,"ACTIVATED" ) ) ,
 protect
 DECLARE goal = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"GOAL" ) ) ,protect
 DECLARE goalcp = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"GOALCP" ) ) ,protect
 DECLARE goaldp = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"GOALDP" ) ) ,protect
 DECLARE intervention = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"INTERVENTION" ) ) ,
 protect
 DECLARE interventndp = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"INTERVENTNDP" ) ) ,
 protect
 DECLARE indicator = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"INDICATOR" ) ) ,protect
 DECLARE indicatorcp = f8 WITH constant (uar_get_code_by ("MEANING" ,30320 ,"INDICATORCP" ) ) ,
 protect
 DECLARE index = i4 WITH noconstant (0 ) ,protect
 DECLARE pos = i4 WITH noconstant (0 ) ,protect
 DECLARE first_ind = i4 WITH noconstant (0 ) ,protect
 DECLARE first_i_ind = i4 WITH noconstant (0 ) ,protect
 DECLARE access_length = i4 WITH noconstant (0 ) ,protect
 DECLARE access_use = i4 WITH noconstant (0 ) ,protect
 DECLARE found = i4 WITH noconstant (0 ) ,protect
 SET reply->text = rhead
 SET nodatacaption = uar_i18ngetmessage (i18nhandle ,"NoData" ," No qualifying data available" )
 SET titlecaption = "Current IPOCs / Short Term Goalsx";
  ;uar_i18ngetmessage (i18nhandle ,"Title" ,"Current IPOCs / Short Term Goals" )
 SET goalcaption = uar_i18ngetmessage (i18nhandle ,"Goal" ,"Goals" )
 SET interventionscaption = uar_i18ngetmessage (i18nhandle ,"Interventions" ,"Interventions" )
 SET outmetcaption = uar_i18ngetmessage (i18nhandle ,"OutMetReason" ,"Outcome Note:" )
 SET outreasoncaption = uar_i18ngetmessage (i18nhandle ,"OutReason" ,"Outcome Variance Reason:" )
 SET outactioncaption = uar_i18ngetmessage (i18nhandle ,"OutAction" ,"Outcome Variance Action:" )
 SET lastupdtbycaption = uar_i18ngetmessage (i18nhandle ,"UpdateAction" ,"Last Update By: " )
 SET targetcaption = uar_i18ngetmessage (i18nhandle ,"TargPerByAction" ,"Target Date: " )
 SET initiatedatecaption = uar_i18ngetmessage (i18nhandle ,"InitiateAction" ,"Initiated Date: " )
 SET targperbycaption = uar_i18ngetmessage (i18nhandle ,"TargPerAction" ,"No target date entered" )
 DECLARE getcodevalues (null ) = null
 DECLARE getipoc (null ) = null
 DECLARE getipocoutcomes (null ) = null
 DECLARE sortdata (null ) = null
 DECLARE printdata (null ) = null
 CALL getcodevalues (null )
 CALL getipoc (null )
 CALL getipocoutcomes (null )
 CALL sortdata (null )
 CALL printdata (null )
 SUBROUTINE  getcodevalues (null )
  SELECT INTO "nl:"
   FROM (code_value cv )
   WHERE (cv.code_set = 30183 )
   AND (cv.cdf_meaning = "IPOC" )
   HEAD REPORT
    ipoc_cnt = 0
   DETAIL
    ipoc_cnt = (ipoc_cnt + 1 ) ,
    stat = alterlist (ipoc_doc->ipoc_qual ,ipoc_cnt ) ,
    ipoc_doc->ipoc_qual[ipoc_cnt ].ipoc_cd = cv.code_value
   FOOT REPORT
    ipoc_doc->ipoc_doc_cnt = ipoc_cnt ,
    stat = alterlist (ipoc_doc->ipoc_qual ,ipoc_cnt )
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getipoc (null )
  SELECT INTO "nl:"
   temp_disp =
   IF ((p.type_mean = "CAREPLAN" ) ) trim (p.description )
   ELSE concat (trim (p.pw_group_desc ) ,", " ,trim (p.description ) )
   ENDIF
   ,temp_stat = uar_get_code_display (p.pw_status_cd )
   FROM (pathway p ),
    (act_pw_comp apc ),
    (outcome_activity oa ),
    (prsnl pr )
   PLAN (p
    WHERE (p.encntr_id = request->visit[1 ].encntr_id )
    AND ((p.started_ind + 0 ) = 1 )
    AND ((p.ended_ind + 0 ) != 1 )
    AND ((p.pw_status_cd + 0 ) = initiatedcd )
    AND (trim (p.type_mean ) IN ("CAREPLAN" ,
    "PHASE" ) )
    AND expand (index ,1 ,ipoc_doc->ipoc_doc_cnt ,p.pathway_type_cd ,ipoc_doc->ipoc_qual[index ].
     ipoc_cd ) )
    JOIN (apc
    WHERE (apc.pathway_id = p.pathway_id )
    AND (apc.included_ind = 1 )
    AND (apc.activated_ind = 1 )
    AND (apc.parent_entity_name = "OUTCOME_ACTIVITY" ) )
    JOIN (oa
    WHERE (oa.outcome_activity_id = apc.parent_entity_id )
    AND (oa.outcome_type_cd IN (goal ,
    goalcp ,
    goaldp ,
    intervention ,
    interventndp ,
    indicator ,
    indicatorcp ) )
    AND (oa.outcome_status_cd = 30182_activated ) )
    JOIN (pr
    WHERE (pr.person_id = apc.activated_prsnl_id ) )
   ORDER BY p.pw_cat_group_id ,
    p.start_dt_tm DESC ,
    p.last_action_seq DESC ,
    p.pathway_id ,
    apc.activated_dt_tm DESC ,
    oa.outcome_activity_id
   HEAD REPORT
    cnt = 0
   HEAD p.pw_cat_group_id
    sdate = p.start_dt_tm
   HEAD p.pathway_id
    cnt = (cnt + 1 ) ,stat = alterlist (ipoc_list->ipoc ,cnt ) ,ipoc_list->ipoc[cnt ].pathway_id = p
    .pathway_id ,ipoc_list->ipoc[cnt ].start_dt_tm = sdate ,ipoc_list->ipoc[cnt ].create_dt_sort =
    apc.activated_dt_tm ,ipoc_list->ipoc[cnt ].create_dt_tm = format (apc.activated_dt_tm ,
     "MM/DD/YYYY ;;D" ) ,ipoc_list->ipoc[cnt ].display = temp_disp ,ipoc_list->ipoc[cnt ].
    phase_description = p.description ,ipoc_list->ipoc[cnt ].plan_description = p.pw_group_desc ,
    ipoc_list->ipoc[cnt ].initiate_by = pr.name_full_formatted ,ipoc_list->ipoc[cnt ].status =
    temp_stat ,ipoc_list->ipoc[cnt ].last_seq = p.last_action_seq ,ipoc_list->ipoc[cnt ].multi_phase
    =
    IF ((p.type_mean = "CAREPLAN" ) ) 0
    ELSE 1
    ENDIF
   DETAIL
    null
   FOOT REPORT
    ipoc_list->ipoc_cnt = cnt ,
    stat = alterlist (ipoc_list->ipoc ,cnt )
   WITH nocounter ,expand = 1
  ;end select
  CALL error_and_zero_check_rec (curqual ,"LTC IPOC" ,"CCL error" ,1 ,0 ,ipoc_list )
  IF ((curqual = 0 ) )
   SET reply->text = build2 (reply->text ,nodatacaption ,reol )
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  getipocoutcomes (null )
  SELECT INTO "nl:"
   FROM (pathway pt ),
    (act_pw_comp apc ),
    (outcome_activity oa ),
    (outcome_action oat ),
    (prsnl p1 ),
    (pw_variance_reltn pvr ),
    (long_text lt ),
    (clinical_event ce ),
    (prsnl p ),
    (prsnl p2 )
   PLAN (pt
    WHERE expand (index ,1 ,ipoc_list->ipoc_cnt ,pt.pathway_id ,ipoc_list->ipoc[index ].pathway_id )
    )
    JOIN (apc
    WHERE (apc.pathway_id = pt.pathway_id )
    AND (apc.included_ind = 1 )
    AND (apc.activated_ind = 1 )
    AND (apc.parent_entity_name = "OUTCOME_ACTIVITY" )
    AND (apc.comp_status_cd = 16789_activated ) )
    JOIN (oa
    WHERE (oa.outcome_activity_id = apc.parent_entity_id )
    AND (oa.outcome_type_cd IN (goal ,
    goalcp ,
    goaldp ,
    intervention ,
    interventndp ,
    indicator ,
    indicatorcp ) )
    AND (oa.outcome_status_cd = 30182_activated ) )
    JOIN (oat
    WHERE (oat.outcome_activity_id = oa.outcome_activity_id )
    AND (oat.outcome_status_cd = 30182_activated ) )
    JOIN (p2
    WHERE (p2.person_id = apc.activated_prsnl_id ) )
    JOIN (p1
    WHERE (p1.person_id = oa.updt_id ) )
    JOIN (ce
    WHERE (ce.event_cd = outerjoin (oa.event_cd ) )
    AND (ce.encntr_id = outerjoin (oa.encntr_id ) )
    AND (ce.person_id = outerjoin (oa.person_id ) )
    AND (ce.valid_until_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime ) ) ) )
    JOIN (p
    WHERE (p.person_id = outerjoin (ce.performed_prsnl_id ) ) )
    JOIN (pvr
    WHERE (pvr.parent_entity_id = outerjoin (apc.act_pw_comp_id ) )
    AND (pvr.parent_entity_name = outerjoin ("ACT_PW_COMP" ) )
    AND (pvr.active_ind = outerjoin (1 ) ) )
    JOIN (lt
    WHERE (lt.parent_entity_id = outerjoin (pvr.parent_entity_id ) )
    AND (lt.parent_entity_name = outerjoin ("ACT_PW_COMP" ) )
    AND (lt.long_text_id = outerjoin (pvr.note_text_id ) ) )
   ORDER BY pt.pw_cat_group_id ,
    pt.start_dt_tm DESC ,
    pt.pathway_id ,
    apc.comp_label DESC ,
    oa.outcome_activity_id ,
    ce.clinical_event_id ,
    ce.performed_dt_tm ,
    pvr.chart_dt_tm
   HEAD REPORT
    access_use = 0 ,
    access_length = 0
   HEAD pt.pw_cat_group_id
    null
   HEAD apc.pathway_id
    cnt = 0
   HEAD oa.outcome_activity_id
    found = 0 ,pos = locateval (index ,1 ,ipoc_list->ipoc_cnt ,apc.pathway_id ,ipoc_list->ipoc[index
     ].pathway_id ) ,
    IF ((pos > 0 ) ) cnt = (cnt + 1 ) ,stat = alterlist (ipoc_list->ipoc[pos ].outcomes ,cnt ) ,
     ipoc_list->ipoc[pos ].outcomes[cnt ].outcome_disp = trim (oa.description ) ,ipoc_list->ipoc[pos
     ].outcomes[cnt ].outcome_id = oa.outcome_activity_id ,ipoc_list->ipoc[pos ].outcomes[cnt ].
     initiated_by = p2.name_full_formatted ,ipoc_list->ipoc[pos ].outcomes[cnt ].initiated_dt_tm =
     format (apc.activated_dt_tm ,"MM/DD/YYYY;;D" ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].target_date
      = format (oa.end_dt_tm ,"MM/DD/YYYY;;D" ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].target_type =
     uar_get_code_display (oa.target_type_cd ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].
     target_update_prsn = p1.name_full_formatted ,ipoc_list->ipoc[pos ].outcomes[cnt ].
     target_update_dt = format (oa.outcome_status_dt_tm ,"MM/DD/YYYY;;D" )
    ENDIF
   DETAIL
    access_length = size (trim (ce.accession_nbr ,3 ) ) ,
    access_use = cnvtreal (substring (3 ,access_length ,trim (ce.accession_nbr ,3 ) ) ) ,
    IF ((ce.result_status_cd IN (auth_cd ,
    altered_cd ,
    modified_cd ) ) )
     IF ((oa.outcome_activity_id = access_use ) ) ipoc_list->ipoc[pos ].outcomes[cnt ].performed_by
      = trim (p.name_full_formatted ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].performed_dt_tm = format
      (ce.event_end_dt_tm ,"MM/DD/YYYY;;D" ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].action_text_id =
      pvr.action_text_id ,ipoc_list->ipoc[pos ].outcomes[cnt ].reason_text_id = pvr.reason_text_id ,
      ipoc_list->ipoc[pos ].outcomes[cnt ].outcome_result = ce.result_val ,ipoc_list->ipoc[pos ].
      outcomes[cnt ].outcome_note = lt.long_text ,ipoc_list->ipoc[pos ].outcomes[cnt ].
      parent_entity_id = apc.parent_entity_id ,ipoc_list->ipoc[pos ].outcomes[cnt ].action_result =
      uar_get_code_display (pvr.action_cd ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].reason_result =
      uar_get_code_display (pvr.reason_cd )
     ENDIF
     ,
     IF ((size (trim (ce.accession_nbr ,3 ) ) = 0 ) ) ipoc_list->ipoc[pos ].outcomes[cnt ].
      performed_by = trim (p.name_full_formatted ) ,ipoc_list->ipoc[pos ].outcomes[cnt ].
      performed_dt_tm = format (ce.event_end_dt_tm ,"MM/DD/YYYY;;D" ) ,ipoc_list->ipoc[pos ].
      outcomes[cnt ].action_text_id = pvr.action_text_id ,ipoc_list->ipoc[pos ].outcomes[cnt ].
      reason_text_id = pvr.reason_text_id ,ipoc_list->ipoc[pos ].outcomes[cnt ].outcome_result = ce
      .result_val ,ipoc_list->ipoc[pos ].outcomes[cnt ].outcome_note = lt.long_text ,ipoc_list->ipoc[
      pos ].outcomes[cnt ].parent_entity_id = apc.parent_entity_id ,ipoc_list->ipoc[pos ].outcomes[
      cnt ].action_result = uar_get_code_display (pvr.action_cd ) ,ipoc_list->ipoc[pos ].outcomes[
      cnt ].reason_result = uar_get_code_display (pvr.reason_cd )
     ENDIF
     ,
     IF ((apc.comp_label = "OUT" ) ) ipoc_list->ipoc[pos ].outcomes[cnt ].type_ind = 1
     ELSEIF ((apc.comp_label = "INT" ) ) ipoc_list->ipoc[pos ].outcomes[cnt ].type_ind = 2
     ENDIF
    ENDIF
   FOOT  apc.pathway_id
    ipoc_list->ipoc[pos ].outcome_cnt = cnt ,stat = alterlist (ipoc_list->ipoc[pos ].outcomes ,cnt )
   WITH nocounter ,expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM (act_pw_comp apc ),
    (pw_variance_reltn pvr ),
    (long_text lt1 ),
    (long_text lt2 )
   PLAN (apc
    WHERE expand (index ,1 ,ipoc_list->ipoc_cnt ,apc.pathway_id ,ipoc_list->ipoc[index ].pathway_id
     ) )
    JOIN (pvr
    WHERE (pvr.parent_entity_id = outerjoin (apc.act_pw_comp_id ) )
    AND (pvr.parent_entity_name = outerjoin ("ACT_PW_COMP" ) ) )
    JOIN (lt1
    WHERE (lt1.long_text_id = outerjoin (pvr.action_text_id ) ) )
    JOIN (lt2
    WHERE (lt2.long_text_id = outerjoin (pvr.reason_text_id ) ) )
   ORDER BY pvr.chart_dt_tm
   DETAIL
    FOR (z = 1 TO ipoc_list->ipoc_cnt )
     FOR (y = 1 TO ipoc_list->ipoc[z ].outcome_cnt )
      IF ((ipoc_list->ipoc[z ].outcomes[y ].action_text_id = lt1.long_text_id ) ) ipoc_list->ipoc[z ]
       .outcomes[y ].action_comm = lt1.long_text
      ENDIF
      ,
      IF ((ipoc_list->ipoc[z ].outcomes[y ].reason_text_id = lt2.long_text_id ) ) ipoc_list->ipoc[z ]
       .outcomes[y ].reason_comm = lt2.long_text
      ENDIF
     ENDFOR
    ENDFOR
   WITH nocounter ,expand = 1
  ;end select
 END ;Subroutine
 SUBROUTINE  sortdata (null )
  SELECT INTO "nl:"
   path_id = ipoc_list->ipoc[d1.seq ].pathway_id
   FROM (dummyt d1 WITH seq = value (size (ipoc_list->ipoc ,5 ) ) )
   PLAN (d1 )
   ORDER BY ipoc_list->ipoc[d1.seq ].start_dt_tm DESC ,
    ipoc_list->ipoc[d1.seq ].create_dt_sort DESC ,
    ipoc_list->ipoc[d1.seq ].last_seq DESC ,
    ipoc_list->ipoc[d1.seq ].pathway_id
   HEAD REPORT
    scnt = 0
   HEAD path_id
    scnt3 = 0 ,scnt = (scnt + 1 ) ,stat = alterlist (ipoc_sort->ipoc ,scnt ) ,ipoc_sort->ipoc[scnt ].
    pathway_id = ipoc_list->ipoc[d1.seq ].pathway_id ,ipoc_sort->ipoc[scnt ].start_dt_tm = ipoc_list
    ->ipoc[d1.seq ].start_dt_tm ,ipoc_sort->ipoc[scnt ].create_dt_sort = ipoc_list->ipoc[d1.seq ].
    create_dt_sort ,ipoc_sort->ipoc[scnt ].create_dt_tm = ipoc_list->ipoc[d1.seq ].create_dt_tm ,
    ipoc_sort->ipoc[scnt ].display = ipoc_list->ipoc[d1.seq ].display ,ipoc_sort->ipoc[scnt ].
    phase_description = ipoc_list->ipoc[d1.seq ].phase_description ,ipoc_sort->ipoc[scnt ].
    plan_description = ipoc_list->ipoc[d1.seq ].plan_description ,ipoc_sort->ipoc[scnt ].initiate_by
    = ipoc_list->ipoc[d1.seq ].initiate_by ,ipoc_sort->ipoc[scnt ].status = ipoc_list->ipoc[d1.seq ].
    status ,ipoc_sort->ipoc[scnt ].multi_phase = ipoc_list->ipoc[d1.seq ].multi_phase ,ipoc_sort->
    ipoc[scnt ].last_seq = ipoc_list->ipoc[d1.seq ].last_seq
   DETAIL
    FOR (x = 1 TO ipoc_list->ipoc[d1.seq ].outcome_cnt )
     scnt3 = (scnt3 + 1 ) ,stat = alterlist (ipoc_sort->ipoc[scnt ].outcomes ,scnt3 ) ,ipoc_sort->
     ipoc[scnt ].outcomes[scnt3 ].outcome_disp = ipoc_list->ipoc[d1.seq ].outcomes[x ].outcome_disp ,
     ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].outcome_id = ipoc_list->ipoc[d1.seq ].outcomes[x ].
     outcome_id ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].initiated_by = ipoc_list->ipoc[d1.seq ].
     outcomes[x ].initiated_by ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].initiated_dt_tm = ipoc_list->
     ipoc[d1.seq ].outcomes[x ].initiated_dt_tm ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].target_date
     = ipoc_list->ipoc[d1.seq ].outcomes[x ].target_date ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].
     target_type = ipoc_list->ipoc[d1.seq ].outcomes[x ].target_type ,ipoc_sort->ipoc[scnt ].
     outcomes[scnt3 ].target_update_prsn = ipoc_list->ipoc[d1.seq ].outcomes[x ].target_update_prsn ,
     ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].target_update_dt = ipoc_list->ipoc[d1.seq ].outcomes[x ]
     .target_update_dt ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].performed_by = ipoc_list->ipoc[d1
     .seq ].outcomes[x ].performed_by ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].performed_dt_tm =
     ipoc_list->ipoc[d1.seq ].outcomes[x ].performed_dt_tm ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].
     action_text_id = ipoc_list->ipoc[d1.seq ].outcomes[x ].action_text_id ,ipoc_sort->ipoc[scnt ].
     outcomes[scnt3 ].reason_text_id = ipoc_list->ipoc[d1.seq ].outcomes[x ].reason_text_id ,
     ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].outcome_result = ipoc_list->ipoc[d1.seq ].outcomes[x ].
     outcome_result ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].outcome_note = ipoc_list->ipoc[d1.seq ].
     outcomes[x ].outcome_note ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].parent_entity_id = ipoc_list
     ->ipoc[d1.seq ].outcomes[x ].parent_entity_id ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].
     action_comm = ipoc_list->ipoc[d1.seq ].outcomes[x ].action_comm ,ipoc_sort->ipoc[scnt ].
     outcomes[scnt3 ].action_result = ipoc_list->ipoc[d1.seq ].outcomes[x ].action_result ,ipoc_sort
     ->ipoc[scnt ].outcomes[scnt3 ].reason_comm = ipoc_list->ipoc[d1.seq ].outcomes[x ].reason_comm ,
     ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].reason_result = ipoc_list->ipoc[d1.seq ].outcomes[x ].
     reason_result ,ipoc_sort->ipoc[scnt ].outcomes[scnt3 ].type_ind = ipoc_list->ipoc[d1.seq ].
     outcomes[x ].type_ind
    ENDFOR
   FOOT  path_id
    ipoc_sort->ipoc[scnt ].outcome_cnt = scnt3 ,stat = alterlist (ipoc_sort->ipoc[scnt ].outcomes ,
     scnt3 )
   FOOT REPORT
    ipoc_sort->ipoc_cnt = scnt ,
    stat = alterlist (ipoc_sort->ipoc ,scnt )
   WITH nocounter
  ;end select
  CALL echorecord (ipoc_sort )
 END ;Subroutine
 SUBROUTINE  printdata (null )
  SET reply->text = concat (reply->text ,wb ,wu ,titlecaption ,wr ,reol )
  FOR (y = 1 TO ipoc_sort->ipoc_cnt )
   SET reply->text = build2 (reply->text ,wb ,reol ,"\fi0" ,trim (ipoc_sort->ipoc[y ].display ,3 ) ,
    ",  " ,initiatedatecaption ," " ,format (ipoc_sort->ipoc[y ].start_dt_tm ,"MM/DD/YYYY;;D" ) ,
    ",  " ,lastupdtbycaption ," " ,trim (ipoc_sort->ipoc[y ].initiate_by ,3 ) ,",   " ,trim (
     ipoc_sort->ipoc[y ].create_dt_tm ,3 ) ,reol )
   SET first_ind = 0
   SET first_i_ind = 0
   FOR (z = 1 TO ipoc_sort->ipoc[y ].outcome_cnt )
    IF ((ipoc_sort->ipoc[y ].outcomes[z ].type_ind = 1 ) )
     IF ((first_ind = 0 ) )
      SET reply->text = build2 (reply->text ,wb ,wu ,"\fi0" ,goalcaption ,reol )
      SET first_ind = 1
     ENDIF
    ELSEIF ((ipoc_sort->ipoc[y ].outcomes[z ].type_ind = 2 ) )
     IF ((first_i_ind = 0 ) )
      SET reply->text = build2 (reply->text ,wb ,wu ,"\fi0" ,interventionscaption ,reol )
      SET first_i_ind = 1
     ENDIF
    ENDIF
    SET reply->text = build2 (reply->text ,wb ,"\fi200" ,ipoc_sort->ipoc[y ].outcomes[z ].
     outcome_disp ,",  " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].initiated_dt_tm ,3 ) ,", " ,trim (
      ipoc_sort->ipoc[y ].outcomes[z ].initiated_by ,3 ) ,reol )
    IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].target_date ,3 ) ) > 0 ) )
     SET reply->text = build2 (reply->text ,wr ,"\fi350" ,targetcaption ,"  " ,trim (ipoc_sort->ipoc[
       y ].outcomes[z ].target_date ,3 ) ,"  Performed By: " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].
       target_update_prsn ,3 ) ,",  " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].target_update_dt ,3 ) ,
      reol )
    ELSEIF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].target_type ,3 ) ) > 0 ) )
     SET reply->text = build2 (reply->text ,wr ,"\fi350" ,targetcaption ,"  " ,trim (ipoc_sort->ipoc[
       y ].outcomes[z ].target_type ,3 ) ,"  Performed By: " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].
       target_update_prsn ,3 ) ,",  " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].target_update_dt ,3 ) ,
      reol )
    ELSE
     SET reply->text = build2 (reply->text ,wr ,"\fi350" ,targperbycaption ,reol )
    ENDIF
    IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].outcome_result ,3 ) ) > 0 ) )
     SET reply->text = build2 (reply->text ,wr ,trim (ipoc_sort->ipoc[y ].outcomes[z ].outcome_result
        ,3 ) ,",   " ,ipoc_sort->ipoc[y ].outcomes[z ].performed_dt_tm ,"  " ,trim (ipoc_sort->ipoc[
       y ].outcomes[z ].performed_by ,3 ) ,reol )
     IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].reason_result ,3 ) ) > 0 ) )
      SET reply->text = build2 (reply->text ,wr ,"\fi350" ,outreasoncaption ," " ,trim (ipoc_sort->
        ipoc[y ].outcomes[z ].reason_result ,3 ) )
      IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].reason_comm ,3 ) ) > 0 ) )
       SET reply->text = build2 (reply->text ,",   " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].
         reason_comm ,3 ) ,reol )
      ELSE
       SET reply->text = build2 (reply->text ,reol )
      ENDIF
     ELSEIF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].reason_comm ,3 ) ) > 0 ) )
      SET reply->text = build2 (reply->text ,wr ,"\fi350" ,outreasoncaption ,"  " ,trim (ipoc_sort->
        ipoc[y ].outcomes[z ].reason_comm ,3 ) ,reol )
     ENDIF
     IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].action_result ,3 ) ) > 0 ) )
      SET reply->text = build2 (reply->text ,wr ,"\fi350" ,outactioncaption ," " ,trim (ipoc_sort->
        ipoc[y ].outcomes[z ].action_result ,3 ) )
      IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].action_comm ,3 ) ) > 0 ) )
       SET reply->text = build2 (reply->text ,",   " ,trim (ipoc_sort->ipoc[y ].outcomes[z ].
         action_comm ,3 ) ,reol )
      ELSE
       SET reply->text = build2 (reply->text ,reol )
      ENDIF
     ELSEIF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].action_comm ,3 ) ) > 0 ) )
      SET reply->text = build2 (reply->text ,wr ,"\fi350" ,outactioncaption ," " ,trim (ipoc_sort->
        ipoc[y ].outcomes[z ].action_comm ,3 ) ,reol )
     ENDIF
     IF ((size (trim (ipoc_sort->ipoc[y ].outcomes[z ].outcome_note ,3 ) ) > 0 ) )
      SET reply->text = build2 (reply->text ,wr ,outmetcaption ,"  " ,trim (ipoc_sort->ipoc[y ].
        outcomes[z ].outcome_note ,3 ) ,reol )
     ENDIF
    ENDIF
    SET reply->text = build2 (reply->text ,reol )
   ENDFOR
  ENDFOR
 END ;Subroutine
#exit_script
 SET reply->text = concat (reply->text ,rtfeof )
 CALL echo (reply->text )
END GO

/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Source file name:       chs_wklist_prov_grplist_temp.prg
        Object name:            chs_wklist_prov_grplist_temp
        Request #:
 
        Product:
        Product Team:
        HNA Version:
        CCL Version:
 
        Program purpose:        provider handoff custom template
 
        Tables read:
 
        Tables updated:
 
        Executing from:         PowerChart
 
        Special Notes:
 
******************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer    Feature   Comment                            *
;    *--- -------- -------------------- ----------------------------------- *
;    *001 12/04/20 CS075950              Initial Relsease                   *
;    *003 12/10/2020 CCUMMIN4			 Sorted by UNIT				        *
;~DE~************************************************************************
 
drop program chs_wklist_prov_grplist_temp:dba go
create program chs_wklist_prov_grplist_temp:dba

 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "JSON Request:" = ""
 
with OUTDEV, jsondata
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
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
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
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
 
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
 DECLARE current_time_zone = i4 WITH constant (datetimezonebyname (curtimezone ) ) ,protect
 DECLARE ending_date_time = dq8 WITH constant (cnvtdatetime ("31-DEC-2100" ) ) ,protect
 DECLARE bind_cnt = i4 WITH constant (50 ) ,protect
 DECLARE lower_bound_date = vc WITH constant ("01-JAN-1800 00:00:00.00" ) ,protect
 DECLARE upper_bound_date = vc WITH constant ("31-DEC-2100 23:59:59.99" ) ,protect
 DECLARE codelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnllistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE phonelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE code_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE phone_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_cnt = i4 WITH noconstant (0 ) ,protect
 DECLARE mpc_ap_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_doc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mdoc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_rad_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_txt_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_num_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_immun_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_med_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_date_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_done_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mbo_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_procedure_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_grp_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE eventclasscdpopulated = i2 WITH protect ,noconstant (0 )
 DECLARE addcodetolist ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE addpersonneltolist ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE addpersonneltolistwithdate ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ,(p3 = f8 (val ) ) ) =
 null WITH protect
 DECLARE addphonestolist ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE putjsonrecordtofile ((p1 = vc (ref ) ) ) = null WITH protect
 DECLARE putstringtofile ((p1 = vc (val ) ) ) = null WITH protect
 DECLARE putunboundedstringtofile ((p1 = vc (ref ) ) ) = null WITH protect
 DECLARE outputcodelist ((p1 = vc (ref ) ) ) = null WITH protect
 DECLARE outputpersonnellist ((p1 = vc (ref ) ) ) = null WITH protect
 DECLARE outputphonelist ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE getparametervalues ((p1 = i4 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE getlookbackdatebytype ((p1 = i4 (val ) ) ,(p2 = i4 (val ) ) ) = dq8 WITH protect
 DECLARE getcodevaluesfromcodeset ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE geteventsetnamesfromeventsetcds ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE returnviewertype ((p1 = f8 (val ) ) ,(p2 = f8 (val ) ) ) = vc WITH protect
 DECLARE cnvtisodttmtodq8 ((p1 = vc ) ) = dq8 WITH protect
 DECLARE cnvtdq8toisodttm ((p1 = f8 ) ) = vc WITH protect
 DECLARE getorgsecurityflag (null ) = i2 WITH protect
 DECLARE getcomporgsecurityflag ((p1 = vc (val ) ) ) = i2 WITH protect
 DECLARE populateauthorizedorganizations ((p1 = f8 (val ) ) ,(p2 = vc (ref ) ) ) = null WITH protect
 DECLARE getuserlogicaldomain ((p1 = f8 ) ) = f8 WITH protect
 DECLARE getpersonneloverride ((ppr_cd = f8 (val ) ) ) = i2 WITH protect
 DECLARE cclimpersonation (null ) = null WITH protect
 DECLARE geteventsetdisplaysfromeventsetcds ((p1 = vc (ref ) ) ,(p2 = vc (ref ) ) ) = null WITH
 protect
 DECLARE decodestringparameter ((description = vc (val ) ) ) = vc WITH protect
 DECLARE urlencode ((json = vc (val ) ) ) = vc WITH protect
 DECLARE istaskgranted ((task_number = i4 (val ) ) ) = i2 WITH protect
 
 
 SUBROUTINE  addcodetolist (code_value ,record_data )
  IF ((code_value != 0 ) )
   IF ((((codelistcnt = 0 ) ) OR ((locateval (code_idx ,1 ,codelistcnt ,code_value ,record_data->
    codes[code_idx ].code ) <= 0 ) )) )
    SET codelistcnt = (codelistcnt + 1 )
    SET stat = alterlist (record_data->codes ,codelistcnt )
    SET record_data->codes[codelistcnt ].code = code_value
    SET record_data->codes[codelistcnt ].sequence = uar_get_collation_seq (code_value )
    SET record_data->codes[codelistcnt ].meaning = uar_get_code_meaning (code_value )
    SET record_data->codes[codelistcnt ].display = uar_get_code_display (code_value )
    SET record_data->codes[codelistcnt ].description = uar_get_code_description (code_value )
    SET record_data->codes[codelistcnt ].code_set = uar_get_code_set (code_value )
   ENDIF
  ENDIF
 END ;Subroutine
 
 SUBROUTINE  outputcodelist (record_data )
  CALL log_message ("In OutputCodeList() @deprecated" ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  addpersonneltolist (prsnl_id ,record_data )
  CALL addpersonneltolistwithdate (prsnl_id ,record_data ,current_date_time )
 END ;Subroutine
 
 SUBROUTINE  addpersonneltolistwithdate (prsnl_id ,record_data ,active_date )
  DECLARE personnel_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) )
  IF ((((active_date = null ) ) OR ((active_date = 0.0 ) )) )
   SET active_date = current_date_time
  ENDIF
  IF ((prsnl_id != 0 ) )
   IF ((((prsnllistcnt = 0 ) ) OR ((locateval (prsnl_idx ,1 ,prsnllistcnt ,prsnl_id ,record_data->
    prsnl[prsnl_idx ].id ,active_date ,record_data->prsnl[prsnl_idx ].active_date ) <= 0 ) )) )
    SET prsnllistcnt = (prsnllistcnt + 1 )
    IF ((prsnllistcnt > size (record_data->prsnl ,5 ) ) )
     SET stat = alterlist (record_data->prsnl ,(prsnllistcnt + 9 ) )
    ENDIF
    SET record_data->prsnl[prsnllistcnt ].id = prsnl_id
    IF ((validate (record_data->prsnl[prsnllistcnt ].active_date ) != 0 ) )
     SET record_data->prsnl[prsnllistcnt ].active_date = active_date
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 
 SUBROUTINE  outputpersonnellist (report_data )
  CALL log_message ("In OutputPersonnelList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE prsnl_name_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) ) ,
  protect
  DECLARE active_date_ind = i2 WITH protect ,noconstant (0 )
  DECLARE filteredcnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnl_seq = i4 WITH protect ,noconstant (0 )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  IF ((prsnllistcnt > 0 ) )
   SELECT INTO "nl:"
    FROM (prsnl p ),
     (left
     JOIN person_name pn ON (pn.person_id = p.person_id )
     AND (pn.name_type_cd = prsnl_name_type_cd )
     AND (pn.active_ind = 1 ) )
    PLAN (p
     WHERE expand (idx ,1 ,size (report_data->prsnl ,5 ) ,p.person_id ,report_data->prsnl[idx ].id )
     )
     JOIN (pn )
    ORDER BY p.person_id ,
     pn.end_effective_dt_tm DESC
    HEAD REPORT
     prsnl_seq = 0 ,
     active_date_ind = validate (report_data->prsnl[1 ].active_date ,0 )
    HEAD p.person_id
     IF ((active_date_ind = 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (pn
        .name_full ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (pn
        .name_first ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_middle = trim (pn
        .name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn
        .name_last ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3
        ) ,report_data->prsnl[prsnl_seq ].provider_name.initials = trim (pn.name_initials ,3 ) ,
       report_data->prsnl[prsnl_seq ].provider_name.title = trim (pn.name_initials ,3 )
      ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3 )
      ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,report_data
       ->prsnl[prsnl_seq ].provider_name.name_last = trim (p.name_last ,3 ) ,report_data->prsnl[
       prsnl_seq ].provider_name.username = trim (p.username ,3 )
      ENDIF
     ENDIF
    DETAIL
     IF ((active_date_ind != 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      WHILE ((prsnl_seq > 0 ) )
       IF ((report_data->prsnl[prsnl_seq ].active_date BETWEEN pn.beg_effective_dt_tm AND pn
       .end_effective_dt_tm ) )
        IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].person_name_id = pn.person_name_id ,
         report_data->prsnl[prsnl_seq ].beg_effective_dt_tm = pn.beg_effective_dt_tm ,report_data->
         prsnl[prsnl_seq ].end_effective_dt_tm = pn.end_effective_dt_tm ,report_data->prsnl[
         prsnl_seq ].provider_name.name_full = trim (pn.name_full ,3 ) ,report_data->prsnl[prsnl_seq
         ].provider_name.name_first = trim (pn.name_first ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_middle = trim (pn.name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_last = trim (pn.name_last ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.username = trim (p.username ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name
         .initials = trim (pn.name_initials ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.title
         = trim (pn.name_initials ,3 )
        ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3
          ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn.name_last ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3 )
        ENDIF
        ,
        IF ((report_data->prsnl[prsnl_seq ].active_date = current_date_time ) ) report_data->prsnl[
         prsnl_seq ].active_date = 0
        ENDIF
       ENDIF
       ,prsnl_seq = locateval (idx ,(prsnl_seq + 1 ) ,prsnllistcnt ,p.person_id ,report_data->prsnl[
        idx ].id )
      ENDWHILE
     ENDIF
    FOOT REPORT
     stat = alterlist (report_data->prsnl ,prsnllistcnt )
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"OutputPersonnelList" ,1 ,0 ,report_data )
   IF ((active_date_ind != 0 ) )
    SELECT INTO "nl:"
     end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm ,
     person_name_id = report_data->prsnl[d.seq ].person_name_id ,
     prsnl_id = report_data->prsnl[d.seq ].id
     FROM (dummyt d WITH seq = size (report_data->prsnl ,5 ) )
     ORDER BY end_effective_dt_tm DESC ,
      person_name_id ,
      prsnl_id
     HEAD REPORT
      filteredcnt = 0 ,
      idx = size (report_data->prsnl ,5 ) ,
      stat = alterlist (report_data->prsnl ,(idx * 2 ) )
     HEAD end_effective_dt_tm
      donothing = 0
     HEAD prsnl_id
      idx = (idx + 1 ) ,filteredcnt = (filteredcnt + 1 ) ,report_data->prsnl[idx ].id = report_data->
      prsnl[d.seq ].id ,report_data->prsnl[idx ].person_name_id = report_data->prsnl[d.seq ].
      person_name_id ,
      IF ((report_data->prsnl[d.seq ].person_name_id > 0.0 ) ) report_data->prsnl[idx ].
       beg_effective_dt_tm = report_data->prsnl[d.seq ].beg_effective_dt_tm ,report_data->prsnl[idx ]
       .end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm
      ELSE report_data->prsnl[idx ].beg_effective_dt_tm = cnvtdatetime ("01-JAN-1900" ) ,report_data
       ->prsnl[idx ].end_effective_dt_tm = cnvtdatetime ("31-DEC-2100" )
      ENDIF
      ,report_data->prsnl[idx ].provider_name.name_full = report_data->prsnl[d.seq ].provider_name.
      name_full ,report_data->prsnl[idx ].provider_name.name_first = report_data->prsnl[d.seq ].
      provider_name.name_first ,report_data->prsnl[idx ].provider_name.name_middle = report_data->
      prsnl[d.seq ].provider_name.name_middle ,report_data->prsnl[idx ].provider_name.name_last =
      report_data->prsnl[d.seq ].provider_name.name_last ,report_data->prsnl[idx ].provider_name.
      username = report_data->prsnl[d.seq ].provider_name.username ,report_data->prsnl[idx ].
      provider_name.initials = report_data->prsnl[d.seq ].provider_name.initials ,report_data->prsnl[
      idx ].provider_name.title = report_data->prsnl[d.seq ].provider_name.title
     FOOT REPORT
      stat = alterlist (report_data->prsnl ,idx ) ,
      stat = alterlist (report_data->prsnl ,filteredcnt ,0 )
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"FilterPersonnelList" ,1 ,0 ,report_data )
   ENDIF
  ENDIF
  CALL log_message (build ("Exit OutputPersonnelList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 SUBROUTINE  addphonestolist (prsnl_id ,record_data )
  IF ((prsnl_id != 0 ) )
   IF ((((phonelistcnt = 0 ) ) OR ((locateval (phone_idx ,1 ,phonelistcnt ,prsnl_id ,record_data->
    phone_list[prsnl_idx ].person_id ) <= 0 ) )) )
    SET phonelistcnt = (phonelistcnt + 1 )
    IF ((phonelistcnt > size (record_data->phone_list ,5 ) ) )
     SET stat = alterlist (record_data->phone_list ,(phonelistcnt + 9 ) )
    ENDIF
    SET record_data->phone_list[phonelistcnt ].person_id = prsnl_id
    SET prsnl_cnt = (prsnl_cnt + 1 )
   ENDIF
  ENDIF
 END ;Subroutine
 
 SUBROUTINE  outputphonelist (report_data ,phone_types )
  CALL log_message ("In OutputPhoneList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE personcnt = i4 WITH protect ,constant (size (report_data->phone_list ,5 ) )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  DECLARE idx2 = i4 WITH protect ,noconstant (0 )
  DECLARE idx3 = i4 WITH protect ,noconstant (0 )
  DECLARE phonecnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnlidx = i4 WITH protect ,noconstant (0 )
  IF ((phonelistcnt > 0 ) )
   SELECT
    IF ((size (phone_types->phone_codes ,5 ) = 0 ) )
     phone_sorter = ph.phone_id
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.active_ind = 1 )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ELSE
     phone_sorter = locateval (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,
      phone_types->phone_codes[idx2 ].phone_cd )
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
     AND (ph.active_ind = 1 )
     AND expand (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,phone_types->
      phone_codes[idx2 ].phone_cd )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ENDIF
    INTO "nl:"
    HEAD ph.parent_entity_id
     phonecnt = 0 ,prsnlidx = locateval (idx3 ,1 ,personcnt ,ph.parent_entity_id ,report_data->
      phone_list[idx3 ].person_id )
    HEAD phone_sorter
     phonecnt = (phonecnt + 1 ) ,
     IF ((size (report_data->phone_list[prsnlidx ].phones ,5 ) < phonecnt ) ) stat = alterlist (
       report_data->phone_list[prsnlidx ].phones ,(phonecnt + 5 ) )
     ENDIF
     ,report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_id = ph.phone_id ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type_cd = ph.phone_type_cd ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type = uar_get_code_display (ph.phone_type_cd ) ,
     report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_num = formatphonenumber (ph
      .phone_num ,ph.phone_format_cd ,ph.extension )
    FOOT  ph.parent_entity_id
     stat = alterlist (report_data->phone_list[prsnlidx ].phones ,phonecnt )
    WITH nocounter ,expand = value (evaluate (floor (((personcnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
   ;end select
   SET stat = alterlist (report_data->phone_list ,prsnl_cnt )
   CALL error_and_zero_check_rec (curqual ,"PHONE" ,"OutputPhoneList" ,1 ,0 ,report_data )
  ENDIF
  CALL log_message (build ("Exit OutputPhoneList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  putstringtofile (svalue )
  CALL log_message ("In PutStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  IF ((validate (_memory_reply_string ) = 1 ) )
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest (
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line [* ]
       2 linedata = vc
     1 overflowpage [* ]
       2 ofr_qual [* ]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size (putrequest->document )
   EXECUTE eks_put_source WITH replace ("REQUEST" ,putrequest ) ,
   replace ("REPLY" ,putreply )
  ENDIF
  CALL log_message (build ("Exit PutStringToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  putunboundedstringtofile (trec )
  CALL log_message ("In PutUnboundedStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  DECLARE curstringlength = i4 WITH noconstant (textlen (trec->val ) )
  DECLARE newmaxvarlen = i4 WITH noconstant (0 )
  DECLARE origcurmaxvarlen = i4 WITH noconstant (0 )
  IF ((curstringlength > curmaxvarlen ) )
   SET origcurmaxvarlen = curmaxvarlen
   SET newmaxvarlen = (curstringlength + 10000 )
   SET modify maxvarlen newmaxvarlen
  ENDIF
  CALL putstringtofile (trec->val )
  IF ((newmaxvarlen > 0 ) )
   SET modify maxvarlen origcurmaxvarlen
  ENDIF
  CALL log_message (build ("Exit PutUnboundedStringToFile(), Elapsed time in seconds:" ,datetimediff
    (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 SUBROUTINE  putjsonrecordtofile (record_data )
  CALL log_message ("In PutJSONRecordToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  RECORD _tempjson (
    1 val = gvc
  )
  SET _tempjson->val = cnvtrectojson (record_data )
  CALL putunboundedstringtofile (_tempjson )
  CALL log_message (build ("Exit PutJSONRecordToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  getparametervalues (index ,value_rec )
  DECLARE par = vc WITH noconstant ("" ) ,protect
  DECLARE lnum = i4 WITH noconstant (0 ) ,protect
  DECLARE num = i4 WITH noconstant (1 ) ,protect
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE cnt2 = i4 WITH noconstant (0 ) ,protect
  DECLARE param_value = f8 WITH noconstant (0.0 ) ,protect
  DECLARE param_value_str = vc WITH noconstant ("" ) ,protect
  SET par = reflect (parameter (index ,0 ) )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (par )
  ENDIF
  IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
   SET param_value = parameter (index ,0 )
   IF ((param_value > 0 ) )
    SET value_rec->cnt = (value_rec->cnt + 1 )
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = param_value
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
   SET param_value_str = parameter (index ,0 )
   IF ((trim (param_value_str ,3 ) != "" ) )
    SET value_rec->cnt = (value_rec->cnt + 1 )
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "L" ) )
   SET lnum = 1
   WHILE ((lnum > 0 ) )
    SET par = reflect (parameter (index ,lnum ) )
    IF ((par != " " ) )
     IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
      SET param_value = parameter (index ,lnum )
      IF ((param_value > 0 ) )
       SET value_rec->cnt = (value_rec->cnt + 1 )
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = param_value
      ENDIF
      SET lnum = (lnum + 1 )
     ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
      SET param_value_str = parameter (index ,lnum )
      IF ((trim (param_value_str ,3 ) != "" ) )
       SET value_rec->cnt = (value_rec->cnt + 1 )
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
      ENDIF
      SET lnum = (lnum + 1 )
     ENDIF
    ELSE
     SET lnum = 0
    ENDIF
   ENDWHILE
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
 END ;Subroutine
 
 
 SUBROUTINE  getlookbackdatebytype (units ,flag )
  DECLARE looback_date = dq8 WITH noconstant (cnvtdatetime ("01-JAN-1800 00:00:00" ) )
  IF ((units != 0 ) )
   CASE (flag )
    OF 1 :
     SET looback_date = cnvtlookbehind (build (units ,",H" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 2 :
     SET looback_date = cnvtlookbehind (build (units ,",D" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 3 :
     SET looback_date = cnvtlookbehind (build (units ,",W" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 4 :
     SET looback_date = cnvtlookbehind (build (units ,",M" ) ,cnvtdatetime (curdate ,curtime3 ) )
    OF 5 :
     SET looback_date = cnvtlookbehind (build (units ,",Y" ) ,cnvtdatetime (curdate ,curtime3 ) )
   ENDCASE
  ENDIF
  RETURN (looback_date )
 END ;Subroutine
 SUBROUTINE  getcodevaluesfromcodeset (evt_set_rec ,evt_cd_rec )
  DECLARE csidx = i4 WITH noconstant (0 )
  SELECT DISTINCT INTO "nl:"
   FROM (v500_event_set_explode vese )
   WHERE expand (csidx ,1 ,evt_set_rec->cnt ,vese.event_set_cd ,evt_set_rec->qual[csidx ].value )
   DETAIL
    evt_cd_rec->cnt = (evt_cd_rec->cnt + 1 ) ,
    stat = alterlist (evt_cd_rec->qual ,evt_cd_rec->cnt ) ,
    evt_cd_rec->qual[evt_cd_rec->cnt ].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 
 
 SUBROUTINE  geteventsetnamesfromeventsetcds (evt_set_rec ,evt_set_name_rec )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (v500_event_set_code v )
   WHERE expand (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
   HEAD REPORT
    cnt = 0 ,
    evt_set_name_rec->cnt = evt_set_rec->cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_rec->cnt )
   DETAIL
    pos = locateval (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     cnt = (cnt + 1 ) ,evt_set_name_rec->qual[pos ].value = v.event_set_name ,pos = locateval (index
      ,(pos + 1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_name_rec->cnt = (evt_set_name_rec->cnt - 1 ) ,stat = alterlist (evt_set_name_rec->qual ,
      evt_set_name_rec->cnt ,(pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_name_rec->cnt ,"" ,
      evt_set_name_rec->qual[index ].value )
    ENDWHILE
    ,evt_set_name_rec->cnt = cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 
 
 SUBROUTINE  returnviewertype (eventclasscd ,eventid )
  CALL log_message ("In returnViewerType()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  IF ((eventclasscdpopulated = 0 ) )
   SET mpc_ap_type_cd = uar_get_code_by ("MEANING" ,53 ,"AP" )
   SET mpc_doc_type_cd = uar_get_code_by ("MEANING" ,53 ,"DOC" )
   SET mpc_mdoc_type_cd = uar_get_code_by ("MEANING" ,53 ,"MDOC" )
   SET mpc_rad_type_cd = uar_get_code_by ("MEANING" ,53 ,"RAD" )
   SET mpc_txt_type_cd = uar_get_code_by ("MEANING" ,53 ,"TXT" )
   SET mpc_num_type_cd = uar_get_code_by ("MEANING" ,53 ,"NUM" )
   SET mpc_immun_type_cd = uar_get_code_by ("MEANING" ,53 ,"IMMUN" )
   SET mpc_med_type_cd = uar_get_code_by ("MEANING" ,53 ,"MED" )
   SET mpc_date_type_cd = uar_get_code_by ("MEANING" ,53 ,"DATE" )
   SET mpc_done_type_cd = uar_get_code_by ("MEANING" ,53 ,"DONE" )
   SET mpc_mbo_type_cd = uar_get_code_by ("MEANING" ,53 ,"MBO" )
   SET mpc_procedure_type_cd = uar_get_code_by ("MEANING" ,53 ,"PROCEDURE" )
   SET mpc_grp_type_cd = uar_get_code_by ("MEANING" ,53 ,"GRP" )
   SET mpc_hlatyping_type_cd = uar_get_code_by ("MEANING" ,53 ,"HLATYPING" )
   SET eventclasscdpopulated = 1
  ENDIF
  DECLARE sviewerflag = vc WITH protect ,noconstant ("" )
  CASE (eventclasscd )
   OF mpc_ap_type_cd :
    SET sviewerflag = "AP"
   OF mpc_doc_type_cd :
   OF mpc_mdoc_type_cd :
   OF mpc_rad_type_cd :
    SET sviewerflag = "DOC"
   OF mpc_txt_type_cd :
   OF mpc_num_type_cd :
   OF mpc_immun_type_cd :
   OF mpc_med_type_cd :
   OF mpc_date_type_cd :
   OF mpc_done_type_cd :
    SET sviewerflag = "EVENT"
   OF mpc_mbo_type_cd :
    SET sviewerflag = "MICRO"
   OF mpc_procedure_type_cd :
    SET sviewerflag = "PROC"
   OF mpc_grp_type_cd :
    SET sviewerflag = "GRP"
   OF mpc_hlatyping_type_cd :
    SET sviewerflag = "HLA"
   ELSE
    SET sviewerflag = "STANDARD"
  ENDCASE
  IF ((eventclasscd = mpc_mdoc_type_cd ) )
   SELECT INTO "nl:"
    c2.*
    FROM (clinical_event c1 ),
     (clinical_event c2 )
    PLAN (c1
     WHERE (c1.event_id = eventid ) )
     JOIN (c2
     WHERE (c1.parent_event_id = c2.event_id )
     AND (c2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100" ) ) )
    HEAD c2.event_id
     IF ((c2.event_class_cd = mpc_ap_type_cd ) ) sviewerflag = "AP"
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL log_message (build ("Exit returnViewerType(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
  RETURN (sviewerflag )
 END ;Subroutine
 
 SUBROUTINE  cnvtisodttmtodq8 (isodttmstr )
  DECLARE converteddq8 = dq8 WITH protect ,noconstant (0 )
  SET converteddq8 = cnvtdatetimeutc2 (substring (1 ,10 ,isodttmstr ) ,"YYYY-MM-DD" ,substring (12 ,
    8 ,isodttmstr ) ,"HH:MM:SS" ,4 ,curtimezonedef )
  RETURN (converteddq8 )
 END ;Subroutine
 
 SUBROUTINE  cnvtdq8toisodttm (dq8dttm )
  DECLARE convertedisodttm = vc WITH protect ,noconstant ("" )
  IF ((dq8dttm > 0.0 ) )
   SET convertedisodttm = build (replace (datetimezoneformat (cnvtdatetime (dq8dttm ) ,
      datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
  ELSE
   SET convertedisodttm = nullterm (convertedisodttm )
  ENDIF
  RETURN (convertedisodttm )
 END ;Subroutine
 
 
 SUBROUTINE  getorgsecurityflag (null )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = "SEC_ORG_RELTN" )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 
 SUBROUTINE  getcomporgsecurityflag (dminfo_name )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = dminfo_name )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 
 SUBROUTINE  populateauthorizedorganizations (personid ,value_rec )
  DECLARE organization_cnt = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (prsnl_org_reltn por )
   WHERE (por.person_id = personid )
   AND (por.active_ind = 1 )
   AND (por.beg_effective_dt_tm BETWEEN cnvtdatetime (lower_bound_date ) AND cnvtdatetime (curdate ,
    curtime3 ) )
   AND (por.end_effective_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
    upper_bound_date ) )
   ORDER BY por.organization_id
   HEAD REPORT
    organization_cnt = 0
   DETAIL
    organization_cnt = (organization_cnt + 1 ) ,
    IF ((mod (organization_cnt ,20 ) = 1 ) ) stat = alterlist (value_rec->organizations ,(
      organization_cnt + 19 ) )
    ENDIF
    ,value_rec->organizations[organization_cnt ].organizationid = por.organization_id
   FOOT REPORT
    value_rec->cnt = organization_cnt ,
    stat = alterlist (value_rec->organizations ,organization_cnt )
   WITH nocounter
  ;end select
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
 END ;Subroutine
 
 
 SUBROUTINE  getuserlogicaldomain (id )
  DECLARE returnid = f8 WITH protect ,noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (prsnl p )
   WHERE (p.person_id = id )
   DETAIL
    returnid = p.logical_domain_id
   WITH nocounter
  ;end select
  RETURN (returnid )
 END ;Subroutine
 
 SUBROUTINE  getpersonneloverride (ppr_cd )
  DECLARE override_ind = i2 WITH protect ,noconstant (0 )
  IF ((ppr_cd <= 0.0 ) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (code_value_extension cve )
   WHERE (cve.code_value = ppr_cd )
   AND (cve.code_set = 331 )
   AND (((cve.field_value = "1" ) ) OR ((cve.field_value = "2" ) ))
   AND (cve.field_name = "Override" )
   DETAIL
    override_ind = 1
   WITH nocounter
  ;end select
  RETURN (override_ind )
 END ;Subroutine
 
 
 SUBROUTINE  cclimpersonation (null )
  CALL log_message ("In cclImpersonation()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  EXECUTE secrtl
  DECLARE uar_secsetcontext ((hctx = i4 ) ) = i2 WITH image_axp = "secrtl" ,image_aix =
  "libsec.a(libsec.o)" ,uar = "SecSetContext" ,persist
  DECLARE seccntxt = i4 WITH public
  DECLARE namelen = i4 WITH public
  DECLARE domainnamelen = i4 WITH public
  SET namelen = (uar_secgetclientusernamelen () + 1 )
  SET domainnamelen = (uar_secgetclientdomainnamelen () + 2 )
  SET stat = memalloc (name ,1 ,build ("C" ,namelen ) )
  SET stat = memalloc (domainname ,1 ,build ("C" ,domainnamelen ) )
  SET stat = uar_secgetclientusername (name ,namelen )
  SET stat = uar_secgetclientdomainname (domainname ,domainnamelen )
  SET setcntxt = uar_secimpersonate (nullterm (name ) ,nullterm (domainname ) )
  CALL log_message (build ("Exit cclImpersonation(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 SUBROUTINE  geteventsetdisplaysfromeventsetcds (evt_set_rec ,evt_set_disp_rec )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (v500_event_set_code v )
   WHERE expand (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
   HEAD REPORT
    cnt = 0 ,
    evt_set_disp_rec->cnt = evt_set_rec->cnt ,
    stat = alterlist (evt_set_disp_rec->qual ,evt_set_rec->cnt )
   DETAIL
    pos = locateval (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     cnt = (cnt + 1 ) ,evt_set_disp_rec->qual[pos ].value = v.event_set_cd_disp ,pos = locateval (
      index ,(pos + 1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_disp_rec->cnt ,"" ,evt_set_disp_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_disp_rec->cnt = (evt_set_disp_rec->cnt - 1 ) ,stat = alterlist (evt_set_disp_rec->qual ,
      evt_set_disp_rec->cnt ,(pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_disp_rec->cnt ,"" ,
      evt_set_disp_rec->qual[index ].value )
    ENDWHILE
    ,evt_set_disp_rec->cnt = cnt ,
    stat = alterlist (evt_set_disp_rec->qual ,evt_set_disp_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 
 
 SUBROUTINE  decodestringparameter (description )
  DECLARE decodeddescription = vc WITH private
  SET decodeddescription = replace (description ,"%3B" ,";" ,0 )
  SET decodeddescription = replace (decodeddescription ,"%25" ,"%" ,0 )
  RETURN (decodeddescription )
 END ;Subroutine
 
 
 SUBROUTINE  urlencode (json )
  DECLARE encodedjson = vc WITH private
  SET encodedjson = replace (json ,char (91 ) ,"%5B" ,0 )
  SET encodedjson = replace (encodedjson ,char (123 ) ,"%7B" ,0 )
  SET encodedjson = replace (encodedjson ,char (58 ) ,"%3A" ,0 )
  SET encodedjson = replace (encodedjson ,char (125 ) ,"%7D" ,0 )
  SET encodedjson = replace (encodedjson ,char (93 ) ,"%5D" ,0 )
  SET encodedjson = replace (encodedjson ,char (44 ) ,"%2C" ,0 )
  SET encodedjson = replace (encodedjson ,char (34 ) ,"%22" ,0 )
  RETURN (encodedjson )
 END ;Subroutine
 
 
 SUBROUTINE  istaskgranted (task_number )
  CALL log_message ("In IsTaskGranted" ,log_level_debug )
  DECLARE fntime = f8 WITH private ,noconstant (curtime3 )
  DECLARE task_granted = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (task_access ta ),
    (application_group ag )
   PLAN (ta
    WHERE (ta.task_number = task_number )
    AND (ta.app_group_cd > 0.0 ) )
    JOIN (ag
    WHERE (ag.position_cd = reqinfo->position_cd )
    AND (ag.app_group_cd = ta.app_group_cd )
    AND (ag.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ag.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   DETAIL
    task_granted = 1
   WITH nocounter ,maxqual (ta ,1 )
  ;end select
  CALL log_message (build ("Exit IsTaskGranted - " ,build2 (cnvtint ((curtime3 - fntime ) ) ) ,
    "0 ms" ) ,log_level_debug )
  RETURN (task_granted )
 END ;Subroutine
 FREE RECORD printdata
 RECORD printdata (
   1 person_printing_name = vc
   1 print_group_flag = i2
   1 display_columns
     2 location = i2
     2 patient = i2
     2 consultant = i2
     2 lengthofstay = i2
     2 notes = i2
   1 patients [* ]
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_type = vc
     2 location_data
       3 facility = vc
       3 unit = vc
       3 room = vc
       3 bed = vc
     2 patient_data
       3 name_full = vc
       3 age = vc
       3 mrn = vc
       3 fin = vc
     2 sex = vc
     2 primary_contact = vc
     2 consultant
       3 adm_phy = vc
       3 att_phy = vc
       3 consul_phy = vc
       3 cover_phy = vc
     2 length_of_stay = i4
     2 notes = vc
     2 admit_date = vc
     2 total_hours = i4
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE json_blob_in = vc WITH protect ,noconstant ("" )
 DECLARE run_cust_ccl_prg = i4 WITH protect ,noconstant (0 )
 DECLARE inerror_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) )
 DECLARE notdone_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"NOT DONE" ) )
 DECLARE complete_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,79 ,"COMPLETE" ) )
 DECLARE mrn_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,319 ,"MRN" ) )
 DECLARE fin_cd = f8 WITH protect ,constant (uar_get_code_by ("DISPLAYKEY" ,319 ,"FINNBR" ) )
 DECLARE date_str = vc WITH protect ,constant ("MM/DD/YYYY;;Q" )
 DECLARE column_consultant_str = vc WITH protect ,constant ("MP_VB_COL_CONSULTANT" )
 DECLARE column_patient_str = vc WITH protect ,constant ("MP_VB_COL_PATIENT" )
 DECLARE column_location_str = vc WITH protect ,constant ("MP_VB_COL_LOCATION" )
 DECLARE column_lengthofstay_str = vc WITH protect ,constant ("MP_VB_COL_LENGTH_OF_STAY" )
 DECLARE column_notes_str = vc WITH protect ,constant ("MP_VB_COL_NOTES" )
 DECLARE getprintdata (null ) = null
 DECLARE getusername (null ) = null
 DECLARE getfin (nul ) = null
 DECLARE getattphy (null ) = null
 DECLARE getconphy (null ) = null
 DECLARE getcovphy (null ) = null
 DECLARE getaddphy (null ) = null
 DECLARE getprimarycontact (null ) = null
 CALL log_message (concat ("Begin script: " ,log_program_name ) ,log_level_debug )
 SET printdata->status_data.status = "F"
 IF ((validate (print_options ) = 0 ) )
  IF ((validate (request->blob_in ,"" ) != "" ) )
   SET json_blob_in = trim (request->blob_in ,3 )
  ELSEIF ((size (trim ( $JSONDATA ,3 ) ) > 0 ) )
   SET json_blob_in = trim ( $JSONDATA ,3 )
  ELSE
   CALL populate_subeventstatus_rec ("PopulateRequest" ,"F" ,"MISSING_JSON_INPUT" ,
    "No JSON data provided to script." ,printdata )
   GO TO exit_script
  ENDIF
  SET stat = cnvtjsontorec (json_blob_in )
  IF ((error_message (1 ) = 1 ) )
   CALL populate_subeventstatus_rec ("PopulateRequest" ,"F" ,"CNVTJSONTOREC_ERROR" ,
    "Error encountered during cnvtjsontorec()." ,printdata )
   GO TO exit_script
  ENDIF
 ELSE
  SET run_cust_ccl_prg = 1
 ENDIF
 IF ((validate (print_options ,"-999" ) = "-999" ) )
  CALL populate_subeventstatus_rec ("ValidateRequest" ,"F" ,"MISSING_PRINT_OPTIONS_RECORD" ,
   "Supplied JSON record not named 'PRINT_OPTIONS'." ,printdata )
  GO TO exit_script
 ELSE
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (print_options )
  ENDIF
 ENDIF
 IF ((print_options->print_style = "simplified" ) )
  SET printdata->print_group_flag = 0
 ELSE
  SET printdata->print_group_flag = 1
 ENDIF
 FOR (index = 1 TO size (print_options->column_list.columns ,5 ) )
  CASE (print_options->column_list.columns[index ].reportmean )
   OF column_consultant_str :
    SET printdata->display_columns.consultant = print_options->column_list.columns[index ].active
   OF column_patient_str :
    SET printdata->display_columns.patient = print_options->column_list.columns[index ].active
   OF column_location_str :
    SET printdata->display_columns.location = print_options->column_list.columns[index ].active
   OF column_lengthofstay_str :
    SET printdata->display_columns.lengthofstay = print_options->column_list.columns[index ].active
   OF column_notes_str :
    SET printdata->display_columns.notes = print_options->column_list.columns[index ].active
  ENDCASE
 ENDFOR
 CALL getusername (null )
 CALL getprintdata (null )
 CALL getfin (null )
 CALL getprimarycontact (null )
 CALL getattphy (null )
 CALL getconphy (null )
 CALL getcovphy (null )
 CALL getaddphy (null )
 IF ((run_cust_ccl_prg >= 0 ) )
  CALL createprinttemplatelayout (null )
 ENDIF
 SUBROUTINE  getusername (null )
  CALL log_message ("In getUserName()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  SELECT INTO "nl:"
   FROM (person p )
   WHERE (p.person_id = print_options->user_context.user_id )
   DETAIL
    printdata->person_printing_name = p.name_full_formatted
   WITH nocounter
  ;end select
  CALL log_message (build ("Exit getUserName(), Elapsed time in seconds:" ,((curtime3 -
    begin_date_time ) / 100 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  getprimarycontact (null )
  DECLARE primary_contact = f8 WITH protect ,constant (uar_get_code_by ("DISPLAYKEY" ,72 ,
    "PRIMARYCONTACT" ) )
  DECLARE ecnt = i4 WITH protect ,noconstant (0 )
  DECLARE eidx = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
 
   for (m_idx = 1 to size(print_options->qual,5))
     execute MP_GET_CARE_TEAM_ASSIGN "MINE", printdata->patients[m_idx].person_id,printdata->patients[m_idx].encntr_id
                                          ,0.0, 0.0, 1, 0, 0, 0, 0.0
 
       if(patientCareTeamReply->status_data->status = "S")
     set printdata->patients[m_idx].primary_contact = patientCareTeamReply->primary_contact->provider_name   ;p.name_full_formatted
        endif
   endfor
 
 END ;Subroutine
 
 
 
 SUBROUTINE  getprintdata (null )
  CALL log_message ("In getPrintData()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE eidx = i4 WITH protect ,noconstant (0 )
  DECLARE ecnt = i4 WITH protect ,noconstant (0 )
  DECLARE dob = dq8 WITH protect ,noconstant (0 )
  DECLARE totalhours = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   dob = p.birth_dt_tm
   ,facility = uar_get_code_display (e.loc_facility_cd )
   ,unit = uar_get_code_display (e.loc_nurse_unit_cd )
   ,room = uar_get_code_display (e.loc_room_cd )
   ,bed = uar_get_code_display (e.loc_bed_cd )
   FROM (encounter e ),
    (person p ),
    (encntr_alias ea ),
    (pct_ipass pi ),
    (encntr_domain ed )
   PLAN (e
    WHERE expand (eidx ,1 ,size (print_options->qual ,5 ) ,e.encntr_id ,print_options->qual[eidx ].
     encntr_id )
    AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (e.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = e.person_id )
    AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (p.active_ind = 1 ) )
    JOIN (ea
    WHERE (ea.encntr_id = e.encntr_id )
    AND (ea.encntr_alias_type_cd = mrn_cd )
    AND (ea.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ea.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ea.active_ind = 1 ) )
    JOIN (pi
    WHERE (pi.encntr_id = outerjoin (e.encntr_id ) )
    AND (pi.begin_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (pi.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime ) ) )
    AND (pi.active_ind = outerjoin (1 ) ) )
    JOIN (ed
    WHERE (ed.person_id = outerjoin (p.person_id ) )
    AND (ed.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (ed.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (ed.active_ind = outerjoin (1 ) ) )
   ;003 ORDER BY room, bed, p.person_id
   ORDER BY unit, room, bed, p.person_id ;003
   HEAD p.person_id
    ecnt = (ecnt + 1 ) ,
    IF ((size (printdata->patients ,5 ) < ecnt ) ) stat = alterlist (printdata->patients ,(ecnt + 5
      ) )
    ENDIF
    ,printdata->patients[ecnt ].person_id = p.person_id ,printdata->patients[ecnt ].encntr_id = e
    .encntr_id ,printdata->patients[ecnt ].encntr_type = uar_get_code_display (e.encntr_type_cd ) ,
    printdata->patients[ecnt ].admit_date = format (e.reg_dt_tm ,date_str ) ,
    IF ((e.disch_dt_tm < current_date_time )
    AND (e.disch_dt_tm > 0 ) ) printdata->patients[ecnt ].total_hours = datetimediff (e.disch_dt_tm ,
      e.reg_dt_tm ,3 )
    ELSE printdata->patients[ecnt ].total_hours = datetimediff (current_date_time ,e.reg_dt_tm ,3 )
    ENDIF
    ,totalhours = datetimediff (current_date_time ,e.reg_dt_tm ,3 ) ,printdata->patients[ecnt ].
    length_of_stay = (totalhours / 24 ) ,printdata->patients[ecnt ].patient_data.name_full = p
    .name_full_formatted ,printdata->patients[ecnt ].patient_data.age = substring (1 ,3 ,cnvtage (p
      .birth_dt_tm ) ) ,printdata->patients[ecnt ].sex = substring (1 ,1 ,uar_get_code_display (p
      .sex_cd ) ) ,printdata->patients[ecnt ].patient_data.mrn = cnvtalias (ea.alias ,ea
     .alias_pool_cd ) ,printdata->patients[ecnt ].location_data.facility = uar_get_code_display (e
     .loc_facility_cd ) ,printdata->patients[ecnt ].location_data.unit = uar_get_code_display (e
     .loc_nurse_unit_cd ) ,printdata->patients[ecnt ].location_data.room = uar_get_code_display (e
     .loc_room_cd ) ,printdata->patients[ecnt ].location_data.bed = uar_get_code_display (e
     .loc_bed_cd )
   FOOT REPORT
    stat = alterlist (printdata->patients ,ecnt )
   WITH nocounter
  ;end select
  CALL log_message (build ("Exit getPrintData(), Elapsed time in seconds:" ,((curtime3 -
    begin_date_time ) / 100 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  getfin (null )
  CALL log_message ("In getFIN()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE fidx = i4 WITH protect ,noconstant (0 )
  DECLARE fcnt = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (encounter e ),
    (person p ),
    (encntr_alias ea )
   PLAN (e
    WHERE expand (fidx ,1 ,size (print_options->qual ,5 ) ,e.encntr_id ,print_options->qual[fidx ].
     encntr_id )
    AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (e.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = e.person_id )
    AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (p.active_ind = 1 ) )
    JOIN (ea
    WHERE (ea.encntr_id = e.encntr_id )
    AND (ea.encntr_alias_type_cd = fin_cd )
    AND (ea.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ea.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ea.active_ind = 1 ) )
   ORDER BY p.person_id
   HEAD p.person_id
    m_idx = locateval (gm_idx ,1 ,size (printdata->patients ,5 ) ,e.encntr_id ,printdata->patients[
     gm_idx ].encntr_id ) ,printdata->patients[m_idx ].patient_data.fin = cnvtalias (ea.alias ,ea
     .alias_pool_cd )
  ;end select
 END ;Subroutine
 SUBROUTINE  getattphy (null )
  DECLARE att_phy = f8 WITH public ,constant (uar_get_code_by ("DISPLAY_KEY" ,333 ,
    "ATTENDINGPHYSICIAN" ) )
  DECLARE atnt = i4 WITH protect ,noconstant (0 )
  DECLARE eidx1 = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (prsnl p ),
    (encntr_prsnl_reltn e )
   PLAN (e
    WHERE expand (eidx1 ,1 ,size (print_options->qual ,5 ) ,e.encntr_id ,print_options->qual[eidx1 ].
     encntr_id )
    AND (e.encntr_prsnl_r_cd = att_phy )
    AND (e.active_ind = 1 )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) ) )
    JOIN (p
    WHERE (p.person_id = e.prsnl_person_id ) )
   ORDER BY p.updt_dt_tm DESC
   DETAIL
    m_idx = locateval (gm_idx ,1 ,size (printdata->patients ,5 ) ,e.encntr_id ,printdata->patients[
     gm_idx ].encntr_id ) ,
    printdata->patients[m_idx ].consultant.att_phy = p.name_full_formatted
  ;end select
 END ;Subroutine
 
 SUBROUTINE  getconphy (null )
  DECLARE con_phy = f8 WITH public ,constant (uar_get_code_by ("DISPLAY_KEY" ,333 ,
    "CONSULTINGPHYSICIAN" ) )
  DECLARE cpnt = i4 WITH protect ,noconstant (0 )
  DECLARE eidx2 = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
from
    dcp_shift_assignment dsa
    , pct_care_team pct
    , prsnl p
    , encounter e
plan dsa where expand (eidx2 ,1 ,size (print_options->qual ,5 ) ,dsa.encntr_id ,print_options->qual[eidx2 ].
     encntr_id )
    and dsa.active_ind = 1
    and dsa.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
    and dsa.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
join pct where pct.pct_care_team_id = dsa.pct_care_team_id
    and pct.active_ind = 1
    and pct.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
    and pct.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
join p where p.person_id = pct.prsnl_id
    and p.active_ind = 1
    and p.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
    and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
join e where e.encntr_id = dsa.encntr_id
    and e.disch_dt_tm is  null
DETAIL
    m_idx = locateval (gm_idx ,1 ,size (printdata->patients ,5 ) ,dsa.encntr_id ,printdata->patients[
     gm_idx ].encntr_id ) ,
   if (m_idx > 0)
    printdata->patients[m_idx ].consultant.consul_phy = replace(concat(printdata->patients[m_idx ].consultant.consul_phy,
                                                    char(13), char(10),p.name_full_formatted),
                                                    printdata->patients[m_idx ].primary_contact, "")
  endif
  ;end select
 
 with nocounter
 
 END ;Subroutine
 
 
 SUBROUTINE  getcovphy (null )
  DECLARE cov_phy = f8 WITH public ,constant (uar_get_code_by ("DISPLAY_KEY" ,333 ,
    "COVERINGPHYSICIAN" ) )
  DECLARE cnt = i4 WITH protect ,noconstant (0 )
  DECLARE eidx3 = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (prsnl p ),
    (encntr_prsnl_reltn e )
   PLAN (e
    WHERE expand (eidx3 ,1 ,size (print_options->qual ,5 ) ,e.encntr_id ,print_options->qual[eidx3 ].
     encntr_id )
    AND (e.encntr_prsnl_r_cd = cov_phy )
    AND (e.active_ind = 1 )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) ) )
    JOIN (p
    WHERE (p.person_id = e.prsnl_person_id ) )
   ORDER BY p.updt_dt_tm DESC
   DETAIL
    m_idx = locateval (gm_idx ,1 ,size (printdata->patients ,5 ) ,e.encntr_id ,printdata->patients[
     gm_idx ].encntr_id ) ,
    printdata->patients[m_idx ].consultant.cover_phy = p.name_full_formatted
  ;end select
 END ;Subroutine
 SUBROUTINE  getaddphy (null )
  DECLARE add_phy = f8 WITH public ,constant (uar_get_code_by ("DISPLAY_KEY" ,333 ,
    "ADMITTINGPHYSICIAN" ) )
  DECLARE adnt = i4 WITH protect ,noconstant (0 )
  DECLARE eidx4 = i4 WITH protect ,noconstant (0 )
  DECLARE m_idx = i4 WITH protect ,noconstant (0 )
  DECLARE gm_idx = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (prsnl p ),
    (encntr_prsnl_reltn e )
   PLAN (e
    WHERE expand (eidx4 ,1 ,size (print_options->qual ,5 ) ,e.encntr_id ,print_options->qual[eidx4 ].
     encntr_id )
    AND (e.encntr_prsnl_r_cd = add_phy )
    AND (e.active_ind = 1 )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) ) )
    JOIN (p
    WHERE (p.person_id = e.prsnl_person_id ) )
   ORDER BY p.updt_dt_tm DESC
   DETAIL
    m_idx = locateval (gm_idx ,1 ,size (printdata->patients ,5 ) ,e.encntr_id ,printdata->patients[
     gm_idx ].encntr_id ) ,
    printdata->patients[m_idx ].consultant.adm_phy = p.name_full_formatted
  ;end select
 END ;Subroutine
 SUBROUTINE  createprinttemplatelayout (null )
  DECLARE numberofpatients = i4 WITH protect ,noconstant (size (printdata->patients ,5 ) )
  DECLARE sfinalhtml = vc WITH noconstant ("" )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE patientshtml = vc WITH noconstant ("" )
  DECLARE diagnosisindex = i4 WITH protect ,noconstant (0 )
  DECLARE diagnosisdata = vc WITH noconstant ("" )
  DECLARE medsindex = i4 WITH protect ,noconstant (0 )
  DECLARE medsdata = vc WITH noconstant ("" )
  DECLARE summarydata = vc WITH noconstant ("" )
  DECLARE formatteddate = vc WITH protect ,noconstant ("" )
  DECLARE current_date_time = dq8 WITH protect ,constant (cnvtdatetime (curdate ,curtime3 ) )
  SET formatteddate = format (current_date_time ,cclfmt->shortdatetimenosec )
  SET patientshtml = build2 (patientshtml ,'<div class="table-container">' ,'<table class="w100">' )
  SET patientshtml = build2 (patientshtml ,"<thead>" ,"<tr>" ,'<td class="w5">' ,
   '<div class="cell-header">Location</div>' ,"</td>" ,'<td class="w15">' ,
   '<div class="cell-header">Name</div>' ,"</td>" ,'<td class="w15">' ,
   '<div class="cell-header">MRN</div>' ,"</td>" ,'<td class="w25">' ,
   '<div class="cell-header">Primary Contact</div>' ,"</td>" ,'<td class="w15">' ,
   '<div class="cell-header">Consulting Contacts</div>' ,"</td>" ,"</thead>" )
  FOR (index = 1 TO numberofpatients )
   SET patientshtml = build2 (patientshtml ,"<tbody>" ,"<tr>" ,"<td>" ,'<div class="cell-content">' ,
    printdata->patients[index ].location_data.room ," / " ,printdata->
    patients[index ].location_data.bed ,"</div>" ,"</td>" ,"<td>" ,'<div class="cell-content">' ,
    printdata->patients[index ].patient_data.name_full,"</div>" ,
    "</td>" ,"<td>" ,'<div class="cell-content">MRN: ' ,printdata->patients[index ].patient_data.mrn ,"</div>" ,
    "</td>" )
 
 
   SET patientshtml = build2 (patientshtml ,"<td>" )
   IF ((printdata->patients[index ].consultant.adm_phy != printdata->patients[index ].consultant.
   att_phy ) )
    SET patientshtml = build2 (patientshtml ,
     '<div class="cell-content">' ,printdata->patients[index ].
     primary_contact ,
     "</div>" )
   ELSE
    SET patientshtml = build2 (patientshtml ,
     '<div class="cell-content">' ,printdata->patients[index ].
     primary_contact ,"</div>"
     )
   ENDIF
   SET patientshtml = build2 (patientshtml ,"</td>" )
 
   SET patientshtml = build2 (patientshtml ,"<td>" )
    SET patientshtml = build2 (patientshtml ,
     '<div class="consults-content">' ,printdata->patients[index ].consultant.consul_phy ,
     "</div>" )
   SET patientshtml = build2 (patientshtml ,"</td>" )
   SET patientshtml = build2 (patientshtml ,"<tr>" ,'<td colspan="14" class="dash1"/>',"</tr>" )
  ENDFOR
  SET patientshtml = build2 (patientshtml ,"</tbody>" ,"</table>" ,"</div>" )
  SET sfinalhtml = build2 ("<!doctype html>" ,"<html>" ,"<head>" ,'<meta charset="utf-8">' ,
   '<meta name="description">' ,'<meta http-equiv="X-UA-Compatible" content="IE=Edge">' ,
   "<title>MPage Print</title>" ,'<style type="text/css">' ,
   "body {font-family: calibri; font-size: 12px; position:relative;}" ,
   "table {border-collapse:collapse; table-layout:fixed; width:1000px;}" ,
   "td {vertical-align: top; padding: 2px; word-wrap: break-word;}" ,".w100 {width: 1000px;}" ,
   ".w35 {width: 350px;}" ,".w25 {width: 250px;}" ,".w15 {width: 150px;}" ,".w10 {width: 100px;}" ,
   ".w5 {width: 50px;}" ,".dash1 {border-top: 1px dashed #8b8b8b;}" ,
   ".table-container {padding-top: 1em; padding-left:50px; margin: 0 auto -142px;}" ,
   ".table-container:5th-child(2(5)+1) {break-before: always;}" ,
   ".cell-content {font-family: calibri; font-size: 12px;}" ,
   ".consults-content{font-family: calibri; font-size: 9px;}" ,
   ".cell-header {font-weight: bold;  font-size: 11px;}" ,
   ".print-header {display: flex; padding-left:50px;}" ,
   ".print-header div {display: flex; flex: 1 1;}" ,
   ".print-title {justify-content: center; font-style: bold; font-size: 26px; padding-top:30px;}" ,
   ".printed-date {justify-content: flex-end; padding-top:30px;}" ,
   ".printed-by-user {justify-content: flex-start; padding-top:30px;}" ,"</style>" ,"</head>" ,
   "<body>" ,'<div id = "print-container">' ,'<div class="print-header">' ,
   '<div class="printed-by-user">' ,"<span>" ,"Printed By: " ,"</span>" ,"<span>" ,printdata->
   person_printing_name ,"</span>" ,"</div>" ,'<div class="print-title">' ,"<span>" ,
   "Provider Group List" ,"</span>" ,"</div>" ,'<div class="printed-date">' ,"<span>" ,formatteddate ,
   "</span>" ,"</div>" ,"</div>" ,patientshtml ,"</div>" ,"</body>" ,"</html>" )
  CALL putstringtofile (sfinalhtml )
  IF ((error_message (1 ) = 1 ) )
   CALL populate_subeventstatus_rec ("PopulateRequest" ,"F" ,"CREATING_PRINT_TEMPLATE_HTML" ,
    "Error encountered during createPrintTemplateLayout()." ,printdata )
   GO TO exit_script
  ENDIF
  GO TO exit_program
 END ;Subroutine
#exit_script
 IF ((size (printdata->patients ,5 ) > 0 ) )
  SET printdata->status_data.status = "S"
 ENDIF
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (printdata )
 ENDIF
 CALL putjsonrecordtofile (printdata )
#exit_program
 CALL log_message (concat ("Exiting script: " ,log_program_name ) ,log_level_debug )
end
go
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_lhc_t_asp_worklist.prg
  Object name:        cov_lhc_t_asp_worklist
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   			  Chad Cummings			Initial Release
******************************************************************************/

DROP PROGRAM cov_lhc_t_asp_worklist :dba GO
CREATE PROGRAM cov_lhc_t_asp_worklist :dba

set modify maxvarlen 268435456 ;increases max file size

set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 filename_a    = vc
	1 filename_a_s	= vc
	1 filename_b    = vc
	1 filename_c = vc
	1 filename_d = vc
	1 filename_e = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)


call addEmailLog("chad.cummings@covhlth.com")
call addEmailLog("mtanner@covhlth.com")
call addEmailLog("jbernste@CovHlth.com")

set t_rec->filename_a = concat(trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_a_s = concat("cclscratch:",t_rec->filename_a)

call writeLog(build2(cnvtrectojson(t_rec)))

 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim (eks_common->cur_module_name )
 SET eksmodule = trim (ttemp )
 FREE SET ttemp
 SET ttemp = trim (eks_common->event_name )
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF (NOT ((validate (eksdata->tqual ,"Y" ) = "Y" )
 AND (validate (eksdata->tqual ,"Z" ) = "Z" ) ) )
  FREE SET templatetype
  IF ((conclude > 0 ) )
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt + evokecnt )
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo (concat ("****  " ,format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,
    "hh:mm:ss.cc;3;m" ) ,"     Module:  " ,trim (eksmodule ) ,"  ****" ) ,1 ,0 )
 IF ((validate (tname ,"Y" ) = "Y" ) AND (validate (tname ,"Z" ) = "Z" ) )
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,")           Event:  " ,trim (eksevent ) ,"         Request number:  " ,cnvtstring (
      eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning an Evoke Template" ,"           Event:  " ,trim (eksevent
      ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ELSE
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,"):  " ,trim (tname ) ,"       Event:  " ,trim (eksevent ) ,"         Request number:  " ,
     cnvtstring (eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning Evoke Template:  " ,trim (tname ) ,"       Event:  " ,
     trim (eksevent ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ENDIF
 SET ininc = "eks_sub_record.inc"
 RECORD ekssub (
   1 orig = vc
   1 parse_ind = i2
   1 num_dec_places = i2
   1 mod = vc
   1 status_flag = i2
   1 msg = vc
   1 format_flag = i4
   1 time_zone = i4
   1 skip_curdate_ind = i2
   1 curdate_fnd_ind = i2
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
 IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name) ) > " " ) )) )
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
 FREE RECORD new_alert
 RECORD new_alert (
   1 trigger_rule_name = vc
   1 link_person_id = f8
   1 link_encntr_id = f8
   1 add_alert_ind = i2
   1 category_cd = f8
   1 severity_cd = f8
   1 med_order_id = f8
   1 med_catalog_cd = f8
   1 existing_med_order_id = f8
   1 existing_med_catalog_cd = f8
   1 other_order_id = f8
   1 other_catalog_cd = f8
   1 existing_other_order_id = f8
   1 existing_other_catalog_cd = f8
   1 micro [* ]
     2 order_id = f8
     2 event_id = f8
     2 event [* ]
       3 micro_data = vc
       3 micro_seq_nbr = i4
   1 result_event_id = f8
   1 result_catalog_cd = f8
   1 existing_result_event_id = f8
   1 existing_result_catalog_cd = f8
   1 medresult_event_id = f8
   1 medresult_catalog_cd = f8
   1 medresult_order_id = f8
   1 existing_medresult_event_id = f8
   1 existing_medresult_catalog_cd = f8
   1 existing_medresult_order_id = f8
 )
 FREE RECORD existing_alerts
 RECORD existing_alerts (
   1 alerts [* ]
     2 factor_txt = vc
     2 factor_dt_tm = dq8
     2 factor_status_cd = f8
     2 factor_status_end_dt_tm = dq8
     2 category_cd = f8
     2 severity_cd = f8
     2 catalog_cds [* ]
       3 catalog_cd = f8
     2 micro [* ]
       3 order_id = f8
       3 event_id = f8
       3 micro_seq [* ]
         4 micro_seq_nbr = i4
     2 details [* ]
       3 detail_type_cd = f8
       3 parent_entity_id = f8
       3 detail_txt = vc
 )
 FREE RECORD temp_orders
 RECORD temp_orders (
   1 qual [* ]
     2 order_id = f8
 )
 FREE RECORD temp_events
 RECORD temp_events (
   1 qual [* ]
     2 clin_event_id = f8
     2 event_name = vc
 )
 FREE RECORD temp_micro
 RECORD temp_micro (
   1 qual [* ]
     2 micro_event_id = f8
     2 micro_data = vc
     2 micro_seq_nbr = i4
 )
 FREE RECORD logic_templates
 RECORD logic_templates (
   1 qual [* ]
     2 link_val = i4
     2 alias_name = vc
     2 template_true_ind = i4
 )
 FREE RECORD pop_request
 RECORD pop_request (
   1 person_id = f8
   1 encntr_id = f8
   1 worklist_mean = vc
 )
 FREE RECORD pop_reply
 RECORD pop_reply (
   1 lh_cnt_wl_pop_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD factor_request
 RECORD factor_request (
   1 lh_cnt_wl_pop_id = f8
   1 factor_type_cd = f8
   1 factor_txt = vc
   1 factor_value = i4
   1 factor_dt_tm = dq8
   1 cloud_ident = vc
 )
 FREE RECORD factor_reply
 RECORD factor_reply (
   1 lh_cnt_wl_factor_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD fac_status_req
 RECORD fac_status_req (
   1 statuses [* ]
     2 lh_cnt_wl_factor_id = f8
     2 factor_status_cd = f8
     2 factor_status_end_dt_tm = dq8
 )
 FREE RECORD fac_status_reply
 RECORD fac_status_reply (
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD fac_detail_req
 RECORD fac_detail_req (
   1 details [* ]
     2 lh_cnt_wl_factor_id = f8
     2 detail_type_cd = f8
     2 detail_txt = vc
     2 key_ind = i2
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 child_details [* ]
       3 lh_cnt_wl_factor_id = f8
       3 detail_type_cd = f8
       3 detail_txt = vc
       3 key_ind = i2
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 )
 FREE RECORD fac_detail_reply
 RECORD fac_detail_reply (
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE findlogictemplatealias (dummy ) = null WITH private
 DECLARE getalertdetails ((link_val = i4 ) ,(alias = vc ) ) = i4 WITH private
 DECLARE fillnewalertdetails (dummy ) = null WITH private
 DECLARE checkforduplicatealert (dummy ) = null WITH private
 DECLARE addpatientpop (dummy ) = null WITH private
 DECLARE addpatientfactor (dummy ) = null WITH private
 DECLARE addpatientfactorstatus (dummy ) = null WITH private
 DECLARE addpatientfactordetail (dummy ) = null WITH private
 DECLARE loadfactordetaillist (child_idx = i4,factor_id = f8,detail_type_cd = f8,
 	detail_txt = vc,key_ind = i2,entity_name = vc,entity_id = f8) = null WITH protect
 DECLARE writeexitmessage ((msg = vc ) ) = null WITH protect
 DECLARE checkdistinctcatalogcd ((alert_cntr = i4 ) ,(catalog_cd = f8 ) ) = i4 WITH protect
 DECLARE beg_dt_tm = dq8 WITH protect ,constant (cnvtdatetime (curdate ,curtime3 ) )
 DECLARE asp_worklist_mean = vc WITH protect ,constant ("MP_ASP_WORKLIST" )
 DECLARE wl_dtl_type_severity_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "SEVERITY" ) )
 DECLARE wl_dtl_type_category_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "CATEGORY" ) )
 DECLARE wl_dtl_type_medorder_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "MED_ORDER" ) )
 DECLARE wl_dtl_type_othorder_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "OTHER_ORDER" ) )
 DECLARE wl_dtl_type_micorder_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "MICRO_ORDER" ) )
 DECLARE wl_dtl_type_catalog_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "CATALOG_CD" ) )
 DECLARE wl_dtl_type_mic_evnt_id = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "MICRO_EVENT" ) )
 DECLARE wl_dtl_type_result_id = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "RESULT" ) )
 DECLARE wl_dtl_type_med_reslt_id = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003482 ,
   "MED_RESULT" ) )
 DECLARE alert_not_reviewed_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003478 ,
   "NOTREV" ) )
 DECLARE alert_completed_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003478 ,"COMP"
   ) )
 DECLARE alert_completedint_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003478 ,
   "COMPINT" ) )
 DECLARE alert_dismissed_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003478 ,"DISM"
   ) )
 DECLARE alert_completednotdup_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4003478 ,
   "COMPNOTDUP" ) )
 DECLARE mbo_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,53 ,"MBO" ) )
 DECLARE doc_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,53 ,"DOC" ) )
 DECLARE ce_deleted_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,48 ,"DELETED" ) )
 DECLARE pharm_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6000 ,"PHARMACY" ) )
 DECLARE lab_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6000 ,"GENERAL LAB" ) )
 DECLARE lnk_val_micro = vc WITH protect ,constant ("MICRO" )
 DECLARE lnk_val_med = vc WITH protect ,constant ("MEDORDER" )
 DECLARE lnk_val_medresult = vc WITH protect ,constant ("MEDRESULTS" )
 DECLARE lnk_val_other_order = vc WITH protect ,constant ("OTHERORDER" )
 DECLARE lnk_val_result = vc WITH protect ,constant ("RESULTS" )
 DECLARE result = vc WITH protect ,constant ("RESULT" )
 DECLARE med_result = vc WITH protect ,constant ("MEDRESULT" )
 DECLARE add_alert_false = i2 WITH protect ,constant (0 )
 DECLARE add_alert_true = i2 WITH protect ,constant (1 )
 DECLARE key_ind = i2 WITH protect ,constant (1 )
 DECLARE dup_ind = i2 WITH protect ,constant (1 )
 DECLARE dup_catalog_ind = i2 WITH protect ,constant (1 )
 DECLARE target_object = vc WITH protect ,constant ("lhc_t_asp_worklist" )
 DECLARE template_true = i2 WITH protect ,constant (1 )
 DECLARE errmsg = vc WITH noconstant ("" )
 DECLARE errorcode = i4 WITH noconstant (0 )
 DECLARE lh_cnt_wl_pop_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE lh_cnt_wl_factor_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE sub_start_time = dq8 WITH protect ,noconstant (0.0 )
 DECLARE execute_start_time = dq8 WITH protect ,noconstant (0.0 )
 DECLARE debug_cntr = i4 WITH protect ,noconstant (0 )
 DECLARE trigger_orderid = f8 WITH protect ,noconstant (0.0 )
 DECLARE trigger_accessionid = f8 WITH protect ,noconstant (0.0 )
 DECLARE order_flag = i4 WITH protect ,noconstant (0 )
 DECLARE clinical_event_flag = i4 WITH protect ,noconstant (0 )
 DECLARE micro_flag = i4 WITH protect ,noconstant (0 )
 DECLARE index = i4 WITH protect ,noconstant (0 )
 DECLARE d_stat = f8 WITH protect ,noconstant (0.0 )
 DECLARE l_pos = i4 WITH protect ,noconstant (0 )
 DECLARE log_message = vc WITH protect ,noconstant ("" )
 DECLARE colon_pos = i4 WITH protect ,noconstant (0 )
 DECLARE template_flag = i4 WITH protect ,noconstant (0 )
 DECLARE debug_ind = i4 WITH protect ,noconstant (0 )
 DECLARE micro_cntr = i4 WITH protect ,noconstant (0 )
 DECLARE micro_seq_cntr = i4 WITH protect ,noconstant (0 )
 CALL log_message (concat ("Begin script: " ,target_object ," at " ,format (beg_dt_tm ,";;Q" ) ) ,
  log_level_debug )
 IF (validate (severity ,"Z" ) = "Z" AND validate (severity ,"Y" ) = "Y")
  CALL writeexitmessage ("Invalid parameter SEVERITY!" )
  SET retval = - (1 )
  GO TO exit_script
 ELSE
  SET new_alert->severity_cd = uar_get_code_by ("DISPLAYKEY" ,4003476 ,severity )
 ENDIF
 IF ((validate (category ,"Z" ) = "Z" )
 AND (validate (category ,"Y" ) = "Y" ) )
  CALL writeexitmessage ("Invalid parameter CATEGORY!" )
  SET retval = - (1 )
  GO TO exit_script
 ELSE
  SET new_alert->category_cd = uar_get_code_by ("DISPLAYKEY" ,4003477 ,category )
 ENDIF
 SET log_message = concat ("CATEGORY-'" ,category ,"'," )
 SET log_message = concat (trim (log_message ) ,concat ("SEVERITY-'" ,severity ,"'," ) )
 CALL log_message (log_message ,log_level_debug )
 IF (validate (event ) AND validate (eks_common ) )
  SET new_alert->trigger_rule_name = eks_common->cur_module_name
  SET new_alert->link_person_id = event->qual[eks_common->event_repeat_index ].person_id
  SET new_alert->link_encntr_id = event->qual[eks_common->event_repeat_index ].encntr_id
  SET trigger_accessionid = event->qual[eks_common->event_repeat_index ].accession_id
  SET trigger_orderid = event->qual[eks_common->event_repeat_index ].order_id
 ELSE
  CALL writeexitmessage ("Event record structure did not exist. Trigger variables cannot be set." )
  SET retval = - (1 )
  GO TO exit_script
 ENDIF
 
 SELECT INTO "nl:"
  FROM (dm_info di )
  PLAN (di
   WHERE (di.info_domain = "LIGHTHOUSE CONTENT" )
     AND (di.info_name = "SCRIPT_LOGGING" )
     AND (di.info_char = "T" ) )
  DETAIL
   debug_ind = 1
  WITH nocounter
 ;end select
 
 IF (debug_ind = 1)
  CALL echorecord (event )
  CALL echorecord (eks_common )
  CALL echorecord (eksdata )
 ENDIF
 
 CALL findlogictemplatealias (0 )
 
 FOR (index = 1 TO value (size (logic_templates->qual ,5 )))
  SET template_flag = getalertdetails (logic_templates->qual[index ].link_val ,logic_templates->qual[index ].alias_name)
  SET logic_templates->qual[index ].template_true_ind = template_flag
 ENDFOR
 
 IF (debug_ind = 1) CALL echorecord (logic_templates ) ENDIF
 
 CALL fillnewalertdetails (0 )
 CALL checkforduplicatealert (0 )
 
 IF (new_alert->add_alert_ind = add_alert_true)
  CALL addpatientpop (0 )
  CALL addpatientfactor (0 )
  CALL addpatientfactorstatus (0 )
  CALL addpatientfactordetail (0 )
  CALL writeexitmessage ("Alert data added successfully" )
 ENDIF
 
 IF ((debug_ind = 1 ) ) CALL echorecord (new_alert ) ENDIF
 
 SET retval = 100
 
 SUBROUTINE  findlogictemplatealias (dummy )
  CALL log_message ("Begin - Subroutine FindLogicTemplateAlias" ,log_level_debug )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  DECLARE temp_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE alias = vc WITH private ,noconstant ("" )
  DECLARE eks_size = i4 WITH private ,noconstant (size (eksdata->tqual[logic_inx ].qual ,5 ) )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET d_stat = alterlist (logic_templates->qual ,eks_size )
  FOR (idx = 1 TO eks_size )
   SET alias = piece (eksdata->tqual[logic_inx ].qual[idx ].template_alias ,"_" ,1 ,"" )
   CASE (cnvtupper (alias ) )
    OF lnk_val_med :
     SET temp_cnt = (temp_cnt + 1 )
     SET logic_templates->qual[temp_cnt ].link_val = idx
     SET logic_templates->qual[temp_cnt ].alias_name = lnk_val_med
    OF lnk_val_micro :
     SET temp_cnt = (temp_cnt + 1 )
     SET logic_templates->qual[temp_cnt ].link_val = idx
     SET logic_templates->qual[temp_cnt ].alias_name = lnk_val_micro
    OF lnk_val_other_order :
     SET temp_cnt = (temp_cnt + 1 )
     SET logic_templates->qual[temp_cnt ].link_val = idx
     SET logic_templates->qual[temp_cnt ].alias_name = lnk_val_other_order
    OF lnk_val_medresult :
     SET temp_cnt = (temp_cnt + 1 )
     SET logic_templates->qual[temp_cnt ].link_val = idx
     SET logic_templates->qual[temp_cnt ].alias_name = lnk_val_medresult
    OF lnk_val_result :
     SET temp_cnt = (temp_cnt + 1 )
     SET logic_templates->qual[temp_cnt ].link_val = idx
     SET logic_templates->qual[temp_cnt ].alias_name = lnk_val_result
   ENDCASE
  ENDFOR
  SET d_stat = alterlist (logic_templates->qual ,temp_cnt )
  CALL log_message (build ("End - Subroutine FindLogicTemplateAlias. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  getalertdetails (link_template ,alias )
  CALL log_message ("Begin - Subroutine GetAlertDetails" ,log_level_debug )
  DECLARE order_size = i4 WITH private ,noconstant (0 )
  DECLARE event_size = i4 WITH private ,noconstant (0 )
  DECLARE micro_size = i4 WITH private ,noconstant (0 )
  DECLARE misc_idx = i4 WITH private ,noconstant (0 )
  DECLARE misc_val = f8 WITH private ,noconstant (0 )
  DECLARE data_size = i4 WITH private ,noconstant (0 )
  DECLARE logic_template_flag = i4 WITH private ,noconstant (0 )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET order_flag = 0
  SET clinical_event_flag = 0
  SET micro_flag = 0
  IF (link_template > 0 )
   IF (templatetype = "LOGIC" AND link_template > size (eksdata->tqual[logic_inx ].qual ,5))
    CALL writeexitmessage ("Invalid link value for the logic section!" )
    SET retval = - (1 )
    GO TO exit_script
   ELSE
    IF (eksdata->tqual[logic_inx ].qual[link_template ].cnt > 0 )
     SET data_size = size (eksdata->tqual[logic_inx ].qual[link_template ].data ,5 )
     FOR (misc_idx = 1 TO data_size )
      IF (findstring ("<" ,eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc ))
       IF (cnvtupper (trim (eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc )) = "<ORDER_ID>" )
        SET order_flag = 1
       ELSEIF ((cnvtupper (trim (eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc)) = "<CLINICAL_EVENT_ID>" ))
        SET clinical_event_flag = 1
       ELSEIF ((cnvtupper (trim (eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc)) = "<SUSCEPTIBILITY>" ))
        SET micro_flag = 1
       ENDIF
      ELSE
       IF (isnumeric (piece (eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc ,":" ,1 ,"" )))
        SET misc_val = cnvtreal (piece (eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc ,":" ,1 ,"" ) )
        IF (misc_val > 0 AND (order_flag = 1 ))
         IF (cnvtupper (alias ) = lnk_val_med )
          SET order_size = (size (temp_orders->qual ,5 ) + 1 )
          SET d_stat = alterlist (temp_orders->qual ,order_size )
          SET temp_orders->qual[order_size ].order_id = misc_val
          SET logic_template_flag = template_true
         ELSEIF (cnvtupper (alias ) = lnk_val_other_order )
          SET order_size = (size (temp_orders->qual ,5 ) + 1 )
          SET d_stat = alterlist (temp_orders->qual ,order_size )
          SET temp_orders->qual[order_size ].order_id = misc_val
          SET logic_template_flag = template_true
         ENDIF
        ELSEIF ((misc_val > 0 ) AND (clinical_event_flag = 1 ) )
         IF ((cnvtupper (alias ) = lnk_val_result ) )
          SET event_size = (size (temp_events->qual ,5 ) + 1 )
          SET d_stat = alterlist (temp_events->qual ,event_size )
          SET temp_events->qual[event_size ].clin_event_id = misc_val
          SET temp_events->qual[event_size ].event_name = result
          SET logic_template_flag = template_true
         ELSEIF ((cnvtupper (alias ) = lnk_val_medresult ) )
          SET event_size = (size (temp_events->qual ,5 ) + 1 )
          SET d_stat = alterlist (temp_events->qual ,event_size )
          SET temp_events->qual[event_size ].clin_event_id = misc_val
          SET temp_events->qual[event_size ].event_name = med_result
          SET logic_template_flag = template_true
         ENDIF
        ELSEIF ((misc_val > 0 ) AND (micro_flag = 1 ) )
         SET micro_size = (size (temp_micro->qual ,5 ) + 1 )
         SET d_stat = alterlist (temp_micro->qual ,micro_size )
         SET temp_micro->qual[micro_size ].micro_data = eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc
         SET temp_micro->qual[micro_size ].micro_event_id = misc_val
         SET temp_micro->qual[micro_size ].micro_seq_nbr =
         	 cnvtint (piece (eksdata->tqual[logic_inx ].qual[link_template ].data[misc_idx ].misc ,":" ,2 ,"" ) )
         SET logic_template_flag = template_true
        ENDIF
       ELSE
        IF ((eksdata->tqual[logic_inx ].qual[link_template ].clinical_event_id > 0 ) )
         IF ((cnvtupper (alias ) = lnk_val_result ) )
          SET event_size = (size (temp_events->qual ,5 ) + 1 )
          SET d_stat = alterlist (temp_events->qual ,event_size )
          SET temp_events->qual[event_size ].clin_event_id = eksdata->tqual[logic_inx ].qual[
          link_template ].clinical_event_id
          SET temp_events->qual[event_size ].event_name = result
          SET logic_template_flag = template_true
         ELSEIF ((cnvtupper (alias ) = lnk_val_medresult ) )
          SET event_size = (size (temp_events->qual ,5 ) + 1 )
          SET d_stat = alterlist (temp_events->qual ,event_size )
          SET temp_events->qual[event_size ].clin_event_id = eksdata->tqual[logic_inx ].qual[
          link_template ].clinical_event_id
          SET temp_events->qual[event_size ].event_name = med_result
          SET logic_template_flag = template_true
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
  ELSE
   CALL writeexitmessage ("Link is not defined!" )
   SET retval = - (1 )
   GO TO exit_script
  ENDIF
  CALL log_message (build ("End - Subroutine GetAlertDetails. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
  RETURN (logic_template_flag )
 END ;Subroutine
 
 
 
 
 SUBROUTINE  fillnewalertdetails (dummy )
  CALL log_message ("Begin - Subroutine FillNewAlertDetails" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE temp_micro_size = i4 WITH protect ,noconstant (size (temp_micro->qual ,5 ) )
  DECLARE temp_event_size = i4 WITH protect ,noconstant (size (temp_events->qual ,5 ) )
  DECLARE temp_ord_size = i4 WITH protect ,noconstant (size (temp_orders->qual ,5 ) )
  DECLARE micro_order_cntr = i4 WITH protect ,noconstant (0 )
  DECLARE temp_idx = i4 WITH protect ,noconstant (0 )
  IF (temp_ord_size > 0)
   SET errorcode = error (errmsg ,1 )
   SELECT INTO "nl:"
    FROM (orders o )
    PLAN (o WHERE expand (index ,1 ,temp_ord_size ,o.order_id ,temp_orders->qual[index ].order_id ) )
    ORDER BY o.order_id DESC ,o.catalog_cd
    HEAD o.catalog_cd
     IF (o.catalog_type_cd = pharm_cd AND new_alert->med_order_id = 0)
	  new_alert->med_order_id = o.order_id ,new_alert->med_catalog_cd = o.catalog_cd
     ELSEIF (o.catalog_type_cd = pharm_cd AND new_alert->existing_med_order_id = 0) 
	  new_alert->existing_med_order_id = o.order_id ,new_alert->existing_med_catalog_cd = o.catalog_cd
     ELSEIF (NOT (o.catalog_type_cd IN (lab_cd ,pharm_cd) AND new_alert->other_order_id = 0) )
	  new_alert->other_order_id = o.order_id ,new_alert->other_catalog_cd = o.catalog_cd
     ELSEIF (NOT (o.catalog_type_cd IN (lab_cd ,pharm_cd)) AND new_alert->existing_other_order_id = 0) 
	  new_alert->existing_other_order_id = o.order_id,new_alert->existing_other_catalog_cd = o.catalog_cd
     ENDIF
    WITH nocounter
   ;end select
   SET errorcode = error (errmsg ,0 )
   IF (errorcode != 0)
    CALL log_message (concat ("Subroutine FillNewAlertDetails failed in Orders Data: " ,errmsg ),log_level_debug )
    CALL writeexitmessage ("FillNewAlertDetails subroutine failed in Orders Data" )
    SET retval = - (1 )
    GO TO exit_script
   ENDIF
  ENDIF
  
  
  IF (temp_event_size > 0 )
   SET errorcode = error (errmsg ,1 )
   SELECT INTO "nl:"
    FROM (clinical_event ce )
    PLAN (ce
     WHERE expand (index ,1 ,temp_event_size ,ce.clinical_event_id ,temp_events->qual[index ].
      clin_event_id )
     AND (ce.record_status_cd != ce_deleted_cd ) )
    ORDER BY ce.clinical_event_id DESC ,
     ce.catalog_cd
    HEAD ce.catalog_cd
     l_pos = locateval (index ,1 ,temp_event_size ,ce.clinical_event_id ,temp_events->qual[index ].
      clin_event_id ,result ,temp_events->qual[index ].event_name ) ,
     IF ((l_pos > 0 ) )
      IF ((new_alert->result_event_id = 0 ) ) new_alert->result_event_id = ce.event_id ,new_alert->
       result_catalog_cd = ce.catalog_cd
      ELSEIF ((new_alert->existing_result_event_id = 0 ) ) new_alert->existing_result_event_id = ce
       .event_id ,new_alert->existing_result_catalog_cd = ce.catalog_cd
      ENDIF
     ELSE l_pos = locateval (index ,1 ,temp_event_size ,ce.clinical_event_id ,temp_events->qual[
       index ].clin_event_id ,med_result ,temp_events->qual[index ].event_name ) ,
      IF ((l_pos > 0 ) )
       IF ((new_alert->medresult_event_id = 0 ) ) new_alert->medresult_event_id = ce.event_id ,
        new_alert->medresult_catalog_cd = ce.catalog_cd ,new_alert->medresult_order_id = ce.order_id
       ELSEIF ((new_alert->existing_medresult_event_id = 0 ) ) new_alert->existing_medresult_event_id
         = ce.event_id ,new_alert->existing_medresult_catalog_cd = ce.catalog_cd ,new_alert->
        existing_medresult_order_id = ce.order_id
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET errorcode = error (errmsg ,0 )
   IF ((errorcode != 0 ) )
    CALL log_message (concat ("Subroutine FillNewAlertDetails failed in Admin Data: " ,errmsg ) ,
     log_level_debug )
    CALL writeexitmessage ("FillNewAlertDetails subroutine failed in Admin Data" )
    SET retval = - (1 )
    GO TO exit_script
   ENDIF
  ENDIF
  
  IF (temp_micro_size > 0)
   SET errorcode = error (errmsg ,1 )
   SELECT INTO "nl:"
    FROM (clinical_event ce )
    PLAN (ce
     WHERE expand (index ,1 ,temp_micro_size ,ce.event_id ,temp_micro->qual[index ].micro_event_id )
     AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime ) )
     AND (ce.event_class_cd IN (mbo_cd ,
     doc_cd ) )
     AND (ce.record_status_cd != ce_deleted_cd ) )
    ORDER BY ce.order_id
    HEAD ce.order_id
     micro_order_cntr = (micro_order_cntr + 1 ) ,d_stat = alterlist (new_alert->micro ,
      micro_order_cntr ) ,new_alert->micro[micro_order_cntr ].order_id = ce.order_id ,new_alert->
     micro[micro_order_cntr ].event_id = ce.event_id
    WITH nocounter
   ;end select
   
   SET errorcode = error (errmsg ,0 )
   IF ((errorcode != 0 ) )
    CALL log_message (concat ("Subroutine FillNewAlertDetails failed in Micro Data: " ,errmsg ) ,
     log_level_debug )
    CALL writeexitmessage ("FillNewAlertDetails subroutine failed in Micro Data" )
    SET retval = - (1 )
    GO TO exit_script
   ENDIF
  ENDIF
  FOR (index = 1 TO micro_order_cntr )
   SET micro_seq_cntr = 0
   FOR (temp_idx = 1 TO temp_micro_size )
    IF ((new_alert->micro[index ].event_id = temp_micro->qual[temp_idx ].micro_event_id ) )
     SET micro_seq_cntr = (micro_seq_cntr + 1 )
     IF ((mod (micro_seq_cntr ,10 ) = 1 ) )
      SET d_stat = alterlist (new_alert->micro[index ].event ,(micro_seq_cntr + 9 ) )
     ENDIF
     SET new_alert->micro[index ].event[micro_seq_cntr ].micro_data = temp_micro->qual[temp_idx ].
     micro_data
     SET new_alert->micro[index ].event[micro_seq_cntr ].micro_seq_nbr = temp_micro->qual[temp_idx ].
     micro_seq_nbr
    ENDIF
   ENDFOR
   SET d_stat = alterlist (new_alert->micro[index ].event ,micro_seq_cntr )
  ENDFOR
  CALL log_message (build ("End - Subroutine FillNewAlertDetails. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 SUBROUTINE  checkforduplicatealert (dummy )
  CALL log_message ("Begin - Subroutine CheckForDuplicateAlert" ,log_level_debug )
  DECLARE catalog_cd_cntr = i4 WITH private ,noconstant (0 )
  DECLARE catalog_size = i4 WITH private ,noconstant (0 )
  DECLARE micro_size = i4 WITH private ,noconstant (0 )
  DECLARE micro_seq_size = i4 WITH private ,noconstant (0 )
  DECLARE alert_list_size = i4 WITH private ,noconstant (0 )
  DECLARE alert_cntr = i4 WITH protect ,noconstant (0 )
  DECLARE detail_cntr = i4 WITH private ,noconstant (0 )
  DECLARE duplicate_alert_ind = i4 WITH private ,noconstant (0 )
  DECLARE template_logic_cntr = i4 WITH private ,noconstant (0 )
  DECLARE existing_micro_cntr = i4 WITH private ,noconstant (0 )
  DECLARE existing_micro_seq_cntr = i4 WITH private ,noconstant (0 )
  DECLARE new_micro_cntr = i4 WITH private ,noconstant (0 )
  DECLARE new_micro_seq_pos = i4 WITH private ,noconstant (0 )
  DECLARE dup_template_cntr = i4 WITH private ,noconstant (0 )
  DECLARE dup_micro_flag = i4 WITH private ,noconstant (0 )
  DECLARE dup_order_flag = i4 WITH private ,noconstant (0 )
  DECLARE dup_result_flag = i4 WITH private ,noconstant (0 )
  DECLARE qualified_templates_cntr = i4 WITH private ,noconstant (0 )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET errorcode = error (errmsg ,1 )
  SELECT INTO "nl:"
   FROM (lh_cnt_wl wl ),
    (lh_cnt_wl_pop pop ),
    (lh_cnt_wl_factor f ),
    (lh_cnt_wl_factor_detail fd ),
    (lh_cnt_wl_factor_status fs )
   PLAN (wl
    WHERE (wl.worklist_mean = asp_worklist_mean ) )
    JOIN (pop
    WHERE (pop.lh_cnt_wl_id = wl.lh_cnt_wl_id )
    AND (pop.encntr_id = new_alert->link_encntr_id )
    AND (pop.active_ind = 1 )
    AND (pop.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (pop.end_effective_dt_tm = null ) )
    JOIN (f
    WHERE (f.lh_cnt_wl_pop_id = pop.lh_cnt_wl_pop_id )
    AND (f.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (f.end_effective_dt_tm = null ) )
    JOIN (fs
    WHERE (fs.lh_cnt_wl_factor_id = f.lh_cnt_wl_factor_id ) )
    JOIN (fd
    WHERE (fd.lh_cnt_wl_factor_id = f.lh_cnt_wl_factor_id )
    AND (fd.key_ind = key_ind ) )
   ORDER BY f.lh_cnt_wl_factor_id 
           ,fd.lh_cnt_wl_factor_detail_id

   HEAD f.lh_cnt_wl_factor_id
    alert_cntr = (alert_cntr + 1 ) 
    ,IF (mod (alert_cntr ,10 ) = 1) d_stat = alterlist (existing_alerts->alerts ,(alert_cntr + 9)) ENDIF
    ,detail_cntr = 0 
	,catalog_cd_cntr = 0 
	,micro_size = 0 
	,micro_seq_size = 0 
	,existing_alerts->alerts[alert_cntr ].factor_txt = f.factor_txt 
	,existing_alerts->alerts[alert_cntr ].factor_dt_tm = f.beg_effective_dt_tm 
	,existing_alerts->alerts[alert_cntr ].factor_status_cd = fs.factor_status_cd 
	,existing_alerts->alerts[alert_cntr ].factor_status_end_dt_tm = fs.factor_status_end_dt_tm
   DETAIL
    detail_cntr = (detail_cntr + 1 ) 
	,IF (mod (detail_cntr ,10 ) = 1) d_stat = alterlist (existing_alerts->alerts[alert_cntr ].details ,(detail_cntr + 9)) ENDIF
    ,existing_alerts->alerts[alert_cntr ].details[detail_cntr ].detail_txt = fd.detail_txt 
	,existing_alerts->alerts[alert_cntr ].details[detail_cntr ].detail_type_cd = fd.detail_type_cd 
	,existing_alerts->alerts[alert_cntr ].details[detail_cntr ].parent_entity_id = fd.parent_entity_id 
	,IF (fd.detail_type_cd = wl_dtl_type_category_cd) existing_alerts->alerts[alert_cntr ].category_cd = fd.parent_entity_id
     ELSEIF (fd.detail_type_cd = wl_dtl_type_catalog_cd )
      IF (checkdistinctcatalogcd (alert_cntr ,fd.parent_entity_id ) = 0) catalog_cd_cntr = (catalog_cd_cntr + 1 ) 
	  ,IF (mod (catalog_cd_cntr ,10 ) = 1) d_stat = alterlist (existing_alerts->alerts[alert_cntr].catalog_cds 
	  ,(catalog_cd_cntr + 9 )) ENDIF
      ,existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd = fd.parent_entity_id
      ENDIF
     ELSEIF (fd.detail_type_cd = wl_dtl_type_micorder_cd) micro_size = (size (existing_alerts->alerts[alert_cntr ].micro ,5) + 1) 
	    ,d_stat = alterlist (existing_alerts->alerts[alert_cntr ].micro ,micro_size ) 
		,existing_alerts->alerts[alert_cntr ].micro[micro_size ].order_id = fd.parent_entity_id 
		,existing_alerts->alerts[alert_cntr ].micro[micro_size ].event_id = cnvtreal (fd.detail_txt )
     ELSEIF (fd.detail_type_cd = wl_dtl_type_mic_evnt_id) l_pos 
     = locateval (index ,1 ,size (existing_alerts->alerts[alert_cntr ].micro ,5 ) 
	   ,fd.parent_entity_id ,existing_alerts->alerts[alert_cntr ].micro[index ].event_id ) 
	   ,IF ((l_pos > 0 ) ) micro_seq_size = (size (existing_alerts->alerts[alert_cntr ].micro[l_pos ].micro_seq ,5 ) + 1 ) 
	     ,d_stat = alterlist (existing_alerts->alerts[alert_cntr ].micro[l_pos ].micro_seq ,micro_seq_size ) 
		 ,existing_alerts->alerts[alert_cntr ].micro[l_pos ].micro_seq[micro_seq_size ].micro_seq_nbr 
		 = cnvtint (piece (fd.detail_txt ,":" ,2 ,"" ))
         ENDIF
     ENDIF
   FOOT  f.lh_cnt_wl_factor_id
    d_stat = alterlist (existing_alerts->alerts[alert_cntr ].details ,detail_cntr ) ,
    d_stat = alterlist (existing_alerts->alerts[alert_cntr ].catalog_cds ,catalog_cd_cntr )
   WITH nocounter
  ;end select
  
  SET d_stat = alterlist (existing_alerts->alerts ,alert_cntr )
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine CheckForDuplicateAlert failed: " ,errmsg ) ,log_level_debug
    )
   CALL writeexitmessage ("CheckForDuplicateAlert subroutine failed" )
   SET retval = - (1 )
   GO TO exit_script
  ENDIF
  SET alert_list_size = size (existing_alerts->alerts ,5 )
  FOR (alert_cntr = 1 TO alert_list_size )
   SET qualified_templates_cntr = 0
   SET dup_template_cntr = 0
   IF ((duplicate_alert_ind = 0 ) )
    IF (existing_alerts->alerts[alert_cntr].category_cd = new_alert->category_cd)
     SET catalog_size = size (existing_alerts->alerts[alert_cntr ].catalog_cds ,5 )
     SET micro_size = size (existing_alerts->alerts[alert_cntr ].micro ,5 )
     FOR (template_logic_cntr = 1 TO value (size (logic_templates->qual ,5 ) ) )
      SET dup_micro_flag = 0
      SET dup_order_flag = 0
      SET dup_result_flag = 0
      IF (logic_templates->qual[template_logic_cntr ].template_true_ind = template_true)
       SET qualified_templates_cntr = (qualified_templates_cntr + 1 )
       CASE (logic_templates->qual[template_logic_cntr ].alias_name )
        OF lnk_val_med :
         FOR (catalog_cd_cntr = 1 TO catalog_size )
          IF ((existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd = new_alert->med_catalog_cd ) )
           SET dup_order_flag = dup_ind
           SET catalog_cd_cntr = (catalog_size + 1 )
          ENDIF
         ENDFOR
         ,
         IF ((new_alert->existing_med_catalog_cd > 0 ) AND (dup_order_flag = dup_ind ) )
          IF ((locateval (catalog_cd_cntr ,1 ,catalog_size ,new_alert->existing_med_catalog_cd ,
           existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd ) > 0 ) )
           SET dup_order_flag = dup_ind
          ELSE
           SET dup_order_flag = 0
          ENDIF
         ENDIF
         ,
         IF (dup_order_flag = dup_ind )
          SET dup_template_cntr = (dup_template_cntr + 1 )
         ENDIF
        OF lnk_val_other_order :
         FOR (catalog_cd_cntr = 1 TO catalog_size )
          IF (existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd = new_alert->other_catalog_cd )
           SET dup_order_flag = dup_ind
           SET catalog_cd_cntr = (catalog_size + 1 )
          ENDIF
         ENDFOR
         ,
         IF (new_alert->existing_other_catalog_cd > 0 AND dup_order_flag = dup_ind)
          IF ((locateval (catalog_cd_cntr ,1 ,catalog_size ,new_alert->existing_other_catalog_cd ,
           existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd ) > 0 ) )
           SET dup_order_flag = dup_ind
          ELSE
           SET dup_order_flag = 0
          ENDIF
         ENDIF
         ,
         IF (dup_order_flag = dup_ind )
          SET dup_template_cntr = (dup_template_cntr + 1 )
         ENDIF
        OF lnk_val_medresult :
         FOR (catalog_cd_cntr = 1 TO catalog_size )
          IF (existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd = new_alert->medresult_catalog_cd )
           SET dup_result_flag = dup_ind
           SET catalog_cd_cntr = (catalog_size + 1 )
          ENDIF
         ENDFOR
         ,
         IF (new_alert->existing_medresult_catalog_cd > 0 AND dup_result_flag = dup_ind )
          IF ((locateval (catalog_cd_cntr ,1 ,catalog_size ,new_alert->existing_medresult_catalog_cd
           ,existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd ) > 0 ) )
           SET dup_result_flag = dup_ind
          ELSE
           SET dup_result_flag = 0
          ENDIF
         ENDIF
         ,
         IF (dup_result_flag = dup_ind )
          SET dup_template_cntr = (dup_template_cntr + 1 )
         ENDIF
        OF lnk_val_result :
         FOR (catalog_cd_cntr = 1 TO catalog_size )
          IF (existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd = new_alert->result_catalog_cd )
           SET dup_result_flag = dup_ind
           SET catalog_cd_cntr = (catalog_size + 1 )
          ENDIF
         ENDFOR
         ,
         IF (new_alert->existing_result_catalog_cd > 0 AND dup_result_flag = dup_ind )
          IF ((locateval (catalog_cd_cntr ,1 ,catalog_size ,new_alert->existing_result_catalog_cd ,
           existing_alerts->alerts[alert_cntr ].catalog_cds[catalog_cd_cntr ].catalog_cd ) > 0 ) )
           SET dup_result_flag = dup_ind
          ELSE
           SET dup_result_flag = 0
          ENDIF
         ENDIF
         ,
         IF (dup_result_flag = dup_ind)
          SET dup_template_cntr = (dup_template_cntr + 1 )
         ENDIF
        OF lnk_val_micro :
         FOR (existing_micro_cntr = 1 TO micro_size )
          FOR (new_micro_cntr = 1 TO value (size (new_alert->micro ,5 ) ) )
           IF ((existing_alerts->alerts[alert_cntr ].micro[existing_micro_cntr ].order_id = new_alert
           ->micro[new_micro_cntr ].order_id ) )
            SET dup_micro_flag = dup_ind
           ENDIF
           IF ((dup_micro_flag = dup_ind ) )
            SET new_micro_seq_pos = value (size (new_alert->micro[new_micro_cntr ].event ,5 ) )
            SET micro_seq_size = size (existing_alerts->alerts[alert_cntr ].micro[
             existing_micro_cntr ].micro_seq ,5 )
            IF ((micro_seq_size > 0 ) )
             IF ((locateval (existing_micro_seq_cntr ,1 ,micro_seq_size ,new_alert->micro[
              new_micro_cntr ].event[new_micro_seq_pos ].micro_seq_nbr ,existing_alerts->alerts[
              alert_cntr ].micro[existing_micro_cntr ].micro_seq[existing_micro_seq_cntr ].
              micro_seq_nbr ) > 0 ) )
              SET dup_micro_flag = dup_ind
             ELSE
              SET dup_micro_flag = 0
             ENDIF
            ELSE
             SET dup_micro_flag = 0
            ENDIF
           ENDIF
          ENDFOR
         ENDFOR
         ,
         IF (dup_micro_flag = dup_ind)
          SET dup_template_cntr = (dup_template_cntr + 1 )
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
     IF ((qualified_templates_cntr = dup_template_cntr ) )
      SET duplicate_alert_ind = dup_ind
     ENDIF
    ENDIF
    IF (duplicate_alert_ind = dup_ind)
     IF (existing_alerts->alerts[alert_cntr ].factor_status_cd IN (alert_completed_cd ,alert_completedint_cd ))
      IF (existing_alerts->alerts[alert_cntr ].factor_dt_tm > cnvtlookbehind ("72, H" ) )
       SET duplicate_alert_ind = dup_ind
      ELSE
       SET duplicate_alert_ind = 0
      ENDIF
     ELSEIF ((existing_alerts->alerts[alert_cntr ].factor_status_cd = alert_dismissed_cd ) )
      IF ((existing_alerts->alerts[alert_cntr ].factor_status_end_dt_tm > cnvtdatetime (curdate ,
       curtime3 ) ) )
       SET duplicate_alert_ind = dup_ind
      ELSE
       SET duplicate_alert_ind = 0
      ENDIF
     ELSEIF ((existing_alerts->alerts[alert_cntr ].factor_status_cd = alert_completednotdup_cd ) )
      SET duplicate_alert_ind = 0
     ELSE
      SET duplicate_alert_ind = dup_ind
     ENDIF
    ENDIF
   ENDIF
   IF (duplicate_alert_ind = dup_ind)
    CALL log_message (build ("duplicate cntr: " ,dup_template_cntr ,"qualified_templates_cntr " ,
      qualified_templates_cntr ) ,log_level_debug )
    SET alert_cntr = (alert_list_size + 1 )
   ENDIF
  ENDFOR
  IF (duplicate_alert_ind = dup_ind)
   SET new_alert->add_alert_ind = add_alert_false
   CALL writeexitmessage ("This rule has data that is a duplicate of an existing alert" )
  ELSE
   SET new_alert->add_alert_ind = add_alert_true
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (existing_alerts )
  ENDIF
  CALL log_message (build ("End - Subroutine CheckForDuplicateAlert. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 
 SUBROUTINE  checkdistinctcatalogcd (alert_index ,catalog_cd )
  CALL log_message ("Begin - Subroutine CheckDistinctCatalogCd" ,log_level_debug )
  DECLARE catalog_idx = i4 WITH private ,noconstant (0 )
  DECLARE catalog_cd_exists = i4 WITH private ,noconstant (0 )
  FOR (catalog_idx = 1 TO value (size (existing_alerts->alerts[alert_index].catalog_cds ,5 ) ) )
   IF (existing_alerts->alerts[alert_index ].catalog_cds[catalog_idx ].catalog_cd = catalog_cd)
    SET catalog_cd_exists = dup_catalog_ind
   ENDIF
  ENDFOR
  CALL log_message ("End - Subroutine CheckDistinctCatalogCd" ,log_level_debug )
  IF (catalog_cd_exists = dup_catalog_ind)
   RETURN (dup_catalog_ind )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 
 
 SUBROUTINE  addpatientpop (dummy )
  CALL log_message ("Begin - Subroutine AddPatientPop" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET errorcode = error (errmsg ,1 )
  SELECT INTO "nl:"
   FROM (lh_cnt_wl wl ),
    (lh_cnt_wl_pop pop )
   PLAN (wl
    WHERE (wl.worklist_mean = asp_worklist_mean ) )
    JOIN (pop
    WHERE (pop.lh_cnt_wl_id = wl.lh_cnt_wl_id )
    AND (pop.encntr_id = new_alert->link_encntr_id )
    AND (pop.active_ind = 1 )
    AND (pop.end_effective_dt_tm = null ) )
   DETAIL
    lh_cnt_wl_pop_id = pop.lh_cnt_wl_pop_id
   WITH nocounter
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine AddPatientPop failed: " ,errmsg ) ,log_level_debug )
   CALL writeexitmessage ("AddPatientPop subroutine failed" )
   SET retval = - (1 )
   GO TO exit_script
  ENDIF
  IF ((lh_cnt_wl_pop_id = 0 ) )
   SET pop_request->person_id = new_alert->link_person_id
   SET pop_request->encntr_id = new_alert->link_encntr_id
   SET pop_request->worklist_mean = asp_worklist_mean
   SET execute_start_time = cnvtdatetime (curdate ,curtime3 )
   CALL log_message ("Beginning to execute lhc_wl_add_pop" ,log_level_debug )
   EXECUTE lhc_wl_add_pop WITH replace ("REQUEST" ,pop_request ) ,
   replace ("REPLY" ,pop_reply )
   CALL log_message (build ("Finished executing lhc_wl_add_pop. Elapsed time in seconds:" ,
     datetimediff (cnvtdatetime (curdate ,curtime3 ) ,execute_start_time ,5 ) ) ,log_level_debug )
   IF ((pop_reply->status_data.status = "S" ) )
    CALL log_message (concat ("Success from lhc_wl_add_pop" ,errmsg ) ,log_level_debug )
    SET lh_cnt_wl_pop_id = pop_reply->lh_cnt_wl_pop_id
   ELSE
    CALL log_message (concat ("Patient not added, failure in lhc_wl_add_pop" ,errmsg ) ,
     log_level_debug )
    CALL writeexitmessage ("Patient not added, failure in lhc_wl_add_pop" )
    SET retval = - (1 )
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (pop_request )
   CALL echorecord (pop_reply )
  ENDIF
  CALL log_message (build ("End - Subroutine AddPatientPop. Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 SUBROUTINE  addpatientfactor (dummy )
  CALL log_message ("Begin - Subroutine AddPatientFactor" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET factor_request->lh_cnt_wl_pop_id = lh_cnt_wl_pop_id
  SET factor_request->factor_txt = new_alert->trigger_rule_name
  SET factor_request->factor_dt_tm = cnvtdatetime (curdate ,curtime3 )
  SET execute_start_time = cnvtdatetime (curdate ,curtime3 )
  CALL log_message ("Beginning to execute lhc_wl_add_factor" ,log_level_debug )
  EXECUTE lhc_wl_add_factor WITH replace ("REQUEST" ,factor_request ) ,
  replace ("REPLY" ,factor_reply )
  CALL log_message (build ("Finished executing lhc_wl_add_factor. Elapsed time in seconds:" 
  ,datetimediff (cnvtdatetime (curdate ,curtime3 ) ,execute_start_time ,5 ) ) ,log_level_debug )
  IF (factor_reply->status_data.status = "S")
   CALL log_message (concat ("Success from lhc_wl_add_factor" ,errmsg ) ,log_level_debug )
   SET lh_cnt_wl_factor_id = factor_reply->lh_cnt_wl_factor_id
  ELSE
   CALL log_message (concat ("Factor not added, failure in lhc_wl_add_factor" ,errmsg ) ,log_level_debug )
   CALL writeexitmessage ("Factor not added, failure in lhc_wl_add_factor" )
   SET retval = - (1 )
   GO TO exit_script
  ENDIF
  IF (debug_ind = 1)
   CALL echorecord (factor_request )
   CALL echorecord (factor_reply )
  ENDIF
  CALL log_message (build ("End - Subroutine AddPatientFactor. Elapsed time in seconds:" 
  ,datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine

 SUBROUTINE  addpatientfactorstatus (dummy )
  CALL log_message ("Begin - Subroutine AddPatientFactorStatus" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET d_stat = alterlist (fac_status_req->statuses ,1 )
  SET fac_status_req->statuses[1 ].lh_cnt_wl_factor_id = lh_cnt_wl_factor_id
  SET fac_status_req->statuses[1 ].factor_status_cd = alert_not_reviewed_cd
  SET fac_status_req->statuses[1 ].factor_status_end_dt_tm = null
  SET execute_start_time = cnvtdatetime (curdate ,curtime3 )
  CALL log_message ("Beginning to execute lhc_wl_add_factor_status" ,log_level_debug )
  EXECUTE lhc_wl_add_factor_status WITH replace ("REQUEST" ,fac_status_req ) ,
  replace ("REPLY" ,fac_status_reply )
  CALL log_message (build ("Finished executing lhc_wl_add_factor_status. Elapsed time in seconds:" ,
                           datetimediff (cnvtdatetime (curdate ,curtime3 ) ,execute_start_time ,5 ) ) ,log_level_debug )
  IF (fac_status_reply->status_data.status = "S")
   CALL log_message (concat ("Factor status was added successfully" ) ,log_level_debug )
  ELSE
   CALL log_message (concat ("Factor not added, failure in lhc_wl_add_factor_status" ,errmsg ) ,log_level_debug )
   CALL writeexitmessage ("Factor not added, failure in lhc_wl_add_factor_status" )
   SET retval = - (1 )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (fac_status_req )
  ENDIF
  CALL log_message (build ("End - Subroutine AddPatientFactorStatus. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 SUBROUTINE  addpatientfactordetail (dummy )
  CALL log_message ("Begin - Subroutine AddPatientFactorDetail" ,log_level_debug )
  DECLARE child_idx_cntr = i4 WITH protect ,noconstant (0 )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  SET d_stat = alterlist (fac_detail_req->details ,1 )
  CALL loadfactordetaillist (0 ,lh_cnt_wl_factor_id ,wl_dtl_type_category_cd ,"" ,key_ind ,"CODE_VALUE" ,new_alert->category_cd )
  SET child_idx_cntr = (child_idx_cntr + 1 )
  CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_severity_cd 
  ,"" ,0 ,"CODE_VALUE" ,new_alert->severity_cd )

  IF (new_alert->med_order_id > 0)
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_medorder_cd 
   ,"" ,0 ,"ORDERS" ,new_alert->med_order_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd 
   ,"" ,key_ind ,"CODE_VALUE" ,new_alert->med_catalog_cd )
  ENDIF

  IF (new_alert->existing_med_order_id > 0)
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_medorder_cd ,"" ,0 ,
    "ORDERS" ,new_alert->existing_med_order_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->existing_med_catalog_cd )
  ENDIF
  
  IF (new_alert->other_order_id > 0 )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_othorder_cd ,"" ,0 ,
    "ORDERS" ,new_alert->other_order_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->other_catalog_cd )
  ENDIF
  
  IF (new_alert->existing_other_order_id > 0 )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_othorder_cd ,"" ,0 ,
    "ORDERS" ,new_alert->existing_other_order_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->existing_other_catalog_cd )
  ENDIF
  
  IF (new_alert->result_event_id > 0 )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_result_id ,"" ,0 ,
    "CLINICAL_EVENT" ,new_alert->result_event_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->result_catalog_cd )
  ENDIF
  IF ((new_alert->existing_result_event_id > 0 ) )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_result_id ,"" ,0 ,
    "CLINICAL_EVENT" ,new_alert->existing_result_event_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->existing_result_catalog_cd )
  ENDIF
  
  IF ((new_alert->medresult_event_id > 0 ) )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_med_reslt_id ,"" ,0 ,
    "CLINICAL_EVENT" ,new_alert->medresult_event_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->medresult_catalog_cd )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_medorder_cd ,"" ,0 ,
    "ORDERS" ,new_alert->medresult_order_id )
  ENDIF
  IF ((new_alert->existing_medresult_event_id > 0 ) )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_med_reslt_id ,"" ,0 ,
    "CLINICAL_EVENT" ,new_alert->existing_medresult_event_id )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_catalog_cd ,"" ,
    key_ind ,"CODE_VALUE" ,new_alert->existing_medresult_catalog_cd )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_medorder_cd ,"" ,0 ,
    "ORDERS" ,new_alert->existing_medresult_order_id )
  ENDIF
  FOR (micro_cntr = 1 TO value (size (new_alert->micro ,5 ) ) )
   SET child_idx_cntr = (child_idx_cntr + 1 )
   CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_micorder_cd ,
    cnvtstring (new_alert->micro[micro_cntr ].event_id ,25 ,1 ) ,key_ind ,"ORDERS" ,new_alert->micro[
    micro_cntr ].order_id )
   FOR (micro_seq_cntr = 1 TO value (size (new_alert->micro[micro_cntr ].event ,5 ) ) )
    SET child_idx_cntr = (child_idx_cntr + 1 )
    CALL loadfactordetaillist (child_idx_cntr ,lh_cnt_wl_factor_id ,wl_dtl_type_mic_evnt_id ,
     new_alert->micro[micro_cntr ].event[micro_seq_cntr ].micro_data ,key_ind ,"CLINICAL_EVENT" ,
     new_alert->micro[micro_cntr ].event_id )
   ENDFOR
  ENDFOR
  SET execute_start_time = cnvtdatetime (curdate ,curtime3 )
  CALL log_message ("Beginning to execute lhc_wl_add_factor_detail" ,log_level_debug )
  IF ((debug_ind = 1 ) )
   CALL echorecord (fac_detail_req )
  ENDIF
  EXECUTE lhc_wl_add_factor_detail WITH replace ("REQUEST" ,fac_detail_req ) ,
  replace ("REPLY" ,fac_detail_reply )
  CALL log_message (build ("Finished executing lhc_wl_add_factor_detail. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,execute_start_time ,5 ) ) ,log_level_debug )
  IF ((fac_detail_reply->status_data.status = "S" ) )
   CALL log_message (concat ("Success from lhc_wl_add_factor_detail" ) ,log_level_debug )
  ELSE
   CALL log_message (concat ("Factor details not added, failure in lhc_wl_add_factor_detail" ,errmsg
     ) ,log_level_debug )
   CALL writeexitmessage ("Factor details not added, failure in lhc_wl_add_factor_detail" )
   SET retval = - (1 )
   GO TO exit_script
  ENDIF
  CALL log_message (build ("End - Subroutine AddPatientFactorDetail. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 
 
 
 
 
 SUBROUTINE  loadfactordetaillist (child_idx ,factor_id ,detail_type_cd ,detail_txt ,key_ind ,
  entity_name ,entity_id )
  IF ((child_idx = 0 ) )
   SET fac_detail_req->details[1 ].lh_cnt_wl_factor_id = factor_id
   SET fac_detail_req->details[1 ].detail_type_cd = detail_type_cd
   SET fac_detail_req->details[1 ].detail_txt = detail_txt
   SET fac_detail_req->details[1 ].key_ind = key_ind
   SET fac_detail_req->details[1 ].parent_entity_name = entity_name
   SET fac_detail_req->details[1 ].parent_entity_id = entity_id
   SET fac_detail_req->details[1 ].beg_effective_dt_tm = cnvtdatetime (curdate ,curtime3 )
  ELSE
   SET d_stat = alterlist (fac_detail_req->details[1 ].child_details ,child_idx )
   SET fac_detail_req->details[1 ].child_details[child_idx ].lh_cnt_wl_factor_id = factor_id
   SET fac_detail_req->details[1 ].child_details[child_idx ].detail_type_cd = detail_type_cd
   SET fac_detail_req->details[1 ].child_details[child_idx ].detail_txt = detail_txt
   SET fac_detail_req->details[1 ].child_details[child_idx ].key_ind = key_ind
   SET fac_detail_req->details[1 ].child_details[child_idx ].parent_entity_name = entity_name
   SET fac_detail_req->details[1 ].child_details[child_idx ].parent_entity_id = entity_id
   SET fac_detail_req->details[1 ].child_details[child_idx ].beg_effective_dt_tm = cnvtdatetime (
    curdate ,curtime3 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  writeexitmessage (ekm_message )
  SET eksdata->tqual[tcurindex ].qual[curindex ].logging = concat (trim (log_message ) ,ekm_message
   )
 END ;Subroutine
 
 
#exit_script
call writeLog(build2("* START Exit Section  ************************************"))
call writeLog(build2(cnvtrectojson()))
call echojson(temp_orders,t_rec->filename_a_s,1)
call echojson(temp_events,t_rec->filename_a_s,1)
call echojson(temp_micro,t_rec->filename_a_s,1)
call echojson(logic_templates,t_rec->filename_a_s,1)
call echojson(new_alert,t_rec->filename_a_s,1)
call echojson(existing_alerts,t_rec->filename_a_s,1)
call echojson(pop_request,t_rec->filename_a_s,1)
call echojson(pop_reply,t_rec->filename_a_s,1)
call echojson(factor_request,t_rec->filename_a_s,1)
call echojson(factor_reply,t_rec->filename_a_s,1)
call echojson(fac_status_req,t_rec->filename_a_s,1)
call echojson(fac_status_reply,t_rec->filename_a_s,1)
call echojson(fac_detail_req,t_rec->filename_a_s,1)
call echojson(fac_detail_reply,t_rec->filename_a_s,1)
call echojson(t_rec,t_rec->filename_a_s,1)
call echojson(program_log,t_rec->filename_a_s,1)

call writeLog(build2("* START Exit Section  ************************************"))
call writeLog(build2(cnvtrectojson(temp_orders)))
call writeLog(build2(cnvtrectojson(temp_events)))
call writeLog(build2(cnvtrectojson(temp_micro)))
call writeLog(build2(cnvtrectojson(logic_templates)))
call writeLog(build2(cnvtrectojson(new_alert)))
call writeLog(build2(cnvtrectojson(existing_alerts)))
call writeLog(build2(cnvtrectojson(pop_request)))
call writeLog(build2(cnvtrectojson(pop_reply)))
call writeLog(build2(cnvtrectojson(factor_request)))
call writeLog(build2(cnvtrectojson(factor_reply)))
call writeLog(build2(cnvtrectojson(fac_status_req)))
call writeLog(build2(cnvtrectojson(fac_status_reply)))
call writeLog(build2(cnvtrectojson(fac_detail_req)))
call writeLog(build2(cnvtrectojson(fac_detail_reply)))

call writeLog(build2(cnvtrectojson(program_log)))

call writeLog(build2("-->Adding Attachment"))
call writeLog(build2("--->program_log->files.file_path=",trim(program_log->files.file_path)))
call writeLog(build2("--->t_rec->filename_a=",trim(t_rec->filename_a)))

call addAttachment(program_log->files.file_path,t_rec->filename_a)
call exitScript(null)

 FREE RECORD temp_orders
 FREE RECORD temp_events
 FREE RECORD temp_micro
 FREE RECORD logic_templates
 FREE RECORD new_alert
 FREE RECORD existing_alerts
 FREE RECORD pop_request
 FREE RECORD pop_reply
 FREE RECORD factor_request
 FREE RECORD factor_reply
 FREE RECORD fac_status_req
 FREE RECORD fac_status_reply
 FREE RECORD fac_detail_req
 FREE RECORD fac_detail_reply
 CALL log_message (build ("End script: " ,target_object ,", Elapsed time in seconds:" ,datetimediff (
    cnvtdatetime (curdate ,curtime3 ) ,beg_dt_tm ,5 ) ) ,log_level_debug )
END GO

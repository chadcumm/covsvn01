/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan' 2020
	Solution:			Behavioral health
	Source file name:	      cov_bh_treat_plan_op_mtp.prg
	Object name:		cov_bh_treat_plan_op_mtp
	Request#:			6723
	Program purpose:	      Track OP outreach specialist documentation
	Executing from:		DA2
 	Special Notes:          Modified/Customized Cerner code
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_bh_treat_plan_os_mtp:dba go
create program cov_bh_treat_plan_os_mtp:dba
 
prompt
  "Output to File/Printer/MINE" = "MINE" ,
  "Select Facility" = 0 ,
  "Get Excel?" = 0
WITH outdev ,fac ,excel
 
 DECLARE getreply (null ) = vc
 DECLARE geterrorcount (null ) = i4
 DECLARE ccps_json = i2 WITH protect ,constant (0 )
 DECLARE ccps_xml = i2 WITH protect ,constant (1 )
 DECLARE ccps_rec_listing = i2 WITH protect ,constant (2 )
 DECLARE ccps_info_domain = vc WITH protect ,constant ("CCPS_SCRIPT_LOGGING" )
 DECLARE ccps_none_ind = i2 WITH protect ,constant (0 )
 DECLARE ccps_file_ind = i2 WITH protect ,constant (1 )
 DECLARE ccps_msgview_ind = i2 WITH protect ,constant (2 )
 DECLARE ccps_listing_ind = i2 WITH protect ,constant (3 )
 DECLARE ccps_log_error = i2 WITH protect ,constant (0 )
 DECLARE ccps_log_audit = i2 WITH protect ,constant (2 )
 DECLARE ccps_error_disp = vc WITH protect ,noconstant ("ERROR" )
 DECLARE ccps_audit_disp = vc WITH protect ,noconstant ("AUDIT" )
 DECLARE ccps_delim1 = vc WITH protect ,noconstant ("*" )
 DECLARE ccps_delim2 = vc WITH protect ,noconstant (";" )
 DECLARE prev_ccps_delim1 = vc WITH protect ,noconstant (":" )
 DECLARE prev_ccps_delim2 = vc WITH protect ,noconstant (";" )
 DECLARE ccps_serrmsg = vc WITH protect ,noconstant (fillstring (132 ," " ) )
 DECLARE ccps_ierrcode = i4 WITH protect ,noconstant (error (ccps_serrmsg ,1 ) )
 EXECUTE msgrtl
 IF (NOT (validate (debug_values ) ) )
  RECORD debug_values (
    1 log_program_name = vc
    1 log_file_dest = vc
    1 inactive_dt_tm = vc
    1 log_level = i2
    1 log_level_override = i2
    1 logging_on = i2
    1 rec_format = i2
    1 suppress_rec = i2
    1 suppress_msg = i2
    1 debug_method = i4
  ) WITH protect
  SET debug_values->logging_on = false
  SET debug_values->log_program_name = curprog
 ENDIF
 IF (NOT (validate (ccps_log ) ) )
  RECORD ccps_log (
    1 ecnt = i4
    1 cnt = i4
    1 qual [* ]
      2 msg = vc
      2 msg_type_id = i4
      2 msg_type_display = vc
  ) WITH protect
 ENDIF
 IF (NOT (validate (ccps_log_frec ) ) )
  RECORD ccps_log_frec (
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 IF (NOT (validate (reply ) ) )
  RECORD reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 CALL setreply ("F" )
 SELECT INTO "nl:"
  FROM (dm_info dm )
  PLAN (dm
   WHERE (dm.info_domain = ccps_info_domain )
   AND (dm.info_name = debug_values->log_program_name )
   AND (dm.info_date >= cnvtdatetime (sysdate ) ) )
  ORDER BY dm.info_name
  HEAD dm.info_name
   entity_cnt = 0 ,component_cnt = 0 ,entity = trim (piece (dm.info_char ,"," ,(entity_cnt + 1 ) ,
     "Not Found" ) ,3 ) ,component = fillstring (4000 ," " ) ,
   WHILE ((component != "Not Found" ) )
    component_cnt +=1 ,
    IF ((findstring (ccps_delim2 ,entity ,1 ) = 0 ) ) component = trim (piece (entity ,
       prev_ccps_delim2 ,component_cnt ,"Not Found" ) ,3 ) ,component_head = trim (piece (cnvtlower (
        component ) ,prev_ccps_delim1 ,1 ,"Not Found" ) ,3 ) ,component_value = trim (piece (
       component ,prev_ccps_delim1 ,2 ,"Not Found" ) ,3 )
    ELSE component = trim (piece (entity ,ccps_delim2 ,component_cnt ,"Not Found" ) ,3 ) ,
     component_head = trim (piece (cnvtlower (component ) ,ccps_delim1 ,1 ,"Not Found" ) ,3 ) ,
     component_value = trim (piece (component ,ccps_delim1 ,2 ,"Not Found" ) ,3 )
    ENDIF
    ,
    CASE (component_head )
     OF "program" :
      debug_values->log_program_name = component_value
     OF "debug_method" :
      IF ((component_value = "None" ) ) debug_values->debug_method = ccps_none_ind
      ELSEIF ((component_value = "File" ) ) debug_values->debug_method = ccps_file_ind
      ELSEIF ((component_value = "Message View" ) ) debug_values->debug_method = ccps_msgview_ind
      ELSEIF ((component_value = "Listing" ) ) debug_values->debug_method = ccps_listing_ind
      ENDIF
     OF "file_name" :
      debug_values->log_file_dest = component_value
     OF "inactive_dt_tm" :
      debug_values->inactive_dt_tm = component_value
     OF "rec_type" :
      debug_values->rec_format = cnvtint (component_value )
     OF "suppress_rec" :
      debug_values->suppress_rec = cnvtint (component_value )
     OF "suppress_msg" :
      debug_values->suppress_msg = cnvtint (component_value )
    ENDCASE
   ENDWHILE
   ,
   IF ((debug_values->debug_method != ccps_none_ind ) ) debug_values->logging_on = true
   ELSE debug_values->logging_on = false
   ENDIF
  FOOT  dm.info_name
   null
  WITH nocounter
 ;end select
 IF (validate (ccps_debug ) )
  IF (NOT (validate (ccps_file ) ) )
   SET debug_values->log_file_dest = build (debug_values->log_program_name ,"_DBG.dat" )
  ELSE
   SET debug_values->log_file_dest = ccps_file
  ENDIF
  IF (NOT (validate (ccps_rec_format ) ) )
   IF ((ccps_debug != ccps_listing_ind ) )
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ELSE
   IF ((ccps_rec_format = ccps_xml ) )
    SET debug_values->rec_format = ccps_xml
   ELSEIF ((ccps_rec_format = ccps_json ) )
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ENDIF
  IF (NOT (validate (ccps_suppress_rec ) ) )
   SET debug_values->suppress_rec = false
  ELSE
   IF ((ccps_suppress_rec = true ) )
    SET debug_values->suppress_rec = true
   ELSE
    SET debug_values->suppress_rec = false
   ENDIF
  ENDIF
  IF (NOT (validate (ccps_suppress_msg ) ) )
   SET debug_values->suppress_msg = false
  ELSE
   IF ((ccps_suppress_msg = true ) )
    SET debug_values->suppress_msg = true
   ELSE
    SET debug_values->suppress_msg = false
   ENDIF
  ENDIF
  CASE (ccps_debug )
   OF ccps_none_ind :
    SET debug_values->debug_method = ccps_none_ind
    SET debug_values->logging_on = false
   OF ccps_file_ind :
    SET debug_values->debug_method = ccps_file_ind
    SET debug_values->logging_on = true
   OF ccps_msgview_ind :
    SET debug_values->debug_method = ccps_msgview_ind
    SET debug_values->logging_on = true
   OF ccps_listing_ind :
    SET debug_values->debug_method = ccps_listing_ind
    SET debug_values->logging_on = true
  ENDCASE
 ENDIF
 IF (debug_values->logging_on )
  CALL echo ("****************************" )
  CALL echo ("*** Logging is turned ON ***" )
  CALL echo ("****************************" )
  CASE (debug_values->debug_method )
   OF ccps_file_ind :
    CALL echo (build ("*** Will write to file: " ,debug_values->log_file_dest ,"***" ) )
   OF ccps_msgview_ind :
    CALL echo ("*****************************" )
    CALL echo ("*** Will write to MsgView ***" )
    CALL echo ("*****************************" )
   OF ccps_listing_ind :
    CALL echo ("*********************************" )
    CALL echo ("*** Will write to the listing ***" )
    CALL echo ("*********************************" )
  ENDCASE
  IF ((debug_values->suppress_rec = true ) )
   CALL echo ("****************************" )
   CALL echo ("***  Suppress Rec is ON  ***" )
   CALL echo ("****************************" )
  ENDIF
  IF ((debug_values->suppress_msg = true ) )
   CALL echo ("****************************" )
   CALL echo ("***  Suppress Msg is ON  ***" )
   CALL echo ("****************************" )
  ENDIF
 ELSE
  CALL echo ("*****************************" )
  CALL echo ("*** Logging is turned OFF ***" )
  CALL echo ("*****************************" )
 ENDIF
 SUBROUTINE  (logmsg (mymsg =vc ,msglvl =i2 (value ,2 ) ) =null )
  DECLARE seek_retval = i4 WITH private ,noconstant (0 )
  DECLARE filelen = i4 WITH private ,noconstant (0 )
  DECLARE write_stat = i2 WITH private ,noconstant (0 )
  DECLARE imsglvl = i2 WITH private ,noconstant (0 )
  DECLARE smsglvl = vc WITH private ,noconstant ("" )
  DECLARE slogtext = vc WITH private ,noconstant ("" )
  DECLARE start_char = i4 WITH private ,noconstant (0 )
  SET imsglvl = msglvl
  SET slogtext = mymsg
  IF ((((debug_values->suppress_msg = false ) ) OR ((debug_values->suppress_msg = true )
  AND (msglvl = ccps_log_error ) )) )
   IF ((((imsglvl = ccps_log_error ) ) OR ((debug_values->logging_on = true ) )) )
    SET ccps_log->cnt +=1
    IF ((msglvl = ccps_log_error ) )
     SET ccps_log->ecnt +=1
    ENDIF
    SET stat = alterlist (ccps_log->qual ,ccps_log->cnt )
    SET ccps_log->qual[ccps_log->cnt ].msg = trim (mymsg ,3 )
    SET ccps_log->qual[ccps_log->cnt ].msg_type_id = msglvl
    IF ((msglvl = ccps_log_error ) )
     SET ccps_log->qual[ccps_log->cnt ].msg_type_display = ccps_error_disp
    ELSE
     SET ccps_log->qual[ccps_log->cnt ].msg_type_display = ccps_audit_disp
    ENDIF
   ENDIF
   CASE (imsglvl )
    OF ccps_log_error :
     SET smsglvl = "Error"
    OF ccps_log_audit :
     SET smsglvl = "Audit"
   ENDCASE
   IF ((imsglvl = ccps_log_error ) )
    CALL writemlgmsg (slogtext ,imsglvl )
    CALL populatesubeventstatus (ccps_log->ecnt ,ccps_error_disp ,"F" ,build (curprog ) ,trim (mymsg
      ,3 ) )
   ENDIF
   IF ((debug_values->logging_on = true ) )
    IF ((debug_values->debug_method = ccps_msgview_ind )
    AND (msglvl != ccps_log_error ) )
     CALL writemlgmsg (slogtext ,imsglvl )
    ELSEIF ((debug_values->debug_method = ccps_file_ind ) )
     SET ccps_log_frec->file_name = debug_values->log_file_dest
     SET ccps_log_frec->file_buf = "ab"
     SET stat = cclio ("OPEN" ,ccps_log_frec )
     SET ccps_log_frec->file_dir = 2
     SET seek_retval = cclio ("SEEK" ,ccps_log_frec )
     SET filelen = cclio ("TELL" ,ccps_log_frec )
     SET ccps_log_frec->file_offset = filelen
     SET ccps_log_frec->file_buf = build2 (format (cnvtdatetime (sysdate ) ,"mm/dd/yyyy hh:mm:ss;;d"
       ) ,fillstring (5 ," " ) ,"{" ,smsglvl ,"}" ,fillstring (5 ," " ) ,mymsg ,char (13 ) ,char (10
       ) )
     SET write_stat = cclio ("WRITE" ,ccps_log_frec )
     SET stat = cclio ("CLOSE" ,ccps_log_frec )
    ELSEIF ((debug_values->debug_method = ccps_listing_ind ) )
     CALL echo (build2 ("*** " ,format (cnvtdatetime (sysdate ) ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
       fillstring (5 ," " ) ,"{" ,smsglvl ,"}" ,fillstring (5 ," " ) ,mymsg ) )
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (logrecord (myrecstruct =vc (ref ) ) =null )
  IF ((debug_values->suppress_rec = false ) )
   DECLARE smsgtype = vc WITH private ,noconstant ("" )
   DECLARE write_stat = i4 WITH private ,noconstant (0 )
   SET smsgtype = "Audit"
   IF ((debug_values->logging_on = true ) )
    IF ((debug_values->debug_method = ccps_file_ind ) )
     SET ccps_log_frec->file_name = debug_values->log_file_dest
     SET ccps_log_frec->file_buf = "ab"
     SET stat = cclio ("OPEN" ,ccps_log_frec )
     SET ccps_log_frec->file_dir = 2
     SET seek_retval = cclio ("SEEK" ,ccps_log_frec )
     SET filelen = cclio ("TELL" ,ccps_log_frec )
     SET ccps_log_frec->file_offset = filelen
     SET ccps_log_frec->file_buf = build2 (format (cnvtdatetime (sysdate ) ,"mm/dd/yyyy hh:mm:ss;;d"
       ) ,fillstring (5 ," " ) ,"{" ,smsgtype ,"}" ,fillstring (5 ," " ) )
     IF ((debug_values->rec_format = ccps_xml ) )
      CALL echoxml (myrecstruct ,debug_values->log_file_dest ,1 )
     ELSEIF ((debug_values->rec_format = ccps_json ) )
      CALL echojson (myrecstruct ,debug_values->log_file_dest ,1 )
     ELSE
      CALL echorecord (myrecstruct ,debug_values->log_file_dest ,1 )
     ENDIF
     SET ccps_log_frec->file_buf = build (ccps_log_frec->file_buf ,char (13 ) ,char (10 ) )
     SET write_stat = cclio ("WRITE" ,ccps_log_frec )
     SET stat = cclio ("CLOSE" ,ccps_log_frec )
    ELSEIF ((debug_values->debug_method = ccps_listing_ind ) )
     CALL echo (build2 ("*** " ,format (cnvtdatetime (sysdate ) ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
       fillstring (5 ," " ) ,"{" ,smsgtype ,"}" ,fillstring (5 ," " ) ) )
     IF ((debug_values->rec_format = ccps_xml ) )
      CALL echoxml (myrecstruct )
     ELSEIF ((debug_values->rec_format = ccps_json ) )
      CALL echojson (myrecstruct )
     ELSE
      CALL echorecord (myrecstruct )
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (catcherrors (mymsg =vc ) =i2 )
  DECLARE ccps_ierroroccurred = i2 WITH private ,noconstant (0 )
  SET ccps_ierrcode = error (ccps_serrmsg ,0 )
  WHILE ((ccps_ierrcode > 0 )
  AND (ccps_log->ecnt < 50 ) )
   SET ccps_ierroroccurred = 1
   CALL logmsg (trim (build2 (mymsg ," -- " ,trim (ccps_serrmsg ,3 ) ) ,3 ) ,ccps_log_error )
   SET ccps_ierrcode = error (ccps_serrmsg ,1 )
  ENDWHILE
  RETURN (ccps_ierroroccurred )
 END ;Subroutine
 SUBROUTINE  geterrorcount (null )
  RETURN (ccps_log->ecnt )
 END ;Subroutine
 SUBROUTINE  (finalizemsgs (outdest =vc (value ,"" ) ,recsizezflag =i4 (value ,1 ) ) =null )
  DECLARE errcnt = i4 WITH noconstant (0 ) ,private
  SET stat = catcherrors ("Performing final check for errors..." )
  SET errcnt = geterrorcount (null )
  IF ((errcnt > 0 ) )
   CALL setreply ("F" )
  ELSEIF ((recsizezflag = 0 ) )
   CALL setreply ("Z" )
  ELSE
   CALL setreply ("S" )
  ENDIF
  IF ((ccps_log->ecnt > 0 )
  AND (cnvtstring (outdest ) != "" ) )
   SELECT INTO value (outdest )
    FROM (dummyt d WITH seq = ccps_log->cnt )
    PLAN (d
     WHERE (ccps_log->qual[d.seq ].msg_type_id = ccps_log_error ) )
    HEAD REPORT
     CALL print (build2 (
      "*** Errors have occurred in the CCL Script.  Please contact your CCL Developer " ,
      "and/or create a help desk ticket to resolving the issue. ***" ,char (13 ) ,char (10 ) ,char (13
       ) ,char (10 ) ) )
    DETAIL
     CALL print (ccps_log->qual[d.seq ].msg ) ,
     row + 1
    FOOT REPORT
     null
    WITH nocounter ,maxcol = 500
   ;end select
  ENDIF
  IF ((debug_values->debug_method = ccps_listing_ind ) )
   CALL echo ("********************************" )
   CALL echo ("*** Printing Logging Summary ***" )
   CALL echo ("********************************" )
   CALL logrecord (ccps_log )
   CALL logrecord (reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (setreply (mystat =vc ) =null )
  IF ((validate (reply->status_data.status ) = 1 ) )
   SET reply->status_data.status = mystat
  ENDIF
 END ;Subroutine
 SUBROUTINE  getreply (null )
  IF ((validate (reply->status_data.status ) = 1 ) )
   RETURN (reply->status_data.status )
  ELSE
   RETURN ("Z" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getcodewithcheck (type =vc ,code_set =i4 (value ,0 ) ,expression =vc (value ,"" ) ,
  msglvl =i2 (value ,2 ) ) =f8 )
  DECLARE cki_flag = i2 WITH private ,noconstant (0 )
  IF ((code_set = 0 ) )
   DECLARE tmp_code_value = f8 WITH private ,noconstant (uar_get_code_by_cki (type ) )
   SET cki_flag = 1
  ELSE
   DECLARE tmp_code_value = f8 WITH private ,noconstant (uar_get_code_by (type ,code_set ,expression
     ) )
  ENDIF
  IF ((tmp_code_value <= 0 ) )
   IF ((cki_flag = 0 ) )
    CALL logmsg (build2 ("*** ! Code value from code set " ,trim (cnvtstring (code_set ) ,3 ) ,
      " with " ,type ," of " ,expression ," was not found !" ) ,msglvl )
   ELSE
    CALL logmsg (build2 ("*** ! Code value with CKI of " ,type ," was not found !" ) ,msglvl )
   ENDIF
  ENDIF
  RETURN (tmp_code_value )
 END ;Subroutine
 SUBROUTINE  (populatesubeventstatus (errorcnt =i4 (value ) ,operationname =vc (value ) ,
  operationstatus =vc (value ) ,targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ) =i2 )
  DECLARE ccps_isubeventcnt = i4 WITH protect ,noconstant (0 )
  DECLARE ccps_isubeventsize = i4 WITH protect ,noconstant (0 )
  IF ((validate (reply->ops_event ) = 1 )
  AND (errorcnt = 1 ) )
   SET reply->ops_event = targetobjectvalue
  ENDIF
  IF ((validate (reply->status_data.status ,"-1" ) != "-1" ) )
   SET ccps_isubeventcnt = size (reply->status_data.subeventstatus ,5 )
   IF ((ccps_isubeventcnt > 0 ) )
    SET ccps_isubeventsize = size (trim (reply->status_data.subeventstatus[ccps_isubeventcnt ].
      operationname ) )
    SET ccps_isubeventsize +=size (trim (reply->status_data.subeventstatus[ccps_isubeventcnt ].
      operationstatus ) )
    SET ccps_isubeventsize +=size (trim (reply->status_data.subeventstatus[ccps_isubeventcnt ].
      targetobjectname ) )
    SET ccps_isubeventsize +=size (trim (reply->status_data.subeventstatus[ccps_isubeventcnt ].
      targetobjectvalue ) )
   ENDIF
   IF ((ccps_isubeventsize > 0 ) )
    SET ccps_isubeventcnt +=1
    SET iloggingstat = alter (reply->status_data.subeventstatus ,ccps_isubeventcnt )
   ENDIF
   IF ((ccps_isubeventcnt > 0 ) )
    SET reply->status_data.subeventstatus[ccps_isubeventcnt ].operationname = substring (1 ,25 ,
     operationname )
    SET reply->status_data.subeventstatus[ccps_isubeventcnt ].operationstatus = substring (1 ,1 ,
     operationstatus )
    SET reply->status_data.subeventstatus[ccps_isubeventcnt ].targetobjectname = substring (1 ,25 ,
     targetobjectname )
    SET reply->status_data.subeventstatus[ccps_isubeventcnt ].targetobjectvalue = targetobjectvalue
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (writemlgmsg (msg =vc ,lvl =i2 ) =null )
  DECLARE sys_handle = i4 WITH noconstant (0 ) ,private
  DECLARE sys_status = i4 WITH noconstant (0 ) ,private
  CALL uar_syscreatehandle (sys_handle ,sys_status )
  IF ((sys_handle > 0 ) )
   CALL uar_msgsetlevel (sys_handle ,lvl )
   CALL uar_sysevent (sys_handle ,lvl ,nullterm (debug_values->log_program_name ) ,nullterm (msg ) )
   CALL uar_sysdestroyhandle (sys_handle )
  ENDIF
 END ;Subroutine
 SET lastmod = "Jan'2020"
 IF (NOT (validate (list_in ) ) )
  DECLARE list_in = i2 WITH protect ,constant (1 )
 ENDIF
 IF (NOT (validate (list_not_in ) ) )
  DECLARE list_not_in = i2 WITH protect ,constant (2 )
 ENDIF
 IF (NOT (validate (ccps_records ) ) )
  RECORD ccps_records (
    1 cnt = i4
    1 list [* ]
      2 name = vc
    1 num = i4
  ) WITH persistscript
 ENDIF
 SUBROUTINE  (ispromptany (which_prompt =i2 ) =i2 )
  DECLARE prompt_reflect = vc WITH private ,noconstant (reflect (parameter (which_prompt ,0 ) ) )
  DECLARE return_val = i2 WITH private ,noconstant (0 )
  IF ((prompt_reflect = "C1" ) )
   IF ((ichar (value (parameter (which_prompt ,1 ) ) ) = 42 ) )
    SET return_val = 1
   ENDIF
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (ispromptlist (which_prompt =i2 ) =i2 )
  DECLARE prompt_reflect = vc WITH private ,noconstant (reflect (parameter (which_prompt ,0 ) ) )
  DECLARE return_val = i2 WITH private ,noconstant (0 )
  IF ((substring (1 ,1 ,prompt_reflect ) = "L" ) )
   SET return_val = 1
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (ispromptsingle (which_prompt =i2 ) =i2 )
  DECLARE prompt_reflect = vc WITH private ,noconstant (reflect (parameter (which_prompt ,0 ) ) )
  DECLARE return_val = i2 WITH private ,noconstant (0 )
  IF ((textlen (trim (prompt_reflect ,3 ) ) > 0 )
  AND NOT (ispromptany (which_prompt ) )
  AND NOT (ispromptlist (which_prompt ) ) )
   SET return_val = 1
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (ispromptempty (which_prompt =i2 ) =i2 )
  DECLARE prompt_reflect = vc WITH private ,noconstant (reflect (parameter (which_prompt ,0 ) ) )
  DECLARE return_val = i2 WITH private ,noconstant (0 )
  IF ((textlen (trim (prompt_reflect ,3 ) ) = 0 ) )
   SET return_val = 1
  ELSEIF (ispromptsingle (which_prompt ) )
   IF ((substring (1 ,1 ,prompt_reflect ) = "C" ) )
    IF ((textlen (trim (value (parameter (which_prompt ,0 ) ) ,3 ) ) = 0 ) )
     SET return_val = 1
    ENDIF
   ELSE
    IF ((cnvtreal (value (parameter (which_prompt ,1 ) ) ) = 0 ) )
     SET return_val = 1
    ENDIF
   ENDIF
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (getpromptlist (which_prompt =i2 ,which_column =vc ,which_option =i2 (value ,list_in )
  ) =vc )
  DECLARE prompt_reflect = vc WITH noconstant (reflect (parameter (which_prompt ,0 ) ) ) ,private
  DECLARE count = i4 WITH noconstant (0 ) ,private
  DECLARE item_num = i4 WITH noconstant (0 ) ,private
  DECLARE option_str = vc WITH noconstant ("" ) ,private
  DECLARE return_val = vc WITH noconstant ("0=1" ) ,private
  IF ((which_option = list_not_in ) )
   SET option_str = " NOT IN ("
  ELSE
   SET option_str = " IN ("
  ENDIF
  IF (ispromptany (which_prompt ) )
   SET return_val = "1=1"
  ELSEIF (ispromptlist (which_prompt ) )
   SET count = cnvtint (substring (2 ,(textlen (prompt_reflect ) - 1 ) ,prompt_reflect ) )
  ELSEIF (ispromptsingle (which_prompt ) )
   SET count = 1
  ENDIF
  IF ((count > 0 ) )
   SET return_val = concat ("(" ,which_column ,option_str )
   FOR (item_num = 1 TO count )
    IF ((mod (item_num ,1000 ) = 1 )
    AND (item_num > 1 ) )
     SET return_val = replace (return_val ,"," ,")" ,2 )
     SET return_val = concat (return_val ," or " ,which_column ,option_str )
    ENDIF
    IF ((substring (1 ,1 ,reflect (parameter (which_prompt ,item_num ) ) ) = "C" ) )
     SET return_val = concat (return_val ,"'" ,value (parameter (which_prompt ,item_num ) ) ,"'" ,
      "," )
    ELSE
     SET return_val = build (return_val ,value (parameter (which_prompt ,item_num ) ) ,"," )
    ENDIF
   ENDFOR
   SET return_val = replace (return_val ,"," ,")" ,2 )
   SET return_val = concat (return_val ,")" )
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (getpromptexpand (which_prompt =i2 ,which_column =vc ,which_option =i2 (value ,list_in
   ) ) =vc )
  DECLARE record_name = vc WITH private ,noconstant (" " )
  DECLARE return_val = vc WITH private ,noconstant ("0=1" )
  IF (ispromptany (which_prompt ) )
   SET return_val = "1=1"
  ELSEIF (((ispromptlist (which_prompt ) ) OR (ispromptsingle (which_prompt ) )) )
   SET record_name = getpromptrecord (which_prompt ,which_column )
   IF ((textlen (trim (record_name ,3 ) ) > 0 ) )
    SET return_val = createexpandparser (which_column ,record_name ,which_option )
   ENDIF
  ENDIF
  CALL logmsg (concat ("GetPromptExpand: return value = " ,return_val ) )
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (getpromptrecord (which_prompt =i2 ,which_rec =vc ) =vc )
  DECLARE record_name = vc WITH private ,noconstant (" " )
  DECLARE prompt_reflect = vc WITH private ,noconstant (reflect (parameter (which_prompt ,0 ) ) ) ,
  private
  DECLARE count = i4 WITH private ,noconstant (0 )
  DECLARE item_num = i4 WITH private ,noconstant (0 )
  DECLARE idx = i4 WITH private ,noconstant (0 )
  DECLARE data_type = vc WITH private ,noconstant (" " )
  DECLARE alias_parser = vc WITH private ,noconstant (" " )
  DECLARE cnt_parser = vc WITH private ,noconstant (" " )
  DECLARE alterlist_parser = vc WITH private ,noconstant (" " )
  DECLARE data_type_parser = vc WITH private ,noconstant (" " )
  DECLARE return_val = vc WITH private ,noconstant (" " )
  IF (((NOT (ispromptany (which_prompt ) ) ) OR (NOT (ispromptempty (which_prompt ) ) )) )
   SET record_name = createrecord (which_rec )
   IF ((textlen (trim (record_name ,3 ) ) > 0 ) )
    IF (ispromptlist (which_prompt ) )
     SET count = cnvtint (substring (2 ,(textlen (prompt_reflect ) - 1 ) ,prompt_reflect ) )
    ELSEIF (ispromptsingle (which_prompt ) )
     SET count = 1
    ENDIF
    IF ((count > 0 ) )
     SET alias_parser = concat ("set curalias = which_rec_alias " ,record_name ,"->list[idx] go" )
     SET cnt_parser = build2 ("set " ,record_name ,"->cnt = " ,count ," go" )
     SET alterlist_parser = build2 ("set stat = alterlist(" ,record_name ,"->list," ,record_name ,
      "->cnt) go" )
     SET data_type = cnvtupper (substring (1 ,1 ,reflect (parameter (which_prompt ,1 ) ) ) )
     SET data_type_parser = concat ("set " ,record_name ,"->data_type = '" ,data_type ,"' go" )
     CALL parser (alias_parser )
     CALL parser (cnt_parser )
     CALL parser (alterlist_parser )
     CALL parser (data_type_parser )
     CALL logmsg (concat ("GetPromptRecord: alias_parser = " ,alias_parser ) )
     CALL logmsg (concat ("GetPromptRecord: cnt_parser = " ,cnt_parser ) )
     CALL logmsg (concat ("GetPromptRecord: alterlist_parser = " ,alterlist_parser ) )
     CALL logmsg (concat ("GetPromptRecord: data_type_parser = " ,data_type_parser ) )
     FOR (item_num = 1 TO count )
      SET idx +=1
      CASE (data_type )
       OF "I" :
        SET which_rec_alias->number = cnvtreal (value (parameter (which_prompt ,item_num ) ) )
       OF "F" :
        SET which_rec_alias->number = cnvtreal (value (parameter (which_prompt ,item_num ) ) )
       OF "C" :
        SET which_rec_alias->string = value (parameter (which_prompt ,item_num ) )
      ENDCASE
     ENDFOR
     SET cnt_parser = concat (record_name ,"->cnt" )
     IF ((validate (parser (cnt_parser ) ,0 ) > 0 ) )
      SET return_val = record_name
     ELSE
      CALL cclexception (999 ,"E" ,
       "GetPromptRecord: failed to add the prompt values to the new record" )
     ENDIF
     SET alias_parser = concat ("set curalias which_rec_alias off go" )
     CALL parser (alias_parser )
     CALL logmsg (concat ("GetPromptRecord: cnt_parser = " ,cnt_parser ) )
     CALL logmsg (concat ("GetPromptRecord: alias_parser = " ,alias_parser ) )
    ELSE
     CALL logmsg ("GetPromptRecord: zero records found" )
    ENDIF
   ENDIF
  ELSE
   CALL logmsg ("GetPromptRecord: prompt value is any(*) or empty" )
  ENDIF
  IF ((textlen (trim (record_name ,3 ) ) > 0 ) )
   CALL parser (concat ("call logRecord(" ,record_name ,") go" ) )
  ENDIF
  CALL logmsg (concat ("GetPromptRecord: return value = " ,return_val ) )
  CALL catcherrors ("An error occurred in GetPromptRecord()" )
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (createrecord (which_rec =vc (value ,"" ) ) =vc )
  DECLARE record_name = vc WITH private ,noconstant (" " )
  DECLARE record_parser = vc WITH private ,noconstant (" " )
  DECLARE new_record_ind = i2 WITH private ,noconstant (0 )
  DECLARE return_val = vc WITH private ,noconstant (" " )
  IF ((textlen (trim (which_rec ,3 ) ) > 0 ) )
   IF ((findstring ("." ,which_rec ,1 ,0 ) > 0 ) )
    SET record_name = concat ("ccps_" ,trim (which_rec ,3 ) ,"_rec" )
   ELSE
    SET record_name = trim (which_rec ,3 )
   ENDIF
  ELSE
   SET record_name = build ("ccps_temp_" ,(ccps_records->cnt + 1 ) ,"_rec" )
  ENDIF
  SET record_name = concat (trim (replace (record_name ,concat (
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 !"#$%&' ,
      "'()*+,-./:;<=>?@[\]^_`{|}~" ) ,concat (
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_______" ,
      "__________________________" ) ,3 ) ,3 ) )
  CALL logmsg (concat ("CreateRecord: record_name = " ,record_name ) )
  IF (NOT (validate (parser (record_name ) ) ) )
   SET record_parser = concat ("record " ,record_name ," (1 cnt = i4" ,
    " 1 list[*] 2 string = vc 2 number = f8" ," 1 data_type = c1 1 num = i4)" ,
    " with persistscript go" )
   CALL logmsg (concat ("CreateRecord: record parser = " ,record_parser ) )
   CALL parser (record_parser )
   IF (validate (parser (record_name ) ) )
    SET return_val = record_name
    SET ccps_records->cnt +=1
    SET stat = alterlist (ccps_records->list ,ccps_records->cnt )
    SET ccps_records->list[ccps_records->cnt ].name = record_name
   ELSE
    CALL cclexception (999 ,"E" ,"CreateRecord: failed to create record" )
   ENDIF
  ELSE
   CALL cclexception (999 ,"E" ,"CreateRecord: record already exists" )
   CALL parser (concat ("call logRecord(" ,record_name ,") go" ) )
  ENDIF
  CALL logrecord (ccps_records )
  CALL logmsg (concat ("CreateRecord: return value = " ,return_val ) )
  CALL catcherrors ("An error occurred in CreateRecord()" )
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (createexpandparser (which_column =vc ,which_rec =vc ,which_option =i2 (value ,list_in
   ) ) =vc )
  DECLARE return_val = vc WITH private ,noconstant ("0=1" )
  DECLARE option_str = vc WITH private ,noconstant (" " )
  DECLARE record_member = vc WITH private ,noconstant (" " )
  DECLARE data_type = vc WITH private ,noconstant (" " )
  DECLARE data_type_parser = vc WITH private ,noconstant (" " )
  IF (validate (parser (which_rec ) ) )
   IF ((which_option = list_not_in ) )
    SET option_str = " NOT"
   ENDIF
   SET data_type_parser = concat ("set data_type = " ,which_rec ,"->data_type go" )
   CALL parser (data_type_parser )
   CASE (data_type )
    OF "I" :
     SET record_member = "number"
    OF "F" :
     SET record_member = "number"
    OF "C" :
     SET record_member = "string"
   ENDCASE
   SET return_val = build (option_str ," expand(" ,which_rec ,"->num" ,"," ,"1," ,which_rec ,
    "->cnt," ,which_column ,"," ,which_rec ,"->list[" ,which_rec ,"->num]." ,record_member ,")" )
  ELSE
   CALL logmsg (concat ("CreateExpandParser: " ,which_rec ," does not exist" ) )
  ENDIF
  CALL logmsg (concat ("CreateExpandParser: return value = " ,return_val ) )
  CALL catcherrors ("An error occurred in CreateExpandParser()" )
  RETURN (return_val )
 END ;Subroutine
 CALL logmsg ("sc_cps_get_prompt_list 007 11/02/2012 ML011047" )
 DECLARE check_ops (null ) = null
 DECLARE main_query (null ) = null
 DECLARE clinical_event (null ) = null
 DECLARE output (null ) = null
 RECORD treat_plan_rpt (
   1 cnt = i4
   1 qual [* ]
     2 facility = vc
     2 person_id = f8
     2 patient_name = vc
     2 encntr_id = f8
     2 ce_encntr_id = f8
     2 fin = vc
     2 reg_dt = vc
     2 goal_date = vc
     2 goal_date_charted = vc
     2 goal_date_creator = vc
     2 until_com = f8
     2 days_over = f8
     2 flag = i2
 )
 
 DECLARE os_mtp_update_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,72 ,"BH OS MTP Update Date" ) ) ,protect
 ;DECLARE 72_bh_goal_cd = f8 WITH constant (uar_get_code_by ("DISPLAY_KEY" ,72 ,"BHGOALCOMPLETIONDATE" ) ) ,protect
 DECLARE 319_fin_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!2930" ) ) ,protect
 DECLARE 8_altered_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!16901" ) ) ,protect
 DECLARE 8_authorized_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!2628" ) ) ,protect
 DECLARE 8_modified_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!2636" ) ) ,protect
 
 DECLARE ops_scheduler = i4 WITH constant (4600 ) ,protect
 DECLARE ops_monitor = i4 WITH constant (4700 ) ,protect
 DECLARE ops_server = i4 WITH constant (4800 ) ,protect
 DECLARE ops_ex_server = i4 WITH constant (3202004 ) ,protect
 DECLARE ops_job = i2 WITH noconstant (0 ) ,protect
 DECLARE ny_tz = i2 WITH constant (126 ) ,protect
 DECLARE last_mod = vc WITH noconstant ("" ) ,protect
 DECLARE idx = i4 WITH noconstant (0 ) ,protect
 DECLARE idx2 = i4 WITH noconstant (0 ) ,protect
 DECLARE flag = i2 WITH noconstant (0 ) ,protect
 DECLARE fac_parser = vc WITH noconstant ("" ) ,protect
 DECLARE begin_dt_tm = dq8 WITH constant (datetimefind (cnvtlookbehind ("8, M" ) ,"D" ,"B" ,"B" ) ) ,
 protect
 DECLARE end_dt_tm = dq8 WITH constant (datetimefind (cnvtlookbehind ("4, M" ) ,"D" ,"E" ,"E" ) ) ,
 protect
 CALL logmsg (build2 ("This is the begin_dt_tm: " ,format (begin_dt_tm ,"MM/DD/YYYY hh:mm;;Q" ) ) ,
  ccps_log_audit )
 CALL logmsg (build2 ("This is the end_dt_tm: " ,format (end_dt_tm ,"MM/DD/YYYY hh:mm;;Q" ) ) ,
  ccps_log_audit )
 IF (((ispromptany (2 ) ) OR (ispromptempty (2 ) )) )
  SET fac_parser = "1=1"
 ELSE
  SET fac_parser = trim (getpromptlist (2 ,"e.loc_facility_cd" ,1 ) ,3 )
 ENDIF
 CALL logmsg (build2 ("This is fac_parser: " ,fac_parser ) ,ccps_log_audit )
 CALL logmsg (build2 ("Going into CHECK OPS!" ) ,ccps_log_audit )
 CALL check_ops (null )
 CALL logmsg (build2 ("Going into MAIN QUERY!" ) ,ccps_log_audit )
 CALL main_query (null )
 CALL logmsg (build2 ("Going into CLINICAL EVENT!" ) ,ccps_log_audit )
 CALL clinical_event (null )
 
 IF (( $EXCEL = 1 ) )
  CALL output (null )
 ELSE
 	EXECUTE cov_bh_treat_plan_os_lb  $OUTDEV
  	;EXECUTE chs_tn_cr_treat_plan_rpt_lyt  $OUTDEV
 ENDIF
 
 SUBROUTINE  check_ops (null )
  IF ((validate (reqinfo->updt_app ,0.0 ) > 0.0 ) )
   IF ((reqinfo->updt_app IN (ops_scheduler ,
   ops_monitor ,
   ops_server ,
   ops_ex_server ) ) )
    SET ops_job = 1
   ENDIF
  ENDIF
 END ;Subroutine
 
;-----------------------  Main Query ----------------------------------------
;Patient Demographic
 SUBROUTINE  main_query (null )
  SELECT INTO "nl:"
   FROM (encounter e ),
    (person p ),
    (encntr_alias ea )
   PLAN (e WHERE (e.reg_dt_tm BETWEEN cnvtdatetime (begin_dt_tm ) AND cnvtdatetime (end_dt_tm ) )
    AND parser (fac_parser )
    AND (e.active_ind = 1 )
    AND (e.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (e.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (p
    WHERE (p.person_id = e.person_id )
    AND (p.active_ind = 1 )
    AND (p.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (p.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (ea
    WHERE (ea.encntr_id = e.encntr_id )
    AND (ea.encntr_alias_type_cd = 319_fin_cd )
    AND (ea.active_ind = 1 )
    AND (ea.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (ea.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
   ORDER BY e.loc_facility_cd ,
    e.person_id ,
    e.encntr_id
   HEAD REPORT
    idx = 0
   HEAD e.encntr_id
    idx +=1 ,
    IF ((mod (idx ,10 ) = 1 ) ) stat = alterlist (treat_plan_rpt->qual ,(idx + 9 ) )
    ENDIF
    ,treat_plan_rpt->qual[idx ].patient_name = build2 (trim (p.name_last ,3 ) ,", " ,trim (p
      .name_first ,3 ) ," " ,substring (1 ,1 ,p.name_middle ) ) ,treat_plan_rpt->qual[idx ].person_id
     = p.person_id ,treat_plan_rpt->qual[idx ].encntr_id = e.encntr_id ,treat_plan_rpt->qual[idx ].
    facility = trim (uar_get_code_display (e.loc_facility_cd ) ,3 ) ,treat_plan_rpt->qual[idx ].
    reg_dt = datetimezoneformat (e.reg_dt_tm ,ny_tz ,"MM/DD/YYYY" ) ,treat_plan_rpt->qual[idx ].fin
    = trim (cnvtalias (ea.alias ,ea.alias_pool_cd ) ,3 )
   FOOT  e.encntr_id
    null
   FOOT REPORT
    stat = alterlist (treat_plan_rpt->qual ,idx ) ,
    treat_plan_rpt->cnt = idx ,
    CALL logmsg (build2 ("This is the COUNT: " ,treat_plan_rpt->cnt ) ,ccps_log_audit )
   WITH nocounter
  ;end select
 END ;Subroutine
 
;--------------------------- Clinical Events --------------------------------------------------------------------
 
 SUBROUTINE  clinical_event (null )
  SELECT INTO "nl:"
   FROM (clinical_event ce ),
    (ce_date_result cdr ),
    (prsnl p )
   PLAN (ce
    WHERE expand (idx2 ,1 ,treat_plan_rpt->cnt ,ce.encntr_id ,treat_plan_rpt->qual[idx2 ].encntr_id ,
     ce.person_id ,treat_plan_rpt->qual[idx2 ].person_id )
    AND (ce.event_cd = os_mtp_update_var)
    ;AND (ce.event_cd = 72_bh_goal_cd )
    AND (ce.result_status_cd IN (8_altered_cd ,
    8_authorized_cd ,
    8_modified_cd ) )
    AND (ce.valid_until_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (cdr
    WHERE (cdr.event_id = ce.event_id )
    AND (cdr.valid_until_dt_tm > cnvtdatetime (sysdate ) ) )
    JOIN (p
    WHERE (p.person_id = Outerjoin(ce.updt_id )) )
   ORDER BY ce.encntr_id ,
    ce.event_end_dt_tm
   HEAD REPORT
    null
   HEAD ce.encntr_id
    pos = locateval (idx2 ,1 ,treat_plan_rpt->cnt ,ce.encntr_id ,treat_plan_rpt->qual[idx2 ].
     encntr_id ,ce.person_id ,treat_plan_rpt->qual[idx2 ].person_id ) ,
    IF ((pos > 0 ) )
     CALL logmsg (build2 ("POS = " ,pos ) ,ccps_log_audit ) ,
     CALL logmsg (build2 ("Here's the encntr_id: " ,ce.encntr_id ) ,ccps_log_audit ) ,treat_plan_rpt
     ->qual[pos ].ce_encntr_id = ce.encntr_id ,treat_plan_rpt->qual[pos ].goal_date_charted = format
     (ce.verified_dt_tm ,"MM/DD/YYYY;;Q" ) ,treat_plan_rpt->qual[pos ].goal_date_creator = build2 (
      trim (p.name_last ,3 ) ,", " ,trim (p.name_first ,3 ) ) ,
     CALL logmsg (build ("Here's the goal_date: " ,datetimezoneformat (cdr.result_dt_tm ,cdr
       .result_tz ,"DD-MMM-YYYY" ) ) ,ccps_log_audit ) ,treat_plan_rpt->qual[pos ].goal_date =
     datetimezoneformat (cdr.result_dt_tm ,cdr.result_tz ,"DD-MMM-YYYY" ) ,
     IF ((textlen (trim (treat_plan_rpt->qual[pos ].goal_date ,3 ) ) > 0 ) ) treat_plan_rpt->qual[
      pos ].flag = 1
     ENDIF
     ,treat_plan_rpt->qual[pos ].until_com = datetimediff (cnvtdatetime (treat_plan_rpt->qual[pos ].
       goal_date ) ,cnvtdatetime (sysdate ) ,1 ) ,
     CALL logmsg (build2 ("# of days until Completion: " ,treat_plan_rpt->qual[pos ].until_com ) ,
     ccps_log_audit ) ,
     IF ((treat_plan_rpt->qual[pos ].until_com < 0 ) ) treat_plan_rpt->qual[pos ].until_com = 0
     ENDIF
     ,treat_plan_rpt->qual[pos ].days_over = datetimediff (cnvtdatetime (sysdate ) ,cnvtdatetime (
       treat_plan_rpt->qual[pos ].goal_date ) ,1 ) ,
     CALL logmsg (build2 ("# of days Overdue: " ,treat_plan_rpt->qual[pos ].days_over ) ,
     ccps_log_audit ) ,
     IF ((treat_plan_rpt->qual[pos ].days_over < 0 ) ) treat_plan_rpt->qual[pos ].days_over = 0
     ENDIF
    ENDIF
   FOOT  ce.encntr_id
    null
   FOOT REPORT
    null
   WITH expand = 2
  ;end select
 END ;Subroutine
 
;------------------------------------- Output Section Start --------------------------------------------------------------------------
  SUBROUTINE  output (null )
  RECORD file_output (
    1 file_desc = i4
    1 file_name = vc
    1 file_buf = vc
    1 file_dir = i4
    1 file_offset = i4
  )
  DECLARE output_string = vc WITH noconstant ("" ) ,protect
  DECLARE file_date = vc WITH noconstant ("" ) ,protect
  DECLARE end_of_line = vc WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
  DECLARE delimiter = vc WITH constant ("|" ) ,protect
  DECLARE idx = i4 WITH noconstant (0 ) ,protect
  IF ((size (treat_plan_rpt->qual ,5 ) > 0 ) )
   CALL logmsg (build2 ("OPS_JOB is equal to: " ,ops_job ) ,ccps_log_audit )
   CALL logmsg (build2 ("EXCEL is equal to: " , $EXCEL ) ,ccps_log_audit )
   SET file_output->file_name =  $OUTDEV
   CALL logmsg (build2 ("FILE NAME IS: " ,file_output->file_name ) ,ccps_log_audit )
   SET file_output->file_dir = 2
   SET file_output->file_buf = "w"
   SET stat = cclio ("OPEN" ,file_output )
   SET output_string = build2 ("Patient Name" ,delimiter ,"FIN" ,delimiter ,
    "BH Goal Completion Date" ,delimiter ,"Days Until Completion" ,delimiter ,"Days Overdue" ,
    delimiter ,"Documented By" ,delimiter ,"Documented On" )
   SET file_output->file_buf = concat (output_string ,end_of_line )
   SET stat = cclio ("WRITE" ,file_output )
   FOR (idx = 1 TO treat_plan_rpt->cnt )
    IF ((textlen (trim (treat_plan_rpt->qual[idx ].goal_date ,3 ) ) > 0 ) )
     IF ((treat_plan_rpt->qual[idx ].until_com <= 60 ) )
      SET output_string = build2 (trim (substring (1 ,50 ,treat_plan_rpt->qual[idx ].patient_name ) ,
        3 ) ,delimiter ,trim (substring (1 ,12 ,treat_plan_rpt->qual[idx ].fin ) ,3 ) ,delimiter ,
       trim (substring (1 ,12 ,treat_plan_rpt->qual[idx ].goal_date ) ,3 ) ,delimiter ,trim (
        substring (1 ,3 ,cnvtstring (treat_plan_rpt->qual[idx ].until_com ) ) ,3 ) ,delimiter ,trim (
        substring (1 ,3 ,cnvtstring (treat_plan_rpt->qual[idx ].days_over ) ) ,3 ) ,delimiter ,trim (
        substring (1 ,50 ,treat_plan_rpt->qual[idx ].goal_date_creator ) ,3 ) ,delimiter ,trim (
        substring (1 ,12 ,treat_plan_rpt->qual[idx ].goal_date_charted ) ,3 ) )
      SET file_output->file_buf = concat (output_string ,end_of_line )
      SET stat = cclio ("WRITE" ,file_output )
     ENDIF
    ENDIF
   ENDFOR
   SET stat = cclio ("CLOSE" ,file_output )
  ELSE
   SELECT INTO  $OUTDEV
    FROM (dummyt d WITH seq = 1 )
    PLAN (d )
    HEAD REPORT
     "{CPI/9}{FONT/4}" ,
     row 3 ,
     col 0 ,
     CALL print (build2 ("Execution Date/Time:  " ,format (cnvtdatetime (curdate ,curtime ) ,
       "mm/dd/yyyy hh:mm:ss;;q" ) ) ) ,
     row + 1 ,
     row 6 ,
     col 0 ,
     CALL print (
     "There is no qualifying data to display in the report for the chosen criteria. Please try again."
     )
    WITH nocounter ,nullreport ,maxcol = 300 ,dio = postscript
   ;end select
  ENDIF
 END ;Subroutine
;------------------------------------- Output Section End --------------------------------------------------------------------------
 
END GO

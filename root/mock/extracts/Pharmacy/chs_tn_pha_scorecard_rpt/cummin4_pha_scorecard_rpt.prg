DROP PROGRAM cummin4_pha_scorecard_rpt :dba GO
CREATE PROGRAM cummin4_pha_scorecard_rpt :dba 
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Begin Date:" = "" ,
  "End Date:" = "CURDATE" ,
  "Generate File:" = 0
  WITH outdev ,begin_dt ,end_dt ,to_file
 DECLARE logmsg ((mymsg = vc ) ,(msglvl = i2 (value ,2 ) ) ) = null
 DECLARE logrecord ((myrecstruct = vc (ref ) ) ) = null
 DECLARE finalizemsgs ((outdest = vc (value ,"" ) ) ,(recsizezflag = i4 (value ,1 ) ) ) = null
 DECLARE catcherrors ((mymsg = vc ) ) = i2
 DECLARE getreply (null ) = vc
 DECLARE geterrorcount (null ) = i4
 DECLARE getcodewithcheck ((type = vc ) ,(code_set = i4 (value ,0 ) ) ,(expression = vc (value ,"" )
  ) ,(msglvl = i2 (value ,2 ) ) ) = f8
 DECLARE setreply ((mystat = vc ) ) = null
 DECLARE populatesubeventstatus ((errorcnt = i4 (value ) ) ,(operationname = vc (value ) ) ,(
  operationstatus = vc (value ) ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value
   ) ) ) = i2
 DECLARE writemlgmsg ((msg = vc ) ,(lvl = i2 ) ) = null
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

set ccps_debug = 3	

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
 IF (NOT (validate (frec ) ) )
  RECORD frec (
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
   AND (dm.info_date >= cnvtdatetime (curdate ,curtime3 ) ) )
  ORDER BY dm.info_name
  HEAD dm.info_name
   entity_cnt = 0 ,component_cnt = 0 ,entity = trim (piece (dm.info_char ,"," ,(entity_cnt + 1 ) ,
     "Not Found" ) ,3 ) ,component = fillstring (4000 ," " ) ,
   WHILE ((component != "Not Found" ) )
    component_cnt = (component_cnt + 1 ) ,
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
 SUBROUTINE  logmsg (mymsg ,msglvl )
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
    SET ccps_log->cnt = (ccps_log->cnt + 1 )
    IF ((msglvl = ccps_log_error ) )
     SET ccps_log->ecnt = (ccps_log->ecnt + 1 )
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
     SET frec->file_name = debug_values->log_file_dest
     SET frec->file_buf = "ab"
     SET stat = cclio ("OPEN" ,frec )
     SET frec->file_dir = 2
     SET seek_retval = cclio ("SEEK" ,frec )
     SET filelen = cclio ("TELL" ,frec )
     SET frec->file_offset = filelen
     SET frec->file_buf = build2 (format (cnvtdatetime (curdate ,curtime3 ) ,
       "mm/dd/yyyy hh:mm:ss;;d" ) ,fillstring (5 ," " ) ,"{" ,smsglvl ,"}" ,fillstring (5 ," " ) ,
      mymsg ,char (13 ) ,char (10 ) )
     SET write_stat = cclio ("WRITE" ,frec )
     SET stat = cclio ("CLOSE" ,frec )
    ELSEIF ((debug_values->debug_method = ccps_listing_ind ) )
     CALL echo (build2 ("*** " ,format (cnvtdatetime (curdate ,curtime3 ) ,"mm/dd/yyyy hh:mm:ss;;d"
        ) ,fillstring (5 ," " ) ,"{" ,smsglvl ,"}" ,fillstring (5 ," " ) ,mymsg ) )
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  logrecord (myrecstruct )
  IF ((debug_values->suppress_rec = false ) )
   DECLARE smsgtype = vc WITH private ,noconstant ("" )
   DECLARE write_stat = i4 WITH private ,noconstant (0 )
   SET smsgtype = "Audit"
   IF ((debug_values->logging_on = true ) )
    IF ((debug_values->debug_method = ccps_file_ind ) )
     SET frec->file_name = debug_values->log_file_dest
     SET frec->file_buf = "ab"
     SET stat = cclio ("OPEN" ,frec )
     SET frec->file_dir = 2
     SET seek_retval = cclio ("SEEK" ,frec )
     SET filelen = cclio ("TELL" ,frec )
     SET frec->file_offset = filelen
     SET frec->file_buf = build2 (format (cnvtdatetime (curdate ,curtime3 ) ,
       "mm/dd/yyyy hh:mm:ss;;d" ) ,fillstring (5 ," " ) ,"{" ,smsgtype ,"}" ,fillstring (5 ," " ) )
     IF ((debug_values->rec_format = ccps_xml ) )
      CALL echoxml (myrecstruct ,debug_values->log_file_dest ,1 )
     ELSEIF ((debug_values->rec_format = ccps_json ) )
      CALL echojson (myrecstruct ,debug_values->log_file_dest ,1 )
     ELSE
      CALL echorecord (myrecstruct ,debug_values->log_file_dest ,1 )
     ENDIF
     SET frec->file_buf = build (frec->file_buf ,char (13 ) ,char (10 ) )
     SET write_stat = cclio ("WRITE" ,frec )
     SET stat = cclio ("CLOSE" ,frec )
    ELSEIF ((debug_values->debug_method = ccps_listing_ind ) )
     CALL echo (build2 ("*** " ,format (cnvtdatetime (curdate ,curtime3 ) ,"mm/dd/yyyy hh:mm:ss;;d"
        ) ,fillstring (5 ," " ) ,"{" ,smsgtype ,"}" ,fillstring (5 ," " ) ) )
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
 SUBROUTINE  catcherrors (mymsg )
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
 SUBROUTINE  finalizemsgs (outdest ,recsizezflag )
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
      "*** Errors have occurred in the CCL Script.  Please contact your System Administrator " ,
      "and/or Cerner for assistance with resolving the issue. ***" ,char (13 ) ,char (10 ) ,char (13
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
 SUBROUTINE  setreply (mystat )
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
 SUBROUTINE  getcodewithcheck (type ,code_set ,expression ,msglvl )
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
 SUBROUTINE  populatesubeventstatus (errorcnt ,operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue )
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
    SET ccps_isubeventsize = (ccps_isubeventsize + size (trim (reply->status_data.subeventstatus[
      ccps_isubeventcnt ].operationstatus ) ) )
    SET ccps_isubeventsize = (ccps_isubeventsize + size (trim (reply->status_data.subeventstatus[
      ccps_isubeventcnt ].targetobjectname ) ) )
    SET ccps_isubeventsize = (ccps_isubeventsize + size (trim (reply->status_data.subeventstatus[
      ccps_isubeventcnt ].targetobjectvalue ) ) )
   ENDIF
   IF ((ccps_isubeventsize > 0 ) )
    SET ccps_isubeventcnt = (ccps_isubeventcnt + 1 )
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
 SUBROUTINE  writemlgmsg (msg ,lvl )
  DECLARE sys_handle = i4 WITH noconstant (0 ) ,private
  DECLARE sys_status = i4 WITH noconstant (0 ) ,private
  CALL uar_syscreatehandle (sys_handle ,sys_status )
  IF ((sys_handle > 0 ) )
   CALL uar_msgsetlevel (sys_handle ,lvl )
   CALL uar_sysevent (sys_handle ,lvl ,nullterm (debug_values->log_program_name ) ,nullterm (msg ) )
   CALL uar_sysdestroyhandle (sys_handle )
  ENDIF
 END ;Subroutine
 SET lastmod = "004 01/19/2017 ML011047"
 SUBROUTINE  (parsedateprompt (date_str =vc ,default_date =vc ,time =i4 ) =dq8 )
  DECLARE _return_val = dq8 WITH noconstant (0.0 ) ,private
  DECLARE _time = i4 WITH constant (cnvtint (time ) ) ,private
  DECLARE _date = i4 WITH constant (_parsedate (date_str ) ) ,private
  IF ((_date = 0.0 ) )
   CASE (substring (1 ,1 ,reflect (default_date ) ) )
    OF "F" :
     SET _return_val = cnvtdatetime (cnvtdate (default_date ) ,_time )
    OF "C" :
     SET _return_val = cnvtdatetime (_evaluatedatestr (default_date ) ,_time )
    OF "I" :
     SET _return_val = cnvtdatetime (default_date ,_time )
    ELSE
     SET _return_val = 0
   ENDCASE
  ELSE
   SET _return_val = cnvtdatetime (_date ,_time )
  ENDIF
  RETURN (_return_val )
 END ;Subroutine
 SUBROUTINE  (parsedateoperations (pdateunits =vc ,prangemode =vc (value ,"B" ) ,ptimemode =vc (
   value ,"B" ) ) =dq8 )
  DECLARE type = vc WITH private ,noconstant ("" )
  DECLARE units = i2 WITH private ,noconstant (0 )
  DECLARE interval_type = c1 WITH private ,noconstant ("" )
  DECLARE date_mode = c1 WITH private ,noconstant ("" )
  DECLARE return_date = dq8 WITH private ,noconstant (0.0 )
  DECLARE search_exp = c1 WITH private ,noconstant ("" )
  IF (findstring ("-" ,pdateunits ,1 ) )
   SET search_exp = "-"
  ELSEIF (findstring ("+" ,pdateunits ,1 ) )
   SET search_exp = "+"
  ENDIF
  SET type = cnvtupper (trim (piece (pdateunits ,search_exp ,1 ,"CURDATE" ) ,3 ) )
  SET units = cnvtint (piece (pdateunits ,search_exp ,2 ,"0" ) )
  CASE (type )
   OF "CURDATE" :
    SET interval_type = "D"
    SET date_mode = "D"
   OF "CURWEEK" :
    SET interval_type = "W"
    SET date_mode = "W"
   OF "CURMONTH" :
    SET interval_type = "M"
    SET date_mode = "M"
   OF "CURQUARTER" :
    SET interval_type = "M"
    SET date_mode = "Q"
    SET units = (units * 3 )
   OF "CURYEAR" :
    SET interval_type = "Y"
    SET date_mode = "Y"
   ELSE
    SET interval_type = "D"
    SET date_mode = "D"
  ENDCASE
  IF ((search_exp = "-" ) )
   SET return_date = cnvtlookbehind (build (units ,"," ,interval_type ) ,cnvtdatetime (curdate ,
     curtime3 ) )
  ELSE
   SET return_date = cnvtlookahead (build (units ,"," ,interval_type ) ,cnvtdatetime (curdate ,
     curtime3 ) )
  ENDIF
  SET return_date = datetimefind (cnvtdatetime (return_date ) ,date_mode ,prangemode ,ptimemode )
  IF ((cnvtdatetime (return_date ) = 0.0 ) )
   SET return_date = cnvtdatetime (curdate ,curtime3 )
  ENDIF
  RETURN (return_date )
 END ;Subroutine
 SUBROUTINE  (_parsedate (date_str =vc ) =i4 )
  DECLARE _return_val = dq8 WITH noconstant (0.0 ) ,private
  DECLARE _time = i4 WITH constant (0 ) ,private
  IF (isnumeric (date_str ) )
   DECLARE _date = vc WITH constant (trim (cnvtstring (date_str ) ) ) ,private
   SET _return_val = cnvtdatetime (cnvtdate (_date ) ,_time )
   IF ((_return_val = 0.0 ) )
    SET _return_val = cnvtdatetime (cnvtint (_date ) ,_time )
   ENDIF
  ELSE
   DECLARE _date = vc WITH constant (trim (date_str ) ) ,private
   IF ((textlen (trim (_date ) ) = 0 ) )
    SET _return_val = 0
   ELSE
    IF ((_date IN ("*CURDATE*" ) ) )
     SET _return_val = cnvtdatetime (_evaluatedatestr (_date ) ,_time )
    ELSE
     SET _return_val = cnvtdatetime (cnvtdate2 (_date ,_evaluatedateformat (_date ) ) ,_time )
    ENDIF
   ENDIF
  ENDIF
  RETURN (cnvtdate (_return_val ) )
 END ;Subroutine
 SUBROUTINE  (_evaluatedatestr (date_str =vc ) =i4 )
  DECLARE _dq8 = dq8 WITH noconstant (0.0 ) ,private
  DECLARE _parse = vc WITH constant (concat ("set _dq8 = cnvtdatetime(" ,date_str ,", 0) go" ) ) ,
  private
  CALL parser (_parse )
  RETURN (cnvtdate (_dq8 ) )
 END ;Subroutine
 SUBROUTINE  (_evaluatedateformat (date_str =vc ) =vc )
  DECLARE _format_str = vc WITH protect ,noconstant ("DD-MMM-YYYY" )
  DECLARE _swap_str = vc WITH protect ,noconstant ("" )
  DECLARE _search_exp = vc WITH protect ,noconstant ("" )
  DECLARE _search_day = vc WITH protect ,noconstant ("" )
  DECLARE _search_mth = vc WITH protect ,noconstant ("" )
  DECLARE _search_pos = i4 WITH protect ,noconstant (0 )
  IF (findstring ("/" ,date_str ,1 ) )
   SET _search_exp = "/"
   SET _search_pos = findstring (_search_exp ,date_str )
  ELSEIF (findstring ("-" ,date_str ,1 ) )
   SET _search_exp = "-"
   SET _search_pos = findstring (_search_exp ,date_str )
  ENDIF
  SET _search_day = trim (piece (date_str ,_search_exp ,1 ,"" ) ,3 )
  SET _search_mth = trim (piece (date_str ,_search_exp ,2 ,"" ) ,3 )
  IF ((textlen (_search_day ) > 2 ) )
   SET _swap_str = _search_day
   SET _search_day = _search_mth
   SET _search_mth = _swap_str
  ENDIF
  CASE (_search_pos )
   OF 4 :
    CASE (_search_exp )
     OF "-" :
      SET _format_str = "MMM-DD-YYYY"
     OF "/" :
      SET _format_str = "MMM/DD/YYYY"
    ENDCASE
   OF 3 :
    IF ((textlen (_search_mth ) > 2 ) )
     CASE (_search_exp )
      OF "-" :
       SET _format_str = "DD-MMM-YYYY"
      OF "/" :
       SET _format_str = "DD/MMM/YYYY"
     ENDCASE
    ELSE
     CASE (_search_exp )
      OF "-" :
       SET _format_str = "MM-DD-YYYY"
      OF "/" :
       SET _format_str = "MM/DD/YYYY"
     ENDCASE
    ENDIF
  ENDCASE
  RETURN (_format_str )
 END ;Subroutine
 SUBROUTINE  (_evaluatetimestr (time_str =vc ) =i4 )
  DECLARE _dq8 = dq8 WITH constant (cnvtdatetime (0 ,time_str ) ) ,private
  DECLARE _str = vc WITH constant (format (cnvtstring (cnvttime (_dq8 ) ) ,"####;p0" ) )
  RETURN (cnvttime2 (_dq8 ,"HHMM" ) )
 END ;Subroutine
 DECLARE active = i2 WITH protect ,constant (1 )
 DECLARE display_msg = vc WITH protect ,noconstant ("" )
 DECLARE date_time_fmt = vc WITH protect ,constant ("MM/DD/YYYY HH:MM;;Q" )
 IF (NOT (validate (pha_data ) ) )
  RECORD pha_data (
    1 qual_cnt = i4
    1 qual [* ]
      2 encntr_id = f8
      2 encntr_alias_id = f8
      2 event_id = f8
      2 clinical_event_id = f8
      2 person_id = f8
      2 person_alias_id = f8
      2 charge_item_id = f8
      2 bill_item_id = f8
      2 bill_item_mod_id = f8
      2 item_id = f8
      2 task_id = f8
      2 organization_id = f8
      2 order_id = f8
      2 order_action_id = f8
      2 order_prod_id = f8
      2 template_order_id = f8
      2 prsnl_alias_id = f8
      2 phys_person_id = f8
      2 ordered_by_id = f8
      2 synonym_id = f8
      2 facility_cd = vc
      2 fin = vc
      2 cmrn = vc
      2 item_number = vc
      2 charge_entered_dt = dq8
      2 charged_dt = dq8
      2 order_display = vc
      2 drug_generic_name = vc
      2 drug_brand_name = vc
      2 strength_dose = vc
      2 strength_dose_unit = vc
      2 route_of_admin = vc
      2 volume_dose = vc
      2 volume_dose_unit = vc
      2 rate = vc
      2 rate_unit = vc
      2 normalized_rate = vc
      2 normalized_rate_unit = vc
      2 drug_form = vc
      2 quantity_doses_charged = f8
      2 frequency_code = f8
      2 frequency_display = vc
      2 duration = vc
      2 drug_class_code1 = vc
      2 drug_class_description1 = vc
      2 drug_class_code2 = vc
      2 drug_class_description2 = vc
      2 drug_class_code3 = vc
      2 drug_class_description3 = vc
      2 physician_number = vc
      2 personnel_username = vc
      2 admit_dt_tm = dq8
      2 discharge_dt_tm = dq8
      2 mrn = vc
      2 d_number = vc
      2 multm_main_drug_code = i4
      2 multm_flag = i2
      2 data_origin = vc
      2 category_cd = f8
      2 result_status_cd = f8
      2 item_id_flag = i2
      2 template_order_flag = i4
      2 volume_dose_flag = i2
      2 strength_dose_flag = i2
      2 change_rate_flag = i2
  )
 ENDIF
 IF (NOT (validate (acudose_data ) ) )
  RECORD acudose_data (
    1 qual_cnt = i4
    1 qual [* ]
      2 encntr_id = f8
      2 encntr_alias_id = f8
      2 event_id = f8
      2 clinical_event_id = f8
      2 person_id = f8
      2 person_alias_id = f8
      2 charge_item_id = f8
      2 bill_item_id = f8
      2 bill_item_mod_id = f8
      2 item_id = f8
      2 task_id = f8
      2 organization_id = f8
      2 order_id = f8
      2 order_action_id = f8
      2 order_prod_id = f8
      2 template_order_id = f8
      2 prsnl_alias_id = f8
      2 phys_person_id = f8
      2 ordered_by_id = f8
      2 synonym_id = f8
      2 facility_cd = vc
      2 fin = vc
      2 cmrn = vc
      2 item_number = vc
      2 charge_entered_dt = dq8
      2 charged_dt = dq8
      2 order_display = vc
      2 drug_generic_name = vc
      2 drug_brand_name = vc
      2 strength_dose = vc
      2 strength_dose_unit = vc
      2 route_of_admin = vc
      2 volume_dose = vc
      2 volume_dose_unit = vc
      2 rate = vc
      2 rate_unit = vc
      2 normalized_rate = vc
      2 normalized_rate_unit = vc
      2 drug_form = vc
      2 quantity_doses_charged = f8
      2 frequency_code = f8
      2 frequency_display = vc
      2 duration = vc
      2 drug_class_code1 = vc
      2 drug_class_description1 = vc
      2 drug_class_code2 = vc
      2 drug_class_description2 = vc
      2 drug_class_code3 = vc
      2 drug_class_description3 = vc
      2 physician_number = vc
      2 personnel_username = vc
      2 admit_dt_tm = dq8
      2 discharge_dt_tm = dq8
      2 mrn = vc
      2 d_number = vc
      2 multm_main_drug_code = i4
      2 multm_flag = i2
      2 data_origin = vc
      2 category_cd = f8
      2 result_status_cd = f8
      2 item_id_flag = i2
      2 template_order_flag = i4
      2 volume_dose_flag = i2
      2 strength_dose_flag = i2
      2 change_rate_flag = i2
  )
 ENDIF
 IF (NOT (validate (charge_credit_data ) ) )
  RECORD charge_credit_data (
    1 qual_cnt = i4
    1 qual [* ]
      2 encntr_id = f8
      2 encntr_alias_id = f8
      2 event_id = f8
      2 clinical_event_id = f8
      2 person_id = f8
      2 person_alias_id = f8
      2 charge_item_id = f8
      2 bill_item_id = f8
      2 bill_item_mod_id = f8
      2 item_id = f8
      2 task_id = f8
      2 organization_id = f8
      2 order_id = f8
      2 order_action_id = f8
      2 order_prod_id = f8
      2 template_order_id = f8
      2 prsnl_alias_id = f8
      2 phys_person_id = f8
      2 ordered_by_id = f8
      2 synonym_id = f8
      2 facility_cd = vc
      2 fin = vc
      2 cmrn = vc
      2 item_number = vc
      2 charge_entered_dt = dq8
      2 charged_dt = dq8
      2 order_display = vc
      2 drug_generic_name = vc
      2 drug_brand_name = vc
      2 strength_dose = vc
      2 strength_dose_unit = vc
      2 route_of_admin = vc
      2 volume_dose = vc
      2 volume_dose_unit = vc
      2 rate = vc
      2 rate_unit = vc
      2 normalized_rate = vc
      2 normalized_rate_unit = vc
      2 drug_form = vc
      2 quantity_doses_charged = f8
      2 frequency_code = f8
      2 frequency_display = vc
      2 duration = vc
      2 drug_class_code1 = vc
      2 drug_class_description1 = vc
      2 drug_class_code2 = vc
      2 drug_class_description2 = vc
      2 drug_class_code3 = vc
      2 drug_class_description3 = vc
      2 physician_number = vc
      2 personnel_username = vc
      2 admit_dt_tm = dq8
      2 discharge_dt_tm = dq8
      2 mrn = vc
      2 d_number = vc
      2 multm_main_drug_code = i4
      2 multm_flag = i2
      2 data_origin = vc
      2 category_cd = f8
      2 result_status_cd = f8
      2 item_id_flag = i2
      2 template_order_flag = i4
      2 volume_dose_flag = i2
      2 strength_dose_flag = i2
      2 change_rate_flag = i2
  )
 ENDIF
 DECLARE getmedamindata (null ) = i2
 DECLARE getacudosedata (null ) = i2
 DECLARE getchargecreditdata (null ) = i2
 DECLARE getchangeratedata (null ) = i2
 DECLARE getorderingredientdata (null ) = i2
 DECLARE getorderproductdata (null ) = i2
 DECLARE getorderdetaildata (null ) = i2
 DECLARE getdrugsynonymdata (null ) = i2
 DECLARE getdrugidentifierdata (null ) = i2
 DECLARE getdrugclassdata (null ) = i2
 DECLARE getchargedata (null ) = i2
 DECLARE getfinmrndata (null ) = i2
 DECLARE getcmrndata (null ) = i2
 DECLARE getphysiciandata (null ) = i2
 DECLARE getorderingusername (null ) = i2
 DECLARE getfacilityalias (null ) = i2
 DECLARE outputtofile (null ) = i2
 DECLARE outputtoscreen (null ) = i2
 IF (NOT (validate (is_ops_job ) ) )
  DECLARE is_ops_job = i2 WITH protect ,noconstant (0 )
  IF (validate (request->batch_selection ) )
   SET is_ops_job = 1
   CALL logmsg (build2 ("IS_OPS_JOB: " ,is_ops_job ) )
  ENDIF
 ENDIF
 IF ((is_ops_job = true ) )
  CALL logmsg ("Extract is being ran from ops..." )
  DECLARE start_dt = dq8 WITH protect ,constant (parsedateoperations ("CURDATE-1" ,"B" ,"B" ) )
  DECLARE end_dt = dq8 WITH protect ,constant (parsedateoperations ("CURDATE-1" ,"E" ,"E" ) )
 ELSE
  CALL logmsg ("Extract is being ran from the front end..." )
  DECLARE start_dt = dq8 WITH protect ,constant (parsedateprompt ( $BEGIN_DT ,curdate ,0 ) )
  DECLARE end_dt = dq8 WITH protect ,constant (parsedateprompt ( $END_DT ,curdate ,235959 ) )
 ENDIF
 CALL logmsg (build2 ("start_dt: " ,format (start_dt ,";;Q" ) ) )
 CALL logmsg (build2 ("end_dt:   " ,format (end_dt ,";;Q" ) ) )
 IF (NOT (getmedamindata (null ) ) )
  CALL logmsg ("Failed to load Med Admin data, going to exit script..." )
  SET display_msg = "Failed to load med admin data"
  GO TO exit_script
 ENDIF
 IF (NOT (getacudosedata (null ) ) )
  CALL logmsg ("Failed to load Acudose data, going to exit script..." )
  SET display_msg = "Failed to load Acudose data"
  GO TO exit_script
 ENDIF
 IF (NOT (getchargecreditdata (null ) ) )
  CALL logmsg ("Failed to load Charge Credit data, going to exit script..." )
  SET display_msg = "Failed to load Charge Credit data"
  GO TO exit_script
 ENDIF
 IF (NOT (getchangeratedata (null ) ) )
  CALL logmsg ("Failed to load Change Rate data, going to exit script..." )
  SET display_msg = "Failed to load Change Rate data"
  GO TO exit_script
 ENDIF
 IF (NOT (getorderingredientdata (null ) ) )
  CALL logmsg ("Failed to load Order Ingredient data, going to exit script..." )
  SET display_msg = "Failed to load Order Ingredient data"
  GO TO exit_script
 ENDIF
 IF (NOT (getorderproductdata (null ) ) )
  CALL logmsg ("Failed to load Order Product data, going to exit script..." )
  SET display_msg = "Failed to load Order Product data"
  GO TO exit_script
 ENDIF
 IF (NOT (getorderdetaildata (null ) ) )
  CALL logmsg ("Failed to load Order Detail data, going to exit script..." )
  SET display_msg = "Failed to load Order Detail data"
  GO TO exit_script
 ENDIF
 IF (NOT (getdrugsynonymdata (null ) ) )
  CALL logmsg ("Failed to load Drug Synonym data, going to exit script..." )
  SET display_msg = "Failed to load Drug Synonym data"
  GO TO exit_script
 ENDIF
 IF (NOT (getdrugidentifierdata (null ) ) )
  CALL logmsg ("Failed to load Drug Identifier data, going to exit script..." )
  SET display_msg = "Failed to load Drug Identifier data"
  GO TO exit_script
 ENDIF
 IF (NOT (getdrugclassdata (null ) ) )
  CALL logmsg ("Failed to load Drug Class data, going to exit script..." )
  SET display_msg = "Failed to load Drug Class data"
  GO TO exit_script
 ENDIF
 IF (NOT (getchargedata (null ) ) )
  CALL logmsg ("Failed to load Charge data, going to exit script..." )
  SET display_msg = "Failed to load Charge data"
  GO TO exit_script
 ENDIF
 IF (NOT (getfinmrndata (null ) ) )
  CALL logmsg ("Failed to load FIN and MRN data, going to exit script..." )
  SET display_msg = "Failed to load FIN and MRN data"
  GO TO exit_script
 ENDIF
 IF (NOT (getcmrndata (null ) ) )
  CALL logmsg ("Failed to load CMRN data, going to exit script..." )
  SET display_msg = "Failed to load CMRN data"
  GO TO exit_script
 ENDIF
 IF (NOT (getphysiciandata (null ) ) )
  CALL logmsg ("Failed to load Physician data, going to exit script..." )
  SET display_msg = "Failed to load Physician data"
  GO TO exit_script
 ENDIF
 IF (NOT (getorderingusername (null ) ) )
  CALL logmsg ("Failed to load ordering personnel username, going to exit script..." )
  SET display_msg = "Failed to load the ordering personnel's username"
  GO TO exit_script
 ENDIF
 IF (NOT (getfacilityalias (null ) ) )
  CALL logmsg ("Failed to load organization alias, going to exit script..." )
  SET display_msg = "Failed to load the organization alias"
  GO TO exit_script
 ENDIF
 IF (( $TO_FILE = active ) )
  CALL logmsg ("Outputting to file..." )
  CALL outputtofile (null )
 ELSE
  CALL logmsg ("Outputting to screen..." )
  CALL outputtoscreen (null )
 ENDIF
 CALL echorecord (pha_data )
 CALL echo ("001 12/28/14 RS049105 CCPS-13468 Initial Release" )
 RETURN
#exit_script
 CALL logmsg ("Creating Exit Script..." )
 SELECT INTO  $OUTDEV
  FROM (dummyt d WITH seq = 1 )
  PLAN (d )
  HEAD REPORT
   "{CPI/9}{FONT/4}" ,
   row 0 ,
   col 0 ,
   CALL print (build2 ("PROGRAM:  " ,cnvtlower (curprog ) ,"       NODE:  " ,curnode ) ) ,
   row + 3 ,
   col 0 ,
   CALL print (display_msg ) ,
   row + 3 ,
   col 0 ,
   CALL print (build2 ("Number of rows of data found: " ,pha_data->qual_cnt ) ) ,
   row + 3 ,
   col 0 ,
   CALL print (build2 ("Execution Date/Time:  " ,format (cnvtdatetime (curdate ,curtime ) ,
     "mm/dd/yyyy hh:mm:ss;;q" ) ) )
  WITH nocounter ,nullreport ,maxcol = 300 ,dio = postscript
 ;end select
 CALL echo ("001 12/28/14 RS049105 CCPS-13468 Initial Release" )
 SUBROUTINE  getmedamindata (null )
  CALL logmsg ("*******Beginning Subroutine: GetMedAminData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE empty = i2 WITH protect ,constant (0 )
  DECLARE strenght_dose = vc WITH protect ,noconstant ("" )
  DECLARE ivparvar_vc = vc WITH protect ,constant ("IVPARENT" )
  DECLARE 8_active_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2627" ) )
  DECLARE 8_modified_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!16901" ) )
  DECLARE 8_auth_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2628" ) )
  DECLARE 8_mod_amend_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2636" ) )
  DECLARE 24_child_reltn_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2661" ) )
  DECLARE 54_vol_ml_result_unit_cd = f8 WITH protect ,constant (getcodewithcheck (
    "CKI.CODEVALUE!3780" ) )
  DECLARE 180_ivwastevar_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!31649" ) )
  DECLARE 180_rate_change_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!31647" )
   )
  DECLARE 180_begin_bag_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!31642" ) )
  DECLARE 6000_pharmacy_var_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!3079" )
   )
  DECLARE 6003_order_action_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!3094" )
   )
  CALL logmsg (build2 ("24_CHILD_RELTN_CD:    " ,24_child_reltn_cd ) )
  CALL logmsg (build2 ("180_IVWASTEVAR_CD:    " ,180_ivwastevar_cd ) )
  CALL logmsg (build2 ("6000_PHARMACY_VAR_CD: " ,6000_pharmacy_var_cd ) )
  CALL logmsg (build2 ("180_RATE_CHANGE_CD:    " ,180_rate_change_cd ) )
  SELECT INTO "nl:"
   FROM (ce_med_result cmr ),
    (clinical_event ce ),
    (encounter e ),
    (orders o ),
    (order_action oa ),
    (task_activity ta )
   PLAN (ce
    WHERE (ce.event_end_dt_tm BETWEEN cnvtdatetime (start_dt ) AND cnvtdatetime (end_dt ) )
    AND (ce.view_level = active )
    AND (ce.publish_flag = active )
    AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (ce.task_assay_cd = empty )
    AND (ce.event_reltn_cd = 24_child_reltn_cd )
    AND (ce.event_title_text != ivparvar_vc )
    AND (ce.result_status_cd IN (8_active_cd ,
    8_modified_cd ,
    8_auth_cd ,
    8_mod_amend_cd ) ) )
    JOIN (cmr
    WHERE (cmr.event_id = outerjoin (ce.event_id ) )
    AND (cmr.event_id != outerjoin (empty ) )
    AND (cmr.valid_until_dt_tm = outerjoin (cnvtdatetime ("31-DEC-2100 00:00:00" ) ) )
    AND (cmr.synonym_id != outerjoin (empty ) )
    AND NOT ((cmr.iv_event_cd IN (180_ivwastevar_cd ,
    180_rate_change_cd ) ) ) )
    JOIN (o
    WHERE (o.order_id = ce.order_id )
    AND (o.catalog_type_cd = 6000_pharmacy_var_cd ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id )
    AND (e.active_ind = active )
    AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence IN (
    (SELECT
     max (oa1.action_sequence )
     FROM (order_action oa1 )
     WHERE (oa1.order_id = oa.order_id ) ) ) ) )
    JOIN (ta
    WHERE (ta.order_id = o.order_id ) )
   ORDER BY ce.order_id
   HEAD REPORT
    cnt = 0
   HEAD ce.order_id
    cnt +=1 ,
    IF ((mod (cnt ,100 ) = 1 ) ) stat = alterlist (pha_data->qual ,(cnt + 99 ) )
    ENDIF
    ,pha_data->qual[cnt ].encntr_id = e.encntr_id ,pha_data->qual[cnt ].event_id = ce.event_id ,
    pha_data->qual[cnt ].clinical_event_id = ce.clinical_event_id ,pha_data->qual[cnt ].person_id = e
    .person_id ,pha_data->qual[cnt ].task_id = ta.task_id ,pha_data->qual[cnt ].order_id = o
    .order_id ,pha_data->qual[cnt ].order_action_id = oa.order_action_id ,pha_data->qual[cnt ].
    phys_person_id = oa.order_provider_id ,pha_data->qual[cnt ].template_order_id = o
    .template_order_id ,pha_data->qual[cnt ].template_order_flag = o.template_order_flag ,pha_data->
    qual[cnt ].organization_id = e.organization_id ,pha_data->qual[cnt ].ordered_by_id = oa
    .action_personnel_id ,
    IF ((pha_data->qual[cnt ].template_order_flag = 4 ) ) pha_data->qual[cnt ].order_prod_id =
     pha_data->qual[cnt ].template_order_id ,pha_data->qual[cnt ].order_id = pha_data->qual[cnt ].
     template_order_id
    ELSE pha_data->qual[cnt ].order_prod_id = pha_data->qual[cnt ].order_id
    ENDIF
    ,
    IF ((o.iv_ind = active ) ) pha_data->qual[cnt ].synonym_id = o.iv_set_synonym_id
    ELSE pha_data->qual[cnt ].synonym_id = o.synonym_id
    ENDIF
    ,
    IF ((cmr.admin_dosage > 0.0 ) ) strength_dose = cnvtstring (cmr.admin_dosage ) ,
     IF ((findstring ("." ,strength_dose ) = 0 ) ) pha_data->qual[cnt ].strength_dose =
      strength_dose
     ELSE pha_data->qual[cnt ].strength_dose = substring (1 ,(findstring ("." ,strength_dose ) + 2 )
       ,strength_dose )
     ENDIF
     ,pha_data->qual[cnt ].strength_dose_unit = uar_get_code_display (cmr.dosage_unit_cd ) ,pha_data
     ->qual[cnt ].strength_dose_flag = 1
    ENDIF
    ,
    IF ((ce.result_units_cd = 54_vol_ml_result_unit_cd ) )
     IF ((cnvtreal (ce.result_val ) != 0.00 ) )
      IF ((findstring ("." ,ce.result_val ) = 0 ) ) pha_data->qual[cnt ].volume_dose = trim (ce
        .result_val ,3 )
      ELSE pha_data->qual[cnt ].volume_dose = substring (1 ,(findstring ("." ,ce.result_val ) + 2 ) ,
        ce.result_val )
      ENDIF
      ,pha_data->qual[cnt ].volume_dose_unit = uar_get_code_display (ce.result_units_cd )
     ENDIF
    ENDIF
    ,pha_data->qual[cnt ].route_of_admin = uar_get_code_display (cmr.admin_route_cd ) ,pha_data->
    qual[cnt ].result_status_cd = ce.result_status_cd ,pha_data->qual[cnt ].charge_entered_dt = ce
    .performed_dt_tm ,pha_data->qual[cnt ].order_display = trim (o.dept_misc_line ,3 ) ,pha_data->
    qual[cnt ].data_origin = "CLINICAL EVENT" ,pha_data->qual[cnt ].admit_dt_tm = e.reg_dt_tm ,
    pha_data->qual[cnt ].discharge_dt_tm = e.disch_dt_tm ,d_pos = findstring ("!d" ,o.cki ) ,
    multm_code_pos = findstring ("!" ,o.cki ) ,cki_len = textlen (o.cki ) ,
    IF ((d_pos > 0 ) ) pha_data->qual[cnt ].d_number = trim (substring ((d_pos + 1 ) ,cki_len ,o.cki
       ) )
    ELSEIF ((multm_code_pos > 0 ) ) multm_code = trim (substring ((multm_code_pos + 1 ) ,cki_len ,o
       .cki ) ) ,pha_data->qual[cnt ].multm_main_drug_code = cnvtint (multm_code ) ,pha_data->qual[
     cnt ].multm_flag = 1
    ENDIF
    ,pha_data->qual[cnt ].category_cd = o.catalog_cd
   FOOT  ce.order_id
    null
   FOOT REPORT
    pha_data->qual_cnt = cnt ,
    stat = alterlist (pha_data->qual ,pha_data->qual_cnt )
   WITH nocounter
  ;end select
  IF (catcherrors ("Error occured in the Clinical Event query!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetMedAminData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getacudosedata (null )
  CALL logmsg ("*******Beginning Subroutine: GetAcudoseData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE empty = i2 WITH protect ,constant (0 )
  DECLARE 89_acudose_contrib_cd = f8 WITH protect ,constant (getcodewithcheck ("DISPLAYKEY" ,89 ,
    "ACUDOSE" ) )
  SELECT INTO "nl:"
   FROM (orders o ),
    (order_action oa ),
    (encounter e )
   PLAN (o
    WHERE (o.orig_order_dt_tm BETWEEN cnvtdatetime (start_dt ) AND cnvtdatetime (end_dt ) )
    AND (o.contributor_system_cd = 89_acudose_contrib_cd )
    AND (o.active_ind = active ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence IN (
    (SELECT
     max (oa1.action_sequence )
     FROM (order_action oa1 )
     WHERE (oa1.order_id = oa.order_id ) ) ) ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id )
    AND (e.active_ind = active ) )
   ORDER BY o.order_id
   HEAD REPORT
    cnt = 0
   HEAD o.order_id
    cnt +=1 ,
    IF ((mod (cnt ,100 ) = 1 ) ) stat = alterlist (acudose_data->qual ,(cnt + 99 ) )
    ENDIF
    ,acudose_data->qual[cnt ].encntr_id = o.encntr_id ,acudose_data->qual[cnt ].person_id = o
    .person_id ,acudose_data->qual[cnt ].order_id = o.order_id ,acudose_data->qual[cnt ].
    phys_person_id = oa.order_provider_id ,acudose_data->qual[cnt ].template_order_id = o
    .template_order_id ,acudose_data->qual[cnt ].template_order_flag = o.template_order_flag ,
    acudose_data->qual[cnt ].organization_id = e.organization_id ,acudose_data->qual[cnt ].
    ordered_by_id = oa.action_personnel_id ,
    IF ((acudose_data->qual[cnt ].template_order_flag = 4 ) ) acudose_data->qual[cnt ].order_prod_id
     = acudose_data->qual[cnt ].template_order_id ,acudose_data->qual[cnt ].order_id = acudose_data->
     qual[cnt ].template_order_id
    ELSE acudose_data->qual[cnt ].order_prod_id = acudose_data->qual[cnt ].order_id
    ENDIF
    ,
    IF ((o.iv_ind = active ) ) acudose_data->qual[cnt ].synonym_id = o.iv_set_synonym_id
    ELSE acudose_data->qual[cnt ].synonym_id = o.synonym_id
    ENDIF
    ,d_pos = findstring ("!d" ,o.cki ) ,multm_code_pos = findstring ("!" ,o.cki ) ,cki_len = textlen
    (o.cki ) ,
    IF ((d_pos > 0 ) ) acudose_data->qual[cnt ].d_number = trim (substring ((d_pos + 1 ) ,cki_len ,o
       .cki ) )
    ELSEIF ((multm_code_pos > 0 ) ) multm_code = trim (substring ((multm_code_pos + 1 ) ,cki_len ,o
       .cki ) ) ,acudose_data->qual[cnt ].multm_main_drug_code = cnvtint (multm_code ) ,acudose_data
     ->qual[cnt ].multm_flag = 1
    ENDIF
    ,acudose_data->qual[cnt ].category_cd = o.catalog_cd ,acudose_data->qual[cnt ].charge_entered_dt
    = o.orig_order_dt_tm ,acudose_data->qual[cnt ].order_display = trim (o.dept_misc_line ,3 ) ,
    acudose_data->qual[cnt ].data_origin = "ACUDOSE" ,acudose_data->qual[cnt ].admit_dt_tm = e
    .reg_dt_tm ,acudose_data->qual[cnt ].discharge_dt_tm = e.disch_dt_tm
   FOOT  o.order_id
    null
   FOOT REPORT
    acudose_data->qual_cnt = cnt ,
    stat = alterlist (acudose_data->qual ,acudose_data->qual_cnt )
   WITH nocounter
  ;end select
  IF (catcherrors ("Error occured in the Acudose query!" ) )
   SET return_ind = 0
  ENDIF
  SET stat = movereclist (acudose_data->qual ,pha_data->qual ,1 ,pha_data->qual_cnt ,acudose_data->
   qual_cnt ,true )
  SET pha_data->qual_cnt = size (pha_data->qual ,5 )
  CALL logmsg ("*******End of Subroutine: GetAcudoseData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getchargecreditdata (null )
  CALL logmsg ("*******Beginning Subroutine: GetChargeCreditData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE empty = i2 WITH protect ,constant (0 )
  DECLARE charge_credit_app_nbr = i4 WITH protect ,constant (390000 )
  SELECT INTO "nl:"
   FROM (orders o ),
    (order_action oa ),
    (application a ),
    (encounter e )
   PLAN (o
    WHERE (o.orig_order_dt_tm BETWEEN cnvtdatetime (start_dt ) AND cnvtdatetime (end_dt ) )
    AND (o.active_ind = active ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence IN (
    (SELECT
     max (oa1.action_sequence )
     FROM (order_action oa1 )
     WHERE (oa1.order_id = oa.order_id ) ) ) ) )
    JOIN (a
    WHERE (a.application_number = oa.order_app_nbr )
    AND (a.application_number = charge_credit_app_nbr ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id )
    AND (e.active_ind = active ) )
   ORDER BY o.order_id
   HEAD REPORT
    cnt = 0
   HEAD o.order_id
    cnt +=1 ,
    IF ((mod (cnt ,100 ) = 1 ) ) stat = alterlist (charge_credit_data->qual ,(cnt + 99 ) )
    ENDIF
    ,charge_credit_data->qual[cnt ].encntr_id = o.encntr_id ,charge_credit_data->qual[cnt ].person_id
     = o.person_id ,charge_credit_data->qual[cnt ].order_id = o.order_id ,charge_credit_data->qual[
    cnt ].phys_person_id = oa.order_provider_id ,charge_credit_data->qual[cnt ].template_order_id = o
    .template_order_id ,charge_credit_data->qual[cnt ].template_order_flag = o.template_order_flag ,
    charge_credit_data->qual[cnt ].organization_id = e.organization_id ,charge_credit_data->qual[cnt
    ].ordered_by_id = oa.action_personnel_id ,
    IF ((charge_credit_data->qual[cnt ].template_order_flag = 4 ) ) charge_credit_data->qual[cnt ].
     order_prod_id = charge_credit_data->qual[cnt ].template_order_id ,charge_credit_data->qual[cnt ]
     .order_id = charge_credit_data->qual[cnt ].template_order_id
    ELSE charge_credit_data->qual[cnt ].order_prod_id = charge_credit_data->qual[cnt ].order_id
    ENDIF
    ,
    IF ((o.iv_ind = active ) ) charge_credit_data->qual[cnt ].synonym_id = o.iv_set_synonym_id
    ELSE charge_credit_data->qual[cnt ].synonym_id = o.synonym_id
    ENDIF
    ,d_pos = findstring ("!d" ,o.cki ) ,multm_code_pos = findstring ("!" ,o.cki ) ,cki_len = textlen
    (o.cki ) ,
    IF ((d_pos > 0 ) ) charge_credit_data->qual[cnt ].d_number = trim (substring ((d_pos + 1 ) ,
       cki_len ,o.cki ) )
    ELSEIF ((multm_code_pos > 0 ) ) multm_code = trim (substring ((multm_code_pos + 1 ) ,cki_len ,o
       .cki ) ) ,charge_credit_data->qual[cnt ].multm_main_drug_code = cnvtint (multm_code ) ,
     charge_credit_data->qual[cnt ].multm_flag = 1
    ENDIF
    ,charge_credit_data->qual[cnt ].category_cd = o.catalog_cd ,charge_credit_data->qual[cnt ].
    charge_entered_dt = o.orig_order_dt_tm ,charge_credit_data->qual[cnt ].order_display = trim (o
     .dept_misc_line ,3 ) ,charge_credit_data->qual[cnt ].data_origin = "CHARGE/CREDIT" ,
    charge_credit_data->qual[cnt ].admit_dt_tm = e.reg_dt_tm ,charge_credit_data->qual[cnt ].
    discharge_dt_tm = e.disch_dt_tm
   FOOT  o.order_id
    null
   FOOT REPORT
    charge_credit_data->qual_cnt = cnt ,
    stat = alterlist (charge_credit_data->qual ,charge_credit_data->qual_cnt )
   WITH nocounter
  ;end select
  SET stat = movereclist (charge_credit_data->qual ,pha_data->qual ,1 ,pha_data->qual_cnt ,
   charge_credit_data->qual_cnt ,true )
  SET pha_data->qual_cnt = size (pha_data->qual ,5 )
  CALL logmsg ("*******End of Subroutine: GetChargeCreditData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getchangeratedata (null )
  CALL logmsg ("*******Beginning Subroutine: GetChangeRateData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE empty = i2 WITH protect ,constant (0 )
  DECLARE ivparvar_vc = vc WITH protect ,constant ("IVPARENT" )
  DECLARE 8_active_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2627" ) )
  DECLARE 8_modified_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!16901" ) )
  DECLARE 8_auth_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2628" ) )
  DECLARE 8_mod_amend_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2636" ) )
  DECLARE 24_child_reltn_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2661" ) )
  DECLARE 54_vol_ml_result_unit_cd = f8 WITH protect ,constant (getcodewithcheck (
    "CKI.CODEVALUE!3780" ) )
  DECLARE 180_ivwastevar_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!31649" ) )
  DECLARE 180_rate_change_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!31647" )
   )
  DECLARE 6000_pharmacy_var_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!3079" )
   )
  CALL logmsg (build2 ("24_CHILD_RELTN_CD:    " ,24_child_reltn_cd ) )
  CALL logmsg (build2 ("180_IVWASTEVAR_CD:    " ,180_ivwastevar_cd ) )
  CALL logmsg (build2 ("6000_PHARMACY_VAR_CD: " ,6000_pharmacy_var_cd ) )
  CALL logmsg (build2 ("180_RATE_CHANGE_CD:    " ,180_rate_change_cd ) )
  SELECT INTO "nl:"
   FROM (ce_med_result cmr ),
    (clinical_event ce ),
    (order_ingredient oi ),
    (encounter e ),
    (orders o ),
    (order_action oa ),
    (task_activity ta )
   PLAN (ce
    WHERE (ce.event_end_dt_tm BETWEEN cnvtdatetime (start_dt ) AND cnvtdatetime (end_dt ) )
    AND (ce.view_level = active )
    AND (ce.publish_flag = active )
    AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (ce.task_assay_cd = empty )
    AND (ce.event_title_text = ivparvar_vc )
    AND (ce.result_status_cd IN (8_active_cd ,
    8_modified_cd ,
    8_auth_cd ,
    8_mod_amend_cd ) ) )
    JOIN (cmr
    WHERE (cmr.event_id = ce.event_id )
    AND (cmr.event_id != empty )
    AND (cmr.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
    AND (cmr.iv_event_cd = 180_rate_change_cd ) )
    JOIN (oi
    WHERE (oi.order_id = ce.order_id )
    AND (oi.ingredient_type_flag = 3 ) )
    JOIN (o
    WHERE (o.order_id = ce.order_id )
    AND (o.catalog_type_cd = 6000_pharmacy_var_cd ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id )
    AND (e.active_ind = active )
    AND (e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence IN (
    (SELECT
     max (oa1.action_sequence )
     FROM (order_action oa1 )
     WHERE (oa1.order_id = oa.order_id ) ) ) ) )
    JOIN (ta
    WHERE (ta.order_id = o.order_id ) )
   ORDER BY o.order_id ,
    ce.result_status_cd ,
    ce.event_id
   HEAD REPORT
    cnt = size (pha_data->qual ,5 )
   HEAD o.order_id
    null
   HEAD ce.result_status_cd
    null
   HEAD ce.event_id
    cnt +=1 ,stat = alterlist (pha_data->qual ,cnt ) ,pha_data->qual[cnt ].encntr_id = e.encntr_id ,
    pha_data->qual[cnt ].event_id = ce.event_id ,pha_data->qual[cnt ].clinical_event_id = ce
    .clinical_event_id ,pha_data->qual[cnt ].person_id = e.person_id ,pha_data->qual[cnt ].task_id =
    ta.task_id ,pha_data->qual[cnt ].order_id = o.order_id ,pha_data->qual[cnt ].order_action_id = oa
    .order_action_id ,pha_data->qual[cnt ].phys_person_id = oa.order_provider_id ,pha_data->qual[cnt
    ].template_order_id = o.template_order_id ,pha_data->qual[cnt ].template_order_flag = o
    .template_order_flag ,pha_data->qual[cnt ].organization_id = e.organization_id ,pha_data->qual[
    cnt ].ordered_by_id = oa.action_personnel_id ,pha_data->qual[cnt ].synonym_id = oi.synonym_id ,
    IF ((pha_data->qual[cnt ].template_order_flag = 4 ) ) pha_data->qual[cnt ].order_prod_id =
     pha_data->qual[cnt ].template_order_id ,pha_data->qual[cnt ].order_id = pha_data->qual[cnt ].
     template_order_id
    ELSE pha_data->qual[cnt ].order_prod_id = pha_data->qual[cnt ].order_id
    ENDIF
    ,pha_data->qual[cnt ].route_of_admin = uar_get_code_display (cmr.admin_route_cd ) ,pha_data->
    qual[cnt ].result_status_cd = ce.result_status_cd ,pha_data->qual[cnt ].charge_entered_dt = ce
    .performed_dt_tm ,pha_data->qual[cnt ].order_display = trim (o.dept_misc_line ,3 ) ,pha_data->
    qual[cnt ].data_origin = "CHANGE RATE" ,pha_data->qual[cnt ].admit_dt_tm = e.reg_dt_tm ,pha_data
    ->qual[cnt ].discharge_dt_tm = e.disch_dt_tm ,pha_data->qual[cnt ].rate = cnvtstring (cmr
     .infusion_rate ,16 ,4 ) ,pha_data->qual[cnt ].rate_unit = uar_get_code_display (cmr
     .infusion_unit_cd ) ,d_pos = findstring ("!d" ,o.cki ) ,multm_code_pos = findstring ("!" ,o.cki
     ) ,cki_len = textlen (o.cki ) ,
    IF ((d_pos > 0 ) ) pha_data->qual[cnt ].d_number = trim (substring ((d_pos + 1 ) ,cki_len ,o.cki
       ) )
    ELSEIF ((multm_code_pos > 0 ) ) multm_code = trim (substring ((multm_code_pos + 1 ) ,cki_len ,o
       .cki ) ) ,pha_data->qual[cnt ].multm_main_drug_code = cnvtint (multm_code ) ,pha_data->qual[
     cnt ].multm_flag = 1
    ENDIF
    ,pha_data->qual[cnt ].category_cd = o.catalog_cd
   FOOT  ce.event_id
    null
   FOOT  ce.result_status_cd
    null
   FOOT  o.order_id
    null
   FOOT REPORT
    pha_data->qual_cnt = cnt ,
    stat = alterlist (pha_data->qual ,pha_data->qual_cnt )
   WITH expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetChangeRateData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetChangeRateData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getorderingredientdata (null )
  CALL logmsg ("*******Beginning Subroutine: GetOrderIngredientData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE volume_dose = vc WITH protect ,noconstant ("" )
  DECLARE volume_dose_unit = vc WITH protect ,noconstant ("" )
  DECLARE strength_dose = vc WITH protect ,noconstant ("" )
  DECLARE strength_dose_unit = vc WITH protect ,noconstant ("" )
  DECLARE normalized_rate = vc WITH protect ,noconstant ("" )
  DECLARE normalized_rate_unit = vc WITH protect ,noconstant ("" )
  SELECT INTO "nl:"
   FROM (order_ingredient oi )
   PLAN (oi
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,oi.order_id ,pha_data->qual[expand_idx ].
     order_id ) )
   ORDER BY oi.order_id ,
    oi.synonym_id ,
    oi.action_sequence DESC
   HEAD oi.order_id
    null
   HEAD oi.synonym_id
    volume_dose = "" ,volume_dose_unit = "" ,strength_dose = "" ,strength_dose_unit = "" ,
    normalized_rate = "" ,normalized_rate_unit = ""
   DETAIL
    volume_dose = build (oi.volume ) ,
    volume_dose_unit = trim (uar_get_code_display (oi.volume_unit ) ,3 ) ,
    strength_dose = build (oi.strength ) ,
    strength_dose_unit = trim (uar_get_code_display (oi.strength_unit ) ,3 ) ,
    normalized_rate = build (oi.normalized_rate ) ,
    normalized_rate_unit = trim (uar_get_code_display (oi.normalized_rate_unit_cd ) ,3 )
   FOOT  oi.synonym_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,oi.order_id ,pha_data->qual[locate_idx ].
     order_id ) ,
    WHILE ((pos > 0 ) )
     IF ((textlen (trim (pha_data->qual[pos ].volume_dose ,3 ) ) = 0 ) )
      IF ((cnvtreal (volume_dose ) != 0.00 ) )
       IF ((findstring ("." ,volume_dose ) = 0 ) ) pha_data->qual[pos ].volume_dose = volume_dose
       ELSE pha_data->qual[pos ].volume_dose = substring (1 ,(findstring ("." ,volume_dose ) + 2 ) ,
         volume_dose )
       ENDIF
       ,pha_data->qual[pos ].volume_dose_unit = volume_dose_unit ,pha_data->qual[pos ].
       volume_dose_flag = 1
      ENDIF
     ENDIF
     ,
     IF ((textlen (trim (pha_data->qual[pos ].strength_dose ,3 ) ) = 0 ) )
      IF ((cnvtreal (strength_dose ) != 0.00 ) )
       IF ((findstring ("." ,strength_dose ) = 0 ) ) pha_data->qual[pos ].strength_dose =
        strength_dose
       ELSE pha_data->qual[pos ].strength_dose = substring (1 ,(findstring ("." ,strength_dose ) + 2
         ) ,strength_dose )
       ENDIF
       ,pha_data->qual[pos ].strength_dose_unit = strength_dose_unit ,pha_data->qual[pos ].
       strength_dose_flag = 1
      ENDIF
     ENDIF
     ,
     IF ((textlen (trim (pha_data->qual[pos ].normalized_rate ,3 ) ) = 0 ) )
      IF ((cnvtreal (normalized_rate ) != 0.0 ) )
       IF ((findstring ("." ,normalized_rate ) = 0 ) ) pha_data->qual[pos ].normalized_rate =
        normalized_rate
       ELSE pha_data->qual[pos ].normalized_rate = substring (1 ,(findstring ("." ,normalized_rate )
         + 2 ) ,normalized_rate )
       ENDIF
       ,pha_data->qual[pos ].normalized_rate_unit = normalized_rate_unit
      ENDIF
     ENDIF
     ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,oi.order_id ,pha_data->qual[
      locate_idx ].order_id )
    ENDWHILE
   FOOT  oi.order_id
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetOrderIngredientData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetOrderIngredientData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getorderproductdata (null )
  CALL logmsg ("*******Beginning Subroutine: GetOrderProductData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE 8_inerror_result_status_cd = f8 WITH protect ,constant (getcodewithcheck (
    "CKI.CODEVALUE!7982" ) )
  CALL logmsg (build2 ("8_inerror_result_status_cd: " ,8_inerror_result_status_cd ) )
  SELECT INTO "nl:"
   FROM (order_product op )
   PLAN (op
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,op.order_id ,pha_data->qual[expand_idx ].
     order_prod_id )
    AND (op.ingred_sequence = 1 ) )
   ORDER BY op.order_id ,
    op.action_sequence DESC
   HEAD op.order_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,op.order_id ,pha_data->qual[locate_idx ].
     order_prod_id ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].item_id = op.item_id ,
     IF ((pha_data->qual[pos ].item_id > 0 ) ) pha_data->qual[pos ].item_id_flag = 1
     ENDIF
     ,
     IF ((pha_data->qual[pos ].result_status_cd = 8_inerror_result_status_cd ) ) pha_data->qual[pos ]
      .volume_dose = cnvtstring (ceil ((op.dose_quantity * - (1 ) ) ) ) ,pha_data->qual[pos ].
      volume_dose_unit = uar_get_code_display (op.dose_quantity_unit_cd )
     ELSE pha_data->qual[pos ].volume_dose = cnvtstring (ceil (op.dose_quantity ) ) ,pha_data->qual[
      pos ].volume_dose_unit = uar_get_code_display (op.dose_quantity_unit_cd )
     ENDIF
     ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,op.order_id ,pha_data->qual[
      locate_idx ].order_prod_id )
    ENDWHILE
   HEAD op.action_sequence
    null
   FOOT  op.action_sequence
    null
   FOOT  op.order_id
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetOrderProductData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetOrderProductData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getorderdetaildata (null )
  CALL logmsg ("*******Beginning Subroutine: GetOrderDetailData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE frequency_code = f8 WITH protect ,noconstant (0.0 )
  DECLARE frequency = vc WITH protect ,noconstant ("" )
  DECLARE strength_dose = vc WITH protect ,noconstant ("" )
  DECLARE strength_dose_unit = vc WITH protect ,noconstant ("" )
  DECLARE volume_dose = vc WITH protect ,noconstant ("" )
  DECLARE volume_dose_unit = vc WITH protect ,noconstant ("" )
  DECLARE drug_form = vc WITH protect ,noconstant ("" )
  DECLARE duration = vc WITH protect ,noconstant ("" )
  DECLARE duration_unit = vc WITH protect ,noconstant ("" )
  DECLARE rate = vc WITH protect ,noconstant ("" )
  DECLARE rate_unit = vc WITH protect ,noconstant ("" )
  DECLARE route = vc WITH protect ,noconstant ("" )
  DECLARE oe_freq = f8 WITH protect ,constant (12690.00 )
  DECLARE oe_strengthdose = f8 WITH protect ,constant (12715.00 )
  DECLARE oe_strengthdoseunit = f8 WITH protect ,constant (12716.00 )
  DECLARE oe_volumedose = f8 WITH protect ,constant (12718.00 )
  DECLARE oe_volumedoseunit = f8 WITH protect ,constant (12719.00 )
  DECLARE oe_drugform = f8 WITH protect ,constant (12693.00 )
  DECLARE oe_duration = f8 WITH protect ,constant (12721.00 )
  DECLARE oe_durationunit = f8 WITH protect ,constant (12723.00 )
  DECLARE oe_rxroute = f8 WITH protect ,constant (12711.00 )
  DECLARE oe_rate = f8 WITH protect ,constant (12704.00 )
  DECLARE oe_rate_unit = f8 WITH protect ,constant (633585.00 )
  SELECT INTO "nl:"
   FROM (order_detail od )
   PLAN (od
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,od.order_id ,pha_data->qual[expand_idx ].
     order_id )
    AND (od.oe_field_id IN (oe_freq ,
    oe_strengthdose ,
    oe_strengthdoseunit ,
    oe_volumedose ,
    oe_volumedoseunit ,
    oe_drugform ,
    oe_duration ,
    oe_durationunit ,
    oe_rate ,
    oe_rate_unit ,
    oe_rxroute ) ) )
   ORDER BY od.order_id ,
    od.oe_field_id
   HEAD od.order_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,od.order_id ,pha_data->qual[locate_idx ].
     order_id ) ,frequency_code = 0.0 ,frequency = "" ,strength_dose = "" ,strength_dose_unit = "" ,
    volume_dose = "" ,volume_dose_unit = "" ,drug_form = "" ,duration = "" ,duration_unit = "" ,rate
    = "" ,rate_unit = "" ,route = ""
   HEAD od.oe_field_id
    CASE (od.oe_field_id )
     OF oe_freq :
      frequency_code = od.oe_field_value ,
      frequency = trim (od.oe_field_display_value ,3 )
     OF oe_strengthdose :
      strength_dose = trim (od.oe_field_display_value ,3 )
     OF oe_strengthdoseunit :
      strength_dose_unit = trim (od.oe_field_display_value ,3 )
     OF oe_volumedose :
      volume_dose = trim (od.oe_field_display_value ,3 )
     OF oe_volumedoseunit :
      volume_dose_unit = trim (od.oe_field_display_value ,3 )
     OF oe_drugform :
      drug_form = trim (od.oe_field_display_value ,3 )
     OF oe_duration :
      duration = trim (od.oe_field_display_value ,3 )
     OF oe_durationunit :
      duration_unit = trim (od.oe_field_display_value ,3 )
     OF oe_rate :
      rate = trim (od.oe_field_display_value ,3 )
     OF oe_rate_unit :
      rate_unit = trim (od.oe_field_display_value ,3 )
     OF oe_rxroute :
      route = trim (od.oe_field_display_value ,3 )
    ENDCASE
   FOOT  od.oe_field_id
    null
   FOOT  od.order_id
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].frequency_code = frequency_code ,pha_data->qual[pos ].frequency_display =
     frequency ,
     IF ((textlen (trim (strength_dose ,3 ) ) = 0 )
     AND (textlen (trim (pha_data->qual[pos ].strength_dose ,3 ) ) = 0 ) ) pha_data->qual[pos ].
      strength_dose = strength_dose
     ENDIF
     ,
     IF ((textlen (trim (strength_dose_unit ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].strength_dose_unit ,3 ) ) = 0 ) ) pha_data->qual[pos ].
      strength_dose_unit = strength_dose_unit
     ENDIF
     ,
     IF ((textlen (trim (volume_dose ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].volume_dose ,3 ) ) = 0 ) ) pha_data->qual[pos ].
      volume_dose = volume_dose
     ENDIF
     ,
     IF ((textlen (trim (volume_dose_unit ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].volume_dose_unit ,3 ) ) = 0 ) ) pha_data->qual[pos ].
      volume_dose_unit = volume_dose_unit
     ENDIF
     ,
     IF ((textlen (trim (route ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].route_of_admin ,3 ) ) = 0 ) ) pha_data->qual[pos ].
      route_of_admin = route
     ENDIF
     ,
     IF ((textlen (trim (drug_form ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].drug_form ,3 ) ) = 0 ) ) pha_data->qual[pos ].drug_form
       = drug_form
     ENDIF
     ,
     IF ((textlen (trim (duration ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].duration ,3 ) ) = 0 ) ) pha_data->qual[pos ].duration
      = build2 (duration ," " ,duration_unit )
     ENDIF
     ,
     IF ((textlen (trim (rate ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].rate ,3 ) ) = 0 ) ) pha_data->qual[pos ].rate = rate
     ENDIF
     ,
     IF ((textlen (trim (rate_unit ,3 ) ) != 0 )
     AND (textlen (trim (pha_data->qual[pos ].rate_unit ,3 ) ) = 0 ) ) pha_data->qual[pos ].rate_unit
       = rate_unit
     ENDIF
     ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,od.order_id ,pha_data->qual[
      locate_idx ].order_id )
    ENDWHILE
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetOrderDetailData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetOrderDetailData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getdrugsynonymdata (null )
  CALL logmsg ("*******Beginning Subroutine: GetOrderDetailData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE empty = i2 WITH protect ,constant (0 )
  SELECT INTO "nl:"
   FROM (order_catalog_synonym ocs )
   PLAN (ocs
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,ocs.synonym_id ,pha_data->qual[expand_idx ].
     synonym_id ) )
   ORDER BY ocs.synonym_id
   HEAD ocs.synonym_id
    pos = locateval (locate_idx ,pos ,pha_data->qual_cnt ,ocs.synonym_id ,pha_data->qual[locate_idx ]
     .synonym_id ) ,
    WHILE ((pos > 0 ) )
     IF ((pha_data->qual[pos ].item_id < 1 ) ) pha_data->qual[pos ].item_id = ocs.item_id ,
      IF ((pha_data->qual[pos ].item_id > 0 ) ) pha_data->qual[pos ].item_id_flag = 1
      ENDIF
     ENDIF
     ,
     IF ((textlen (trim (pha_data->qual[pos ].order_display ,3 ) ) = 0 ) ) pha_data->qual[pos ].
      order_display = trim (ocs.mnemonic ,3 )
     ENDIF
     ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,ocs.synonym_id ,pha_data->qual[
      locate_idx ].synonym_id )
    ENDWHILE
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetOrderDetailData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetOrderDetailData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getdrugidentifierdata (null )
  CALL logmsg ("*******Beginning Subroutine: GetDrugIdentifierData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE empty = i2 WITH protect ,constant (0 )
  DECLARE drug_brand_name = vc WITH protect ,noconstant ("" )
  DECLARE drug_generic_name = vc WITH protect ,noconstant ("" )
  DECLARE item_number = vc WITH protect ,noconstant ("" )
  DECLARE 11000_brandname_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!3303" ) )
  DECLARE 11000_chargenumber_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!3304"
    ) )
  DECLARE 11000_genericname_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!3294" )
   )
  CALL logmsg (build2 ("11000_BRANDNAME_CD:    " ,11000_brandname_cd ) )
  CALL logmsg (build2 ("11000_CHARGENUMBER_CD: " ,11000_chargenumber_cd ) )
  CALL logmsg (build2 ("11000_GENERICNAME_CD:  " ,11000_genericname_cd ) )
  SELECT INTO "nl:"
   FROM (med_identifier mi )
   PLAN (mi
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,mi.item_id ,pha_data->qual[expand_idx ].item_id
     ,1 ,pha_data->qual[expand_idx ].item_id_flag )
    AND (mi.primary_ind = active )
    AND (mi.med_product_id = empty )
    AND (mi.med_identifier_type_cd IN (11000_brandname_cd ,
    11000_chargenumber_cd ,
    11000_genericname_cd ) )
    AND (mi.active_ind = active ) )
   ORDER BY mi.item_id ,
    mi.med_identifier_type_cd
   HEAD mi.item_id
    drug_brand_name = "" ,item_number = "" ,drug_generic_name = "" ,pos = locateval (locate_idx ,1 ,
     pha_data->qual_cnt ,mi.item_id ,pha_data->qual[locate_idx ].item_id ,1 ,pha_data->qual[
     locate_idx ].item_id_flag )
   HEAD mi.med_identifier_type_cd
    CASE (mi.med_identifier_type_cd )
     OF 11000_brandname_cd :
      drug_brand_name = trim (mi.value ,3 )
     OF 11000_chargenumber_cd :
      item_number = trim (mi.value ,3 )
     OF 11000_genericname_cd :
      drug_generic_name = trim (mi.value ,3 )
    ENDCASE
   FOOT  mi.med_identifier_type_cd
    null
   FOOT  mi.item_id
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].drug_brand_name = drug_brand_name ,pha_data->qual[pos ].item_number =
     item_number ,pha_data->qual[pos ].drug_generic_name = drug_generic_name ,pos = locateval (
      locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,mi.item_id ,pha_data->qual[locate_idx ].item_id ,1
      ,pha_data->qual[locate_idx ].item_id_flag )
    ENDWHILE
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetDrugIdentifierData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetDrugIdentifierData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getdrugclassdata (null )
  CALL logmsg ("*******Beginning Subroutine: GetDrugClassData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE theraputic_class = i4 WITH protect ,constant (2 )
  DECLARE empty = f8 WITH protect ,constant (0.0 )
  DECLARE drug_cat1 = vc WITH protect ,noconstant ("" )
  DECLARE drug_desc1 = vc WITH protect ,noconstant ("" )
  DECLARE drug_cat2 = vc WITH protect ,noconstant ("" )
  DECLARE drug_desc2 = vc WITH protect ,noconstant ("" )
  DECLARE drug_cat3 = vc WITH protect ,noconstant ("" )
  DECLARE drug_desc3 = vc WITH protect ,noconstant ("" )
  SELECT INTO "nl:"
   FROM (mltm_mmdc_name_map mmnm ),
    (mltm_drug_name mdn ),
    (mltm_drug_name_map mdnm ),
    (mltm_drug_id mdi )
   PLAN (mmnm
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,mmnm.main_multum_drug_code ,pha_data->qual[
     expand_idx ].multm_main_drug_code ,1 ,pha_data->qual[expand_idx ].multm_flag ) )
    JOIN (mdn
    WHERE (mmnm.drug_synonym_id = mdn.drug_synonym_id ) )
    JOIN (mdnm
    WHERE (mdnm.drug_synonym_id = mdn.drug_synonym_id ) )
    JOIN (mdi
    WHERE (mdi.drug_identifier = mdnm.drug_identifier ) )
   ORDER BY mmnm.main_multum_drug_code
   HEAD REPORT
    pos = 0
   HEAD mmnm.main_multum_drug_code
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,mmnm.main_multum_drug_code ,pha_data->qual[
     locate_idx ].multm_main_drug_code ,1 ,pha_data->qual[locate_idx ].multm_flag ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].d_number = mdnm.drug_identifier ,pos = locateval (locate_idx ,(pos + 1 ) ,
      pha_data->qual_cnt ,mmnm.main_multum_drug_code ,pha_data->qual[locate_idx ].
      multm_main_drug_code ,1 ,pha_data->qual[locate_idx ].multm_flag )
    ENDWHILE
   FOOT  mmnm.main_multum_drug_code
    null
   WITH expand = 1
  ;end select
  SELECT INTO "nl:"
   mcdx.drug_identifier ,
   dc1.multum_category_id ,
   parent_category = substring (1 ,50 ,dc1.category_name ) ,
   dc2.multum_category_id ,
   sub_category = substring (1 ,50 ,dc2.category_name ) ,
   dc3.multum_category_id ,
   sub_sub_category = substring (1 ,50 ,dc3.category_name )
   FROM (mltm_drug_categories dc1 ),
    (mltm_category_drug_xref mcdx ),
    (mltm_category_sub_xref dcs1 ),
    (mltm_drug_categories dc2 ),
    (mltm_category_sub_xref dcs2 ),
    (mltm_drug_categories dc3 )
   PLAN (dc1
    WHERE NOT (EXISTS (
    (SELECT
     mcsx.multum_category_id
     FROM (mltm_category_sub_xref mcsx )
     WHERE (mcsx.sub_category_id = dc1.multum_category_id ) ) ) ) )
    JOIN (dcs1
    WHERE (dc1.multum_category_id = dcs1.multum_category_id ) )
    JOIN (dc2
    WHERE (dcs1.sub_category_id = dc2.multum_category_id ) )
    JOIN (dcs2
    WHERE (dcs2.multum_category_id = outerjoin (dc2.multum_category_id ) ) )
    JOIN (dc3
    WHERE (dc3.multum_category_id = outerjoin (dcs2.sub_category_id ) ) )
    JOIN (mcdx
    WHERE (((mcdx.multum_category_id = dc1.multum_category_id ) ) OR ((((mcdx.multum_category_id =
    dc2.multum_category_id ) ) OR ((mcdx.multum_category_id = dc3.multum_category_id ) )) ))
    AND expand (expand_idx ,1 ,pha_data->qual_cnt ,mcdx.drug_identifier ,pha_data->qual[expand_idx ].
     d_number ) )
   ORDER BY mcdx.drug_identifier
   HEAD mcdx.drug_identifier
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,mcdx.drug_identifier ,pha_data->qual[
     locate_idx ].d_number ) ,
    WHILE ((pos > 0 ) )
     IF ((dc1.multum_category_id != empty ) ) pha_data->qual[pos ].drug_class_code1 = trim (
       cnvtstring (dc1.multum_category_id ) ,3 ) ,pha_data->qual[pos ].drug_class_description1 = dc1
      .category_name
     ENDIF
     ,
     IF ((dc2.multum_category_id != empty ) ) pha_data->qual[pos ].drug_class_code2 = trim (
       cnvtstring (dc2.multum_category_id ) ,3 ) ,pha_data->qual[pos ].drug_class_description2 = dc2
      .category_name
     ENDIF
     ,
     IF ((dc3.multum_category_id != empty ) ) pha_data->qual[pos ].drug_class_code3 = trim (
       cnvtstring (dc3.multum_category_id ) ,3 ) ,pha_data->qual[pos ].drug_class_description3 = dc3
      .category_name
     ENDIF
     ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,mcdx.drug_identifier ,pha_data->
      qual[locate_idx ].d_number )
    ENDWHILE
   FOOT  mcdx.drug_identifier
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetDrugClassData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetDrugClassData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getchargedata (null )
  CALL logmsg ("*******Beginning Subroutine: GetChargeData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (dispense_hx d )
   PLAN (d
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,d.order_id ,pha_data->qual[expand_idx ].order_id
      )
    AND (d.charge_ind = active ) )
   ORDER BY d.order_id
   HEAD d.order_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,d.order_id ,pha_data->qual[locate_idx ].
     order_id ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].charged_dt = d.charge_dt_tm ,pha_data->qual[pos ].quantity_doses_charged =
     d.doses ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,d.order_id ,pha_data->
      qual[locate_idx ].order_id )
    ENDWHILE
   FOOT  d.order_id
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetChargeData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetChargeData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getfinmrndata (null )
  CALL logmsg ("*******Beginning Subroutine: GetFINMRNData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE finnbr = vc WITH protect ,noconstant ("" )
  DECLARE mrn = vc WITH protect ,noconstant ("" )
  DECLARE 319_finnbr_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!2930" ) )
  DECLARE 319_mrn_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!8021" ) )
  CALL logmsg (build2 ("319_FINNBR_CD: " ,319_finnbr_cd ) )
  CALL logmsg (build2 ("319_MRN_CD:    " ,319_mrn_cd ) )
  SELECT INTO "nl:"
   FROM (encntr_alias ea )
   PLAN (ea
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,ea.encntr_id ,pha_data->qual[expand_idx ].
     encntr_id )
    AND (ea.encntr_alias_type_cd IN (319_finnbr_cd ,
    319_mrn_cd ) )
    AND (ea.active_ind = active )
    AND (ea.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ea.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY ea.encntr_id ,
    ea.encntr_alias_type_cd
   HEAD ea.encntr_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,ea.encntr_id ,pha_data->qual[locate_idx ].
     encntr_id ) ,mrn = "" ,fin = ""
   HEAD ea.encntr_alias_type_cd
    pha_data->qual[pos ].encntr_alias_id = ea.encntr_alias_id ,
    CASE (ea.encntr_alias_type_cd )
     OF 319_finnbr_cd :
      finnbr = trim (ea.alias ,3 )
     OF 319_mrn_cd :
      mrn = trim (ea.alias ,3 )
    ENDCASE
   FOOT  ea.encntr_alias_type_cd
    null
   FOOT  ea.encntr_id
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].fin = finnbr ,pha_data->qual[pos ].mrn = mrn ,pos = locateval (locate_idx ,
      (pos + 1 ) ,pha_data->qual_cnt ,ea.encntr_id ,pha_data->qual[locate_idx ].encntr_id )
    ENDWHILE
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetFINMRNData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetFINMRNData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getcmrndata (null )
  CALL logmsg ("*******Beginning Subroutine: GetCMRNData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE 263_cmrn_cd = f8 WITH protect ,constant (getcodewithcheck ("DISPLAYKEY" ,263 ,"CMRN" ) )
  CALL logmsg (build2 ("263_CMRN_CD: " ,263_cmrn_cd ) )
  SELECT INTO "nl:"
   FROM (person_alias pa )
   PLAN (pa
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,pa.person_id ,pha_data->qual[expand_idx ].
     person_id )
    AND (pa.alias_pool_cd = 263_cmrn_cd )
    AND (pa.active_ind = active )
    AND (pa.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (pa.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY pa.person_id
   HEAD pa.person_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,pa.person_id ,pha_data->qual[locate_idx ].
     person_id ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].person_alias_id = pa.person_alias_id ,pha_data->qual[pos ].cmrn = trim (pa
      .alias ,3 ) ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,pa.person_id ,
      pha_data->qual[locate_idx ].person_id )
    ENDWHILE
   FOOT  pa.person_id
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetCMRNData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetCMRNData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getphysiciandata (null )
  CALL logmsg ("*******Beginning Subroutine: GetPhysicianData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE 263_star_cd = f8 WITH protect ,constant (getcodewithcheck ("DISPLAYKEY" ,263 ,
    "STARDOCTORNUMBER" ) )
  DECLARE 320_org_doc_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!6664" ) )
  DECLARE 333_attending_cd = f8 WITH protect ,constant (getcodewithcheck ("CKI.CODEVALUE!4024" ) )
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr ),
    (prsnl_alias pa )
   PLAN (epr
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,epr.encntr_id ,pha_data->qual[expand_idx ].
     encntr_id )
    AND (epr.encntr_prsnl_r_cd = 333_attending_cd )
    AND (epr.active_ind = active )
    AND (epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (epr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (pa
    WHERE (pa.person_id = epr.prsnl_person_id )
    AND (pa.alias_pool_cd = 263_star_cd )
    AND (pa.prsnl_alias_type_cd = 320_org_doc_cd )
    AND (pa.active_ind = active )
    AND (pa.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (pa.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY epr.encntr_id
   HEAD epr.encntr_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,epr.encntr_id ,pha_data->qual[locate_idx ].
     encntr_id ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].prsnl_alias_id = pa.prsnl_alias_id ,pha_data->qual[pos ].physician_number
     = trim (pa.alias ,3 ) ,pos = locateval (locate_idx ,(pos + 1 ) ,pha_data->qual_cnt ,epr
      .encntr_id ,pha_data->qual[locate_idx ].encntr_id )
    ENDWHILE
   FOOT  epr.encntr_id
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetPhysicianData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetPhysicianData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getorderingusername (null )
  CALL logmsg ("*******Beginning Subroutine: GetPhysicianData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (prsnl p )
   PLAN (p
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,p.person_id ,pha_data->qual[expand_idx ].
     ordered_by_id )
    AND (p.active_ind = active )
    AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY p.person_id
   HEAD p.person_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,p.person_id ,pha_data->qual[locate_idx ].
     ordered_by_id ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].personnel_username = trim (p.username ,3 ) ,pos = locateval (locate_idx ,(
      pos + 1 ) ,pha_data->qual_cnt ,p.person_id ,pha_data->qual[locate_idx ].ordered_by_id )
    ENDWHILE
   FOOT  p.person_id
    null
   WITH nocounter ,expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetPhysicianData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetPhysicianData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  getfacilityalias (null )
  CALL logmsg ("*******Beginning Subroutine: GetPhysicianData(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE expand_idx = i4 WITH protect ,noconstant (0 )
  DECLARE locate_idx = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE 263_strata_alias_cd = f8 WITH protect ,constant (getcodewithcheck ("DISPLAYKEY" ,263 ,
    "STRATAPHARMACYORGIDS" ) )
  SELECT INTO "nl:"
   FROM (organization_alias oa )
   PLAN (oa
    WHERE expand (expand_idx ,1 ,pha_data->qual_cnt ,oa.organization_id ,pha_data->qual[expand_idx ].
     organization_id )
    AND (oa.alias_pool_cd = 263_strata_alias_cd )
    AND (oa.active_ind = active )
    AND (oa.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (oa.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY oa.organization_id
   HEAD oa.organization_id
    pos = locateval (locate_idx ,1 ,pha_data->qual_cnt ,oa.organization_id ,pha_data->qual[
     locate_idx ].organization_id ) ,
    WHILE ((pos > 0 ) )
     pha_data->qual[pos ].facility_cd = trim (oa.alias ,3 ) ,pos = locateval (locate_idx ,(pos + 1 )
      ,pha_data->qual_cnt ,oa.organization_id ,pha_data->qual[locate_idx ].organization_id )
    ENDWHILE
   FOOT  oa.organization_id
    null
   WITH expand = 1
  ;end select
  IF (catcherrors ("Error occured in the GetPhysicianData(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: GetPhysicianData(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  outputtofile (null )
  CALL logmsg ("*******Beginning Subroutine: OutputToFile(null) = i2*******" )
  RECORD cclio_rec (
    1 file_desc = i4
    1 file_name = vc
    1 file_buf = vc
    1 file_dir = i4
    1 file_offset = i4
  ) WITH protect
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  DECLARE data_idx = i4 WITH protect ,noconstant (0 )
  DECLARE logical_dir = vc WITH protect ,noconstant ("" )
  SET logical logical_dir
  "/cerner/w_custom/b0665_cust/to_client_site/ClinicalAncillary/Pharmacy/PAExports/Cov_PNI_PharmacyScorecard.txt"
  DECLARE extract_filename = vc WITH protect ,constant (concat ("cov_pni_pharmacyscorecard.txt" ) )
  DECLARE output_string = vc WITH protect ,noconstant ("" )
  DECLARE file_directory = vc WITH protect ,constant (build (logical ("cer_temp" ) ) )
  DECLARE full_file_path = vc WITH protect ,noconstant ("" )
  DECLARE carriage_return = c1 WITH protect ,constant (char (13 ) )
  DECLARE line_feed = c1 WITH protect ,constant (char (10 ) )
  DECLARE file_delimiter = c1 WITH protect ,constant ("|" )
  DECLARE file_header = vc WITH protect ,constant (build2 ("Facility Code" ,file_delimiter ,
    "Hospital Account Number" ,file_delimiter ,"Master Patient Account" ,file_delimiter ,
    "HMM Item Number" ,file_delimiter ,"Date of Charged Entered" ,file_delimiter ,"Date Charged" ,
    file_delimiter ,"Prescription Number" ,file_delimiter ,"Drug Generic Name" ,file_delimiter ,
    "Brand Name" ,file_delimiter ,"Strength Dose" ,file_delimiter ,"Strength Dose Unit" ,
    file_delimiter ,"Route of Admin" ,file_delimiter ,"Volume Dose" ,file_delimiter ,
    "Volume Dose Unit" ,file_delimiter ,"Rate" ,file_delimiter ,"Rate Unit" ,file_delimiter ,
    "Drug Form" ,file_delimiter ,"Quantity of Doses Charged" ,file_delimiter ,"Frequency Code" ,
    file_delimiter ,"Frequency Code Description" ,file_delimiter ,"Number of Doses for Therapy" ,
    file_delimiter ,"Drug Class Level 1" ,file_delimiter ,"Drug Class Description 1" ,file_delimiter
    ,"Drug Class Level 2" ,file_delimiter ,"Drug Class Description 2" ,file_delimiter ,
    "Drug Class Level 3" ,file_delimiter ,"Drug Class Description 3" ,file_delimiter ,
    "Physician Number" ,file_delimiter ,"Entering Personnel Identifier" ,file_delimiter ,
    "Admit Date Time" ,file_delimiter ,"Discharge Date Time" ,file_delimiter ,carriage_return ,
    line_feed ) )
  SET full_file_path = "logical_dir"
  SET cclio_rec->file_name = full_file_path
  CALL logmsg (build2 ("Full File Path: " ,full_file_path ) )
  CALL logmsg (build2 ("Current Node:   " ,curnode ) )
  SET cclio_rec->file_buf = "w"
  SET stat = cclio ("OPEN" ,cclio_rec )
  CALL logmsg (build2 ("Open File Stat: " ,stat ) )
  SET cclio_rec->file_buf = file_header
  SET stat = cclio ("WRITE" ,cclio_rec )
  FOR (data_idx = 1 TO pha_data->qual_cnt )
   SET output_string = build (pha_data->qual[data_idx ].facility_cd ,file_delimiter ,pha_data->qual[
    data_idx ].mrn ,file_delimiter ,pha_data->qual[data_idx ].fin ,file_delimiter ,pha_data->qual[
    data_idx ].item_number ,file_delimiter ,format (pha_data->qual[data_idx ].charge_entered_dt ,
     date_time_fmt ) ,file_delimiter ,format (pha_data->qual[data_idx ].charged_dt ,date_time_fmt ) ,
    file_delimiter ,pha_data->qual[data_idx ].order_id ,file_delimiter ,pha_data->qual[data_idx ].
    drug_generic_name ,file_delimiter ,pha_data->qual[data_idx ].drug_brand_name ,file_delimiter ,
    pha_data->qual[data_idx ].strength_dose ,file_delimiter ,pha_data->qual[data_idx ].
    strength_dose_unit ,file_delimiter ,pha_data->qual[data_idx ].route_of_admin ,file_delimiter ,
    pha_data->qual[data_idx ].volume_dose ,file_delimiter ,pha_data->qual[data_idx ].volume_dose_unit
     ,file_delimiter ,pha_data->qual[data_idx ].rate ,file_delimiter ,pha_data->qual[data_idx ].
    rate_unit ,file_delimiter ,pha_data->qual[data_idx ].drug_form ,file_delimiter ,pha_data->qual[
    data_idx ].quantity_doses_charged ,file_delimiter ,pha_data->qual[data_idx ].frequency_code ,
    file_delimiter ,pha_data->qual[data_idx ].frequency_display ,file_delimiter ,pha_data->qual[
    data_idx ].duration ,file_delimiter ,pha_data->qual[data_idx ].drug_class_code1 ,file_delimiter ,
    pha_data->qual[data_idx ].drug_class_description1 ,file_delimiter ,pha_data->qual[data_idx ].
    drug_class_code2 ,file_delimiter ,pha_data->qual[data_idx ].drug_class_description2 ,
    file_delimiter ,pha_data->qual[data_idx ].drug_class_code3 ,file_delimiter ,pha_data->qual[
    data_idx ].drug_class_description3 ,file_delimiter ,pha_data->qual[data_idx ].physician_number ,
    file_delimiter ,pha_data->qual[data_idx ].personnel_username ,file_delimiter ,format (pha_data->
     qual[data_idx ].admit_dt_tm ,date_time_fmt ) ,file_delimiter ,format (pha_data->qual[data_idx ].
     discharge_dt_tm ,date_time_fmt ) ,file_delimiter ,carriage_return ,line_feed )
   SET cclio_rec->file_buf = output_string
   SET stat = cclio ("WRITE" ,cclio_rec )
   SET output_string = ""
  ENDFOR
  SET stat = cclio ("CLOSE" ,cclio_rec )
  IF (catcherrors ("Error occured in the OutputToFile(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: OutputToFile(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 SUBROUTINE  outputtoscreen (null )
  CALL logmsg ("*******Beginning Subroutine: OutputToFile(null) = i2*******" )
  DECLARE return_ind = i2 WITH protect ,noconstant (1 )
  SELECT INTO  $OUTDEV
   facility_cd = pha_data->qual[d1.seq ].facility_cd ,
   fin = substring (1 ,30 ,pha_data->qual[d1.seq ].fin ) ,
   cmrn = substring (1 ,30 ,pha_data->qual[d1.seq ].cmrn ) ,
   item_number = substring (1 ,30 ,pha_data->qual[d1.seq ].item_number ) ,
   prescription_number = pha_data->qual[d1.seq ].order_id ,
   charge_entered_dt = format (pha_data->qual[d1.seq ].charge_entered_dt ,date_time_fmt ) ,
   charged_dt = format (pha_data->qual[d1.seq ].charged_dt ,date_time_fmt ) ,
   order_display = substring (1 ,255 ,pha_data->qual[d1.seq ].order_display ) ,
   drug_generic_name = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_generic_name ) ,
   drug_brand_name = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_brand_name ) ,
   strength_dose = substring (1 ,30 ,pha_data->qual[d1.seq ].strength_dose ) ,
   strength_dose_unit = substring (1 ,30 ,pha_data->qual[d1.seq ].strength_dose_unit ) ,
   route_of_admin = substring (1 ,30 ,pha_data->qual[d1.seq ].route_of_admin ) ,
   volume_dose = substring (1 ,30 ,pha_data->qual[d1.seq ].volume_dose ) ,
   volume_dose_unit = substring (1 ,30 ,pha_data->qual[d1.seq ].volume_dose_unit ) ,
   rate = substring (1 ,30 ,pha_data->qual[d1.seq ].rate ) ,
   rate_unit = substring (1 ,30 ,pha_data->qual[d1.seq ].rate_unit ) ,
   drug_form = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_form ) ,
   quantity_doses_charged = pha_data->qual[d1.seq ].quantity_doses_charged ,
   frequency_code = pha_data->qual[d1.seq ].frequency_code ,
   frequency_display = substring (1 ,30 ,pha_data->qual[d1.seq ].frequency_display ) ,
   duration = substring (1 ,30 ,pha_data->qual[d1.seq ].duration ) ,
   drug_class_code1 = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_class_code1 ) ,
   drug_class_description1 = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_class_description1 ) ,
   drug_class_code2 = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_class_code2 ) ,
   drug_class_description2 = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_class_description2 ) ,
   drug_class_code3 = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_class_code3 ) ,
   drug_class_description3 = substring (1 ,30 ,pha_data->qual[d1.seq ].drug_class_description3 ) ,
   physician_number = substring (1 ,30 ,pha_data->qual[d1.seq ].physician_number ) ,
   personnel_username = substring (1 ,30 ,pha_data->qual[d1.seq ].personnel_username ) ,
   admit_dt_tm = format (pha_data->qual[d1.seq ].admit_dt_tm ,date_time_fmt ) ,
   discharge_dt_tm = format (pha_data->qual[d1.seq ].discharge_dt_tm ,date_time_fmt )
   FROM (dummyt d1 WITH seq = value (size (pha_data->qual ,5 ) ) )
   PLAN (d1 )
   ORDER BY facility_cd ,
    fin ,
    charge_entered_dt
   WITH nocounter ,separator = " " ,format
  ;end select
  IF (catcherrors ("Error occured in the OutputToFile(null) subroutine!" ) )
   SET return_ind = 0
  ENDIF
  CALL logmsg ("*******End of Subroutine: OutputToFile(null) = i2*******" )
  RETURN (return_ind )
 END ;Subroutine
 call echorecord(debug_values)
END GO

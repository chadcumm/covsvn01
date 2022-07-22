 
DROP PROGRAM mp_unified_driver_ws_nocss :group1 GO
CREATE PROGRAM mp_unified_driver_ws_nocss :group1
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Person ID:" = 0.00 ,
  "Encounter ID:" = 0.00 ,
  "Personnel ID:" = 0.00 ,
  "Provider Position Code:" = 0.00 ,
  "Patient Provider Relationship Code:" = 0.00 ,
  "Executable in Context:" = "" ,
  "Static Content Location:" = "" ,
  "Viewpoint Name Key:" = "" ,
  "Debug Bitmap:" = 0
  WITH outdev ,person_id ,encntr_id ,prsnl_id ,pos_cd ,ppr_cd ,executable ,static_content ,
  category_mean ,debug_map
 FREE RECORD criterion
 RECORD criterion (
   1 person_id = f8
   1 person_name = vc
   1 person_info
     2 sex_cd = f8
     2 admin_sex_cd = f8
     2 birth_sex_cd = f8
     2 dob = vc
     2 person_name = vc
   1 encntrs [1 ]
     2 encntr_id = f8
   1 prsnl_id = f8
   1 executable = vc
   1 static_content = vc
   1 position_cd = f8
   1 ppr_cd = f8
   1 debug_ind = i2
   1 help_file_local_ind = i2
   1 category_mean = vc
   1 locale_id = vc
   1 device_location = vc
   1 encntr_override [* ]
     2 encntr_id = f8
   1 logical_domain_id = f8
   1 encntr_location
     2 facility_cd = f8
   1 client_tz = i4
   1 is_utc = i2
   1 username = vc
   1 release_identifier = vc
   1 release_version = vc
   1 alva_enabled = i2
   1 scratchpad_cds_alerts_add = i4
   1 static_content_legacy = vc
   1 workflow_base_url = vc
   1 codes [* ]
     2 sequence = i4
     2 code = f8
     2 code_set = f8
     2 display = vc
     2 description = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD view_types
 RECORD view_types (
   1 views [* ]
     2 view_mean = vc
 )
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,protect
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
 DECLARE getorgsecurityflag (null ) = i2 WITH protect
 DECLARE cclimpersonation (null ) = null WITH protect
 SUBROUTINE  (addcodetolist (code_value =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  IF ((code_value != 0 ) )
   IF ((((codelistcnt = 0 ) ) OR ((locateval (code_idx ,1 ,codelistcnt ,code_value ,record_data->
    codes[code_idx ].code ) <= 0 ) )) )
    SET codelistcnt +=1
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
 SUBROUTINE  (outputcodelist (record_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputCodeList() @deprecated" ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (addpersonneltolist (prsnl_id =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  CALL addpersonneltolistwithdate (prsnl_id ,record_data ,current_date_time )
 END ;Subroutine
 SUBROUTINE  (addpersonneltolistwithdate (prsnl_id =f8 (val ) ,record_data =vc (ref ) ,active_date =
  f8 (val ) ) =null WITH protect )
  DECLARE personnel_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) )
  IF ((((active_date = null ) ) OR ((active_date = 0.0 ) )) )
   SET active_date = current_date_time
  ENDIF
  IF ((prsnl_id != 0 ) )
   IF ((((prsnllistcnt = 0 ) ) OR ((locateval (prsnl_idx ,1 ,prsnllistcnt ,prsnl_id ,record_data->
    prsnl[prsnl_idx ].id ,active_date ,record_data->prsnl[prsnl_idx ].active_date ) <= 0 ) )) )
    SET prsnllistcnt +=1
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
 SUBROUTINE  (outputpersonnellist (report_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputPersonnelList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
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
      idx +=1 ,filteredcnt +=1 ,report_data->prsnl[idx ].id = report_data->prsnl[d.seq ].id ,
      report_data->prsnl[idx ].person_name_id = report_data->prsnl[d.seq ].person_name_id ,
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
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (addphonestolist (prsnl_id =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  IF ((prsnl_id != 0 ) )
   IF ((((phonelistcnt = 0 ) ) OR ((locateval (phone_idx ,1 ,phonelistcnt ,prsnl_id ,record_data->
    phone_list[prsnl_idx ].person_id ) <= 0 ) )) )
    SET phonelistcnt +=1
    IF ((phonelistcnt > size (record_data->phone_list ,5 ) ) )
     SET stat = alterlist (record_data->phone_list ,(phonelistcnt + 9 ) )
    ENDIF
    SET record_data->phone_list[phonelistcnt ].person_id = prsnl_id
    SET prsnl_cnt +=1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputphonelist (report_data =vc (ref ) ,phone_types =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputPhoneList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
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
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
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
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
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
     phonecnt +=1 ,
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
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putstringtofile (svalue =vc (val ) ) =null WITH protect )
  CALL log_message ("In PutStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
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
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putunboundedstringtofile (trec =vc (ref ) ) =null WITH protect )
  CALL log_message ("In PutUnboundedStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
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
    (cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putjsonrecordtofile (record_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In PutJSONRecordToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  RECORD _tempjson (
    1 val = gvc
  )
  SET _tempjson->val = cnvtrectojson (record_data )
  CALL putunboundedstringtofile (_tempjson )
  CALL log_message (build ("Exit PutJSONRecordToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getparametervalues (index =i4 (val ) ,value_rec =vc (ref ) ) =null WITH protect )
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
    SET value_rec->cnt +=1
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = param_value
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
   SET param_value_str = parameter (index ,0 )
   IF ((trim (param_value_str ,3 ) != "" ) )
    SET value_rec->cnt +=1
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
       SET value_rec->cnt +=1
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = param_value
      ENDIF
      SET lnum +=1
     ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
      SET param_value_str = parameter (index ,lnum )
      IF ((trim (param_value_str ,3 ) != "" ) )
       SET value_rec->cnt +=1
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
      ENDIF
      SET lnum +=1
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
 SUBROUTINE  (getlookbackdatebytype (units =i4 (val ) ,flag =i4 (val ) ) =dq8 WITH protect )
  DECLARE looback_date = dq8 WITH noconstant (cnvtdatetime ("01-JAN-1800 00:00:00" ) )
  IF ((units != 0 ) )
   CASE (flag )
    OF 1 :
     SET looback_date = cnvtlookbehind (build (units ,",H" ) ,cnvtdatetime (sysdate ) )
    OF 2 :
     SET looback_date = cnvtlookbehind (build (units ,",D" ) ,cnvtdatetime (sysdate ) )
    OF 3 :
     SET looback_date = cnvtlookbehind (build (units ,",W" ) ,cnvtdatetime (sysdate ) )
    OF 4 :
     SET looback_date = cnvtlookbehind (build (units ,",M" ) ,cnvtdatetime (sysdate ) )
    OF 5 :
     SET looback_date = cnvtlookbehind (build (units ,",Y" ) ,cnvtdatetime (sysdate ) )
   ENDCASE
  ENDIF
  RETURN (looback_date )
 END ;Subroutine
 SUBROUTINE  (getcodevaluesfromcodeset (evt_set_rec =vc (ref ) ,evt_cd_rec =vc (ref ) ) =null WITH
  protect )
  DECLARE csidx = i4 WITH noconstant (0 )
  SELECT DISTINCT INTO "nl:"
   FROM (v500_event_set_explode vese )
   WHERE expand (csidx ,1 ,evt_set_rec->cnt ,vese.event_set_cd ,evt_set_rec->qual[csidx ].value )
   DETAIL
    evt_cd_rec->cnt +=1 ,
    stat = alterlist (evt_cd_rec->qual ,evt_cd_rec->cnt ) ,
    evt_cd_rec->qual[evt_cd_rec->cnt ].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  (geteventsetnamesfromeventsetcds (evt_set_rec =vc (ref ) ,evt_set_name_rec =vc (ref )
  ) =null WITH protect )
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
     cnt +=1 ,evt_set_name_rec->qual[pos ].value = v.event_set_name ,pos = locateval (index ,(pos +
      1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_name_rec->cnt -=1 ,stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt ,(
      pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[
      index ].value )
    ENDWHILE
    ,evt_set_name_rec->cnt = cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 SUBROUTINE  (returnviewertype (eventclasscd =f8 (val ) ,eventid =f8 (val ) ) =vc WITH protect )
  CALL log_message ("In returnViewerType()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
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
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
  RETURN (sviewerflag )
 END ;Subroutine
 SUBROUTINE  (cnvtisodttmtodq8 (isodttmstr =vc ) =dq8 WITH protect )
  DECLARE converteddq8 = dq8 WITH protect ,noconstant (0 )
  SET converteddq8 = cnvtdatetimeutc2 (substring (1 ,10 ,isodttmstr ) ,"YYYY-MM-DD" ,substring (12 ,
    8 ,isodttmstr ) ,"HH:MM:SS" ,4 ,curtimezonedef )
  RETURN (converteddq8 )
 END ;Subroutine
 SUBROUTINE  (cnvtdq8toisodttm (dq8dttm =f8 ) =vc WITH protect )
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
 SUBROUTINE  (getcomporgsecurityflag (dminfo_name =vc (val ) ) =i2 WITH protect )
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
 SUBROUTINE  (populateauthorizedorganizations (personid =f8 (val ) ,value_rec =vc (ref ) ) =null
  WITH protect )
  DECLARE organization_cnt = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (prsnl_org_reltn por )
   WHERE (por.person_id = personid )
   AND (por.active_ind = 1 )
   AND (por.beg_effective_dt_tm BETWEEN cnvtdatetime (lower_bound_date ) AND cnvtdatetime (sysdate )
   )
   AND (por.end_effective_dt_tm BETWEEN cnvtdatetime (sysdate ) AND cnvtdatetime (upper_bound_date )
   )
   ORDER BY por.organization_id
   HEAD REPORT
    organization_cnt = 0
   DETAIL
    organization_cnt +=1 ,
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
 SUBROUTINE  (getuserlogicaldomain (id =f8 ) =f8 WITH protect )
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
 SUBROUTINE  (getpersonneloverride (ppr_cd =f8 (val ) ) =i2 WITH protect )
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
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
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
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (geteventsetdisplaysfromeventsetcds (evt_set_rec =vc (ref ) ,evt_set_disp_rec =vc (ref
   ) ) =null WITH protect )
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
     cnt +=1 ,evt_set_disp_rec->qual[pos ].value = v.event_set_cd_disp ,pos = locateval (index ,(pos
      + 1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_disp_rec->cnt ,"" ,evt_set_disp_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_disp_rec->cnt -=1 ,stat = alterlist (evt_set_disp_rec->qual ,evt_set_disp_rec->cnt ,(
      pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_disp_rec->cnt ,"" ,evt_set_disp_rec->qual[
      index ].value )
    ENDWHILE
    ,evt_set_disp_rec->cnt = cnt ,
    stat = alterlist (evt_set_disp_rec->qual ,evt_set_disp_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 SUBROUTINE  (decodestringparameter (description =vc (val ) ) =vc WITH protect )
  DECLARE decodeddescription = vc WITH private
  SET decodeddescription = replace (description ,"%3B" ,";" ,0 )
  SET decodeddescription = replace (decodeddescription ,"%25" ,"%" ,0 )
  RETURN (decodeddescription )
 END ;Subroutine
 SUBROUTINE  (urlencode (json =vc (val ) ) =vc WITH protect )
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
 SUBROUTINE  (istaskgranted (task_number =i4 (val ) ) =i2 WITH protect )
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
    AND (ag.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (ag.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
   DETAIL
    task_granted = 1
   WITH nocounter ,maxqual (ta ,1 )
  ;end select
  CALL log_message (build ("Exit IsTaskGranted - " ,build2 (cnvtint ((curtime3 - fntime ) ) ) ,
    "0 ms" ) ,log_level_debug )
  RETURN (task_granted )
 END ;Subroutine
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
 IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name
   ) ) > " " ) )) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE  (log_message (logmsg =vc ,loglvl =i4 ) =null )
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
 SUBROUTINE  (error_message (logstatusblockind =i2 ) =i2 )
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
 SUBROUTINE  (error_and_zero_check_rec (qualnum =i4 ,opname =vc ,logmsg =vc ,errorforceexit =i2 ,
  zeroforceexit =i2 ,recorddata =vc (ref ) ) =i2 )
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
 SUBROUTINE  (error_and_zero_check (qualnum =i4 ,opname =vc ,logmsg =vc ,errorforceexit =i2 ,
  zeroforceexit =i2 ) =i2 )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus_rec (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ,recorddata =vc (ref ) ) =i2 )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationstatus ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     targetobjectname ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     targetobjectvalue ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt +=1
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
 SUBROUTINE  (populate_subeventstatus (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ) =i2 )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue ,reply )
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus_msg (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ,loglevel =i2 (value ) ) =i2 )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue
   )
  CALL log_message (targetobjectvalue ,loglevel )
 END ;Subroutine
 SUBROUTINE  (check_log_level (arg_log_level =i4 ) =i2 )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 DECLARE ejs_subtimer = dq8 WITH protect ,noconstant (curtime3 )
 DECLARE uar_srvgetasis ((p1 = i4 (value ) ) ,(p2 = vc (ref ) ) ,(p3 = vc (ref ) ) ,(p4 = i4 (value
   ) ) ) = i4 WITH image_axp = "srvrtl" ,image_aix = "libsrv.a(libsrv.o)" ,uar = "SrvGetAsIs" ,
 persist
 SUBROUTINE  (getnamespacedsettings (teamnamespace =vc (val ) ,settingskey =vc (val ) ) =vc WITH
  protect )
  DECLARE hmsg = i4 WITH protect ,noconstant (0 )
  DECLARE hrequest = i4 WITH protect ,noconstant (0 )
  DECLARE hreply = i4 WITH protect ,noconstant (0 )
  DECLARE hstatus = i4 WITH protect ,noconstant (0 )
  DECLARE status = vc WITH protect ,noconstant ("F" )
  SET hmsg = uar_srvselectmessage (535000 )
  CALL echo (build2 ("hMsg: " ,hmsg ) )
  IF ((hmsg = 0 ) )
   CALL log_message ("mpage_namespaced_settings_cache.inc: EJS transaction 535000 unavailable" ,
    log_level_debug )
   RETURN ("" )
  ENDIF
  SET hrequest = uar_srvcreaterequest (hmsg )
  CALL echo (build2 ("hRequest: " ,hrequest ) )
  IF ((hrequest = 0 ) )
   CALL log_message (
    "mpage_namespaced_settings_cache.inc: EJS transaction 535000 request construction error" ,
    log_level_debug )
   RETURN ("" )
  ENDIF
  SET hreply = uar_srvcreatereply (hmsg )
  CALL echo (build2 ("hReply: " ,hreply ) )
  IF ((hreply = 0 ) )
   CALL log_message (
    "mpage_namespaced_settings_cache.inc: EJS transaction 535000 request construction error" ,
    log_level_debug )
   RETURN ("" )
  ENDIF
  SET stat = uar_srvsetstring (hrequest ,"team_namespace" ,nullterm (teamnamespace ) )
  SET stat = uar_srvsetstring (hrequest ,"settings_key" ,nullterm (settingskey ) )
  SET ejs_subtimer = curtime3
  SET stat = uar_srvexecute (hmsg ,hrequest ,hreply )
  IF ((stat != 0 ) )
   CALL log_message ("mpage_namespaced_settings_cache.inc: EJS transaction 535000 execution failure"
    ,log_level_debug )
   RETURN ("" )
  ENDIF
  CALL log_message (build ("mpage_namespaced_settings_cache.inc: GetNamespacedSettings call: " ,((
    curtime3 - ejs_subtimer ) / 100.0 ) ) ,log_level_debug )
  SET ejs_subtimer = curtime3
  SET hstatus = uar_srvgetstruct (hreply ,"status_data" )
  SET status = uar_srvgetstringptr (hstatus ,"status" )
  IF ((((status = "Z" ) ) OR ((status = "F" ) )) )
   CALL log_message (build2 ("mpage_namespaced_settings_cache.inc: No values for " ,teamnamespace ,
     " " ,settingskey ) ,log_level_debug )
   RETURN ("" )
  ENDIF
  DECLARE cachedsettings = vc WITH protect ,noconstant ("" )
  DECLARE cachedsettingssize = i4 WITH protect ,noconstant (0 )
  DECLARE response = vc WITH protect ,noconstant ("" )
  SET cachedsettings = uar_srvgetasisptr (hreply ,"settings" )
  SET cachedsettingssize = uar_srvgetasissize (hreply ,"settings" )
  SET stat = memrealloc (response ,cachedsettingssize ,"C1" )
  SET stat = uar_srvgetasis (hreply ,"settings" ,response ,cachedsettingssize )
  SET cachedsettings = notrim (substring (1 ,cachedsettingssize ,response ) )
  CALL log_message (build ("mpage_namespaced_settings_cache.inc: Reply processing:" ,((curtime3 -
    ejs_subtimer ) / 100.0 ) ) ,log_level_debug )
  CALL uar_srvdestroymessage (hmsg )
  CALL uar_srvdestroyhandle (hrequest )
  CALL uar_srvdestroyhandle (hreply )
  CALL log_message (build2 ("mpage_namespaced_settings_cache.inc: Cached values available for " ,
    teamnamespace ," " ,settingskey ) ,log_level_debug )
  RETURN (cachedsettings )
 END ;Subroutine
 SUBROUTINE  (cachenamespacedsettings (teamnamespace =vc (val ) ,settingskey =vc (val ) ,
  settingsstring =vc (val ) ) =i2 WITH protect )
  DECLARE hmsg = i4 WITH protect ,noconstant (0 )
  DECLARE hrequest = i4 WITH protect ,noconstant (0 )
  DECLARE hreply = i4 WITH protect ,noconstant (0 )
  DECLARE hstatus = i4 WITH protect ,noconstant (0 )
  DECLARE hsubeventstatus = i4 WITH protect ,noconstant (0 )
  DECLARE status = vc WITH protect ,noconstant ("F" )
  SET hmsg = uar_srvselectmessage (535001 )
  IF ((hmsg = 0 ) )
   CALL log_message ("mpage_namespaced_settings_cache.inc: EJS transaction 535001 unavailable" ,
    log_level_debug )
   RETURN (false )
  ENDIF
  SET hrequest = uar_srvcreaterequest (hmsg )
  IF ((hrequest = 0 ) )
   CALL log_message (
    "mpage_namespaced_settings_cache.inc: EJS transaction 535001 request construction error" ,
    log_level_debug )
   RETURN (false )
  ENDIF
  SET hreply = uar_srvcreatereply (hmsg )
  IF ((hreply = 0 ) )
   CALL log_message (
    "mpage_namespaced_settings_cache.inc: EJS transaction 535001 request construction error" ,
    log_level_debug )
   RETURN (false )
  ENDIF
  IF ((settingsstring = "" ) )
   RETURN (false )
  ENDIF
  SET stat = uar_srvsetstring (hrequest ,"team_namespace" ,nullterm (teamnamespace ) )
  SET stat = uar_srvsetstring (hrequest ,"settings_key" ,nullterm (settingskey ) )
  SET stat = uar_srvsetasis (hrequest ,"settings" ,nullterm (settingsstring ) ,size (settingsstring
    ) )
  SET stat = uar_srvexecute (hmsg ,hrequest ,hreply )
  IF ((stat != 0 ) )
   CALL log_message ("mpage_namespaced_settings_cache.inc: EJS transaction 535001 execution failure"
    ,log_level_debug )
   RETURN (0 )
  ENDIF
  SET hstatus = uar_srvgetstruct (hreply ,"status_data" )
  SET status = uar_srvgetstringptr (hstatus ,"status" )
  CALL uar_srvdestroymessage (hmsg )
  CALL uar_srvdestroyhandle (hrequest )
  CALL uar_srvdestroyhandle (hreply )
  IF ((((status = "Z" ) ) OR ((status = "F" ) )) )
   RETURN (false )
  ELSE
   CALL log_message (build2 ("mpage_namespaced_settings_cache.inc: settings for " ,settingskey ,
     " cached successfully" ) ,log_level_debug )
   RETURN (true )
  ENDIF
 END ;Subroutine
 FREE RECORD comp_filters
 RECORD comp_filters (
   1 filter [* ]
     2 filter_mean = vc
 )
 FREE RECORD mappings
 RECORD mappings (
   1 mapping [* ]
     2 filtermean = vc
     2 token = vc
 )
 DECLARE getfiltermeantokens (null ) = vc WITH protect
 SET stat = alterlist (mappings->mapping ,325 )
 SET mappings->mapping[1 ].filtermean = "10_COMMUNE"
 SET mappings->mapping[1 ].token = "2p"
 SET mappings->mapping[2 ].filtermean = "11_COMMUNE"
 SET mappings->mapping[2 ].token = "2p"
 SET mappings->mapping[3 ].filtermean = "12_COMMUNE"
 SET mappings->mapping[3 ].token = "2p"
 SET mappings->mapping[4 ].filtermean = "13_COMMUNE"
 SET mappings->mapping[4 ].token = "2p"
 SET mappings->mapping[5 ].filtermean = "14_COMMUNE"
 SET mappings->mapping[5 ].token = "2p"
 SET mappings->mapping[6 ].filtermean = "15_COMMUNE"
 SET mappings->mapping[6 ].token = "2p"
 SET mappings->mapping[7 ].filtermean = "16_COMMUNE"
 SET mappings->mapping[7 ].token = "2p"
 SET mappings->mapping[8 ].filtermean = "17_COMMUNE"
 SET mappings->mapping[8 ].token = "2p"
 SET mappings->mapping[9 ].filtermean = "18_COMMUNE"
 SET mappings->mapping[9 ].token = "2p"
 SET mappings->mapping[10 ].filtermean = "19_COMMUNE"
 SET mappings->mapping[10 ].token = "2p"
 SET mappings->mapping[11 ].filtermean = "1_COMMUNE"
 SET mappings->mapping[11 ].token = "2p"
 SET mappings->mapping[12 ].filtermean = "20_COMMUNE"
 SET mappings->mapping[12 ].token = "2p"
 SET mappings->mapping[13 ].filtermean = "21_COMMUNE"
 SET mappings->mapping[13 ].token = "2p"
 SET mappings->mapping[14 ].filtermean = "22_COMMUNE"
 SET mappings->mapping[14 ].token = "2p"
 SET mappings->mapping[15 ].filtermean = "2_COMMUNE"
 SET mappings->mapping[15 ].token = "2p"
 SET mappings->mapping[16 ].filtermean = "3_COMMUNE"
 SET mappings->mapping[16 ].token = "2p"
 SET mappings->mapping[17 ].filtermean = "4_COMMUNE"
 SET mappings->mapping[17 ].token = "2p"
 SET mappings->mapping[18 ].filtermean = "5_COMMUNE"
 SET mappings->mapping[18 ].token = "2p"
 SET mappings->mapping[19 ].filtermean = "6_COMMUNE"
 SET mappings->mapping[19 ].token = "2p"
 SET mappings->mapping[20 ].filtermean = "7_COMMUNE"
 SET mappings->mapping[20 ].token = "2p"
 SET mappings->mapping[21 ].filtermean = "8_COMMUNE"
 SET mappings->mapping[21 ].token = "2p"
 SET mappings->mapping[22 ].filtermean = "9_COMMUNE"
 SET mappings->mapping[22 ].token = "2p"
 SET mappings->mapping[23 ].filtermean = "ADV_ASTHMA_DOC"
 SET mappings->mapping[23 ].token = "2Z"
 SET mappings->mapping[24 ].filtermean = "ADV_CRITICAL_COMP"
 SET mappings->mapping[24 ].token = "2i"
 SET mappings->mapping[25 ].filtermean = "ALLERGY"
 SET mappings->mapping[25 ].token = "01"
 SET mappings->mapping[26 ].filtermean = "AMB_BIRTHHIST"
 SET mappings->mapping[26 ].token = "37"
 SET mappings->mapping[27 ].filtermean = "AMB_CONSENTS"
 SET mappings->mapping[27 ].token = "31"
 SET mappings->mapping[28 ].filtermean = "AMB_HEALTHPLAN"
 SET mappings->mapping[28 ].token = "32"
 SET mappings->mapping[29 ].filtermean = "AMB_HOME_MEDS"
 SET mappings->mapping[29 ].token = "2U"
 SET mappings->mapping[30 ].filtermean = "AMB_PATRELTN"
 SET mappings->mapping[30 ].token = "33"
 SET mappings->mapping[31 ].filtermean = "AMB_PAT_SUMM"
 SET mappings->mapping[31 ].token = "1t"
 SET mappings->mapping[32 ].filtermean = "AMB_PROVRELTN"
 SET mappings->mapping[32 ].token = "34"
 SET mappings->mapping[33 ].filtermean = "AMB_REG_INFO"
 SET mappings->mapping[33 ].token = "35"
 SET mappings->mapping[34 ].filtermean = "AMB_VISITS_ENC"
 SET mappings->mapping[34 ].token = "36"
 SET mappings->mapping[35 ].filtermean = "ANCIL_DOC"
 SET mappings->mapping[35 ].token = "02"
 SET mappings->mapping[36 ].filtermean = "ANESTHESIA"
 SET mappings->mapping[36 ].token = "30"
 SET mappings->mapping[37 ].filtermean = "ANESTHESIA_SUM"
 SET mappings->mapping[37 ].token = "30"
 SET mappings->mapping[38 ].filtermean = "ANTI_COAG"
 SET mappings->mapping[38 ].token = "26"
 SET mappings->mapping[39 ].filtermean = "APNEA"
 SET mappings->mapping[39 ].token = "03"
 SET mappings->mapping[40 ].filtermean = "APPOINTMENTS"
 SET mappings->mapping[40 ].token = "04"
 SET mappings->mapping[41 ].filtermean = "BH_ASSESSMENTS"
 SET mappings->mapping[41 ].token = "21"
 SET mappings->mapping[42 ].filtermean = "CALCULATOR"
 SET mappings->mapping[42 ].token = "2R"
 SET mappings->mapping[43 ].filtermean = "CARE_MANAGERS_COMP"
 SET mappings->mapping[43 ].token = "3V"
 SET mappings->mapping[44 ].filtermean = "CARE_TEAM"
 SET mappings->mapping[44 ].token = "3a"
 SET mappings->mapping[45 ].filtermean = "CASE_DISTRIBUTION"
 SET mappings->mapping[45 ].token = "3T"
 SET mappings->mapping[46 ].filtermean = "CHEMO_REVIEW"
 SET mappings->mapping[46 ].token = "1n"
 SET mappings->mapping[47 ].filtermean = "CLIN_DOC"
 SET mappings->mapping[47 ].token = "02"
 SET mappings->mapping[48 ].filtermean = "CLIN_TRIALS"
 SET mappings->mapping[48 ].token = "1m"
 SET mappings->mapping[49 ].filtermean = "CONSOL_PROBLEMS"
 SET mappings->mapping[49 ].token = "05"
 SET mappings->mapping[50 ].filtermean = "CPM_ASSIGN_COMP"
 SET mappings->mapping[50 ].token = "3f"
 SET mappings->mapping[51 ].filtermean = "CURR_STATUS"
 SET mappings->mapping[51 ].token = "07"
 SET mappings->mapping[52 ].filtermean = "CUSTOM_COMP_1"
 SET mappings->mapping[52 ].token = "27"
 SET mappings->mapping[53 ].filtermean = "CUSTOM_COMP_10"
 SET mappings->mapping[53 ].token = "27"
 SET mappings->mapping[54 ].filtermean = "CUSTOM_COMP_11"
 SET mappings->mapping[54 ].token = "27"
 SET mappings->mapping[55 ].filtermean = "CUSTOM_COMP_12"
 SET mappings->mapping[55 ].token = "27"
 SET mappings->mapping[56 ].filtermean = "CUSTOM_COMP_13"
 SET mappings->mapping[56 ].token = "27"
 SET mappings->mapping[57 ].filtermean = "CUSTOM_COMP_14"
 SET mappings->mapping[57 ].token = "27"
 SET mappings->mapping[58 ].filtermean = "CUSTOM_COMP_15"
 SET mappings->mapping[58 ].token = "27"
 SET mappings->mapping[59 ].filtermean = "CUSTOM_COMP_16"
 SET mappings->mapping[59 ].token = "27"
 SET mappings->mapping[60 ].filtermean = "CUSTOM_COMP_17"
 SET mappings->mapping[60 ].token = "27"
 SET mappings->mapping[61 ].filtermean = "CUSTOM_COMP_18"
 SET mappings->mapping[61 ].token = "27"
 SET mappings->mapping[62 ].filtermean = "CUSTOM_COMP_19"
 SET mappings->mapping[62 ].token = "27"
 SET mappings->mapping[63 ].filtermean = "CUSTOM_COMP_2"
 SET mappings->mapping[63 ].token = "27"
 SET mappings->mapping[64 ].filtermean = "CUSTOM_COMP_20"
 SET mappings->mapping[64 ].token = "27"
 SET mappings->mapping[65 ].filtermean = "CUSTOM_COMP_3"
 SET mappings->mapping[65 ].token = "27"
 SET mappings->mapping[66 ].filtermean = "CUSTOM_COMP_4"
 SET mappings->mapping[66 ].token = "27"
 SET mappings->mapping[67 ].filtermean = "CUSTOM_COMP_5"
 SET mappings->mapping[67 ].token = "27"
 SET mappings->mapping[68 ].filtermean = "CUSTOM_COMP_6"
 SET mappings->mapping[68 ].token = "27"
 SET mappings->mapping[69 ].filtermean = "CUSTOM_COMP_7"
 SET mappings->mapping[69 ].token = "27"
 SET mappings->mapping[70 ].filtermean = "CUSTOM_COMP_8"
 SET mappings->mapping[70 ].token = "27"
 SET mappings->mapping[71 ].filtermean = "CUSTOM_COMP_9"
 SET mappings->mapping[71 ].token = "27"
 SET mappings->mapping[72 ].filtermean = "CUSTOM_LINKS"
 SET mappings->mapping[72 ].token = "2I"
 SET mappings->mapping[73 ].filtermean = "DC_ACTIVITIES"
 SET mappings->mapping[73 ].token = "08"
 SET mappings->mapping[74 ].filtermean = "DC_CARE_MGMT"
 SET mappings->mapping[74 ].token = "09"
 SET mappings->mapping[75 ].filtermean = "DC_DIAGNOSIS"
 SET mappings->mapping[75 ].token = "0A"
 SET mappings->mapping[76 ].filtermean = "DC_ORDER"
 SET mappings->mapping[76 ].token = "0B"
 SET mappings->mapping[77 ].filtermean = "DC_READINESS"
 SET mappings->mapping[77 ].token = "0C"
 SET mappings->mapping[78 ].filtermean = "DC_RESULTS"
 SET mappings->mapping[78 ].token = "0D"
 SET mappings->mapping[79 ].filtermean = "DC_SOCIAL"
 SET mappings->mapping[79 ].token = "0E"
 SET mappings->mapping[80 ].filtermean = "DIAGNOSIS"
 SET mappings->mapping[80 ].token = "0A"
 SET mappings->mapping[81 ].filtermean = "DMS_ALLERGIES"
 SET mappings->mapping[81 ].token = "00"
 SET mappings->mapping[82 ].filtermean = "DMS_ANTIDIABETIC"
 SET mappings->mapping[82 ].token = "1i"
 SET mappings->mapping[83 ].filtermean = "DMS_DIAGNOSIS"
 SET mappings->mapping[83 ].token = "0A"
 SET mappings->mapping[84 ].filtermean = "DMS_DIET"
 SET mappings->mapping[84 ].token = "1h"
 SET mappings->mapping[85 ].filtermean = "DMS_GRAPH"
 SET mappings->mapping[85 ].token = "1l"
 SET mappings->mapping[86 ].filtermean = "DMS_INS_24_HRS"
 SET mappings->mapping[86 ].token = "1k"
 SET mappings->mapping[87 ].filtermean = "DMS_LAB"
 SET mappings->mapping[87 ].token = "0Z"
 SET mappings->mapping[88 ].filtermean = "DMS_MEDS_GLUC_LVL"
 SET mappings->mapping[88 ].token = "1j"
 SET mappings->mapping[89 ].filtermean = "DMS_PROBLEMS"
 SET mappings->mapping[89 ].token = "1B"
 SET mappings->mapping[90 ].filtermean = "DMS_REFERENCE"
 SET mappings->mapping[90 ].token = "1f"
 SET mappings->mapping[91 ].filtermean = "DMS_SCREENINGS"
 SET mappings->mapping[91 ].token = "1g"
 SET mappings->mapping[92 ].filtermean = "DX"
 SET mappings->mapping[92 ].token = "0A"
 SET mappings->mapping[93 ].filtermean = "ED_TIMELINE"
 SET mappings->mapping[93 ].token = "0F"
 SET mappings->mapping[94 ].filtermean = "EP_DA"
 SET mappings->mapping[94 ].token = "1e"
 SET mappings->mapping[95 ].filtermean = "FAMILY_HX"
 SET mappings->mapping[95 ].token = "0H"
 SET mappings->mapping[96 ].filtermean = "FIM"
 SET mappings->mapping[96 ].token = "0I"
 SET mappings->mapping[97 ].filtermean = "FLAG_EVENTS"
 SET mappings->mapping[97 ].token = "0J"
 SET mappings->mapping[98 ].filtermean = "FLD_BAL"
 SET mappings->mapping[98 ].token = "0K"
 SET mappings->mapping[99 ].filtermean = "FOLLOWUP"
 SET mappings->mapping[99 ].token = "0L"
 SET mappings->mapping[100 ].filtermean = "FP_CUSTOM_COMP_1"
 SET mappings->mapping[100 ].token = "27"
 SET mappings->mapping[101 ].filtermean = "FP_CUSTOM_COMP_2"
 SET mappings->mapping[101 ].token = "27"
 SET mappings->mapping[102 ].filtermean = "FP_CUSTOM_COMP_3"
 SET mappings->mapping[102 ].token = "27"
 SET mappings->mapping[103 ].filtermean = "FP_CUSTOM_COMP_4"
 SET mappings->mapping[103 ].token = "27"
 SET mappings->mapping[104 ].filtermean = "FP_CUSTOM_COMP_5"
 SET mappings->mapping[104 ].token = "27"
 SET mappings->mapping[105 ].filtermean = "FP_CUSTOM_COMP_6"
 SET mappings->mapping[105 ].token = "27"
 SET mappings->mapping[106 ].filtermean = "FRAMING"
 SET mappings->mapping[106 ].token = "1y"
 SET mappings->mapping[107 ].filtermean = "FUTURE_ORD"
 SET mappings->mapping[107 ].token = "0M"
 SET mappings->mapping[108 ].filtermean = "GOALS"
 SET mappings->mapping[108 ].token = "0N"
 SET mappings->mapping[109 ].filtermean = "GOALS_WF"
 SET mappings->mapping[109 ].token = "3e"
 SET mappings->mapping[110 ].filtermean = "GRAPH"
 SET mappings->mapping[110 ].token = "0O"
 SET mappings->mapping[111 ].filtermean = "GRAPHS"
 SET mappings->mapping[111 ].token = "0P"
 SET mappings->mapping[112 ].filtermean = "GROWTH_CHART"
 SET mappings->mapping[112 ].token = "0Q"
 SET mappings->mapping[113 ].filtermean = "HCM_CANDIDATES"
 SET mappings->mapping[113 ].token = "3S"
 SET mappings->mapping[114 ].filtermean = "HCM_COMM_EVENTS"
 SET mappings->mapping[114 ].token = "3X"
 SET mappings->mapping[115 ].filtermean = "HCM_REFERRAL"
 SET mappings->mapping[115 ].token = "3U"
 SET mappings->mapping[116 ].filtermean = "HEALTH_MAINT"
 SET mappings->mapping[116 ].token = "0R"
 SET mappings->mapping[117 ].filtermean = "HIM_PROCEDURES"
 SET mappings->mapping[117 ].token = "3D"
 SET mappings->mapping[118 ].filtermean = "HIM_REG_DISCH_INFO"
 SET mappings->mapping[118 ].token = "3E"
 SET mappings->mapping[119 ].filtermean = "HIV_PROFILE"
 SET mappings->mapping[119 ].token = "1d"
 SET mappings->mapping[120 ].filtermean = "HI_REGISTRIES"
 SET mappings->mapping[120 ].token = "3C"
 SET mappings->mapping[121 ].filtermean = "HOME_MEDS"
 SET mappings->mapping[121 ].token = "0T"
 SET mappings->mapping[122 ].filtermean = "ICU_FLOWSHEET"
 SET mappings->mapping[122 ].token = "0U"
 SET mappings->mapping[123 ].filtermean = "IMMUNIZATIONS"
 SET mappings->mapping[123 ].token = "0V"
 SET mappings->mapping[124 ].filtermean = "INCOMPLETE_ORDERS"
 SET mappings->mapping[124 ].token = "0W"
 SET mappings->mapping[125 ].filtermean = "INTER_TEAM"
 SET mappings->mapping[125 ].token = "0Y"
 SET mappings->mapping[126 ].filtermean = "INTRAOP_SUMMARY"
 SET mappings->mapping[126 ].token = "1a"
 SET mappings->mapping[127 ].filtermean = "LAB"
 SET mappings->mapping[127 ].token = "0a"
 SET mappings->mapping[128 ].filtermean = "LINES"
 SET mappings->mapping[128 ].token = "0b"
 SET mappings->mapping[129 ].filtermean = "MANAGE_CASE"
 SET mappings->mapping[129 ].token = "4A"
 SET mappings->mapping[130 ].filtermean = "MEDCALC"
 SET mappings->mapping[130 ].token = "2t"
 SET mappings->mapping[131 ].filtermean = "MEDS"
 SET mappings->mapping[131 ].token = "0c"
 SET mappings->mapping[132 ].filtermean = "MED_REC"
 SET mappings->mapping[132 ].token = "0d"
 SET mappings->mapping[133 ].filtermean = "MICRO"
 SET mappings->mapping[133 ].token = "0f"
 SET mappings->mapping[134 ].filtermean = "MMF_MED_GAL"
 SET mappings->mapping[134 ].token = "2P"
 SET mappings->mapping[135 ].filtermean = "MP_BBT_OVERVIEW_LAYOUT"
 SET mappings->mapping[135 ].token = "38"
 SET mappings->mapping[136 ].filtermean = "MP_BBT_PRODUCTS_LAYOUT"
 SET mappings->mapping[136 ].token = "39"
 SET mappings->mapping[137 ].filtermean = "MP_VB_REHAB_REGULATORY"
 SET mappings->mapping[137 ].token = "3G"
 SET mappings->mapping[138 ].filtermean = "MTM_SUM"
 SET mappings->mapping[138 ].token = "3c"
 SET mappings->mapping[139 ].filtermean = "MTM_WF"
 SET mappings->mapping[139 ].token = "3c"
 SET mappings->mapping[140 ].filtermean = "NARRATIVE_PROBLEM"
 SET mappings->mapping[140 ].token = "05"
 SET mappings->mapping[141 ].filtermean = "NC_DC_PLAN"
 SET mappings->mapping[141 ].token = "0g"
 SET mappings->mapping[142 ].filtermean = "NC_OVERDUE_TASKS"
 SET mappings->mapping[142 ].token = "0h"
 SET mappings->mapping[143 ].filtermean = "NC_PLAN"
 SET mappings->mapping[143 ].token = "0i"
 SET mappings->mapping[144 ].filtermean = "NC_PSYCHOSOC"
 SET mappings->mapping[144 ].token = "0j"
 SET mappings->mapping[145 ].filtermean = "NC_PT_ASSESS"
 SET mappings->mapping[145 ].token = "0k"
 SET mappings->mapping[146 ].filtermean = "NC_PT_BACKGROUND"
 SET mappings->mapping[146 ].token = "0l"
 SET mappings->mapping[147 ].filtermean = "NEO_HYPERBILI"
 SET mappings->mapping[147 ].token = "0p"
 SET mappings->mapping[148 ].filtermean = "NEO_OVERVIEW"
 SET mappings->mapping[148 ].token = "0m"
 SET mappings->mapping[149 ].filtermean = "NEO_TASK_TIMELINE"
 SET mappings->mapping[149 ].token = "0n"
 SET mappings->mapping[150 ].filtermean = "NEO_TRANSFUSION"
 SET mappings->mapping[150 ].token = "0q"
 SET mappings->mapping[151 ].filtermean = "NEO_WEIGHT"
 SET mappings->mapping[151 ].token = "0o"
 SET mappings->mapping[152 ].filtermean = "NEW_DOC"
 SET mappings->mapping[152 ].token = "0r"
 SET mappings->mapping[153 ].filtermean = "NEW_ORDERS"
 SET mappings->mapping[153 ].token = "0s"
 SET mappings->mapping[154 ].filtermean = "NOTES"
 SET mappings->mapping[154 ].token = "0t"
 SET mappings->mapping[155 ].filtermean = "ONCOLOGY_RADIATION"
 SET mappings->mapping[155 ].token = "2r"
 SET mappings->mapping[156 ].filtermean = "OPH_MEASUREMENTS"
 SET mappings->mapping[156 ].token = "22"
 SET mappings->mapping[157 ].filtermean = "OPH_PRES_EYEWEAR "
 SET mappings->mapping[157 ].token = "3l"
 SET mappings->mapping[158 ].filtermean = "OPH_SCRIPTS"
 SET mappings->mapping[158 ].token = "2s"
 SET mappings->mapping[159 ].filtermean = "ORDERS"
 SET mappings->mapping[159 ].token = "0W"
 SET mappings->mapping[160 ].filtermean = "ORDER_HX"
 SET mappings->mapping[160 ].token = "0u"
 SET mappings->mapping[161 ].filtermean = "ORD_SEL_1"
 SET mappings->mapping[161 ].token = "2d"
 SET mappings->mapping[162 ].filtermean = "ORD_SEL_10"
 SET mappings->mapping[162 ].token = "2d"
 SET mappings->mapping[163 ].filtermean = "ORD_SEL_11"
 SET mappings->mapping[163 ].token = "2d"
 SET mappings->mapping[164 ].filtermean = "ORD_SEL_12"
 SET mappings->mapping[164 ].token = "2d"
 SET mappings->mapping[165 ].filtermean = "ORD_SEL_13"
 SET mappings->mapping[165 ].token = "2d"
 SET mappings->mapping[166 ].filtermean = "ORD_SEL_14"
 SET mappings->mapping[166 ].token = "2d"
 SET mappings->mapping[167 ].filtermean = "ORD_SEL_15"
 SET mappings->mapping[167 ].token = "2d"
 SET mappings->mapping[168 ].filtermean = "ORD_SEL_2"
 SET mappings->mapping[168 ].token = "2d"
 SET mappings->mapping[169 ].filtermean = "ORD_SEL_3"
 SET mappings->mapping[169 ].token = "2d"
 SET mappings->mapping[170 ].filtermean = "ORD_SEL_4"
 SET mappings->mapping[170 ].token = "2d"
 SET mappings->mapping[171 ].filtermean = "ORD_SEL_5"
 SET mappings->mapping[171 ].token = "2d"
 SET mappings->mapping[172 ].filtermean = "ORD_SEL_6"
 SET mappings->mapping[172 ].token = "2d"
 SET mappings->mapping[173 ].filtermean = "ORD_SEL_7"
 SET mappings->mapping[173 ].token = "2d"
 SET mappings->mapping[174 ].filtermean = "ORD_SEL_8"
 SET mappings->mapping[174 ].token = "2d"
 SET mappings->mapping[175 ].filtermean = "ORD_SEL_9"
 SET mappings->mapping[175 ].token = "2d"
 SET mappings->mapping[176 ].filtermean = "ORD_SEL_ADD_FAV_FOLDER"
 SET mappings->mapping[176 ].token = "0X"
 SET mappings->mapping[177 ].filtermean = "OVERDUE_TASKS"
 SET mappings->mapping[177 ].token = "0h"
 SET mappings->mapping[178 ].filtermean = "PACE_SUMMARY"
 SET mappings->mapping[178 ].token = "2L"
 SET mappings->mapping[179 ].filtermean = "PAIN_SCORE_GRAPH"
 SET mappings->mapping[179 ].token = "29"
 SET mappings->mapping[180 ].filtermean = "PAST_MED_HX"
 SET mappings->mapping[180 ].token = "0v"
 SET mappings->mapping[181 ].filtermean = "PAST_MHX"
 SET mappings->mapping[181 ].token = "0v"
 SET mappings->mapping[182 ].filtermean = "PATH"
 SET mappings->mapping[182 ].token = "0w"
 SET mappings->mapping[183 ].filtermean = "PATHWAYS_OVERVIEW"
 SET mappings->mapping[183 ].token = "2l"
 SET mappings->mapping[184 ].filtermean = "PATHWAYS_TREATMENT"
 SET mappings->mapping[184 ].token = "2n"
 SET mappings->mapping[185 ].filtermean = "PATHWAYS_WORKUP"
 SET mappings->mapping[185 ].token = "2m"
 SET mappings->mapping[186 ].filtermean = "PAT_ED"
 SET mappings->mapping[186 ].token = "0y"
 SET mappings->mapping[187 ].filtermean = "PERIOP_TRACK"
 SET mappings->mapping[187 ].token = "1Z"
 SET mappings->mapping[188 ].filtermean = "POSTOP_SUMMARY"
 SET mappings->mapping[188 ].token = "1c"
 SET mappings->mapping[189 ].filtermean = "PRECAUTIONS"
 SET mappings->mapping[189 ].token = "0z"
 SET mappings->mapping[190 ].filtermean = "PREG_ASSESS"
 SET mappings->mapping[190 ].token = "0_"
 SET mappings->mapping[191 ].filtermean = "PREG_ASSESS_2"
 SET mappings->mapping[191 ].token = "10"
 SET mappings->mapping[192 ].filtermean = "PREG_ASSESS_3"
 SET mappings->mapping[192 ].token = "11"
 SET mappings->mapping[193 ].filtermean = "PREG_BIRTH_PLAN"
 SET mappings->mapping[193 ].token = "12"
 SET mappings->mapping[194 ].filtermean = "PREG_DELIVERY"
 SET mappings->mapping[194 ].token = "2N"
 SET mappings->mapping[195 ].filtermean = "PREG_ED"
 SET mappings->mapping[195 ].token = "13"
 SET mappings->mapping[196 ].filtermean = "PREG_EDD_MAINT"
 SET mappings->mapping[196 ].token = "14"
 SET mappings->mapping[197 ].filtermean = "PREG_FETAL_MON"
 SET mappings->mapping[197 ].token = "15"
 SET mappings->mapping[198 ].filtermean = "PREG_GENETIC_SCR"
 SET mappings->mapping[198 ].token = "16"
 SET mappings->mapping[199 ].filtermean = "PREG_HX"
 SET mappings->mapping[199 ].token = "18"
 SET mappings->mapping[200 ].filtermean = "PREG_OVERVIEW"
 SET mappings->mapping[200 ].token = "19"
 SET mappings->mapping[201 ].filtermean = "PREG_RESULTS"
 SET mappings->mapping[201 ].token = "1A"
 SET mappings->mapping[202 ].filtermean = "PREG_RISK_FACTORS"
 SET mappings->mapping[202 ].token = "3B"
 SET mappings->mapping[203 ].filtermean = "PREOP_CHECKLIST"
 SET mappings->mapping[203 ].token = "1b"
 SET mappings->mapping[204 ].filtermean = "PROBLEM"
 SET mappings->mapping[204 ].token = "1B"
 SET mappings->mapping[205 ].filtermean = "PROC_HX"
 SET mappings->mapping[205 ].token = "1C"
 SET mappings->mapping[206 ].filtermean = "PROC_INFO"
 SET mappings->mapping[206 ].token = "1Y"
 SET mappings->mapping[207 ].filtermean = "PT_ED"
 SET mappings->mapping[207 ].token = "0y"
 SET mappings->mapping[208 ].filtermean = "PT_INFO"
 SET mappings->mapping[208 ].token = "1D"
 SET mappings->mapping[209 ].filtermean = "QM"
 SET mappings->mapping[209 ].token = "1E"
 SET mappings->mapping[210 ].filtermean = "RAD"
 SET mappings->mapping[210 ].token = "1F"
 SET mappings->mapping[211 ].filtermean = "RAD_DOSE"
 SET mappings->mapping[211 ].token = "2A"
 SET mappings->mapping[212 ].filtermean = "RESP"
 SET mappings->mapping[212 ].token = "1G"
 SET mappings->mapping[213 ].filtermean = "RESP_ASSESS"
 SET mappings->mapping[213 ].token = "1H"
 SET mappings->mapping[214 ].filtermean = "RESP_TX"
 SET mappings->mapping[214 ].token = "1I"
 SET mappings->mapping[215 ].filtermean = "RESTRAINTS"
 SET mappings->mapping[215 ].token = "1J"
 SET mappings->mapping[216 ].filtermean = "RPHS_CLIN_ALERTS"
 SET mappings->mapping[216 ].token = "2W"
 SET mappings->mapping[217 ].filtermean = "RPHS_DECISION_SUPPORT"
 SET mappings->mapping[217 ].token = "2I"
 SET mappings->mapping[218 ].filtermean = "RPHS_HIGH_RISK"
 SET mappings->mapping[218 ].token = "2V"
 SET mappings->mapping[219 ].filtermean = "SAFETY"
 SET mappings->mapping[219 ].token = "20"
 SET mappings->mapping[220 ].filtermean = "SIG_EVENTS"
 SET mappings->mapping[220 ].token = "1K"
 SET mappings->mapping[221 ].filtermean = "SMART_REVIEW_PARAM"
 SET mappings->mapping[221 ].token = "2H"
 SET mappings->mapping[222 ].filtermean = "SM_QM"
 SET mappings->mapping[222 ].token = "5a"
 SET mappings->mapping[223 ].filtermean = "SOCIAL_HX"
 SET mappings->mapping[223 ].token = "1M"
 SET mappings->mapping[224 ].filtermean = "SURG_PROC_HX"
 SET mappings->mapping[224 ].token = "1O"
 SET mappings->mapping[225 ].filtermean = "THER_TREAT"
 SET mappings->mapping[225 ].token = "1_"
 SET mappings->mapping[226 ].filtermean = "TOP_3_PARAMS"
 SET mappings->mapping[226 ].token = "2S"
 SET mappings->mapping[227 ].filtermean = "TOP_3_PARAMS_SUM"
 SET mappings->mapping[227 ].token = "3b"
 SET mappings->mapping[228 ].filtermean = "TOP_3_PARAMS_WF"
 SET mappings->mapping[228 ].token = "3d"
 SET mappings->mapping[229 ].filtermean = "TREATMENTS"
 SET mappings->mapping[229 ].token = "1P"
 SET mappings->mapping[230 ].filtermean = "TRIAGE_DOCUMENT"
 SET mappings->mapping[230 ].token = "1Q"
 SET mappings->mapping[231 ].filtermean = "VENT_MON"
 SET mappings->mapping[231 ].token = "1R"
 SET mappings->mapping[232 ].filtermean = "VISITS"
 SET mappings->mapping[232 ].token = "1S"
 SET mappings->mapping[233 ].filtermean = "VS"
 SET mappings->mapping[233 ].token = "1T"
 SET mappings->mapping[234 ].filtermean = "WARFARIN_MGT"
 SET mappings->mapping[234 ].token = "2E"
 SET mappings->mapping[235 ].filtermean = "WEIGHT"
 SET mappings->mapping[235 ].token = "1W"
 SET mappings->mapping[236 ].filtermean = "WF_ACTIONS_SIT_AWARENESS"
 SET mappings->mapping[236 ].token = "2k"
 SET mappings->mapping[237 ].filtermean = "WF_ACTIVITIES"
 SET mappings->mapping[237 ].token = "23"
 SET mappings->mapping[238 ].filtermean = "WF_ADV_GROWTH_CHART"
 SET mappings->mapping[238 ].token = "24"
 SET mappings->mapping[239 ].filtermean = "WF_ALLERGY"
 SET mappings->mapping[239 ].token = "00"
 SET mappings->mapping[240 ].filtermean = "WF_ANTI_COAG"
 SET mappings->mapping[240 ].token = "26"
 SET mappings->mapping[241 ].filtermean = "WF_AOAV_SOI"
 SET mappings->mapping[241 ].token = "3j"
 SET mappings->mapping[242 ].filtermean = "WF_ASSESSMENT_PLAN"
 SET mappings->mapping[242 ].token = "1o"
 SET mappings->mapping[243 ].filtermean = "WF_CARDIO_DEVICE"
 SET mappings->mapping[243 ].token = "2O"
 SET mappings->mapping[244 ].filtermean = "WF_CARE_TEAM"
 SET mappings->mapping[244 ].token = "2Q"
 SET mappings->mapping[245 ].filtermean = "WF_CASE_CLOSURE"
 SET mappings->mapping[245 ].token = "3W"
 SET mappings->mapping[246 ].filtermean = "WF_CHARGES"
 SET mappings->mapping[246 ].token = "2u"
 SET mappings->mapping[247 ].filtermean = "WF_CHECKOUT"
 SET mappings->mapping[247 ].token = "2w"
 SET mappings->mapping[248 ].filtermean = "WF_CHIEF_COMPLAINT"
 SET mappings->mapping[248 ].token = "1p"
 SET mappings->mapping[249 ].filtermean = "WF_CLIN_DOC"
 SET mappings->mapping[249 ].token = "1q"
 SET mappings->mapping[250 ].filtermean = "WF_COMMUNICATION_EVENTS"
 SET mappings->mapping[250 ].token = "3Y"
 SET mappings->mapping[251 ].filtermean = "WF_CONSOL_HX"
 SET mappings->mapping[251 ].token = "25"
 SET mappings->mapping[252 ].filtermean = "WF_CONSOL_PROBLEMS"
 SET mappings->mapping[252 ].token = "06"
 SET mappings->mapping[253 ].filtermean = "WF_CONSOL_PROBLEMS_O3"
 SET mappings->mapping[253 ].token = "3A"
 SET mappings->mapping[254 ].filtermean = "WF_CPM_COMP"
 SET mappings->mapping[254 ].token = "3H"
 SET mappings->mapping[255 ].filtermean = "WF_CUSTOM_LINKS"
 SET mappings->mapping[255 ].token = "2I"
 SET mappings->mapping[256 ].filtermean = "WF_DIALYSIS"
 SET mappings->mapping[256 ].token = "2T"
 SET mappings->mapping[257 ].filtermean = "WF_FAMILY_HX"
 SET mappings->mapping[257 ].token = "0G"
 SET mappings->mapping[258 ].filtermean = "WF_FLD_BAL"
 SET mappings->mapping[258 ].token = "1r"
 SET mappings->mapping[259 ].filtermean = "WF_FOLLOWUP"
 SET mappings->mapping[259 ].token = "2j"
 SET mappings->mapping[260 ].filtermean = "WF_GDD_COMP_1"
 SET mappings->mapping[260 ].token = "3F"
 SET mappings->mapping[261 ].filtermean = "WF_GDD_COMP_2"
 SET mappings->mapping[261 ].token = "3F"
 SET mappings->mapping[262 ].filtermean = "WF_GDD_COMP_3"
 SET mappings->mapping[262 ].token = "3F"
 SET mappings->mapping[263 ].filtermean = "WF_HEALTH_MAINT"
 SET mappings->mapping[263 ].token = "0S"
 SET mappings->mapping[264 ].filtermean = "WF_HI_REGISTRIES"
 SET mappings->mapping[264 ].token = "3C"
 SET mappings->mapping[265 ].filtermean = "WF_HOME_MEDS"
 SET mappings->mapping[265 ].token = "1s"
 SET mappings->mapping[266 ].filtermean = "WF_HOSP_COURSE"
 SET mappings->mapping[266 ].token = "3h"
 SET mappings->mapping[267 ].filtermean = "WF_HX_PRESENT_ILL"
 SET mappings->mapping[267 ].token = "1z"
 SET mappings->mapping[268 ].filtermean = "WF_HX_PRESENT_ILL_STRUCT"
 SET mappings->mapping[268 ].token = "1z"
 SET mappings->mapping[269 ].filtermean = "WF_HYPERBILI_PARAM"
 SET mappings->mapping[269 ].token = "3k"
 SET mappings->mapping[270 ].filtermean = "WF_IMMUNIZATIONS"
 SET mappings->mapping[270 ].token = "2J"
 SET mappings->mapping[271 ].filtermean = "WF_INCOMPLETE_ORDERS"
 SET mappings->mapping[271 ].token = "1u"
 SET mappings->mapping[272 ].filtermean = "WF_LAB"
 SET mappings->mapping[272 ].token = "28"
 SET mappings->mapping[273 ].filtermean = "WF_MANAGE_CASE"
 SET mappings->mapping[273 ].token = "4B"
 SET mappings->mapping[274 ].filtermean = "WF_MBIOLOGY"
 SET mappings->mapping[274 ].token = "0e"
 SET mappings->mapping[275 ].filtermean = "WF_MEDS"
 SET mappings->mapping[275 ].token = "1X"
 SET mappings->mapping[276 ].filtermean = "WF_MMF_MED_GAL"
 SET mappings->mapping[276 ].token = "2g"
 SET mappings->mapping[277 ].filtermean = "WF_MUFX"
 SET mappings->mapping[277 ].token = "3R"
 SET mappings->mapping[278 ].filtermean = "WF_NEW_ORDERS"
 SET mappings->mapping[278 ].token = "1v"
 SET mappings->mapping[279 ].filtermean = "WF_ORDER_DETAILS"
 SET mappings->mapping[279 ].token = "2v"
 SET mappings->mapping[280 ].filtermean = "WF_ORDER_HX"
 SET mappings->mapping[280 ].token = "1w"
 SET mappings->mapping[281 ].filtermean = "WF_ORDER_PROFILE"
 SET mappings->mapping[281 ].token = "1x"
 SET mappings->mapping[282 ].filtermean = "WF_PACE_SUMMARY"
 SET mappings->mapping[282 ].token = "2M"
 SET mappings->mapping[283 ].filtermean = "WF_PARTO_CONTRACT"
 SET mappings->mapping[283 ].token = "3M"
 SET mappings->mapping[284 ].filtermean = "WF_PARTO_FHR"
 SET mappings->mapping[284 ].token = "3I"
 SET mappings->mapping[285 ].filtermean = "WF_PARTO_LABOR"
 SET mappings->mapping[285 ].token = "3J"
 SET mappings->mapping[286 ].filtermean = "WF_PARTO_OVERVIEW"
 SET mappings->mapping[286 ].token = "3L"
 SET mappings->mapping[287 ].filtermean = "WF_PARTO_TABLE1"
 SET mappings->mapping[287 ].token = "3N"
 SET mappings->mapping[288 ].filtermean = "WF_PARTO_TABLE2"
 SET mappings->mapping[288 ].token = "3O"
 SET mappings->mapping[289 ].filtermean = "WF_PARTO_TABLE3"
 SET mappings->mapping[289 ].token = "3P"
 SET mappings->mapping[290 ].filtermean = "WF_PARTO_VITALS"
 SET mappings->mapping[290 ].token = "3K"
 SET mappings->mapping[291 ].filtermean = "WF_PAST_MHX"
 SET mappings->mapping[291 ].token = "0v"
 SET mappings->mapping[292 ].filtermean = "WF_PATH"
 SET mappings->mapping[292 ].token = "0x"
 SET mappings->mapping[293 ].filtermean = "WF_PATIENT_INFO"
 SET mappings->mapping[293 ].token = "4C"
 SET mappings->mapping[294 ].filtermean = "WF_PAT_INST"
 SET mappings->mapping[294 ].token = "3g"
 SET mappings->mapping[295 ].filtermean = "WF_PHYSICAL_EXAM"
 SET mappings->mapping[295 ].token = "2_"
 SET mappings->mapping[296 ].filtermean = "WF_PHYSICAL_EXAM_STRUCT"
 SET mappings->mapping[296 ].token = "2_"
 SET mappings->mapping[297 ].filtermean = "WF_PREG_ADD_PREGNANCY"
 SET mappings->mapping[297 ].token = "2G"
 SET mappings->mapping[298 ].filtermean = "WF_PREG_BIRTH_PLAN"
 SET mappings->mapping[298 ].token = "2F"
 SET mappings->mapping[299 ].filtermean = "WF_PREG_DELIVERY"
 SET mappings->mapping[299 ].token = "3Z"
 SET mappings->mapping[300 ].filtermean = "WF_PREG_EC"
 SET mappings->mapping[300 ].token = "2e"
 SET mappings->mapping[301 ].filtermean = "WF_PREG_EDD_MAINT"
 SET mappings->mapping[301 ].token = "2b"
 SET mappings->mapping[302 ].filtermean = "WF_PREG_FETAL_MON"
 SET mappings->mapping[302 ].token = "2a"
 SET mappings->mapping[303 ].filtermean = "WF_PREG_GENETIC_SCR"
 SET mappings->mapping[303 ].token = "2q"
 SET mappings->mapping[304 ].filtermean = "WF_PREG_HX"
 SET mappings->mapping[304 ].token = "17"
 SET mappings->mapping[305 ].filtermean = "WF_PREG_OVERVIEW"
 SET mappings->mapping[305 ].token = "2o"
 SET mappings->mapping[306 ].filtermean = "WF_PREG_PREN_LABS"
 SET mappings->mapping[306 ].token = "3Q"
 SET mappings->mapping[307 ].filtermean = "WF_PREG_PV"
 SET mappings->mapping[307 ].token = "2Y"
 SET mappings->mapping[308 ].filtermean = "WF_PREG_RISK_FACTORS"
 SET mappings->mapping[308 ].token = "2c"
 SET mappings->mapping[309 ].filtermean = "WF_PREG_RT"
 SET mappings->mapping[309 ].token = "3i"
 SET mappings->mapping[310 ].filtermean = "WF_PREG_SA"
 SET mappings->mapping[310 ].token = "2x"
 SET mappings->mapping[311 ].filtermean = "WF_PREG_TA"
 SET mappings->mapping[311 ].token = "2y"
 SET mappings->mapping[312 ].filtermean = "WF_PROC_HX"
 SET mappings->mapping[312 ].token = "1N"
 SET mappings->mapping[313 ].filtermean = "WF_PTED"
 SET mappings->mapping[313 ].token = "2h"
 SET mappings->mapping[314 ].filtermean = "WF_RAD"
 SET mappings->mapping[314 ].token = "1U"
 SET mappings->mapping[315 ].filtermean = "WF_REM"
 SET mappings->mapping[315 ].token = "2B"
 SET mappings->mapping[316 ].filtermean = "WF_REVIEW_SYMPT"
 SET mappings->mapping[316 ].token = "2z"
 SET mappings->mapping[317 ].filtermean = "WF_REVIEW_SYMPT_STRUCT"
 SET mappings->mapping[317 ].token = "2z"
 SET mappings->mapping[318 ].filtermean = "WF_SA"
 SET mappings->mapping[318 ].token = "2K"
 SET mappings->mapping[319 ].filtermean = "WF_SOCIAL"
 SET mappings->mapping[319 ].token = "2C"
 SET mappings->mapping[320 ].filtermean = "WF_SOCIAL_HX"
 SET mappings->mapping[320 ].token = "1L"
 SET mappings->mapping[321 ].filtermean = "WF_SR"
 SET mappings->mapping[321 ].token = "2f"
 SET mappings->mapping[322 ].filtermean = "WF_TRIAGE"
 SET mappings->mapping[322 ].token = "2X"
 SET mappings->mapping[323 ].filtermean = "WF_VISITS"
 SET mappings->mapping[323 ].token = "2D"
 SET mappings->mapping[324 ].filtermean = "WF_VS"
 SET mappings->mapping[324 ].token = "1V"
 SET mappings->mapping[325 ].filtermean = "WF_WARFARIN_MGT"
 SET mappings->mapping[325 ].token = "2E"
 SUBROUTINE  getfiltermeantokens (null )
  CALL log_message ("In GetFilterMeanTokens()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE filterindx = i4 WITH noconstant (0 ) ,protect
  DECLARE filtermean = vc WITH noconstant ("" ) ,protect
  DECLARE filtertoken = vc WITH noconstant ("" ) ,protect
  DECLARE indx = i4 WITH protect ,noconstant (0 )
  DECLARE indx2 = i4 WITH protect ,noconstant (0 )
  DECLARE mappingcnt = i4 WITH protect ,noconstant (size (mappings->mapping ,5 ) )
  DECLARE params = vc WITH noconstant ("" ) ,protect
  DECLARE tokencnt = i4 WITH protect ,noconstant (0 )
  FREE RECORD tokens_rec
  RECORD tokens_rec (
    1 tokens [* ]
      2 token = vc
  )
  FOR (filterindx = 1 TO size (comp_filters->filter ,5 ) )
   SET filtermean = cnvtupper (comp_filters->filter[filterindx ].filter_mean )
   SET indx = locateval (indx ,1 ,mappingcnt ,filtermean ,mappings->mapping[indx ].filtermean )
   IF ((indx > 0 ) )
    SET indx2 = locateval (indx2 ,1 ,tokencnt ,mappings->mapping[indx ].token ,tokens_rec->tokens[
     indx2 ].token )
    IF ((indx2 = 0 ) )
     SET tokencnt +=1
     IF ((mod (tokencnt ,50 ) = 1 ) )
      SET stat = alterlist (tokens_rec->tokens ,(tokencnt + 49 ) )
     ENDIF
     SET tokens_rec->tokens[tokencnt ].token = mappings->mapping[indx ].token
     SET filtertoken = build2 (filtertoken ,mappings->mapping[indx ].token )
    ENDIF
   ELSE
    CALL log_message (build ("Error mapping FILTER_MEAN: " ,filtermean ) ,log_level_debug )
    SET filterindx = (size (comp_filters->filter ,5 ) + 1 )
    SET tokencnt = 0
   ENDIF
  ENDFOR
  SET stat = alterlist (tokens_rec->tokens ,tokencnt )
  IF ((size (tokens_rec->tokens ,5 ) > 0 ) )
   SET params = trim (build2 ("build?t=" ,trim (filtertoken ,3 ) ) ,3 )
  ENDIF
  IF ((validate (debug_ind ) = 1 ) )
   CALL echorecord (mappings )
   CALL echorecord (comp_filters )
   CALL echorecord (tokens_rec )
   CALL echo (build2 ("Token params string: " ,params ) )
  ENDIF
  CALL log_message (build ("Exit GetFilterMeanTokens(), Elapsed time:" ,((curtime3 - begin_date_time
    ) / 100.0 ) ) ,log_level_debug )
  RETURN (params )
 END ;Subroutine
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
 DECLARE i18nhandle = i4 WITH protect
 DECLARE class_begin_ts = dm12 WITH protect ,constant (systimestamp )
 CREATE CLASS mp_i18n
 init
 IF ((validate (debug_ind ,0 ) = 1 ) )
  DECLARE PRIVATE::obj_create_start = dm12 WITH constant (systimestamp )
  CALL echo ("BEGIN MP_I18N object creation" )
 ENDIF
 RECORD PRIVATE::settings (
   1 i18nhandle = i4
   1 domainlocale = vc
   1 locale = vc
   1 langid = vc
   1 langlocaleid = vc
   1 logprgname = vc
   1 localeobjectname = vc
   1 localefilename = vc
   1 worklistfilename = vc
   1 localefilepath = vc
   1 worklistlocalefilepath = vc
 )
 DECLARE PRIVATE::overrideind = i2 WITH protect ,noconstant (0 )
 DECLARE PRIVATE::locidx = i4 WITH protect ,noconstant (0 )
 DECLARE PRIVATE::override_prg_global_pos = i4 WITH protect ,noconstant (0 )
 DECLARE PRIVATE::override_prg_prsnl_pos = i4 WITH protect ,noconstant (0 )
 DECLARE PRIVATE::override_all_global_pos = i4 WITH protect ,noconstant (0 )
 DECLARE PRIVATE::override_all_prsnl_pos = i4 WITH protect ,noconstant (0 )
 DECLARE PRIVATE::override_prg_global_str = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_prg_user_str = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_all_global_str = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_all_usr_str = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_prg_global_val = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_prg_user_val = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_all_global_val = vc WITH noconstant ("" )
 DECLARE PRIVATE::override_all_usr_val = vc WITH noconstant ("" )
 DECLARE _::getdomainlocale (null ) = vc
 DECLARE _::getlocale (null ) = vc
 DECLARE _::getlangid (null ) = vc
 DECLARE _::getlanglocaleid (null ) = vc
 DECLARE _::getlocaleobjectname (null ) = vc
 DECLARE _::getlocalefilename (null ) = vc
 DECLARE _::getworklistfilename (null ) = vc
 DECLARE _::getlogprgname (null ) = vc
 DECLARE _::geti18nhandle (null ) = i4
 DECLARE _::getlocalefilepath (null ) = vc
 DECLARE _::getworklistlocalefilepath (null ) = vc
 DECLARE _::dump (null ) = null
 DECLARE _::generatemasks (null ) = null
 SUBROUTINE  _::generatemasks (null )
  FREE RECORD datetimeformats
  RECORD datetimeformats (
    1 formatters
      2 decimal_point = vc
      2 thousands_sep = vc
      2 grouping = vc
      2 dollar = vc
      2 time24hr = vc
      2 time24hrnosec = vc
      2 shortdate2yr = vc
      2 fulldate2yr = vc
      2 fulldate4yr = vc
      2 fullmonth4yrnodate = vc
      2 full4yr = vc
      2 fulldatetime2yr = vc
      2 fulldatetime4yr = vc
    1 dateformats
      2 shortdate = vc
      2 mediumdate = vc
      2 longdate = vc
      2 shortdatetime = vc
      2 mediumdatetime = vc
      2 longdatetime = vc
      2 timewithseconds = vc
      2 timenoseconds = vc
      2 weekdaynumber = vc
      2 weekdayabbrev = vc
      2 weekdayname = vc
      2 monthname = vc
      2 monthnumber = vc
      2 monthabbrev = vc
      2 shortdate4yr = vc
      2 mediumdate4yr = vc
      2 shortdatetimenosec = vc
      2 datetimecondensed = vc
      2 datecondensed = vc
      2 mediumdate4yr2 = vc
      2 default = vc
      2 short_date2 = vc
      2 short_date3 = vc
      2 short_date4 = vc
      2 short_date5 = vc
      2 medium_date = vc
      2 long_date = vc
      2 short_time = vc
      2 medium_time = vc
      2 military_time = vc
      2 iso_date = vc
      2 iso_time = vc
      2 iso_date_time = vc
      2 iso_utc_date_time = vc
      2 long_date_time2 = vc
      2 long_date_time3 = vc
      2 medium_date_no_year = vc
      2 month_year = vc
    1 weekmonthnames
      2 weekabbrev = vc
      2 weekfull = vc
      2 monthabbrev = vc
      2 monthfull = vc
  ) WITH persistscript
  SET datetimeformats->dateformats.longdate = replace (cclfmt->longdate ,";;d" ,"" )
  SET datetimeformats->dateformats.longdatetime = replace (cclfmt->longdatetime ,";3;d" ,"" )
  SET datetimeformats->dateformats.mediumdate = replace (cclfmt->mediumdate ,";;d" ,"" )
  SET datetimeformats->dateformats.mediumdatetime = replace (cclfmt->mediumdatetime ,";3;d" ,"" )
  SET datetimeformats->dateformats.shortdate = replace (cclfmt->shortdate ,";;d" ,"" )
  SET datetimeformats->dateformats.shortdatetime = replace (cclfmt->shortdatetime ,";3;d" ,"" )
  SET datetimeformats->dateformats.timenoseconds = replace (cclfmt->timenoseconds ,";3;m" ,"" )
  SET datetimeformats->dateformats.timewithseconds = replace (cclfmt->timewithseconds ,";3;m" ,"" )
  SET datetimeformats->dateformats.shortdate4yr = replace (cclfmt->shortdate4yr ,";;d" ,"" )
  SET datetimeformats->dateformats.mediumdate4yr = replace (cclfmt->mediumdate4yr ,";;d" ,"" )
  SET datetimeformats->dateformats.shortdatetimenosec = replace (cclfmt->shortdatetimenosec ,";3;d" ,
   "" )
  SET datetimeformats->dateformats.datetimecondensed = replace (cclfmt->datetimecondensed ,";3;d" ,
   "" )
  SET datetimeformats->dateformats.datecondensed = replace (cclfmt->datecondensed ,";;d" ,"" )
  IF (validate (cclfmt->mediumdate4yr2 ) )
   SET datetimeformats->dateformats.mediumdate4yr2 = replace (cclfmt->mediumdate4yr2 ,";;d" ,"" )
  ELSE
   SET datetimeformats->dateformats.mediumdate4yr2 = replace (cclfmt->shortdate4yr ,";;d" ,"" )
  ENDIF
  SET datetimeformats->dateformats.monthname = replace (cclfmt->monthname ,";;d" ,"" )
  SET datetimeformats->dateformats.monthabbrev = replace (cclfmt->monthabbrev ,";;d" ,"" )
  SET datetimeformats->dateformats.monthnumber = replace (cclfmt->monthnumber ,";;d" ,"" )
  SET datetimeformats->dateformats.weekdayabbrev = replace (cclfmt->weekdayabbrev ,";;d" ,"" )
  SET datetimeformats->dateformats.weekdayname = replace (cclfmt->weekdayname ,";;d" ,"" )
  SET datetimeformats->dateformats.weekdaynumber = replace (cclfmt->weekdaynumber ,";;d" ,"" )
  SET datetimeformats->formatters.thousands_sep = curlocale ("THOUSAND" )
  SET datetimeformats->formatters.decimal_point = curlocale ("DECIMAL" )
  SET datetimeformats->formatters.dollar = curlocale ("DOLLAR" )
  SET datetimeformats->formatters.grouping = "3"
  SET datetimeformats->formatters.time24hr = "HH:mm:ss"
  SET datetimeformats->formatters.time24hrnosec = "HH:mm"
  SET datetimeformats->formatters.full4yr = "yyyy"
  SET datetimeformats->formatters.shortdate2yr = datetimeformats->dateformats.shortdate
  SET datetimeformats->formatters.fulldate2yr = datetimeformats->dateformats.shortdate
  SET datetimeformats->formatters.fulldate4yr = datetimeformats->dateformats.shortdate4yr
  SET datetimeformats->formatters.fullmonth4yrnodate = "MMM/yyyy"
  SET datetimeformats->formatters.fulldatetime2yr = build2 (datetimeformats->dateformats.shortdate ,
   " " ,datetimeformats->dateformats.timenoseconds )
  SET datetimeformats->formatters.fulldatetime4yr = build2 (datetimeformats->dateformats.shortdate4yr
    ," " ,datetimeformats->dateformats.timenoseconds )
  SET datetimeformats->dateformats.military_time = "HH:mm"
  SET datetimeformats->dateformats.iso_date = "yyyy-MM-dd"
  SET datetimeformats->dateformats.iso_time = "HH:mm:ss"
  SET datetimeformats->dateformats.iso_date_time = "yyyy-MM-dd'T'HH:mm:ss"
  SET datetimeformats->dateformats.iso_utc_date_time = "UTC:yyyy-MM-dd'T'HH:mm:ss'Z'"
  SET datetimeformats->dateformats.short_date5 = "yyyy"
  SET datetimeformats->dateformats.default = datetimeformats->dateformats.longdatetime
  SET datetimeformats->dateformats.short_date2 = datetimeformats->dateformats.shortdate4yr
  SET datetimeformats->dateformats.short_date3 = datetimeformats->dateformats.shortdate
  SET datetimeformats->dateformats.short_date4 = "MMM/yyyy"
  SET datetimeformats->dateformats.medium_date = datetimeformats->dateformats.mediumdate4yr2
  SET datetimeformats->dateformats.long_date = datetimeformats->dateformats.longdate
  SET datetimeformats->dateformats.short_time = datetimeformats->dateformats.timenoseconds
  SET datetimeformats->dateformats.medium_time = datetimeformats->dateformats.timewithseconds
  SET datetimeformats->dateformats.long_date_time2 = build2 (datetimeformats->dateformats.shortdate ,
   " " ,datetimeformats->dateformats.timenoseconds )
  SET datetimeformats->dateformats.long_date_time3 = build2 (datetimeformats->dateformats.
   shortdate4yr ," " ,datetimeformats->dateformats.timenoseconds )
  SET datetimeformats->dateformats.medium_date_no_year = "d mmm"
  SET datetimeformats->dateformats.month_year = "MAC. yyyy"
  SET datetimeformats->weekmonthnames.weekabbrev = curlocale ("WEEKABBREV" )
  SET datetimeformats->weekmonthnames.weekfull = curlocale ("WEEKFULL" )
  SET datetimeformats->weekmonthnames.monthabbrev = curlocale ("MONTHABBREV" )
  SET datetimeformats->weekmonthnames.monthfull = concat (format (cnvtdatetime ("01-jan-2015" ) ,
    "mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-feb-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (
    cnvtdatetime ("01-mar-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-apr-2015" ) ,
    "mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-may-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (
    cnvtdatetime ("01-jun-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-jul-2015" ) ,
    "mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-aug-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (
    cnvtdatetime ("01-sep-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-oct-2015" ) ,
    "mmmmmmmmmmmm,;;q" ) ,format (cnvtdatetime ("01-nov-2015" ) ,"mmmmmmmmmmmm,;;q" ) ,format (
    cnvtdatetime ("01-dec-2015" ) ,"mmmmmmmmmmmm;;q" ) )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (datetimeformats )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (_::setlocale (str =vc ) =null )
  SET private::settings ->locale = str
 END ;Subroutine
 SUBROUTINE  (_::setlangid (str =vc ) =null )
  SET private::settings ->langid = str
 END ;Subroutine
 SUBROUTINE  (_::setlanglocaleid (str =vc ) =null )
  SET private::settings ->langlocaleid = str
 END ;Subroutine
 SUBROUTINE  (_::setlogprgname (str =vc ) =null )
  SET private::settings ->logprgname = str
 END ;Subroutine
 SUBROUTINE  (_::setlocaleobjectname (str =vc ) =null )
  SET private::settings ->localeobjectname = str
 END ;Subroutine
 SUBROUTINE  (_::setlocalefilename (str =vc ) =null )
  SET private::settings ->localefilename = str
 END ;Subroutine
 SUBROUTINE  (_::setlocalefilepath (str =vc ) =null )
  SET private::settings ->localefilepath = str
 END ;Subroutine
 SUBROUTINE  (_::setdomainlocale (str =vc ) =null )
  SET private::settings ->domainlocale = str
 END ;Subroutine
 SUBROUTINE  (_::seti18nhandle (val =i4 ) =null )
  SET private::settings ->i18nhandle = val
 END ;Subroutine
 SUBROUTINE  (_::setworklistfilename (str =vc ) =null )
  SET private::settings ->worklistfilename = str
 END ;Subroutine
 SUBROUTINE  (_::setworklistlocalefilepath (str =vc ) =null )
  SET private::settings ->worklistlocalefilepath = str
 END ;Subroutine
 SUBROUTINE  _::getworklistfilename (null )
  RETURN (private::settings ->worklistfilename )
 END ;Subroutine
 SUBROUTINE  _::getlocale (null )
  RETURN (private::settings ->locale )
 END ;Subroutine
 SUBROUTINE  _::getlangid (null )
  RETURN (private::settings ->langid )
 END ;Subroutine
 SUBROUTINE  _::getlanglocaleid (null )
  RETURN (private::settings ->langlocaleid )
 END ;Subroutine
 SUBROUTINE  _::getlogprgname (null )
  RETURN (private::settings ->logprgname )
 END ;Subroutine
 SUBROUTINE  _::getdomainlocale (null )
  DECLARE tlocale = c5 WITH private ,noconstant ("     " )
  SET tlocale = cnvtupper (logical ("CCL_LANG" ) )
  IF ((tlocale = " " ) )
   SET tlocale = cnvtupper (logical ("LANG" ) )
   IF ((tlocale IN (" " ,
   "C" ) ) )
    SET tlocale = "EN_US"
   ENDIF
  ENDIF
  CALL _::setdomainlocale (tlocale )
  RETURN (tlocale )
 END ;Subroutine
 SUBROUTINE  _::getlocaleobjectname (null )
  RETURN (private::settings ->localeobjectname )
 END ;Subroutine
 SUBROUTINE  _::getlocalefilename (null )
  RETURN (private::settings ->localefilename )
 END ;Subroutine
 SUBROUTINE  _::getlocalefilepath (null )
  RETURN (private::settings ->localefilepath )
 END ;Subroutine
 SUBROUTINE  _::geti18nhandle (null )
  RETURN (private::settings ->i18nhandle )
 END ;Subroutine
 SUBROUTINE  _::getworklistlocalefilepath (null )
  RETURN (private::settings ->worklistlocalefilepath )
 END ;Subroutine
 SUBROUTINE  (_::initlocale (str =vc ) =null )
  DECLARE tlangid = vc WITH private ,noconstant ("" )
  DECLARE tlanglocaleid = vc WITH private ,noconstant ("" )
  CALL _::setlocale (trim (str ,3 ) )
  IF ((textlen (_::getlocale (null ) ) = 0 ) )
   CALL _::setlocale (_::getdomainlocale (null ) )
  ELSE
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo (build2 ("Current Domain locale value: " ,_::getdomainlocale (null ) ) )
    CALL echo (build2 ("Overriding locale to: " ,str ) )
   ENDIF
   SET PRIVATE::overrideind = 1
  ENDIF
  CALL _::setlangid (cnvtlower (substring (1 ,2 ,_::getlocale (null ) ) ) )
  CALL _::setlanglocaleid (cnvtupper (substring (4 ,2 ,_::getlocale (null ) ) ) )
  SET tlangid = _::getlangid (null )
  SET tlanglocaleid = _::getlanglocaleid (null )
  CASE (tlangid )
   OF "en" :
    CALL _::setlocalefilename ("locale" )
    CALL _::setlocaleobjectname ("en_US" )
    IF ((((cnvtupper (_::getlocale (null ) ) = "EN_AU" ) ) OR ((cnvtupper (_::getlocale (null ) ) =
    "EN_GB" ) )) )
     CALL _::setlocaleobjectname (concat (tlangid ,"_" ,tlanglocaleid ) )
     CALL _::setlocalefilename (concat ("locale." ,tlangid ,"_" ,tlanglocaleid ) )
     CALL _::setlocale (substring (1 ,5 ,_::getlocale (null ) ) )
     CALL _::setworklistfilename (concat (cnvtupper (tlangid ) ,"_" ,cnvtupper (tlanglocaleid ) ) )
    ELSE
     CALL _::setlocale ("EN_US" )
     CALL _::setworklistfilename ("EN_US" )
    ENDIF
   OF "es" :
   OF "de" :
   OF "fr" :
   OF "pt" :
    CALL _::setlocalefilename (concat ("locale." ,tlangid ) )
    CALL _::setlocaleobjectname (concat (tlangid ,"_" ,tlanglocaleid ) )
    CALL _::setlocale (substring (1 ,5 ,_::getlocale (null ) ) )
    IF ((cnvtupper (tlangid ) = "PT" ) )
     CALL _::setworklistfilename ("PT_BR" )
    ELSE
     CALL _::setworklistfilename (concat (cnvtupper (tlangid ) ,"_" ,cnvtupper (tlangid ) ) )
    ENDIF
   ELSE
    CALL _::setlocalefilename ("locale" )
    CALL _::setlocaleobjectname ("en_US" )
    CALL _::setlocale ("EN_US" )
    CALL _::setworklistfilename ("EN_US" )
  ENDCASE
  IF ((PRIVATE::overrideind = 0 ) )
   CALL uar_i18nlocalizationinit (i18nhandle ,nullterm (curprog ) ,nullterm ("" ) ,curcclrev )
   CALL _::seti18nhandle (i18nhandle )
  ELSE
   CALL uar_i18nlocalizationinit (i18nhandle ,nullterm (curprog ) ,nullterm (_::getlocale (null ) ) ,
    curcclrev )
   CALL _::seti18nhandle (i18nhandle )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo ("**** OVERRIDING VALUES IN CCLFMT ****" )
    CALL echo ("CCLFMT BEFORE OVERRIDE:" )
    CALL echorecord (cclfmt )
   ENDIF
   EXECUTE cclstartup_locale _::getlocale (null )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo ("CCLFMT AFTER OVERRIDE:" )
    CALL echorecord (cclfmt )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  _::dump (null )
  CALL echorecord (PRIVATE::settings )
 END ;Subroutine
 IF (validate (log_program_name ) )
  CALL _::setlogprgname (log_program_name )
 ELSE
  CALL _::setlogprgname (curprog )
 ENDIF
 IF (validate (_mp_18n_override ) )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (_mp_18n_override )
  ENDIF
  SET PRIVATE::override_prg_global_pos = locateval (PRIVATE::locidx ,1 ,size (_mp_18n_override->
    scripts ,5 ) ,cnvtupper (_::getlogprgname (null ) ) ,cnvtupper (_mp_18n_override->scripts[
    PRIVATE::locidx ].name ) ,0.0 ,_mp_18n_override->scripts[PRIVATE::locidx ].prsnl_id )
  SET PRIVATE::override_prg_prsnl_pos = locateval (PRIVATE::locidx ,1 ,size (_mp_18n_override->
    scripts ,5 ) ,cnvtupper (_::getlogprgname (null ) ) ,cnvtupper (_mp_18n_override->scripts[
    PRIVATE::locidx ].name ) ,reqinfo->updt_id ,_mp_18n_override->scripts[PRIVATE::locidx ].prsnl_id
   )
  SET PRIVATE::override_all_global_pos = locateval (PRIVATE::locidx ,1 ,size (_mp_18n_override->
    scripts ,5 ) ,"ALL" ,cnvtupper (_mp_18n_override->scripts[PRIVATE::locidx ].name ) ,0.0 ,
   _mp_18n_override->scripts[PRIVATE::locidx ].prsnl_id )
  SET PRIVATE::override_all_prsnl_pos = locateval (PRIVATE::locidx ,1 ,size (_mp_18n_override->
    scripts ,5 ) ,"ALL" ,cnvtupper (_mp_18n_override->scripts[PRIVATE::locidx ].name ) ,reqinfo->
   updt_id ,_mp_18n_override->scripts[PRIVATE::locidx ].prsnl_id )
  IF ((PRIVATE::override_prg_prsnl_pos > 0 ) )
   CALL _::setlocale (_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos ].locale )
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos ].localefile ) )
    CALL _::setlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos ].localefile
      )
   ENDIF
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos ].worklistlocalefile ) )
    CALL _::setworklistlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos ].
     worklistlocalefile )
   ENDIF
  ELSEIF ((PRIVATE::override_all_prsnl_pos > 0 ) )
   CALL _::setlocale (_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos ].locale )
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos ].localefile ) )
    CALL _::setlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos ].localefile
      )
   ENDIF
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos ].worklistlocalefile ) )
    CALL _::setworklistlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos ].
     worklistlocalefile )
   ENDIF
  ELSEIF ((PRIVATE::override_prg_global_pos > 0 ) )
   CALL _::setlocale (_mp_18n_override->scripts[PRIVATE::override_prg_global_pos ].locale )
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_prg_global_pos ].localefile ) )
    CALL _::setlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_prg_global_pos ].
     localefile )
   ENDIF
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_prg_global_pos ].worklistlocalefile ) )
    CALL _::setworklistlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_prg_global_pos ].
     worklistlocalefile )
   ENDIF
  ELSEIF ((PRIVATE::override_all_global_pos > 0 ) )
   CALL _::setlocale (_mp_18n_override->scripts[PRIVATE::override_all_global_pos ].locale )
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_all_global_pos ].localefile ) )
    CALL _::setlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_all_global_pos ].
     localefile )
   ENDIF
   IF (validate (_mp_18n_override->scripts[PRIVATE::override_all_global_pos ].worklistlocalefile ) )
    CALL _::setworklistlocalefilepath (_mp_18n_override->scripts[PRIVATE::override_all_global_pos ].
     worklistlocalefile )
   ENDIF
  ENDIF
 ENDIF
 CALL _::initlocale (_::getlocale (null ) )
 IF ((checkfun ("LOG_MESSAGE" ) = 7 ) )
  CALL log_message (concat ("-mp_i18n Locale file name: " ,_::getlocalefilename (null ) ) ,
   log_level_debug )
  CALL log_message (concat ("-mp_i18n Worklist Locale file name: " ,_::getworklistfilename (null ) )
   ,log_level_debug )
  CALL log_message (concat ("-mp_i18n Locale object name: " ,_::getlocaleobjectname (null ) ) ,
   log_level_debug )
 ENDIF
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echo (concat ("END MP_I18N object creation, Elapsed time:" ,cnvtstring (timestampdiff (
      systimestamp ,class_begin_ts ) ,17 ,4 ) ) )
  CALL _::dump (null )
 ENDIF
 END; class scope:init
 final
 IF ((PRIVATE::overrideind = 1 ) )
  EXECUTE cclstartup_locale _::getdomainlocale (null )
  IF ((checkprg ("CCLSTARTUP_CUSTREFLOG" ) > 0 ) )
   EXECUTE cclstartup_custreflog
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo ("**** REVERTED OVERRIDDEN VALUES IN CCLFMT ****" )
   CALL echo ("CCLFMT AFTER OVERRIDE REVERT:" )
   CALL echorecord (cclfmt )
  ENDIF
 ENDIF
 END; class scope:final
 WITH copy = 0
 DECLARE MP::i18n = null WITH class (mp_i18n )
 DECLARE getflexedsettingskey_dummy = vc WITH protect ,noconstant ("" )
 SUBROUTINE  (getflexid (pos_cd =f8 ,locrecord =vc (ref ) ,cached_settings =vc (ref ) ,
  parent_entity_name =vc (value ,"" ) ) =null WITH protect )
  CALL log_message ("In getFlexId()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH private ,constant (curtime3 )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  FOR (index = 1 TO size (cached_settings->mpage ,5 ) )
   SET cached_settings->mpage[index ].nurse_unit_flex_id = - (1 )
   SET cached_settings->mpage[index ].building_flex_id = - (1 )
   SET cached_settings->mpage[index ].facility_flex_id = - (1 )
   SET cached_settings->mpage[index ].position_flex_id = - (1 )
  ENDFOR
  CALL getflexidforpositionflexing (pos_cd ,parent_entity_name )
  IF ((locrecord->facilitycd = 0.0 )
  AND (locrecord->buildingcd = 0.0 )
  AND (locrecord->nurseunitcd = 0.0 ) )
   RETURN (null )
  ENDIF
  CALL getflexidforpositionlocationflexing (pos_cd ,locrecord ,parent_entity_name )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo ("Flex Settings:" )
   CALL echorecord (cached_settings )
  ENDIF
  CALL log_message (build ("Exit getFlexId(), Elapsed time:" ,((curtime3 - begin_date_time ) / 100.0
    ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getflexidforpositionlocationflexing (pos_cd =f8 ,locrecord =vc (ref ) ,
  parent_entity_name =vc (value ,"" ) ) =null WITH protect )
  CALL log_message ("In getFlexIdForPositionLocationFlexing()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH private ,constant (curtime3 )
  DECLARE parser_const = c3 WITH protect ,constant ("1=1" )
  DECLARE bdr_const = c45 WITH protect ,constant ("bdv.parent_entity_name = ^BR_DATAMART_REPORT^" )
  DECLARE br_parser = vc WITH protect ,constant (evaluate (parent_entity_name ,"BR_DATAMART_REPORT" ,
    bdr_const ,parser_const ) )
  IF ((pos_cd <= 0.0 ) )
   RETURN (null )
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (size (cached_settings->mpage ,5 ) ) ),
    (br_datamart_category bdc ),
    (br_datamart_value bdv ),
    (br_datamart_flex flex1 ),
    (br_datamart_flex flex2 )
   PLAN (d
    WHERE (d.seq > 0 ) )
    JOIN (bdc
    WHERE (bdc.category_mean = cached_settings->mpage[d.seq ].cat_mean )
    AND (bdc.flex_flag = 3 ) )
    JOIN (bdv
    WHERE (bdv.br_datamart_category_id = bdc.br_datamart_category_id )
    AND parser (br_parser ) )
    JOIN (flex1
    WHERE (flex1.br_datamart_flex_id = bdv.br_datamart_flex_id )
    AND (flex1.parent_entity_id IN (locrecord->nurseunitcd ,
    locrecord->buildingcd ,
    locrecord->facilitycd ) )
    AND (flex1.parent_entity_type_flag = 2 ) )
    JOIN (flex2
    WHERE (flex2.br_datamart_flex_id = flex1.grouper_flex_id )
    AND (flex2.parent_entity_id = pos_cd )
    AND (flex2.parent_entity_type_flag = 1 ) )
   ORDER BY d.seq ,
    flex1.parent_entity_id
   HEAD d.seq
    row + 0
   HEAD flex1.parent_entity_id
    IF ((locrecord->nurseunitcd > 0.0 )
    AND (flex1.parent_entity_id = locrecord->nurseunitcd ) ) cached_settings->mpage[d.seq ].
     nurse_unit_flex_id = flex1.br_datamart_flex_id ,cached_settings->mpage[d.seq ].
     pos_loc_settings_ind = 1
    ELSEIF ((locrecord->buildingcd > 0.0 )
    AND (flex1.parent_entity_id = locrecord->buildingcd ) ) cached_settings->mpage[d.seq ].
     building_flex_id = flex1.br_datamart_flex_id ,cached_settings->mpage[d.seq ].
     pos_loc_settings_ind = 1
    ELSEIF ((locrecord->facilitycd > 0.0 )
    AND (flex1.parent_entity_id = locrecord->facilitycd ) ) cached_settings->mpage[d.seq ].
     facility_flex_id = flex1.br_datamart_flex_id ,cached_settings->mpage[d.seq ].
     pos_loc_settings_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"BR_DATAMART_FLEX" ,"getFlexIdForPositionLocationFlexing" ,
   1 ,0 ,cached_settings )
  CALL log_message (build ("Exit getFlexIdForPositionLocationFlexing(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getflexidforpositionflexing (pos_cd =f8 ,parent_entity_name =vc (value ,"" ) ) =null
  WITH protect )
  CALL log_message ("In getFlexIdForPositionFlexing()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH private ,constant (curtime3 )
  DECLARE parser_const = c3 WITH protect ,constant ("1=1" )
  DECLARE bdr_const = c45 WITH protect ,constant ("bv.parent_entity_name = ^BR_DATAMART_REPORT^" )
  DECLARE br_parser = vc WITH protect ,constant (evaluate (parent_entity_name ,"BR_DATAMART_REPORT" ,
    bdr_const ,parser_const ) )
  IF ((pos_cd <= 0.0 ) )
   RETURN (null )
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (size (cached_settings->mpage ,5 ) ) ),
    (br_datamart_category bdc ),
    (br_datamart_value bv ),
    (br_datamart_flex flex )
   PLAN (d
    WHERE (d.seq > 0 ) )
    JOIN (bdc
    WHERE (bdc.category_mean = cached_settings->mpage[d.seq ].cat_mean ) )
    JOIN (bv
    WHERE (bv.br_datamart_category_id = bdc.br_datamart_category_id )
    AND parser (br_parser ) )
    JOIN (flex
    WHERE (flex.br_datamart_flex_id = bv.br_datamart_flex_id )
    AND (flex.parent_entity_id = pos_cd ) )
   ORDER BY d.seq
   HEAD d.seq
    cached_settings->mpage[d.seq ].position_flex_id = flex.br_datamart_flex_id
   WITH nocounter
  ;end select
  CALL error_and_zero_check_rec (curqual ,"BR_DATAMART_FLEX" ,"getFlexIdForPositionFlexing" ,1 ,0 ,
   cached_settings )
  CALL log_message (build ("Exit getFlexIdForPositionFlexing(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getflexedsettingskey (position_cd =f8 ,position_flex_id =f8 ,pos_loc_settings_ind =i2 (
   value ,0 ) ,nurse_unit_flex_id =f8 (value ,0.0 ) ,building_flex_id =f8 (value ,0.0 ) ,
  facility_flex_id =f8 (value ,0.0 ) ,locrecord =vc (ref ,getflexedsettingskey_dummy ) ) =vc WITH
  protect )
  CALL log_message ("In getFlexedSettingsKey()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH private ,constant (curtime3 )
  DECLARE flexed_settings_key = vc WITH protect ,noconstant ("" )
  IF ((((position_flex_id > 0.0 ) ) OR ((pos_loc_settings_ind = 1 ) )) )
   IF ((position_cd > 0.0 ) )
    SET flexed_settings_key = build2 ("|" ,trim (cnvtstring (position_cd ,40 ) ) )
   ELSE
    CALL log_message (build ("getFlexedSettingsKey():" ,
      "Position code has not been defined for flexed settings" ) ,log_level_debug )
    RETURN (flexed_settings_key )
   ENDIF
  ENDIF
  IF ((pos_loc_settings_ind = 1 )
  AND (validate (locrecord->facilitycd ,- (1 ) ) != - (1 ) ) )
   IF ((locrecord->facilitycd = 0.0 )
   AND (locrecord->buildingcd = 0.0 )
   AND (locrecord->nurseunitcd = 0.0 ) )
    CALL log_message (build ("getFlexedSettingsKey():" ,
      "Encounter location values not been defined for flexed settings" ,log_level_debug ) )
    RETURN (flexed_settings_key )
   ENDIF
   IF ((nurse_unit_flex_id > 0.0 ) )
    SET flexed_settings_key = build2 (flexed_settings_key ,"|" ,trim (cnvtstring (locrecord->
       nurseunitcd ,40 ) ) )
   ELSEIF ((building_flex_id > 0.0 ) )
    SET flexed_settings_key = build2 (flexed_settings_key ,"|" ,trim (cnvtstring (locrecord->
       buildingcd ,40 ) ) )
   ELSEIF ((facility_flex_id > 0.0 ) )
    SET flexed_settings_key = build2 (flexed_settings_key ,"|" ,trim (cnvtstring (locrecord->
       facilitycd ,40 ) ) )
   ENDIF
  ENDIF
  CALL log_message (build ("getFlexedSettingsKey():" ,flexed_settings_key ) ,log_level_debug )
  CALL log_message (build ("Exit getFlexedSettingsKey(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
  RETURN (trim (flexed_settings_key ,3 ) )
 END ;Subroutine
 FREE RECORD splunk_hec_config
 RECORD splunk_hec_config (
   1 http_event_collector_url = vc
   1 http_event_collector_token = vc
   1 max_retry_count = f8
   1 client_mnemonic = vc
   1 current_domain = vc
   1 is_splunk_logger_active = f8
   1 status_data
     2 status = c1
     2 status_message = vc
 )
 DECLARE getsplunkhecconfig (null ) = null WITH protect
 SUBROUTINE  getsplunkhecconfig (null )
  CALL log_message ("In GetSplunkHECConfig()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  EXECUTE mp_get_splunk_hec_config "^MINE^" WITH replace ("REPLY" ,"SPLUNK_HEC_CONFIG" )
  IF ((splunk_hec_config->status_data.status = "S" ) )
   CALL log_message ("Found splunk HEC configuration" ,log_level_debug )
  ELSEIF ((splunk_hec_config->status_data.status = "Z" ) )
   CALL log_message ("No splunk HEC configuration found" ,log_level_debug )
  ELSEIF ((splunk_hec_config->status_data.status = "F" ) )
   CALL log_message ("Failed to fetch splunk HEC configuration" ,log_level_debug )
  ENDIF
  CALL log_message (build ("Exit GetSplunkHECConfig(), Elapsed time:" ,((curtime3 - begin_date_time
    ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 IF ((validate (request_reply ) = 0 ) )
  RECORD request_reply (
    1 requesturi = vc
    1 params = vc
    1 responsecode = i4
    1 responsetext = vc
    1 responsebody = vc
    1 responseheaders [* ]
      2 name = vc
      2 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ((validate (uar_xml_parsestring ) = 0 ) )
  DECLARE uar_xml_parsestring ((xmlstring = vc ) ,(filehandle = i4 (ref ) ) ) = i4
 ENDIF
 IF ((validate (uar_xml_getroot ) = 0 ) )
  DECLARE uar_xml_getroot ((filehandle = i4 (ref ) ) ,(nodehandle = i4 (ref ) ) ) = i4
 ENDIF
 IF ((validate (uar_xml_getchildnode ) = 0 ) )
  DECLARE uar_xml_getchildnode ((nodehandle = i4 (ref ) ) ,(nodenumber = i4 (ref ) ) ,(childnode =
   i4 (ref ) ) ) = i4
 ENDIF
 IF ((validate (uar_xml_getchildcount ) = 0 ) )
  DECLARE uar_xml_getchildcount ((nodehandle = i4 (ref ) ) ) = i4
 ENDIF
 IF ((validate (uar_xml_getnodename ) = 0 ) )
  DECLARE uar_xml_getnodename ((nodehandle = i4 (ref ) ) ) = vc
 ENDIF
 IF ((validate (uar_xml_findchildnode ) = 0 ) )
  DECLARE uar_xml_findchildnode ((nodehandle = i4 (ref ) ) ,(nodename = vc ) ,(childhandle = i4 (ref
    ) ) ) = i4
 ENDIF
 IF ((validate (uar_xml_getnodecontent ) = 0 ) )
  DECLARE uar_xml_getnodecontent ((nodehandle = i4 (ref ) ) ) = vc
 ENDIF
 DECLARE getoauthheader (null ) = vc
 SUBROUTINE  (cleanuphandles (requesthandle =i4 ,replyhandle =i4 ) =null )
  IF ((requesthandle != 0 ) )
   CALL uar_srvdestroyinstance (requesthandle )
  ENDIF
  IF ((replyhandle != 0 ) )
   CALL uar_srvdestroyinstance (replyhandle )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getmillenniumserviceentry (servicekey =vc ) =vc )
  CALL log_message ("In mp_millennium_services_directory.getMillenniumServiceEntry()" ,
   log_level_debug )
  DECLARE gmse_begin_date_time = dm12 WITH private ,constant (systimestamp )
  DECLARE servicedirectorylookupmsg = i4 WITH protect ,constant (uar_srvselectmessage (477783 ) )
  DECLARE servicedirectorylookuprequest = i4 WITH protect ,constant (uar_srvcreaterequest (
    servicedirectorylookupmsg ) )
  DECLARE servicedirectorylookupreply = i4 WITH protect ,constant (uar_srvcreatereply (
    servicedirectorylookupmsg ) )
  DECLARE stat = i4 WITH protect ,noconstant (0 )
  DECLARE statusstruct = i4 WITH protect ,noconstant (0 )
  DECLARE successind = vc WITH protect ,noconstant ("" )
  DECLARE millenniumserviceentry = vc WITH protect ,noconstant ("" )
  SET stat = uar_srvsetstring (servicedirectorylookuprequest ,"key" ,nullterm (servicekey ) )
  IF ((stat = 0 ) )
   CALL log_message ("Failed to set orion service url key" ,log_level_error )
   CALL cleanuphandles (servicedirectorylookuprequest ,servicedirectorylookupreply )
   RETURN ("" )
  ENDIF
  SET stat = uar_srvexecute (servicedirectorylookupmsg ,servicedirectorylookuprequest ,
   servicedirectorylookupreply )
  IF ((stat != 0 ) )
   CALL log_message ("Failed to retrieve orion service url. uar_SrvExecute failure" ,log_level_error
    )
   CALL cleanuphandles (servicedirectorylookuprequest ,servicedirectorylookupreply )
   RETURN ("" )
  ENDIF
  SET statusstruct = uar_srvgetstruct (servicedirectorylookupreply ,"status_data" )
  IF ((statusstruct = 0 ) )
   CALL log_message ("Failed to retrieve orion service url. Error retrieving status_data" ,
    log_level_error )
   CALL cleanuphandles (servicedirectorylookuprequest ,servicedirectorylookupreply )
   RETURN ("" )
  ENDIF
  SET successind = uar_srvgetstringptr (statusstruct ,"status" )
  IF ((successind != "S" ) )
   CALL log_message ("Failed to retrieve orion service url. Call returned a non success status" ,
    log_level_error )
   CALL cleanuphandles (servicedirectorylookuprequest ,servicedirectorylookupreply )
   RETURN ("" )
  ENDIF
  SET millenniumserviceentry = uar_srvgetstringptr (servicedirectorylookupreply ,"url" )
  CALL cleanuphandles (servicedirectorylookuprequest ,servicedirectorylookupreply )
  CALL log_message (build (
    "Exit mp_millennium_services_directory.getMillenniumServiceEntry(), Elapsed time:" ,cnvtstring (
     timestampdiff (systimestamp ,gmse_begin_date_time ) ,17 ,4 ) ) ,log_level_debug )
  RETURN (millenniumserviceentry )
 END ;Subroutine
 SUBROUTINE  getoauthheader (null )
  CALL log_message ("In mp_millennium_services_directory.getOAuthHeader()" ,log_level_debug )
  DECLARE goah_begin_date_time = dm12 WITH private ,constant (systimestamp )
  DECLARE oauthmessage = i4 WITH protect ,constant (uar_srvselectmessage (99999131 ) )
  DECLARE oauthrequest = i4 WITH protect ,constant (uar_srvcreaterequest (oauthmessage ) )
  DECLARE oauthresponse = i4 WITH protect ,constant (uar_srvcreatereply (oauthmessage ) )
  DECLARE oauthstatus = i4 WITH protect ,noconstant (0 )
  DECLARE stat = i4 WITH protect ,noconstant (0 )
  DECLARE oauthresponsestruct = i4 WITH protect ,noconstant (0 )
  DECLARE oauthtoken = vc WITH protect ,noconstant ("" )
  DECLARE oauthconsumerkey = vc WITH protect ,noconstant ("" )
  DECLARE oauthsignature = vc WITH protect ,noconstant ("" )
  DECLARE oauthsignaturemethod = vc WITH protect ,constant ("PLAINTEXT" )
  DECLARE epochdatestart = f8 WITH private ,constant ((cnvtdatetime ("01-JAN-1970" ) / 10000000 ) )
  DECLARE epochdatecurrent = f8 WITH private ,noconstant (0.0 )
  DECLARE epochdate = i4 WITH private ,noconstant (0 )
  DECLARE oauthtimestamp = vc WITH private ,noconstant ("" )
  DECLARE oauthnonce = vc WITH private ,noconstant ("" )
  SET stat = uar_srvexecute (oauthmessage ,oauthrequest ,oauthresponse )
  IF ((stat != 0 ) )
   CALL log_message ("Failed to retrieve oAuth header. uar_SrvExecute failure" ,log_level_error )
   CALL cleanuphandles (oauthrequest ,oauthresponse )
   RETURN ("" )
  ENDIF
  SET oauthstatus = uar_srvgetstruct (oauthresponse ,"status" )
  SET stat = uar_srvgetshort (oauthstatus ,"success_ind" )
  IF ((stat = 0 ) )
   CALL log_message ("Failed to retrieve oAuth header. Call returned a non success status" ,
    log_level_error )
   CALL cleanuphandles (oauthrequest ,oauthresponse )
   RETURN ("" )
  ENDIF
  SET oauthresponsestruct = uar_srvgetstruct (oauthresponse ,"oauth_access_token" )
  SET oauthtoken = uar_srvgetstringptr (oauthresponsestruct ,"oauth_token" )
  SET oauthconsumerkey = uar_srvgetstringptr (oauthresponsestruct ,"oauth_consumer_key" )
  SET oauthtokensecret = uar_srvgetstringptr (oauthresponsestruct ,"oauth_token_secret" )
  SET oauthaccessorsecret = uar_srvgetstringptr (oauthresponsestruct ,"oauth_accessor_secret" )
  SET oauthsignature = trim (concat (oauthaccessorsecret ,"%26" ,oauthtokensecret ) ,3 )
  SET epochdatecurrent = (cnvtdatetime (sysdate ) / 10000000 )
  SET epochdate = (epochdatecurrent - epochdatestart )
  SET oauthtimestamp = trim (cnvtstring (epochdate ) ,3 )
  SET oauthnonce = trim (format ((epochdatecurrent * epochdatestart ) ,build (fillstring (31 ,"#" ) ,
     ";T(1)" ) ) ,3 )
  CALL cleanuphandles (oauthrequest ,oauthresponse )
  CALL log_message (build ("Exit mp_millennium_services_directory.getOAuthHeader(), Elapsed time:" ,
    cnvtstring (timestampdiff (systimestamp ,goah_begin_date_time ) ,17 ,4 ) ) ,log_level_debug )
  RETURN (concat ('OAuth oauth_token="' ,oauthtoken ,'", oauth_consumer_key="' ,oauthconsumerkey ,
   '", oauth_signature_method="' ,oauthsignaturemethod ,'", oauth_signature="' ,oauthsignature ,
   '", oauth_timestamp="' ,oauthtimestamp ,'", oauth_nonce="' ,oauthnonce ,'"' ) )
 END ;Subroutine
 SUBROUTINE  (getworkflowurl (viewpointfiltermeaning =vc ) =vc )
  CALL log_message ("In mp_millennium_services_directory.getWorkflowURL()" ,log_level_debug )
  DECLARE gcsu_begin_date_time = dm12 WITH private ,constant (systimestamp )
  DECLARE responsecachedind = i2 WITH protect ,noconstant (1 )
  DECLARE workflowurlresponse = vc WITH protect ,noconstant (trim (getnamespacedsettings ("orion" ,
     "workflow-url-response" ) ,3 ) )
  DECLARE orionserviceurl = vc WITH protect ,noconstant ("" )
  DECLARE orionservicekeyurl = vc WITH protect ,noconstant ("" )
  DECLARE oauthheaders = vc WITH protect ,noconstant ("" )
  DECLARE stat = i4 WITH protect ,noconstant (0 )
  DECLARE overridecount = i4 WITH protect ,noconstant (0 )
  DECLARE workflowurl = vc WITH protect ,noconstant ("" )
  IF ((textlen (workflowurlresponse ) = 0 ) )
   SET responsecachedind = 0
   SET orionserviceurl = trim (getmillenniumserviceentry (
     "urn:cerner:api:orion-directory-service.json" ) ,3 )
   IF ((textlen (orionserviceurl ) = 0 ) )
    CALL log_message ("getMillenniumServiceEntry failed" ,log_level_error )
    RETURN ("" )
   ENDIF
   SET orionservicekeyurl = build2 (orionserviceurl ,"directories/static-assets?key=workflow" )
   SET oauthheaders = trim (getoauthheader (null ) ,3 )
   IF ((textlen (oauthheaders ) = 0 ) )
    CALL log_message ("getOAuthHeader failed" ,log_level_error )
    RETURN ("" )
   ENDIF
   EXECUTE mp_ccl_http_req "NOFORMS" ,
   "" ,
   orionservicekeyurl ,
   "" ,
   "" ,
   "" ,
   nullterm (oauthheaders )
   IF ((request_reply->status_data.status = "F" ) )
    CALL log_message ("Call to Orion Service Directory failed" ,log_level_error )
    RETURN ("" )
   ENDIF
   SET workflowurlresponse = request_reply->responsebody
  ENDIF
  SET stat = cnvtjsontorec (build ('{"jsonResponse",' ,substring (2 ,(textlen (workflowurlresponse )
     - 2 ) ,workflowurlresponse ) ,"}" ) )
  IF ((stat = 0 ) )
   CALL log_message ("Failed to parse Orion Service Directory JSON" ,log_level_error )
   RETURN ("" )
  ENDIF
  IF ((validate (jsonresponse->overrides ) != 0 ) )
   SET overridecount = size (jsonresponse->overrides ,5 )
   FOR (override = 1 TO overridecount )
    IF ((jsonresponse->overrides[override ].viewpointfiltermeaning = viewpointfiltermeaning ) )
     SET workflowurl = trim (jsonresponse->overrides[override ].url ,3 )
     CALL log_message (build (
       "Exit override mp_millennium_services_directory.getWorkflowURL(), Elapsed time:" ,cnvtstring (
        timestampdiff (systimestamp ,gcsu_begin_date_time ) ,17 ,4 ) ) ,log_level_debug )
     FREE RECORD jsonresponse
     RETURN (workflowurl )
    ENDIF
   ENDFOR
  ENDIF
  IF ((validate (jsonresponse->url ) = 0 ) )
   CALL log_message ("URL not present in Orion Service Directory JSON" ,log_level_error )
   FREE RECORD jsonresponse
   RETURN ("" )
  ENDIF
  SET workflowurl = trim (jsonresponse->url ,3 )
  IF ((responsecachedind = 0 )
  AND (textlen (workflowurl ) > 0 ) )
   CALL cachenamespacedsettings ("orion" ,"workflow-url-response" ,workflowurlresponse )
  ENDIF
  FREE RECORD jsonresponse
  CALL log_message (build ("Exit mp_millennium_services_directory.getWorkflowURL(), Elapsed time:" ,
    cnvtstring (timestampdiff (systimestamp ,gcsu_begin_date_time ) ,17 ,4 ) ) ,log_level_debug )
  RETURN (workflowurl )
 END ;Subroutine
 DECLARE parseoverloadedcategorymean (null ) = null WITH protect
 DECLARE parseoverloadedstaticcontentlocation (null ) = null WITH protect
 DECLARE populatecriterionrec (null ) = null WITH protect
 DECLARE populatelocalefilepath (null ) = null WITH protect
 DECLARE determinempagetype (null ) = null WITH protect
 DECLARE loadviewpointsettings (null ) = null WITH protect
 DECLARE getmpagesettings (null ) = null WITH protect
 DECLARE generatecontentrequirements (null ) = null WITH protect
 DECLARE getchartsearchurl (null ) = vc WITH protect
 DECLARE generatempagehtml (null ) = null WITH protect
 DECLARE generatecomponenttokens (null ) = null WITH protect
 DECLARE resolvestaticcontenturl (null ) = null WITH protect
 DECLARE determineviewfilters (null ) = null WITH protect
 DECLARE determinedeferredloadcompatibility (null ) = null WITH protect
 DECLARE generatecontenturlsbycategory (null ) = null WITH protect
 DECLARE getbindingmappings (null ) = vc WITH protect
 DECLARE static_content_folder = vc WITH protect ,constant ("UnifiedContent" )
 DECLARE custom_content_folder = vc WITH protect ,constant ("custom_mpage_content" )
 DECLARE unspecified_category = vc WITH protect ,constant ("__UNSPECIFIED_CATEGORY" )
 DECLARE chartsearchflag = i2 WITH protect ,noconstant (false )
 DECLARE componenttokens = vc WITH protect ,noconstant ("" )
 DECLARE escapedtokens = vc WITH protect ,noconstant ("" )
 DECLARE contentserverurl = vc WITH protect ,noconstant ("" )
 DECLARE cssgrouplinktags = vc WITH protect ,noconstant ("" )
 DECLARE cssreqs = vc WITH protect ,noconstant ("" )
 DECLARE curencntrtype = f8 WITH protect ,noconstant (0 )
 DECLARE overridelocaleasus = i2 WITH protect ,noconstant (btest ( $DEBUG_MAP ,1 ) )
 DECLARE usecustomcomponentexamples = i2 WITH protect ,noconstant (btest ( $DEBUG_MAP ,2 ) )
 DECLARE ignorecache = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,3 ) )
 DECLARE allowdynamiccontentbuild = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,4 ) )
 DECLARE enableedgemode = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,5 ) )
 DECLARE contentfromcloud = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,6 ) )
 DECLARE forcelegacycontentload = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,7 ) )
 DECLARE forcedeferredcontentload = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,8 ) )
 DECLARE alvaenabled = i4 WITH protect ,noconstant (btest ( $DEBUG_MAP ,9 ) )
 DECLARE legacycontentload = i4 WITH protect ,noconstant (true )
 DECLARE jsgroupscripttags = vc WITH protect ,noconstant ("" )
 DECLARE javascriptreqs = vc WITH protect ,noconstant ("" )
 DECLARE loadviewpointflag = i2 WITH protect ,noconstant (false )
 DECLARE loadcustomcomponents = i4 WITH protect ,noconstant (true )
 DECLARE loadingmpagesreach = i2 WITH protect ,noconstant (false )
 DECLARE mpagecatid = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpagesettingsjson = vc WITH protect ,noconstant ("" )
 DECLARE renderfunction = vc WITH protect ,noconstant (" " )
 DECLARE categorymean = vc WITH protect ,noconstant ("" )
 DECLARE defaultviewcatmean = vc WITH protect ,noconstant ("" )
 DECLARE defaultviewind = i4 WITH protect ,noconstant (0 )
 DECLARE basegroupid = vc WITH protect ,noconstant ("" )
 DECLARE staticcontenturl = vc WITH protect ,noconstant ("" )
 DECLARE cdcontentserverurl = vc WITH protect ,noconstant ("" )
 DECLARE utilizempages5xmappings = i2 WITH protect ,noconstant (false )
 DECLARE basecontentfolder = vc WITH protect ,noconstant (nullterm ("" ) )
 DECLARE basegroupreleaseident = vc WITH protect ,noconstant ("" )
 DECLARE basegroupreleaseversion = vc WITH protect ,noconstant ("" )
 DECLARE viewstaticcontentjson = vc WITH protect ,noconstant ("" )
 DECLARE chartsearchcss = vc WITH protect ,noconstant ("" )
 DECLARE flexedkeysuffix = vc WITH protect ,noconstant ("" )
 DECLARE requestbindingjson = vc WITH protect ,noconstant ("" )
 DECLARE mp_common_imported = vc WITH protect
 CALL parseoverloadedcategorymean (null )
 CALL parseoverloadedstaticcontentlocation (null )
 CALL populatecriterionrec (null )
 CALL getsplunkhecconfig (null )
 CALL populatelocalefilepath (null )
 CALL determinempagetype (null )
 IF ((loadingmpagesreach != true ) )
  CALL loadviewpointsettings (null )
 ENDIF
 CALL getmpagesettings (null )
 IF ((contentserverurl != "" ) )
  CALL determinedeferredloadcompatibility (null )
  CALL generatecomponenttokens (null )
 ELSE
  SET legacycontentload = true
 ENDIF
 IF ((alvaenabled = 1 ) )
  SET requestbindingjson = getbindingmappings (null )
 ENDIF
 CALL generatecontentrequirements (null )
 CALL generatempagehtml (null )
 SUBROUTINE  getbindingmappings (null )
  CALL log_message ("In GetBindingMappings()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE requestbindings = vc WITH noconstant ("" ) ,private
  IF ((checkprg ("MP_GET_BINDING_MAPPINGS" ) > 0 ) )
   EXECUTE mp_get_binding_mappings
   IF (validate (mpages_request_bindings ) )
    SET requestbindings = cnvtrectojson (mpages_request_bindings )
   ENDIF
  ENDIF
  CALL log_message (build ("Exit GetBindingMappings(), Elapsed time:" ,((curtime3 - begin_date_time
    ) / 100.0 ) ) ,log_level_debug )
  RETURN (requestbindings )
 END ;Subroutine
 SUBROUTINE  parseoverloadedcategorymean (null )
  SET categorymean = trim (piece (cnvtupper ( $CATEGORY_MEAN ) ,":" ,1 ,"" ) ,3 )
  SET defaultviewcatmean = trim (piece (cnvtupper ( $CATEGORY_MEAN ) ,":" ,2 ,"" ) ,3 )
  SET defaultviewind = 0
  IF ((size (defaultviewcatmean ,1 ) > 0 ) )
   SET defaultviewind = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE  parseoverloadedstaticcontentlocation (null )
  SET staticcontenturl = trim (piece ( $STATIC_CONTENT ,"|" ,1 ,"" ) ,3 )
  SET basegroupid = trim (piece ( $STATIC_CONTENT ,"|" ,2 ,"" ) ,3 )
 END ;Subroutine
 SUBROUTINE  resolvestaticcontenturl (null )
  CALL log_message ("In ResolveStaticContentURL()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE subtimer = dq8 WITH private ,noconstant (curtime3 )
  IF ((basegroupid = "" ) )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    FROM (dm_info di )
    PLAN (di
     WHERE (di.info_domain = "INS" )
     AND (di.info_name = "MP_BASE_GROUP" ) )
    DETAIL
     basegroupid = trim (di.info_char ,3 )
    WITH nocounter
   ;end select
   CALL log_message (build ("ResolveStaticContentURL:Base group identification, Elapsed time:" ,((
     curtime3 - subtimer ) / 100.0 ) ) ,log_level_debug )
   IF ((basegroupid = "" ) )
    SET utilizempages5xmappings = true
   ELSEIF ((staticcontenturl != "" )
   AND (findstring ("|" , $STATIC_CONTENT ) = 0 ) )
    SET utilizempages5xmappings = true
   ELSE
    SET utilizempages5xmappings = false
   ENDIF
  ELSE
   SET utilizempages5xmappings = false
  ENDIF
  IF ((staticcontenturl = "" ) )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    FROM (dm_info d )
    WHERE (d.info_domain = "INS" )
    AND (((d.info_name = "CONTENT_SERVICE_URL" ) ) OR ((d.info_name = "CD_CONTENT_SERVICE_URL" ) ))
    DETAIL
     IF ((d.info_name = "CONTENT_SERVICE_URL" ) ) contentserverurl = trim (d.info_char ,3 )
     ENDIF
     ,
     IF ((d.info_name = "CD_CONTENT_SERVICE_URL" ) ) cdcontentserverurl = trim (d.info_char ,3 )
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message (build ("ResolveStaticContentURL:static_content server query, Elapsed time:" ,((
     curtime3 - subtimer ) / 100.0 ) ) ,log_level_debug )
   IF ((contentserverurl = "" ) )
    SET _memory_reply_string =
    "No Static Content passed to script or defined in CONTENT_SERVICE_URL"
    GO TO exit_script
   ENDIF
  ENDIF
  SET criterion->static_content_legacy = contentserverurl
  IF ((utilizempages5xmappings = true ) )
   IF ((staticcontenturl = "" ) )
    SET contentserverurl = build2 (contentserverurl ,"/" ,static_content_folder )
    SET criterion->static_content = contentserverurl
   ELSEIF ((allowdynamiccontentbuild = 1 ) )
    SET contentserverurl = staticcontenturl
    SET criterion->static_content = contentserverurl
   ELSE
    SET criterion->static_content = staticcontenturl
   ENDIF
  ELSE
   IF ((staticcontenturl != "" ) )
    IF ((allowdynamiccontentbuild = 1 ) )
     SET contentserverurl = staticcontenturl
     SET criterion->static_content = contentserverurl
    ELSE
     SET criterion->static_content = staticcontenturl
    ENDIF
   ELSE
    SET criterion->static_content = contentserverurl
   ENDIF
   IF ((alvaenabled = 1 )
   AND (cdcontentserverurl != "" ) )
    SET criterion->static_content = build (cdcontentserverurl ,"/static" )
   ENDIF
   IF ((((contentserverurl != "" ) ) OR ((alvaenabled = 1 )
   AND (cdcontentserverurl != "" ) )) )
    SET subtimer = curtime3
    SELECT INTO "nl:"
     FROM (mp_group mg ),
      (mp_release mr )
     PLAN (mg
      WHERE (mg.group_ident = basegroupid ) )
      JOIN (mr
      WHERE (mr.mp_release_id = mg.mp_release_id ) )
     DETAIL
      basecontentfolder = build2 ("/" ,mg.base_folder ) ,
      basegroupreleaseident = mr.release_ident ,
      basegroupreleaseversion = mg.version_txt
     WITH nocounter
    ;end select
    CALL log_message (build (
      "ResolveStaticContentURL:Base group release and base folder, Elapsed time:" ,((curtime3 -
      subtimer ) / 100.0 ) ) ,log_level_debug )
    IF ((((basecontentfolder = "" ) ) OR ((basecontentfolder = "/" ) )) )
     SET _memory_reply_string = build2 ("Base Group " ,basegroupid ," is not valid" )
     GO TO exit_script
    ENDIF
    IF ((basegroupreleaseident = "" ) )
     SET _memory_reply_string = build2 ("Base Group " ,basegroupid ,
      " is not associated to a release" )
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF ((validate (debug_ind ) = 1 ) )
   IF (utilizempages5xmappings )
    CALL echo ("Utilizing MPages 5.X component mappings scheme" )
   ELSE
    CALL echo ("Utilizing MPages 6.X component mappings scheme" )
    CALL echo (build2 ("Base Group Id: " ,basegroupid ) )
   ENDIF
   CALL echo (build2 ("Content Server URL: " ,contentserverurl ) )
   CALL echo (build2 ("CD Content Server URL: " ,cdcontentserverurl ) )
  ENDIF
  CALL log_message (build ("Exit ResolveStaticContentURL(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  determinedeferredloadcompatibility (null )
  IF ((forcedeferredcontentload = true ) )
   SET legacycontentload = false
  ELSEIF ((forcelegacycontentload != true )
  AND (loadingmpagesreach != true ) )
   SELECT INTO "nl:"
    FROM (dm_info d )
    WHERE (d.info_domain = "MP_DEFERRED_VIEW_COMPATIBLE" )
    AND (d.info_name = basegroupreleaseident )
   ;end select
   IF ((curqual > 0 ) )
    SET legacycontentload = false
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  populatecriterionrec (null )
  CALL log_message ("In PopulateCriterionRec()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE active_status = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
  DECLARE cnt = i4 WITH protect ,noconstant (0 )
  DECLARE subtimer = dq8 WITH private ,noconstant (curtime3 )
  SET criterion->person_id =  $PERSON_ID
  SET criterion->encntr_id =  $ENCNTR_ID
  SET criterion->prsnl_id =  $PRSNL_ID
  IF ((criterion->prsnl_id = 0.0 ) )
   SET criterion->prsnl_id = reqinfo->updt_id
  ENDIF
  SET criterion->executable =  $EXECUTABLE
  SET criterion->position_cd =  $POS_CD
  IF ((criterion->position_cd = 0.0 ) )
   SET criterion->position_cd = reqinfo->position_cd
  ENDIF
  SET criterion->ppr_cd =  $PPR_CD
  SET criterion->debug_ind =  $DEBUG_MAP
  SET criterion->category_mean = cnvtupper (categorymean )
  IF ((criterion->person_id > 0.0 ) )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    FROM (person p ),
     (person_patient pp )
    PLAN (p
     WHERE (p.person_id = criterion->person_id ) )
     JOIN (pp
     WHERE (pp.person_id = Outerjoin(p.person_id )) )
    ORDER BY p.person_id
    DETAIL
     criterion->person_info.dob = trim (format (cnvtdatetimeutc (p.birth_dt_tm ,3 ) ,
       "YYYY-MM-DDTHH:MM:SSZ;3;Q" ) ,3 ) ,
     criterion->person_info.sex_cd = p.sex_cd ,
     criterion->person_info.admin_sex_cd = p.sex_cd ,
     criterion->person_info.birth_sex_cd = pp.birth_sex_cd ,
     criterion->person_info.person_name = p.name_full_formatted ,
     criterion->logical_domain_id = p.logical_domain_id ,
     CALL addcodetolist (p.sex_cd ,criterion ) ,
     CALL addcodetolist (pp.birth_sex_cd ,criterion )
    WITH nocounter
   ;end select
   CALL log_message (build (
     "PopulateCriterionRec:person and person_patient table query, Elapsed time:" ,((curtime3 -
     subtimer ) / 100.0 ) ) ,log_level_debug )
   CALL error_and_zero_check_rec (curqual ,"Person and person_patient table query" ,"GetPatientData"
    ,1 ,0 ,criterion )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    FROM (encounter e )
    WHERE (e.person_id = criterion->person_id )
    AND (e.active_status_cd = active_status )
    DETAIL
     cnt +=1 ,
     IF ((mod (cnt ,10 ) = 1 ) ) stat = alterlist (criterion->encntr_override ,(cnt + 9 ) )
     ENDIF
     ,criterion->encntr_override[cnt ].encntr_id = e.encntr_id ,
     IF ((e.encntr_id = criterion->encntrs[1 ].encntr_id ) ) curencntrtype = e.encntr_type_cd ,
      criterion->encntr_location.facility_cd = e.loc_facility_cd
     ENDIF
    FOOT REPORT
     stat = alterlist (criterion->encntr_override ,cnt )
    WITH nocounter
   ;end select
   CALL log_message (build ("PopulateCriterionRec:encntr override query, Elapsed time:" ,((curtime3
     - subtimer ) / 100.0 ) ) ,log_level_debug )
   CALL error_and_zero_check_rec (curqual ,"Encounter override query" ,"GetEncounterOverride" ,1 ,0 ,
    criterion )
  ENDIF
  SET subtimer = curtime3
  SELECT INTO "nl:"
   FROM (dm_info d )
   WHERE (d.info_domain = "DATA MANAGEMENT" )
   AND (d.info_name = "HELP LOCATION" )
   DETAIL
    criterion->help_file_local_ind = 1
   WITH nocounter
  ;end select
  CALL log_message (build ("PopulateCriterionRec:help file query, Elapsed time:" ,((curtime3 -
    subtimer ) / 100.0 ) ) ,log_level_debug )
  SET criterion->scratchpad_cds_alerts_add = 1
  SET subtimer = curtime3
  SELECT INTO "nl:"
   FROM (dm_info d )
   WHERE (d.info_domain = "INS" )
   AND (d.info_name = "MP_SCRATCHPAD_CDS_ALERTS_ADD" )
   AND (d.info_number = 0.0 )
   DETAIL
    criterion->scratchpad_cds_alerts_add = 0
   WITH nocounter
  ;end select
  CALL log_message (build ("PopulateCriterionRec:scratchpad_cds_alerts_add query, Elapsed time:" ,((
    curtime3 - subtimer ) / 100.0 ) ) ,log_level_debug )
  CALL resolvestaticcontenturl (null )
  IF ((basegroupreleaseident != "" ) )
   SET criterion->release_identifier = basegroupreleaseident
   SET criterion->release_version = basegroupreleaseversion
  ENDIF
  IF ((overridelocaleasus = 1 ) )
   CALL MP::i18n .initlocale ("en_US" )
  ENDIF
  SET criterion->locale_id = MP::i18n .getlocale (null )
  CALL MP::i18n .generatemasks (null )
  SET criterion->client_tz = curtimezoneapp
  SET criterion->is_utc = curutc
  SELECT INTO "nl:"
   FROM (prsnl p )
   WHERE (p.person_id = criterion->prsnl_id )
   DETAIL
    criterion->username = p.username
   WITH nocounter
  ;end select
  SET criterion->alva_enabled = alvaenabled
  SET criterion->workflow_base_url = "https://workflow-test.cernerpowerchart.com"
  CALL log_message (build ("Exit PopulateCriterionRec(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  populatelocalefilepath (null )
  CALL log_message ("In PopulateLocaleFilePath()" ,log_level_debug )
  DECLARE begin_date_time = dm12 WITH protect ,constant (systimestamp )
  DECLARE localefilepath = vc WITH protect ,noconstant ("" )
  IF ((trim (MP::i18n .getlocalefilepath (null ) ,3 ) = "" ) )
   IF ((basegroupreleaseident != "" ) )
    SELECT INTO "nl:"
     FROM (dm_info d )
     WHERE (d.info_domain = "INS" )
     AND (d.info_name = concat (basegroupreleaseident ,"_TRANS" ) )
     DETAIL
      localefilepath = build2 (criterion->static_content ,trim (d.info_char ,3 ) )
     WITH nocounter
    ;end select
    CALL log_message (concat ("PopulateLocaleFilePath: locale file path query, Elapsed time: " ,
      cnvtstring (timestampdiff (systimestamp ,begin_date_time ) ,17 ,4 ) ) ,log_level_debug )
   ENDIF
   IF ((((localefilepath = "" ) ) OR ((overridelocaleasus = 1 ) )) )
    SET localefilepath = build2 (criterion->static_content ,basecontentfolder ,
     "/js/locale/locale.js" )
   ENDIF
   CALL MP::i18n .setlocalefilepath (localefilepath )
  ENDIF
  CALL log_message (concat ("Exit PopulateLocaleFilePath(), Elapsed time: " ,cnvtstring (
     timestampdiff (systimestamp ,begin_date_time ) ,17 ,4 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  determinempagetype (null )
  CALL log_message ("In DetermineMPageType()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE subtimer = dq8 WITH private ,noconstant (curtime3 )
  DECLARE loadmpageflag = i2 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (mp_viewpoint mpv )
   WHERE (mpv.viewpoint_name_key = criterion->category_mean )
   AND (mpv.active_ind = 1 )
   DETAIL
    loadviewpointflag = true
   WITH nocounter
  ;end select
  CALL log_message (build ("DetermineMPageType:viewpoint query, Elapsed time:" ,((curtime3 -
    subtimer ) / 100.0 ) ) ,log_level_debug )
  IF ((loadviewpointflag = false ) )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    FROM (br_datamart_category bdc )
    WHERE (bdc.category_mean = criterion->category_mean )
    DETAIL
     loadmpageflag = true ,
     mpagecatid = bdc.br_datamart_category_id ,
     IF ((((bdc.category_mean = "MP_REACH_V5" ) ) OR ((bdc.category_mean = "MP_REACH" ) )) )
      loadingmpagesreach = true
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message (build ("DetermineMPageType:mpage query, Elapsed time:" ,((curtime3 - subtimer )
     / 100.0 ) ) ,log_level_debug )
   CALL error_and_zero_check_rec (curqual ,"MPage type identification" ,"DetermineMPageType" ,1 ,0 ,
    criterion )
  ENDIF
  IF ((mpagecatid = 0.0 )
  AND (loadviewpointflag = false ) )
   CALL echo (build2 ("Invalid view or view identifier: " , $CATEGORY_MEAN ) )
   CALL generatescripterrorhtml ("Invalid View or Viewpoint Identifier" )
   GO TO exit_script
  ENDIF
  CALL log_message (build ("DetermineMPageType:loadViewpoint=" ,loadviewpointflag ," loadMPage=" ,
    loadmpageflag ) ,log_level_debug )
  CALL log_message (build ("Exit DetermineMPageType(), Elapsed time:" ,((curtime3 - begin_date_time
    ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  loadviewpointsettings (null )
  CALL log_message ("In LoadViewPointSettings()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE optionsflag = i4 WITH protect ,noconstant (0 )
  DECLARE app_number = i4 WITH protect ,constant (3202020 )
  IF ((loadviewpointflag = false ) )
   SET loadviewpointflag = true
   SET optionsflag +=2
  ENDIF
  EXECUTE mp_get_viewpoint_settings "MINE" ,
  categorymean ,
  defaultviewcatmean ,
   $ENCNTR_ID ,
   $PRSNL_ID ,
   $POS_CD ,
  optionsflag ,
  app_number
  SET criterion->category_mean = vp_info->active_view_cat_mean
  CALL log_message (build ("Exit LoadViewPointSettings(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  getmpagesettings (null )
  CALL log_message ("In GetMPageSettings()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE app_number = i4 WITH protect ,constant (3202020 )
  SET _memory_reply_string = ""
  EXECUTE mp_get_mpage_settings "mine" ,
  criterion->category_mean ,
  criterion->prsnl_id ,
  criterion->position_cd ,
  0 ,
  ignorecache ,
  criterion->encntrs[1 ].encntr_id ,
  app_number
  SET mpagesettingsjson = replace (_memory_reply_string ,"'" ,"\'" )
  SET mpagesettingsjson = replace (_memory_reply_string ,'\"' ,'\\\"' )
  SET _memory_reply_string = ""
  CALL log_message (build ("Exit GetMPageSettings(), Elapsed time:" ,((curtime3 - begin_date_time )
    / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  generatecomponenttokens (null )
  CALL log_message ("In GenerateComponentTokens()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE subtimer = dq8 WITH protect ,noconstant (curtime3 )
  DECLARE not_found_filter_mean = vc WITH constant ("<not_found>" )
  DECLARE compcnt = i4 WITH protect ,noconstant (0 )
  DECLARE compindx = i4 WITH protect ,noconstant (0 )
  DECLARE flexid = f8 WITH protect ,noconstant (0.0 )
  DECLARE indx = i4 WITH protect ,noconstant (0 )
  DECLARE loadcustcompflag = i4 WITH protect ,noconstant (false )
  DECLARE qocindx = i4 WITH protect ,noconstant (0 )
  DECLARE grouperviewind = i4 WITH protect ,noconstant (0 )
  DECLARE groupedviewcatmeans = vc WITH protect ,noconstant ("mv.viewpoint_name_key in (" )
  DECLARE findposlevelsettings = i2 WITH protect ,noconstant (0 )
  DECLARE settingskey = vc WITH protect ,noconstant ("" )
  DECLARE pagerecindx = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH noconstant (1 )
  FREE RECORD mpage_comp_filters
  RECORD mpage_comp_filters (
    1 filter [* ]
      2 filter_mean = vc
  )
  FREE RECORD page_rec
  RECORD page_rec (
    1 category_id [* ]
      2 id = f8
      2 cat_mean = vc
      2 filters_json = vc
      2 components_defined = i4
      2 filters [* ]
        3 filter_mean = vc
  )
  FREE RECORD unassociated_filters
  RECORD unassociated_filters (
    1 filter [* ]
      2 filter_mean = vc
  )
  FREE RECORD flex_settings
  RECORD flex_settings (
    1 mpage [* ]
      2 cat_id = f8
      2 cat_mean = vc
      2 nurse_unit_flex_id = f8
      2 building_flex_id = f8
      2 facility_flex_id = f8
      2 position_flex_id = f8
      2 pos_loc_settings_ind = i2
  )
  FREE RECORD tokenreply
  RECORD tokenreply (
    1 group_cnt = i4
    1 groups [* ]
      2 base_folder = vc
      2 mappings_json = vc
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  IF ((loadingmpagesreach != true ) )
   SET stat = alterlist (page_rec->category_id ,size (vp_info->views ,5 ) )
   FOR (indx = 1 TO size (vp_info->views ,5 ) )
    IF ((vp_info->views[indx ].view_type != 4 ) )
     SET page_rec->category_id[indx ].id = vp_info->views[indx ].view_cat_id
     SET page_rec->category_id[indx ].cat_mean = vp_info->views[indx ].view_cat_mean
     SET page_rec->category_id[indx ].components_defined = false
    ENDIF
    IF ((vp_info->views[indx ].view_type_mean = "WF_GRP_VIEW" ) )
     SET grouperviewind = 1
     SET groupedviewcatmeans = build2 (groupedviewcatmeans ,"^" ,vp_info->views[indx ].
      grouped_view_viewpoint_id ,"^," )
    ENDIF
   ENDFOR
   SET groupedviewcatmeans = trim (replace (groupedviewcatmeans ,"," ,"" ,2 ) ,3 )
   SET groupedviewcatmeans = build2 (groupedviewcatmeans ,")" )
  ELSE
   SET stat = alterlist (page_rec->category_id ,1 )
   SET page_rec->category_id[1 ].id = mpagecatid
   SET page_rec->category_id[1 ].cat_mean = criterion->category_mean
   SET page_rec->category_id[1 ].components_defined = false
  ENDIF
  IF (grouperviewind )
   SELECT INTO "nl:"
    FROM (mp_viewpoint mv ),
     (mp_viewpoint_reltn mvr ),
     (br_datamart_category bdc )
    PLAN (mv
     WHERE parser (groupedviewcatmeans )
     AND (mv.active_ind = 1 ) )
     JOIN (mvr
     WHERE (mvr.mp_viewpoint_id = mv.mp_viewpoint_id ) )
     JOIN (bdc
     WHERE (bdc.br_datamart_category_id = mvr.br_datamart_category_id ) )
    DETAIL
     indx = (size (page_rec->category_id ,5 ) + 1 ) ,
     stat = alterlist (page_rec->category_id ,indx ) ,
     page_rec->category_id[indx ].id = mvr.br_datamart_category_id ,
     page_rec->category_id[indx ].cat_mean = bdc.category_mean
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist (flex_settings->mpage ,size (page_rec->category_id ,5 ) )
  FOR (indx = 1 TO size (page_rec->category_id ,5 ) )
   SET flex_settings->mpage[indx ].cat_id = page_rec->category_id[indx ].id
   SET flex_settings->mpage[indx ].cat_mean = page_rec->category_id[indx ].cat_mean
  ENDFOR
  CALL getflexid (criterion->position_cd ,locrecord ,flex_settings ,"BR_DATAMART_REPORT" )
  IF ((ignorecache != true ) )
   FOR (indx = 1 TO size (page_rec->category_id ,5 ) )
    SET settingskey = trim (build2 ("COMP_FILTER_MAPPINGS|" ,trim (cnvtstring (page_rec->category_id[
        indx ].id ) ,3 ) ) )
    SET flexedkeysuffix = getflexedsettingskey (criterion->position_cd ,flex_settings->mpage[indx ].
     position_flex_id ,flex_settings->mpage[indx ].pos_loc_settings_ind ,flex_settings->mpage[indx ].
     nurse_unit_flex_id ,flex_settings->mpage[indx ].building_flex_id ,flex_settings->mpage[indx ].
     facility_flex_id ,locrecord )
    IF ((textlen (trim (flexedkeysuffix ) ) > 0 ) )
     SET settingskey = build2 (settingskey ,flexedkeysuffix )
    ENDIF
    SET page_rec->category_id[indx ].filters_json = getnamespacedsettings ("MP" ,settingskey )
    IF ((page_rec->category_id[indx ].filters_json != "" ) )
     SET stat = cnvtjsontorec (page_rec->category_id[indx ].filters_json )
     SET stat = movereclist (mpage_comp_filters->filter ,comp_filters->filter ,1 ,size (comp_filters
       ->filter ,5 ) ,size (mpage_comp_filters->filter ,5 ) ,1 )
     SET stat = movereclist (mpage_comp_filters->filter ,page_rec->category_id[indx ].filters ,1 ,0 ,
      size (mpage_comp_filters->filter ,5 ) ,1 )
     SET stat = initrec (mpage_comp_filters )
    ENDIF
   ENDFOR
  ENDIF
  FREE RECORD comp_reports
  RECORD comp_reports (
    1 report_list [* ]
      2 report_id = f8
  )
  SET subtimer = curtime3
  SELECT INTO "nl:"
   mpage_param_mean =
   IF ((((bdv.mpage_param_mean = null ) ) OR ((bdv.mpage_param_mean = "" ) )) ) "AAA"
   ELSE bdv.mpage_param_mean
   ENDIF
   FROM (dummyt d WITH seq = value (size (page_rec->category_id ,5 ) ) ),
    (br_datamart_category bdc ),
    (br_datamart_report bdr ),
    (br_datamart_value bdv ),
    (br_datamart_flex flex1 ),
    (br_datamart_flex flex2 )
   PLAN (d
    WHERE (page_rec->category_id[d.seq ].filters_json = "" ) )
    JOIN (bdc
    WHERE (bdc.br_datamart_category_id = page_rec->category_id[d.seq ].id ) )
    JOIN (bdr
    WHERE (bdr.br_datamart_category_id = bdc.br_datamart_category_id ) )
    JOIN (bdv
    WHERE (bdv.br_datamart_category_id = bdr.br_datamart_category_id )
    AND (bdv.parent_entity_name = "BR_DATAMART_REPORT" )
    AND (bdv.parent_entity_id = bdr.br_datamart_report_id ) )
    JOIN (flex1
    WHERE (flex1.br_datamart_flex_id = bdv.br_datamart_flex_id )
    AND (flex1.parent_entity_id IN (locrecord->nurseunitcd ,
    locrecord->buildingcd ,
    locrecord->facilitycd ) ) )
    JOIN (flex2
    WHERE (flex2.br_datamart_flex_id = flex1.grouper_flex_id )
    AND (flex2.parent_entity_id = criterion->position_cd ) )
   ORDER BY bdr.br_datamart_category_id ,
    bdr.br_datamart_report_id ,
    mpage_param_mean
   HEAD bdr.br_datamart_report_id
    IF ((bdv.mpage_param_mean != "mp_vb_component_status" ) ) compcnt +=1 ,
     IF ((mod (compcnt ,50 ) = 1 ) ) stat = alterlist (comp_reports->report_list ,(compcnt + 49 ) )
     ENDIF
     ,comp_reports->report_list[compcnt ].report_id = bdr.br_datamart_report_id ,page_rec->
     category_id[d.seq ].components_defined = true
    ENDIF
   WITH nocounter
  ;end select
  FOR (indx = 1 TO size (page_rec->category_id ,5 ) )
   IF ((page_rec->category_id[indx ].components_defined = false ) )
    SET findposlevelsettings = 1
   ENDIF
  ENDFOR
  IF ((findposlevelsettings = 1 ) )
   SELECT INTO "nl:"
    mpage_param_mean =
    IF ((((bdv.mpage_param_mean = null ) ) OR ((bdv.mpage_param_mean = "" ) )) ) "AAA"
    ELSE bdv.mpage_param_mean
    ENDIF
    FROM (dummyt d WITH seq = value (size (page_rec->category_id ,5 ) ) ),
     (br_datamart_category bdc ),
     (br_datamart_report bdr ),
     (br_datamart_value bdv ),
     (br_datamart_flex bx )
    PLAN (d
     WHERE (page_rec->category_id[d.seq ].filters_json = "" )
     AND (page_rec->category_id[d.seq ].components_defined = false ) )
     JOIN (bdc
     WHERE (bdc.br_datamart_category_id = page_rec->category_id[d.seq ].id ) )
     JOIN (bdr
     WHERE (bdr.br_datamart_category_id = bdc.br_datamart_category_id ) )
     JOIN (bdv
     WHERE (bdv.br_datamart_category_id = bdr.br_datamart_category_id )
     AND (bdv.parent_entity_name = "BR_DATAMART_REPORT" )
     AND (bdv.parent_entity_id = bdr.br_datamart_report_id ) )
     JOIN (bx
     WHERE (bx.br_datamart_flex_id = bdv.br_datamart_flex_id )
     AND (bx.parent_entity_id IN (criterion->position_cd ,
     0.0 ) ) )
    ORDER BY bdr.br_datamart_category_id ,
     bx.parent_entity_id DESC ,
     bdr.br_datamart_report_id ,
     mpage_param_mean
    HEAD bdr.br_datamart_category_id
     flexid = bx.parent_entity_id
    HEAD bdr.br_datamart_report_id
     IF ((flexid = bx.parent_entity_id )
     AND (bdv.mpage_param_mean != "mp_vb_component_status" ) ) compcnt +=1 ,
      IF ((mod (compcnt ,50 ) = 1 ) ) stat = alterlist (comp_reports->report_list ,(compcnt + 49 ) )
      ENDIF
      ,comp_reports->report_list[compcnt ].report_id = bdr.br_datamart_report_id ,page_rec->
      category_id[d.seq ].components_defined = true
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist (comp_reports->report_list ,compcnt )
  CALL log_message (build ("GenerateComponentTokens:selected components query, Elapsed time:" ,((
    curtime3 - subtimer ) / 100.0 ) ) ,log_level_debug )
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (size (page_rec->category_id ,5 ) ) ),
    (br_datamart_category bdc ),
    (br_datamart_report bdr )
   PLAN (d
    WHERE (page_rec->category_id[d.seq ].filters_json = "" )
    AND (page_rec->category_id[d.seq ].components_defined = false ) )
    JOIN (bdc
    WHERE (bdc.br_datamart_category_id = page_rec->category_id[d.seq ].id ) )
    JOIN (bdr
    WHERE (bdr.br_datamart_category_id = bdc.br_datamart_category_id ) )
   ORDER BY bdr.br_datamart_report_id
   HEAD bdr.br_datamart_report_id
    compcnt +=1 ,
    IF ((compcnt > size (comp_reports->report_list ,5 ) ) ) stat = alterlist (comp_reports->
      report_list ,(compcnt + 5 ) )
    ENDIF
    ,comp_reports->report_list[compcnt ].report_id = bdr.br_datamart_report_id
   FOOT REPORT
    stat = alterlist (comp_reports->report_list ,compcnt )
   WITH nocounter
  ;end select
  SET subtimer = curtime3
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (size (page_rec->category_id ,5 ) ) ),
    (br_datamart_category bdc ),
    (br_datamart_report bdr ),
    (br_datamart_report_filter_r rfr ),
    (br_datamart_filter bdf )
   PLAN (d
    WHERE (page_rec->category_id[d.seq ].filters_json = "" ) )
    JOIN (bdc
    WHERE (bdc.br_datamart_category_id = page_rec->category_id[d.seq ].id ) )
    JOIN (bdr
    WHERE (bdr.br_datamart_category_id = bdc.br_datamart_category_id )
    AND expand (indx ,1 ,size (comp_reports->report_list ,5 ) ,bdr.br_datamart_report_id ,
     comp_reports->report_list[indx ].report_id ) )
    JOIN (rfr
    WHERE (rfr.br_datamart_report_id = bdr.br_datamart_report_id ) )
    JOIN (bdf
    WHERE (bdf.br_datamart_filter_id = rfr.br_datamart_filter_id )
    AND (bdf.filter_category_mean = "MP_SECT_PARAMS" ) )
   ORDER BY bdc.br_datamart_category_id ,
    bdr.br_datamart_report_id
   HEAD bdc.br_datamart_category_id
    stat = initrec (mpage_comp_filters ) ,compcnt = 0
   HEAD bdr.br_datamart_report_id
    compcnt +=1 ,
    IF ((mod (compcnt ,50 ) = 1 ) ) stat = alterlist (mpage_comp_filters->filter ,(compcnt + 49 ) )
    ENDIF
    ,mpage_comp_filters->filter[compcnt ].filter_mean = bdf.filter_mean
   FOOT  bdc.br_datamart_category_id
    stat = alterlist (mpage_comp_filters->filter ,compcnt ) ,settingskey = trim (build2 (
      "COMP_FILTER_MAPPINGS|" ,trim (cnvtstring (bdr.br_datamart_category_id ) ,3 ) ) ,3 ) ,
    flexedkeysuffix = "" ,pagerecindx = locateval (indx ,1 ,size (page_rec->category_id ,5 ) ,bdr
     .br_datamart_category_id ,flex_settings->mpage[indx ].cat_id ) ,
    IF ((pagerecindx > 0 ) ) flexedkeysuffix = getflexedsettingskey (criterion->position_cd ,
      flex_settings->mpage[pagerecindx ].position_flex_id ,flex_settings->mpage[pagerecindx ].
      pos_loc_settings_ind ,flex_settings->mpage[pagerecindx ].nurse_unit_flex_id ,flex_settings->
      mpage[pagerecindx ].building_flex_id ,flex_settings->mpage[pagerecindx ].facility_flex_id ,
      locrecord )
    ENDIF
    ,
    IF ((textlen (trim (flexedkeysuffix ) ) > 0 ) ) settingskey = build2 (settingskey ,
      flexedkeysuffix )
    ENDIF
    ,stat = cachenamespacedsettings ("MP" ,settingskey ,cnvtrectojson (mpage_comp_filters ) ) ,stat
    = movereclist (mpage_comp_filters->filter ,comp_filters->filter ,1 ,size (comp_filters->filter ,
      5 ) ,size (mpage_comp_filters->filter ,5 ) ,1 ) ,stat = movereclist (mpage_comp_filters->filter
      ,page_rec->category_id[d.seq ].filters ,1 ,0 ,size (mpage_comp_filters->filter ,5 ) ,1 )
   WITH nocounter
  ;end select
  CALL log_message (build ("GenerateComponentTokens:filter mean query, Elapsed time:" ,((curtime3 -
    subtimer ) / 100.0 ) ) ,log_level_debug )
  IF ((loadingmpagesreach != true ) )
   SET qocindx = locateval (indx ,1 ,size (vp_info->views ,5 ) ,"MP_COMMON_ORDERS_V4" ,vp_info->
    views[indx ].view_cat_mean )
  ENDIF
  IF ((qocindx > 0 ) )
   SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
   SET stat = alterlist (unassociated_filters->filter ,indx )
   SET unassociated_filters->filter[indx ].filter_mean = "ORD_SEL_ADD_FAV_FOLDER"
  ENDIF
  IF ((vp_info->ipass_enabled = "1" ) )
   SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
   SET stat = alterlist (unassociated_filters->filter ,indx )
   SET unassociated_filters->filter[indx ].filter_mean = "VP_IPASS"
  ENDIF
  IF ((validate (vp_info->notifications ) = 1 ) )
   IF ((validate (vp_info->notifications.notification_center_enabled ,0 ) = 1 ) )
    SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
    SET stat = alterlist (unassociated_filters->filter ,indx )
    SET unassociated_filters->filter[indx ].filter_mean = "VP_NOTIFICATIONS"
   ENDIF
   IF ((validate (vp_info->notifications.wf_notif_toggle_rte ,0 ) = 1 ) )
    SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
    SET stat = alterlist (unassociated_filters->filter ,indx )
    SET unassociated_filters->filter[indx ].filter_mean = "WF_NOTIF_TOGGLE_RTE"
   ENDIF
   IF ((validate (vp_info->notifications.wf_notif_toggle_expord ,0 ) = 1 ) )
    SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
    SET stat = alterlist (unassociated_filters->filter ,indx )
    SET unassociated_filters->filter[indx ].filter_mean = "WF_NOTIF_TOGGLE_EXPORD"
   ENDIF
   IF ((validate (vp_info->notifications.wf_notif_filter_means ) = 1 ) )
    SET num = 1
    SET str = piece (vp_info->notifications.wf_notif_filter_means ,"," ,num ,not_found_filter_mean ,
     3 )
    WHILE ((str != not_found_filter_mean ) )
     SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
     SET stat = alterlist (unassociated_filters->filter ,indx )
     SET unassociated_filters->filter[indx ].filter_mean = str
     SET num +=1
     SET str = piece (vp_info->notifications.wf_notif_filter_means ,"," ,num ,not_found_filter_mean ,
      3 )
    ENDWHILE
   ENDIF
  ENDIF
  IF ((validate (vp_info->voice ) = 1 ) )
   IF ((validate (vp_info->voice.voice_enabled ,0 ) = 1 ) )
    SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
    SET stat = alterlist (unassociated_filters->filter ,indx )
    SET unassociated_filters->filter[indx ].filter_mean = "VP_VOICE"
   ENDIF
   IF ((validate (vp_info->voice.wf_voice_config ) = 1 ) )
    SET num = 1
    SET str = piece (vp_info->voice.wf_voice_config ,"," ,num ,not_found_filter_mean ,3 )
    WHILE ((str != not_found_filter_mean ) )
     SET indx = (size (unassociated_filters->filter ,5 ) + 1 )
     SET stat = alterlist (unassociated_filters->filter ,indx )
     SET unassociated_filters->filter[indx ].filter_mean = str
     SET num +=1
     SET str = piece (vp_info->voice.wf_voice_config ,"," ,num ,not_found_filter_mean ,3 )
    ENDWHILE
   ENDIF
  ENDIF
  CALL determineviewfilters (null )
  SET stat = movereclist (view_types->views ,unassociated_filters->filter ,1 ,size (
    unassociated_filters->filter ,5 ) ,size (view_types->views ,5 ) ,1 )
  SET stat = movereclist (unassociated_filters->filter ,comp_filters->filter ,1 ,size (comp_filters->
    filter ,5 ) ,size (unassociated_filters->filter ,5 ) ,1 )
  IF ((legacycontentload = false ) )
   CALL generatecontenturlsbycategory (null )
  ELSEIF ((size (comp_filters->filter ,5 ) > 0 ) )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    filter_mean = substring (1 ,30 ,comp_filters->filter[d.seq ].filter_mean )
    FROM (dummyt d WITH seq = value (size (comp_filters->filter ,5 ) ) )
    PLAN (d )
    ORDER BY filter_mean
    HEAD REPORT
     compcnt = size (comp_filters->filter ,5 ) ,
     stat = alterlist (comp_filters->filter ,(2 * compcnt ) ) ,
     compindx = compcnt
    HEAD filter_mean
     IF (((operator (trim (filter_mean ) ,"REGEXPLIKE" ,"^(FUSION_|FP_)?CUSTOM_COMP_[0-9]+$" ) ) OR (
     (trim (filter_mean ) = "WF_CARE_PATH_COMP" ) )) ) loadcustcompflag = true
     ENDIF
     ,compindx +=1 ,comp_filters->filter[compindx ].filter_mean = trim (filter_mean ,3 )
    FOOT REPORT
     stat = alterlist (comp_filters->filter ,compcnt ,0 ) ,
     stat = alterlist (comp_filters->filter ,(compindx - compcnt ) ) ,
     loadcustomcomponents = loadcustcompflag
    WITH nocounter
   ;end select
   CALL log_message (build ("GenerateComponentTokens:sort filters, Elapsed time:" ,((curtime3 -
     subtimer ) / 100.0 ) ) ,log_level_debug )
   IF (utilizempages5xmappings )
    SET componenttokens = getfiltermeantokens (null )
   ELSE
    EXECUTE mp_retrieve_comp_mappings "NOFORMS" ,
    basegroupreleaseident WITH replace ("REPLY" ,"TOKENREPLY" ) ,
    replace ("COMPONENTS_TO_RETRIEVE" ,"COMP_FILTERS" )
    IF ((((alvaenabled = 0 ) ) OR ((cdcontentserverurl = "" ) )) )
     SET dynamiccontentcontextroot = criterion->static_content
     SET pathandqueryjs = "/js/group?"
     SET pathandquerycss = "/css/group?"
    ELSE
     SET dynamiccontentcontextroot = build (cdcontentserverurl ,"/dynamic" )
     SET pathandqueryjs = "/content/js?tokens="
     SET pathandquerycss = "/content/css?tokens="
    ENDIF
    FOR (indx = 1 TO tokenreply->group_cnt )
     IF ((((contentfromcloud = 1 ) ) OR ((alvaenabled = 1 )
     AND (cdcontentserverurl != "" ) )) )
      SET escapedtokens = urlencode (tokenreply->groups[indx ].mappings_json )
      SET jsgroupscripttags = build2 (jsgroupscripttags ,"<script type='text/javascript' src='" ,
       dynamiccontentcontextroot ,"/" ,tokenreply->groups[indx ].base_folder ,pathandqueryjs ,
       escapedtokens ,"'></script>" )
      SET cssgrouplinktags = build2 (cssgrouplinktags ,
       "<link rel='stylesheet' type='text/css' href='" ,dynamiccontentcontextroot ,"/" ,tokenreply->
       groups[indx ].base_folder ,pathandquerycss ,escapedtokens ,"' />" )
     ELSE
      SET jsgroupscripttags = build2 (jsgroupscripttags ,"<script type='text/javascript' src='" ,
       dynamiccontentcontextroot ,"/" ,tokenreply->groups[indx ].base_folder ,pathandqueryjs ,
       tokenreply->groups[indx ].mappings_json ,"'></script>" )
      SET cssgrouplinktags = build2 (cssgrouplinktags ,
       "<link rel='stylesheet' type='text/css' href='" ,dynamiccontentcontextroot ,"/" ,tokenreply->
       groups[indx ].base_folder ,pathandquerycss ,tokenreply->groups[indx ].mappings_json ,"' />" )
     ENDIF
    ENDFOR
    SET componenttokens = cnvtrectojson (tokenreply )
    IF ((validate (debug_ind ) = 1 ) )
     CALL echo (build2 ("Base group release ident: " ,basegroupreleaseident ) )
     CALL echorecord (comp_filters )
     CALL echorecord (tokenreply )
    ENDIF
   ENDIF
   IF ((validate (debug_ind ) = 1 ) )
    CALL echo (build2 ("Component Tokens: " ,componenttokens ) )
   ENDIF
  ENDIF
  FREE RECORD mpage_comp_filters
  FREE RECORD page_rec
  FREE RECORD tokenreply
  FREE RECORD unassociated_filters
  CALL log_message (build ("Exit GenerateComponentTokens(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  generatecontenturlsbycategory (null )
  CALL log_message ("In GenerateContentURLsByCategory()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE indx = i4 WITH protect ,noconstant (0 )
  DECLARE jndx = i4 WITH protect ,noconstant (0 )
  DECLARE filter_count = i4 WITH protect ,noconstant (0 )
  DECLARE unassociated_count = i4 WITH protect ,noconstant (size (unassociated_filters->filter ,5 )
   )
  FREE RECORD view_content_urls
  RECORD view_content_urls (
    1 category [* ]
      2 cat_mean = vc
      2 group [* ]
        3 js_url = vc
        3 css_url = vc
  )
  FREE RECORD component_category_filters
  RECORD component_category_filters (
    1 filter [* ]
      2 filter_mean = vc
      2 category_mean = vc
  )
  FREE RECORD tokenreply
  RECORD tokenreply (
    1 category [* ]
      2 category_mean = vc
      2 group_cnt = i4
      2 groups [* ]
        3 base_folder = vc
        3 mappings_json = vc
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  FOR (indx = 1 TO size (page_rec->category_id ,5 ) )
   SET stat = alterlist (component_category_filters->filter ,(size (component_category_filters->
     filter ,5 ) + size (page_rec->category_id[indx ].filters ,5 ) ) )
   FOR (jndx = 1 TO size (page_rec->category_id[indx ].filters ,5 ) )
    SET filter_count +=1
    SET component_category_filters->filter[filter_count ].filter_mean = page_rec->category_id[indx ].
    filters[jndx ].filter_mean
    IF ((legacycontentload = true ) )
     SET component_category_filters->filter[filter_count ].category_mean = unspecified_category
    ELSE
     SET component_category_filters->filter[filter_count ].category_mean = page_rec->category_id[
     indx ].cat_mean
    ENDIF
   ENDFOR
  ENDFOR
  SET stat = alterlist (component_category_filters->filter ,(filter_count + unassociated_count ) )
  FOR (indx = 1 TO unassociated_count )
   SET filter_count +=1
   SET component_category_filters->filter[filter_count ].filter_mean = unassociated_filters->filter[
   indx ].filter_mean
   SET component_category_filters->filter[filter_count ].category_mean = unspecified_category
  ENDFOR
  IF ((size (component_category_filters->filter ,5 ) > 0 ) )
   SET subtimer = curtime3
   SELECT INTO "nl:"
    filter_mean = substring (1 ,30 ,component_category_filters->filter[d.seq ].filter_mean ) ,
    category_mean = substring (1 ,30 ,component_category_filters->filter[d.seq ].category_mean )
    FROM (dummyt d WITH seq = value (filter_count ) )
    PLAN (d )
    ORDER BY filter_mean
    HEAD REPORT
     compcnt = size (component_category_filters->filter ,5 ) ,
     stat = alterlist (component_category_filters->filter ,(2 * compcnt ) ) ,
     compindx = compcnt
    HEAD filter_mean
     IF (((operator (trim (filter_mean ) ,"REGEXPLIKE" ,"^^(FUSION_|FP_)?CUSTOM_COMP_[0-9]+$" ) ) OR
     ((trim (filter_mean ) = "WF_CARE_PATH_COMP" ) )) ) loadcustcompflag = true
     ENDIF
     ,multiple_cat_means = false ,start_cat_mean = category_mean
    DETAIL
     IF ((category_mean != start_cat_mean ) ) multiple_cat_means = true
     ENDIF
    FOOT  filter_mean
     compindx +=1 ,component_category_filters->filter[compindx ].filter_mean = trim (filter_mean ,3
      ) ,
     IF ((multiple_cat_means = true ) ) component_category_filters->filter[compindx ].category_mean
      = unspecified_category
     ELSE component_category_filters->filter[compindx ].category_mean = category_mean
     ENDIF
    FOOT REPORT
     stat = alterlist (component_category_filters->filter ,compcnt ,0 ) ,
     stat = alterlist (component_category_filters->filter ,(compindx - compcnt ) ) ,
     loadcustomcomponents = loadcustcompflag
    WITH nocounter
   ;end select
   CALL log_message (build ("GenerateComponentTokens:sort filters, Elapsed time:" ,((curtime3 -
     subtimer ) / 100.0 ) ) ,log_level_debug )
   EXECUTE mp_retrieve_cat_comp_mappings "NOFORMS" ,
   basegroupreleaseident WITH replace ("REPLY" ,"TOKENREPLY" ) ,
   replace ("COMPONENTS_TO_RETRIEVE" ,"COMPONENT_CATEGORY_FILTERS" )
   SET stat = alterlist (view_content_urls->category ,size (tokenreply->category ,5 ) )
   IF ((((alvaenabled = 0 ) ) OR ((cdcontentserverurl = "" ) )) )
    SET dynamiccontentcontextroot = criterion->static_content
    SET pathandqueryjs = "/js/group?"
    SET pathandquerycss = "/css/group?"
   ELSE
    SET dynamiccontentcontextroot = build (cdcontentserverurl ,"/dynamic" )
    SET pathandqueryjs = "/content/js?tokens="
    SET pathandquerycss = "/content/css?tokens="
   ENDIF
   FOR (indx = 1 TO size (tokenreply->category ,5 ) )
    SET stat = alterlist (view_content_urls->category[indx ].group ,tokenreply->category[indx ].
     group_cnt )
    SET view_content_urls->category[indx ].cat_mean = tokenreply->category[indx ].category_mean
    FOR (jndx = 1 TO tokenreply->category[indx ].group_cnt )
     IF ((((contentfromcloud = 1 ) ) OR ((alvaenabled = 1 )
     AND (cdcontentserverurl != "" ) )) )
      SET escapedtokens = urlencode (tokenreply->category[indx ].groups[jndx ].mappings_json )
     ELSE
      SET escapedtokens = tokenreply->category[indx ].groups[jndx ].mappings_json
     ENDIF
     SET view_content_urls->category[indx ].group[jndx ].js_url = build2 (dynamiccontentcontextroot ,
      "/" ,tokenreply->category[indx ].groups[jndx ].base_folder ,pathandqueryjs ,escapedtokens )
     SET view_content_urls->category[indx ].group[jndx ].css_url = build2 (dynamiccontentcontextroot
      ,"/" ,tokenreply->category[indx ].groups[jndx ].base_folder ,pathandquerycss ,escapedtokens )
     IF ((tokenreply->category[indx ].category_mean = unspecified_category ) )
      SET jsgroupscripttags = build2 (jsgroupscripttags ,"<script type='text/javascript' src='" ,
       view_content_urls->category[indx ].group[jndx ].js_url ,"'></script>" )
      SET cssgrouplinktags = build2 (cssgrouplinktags ,
       "<link rel='stylesheet' type='text/css' href='" ,view_content_urls->category[indx ].group[
       jndx ].css_url ,"' />" )
     ENDIF
    ENDFOR
   ENDFOR
   SET viewstaticcontentjson = cnvtrectojson (view_content_urls )
   SET componenttokens = cnvtrectojson (tokenreply )
   IF ((validate (debug_ind ) = 1 ) )
    CALL echo (build2 ("Base group release ident: " ,basegroupreleaseident ) )
    CALL echorecord (comp_filters )
    CALL echorecord (tokenreply )
    CALL echo (build2 ("Component Tokens: " ,componenttokens ) )
   ENDIF
   FREE RECORD mpage_comp_filters
   FREE RECORD page_rec
   FREE RECORD tokenreply
   FREE RECORD unassociated_filters
   FREE RECORD view_content_urls
   FREE RECORD component_category_filters
  ENDIF
  CALL log_message (build ("Exit GenerateContentURLsByCategory(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  determineviewfilters (null )
  CALL log_message ("In DetermineViewFilters()" ,log_level_debug )
  DECLARE filtercount = i4 WITH protect ,noconstant (0 )
  DECLARE indx = i4 WITH protect ,noconstant (0 )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE view_cnt = i4 WITH protect ,constant (size (vp_info->views ,5 ) )
  IF ((loadingmpagesreach != true ) )
   SET stat = alterlist (view_types->views ,(view_cnt * 2 ) )
   FOR (indx = 1 TO view_cnt )
    IF ((vp_info->views[indx ].view_cat_mean != patstring ("VB_*" ) ) )
     SET filtercount +=1
     SET view_types->views[filtercount ].view_mean = vp_info->views[indx ].view_cat_mean
    ENDIF
    SET filtercount +=1
    SET view_types->views[filtercount ].view_mean = vp_info->views[indx ].view_type_mean
   ENDFOR
   SET stat = alterlist (view_types->views ,filtercount )
  ELSE
   SET stat = alterlist (view_types->views ,2 )
   SET view_types->views[1 ].view_mean = "MP_REACH_V5"
   SET view_types->views[2 ].view_mean = "SUM_STD"
  ENDIF
  CALL log_message (build ("Exit DetermineViewFilters(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  getchartsearchurl (null )
  CALL log_message ("In GetChartSearchURL()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE searchurl = vc WITH protect ,noconstant ("" )
  IF ((loadingmpagesreach != true ) )
   IF ((vp_info->cs_enabled = "1" ) )
    EXECUTE ss_get_chart_search_config
    SET searchurl = configuration->chartsearchurl.value
   ENDIF
  ENDIF
  CALL log_message (build ("Exit GetChartSearchURL(), Elapsed time:" ,((curtime3 - begin_date_time )
    / 100.0 ) ) ,log_level_debug )
  RETURN (searchurl )
 END ;Subroutine
 SUBROUTINE  generatecontentrequirements (null )
  CALL log_message ("In GenerateContentRequirements()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE chartsearchurl = vc WITH protect ,noconstant ("" )
  DECLARE chartsearchjs = vc WITH protect ,noconstant ("" )
  DECLARE componentjs = vc WITH protect ,noconstant ("" )
  DECLARE componentcss = vc WITH protect ,noconstant ("" )
  DECLARE customcompjs = vc WITH protect ,noconstant ("" )
  DECLARE customcompcss = vc WITH protect ,noconstant ("" )
  DECLARE customcompsc = vc WITH protect ,noconstant ("" )
  SET chartsearchurl = getchartsearchurl (null )
  IF ((chartsearchurl != "" ) )
   SET chartsearchjs = build2 ('<script type="text/javascript" src="' ,chartsearchurl ,
    'js/search-input-all.min.js" async="async"></script>' ,'<script type="text/javascript" src="' ,
    chartsearchurl ,'js/embed.js" async="async"></script>' )
   SET chartsearchcss = build2 ('var cssSearchInputAll=document.createElement("link");' ,
    'cssSearchInputAll.rel="stylesheet";' ,'cssSearchInputAll.href="' ,chartsearchurl ,
    'css/search-input-all.min.css";' ,'cssSearchInputAll.type="text/css";' ,
    'var cssMainIE8=document.createElement("link");' ,'cssMainIE8.rel="stylesheet";' ,
    'cssMainIE8.href="' ,chartsearchurl ,'css/main_ie8.css";' ,'cssMainIE8.type="text/css";' ,
    'var headDOM=document.getElementsByTagName("head")[0];' ,
    "headDOM.appendChild(cssSearchInputAll);" ,"headDOM.appendChild(cssMainIE8);" )
  ENDIF
  IF (loadcustomcomponents )
   IF ((usecustomcomponentexamples = 1 ) )
    SET customcompjs = build2 ('<script type="text/javascript" src="' ,criterion->static_content ,
     basecontentfolder ,'/custom-components/js/custom-component-examples.js"></script>' )
    SET customcompcss = build2 ('<link type="text/css" rel="stylesheet" href="' ,criterion->
     static_content ,basecontentfolder ,'/custom-components/css/custom-component-examples.css"/>' )
   ELSE
    IF (utilizempages5xmappings )
     SET customcompsc = replace (criterion->static_content ,static_content_folder ,
      custom_content_folder )
    ELSE
     IF ((alvaenabled = 1 )
     AND (cdcontentserverurl != "" ) )
      SET customcompsc = build2 (criterion->static_content_legacy ,"/" ,custom_content_folder )
     ELSE
      SET customcompsc = build2 (criterion->static_content ,"/" ,custom_content_folder )
     ENDIF
    ENDIF
    SET customcompjs = build2 ('<script type="text/javascript" src="' ,customcompsc ,
     '/custom-components/js/custom-components.js"></script>' )
    SET customcompcss = build2 ('<link type="text/css" rel="stylesheet" href="' ,customcompsc ,
     '/custom-components/css/custom-components.css"/>' )
   ENDIF
  ENDIF
  IF ((contentserverurl != "" )
  AND (componenttokens != "" ) )
   IF (utilizempages5xmappings )
    SET componentjs = build2 (^<script type="text/javascript" src='^ ,criterion->static_content ,
     "/js/" ,componenttokens ,"'></script>" )
    SET componentcss = build2 (^<link rel="stylesheet" type="text/css" href='^ ,criterion->
     static_content ,"/css/" ,componenttokens ,"'></link>" )
   ELSE
    SET componentjs = jsgroupscripttags
    SET componentcss = cssgrouplinktags
   ENDIF
  ELSE
   IF ((contentserverurl != "" ) )
    CALL generatescripterrorhtml (
     "Unable to create component token string: unknown component filter mapping" )
    GO TO exit_script
   ENDIF
   SET componentjs = build2 (^<script type="text/javascript" src='^ ,criterion->static_content ,
    basecontentfolder ,"/js/master-components.js'></script>" )
   SET componentcss = build2 (^<link rel="stylesheet" type="text/css" href='^ ,criterion->
    static_content ,basecontentfolder ,"/css/master-components.css'></link>" )
  ENDIF
  SET javascriptreqs = build2 (^<script type="text/javascript" src='^ ,MP::i18n .getlocalefilepath (
    null ) ,"'></script>" ,^<script type="text/javascript" src='^ ,criterion->static_content ,
   basecontentfolder ,"/js/assembly.js'></script>" ,^<script type="text/javascript" src='^ ,criterion
   ->static_content ,basecontentfolder ,"/js/master-core-util.js'></script>" ,
   ^<script type="text/javascript" src='^ ,criterion->static_content ,basecontentfolder ,
   "/js/master-render.js'></script>" ,componentjs ,chartsearchjs ,customcompjs )
  SET cssreqs = build2 (^<link rel="stylesheet" type="text/css" href='^ ,criterion->static_content ,
   basecontentfolder ,"/css/tcpip-dummy.css' />" ,^<link rel="stylesheet" type="text/css" href='^ ,
   criterion->static_content ,basecontentfolder ,"/css/assembly.css' />" ,
   ^<link rel="stylesheet" type="text/css" href='^ ,criterion->static_content ,basecontentfolder ,
   "/css/master-core-util.css' />" ,componentcss ,customcompcss )
  IF ((textlen (trim (criterion->workflow_base_url ) ) > 0 ) )
   SET javascriptreqs = build2 ('<script type="text/javascript">' ,'window.WORKFLOW_BASE_URL = "' ,
    criterion->workflow_base_url ,'";' ,"</script>" ,^<script type="text/javascript" src='^ ,
    criterion->static_content ,"/WS_DIAGNOSTIC/workflow/workflow.js'></script>" ,javascriptreqs )
  ENDIF
  SET criterion->static_content = build2 (criterion->static_content ,basecontentfolder )
  SET criterion->static_content_legacy = build2 (criterion->static_content_legacy ,basecontentfolder
   )
  CALL log_message (build ("Exit GenerateContentRequirements(), Elapsed time:" ,((curtime3 -
    begin_date_time ) / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (generatescripterrorhtml (message =vc ) =null WITH protect )
  DECLARE metastr = vc WITH protect ,noconstant ("" )
  IF ((enableedgemode = 1 ) )
   SET metastr = '<meta http-equiv="X-UA-Compatible" content="IE=edge">'
  ELSE
   SET metastr = '<meta http-equiv="X-UA-Compatible" content="IE=10">'
  ENDIF
  SET _memory_reply_string = build2 ("<!DOCTYPE html>" ,'<html dir="ltr">' ,"<head>" ,metastr ,
   '<meta http-equiv="Content-Type" content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,' ,
   'CCLLINKPOPUP,CCLNEWSESSIONWINDOW,MPAGES_SVC_EVENT" name="discern"/>' ,
   '<meta name="viewport" content="width=device-width, initial-scale=1.0">' ,
   '<link rel="stylesheet" type="text/css" href="' ,criterion->static_content ,basecontentfolder ,
   '/css/assembly.css" />' ,'<link rel="stylesheet" type="text/css" href="' ,criterion->
   static_content ,basecontentfolder ,'/css/master-core-util.css" />' ,
   '<script type="text/javascript" src="' ,MP::i18n .getlocalefilepath (null ) ,'"></script>' ,
   '<script type="text/javascript" src="' ,criterion->static_content ,basecontentfolder ,
   '/js/assembly.js"></script>' ,'<script type="text/javascript" src="' ,criterion->static_content ,
   basecontentfolder ,'/js/master-core-util.js"></script>' ,'<script type="text/javascript" src="' ,
   criterion->static_content ,basecontentfolder ,'/js/master-render.js"></script>' ,"<title>" ,
   criterion->person_info.person_name ,"</title>" ,"</head>" ,^<body onload='throw new Error("^ ,
   message ,^")';></body>^ ,"</html>" )
 END ;Subroutine
 SUBROUTINE  generatempagehtml (null )
  CALL log_message ("In GenerateMPageHTML()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE viewpointjson = vc WITH protect ,noconstant ("var m_viewpointJSON;" )
  DECLARE viewcategorymean = vc WITH protect ,noconstant ("" )
  DECLARE dateformatsjson = vc WITH protect ,noconstant ("" )
  DECLARE criterionjson = vc WITH protect ,noconstant ("" )
  DECLARE metastr = vc WITH protect ,noconstant ("" )
  DECLARE staticcontenturljsonvar = vc WITH protect ,noconstant ("" )
  DECLARE splunkhecconfigjson = vc WITH protect ,noconstant ("" )
  IF ((enableedgemode = 1 ) )
   SET metastr = '<meta http-equiv="X-UA-Compatible" content="IE=edge">'
  ELSE
   SET metastr = '<meta http-equiv="X-UA-Compatible" content="IE=10">'
  ENDIF
  IF ((loadingmpagesreach != true ) )
   SET renderfunction = build2 (renderfunction ,"MP_Viewpoint.launchViewpoint();" )
   IF ((chartsearchcss != "" ) )
    SET renderfunction = build2 (renderfunction ,chartsearchcss )
   ENDIF
   SET viewpointjson = build2 ("var m_viewpointJSON = '" ,replace (cnvtrectojson (vp_info ) ,"'" ,
     "\'" ) ,"';" )
   SET viewcategorymean = vp_info->active_view_cat_mean
  ELSE
   SET renderfunction = build2 (renderfunction ,"renderMPagesView('" ,criterion->category_mean ,
    "');" )
   SET viewcategorymean = criterion->category_mean
  ENDIF
  SET criterionjson = replace (cnvtrectojson (criterion ) ,"'" ,"\'" ,0 )
  SET criterionjson = replace (criterionjson ,"\\" ,"\\\\" ,0 )
  SET criterionjson = replace (criterionjson ,'\"' ,'\\"' ,0 )
  SET splunkhecconfigjson = replace (cnvtrectojson (splunk_hec_config ) ,"'" ,"\'" ,0 )
  SET splunkhecconfigjson = replace (splunkhecconfigjson ,"\\" ,"\\\\" ,0 )
  SET splunkhecconfigjson = replace (splunkhecconfigjson ,'\"' ,'\\"' ,0 )
  SET dateformatsjson = replace (cnvtrectojson (datetimeformats ,4 ) ,"'" ,"\'" ,0 )
  IF ((legacycontentload != true ) )
   SET staticcontenturljsonvar = build2 ("var m_view_content_urls = '" ,replace (
     viewstaticcontentjson ,'\"' ,'\\"' ) ,"';" )
  ELSE
   SET staticcontenturljsonvar = " "
  ENDIF
  SET _memory_reply_string = build2 ("<!DOCTYPE html>" ,'<html dir="ltr">' ,"<head>" ,metastr ,
   '<meta http-equiv="Content-Type" content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,' ,
   'CCLLINKPOPUP,CCLNEWSESSIONWINDOW,MPAGES_SVC_EVENT" name="discern"/>' ,
   '<meta name="viewport" content="width=device-width, initial-scale=1.0">' ,
   '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">' ,
   '<script type="text/javascript">' ,"var _loadTimer = null;" ,"try{" ,
   '_pageLoadTimer = window.external.DiscernObjectFactory("CHECKPOINT");' ,
   '_pageLoadTimer.EventName = "USR:MPG.MP_UNIFIED_DRIVER load entire page";' ,
   '_pageLoadTimer.MetaData("rtms.legacy.subtimerName") = "' ,viewcategorymean ,'";' ,
   '_pageLoadTimer.SubEventName = "Start";' ,"_pageLoadTimer.Publish();" ,
   '_loadTimer = window.external.DiscernObjectFactory("SLATIMER");' ,
   '_loadTimer.TimerName = "ENG:MPG.MP_UNIFIED_DRIVER - load resources";' ,
   '_loadTimer.SubtimerName = "";' ,"_loadTimer.Start();" ,"}catch(err){}" ,"</script>" ,cssreqs ,
   '<script type="text/javascript">' ,viewpointjson ,"var m_criterionJSON = '" ,criterionjson ,"';" ,
   "var m_dateformatJSON = '" ,dateformatsjson ,"';" ,
   "var CERN_driver_script = 'MP_UNIFIED_DRIVER';" ,"var CERN_driver_mean = '" ,cnvtupper (
    categorymean ) ,"';" ,"var CERN_driver_static_content = '" ,trim ( $STATIC_CONTENT ,3 ) ,"';" ,
   "var CERN_static_content = '" ,criterion->static_content ,"';" ,"var m_mpageSettingsJSON = '" ,
   replace (mpagesettingsjson ,"'" ,"\'" ) ,"';" ,"var m_bedrockMpage = null;" ,
   "var m_localeObjectName = '" ,MP::i18n .getlocaleobjectname (null ) ,"';" ,
   "var m_requestBindingJSON = " ,evaluate (alvaenabled ,1 ,build2 ("'" ,requestbindingjson ,"'" ) ,
    "null" ) ,";" ,"var MPAGE_LOCALE = null;" ,"var splunkHECConfig = '" ,splunkhecconfigjson ,"';" ,
   staticcontenturljsonvar ,"</script>" ,javascriptreqs ,"<title>" ,criterion->person_info.
   person_name ,"</title>" ,"</head>" ,
   '<body><script> document.addEventListener("DOMContentLoaded", function(event) {if (_loadTimer) {_loadTimer.Stop();}'
   ,renderfunction ,"})</script></body>" ,"</html>" )
  IF ((validate (debug_ind ) = 1 ) )
   CALL echo (build2 ("Page HTML: " ,_memory_reply_string ) )
  ENDIF
  CALL log_message (build ("Exit GenerateMPageHTML(), Elapsed time:" ,((curtime3 - begin_date_time )
    / 100.0 ) ) ,log_level_debug )
 END ;Subroutine
#exit_script
 IF (validate (debug_ind ,0 ) )
  IF (validate (criterion ) )
   CALL echorecord (criterion )
  ENDIF
  IF (validate (vp_info ) )
   CALL echorecord (vp_info )
  ENDIF
 ELSE
  FREE RECORD criterion
  FREE RECORD vp_info
 ENDIF
END GO
 

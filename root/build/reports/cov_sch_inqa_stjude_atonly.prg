/***********************************************************
Author 			:	Mike Layman
Date Written	:	04/10/2018
Program Title	:	Request By Appointment Type
Source File		:	sch_inqa_stjude_atonly.prg
Object Name		:	sch_inqa_stjude_atonly
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is a translated copy of the original
					Cerner script - sch_inqa_req_cancel_patonly. CR 1259
					requested that the Health Plan be added to all request list
					queue's.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					clinical_event, orders, order_action
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	SchapptBook.Exe
Special Notes	:
Usage			:	sch_inqa_stjude_atonly go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		04/10/2018	Mike Layman				CR 1259
 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
 
DROP PROGRAM sch_inqa_stjude_atonly :dba GO
CREATE PROGRAM sch_inqa_stjude_atonly :dba
 IF ((validate (action_none ,- (1 ) ) != 0 ) )
  DECLARE action_none = i2 WITH protect ,noconstant (0 )
 ENDIF
 IF ((validate (action_add ,- (1 ) ) != 1 ) )
  DECLARE action_add = i2 WITH protect ,noconstant (1 )
 ENDIF
 IF ((validate (action_chg ,- (1 ) ) != 2 ) )
  DECLARE action_chg = i2 WITH protect ,noconstant (2 )
 ENDIF
 IF ((validate (action_del ,- (1 ) ) != 3 ) )
  DECLARE action_del = i2 WITH protect ,noconstant (3 )
 ENDIF
 IF ((validate (action_get ,- (1 ) ) != 4 ) )
  DECLARE action_get = i2 WITH protect ,noconstant (4 )
 ENDIF
 IF ((validate (action_ina ,- (1 ) ) != 5 ) )
  DECLARE action_ina = i2 WITH protect ,noconstant (5 )
 ENDIF
 IF ((validate (action_act ,- (1 ) ) != 6 ) )
  DECLARE action_act = i2 WITH protect ,noconstant (6 )
 ENDIF
 IF ((validate (action_temp ,- (1 ) ) != 999 ) )
  DECLARE action_temp = i2 WITH protect ,noconstant (999 )
 ENDIF
 IF ((validate (true ,- (1 ) ) != 1 ) )
  DECLARE true = i2 WITH protect ,noconstant (1 )
 ENDIF
 IF ((validate (false ,- (1 ) ) != 0 ) )
  DECLARE false = i2 WITH protect ,noconstant (0 )
 ENDIF
 IF ((validate (gen_nbr_error ,- (1 ) ) != 3 ) )
  DECLARE gen_nbr_error = i2 WITH protect ,noconstant (3 )
 ENDIF
 IF ((validate (insert_error ,- (1 ) ) != 4 ) )
  DECLARE insert_error = i2 WITH protect ,noconstant (4 )
 ENDIF
 IF ((validate (update_error ,- (1 ) ) != 5 ) )
  DECLARE update_error = i2 WITH protect ,noconstant (5 )
 ENDIF
 IF ((validate (replace_error ,- (1 ) ) != 6 ) )
  DECLARE replace_error = i2 WITH protect ,noconstant (6 )
 ENDIF
 IF ((validate (delete_error ,- (1 ) ) != 7 ) )
  DECLARE delete_error = i2 WITH protect ,noconstant (7 )
 ENDIF
 IF ((validate (undelete_error ,- (1 ) ) != 8 ) )
  DECLARE undelete_error = i2 WITH protect ,noconstant (8 )
 ENDIF
 IF ((validate (remove_error ,- (1 ) ) != 9 ) )
  DECLARE remove_error = i2 WITH protect ,noconstant (9 )
 ENDIF
 IF ((validate (attribute_error ,- (1 ) ) != 10 ) )
  DECLARE attribute_error = i2 WITH protect ,noconstant (10 )
 ENDIF
 IF ((validate (lock_error ,- (1 ) ) != 11 ) )
  DECLARE lock_error = i2 WITH protect ,noconstant (11 )
 ENDIF
 IF ((validate (none_found ,- (1 ) ) != 12 ) )
  DECLARE none_found = i2 WITH protect ,noconstant (12 )
 ENDIF
 IF ((validate (select_error ,- (1 ) ) != 13 ) )
  DECLARE select_error = i2 WITH protect ,noconstant (13 )
 ENDIF
 IF ((validate (update_cnt_error ,- (1 ) ) != 14 ) )
  DECLARE update_cnt_error = i2 WITH protect ,noconstant (14 )
 ENDIF
 IF ((validate (not_found ,- (1 ) ) != 15 ) )
  DECLARE not_found = i2 WITH protect ,noconstant (15 )
 ENDIF
 IF ((validate (version_insert_error ,- (1 ) ) != 16 ) )
  DECLARE version_insert_error = i2 WITH protect ,noconstant (16 )
 ENDIF
 IF ((validate (inactivate_error ,- (1 ) ) != 17 ) )
  DECLARE inactivate_error = i2 WITH protect ,noconstant (17 )
 ENDIF
 IF ((validate (activate_error ,- (1 ) ) != 18 ) )
  DECLARE activate_error = i2 WITH protect ,noconstant (18 )
 ENDIF
 IF ((validate (version_delete_error ,- (1 ) ) != 19 ) )
  DECLARE version_delete_error = i2 WITH protect ,noconstant (19 )
 ENDIF
 IF ((validate (uar_error ,- (1 ) ) != 20 ) )
  DECLARE uar_error = i2 WITH protect ,noconstant (20 )
 ENDIF
 IF ((validate (duplicate_error ,- (1 ) ) != 21 ) )
  DECLARE duplicate_error = i2 WITH protect ,noconstant (21 )
 ENDIF
 IF ((validate (ccl_error ,- (1 ) ) != 22 ) )
  DECLARE ccl_error = i2 WITH protect ,noconstant (22 )
 ENDIF
 IF ((validate (execute_error ,- (1 ) ) != 23 ) )
  DECLARE execute_error = i2 WITH protect ,noconstant (23 )
 ENDIF
 IF ((validate (failed ,- (1 ) ) != 0 ) )
  DECLARE failed = i2 WITH protect ,noconstant (false )
 ENDIF
 IF ((validate (table_name ,"ZZZ" ) = "ZZZ" ) )
  DECLARE table_name = vc WITH protect ,noconstant ("" )
 ELSE
  SET table_name = fillstring (100 ," " )
 ENDIF
 IF ((validate (call_echo_ind ,- (1 ) ) != 0 ) )
  DECLARE call_echo_ind = i2 WITH protect ,noconstant (false )
 ENDIF
 IF ((validate (i_version ,- (1 ) ) != 0 ) )
  DECLARE i_version = i2 WITH protect ,noconstant (0 )
 ENDIF
 IF ((validate (program_name ,"ZZZ" ) = "ZZZ" ) )
  DECLARE program_name = vc WITH protect ,noconstant (fillstring (30 ," " ) )
 ENDIF
 IF ((validate (sch_security_id ,- (1 ) ) != 0 ) )
  DECLARE sch_security_id = f8 WITH protect ,noconstant (0.0 )
 ENDIF
 IF ((validate (last_mod ,"NOMOD" ) = "NOMOD" ) )
  DECLARE last_mod = c5 WITH private ,noconstant ("" )
 ENDIF
 IF ((validate (schuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring schuar_def" )
  DECLARE schuar_def = i2 WITH persist
  SET schuar_def = 1
  DECLARE uar_sch_check_security ((sec_type_cd = f8 (ref ) ) ,(parent1_id = f8 (ref ) ) ,(parent2_id
   = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref ) ) ,(user_id = f8 (ref ) ) ) = i4
  WITH image_axp = "shrschuar" ,image_aix = "libshrschuar.a(libshrschuar.o)" ,uar =
  "uar_sch_check_security" ,persist
  DECLARE uar_sch_security_insert ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(parent1_id =
   f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref ) ) ) = i4
  WITH image_axp = "shrschuar" ,image_aix = "libshrschuar.a(libshrschuar.o)" ,uar =
  "uar_sch_security_insert" ,persist
  DECLARE uar_sch_security_perform () = i4 WITH image_axp = "shrschuar" ,image_aix =
  "libshrschuar.a(libshrschuar.o)" ,uar = "uar_sch_security_perform" ,persist
  DECLARE uar_sch_check_security_ex ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(parent1_id
   = f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref ) ) ) = i4
  WITH image_axp = "shrschuar" ,image_aix = "libshrschuar.a(libshrschuar.o)" ,uar =
  "uar_sch_check_security_ex" ,persist
  DECLARE uar_sch_check_security_ex2 ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(
   parent1_id = f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref
    ) ) ,(position_cd = f8 (ref ) ) ) = i4 WITH image_axp = "shrschuar" ,image_aix =
  "libshrschuar.a(libshrschuar.o)" ,uar = "uar_sch_check_security_ex2" ,persist
  DECLARE uar_sch_security_insert_ex2 ((user_id = f8 (ref ) ) ,(sec_type_cd = f8 (ref ) ) ,(
   parent1_id = f8 (ref ) ) ,(parent2_id = f8 (ref ) ) ,(parent3_id = f8 (ref ) ) ,(sec_id = f8 (ref
    ) ) ,(position_cd = f8 (ref ) ) ) = i4 WITH image_axp = "shrschuar" ,image_aix =
  "libshrschuar.a(libshrschuar.o)" ,uar = "uar_sch_security_insert_ex2" ,persist
 ENDIF
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
 SET stat = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 IF (NOT (validate (format_text_request ,0 ) ) )
  RECORD format_text_request (
    1 call_echo_ind = i2
    1 raw_text = vc
    1 temp_str = vc
    1 chars_per_line = i4
  )
 ENDIF
 IF (NOT (validate (format_text_reply ,0 ) ) )
  RECORD format_text_reply (
    1 beg_index = i4
    1 end_index = i4
    1 temp_index = i4
    1 qual_alloc = i4
    1 qual_cnt = i4
    1 qual [* ]
      2 text_string = vc
  )
 ENDIF
 SET format_text_reply->qual_cnt = 0
 SET format_text_reply->qual_alloc = 0
 SUBROUTINE  format_text (null_index )
  SET format_text_request->raw_text = trim (format_text_request->raw_text ,3 )
  SET text_length = textlen (format_text_request->raw_text )
  SET format_text_request->temp_str = " "
  FOR (j_text = 1 TO text_length )
   SET temp_char = substring (j_text ,1 ,format_text_request->raw_text )
   IF ((temp_char = " " ) )
    SET temp_char = "^"
   ENDIF
   SET t_number = ichar (temp_char )
   IF ((t_number != 10 )
   AND (t_number != 13 ) )
    SET format_text_request->temp_str = concat (format_text_request->temp_str ,temp_char )
   ENDIF
   IF ((t_number = 13 ) )
    SET format_text_request->temp_str = concat (format_text_request->temp_str ,"^" )
   ENDIF
  ENDFOR
  SET format_text_request->temp_str = replace (format_text_request->temp_str ,"^" ," " ,0 )
  SET format_text_request->raw_text = format_text_request->temp_str
  SET format_text_reply->beg_index = 0
  SET format_text_reply->end_index = 0
  SET format_text_reply->qual_cnt = 0
  SET text_len = textlen (format_text_request->raw_text )
  IF ((text_len > format_text_request->chars_per_line ) )
   WHILE ((text_len > format_text_request->chars_per_line ) )
    SET wrap_ind = 0
    SET format_text_reply->beg_index = 1
    WHILE ((wrap_ind = 0 ) )
     SET format_text_reply->end_index = findstring (" " ,format_text_request->raw_text ,
      format_text_reply->beg_index )
     IF ((format_text_reply->end_index = 0 ) )
      SET format_text_reply->end_index = (format_text_request->chars_per_line + 10 )
     ENDIF
     IF ((format_text_reply->beg_index = 1 )
     AND (format_text_reply->end_index > format_text_request->chars_per_line ) )
      SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt + 1 )
      IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc ) )
       SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc + 10 )
       SET stat = alterlist (format_text_reply->qual ,format_text_reply->qual_alloc )
      ENDIF
      SET format_text_reply->qual[format_text_reply->qual_cnt ].text_string = substring (1 ,
       format_text_request->chars_per_line ,format_text_request->raw_text )
      SET format_text_request->raw_text = substring ((format_text_request->chars_per_line + 1 ) ,(
       text_len - format_text_request->chars_per_line ) ,format_text_request->raw_text )
      SET wrap_ind = 1
     ELSEIF ((format_text_reply->end_index > format_text_request->chars_per_line ) )
      SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt + 1 )
      IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc ) )
       SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc + 10 )
       SET stat = alterlist (format_text_reply->qual ,format_text_reply->qual_alloc )
      ENDIF
      SET format_text_reply->qual[format_text_reply->qual_cnt ].text_string = substring (1 ,(
       format_text_reply->beg_index - 1 ) ,format_text_request->raw_text )
      SET format_text_request->raw_text = substring (format_text_reply->beg_index ,((text_len -
       format_text_reply->beg_index ) + 1 ) ,format_text_request->raw_text )
      SET wrap_ind = 1
     ENDIF
     SET format_text_reply->beg_index = (format_text_reply->end_index + 1 )
    ENDWHILE
    SET text_len = textlen (format_text_request->raw_text )
   ENDWHILE
   SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt + 1 )
   IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc ) )
    SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc + 10 )
    SET stat = alterlist (format_text_reply->qual ,format_text_reply->qual_alloc )
   ENDIF
   SET format_text_reply->qual[format_text_reply->qual_cnt ].text_string = format_text_request->
   raw_text
  ELSE
   SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt + 1 )
   IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc ) )
    SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc + 10 )
    SET stat = alterlist (format_text_reply->qual ,format_text_reply->qual_alloc )
   ENDIF
   SET format_text_reply->qual[format_text_reply->qual_cnt ].text_string = format_text_request->
   raw_text
  ENDIF
 END ;Subroutine
 SUBROUTINE  inc_format_text (null_index )
  SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt + 1 )
  IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc ) )
   SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc + 10 )
   SET stat = alterlist (format_text_reply->qual ,format_text_reply->qual_alloc )
  ENDIF
 END ;Subroutine
 IF (NOT (validate (get_atgroup_exp_request ,0 ) ) )
  RECORD get_atgroup_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_atgroup_exp_reply ,0 ) ) )
  RECORD get_atgroup_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 appt_type_cd = f8
  )
 ENDIF
 IF (NOT (validate (get_locgroup_exp_request ,0 ) ) )
  RECORD get_locgroup_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_locgroup_exp_reply ,0 ) ) )
  RECORD get_locgroup_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 location_cd = f8
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_request ,0 ) ) )
  RECORD get_res_group_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 res_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_reply ,0 ) ) )
  RECORD get_res_group_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 res_group_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 resource_cd = f8
        3 mnemonic = vc
        3 description = vc
        3 quota = i4
        3 person_id = f8
        3 id_disp = vc
        3 res_type_flag = i2
        3 active_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_slot_group_exp_request ,0 ) ) )
  RECORD get_slot_group_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 slot_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_slot_group_exp_reply ,0 ) ) )
  RECORD get_slot_group_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 slot_group_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 slot_type_id = f8
  )
 ENDIF
 RECORD reply (
   1 attr_qual_cnt = i4
   1 attr_qual [* ]
     2 attr_name = c31
     2 attr_label = c60
     2 attr_type = c8
     2 attr_def_seq = i4
     2 attr_alt_sort_column = vc
   1 query_qual_cnt = i4
   1 query_qual [* ]
     2 hide#schentryid = f8
     2 hide#scheventid = f8
     2 hide#scheduleid = f8
     2 hide#scheduleseq = i4
     2 hide#reqactionid = f8
     2 hide#actionid = f8
     2 hide#schapptid = f8
     2 hide#statemeaning = vc
     2 hide#earliestdttm = dq8
     2 hide#latestdttm = dq8
     2 hide#reqmadedttm = dq8
     2 hide#entrystatemeaning = c12
     2 hide#reqactionmeaning = c12
     2 hide#encounterid = f8
     2 hide#personid = f8
     2 hide#bitmask = i4
     2 isolation_type = vc
     2 stat = vc
     2 inpatient = vc
     2 cmt = vc
     2 time = vc
     2 earliest_dt_tm = dq8
     2 scheduled_dt_tm = dq8
     2 days_of_week = vc
     2 req_action_display = vc
     2 appt_type_display = vc
     2 person_name = vc
     2 sch_action_id = f8
     2 sch_event_id = f8
     2 orders = vc
     2 order_cmt = vc
     2 healthplan = vc ;001
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 ;SET reply->attr_qual_cnt = 28
 SET reply->attr_qual_cnt = 29
 SET t_index = 0
 SET stat = alterlist (reply->attr_qual ,reply->attr_qual_cnt )
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#schentryid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#SCHENTRYID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#scheventid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#SCHEVENTID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#scheduleid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#SCHEDULEID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#scheduleseq"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#SCHEDULESEQ"
 SET reply->attr_qual[t_index ].attr_type = "i4"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#reqactionid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#REQACTIONID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#actionid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#ACTIONID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#schapptid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#SCHAPPTID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#statemeaning"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#STATEMEANING"
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#earliestdttm"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#EARLIESTDTTM"
 SET reply->attr_qual[t_index ].attr_type = "dq8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#latestdttm"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#LATESTDTTM"
 SET reply->attr_qual[t_index ].attr_type = "dq8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#reqmadedttm"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#REQMADEDTTM"
 SET reply->attr_qual[t_index ].attr_type = "dq8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#entrystatemeaning"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#ENTRYSTATEMEANING"
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#reqactionmeaning"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#REQACTIONMEANING"
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#encounterid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#ENCOUNTERID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#personid"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#PERSONID"
 SET reply->attr_qual[t_index ].attr_type = "f8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "hide#bitmask"
 SET reply->attr_qual[t_index ].attr_label = "HIDE#BITMASK"
 SET reply->attr_qual[t_index ].attr_type = "i4"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "cmt"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"C" ,"C" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "order_cmt"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"OC" ,"OC" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "isolation_type"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Iso" ,"Iso" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "stat"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Stat" ,"Stat" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "inpatient"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Inp" ,"Inp" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "req_action_display"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Action" ,"Action" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "person_name"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Person Name" ,
  "Person Name" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "HealthPlan"
  SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,
   "HealthPlan" ,"HealthPlan" )  ;001
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "appt_type_display"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Appointment Type" ,
  "Appointment Type" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "earliest_dt_tm"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Earliest Date" ,
  "Earliest Date" )
 SET reply->attr_qual[t_index ].attr_type = "dq8"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "time"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Time" ,"Time" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "orders"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Orders" ,"Orders" )
 SET reply->attr_qual[t_index ].attr_type = "vc"
 SET t_index = (t_index + 1 )
 SET reply->attr_qual[t_index ].attr_name = "scheduled_dt_tm"
 SET reply->attr_qual[t_index ].attr_label = uar_i18ngetmessage (i18nhandle ,"Scheduled Date" ,
  "Scheduled Date" )
 SET reply->attr_qual[t_index ].attr_type = "dq8"
 
 SET reply->query_qual_cnt = 0
 SET stat = alterlist (reply->query_qual ,reply->query_qual_cnt )
 FREE SET t_record
 RECORD t_record (
   1 queue_id = f8
   1 person_id = f8
   1 resource_cd = f8
   1 location_cd = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 atgroup_id = f8
   1 locgroup_id = f8
   1 res_group_id = f8
   1 slot_group_id = f8
   1 appt_type_cd = f8
   1 title = vc
   1 appttype_qual_cnt = i4
   1 appttype_qual [* ]
     2 appt_type_cd = f8
   1 location_qual_cnt = i4
   1 location_qual [* ]
     2 location_cd = f8
   1 resource_qual_cnt = i4
   1 resource_qual [* ]
     2 resource_cd = f8
     2 person_id = f8
   1 slot_qual_cnt = i4
   1 slot_qual [* ]
     2 slot_type_id = f8
   1 user_defined = vc
   1 order_type_cd = f8
   1 order_type_meaning = c12
   1 pending_state_cd = f8
   1 pending_state_meaning = c12
   1 isobeg_type_cd = f8
   1 isobeg_type_meaning = c12
   1 isoend_type_cd = f8
   1 isoend_type_meaning = c12
   1 isolation_type_cd = f8
   1 isolation_type_meaning = c12
   1 userdefined_type_cd = f8
   1 userdefined_type_meaning = c12
   1 temp_beg_dt_tm = dq8
   1 temp_end_dt_tm = dq8
   1 temp_isolation_cd = f8
   1 ordcomment_cd = f8
   1 ordcomment_meaning = c12
   1 order_action_cd = f8
   1 order_action_meaning = c12
   1 modify_action_cd = f8
   1 modify_action_meaning = c12
   1 collection_action_cd = f8
   1 collection_action_meaning = c12
   1 renew_action_cd = f8
   1 renew_action_meaning = c12
   1 activate_action_cd = f8
   1 activate_action_meaning = c12
   1 futuredc_action_cd = f8
   1 futuredc_action_meaning = c12
   1 resume_renew_action_cd = f8
   1 resume_renew_action_meaning = c12
   1 max_order_cnt = i4
   1 event_qual [* ]
     2 protocol_parent_id = f8
     2 order_qual_cnt = i4
     2 order_qual [* ]
       3 order_id = f8
       3 description = vc
       3 order_seq_nbr = i4
 )
 CALL echo ("Checking the input fields..." )
 FOR (i_input = 1 TO size (request->qual ,5 ) )
  IF ((request->qual[i_input ].oe_field_meaning_id = 0 ) )
   CASE (request->qual[i_input ].oe_field_meaning )
    OF "QUEUE" :
     SET t_record->queue_id = request->qual[i_input ].oe_field_value
    OF "PERSON" :
     SET t_record->person_id = request->qual[i_input ].oe_field_value
    OF "RESOURCE" :
     SET t_record->resource_cd = request->qual[i_input ].oe_field_value
    OF "LOCATION" :
     SET t_record->location_cd = request->qual[i_input ].oe_field_value
    OF "BEGDTTM" :
     SET t_record->beg_dt_tm = request->qual[i_input ].oe_field_dt_tm_value
    OF "ENDDTTM" :
     SET t_record->end_dt_tm = request->qual[i_input ].oe_field_dt_tm_value
    OF "ATGROUP" :
     SET t_record->atgroup_id = request->qual[i_input ].oe_field_value
    OF "LOCGROUP" :
     SET t_record->locgroup_id = request->qual[i_input ].oe_field_value
    OF "RESGROUP" :
     SET t_record->res_group_id = request->qual[i_input ].oe_field_value
    OF "SLOTGROUP" :
     SET t_record->slot_group_id = request->qual[i_input ].oe_field_value
    OF "TITLE" :
     SET t_record->title = request->qual[i_input ].oe_field_display_value
    OF "APPTTYPE" :
     SET t_record->appt_type_cd = request->qual[i_input ].oe_field_value
   ENDCASE
  ELSE
   CASE (request->qual[i_input ].label_text )
    OF "<Label Text Goes Here>" :
     SET t_record->user_defined = request->qual[i_input ].oe_field_display_value
   ENDCASE
  ENDIF
 ENDFOR
 IF ((t_record->atgroup_id > 0 ) )
  SET get_atgroup_exp_request->call_echo_ind = 0
  SET get_atgroup_exp_request->security_ind = 1
  SET get_atgroup_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_atgroup_exp_request->qual ,get_atgroup_exp_reply->qual_cnt )
  SET get_atgroup_exp_request->qual[get_atgroup_exp_reply->qual_cnt ].sch_object_id = t_record->
  atgroup_id
  SET get_atgroup_exp_request->qual[get_atgroup_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_atgroup_exp
  FOR (i_input = 1 TO get_atgroup_exp_reply->qual_cnt )
   SET t_record->appttype_qual_cnt = get_atgroup_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->appttype_qual ,t_record->appttype_qual_cnt )
   FOR (j_input = 1 TO t_record->appttype_qual_cnt )
    SET t_record->appttype_qual[j_input ].appt_type_cd = get_atgroup_exp_reply->qual[i_input ].qual[
    j_input ].appt_type_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->appttype_qual_cnt = 0
 ENDIF
 IF ((t_record->locgroup_id > 0 ) )
  SET get_locgroup_exp_request->call_echo_ind = 0
  SET get_locgroup_exp_request->security_ind = 1
  SET get_locgroup_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_locgroup_exp_request->qual ,get_locgroup_exp_reply->qual_cnt )
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt ].sch_object_id = t_record->
  locgroup_id
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_locgroup_exp
  FOR (i_input = 1 TO get_locgroup_exp_reply->qual_cnt )
   SET t_record->location_qual_cnt = get_locgroup_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->location_qual ,t_record->location_qual_cnt )
   FOR (j_input = 1 TO t_record->location_qual_cnt )
    SET t_record->location_qual[j_input ].location_cd = get_locgroup_exp_reply->qual[i_input ].qual[
    j_input ].location_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->location_qual_cnt = 0
 ENDIF
 IF ((t_record->res_group_id > 0 ) )
  SET get_res_group_exp_request->call_echo_ind = 0
  SET get_res_group_exp_request->security_ind = 1
  SET get_res_group_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_res_group_exp_request->qual ,get_res_group_exp_reply->qual_cnt )
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt ].res_group_id = t_record->
  res_group_id
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_res_group_exp
  FOR (i_input = 1 TO get_res_group_exp_reply->qual_cnt )
   SET t_record->resource_qual_cnt = get_res_group_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->resource_qual ,t_record->resource_qual_cnt )
   FOR (j_input = 1 TO t_record->resource_qual_cnt )
    SET t_record->resource_qual[j_input ].resource_cd = get_res_group_exp_reply->qual[i_input ].qual[
    j_input ].resource_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->resource_qual_cnt = 0
 ENDIF
 IF ((t_record->slot_group_id > 0 ) )
  SET get_slot_group_exp_request->call_echo_ind = 0
  SET get_slot_group_exp_request->security_ind = 1
  SET get_slot_group_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_slot_group_exp_request->qual ,get_slot_group_exp_reply->qual_cnt )
  SET get_slot_group_exp_request->qual[get_slot_group_exp_reply->qual_cnt ].slot_group_id = t_record
  ->slot_group_id
  SET get_slot_group_exp_request->qual[get_slot_group_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_slot_group_exp
  FOR (i_input = 1 TO get_slot_group_exp_reply->qual_cnt )
   SET t_record->slot_qual_cnt = get_slot_group_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->slot_qual ,t_record->slot_qual_cnt )
   FOR (j_input = 1 TO t_record->slot_qual_cnt )
    SET t_record->slot_qual[j_input ].slot_type_id = get_slot_group_exp_reply->qual[i_input ].qual[
    j_input ].slot_type_id
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->slot_qual_cnt = 0
 ENDIF
 IF ((t_record->resource_qual_cnt > 0 ) )
  SELECT INTO "nl:"
   a.person_id ,
   d.seq
   FROM (dummyt d WITH seq = value (t_record->resource_qual_cnt ) ),
    (sch_resource a )
   PLAN (d )
    JOIN (a
    WHERE (a.resource_cd = t_record->resource_qual[d.seq ].resource_cd )
    AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   DETAIL
    t_record->resource_qual[d.seq ].person_id = a.person_id
   WITH nocounter
  ;end select
 ENDIF
 SET t_record->pending_state_cd = 0.0
 SET t_record->pending_state_meaning = fillstring (12 ," " )
 SET t_record->pending_state_meaning = "PENDING"
 SET stat = uar_get_meaning_by_codeset (23018 ,t_record->pending_state_meaning ,1 ,t_record->
  pending_state_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(23018," ,t_record->pending_state_meaning ,",1," ,
   t_record->pending_state_cd ,")" ) )
 IF ((((stat != 0 ) ) OR ((t_record->pending_state_cd <= 0 ) )) )
  IF (call_echo_ind )
   CALL echo (build ("stat = " ,stat ) )
   CALL echo (build ("t_record->pending_state_cd = " ,t_record->pending_state_cd ) )
   CALL echo (build ("Invalid select on CODE_SET (23018), CDF_MEANING(" ,t_record->
     pending_state_meaning ,")" ) )
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ad_null = nullind (ad.sch_action_id ) ,
  l_null = nullind (l.sch_lock_id ) ,
  a.queue_id
  FROM (sch_entry a ),
   (sch_event_action ea ),
   (sch_event e ),
   (person p ),
   (encounter enc ),
   (sch_lock l ),
   (sch_action_date ad )
  PLAN (a
   WHERE (a.appt_type_cd = t_record->appt_type_cd )
   AND (a.entry_state_cd = t_record->pending_state_cd )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (ea
   WHERE (ea.sch_action_id = a.sch_action_id )
   AND (ea.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (e
   WHERE (e.sch_event_id = ea.sch_event_id )
   AND (e.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (p
   WHERE (p.person_id = a.person_id ) )
   JOIN (enc
   WHERE (enc.encntr_id = a.encntr_id ) )
   JOIN (l
   WHERE (l.parent_table = outerjoin ("SCH_EVENT" ) )
   AND (l.parent_id = outerjoin (a.sch_event_id ) )
   AND (l.release_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (l.version_dt_tm = outerjoin (cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) ) )
   JOIN (ad
   WHERE (ad.sch_action_id = outerjoin (a.sch_action_id ) )
   AND (ad.scenario_nbr = outerjoin (1 ) )
   AND (ad.seq_nbr = outerjoin (1 ) )
   AND (ad.version_dt_tm = outerjoin (cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) ) )
  ORDER BY a.sch_action_id
  HEAD REPORT
   reply->query_qual_cnt = 0
  HEAD a.sch_action_id
   IF ((((l_null = 1 ) ) OR ((l.status_flag = 3 )
   AND (l.granted_prsnl_id = reqinfo->updt_id ) )) ) reply->query_qual_cnt = (reply->query_qual_cnt
    + 1 ) ,
    IF ((mod (reply->query_qual_cnt ,100 ) = 1 ) ) stat = alterlist (reply->query_qual ,(reply->
      query_qual_cnt + 99 ) ) ,stat = alterlist (t_record->event_qual ,(reply->query_qual_cnt + 99 )
      )
    ENDIF
    ,reply->query_qual[reply->query_qual_cnt ].hide#schentryid = a.sch_entry_id ,reply->query_qual[
    reply->query_qual_cnt ].hide#scheventid = a.sch_event_id ,reply->query_qual[reply->query_qual_cnt
     ].hide#scheduleid = a.schedule_id ,reply->query_qual[reply->query_qual_cnt ].hide#scheduleseq =
    e.schedule_seq ,reply->query_qual[reply->query_qual_cnt ].hide#reqactionid = a.sch_action_id ,
    reply->query_qual[reply->query_qual_cnt ].hide#actionid = ea.req_action_id ,reply->query_qual[
    reply->query_qual_cnt ].hide#schapptid = a.sch_appt_id ,reply->query_qual[reply->query_qual_cnt ]
    .hide#statemeaning = e.sch_meaning ,reply->query_qual[reply->query_qual_cnt ].hide#earliestdttm
    = cnvtdatetime (a.earliest_dt_tm ) ,reply->query_qual[reply->query_qual_cnt ].hide#latestdttm =
    cnvtdatetime (a.latest_dt_tm ) ,reply->query_qual[reply->query_qual_cnt ].hide#reqmadedttm =
    cnvtdatetime (a.request_made_dt_tm ) ,reply->query_qual[reply->query_qual_cnt ].
    hide#entrystatemeaning = a.entry_state_meaning ,reply->query_qual[reply->query_qual_cnt ].
    hide#reqactionmeaning = a.req_action_meaning ,reply->query_qual[reply->query_qual_cnt ].
    hide#encounterid = a.encntr_id ,reply->query_qual[reply->query_qual_cnt ].hide#personid = a
    .person_id ,reply->query_qual[reply->query_qual_cnt ].hide#bitmask = 0 ,
    IF ((a.earliest_dt_tm > cnvtdatetime ("01-JAN-1800 00:00:00.00" ) ) ) reply->query_qual[reply->
     query_qual_cnt ].earliest_dt_tm = cnvtdatetime (a.earliest_dt_tm )
    ELSE reply->query_qual[reply->query_qual_cnt ].earliest_dt_tm = 0
    ENDIF
    ,
    IF (NOT ((format (a.earliest_dt_tm ,"HHMM;;DATE" ) IN ("0000" ,
    "0001" ) ) ) ) reply->query_qual[reply->query_qual_cnt ].time = format (a.earliest_dt_tm ,
      "HH:MM;;DATE" )
    ELSE reply->query_qual[reply->query_qual_cnt ].time = ""
    ENDIF
    ,
    IF ((ad_null = 0 ) )
     IF ((ad.time_restr_cd > 0 ) ) reply->query_qual[reply->query_qual_cnt ].time =
      uar_get_code_display (ad.time_restr_cd )
     ENDIF
     ,
     FOR (i = 1 TO 7 )
      IF ((substring (i ,1 ,ad.days_of_week ) = "X" ) ) reply->query_qual[reply->query_qual_cnt ].
       days_of_week = build (reply->query_qual[reply->query_qual_cnt ].days_of_week ,evaluate (i ,1 ,
         "Sun," ,2 ,"Mon," ,3 ,"Tue," ,4 ,"Wed," ,5 ,"Thu," ,6 ,"Fri," ,7 ,"Sat," ) )
      ENDIF
     ENDFOR
     ,
     IF ((reply->query_qual[reply->query_qual_cnt ].days_of_week > " " ) ) reply->query_qual[reply->
      query_qual_cnt ].days_of_week = substring (1 ,(size (reply->query_qual[reply->query_qual_cnt ].
        days_of_week ) - 1 ) ,reply->query_qual[reply->query_qual_cnt ].days_of_week )
     ENDIF
    ELSE reply->query_qual[reply->query_qual_cnt ].days_of_week = ""
    ENDIF
    ,reply->query_qual[reply->query_qual_cnt ].req_action_display = uar_get_code_display (a
     .req_action_cd ) ,reply->query_qual[reply->query_qual_cnt ].appt_type_display =
    uar_get_code_display (e.appt_synonym_cd ) ,
    IF ((a.person_id > 0 ) ) reply->query_qual[reply->query_qual_cnt ].person_name = p
     .name_full_formatted
    ELSE reply->query_qual[reply->query_qual_cnt ].person_name = ""
    ENDIF
    ,
    IF ((e.protocol_type_flag = 1 ) ) t_record->event_qual[reply->query_qual_cnt ].protocol_parent_id
      = e.sch_event_id
    ENDIF
    ,
    IF ((uar_get_code_display (enc.encntr_type_cd ) IN ("Inpatient" ,
    "After Hours Inpatient" ) ) ) reply->query_qual[reply->query_qual_cnt ].inpatient = "Yes"
    ENDIF
   ENDIF
  FOOT REPORT
   IF ((mod (reply->query_qual_cnt ,100 ) != 0 ) ) stat = alterlist (reply->query_qual ,reply->
     query_qual_cnt ) ,stat = alterlist (t_record->event_qual ,reply->query_qual_cnt )
   ENDIF
   ,t_record->max_order_cnt = 0
  WITH nocounter
 ;end select
 IF ((reply->query_qual_cnt <= 0 ) )
  GO TO exit_script
 ENDIF
 
 ;001 - health plan
FOR (cnt = 1 to reply->query_qual_cnt)

	IF (reply->query_qual[cnt].hide#encounterid > 0)
	
		 SELECT into 'nl:'
		 
		 FROM encntr_plan_reltn epr,
		 	  health_plan hp
		 
		PLAN epr
		WHERE reply->query_qual[cnt].hide#encounterid = epr.encntr_id
		AND epr.active_ind = 1
		JOIN hp
		WHERE epr.health_plan_id = hp.health_plan_id
		AND hp.active_ind = 1
		 
		 
		DETAIL
			reply->query_qual[cnt].healthplan = hp.plan_name
		 
		 WITH nocounter
	
	ELSE
			 SELECT into 'nl:'
		 
		 FROM person_plan_reltn ppr,
		 	  health_plan hp
		 
		PLAN ppr
		WHERE reply->query_qual[cnt].hide#personid = ppr.person_id
		AND ppr.active_ind = 1
		JOIN hp
		WHERE ppr.health_plan_id = hp.health_plan_id
		AND hp.active_ind = 1
		 
		 
		DETAIL
			reply->query_qual[cnt].healthplan = hp.plan_name
		 
		 WITH nocounter
	
	
	ENDIF


ENDFOR
 
 SELECT INTO "nl:"
  t_sort = evaluate (a.role_meaning ,"PATIENT" ,2 ,a.primary_role_ind ) ,
  a.updt_cnt
  FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
   (sch_appt a )
  PLAN (d
   WHERE (reply->query_qual[d.seq ].hide#scheventid > 0 )
   AND (reply->query_qual[d.seq ].hide#scheduleid > 0 ) )
   JOIN (a
   WHERE (a.sch_event_id = reply->query_qual[d.seq ].hide#scheventid )
   AND (a.schedule_id = reply->query_qual[d.seq ].hide#scheduleid )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
  ORDER BY d.seq ,
   t_sort
  DETAIL
   reply->query_qual[d.seq ].hide#bitmask = a.bit_mask ,
   reply->query_qual[d.seq ].scheduled_dt_tm = cnvtdatetime (a.beg_dt_tm )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.updt_cnt
  FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
   (sch_event_comm a )
  PLAN (d )
   JOIN (a
   WHERE (a.sch_event_id = reply->query_qual[d.seq ].hide#scheventid )
   AND (a.sch_action_id = reply->query_qual[d.seq ].hide#reqactionid )
   AND (a.text_type_meaning = "ACTION" )
   AND (a.sub_text_meaning = "ACTION" )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
  DETAIL
   reply->query_qual[d.seq ].cmt = "Y"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.updt_cnt
  FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
   (sch_event_comm a )
  PLAN (d )
   JOIN (a
   WHERE (a.sch_event_id = reply->query_qual[d.seq ].hide#scheventid )
   AND (a.sch_action_id = reply->query_qual[d.seq ].hide#actionid )
   AND (a.text_type_meaning = "ACTION" )
   AND (a.sub_text_meaning = "ACTION" )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
  DETAIL
   reply->query_qual[d.seq ].cmt = "Y"
  WITH nocounter
 ;end select
 SET t_record->order_type_cd = 0.0
 SET t_record->order_type_meaning = fillstring (12 ," " )
 SET t_record->order_type_meaning = "ORDER"
 SET stat = uar_get_meaning_by_codeset (16110 ,t_record->order_type_meaning ,1 ,t_record->
  order_type_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(16110," ,t_record->order_type_meaning ,",1," ,t_record
   ->order_type_cd ,")" ) )
 IF ((((stat != 0 ) ) OR ((t_record->order_type_cd <= 0 ) )) )
  IF (call_echo_ind )
   CALL echo (build ("stat = " ,stat ) )
   CALL echo (build ("t_record->order_type_cd = " ,t_record->order_type_cd ) )
   CALL echo (build ("Invalid select on CODE_SET (16110), CDF_MEANING(" ,t_record->order_type_meaning
      ,")" ) )
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
   (sch_event e ),
   (sch_event_attach a )
  PLAN (d
   WHERE (t_record->event_qual[d.seq ].protocol_parent_id > 0 ) )
   JOIN (e
   WHERE (e.protocol_parent_id = t_record->event_qual[d.seq ].protocol_parent_id )
   AND NOT ((e.sch_meaning IN ("CANCELED" ,
   "NOSHOW" ) ) )
   AND (e.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (a
   WHERE (a.sch_event_id = e.sch_event_id )
   AND (a.attach_type_cd = t_record->order_type_cd )
   AND (a.beg_schedule_seq <= reply->query_qual[d.seq ].hide#scheduleseq )
   AND (a.end_schedule_seq >= reply->query_qual[d.seq ].hide#scheduleseq )
   AND NOT ((a.order_status_meaning IN ("CANCELED" ,
   "COMPLETED" ,
   "DISCONTINUED" ) ) )
   AND (a.state_meaning != "REMOVED" )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (a.active_ind = 1 ) )
  ORDER BY d.seq ,
   e.protocol_seq_nbr ,
   a.order_seq_nbr
  HEAD d.seq
   t_record->event_qual[d.seq ].order_qual_cnt = 0
  DETAIL
   t_record->event_qual[d.seq ].order_qual_cnt = (t_record->event_qual[d.seq ].order_qual_cnt + 1 ) ,
   IF ((mod (t_record->event_qual[d.seq ].order_qual_cnt ,10 ) = 1 ) ) stat = alterlist (t_record->
     event_qual[d.seq ].order_qual ,(t_record->event_qual[d.seq ].order_qual_cnt + 9 ) )
   ENDIF
   ,t_record->event_qual[d.seq ].order_qual[t_record->event_qual[d.seq ].order_qual_cnt ].order_id =
   a.order_id ,
   t_record->event_qual[d.seq ].order_qual[t_record->event_qual[d.seq ].order_qual_cnt ].description
   = a.description ,
   t_record->event_qual[d.seq ].order_qual[t_record->event_qual[d.seq ].order_qual_cnt ].
   order_seq_nbr = a.order_seq_nbr
  FOOT  d.seq
   IF ((mod (t_record->event_qual[d.seq ].order_qual_cnt ,10 ) != 0 ) ) stat = alterlist (t_record->
     event_qual[d.seq ].order_qual ,t_record->event_qual[d.seq ].order_qual_cnt )
   ENDIF
   ,
   IF ((t_record->event_qual[d.seq ].order_qual_cnt > t_record->max_order_cnt ) ) t_record->
    max_order_cnt = t_record->event_qual[d.seq ].order_qual_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
   (sch_event_attach a )
  PLAN (d
   WHERE (t_record->event_qual[d.seq ].protocol_parent_id <= 0 ) )
   JOIN (a
   WHERE (a.sch_event_id = reply->query_qual[d.seq ].hide#scheventid )
   AND (a.attach_type_cd = t_record->order_type_cd )
   AND (a.beg_schedule_seq <= reply->query_qual[d.seq ].hide#scheduleseq )
   AND (a.end_schedule_seq >= reply->query_qual[d.seq ].hide#scheduleseq )
   AND NOT ((a.order_status_meaning IN ("CANCELED" ,
   "COMPLETED" ,
   "DISCONTINUED" ) ) )
   AND (a.state_meaning != "REMOVED" )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (a.active_ind = 1 ) )
  ORDER BY d.seq ,
   a.order_seq_nbr
  HEAD d.seq
   t_record->event_qual[d.seq ].order_qual_cnt = 0
  DETAIL
   t_record->event_qual[d.seq ].order_qual_cnt = (t_record->event_qual[d.seq ].order_qual_cnt + 1 ) ,
   IF ((mod (t_record->event_qual[d.seq ].order_qual_cnt ,10 ) = 1 ) ) stat = alterlist (t_record->
     event_qual[d.seq ].order_qual ,(t_record->event_qual[d.seq ].order_qual_cnt + 9 ) )
   ENDIF
   ,t_record->event_qual[d.seq ].order_qual[t_record->event_qual[d.seq ].order_qual_cnt ].order_id =
   a.order_id ,
   t_record->event_qual[d.seq ].order_qual[t_record->event_qual[d.seq ].order_qual_cnt ].description
   = a.description ,
   t_record->event_qual[d.seq ].order_qual[t_record->event_qual[d.seq ].order_qual_cnt ].
   order_seq_nbr = a.order_seq_nbr ,
   CALL echo (build ("PROTOCOL_PARENT_ID[" ,t_record->event_qual[d.seq ].protocol_parent_id ,
    "] SCH_EVENT_ID [" ,a.sch_event_id ,"] ORDER_ID [" ,a.order_id ,"]" ) )
  FOOT  d.seq
   IF ((mod (t_record->event_qual[d.seq ].order_qual_cnt ,10 ) != 0 ) ) stat = alterlist (t_record->
     event_qual[d.seq ].order_qual ,t_record->event_qual[d.seq ].order_qual_cnt )
   ENDIF
   ,
   IF ((t_record->event_qual[d.seq ].order_qual_cnt > t_record->max_order_cnt ) ) t_record->
    max_order_cnt = t_record->event_qual[d.seq ].order_qual_cnt
   ENDIF
  WITH nocounter
 ;end select
 SET t_record->order_action_meaning = "ORDER"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->order_action_meaning ,1 ,t_record->
  order_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->order_action_meaning ,",1," ,
   t_record->order_action_cd ,")" ) )
 SET t_record->modify_action_meaning = "MODIFY"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->modify_action_meaning ,1 ,t_record->
  modify_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->modify_action_meaning ,",1," ,
   t_record->modify_action_cd ,")" ) )
 SET t_record->collection_action_meaning = "COLLECTION"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->collection_action_meaning ,1 ,t_record->
  collection_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->collection_action_meaning ,",1," ,
   t_record->collection_action_cd ,")" ) )
 SET t_record->renew_action_meaning = "RENEW"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->renew_action_meaning ,1 ,t_record->
  renew_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->renew_action_meaning ,",1," ,
   t_record->renew_action_cd ,")" ) )
 SET t_record->activate_action_meaning = "ACTIVATE"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->activate_action_meaning ,1 ,t_record->
  activate_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->activate_action_meaning ,",1," ,
   t_record->activate_action_cd ,")" ) )
 SET t_record->futuredc_action_meaning = "FUTUREDC"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->futuredc_action_meaning ,1 ,t_record->
  futuredc_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->futuredc_action_meaning ,",1," ,
   t_record->futuredc_action_cd ,")" ) )
 SET t_record->resume_renew_action_meaning = "RESUME/RENEW"
 SET stat = uar_get_meaning_by_codeset (6003 ,t_record->resume_renew_action_meaning ,1 ,t_record->
  resume_renew_action_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(6003," ,t_record->resume_renew_action_meaning ,",1," ,
   t_record->resume_renew_action_cd ,")" ) )
 IF ((t_record->max_order_cnt > 0 ) )
  SET act_seq = 0
  SELECT INTO "nl:"
   t_order_seq_nbr = t_record->event_qual[d.seq ].order_qual[d2.seq ].order_seq_nbr ,
   od_exists = decode (od.seq ,1 ,0 )
   FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
    (dummyt d2 WITH seq = value (t_record->max_order_cnt ) ),
    (orders o ),
    (order_action oa ),
    (dummyt d3 ),
    (order_detail od )
   PLAN (d )
    JOIN (d2
    WHERE (d2.seq <= t_record->event_qual[d.seq ].order_qual_cnt ) )
    JOIN (o
    WHERE (o.order_id = t_record->event_qual[d.seq ].order_qual[d2.seq ].order_id ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (((oa.action_type_cd = t_record->order_action_cd ) ) OR ((((oa.action_type_cd = t_record->
    modify_action_cd ) ) OR ((((oa.action_type_cd = t_record->activate_action_cd ) ) OR ((((oa
    .action_type_cd = t_record->futuredc_action_cd ) ) OR ((((oa.action_type_cd = t_record->
    renew_action_cd ) ) OR ((((oa.action_type_cd = t_record->resume_renew_action_cd ) ) OR ((oa
    .action_type_cd = t_record->collection_action_cd ) )) )) )) )) )) ))
    AND (oa.action_rejected_ind = 0 ) )
    JOIN (d3
    WHERE (d3.seq = 1 ) )
    JOIN (od
    WHERE (od.order_id = oa.order_id )
    AND (od.action_sequence = oa.action_sequence )
    AND (od.oe_field_meaning_id = 127 ) )
   ORDER BY d.seq ,
    d2.seq ,
    o.order_id ,
    od.oe_field_id ,
    od.action_sequence DESC
   HEAD d.seq
    t_index = 0
   HEAD d2.seq
    t_index = 0
   HEAD o.order_id
    IF ((reply->query_qual[d.seq ].orders <= " " ) ) reply->query_qual[d.seq ].orders = t_record->
     event_qual[d.seq ].order_qual[d2.seq ].description
    ENDIF
    ,
    IF ((o.orig_ord_as_flag = 4 ) ) reply->query_qual[d.seq ].inpatient = "Yes"
    ENDIF
   HEAD od.oe_field_id
    act_seq = od.action_sequence ,flag = 1
   HEAD od.action_sequence
    IF ((act_seq != od.action_sequence ) ) flag = 0
    ENDIF
   DETAIL
    IF ((flag = 1 )
    AND (od_exists = 1 )
    AND (uar_get_code_meaning (od.oe_field_value ) = "STAT" ) ) reply->query_qual[d.seq ].stat =
     "Yes"
    ENDIF
   WITH nocounter ,outerjoin = d3 ,dontcare = od
  ;end select
  SET t_record->ordcomment_cd = 0.0
  SET t_record->ordcomment_meaning = fillstring (12 ," " )
  SET t_record->ordcomment_meaning = "ORD COMMENT"
  SET stat = uar_get_meaning_by_codeset (14 ,t_record->ordcomment_meaning ,1 ,t_record->ordcomment_cd
    )
  CALL echo (build ("UAR_GET_MEANING_BY_CODESET(14," ,t_record->ordcomment_meaning ,",1," ,t_record->
    ordcomment_cd ,")" ) )
  IF ((((stat != 0 ) ) OR ((t_record->ordcomment_cd <= 0 ) )) )
   IF (call_echo_ind )
    CALL echo (build ("stat = " ,stat ) )
    CALL echo (build ("t_record->ordcomment_cd = " ,t_record->ordcomment_cd ) )
    CALL echo (build ("Invalid select on CODE_SET (14), CDF_MEANING(" ,t_record->ordcomment_meaning ,
      ")" ) )
   ENDIF
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   oc.order_id ,
   oc.action_sequence ,
   oc.comment_type_cd
   FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
    (dummyt d2 WITH seq = value (t_record->max_order_cnt ) ),
    (order_comment oc )
   PLAN (d
    WHERE (t_record->event_qual[d.seq ].order_qual_cnt > 0 ) )
    JOIN (d2
    WHERE (d2.seq <= t_record->event_qual[d.seq ].order_qual_cnt ) )
    JOIN (oc
    WHERE (oc.order_id = t_record->event_qual[d.seq ].order_qual[d2.seq ].order_id )
    AND (oc.comment_type_cd = t_record->ordcomment_cd ) )
   HEAD d.seq
    reply->query_qual[d.seq ].order_cmt = "Yes"
   WITH nocounter
  ;end select
 ENDIF
 SET t_record->isobeg_type_cd = 0.0
 SET t_record->isobeg_type_meaning = fillstring (12 ," " )
 SET t_record->isobeg_type_meaning = "ISOBEG"
 SET stat = uar_get_meaning_by_codeset (356 ,t_record->isobeg_type_meaning ,1 ,t_record->
  isobeg_type_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(356," ,t_record->isobeg_type_meaning ,",1," ,t_record
   ->isobeg_type_cd ,")" ) )
 IF ((((stat != 0 ) ) OR ((t_record->isobeg_type_cd <= 0 ) )) )
  SET t_record->isobeg_type_cd = 0
 ENDIF
 SET t_record->isoend_type_cd = 0.0
 SET t_record->isoend_type_meaning = fillstring (12 ," " )
 SET t_record->isoend_type_meaning = "ISOEND"
 SET stat = uar_get_meaning_by_codeset (356 ,t_record->isoend_type_meaning ,1 ,t_record->
  isoend_type_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(356," ,t_record->isoend_type_meaning ,",1," ,t_record
   ->isoend_type_cd ,")" ) )
 IF ((((stat != 0 ) ) OR ((t_record->isoend_type_cd <= 0 ) )) )
  SET t_record->isoend_type_cd = 0
 ENDIF
 SET t_record->isolation_type_cd = 0.0
 SET t_record->isolation_type_meaning = fillstring (12 ," " )
 SET t_record->isolation_type_meaning = "ISOLATION"
 SET stat = uar_get_meaning_by_codeset (356 ,t_record->isolation_type_meaning ,1 ,t_record->
  isolation_type_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(356," ,t_record->isolation_type_meaning ,",1," ,
   t_record->isolation_type_cd ,")" ) )
 IF ((((stat != 0 ) ) OR ((t_record->isolation_type_cd <= 0 ) )) )
  SET t_record->isolation_type_cd = 0
 ENDIF
 SET t_record->userdefined_type_cd = 0.0
 SET t_record->userdefined_type_meaning = fillstring (12 ," " )
 SET t_record->userdefined_type_meaning = "USERDEFINED"
 SET stat = uar_get_meaning_by_codeset (355 ,t_record->userdefined_type_meaning ,1 ,t_record->
  userdefined_type_cd )
 CALL echo (build ("UAR_GET_MEANING_BY_CODESET(355," ,t_record->userdefined_type_meaning ,",1," ,
   t_record->userdefined_type_cd ,")" ) )
 IF ((((stat != 0 ) ) OR ((t_record->userdefined_type_cd <= 0 ) )) )
  SET t_record->userdefined_type_cd = 0
 ENDIF
 IF ((t_record->isobeg_type_cd > 0 )
 AND (t_record->isoend_type_cd > 0 )
 AND (t_record->isolation_type_cd > 0 ) )
  SELECT INTO "nl:"
   a.updt_cnt
   FROM (dummyt d WITH seq = value (reply->query_qual_cnt ) ),
    (person_info a ),
    (code_value_extension c )
   PLAN (d
    WHERE (reply->query_qual[d.seq ].hide#personid > 0 ) )
    JOIN (a
    WHERE (a.person_id = reply->query_qual[d.seq ].hide#personid )
    AND (a.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (a.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
    AND (a.info_type_cd = t_record->userdefined_type_cd )
    AND (a.info_sub_type_cd IN (t_record->isobeg_type_cd ,
    t_record->isoend_type_cd ,
    t_record->isolation_type_cd ) )
    AND (a.active_ind = 1 ) )
    JOIN (c
    WHERE (c.code_value = a.info_sub_type_cd )
    AND (c.field_name = "TYPE" )
    AND (c.code_set = 356 ) )
   HEAD d.seq
    t_record->temp_beg_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ,t_record->temp_end_dt_tm =
    cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ,t_record->temp_isolation_cd = 0
   DETAIL
    IF ((a.info_sub_type_cd = t_record->isobeg_type_cd )
    AND (c.field_value = "DATE" )
    AND (cnvtdatetime (a.value_dt_tm ) > 0 ) ) t_record->temp_beg_dt_tm = cnvtdatetime (a
      .value_dt_tm )
    ENDIF
    ,
    IF ((a.info_sub_type_cd = t_record->isoend_type_cd )
    AND (c.field_value = "DATE" )
    AND (cnvtdatetime (a.value_dt_tm ) > 0 ) ) t_record->temp_end_dt_tm = cnvtdatetime (a
      .value_dt_tm )
    ENDIF
    ,
    IF ((a.info_sub_type_cd = t_record->isolation_type_cd )
    AND (c.field_value = "CODE" ) ) t_record->temp_isolation_cd = a.value_cd
    ENDIF
   FOOT  d.seq
    IF ((t_record->temp_isolation_cd > 0 )
    AND (reply->query_qual[d.seq ].hide#earliestdttm >= t_record->temp_beg_dt_tm )
    AND (reply->query_qual[d.seq ].hide#earliestdttm <= t_record->temp_end_dt_tm ) ) reply->
     query_qual[d.seq ].isolation_type = "Yes"
    ENDIF
   WITH nocounter ,orahint ("INDEX(A XIE1PERSON_INFO) INDEX(C XPKCODE_VALUE_EXTENSION)" )
  ;end select
 ENDIF
#exit_script
 IF ((failed = false ) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  IF ((failed != true ) )
   CASE (failed )
    OF select_error :
     SET reply->status_data.subeventstatus[1 ].operationname = "SELECT"
    ELSE
     SET reply->status_data.subeventstatus[1 ].operationname = "UNKNOWN"
   ENDCASE
   SET reply->status_data.subeventstatus[1 ].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = table_name
  ENDIF
 ENDIF
 FREE SET t_record
END GO
 

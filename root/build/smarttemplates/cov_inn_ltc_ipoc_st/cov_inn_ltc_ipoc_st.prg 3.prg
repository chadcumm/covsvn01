DROP PROGRAM cov_inn_ltc_ipoc_st :dba GO
CREATE PROGRAM cov_inn_ltc_ipoc_st :dba
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
 SET titlecaption = uar_i18ngetmessage (i18nhandle ,"Title" ,"Current IPOCs" )
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
    ce.performed_dt_tm DESC ,
    pvr.chart_dt_tm DESC ,
    oa.start_dt_tm DESC ,
    lt.active_status_dt_tm DESC ,
    apc.sequence
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
    IF ((found = 0 ) )
     IF ((ce.result_status_cd IN (auth_cd ,
     altered_cd ,
     modified_cd ) ) ) found = 1 ,access_length = size (trim (ce.accession_nbr ,3 ) ) ,access_use =
      cnvtreal (substring (3 ,access_length ,trim (ce.accession_nbr ,3 ) ) ) ,
      IF ((((access_use = oa.outcome_activity_id ) ) OR ((size (ce.accession_nbr ) > 0 )
      AND (((oa.outcome_type_cd != goaldp ) ) OR ((oa.outcome_type_cd != interventndp ) )) )) )
       ipoc_list->ipoc[pos ].outcomes[cnt ].performed_by = trim (p.name_full_formatted ) ,ipoc_list->
       ipoc[pos ].outcomes[cnt ].performed_dt_tm = format (ce.event_end_dt_tm ,"MM/DD/YYYY;;D" ) ,
       ipoc_list->ipoc[pos ].outcomes[cnt ].action_text_id = pvr.action_text_id ,ipoc_list->ipoc[pos
       ].outcomes[cnt ].reason_text_id = pvr.reason_text_id ,ipoc_list->ipoc[pos ].outcomes[cnt ].
       outcome_result = ce.result_val ,ipoc_list->ipoc[pos ].outcomes[cnt ].outcome_note = lt
       .long_text ,ipoc_list->ipoc[pos ].outcomes[cnt ].parent_entity_id = apc.parent_entity_id ,
       ipoc_list->ipoc[pos ].outcomes[cnt ].action_result = uar_get_code_display (pvr.action_cd ) ,
       ipoc_list->ipoc[pos ].outcomes[cnt ].reason_result = uar_get_code_display (pvr.reason_cd )
      ENDIF
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

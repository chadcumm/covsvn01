DROP PROGRAM cov_bbt_ops_batch_release :dba GO
CREATE PROGRAM cov_bbt_ops_batch_release :dba
 RECORD ops_request (
   1 productlist [1 ]
     2 product_id = f8
     2 product_type = c1
     2 p_updt_cnt = i4
     2 der_updt_cnt = i4
     2 supp_prefix = c5
     2 productevent [* ]
       3 product_event_id = f8
       3 event_type_cd = f8
       3 pe_updt_cnt = i4
       3 updt_cnt = i4
       3 order_id = f8
       3 person_id = f8
       3 release_reason_cd = f8
       3 release_qty = i4
       3 release_iu = i4
       3 xm_exp_dt_tm = dq8
       3 pat_aborh = vc
     2 status = c1
     2 err_message = c40
 )
 RECORD reply (
   1 rpt_list [* ]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE temp_string = vc
 DECLARE mode_selection = vc
 DECLARE batch_field = vc
 DECLARE rpt_mode = vc
 DECLARE sort_selection = vc
 DECLARE sort_field = vc
 DECLARE nbr_to_update = i4 WITH noconstant (0 )
 DECLARE count1 = i4 WITH noconstant (0 )
 DECLARE failed = c1 WITH noconstant ("F" )
 DECLARE active_quar = c1 WITH noconstant ("F" )
 DECLARE active_assign = c1 WITH noconstant ("F" )
 DECLARE active_uncfrm = c1 WITH noconstant ("F" )
 DECLARE active_xm = c1 WITH noconstant ("F" )
 DECLARE active_shipped = c1 WITH noconstant ("F" )
 DECLARE active_intransit = c1 WITH noconstant ("F" )
 DECLARE multiple_xm = c1 WITH noconstant ("F" )
 DECLARE error_process = c40 WITH noconstant (fillstring (40 ," " ) )
 DECLARE error_message = c40 WITH noconstant (fillstring (40 ," " ) )
 DECLARE success_cnt = i4 WITH noconstant (0 )
 DECLARE failure_occured = c1 WITH noconstant ("F" )
 DECLARE quantity_val = i4 WITH noconstant (0 )
 DECLARE product_event_id = f8 WITH noconstant (0.0 )
 DECLARE gsub_product_event_status = c1 WITH noconstant (" " )
 DECLARE assign_release_id_val = f8 WITH noconstant (0.0 )
 DECLARE mrn_code = f8 WITH noconstant (0.0 )
 DECLARE code_cnt = i4 WITH noconstant (0 )
 DECLARE count2 = i4 WITH noconstant (0 )
 DECLARE nbr_of_events = i4 WITH noconstant (0 )
 DECLARE index = i4 WITH noconstant (0 )
 DECLARE pe_index = i4 WITH noconstant (0 )
 DECLARE temp_prod_event_id = f8 WITH noconstant (0.0 )
 DECLARE temp_updt_cnt = i4 WITH noconstant (0 )
 DECLARE temp_pe_updt_cnt = i4 WITH noconstant (0 )
 DECLARE pos = i4 WITH noconstant (0 )
 DECLARE pos1 = i4 WITH noconstant (0 )
 DECLARE quantity_iu = i4 WITH noconstant (0 )
 DECLARE ops_param_status = i4 WITH noconstant (- (1 ) )
 DECLARE total_xm_events = i4 WITH noconstant (0 )
 DECLARE qual_xm_events = i4 WITH noconstant (0 )
 DECLARE multiple_inprog = c1 WITH noconstant ("F" )
 DECLARE total_inprog_events = i4 WITH noconstant (0 )
 DECLARE qual_inprog_events = i4 WITH noconstant (0 )
 DECLARE valid_prod_ind = c1 WITH noconstant ("F" )
 DECLARE der_release_qty = i4 WITH noconstant (0 )
 DECLARE der_release_iu = i4 WITH noconstant (0 )
 DECLARE xm_expired_reason_cd = f8 WITH noconstant (0.0 )
 DECLARE pat_expired_reason_cd = f8 WITH noconstant (0.0 )
 DECLARE enc_discharged_reason_cd = f8 WITH noconstant (0.0 )
 DECLARE quar_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE assign_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE xmtch_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE dispense_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE avail_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE uncfrm_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE inprogress_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE autologous_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE directed_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE shipped_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE intransit_event_type_cd = f8 WITH noconstant (0.0 )
 DECLARE mrn_meaning = c12 WITH protected ,constant ("MRN" )
 DECLARE xm_exp_meaning = c12 WITH protected ,constant ("EXPIRED" )
 DECLARE pat_exp_meaning = c12 WITH protected ,constant ("PAT_DECEASED" )
 DECLARE enc_discharg_meaning = c12 WITH protected ,constant ("SYS_DISCHRG" )
 DECLARE assign_meaning = c12 WITH protected ,constant ("1" )
 DECLARE quar_meaning = c12 WITH protected ,constant ("2" )
 DECLARE xm_meaning = c12 WITH protected ,constant ("3" )
 DECLARE dispense_meaning = c12 WITH protected ,constant ("4" )
 DECLARE available_meaning = c12 WITH protected ,constant ("12" )
 DECLARE uncfrm_meaning = c12 WITH protected ,constant ("9" )
 DECLARE inprog_meaning = c12 WITH protected ,constant ("16" )
 DECLARE auto_meaning = c12 WITH protected ,constant ("10" )
 DECLARE dir_meaning = c12 WITH protected ,constant ("11" )
 DECLARE ship_meaning = c12 WITH protected ,constant ("15" )
 DECLARE intransit_meaning = c12 WITH protected ,constant ("25" )
 DECLARE i18nhandle = i4 WITH noconstant (0 )
 DECLARE h = i4 WITH noconstant (0 )
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 RECORD captions (
   1 rpt_batch_crossmatch = vc
   1 as_of_time = vc
   1 as_of_date = vc
   1 blood_bank_owner = vc
   1 inventory_area = vc
   1 prepared = vc
   1 unit_number = vc
   1 medical_number = vc
   1 patient_name = vc
   1 accession_number = vc
   1 product = vc
   1 status = vc
   1 xm_exp_date = vc
   1 report_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
   1 rpt_no_crossmatches = vc
   1 update_and_report = vc
   1 report_only = vc
   1 reason = vc
   1 aborh = vc
 )
 SET captions->rpt_batch_crossmatch = uar_i18ngetmessage (i18nhandle ,"rpt_batch_crossmatch" ,
  "B A T C H    C R O S S M A T C H   R E L E A S E   R E P O R T" )
 SET captions->as_of_time = uar_i18ngetmessage (i18nhandle ,"as_of_time" ,"As of Time:" )
 SET captions->as_of_date = uar_i18ngetmessage (i18nhandle ,"as_of_date" ,"As of Date:" )
 SET captions->blood_bank_owner = uar_i18ngetmessage (i18nhandle ,"blood_bank_owner" ,
  "Blood Bank Owner: " )
 SET captions->inventory_area = uar_i18ngetmessage (i18nhandle ,"inventory_area" ,"Inventory Area: "
  )
 SET captions->prepared = uar_i18ngetmessage (i18nhandle ,"prepared" ,"Prepared:" )
 SET captions->unit_number = uar_i18ngetmessage (i18nhandle ,"unit_number" ,"UNIT NUMBER" )
 SET captions->medical_number = uar_i18ngetmessage (i18nhandle ,"medical_number" ,"MEDICAL NUMBER" )
 SET captions->patient_name = uar_i18ngetmessage (i18nhandle ,"patient_name" ,"PATIENT NAME" )
 SET captions->accession_number = uar_i18ngetmessage (i18nhandle ,"accession_number" ,
  "ACCESSION NUMBER" )
 SET captions->product = uar_i18ngetmessage (i18nhandle ,"product" ,"PRODUCT" )
 SET captions->status = uar_i18ngetmessage (i18nhandle ,"status" ,"STATUS" )
 SET captions->xm_exp_date = uar_i18ngetmessage (i18nhandle ,"xm_exp_date" ,"XM EXP DATE" )
 SET captions->report_id = uar_i18ngetmessage (i18nhandle ,"report_id" ,
  "Report ID: BBT_OPS_BATCH_RELEASE" )
 SET captions->rpt_page = uar_i18ngetmessage (i18nhandle ,"rpt_page" ,"Page:" )
 SET captions->printed = uar_i18ngetmessage (i18nhandle ,"printed" ,"Printed:" )
 SET captions->end_of_report = uar_i18ngetmessage (i18nhandle ,"end_of_report" ,
  "* * * End of Report * * *" )
 SET captions->rpt_no_crossmatches = uar_i18ngetmessage (i18nhandle ,"rpt_no_crossmatches" ,
  " * * * No crossmatches to release at this time * * *" )
 SET captions->update_and_report = uar_i18ngetmessage (i18nhandle ,"update_and_report" ,
  "UPDATE AND REPORT" )
 SET captions->report_only = uar_i18ngetmessage (i18nhandle ,"report_only" ,"REPORT ONLY" )
 SET captions->reason = uar_i18ngetmessage (i18nhandle ,"reason" ,"REASON" )
 SET captions->aborh = uar_i18ngetmessage (i18nhandle ,"ABORH" ,"ABO RH" )
 IF ((trim (request->batch_selection ) > " " ) )
  SET temp_string = cnvtupper (trim (request->batch_selection ) )
  SET mode_selection = fillstring (6 ," " )
  CALL check_mode_opt ("bbt_ops_batch_release" )
  IF ((mode_selection = "UPDATE" ) )
   SET batch_field = mode_selection
   SET rpt_mode = captions->update_and_report
  ELSEIF ((mode_selection = "REPORT" ) )
   SET batch_field = mode_selection
   SET rpt_mode = captions->report_only
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "bbt_ops_batch_release"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "no mode selection"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
   "no correct mode selection in string"
   GO TO exit_script
  ENDIF
  SET sort_selection = fillstring (20 ," " )
  CALL check_sort_opt ("bbt_ops_batch_release" )
  IF ((sort_selection = "NAME" ) )
   SET sort_field = sort_selection
  ELSEIF ((sort_selection = "MRN" ) )
   SET sort_field = sort_selection
  ELSE
   SET sort_field = "NAME"
  ENDIF
  CALL check_location_cd ("bbt_ops_batch_release" )
  CALL check_misc_functionality ("PATENCSTATUS" )
 ELSE
  SET batch_field = "REPORT"
  SET rpt_mode = captions->report_only
  SET sort_field = "NAME"
  SET request->address_location_cd = 0.0
 ENDIF
 DECLARE check_facility_cd ((script_name = vc ) ) = null
 DECLARE check_exception_type_cd ((script_name = vc ) ) = null
 SUBROUTINE  check_opt_date_passed (script_name )
  SET ddmmyy_flag = 0
  SET dd_flag = 0
  SET mm_flag = 0
  SET yy_flag = 0
  SET dayentered = 0
  SET monthentered = 0
  SET yearentered = 0
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("DAY[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET day_string = substring ((temp_pos + 4 ) ,size (temp_string ) ,temp_string )
   SET day_pos = cnvtint (value (findstring ("]" ,day_string ) ) )
   IF ((day_pos > 0 ) )
    SET day_nbr = substring (1 ,(day_pos - 1 ) ,day_string )
    IF ((trim (day_nbr ) > " " ) )
     SET ddmmyy_flag = (ddmmyy_flag + 1 )
     SET dd_flag = 1
     SET dayentered = cnvtreal (day_nbr )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse DAY value"
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse DAY value"
   ENDIF
  ENDIF
  IF ((reply->status_data.status != "F" ) )
   SET temp_pos = 0
   SET temp_pos = cnvtint (value (findstring ("MONTH[" ,temp_string ) ) )
   IF ((temp_pos > 0 ) )
    SET month_string = substring ((temp_pos + 6 ) ,size (temp_string ) ,temp_string )
    SET month_pos = cnvtint (value (findstring ("]" ,month_string ) ) )
    IF ((month_pos > 0 ) )
     SET month_nbr = substring (1 ,(month_pos - 1 ) ,month_string )
     IF ((trim (month_nbr ) > " " ) )
      SET ddmmyy_flag = (ddmmyy_flag + 1 )
      SET mm_flag = 1
      SET monthentered = cnvtreal (month_nbr )
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse MONTH value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse MONTH value"
    ENDIF
   ENDIF
  ENDIF
  IF ((reply->status_data.status != "F" ) )
   SET temp_pos = 0
   SET temp_pos = cnvtint (value (findstring ("YEAR[" ,temp_string ) ) )
   IF ((temp_pos > 0 ) )
    SET year_string = substring ((temp_pos + 5 ) ,size (temp_string ) ,temp_string )
    SET year_pos = cnvtint (value (findstring ("]" ,year_string ) ) )
    IF ((year_pos > 0 ) )
     SET year_nbr = substring (1 ,(year_pos - 1 ) ,year_string )
     IF ((trim (year_nbr ) > " " ) )
      SET ddmmyy_flag = (ddmmyy_flag + 1 )
      SET yy_flag = 1
      SET yearentered = cnvtreal (year_nbr )
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse YEAR value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse YEAR value"
    ENDIF
   ENDIF
  ENDIF
  IF ((ddmmyy_flag > 1 ) )
   SET reply->status_data.subeventstatus[1 ].operationname = script_name
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse DAY or MONTH or YEAR value"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "multi date selection"
   GO TO exit_script
  ENDIF
  IF ((reply->status_data.status = "F" ) )
   SET reply->status_data.subeventstatus[1 ].operationname = script_name
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
   GO TO exit_script
  ENDIF
  IF ((dd_flag = 1 ) )
   IF ((dayentered > 0 ) )
    SET interval = build (abs (dayentered ) ,"d" )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,0000 )
    SET begday = cnvtlookahead (interval ,request->ops_date )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,235959 )
    SET endday = cnvtlookahead (interval ,request->ops_date )
   ELSE
    SET interval = build (abs (dayentered ) ,"d" )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,0000 )
    SET begday = cnvtlookbehind (interval ,request->ops_date )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,235959 )
    SET endday = cnvtlookbehind (interval ,request->ops_date )
   ENDIF
  ELSEIF ((mm_flag = 1 ) )
   IF ((monthentered > 0 ) )
    SET interval = build (abs (monthentered ) ,"m" )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,0000 )
    SET smonth = cnvtstring (month (request->ops_date ) )
    SET sday = "01"
    SET syear = cnvtstring (year (request->ops_date ) )
    SET sdateall = concat (smonth ,sday ,syear )
    SET begday = cnvtlookahead (interval ,cnvtdatetime (cnvtdate (sdateall ) ,0 ) )
    SET endday = cnvtlookahead ("1m" ,cnvtdatetime (cnvtdate (begday ) ,235959 ) )
    SET endday = cnvtlookbehind ("1d" ,endday )
   ELSE
    SET interval = build (abs (monthentered ) ,"m" )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,0000 )
    SET smonth = cnvtstring (month (request->ops_date ) )
    SET sday = "01"
    SET syear = cnvtstring (year (request->ops_date ) )
    SET sdateall = concat (smonth ,sday ,syear )
    SET begday = cnvtlookbehind (interval ,cnvtdatetime (cnvtdate (sdateall ) ,0 ) )
    SET endday = cnvtlookahead ("1m" ,cnvtdatetime (cnvtdate (begday ) ,235959 ) )
    SET endday = cnvtlookbehind ("1d" ,endday )
   ENDIF
  ELSEIF ((yy_flag = 1 ) )
   IF ((yearentered > 0 ) )
    SET interval = build (abs (yearentered ) ,"y" )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,0000 )
    SET smonth = "01"
    SET sday = "01"
    SET syear = cnvtstring (year (request->ops_date ) )
    SET sdateall = concat (smonth ,sday ,syear )
    SET begday = cnvtlookahead (interval ,cnvtdatetime (cnvtdate (sdateall ) ,0 ) )
    SET endday = cnvtlookahead ("1y" ,cnvtdatetime (cnvtdate (begday ) ,235959 ) )
    SET endday = cnvtlookbehind ("1d" ,endday )
   ELSE
    SET interval = build (abs (yearentered ) ,"y" )
    SET request->ops_date = cnvtdatetime (cnvtdate2 (format (request->ops_date ,"mm/dd/yyyy;;d" ) ,
      "mm/dd/yyyy" ) ,0000 )
    SET smonth = "01"
    SET sday = "01"
    SET syear = cnvtstring (year (request->ops_date ) )
    SET sdateall = concat (smonth ,sday ,syear )
    SET begday = cnvtlookbehind (interval ,cnvtdatetime (cnvtdate (sdateall ) ,0 ) )
    SET endday = cnvtlookahead ("1y" ,cnvtdatetime (cnvtdate (begday ) ,235959 ) )
    SET endday = cnvtlookbehind ("1d" ,endday )
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = script_name
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse DAY or MONTH or YEAR value"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "NO date selection"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_bb_organization (script_name )
  DECLARE norgpos = i2 WITH protect ,noconstant (0 )
  DECLARE ntemppos = i2 WITH protect ,noconstant (0 )
  DECLARE ncodeset = i4 WITH protect ,constant (278 )
  DECLARE sorgname = vc WITH protect ,noconstant (fillstring (132 ,"" ) )
  DECLARE sorgstring = vc WITH protect ,noconstant (fillstring (132 ,"" ) )
  DECLARE dbbmanufcd = f8 WITH protect ,noconstant (0.0 )
  DECLARE dbbsupplcd = f8 WITH protect ,noconstant (0.0 )
  DECLARE dbbclientcd = f8 WITH protect ,noconstant (0.0 )
  SET stat = uar_get_meaning_by_codeset (ncodeset ,"BBMANUF" ,1 ,dbbmanufcd )
  SET stat = uar_get_meaning_by_codeset (ncodeset ,"BBSUPPL" ,1 ,dbbsupplcd )
  SET stat = uar_get_meaning_by_codeset (ncodeset ,"BBCLIENT" ,1 ,dbbclientcd )
  SET ntemppos = cnvtint (value (findstring ("ORG[" ,temp_string ) ) )
  IF ((ntemppos > 0 ) )
   SET sorgstring = substring ((ntemppos + 4 ) ,size (temp_string ) ,temp_string )
   SET norgpos = cnvtint (value (findstring ("]" ,sorgstring ) ) )
   IF ((norgpos > 0 ) )
    SET sorgname = substring (1 ,(norgpos - 1 ) ,sorgstring )
    IF ((trim (sorgname ) > " " ) )
     SELECT INTO "nl:"
      FROM (org_type_reltn ot ),
       (organization o )
      PLAN (ot
       WHERE (ot.org_type_cd IN (dbbmanufcd ,
       dbbsupplcd ,
       dbbclientcd ) )
       AND (ot.active_ind = 1 ) )
       JOIN (o
       WHERE (o.org_name_key = trim (cnvtupper (sorgname ) ) )
       AND (o.active_ind = 1 ) )
      DETAIL
       request->organization_id = o.organization_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ELSE
   SET request->organization_id = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_owner_cd (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("OWN[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET own_string = substring ((temp_pos + 4 ) ,size (temp_string ) ,temp_string )
   SET own_pos = cnvtint (value (findstring ("]" ,own_string ) ) )
   IF ((own_pos > 0 ) )
    SET own_area = substring (1 ,(own_pos - 1 ) ,own_string )
    IF ((trim (own_area ) > " " ) )
     SET request->cur_owner_area_cd = cnvtreal (own_area )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse owner area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse owner area code value"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->cur_owner_area_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_inventory_cd (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("INV[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET inv_string = substring ((temp_pos + 4 ) ,size (temp_string ) ,temp_string )
   SET inv_pos = cnvtint (value (findstring ("]" ,inv_string ) ) )
   IF ((inv_pos > 0 ) )
    SET inv_area = substring (1 ,(inv_pos - 1 ) ,inv_string )
    IF ((trim (inv_area ) > " " ) )
     SET request->cur_inv_area_cd = cnvtreal (inv_area )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse inventory area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse inventory area code value"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->cur_inv_area_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_location_cd (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("LOC[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET loc_string = substring ((temp_pos + 4 ) ,size (temp_string ) ,temp_string )
   SET loc_pos = cnvtint (value (findstring ("]" ,loc_string ) ) )
   IF ((loc_pos > 0 ) )
    SET location_cd = substring (1 ,(loc_pos - 1 ) ,loc_string )
    IF ((trim (location_cd ) > " " ) )
     SET request->address_location_cd = cnvtreal (location_cd )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse location code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse location code value"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->address_location_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_sort_opt (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("SORT[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET sort_string = substring ((temp_pos + 5 ) ,size (temp_string ) ,temp_string )
   SET sort_pos = cnvtint (value (findstring ("]" ,sort_string ) ) )
   IF ((sort_pos > 0 ) )
    SET sort_selection = substring (1 ,(sort_pos - 1 ) ,sort_string )
   ELSE
    SET sort_selection = " "
   ENDIF
  ELSE
   SET sort_selection = " "
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_mode_opt (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("MODE[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET mode_string = substring ((temp_pos + 5 ) ,size (temp_string ) ,temp_string )
   SET mode_pos = cnvtint (value (findstring ("]" ,mode_string ) ) )
   IF ((mode_pos > 0 ) )
    SET mode_selection = substring (1 ,(mode_pos - 1 ) ,mode_string )
   ELSE
    SET mode_selection = " "
   ENDIF
  ELSE
   SET mode_selection = " "
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_rangeofdays_opt (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("RANGEOFDAYS[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET next_string = substring ((temp_pos + 12 ) ,size (temp_string ) ,temp_string )
   SET next_pos = cnvtint (value (findstring ("]" ,next_string ) ) )
   SET days_look_ahead = cnvtint (trim (substring (1 ,(next_pos - 1 ) ,next_string ) ) )
   IF ((days_look_ahead > 0 ) )
    SET days_look_ahead = days_look_ahead
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse look ahead days"
    GO TO exit_script
   ENDIF
  ELSE
   SET days_look_ahead = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_hrs_opt (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("HRS[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET hrs_string = substring ((temp_pos + 4 ) ,size (temp_string ) ,temp_string )
   SET hrs_pos = cnvtint (value (findstring ("]" ,hrs_string ) ) )
   IF ((hrs_pos > 0 ) )
    SET num_hrs = substring (1 ,(hrs_pos - 1 ) ,hrs_string )
    IF ((trim (num_hrs ) > " " ) )
     IF ((cnvtint (trim (num_hrs ) ) > 0 ) )
      SET hoursentered = cnvtreal (num_hrs )
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1 ].operationname = script_name
      SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
      SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse number of hours"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse number of hours"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse number of hours"
    GO TO exit_script
   ENDIF
  ELSE
   SET hoursentered = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_svc_opt (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("SVC[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET svc_string = substring ((temp_pos + 4 ) ,size (temp_string ) ,temp_string )
   SET svc_pos = cnvtint (value (findstring ("]" ,svc_string ) ) )
   SET parm_string = fillstring (100 ," " )
   SET parm_string = substring (1 ,(svc_pos - 1 ) ,svc_string )
   SET ptr = 1
   SET back_ptr = 1
   SET param_idx = 1
   SET nbr_of_services = size (trim (parm_string ) )
   SET flag_exit_loop = 0
   FOR (param_idx = 1 TO nbr_of_services )
    SET ptr = findstring ("," ,parm_string ,back_ptr )
    IF ((ptr = 0 ) )
     SET ptr = (nbr_of_services + 1 )
     SET flag_exit_loop = 1
    ENDIF
    SET parm_len = (ptr - back_ptr )
    SET stat = alterlist (ops_params->qual ,param_idx )
    SET ops_params->qual[param_idx ].param = trim (substring (back_ptr ,value (parm_len ) ,
      parm_string ) ,3 )
    SET back_ptr = (ptr + 1 )
    SET stat = alterlist (request->qual ,param_idx )
    SET request->qual[param_idx ].service_resource_cd = cnvtreal (ops_params->qual[param_idx ].param
     )
    IF ((flag_exit_loop = 1 ) )
     SET param_idx = nbr_of_services
    ENDIF
   ENDFOR
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = script_name
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse service resource"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_donation_location (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("DLOC[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET loc_string = substring ((temp_pos + 5 ) ,size (temp_string ) ,temp_string )
   SET loc_pos = cnvtint (value (findstring ("]" ,loc_string ) ) )
   IF ((loc_pos > 0 ) )
    SET location_cd = substring (1 ,(loc_pos - 1 ) ,loc_string )
    IF ((trim (location_cd ) > " " ) )
     SET request->donation_location_cd = cnvtreal (trim (location_cd ) )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse donation location"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse donation location"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->donation_location_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_null_report (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("NULLRPT[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET null_string = substring ((temp_pos + 8 ) ,size (temp_string ) ,temp_string )
   SET null_pos = cnvtint (value (findstring ("]" ,null_string ) ) )
   IF ((null_pos > 0 ) )
    SET null_selection = substring (1 ,(null_pos - 1 ) ,null_string )
    IF ((trim (null_selection ) = "Y" ) )
     SET request->null_ind = 1
    ELSE
     SET request->null_ind = 0
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse null report indicator"
    GO TO exit_script
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_outcome_cd (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("OUTCOME[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET outcome_string = substring ((temp_pos + 8 ) ,size (temp_string ) ,temp_string )
   SET loc_pos = cnvtint (value (findstring ("]" ,outcome_string ) ) )
   IF ((loc_pos > 0 ) )
    SET outcome_cd = substring (1 ,(loc_pos - 1 ) ,outcome_string )
    IF ((trim (outcome_cd ) > " " ) )
     SET request->outcome_cd = cnvtreal (outcome_cd )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse outcome code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse outcome code value"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->outcome_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_facility_cd (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("FACILITY[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET loc_string = substring ((temp_pos + 9 ) ,size (temp_string ) ,temp_string )
   SET loc_pos = cnvtint (value (findstring ("]" ,loc_string ) ) )
   IF ((loc_pos > 0 ) )
    SET facility_cd = substring (1 ,(loc_pos - 1 ) ,loc_string )
    IF ((trim (facility_cd ) > " " ) )
     SET request->facility_cd = cnvtreal (facility_cd )
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
     "no facility code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse facility code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no facility code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse facility code value"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->facility_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_exception_type_cd (script_name )
  SET temp_pos = 0
  SET temp_pos = cnvtint (value (findstring ("EXCEPT[" ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET loc_string = substring ((temp_pos + 7 ) ,size (temp_string ) ,temp_string )
   SET loc_pos = cnvtint (value (findstring ("]" ,loc_string ) ) )
   IF ((loc_pos > 0 ) )
    SET exception_type_cd = substring (1 ,(loc_pos - 1 ) ,loc_string )
    IF ((trim (exception_type_cd ) > " " ) )
     IF ((trim (exception_type_cd ) = "ALL" ) )
      SET request->exception_type_cd = 0.0
     ELSE
      SET request->exception_type_cd = cnvtreal (exception_type_cd )
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1 ].operationname = script_name
     SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
     SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
     "no exception type code value in string"
     SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse exception type code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1 ].operationname = script_name
    SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
    "no exception type code value in string"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse exception type code value"
    GO TO exit_script
   ENDIF
  ELSE
   SET request->exception_type_cd = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_misc_functionality (param_name )
  SET temp_pos = 0
  SET status_param = ""
  SET temp_str = concat (param_name ,"[" )
  SET temp_pos = cnvtint (value (findstring (temp_str ,temp_string ) ) )
  IF ((temp_pos > 0 ) )
   SET status_string = substring ((temp_pos + textlen (temp_str ) ) ,size (temp_string ) ,
    temp_string )
   SET status_pos = cnvtint (value (findstring ("]" ,status_string ) ) )
   IF ((status_pos > 0 ) )
    SET status_param = substring (1 ,(status_pos - 1 ) ,status_string )
    IF ((trim (status_param ) > " " ) )
     SET ops_param_status = cnvtint (status_param )
    ENDIF
   ENDIF
  ENDIF
  RETURN
 END ;Subroutine
 SET sub_get_location_name = fillstring (25 ," " )
 SET sub_get_location_address1 = fillstring (100 ," " )
 SET sub_get_location_address2 = fillstring (100 ," " )
 SET sub_get_location_address3 = fillstring (100 ," " )
 SET sub_get_location_address4 = fillstring (100 ," " )
 SET sub_get_location_citystatezip = fillstring (100 ," " )
 SET sub_get_location_country = fillstring (100 ," " )
 IF ((request->address_location_cd != 0 ) )
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset (212 ,"BUSINESS" ,code_cnt ,addr_type_cd )
  IF ((addr_type_cd = 0.0 ) )
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr ,
    a.street_addr2 ,
    a.street_addr3 ,
    a.street_addr4 ,
    a.city ,
    a.state ,
    a.zipcode ,
    a.country ,
    l.location_cd
    FROM (address a )
    WHERE (a.active_ind = 1 )
    AND (a.address_type_cd = addr_type_cd )
    AND (a.parent_entity_name = "LOCATION" )
    AND (a.parent_entity_id = request->address_location_cd )
    DETAIL
     sub_get_location_name = uar_get_code_display (request->address_location_cd ) ,
     sub_get_location_address1 = a.street_addr ,
     sub_get_location_address2 = a.street_addr2 ,
     sub_get_location_address3 = a.street_addr3 ,
     sub_get_location_address4 = a.street_addr4 ,
     sub_get_location_citystatezip = concat (trim (a.city ) ,", " ,trim (a.state ) ,"  " ,trim (a
       .zipcode ) ) ,
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF ((curqual = 0 ) )
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 SET nbr_to_update = 0
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET active_quar = "F"
 SET active_assign = "F"
 SET active_uncfrm = "F"
 SET multiple_xm = "F"
 SET active_shipped = "F"
 SET active_intransit = "F"
 SET error_process = "                                      "
 SET error_message = "                                      "
 SET success_cnt = 0
 SET failure_occured = "F"
 SET quantity_val = 0
 SET product_event_id = 0.0
 SET gsub_product_event_status = "  "
 SET assign_release_id_val = 0.0
 SET mrn_code = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (4 ,nullterm (mrn_meaning ) ,code_cnt ,mrn_code )
 IF ((mrn_code = 0.0 ) )
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues"
  SET error_message = "unable to get MRN codevalue"
 ENDIF
 SET xm_expired_reason_cd = 0.0
 SET pat_expired_reason_cd = 0.0
 SET enc_discharged_reason_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1616 ,nullterm (xm_exp_meaning ) ,code_cnt ,
  xm_expired_reason_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1616 ,nullterm (pat_exp_meaning ) ,code_cnt ,
  pat_expired_reason_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1616 ,nullterm (enc_discharg_meaning ) ,code_cnt ,
  enc_discharged_reason_cd )
 SET quar_event_type_cd = 0.0
 SET assign_event_type_cd = 0.0
 SET xmtch_event_type_cd = 0.0
 SET dispense_event_type_cd = 0.0
 SET avail_event_type_cd = 0.0
 SET uncfrm_event_type_cd = 0.0
 SET inprogress_event_type_cd = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET shipped_event_type_cd = 0.0
 SET intransit_event_type_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (quar_meaning ) ,code_cnt ,quar_event_type_cd
  )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (assign_meaning ) ,code_cnt ,
  assign_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (xm_meaning ) ,code_cnt ,xmtch_event_type_cd
  )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (dispense_meaning ) ,code_cnt ,
  dispense_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (available_meaning ) ,code_cnt ,
  avail_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (uncfrm_meaning ) ,code_cnt ,
  uncfrm_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (inprog_meaning ) ,code_cnt ,
  inprogress_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (auto_meaning ) ,code_cnt ,
  autologous_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (dir_meaning ) ,code_cnt ,
  directed_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (ship_meaning ) ,code_cnt ,
  shipped_event_type_cd )
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset (1610 ,nullterm (intransit_meaning ) ,code_cnt ,
  intransit_event_type_cd )
 IF ((((quar_event_type_cd = 0.0 ) ) OR ((((assign_event_type_cd = 0.0 ) ) OR ((((
 xmtch_event_type_cd = 0.0 ) ) OR ((((dispense_event_type_cd = 0.0 ) ) OR ((((avail_event_type_cd =
 0.0 ) ) OR ((((uncfrm_event_type_cd = 0.0 ) ) OR ((((inprogress_event_type_cd = 0.0 ) ) OR ((((
 autologous_event_type_cd = 0.0 ) ) OR ((((directed_event_type_cd = 0.0 ) ) OR ((((
 shipped_event_type_cd = 0.0 ) ) OR ((intransit_event_type_cd = 0.0 ) )) )) )) )) )) )) )) )) )) ))
 )
  SET reply->status_data.status = "F"
  SET error_process = "bbt_ops_batch_release"
  SET error_message = "unable to load product_event ids"
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].operationname = "release"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "code value read failed"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "F"
  GO TO exit_script
 ENDIF
 CALL check_owner_cd ("bbt_ops_batch_transfusion.prg" )
 CALL check_inventory_cd ("bbt_ops_batch_transfusion.prg" )
 SET product_count = 0
 SELECT INTO "nl:"
  xm.product_event_id ,
  pe.product_event_id ,
  pe.person_id ,
  p.product_id ,
  p.locked_ind ,
  b.product_id
  FROM (product p ),
   (blood_product b ),
   (product_event pe ),
   (crossmatch xm )
  PLAN (xm
   WHERE (xm.active_ind = 1 )
   AND (cnvtdatetime (request->ops_date ) >= xm.crossmatch_exp_dt_tm ) )
   JOIN (pe
   WHERE (pe.active_ind = 1 )
   AND (xm.product_event_id = pe.product_event_id ) )
   JOIN (p
   WHERE (pe.product_id = p.product_id )
   AND (((p.locked_ind = 0 ) ) OR ((p.locked_ind = null ) ))
   AND (p.active_ind = 1 )
   AND (p.product_id > 0.0 ) )
   JOIN (b
   WHERE (b.product_id = p.product_id ) )
  ORDER BY xm.product_id ,
   xm.product_event_id
  HEAD REPORT
   count1 = 0
  HEAD xm.product_id
   valid_prod_ind = "F" ,
   IF ((((request->cur_owner_area_cd > 0.0 )
   AND (request->cur_owner_area_cd = p.cur_owner_area_cd ) ) OR ((request->cur_owner_area_cd = 0.0 )
   ))
   AND (((request->cur_inv_area_cd > 0.0 )
   AND (request->cur_inv_area_cd = p.cur_inv_area_cd ) ) OR ((request->cur_inv_area_cd = 0.0 ) )) )
    valid_prod_ind = "T"
   ENDIF
   ,
   IF ((valid_prod_ind = "T" ) ) count1 = (count1 + 1 ) ,count2 = 0 ,product_count = (product_count
    + 1 ) ,stat = alter (ops_request->productlist ,count1 ) ,ops_request->productlist[count1 ].
    product_type = "B" ,ops_request->productlist[count1 ].supp_prefix = b.supplier_prefix ,
    ops_request->productlist[count1 ].product_id = p.product_id ,ops_request->productlist[count1 ].
    p_updt_cnt = p.updt_cnt
   ENDIF
  HEAD xm.product_event_id
   IF ((valid_prod_ind = "T" ) ) count2 = (count2 + 1 ) ,stat = alterlist (ops_request->productlist[
     count1 ].productevent ,count2 ) ,ops_request->productlist[count1 ].productevent[count2 ].
    product_event_id = pe.product_event_id ,ops_request->productlist[count1 ].productevent[count2 ].
    event_type_cd = pe.event_type_cd ,ops_request->productlist[count1 ].productevent[count2 ].
    pe_updt_cnt = pe.updt_cnt ,ops_request->productlist[count1 ].productevent[count2 ].order_id = pe
    .order_id ,ops_request->productlist[count1 ].productevent[count2 ].person_id = pe.person_id ,
    ops_request->productlist[count1 ].productevent[count2 ].release_reason_cd = xm_expired_reason_cd
   ENDIF
  WITH nocounter
 ;end select
 IF ((ops_param_status = 1 ) )
  SELECT INTO "nl:"
   pe.product_event_id ,
   pn.person_id ,
   en.encntr_id ,
   p.product_id ,
   rel_reason = decode (pn.seq ,"Patient Expired" ,en.seq ,"Encounter Discharged" ,"Y" ) ,
   prod_type = decode (b.seq ,"b" ,b1.seq ,"b" ,d.seq ,"d" ,de.seq ,"d" ,"x" )
   FROM (product_event pe ),
    (encounter en ),
    (person pn ),
    (product p ),
    (blood_product b ),
    (blood_product b1 ),
    (derivative d ),
    (derivative de ),
    (dummyt d1 ),
    (dummyt d2 ),
    (dummyt d3 ),
    (dummyt d4 )
   PLAN (pe
    WHERE (pe.event_type_cd IN (xmtch_event_type_cd ,
    assign_event_type_cd ,
    inprogress_event_type_cd ) )
    AND (pe.active_ind = 1 ) )
    JOIN (p
    WHERE (pe.product_id = p.product_id )
    AND (p.active_ind = 1 )
    AND (p.product_id > 0.0 )
    AND (((p.locked_ind = 0 ) ) OR ((p.locked_ind = null ) )) )
    JOIN (((d1
    WHERE (d1.seq = 1 ) )
    JOIN (pn
    WHERE (pe.person_id = pn.person_id )
    AND (pn.person_id > 0.0 )
    AND (pn.deceased_dt_tm != null ) )
    JOIN (d2
    WHERE (d2.seq = 1 ) )
    JOIN (((b
    WHERE (b.product_id = p.product_id ) )
    ) ORJOIN ((d
    WHERE (d.product_id = p.product_id ) )
    )) ) ORJOIN ((d3
    WHERE (d3.seq = 1 ) )
    JOIN (en
    WHERE (pe.encntr_id = en.encntr_id )
    AND (en.encntr_id > 0.0 )
    AND (en.active_ind = 1 )
    AND (en.disch_dt_tm != null )
    AND (en.disch_dt_tm <= cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (d4
    WHERE (d4.seq = 1 ) )
    JOIN (((b1
    WHERE (b1.product_id = p.product_id ) )
    ) ORJOIN ((de
    WHERE (de.product_id = p.product_id ) )
    )) ))
   ORDER BY pe.product_id ,
    pe.product_event_id ,
    rel_reason DESC
   HEAD pe.product_id
    valid_prod_ind = "F" ,
    IF ((((request->cur_owner_area_cd > 0.0 )
    AND (request->cur_owner_area_cd = p.cur_owner_area_cd ) ) OR ((request->cur_owner_area_cd = 0.0
    ) ))
    AND (((request->cur_inv_area_cd > 0.0 )
    AND (request->cur_inv_area_cd = p.cur_inv_area_cd ) ) OR ((request->cur_inv_area_cd = 0.0 ) )) )
     valid_prod_ind = "T"
    ENDIF
    ,
    IF ((valid_prod_ind = "T" ) ) pos = 0 ,pos = locateval (index ,1 ,size (ops_request->productlist
       ,5 ) ,p.product_id ,ops_request->productlist[index ].product_id ) ,
     IF ((pos = 0 ) ) count1 = (count1 + 1 ) ,count2 = 0 ,product_count = (product_count + 1 ) ,stat
      = alter (ops_request->productlist ,count1 ) ,ops_request->productlist[count1 ].product_type =
      IF ((prod_type = "d" ) ) "D"
      ELSE "B"
      ENDIF
      ,ops_request->productlist[count1 ].product_id = p.product_id ,ops_request->productlist[count1 ]
      .p_updt_cnt = p.updt_cnt ,ops_request->productlist[count1 ].der_updt_cnt =
      IF ((prod_type = "d" ) )
       IF ((rel_reason = "Patient Expired" ) ) d.updt_cnt
       ELSE de.updt_cnt
       ENDIF
      ELSE 0
      ENDIF
      ,
      IF ((prod_type = "b" ) ) ops_request->productlist[count1 ].supp_prefix =
       IF ((rel_reason = "Patient Expired" ) ) b.supplier_prefix
       ELSE b1.supplier_prefix
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   HEAD pe.product_event_id
    IF ((valid_prod_ind = "T" ) )
     IF ((pos = 0 ) ) count2 = (count2 + 1 ) ,stat = alterlist (ops_request->productlist[count1 ].
       productevent ,count2 ) ,ops_request->productlist[count1 ].productevent[count2 ].
      product_event_id = pe.product_event_id ,ops_request->productlist[count1 ].productevent[count2 ]
      .event_type_cd = pe.event_type_cd ,ops_request->productlist[count1 ].productevent[count2 ].
      pe_updt_cnt = pe.updt_cnt ,ops_request->productlist[count1 ].productevent[count2 ].order_id =
      pe.order_id ,ops_request->productlist[count1 ].productevent[count2 ].person_id = pe.person_id ,
      ops_request->productlist[count1 ].productevent[count2 ].release_reason_cd =
      IF ((rel_reason = "Patient Expired" ) ) pat_expired_reason_cd
      ELSE enc_discharged_reason_cd
      ENDIF
      ,
      IF ((ops_request->productlist[count1 ].productevent[count2 ].event_type_cd =
      inprogress_event_type_cd ) ) ops_request->productlist[count1 ].status = "S"
      ENDIF
     ELSE pos1 = 0 ,pos1 = locateval (index ,1 ,size (ops_request->productlist[pos ].productevent ,5
        ) ,pe.product_event_id ,ops_request->productlist[pos ].productevent[index ].product_event_id
       ) ,
      IF ((pos1 = 0 ) ) count2 = (size (ops_request->productlist[pos ].productevent ,5 ) + 1 ) ,stat
       = alterlist (ops_request->productlist[pos ].productevent ,count2 ) ,ops_request->productlist[
       pos ].productevent[count2 ].product_event_id = pe.product_event_id ,ops_request->productlist[
       pos ].productevent[count2 ].event_type_cd = pe.event_type_cd ,ops_request->productlist[pos ].
       productevent[count2 ].pe_updt_cnt = pe.updt_cnt ,ops_request->productlist[pos ].productevent[
       count2 ].order_id = pe.order_id ,ops_request->productlist[pos ].productevent[count2 ].
       person_id = pe.person_id ,ops_request->productlist[pos ].productevent[count2 ].
       release_reason_cd =
       IF ((rel_reason = "Patient Expired" ) ) pat_expired_reason_cd
       ELSE enc_discharged_reason_cd
       ENDIF
       ,
       IF ((ops_request->productlist[pos ].productevent[count2 ].event_type_cd =
       inprogress_event_type_cd ) ) ops_request->productlist[pos ].status = "S"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO size (ops_request->productlist ,5 ) )
  SELECT INTO "nl:"
   pe.product_event_id ,
   event = decode (a.seq ,"ASSIGN" ,xm.seq ,"XM" ,"yy" ) ,
   is_dispensed =
   IF ((pe_pd.product_id > 0 ) ) "pd"
   ELSE "xx"
   ENDIF
   FROM (product_event pe ),
    (patient_dispense pe_pd ),
    (crossmatch xm ),
    (assign a ),
    (dummyt d1 )
   PLAN (pe
    WHERE expand (index ,1 ,size (ops_request->productlist[i ].productevent ,5 ) ,pe
     .product_event_id ,ops_request->productlist[i ].productevent[index ].product_event_id ) )
    JOIN (pe_pd
    WHERE (pe_pd.product_id = outerjoin (pe.product_id ) )
    AND (pe_pd.active_ind = outerjoin (1 ) ) )
    JOIN (d1 )
    JOIN (((xm
    WHERE (pe.product_event_id = xm.product_event_id ) )
    ) ORJOIN ((a
    WHERE (pe.product_event_id = a.product_event_id ) )
    ))
   ORDER BY pe.product_event_id
   HEAD pe.product_event_id
    pos = locateval (index ,1 ,size (ops_request->productlist[i ].productevent ,5 ) ,pe
     .product_event_id ,ops_request->productlist[i ].productevent[index ].product_event_id ) ,
    IF ((event = "ASSIGN" ) ) ops_request->productlist[i ].productevent[pos ].updt_cnt = a.updt_cnt
    ELSEIF ((event = "XM" ) ) ops_request->productlist[i ].productevent[pos ].updt_cnt = xm.updt_cnt
    ,ops_request->productlist[i ].productevent[pos ].xm_exp_dt_tm = cnvtdatetime (xm
      .crossmatch_exp_dt_tm )
    ENDIF
    ,
    IF ((ops_request->productlist[i ].product_type = "D" ) )
     IF ((event = "ASSIGN" ) ) ops_request->productlist[i ].productevent[pos ].release_qty = a
      .cur_assign_qty ,ops_request->productlist[i ].productevent[pos ].release_iu = a
      .cur_assign_intl_units
     ENDIF
    ENDIF
    ,
    IF ((ops_request->productlist[i ].product_type = "B" ) )
     IF ((is_dispensed = "pd" ) ) ops_request->productlist[i ].status = "F" ,ops_request->
      productlist[i ].err_message = "Product issued"
     ELSE ops_request->productlist[i ].status = "S"
     ENDIF
    ELSE ops_request->productlist[i ].status = "S"
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 SET stat = alter (ops_request->productlist ,count1 )
 IF ((cnvtupper (batch_field ) = "UPDATE" ) )
  SET nbr_to_update = cnvtint (size (ops_request->productlist ,5 ) )
  SET stat = alter (reply->status_data.subeventstatus ,nbr_to_update )
  SET error_process = "                                      "
  SET error_message = "                                      "
  FOR (prod = 1 TO nbr_to_update )
   IF ((ops_request->productlist[prod ].status = "S" ) )
    UPDATE FROM (product p )
     SET p.locked_ind = 1 ,
      p.updt_cnt = (p.updt_cnt + 1 ) ,
      p.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      p.updt_id = reqinfo->updt_id ,
      p.updt_task = reqinfo->updt_task ,
      p.updt_applctx = reqinfo->updt_applctx
     WHERE (p.product_id = ops_request->productlist[prod ].product_id )
     AND (p.updt_cnt = ops_request->productlist[prod ].p_updt_cnt )
     AND (((p.locked_ind = null ) ) OR ((p.locked_ind = 0 ) ))
     WITH nocounter
    ;end update
    IF ((curqual = 0 ) )
     SET ops_request->productlist[prod ].status = "F"
     SET error_process = "lock product"
     SET error_message = "Unable to lock product"
    ELSE
     SET ops_request->productlist[prod ].p_updt_cnt = (ops_request->productlist[prod ].p_updt_cnt +
     1 )
     COMMIT
    ENDIF
   ELSE
    SET ops_request->productlist[prod ].p_updt_cnt = (ops_request->productlist[prod ].p_updt_cnt + 1
    )
   ENDIF
  ENDFOR
  SET nbr_to_update = cnvtint (size (ops_request->productlist ,5 ) )
  FOR (prod = 1 TO nbr_to_update )
   SET failure_occured = "F"
   SET active_quar = "F"
   SET active_assign = "F"
   SET active_uncfrm = "F"
   SET active_inprogress = "F"
   SET active_autologous = "F"
   SET active_directed = "F"
   SET multiple_xm = "F"
   SET active_xm = "F"
   SET active_avail = "F"
   SET active_shipped = "F"
   SET active_intransit = "F"
   SET index = 0
   SET pos = 0
   SET total_xm_events = 0
   SET qual_xm_events = 0
   SET multiple_inprog = "F"
   SET total_inprog_events = 0
   SET qual_inprog_events = 0
   IF ((ops_request->productlist[prod ].status = "S" ) )
    SELECT INTO "nl:"
     pe.product_event_id
     FROM (product_event pe )
     WHERE (pe.active_ind = 1 )
     AND (pe.product_id = ops_request->productlist[prod ].product_id )
     DETAIL
      IF ((pe.event_type_cd = quar_event_type_cd ) ) active_quar = "T"
      ELSEIF ((pe.event_type_cd = assign_event_type_cd ) ) active_assign = "T"
      ELSEIF ((pe.event_type_cd = uncfrm_event_type_cd ) ) active_uncfrm = "T"
      ELSEIF ((pe.event_type_cd = xmtch_event_type_cd ) ) total_xm_events = (total_xm_events + 1 ) ,
       active_xm = "T" ,pos = locateval (index ,1 ,size (ops_request->productlist[prod ].productevent
          ,5 ) ,pe.product_event_id ,ops_request->productlist[prod ].productevent[index ].
        product_event_id ) ,
       IF ((pos > 0 ) ) qual_xm_events = (qual_xm_events + 1 )
       ENDIF
       ,
       IF ((total_xm_events = qual_xm_events ) ) multiple_xm = "F"
       ELSE multiple_xm = "T"
       ENDIF
      ELSEIF ((pe.event_type_cd = inprogress_event_type_cd ) ) total_inprog_events = (
       total_inprog_events + 1 ) ,pos = locateval (index ,1 ,size (ops_request->productlist[prod ].
         productevent ,5 ) ,pe.product_event_id ,ops_request->productlist[prod ].productevent[index ]
        .product_event_id ) ,
       IF ((pos > 0 ) ) qual_inprog_events = (qual_inprog_events + 1 )
       ENDIF
       ,
       IF ((total_inprog_events = qual_inprog_events ) ) multiple_inprog = "F"
       ELSE multiple_inprog = "T"
       ENDIF
      ELSEIF ((pe.event_type_cd = autologous_event_type_cd ) ) active_autologous = "T"
      ELSEIF ((pe.event_type_cd = directed_event_type_cd ) ) active_directed = "T"
      ELSEIF ((pe.event_type_cd = avail_event_type_cd ) ) active_avail = "T"
      ELSEIF ((pe.event_type_cd = shipped_event_type_cd ) ) active_shipped = "T"
      ELSEIF ((pe.event_type_cd = intransit_event_type_cd ) ) active_intransit = "T"
      ENDIF
     WITH counter
    ;end select
   ENDIF
   SET nbr_of_events = cnvtint (size (ops_request->productlist[prod ].productevent ,5 ) )
   FOR (count1 = 1 TO nbr_of_events )
    SET temp_prod_event_id = ops_request->productlist[prod ].productevent[count1 ].product_event_id
    SET temp_updt_cnt = ops_request->productlist[prod ].productevent[count1 ].updt_cnt
    SET temp_pe_updt_cnt = ops_request->productlist[prod ].productevent[count1 ].pe_updt_cnt
    IF ((ops_request->productlist[prod ].status = "S" ) )
     IF ((failure_occured = "F" )
     AND (ops_request->productlist[prod ].productevent[count1 ].event_type_cd = xmtch_event_type_cd
     ) )
      SELECT INTO "nl:"
       xm.product_id ,
       xm.product_event_id
       FROM (crossmatch xm )
       PLAN (xm
        WHERE (xm.product_event_id = temp_prod_event_id )
        AND (xm.product_id = ops_request->productlist[prod ].product_id )
        AND (xm.updt_cnt = temp_updt_cnt ) )
       WITH nocounter ,forupdate (xm )
      ;end select
      IF ((curqual != 0 ) )
       SELECT INTO "nl:"
        pe.product_id
        FROM (product_event pe )
        PLAN (pe
         WHERE (pe.product_event_id = temp_prod_event_id )
         AND (pe.product_id = ops_request->productlist[prod ].product_id )
         AND (pe.event_type_cd = xmtch_event_type_cd )
         AND (pe.updt_cnt = temp_pe_updt_cnt ) )
        WITH nocounter ,forupdate (pe )
       ;end select
      ENDIF
      IF ((curqual = 0 ) )
       SET error_process = "lock crossmatch/product_event"
       SET error_message = "crossmatch/product_event not locked"
       SET failure_occured = "T"
      ELSE
       UPDATE FROM (crossmatch xm )
        SET xm.release_reason_cd = ops_request->productlist[prod ].productevent[count1 ].
         release_reason_cd ,
         xm.release_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
         xm.release_prsnl_id = reqinfo->updt_id ,
         xm.release_qty = 0 ,
         xm.crossmatch_qty = 0 ,
         xm.updt_cnt = (xm.updt_cnt + 1 ) ,
         xm.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
         xm.updt_task = reqinfo->updt_task ,
         xm.updt_id = reqinfo->updt_id ,
         xm.updt_applctx = reqinfo->updt_applctx ,
         xm.active_ind = 0 ,
         xm.active_status_cd = reqdata->inactive_status_cd ,
         xm.active_status_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
         xm.active_status_prsnl_id = reqinfo->updt_id
        PLAN (xm
         WHERE (xm.product_event_id = temp_prod_event_id )
         AND (xm.product_id = ops_request->productlist[prod ].product_id )
         AND (xm.updt_cnt = temp_updt_cnt ) )
        WITH counter
       ;end update
       IF ((curqual = 0 ) )
        SET error_process = "update crossmatch"
        SET error_message = "crossmatch not updated"
        SET failure_occured = "T"
       ELSE
        UPDATE FROM (product_event pe )
         SET pe.active_ind = 0 ,
          pe.active_status_cd = reqdata->inactive_status_cd ,
          pe.active_status_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
          pe.active_status_prsnl_id = reqinfo->updt_id ,
          pe.updt_cnt = (pe.updt_cnt + 1 ) ,
          pe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
          pe.updt_task = reqinfo->updt_task ,
          pe.updt_id = reqinfo->updt_id ,
          pe.updt_applctx = reqinfo->updt_applctx
         PLAN (pe
          WHERE (pe.product_event_id = temp_prod_event_id )
          AND (pe.product_id = ops_request->productlist[prod ].product_id )
          AND (pe.event_type_cd = xmtch_event_type_cd )
          AND (pe.updt_cnt = temp_pe_updt_cnt ) )
         WITH counter
        ;end update
        IF ((curqual = 0 ) )
         SET error_process = "update event"
         SET error_message = "crossmatch product_event not updated"
         SET failure_occured = "T"
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((failure_occured = "F" )
     AND (ops_request->productlist[prod ].productevent[count1 ].event_type_cd = assign_event_type_cd
     ) )
      SELECT INTO "nl:"
       a.product_id ,
       a.product_event_id
       FROM (assign a )
       PLAN (a
        WHERE (a.product_event_id = temp_prod_event_id )
        AND (a.product_id = ops_request->productlist[prod ].product_id )
        AND (a.updt_cnt = temp_updt_cnt ) )
       DETAIL
        quantity_val = a.cur_assign_qty ,
        quantity_iu = a.cur_assign_intl_units
       WITH nocounter ,forupdate (a )
      ;end select
      IF ((curqual != 0 ) )
       SELECT INTO "nl:"
        pe.product_id
        FROM (product_event pe )
        PLAN (pe
         WHERE (pe.product_event_id = temp_prod_event_id )
         AND (pe.product_id = ops_request->productlist[prod ].product_id )
         AND (pe.event_type_cd = assign_event_type_cd )
         AND (pe.updt_cnt = temp_pe_updt_cnt ) )
        WITH nocounter ,forupdate (pe )
       ;end select
      ENDIF
      IF ((curqual = 0 ) )
       SET error_process = "lock assign/product_event"
       SET error_message = "assign/product_event not locked"
       SET failure_occured = "T"
      ELSE
       UPDATE FROM (assign a )
        SET a.cur_assign_qty =
         IF ((ops_request->productlist[prod ].product_type = "B" ) ) 0
         ELSEIF ((quantity_val <= ops_request->productlist[prod ].productevent[count1 ].release_qty
         ) ) 0
         ELSE (quantity_val - ops_request->productlist[prod ].productevent[count1 ].release_qty )
         ENDIF
         ,a.cur_assign_intl_units =
         IF ((ops_request->productlist[prod ].product_type = "B" ) ) 0
         ELSEIF ((quantity_iu <= ops_request->productlist[prod ].productevent[count1 ].release_iu )
         ) 0
         ELSE (quantity_iu - ops_request->productlist[prod ].productevent[count1 ].release_iu )
         ENDIF
         ,a.updt_cnt = (a.updt_cnt + 1 ) ,
         a.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
         a.updt_task = reqinfo->updt_task ,
         a.updt_id = reqinfo->updt_id ,
         a.updt_applctx = reqinfo->updt_applctx ,
         a.active_ind =
         IF ((ops_request->productlist[prod ].product_type = "B" ) ) 0
         ELSEIF ((quantity_val = ops_request->productlist[prod ].productevent[count1 ].release_qty )
         ) 0
         ELSE 1
         ENDIF
         ,a.active_status_cd =
         IF ((ops_request->productlist[prod ].product_type = "B" ) ) reqdata->inactive_status_cd
         ELSEIF ((quantity_val = ops_request->productlist[prod ].productevent[count1 ].release_qty )
         ) reqdata->inactive_status_cd
         ELSE reqdata->active_status_cd
         ENDIF
         ,a.active_status_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
         a.active_status_prsnl_id = reqinfo->updt_id
        PLAN (a
         WHERE (a.product_event_id = temp_prod_event_id )
         AND (a.product_id = ops_request->productlist[prod ].product_id )
         AND (a.updt_cnt = temp_updt_cnt ) )
        WITH counter
       ;end update
       IF ((curqual = 0 ) )
        SET error_process = "update assign"
        SET error_message = "assign not updated"
        SET failure_occured = "T"
       ELSE
        SELECT INTO "nl:"
         seqn = seq (pathnet_seq ,nextval )
         FROM (dual )
         DETAIL
          assign_release_id_val = seqn
         WITH format ,nocounter
        ;end select
        IF ((curqual = 0 ) )
         SET error_process = "insert assign_release_id"
         SET error_message = "assign_release_id not generated"
         SET failure_occured = "T"
        ELSE
         INSERT FROM (assign_release ar )
          SET ar.assign_release_id = assign_release_id_val ,
           ar.product_id = ops_request->productlist[prod ].product_id ,
           ar.product_event_id = temp_prod_event_id ,
           ar.release_reason_cd = ops_request->productlist[prod ].productevent[count1 ].
           release_reason_cd ,
           ar.release_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
           ar.release_prsnl_id = reqinfo->updt_id ,
           ar.release_qty =
           IF ((ops_request->productlist[prod ].product_type = "B" ) ) 0
           ELSE ops_request->productlist[prod ].productevent[count1 ].release_qty
           ENDIF
           ,ar.release_intl_units =
           IF ((ops_request->productlist[prod ].product_type = "B" ) ) 0
           ELSE ops_request->productlist[prod ].productevent[count1 ].release_iu
           ENDIF
           ,ar.updt_cnt = 0 ,
           ar.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
           ar.updt_task = reqinfo->updt_task ,
           ar.updt_id = reqinfo->updt_id ,
           ar.updt_applctx = reqinfo->updt_applctx ,
           ar.active_ind = 1 ,
           ar.active_status_cd = reqdata->active_status_cd ,
           ar.active_status_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
           ar.active_status_prsnl_id = reqinfo->updt_id
          WITH nocounter
         ;end insert
         IF ((curqual = 0 ) )
          SET error_process = "insert assign_release row"
          SET error_message = "assign_release row not updated"
          SET failure_occured = "T"
         ELSE
          UPDATE FROM (product_event pe )
           SET pe.active_ind =
            IF ((ops_request->productlist[prod ].product_type = "B" ) ) 0
            ELSEIF ((quantity_val = ops_request->productlist[prod ].productevent[count1 ].release_qty
             ) ) 0
            ELSE 1
            ENDIF
            ,pe.active_status_cd =
            IF ((ops_request->productlist[prod ].product_type = "B" ) ) reqdata->inactive_status_cd
            ELSEIF ((quantity_val = ops_request->productlist[prod ].productevent[count1 ].release_qty
             ) ) reqdata->inactive_status_cd
            ELSE reqdata->active_status_cd
            ENDIF
            ,pe.active_status_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
            pe.active_status_prsnl_id = reqinfo->updt_id ,
            pe.updt_cnt = (pe.updt_cnt + 1 ) ,
            pe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
            pe.updt_task = reqinfo->updt_task ,
            pe.updt_id = reqinfo->updt_id ,
            pe.updt_applctx = reqinfo->updt_applctx
           PLAN (pe
            WHERE (pe.product_event_id = temp_prod_event_id )
            AND (pe.product_id = ops_request->productlist[prod ].product_id )
            AND (pe.event_type_cd = assign_event_type_cd )
            AND (pe.updt_cnt = temp_pe_updt_cnt ) )
           WITH counter
          ;end update
          IF ((curqual = 0 ) )
           SET error_process = "update event"
           SET error_message = "assign product_event not updated"
           SET failure_occured = "T"
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((failure_occured = "F" )
     AND (ops_request->productlist[prod ].productevent[count1 ].event_type_cd =
     inprogress_event_type_cd ) )
      CALL chg_product_event (temp_prod_event_id ,cnvtdatetime (curdate ,curtime3 ) ,reqinfo->updt_id
        ,0 ,0 ,reqdata->inactive_status_cd ,cnvtdatetime (curdate ,curtime3 ) ,reqinfo->updt_id ,
       temp_pe_updt_cnt ,1 ,0 )
      IF ((curqual = 0 ) )
       SET error_process = "update event"
       SET error_message = "in progress product_event not updated"
       SET failure_occured = "T"
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   IF ((failure_occured = "F" )
   AND (((active_quar = "F" )
   AND (((active_assign = "F" ) ) OR ((active_assign = "T" )
   AND (active_xm = "F" ) ))
   AND (active_uncfrm = "F" )
   AND (multiple_xm = "F" )
   AND (multiple_inprog = "F" )
   AND (active_autologous = "F" )
   AND (active_directed = "F" )
   AND (active_shipped = "F" )
   AND (active_intransit = "F" )
   AND (ops_request->productlist[prod ].product_type = "B" ) ) OR ((ops_request->productlist[prod ].
   product_type = "D" ) ))
   AND (active_avail = "F" )
   AND (ops_request->productlist[prod ].status = "S" ) )
    CALL add_product_event (ops_request->productlist[prod ].product_id ,0 ,0 ,0 ,0 ,
     avail_event_type_cd ,cnvtdatetime (curdate ,curtime3 ) ,reqinfo->updt_id ,0 ,0 ,0 ,0 ,1 ,reqdata
     ->active_status_cd ,cnvtdatetime (curdate ,curtime3 ) ,reqinfo->updt_id )
    IF ((curqual = 0 ) )
     SET error_process = "add product_event"
     SET error_message = "available event not added"
     SET failure_occured = "T"
    ENDIF
   ENDIF
   IF ((failure_occured = "F" )
   AND (ops_request->productlist[prod ].product_type = "D" ) )
    SET der_release_qty = 0
    SET der_release_iu = 0
    FOR (count2 = 1 TO nbr_of_events )
     IF ((ops_request->productlist[prod ].productevent[count2 ].event_type_cd = assign_event_type_cd
     ) )
      SET der_release_qty = (der_release_qty + ops_request->productlist[prod ].productevent[count2 ].
      release_qty )
      SET der_release_iu = (der_release_iu + ops_request->productlist[prod ].productevent[count2 ].
      release_iu )
     ENDIF
    ENDFOR
    UPDATE FROM (derivative der )
     SET der.cur_avail_qty = (der.cur_avail_qty + der_release_qty ) ,
      der.cur_intl_units = (der.cur_intl_units + der_release_iu ) ,
      der.updt_cnt = (der.updt_cnt + 1 ) ,
      der.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      der.updt_task = reqinfo->updt_task ,
      der.updt_id = reqinfo->updt_id ,
      der.updt_applctx = reqinfo->updt_applctx
     PLAN (der
      WHERE (der.product_id = ops_request->productlist[prod ].product_id )
      AND (der.updt_cnt = ops_request->productlist[prod ].der_updt_cnt ) )
     WITH counter
    ;end update
    IF ((curqual = 0 ) )
     SET error_process = "updt derivative"
     SET error_message = "available qty not updated"
     SET failure_occured = "T"
    ENDIF
   ENDIF
   IF ((ops_request->productlist[prod ].status = "S" ) )
    SELECT INTO "nl:"
     p.product_id
     FROM (product p )
     PLAN (p
      WHERE (p.product_id = ops_request->productlist[prod ].product_id )
      AND (p.updt_cnt = ops_request->productlist[prod ].p_updt_cnt )
      AND (p.locked_ind = 1 ) )
     DETAIL
      CALL echo (build ("locked_ind: " ,p.locked_ind ) ) ,
      CALL echo (build ("update_cnt: " ,p.updt_cnt ) )
     WITH nocounter ,forupdate (p )
    ;end select
    IF ((curqual = 0 ) )
     SET error_process = "update product"
     SET error_message = "product not unlocked"
     SET failure_occured = "T"
    ELSE
     UPDATE FROM (product p )
      SET p.locked_ind = 0 ,
       p.updt_cnt = (p.updt_cnt + 1 ) ,
       p.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
       p.updt_id = reqinfo->updt_id ,
       p.updt_task = reqinfo->updt_task ,
       p.updt_applctx = reqinfo->updt_applctx
      PLAN (p
       WHERE (p.product_id = ops_request->productlist[prod ].product_id )
       AND (p.updt_cnt = ops_request->productlist[prod ].p_updt_cnt )
       AND (p.locked_ind = 1 ) )
      WITH counter
     ;end update
     IF ((curqual = 0 ) )
      SET error_process = "update product"
      SET error_message = "product not unlocked"
      SET failure_occured = "T"
     ENDIF
    ENDIF
   ENDIF
   IF ((failure_occured = "F" )
   AND (ops_request->productlist[prod ].status = "S" ) )
    SET reply->status_data.status = "S"
    SET ops_request->productlist[prod ].err_message = " "
    SET reply->status_data.subeventstatus[prod ].operationname = "Complete"
    SET reply->status_data.subeventstatus[prod ].operationstatus = "S"
    SET reply->status_data.subeventstatus[prod ].targetobjectname = "Tables Updated"
    SET reply->status_data.subeventstatus[prod ].targetobjectvalue = "S"
    COMMIT
    SET success_cnt = (success_cnt + 1 )
   ELSE
    ROLLBACK
    SET ops_request->productlist[prod ].status = "F"
    IF ((ops_request->productlist[prod ].err_message <= " " ) )
     SET ops_request->productlist[prod ].err_message = error_message
    ENDIF
    SET reply->status_data.subeventstatus[prod ].operationname = error_process
    SET reply->status_data.subeventstatus[prod ].operationstatus = "F"
    SET reply->status_data.subeventstatus[prod ].targetobjectname = error_message
    SET reply->status_data.subeventstatus[prod ].targetobjectvalue = "F"
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE  add_product_event_with_inventory_area_cd (sub_product_id ,sub_person_id ,sub_encntr_id ,
  sub_order_id ,sub_bb_result_id ,sub_event_type_cd ,sub_event_dt_tm ,sub_event_prsnl_id ,
  sub_event_status_flag ,sub_override_ind ,sub_override_reason_cd ,sub_related_product_event_id ,
  sub_active_ind ,sub_active_status_cd ,sub_active_status_dt_tm ,sub_active_status_prsnl_id ,
  sub_locn_cd )
  CALL echo (build (" PRODUCT_ID - " ,sub_product_id ," PERSON_ID - " ,sub_person_id ,
    " ENCNTR_ID - " ,sub_encntr_id ," SUB_RODER_ID - " ,sub_order_id ," BB_RESULT_ID - " ,
    sub_bb_result_id ," EVENT_TYPE_ID - " ,sub_event_type_cd ," EVENT_DT_TM_ID - " ,sub_event_dt_tm ,
    " PRSNL_ID - " ,sub_event_prsnl_id ," EVENT_STATUS_FLAG - " ,sub_event_status_flag ,
    " override_ind - " ,sub_override_ind ," override_reason_cd - " ,sub_override_reason_cd ,
    " related_pe_id - " ,sub_related_product_event_id ," active_ind - " ,sub_active_ind ,
    " active_status_cd - " ,sub_active_status_cd ," active_status_dt_tm - " ,sub_active_status_dt_tm
    ," status_prsnl_id - " ,sub_active_status_prsnl_id ," inventoy_area_cd - " ,sub_locn_cd ) )
  SET gsub_product_event_status = "  "
  SET product_event_id = 0.0
  SET sub_product_event_id = 0.0
  DECLARE new_pathnet_seq = f8 WITH protect ,noconstant (0.0 )
  SET new_pathnet_seq = 0
  SELECT INTO "nl:"
   seqn = seq (pathnet_seq ,nextval )
   FROM (dual )
   DETAIL
    new_pathnet_seq = seqn
   WITH format ,nocounter
  ;end select
  IF ((curqual = 0 ) )
   SET gsub_product_event_status = "FS"
  ELSE
   SET sub_product_event_id = new_pathnet_seq
   INSERT FROM (product_event pe )
    SET pe.product_event_id = sub_product_event_id ,
     pe.product_id = sub_product_id ,
     pe.person_id =
     IF ((sub_person_id = null ) ) 0
     ELSE sub_person_id
     ENDIF
     ,pe.encntr_id =
     IF ((sub_encntr_id = null ) ) 0
     ELSE sub_encntr_id
     ENDIF
     ,pe.order_id =
     IF ((sub_order_id = null ) ) 0
     ELSE sub_order_id
     ENDIF
     ,pe.bb_result_id = sub_bb_result_id ,
     pe.event_type_cd = sub_event_type_cd ,
     pe.event_dt_tm = cnvtdatetime (sub_event_dt_tm ) ,
     pe.event_prsnl_id = sub_event_prsnl_id ,
     pe.event_status_flag = sub_event_status_flag ,
     pe.override_ind = sub_override_ind ,
     pe.override_reason_cd = sub_override_reason_cd ,
     pe.related_product_event_id = sub_related_product_event_id ,
     pe.active_ind = sub_active_ind ,
     pe.active_status_cd = sub_active_status_cd ,
     pe.active_status_dt_tm = cnvtdatetime (sub_active_status_dt_tm ) ,
     pe.active_status_prsnl_id = sub_active_status_prsnl_id ,
     pe.updt_cnt = 0 ,
     pe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     pe.updt_id = reqinfo->updt_id ,
     pe.updt_task = reqinfo->updt_task ,
     pe.updt_applctx = reqinfo->updt_applctx ,
     pe.event_tz =
     IF ((curutc = 1 ) ) curtimezoneapp
     ELSE 0
     ENDIF
     ,pe.inventory_area_cd = sub_locn_cd
    WITH nocounter
   ;end insert
   SET product_event_id = sub_product_event_id
   SET new_product_event_id = sub_product_event_id
   IF ((curqual = 0 ) )
    SET gsub_product_event_status = "FA"
   ELSE
    SET gsub_product_event_status = "OK"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  add_product_event (sub_product_id ,sub_person_id ,sub_encntr_id ,sub_order_id ,
  sub_bb_result_id ,sub_event_type_cd ,sub_event_dt_tm ,sub_event_prsnl_id ,sub_event_status_flag ,
  sub_override_ind ,sub_override_reason_cd ,sub_related_product_event_id ,sub_active_ind ,
  sub_active_status_cd ,sub_active_status_dt_tm ,sub_active_status_prsnl_id )
  SET gsub_product_event_status = "  "
  SET product_event_id = 0.0
  SET sub_product_event_id = 0.0
  DECLARE new_pathnet_seq = f8 WITH protect ,noconstant (0.0 )
  SET new_pathnet_seq = 0
  SELECT INTO "nl:"
   seqn = seq (pathnet_seq ,nextval )
   FROM (dual )
   DETAIL
    new_pathnet_seq = seqn
   WITH format ,nocounter
  ;end select
  IF ((curqual = 0 ) )
   SET gsub_product_event_status = "FS"
  ELSE
   SET sub_product_event_id = new_pathnet_seq
   INSERT FROM (product_event pe )
    SET pe.product_event_id = sub_product_event_id ,
     pe.product_id = sub_product_id ,
     pe.person_id =
     IF ((sub_person_id = null ) ) 0
     ELSE sub_person_id
     ENDIF
     ,pe.encntr_id =
     IF ((sub_encntr_id = null ) ) 0
     ELSE sub_encntr_id
     ENDIF
     ,pe.order_id =
     IF ((sub_order_id = null ) ) 0
     ELSE sub_order_id
     ENDIF
     ,pe.bb_result_id = sub_bb_result_id ,
     pe.event_type_cd = sub_event_type_cd ,
     pe.event_dt_tm = cnvtdatetime (sub_event_dt_tm ) ,
     pe.event_prsnl_id = sub_event_prsnl_id ,
     pe.event_status_flag = sub_event_status_flag ,
     pe.override_ind = sub_override_ind ,
     pe.override_reason_cd = sub_override_reason_cd ,
     pe.related_product_event_id = sub_related_product_event_id ,
     pe.active_ind = sub_active_ind ,
     pe.active_status_cd = sub_active_status_cd ,
     pe.active_status_dt_tm = cnvtdatetime (sub_active_status_dt_tm ) ,
     pe.active_status_prsnl_id = sub_active_status_prsnl_id ,
     pe.updt_cnt = 0 ,
     pe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     pe.updt_id = reqinfo->updt_id ,
     pe.updt_task = reqinfo->updt_task ,
     pe.updt_applctx = reqinfo->updt_applctx ,
     pe.event_tz =
     IF ((curutc = 1 ) ) curtimezoneapp
     ELSE 0
     ENDIF
    WITH nocounter
   ;end insert
   SET product_event_id = sub_product_event_id
   SET new_product_event_id = sub_product_event_id
   IF ((curqual = 0 ) )
    SET gsub_product_event_status = "FA"
   ELSE
    SET gsub_product_event_status = "OK"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  chg_product_event (sub_product_event_id ,sub_event_dt_tm ,sub_event_prsnl_id ,
  sub_event_status_flag ,sub_active_ind ,sub_active_status_cd ,sub_active_status_dt_tm ,
  sub_active_status_prsnl_id ,sub_updt_cnt ,sub_lock_forupdate_ind ,sub_updt_dt_tm_prsnl_ind )
  SET gsub_product_event_status = "  "
  IF ((sub_lock_forupdate_ind = 1 ) )
   SELECT INTO "nl:"
    pe.product_event_id
    FROM (product_event pe )
    WHERE (pe.product_event_id = sub_product_event_id )
    AND (pe.updt_cnt = sub_updt_cnt )
    WITH nocounter
   ;end select
   IF ((curqual = 0 ) )
    SET gsub_product_event_status = "FL"
   ENDIF
  ENDIF
  IF ((((sub_lock_forupdate_ind = 0 ) ) OR ((sub_lock_forupdate_ind = 1 )
  AND (curqual > 0 ) )) )
   IF ((sub_updt_dt_tm_prsnl_ind = 1 ) )
    UPDATE FROM (product_event pe )
     SET pe.event_dt_tm = cnvtdatetime (sub_event_dt_tm ) ,
      pe.event_prsnl_id = sub_event_prsnl_id ,
      pe.event_status_flag = sub_event_status_flag ,
      pe.active_ind = sub_active_ind ,
      pe.active_status_cd = sub_active_status_cd ,
      pe.active_status_dt_tm = cnvtdatetime (sub_active_status_dt_tm ) ,
      pe.active_status_prsnl_id = sub_active_status_prsnl_id ,
      pe.updt_cnt = (pe.updt_cnt + 1 ) ,
      pe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      pe.updt_id = reqinfo->updt_id ,
      pe.updt_task = reqinfo->updt_task ,
      pe.updt_applctx = reqinfo->updt_applctx
     WHERE (pe.product_event_id = sub_product_event_id )
     AND (pe.updt_cnt = sub_updt_cnt )
     WITH nocounter
    ;end update
   ELSE
    UPDATE FROM (product_event pe )
     SET pe.event_status_flag = sub_event_status_flag ,
      pe.active_ind = sub_active_ind ,
      pe.active_status_cd = sub_active_status_cd ,
      pe.active_status_dt_tm = cnvtdatetime (sub_active_status_dt_tm ) ,
      pe.active_status_prsnl_id = sub_active_status_prsnl_id ,
      pe.updt_cnt = (pe.updt_cnt + 1 ) ,
      pe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      pe.updt_id = reqinfo->updt_id ,
      pe.updt_task = reqinfo->updt_task ,
      pe.updt_applctx = reqinfo->updt_applctx
     WHERE (pe.product_event_id = sub_product_event_id )
     AND (pe.updt_cnt = sub_updt_cnt )
     WITH nocounter
    ;end update
   ENDIF
   IF ((curqual = 0 ) )
    SET gsub_product_event_status = "FU"
   ELSE
    SET gsub_product_event_status = "OK"
   ENDIF
  ENDIF
 END ;Subroutine
 IF ((success_cnt < nbr_to_update ) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET number = "                    "
 SET sub_number = fillstring (5 ," " )
 SET med_num = "                   "
 SET pat_name = "                                     "
 SET prod_num = "                         "
 SET status = fillstring (20 ," " )
 SET prod_disp = "                                     "
 SET line = fillstring (125 ,"_" )
 SET cur_owner_area_disp = fillstring (40 ," " )
 SET cur_inv_area_disp = fillstring (40 ," " )
 SET msg_error = fillstring (30 ," " )
 SET reason = fillstring (30 ," " )
 SET temp_string = fillstring (15 ," " )
 SET count1 = cnvtint (size (ops_request->productlist ,5 ) )
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_batchrelease" ,
 "txt" ,
 "x"
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = size (ops_request->productlist ,5 ) ),
   (dummyt d2 WITH seq = 1 ),
   (person_aborh pa )
  PLAN (d
   WHERE maxrec (d2 ,size (ops_request->productlist[d.seq ].productevent ,5 ) ) )
   JOIN (d2 )
   JOIN (pa
   WHERE (ops_request->productlist[d.seq ].productevent[d2.seq ].person_id = pa.person_id ) )
  DETAIL
   ops_request->productlist[d.seq ].productevent[d2.seq ].pat_aborh = build2 (trim (
     uar_get_code_display (pa.abo_cd ) ) ," " ,trim (uar_get_code_display (pa.rh_cd ) ) )
  WITH nocounter
 ;end select
 CALL echorecord (ops_request )
 SELECT INTO cpm_cfn_info->file_name_logical
  per.person_id ,
  per.name_full_formatted ,
  pra.person_id ,
  pra.alias ,
  p.product_id ,
  ord.accession ,
  c_prod.display ,
  sort1 =
  IF ((sort_field > " " ) )
   IF ((sort_field = "NAME" ) ) per.name_full_formatted
   ELSEIF ((sort_field = "MRN" ) ) pra.alias
   ELSE per.name_full_formatted
   ENDIF
  ELSE per.name_full_formatted
  ENDIF
  ,sort2 =
  IF ((sort_field > " " ) )
   IF ((sort_field = "NAME" ) ) " "
   ELSEIF ((sort_field = "MRN" ) ) per.name_full_formatted
   ELSE " "
   ENDIF
  ELSE " "
  ENDIF
  FROM (product p ),
   (product_event pe ),
   (dummyt d_pra WITH seq = 1 ),
   (person_alias pra ),
   (dummyt d_ord WITH seq = 1 ),
   (accession_order_r ord ),
   (person per ),
   (code_value c_prod ),
   (dummyt d1 WITH seq = 1 ),
   (dummyt d2 WITH seq = 1 ),
   (dummyt d_ar WITH seq = value (count1 ) )
  PLAN (d_ar )
   JOIN (p
   WHERE (p.product_id = ops_request->productlist[d_ar.seq ].product_id ) )
   JOIN (pe
   WHERE (p.product_id = pe.product_id )
   AND expand (pe_index ,1 ,size (ops_request->productlist[d_ar.seq ].productevent ,5 ) ,pe
    .product_event_id ,ops_request->productlist[d_ar.seq ].productevent[pe_index ].product_event_id
    ) )
   JOIN (d1
   WHERE (d1.seq = 1 ) )
   JOIN (per
   WHERE (pe.person_id = per.person_id ) )
   JOIN (d2
   WHERE (d2.seq = 1 ) )
   JOIN (c_prod
   WHERE (c_prod.code_set = 1604 )
   AND (p.product_cd = c_prod.code_value ) )
   JOIN (d_pra
   WHERE (d_pra.seq = 1 ) )
   JOIN (pra
   WHERE (pe.person_id = pra.person_id )
   AND (pra.person_alias_type_cd = mrn_code )
   AND (pra.active_ind != 0 ) )
   JOIN (d_ord
   WHERE (d_ord.seq = 1 ) )
   JOIN (ord
   WHERE (pe.order_id = ord.order_id )
   AND (ord.primary_flag = 0 ) )
  ORDER BY p.cur_owner_area_cd ,
   p.cur_inv_area_cd ,
   sort1 ,
   sort2 ,
   per.person_id ,
   p.product_nbr ,
   p.product_id ,
   pe.product_event_id
  HEAD REPORT
   cur_owner_area_cd_hd = p.cur_owner_area_cd ,
   cur_inv_area_cd_hd = p.cur_inv_area_cd ,
   cur_owner_area_disp = uar_get_code_display (p.cur_owner_area_cd ) ,
   cur_inv_area_disp = uar_get_code_display (p.cur_inv_area_cd ) ,
   select_ok_ind = 0 ,
   formatted_acc = fillstring (25 ," " )
  HEAD PAGE
   row 0 ,
   CALL center (captions->rpt_batch_crossmatch ,1 ,125 ) ,
   col 104 ,
   captions->as_of_time ,
   col 119 ,
   request->ops_date "@TIMENOSECONDS;;M" ,
   row + 1 ,
   col 104 ,
   captions->as_of_date ,
   col 119 ,
   request->ops_date "@DATECONDENSED;;d" ,
   inc_i18nhandle = 0 ,
   inc_h = uar_i18nlocalizationinit (inc_i18nhandle ,curprog ,"" ,curcclrev ) ,
   row 0 ,
   IF ((sub_get_location_name = "<<INFORMATION NOT FOUND>>" ) ) inc_info_not_found =
    uar_i18ngetmessage (inc_i18nhandle ,"inc_information_not_found" ,"<<INFORMATION NOT FOUND>>" ) ,
    col 1 ,inc_info_not_found
   ELSE col 1 ,sub_get_location_name
   ENDIF
   ,row + 1 ,
   IF ((sub_get_location_name != "<<INFORMATION NOT FOUND>>" ) )
    IF ((sub_get_location_address1 != " " ) ) col 1 ,sub_get_location_address1 ,row + 1
    ENDIF
    ,
    IF ((sub_get_location_address2 != " " ) ) col 1 ,sub_get_location_address2 ,row + 1
    ENDIF
    ,
    IF ((sub_get_location_address3 != " " ) ) col 1 ,sub_get_location_address3 ,row + 1
    ENDIF
    ,
    IF ((sub_get_location_address4 != " " ) ) col 1 ,sub_get_location_address4 ,row + 1
    ENDIF
    ,
    IF ((sub_get_location_citystatezip != ",   " ) ) col 1 ,sub_get_location_citystatezip ,row + 1
    ENDIF
    ,
    IF ((sub_get_location_country != " " ) ) col 1 ,sub_get_location_country ,row + 1
    ENDIF
   ENDIF
   ,save_row = row ,
   row 1 ,
   CALL center (rpt_mode ,1 ,125 ) ,
   row save_row ,
   row + 1 ,
   col 1 ,
   captions->blood_bank_owner ,
   col 19 ,
   cur_owner_area_disp ,
   row + 1 ,
   col 1 ,
   captions->inventory_area ,
   col 17 ,
   cur_inv_area_disp ,
   row + 1 ,
   col 1 ,
   captions->prepared ,
   col 11 ,
   curdate "@DATECONDENSED;;d" ,
   row + 3 ,
   CALL center (captions->unit_number ,58 ,82 ) ,
   CALL center (captions->status ,98 ,111 ) ,
   row + 1 ,
   CALL center (captions->medical_number ,1 ,19 ) ,
   CALL center (captions->patient_name ,21 ,56 ) ,
   CALL center (captions->accession_number ,58 ,82 ) ,
   CALL center (captions->product ,78 ,90 ) ,
   CALL center (captions->reason ,98 ,111 ) ,
   CALL center (captions->xm_exp_date ,113 ,125 ) ,
   CALL center (captions->aborh ,126 ,135 ) ,
   row + 1 ,
   col 1 ,
   "-------------------" ,
   col 21 ,
   "------------------------------------" ,
   col 58 ,
   "-------------------" ,
   col 78 ,
   "-------------" ,
   col 98 ,
   "--------------" ,
   col 113 ,
   "-------------" ,
   col 127 ,
   "---------" ,
   row + 2
  HEAD p.cur_owner_area_cd
   IF ((p.cur_owner_area_cd != cur_owner_area_cd_hd ) ) cur_owner_area_disp = uar_get_code_display (p
     .cur_owner_area_cd ) ,cur_owner_area_cd_hd = p.cur_owner_area_cd
   ENDIF
  HEAD p.cur_inv_area_cd
   IF ((p.cur_inv_area_cd != cur_inv_area_cd_hd ) ) cur_inv_area_disp = uar_get_code_display (p
     .cur_inv_area_cd ) ,cur_inv_area_cd_hd = p.cur_inv_area_cd ,
    BREAK
   ENDIF
  HEAD per.person_id
   med_num = cnvtalias (pra.alias ,pra.alias_pool_cd ) ,pat_name = per.name_full_formatted
  HEAD p.product_id
   IF ((row >= 58 ) )
    BREAK
   ENDIF
   ,
   IF ((ops_request->productlist[d_ar.seq ].product_id > 0.0 )
   AND (product_count > 0 ) )
    IF ((ops_request->productlist[d_ar.seq ].product_type = "B" ) ) number = p.product_nbr ,
     sub_number = p.product_sub_nbr ,prod_num = concat (trim (ops_request->productlist[d_ar.seq ].
       supp_prefix ) ,trim (number ,3 ) ," " ,trim (sub_number ,3 ) )
    ELSE prod_num = p.product_nbr
    ENDIF
    ,prod_disp = substring (1 ,18 ,c_prod.display ) ,col 1 ,med_num ,col 21 ,pat_name
   ELSEIF ((count1 <= 1 ) ) row + 1 ,
    CALL center (captions->rpt_no_crossmatches ,1 ,125 )
   ENDIF
  HEAD pe.product_event_id
   IF ((row >= 58 ) )
    BREAK
   ENDIF
   ,reason = " " ,pos = locateval (index ,1 ,size (ops_request->productlist[d_ar.seq ].productevent ,
     5 ) ,pe.product_event_id ,ops_request->productlist[d_ar.seq ].productevent[index ].
    product_event_id ) ,
   IF ((pos > 0 ) )
    IF ((ops_request->productlist[d_ar.seq ].status = "S" )
    AND (cnvtupper (batch_field ) = "UPDATE" ) ) status = "Released" ,temp_string = " " ,
     IF ((pe.event_type_cd = xmtch_event_type_cd ) ) temp_string = "XM"
     ELSEIF ((pe.event_type_cd = assign_event_type_cd ) ) temp_string = "Assign"
     ELSEIF ((pe.event_type_cd = inprogress_event_type_cd ) ) temp_string = "Inprog"
     ENDIF
     ,status = concat (temp_string ," " ,status ) ,reason = uar_get_code_display (ops_request->
      productlist[d_ar.seq ].productevent[pos ].release_reason_cd ) ,reason = substring (1 ,15 ,
      reason )
    ELSE status = "Not Released" ,
     IF ((ops_request->productlist[d_ar.seq ].err_message > " " ) ) reason = ops_request->
      productlist[d_ar.seq ].err_message
     ENDIF
    ENDIF
    ,col 58 ,prod_num ,col 78 ,prod_disp ,col 97 ,status ,col 113 ,ops_request->productlist[d_ar.seq
    ].productevent[pos ].xm_exp_dt_tm "@DATETIMECONDENSED;;d" ,col 127 ,ops_request->productlist[d_ar
    .seq ].productevent[pos ].pat_aborh ,row + 1 ,formatted_acc = cnvtacc (ord.accession ) ,col 58 ,
    formatted_acc ,col 97 ,reason ,row + 1
   ENDIF
  DETAIL
   row + 0
  FOOT PAGE
   row 59 ,
   col 1 ,
   line ,
   row + 1 ,
   col 1 ,
   captions->report_id ,
   col 60 ,
   captions->rpt_page ,
   col 67 ,
   curpage "###" ,
   col 101 ,
   captions->printed ,
   col 110 ,
   curdate "@DATECONDENSED;;d" ,
   col 119 ,
   curtime "@TIMENOSECONDS;;M"
  FOOT REPORT
   row 62 ,
   col 53 ,
   captions->end_of_report ,
   select_ok_ind = 1
  WITH nocounter ,outerjoin (d1 ) ,outerjoin (d2 ) ,outerjoin (d_pra ) ,dontcare (pra ) ,outerjoin (
    d_ord ) ,maxrow = 63 ,compress ,nolandscape ,nullreport ,expand = 1 ,maxcol = 150
 ;end select
 SET rpt_cnt = (rpt_cnt + 1 )
 SET stat = alterlist (reply->rpt_list ,rpt_cnt )
 SET reply->rpt_list[rpt_cnt ].rpt_filename = cpm_cfn_info->file_name_path
 SET spool value (reply->rpt_list[rpt_cnt ].rpt_filename ) value (request->output_dist )
 IF ((select_ok_ind = 1 ) )
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO

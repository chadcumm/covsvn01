
DROP PROGRAM bbt_rpt_unit_status :dba GO
CREATE PROGRAM bbt_rpt_unit_status :dba
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
 DECLARE get_username (sub_person_id ) = c10
 SUBROUTINE  get_username (sub_person_id )
  SET sub_get_username = fillstring (10 ," " )
  SELECT INTO "nl:"
   pnl.username
   FROM (prsnl pnl )
   WHERE (pnl.person_id = sub_person_id )
   AND (pnl.person_id != null )
   AND (pnl.person_id > 0.0 )
   DETAIL
    sub_get_username = pnl.username
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   SET inc_i18nhandle = 0
   SET inc_h = uar_i18nlocalizationinit (inc_i18nhandle ,curprog ,"" ,curcclrev )
   SET sub_get_username = uar_i18ngetmessage (inc_i18nhandle ,"inc_unknown" ,"<Unknown>" )
  ENDIF
  RETURN (sub_get_username )
 END ;Subroutine
 DECLARE reportbyusername = vc WITH protect ,noconstant ("" )
 SET reportbyusername = get_username (reqinfo->updt_id )
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
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 user = vc
   1 blood_bank_owner = vc
   1 inventory_area = vc
   1 product_class = vc
   1 product_category = vc
   1 begin_exp_date = vc
   1 ending_exp_date = vc
   1 expire = vc
   1 prod_number = vc
   1 prod_type = vc
   1 aborh = vc
   1 quantity = vc
   1 date_time = vc
   1 status = vc
   1 name = vc
   1 mrn = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
   1 not_on_file = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage (i18nhandle ,"rpt_title" ,
  "U N I T   S T A T U S   R E P O R T" )
 SET captions->rpt_time = uar_i18ngetmessage (i18nhandle ,"rpt_time" ,"Time:" )
 SET captions->rpt_as_of_date = uar_i18ngetmessage (i18nhandle ,"rpt_as_of_date" ,"As of Date:" )
 SET captions->user = uar_i18ngetmessage (i18nhandle ,"user" ,"User:" )
 SET captions->blood_bank_owner = uar_i18ngetmessage (i18nhandle ,"blood_bank_owner" ,
  "Blood Bank Owner: " )
 SET captions->inventory_area = uar_i18ngetmessage (i18nhandle ,"inventory_area" ,"Inventory Area: "
  )
 SET captions->product_class = uar_i18ngetmessage (i18nhandle ,"product_class" ,"Product Class:" )
 SET captions->product_category = uar_i18ngetmessage (i18nhandle ,"product_category" ,
  "Product Category:" )
 SET captions->begin_exp_date = uar_i18ngetmessage (i18nhandle ,"begin_exp_date" ,
  "Beginning Expiration Date:" )
 SET captions->ending_exp_date = uar_i18ngetmessage (i18nhandle ,"ending_exp_date" ,
  "Ending Expiration Date:" )
 SET captions->expire = uar_i18ngetmessage (i18nhandle ,"expire" ,"Expire" )
 SET captions->prod_number = uar_i18ngetmessage (i18nhandle ,"prod_number" ,"Product Number" )
 SET captions->prod_type = uar_i18ngetmessage (i18nhandle ,"prod_type" ,"Product Type" )
 SET captions->aborh = uar_i18ngetmessage (i18nhandle ,"aborh" ,"ABO/Rh" )
 SET captions->quantity = uar_i18ngetmessage (i18nhandle ,"quantity" ,"Qty" )
 SET captions->date_time = uar_i18ngetmessage (i18nhandle ,"date_time" ,"Date/Time" )
 SET captions->status = uar_i18ngetmessage (i18nhandle ,"status" ,"Status" )
 SET captions->name = uar_i18ngetmessage (i18nhandle ,"name" ,"Name" )
 SET captions->mrn = uar_i18ngetmessage (i18nhandle ,"mrn" ,"MRN" )
 SET captions->rpt_id = uar_i18ngetmessage (i18nhandle ,"rpt_id" ,"Report ID: BBT_RPT_UNIT_STATUS" )
 SET captions->rpt_page = uar_i18ngetmessage (i18nhandle ,"rpt_page" ,"Page:" )
 SET captions->printed = uar_i18ngetmessage (i18nhandle ,"printed" ,"Printed:" )
 SET captions->end_of_report = uar_i18ngetmessage (i18nhandle ,"end_of_report" ,
  "* * * End of Report * * *" )
 SET captions->all = uar_i18ngetmessage (i18nhandle ,"all" ,"(All)" )
 SET captions->not_on_file = uar_i18ngetmessage (i18nhandle ,"not_on_file" ,"<Not on file>" )
 DECLARE nproductcount = i2 WITH noconstant (0 )
 DECLARE naddproduct = i2 WITH noconstant (0 )
 DECLARE ndervalidevent = i2 WITH noconstant (0 )
 DECLARE nderinvalidevent = i2 WITH noconstant (0 )
 IF ((trim (request->batch_selection ) > "" ) )
  SET temp_string = cnvtupper (trim (request->batch_selection ) )
  SET days_look_ahead = 0
  CALL check_rangeofdays_opt ("bbt_rpt_unit_status" )
  IF ((days_look_ahead > 0 ) )
   SET begin_date_time = cnvtdatetime (request->ops_date )
   SET end_date_time = cnvtdatetime (datetimeadd (request->ops_date ,days_look_ahead ) )
  ELSE
   SET reply->status = "F"
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "bbt_rpt_unit_status"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "no value in string"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "parse look ahead days"
   GO TO exit_script
  ENDIF
  CALL check_owner_cd ("bbt_rpt_unit_status" )
  CALL check_inventory_cd ("bbt_rpt_unit_status" )
  CALL check_location_cd ("bbt_rpt_unit_status" )
 ELSE
  SET begin_date_time = cnvtdatetime (request->beg_dt_tm )
  SET end_date_time = cnvtdatetime (request->end_dt_tm )
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
 SET cur_owner_area_disp = fillstring (40 ," " )
 SET cur_inv_area_disp = fillstring (40 ," " )
 IF ((request->cur_owner_area_cd = 0.0 ) )
  SET cur_owner_area_disp = captions->all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display (request->cur_owner_area_cd )
 ENDIF
 IF ((request->cur_inv_area_cd = 0.0 ) )
  SET cur_inv_area_disp = captions->all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display (request->cur_inv_area_cd )
 ENDIF
 SET line = fillstring (125 ,"_" )
 SET mrn_code = 0.0
 SET dispose_code = 0.0
 SET transfuse_code = 0.0
 SET destroy_code = 0.0
 SET code_cnt = 1
 SET derivative_class_cd = 0.0
 SET cdf_meaning = fillstring (12 ," " )
 SET cdf_meaning = "DERIVATIVE"
 SET stat = uar_get_meaning_by_codeset (1606 ,cdf_meaning ,1 ,derivative_class_cd )
 SET stat = uar_get_meaning_by_codeset (319 ,"MRN" ,code_cnt ,mrn_code )
 SET stat = uar_get_meaning_by_codeset (1610 ,"5" ,code_cnt ,dispose_code )
 SET stat = uar_get_meaning_by_codeset (1610 ,"7" ,code_cnt ,transfuse_code )
 SET stat = uar_get_meaning_by_codeset (1610 ,"14" ,code_cnt ,destroy_code )
 IF ((((mrn_code = 0.0 ) ) OR ((((dispose_code = 0.0 ) ) OR ((((transfuse_code = 0.0 ) ) OR ((((
 destroy_code = 0.0 ) ) OR ((derivative_class_cd = 0.0 ) )) )) )) )) )
  SET reply->status = "F"
  GO TO exit_script
 ENDIF
 RECORD aborh (
   1 aborh_list [* ]
     2 aborh_display = c13
     2 abo_code = f8
     2 rh_code = f8
 )
 SET stat = alterlist (aborh->aborh_list ,10 )
 SET aborh_index = 0
 SELECT INTO "nl:"
  FROM (code_value cv1 ),
   (code_value_extension cve1 ),
   (code_value_extension cve2 ),
   (dummyt d1 WITH seq = 1 ),
   (code_value cv2 ),
   (dummyt d2 WITH seq = 1 ),
   (code_value cv3 )
  PLAN (cv1
   WHERE (cv1.code_set = 1640 )
   AND (cv1.active_ind = 1 ) )
   JOIN (cve1
   WHERE (cve1.code_set = 1640 )
   AND (cv1.code_value = cve1.code_value )
   AND (cve1.field_name = "ABOOnly_cd" ) )
   JOIN (cve2
   WHERE (cve2.code_set = 1640 )
   AND (cv1.code_value = cve2.code_value )
   AND (cve2.field_name = "RhOnly_cd" ) )
   JOIN (d1
   WHERE (d1.seq = 1 ) )
   JOIN (cv2
   WHERE (cv2.code_set = 1641 )
   AND (cnvtint (cve1.field_value ) = cv2.code_value ) )
   JOIN (d2
   WHERE (d2.seq = 1 ) )
   JOIN (cv3
   WHERE (cv3.code_set = 1642 )
   AND (cnvtint (cve2.field_value ) = cv3.code_value ) )
  ORDER BY cve1.field_value ,
   cve2.field_value
  DETAIL
   aborh_index = (aborh_index + 1 ) ,
   IF ((mod (aborh_index ,10 ) = 1 )
   AND (aborh_index != 1 ) ) stat = alterlist (aborh->aborh_list ,(aborh_index + 9 ) )
   ENDIF
   ,aborh->aborh_list[aborh_index ].aborh_display = substring (1 ,13 ,cv1.display ) ,
   aborh->aborh_list[aborh_index ].abo_code = cv2.code_value ,
   aborh->aborh_list[aborh_index ].rh_code = cv3.code_value
  WITH outerjoin (d1 ) ,outerjoin (d2 ) ,check ,nocounter
 ;end select
 IF ((curqual > 0 ) )
  SET stat = alterlist (aborh->aborh_list ,aborh_index )
 ENDIF
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_unit_status" ,
 "txt" ,
 "x"
 RECORD product (
   1 product_list [* ]
     2 product_id = f8
 )
 SET stat = alterlist (product->product_list ,0 )
 SELECT INTO "nl:"
  p.product_id ,
  pe.event_type_cd
  FROM (product p ),
   (product_event pe )
  PLAN (p
   WHERE (p.cur_expire_dt_tm BETWEEN cnvtdatetime (begin_date_time ) AND cnvtdatetime (end_date_time
    ) )
   AND (((request->cur_owner_area_cd > 0.0 )
   AND (request->cur_owner_area_cd = p.cur_owner_area_cd ) ) OR ((request->cur_owner_area_cd = 0.0 )
   ))
   AND (((request->cur_inv_area_cd > 0.0 )
   AND (request->cur_inv_area_cd = p.cur_inv_area_cd ) ) OR ((request->cur_inv_area_cd = 0.0 ) ))
   AND (p.active_ind = 1 )
   AND (p.product_id > 0.0 ) )
   JOIN (pe
   WHERE (pe.product_id = p.product_id )
   AND (pe.active_ind = 1 ) )
  HEAD p.product_id
   naddproduct = 1 ,ndervalidevent = 0 ,nderinvalidevent = 0
  DETAIL
   IF ((naddproduct = 1 ) )
    IF ((p.product_class_cd = derivative_class_cd ) )
     IF ((pe.event_type_cd != dispose_code )
     AND (pe.event_type_cd != transfuse_code )
     AND (pe.event_type_cd != destroy_code ) ) ndervalidevent = (ndervalidevent + 1 )
     ENDIF
    ELSE
     IF ((((pe.event_type_cd = dispose_code ) ) OR ((((pe.event_type_cd = transfuse_code ) ) OR ((pe
     .event_type_cd = destroy_code ) )) )) ) naddproduct = 0
     ENDIF
    ENDIF
   ENDIF
  FOOT  p.product_id
   IF ((p.product_class_cd = derivative_class_cd ) )
    IF ((ndervalidevent > 0 ) ) naddproduct = 1
    ELSE naddproduct = 0
    ENDIF
   ENDIF
   ,
   IF ((naddproduct = 1 ) ) nproductcount = (nproductcount + 1 ) ,
    IF ((mod (nproductcount ,10 ) = 1 ) ) stat = alterlist (product->product_list ,(nproductcount +
      9 ) )
    ENDIF
    ,product->product_list[nproductcount ].product_id = p.product_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist (product->product_list ,nproductcount )
 SELECT INTO cpm_cfn_info->file_name_logical
  d_flg = decode (bp.seq ,"BP" ,de.seq ,"DE" ,"XX" ) ,
  pr.product_id ,
  pr.product_nbr ,
  pr.product_sub_nbr ,
  pr.product_cat_cd ,
  pr.cur_expire_dt_tm ,
  product_class_display = uar_get_code_display (pr.product_class_cd ) ,
  product_cat_display = uar_get_code_display (pr.product_cat_cd ) ,
  product_display = uar_get_code_display (pr.product_cd ) ,
  pe.person_id ,
  pe.product_event_id ,
  pe.event_type_cd ,
  event_type_display = uar_get_code_display (pe.event_type_cd ) "###############" ,
  bp.cur_abo_cd ,
  bp.cur_rh_cd ,
  de.cur_avail_qty ,
  per.name_full_formatted "#########################" ,
  n_f_f = decode (per.name_full_formatted ,per.name_full_formatted ,fillstring (20 ," " ) )
  "####################" ,
  alias = decode (ea.seq ,"Y" ,"N" )
  FROM (dummyt d WITH seq = value (nproductcount ) ),
   (product pr ),
   (product_event pe ),
   (dummyt d4 WITH seq = 1 ),
   (person per ),
   (dummyt d5 WITH seq = 1 ),
   (encntr_alias ea ),
   (dummyt d1 WITH seq = 1 ),
   (blood_product bp ),
   (derivative de )
  PLAN (d
   WHERE (nproductcount > 0 ) )
   JOIN (pr
   WHERE (pr.product_id = product->product_list[d.seq ].product_id ) )
   JOIN (pe
   WHERE (pr.product_id = pe.product_id )
   AND (pe.active_ind = 1 ) )
   JOIN (d4
   WHERE (d4.seq = 1 ) )
   JOIN (per
   WHERE (pe.person_id > 0 )
   AND (pe.person_id = per.person_id ) )
   JOIN (d5
   WHERE (d5.seq = 1 ) )
   JOIN (ea
   WHERE (pe.encntr_id > 0 )
   AND (ea.encntr_id = pe.encntr_id )
   AND (ea.encntr_alias_type_cd = mrn_code )
   AND (ea.active_ind = 1 ) )
   JOIN (d1
   WHERE (d1.seq = 1 ) )
   JOIN (((bp
   WHERE (pr.product_id = bp.product_id ) )
   ) ORJOIN ((de
   WHERE (pr.product_id = de.product_id ) )
   ))
  ORDER BY product_class_display ,
   product_cat_display ,
   product_display ,
   cnvtdatetime (pr.cur_expire_dt_tm ) ,
   pr.product_id ,
   pr.product_nbr ,
   pr.product_sub_nbr ,
   event_type_display
  HEAD REPORT
   new_report = "Y" ,
   product_cd_hd = 0.0 ,
   select_ok_ind = 0 ,
   mrn = fillstring (20 ," " )
  HEAD PAGE
   new_page = "Y" ,
   row 0 ,
   CALL center (captions->rpt_title ,1 ,125 ) ,
   col 104 ,
   captions->rpt_time ,
   col 118 ,
   curtime "@TIMENOSECONDS;;M" ,
   row + 1 ,
   col 104 ,
   captions->rpt_as_of_date ,
   col 118 ,
   curdate "@DATECONDENSED;;d" ,
   row + 1 ,
   col 104 ,
   captions->user ,
   col 111 ,
   reportbyusername "###############;R" ,
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
   ,row + 1 ,
   col 1 ,
   captions->blood_bank_owner ,
   col 19 ,
   cur_owner_area_disp ,
   row + 1 ,
   col 1 ,
   captions->inventory_area ,
   col 17 ,
   cur_inv_area_disp ,
   row + 2 ,
   col 4 ,
   captions->product_class ,
   col 22 ,
   product_class_display ,
   beg_dt_tm = cnvtdatetime (begin_date_time ) ,
   row + 1 ,
   col 4 ,
   captions->product_category ,
   col 22 ,
   product_cat_display ,
   end_dt_tm = cnvtdatetime (end_date_time ) ,
   row + 2 ,
   col 20 ,
   captions->begin_exp_date ,
   col 47 ,
   beg_dt_tm "@DATETIMECONDENSED;;d" ,
   col 72 ,
   captions->ending_exp_date ,
   col 96 ,
   end_dt_tm "@DATETIMECONDENSED;;d" ,
   row + 2 ,
   CALL center (captions->expire ,59 ,70 ) ,
   row + 1 ,
   CALL center (captions->prod_number ,1 ,25 ) ,
   col 27 ,
   captions->prod_type ,
   CALL center (captions->aborh ,40 ,52 ) ,
   col 54 ,
   captions->quantity ,
   CALL center (captions->date_time ,59 ,70 ) ,
   CALL center (captions->status ,72 ,84 ) ,
   CALL center (captions->name ,86 ,105 ) ,
   CALL center (captions->mrn ,107 ,125 ) ,
   row + 1 ,
   col 1 ,
   "-------------------------" ,
   col 27 ,
   "------------" ,
   col 40 ,
   "-------------" ,
   col 54 ,
   "----" ,
   col 59 ,
   "------------" ,
   col 72 ,
   "-------------" ,
   col 86 ,
   "--------------------" ,
   col 107 ,
   "-------------------" ,
   row + 1
  HEAD product_cat_display
   IF ((new_report = "Y" ) ) new_report = "N"
   ELSE
    BREAK
   ENDIF
  HEAD pr.product_id
   new_prod_id = "Y"
  DETAIL
   IF ((new_page != "Y" ) ) row + 1 ,
    IF ((row > 56 ) )
     BREAK
    ENDIF
   ENDIF
   ,
   IF ((pr.product_cd != product_cd_hd ) ) product_cd_hd = pr.product_cd
   ENDIF
   ,new_page = "N" ,
   IF ((new_prod_id = "Y" ) ) new_prod_id = "N" ,
    IF ((pr.product_sub_nbr > " " ) ) prod_nbr_display = concat (trim (bp.supplier_prefix ) ,trim (pr
       .product_nbr ) ," " ,trim (pr.product_sub_nbr ) )
    ELSE prod_nbr_display = concat (trim (bp.supplier_prefix ) ,trim (pr.product_nbr ) )
    ENDIF
    ,col 1 ,prod_nbr_display "#########################" ,col 27 ,product_display "############" ,
    IF ((d_flg = "BP" ) ) idx_a = 1 ,finish_flag = "N" ,
     WHILE ((idx_a <= aborh_index )
     AND (finish_flag = "N" ) )
      IF ((bp.cur_abo_cd = aborh->aborh_list[idx_a ].abo_code )
      AND (bp.cur_rh_cd = aborh->aborh_list[idx_a ].rh_code ) ) col 40 ,aborh->aborh_list[idx_a ].
       aborh_display "#############" ,finish_flag = "Y"
      ELSE idx_a = (idx_a + 1 )
      ENDIF
     ENDWHILE
    ENDIF
    ,
    IF ((d_flg = "DE" ) ) qty = trim (cnvtstring (de.cur_avail_qty ,4 ,0 ,r ) ) ,col 54 ,qty
    ENDIF
    ,dt_tm = cnvtdatetime (pr.cur_expire_dt_tm ) ,col 59 ,dt_tm "@DATETIMECONDENSED;;d" ,col 72 ,
    event_type_display ,
    IF ((n_f_f > " " ) ) col 86 ,n_f_f
    ENDIF
    ,
    IF ((alias = "Y" ) ) mrn = cnvtalias (ea.alias ,ea.alias_pool_cd ) ,col 107 ,mrn
     "###################"
    ELSE
     IF ((pe.person_id != null )
     AND (pe.person_id > 0 ) ) col 107 ,captions->not_on_file
     ENDIF
    ENDIF
   ELSE col 72 ,event_type_display ,
    IF ((n_f_f > " " ) ) col 86 ,n_f_f
    ENDIF
    ,
    IF ((alias = "Y" ) ) mrn = cnvtalias (ea.alias ,ea.alias_pool_cd ) ,col 107 ,mrn
     "###################"
    ELSE
     IF ((pe.person_id != null )
     AND (pe.person_id > 0 ) ) col 107 ,captions->not_on_file
     ENDIF
    ENDIF
   ENDIF
  FOOT  pr.product_id
   row + 1 ,
   IF ((row > 56 ) )
    BREAK
   ENDIF
  FOOT PAGE
   row 57 ,
   col 1 ,
   line ,
   row + 1 ,
   col 1 ,
   captions->rpt_id ,
   col 58 ,
   captions->rpt_page ,
   col 64 ,
   curpage "###" ,
   col 100 ,
   captions->printed ,
   col 110 ,
   curdate "@DATECONDENSED;;d" ,
   col 120 ,
   curtime "@TIMENOSECONDS;;M"
  FOOT REPORT
   row 60 ,
   CALL center (captions->end_of_report ,1 ,125 ) ,
   select_ok_ind = 1
  WITH nocounter ,nullreport ,maxrow = 61 ,dontcare (per ) ,dontcare (ea ) ,compress ,nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt + 1 )
 SET stat = alterlist (reply->rpt_list ,rpt_cnt )
 SET reply->rpt_list[rpt_cnt ].rpt_filename = cpm_cfn_info->file_name_path
 IF ((trim (request->batch_selection ) > "" ) )
  SET spool value (reply->rpt_list[rpt_cnt ].rpt_filename ) value (request->output_dist )
  SET reply->status_data.status = "S"
 ENDIF
 IF ((select_ok_ind = 1 ) )
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status = "F" ) )
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE SET product
END GO


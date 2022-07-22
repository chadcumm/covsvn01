DROP PROGRAM wh_psg_demographics :dba GO
CREATE PROGRAM wh_psg_demographics :dba
 IF (NOT (validate (rhead ,0 ) ) )
  SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
  SET rhead_colors1 = "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;"
  SET rhead_colors2 = "\red99\green99\blue99;\red22\green107\blue178;"
  SET rhead_colors3 = "\red0\green0\blue255;\red123\green193\blue67;\red255\green0\blue0;}"
  SET reol = "\par "
  SET rtab = "\tab "
  SET wr = "\plain \f0 \fs16 \cb2 "
  SET wr11 = "\plain \f0 \fs11 \cb2 "
  SET wr18 = "\plain \f0 \fs18 \cb2 "
  SET wr20 = "\plain \f0 \fs20 \cb2 "
  SET wu = "\plain \f0 \fs16 \ul \cb2 "
  SET wb = "\plain \f0 \fs16 \b \cb2 "
  SET wbu = "\plain \f0 \fs16 \b \ul \cb2 "
  SET wi = "\plain \f0 \fs16 \i \cb2 "
  SET ws = "\plain \f0 \fs16 \strike \cb2"
  SET wb2 = "\plain \f0 \fs18 \b \cb2 "
  SET wb18 = "\plain \f0 \fs18 \b \cb2 "
  SET wb20 = "\plain \f0 \fs20 \b \cb2 "
  SET rsechead = "\plain \f0 \fs28 \b \ul \cb2 "
  SET rsubsechead = "\plain \f0 \fs22 \b \cb2 "
  SET rsecline = "\plain \f0 \fs20 \b \cb2 "
  SET hi = "\pard\fi-2340\li2340 "
  SET rtfeof = "}"
  SET wbuf26 = "\plain \f0 \fs26 \b \ul \cb2 "
  SET wbuf30 = "\plain \f0 \fs30 \b \ul \cb2 "
  SET rpard = "\pard "
  SET rtitle = "\plain \f0 \fs36 \b \cb2 "
  SET rpatname = "\plain \f0 \fs38 \b \cb2 "
  SET rtabstop1 = "\tx300"
  SET rtabstopnd = "\tx400"
  SET wsd = "\plain \f0 \fs13 \cb2 "
  SET wsb = "\plain \f0 \fs13 \b \cb2 "
  SET wrs = "\plain \f0 \fs14 \cb2 "
  SET wbs = "\plain \f0 \fs14 \b \cb2 "
  DECLARE snot_documented = vc WITH public ,constant ("--" )
  SET color0 = "\cf0 "
  SET colorgrey = "\cf3 "
  SET colornavy = "\cf4 "
  SET colorblue = "\cf5 "
  SET colorgreen = "\cf6 "
  SET colorred = "\cf7 "
  SET row_start = "\trowd"
  SET row_end = "\row"
  SET cell_start = "\intbl "
  SET cell_end = "\cell"
  SET cell_text_center = "\qc "
  SET cell_text_left = "\ql "
  SET cell_border_top = "\clbrdrt\brdrt\brdrw1"
  SET cell_border_left = "\clbrdrl\brdrl\brdrw1"
  SET cell_border_bottom = "\clbrdrb\brdrb\brdrw1"
  SET cell_border_right = "\clbrdrr\brdrr\brdrw1"
  SET cell_border_top_left = "\clbrdrt\brdrt\brdrw1\clbrdrl\brdrl\brdrw1"
  SET block_start = "{"
  SET block_end = "}"
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
 IF (NOT (validate (i18nhandle ) ) )
  DECLARE i18nhandle = i4 WITH protect ,noconstant (0 )
 ENDIF
 SET stat = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 DECLARE stand_alone_ind = i4 WITH protect ,noconstant (0 )
 IF (NOT (validate (request->person[1 ].pregnancy_list ) ) )
  SET stand_alone_ind = 1
  DECLARE getpregnancyinfo ((personid = f8 ) ) = null WITH public
  DECLARE getformattedvalue ((val = vc ) ) = vc WITH public
  FREE RECORD preg_info_reply
  RECORD preg_info_reply (
    1 person_cnt = i2
    1 person [1 ]
      2 person_id = f8
      2 person_name = vc
      2 person_dob = vc
      2 pregnancy_list [* ]
        3 pregnancy_id = f8
        3 onset_dt_tm = dq8
        3 onset_date_formatted = vc
        3 problem_id = f8
    1 visit_cnt = i2
    1 visit [1 ]
      2 encntr_id = f8
    1 prsnl_cnt = i2
  )
  SUBROUTINE  getformattedvalue (val )
   DECLARE decimal_point = vc WITH private ,noconstant ("" )
   DECLARE formatted_val = vc WITH private ,noconstant (val )
   SET decimal_point = curlocale ("DECIMAL" )
   IF (isnumeric (val ) )
    IF (findstring ("." ,val ) )
     SET formatted_val = replace (val ,"." ,decimal_point ,0 )
    ENDIF
   ENDIF
   RETURN (nullterm (formatted_val ) )
  END ;Subroutine
  SUBROUTINE  getpregnancyinfo (personid )
   SELECT INTO "nl:"
    temp_dt_tm =
    IF ((pr.onset_dt_tm != null ) ) pr.onset_dt_tm
    ELSE pr.beg_effective_dt_tm
    ENDIF
    FROM (pregnancy_instance pi ),
     (problem pr ),
     (person p )
    PLAN (pi
     WHERE (pi.person_id = personid )
     AND (pi.active_ind = 1 )
     AND (pi.historical_ind = 0 )
     AND (pi.preg_end_dt_tm = cnvtdatetime ("31-DEC-2100" ) ) )
     JOIN (pr
     WHERE (pr.problem_id = pi.problem_id )
     AND (pr.active_ind = 1 ) )
     JOIN (p
     WHERE (p.person_id = pi.person_id ) )
    ORDER BY temp_dt_tm DESC
    HEAD REPORT
     stat = alterlist (preg_info_reply->pregnancy_list ,1 ) ,
     preg_info_reply->person[1 ].pregnancy_list[1 ].onset_date_formatted = format (temp_dt_tm ,
      "YYYYMMDD;;d" ) ,
     preg_info_reply->person[1 ].pregnancy_list[1 ].onset_dt_tm = temp_dt_tm ,
     preg_info_reply->person[1 ].pregnancy_list[1 ].problem_id = pi.problem_id ,
     preg_info_reply->person[1 ].pregnancy_list[1 ].pregnancy_id = pi.pregnancy_id ,
     preg_info_reply->person[1 ].person_name = trim (substring (1 ,50 ,p.name_full_formatted ) ) ,
     preg_info_reply->person[1 ].person_dob = format (p.birth_dt_tm ,"MM/DD/YY;;d" ) ,
     preg_info_reply->person[1 ].person_id = personid
    WITH nocounter
   ;end select
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echorecord (preg_info_reply )
   ENDIF
  END ;Subroutine
 ENDIF
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echo (build ("stand_alone_ind:" ,stand_alone_ind ) )
 ENDIF
 DECLARE whorgsecpref = i2 WITH protect ,noconstant (0 )
 DECLARE prsnl_override_flag = i2 WITH protect ,noconstant (0 )
 DECLARE preg_org_sec_ind = i4 WITH noconstant (0 ) ,public
 DECLARE os_idx = i4 WITH noconstant (0 )
 IF ((validate (antepartum_run_ind ) = 0 ) )
  DECLARE antepartum_run_ind = i4 WITH public ,noconstant (0 )
 ENDIF
 IF (NOT (validate (whsecuritydisclaim ) ) )
  DECLARE whsecuritydisclaim = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap99" ,
    "(Report contains only data from encounters at associated organizations)" ) )
 ENDIF
 IF (NOT (validate (preg_sec_orgs ) ) )
  FREE RECORD preg_sec_orgs
  RECORD preg_sec_orgs (
    1 qual [* ]
      2 org_id = f8
      2 confid_level = i4
  )
 ENDIF
 DECLARE getpersonneloverride ((person_id = f8 (val ) ) ,(prsnl_id = f8 (val ) ) ) = i2 WITH protect
 DECLARE getpreferences () = i2 WITH protect
 DECLARE getorgsecurity () = null WITH protect
 DECLARE loadorganizationsecuritylist () = null
 IF ((validate (honor_org_security_flag ) = 0 ) )
  DECLARE honor_org_security_flag = i2 WITH public ,noconstant (0 )
  SET whorgsecpref = getpreferences (null )
  CALL getorgsecurity (null )
  SET prsnl_override_flag = getpersonneloverride (request->person[1 ].person_id ,reqinfo->updt_id )
  IF ((prsnl_override_flag = 0 ) )
   IF ((preg_org_sec_ind = 1 )
   AND (whorgsecpref = 1 ) )
    SET honor_org_security_flag = 1
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE  getpersonneloverride (person_id ,prsnl_id )
  CALL echo (build ("person_id=" ,person_id ) )
  CALL echo (build ("prsnl_id=" ,prsnl_id ) )
  DECLARE override_ind = i2 WITH protect ,noconstant (0 )
  IF ((((person_id <= 0.0 ) ) OR ((prsnl_id <= 0.0 ) )) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (person_prsnl_reltn ppr ),
    (code_value_extension cve )
   PLAN (ppr
    WHERE (ppr.prsnl_person_id = prsnl_id )
    AND (ppr.active_ind = 1 )
    AND ((ppr.person_id + 0 ) = person_id )
    AND (ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (cve
    WHERE (cve.code_value = ppr.person_prsnl_r_cd )
    AND (cve.code_set = 331 )
    AND (((cve.field_value = "1" ) ) OR ((cve.field_value = "2" ) ))
    AND (cve.field_name = "Override" ) )
   DETAIL
    override_ind = 1
   WITH nocounter
  ;end select
  RETURN (override_ind )
 END ;Subroutine
 SUBROUTINE  getpreferences (null )
  DECLARE powerchart_app_number = i4 WITH protect ,constant (600005 )
  DECLARE spreferencename = vc WITH protect ,constant ("PREGNANCY_SMART_TMPLT_ORG_SEC" )
  DECLARE prefvalue = vc WITH noconstant ("0" ) ,protect
  SELECT INTO "nl:"
   FROM (app_prefs ap ),
    (name_value_prefs nvp )
   PLAN (ap
    WHERE (ap.prsnl_id = 0.0 )
    AND (ap.position_cd = 0.0 )
    AND (ap.application_number = powerchart_app_number ) )
    JOIN (nvp
    WHERE (nvp.parent_entity_name = "APP_PREFS" )
    AND (nvp.parent_entity_id = ap.app_prefs_id )
    AND (trim (nvp.pvc_name ,3 ) = cnvtupper (spreferencename ) ) )
   DETAIL
    prefvalue = nvp.pvc_value
   WITH nocounter
  ;end select
  RETURN (cnvtint (prefvalue ) )
 END ;Subroutine
 SUBROUTINE  getorgsecurity (null )
  SELECT INTO "nl:"
   FROM (dm_info d1 )
   WHERE (d1.info_domain = "SECURITY" )
   AND (d1.info_name = "SEC_ORG_RELTN" )
   AND (d1.info_number = 1 )
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo (build ("org_sec_ind=" ,preg_org_sec_ind ) )
  IF ((preg_org_sec_ind = 1 ) )
   CALL loadorganizationsecuritylist (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  loadorganizationsecuritylist (null )
  DECLARE org_cnt = i2 WITH noconstant (0 )
  DECLARE stat = i2 WITH protect ,noconstant (0 )
  IF ((validate (sac_org ) = 1 ) )
   FREE RECORD sac_org
  ENDIF
  RECORD sac_org (
    1 organizations [* ]
      2 organization_id = f8
      2 confid_cd = f8
      2 confid_level = i4
  )
  EXECUTE secrtl
  DECLARE orgcnt = i4 WITH protected ,noconstant (0 )
  DECLARE secstat = i2
  DECLARE logontype = i4 WITH protect ,noconstant (- (1 ) )
  DECLARE confid_cd = f8 WITH protected ,noconstant (0.0 )
  DECLARE role_profile_org_id = f8 WITH protected ,noconstant (0.0 )
  CALL uar_secgetclientlogontype (logontype )
  CALL echo (build ("logontype:" ,logontype ) )
  IF ((logontype = 0 ) )
   SELECT DISTINCT INTO "nl:"
    FROM (prsnl_org_reltn por ),
     (organization o ),
     (prsnl p )
    PLAN (p
     WHERE (p.person_id = reqinfo->updt_id ) )
     JOIN (por
     WHERE (por.person_id = p.person_id )
     AND (por.active_ind = 1 )
     AND (por.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (por.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
     JOIN (o
     WHERE (por.organization_id = o.organization_id ) )
    DETAIL
     orgcnt = (orgcnt + 1 ) ,
     IF ((mod (orgcnt ,10 ) = 1 ) ) secstat = alterlist (sac_org->organizations ,(orgcnt + 9 ) )
     ENDIF
     ,sac_org->organizations[orgcnt ].organization_id = por.organization_id ,
     sac_org->organizations[orgcnt ].confid_cd = por.confid_level_cd ,
     confid_cd = uar_get_collation_seq (por.confid_level_cd ) ,
     sac_org->organizations[orgcnt ].confid_level =
     IF ((confid_cd > 0 ) ) confid_cd
     ELSE 0
     ENDIF
    WITH nocounter
   ;end select
   SET secstat = alterlist (sac_org->organizations ,orgcnt )
  ENDIF
  IF ((logontype = 1 ) )
   CALL echo ("entered into NHS logon" )
   DECLARE hprop = i4 WITH protect ,noconstant (0 )
   DECLARE tmpstat = i2
   DECLARE spropname = vc
   DECLARE sroleprofile = vc
   SET hprop = uar_srvcreateproperty ()
   SET tmpstat = uar_secgetclientattributesext (5 ,hprop )
   SET spropname = uar_srvfirstproperty (hprop )
   SET sroleprofile = uar_srvgetpropertyptr (hprop ,nullterm (spropname ) )
   CALL echo (sroleprofile )
   DECLARE nhstrustchild_org_org_reltn_cd = f8
   SET nhstrustchild_org_org_reltn_cd = uar_get_code_by ("MEANING" ,369 ,"NHSTRUSTCHLD" )
   SELECT INTO "nl:"
    FROM (prsnl_org_reltn_type prt ),
     (prsnl_org_reltn por ),
     (organization o )
    PLAN (prt
     WHERE (prt.role_profile = sroleprofile )
     AND (prt.active_ind = 1 )
     AND (prt.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (prt.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
     JOIN (o
     WHERE (o.organization_id = prt.organization_id ) )
     JOIN (por
     WHERE (outerjoin (prt.organization_id ) = por.organization_id )
     AND (por.person_id = outerjoin (prt.prsnl_id ) )
     AND (por.active_ind = outerjoin (1 ) )
     AND (por.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (por.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
    ORDER BY por.prsnl_org_reltn_id
    DETAIL
     orgcnt = 1 ,
     stat = alterlist (sac_org->organizations ,1 ) ,
     sac_org->organizations[1 ].organization_id = prt.organization_id ,
     role_profile_org_id = sac_org->organizations[orgcnt ].organization_id ,
     sac_org->organizations[1 ].confid_cd = por.confid_level_cd ,
     confid_cd = uar_get_collation_seq (por.confid_level_cd ) ,
     sac_org->organizations[1 ].confid_level =
     IF ((confid_cd > 0 ) ) confid_cd
     ELSE 0
     ENDIF
    WITH maxrec = 1
   ;end select
   SELECT INTO "nl:"
    FROM (prsnl_org_reltn por )
    PLAN (por
     WHERE (por.person_id = reqinfo->updt_id )
     AND (por.active_ind = 1 )
     AND (por.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (por.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    HEAD REPORT
     IF ((orgcnt > 0 ) ) stat = alterlist (sac_org->organizations ,10 )
     ENDIF
    DETAIL
     IF ((role_profile_org_id != por.organization_id ) ) orgcnt = (orgcnt + 1 ) ,
      IF ((mod (orgcnt ,10 ) = 1 ) ) stat = alterlist (sac_org->organizations ,(orgcnt + 9 ) )
      ENDIF
      ,sac_org->organizations[orgcnt ].organization_id = por.organization_id ,sac_org->organizations[
      orgcnt ].confid_cd = por.confid_level_cd ,confid_cd = uar_get_collation_seq (por
       .confid_level_cd ) ,sac_org->organizations[orgcnt ].confid_level =
      IF ((confid_cd > 0 ) ) confid_cd
      ELSE 0
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist (sac_org->organizations ,orgcnt )
    WITH nocounter
   ;end select
   CALL uar_srvdestroyhandle (hprop )
  ENDIF
  SET org_cnt = size (sac_org->organizations ,5 )
  CALL echo (build ("org_cnt: " ,org_cnt ) )
  SET stat = alterlist (preg_sec_orgs->qual ,(org_cnt + 1 ) )
  FOR (count = 1 TO org_cnt )
   SET preg_sec_orgs->qual[count ].org_id = sac_org->organizations[count ].organization_id
   SET preg_sec_orgs->qual[count ].confid_level = sac_org->organizations[count ].confid_level
  ENDFOR
  SET preg_sec_orgs->qual[(org_cnt + 1 ) ].org_id = 0.00
  SET preg_sec_orgs->qual[(org_cnt + 1 ) ].confid_level = 0
  CALL echorecord (preg_sec_orgs )
 END ;Subroutine
 FREE RECORD pt_info
 RECORD pt_info (
   1 name_concat = vc
   1 dob = vc
   1 age = vc
   1 add_concat = vc
   1 phone_str = vc
   1 phone = vc
   1 bus_phone = vc
   1 mobile_phone = vc
   1 pcp_name = vc
   1 support = vc
   1 support_relation = vc
   1 delivery_loc = vc
   1 ethnicity = vc
   1 newborn_phys = vc
   1 languages = vc
   1 religious_pref = vc
   1 marital_status = vc
   1 ob_providers = vc
   1 mrn = vc
   1 race = vc
   1 referred_by = vc
   1 partner_name = vc
   1 partner_phone = vc
   1 planned_preg = vc
   1 prenatal_document = vc
   1 tubal_consent = vc
   1 occupation = vc
   1 hp_cnt = i2
   1 hp_qual [* ]
     2 hp_id = f8
     2 hp_name = vc
     2 hp_address = vc
     2 hp_phone = vc
     2 group_num = vc
     2 member_num = vc
     2 deduct_amt = vc
     2 plan_type = vc
 )
 DECLARE auth = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE altered = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) )
 DECLARE modified = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) )
 DECLARE dhome_address = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,212 ,"HOME" ) )
 DECLARE dhome_phone = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,43 ,"HOME" ) )
 DECLARE dmobile_phone = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,43 ,"CELL" ) )
 DECLARE dbus_phone = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,43 ,"BUSINESS" ) )
 DECLARE dbus_address = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,212 ,"BUSINESS" ) )
 DECLARE dfreetext_phone = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,281 ,"FREETEXT" ) )
 DECLARE dobprovider = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,331 ,"OBGYN" ) )
 DECLARE dpcp = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,331 ,"PCP" ) )
 DECLARE drefprovider = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,333 ,"REFERDOC" ) )
 DECLARE dmrn = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,4 ,"MRN" ) )
 DECLARE dspouse = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,40 ,"SPOUSE" ) )
 DECLARE dmarried = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,38 ,"MARRIED" ) )
 DECLARE demployer_org_reltn = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,338 ,"EMPLOYER"
   ) )
 DECLARE newborn_phys = vc WITH public ,constant ("CERNER!D6247C7E-22A4-465F-8C16-98832D8A3968" )
 DECLARE support_person_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12703" ) )
 DECLARE support_person_relation_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!12722"
   ) )
 DECLARE delivery_loc_es = vc WITH public ,constant ("Delivery Location" )
 DECLARE planned_preg_es = vc WITH public ,constant ("Planned/Unplanned Pregnancy" )
 DECLARE prenatal_doc_es = vc WITH public ,constant ("Date Prenatal Record Sent to Hospital" )
 DECLARE tubal_consent_es = vc WITH public ,constant ("Date Consent Signed for Tubal Ligation" )
 DECLARE snot_documented_review = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap1" ,
   "Not located. Please review with patient." ) )
 DECLARE snot_recorded_review = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap2" ,
   "Not explicitly recorded. May be noted in prenatal encounter section below." ) )
 DECLARE snot_recorded_hp = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap3" ,
   "Health plan name not recorded" ) )
 DECLARE sphonework = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap4" ," (Work)" )
  )
 DECLARE sphonehome = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap5" ," (Home)" )
  )
 DECLARE sphonemobile = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap6" ,
   " (Mobile)" ) )
 DECLARE sstate = vc WITH public ,noconstant ("" )
 DECLARE cdemodetails = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap7" ,
   "Registration and Pregnancy Information" ) )
 DECLARE crace = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap8" ,"Race:" ) )
 DECLARE cethnic = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap9" ,"Ethnicity:" )
  )
 DECLARE cmaritialstat = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap10" ,
   "Marital Status:" ) )
 DECLARE clanguages = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap11" ,
   "Language(s):" ) )
 DECLARE creligiouspref = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap12" ,
   "Religious Preference(s):" ) )
 DECLARE coccedu = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap13" ,
   "Occupation/Education:" ) )
 DECLARE coccedustr = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap14" ,
   "See social history above if documented." ) )
 DECLARE caddresssection = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap15" ,
   "Address, Phone, and Health Plans" ) )
 DECLARE caddress = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap16" ,
   "Home Address:" ) )
 DECLARE cphone = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap17" ,"Phone:" ) )
 DECLARE chealthplan = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap18" ,
   "Health Plans" ) )
 DECLARE chealthplanmember = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap19" ,
   "Member/Group:" ) )
 DECLARE chealthplanaddress = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap20" ,
   "Address:" ) )
 DECLARE cdeductable = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap21" ,
   "Deductible: $" ) )
 DECLARE chptype = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap22" ,"Type:" ) )
 DECLARE cobinfo = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap23" ,
   "General Prenatal Information" ) )
 DECLARE cprenatalloc = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap24" ,
   "Prenatal Care Location:" ) )
 DECLARE cattending = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap25" ,
   "Attending:" ) )
 DECLARE chospital = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap26" ,
   "Delivery Center/Hospital Information:" ) )
 DECLARE cnewbornphys = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap27" ,
   "Newborn Provider Information:" ) )
 DECLARE creffered = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap28" ,
   "Referring Provider Information:" ) )
 DECLARE cpcp = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap29" ,
   "Primary Provider Information:" ) )
 DECLARE cpartnername = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap31" ,
   "Husband/Partner Information:" ) )
 DECLARE csupport = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap32" ,
   "Support Person Information:" ) )
 DECLARE cplannedpreg = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap33" ,
   "Planned/Unplanned Pregnancy:" ) )
 DECLARE cobproviders = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap34" ,
   "OB Provider(s) Information:" ) )
 DECLARE cadditionalinfo = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap35" ,
   "**See below for detailed information for all visits and information." ) )
 DECLARE cprimaryobpracloc = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap36" ,
   "Primary OB Physician Practice Location:" ) )
 DECLARE cprenataldoc = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap37" ,
   "Date Prenatal Record Sent to Hospital:" ) )
 DECLARE ctubalconsent = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap38" ,
   "Date Consent Signed for Tubal Ligation:" ) )
 SET fmtphone = fillstring (22 ," " )
 SET tempphone = fillstring (22 ," " )
 SET pt_info->name_concat = snot_documented
 SET pt_info->dob = snot_documented
 SET pt_info->age = snot_documented
 SET pt_info->add_concat = snot_documented
 SET pt_info->phone_str = snot_documented
 SET pt_info->phone = snot_documented
 SET pt_info->bus_phone = snot_documented
 SET pt_info->mobile_phone = snot_documented
 SET pt_info->pcp_name = snot_documented
 SET pt_info->support = snot_documented
 SET pt_info->support_relation = " "
 SET pt_info->delivery_loc = snot_documented
 SET pt_info->ethnicity = snot_documented
 SET pt_info->newborn_phys = snot_documented
 SET pt_info->languages = snot_documented
 SET pt_info->religious_pref = snot_documented
 SET pt_info->marital_status = snot_documented
 SET pt_info->mrn = snot_documented
 SET pt_info->race = snot_documented
 SET pt_info->referred_by = snot_documented
 SET pt_info->partner_name = snot_documented
 SET pt_info->partner_phone = snot_documented
 SET pt_info->planned_preg = snot_documented
 SET pt_info->prenatal_document = snot_documented
 SET pt_info->tubal_consent = snot_documented
 SET pt_info->ob_providers = snot_recorded_review
 SET pt_info->occupation = coccedustr
 DECLARE onset_dt_tm = dq8 WITH protect
 IF ((stand_alone_ind = 1 ) )
  SET z = getpregnancyinfo (request->person[1 ].person_id )
  SET onset_dt_tm = preg_info_reply->person[1 ].pregnancy_list[1 ].onset_dt_tm
  SET reply->text = concat (reply->text ,rhead ,rhead_colors1 ,rhead_colors2 ,rhead_colors3 )
 ELSE
  SET onset_dt_tm = request->person[1 ].pregnancy_list[1 ].onset_dt_tm
 ENDIF
 SELECT
  IF ((honor_org_security_flag = 1 ) ) INTO "nl:"
   sstreet1 = trim (a.street_addr ) ,
   sstreet2 = trim (a.street_addr2 ) ,
   scity = trim (a.city ) ,
   szip = trim (a.zipcode ) ,
   sphone = trim (ph.phone_num )
   FROM (person_plan_reltn ppr ),
    (health_plan hp ),
    (address a ),
    (phone ph ),
    (organization o )
   PLAN (ppr
    WHERE (ppr.person_id = request->person[1 ].person_id )
    AND (ppr.active_ind = 1 )
    AND (ppr.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (hp
    WHERE (ppr.health_plan_id = hp.health_plan_id ) )
    JOIN (a
    WHERE (a.parent_entity_name = outerjoin ("HEALTH_PLAN" ) )
    AND (a.parent_entity_id = outerjoin (hp.health_plan_id ) )
    AND (a.address_type_cd = outerjoin (dbus_address ) )
    AND (a.active_ind = outerjoin (1 ) )
    AND (a.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (a.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
    JOIN (ph
    WHERE (ph.parent_entity_name = outerjoin ("HEALTH_PLAN" ) )
    AND (ph.parent_entity_id = outerjoin (hp.health_plan_id ) )
    AND (ph.phone_type_cd = outerjoin (dbus_phone ) )
    AND (ph.active_ind = outerjoin (1 ) )
    AND (ph.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (ph.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
    JOIN (o
    WHERE (ppr.organization_id = o.organization_id )
    AND expand (os_idx ,1 ,size (preg_sec_orgs->qual ,5 ) ,ppr.organization_id ,preg_sec_orgs->qual[
     os_idx ].org_id ) )
  ELSE INTO "nl:"
   sstreet1 = trim (a.street_addr ) ,
   sstreet2 = trim (a.street_addr2 ) ,
   scity = trim (a.city ) ,
   szip = trim (a.zipcode ) ,
   sphone = trim (ph.phone_num )
   FROM (person_plan_reltn ppr ),
    (health_plan hp ),
    (address a ),
    (phone ph )
   PLAN (ppr
    WHERE (ppr.person_id = request->person[1 ].person_id )
    AND (ppr.active_ind = 1 )
    AND (ppr.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (hp
    WHERE (ppr.health_plan_id = hp.health_plan_id ) )
    JOIN (a
    WHERE (a.parent_entity_name = outerjoin ("HEALTH_PLAN" ) )
    AND (a.parent_entity_id = outerjoin (hp.health_plan_id ) )
    AND (a.address_type_cd = outerjoin (dbus_address ) )
    AND (a.active_ind = outerjoin (1 ) )
    AND (a.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (a.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
    JOIN (ph
    WHERE (ph.parent_entity_name = outerjoin ("HEALTH_PLAN" ) )
    AND (ph.parent_entity_id = outerjoin (hp.health_plan_id ) )
    AND (ph.phone_type_cd = outerjoin (dbus_phone ) )
    AND (ph.active_ind = outerjoin (1 ) )
    AND (ph.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (ph.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
  ENDIF
  ORDER BY ppr.priority_seq
  HEAD REPORT
   hpcnt = 0
  DETAIL
   hpcnt = (hpcnt + 1 ) ,
   stat = alterlist (pt_info->hp_qual ,hpcnt ) ,
   IF ((hp.plan_name != null ) ) pt_info->hp_qual[hpcnt ].hp_name = trim (hp.plan_name )
   ELSE pt_info->hp_qual[hpcnt ].hp_name = snot_recorded_hp
   ENDIF
   ,pt_info->hp_qual[hpcnt ].group_num = trim (ppr.member_nbr ) ,
   IF ((ppr.member_nbr != null ) ) pt_info->hp_qual[hpcnt ].member_num = trim (ppr.member_nbr )
   ELSE pt_info->hp_qual[hpcnt ].member_num = snot_documented
   ENDIF
   ,
   IF ((ppr.deduct_amt != null ) ) pt_info->hp_qual[hpcnt ].deduct_amt = trim (cnvtstring (ppr
      .deduct_amt ,6 ,2 ) ,3 )
   ELSE pt_info->hp_qual[hpcnt ].deduct_amt = snot_documented
   ENDIF
   ,
   IF ((hp.plan_type_cd > 0 ) ) pt_info->hp_qual[hpcnt ].plan_type = trim (uar_get_code_display (hp
      .plan_type_cd ) )
   ELSE pt_info->hp_qual[hpcnt ].plan_type = snot_documented
   ENDIF
   ,pt_info->hp_qual[hpcnt ].hp_id = hp.health_plan_id ,
   IF ((a.state_cd > 0 ) ) sstate = uar_get_code_display (a.state_cd )
   ELSE sstate = trim (a.state )
   ENDIF
   ,
   IF ((a.address_id > 0 ) )
    IF ((size (trim (sstreet2 ) ) > 0 ) ) pt_info->hp_qual[hpcnt ].hp_address = concat (trim (
       sstreet1 ) ,", " ,trim (sstreet2 ) ,", " ,trim (scity ) ,", " ,trim (sstate ) ," " ,trim (
       szip ) )
    ELSE pt_info->hp_qual[hpcnt ].hp_address = concat (trim (sstreet1 ) ,", " ,trim (scity ) ,", " ,
      trim (sstate ) ," " ,trim (szip ) )
    ENDIF
   ELSE pt_info->hp_qual[hpcnt ].hp_address = snot_documented
   ENDIF
   ,
   IF ((size (trim (ph.phone_num ) ) > 0 ) ) tempphone = fillstring (22 ," " ) ,tempphone =
    cnvtalphanum (ph.phone_num ) ,
    IF ((tempphone != ph.phone_num ) ) fmtphone = ph.phone_num
    ELSE
     IF ((ph.phone_format_cd > 0 ) ) fmtphone = cnvtphone (trim (ph.phone_num ) ,ph.phone_format_cd
       )
     ELSEIF ((size (tempphone ) < 8 ) ) fmtphone = format (trim (ph.phone_num ) ,"###-####" )
     ELSE fmtphone = format (trim (ph.phone_num ) ,"(###) ###-####" )
     ENDIF
    ENDIF
    ,fmtphone = cnvtphone (trim (cnvtalphanum (ph.phone_num ) ) ,ph.phone_format_cd ) ,
    IF ((fmtphone <= " " ) ) fmtphone = ph.phone_num
    ENDIF
    ,
    IF ((ph.extension > " " ) ) fmtphone = concat (trim (fmtphone ) ," x" ,ph.extension )
    ENDIF
    ,pt_info->hp_qual[hpcnt ].hp_phone = trim (fmtphone )
   ELSE pt_info->hp_qual[hpcnt ].hp_phone = snot_documented
   ENDIF
  FOOT REPORT
   pt_info->hp_cnt = hpcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sdob = format (p.birth_dt_tm ,"@SHORTDATE4YR" ) ,
  age = cnvtage (p.birth_dt_tm ) ,
  sname_first = trim (p.name_first ) ,
  sname_last = trim (p.name_last ) ,
  sstreet1 = trim (a.street_addr ) ,
  sstreet2 = trim (a.street_addr2 ) ,
  scity = trim (a.city ) ,
  szip = trim (a.zipcode ) ,
  sphone = trim (ph.phone_num ) ,
  smobilephone = trim (ph1.phone_num ) ,
  sbusphone = trim (ph2.phone_num )
  FROM (person p ),
   (dummyt d1 ),
   (address a ),
   (dummyt d2 ),
   (phone ph ),
   (dummyt d4 ),
   (phone ph1 ),
   (dummyt d5 ),
   (phone ph2 ),
   (dummyt d6 ),
   (person_alias pa )
  PLAN (p
   WHERE (p.person_id = request->person[1 ].person_id ) )
   JOIN (d1 )
   JOIN (a
   WHERE (a.parent_entity_id = p.person_id )
   AND (a.parent_entity_name = "PERSON" )
   AND (a.address_type_cd = dhome_address )
   AND (a.active_ind = 1 ) )
   JOIN (d2 )
   JOIN (ph
   WHERE (ph.parent_entity_id = p.person_id )
   AND (ph.parent_entity_name = "PERSON" )
   AND (ph.phone_type_cd = dhome_phone )
   AND (ph.active_ind = 1 ) )
   JOIN (d4 )
   JOIN (ph1
   WHERE (ph1.parent_entity_id = p.person_id )
   AND (ph1.parent_entity_name = "PERSON" )
   AND (ph1.phone_type_cd = dmobile_phone )
   AND (ph1.active_ind = 1 ) )
   JOIN (d5 )
   JOIN (ph2
   WHERE (ph2.parent_entity_id = p.person_id )
   AND (ph2.parent_entity_name = "PERSON" )
   AND (ph2.phone_type_cd = dbus_phone )
   AND (ph2.active_ind = 1 ) )
   JOIN (d6 )
   JOIN (pa
   WHERE (p.person_id = pa.person_id )
   AND (pa.person_alias_type_cd = dmrn )
   AND (pa.active_ind = 1 )
   AND (pa.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
   AND (pa.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
  DETAIL
   pt_info->name_concat = concat (trim (sname_first ) ," " ,trim (sname_last ) ) ,
   IF ((p.birth_dt_tm > cnvtdatetime ("01-JAN-1800 00:00" ) ) ) pt_info->age = trim (age ,3 ) ,
    pt_info->dob = trim (sdob )
   ENDIF
   ,
   IF ((p.marital_type_cd > 0 ) ) pt_info->marital_status = trim (uar_get_code_display (p
      .marital_type_cd ) )
   ENDIF
   ,
   IF ((p.race_cd > 0 ) ) pt_info->race = trim (uar_get_code_display (p.race_cd ) )
   ENDIF
   ,
   IF ((p.ethnic_grp_cd > 0 ) ) pt_info->ethnicity = trim (uar_get_code_display (p.ethnic_grp_cd ) )
   ENDIF
   ,
   IF ((p.language_cd > 0 ) ) pt_info->languages = trim (uar_get_code_display (p.language_cd ) )
   ENDIF
   ,
   IF ((p.religion_cd > 0 ) ) pt_info->religious_pref = trim (uar_get_code_display (p.religion_cd )
     )
   ENDIF
   ,
   IF ((a.state_cd > 0 ) ) sstate = uar_get_code_display (a.state_cd )
   ELSE sstate = trim (a.state )
   ENDIF
   ,
   IF ((a.address_id > 0 ) )
    IF ((size (trim (sstreet2 ) ) > 0 ) ) pt_info->add_concat = concat (trim (sstreet1 ) ,", " ,trim
      (sstreet2 ) ,", " ,trim (scity ) ,", " ,trim (sstate ) ," " ,trim (szip ) )
    ELSE pt_info->add_concat = concat (trim (sstreet1 ) ,", " ,trim (scity ) ,", " ,trim (sstate ) ,
      " " ,trim (szip ) )
    ENDIF
   ENDIF
   ,
   IF ((size (trim (sphone ) ) > 0 ) ) tempphone = fillstring (22 ," " ) ,tempphone = cnvtalphanum (
     ph.phone_num ) ,
    IF ((tempphone != ph.phone_num ) ) fmtphone = ph.phone_num
    ELSE
     IF ((ph.phone_format_cd > 0 ) ) fmtphone = cnvtphone (trim (ph.phone_num ) ,ph.phone_format_cd
       )
     ELSEIF ((size (tempphone ) < 8 ) ) fmtphone = format (trim (ph.phone_num ) ,"###-####" )
     ELSE fmtphone = format (trim (ph.phone_num ) ,"(###) ###-####" )
     ENDIF
    ENDIF
    ,fmtphone = cnvtphone (trim (cnvtalphanum (ph.phone_num ) ) ,ph.phone_format_cd ) ,
    IF ((fmtphone <= " " ) ) fmtphone = ph.phone_num
    ENDIF
    ,
    IF ((ph.extension > " " ) ) fmtphone = concat (trim (fmtphone ) ," x" ,ph.extension )
    ENDIF
    ,pt_info->phone = concat (trim (fmtphone ) ,sphonehome )
   ENDIF
   ,
   IF ((size (trim (smobilephone ) ) > 0 ) ) tempphone = fillstring (22 ," " ) ,tempphone =
    cnvtalphanum (ph1.phone_num ) ,
    IF ((tempphone != ph1.phone_num ) ) fmtphone = ph1.phone_num
    ELSE
     IF ((ph1.phone_format_cd > 0 ) ) fmtphone = cnvtphone (trim (ph1.phone_num ) ,ph1
       .phone_format_cd )
     ELSEIF ((size (tempphone ) < 8 ) ) fmtphone = format (trim (ph1.phone_num ) ,"###-####" )
     ELSE fmtphone = format (trim (ph1.phone_num ) ,"(###) ###-####" )
     ENDIF
    ENDIF
    ,fmtphone = cnvtphone (trim (cnvtalphanum (ph1.phone_num ) ) ,ph1.phone_format_cd ) ,
    IF ((fmtphone <= " " ) ) fmtphone = ph1.phone_num
    ENDIF
    ,
    IF ((ph1.extension > " " ) ) fmtphone = concat (trim (fmtphone ) ," x" ,ph1.extension )
    ENDIF
    ,pt_info->mobile_phone = concat (trim (fmtphone ) ,sphonemobile )
   ENDIF
   ,
   IF ((size (trim (sbusphone ) ) > 0 ) ) tempphone = fillstring (22 ," " ) ,tempphone =
    cnvtalphanum (ph2.phone_num ) ,
    IF ((tempphone != ph2.phone_num ) ) fmtphone = ph2.phone_num
    ELSE
     IF ((ph2.phone_format_cd > 0 ) ) fmtphone = cnvtphone (trim (ph2.phone_num ) ,ph2
       .phone_format_cd )
     ELSEIF ((size (tempphone ) < 8 ) ) fmtphone = format (trim (ph2.phone_num ) ,"###-####" )
     ELSE fmtphone = format (trim (ph2.phone_num ) ,"(###) ###-####" )
     ENDIF
    ENDIF
    ,fmtphone = cnvtphone (trim (cnvtalphanum (ph2.phone_num ) ) ,ph2.phone_format_cd ) ,
    IF ((fmtphone <= " " ) ) fmtphone = ph2.phone_num
    ENDIF
    ,
    IF ((ph2.extension > " " ) ) fmtphone = concat (trim (fmtphone ) ," x" ,ph2.extension )
    ENDIF
    ,pt_info->bus_phone = concat (trim (fmtphone ) ,sphonework )
   ENDIF
   ,
   IF ((pa.alias > " " ) ) pt_info->mrn = cnvtalias (pa.alias ,pa.alias_pool_cd )
   ENDIF
  FOOT REPORT
   IF ((pt_info->phone > " " )
   AND (pt_info->mobile_phone > " " )
   AND (pt_info->bus_phone > " " ) ) pt_info->phone_str = concat (pt_info->phone ,", " ,pt_info->
     mobile_phone ,", " ,pt_info->bus_phone )
   ELSEIF ((pt_info->phone > " " )
   AND (pt_info->mobile_phone > " " ) ) pt_info->phone_str = concat (pt_info->phone ,", " ,pt_info->
     mobile_phone )
   ELSEIF ((pt_info->phone > " " )
   AND (pt_info->bus_phone > " " ) ) pt_info->phone_str = concat (pt_info->phone ,", " ,pt_info->
     bus_phone )
   ELSEIF ((pt_info->mobile_phone > " " )
   AND (pt_info->bus_phone > " " ) ) pt_info->phone_str = concat (pt_info->mobile_phone ,", " ,
     pt_info->bus_phone )
   ELSEIF ((pt_info->bus_phone > " " ) ) pt_info->phone_str = pt_info->bus_phone
   ELSEIF ((pt_info->mobile_phone > " " ) ) pt_info->phone_str = pt_info->mobile_phone
   ELSEIF ((pt_info->phone > " " ) ) pt_info->phone_str = pt_info->phone
   ELSE pt_info->phone_str = snot_documented
   ENDIF
  WITH nocounter ,outerjoin = d1 ,outerjoin = d2 ,outerjoin = d4 ,outerjoin = d5 ,outerjoin = d6 ,
   dontcare = pa ,dontcare = a ,dontcare = ph ,dontcare = ph1 ,dontcare = ph2
 ;end select
 SELECT INTO "nl:"
  sphone = trim (ph.phone_num )
  FROM (person p ),
   (person_person_reltn ppr ),
   (person p2 ),
   (dummyt d1 ),
   (phone ph )
  PLAN (p
   WHERE (p.person_id = request->person[1 ].person_id ) )
   JOIN (ppr
   WHERE (ppr.person_id = p.person_id )
   AND (ppr.related_person_reltn_cd = dspouse )
   AND (ppr.active_ind = 1 )
   AND (ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   JOIN (p2
   WHERE (p2.person_id = ppr.related_person_id ) )
   JOIN (d1 )
   JOIN (ph
   WHERE (ph.parent_entity_id = p2.person_id )
   AND (ph.parent_entity_name = "PERSON" )
   AND (ph.phone_type_cd = dhome_phone )
   AND (ph.active_ind = 1 ) )
  DETAIL
   IF ((p.marital_type_cd = dmarried )
   AND (ppr.related_person_reltn_cd = dspouse ) ) pt_info->partner_name = trim (p2
     .name_full_formatted ,3 ) ,
    IF ((size (trim (sphone ) ) > 0 ) ) tempphone = fillstring (22 ," " ) ,tempphone = cnvtalphanum (
      ph.phone_num ) ,
     IF ((tempphone != ph.phone_num ) ) fmtphone = ph.phone_num
     ELSE
      IF ((ph.phone_format_cd > 0 ) ) fmtphone = cnvtphone (trim (ph.phone_num ) ,ph.phone_format_cd
        )
      ELSEIF ((size (tempphone ) < 8 ) ) fmtphone = format (trim (ph.phone_num ) ,"###-####" )
      ELSE fmtphone = format (trim (ph.phone_num ) ,"(###) ###-####" )
      ENDIF
     ENDIF
     ,fmtphone = cnvtphone (trim (cnvtalphanum (ph.phone_num ) ) ,ph.phone_format_cd ) ,
     IF ((fmtphone <= " " ) ) fmtphone = ph.phone_num
     ENDIF
     ,
     IF ((ph.extension > " " ) ) fmtphone = concat (trim (fmtphone ) ," x" ,ph.extension )
     ENDIF
     ,pt_info->partner_phone = concat (trim (fmtphone ) ,sphonehome )
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (person p ),
   (person_prsnl_reltn ppr ),
   (prsnl p2 )
  PLAN (p
   WHERE (p.person_id = request->person[1 ].person_id ) )
   JOIN (ppr
   WHERE (ppr.person_id = p.person_id )
   AND (ppr.person_prsnl_r_cd IN (dpcp ,
   dobprovider ) )
   AND (ppr.active_ind = 1 )
   AND (ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   JOIN (p2
   WHERE (p2.person_id = ppr.prsnl_person_id ) )
  DETAIL
   CASE (ppr.person_prsnl_r_cd )
    OF dpcp :
     pt_info->pcp_name = p2.name_full_formatted
    OF dobprovider :
     pt_info->ob_providers = p2.name_full_formatted
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (person p ),
   (encntr_prsnl_reltn epr ),
   (encounter e ),
   (prsnl p2 )
  PLAN (p
   WHERE (p.person_id = request->person[1 ].person_id ) )
   JOIN (e
   WHERE (e.person_id = p.person_id ) )
   JOIN (epr
   WHERE (epr.encntr_id = e.encntr_id )
   AND (epr.encntr_prsnl_r_cd = drefprovider )
   AND (epr.active_ind = 1 )
   AND (epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (epr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   JOIN (p2
   WHERE (p2.person_id = epr.prsnl_person_id ) )
  DETAIL
   pt_info->referred_by = p2.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (person_org_reltn por )
  WHERE (por.person_id = request->person[1 ].person_id )
  AND (por.active_ind = 1 )
  AND (por.person_org_reltn_cd = demployer_org_reltn )
  ORDER BY por.beg_effective_dt_tm DESC
  HEAD por.person_id
   IF ((por.empl_occupation_cd <= 0.0 ) ) pt_info->occupation = por.empl_occupation_text
   ELSE pt_info->occupation = trim (uar_get_code_display (por.empl_occupation_cd ) ,3 )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (clinical_event ce ),
   (code_value cv )
  PLAN (ce
   WHERE (ce.person_id = request->person[1 ].person_id ) )
   JOIN (cv
   WHERE (cv.code_value = ce.event_cd )
   AND (cv.concept_cki = newborn_phys ) )
  DETAIL
   pt_info->newborn_phys = trim (ce.result_val )
  WITH nocounter
 ;end select
 SELECT
  IF ((honor_org_security_flag = 1 ) ) INTO "nl:"
   FROM (clinical_event ce ),
    (encounter e )
   PLAN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd IN (support_person_cd ,
    support_person_relation_cd ) )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
      "YYYYMMDD;;D" ) ) ) )
    JOIN (e
    WHERE (e.encntr_id = ce.encntr_id )
    AND expand (os_idx ,1 ,size (preg_sec_orgs->qual ,5 ) ,e.organization_id ,preg_sec_orgs->qual[
     os_idx ].org_id ) )
  ELSE INTO "nl:"
   FROM (clinical_event ce )
   PLAN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd IN (support_person_cd ,
    support_person_relation_cd ) )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
      "YYYYMMDD;;D" ) ) ) )
  ENDIF
  DETAIL
   CASE (ce.event_cd )
    OF support_person_cd :
     pt_info->support = trim (ce.result_val )
    OF support_person_relation_cd :
     pt_info->support_relation = build ("(" ,trim (ce.result_val ) ,")" )
   ENDCASE
  WITH nocounter
 ;end select
 SELECT
  IF ((honor_org_security_flag = 1 ) ) INTO "nl:"
   FROM (v500_event_set_code v5es ),
    (v500_event_set_explode v5ese ),
    (v500_event_code v5ec ),
    (clinical_event ce ),
    (ce_date_result cdr ),
    (encounter e )
   PLAN (v5es
    WHERE (v5es.event_set_name IN (delivery_loc_es ,
    planned_preg_es ,
    prenatal_doc_es ,
    tubal_consent_es ) ) )
    JOIN (v5ese
    WHERE (v5ese.event_set_cd = v5es.event_set_cd ) )
    JOIN (v5ec
    WHERE (v5ec.event_cd = v5ese.event_cd ) )
    JOIN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd = v5ec.event_cd )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
      "YYYYMMDD;;D" ) ) ) )
    JOIN (e
    WHERE (e.encntr_id = ce.encntr_id )
    AND expand (os_idx ,1 ,size (preg_sec_orgs->qual ,5 ) ,e.organization_id ,preg_sec_orgs->qual[
     os_idx ].org_id ) )
    JOIN (cdr
    WHERE (cdr.event_id = outerjoin (ce.event_id ) )
    AND (cdr.valid_until_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
  ELSE INTO "nl:"
   FROM (v500_event_set_code v5es ),
    (v500_event_set_explode v5ese ),
    (v500_event_code v5ec ),
    (clinical_event ce ),
    (ce_date_result cdr )
   PLAN (v5es
    WHERE (v5es.event_set_name IN (delivery_loc_es ,
    planned_preg_es ,
    prenatal_doc_es ,
    tubal_consent_es ) ) )
    JOIN (v5ese
    WHERE (v5ese.event_set_cd = v5es.event_set_cd ) )
    JOIN (v5ec
    WHERE (v5ec.event_cd = v5ese.event_cd ) )
    JOIN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd = v5ec.event_cd )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
      "YYYYMMDD;;D" ) ) ) )
    JOIN (cdr
    WHERE (cdr.event_id = outerjoin (ce.event_id ) )
    AND (cdr.valid_until_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
  ENDIF
  ORDER BY v5es.event_set_name ,
   cdr.result_dt_tm ,
   ce.event_end_dt_tm DESC
  FOOT  v5es.event_set_name
   CASE (v5es.event_set_name )
    OF delivery_loc_es :
     pt_info->delivery_loc = trim (ce.result_val )
    OF planned_preg_es :
     pt_info->planned_preg = trim (ce.result_val )
    OF prenatal_doc_es :
     pt_info->prenatal_document = format (cdr.result_dt_tm ,"@SHORTDATE4YR" )
    OF tubal_consent_es :
     pt_info->tubal_consent = format (cdr.result_dt_tm ,"@SHORTDATE4YR" )
   ENDCASE
  WITH nocounter
 ;end select
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (pt_info )
 ENDIF
 SET reply->text = concat (reply->text ,"\tx300\tx5000" )
 SET reply->text = concat (reply->text ,rsechead ,colornavy ,cdemodetails ,wr ,reol )
 IF ((stand_alone_ind = 1 ) )
  IF ((honor_org_security_flag = 1 ) )
   SET reply->text = concat (reply->text ,colorgrey ,whsecuritydisclaim ,wr ,reol )
  ENDIF
 ENDIF
 SET reply->text = concat (reply->text ,rtab ,wr ,colorgrey ,crace ,"  " ,wr ,pt_info->race ,rtab ,
  wr ,colorgrey ,cethnic ,"  " ,wr ,pt_info->ethnicity ,reol ,rtab ,wr ,colorgrey ,cmaritialstat ,
  "  " ,wr ,pt_info->marital_status ,reol ,rtab ,wr ,colorgrey ,clanguages ,"  " ,wr ,pt_info->
  languages ,reol ,rtab ,wr ,colorgrey ,creligiouspref ,"  " ,wr ,pt_info->religious_pref ,reol ,
  rtab ,wr ,colorgrey ,coccedu ,"  " ,wr ,pt_info->occupation ,reol ,reol ,rsubsechead ,colorgrey ,
  caddresssection ,wr ,reol ,rtab ,wr ,colorgrey ,caddress ,"  " ,wr ,pt_info->add_concat ,reol ,
  rtab ,wr ,colorgrey ,cphone ,"  " ,wr ,pt_info->phone_str ,reol ,reol ,rtab ,wu ,colorgrey ,
  chealthplan ,wr ,colorgrey ,": " ,wr )
 FOR (i = 1 TO size (pt_info->hp_qual ,5 ) )
  SET reply->text = concat (reply->text ,rpard ,"\tx300\tx520\tx3000" ,reol ,rtab ,trim (cnvtstring (
     i ) ) ," -" ,rtab ,wb ,pt_info->hp_qual[i ].hp_name ,wr ,reol ,rtab ,rtab ,colorgrey ,
   chealthplanmember ,"  " ,wr ,pt_info->hp_qual[i ].member_num ,reol ,rtab ,rtab ,colorgrey ,
   cdeductable ,"  " ,wr ,pt_info->hp_qual[i ].deduct_amt ,rtab ,colorgrey ,chptype ,"  " ,wr ,
   pt_info->hp_qual[i ].plan_type ,reol ,rtab ,rtab ,colorgrey ,chealthplanaddress ,"  " ,wr ,pt_info
   ->hp_qual[i ].hp_address ,reol ,rtab ,rtab ,colorgrey ,cphone ,"  " ,wr ,pt_info->hp_qual[i ].
   hp_phone )
 ENDFOR
 IF ((size (pt_info->hp_qual ,5 ) = 0 ) )
  SET reply->text = concat (reply->text ,wr ,snot_documented_review ,reol ,reol )
 ELSE
  SET reply->text = concat (reply->text ,reol ,reol )
 ENDIF
 SET reply->text = concat (reply->text ,rpard ,"\tx300\tx6000" ,rsubsechead ,colorgrey ,cobinfo ,wr ,
  reol ,rtab ,wr ,colorgrey ,cobproviders ,"  " ,wr ,pt_info->ob_providers ,reol ,rtab ,wsd ,
  colorgrey ,cadditionalinfo ,wr ,reol ,reol ,rtab ,wr ,colorgrey ,chospital ,"  " ,wr ,pt_info->
  delivery_loc ,reol ,rtab ,wr ,colorgrey ,cnewbornphys ,"  " ,wr ,pt_info->newborn_phys ,reol ,rtab
  ,wr ,colorgrey ,creffered ,"  " ,wr ,pt_info->referred_by ,reol ,rtab ,wr ,colorgrey ,cpcp ,"  " ,
  wr ,pt_info->pcp_name ,reol ,rtab ,wr ,colorgrey ,cpartnername ,"  " ,wr ,pt_info->partner_name ,
  "   " ,pt_info->partner_phone ,reol ,rtab ,wr ,colorgrey ,csupport ,"  " ,wr ,pt_info->support ,
  "  " ,pt_info->support_relation ,reol ,rtab ,wr ,colorgrey ,cplannedpreg ,"  " ,wr ,pt_info->
  planned_preg ,reol ,rtab ,wr ,colorgrey ,ctubalconsent ,"  " ,wr ,pt_info->tubal_consent ,reol ,
  rtab ,wr ,colorgrey ,cprenataldoc ,"  " ,wr ,pt_info->prenatal_document ,reol )
 SET reply->text = concat (reply->text ,rpard )
#exit_script
 IF ((stand_alone_ind = 1 ) )
  SET reply->text = concat (reply->text ,rtfeof )
 ENDIF
 SET script_version = "001"
END GO
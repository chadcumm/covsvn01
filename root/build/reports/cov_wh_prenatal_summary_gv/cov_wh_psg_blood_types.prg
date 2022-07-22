/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/10/2020
  Solution:           
  Source file name:   cov_wh_psg_blood_types.prg
  Object name:        cov_wh_psg_blood_types
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   02/10/2020  Chad Cummings			initial copy from wh_prenatal_summary_gv
001   02/10/2020  Chad Cummings			added ABORh GROUP result option
******************************************************************************/
DROP PROGRAM cov_wh_psg_blood_types :dba GO
CREATE PROGRAM cov_wh_psg_blood_types :dba
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
 ENDIF
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
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echo (build ("stand_alone_ind:" ,stand_alone_ind ) )
 ENDIF
 FREE RECORD blood_info
 RECORD blood_info (
   1 pat_aborh = vc
   1 pat_aborh_found = i4
   1 pat_aborh_r_dt_tm = dq8
   1 pat_aborh_string = vc
   1 pat_anti = vc
   1 pat_anti_r_dt_tm = dq8
   1 fob_aborh = vc
   1 fob_anti = vc
   1 anti_given = vc
   1 pat_anti_8_20 = vc
   1 pat_anti_24_28 = vc
 )
 DECLARE abo_rh_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!8431" ) )
 DECLARE amb_abo_rh_cd = f8 WITH public ,constant ( uar_get_code_by("DISPLAY",72,"ABO Group") ) ;001
 DECLARE anti_screen_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!10744" ) )
 DECLARE anti_d_8_20_es = vc WITH public ,constant ("Rho(D) Initial Status" )
 DECLARE anti_d_24_28_es = vc WITH public ,constant ("Rho(D) 28 Week Status" )
 DECLARE anti_d_rhg_es = vc WITH public ,constant ("Rho(D) Dates Given" )
 DECLARE fob_antibody_es = vc WITH public ,constant ("Father of Baby Antibody Screen" )
 DECLARE f_antibody_es = vc WITH public ,constant ("FOB Antibody Screen" )
 DECLARE fob_abo_rh_es = vc WITH public ,constant ("Father of Baby ABO/Rh" )
 DECLARE f_abo_rh_es = vc WITH public ,constant ("FOB ABO/Rh" )
 DECLARE auth = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE altered = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) )
 DECLARE modified = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) )
 DECLARE captions_title = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap1" ,
   "Blood Types and Anti-D Immune Globulin" ) )
 DECLARE cbloodtypehead = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap2" ,
   "Blood Type and Screen" ) )
 DECLARE cpatientaborh = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap3" ,
   "Mother ABO/Rh:" ) )
 DECLARE cpatientanti = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap4" ,
   "Mother Antibody Screen:" ) )
 DECLARE cfobaborh = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap5" ,
   "Father of Baby ABO/Rh:" ) )
 DECLARE cfobanti = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap6" ,
   "Father of Baby Antibody Screen:" ) )
 DECLARE cantidhead = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap7" ,
   "Anti-D Immune Globulin" ) )
 DECLARE cantidrhggiven = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap8" ,
   "Rho(D) Dates Given:" ) )
 DECLARE cantid_8_20 = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap9" ,
   "Rho(D) Initial Status:" ) )
 DECLARE cantid_24_28 = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap10" ,
   "Rho(D) 28 Week Status:" ) )
 DECLARE cnot_recorded = vc WITH public ,constant (uar_i18ngetmessage (i18nhandle ,"cap12" ,
   "Not recorded or unknown" ) )
 SET blood_info->pat_aborh = snot_documented
 SET blood_info->pat_anti = snot_documented
 SET blood_info->fob_aborh = snot_documented
 SET blood_info->fob_anti = snot_documented
 SET blood_info->anti_given = snot_documented
 SET blood_info->pat_anti_8_20 = snot_documented
 SET blood_info->pat_anti_24_28 = snot_documented
 SET blood_info->pat_aborh_found = 0
 SET blood_info->pat_aborh_string = snot_documented
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
   FROM (clinical_event ce ),
    (encounter e )
   PLAN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd IN (abo_rh_cd ,
    amb_abo_rh_cd, ;001
    anti_screen_cd ) )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ce.result_val > " " )
    AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
      "YYYYMMDD;;D" ) ) ) )
    JOIN (e
    WHERE (ce.encntr_id = e.encntr_id )
    AND expand (os_idx ,1 ,size (preg_sec_orgs->qual ,5 ) ,e.organization_id ,preg_sec_orgs->qual[
     os_idx ].org_id ) )
  ELSE INTO "nl:"
   FROM (clinical_event ce )
   PLAN (ce
    WHERE (ce.person_id = request->person[1 ].person_id )
    AND (ce.event_cd IN (abo_rh_cd ,
    amb_abo_rh_cd, ;001
    anti_screen_cd ) )
    AND (ce.result_status_cd IN (auth ,
    altered ,
    modified ) )
    AND (ce.event_tag != "Date\Time Correction" )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ce.result_val > " " )
    AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
      "YYYYMMDD;;D" ) ) ) )
  ENDIF
  ORDER BY ce.event_cd ,
   ce.event_end_dt_tm
  HEAD ce.event_cd
   CASE (ce.event_cd )
    OF abo_rh_cd :
     IF ((blood_info->pat_aborh_r_dt_tm < ce.event_end_dt_tm ) ) blood_info->pat_aborh = trim (
       getformattedvalue (ce.result_val ) ) ,blood_info->pat_aborh_found = 1 ,blood_info->
      pat_aborh_r_dt_tm = ce.event_end_dt_tm
     ENDIF
    OF anti_screen_cd :
     IF ((blood_info->pat_anti_r_dt_tm < ce.event_end_dt_tm ) ) blood_info->pat_anti = trim (
       getformattedvalue (ce.result_val ) ) ,blood_info->pat_anti_r_dt_tm = ce.event_end_dt_tm
     ENDIF
    ;start 001
    OF amb_abo_rh_cd :
     IF ((blood_info->pat_aborh_r_dt_tm < ce.event_end_dt_tm ) ) blood_info->pat_aborh = trim (
       getformattedvalue (ce.result_val ) ) ,blood_info->pat_aborh_found = 1 ,blood_info->
      pat_aborh_r_dt_tm = ce.event_end_dt_tm
     ENDIF
    ;end 001
   ENDCASE
   ,
   IF ((blood_info->pat_aborh_found = 1 ) ) blood_info->pat_aborh_string = blood_info->pat_aborh
   ELSE blood_info->pat_aborh_string = cnot_recorded
   ENDIF
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
    WHERE (v5es.event_set_name IN (fob_abo_rh_es ,
    f_abo_rh_es ,
    fob_antibody_es ,
    f_antibody_es ,
    anti_d_8_20_es ,
    anti_d_24_28_es ,
    anti_d_rhg_es ) ) )
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
    JOIN (e
    WHERE (ce.encntr_id = e.encntr_id )
    AND expand (os_idx ,1 ,size (preg_sec_orgs->qual ,5 ) ,e.organization_id ,preg_sec_orgs->qual[
     os_idx ].org_id ) )
  ELSE INTO "nl:"
   FROM (v500_event_set_code v5es ),
    (v500_event_set_explode v5ese ),
    (v500_event_code v5ec ),
    (clinical_event ce ),
    (ce_date_result cdr )
   PLAN (v5es
    WHERE (v5es.event_set_name IN (fob_abo_rh_es ,
    f_abo_rh_es ,
    fob_antibody_es ,
    f_antibody_es ,
    anti_d_8_20_es ,
    anti_d_24_28_es ,
    anti_d_rhg_es ) ) )
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
  HEAD REPORT
   given_cnt = 1
  DETAIL
   IF ((v5es.event_set_name = anti_d_rhg_es ) )
    IF ((given_cnt = 1 ) ) blood_info->anti_given = format (cdr.result_dt_tm ,"@SHORTDATE4YR" ) ,
     given_cnt = (given_cnt + 1 )
    ELSE blood_info->anti_given = concat (blood_info->anti_given ,", " ,format (cdr.result_dt_tm ,
       "@SHORTDATE4YR" ) ) ,given_cnt = (given_cnt + 1 )
    ENDIF
   ENDIF
  FOOT  v5es.event_set_name
   CASE (v5es.event_set_name )
    OF fob_abo_rh_es :
     blood_info->fob_aborh = trim (getformattedvalue (ce.result_val ) )
    OF f_abo_rh_es :
     blood_info->fob_aborh = trim (getformattedvalue (ce.result_val ) )
    OF fob_antibody_es :
     blood_info->fob_anti = trim (getformattedvalue (ce.result_val ) )
    OF f_antibody_es :
     blood_info->fob_anti = trim (getformattedvalue (ce.result_val ) )
    OF anti_d_8_20_es :
     blood_info->pat_anti_8_20 = trim (getformattedvalue (ce.result_val ) )
    OF anti_d_24_28_es :
     blood_info->pat_anti_24_28 = trim (getformattedvalue (ce.result_val ) )
   ENDCASE
  WITH nocounter
 ;end select
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (blood_info )
 ENDIF
 SET reply->text = concat (reply->text ,rsechead ,colornavy ,captions_title ,reol )
 IF ((stand_alone_ind = 1 ) )
  IF ((honor_org_security_flag = 1 ) )
   SET reply->text = concat (reply->text ,reol ,colorgrey ,whsecuritydisclaim ,wr ,reol )
  ENDIF
 ENDIF
 SET reply->text = concat (reply->text ,wu ,cbloodtypehead ,wr ,reol ,wr ,colorgrey ,cpatientaborh ,
  "  " ,wr ,blood_info->pat_aborh_string ,reol ,wr ,colorgrey ,cpatientanti ,"  " ,wr ,blood_info->
  pat_anti ,reol ,wr ,colorgrey ,cfobaborh ,"  " ,wr ,blood_info->fob_aborh ,reol ,wr ,colorgrey ,
  cfobanti ,"  " ,wr ,blood_info->fob_anti ,reol ,reol ,wu ,cantidhead ,wr ,reol ,wr ,colorgrey ,
  cantid_8_20 ,"  " ,wr ,blood_info->pat_anti_8_20 ,reol ,wr ,colorgrey ,cantid_24_28 ,"  " ,wr ,
  blood_info->pat_anti_24_28 ,reol ,wr ,colorgrey ,cantidrhggiven ,"  " ,wr ,blood_info->anti_given ,
  reol )
 SET reply->text = concat (reply->text ,rpard )
#exit_script
 IF ((stand_alone_ind = 1 ) )
  SET reply->text = concat (reply->text ,rtfeof )
 ENDIF
 SET script_version = "001"
END GO

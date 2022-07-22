/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/10/2020
  Solution:           
  Source file name:   cov_wh_psg_ob_exams.prg
  Object name:        cov_wh_psg_ob_exams
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   03/17/2020  Chad Cummings			initial copy from wh_psg_ob_exams
******************************************************************************/
DROP PROGRAM cov_wh_psg_ob_exams :dba GO
CREATE PROGRAM cov_wh_psg_ob_exams :dba
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
 DECLARE edd_id = f8
 DECLARE current_ega_days = f8
 DECLARE ega_found = i4 WITH public ,noconstant (0 )
 DECLARE ispatientdelivered (null ) = i2 WITH protect
 FREE RECORD dcp_request
 RECORD dcp_request (
   1 provider_id = f8
   1 position_cd = f8
   1 cal_ega_multiple_gest = i2
   1 patient_list [1 ]
     2 patient_id = f8
     2 encntr_id = f8
   1 provider_list [1 ]
     2 patient_id = f8
     2 encntr_id = f8
     2 provider_patient_reltn_cd = f8
   1 pregnancy_list [* ]
     2 pregnancy_id = f8
   1 multiple_egas = i2
 )
 SET stat = alterlist (dcp_request->patient_list ,1 )
 SET dcp_request->patient_list[1 ].patient_id = request->person[1 ].person_id
 SET dcp_request->cal_ega_multiple_gest = 1
 SET dcp_request->multiple_egas = 1
 SET dcp_request->provider_id = reqinfo->updt_id
 SET dcp_request->position_cd = reqinfo->position_cd
 EXECUTE dcp_get_final_ega WITH replace ("REQUEST" ,dcp_request ) ,
 replace ("REPLY" ,dcp_reply )
 SET modify = nopredeclare
 IF ((dcp_reply->gestation_info[1 ].edd_id > 0.0 ) )
  SELECT INTO "nl:"
   FROM (pregnancy_estimate pe )
   PLAN (pe
    WHERE (pe.pregnancy_estimate_id = dcp_reply->gestation_info[1 ].edd_id ) )
   DETAIL
    ega_found = 1 ,
    IF ((dcp_reply->gestation_info[1 ].current_gest_age > 0 ) ) current_ega_days = dcp_reply->
     gestation_info[1 ].current_gest_age
    ELSEIF ((dcp_reply->gestation_info[1 ].gest_age_at_delivery > 0 ) ) current_ega_days = dcp_reply
     ->gestation_info[1 ].gest_age_at_delivery
    ENDIF
    ,edd_id = pe.pregnancy_estimate_id
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE  ispatientdelivered (null )
  DECLARE patient_delivered_ind = i2 WITH protect ,noconstant (0 )
  IF ((dcp_reply->gestation_info[1 ].delivered_ind = 1 )
  AND (dcp_reply->gestation_info[1 ].partial_delivery_ind = 0 )
  AND (size (dcp_reply->gestation_info[1 ].dynamic_label ,5 ) > 0 ) )
   SET patient_delivered_ind = 1
  ENDIF
  RETURN (patient_delivered_ind )
 END ;Subroutine
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
 FREE SET ob
 RECORD ob (
   1 visit_cnt = i4
   1 visit [* ]
     2 date = c8
     2 ega = c5
     2 ega_weeks = vc
     2 ega_days = vc
     2 ega_weeks_result_dt_tm = dq8
     2 ega_days_result_dt_tm = dq8
     2 fhr = c7
     2 pres = c19
     2 fundal_ht = c8
     2 fetal_mvmt = c22
     2 preterm_ss = c7
     2 dil = c6
     2 eff = c4
     2 sta = c3
     2 sys_bp = vc
     2 sys_bp_c = vc
     2 dia_bp = vc
     2 dia_bp_c = vc
     2 bp = c9
     2 wt_kg = vc
     2 wt_lbs = vc
     2 wt = vc
     2 gluc = c10
     2 prot = c10
     2 nxvisit = vc
     2 addt_fetus [* ]
       3 baby = c7
       3 fhr = c7
       3 pres = vc
       3 fetal_mvmt = c22
       3 seq = i4
       3 smartfhr = vc
       3 smartfetal_mvmt = vc
     2 smartpreterm_ss = vc
     2 smarturinegluc = vc
     2 smarturineprot = vc
     2 smartfhr = vc
     2 smartfetal_mvmt = vc
   1 exam_comment_cnt = i4
   1 exam_comments [* ]
     2 comment_text = vc
     2 comment_dt_tm = vc
     2 comment_prsnl = vc
 )
 FREE RECORD clin_events
 RECORD clin_events (
   1 rec [* ]
     2 name = vc
     2 event_cd = f8
     2 concept_cki = vc
   1 cnt = i4
 )
 FREE RECORD long_pres_part
 RECORD long_pres_part (
   1 rec [* ]
     2 date = vc
     2 pres_part = vc
 )
 FREE RECORD long_fetal_mvmt
 RECORD long_fetal_mvmt (
   1 rec [* ]
     2 date = vc
     2 fetal_mvmt = vc
 )
 FREE RECORD long_preterm_ss
 RECORD long_preterm_ss (
   1 rec [* ]
     2 date = vc
     2 preterm_ss = vc
 )
 FREE RECORD long_fundal_height
 RECORD long_fundal_height (
   1 rec [* ]
     2 date = vc
     2 fundal_ht = vc
 )
 FREE RECORD long_cervix_dil
 RECORD long_cervix_dil (
   1 rec [* ]
     2 date = vc
     2 dil = vc
 )
 FREE RECORD long_cervix_effacement
 RECORD long_cervix_effacement (
   1 rec [* ]
     2 date = vc
     2 eff = vc
 )
 FREE RECORD long_fetal_station
 RECORD long_fetal_station (
   1 rec [* ]
     2 date = vc
     2 sta = vc
 )
 FREE RECORD long_fhr
 RECORD long_fhr (
   1 rec [* ]
     2 date = vc
     2 fhr = vc
 )
 FREE RECORD long_ega
 RECORD long_ega (
   1 rec [* ]
     2 date = vc
     2 ega = vc
 )
 FREE RECORD long_glucose
 RECORD long_glucose (
   1 rec [* ]
     2 date = vc
     2 gluc = vc
 )
 FREE RECORD long_protien
 RECORD long_protien (
   1 rec [* ]
     2 date = vc
     2 prot = vc
 )
 FREE RECORD long_weight
 RECORD long_weight (
   1 rec [* ]
     2 date = vc
     2 wt = vc
 )
 FREE RECORD long_bloodpressure_n
 RECORD long_bloodpressure_n (
   1 rec [* ]
     2 date = vc
     2 bp = vc
 )
 FREE RECORD long_bloodpressure_y
 RECORD long_bloodpressure_y (
   1 rec [* ]
     2 date = vc
     2 bp = vc
 )
 DECLARE temp_wt_kg = vc WITH public ,noconstant ("" )
 DECLARE temp_wt_lbs = vc WITH public ,noconstant ("" )
 DECLARE next_visit_txt = vc WITH public ,noconstant (snot_documented )
 DECLARE auth = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE altered = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) )
 DECLARE modified = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) )
 DECLARE kg_in_pound = f8 WITH public ,constant (2.205 )
 DECLARE kg_in_grams = f8 WITH public ,constant (1000 )
 DECLARE pound_in_grams = f8 WITH public ,constant (453.59237 )
 DECLARE diastolic_blood_pressure = vc WITH protect ,constant ("CERNER!AE2lmwD9a+OCboERn4waeg" )
 DECLARE protein_urine_dipstick = vc WITH protect ,constant ("CERNER!AeXiwwEJc7Lb7KK8Cqk/Mw" )
 DECLARE glucose_urine_dipstick = vc WITH protect ,constant ("CERNER!AeXiwwEJc7Lb7JNxCqk/Mw" )
 DECLARE systolic_blood_pressure = vc WITH protect ,constant ("CERNER!AE2lmwD9a+OCboD/n4waeg" )
 DECLARE cervix_dilation = vc WITH protect ,constant ("CERNER!86D59A58-992F-4FAE-A470-FC6D6A2103D2"
  )
 DECLARE cervix_effacement = vc WITH protect ,constant (
  "CERNER!0A276863-603D-4B81-A00D-03B8E0785CD8" )
 DECLARE fetal_station = vc WITH protect ,constant ("CERNER!5DA57B04-B101-43C8-B3B9-9F4887321C48" )
 DECLARE fundal_height = vc WITH protect ,constant ("CERNER!F6916B5D-ABED-4526-8092-080886C5BCE6" )
 DECLARE preterm_labor_ssp = vc WITH protect ,constant (
  "CERNER!C8C52A77-D16A-465C-8247-C79AC31A82E3" )
 DECLARE weight_measured = vc WITH protect ,constant ("CERNER!E9A8D345-C87A-4034-938A-BA2349967398"
  )
 DECLARE fetal_presentation = vc WITH protect ,constant (
  "CERNER!752D42BB-AD4D-42F9-BA9D-3CB2198588BB" )
 DECLARE fhr_baseline = vc WITH protect ,constant ("CERNER!88CD125E-F1F0-45FC-90DE-0CCB184B43E4" )
 DECLARE fetal_activity = vc WITH protect ,constant ("CERNER!461596EC-F0E5-45A2-A722-F38D34A70646" )
 DECLARE next_visit = vc WITH protect ,constant ("CERNER!C1C95B71-085F-4049-AE11-F8FDB825FA87" )
 DECLARE fhr = vc WITH protect ,constant ("CERNER!A3C94E1C-E070-4C35-B267-8F2EB7D95747" )
 DECLARE g_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!6123" ) )
 DECLARE kg_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2751" ) )
 DECLARE lb_cd = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2746" ) )
 DECLARE ce_dyn_label_active_cd = f8 WITH public ,constant (uar_get_code_by_cki (
   "CKI.CODEVALUE!12609392" ) )
 DECLARE s_num = i4 WITH public ,noconstant (0 )
 DECLARE s_start = i4 WITH public ,noconstant (1 )
 DECLARE datecaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap1" ,"Date" ) )
 DECLARE fundalcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap2" ,"FunHt"
   ) )
 DECLARE htcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap3" ,"cm" ) )
 DECLARE pretermcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap4" ,
   "PTL S/S" ) )
 DECLARE sscaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap5" ,"S/S" ) )
 DECLARE dashcervixcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap6" ,
   "Cervix" ) )
 DECLARE dilcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap7" ,"Dil" ) )
 DECLARE effcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap8" ,"Eff(%)" )
  )
 DECLARE fetalcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap9" ,
   "Fetal Activity" ) )
 DECLARE stacaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap10" ,"Sta" ) )
 DECLARE weightcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap11" ,
   "Weight" ) )
 DECLARE ibskgcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap12" ,
   "lbs | kg" ) )
 DECLARE bpcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap14" ,"BP" ) )
 DECLARE dashurinecaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap15" ,
   "Urine" ) )
 DECLARE protcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap16" ,"Prot" )
  )
 DECLARE gluccaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap17" ,"Gluc" )
  )
 DECLARE fhrcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap18" ,"FHR" ) )
 DECLARE fetprescaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap19" ,
   "Fet Pres" ) )
 DECLARE longfetprescaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap20" ,
   "* Fetal Presentation" ) )
 DECLARE mmhgcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap21" ,"mmHg" )
  )
 DECLARE nextvisitcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap22" ,
   "Next Visit:" ) )
 DECLARE modifiedcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap23" ,
   " (c)" ) )
 DECLARE partcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap24" ,"Part" )
  )
 DECLARE longfetalmvmtcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap25" ,
   "* Fetal Activity" ) )
 DECLARE modfromcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap26" ,
   " (c) from" ) )
 DECLARE fromcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap27" ," from" )
  )
 DECLARE longfundalheightcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "cap28" ,"* Fundal Height " ) )
 DECLARE longcervixdilationcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "cap29" ,"* Cervix Dilation " ) )
 DECLARE longcervixeffacementcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "cap30" ,"* Cervix Effacement " ) )
 DECLARE longfetalstationcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "cap31" ,"* Cervix Station " ) )
 DECLARE longfhrcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap32" ,
   "* FHR " ) )
 DECLARE longegacaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap33" ,
   "* EGA " ) )
 DECLARE longglucosdecaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap34" ,
   "* Urine Glucose " ) )
 DECLARE longprotiencaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap35" ,
   "* Urine Protien " ) )
 DECLARE longweightcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap36" ,
   "* Weight " ) )
 DECLARE longbloodpressuren = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap37" ,
   "* Blood Pressure" ) )
 DECLARE longbloodpressurey = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap38" ,
   "* Blood Pressure" ) )
 DECLARE result_dt_tm = dq8 WITH protect
 DECLARE babycaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap28" ,"Baby" )
  )
 DECLARE egacaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap29" ,"EGA" ) )
 DECLARE captions_title = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap30" ,
   "Prenatal Exam and Notes" ) )
 DECLARE cobexamcomments = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap31" ,
   "Prenatal Note(s):" ) )
 DECLARE cno_comments = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap32" ,
   "No prenatal exam data has been recorded." ) )
 DECLARE cweeks = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap33" ,"w" ) )
 DECLARE cdays = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap34" ,"d" ) )
 DECLARE cseechart = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap35" ,"see chart"
   ) )
 DECLARE smart_captions_title = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap1" ,"Prenatal Exams and Notes" ) )
 DECLARE smartdatecaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap2" ,
   "Date:" ) )
 DECLARE smartegacaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap3" ,
   "EGA:" ) )
 DECLARE smartweightcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap4"
   ,"Weight" ) )
 DECLARE smartlbskgcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap5" ,
   "lbs|kg" ) )
 DECLARE smartfundalcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap6"
   ,"Fundal Height" ) )
 DECLARE smarthtcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap7" ,
   "cm" ) )
 DECLARE smartbpcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap8" ,
   "Blood Pressure" ) )
 DECLARE smartmmhgcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap9" ,
   "mmHg" ) )
 DECLARE smartcervixcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap10" ,"Cervix Exam" ) )
 DECLARE smartdilcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap11" ,
   "Dil cm" ) )
 DECLARE smarteffcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap12" ,
   "Eff %" ) )
 DECLARE smartstatcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap13" ,
   "Sta -" ) )
 DECLARE smartpretermcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap14" ,"Preterm Labor S/S:" ) )
 DECLARE smarturineglucosecaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap15" ,"Urine Glucose:" ) )
 DECLARE smarturineproteincaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap16" ,"Urine Protein:" ) )
 DECLARE smartnextvisitcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap17" ,"Next Visit:" ) )
 DECLARE smartfhrcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"smartcap18" ,
   "FHR:" ) )
 DECLARE smartfetalmvmtcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap19" ,"Fetal Movement:" ) )
 DECLARE smartfetalprestcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "smartcap20" ,"Presentation:" ) )
 DECLARE longpretermcaption = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"cap36" ,
   "* Preterm Labor Signs & Symptoms" ) )
 DECLARE lbscaption = vc WITH public ,noconstant ("" )
 DECLARE kgcaption = vc WITH public ,noconstant ("" )
 SET lbscaption = trim (substring (1 ,(findstring ("|" ,ibskgcaption ) - 1 ) ,ibskgcaption ) ,7 )
 SET kgcaption = trim (substring ((findstring ("|" ,ibskgcaption ) + 1 ) ,size (ibskgcaption ,1 ) ,
   ibskgcaption ) ,7 )
 SET row_type1 = concat (
 		 "\trgaph25" 
 		,cell_border_top_left ,"\cellx600" 	;Date
 		,cell_border_top_left ,"\cellx1200" ;EGA
 		,cell_border_top_left ,"\cellx1700" ;FunHt
 		,cell_border_top_left ,"\cellx2300" ;PTL S/S
 		,cell_border_top_left ,"\cellx3650" ;Cervix
 		,cell_border_top_left ,"\cellx4200" ;BP
 		,cell_border_top_left ,"\cellx5200" ;Weight
 		,cell_border_top_left ,"\cellx6950" ;Urine
 		,cell_border_top_left ,cell_border_right ,"\cellx10350" ;Baby
 	)
 SET row_type2 = concat (
 		"\trgaph25" 
 		,cell_border_top_left ,"\cellx600" 	;(date)
 		,cell_border_top_left ,"\cellx1200" ;(ega)
 		,cell_border_top_left ,"\cellx1700" ;cm
 		,cell_border_top_left ,"\cellx2300" ;(PTL S/S)
 		,cell_border_top_left ,"\cellx2700" ;Dil
 		,cell_border_top_left ,"\cellx3250" ;Eff(%)
 		,cell_border_top_left ,"\cellx3650" ;sta
 		,cell_border_top_left ,"\cellx4200" ;mmHg
 		,cell_border_top_left ,"\cellx5200" ;lbs | kg
 		,cell_border_top_left ,"\cellx6300" ;Gluc
 		,cell_border_top_left ,"\cellx6950" ;Prot
 		,cell_border_top_left ,"\cellx8500" ;FHR
 		,cell_border_top_left ,"\cellx9600" ;Fetal Activity
 		,cell_border_top_left ,cell_border_right ,"\cellx10350" ;Fet Pres
 	)
 		
 SET row_type3 = concat (
 		"\trgaph25" 
 		,cell_border_top ,"\cellx600" 	;(date)
 		,cell_border_top ,"\cellx1200" 	;(ega)
 		,cell_border_top ,"\cellx1700" 	;cm
 		,cell_border_top ,"\cellx2300" 	;(PTL S/S)
 		,cell_border_top ,"\cellx2700" 	;Dil
 		,cell_border_top ,"\cellx3250" 	;Eff(%)
 		,cell_border_top ,"\cellx3650" 	;sta
 		,cell_border_top ,"\cellx4200" 	;mmHg
 		,cell_border_top ,"\cellx5200" 	;lbs | kg
 		,cell_border_top ,"\cellx6300" 	;Gluc
 		,cell_border_top ,"\cellx6950" 	;Prot
 		,cell_border_top ,"\cellx8500" 	;FHR
 		,cell_border_top ,"\cellx9600" 	;Fetal Activity
 		,cell_border_top ,"\cellx10350"	;Fet Pres
 	)
 SET captions1 = concat (row_start ,row_type1 ,cell_start ,cell_text_center ,datecaption ,cell_end ,
  cell_start ,cell_text_center ,egacaption ,cell_end ,cell_start ,cell_text_center ,fundalcaption ,
  cell_end ,cell_start ,cell_text_center ,pretermcaption ,cell_end ,cell_start ,cell_text_center ,
  dashcervixcaption ,cell_end ,cell_start ,cell_text_center ,bpcaption ,cell_end ,cell_start ,
  cell_text_center ,weightcaption ,cell_end ,cell_start ,cell_text_center ,dashurinecaption ,
  cell_end ,cell_start ,cell_text_center ,babycaption ,cell_end ,row_end )
 SET captions2 = concat (row_start ,row_type2 ,cell_start ,cell_end ,cell_start ,cell_end ,
  cell_start ,htcaption ,cell_end ,cell_start ,cell_end ,cell_start ,dilcaption ,cell_end ,
  cell_start ,effcaption ,cell_end ,cell_start ,stacaption ,cell_end ,cell_start ,mmhgcaption ,
  cell_end ,cell_start ,ibskgcaption ,cell_end ,cell_start ,gluccaption ,cell_end ,cell_start ,
  protcaption ,cell_end ,cell_start ,fhrcaption ,cell_end ,cell_start ,fetalcaption ,cell_end ,
  cell_start ,fetprescaption ,cell_end ,row_end )
 DECLARE geteventcodes (null ) = null WITH protect
 DECLARE writenodata (null ) = null WITH protect
 DECLARE getresults (null ) = null WITH protect
 DECLARE isvalidfetalresult ((p1 = dq8 (val ) ) ,(p2 = vc (val ) ) ) = i2 WITH protect
 DECLARE onset_dt_tm = dq8 WITH protect
 IF ((stand_alone_ind = 1 ) )
  SET z = getpregnancyinfo (request->person[1 ].person_id )
  SET onset_dt_tm = preg_info_reply->person[1 ].pregnancy_list[1 ].onset_dt_tm
  SET reply->text = concat (reply->text ,rhead ,rhead_colors1 ,rhead_colors2 ,rhead_colors3 )
 ELSE
  SET onset_dt_tm = request->person[1 ].pregnancy_list[1 ].onset_dt_tm
 ENDIF
 CALL geteventcodes (null )
 IF ((clin_events->cnt = 0 ) )
  CALL writenodata (null )
 ENDIF
 CALL getresults (null )
 GO TO exit_script
 SUBROUTINE  writenodata (null )
  IF ((stand_alone_ind = 1 ) )
   SET reply->text = concat (reply->text ,wr ,rpard ,rtabstopnd ,reol ,rtab ,cno_comments ,reol )
  ELSE
   SET reply->text = concat (reply->text ,rsechead ,colornavy ,captions_title ,wr ,reol ,rpard ,
    rtabstopnd ,reol ,rtab ,cno_comments ,reol ,rpard )
  ENDIF
  GO TO exit_script
 END ;Subroutine
 SUBROUTINE  geteventcodes (null )
  SELECT INTO "nl:"
   FROM (code_value cv )
   PLAN (cv
    WHERE (cv.code_set = 72 )
    AND (cv.concept_cki IN (diastolic_blood_pressure ,
    protein_urine_dipstick ,
    glucose_urine_dipstick ,
    systolic_blood_pressure ,
    cervix_dilation ,
    cervix_effacement ,
    fetal_station ,
    fundal_height ,
    preterm_labor_ssp ,
    weight_measured ,
    fetal_presentation ,
    fhr_baseline ,
    fhr ,
    fetal_activity ,
    next_visit ) )
    AND (cv.active_ind = 1 ) )
   ORDER BY cv.concept_cki
   HEAD REPORT
    ec_cnt = 0
   DETAIL
    ec_cnt = (ec_cnt + 1 ) ,
    stat = alterlist (clin_events->rec ,ec_cnt ) ,
    clin_events->rec[ec_cnt ].event_cd = cv.code_value ,
    clin_events->rec[ec_cnt ].concept_cki = cv.concept_cki ,
    clin_events->rec[ec_cnt ].name = cv.display
   FOOT REPORT
    clin_events->cnt = ec_cnt
   WITH nocounter
  ;end select
  IF (validate (debug_ind ,0 ) )
   CALL echorecord (clin_events )
  ENDIF
 END ;Subroutine
 SUBROUTINE  isvalidfetalresult (event_end_dt_tm ,dynamic_label_id )
  DECLARE delvidx = i4 WITH protect ,noconstant (0 )
  DECLARE isvalid = i2 WITH protect ,noconstant (1 )
  SET pos = locateval (delvidx ,0 ,size (dcp_reply->gestation_info[1 ].dynamic_label ,5 ) ,
   dynamic_label_id ,dcp_reply->gestation_info[1 ].dynamic_label[delvidx ].dynamic_label_id )
  IF ((pos > 0 )
  AND (cnvtdatetime (event_end_dt_tm ) > cnvtdatetime (dcp_reply->gestation_info[1 ].dynamic_label[
   pos ].delivery_date ) ) )
   SET isvalid = 0
  ENDIF
  RETURN (isvalid )
 END ;Subroutine
 SUBROUTINE  getresults (null )
  DECLARE ceidx = i4 WITH protect ,noconstant (0 )
  DECLARE lvidx = i4 WITH protect ,noconstant (0 )
  DECLARE nvidx = i4 WITH protect ,noconstant (0 )
  DECLARE delivery_days_parser = vc WITH noconstant ("1=1" ) ,protect
  IF (ispatientdelivered (null )
  AND (cnvtint (format (dcp_reply->gestation_info[1 ].delivery_date ,"YYYYMMDDHHMMSS;;Q" ) ) > 0 ) )
   SET delivery_days_parser =
   "(ce.event_end_dt_tm) <= cnvtdatetime(dcp_reply->gestation_info[1].delivery_date)"
  ENDIF
  SELECT
   IF ((honor_org_security_flag = 1 ) ) INTO "nl:"
    ce_event_end_dt = cnvtdate (ce.event_end_dt_tm ) ,
    ce_result_units_cd = uar_get_code_display (ce.result_units_cd ) ,
    ce_event_cd = ce.event_cd ,
    code_sort =
    IF ((ce.event_cd = clin_events->rec[locateval (nvidx ,1 ,size (clin_events->rec ,5 ) ,next_visit
     ,clin_events->rec[nvidx ].concept_cki ) ].event_cd ) ) 1
    ELSE 2
    ENDIF
    ,date_formated = format (ce.event_end_dt_tm ,"@SHORTDATE4YR" )
    FROM (clinical_event ce ),
     (ce_dynamic_label cdl ),
     (encounter e )
    PLAN (ce
     WHERE (ce.person_id = request->person[1 ].person_id )
     AND expand (ceidx ,1 ,size (clin_events->rec ,5 ) ,ce.event_cd ,clin_events->rec[ceidx ].
      event_cd )
     AND (ce.result_status_cd IN (auth ,
     altered ,
     modified ) )
     AND (ce.event_tag != "Date\Time Correction" )
     AND (ce.event_tag != "In Error" )
     AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
       "YYYYMMDD;;D" ) ) )
     AND parser (delivery_days_parser ) )
     JOIN (cdl
     WHERE (cdl.ce_dynamic_label_id = outerjoin (ce.ce_dynamic_label_id ) )
     AND (cdl.label_status_cd = outerjoin (ce_dyn_label_active_cd ) )
     AND (cdl.valid_from_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (cdl.valid_until_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
     JOIN (e
     WHERE (ce.encntr_id = e.encntr_id )
     AND expand (os_idx ,1 ,size (preg_sec_orgs->qual ,5 ) ,e.organization_id ,preg_sec_orgs->qual[
      os_idx ].org_id ) )
   ELSE INTO "nl:"
    ce_event_end_dt = cnvtdate (ce.event_end_dt_tm ) ,
    ce_result_units_cd = uar_get_code_display (ce.result_units_cd ) ,
    ce_event_cd = ce.event_cd ,
    code_sort =
    IF ((ce.event_cd = clin_events->rec[locateval (nvidx ,1 ,size (clin_events->rec ,5 ) ,next_visit
     ,clin_events->rec[nvidx ].concept_cki ) ].event_cd ) ) 1
    ELSE 2
    ENDIF
    ,date_formated = format (ce.event_end_dt_tm ,"@SHORTDATE4YR" )
    FROM (clinical_event ce ),
     (ce_dynamic_label cdl )
    PLAN (ce
     WHERE (ce.person_id = request->person[1 ].person_id )
     AND expand (ceidx ,1 ,size (clin_events->rec ,5 ) ,ce.event_cd ,clin_events->rec[ceidx ].
      event_cd )
     AND (ce.result_status_cd IN (auth ,
     altered ,
     modified ) )
     AND (ce.event_tag != "Date\Time Correction" )
     AND (ce.event_tag != "In Error" )
     AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (cnvtint (format (ce.event_end_dt_tm ,"YYYYMMDD;;D" ) ) >= cnvtint (format (onset_dt_tm ,
       "YYYYMMDD;;D" ) ) )
     AND parser (delivery_days_parser ) )
     JOIN (cdl
     WHERE (cdl.ce_dynamic_label_id = outerjoin (ce.ce_dynamic_label_id ) )
     AND (cdl.label_status_cd = outerjoin (ce_dyn_label_active_cd ) )
     AND (cdl.valid_from_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (cdl.valid_until_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
   ENDIF
   ORDER BY ce_event_end_dt DESC ,
    code_sort ,
    cdl.label_name ,
    ce.event_id ,
    ce_event_cd ,
    ce.event_end_dt_tm DESC
   HEAD REPORT
    cnt = 0 ,
    lppcnt = 0 ,
    lfmcnt = 0 ,
    nv_ind = 0 ,
    lpretermcnt = 0 ,
    lfundalheightcnt = 0 ,
    lcervixdilationcnt = 0 ,
    lcervixeffcnt = 0 ,
    lfetalstationcnt = 0 ,
    lfhrbaselinecnt = 0 ,
    legacnt = 0 ,
    lurineglucnt = 0 ,
    lurineprocnt = 0 ,
    lweightcnt = 0 ,
    lbpnomodifycnt = 0 ,
    lbpyesmodifycnt = 0
   HEAD ce_event_end_dt
    cnt = (cnt + 1 ) ,addt_fetus_cnt = 0 ,stat = alterlist (ob->visit ,cnt ) ,ob->visit[cnt ].date =
    format (ce.event_end_dt_tm ,"@SHORTDATE" ) ,ob->visit[cnt ].ega = snot_documented ,ob->visit[cnt
    ].ega_weeks = snot_documented ,ob->visit[cnt ].ega_days = snot_documented ,ob->visit[cnt ].fhr =
    " " ,ob->visit[cnt ].pres = snot_documented ,ob->visit[cnt ].fundal_ht = snot_documented ,ob->
    visit[cnt ].fetal_mvmt = snot_documented ,ob->visit[cnt ].preterm_ss = snot_documented ,ob->
    visit[cnt ].dil = snot_documented ,ob->visit[cnt ].eff = snot_documented ,ob->visit[cnt ].sta =
    snot_documented ,ob->visit[cnt ].sys_bp = " " ,ob->visit[cnt ].sys_bp_c = " " ,ob->visit[cnt ].
    dia_bp = " " ,ob->visit[cnt ].dia_bp_c = " " ,ob->visit[cnt ].bp = snot_documented ,ob->visit[
    cnt ].wt_kg = " " ,ob->visit[cnt ].wt_lbs = " " ,ob->visit[cnt ].wt = snot_documented ,ob->visit[
    cnt ].prot = snot_documented ,ob->visit[cnt ].gluc = snot_documented ,ob->visit[cnt ].nxvisit =
    " "
   DETAIL
    ccki = clin_events->rec[locateval (lvidx ,1 ,size (clin_events->rec ,5 ) ,ce.event_cd ,
     clin_events->rec[lvidx ].event_cd ) ].concept_cki ,
    CASE (ccki )
     OF fhr_baseline :
     OF fhr :
      IF ((size (trim (ce.result_val ) ) > 9 ) ) lfhrbaselinecnt = (lfhrbaselinecnt + 1 ) ,stat =
       alterlist (long_fhr->rec ,lfhrbaselinecnt ) ,long_fhr->rec[lfhrbaselinecnt ].date =
       date_formated ,long_fhr->rec[lfhrbaselinecnt ].fhr = concat (trim (getformattedvalue (ce
          .result_val ) ) ,trim (ce_result_units_cd ) ) ,ob->visit[cnt ].fhr = concat ("*" ,
        substring (1 ,3 ,getformattedvalue (ce.result_val ) ) ,"..." ,trim (ce_result_units_cd ) )
      ELSE ob->visit[cnt ].fhr = concat (trim (getformattedvalue (ce.result_val ) ) ,trim (
         ce_result_units_cd ) )
      ENDIF
      ,
      ob->visit[cnt ].smartfhr = ob->visit[cnt ].fhr
     OF fetal_presentation :
      IF ((size (trim (ce.result_val ) ) > 10 ) )
       IF ((trim (cdl.label_name ) != "" )
       AND (cdl.label_status_cd = ce_dyn_label_active_cd ) ) lppcnt = (lppcnt + 1 ) ,stat =
        alterlist (long_pres_part->rec ,lppcnt ) ,long_pres_part->rec[lppcnt ].date = date_formated ,
        long_pres_part->rec[lppcnt ].pres_part = trim (ce.result_val )
       ENDIF
       ,ob->visit[cnt ].pres = concat ("*" ,substring (1 ,7 ,ce.result_val ) ,"..." )
      ELSE ob->visit[cnt ].pres = trim (ce.result_val )
      ENDIF
      ,
      IF ((stand_alone_ind = 1 ) ) ob->visit[cnt ].pres = trim (ce.result_val )
      ENDIF
     OF fundal_height :
      IF ((size (trim (ce.result_val ) ) > 3 ) ) lfundalheightcnt = (lfundalheightcnt + 1 ) ,stat =
       alterlist (long_fundal_height->rec ,lfundalheightcnt ) ,long_fundal_height->rec[
       lfundalheightcnt ].date = date_formated ,long_fundal_height->rec[lfundalheightcnt ].fundal_ht
       = trim (getformattedvalue (ce.result_val ) ) ,ob->visit[cnt ].fundal_ht = concat ("*" ,
        substring (1 ,2 ,getformattedvalue (ce.result_val ) ) ,"..." )
      ELSE ob->visit[cnt ].fundal_ht = trim (getformattedvalue (ce.result_val ) )
      ENDIF
     OF fetal_activity :
      IF ((size (trim (ce.result_val ) ) > 10 ) ) lfmcnt = (lfmcnt + 1 ) ,stat = alterlist (
        long_fetal_mvmt->rec ,lfmcnt ) ,long_fetal_mvmt->rec[lfmcnt ].date = date_formated ,
       long_fetal_mvmt->rec[lfmcnt ].fetal_mvmt = trim (ce.result_val ) ,ob->visit[cnt ].fetal_mvmt
       = concat ("*" ,substring (1 ,10 ,ce.result_val ) ,"..." )
      ELSE ob->visit[cnt ].fetal_mvmt = trim (ce.result_val )
      ENDIF
      ,
      ob->visit[cnt ].smartfetal_mvmt = trim (ce.result_val )
     OF preterm_labor_ssp :
      IF ((size (trim (ce.result_val ) ) > 4 ) ) lpretermcnt = (lpretermcnt + 1 ) ,stat = alterlist (
        long_preterm_ss->rec ,lpretermcnt ) ,long_preterm_ss->rec[lpretermcnt ].date = date_formated
      ,long_preterm_ss->rec[lpretermcnt ].preterm_ss = trim (ce.result_val ) ,ob->visit[cnt ].
       preterm_ss = concat ("*" ,substring (1 ,4 ,trim (ce.result_val ,4 ) ) ,".." )
      ELSE ob->visit[cnt ].preterm_ss = trim (ce.result_val )
      ENDIF
      ,
      ob->visit[cnt ].smartpreterm_ss = trim (ce.result_val )
     OF cervix_dilation :
      IF ((size (trim (ce.result_val ) ) > 3 ) ) lcervixdilationcnt = (lcervixdilationcnt + 1 ) ,
       stat = alterlist (long_cervix_dil->rec ,lcervixdilationcnt ) ,long_cervix_dil->rec[
       lcervixdilationcnt ].date = date_formated ,long_cervix_dil->rec[lcervixdilationcnt ].dil =
       trim (getformattedvalue (ce.result_val ) ) ,ob->visit[cnt ].dil = concat ("*" ,substring (1 ,
         2 ,getformattedvalue (ce.result_val ) ) ,"..." )
      ELSE ob->visit[cnt ].dil = trim (getformattedvalue (ce.result_val ) )
      ENDIF
     OF cervix_effacement :
      IF ((size (trim (ce.result_val ) ) > 4 ) ) lcervixeffcnt = (lcervixeffcnt + 1 ) ,stat =
       alterlist (long_cervix_effacement->rec ,lcervixeffcnt ) ,long_cervix_effacement->rec[
       lcervixeffcnt ].date = date_formated ,long_cervix_effacement->rec[lcervixeffcnt ].eff = trim (
        ce.result_val ) ,ob->visit[cnt ].eff = trim (build (trim (concat ("*" ,substring (1 ,1 ,ce
            .result_val ) ,"..." ) ) ,"%" ) )
      ELSE ob->visit[cnt ].eff = trim (build (trim (ce.result_val ,4 ) ,"%" ) )
      ENDIF
     OF fetal_station :
      IF ((cnvtupper (ce.result_val ) != "NOT*" ) )
       IF ((size (trim (ce.result_val ) ) > 3 ) ) lfetalstationcnt = (lfetalstationcnt + 1 ) ,stat =
        alterlist (long_fetal_station->rec ,lfetalstationcnt ) ,long_fetal_station->rec[
        lfetalstationcnt ].date = date_formated ,long_fetal_station->rec[lfetalstationcnt ].sta =
        trim (ce.result_val ) ,ob->visit[cnt ].sta = concat ("*" ,substring (1 ,1 ,ce.result_val ) ,
         ".." )
       ELSE ob->visit[cnt ].sta = trim (ce.result_val )
       ENDIF
      ELSE ob->visit[cnt ].sta = trim ("FLT" )
      ENDIF
     OF systolic_blood_pressure :
      ob->visit[cnt ].sys_bp = trim (ce.result_val ) ,
      IF ((ce.result_status_cd = modified ) ) ob->visit[cnt ].sys_bp_c = "Y"
      ELSE ob->visit[cnt ].sys_bp_c = "N"
      ENDIF
     OF diastolic_blood_pressure :
      ob->visit[cnt ].dia_bp = trim (getformattedvalue (ce.result_val ) ) ,
      IF ((ce.result_status_cd = modified ) ) ob->visit[cnt ].dia_bp_c = "Y"
      ELSE ob->visit[cnt ].dia_bp_c = "N"
      ENDIF
     OF weight_measured :
      IF ((ce.result_units_cd = kg_cd ) ) temp_wt_kg = trim (ce.result_val ) ,temp_wt_lbs = trim (
        cnvtstring ((cnvtreal (ce.result_val ) * kg_in_pound ) ,9 ,3 ) )
      ELSEIF ((ce.result_units_cd = lb_cd ) ) temp_wt_kg = trim (cnvtstring ((cnvtreal (ce
          .result_val ) / kg_in_pound ) ,9 ,3 ) ) ,temp_wt_lbs = trim (ce.result_val )
      ELSEIF ((ce.result_units_cd = g_cd ) ) temp_wt_lbs = trim (cnvtstring ((cnvtreal (ce
          .result_val ) / pound_in_grams ) ,9 ,3 ) ) ,temp_wt_kg = trim (cnvtstring ((cnvtreal (ce
          .result_val ) / kg_in_grams ) ,9 ,3 ) )
      ENDIF
      ,
      ob->visit[cnt ].wt_kg = trim (getformattedvalue (temp_wt_kg ) ) ,
      ob->visit[cnt ].wt_lbs = trim (getformattedvalue (temp_wt_lbs ) )
     OF glucose_urine_dipstick :
      IF ((isnumeric (substring (1 ,1 ,trim (ce.result_val ) ) ) = 1 ) )
       IF ((substring (2 ,1 ,trim (ce.result_val ) ) IN (" " ,
       "+" ) ) ) ob->visit[cnt ].gluc = substring (1 ,2 ,trim (ce.result_val ) )
       ELSE ob->visit[cnt ].gluc = substring (1 ,4 ,trim (ce.result_val ) )
       ENDIF
      ELSE ob->visit[cnt ].gluc = trim (ce.result_val )
      ENDIF
      ,
      IF ((size (trim (ce.result_val ) ) > 10 ) ) lurineglucnt = (lurineglucnt + 1 ) ,stat =
       alterlist (long_glucose->rec ,lurineglucnt ) ,long_glucose->rec[lurineglucnt ].date =
       date_formated ,long_glucose->rec[lurineglucnt ].gluc = trim (ce.result_val ) ,ob->visit[cnt ].
       gluc = concat ("*" ,substring (1 ,3 ,ce.result_val ) ,"..." )
      ENDIF
      ,
      ob->visit[cnt ].smarturinegluc = trim (ce.result_val )
     OF protein_urine_dipstick :
      IF ((isnumeric (substring (1 ,1 ,trim (ce.result_val ) ) ) = 1 ) )
       IF ((substring (2 ,1 ,trim (ce.result_val ) ) IN (" " ,
       "+" ) ) ) ob->visit[cnt ].prot = substring (1 ,2 ,trim (ce.result_val ) )
       ELSE ob->visit[cnt ].prot = substring (1 ,4 ,trim (ce.result_val ) )
       ENDIF
      ELSE ob->visit[cnt ].prot = trim (ce.result_val )
      ENDIF
      ,
      IF ((size (ob->visit[cnt ].prot ) > 28 ) ) ob->visit[cnt ].prot = cseechart
      ENDIF
      ,
      IF ((size (trim (ce.result_val ) ) > 10 ) ) lurineprocnt = (lurineprocnt + 1 ) ,stat =
       alterlist (long_protien->rec ,lurineprocnt ) ,long_protien->rec[lurineprocnt ].date =
       date_formated ,long_protien->rec[lurineprocnt ].prot = trim (ce.result_val ) ,ob->visit[cnt ].
       prot = concat ("*" ,substring (1 ,3 ,ce.result_val ) ,"..." )
      ENDIF
      ,
      ob->visit[cnt ].smarturineprot = trim (ce.result_val )
     OF next_visit :
      IF ((nv_ind = 0 ) )
       IF ((ce.clinical_event_id > 0 ) ) nv_ind = 1 ,
        IF ((ce.result_status_cd = modified ) ) ob->visit[cnt ].nxvisit = concat ("+" ,trim (
           getformattedvalue (ce.result_val ) ) ," " ,trim (ce_result_units_cd ) ,modfromcaption ,
          " " ,date_formated )
        ELSE ob->visit[cnt ].nxvisit = concat ("+" ,trim (getformattedvalue (ce.result_val ) ) ," " ,
          trim (ce_result_units_cd ) ,fromcaption ," " ,date_formated )
        ENDIF
       ELSE ob->visit[cnt ].nxvisit = snot_documented
       ENDIF
      ENDIF
      ,
      IF ((stand_alone_ind = 1 ) ) ob->visit[cnt ].nxvisit = concat ("+" ,trim (getformattedvalue (ce
          .result_val ) ) ," " ,trim (ce_result_units_cd ) ,fromcaption ," " ,date_formated )
      ENDIF
    ENDCASE
    ,
    IF ((trim (cdl.label_name ) != "" )
    AND isvalidfetalresult (ce.event_end_dt_tm ,cdl.ce_dynamic_label_id ) )
     IF ((cdl.label_status_cd = ce_dyn_label_active_cd ) ) pos = locateval (s_num ,s_start ,size (ob
        ->visit[cnt ].addt_fetus ,5 ) ,cdl.label_seq_nbr ,ob->visit[cnt ].addt_fetus[s_num ].seq ) ,
      IF ((pos = 0 ) ) addt_fetus_cnt = (addt_fetus_cnt + 1 ) ,stat = alterlist (ob->visit[cnt ].
        addt_fetus ,addt_fetus_cnt ) ,ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].fhr = " " ,ob->
       visit[cnt ].addt_fetus[addt_fetus_cnt ].pres = snot_documented ,ob->visit[cnt ].addt_fetus[
       addt_fetus_cnt ].fetal_mvmt = snot_documented ,ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].
       smartfhr = " "
      ELSE addt_fetus_cnt = pos
      ENDIF
      ,
      IF ((((ccki = fhr_baseline ) ) OR ((ccki = fhr ) )) ) ob->visit[cnt ].addt_fetus[
       addt_fetus_cnt ].fhr = ob->visit[cnt ].fhr ,ob->visit[cnt ].fhr = " " ,ob->visit[cnt ].
       addt_fetus[addt_fetus_cnt ].smartfhr = ob->visit[cnt ].smartfhr ,ob->visit[cnt ].smartfhr =
       " "
      ELSEIF ((ccki = fetal_presentation ) ) ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].pres = ob->
       visit[cnt ].pres ,ob->visit[cnt ].pres = " "
      ELSEIF ((ccki = fetal_activity ) ) ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].fetal_mvmt = ob
       ->visit[cnt ].fetal_mvmt ,ob->visit[cnt ].fetal_mvmt = snot_documented ,ob->visit[cnt ].
       addt_fetus[addt_fetus_cnt ].smartfetal_mvmt = ob->visit[cnt ].smartfetal_mvmt ,ob->visit[cnt ]
       .smartfetal_mvmt = snot_documented
      ENDIF
      ,
      IF ((size (trim (cdl.label_name ) ) > 7 ) ) ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].baby =
       substring ((size (trim (cdl.label_name ) ) - 6 ) ,7 ,trim (cdl.label_name ) )
      ELSE ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].baby = trim (cdl.label_name )
      ENDIF
      ,ob->visit[cnt ].addt_fetus[addt_fetus_cnt ].seq = cdl.label_seq_nbr
     ENDIF
    ENDIF
   FOOT  ce_event_end_dt
    IF ((ob->visit[cnt ].sys_bp != " " )
    AND (ob->visit[cnt ].dia_bp != " " ) )
     IF ((ob->visit[cnt ].sys_bp_c = "N" )
     AND (ob->visit[cnt ].dia_bp_c = "N" ) ) ob->visit[cnt ].bp = trim (concat (trim (ob->visit[cnt ]
         .sys_bp ) ,"/" ,trim (ob->visit[cnt ].dia_bp ) ) ) ,
      IF ((size (trim (ob->visit[cnt ].bp ) ) > 7 ) ) lbpnomodifycnt = (lbpnomodifycnt + 1 ) ,stat =
       alterlist (long_bloodpressure_n->rec ,lbpnomodifycnt ) ,long_bloodpressure_n->rec[
       lbpnomodifycnt ].date = date_formated ,long_bloodpressure_n->rec[lbpnomodifycnt ].bp = trim (
        ob->visit[cnt ].bp ) ,ob->visit[cnt ].bp = concat ("*" ,substring (1 ,3 ,ob->visit[cnt ].bp
         ) ,"..." )
      ELSE ob->visit[cnt ].bp = trim (concat (trim (ob->visit[cnt ].sys_bp ) ,"/" ,trim (ob->visit[
          cnt ].dia_bp ) ) )
      ENDIF
     ELSE
      IF ((size (trim (ob->visit[cnt ].bp ) ) > 3 ) ) lbpyesmodifycnt = (lbpyesmodifycnt + 1 ) ,stat
       = alterlist (long_bloodpressure_y->rec ,lbpyesmodifycnt ) ,long_bloodpressure_y->rec[
       lbpyesmodifycnt ].date = date_formated ,long_bloodpressure_y->rec[lbpyesmodifycnt ].bp = trim
       (ob->visit[cnt ].bp ) ,ob->visit[cnt ].bp = concat ("*" ,substring (1 ,3 ,ob->visit[cnt ].bp
         ) ,"..." )
      ELSE ob->visit[cnt ].bp = trim (concat (trim (ob->visit[cnt ].sys_bp ) ,"/" ,trim (ob->visit[
          cnt ].dia_bp ) ) )
      ENDIF
     ENDIF
    ENDIF
    ,
    IF ((ob->visit[cnt ].wt_kg != " " )
    AND (ob->visit[cnt ].wt_lbs != " " ) ) ob->visit[cnt ].wt = trim (concat (trim (ob->visit[cnt ].
        wt_lbs ) ,"|" ,trim (ob->visit[cnt ].wt_kg ) ) ) ,
     IF ((size (trim (ob->visit[cnt ].wt ) ) > 30 ) ) lweightcnt = (lweightcnt + 1 ) ,stat =
      alterlist (long_weight->rec ,lweightcnt ) ,long_weight->rec[lweightcnt ].date = date_formated ,
      long_weight->rec[lweightcnt ].wt = trim (concat (trim (ob->visit[cnt ].wt_lbs ) ,"(" ,
        lbscaption ,")" , " | " ,trim (ob->visit[cnt ].wt_kg ) ,"(" ,kgcaption ,")" ) ) ,ob->visit[cnt ]
      .wt = concat ("*" ,substring (1 ,3 ,ob->visit[cnt ].wt ) ,"..." )
     ELSE ob->visit[cnt ].wt = trim (concat (trim (ob->visit[cnt ].wt_lbs ) ," | " ,trim (ob->visit[
         cnt ].wt_kg ) ) )
     ENDIF
    ENDIF
    ,
    IF ((ega_found = 0 ) ) ob->visit[cnt ].ega = snot_documented
    ELSEIF ((ega_found = 1 ) )
     IF (ispatientdelivered (null ) ) result_dt_tm = dcp_reply->gestation_info[1 ].delivery_date
     ELSE result_dt_tm = cnvtdatetime (curdate ,curtime )
     ENDIF
     ,result_days_diff = round (datetimediff (result_dt_tm ,ce.event_end_dt_tm ) ,0 ) ,result_ega =
     cnvtint ((current_ega_days - result_days_diff ) ) ,
     IF ((result_ega > 0 ) ) ob->visit[cnt ].ega_weeks = trim (build ((result_ega / 7 ) ,cweeks ) ) ,
      ob->visit[cnt ].ega_days = trim (build (mod (result_ega ,7 ) ,cdays ) ) ,ob->visit[cnt ].ega =
      build (ob->visit[cnt ].ega_weeks ,ob->visit[cnt ].ega_days ) ,
      IF ((size (trim (ob->visit[cnt ].ega ) ) > 5 ) ) legacnt = (legacnt + 1 ) ,stat = alterlist (
        long_ega->rec ,legacnt ) ,long_ega->rec[legacnt ].date = date_formated ,long_ega->rec[
       legacnt ].ega = concat (trim (ob->visit[cnt ].ega ) ) ,ob->visit[cnt ].ega = concat ("*" ,
        substring (1 ,3 ,ob->visit[cnt ].ega ) ,"..." )
      ELSE ob->visit[cnt ].ega = build (ob->visit[cnt ].ega_weeks ,ob->visit[cnt ].ega_days )
      ENDIF
     ELSE ob->visit[cnt ].ega = snot_documented
     ENDIF
    ENDIF
   FOOT REPORT
    ob->visit_cnt = cnt
   WITH nocounter
  ;end select
  IF (validate (debug_ind ,0 ) )
   CALL echorecord (ob )
   CALL echorecord (long_pres_part )
   CALL echorecord (long_fetal_mvmt )
   CALL echorecord (long_preterm_ss )
  ENDIF
  IF ((curqual < 1 ) )
   CALL writenodata (null )
  ENDIF
  SET reply->text = concat (reply->text ,rsechead ,colornavy ,captions_title ,reol )
  IF ((stand_alone_ind = 1 ) )
   IF ((honor_org_security_flag = 1 ) )
    SET reply->text = concat (reply->text ,reol ,colorgrey ,whsecuritydisclaim ,wr ,reol )
   ENDIF
  ENDIF
  SET reply->text = concat (reply->text ,reol )
  IF ((stand_alone_ind = 0 ) )
   SET reply->text = concat (reply->text ,block_start ,wsb ,color0 ,captions1 ,captions2 )
   FOR (x = 1 TO ob->visit_cnt )
    SET reply->text = concat (reply->text ,row_start ,row_type2 ,color0 ,cell_start ,cell_text_left ,
     ob->visit[x ].date ,cell_end ,colorgrey ,cell_start ,cell_text_left ,ob->visit[x ].ega ,
     cell_end ,cell_start ,cell_text_left ,ob->visit[x ].fundal_ht ,cell_end ,cell_start ,
     cell_text_left ,ob->visit[x ].preterm_ss ,cell_end ,cell_start ,cell_text_left ,ob->visit[x ].
     dil ,cell_end ,cell_start ,cell_text_left ,ob->visit[x ].eff ,cell_end ,cell_start ,
     cell_text_left ,ob->visit[x ].sta ,cell_end ,cell_start ,cell_text_left ,trim (ob->visit[x ].bp
      ,7 ) ,cell_end ,cell_start ,cell_text_left ,trim (ob->visit[x ].wt ,7 ) ,rtab,rtab,cell_end ,cell_start , ;001
     cell_text_left ,ob->visit[x ].gluc ,cell_end ,cell_start ,cell_text_left ,ob->visit[x ].prot ,
     cell_end )
    FOR (y = 1 TO size (ob->visit[x ].addt_fetus ,5 ) )
     IF ((y = 1 ) )
      SET reply->text = concat (reply->text ,cell_start ,cell_text_left ,ob->visit[x ].addt_fetus[y ]
       .baby ," = " ,ob->visit[x ].addt_fetus[y ].fhr ,cell_end ,cell_start ,cell_text_left ,trim (ob
        ->visit[x ].addt_fetus[y ].fetal_mvmt ,7 ) ,cell_end ,cell_start ,cell_text_left ,ob->visit[
       x ].addt_fetus[y ].pres ,cell_end ,row_end )
     ELSE
      SET reply->text = concat (reply->text ,row_start ,row_type2 ,color0 ,cell_start ,cell_end ,
       colorgrey ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,
       cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,
       cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_text_left ,ob->visit[x
       ].addt_fetus[y ].baby ," = " ,ob->visit[x ].addt_fetus[y ].fhr ,cell_end ,cell_start ,
       cell_text_left ,trim (ob->visit[x ].addt_fetus[y ].fetal_mvmt ,7 ) ,cell_end ,cell_start ,
       cell_text_left ,ob->visit[x ].addt_fetus[y ].pres ,cell_end ,row_end )
     ENDIF
    ENDFOR
    IF ((size (ob->visit[x ].addt_fetus ,5 ) = 0 ) )
     SET reply->text = concat (reply->text ,cell_start ,snot_documented ,cell_end ,cell_start ,
      snot_documented ,cell_end ,cell_start ,snot_documented ,cell_end ,row_end )
    ENDIF
   ENDFOR
   SET reply->text = concat (reply->text ,row_start ,row_type3 ,cell_start ,cell_end ,cell_start ,
    cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end
    ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,
    cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,cell_start ,cell_end ,row_end
    )
   SET reply->text = concat (reply->text ,block_end ,reol )
   FOR (z = 1 TO ob->visit_cnt )
    IF ((ob->visit[z ].nxvisit != " " ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,nextvisitcaption ,colorgrey ,"  " ,ob->
      visit[z ].nxvisit ,reol )
    ENDIF
   ENDFOR
   IF ((size (long_ega->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longegacaption ,reol )
    FOR (lf = 1 TO size (long_ega->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_ega->rec[lf ].date ,rtab ,colorgrey ,
      long_ega->rec[lf ].ega ,reol )
    ENDFOR
    SET stat = alterlist (long_ega->rec ,0 )
   ENDIF
   IF ((size (long_pres_part->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longfetprescaption ,reol )
    FOR (lz = 1 TO size (long_pres_part->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_pres_part->rec[lz ].date ,rtab ,
      colorgrey ,long_pres_part->rec[lz ].pres_part ,reol )
    ENDFOR
    SET stat = alterlist (long_pres_part->rec ,0 )
   ENDIF
   IF ((size (long_fundal_height->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longfundalheightcaption ,reol )
    FOR (lf = 1 TO size (long_fundal_height->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_fundal_height->rec[lf ].date ,rtab ,
      colorgrey ,long_fundal_height->rec[lf ].fundal_ht ,reol )
    ENDFOR
    SET stat = alterlist (long_fundal_height->rec ,0 )
   ENDIF
   IF ((size (long_preterm_ss->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longpretermcaption ,reol )
    FOR (lf = 1 TO size (long_preterm_ss->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_preterm_ss->rec[lf ].date ,rtab ,
      colorgrey ,long_preterm_ss->rec[lf ].preterm_ss ,reol )
    ENDFOR
    SET stat = alterlist (long_preterm_ss->rec ,0 )
   ENDIF
   IF ((size (long_cervix_dil->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longcervixdilationcaption ,reol )
    FOR (lf = 1 TO size (long_cervix_dil->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_cervix_dil->rec[lf ].date ,rtab ,
      colorgrey ,long_cervix_dil->rec[lf ].dil ,reol )
    ENDFOR
    SET stat = alterlist (long_cervix_dil->rec ,0 )
   ENDIF
   IF ((size (long_cervix_effacement->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longcervixeffacementcaption ,reol )
    FOR (lf = 1 TO size (long_cervix_effacement->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_cervix_effacement->rec[lf ].date ,rtab
      ,colorgrey ,long_cervix_effacement->rec[lf ].eff ,reol )
    ENDFOR
    SET stat = alterlist (long_cervix_effacement->rec ,0 )
   ENDIF
   IF ((size (long_fetal_station->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longfetalstationcaption ,reol )
    FOR (lf = 1 TO size (long_fetal_station->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_fetal_station->rec[lf ].date ,rtab ,
      colorgrey ,long_fetal_station->rec[lf ].sta ,reol )
    ENDFOR
    SET stat = alterlist (long_fetal_station->rec ,0 )
   ENDIF
   IF ((size (long_bloodpressure_n->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longbloodpressuren ,reol )
    FOR (lf = 1 TO size (long_bloodpressure_n->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_bloodpressure_n->rec[lf ].date ,rtab ,
      colorgrey ,long_bloodpressure_n->rec[lf ].bp ,reol )
    ENDFOR
    SET stat = alterlist (long_bloodpressure_n->rec ,0 )
   ENDIF
   IF ((size (long_bloodpressure_y->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longbloodpressurey ,reol )
    FOR (lf = 1 TO size (long_bloodpressure_y->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_bloodpressure_y->rec[lf ].date ,rtab ,
      colorgrey ,long_bloodpressure_y->rec[lf ].bp ,reol )
    ENDFOR
    SET stat = alterlist (long_bloodpressure_y->rec ,0 )
   ENDIF
   IF ((size (long_weight->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longweightcaption ,reol )
    FOR (lf = 1 TO size (long_weight->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_weight->rec[lf ].date ,rtab ,colorgrey
      ,long_weight->rec[lf ].wt ,reol )
    ENDFOR
    SET stat = alterlist (long_weight->rec ,0 )
   ENDIF
   IF ((size (long_glucose->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longglucosdecaption ,reol )
    FOR (lf = 1 TO size (long_glucose->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_glucose->rec[lf ].date ,rtab ,
      colorgrey ,long_glucose->rec[lf ].gluc ,reol )
    ENDFOR
    SET stat = alterlist (long_glucose->rec ,0 )
   ENDIF
   IF ((size (long_protien->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longprotiencaption ,reol )
    FOR (lf = 1 TO size (long_protien->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_protien->rec[lf ].date ,rtab ,
      colorgrey ,long_protien->rec[lf ].prot ,reol )
    ENDFOR
    SET stat = alterlist (long_protien->rec ,0 )
   ENDIF
   IF ((size (long_fhr->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longfhrcaption ,reol )
    FOR (lf = 1 TO size (long_fhr->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_fhr->rec[lf ].date ,rtab ,colorgrey ,
      long_fhr->rec[lf ].fhr ,reol )
    ENDFOR
    SET stat = alterlist (long_fhr->rec ,0 )
   ENDIF
   IF ((size (long_fetal_mvmt->rec ,5 ) > 0 ) )
    SET reply->text = concat (reply->text ,reol ,wrs ,color0 ,longfetalmvmtcaption ,reol )
    FOR (lf = 1 TO size (long_fetal_mvmt->rec ,5 ) )
     SET reply->text = concat (reply->text ,wrs ,color0 ,long_fetal_mvmt->rec[lf ].date ,rtab ,
      colorgrey ,long_fetal_mvmt->rec[lf ].fetal_mvmt ,reol )
    ENDFOR
    SET stat = alterlist (long_fetal_mvmt->rec ,0 )
   ENDIF
   SET reply->text = concat (reply->text ,rpard )
  ENDIF
  IF ((stand_alone_ind = 1 ) )
   SET reply->text = concat (reply->text ,rsubsechead ,colornavy ,smart_captions_title ,reol )
   FOR (visitresults = 1 TO ob->visit_cnt )
    SET reply->text = concat (reply->text ,reol )
    SET reply->text = concat (reply->text ,rsubsechead ,colornavy ,wb ,smartdatecaption )
    SET reply->text = concat (reply->text ," " ,wb ,ob->visit[visitresults ].date ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartegacaption )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].ega ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartweightcaption ," (" ,smartlbskgcaption ,
     "):" )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].wt ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartfundalcaption ," (" ,smarthtcaption ,"):"
     )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].fundal_ht ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartbpcaption ," (" ,smartmmhgcaption ,"):" )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].bp ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartcervixcaption ," (" ,smartdilcaption ,"/"
     )
    SET reply->text = concat (reply->text ,colorgrey ,smarteffcaption ,"/" ,smartstatcaption ,")" ,
     ":" )
    SET reply->text = concat (reply->text ,wr ,trim (ob->visit[visitresults ].dil ) ,"/" ,trim (ob->
      visit[visitresults ].eff ) ,"/" ,ob->visit[visitresults ].sta ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartpretermcaption )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].smartpreterm_ss ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smarturineglucosecaption )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].smarturinegluc ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smarturineproteincaption )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].smarturineprot ,reol )
    SET reply->text = concat (reply->text ,colorgrey ,smartnextvisitcaption )
    SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].nxvisit )
    FOR (visitbabyresults = 1 TO size (ob->visit[visitresults ].addt_fetus ,5 ) )
     SET reply->text = concat (reply->text ,reol )
     SET reply->text = concat (reply->text ,colorgrey )
     SET reply->text = concat (reply->text ,ob->visit[visitresults ].addt_fetus[visitbabyresults ].
      baby ,reol ,rtab )
     SET reply->text = concat (reply->text ,colorgrey ,smartfhrcaption )
     SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].addt_fetus[
      visitbabyresults ].smartfhr ,reol ,rtab )
     SET reply->text = concat (reply->text ,colorgrey ,smartfetalmvmtcaption )
     SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].addt_fetus[
      visitbabyresults ].smartfetal_mvmt ,reol ,rtab )
     SET reply->text = concat (reply->text ,colorgrey ,smartfetalprestcaption )
     SET reply->text = concat (reply->text ," " ,wr ,ob->visit[visitresults ].addt_fetus[
      visitbabyresults ].pres ,reol )
    ENDFOR
    SET reply->text = concat (reply->text ,reol ,reol )
   ENDFOR
  ENDIF
 END ;Subroutine
#exit_script
 IF ((stand_alone_ind = 1 ) )
  SET reply->text = concat (reply->text ,rtfeof )
 ENDIF
 SET script_version = "001"
END GO

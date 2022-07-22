/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_mak_unauth_doc_driver.prg
  Object name:        cov_mak_unauth_doc_driver
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   08/23/2019  Chad Cummings			added validate for TEMP record structure
******************************************************************************/
DROP PROGRAM cov_mak_unauth_doc_driver :dba GO
CREATE PROGRAM cov_mak_unauth_doc_driver :dba
 RECORD reply (
   1 file_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD tdo_request_struct
 RECORD tdo_request_struct (
   1 encntr_qual [* ]
     2 encntr_id = f8
 )
 FREE RECORD tdo_reply_struct
 RECORD tdo_reply_struct (
   1 encntr_qual [* ]
     2 encntr_id = f8
     2 term_digit_nbr = i4
     2 term_digit_format = vc
 )
 FREE RECORD age_request_struct
 RECORD age_request_struct (
   1 total_qual [* ]
     2 encntr_id = f8
     2 physician_id = f8
 )
 FREE RECORD age_reply_struct
 RECORD age_reply_struct (
   1 encntr_qual [* ]
     2 encntr_id = f8
     2 physician_id = f8
     2 chart_age = i2
 )
 if (not(validate(temp,0))) ;001
 FREE RECORD temp
 RECORD temp (
   1 qual [* ]
     2 encntr_id = f8
     2 person_id = f8
     2 mrn_formatted = c20
     2 fin_formatted = c20
     2 name_full_formatted = c35
     2 encntr_type_disp = c15
     2 visit_age = i2
     2 visit_alloc_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 tdo = c20
     2 organization_id = f8
     2 org_name = vc
     2 doc_qual [* ]
       3 clinical_event_id = f8
       3 event_disp = c20
       3 valid_from_dt_tm = dq8
 )
 endif ;001
 DECLARE temp_time = c6 WITH public ,noconstant ("" )
 DECLARE hold_file_name = c13 WITH public ,noconstant ("" )
 DECLARE hold_file = c23 WITH public ,noconstant ("" )
 DECLARE start_dt_tm = q8 WITH public ,noconstant (cnvtdatetime ("" ) )
 DECLARE end_dt_tm = q8 WITH public ,noconstant (cnvtdatetime ("" ) )
 DECLARE system_dt_tm = q8 WITH public ,noconstant (cnvtdatetime ("" ) )
 DECLARE unauth_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE sign_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE requested_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE mrn_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE fin_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE encntr_qual_cnt = i4 WITH public ,noconstant (0 )
 DECLARE e_cnt = i4 WITH public ,noconstant (0 )
 DECLARE tdo_qual_cnt = i4 WITH public ,noconstant (0 )
 DECLARE age_qual_cnt = i4 WITH public ,noconstant (0 )
 DECLARE age_cnt = i4 WITH public ,noconstant (0 )
 DECLARE org_qual_cnt = i4 WITH public ,noconstant (0 )
 DECLARE org_cnt = i4 WITH public ,noconstant (0 )
 DECLARE multi_facility_ind = i2 WITH public ,noconstant (0 )
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
 SET handle = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 SET temp_time = cnvtstring (curtime3 ,6 ,0 ,r )
 SET hold_file_name = build ("HIM" ,temp_time ,".DAT" )
 SET hold_file = build ("CER_PRINT:" ,hold_file_name )
 SET stat = uar_get_meaning_by_codeset (8 ,"UNAUTH" ,1 ,unauth_cd )
 SET stat = uar_get_meaning_by_codeset (21 ,"SIGN" ,1 ,sign_cd )
 SET stat = uar_get_meaning_by_codeset (103 ,"REQUESTED" ,1 ,requested_cd )
 SET stat = uar_get_meaning_by_codeset (319 ,"MRN" ,1 ,mrn_cd )
 SET stat = uar_get_meaning_by_codeset (319 ,"FIN NBR" ,1 ,fin_cd )
 SET start_dt_tm = cnvtdatetime (request->start_dt_tm )
 SET end_dt_tm = cnvtdatetime (request->end_dt_tm )
 SET system_dt_tm = cnvtdatetime (curdate ,curtime3 )
 SET org_qual_cnt = size (request->org_qual ,5 )
 IF ((org_qual_cnt > 0 ) )
  FOR (org_cnt = 1 TO org_qual_cnt )
   IF ((request->org_qual[org_cnt ].organization_id > 0 ) )
    SET multi_facility_ind = 1
    SET org_cnt = org_qual_cnt
   ENDIF
  ENDFOR
 ENDIF
 IF ((multi_facility_ind != 1 ) )
  SET org_qual_cnt = 1
  SET stat = alterlist (request->org_qual ,org_qual_cnt )
  SET request->org_qual[1 ].organization_id = 0.0
 ENDIF
 SET stat = alterlist (temp->qual ,10 )
 SET stat = alterlist (tdo_request_struct->encntr_qual ,10 )
 SET stat = alterlist (age_request_struct->total_qual ,10 )
 CASE (request->date_flag )
  OF 1 :
   SELECT INTO "nl:"
    ce.clinical_event_id ,
    ce.event_cd ,
    event_disp = uar_get_code_display (ce.event_cd ) ,
    e.organization_id ,
    ce.valid_from_dt_tm ";;f" ,
    ce.valid_until_dt_tm ";;f" ,
    ce.clinsig_updt_dt_tm ";;f"
    FROM (dummyt d WITH seq = value (org_qual_cnt ) ),
     (clinical_event ce ),
     (encounter e ),
     (him_event_extension hee )
    PLAN (d )
     JOIN (ce
     WHERE (ce.clinsig_updt_dt_tm >= cnvtdatetime (start_dt_tm ) )
     AND (ce.clinsig_updt_dt_tm <= cnvtdatetime (end_dt_tm ) )
     AND (ce.valid_until_dt_tm > cnvtdatetime (system_dt_tm ) )
     AND (ce.result_status_cd = unauth_cd )
     AND ((ce.parent_event_id + 0 ) = ce.event_id )
     AND NOT (EXISTS (
     (SELECT
      cep.ce_event_prsnl_id
      FROM (ce_event_prsnl cep )
      WHERE (cep.event_id = ce.event_id )
      AND (cep.valid_until_dt_tm > cnvtdatetime (system_dt_tm ) )
      AND ((cep.action_type_cd + 0 ) = sign_cd )
      AND ((cep.action_status_cd + 0 ) = requested_cd ) ) ) ) )
     JOIN (e
     WHERE (e.encntr_id = ce.encntr_id )
     AND ((e.person_id + 0 ) = ce.person_id )
     AND (((multi_facility_ind = 1 )
     AND ((e.organization_id + 0 ) = request->org_qual[d.seq ].organization_id ) ) OR ((
     multi_facility_ind != 1 ) ))
     AND (e.beg_effective_dt_tm <= cnvtdatetime (system_dt_tm ) )
     AND (e.end_effective_dt_tm >= cnvtdatetime (system_dt_tm ) )
     AND (e.active_ind = 1 ) )
     JOIN (hee
     WHERE (hee.event_cd = ce.event_cd )
     AND ((((hee.organization_id + 0 ) = e.organization_id ) ) OR (((hee.organization_id + 0 ) = 0 )
     AND NOT (EXISTS (
     (SELECT
      oer.organization_id
      FROM (org_event_set_reltn oer )
      WHERE (oer.organization_id = e.organization_id )
      AND (oer.active_ind = 1 ) ) ) ) )) )
    ORDER BY ce.encntr_id
    HEAD ce.encntr_id
     encntr_qual_cnt = (encntr_qual_cnt + 1 ) ,
     IF ((mod (encntr_qual_cnt ,10 ) = 0 )
     AND (encntr_qual_cnt != 0 ) ) stat = alterlist (temp->qual ,(encntr_qual_cnt + 9 ) ) ,stat =
      alterlist (tdo_request_struct->encntr_qual ,(encntr_qual_cnt + 9 ) ) ,stat = alterlist (
       age_request_struct->total_qual ,(encntr_qual_cnt + 9 ) )
     ENDIF
     ,tdo_request_struct->encntr_qual[encntr_qual_cnt ].encntr_id = e.encntr_id ,age_request_struct->
     total_qual[encntr_qual_cnt ].encntr_id = e.encntr_id ,temp->qual[encntr_qual_cnt ].encntr_id = e
     .encntr_id ,temp->qual[encntr_qual_cnt ].person_id = e.person_id ,temp->qual[encntr_qual_cnt ].
     disch_dt_tm = e.disch_dt_tm ,temp->qual[encntr_qual_cnt ].organization_id = e.organization_id ,
     IF ((request->debug_ind = 1 ) ) doc_qual_cnt = 0 ,stat = alterlist (temp->qual[encntr_qual_cnt ]
       .doc_qual ,0 )
     ENDIF
    DETAIL
     IF ((request->debug_ind = 1 ) ) doc_qual_cnt = (doc_qual_cnt + 1 ) ,stat = alterlist (temp->
       qual[encntr_qual_cnt ].doc_qual ,doc_qual_cnt ) ,temp->qual[encntr_qual_cnt ].doc_qual[
      doc_qual_cnt ].clinical_event_id = ce.clinical_event_id ,temp->qual[encntr_qual_cnt ].doc_qual[
      doc_qual_cnt ].event_disp = event_disp ,temp->qual[encntr_qual_cnt ].doc_qual[doc_qual_cnt ].
      valid_from_dt_tm = ce.valid_from_dt_tm
     ENDIF
    WITH nocounter
   ;end select
  OF 2 :
   SELECT INTO "nl:"
    e.encntr_id ,
    ce.clinical_event_id ,
    ce.event_cd ,
    event_disp = uar_get_code_display (ce.event_cd ) ,
    ce.valid_from_dt_tm ";;f" ,
    ce.valid_until_dt_tm ";;f" ,
    ce.clinsig_updt_dt_tm ";;f"
    FROM (dummyt d WITH seq = value (org_qual_cnt ) ),
     (encounter e ),
     (clinical_event ce ),
     (him_event_extension hee )
    PLAN (d )
     JOIN (e
     WHERE (e.disch_dt_tm >= cnvtdatetime (start_dt_tm ) )
     AND (e.disch_dt_tm <= cnvtdatetime (end_dt_tm ) )
     AND (((multi_facility_ind = 1 )
     AND ((e.organization_id + 0 ) = request->org_qual[d.seq ].organization_id ) ) OR ((
     multi_facility_ind != 1 ) ))
     AND (e.beg_effective_dt_tm <= cnvtdatetime (system_dt_tm ) )
     AND (e.end_effective_dt_tm >= cnvtdatetime (system_dt_tm ) )
     AND (e.active_ind = 1 ) )
     JOIN (ce
     WHERE (ce.encntr_id = e.encntr_id )
     AND (ce.person_id = e.person_id )
     AND (ce.valid_until_dt_tm > cnvtdatetime (system_dt_tm ) )
     AND (ce.result_status_cd = unauth_cd )
     AND ((ce.parent_event_id + 0 ) = ce.event_id )
     AND NOT (EXISTS (
     (SELECT
      cep.ce_event_prsnl_id
      FROM (ce_event_prsnl cep )
      WHERE (cep.event_id = ce.event_id )
      AND (cep.valid_until_dt_tm > cnvtdatetime (system_dt_tm ) )
      AND ((cep.action_type_cd + 0 ) = sign_cd )
      AND ((cep.action_status_cd + 0 ) = requested_cd ) ) ) ) )
     JOIN (hee
     WHERE (hee.event_cd = ce.event_cd )
     AND ((((hee.organization_id + 0 ) = e.organization_id ) ) OR (((hee.organization_id + 0 ) = 0 )
     AND NOT (EXISTS (
     (SELECT
      oer.organization_id
      FROM (org_event_set_reltn oer )
      WHERE (oer.organization_id = e.organization_id )
      AND (oer.active_ind = 1 ) ) ) ) )) )
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     encntr_qual_cnt = (encntr_qual_cnt + 1 ) ,
     IF ((mod (encntr_qual_cnt ,10 ) = 0 )
     AND (encntr_qual_cnt != 0 ) ) stat = alterlist (temp->qual ,(encntr_qual_cnt + 9 ) ) ,stat =
      alterlist (tdo_request_struct->encntr_qual ,(encntr_qual_cnt + 9 ) ) ,stat = alterlist (
       age_request_struct->total_qual ,(encntr_qual_cnt + 9 ) )
     ENDIF
     ,tdo_request_struct->encntr_qual[encntr_qual_cnt ].encntr_id = e.encntr_id ,age_request_struct->
     total_qual[encntr_qual_cnt ].encntr_id = e.encntr_id ,temp->qual[encntr_qual_cnt ].encntr_id = e
     .encntr_id ,temp->qual[encntr_qual_cnt ].person_id = e.person_id ,temp->qual[encntr_qual_cnt ].
     disch_dt_tm = e.disch_dt_tm ,temp->qual[encntr_qual_cnt ].organization_id = e.organization_id ,
     IF ((request->debug_ind = 1 ) ) doc_qual_cnt = 0 ,stat = alterlist (temp->qual[encntr_qual_cnt ]
       .doc_qual ,0 )
     ENDIF
    DETAIL
     IF ((request->debug_ind = 1 ) ) doc_qual_cnt = (doc_qual_cnt + 1 ) ,stat = alterlist (temp->
       qual[encntr_qual_cnt ].doc_qual ,doc_qual_cnt ) ,temp->qual[encntr_qual_cnt ].doc_qual[
      doc_qual_cnt ].clinical_event_id = ce.clinical_event_id ,temp->qual[encntr_qual_cnt ].doc_qual[
      doc_qual_cnt ].event_disp = event_disp ,temp->qual[encntr_qual_cnt ].doc_qual[doc_qual_cnt ].
      valid_from_dt_tm = ce.valid_from_dt_tm
     ENDIF
    WITH nocounter
   ;end select
 ENDCASE
 SET stat = alterlist (temp->qual ,encntr_qual_cnt )
 SET stat = alterlist (tdo_request_struct->encntr_qual ,encntr_qual_cnt )
 SET stat = alterlist (age_request_struct->total_qual ,encntr_qual_cnt )
 IF ((encntr_qual_cnt = 0 ) )
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1 ].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "CLINICAL_EVENT"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "DUMMYT"
  GO TO exit_script
 ENDIF
 IF ((request->sort_flag = 1 ) )
  EXECUTE him_get_terminal_digits
  SET tdo_qual_cnt = size (tdo_reply_struct->encntr_qual ,5 )
  SELECT INTO "nl:"
   d_tmp.seq ,
   encntr_id = temp->qual[d_tmp.seq ].encntr_id ,
   d_tdo.seq ,
   tdo = tdo_reply_struct->encntr_qual[d_tdo.seq ].term_digit_format
   FROM (dummyt d_tdo WITH seq = value (tdo_qual_cnt ) ),
    (dummyt d_tmp WITH seq = value (encntr_qual_cnt ) )
   PLAN (d_tdo )
    JOIN (d_tmp
    WHERE (temp->qual[d_tmp.seq ].encntr_id = tdo_reply_struct->encntr_qual[d_tdo.seq ].encntr_id )
    )
   DETAIL
    temp->qual[d_tmp.seq ].tdo = tdo
   WITH nocounter
  ;end select
 ENDIF
 EXECUTE him_get_chart_age
 SET age_qual_cnt = size (age_reply_struct->encntr_qual ,5 )
 FOR (age_cnt = 1 TO age_qual_cnt )
  SET temp->qual[age_cnt ].visit_age = age_reply_struct->encntr_qual[age_cnt ].chart_age
 ENDFOR
 SELECT INTO "nl:"
  e.encntr_id ,
  per.person_id ,
  mrn_formatted = substring (1 ,20 ,trim (cnvtalias (ea_mrn.alias ,ea_mrn.alias_pool_cd ) ) ) ,
  fin_formatted = substring (1 ,20 ,trim (cnvtalias (ea_fin.alias ,ea_fin.alias_pool_cd ) ) ) ,
  name_full_formatted = substring (1 ,35 ,per.name_full_formatted ) ,
  encntr_type_disp = substring (1 ,15 ,uar_get_code_display (e.encntr_type_cd ) ) ,
  visit_alloc_dt_tm =
  IF ((cp.allocation_dt_flag = 0 )
  AND (cnvtdatetime (cp.allocation_dt_tm ) > 0 ) ) cp.allocation_dt_tm
  ELSEIF ((cp.allocation_dt_flag = 1 )
  AND (cnvtdatetime (e.reg_dt_tm ) > 0 ) ) (cnvtdatetime (e.reg_dt_tm ) + cp.allocation_dt_modifier
   )
  ELSEIF ((cp.allocation_dt_flag = 2 )
  AND (cnvtdatetime (e.disch_dt_tm ) > 0 ) ) (cnvtdatetime (e.reg_dt_tm ) + cp
   .allocation_dt_modifier )
  ENDIF
  FROM (dummyt d WITH seq = value (encntr_qual_cnt ) ),
   (encounter e ),
   (person per ),
   (organization org ),
   (chart_process cp ),
   (encntr_alias ea_mrn ),
   (encntr_alias ea_fin )
  PLAN (d )
   JOIN (e
   WHERE (e.encntr_id = temp->qual[d.seq ].encntr_id ) )
   JOIN (per
   WHERE (per.person_id = e.person_id ) )
   JOIN (org
   WHERE (org.organization_id = e.organization_id ) )
   JOIN (cp
   WHERE (cp.encntr_id = outerjoin (e.encntr_id ) )
   AND (cp.beg_effective_dt_tm <= outerjoin (cnvtdatetime (system_dt_tm ) ) )
   AND (cp.end_effective_dt_tm >= outerjoin (cnvtdatetime (system_dt_tm ) ) )
   AND (cp.active_ind = outerjoin (1 ) ) )
   JOIN (ea_mrn
   WHERE (ea_mrn.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea_mrn.encntr_alias_type_cd = outerjoin (mrn_cd ) )
   AND (ea_mrn.beg_effective_dt_tm <= outerjoin (cnvtdatetime (system_dt_tm ) ) )
   AND (ea_mrn.end_effective_dt_tm >= outerjoin (cnvtdatetime (system_dt_tm ) ) )
   AND (ea_mrn.active_ind = outerjoin (1 ) ) )
   JOIN (ea_fin
   WHERE (ea_fin.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea_fin.encntr_alias_type_cd = outerjoin (fin_cd ) )
   AND (ea_fin.beg_effective_dt_tm <= outerjoin (cnvtdatetime (system_dt_tm ) ) )
   AND (ea_fin.end_effective_dt_tm >= outerjoin (cnvtdatetime (system_dt_tm ) ) )
   AND (ea_fin.active_ind = outerjoin (1 ) ) )
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq ].name_full_formatted = name_full_formatted ,temp->qual[d.seq ].encntr_type_disp
   = encntr_type_disp ,temp->qual[d.seq ].org_name = org.org_name ,temp->qual[d.seq ].
   visit_alloc_dt_tm = visit_alloc_dt_tm
  DETAIL
   IF ((ea_mrn.encntr_alias_id > 0 )
   AND (ea_mrn.encntr_alias_id != null ) ) temp->qual[d.seq ].mrn_formatted = mrn_formatted
   ENDIF
   ,
   IF ((ea_fin.encntr_alias_id > 0 )
   AND (ea_fin.encntr_alias_id != null ) ) temp->qual[d.seq ].fin_formatted = fin_formatted
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value (hold_file )
  person_id = temp->qual[d.seq ].person_id ,
  encntr_id = temp->qual[d.seq ].encntr_id ,
  name_full_formatted = temp->qual[d.seq ].name_full_formatted ,
  encntr_type_disp = temp->qual[d.seq ].encntr_type_disp ,
  mrn_formatted = temp->qual[d.seq ].mrn_formatted ,
  fin_formatted = temp->qual[d.seq ].fin_formatted ,
  visit_age = temp->qual[d.seq ].visit_age ,
  visit_alloc_dt_tm = temp->qual[d.seq ].visit_alloc_dt_tm ,
  disch_dt_tm = temp->qual[d.seq ].disch_dt_tm ,
  tdo = temp->qual[d.seq ].tdo ,
  organization_id =
  IF ((multi_facility_ind = 1 ) ) temp->qual[d.seq ].organization_id
  ELSE 0
  ENDIF
  ,org_name =
  IF ((multi_facility_ind = 1 ) ) temp->qual[d.seq ].org_name
  ELSE ""
  ENDIF
  ,sort_order =
  IF ((request->sort_flag = 1 ) ) temp->qual[d.seq ].tdo
  ELSEIF ((request->sort_flag = 2 ) )
   IF ((temp->qual[d.seq ].visit_alloc_dt_tm != cnvtdatetime ("" ) ) ) format (temp->qual[d.seq ].
     visit_age ,"####;P0" )
   ELSE ""
   ENDIF
  ELSEIF ((request->sort_flag = 3 ) ) format (temp->qual[d.seq ].visit_alloc_dt_tm ,"yyyy/mm/dd;;Q"
    )
  ELSEIF ((request->sort_flag = 4 ) ) format (temp->qual[d.seq ].disch_dt_tm ,"yyyy/mm/dd;;Q" )
  ENDIF
  FROM (dummyt d WITH seq = value (encntr_qual_cnt ) )
  ORDER BY org_name ,
   organization_id ,
   sort_order ,
   encntr_id
  HEAD REPORT
   nreportwidth = 131 ,
   i18nreporttitle = uar_i18ngetmessage (i18nhandle ,"key1" ,"UNAUTHENTICATED DOCUMENT REPORT" ) ,
   i18npage = uar_i18ngetmessage (i18nhandle ,"key2" ,"PAGE" ) ,
   CASE (request->date_flag )
    OF 1 :
     i18ndaterange = uar_i18ngetmessage (i18nhandle ,"key3" ,"DOCUMENT UPDATE DATE RANGE" )
    OF 2 :
     i18ndaterange = uar_i18ngetmessage (i18nhandle ,"key4" ,"DISCHARGE DATE RANGE" )
   ENDCASE
   ,i18ndaterange = concat (i18ndaterange ,": " ,format (start_dt_tm ,"@SHORTDATE;;Q" ) ," - " ,
    format (end_dt_tm ,"@SHORTDATE;;Q" ) ) ,
   i18nprinted = uar_i18ngetmessage (i18nhandle ,"key5" ,"PRINTED" ) ,
   i18nprinted = concat (i18nprinted ,": " ,format (system_dt_tm ,"@SHORTDATE;;Q" ) ) ,
   i18nfacility = uar_i18ngetmessage (i18nhandle ,"key15" ,"FACILITY" ) ,
   i18ncontinued = uar_i18ngetmessage (i18nhandle ,"key16" ,"(continued)" ) ,
   i18nmrn = uar_i18ngetmessage (i18nhandle ,"key6" ,"        MRN         " ) ,
   i18nfinancialnumber = uar_i18ngetmessage (i18nhandle ,"key7" ,"  FINANCIAL NUMBER  " ) ,
   i18nname = uar_i18ngetmessage (i18nhandle ,"key8" ,"               NAME                " ) ,
   i18npatienttype = uar_i18ngetmessage (i18nhandle ,"key9" ," PATIENT TYPE  " ) ,
   i18nvisit = uar_i18ngetmessage (i18nhandle ,"key10" ,"VISIT" ) ,
   i18nage = uar_i18ngetmessage (i18nhandle ,"key11" ," AGE " ) ,
   i18nvisitalloc = uar_i18ngetmessage (i18nhandle ,"key12" ,"VISIT ALLOC " ) ,
   i18ndate = uar_i18ngetmessage (i18nhandle ,"key13" ,"    DATE    " ) ,
   i18ndischarge = uar_i18ngetmessage (i18nhandle ,"key14" ," DISCHARGE  " ) ,
   nnewpageind = 0 ,
   norgcontind = 0 ,
   npagecnt = 0 ,
   ncalccol = 0 ,
   ncalcrow = 0 ,
   sdateformated = fillstring (15 ," " ) ,
   nencntrprintedcnt = 0 ,
   doc_qual_cnt = 0 ,
   MACRO (column_headings )
    IF ((multi_facility_ind = 1 )
    AND (row > 56 ) )
     BREAK
    ELSE
     IF ((multi_facility_ind = 1 ) ) row + 2 ,col 000 ,i18nfacility ,ncalccol = size (i18nfacility )
     ,col ncalccol ,":" ,ncalccol = (ncalccol + 2 ) ,col ncalccol ,temp->qual[d.seq ].org_name ,
      IF ((norgcontind = 1 ) ) ncalccol = ((ncalccol + size (temp->qual[d.seq ].org_name ) ) + 1 ) ,
       col ncalccol ,i18ncontinued
      ENDIF
      ,row + 1
     ELSE row + 1
     ENDIF
     ,col 098 ,i18nvisit ,col 105 ,i18nvisitalloc ,col 119 ,i18ndischarge ,row + 1 ,col 000 ,i18nmrn
    ,col 022 ,i18nfinancialnumber ,col 044 ,i18nname ,col 081 ,i18npatienttype ,col 098 ,i18nage ,
     col 105 ,i18ndate ,col 119 ,i18ndate ,row + 1 ,col 000 ,"--------------------" ,col 022 ,
     "--------------------" ,col 044 ,"-----------------------------------" ,col 081 ,
     "---------------" ,col 098 ,"-----" ,col 105 ,"------------" ,col 119 ,"------------" ,row + 1
    ENDIF
   ENDMACRO
  HEAD PAGE
   nnewpageind = 1 ,
   npagecnt = (npagecnt + 1 ) ,
   CALL center (i18nreporttitle ,1 ,nreportwidth ) ,
   ncalccol = (nreportwidth - (size (i18npage ) + 4 ) ) ,
   col ncalccol ,
   i18npage ,
   ncalccol = (ncalccol + (size (i18npage ) + 1 ) ) ,
   col ncalccol ,
   npagecnt "###" ,
   row + 1 ,
   CALL center (i18ndaterange ,1 ,nreportwidth ) ,
   row + 1 ,
   CALL center (i18nprinted ,1 ,nreportwidth ) ,
   row + 1
  HEAD organization_id
   norgcontind = 0 ,
   IF ((multi_facility_ind = 1 )
   AND (nnewpageind != 1 ) ) column_headings
   ENDIF
  DETAIL
   IF ((nnewpageind = 1 ) ) column_headings ,nnewpageind = 0
   ENDIF
   ,norgcontind = 1 ,
   IF ((temp->qual[d.seq ].mrn_formatted != null ) ) col 000 ,mrn_formatted
   ENDIF
   ,
   IF ((temp->qual[d.seq ].fin_formatted != null ) ) col 022 ,fin_formatted
   ENDIF
   ,
   IF ((temp->qual[d.seq ].name_full_formatted != null ) ) col 044 ,name_full_formatted
   ENDIF
   ,
   IF ((temp->qual[d.seq ].encntr_type_disp != null ) ) col 081 ,encntr_type_disp
   ENDIF
   ,
   IF ((temp->qual[d.seq ].visit_alloc_dt_tm != cnvtdatetime ("" ) ) ) col 099 ,visit_age "####" ,
    sdateformatted = concat (format (visit_alloc_dt_tm ,"@SHORTDATE;;Q" ) ) ,col 105 ,sdateformatted
   ENDIF
   ,
   IF ((temp->qual[d.seq ].disch_dt_tm != cnvtdatetime ("" ) ) ) sdateformatted = concat (format (
      disch_dt_tm ,"@SHORTDATE;;Q" ) ) ,col 119 ,sdateformatted
   ENDIF
   ,
   IF ((request->debug_ind = 1 ) ) row + 1 ,col 012 ,"per" ,col 015 ,temp->qual[d.seq ].person_id
    "##########" ,col 027 ,"enc" ,col 030 ,temp->qual[d.seq ].encntr_id "##########" ,
    FOR (doc_qual_cnt = 1 TO size (temp->qual[d.seq ].doc_qual ,5 ) )
     IF ((doc_qual_cnt != 1 ) ) row + 1
     ENDIF
     ,col 042 ,"evt" ,col 045 ,temp->qual[d.seq ].doc_qual[doc_qual_cnt ].clinical_event_id
     "##########" ,col 060 ,temp->qual[d.seq ].doc_qual[doc_qual_cnt ].event_disp ,col 085 ,temp->
     qual[d.seq ].doc_qual[doc_qual_cnt ].valid_from_dt_tm "mm/dd/yyyy;;d" ,col 096 ,temp->qual[d
     .seq ].doc_qual[doc_qual_cnt ].valid_from_dt_tm "hh:mm;;m"
    ENDFOR
   ENDIF
   ,nencntrprintedcnt = (nencntrprintedcnt + 1 ) ,
   IF ((nencntrprintedcnt != encntr_qual_cnt ) ) row + 1
   ENDIF
  WITH nocounter ,maxrow = 63
 ;end select
 IF ((curqual = 0 ) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].operationname = hold_file_name
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "DUMMYT"
 ELSE
  SET reply->file_name = hold_file_name
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD tdo_request_struct
 FREE RECORD tdo_reply_struct
 FREE RECORD age_request_struct
 FREE RECORD age_reply_struct
END GO


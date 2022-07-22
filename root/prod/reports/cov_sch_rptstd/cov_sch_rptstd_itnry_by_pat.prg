/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/21/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sch_rptstd_itnry_by_pat.prg
	Object name:		cov_sch_rptstd_itnry_by_pat
	Request #:			3113, 3028
 
	Program purpose:	Provides data for Standard Itinerary Report by Patient Covenant.
 
	Executing from:		Scheduling Appointment Book Reports
 
 	Special Notes:		Called by Scheduling Reports (schreportexe.exe).
 						Originally translated and customized by Cerner from
 						Cerner program sch_rptstd_itnry_by_pat.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	08/21/2018	Todd A. Blanchard		001 Excluded PBH patients, formatted time,
 											and added day of week.
 
******************************************************************************/
 
DROP PROGRAM cov_sch_rptstd_itnry_by_pat :dba GO
CREATE PROGRAM cov_sch_rptstd_itnry_by_pat :dba
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
 DECLARE s_format_utc_date (date ,tz_index ,option ) = vc
 SUBROUTINE  s_format_utc_date (date ,tz_index ,option )
  IF (curutc )
   IF ((tz_index > 0 ) )
    RETURN (format (datetimezone (date ,tz_index ) ,option ) )
   ELSE
    RETURN (format (datetimezone (date ,curtimezonesys ) ,option ) )
   ENDIF
  ELSE
   RETURN (format (date ,option ) )
  ENDIF
 END ;Subroutine
 FREE SET t_list
 RECORD t_list (
   1 sch_appt_id = f8
   1 appt_type_cd = f8
   1 appt_type_desc = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 beg_tm = vc
   1 end_tm = vc
   1 day_of_week = vc
   1 sch_state_cd = f8
   1 state_meaning = c12
   1 sch_event_id = f8
   1 location_cd = f8
   1 appt_reason_free = vc
   1 location_freetext = c20
   1 appt_synonym_cd = f8
   1 appt_synonym_free = vc
   1 duration = i4
   1 appt_scheme_id = f8
   1 duration = i4
   1 req_prsnl_id = f8
   1 req_prsnl_name = vc
   1 primary_resource_cd = f8
   1 primary_resource_mnem = c20
   1 schedule_id = f8
   1 raw_text = vc
   1 raw_text_size = i4
   1 text_qual_cnt = i4
   1 text_qual_alloc = i4
   1 text_qual [* ]
     2 line = vc
 )
 DECLARE field30 = c30 WITH public ,noconstant (fillstring (30 ," " ) )
 DECLARE getcodevalue_meaning = c12 WITH public ,noconstant (fillstring (12 ," " ) )
 DECLARE mrn_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE addr_type_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE appt_loc_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE getcodevalue ((code_set = i4 ) ,(cdf_meaning = c12 ) ,(code_variable = f8 (ref ) ) ) = f8
 DECLARE t_text_type_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE t_text_type_meaning = c12 WITH public ,noconstant (fillstring (12 ," " ) )
 DECLARE t_sub_text_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE t_sub_text_meaning = c12 WITH public ,noconstant (fillstring (12 ," " ) )
 DECLARE t_sub_text_mnemonic = c40 WITH public ,noconstant (fillstring (40 ," " ) )
 DECLARE pref_rmvpresuf = f8 WITH public ,noconstant (0.0 )
 SET getcodevalue_meaning = "MRN"
 CALL getcodevalue (4 ,getcodevalue_meaning ,mrn_cd )
 SET getcodevalue_meaning = "HOME"
 CALL getcodevalue (212 ,getcodevalue_meaning ,addr_type_cd )
 SET getcodevalue_meaning = "APPOINTMENT"
 CALL getcodevalue (14509 ,getcodevalue_meaning ,appt_loc_cd )
 DECLARE current_name_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"CURRENT" ) )
 SET t_list->text_qual_cnt = 0
 SET t_list->text_qual_alloc = 20
 SET stat = alterlist (t_list->text_qual ,t_list->text_qual_alloc )
 SET t_text_type_meaning = "PREAPPT"
 SET t_sub_text_meaning = "PREAPPT"
 RECORD t_person (
   1 person_id = f8
   1 name = vc
   1 mrn = vc
   1 dob = dq8
   1 birth_tz = i4
   1 birth_formatted = vc
   1 sex = vc
   1 street_addr = vc
   1 city = vc
   1 state = vc
   1 zipcode = vc
 )
 SELECT INTO "nl:"
  FROM (sch_pref sp )
  PLAN (sp
   WHERE (sp.pref_type_meaning = "RMVPRESUF" ) )
  DETAIL
   pref_rmvpresuf = sp.pref_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pa_null = nullind (pa.person_id ) ,
  a_null = nullind (addr.address_id ) ,
  pn_null = nullind (pn.person_name_id ) ,
  sex_disp = uar_get_code_display (r.sex_cd )
  FROM (person r ),
   (person_alias pa ),
   (address addr ),
   (person_name pn )
  PLAN (r
   WHERE parser ( $4 ) )
   JOIN (pa
   WHERE (pa.person_id = outerjoin (r.person_id ) )
   AND (pa.person_alias_type_cd = outerjoin (mrn_cd ) )
   AND (pa.active_ind = outerjoin (1 ) ) )
   JOIN (addr
   WHERE (addr.parent_entity_name = outerjoin ("PERSON" ) )
   AND (addr.address_type_cd = outerjoin (addr_type_cd ) )
   AND (addr.parent_entity_id = outerjoin (r.person_id ) )
   AND (addr.address_id > outerjoin (0 ) )
   AND (addr.active_ind = outerjoin (1 ) ) )
   JOIN (pn
   WHERE (pn.person_id = outerjoin (r.person_id ) )
   AND (pn.person_id != outerjoin (0 ) )
   AND (pn.active_ind = outerjoin (1 ) )
   AND (pn.name_type_cd = current_name_type_cd )
   AND (pn.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime ) )
   AND (pn.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime ) ) )
  DETAIL
   t_person->person_id = r.person_id ,
   t_person->dob = r.birth_dt_tm ,
   t_person->sex = trim (sex_disp ) ,
   t_person->birth_tz = validate (r.birth_tz ,0 ) ,
   IF ((trim (r.name_full_formatted ) > "" ) )
    IF ((pref_rmvpresuf IN (0 ,
    5 ,
    6 ,
    7 ) )
    AND (trim (pn.name_prefix ) > "" ) ) t_person->name = concat (trim (pn.name_prefix ) ," " ,trim (
       r.name_full_formatted ) )
    ELSE t_person->name = trim (r.name_full_formatted )
    ENDIF
   ELSE t_person->name = ""
   ENDIF
   ,
   IF ((pref_rmvpresuf IN (0 ,
   3 ,
   4 ,
   7 ) )
   AND (trim (pn.name_suffix ) > "" ) ) t_person->name = concat (trim (t_person->name ) ," " ,trim (
      pn.name_suffix ) )
   ENDIF
   ,
   IF ((pref_rmvpresuf IN (0 ,
   2 ,
   4 ,
   6 ) )
   AND (trim (pn.name_title ) > "" ) ) t_person->name = concat (trim (t_person->name ) ," " ,trim (pn
      .name_title ) )
   ENDIF
   ,
   IF ((pa_null = 0 ) ) t_person->mrn = trim (pa.alias ,3 )
   ENDIF
   ,
   IF ((a_null = 0 ) ) t_person->street_addr = trim (addr.street_addr ,3 ) ,t_person->city = trim (
     addr.city ,3 ) ,t_person->state = trim (addr.state ,3 ) ,t_person->zipcode = trim (addr.zipcode
     ,3 )
   ENDIF
   ,t_person->birth_formatted = s_format_utc_date (t_person->dob ,t_person->birth_tz ,
    "@SHORTDATE;4;d" ) ;,
;   IF ((size (t_person->state ) > 0 ) ) t_person->state = concat ("," ,t_person->state )
;   ENDIF ;001
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.updt_cnt
  FROM (sch_sub_text a )
  WHERE (a.text_type_meaning = t_text_type_meaning )
  AND (a.sub_text_meaning = t_sub_text_meaning )
  AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
  DETAIL
   t_text_type_cd = a.text_type_cd ,
   t_sub_text_cd = a.sub_text_cd ,
   t_sub_text_mnemonic = a.mnemonic
  WITH nocounter
 ;end select
 SELECT INTO  $1
  side = decode (e.seq ,1 ,tl.seq ,2 ,3 ) ,
  r.person_id ,
  a.sch_appt_id ,
  l.location_cd ,
  se.updt_cnt ,
  d.seq ,
  e.updt_cnt ,
  tl.updt_cnt ,
  t.updt_cnt ,
  state_meaning = uar_get_code_display (a.sch_state_cd ) ,
  lt.long_text_id
  FROM (person r ),
   (sch_appt a ),
   (sch_location l ),
   (sch_event se ),
   (dummyt d ),
   (sch_event_disp e ),
   (sch_text_link tl ),
   (sch_sub_list sl ),
   (sch_template t ),
   (long_text_reference lt ),
   (location l2 ), ;001
   (organization org) ;001
  PLAN (r
   WHERE parser ( $4 ) )
   JOIN (a
   WHERE parser ( $2 )
   AND parser ( $3 )
   AND (a.person_id = r.person_id )
   AND (a.state_meaning IN ("CHECKED IN" ,
   "CHECKED OUT" ,
   "CONFIRMED" ,
   "FINALIZED" ,
   "PENDING" ,
   "SCHEDULED" ) )
   AND (a.role_meaning = "PATIENT" )
   AND (a.active_ind = 1 )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (l
   WHERE (l.schedule_id = a.schedule_id )
   AND (l.location_type_cd = appt_loc_cd )
   AND (l.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (se
   WHERE (se.sch_event_id = a.sch_event_id )
   AND (se.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   ;001
   JOIN (l2
   WHERE (l2.location_cd = l.location_cd ) )
   JOIN (org
   WHERE (org.organization_id = l2.organization_id
   	AND org.organization_id NOT IN (
   		3144500.00,
		3234074.00,
		3234075.00,
		3234076.00,
		3234077.00,
		3234078.00,
		3234079.00
   	) ) )
   ;
   JOIN (d
   WHERE (d.seq = 1 ) )
   JOIN (((e
   WHERE (e.sch_event_id = a.sch_event_id )
   AND (((e.schedule_id = 0 ) ) OR ((e.schedule_id = a.schedule_id ) ))
   AND (((e.sch_appt_id = 0 ) ) OR ((e.sch_appt_id = a.sch_appt_id ) ))
   AND (e.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (e.active_ind = 1 ) )
   ) ORJOIN ((tl
   WHERE (tl.parent_id = se.appt_type_cd )
   AND (tl.parent_table = "CODE_VALUE" )
   AND (tl.parent2_id = l.location_cd )
   AND (tl.parent2_table = "CODE_VALUE" )
   AND (tl.text_type_cd = t_text_type_cd )
   AND (tl.sub_text_cd = t_sub_text_cd )
   AND (tl.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (sl
   WHERE (sl.parent_id = tl.text_link_id )
   AND (sl.parent_table = "SCH_TEXT_LINK" )
   AND (sl.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (t
   WHERE (t.template_id = sl.template_id )
   AND (t.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (lt
   WHERE (lt.long_text_id = t.text_id ) )
   ))
  ORDER BY cnvtdatetime (a.beg_dt_tm ) ,
   a.sch_appt_id ,
   side
  HEAD PAGE
   col 0 ,
   row 0 ,
   "{F/4}{CPI/12}{LPI/6}" ,
   "{POS/540/28}Page " ,
   curpage "###" ,
   row + 1 ,
   "{F/4}{CPI/8}{LPI/5}" ,
   "{POS/207/61}{B}Person Appointment Itinerary" ,
   row + 1 ,
   col 0 ,
   "{POS/250/97}{B}Covenant Health" ,
   "{F/4}{CPI/11}{LPI/6}" ,
   row + 1 ,
   "{POS/90/180}" ,
   t_person->name ,
   col + 0 ,
   "{POS/342/180}Medical Record Number: " ,
   col + 1 ,
   t_person->mrn ,
   row + 1 ,
   col 0 ,
   "{POS/90/193}" ,
   t_person->street_addr ,
   col + 0 ,
   "{POS/342/193}Sex: " ,
   col + 1 ,
   t_person->sex ,
   row + 1 ,
   "{POS/90/206}" ,
   t_person->city ,
   ", " , ;001
;   col + 1 , ;001
   t_person->state ,
   "  " ,
   t_person->zipcode ,
   col + 0 ,
   "{POS/342/206}DOB: " ,
   col + 1 ,
   t_person->birth_formatted ,
   row + 2 ,
   "{POS/56/245}{B}Location" ,
   "{POS/172/245}{B}Day" , ;001
   "{POS/208/245}{B}Date" , ;001
   "{POS/252/245}{B}Time" ,
   "{POS/306/245}{B}Appointment Type" ,
   "{POS/450/245}{B}Resource" ,
   row + 1 ,
   "{POS/56/246}{B}{REPEAT/90/_/}" ,
   "{ENDB}" ,
   row + 1 ,
   y_pos = 272
  HEAD a.sch_appt_id
   ;001
   t_list->sch_appt_id = a.sch_appt_id ,
   t_list->schedule_id = a.schedule_id ,
   t_list->beg_dt_tm = a.beg_dt_tm ,
   t_list->end_dt_tm = a.end_dt_tm ,
   t_list->beg_tm = format(a.beg_dt_tm, "hh:mm;;s") , ;001
   t_list->end_tm = format(a.end_dt_tm, "hh:mm;;s") , ;001
   t_list->day_of_week = cnvtupper(format(a.beg_dt_tm, "www;;d")) , ;001
   t_list->sch_state_cd = a.sch_state_cd ,
   t_list->state_meaning = state_meaning ,
   t_list->sch_event_id = a.sch_event_id ,
   t_list->duration = a.duration ,
   t_list->appt_scheme_id = a.appt_scheme_id ,
   t_list->raw_text = ""
   ;
  DETAIL
   IF ((side = 1 ) )
    IF ((((e.schedule_id = 0 ) ) OR ((e.schedule_id = a.schedule_id ) ))
    AND (((e.sch_appt_id = 0 ) ) OR ((e.sch_appt_id = a.sch_appt_id ) )) )
     CASE (e.disp_field_id )
      OF 1 :
       t_list->location_freetext = trim (e.disp_display ) ,
       t_list->location_cd = e.disp_value
      OF 5 :
       t_list->primary_resource_cd = e.disp_value ,
       t_list->primary_resource_mnem = trim (e.disp_display ,3 )
      OF 6 :
       t_list->appt_type_desc = e.disp_display ,
       t_list->appt_type_cd = e.disp_value
      OF 7 :
       t_list->appt_synonym_cd = e.disp_value ,
       t_list->appt_synonym_free = trim (e.disp_display ,3 )
      OF 8 :
       t_list->req_prsnl_id = e.disp_value ,
       t_list->req_prsnl_name = e.disp_display
      OF 9 :
       t_list->appt_reason_free = e.disp_display
     ENDCASE
    ENDIF
   ELSEIF ((side = 2 ) )
    IF ((t_list->raw_text > " " ) ) t_list->raw_text = concat (trim (t_list->raw_text ) ,char (13 ) ,
      char (10 ) ,char (13 ) ,char (10 ) ,lt.long_text )
    ELSE t_list->raw_text = concat (trim (t_list->raw_text ) ,lt.long_text )
    ENDIF
   ENDIF
  FOOT  a.sch_appt_id
   t_list->text_qual_cnt = 0 ,t_list->raw_text_size = size (t_list->raw_text ) ,t_beg = 0 ,
   t_beg_white = 0 ,
   FOR (i = 1 TO t_list->raw_text_size )
    t_char = substring (i ,1 ,t_list->raw_text ) ,
    CASE (ichar (t_char ) )
     OF 10 :
     OF 13 :
      IF ((t_beg = 0 ) )
       IF ((ichar (t_char ) = 13 ) ) t_list->text_qual_cnt = (t_list->text_qual_cnt + 1 ) ,
        IF ((t_list->text_qual_cnt > t_list->text_qual_alloc ) ) t_list->text_qual_alloc = (t_list->
         text_qual_alloc + 1 ) ,stat = alterlist (t_list->text_qual ,t_list->text_qual_alloc )
        ENDIF
        ,t_list->text_qual[t_list->text_qual_cnt ].line = ""
       ENDIF
      ELSE t_list->text_qual_cnt = (t_list->text_qual_cnt + 1 ) ,
       IF ((t_list->text_qual_cnt > t_list->text_qual_alloc ) ) t_list->text_qual_alloc = (t_list->
        text_qual_alloc + 1 ) ,stat = alterlist (t_list->text_qual ,t_list->text_qual_alloc )
       ENDIF
       ,t_list->text_qual[t_list->text_qual_cnt ].line = substring (t_beg ,(i - t_beg ) ,t_list->
        raw_text ) ,t_beg = 0 ,t_beg_white = 0
      ENDIF
     ELSE
      IF ((t_beg = 0 ) ) t_beg = i ,
       IF ((t_char IN (" " ,
       "," ,
       "-" ) ) ) t_beg_white = i
       ENDIF
      ELSE
       IF ((t_char IN (" " ,
       "," ,
       "-" ) ) ) t_beg_white = i
       ENDIF
       ,
       IF (((i - t_beg ) > 80 ) ) t_list->text_qual_cnt = (t_list->text_qual_cnt + 1 ) ,
        IF ((t_list->text_qual_cnt > t_list->text_qual_alloc ) ) t_list->text_qual_alloc = (t_list->
         text_qual_alloc + 1 ) ,stat = alterlist (t_list->text_qual ,t_list->text_qual_alloc )
        ENDIF
        ,
        IF ((t_beg_white = 0 ) ) t_list->text_qual[t_list->text_qual_cnt ].line = substring (t_beg ,(
          i - t_beg ) ,t_list->raw_text ) ,t_beg = i ,
         IF ((t_char IN (" " ,
         "," ,
         "-" ) ) ) t_beg_white = i
         ENDIF
        ELSE t_list->text_qual[t_list->text_qual_cnt ].line = substring (t_beg ,(t_beg_white - t_beg
          ) ,t_list->raw_text ) ,t_beg = (t_beg_white + 1 ) ,t_beg_white = 0
        ENDIF
       ENDIF
      ENDIF
    ENDCASE
   ENDFOR
   ,
   IF (t_beg ) t_list->text_qual_cnt = (t_list->text_qual_cnt + 1 ) ,
    IF ((t_list->text_qual_cnt > t_list->text_qual_alloc ) ) t_list->text_qual_alloc = (t_list->
     text_qual_alloc + 1 ) ,stat = alterlist (t_list->text_qual ,t_list->text_qual_alloc )
    ENDIF
    ,t_list->text_qual[t_list->text_qual_cnt ].line = substring (t_beg ,(i - t_beg ) ,t_list->
     raw_text )
   ENDIF
   ,
   IF ((y_pos > 671 ) )
    BREAK
   ENDIF
   ,"{F/4}{CPI/12}{LPI/6}" ,
   CALL print (calcpos (56 ,y_pos ) ) ,"{B}" ,t_list->location_freetext ,"{ENDB}" ,
   CALL print (calcpos (172 ,y_pos ) ) ,t_list->day_of_week , ;001
   CALL print (calcpos (208 ,y_pos ) ) ,t_list->beg_dt_tm "@SHORTDATE" , ;001
   CALL print (calcpos (252 ,y_pos ) ) ,t_list->beg_tm , ;001
   IF ((size (t_list->appt_synonym_free ) > 30 ) ) field30 = substring (1 ,30 ,t_list->
     appt_synonym_free ) ,
    CALL print (calcpos (306 ,y_pos ) ) ,field30
   ELSE
    CALL print (calcpos (306 ,y_pos ) ) ,t_list->appt_synonym_free
   ENDIF
   ,
   IF ((size (t_list->primary_resource_mnem ) > 30 ) ) field30 = substring (1 ,30 ,t_list->
     primary_resource_mnem ) ,
    CALL print (calcpos (450 ,y_pos ) ) ,field30
   ELSE
    CALL print (calcpos (450 ,y_pos ) ) ,t_list->primary_resource_mnem
   ENDIF
   ,
   CALL print (calcpos (450 ,y_pos ) ) ,row + 1 ,
   IF ((t_list->text_qual_cnt > 0 ) ) row + 1 ,col 0 ,y_pos = (y_pos + 13 ) ,
    CALL print (calcpos (90 ,y_pos ) ) ,"{B}" ,t_sub_text_mnemonic ,"{ENDB}" ,
    FOR (i = 1 TO t_list->text_qual_cnt )
     row + 1 ,col 0 ,y_pos = (y_pos + 13 ) ,
     IF ((y_pos > 700 ) )
      BREAK
     ENDIF
     ,
     CALL print (calcpos (90 ,y_pos ) ) ,t_list->text_qual[i ].line
    ENDFOR
   ENDIF
   ,row + 1 ,y_pos = (y_pos + 26 )
  FOOT REPORT
   row + 1 ,
   "{F/4}{CPI/12}{LPI/6}" ,
   "{POS/90/702}" ,
   row + 1 ,
   "{POS/90/715}" ,
   row + 2 ,
   "{POS/252/741}*** End of Itinerary ***"
  WITH nullreport ,nocounter ,outerjoin = d ,dio = postscript ,formfeed = post ,maxcol = 400
 ;end select
 SUBROUTINE  getcodevalue (code_set ,cdf_meaning ,code_variable )
  SET stat = uar_get_meaning_by_codeset (code_set ,cdf_meaning ,1 ,code_variable )
  IF ((((stat != 0 ) ) OR ((code_variable <= 0 ) )) )
   CALL echo (build ("Invalid select on CODE_SET (" ,code_set ,"),  CDF_MEANING(" ,cdf_meaning ,")"
     ) )
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO
 

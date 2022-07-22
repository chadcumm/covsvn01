/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/05/2022
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sch_rptstd_res_appt_mg.prg
	Object name:		cov_sch_rptstd_res_appt_mg
	Request #:			12544
 
	Program purpose:	Provides data for Standard MG Resource Appointment List.
 
	Executing from:		Scheduling Appointment Book Reports
 
 	Special Notes:		Called by Scheduling Reports (schreportexe.exe).
 						Translated and customized from Cerner program
 						sch_rptstd_res_appt_patsch.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_sch_rptstd_res_appt_mg:dba GO
CREATE PROGRAM cov_sch_rptstd_res_appt_mg:dba
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
 DECLARE getcodevalue_meaning = c12 WITH public ,noconstant (fillstring (12 ," " ) )
 DECLARE mrn_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE en_mrn_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE home_cd = f8 WITH public ,noconstant (0.0 )
 DECLARE t_pat_beg = c11 WITH public ,noconstant (fillstring (11 ," " ) )
 DECLARE t_pat_end = c11 WITH public ,noconstant (fillstring (11 ," " ) )
 DECLARE beg_day_num = i4 WITH public ,noconstant (0 )
 DECLARE end_day_num = i4 WITH public ,noconstant (0 )
 DECLARE print_line120 = c120 WITH public ,noconstant (fillstring (120 ," " ) )
 DECLARE t_detail_offset = i4 WITH public ,noconstant (13 )
 DECLARE max_patient_qual = i4 WITH public ,noconstant (0 )
 DECLARE mg_dt_tm = f8 WITH public ,constant (26851453.00 )
 DECLARE mg_where = f8 WITH public ,constant (4240092935.00 )
 DECLARE mg_loc = f8 WITH public ,constant (4242912945.00 )
 DECLARE mg_other = f8 WITH public ,constant (uar_get_code_by("DISPLAYKEY", 100535, "OTHER"))
 FREE SET t_rec
 RECORD t_rec (
   1 temp_string = vc
   1 temp_size = i4
   1 resource_cd = f8
   1 resource_mnem = vc
   1 qual_cnt = i4
   1 qual [* ]
     2 sort_field = i4
     2 sch_appt_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 sch_state_disp = c11
     2 sch_event_id = f8
     2 schedule_id = f8
     2 appt_synonym_free = c30
     2 duration = i4
     2 detail_qual_cnt = i4
     2 detail_qual [* ]
       3 oe_field_id = f8
       3 oe_field_display_value = c255
       3 oe_field_dt_tm_value = dq8
       3 oe_field_meaning = c25
       3 oe_field_value = f8
       3 oe_field_meaning_id = f8
       3 description = vc
       3 accept_size = i4
       3 field_type_flag = i2
     2 patient_qual_cnt = i4
     2 patient_qual [* ]
       3 person_id = f8
       3 name = c30
       3 mrn = c20
       3 home_phone = c15
       3 birth_dt_tm = dq8
       3 birth_tz = i4
       3 birth_formatted = vc
       3 sex = c10
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 appt_qual_cnt = i4
       3 appt_qual [* ]
         4 sch_event_id = f8
         4 sch_appt_id = f8
         4 beg_dt_tm = dq8
         4 end_dt_tm = dq8
         4 sch_state_disp = c11
         4 appt_synonym_free = c30
         4 duration = i4
         4 primary_resource_mnem = c30
 )
 FREE SET t_record
 RECORD t_record (
   1 t_ind = i4
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 resource_cd = f8
 )
 SET t_record->t_ind = (findstring (" = " , $4 ,1 ) + 3 )
 SET t_record->resource_cd = cnvtreal (substring (t_record->t_ind ,((size (trim ( $4 ) ) - t_record->
   t_ind ) + 1 ) , $4 ) )
 SET t_record->t_ind = (findstring (char (34 ) , $3 ,1 ) + 1 )
 SET t_record->beg_dt_tm = cnvtdatetime (substring (t_record->t_ind ,23 , $3 ) )
 SET t_record->t_ind = (findstring (char (34 ) , $2 ,1 ) + 1 )
 SET t_record->end_dt_tm = cnvtdatetime (substring (t_record->t_ind ,23 , $2 ) )
 SET t_rec->qual_cnt = 0
 SET t_pat_beg = concat (substring (15 ,11 , $3 ) ," 00:00:00.00" )
 SET t_pat_end = concat (substring (15 ,11 , $2 ) ," 23:59:00.00" ) 
 SET beg_day_num = cnvtdate2 (format (cnvtdatetime (t_pat_beg ) ,"MMDDYYYY;;DATE" ) ,"MMDDYYYY" )
 SET end_day_num = cnvtdate2 (format (cnvtdatetime (t_pat_end ) ,"MMDDYYYY;;DATE" ) ,"MMDDYYYY" )
 SET getcodevalue_meaning = "MRN"
 CALL getcodevalue (4 ,getcodevalue_meaning ,mrn_cd )
 CALL getcodevalue (319 ,getcodevalue_meaning ,en_mrn_cd )
 SET getcodevalue_meaning = "HOME"
 CALL getcodevalue (43 ,getcodevalue_meaning ,home_cd )
 SELECT INTO "nl:"
  r.mnemonic
  FROM (sch_resource r )
  WHERE (r.resource_cd = t_record->resource_cd )
  AND (r.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
  AND (r.active_ind = 1 )
  DETAIL
   t_rec->resource_mnem = r.mnemonic
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  r.resource_cd ,
  a.sch_appt_id ,
  sch_state_disp = uar_get_code_display (a.sch_state_cd ) ,
  sex_disp = uar_get_code_display (p.sex_cd ) ,
  e.sch_event_id ,
  ep.person_id ,
  p.name_full_formatted ,
  ena_exist = decode (ena.seq ,1 ,0 ) ,
  oapr_exist = decode (oapr.seq ,1 ,0 ) ,
  ph_exist = decode (ph.seq ,1 ,0 )
  FROM (sch_resource r ),
   (sch_appt a ),
   (sch_event e ),
   (sch_event_patient ep ),
   (person p ),
   (dummyt d2 ),
   (encntr_alias ena ),
   (location l ),
   (dummyt d3 ),
   (org_alias_pool_reltn oapr ),
   (person_alias pa ),
   (dummyt d4 ),
   (phone ph )
  PLAN (r
   WHERE (r.resource_cd = t_record->resource_cd )
   AND (r.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (r.active_ind = 1 ) )
   JOIN (a
   WHERE (a.person_id = r.person_id )
   AND (a.resource_cd = r.resource_cd )
   AND (a.beg_dt_tm < cnvtdatetime (t_record->end_dt_tm ) )
   AND (a.end_dt_tm > cnvtdatetime (t_record->beg_dt_tm ) )
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (a.state_meaning IN ("CHECKED IN" ,
   "CHECKED OUT" ,
   "CONFIRMED" ,
   "FINALIZED" ,
   "NOSHOW" ,
   "PENDING" ,
   "STANDBY" ,
   "SCHEDULED" ) )
   AND ((a.role_meaning = null ) OR ((a.role_meaning != "PATIENT" ) ))
   AND (a.active_ind = 1 ) )
   JOIN (e
   WHERE (e.sch_event_id = a.sch_event_id )
   AND (e.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (ep
   WHERE (ep.sch_event_id = a.sch_event_id )
   AND (ep.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (ep.active_ind = 1 ) )
   JOIN (p
   WHERE (p.person_id = ep.person_id ) )
   JOIN (l
   WHERE (l.location_cd = a.appt_location_cd ) )
   JOIN (d2
   WHERE (d2.seq = 1 ) )
   JOIN (ena
   WHERE (ena.encntr_id = ep.encntr_id )
   AND (ena.encntr_id > 0 )
   AND (ena.encntr_alias_type_cd = en_mrn_cd )
   AND (ena.active_ind = 1 )
   AND (ena.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
   AND (ena.end_effective_dt_tm >= cnvtdatetime (sysdate ) ) )
   JOIN (d3
   WHERE (d3.seq = 1 ) )
   JOIN (oapr
   WHERE (oapr.organization_id = l.organization_id )
   AND (oapr.alias_entity_name = "PERSON_ALIAS" )
   AND (oapr.alias_entity_alias_type_cd = mrn_cd ) )
   JOIN (pa
   WHERE (pa.person_id = p.person_id )
   AND (pa.alias_pool_cd = oapr.alias_pool_cd )
   AND (pa.person_alias_type_cd = mrn_cd )
   AND (pa.active_ind = 1 )
   AND (pa.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
   AND (pa.end_effective_dt_tm >= cnvtdatetime (sysdate ) ) )
   JOIN (d4
   WHERE (d4.seq = 1 ) )
   JOIN (ph
   WHERE (ph.parent_entity_id = p.person_id )
   AND (ph.parent_entity_name = "PERSON" )
   AND (ph.phone_id != 0 )
   AND (ph.phone_type_cd = home_cd )
   AND (ph.active_ind = 1 )
   AND (ph.phone_type_seq = 1 )
   AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
   AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) ) )
  ORDER BY cnvtdatetime (a.beg_dt_tm ) ,
   a.sch_appt_id ,
   p.person_id
  HEAD REPORT
   t_rec->resource_cd = r.resource_cd ,
   t_rec->resource_mnem = trim (r.mnemonic ) ,
   t_rec->qual_cnt = 0
  HEAD a.sch_appt_id
   t_rec->qual_cnt +=1 ,t_qual = t_rec->qual_cnt ,
   IF ((mod (t_qual ,10 ) = 1 ) ) stat = alterlist (t_rec->qual ,(t_qual + 9 ) )
   ENDIF
   ,t_rec->qual[t_qual ].sch_appt_id = a.sch_appt_id ,t_rec->qual[t_qual ].sort_field = cnvtdate2 (
    format (a.beg_dt_tm ,"MMDDYYYY;;D" ) ,"MMDDYYYY" ) ,t_rec->qual[t_qual ].beg_dt_tm = a.beg_dt_tm
   ,t_rec->qual[t_qual ].end_dt_tm = a.end_dt_tm ,t_rec->qual[t_qual ].sch_state_disp =
   sch_state_disp ,t_rec->qual[t_qual ].sch_event_id = e.sch_event_id ,t_rec->qual[t_qual ].
   schedule_id = a.schedule_id ,t_rec->qual[t_qual ].appt_synonym_free = e.appt_synonym_free ,t_rec->
   qual[t_qual ].duration = a.duration ,t_rec->qual[t_qual ].patient_qual_cnt = 0 ,t_rec->qual[
   t_qual ].detail_qual_cnt = 0
  HEAD p.person_id
   t_rec->qual[t_qual ].patient_qual_cnt +=1 ,t_patient = t_rec->qual[t_qual ].patient_qual_cnt ,
   IF ((mod (t_patient ,10 ) = 1 ) ) stat = alterlist (t_rec->qual[t_qual ].patient_qual ,(t_patient
     + 9 ) )
   ENDIF
   ,t_rec->qual[t_qual ].patient_qual[t_patient ].person_id = ep.person_id ,t_rec->qual[t_qual ].
   patient_qual[t_patient ].name = p.name_full_formatted ,t_rec->qual[t_qual ].patient_qual[
   t_patient ].birth_dt_tm = p.birth_dt_tm ,t_rec->qual[t_qual ].patient_qual[t_patient ].birth_tz =
   validate (p.birth_tz ,0 ) ,t_rec->qual[t_qual ].patient_qual[t_patient ].birth_formatted =
   s_format_utc_date (p.birth_dt_tm ,validate (p.birth_tz ,0 ) ,"@SHORTDATE;4;D" ) ,t_rec->qual[
   t_qual ].patient_qual[t_patient ].sex = sex_disp ,
   IF (ena_exist
   AND (ena.encntr_id > 0 ) ) t_rec->qual[t_qual ].patient_qual[t_patient ].mrn = substring (1 ,20 ,
     cnvtalias (ena.alias ,ena.alias_pool_cd ) )
   ELSEIF (oapr_exist ) t_rec->qual[t_qual ].patient_qual[t_patient ].mrn = substring (1 ,20 ,
     cnvtalias (pa.alias ,pa.alias_pool_cd ) )
   ELSE t_rec->qual[t_qual ].patient_qual[t_patient ].mrn = ""
   ENDIF
   ,
   IF (ph_exist ) t_rec->qual[t_qual ].patient_qual[t_patient ].home_phone = cnvtphone (cnvtalphanum
     (ph.phone_num ) ,ph.phone_format_cd )
   ELSE t_rec->qual[t_qual ].patient_qual[t_patient ].home_phone = ""
   ENDIF
   ,t_rec->qual[t_qual ].patient_qual[t_patient ].beg_dt_tm = cnvtdatetime (concat (format (a
      .beg_dt_tm ,"DD-MMM-YYYY;;DATE" ) ," 00:00:00.00" ) ) ,t_rec->qual[t_qual ].patient_qual[
   t_patient ].end_dt_tm = cnvtdatetime (concat (format (a.end_dt_tm ,"DD-MMM-YYYY;;DATE" ) ,
     " 23:59:00.00" ) ) ,t_rec->qual[t_qual ].patient_qual[t_patient ].appt_qual_cnt = 0
  FOOT  p.person_id
   null
  FOOT  a.sch_appt_id
   IF ((mod (t_patient ,10 ) != 0 ) ) stat = alterlist (t_rec->qual[t_qual ].patient_qual ,t_patient
     )
   ENDIF
   ,
   IF ((t_patient > max_patient_qual ) ) max_patient_qual = t_patient
   ENDIF
  FOOT REPORT
   IF ((mod (t_qual ,10 ) != 0 ) ) stat = alterlist (t_rec->qual ,t_qual )
   ENDIF
  WITH nocounter ,dio = postscript ,maxcol = 2000 ,maxqual (pa ,1 ) ,outerjoin = d2 ,dontcare = ena ,
   outerjoin = d3 ,dontcare = oapr ,outerjoin = d4 ,dontcare = ph
 ;end select
 SELECT INTO "nl:"
  ed.updt_cnt ,
  oef.updt_cnt ,
  d.seq
  FROM (sch_event_detail ed ),
   (order_entry_fields oef ),
   (dummyt d WITH seq = value (t_rec->qual_cnt ) )
  PLAN (d )
   JOIN (ed
   WHERE (ed.sch_event_id = t_rec->qual[d.seq ].sch_event_id )
   AND (ed.sch_action_id = 0 )
   AND (ed.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (ed.active_ind = 1 )  
   AND (exists (
   	select ed2.oe_field_id
   	from sch_event_detail ed2 
   	where 
		ed2.sch_event_id = t_rec->qual[d.seq ].sch_event_id
		AND ed2.sch_action_id = 0
		AND ed2.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00")
		AND ed2.active_ind = 1
		AND ed2.oe_field_id = mg_where
		AND ed2.oe_field_value = mg_other
   ))
   )
   JOIN (oef
   WHERE (oef.oe_field_id = ed.oe_field_id ) 
   AND (oef.oe_field_id in (mg_dt_tm, mg_where, mg_loc) ))
   
  HEAD d.seq
   t_rec->qual[d.seq ].detail_qual_cnt = 0
  DETAIL
   t_rec->qual[d.seq ].detail_qual_cnt +=1 ,
   detail_index = t_rec->qual[d.seq ].detail_qual_cnt ,
   IF ((mod (detail_index ,10 ) = 1 ) ) stat = alterlist (t_rec->qual[d.seq ].detail_qual ,(
     detail_index + 9 ) )
   ENDIF
   ,t_rec->qual[d.seq ].detail_qual[detail_index ].oe_field_id = ed.oe_field_id ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].oe_field_display_value = ed.oe_field_display_value
   ,t_rec->qual[d.seq ].detail_qual[detail_index ].oe_field_dt_tm_value = ed.oe_field_dt_tm_value ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].oe_field_meaning = ed.oe_field_meaning ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].oe_field_value = ed.oe_field_value ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].oe_field_meaning_id = ed.oe_field_meaning_id ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].description = concat (trim (oef.description ) ,":"
    ) ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].accept_size = oef.accept_size ,
   t_rec->qual[d.seq ].detail_qual[detail_index ].field_type_flag = oef.field_type_flag
  FOOT  d.seq
   IF ((mod (detail_index ,10 ) != 0 ) ) stat = alterlist (t_rec->qual[d.seq ].detail_qual ,
     detail_index )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.sch_appt_id ,
  e.appt_synonym_free ,
  sch_state_disp = uar_get_code_display (a.sch_state_cd ) ,
  d1.seq ,
  ed.disp_value ,
  d.seq ,
  d2.seq
  FROM (sch_appt a ),
   (sch_event e ),
   (dummyt d1 ),
   (sch_event_disp ed ),
   (dummyt d WITH seq = value (t_rec->qual_cnt ) ),
   (dummyt d2 WITH seq = value (max_patient_qual ) )
  PLAN (d )
   JOIN (d2
   WHERE (d2.seq <= t_rec->qual[d.seq ].patient_qual_cnt ) )
   JOIN (a
   WHERE (cnvtdatetime (t_rec->qual[d.seq ].patient_qual[d2.seq ].end_dt_tm ) > a.beg_dt_tm )
   AND (cnvtdatetime (t_rec->qual[d.seq ].patient_qual[d2.seq ].beg_dt_tm ) < a.end_dt_tm )
   AND (t_rec->qual[d.seq ].patient_qual[d2.seq ].person_id = a.person_id )
   AND (((t_rec->qual[d.seq ].sch_event_id != a.sch_event_id ) ) OR ((t_rec->qual[d.seq ].schedule_id
    != a.schedule_id ) ))
   AND (a.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (a.state_meaning IN ("CHECKED IN" ,
   "CHECKED OUT" ,
   "CONFIRMED" ,
   "FINALIZED" ,
   "NOSHOW" ,
   "PENDING" ,
   "STANDBY" ,
   "SCHEDULED" ) )
   AND (a.active_ind = 1 ) )
   JOIN (e
   WHERE (e.sch_event_id = a.sch_event_id )
   AND (e.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) ) )
   JOIN (d1
   WHERE (d1.seq = 1 ) )
   JOIN (ed
   WHERE (ed.sch_event_id = a.sch_event_id )
   AND (((ed.schedule_id = 0 ) ) OR ((ed.schedule_id = a.schedule_id ) ))
   AND (((ed.sch_appt_id = 0 ) ) OR ((ed.sch_appt_id = a.sch_appt_id ) ))
   AND (ed.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
   AND (ed.disp_field_id = 5 )
   AND (ed.active_ind = 1 ) )
  ORDER BY d.seq ,
   d2.seq ,
   cnvtdatetime (a.beg_dt_tm ) ,
   a.sch_appt_id
  HEAD d.seq
   dummy_value = 0
  HEAD d2.seq
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual_cnt = 0
  DETAIL
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual_cnt +=1 ,
   t_appt = t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual_cnt ,
   IF ((mod (t_appt ,10 ) = 1 ) ) stat = alterlist (t_rec->qual[d.seq ].patient_qual[d2.seq ].
     appt_qual ,(t_appt + 9 ) )
   ENDIF
   ,t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].sch_event_id = a.sch_event_id ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].sch_appt_id = a.sch_appt_id ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].beg_dt_tm = a.beg_dt_tm ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].end_dt_tm = a.end_dt_tm ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].sch_state_disp = sch_state_disp ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].appt_synonym_free = e
   .appt_synonym_free ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].duration = a.duration ,
   t_rec->qual[d.seq ].patient_qual[d2.seq ].appt_qual[t_appt ].primary_resource_mnem = ed
   .disp_display
  FOOT  d.seq
   dummy_value = 0
  FOOT  d2.seq
   IF ((mod (t_appt ,10 ) != 0 ) ) stat = alterlist (t_rec->qual[d.seq ].patient_qual[d2.seq ].
     appt_qual ,t_appt )
   ENDIF
  WITH nocounter ,outerjoin = d1 ,maxcol = 2000 ,dontcare = ed
 ;end select
 SELECT INTO  $1
  d.seq
  FROM (dummyt d )  
  HEAD REPORT
   t_last_sort_field = beg_day_num ,
   t_last_foot_field = beg_day_num
  HEAD PAGE
   row + 1 ,
   col + 0 ,
   "{F/4}{CPI/12}{LPI/6}" ,
   row + 1 ,
   "{POS/540/28}{B}Page: " ,
   curpage ";l;i" ,
   "{ENDB}" ,
   row + 1 ,
   "{F/4}{CPI/9}{LPI/5}" ,
   "{POS/185/55}{B}S C H E D U L I N G   M A N A G E M E N T" ,
   row + 1 ,
   "{POS/186/70}{B}MG Resource Daily Appointment Summary" ,
   row + 1 ,
   "{F/4}{CPI/11}{LPI/6}" ,
   "{POS/72/100}{B}Resource: {ENDB}" ,
   t_rec->resource_mnem ,
   row + 1 ,
   "{POS/72/113}{B}Date: {ENDB}" ,
   t_last_sort_field "@SHORTDATE" ,
   row + 1 ,
   "{POS/72/139}{B}Time" ,
   "{POS/110/139}{B}Dur" ,
   "{POS/154/139}{B}Appointment Type" ,
   "{POS/330/139}{B}State" ,
   "{POS/432/139}{B}Physician" ,
   row + 1 ,
   "{POS/72/140}{B}{REPEAT/83/_/}" ,
   row + 1 ,
   "{ENDB}" ,
   t_cont_ind = 1 ,
   y_pos = 140
  DETAIL
   FOR (i = 1 TO t_rec->qual_cnt )
    IF (t_rec->qual[i ].detail_qual_cnt > 0)
   
    WHILE ((t_last_sort_field < t_rec->qual[i ].sort_field ) )
     t_foot_sort_field = t_last_sort_field ,t_last_sort_field +=1 ,
     BREAK
    ENDWHILE
    ,t_foot_sort_field = t_last_sort_field ,row + 1 ,"{F/4}{CPI/12}{LPI/6}" ,
    IF ((y_pos > 668 ) ) t_cont_ind = 0 ,
     BREAK
    ENDIF
    ,y_pos +=13 ,
    CALL print (calcpos (72 ,y_pos ) ) ,t_rec->qual[i ].beg_dt_tm "@TIMENOSECONDS" ,
    CALL print (calcpos (110 ,y_pos ) ) ,t_rec->qual[i ].duration "####" ,
    CALL print (calcpos (154 ,y_pos ) ) ,t_rec->qual[i ].appt_synonym_free ,
    CALL print (calcpos (330 ,y_pos ) ) ,t_rec->qual[i ].sch_state_disp ,
    FOR (j = 1 TO t_rec->qual[i ].detail_qual_cnt )
     IF ((t_rec->qual[i ].detail_qual[j ].oe_field_meaning = "REFERPHYS" ) )
      CALL print (calcpos (432 ,y_pos ) ) ,t_rec->qual[i ].detail_qual[j ].oe_field_display_value
      "##############################;;t" ,j = (t_rec->qual[i ].detail_qual_cnt + 1 )
     ENDIF
    ENDFOR
    ,row + 1 ,
    FOR (j = 1 TO t_rec->qual[i ].patient_qual_cnt )
     IF ((y_pos > 681 ) ) t_cont_ind = 0 ,
      BREAK
     ENDIF
     ,y_pos +=13 ,col 0 ,"{F/4}{CPI/12}{LPI/6}" ,
     CALL print (calcpos (72 ,y_pos ) ) ,"{B}" ,"Person: " ,"{ENDB}" ,
     CALL print (calcpos (112 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].name ,row + 1 ,
     IF ((y_pos > 681 ) ) t_cont_ind = 0 ,
      BREAK
     ENDIF
     ,y_pos +=13 ,col 0 ,"{F/4}{CPI/12}{LPI/6}" ,
     CALL print (calcpos (72 ,y_pos ) ) ,"{B}" ,"Home Phone: " ,"{ENDB}" ,
     CALL print (calcpos (138 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].home_phone ,row + 1 ,col
     + 0 ,
     CALL print (calcpos (216 ,y_pos ) ) ,"{B}" ,"MRN:" ,"{ENDB}" ,
     CALL print (calcpos (250 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].mrn ,row + 1 ,col + 0 ,
     CALL print (calcpos (355 ,y_pos ) ) ,"{B}" ,"DOB:" ,"{ENDB}" ,
     CALL print (calcpos (389 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].birth_formatted ,row + 1 ,
     col + 0 ,
     CALL print (calcpos (432 ,y_pos ) ) ,"{B}" ,"Sex:" ,"{ENDB}" ,
     CALL print (calcpos (473 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].sex ,row + 1 ;,
;     IF ((t_rec->qual[i ].patient_qual[j ].appt_qual_cnt > 0 ) )
;      IF ((y_pos > 694 ) ) t_cont_ind = 0 ,
;       BREAK
;      ENDIF
;      ,y_pos +=13 ,row + 1 ,"{F/6}" ,
;      CALL print (calcpos (154 ,y_pos ) ) ,"{B}Date" ,
;      CALL print (calcpos (212 ,y_pos ) ) ,"{B}Time" ,
;      CALL print (calcpos (250 ,y_pos ) ) ,"{B}Dur" ,
;      CALL print (calcpos (288 ,y_pos ) ) ,"{B}Appointment Type" ,
;      CALL print (calcpos (416 ,y_pos ) ) ,"{B}State" ,
;      CALL print (calcpos (486 ,y_pos ) ) ,"{B}Resource" ,row + 1 ,"{ENDB}" ,
;      FOR (k = 1 TO t_rec->qual[i ].patient_qual[j ].appt_qual_cnt )
;       IF ((y_pos > 707 ) ) t_cont_ind = 0 ,
;        BREAK
;       ENDIF
;       ,y_pos +=13 ,col 0 ,"{F/6}" ,
;       CALL print (calcpos (154 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].appt_qual[k ].beg_dt_tm "@SHORTDATE" ,
;       CALL print (calcpos (212 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].appt_qual[k ].beg_dt_tm "@TIMENOSECONDS" ,
;       CALL print (calcpos (250 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].appt_qual[k ].duration "####" ,
;       CALL print (calcpos (288 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].appt_qual[k ].appt_synonym_free ,
;       CALL print (calcpos (416 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].appt_qual[k ].sch_state_disp ,
;       CALL print (calcpos (486 ,y_pos ) ) ,t_rec->qual[i ].patient_qual[j ].appt_qual[k ].primary_resource_mnem ,row + 1
;      ENDFOR
;     ENDIF
    ENDFOR
    ,
    FOR (j = 1 TO t_rec->qual[i ].detail_qual_cnt )
     IF (1 ) t_rec->temp_string = concat ("{B}" ,t_rec->qual[i ].detail_qual[j ].description ,
       "{ENDB}" ) ,
      CASE (t_rec->qual[i ].detail_qual[j ].field_type_flag )
       OF 0 :
        IF ((t_rec->qual[i ].detail_qual[j ].description IN ("Diagnosis:" ,
        "Procedure:" ) ) ) t_rec->temp_string = concat (t_rec->temp_string ,"  {B}" ,trim (t_rec->
           qual[i ].detail_qual[j ].oe_field_display_value ) ,"{ENDB}" )
        ELSE t_rec->temp_string = concat (t_rec->temp_string ,"  " ,t_rec->qual[i ].detail_qual[j ].
          oe_field_display_value )
        ENDIF
       OF 1 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,format (t_rec->qual[i ].detail_qual[j
          ].oe_field_value ,";l;i" ) )
       OF 2 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,format (t_rec->qual[i ].detail_qual[j
          ].oe_field_value ,";l;f" ) )
       OF 3 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,format (t_rec->qual[i ].detail_qual[j
          ].oe_field_dt_tm_value ,"@SHORTDATE" ) )
       OF 4 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,format (t_rec->qual[i ].detail_qual[j
          ].oe_field_dt_tm_value ,"@TIMENOSECONDS" ) )
       OF 5 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,format (t_rec->qual[i ].detail_qual[j
          ].oe_field_dt_tm_value ,"@SHORTDATETIME" ) )
       OF 6 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,t_rec->qual[i ].detail_qual[j ].
         oe_field_display_value )
       OF 7 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,evaluate (t_rec->qual[i ].detail_qual[
          j ].oe_field_value ,1.0 ,"Yes" ,"No" ) )
       OF 8 :
        t_rec->temp_string = concat (t_rec->temp_string ,"  " ,t_rec->qual[i ].detail_qual[j ].
         oe_field_display_value )
       ELSE t_rec->temp_string = concat (t_rec->temp_string ,"  " ,t_rec->qual[i ].detail_qual[j ].
         oe_field_display_value )
      ENDCASE
      ,row + 1 ,
      IF ((y_pos > 707 ) ) t_cont_ind = 0 ,
       BREAK
      ENDIF
      ,t_rec->temp_size = size (t_rec->temp_string ) ,y_pos +=t_detail_offset ,
      "{F/4}{CPI/15}{LPI/6}" ,print_line120 = substring (1 ,120 ,t_rec->temp_string ) ,
      CALL print (calcpos (90 ,y_pos ) ) ,print_line120 ,
      IF ((t_rec->temp_size > 120 ) ) x_pos = 18 ,
       IF ((y_pos > 707 ) ) t_cont_ind = 0 ,
        BREAK
       ENDIF
       ,y_pos +=t_detail_offset ,print_line120 = substring (121 ,120 ,t_rec->temp_string ) ,
       CALL print (calcpos ((90 + x_pos ) ,y_pos ) ) ,print_line120 ,
       IF ((t_rec->temp_size > 240 ) )
        IF ((y_pos > 707 ) ) t_cont_ind = 0 ,
         BREAK
        ENDIF
        ,y_pos +=t_detail_offset ,print_line120 = substring (241 ,120 ,t_rec->temp_string ) ,
        CALL print (calcpos ((90 + x_pos ) ,y_pos ) ) ,print_line120
       ENDIF
      ENDIF
      ,row + 1
     ENDIF
    ENDFOR
    ,y_pos +=13
    ENDIF
   ENDFOR
  FOOT PAGE
   row + 1 ,
   col 0 ,
   "{F/4}{CPI/12}{LPI/6}" ,
   IF (t_cont_ind )
    CALL print (calcpos (216 ,756 ) ) ,"*** End of " ,t_foot_sort_field "@SHORTDATE" ,
    " appointments ***"
   ELSE
    CALL print (calcpos (252 ,756 ) ) ,"*** To be continued ***"
   ENDIF
  WITH nocounter ,dio = postscript ,formfeed = post ,maxcol = 2000 ,maxrow = 2000
 ;end select
 SUBROUTINE  (getcodevalue (code_set =i4 ,cdf_meaning =c12 ,code_variable =f8 (ref ) ) =f8 )
  SET stat = uar_get_meaning_by_codeset (code_set ,cdf_meaning ,1 ,code_variable )
  IF ((((stat != 0 ) ) OR ((code_variable <= 0 ) )) )
   CALL echo (build ("Invalid select on CODE_SET (" ,code_set ,"),  CDF_MEANING(" ,cdf_meaning ,")"
     ) )
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO


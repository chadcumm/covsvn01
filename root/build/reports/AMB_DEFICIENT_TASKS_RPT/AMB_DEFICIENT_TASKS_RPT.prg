DROP PROGRAM cov_amb_deficient_tasks_rpt :dba GO
CREATE PROGRAM cov_amb_deficient_tasks_rpt :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Date of Service Begin" = "CURDATE" ,
  "Date of Service End" = "CURDATE" ,
  "Organization" = 0 ,
  "Choose a task type" = 0 ,
  "Ordering Provider" = 0 ,
  "Run in spreadsheet format" = 1
  WITH outdev ,start_date ,end_date ,organization_prompt ,task_type_prompt ,provider_prompt ,
  excel_prompt
 DECLARE notdocumented = vc WITH public ,constant ("--" )
 DECLARE who_running = f8
 DECLARE who_running_name = c25
 DECLARE display_org = vc WITH constant (fillstring (30 ," " ) )
 DECLARE display_loc = vc WITH constant (fillstring (30 ," " ) )
 DECLARE display_provider = vc WITH constant (fillstring (30 ," " ) )
 DECLARE display_pat = vc WITH constant (fillstring (30 ," " ) )
 DECLARE display_mrn = vc WITH constant (fillstring (12 ," " ) )
 DECLARE display_encntr = vc WITH constant (fillstring (12 ," " ) )
 DECLARE display_start = vc
 DECLARE display_end = vc
 DECLARE startdate = vc
 DECLARE enddate = vc
 DECLARE org_id_from_prompt = f8
 DECLARE person_mrn_alias_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,4 ,"MRN" ) )
 DECLARE task_in_process = f8 WITH constant (uar_get_code_by ("MEANING" ,79 ,"INPROCESS" ) )
 DECLARE task_pending = f8 WITH constant (uar_get_code_by ("MEANING" ,79 ,"PENDING" ) )
 DECLARE task_overdue = f8 WITH constant (uar_get_code_by ("MEANING" ,79 ,"OVERDUE" ) )
 DECLARE task_opened = f8 WITH constant (uar_get_code_by ("MEANING" ,79 ,"OPENED" ) )
 DECLARE script_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,6003 ,"ORDER" ) )
 DECLARE address_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,212 ,"HOME" ) )
 DECLARE phone_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,43 ,"HOME" ) )
 DECLARE us_ph_format = f8 WITH constant (uar_get_code_by ("MEANING" ,281 ,"US" ) )
 DECLARE dr_number = f8
 DECLARE check_date = vc
 DECLARE totalcnt = i4
 DECLARE did_we_print = vc
 DECLARE prov_all = vc
 DECLARE query_start_time = f8 WITH public ,noconstant (0.00 )
 DECLARE cur_time_temp = f8 WITH public ,noconstant (0.00 )
 DECLARE query_stop_time = vc WITH public ,noconstant ("" )
 DECLARE elapsed_time = f8 WITH public ,noconstant (0.00 )
 SET did_we_print = "N"
 SET line = fillstring (130 ,"*" )
 SET line2 = fillstring (130 ,"-" )
 SET start_dt_tm = cnvtdatetime (cnvtdate2 ( $START_DATE ,"MM/DD/YYYY" ) ,0 )
 SET end_dt_tm = cnvtdatetime (cnvtdate2 ( $END_DATE ,"MM/DD/YYYY" ) ,2359 )
 SET display_start =  $START_DATE
 SET display_end =  $END_DATE
 DECLARE pname_max = i4 WITH protect ,noconstant (0 )
 DECLARE locname_max = i4 WITH protect ,noconstant (0 )
 DECLARE prname_max = i4 WITH protect ,noconstant (0 )
 DECLARE pr2name_max = i4 WITH protect ,noconstant (0 )
 DECLARE ordname_max = i4 WITH protect ,noconstant (0 )
 DECLARE orddet_max = i4 WITH protect ,noconstant (0 )
 DECLARE addr_max = i4 WITH protect ,noconstant (0 )
 DECLARE tasktype_max = i4 WITH protect ,noconstant (0 )
 DECLARE taskdesc_max = i4 WITH protect ,noconstant (0 )
 DECLARE prov_param_num = i4 WITH public ,constant (6 )
 DECLARE task_num = i4 WITH public ,constant (5 )
 SET tpar = reflect (parameter (task_num ,0 ) )
 FREE SET prov_param
 RECORD prov_param (
   1 prov_cnt = i4
   1 provider [* ]
     2 value = f8
 )
 SET par = reflect (parameter (prov_param_num ,0 ) )
 CALL echo (par )
 IF ((substring (1 ,1 ,par ) = "C" ) )
  SET prov_param->prov_cnt = (prov_param->prov_cnt + 1 )
  SET stat = alterlist (prov_param->provider ,prov_param->prov_cnt )
  SET prov_param->provider[prov_param->prov_cnt ].value = 0.0
 ELSEIF ((substring (1 ,1 ,par ) = "F" ) )
  SET prov_param->prov_cnt = (prov_param->prov_cnt + 1 )
  SET stat = alterlist (prov_param->provider ,prov_param->prov_cnt )
  SET prov_param->provider[prov_param->prov_cnt ].value = value ( $PROVIDER_PROMPT )
 ELSEIF ((substring (1 ,1 ,par ) = "L" ) )
  SET prov_param->prov_cnt = (prov_param->prov_cnt + 1 )
  SET stat = alterlist (prov_param->provider ,prov_param->prov_cnt )
  SET prov_param->provider[prov_param->prov_cnt ].value = 0.0
  SET lnum = 1
  WHILE ((lnum > 0 ) )
   SET par = reflect (parameter (prov_param_num ,lnum ) )
   IF ((par = " " ) )
    SET prov_param->prov_cnt = (lnum - 1 )
    SET lnum = 0
   ELSE
    SET stat = alterlist (prov_param->provider ,lnum )
    SET prov_param->provider[lnum ].value = parameter (prov_param_num ,lnum )
    SET lnum = (lnum + 1 )
   ENDIF
  ENDWHILE
 ENDIF
 IF ((substring (1 ,1 ,reflect (parameter (prov_param_num ,0 ) ) ) = "C" ) )
  SET prov_all = "ALL"
 ENDIF
 CALL echorecord (prov_param )
 CALL echo (build ("PROV_ALL: " ,prov_all ) )
 SELECT INTO "nl:"
  FROM (person p )
  PLAN (p
   WHERE (p.person_id = reqinfo->updt_id ) )
  DETAIL
   who_running = p.person_id ,
   who_running_name = p.name_full_formatted
  WITH nocounter
 ;end select
 DECLARE prov_seq = i4 WITH public ,noconstant (0 )
 DECLARE pers_seq = i4 WITH public ,noconstant (0 )
 SET num_seq = 0
 FREE RECORD qual
 RECORD qual (
   1 qual_cnt = i4
   1 qual [* ]
     2 location = vc
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 dob = vc
     2 age = vc
     2 gender = vc
     2 mrn = vc
     2 fin = vc
     2 home_address = vc
     2 home_phone = vc
     2 ord_name = vc
     2 ord_date = vc
     2 ord_prov = vc
     2 ord_by = vc
     2 ord_det = vc
     2 task_type = vc
     2 task_desc = vc
     2 task_date = vc
     2 ord_status = vc
     2 task_status = vc
 )
 SET query_start_time = cnvtdatetime (curdate ,curtime3 )
 DECLARE task_parser = vc WITH public ,noconstant ("" )
 IF ((substring (1 ,1 ,reflect (parameter (task_num ,0 ) ) ) != "C" ) )
  DECLARE task_parser_val = f8
  SET task_parser_val = value ( $TASK_TYPE_PROMPT )
  SET task_parser = "ta.task_type_cd = task_parser_val"
 ELSE
  SET task_parser = "1=1"
 ENDIF
 SELECT DISTINCT INTO "nl:"
  location = uar_get_code_description (e.location_cd ) ,
  patient = trim (p.name_full_formatted ) ,
  task_date = format (ta.task_dt_tm ,"MM/DD/YYYY HH:MM;;d" )
  FROM (task_activity ta ),
   (order_task ot ),
   (orders o ),
   (order_action oa ),
   (encounter e ),
   (prsnl prsnl1 ),
   (prsnl prsnl2 ),
   (person p ),
   (person_alias pa ),
   (address a ),
   (phone ph ),
   (encntr_alias ea )
  PLAN (e
   WHERE (e.reg_dt_tm BETWEEN cnvtdatetime (start_dt_tm ) AND cnvtdatetime (end_dt_tm ) )
   AND (e.organization_id =  $ORGANIZATION_PROMPT ) )
   JOIN (ta
   WHERE (ta.encntr_id = e.encntr_id )
   AND (ta.order_id > 0 )
   AND parser (task_parser )
   AND (ta.task_status_cd IN (task_overdue ,
   task_in_process ,
   task_pending ,
   task_opened ) ) )
   JOIN (ot
   WHERE (ot.reference_task_id = ta.reference_task_id ) )
   JOIN (o
   WHERE (o.order_id = ta.order_id ) )
   JOIN (oa
   WHERE (oa.order_id = o.order_id )
   AND (oa.action_type_cd = value (uar_get_code_by ("MEANING" ,6003 ,"ORDER" ) ) )
   AND ((expand (prov_seq ,1 ,prov_param->prov_cnt ,oa.order_provider_id ,prov_param->provider[
    prov_seq ].value ) ) OR ((prov_all = "ALL" ) )) )
   JOIN (prsnl1
   WHERE (prsnl1.person_id = o.active_status_prsnl_id ) )
   JOIN (prsnl2
   WHERE (prsnl2.person_id = oa.order_provider_id ) )
   JOIN (p
   WHERE (p.person_id = ta.person_id ) )
   JOIN (ea
   WHERE (ea.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea.encntr_alias_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) ) )
   )
   AND (ea.active_ind = outerjoin (1 ) ) )
   JOIN (pa
   WHERE (pa.person_id = outerjoin (p.person_id ) )
   AND (pa.person_alias_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,4 ,"MRN" ) ) ) )
   AND (pa.active_ind = outerjoin (1 ) ) )
   JOIN (a
   WHERE (a.parent_entity_id = outerjoin (p.person_id ) )
   AND (a.parent_entity_name = outerjoin ("PERSON" ) )
   AND (a.address_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,212 ,"HOME" ) ) ) )
   AND (a.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (a.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (a.active_ind = outerjoin (1 ) ) )
   JOIN (ph
   WHERE (ph.parent_entity_id = outerjoin (p.person_id ) )
   AND (ph.parent_entity_name = outerjoin ("PERSON" ) )
   AND (ph.phone_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,43 ,"HOME" ) ) ) )
   AND (ph.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (ph.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (ph.active_ind = outerjoin (1 ) ) )
  ORDER BY location ,
   patient ,
   task_date ,
   o.order_id
  HEAD REPORT
   qual->qual_cnt = 0
  DETAIL
   qual->qual_cnt = (qual->qual_cnt + 1 ) ,
   IF ((mod (qual->qual_cnt ,1000 ) = 1 ) ) stat = alterlist (qual->qual ,(qual->qual_cnt + 1000 ) )
   ENDIF
   ,
   IF ((qual->qual_cnt = 1 ) ) qual->qual[qual->qual_cnt ].location = "Location" ,qual->qual[qual->
    qual_cnt ].name = "Patient_Name" ,qual->qual[qual->qual_cnt ].dob = "Date_of_Birth" ,qual->qual[
    qual->qual_cnt ].age = "Age" ,qual->qual[qual->qual_cnt ].gender = "Gender" ,qual->qual[qual->
    qual_cnt ].mrn = "MRN" ,qual->qual[qual->qual_cnt ].fin = "Encounter#" ,qual->qual[qual->qual_cnt
     ].home_address = "Home_Address" ,qual->qual[qual->qual_cnt ].home_phone = "Home_Phone" ,qual->
    qual[qual->qual_cnt ].ord_name = "Order_Name" ,qual->qual[qual->qual_cnt ].ord_date = "Ordered" ,
    qual->qual[qual->qual_cnt ].ord_prov = "Ordering_Provider" ,qual->qual[qual->qual_cnt ].ord_by =
    "Order_Entered_By" ,qual->qual[qual->qual_cnt ].ord_det = "Order_Details" ,qual->qual[qual->
    qual_cnt ].task_type = "Type" ,qual->qual[qual->qual_cnt ].task_desc = "Task" ,qual->qual[qual->
    qual_cnt ].task_date = "Task_Created" ,qual->qual[qual->qual_cnt ].ord_status =
    "Current_Order_Status" ,qual->qual[qual->qual_cnt ].task_status = "Current_Task_Status" ,
    locname_max = (cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].location ) ) ) + 1 ) ,
    pname_max = (cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].name ) ) ) + 1 ) ,addr_max = (
    cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].home_address ) ) ) + 1 ) ,ordname_max = (
    cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_name ) ) ) + 1 ) ,prname_max = (cnvtint (
     textlen (trim (qual->qual[qual->qual_cnt ].ord_prov ) ) ) + 1 ) ,pr2name_max = (cnvtint (
     textlen (trim (qual->qual[qual->qual_cnt ].ord_by ) ) ) + 1 ) ,orddet_max = (cnvtint (textlen (
      trim (qual->qual[qual->qual_cnt ].ord_det ) ) ) + 1 ) ,tasktype_max = (cnvtint (textlen (trim (
       qual->qual[qual->qual_cnt ].task_type ) ) ) + 1 ) ,taskdesc_max = (cnvtint (textlen (trim (
       qual->qual[qual->qual_cnt ].task_desc ) ) ) + 1 ) ,qual->qual_cnt = (qual->qual_cnt + 1 )
   ENDIF
   ,qual->qual[qual->qual_cnt ].location = notdocumented ,
   qual->qual[qual->qual_cnt ].name = notdocumented ,
   qual->qual[qual->qual_cnt ].dob = notdocumented ,
   qual->qual[qual->qual_cnt ].age = notdocumented ,
   qual->qual[qual->qual_cnt ].home_address = notdocumented ,
   qual->qual[qual->qual_cnt ].home_phone = notdocumented ,
   qual->qual[qual->qual_cnt ].ord_name = notdocumented ,
   qual->qual[qual->qual_cnt ].ord_date = notdocumented ,
   qual->qual[qual->qual_cnt ].ord_prov = notdocumented ,
   qual->qual[qual->qual_cnt ].ord_by = notdocumented ,
   qual->qual[qual->qual_cnt ].task_type = notdocumented ,
   qual->qual[qual->qual_cnt ].task_desc = notdocumented ,
   qual->qual[qual->qual_cnt ].task_date = notdocumented ,
   qual->qual[qual->qual_cnt ].ord_status = notdocumented ,
   qual->qual[qual->qual_cnt ].task_status = notdocumented ,
   qual->qual[qual->qual_cnt ].person_id = o.person_id ,
   qual->qual[qual->qual_cnt ].encntr_id = o.encntr_id ,
   qual->qual[qual->qual_cnt ].location = trim (uar_get_code_description (e.location_cd ) ) ,
   IF ((locname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].location ) ) ) ) )
    locname_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].location ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].name = trim (p.name_full_formatted ) ,
   IF ((pname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].name ) ) ) ) ) pname_max =
    cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].name ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/DD/YYYY" ) ,
   qual->qual[qual->qual_cnt ].age = trim (substring (1 ,12 ,cnvtage (cnvtdate (p.birth_dt_tm ) ,
      curdate ) ) ,3 ) ,
   qual->qual[qual->qual_cnt ].gender = uar_get_code_display (p.sex_cd ) ,
   IF ((qual->qual[qual->qual_cnt ].gender = null ) ) qual->qual[qual->qual_cnt ].gender =
    notdocumented
   ENDIF
   ,qual->qual[qual->qual_cnt ].mrn = substring (1 ,16 ,cnvtalias (pa.alias ,pa.alias_pool_cd ) ) ,
   IF ((qual->qual[qual->qual_cnt ].mrn = null ) ) qual->qual[qual->qual_cnt ].mrn = notdocumented
   ENDIF
   ,qual->qual[qual->qual_cnt ].fin = concat ("0" ,substring (1 ,11 ,ea.alias ) ) ,
   IF ((qual->qual[qual->qual_cnt ].fin = null ) ) qual->qual[qual->qual_cnt ].fin = notdocumented
   ENDIF
   ,
   IF ((ph.phone_type_cd = phone_cd ) )
    IF ((ph.phone_format_cd = 0.0 ) ) qual->qual[qual->qual_cnt ].home_phone = cnvtphone (ph
      .phone_num_key ,us_ph_format )
    ELSE qual->qual[qual->qual_cnt ].home_phone = cnvtphone (ph.phone_num_key ,ph.phone_format_cd )
    ENDIF
   ENDIF
   ,
   IF ((a.street_addr > " " ) ) qual->qual[qual->qual_cnt ].home_address = trim (a.street_addr ) ,
    IF ((a.street_addr2 > " " ) ) qual->qual[qual->qual_cnt ].home_address = concat (trim (qual->
       qual[qual->qual_cnt ].home_address ) ," " ,trim (a.street_addr2 ) )
    ENDIF
    ,
    IF ((a.state_cd > 0.0 ) ) qual->qual[qual->qual_cnt ].home_address = concat (qual->qual[qual->
      qual_cnt ].home_address ," " ,trim (a.city ) ,", " ,trim (uar_get_code_display (a.state_cd ) )
      ," " ,trim (a.zipcode ) )
    ELSE qual->qual[qual->qual_cnt ].home_address = concat (qual->qual[qual->qual_cnt ].home_address
      ," " ,trim (a.city ) ,", " ,trim (a.state ) ," " ,trim (a.zipcode ) )
    ENDIF
    ,
    IF ((addr_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].home_address ) ) ) ) )
     addr_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].home_address ) ) )
    ENDIF
   ENDIF
   ,qual->qual[qual->qual_cnt ].ord_name = trim (o.ordered_as_mnemonic ) ,
   IF ((ordname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_name ) ) ) ) )
    ordname_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_name ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].ord_date = format (o.orig_order_dt_tm ,"MM/DD/YYYY;;d" ) ,
   qual->qual[qual->qual_cnt ].ord_prov = trim (prsnl2.name_full_formatted ) ,
   IF ((prname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_prov ) ) ) ) )
    prname_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_prov ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].ord_by = trim (prsnl1.name_full_formatted ) ,
   IF ((pr2name_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_by ) ) ) ) )
    pr2name_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_by ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].ord_det = trim (o.clinical_display_line ) ,
   IF ((orddet_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_det ) ) ) ) )
    orddet_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_det ) ) )
   ENDIF
   ,
   IF ((qual->qual[qual->qual_cnt ].ord_det = null ) ) qual->qual[qual->qual_cnt ].ord_det =
    notdocumented
   ENDIF
   ,qual->qual[qual->qual_cnt ].task_type = trim (uar_get_code_display (ta.task_type_cd ) ) ,
   IF ((tasktype_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].task_type ) ) ) ) )
    tasktype_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].task_type ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].task_desc = trim (ot.task_description ) ,
   IF ((taskdesc_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].task_desc ) ) ) ) )
    taskdesc_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].task_desc ) ) )
   ENDIF
   ,qual->qual[qual->qual_cnt ].task_date = format (ta.task_dt_tm ,"MM/DD/YYYY HH:MM;;d" ) ,
   qual->qual[qual->qual_cnt ].ord_status = trim (uar_get_code_display (o.order_status_cd ) ) ,
   qual->qual[qual->qual_cnt ].task_status = trim (uar_get_code_display (ta.task_status_cd ) )
  FOOT REPORT
   stat = alterlist (qual->qual ,qual->qual_cnt )
  WITH nocounter
 ;end select
 IF ((qual->qual_cnt > 0 ) )
  IF (( $EXCEL_PROMPT = 1 ) )
   SELECT INTO  $OUTDEV
    location = substring (1 ,value (locname_max ) ,qual->qual[d.seq ].location ) ,
    patient = substring (1 ,value (pname_max ) ,qual->qual[d.seq ].name ) ,
    patient_dob = substring (1 ,15 ,qual->qual[d.seq ].dob ) ,
    patient_age = substring (1 ,12 ,qual->qual[d.seq ].age ) ,
    patient_gender = substring (1 ,10 ,qual->qual[d.seq ].gender ) ,
    patient_mrn = substring (1 ,10 ,qual->qual[d.seq ].mrn ) ,
    patient_address = substring (1 ,value (addr_max ) ,qual->qual[d.seq ].home_address ) ,
    encntr_number = substring (1 ,12 ,qual->qual[d.seq ].fin ) ,
    patient_phone = substring (1 ,15 ,qual->qual[d.seq ].home_phone ) ,
    order_name = substring (1 ,value (ordname_max ) ,qual->qual[d.seq ].ord_name ) ,
    order_date = substring (1 ,20 ,qual->qual[d.seq ].ord_date ) ,
    ordering_provider = substring (1 ,value (prname_max ) ,qual->qual[d.seq ].ord_prov ) ,
    entering_provider = substring (1 ,value (pr2name_max ) ,qual->qual[d.seq ].ord_by ) ,
    order_detail = substring (1 ,value (orddet_max ) ,qual->qual[d.seq ].ord_det ) ,
    task_type = substring (1 ,value (tasktype_max ) ,qual->qual[d.seq ].task_type ) ,
    task_description = substring (1 ,value (taskdesc_max ) ,qual->qual[d.seq ].task_desc ) ,
    task_date = substring (1 ,20 ,qual->qual[d.seq ].task_date ) ,
    current_order_status = substring (1 ,21 ,qual->qual[d.seq ].ord_status ) ,
    current_task_status = substring (1 ,21 ,qual->qual[d.seq ].task_status )
    FROM (dummyt d WITH seq = value (qual->qual_cnt ) )
    PLAN (d
     WHERE (d.seq > 0 ) )
    WITH nocounter
   ;end select
   IF ((qual->qual_cnt > 0 ) )
    SET did_we_print = "Y"
   ENDIF
  ELSE
   SELECT INTO  $OUTDEV
    location = substring (1 ,40 ,qual->qual[d.seq ].location ) ,
    patient = substring (1 ,40 ,qual->qual[d.seq ].name ) ,
    patient_dob = substring (1 ,15 ,qual->qual[d.seq ].dob ) ,
    patient_age = substring (1 ,12 ,qual->qual[d.seq ].age ) ,
    patient_gender = substring (1 ,10 ,qual->qual[d.seq ].gender ) ,
    patient_mrn = substring (1 ,10 ,qual->qual[d.seq ].mrn ) ,
    encntr_number = substring (1 ,12 ,qual->qual[d.seq ].fin ) ,
    patient_address = substring (1 ,100 ,qual->qual[d.seq ].home_address ) ,
    patient_phone = substring (1 ,15 ,qual->qual[d.seq ].home_phone ) ,
    order_name = substring (1 ,40 ,qual->qual[d.seq ].ord_name ) ,
    order_date = substring (1 ,20 ,qual->qual[d.seq ].ord_date ) ,
    ordering_provider = substring (1 ,40 ,qual->qual[d.seq ].ord_prov ) ,
    entering_provider = substring (1 ,35 ,qual->qual[d.seq ].ord_by ) ,
    order_detail = substring (1 ,33 ,qual->qual[d.seq ].ord_det ) ,
    task_type = substring (1 ,25 ,qual->qual[d.seq ].task_type ) ,
    task_description = substring (1 ,45 ,qual->qual[d.seq ].task_desc ) ,
    task_date = substring (1 ,20 ,qual->qual[d.seq ].task_date ) ,
    current_order_status = substring (1 ,12 ,qual->qual[d.seq ].ord_status ) ,
    current_task_status = substring (1 ,12 ,qual->qual[d.seq ].task_status ) ,
    person_id = qual->qual[d.seq ].person_id
    FROM (dummyt d WITH seq = value (qual->qual_cnt ) )
    PLAN (d
     WHERE (d.seq > 1 ) )
    HEAD PAGE
     row 1 ,
     col 1 ,
     "Outstanding/Deficient Task Report" ,
     row 1 ,
     col 100 ,
     "By: " ,
     row 1 ,
     col 106 ,
     who_running_name ,
     row 2 ,
     col 1 ,
     "Requested Dates:" ,
     row 2 ,
     col 21 ,
     display_start ,
     row 2 ,
     col 32 ,
     "to" ,
     row 2 ,
     col 35 ,
     display_end ,
     row 2 ,
     col 100 ,
     "Run:" ,
     today = format (curdate ,"MM/DD/YY;;d" ) ,
     row 2 ,
     col 106 ,
     today ,
     now = format (curtime ,"hh:mm;;s" ) ,
     row 2 ,
     col 115 ,
     now ,
     row 3 ,
     col 100 ,
     "Page:" ,
     pge = trim (cnvtstring (curpage ) ,3 ) ,
     row 3 ,
     col 106 ,
     pge ,
     row + 1
    HEAD person_id
     row + 1 ,col 1 ,line ,row + 1 ,col 1 ,"Patient: " ,col 11 ,patient ,col 50 ,"MRN: " ,col 55 ,
     patient_mrn ,col 71 ,"DOB: " ,col 76 ,patient_dob ,col 95 ,"Gender: " ,col 103 ,patient_gender ,
     row + 1 ,col 11 ,"Address: " ,col 20 ,patient_address ,col 71 ,"Phone: " ,col 78 ,patient_phone
     ,col 95 ,"Encounter#:" ,col 107 ,encntr_number ,row + 1 ,col 1 ,line
    DETAIL
     row + 1 ,
     col 13 ,
     "Task: " ,
     col 21 ,
     task_description ,
     col 71 ,
     "Type: " ,
     col 77 ,
     task_type ,
     row + 1 ,
     col 21 ,
     "Task Created: " ,
     col 35 ,
     task_date ,
     col 71 ,
     "Current Task Status: " ,
     col 93 ,
     current_task_status ,
     row + 1 ,
     col 21 ,
     "Order: " ,
     col 28 ,
     order_name ,
     col 71 ,
     "Ordered: " ,
     col 80 ,
     order_date ,
     row + 1 ,
     col 21 ,
     "Order Details: " ,
     col 36 ,
     order_detail ,
     col 71 ,
     "Current Order Status: " ,
     col 93 ,
     current_order_status ,
     row + 1 ,
     col 21 ,
     "Ordering Provider: " ,
     col 40 ,
     ordering_provider ,
     col 71 ,
     "Order Entered By: " ,
     col 89 ,
     entering_provider ,
     totalcnt = (totalcnt + 1 ) ,
     did_we_print = "Y" ,
     row + 1
    FOOT  person_id
     null
    FOOT REPORT
     col 1 ,
     line ,
     row + 1 ,
     col 8 ,
     "Grand Total: " ,
     count = trim (cnvtstring (totalcnt ) ,3 ) ,
     col 22 ,
     count ,
     CALL center ("***** END OF REPORT *****" ,0 ,130 ) ,
     row + 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((did_we_print = "N" ) )
  SELECT INTO  $OUTDEV
   FROM (dummyt d )
   PLAN (d )
   DETAIL
    row 1 ,
    col 1 ,
    "Outstanding/Deficient Task Report" ,
    row 1 ,
    col 100 ,
    "By: " ,
    row 1 ,
    col 106 ,
    who_running_name ,
    row 2 ,
    col 1 ,
    "Requested Dates:" ,
    row 2 ,
    col 21 ,
    display_start ,
    row 2 ,
    col 32 ,
    "to" ,
    row 2 ,
    col 35 ,
    display_end ,
    row 2 ,
    col 100 ,
    "Run:" ,
    today = format (curdate ,"MM/DD/YY;;d" ) ,
    row 2 ,
    col 106 ,
    today ,
    now = format (curtime ,"hh:mm;;s" ) ,
    row 2 ,
    col 115 ,
    now ,
    row 3 ,
    col 100 ,
    "Page:" ,
    pge = trim (cnvtstring (curpage ) ,3 ) ,
    row 3 ,
    col 106 ,
    pge ,
    row + 2 ,
    col 1 ,
    line ,
    row + 3 ,
    CALL center ("NO INFORMATION RETURNED" ,0 ,130 ) ,
    row + 3 ,
    col 1 ,
    line ,
    row + 1 ,
    CALL center ("***** END OF REPORT *****" ,0 ,130 )
   WITH nocounter ,dontcare = d
  ;end select
 ENDIF
 SET query_stop_time = format (cnvtdatetime (curdate ,curtime3 ) ,"MM/DD/YYYY HH:MM:ss;;d" )
 SET cur_time_temp = cnvtdatetime (curdate ,curtime3 )
 SET elapsed_time = round (datetimediff (cur_time_temp ,query_start_time ,5 ) ,4 )
#exit_program
END GO

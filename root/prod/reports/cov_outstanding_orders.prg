/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:				Unknown
	Date Written:		June 2018
	Solution:			Ambulatory
	Source file name:  	cov_outstanding_orders.prg
	Object name:		cov_outstanding_orders
	Request#:
 
	Program purpose:	Show outstanding Orders
	Executing from:		CCL/DA2/Ambulatory folder
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	     Developer			     Comment
----------	     --------------------	------------------------------------------
001 08/03/2018   Dawn Greer, DBA        Filter out TEST Patients (ZZZ*, TTT*, FFF*)
002 07/10/2019   Dawn Greer, DBA        Add criteria to Phone and Address subqueries
                                        to look for parent_entity_name = 'PERSON' 
                                        and thus get the correct phone number and
                                        address.
******************************************************************************/
 
 
DROP PROGRAM cov_outstanding_orders :dba GO
CREATE PROGRAM cov_outstanding_orders :dba
 prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Ordered From" = "CURDATE"
	, "Ordered To" = "CURDATE"
	, "Location" = 0
	, "Provider" = 0
	, "Order Type:" = 0
	, "Run in spreadsheet format" = 1
 
with
OUTDEV, ORDERED_FROM, ORDERED_TO, LOC_PROMPT, PROVIDER_PROMPT, MEDS, EXCEL_PROMPT
 DECLARE indx_type = i4 WITH protect ,noconstant (0 )
 DECLARE logging = i4 WITH protect ,noconstant (0 )
 DECLARE report_name = vc WITH protect ,constant ("Outstanding Orders Report" )
 SET indx_type = 1
 SET logging = 1
 IF ((checkdic (cnvtupper ("amb_location_encntr_index" ) ,"P" ,0 ) = 0 ) )
  CALL echo ("*** FAILURE ***" )
  CALL echo ("*** amb_location_encntr_index program not in object library, exiting script.***" )
  CALL echo (
   "*** Validate amb_location_encntr_index program is in the correct directory and included. ***" )
  GO TO exit_program
 ENDIF
 DECLARE location = f8 WITH constant ( $LOC_PROMPT )
 DECLARE location_name = vc WITH constant (uar_get_code_description (cnvtreal ( $LOC_PROMPT ) ) )
 DECLARE indx_type_name = vc WITH protect ,noconstant ("" )
 DECLARE num_seq = i4 WITH protect ,noconstant (0 )
 DECLARE loc_seq = i4 WITH protect ,noconstant (0 )
 FREE RECORD indx_reply
 RECORD indx_reply (
   1 indx_cnt = i4
   1 indx [* ]
     2 person_id = f8
     2 encntr_id = f8
   1 status_flag = c1
   1 indx_loc_cnt = i4
   1 indx_loc [* ]
     2 location_cd = f8
   1 loc_status_flag = c1
 )
 EXECUTE amb_location_encntr_index location ,
 indx_type ,
 logging WITH replace ("INDX_REC" ,indx_reply )
 FREE RECORD indx_rec
 IF ((logging = 1 ) )
  IF ((indx_type = 0 ) )
   SET indx_type_name = "Location CD Only"
  ELSEIF ((indx_type = 1 ) )
   SET indx_type_name = "Person_id Only"
  ELSEIF ((indx_type = 2 ) )
   SET indx_type_name = "Encntr_id Only"
  ELSEIF ((indx_type = 3 ) )
   SET indx_type_name = "Person_id and Encntr_id"
  ENDIF
 ENDIF
 IF ((((indx_reply->status_flag = "F" )
 AND (indx_type != 0 ) ) OR ((indx_reply->loc_status_flag = "F" ) )) )
  GO TO end_program
 ENDIF
 IF ((logging = 1 )
 AND (indx_type != 0 ) )
  CALL echo (build ("***Entering Expand indx_reply***" ) )
 ENDIF
 IF ((indx_type != 0 ) )
  SET actual_size = size (indx_reply->indx ,5 )
  SET expand_size = 200
  SET expand_stop = 200
  SET expand_start = 1
  SET expand_total = (actual_size + (expand_size - mod (actual_size ,expand_size ) ) )
  SET num = 0
  SET stat = alterlist (indx_reply->indx ,expand_total )
  FOR (idx = (actual_size + 1 ) TO expand_total )
   IF ((indx_type = 1 ) )
    SET indx_reply->indx[idx ].person_id = indx_reply->indx[actual_size ].person_id
   ELSEIF ((indx_type = 2 ) )
    SET indx_reply->indx[idx ].encntr_id = indx_reply->indx[actual_size ].encntr_id
   ELSEIF ((indx_type = 3 ) )
    SET indx_reply->indx[idx ].person_id = indx_reply->indx[actual_size ].person_id
    SET indx_reply->indx[idx ].encntr_id = indx_reply->indx[actual_size ].encntr_id
   ENDIF
  ENDFOR
 ENDIF
 IF ((logging = 1 ) )
  IF ((indx_type != 0 ) )
   CALL echo (build ("Actual Size: " ,actual_size ) )
   CALL echo (build ("Expand Total: " ,expand_total ) )
   CALL echo (build ("***Exiting Expand indx_reply***" ) )
  ENDIF
  CALL echo ("***VERIFIYING INDEX CREATED AS INDICATED***" )
  CALL echo (build ("Index Type: " ,indx_type_name ,"--Count: " ,indx_reply->indx_cnt ) )
  CALL echo (build ("PERSON at POS 1: " ,indx_reply->indx[1 ].person_id ) )
  CALL echo (build ("ENCNTR at POS 1: " ,indx_reply->indx[1 ].encntr_id ) )
  CALL echo (build ("LOCATION at POS 1: " ,indx_reply->indx_loc[1 ].location_cd ) )
  CALL echo ("***VERIFICATION COMPLETE***" )
 ENDIF
 DECLARE notdocumented = vc WITH public ,constant ("--" )
 DECLARE prov_all = vc
 DECLARE provider_name = vc
 SET line = fillstring (130 ,"*" )
 DECLARE who_running = f8
 DECLARE who_running_name = vc
 DECLARE display_date = vc
 DECLARE emrn = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,319 ,"MRN" ) )
 DECLARE encntr_fin_alias_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) )
 DECLARE prov_number = f8
 DECLARE home_address_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,212 ,"HOME" ) )
 DECLARE home_phone_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,43 ,"HOME" ) )
 DECLARE us_ph_format = f8 WITH constant (uar_get_code_by ("MEANING" ,281 ,"US" ) )
 DECLARE orderedcd = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"ORDERED" ) )
 DECLARE pharmacy = f8 WITH constant (uar_get_code_by ("MEANING" ,6000 ,"PHARMACY" ) )
 DECLARE did_we_print = vc
 SET did_we_print = "N"
 DECLARE future_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"FUTURE" ) ) ,protect
 DECLARE ordered_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"ORDERED" ) ) ,protect
 DECLARE pname_max = i4 WITH protect ,noconstant (0 )
 DECLARE prname_max = i4 WITH protect ,noconstant (0 )
 DECLARE pr2name_max = i4 WITH protect ,noconstant (0 )
 DECLARE ordname_max = i4 WITH protect ,noconstant (0 )
 DECLARE ordtype_max = i4 WITH protect ,noconstant (0 )
 DECLARE orddet_max = i4 WITH protect ,noconstant (0 )
 DECLARE addr_max = i4 WITH protect ,noconstant (0 )
 DECLARE startdate = f8
 DECLARE enddate = f8
 SET display_start =  $ORDERED_FROM
 SET display_end =  $ORDERED_TO
 SELECT INTO "nl:"
  FROM (person p )
  PLAN (p
   WHERE (p.person_id = reqinfo->updt_id ) )
  DETAIL
   who_running = p.person_id ,
   who_running_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (prsnl pr )
  WHERE (pr.person_id =  $PROVIDER_PROMPT )
  HEAD REPORT
   provider_name = trim (pr.name_full_formatted )
  WITH nocounter
 ;end select
 DECLARE catparser = vc WITH public ,noconstant ("" )
 IF (( $MEDS = 1 ) )
  SET catparser = "o.catalog_type_cd != PHARMACY and o.order_status_cd in (ORDERED_CD,FUTURE_CD)"
 ELSEIF (( $MEDS = 2 ) )
  SET catparser =
  "o.catalog_type_cd > 0 and o.orig_ord_as_flag not in (1,2) and o.order_status_cd in (ORDERED_CD,FUTURE_CD)"
 ELSEIF (( $MEDS = 3 ) )
  SET catparser =
  "o.catalog_type_cd = PHARMACY and o.orig_ord_as_flag not in (1,2) and o.order_status_cd in (ORDERED_CD,FUTURE_CD)"
 ELSEIF (( $MEDS = 4 ) )
  SET catparser = "o.order_status_cd in (FUTURE_CD)"
 ENDIF
 IF ((logging = 1 ) )
  CALL echo (build ("Parser: " ,catparser ) )
  CALL echo (build ("Start Date(converted): " ,startdate ) )
  CALL echo (build ("End Date(converted): " ,enddate ) )
  CALL echo (build ("Start Date(prompt): " , $ORDERED_FROM ) )
  CALL echo (build ("End Date(prompt): " , $ORDERED_TO ) )
  CALL echo (build ("Location: " ,location_name ,"--Location Cd: " ,location ) )
  CALL echo (build ("Include Admin: " , $MEDS ) )
  CALL echo (build ("Excel: " , $EXCEL_PROMPT ) )
  SET query_start_time = cnvtdatetime (curdate ,curtime3 )
  CALL echo (build ("MAIN QUERY START TIME: " ,format (query_start_time ,"MM/DD/YYYY HH:MM:SS;;d" )
    ) )
 ENDIF
 FREE RECORD qual
 RECORD qual (
   1 qual_cnt = i4
   1 qual [* ]
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
     2 ord_type = vc
     2 ord_name = vc
     2 orig_date = vc
     2 ord_prov = vc
     2 ord_by = vc
     2 ord_det = vc
     2 ord_status = vc
     2 order_id = f8
     2 future_date = dq8
     2 grace = vc
     2 future_order_status = vc
 )
 FREE RECORD order_detail_info
 RECORD order_detail_info (
   1 cnt = i4
   1 list [* ]
     2 order_id = f8
     2 date = dq8
     2 date_string = vc
     2 num = i4
     2 unit = vc
 )
 FREE RECORD future_order_info
 RECORD future_order_info (
   1 cnt = i4
   1 list [* ]
     2 order_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 status = vc
 )
 SELECT distinct INTO "nl:"
  p.person_id,
  e.encntr_id,
  o.order_id,
  patient_name = substring (1 ,40 ,p.name_full_formatted ) ,
  ord_as_mn = substring (1 ,40 ,o.ordered_as_mnemonic ) ,
  ord_start = format (o.orig_order_dt_tm ,"MM/DD/YYYY;;d" )
  FROM (orders o ),
   (order_action oa ),
   (prsnl pr1 ),
   (prsnl pr2 ),
   (encounter e ),
   (person p ),
   (encntr_alias ea ),
   (encntr_alias ea1 ),
   (address a ),
   (phone ph ),
   (dummyt d WITH seq = value ((expand_total / expand_size ) ) )
  PLAN (d
   WHERE assign (expand_start ,evaluate (d.seq ,1 ,1 ,(expand_start + expand_size ) ) )
   AND assign (expand_stop ,(expand_start + (expand_size - 1 ) ) ) )
   JOIN (o
   WHERE (o.template_order_flag = 0 )
   AND parser (catparser )
   AND (o.current_start_dt_tm >= cnvtdatetime (cnvtdate2 ( $ORDERED_FROM ,"MM/DD/YY" ) ,0 ) )
   AND (o.current_start_dt_tm <= cnvtdatetime (cnvtdate2 ( $ORDERED_TO ,"MM/DD/YY" ) ,2359 ) )
   AND (o.orderable_type_flag != 6 ) )
   JOIN (oa
   WHERE (oa.order_id = o.order_id )
   AND (oa.action_sequence = 1 )
   AND (oa.order_provider_id =  $PROVIDER_PROMPT ) )
   JOIN (pr1
   WHERE (pr1.person_id = oa.order_provider_id ) )
   JOIN (pr2
   WHERE (pr2.person_id = oa.action_personnel_id ) )
   JOIN (e
   WHERE (e.encntr_id = o.encntr_id ) )
   JOIN (p
   WHERE (p.person_id = o.person_id )
   AND (p.active_ind = 1 )
   AND (p.name_last_key NOT IN ("ZZZ*","TTTT*","FFF*")))    ;001 - Excluding test patients
   JOIN (ea
   WHERE (ea.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea.encntr_alias_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,319 ,"MRN" ) ) ) )
   AND (ea.active_ind = outerjoin (1 ) )
   AND (ea.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (ea.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
   JOIN (ea1
   WHERE (ea1.encntr_id = outerjoin (e.encntr_id ) )
   AND (ea1.encntr_alias_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) )
    ) )
   AND (ea1.active_ind = outerjoin (1 ) )
   AND (ea1.beg_effective_dt_tm < outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (ea1.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
   JOIN (a
   WHERE (a.parent_entity_id = outerjoin (p.person_id ) )
   AND (trim (a.parent_entity_name ) = outerjoin ("PERSON" ) )
   AND (a.address_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,212 ,"HOME" ) ) ) )
   AND (a.address_type_seq = outerjoin (1 ) )
   AND (a.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (a.end_effective_dt_tm >= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (a.active_ind = outerjoin (1 ) )
   AND (a.address_id =
   (SELECT
    max (a1.address_id )
    FROM (address a1 )
    WHERE (a1.parent_entity_id = p.person_id )
    AND (a1.parent_entity_name = 'PERSON') 	;002 - DG - Added to get correct address
    AND (a1.address_type_cd = value (uar_get_code_by ("MEANING" ,212 ,"HOME" ) ) )
    AND (a1.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) )
    AND (a1.active_ind = 1 ) ) ) )
   JOIN (ph
   WHERE (ph.parent_entity_id = outerjoin (p.person_id ) )
   AND (trim (ph.parent_entity_name ) = outerjoin ("PERSON" ) )
   AND (ph.phone_type_cd = outerjoin (value (uar_get_code_by ("MEANING" ,43 ,"HOME" ) ) ) )
   AND (ph.phone_type_seq = outerjoin (1 ) )
   AND (ph.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (ph.end_effective_dt_tm >= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (ph.active_ind = outerjoin (1 ) )
   AND (ph.phone_id =
   (SELECT
    max (ph1.phone_id )
    FROM (phone ph1 )
    WHERE (ph1.parent_entity_id = p.person_id )
    AND (ph1.parent_entity_name = 'PERSON')  ;002 - DG - Added to get correct phone number
    AND (ph1.phone_type_cd = value (uar_get_code_by ("MEANING" ,43 ,"HOME" ) ) )
    AND (ph1.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (ph1.active_ind = 1 ) ) ) )
  ORDER BY patient_name ,o.order_id,
   ord_start ,
   ord_as_mn
  HEAD REPORT
   stat = alterlist (indx_reply->indx ,999 ) ,
   qual->qual_cnt = 0
  DETAIL
   IF (( $MEDS = 1 )
   AND (o.catalog_type_cd = pharmacy ) ) null
   ELSE qual->qual_cnt = (qual->qual_cnt + 1 ) ,
    IF ((mod (qual->qual_cnt ,1000 ) = 1 ) ) stat = alterlist (qual->qual ,(qual->qual_cnt + 999 ) )
    ENDIF
    ,
    IF ((qual->qual_cnt = 1 ) ) qual->qual[qual->qual_cnt ].name = "Patient_Name" ,qual->qual[qual->
     qual_cnt ].dob = "Date_of_Birth" ,qual->qual[qual->qual_cnt ].age = "Age" ,qual->qual[qual->
     qual_cnt ].gender = "Gender" ,qual->qual[qual->qual_cnt ].mrn = "MRN" ,qual->qual[qual->qual_cnt
      ].fin = "FIN" ,qual->qual[qual->qual_cnt ].home_phone = "Home_Phone" ,qual->qual[qual->qual_cnt
      ].home_address = "Home_Address" ,qual->qual[qual->qual_cnt ].ord_type = "Type" ,qual->qual[qual
     ->qual_cnt ].ord_name = "Order_Name" ,qual->qual[qual->qual_cnt ].orig_date = "Start" ,qual->
     qual[qual->qual_cnt ].ord_prov = "Ordering_Provider" ,qual->qual[qual->qual_cnt ].ord_by =
     "Ordered_By" ,qual->qual[qual->qual_cnt ].ord_det = "Order_Details" ,qual->qual[qual->qual_cnt ]
     .ord_status = "Status" ,qual->qual[qual->qual_cnt ].future_order_status = "Future_Order_Status"
    ,qual->qual[qual->qual_cnt ].grace = "Future_Date_Range" ,pname_max = cnvtint (textlen (trim (
        qual->qual[qual->qual_cnt ].name ) ) ) ,addr_max = cnvtint (textlen (trim (qual->qual[qual->
        qual_cnt ].home_address ) ) ) ,ordname_max = cnvtint (textlen (trim (qual->qual[qual->
        qual_cnt ].ord_name ) ) ) ,prname_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].
        ord_prov ) ) ) ,pr2name_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_by ) )
      ) ,orddet_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_det ) ) ) ,qual->
     qual_cnt = (qual->qual_cnt + 1 )
    ENDIF
    ,qual->qual[qual->qual_cnt ].name = notdocumented ,qual->qual[qual->qual_cnt ].dob =
    notdocumented ,qual->qual[qual->qual_cnt ].age = notdocumented ,qual->qual[qual->qual_cnt ].
    home_phone = notdocumented ,qual->qual[qual->qual_cnt ].home_address = notdocumented ,qual->qual[
    qual->qual_cnt ].ord_type = notdocumented ,qual->qual[qual->qual_cnt ].ord_name = notdocumented ,
    qual->qual[qual->qual_cnt ].orig_date = notdocumented ,qual->qual[qual->qual_cnt ].ord_prov =
    notdocumented ,qual->qual[qual->qual_cnt ].ord_by = notdocumented ,qual->qual[qual->qual_cnt ].
    ord_status = notdocumented ,qual->qual[qual->qual_cnt ].future_order_status = notdocumented ,qual
    ->qual[qual->qual_cnt ].grace = notdocumented ,qual->qual[qual->qual_cnt ].person_id = o
    .person_id ,qual->qual[qual->qual_cnt ].encntr_id = o.encntr_id ,qual->qual[qual->qual_cnt ].
    order_id = o.order_id ,qual->qual[qual->qual_cnt ].name = trim (p.name_full_formatted ) ,
    IF ((pname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].name ) ) ) ) ) pname_max =
     cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].name ) ) )
    ENDIF
    ,qual->qual[qual->qual_cnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/DD/YYYY" )
   ,qual->qual[qual->qual_cnt ].age = trim (substring (1 ,12 ,cnvtage (cnvtdate (p.birth_dt_tm ) ,
       curdate ) ) ,3 ) ,qual->qual[qual->qual_cnt ].gender = uar_get_code_display (p.sex_cd ) ,
    IF ((qual->qual[qual->qual_cnt ].gender = null ) ) qual->qual[qual->qual_cnt ].gender =
     notdocumented
    ENDIF
    ,qual->qual[qual->qual_cnt ].mrn = substring (1 ,16 ,cnvtalias (ea.alias ,ea.alias_pool_cd ) ) ,
    IF ((qual->qual[qual->qual_cnt ].mrn = null ) ) qual->qual[qual->qual_cnt ].mrn = notdocumented
    ENDIF
    ,qual->qual[qual->qual_cnt ].fin = substring (1 ,16 ,cnvtalias (ea1.alias ,ea1.alias_pool_cd ) )
   ,
    IF ((qual->qual[qual->qual_cnt ].fin = null ) ) qual->qual[qual->qual_cnt ].fin = notdocumented
    ENDIF
    ,
    IF ((ph.phone_type_cd = home_phone_cd ) )
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
       qual_cnt ].home_address ," " ,trim (a.city ) ,", " ,trim (uar_get_code_display (a.state_cd )
        ) ," " ,trim (a.zipcode ) )
     ELSE qual->qual[qual->qual_cnt ].home_address = concat (qual->qual[qual->qual_cnt ].home_address
        ," " ,trim (a.city ) ,", " ,trim (a.state ) ," " ,trim (a.zipcode ) )
     ENDIF
     ,
     IF ((addr_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].home_address ) ) ) ) )
      addr_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].home_address ) ) )
     ENDIF
    ENDIF
    ,qual->qual[qual->qual_cnt ].ord_type = trim (uar_get_code_display (o.activity_type_cd ) ) ,
    IF ((ordtype_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_type ) ) ) ) )
     ordtype_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_type ) ) )
    ENDIF
    ,qual->qual[qual->qual_cnt ].ord_name = trim (o.order_mnemonic ) ,
    IF ((ordname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_name ) ) ) ) )
     ordname_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_name ) ) )
    ENDIF
    ,qual->qual[qual->qual_cnt ].orig_date = format (o.current_start_dt_tm ,"MM/DD/YYYY;;d" ) ,qual->
    qual[qual->qual_cnt ].ord_prov = trim (pr1.name_full_formatted ) ,
    IF ((prname_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_prov ) ) ) ) )
     prname_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_prov ) ) )
    ENDIF
    ,qual->qual[qual->qual_cnt ].ord_by = trim (pr2.name_full_formatted ) ,
    IF ((pr2name_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_by ) ) ) ) )
     pr2name_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_by ) ) )
    ENDIF
    ,qual->qual[qual->qual_cnt ].ord_det = trim (o.order_detail_display_line ) ,
    IF ((orddet_max < cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_det ) ) ) ) )
     orddet_max = cnvtint (textlen (trim (qual->qual[qual->qual_cnt ].ord_det ) ) )
    ENDIF
    ,
    IF ((qual->qual[qual->qual_cnt ].ord_det = null ) ) qual->qual[qual->qual_cnt ].ord_det =
     notdocumented
    ENDIF
    ,qual->qual[qual->qual_cnt ].ord_status = trim (uar_get_code_display (o.order_status_cd ) )
   ENDIF
  FOOT REPORT
   stat = alterlist (qual->qual ,qual->qual_cnt ) ,
   IF ((logging = 1 ) )
    CALL echorecord (qual )
   ENDIF
  WITH expand = 1 ,nocounter
 ;end select
 IF ((logging = 1 ) )
  CALL echo (build ("Total Qualifying Medications: " ,qual->qual_cnt ) )
  CALL echo (build ("Max Person: " ,pname_max ) )
  CALL echo (build ("Max Prsnl: " ,prname_max ) )
  CALL echo (build ("Max Prsnl2: " ,pr2name_max ) )
  CALL echo (build ("Max Address: " ,addr_max ) )
  CALL echo (build ("Max Ord Type: " ,ordtype_max ) )
  CALL echo (build ("Max Ord Name: " ,ordname_max ) )
  CALL echo (build ("Max Order Details: " ,orddet_max ) )
 ENDIF
 DECLARE itr = i4 WITH protect
 DECLARE ctr = i4 WITH protect
 DECLARE ctr1 = i4 WITH protect
 DECLARE ctr2 = i4 WITH protect
 DECLARE ctr3 = i4 WITH protect
 DECLARE temp_dt_tm = dq8 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE num_of_days = i4 WITH protect
 DECLARE num_of_days_neg = i4 WITH protect
 SELECT distinct INTO "nl:"
  FROM (order_detail od )
  WHERE expand (itr ,1 ,qual->qual_cnt ,od.order_id ,qual->qual[itr ].order_id )
  AND (od.oe_field_meaning IN ("FORDGRACENBR" ,
  "REQSTARTDTTM" ,
  "FORDGRACEUNIT" ) )
  ORDER BY od.order_id ,
   od.oe_field_id
  HEAD REPORT
   ctr = 0 ,
   stat = alterlist (order_detail_info->list ,10 )
  HEAD od.order_id
   ctr = (ctr + 1 ) ,
   IF ((mod (ctr ,10 ) = 1 ) ) stat = alterlist (order_detail_info->list ,(ctr + 9 ) )
   ENDIF
   ,order_detail_info->list[ctr ].order_id = od.order_id
  HEAD od.oe_field_id
   IF ((od.oe_field_meaning = "REQSTARTDTTM" ) ) order_detail_info->list[ctr ].date = od
    .oe_field_dt_tm_value ,order_detail_info->list[ctr ].date_string = od.oe_field_display_value
   ENDIF
   ,
   IF ((od.oe_field_meaning = "FORDGRACENBR" ) ) order_detail_info->list[ctr ].num = cnvtint (od
     .oe_field_display_value )
   ENDIF
   ,
   IF ((od.oe_field_meaning = "FORDGRACEUNIT" ) ) order_detail_info->list[ctr ].unit = od
    .oe_field_display_value
   ENDIF
  FOOT REPORT
   stat = alterlist (order_detail_info->list ,ctr ) ,
   order_detail_info->cnt = ctr ,
   FOR (ctr1 = 1 TO order_detail_info->cnt )
    pos = locateval (itr ,1 ,qual->qual_cnt ,order_detail_info->list[ctr1 ].order_id ,qual->qual[itr
     ].order_id ) ,
    IF ((pos > 0 ) ) num_of_days = order_detail_info->list[ctr1 ].num ,num_of_days_neg = (- (1 ) *
     num_of_days ) ,
     IF ((qual->qual[pos ].ord_status = "Future" ) ) qual->qual[pos ].grace = build (format (
        datetimeadd (order_detail_info->list[ctr1 ].date ,num_of_days_neg ) ,";;D" ) ,"-" ,format (
        datetimeadd (order_detail_info->list[ctr1 ].date ,num_of_days ) ,";;D" ) )
     ELSE qual->qual[pos ].grace = notdocumented
     ENDIF
    ENDIF
   ENDFOR
  WITH expand = 1 ,nocounter
 ;end select
 SELECT distinct INTO "nl:"
  FROM (order_future_info ofi )
  WHERE expand (itr ,1 ,qual->qual_cnt ,ofi.order_id ,qual->qual[itr ].order_id )
  AND (ofi.order_future_info_id != 0 )
  ORDER BY ofi.order_id
  HEAD REPORT
   ctr2 = 0 ,
   stat = alterlist (future_order_info->list ,10 )
  HEAD ofi.order_id
   ctr2 = (ctr2 + 1 ) ,
   IF ((mod (ctr2 ,10 ) = 1 ) ) stat = alterlist (future_order_info->list ,(ctr2 + 9 ) )
   ENDIF
   ,future_order_info->list[ctr2 ].beg_dt_tm = ofi.begin_due_dt_tm ,future_order_info->list[ctr2 ].
   end_dt_tm = ofi.begin_due_dt_tm ,future_order_info->list[ctr2 ].order_id = ofi.order_id ,
   IF ((ofi.begin_due_dt_tm > cnvtdatetime (curdate ,235959 ) ) ) future_order_info->list[ctr2 ].
    status = "Upcoming"
   ELSEIF ((ofi.end_due_dt_tm < cnvtdatetime (curdate ,0 ) ) ) future_order_info->list[ctr2 ].status
    = "Overdue"
   ELSE future_order_info->list[ctr2 ].status = "Due"
   ENDIF
  FOOT REPORT
   stat = alterlist (future_order_info->list ,ctr2 ) ,
   future_order_info->cnt = ctr2 ,
   FOR (ctr3 = 1 TO future_order_info->cnt )
    pos = locateval (itr ,1 ,qual->qual_cnt ,future_order_info->list[ctr3 ].order_id ,qual->qual[itr
     ].order_id ) ,
    IF ((pos > 0 ) ) qual->qual[pos ].future_order_status = future_order_info->list[ctr3 ].status
    ENDIF
   ENDFOR
  WITH expand = 1 ,nocounter
 ;end select
 CALL echorecord (future_order_info )
 IF (( $EXCEL_PROMPT = 1 ) )
  SELECT distinct  INTO  $OUTDEV
   name = substring (1 ,value (pname_max ) ,qual->qual[d.seq ].name ) ,
   dob = substring (1 ,15 ,qual->qual[d.seq ].dob ) ,
   age = substring (1 ,8 ,qual->qual[d.seq ].age ) ,
   gender = substring (1 ,15 ,qual->qual[d.seq ].gender ) ,
   mrn = substring (1 ,15 ,qual->qual[d.seq ].mrn ) ,
   fin = substring (1 ,15 ,qual->qual[d.seq ].fin ) ,
   home_address = substring (1 ,value (addr_max ) ,qual->qual[d.seq ].home_address ) ,
   home_phone = substring (1 ,15 ,qual->qual[d.seq ].home_phone ) ,
   ord_type = substring (1 ,value (ordtype_max ) ,qual->qual[d.seq ].ord_type ) ,
   ord_name = substring (1 ,value (ordname_max ) ,qual->qual[d.seq ].ord_name ) ,
   orig_date = substring (1 ,20 ,qual->qual[d.seq ].orig_date ) ,
   ord_prov = substring (1 ,50 ,qual->qual[d.seq ].ord_prov ) ,
   ord_by = substring (1 ,50 ,qual->qual[d.seq ].ord_by ) ,
   ord_det = substring (1 ,255 ,qual->qual[d.seq ].ord_det ) ,
   status = substring (1 ,10 ,qual->qual[d.seq ].ord_status ) ,
   future_order_status = substring (1 ,25 ,qual->qual[d.seq ].future_order_status ) ,
   future_date = substring (1 ,25 ,qual->qual[d.seq ].grace )
   FROM (dummyt d WITH seq = value (qual->qual_cnt ) )
   PLAN (d
    WHERE (d.seq > 0 ) )
   WITH nocounter
  ;end select
  IF ((qual->qual_cnt > 0 ) )
   SET did_we_print = "Y"
  ENDIF
 ELSE
  SELECT distinct INTO  $OUTDEV
   person_id = qual->qual[d.seq ].person_id ,
   name = substring (1 ,40 ,qual->qual[d.seq ].name ) ,
   dob = substring (1 ,15 ,qual->qual[d.seq ].dob ) ,
   age = substring (1 ,12 ,qual->qual[d.seq ].age ) ,
   gender = substring (1 ,10 ,qual->qual[d.seq ].gender ) ,
   mrn = substring (1 ,10 ,qual->qual[d.seq ].mrn ) ,
   fin = substring (1 ,15 ,qual->qual[d.seq ].fin ) ,
   home_address = substring (1 ,100 ,qual->qual[d.seq ].home_address ) ,
   home_phone = substring (1 ,15 ,qual->qual[d.seq ].home_phone ) ,
   ord_type = substring (1 ,20 ,qual->qual[d.seq ].ord_type ) ,
   ord_name = substring (1 ,40 ,qual->qual[d.seq ].ord_name ) ,
   orig_date = substring (1 ,20 ,qual->qual[d.seq ].orig_date ) ,
   ord_prov = substring (1 ,25 ,qual->qual[d.seq ].ord_prov ) ,
   ord_by = substring (1 ,25 ,qual->qual[d.seq ].ord_by ) ,
   ord_det = substring (1 ,45 ,qual->qual[d.seq ].ord_det ) ,
   status = substring (1 ,12 ,qual->qual[d.seq ].ord_status ) ,
   future_order_status = substring (1 ,10 ,qual->qual[d.seq ].future_order_status ) ,
   future_date = substring (1 ,25 ,qual->qual[d.seq ].grace )
   FROM (dummyt d WITH seq = value (qual->qual_cnt ) )
   PLAN (d
    WHERE (d.seq > 1 ) )
   HEAD REPORT
    null
   HEAD PAGE
    row 1 ,
    col 1 ,
    report_name ,
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
    col 22 ,
    display_start ,
    row 2 ,
    col 33 ,
    "to" ,
    row 2 ,
    col 36 ,
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
    col 1 ,
    location_name ,
    row 3 ,
    col 100 ,
    "Page:" ,
    pge = trim (cnvtstring (curpage ) ,3 ) ,
    row 3 ,
    col 106 ,
    pge ,
    row + 1
   HEAD person_id
    row + 2 ,col 1 ,line ,row + 1 ,col 3 ,"Patient:" ,col 20 ,name ,col 60 ,"MRN:" ,col + 1 ,mrn ,
    col 100 ,"FIN:" ,col + 1 ,fin ,row + 1 ,col 20 ,"DOB:" ,col + 1 ,dob ,col 60 ,"Gender:" ,col + 1
    ,gender ,row + 1 ,col 20 ,"Address:" ,col + 1 ,home_address ,col 100 ,"Phone:" ,col + 1 ,
    home_phone ,row + 1 ,col 1 ,line
   DETAIL
    row + 1 ,
    col 8 ,
    "Order:" ,
    col + 1 ,
    ord_name ,
    col 70 ,
    "Order Details:" ,
    col + 1 ,
    ord_det ,
    row + 1 ,
    col 23 ,
    "Ordered:" ,
    col + 1 ,
    orig_date ,
    col 70 ,
    "Current Order Status:" ,
    col + 1 ,
    status ,
    row + 1 ,
    col 23 ,
    "Ordering Provider:" ,
    col + 1 ,
    ord_prov ,
    col 70 ,
    "Ordered By:" ,
    col + 1 ,
    ord_by ,
    row + 1 ,
    col 23 ,
    "Future Date Range:" ,
    col + 1 ,
    future_date ,
    col 70 ,
    "Future Order Status:" ,
    col + 1 ,
    future_order_status ,
    row + 1 ,
    did_we_print = "Y"
   FOOT REPORT
    row + 2 ,
    col 1 ,
    line ,
    row + 1 ,
    CALL center ("***** END OF REPORT *****" ,0 ,130 )
   WITH nocounter ,landscape ,maxrow = 45
  ;end select
  IF ((did_we_print = "N" ) )
   SELECT distinct  INTO  $OUTDEV
    FROM (dummyt d )
    PLAN (d )
    DETAIL
     row 1 ,
     col 1 ,
     report_name ,
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
     col 22 ,
     display_start ,
     row 2 ,
     col 33 ,
     "to" ,
     row 2 ,
     col 36 ,
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
     col 1 ,
     location_name ,
     row 3 ,
     col 100 ,
     "Page:" ,
     pge = trim (cnvtstring (curpage ) ,3 ) ,
     row 3 ,
     col 106 ,
     pge ,
     row + 1 ,
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
 ENDIF
 IF ((logging = 1 ) )
  SET query_stop_time = format (cnvtdatetime (curdate ,curtime3 ) ,"MM/DD/YYYY HH:MM:SS;;d" )
  CALL echo (build ("MAIN QUERY END TIME: " ,query_stop_time ) )
  SET query_elapsed_time = datetimediff (cnvtdatetime (curdate ,curtime3 ) ,query_start_time ,5 )
  CALL echo (build ("MAIN QUERY ELAPSED TIME (SECONDS): " ,query_elapsed_time ) )
 ENDIF
#end_program
 IF ((((indx_reply->status_flag = "F" )
 AND (indx_type != 0 ) ) OR ((indx_reply->loc_status_flag = "F" ) )) )
  SELECT distinct INTO  $OUTDEV
   FROM (dummyt d )
   PLAN (d )
   DETAIL
    row 1 ,
    col 1 ,
    report_name ,
    row 1 ,
    col 90 ,
    "Page:" ,
    pge = trim (cnvtstring (curpage ) ,3 ) ,
    row 1 ,
    col 96 ,
    pge ,
    row + 3 ,
    col 10 ,
    "NO PATIENTS AVAILABLE FOR SELECTED LOCATION" ,
    row + 2 ,
    CALL center ("***** END OF REPORT *****" ,0 ,130 )
   WITH nocounter ,dontcare = d
  ;end select
 ENDIF
#exit_program
END GO

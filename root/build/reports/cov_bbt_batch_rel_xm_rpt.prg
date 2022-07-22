DROP PROGRAM cov_bbt_batch_rel_xm_rpt:DBA go
CREATE PROGRAM cov_bbt_batch_rel_xm_rpt
 
prompt 
	"Output to File/Printer/MINE" = "MINE"              ;* Enter or select the printer or file name to send this report to.
	, "Select Mode" = ""
	, "Select Sort" = ""
	, "Select Facility Location" = 2552503613.00
	, "Select BB Owner Area Location" = 2554362747.00
	, "Select BB Inventory Area" = 2554362755.00
	, "Select Patient Encounter Status" = 0
	, "Select XM Exp Date/Time" = "SYSDATE" 

with OUTDEV, mode, sort, loc, own, inv, patencstatus, expdate
 
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
       3 pat_aborh	=	vc
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
   1 aborh  = vc
 )


FREE RECORD request
 record REQUEST (
  1 Output_Dist = c100
  1 Batch_Selection = c100
  1 Ops_Date = dq8
  1 address_location_cd = f8
  1 cur_owner_area_cd = f8
  1 cur_inv_area_cd = f8
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
 DECLARE mrn_meaning = c12 WITH protect ,constant ("MRN" )
 DECLARE xm_exp_meaning = c12 WITH protect ,constant ("EXPIRED" )
 DECLARE pat_exp_meaning = c12 WITH protect ,constant ("PAT_DECEASED" )
 DECLARE enc_discharg_meaning = c12 WITH protect ,constant ("SYS_DISCHRG" )
 DECLARE assign_meaning = c12 WITH protect ,constant ("1" )
 DECLARE quar_meaning = c12 WITH protect ,constant ("2" )
 DECLARE xm_meaning = c12 WITH protect ,constant ("3" )
 DECLARE dispense_meaning = c12 WITH protect ,constant ("4" )
 DECLARE available_meaning = c12 WITH protect ,constant ("12" )
 DECLARE uncfrm_meaning = c12 WITH protect ,constant ("9" )
 DECLARE inprog_meaning = c12 WITH protect ,constant ("16" )
 DECLARE auto_meaning = c12 WITH protect ,constant ("10" )
 DECLARE dir_meaning = c12 WITH protect ,constant ("11" )
 DECLARE ship_meaning = c12 WITH protect ,constant ("15" )
 DECLARE intransit_meaning = c12 WITH protect ,constant ("25" )
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
 
;CALL ECHORECORD(captions)
 
;go to exitscript


SET request->Output_Dist = "MINE"
SET request->Ops_Date = CNVTDATETIME(CURDATE, CURTIME3) 
SET sort_selection = fillstring (20 ," " )
SET sort_selection = VALUE($sort)
SET request->address_location_cd = $LOC
SET ops_param_status = $PATENCSTATUS
SET request->cur_owner_area_cd = $OWN
SET request->cur_inv_area_cd = $INV
SET mode_selection = $MODE
 

;CALL ECHORECORD(request)
;GO TO exitscript
 
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
   (crossmatch xm ),
   (person_aborh pa)
  PLAN (xm
   WHERE (xm.active_ind = 1 )
   AND (cnvtdatetime ($expdate ) >= xm.crossmatch_exp_dt_tm ) )
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
   JOIN (pa
   WHERE (pe.person_id = pa.person_id))
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
   IF ((valid_prod_ind = "T" ) ) count1 = (count1 + 1 ) ,count2 = 0 ,
   product_count = (product_count + 1 ) ,stat = alter (ops_request->productlist ,count1 ) ,
   ops_request->productlist[count1 ].product_type = "B" ,
   ops_request->productlist[count1 ].supp_prefix = b.supplier_prefix ,
   ops_request->productlist[count1 ].product_id = p.product_id ,
   ops_request->productlist[count1 ].p_updt_cnt = p.updt_cnt
   ENDIF
   call echo(valid_prod_ind)
  HEAD xm.product_event_id
   IF ((valid_prod_ind = "T" ) ) count2 = (count2 + 1 ) ,
   stat = alterlist (ops_request->productlist[count1].productevent ,count2 ) ,
   ops_request->productlist[count1 ].productevent[count2 ].product_event_id = pe.product_event_id ,
   ops_request->productlist[count1 ].productevent[count2 ].event_type_cd = pe.event_type_cd ,
   ops_request->productlist[count1 ].productevent[count2 ].pe_updt_cnt = pe.updt_cnt ,
   ops_request->productlist[count1 ].productevent[count2 ].order_id = pe.order_id ,
   ops_request->productlist[count1 ].productevent[count2 ].person_id = pe.person_id ,
   ops_request->productlist[count1 ].productevent[count2 ].release_reason_cd = xm_expired_reason_cd,
   ops_request->productlist[count1].productevent[count2].pat_aborh = BUILD2(TRIM(UAR_GET_CODE_DISPLAY(pa.abo_cd)),' ',
   TRIM(UAR_GET_CODE_DISPLAY(pa.rh_cd)))
   ENDIF
  WITH nocounter
;CALL ECHORECORD(ops_request)
;GO TO exitscript

;Get Address
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


 
;CALL ECHORECORD(ops_request)
;GO TO exitscript
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
 call echo(build('count1 :', count1))
SELECT INTO $outdev ;cpm_cfn_info->file_name_logical
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
   (dummyt d_ar WITH seq = value (count1) )
  PLAN (d_ar )
   JOIN (p
   WHERE (p.product_id = ops_request->productlist[d_ar.seq].product_id ) )
   JOIN (pe
   WHERE (p.product_id = pe.product_id )
   AND expand (pe_index ,1 ,size (ops_request->productlist[d_ar.seq ].productevent ,5 ) ,
   pe.product_event_id ,ops_request->productlist[d_ar.seq ].productevent[pe_index ].product_event_id
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
   line = fillstring (125 ,"_" )
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
   CALL CENTER ('PATIENT',127,135),
   row + 1 ,
   CALL center (captions->medical_number ,1 ,19 ) ,
   CALL center (captions->patient_name ,21 ,56 ) ,
   CALL center (captions->accession_number ,58 ,82 ) ,
   CALL center (captions->product ,84 ,96 ) ,
   CALL center (captions->reason ,98 ,111 ) ,
   CALL center (captions->xm_exp_date ,113 ,125 ) ,
   CALL CENTER (captions->aborh,127,135),
   row + 1 ,
   col 1 ,
   "-------------------" ,
   col 21 ,
   "------------------------------------" ,
   col 58 ,
   "-------------------------" ,
   col 84 ,
   "-------------" ,
   col 98 ,
   "--------------" ,
   col 113 ,
   "-------------" ,
   col 127,
   "---------",
   row + 2
  HEAD p.cur_owner_area_cd
   IF ((p.cur_owner_area_cd != cur_owner_area_cd_hd ) ) cur_owner_area_disp = 
   uar_get_code_display (p.cur_owner_area_cd ) ,cur_owner_area_cd_hd = p.cur_owner_area_cd
   ENDIF
  HEAD p.cur_inv_area_cd
   IF ((p.cur_inv_area_cd != cur_inv_area_cd_hd ) ) 
   cur_inv_area_disp = uar_get_code_display (p.cur_inv_area_cd ) ,cur_inv_area_cd_hd = p.cur_inv_area_cd ,
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
     sub_number = p.product_sub_nbr ,prod_num = 
     concat (trim (ops_request->productlist[d_ar.seq ].supp_prefix ) ,trim (number ,3 ) ," " ,trim (sub_number ,3 ) )
    ELSE prod_num = p.product_nbr
    ENDIF
    ,prod_disp = c_prod.display ,col 1 ,med_num ,col 21 ,pat_name
   ELSEIF ((count1 <= 1 ) ) row + 1 ,
    CALL center (captions->rpt_no_crossmatches ,1 ,125 )
   ENDIF
  HEAD pe.product_event_id
   IF ((row >= 58 ) )
    BREAK
   ENDIF
   ,reason = " " ,pos = locateval (index ,1 ,size (ops_request->productlist[d_ar.seq ].productevent ,
     5 ) ,pe.product_event_id ,ops_request->productlist[d_ar.seq ].productevent[index ].product_event_id ) ,
   IF ((pos > 0 ) )
    IF ((ops_request->productlist[d_ar.seq ].status = "S" )
    AND (cnvtupper (batch_field ) = "UPDATE" ) ) status = "Released" ,temp_string = " " ,
     IF ((pe.event_type_cd = xmtch_event_type_cd ) ) temp_string = "XM"
     ELSEIF ((pe.event_type_cd = assign_event_type_cd ) ) temp_string = "Assign"
     ELSEIF ((pe.event_type_cd = inprogress_event_type_cd ) ) temp_string = "Inprog"
     ENDIF
     ,status = concat (temp_string ," " ,status ) ,reason = 
     uar_get_code_display (ops_request->productlist[d_ar.seq ].productevent[pos ].release_reason_cd ) ,
     reason = substring (1 ,15 ,reason )
    ELSE status = "Not Released" ,
     IF ((ops_request->productlist[d_ar.seq ].err_message > " " ) ) 
     reason = ops_request->productlist[d_ar.seq ].err_message
     ENDIF
    ENDIF
    ,col 58 ,prod_num ,col 84 ,prod_disp ,col 97 ,status ,col 113 ,
    ops_request->productlist[d_ar.seq].productevent[pos ].xm_exp_dt_tm "@DATETIMECONDENSED;;d" ,
    COL 127 ops_request->productlist[d_ar.seq].productevent[pos].pat_aborh,
    row + 1 ,formatted_acc = cnvtacc (ord.accession ) ,col 58 ,formatted_acc ,col 97 ,reason ,
    
    row + 1
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
    d_ord ) ,maxrow = 63 ,compress ,nolandscape ,nullreport ,expand = 1, MAXCOL = 150
 
/******** Subroutines *******************/
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
 
#exitscript
 
 
 
 
END
GO
 

;001 - removed ordered status requirement
DROP PROGRAM pharmacy_tat_extract GO
CREATE PROGRAM pharmacy_tat_extract
 prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Enter Start Date" = "SYSDATE"
	, "Enter End Date" = ""
	, "Select Facility" = 0
 
with OUTDEV, vStart_dt, vEnd_dt, vFacility
 SET beg_dt_tm = cnvtdatetime ( $VSTART_DT )
 SET end_dt_tm = cnvtdatetime ( $VEND_DT )
 SET vversion = 0.8
 SET vversion_date = "MAR-12-2012"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring (12 ," " )
 SET vfin_nbr_cd = 0.0
 SET vpharm_cat_cd = 0.0
 SET vord_action_cd = 0.0
 SET vord_status_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET vfin_nbr_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET vpharm_cat_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET vord_action_cd = code_value
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET vord_status_cd = code_value
 SET cdcaction = uar_get_code_by ("MEANING" ,6003 ,"DISCONTINUE" )
 SET cordered = uar_get_code_by ("MEANING" ,6004 ,"ORDERED" )
 SELECT  INTO  $OUTDEV
  physician_name = trim (pmd.name_full_formatted ,3 ) ,
  orderable = trim (o.hna_order_mnemonic ,3 ) ,
  synonym = trim (o.ordered_as_mnemonic ,3 ) ,
  order_sentence = substring (1 ,100 ,check(o.clinical_display_line )) ,
  ordered_date = o.orig_order_dt_tm "mm/dd/yyyy" ,
  ordered_time = o.orig_order_dt_tm "hh:mm:ss" ,
  oa.action_dt_tm "@MEDIUMDATETIME" ,
  verified_date = ordrev.review_dt_tm "mm/dd/yyyy" ,
  verified_time = ordrev.review_dt_tm "hh:mm:ss" ,
  verifying_rph = trim (prx.name_full_formatted ,3 ) ,
  oa_action_type_disp = uar_get_code_display (oa.action_type_cd ) ,
  oa_order_status_disp = uar_get_code_display (oa.order_status_cd ) ,
  ordering_facility = trim (cv1.display ,3 ) ,
  ordering_location = trim (cv2.display ,3 ) ,
  tat_minutes = datetimediff (ordrev.review_dt_tm ,o.orig_order_dt_tm ,4 ) ,
  tat2_minutes = datetimediff (ordrev.review_dt_tm ,oa.action_dt_tm ,4 ) ,
  financial_number = trim (ea.alias ,3 ) ,
  order_id = o.order_id
  FROM (code_value cv1 ),
   (code_value cv2 ),
   (orders o ),
   (order_review ordrev ),
   (order_action oa ),
   (prsnl pmd ),
   (prsnl prx ),
   (encntr_loc_hist elh ),
   (encntr_alias ea ),
   (encounter e )
  PLAN (o
   WHERE ((o.catalog_type_cd + 0 ) = vpharm_cat_cd )
   AND (o.orig_order_dt_tm BETWEEN cnvtdatetime ( $VSTART_DT ) AND cnvtdatetime ( $VEND_DT ) ) )
   JOIN (e
   WHERE (e.encntr_id = o.encntr_id ) )
   JOIN (elh
   WHERE (elh.encntr_id = o.encntr_id )
   AND (elh.loc_facility_cd =  $VFACILITY )
   AND (elh.beg_effective_dt_tm <= o.orig_order_dt_tm )
   AND (elh.end_effective_dt_tm >= o.orig_order_dt_tm ) )
   JOIN (cv1
   WHERE (elh.loc_facility_cd = cv1.code_value ) )
   JOIN (cv2
   WHERE (elh.loc_nurse_unit_cd = cv2.code_value ) )
   JOIN (ea
   WHERE (o.encntr_id = ea.encntr_id )
   AND (ea.encntr_alias_type_cd = vfin_nbr_cd ) )
   JOIN (oa
   WHERE (o.order_id = oa.order_id )
   AND (oa.needs_verify_ind IN (3 ,
   4 ,
   5 ) )
   ;001 AND (oa.order_status_cd = cordered )
   ); 001
   JOIN (pmd
   WHERE (pmd.person_id = oa.order_provider_id ) )
   JOIN (ordrev
   WHERE (oa.order_id = ordrev.order_id )
   AND (oa.action_sequence = ordrev.action_sequence )
   AND (ordrev.review_type_flag = 3 )
   AND NOT ((ordrev.review_personnel_id IN (0 ,
   1 ) ) )
   AND ((ordrev.reviewed_status_flag + 0 ) != 4 ) )
   JOIN (prx
   WHERE (ordrev.review_personnel_id = prx.person_id )
   AND (prx.name_last_key != "SYSTEM" ) )
  WITH nocounter ,separator = " " ,format
 ;end select
END GO

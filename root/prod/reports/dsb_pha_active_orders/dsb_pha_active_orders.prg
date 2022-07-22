DROP PROGRAM dsb_pha_active_orders :dba GO
CREATE PROGRAM dsb_pha_active_orders :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Select your Facility:" = 0 ,
  "Display Active Orders Only?:" = 1 ,
  "Begin Date:" = "CURDATE" ,
  "End Date:" = "CURDATE" ,
  "Select your products: (Click column header to Sort)" = 0
  WITH outdev ,facility ,activeord ,begindt ,enddt ,itemid
 DECLARE cdfin = f8 WITH constant (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) ) ,protect
 DECLARE cdmrn = f8 WITH constant (uar_get_code_by ("MEANING" ,319 ,"MRN" ) ) ,protect
 DECLARE cdcensus = f8 WITH constant (uar_get_code_by ("MEANING" ,339 ,"CENSUS" ) ) ,protect
 DECLARE cdpyxisid = f8 WITH constant (uar_get_code_by ("MEANING" ,11000 ,"PYXIS" ) ) ,protect
 DECLARE cdcdm = f8 WITH constant (uar_get_code_by ("MEANING" ,11000 ,"CDM" ) ) ,protect
 DECLARE cddesc = f8 WITH constant (uar_get_code_by ("MEANING" ,11000 ,"DESC" ) ) ,protect
 DECLARE cdinpatient = f8 WITH constant (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT" ) ) ,protect
 DECLARE cdsoftstop = f8 WITH constant (uar_get_code_by ("MEANING" ,4009 ,"SOFT" ) ) ,protect
 DECLARE cdhardstop = f8 WITH constant (uar_get_code_by ("MEANING" ,4009 ,"HARD" ) ) ,protect
 DECLARE cdphysstop = f8 WITH constant (uar_get_code_by ("MEANING" ,4009 ,"DRSTOP" ) ) ,protect
 DECLARE cdordered = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"ORDERED" ) ) ,protect
 DECLARE cdsuspended = f8 WITH constant (uar_get_code_by ("MEANING" ,6004 ,"SUSPENDED" ) ) ,protect
 DECLARE cdfacility = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"FACILITY" ) ) ,protect
 DECLARE cdauth = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE cord_comment = f8 WITH constant (uar_get_code_by ("MEANING" ,14 ,"ORD COMMENT" ) ) ,protect
 DECLARE cdpharmact = f8 WITH constant (uar_get_code_by ("MEANING" ,106 ,"PHARMACY" ) ) ,protect
 DECLARE prdcnt = i4 WITH protect
 DECLARE ordcnt = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE idx2 = i4 WITH protect
 DECLARE faccnt = i4 WITH protect
 DECLARE facidx = i4 WITH protect
 DECLARE mypos = i4 WITH protect
 DECLARE stat = i2 WITH protect
 DECLARE all_fac_ind = i2 WITH protect
 FREE RECORD fac_req
 RECORD fac_req (
   1 facilities [* ]
     2 facility_cd = f8
 )
 FREE RECORD results
 RECORD results (
   1 products [* ]
     2 item_id = f8
     2 desc = vc
     2 pyxis_id = vc
     2 cdm = vc
     2 orders [* ]
       3 order_id = f8
       3 order_status = vc
       3 facility_cd = f8
       3 facility_disp = vc
       3 nurse_unit = vc
       3 room_bed = vc
       3 fin = vc
       3 discharge_dt_tm = dq8
       3 patient_name = vc
       3 display_line = vc
       3 ordered_dt_tm = dq8
       3 start_dt_tm = dq8
       3 stop_dt_tm = dq8
       3 stop_type = vc
       3 stop_dt_tm_disp = vc
       3 powerplan = vc
       3 order_phys_name = vc
       3 order_phys_pos_disp = vc
       3 entered_by_name = vc
       3 entered_by_pos_disp = vc
       3 order_comments = vc
 )
 SET all_fac_ind = evaluate (parameter (parameter2 ( $FACILITY ) ,1 ) ,0 ,1 ,0 )
 SELECT INTO "nl:"
  l.location_cd ,
  facility = uar_get_code_display (l.location_cd )
  FROM (prsnl_org_reltn por ),
   (location l )
  PLAN (por
   WHERE (por.person_id = reqinfo->updt_id )
   AND (por.active_ind = 1 )
   AND (por.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime ) )
   AND (por.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime ) ) )
   JOIN (l
   WHERE (l.organization_id = por.organization_id )
   AND (l.location_type_cd = cdfacility )
   AND (l.active_ind = 1 )
   AND (l.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime ) )
   AND (l.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime ) )
   AND (l.data_status_cd = cdauth )
   AND (((l.location_cd =  $FACILITY ) ) OR ((all_fac_ind = 1 ) )) )
  HEAD REPORT
   faccnt = 0
  DETAIL
   faccnt = (faccnt + 1 ) ,
   IF ((faccnt > size (fac_req->facilities ,5 ) ) ) stat = alterlist (fac_req->facilities ,(faccnt +
     50 ) )
   ENDIF
   ,fac_req->facilities[faccnt ].facility_cd = l.location_cd
  FOOT REPORT
   stat = alterlist (fac_req->facilities ,faccnt )
  WITH nocounter
 ;end select
 CALL echorecord (fac_req )
 SELECT INTO "nl:"
  FROM (med_identifier mi1 ),
   (med_identifier mi2 ),
   (med_identifier mi3 )
  PLAN (mi1
   WHERE (mi1.item_id =  $ITEMID )
   AND (mi1.med_identifier_type_cd = cddesc )
   AND (mi1.med_product_id = 0 )
   AND (mi1.primary_ind = 1 )
   AND (mi1.active_ind = 1 )
   AND (mi1.pharmacy_type_cd = cdinpatient ) )
   JOIN (mi2
   WHERE (mi2.item_id = outerjoin (mi1.item_id ) )
   AND (mi2.med_identifier_type_cd = outerjoin (cdpyxisid ) )
   AND (mi2.med_product_id = outerjoin (0 ) )
   AND (mi2.primary_ind = outerjoin (1 ) )
   AND (mi2.active_ind = outerjoin (1 ) )
   AND (mi2.pharmacy_type_cd = outerjoin (cdinpatient ) ) )
   JOIN (mi3
   WHERE (mi3.item_id = outerjoin (mi1.item_id ) )
   AND (mi3.med_identifier_type_cd = outerjoin (cdcdm ) )
   AND (mi3.med_product_id = outerjoin (0 ) )
   AND (mi3.primary_ind = outerjoin (1 ) )
   AND (mi3.active_ind = outerjoin (1 ) )
   AND (mi3.pharmacy_type_cd = outerjoin (cdinpatient ) ) )
  ORDER BY mi1.item_id
  HEAD REPORT
   prdcnt = 0
  DETAIL
   prdcnt = (prdcnt + 1 ) ,
   IF ((prdcnt > size (results->products ,5 ) ) ) stat = alterlist (results->products ,(prdcnt + 20
     ) )
   ENDIF
   ,results->products[prdcnt ].item_id = mi1.item_id ,
   results->products[prdcnt ].desc = trim (mi1.value ) ,
   results->products[prdcnt ].pyxis_id = trim (mi2.value ) ,
   results->products[prdcnt ].cdm = trim (mi3.value )
  FOOT REPORT
   stat = alterlist (results->products ,prdcnt )
  WITH nocounter
 ;end select
 IF (( $ACTIVEORD = 1 ) )
  SELECT INTO "nl: "
   FROM (encntr_domain ed ),
    (order_dispense od ),
    (order_product op ),
    (orders o ),
    (encntr_alias ea1 ),
    (encounter e ),
    (person p ),
    (prsnl pr1 ),
    (order_action oa ),
    (prsnl pr2 ),
    (act_pw_comp apc ),
    (pathway pw ),
    (order_comment oc ),
    (long_text lt )
   PLAN (ed
    WHERE (ed.end_effective_dt_tm BETWEEN cnvtdatetime ((curdate - 1 ) ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) )
    AND expand (facidx ,1 ,size (fac_req->facilities ,5 ) ,ed.loc_facility_cd ,fac_req->facilities[
     facidx ].facility_cd )
    AND (ed.loc_building_cd != 0 )
    AND (ed.loc_nurse_unit_cd != 0 )
    AND (ed.encntr_domain_type_cd = cdcensus )
    AND (ed.active_ind = 1 ) )
    JOIN (od
    WHERE (od.encntr_id = ed.encntr_id )
    AND (od.person_id = ed.person_id )
    AND (od.profile_display_dt_tm BETWEEN cnvtdatetime (curdate ,curtime3 ) AND cnvtdatetime (
     "31-DEC-2100" ) ) )
    JOIN (op
    WHERE (op.order_id = od.order_id )
    AND (op.action_sequence = od.last_ver_ingr_seq )
    AND expand (idx ,1 ,prdcnt ,op.item_id ,results->products[idx ].item_id ) )
    JOIN (o
    WHERE (op.order_id = o.order_id )
    AND (o.order_status_cd IN (cdordered ,
    cdsuspended ) ) )
    JOIN (ea1
    WHERE (ea1.encntr_id = o.encntr_id )
    AND (ea1.encntr_alias_type_cd = cdfin )
    AND (ea1.active_ind = 1 )
    AND (ea1.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id ) )
    JOIN (p
    WHERE (p.person_id = o.person_id )
    AND (p.active_ind = 1 )
    AND (p.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (pr1
    WHERE (pr1.person_id = o.last_update_provider_id ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence = 1 ) )
    JOIN (oc
    WHERE (oc.action_sequence = outerjoin (oa.action_sequence ) )
    AND (oc.order_id = outerjoin (oa.order_id ) )
    AND (oc.comment_type_cd = outerjoin (cord_comment ) ) )
    JOIN (lt
    WHERE (lt.long_text_id = outerjoin (oc.long_text_id ) ) )
    JOIN (pr2
    WHERE (pr2.person_id = oa.action_personnel_id ) )
    JOIN (apc
    WHERE (apc.parent_entity_id = outerjoin (o.order_id ) )
    AND (apc.parent_entity_name = outerjoin ("ORDERS" ) ) )
    JOIN (pw
    WHERE (pw.pathway_id = outerjoin (apc.pathway_id ) ) )
   ORDER BY op.item_id
   HEAD op.item_id
    ordcnt = 0 ,mypos = locatevalsort (idx2 ,1 ,prdcnt ,op.item_id ,results->products[idx2 ].item_id
     )
   DETAIL
    ordcnt = (ordcnt + 1 ) ,
    IF ((ordcnt > size (results->products[mypos ].orders ,5 ) ) ) stat = alterlist (results->
      products[mypos ].orders ,(ordcnt + 50 ) )
    ENDIF
    ,results->products[mypos ].orders[ordcnt ].facility_cd = e.loc_facility_cd ,
    results->products[mypos ].orders[ordcnt ].facility_disp = uar_get_code_display (e
     .loc_facility_cd ) ,
    results->products[mypos ].orders[ordcnt ].nurse_unit = trim (uar_get_code_display (e
      .loc_nurse_unit_cd ) ) ,
    results->products[mypos ].orders[ordcnt ].room_bed = evaluate (e.loc_room_cd ,0.0 ,"" ,build (
      uar_get_code_display (e.loc_room_cd ) ,"-" ,uar_get_code_display (e.loc_bed_cd ) ) ) ,
    results->products[mypos ].orders[ordcnt ].fin = trim (ea1.alias ) ,
    results->products[mypos ].orders[ordcnt ].discharge_dt_tm = e.disch_dt_tm ,
    results->products[mypos ].orders[ordcnt ].patient_name = trim (p.name_full_formatted ) ,
    results->products[mypos ].orders[ordcnt ].order_id = od.order_id ,
    results->products[mypos ].orders[ordcnt ].display_line = check (o.dept_misc_line ,char (32 ) ) ,
    results->products[mypos ].orders[ordcnt ].order_status = uar_get_code_display (o.order_status_cd
     ) ,
    results->products[mypos ].orders[ordcnt ].ordered_dt_tm = o.orig_order_dt_tm ,
    results->products[mypos ].orders[ordcnt ].start_dt_tm = o.current_start_dt_tm ,
    results->products[mypos ].orders[ordcnt ].stop_dt_tm = o.projected_stop_dt_tm ,
    results->products[mypos ].orders[ordcnt ].stop_type = uar_get_code_display (o.stop_type_cd ) ,
    results->products[mypos ].orders[ordcnt ].stop_dt_tm_disp = concat (format (o
      .projected_stop_dt_tm ,"mm/dd/yyyy HH:MM;;Q" ) ,evaluate (o.stop_type_cd ,cdsoftstop ," (s)" ,
      cdhardstop ," (h)" ,cdphysstop ," (p)" ,"" ) ) ,
    results->products[mypos ].orders[ordcnt ].order_phys_name = trim (pr1.name_full_formatted ) ,
    results->products[mypos ].orders[ordcnt ].order_phys_pos_disp = trim (uar_get_code_display (pr1
      .position_cd ) ) ,
    results->products[mypos ].orders[ordcnt ].entered_by_name = trim (pr2.name_full_formatted ) ,
    results->products[mypos ].orders[ordcnt ].entered_by_pos_disp = trim (uar_get_code_display (pr2
      .position_cd ) ) ,
    results->products[mypos ].orders[ordcnt ].powerplan = trim (pw.pw_group_desc ) ,
    results->products[mypos ].orders[ordcnt ].order_comments = lt.long_text
   FOOT  op.item_id
    stat = alterlist (results->products[mypos ].orders ,ordcnt )
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl: "
   FROM (orders o ),
    (encounter e ),
    (order_dispense od ),
    (order_product op ),
    (encntr_loc_hist elh ),
    (encntr_alias ea1 ),
    (person p ),
    (prsnl pr1 ),
    (order_action oa ),
    (prsnl pr2 ),
    (act_pw_comp apc ),
    (pathway pw ),
    (order_comment oc ),
    (long_text lt )
   PLAN (o
    WHERE (o.orig_order_dt_tm BETWEEN cnvtdatetime (concat ( $BEGINDT ," 00:00:00" ) ) AND
    cnvtdatetime (concat ( $ENDDT ," 23:59:59" ) ) )
    AND (o.product_id = 0 )
    AND (o.order_status_cd != 0 )
    AND (o.activity_type_cd = cdpharmact )
    AND (o.orig_ord_as_flag = 0 )
    AND (o.template_order_flag IN (0 ,
    1 ) ) )
    JOIN (e
    WHERE (e.encntr_id = o.encntr_id )
    AND expand (facidx ,1 ,size (fac_req->facilities ,5 ) ,e.loc_facility_cd ,fac_req->facilities[
     facidx ].facility_cd ) )
    JOIN (od
    WHERE (od.order_id = o.order_id ) )
    JOIN (op
    WHERE (op.order_id = od.order_id )
    AND (op.action_sequence = od.last_ver_ingr_seq )
    AND expand (idx ,1 ,prdcnt ,op.item_id ,results->products[idx ].item_id ) )
    JOIN (elh
    WHERE (elh.encntr_id = o.encntr_id )
    AND (elh.active_ind = 1 )
    AND (elh.encntr_loc_hist_id =
    (SELECT
     max (elh2.encntr_loc_hist_id )
     FROM (encntr_loc_hist elh2 )
     WHERE (elh2.encntr_id = elh.encntr_id )
     AND (elh2.active_ind = 1 )
     AND (elh2.beg_effective_dt_tm <= o.orig_order_dt_tm ) ) ) )
    JOIN (ea1
    WHERE (ea1.encntr_id = o.encntr_id )
    AND (ea1.encntr_alias_type_cd = cdfin )
    AND (ea1.active_ind = 1 )
    AND (ea1.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (p
    WHERE (p.person_id = o.person_id )
    AND (p.active_ind = 1 )
    AND (p.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (pr1
    WHERE (pr1.person_id = o.last_update_provider_id ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id )
    AND (oa.action_sequence = 1 ) )
    JOIN (oc
    WHERE (oc.action_sequence = outerjoin (oa.action_sequence ) )
    AND (oc.order_id = outerjoin (oa.order_id ) )
    AND (oc.comment_type_cd = outerjoin (cord_comment ) ) )
    JOIN (lt
    WHERE (lt.long_text_id = outerjoin (oc.long_text_id ) ) )
    JOIN (pr2
    WHERE (pr2.person_id = oa.action_personnel_id ) )
    JOIN (apc
    WHERE (apc.parent_entity_id = outerjoin (o.order_id ) )
    AND (apc.parent_entity_name = outerjoin ("ORDERS" ) ) )
    JOIN (pw
    WHERE (pw.pathway_id = outerjoin (apc.pathway_id ) ) )
   ORDER BY op.item_id
   HEAD op.item_id
    ordcnt = 0 ,mypos = locatevalsort (idx2 ,1 ,prdcnt ,op.item_id ,results->products[idx2 ].item_id
     )
   DETAIL
    ordcnt = (ordcnt + 1 ) ,
    IF ((ordcnt > size (results->products[mypos ].orders ,5 ) ) ) stat = alterlist (results->
      products[mypos ].orders ,(ordcnt + 50 ) )
    ENDIF
    ,results->products[mypos ].orders[ordcnt ].facility_cd = elh.loc_facility_cd ,
    results->products[mypos ].orders[ordcnt ].facility_disp = uar_get_code_display (elh
     .loc_facility_cd ) ,
    results->products[mypos ].orders[ordcnt ].nurse_unit = trim (uar_get_code_display (elh
      .loc_nurse_unit_cd ) ) ,
    results->products[mypos ].orders[ordcnt ].room_bed = evaluate (elh.loc_room_cd ,0.0 ,"" ,build (
      uar_get_code_display (elh.loc_room_cd ) ,"-" ,uar_get_code_display (elh.loc_bed_cd ) ) ) ,
    results->products[mypos ].orders[ordcnt ].fin = trim (ea1.alias ) ,
    results->products[mypos ].orders[ordcnt ].discharge_dt_tm = e.disch_dt_tm ,
    results->products[mypos ].orders[ordcnt ].patient_name = trim (p.name_full_formatted ) ,
    results->products[mypos ].orders[ordcnt ].order_id = od.order_id ,
    results->products[mypos ].orders[ordcnt ].display_line = check (o.dept_misc_line ,char (32 ) ) ,
    results->products[mypos ].orders[ordcnt ].order_status = uar_get_code_display (o.order_status_cd
     ) ,
    results->products[mypos ].orders[ordcnt ].ordered_dt_tm = o.orig_order_dt_tm ,
    results->products[mypos ].orders[ordcnt ].start_dt_tm = o.current_start_dt_tm ,
    results->products[mypos ].orders[ordcnt ].stop_dt_tm = o.projected_stop_dt_tm ,
    results->products[mypos ].orders[ordcnt ].stop_type = uar_get_code_display (o.stop_type_cd ) ,
    results->products[mypos ].orders[ordcnt ].stop_dt_tm_disp = concat (format (o
      .projected_stop_dt_tm ,"mm/dd/yyyy HH:MM;;Q" ) ,evaluate (o.stop_type_cd ,cdsoftstop ," (s)" ,
      cdhardstop ," (h)" ,cdphysstop ," (p)" ,"" ) ) ,
    results->products[mypos ].orders[ordcnt ].order_phys_name = trim (pr1.name_full_formatted ) ,
    results->products[mypos ].orders[ordcnt ].order_phys_pos_disp = trim (uar_get_code_display (pr1
      .position_cd ) ) ,
    results->products[mypos ].orders[ordcnt ].entered_by_name = trim (pr2.name_full_formatted ) ,
    results->products[mypos ].orders[ordcnt ].entered_by_pos_disp = trim (uar_get_code_display (pr2
      .position_cd ) ) ,
    results->products[mypos ].orders[ordcnt ].powerplan = trim (pw.pw_group_desc ) ,
    results->products[mypos ].orders[ordcnt ].order_comments = lt.long_text
   FOOT  op.item_id
    stat = alterlist (results->products[mypos ].orders ,ordcnt )
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord (results )
 SELECT INTO  $OUTDEV
  med_id = substring (1 ,20 ,results->products[d1.seq ].pyxis_id ) ,
  product_description = substring (1 ,200 ,results->products[d1.seq ].desc ) ,
  facility = substring (1 ,50 ,results->products[d1.seq ].orders[d2.seq ].facility_disp ) ,
  location = substring (1 ,40 ,results->products[d1.seq ].orders[d2.seq ].nurse_unit ) ,
  room_bed = substring (1 ,80 ,results->products[d1.seq ].orders[d2.seq ].room_bed ) ,
  fin = substring (1 ,200 ,results->products[d1.seq ].orders[d2.seq ].fin ) ,
  patient_name = substring (1 ,100 ,results->products[d1.seq ].orders[d2.seq ].patient_name ) ,
  display_line = substring (1 ,255 ,results->products[d1.seq ].orders[d2.seq ].display_line ) ,
  start_dt_tm = format (results->products[d1.seq ].orders[d2.seq ].start_dt_tm ,
   "mm/dd/yyyy HH:MM;;Q" ) ,
  stop_dt_tm = substring (1 ,25 ,results->products[d1.seq ].orders[d2.seq ].stop_dt_tm_disp ) ,
  powerplan = substring (1 ,100 ,results->products[d1.seq ].orders[d2.seq ].powerplan ) ,
  ordering_physician = substring (1 ,100 ,results->products[d1.seq ].orders[d2.seq ].order_phys_name
   ) ,
  ordering_phys_position = substring (1 ,50 ,results->products[d1.seq ].orders[d2.seq ].
   order_phys_pos_disp ) ,
  entered_by = substring (1 ,100 ,results->products[d1.seq ].orders[d2.seq ].entered_by_name ) ,
  entered_by_position = substring (1 ,50 ,results->products[d1.seq ].orders[d2.seq ].
   entered_by_pos_disp ) ,
  ordered_dt_tm = format (results->products[d1.seq ].orders[d2.seq ].ordered_dt_tm ,
   "mm/dd/yyyy HH:MM;;Q" ) ,
  order_status = substring (1 ,40 ,results->products[d1.seq ].orders[d2.seq ].order_status ) ,
  discharge_dt_tm = format (results->products[d1.seq ].orders[d2.seq ].discharge_dt_tm ,
   "mm/dd/yyyy HH:MM;;Q" ) ,
  order_comment = trim (replace (replace (substring (1 ,200 ,results->products[d1.seq ].orders[d2
      .seq ].order_comments ) ,char (13 ) ,"   " ) ,char (10 ) ,"   " ) ) ,
  order_id = results->products[d1.seq ].orders[d2.seq ].order_id
  FROM (dummyt d1 WITH seq = prdcnt ),
   (dummyt d2 WITH seq = 1 )
  PLAN (d1
   WHERE maxrec (d2 ,size (results->products[d1.seq ].orders ,5 ) ) )
   JOIN (d2 )
  ORDER BY product_description ,
   facility ,
   location ,
   fin ,
   order_id
  WITH format ,separator = " " ,outerjoin = d1
 ;end select
#exit_script
 SET last_mod = "006"
END GO

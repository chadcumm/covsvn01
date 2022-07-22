DROP PROGRAM pha_ord_verify_tat GO
CREATE PROGRAM pha_ord_verify_tat
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Report For Unit Type" = "1" ,
  "Facility:" = 0 ,
  "Order Entered Begin Dt/Tm:" = "SYSDATE" ,
  "Order Entered End Dt/Tm:" = "SYSDATE" ,
  "Report Type:" = 0 ,
  "Is Valid:" = 0 ,
  "Is Valid2:" = ""
  WITH outdev ,reportoption ,p_facility ,beg_dt_tm ,end_dt_tm ,p_report_type ,is_valid ,is_valid2
 RECORD temp (
   1 cnt = i4
   1 qual [* ]
     2 order_id = f8
     2 order_action_seq = i4
     2 action_type = vc
     2 phd_name = vc
     2 phd_person_id = f8
     2 order_action_dt_tm = dq8
     2 order_review_dt_tm = dq8
     2 hour = i4
     2 tat = f8
     2 needs_verify = i4
     2 first_touch_dt_tm = dq8
     2 first_touch_tat = f8
     2 review_comp_dt_tm = dq8
     2 review_comp_tat = f8
 )
 RECORD tat (
   1 facility = vc
   1 report_type = i4
   1 beg_dt_tm = vc
   1 end_dt_tm = vc
   1 rpttot_cnt = i4
   1 rpttot_touch_tot_tm = f8
   1 rpttot_touch_avg_tm = i4
   1 rpttot_tot_tm = f8
   1 rpttot_avg_tm = i4
   1 hr_qual [24 ]
     2 cnt = i4
     2 touch_tot_tm = f8
     2 touch_avg_tm = i4
     2 tot_tm = f8
     2 avg_tm = i4
   1 phd_cnt = i4
   1 phd_qual [* ]
     2 phd_name = vc
     2 phdtot_cnt = i4
     2 phdtot_touch_tot_tm = f8
     2 phdtot_touch_avg_tm = i4
     2 phdtot_tot_tm = f8
     2 phdtot_avg_tm = i4
     2 hr_qual [24 ]
       3 cnt = i4
       3 touch_tot_tm = f8
       3 touch_avg_tm = i4
       3 tot_tm = f8
       3 avg_tm = i4
 )
 DECLARE statuschange_cv = f8 WITH public ,constant (uar_get_code_by ("DISPLAYKEY" ,6003 ,
   "STATUSCHANGE" ) )
 DECLARE transfercancel_cv = f8 WITH public ,constant (uar_get_code_by ("DISPLAYKEY" ,6003 ,
   "TRANSFERCANCEL" ) )
 SET beg_dt_tm = cnvtdatetime ( $BEG_DT_TM )
 SET end_dt_tm = cnvtdatetime ( $END_DT_TM )
 SET tat->report_type =  $P_REPORT_TYPE
 SET tat->beg_dt_tm = format (beg_dt_tm ,"mm/dd/yyyy hh:mm;;d" )
 SET tat->end_dt_tm = format (end_dt_tm ,"mm/dd/yyyy hh:mm;;d" )
 SET cordered = uar_get_code_by ("MEANING" ,6004 ,"ORDERED" )
 SELECT INTO "nl:"
  FROM (code_value cv )
  WHERE (cv.code_value =  $P_FACILITY )
  DETAIL
   tat->facility = build2 (tat->facility ,", " ,trim (cv.description ) )
  FOOT REPORT
   tat->facility = substring (3 ,textlen (tat->facility ) ,tat->facility )
  WITH nocounter
 ;end select
 SET date1 = cnvtdatetime ( $BEG_DT_TM )
 SET date2 = cnvtdatetime (cnvtdate (date1 ) ,235959 )
 IF ((date2 > cnvtdatetime ( $END_DT_TM ) ) )
  SET date2 = cnvtdatetime ( $END_DT_TM )
 ENDIF
 IF (( $REPORTOPTION = "1" ) )
  WHILE ((date1 <= cnvtdatetime ( $END_DT_TM ) ) )
   CALL echo (format (date1 ,"mm/dd/yyyy hh:mm;;d" ) )
   CALL echo (format (date2 ,"mm/dd/yyyy hh:mm;;d" ) )
   SELECT
    oa.action_dt_tm "mm/dd/yyyy hh:mm;;d" ,
    hr = hour (oa.action_dt_tm ) ,
    orev.review_dt_tm "mm/dd/yyyy hh:mm;;d" ,
    oa.order_id ,
    oa.action_sequence ,
    rev_date = orev.review_dt_tm "yyyymmdd_hhmmss;;d"
    FROM (order_action oa ),
     (order_review orev ),
     (orders o ),
     (encounter e ),
     (encntr_loc_hist elh )
    PLAN (oa
     WHERE (oa.needs_verify_ind IN (3 ,
     4 ,
     5 ) )
     AND (oa.order_status_cd = cordered ) )
     JOIN (orev
     WHERE (orev.order_id = oa.order_id )
     AND (orev.action_sequence = oa.action_sequence )
     AND (orev.review_type_flag = 3 )
     AND ((orev.reviewed_status_flag + 0 ) != 4 )
     AND NOT ((orev.review_personnel_id IN (0 ,
     1 ) ) ) )
     JOIN (o
     WHERE (o.order_id = oa.order_id )
     AND (o.orig_order_dt_tm >= cnvtdatetime (date1 ) )
     AND (o.orig_order_dt_tm <= cnvtdatetime (date2 ) ) )
     JOIN (e
     WHERE (e.encntr_id = o.encntr_id ) )
     JOIN (elh
     WHERE (elh.encntr_id = o.encntr_id )
     AND (elh.beg_effective_dt_tm <= o.orig_order_dt_tm )
     AND (elh.end_effective_dt_tm >= o.orig_order_dt_tm )
     AND (elh.loc_facility_cd =  $P_FACILITY ) )
    ORDER BY oa.order_id ,
     oa.action_sequence ,
     orev.review_sequence
    HEAD REPORT
     cnt = temp->cnt
    HEAD oa.order_id
     row + 0
    HEAD oa.action_sequence
     cnt = (cnt + 1 ) ,stat = alterlist (temp->qual ,cnt ) ,temp->qual[cnt ].order_id = oa.order_id ,
     temp->qual[cnt ].order_action_seq = oa.action_sequence ,temp->qual[cnt ].action_type =
     uar_get_code_display (oa.action_type_cd ) ,temp->qual[cnt ].order_action_dt_tm = oa
     .action_dt_tm ,temp->qual[cnt ].hour = (cnvtint (hour (oa.action_dt_tm ) ) + 1 ) ,temp->qual[
     cnt ].needs_verify = oa.needs_verify_ind
    HEAD orev.review_sequence
     IF ((temp->qual[cnt ].first_touch_dt_tm = null ) ) temp->qual[cnt ].first_touch_dt_tm = orev
      .review_dt_tm ,temp->qual[cnt ].phd_person_id = orev.review_personnel_id
     ENDIF
     ,
     IF ((orev.reviewed_status_flag IN (1 ,
     5 ) ) ) temp->qual[cnt ].review_comp_dt_tm = orev.review_dt_tm
     ENDIF
    FOOT REPORT
     temp->cnt = cnt
    WITH nocounter
   ;end select
   SET date1 = cnvtlookahead ("1,D" ,date1 )
   SET date2 = cnvtlookahead ("1,D" ,date2 )
   IF ((date2 > cnvtdatetime ( $END_DT_TM ) ) )
    SET date2 = cnvtdatetime ( $END_DT_TM )
   ENDIF
   IF ((date1 >= cnvtdatetime ( $END_DT_TM ) ) )
    CALL echo ("endwhile" )
   ENDIF
  ENDWHILE
 ELSEIF (( $REPORTOPTION = "2" ) )
  WHILE ((date1 <= cnvtdatetime ( $END_DT_TM ) ) )
   CALL echo (format (date1 ,"mm/dd/yyyy hh:mm;;d" ) )
   CALL echo (format (date2 ,"mm/dd/yyyy hh:mm;;d" ) )
   SELECT
    oa.action_dt_tm "mm/dd/yyyy hh:mm;;d" ,
    hr = hour (oa.action_dt_tm ) ,
    orev.review_dt_tm "mm/dd/yyyy hh:mm;;d" ,
    oa.order_id ,
    oa.action_sequence ,
    rev_date = orev.review_dt_tm "yyyymmdd_hhmmss;;d"
    FROM (order_action oa ),
     (order_review orev ),
     (orders o ),
     (encounter e ),
     (encntr_loc_hist elh )
    PLAN (oa
     WHERE (oa.needs_verify_ind IN (3 ,
     4 ,
     5 ) )
     AND (oa.order_status_cd = cordered ) )
     JOIN (orev
     WHERE (orev.order_id = oa.order_id )
     AND (orev.action_sequence = oa.action_sequence )
     AND (orev.review_type_flag = 3 )
     AND ((orev.reviewed_status_flag + 0 ) != 4 )
     AND NOT ((orev.review_personnel_id IN (0 ,
     1 ) ) ) )
     JOIN (o
     WHERE (o.order_id = oa.order_id )
     AND (o.orig_order_dt_tm >= cnvtdatetime (date1 ) )
     AND (o.orig_order_dt_tm <= cnvtdatetime (date2 ) ) )
     JOIN (e
     WHERE (e.encntr_id = o.encntr_id ) )
     JOIN (elh
     WHERE (elh.encntr_id = o.encntr_id )
     AND (elh.loc_facility_cd =  $P_FACILITY )
     AND (elh.beg_effective_dt_tm <= o.orig_order_dt_tm )
     AND (elh.end_effective_dt_tm >= o.orig_order_dt_tm )
     AND (elh.loc_nurse_unit_cd =
     (SELECT
      cv.code_value
      FROM (code_value cv )
      WHERE (cv.code_set = 220 )
      AND (cv.code_value = elh.loc_nurse_unit_cd )
      AND (cv.display = "*ED" ) ) ) )
    ORDER BY oa.order_id ,
     oa.action_sequence ,
     orev.review_sequence
    HEAD REPORT
     cnt = temp->cnt
    HEAD oa.order_id
     row + 0
    HEAD oa.action_sequence
     cnt = (cnt + 1 ) ,stat = alterlist (temp->qual ,cnt ) ,temp->qual[cnt ].order_id = oa.order_id ,
     temp->qual[cnt ].order_action_seq = oa.action_sequence ,temp->qual[cnt ].action_type =
     uar_get_code_display (oa.action_type_cd ) ,temp->qual[cnt ].order_action_dt_tm = oa
     .action_dt_tm ,temp->qual[cnt ].hour = (cnvtint (hour (oa.action_dt_tm ) ) + 1 ) ,temp->qual[
     cnt ].needs_verify = oa.needs_verify_ind
    HEAD orev.review_sequence
     IF ((temp->qual[cnt ].first_touch_dt_tm = null ) ) temp->qual[cnt ].first_touch_dt_tm = orev
      .review_dt_tm ,temp->qual[cnt ].phd_person_id = orev.review_personnel_id
     ENDIF
     ,
     IF ((orev.reviewed_status_flag IN (1 ,
     5 ) ) ) temp->qual[cnt ].review_comp_dt_tm = orev.review_dt_tm
     ENDIF
    FOOT REPORT
     temp->cnt = cnt
    WITH nocounter
   ;end select
   SET date1 = cnvtlookahead ("1,D" ,date1 )
   SET date2 = cnvtlookahead ("1,D" ,date2 )
   IF ((date2 > cnvtdatetime ( $END_DT_TM ) ) )
    SET date2 = cnvtdatetime ( $END_DT_TM )
   ENDIF
   IF ((date1 >= cnvtdatetime ( $END_DT_TM ) ) )
    CALL echo ("endwhile" )
   ENDIF
  ENDWHILE
 ENDIF
 DECLARE phd_name = vc
 IF ((temp->cnt > 0 ) )
  SELECT INTO "nl:"
   phd_name = p.name_full_formatted ,
   phd_person_id = temp->qual[d.seq ].phd_person_id
   FROM (dummyt d WITH seq = temp->cnt ),
    (prsnl p )
   PLAN (d )
    JOIN (p
    WHERE (p.person_id = temp->qual[d.seq ].phd_person_id ) )
   ORDER BY phd_name ,
    phd_person_id
   HEAD REPORT
    phd_cnt = 0
   HEAD phd_name
    row + 1
   HEAD phd_person_id
    phd_cnt = (phd_cnt + 1 ) ,stat = alterlist (tat->phd_qual ,phd_cnt ) ,tat->phd_qual[phd_cnt ].
    phd_name = p.name_full_formatted
   DETAIL
    temp->qual[d.seq ].review_comp_tat = datetimediff (temp->qual[d.seq ].review_comp_dt_tm ,temp->
     qual[d.seq ].order_action_dt_tm ,4 ) ,
    temp->qual[d.seq ].first_touch_tat = datetimediff (temp->qual[d.seq ].first_touch_dt_tm ,temp->
     qual[d.seq ].order_action_dt_tm ,4 ) ,
    tat->phd_qual[phd_cnt ].hr_qual[temp->qual[d.seq ].hour ].cnt = (tat->phd_qual[phd_cnt ].hr_qual[
    temp->qual[d.seq ].hour ].cnt + 1 ) ,
    tat->phd_qual[phd_cnt ].hr_qual[temp->qual[d.seq ].hour ].touch_tot_tm = (tat->phd_qual[phd_cnt ]
    .hr_qual[temp->qual[d.seq ].hour ].touch_tot_tm + temp->qual[d.seq ].first_touch_tat ) ,
    tat->phd_qual[phd_cnt ].hr_qual[temp->qual[d.seq ].hour ].tot_tm = (tat->phd_qual[phd_cnt ].
    hr_qual[temp->qual[d.seq ].hour ].tot_tm + temp->qual[d.seq ].review_comp_tat )
   FOOT REPORT
    tat->phd_cnt = phd_cnt
   WITH nocounter
  ;end select
 ENDIF
 FOR (phd_cnt = 1 TO tat->phd_cnt )
  FOR (hr_cnt = 1 TO 24 )
   SET tat->phd_qual[phd_cnt ].phdtot_cnt = (tat->phd_qual[phd_cnt ].phdtot_cnt + tat->phd_qual[
   phd_cnt ].hr_qual[hr_cnt ].cnt )
   SET tat->phd_qual[phd_cnt ].phdtot_touch_tot_tm = (tat->phd_qual[phd_cnt ].phdtot_touch_tot_tm +
   tat->phd_qual[phd_cnt ].hr_qual[hr_cnt ].touch_tot_tm )
   SET tat->phd_qual[phd_cnt ].phdtot_tot_tm = (tat->phd_qual[phd_cnt ].phdtot_tot_tm + tat->
   phd_qual[phd_cnt ].hr_qual[hr_cnt ].tot_tm )
   SET tat->hr_qual[hr_cnt ].cnt = (tat->hr_qual[hr_cnt ].cnt + tat->phd_qual[phd_cnt ].hr_qual[
   hr_cnt ].cnt )
   SET tat->hr_qual[hr_cnt ].touch_tot_tm = (tat->hr_qual[hr_cnt ].touch_tot_tm + tat->phd_qual[
   phd_cnt ].hr_qual[hr_cnt ].touch_tot_tm )
   SET tat->hr_qual[hr_cnt ].tot_tm = (tat->hr_qual[hr_cnt ].tot_tm + tat->phd_qual[phd_cnt ].
   hr_qual[hr_cnt ].tot_tm )
   IF ((tat->phd_qual[phd_cnt ].hr_qual[hr_cnt ].cnt > 0 ) )
    SET tat->phd_qual[phd_cnt ].hr_qual[hr_cnt ].touch_avg_tm = round ((tat->phd_qual[phd_cnt ].
     hr_qual[hr_cnt ].touch_tot_tm / tat->phd_qual[phd_cnt ].hr_qual[hr_cnt ].cnt ) ,0 )
    SET tat->phd_qual[phd_cnt ].hr_qual[hr_cnt ].avg_tm = round ((tat->phd_qual[phd_cnt ].hr_qual[
     hr_cnt ].tot_tm / tat->phd_qual[phd_cnt ].hr_qual[hr_cnt ].cnt ) ,0 )
   ENDIF
  ENDFOR
  IF ((tat->phd_qual[phd_cnt ].phdtot_cnt > 0 ) )
   SET tat->phd_qual[phd_cnt ].phdtot_touch_avg_tm = round ((tat->phd_qual[phd_cnt ].
    phdtot_touch_tot_tm / tat->phd_qual[phd_cnt ].phdtot_cnt ) ,0 )
   SET tat->phd_qual[phd_cnt ].phdtot_avg_tm = round ((tat->phd_qual[phd_cnt ].phdtot_tot_tm / tat->
    phd_qual[phd_cnt ].phdtot_cnt ) ,0 )
  ENDIF
 ENDFOR
 FOR (hr_cnt = 1 TO 24 )
  SET tat->rpttot_cnt = (tat->rpttot_cnt + tat->hr_qual[hr_cnt ].cnt )
  SET tat->rpttot_touch_tot_tm = (tat->rpttot_touch_tot_tm + tat->hr_qual[hr_cnt ].touch_tot_tm )
  SET tat->rpttot_tot_tm = (tat->rpttot_tot_tm + tat->hr_qual[hr_cnt ].tot_tm )
  IF ((tat->hr_qual[hr_cnt ].cnt > 0 ) )
   SET tat->hr_qual[hr_cnt ].touch_avg_tm = round ((tat->hr_qual[hr_cnt ].touch_tot_tm / tat->
    hr_qual[hr_cnt ].cnt ) ,0 )
   SET tat->hr_qual[hr_cnt ].avg_tm = round ((tat->hr_qual[hr_cnt ].tot_tm / tat->hr_qual[hr_cnt ].
    cnt ) ,0 )
  ENDIF
 ENDFOR
 IF ((tat->rpttot_cnt > 0 ) )
  SET tat->rpttot_touch_avg_tm = round ((tat->rpttot_touch_tot_tm / tat->rpttot_cnt ) ,0 )
  SET tat->rpttot_avg_tm = round ((tat->rpttot_tot_tm / tat->rpttot_cnt ) ,0 )
 ENDIF
#exit_script
 CALL echorecord (tat )
 IF (( $P_REPORT_TYPE < 2 ) )
  EXECUTE uhs_pha_ord_verify_tat_lo  $OUTDEV
 ELSE
  SELECT INTO  $OUTDEV
   domain = curdomain ,
   facility = tat->facility ,
   beg_dt_tm = tat->beg_dt_tm ,
   end_dt_tm = tat->end_dt_tm ,
   phd_name = substring (1 ,50 ,tat->phd_qual[d.seq ].phd_name ) ,
   0000_0059_cnt = format (tat->phd_qual[d.seq ].hr_qual[1 ].cnt ,"#####" ) ,
   0000_0059_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[1 ].touch_avg_tm ,"#####.##" ) ,
   0000_0059_total_avg = format (tat->phd_qual[d.seq ].hr_qual[1 ].avg_tm ,"#####.##" ) ,
   0100_0159_cnt = format (tat->phd_qual[d.seq ].hr_qual[2 ].cnt ,"#####" ) ,
   0100_0159_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[2 ].touch_avg_tm ,"#####.##" ) ,
   0100_0159_total_avg = format (tat->phd_qual[d.seq ].hr_qual[2 ].avg_tm ,"#####.##" ) ,
   0200_0259_cnt = format (tat->phd_qual[d.seq ].hr_qual[3 ].cnt ,"#####" ) ,
   0200_0259_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[3 ].touch_avg_tm ,"#####.##" ) ,
   0200_0259_total_avg = format (tat->phd_qual[d.seq ].hr_qual[3 ].avg_tm ,"#####.##" ) ,
   0300_0359_cnt = format (tat->phd_qual[d.seq ].hr_qual[4 ].cnt ,"#####" ) ,
   0300_0359_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[4 ].touch_avg_tm ,"#####.##" ) ,
   0300_0359_total_avg = format (tat->phd_qual[d.seq ].hr_qual[4 ].avg_tm ,"#####.##" ) ,
   0400_0459_cnt = format (tat->phd_qual[d.seq ].hr_qual[5 ].cnt ,"#####" ) ,
   0400_0459_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[5 ].touch_avg_tm ,"#####.##" ) ,
   0400_0459_total_avg = format (tat->phd_qual[d.seq ].hr_qual[5 ].avg_tm ,"#####.##" ) ,
   0500_0559_cnt = format (tat->phd_qual[d.seq ].hr_qual[6 ].cnt ,"#####" ) ,
   0500_0559_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[6 ].touch_avg_tm ,"#####.##" ) ,
   0500_0559_total_avg = format (tat->phd_qual[d.seq ].hr_qual[6 ].avg_tm ,"#####.##" ) ,
   0600_0659_cnt = format (tat->phd_qual[d.seq ].hr_qual[7 ].cnt ,"#####" ) ,
   0600_0659_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[7 ].touch_avg_tm ,"#####.##" ) ,
   0600_0659_total_avg = format (tat->phd_qual[d.seq ].hr_qual[7 ].avg_tm ,"#####.##" ) ,
   0700_0759_cnt = format (tat->phd_qual[d.seq ].hr_qual[8 ].cnt ,"#####" ) ,
   0700_0759_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[8 ].touch_avg_tm ,"#####.##" ) ,
   0700_0759_total_avg = format (tat->phd_qual[d.seq ].hr_qual[8 ].avg_tm ,"#####.##" ) ,
   0800_0859_cnt = format (tat->phd_qual[d.seq ].hr_qual[9 ].cnt ,"#####" ) ,
   0800_0859_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[9 ].touch_avg_tm ,"#####.##" ) ,
   0800_0859_total_avg = format (tat->phd_qual[d.seq ].hr_qual[9 ].avg_tm ,"#####.##" ) ,
   0900_0959_cnt = format (tat->phd_qual[d.seq ].hr_qual[10 ].cnt ,"#####" ) ,
   0900_0959_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[10 ].touch_avg_tm ,"#####.##" ) ,
   0900_0959_total_avg = format (tat->phd_qual[d.seq ].hr_qual[10 ].avg_tm ,"#####.##" ) ,
   1000_1059_cnt = format (tat->phd_qual[d.seq ].hr_qual[11 ].cnt ,"#####" ) ,
   1000_1059_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[11 ].touch_avg_tm ,"#####.##" ) ,
   1000_1059_total_avg = format (tat->phd_qual[d.seq ].hr_qual[11 ].avg_tm ,"#####.##" ) ,
   1100_1159_cnt = format (tat->phd_qual[d.seq ].hr_qual[12 ].cnt ,"#####" ) ,
   1100_1159_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[12 ].touch_avg_tm ,"#####.##" ) ,
   1100_1159_total_avg = format (tat->phd_qual[d.seq ].hr_qual[12 ].avg_tm ,"#####.##" ) ,
   1200_1259_cnt = format (tat->phd_qual[d.seq ].hr_qual[13 ].cnt ,"#####" ) ,
   1200_1259_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[13 ].touch_avg_tm ,"#####.##" ) ,
   1200_1259_total_avg = format (tat->phd_qual[d.seq ].hr_qual[13 ].avg_tm ,"#####.##" ) ,
   1300_1359_cnt = format (tat->phd_qual[d.seq ].hr_qual[14 ].cnt ,"#####" ) ,
   1300_1359_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[14 ].touch_avg_tm ,"#####.##" ) ,
   1300_1359_total_avg = format (tat->phd_qual[d.seq ].hr_qual[14 ].avg_tm ,"#####.##" ) ,
   1400_1459_cnt = format (tat->phd_qual[d.seq ].hr_qual[15 ].cnt ,"#####" ) ,
   1400_1459_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[15 ].touch_avg_tm ,"#####.##" ) ,
   1400_1459_total_avg = format (tat->phd_qual[d.seq ].hr_qual[15 ].avg_tm ,"#####.##" ) ,
   1500_1559_cnt = format (tat->phd_qual[d.seq ].hr_qual[16 ].cnt ,"#####" ) ,
   1500_1559_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[16 ].touch_avg_tm ,"#####.##" ) ,
   1500_1559_total_avg = format (tat->phd_qual[d.seq ].hr_qual[16 ].avg_tm ,"#####.##" ) ,
   1600_1659_cnt = format (tat->phd_qual[d.seq ].hr_qual[17 ].cnt ,"#####" ) ,
   1600_1659_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[17 ].touch_avg_tm ,"#####.##" ) ,
   1600_1659_total_avg = format (tat->phd_qual[d.seq ].hr_qual[17 ].avg_tm ,"#####.##" ) ,
   1700_1759_cnt = format (tat->phd_qual[d.seq ].hr_qual[18 ].cnt ,"#####" ) ,
   1700_1759_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[18 ].touch_avg_tm ,"#####.##" ) ,
   1700_1759_total_avg = format (tat->phd_qual[d.seq ].hr_qual[18 ].avg_tm ,"#####.##" ) ,
   1800_1859_cnt = format (tat->phd_qual[d.seq ].hr_qual[19 ].cnt ,"#####" ) ,
   1800_1859_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[19 ].touch_avg_tm ,"#####.##" ) ,
   1800_1859_total_avg = format (tat->phd_qual[d.seq ].hr_qual[19 ].avg_tm ,"#####.##" ) ,
   1900_1959_cnt = format (tat->phd_qual[d.seq ].hr_qual[20 ].cnt ,"#####" ) ,
   1900_1959_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[20 ].touch_avg_tm ,"#####.##" ) ,
   1900_1959_total_avg = format (tat->phd_qual[d.seq ].hr_qual[20 ].avg_tm ,"#####.##" ) ,
   2000_2059_cnt = format (tat->phd_qual[d.seq ].hr_qual[21 ].cnt ,"#####" ) ,
   2000_2059_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[21 ].touch_avg_tm ,"#####.##" ) ,
   2000_2059_total_avg = format (tat->phd_qual[d.seq ].hr_qual[21 ].avg_tm ,"#####.##" ) ,
   2100_2159_cnt = format (tat->phd_qual[d.seq ].hr_qual[22 ].cnt ,"#####" ) ,
   2100_2159_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[22 ].touch_avg_tm ,"#####.##" ) ,
   2100_2159_total_avg = format (tat->phd_qual[d.seq ].hr_qual[22 ].avg_tm ,"#####.##" ) ,
   2200_2259_cnt = format (tat->phd_qual[d.seq ].hr_qual[23 ].cnt ,"#####" ) ,
   2200_2259_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[23 ].touch_avg_tm ,"#####.##" ) ,
   2200_2259_total_avg = format (tat->phd_qual[d.seq ].hr_qual[23 ].avg_tm ,"#####.##" ) ,
   2300_2359_cnt = format (tat->phd_qual[d.seq ].hr_qual[24 ].cnt ,"#####" ) ,
   2300_2359_touch_avg = format (tat->phd_qual[d.seq ].hr_qual[24 ].touch_avg_tm ,"#####.##" ) ,
   2300_2359_total_avg = format (tat->phd_qual[d.seq ].hr_qual[24 ].avg_tm ,"#####.##" ) ,
   phd_tot_cnt = format (tat->phd_qual[d.seq ].phdtot_cnt ,"#####" ) ,
   phd_tot_touch_avg = format (tat->phd_qual[d.seq ].phdtot_touch_avg_tm ,"#####.##" ) ,
   phd_tot_total_avg = format (tat->phd_qual[d.seq ].phdtot_avg_tm ,"#####.##" )
   FROM (dummyt d WITH seq = tat->phd_cnt )
   WITH format ,separator = " "
  ;end select
 ENDIF
 CALL echorecord (temp )
;#end
END GO

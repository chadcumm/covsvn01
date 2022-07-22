DROP PROGRAM lh_nqf2019_report :dba GO
CREATE PROGRAM lh_nqf2019_report :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Reporting Time Frame" = "YEAR" ,
  "Year" = "" ,
  "Start Date" = "CURDATE" ,
  "End Date" = "CURDATE" ,
  "Report Printing Options" = "SUM_PS" ,
  "Quality Measure" = "" ,
  "Organization" = - (1 ) ,
  "Filter EP List" = "ALL" ,
  "Eligible Clinician" = 0 ,
  "Filter Measures" = "-1" ,
  "Quarter Start Date" = "" ,
  "Report By" = "INDV"
  WITH outdev ,optinitiative ,year ,start_dt ,end_dt ,chksummaryonly ,lstmeasure ,orgfilter ,
  epfilter ,lsteligibleprovider ,brdefmeas ,dt_quarter_year ,reportby ,tier2 ,tier1
 DECLARE getmeasureresults ((measure = vc ) ) = null
 DECLARE determine_ep_summary_mrn (null ) = null
 DECLARE summaryreport ((measure = vc ) ) = null
 DECLARE sortreport_sum (null ) = null
 DECLARE sortreport_det (null ) = null
 DECLARE addreport (null ) = null
 DECLARE getmeasurename ((reportmean = vc ) ) = vc
 DECLARE getpwx_info (null ) = null
 DECLARE setorgidparser (null ) = null
 DECLARE setldparser ((params = vc (ref ) ) ) = null
 DECLARE addsubmeasures (null ) = null
 DECLARE copysubmeasures (null ) = null
 DECLARE insertsubmeasures ((primarymeasure = vc ) ,(totalsubmeasures = i4 ) ,(pos = i4 ) ) = null
 DECLARE removedummyitem ((rec_name = vc (ref ) ) ,(ind_type = vc (value ,"exclude_ind" ) ) ) = null
 DECLARE removedummyitemexcludeonly ((rec_name = vc (ref ) ) ,(ind_type = vc (value ,"exclude_ind" )
  ) ) = null
 DECLARE get_measure_list ((rec = vc (ref ) ) ) = null
 DECLARE calcoutcomesortkey ((outcome = i2 ) ) = i2
 DECLARE getepsemptyrpt (null ) = null
 DECLARE setfluseason (null ) = null
 DECLARE get_all_grp_list ((rec = vc (ref ) ) ) = null
 DECLARE determineepsfromprompt ((paramtypein = vc ) ,(epfilter = vc ) ,(orgfilter = i4 ) ,(rec = vc
  (ref ) ) ) = i2
 DECLARE determinemeasuresfromprompt ((paramtypein = vc ) ,(rec = vc (ref ) ) ) = i2
 DECLARE sync_prompt_ep_measures ((rec = vc (ref ) ) ) = null
 DECLARE sync_prompt_grp_measures ((rec = vc (ref ) ) ) = null
 DECLARE build_measure_string ((levelstring = vc ) ,(pos = i4 ) ,(rec = vc (ref ) ) ) = vc
 DECLARE populate_measures_from_string ((in_string = vc ) ,(levelstring = vc ) ,(pos = i4 ) ,(rec =
  vc (ref ) ) ) = null
 DECLARE getreportmean ((report_mean = vc ) ) = vc
 DECLARE stripdotafter ((orig_str = vc ) ) = vc
 DECLARE get_rpt_dt_range_prompt ((opt_initiative = vc ) ,(year = vc ) ,(qtr_year = vc ) ,(start_dt
  = dq8 ) ,(end_dt = dq8 ) ) = null
 DECLARE month_check ((prior_date = dq8 ) ,(later_date = dq8 ) ,(no_of_months = i2 ) ,(within_range
  = i2 ) ) = i2
 DECLARE check_npi_tin ((ep_report = vc (ref ) ) ) = null
 DECLARE calvalidhic ((hic_nbr = vc ) ) = i2
 DECLARE retrieve_group_eps (null ) = null
 DECLARE pull_ep_sum_into_grp_sum (null ) = null
 DECLARE move_grp_sum_to_ep_sum (null ) = null
 DECLARE determine_grps_from_prompt ((paramtypein = vc ) ,(rec = vc (ref ) ) ) = i2
 DECLARE sort_lh_ep_reply (null ) = null
 DECLARE restrict_ep_sum_to_brdefmeas ((sum_rec = vc (ref ) ) ,(search_rec = vc (ref ) ) ,(
  report_by_type = vc (value ,"INDV" ) ) ) = null
 DECLARE base_getqrdabrepmeas_list ((rec = vc (ref ) ) ) = i2
 DECLARE base_getqrdabrgrpmeas_list ((rec = vc (ref ) ) ) = i2
 DECLARE run_report_main (null ) = null
 DECLARE getgrant_script ((myobject_name = vc ) ) = null
 DECLARE delete_submeasure ((submeasure = vc ) ) = null
 DECLARE sum_submeasures ((add1 = vc ) ,(add2 = vc ) ,(total = vc ) ) = null
 DECLARE pull_ep_sum_into_grp_sum_forgpro (null ) = null
 DECLARE getproviderids (null ) = null
 DECLARE getprovidergroups (null ) = null
 DECLARE updatenqf28outcomes ((measure_mean = vc ) ) = null
 DECLARE updatenqf22outcomes (null ) = null
 DECLARE lhperformance ((measure_desc = vc ) ,(status_flag = i2 ) ,(elapsed_time = f8 ) ,(
  population_cnt = i4 ) ) = null
 DECLARE mrn_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,4 ,"MRN" ) ) ,public
 DECLARE fin_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) ) ,public
 DECLARE debug_clause = vc WITH noconstant ("1=1" )
 DECLARE debug_ind = i2 WITH noconstant (0 ) ,public
 DECLARE obj_name = vc WITH noconstant ("" )
 DECLARE obj_version = vc WITH noconstant ("" )
 DECLARE obj_grant_var = vc WITH noconstant ("" )
 IF ((validate (lh_mu_ep_report_debug_21000101 ) = 1 ) )
  DECLARE dpos = i4 WITH noconstant (0 ) ,privateprotect
  DECLARE dpos2 = i4 WITH noconstant (0 ) ,privateprotect
  DECLARE dsize = i4 WITH constant (size (lh_mu_ep_report_debug_21000101 ,1 ) ) ,privateprotect
  DECLARE splitbyte = c1 WITH constant ("," ) ,privateprotect
  SET debug_ind = 1
  CALL echo (build ("DEBUG MODE ENABLED" ) )
  DECLARE debug_brepid = f8 WITH noconstant (0 ) ,public
  DECLARE debug_measure = vc WITH noconstant ("" ) ,public
  DECLARE debug_pid = f8 WITH noconstant (0 ) ,public
  SET dpos = findstring (splitbyte ,lh_mu_ep_report_debug_21000101 )
  SET dpos2 = findstring (splitbyte ,lh_mu_ep_report_debug_21000101 ,(dpos + 1 ) )
  SET debug_brepid = cnvtreal (substring (1 ,(dpos - 1 ) ,lh_mu_ep_report_debug_21000101 ) )
  SET debug_measure = substring ((dpos + 1 ) ,((dpos2 - dpos ) - 1 ) ,lh_mu_ep_report_debug_21000101
   )
  SET debug_pid = cnvtreal (substring ((dpos2 + 1 ) ,(dsize - dpos2 ) ,
    lh_mu_ep_report_debug_21000101 ) )
  CALL echo (build (":ep:" ,debug_brepid ,":m:" ,debug_measure ,":pid:" ,debug_pid ) )
 ENDIF
 SUBROUTINE  getmeasureresults (measure )
  DECLARE location_filter = vc WITH noconstant ("" ) ,protect
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  SET location_filter = build2 ("NOT expand(num, 1, size(lh_excl_loc->qual, 5), " ,
   "POP.loc_nurse_unit_cd, lh_excl_loc->qual[num].loc_nurse_unit_cd)" )
  CALL getlocfilter (0 )
  IF ((pwx_ind != 1 ) )
   SET org_id_parser = "1=1"
  ENDIF
  CASE (cnvtupper (measure ) )
   OF "MU_EC_0004_2019.1.1" :
    CALL getresults_nqf4 (0 )
   OF "MU_EC_0018_2019" :
    CALL getresults_nqf18 (0 )
   OF "MU_EC_0022_2019.1" :
    CALL getresults_nqf22 (0 )
   OF "MU_EC_0024_2019.1.1" :
    CALL getresults_nqf24 (0 )
   OF "MU_EC_0028_2019.1" :
    CALL getresults_nqf28 (0 )
   OF "MU_EC_0032_2019" :
    CALL getresults_nqf32 (0 )
   OF "MU_EC_0033_2019.1" :
    CALL getresults_nqf33 (0 )
   OF "MU_EC_0034_2019" :
    CALL getresults_nqf34 (0 )
   OF "MU_EC_0038_2019" :
    CALL getresults_nqf38 (0 )
   OF "MU_EC_0041_2019" :
    CALL getresults_nqf41 (0 )
   OF "MU_EC_0055_2019" :
    CALL getresults_nqf55 (0 )
   OF "MU_EC_0059_2019" :
    CALL getresults_nqf59 (0 )
   OF "MU_EC_0062_2019" :
    CALL getresults_nqf62 (0 )
   OF "MU_EC_0069_2019" :
    CALL getresults_nqf69 (0 )
   OF "MU_EC_0070_2019.1" :
    CALL getresults_nqf70 (0 )
   OF "MU_EC_0081_2019.1" :
    CALL getresults_nqf81 (0 )
   OF "MU_EC_0083_2019.1" :
    CALL getresults_nqf83 (0 )
   OF "MU_EC_0101_2019" :
    CALL getresults_nqf101 (0 )
   OF "MU_EC_0104_2019" :
    CALL getresults_nqf104 (0 )
   OF "MU_EC_0384_2019.1" :
    CALL getresults_nqf384 (0 )
   OF "MU_EC_0418_2019" :
    CALL getresults_nqf418 (0 )
   OF "MU_EC_0419_2019" :
    CALL getresults_nqf419 (0 )
   OF "MU_EC_0421_2019" :
    CALL getresults_nqf421 (0 )
   OF "MU_EC_0710_2019.1" :
    CALL getresults_nqf710 (0 )
   OF "MU_EC_0712_2019.1.1" :
    CALL getresults_nqf712 (0 )
   OF "MU_EC_1365_2019" :
    CALL getresults_nqf1365 (0 )
   OF "MU_EC_2372_2019" :
    CALL getresults_nqf2372 (0 )
   OF "MU_EC_2872_2019" :
    CALL getresults_nqf2872 (0 )
   OF "MU_EC_CMS22_2019" :
    CALL getresults_cms22 (0 )
   OF "MU_EC_CMS50_2019" :
    CALL getresults_cms50 (0 )
   OF "MU_EC_CMS74_2019.1" :
    CALL getresults_cms74 (0 )
   OF "MU_EC_CMS75_2019" :
    CALL getresults_cms75 (0 )
   OF "MU_EC_CMS82_2019" :
    CALL getresults_cms82 (0 )
   OF "MU_EC_CMS90_2019" :
    CALL getresults_cms90 (0 )
   OF "MU_EC_CMS127_2019" :
    CALL getresults_cms127 (0 )
   OF "MU_EC_CMS146_2019" :
    CALL getresults_cms146 (0 )
  ENDCASE
  SET stat = initrec (lh_excl_loc )
  SET stat = initrec (lh_ep_reply_bk )
 END ;Subroutine
 SUBROUTINE  determine_ep_summary_mrn (null )
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = ep_summary->ep_cnt ),
    (dummyt d1 WITH seq = 1 ),
    (person_alias pa )
   PLAN (d
    WHERE (ep_summary->ep_cnt > 0 )
    AND maxrec (d1 ,size (ep_summary->eps[d.seq ].patients ,5 ) ) )
    JOIN (d1 )
    JOIN (pa
    WHERE (pa.person_id = ep_summary->eps[d.seq ].patients[d1.seq ].person_id )
    AND (pa.person_alias_type_cd = mrn_cd )
    AND (pa.active_ind = 1 ) )
   DETAIL
    ep_summary->eps[d.seq ].patients[d1.seq ].mrn = pa.alias
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  summaryreport (measure )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE sum_var = f8 WITH protect ,noconstant (0 )
  DECLARE count_var = f8 WITH protect ,noconstant (0 )
  DECLARE ep = i4 WITH protect ,noconstant (0 )
  DECLARE p = i4 WITH protect ,noconstant (0 )
  DECLARE e = i4 WITH protect ,noconstant (0 )
  DECLARE pat = i4 WITH protect ,noconstant (0 )
  DECLARE enc = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";summaryReport" )
  CALL beg_time (0 )
  FOR (ep = 1 TO ep_summary->ep_cnt )
   IF ((ep_summary->eps[ep ].reportmean = measure ) )
    FOR (p = 1 TO ep_summary->eps[ep ].patient_cnt )
     SET pat = locateval (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,ep_summary->eps[ep ].patients[p
      ].person_id ,lh_ep_reply->persons[iter1 ].person_id )
     IF ((pat > 0 ) )
      IF ((ep_summary->eps[ep ].patients[p ].exclude_ind = 0 ) )
       SET ep_summary->eps[ep ].patients[p ].outcome_ind = lh_ep_reply->persons[pat ].outcome_ind
       SET ep_summary->eps[ep ].patients[p ].outcome = lh_ep_reply->persons[pat ].outcome
       SET ep_summary->eps[ep ].patients[p ].exclude_ind = lh_ep_reply->persons[pat ].exclude_ind
       SET ep_summary->eps[ep ].patients[p ].outcome_numeric = lh_ep_reply->persons[pat ].
       outcome_numeric
       SET ep_summary->eps[ep ].patients[p ].gender = lh_ep_reply->persons[pat ].gender
       SET ep_summary->eps[ep ].patients[p ].race = lh_ep_reply->persons[pat ].race
       SET ep_summary->eps[ep ].patients[p ].ethnicity = lh_ep_reply->persons[pat ].ethnicity
       SET ep_summary->eps[ep ].patients[p ].payer = lh_ep_reply->persons[pat ].payer
       SET ep_summary->eps[ep ].patients[p ].payer_group = lh_ep_reply->persons[pat ].payer_group
       SET ep_summary->eps[ep ].patients[p ].hic = lh_ep_reply->persons[pat ].hic
      ENDIF
      IF ((isencounterlevelmeasure (measure ) = 1 ) )
       FOR (e = 1 TO ep_summary->eps[ep ].patients[p ].encntr_cnt )
        SET enc = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons[pat ].encntrs ,5 ) ,ep_summary
         ->eps[ep ].patients[p ].encntrs[e ].encntr_id ,lh_ep_reply->persons[pat ].encntrs[iter2 ].
         encntr_id )
        IF ((enc > 0 ) )
         SET ep_summary->eps[ep ].patients[p ].encntrs[e ].outcome_ind = lh_ep_reply->persons[pat ].
         encntrs[enc ].outcome_ind
         SET ep_summary->eps[ep ].patients[p ].encntrs[e ].outcome = lh_ep_reply->persons[pat ].
         encntrs[enc ].outcome
         SET ep_summary->eps[ep ].patients[p ].encntrs[e ].exclude_ind = lh_ep_reply->persons[pat ].
         encntrs[enc ].exclude_ind
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
  IF ((uses_outcome_numeric (measure ) = 1 ) )
   FOR (ep = 1 TO ep_summary->ep_cnt )
    IF ((ep_summary->eps[ep ].reportmean = measure ) )
     SET count_var = 0
     SET sum_var = 0
     FOR (p = 1 TO ep_summary->eps[ep ].patient_cnt )
      SET pat = locatevalsort (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,ep_summary->eps[ep ].
       patients[p ].person_id ,lh_ep_reply->persons[iter1 ].person_id )
      IF ((pat > 0 ) )
       IF ((ep_summary->eps[ep ].patients[p ].exclude_ind = 0 )
       AND (lh_ep_reply->persons[pat ].special_group = 2 ) )
        SET count_var = (count_var + 1 )
        SET sum_var = (sum_var + lh_ep_reply->persons[pat ].outcome_numeric )
       ENDIF
      ENDIF
     ENDFOR
     SET ep_summary->eps[ep ].percent = (sum_var / count_var )
    ENDIF
   ENDFOR
  ENDIF
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("debug: end of summaryReport" )
   CALL echorecord (ep_summary )
  ENDIF
 END ;Subroutine
 SUBROUTINE  sortreport_det (null )
  CALL lhprint (build (";################ sortReport_DET Function ################" ) )
  CALL beg_time (0 )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE start_not_done = i4 WITH noconstant (0 ) ,protect
  DECLARE start_done = i4 WITH noconstant (0 ) ,protect
  DECLARE start_exclude = i4 WITH noconstant (0 ) ,protect
  DECLARE move_to = i4 WITH noconstant (0 ) ,protect
  DECLARE epcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE mcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE pcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE ecnt = i4 WITH noconstant (0 ) ,protect
  DECLARE esize = i4 WITH noconstant (0 ) ,protect
  DECLARE provider = i4 WITH noconstant (0 ) ,protect
  DECLARE epiter = i4 WITH noconstant (1 ) ,protect
  DECLARE rec_size = i4 WITH noconstant (0 ) ,protect
  DECLARE done = i2 WITH noconstant (0 ) ,protect
  DECLARE epidx = i4 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  DECLARE eppos = i4 WITH protect ,noconstant (0 )
  DECLARE measpos = i4 WITH protect ,noconstant (0 )
  DECLARE tmpsize = i4 WITH protect ,noconstant (0 )
  IF ((ep_report->ep_cnt > 0 ) )
   FOR (epcnt = 1 TO ep_report->ep_cnt )
    FOR (mcnt = 1 TO ep_report->eps[epcnt ].measure_cnt )
     FOR (pcnt = 1 TO ep_report->eps[epcnt ].measures[mcnt ].patient_cnt )
      SET ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].sortkey = calcoutcomesortkey (
       ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].outcome_ind )
      IF ((isencounterlevelmeasure (ep_report->eps[epcnt ].measures[mcnt ].reportmean ) = 1 ) )
       FOR (ecnt = 1 TO ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntr_cnt )
        SET ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntrs[ecnt ].sortkey =
        calcoutcomesortkey (ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntrs[ecnt ].
         outcome_ind )
       ENDFOR
      ENDIF
     ENDFOR
    ENDFOR
   ENDFOR
   SET stat = initrec (temp_ep_report )
   SELECT INTO "NL:"
    flat_ep_name = cnvtlower (substring (1 ,100 ,ep_report->eps[d1.seq ].name ) ) ,
    provid = ep_report->eps[d1.seq ].provider_id ,
    taxid = ep_report->eps[d1.seq ].tax_id_nbr_txt ,
    repmean = cnvtupper (substring (1 ,30 ,ep_report->eps[d1.seq ].measures[d2.seq ].reportmean ) ) ,
    pat_outcome_key = ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].sortkey ,
    flat_patient_name = cnvtupper (substring (1 ,30 ,ep_report->eps[d1.seq ].measures[d2.seq ].
      patients[d3.seq ].name ) ) ,
    pid = ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].person_id ,
    eid = ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].encntrs[d4.seq ].encntr_id
    FROM (dummyt d1 WITH seq = value (size (ep_report->eps ,5 ) ) ),
     (dummyt d2 WITH seq = 1 ),
     (dummyt d3 WITH seq = 1 ),
     (dummyt d4 WITH seq = 1 )
    PLAN (d1
     WHERE maxrec (d2 ,size (ep_report->eps[d1.seq ].measures ,5 ) ) )
     JOIN (d2
     WHERE maxrec (d3 ,size (ep_report->eps[d1.seq ].measures[d2.seq ].patients ,5 ) ) )
     JOIN (d3
     WHERE maxrec (d4 ,size (ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].encntrs ,5
       ) ) )
     JOIN (d4 )
    ORDER BY flat_ep_name ,
     provid ,
     taxid ,
     repmean ,
     pat_outcome_key ,
     flat_patient_name ,
     pid ,
     eid
    HEAD REPORT
     epcnt = 0 ,
     stat = alterlist (temp_ep_report->eps ,size (ep_report->eps ,5 ) ) ,
     temp_ep_report->ep_cnt = ep_report->ep_cnt
    HEAD provid
     dummy = 0
    HEAD taxid
     epcnt = (epcnt + 1 ) ,temp_ep_report->eps[epcnt ].br_eligible_provider_id = ep_report->eps[d1
     .seq ].br_eligible_provider_id ,temp_ep_report->eps[epcnt ].provider_id = ep_report->eps[d1.seq
     ].provider_id ,temp_ep_report->eps[epcnt ].name = ep_report->eps[d1.seq ].name ,temp_ep_report->
     eps[epcnt ].tax_id_nbr_txt = ep_report->eps[d1.seq ].tax_id_nbr_txt ,temp_ep_report->eps[epcnt ]
     .npi_nbr_txt = ep_report->eps[d1.seq ].npi_nbr_txt ,temp_ep_report->eps[epcnt ].measure_cnt =
     ep_report->eps[d1.seq ].measure_cnt ,mcnt = 0 ,stat = alterlist (temp_ep_report->eps[epcnt ].
      measures ,size (ep_report->eps[d1.seq ].measures ,5 ) )
    HEAD repmean
     mcnt = (mcnt + 1 ) ,temp_ep_report->eps[epcnt ].measures[mcnt ].reportmean = ep_report->eps[d1
     .seq ].measures[d2.seq ].reportmean ,temp_ep_report->eps[epcnt ].measures[mcnt ].ippcnt =
     ep_report->eps[d1.seq ].measures[d2.seq ].ippcnt ,temp_ep_report->eps[epcnt ].measures[mcnt ].
     nnums = ep_report->eps[d1.seq ].measures[d2.seq ].nnums ,temp_ep_report->eps[epcnt ].measures[
     mcnt ].ndens = ep_report->eps[d1.seq ].measures[d2.seq ].ndens ,temp_ep_report->eps[epcnt ].
     measures[mcnt ].nexcs = ep_report->eps[d1.seq ].measures[d2.seq ].nexcs ,temp_ep_report->eps[
     epcnt ].measures[mcnt ].nexceps = ep_report->eps[d1.seq ].measures[d2.seq ].nexceps ,
     temp_ep_report->eps[epcnt ].measures[mcnt ].percent = ep_report->eps[d1.seq ].measures[d2.seq ].
     percent ,temp_ep_report->eps[epcnt ].measures[mcnt ].patient_cnt = ep_report->eps[d1.seq ].
     measures[d2.seq ].patient_cnt ,pcnt = 0 ,stat = alterlist (temp_ep_report->eps[epcnt ].measures[
      mcnt ].patients ,size (ep_report->eps[d1.seq ].measures[d2.seq ].patients ,5 ) )
    HEAD pid
     pcnt = (pcnt + 1 ) ,temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].person_id =
     ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].person_id ,temp_ep_report->eps[
     epcnt ].measures[mcnt ].patients[pcnt ].name = ep_report->eps[d1.seq ].measures[d2.seq ].
     patients[d3.seq ].name ,temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].mrn =
     ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].mrn ,temp_ep_report->eps[epcnt ].
     measures[mcnt ].patients[pcnt ].birth_date = ep_report->eps[d1.seq ].measures[d2.seq ].patients[
     d3.seq ].birth_date ,temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].outcome =
     ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].outcome ,temp_ep_report->eps[epcnt ]
     .measures[mcnt ].patients[pcnt ].outcome_ind = ep_report->eps[d1.seq ].measures[d2.seq ].
     patients[d3.seq ].outcome_ind ,temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].
     outcome_numeric = ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].outcome_numeric ,
     temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntr_cnt = ep_report->eps[d1.seq ]
     .measures[d2.seq ].patients[d3.seq ].encntr_cnt ,ecnt = 0 ,esize = size (ep_report->eps[d1.seq ]
      .measures[d2.seq ].patients[d3.seq ].encntrs ,5 ) ,stat = alterlist (temp_ep_report->eps[epcnt
      ].measures[mcnt ].patients[pcnt ].encntrs ,esize )
    HEAD eid
     ecnt = (ecnt + 1 ) ,temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntrs[ecnt ].
     encntr_id = ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].encntrs[d4.seq ].
     encntr_id ,temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntrs[ecnt ].visit_date
      = ep_report->eps[d1.seq ].measures[d2.seq ].patients[d3.seq ].encntrs[d4.seq ].visit_date ,
     temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntrs[ecnt ].fin = ep_report->eps[
     d1.seq ].measures[d2.seq ].patients[d3.seq ].encntrs[d4.seq ].fin ,temp_ep_report->eps[epcnt ].
     measures[mcnt ].patients[pcnt ].encntrs[ecnt ].outcome = ep_report->eps[d1.seq ].measures[d2
     .seq ].patients[d3.seq ].encntrs[d4.seq ].outcome ,temp_ep_report->eps[epcnt ].measures[mcnt ].
     patients[pcnt ].encntrs[ecnt ].outcome_ind = ep_report->eps[d1.seq ].measures[d2.seq ].patients[
     d3.seq ].encntrs[d4.seq ].outcome_ind
    FOOT  pid
     stat = alterlist (temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntrs ,ecnt ) ,
     temp_ep_report->eps[epcnt ].measures[mcnt ].patients[pcnt ].encntr_cnt = ecnt
    FOOT  repmean
     stat = alterlist (temp_ep_report->eps[epcnt ].measures[mcnt ].patients ,pcnt ) ,temp_ep_report->
     eps[epcnt ].measures[mcnt ].patient_cnt = pcnt
    FOOT  provid
     stat = alterlist (temp_ep_report->eps[epcnt ].measures ,mcnt ) ,temp_ep_report->eps[epcnt ].
     measure_cnt = mcnt
    FOOT REPORT
     stat = alterlist (temp_ep_report->eps ,epcnt ) ,
     temp_ep_report->ep_cnt = epcnt
    WITH nocounter
   ;end select
   SET stat = moverec (temp_ep_report ,ep_report )
   SET stat = initrec (temp_ep_report )
   IF ((ep_report->ep_cnt > 0 ) )
    WHILE ((done = 0 ) )
     SET rec_size = ep_report->ep_cnt
     IF ((ep_report->eps[epiter ].br_eligible_provider_id <= 0 ) )
      SET rec_size = (rec_size - 1 )
      SET stat = alterlist (ep_report->eps ,rec_size ,(epiter - 1 ) )
      SET ep_report->ep_cnt = rec_size
     ELSE
      SET epiter = (epiter + 1 )
     ENDIF
     IF ((epiter > rec_size ) )
      SET done = 1
     ENDIF
    ENDWHILE
   ENDIF
   IF ((params->report_by = "GPRO" ) )
    SELECT INTO "NL:"
     FROM (br_gpro bg ),
      (dummyt d1 WITH seq = params->grp_cnt )
     PLAN (d1
      WHERE (params->grp_cnt > 0 ) )
      JOIN (bg
      WHERE (bg.br_gpro_id = params->grps[d1.seq ].br_gpro_id ) )
     DETAIL
      epidx = locateval (num ,1 ,ep_report->ep_cnt ,params->grps[d1.seq ].br_gpro_id ,ep_report->eps[
       num ].br_eligible_provider_id ) ,
      IF ((epidx = 0 ) ) ep_report->ep_cnt = (ep_report->ep_cnt + 1 ) ,stat = alterlist (ep_report->
        eps ,ep_report->ep_cnt ) ,ep_report->eps[ep_report->ep_cnt ].br_eligible_provider_id = params
       ->grps[d1.seq ].br_gpro_id ,ep_report->eps[ep_report->ep_cnt ].name = bg.br_gpro_name ,
       ep_report->eps[ep_report->ep_cnt ].tax_id_nbr_txt = bg.tax_id_nbr_txt ,ep_report->eps[
       ep_report->ep_cnt ].measure_cnt = 0
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((params->report_by = "CPC" ) )
    SELECT INTO "NL:"
     FROM (br_cpc bc ),
      (dummyt d1 WITH seq = params->ep_cnt )
     PLAN (d1
      WHERE (params->ep_cnt > 0 ) )
      JOIN (bc
      WHERE (bc.br_cpc_id = params->eps[d1.seq ].br_eligible_provider_id ) )
     DETAIL
      epidx = locateval (num ,1 ,ep_report->ep_cnt ,params->eps[d1.seq ].br_eligible_provider_id ,
       ep_report->eps[num ].br_eligible_provider_id ) ,
      IF ((epidx = 0 ) ) ep_report->ep_cnt = (ep_report->ep_cnt + 1 ) ,stat = alterlist (ep_report->
        eps ,ep_report->ep_cnt ) ,ep_report->eps[ep_report->ep_cnt ].br_eligible_provider_id = params
       ->eps[d1.seq ].br_eligible_provider_id ,ep_report->eps[ep_report->ep_cnt ].name = bc
       .br_cpc_name ,ep_report->eps[ep_report->ep_cnt ].tax_id_nbr_txt = bc.cpc_site_id_txt ,
       ep_report->eps[ep_report->ep_cnt ].npi_nbr_txt = bc.tax_id_nbr_txt ,ep_report->eps[ep_report->
       ep_cnt ].measure_cnt = 0
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (br_eligible_provider ep ),
      (prsnl pl ),
      (br_gpro_reltn gr ),
      (br_gpro g )
     WHERE expand (num ,1 ,size (params->eps ,5 ) ,ep.br_eligible_provider_id ,params->eps[num ].
      br_eligible_provider_id )
     AND (ep.provider_id = pl.person_id )
     AND (gr.parent_entity_id = ep.br_eligible_provider_id )
     AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (gr.active_ind = 1 )
     AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (g.br_gpro_id = gr.br_gpro_id )
     AND (g.active_ind = 1 )
     AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     ORDER BY ep.br_eligible_provider_id ,
      g.br_gpro_id
     HEAD REPORT
      i = 0 ,
      j = 0
     HEAD ep.br_eligible_provider_id
      i = locateval (num ,1 ,size (ep_report->eps ,5 ) ,ep.br_eligible_provider_id ,ep_report->eps[
       num ].br_eligible_provider_id )
     HEAD g.br_gpro_id
      j = locateval (num ,1 ,size (ep_report->eps ,5 ) ,g.tax_id_nbr_txt ,ep_report->eps[num ].
       tax_id_nbr_txt ) ,
      IF ((((i = 0 ) ) OR ((j = 0 ) )) ) k = locateval (num ,1 ,size (filter_params->tins ,5 ) ,g
        .br_gpro_id ,filter_params->tins[num ].br_gpro_id ) ,
       IF ((((size (filter_params->tins ,5 ) = 0 ) ) OR ((k != 0 ) )) ) ep_report->ep_cnt = (
        ep_report->ep_cnt + 1 ) ,stat = alterlist (ep_report->eps ,ep_report->ep_cnt ) ,ep_report->
        eps[ep_report->ep_cnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_report->eps[
        ep_report->ep_cnt ].provider_id = ep.provider_id ,ep_report->eps[ep_report->ep_cnt ].name =
        pl.name_full_formatted ,ep_report->eps[ep_report->ep_cnt ].tax_id_nbr_txt = g.tax_id_nbr_txt
       ,ep_report->eps[ep_report->ep_cnt ].npi_nbr_txt = ep.national_provider_nbr_txt ,ep_report->
        eps[ep_report->ep_cnt ].measure_cnt = 0
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
   ENDIF
   SET stat = initrec (temp_ep_report )
   IF ((ep_report->ep_cnt > 0 ) )
    SELECT INTO "NL:"
     flat_name = cnvtupper (ep_report->eps[d.seq ].name )
     FROM (dummyt d WITH seq = ep_report->ep_cnt )
     PLAN (d )
     ORDER BY flat_name
     HEAD REPORT
      epidx = 0
     DETAIL
      epidx = (epidx + 1 ) ,
      temp_ep_report->ep_cnt = epidx ,
      stat = alterlist (temp_ep_report->eps ,epidx ) ,
      temp_ep_report->eps[epidx ].br_eligible_provider_id = ep_report->eps[d.seq ].
      br_eligible_provider_id ,
      temp_ep_report->eps[epidx ].provider_id = ep_report->eps[d.seq ].provider_id ,
      temp_ep_report->eps[epidx ].name = ep_report->eps[d.seq ].name ,
      temp_ep_report->eps[epidx ].tax_id_nbr_txt = ep_report->eps[d.seq ].tax_id_nbr_txt ,
      temp_ep_report->eps[epidx ].npi_nbr_txt = ep_report->eps[d.seq ].npi_nbr_txt ,
      temp_ep_report->eps[epidx ].measure_cnt = ep_report->eps[d.seq ].measure_cnt ,
      IF ((temp_ep_report->eps[epidx ].measure_cnt > 0 ) ) stat = moverec (ep_report->eps[d.seq ].
        measures ,temp_ep_report->eps[epidx ].measures )
      ENDIF
     WITH nocounter
    ;end select
    SET stat = moverec (temp_ep_report ,ep_report )
   ENDIF
   IF ((params->report_by != "GPRO" ) )
    FOR (i = 1 TO size (params->eps ,5 ) )
     SET eppos = locateval (num ,1 ,ep_report->ep_cnt ,params->eps[i ].br_eligible_provider_id ,
      ep_report->eps[num ].br_eligible_provider_id )
     WHILE ((eppos > 0 ) )
      FOR (j = 1 TO size (params->eps[i ].measures ,5 ) )
       SET measpos = locateval (num ,1 ,size (ep_report->eps[eppos ].measures ,5 ) ,cnvtupper (params
         ->eps[i ].measures[j ].mean ) ,cnvtupper (ep_report->eps[eppos ].measures[num ].reportmean
         ) )
       IF ((measpos <= 0 ) )
        SET tmpsize = (size (ep_report->eps[eppos ].measures ,5 ) + 1 )
        SET stat = alterlist (ep_report->eps[eppos ].measures ,tmpsize )
        SET ep_report->eps[eppos ].measures[tmpsize ].reportmean = params->eps[i ].measures[j ].mean
        SET ep_report->eps[eppos ].measure_cnt = tmpsize
       ENDIF
      ENDFOR
      SET eppos = locateval (num ,(eppos + 1 ) ,ep_report->ep_cnt ,params->eps[i ].
       br_eligible_provider_id ,ep_report->eps[num ].br_eligible_provider_id )
     ENDWHILE
    ENDFOR
   ELSE
    FOR (i = 1 TO size (params->grps ,5 ) )
     SET eppos = locateval (num ,1 ,ep_report->ep_cnt ,params->grps[i ].br_gpro_id ,ep_report->eps[
      num ].br_eligible_provider_id )
     IF ((eppos > 0 ) )
      FOR (j = 1 TO size (params->grps[i ].measures ,5 ) )
       SET measpos = locateval (num ,1 ,size (ep_report->eps[eppos ].measures ,5 ) ,cnvtupper (params
         ->grps[i ].measures[j ].mean ) ,cnvtupper (ep_report->eps[eppos ].measures[num ].reportmean
         ) )
       IF ((measpos <= 0 ) )
        SET tmpsize = (size (ep_report->eps[eppos ].measures ,5 ) + 1 )
        SET stat = alterlist (ep_report->eps[eppos ].measures ,tmpsize )
        SET ep_report->eps[eppos ].measures[tmpsize ].reportmean = params->grps[i ].measures[j ].mean
        SET ep_report->eps[eppos ].measure_cnt = tmpsize
       ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   SET stat = initrec (temp_ep_report )
  ENDIF
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  sortreport_sum (null )
  CALL lhprint (build (";################ sortReport_SUM Function ################" ) )
  CALL beg_time (0 )
  DECLARE epcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE mcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE j = i4 WITH noconstant (0 ) ,protect
  DECLARE k = i4 WITH noconstant (0 ) ,protect
  DECLARE l = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE al_batch_size = i4 WITH noconstant (0 ) ,protect
  IF ((ep_report->ep_cnt > 0 ) )
   SET stat = initrec (temp_ep_report )
   IF ((params->report_by = "GPRO" ) )
    SELECT INTO "nl:"
     gproid = params->grps[d1.seq ].br_gpro_id
     FROM (dummyt d1 WITH seq = value (size (params->grps ,5 ) ) ),
      (br_gpro bg )
     PLAN (d1
      WHERE (params->grp_cnt > 0 ) )
      JOIN (bg
      WHERE (bg.br_gpro_id = params->grps[d1.seq ].br_gpro_id ) )
     ORDER BY gproid
     HEAD REPORT
      epcnt = 0
     HEAD gproid
      epcnt = (epcnt + 1 ) ,stat = alterlist (temp_ep_report->eps ,epcnt ) ,temp_ep_report->eps[
      epcnt ].br_eligible_provider_id = gproid ,temp_ep_report->eps[epcnt ].provider_id = gproid ,
      temp_ep_report->eps[epcnt ].name = bg.br_gpro_name ,temp_ep_report->ep_cnt = epcnt ,stat =
      alterlist (temp_ep_report->eps[epcnt ].measures ,params->grps[d1.seq ].measure_cnt ) ,
      temp_ep_report->eps[epcnt ].measure_cnt = params->grps[d1.seq ].measure_cnt ,temp_ep_report->
      eps[epcnt ].tax_id_nbr_txt = params->grps[d1.seq ].tax_id_nbr_txt ,
      FOR (i = 1 TO params->grps[d1.seq ].measure_cnt )
       temp_ep_report->eps[epcnt ].measures[i ].reportmean = substring (1 ,25 ,params->grps[d1.seq ].
        measures[i ].mean ) ,temp_ep_report->eps[epcnt ].measures[i ].ippcnt = 0 ,temp_ep_report->
       eps[epcnt ].measures[i ].nnums = 0 ,temp_ep_report->eps[epcnt ].measures[i ].ndens = 0 ,
       temp_ep_report->eps[epcnt ].measures[i ].nexcs = 0 ,temp_ep_report->eps[epcnt ].measures[i ].
       nexceps = 0 ,temp_ep_report->eps[epcnt ].measures[i ].percent = 0
      ENDFOR
     WITH nocounter
    ;end select
   ELSEIF ((params->report_by = "CPC" ) )
    SELECT INTO "nl:"
     FROM (dummyt d1 WITH seq = params->ep_cnt ),
      (br_cpc bc )
     PLAN (d1 )
      JOIN (bc
      WHERE (bc.br_cpc_id = params->eps[d1.seq ].br_eligible_provider_id ) )
     ORDER BY bc.br_cpc_id
     HEAD REPORT
      epcnt = 0
     HEAD bc.br_cpc_id
      epcnt = (epcnt + 1 ) ,stat = alterlist (temp_ep_report->eps ,epcnt ) ,temp_ep_report->eps[
      epcnt ].br_eligible_provider_id = params->eps[d1.seq ].br_eligible_provider_id ,temp_ep_report
      ->eps[epcnt ].name = bc.br_cpc_name ,temp_ep_report->ep_cnt = epcnt ,temp_ep_report->eps[epcnt
      ].measure_cnt = params->measure_cnt ,temp_ep_report->eps[epcnt ].npi_nbr_txt = bc
      .cpc_site_id_txt ,temp_ep_report->eps[epcnt ].tax_id_nbr_txt = bc.tax_id_nbr_txt ,stat =
      alterlist (temp_ep_report->eps[epcnt ].measures ,params->measure_cnt ) ,
      FOR (i = 1 TO params->measure_cnt )
       temp_ep_report->eps[epcnt ].measures[i ].reportmean = substring (1 ,25 ,params->measures[i ].
        mean )
      ENDFOR
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (prsnl p ),
      (br_eligible_provider b ),
      (br_gpro_reltn gr ),
      (br_gpro g ),
      (dummyt d1 WITH seq = value (size (params->eps ,5 ) ) )
     PLAN (d1 )
      JOIN (b
      WHERE (b.br_eligible_provider_id = params->eps[d1.seq ].br_eligible_provider_id ) )
      JOIN (p
      WHERE (p.person_id = b.provider_id ) )
      JOIN (gr
      WHERE (gr.active_ind = 1 )
      AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
      AND (gr.parent_entity_id = b.br_eligible_provider_id ) )
      JOIN (g
      WHERE (g.active_ind = 1 )
      AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (g.br_gpro_id = gr.br_gpro_id ) )
     ORDER BY b.br_eligible_provider_id ,
      g.br_gpro_id
     HEAD REPORT
      epcnt = 0
     HEAD b.br_eligible_provider_id
      dummy = 0
     HEAD g.br_gpro_id
      i = locateval (num ,1 ,size (filter_params->tins ,5 ) ,g.br_gpro_id ,filter_params->tins[num ].
       br_gpro_id ) ,
      IF ((((size (filter_params->tins ,5 ) = 0 ) ) OR ((i > 0 ) )) ) epcnt = (epcnt + 1 ) ,stat =
       alterlist (temp_ep_report->eps ,epcnt ) ,temp_ep_report->eps[epcnt ].br_eligible_provider_id
       = params->eps[d1.seq ].br_eligible_provider_id ,temp_ep_report->eps[epcnt ].provider_id = b
       .provider_id ,temp_ep_report->eps[epcnt ].name = cnvtupper (p.name_full_formatted ) ,
       temp_ep_report->ep_cnt = epcnt ,stat = alterlist (temp_ep_report->eps[epcnt ].measures ,params
        ->eps[d1.seq ].measure_cnt ) ,temp_ep_report->eps[epcnt ].measure_cnt = params->eps[d1.seq ].
       measure_cnt ,temp_ep_report->eps[epcnt ].npi_nbr_txt = b.national_provider_nbr_txt ,
       temp_ep_report->eps[epcnt ].tax_id_nbr_txt = g.tax_id_nbr_txt ,
       FOR (i = 1 TO params->eps[d1.seq ].measure_cnt )
        temp_ep_report->eps[epcnt ].measures[i ].reportmean = substring (1 ,25 ,params->eps[d1.seq ].
         measures[i ].mean ) ,temp_ep_report->eps[epcnt ].measures[i ].ippcnt = 0 ,temp_ep_report->
        eps[epcnt ].measures[i ].nnums = 0 ,temp_ep_report->eps[epcnt ].measures[i ].ndens = 0 ,
        temp_ep_report->eps[epcnt ].measures[i ].nexcs = 0 ,temp_ep_report->eps[epcnt ].measures[i ].
        nexceps = 0 ,temp_ep_report->eps[epcnt ].measures[i ].percent = 0
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FOR (i = 1 TO temp_ep_report->ep_cnt )
    SET j = locateval (iter1 ,1 ,ep_report->ep_cnt ,temp_ep_report->eps[i ].br_eligible_provider_id ,
     ep_report->eps[iter1 ].br_eligible_provider_id ,temp_ep_report->eps[i ].tax_id_nbr_txt ,
     ep_report->eps[iter1 ].tax_id_nbr_txt )
    IF ((j > 0 ) )
     FOR (k = 1 TO temp_ep_report->eps[i ].measure_cnt )
      SET l = locateval (iter2 ,1 ,ep_report->eps[j ].measure_cnt ,temp_ep_report->eps[i ].measures[
       k ].reportmean ,ep_report->eps[j ].measures[iter2 ].reportmean )
      IF ((l > 0 ) )
       SET temp_ep_report->eps[i ].measures[k ].ippcnt = ep_report->eps[j ].measures[l ].ippcnt
       SET temp_ep_report->eps[i ].measures[k ].nnums = ep_report->eps[j ].measures[l ].nnums
       SET temp_ep_report->eps[i ].measures[k ].ndens = ep_report->eps[j ].measures[l ].ndens
       SET temp_ep_report->eps[i ].measures[k ].nexcs = ep_report->eps[j ].measures[l ].nexcs
       SET temp_ep_report->eps[i ].measures[k ].nexceps = ep_report->eps[j ].measures[l ].nexceps
       SET temp_ep_report->eps[i ].measures[k ].percent = ep_report->eps[j ].measures[l ].percent
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   SET stat = initrec (ep_report )
   SELECT INTO "NL:"
    flat_ep_name = cnvtlower (substring (1 ,100 ,temp_ep_report->eps[d1.seq ].name ) ) ,
    br_provid = temp_ep_report->eps[d1.seq ].br_eligible_provider_id ,
    taxid = temp_ep_report->eps[d1.seq ].tax_id_nbr_txt ,
    repmean = cnvtupper (substring (1 ,30 ,temp_ep_report->eps[d1.seq ].measures[d2.seq ].reportmean
      ) )
    FROM (dummyt d1 WITH seq = value (size (temp_ep_report->eps ,5 ) ) ),
     (dummyt d2 WITH seq = 1 )
    PLAN (d1
     WHERE maxrec (d2 ,size (temp_ep_report->eps[d1.seq ].measures ,5 ) ) )
     JOIN (d2 )
    ORDER BY flat_ep_name ,
     br_provid ,
     taxid ,
     repmean
    HEAD REPORT
     epcnt = 0
    HEAD br_provid
     dummy = 0
    HEAD taxid
     epcnt = (epcnt + 1 ) ,ep_report->ep_cnt = epcnt ,al_batch_size = 100 ,
     IF ((mod (epcnt ,al_batch_size ) = 1 ) ) stat = alterlist (ep_report->eps ,((epcnt +
       al_batch_size ) - 1 ) )
     ENDIF
     ,ep_report->eps[epcnt ].br_eligible_provider_id = temp_ep_report->eps[d1.seq ].
     br_eligible_provider_id ,ep_report->eps[epcnt ].provider_id = temp_ep_report->eps[d1.seq ].
     provider_id ,ep_report->eps[epcnt ].name = temp_ep_report->eps[d1.seq ].name ,ep_report->eps[
     epcnt ].tax_id_nbr_txt = temp_ep_report->eps[d1.seq ].tax_id_nbr_txt ,ep_report->eps[epcnt ].
     npi_nbr_txt = temp_ep_report->eps[d1.seq ].npi_nbr_txt ,mcnt = 0
    HEAD repmean
     mcnt = (mcnt + 1 ) ,ep_report->eps[epcnt ].measure_cnt = mcnt ,
     IF ((mod (mcnt ,al_batch_size ) = 1 ) ) stat = alterlist (ep_report->eps[epcnt ].measures ,((
       mcnt + al_batch_size ) - 1 ) )
     ENDIF
     ,ep_report->eps[epcnt ].measures[mcnt ].reportmean = temp_ep_report->eps[d1.seq ].measures[d2
     .seq ].reportmean ,ep_report->eps[epcnt ].measures[mcnt ].ippcnt = temp_ep_report->eps[d1.seq ].
     measures[d2.seq ].ippcnt ,ep_report->eps[epcnt ].measures[mcnt ].nnums = temp_ep_report->eps[d1
     .seq ].measures[d2.seq ].nnums ,ep_report->eps[epcnt ].measures[mcnt ].ndens = temp_ep_report->
     eps[d1.seq ].measures[d2.seq ].ndens ,ep_report->eps[epcnt ].measures[mcnt ].nexcs =
     temp_ep_report->eps[d1.seq ].measures[d2.seq ].nexcs ,ep_report->eps[epcnt ].measures[mcnt ].
     nexceps = temp_ep_report->eps[d1.seq ].measures[d2.seq ].nexceps ,ep_report->eps[epcnt ].
     measures[mcnt ].percent = temp_ep_report->eps[d1.seq ].measures[d2.seq ].percent
    FOOT  br_provid
     stat = alterlist (ep_report->eps[epcnt ].measures ,mcnt )
    FOOT REPORT
     stat = alterlist (ep_report->eps ,epcnt )
    WITH nocounter
   ;end select
   SET stat = initrec (temp_ep_report )
  ENDIF
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  addreport (null )
  DECLARE start_time = dq8 WITH protect ,noconstant (cnvtdatetime (curdate ,curtime3 ) )
  DECLARE end_time = dq8 WITH protect ,noconstant
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE provider_id = f8 WITH noconstant (0.0 ) ,protect
  DECLARE tax_id_nbr_txt = vc WITH noconstant ("" ) ,protect
  DECLARE patient_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE rptcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE numcnt = f8 WITH noconstant (0.0 ) ,protect
  DECLARE denomcnt = f8 WITH noconstant (0.0 ) ,protect
  DECLARE exclusioncnt = f8 WITH noconstant (0.0 ) ,protect
  DECLARE exceptioncnt = f8 WITH noconstant (0.0 ) ,protect
  DECLARE ippcnt = f8 WITH noconstant (0.0 ) ,protect
  DECLARE prov_percentage = f8 WITH noconstant (0 ) ,protect
  DECLARE measurename = vc WITH noconstant ("" ) ,protect
  DECLARE reportmean = vc WITH noconstant ("" ) ,protect
  DECLARE sepc = i4 WITH noconstant (0 ) ,protect
  DECLARE sptc = i4 WITH noconstant (0 ) ,protect
  DECLARE senc = i4 WITH noconstant (0 ) ,protect
  DECLARE repc = i4 WITH noconstant (0 ) ,protect
  DECLARE rmc = i4 WITH noconstant (0 ) ,protect
  DECLARE rptc = i4 WITH noconstant (0 ) ,protect
  DECLARE renc = i4 WITH noconstant (0 ) ,protect
  DECLARE reppos = i4 WITH noconstant (0 ) ,protect
  DECLARE start_not_done = i4 WITH noconstant (0 ) ,protect
  DECLARE start_done = i4 WITH noconstant (0 ) ,protect
  DECLARE start_exclude = i4 WITH noconstant (0 ) ,protect
  DECLARE move_to = i4 WITH noconstant (0 ) ,protect
  DECLARE rec_size = i4 WITH noconstant (0 ) ,protect
  DECLARE e = i4 WITH noconstant (0 ) ,protect
  DECLARE p = i4 WITH noconstant (0 ) ,protect
  DECLARE tblcnt = i4 WITH protect ,noconstant (0 )
  DECLARE r = i4 WITH protect ,noconstant (0 )
  DECLARE ep = i4 WITH noconstant (0 ) ,protect
  DECLARE patencntrcnt = i4 WITH protect ,noconstant (0 )
  CALL lhprint (build (";################ AddReport Function ################" ) )
  CALL lhprint (" " )
  CALL lhprint (build ("Start Time of AddReport:" ,format (start_time ,";;q" ) ) )
  IF ((validate (lh_pat_enc_outcomes ) = 0 ) )
   RECORD lh_pat_enc_outcomes (
     1 encs [* ]
       2 name = vc
       2 mrn = vc
       2 birth_date = vc
       2 visit_date = vc
       2 fin = vc
       2 outcome_ind = i2
       2 outcome = vc
   ) WITH public
  ENDIF
  IF ((validate (temp_lh_pat_enc_outcomes ) = 0 ) )
   RECORD temp_lh_pat_enc_outcomes (
     1 encs [* ]
       2 name = vc
       2 mrn = vc
       2 birth_date = vc
       2 visit_date = vc
       2 fin = vc
       2 outcome_ind = i2
       2 outcome = vc
   ) WITH public
  ENDIF
  FOR (sepc = 1 TO ep_summary->ep_cnt )
   SET provider_id = ep_summary->eps[sepc ].br_eligible_provider_id
   SET tax_id_nbr_txt = ep_summary->eps[sepc ].tax_id_nbr_txt
   SET reppos = locateval (num ,1 ,size (ep_report->eps ,5 ) ,provider_id ,ep_report->eps[num ].
    br_eligible_provider_id ,tax_id_nbr_txt ,ep_report->eps[num ].tax_id_nbr_txt )
   IF ((reppos = 0 ) )
    SET repc = (repc + 1 )
    SET stat = alterlist (ep_report->eps ,repc )
    SET reppos = repc
    SET ep_report->ep_cnt = repc
    SET ep_report->eps[reppos ].provider_id = provider_id
    SET ep_report->eps[reppos ].br_eligible_provider_id = ep_summary->eps[sepc ].
    br_eligible_provider_id
    SET ep_report->eps[reppos ].name = ep_summary->eps[sepc ].name
    SET ep_report->eps[reppos ].tax_id_nbr_txt = ep_summary->eps[sepc ].tax_id_nbr_txt
    SET ep_report->eps[reppos ].npi_nbr_txt = ep_summary->eps[sepc ].npi_nbr_txt
    SET ep_report->eps[reppos ].measure_cnt = 0
   ENDIF
   SET rmc = ep_report->eps[reppos ].measure_cnt
   SET rmc = (rmc + 1 )
   SET stat = alterlist (ep_report->eps[reppos ].measures ,rmc )
   SET ep_report->eps[reppos ].measure_cnt = rmc
   SET ep_report->eps[reppos ].measures[rmc ].reportmean = ep_summary->eps[sepc ].reportmean
   SET ep_report->eps[reppos ].measures[rmc ].percent = ep_summary->eps[sepc ].percent
   SET patient_cnt = ep_summary->eps[sepc ].patient_cnt
   SET stat = alterlist (ep_report->eps[reppos ].measures[rmc ].patients ,patient_cnt )
   SET rptc = 0
   FOR (sptc = 1 TO patient_cnt )
    SET rptc = (rptc + 1 )
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].person_id = ep_summary->eps[sepc ].
    patients[sptc ].person_id
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].name = ep_summary->eps[sepc ].
    patients[sptc ].name
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].mrn = ep_summary->eps[sepc ].patients[
    sptc ].mrn
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].birth_date = ep_summary->eps[sepc ].
    patients[sptc ].birth_date
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].gender = ep_summary->eps[sepc ].
    patients[sptc ].gender
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].race = ep_summary->eps[sepc ].
    patients[sptc ].race
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].ethnicity = ep_summary->eps[sepc ].
    patients[sptc ].ethnicity
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].payer = ep_summary->eps[sepc ].
    patients[sptc ].payer
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].payer_group = ep_summary->eps[sepc ].
    patients[sptc ].payer_group
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].hic = ep_summary->eps[sepc ].patients[
    sptc ].hic
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].outcome = ep_summary->eps[sepc ].
    patients[sptc ].outcome
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].outcome_ind = ep_summary->eps[sepc ].
    patients[sptc ].outcome_ind
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].outcome_numeric = ep_summary->eps[
    sepc ].patients[sptc ].outcome_numeric
    SET encntr_cnt = ep_summary->eps[sepc ].patients[sptc ].encntr_cnt
    SET stat = alterlist (ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs ,encntr_cnt
     )
    SET renc = 0
    FOR (senc = 1 TO encntr_cnt )
     SET renc = (renc + 1 )
     SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs[renc ].encntr_id = ep_summary
     ->eps[sepc ].patients[sptc ].encntrs[senc ].encntr_id
     SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs[renc ].visit_date =
     ep_summary->eps[sepc ].patients[sptc ].encntrs[senc ].visit_date
     SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs[renc ].fin = ep_summary->eps[
     sepc ].patients[sptc ].encntrs[senc ].fin
     SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs[renc ].outcome = ep_summary->
     eps[sepc ].patients[sptc ].encntrs[senc ].outcome
     SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs[renc ].outcome_ind =
     ep_summary->eps[sepc ].patients[sptc ].encntrs[senc ].outcome_ind
    ENDFOR
    SET ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntr_cnt = renc
    SET stat = alterlist (ep_report->eps[reppos ].measures[rmc ].patients[rptc ].encntrs ,renc )
   ENDFOR
   SET ep_report->eps[reppos ].measures[rmc ].patient_cnt = rptc
   SET stat = alterlist (ep_report->eps[reppos ].measures[rmc ].patients ,rptc )
  ENDFOR
  SET stat = initrec (ep_summary )
  FOR (ep = 1 TO ep_report->ep_cnt )
   FOR (ms = 1 TO ep_report->eps[ep ].measure_cnt )
    SET ippcnt = 0
    SET numcnt = 0
    SET denomcnt = 0
    SET exclusioncnt = 0
    SET exceptioncnt = 0
    IF ((isencounterlevelmeasure (ep_report->eps[ep ].measures[ms ].reportmean ) = 1 ) )
     FOR (p = 1 TO ep_report->eps[ep ].measures[ms ].patient_cnt )
      FOR (e = 1 TO ep_report->eps[ep ].measures[ms ].patients[p ].encntr_cnt )
       SET ippcnt = (ippcnt + 1 )
       IF ((ep_report->eps[ep ].measures[ms ].patients[p ].encntrs[e ].outcome_ind = 1 ) )
        SET numcnt = (numcnt + 1 )
       ELSEIF ((ep_report->eps[ep ].measures[ms ].patients[p ].encntrs[e ].outcome_ind = 2 ) )
        SET exclusioncnt = (exclusioncnt + 1 )
       ELSEIF ((ep_report->eps[ep ].measures[ms ].patients[p ].encntrs[e ].outcome_ind = 3 ) )
        SET exceptioncnt = (exceptioncnt + 1 )
       ELSEIF ((ep_report->eps[ep ].measures[ms ].patients[p ].encntrs[e ].outcome_ind = 4 ) )
        SET denomcnt = (denomcnt + 1 )
       ENDIF
      ENDFOR
     ENDFOR
     SET ep_report->eps[ep ].measures[ms ].nnums = numcnt
     SET ep_report->eps[ep ].measures[ms ].ippcnt = ippcnt
     SET ep_report->eps[ep ].measures[ms ].ndens = ippcnt
     SET ep_report->eps[ep ].measures[ms ].nexcs = exclusioncnt
     SET ep_report->eps[ep ].measures[ms ].nexceps = exceptioncnt
    ELSE
     FOR (p = 1 TO ep_report->eps[ep ].measures[ms ].patient_cnt )
      SET ippcnt = (ippcnt + 1 )
      IF ((ep_report->eps[ep ].measures[ms ].patients[p ].outcome_ind = 1 ) )
       SET numcnt = (numcnt + 1 )
      ELSEIF ((ep_report->eps[ep ].measures[ms ].patients[p ].outcome_ind = 2 ) )
       SET exclusioncnt = (exclusioncnt + 1 )
      ELSEIF ((ep_report->eps[ep ].measures[ms ].patients[p ].outcome_ind = 3 ) )
       SET exceptioncnt = (exceptioncnt + 1 )
      ELSEIF ((ep_report->eps[ep ].measures[ms ].patients[p ].outcome_ind = 4 ) )
       SET denomcnt = (denomcnt + 1 )
      ENDIF
     ENDFOR
     SET ep_report->eps[ep ].measures[ms ].nnums = numcnt
     SET ep_report->eps[ep ].measures[ms ].ippcnt = ippcnt
     SET ep_report->eps[ep ].measures[ms ].ndens = (ippcnt - denomcnt )
     SET ep_report->eps[ep ].measures[ms ].nexcs = exclusioncnt
     SET ep_report->eps[ep ].measures[ms ].nexceps = exceptioncnt
    ENDIF
   ENDFOR
  ENDFOR
  IF ((ep_report->ep_cnt = 0 ) )
   CALL getepsemptyrpt (0 )
  ENDIF
  IF ((params->report_by = "INDV" ) )
   CALL check_npi_tin (ep_report )
  ENDIF
  IF ((cnvtupper (params->chksummaryonly ) IN ("*PS" ,
  "*PDF" ) ) )
   IF ((cnvtupper (params->chksummaryonly ) IN ("DET_PS" ,
   "DET_PDF" ) ) )
    CALL sortreport_det (0 )
   ELSEIF ((cnvtupper (params->chksummaryonly ) IN ("SUM_PS" ,
   "SUM_PDF" ) ) )
    CALL sortreport_sum (0 )
   ENDIF
   FOR (ep = 1 TO ep_report->ep_cnt )
    SET rptcnt = (rpt->report_cnt + 1 )
    SET rpt->report_cnt = rptcnt
    SET stat = alterlist (rpt->reports ,rptcnt )
    SET rpt->reports[rptcnt ].tin = ep_report->eps[ep ].tax_id_nbr_txt
    SET rpt->reports[rptcnt ].npi = ep_report->eps[ep ].npi_nbr_txt
    SET rpt->reports[rptcnt ].name = ep_report->eps[ep ].name
    SET r = 1
    SET tblcnt = 1
    SET rpt->reports[rptcnt ].seq = ep
    SET rpt->reports[rptcnt ].table_cnt = 1
    SET stat = alterlist (rpt->reports[rptcnt ].tables ,1 )
    SET rpt->reports[rptcnt ].tables[tblcnt ].name = "Summary"
    SET rpt->reports[rptcnt ].tables[tblcnt ].table_seq = 1
    SET rpt->reports[rptcnt ].tables[tblcnt ].row_cnt = (ep_report->eps[ep ].measure_cnt + 1 )
    SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows ,(ep_report->eps[ep ].
     measure_cnt + 1 ) )
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cell_cnt = 7
    SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells ,7 )
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].value = "Measure"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].width = 150
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].value = "Patient Pop"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].width = 35
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].value = "Denominator"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].width = 35
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "Exclusions"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].width = 35
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = "Exceptions"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].width = 35
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "Numerator"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].width = 35
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].value = "Performance Rate"
    SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].width = 35
    FOR (ms = 1 TO ep_report->eps[ep ].measure_cnt )
     SET r = (r + 1 )
     SET reportmean = getreportmean (ep_report->eps[ep ].measures[ms ].reportmean )
     SET denomcnt = 0
     SET ippcnt = 0
     SET numcnt = 0
     SET exclusioncnt = 0
     SET exceptioncnt = 0
     SET prov_percentage = 0.0
     SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cell_cnt = 7
     SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells ,7 )
     SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].value = reportmean
     SET ippcnt = ep_report->eps[ep ].measures[ms ].ippcnt
     SET numcnt = ep_report->eps[ep ].measures[ms ].nnums
     SET denomcnt = ep_report->eps[ep ].measures[ms ].ndens
     SET exclusioncnt = ep_report->eps[ep ].measures[ms ].nexcs
     SET exceptioncnt = ep_report->eps[ep ].measures[ms ].nexceps
     SET prov_percentage = ep_report->eps[ep ].measures[ms ].percent
     SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].value = cnvtstring (ippcnt )
     SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].value = cnvtstring (denomcnt )
     IF ((uses_outcome_numeric (ep_report->eps[ep ].measures[ms ].reportmean ) = 1 ) )
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "N/A"
     ELSE
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = cnvtstring (numcnt )
     ENDIF
     IF ((hasnoexclusions (ep_report->eps[ep ].measures[ms ].reportmean ) = 1 ) )
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "N/A"
     ELSE
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = cnvtstring (exclusioncnt
       )
     ENDIF
     IF ((hasnoexceptions (ep_report->eps[ep ].measures[ms ].reportmean ) = 1 ) )
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = "N/A"
     ELSE
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = cnvtstring (exceptioncnt
       )
     ENDIF
     IF ((((denomcnt - exclusioncnt ) - exceptioncnt ) > 0 ) )
      IF ((uses_outcome_numeric (ep_report->eps[ep ].measures[ms ].reportmean ) = 1 ) )
       SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].value = build (cnvtstring (
         prov_percentage ,6 ,2 ) ,"%" )
      ELSE
       SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].value = build (cnvtstring (((
         numcnt / ((denomcnt - exclusioncnt ) - exceptioncnt ) ) * 100.00 ) ,6 ,2 ) ,"%" )
      ENDIF
     ELSE
      SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].value = "N/A"
     ENDIF
    ENDFOR
    IF ((cnvtupper (params->chksummaryonly ) IN ("DET_PS" ,
    "DET_PDF" ) ) )
     FOR (md = 1 TO ep_report->eps[ep ].measure_cnt )
      IF ((ep_report->eps[ep ].measures[md ].patient_cnt > 0 ) )
       SET tblcnt = (tblcnt + 1 )
       SET rpt->reports[rptcnt ].table_cnt = tblcnt
       SET stat = alterlist (rpt->reports[rptcnt ].tables ,tblcnt )
       SET rpt->reports[rptcnt ].tables[tblcnt ].table_seq = tblcnt
       SET measurename = getmeasurename (ep_report->eps[ep ].measures[md ].reportmean )
       SET rpt->reports[rptcnt ].tables[tblcnt ].name = build2 ("Details - " ,measurename )
       SET r = (rpt->reports[rptcnt ].tables[tblcnt ].row_cnt + 1 )
       SET rpt->reports[rptcnt ].tables[tblcnt ].row_cnt = r
       SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows ,r )
       IF ((isencounterlevelmeasure (ep_report->eps[ep ].measures[md ].reportmean ) = 1 ) )
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cell_cnt = 7
        SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells ,7 )
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].value = "Patient Name"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].width = 125
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].value = "MRN"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].width = 20
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].value = "Date of Birth"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].width = 40
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "Visit Date"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].width = 20
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = "Fin Nbr"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].width = 20
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "Numerator"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].width = 20
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].value = "Outcome"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].width = 80
        SET stat = initrec (lh_pat_enc_outcomes )
        SET patencntrcnt = 0
        FOR (p = 1 TO ep_report->eps[ep ].measures[md ].patient_cnt )
         FOR (e = 1 TO ep_report->eps[ep ].measures[md ].patients[p ].encntr_cnt )
          SET patencntrcnt = (patencntrcnt + 1 )
          SET stat = alterlist (lh_pat_enc_outcomes->encs ,patencntrcnt )
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].name = ep_report->eps[ep ].measures[md ].
          patients[p ].name
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].mrn = ep_report->eps[ep ].measures[md ].
          patients[p ].mrn
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].birth_date = ep_report->eps[ep ].measures[md ]
          .patients[p ].birth_date
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].visit_date = ep_report->eps[ep ].measures[md ]
          .patients[p ].encntrs[e ].visit_date
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].fin = ep_report->eps[ep ].measures[md ].
          patients[p ].encntrs[e ].fin
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].outcome_ind = ep_report->eps[ep ].measures[md
          ].patients[p ].encntrs[e ].outcome_ind
          SET lh_pat_enc_outcomes->encs[patencntrcnt ].outcome = ep_report->eps[ep ].measures[md ].
          patients[p ].encntrs[e ].outcome
         ENDFOR
        ENDFOR
        SET stat = initrec (temp_lh_pat_enc_outcomes )
        SELECT INTO "NL:"
         flat_outcome = cnvtupper (substring (1 ,30 ,lh_pat_enc_outcomes->encs[d.seq ].outcome ) ) ,
         flat_name = cnvtupper (substring (1 ,30 ,lh_pat_enc_outcomes->encs[d.seq ].name ) )
         FROM (dummyt d WITH seq = value (size (lh_pat_enc_outcomes->encs ,5 ) ) )
         ORDER BY lh_pat_enc_outcomes->encs[d.seq ].outcome_ind ,
          flat_outcome ,
          flat_name ,
          lh_pat_enc_outcomes->encs[d.seq ].fin
         HEAD REPORT
          patencntrcnt = 0 ,
          stat = alterlist (temp_lh_pat_enc_outcomes->encs ,size (lh_pat_enc_outcomes->encs ,5 ) )
         DETAIL
          patencntrcnt = (patencntrcnt + 1 ) ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].name = lh_pat_enc_outcomes->encs[d.seq ].name
           ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].mrn = lh_pat_enc_outcomes->encs[d.seq ].mrn ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].birth_date = lh_pat_enc_outcomes->encs[d.seq
          ].birth_date ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].visit_date = lh_pat_enc_outcomes->encs[d.seq
          ].visit_date ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].fin = lh_pat_enc_outcomes->encs[d.seq ].fin ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].outcome_ind = lh_pat_enc_outcomes->encs[d
          .seq ].outcome_ind ,
          temp_lh_pat_enc_outcomes->encs[patencntrcnt ].outcome = lh_pat_enc_outcomes->encs[d.seq ].
          outcome
         WITH nocounter
        ;end select
        SET stat = moverec (temp_lh_pat_enc_outcomes ,lh_pat_enc_outcomes )
        SET stat = initrec (temp_lh_pat_enc_outcomes )
        SET rec_size = size (lh_pat_enc_outcomes->encs ,5 )
        SET start_not_done = locateval (num ,1 ,rec_size ,0 ,lh_pat_enc_outcomes->encs[num ].
         outcome_ind )
        SET start_done = locateval (num ,1 ,rec_size ,1 ,lh_pat_enc_outcomes->encs[num ].outcome_ind
         )
        SET start_exclude = locateval (num ,1 ,rec_size ,2 ,lh_pat_enc_outcomes->encs[num ].
         outcome_ind )
        IF ((start_not_done != 0 )
        AND (start_done != 0 ) )
         IF ((start_exclude != 0 ) )
          SET move_to = (start_exclude - 1 )
         ELSE
          SET move_to = rec_size
         ENDIF
         SET stat = movereclist (lh_pat_enc_outcomes->encs ,lh_pat_enc_outcomes->encs ,
          start_not_done ,move_to ,(start_done - start_not_done ) ,true )
         SET stat = alterlist (lh_pat_enc_outcomes->encs ,rec_size ,0 )
        ENDIF
        FOR (patencntrcnt = 1 TO size (lh_pat_enc_outcomes->encs ,5 ) )
         SET r = (rpt->reports[rptcnt ].tables[tblcnt ].row_cnt + 1 )
         SET rpt->reports[rptcnt ].tables[tblcnt ].row_cnt = r
         SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows ,r )
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cell_cnt = 7
         SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells ,7 )
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].value = lh_pat_enc_outcomes->
         encs[patencntrcnt ].name
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].value = lh_pat_enc_outcomes->
         encs[patencntrcnt ].mrn
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].value = lh_pat_enc_outcomes->
         encs[patencntrcnt ].birth_date
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = lh_pat_enc_outcomes->
         encs[patencntrcnt ].visit_date
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = lh_pat_enc_outcomes->
         encs[patencntrcnt ].fin
         IF ((lh_pat_enc_outcomes->encs[patencntrcnt ].outcome_ind = 1 ) )
          SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "Yes"
         ELSEIF ((lh_pat_enc_outcomes->encs[patencntrcnt ].outcome_ind IN (2 ,
         4 ) ) )
          SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "N/A"
         ELSEIF ((lh_pat_enc_outcomes->encs[patencntrcnt ].outcome_ind = 3 ) )
          SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "Exception"
         ELSE
          SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[6 ].value = "No"
         ENDIF
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[7 ].value = lh_pat_enc_outcomes->
         encs[patencntrcnt ].outcome
        ENDFOR
        SET stat = initrec (lh_pat_enc_outcomes )
       ELSE
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cell_cnt = 5
        SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells ,5 )
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].value = "Patient Name"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].width = 125
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].value = "MRN"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].width = 20
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].value = "Date of Birth"
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].width = 50
        IF ((uses_outcome_numeric (ep_report->eps[ep ].measures[md ].reportmean ) = 1 ) )
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "TTR%"
        ELSE
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "Numerator"
        ENDIF
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].width = 20
        IF ((uses_outcome_numeric (ep_report->eps[ep ].measures[md ].reportmean ) = 1 ) )
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = "Remarks"
        ELSE
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = "Outcome"
        ENDIF
        SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].width = 80
        FOR (p = 1 TO ep_report->eps[ep ].measures[md ].patient_cnt )
         SET r = (rpt->reports[rptcnt ].tables[tblcnt ].row_cnt + 1 )
         SET rpt->reports[rptcnt ].tables[tblcnt ].row_cnt = r
         SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows ,r )
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cell_cnt = 5
         SET stat = alterlist (rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells ,5 )
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[1 ].value = ep_report->eps[ep ].
         measures[md ].patients[p ].name
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[2 ].value = ep_report->eps[ep ].
         measures[md ].patients[p ].mrn
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[3 ].value = ep_report->eps[ep ].
         measures[md ].patients[p ].birth_date
         IF ((uses_outcome_numeric (ep_report->eps[ep ].measures[md ].reportmean ) = 1 ) )
          SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = build (cnvtstring (
            ep_report->eps[ep ].measures[md ].patients[p ].outcome_numeric ,6 ,2 ) ,"%" )
         ELSE
          IF ((ep_report->eps[ep ].measures[md ].patients[p ].outcome_ind = 1 ) )
           SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "Yes"
          ELSEIF ((ep_report->eps[ep ].measures[md ].patients[p ].outcome_ind IN (2 ,
          4 ) ) )
           SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "N/A"
          ELSEIF ((ep_report->eps[ep ].measures[md ].patients[p ].outcome_ind = 3 ) )
           SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "Exception"
          ELSE
           SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[4 ].value = "No"
          ENDIF
         ENDIF
         SET rpt->reports[rptcnt ].tables[tblcnt ].rows[r ].cells[5 ].value = ep_report->eps[ep ].
         measures[md ].patients[p ].outcome
        ENDFOR
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
  SET end_time = cnvtdatetime (curdate ,curtime3 )
  CALL lhprint (build ("End time of AddReport: " ,format (end_time ,";;q" ) ) )
  CALL lhprint (build ("Elapsed time of AddReport: " ,datetimediff (end_time ,start_time ,5 ) ) )
  CALL lhprint (" " )
 END ;Subroutine
 SUBROUTINE  getmeasurename (reportmean )
  DECLARE measurename = vc WITH noconstant ("" ) ,protect
  DECLARE measnum = vc WITH noconstant ("" ) ,protect
  DECLARE measdesc = vc WITH noconstant ("" ) ,protect
  CASE (cnvtupper (reportmean ) )
   OF "MU_EC_0004_2019.1.1" :
    SET measurename =
    "NQF-0004.1/CMS-137v7 (Age 13-17):  Alcohol/Drug Dependence Treatment Initiation"
   OF "MU_EC_0004_2019.1.2" :
    SET measurename =
    "NQF-0004.1/CMS-137v7 (Age 18 +):  Alcohol/Drug Dependence Treatment Initiation"
   OF "MU_EC_0004_2019.1.3" :
    SET measurename =
    "NQF-0004.1/CMS-137v7 (Combined Population Total):  Alcohol/Drug Dependence Treatment Initi"
   OF "MU_EC_0004_2019.2.1" :
    SET measurename =
    "NQF-0004.2/CMS-137v7 (Age 13-17):  Alcohol/Drug Dependence Treatment Engagement"
   OF "MU_EC_0004_2019.2.2" :
    SET measurename =
    "NQF-0004.2/CMS-137v7 (Age 18 +):  Alcohol/Drug Dependence Treatment Engagement"
   OF "MU_EC_0004_2019.2.3" :
    SET measurename =
    "NQF-0004.2/CMS-137v7 (Combined Population Total):  Alcohol/Drug Dependence Treatment Eng"
   OF "MU_EC_0022_2019.1" :
    SET measurename = "NQF-0022.1/CMS-156v7 = Drugs to be Avoided in the Elderly"
   OF "MU_EC_0022_2019.2" :
    SET measurename = "NQF-0022.2/CMS-156v7 = Drugs to be Avoided in the Elderly"
   OF "MU_EC_0024_2019.1.1" :
    SET measurename = "NQF-0024.1/CMS-155v7 (POP 1) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.1.2" :
    SET measurename = "NQF-0024.1/CMS-155v7 (POP 2) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.1.3" :
    SET measurename =
    "NQF-0024.1/CMS-155v7 (Combined Population Total) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.2.1" :
    SET measurename = "NQF-0024.2/CMS-155v7 (POP 1) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.2.2" :
    SET measurename = "NQF-0024.2/CMS-155v7 (POP 2) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.2.3" :
    SET measurename =
    "NQF-0024.2/CMS-155v7 (Combined Population Total) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.3.1" :
    SET measurename = "NQF-0024.3/CMS-155v7 (POP 1) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.3.2" :
    SET measurename = "NQF-0024.3/CMS-155v7 (POP 2) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0024_2019.3.3" :
    SET measurename =
    "NQF-0024.3/CMS-155v7 (Combined Population Total) = Wt Assess for Children and Adolescents"
   OF "MU_EC_0028_2019.1" :
    SET measurename =
    "NQF-0028.1/CMS-138v7 (POP 1) = Tobacco Use:  Screening & Cessation Intervention"
   OF "MU_EC_0028_2019.2" :
    SET measurename =
    "NQF-0028.2/CMS-138v7 (POP 2) = Tobacco Use:  Screening & Cessation Intervention"
   OF "MU_EC_0028_2019.3" :
    SET measurename =
    "NQF-0028.3/CMS-138v7 (POP 3) = Tobacco Use:  Screening & Cessation Intervention"
   OF "MU_EC_0033_2019.1" :
    SET measurename = "NQF-0033.1/CMS-153v7 Chlamydia Screening for Women"
   OF "MU_EC_0033_2019.2" :
    SET measurename = "NQF-0033.2/CMS-153v7 Chlamydia Screening for Women"
   OF "MU_EC_0033_2019.3" :
    SET measurename =
    "NQF-0033.3/CMS-153v7 (Combined Population Total) Chlamydia Screening for Women"
   OF "MU_EC_0070_2019.1" :
    SET measurename =
    "NQF-0070.1/CMS-145v7 = Coronary Artery Disease (CAD):  Beta-Blocker Therapy- Prior MI"
   OF "MU_EC_0070_2019.2" :
    SET measurename =
    "NQF-0070.2/CMS-145v7 = Coronary Artery Disease (CAD):  Beta-Blocker Therapy- Prior MI"
   OF "MU_EC_0081_2019.1" :
    SET measurename =
    "NQF-0081.1/CMS-135v7 (PERSON LEVEL) = (HF):  ACE/ARB Therapy for LVSD-Outpatient"
   OF "MU_EC_0081_2019.2" :
    SET measurename =
    "NQF-0081.2/CMS-135v7 (ENCOUNTER LEVEL) = (HF):  ACE/ARB Therapy for LVSD-Inpatient"
   OF "MU_EC_0083_2019.1" :
    SET measurename =
    "NQF-0083.1/CMS-144v7 (PERSON LEVEL) = (HF):  Beta-Blocker Therapy for LVSD-Outpatient"
   OF "MU_EC_0083_2019.2" :
    SET measurename =
    "NQF-0083.2/CMS-144v7 (ENCOUNTER LEVEL) = (HF):  Beta-Blocker Therapy for LVSD-Inpatient"
   OF "MU_EC_0384_2019.1" :
    SET measurename =
    "NQF-0384.1 (POP 1)/CMS-157v7 = Medical and Radiation - Pain Intensity Quantified"
   OF "MU_EC_0384_2019.2" :
    SET measurename =
    "NQF-0384.2 (POP 2)/CMS-157v7 = Medical and Radiation - Pain Intensity Quantified"
   OF "MU_EC_0710_2019.1" :
    SET measurename = "NQF-0710.1/CMS-159v7 (age 12-17):  Depression Remission at Twelve Months"
   OF "MU_EC_0710_2019.2" :
    SET measurename = "NQF-0710.2/CMS-159v7 (age 18+):  Depression Remission at Twelve Months"
   OF "MU_EC_0710_2019.3" :
    SET measurename =
    "NQF-0710.3/CMS-159v7 (Combined Population Total):  Depression Remission at Twelve Months"
   OF "MU_EC_0712_2019.1.1" :
    SET measurename =
    "NQF-0712.1/CMS-160v7 (Sep-Dec, POP 1):  Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_0712_2019.1.2" :
    SET measurename =
    "NQF-0712.1/CMS-160v7 (Sep-Dec, POP 2):  Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_0712_2019.1.3" :
    SET measurename =
    "NQF-0712.1/CMS-160v7 (Sep-Dec, Combined Population Total):  Depression Utilize/PHQ-9 Tool"
   OF "MU_EC_0712_2019.2.1" :
    SET measurename =
    "NQF-0712.2/CMS-160v7 (May-Aug, POP 1):  Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_0712_2019.2.2" :
    SET measurename =
    "NQF-0712.2/CMS-160v7 (May-Aug, POP 2):  Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_0712_2019.2.3" :
    SET measurename =
    "NQF-0712.2/CMS-160v7 (May-Aug, Combined Population Total):  Depression Utilize/PHQ-9 Tool"
   OF "MU_EC_0712_2019.3.1" :
    SET measurename =
    "NQF-0712.3/CMS-160v7 (Jan-Apr, POP 1): Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_0712_2019.3.2" :
    SET measurename =
    "NQF-0712.3/CMS-160v7 (Jan-Apr, POP 2): Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_0712_2019.3.3" :
    SET measurename =
    "NQF-0712.3/CMS-160v7 (Jan-Apr, Combined Total Population): Depression Utilization of the PHQ-9 Tool"
   OF "MU_EC_CMS74_2019.1" :
    SET measurename = "CMS74.1v8 (age 0-5): Primary Caries Prevention Intervention"
   OF "MU_EC_CMS74_2019.2" :
    SET measurename = "CMS74.2v8 (age 6-12): Primary Caries Prevention Intervention"
   OF "MU_EC_CMS74_2019.3" :
    SET measurename = "CMS74.3v8 (age 13-20): Primary Caries Prevention Intervention"
   OF "MU_EC_CMS74_2019.4" :
    SET measurename =
    "CMS74.4v8 (Combined Population Total): Primary Caries Prevention Intervention"
   ELSE
    SELECT INTO "nl:"
     FROM (br_datamart_report bdr )
     WHERE (bdr.report_mean = reportmean )
     DETAIL
      measurename = bdr.report_name
     WITH nocounter
    ;end select
    SET meas_size = size (measurename ,1 )
    SET measnum = substring (1 ,(findstring ("=" ,measurename ,1 ,0 ) - 1 ) ,measurename )
    SET measdesc = substring (findstring ("=" ,measurename ,1 ,0 ) ,meas_size ,measurename )
    SET measurename = build2 (measnum ,getcmsversion (trim (reportmean ) ) ," " ,measdesc )
  ENDCASE
  RETURN (measurename )
 END ;Subroutine
 SUBROUTINE  getpwx_info (null )
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "MU_EP" )
   AND (di.info_name = "MU_EP_PWX" )
   DETAIL
    pwx_ind = 1
   WITH nocounter
  ;end select
  IF ((reqinfo->updt_id = 0 )
  AND (pwx_ind = 1 ) )
   SELECT INTO "nl:"
    FROM (prsnl p )
    WHERE (p.username = curuser )
    AND (p.active_ind = 1 )
    DETAIL
     pwx_user_id = p.person_id
    WITH nocounter
   ;end select
  ELSEIF ((pwx_ind = 1 ) )
   SET pwx_user_id = reqinfo->updt_id
  ENDIF
  IF ((params->orgfilter = - (1 ) )
  AND (pwx_ind = 1 ) )
   SELECT INTO "nl:"
    FROM (organization o ),
     (prsnl p ),
     (prsnl_org_reltn po )
    WHERE (o.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (o.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (o.active_ind = 1 )
    AND (p.person_id = pwx_user_id )
    AND (o.logical_domain_id = p.logical_domain_id )
    AND (po.person_id = p.person_id )
    AND (po.organization_id = o.organization_id )
    AND (po.active_ind = 1 )
    AND (po.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (po.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    ORDER BY o.org_name ,
     o.organization_id
    HEAD o.org_name
     dummy = 0
    HEAD o.organization_id
     org_id_parser = concat (org_id_parser ,"," ,trim (cnvtstring (o.organization_id ) ) )
    FOOT REPORT
     org_id_parser = concat (org_id_parser ,")" ) ,
     org_id_parser = trim (replace (org_id_parser ,"," ,"" ,1 ) ,3 )
    WITH nocounter
   ;end select
  ELSEIF ((pwx_ind = 1 ) )
   SET org_id_parser = concat (org_id_parser ,trim (cnvtstring (params->orgfilter ) ) ,")" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  setorgidparser (null )
  DECLARE iter = i4 WITH protect ,noconstant (0 )
  IF ((pwx_ind = 1 ) )
   IF ((params->orgfilter = - (1 ) ) )
    SELECT INTO "nl:"
     FROM (organization o ),
      (prsnl_org_reltn po ),
      (br_eligible_provider bep )
     PLAN (bep
      WHERE expand (iter ,1 ,size (params->eps ,5 ) ,bep.br_eligible_provider_id ,params->eps[iter ].
       br_eligible_provider_id ) )
      JOIN (po
      WHERE (po.person_id = bep.provider_id )
      AND (po.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
      AND (po.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (po.active_ind = 1 ) )
      JOIN (o
      WHERE (o.organization_id = po.organization_id )
      AND (o.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
      AND (o.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (o.active_ind = 1 ) )
     ORDER BY o.organization_id
     HEAD REPORT
      org_id_parser = "POP.organization_id in("
     HEAD o.organization_id
      org_id_parser = build2 (org_id_parser ,build (o.organization_id ) ,"," )
     FOOT REPORT
      org_id_parser = replace (org_id_parser ,"," ,")" ,2 )
     WITH nocounter ,expand = 1
    ;end select
   ELSE
    SET org_id_parser = build2 ("POP.organization_id = " ,build (params->orgfilter ) )
   ENDIF
  ELSE
   SET org_id_parser = "1=1"
  ENDIF
 END ;Subroutine
 SUBROUTINE  setldparser (params )
  IF ((size (params->eps ,5 ) > 0 ) )
   SELECT INTO "nl:"
    ld_id = params->eps[d.seq ].logical_domain_id
    FROM (dummyt d WITH seq = size (params->eps ,5 ) )
    ORDER BY ld_id
    HEAD REPORT
     logical_domain_id_parser = "p.logical_domain_id IN ("
    HEAD ld_id
     logical_domain_id_parser = build2 (logical_domain_id_parser ,build (ld_id ) ,"," )
    FOOT REPORT
     logical_domain_id_parser = replace (logical_domain_id_parser ,"," ,")" ,2 )
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE  addsubmeasures (null )
  DECLARE i = i4 WITH noconstant (1 ) ,protect
  DECLARE repmeanstring = vc WITH noconstant ("" ) ,protect
  WHILE ((i <= params->measure_cnt ) )
   SET repmeanstring = cnvtupper (params->measures[i ].mean )
   CASE (repmeanstring )
    OF "MU_EC_0004_2019" :
     CALL insertsubmeasures (repmeanstring ,6 ,i )
    OF "MU_EC_0022_2019" :
    OF "MU_EC_0070_2019" :
    OF "MU_EC_0081_2019" :
    OF "MU_EC_0083_2019" :
    OF "MU_EC_0384_2019" :
     CALL insertsubmeasures (repmeanstring ,2 ,i )
    OF "MU_EC_0024_2019" :
    OF "MU_EC_0712_2019" :
     CALL insertsubmeasures (repmeanstring ,9 ,i )
    OF "MU_EC_0033_2019" :
    OF "MU_EC_0710_2019" :
    OF "MU_EC_0028_2019" :
     CALL insertsubmeasures (repmeanstring ,3 ,i )
    OF "MU_EC_CMS74_2019" :
     CALL insertsubmeasures (repmeanstring ,4 ,i )
   ENDCASE
   SET i = (i + 1 )
  ENDWHILE
 END ;Subroutine
 SUBROUTINE  insertsubmeasures (primarymeasure ,totalsubmeasures ,posin )
  DECLARE measurestoadd = i4 WITH constant ((totalsubmeasures - 1 ) ) ,protect
  DECLARE submeasurecount = i4 WITH noconstant (1 ) ,protect
  DECLARE i = i4 WITH noconstant (posin ) ,protect
  IF ((cnvtupper (params->measures[posin ].mean ) IN ("MU_EC_0024_2019" ,
  "MU_EC_0712_2019" ) ) )
   SET params->measure_cnt = (params->measure_cnt + measurestoadd )
   SET stat = alterlist (params->measures ,params->measure_cnt )
   SET params->measures[i ].mean = build (params->measures[i ].mean ,".1.1" )
   SET pos = params->measure_cnt
   WHILE ((pos > (i + measurestoadd ) ) )
    SET params->measures[pos ].mean = params->measures[(pos - measurestoadd ) ].mean
    SET pos = (pos - 1 )
   ENDWHILE
   SET params->measures[(i + 1 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".1.2" )
   SET params->measures[(i + 2 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".1.3" )
   SET params->measures[(i + 3 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".2.1" )
   SET params->measures[(i + 4 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".2.2" )
   SET params->measures[(i + 5 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".2.3" )
   SET params->measures[(i + 6 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".3.1" )
   SET params->measures[(i + 7 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".3.2" )
   SET params->measures[(i + 8 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".3.3" )
  ELSEIF ((cnvtupper (params->measures[posin ].mean ) = "MU_EC_0004_2019" ) )
   SET params->measure_cnt = (params->measure_cnt + measurestoadd )
   SET stat = alterlist (params->measures ,params->measure_cnt )
   SET params->measures[i ].mean = build (params->measures[i ].mean ,".1.1" )
   SET pos = params->measure_cnt
   WHILE ((pos > (i + measurestoadd ) ) )
    SET params->measures[pos ].mean = params->measures[(pos - measurestoadd ) ].mean
    SET pos = (pos - 1 )
   ENDWHILE
   SET params->measures[(i + 1 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".1.2" )
   SET params->measures[(i + 2 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".1.3" )
   SET params->measures[(i + 3 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".2.1" )
   SET params->measures[(i + 4 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".2.2" )
   SET params->measures[(i + 5 ) ].mean = replace (params->measures[i ].mean ,".1.1" ,".2.3" )
  ELSE
   IF ((primarymeasure != "" )
   AND (totalsubmeasures > 1 ) )
    IF ((cnvtupper (params->measures[posin ].mean ) = cnvtupper (primarymeasure ) ) )
     SET params->measure_cnt = (params->measure_cnt + measurestoadd )
     SET stat = alterlist (params->measures ,params->measure_cnt ,posin )
     SET i = posin
     WHILE ((i <= (posin + measurestoadd ) ) )
      SET params->measures[i ].mean = build (cnvtupper (primarymeasure ) ,"." ,submeasurecount )
      SET submeasurecount = (submeasurecount + 1 )
      SET i = (i + 1 )
     ENDWHILE
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  removedummyitem (rec_name ,ind_type )
  DECLARE i = i4 WITH noconstant (1 ) ,protect
  DECLARE j = i4 WITH noconstant (0 ) ,protect
  DECLARE arr_size = i4 WITH noconstant (size (rec_name->persons ,5 ) ) ,protect
  DECLARE nencs = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";removeDummyItem" )
  CALL lhprint (";Record Structure name__________: LH_EP_REPLY" )
  CALL lhprint (build2 (";Size before removing records__________: " ,arr_size ) )
  IF ((ind_type = "exclude_ind" ) )
   FOR (i = arr_size TO 1 BY - (1 ) )
    IF ((rec_name->persons[i ].exclude_ind = 1 ) )
     SET arr_size = (arr_size - 1 )
     SET stat = alterlist (rec_name->persons ,arr_size ,(i - 1 ) )
    ELSE
     SET nencs = size (rec_name->persons[i ].encntrs ,5 )
     FOR (j = nencs TO 1 BY - (1 ) )
      IF ((rec_name->persons[i ].encntrs[j ].exclude_ind = 1 ) )
       SET nencs = (nencs - 1 )
       SET stat = alterlist (rec_name->persons[i ].encntrs ,nencs ,(j - 1 ) )
      ENDIF
     ENDFOR
     IF ((nencs = 0 ) )
      SET arr_size = (arr_size - 1 )
      SET stat = alterlist (rec_name->persons ,arr_size ,(i - 1 ) )
     ELSE
      SET rec_name->persons[i ].encntr_cnt = nencs
     ENDIF
    ENDIF
   ENDFOR
  ELSEIF ((ind_type = "ep_ind" ) )
   FOR (i = arr_size TO 1 BY - (1 ) )
    IF ((((rec_name->persons[i ].ep_ind = 0 ) ) OR ((rec_name->persons[i ].exclude_ind = 1 ) )) )
     SET arr_size = (arr_size - 1 )
     SET stat = alterlist (rec_name->persons ,arr_size ,(i - 1 ) )
    ELSE
     SET nencs = size (rec_name->persons[i ].encntrs ,5 )
     FOR (j = nencs TO 1 BY - (1 ) )
      IF ((rec_name->persons[i ].encntrs[j ].exclude_ind = 1 ) )
       SET nencs = (nencs - 1 )
       SET stat = alterlist (rec_name->persons[i ].encntrs ,nencs ,(j - 1 ) )
      ENDIF
     ENDFOR
     IF ((nencs = 0 ) )
      SET arr_size = (arr_size - 1 )
      SET stat = alterlist (rec_name->persons ,arr_size ,(i - 1 ) )
     ELSE
      SET rec_name->persons[i ].encntr_cnt = nencs
     ENDIF
    ENDIF
   ENDFOR
  ELSE
   CALL lhprint (build2 ("ERROR: removeDummyItem doesn't support this indicator: " ,ind_type ) )
  ENDIF
  CALL lhprint (build2 (";Size after removing records__________" ,arr_size ) )
  SET rec_name->person_cnt = arr_size
 END ;Subroutine
 SUBROUTINE  get_measure_list (rec )
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_report bdr )
   PLAN (bdc
    WHERE (bdc.category_mean = category_mean ) )
    JOIN (bdr
    WHERE (bdr.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (bdr.report_seq > 0 )
    AND (bdr.report_mean IN ("MU_EC_0004_2019" ,
    "MU_EC_0018_2019" ,
    "MU_EC_0022_2019" ,
    "MU_EC_0024_2019" ,
    "MU_EC_0028_2019" ,
    "MU_EC_0032_2019" ,
    "MU_EC_0033_2019" ,
    "MU_EC_0034_2019" ,
    "MU_EC_0038_2019" ,
    "MU_EC_0041_2019" ,
    "MU_EC_0055_2019" ,
    "MU_EC_0059_2019" ,
    "MU_EC_0062_2019" ,
    "MU_EC_0069_2019" ,
    "MU_EC_0070_2019" ,
    "MU_EC_0081_2019" ,
    "MU_EC_0083_2019" ,
    "MU_EC_0101_2019" ,
    "MU_EC_0104_2019" ,
    "MU_EC_0384_2019" ,
    "MU_EC_0418_2019" ,
    "MU_EC_0419_2019" ,
    "MU_EC_0421_2019" ,
    "MU_EC_0710_2019" ,
    "MU_EC_0712_2019" ,
    "MU_EC_1365_2019" ,
    "MU_EC_2372_2019" ,
    "MU_EC_2872_2019" ,
    "MU_EC_CMS22_2019" ,
    "MU_EC_CMS50_2019" ,
    "MU_EC_CMS74_2019" ,
    "MU_EC_CMS75_2019" ,
    "MU_EC_CMS82_2019" ,
    "MU_EC_CMS90_2019" ,
    "MU_EC_CMS127_2019" ,
    "MU_EC_CMS146_2019" ) ) )
   ORDER BY bdr.report_seq
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (rec->measure_cnt + 1 ) ,
    rec->measure_cnt = cnt ,
    stat = alterlist (rec->measures ,cnt ) ,
    rec->measures[cnt ].mean = bdr.report_mean
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  calcoutcomesortkey (outcome )
  DECLARE sortkey = i2 WITH protect ,noconstant (0 )
  CASE (outcome )
   OF - (1 ) :
   OF 4 :
    SET sortkey = 1
   OF 2 :
    SET sortkey = 2
   OF 1 :
    SET sortkey = 3
   OF 3 :
    SET sortkey = 4
   OF 0 :
    SET sortkey = 5
   ELSE
    SET sortkey = 9
  ENDCASE
  RETURN (sortkey )
 END ;Subroutine
 SUBROUTINE  getepsemptyrpt (null )
  CALL lhprint ("; getEPsEmptyRpt" )
  CALL beg_time (0 )
  CALL lhprint (" " )
  CALL lhprint (" " )
  IF ((params->report_by = "CPC" ) )
   CALL lhprint (
    "; *** Note : No patient has qualified for any of the CPCs chosen for the measures chosen. *** "
    )
   CALL lhprint (
    "; ***        We will still display all the CPCs chosen with zero count                    *** "
    )
   SELECT INTO "NL:"
    FROM (dummyt d1 WITH seq = params->ep_cnt ),
     (br_cpc bc )
    PLAN (d1
     WHERE (params->ep_cnt > 0 ) )
     JOIN (bc
     WHERE (bc.br_cpc_id = params->eps[d1.seq ].br_eligible_provider_id ) )
    ORDER BY bc.br_cpc_id
    HEAD REPORT
     epcnt = 0 ,
     total_ep_cnt = 1000 ,
     stat = alterlist (ep_report->eps ,total_ep_cnt )
    HEAD bc.br_cpc_id
     epcnt = (ep_report->ep_cnt + 1 ) ,ep_report->ep_cnt = epcnt ,
     IF ((epcnt > total_ep_cnt ) ) total_ep_cnt = (total_ep_cnt + 1000 ) ,stat = alterlist (ep_report
       ->eps ,total_ep_cnt )
     ENDIF
     ,ep_report->eps[epcnt ].br_eligible_provider_id = bc.br_cpc_id ,ep_report->eps[epcnt ].name = bc
     .br_cpc_name ,ep_report->eps[epcnt ].tax_id_nbr_txt = bc.tax_id_nbr_txt ,ep_report->eps[epcnt ].
     npi_nbr_txt = bc.cpc_site_id_txt ,
     FOR (i = 1 TO params->measure_cnt )
      stat = alterlist (ep_report->eps[epcnt ].measures ,params->measure_cnt ) ,ep_report->eps[epcnt
      ].measure_cnt = params->measure_cnt ,ep_report->eps[epcnt ].measures[i ].reportmean =
      substring (1 ,25 ,params->measures[i ].mean )
     ENDFOR
    FOOT REPORT
     stat = alterlist (ep_report->eps ,epcnt )
    WITH nocounter
   ;end select
  ELSE
   CALL lhprint (
    "; *** Note : No patient has qualified for any of the EPs chosen for the measures chosen. *** "
    )
   CALL lhprint (
    "; ***        We will still display all the EPs chosen with zero count                    *** "
    )
   SELECT INTO "NL:"
    FROM (dummyt d1 WITH seq = params->ep_cnt ),
     (br_eligible_provider ep ),
     (prsnl pl ),
     (br_gpro_reltn gr ),
     (br_gpro g )
    PLAN (d1
     WHERE (params->ep_cnt > 0 ) )
     JOIN (ep
     WHERE (ep.br_eligible_provider_id = params->eps[d1.seq ].br_eligible_provider_id ) )
     JOIN (pl
     WHERE (pl.person_id = ep.provider_id ) )
     JOIN (gr
     WHERE (gr.active_ind = 1 )
     AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (gr.parent_entity_id = ep.br_eligible_provider_id ) )
     JOIN (g
     WHERE (g.active_ind = 1 )
     AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (g.br_gpro_id = gr.br_gpro_id ) )
    ORDER BY ep.provider_id ,
     g.br_gpro_id
    HEAD REPORT
     epcnt = 0 ,
     total_ep_cnt = 1000 ,
     stat = alterlist (ep_report->eps ,total_ep_cnt )
    HEAD ep.provider_id
     dummy = 0
    HEAD g.br_gpro_id
     epcnt = (ep_report->ep_cnt + 1 ) ,ep_report->ep_cnt = epcnt ,
     IF ((epcnt > total_ep_cnt ) ) total_ep_cnt = (total_ep_cnt + 1000 ) ,stat = alterlist (ep_report
       ->eps ,total_ep_cnt )
     ENDIF
     ,ep_report->eps[epcnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_report->eps[
     epcnt ].provider_id = ep.provider_id ,ep_report->eps[epcnt ].name = pl.name_full_formatted ,
     ep_report->eps[epcnt ].tax_id_nbr_txt = g.tax_id_nbr_txt ,ep_report->eps[epcnt ].npi_nbr_txt =
     ep.national_provider_nbr_txt ,
     FOR (i = 1 TO params->measure_cnt )
      stat = alterlist (ep_report->eps[epcnt ].measures ,params->measure_cnt ) ,ep_report->eps[epcnt
      ].measure_cnt = params->measure_cnt ,ep_report->eps[epcnt ].measures[i ].reportmean =
      substring (1 ,25 ,params->measures[i ].mean ) ,ep_report->eps[epcnt ].measures[i ].nnums = 0 ,
      ep_report->eps[epcnt ].measures[i ].ndens = 0 ,ep_report->eps[epcnt ].measures[i ].nexcs = 0 ,
      ep_report->eps[epcnt ].measures[i ].percent = 0
     ENDFOR
    FOOT REPORT
     stat = alterlist (ep_report->eps ,epcnt )
    WITH nocounter
   ;end select
  ENDIF
  CALL lhprint (" " )
  CALL lhprint (" " )
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  setfluseason (null )
  SET beg_year = datetimepart (cnvtdatetime (beg_extract_dt_tm ) ,1 )
  SET end_year = datetimepart (cnvtdatetime (end_extract_dt_tm ) ,1 )
  IF ((beg_year = end_year ) )
   SET beg_extract_dt_tm_41 = datetimeadd (cnvtdatetime (build ("01-JAN-" ,beg_year ) ) ,- (92 ) )
   SET end_extract_dt_tm_41 = datetimeadd (cnvtdatetime (build ("01-JAN-" ,end_year ," 23:59:59" ) )
    ,89 )
   CALL lhprint (build ("Report NQF41 flu season start:" ,format (beg_extract_dt_tm_41 ,";;q" ) ) )
   CALL lhprint (build ("Report NQF41 flu season end:" ,format (end_extract_dt_tm_41 ,";;q" ) ) )
  ELSE
   SET rpt->status = "F"
   SET rpt->message = "Select the date range in one calendar year"
   CALL lhprint (
    "ERROR: Unable to set report NQF41 flu season! Please select the date range in one calendar year."
    )
  ENDIF
 END ;Subroutine
 SUBROUTINE  determineepsfromprompt (paramtypein ,epfilter ,orgfilter ,rec )
  DECLARE success = i2 WITH protect ,noconstant (1 )
  DECLARE lnum = i4 WITH protect ,noconstant (0 )
  DECLARE paramtype = vc WITH protect ,noconstant (paramtypein )
  IF ((paramtype = " " ) )
   SET success = 0
  ELSE
   IF ((paramtype = "L" ) )
    SET lnum = 1
    WHILE ((lnum > 0 ) )
     SET paramtype = reflect (parameter (10 ,lnum ) )
     IF ((paramtype = " " ) )
      SET lnum = 0
     ELSE
      SET rec->ep_cnt = lnum
      SET stat = alterlist (rec->eps ,lnum )
      SET rec->eps[lnum ].br_eligible_provider_id = cnvtreal (parameter (10 ,lnum ) )
      IF ((lnum = 1 ) )
       SET log_ep_string = build (rec->eps[lnum ].br_eligible_provider_id )
      ELSE
       SET log_ep_string = build (log_ep_string ,"," ,rec->eps[lnum ].br_eligible_provider_id )
      ENDIF
      SET lnum = (lnum + 1 )
     ENDIF
    ENDWHILE
    IF ((params->report_by = "CPC" ) )
     CALL getcpcunits (0 )
    ENDIF
   ELSEIF ((paramtype = "F" ) )
    SET rec->ep_cnt = 1
    SET stat = alterlist (rec->eps ,1 )
    SET rec->eps[1 ].br_eligible_provider_id = cnvtreal (parameter (10 ,0 ) )
    SET log_ep_string = build (log_ep_string ,rec->eps[1 ].br_eligible_provider_id )
    IF ((params->report_by = "CPC" ) )
     CALL getcpcunits (0 )
    ENDIF
   ELSEIF ((paramtype = "I" ) )
    IF ((value (parameter (10 ,0 ) ) = - (1 ) ) )
     IF ((params->report_by = "CPC" ) )
      SET log_ep_string = "All CPCs selected"
      CALL getcpclist (0 )
      CALL getcpcunits (0 )
     ENDIF
    ELSE
     SET success = 0
    ENDIF
   ELSE
    SET success = 0
   ENDIF
  ENDIF
  RETURN (success )
 END ;Subroutine
 SUBROUTINE  determinemeasuresfromprompt (paramtypein ,rec )
  DECLARE success = i2 WITH protect ,noconstant (1 )
  DECLARE lnum = i4 WITH protect ,noconstant (0 )
  DECLARE paramtype = vc WITH protect ,noconstant (paramtypein )
  IF ((trim (paramtype ,3 ) = "" ) )
   SET success = 0
  ELSE
   IF ((paramtype = "L" ) )
    SET lnum = 1
    WHILE ((lnum > 0 ) )
     SET paramtype = reflect (parameter (7 ,lnum ) )
     IF ((paramtype = " " ) )
      SET lnum = 0
     ELSE
      SET rec->measure_cnt = lnum
      SET stat = alterlist (rec->measures ,lnum )
      SET rec->measures[lnum ].mean = parameter (7 ,lnum )
      SET lnum = (lnum + 1 )
     ENDIF
    ENDWHILE
   ELSEIF ((paramtype = "C" ) )
    IF ((value (parameter (7 ,0 ) ) = "ALL" ) )
     SET log_measure_string = "ALL"
     IF ((params->report_by = "CPC" ) )
      CALL getallcpcmeasures (0 )
     ELSE
      CALL get_measure_list (rec )
     ENDIF
    ELSEIF ((size (parameter (7 ,0 ) ,1 ) = 1 ) )
     SET success = 0
    ELSE
     SET rec->measure_cnt = 1
     SET stat = alterlist (rec->measures ,1 )
     SET rec->measures[1 ].mean = parameter (7 ,0 )
    ENDIF
   ELSE
    SET success = 0
   ENDIF
  ENDIF
  IF ((log_measure_string = "" ) )
   FOR (i = 1 TO rec->measure_cnt )
    IF ((i = 1 ) )
     SET log_measure_string = build (rec->measures[1 ].mean )
    ELSE
     SET log_measure_string = concat (log_measure_string ,"," ,rec->measures[i ].mean )
    ENDIF
   ENDFOR
  ENDIF
  RETURN (success )
 END ;Subroutine
 SUBROUTINE  sync_prompt_ep_measures (rec )
  DECLARE has_measures = i2 WITH protect ,noconstant (0 )
  DECLARE has_ep_measures = i2 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  IF ((size (rec->measures ,5 ) > 0 ) )
   SET has_measures = 1
  ENDIF
  FOR (i = 1 TO size (rec->eps ,5 ) )
   IF ((size (rec->eps[i ].measures ,5 ) > 0 ) )
    SET has_ep_measures = 1
   ENDIF
  ENDFOR
  IF ((has_measures = 1 )
  AND (has_ep_measures = 0 ) )
   FOR (i = 1 TO size (rec->eps ,5 ) )
    SET rec->eps[i ].measure_cnt = rec->measure_cnt
    SET stat = alterlist (rec->eps[i ].measures ,rec->measure_cnt )
    SET rec->eps[i ].measure_string = rec->measure_string
    FOR (j = 1 TO rec->measure_cnt )
     SET rec->eps[i ].measures[j ].mean = rec->measures[j ].mean
    ENDFOR
   ENDFOR
  ELSEIF ((has_ep_measures = 1 ) )
   FOR (i = 1 TO size (rec->eps ,5 ) )
    FOR (j = 1 TO size (rec->eps[i ].measures ,5 ) )
     SET pos = locateval (num ,1 ,size (rec->measures ,5 ) ,rec->eps[i ].measures[j ].mean ,rec->
      measures[num ].mean )
     IF ((pos = 0 ) )
      SET rec->measure_cnt = (rec->measure_cnt + 1 )
      SET stat = alterlist (rec->measures ,rec->measure_cnt )
      SET rec->measures[rec->measure_cnt ].mean = rec->eps[i ].measures[j ].mean
     ENDIF
    ENDFOR
   ENDFOR
  ENDIF
  SET rec->measure_string = build_measure_string ("TOP" ,0 ,rec )
  FOR (i = 1 TO size (rec->eps ,5 ) )
   SET rec->eps[i ].measure_string = build_measure_string ("EP" ,cnvtint (i ) ,rec )
  ENDFOR
 END ;Subroutine
 SUBROUTINE  sync_prompt_grp_measures (rec )
  DECLARE has_measures = i2 WITH protect ,noconstant (0 )
  DECLARE has_ep_measures = i2 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  IF ((size (rec->measures ,5 ) > 0 ) )
   SET has_measures = 1
  ENDIF
  FOR (i = 1 TO size (rec->grps ,5 ) )
   IF ((size (rec->grps[i ].measures ,5 ) > 0 ) )
    SET has_ep_measures = 1
   ENDIF
  ENDFOR
  IF ((has_measures = 1 )
  AND (has_ep_measures = 0 ) )
   FOR (i = 1 TO size (rec->grps ,5 ) )
    SET rec->grps[i ].measure_cnt = rec->measure_cnt
    SET stat = alterlist (rec->grps[i ].measures ,rec->measure_cnt )
    SET rec->grps[i ].measure_string = rec->measure_string
    FOR (j = 1 TO rec->measure_cnt )
     SET rec->grps[i ].measures[j ].mean = rec->measures[j ].mean
    ENDFOR
   ENDFOR
  ELSEIF ((has_ep_measures = 1 ) )
   FOR (i = 1 TO size (rec->grps ,5 ) )
    FOR (j = 1 TO size (rec->grps[i ].measures ,5 ) )
     SET pos = locateval (num ,1 ,size (rec->measures ,5 ) ,rec->grps[i ].measures[j ].mean ,rec->
      measures[num ].mean )
     IF ((pos = 0 ) )
      SET rec->measure_cnt = (rec->measure_cnt + 1 )
      SET stat = alterlist (rec->measures ,rec->measure_cnt )
      SET rec->measures[rec->measure_cnt ].mean = rec->grps[i ].measures[j ].mean
     ENDIF
    ENDFOR
   ENDFOR
  ENDIF
  SET rec->measure_string = build_measure_string ("TOP" ,0 ,rec )
  FOR (i = 1 TO size (rec->grps ,5 ) )
   SET rec->grps[i ].measure_string = build_measure_string ("GRP" ,cnvtint (i ) ,rec )
  ENDFOR
 END ;Subroutine
 SUBROUTINE  build_measure_string (levelstring ,pos ,rec )
  DECLARE temp_string = vc WITH protect ,noconstant ("" )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE posint = i4 WITH protect ,noconstant (cnvtint (pos ) )
  CASE (cnvtupper (levelstring ) )
   OF "TOP" :
   OF "BASE" :
    FOR (i = 1 TO size (rec->measures ,5 ) )
     IF ((i = 1 ) )
      SET temp_string = build (rec->measures[1 ].mean )
     ELSE
      SET temp_string = build (temp_string ,"," ,rec->measures[i ].mean )
     ENDIF
    ENDFOR
   OF "EP" :
   OF "EPS" :
    FOR (i = 1 TO size (rec->eps[posint ].measures ,5 ) )
     IF ((i = 1 ) )
      SET temp_string = build (rec->eps[posint ].measures[1 ].mean )
     ELSE
      SET temp_string = build (temp_string ,"," ,rec->eps[posint ].measures[i ].mean )
     ENDIF
    ENDFOR
   OF "GRP" :
   OF "GRPS" :
    FOR (i = 1 TO size (rec->grps[posint ].measures ,5 ) )
     IF ((i = 1 ) )
      SET temp_string = build (rec->grps[posint ].measures[1 ].mean )
     ELSE
      SET temp_string = build (temp_string ,"," ,rec->grps[posint ].measures[i ].mean )
     ENDIF
    ENDFOR
  ENDCASE
  SET temp_string = replace (temp_string ,",," ,"," )
  RETURN (temp_string )
 END ;Subroutine
 SUBROUTINE  populate_measures_from_string (in_string ,levelstring ,pos ,rec )
  DECLARE ind = i2 WITH protect ,noconstant (1 )
  DECLARE loc = i4 WITH protect ,noconstant (0 )
  DECLARE start_pos = i4 WITH protect ,noconstant (1 )
  DECLARE cnt = i4 WITH protect ,noconstant (0 )
  DECLARE posint = i4 WITH protect ,noconstant (cnvtint (pos ) )
  DECLARE len = i4 WITH protect ,noconstant (0 )
  CASE (cnvtupper (levelstring ) )
   OF "TOP" :
   OF "BASE" :
    WHILE ((ind = 1 ) )
     SET loc = findstring ("," ,trim (in_string ,3 ) ,start_pos ,0 )
     IF ((loc > 0 ) )
      SET cnt = (cnt + 1 )
      SET len = (loc - start_pos )
      SET stat = alterlist (rec->measures ,cnt )
      SET rec->measure_cnt = cnt
      SET rec->measures[cnt ].mean = substring (start_pos ,len ,trim (in_string ,3 ) )
      SET start_pos = (loc + 1 )
     ELSE
      SET ind = 0
      SET cnt = (cnt + 1 )
      SET len = (size (trim (in_string ,3 ) ) - start_pos )
      SET stat = alterlist (rec->measures ,cnt )
      SET rec->measure_cnt = cnt
      SET rec->measures[cnt ].mean = substring (start_pos ,(len + 1 ) ,trim (in_string ,3 ) )
     ENDIF
    ENDWHILE
   OF "EP" :
   OF "EPS" :
    WHILE ((ind = 1 ) )
     SET loc = findstring ("," ,trim (in_string ,3 ) ,start_pos ,0 )
     IF ((loc > 0 ) )
      SET cnt = (cnt + 1 )
      SET len = (loc - start_pos )
      SET stat = alterlist (rec->eps[posint ].measures ,cnt )
      SET rec->eps[posint ].measure_cnt = cnt
      SET rec->eps[posint ].measures[cnt ].mean = substring (start_pos ,len ,trim (in_string ,3 ) )
      SET start_pos = (loc + 1 )
     ELSE
      SET ind = 0
      SET cnt = (cnt + 1 )
      SET len = (size (trim (in_string ,3 ) ) - start_pos )
      SET stat = alterlist (rec->eps[posint ].measures ,cnt )
      SET rec->eps[posint ].measure_cnt = cnt
      SET rec->eps[posint ].measures[cnt ].mean = substring (start_pos ,(len + 1 ) ,trim (in_string ,
        3 ) )
     ENDIF
    ENDWHILE
   OF "GRP" :
   OF "GRPS" :
    WHILE ((ind = 1 ) )
     SET loc = findstring ("," ,trim (in_string ,3 ) ,start_pos ,0 )
     IF ((loc > 0 ) )
      SET cnt = (cnt + 1 )
      SET len = (loc - start_pos )
      SET stat = alterlist (rec->grps[posint ].measures ,cnt )
      SET rec->grps[posint ].measure_cnt = cnt
      SET rec->grps[posint ].measures[cnt ].mean = substring (start_pos ,len ,trim (in_string ,3 ) )
      SET start_pos = (loc + 1 )
     ELSE
      SET ind = 0
      SET cnt = (cnt + 1 )
      SET len = (size (trim (in_string ,3 ) ) - start_pos )
      SET stat = alterlist (rec->grps[posint ].measures ,cnt )
      SET rec->grps[posint ].measure_cnt = cnt
      SET rec->grps[posint ].measures[cnt ].mean = substring (start_pos ,(len + 1 ) ,trim (in_string
        ,3 ) )
     ENDIF
    ENDWHILE
  ENDCASE
 END ;Subroutine
 SUBROUTINE  getreportmean (report_mean )
  DECLARE rmean = vc WITH noconstant ("" ) ,protect
  IF ((report_mean = "MU_EC_CMS*" ) )
   SET rmean = replace (report_mean ,"MU_EC_CMS" ,"CMS " )
  ELSE
   SET rmean = replace (report_mean ,"MU_EC_" ,"NQF " )
  ENDIF
  SET rmean = replace (rmean ,"_2019" ,"" )
  SET rmean = replace (rmean ,"_" ," " )
  CASE (rmean )
   OF "NQF 0024.1.1" :
    SET rmean = "NQF 0024.1 (POP 1)"
   OF "NQF 0024.2.1" :
    SET rmean = "NQF 0024.2 (POP 1)"
   OF "NQF 0024.3.1" :
    SET rmean = "NQF 0024.3 (POP 1)"
   OF "NQF 0024.1.2" :
    SET rmean = "NQF 0024.1 (POP 2)"
   OF "NQF 0024.2.2" :
    SET rmean = "NQF 0024.2 (POP 2)"
   OF "NQF 0024.3.2" :
    SET rmean = "NQF 0024.3 (POP 2)"
   OF "NQF 0024.1.3" :
    SET rmean = "NQF 0024.1 (POP TOTAL)"
   OF "NQF 0024.2.3" :
    SET rmean = "NQF 0024.2 (POP TOTAL)"
   OF "NQF 0024.3.3" :
    SET rmean = "NQF 0024.3 (POP TOTAL)"
   OF "NQF 0004.1.1" :
    SET rmean = "NQF 0004.1 (POP 1)"
   OF "NQF 0004.2.1" :
    SET rmean = "NQF 0004.2 (POP 1)"
   OF "NQF 0004.3.1" :
    SET rmean = "NQF 0004.3 (POP 1)"
   OF "NQF 0004.1.2" :
    SET rmean = "NQF 0004.1 (POP 2)"
   OF "NQF 0004.2.2" :
    SET rmean = "NQF 0004.2 (POP 2)"
   OF "NQF 0004.3.2" :
    SET rmean = "NQF 0004.3 (POP 2)"
   OF "NQF 0004.1.3" :
    SET rmean = "NQF 0004.1 (POP TOTAL)"
   OF "NQF 0004.2.3" :
    SET rmean = "NQF 0004.2 (POP TOTAL)"
   OF "NQF 0004.3.3" :
    SET rmean = "NQF 0004.3 (POP TOTAL)"
   OF "NQF 0712.1.1" :
    SET rmean = "NQF 0712.1 (POP 1)"
   OF "NQF 0712.2.1" :
    SET rmean = "NQF 0712.2 (POP 1)"
   OF "NQF 0712.3.1" :
    SET rmean = "NQF 0712.3 (POP 1)"
   OF "NQF 0712.1.2" :
    SET rmean = "NQF 0712.1 (POP 2)"
   OF "NQF 0712.2.2" :
    SET rmean = "NQF 0712.2 (POP 2)"
   OF "NQF 0712.3.2" :
    SET rmean = "NQF 0712.3 (POP 2)"
   OF "NQF 0712.1.3" :
    SET rmean = "NQF 0712.1 (POP TOTAL)"
   OF "NQF 0712.2.3" :
    SET rmean = "NQF 0712.1 (POP TOTAL)"
   OF "NQF 0712.3.3" :
    SET rmean = "NQF 0712.3 (POP Total)"
  ENDCASE
  RETURN (rmean )
 END ;Subroutine
 SUBROUTINE  stripdotafter (orig_str )
  DECLARE newstr = vc WITH noconstant ("" ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  SET pos = findstring ("." ,orig_str )
  IF ((pos = 0 ) )
   SET newstr = orig_str
  ELSE
   SET newstr = substring (1 ,(pos - 1 ) ,orig_str )
  ENDIF
  RETURN (newstr )
 END ;Subroutine
 SUBROUTINE  get_rpt_dt_range_prompt (opt_initiative ,year ,qtr_year ,start_dt ,end_dt )
  DECLARE return_string = vc WITH protect ,noconstant ("" )
  SET beg_extract_dt_tm = 0
  SET end_extract_dt_tm = 0
  IF ((opt_initiative = "90_DAY" ) )
   IF ((((datetimepart (cnvtdatetime (start_dt ) ,2 ) < 10 ) ) OR ((datetimepart (cnvtdatetime (
     start_dt ) ,2 ) = 10 )
   AND (datetimepart (cnvtdatetime (start_dt ) ,3 ) < 4 ) )) )
    SET beg_extract_dt_tm = cnvtdatetime (start_dt )
    SET end_extract_dt_tm = datetimeadd (cnvtdatetime (cnvtdate (start_dt ) ,235959 ) ,89 )
   ELSE
    SET return_string =
    "The 90 day period must be within the current calendar year. Select a reporting period start date prior to Oct 4."
   ENDIF
  ELSEIF ((opt_initiative = "CUSTTF" ) )
   IF ((datetimediff (cnvtdatetime (start_dt ) ,cnvtdatetime (end_dt ) ) > 0 ) )
    SET return_string = "The start date must be prior to the end date."
   ELSE
    SET beg_extract_dt_tm = cnvtdatetime (start_dt )
    SET end_extract_dt_tm = cnvtdatetime (cnvtdate (end_dt ) ,235959 )
   ENDIF
  ELSEIF ((opt_initiative = "YEAR" ) )
   IF ((isnumeric (year ) != 1 ) )
    SET return_string = "Report year was not specified."
   ELSE
    SET beg_extract_dt_tm = cnvtdatetime (build ("01-JAN-" ,year ) )
    SET end_extract_dt_tm = cnvtdatetime (build ("31-DEC-" ,year ," 23:59:59" ) )
   ENDIF
  ELSEIF ((opt_initiative = "QTR_YEAR" ) )
   IF ((qtr_year = "JAN" ) )
    SET beg_extract_dt_tm = cnvtdatetime (build ("01-JAN-2019" ) )
    SET end_extract_dt_tm = cnvtdatetime (build ("31-MAR-2019 23:59:59" ) )
   ELSEIF ((qtr_year = "APR" ) )
    SET beg_extract_dt_tm = cnvtdatetime (build ("01-APR-2019" ) )
    SET end_extract_dt_tm = cnvtdatetime (build ("30-JUN-2019 23:59:59" ) )
   ELSEIF ((qtr_year = "JUL" ) )
    SET beg_extract_dt_tm = cnvtdatetime (build ("01-JUL-2019" ) )
    SET end_extract_dt_tm = cnvtdatetime (build ("30-SEP-2019 23:59:59" ) )
   ELSEIF ((qtr_year = "OCT" ) )
    SET beg_extract_dt_tm = cnvtdatetime (build ("01-OCT-2019" ) )
    SET end_extract_dt_tm = cnvtdatetime (build ("31-DEC-2019 23:59:59" ) )
   ELSE
    SET return_string = "An invalid quarter-year start month was specified."
   ENDIF
  ENDIF
  IF ((datetimetrunc (cnvtdatetime (beg_extract_dt_tm ) ,"YY" ) != datetimetrunc (cnvtdatetime (
    end_extract_dt_tm ) ,"YY" ) ) )
   SET return_string = "The measurement period must be within the same calendar year."
  ENDIF
  RETURN (return_string )
 END ;Subroutine
 SUBROUTINE  month_check (prior_date ,later_date ,no_of_months ,within_range )
  DECLARE success = i2 WITH protect ,noconstant (1 )
  DECLARE duration = i2 WITH protect ,noconstant (- (1 ) )
  IF ((no_of_months < 0 ) )
   SET success = 0
  ELSE
   IF ((later_date >= prior_date ) )
    IF ((day (later_date ) >= day (prior_date ) ) )
     SET duration = ((((year (later_date ) - year (prior_date ) ) * 12 ) + month (later_date ) ) -
     month (prior_date ) )
    ELSE
     IF ((day (later_date ) < day (prior_date ) ) )
      SET duration = ((((year (later_date ) - year (prior_date ) ) * 12 ) + (month (later_date ) -
      month (prior_date ) ) ) - 1 )
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF ((((within_range = 1 )
  AND (duration <= no_of_months )
  AND (duration >= 0 ) ) OR ((within_range = 0 )
  AND (duration >= no_of_months ) )) )
   SET success = 1
  ELSE
   SET success = 0
  ENDIF
  RETURN (success )
 END ;Subroutine
 SUBROUTINE  check_npi_tin (ep_report )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE warning_str = vc WITH noconstant ("" ) ,protect
  CALL lhprint ("" )
  CALL lhprint ("; check_npi_tin starts" )
  FOR (num = 1 TO size (ep_report->eps ,5 ) )
   IF ((((trim (ep_report->eps[num ].tax_id_nbr_txt ) = "" ) ) OR ((trim (ep_report->eps[num ].
    npi_nbr_txt ) = "" ) )) )
    SET warning_str = build2 (";WARNING: QRDA unqualifying provider (provider_id=" ,build (ep_report
      ->eps[num ].provider_id ) ,"  br_eligible_provider_id=" ,build (ep_report->eps[num ].
      br_eligible_provider_id ) ,"): lacking NPI or TIN!" )
    CALL lhprint ("" )
    CALL lhprint (warning_str )
   ENDIF
  ENDFOR
  CALL lhprint ("" )
  CALL lhprint ("; check_npi_tin ends" )
  CALL lhprint ("" )
 END ;Subroutine
 SUBROUTINE  getgrant_script (myobject_name )
  SELECT INTO "NL:"
   object = substring (1 ,1 ,g.rest ) ,
   object_name = substring (2 ,30 ,g.rest ) ,
   group = ichar (substring (32 ,1 ,g.rest ) ) ,
   rdboptval = evaluate (substring (274 ,6 ,g.data ) ,"<sec1>" ,ichar (substring (248 ,1 ,g.data ) )
    ,0 ) ,
   rdboptqry = evaluate (substring (274 ,6 ,g.data ) ,"<sec1>" ,substring (249 ,25 ,g.data ) ,
    fillstring (25 ,char (0 ) ) ) ,
   rdbopt = evaluate (substring (274 ,6 ,g.data ) ,"<sec1>" ,"Y" ,"N" )
   FROM (dgeneric g WITH access_code = "5" ,user_code = none )
   WHERE (g.platform = "H0000" )
   AND (g.rcode = "5" )
   AND (g.rest = patstring (concat ("P" ,trim (myobject_name ) ,"*" ) ) )
   AND (evaluate (substring (274 ,6 ,g.data ) ,"<sec1>" ,band (ichar (substring (248 ,1 ,g.data ) ) ,
     15 ) ,0 ) BETWEEN 0 AND 15 )
   ORDER BY object_name
   HEAD object_name
    IF ((cnvtupper (object_name ) = myobject_name ) ) obj_grant_var = build ("; OBJECT GRANT   :" ,
      myobject_name ,"(" ,evaluate (rdbopt ,"Y" ,"RULE" ,"N" ,"NONE" ) ,")" )
    ENDIF
   WITH nocounter
  ;end select
  CALL lhprint (obj_grant_var )
 END ;Subroutine
 SUBROUTINE  calvalidhic (hic_nbr )
  DECLARE alphanum_ind = i2 WITH noconstant (0 )
  DECLARE all_9 = i2 WITH protect ,noconstant (0 )
  DECLARE good_alphanum = i2 WITH protect ,noconstant (0 )
  DECLARE length_ind = i2 WITH protect ,noconstant (0 )
  DECLARE hicstring = vc WITH protect ,noconstant ("" )
  DECLARE return_var = i2 WITH protect ,noconstant (0 )
  DECLARE alpha_str = vc WITH noconstant (cnvtalphanum (hicstring ,2 ) )
  DECLARE num_str = vc WITH noconstant (cnvtalphanum (hicstring ,1 ) )
  SET hicstring = cnvtupper (cnvtalphanum (hic_nbr ) )
  IF ((size (alpha_str ) != 0 )
  AND (size (num_str ) != 0 ) )
   IF ((size (hicstring ) = (size (alpha_str ) + size (num_str ) ) ) )
    SET alphanum_ind = 1
   ENDIF
  ENDIF
  IF ((size (hicstring ) BETWEEN 7 AND 12 ) )
   SET length_ind = 1
  ENDIF
  IF ((alphanum_ind = 1 ) )
   IF ((hicstring = fillstring (value (size (hicstring ) ) ,"9" ) ) )
    SET all_9 = 1
   ENDIF
  ENDIF
  IF ((size (hicstring ) = 7 ) )
   IF ((substring (1 ,1 ,hicstring ) = alpha_str )
   AND (substring (2 ,size (hicstring ) ,hicstring ) = num_str ) )
    SET good_alphanum = 1
   ENDIF
  ELSEIF ((size (hicstring ) = 8 ) )
   IF ((substring (1 ,2 ,hicstring ) = alpha_str )
   AND (substring (3 ,size (hicstring ) ,hicstring ) = num_str ) )
    SET good_alphanum = 1
   ENDIF
  ELSEIF ((size (hicstring ) = 9 ) )
   IF ((substring (1 ,3 ,hicstring ) = alpha_str )
   AND (substring (4 ,size (hicstring ) ,hicstring ) = num_str ) )
    SET good_alphanum = 1
   ENDIF
  ELSEIF ((size (hicstring ) = 10 ) )
   IF ((substring (1 ,1 ,hicstring ) = alpha_str )
   AND (substring (2 ,size (hicstring ) ,hicstring ) = num_str ) )
    SET good_alphanum = 1
   ELSEIF ((substring (1 ,9 ,hicstring ) = num_str )
   AND (substring (10 ,1 ,hicstring ) = alpha_str ) )
    SET good_alphanum = 1
   ENDIF
  ELSEIF ((size (hicstring ) = 11 ) )
   IF ((substring (1 ,2 ,hicstring ) = alpha_str )
   AND (substring (3 ,size (hicstring ) ,hicstring ) = num_str ) )
    SET good_alphanum = 1
   ELSEIF ((substring (1 ,9 ,hicstring ) = num_str )
   AND (substring (10 ,2 ,hicstring ) = alpha_str ) )
    SET good_alphanum = 1
   ELSEIF ((substring (1 ,9 ,hicstring ) = substring (1 ,9 ,num_str ) )
   AND (substring (10 ,1 ,hicstring ) = alpha_str )
   AND (substring (11 ,1 ,hicstring ) = substring (10 ,1 ,num_str ) ) )
    SET good_alphanum = 1
   ENDIF
  ELSEIF ((size (hicstring ) = 12 ) )
   IF ((substring (1 ,3 ,hicstring ) = alpha_str )
   AND (substring (4 ,size (hicstring ) ,hicstring ) = num_str ) )
    SET good_alphanum = 1
   ENDIF
  ENDIF
  IF ((alphanum_ind = 1 )
  AND (length_ind = 1 )
  AND (all_9 = 0 )
  AND (good_alphanum = 1 ) )
   SET return_var = 1
  ENDIF
  RETURN (return_var )
 END ;Subroutine
 SUBROUTINE  retrieve_group_eps (null )
  CALL lhprint ("; Preparing groups and EPs " )
  CALL beg_time (0 )
  DECLARE grp_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE ep_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE param_ep_pos = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  DECLARE num2 = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (br_gpro bg ),
    (br_gpro_reltn bgr ),
    (br_eligible_provider ep ),
    (prsnl pl )
   WHERE (bg.br_gpro_id = bgr.br_gpro_id )
   AND (bgr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (bg.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (bgr.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (bg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (bg.logical_domain_id = logical_domain_id )
   AND expand (num ,1 ,params->grp_cnt ,bg.br_gpro_id ,params->grps[num ].br_gpro_id )
   AND (bgr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
   AND (ep.br_eligible_provider_id = bgr.parent_entity_id )
   AND (bgr.active_ind = 1 )
   AND (bg.active_ind = 1 )
   AND (bg.br_gpro_id > 0 )
   AND (pl.person_id = ep.provider_id )
   ORDER BY bg.br_gpro_id ,
    bgr.br_gpro_reltn_id
   HEAD REPORT
    grp_cnt = 0 ,
    param_ep_cnt = 0
   HEAD bg.br_gpro_id
    i = locateval (num ,1 ,params->grp_cnt ,bg.br_gpro_id ,params->grps[num ].br_gpro_id ) ,params->
    grps[i ].name = bg.br_gpro_name ,params->grps[i ].tax_id_nbr_txt = bg.tax_id_nbr_txt ,grp_cnt = (
    grp_cnt + 1 ) ,stat = alterlist (grp_summary->grps ,grp_cnt ) ,grp_summary->grp_cnt = grp_cnt ,
    grp_summary->grps[grp_cnt ].tax_id_nbr_txt = bg.tax_id_nbr_txt ,grp_summary->grps[grp_cnt ].name
    = bg.br_gpro_name ,grp_summary->grps[grp_cnt ].logical_domain_id = logical_domain_id ,grp_summary
    ->grps[grp_cnt ].br_gpro_id = bg.br_gpro_id ,ep_cnt = 0
   HEAD bgr.br_gpro_reltn_id
    ep_cnt = (ep_cnt + 1 ) ,stat = alterlist (grp_summary->grps[grp_cnt ].eps ,ep_cnt ) ,grp_summary
    ->grps[grp_cnt ].ep_cnt = ep_cnt ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].
    br_eligible_provider_id = ep.br_eligible_provider_id ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].
    provider_id = ep.provider_id ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].name = pl
    .name_full_formatted ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].npi_nbr_txt = ep
    .national_provider_nbr_txt ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].tax_id_nbr_txt = bg
    .tax_id_nbr_txt ,param_ep_pos = locateval (num2 ,1 ,size (params->eps ,5 ) ,ep
     .br_eligible_provider_id ,params->eps[num2 ].br_eligible_provider_id ) ,
    IF ((param_ep_pos = 0 ) ) param_ep_pos = (size (params->eps ,5 ) + 1 ) ,params->ep_cnt =
     param_ep_pos ,stat = alterlist (params->eps ,param_ep_pos ) ,params->eps[param_ep_pos ].
     br_eligible_provider_id = ep.br_eligible_provider_id ,params->eps[param_ep_pos ].npi_nbr_txt =
     ep.national_provider_nbr_txt ,params->eps[param_ep_pos ].name = pl.name_full_formatted ,params->
     eps[param_ep_pos ].logical_domain_id = pl.logical_domain_id
    ENDIF
   WITH nocounter ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  pull_ep_sum_into_grp_sum_forgpro (null )
  CALL lhprint ("; Moving from ep_summary to grp_summary " )
  CALL beg_time (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  DECLARE esum_pt = i4 WITH protect ,noconstant (0 )
  DECLARE esum_en = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  DECLARE esum_ep = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_mez = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_pt = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_en = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO size (grp_summary->grps ,5 ) )
   FOR (j = 1 TO size (grp_summary->grps[i ].eps ,5 ) )
    SET esum_ep = locateval (num ,1 ,ep_summary->ep_cnt ,grp_summary->grps[i ].eps[j ].
     br_eligible_provider_id ,ep_summary->eps[num ].br_eligible_provider_id ,grp_summary->grps[i ].
     tax_id_nbr_txt ,ep_summary->eps[num ].tax_id_nbr_txt )
    WHILE ((esum_ep > 0 ) )
     SET gsum_mez = locateval (num ,1 ,grp_summary->grps[i ].meas_cnt ,ep_summary->eps[esum_ep ].
      reportmean ,grp_summary->grps[i ].measures[num ].report_mean )
     IF ((gsum_mez > 0 ) )
      FOR (esum_pt = 1 TO size (ep_summary->eps[esum_ep ].patients ,5 ) )
       SET gsum_pt = locateval (num ,1 ,size (grp_summary->grps[i ].measures[gsum_mez ].patients ,5
         ) ,ep_summary->eps[esum_ep ].patients[esum_pt ].person_id ,grp_summary->grps[i ].measures[
        gsum_mez ].patients[num ].person_id )
       IF ((gsum_pt = 0 ) )
        SET gsum_pt = (grp_summary->grps[i ].measures[gsum_mez ].patient_cnt + 1 )
        SET grp_summary->grps[i ].measures[gsum_mez ].patient_cnt = gsum_pt
        SET stat = alterlist (grp_summary->grps[i ].measures[gsum_mez ].patients ,gsum_pt )
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].person_id = ep_summary->eps[
        esum_ep ].patients[esum_pt ].person_id
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].name = ep_summary->eps[
        esum_ep ].patients[esum_pt ].name
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].mrn = ep_summary->eps[
        esum_ep ].patients[esum_pt ].mrn
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].birth_date = ep_summary->
        eps[esum_ep ].patients[esum_pt ].birth_date
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].outcome = ep_summary->eps[
        esum_ep ].patients[esum_pt ].outcome
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].outcome_ind = ep_summary->
        eps[esum_ep ].patients[esum_pt ].outcome_ind
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].outcome_numeric = ep_summary
        ->eps[esum_ep ].patients[esum_pt ].outcome_numeric
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].gender = ep_summary->eps[
        esum_ep ].patients[esum_pt ].gender
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].race = ep_summary->eps[
        esum_ep ].patients[esum_pt ].race
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].ethnicity = ep_summary->eps[
        esum_ep ].patients[esum_pt ].ethnicity
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].payer = ep_summary->eps[
        esum_ep ].patients[esum_pt ].payer
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].payer_group = ep_summary->
        eps[esum_ep ].patients[esum_pt ].payer_group
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].hic = ep_summary->eps[
        esum_ep ].patients[esum_pt ].hic
       ENDIF
       FOR (esum_en = 1 TO size (ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs ,5 ) )
        SET gsum_en = locateval (num ,1 ,size (grp_summary->grps[i ].measures[gsum_mez ].patients[
          gsum_pt ].encntrs ,5 ) ,ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].
         encntr_id ,grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[num ].
         encntr_id )
        IF ((gsum_en = 0 ) )
         SET gsum_en = (size (grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs ,
          5 ) + 1 )
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntr_cnt = gsum_en
         SET stat = alterlist (grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs ,
          gsum_en )
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].encntr_id
          = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].encntr_id
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].
         br_eligible_provider_id = ep_summary->eps[esum_ep ].br_eligible_provider_id
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].
         visit_date = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].visit_date
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].fin =
         ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].fin
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].outcome
         = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].outcome
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].
         outcome_ind = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].outcome_ind
        ENDIF
       ENDFOR
      ENDFOR
     ENDIF
     SET esum_ep = locateval (num ,(esum_ep + 1 ) ,ep_summary->ep_cnt ,grp_summary->grps[i ].eps[j ].
      br_eligible_provider_id ,ep_summary->eps[num ].br_eligible_provider_id ,grp_summary->grps[i ].
      tax_id_nbr_txt ,ep_summary->eps[num ].tax_id_nbr_txt )
    ENDWHILE
   ENDFOR
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  pull_ep_sum_into_grp_sum (null )
  CALL lhprint ("; Moving from ep_summary to grp_summary " )
  CALL beg_time (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  DECLARE esum_pt = i4 WITH protect ,noconstant (0 )
  DECLARE esum_en = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  DECLARE esum_ep = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_mez = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_pt = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_en = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO size (grp_summary->grps ,5 ) )
   FOR (j = 1 TO size (grp_summary->grps[i ].eps ,5 ) )
    SET esum_ep = locateval (num ,1 ,ep_summary->ep_cnt ,grp_summary->grps[i ].eps[j ].
     br_eligible_provider_id ,ep_summary->eps[num ].br_eligible_provider_id ,grp_summary->grps[i ].
     tax_id_nbr_txt ,ep_summary->eps[num ].tax_id_nbr_txt )
    WHILE ((esum_ep > 0 ) )
     SET gsum_mez = locateval (num ,1 ,grp_summary->grps[i ].meas_cnt ,ep_summary->eps[esum_ep ].
      reportmean ,grp_summary->grps[i ].measures[num ].report_mean )
     IF ((gsum_mez = 0 ) )
      SET grp_summary->grps[i ].meas_cnt = (grp_summary->grps[i ].meas_cnt + 1 )
      SET gsum_mez = grp_summary->grps[i ].meas_cnt
      SET stat = alterlist (grp_summary->grps[i ].measures ,gsum_mez )
      SET grp_summary->grps[i ].measures[gsum_mez ].report_mean = ep_summary->eps[esum_ep ].
      reportmean
      SET grp_summary->grps[i ].measures[gsum_mez ].percentage = ep_summary->eps[esum_ep ].percent
     ENDIF
     IF ((gsum_mez > 0 ) )
      FOR (esum_pt = 1 TO size (ep_summary->eps[esum_ep ].patients ,5 ) )
       SET gsum_pt = locateval (num ,1 ,size (grp_summary->grps[i ].measures[gsum_mez ].patients ,5
         ) ,ep_summary->eps[esum_ep ].patients[esum_pt ].person_id ,grp_summary->grps[i ].measures[
        gsum_mez ].patients[num ].person_id )
       IF ((gsum_pt = 0 ) )
        SET gsum_pt = (grp_summary->grps[i ].measures[gsum_mez ].patient_cnt + 1 )
        SET grp_summary->grps[i ].measures[gsum_mez ].patient_cnt = gsum_pt
        SET stat = alterlist (grp_summary->grps[i ].measures[gsum_mez ].patients ,gsum_pt )
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].person_id = ep_summary->eps[
        esum_ep ].patients[esum_pt ].person_id
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].name = ep_summary->eps[
        esum_ep ].patients[esum_pt ].name
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].mrn = ep_summary->eps[
        esum_ep ].patients[esum_pt ].mrn
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].birth_date = ep_summary->
        eps[esum_ep ].patients[esum_pt ].birth_date
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].outcome = ep_summary->eps[
        esum_ep ].patients[esum_pt ].outcome
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].outcome_ind = ep_summary->
        eps[esum_ep ].patients[esum_pt ].outcome_ind
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].outcome_numeric = ep_summary
        ->eps[esum_ep ].patients[esum_pt ].outcome_numeric
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].gender = ep_summary->eps[
        esum_ep ].patients[esum_pt ].gender
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].race = ep_summary->eps[
        esum_ep ].patients[esum_pt ].race
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].ethnicity = ep_summary->eps[
        esum_ep ].patients[esum_pt ].ethnicity
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].payer = ep_summary->eps[
        esum_ep ].patients[esum_pt ].payer
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].payer_group = ep_summary->
        eps[esum_ep ].patients[esum_pt ].payer_group
        SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].hic = ep_summary->eps[
        esum_ep ].patients[esum_pt ].hic
       ENDIF
       FOR (esum_en = 1 TO size (ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs ,5 ) )
        SET gsum_en = locateval (num ,1 ,size (grp_summary->grps[i ].measures[gsum_mez ].patients[
          gsum_pt ].encntrs ,5 ) ,ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].
         encntr_id ,grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[num ].
         encntr_id )
        IF ((gsum_en = 0 ) )
         SET gsum_en = (size (grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs ,
          5 ) + 1 )
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntr_cnt = gsum_en
         SET stat = alterlist (grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs ,
          gsum_en )
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].encntr_id
          = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].encntr_id
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].
         br_eligible_provider_id = ep_summary->eps[esum_ep ].br_eligible_provider_id
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].
         visit_date = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].visit_date
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].fin =
         ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].fin
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].outcome
         = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].outcome
         SET grp_summary->grps[i ].measures[gsum_mez ].patients[gsum_pt ].encntrs[gsum_en ].
         outcome_ind = ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].outcome_ind
        ENDIF
       ENDFOR
      ENDFOR
     ENDIF
     SET esum_ep = locateval (num ,(esum_ep + 1 ) ,ep_summary->ep_cnt ,grp_summary->grps[i ].eps[j ].
      br_eligible_provider_id ,ep_summary->eps[num ].br_eligible_provider_id ,grp_summary->grps[i ].
      tax_id_nbr_txt ,ep_summary->eps[num ].tax_id_nbr_txt )
    ENDWHILE
   ENDFOR
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  move_grp_sum_to_ep_sum (null )
  CALL lhprint ("; Moving back to ep_summary from grp_summary " )
  CALL beg_time (0 )
  SET stat = initrec (ep_summary )
  DECLARE gsum_grp = i4 WITH protect ,noconstant (0 )
  DECLARE gsum_mez = i4 WITH protect ,noconstant (0 )
  DECLARE esum_ep = i4 WITH protect ,noconstant (0 )
  DECLARE esum_pt = i4 WITH protect ,noconstant (0 )
  DECLARE esum_en = i4 WITH protect ,noconstant (0 )
  FOR (gsum_grp = 1 TO size (grp_summary->grps ,5 ) )
   FOR (gsum_mez = 1 TO size (grp_summary->grps[gsum_grp ].measures ,5 ) )
    SET esum_ep = (esum_ep + 1 )
    SET ep_summary->ep_cnt = esum_ep
    SET stat = alterlist (ep_summary->eps ,esum_ep )
    SET ep_summary->eps[esum_ep ].br_eligible_provider_id = grp_summary->grps[gsum_grp ].br_gpro_id
    SET ep_summary->eps[esum_ep ].provider_id = grp_summary->grps[gsum_grp ].br_gpro_id
    SET ep_summary->eps[esum_ep ].name = grp_summary->grps[gsum_grp ].name
    SET ep_summary->eps[esum_ep ].tax_id_nbr_txt = grp_summary->grps[gsum_grp ].tax_id_nbr_txt
    SET ep_summary->eps[esum_ep ].reportmean = grp_summary->grps[gsum_grp ].measures[gsum_mez ].
    report_mean
    SET ep_summary->eps[esum_ep ].percent = grp_summary->grps[gsum_grp ].measures[gsum_mez ].
    percentage
    SET ep_summary->eps[esum_ep ].patient_cnt = grp_summary->grps[gsum_grp ].measures[gsum_mez ].
    patient_cnt
    SET stat = alterlist (ep_summary->eps[esum_ep ].patients ,ep_summary->eps[esum_ep ].patient_cnt
     )
    FOR (esum_pt = 1 TO ep_summary->eps[esum_ep ].patient_cnt )
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].person_id = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].person_id
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].name = grp_summary->grps[gsum_grp ].measures[
     gsum_mez ].patients[esum_pt ].name
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].mrn = grp_summary->grps[gsum_grp ].measures[
     gsum_mez ].patients[esum_pt ].mrn
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].birth_date = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].birth_date
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].outcome = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].outcome
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].outcome_ind = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].outcome_ind
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].outcome_numeric = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].outcome_numeric
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].gender = grp_summary->grps[gsum_grp ].measures[
     gsum_mez ].patients[esum_pt ].gender
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].race = grp_summary->grps[gsum_grp ].measures[
     gsum_mez ].patients[esum_pt ].race
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].ethnicity = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].ethnicity
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].payer = grp_summary->grps[gsum_grp ].measures[
     gsum_mez ].patients[esum_pt ].payer
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].payer_group = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].payer_group
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].hic = grp_summary->grps[gsum_grp ].measures[
     gsum_mez ].patients[esum_pt ].hic
     SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntr_cnt = grp_summary->grps[gsum_grp ].
     measures[gsum_mez ].patients[esum_pt ].encntr_cnt
     SET stat = alterlist (ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs ,ep_summary->eps[
      esum_ep ].patients[esum_pt ].encntr_cnt )
     FOR (esum_en = 1 TO ep_summary->eps[esum_ep ].patients[esum_pt ].encntr_cnt )
      SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].br_eligible_provider_id =
      grp_summary->grps[gsum_grp ].measures[gsum_mez ].patients[esum_pt ].encntrs[esum_en ].
      br_eligible_provider_id
      SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].encntr_id = grp_summary->
      grps[gsum_grp ].measures[gsum_mez ].patients[esum_pt ].encntrs[esum_en ].encntr_id
      SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].visit_date = grp_summary->
      grps[gsum_grp ].measures[gsum_mez ].patients[esum_pt ].encntrs[esum_en ].visit_date
      SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].fin = grp_summary->grps[
      gsum_grp ].measures[gsum_mez ].patients[esum_pt ].encntrs[esum_en ].fin
      SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].outcome = grp_summary->grps[
      gsum_grp ].measures[gsum_mez ].patients[esum_pt ].encntrs[esum_en ].outcome
      SET ep_summary->eps[esum_ep ].patients[esum_pt ].encntrs[esum_en ].outcome_ind = grp_summary->
      grps[gsum_grp ].measures[gsum_mez ].patients[esum_pt ].encntrs[esum_en ].outcome_ind
     ENDFOR
    ENDFOR
   ENDFOR
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  removedummyitemexcludeonly (rec_name ,ind_type )
  DECLARE h = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE j = i4 WITH noconstant (0 ) ,protect
  DECLARE neps = i4 WITH noconstant (size (rec_name->eps ,5 ) ) ,protect
  DECLARE npts = i4 WITH noconstant (0 ) ,protect
  DECLARE nencs = i4 WITH noconstant (0 ) ,protect
  IF ((ind_type = "exclude_ind" ) )
   FOR (h = neps TO 1 BY - (1 ) )
    IF ((rec_name->eps[h ].exclude_ind != 1 )
    AND (rec_name->eps[h ].patient_cnt > 0 ) )
     SET npts = size (rec_name->eps[h ].patients ,5 )
     FOR (i = npts TO 1 BY - (1 ) )
      IF ((rec_name->eps[h ].patients[i ].exclude_ind != 1 )
      AND (rec_name->eps[h ].patients[i ].encntr_cnt > 0 ) )
       SET nencs = size (rec_name->eps[h ].patients[i ].encntrs ,5 )
       FOR (j = nencs TO 1 BY - (1 ) )
        IF ((rec_name->eps[h ].patients[i ].encntrs[j ].exclude_ind = 1 ) )
         SET nencs = (nencs - 1 )
         SET stat = alterlist (rec_name->eps[h ].patients[i ].encntrs ,nencs ,(j - 1 ) )
        ENDIF
       ENDFOR
       SET rec_name->eps[h ].patients[i ].encntr_cnt = nencs
      ENDIF
      IF ((((rec_name->eps[h ].patients[i ].exclude_ind = 1 ) ) OR ((rec_name->eps[h ].patients[i ].
      encntr_cnt = 0 ) )) )
       SET npts = (npts - 1 )
       SET stat = alterlist (rec_name->eps[h ].patients ,npts ,(i - 1 ) )
      ENDIF
     ENDFOR
     SET rec_name->eps[h ].patient_cnt = npts
    ENDIF
    IF ((((rec_name->eps[h ].exclude_ind = 1 ) ) OR ((rec_name->eps[h ].patient_cnt = 0 ) )) )
     SET neps = (neps - 1 )
     SET stat = alterlist (rec_name->eps ,neps ,(h - 1 ) )
     SET rec_name->ep_cnt = neps
    ENDIF
   ENDFOR
  ELSE
   CALL lhprint (build2 ("ERROR: removeDummyItemExcludeOnly doesn't support this indicator: " ,
     ind_type ) )
  ENDIF
 END ;Subroutine
 SUBROUTINE  get_all_grp_list (rec )
  CALL lhprint ("; Preparing groups and EPs " )
  CALL beg_time (0 )
  DECLARE num2 = i4 WITH protect ,noconstant (0 )
  DECLARE cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (br_gpro bg ),
    (br_gpro_reltn bgr ),
    (br_eligible_provider ep ),
    (prsnl pl )
   WHERE (bg.br_gpro_id = bgr.br_gpro_id )
   AND (bgr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
   AND (ep.br_eligible_provider_id = bgr.parent_entity_id )
   AND (bgr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (bg.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (bgr.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (bg.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
   AND (pl.person_id = ep.provider_id )
   AND (bg.logical_domain_id = logical_domain_id )
   AND (ep.logical_domain_id = logical_domain_id )
   AND (bgr.active_ind = 1 )
   AND (bg.active_ind = 1 )
   AND (bg.br_gpro_id > 0 )
   ORDER BY bg.br_gpro_id ,
    bgr.br_gpro_reltn_id
   HEAD REPORT
    grp_cnt = 0 ,
    param_ep_cnt = 0
   HEAD bg.br_gpro_id
    grp_cnt = (grp_cnt + 1 ) ,stat = alterlist (grp_summary->grps ,grp_cnt ) ,grp_summary->grp_cnt =
    grp_cnt ,grp_summary->grps[grp_cnt ].tax_id_nbr_txt = bg.tax_id_nbr_txt ,grp_summary->grps[
    grp_cnt ].name = bg.br_gpro_name ,grp_summary->grps[grp_cnt ].logical_domain_id = bg
    .logical_domain_id ,grp_summary->grps[grp_cnt ].br_gpro_id = bg.br_gpro_id ,ep_cnt = 0 ,stat =
    alterlist (params->grps ,grp_cnt ) ,params->grp_cnt = grp_cnt ,params->grps[grp_cnt ].br_gpro_id
    = bg.br_gpro_id ,params->grps[grp_cnt ].name = bg.br_gpro_name ,params->grps[grp_cnt ].
    tax_id_nbr_txt = bg.tax_id_nbr_txt ,params->grps[grp_cnt ].logical_domain_id = bg
    .logical_domain_id
   HEAD bgr.br_gpro_reltn_id
    ep_cnt = (ep_cnt + 1 ) ,stat = alterlist (grp_summary->grps[grp_cnt ].eps ,ep_cnt ) ,grp_summary
    ->grps[grp_cnt ].ep_cnt = ep_cnt ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].
    br_eligible_provider_id = ep.br_eligible_provider_id ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].
    provider_id = ep.provider_id ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].name = pl
    .name_full_formatted ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].npi_nbr_txt = ep
    .national_provider_nbr_txt ,grp_summary->grps[grp_cnt ].eps[ep_cnt ].tax_id_nbr_txt = bg
    .tax_id_nbr_txt ,param_ep_pos = locateval (num2 ,1 ,size (params->eps ,5 ) ,ep
     .br_eligible_provider_id ,params->eps[num2 ].br_eligible_provider_id ) ,
    IF ((param_ep_pos = 0 ) ) param_ep_pos = (size (params->eps ,5 ) + 1 ) ,params->ep_cnt =
     param_ep_pos ,stat = alterlist (params->eps ,param_ep_pos ) ,params->eps[param_ep_pos ].
     br_eligible_provider_id = ep.br_eligible_provider_id ,params->eps[param_ep_pos ].npi_nbr_txt =
     ep.national_provider_nbr_txt ,params->eps[param_ep_pos ].name = pl.name_full_formatted ,params->
     eps[param_ep_pos ].logical_domain_id = pl.logical_domain_id
    ENDIF
   WITH nocounter
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  determine_grps_from_prompt (paramtypein ,rec )
  DECLARE success = i2 WITH protect ,noconstant (1 )
  DECLARE lnum = i4 WITH protect ,noconstant (0 )
  DECLARE paramtype = vc WITH protect ,noconstant (paramtypein )
  IF ((paramtype = " " ) )
   SET success = 0
  ELSE
   IF ((paramtype = "L" ) )
    SET lnum = 1
    WHILE ((lnum > 0 ) )
     SET paramtype = reflect (parameter (10 ,lnum ) )
     IF ((paramtype = " " ) )
      SET lnum = 0
     ELSE
      SET rec->grp_cnt = lnum
      SET stat = alterlist (rec->grps ,lnum )
      SET rec->grps[lnum ].br_gpro_id = cnvtreal (parameter (10 ,lnum ) )
      IF ((lnum = 1 ) )
       SET log_ep_string = build (rec->grps[lnum ].br_gpro_id )
      ELSE
       SET log_ep_string = build (log_ep_string ,"," ,rec->grps[lnum ].br_gpro_id )
      ENDIF
      SET lnum = (lnum + 1 )
     ENDIF
    ENDWHILE
   ELSEIF ((paramtype = "F" ) )
    SET rec->grp_cnt = 1
    SET stat = alterlist (rec->grps ,1 )
    SET rec->grps[1 ].br_gpro_id = cnvtreal (parameter (10 ,0 ) )
    SET log_ep_string = build (log_ep_string ,rec->grps[1 ].br_gpro_id )
   ELSEIF ((paramtype = "I" ) )
    IF ((value (parameter (10 ,0 ) ) = - (1 ) ) )
     SET log_ep_string = "All groups selected"
     CALL get_all_grp_list (rec )
    ELSE
     SET success = 0
    ENDIF
   ELSE
    SET success = 0
   ENDIF
  ENDIF
  RETURN (success )
 END ;Subroutine
 SUBROUTINE  sort_lh_ep_reply (null )
  DECLARE bpcnt = i4 WITH protect ,noconstant (0 )
  DECLARE becnt = i4 WITH protect ,noconstant (0 )
  SET stat = initrec (lh_ep_reply_bk )
  SELECT INTO "nl:"
   pid = lh_ep_reply->persons[d1.seq ].person_id ,
   eid = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].encntr_id
   FROM (dummyt d1 WITH seq = lh_ep_reply->person_cnt ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE (lh_ep_reply->person_cnt > 0 )
    AND maxrec (d2 ,lh_ep_reply->persons[d1.seq ].encntr_cnt ) )
    JOIN (d2
    WHERE (lh_ep_reply->persons[d1.seq ].encntr_cnt > 0 ) )
   ORDER BY pid ,
    eid
   HEAD REPORT
    lh_ep_reply_bk->person_cnt = size (lh_ep_reply->persons ,5 ) ,
    stat = alterlist (lh_ep_reply_bk->persons ,size (lh_ep_reply->persons ,5 ) ) ,
    bpcnt = 0
   HEAD pid
    becnt = 0 ,bpcnt = (bpcnt + 1 ) ,lh_ep_reply_bk->persons[bpcnt ].encntr_cnt = size (lh_ep_reply->
     persons[d1.seq ].encntrs ,5 ) ,stat = alterlist (lh_ep_reply_bk->persons[bpcnt ].encntrs ,size (
      lh_ep_reply->persons[d1.seq ].encntrs ,5 ) ) ,lh_ep_reply_bk->persons[bpcnt ].person_id =
    lh_ep_reply->persons[d1.seq ].person_id ,lh_ep_reply_bk->persons[bpcnt ].recent_encntr_id =
    lh_ep_reply->persons[d1.seq ].recent_encntr_id ,lh_ep_reply_bk->persons[bpcnt ].
    recent_encntr_date = lh_ep_reply->persons[d1.seq ].recent_encntr_date ,lh_ep_reply_bk->persons[
    bpcnt ].recent_encntr_reg_date = lh_ep_reply->persons[d1.seq ].recent_encntr_reg_date ,
    lh_ep_reply_bk->persons[bpcnt ].second_recent_encntr_id = lh_ep_reply->persons[d1.seq ].
    second_recent_encntr_id ,lh_ep_reply_bk->persons[bpcnt ].second_recent_encntr_date = lh_ep_reply
    ->persons[d1.seq ].second_recent_encntr_date ,lh_ep_reply_bk->persons[bpcnt ].first_encntr_id =
    lh_ep_reply->persons[d1.seq ].first_encntr_id ,lh_ep_reply_bk->persons[bpcnt ].first_encntr_date
    = lh_ep_reply->persons[d1.seq ].first_encntr_date ,lh_ep_reply_bk->persons[bpcnt ].last_reg_date
    = lh_ep_reply->persons[d1.seq ].last_reg_date ,lh_ep_reply_bk->persons[bpcnt ].last_disch_date =
    lh_ep_reply->persons[d1.seq ].last_disch_date ,lh_ep_reply_bk->persons[bpcnt ].special_cond_dt_tm
     = lh_ep_reply->persons[d1.seq ].special_cond_dt_tm ,lh_ep_reply_bk->persons[bpcnt ].
    special_cond_a_dt_tm = lh_ep_reply->persons[d1.seq ].special_cond_a_dt_tm ,lh_ep_reply_bk->
    persons[bpcnt ].recent_bmi_amb_event_id = lh_ep_reply->persons[d1.seq ].recent_bmi_amb_event_id ,
    lh_ep_reply_bk->persons[bpcnt ].first_low_back_pblm_date = lh_ep_reply->persons[d1.seq ].
    first_low_back_pblm_date ,lh_ep_reply_bk->persons[bpcnt ].mrn = lh_ep_reply->persons[d1.seq ].mrn
     ,lh_ep_reply_bk->persons[bpcnt ].age = lh_ep_reply->persons[d1.seq ].age ,lh_ep_reply_bk->
    persons[bpcnt ].gender_cd = lh_ep_reply->persons[d1.seq ].gender_cd ,lh_ep_reply_bk->persons[
    bpcnt ].outcome_numeric = lh_ep_reply->persons[d1.seq ].outcome_numeric ,lh_ep_reply_bk->persons[
    bpcnt ].outcome_ind = lh_ep_reply->persons[d1.seq ].outcome_ind ,lh_ep_reply_bk->persons[bpcnt ].
    outcome = lh_ep_reply->persons[d1.seq ].outcome ,lh_ep_reply_bk->persons[bpcnt ].exclude_ind =
    lh_ep_reply->persons[d1.seq ].exclude_ind ,lh_ep_reply_bk->persons[bpcnt ].ep_ind = lh_ep_reply->
    persons[d1.seq ].ep_ind ,lh_ep_reply_bk->persons[bpcnt ].special_group = lh_ep_reply->persons[d1
    .seq ].special_group ,lh_ep_reply_bk->persons[bpcnt ].gender = lh_ep_reply->persons[d1.seq ].
    gender ,lh_ep_reply_bk->persons[bpcnt ].race = lh_ep_reply->persons[d1.seq ].race ,lh_ep_reply_bk
    ->persons[bpcnt ].ethnicity = lh_ep_reply->persons[d1.seq ].ethnicity ,lh_ep_reply_bk->persons[
    bpcnt ].payer = lh_ep_reply->persons[d1.seq ].payer ,lh_ep_reply_bk->persons[bpcnt ].payer_group
    = lh_ep_reply->persons[d1.seq ].payer_group ,lh_ep_reply_bk->persons[bpcnt ].payer_reg_dt_tm =
    lh_ep_reply->persons[d1.seq ].payer_reg_dt_tm ,lh_ep_reply_bk->persons[bpcnt ].hic = lh_ep_reply
    ->persons[d1.seq ].hic
   HEAD eid
    becnt = (becnt + 1 ) ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].encntr_id = lh_ep_reply->
    persons[d1.seq ].encntrs[d2.seq ].encntr_id ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].fin
    = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].fin ,lh_ep_reply_bk->persons[bpcnt ].encntrs[
    becnt ].outcome_ind = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].outcome_ind ,lh_ep_reply_bk
    ->persons[bpcnt ].encntrs[becnt ].outcome = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].
    outcome ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].exclude_ind = lh_ep_reply->persons[d1
    .seq ].encntrs[d2.seq ].exclude_ind ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].ep_ind =
    lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].ep_ind ,lh_ep_reply_bk->persons[bpcnt ].encntrs[
    becnt ].reg_dt_tm = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].reg_dt_tm ,lh_ep_reply_bk->
    persons[bpcnt ].encntrs[becnt ].disch_dt_tm = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].
    disch_dt_tm ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].special_cond_dt_tm = lh_ep_reply->
    persons[d1.seq ].encntrs[d2.seq ].special_cond_dt_tm ,lh_ep_reply_bk->persons[bpcnt ].encntrs[
    becnt ].outpt_ind = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].outpt_ind ,lh_ep_reply_bk->
    persons[bpcnt ].encntrs[becnt ].inpt_ind = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].
    inpt_ind ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].special_group = lh_ep_reply->persons[d1
    .seq ].encntrs[d2.seq ].special_group ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].a1 =
    lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].a1 ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt
    ].a2 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].a2 ,lh_ep_reply_bk->persons[bpcnt ].
    encntrs[becnt ].b1 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].b1 ,lh_ep_reply_bk->persons[
    bpcnt ].encntrs[becnt ].b2 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].b2 ,lh_ep_reply_bk->
    persons[bpcnt ].encntrs[becnt ].c1 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].c1 ,
    lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].c2 = lh_ep_reply->persons[d1.seq ].encntrs[d2
    .seq ].c2 ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].d1 = lh_ep_reply->persons[d1.seq ].
    encntrs[d2.seq ].d1 ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].d2 = lh_ep_reply->persons[d1
    .seq ].encntrs[d2.seq ].d2 ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].e1 = lh_ep_reply->
    persons[d1.seq ].encntrs[d2.seq ].e1 ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt ].e2 =
    lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].e2 ,lh_ep_reply_bk->persons[bpcnt ].encntrs[becnt
    ].f1 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].f1 ,lh_ep_reply_bk->persons[bpcnt ].
    encntrs[becnt ].f2 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].f2 ,lh_ep_reply_bk->persons[
    bpcnt ].encntrs[becnt ].h1 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].h1 ,lh_ep_reply_bk->
    persons[bpcnt ].encntrs[becnt ].h2 = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].h2
   WITH nocounter
  ;end select
  SET stat = initrec (lh_ep_reply )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
 END ;Subroutine
 SUBROUTINE  restrict_ep_sum_to_brdefmeas (sum_rec ,search_rec ,report_by_type )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE provpos = i4 WITH protect ,noconstant (0 )
  DECLARE measpos = i4 WITH protect ,noconstant (0 )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  DECLARE measval = vc WITH protect ,noconstant ("" )
  DECLARE local_type = vc WITH protect ,noconstant ("EPS" )
  IF ((cnvtupper (report_by_type ) IN ("GPRO" ,
  "GRPS" ) ) )
   SET local_type = "GRPS"
  ELSE
   SET local_type = "EPS"
  ENDIF
  FOR (i = 1 TO size (sum_rec->eps ,5 ) )
   SET provpos = 0
   SET measpos = 0
   IF ((local_type = "EPS" ) )
    SET provpos = locateval (num ,1 ,size (search_rec->eps ,5 ) ,sum_rec->eps[i ].
     br_eligible_provider_id ,search_rec->eps[num ].br_eligible_provider_id )
    IF ((provpos > 0 ) )
     SET measval = cnvtupper (stripdotafter (sum_rec->eps[i ].reportmean ) )
     SET measpos = locateval (num ,1 ,size (search_rec->eps[provpos ].measures ,5 ) ,measval ,
      cnvtupper (stripdotafter (search_rec->eps[provpos ].measures[num ].mean ) ) )
    ENDIF
   ELSE
    SET provpos = locateval (num ,1 ,size (search_rec->grps ,5 ) ,sum_rec->eps[i ].
     br_eligible_provider_id ,search_rec->grps[num ].br_gpro_id )
    IF ((provpos > 0 ) )
     SET measval = cnvtupper (stripdotafter (sum_rec->eps[i ].reportmean ) )
     SET measpos = locateval (num ,1 ,size (search_rec->grps[provpos ].measures ,5 ) ,measval ,
      cnvtupper (stripdotafter (search_rec->grps[provpos ].measures[num ].mean ) ) )
    ENDIF
   ENDIF
   IF (NOT ((provpos > 0 )
   AND (measpos > 0 ) ) )
    SET sum_rec->eps[i ].exclude_ind = 1
   ENDIF
  ENDFOR
  CALL removedummyitemexcludeonly (sum_rec ,"exclude_ind" )
 END ;Subroutine
 SUBROUTINE  base_getqrdabrepmeas_list (rec )
  DECLARE temp_meas = vc WITH protect ,noconstant ("" )
  DECLARE ld_parser = vc WITH protect ,noconstant ("ep.logical_domain_id = LOGICAL_DOMAIN_ID" )
  DECLARE success = i2 WITH protect ,noconstant (0 )
  DECLARE meas_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE epcount = i4 WITH protect ,noconstant (0 )
  IF ((pwx_ind = 1 ) )
   SET ld_parser = "1=1"
  ENDIF
  SELECT INTO "nl:"
   FROM (br_eligible_provider ep ),
    (lh_cqm_meas meas ),
    (lh_cqm_meas_svc_entity_r rel ),
    (lh_d_personnel ldp )
   WHERE (ep.br_eligible_provider_id = rel.parent_entity_id )
   AND (rel.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
   AND (meas.lh_cqm_meas_id = rel.lh_cqm_meas_id )
   AND (rel.active_ind = 1 )
   AND (rel.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (rel.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (ep.br_eligible_provider_id != 0 )
   AND parser (ld_parser )
   AND (ldp.person_id = ep.provider_id )
   ORDER BY ep.br_eligible_provider_id ,
    meas.meas_ident
   HEAD REPORT
    success = 1 ,
    epcount = 0
   HEAD ep.br_eligible_provider_id
    epcount = (epcount + 1 ) ,stat = alterlist (rec->eps ,epcount ) ,rec->ep_cnt = epcount ,rec->eps[
    epcount ].br_eligible_provider_id = ep.br_eligible_provider_id ,rec->eps[epcount ].
    logical_domain_id = ep.logical_domain_id ,meas_cnt = 0
   HEAD meas.meas_ident
    IF ((meas.meas_ident = "*2019*" )
    AND (meas.measure_short_desc != "*YQF*" ) ) meas_cnt = (meas_cnt + 1 ) ,rec->eps[epcount ].
     measure_cnt = meas_cnt ,stat = alterlist (rec->eps[epcount ].measures ,meas_cnt ) ,temp_meas =
     cnvtupper (meas.measure_short_desc ) ,
     IF ((findstring ("CMS" ,temp_meas ) > 0 ) ) temp_meas = build ("CMS" ,cnvtint (substring (5 ,(
         size (temp_meas ) - 4 ) ,temp_meas ) ) )
     ELSE temp_meas = replace (temp_meas ,"NQF-" ,"" )
     ENDIF
     ,temp_meas = build ("MU_EC_" ,temp_meas ,"_2019" ) ,rec->eps[epcount ].measures[meas_cnt ].mean
     = temp_meas
    ENDIF
   WITH nocounter
  ;end select
  RETURN (success )
 END ;Subroutine
 SUBROUTINE  base_getqrdabrgrpmeas_list (rec )
  DECLARE success = i2 WITH protect ,noconstant (0 )
  DECLARE temp_meas = vc WITH protect ,noconstant ("" )
  DECLARE ld_parser = vc WITH protect ,noconstant ("bg.logical_domain_id = LOGICAL_DOMAIN_ID" )
  DECLARE meas_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE epcount = i4 WITH protect ,noconstant (0 )
  IF ((pwx_ind = 1 ) )
   SET ld_parser = "1=1"
  ENDIF
  CALL lhprint (";retrieve measures and groups selected in BR, then store them into QRDA_BR_DEF_EP"
   )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (br_eligible_provider ep ),
    (lh_cqm_meas meas ),
    (lh_cqm_meas_svc_entity_r rel ),
    (br_gpro bg ),
    (br_gpro_reltn bgr )
   WHERE (rel.parent_entity_name = "BR_GPRO" )
   AND (rel.parent_entity_id = bg.br_gpro_id )
   AND (meas.lh_cqm_meas_id = rel.lh_cqm_meas_id )
   AND (rel.active_ind = 1 )
   AND (cnvtdatetime (curdate ,curtime3 ) BETWEEN rel.beg_effective_dt_tm AND rel
   .end_effective_dt_tm )
   AND (bg.br_gpro_id != 0 )
   AND (bg.br_gpro_id = bgr.br_gpro_id )
   AND (cnvtdatetime (curdate ,curtime3 ) BETWEEN bgr.beg_effective_dt_tm AND bgr
   .end_effective_dt_tm )
   AND parser (ld_parser )
   AND (bgr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
   AND (ep.br_eligible_provider_id = bgr.parent_entity_id )
   AND (bgr.active_ind = 1 )
   AND (bg.active_ind = 1 )
   AND (bg.br_gpro_id > 0 )
   ORDER BY bg.br_gpro_id ,
    meas.meas_ident
   HEAD REPORT
    success = 1 ,
    epcount = 0
   HEAD bg.br_gpro_id
    epcount = (epcount + 1 ) ,stat = alterlist (rec->eps ,epcount ) ,rec->ep_cnt = epcount ,rec->eps[
    epcount ].br_eligible_provider_id = bg.br_gpro_id ,rec->eps[epcount ].logical_domain_id = bg
    .logical_domain_id ,meas_cnt = 0
   HEAD meas.meas_ident
    IF ((meas.meas_ident = "*2019*" )
    AND (meas.measure_short_desc != "*YQF*" ) ) meas_cnt = (meas_cnt + 1 ) ,rec->eps[epcount ].
     measure_cnt = meas_cnt ,stat = alterlist (rec->eps[epcount ].measures ,meas_cnt ) ,temp_meas =
     cnvtupper (meas.measure_short_desc ) ,
     IF ((findstring ("CMS" ,temp_meas ) > 0 ) ) temp_meas = build ("CMS" ,cnvtint (substring (5 ,(
         size (temp_meas ) - 4 ) ,temp_meas ) ) )
     ELSE temp_meas = replace (temp_meas ,"NQF-" ,"" )
     ENDIF
     ,temp_meas = build ("MU_EC_" ,temp_meas ,"_2019" ) ,rec->eps[epcount ].measures[meas_cnt ].mean
     = temp_meas
    ENDIF
   WITH nocounter
  ;end select
  CALL end_time (0 )
  RETURN (success )
 END ;Subroutine
 SUBROUTINE  copysubmeasures (null )
  DECLARE i = i4 WITH noconstant (1 ) ,protect
  DECLARE j = i4 WITH noconstant (1 ) ,protect
  DECLARE cursize = i2 WITH noconstant (0 ) ,protect
  DECLARE num = i2 WITH protect ,noconstant (0 )
  DECLARE q = i2 WITH protect ,noconstant (0 )
  DECLARE newsize = i2 WITH protect ,noconstant (0 )
  FOR (q = 1 TO size (params->measures ,5 ) )
   FOR (i = 1 TO size (params->eps ,5 ) )
    SET pos = locateval (num ,1 ,size (params->eps[i ].measures ,5 ) ,stripdotafter (params->
      measures[q ].mean ) ,params->eps[i ].measures[num ].mean )
    IF ((pos > 0 ) )
     SET cursize = (size (params->eps[i ].measures ,5 ) + 1 )
     SET stat = alterlist (params->eps[i ].measures ,cursize )
     SET params->eps[i ].measures[cursize ].mean = params->measures[q ].mean
    ENDIF
   ENDFOR
   FOR (i = 1 TO size (params->grps ,5 ) )
    SET pos = locateval (num ,1 ,size (params->grps[i ].measures ,5 ) ,stripdotafter (params->
      measures[q ].mean ) ,params->grps[i ].measures[num ].mean )
    IF ((pos > 0 ) )
     SET cursize = (size (params->grps[i ].measures ,5 ) + 1 )
     SET stat = alterlist (params->grps[i ].measures ,cursize )
     SET params->grps[i ].measures[cursize ].mean = params->measures[q ].mean
    ENDIF
   ENDFOR
  ENDFOR
  FOR (i = 1 TO size (params->eps ,5 ) )
   SET newsize = (size (params->eps[i ].measures ,5 ) - params->eps[i ].measure_cnt )
   SET stat = alterlist (params->eps[i ].measures ,newsize ,0 )
   SET params->eps[i ].measure_cnt = newsize
   SET params->eps[i ].measure_string = build_measure_string ("EP" ,i ,params )
  ENDFOR
  FOR (i = 1 TO size (params->grps ,5 ) )
   SET newsize = (size (params->grps[i ].measures ,5 ) - params->grps[i ].measure_cnt )
   SET stat = alterlist (params->grps[i ].measures ,newsize ,0 )
   SET params->grps[i ].measure_cnt = newsize
   SET params->grps[i ].measure_string = build_measure_string ("GRP" ,i ,params )
  ENDFOR
 END ;Subroutine
 SUBROUTINE  delete_submeasure (submeasure )
  DECLARE i = ui4 WITH protect ,noconstant (1 )
  DECLARE arr_size = ui4 WITH noconstant (size (ep_summary->eps ,5 ) ) ,protect
  FOR (i = arr_size TO 1 BY - (1 ) )
   IF ((ep_summary->eps[i ].reportmean = submeasure ) )
    SET arr_size = (arr_size - 1 )
    SET stat = alterlist (ep_summary->eps ,arr_size ,(i - 1 ) )
   ENDIF
  ENDFOR
  SET ep_summary->ep_cnt = arr_size
 END ;Subroutine
 SUBROUTINE  sum_submeasures (add1 ,add2 ,total )
  DECLARE num = ui4 WITH protect ,noconstant (0 )
  DECLARE ep_pos = ui4 WITH protect ,noconstant (0 )
  DECLARE done = i2 WITH protect ,noconstant (0 )
  DECLARE i_pcnt = ui4 WITH protect ,noconstant (0 )
  DECLARE ep_pos_pcnt = ui4 WITH protect ,noconstant (0 )
  DECLARE i_ecnt = ui4 WITH protect ,noconstant (0 )
  DECLARE ep_pos_ecnt = ui4 WITH protect ,noconstant (0 )
  DECLARE initial_ep_summary_size = ui4 WITH protect ,noconstant (ep_summary->ep_cnt )
  DECLARE i = i4 WITH protect ,noconstant (1 )
  SET ep_summary->ep_cnt = size (ep_summary->eps ,5 )
  IF ((ep_summary->ep_cnt > 0 ) )
   SET i = 1
   FOR (i = 1 TO initial_ep_summary_size )
    IF ((ep_summary->eps[i ].reportmean IN (add1 ,
    add2 ) ) )
     SET done = 0
     SET ep_pos = 0
     IF ((ep_summary->ep_cnt > initial_ep_summary_size ) )
      SET ep_pos = locateval (num ,(initial_ep_summary_size + 1 ) ,ep_summary->ep_cnt ,ep_summary->
       eps[i ].br_eligible_provider_id ,ep_summary->eps[num ].br_eligible_provider_id ,ep_summary->
       eps[i ].tax_id_nbr_txt ,ep_summary->eps[num ].tax_id_nbr_txt )
      WHILE ((done = 0 ) )
       IF ((ep_summary->eps[ep_pos ].reportmean = total ) )
        SET done = 1
       ELSEIF ((ep_pos = 0 ) )
        SET done = 1
       ELSE
        SET ep_pos = locateval (num ,(ep_pos + 1 ) ,ep_summary->ep_cnt ,ep_summary->eps[i ].
         br_eligible_provider_id ,ep_summary->eps[num ].br_eligible_provider_id ,ep_summary->eps[i ].
         tax_id_nbr_txt ,ep_summary->eps[num ].tax_id_nbr_txt )
       ENDIF
      ENDWHILE
     ENDIF
     IF ((ep_pos = 0 ) )
      SET ep_pos = (ep_summary->ep_cnt + 1 )
      SET ep_summary->ep_cnt = ep_pos
      SET stat = alterlist (ep_summary->eps ,ep_pos )
      SET ep_summary->eps[ep_pos ].br_eligible_provider_id = ep_summary->eps[i ].
      br_eligible_provider_id
      SET ep_summary->eps[ep_pos ].provider_id = ep_summary->eps[i ].provider_id
      SET ep_summary->eps[ep_pos ].tax_id_nbr_txt = ep_summary->eps[i ].tax_id_nbr_txt
      SET ep_summary->eps[ep_pos ].gpro_name = ep_summary->eps[i ].gpro_name
      SET ep_summary->eps[ep_pos ].npi_nbr_txt = ep_summary->eps[i ].npi_nbr_txt
      SET ep_summary->eps[ep_pos ].name = ep_summary->eps[i ].name
      SET ep_summary->eps[ep_pos ].reportmean = total
     ENDIF
     FOR (i_pcnt = 1 TO ep_summary->eps[i ].patient_cnt )
      SET ep_pos_pcnt = (ep_summary->eps[ep_pos ].patient_cnt + 1 )
      SET ep_summary->eps[ep_pos ].patient_cnt = ep_pos_pcnt
      SET stat = alterlist (ep_summary->eps[ep_pos ].patients ,ep_pos_pcnt )
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].person_id = ep_summary->eps[i ].patients[
      i_pcnt ].person_id
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].name = ep_summary->eps[i ].patients[i_pcnt
      ].name
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].mrn = ep_summary->eps[i ].patients[i_pcnt ]
      .mrn
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].gender = ep_summary->eps[i ].patients[
      i_pcnt ].gender
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].race = ep_summary->eps[i ].patients[i_pcnt
      ].race
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].ethnicity = ep_summary->eps[i ].patients[
      i_pcnt ].ethnicity
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].payer = ep_summary->eps[i ].patients[
      i_pcnt ].payer
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].payer_group = ep_summary->eps[i ].patients[
      i_pcnt ].payer_group
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].hic = ep_summary->eps[i ].patients[i_pcnt ]
      .hic
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].birth_date = ep_summary->eps[i ].patients[
      i_pcnt ].birth_date
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].outcome_ind = ep_summary->eps[i ].patients[
      i_pcnt ].outcome_ind
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].outcome = ep_summary->eps[i ].patients[
      i_pcnt ].outcome
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].outcome_numeric = ep_summary->eps[i ].
      patients[i_pcnt ].outcome_numeric
      SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].exclude_ind = ep_summary->eps[i ].patients[
      i_pcnt ].exclude_ind
      FOR (i_ecnt = 1 TO ep_summary->eps[i ].patients[i_pcnt ].encntr_cnt )
       SET ep_pos_ecnt = (ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntr_cnt + 1 )
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntr_cnt = ep_pos_ecnt
       SET stat = alterlist (ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs ,ep_pos_ecnt )
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].encntr_id =
       ep_summary->eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].encntr_id
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].
       br_eligible_provider_id = ep_summary->eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].
       br_eligible_provider_id
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].visit_date =
       ep_summary->eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].visit_date
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].fin = ep_summary->
       eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].fin
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].outcome = ep_summary
       ->eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].outcome
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].outcome_ind =
       ep_summary->eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].outcome_ind
       SET ep_summary->eps[ep_pos ].patients[ep_pos_pcnt ].encntrs[ep_pos_ecnt ].exclude_ind =
       ep_summary->eps[i ].patients[i_pcnt ].encntrs[i_ecnt ].exclude_ind
      ENDFOR
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE  run_report_main (null )
  DECLARE param_meas_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE nqf22_ind = i2 WITH protect ,noconstant (0 )
  DECLARE nqf28_ind = i2 WITH protect ,noconstant (0 )
  SET beg_extract_dt_tm_year_start = cnvtdatetime (build ("01-JAN-" ,datetimepart (cnvtdatetime (
      beg_extract_dt_tm ) ,1 ) ," 00:00:00" ) )
  SET end_extract_dt_tm_year_end = cnvtdatetime (build ("31-DEC-" ,datetimepart (cnvtdatetime (
      end_extract_dt_tm ) ,1 ) ," 23:59:59" ) )
  SET rpt->date_range = build2 (format (beg_extract_dt_tm ,"MM/DD/YYYY;;q" ) ," - " ,format (
    end_extract_dt_tm ,"MM/DD/YYYY;;q" ) )
  SET rpt->created_on = format (cnvtdatetime (curdate ,curtime3 ) ,"MM/DD/YYYY;;q" )
  CALL addsubmeasures (0 )
  CALL copysubmeasures (0 )
  IF ((params->report_by = "CPC" ) )
   CALL getcpcunits (0 )
  ENDIF
  IF ((rpt->status = "F" ) )
   CALL printreportnotrun (value (params->outdev ) )
  ELSE
   FOR (param_meas_cnt = 1 TO params->measure_cnt )
    CALL lhprint (build ("/**** Measure: " ,params->measures[param_meas_cnt ].mean ," ****/" ) )
    SET log_measure_start_dt_tm = cnvtdatetime (curdate ,curtime3 )
    CALL lhprint (build ("Start time of this measure :" ,format (log_measure_start_dt_tm ,";;q" ) )
     )
    CALL lhprint (" " )
    CALL getmeasureresults (params->measures[param_meas_cnt ].mean )
    IF ((params->measures[param_meas_cnt ].mean = "MU_EC_0022_2019.1" ) )
     SET nqf22_ind = 1
    ELSEIF ((params->measures[param_meas_cnt ].mean = "MU_EC_0028_2019.1" ) )
     SET nqf28_ind = 1
    ENDIF
    SET log_measure_end_dt_tm = cnvtdatetime (curdate ,curtime3 )
    CALL lhprint (build ("End time of this measure : " ,format (log_measure_end_dt_tm ,";;q" ) ) )
    CALL lhprint (build ("Elapsed time of this measure : " ,datetimediff (log_measure_end_dt_tm ,
       log_measure_start_dt_tm ,5 ) ) )
    CALL lhprint (" " )
    CALL lhprint (" " )
   ENDFOR
   CALL determine_ep_summary_mrn (0 )
   CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   IF ((params->report_by = "GPRO" ) )
    CALL pull_ep_sum_into_grp_sum (0 )
    CALL move_grp_sum_to_ep_sum (0 )
   ENDIF
   CALL applyproviderfilters (0 )
   CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   IF ((params->report_by != "CPC" ) )
    CALL restrict_ep_sum_to_brdefmeas (ep_summary ,params ,params->report_by )
   ENDIF
   IF ((nqf22_ind = 1 ) )
    CALL updatenqf22outcomes (0 )
   ELSEIF ((nqf28_ind = 1 ) )
    CALL updatenqf28outcomes ("MU_EC_0028_2019.1" )
    CALL updatenqf28outcomes ("MU_EC_0028_2019.2" )
    CALL updatenqf28outcomes ("MU_EC_0028_2019.3" )
    CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   ENDIF
   CALL addreport (0 )
   CALL lhprint (";################ Printing Report ################" )
   CALL beg_time (0 )
   IF ((ep_report->ep_cnt = 0 ) )
    SET rpt->message = "No data qualified"
    SET rpt->status = "F"
    SET stat = initrec (ep_report )
    CALL printreportnotrun (value (params->outdev ) )
   ELSE
    CASE (cnvtupper (params->chksummaryonly ) )
     OF "SUM_PS" :
     OF "DET_PS" :
      CALL printpsreport (params->outdev )
      CALL end_time (0 )
     OF "SUM_PDF" :
     OF "DET_PDF" :
      CALL printpdfreport (params->outdev )
      CALL end_time (0 )
     OF "SUM_CSV" :
      IF ((cnvtupper (target_file ) = "MINE" ) )
       CALL printcsvreport (0 ,params->outdev ," " )
      ELSE
       CALL printcsvreport (0 ,value (params->outdev ) ,"," )
      ENDIF
      ,
      SET stat = initrec (ep_report )
     OF "DET_CSV" :
      IF ((cnvtupper (target_file ) = "MINE" ) )
       CALL printcsvreport (1 ,params->outdev ," " )
      ELSE
       CALL printcsvreport (1 ,value (params->outdev ) ,"," )
      ENDIF
    ENDCASE
   ENDIF
   SET stat = initrec (ep_report )
   SET stat = initrec (rpt )
  ENDIF
  SET report_end_dt_tm = cnvtdatetime (curdate ,curtime3 )
  IF ((cnvtupper (params->chksummaryonly ) = "*PS" ) )
   CALL lhprint (build ("Report end date :" ,format (report_end_dt_tm ,";;q" ) ) )
   CALL lhprint (build ("Total Time taken for report :" ,datetimediff (report_end_dt_tm ,
      report_start_dt_tm ,5 ) ) )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getproviderids (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE epcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE gprocnt = i4 WITH noconstant (0 ) ,protect
  DECLARE cpccnt = i4 WITH noconstant (0 ) ,protect
  IF ((params->report_by = "INDV" ) )
   CALL lhprint (";retrieve EP list" )
   CALL beg_time (0 )
   SELECT INTO "nl:"
    FROM (br_eligible_provider ep )
    WHERE expand (iter1 ,1 ,size (params->eps ,5 ) ,ep.br_eligible_provider_id ,params->eps[iter1 ].
     br_eligible_provider_id )
    ORDER BY ep.provider_id
    HEAD REPORT
     pos = 0
    HEAD ep.provider_id
     pos = locateval (iter2 ,1 ,size (lh_ep_provider_list->epcnt ,5 ) ,ep.br_eligible_provider_id ,
      lh_ep_provider_list->eps[iter2 ].br_eligible_provider_id ) ,
     IF ((pos = 0 ) ) epcnt = (epcnt + 1 ) ,stat = alterlist (lh_ep_provider_list->eps ,epcnt ) ,
      lh_ep_provider_list->epcnt = epcnt ,lh_ep_provider_list->eps[epcnt ].br_eligible_provider_id =
      ep.br_eligible_provider_id ,lh_ep_provider_list->eps[epcnt ].provider_id = ep.provider_id
     ENDIF
    WITH nocounter ,expand = 1
   ;end select
   CALL end_time (0 )
  ELSEIF ((params->report_by = "GPRO" ) )
   CALL lhprint (";Building out GPRO provider list" )
   CALL beg_time (0 )
   SET gprocnt = size (params->grps ,5 )
   SET stat = alterlist (lh_ep_provider_list->gpros ,gprocnt )
   SET lh_ep_provider_list->gprocnt = gprocnt
   FOR (i = 1 TO gprocnt )
    SET epcnt = 0
    SET lh_ep_provider_list->gpros[i ].br_gpro_id = params->grps[i ].br_gpro_id
    SELECT INTO "nl:"
     FROM (br_eligible_provider ep ),
      (br_gpro_reltn bgr ),
      (br_gpro bg )
     WHERE (bg.br_gpro_id = lh_ep_provider_list->gpros[i ].br_gpro_id )
     AND (bgr.br_gpro_id = bg.br_gpro_id )
     AND (bgr.active_ind = 1 )
     AND (bgr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) )
     AND (bgr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (ep.br_eligible_provider_id = bgr.parent_entity_id )
     ORDER BY ep.provider_id
     HEAD REPORT
      pos = 0
     HEAD ep.provider_id
      pos = locateval (iter2 ,1 ,size (lh_ep_provider_list->gpros[i ].eps ,5 ) ,ep.provider_id ,
       lh_ep_provider_list->gpros[i ].eps[iter2 ].provider_id ) ,
      IF ((pos = 0 ) ) epcnt = (epcnt + 1 ) ,stat = alterlist (lh_ep_provider_list->gpros[i ].eps ,
        epcnt ) ,lh_ep_provider_list->gpros[i ].eps[epcnt ].br_eligible_provider_id = ep
       .br_eligible_provider_id ,lh_ep_provider_list->gpros[i ].eps[epcnt ].provider_id = ep
       .provider_id
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
   CALL end_time (0 )
  ELSE
   CALL lhprint (";Building out CPC provider list" )
   CALL beg_time (0 )
   SET cpccnt = size (params->eps ,5 )
   SET stat = alterlist (lh_ep_provider_list->cpcs ,cpccnt )
   SET lh_ep_provider_list->cpccnt = cpccnt
   FOR (i = 1 TO cpccnt )
    SET epcnt = 0
    SET lh_ep_provider_list->cpcs[i ].br_cpc_id = params->eps[i ].br_eligible_provider_id
    SELECT INTO "nl:"
     FROM (br_eligible_provider ep ),
      (br_cpc_elig_prov_reltn bcr ),
      (br_cpc bc )
     WHERE (bc.br_cpc_id = lh_ep_provider_list->cpcs[i ].br_cpc_id )
     AND (bcr.br_cpc_id = bc.br_cpc_id )
     AND (bcr.active_ind = 1 )
     AND (bcr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) )
     AND (bcr.br_eligible_provider_id = ep.br_eligible_provider_id )
     ORDER BY ep.provider_id
     HEAD REPORT
      pos = 0
     HEAD ep.provider_id
      pos = locateval (iter2 ,1 ,size (lh_ep_provider_list->cpcs[i ].eps ,5 ) ,ep.provider_id ,
       lh_ep_provider_list->cpcs[i ].eps[iter2 ].provider_id ) ,
      IF ((pos = 0 ) ) epcnt = (epcnt + 1 ) ,stat = alterlist (lh_ep_provider_list->cpcs[i ].eps ,
        epcnt ) ,lh_ep_provider_list->cpcs[i ].eps[epcnt ].br_eligible_provider_id = ep
       .br_eligible_provider_id ,lh_ep_provider_list->cpcs[i ].eps[epcnt ].provider_id = ep
       .provider_id
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
   CALL end_time (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getprovidergroups (null )
  DECLARE epcnt = i4 WITH noconstant (size (params->eps ,5 ) ) ,protect
  DECLARE gpro_iter = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Building out provider group list" )
  CALL beg_time (0 )
  SET stat = alterlist (lh_ep_provider_groups->eps ,epcnt )
  SET lh_ep_provider_groups->epcnt = epcnt
  FOR (i = 1 TO epcnt )
   SET lh_ep_provider_groups->eps[i ].br_eligible_provider_id = params->eps[i ].
   br_eligible_provider_id
   SELECT INTO "nl:"
    FROM (br_gpro b ),
     (br_gpro_reltn r ),
     (br_eligible_provider p )
    WHERE expand (gpro_iter ,1 ,size (params->grps ,5 ) ,b.br_gpro_id ,params->grps[gpro_iter ].
     br_gpro_id )
    AND (r.br_gpro_id = b.br_gpro_id )
    AND (r.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (r.active_ind = 1 )
    AND (r.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
    AND (r.parent_entity_id = params->eps[i ].br_eligible_provider_id )
    AND (r.parent_entity_id = p.br_eligible_provider_id )
    ORDER BY b.br_gpro_id
    HEAD b.br_gpro_id
     grpsize = (size (lh_ep_provider_groups->eps[i ].gpros ,5 ) + 1 ) ,stat = alterlist (
      lh_ep_provider_groups->eps[i ].gpros ,grpsize ) ,lh_ep_provider_groups->eps[i ].gpros[grpsize ]
     .br_gpro_id = b.br_gpro_id ,lh_ep_provider_groups->eps[i ].provider_id = p.provider_id
    WITH nocounter
   ;end select
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  updatenqf28outcomes (measure_mean )
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE j = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE testiter = i4 WITH noconstant (0 ) ,protect
  IF ((size (ep_summary->eps ,5 ) > 0 ) )
   FOR (i = 1 TO size (ep_summary->eps ,5 ) )
    IF ((ep_summary->eps[i ].reportmean = measure_mean )
    AND (size (ep_summary->eps[i ].patients ,5 ) > 0 ) )
     FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
      SET ep_summary->eps[i ].patients[j ].exclude_ind = 1
      SET pos = locateval (testiter ,1 ,size (lh_ep_provider->eps ,5 ) ,ep_summary->eps[i ].
       provider_id ,lh_ep_provider->eps[testiter ].ep_id ,ep_summary->eps[i ].patients[j ].person_id
       ,lh_ep_provider->eps[testiter ].person_id )
      IF ((pos > 0 ) )
       IF ((lh_ep_provider->eps[pos ].ecnt >= 2 ) )
        SET ep_summary->eps[i ].patients[j ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE  updatenqf22outcomes (null )
  DECLARE eppos = i4 WITH noconstant (0 )
  DECLARE patpos = i4 WITH noconstant (0 )
  DECLARE iter = i4 WITH noconstant (0 )
  FOR (i = 1 TO size (lh_nqf22_num1->qual ,5 ) )
   IF ((size (ep_summary->eps ,5 ) > 0 ) )
    SET eppos = locateval (iter ,1 ,size (ep_summary->eps ,5 ) ,lh_nqf22_num1->qual[i ].reporting_id
     ,ep_summary->eps[iter ].br_eligible_provider_id ,"MU_EC_0022_2019.1" ,ep_summary->eps[iter ].
     reportmean )
    WHILE ((eppos > 0 ) )
     SET patpos = locateval (iter ,1 ,size (ep_summary->eps[eppos ].patients ,5 ) ,lh_nqf22_num1->
      qual[i ].person_id ,ep_summary->eps[eppos ].patients[iter ].person_id )
     IF ((patpos > 0 ) )
      SET ep_summary->eps[eppos ].patients[patpos ].outcome_ind = 1
      SET ep_summary->eps[eppos ].patients[patpos ].outcome = "Met, Done"
     ENDIF
     SET eppos = locateval (iter ,(eppos + 1 ) ,size (ep_summary->eps ,5 ) ,lh_nqf22_num1->qual[i ].
      reporting_id ,ep_summary->eps[iter ].br_eligible_provider_id ,"MU_EC_0022_2019.1" ,ep_summary->
      eps[iter ].reportmean )
    ENDWHILE
   ENDIF
  ENDFOR
  FOR (i = 1 TO size (lh_nqf22_num2->qual ,5 ) )
   IF ((size (ep_summary->eps ,5 ) > 0 ) )
    SET eppos = locateval (iter ,1 ,size (ep_summary->eps ,5 ) ,lh_nqf22_num2->qual[i ].reporting_id
     ,ep_summary->eps[iter ].br_eligible_provider_id ,"MU_EC_0022_2019.2" ,ep_summary->eps[iter ].
     reportmean )
    WHILE ((eppos > 0 ) )
     SET patpos = locateval (iter ,1 ,size (ep_summary->eps[eppos ].patients ,5 ) ,lh_nqf22_num2->
      qual[i ].person_id ,ep_summary->eps[eppos ].patients[iter ].person_id )
     IF ((patpos > 0 ) )
      SET ep_summary->eps[eppos ].patients[patpos ].outcome_ind = 1
      SET ep_summary->eps[eppos ].patients[patpos ].outcome = "Met, Done"
     ENDIF
     SET eppos = locateval (iter ,(eppos + 1 ) ,size (ep_summary->eps ,5 ) ,lh_nqf22_num2->qual[i ].
      reporting_id ,ep_summary->eps[iter ].br_eligible_provider_id ,"MU_EC_0022_2019.2" ,ep_summary->
      eps[iter ].reportmean )
    ENDWHILE
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE  lhperformance (measure_desc ,status_flag ,elapsed_time ,population_cnt )
  IF ((validate (category_mean ) = 1 )
  AND (validate (measure_desc ) = 1 )
  AND (validate (beg_extract_dt_tm ) = 1 )
  AND (validate (end_extract_dt_tm ) = 1 ) )
   SET errcode = error (errmsg ,1 )
   INSERT FROM (lh_performance_audit lhp )
    SET lhp.lh_performance_audit_id = seq (reference_seq ,nextval ) ,
     lhp.category_mean = trim (substring (1 ,50 ,category_mean ) ,3 ) ,
     lhp.measure_desc = trim (substring (1 ,50 ,measure_desc ) ,3 ) ,
     lhp.record_cnt = population_cnt ,
     lhp.status_flag = status_flag ,
     lhp.process_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     lhp.elapsed_time = elapsed_time ,
     lhp.start_dt_tm = cnvtdatetime (start_getepdata_time ) ,
     lhp.end_dt_tm = cnvtdatetime (end_getepdata_time ) ,
     lhp.date_range_start_dt_tm = cnvtdatetime (beg_extract_dt_tm ) ,
     lhp.date_range_end_dt_tm = cnvtdatetime (end_extract_dt_tm ) ,
     lhp.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     lhp.updt_cnt = 0 ,
     lhp.updt_task = "LIGHTHOUSE_REPORT" ,
     lhp.updt_source = script_name ,
     lhp.first_process_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     lhp.last_process_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     lhp.extract_dt_tm = cnvtdatetime (extract_dt_tm )
   ;end insert
   SET errcode = error (errmsg ,0 )
   IF ((errcode != 0 ) )
    CALL lhprint ("Error while running performance measurement query" )
    CALL echo ("Error while running performance measurement query" )
    CALL lhprint (errmsg )
    ROLLBACK
    SET err_count = (err_count + 1 )
   ELSE
    COMMIT
   ENDIF
   SET errcode = error (errmsg ,1 )
  ENDIF
 END ;Subroutine
 DECLARE getcpcunits (null ) = null
 DECLARE getcpclist (null ) = null
 DECLARE getallcpcmeasures (null ) = null
 DECLARE cpcattribution ((reportmean = vc ) ,(pop_group = vc ) ,(attrb_type = i2 ) ,(attributionhint
  = vc ) ) = null
 DECLARE cpcattributionimport ((reportmean = vc ) ,(pop_group = vc ) ,(attrb_type = i2 ) ,(
  attributionhint = vc ) ) = null
 DECLARE removenoncpcmeasuresqrda (null ) = null
 DECLARE iscpcmeasure ((meas_name = vc ) ) = i2
 IF ((validate (cpc_nurse_units ) = 0 ) )
  RECORD cpc_nurse_units (
    1 unit_cnt = i4
    1 unit [* ]
      2 br_cpc_id = f8
      2 br_eligible_provider_id = f8
      2 location_cd = f8
      2 tin = vc
      2 site_id = vc
      2 cpc_name = vc
  ) WITH public
 ENDIF
 SUBROUTINE  getcpcunits (null )
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE ld_parser = vc WITH protect ,noconstant ("bc.logical_domain_id = LOGICAL_DOMAIN_ID" )
  IF ((pwx_ind = 1 ) )
   SET ld_parser = "1=1"
  ENDIF
  SELECT INTO "nl:"
   FROM (br_cpc bc ),
    (br_cpc_loc_reltn bclr ),
    (br_cpc_elig_prov_reltn bcpr )
   WHERE expand (num ,1 ,params->ep_cnt ,(bc.br_cpc_id + 0 ) ,params->eps[num ].
    br_eligible_provider_id )
   AND (bc.br_cpc_id = bclr.br_cpc_id )
   AND (bc.br_cpc_id = bcpr.br_cpc_id )
   AND (bc.active_ind = 1 )
   AND (bclr.active_ind = 1 )
   AND (bcpr.active_ind = 1 )
   AND parser (ld_parser )
   AND (bc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (bc.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
   AND (bcpr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (bcpr.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
   AND (bclr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (bclr.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
   ORDER BY bcpr.br_eligible_provider_id ,
    bclr.location_cd
   HEAD REPORT
    stat = initrec (cpc_nurse_units ) ,
    cnt = 0
   HEAD bcpr.br_eligible_provider_id
    dummy = 0
   HEAD bclr.location_cd
    cnt = (cnt + 1 ) ,stat = alterlist (cpc_nurse_units->unit ,cnt ) ,cpc_nurse_units->unit[cnt ].
    br_cpc_id = bc.br_cpc_id ,cpc_nurse_units->unit[cnt ].br_eligible_provider_id = bcpr
    .br_eligible_provider_id ,cpc_nurse_units->unit[cnt ].location_cd = bclr.location_cd ,
    cpc_nurse_units->unit[cnt ].tin = bc.tax_id_nbr_txt ,cpc_nurse_units->unit[cnt ].site_id = bc
    .cpc_site_id_txt ,cpc_nurse_units->unit[cnt ].cpc_name = bc.br_cpc_name
   FOOT REPORT
    cpc_nurse_units->unit_cnt = cnt
   WITH nocounter ,expand = 1
  ;end select
 END ;Subroutine
 SUBROUTINE  getcpclist (null )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE k = i4 WITH noconstant (0 ) ,protect
  DECLARE temp = i4 WITH noconstant (0 ) ,protect
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE ld_parser = vc WITH protect ,noconstant ("bc.logical_domain_id = LOGICAL_DOMAIN_ID" )
  IF ((validate (update_source ) = 1 ) )
   IF ((pwx_ind = 1 )
   AND (update_source = "lh_nqf2019_qrda_load*" ) )
    SET ld_parser = "1=1"
   ENDIF
  ENDIF
  IF ((size (params->eps ,5 ) = 0 ) )
   IF ((update_source IN ("lh_nqf2019_qrda_load_cat1.prg" ,
   "lh_nqf2019_qrda_load_cat3.prg" ) ) )
    SELECT INTO "nl:"
     FROM (br_cpc bc ),
      (address ad )
     WHERE (bc.active_ind = 1 )
     AND (ad.parent_entity_id = bc.br_cpc_id )
     AND (ad.parent_entity_name = "BR_CPC" )
     AND (ad.active_ind = 1 )
     AND parser (ld_parser )
     AND (bc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (bc.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
     ORDER BY bc.br_cpc_id
     HEAD REPORT
      cnt = 0
     HEAD bc.br_cpc_id
      cnt = (cnt + 1 ) ,stat = alterlist (params->eps ,cnt ) ,params->eps[cnt ].
      br_eligible_provider_id = bc.br_cpc_id
     FOOT REPORT
      params->ep_cnt = cnt
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (br_cpc bc )
     WHERE (bc.active_ind = 1 )
     AND parser (ld_parser )
     AND (bc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (bc.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
     ORDER BY bc.br_cpc_id
     HEAD REPORT
      cnt = 0
     HEAD bc.br_cpc_id
      cnt = (cnt + 1 ) ,stat = alterlist (params->eps ,cnt ) ,params->eps[cnt ].
      br_eligible_provider_id = bc.br_cpc_id
     FOOT REPORT
      params->ep_cnt = cnt
     WITH nocounter
    ;end select
   ENDIF
  ELSEIF ((size (params->eps ,5 ) > 0 ) )
   IF ((update_source IN ("lh_nqf2019_qrda_load_cat1.prg" ,
   "lh_nqf2019_qrda_load_cat3.prg" ) ) )
    SELECT INTO "nl:"
     FROM (br_cpc bc ),
      (address ad )
     WHERE expand (num ,1 ,size (params->eps ,5 ) ,bc.br_cpc_id ,params->eps[num ].
      br_eligible_provider_id )
     AND (bc.active_ind = 1 )
     AND (ad.parent_entity_id = bc.br_cpc_id )
     AND (ad.parent_entity_name = "BR_CPC" )
     AND (ad.active_ind = 1 )
     AND parser (ld_parser )
     AND (bc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (bc.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
     ORDER BY bc.br_cpc_id
     HEAD REPORT
      cnt = 0
     HEAD bc.br_cpc_id
      pos = locateval (iter1 ,1 ,size (params->eps ,5 ) ,bc.br_cpc_id ,params->eps[iter1 ].
       br_eligible_provider_id ) ,
      IF ((pos > 0 ) ) params->eps[pos ].include_ind = 1
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
    SET k = size (params->eps ,5 )
    SET temp = k
    WHILE ((k > 0 ) )
     IF ((params->eps[k ].include_ind = 0 ) )
      SET k = (k - 1 )
      SET temp = (temp - 1 )
      SET stat = alterlist (params->eps ,temp ,k )
      SET params->ep_cnt = size (params->eps ,5 )
     ELSE
      SET k = (k - 1 )
     ENDIF
    ENDWHILE
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  getallcpcmeasures (null )
  SET stat = alterlist (params->measures ,2 )
  SET params->measures[1 ].mean = "MU_EC_0018_2019"
  SET params->measures[2 ].mean = "MU_EC_0059_2019"
  SET params->measure_cnt = 2
 END ;Subroutine
 SUBROUTINE  cpcattribution (reportmean ,pop_group ,attrb_type ,attributionhint )
  DECLARE attribution_option_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE code_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE num2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_check = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE cpc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE qry_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE cpc_i = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_i = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";CPC Attribution" )
  CALL lhprint (build (";Report Mean: " ,reportmean ) )
  CALL lhprint (build (";Population Group: " ,pop_group ) )
  CALL lhprint (build (";Attribution type: " ,attrb_type ) )
  CALL lhprint (build (";Attribution hint: " ,attributionhint ) )
  IF ((attrb_type = 1 ) )
   SET attribution_option_parser = "laer.attribution_option = '1'"
   SET code_parser =
   "expand(num, 1, br_filters->epr_cnt, laer.encntr_prsnl_r_cd, br_filters->eprs[num].code_value) "
  ELSEIF ((attrb_type = 2 ) )
   SET code_parser =
   "expand(num, 1, size(ep_nomen->qual,5), laer.charge_reltn_cd, ep_nomen->qual[num].source_vocab_id) "
   IF ((ep_charge_bim_option_ind = 0 ) )
    SET attribution_option_parser = "laer.attribution_option = '2B'"
   ELSE
    SET attribution_option_parser = "laer.attribution_option = '2C'"
   ENDIF
  ENDIF
  CALL beg_time (0 )
  IF ((validate (lh_query_ids ) = 0 ) )
   RECORD lh_query_ids (
     1 pop_group = vc
     1 qry_cnt = i4
     1 qual [* ]
       2 d_query_id = f8
   ) WITH public
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_d_query qry )
   WHERE (qry.population_group = pop_group )
   AND (qry.active_ind = 1 )
   HEAD REPORT
    qry_cnt = 0 ,
    lh_query_ids->pop_group = pop_group
   HEAD qry.d_query_id
    qry_cnt = (qry_cnt + 1 ) ,stat = alterlist (lh_query_ids->qual ,qry_cnt ) ,lh_query_ids->qual[
    qry_cnt ].d_query_id = qry.d_query_id
   FOOT REPORT
    lh_query_ids->qry_cnt = qry_cnt
   WITH nocounter
  ;end select
  SET persons_size = size (lh_ep_reply->persons ,5 )
  SET person_batch_size = 5000
  SET person_iter = 1
  SET iter2 = 0
  IF ((persons_size < person_batch_size ) )
   SET person_batch_size = persons_size
  ENDIF
  WHILE ((person_iter <= persons_size ) )
   IF (((person_iter + person_batch_size ) > persons_size ) )
    SET person_batch_size = (persons_size - person_iter )
   ELSE
    SET person_batch_size = 5000
   ENDIF
   SELECT
    IF ((attributionhint != "" ) )
     WITH nocounter ,expand = 1 ,orahintcbo (value (attributionhint ) )
    ELSE
    ENDIF
    INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 pop ),
     (lh_amb_ep_reltn_2019 laer ),
     (lh_d_personnel prsnl ),
     (br_eligible_provider ep )
    PLAN (pop
     WHERE expand (iter1 ,person_iter ,(person_iter + person_batch_size ) ,pop.person_id ,lh_ep_reply
      ->persons[iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
     AND (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) )
     AND (pop.active_ind = 1 )
     AND expand (cpc_iter ,1 ,size (cpc_nurse_units->unit ,5 ) ,pop.loc_nurse_unit_cd ,
      cpc_nurse_units->unit[cpc_iter ].location_cd )
     AND expand (qry_iter ,1 ,lh_query_ids->qry_cnt ,pop.d_query_id ,lh_query_ids->qual[qry_iter ].
      d_query_id ) )
     JOIN (laer
     WHERE (laer.lh_amb_qual_encntr_2019_id = pop.lh_amb_qual_encntr_2019_id )
     AND parser (code_parser )
     AND (laer.active_ind = 1 )
     AND parser (attribution_option_parser ) )
     JOIN (ep
     WHERE expand (cpc_iter ,1 ,size (cpc_nurse_units->unit ,5 ) ,ep.br_eligible_provider_id ,
      cpc_nurse_units->unit[cpc_iter ].br_eligible_provider_id )
     AND (laer.provider_id = ep.provider_id )
     AND (ep.active_ind = 1 ) )
     JOIN (prsnl
     WHERE (prsnl.person_id = ep.provider_id )
     AND (prsnl.active_ind = 1 ) )
    ORDER BY pop.person_id ,
     pop.encntr_id
    HEAD REPORT
     epcnt = 0 ,
     ep_pos = 0 ,
     cpc_pos = 0 ,
     row + 1
    HEAD pop.loc_nurse_unit_cd
     cpc_pos = locateval (cpc_i ,1 ,size (cpc_nurse_units->unit ,5 ) ,pop.loc_nurse_unit_cd ,
      cpc_nurse_units->unit[cpc_i ].location_cd ) ,
     IF ((cpc_pos > 0 )
     AND (cpc_nurse_units->unit[cpc_pos ].br_eligible_provider_id != 0 ) ) cpc_id = cpc_nurse_units->
      unit[cpc_pos ].br_cpc_id ,ep_pos = locateval (ep_i ,1 ,size (ep_summary->eps ,5 ) ,cpc_id ,
       ep_summary->eps[ep_i ].provider_id ,reportmean ,ep_summary->eps[ep_i ].reportmean ) ,
      IF ((ep_pos > 0 ) ) epcnt = ep_pos
      ELSE epcnt = (ep_summary->ep_cnt + 1 ) ,ep_summary->ep_cnt = epcnt ,stat = alterlist (
        ep_summary->eps ,epcnt )
      ENDIF
      ,ep_summary->eps[epcnt ].br_eligible_provider_id = cpc_nurse_units->unit[cpc_pos ].br_cpc_id ,
      ep_summary->eps[epcnt ].provider_id = cpc_nurse_units->unit[cpc_pos ].br_cpc_id ,ep_summary->
      eps[epcnt ].tax_id_nbr_txt = cpc_nurse_units->unit[cpc_pos ].tin ,ep_summary->eps[epcnt ].
      npi_nbr_txt = cpc_nurse_units->unit[cpc_pos ].site_id ,ep_summary->eps[epcnt ].name =
      cpc_nurse_units->unit[cpc_pos ].cpc_name ,ep_summary->eps[epcnt ].reportmean = reportmean ,
      ptcnt = 0
     ENDIF
    HEAD pop.person_id
     person_pos = 0 ,person_pos2 = 0 ,person_pos = locateval (person_i ,1 ,size (lh_ep_reply->persons
        ,5 ) ,pop.person_id ,lh_ep_reply->persons[person_i ].person_id ) ,person_pos2 = locateval (
      person_i2 ,1 ,size (ep_summary->eps[epcnt ].patients ,5 ) ,pop.person_id ,ep_summary->eps[
      epcnt ].patients[person_i2 ].person_id ) ,
     IF ((person_pos > 0 )
     AND (person_pos2 = 0 )
     AND (lh_ep_reply->persons[person_i ].updt_src_ind IN (1 ,
     3 ) ) ) ptcnt = (ep_summary->eps[epcnt ].patient_cnt + 1 ) ,ep_summary->eps[epcnt ].patient_cnt
      = ptcnt ,stat = alterlist (ep_summary->eps[epcnt ].patients ,ptcnt ) ,ep_summary->eps[epcnt ].
      patients[ptcnt ].person_id = pop.person_id ,ep_summary->eps[epcnt ].patients[ptcnt ].mrn =
      lh_ep_reply->persons[person_pos ].mrn ,ep_summary->eps[epcnt ].patients[ptcnt ].birth_date =
      format (lh_ep_reply->persons[person_pos ].birth_date ,"mm/dd/yyyy;;q" ) ,ecnt = 0 ,enc_pos = 0
     ,encntr_check = 0
     ELSEIF ((person_pos > 0 )
     AND (person_pos2 > 0 )
     AND (lh_ep_reply->persons[person_pos ].updt_src_ind IN (1 ,
     3 ) ) ) ptcnt = person_pos2
     ENDIF
    HEAD pop.encntr_id
     IF ((person_pos > 0 ) ) enc_pos = locateval (enc_iter ,1 ,lh_ep_reply->persons[person_pos ].
       encntr_cnt ,pop.encntr_id ,lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].encntr_id ,0 ,
       lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].exclude_ind ) ,
      IF ((enc_pos > 0 ) ) lh_ep_reply->persons[person_pos ].encntrs[enc_pos ].ep_ind = 1 ,ecnt = (
       ep_summary->eps[epcnt ].patients[ptcnt ].encntr_cnt + 1 ) ,ep_summary->eps[epcnt ].patients[
       ptcnt ].encntr_cnt = ecnt ,stat = alterlist (ep_summary->eps[epcnt ].patients[ptcnt ].encntrs
        ,ecnt ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[ecnt ].encntr_id = pop.encntr_id ,
       ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[ecnt ].br_eligible_provider_id = ep
       .br_eligible_provider_id ,ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[ecnt ].visit_date
       = format (pop.reg_dt_tm ,"mm/dd/yyyy;;q" ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[
       ecnt ].fin = lh_ep_reply->persons[person_pos ].encntrs[enc_pos ].fin ,encntr_check = 1
      ENDIF
     ENDIF
    FOOT  pop.person_id
     IF ((encntr_check = 1 ) ) lh_ep_reply->persons[person_pos ].ep_ind = 1
     ENDIF
    WITH nocounter ,expand = 1
   ;end select
   SET person_iter = ((person_iter + person_batch_size ) + 1 )
  ENDWHILE
  SELECT INTO "nl:"
   FROM (lh_d_person per ),
    (dummyt d1 WITH seq = ep_summary->ep_cnt ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (ep_summary->eps[d1.seq ].patients ,5 ) )
    AND (ep_summary->ep_cnt > 0 ) )
    JOIN (d2
    WHERE (ep_summary->eps[d1.seq ].patient_cnt > 0 ) )
    JOIN (per
    WHERE (per.person_id = ep_summary->eps[d1.seq ].patients[d2.seq ].person_id ) )
   HEAD d1.seq
    dummy = 0
   HEAD d2.seq
    dummy = 0
   DETAIL
    ep_summary->eps[d1.seq ].patients[d2.seq ].name = per.name_full
   WITH nocounter
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  cpcattributionimport (reportmean ,pop_group ,attrb_type ,attributionhint )
  DECLARE attribution_option_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE code_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE num2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE batch_size = i4 WITH constant (15 ) ,protect
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_check = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_i = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_counter = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_batch = i4 WITH noconstant (25000 ) ,protect
  DECLARE person_pos2 = i4 WITH noconstant (0 ) ,protect
  DECLARE persons_size = i4 WITH noconstant (0 ) ,protect
  DECLARE person_batch_size = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";CPC Import Attribution" )
  CALL lhprint (build (";Report Mean: " ,reportmean ) )
  CALL lhprint (build (";Population Group: " ,pop_group ) )
  CALL lhprint (build (";Attribution type: " ,attrb_type ) )
  CALL lhprint (build (";Attribution hint: " ,attributionhint ) )
  CALL beg_time (0 )
  SET persons_size = size (lh_ep_reply->persons ,5 )
  SET person_batch_size = 5000
  SET person_iter = 1
  SET iter2 = 0
  IF ((persons_size < person_batch_size ) )
   SET person_batch_size = persons_size
  ENDIF
  WHILE ((person_iter <= persons_size ) )
   IF (((person_iter + person_batch_size ) > persons_size ) )
    SET person_batch_size = (persons_size - person_iter )
   ELSE
    SET person_batch_size = 5000
   ENDIF
   SELECT
    IF ((attributionhint != "" ) )
     WITH nocounter ,expand = 1 ,orahintcbo (value (attributionhint ) )
    ELSE
    ENDIF
    INTO "nl:"
    FROM (lh_import_qrda ipop ),
     (br_eligible_provider ep ),
     (br_cpc_elig_prov_reltn bcpr ),
     (br_cpc bc )
    PLAN (ipop
     WHERE expand (iter1 ,person_iter ,(person_iter + person_batch_size ) ,ipop.person_id ,
      lh_ep_reply->persons[iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind ) )
     JOIN (bc
     WHERE expand (num ,1 ,params->ep_cnt ,(bc.br_cpc_id + 0 ) ,params->eps[num ].
      br_eligible_provider_id )
     AND (bc.active_ind = 1 )
     AND (bc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (bc.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
     AND (bc.br_cpc_id =
     (SELECT
      sup.supp_data_txt
      FROM (lh_import_qrda_supp sup )
      WHERE (sup.parent_entity_id = ipop.lh_import_qrda_id )
      AND (sup.supp_data_type = "CPC" ) ) ) )
     JOIN (bcpr
     WHERE (bcpr.br_cpc_id = bc.br_cpc_id )
     AND (bcpr.active_ind = 1 )
     AND (bcpr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (bcpr.beg_effective_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) )
     JOIN (ep
     WHERE (ep.br_eligible_provider_id = bcpr.br_eligible_provider_id )
     AND (ep.national_provider_nbr_txt =
     (SELECT
      sup.supp_data_txt
      FROM (lh_import_qrda_supp sup )
      WHERE (sup.parent_entity_id = ipop.lh_import_qrda_id )
      AND (sup.supp_data_type = "NPI" ) ) )
     AND (ep.active_ind = 1 ) )
    ORDER BY ep.provider_id ,
     bc.br_cpc_id ,
     ipop.person_id ,
     ipop.encntr_id
    HEAD REPORT
     epcnt = 0 ,
     ep_pos = 0
    HEAD bc.br_cpc_id
     ep_pos = locateval (ep_i ,1 ,size (ep_summary->eps ,5 ) ,bc.br_cpc_id ,ep_summary->eps[ep_i ].
      provider_id ,reportmean ,ep_summary->eps[ep_i ].reportmean ) ,
     IF ((ep_pos > 0 ) ) epcnt = ep_pos
     ELSE epcnt = (ep_summary->ep_cnt + 1 ) ,ep_summary->ep_cnt = epcnt ,stat = alterlist (ep_summary
       ->eps ,epcnt )
     ENDIF
     ,ep_summary->eps[epcnt ].br_eligible_provider_id = bc.br_cpc_id ,ep_summary->eps[epcnt ].
     provider_id = bc.br_cpc_id ,ep_summary->eps[epcnt ].tax_id_nbr_txt = bc.tax_id_nbr_txt ,
     ep_summary->eps[epcnt ].npi_nbr_txt = bc.cpc_site_id_txt ,ep_summary->eps[epcnt ].name = bc
     .br_cpc_name ,ep_summary->eps[epcnt ].reportmean = reportmean ,ptcnt = 0
    HEAD ipop.person_id
     person_pos = locateval (person_i ,1 ,size (ep_summary->eps[epcnt ].patients ,5 ) ,ipop
      .person_id ,ep_summary->eps[epcnt ].patients[person_i ].person_id ) ,person_pos2 = locateval (
      person_i ,1 ,size (lh_ep_reply->persons ,5 ) ,ipop.person_id ,lh_ep_reply->persons[person_i ].
      person_id ) ,
     IF ((person_pos2 > 0 )
     AND (lh_ep_reply->persons[person_i ].updt_src_ind IN (2 ,
     3 ) ) )
      IF ((person_pos > 0 ) ) ptcnt = person_pos
      ELSE ptcnt = (ep_summary->eps[epcnt ].patient_cnt + 1 ) ,ep_summary->eps[epcnt ].patient_cnt =
       ptcnt ,stat = alterlist (ep_summary->eps[epcnt ].patients ,ptcnt )
      ENDIF
      ,ep_summary->eps[epcnt ].patients[ptcnt ].person_id = ipop.person_id ,ep_summary->eps[epcnt ].
      patients[ptcnt ].mrn = lh_ep_reply->persons[person_pos2 ].mrn ,ep_summary->eps[epcnt ].
      patients[ptcnt ].birth_date = format (lh_ep_reply->persons[person_pos2 ].birth_date ,
       "mm/dd/yyyy;;q" ) ,ecnt = 0 ,enc_pos = 0 ,encntr_check = 0
     ENDIF
    HEAD ipop.encntr_id
     enc_pos = locateval (enc_iter ,1 ,lh_ep_reply->persons[person_pos2 ].encntr_cnt ,ipop.encntr_id
      ,lh_ep_reply->persons[person_pos2 ].encntrs[enc_iter ].encntr_id ) ,
     IF ((enc_pos > 0 )
     AND (lh_ep_reply->persons[person_pos2 ].encntrs[enc_pos ].exclude_ind = 0 ) ) lh_ep_reply->
      persons[person_pos2 ].encntrs[enc_pos ].ep_ind = 1 ,ecnt = (ep_summary->eps[epcnt ].patients[
      ptcnt ].encntr_cnt + 1 ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntr_cnt = ecnt ,stat =
      alterlist (ep_summary->eps[epcnt ].patients[ptcnt ].encntrs ,ecnt ) ,ep_summary->eps[epcnt ].
      patients[ptcnt ].encntrs[ecnt ].encntr_id = ipop.encntr_id ,ep_summary->eps[epcnt ].patients[
      ptcnt ].encntrs[ecnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_summary->eps[
      epcnt ].patients[ptcnt ].encntrs[ecnt ].visit_date = format (ipop.effective_low_dt_tm ,
       "mm/dd/yyyy;;q" ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[ecnt ].fin = lh_ep_reply->
      persons[person_pos2 ].encntrs[enc_pos ].fin ,encntr_check = 1
     ENDIF
    FOOT  ipop.person_id
     IF ((encntr_check = 1 ) ) lh_ep_reply->persons[person_pos2 ].ep_ind = 1
     ENDIF
    WITH nocounter ,expand = 1
   ;end select
   SET person_iter = ((person_iter + person_batch_size ) + 1 )
   IF ((attrib_counter = attrib_batch ) )
    CALL lhprint (attrib_counter )
    CALL lhprint (format (sysdate ,";;q" ) )
    SET attrib_batch = (attrib_batch + 25000 )
   ENDIF
  ENDWHILE
  SELECT INTO "nl:"
   FROM (lh_d_person per ),
    (dummyt d1 WITH seq = ep_summary->ep_cnt ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (ep_summary->eps[d1.seq ].patients ,5 ) )
    AND (ep_summary->ep_cnt > 0 ) )
    JOIN (d2
    WHERE (ep_summary->eps[d1.seq ].patient_cnt > 0 ) )
    JOIN (per
    WHERE (per.person_id = ep_summary->eps[d1.seq ].patients[d2.seq ].person_id ) )
   HEAD d1.seq
    dummy = 0
   HEAD d2.seq
    dummy = 0
   DETAIL
    ep_summary->eps[d1.seq ].patients[d2.seq ].name = per.name_full
   WITH nocounter
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  removenoncpcmeasuresqrda (null )
  DECLARE i = i4 WITH noconstant (1 ) ,protect
  DECLARE rec_size = i4 WITH noconstant (size (params->measures ,5 ) ) ,protect
  WHILE ((i <= rec_size ) )
   IF ((iscpcmeasure (params->measures[i ].mean ) = 0 ) )
    SET rec_size = (rec_size - 1 )
    SET stat = alterlist (params->measures ,rec_size ,(i - 1 ) )
    SET i = (i - 1 )
   ENDIF
   SET i = (i + 1 )
  ENDWHILE
 END ;Subroutine
 SUBROUTINE  iscpcmeasure (meas_name )
  DECLARE return_val = i2 WITH protect ,noconstant (0 )
  IF ((piece (meas_name ,"." ,1 ,meas_name ) IN ("MU_EC_0018_2019" ,
  "MU_EC_0059_2019" ) ) )
   SET return_val = 1
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 IF ((validate (lh_ep_reply ) = 0 ) )
  RECORD lh_ep_reply (
    1 person_cnt = i4
    1 persons [* ]
      2 person_id = f8
      2 recent_encntr_id = f8
      2 recent_encntr_date = dq8
      2 recent_encntr_reg_date = dq8
      2 recent_encntr_disch_date = dq8
      2 second_recent_encntr_id = f8
      2 second_recent_encntr_date = dq8
      2 first_encntr_id = f8
      2 first_encntr_date = dq8
      2 last_reg_date = dq8
      2 last_disch_date = dq8
      2 special_cond_dt_tm = dq8
      2 special_cond_a_dt_tm = dq8
      2 recent_bmi_amb_event_id = f8
      2 first_low_back_pblm_date = dq8
      2 updt_src_ind = i2
      2 mrn = vc
      2 age = i2
      2 birth_date = dq8
      2 deceased_date = dq8
      2 gender_cd = f8
      2 outcome_numeric = f8
      2 outcome_ind = i2
      2 outcome_temp = i2
      2 outcome = vc
      2 exclude_ind = i2
      2 ep_ind = i2
      2 qrda_ind = i2
      2 special_group = i4
      2 special_group_two = i4
      2 encntr_cnt = i4
      2 gender = vc
      2 race = vc
      2 ethnicity = vc
      2 payer = vc
      2 payer_group = vc
      2 payer_reg_dt_tm = dq8
      2 hic = vc
      2 pop_ep_dt_tm = dq8
      2 encntrs [* ]
        3 encntr_id = f8
        3 fin = vc
        3 outcome_ind = i2
        3 outcome = vc
        3 exclude_ind = i2
        3 ep_ind = i2
        3 ep_dt_tm = dq8
        3 reg_dt_tm = dq8
        3 disch_dt_tm = dq8
        3 special_cond_dt_tm = dq8
        3 outpt_ind = i2
        3 inpt_ind = i2
        3 special_group = i4
        3 a1 = i2
        3 a2 = i2
        3 b1 = i2
        3 b2 = i2
        3 c1 = i2
        3 c2 = i2
        3 d1 = i2
        3 d2 = i2
        3 e1 = i2
        3 e2 = i2
        3 f1 = i2
        3 f2 = i2
        3 h1 = i2
        3 h2 = i2
  ) WITH public
 ENDIF
 IF ((validate (lh_ep_reply_bk ) = 0 ) )
  RECORD lh_ep_reply_bk (
    1 person_cnt = i4
    1 persons [* ]
      2 person_id = f8
      2 recent_encntr_id = f8
      2 recent_encntr_date = dq8
      2 recent_encntr_reg_date = dq8
      2 recent_encntr_disch_date = dq8
      2 second_recent_encntr_id = f8
      2 second_recent_encntr_date = dq8
      2 first_encntr_id = f8
      2 first_encntr_date = dq8
      2 last_reg_date = dq8
      2 last_disch_date = dq8
      2 special_cond_dt_tm = dq8
      2 special_cond_a_dt_tm = dq8
      2 recent_bmi_amb_event_id = f8
      2 first_low_back_pblm_date = dq8
      2 updt_src_ind = i2
      2 mrn = vc
      2 age = i2
      2 birth_date = dq8
      2 deceased_date = dq8
      2 gender_cd = f8
      2 outcome_numeric = f8
      2 outcome_ind = i2
      2 outcome_temp = i2
      2 outcome = vc
      2 exclude_ind = i2
      2 ep_ind = i2
      2 qrda_ind = i2
      2 special_group = i4
      2 special_group_two = i4
      2 encntr_cnt = i4
      2 gender = vc
      2 race = vc
      2 ethnicity = vc
      2 payer = vc
      2 payer_group = vc
      2 payer_reg_dt_tm = dq8
      2 hic = vc
      2 pop_ep_dt_tm = dq8
      2 encntrs [* ]
        3 encntr_id = f8
        3 fin = vc
        3 outcome_ind = i2
        3 outcome = vc
        3 exclude_ind = i2
        3 ep_ind = i2
        3 ep_dt_tm = dq8
        3 reg_dt_tm = dq8
        3 disch_dt_tm = dq8
        3 special_cond_dt_tm = dq8
        3 outpt_ind = i2
        3 inpt_ind = i2
        3 special_group = i4
        3 a1 = i2
        3 a2 = i2
        3 b1 = i2
        3 b2 = i2
        3 c1 = i2
        3 c2 = i2
        3 d1 = i2
        3 d2 = i2
        3 e1 = i2
        3 e2 = i2
        3 f1 = i2
        3 f2 = i2
        3 h1 = i2
        3 h2 = i2
  ) WITH public
 ENDIF
 IF ((validate (br_filters ) = 0 ) )
  RECORD br_filters (
    1 provider_attribution = i4
    1 epr_cnt = i4
    1 eprs [* ]
      2 code_value = f8
    1 ppr_cnt = i4
    1 pprs [* ]
      2 code_value = f8
  ) WITH public
 ENDIF
 IF ((validate (lh_ep_provider_list ) = 0 ) )
  RECORD lh_ep_provider_list (
    1 epcnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
    1 gprocnt = i4
    1 gpros [* ]
      2 br_gpro_id = f8
      2 eps [* ]
        3 provider_id = f8
        3 br_eligible_provider_id = f8
    1 cpccnt = i4
    1 cpcs [* ]
      2 br_cpc_id = f8
      2 eps [* ]
        3 provider_id = f8
        3 br_eligible_provider_id = f8
  ) WITH public
 ENDIF
 IF ((validate (lh_ep_provider_groups ) = 0 ) )
  RECORD lh_ep_provider_groups (
    1 epcnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 gpros [* ]
        3 br_gpro_id = f8
  ) WITH public
 ENDIF
 IF ((validate (lh_nqf22_num1 ) = 0 ) )
  RECORD lh_nqf22_num1 (
    1 qual [* ]
      2 reporting_id = f8
      2 person_id = f8
  ) WITH public
 ENDIF
 IF ((validate (lh_nqf22_num2 ) = 0 ) )
  RECORD lh_nqf22_num2 (
    1 qual [* ]
      2 reporting_id = f8
      2 person_id = f8
  ) WITH public
 ENDIF
 IF ((validate (ep_summary ) = 0 ) )
  RECORD ep_summary (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 name = vc
      2 tax_id_nbr_txt = vc
      2 npi_nbr_txt = vc
      2 logical_domain_id = f8
      2 reportmean = vc
      2 patient_cnt = i4
      2 metric_val = f8
      2 nnums = f8
      2 ndens = f8
      2 nexcs = f8
      2 nexcp = f8
      2 nipp = f8
      2 nmsrpop = f8
      2 percent = f8
      2 exclude_ind = i2
      2 gpro_name = vc
      2 patients [* ]
        3 person_id = f8
        3 name = vc
        3 mrn = vc
        3 birth_date = vc
        3 outcome = vc
        3 outcome_ind = i2
        3 outcome_numeric = f8
        3 exclude_ind = i2
        3 encntr_cnt = i4
        3 gender = vc
        3 race = vc
        3 ethnicity = vc
        3 payer = vc
        3 payer_group = vc
        3 hic = vc
        3 encntrs [* ]
          4 encntr_id = f8
          4 visit_date = vc
          4 fin = vc
          4 outcome = vc
          4 outcome_ind = i2
          4 exclude_ind = i2
          4 br_eligible_provider_id = f8
  )
 ENDIF
 IF ((validate (grp_summary ) = 0 ) )
  RECORD grp_summary (
    1 grp_cnt = i4
    1 grps [* ]
      2 br_gpro_id = f8
      2 name = vc
      2 tax_id_nbr_txt = vc
      2 logical_domain_id = f8
      2 ep_cnt = i4
      2 eps [* ]
        3 br_eligible_provider_id = f8
        3 provider_id = f8
        3 name = vc
        3 tax_id_nbr_txt = vc
        3 npi_nbr_txt = vc
      2 meas_cnt = i4
      2 measures [* ]
        3 report_mean = vc
        3 ipp = f8
        3 nnums = f8
        3 ndens = f8
        3 nexclusions = f8
        3 nexceptions = f8
        3 percentage = f8
        3 patient_cnt = i4
        3 patients [* ]
          4 person_id = f8
          4 name = vc
          4 mrn = vc
          4 birth_date = vc
          4 outcome = vc
          4 outcome_ind = i2
          4 outcome_numeric = f8
          4 gender = vc
          4 race = vc
          4 ethnicity = vc
          4 payer = vc
          4 payer_group = vc
          4 hic = vc
          4 encntr_cnt = i4
          4 encntrs [* ]
            5 encntr_id = f8
            5 visit_date = vc
            5 fin = vc
            5 outcome = vc
            5 outcome_ind = i2
            5 br_eligible_provider_id = f8
  ) WITH public
 ENDIF
 IF ((validate (nqf22_summary ) = 0 ) )
  RECORD nqf22_summary (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 name = vc
      2 tax_id_nbr_txt = vc
      2 npi_nbr_txt = vc
      2 reportmean = vc
      2 patient_cnt = i4
      2 patients [* ]
        3 person_id = f8
        3 name = vc
        3 mrn = vc
        3 birth_date = vc
        3 outcome = vc
        3 outcome_ind = i2
        3 exclude_ind = i2
        3 encntr_cnt = i4
        3 encntrs [* ]
          4 encntr_id = f8
          4 visit_date = vc
          4 fin = vc
  ) WITH public
 ENDIF
 IF ((validate (ep_report ) = 0 ) )
  RECORD ep_report (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 name = vc
      2 first_name = vc
      2 last_name = vc
      2 addr1 = vc
      2 addr2 = vc
      2 city = vc
      2 state = vc
      2 zip5 = vc
      2 zip4 = vc
      2 phone = vc
      2 phone_ext = vc
      2 tax_id_nbr_txt = vc
      2 npi_nbr_txt = vc
      2 measure_cnt = i4
      2 measures [* ]
        3 reportmean = vc
        3 sortkey = i4
        3 patient_cnt = i4
        3 ippcnt = f8
        3 nnums = f8
        3 ndens = f8
        3 nexcs = f8
        3 nexceps = f8
        3 percent = f8
        3 patients [* ]
          4 person_id = f8
          4 name = vc
          4 mrn = vc
          4 birth_date = vc
          4 outcome = vc
          4 outcome_ind = i2
          4 outcome_numeric = f8
          4 sortkey = i4
          4 encntr_cnt = i4
          4 gender = vc
          4 race = vc
          4 ethnicity = vc
          4 payer = vc
          4 payer_group = vc
          4 hic = vc
          4 encntrs [* ]
            5 encntr_id = f8
            5 visit_date = vc
            5 fin = vc
            5 outcome = vc
            5 outcome_ind = i2
            5 sortkey = i4
  ) WITH public
 ENDIF
 IF ((validate (ep_report_muattest ) = 0 ) )
  RECORD ep_report_muattest (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 name = vc
      2 first_name = vc
      2 last_name = vc
      2 addr1 = vc
      2 addr2 = vc
      2 city = vc
      2 state = vc
      2 zip5 = vc
      2 zip4 = vc
      2 phone = vc
      2 phone_ext = vc
      2 tax_id_nbr_txt = vc
      2 npi_nbr_txt = vc
      2 measure_cnt = i4
      2 measures [* ]
        3 reportmean = vc
        3 reportname = vc
        3 sortkey = i4
        3 patient_cnt = i4
        3 ippcnt = f8
        3 nnums = f8
        3 ndens = f8
        3 nexcs = f8
        3 nexceps = f8
        3 percent = f8
        3 patients [* ]
          4 person_id = f8
          4 name = vc
          4 mrn = vc
          4 birth_date = vc
          4 outcome = vc
          4 outcome_ind = i2
          4 outcome_numeric = f8
          4 sortkey = i4
          4 encntr_cnt = i4
          4 gender = vc
          4 race = vc
          4 ethnicity = vc
          4 payer = vc
          4 payer_group = vc
          4 hic = vc
          4 encntrs [* ]
            5 encntr_id = f8
            5 visit_date = vc
            5 fin = vc
            5 outcome = vc
            5 outcome_ind = i2
            5 sortkey = i4
  ) WITH public
 ENDIF
 IF ((validate (ep_report_csv ) = 0 ) )
  RECORD ep_report_csv (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 name = vc
      2 tax_id_nbr_txt = vc
      2 npi_nbr_txt = vc
      2 measure_cnt = i4
      2 measures [* ]
        3 reportmean = vc
        3 reportname = vc
        3 measuredomain = vc
        3 measureseq = i4
        3 high_priority_ind = vc
        3 outcome_ind = vc
        3 meas_type = vc
        3 patient_cnt = i4
        3 ippcnt = f8
        3 nnums = vc
        3 ndens = f8
        3 nexcs = vc
        3 nexceps = vc
        3 percent = f8
        3 patients [* ]
          4 person_id = f8
          4 name = vc
          4 mrn = vc
          4 birth_date = vc
          4 outcome = vc
          4 outcome_ind = i2
          4 outcome_numeric = f8
          4 encntr_cnt = i4
          4 gender = vc
          4 race = vc
          4 ethnicity = vc
          4 payer = vc
          4 payer_group = vc
          4 hic = vc
          4 encntrs [* ]
            5 encntr_id = f8
            5 visit_date = vc
            5 fin = vc
            5 outcome = vc
            5 outcome_ind = i2
            5 outcome_key = i2
            5 outcome_numeric = f8
            5 isnumerator = vc
  ) WITH public
 ENDIF
 IF ((validate (temp_ep_report ) = 0 ) )
  RECORD temp_ep_report (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 name = vc
      2 first_name = vc
      2 last_name = vc
      2 addr1 = vc
      2 addr2 = vc
      2 city = vc
      2 state = vc
      2 zip5 = vc
      2 zip4 = vc
      2 phone = vc
      2 phone_ext = vc
      2 tax_id_nbr_txt = vc
      2 npi_nbr_txt = vc
      2 measure_cnt = i4
      2 measures [* ]
        3 reportmean = vc
        3 sortkey = i4
        3 patient_cnt = i4
        3 ippcnt = f8
        3 nnums = f8
        3 ndens = f8
        3 nexcs = f8
        3 nexceps = f8
        3 percent = f8
        3 patients [* ]
          4 person_id = f8
          4 name = vc
          4 mrn = vc
          4 birth_date = vc
          4 outcome = vc
          4 outcome_ind = i2
          4 outcome_numeric = f8
          4 sortkey = i4
          4 encntr_cnt = i4
          4 gender = vc
          4 race = vc
          4 ethnicity = vc
          4 payer = vc
          4 payer_group = vc
          4 hic = vc
          4 encntrs [* ]
            5 encntr_id = f8
            5 visit_date = vc
            5 fin = vc
            5 outcome = vc
            5 outcome_ind = i2
            5 sortkey = i4
  ) WITH public
 ENDIF
 IF ((validate (rpt ) = 0 ) )
  RECORD rpt (
    1 date_range = vc
    1 created_by = vc
    1 created_on = vc
    1 report_cnt = i4
    1 reports [* ]
      2 name = vc
      2 mean = vc
      2 seq = i4
      2 tin = vc
      2 npi = vc
      2 table_cnt = i4
      2 tables [* ]
        3 name = vc
        3 table_seq = i4
        3 row_cnt = i4
        3 rows [* ]
          4 cell_cnt = i4
          4 cells [* ]
            5 width = i4
            5 value = vc
    1 status = c1
    1 message = vc
  ) WITH public
 ENDIF
 IF ((validate (params ) = 0 ) )
  RECORD params (
    1 outdev = vc
    1 epfilter = vc
    1 orgfilter = i4
    1 optinitiative = vc
    1 year = vc
    1 start_dt = dq8
    1 end_dt = dq8
    1 quarter_year_month = vc
    1 brdefmeas = vc
    1 chksummaryonly = vc
    1 payerfilter = vc
    1 qrdamode = vc
    1 measure_cnt = i4
    1 measure_string = vc
    1 report_by = vc
    1 measures [* ]
      2 mean = vc
    1 grp_cnt = i4
    1 grps [* ]
      2 br_gpro_id = f8
      2 name = vc
      2 tax_id_nbr_txt = vc
      2 logical_domain_id = f8
      2 measure_cnt = i4
      2 measure_string = vc
      2 measures [* ]
        3 mean = vc
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 provider_id = f8
      2 npi_nbr_txt = vc
      2 tax_id_nbr_txt = vc
      2 include_ind = i2
      2 name = vc
      2 logical_domain_id = f8
      2 measure_cnt = i4
      2 measure_string = vc
      2 measures [* ]
        3 mean = vc
  ) WITH public
 ENDIF
 IF ((validate (ep_nomen ) = 0 ) )
  RECORD ep_nomen (
    1 qual [* ]
      2 source_vocab_id = vc
  ) WITH public
 ENDIF
 IF ((validate (ep_provider ) = 0 ) )
  RECORD ep_provider (
    1 qual [* ]
      2 provider_id = f8
      2 encntrs [* ]
        3 encntr_id = f8
        3 person_id = f8
  ) WITH public
 ENDIF
 IF ((validate (lh_bill_encntr_date ) = 0 ) )
  RECORD lh_bill_encntr_date (
    1 daycnt = i4
    1 days [* ]
      2 encntrday = dq8
      2 a_ind = i2
      2 b_ind = i2
      2 c_ind = i2
  ) WITH public
 ENDIF
 IF ((validate (encntr_a2_d2 ) = 0 ) )
  RECORD encntr_a2_d2 (
    1 persons [* ]
      2 person_id = f8
      2 encntrs [* ]
        3 encntr_id = f8
  ) WITH public
 ENDIF
 IF ((validate (lh_ep_provider ) = 0 ) )
  RECORD lh_ep_provider (
    1 epcnt = i4
    1 eps [* ]
      2 person_id = f8
      2 ep_id = f8
      2 ecnt = i4
      2 days [* ]
        3 encntrday = dq8
  ) WITH public
 ENDIF
 IF ((validate (lh_measures_chosen ) = 0 ) )
  RECORD lh_measures_chosen (
    1 measure_cnt = i2
    1 qual [* ]
      2 pop_group = vc
  ) WITH public
 ENDIF
 IF ((validate (lh_excl_loc ) = 0 ) )
  RECORD lh_excl_loc (
    1 unit_cnt = i2
    1 qual [* ]
      2 loc_nurse_unit_cd = f8
  ) WITH public
 ENDIF
 IF ((validate (tmp_br_def_epgpro_meas ) = 0 ) )
  RECORD tmp_br_def_epgpro_meas (
    1 ep_cnt = i4
    1 eps [* ]
      2 br_eligible_provider_id = f8
      2 logical_domain_id = f8
      2 measure_cnt = i4
      2 measures [* ]
        3 mean = vc
  ) WITH public
 ENDIF
 IF ((validate (filter_params ) = 0 ) )
  RECORD filter_params (
    1 tins [* ]
      2 br_gpro_id = f8
    1 sites [* ]
      2 br_cpc_id = f8
    1 provider_types [* ]
      2 lh_provider_type_id = f8
    1 eps [* ]
      2 br_eligible_provider_id = f8
    1 measures [* ]
      2 lh_cqm_meas_id = f8
      2 mean = vc
    1 insurance_item_id = f8
    1 gender_item_id = f8
    1 race_cd = f8
    1 ethnicity_cd = f8
    1 birthdate_low_dt_tm = dq8
    1 birthdate_high_dt_tm = dq8
    1 problem_vset_id = f8
    1 print_option = vc
    1 beg_extract_dt_tm = dq8
    1 end_extract_dt_tm = dq8
    1 report_mode = vc
    1 report_by = vc
    1 logical_domain_id = f8
    1 file_text = vc
  ) WITH public
 ENDIF
 IF ((validate (lh_med_recs ) = 0 ) )
  RECORD lh_med_recs (
    1 med_rec_cnt = i4
    1 qual [* ]
      2 encntr_id = f8
      2 rec_ep_dt_tm = dq8
      2 rec_ep_end_dt_tm = dq8
  ) WITH public
 ENDIF
 DECLARE lhprint ((text = vc ) ,(print_ind = i2 (value ,0 ) ) ) = null WITH public
 DECLARE getlocfilter (null ) = null
 DECLARE getepchargebimoption (null ) = null WITH public
 DECLARE isencounterlevelmeasure ((measure = vc ) ) = i2
 DECLARE hasnoexclusions ((measure = vc ) ) = i2
 DECLARE hasnoexceptions ((measure = vc ) ) = i2
 DECLARE uses_outcome_numeric ((measure = vc ) ) = i2
 DECLARE beg_time (null ) = null
 DECLARE end_time (null ) = null
 DECLARE nqf2cms_num ((nqf_num = i2 ) ) = i2
 DECLARE reportmean2cms_str ((rm = vc ) ) = vc
 DECLARE getstatename ((state = vc ) ) = vc
 DECLARE lhloaddimension ((table_name = vc ) ) = null
 DECLARE getmeasuredomain ((reportmean = vc ) ) = vc
 DECLARE getmeasuretype ((reportmean = vc ) ) = vc
 DECLARE getmeasurepriority ((reportmean = vc ) ) = vc
 DECLARE getcmsversion ((reportmean = vc ) ) = vc
 DECLARE lhgetdatetimedifference (date2 ,date1 ,factor ) = i2
 DECLARE checkoverlapsmeasurementperiod ((ep_dt_tm = dq8 ) ,(ep_end_dt_tm = dq8 ) ) = i2
 DECLARE checkduringmeasurementperiod ((ep_dt_tm = dq8 ) ) = i2
 DECLARE diagnosisdatecheck ((ep_dt_tm = dq8 ) ,(ep_end_dt_tm = dq8 ) ,(updt_source = vc ) ) = i2
 DECLARE lhgetutcoffset ((datetime = dq8 ) ,(timezone = i2 ) ) = vc
 DECLARE addattributiontodqueryifneeded (null ) = null
 DECLARE ep_charge_bim_option_ind = i2 WITH noconstant (0 )
 DECLARE beg_year_1800 = dq8 WITH protect ,constant (cnvtdatetime ("01-JAN-1800 00:00:00" ) )
 DECLARE beg_time_var = dq8 WITH noconstant (0 )
 DECLARE end_time_var = dq8 WITH noconstant (0 )
 SUBROUTINE  lhprint (text ,print_ind )
  DECLARE print_to_audit = i2 WITH noconstant (1 ) ,protect
  IF (validate (lh_print_suppress ) )
   IF ((lh_print_suppress = 1 )
   AND (print_ind = 0 ) )
    SET print_to_audit = 0
   ENDIF
  ENDIF
  IF ((print_to_audit = 1 ) )
   IF (validate (audit_filename ) )
    SELECT INTO value (audit_filename )
     FROM (dummyt )
     DETAIL
      IF ((size (text ,1 ) < 35000 ) )
       CALL print (text )
      ENDIF
     WITH noheading ,nocounter ,format = lfstream ,maxcol = 35000 ,maxrow = 1 ,append
    ;end select
   ELSE
    CALL echo (text )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  getlocfilter (null )
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_filter bdf ),
    (br_datamart_value bdv )
   PLAN (bdc
    WHERE (bdc.category_mean = category_mean ) )
    JOIN (bdf
    WHERE (bdf.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (bdf.filter_mean = "MUSE_UNITS_EXCL" ) )
    JOIN (bdv
    WHERE (bdv.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (bdv.br_datamart_filter_id = bdf.br_datamart_filter_id ) )
   ORDER BY bdv.parent_entity_id
   HEAD REPORT
    cnt = 0
   HEAD bdv.parent_entity_id
    cnt = (cnt + 1 ) ,stat = alterlist (lh_excl_loc->qual ,cnt ) ,lh_excl_loc->qual[cnt ].
    loc_nurse_unit_cd = bdv.parent_entity_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getepchargebimoption (null )
  DECLARE temp_charge_bim_option = i2 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (br_datamart_category cat ),
    (br_datamart_filter fil ),
    (br_datamart_value val )
   WHERE (cat.br_datamart_category_id = val.br_datamart_category_id )
   AND (cat.br_datamart_category_id = fil.br_datamart_category_id )
   AND (val.br_datamart_filter_id = fil.br_datamart_filter_id )
   AND (val.logical_domain_id = logical_domain_id )
   AND (fil.filter_mean = "EP_CHARGE_BIM_OPTION" )
   AND (cat.category_mean = category_mean )
   AND (val.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   DETAIL
    IF ((isnumeric (trim (val.freetext_desc ,3 ) ) > 0 ) ) temp_charge_bim_option = cnvtint (trim (
       val.freetext_desc ,3 ) )
    ENDIF
   WITH nocounter
  ;end select
  SET ep_charge_bim_option_ind = temp_charge_bim_option
  RETURN (temp_charge_bim_option )
 END ;Subroutine
 SUBROUTINE  isencounterlevelmeasure (measure )
  DECLARE return_val = i2 WITH noconstant (0 ) ,protect
  IF ((cnvtupper (measure ) IN ("MU_EC_0069_2019" ,
  "NQF2019_0069" ,
  "NQF69" ,
  "MU_EC_0081_2019.2" ,
  "MU_EC_0083_2019.2" ,
  "MU_EC_0104_2019" ,
  "NQF2019_0104" ,
  "NQF104" ,
  "MU_EC_0384_2019*" ,
  "NQF2019_0384" ,
  "NQF384" ,
  "MU_EC_0419_2019" ,
  "NQF2019_0419" ,
  "NQF419" ,
  "MU_EC_1365_2019" ,
  "NQF2019_1365" ,
  "NQF1365" ,
  "MU_EC_CMS146_2019" ,
  "CMS2019_0146" ,
  "CMS146" ) ) )
   SET return_val = 1
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  hasnoexclusions (measure )
  DECLARE return_val = i2 WITH noconstant (0 ) ,protect
  IF ((cnvtupper (measure ) IN ("MU_EC_0028_2019*" ,
  "NQF2019_0028" ,
  "NQF28" ,
  "MU_EC_0041_2019" ,
  "NQF2019_0041" ,
  "NQF41" ,
  "MU_EC_0070_2019*" ,
  "NQF2019_0070" ,
  "NQF70" ,
  "MU_EC_0081_2019*" ,
  "NQF2019_0081" ,
  "NQF81" ,
  "MU_EC_0083_2019*" ,
  "NQF2019_0083" ,
  "NQF83" ,
  "MU_EC_0104_2019" ,
  "NQF2019_0104" ,
  "NQF104" ,
  "MU_EC_0384_2019*" ,
  "NQF2019_0384" ,
  "NQF384" ,
  "MU_EC_0419_2019" ,
  "NQF2019_0419" ,
  "NQF419" ,
  "MU_EC_1365_2019" ,
  "NQF2019_1365" ,
  "NQF1365" ,
  "MU_EC_2872_2019" ,
  "NQF2019_2872" ,
  "NQF2872" ,
  "MU_EC_CMS50_2019" ,
  "CMS2019_0050" ,
  "CMS50" ,
  "MU_EC_CMS82_2019" ,
  "CMS2019_0082" ,
  "CMS82" ) ) )
   SET return_val = 1
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  hasnoexceptions (measure )
  DECLARE return_val = i2 WITH noconstant (0 ) ,protect
  IF ((cnvtupper (measure ) IN ("MU_EC_0004_2019*" ,
  "NQF2019_0004" ,
  "NQF0004" ,
  "MU_EC_0018_2019" ,
  "NQF2019_0018" ,
  "NQF0018" ,
  "MU_EC_0022_2019*" ,
  "NQF2019_0022" ,
  "NQF0022" ,
  "MU_EC_0024_2019*" ,
  "NQF2019_0024" ,
  "NQF0024" ,
  "MU_EC_0032_2019" ,
  "NQF2019_0032" ,
  "NQF32" ,
  "MU_EC_0033_2019*" ,
  "NQF2019_0033" ,
  "NQF33" ,
  "MU_EC_0034_2019" ,
  "NQF2019_0034" ,
  "NQF34" ,
  "MU_EC_0038_2019" ,
  "NQF2019_0038" ,
  "NQF38" ,
  "MU_EC_0055_2019" ,
  "NQF2019_0055" ,
  "NQF55" ,
  "MU_EC_0059_2019" ,
  "NQF2019_0059" ,
  "NQF59" ,
  "MU_EC_0062_2019" ,
  "NQF2019_0062" ,
  "NQF62" ,
  "MU_EC_0069_2019" ,
  "NQF2019_0069" ,
  "NQF69" ,
  "MU_EC_0101_2019" ,
  "NQF2019_0101" ,
  "NQF0101" ,
  "MU_EC_0104_2019" ,
  "NQF2019_0104" ,
  "NQF0104" ,
  "MU_EC_0384_2019*" ,
  "NQF2019_0384" ,
  "NQF384" ,
  "MU_EC_0710_2019*" ,
  "NQF2019_0710" ,
  "NQF710" ,
  "MU_EC_0712_2019*" ,
  "NQF2019_0712" ,
  "NQF712" ,
  "MU_EC_1365_2019" ,
  "NQF2019_1365" ,
  "NQF1365" ,
  "MU_EC_2372_2019" ,
  "NQF2019_2372" ,
  "NQF2372" ,
  "MU_EC_CMS50_2019" ,
  "CMS2019_0050" ,
  "CMS50" ,
  "MU_EC_CMS74_2019*" ,
  "CMS2019_0074" ,
  "CMS74" ,
  "MU_EC_CMS75_2019" ,
  "CMS2019_0075" ,
  "CMS75" ,
  "MU_EC_CMS82_2019" ,
  "CMS2019_0082" ,
  "CMS82" ,
  "MU_EC_CMS90_2019" ,
  "CMS2019_0090" ,
  "CMS90" ,
  "MU_EC_CMS127_2019" ,
  "CMS2019_0127" ,
  "CMS127" ,
  "MU_EC_CMS146_2019" ,
  "CMS2019_0146" ,
  "CMS146" ) ) )
   SET return_val = 1
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  beg_time (null )
  SET end_time_var = 0
  SET beg_time_var = cnvtdatetime (curdate ,curtime3 )
  CALL lhprint (build ("Start Time    :" ,format (beg_time_var ,";;q" ) ) )
 END ;Subroutine
 SUBROUTINE  uses_outcome_numeric (measure )
  DECLARE return_val = i2 WITH noconstant (0 ) ,protect
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  end_time (null )
  SET end_time_var = cnvtdatetime (curdate ,curtime3 )
  CALL lhprint (build ("End Time      :" ,format (end_time_var ,";;q" ) ) )
  CALL lhprint (build ("Elapsed Time  :" ,datetimediff (end_time_var ,beg_time_var ,5 ) ) )
  CALL lhprint (" " )
  SET beg_time_var = 0
 END ;Subroutine
 SUBROUTINE  reportmean2cms_str (rm )
  DECLARE cms_str = vc WITH protect ,noconstant ("" )
  DECLARE core_str = vc WITH protect ,noconstant ("" )
  DECLARE pos_ep_ = i4 WITH protect ,noconstant (findstring ("EP_" ,cnvtupper (rm ) ) )
  DECLARE pos_2019 = i4 WITH protect ,noconstant (findstring ("_2019" ,rm ) )
  DECLARE pos_second_under = i4 WITH protect ,noconstant (findstring ("_" ,rm ,pos_ep_ ) )
  IF ((pos_ep_ > 0 )
  AND (pos_2019 > 0 )
  AND (pos_second_under > 0 ) )
   SET core_str = substring ((pos_second_under + 1 ) ,((pos_2019 - pos_second_under ) - 1 ) ,
    cnvtupper (rm ) )
  ENDIF
  IF ((core_str != "" ) )
   IF ((substring (1 ,1 ,core_str ) = "C" ) )
    SET cms_str = core_str
   ELSE
    SET cms_str = build ("CMS" ,nqf2cms_num (cnvtint (core_str ) ) )
   ENDIF
  ENDIF
  RETURN (cms_str )
 END ;Subroutine
 SUBROUTINE  nqf2cms_num (nqf_num )
  DECLARE cms_num = i2 WITH protect ,noconstant (- (1 ) )
  CASE (nqf_num )
   OF 4 :
    SET cms_num = 137
   OF 18 :
    SET cms_num = 165
   OF 22 :
    SET cms_num = 156
   OF 24 :
    SET cms_num = 155
   OF 28 :
    SET cms_num = 138
   OF 32 :
    SET cms_num = 124
   OF 33 :
    SET cms_num = 153
   OF 34 :
    SET cms_num = 130
   OF 38 :
    SET cms_num = 117
   OF 41 :
    SET cms_num = 147
   OF 55 :
    SET cms_num = 131
   OF 59 :
    SET cms_num = 122
   OF 62 :
    SET cms_num = 134
   OF 69 :
    SET cms_num = 154
   OF 70 :
    SET cms_num = 145
   OF 81 :
    SET cms_num = 135
   OF 83 :
    SET cms_num = 144
   OF 101 :
    SET cms_num = 139
   OF 104 :
    SET cms_num = 161
   OF 384 :
    SET cms_num = 157
   OF 418 :
    SET cms_num = 2
   OF 419 :
    SET cms_num = 68
   OF 421 :
    SET cms_num = 69
   OF 710 :
    SET cms_num = 159
   OF 712 :
    SET cms_num = 160
   OF 1365 :
    SET cms_num = 177
   OF 2372 :
    SET cms_num = 125
   OF 2872 :
    SET cms_num = 149
  ENDCASE
  RETURN (cms_num )
 END ;Subroutine
 SUBROUTINE  getstatename (state )
  DECLARE return_val = vc WITH protect ,noconstant (state )
  IF ((state = "*DISTRICT*COLUMBIA*" ) )
   SET return_val = "DC"
  ELSEIF ((state = "*MARIANA*" ) )
   SET return_val = "MP"
  ELSEIF ((state = "*SAMOA*" ) )
   SET return_val = "AS"
  ELSEIF ((state = "*PUERTO*" ) )
   SET return_val = "PR"
  ELSEIF ((state = "*VIRGIN*ISLAND*" ) )
   SET return_val = "VI"
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  lhloaddimension (table_name )
  DECLARE min_from_dt_tm = dq8
  DECLARE max_to_dt_tm = dq8
  DECLARE load_cmd = vc
  DECLARE select_extract_var = vc
  DECLARE cnt = i4 WITH noconstant (0 )
  DECLARE logical_cond = vc WITH protect
  IF ((checkdic (concat (cnvtupper (table_name ) ,".LOGICAL_DOMAIN_ID" ) ,"A" ,0 ) > 0 ) )
   SET logical_cond = "AND t.logical_domain_id = LOGICAL_DOMAIN_ID"
  ELSE
   SET logical_cond = "AND 1=1"
  ENDIF
  IF ((checkdic (concat (cnvtupper (table_name ) ,".EXTRACT_DT_TM" ) ,"A" ,0 ) > 0 ) )
   SET select_extract_var = concat ('SELECT INTO "nl:" FROM ' ,table_name ,
    " t WHERE t.extract_dt_tm is not null " ,logical_cond ," ORDER BY t.extract_dt_tm desc " ,
    ' FOOT REPORT min_from_dt_tm = CNVTDATETIME(NULLVAL(t.extract_dt_tm,CNVTDATETIME("01-JAN-1800")))'
    ," WITH MAXREC = 1" )
   CALL parser (select_extract_var )
   CALL parser ("GO" )
  ENDIF
  IF ((min_from_dt_tm = 0 ) )
   SET min_from_dt_tm = cnvtdatetime ("01-JAN-1800" )
  ENDIF
  SET max_to_dt_tm = cnvtdatetime (curdate ,curtime3 )
  CALL lhprint (" " )
  CALL lhprint ("-------------------------------------" )
  CALL lhprint (concat ("Dimension table: " ,table_name ) )
  CALL lhprint (concat ("Update date range : " ,format (min_from_dt_tm ,"MM/DD/YYYY HH:MM:SS;;Q" ) ,
    " To " ,format (max_to_dt_tm ,"MM/DD/YYYY HH:MM:SS;;Q" ) ) )
  SET load_cmd = concat ("execute " ,table_name ," " ,build (min_from_dt_tm ) ,"," ,build (
    max_to_dt_tm ) ,"," ,build (logical_domain_id ) )
  CALL parser (load_cmd )
  CALL parser ("GO" )
 END ;Subroutine
 SUBROUTINE  getmeasuredomain (reportmean )
  DECLARE measuredomain = vc WITH protect ,noconstant ("Measure domain not found!" )
  IF ((cnvtupper (reportmean ) IN ("MU_EC_0024_2019*" ,
  "MU_EC_0028_2019*" ,
  "MU_EC_0033_2019*" ,
  "MU_EC_0038_2019" ,
  "MU_EC_0041_2019" ,
  "MU_EC_0418_2019" ,
  "MU_EC_0421_2019" ,
  "MU_EC_CMS22_2019" ,
  "MU_EC_CMS75_2019" ,
  "MU_EC_CMS82_2019" ,
  "MU_EC_CMS127_2019" ) ) )
   SET measuredomain = "Community/Population Health"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0004_2019*" ,
  "MU_EC_0018_2019" ,
  "MU_EC_0032_2019" ,
  "MU_EC_0034_2019" ,
  "MU_EC_0055_2019" ,
  "MU_EC_0059_2019" ,
  "MU_EC_0062_2019" ,
  "MU_EC_0070_2019*" ,
  "MU_EC_0081_2019*" ,
  "MU_EC_0083_2019*" ,
  "MU_EC_0104_2019" ,
  "MU_EC_0710_2019*" ,
  "MU_EC_0712_2019*" ,
  "MU_EC_2372_2019" ,
  "MU_EC_2872_2019" ,
  "MU_EC_CMS74_2019*" ) ) )
   SET measuredomain = "Effective Clinical Care"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0069_2019" ,
  "MU_EC_CMS146_2019" ) ) )
   SET measuredomain = "Efficiency and Cost Reduction"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0022_2019*" ,
  "MU_EC_0101_2019" ,
  "MU_EC_0419_2019" ,
  "MU_EC_1365_2019" ) ) )
   SET measuredomain = "Patient Safety"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0384_2019*" ,
  "MU_EC_CMS90_2019" ) ) )
   SET measuredomain = "Person and Caregiver-Centered Experience and Outcomes"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_CMS50_2019" ) ) )
   SET measuredomain = "Communication and Care Coordination"
  ENDIF
  RETURN (measuredomain )
 END ;Subroutine
 SUBROUTINE  getmeasuretype (reportmean )
  DECLARE measuretype = vc WITH protect ,noconstant ("Measure Type Not Found! Check the report mean"
   )
  IF ((cnvtupper (reportmean ) IN ("MU_EC_0004_2019*" ,
  "MU_EC_0022_2019*" ,
  "MU_EC_0024_2019*" ,
  "MU_EC_0028_2019*" ,
  "MU_EC_0032_2019" ,
  "MU_EC_0033_2019*" ,
  "MU_EC_0034_2019" ,
  "MU_EC_0038_2019" ,
  "MU_EC_0041_2019" ,
  "MU_EC_0055_2019" ,
  "MU_EC_0062_2019" ,
  "MU_EC_0069_2019" ,
  "MU_EC_0070_2019*" ,
  "MU_EC_0081_2019*" ,
  "MU_EC_0083_2019*" ,
  "MU_EC_0101_2019" ,
  "MU_EC_0104_2019" ,
  "MU_EC_0384_2019*" ,
  "MU_EC_0418_2019" ,
  "MU_EC_0419_2019" ,
  "MU_EC_0421_2019" ,
  "MU_EC_0712_2019*" ,
  "MU_EC_1365_2019" ,
  "MU_EC_2372_2019" ,
  "MU_EC_2872_2019" ,
  "MU_EC_CMS22_2019" ,
  "MU_EC_CMS50_2019" ,
  "MU_EC_CMS74_2019*" ,
  "MU_EC_CMS82_2019" ,
  "MU_EC_CMS90_2019" ,
  "MU_EC_CMS127_2019" ,
  "MU_EC_CMS146_2019" ) ) )
   SET measuretype = "Process"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0018_2019" ,
  "MU_EC_0059_2019" ) ) )
   SET measuretype = "Intermediate Outcome"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0710_2019*" ,
  "MU_EC_CMS75_2019" ) ) )
   SET measuretype = "Outcome"
  ENDIF
  RETURN (measuretype )
 END ;Subroutine
 SUBROUTINE  getmeasurepriority (reportmean )
  DECLARE measurepriority = vc WITH protect ,noconstant ("N/A" )
  SELECT INTO "nl:"
   FROM (lh_cqm_meas lh )
   WHERE (lh.meas_ident = "MU_EC_*_2019" )
   HEAD lh.meas_ident
    pos = findstring (trim (lh.meas_ident ) ,reportmean ) ,
    IF ((pos > 0 ) )
     IF ((lh.high_priority_ind = 1 ) ) measurepriority = "Yes"
     ELSEIF ((lh.high_priority_ind = 0 ) ) measurepriority = "No"
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  RETURN (measurepriority )
 END ;Subroutine
 SUBROUTINE  getcmsversion (reportmean )
  DECLARE cmsversion = vc WITH protect ,noconstant ("CMS Version Not Found! Check the report mean" )
  IF ((cnvtupper (reportmean ) IN ("MU_EC_0022_2019*" ,
  "MU_EC_0028_2019*" ,
  "MU_EC_CMS82_2019" ) ) )
   SET cmsversion = "v6"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0004_2019*" ,
  "MU_EC_0018_2019" ,
  "MU_EC_0024_2019*" ,
  "MU_EC_0032_2019" ,
  "MU_EC_0033_2019*" ,
  "MU_EC_0034_2019" ,
  "MU_EC_0038_2019" ,
  "MU_EC_0055_2019" ,
  "MU_EC_0059_2019" ,
  "MU_EC_0062_2019" ,
  "MU_EC_0069_2019" ,
  "MU_EC_0070_2019*" ,
  "MU_EC_0081_2019*" ,
  "MU_EC_0083_2019*" ,
  "MU_EC_0101_2019" ,
  "MU_EC_0104_2019" ,
  "MU_EC_0384_2019*" ,
  "MU_EC_0421_2019" ,
  "MU_EC_0710_2019*" ,
  "MU_EC_0712_2019*" ,
  "MU_EC_1365_2019" ,
  "MU_EC_2372_2019" ,
  "MU_EC_2872_2019" ,
  "MU_EC_CMS22_2019" ,
  "MU_EC_CMS50_2019" ,
  "MU_EC_CMS75_2019" ,
  "MU_EC_CMS127_2019" ,
  "MU_EC_CMS146_2019" ) ) )
   SET cmsversion = "v7"
  ELSEIF ((cnvtupper (reportmean ) IN ("MU_EC_0041_2019" ,
  "MU_EC_0418_2019" ,
  "MU_EC_0419_2019" ,
  "MU_EC_CMS74_2019*" ,
  "MU_EC_CMS90_2019" ) ) )
   SET cmsversion = "v8"
  ENDIF
  RETURN (cmsversion )
 END ;Subroutine
 SUBROUTINE  diagnosisdatecheck (ep_dt_tm ,ep_end_dt_tm ,updt_source )
  DECLARE diagnosisdatecheckind = i2 WITH noconstant (0 ) ,protect
  IF ((updt_source = "IMPORT*" ) )
   SET diagnosisdatecheckind = checkoverlapsmeasurementperiod (ep_dt_tm ,ep_end_dt_tm )
  ELSE
   SET diagnosisdatecheckind = checkduringmeasurementperiod (ep_dt_tm )
  ENDIF
  RETURN (diagnosisdatecheckind )
 END ;Subroutine
 SUBROUTINE  checkoverlapsmeasurementperiod (ep_dt_tm ,ep_end_dt_tm )
  DECLARE overlapscheckind = i2 WITH noconstant (0 ) ,protect
  IF ((ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
   IF ((((ep_end_dt_tm = null ) ) OR ((ep_end_dt_tm >= cnvtdatetime (beg_extract_dt_tm ) ) )) )
    SET overlapscheckind = 1
   ENDIF
  ENDIF
  RETURN (overlapscheckind )
 END ;Subroutine
 SUBROUTINE  checkduringmeasurementperiod (ep_dt_tm )
  DECLARE duringcheckind = i2 WITH noconstant (0 ) ,protect
  IF ((ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm ) ) )
   SET duringcheckind = 1
  ENDIF
  RETURN (duringcheckind )
 END ;Subroutine
 SUBROUTINE  lhgetdatetimedifference (date2 ,date1 ,factor )
  DECLARE datetimedifference = i2 WITH protect ,noconstant (0 )
  DECLARE year1 = i2 WITH protect ,noconstant (0 )
  DECLARE month1 = i2 WITH protect ,noconstant (0 )
  DECLARE day1 = i2 WITH protect ,noconstant (0 )
  DECLARE year2 = i2 WITH protect ,noconstant (0 )
  DECLARE month2 = i2 WITH protect ,noconstant (0 )
  DECLARE day2 = i2 WITH protect ,noconstant (0 )
  IF ((date2 >= date1 ) )
   SET year1 = cnvtint (format (datetimetrunc (cnvtdatetime (date1 ) ,"YY" ) ,"YYYY;;q" ) )
   SET month1 = cnvtint (format (datetimetrunc (cnvtdatetime (date1 ) ,"MM" ) ,"MM;;q" ) )
   SET day1 = cnvtint (format (datetimetrunc (cnvtdatetime (date1 ) ,"DD" ) ,"DD;;q" ) )
   SET year2 = cnvtint (format (datetimetrunc (cnvtdatetime (date2 ) ,"YY" ) ,"YYYY;;q" ) )
   SET month2 = cnvtint (format (datetimetrunc (cnvtdatetime (date2 ) ,"MM" ) ,"MM;;q" ) )
   SET day2 = cnvtint (format (datetimetrunc (cnvtdatetime (date2 ) ,"DD" ) ,"DD;;q" ) )
   CASE (cnvtupper (factor ) )
    OF "Y" :
     IF ((month2 < month1 ) )
      SET datetimedifference = ((year2 - year1 ) - 1 )
     ELSEIF ((month2 = month1 )
     AND (day2 >= day1 ) )
      SET datetimedifference = (year2 - year1 )
     ELSEIF ((month2 = month1 )
     AND (day2 < day1 ) )
      SET datetimedifference = ((year2 - year1 ) - 1 )
     ELSEIF ((month2 > month1 ) )
      SET datetimedifference = (year2 - year1 )
     ENDIF
    OF "MO" :
     IF ((day2 >= day1 ) )
      SET datetimedifference = (((year2 - year1 ) * 12 ) + (month2 - month1 ) )
     ELSE
      SET datetimedifference = ((((year2 - year1 ) * 12 ) + (month2 - month1 ) ) - 1 )
     ENDIF
    OF "D" :
     SET datetimedifference = datetimediff (datetimetrunc (cnvtdatetime (date2 ) ,"DD" ) ,
      datetimetrunc (cnvtdatetime (date1 ) ,"DD" ) )
    OF "H" :
     SET datetimedifference = floor ((datetimediff (datetimetrunc (cnvtdatetime (date2 ) ,"MI" ) ,
       datetimetrunc (cnvtdatetime (date1 ) ,"MI" ) ) * 24 ) )
    OF "M" :
     SET datetimedifference = floor (datetimediff (datetimetrunc (cnvtdatetime (date2 ) ,"MI" ) ,
       datetimetrunc (cnvtdatetime (date1 ) ,"MI" ) ,4 ) )
    ELSE
     SET datetimedifference = - (1 )
   ENDCASE
  ELSE
   SET datetimedifference = - (1 )
  ENDIF
  RETURN (datetimedifference )
 END ;Subroutine
 SUBROUTINE  lhgetutcoffset (datetime ,timezone )
  DECLARE offsetvar = i4 WITH protect ,noconstant (0 )
  DECLARE daylightvar = i4 WITH protect ,noconstant (0 )
  DECLARE zone = vc WITH protect ,noconstant ("" )
  DECLARE standardzone = vc WITH protect ,noconstant ("" )
  DECLARE offsetcentiseconds = f8 WITH protect ,noconstant (0.0 )
  DECLARE offset = vc WITH protect ,noconstant ("" )
  SET zone = datetimezonebyindex (timezone ,offsetvar ,daylightvar ,7 ,datetime )
  SET standardzone = datetimezonebyindex (timezone ,offsetvar ,daylightvar ,3 ,datetime )
  SET offsetcentiseconds = (offsetvar / 10.0 )
  IF ((standardzone != datetimezoneformat (datetime ,timezone ,"ZZZ" ) ) )
   SET offsetcentiseconds = (offsetcentiseconds + (daylightvar / 10.0 ) )
  ENDIF
  IF ((offsetcentiseconds >= 0 ) )
   SET offset = format (cnvtdatetime (0 ,offsetcentiseconds ) ,"+HHMM;;M" )
  ELSE
   SET offset = format (cnvtdatetime (0 ,abs (offsetcentiseconds ) ) ,"-HHMM;;M" )
  ENDIF
  RETURN (offset )
 END ;Subroutine
 SUBROUTINE  addattributiontodqueryifneeded (null )
  DECLARE queryexistsontable = i2 WITH protect ,noconstant (0 )
  DECLARE populationgroup = vc WITH protect ,constant ("NQF2019_0000" )
  DECLARE querycounter = i4 WITH protect ,noconstant (0 )
  SET errcode = error (errmsg ,0 )
  FREE RECORD attribquerynames
  RECORD attribquerynames (
    1 names [* ]
      2 queryname = vc
  )
  SET stat = alterlist (attribquerynames->names ,4 )
  SET attribquerynames->names[1 ].queryname = "NQF2019_REPORT_ATTRIB"
  SET attribquerynames->names[2 ].queryname = "NQF2019_REPORT_ATTRIB_IMPORT"
  SET attribquerynames->names[3 ].queryname = "NQF2019_CPC_ATTRIB"
  SET attribquerynames->names[4 ].queryname = "NQF2019_CPC_ATTRIB_IMPORT"
  FOR (querycounter = 1 TO size (attribquerynames->names ,5 ) )
   SET queryexistsontable = 0
   SELECT INTO "nl:"
    FROM (lh_d_query qry )
    WHERE (trim (cnvtupper (qry.query_name ) ,3 ) = trim (cnvtupper (attribquerynames->names[
      querycounter ].queryname ) ,3 ) )
    HEAD REPORT
     queryexistsontable = 1
    WITH nocounter
   ;end select
   IF ((queryexistsontable = 0 ) )
    INSERT FROM (lh_d_query qry )
     SET qry.d_query_id = seq (lh_seq ,nextval ) ,
      qry.query_name = value (attribquerynames->names[querycounter ].queryname ) ,
      qry.population_group = populationgroup ,
      qry.active_ind = 1 ,
      qry.updt_cnt = 0 ,
      qry.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      qry.updt_task = "LIGHTHOUSE LOAD" ,
      qry.updt_source = "lh_nqf2019_report.prg" ,
      qry.extract_dt_tm = cnvtdatetime (extract_dt_tm )
     WITH nocounter
    ;end insert
   ENDIF
  ENDFOR
  SET errcode = error (errmsg ,0 )
  IF ((errcode != 0 ) )
   CALL lhprint (" " )
   CALL lhprint ("Error in LH_D_QUERY Attribution Insert" )
   CALL lhprint (errmsg )
   ROLLBACK
  ELSE
   COMMIT
  ENDIF
  SET errcode = error (errmsg ,1 )
 END ;Subroutine
 DECLARE getproviderattribution ((measure = vc ) ) = i4
 DECLARE geteprfilter ((measure = vc ) ) = null
 DECLARE getepdata ((reportmean = vc ) ,(reltnopt = i2 ) ,(pop_group = vc ) ) = null
 DECLARE doattribution ((reportmean = vc ) ,(pop_group = vc ) ,(attrb_type = i2 ) ,(attributionhint
  = vc ) ) = null
 DECLARE doattributionimport ((reportmean = vc ) ,(pop_group = vc ) ,(attrb_type = i2 ) ,(
  attributionhint = vc ) ) = null
 DECLARE getnonmappednomenclature ((value_set_name = vc ) ,(meas_type = vc ) ,(cd_typ_var = vc ) ,(
  drug_ex = vc ) ) = null
 DECLARE retrievedemographics ((pop_group = vc ) ) = null
 DECLARE get_birth_dt_tm ((lh_ep_reply = vc (ref ) ) ) = null
 DECLARE getattributionhint ((attributionversion = vc ) ) = vc
 SUBROUTINE  getproviderattribution (measure )
  DECLARE logical_domain_parser = vc WITH protect ,noconstant ("1=1" )
  IF ((pwx_ind = 1 ) )
   SET logical_domain_parser = "1=1"
  ELSE
   SET logical_domain_parser = "bdv.logical_domain_id = LOGICAL_DOMAIN_ID"
  ENDIF
  CALL lhprint (build (";getProviderAttribution --" ) )
  CALL beg_time (0 )
  DECLARE filter_mean = vc WITH noconstant (build ("PROVIDER_ATTRIBUTE_" ,measure ) ) ,protect
  DECLARE attribution = i4 WITH noconstant (1 ) ,protect
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_filter bdf ),
    (br_datamart_value bdv )
   PLAN (bdc
    WHERE (bdc.category_mean = category_mean ) )
    JOIN (bdf
    WHERE (bdf.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (bdf.filter_mean = filter_mean ) )
    JOIN (bdv
    WHERE (bdv.br_datamart_category_id = bdf.br_datamart_category_id )
    AND (bdv.br_datamart_filter_id = bdf.br_datamart_filter_id )
    AND parser (logical_domain_parser ) )
   DETAIL
    attribution = cnvtint (bdv.freetext_desc )
   WITH nocounter
  ;end select
  CALL lhprint (build ("Provider Attribution :" ,attribution ) )
  CALL end_time (0 )
  RETURN (attribution )
 END ;Subroutine
 SUBROUTINE  geteprfilter (measure )
  DECLARE logical_domain_parser = vc WITH protect ,noconstant ("1=1" )
  SET br_filters->provider_attribution = getproviderattribution (measure )
  IF ((pwx_ind = 1 ) )
   SET logical_domain_parser = "1=1"
  ELSE
   SET logical_domain_parser = "bdv.logical_domain_id = LOGICAL_DOMAIN_ID"
  ENDIF
  CALL lhprint (build (";getEPRFilter --" ) )
  CALL beg_time (0 )
  DECLARE filter_mean = vc WITH noconstant (build ("ENC_PRSNL_" ,measure ) ) ,protect
  SELECT INTO "nl:"
   FROM (br_datamart_category bdc ),
    (br_datamart_filter bdf ),
    (br_datamart_value bdv )
   PLAN (bdc
    WHERE (bdc.category_mean = category_mean ) )
    JOIN (bdf
    WHERE (bdf.br_datamart_category_id = bdc.br_datamart_category_id )
    AND (bdf.filter_mean = filter_mean ) )
    JOIN (bdv
    WHERE (bdv.br_datamart_category_id = bdf.br_datamart_category_id )
    AND (bdv.br_datamart_filter_id = bdf.br_datamart_filter_id )
    AND parser (logical_domain_parser ) )
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (br_filters->epr_cnt + 1 ) ,
    br_filters->epr_cnt = cnt ,
    stat = alterlist (br_filters->eprs ,cnt ) ,
    br_filters->eprs[cnt ].code_value = bdv.parent_entity_id
   WITH nocounter
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  doattribution (reportmean ,pop_group ,attrb_type ,attributionhint )
  DECLARE attribution_option_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE code_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE num2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE batch_size = i4 WITH constant (15 ) ,protect
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_check = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_i = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_counter = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_batch = i4 WITH noconstant (25000 ) ,protect
  DECLARE person_pos2 = i4 WITH noconstant (0 ) ,protect
  DECLARE persons_size = i4 WITH noconstant (0 ) ,protect
  DECLARE person_batch_size = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Attribution" )
  CALL lhprint (build (";Report Mean: " ,reportmean ) )
  CALL lhprint (build (";Population Group: " ,pop_group ) )
  CALL lhprint (build (";Attribution type: " ,attrb_type ) )
  CALL lhprint (build (";Attribution hint: " ,attributionhint ) )
  IF ((validate (lh_query_ids ) = 0 ) )
   RECORD lh_query_ids (
     1 pop_group = vc
     1 qry_cnt = i4
     1 qual [* ]
       2 d_query_id = f8
   ) WITH public
  ENDIF
  IF ((attrb_type = 1 ) )
   SET attribution_option_parser = "laer.attribution_option = '1'"
   SET code_parser =
   "expand(num, 1, br_filters->epr_cnt, laer.encntr_prsnl_r_cd, br_filters->eprs[num].code_value) "
  ELSEIF ((attrb_type = 2 ) )
   SET code_parser =
   "expand(num, 1, size(ep_nomen->qual,5), laer.charge_reltn_cd, ep_nomen->qual[num].source_vocab_id) "
   IF ((ep_charge_bim_option_ind = 0 ) )
    SET attribution_option_parser = "laer.attribution_option = '2B'"
   ELSE
    SET attribution_option_parser = "laer.attribution_option = '2C'"
   ENDIF
  ENDIF
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_d_query qry )
   WHERE (qry.population_group = pop_group )
   AND (qry.active_ind = 1 )
   HEAD REPORT
    qry_cnt = 0 ,
    lh_query_ids->pop_group = pop_group
   HEAD qry.d_query_id
    qry_cnt = (qry_cnt + 1 ) ,stat = alterlist (lh_query_ids->qual ,qry_cnt ) ,lh_query_ids->qual[
    qry_cnt ].d_query_id = qry.d_query_id
   FOOT REPORT
    lh_query_ids->qry_cnt = qry_cnt
   WITH nocounter
  ;end select
  SET persons_size = size (lh_ep_reply->persons ,5 )
  SET person_batch_size = 5000
  SET person_iter = 1
  SET iter2 = 0
  IF ((persons_size < person_batch_size ) )
   SET person_batch_size = persons_size
  ENDIF
  WHILE ((person_iter <= persons_size ) )
   IF (((person_iter + person_batch_size ) > persons_size ) )
    SET person_batch_size = (persons_size - person_iter )
   ELSE
    SET person_batch_size = 5000
   ENDIF
   SELECT
    IF ((attributionhint != "" ) )
     WITH nocounter ,expand = 1 ,orahintcbo (value (attributionhint ) )
    ELSE
    ENDIF
    INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 pop ),
     (lh_amb_ep_reltn_2019 laer ),
     (br_eligible_provider ep ),
     (br_gpro_reltn gr ),
     (br_gpro g )
    PLAN (pop
     WHERE expand (iter1 ,person_iter ,(person_iter + person_batch_size ) ,pop.person_id ,lh_ep_reply
      ->persons[iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
     AND (pop.active_ind = 1 )
     AND (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) )
     AND expand (iter2 ,1 ,lh_query_ids->qry_cnt ,pop.d_query_id ,lh_query_ids->qual[iter2 ].
      d_query_id ) )
     JOIN (laer
     WHERE (laer.lh_amb_qual_encntr_2019_id = pop.lh_amb_qual_encntr_2019_id )
     AND parser (code_parser )
     AND (laer.active_ind = 1 )
     AND parser (attribution_option_parser ) )
     JOIN (ep
     WHERE expand (num ,1 ,params->ep_cnt ,(ep.br_eligible_provider_id + 0 ) ,params->eps[num ].
      br_eligible_provider_id )
     AND (laer.provider_id = ep.provider_id )
     AND (ep.active_ind = 1 ) )
     JOIN (gr
     WHERE (gr.active_ind = 1 )
     AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (gr.parent_entity_id = ep.br_eligible_provider_id ) )
     JOIN (g
     WHERE (g.active_ind = 1 )
     AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (g.br_gpro_id = gr.br_gpro_id ) )
    ORDER BY ep.provider_id ,
     g.br_gpro_id ,
     pop.person_id ,
     pop.encntr_id
    HEAD REPORT
     epcnt = 0 ,
     ep_pos = 0
    HEAD ep.provider_id
     dummy = 0
    HEAD g.br_gpro_id
     ep_pos = locateval (ep_i ,1 ,size (ep_summary->eps ,5 ) ,ep.provider_id ,ep_summary->eps[ep_i ].
      provider_id ,reportmean ,ep_summary->eps[ep_i ].reportmean ,g.tax_id_nbr_txt ,ep_summary->eps[
      ep_i ].tax_id_nbr_txt ) ,
     IF ((ep_pos > 0 ) ) epcnt = ep_pos
     ELSE epcnt = (ep_summary->ep_cnt + 1 ) ,ep_summary->ep_cnt = epcnt ,stat = alterlist (ep_summary
       ->eps ,epcnt )
     ENDIF
     ,ep_summary->eps[epcnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_summary->eps[
     epcnt ].provider_id = ep.provider_id ,ep_summary->eps[epcnt ].tax_id_nbr_txt = g.tax_id_nbr_txt
     ,ep_summary->eps[epcnt ].gpro_name = g.br_gpro_name ,ep_summary->eps[epcnt ].npi_nbr_txt = ep
     .national_provider_nbr_txt ,ep_summary->eps[epcnt ].reportmean = reportmean ,ptcnt = 0
    HEAD pop.person_id
     person_pos = locateval (person_i ,1 ,size (ep_summary->eps[epcnt ].patients ,5 ) ,pop.person_id
      ,ep_summary->eps[epcnt ].patients[person_i ].person_id ) ,person_pos2 = locateval (person_i ,1
      ,size (lh_ep_reply->persons ,5 ) ,pop.person_id ,lh_ep_reply->persons[person_i ].person_id ) ,
     IF ((person_pos2 > 0 )
     AND (lh_ep_reply->persons[person_pos2 ].updt_src_ind IN (1 ,
     3 ) ) )
      IF ((person_pos > 0 ) ) ptcnt = person_pos
      ELSE ptcnt = (ep_summary->eps[epcnt ].patient_cnt + 1 ) ,ep_summary->eps[epcnt ].patient_cnt =
       ptcnt ,stat = alterlist (ep_summary->eps[epcnt ].patients ,ptcnt )
      ENDIF
      ,ep_summary->eps[epcnt ].patients[ptcnt ].person_id = pop.person_id ,ep_summary->eps[epcnt ].
      patients[ptcnt ].mrn = lh_ep_reply->persons[person_pos2 ].mrn ,ep_summary->eps[epcnt ].
      patients[ptcnt ].birth_date = format (lh_ep_reply->persons[person_pos2 ].birth_date ,
       "mm/dd/yyyy;;q" ) ,ecnt = 0 ,enc_pos = 0 ,encntr_check = 0
     ENDIF
    HEAD pop.encntr_id
     enc_pos = locateval (enc_iter ,1 ,lh_ep_reply->persons[person_pos2 ].encntr_cnt ,pop.encntr_id ,
      lh_ep_reply->persons[person_pos2 ].encntrs[enc_iter ].encntr_id ) ,
     IF ((enc_pos > 0 )
     AND (lh_ep_reply->persons[person_pos2 ].encntrs[enc_pos ].exclude_ind = 0 ) ) lh_ep_reply->
      persons[person_pos2 ].encntrs[enc_pos ].ep_ind = 1 ,ecnt = (ep_summary->eps[epcnt ].patients[
      ptcnt ].encntr_cnt + 1 ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntr_cnt = ecnt ,stat =
      alterlist (ep_summary->eps[epcnt ].patients[ptcnt ].encntrs ,ecnt ) ,ep_summary->eps[epcnt ].
      patients[ptcnt ].encntrs[ecnt ].encntr_id = pop.encntr_id ,ep_summary->eps[epcnt ].patients[
      ptcnt ].encntrs[ecnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_summary->eps[
      epcnt ].patients[ptcnt ].encntrs[ecnt ].visit_date = format (pop.reg_dt_tm ,"mm/dd/yyyy;;q" ) ,
      ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[ecnt ].fin = lh_ep_reply->persons[person_pos2
      ].encntrs[enc_pos ].fin ,encntr_check = 1
     ENDIF
    FOOT  pop.person_id
     IF ((encntr_check = 1 ) ) lh_ep_reply->persons[person_pos2 ].ep_ind = 1
     ENDIF
    WITH nocounter ,expand = 1
   ;end select
   SET person_iter = ((person_iter + person_batch_size ) + 1 )
   IF ((attrib_counter = attrib_batch ) )
    CALL lhprint (attrib_counter )
    CALL lhprint (format (sysdate ,";;q" ) )
    SET attrib_batch = (attrib_batch + 25000 )
   ENDIF
  ENDWHILE
  SELECT INTO "nl:"
   FROM (lh_d_person per ),
    (lh_d_personnel prsnl ),
    (dummyt d1 WITH seq = ep_summary->ep_cnt ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (ep_summary->eps[d1.seq ].patients ,5 ) )
    AND (ep_summary->ep_cnt > 0 ) )
    JOIN (d2
    WHERE (ep_summary->eps[d1.seq ].patient_cnt > 0 ) )
    JOIN (prsnl
    WHERE (prsnl.person_id = ep_summary->eps[d1.seq ].provider_id ) )
    JOIN (per
    WHERE (per.person_id = ep_summary->eps[d1.seq ].patients[d2.seq ].person_id ) )
   HEAD d1.seq
    ep_summary->eps[d1.seq ].name = prsnl.name_full
   HEAD d2.seq
    dummy = 0
   DETAIL
    ep_summary->eps[d1.seq ].patients[d2.seq ].name = per.name_full
   WITH nocounter
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  doattributionimport (reportmean ,pop_group ,attrb_type ,attributionhint )
  DECLARE attribution_option_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE code_parser = vc WITH protect ,noconstant ("1=1" )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE num2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE batch_size = i4 WITH constant (15 ) ,protect
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_check = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_i = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_counter = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_batch = i4 WITH noconstant (25000 ) ,protect
  DECLARE person_pos2 = i4 WITH noconstant (0 ) ,protect
  DECLARE persons_size = i4 WITH noconstant (0 ) ,protect
  DECLARE person_batch_size = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Import Attribution" )
  CALL lhprint (build (";Report Mean: " ,reportmean ) )
  CALL lhprint (build (";Population Group: " ,pop_group ) )
  CALL lhprint (build (";Attribution type: " ,attrb_type ) )
  CALL lhprint (build (";Attribution hint: " ,attributionhint ) )
  IF ((attrb_type = 1 ) )
   SET attribution_option_parser = "laer.attribution_option = '1'"
   SET code_parser =
   "expand(num, 1, br_filters->epr_cnt, laer.encntr_prsnl_r_cd, br_filters->eprs[num].code_value) "
  ELSEIF ((attrb_type = 2 ) )
   SET code_parser =
   "expand(num, 1, size(ep_nomen->qual,5), laer.charge_reltn_cd, ep_nomen->qual[num].source_vocab_id) "
   IF ((ep_charge_bim_option_ind = 0 ) )
    SET attribution_option_parser = "laer.attribution_option = '2B'"
   ELSE
    SET attribution_option_parser = "laer.attribution_option = '2C'"
   ENDIF
  ENDIF
  CALL beg_time (0 )
  SET persons_size = size (lh_ep_reply->persons ,5 )
  SET person_batch_size = 5000
  SET person_iter = 1
  SET iter2 = 0
  IF ((persons_size < person_batch_size ) )
   SET person_batch_size = persons_size
  ENDIF
  WHILE ((person_iter <= persons_size ) )
   IF (((person_iter + person_batch_size ) > persons_size ) )
    SET person_batch_size = (persons_size - person_iter )
   ELSE
    SET person_batch_size = 5000
   ENDIF
   SELECT
    IF ((attributionhint != "" ) )
     WITH nocounter ,expand = 1 ,orahintcbo (value (attributionhint ) )
    ELSE
    ENDIF
    INTO "nl:"
    FROM (lh_import_qrda ipop ),
     (br_eligible_provider ep ),
     (br_gpro_reltn gr ),
     (br_gpro g )
    PLAN (ipop
     WHERE expand (iter1 ,person_iter ,(person_iter + person_batch_size ) ,ipop.person_id ,
      lh_ep_reply->persons[iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
     AND (ipop.effective_low_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) )
     JOIN (ep
     WHERE expand (num ,1 ,params->ep_cnt ,(ep.br_eligible_provider_id + 0 ) ,params->eps[num ].
      br_eligible_provider_id )
     AND (ep.national_provider_nbr_txt =
     (SELECT
      sup.supp_data_txt
      FROM (lh_import_qrda_supp sup )
      WHERE (sup.parent_entity_id = ipop.lh_import_qrda_id )
      AND (sup.supp_data_type = "NPI" ) ) )
     AND (ep.active_ind = 1 ) )
     JOIN (gr
     WHERE (gr.active_ind = 1 )
     AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (gr.parent_entity_id = ep.br_eligible_provider_id ) )
     JOIN (g
     WHERE (g.active_ind = 1 )
     AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (g.br_gpro_id = gr.br_gpro_id )
     AND (g.tax_id_nbr_txt =
     (SELECT
      sup.supp_data_txt
      FROM (lh_import_qrda_supp sup )
      WHERE (sup.parent_entity_id = ipop.lh_import_qrda_id )
      AND (sup.supp_data_type = "TIN" ) ) ) )
    ORDER BY ep.provider_id ,
     g.br_gpro_id ,
     ipop.person_id ,
     ipop.encntr_id
    HEAD REPORT
     epcnt = 0 ,
     ep_pos = 0
    HEAD ep.provider_id
     dummy = 0
    HEAD g.br_gpro_id
     ep_pos = locateval (ep_i ,1 ,size (ep_summary->eps ,5 ) ,ep.provider_id ,ep_summary->eps[ep_i ].
      provider_id ,reportmean ,ep_summary->eps[ep_i ].reportmean ,g.tax_id_nbr_txt ,ep_summary->eps[
      ep_i ].tax_id_nbr_txt ) ,
     IF ((ep_pos > 0 ) ) epcnt = ep_pos
     ELSE epcnt = (ep_summary->ep_cnt + 1 ) ,ep_summary->ep_cnt = epcnt ,stat = alterlist (ep_summary
       ->eps ,epcnt )
     ENDIF
     ,ep_summary->eps[epcnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_summary->eps[
     epcnt ].provider_id = ep.provider_id ,ep_summary->eps[epcnt ].tax_id_nbr_txt = g.tax_id_nbr_txt
     ,ep_summary->eps[epcnt ].npi_nbr_txt = ep.national_provider_nbr_txt ,ep_summary->eps[epcnt ].
     reportmean = reportmean ,ptcnt = 0
    HEAD ipop.person_id
     person_pos = locateval (person_i ,1 ,size (ep_summary->eps[epcnt ].patients ,5 ) ,ipop
      .person_id ,ep_summary->eps[epcnt ].patients[person_i ].person_id ) ,person_pos2 = locateval (
      person_i ,1 ,size (lh_ep_reply->persons ,5 ) ,ipop.person_id ,lh_ep_reply->persons[person_i ].
      person_id ) ,
     IF ((person_pos2 > 0 )
     AND (lh_ep_reply->persons[person_pos2 ].updt_src_ind IN (2 ,
     3 ) ) )
      IF ((person_pos > 0 ) ) ptcnt = person_pos
      ELSE ptcnt = (ep_summary->eps[epcnt ].patient_cnt + 1 ) ,ep_summary->eps[epcnt ].patient_cnt =
       ptcnt ,stat = alterlist (ep_summary->eps[epcnt ].patients ,ptcnt )
      ENDIF
      ,ep_summary->eps[epcnt ].patients[ptcnt ].person_id = ipop.person_id ,ep_summary->eps[epcnt ].
      patients[ptcnt ].mrn = lh_ep_reply->persons[person_pos2 ].mrn ,ep_summary->eps[epcnt ].
      patients[ptcnt ].birth_date = format (lh_ep_reply->persons[person_pos2 ].birth_date ,
       "mm/dd/yyyy;;q" ) ,ecnt = 0 ,enc_pos = 0 ,encntr_check = 0
     ENDIF
    HEAD ipop.encntr_id
     enc_pos = locateval (enc_iter ,1 ,lh_ep_reply->persons[person_pos2 ].encntr_cnt ,ipop.encntr_id
      ,lh_ep_reply->persons[person_pos2 ].encntrs[enc_iter ].encntr_id ) ,
     IF ((enc_pos > 0 )
     AND (lh_ep_reply->persons[person_pos2 ].encntrs[enc_pos ].exclude_ind = 0 ) ) lh_ep_reply->
      persons[person_pos2 ].encntrs[enc_pos ].ep_ind = 1 ,ecnt = (ep_summary->eps[epcnt ].patients[
      ptcnt ].encntr_cnt + 1 ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntr_cnt = ecnt ,stat =
      alterlist (ep_summary->eps[epcnt ].patients[ptcnt ].encntrs ,ecnt ) ,ep_summary->eps[epcnt ].
      patients[ptcnt ].encntrs[ecnt ].encntr_id = ipop.encntr_id ,ep_summary->eps[epcnt ].patients[
      ptcnt ].encntrs[ecnt ].br_eligible_provider_id = ep.br_eligible_provider_id ,ep_summary->eps[
      epcnt ].patients[ptcnt ].encntrs[ecnt ].visit_date = format (ipop.effective_low_dt_tm ,
       "mm/dd/yyyy;;q" ) ,ep_summary->eps[epcnt ].patients[ptcnt ].encntrs[ecnt ].fin = lh_ep_reply->
      persons[person_pos2 ].encntrs[enc_pos ].fin ,encntr_check = 1
     ENDIF
    FOOT  ipop.person_id
     IF ((encntr_check = 1 ) ) lh_ep_reply->persons[person_pos2 ].ep_ind = 1
     ENDIF
    WITH nocounter ,expand = 1
   ;end select
   SET person_iter = ((person_iter + person_batch_size ) + 1 )
   IF ((attrib_counter = attrib_batch ) )
    CALL lhprint (attrib_counter )
    CALL lhprint (format (sysdate ,";;q" ) )
    SET attrib_batch = (attrib_batch + 25000 )
   ENDIF
  ENDWHILE
  SELECT INTO "nl:"
   FROM (lh_d_person per ),
    (lh_d_personnel prsnl ),
    (dummyt d1 WITH seq = ep_summary->ep_cnt ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (ep_summary->eps[d1.seq ].patients ,5 ) )
    AND (ep_summary->ep_cnt > 0 ) )
    JOIN (d2
    WHERE (ep_summary->eps[d1.seq ].patient_cnt > 0 ) )
    JOIN (prsnl
    WHERE (prsnl.person_id = ep_summary->eps[d1.seq ].provider_id ) )
    JOIN (per
    WHERE (per.person_id = ep_summary->eps[d1.seq ].patients[d2.seq ].person_id ) )
   HEAD d1.seq
    ep_summary->eps[d1.seq ].name = prsnl.name_full
   HEAD d2.seq
    dummy = 0
   DETAIL
    ep_summary->eps[d1.seq ].patients[d2.seq ].name = per.name_full
   WITH nocounter
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  retrievedemographics (pop_group )
  DECLARE batch_size = i4 WITH constant (5000 ) ,protect
  DECLARE batch_counter = i4 WITH noconstant (0 ) ,protect
  DECLARE total_batches = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter_st = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter_end = i4 WITH noconstant (0 ) ,protect
  DECLARE size_ttl = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE j = i4 WITH noconstant (0 ) ,protect
  DECLARE logical_domain_parser = vc WITH protect ,noconstant (
   "pop.logical_domain_id = LOGICAL_DOMAIN_ID" )
  SET size_ttl = size (lh_ep_reply->persons ,5 )
  IF ((size_ttl <= batch_size ) )
   SET total_batches = 1
  ELSEIF ((mod (size_ttl ,batch_size ) = 0 ) )
   SET total_batches = (size_ttl / batch_size )
  ELSE
   SET total_batches = ((size_ttl / batch_size ) + 1 )
  ENDIF
  CALL lhprint ("Demographic text retrieval" )
  CALL beg_time (0 )
  IF ((pwx_ind = 1 ) )
   SET logical_domain_parser = "1=1"
  ENDIF
  WHILE ((size_ttl > 0 ) )
   IF ((size_ttl > batch_size ) )
    SET person_iter_st = (person_iter_end + 1 )
    SET person_iter_end = (person_iter_end + batch_size )
    SET size_ttl = (size_ttl - batch_size )
    SET batch_counter = (batch_counter + 1 )
   ELSE
    SET person_iter_st = (person_iter_end + 1 )
    SET person_iter_end = (person_iter_end + size_ttl )
    SET size_ttl = 0
    SET batch_counter = (batch_counter + 1 )
   ENDIF
   CALL lhprint (concat ("Batch Progress: " ,trim (cnvtstring (batch_counter ) ) ,"/" ,trim (
      cnvtstring (total_batches ) ) ) )
   SELECT INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 pop ),
     (lh_d_query qry ),
     (br_datam_val_set_item_meas bdvsim ),
     (br_datam_val_set_item vitem ),
     (br_datam_val_set bdvs ),
     (br_datamart_category bdc )
    PLAN (pop
     WHERE expand (person_iter ,person_iter_st ,person_iter_end ,pop.person_id ,lh_ep_reply->persons[
      person_iter ].person_id )
     AND (pop.active_ind = 1 )
     AND parser (logical_domain_parser )
     AND (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) )
     JOIN (qry
     WHERE (pop.d_query_id = qry.d_query_id )
     AND (qry.population_group = pop_group )
     AND (qry.active_ind = 1 ) )
     JOIN (vitem
     WHERE (vitem.source_vocab_item_ident IN (pop.gender_vset_cd ,
     pop.ethnicity_vset_cd ,
     pop.race_vset_cd ,
     pop.payer_vset_cd ) ) )
     JOIN (bdvsim
     WHERE (bdvsim.br_datam_val_set_item_id = vitem.br_datam_val_set_item_id ) )
     JOIN (bdvs
     WHERE (vitem.br_datam_val_set_id = bdvs.br_datam_val_set_id )
     AND (bdvs.value_set_name IN ("ONC_ADMINISTRATIVE_SEX" ,
     "PAYER" ,
     "RACE" ,
     "ETHNICITY" ) ) )
     JOIN (bdc
     WHERE (bdc.br_datamart_category_id = bdvs.br_datamart_category_id )
     AND (bdc.category_mean = category_mean ) )
    ORDER BY pop.reg_dt_tm
    HEAD pop.person_id
     payer_ind = 0 ,person_pos = locateval (person_iter ,person_iter_st ,person_iter_end ,pop
      .person_id ,lh_ep_reply->persons[person_iter ].person_id )
    DETAIL
     IF ((person_pos > 0 ) )
      CASE (vitem.source_vocab_item_ident )
       OF pop.gender_vset_cd :
        lh_ep_reply->persons[person_pos ].gender = trim (bdvsim.vocab_item_desc )
       OF pop.ethnicity_vset_cd :
        lh_ep_reply->persons[person_pos ].ethnicity = trim (bdvsim.vocab_item_desc )
       OF pop.race_vset_cd :
        lh_ep_reply->persons[person_pos ].race = trim (bdvsim.vocab_item_desc )
       OF pop.payer_vset_cd :
        lh_ep_reply->persons[person_pos ].payer = trim (bdvsim.vocab_item_desc ) ,
        lh_ep_reply->persons[person_pos ].payer_reg_dt_tm = pop.reg_dt_tm ,
        IF ((lh_ep_reply->persons[person_pos ].payer_group != "A" ) ) lh_ep_reply->persons[
         person_pos ].payer_group = pop.cms_payer_group ,
         IF ((pop.cms_payer_group = "A" ) ) payer_ind = 1
         ENDIF
        ENDIF
      ENDCASE
      ,lh_ep_reply->persons[person_pos ].hic = pop.hic_nbr
     ENDIF
    FOOT  pop.person_id
     per_pos = 0 ,per_pos = locateval (i ,1 ,size (lh_ep_reply->persons ,5 ) ,pop.person_id ,
      lh_ep_reply->persons[i ].person_id ) ,
     WHILE ((payer_ind = 1 )
     AND (per_pos > 0 ) )
      lh_ep_reply->persons[per_pos ].payer_group = "A" ,per_pos = locateval (j ,(per_pos + 1 ) ,size
       (lh_ep_reply->persons ,5 ) ,pop.person_id ,lh_ep_reply->persons[j ].person_id )
     ENDWHILE
    WITH nocounter ,expand = 1
   ;end select
  ENDWHILE
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getepdata (reportmean ,reltnopt ,pop_group )
  DECLARE perf_qry_name = vc WITH noconstant (reportmean )
  DECLARE elapsed_time = f8 WITH noconstant (0 )
  DECLARE attributionhint = vc WITH noconstant ("" ) ,protect
  DECLARE start_getepdata_time = dq8 WITH protect ,noconstant (cnvtdatetime (curdate ,curtime3 ) )
  DECLARE end_getepdata_time = dq8 WITH protect ,noconstant (cnvtdatetime (curdate ,curtime3 ) )
  CALL lhprint (build (";getEPData for:" ,reportmean ,"-with reltnOpt:" ,reltnopt ) )
  CALL lhprint (build ("getEPData start time :" ,format (start_getepdata_time ,";;q" ) ) )
  CALL lhprint ("" )
  CALL lhprint (build2 (";before getEPData: the size of LH_EP_REPLY is " ,build (size (lh_ep_reply->
      persons ,5 ) ) ) )
  CALL lhprint ("" )
  CALL get_birth_dt_tm (lh_ep_reply )
  SET errcode = error (errmsg ,1 )
  IF ((params->report_by = "CPC" ) )
   SET perf_qry_name = concat (perf_qry_name ,"_CPC_" ,build (size (lh_ep_reply->persons ,5 ) ) )
   SET attributionhint = getattributionhint ("NQF2019_CPC_ATTRIB" )
   CALL cpcattribution (reportmean ,pop_group ,reltnopt ,attributionhint )
   SET attributionhint = getattributionhint ("NQF2019_CPC_ATTRIB_IMPORT" )
   CALL cpcattributionimport (reportmean ,pop_group ,reltnopt ,attributionhint )
  ELSE
   SET perf_qry_name = concat (perf_qry_name ,"_" ,build (size (lh_ep_reply->persons ,5 ) ) )
   SET attributionhint = getattributionhint ("NQF2019_REPORT_ATTRIB" )
   CALL doattribution (reportmean ,pop_group ,reltnopt ,attributionhint )
   SET attributionhint = getattributionhint ("NQF2019_REPORT_ATTRIB_IMPORT" )
   CALL doattributionimport (reportmean ,pop_group ,reltnopt ,attributionhint )
  ENDIF
  SET stat = initrec (ep_nomen )
  CALL lhprint (";Removing patients who are not attributed to a provider..." )
  CALL beg_time (0 )
  CALL removedummyitem (lh_ep_reply ,"ep_ind" )
  CALL end_time (0 )
  CALL lhprint (build2 (";after getEPData: the size of LH_EP_REPLY is " ,build (size (lh_ep_reply->
      persons ,5 ) ) ) )
  CALL lhprint ("" )
  SET perf_qry_name = concat (perf_qry_name ,"_" ,build (size (lh_ep_reply->persons ,5 ) ) )
  CALL retrievedemographics (pop_group )
  CALL applypatientfilters (0 )
  SET end_getepdata_time = cnvtdatetime (curdate ,curtime3 )
  SET elapsed_time = datetimediff (end_getepdata_time ,start_getepdata_time ,5 )
  SET errcode = error (errmsg ,0 )
  IF ((errcode != 0 ) )
   CALL lhprint (concat ("Error while running query for attribution" ) )
   CALL echo ("Error while running query" )
   CALL lhprint (errmsg )
   SET err_count = (err_count + 1 )
   SET status_flag = 2
  ELSE
   SET status_flag = 1
  ENDIF
  CALL lhperformance (perf_qry_name ,status_flag ,elapsed_time ,size (lh_ep_reply->persons ,5 ) )
  CALL lhprint (build ("getEPData End Time      :" ,format (end_getepdata_time ,";;q" ) ) )
  CALL lhprint (build ("getEPData Elapsed Time  :" ,datetimediff (end_getepdata_time ,beg_time_var ,
     5 ) ) )
  CALL lhprint (" " )
 END ;Subroutine
 SUBROUTINE  getnonmappednomenclature (value_set_name ,meas_type ,cd_typ_var ,drug_ex )
  CALL lhprint (";############### getNonMappedNomenclature ###############" )
  CALL lhprint (build2 ("Non-Mapped Nomenclature filter: " ,value_set_name ) )
  IF ((br_filters->provider_attribution = 2 ) )
   CALL beg_time (0 )
   DECLARE measure_type_comp = vc WITH noconstant (" trim(meas.meas_ident,3) IN ('','" ) ,protect
   DECLARE cd_typ_var_comp = vc WITH noconstant (" vitem.source_vocab_mean IN(" ) ,protect
   SET measure_type_comp = concat (measure_type_comp ,meas_type ,"')" )
   SET cd_typ_var_comp = concat (cd_typ_var_comp ,cd_typ_var ,")" )
   DECLARE br_vset_id = i4 WITH noconstant (- (1 ) ) ,protect
   SELECT INTO "nl:"
    FROM (br_datam_val_set vset ),
     (br_datamart_category cat ),
     (br_datamart_filter fil )
    PLAN (cat
     WHERE (cnvtupper (cat.category_mean ) = cnvtupper (category_mean ) ) )
     JOIN (fil
     WHERE (fil.br_datamart_category_id = cat.br_datamart_category_id )
     AND (cnvtupper (fil.filter_mean ) = cnvtupper (value_set_name ) ) )
     JOIN (vset
     WHERE (vset.br_datam_val_set_id = fil.expected_action_value_set_id )
     AND (vset.br_datamart_category_id = cat.br_datamart_category_id )
     AND (cnvtupper (vset.template_name ) = "ENCOUNTERS" ) )
    DETAIL
     br_vset_id = vset.br_datam_val_set_id
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (br_datam_val_set_item vitem ),
     (br_datam_val_set_item_meas meas )
    PLAN (vitem
     WHERE (vitem.br_datam_val_set_id = br_vset_id ) )
     JOIN (meas
     WHERE (meas.br_datam_val_set_item_id = vitem.br_datam_val_set_item_id )
     AND parser (drug_ex )
     AND parser (cd_typ_var_comp ) )
    ORDER BY vitem.source_vocab_item_ident
    HEAD REPORT
     cnt = size (ep_nomen->qual ,5 )
    HEAD vitem.source_vocab_item_ident
     cnt = (cnt + 1 ) ,stat = alterlist (ep_nomen->qual ,cnt ) ,ep_nomen->qual[cnt ].source_vocab_id
     = vitem.source_vocab_item_ident
    WITH nocounter
   ;end select
   CALL lhprint (build2 ("Number of nomenclature items: " ,size (ep_nomen->qual ,5 ) ) )
   CALL end_time (0 )
  ELSE
   CALL lhprint (build2 ("WARNING: Provider attribution not billing (2), nomenclature not run" ) )
  ENDIF
 END ;Subroutine
 SUBROUTINE  get_birth_dt_tm (lh_ep_reply )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (lh_d_person p )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,p.person_id ,lh_ep_reply->persons[iter1 ]
    .person_id )
   ORDER BY p.person_id
   HEAD REPORT
    pos = 0
   HEAD p.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,p.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) )
     IF ((p.updt_source = "*IMPORT*" ) ) lh_ep_reply->persons[pos ].birth_date = cnvtdatetimeutc (p
       .birth_dt_tm ,1 )
     ELSE lh_ep_reply->persons[pos ].birth_date = nullcheck (cnvtdatetimeutc (p.abs_birth_dt_tm ,1 )
       ,cnvtdatetime (datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"dd-MMM-yyyy HH:mm:ss" ) ) ,
       nullind (p.abs_birth_dt_tm ) )
     ENDIF
    ENDIF
   WITH nocounter ,expand = 1
  ;end select
 END ;Subroutine
 SUBROUTINE  applypatientfilters (null )
  DECLARE iter = i4 WITH noconstant (0 ) ,protect
  DECLARE ep_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((filter_params->birthdate_low_dt_tm != 0.0 )
   AND (cnvtdatetime (lh_ep_reply->persons[i ].birth_date ) < cnvtdatetime (filter_params->
    birthdate_low_dt_tm ) ) )
    SET lh_ep_reply->persons[i ].exclude_ind = 1
   ENDIF
   IF ((filter_params->birthdate_high_dt_tm != 0.0 )
   AND (cnvtdatetime (lh_ep_reply->persons[i ].birth_date ) > cnvtdatetime (filter_params->
    birthdate_high_dt_tm ) ) )
    SET lh_ep_reply->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (br_datam_val_set_item_meas vmeas ),
    (dummyt d WITH seq = size (lh_ep_reply->persons ,5 ) )
   PLAN (d
    WHERE (size (lh_ep_reply->persons ,5 ) > 0 ) )
    JOIN (vmeas
    WHERE (vmeas.br_datam_val_set_item_id = filter_params->insurance_item_id )
    AND (vmeas.br_datam_val_set_item_id > 0 ) )
   DETAIL
    IF ((((lh_ep_reply->persons[d.seq ].payer = "" ) ) OR ((trim (lh_ep_reply->persons[d.seq ].payer
     ) != trim (vmeas.vocab_item_desc ) ) )) ) lh_ep_reply->persons[d.seq ].exclude_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (br_datam_val_set_item_meas vmeas ),
    (dummyt d WITH seq = size (lh_ep_reply->persons ,5 ) )
   PLAN (d
    WHERE (size (lh_ep_reply->persons ,5 ) > 0 ) )
    JOIN (vmeas
    WHERE (vmeas.br_datam_val_set_item_id = filter_params->gender_item_id )
    AND (vmeas.br_datam_val_set_item_id > 0 ) )
   DETAIL
    IF ((((lh_ep_reply->persons[d.seq ].gender = "" ) ) OR ((trim (lh_ep_reply->persons[d.seq ].
     gender ) != trim (vmeas.vocab_item_desc ) ) )) ) lh_ep_reply->persons[d.seq ].exclude_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (br_datam_val_set_item_meas vmeas ),
    (code_value cv ),
    (br_datamart_value val ),
    (br_datamart_category cat ),
    (dummyt d WITH seq = size (lh_ep_reply->persons ,5 ) )
   PLAN (d
    WHERE (size (lh_ep_reply->persons ,5 ) > 0 ) )
    JOIN (cv
    WHERE (cv.code_value = filter_params->race_cd )
    AND (cv.code_value > 0 ) )
    JOIN (val
    WHERE (cv.code_value = val.parent_entity_id )
    AND (val.parent_entity_name = "CODE_VALUE" )
    AND (val.parent_entity_name2 = "BR_DATAM_VAL_SET_ITEM" )
    AND (val.parent_entity_id2 != 0 )
    AND (val.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (vmeas
    WHERE (vmeas.br_datam_val_set_item_id = val.parent_entity_id2 ) )
    JOIN (cat
    WHERE (val.br_datamart_category_id = cat.br_datamart_category_id )
    AND (cat.category_mean = category_mean ) )
   DETAIL
    IF ((((lh_ep_reply->persons[d.seq ].race = "" ) ) OR ((trim (lh_ep_reply->persons[d.seq ].race )
    != trim (vmeas.vocab_item_desc ) ) )) ) lh_ep_reply->persons[d.seq ].exclude_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (br_datam_val_set_item_meas vmeas ),
    (code_value cv ),
    (br_datamart_value val ),
    (br_datamart_category cat ),
    (dummyt d WITH seq = size (lh_ep_reply->persons ,5 ) )
   PLAN (d
    WHERE (size (lh_ep_reply->persons ,5 ) > 0 ) )
    JOIN (cv
    WHERE (cv.code_value = filter_params->ethnicity_cd )
    AND (cv.code_value > 0 ) )
    JOIN (val
    WHERE (cv.code_value = val.parent_entity_id )
    AND (val.parent_entity_name = "CODE_VALUE" )
    AND (val.parent_entity_name2 = "BR_DATAM_VAL_SET_ITEM" )
    AND (val.parent_entity_id2 != 0 )
    AND (val.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (vmeas
    WHERE (vmeas.br_datam_val_set_item_id = val.parent_entity_id2 ) )
    JOIN (cat
    WHERE (val.br_datamart_category_id = cat.br_datamart_category_id )
    AND (cat.category_mean = category_mean ) )
   DETAIL
    IF ((((lh_ep_reply->persons[d.seq ].ethnicity = "" ) ) OR ((trim (lh_ep_reply->persons[d.seq ].
     ethnicity ) != trim (vmeas.vocab_item_desc ) ) )) ) lh_ep_reply->persons[d.seq ].exclude_ind =
     1
    ENDIF
   WITH nocounter
  ;end select
  FOR (iter = 1 TO lh_ep_reply->person_cnt )
   IF ((lh_ep_reply->persons[iter ].exclude_ind = 1 ) )
    FOR (ep_iter = 1 TO size (ep_summary->eps ,5 ) )
     SET person_pos = locateval (person_iter ,1 ,size (ep_summary->eps[ep_iter ].patients ,5 ) ,
      lh_ep_reply->persons[iter ].person_id ,ep_summary->eps[ep_iter ].patients[person_iter ].
      person_id )
     IF ((person_pos > 0 ) )
      SET ep_summary->eps[ep_iter ].patients[person_pos ].exclude_ind = 1
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
  CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((filter_params->problem_vset_id > 0 ) )
   FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
    SET lh_ep_reply->persons[i ].exclude_ind = 1
   ENDFOR
   FOR (i = 1 TO size (ep_summary->eps ,5 ) )
    FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
     SET ep_summary->eps[i ].patients[j ].exclude_ind = 1
    ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    FROM (br_datam_val_set vset ),
     (lh_amb_event_data_2019 l ),
     (dummyt d WITH seq = size (lh_ep_reply->persons ,5 ) )
    PLAN (d
     WHERE (size (lh_ep_reply->persons ,5 ) != 0 ) )
     JOIN (l
     WHERE (l.person_id = lh_ep_reply->persons[d.seq ].person_id )
     AND (l.active_ind = 1 )
     AND (l.primary_vset_cd_sys_oid = "2.16.840.1.113883.6.96" ) )
     JOIN (vset
     WHERE (vset.vocab_oid_txt = l.primary_vset_cd_sys_sdtc )
     AND (filter_params->problem_vset_id > 0 )
     AND (vset.br_datam_val_set_id = filter_params->problem_vset_id ) )
    DETAIL
     lh_ep_reply->persons[d.seq ].exclude_ind = 0 ,
     FOR (ep_iter = 1 TO size (ep_summary->eps ,5 ) )
      person_pos = locateval (person_iter ,1 ,size (ep_summary->eps[ep_iter ].patients ,5 ) ,
       lh_ep_reply->persons[d.seq ].person_id ,ep_summary->eps[ep_iter ].patients[person_iter ].
       person_id ) ,
      IF ((person_pos > 0 ) ) ep_summary->eps[ep_iter ].patients[person_pos ].exclude_ind = 0
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  applyproviderfilters (null )
  FREE RECORD nurse_unit
  RECORD nurse_unit (
    1 qual [* ]
      2 br_gpro_id = f8
      2 nurse_unit_cd = f8
  )
  SELECT INTO "nl:"
   FROM (nurse_unit n ),
    (br_gpro_reltn gr )
   WHERE (gr.parent_entity_name = "LOCATION" )
   AND (gr.active_ind = 1 )
   AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (((gr.parent_entity_id = n.location_cd ) ) OR ((((gr.parent_entity_id = n.loc_building_cd ) )
   OR ((gr.parent_entity_id = n.loc_facility_cd ) )) ))
   ORDER BY gr.br_gpro_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt + 1 ) ,
    stat = alterlist (nurse_unit->qual ,cnt ) ,
    nurse_unit->qual[cnt ].br_gpro_id = gr.br_gpro_id ,
    nurse_unit->qual[cnt ].nurse_unit_cd = n.location_cd
   WITH nocounter
  ;end select
  IF ((params->report_by = "INDV" ) )
   FOR (i = 1 TO size (ep_summary->eps ,5 ) )
    FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
     FOR (k = 1 TO size (ep_summary->eps[i ].patients[j ].encntrs ,5 ) )
      SET ep_summary->eps[i ].patients[j ].encntrs[k ].exclude_ind = 1
     ENDFOR
    ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 l ),
     (br_gpro g ),
     (br_gpro_reltn gr ),
     (dummyt d WITH seq = ep_summary->ep_cnt ),
     (dummyt d2 WITH seq = 1 ),
     (dummyt d3 WITH seq = 1 )
    PLAN (d
     WHERE (ep_summary->ep_cnt > 0 )
     AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
     JOIN (d2
     WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
     AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
     JOIN (d3
     WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
     JOIN (l
     WHERE (l.active_ind = 1 )
     AND (l.person_id = ep_summary->eps[d.seq ].patients[d2.seq ].person_id )
     AND (l.encntr_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].encntr_id ) )
     JOIN (g
     WHERE (g.active_ind = 1 )
     AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (g.tax_id_nbr_txt = ep_summary->eps[d.seq ].tax_id_nbr_txt ) )
     JOIN (gr
     WHERE (gr.active_ind = 1 )
     AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (gr.br_gpro_id = g.br_gpro_id )
     AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (gr.parent_entity_id = ep_summary->eps[d.seq ].br_eligible_provider_id ) )
    DETAIL
     i = locateval (num ,1 ,size (filter_params->tins ,5 ) ,g.br_gpro_id ,filter_params->tins[num ].
      br_gpro_id ) ,
     j = locateval (num ,1 ,size (nurse_unit->qual ,5 ) ,g.br_gpro_id ,nurse_unit->qual[num ].
      br_gpro_id ) ,
     k = locateval (num ,1 ,size (nurse_unit->qual ,5 ) ,g.br_gpro_id ,nurse_unit->qual[num ].
      br_gpro_id ,l.loc_nurse_unit_cd ,nurse_unit->qual[num ].nurse_unit_cd ) ,
     IF ((((size (filter_params->tins ,5 ) = 0 ) ) OR ((i > 0 ) )) )
      IF ((((j = 0 ) ) OR ((((k > 0 ) ) OR ((l.updt_source = "*IMPORT*" ) )) )) ) ep_summary->eps[d
       .seq ].patients[d2.seq ].encntrs[d3.seq ].exclude_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   IF ((size (filter_params->sites ,5 ) > 0 ) )
    FOR (i = 1 TO size (ep_summary->eps ,5 ) )
     FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
      FOR (k = 1 TO size (ep_summary->eps[i ].patients[j ].encntrs ,5 ) )
       SET ep_summary->eps[i ].patients[j ].encntrs[k ].exclude_ind = 1
      ENDFOR
     ENDFOR
    ENDFOR
    SELECT INTO "nl:"
     FROM (lh_amb_qual_encntr_2019 l ),
      (br_cpc_elig_prov_reltn cr ),
      (br_cpc_loc_reltn cr1 ),
      (br_cpc cpc ),
      (dummyt d WITH seq = ep_summary->ep_cnt ),
      (dummyt d2 WITH seq = 1 ),
      (dummyt d3 WITH seq = 1 )
     PLAN (d
      WHERE (ep_summary->ep_cnt > 0 )
      AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
      JOIN (d2
      WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
      AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
      JOIN (d3
      WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
      JOIN (l
      WHERE (l.active_ind = 1 )
      AND (l.person_id = ep_summary->eps[d.seq ].patients[d2.seq ].person_id )
      AND (l.encntr_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].encntr_id ) )
      JOIN (cpc
      WHERE (cpc.tax_id_nbr_txt = ep_summary->eps[d.seq ].tax_id_nbr_txt )
      AND (cpc.active_ind = 1 )
      AND (cpc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      JOIN (cr
      WHERE (cr.br_cpc_id = cpc.br_cpc_id )
      AND (cr.active_ind = 1 )
      AND (cr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (cr.br_eligible_provider_id = ep_summary->eps[d.seq ].br_eligible_provider_id ) )
      JOIN (cr1
      WHERE (cr1.active_ind = 1 )
      AND (cr1.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (cr1.br_cpc_id = cr.br_cpc_id )
      AND (cr1.location_cd = l.loc_nurse_unit_cd ) )
     DETAIL
      i = locateval (num ,1 ,size (filter_params->sites ,5 ) ,cpc.br_cpc_id ,filter_params->sites[
       num ].br_cpc_id ) ,
      IF ((i > 0 ) ) ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].exclude_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   ENDIF
  ELSEIF ((params->report_by = "GPRO" ) )
   FOR (i = 1 TO size (ep_summary->eps ,5 ) )
    FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
     FOR (k = 1 TO size (ep_summary->eps[i ].patients[j ].encntrs ,5 ) )
      SET ep_summary->eps[i ].patients[j ].encntrs[k ].exclude_ind = 1
     ENDFOR
    ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 l ),
     (br_gpro g ),
     (br_gpro_reltn gr ),
     (dummyt d WITH seq = ep_summary->ep_cnt ),
     (dummyt d2 WITH seq = 1 ),
     (dummyt d3 WITH seq = 1 )
    PLAN (d
     WHERE (ep_summary->ep_cnt > 0 )
     AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
     JOIN (d2
     WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
     AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
     JOIN (d3
     WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
     JOIN (l
     WHERE (l.active_ind = 1 )
     AND (l.person_id = ep_summary->eps[d.seq ].patients[d2.seq ].person_id )
     AND (l.encntr_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].encntr_id ) )
     JOIN (g
     WHERE (g.active_ind = 1 )
     AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (g.tax_id_nbr_txt = ep_summary->eps[d.seq ].tax_id_nbr_txt ) )
     JOIN (gr
     WHERE (gr.br_gpro_id = g.br_gpro_id )
     AND (gr.active_ind = 1 )
     AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
     AND (gr.parent_entity_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].
     br_eligible_provider_id ) )
    DETAIL
     i = locateval (num ,1 ,size (params->grps ,5 ) ,gr.br_gpro_id ,params->grps[num ].br_gpro_id ) ,
     j = locateval (num ,1 ,size (nurse_unit->qual ,5 ) ,g.br_gpro_id ,nurse_unit->qual[num ].
      br_gpro_id ) ,
     k = locateval (num ,1 ,size (nurse_unit->qual ,5 ) ,g.br_gpro_id ,nurse_unit->qual[num ].
      br_gpro_id ,l.loc_nurse_unit_cd ,nurse_unit->qual[num ].nurse_unit_cd ) ,
     IF ((i > 0 ) )
      IF ((((j = 0 ) ) OR ((((k > 0 ) ) OR ((l.updt_source = "*IMPORT*" ) )) )) ) ep_summary->eps[d
       .seq ].patients[d2.seq ].encntrs[d3.seq ].exclude_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   IF ((size (filter_params->sites ,5 ) > 0 ) )
    FOR (i = 1 TO size (ep_summary->eps ,5 ) )
     FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
      FOR (k = 1 TO size (ep_summary->eps[i ].patients[j ].encntrs ,5 ) )
       SET ep_summary->eps[i ].patients[j ].encntrs[k ].exclude_ind = 1
      ENDFOR
     ENDFOR
    ENDFOR
    SELECT INTO "nl:"
     FROM (lh_amb_qual_encntr_2019 l ),
      (br_cpc cpc ),
      (br_cpc_elig_prov_reltn cr ),
      (br_cpc_loc_reltn cr1 ),
      (dummyt d WITH seq = ep_summary->ep_cnt ),
      (dummyt d2 WITH seq = 1 ),
      (dummyt d3 WITH seq = 1 )
     PLAN (d
      WHERE (ep_summary->ep_cnt > 0 )
      AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
      JOIN (d2
      WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
      AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
      JOIN (d3
      WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
      JOIN (l
      WHERE (l.active_ind = 1 )
      AND (l.person_id = ep_summary->eps[d.seq ].patients[d2.seq ].person_id )
      AND (l.encntr_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].encntr_id ) )
      JOIN (cpc
      WHERE (cpc.tax_id_nbr_txt = ep_summary->eps[d.seq ].tax_id_nbr_txt )
      AND (cpc.active_ind = 1 )
      AND (cpc.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      JOIN (cr
      WHERE (cr.br_cpc_id = cpc.br_cpc_id )
      AND (cr.active_ind = 1 )
      AND (cr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (cr.br_eligible_provider_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].
      br_eligible_provider_id ) )
      JOIN (cr1
      WHERE (cr1.br_cpc_id = cr.br_cpc_id )
      AND (cr1.active_ind = 1 )
      AND (cr1.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (cr1.location_cd = l.loc_nurse_unit_cd ) )
     DETAIL
      i = locateval (num ,1 ,size (filter_params->sites ,5 ) ,cr.br_cpc_id ,filter_params->sites[num
       ].br_cpc_id ) ,
      IF ((i > 0 ) ) ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].exclude_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   ENDIF
   IF ((size (filter_params->eps ,5 ) > 0 ) )
    FOR (i = 1 TO size (ep_summary->eps ,5 ) )
     FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
      FOR (k = 1 TO size (ep_summary->eps[i ].patients[j ].encntrs ,5 ) )
       SET ep_summary->eps[i ].patients[j ].encntrs[k ].exclude_ind = 1
      ENDFOR
     ENDFOR
    ENDFOR
    SELECT INTO "nl:"
     FROM (br_gpro_reltn gr ),
      (dummyt d WITH seq = ep_summary->ep_cnt ),
      (dummyt d2 WITH seq = 1 ),
      (dummyt d3 WITH seq = 1 )
     PLAN (d
      WHERE (ep_summary->ep_cnt > 0 )
      AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
      JOIN (d2
      WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
      AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
      JOIN (d3
      WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
      JOIN (gr
      WHERE (gr.parent_entity_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].
      br_eligible_provider_id )
      AND (gr.active_ind = 1 )
      AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" ) )
     DETAIL
      i = locateval (num ,1 ,size (filter_params->eps ,5 ) ,gr.parent_entity_id ,filter_params->eps[
       num ].br_eligible_provider_id ) ,
      IF ((i > 0 ) ) ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].exclude_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   ENDIF
  ELSEIF ((params->report_by = "CPC" ) )
   IF ((size (filter_params->eps ,5 ) > 0 ) )
    FOR (i = 1 TO size (ep_summary->eps ,5 ) )
     FOR (j = 1 TO size (ep_summary->eps[i ].patients ,5 ) )
      FOR (k = 1 TO size (ep_summary->eps[i ].patients[j ].encntrs ,5 ) )
       SET ep_summary->eps[i ].patients[j ].encntrs[k ].exclude_ind = 1
      ENDFOR
     ENDFOR
    ENDFOR
    SELECT INTO "nl:"
     FROM (br_cpc_elig_prov_reltn cr ),
      (dummyt d WITH seq = ep_summary->ep_cnt ),
      (dummyt d2 WITH seq = 1 ),
      (dummyt d3 WITH seq = 1 )
     PLAN (d
      WHERE (ep_summary->ep_cnt > 0 )
      AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
      JOIN (d2
      WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
      AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
      JOIN (d3
      WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
      JOIN (cr
      WHERE (cr.br_eligible_provider_id = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].
      br_eligible_provider_id )
      AND (cr.active_ind = 1 )
      AND (cr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
     DETAIL
      i = locateval (num ,1 ,size (filter_params->eps ,5 ) ,cr.br_eligible_provider_id ,filter_params
       ->eps[num ].br_eligible_provider_id ) ,
      IF ((i > 0 ) ) ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].exclude_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattributionhint (attributionversion )
  DECLARE storedhint = vc WITH protect ,noconstant ("" )
  SELECT INTO "nl:"
   FROM (lh_d_query d )
   WHERE (trim (cnvtupper (d.query_name ) ,3 ) = trim (cnvtupper (attributionversion ) ,3 ) )
   AND (d.active_ind = 1 )
   ORDER BY d.hint_name
   HEAD REPORT
    storedhint = trim (d.hint_name ,3 )
   WITH nocounter
  ;end select
  RETURN (storedhint )
 END ;Subroutine
 DECLARE printreportnotrun ((output = vc ) ) = null
 DECLARE printpsreport ((output_filename = vc ) ) = null
 DECLARE printpdfreport ((output_filename = vc ) ) = null
 DECLARE printcsvreport ((option = i4 ) ,(output = vc ) ,(sep = vc ) ) = null
 DECLARE get_cms_submeasure_str ((rm = vc ) ) = vc
 DECLARE gettarget_file (null ) = null
 DECLARE wrap_string ((separator = vc ) ,(string = vc ) ) = vc
 DECLARE set_extension ((file_name = vc ) ,(extension = vc ) ) = vc
 DECLARE colstr = vc
 SUBROUTINE  printreportnotrun (output )
  IF ((value (output ) != "*.csv" ) )
   SELECT INTO value (output )
    HEAD REPORT
     y_pos = 18 ,
     yval = 0 ,
     printpsheader = 0 ,
     col 0 ,
     "{PS/792 0 translate 90 rotate/}" ,
     row + 1 ,
     warning1 = rpt->message ,
     warning1_pos = (391 - (size (warning1 ) * 2 ) ) ,
     row + 1 ,
     "{F/1}{CPI/16}" ,
     row + 1 ,
     CALL print (calcpos (warning1_pos ,(y_pos + 300 ) ) ) ,
     warning1 ,
     row + 1 ,
     y_pos = (y_pos + 132 )
    WITH maxrec = 5 ,maxcol = 300 ,maxrow = 500 ,landscape ,dio = 08 ,noheading ,format = variable
   ;end select
  ELSEIF ((value (output ) = "*.csv" ) )
   SELECT INTO value (output )
    FROM (dummyt d WITH seq = 1 )
    HEAD REPORT
     CALL print (rpt->message )
    WITH nocounter ,separator = ","
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE  printpsreport (output_filename )
  DECLARE page_len = i4 WITH constant (535 )
  DECLARE total_page_cnt = vc WITH protect ,noconstant ("" )
  DECLARE temp_file_name = vc WITH protect ,noconstant (build ("tmp_lh_rpt_" ,format (
     report_start_dt_tm ,"YYYYMMDDHHMMSS;;q" ) ,".ps" ) )
  DECLARE command = vc WITH protect ,noconstant ("" )
  DECLARE status = i2 WITH protect ,noconstant (0 )
  DECLARE modified_filename = vc WITH protect ,noconstant ("" )
  IF ((substring ((textlen (output_filename ) - 3 ) ,textlen (output_filename ) ,output_filename )
  != ".dat" ) )
   SET modified_filename = set_extension (value (output_filename ) ,"ps" )
  ELSE
   SET modified_filename = output_filename
  ENDIF
  SELECT INTO value (temp_file_name )
   date_range = substring (1 ,30 ,rpt->date_range ) ,
   created_by = substring (1 ,30 ,rpt->created_by ) ,
   created_on = substring (1 ,30 ,rpt->created_on ) ,
   report_title = substring (1 ,100 ,rpt->reports[d1.seq ].name ) ,
   tin = substring (1 ,30 ,rpt->reports[d1.seq ].tin ) ,
   npi = substring (1 ,30 ,rpt->reports[d1.seq ].npi ) ,
   report_seq = rpt->reports[d1.seq ].seq ,
   table_name = substring (1 ,100 ,rpt->reports[d1.seq ].tables[d2.seq ].name ) ,
   table_seq = rpt->reports[d1.seq ].tables[d2.seq ].table_seq ,
   cell_value = substring (1 ,30 ,rpt->reports[d1.seq ].tables[d2.seq ].rows[d3.seq ].cells[d4.seq ].
    value )
   FROM (dummyt d1 WITH seq = value (size (rpt->reports ,5 ) ) ),
    (dummyt d2 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 ),
    (dummyt d5 ),
    (dummyt d4 WITH seq = 1 ),
    (dummyt d6 )
   PLAN (d1
    WHERE maxrec (d2 ,size (rpt->reports[d1.seq ].tables ,5 ) ) )
    JOIN (d2
    WHERE maxrec (d3 ,size (rpt->reports[d1.seq ].tables[d2.seq ].rows ,5 ) ) )
    JOIN (d5 )
    JOIN (d3
    WHERE maxrec (d4 ,size (rpt->reports[d1.seq ].tables[d2.seq ].rows[d3.seq ].cells ,5 ) ) )
    JOIN (d4 )
    JOIN (d6 )
   ORDER BY report_seq ,
    table_seq
   HEAD REPORT
    SUBROUTINE  wrapdata (datastr ,col_len ,x_loc ,y_loc ,y_start ,uline )
     linesize = (size (trim (datastr ,3 ) ,1 ) + 1 ) ,begloc = 1 ,endloc = 1 ,high_val = (y_start -
     6 ) ,space_indx = 0 ,
     WHILE ((endloc < linesize ) )
      high_val = (high_val + 6 ) ,begloc = endloc ,endloc = minval ((begloc + col_len ) ,linesize ) ,
      space_indx = findstring (" " ,substring (begloc ,((endloc - begloc ) + 1 ) ,trim (datastr ,3 )
        ) ,1 ,1 ) ,
      IF ((endloc < linesize )
      AND (space_indx > 0 ) ) endloc = (begloc + space_indx ) ,colstr = substring (begloc ,((endloc
        - begloc ) - 1 ) ,trim (datastr ,3 ) )
      ELSE colstr = substring (begloc ,(endloc - begloc ) ,trim (datastr ,3 ) )
      ENDIF
      ,
      CALL print (calcpos (x_loc ,(y_loc + high_val ) ) ) ,
      IF ((uline = 1 ) ) "{U}" ,colstr ,row + 1 ,"{ENDU}"
      ELSE colstr
      ENDIF
      ,
      WHILE ((endloc < linesize )
      AND (substring (endloc ,1 ,trim (datastr ,3 ) ) = " " ) )
       endloc = (endloc + 1 )
      ENDWHILE
     ENDWHILE
     ,
     IF ((high_val > maxyinc ) ) maxyinc = high_val
     ENDIF
    END ;Subroutine report
    ,colwidth = 0 ,
    y_pos = 18 ,
    printpsheader = 0 ,
    col 0 ,
    "{PS/792 0 translate 90 rotate/}"
   HEAD PAGE
    IF ((curpage > 1 ) ) y_pos = 18
    ENDIF
    ,
    IF (printpsheader ) col 0 ,"{PS/792 0 translate 90 rotate/}"
    ENDIF
    ,printpsheader = 1
   HEAD report_seq
    report_title_pos = (391 - (size (trim (report_title ) ,1 ) * 4 ) ) ,row + 1 ,"{F/1}{CPI/10}" ,
    CALL print (calcpos (report_title_pos ,(y_pos + 11 ) ) ) ,report_title ,row + 1 ,"{F/0}{CPI/14}"
    ,
    CALL print (calcpos (575 ,(y_pos + 29 ) ) ) ,"Created By: " ,created_by ,
    CALL print (calcpos (36 ,(y_pos + 29 ) ) ) ,"Date Range: " ,date_range ,
    CALL print (calcpos (575 ,(y_pos + 47 ) ) ) ,"Created On: " ,created_on ,
    IF ((rpt->reports[d1.seq ].npi != "" ) )
     IF ((params->report_by = "CPC" ) )
      CALL print (calcpos (36 ,(y_pos + 47 ) ) ) ,"Practice ID: " ,npi
     ELSE
      CALL print (calcpos (36 ,(y_pos + 47 ) ) ) ,"NPI: " ,npi
     ENDIF
    ENDIF
    ,
    IF ((trim (tin ,3 ) != "" ) )
     IF ((params->report_by = "CPC" ) )
      CALL print (calcpos (200 ,(y_pos + 47 ) ) ) ,"CPC TIN: " ,tin
     ELSE
      CALL print (calcpos (150 ,(y_pos + 47 ) ) ) ,"TIN: " ,tin
     ENDIF
    ENDIF
    ,y_pos = (y_pos + 65 )
   HEAD table_seq
    IF (((y_pos + 50 ) >= page_len ) ) y_pos = 0 ,
     BREAK
    ENDIF
    ,row + 1 ,"{F/1}{CPI/11}" ,row + 1 ,
    CALL print (calcpos (36 ,(y_pos + 20 ) ) ) ,table_name ,row + 1 ,row + 1 ,y_val = ((792 - y_pos
    ) - 40 ) ,"{PS/newpath 1.5 setlinewidth   36 " ,y_val ," moveto  755 " ,y_val ,
    " lineto stroke 36 " ,y_val ," moveto/}" ,row + 1 ,y_pos = (y_pos + 40 ) ,x_pos = 36 ,
    FOR (r = 1 TO rpt->reports[d1.seq ].tables[d2.seq ].row_cnt )
     FOR (c = 1 TO rpt->reports[d1.seq ].tables[d2.seq ].rows[r ].cell_cnt )
      row + 1 ,"{F/0}{CPI/14}" ,maxyinc = 11 ,colwidth = rpt->reports[d1.seq ].tables[d2.seq ].rows[
      1 ].cells[c ].width ,uline = 0 ,
      IF ((r = 1 ) ) uline = 1
      ELSE uline = 0
      ENDIF
      ,
      CALL wrapdata (rpt->reports[d1.seq ].tables[d2.seq ].rows[r ].cells[c ].value ,colwidth ,x_pos
      ,y_pos ,11 ,uline ) ,x_pos = ((x_pos + colwidth ) + 50 )
     ENDFOR
     ,x_pos = 36 ,y_pos = (y_pos + 20 ) ,
     IF (((y_pos + 50 ) >= page_len ) ) y_pos = 18 ,
      BREAK,
      FOR (c = 1 TO rpt->reports[d1.seq ].tables[d2.seq ].rows[1 ].cell_cnt )
       row + 1 ,"{F/0}{CPI/14}" ,colwidth = rpt->reports[d1.seq ].tables[d2.seq ].rows[1 ].cells[c ].
       width ,
       CALL wrapdata (rpt->reports[d1.seq ].tables[d2.seq ].rows[1 ].cells[c ].value ,colwidth ,
       x_pos ,y_pos ,11 ,1 ) ,x_pos = ((x_pos + colwidth ) + 50 )
      ENDFOR
      ,x_pos = 36 ,y_pos = (y_pos + 20 )
     ENDIF
    ENDFOR
   FOOT  table_name
    y_pos = (y_pos + 20 )
   FOOT  report_seq
    IF ((d1.seq < rpt->report_cnt ) ) y_pos = 0 ,
     BREAK
    ENDIF
   FOOT PAGE
    total_page_cnt = trim (cnvtstring (curpage ) ) ,
    row + 1 ,
    "{F/0}{CPI/14}" ,
    CALL print (calcpos (36 ,560 ) ) ,
    "Clinician Electronic Clinical Quality Measures 2019" ,
    page_of_page_string = concat ("Page: " ,trim (cnvtstring (curpage ) ) ," of " ,
     "&&&&FinalPage&&&&" ) ,
    CALL print (calcpos (660 ,560 ) ) ,
    page_of_page_string
   FOOT REPORT
    row + 1 ,
    "{F/1}{CPI/10}" ,
    row + 1 ,
    CALL print (calcpos (307 ,544 ) ) ,
    "*** END OF REPORT ***"
   WITH maxcol = 2000 ,maxrow = 500 ,landscape ,append ,dio = 08 ,noheading ,format = variable ,
    outerjoin = d5 ,outerjoin = d6
  ;end select
  FREE DEFINE rtl2
  DEFINE rtl2 temp_file_name
  SELECT INTO value (modified_filename )
   newline = substring (1 ,1999 ,replace (r.line ,"&&&&FinalPage&&&&" ,total_page_cnt ) )
   FROM (rtl2t r )
   DETAIL
    col 0 ,
    newline ,
    row + 1
   WITH maxcol = 2000 ,maxrow = 500 ,landscape ,noheading ,format = variable
  ;end select
  SET command = build ("rm $CCLUSERDIR/" ,temp_file_name )
  CALL dcl (command ,size (trim (command ) ) ,status )
  FREE DEFINE rtl2
 END ;Subroutine
 SUBROUTINE  printpdfreport (output_filename )
  DECLARE page_len = i4 WITH constant (535 )
  DECLARE total_page_cnt = vc WITH protect ,noconstant ("" )
  DECLARE temp_file_name = vc WITH protect ,noconstant (build ("tmp_lh_rpt_" ,format (
     report_start_dt_tm ,"YYYYMMDDHHMMSS;;q" ) ,".pdf" ) )
  DECLARE modified_filename = vc WITH protect ,noconstant ("" )
  IF ((substring ((textlen (output_filename ) - 3 ) ,textlen (output_filename ) ,output_filename )
  != ".dat" ) )
   SET modified_filename = set_extension (value (output_filename ) ,"pdf" )
  ELSE
   SET modified_filename = output_filename
  ENDIF
  SELECT INTO value (temp_file_name )
   date_range = substring (1 ,30 ,rpt->date_range ) ,
   created_by = substring (1 ,30 ,rpt->created_by ) ,
   created_on = substring (1 ,30 ,rpt->created_on ) ,
   report_title = substring (1 ,100 ,rpt->reports[d1.seq ].name ) ,
   tin = substring (1 ,30 ,rpt->reports[d1.seq ].tin ) ,
   npi = substring (1 ,30 ,rpt->reports[d1.seq ].npi ) ,
   report_seq = rpt->reports[d1.seq ].seq ,
   table_name = substring (1 ,100 ,rpt->reports[d1.seq ].tables[d2.seq ].name ) ,
   table_seq = rpt->reports[d1.seq ].tables[d2.seq ].table_seq ,
   cell_value = substring (1 ,30 ,rpt->reports[d1.seq ].tables[d2.seq ].rows[d3.seq ].cells[d4.seq ].
    value )
   FROM (dummyt d1 WITH seq = value (size (rpt->reports ,5 ) ) ),
    (dummyt d2 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 ),
    (dummyt d5 ),
    (dummyt d4 WITH seq = 1 ),
    (dummyt d6 )
   PLAN (d1
    WHERE maxrec (d2 ,size (rpt->reports[d1.seq ].tables ,5 ) ) )
    JOIN (d2
    WHERE maxrec (d3 ,size (rpt->reports[d1.seq ].tables[d2.seq ].rows ,5 ) ) )
    JOIN (d5 )
    JOIN (d3
    WHERE maxrec (d4 ,size (rpt->reports[d1.seq ].tables[d2.seq ].rows[d3.seq ].cells ,5 ) ) )
    JOIN (d4 )
    JOIN (d6 )
   ORDER BY report_seq ,
    table_seq
   HEAD REPORT
    SUBROUTINE  wrapdata (datastr ,col_len ,x_loc ,y_loc ,y_start ,uline )
     linesize = (size (trim (datastr ,3 ) ,1 ) + 1 ) ,begloc = 1 ,endloc = 1 ,high_val = (y_start -
     6 ) ,space_indx = 0 ,
     WHILE ((endloc < linesize ) )
      high_val = (high_val + 6 ) ,begloc = endloc ,endloc = minval ((begloc + col_len ) ,linesize ) ,
      space_indx = findstring (" " ,substring (begloc ,((endloc - begloc ) + 1 ) ,trim (datastr ,3 )
        ) ,1 ,1 ) ,
      IF ((endloc < linesize )
      AND (space_indx > 0 ) ) endloc = (begloc + space_indx ) ,colstr = substring (begloc ,((endloc
        - begloc ) - 1 ) ,trim (datastr ,3 ) )
      ELSE colstr = substring (begloc ,(endloc - begloc ) ,trim (datastr ,3 ) )
      ENDIF
      ,
      CALL print (calcpos (x_loc ,(y_loc + high_val ) ) ) ,
      IF ((uline = 1 ) ) "{U}" ,colstr ,row + 1 ,"{ENDU}"
      ELSE colstr
      ENDIF
      ,
      WHILE ((endloc < linesize )
      AND (substring (endloc ,1 ,trim (datastr ,3 ) ) = " " ) )
       endloc = (endloc + 1 )
      ENDWHILE
     ENDWHILE
     ,
     IF ((high_val > maxyinc ) ) maxyinc = high_val
     ENDIF
    END ;Subroutine report
    ,colwidth = 0 ,
    y_pos = 18 ,
    printpsheader = 0 ,
    col 0 ,
    "{PS/792 0 translate 90 rotate/}"
   HEAD PAGE
    IF ((curpage > 1 ) ) y_pos = 18
    ENDIF
    ,
    IF (printpsheader ) col 0 ,"{PS/792 0 translate 90 rotate/}"
    ENDIF
    ,printpsheader = 1
   HEAD report_seq
    report_title_pos = (391 - (size (trim (report_title ) ,1 ) * 4 ) ) ,row + 1 ,"{F/1}{CPI/10}" ,
    CALL print (calcpos (report_title_pos ,(y_pos + 11 ) ) ) ,report_title ,row + 1 ,"{F/0}{CPI/14}"
    ,
    CALL print (calcpos (575 ,(y_pos + 29 ) ) ) ,"Created By: " ,created_by ,
    CALL print (calcpos (36 ,(y_pos + 29 ) ) ) ,"Date Range: " ,date_range ,
    CALL print (calcpos (575 ,(y_pos + 47 ) ) ) ,"Created On: " ,created_on ,
    IF ((rpt->reports[d1.seq ].npi != "" ) )
     IF ((params->report_by = "CPC" ) )
      CALL print (calcpos (36 ,(y_pos + 47 ) ) ) ,"Practice ID: " ,npi
     ELSE
      CALL print (calcpos (36 ,(y_pos + 47 ) ) ) ,"NPI: " ,npi
     ENDIF
    ENDIF
    ,
    IF ((trim (tin ,3 ) != "" ) )
     IF ((params->report_by = "CPC" ) )
      CALL print (calcpos (200 ,(y_pos + 47 ) ) ) ,"CPC TIN: " ,tin
     ELSE
      CALL print (calcpos (150 ,(y_pos + 47 ) ) ) ,"TIN: " ,tin
     ENDIF
    ENDIF
    ,y_pos = (y_pos + 65 )
   HEAD table_seq
    IF (((y_pos + 50 ) >= page_len ) ) y_pos = 0 ,
     BREAK
    ENDIF
    ,row + 1 ,"{F/1}{CPI/11}" ,row + 1 ,
    CALL print (calcpos (36 ,(y_pos + 20 ) ) ) ,table_name ,row + 1 ,
    "   _____________________________________________________________________________________________________________"
    ,row + 1 ,y_val = ((792 - y_pos ) - 40 ) ,"{PS/newpath 1.5 setlinewidth   36 " ,y_val ,
    " moveto  755 " ,y_val ," lineto stroke 36 " ,y_val ," moveto/}" ,row + 1 ,y_pos = (y_pos + 40 )
    ,x_pos = 36 ,
    FOR (r = 1 TO rpt->reports[d1.seq ].tables[d2.seq ].row_cnt )
     FOR (c = 1 TO rpt->reports[d1.seq ].tables[d2.seq ].rows[r ].cell_cnt )
      row + 1 ,"{F/0}{CPI/14}" ,maxyinc = 11 ,colwidth = rpt->reports[d1.seq ].tables[d2.seq ].rows[
      1 ].cells[c ].width ,uline = 0 ,
      IF ((r = 1 ) ) uline = 1
      ELSE uline = 0
      ENDIF
      ,
      CALL wrapdata (rpt->reports[d1.seq ].tables[d2.seq ].rows[r ].cells[c ].value ,colwidth ,x_pos
      ,y_pos ,11 ,uline ) ,x_pos = ((x_pos + colwidth ) + 50 )
     ENDFOR
     ,x_pos = 36 ,y_pos = (y_pos + 20 ) ,
     IF (((y_pos + 50 ) >= page_len ) ) y_pos = 18 ,
      BREAK,
      FOR (c = 1 TO rpt->reports[d1.seq ].tables[d2.seq ].rows[1 ].cell_cnt )
       row + 1 ,"{F/0}{CPI/14}" ,colwidth = rpt->reports[d1.seq ].tables[d2.seq ].rows[1 ].cells[c ].
       width ,
       CALL wrapdata (rpt->reports[d1.seq ].tables[d2.seq ].rows[1 ].cells[c ].value ,colwidth ,
       x_pos ,y_pos ,11 ,1 ) ,x_pos = ((x_pos + colwidth ) + 50 )
      ENDFOR
      ,x_pos = 36 ,y_pos = (y_pos + 20 )
     ENDIF
    ENDFOR
   FOOT  table_name
    y_pos = (y_pos + 20 )
   FOOT  report_seq
    IF ((d1.seq < rpt->report_cnt ) ) y_pos = 0 ,
     BREAK
    ENDIF
   FOOT PAGE
    total_page_cnt = trim (cnvtstring (curpage ) ) ,
    row + 1 ,
    "{F/0}{CPI/14}" ,
    CALL print (calcpos (36 ,560 ) ) ,
    "Clinician Electronic Clinical Quality Measures 2019" ,
    page_of_page_string = concat ("Page: " ,trim (cnvtstring (curpage ) ) ," of " ,
     "&&&&FinalPage&&&&" ) ,
    CALL print (calcpos (660 ,560 ) ) ,
    page_of_page_string
   FOOT REPORT
    row + 1 ,
    "{F/1}{CPI/10}" ,
    row + 1 ,
    CALL print (calcpos (307 ,544 ) ) ,
    "*** END OF REPORT ***"
   WITH maxcol = 2000 ,maxrow = 500 ,landscape ,append ,dio = 38 ,noheading ,format = variable ,
    outerjoin = d5 ,outerjoin = d6
  ;end select
  FREE DEFINE rtl3
  DEFINE rtl3 temp_file_name
  SELECT INTO value (modified_filename )
   newline = concat (substring (1 ,1998 ,replace (r.line ,"&&&&FinalPage&&&&" ,total_page_cnt ) ) ,
    char (13 ) )
   FROM (rtl3t r )
   DETAIL
    col 0 ,
    newline ,
    row + 1
   WITH maxcol = 2000 ,maxrow = 1 ,landscape ,noheading ,format = variable ,formfeed = none
  ;end select
  DECLARE command = vc WITH protect ,noconstant (build ("rm $CCLUSERDIR/" ,temp_file_name ) )
  DECLARE status = i2 WITH protect ,noconstant (0 )
  CALL dcl (command ,size (trim (command ) ) ,status )
  FREE DEFINE rtl3
 END ;Subroutine
 SUBROUTINE  printcsvreport (option ,output ,sep )
  DECLARE sep = vc WITH noconstant (" " ) ,protect
  DECLARE quote_var = vc WITH noconstant ("" ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  DECLARE k = i4 WITH protect ,noconstant (0 )
  DECLARE l = i4 WITH protect ,noconstant (0 )
  DECLARE m = i4 WITH protect ,noconstant (0 )
  DECLARE n = i4 WITH protect ,noconstant (0 )
  DECLARE modified_filename = vc WITH protect ,noconstant ("" )
  IF ((substring ((textlen (output ) - 3 ) ,textlen (output ) ,output ) != ".dat" ) )
   SET modified_filename = set_extension (value (output ) ,"csv" )
  ELSE
   SET modified_filename = output
  ENDIF
  IF ((output_style = 1 ) )
   SET sep = ","
   SET quote_var = '"'
  ENDIF
  CASE (option )
   OF 0 :
    SET stat = initrec (ep_report_csv )
    DECLARE num_exclusions = i4 WITH noconstant (0 ) ,protect
    DECLARE num_exceptions = i4 WITH noconstant (0 ) ,protect
    DECLARE num_numerators = i4 WITH noconstant (0 ) ,protect
    IF ((params->report_by = "GPRO" ) )
     SET stat = alterlist (ep_report_csv->eps ,size (params->grps ,5 ) )
     SET ep_report_csv->ep_cnt = size (params->grps ,5 )
     FOR (i = 1 TO size (params->grps ,5 ) )
      IF ((params->grps[i ].br_gpro_id > 0 ) )
       SET ep_report_csv->eps[i ].br_eligible_provider_id = params->grps[i ].br_gpro_id
       SET ep_report_csv->eps[i ].name = params->grps[i ].name
       SET ep_report_csv->eps[i ].tax_id_nbr_txt = params->grps[i ].tax_id_nbr_txt
       SET ep_report_csv->eps[i ].measure_cnt = size (params->grps[i ].measures ,5 )
       SET stat = alterlist (ep_report_csv->eps[i ].measures ,size (params->grps[i ].measures ,5 ) )
       FOR (j = 1 TO ep_report_csv->eps[i ].measure_cnt )
        SET ep_report_csv->eps[i ].measures[j ].reportmean = substring (1 ,25 ,params->grps[i ].
         measures[j ].mean )
        SET ep_report_csv->eps[i ].measures[j ].ippcnt = 0
        SET ep_report_csv->eps[i ].measures[j ].nnums = "0"
        SET ep_report_csv->eps[i ].measures[j ].ndens = 0
        SET ep_report_csv->eps[i ].measures[j ].nexcs = "0"
        SET ep_report_csv->eps[i ].measures[j ].nexceps = "0"
        SET ep_report_csv->eps[i ].measures[j ].percent = 0
       ENDFOR
      ENDIF
     ENDFOR
    ELSEIF ((params->report_by = "CPC" ) )
     SELECT INTO "nl:"
      FROM (dummyt d1 WITH seq = value (size (params->eps ,5 ) ) ),
       (br_cpc bc )
      PLAN (d1 )
       JOIN (bc
       WHERE (bc.br_cpc_id = params->eps[d1.seq ].br_eligible_provider_id ) )
      ORDER BY bc.br_cpc_id
      HEAD REPORT
       epcnt = 0
      HEAD bc.br_cpc_id
       epcnt = (epcnt + 1 ) ,stat = alterlist (ep_report_csv->eps ,epcnt ) ,ep_report_csv->eps[epcnt
       ].br_eligible_provider_id = bc.br_cpc_id ,ep_report_csv->eps[epcnt ].name = bc.br_cpc_name ,
       ep_report_csv->ep_cnt = epcnt ,stat = alterlist (ep_report_csv->eps[epcnt ].measures ,params->
        eps[d1.seq ].measure_cnt ) ,ep_report_csv->eps[epcnt ].measure_cnt = params->eps[d1.seq ].
       measure_cnt ,ep_report_csv->eps[epcnt ].npi_nbr_txt = bc.cpc_site_id_txt ,ep_report_csv->eps[
       epcnt ].tax_id_nbr_txt = bc.tax_id_nbr_txt ,
       FOR (i = 1 TO params->eps[d1.seq ].measure_cnt )
        ep_report_csv->eps[epcnt ].measures[i ].reportmean = substring (1 ,25 ,params->eps[d1.seq ].
         measures[i ].mean ) ,ep_report_csv->eps[epcnt ].measures[i ].ippcnt = 0 ,ep_report_csv->eps[
        epcnt ].measures[i ].nnums = "0" ,ep_report_csv->eps[epcnt ].measures[i ].ndens = 0 ,
        ep_report_csv->eps[epcnt ].measures[i ].nexcs = "0" ,ep_report_csv->eps[epcnt ].measures[i ].
        nexceps = "0" ,ep_report_csv->eps[epcnt ].measures[i ].percent = 0
       ENDFOR
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      rm = substring (1 ,25 ,params->eps[d1.seq ].measures[d2.seq ].mean )
      FROM (prsnl p ),
       (br_eligible_provider b ),
       (br_gpro_reltn gr ),
       (br_gpro g ),
       (dummyt d1 WITH seq = value (size (params->eps ,5 ) ) ),
       (dummyt d2 WITH seq = 1 )
      PLAN (d1
       WHERE (params->ep_cnt > 0 )
       AND maxrec (d2 ,params->eps[d1.seq ].measure_cnt ) )
       JOIN (d2
       WHERE (params->eps[d1.seq ].measure_cnt > 0 ) )
       JOIN (b
       WHERE (b.br_eligible_provider_id = params->eps[d1.seq ].br_eligible_provider_id ) )
       JOIN (p
       WHERE (p.person_id = b.provider_id ) )
       JOIN (gr
       WHERE (gr.active_ind = 1 )
       AND (gr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
       AND (gr.parent_entity_name = "BR_ELIGIBLE_PROVIDER" )
       AND (gr.parent_entity_id = b.br_eligible_provider_id ) )
       JOIN (g
       WHERE (g.active_ind = 1 )
       AND (g.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
       AND (g.br_gpro_id = gr.br_gpro_id ) )
      ORDER BY b.br_eligible_provider_id ,
       g.br_gpro_id ,
       rm
      HEAD REPORT
       epcnt = 0
      HEAD b.br_eligible_provider_id
       dummy = 0
      HEAD g.br_gpro_id
       j = locateval (num ,1 ,size (filter_params->tins ,5 ) ,g.br_gpro_id ,filter_params->tins[num ]
        .br_gpro_id ) ,
       IF ((((size (filter_params->tins ,5 ) = 0 ) ) OR ((j > 0 ) )) ) epcnt = (epcnt + 1 ) ,stat =
        alterlist (ep_report_csv->eps ,epcnt ) ,ep_report_csv->eps[epcnt ].br_eligible_provider_id =
        params->eps[d1.seq ].br_eligible_provider_id ,ep_report_csv->eps[epcnt ].name = cnvtupper (p
         .name_full_formatted ) ,ep_report_csv->ep_cnt = epcnt ,stat = alterlist (ep_report_csv->eps[
         epcnt ].measures ,params->eps[d1.seq ].measure_cnt ) ,ep_report_csv->eps[epcnt ].measure_cnt
         = params->eps[d1.seq ].measure_cnt ,ep_report_csv->eps[epcnt ].npi_nbr_txt = b
        .national_provider_nbr_txt ,ep_report_csv->eps[epcnt ].tax_id_nbr_txt = g.tax_id_nbr_txt ,i
        = 0
       ENDIF
      HEAD rm
       IF ((((size (filter_params->tins ,5 ) = 0 ) ) OR ((j > 0 ) )) ) i = (i + 1 ) ,ep_report_csv->
        eps[epcnt ].measures[i ].reportmean = rm ,ep_report_csv->eps[epcnt ].measures[i ].ippcnt = 0
       ,ep_report_csv->eps[epcnt ].measures[i ].nnums = "0" ,ep_report_csv->eps[epcnt ].measures[i ].
        ndens = 0 ,ep_report_csv->eps[epcnt ].measures[i ].nexcs = "0" ,ep_report_csv->eps[epcnt ].
        measures[i ].nexceps = "0" ,ep_report_csv->eps[epcnt ].measures[i ].percent = 0
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    ,
    FOR (i = 1 TO ep_report_csv->ep_cnt )
     FOR (j = 1 TO ep_report_csv->eps[i ].measure_cnt )
      SET ep_report_csv->eps[i ].measures[j ].reportname = substring (1 ,150 ,getmeasurename (trim (
         ep_report_csv->eps[i ].measures[j ].reportmean ) ) )
      SET ep_report_csv->eps[i ].measures[j ].measuredomain = substring (1 ,40 ,getmeasuredomain (
        trim (ep_report_csv->eps[i ].measures[j ].reportmean ) ) )
      SET ep_report_csv->eps[i ].measures[j ].high_priority_ind = getmeasurepriority (trim (
        ep_report_csv->eps[i ].measures[j ].reportmean ) )
      SET ep_report_csv->eps[i ].measures[j ].meas_type = getmeasuretype (trim (ep_report_csv->eps[i
        ].measures[j ].reportmean ) )
     ENDFOR
    ENDFOR
    ,
    FOR (i = 1 TO ep_report_csv->ep_cnt )
     FOR (j = 1 TO ep_report->ep_cnt )
      IF ((ep_report_csv->eps[i ].br_eligible_provider_id = ep_report->eps[j ].
      br_eligible_provider_id )
      AND (ep_report_csv->eps[i ].tax_id_nbr_txt = ep_report->eps[j ].tax_id_nbr_txt ) )
       FOR (k = 1 TO ep_report_csv->eps[i ].measure_cnt )
        FOR (l = 1 TO ep_report->eps[j ].measure_cnt )
         IF ((ep_report_csv->eps[i ].measures[k ].reportmean = ep_report->eps[j ].measures[l ].
         reportmean ) )
          SET ep_report_csv->eps[i ].measures[k ].patient_cnt = ep_report->eps[j ].measures[l ].
          patient_cnt
          SET ep_report_csv->eps[i ].measures[k ].percent = ep_report->eps[j ].measures[l ].percent
          SET stat = alterlist (ep_report_csv->eps[i ].measures[k ].patients ,ep_report->eps[j ].
           measures[l ].patient_cnt )
          FOR (m = 1 TO ep_report->eps[j ].measures[l ].patient_cnt )
           SET ep_report_csv->eps[i ].measures[k ].patients[m ].outcome_ind = ep_report->eps[j ].
           measures[l ].patients[m ].outcome_ind
           SET ep_report_csv->eps[i ].measures[k ].patients[m ].outcome_numeric = ep_report->eps[j ].
           measures[l ].patients[m ].outcome_numeric
           SET ep_report_csv->eps[i ].measures[k ].patients[m ].encntr_cnt = ep_report->eps[j ].
           measures[l ].patients[m ].encntr_cnt
           SET stat = alterlist (ep_report_csv->eps[i ].measures[k ].patients[m ].encntrs ,ep_report
            ->eps[j ].measures[l ].patients[m ].encntr_cnt )
           FOR (n = 1 TO ep_report->eps[j ].measures[l ].patients[m ].encntr_cnt )
            SET ep_report_csv->eps[i ].measures[k ].patients[m ].encntrs[n ].outcome_ind = ep_report
            ->eps[j ].measures[l ].patients[m ].encntrs[n ].outcome_ind
           ENDFOR
          ENDFOR
         ENDIF
        ENDFOR
       ENDFOR
      ENDIF
     ENDFOR
    ENDFOR
    ,
    FOR (i = 1 TO ep_report_csv->ep_cnt )
     FOR (j = 1 TO ep_report_csv->eps[i ].measure_cnt )
      SET num_exclusions = 0
      SET num_exceptions = 0
      SET num_numerators = 0
      SET ep_report_csv->eps[i ].measures[j ].ippcnt = 0
      SET ep_report_csv->eps[i ].measures[j ].nnums = "0"
      SET ep_report_csv->eps[i ].measures[j ].ndens = 0
      SET ep_report_csv->eps[i ].measures[j ].nexcs = "0"
      SET ep_report_csv->eps[i ].measures[j ].nexceps = "0"
      FOR (k = 1 TO ep_report_csv->eps[i ].measures[j ].patient_cnt )
       IF ((isencounterlevelmeasure (ep_report_csv->eps[i ].measures[j ].reportmean ) = 1 ) )
        FOR (l = 1 TO ep_report_csv->eps[i ].measures[j ].patients[k ].encntr_cnt )
         SET ep_report_csv->eps[i ].measures[j ].ippcnt = (ep_report_csv->eps[i ].measures[j ].ippcnt
          + 1 )
         SET ep_report_csv->eps[i ].measures[j ].ndens = (ep_report_csv->eps[i ].measures[j ].ndens
         + 1 )
         CASE (ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_ind )
          OF 1 :
           SET num_numerators = (num_numerators + 1 )
          OF 2 :
           SET num_exclusions = (num_exclusions + 1 )
          OF 3 :
           SET num_exceptions = (num_exceptions + 1 )
          OF 4 :
           SET ep_report_csv->eps[i ].measures[j ].ndens = (ep_report_csv->eps[i ].measures[j ].ndens
            - 1 )
         ENDCASE
        ENDFOR
       ELSE
        SET ep_report_csv->eps[i ].measures[j ].ippcnt = (ep_report_csv->eps[i ].measures[j ].ippcnt
        + 1 )
        SET ep_report_csv->eps[i ].measures[j ].ndens = (ep_report_csv->eps[i ].measures[j ].ndens +
        1 )
        CASE (ep_report_csv->eps[i ].measures[j ].patients[k ].outcome_ind )
         OF 1 :
          SET num_numerators = (num_numerators + 1 )
         OF 2 :
          SET num_exclusions = (num_exclusions + 1 )
         OF 3 :
          SET num_exceptions = (num_exceptions + 1 )
         OF 4 :
          SET ep_report_csv->eps[i ].measures[j ].ndens = (ep_report_csv->eps[i ].measures[j ].ndens
          - 1 )
        ENDCASE
       ENDIF
      ENDFOR
      IF ((uses_outcome_numeric (ep_report_csv->eps[i ].measures[j ].reportmean ) = 1 ) )
       SET ep_report_csv->eps[i ].measures[j ].nnums = "N/A"
      ELSE
       SET ep_report_csv->eps[i ].measures[j ].nnums = cnvtstring (num_numerators )
       SET ep_report_csv->eps[i ].measures[j ].percent = ((num_numerators / ((ep_report_csv->eps[i ].
       measures[j ].ndens - num_exclusions ) - num_exceptions ) ) * 100 )
      ENDIF
      IF ((hasnoexclusions (ep_report_csv->eps[i ].measures[j ].reportmean ) = 1 ) )
       SET ep_report_csv->eps[i ].measures[j ].nexcs = "N/A"
      ELSE
       SET ep_report_csv->eps[i ].measures[j ].nexcs = cnvtstring (num_exclusions )
      ENDIF
      IF ((hasnoexceptions (ep_report_csv->eps[i ].measures[j ].reportmean ) = 1 ) )
       SET ep_report_csv->eps[i ].measures[j ].nexceps = "N/A"
      ELSE
       SET ep_report_csv->eps[i ].measures[j ].nexceps = cnvtstring (num_exceptions )
      ENDIF
     ENDFOR
    ENDFOR
    ,
    SELECT
     IF ((params->report_by = "CPC" ) )
      cpc_name = build (quote_var ,substring (1 ,60 ,ep_report_csv->eps[d1.seq ].name ) ,quote_var )
      ,practice_id = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].npi_nbr_txt ) ,
      cpc_tin = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].tax_id_nbr_txt ) ,
      measure_domain = build (quote_var ,substring (1 ,40 ,ep_report_csv->eps[d1.seq ].measures[d2
        .seq ].measuredomain ) ,quote_var ) ,
      measure_name = build (quote_var ,substring (1 ,150 ,ep_report_csv->eps[d1.seq ].measures[d2
        .seq ].reportname ) ,quote_var ) ,
      ip_pop = build (floor (ep_report_csv->eps[d1.seq ].measures[d2.seq ].ippcnt ) ) ,
      denominator = build (floor (ep_report_csv->eps[d1.seq ].measures[d2.seq ].ndens ) ) ,
      exclusions = substring (1 ,10 ,ep_report_csv->eps[d1.seq ].measures[d2.seq ].nexcs ) ,
      exceptions = substring (1 ,10 ,ep_report_csv->eps[d1.seq ].measures[d2.seq ].nexceps ) ,
      numerator = substring (1 ,10 ,ep_report_csv->eps[d1.seq ].measures[d2.seq ].nnums ) ,
      percent_metric = build (ep_report_csv->eps[d1.seq ].measures[d2.seq ].percent ) ,
      reporting_start_dt_tm = format (cnvtdatetime (beg_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" ) ,
      reporting_end_dt_tm = format (cnvtdatetime (end_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" )
     ELSE
      provider_name = build (quote_var ,substring (1 ,60 ,ep_report_csv->eps[d1.seq ].name ) ,
       quote_var ) ,
      npi = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].npi_nbr_txt ) ,
      tin = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].tax_id_nbr_txt ) ,
      measure_name = build (quote_var ,substring (1 ,150 ,ep_report_csv->eps[d1.seq ].measures[d2
        .seq ].reportname ) ,quote_var ) ,
      ip_pop = build (floor (ep_report_csv->eps[d1.seq ].measures[d2.seq ].ippcnt ) ) ,
      denominator = build (floor (ep_report_csv->eps[d1.seq ].measures[d2.seq ].ndens ) ) ,
      exclusions = substring (1 ,10 ,ep_report_csv->eps[d1.seq ].measures[d2.seq ].nexcs ) ,
      exceptions = substring (1 ,10 ,ep_report_csv->eps[d1.seq ].measures[d2.seq ].nexceps ) ,
      numerator = substring (1 ,10 ,ep_report_csv->eps[d1.seq ].measures[d2.seq ].nnums ) ,
      percent_metric = build (ep_report_csv->eps[d1.seq ].measures[d2.seq ].percent ) ,
      reporting_start_dt_tm = format (cnvtdatetime (beg_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" ) ,
      reporting_end_dt_tm = format (cnvtdatetime (end_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" ) ,
      measure_type = build (ep_report_csv->eps[d1.seq ].measures[d2.seq ].meas_type ) ,
      high_priority_ind = build (ep_report_csv->eps[d1.seq ].measures[d2.seq ].high_priority_ind ) ,
      measure_domain = build (quote_var ,substring (1 ,40 ,ep_report_csv->eps[d1.seq ].measures[d2
        .seq ].measuredomain ) ,quote_var )
     ENDIF
     INTO value (modified_filename )
     FROM (dummyt d1 WITH seq = value (size (ep_report_csv->eps ,5 ) ) ),
      (dummyt d2 WITH seq = value (1 ) )
     PLAN (d1
      WHERE maxrec (d2 ,size (ep_report_csv->eps[d1.seq ].measures ,5 ) ) )
      JOIN (d2 )
     ORDER BY cnvtupper (ep_report_csv->eps[d1.seq ].name ) ,
      ep_report_csv->eps[d1.seq ].npi_nbr_txt ,
      ep_report_csv->eps[d1.seq ].tax_id_nbr_txt ,
      ep_report_csv->eps[d1.seq ].measures[d2.seq ].measureseq ,
      trim (ep_report_csv->eps[d1.seq ].measures[d2.seq ].reportname )
     WITH nocounter ,format ,format (date ,";;q" ) ,separator = value (sep )
    ;end select
   OF 1 :
    SET stat = alterlist (ep_report_csv->eps ,ep_report->ep_cnt )
    SET ep_report_csv->ep_cnt = ep_report->ep_cnt
    FOR (i = 1 TO ep_report->ep_cnt )
     SET ep_report_csv->eps[i ].br_eligible_provider_id = ep_report->eps[i ].br_eligible_provider_id
     SET ep_report_csv->eps[i ].provider_id = ep_report->eps[i ].provider_id
     SET ep_report_csv->eps[i ].name = ep_report->eps[i ].name
     SET ep_report_csv->eps[i ].tax_id_nbr_txt = ep_report->eps[i ].tax_id_nbr_txt
     SET ep_report_csv->eps[i ].npi_nbr_txt = ep_report->eps[i ].npi_nbr_txt
     SET ep_report_csv->eps[i ].measure_cnt = ep_report->eps[i ].measure_cnt
     SET stat = alterlist (ep_report_csv->eps[i ].measures ,ep_report->eps[i ].measure_cnt )
     SET ep_report_csv->eps[i ].measure_cnt = ep_report->eps[i ].measure_cnt
     FOR (j = 1 TO ep_report->eps[i ].measure_cnt )
      SET ep_report_csv->eps[i ].measures[j ].reportmean = substring (1 ,25 ,ep_report->eps[i ].
       measures[j ].reportmean )
      SET ep_report_csv->eps[i ].measures[j ].reportname = substring (1 ,150 ,getmeasurename (trim (
         ep_report->eps[i ].measures[j ].reportmean ) ) )
      SET ep_report_csv->eps[i ].measures[j ].measuredomain = substring (1 ,40 ,getmeasuredomain (
        trim (ep_report_csv->eps[i ].measures[j ].reportmean ) ) )
      SET ep_report_csv->eps[i ].measures[j ].high_priority_ind = getmeasurepriority (trim (
        ep_report_csv->eps[i ].measures[j ].reportmean ) )
      SET ep_report_csv->eps[i ].measures[j ].meas_type = getmeasuretype (trim (ep_report_csv->eps[i
        ].measures[j ].reportmean ) )
      SET ep_report_csv->eps[i ].measures[j ].patient_cnt = ep_report->eps[i ].measures[j ].
      patient_cnt
      SET stat = alterlist (ep_report_csv->eps[i ].measures[j ].patients ,ep_report->eps[i ].
       measures[j ].patient_cnt )
      SET ep_report_csv->eps[i ].measures[j ].patient_cnt = ep_report->eps[i ].measures[j ].
      patient_cnt
      FOR (k = 1 TO ep_report->eps[i ].measures[j ].patient_cnt )
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].person_id = ep_report->eps[i ].measures[
       j ].patients[k ].person_id
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].name = ep_report->eps[i ].measures[j ].
       patients[k ].name
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].mrn = ep_report->eps[i ].measures[j ].
       patients[k ].mrn
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].gender = ep_report->eps[i ].measures[j ].
       patients[k ].gender
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].race = wrap_string ("," ,ep_report->eps[
        i ].measures[j ].patients[k ].race )
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].ethnicity = wrap_string ("," ,ep_report->
        eps[i ].measures[j ].patients[k ].ethnicity )
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].payer = wrap_string ("," ,ep_report->eps[
        i ].measures[j ].patients[k ].payer )
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].payer_group = ep_report->eps[i ].
       measures[j ].patients[k ].payer_group
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].hic = ep_report->eps[i ].measures[j ].
       patients[k ].hic
       SET ep_report_csv->eps[i ].measures[j ].patients[k ].birth_date = ep_report->eps[i ].measures[
       j ].patients[k ].birth_date
       IF ((isencounterlevelmeasure (ep_report->eps[i ].measures[j ].reportmean ) = 1 ) )
        SET stat = alterlist (ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs ,ep_report->
         eps[i ].measures[j ].patients[k ].encntr_cnt )
        SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntr_cnt = ep_report->eps[i ].
        measures[j ].patients[k ].encntr_cnt
        FOR (l = 1 TO ep_report->eps[i ].measures[j ].patients[k ].encntr_cnt )
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].encntr_id = ep_report->eps[
         i ].measures[j ].patients[k ].encntrs[l ].encntr_id
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].visit_date = ep_report->
         eps[i ].measures[j ].patients[k ].encntrs[l ].visit_date
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].fin = ep_report->eps[i ].
         measures[j ].patients[k ].encntrs[l ].fin
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome = ep_report->eps[i
         ].measures[j ].patients[k ].encntrs[l ].outcome
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_ind = ep_report->
         eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_ind
         IF ((ep_report->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_ind = 1 ) )
          SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].isnumerator = "YES"
          SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_key = 1
         ELSE
          CASE (ep_report->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_ind )
           OF 2 :
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_key = 3
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].isnumerator = "N/A"
           OF 3 :
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_key = 5
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].isnumerator =
            "Exception"
           OF 4 :
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_key = 3
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].isnumerator = "N/A"
           ELSE
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].outcome_key = 2
            SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[l ].isnumerator = "NO"
          ENDCASE
         ENDIF
        ENDFOR
       ELSE
        SET stat = alterlist (ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs ,1 )
        SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome = ep_report->eps[i ]
        .measures[j ].patients[k ].outcome
        SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_ind = ep_report->
        eps[i ].measures[j ].patients[k ].outcome_ind
        SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_numeric = ep_report
        ->eps[i ].measures[j ].patients[k ].outcome_numeric
        IF ((ep_report->eps[i ].measures[j ].patients[k ].outcome_ind = 1 ) )
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].isnumerator = "YES"
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_key = 1
        ELSE
         CASE (ep_report->eps[i ].measures[j ].patients[k ].outcome_ind )
          OF 2 :
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_key = 4
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].isnumerator = "N/A"
          OF 3 :
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_key = 5
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].isnumerator =
           "Exception"
          OF 4 :
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_key = 3
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].isnumerator = "N/A"
          ELSE
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_key = 2
           SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].isnumerator = "NO"
         ENDCASE
        ENDIF
        IF ((uses_outcome_numeric (ep_report_csv->eps[i ].measures[j ].reportmean ) = 1 ) )
         SET ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].isnumerator = build (
          cnvtstring (ep_report_csv->eps[i ].measures[j ].patients[k ].encntrs[1 ].outcome_numeric ,
           6 ,2 ) ,"%" )
        ENDIF
       ENDIF
      ENDFOR
     ENDFOR
    ENDFOR
    ,
    SELECT INTO "nl:"
     FROM (lh_cqm_meas lh )
     WHERE (lh.meas_ident = "MU_EC_*_2019" )
     HEAD lh.meas_desc
      FOR (i = 1 TO ep_report_csv->ep_cnt )
       FOR (j = 1 TO ep_report->eps[i ].measure_cnt )
        IF ((substring (1 ,8 ,lh.meas_desc ) = substring (1 ,8 ,ep_report_csv->eps[i ].measures[j ].
         reportname ) ) )
         IF ((lh.high_priority_ind = 0 ) ) ep_report_csv->eps[i ].measures[j ].high_priority_ind =
          "No"
         ELSE ep_report_csv->eps[i ].measures[j ].high_priority_ind = "Yes"
         ENDIF
         ,
         IF ((lh.outcome_ind = 0 ) ) ep_report_csv->eps[i ].measures[j ].outcome_ind = "No"
         ELSE ep_report_csv->eps[i ].measures[j ].outcome_ind = "Yes"
         ENDIF
        ENDIF
       ENDFOR
      ENDFOR
     WITH nocounter
    ;end select
    SELECT
     IF ((params->report_by = "CPC" ) )
      cpc_name = build (quote_var ,substring (1 ,60 ,ep_report_csv->eps[d1.seq ].name ) ,quote_var )
      ,practice_id = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].npi_nbr_txt ) ,
      cpc_tin = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].tax_id_nbr_txt ) ,
      measure_domain = build (quote_var ,substring (1 ,40 ,ep_report_csv->eps[d1.seq ].measures[d3
        .seq ].measuredomain ) ,quote_var ) ,
      measure_name = build (quote_var ,substring (1 ,150 ,ep_report_csv->eps[d1.seq ].measures[d3
        .seq ].reportname ) ,quote_var ) ,
      patient_name = build (quote_var ,substring (1 ,60 ,ep_report_csv->eps[d1.seq ].measures[d3.seq
        ].patients[d2.seq ].name ) ,quote_var ) ,
      mrn = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].mrn ) ,
      birth_date = ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].birth_date ,
      sex = substring (1 ,50 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].gender
       ) ,
      race = substring (1 ,100 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].race
       ) ,
      ethnicity = substring (1 ,100 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].
       ethnicity ) ,
      cms_payer_group = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2
       .seq ].payer_group ) ,
      payer = substring (1 ,100 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].
       payer ) ,
      hic# = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].hic )
      ,visit_date = ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs[d4.seq ].
      visit_date ,
      fin_nbr = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].
       encntrs[d4.seq ].fin ) ,
      numerator = ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs[d4.seq ].
      isnumerator ,
      outcome = build (quote_var ,substring (1 ,50 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].
        patients[d2.seq ].encntrs[d4.seq ].outcome ) ,quote_var ) ,
      reporting_start_dt_tm = format (cnvtdatetime (beg_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" ) ,
      reporting_end_dt_tm = format (cnvtdatetime (end_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" )
     ELSE
      provider_name = build (quote_var ,substring (1 ,60 ,ep_report_csv->eps[d1.seq ].name ) ,
       quote_var ) ,
      npi = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].npi_nbr_txt ) ,
      tin = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].tax_id_nbr_txt ) ,
      measure_name = build (quote_var ,substring (1 ,150 ,ep_report_csv->eps[d1.seq ].measures[d3
        .seq ].reportname ) ,quote_var ) ,
      patient_name = build (quote_var ,substring (1 ,60 ,ep_report_csv->eps[d1.seq ].measures[d3.seq
        ].patients[d2.seq ].name ) ,quote_var ) ,
      mrn = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].mrn ) ,
      birth_date = ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].birth_date ,
      sex = substring (1 ,50 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].gender
       ) ,
      race = substring (1 ,100 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].race
       ) ,
      ethnicity = substring (1 ,100 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].
       ethnicity ) ,
      cms_payer_group = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2
       .seq ].payer_group ) ,
      payer = substring (1 ,100 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].
       payer ) ,
      hic# = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].hic )
      ,visit_date = ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs[d4.seq ].
      visit_date ,
      fin_nbr = substring (1 ,20 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].
       encntrs[d4.seq ].fin ) ,
      numerator = ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs[d4.seq ].
      isnumerator ,
      outcome = build (quote_var ,substring (1 ,50 ,ep_report_csv->eps[d1.seq ].measures[d3.seq ].
        patients[d2.seq ].encntrs[d4.seq ].outcome ) ,quote_var ) ,
      reporting_start_dt_tm = format (cnvtdatetime (beg_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" ) ,
      reporting_end_dt_tm = format (cnvtdatetime (end_extract_dt_tm ) ,"MM/DD/YYYY HH:MM:SS;;D" ) ,
      measure_type = build (ep_report_csv->eps[d1.seq ].measures[d3.seq ].meas_type ) ,
      high_priority_ind = build (ep_report_csv->eps[d1.seq ].measures[d3.seq ].high_priority_ind ) ,
      measure_domain = build (quote_var ,substring (1 ,40 ,ep_report_csv->eps[d1.seq ].measures[d3
        .seq ].measuredomain ) ,quote_var )
     ENDIF
     INTO value (modified_filename )
     FROM (dummyt d1 WITH seq = value (size (ep_report_csv->eps ,5 ) ) ),
      (dummyt d2 WITH seq = value (1 ) ),
      (dummyt d3 WITH seq = value (1 ) ),
      (dummyt d4 WITH seq = value (1 ) )
     PLAN (d1
      WHERE maxrec (d3 ,size (ep_report_csv->eps[d1.seq ].measures ,5 ) ) )
      JOIN (d3
      WHERE maxrec (d2 ,size (ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients ,5 ) ) )
      JOIN (d2
      WHERE maxrec (d4 ,size (ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs
         ,5 ) ) )
      JOIN (d4 )
     ORDER BY cnvtupper (ep_report_csv->eps[d1.seq ].name ) ,
      ep_report_csv->eps[d1.seq ].npi_nbr_txt ,
      ep_report_csv->eps[d1.seq ].tax_id_nbr_txt ,
      ep_report_csv->eps[d1.seq ].measures[d3.seq ].measureseq ,
      ep_report_csv->eps[d1.seq ].measures[d3.seq ].reportname ,
      ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs[d4.seq ].outcome_key ,
      ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].encntrs[d4.seq ].outcome ,
      cnvtupper (ep_report_csv->eps[d1.seq ].measures[d3.seq ].patients[d2.seq ].name )
     WITH nocounter ,format ,format (date ,";;q" ) ,separator = value (sep )
    ;end select
  ENDCASE
  SET stat = initrec (ep_report_csv )
 END ;Subroutine
 SUBROUTINE  get_cms_submeasure_str (rm )
  DECLARE return_str = vc WITH protect ,noconstant ("" )
  DECLARE sm_str = vc WITH protect ,noconstant ("" )
  DECLARE first_period = i2 WITH protect ,noconstant (findstring ("." ,rm ) )
  DECLARE second_period = i2 WITH protect ,noconstant (findstring ("." ,rm ,(first_period + 1 ) ) )
  IF ((first_period = 0 ) )
   SET sm_str = "_SM1"
  ELSEIF ((first_period > 0 )
  AND (second_period = 0 ) )
   SET sm_str = build ("_SM" ,substring ((first_period + 1 ) ,1 ,rm ) )
  ELSEIF ((first_period > 0 )
  AND (second_period > 0 ) )
   CASE (substring (first_period ,((size (rm ,1 ) - first_period ) + 1 ) ,rm ) )
    OF ".1.1" :
     SET sm_str = "_SM1"
    OF ".1.2" :
     SET sm_str = "_SM2"
    OF ".1.3" :
     SET sm_str = "_SM3"
    OF ".2.1" :
     SET sm_str = "_SM4"
    OF ".2.2" :
     SET sm_str = "_SM5"
    OF ".2.3" :
     SET sm_str = "_SM6"
    OF ".3.1" :
     SET sm_str = "_SM7"
    OF ".3.2" :
     SET sm_str = "_SM8"
    OF ".3.3" :
     SET sm_str = "_SM9"
   ENDCASE
  ENDIF
  SET return_str = build2 (reportmean2cms_str (rm ) ,sm_str )
  RETURN (return_str )
 END ;Subroutine
 SUBROUTINE  gettarget_file (null )
  IF ((value ( $OUTDEV ) != "MINE" )
  AND (reqinfo->updt_id != 0 ) )
   IF ((validate (request->qual[1 ].parameter ) != 0 ) )
    IF ((isnumeric (request->qual[1 ].parameter ) != 1 )
    AND (cnvtint (request->qual[1 ].parameter ) != 0 ) )
     SET target_file = build2 (value (request->qual[1 ].parameter ) )
    ENDIF
   ELSE
    SET target_file = value ( $OUTDEV )
   ENDIF
  ELSE
   SET target_file = value ( $OUTDEV )
  ENDIF
  SET target_file = trim (target_file ,3 )
 END ;Subroutine
 SUBROUTINE  wrap_string (separator ,string )
  DECLARE temp_str = vc WITH protect ,noconstant (build (string ) )
  SET temp_str = trim (temp_str ,3 )
  IF ((findstring (separator ,temp_str ) > 0 ) )
   SET temp_str = build ('"' ,temp_str ,'"' )
  ENDIF
  RETURN (trim (temp_str ,3 ) )
 END ;Subroutine
 SUBROUTINE  set_extension (file_name ,extension )
  DECLARE out_file = vc WITH noconstant ("" )
  DECLARE pos = i2 WITH noconstant (findstring ("." ,file_name ,1 ,1 ) )
  IF ((pos > 0 ) )
   SET out_file = build (substring (1 ,pos ,file_name ) ,extension )
  ELSE
   SET out_file = build (file_name ,"." ,extension )
  ENDIF
  RETURN (out_file )
 END ;Subroutine
 FREE RECORD lh_nqf22_meds
 RECORD lh_nqf22_meds (
   1 query_cnt = i4
   1 queries [* ]
     2 query_name = vc
     2 val_set_name = vc
     2 include_ind = i4
     2 uniq_date_cnt = i4
     2 qual [* ]
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
 )
 DECLARE setvalsets4nqf22 (null ) = null WITH public
 SUBROUTINE  setvalsets4nqf22 (null )
  SET stat = initrec (lh_nqf22_meds )
  SET lh_nqf22_meds->query_cnt = 108
  SET stat = alterlist (lh_nqf22_meds->queries ,lh_nqf22_meds->query_cnt )
  SET lh_nqf22_meds->queries[1 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M3"
  SET lh_nqf22_meds->queries[1 ].val_set_name = "ACETAMINOPHEN_BUTALBITAL"
  SET lh_nqf22_meds->queries[2 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M4"
  SET lh_nqf22_meds->queries[2 ].val_set_name = "ACETAMINOPHEN_BUTALBITAL_CAFFEINE"
  SET lh_nqf22_meds->queries[3 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M5"
  SET lh_nqf22_meds->queries[3 ].val_set_name = "ACETAMINOPHEN_BUTALBITAL_CAFFEINE_CODEINE"
  SET lh_nqf22_meds->queries[4 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M6"
  SET lh_nqf22_meds->queries[4 ].val_set_name = "ACETAMINOPHEN_CHLORPHENIRAMINE_DEXTROMETHORPHAN"
  SET lh_nqf22_meds->queries[5 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M7"
  SET lh_nqf22_meds->queries[5 ].val_set_name =
  "ACETAMINOPHEN_CHLORPHENIRAMINE_DEXTROMETHORPHAN_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[6 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M8"
  SET lh_nqf22_meds->queries[6 ].val_set_name =
  "ACETAMINOPHEN_CHLORPHENIRAMINE_DEXTROMETHORPHAN_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[7 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M9"
  SET lh_nqf22_meds->queries[7 ].val_set_name = "ACETAMINOPHEN_CHLORPHENIRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[8 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M10"
  SET lh_nqf22_meds->queries[8 ].val_set_name = "ACETAMINOPHEN_CHLORPHENIRAMINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[9 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M11"
  SET lh_nqf22_meds->queries[9 ].val_set_name = "ACETAMINOPHEN_DEXBROMPHENIRAMINE"
  SET lh_nqf22_meds->queries[10 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M12"
  SET lh_nqf22_meds->queries[10 ].val_set_name =
  "ACETAMINOPHEN_DEXTROMETHORPHAN_DIPHENHYDRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[11 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M13"
  SET lh_nqf22_meds->queries[11 ].val_set_name = "CETAMINOPHEN_DEXTROMETHORPHAN_DOXYLAMINE"
  SET lh_nqf22_meds->queries[12 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M14"
  SET lh_nqf22_meds->queries[12 ].val_set_name =
  "ACETAMINOPHEN_DEXTROMETHORPHAN_DOXYLAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[13 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M15"
  SET lh_nqf22_meds->queries[13 ].val_set_name = "ACETAMINOPHEN_DIPHENHYDRAMINE"
  SET lh_nqf22_meds->queries[14 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M16"
  SET lh_nqf22_meds->queries[14 ].val_set_name = "ACETAMINOPHEN_DIPHENHYDRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[15 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M17"
  SET lh_nqf22_meds->queries[15 ].val_set_name = "AMITRIPTYLINE_CHLORDIAZEPOXIDE"
  SET lh_nqf22_meds->queries[16 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M18"
  SET lh_nqf22_meds->queries[16 ].val_set_name = "AMITRIPTYLINE_PERPHENAZINE"
  SET lh_nqf22_meds->queries[17 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M19"
  SET lh_nqf22_meds->queries[17 ].val_set_name = "AMITRIPTYLINE_HYDROCHLORIDE"
  SET lh_nqf22_meds->queries[18 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M20"
  SET lh_nqf22_meds->queries[18 ].val_set_name = "ASPIRIN_BUTALBITAL_CAFFEINE"
  SET lh_nqf22_meds->queries[19 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M21"
  SET lh_nqf22_meds->queries[19 ].val_set_name = "AMOXAPINE"
  SET lh_nqf22_meds->queries[20 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M22"
  SET lh_nqf22_meds->queries[20 ].val_set_name = "ASPIRIN_CAFFEINE_ORPHENADRINE"
  SET lh_nqf22_meds->queries[21 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M23"
  SET lh_nqf22_meds->queries[21 ].val_set_name = "ATROPINE_HYOSCYAMINE_PHENOBARBITAL_SCOPOLAMINE"
  SET lh_nqf22_meds->queries[22 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M24"
  SET lh_nqf22_meds->queries[22 ].val_set_name = "ATROPINE_DIPHENOXYLATE"
  SET lh_nqf22_meds->queries[23 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M25"
  SET lh_nqf22_meds->queries[23 ].val_set_name = "BENZTROPINE"
  SET lh_nqf22_meds->queries[24 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M26"
  SET lh_nqf22_meds->queries[24 ].val_set_name = "BROMPHENIRAMINE"
  SET lh_nqf22_meds->queries[25 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M27"
  SET lh_nqf22_meds->queries[25 ].val_set_name = "BROMPHENIRAMINE_CODEINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[26 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M28"
  SET lh_nqf22_meds->queries[26 ].val_set_name = "BROMPHENIRAMINE_CODEINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[27 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M29"
  SET lh_nqf22_meds->queries[27 ].val_set_name = "BROMPHENIRAMINE_DEXTROMETHORPHAN_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[28 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M30"
  SET lh_nqf22_meds->queries[28 ].val_set_name = "BROMPHENIRAMINE_DEXTROMETHORPHAN_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[29 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M31"
  SET lh_nqf22_meds->queries[29 ].val_set_name = "BROMPHENIRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[30 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M32"
  SET lh_nqf22_meds->queries[30 ].val_set_name = "BROMPHENIRAMINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[31 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M33"
  SET lh_nqf22_meds->queries[31 ].val_set_name = "BUTABARBITAL"
  SET lh_nqf22_meds->queries[32 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M34"
  SET lh_nqf22_meds->queries[32 ].val_set_name = "CARBINOXAMINE"
  SET lh_nqf22_meds->queries[33 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M35"
  SET lh_nqf22_meds->queries[33 ].val_set_name = "CARISOPRODOL"
  SET lh_nqf22_meds->queries[34 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M36"
  SET lh_nqf22_meds->queries[34 ].val_set_name = "CHLOPHEDIANOL_CHLORPHENIRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[35 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M37"
  SET lh_nqf22_meds->queries[35 ].val_set_name = "CHLOPHEDIANOL_DEXCHLORPHENIRAMINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[36 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M38"
  SET lh_nqf22_meds->queries[36 ].val_set_name = "CHLORPHENIRAMINE"
  SET lh_nqf22_meds->queries[37 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M39"
  SET lh_nqf22_meds->queries[37 ].val_set_name = "CHLORPHENIRAMINE_CODEINE"
  SET lh_nqf22_meds->queries[38 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M40"
  SET lh_nqf22_meds->queries[38 ].val_set_name = "CHLORPHENIRAMINE_DEXTROMETHORPHAN_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[39 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M41"
  SET lh_nqf22_meds->queries[39 ].val_set_name = "CHLORPHENIRAMINE_DEXTROMETHORPHAN_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[40 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M42"
  SET lh_nqf22_meds->queries[40 ].val_set_name = "CHLORPHENIRAMINE_HYDROCODONE"
  SET lh_nqf22_meds->queries[41 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M43"
  SET lh_nqf22_meds->queries[41 ].val_set_name = "CHLORPHENIRAMINE_HYDROCODONE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[42 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M44"
  SET lh_nqf22_meds->queries[42 ].val_set_name = "CHLORPHENIRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[43 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M45"
  SET lh_nqf22_meds->queries[43 ].val_set_name = "CHLORPHENIRAMINE_PHENYLEPHRINE_PHENYLTOLOXAMINE"
  SET lh_nqf22_meds->queries[44 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M46"
  SET lh_nqf22_meds->queries[44 ].val_set_name = "CHLORPHENIRAMINE_PHENYLEPHRINE_PYRILAMINE"
  SET lh_nqf22_meds->queries[45 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M47"
  SET lh_nqf22_meds->queries[45 ].val_set_name = "CHLORPHENIRAMINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[46 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M48"
  SET lh_nqf22_meds->queries[46 ].val_set_name = "CHLORPROPAMIDE"
  SET lh_nqf22_meds->queries[47 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M49"
  SET lh_nqf22_meds->queries[47 ].val_set_name = "CHLORZOXAZONE"
  SET lh_nqf22_meds->queries[48 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M50"
  SET lh_nqf22_meds->queries[48 ].val_set_name = "CLEMASTINE"
  SET lh_nqf22_meds->queries[49 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M51"
  SET lh_nqf22_meds->queries[49 ].val_set_name = "CLOMIPRAMINE"
  SET lh_nqf22_meds->queries[50 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M52"
  SET lh_nqf22_meds->queries[50 ].val_set_name = "CONJUGATED_ESTROGENS"
  SET lh_nqf22_meds->queries[51 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M53"
  SET lh_nqf22_meds->queries[51 ].val_set_name = "CONJUGATED_ESTROGENS_MEDROXYPROGESTERONE"
  SET lh_nqf22_meds->queries[52 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M54"
  SET lh_nqf22_meds->queries[52 ].val_set_name = "CYCLOBENZAPRINE_HYDROCHLORIDE"
  SET lh_nqf22_meds->queries[53 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M55"
  SET lh_nqf22_meds->queries[53 ].val_set_name = "CYPROHEPTADINE"
  SET lh_nqf22_meds->queries[54 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M56"
  SET lh_nqf22_meds->queries[54 ].val_set_name = "DESIPRAMINE"
  SET lh_nqf22_meds->queries[55 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M57"
  SET lh_nqf22_meds->queries[55 ].val_set_name = "DEXBROMPHENIRAMINE"
  SET lh_nqf22_meds->queries[56 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M58"
  SET lh_nqf22_meds->queries[56 ].val_set_name = "DEXBROMPHENIRAMINE_DEXTROMETHORPHAN_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[57 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M59"
  SET lh_nqf22_meds->queries[57 ].val_set_name = "DEXBROMPHENIRAMINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[58 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M60"
  SET lh_nqf22_meds->queries[58 ].val_set_name =
  "DEXBROMPHENIRAMINE_MALEATE_PSEUDOEPHEDRINE_HYDROCHLORIDE"
  SET lh_nqf22_meds->queries[59 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M61"
  SET lh_nqf22_meds->queries[59 ].val_set_name =
  "DEXCHLORPHENIRAMINE_DEXTROMETHORPHAN_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[60 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M62"
  SET lh_nqf22_meds->queries[60 ].val_set_name = "DEXCHLORPHENIRAMINE_PSEUDOEPHEDRINE"
  SET lh_nqf22_meds->queries[61 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M63"
  SET lh_nqf22_meds->queries[61 ].val_set_name = "DEXTROMETHORPHAN_DIPHENHYDRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[62 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M64"
  SET lh_nqf22_meds->queries[62 ].val_set_name = "DEXTROMETHORPHAN_DOXYLAMINE"
  SET lh_nqf22_meds->queries[63 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M65"
  SET lh_nqf22_meds->queries[63 ].val_set_name = "DICYCLOMINE"
  SET lh_nqf22_meds->queries[64 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M66"
  SET lh_nqf22_meds->queries[64 ].val_set_name = "DIENOGEST_ESTRADIOL_MULTIPHASIC"
  SET lh_nqf22_meds->queries[65 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M67"
  SET lh_nqf22_meds->queries[65 ].val_set_name = "DIMENHYDRINATE"
  SET lh_nqf22_meds->queries[66 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M68"
  SET lh_nqf22_meds->queries[66 ].val_set_name = "DIPHENHYDRAMINE_IBUPROFEN"
  SET lh_nqf22_meds->queries[67 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M69"
  SET lh_nqf22_meds->queries[67 ].val_set_name = "DIPHENHYDRAMINE_PHENYLEPHRINE"
  SET lh_nqf22_meds->queries[68 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M70"
  SET lh_nqf22_meds->queries[68 ].val_set_name = "DIPHENHYDRAMINE_HYDROCHLORIDE"
  SET lh_nqf22_meds->queries[69 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M71"
  SET lh_nqf22_meds->queries[69 ].val_set_name = "DIPYRIDAMOLE"
  SET lh_nqf22_meds->queries[70 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M72"
  SET lh_nqf22_meds->queries[70 ].val_set_name = "DISOPYRAMIDE"
  SET lh_nqf22_meds->queries[71 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M73"
  SET lh_nqf22_meds->queries[71 ].val_set_name = "DROSPIRENONE_ESTRADIOL"
  SET lh_nqf22_meds->queries[72 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M74"
  SET lh_nqf22_meds->queries[72 ].val_set_name = "ESTERIFIED_ESTROGENS"
  SET lh_nqf22_meds->queries[73 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M75"
  SET lh_nqf22_meds->queries[73 ].val_set_name = "ESTERIFIED_ESTROGENS_METHYLTESTOSTERONE"
  SET lh_nqf22_meds->queries[74 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M76"
  SET lh_nqf22_meds->queries[74 ].val_set_name = "ESTRADIOL"
  SET lh_nqf22_meds->queries[75 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M77"
  SET lh_nqf22_meds->queries[75 ].val_set_name = "ESTRADIOL_NORETHINDRONE"
  SET lh_nqf22_meds->queries[76 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M78"
  SET lh_nqf22_meds->queries[76 ].val_set_name = "ESTROPIPATE"
  SET lh_nqf22_meds->queries[77 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M79"
  SET lh_nqf22_meds->queries[77 ].val_set_name = "GLYBURIDE"
  SET lh_nqf22_meds->queries[78 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M80"
  SET lh_nqf22_meds->queries[78 ].val_set_name = "GLYBURIDE_METFORMIN"
  SET lh_nqf22_meds->queries[79 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M81"
  SET lh_nqf22_meds->queries[79 ].val_set_name = "GUANFACINE"
  SET lh_nqf22_meds->queries[80 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M82"
  SET lh_nqf22_meds->queries[80 ].val_set_name = "HYDROCHLOROTHIAZIDE_METHYLDOPA"
  SET lh_nqf22_meds->queries[81 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M83"
  SET lh_nqf22_meds->queries[81 ].val_set_name = "HYDROXYZINE"
  SET lh_nqf22_meds->queries[82 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M84"
  SET lh_nqf22_meds->queries[82 ].val_set_name = "HYOSCYAMINE"
  SET lh_nqf22_meds->queries[83 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M85"
  SET lh_nqf22_meds->queries[83 ].val_set_name = "HYOSCYAMINE_METHENAMINE_MBLUE_PHENYL_SALICYL"
  SET lh_nqf22_meds->queries[84 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M86"
  SET lh_nqf22_meds->queries[84 ].val_set_name =
  "HYOSCYAMINE_METHENAMINE_MBLUE_PHENYL_SALICYL_SODIUM_BIPHOSPHATE"
  SET lh_nqf22_meds->queries[85 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M87"
  SET lh_nqf22_meds->queries[85 ].val_set_name = "HYOSCYAMINE_METHENAMINE_MBLUE_SODIUM_BIPHOSPHATE"
  SET lh_nqf22_meds->queries[86 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M88"
  SET lh_nqf22_meds->queries[86 ].val_set_name = "IMIPRAMINE"
  SET lh_nqf22_meds->queries[87 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M89"
  SET lh_nqf22_meds->queries[87 ].val_set_name = "INDOMETHACIN"
  SET lh_nqf22_meds->queries[88 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M90"
  SET lh_nqf22_meds->queries[88 ].val_set_name = "ISOXSUPRINE"
  SET lh_nqf22_meds->queries[89 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M91"
  SET lh_nqf22_meds->queries[89 ].val_set_name = "KETOROLAC_TROMETHAMINE"
  SET lh_nqf22_meds->queries[90 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M92"
  SET lh_nqf22_meds->queries[90 ].val_set_name = "MECLIZINE"
  SET lh_nqf22_meds->queries[91 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M93"
  SET lh_nqf22_meds->queries[91 ].val_set_name = "MEGESTROL"
  SET lh_nqf22_meds->queries[92 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M94"
  SET lh_nqf22_meds->queries[92 ].val_set_name = "MEPERIDINE"
  SET lh_nqf22_meds->queries[93 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M95"
  SET lh_nqf22_meds->queries[93 ].val_set_name = "MEPROBAMATE"
  SET lh_nqf22_meds->queries[94 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M96"
  SET lh_nqf22_meds->queries[94 ].val_set_name = "METAXALONE"
  SET lh_nqf22_meds->queries[95 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M97"
  SET lh_nqf22_meds->queries[95 ].val_set_name = "METHOCARBAMOL"
  SET lh_nqf22_meds->queries[96 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M98"
  SET lh_nqf22_meds->queries[96 ].val_set_name = "METHYLDOPA"
  SET lh_nqf22_meds->queries[97 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M99"
  SET lh_nqf22_meds->queries[97 ].val_set_name = "NIFEDIPINE"
  SET lh_nqf22_meds->queries[98 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M100"
  SET lh_nqf22_meds->queries[98 ].val_set_name = "NORTRIPTYLINE"
  SET lh_nqf22_meds->queries[99 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M101"
  SET lh_nqf22_meds->queries[99 ].val_set_name = "PAROXETINE"
  SET lh_nqf22_meds->queries[100 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M102"
  SET lh_nqf22_meds->queries[100 ].val_set_name = "PHENOBARBITAL"
  SET lh_nqf22_meds->queries[101 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M103"
  SET lh_nqf22_meds->queries[101 ].val_set_name = "PROMETHAZINE_HYDROCHLORIDE"
  SET lh_nqf22_meds->queries[102 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M104"
  SET lh_nqf22_meds->queries[102 ].val_set_name = "PROTRIPTYLINE"
  SET lh_nqf22_meds->queries[103 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M105"
  SET lh_nqf22_meds->queries[103 ].val_set_name = "PSEUDOEPHEDRINE_TRIPROLIDINE"
  SET lh_nqf22_meds->queries[104 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M106"
  SET lh_nqf22_meds->queries[104 ].val_set_name = "TRIHEXYPHENIDYL"
  SET lh_nqf22_meds->queries[105 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M107"
  SET lh_nqf22_meds->queries[105 ].val_set_name = "TRIMIPRAMINE"
  SET lh_nqf22_meds->queries[106 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M108"
  SET lh_nqf22_meds->queries[106 ].val_set_name = "TRIPROLIDINE"
  SET lh_nqf22_meds->queries[107 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M109"
  SET lh_nqf22_meds->queries[107 ].val_set_name = "ANTI_INFECTIVES_OTHER"
  SET lh_nqf22_meds->queries[108 ].query_name = "NQF2019_0022: HIGH_RISK_MEDICATION: M110"
  SET lh_nqf22_meds->queries[108 ].val_set_name = "NONBENZODIAZEPINE_HYPNOTICS"
 END ;Subroutine
 DECLARE getresults_nqf4 (null ) = null
 DECLARE getpopulation_nqf4 (null ) = null
 DECLARE getattribution_nqf4 ((measure_name = vc ) ) = null
 DECLARE getoutcome1_nqf4 (null ) = null
 DECLARE getoutcome2_nqf4 (null ) = null
 DECLARE getagegroup_nqf4 ((rec_name = vc (ref ) ) ,(grp = i2 ) ) = null
 DECLARE getexclusion_nqf4 (null ) = null
 SUBROUTINE  getresults_nqf4 (null )
  SET br_filters->provider_attribution = getproviderattribution ("4" )
  CALL geteprfilter ("4" )
  CALL getpopulation_nqf4 (0 )
  CALL getattribution_nqf4 ("MU_EC_0004_2019.1.1" )
  CALL getexclusion_nqf4 (0 )
  CALL getoutcome1_nqf4 (0 )
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = moverec (lh_ep_reply ,lh_ep_reply_bk )
  CALL getagegroup_nqf4 (lh_ep_reply ,1 )
  CALL summaryreport ("MU_EC_0004_2019.1.1" )
  SET stat = initrec (lh_ep_reply )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  CALL getagegroup_nqf4 (lh_ep_reply ,2 )
  CALL getattribution_nqf4 ("MU_EC_0004_2019.1.2" )
  CALL summaryreport ("MU_EC_0004_2019.1.2" )
  SET stat = initrec (lh_ep_reply )
  CALL sum_submeasures ("MU_EC_0004_2019.1.1" ,"MU_EC_0004_2019.1.2" ,"MU_EC_0004_2019.1.3" )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  CALL getoutcome2_nqf4 (0 )
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = moverec (lh_ep_reply ,lh_ep_reply_bk )
  CALL getagegroup_nqf4 (lh_ep_reply ,1 )
  CALL getattribution_nqf4 ("MU_EC_0004_2019.2.1" )
  CALL summaryreport ("MU_EC_0004_2019.2.1" )
  SET stat = initrec (lh_ep_reply )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  CALL getagegroup_nqf4 (lh_ep_reply ,2 )
  CALL getattribution_nqf4 ("MU_EC_0004_2019.2.2" )
  CALL summaryreport ("MU_EC_0004_2019.2.2" )
  CALL sum_submeasures ("MU_EC_0004_2019.2.1" ,"MU_EC_0004_2019.2.2" ,"MU_EC_0004_2019.2.3" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf4 (null )
  DECLARE p_iter = i4 WITH protect ,noconstant (0 )
  DECLARE e_iter = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE p_batch_size = i2 WITH protect ,constant (1000 )
  DECLARE e_batch_size = i2 WITH protect ,constant (10 )
  DECLARE person_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE encntr_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtlookahead ("319,D" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtlookahead ("319,D" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (pop.reg_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("POPULATION: NQF2019_0004: A1" ,
    "POPULATION: NQF2019_0004: B1" ,
    "POPULATION: NQF2019_0004: C1" ,
    "POPULATION: NQF2019_0004: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (p.active_ind = 1 )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("13,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    person_cnt = 0
   HEAD pop.person_id
    person_cnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = person_cnt ,
    IF ((mod (person_cnt ,p_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons ,((
      person_cnt + p_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[person_cnt ].person_id = pop.person_id ,lh_ep_reply->persons[person_cnt ].
    mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[person_cnt ].outcome_ind = 0 ,lh_ep_reply->persons[
    person_cnt ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[person_cnt ].exclude_ind = 1 ,
    lh_ep_reply->persons[person_cnt ].age = floor ((datetimediff (cnvtdatetime (beg_extract_dt_tm ) ,
      p.birth_dt_tm ) / 365.25 ) )
   HEAD pop.encntr_id
    encntr_cnt = (lh_ep_reply->persons[person_cnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[
    person_cnt ].encntr_cnt = encntr_cnt ,
    IF ((mod (encntr_cnt ,e_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons[person_cnt ].
      encntrs ,((encntr_cnt + e_batch_size ) - 1 ) )
    ENDIF
    ,stat = alterlist (lh_ep_reply->persons[person_cnt ].encntrs ,encntr_cnt ) ,lh_ep_reply->persons[
    person_cnt ].encntrs[encntr_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[person_cnt ].
    encntrs[encntr_cnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[person_cnt ].encntrs[
    encntr_cnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[person_cnt ].encntrs[encntr_cnt
    ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[person_cnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[person_cnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[person_cnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[person_cnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[person_cnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[person_cnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[person_cnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[person_cnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[person_cnt ].encntrs ,encntr_cnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,person_cnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (build ("Size of LH_EP_REPLY->persons:" ,size (lh_ep_reply->persons ,5 ) ) )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";First diagnosis of alcohol or drug dependence" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,1 ,lh_ep_reply->persons[p_iter ].exclude_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtlookahead ("319,D" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0004: ALCOHOL_DRUG_DEP: F1" ,
    "NQF2019_0004: ALCOHOL_DRUG_DEP: G1" ,
    "NQF2019_0004: ALCOHOL_DRUG_DEP: H1" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm
        ) AND cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm ) ) )
       lh_ep_reply->persons[person_pos ].exclude_ind = 0 ,lh_ep_reply->persons[person_pos ].
       pop_ep_dt_tm = cnvtdatetime (cnvtdate (pat.ep_dt_tm ) ,0 )
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo (";First diagnosis of alcohol or drug dependence" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf4 (measure_name )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0004" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("EMERG_DEPT_VISIT_ENC" ,"0004" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("DETOX_VISIT_ENC" ,"0004" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HOSP_OBS_CARE_INITIAL_ENC" ,"0004" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("DSCHG_SERV_HI_SAME_DAY_ENC" ,"0004" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOSP_INPT_VISIT_INITIAL_ENC" ,"0004" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SERV_HOSP_INPT_ENC" ,"0004" ,"'CPT4'" ,"1=1" )
  CALL getepdata (measure_name ,br_filters->provider_attribution ,"NQF2019_0004" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf4 (null )
  DECLARE p_iter = i4 WITH protect ,noconstant (0 )
  DECLARE e_iter = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE evnt_date = dq8 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0004: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0004: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0004: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0004: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0004: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0004: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0004: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0004: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0004: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0004: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Previous diagnosis of alcohol or drug dependence" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtlookbehind ("60,D" ,beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0004: ALCOHOL_DRUG_DEP: F1" ,
    "NQF2019_0004: ALCOHOL_DRUG_DEP: G1" ,
    "NQF2019_0004: ALCOHOL_DRUG_DEP: H1" ) ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    evnt_date = cnvtdatetime (cnvtdate (pat.ep_dt_tm ) ,0 ) ,
    IF ((evnt_date BETWEEN cnvtlookbehind ("60,D" ,cnvtdatetime (lh_ep_reply->persons[person_pos ].
      pop_ep_dt_tm ) ) AND cnvtlookbehind ("1,S" ,cnvtdatetime (lh_ep_reply->persons[person_pos ].
      pop_ep_dt_tm ) ) ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome1_nqf4 (null )
  DECLARE p_iter = i4 WITH protect ,noconstant (0 )
  DECLARE e_iter = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE had_encounter_within_14_days = i4 WITH protect ,noconstant (0 )
  DECLARE num_encounters_within_30_days = i4 WITH protect ,noconstant (0 )
  DECLARE evnt_date = dq8 WITH protect ,noconstant (0 )
  CALL lhprint (";get outcome 1" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0004: AOD_PSYCH_ENC: A2" ,
    "NQF2019_0004: AOD_PSYCH_ENC: B2" ,
    "NQF2019_0004: AOD_PSYCH_ENC: C2" ,
    "NQF2019_0004: AOD_PSYCH_ENC: D2" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id ) ,had_encounter_within_14_days = 0 ,
    num_encounters_within_30_days = 0
   DETAIL
    evnt_date = cnvtdatetime (pat.ep_dt_tm ) ,
    IF ((lh_ep_reply->persons[person_pos ].pop_ep_dt_tm > 0 )
    AND (had_encounter_within_14_days = 0 )
    AND (evnt_date > cnvtdatetime (lh_ep_reply->persons[person_pos ].pop_ep_dt_tm ) )
    AND (evnt_date <= datetimeadd (cnvtdatetime (lh_ep_reply->persons[person_pos ].pop_ep_dt_tm ) ,
     14 ) ) ) had_encounter_within_14_days = 1 ,lh_ep_reply->persons[person_pos ].
     special_cond_a_dt_tm = evnt_date
    ENDIF
    ,
    IF ((evnt_date > cnvtdatetime (lh_ep_reply->persons[person_pos ].special_cond_a_dt_tm ) )
    AND (evnt_date <= datetimeadd (cnvtdatetime (lh_ep_reply->persons[person_pos ].
      special_cond_a_dt_tm ) ,30 ) ) ) num_encounters_within_30_days = (
     num_encounters_within_30_days + 1 )
    ENDIF
   FOOT  pat.person_id
    IF ((had_encounter_within_14_days = 1 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[person_pos ].outcome = "Met, Done" ,lh_ep_reply->persons[person_pos ].
     special_group = num_encounters_within_30_days
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome 1" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome2_nqf4 (null )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get outcome 2" )
  CALL beg_time (0 )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((lh_ep_reply->persons[i ].outcome_ind != 2 ) )
    IF ((lh_ep_reply->persons[i ].special_group < 2 ) )
     SET lh_ep_reply->persons[i ].outcome_ind = 0
     SET lh_ep_reply->persons[i ].outcome = "Not Met, Not Done"
    ENDIF
   ENDIF
  ENDFOR
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome 2" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getagegroup_nqf4 (rec_name ,grp )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO size (rec_name->persons ,5 ) )
   IF ((grp = 1 )
   AND (rec_name->persons[i ].age > 17 ) )
    SET rec_name->persons[i ].exclude_ind = 1
   ELSEIF ((grp = 2 )
   AND (rec_name->persons[i ].age < 18 ) )
    SET rec_name->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
 END ;Subroutine
 DECLARE getresults_nqf18 (null ) = null
 DECLARE getpopulation_nqf18 (null ) = null
 DECLARE getattribution_nqf18 (null ) = null
 DECLARE getexclusion_nqf18 (null ) = null
 DECLARE getoutcome_nqf18 (null ) = null
 DECLARE active_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,12030 ,"ACTIVE" ) )
 SUBROUTINE  getpopulation_nqf18 (null )
  DECLARE num = i4 WITH protect ,noconstant (0 )
  DECLARE personcnt = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE month_check_flg = i2 WITH protect ,noconstant (0 )
  DECLARE batch_size = i4 WITH protect ,constant (5000 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("POPULATION: NQF2019_0018: A1" ,
    "POPULATION: NQF2019_0018: B1" ,
    "POPULATION: NQF2019_0018: C1" ,
    "POPULATION: NQF2019_0018: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (p.active_ind = 1 )
    AND parser (logical_domain_id_parser )
    AND (p.birth_dt_tm <= cnvtlookbehind ("18,Y" ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.birth_dt_tm > cnvtlookbehind ("85,Y" ,cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.reg_dt_tm DESC ,
    pop.encntr_id
   HEAD REPORT
    stat = alterlist (lh_ep_reply->persons ,20000 )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,encntrcnt = 0 ,
    IF ((size (lh_ep_reply->persons ,5 ) < personcnt ) ) stat = alterlist (lh_ep_reply->persons ,(
      size (lh_ep_reply->persons ,5 ) + batch_size ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].
    exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt
   HEAD pop.reg_dt_tm
    dummy = 0
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    lh_ep_reply->person_cnt = personcnt ,
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Hypertension Problem and Diagnosis" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (num ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[num ].
     person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0018: HYPERTENSION: F1" ,
    "NQF2019_0018: HYPERTENSION: G1" ,
    "NQF2019_0018: HYPERTENSION: H1" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    pcnt = 0
   HEAD pat.person_id
    person_ind = 0 ,month_check_flg = 0 ,pos = locatevalsort (iter1 ,1 ,size (lh_ep_reply->persons ,
      5 ) ,pat.person_id ,lh_ep_reply->persons[iter1 ].person_id ) ,
    IF ((pos > 0 ) ) pcnt = (pcnt + 1 ) ,hyper_date->person_cnt = pcnt ,stat = alterlist (hyper_date
      ->persons ,pcnt ) ,hyper_date->persons[pcnt ].person_id = pat.person_id ,person_ind = 1 ,
     hyp_cnt = 0
    ENDIF
   DETAIL
    IF ((qry.query_name = "NQF2019_0018: HYPERTENSION: H1" ) )
     IF ((month_check_flg = 0 ) )
      IF ((pat.ep_dt_tm >= cnvtdatetime (beg_extract_dt_tm ) ) )
       IF ((lhgetdatetimedifference (pat.ep_dt_tm ,cnvtdatetime (beg_extract_dt_tm ) ,"MO" ) <= 6 )
       ) month_check_flg = 1
       ENDIF
      ELSE
       IF ((checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.ep_end_dt_tm ) = 1 ) ) month_check_flg
        = 1
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF ((month_check_flg = 0 )
     AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) ) )
      IF ((pat.ep_dt_tm >= cnvtdatetime (beg_extract_dt_tm ) ) )
       IF ((lhgetdatetimedifference (pat.ep_dt_tm ,cnvtdatetime (beg_extract_dt_tm ) ,"MO" ) <= 6 )
       ) month_check_flg = 1
       ENDIF
      ELSE
       IF ((diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) )
        month_check_flg = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    ,
    IF ((month_check_flg = 1 )
    AND (person_ind > 0 ) ) person_ind = 2 ,hyp_cnt = (hyp_cnt + 1 ) ,hyper_date->persons[pcnt ].
     date_cnt = hyp_cnt ,stat = alterlist (hyper_date->persons[pcnt ].dates ,hyp_cnt ) ,hyper_date->
     persons[pcnt ].dates[hyp_cnt ].hyper_ep_date = pat.ep_dt_tm ,hyper_date->persons[pcnt ].dates[
     hyp_cnt ].hyper_ep_end_date = pat.ep_end_dt_tm ,month_check_flg = 0
    ENDIF
   FOOT  pat.person_id
    IF ((person_ind = 2 )
    AND (pos > 0 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->persons[pos ].
     outcome_ind = 0 ,lh_ep_reply->persons[pos ].outcome = "Not Met, Not Done"
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,expand = 1 ,orahint ("index(pat XIE02lh_amb_event_data_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Hypertension diagnosis population results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf18 (null )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE out_flg = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";Exclude patients" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (num ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[num ].
    person_id )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0018: DEN_EX_PROB: F2" ,
   "NQF2019_0018: DEN_EX_PROB: G2" ,
   "NQF2019_0018: DEN_EX_PROC: A3" ,
   "NQF2019_0018: DEN_EX_PROC: B3" ,
   "NQF2019_0018: DEN_EX_PROC: C3" ,
   "NQF2019_0018: DEN_EX_PROC: D3" ,
   "NQF2019_0018: DEN_EX_ENC: A5" ,
   "NQF2019_0018: DEN_EX_ENC: B5" ,
   "NQF2019_0018: DEN_EX_ENC: C5" ,
   "NQF2019_0018: DEN_EX_ENC: D5" ,
   "NQF2019_0018: HOSPICE_CARE_AMB: A2" ,
   "NQF2019_0018: HOSPICE_CARE_AMB: D2" ,
   "NQF2019_0018: HOSPICE_CARE_AMB: D3" ,
   "NQF2019_0018: HOSPICE_CARE_AMB: E3" ,
   "NQF2019_0018: DISCH_HOME_HOSPIC_CARE: R1" ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    out_flg = 0 ,pos = locatevalsort (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter1 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (out_flg = 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     CASE (qry.query_name )
      OF "NQF2019_0018: DEN_EX_PROB: F2" :
      OF "NQF2019_0018: DEN_EX_PROB: G2" :
       IF ((diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) out_flg =
        1
       ENDIF
      OF "NQF2019_0018: DISCH_HOME_HOSPIC_CARE: R1" :
       IF ((pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
        end_extract_dt_tm ) ) ) out_flg = 1
       ENDIF
      OF "NQF2019_0018: HOSPICE_CARE_AMB: A2" :
      OF "NQF2019_0018: HOSPICE_CARE_AMB: D2" :
       IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
        end_extract_dt_tm ) ) ) out_flg = 1
       ENDIF
      OF "NQF2019_0018: HOSPICE_CARE_AMB: D3" :
      OF "NQF2019_0018: HOSPICE_CARE_AMB: E3" :
       IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null
       ) )) ) out_flg = 1
       ENDIF
      ELSE out_flg = 1
     ENDCASE
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].
     outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE02lh_amb_event_data_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Exclude patients (Prob)" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (num ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[num ].
    person_id )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.active_ind = 1 )
   AND (qry.query_name = "NQF2019_0018: DEN_EX_PROB: H2" )
   AND (pat.ep_end_dt_tm >= cnvtdatetime (beg_extract_dt_tm ) )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.prob_life_cycle_status_cd = active_cd )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locatevalsort (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter1 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE02lh_amb_event_data_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Exclude patients results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf18 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0018" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0018" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0018" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0018" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0018" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0018_2019" ,br_filters->provider_attribution ,"NQF2019_0018" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf18 (null )
  DECLARE systolic_limit = i4 WITH constant (140 ) ,protect
  DECLARE diastolic_limit = i4 WITH constant (90 ) ,protect
  DECLARE bp_done = i4 WITH noconstant (- (1 ) ) ,protect
  DECLARE bp_met = i4 WITH noconstant (0 ) ,protect
  DECLARE sys_val = i4 WITH noconstant (0 ) ,protect
  DECLARE dia_val = i4 WITH noconstant (0 ) ,protect
  DECLARE sys_done = i4 WITH noconstant (0 ) ,protect
  DECLARE dia_done = i4 WITH noconstant (0 ) ,protect
  DECLARE adult_op_vis_ind = i4 WITH noconstant (0 ) ,protect
  DECLARE adult_op_bp = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE iter2 = i4 WITH protect ,noconstant (0 )
  DECLARE iter3 = i4 WITH protect ,noconstant (0 )
  DECLARE date_iter = i4 WITH protect ,noconstant (0 )
  DECLARE aop_iter = i4 WITH protect ,noconstant (0 )
  DECLARE opv_pos = i4 WITH protect ,noconstant (0 )
  DECLARE sys_bp_dt_tm = dq8 WITH noconstant (0 ) ,protect
  DECLARE dia_bp_dt_tm = dq8 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry ),
    (dummyt d WITH seq = lh_ep_reply->person_cnt )
   PLAN (d
    WHERE (lh_ep_reply->person_cnt > 0 )
    AND (lh_ep_reply->persons[d.seq ].ep_ind = 1 )
    AND (lh_ep_reply->persons[d.seq ].outcome_ind = 0 ) )
    JOIN (pat
    WHERE (pat.person_id = lh_ep_reply->persons[d.seq ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0018: SYSTOLIC: E6" ,
    "NQF2019_0018: DIASTOLIC: E6" ,
    "NQF2019_0018: ADULT_OP_VISIT: A6" ,
    "NQF2019_0018: ADULT_OP_VISIT: B6" ,
    "NQF2019_0018: ADULT_OP_VISIT: C6" ,
    "NQF2019_0018: ADULT_OP_VISIT: D6" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0 ,
    pcnt = 0 ,
    opv_pos = 0
   HEAD pat.person_id
    bp_met = 0 ,adult_op_vis_ind = 0 ,adult_op_bp = 0 ,stat = initrec (systolic_bps ) ,stat =
    initrec (diastolic_bps ) ,person_pos = locateval (iter2 ,1 ,size (hyper_date->persons ,5 ) ,pat
     .person_id ,hyper_date->persons[iter2 ].person_id ) ,pcnt = (pcnt + 1 ) ,adult_opv_date->
    person_cnt = pcnt ,stat = alterlist (adult_opv_date->persons ,pcnt ) ,adult_opv_date->persons[
    pcnt ].person_id = pat.person_id ,aop_cnt = 0
   DETAIL
    IF ((isnumeric (pat.ce_result_val ) > 0 )
    AND (pat.ce_result_val != null )
    AND (pat.ce_result_val != " " ) )
     IF ((qry.query_name = "NQF2019_0018: SYSTOLIC: E6" ) ) sys_done = 1 ,sys_count = (systolic_bps->
      sys_cnt + 1 ) ,systolic_bps->sys_cnt = sys_count ,stat = alterlist (systolic_bps->systolics ,
       sys_count ) ,systolic_bps->systolics[sys_count ].bp_date = cnvtdatetime (pat.ep_dt_tm ) ,
      systolic_bps->systolics[sys_count ].result_val = cnvtreal (pat.ce_result_val )
     ELSEIF ((qry.query_name = "NQF2019_0018: DIASTOLIC: E6" ) ) dia_done = 1 ,dia_count = (
      diastolic_bps->dia_cnt + 1 ) ,diastolic_bps->dia_cnt = dia_count ,stat = alterlist (
       diastolic_bps->diastolics ,dia_count ) ,diastolic_bps->diastolics[dia_count ].bp_date =
      cnvtdatetime (pat.ep_dt_tm ) ,diastolic_bps->diastolics[dia_count ].result_val = cnvtreal (pat
       .ce_result_val )
     ENDIF
    ENDIF
    ,
    IF ((qry.query_name IN ("NQF2019_0018: ADULT_OP_VISIT: A6" ,
    "NQF2019_0018: ADULT_OP_VISIT: B6" ,
    "NQF2019_0018: ADULT_OP_VISIT: C6" ,
    "NQF2019_0018: ADULT_OP_VISIT: D6" ) ) )
     IF ((person_pos > 0 ) ) opv_pos = locateval (iter3 ,1 ,size (adult_opv_date->persons[pcnt ].
        dates ,5 ) ,pat.ep_dt_tm ,cnvtdatetime (adult_opv_date->persons[pcnt ].dates[iter3 ].
        adult_op_ep_date ) ) ,
      IF ((hyper_date->persons[person_pos ].date_cnt > 0 ) )
       FOR (date_iter = 1 TO hyper_date->persons[person_pos ].date_cnt )
        IF ((((adult_op_vis_ind = 0 ) ) OR ((adult_op_vis_ind = 1 )
        AND (size (adult_opv_date->persons[pcnt ].dates ,5 ) > 0 ) ))
        AND (cnvtdatetime (hyper_date->persons[person_pos ].dates[date_iter ].hyper_ep_date ) <= pat
        .ep_end_dt_tm )
        AND (((cnvtdatetime (hyper_date->persons[person_pos ].dates[date_iter ].hyper_ep_end_date )
        >= pat.ep_dt_tm ) ) OR ((hyper_date->persons[person_pos ].dates[date_iter ].hyper_ep_end_date
         = null ) )) ) adult_op_vis_ind = 1 ,
         IF ((opv_pos = 0 ) ) aop_cnt = (aop_cnt + 1 ) ,adult_opv_date->persons[pcnt ].date_cnt =
          aop_cnt ,stat = alterlist (adult_opv_date->persons[pcnt ].dates ,aop_cnt ) ,adult_opv_date
          ->persons[pcnt ].dates[aop_cnt ].adult_op_ep_date = pat.ep_dt_tm ,adult_opv_date->persons[
          pcnt ].dates[aop_cnt ].adult_op_end_date = pat.ep_end_dt_tm
         ENDIF
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    bp_met = checkbloodpressures (pcnt ) ,
    IF ((adult_op_vis_ind = 1 )
    AND (bp_met = 1 ) ) lh_ep_reply->persons[d.seq ].outcome_ind = 0 ,lh_ep_reply->persons[d.seq ].
     outcome = "Not Met, Not Controlled"
    ELSEIF ((adult_op_vis_ind = 1 )
    AND (bp_met = 2 ) ) lh_ep_reply->persons[d.seq ].outcome_ind = 1 ,lh_ep_reply->persons[d.seq ].
     outcome = "Met, Controlled"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01lh_amb_event_data_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  checkbloodpressures (opvpatpos )
  DECLARE earliestdate = dq8 WITH noconstant (0 ) ,protect
  DECLARE returnval = i4 WITH noconstant (0 ) ,protect
  FOR (i = 1 TO size (adult_opv_date->persons[opvpatpos ].dates ,5 ) )
   SET opstart = cnvtdatetime (adult_opv_date->persons[opvpatpos ].dates[i ].adult_op_ep_date )
   SET opend = cnvtdatetime (adult_opv_date->persons[opvpatpos ].dates[i ].adult_op_end_date )
   SET sysdone = 0
   SET sysmet = 0
   SET diadone = 0
   SET diamet = 0
   FOR (j = 1 TO size (systolic_bps->systolics ,5 ) )
    IF ((systolic_bps->systolics[j ].bp_date BETWEEN opstart AND opend ) )
     SET sysdone = 1
     IF ((systolic_bps->systolics[j ].result_val < systolic_limit ) )
      SET sysmet = 1
     ENDIF
    ENDIF
   ENDFOR
   FOR (k = 1 TO size (diastolic_bps->diastolics ,5 ) )
    IF ((diastolic_bps->diastolics[k ].bp_date BETWEEN opstart AND opend ) )
     SET diadone = 1
     IF ((diastolic_bps->diastolics[k ].result_val < diastolic_limit ) )
      SET diamet = 1
     ENDIF
    ENDIF
   ENDFOR
   IF ((sysdone = 1 )
   AND (diadone = 1 ) )
    IF ((opstart > earliestdate ) )
     SET earliestdate = opstart
     IF ((diamet = 1 )
     AND (sysmet = 1 ) )
      SET returnval = 2
     ELSE
      SET returnval = 1
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
  RETURN (returnval )
 END ;Subroutine
 SUBROUTINE  getresults_nqf18 (null )
  IF ((validate (hyper_date ) = 0 ) )
   RECORD hyper_date (
     1 person_cnt = i4
     1 persons [* ]
       2 person_id = f8
       2 date_cnt = i4
       2 dates [* ]
         3 hyper_ep_date = dq8
         3 hyper_ep_end_date = dq8
   ) WITH protect
  ENDIF
  IF ((validate (adult_opv_date ) = 0 ) )
   RECORD adult_opv_date (
     1 person_cnt = i4
     1 persons [* ]
       2 person_id = f8
       2 date_cnt = i4
       2 dates [* ]
         3 adult_op_ep_date = dq8
         3 adult_op_end_date = dq8
   ) WITH protect
  ENDIF
  IF ((validate (systolic_bps ) = 0 ) )
   RECORD systolic_bps (
     1 sys_cnt = i4
     1 systolics [* ]
       2 bp_date = dq8
       2 result_val = f8
   ) WITH protect
  ENDIF
  IF ((validate (diastolic_bps ) = 0 ) )
   RECORD diastolic_bps (
     1 dia_cnt = i4
     1 diastolics [* ]
       2 bp_date = dq8
       2 result_val = f8
   ) WITH protect
  ENDIF
  SET br_filters->provider_attribution = getproviderattribution ("18" )
  CALL geteprfilter ("18" )
  CALL getpopulation_nqf18 (0 )
  CALL getattribution_nqf18 (0 )
  CALL getexclusion_nqf18 (0 )
  CALL getoutcome_nqf18 (0 )
  CALL summaryreport ("MU_EC_0018_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
  SET stat = initrec (hyper_date )
  SET stat = initrec (adult_opv_date )
 END ;Subroutine
 DECLARE getresults_nqf22 (null ) = null
 DECLARE getpopulation_nqf22 (null ) = null
 DECLARE getattribution_nqf22 (null ) = null
 DECLARE getoutcome_nqf22 (null ) = null
 DECLARE getoutcome_nqf22_1 (null ) = null
 DECLARE getoutcome_nqf22_2 (null ) = null
 DECLARE getnqf22_summary (null ) = null
 DECLARE getexclusion_nqf22 (null ) = null
 DECLARE checkpersonid ((providerid = f8 ) ,(personid = f8 ) ,(reportby = vc ) ) = null
 SUBROUTINE  getresults_nqf22 (null )
  SET br_filters->provider_attribution = getproviderattribution ("22" )
  CALL geteprfilter ("22" )
  CALL getproviderids (0 )
  CALL setvalsets4nqf22 (0 )
  CALL getpopulation_nqf22 (0 )
  CALL getattribution_nqf22 (0 )
  CALL getexclusion_nqf22 (0 )
  CALL getoutcome_nqf22 (0 )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
  SET stat = initrec (lh_nqf22_meds )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf22 (null )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  DECLARE personcnt = i4 WITH protect ,noconstant (0 )
  DECLARE encntrcnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query q ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (q
    WHERE (pop.d_query_id = q.d_query_id )
    AND (q.active_ind = 1 )
    AND (q.query_name IN ("POPULATION: NQF2019_0022: A1" ,
    "POPULATION: NQF2019_0022: B1" ,
    "POPULATION: NQF2019_0022: C1" ,
    "POPULATION: NQF2019_0022: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("65,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    encntrcnt = 0 ,personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    stat = alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id
    = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done"
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome
     = "Not Met, Not Done" ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL lhprint (build ("NQF2019_0022 inital patient population query patients:" ,personcnt ) )
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf22 (null )
  CALL getoutcome_nqf22_1 (0 )
  CALL summaryreport ("MU_EC_0022_2019.1" )
  CALL getnqf22_summary (0 )
  CALL getoutcome_nqf22_2 (0 )
  CALL summaryreport ("MU_EC_0022_2019.2" )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf22_1 (null )
  DECLARE start_dt_tm = dq8 WITH protect
  DECLARE stop_dt_tm = dq8 WITH protect
  DECLARE duration_limit = i4 WITH protect ,constant (90 )
  DECLARE med_duration = i4 WITH protect
  DECLARE duration = i4 WITH protect
  DECLARE total_duration = i4 WITH protect
  DECLARE risk_count = i4 WITH protect
  DECLARE iter = i4 WITH protect ,noconstant (0 )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE iter2 = i4 WITH protect ,noconstant (0 )
  DECLARE iter3 = i4 WITH protect ,noconstant (0 )
  DECLARE iter4 = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE cnt = i4 WITH protect ,noconstant (0 )
  DECLARE gpro_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE gpro_id = f8 WITH protect ,noconstant (0 )
  DECLARE duppos = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";getOutcome_NQF22_1 M1" )
  CALL beg_time (0 )
  SET stat = initrec (lh_nqf22_num1 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_cqm_rxnorm_map map ),
    (lh_d_query q )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (pat.primary_vset_cd = map.rxnorm_txt )
   AND (map.category_mean = "MU_CQM_EC_2019" )
   AND (map.value_set_name = "HIGH_RISK_MEDICATIONS_FOR_THE_ELDERLY" )
   AND (pat.d_query_id = q.d_query_id )
   AND (q.active_ind = 1 )
   AND (q.query_name IN ("NQF2019_0022: MEDICATION: M1" ) )
   ORDER BY pat.person_id ,
    pat.last_updated_provider_id
   HEAD pat.person_id
    per_pos = 0
   HEAD pat.last_updated_provider_id
    CALL checkpersonidnum1 (pat.last_updated_provider_id ,pat.person_id ,params->report_by )
   WITH nocounter ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("; getOutcome_NQF22_1 M1" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  IF ((params->report_by = "INDV" ) )
   CALL lhprint (";getOutcome_NQF22_1 M2" )
   CALL beg_time (0 )
   SELECT INTO "nl:"
    FROM (lh_amb_event_data_2019 pat ),
     (lh_d_cqm_rxnorm_map map ),
     (lh_d_query q )
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.last_updated_provider_id > 0 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 )
    AND (pat.primary_vset_cd = map.rxnorm_txt )
    AND (map.category_mean = "MU_CQM_EC_2019" )
    AND (map.value_set_name = "HIGH_RISK_MEDICATIONS_WITH_DAYS_SUPPLY_CRITERIA" )
    AND (pat.d_query_id = q.d_query_id )
    AND (q.active_ind = 1 )
    AND (q.query_name IN ("NQF2019_0022: MEDICATION: M2" ) )
    ORDER BY pat.person_id ,
     pat.last_updated_provider_id ,
     pat.lh_amb_event_data_2019_id
    HEAD pat.person_id
     pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
      persons[iter2 ].person_id )
    HEAD pat.last_updated_provider_id
     prov_pos = locateval (iter3 ,1 ,size (lh_ep_provider_list->eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->eps[iter3 ].provider_id )
    HEAD pat.lh_amb_event_data_2019_id
     IF ((pos > 0 )
     AND (prov_pos > 0 ) ) start_dt_tm = pat.beg_effective_dt_tm ,
      IF ((((pat.end_effective_dt_tm = null ) ) OR ((pat.end_effective_dt_tm = 0 ) )) ) stop_dt_tm =
       cnvtdatetime (end_extract_dt_tm )
      ELSE stop_dt_tm = pat.end_effective_dt_tm
      ENDIF
      ,
      IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 90 ) )
       IF ((size (lh_nqf22_num1->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num1->
          qual ,5 ) ,pat.person_id ,lh_nqf22_num1->qual[iter ].person_id ,lh_ep_provider_list->eps[
         prov_pos ].br_eligible_provider_id ,lh_nqf22_num1->qual[iter ].reporting_id )
       ENDIF
       ,
       IF ((duppos = 0 ) ) cnt = (size (lh_nqf22_num1->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num1->qual ,cnt ) ,lh_nqf22_num1->qual[cnt ].person_id = pat.person_id ,
        lh_nqf22_num1->qual[cnt ].reporting_id = lh_ep_provider_list->eps[prov_pos ].
        br_eligible_provider_id
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
   ;end select
   CALL end_time (0 )
  ELSEIF ((params->report_by = "GPRO" ) )
   FOR (iloop = 1 TO size (lh_ep_provider_list->gpros ,5 ) )
    CALL lhprint (";getOutcome_NQF22_1 M2" )
    CALL beg_time (0 )
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND expand (iter2 ,1 ,size (lh_ep_provider_list->gpros[iloop ].eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->gpros[iloop ].eps[iter2 ].provider_id )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND (map.value_set_name = "HIGH_RISK_MEDICATIONS_WITH_DAYS_SUPPLY_CRITERIA" )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: MEDICATION: M2" ) )
     ORDER BY pat.person_id ,
      pat.last_updated_provider_id ,
      pat.lh_amb_event_data_2019_id
     HEAD pat.person_id
      pos1 = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
       persons[iter2 ].person_id )
     HEAD pat.last_updated_provider_id
      prov_pos1 = locateval (iter4 ,1 ,size (lh_ep_provider_list->gpros[iloop ].eps ,5 ) ,pat
       .last_updated_provider_id ,lh_ep_provider_list->gpros[iloop ].eps[iter4 ].provider_id )
     HEAD pat.lh_amb_event_data_2019_id
      IF ((size (lh_nqf22_num1->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num1->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num1->qual[iter ].person_id ,lh_ep_provider_list->gpros[
        iloop ].br_gpro_id ,lh_nqf22_num1->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((pos1 > 0 )
       AND (prov_pos1 > 0 ) ) start_dt_tm = pat.beg_effective_dt_tm ,
        IF ((((pat.end_effective_dt_tm = null ) ) OR ((pat.end_effective_dt_tm = 0 ) )) ) stop_dt_tm
         = cnvtdatetime (end_extract_dt_tm )
        ELSE stop_dt_tm = pat.end_effective_dt_tm
        ENDIF
        ,
        IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 90 ) ) cnt = (size (
          lh_nqf22_num1->qual ,5 ) + 1 ) ,stat = alterlist (lh_nqf22_num1->qual ,cnt ) ,lh_nqf22_num1
         ->qual[cnt ].person_id = pat.person_id ,lh_nqf22_num1->qual[cnt ].reporting_id =
         lh_ep_provider_list->gpros[iloop ].br_gpro_id
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
    ;end select
    CALL end_time (0 )
   ENDFOR
  ELSE
   FOR (iloop = 1 TO size (lh_ep_provider_list->cpcs ,5 ) )
    CALL lhprint (";getOutcome_NQF22_1 M2" )
    CALL beg_time (0 )
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND expand (iter2 ,1 ,size (lh_ep_provider_list->cpcs[iloop ].eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->cpcs[iloop ].eps[iter2 ].provider_id )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND (map.value_set_name = "HIGH_RISK_MEDICATIONS_WITH_DAYS_SUPPLY_CRITERIA" )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: MEDICATION: M2" ) )
     ORDER BY pat.person_id ,
      pat.last_updated_provider_id ,
      pat.lh_amb_event_data_2019_id
     HEAD pat.person_id
      pos1 = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
       persons[iter2 ].person_id )
     HEAD pat.last_updated_provider_id
      prov_pos1 = locateval (iter4 ,1 ,size (lh_ep_provider_list->cpcs[iloop ].eps ,5 ) ,pat
       .last_updated_provider_id ,lh_ep_provider_list->cpcs[iloop ].eps[iter4 ].provider_id )
     HEAD pat.lh_amb_event_data_2019_id
      IF ((size (lh_nqf22_num1->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num1->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num1->qual[iter ].person_id ,lh_ep_provider_list->cpcs[
        iloop ].br_cpc_id ,lh_nqf22_num1->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((pos1 > 0 )
       AND (prov_pos1 > 0 ) ) start_dt_tm = pat.beg_effective_dt_tm ,
        IF ((((pat.end_effective_dt_tm = null ) ) OR ((pat.end_effective_dt_tm = 0 ) )) ) stop_dt_tm
         = cnvtdatetime (end_extract_dt_tm )
        ELSE stop_dt_tm = pat.end_effective_dt_tm
        ENDIF
        ,
        IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 90 ) ) cnt = (size (
          lh_nqf22_num1->qual ,5 ) + 1 ) ,stat = alterlist (lh_nqf22_num1->qual ,cnt ) ,lh_nqf22_num1
         ->qual[cnt ].person_id = pat.person_id ,lh_nqf22_num1->qual[cnt ].reporting_id =
         lh_ep_provider_list->cpcs[iloop ].br_cpc_id
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
    ;end select
    CALL end_time (0 )
   ENDFOR
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echo ("; getOutcome_NQF22_1 M2" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf22_2 (null )
  DECLARE query_i = i4 WITH protect ,noconstant (0 )
  DECLARE iter = i4 WITH protect ,noconstant (0 )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE iter2 = i4 WITH protect ,noconstant (0 )
  DECLARE iter3 = i4 WITH protect ,noconstant (0 )
  DECLARE iter4 = i4 WITH protect ,noconstant (0 )
  DECLARE iter5 = i4 WITH protect ,noconstant (0 )
  DECLARE iter6 = i4 WITH protect ,noconstant (0 )
  DECLARE start_dt_tm = dq8 WITH protect
  DECLARE stop_dt_tm = dq8 WITH protect
  DECLARE duration_limit = i4 WITH protect ,constant (90 )
  DECLARE med_duration = i4 WITH protect ,noconstant (0 )
  DECLARE total_duration = i4 WITH protect ,noconstant (0 )
  DECLARE high_risk_duration_met = i4 WITH protect ,noconstant (0 )
  DECLARE high_risk_met = i4 WITH protect ,noconstant (0 )
  DECLARE iloop = i4 WITH protect ,noconstant (0 )
  IF ((params->report_by = "INDV" ) )
   FOR (iloop = 1 TO size (lh_ep_provider_list->eps ,5 ) )
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND (pat.last_updated_provider_id > 0 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND (pat.last_updated_provider_id = lh_ep_provider_list->eps[iloop ].provider_id )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND expand (iter4 ,1 ,size (lh_nqf22_meds->queries ,5 ) ,q.query_name ,lh_nqf22_meds->queries[
      iter4 ].query_name ,map.value_set_name ,lh_nqf22_meds->queries[iter4 ].val_set_name )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION:*" ) )
     AND NOT ((q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION: M109" ,
     "NQF2019_0022: HIGH_RISK_MEDICATION: M110" ) ) )
     ORDER BY pat.person_id ,
      q.query_name ,
      pat.beg_effective_dt_tm
     HEAD pat.person_id
      pos = 0
     HEAD q.query_name
      qcount = 0 ,processedfirst = 0
     HEAD pat.beg_effective_dt_tm
      IF ((processedfirst = 1 ) ) stop_dt_tm = pat.beg_effective_dt_tm ,
       IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 1 )
       AND (qcount < 2 ) ) qcount = (qcount + 1 )
       ENDIF
      ENDIF
      ,
      IF ((processedfirst = 0 ) ) start_dt_tm = pat.end_effective_dt_tm ,qcount = 1 ,processedfirst
       = 1
      ENDIF
     FOOT  q.query_name
      IF ((size (lh_nqf22_num2->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num2->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num2->qual[iter ].person_id ,lh_ep_provider_list->eps[
        iloop ].br_eligible_provider_id ,lh_nqf22_num2->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((qcount = 2 ) ) size = (size (lh_nqf22_num2->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num2->qual ,size ) ,lh_nqf22_num2->qual[size ].reporting_id = lh_ep_provider_list->
        eps[iloop ].br_eligible_provider_id ,lh_nqf22_num2->qual[size ].person_id = pat.person_id
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND (pat.last_updated_provider_id > 0 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND (pat.last_updated_provider_id = lh_ep_provider_list->eps[iloop ].provider_id )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND expand (iter4 ,1 ,size (lh_nqf22_meds->queries ,5 ) ,q.query_name ,lh_nqf22_meds->queries[
      iter4 ].query_name ,map.value_set_name ,lh_nqf22_meds->queries[iter4 ].val_set_name )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION: M109" ,
     "NQF2019_0022: HIGH_RISK_MEDICATION: M110" ) )
     ORDER BY pat.person_id ,
      q.query_name ,
      pat.beg_effective_dt_tm
     HEAD pat.person_id
      pos = 0
     HEAD q.query_name
      qcount = 0 ,processedfirst = 0 ,totaltime = 0
     HEAD pat.beg_effective_dt_tm
      IF ((processedfirst = 1 ) ) totaltime = (totaltime + lhgetdatetimedifference (pat
        .end_effective_dt_tm ,pat.beg_effective_dt_tm ,"D" ) ) ,stop_dt_tm = pat.ep_dt_tm ,
       IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 1 )
       AND (qcount < 2 ) ) qcount = (qcount + 1 )
       ENDIF
      ENDIF
      ,
      IF ((processedfirst = 0 ) ) start_dt_tm = pat.end_effective_dt_tm ,totaltime = (totaltime +
       lhgetdatetimedifference (pat.end_effective_dt_tm ,pat.beg_effective_dt_tm ,"D" ) ) ,qcount =
       1 ,processedfirst = 1
      ENDIF
     FOOT  q.query_name
      IF ((size (lh_nqf22_num2->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num2->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num2->qual[iter ].person_id ,lh_ep_provider_list->eps[
        iloop ].br_eligible_provider_id ,lh_nqf22_num2->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((qcount = 2 )
       AND (totaltime >= 90 ) ) size = (size (lh_nqf22_num2->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num2->qual ,size ) ,lh_nqf22_num2->qual[size ].reporting_id = lh_ep_provider_list->
        eps[iloop ].br_eligible_provider_id ,lh_nqf22_num2->qual[size ].person_id = pat.person_id
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
   ENDFOR
  ELSEIF ((params->report_by = "GPRO" ) )
   FOR (iloop = 1 TO size (lh_ep_provider_list->gpros ,5 ) )
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND (pat.last_updated_provider_id > 0 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND expand (iter2 ,1 ,size (lh_ep_provider_list->gpros[iloop ].eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->gpros[iloop ].eps[iter2 ].provider_id )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND expand (iter4 ,1 ,size (lh_nqf22_meds->queries ,5 ) ,q.query_name ,lh_nqf22_meds->queries[
      iter4 ].query_name ,map.value_set_name ,lh_nqf22_meds->queries[iter4 ].val_set_name )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION:*" ) )
     AND NOT ((q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION: M109" ,
     "NQF2019_0022: HIGH_RISK_MEDICATION: M110" ) ) )
     ORDER BY pat.person_id ,
      q.query_name ,
      pat.beg_effective_dt_tm
     HEAD pat.person_id
      pos = 0
     HEAD q.query_name
      qcount = 0 ,processedfirst = 0
     HEAD pat.beg_effective_dt_tm
      IF ((processedfirst = 1 ) ) stop_dt_tm = pat.beg_effective_dt_tm ,
       IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 1 )
       AND (qcount < 2 ) ) qcount = (qcount + 1 )
       ENDIF
      ENDIF
      ,
      IF ((processedfirst = 0 ) ) start_dt_tm = pat.end_effective_dt_tm ,qcount = 1 ,processedfirst
       = 1
      ENDIF
     FOOT  q.query_name
      IF ((size (lh_nqf22_num2->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num2->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num2->qual[iter ].person_id ,lh_ep_provider_list->gpros[
        iloop ].br_gpro_id ,lh_nqf22_num2->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((qcount = 2 ) ) size = (size (lh_nqf22_num2->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num2->qual ,size ) ,lh_nqf22_num2->qual[size ].reporting_id = lh_ep_provider_list->
        gpros[iloop ].br_gpro_id ,lh_nqf22_num2->qual[size ].person_id = pat.person_id
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND (pat.last_updated_provider_id > 0 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND expand (iter6 ,1 ,size (lh_ep_provider_list->gpros[iloop ].eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->gpros[iloop ].eps[iter6 ].provider_id )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND expand (iter4 ,1 ,size (lh_nqf22_meds->queries ,5 ) ,q.query_name ,lh_nqf22_meds->queries[
      iter4 ].query_name ,map.value_set_name ,lh_nqf22_meds->queries[iter4 ].val_set_name )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION: M109" ,
     "NQF2019_0022: HIGH_RISK_MEDICATION: M110" ) )
     ORDER BY pat.person_id ,
      q.query_name ,
      pat.beg_effective_dt_tm
     HEAD pat.person_id
      pos = 0
     HEAD q.query_name
      qcount = 0 ,processedfirst = 0 ,totaltime = 0
     HEAD pat.beg_effective_dt_tm
      IF ((processedfirst = 1 ) ) totaltime = (totaltime + lhgetdatetimedifference (pat
        .end_effective_dt_tm ,pat.beg_effective_dt_tm ,"D" ) ) ,stop_dt_tm = pat.ep_dt_tm ,
       IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 1 )
       AND (qcount < 2 ) ) qcount = (qcount + 1 )
       ENDIF
      ENDIF
      ,
      IF ((processedfirst = 0 ) ) start_dt_tm = pat.end_effective_dt_tm ,totaltime = (totaltime +
       lhgetdatetimedifference (pat.end_effective_dt_tm ,pat.beg_effective_dt_tm ,"D" ) ) ,qcount =
       1 ,processedfirst = 1
      ENDIF
     FOOT  q.query_name
      IF ((size (lh_nqf22_num2->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num2->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num2->qual[iter ].person_id ,lh_ep_provider_list->gpros[
        iloop ].br_gpro_id ,lh_nqf22_num2->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((qcount = 2 )
       AND (totaltime >= 90 ) ) size = (size (lh_nqf22_num2->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num2->qual ,size ) ,lh_nqf22_num2->qual[size ].reporting_id = lh_ep_provider_list->
        gpros[iloop ].br_gpro_id ,lh_nqf22_num2->qual[size ].person_id = pat.person_id
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
   ENDFOR
  ELSE
   FOR (iloop = 1 TO size (lh_ep_provider_list->cpcs ,5 ) )
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND (pat.last_updated_provider_id > 0 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND expand (iter2 ,1 ,size (lh_ep_provider_list->cpcs[iloop ].eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->cpcs[iloop ].eps[iter2 ].provider_id )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND expand (iter4 ,1 ,size (lh_nqf22_meds->queries ,5 ) ,q.query_name ,lh_nqf22_meds->queries[
      iter4 ].query_name ,map.value_set_name ,lh_nqf22_meds->queries[iter4 ].val_set_name )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION:*" ) )
     AND NOT ((q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION: M109" ,
     "NQF2019_0022: HIGH_RISK_MEDICATION: M110" ) ) )
     ORDER BY pat.person_id ,
      q.query_name ,
      pat.beg_effective_dt_tm
     HEAD pat.person_id
      pos = 0
     HEAD q.query_name
      qcount = 0 ,processedfirst = 0
     HEAD pat.beg_effective_dt_tm
      IF ((processedfirst = 1 ) ) stop_dt_tm = pat.beg_effective_dt_tm ,
       IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 1 )
       AND (qcount < 2 ) ) qcount = (qcount + 1 )
       ENDIF
      ENDIF
      ,
      IF ((processedfirst = 0 ) ) start_dt_tm = pat.end_effective_dt_tm ,qcount = 1 ,processedfirst
       = 1
      ENDIF
     FOOT  q.query_name
      IF ((size (lh_nqf22_num2->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num2->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num2->qual[iter ].person_id ,lh_ep_provider_list->cpcs[
        iloop ].br_cpc_id ,lh_nqf22_num2->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((qcount = 2 ) ) size = (size (lh_nqf22_num2->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num2->qual ,size ) ,lh_nqf22_num2->qual[size ].reporting_id = lh_ep_provider_list->
        cpcs[iloop ].br_cpc_id ,lh_nqf22_num2->qual[size ].person_id = pat.person_id
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
    SELECT INTO "nl:"
     FROM (lh_amb_event_data_2019 pat ),
      (lh_d_cqm_rxnorm_map map ),
      (lh_d_query q )
     WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
      iter1 ].person_id )
     AND (pat.last_updated_provider_id > 0 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (pat.active_ind = 1 )
     AND expand (iter6 ,1 ,size (lh_ep_provider_list->cpcs[iloop ].eps ,5 ) ,pat
      .last_updated_provider_id ,lh_ep_provider_list->cpcs[iloop ].eps[iter6 ].provider_id )
     AND (pat.primary_vset_cd = map.rxnorm_txt )
     AND (map.category_mean = "MU_CQM_EC_2019" )
     AND expand (iter4 ,1 ,size (lh_nqf22_meds->queries ,5 ) ,q.query_name ,lh_nqf22_meds->queries[
      iter4 ].query_name ,map.value_set_name ,lh_nqf22_meds->queries[iter4 ].val_set_name )
     AND (pat.d_query_id = q.d_query_id )
     AND (q.active_ind = 1 )
     AND (q.query_name IN ("NQF2019_0022: HIGH_RISK_MEDICATION: M109" ,
     "NQF2019_0022: HIGH_RISK_MEDICATION: M110" ) )
     ORDER BY pat.person_id ,
      q.query_name ,
      pat.beg_effective_dt_tm
     HEAD pat.person_id
      pos = 0
     HEAD q.query_name
      qcount = 0 ,processedfirst = 0 ,totaltime = 0
     HEAD pat.beg_effective_dt_tm
      IF ((processedfirst = 1 ) ) totaltime = (totaltime + lhgetdatetimedifference (pat
        .end_effective_dt_tm ,pat.beg_effective_dt_tm ,"D" ) ) ,stop_dt_tm = pat.ep_dt_tm ,
       IF ((lhgetdatetimedifference (stop_dt_tm ,start_dt_tm ,"D" ) >= 1 )
       AND (qcount < 2 ) ) qcount = (qcount + 1 )
       ENDIF
      ENDIF
      ,
      IF ((processedfirst = 0 ) ) start_dt_tm = pat.end_effective_dt_tm ,totaltime = (totaltime +
       lhgetdatetimedifference (pat.end_effective_dt_tm ,pat.beg_effective_dt_tm ,"D" ) ) ,qcount =
       1 ,processedfirst = 1
      ENDIF
     FOOT  q.query_name
      IF ((size (lh_nqf22_num2->qual ,5 ) > 0 ) ) duppos = locateval (iter ,1 ,size (lh_nqf22_num2->
         qual ,5 ) ,pat.person_id ,lh_nqf22_num2->qual[iter ].person_id ,lh_ep_provider_list->cpcs[
        iloop ].br_cpc_id ,lh_nqf22_num2->qual[iter ].reporting_id )
      ENDIF
      ,
      IF ((duppos = 0 ) )
       IF ((qcount = 2 )
       AND (totaltime >= 90 ) ) size = (size (lh_nqf22_num2->qual ,5 ) + 1 ) ,stat = alterlist (
         lh_nqf22_num2->qual ,size ) ,lh_nqf22_num2->qual[size ].reporting_id = lh_ep_provider_list->
        cpcs[iloop ].br_cpc_id ,lh_nqf22_num2->qual[size ].person_id = pat.person_id
       ENDIF
      ENDIF
     WITH nocounter ,expand = 1
    ;end select
   ENDFOR
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echo ("; getOutcome_NQF22_2" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf22 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0022" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0022" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SER_NURSE_FAC_ENC" ,"0022" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0022" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0022" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0022" ,"'CPT4','HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0022" ,"'CPT4','HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("OPHTHALMOLOGIC_OUTP_VISIT" ,"0022" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0022" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0022_2019.1" ,br_filters->provider_attribution ,"NQF2019_0022" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getnqf22_summary (null )
  DECLARE newpos = i4 WITH protect ,noconstant (ep_summary->ep_cnt )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";Copy EP_SUMMARY submeasure 1 patients to submeasure 2" )
  CALL beg_time (0 )
  FOR (ep = 1 TO ep_summary->ep_cnt )
   IF ((ep_summary->eps[ep ].reportmean = "MU_EC_0022_2019.1" ) )
    SET newpos = (newpos + 1 )
    SET stat = alterlist (ep_summary->eps ,newpos )
    SET ep_summary->eps[newpos ].br_eligible_provider_id = ep_summary->eps[ep ].
    br_eligible_provider_id
    SET ep_summary->eps[newpos ].provider_id = ep_summary->eps[ep ].provider_id
    SET ep_summary->eps[newpos ].name = ep_summary->eps[ep ].name
    SET ep_summary->eps[newpos ].tax_id_nbr_txt = ep_summary->eps[ep ].tax_id_nbr_txt
    SET ep_summary->eps[newpos ].gpro_name = ep_summary->eps[ep ].gpro_name
    SET ep_summary->eps[newpos ].npi_nbr_txt = ep_summary->eps[ep ].npi_nbr_txt
    SET ep_summary->eps[newpos ].npi_nbr_txt = ep_summary->eps[ep ].npi_nbr_txt
    SET ep_summary->eps[newpos ].reportmean = "MU_EC_0022_2019.2"
    SET ep_summary->eps[newpos ].patient_cnt = ep_summary->eps[ep ].patient_cnt
    SET stat = alterlist (ep_summary->eps[newpos ].patients ,ep_summary->eps[ep ].patient_cnt )
    FOR (i = 1 TO ep_summary->eps[ep ].patient_cnt )
     SET ep_summary->eps[newpos ].patients[i ].person_id = ep_summary->eps[ep ].patients[i ].
     person_id
     SET ep_summary->eps[newpos ].patients[i ].name = ep_summary->eps[ep ].patients[i ].name
     SET ep_summary->eps[newpos ].patients[i ].mrn = ep_summary->eps[ep ].patients[i ].mrn
     SET ep_summary->eps[newpos ].patients[i ].birth_date = ep_summary->eps[ep ].patients[i ].
     birth_date
     SET ep_summary->eps[newpos ].patients[i ].outcome = ep_summary->eps[ep ].patients[i ].outcome
     SET ep_summary->eps[newpos ].patients[i ].outcome_ind = ep_summary->eps[ep ].patients[i ].
     outcome_ind
     SET ep_summary->eps[newpos ].patients[i ].outcome_numeric = ep_summary->eps[ep ].patients[i ].
     outcome_numeric
     SET ep_summary->eps[newpos ].patients[i ].exclude_ind = ep_summary->eps[ep ].patients[i ].
     exclude_ind
     SET ep_summary->eps[newpos ].patients[i ].gender = ep_summary->eps[ep ].patients[i ].gender
     SET ep_summary->eps[newpos ].patients[i ].race = ep_summary->eps[ep ].patients[i ].race
     SET ep_summary->eps[newpos ].patients[i ].ethnicity = ep_summary->eps[ep ].patients[i ].
     ethnicity
     SET ep_summary->eps[newpos ].patients[i ].payer = ep_summary->eps[ep ].patients[i ].payer
     SET ep_summary->eps[newpos ].patients[i ].payer_group = ep_summary->eps[ep ].patients[i ].
     payer_group
     SET ep_summary->eps[newpos ].patients[i ].hic = ep_summary->eps[ep ].patients[i ].hic
     SET ep_summary->eps[newpos ].patients[i ].encntr_cnt = ep_summary->eps[ep ].patients[i ].
     encntr_cnt
     SET stat = alterlist (ep_summary->eps[newpos ].patients[i ].encntrs ,ep_summary->eps[ep ].
      patients[i ].encntr_cnt )
     FOR (j = 1 TO ep_summary->eps[ep ].patients[i ].encntr_cnt )
      SET ep_summary->eps[newpos ].patients[i ].encntrs[j ].encntr_id = ep_summary->eps[ep ].
      patients[i ].encntrs[j ].encntr_id
      SET ep_summary->eps[newpos ].patients[i ].encntrs[j ].visit_date = ep_summary->eps[ep ].
      patients[i ].encntrs[j ].visit_date
      SET ep_summary->eps[newpos ].patients[i ].encntrs[j ].fin = ep_summary->eps[ep ].patients[i ].
      encntrs[j ].fin
      SET ep_summary->eps[newpos ].patients[i ].encntrs[j ].outcome = ep_summary->eps[ep ].patients[
      i ].encntrs[j ].outcome
      SET ep_summary->eps[newpos ].patients[i ].encntrs[j ].outcome_ind = ep_summary->eps[ep ].
      patients[i ].encntrs[j ].outcome_ind
      SET ep_summary->eps[newpos ].patients[i ].encntrs[j ].exclude_ind = ep_summary->eps[ep ].
      patients[i ].encntrs[j ].exclude_ind
     ENDFOR
    ENDFOR
   ENDIF
  ENDFOR
  SET ep_summary->ep_cnt = newpos
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf22 (null )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  DECLARE iter2 = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get exclusions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0022: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0022: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0022: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0022: HOSPICE_CARE_AMB: E2" ,
    "NQF2019_0022: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    out_flg = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0022: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0022: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0022: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0022: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0022: HOSPICE_CARE_AMB: E2" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|pos:" ,pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Denominator Exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  checkpersonidnum1 (providerid ,personid ,reportby )
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE duppos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter = i4 WITH noconstant (0 ) ,protect
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  CASE (cnvtupper (reportby ) )
   OF "INDV" :
    IF ((size (lh_nqf22_num1->qual ,5 ) > 0 ) )
     SET duppos = locateval (iter ,1 ,size (lh_nqf22_num1->qual ,5 ) ,personid ,lh_nqf22_num1->qual[
      iter ].person_id ,providerid ,lh_nqf22_num1->qual[iter ].reporting_id )
    ENDIF
    ,
    IF ((duppos = 0 ) )
     SET pos = locatevalsort (iter ,1 ,size (lh_ep_provider_list->eps ,5 ) ,providerid ,
      lh_ep_provider_list->eps[iter ].provider_id )
     IF ((pos > 0 ) )
      SET cnt = (size (lh_nqf22_num1->qual ,5 ) + 1 )
      SET stat = alterlist (lh_nqf22_num1->qual ,cnt )
      SET lh_nqf22_num1->qual[cnt ].person_id = personid
      SET lh_nqf22_num1->qual[cnt ].reporting_id = lh_ep_provider_list->eps[pos ].
      br_eligible_provider_id
     ENDIF
    ENDIF
   OF "GPRO" :
    FOR (gpro = 1 TO size (lh_ep_provider_list->gpros ,5 ) )
     IF ((size (lh_nqf22_num1->qual ,5 ) > 0 ) )
      SET duppos = locateval (iter ,1 ,size (lh_nqf22_num1->qual ,5 ) ,personid ,lh_nqf22_num1->qual[
       iter ].person_id ,lh_ep_provider_list->gpros[gpro ].br_gpro_id ,lh_nqf22_num1->qual[iter ].
       reporting_id )
     ENDIF
     IF ((duppos = 0 ) )
      SET pos = locateval (iter ,1 ,size (lh_ep_provider_list->gpros[gpro ].eps ,5 ) ,providerid ,
       lh_ep_provider_list->gpros[gpro ].eps[iter ].provider_id )
      IF ((pos > 0 ) )
       SET cnt = (size (lh_nqf22_num1->qual ,5 ) + 1 )
       SET stat = alterlist (lh_nqf22_num1->qual ,cnt )
       SET lh_nqf22_num1->qual[cnt ].person_id = personid
       SET lh_nqf22_num1->qual[cnt ].reporting_id = lh_ep_provider_list->gpros[gpro ].br_gpro_id
      ENDIF
     ENDIF
    ENDFOR
   OF "CPC" :
    FOR (cpc = 1 TO size (lh_ep_provider_list->cpcs ,5 ) )
     IF ((size (lh_nqf22_num1->qual ,5 ) > 0 ) )
      SET duppos = locateval (iter ,1 ,size (lh_nqf22_num1->qual ,5 ) ,personid ,lh_nqf22_num1->qual[
       iter ].person_id ,lh_ep_provider_list->cpcs[cpc ].br_cpc_id ,lh_nqf22_num1->qual[iter ].
       reporting_id )
     ENDIF
     IF ((duppos = 0 ) )
      SET pos = locateval (iter ,1 ,size (lh_ep_provider_list->cpcs[cpc ].eps ,5 ) ,providerid ,
       lh_ep_provider_list->cpcs[cpc ].eps[iter ].provider_id )
      IF ((pos > 0 ) )
       SET cnt = (size (lh_nqf22_num1->qual ,5 ) + 1 )
       SET stat = alterlist (lh_nqf22_num1->qual ,cnt )
       SET lh_nqf22_num1->qual[cnt ].person_id = personid
       SET lh_nqf22_num1->qual[cnt ].reporting_id = lh_ep_provider_list->cpcs[cpc ].br_cpc_id
      ENDIF
     ENDIF
    ENDFOR
  ENDCASE
 END ;Subroutine
 DECLARE getresults_nqf24 (null ) = null
 DECLARE process_nqf24_1 ((grp_num = i2 ) ) = null
 DECLARE process_nqf24_2 ((grp_num = i2 ) ) = null
 DECLARE process_nqf24_3 ((grp_num = i2 ) ) = null
 DECLARE getpopulation_nqf24 ((grp_num = i2 ) ) = null
 DECLARE getattribution_nqf24 ((measure_name = vc ) ) = null
 DECLARE getoutcome_nqf24_1 (null ) = null
 DECLARE getoutcome_nqf24_2 (null ) = null
 DECLARE getoutcome_nqf24_3 (null ) = null
 DECLARE getexclusion_nqf24 (null ) = null
 SUBROUTINE  getresults_nqf24 (null )
  CALL geteprfilter ("24" )
  CALL getpopulation_nqf24 (1 )
  CALL process_nqf24_1 (1 )
  CALL process_nqf24_2 (1 )
  CALL process_nqf24_3 (1 )
  SET stat = initrec (lh_ep_reply )
  CALL getpopulation_nqf24 (2 )
  CALL process_nqf24_1 (2 )
  CALL process_nqf24_2 (2 )
  CALL process_nqf24_3 (2 )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
  CALL sum_submeasures ("MU_EC_0024_2019.1.1" ,"MU_EC_0024_2019.1.2" ,"MU_EC_0024_2019.1.3" )
  CALL sum_submeasures ("MU_EC_0024_2019.2.1" ,"MU_EC_0024_2019.2.2" ,"MU_EC_0024_2019.2.3" )
  CALL sum_submeasures ("MU_EC_0024_2019.3.1" ,"MU_EC_0024_2019.3.2" ,"MU_EC_0024_2019.3.3" )
 END ;Subroutine
 SUBROUTINE  process_nqf24_1 (grp_num )
  CALL getattribution_nqf24 (build ("MU_EC_0024_2019.1." ,grp_num ) )
  CALL getexclusion_nqf24 (0 )
  CALL getoutcome_nqf24_1 (0 )
  CALL summaryreport (build ("MU_EC_0024_2019.1." ,grp_num ) )
 END ;Subroutine
 SUBROUTINE  process_nqf24_2 (grp_num )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO lh_ep_reply->person_cnt )
   SET lh_ep_reply->persons[i ].exclude_ind = 0
   SET lh_ep_reply->persons[i ].outcome_ind = 0
   SET lh_ep_reply->persons[i ].outcome = "Not Met, Not Done"
  ENDFOR
  CALL getattribution_nqf24 (build ("MU_EC_0024_2019.2." ,grp_num ) )
  CALL getexclusion_nqf24 (0 )
  CALL getoutcome_nqf24_2 (0 )
  CALL summaryreport (build ("MU_EC_0024_2019.2." ,grp_num ) )
 END ;Subroutine
 SUBROUTINE  process_nqf24_3 (grp_num )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO lh_ep_reply->person_cnt )
   SET lh_ep_reply->persons[i ].exclude_ind = 0
   SET lh_ep_reply->persons[i ].outcome_ind = 0
   SET lh_ep_reply->persons[i ].outcome = "Not Met, Not Done"
  ENDFOR
  CALL getattribution_nqf24 (build ("MU_EC_0024_2019.3." ,grp_num ) )
  CALL getexclusion_nqf24 (0 )
  CALL getoutcome_nqf24_3 (0 )
  CALL summaryreport (build ("MU_EC_0024_2019.3." ,grp_num ) )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf24 (grp_num )
  DECLARE start_age = i2 WITH noconstant (0 ) ,protect
  DECLARE end_age = i2 WITH noconstant (0 ) ,protect
  DECLARE p_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE e_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE p_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE e_batch_size = i4 WITH constant (10 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CASE (grp_num )
   OF 1 :
    SET start_age = 3
    SET end_age = 11
   OF 2 :
    SET start_age = 11
    SET end_age = 17
  ENDCASE
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0024: A1" ,
    "POPULATION: NQF2019_0024: B1" ,
    "POPULATION: NQF2019_0024: C1" ,
    "POPULATION: NQF2019_0024: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind (build (
      start_age ,",Y" ) ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind (build (end_age
      ,",Y" ) ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    p_total_size = p_batch_size ,
    stat = alterlist (lh_ep_reply->persons ,p_total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((personcnt > p_total_size ) ) p_total_size = (p_total_size + p_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons ,p_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 0 ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,
    lh_ep_reply->person_cnt = personcnt ,encntrcnt = 0 ,e_total_size = 10 ,stat = alterlist (
     lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((encntrcnt > e_total_size ) ) e_total_size = (e_total_size + e_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
    IF ((nullind (pop.disch_dt_tm ) = 1 ) ) lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].
     disch_dt_tm = pop.reg_dt_tm
    ELSE lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->
    persons[personcnt ].encntr_cnt = encntrcnt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After initial population query" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf24 (measure_name )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0024" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"0024" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"0024" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_SERV_INDIV_COUNSEL" ,"0024" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_SERV_GROUP_COUNSEL" ,"0024" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0024" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata (measure_name ,br_filters->provider_attribution ,"NQF2019_0024" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf24_1 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0024: BMI_PERCENTILE: E2" ,
    "NQF2019_0024: HEIGHT: E3" ,
    "NQF2019_0024: WEIGHT: E4" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,bmi_code = 0 ,weight_code = 0 ,height_code = 0
   DETAIL
    CASE (qry.query_name )
     OF "NQF2019_0024: BMI_PERCENTILE: E2" :
      bmi_code = 1
     OF "NQF2019_0024: HEIGHT: E3" :
      height_code = 1
     OF "NQF2019_0024: WEIGHT: E4" :
      weight_code = 1
    ENDCASE
   FOOT  pat.person_id
    IF ((person_pos > 0 ) )
     IF ((bmi_code = 1 )
     AND (weight_code = 1 )
     AND (height_code = 1 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->
      persons[person_pos ].outcome = "Met, Done"
     ENDIF
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ,"|out:" ,lh_ep_reply->
      persons[person_pos ].outcome_ind ) ) ,
     CALL echo (build ("debug:bmi:" ,bmi_code ,"|wt:" ,weight_code ,"|hi:" ,height_code ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After BMI calc" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf24_2 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get nutrition counseling outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,1 ,lh_ep_reply->persons[person_iter ].ep_ind ,0 ,lh_ep_reply->
     persons[person_iter ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0024: COUNSEL_NUTRITION: F5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: G5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: H5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: D5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: D6" ,
    "NQF2019_0024: COUNSEL_NUTRITION: D7" ,
    "NQF2019_0024: COUNSEL_NUTRITION: L5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: L6" ,
    "NQF2019_0024: COUNSEL_NUTRITION: A5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: B5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: C5" ,
    "NQF2019_0024: COUNSEL_NUTRITION: E5" ,
    "NQF2019_0024: COUNSEL_NUTRITION_PAT_EDU: P7" ) ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[person_pos ].
     outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ,"|outcome:" ,lh_ep_reply
      ->persons[person_pos ].outcome_ind ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("End effective date:" ,format (pat.end_effective_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After counseling for nutrition" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf24_3 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get counsel phys" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0024: COUNSEL_PHYS: E6" ,
    "NQF2019_0024: COUNSEL_PHYS: D6" ,
    "NQF2019_0024: COUNSEL_PHYS: D7" ,
    "NQF2019_0024: COUNSEL_PHYS: L6" ,
    "NQF2019_0024: COUNSEL_PHYS: L7" ,
    "NQF2019_0024: COUNSEL_PHYS: A6" ,
    "NQF2019_0024: COUNSEL_PHYS_PAT_EDU: P8" ) ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[person_pos ].
     outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ,"|outcome:" ,lh_ep_reply
      ->persons[person_pos ].outcome_ind ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("End effective date:" ,format (pat.end_effective_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes - counseling for physical activity" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf24 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Exclusion check: PREGNANCY" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0024: PREGNANCY_PROB: F1" ,
    "NQF2019_0024: PREGNANCY_PROB: G1" ,
    "NQF2019_0024: PREGNANCY_PROB: H1" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     IF ((qry.query_name = "NQF2019_0024: PREGNANCY_PROB: H1" ) )
      IF (checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.end_effective_dt_tm ) ) lh_ep_reply->
       persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[person_pos ].outcome =
       "Denominator Exclusion"
      ENDIF
     ELSE
      IF ((pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
      AND diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source )
      AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[person_pos ].
       outcome_ind = 2 ,lh_ep_reply->persons[person_pos ].outcome = "Denominator Exclusion"
      ENDIF
     ENDIF
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ,"|outcome:" ,lh_ep_reply
      ->persons[person_pos ].outcome_ind ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("End effective date:" ,format (pat.end_effective_dt_tm ,";;q" ) ,
      "|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After exclusions for pregnancy" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0024: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0024: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0024: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0024: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0024: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0024: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0024: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0024: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0024: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0024: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf28 (null ) = null
 DECLARE processmeasure_nqf28 ((measure = i2 ) ) = null
 DECLARE getpopulation_nqf28 ((attrib_option = i2 ) ) = null
 DECLARE calcindvprov ((providerid = f8 ) ,(personid = f8 ) ,(regdttm = dq8 ) ,(queryname = vc ) ) =
 null
 DECLARE calcgproprov ((providerid = f8 ) ,(personid = f8 ) ,(regdttm = dq8 ) ,(queryname = vc ) ) =
 null
 DECLARE getdeno_nqf28 (null ) = null
 DECLARE getusernonuser_nqf28 (null ) = null
 DECLARE getattribution_nqf28 ((measuremean = vc ) ) = null
 DECLARE getoutcome_nqf28_1 (null ) = null
 DECLARE getoutcome_nqf28_2 (null ) = null
 DECLARE getoutcome_nqf28_3 (null ) = null
 DECLARE getdenoexcep_nqf28_1 (null ) = null
 DECLARE getdenoexcep_nqf28_2 (null ) = null
 DECLARE getdenoexcep_nqf28_3 (null ) = null
 DECLARE validateeps (null ) = null
 SUBROUTINE  getresults_nqf28 (null )
  SET br_filters->provider_attribution = getproviderattribution ("28" )
  CALL geteprfilter ("28" )
  CALL getpopulation_nqf28 (br_filters->provider_attribution )
  CALL getusernonuser_nqf28 (0 )
  CALL processmeasure_nqf28 (1 )
  CALL processmeasure_nqf28 (3 )
  CALL processmeasure_nqf28 (2 )
  CALL validateeps (0 )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  processmeasure_nqf28 (measure )
  IF ((measure = 1 ) )
   CALL getattribution_nqf28 ("MU_EC_0028_2019.1" )
   CALL getoutcome_nqf28_1 (0 )
   CALL getdenoexcep_nqf28_1 (0 )
   CALL summaryreport ("MU_EC_0028_2019.1" )
  ELSEIF ((measure = 2 ) )
   CALL getdeno_nqf28 (0 )
   CALL getattribution_nqf28 ("MU_EC_0028_2019.2" )
   CALL getoutcome_nqf28_2 (0 )
   CALL getdenoexcep_nqf28_2 (0 )
   CALL summaryreport ("MU_EC_0028_2019.2" )
  ELSEIF ((measure = 3 ) )
   CALL getattribution_nqf28 ("MU_EC_0028_2019.3" )
   CALL getoutcome_nqf28_3 (0 )
   CALL getdenoexcep_nqf28_3 (0 )
   CALL summaryreport ("MU_EC_0028_2019.3" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf28 (attrib_option )
  DECLARE provider_cnt_met = i2 WITH noconstant (0 ) ,protect
  DECLARE epcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE tempid = f8 WITH noconstant (1.0 ) ,protect
  DECLARE temppersonid = f8 WITH noconstant (1.0 ) ,protect
  DECLARE flag = i2 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE personcnt1 = i4 WITH noconstant (0 ) ,protect
  DECLARE minqualid = f8 WITH noconstant (1.0 ) ,protect
  DECLARE minpersonid = f8 WITH noconstant (1.0 ) ,protect
  DECLARE provider_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE reltn_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter4 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE pos_ep = i4 WITH noconstant (0 ) ,protect
  DECLARE pos1 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos2 = i4 WITH noconstant (0 ) ,protect
  DECLARE day_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE attrib_option_parser = vc WITH noconstant ("" ) ,protect
  DECLARE att_code = vc WITH noconstant ("" ) ,protect
  DECLARE import_provider_id = f8 WITH noconstant (0.0 ) ,protect
  DECLARE ep_match = i2 WITH noconstant (0 ) ,protect
  DECLARE ep_bk_size = i4 WITH noconstant (0 ) ,protect
  DECLARE ep_size = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Initial Population Query - INDV" )
  CALL beg_time (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  IF ((attrib_option = 1 ) )
   SET attrib_option_parser = "ambep.attribution_option = '1'"
   SET att_code =
   "expand(reltn_iter, 1, br_filters->epr_cnt, ambep.encntr_prsnl_r_cd, br_filters->eprs[reltn_iter].code_value)"
  ELSEIF ((attrib_option = 2 ) )
   CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PC_SERV_GROUP_COUNSEL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PC_SERVICES_OTHER" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("PC_SERV_INDIV_COUNSEL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PSYCHOANALYSIS" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("HLTH_BEHAVE_ASSES_INITIAL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("HLTH_BEHAVE_ASSES_INDI" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1"
    )
   CALL getnonmappednomenclature ("OCCUPATIONAL_THERAPY_EVAL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("OPHTHALMOLOGICAL_SERVICES" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("HLTH_BEHAV_ASSESS_REASSESS" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("SPEECH_HEARING_EVAL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   SET att_code =
   "expand(reltn_iter,1,size(ep_nomen->qual,5),ambep.charge_reltn_cd, ep_nomen->qual[reltn_iter].source_vocab_id)"
   IF ((ep_charge_bim_option_ind = 0 ) )
    SET attrib_option_parser = "ambep.attribution_option = '2B'"
   ELSE
    SET attrib_option_parser = "ambep.attribution_option = '2C'"
   ENDIF
  ENDIF
  IF ((params->report_by = "GPRO" ) )
   CALL getprovidergroups (null )
  ENDIF
  SELECT INTO "nl:"
   FROM (br_eligible_provider ep ),
    (dummyt d1 WITH seq = size (params->eps ,5 ) )
   PLAN (d1
    WHERE (params->ep_cnt > 0 ) )
    JOIN (ep
    WHERE (ep.br_eligible_provider_id = params->eps[d1.seq ].br_eligible_provider_id )
    AND (ep.active_ind = 1 ) )
   HEAD ep.br_eligible_provider_id
    params->eps[d1.seq ].provider_id = ep.provider_id
   WITH nocounter
  ;end select
  SET stat = initrec (lh_ep_provider )
  SET stat = initrec (lh_bill_encntr_date )
  WHILE ((tempid > 0.0 ) )
   SET minpersonid = tempid
   SET flag = 0
   SELECT INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 pop ),
     (lh_d_query qry ),
     (lh_d_person p ),
     (lh_amb_ep_reltn_2019 ambep )
    PLAN (pop
     WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) )
     AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) )
     AND (((pop.person_id > minpersonid ) ) OR ((pop.person_id = minpersonid )
     AND (pop.lh_amb_qual_encntr_2019_id > minqualid ) ))
     AND (pop.active_ind = 1 )
     AND parser (org_id_parser )
     AND parser (location_filter )
     AND parser (debug_clause ) )
     JOIN (qry
     WHERE (pop.d_query_id = qry.d_query_id )
     AND (qry.query_name IN ("POPULATION: NQF2019_0028:*" ) )
     AND (qry.active_ind = 1 ) )
     JOIN (ambep
     WHERE (ambep.lh_amb_qual_encntr_2019_id = pop.lh_amb_qual_encntr_2019_id )
     AND (ambep.active_ind = 1 )
     AND parser (attrib_option_parser )
     AND expand (provider_iter ,1 ,size (params->eps ,5 ) ,ambep.provider_id ,params->eps[
      provider_iter ].provider_id )
     AND parser (att_code ) )
     JOIN (p
     WHERE (p.person_id = pop.person_id )
     AND parser (logical_domain_id_parser )
     AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
      cnvtdatetime (beg_extract_dt_tm ) ) )
     AND (p.active_ind = 1 ) )
    ORDER BY pop.person_id ,
     pop.encntr_id ,
     ambep.provider_id ,
     pop.lh_amb_qual_encntr_2019_id
    HEAD REPORT
     flag = 1 ,
     personcnt = size (lh_ep_reply->persons ,5 ) ,
     pos = 0
    HEAD pop.person_id
     temppersonid = pop.person_id ,enc_cnt = 0 ,person_pos = locateval (iter3 ,1 ,size (lh_ep_reply->
       persons ,5 ) ,pop.person_id ,lh_ep_reply->persons[iter3 ].person_id ) ,
     IF ((person_pos = 0 ) ) personcnt = (personcnt + 1 ) ,stat = alterlist (lh_ep_reply->persons ,
       personcnt )
     ELSE personcnt = person_pos ,enc_cnt = size (lh_ep_reply->persons[personcnt ].encntrs ,5 )
     ENDIF
     ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].
     mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[
     personcnt ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[personcnt ].exclude_ind = 1
    HEAD pop.encntr_id
     pos2 = locateval (iter3 ,1 ,enc_cnt ,pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[
      iter3 ].encntr_id ) ,
     IF ((pos2 = 0 ) ) enc_cnt = (enc_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].encntr_cnt =
      enc_cnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_cnt ) ,lh_ep_reply->
      persons[personcnt ].encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[
      personcnt ].encntrs[enc_cnt ].fin = pop.financial_nbr_txt ,
      IF ((pop.updt_source = "IMPORT*" )
      AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
       IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
        updt_src_ind = 3
       ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
       ENDIF
      ENDIF
      ,
      IF ((pop.updt_source = "lh_nqf2019_load.prg" )
      AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
       IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
        updt_src_ind = 3
       ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
       ENDIF
      ENDIF
     ENDIF
    HEAD pop.lh_amb_qual_encntr_2019_id
     minqualid = pop.lh_amb_qual_encntr_2019_id
    HEAD ambep.provider_id
     CALL echo (params->report_by ) ,
     IF ((params->report_by = "INDV" ) )
      CALL calcindvprov (ambep.provider_id ,pop.person_id ,pop.reg_dt_tm ,qry.query_name )
     ELSEIF ((params->report_by = "GPRO" ) )
      CALL calcgproprov (ambep.provider_id ,pop.person_id ,pop.reg_dt_tm ,qry.query_name )
     ENDIF
     ,
     IF ((debug_ind = 1 ) )
      CALL echo ("Provider count" ) ,
      CALL echorecord (lh_ep_provider )
     ENDIF
    FOOT  pop.person_id
     lh_ep_provider->epcnt = size (lh_ep_provider->eps ,5 )
    WITH maxrec = 5000 ,nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" ) ,expand = 1
   ;end select
   CALL end_time (0 )
   IF ((flag = 0 ) )
    SET tempid = 0.0
   ELSE
    SET tempid = temppersonid
   ENDIF
  ENDWHILE
  SET stat = alterlist (lh_ep_reply->persons ,personcnt )
  SET tempid = 1.0
  SET minpersonid = 1.0
  SET minqualid = 1.0
  SET temppersonid = 1.0
  WHILE ((tempid > 0.0 ) )
   SET minpersonid = tempid
   SET flag = 0
   SELECT INTO "nl:"
    FROM (lh_amb_qual_encntr_2019 pop ),
     (lh_d_query qry ),
     (lh_d_person p ),
     (lh_import_qrda_supp supp )
    PLAN (pop
     WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) )
     AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) )
     AND (((pop.person_id > minpersonid ) ) OR ((pop.person_id = minpersonid )
     AND (pop.lh_amb_qual_encntr_2019_id > minqualid ) ))
     AND (pop.active_ind = 1 )
     AND parser (org_id_parser )
     AND parser (location_filter )
     AND parser (debug_clause ) )
     JOIN (qry
     WHERE (pop.d_query_id = qry.d_query_id )
     AND (qry.query_name IN ("POPULATION: NQF2019_0028:*" ) )
     AND (qry.active_ind = 1 ) )
     JOIN (supp
     WHERE (supp.person_id = pop.person_id )
     AND (supp.supp_data_type = "PROVIDER_ID" ) )
     JOIN (p
     WHERE (p.person_id = pop.person_id )
     AND parser (logical_domain_id_parser )
     AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
      cnvtdatetime (beg_extract_dt_tm ) ) )
     AND (p.active_ind = 1 ) )
    ORDER BY pop.person_id ,
     pop.encntr_id ,
     supp.person_id ,
     pop.lh_amb_qual_encntr_2019_id
    HEAD REPORT
     flag = 1 ,
     personcnt1 = size (lh_ep_reply_bk->persons ,5 ) ,
     pos = 0
    HEAD pop.person_id
     temppersonid = pop.person_id ,enc_cnt = 0 ,person_pos = locateval (iter3 ,1 ,size (
       lh_ep_reply_bk->persons ,5 ) ,pop.person_id ,lh_ep_reply_bk->persons[iter3 ].person_id ) ,
     IF ((person_pos = 0 ) ) personcnt1 = (personcnt1 + 1 ) ,stat = alterlist (lh_ep_reply_bk->
       persons ,personcnt1 )
     ELSE personcnt1 = person_pos ,enc_cnt = size (lh_ep_reply_bk->persons[personcnt1 ].encntrs ,5 )
     ENDIF
     ,lh_ep_reply_bk->persons[personcnt1 ].person_id = pop.person_id ,lh_ep_reply_bk->persons[
     personcnt1 ].mrn = pop.comm_mrn_txt ,lh_ep_reply_bk->persons[personcnt1 ].outcome_ind = 0 ,
     lh_ep_reply_bk->persons[personcnt1 ].outcome = "Not Met, Not Done" ,lh_ep_reply_bk->persons[
     personcnt1 ].exclude_ind = 1
    HEAD pop.encntr_id
     pos2 = locateval (iter3 ,1 ,enc_cnt ,pop.encntr_id ,lh_ep_reply_bk->persons[personcnt1 ].
      encntrs[iter3 ].encntr_id ) ,
     IF ((pos2 = 0 ) ) enc_cnt = (enc_cnt + 1 ) ,lh_ep_reply_bk->persons[personcnt1 ].encntr_cnt =
      enc_cnt ,stat = alterlist (lh_ep_reply_bk->persons[personcnt1 ].encntrs ,enc_cnt ) ,
      lh_ep_reply_bk->persons[personcnt1 ].encntrs[enc_cnt ].encntr_id = pop.encntr_id ,
      lh_ep_reply_bk->persons[personcnt1 ].encntrs[enc_cnt ].fin = pop.financial_nbr_txt ,
      IF ((pop.updt_source = "IMPORT*" )
      AND (lh_ep_reply_bk->persons[personcnt1 ].updt_src_ind != 3 ) )
       IF ((lh_ep_reply_bk->persons[personcnt1 ].updt_src_ind = 1 ) ) lh_ep_reply_bk->persons[
        personcnt1 ].updt_src_ind = 3
       ELSE lh_ep_reply_bk->persons[personcnt1 ].updt_src_ind = 2
       ENDIF
      ENDIF
      ,
      IF ((pop.updt_source = "lh_nqf2019_load.prg" )
      AND (lh_ep_reply_bk->persons[personcnt1 ].updt_src_ind != 3 ) )
       IF ((lh_ep_reply_bk->persons[personcnt1 ].updt_src_ind = 2 ) ) lh_ep_reply_bk->persons[
        personcnt1 ].updt_src_ind = 3
       ELSE lh_ep_reply_bk->persons[personcnt1 ].updt_src_ind = 1
       ENDIF
      ENDIF
     ENDIF
    HEAD pop.lh_amb_qual_encntr_2019_id
     minqualid = pop.lh_amb_qual_encntr_2019_id ,ep_match = 0
    HEAD supp.person_id
     import_provider_id = cnvtreal (supp.supp_data_txt ) ,
     FOR (i = 1 TO size (params->eps ,5 ) )
      IF ((cnvtreal (params->eps[i ].provider_id ) = import_provider_id ) ) ep_match = 1
      ENDIF
     ENDFOR
     ,
     CALL echo (params->report_by ) ,
     IF ((ep_match = 1 ) )
      IF ((params->report_by = "INDV" ) )
       CALL calcindvprov (import_provider_id ,pop.person_id ,pop.reg_dt_tm ,qry.query_name )
      ELSEIF ((params->report_by = "GPRO" ) )
       CALL calcgproprov (import_provider_id ,pop.person_id ,pop.reg_dt_tm ,qry.query_name )
      ENDIF
     ENDIF
     ,
     IF ((debug_ind = 1 ) )
      CALL echo ("Provider count" ) ,
      CALL echorecord (lh_ep_provider )
     ENDIF
    FOOT  pop.person_id
     lh_ep_provider->epcnt = size (lh_ep_provider->eps ,5 )
    WITH maxrec = 5000 ,nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" ) ,expand = 1
   ;end select
   CALL end_time (0 )
   IF ((flag = 0 ) )
    SET tempid = 0.0
   ELSE
    SET tempid = temppersonid
   ENDIF
  ENDWHILE
  SET stat = alterlist (lh_ep_reply_bk->persons ,personcnt1 )
  SET ep_size = size (lh_ep_reply->persons ,5 )
  SET ep_bk_size = size (lh_ep_reply_bk->persons ,5 )
  SET stat = movereclist (lh_ep_reply_bk->persons ,lh_ep_reply->persons ,1 ,ep_size ,ep_bk_size ,
   true )
  SET lh_ep_reply->person_cnt = size (lh_ep_reply->persons ,5 )
  FOR (i = 1 TO size (lh_ep_provider->eps ,5 ) )
   IF ((lh_ep_provider->eps[i ].ecnt >= 2 ) )
    SET pos1 = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,lh_ep_provider->eps[i ].
     person_id ,lh_ep_reply->persons[iter2 ].person_id )
    IF ((pos1 > 0 ) )
     SET lh_ep_reply->persons[pos1 ].exclude_ind = 0
    ENDIF
   ENDIF
  ENDFOR
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo ("IPP results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  calcindvprov (providerid ,personid ,regdttm ,queryname )
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE pos_date = i4 WITH noconstant (0 ) ,protect
  DECLARE ep_cnt_flag = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  SET pos = 0
  SET pos_date = 0
  SET ep_cnt_flag = 0
  SET pos = locateval (iter2 ,1 ,size (lh_ep_provider->eps ,5 ) ,providerid ,lh_ep_provider->eps[
   iter2 ].ep_id ,personid ,lh_ep_provider->eps[iter2 ].person_id )
  IF ((pos = 0 ) )
   SET epcnt = (size (lh_ep_provider->eps ,5 ) + 1 )
   SET stat = alterlist (lh_ep_provider->eps ,epcnt )
   SET stat = alterlist (lh_ep_provider->eps[epcnt ].days ,1 )
   SET lh_ep_provider->epcnt = epcnt
   SET lh_ep_provider->eps[epcnt ].person_id = personid
   SET lh_ep_provider->eps[epcnt ].ep_id = providerid
   SET lh_ep_provider->eps[epcnt ].days[1 ].encntrday = cnvtdate (regdttm )
   SET ep_cnt_flag = 1
  ELSE
   SET epcnt = pos
   SET pos_date = locateval (iter2 ,1 ,size (lh_ep_provider->eps[epcnt ].days ,5 ) ,cnvtdate (
     regdttm ) ,cnvtdate (lh_ep_provider->eps[epcnt ].days[iter2 ].encntrday ) )
   IF ((pos_date = 0 ) )
    SET day_cnt = (size (lh_ep_provider->eps[epcnt ].days ,5 ) + 1 )
    SET stat = alterlist (lh_ep_provider->eps[epcnt ].days ,day_cnt )
    SET lh_ep_provider->eps[epcnt ].days[day_cnt ].encntrday = cnvtdate (regdttm )
    SET ep_cnt_flag = 2
   ENDIF
  ENDIF
  IF ((queryname = "POPULATION: NQF2019_0028: *1" ) )
   IF ((ep_cnt_flag = 1 ) )
    SET lh_ep_provider->eps[epcnt ].ecnt = 1
   ELSEIF ((ep_cnt_flag = 2 ) )
    SET lh_ep_provider->eps[epcnt ].ecnt = (lh_ep_provider->eps[epcnt ].ecnt + 1 )
   ENDIF
  ELSE
   SET lh_ep_provider->eps[epcnt ].ecnt = 2
  ENDIF
 END ;Subroutine
 SUBROUTINE  calcgproprov (providerid ,personid ,regdttm ,queryname )
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE pos_date = i4 WITH noconstant (0 ) ,protect
  DECLARE ep_cnt_flag = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE prov_list_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE prov_list_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  SET prov_list_size = size (lh_ep_provider_groups->eps ,5 )
  SET prov_list_pos = locateval (prov_list_iter ,1 ,prov_list_size ,providerid ,lh_ep_provider_groups
   ->eps[prov_list_iter ].provider_id )
  IF ((size (lh_ep_provider_groups->eps[prov_list_pos ].gpros ,5 ) > 0 )
  AND (prov_list_pos > 0 ) )
   FOR (i = 1 TO size (lh_ep_provider_groups->eps[prov_list_pos ].gpros ,5 ) )
    SET pos = 0
    SET pos_date = 0
    SET ep_cnt_flag = 0
    SET gpro_id = lh_ep_provider_groups->eps[prov_list_pos ].gpros[i ].br_gpro_id
    SET pos = locateval (iter2 ,1 ,size (lh_ep_provider->eps ,5 ) ,gpro_id ,lh_ep_provider->eps[
     iter2 ].ep_id ,personid ,lh_ep_provider->eps[iter2 ].person_id )
    IF ((pos = 0 ) )
     SET epcnt = (size (lh_ep_provider->eps ,5 ) + 1 )
     SET stat = alterlist (lh_ep_provider->eps ,epcnt )
     SET stat = alterlist (lh_ep_provider->eps[epcnt ].days ,1 )
     SET lh_ep_provider->epcnt = epcnt
     SET lh_ep_provider->eps[epcnt ].person_id = personid
     SET lh_ep_provider->eps[epcnt ].ep_id = gpro_id
     SET lh_ep_provider->eps[epcnt ].days[1 ].encntrday = cnvtdate (regdttm )
     SET ep_cnt_flag = 1
    ELSE
     SET epcnt = pos
     SET pos_date = locateval (iter2 ,1 ,size (lh_ep_provider->eps[epcnt ].days ,5 ) ,cnvtdate (
       regdttm ) ,cnvtdate (lh_ep_provider->eps[epcnt ].days[iter2 ].encntrday ) )
     IF ((pos_date = 0 ) )
      SET day_cnt = (size (lh_ep_provider->eps[epcnt ].days ,5 ) + 1 )
      SET stat = alterlist (lh_ep_provider->eps[epcnt ].days ,day_cnt )
      SET lh_ep_provider->eps[epcnt ].days[day_cnt ].encntrday = cnvtdate (regdttm )
      SET ep_cnt_flag = 2
     ENDIF
    ENDIF
    IF ((queryname = "POPULATION: NQF2019_0028: *1" ) )
     IF ((ep_cnt_flag = 1 ) )
      SET lh_ep_provider->eps[epcnt ].ecnt = 1
     ELSEIF ((ep_cnt_flag = 2 ) )
      SET lh_ep_provider->eps[epcnt ].ecnt = (lh_ep_provider->eps[epcnt ].ecnt + 1 )
     ENDIF
    ELSE
     SET lh_ep_provider->eps[epcnt ].ecnt = 2
    ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE  getusernonuser_nqf28 (null )
  CALL lhprint ("; user screen check" )
  CALL beg_time (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE event_user_date = dq8 WITH noconstant (0 ) ,protect
  DECLARE event_non_user_date = dq8 WITH noconstant (0 ) ,protect
  DECLARE tob_use_screen = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_user = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm BETWEEN cnvtlookbehind ("24,M" ,cnvtdatetime (end_extract_dt_tm ) ) AND
   cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0028: TOB_USE_SCREEN: K10" ,
   "NQF2019_0028: TOB_USE_SCREEN: I10" ,
   "NQF2019_0028: TOB_USE_SCREEN: E10" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].special_group_two = 1 ,lh_ep_reply->persons[pos ].
     special_cond_a_dt_tm = cnvtdatetime (pat.ep_dt_tm )
    ENDIF
   WITH nocounter ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";tob-user/non user check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm BETWEEN cnvtlookbehind ("24,M" ,cnvtdatetime (end_extract_dt_tm ) ) AND
   cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0028: TOB_USER_PROB: H2" ,
   "NQF2019_0028: TOB_USER_SHX: K4" ,
   "NQF2019_0028: TOB_USER_SHX: I4" ,
   "NQF2019_0028: TOB_USER_SHX: E4" ,
   "NQF2019_0028: TOB_NON_USER_PROB: H1" ,
   "NQF2019_0028: TOB_NON_USER_SHX: K3" ,
   "NQF2019_0028: TOB_NON_USER_SHX: I3" ,
   "NQF2019_0028: TOB_NON_USER_SHX: E3" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,event_user_date = 0 ,event_non_user_date = 0 ,tob_non_user = 0 ,tob_user =
    0
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].special_group_two = 1 ) )
     CASE (ambqry.query_name )
      OF "NQF2019_0028: TOB_NON_USER_PROB: H1" :
      OF "NQF2019_0028: TOB_NON_USER_SHX: K3" :
      OF "NQF2019_0028: TOB_NON_USER_SHX: I3" :
      OF "NQF2019_0028: TOB_NON_USER_SHX: E3" :
       IF ((lh_ep_reply->persons[pos ].special_cond_a_dt_tm <= cnvtdatetime (pat.ep_dt_tm ) ) )
        IF ((cnvtdatetime (event_non_user_date ) < pat.ep_dt_tm ) ) event_non_user_date = pat
         .ep_dt_tm ,tob_non_user = 1
        ENDIF
       ENDIF
      OF "NQF2019_0028: TOB_USER_PROB: H2" :
      OF "NQF2019_0028: TOB_USER_SHX: E4" :
      OF "NQF2019_0028: TOB_USER_SHX: K4" :
      OF "NQF2019_0028: TOB_USER_SHX: I4" :
       IF ((lh_ep_reply->persons[pos ].special_cond_a_dt_tm <= cnvtdatetime (pat.ep_dt_tm ) ) )
        IF ((cnvtdatetime (event_user_date ) < pat.ep_dt_tm ) ) event_user_date = pat.ep_dt_tm ,
         tob_user = 1
        ENDIF
       ENDIF
     ENDCASE
    ENDIF
   FOOT  pat.person_id
    IF ((tob_non_user = 1 )
    AND (tob_user = 1 ) )
     IF ((cnvtdatetime (event_non_user_date ) > cnvtdatetime (event_user_date ) ) ) lh_ep_reply->
      persons[pos ].special_group = 2 ,lh_ep_reply->persons[pos ].special_cond_dt_tm = cnvtdatetime (
       event_non_user_date )
     ELSE lh_ep_reply->persons[pos ].special_group = 1 ,lh_ep_reply->persons[pos ].special_cond_dt_tm
       = cnvtdatetime (event_user_date )
     ENDIF
    ELSEIF ((tob_non_user = 1 ) ) lh_ep_reply->persons[pos ].special_group = 2 ,lh_ep_reply->persons[
     pos ].special_cond_dt_tm = cnvtdatetime (event_non_user_date )
    ELSEIF ((tob_user = 1 ) ) lh_ep_reply->persons[pos ].special_group = 1 ,lh_ep_reply->persons[pos
     ].special_cond_dt_tm = cnvtdatetime (event_user_date )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getdeno_nqf28 (null )
  CALL lhprint (";Denominator check for NQF28.2" )
  CALL beg_time (0 )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  FOR (p_iter = 1 TO lh_ep_reply->person_cnt )
   SET lh_ep_reply->persons[p_iter ].exclude_ind = 0
   SET lh_ep_reply->persons[p_iter ].outcome_ind = 4
   SET lh_ep_reply->persons[p_iter ].outcome = "IPP Only"
   IF ((lh_ep_reply->persons[p_iter ].special_group_two = 1 )
   AND (lh_ep_reply->persons[p_iter ].special_group = 1 ) )
    SET lh_ep_reply->persons[p_iter ].outcome_ind = 0
    SET lh_ep_reply->persons[p_iter ].outcome = "Not Met, No Cessation"
   ENDIF
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf28 (measuremean )
  CALL lhprint (build (";Attribution for " ,measuremean ) )
  CALL beg_time (0 )
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i = i4 WITH noconstant (0 ) ,protect
  IF ((measuremean = "MU_EC_0028_2019.1" ) )
   CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PC_SERV_GROUP_COUNSEL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PC_SERVICES_OTHER" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("PC_SERV_INDIV_COUNSEL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("PSYCHOANALYSIS" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getnonmappednomenclature ("HLTH_BEHAVE_ASSES_INITIAL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("HLTH_BEHAVE_ASSES_INDI" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1"
    )
   CALL getnonmappednomenclature ("OCCUPATIONAL_THERAPY_EVAL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("OPHTHALMOLOGICAL_SERVICES" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("HLTH_BEHAV_ASSESS_REASSESS" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,
    "1=1" )
   CALL getnonmappednomenclature ("SPEECH_HEARING_EVAL" ,"0028" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
   CALL getepdata (measuremean ,br_filters->provider_attribution ,"NQF2019_0028" )
  ELSE
   SET reportmean = "MU_EC_0028_2019.1"
   SET reportmean1 = measuremean
   SELECT INTO "nl:"
    FROM (dummyt d WITH seq = ep_summary->ep_cnt ),
     (dummyt d2 WITH seq = 1 ),
     (dummyt d3 WITH seq = 1 )
    PLAN (d
     WHERE (ep_summary->ep_cnt > 0 )
     AND (ep_summary->eps[d.seq ].reportmean = reportmean )
     AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
     JOIN (d2
     WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
     AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
     JOIN (d3
     WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
    ORDER BY d.seq ,
     d2.seq ,
     d3.seq
    HEAD d.seq
     ep_pos = locateval (ep_i ,1 ,size (ep_summary->eps ,5 ) ,ep_summary->eps[d.seq ].provider_id ,
      ep_summary->eps[ep_i ].provider_id ,reportmean1 ,ep_summary->eps[ep_i ].reportmean ,ep_summary
      ->eps[d.seq ].tax_id_nbr_txt ,ep_summary->eps[ep_i ].tax_id_nbr_txt ) ,
     IF ((ep_pos > 0 ) ) epcnt1 = ep_pos
     ELSE epcnt = size (ep_summary->eps ,5 ) ,epcnt1 = (epcnt + 1 ) ,stat = alterlist (ep_summary->
       eps ,epcnt1 ) ,ep_summary->ep_cnt = epcnt1 ,ep_summary->eps[epcnt1 ].br_eligible_provider_id
      = ep_summary->eps[d.seq ].br_eligible_provider_id ,ep_summary->eps[epcnt1 ].provider_id =
      ep_summary->eps[d.seq ].provider_id ,ep_summary->eps[epcnt1 ].tax_id_nbr_txt = ep_summary->eps[
      d.seq ].tax_id_nbr_txt ,ep_summary->eps[epcnt1 ].gpro_name = ep_summary->eps[d.seq ].gpro_name
     ,ep_summary->eps[epcnt1 ].npi_nbr_txt = ep_summary->eps[d.seq ].npi_nbr_txt ,ep_summary->eps[
      epcnt1 ].reportmean = reportmean1 ,ep_summary->eps[epcnt1 ].name = ep_summary->eps[d.seq ].name
     ENDIF
     ,ptcnt = 0
    HEAD d2.seq
     person_pos = locateval (person_i ,1 ,size (ep_summary->eps[epcnt1 ].patients ,5 ) ,ep_summary->
      eps[d.seq ].patients[d2.seq ].person_id ,ep_summary->eps[epcnt1 ].patients[person_i ].person_id
       ) ,
     IF ((person_pos > 0 ) ) ptcnt = person_pos
     ELSE ptcnt = (ep_summary->eps[epcnt1 ].patient_cnt + 1 ) ,ep_summary->eps[epcnt1 ].patient_cnt
      = ptcnt ,stat = alterlist (ep_summary->eps[epcnt1 ].patients ,ptcnt ) ,ep_summary->eps[epcnt1 ]
      .patients[ptcnt ].person_id = ep_summary->eps[d.seq ].patients[d2.seq ].person_id ,ep_summary->
      eps[epcnt1 ].patients[ptcnt ].mrn = ep_summary->eps[d.seq ].patients[d2.seq ].mrn ,ep_summary->
      eps[epcnt1 ].patients[ptcnt ].birth_date = ep_summary->eps[d.seq ].patients[d2.seq ].birth_date
       ,ep_summary->eps[epcnt1 ].patients[ptcnt ].name = ep_summary->eps[d.seq ].patients[d2.seq ].
      name
     ENDIF
     ,ecnt = 0
    HEAD d3.seq
     ecnt = (ep_summary->eps[epcnt1 ].patients[ptcnt ].encntr_cnt + 1 ) ,ep_summary->eps[epcnt1 ].
     patients[ptcnt ].encntr_cnt = ecnt ,stat = alterlist (ep_summary->eps[epcnt1 ].patients[ptcnt ].
      encntrs ,ecnt ) ,ep_summary->eps[epcnt1 ].patients[ptcnt ].encntrs[ecnt ].encntr_id =
     ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].encntr_id ,ep_summary->eps[epcnt1 ].
     patients[ptcnt ].encntrs[ecnt ].br_eligible_provider_id = ep_summary->eps[d.seq ].patients[d2
     .seq ].encntrs[d3.seq ].br_eligible_provider_id ,ep_summary->eps[epcnt1 ].patients[ptcnt ].
     encntrs[ecnt ].visit_date = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].
     visit_date ,ep_summary->eps[epcnt1 ].patients[ptcnt ].encntrs[ecnt ].fin = ep_summary->eps[d
     .seq ].patients[d2.seq ].encntrs[d3.seq ].fin
    WITH nocounter
   ;end select
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf28_1 (null )
  CALL lhprint (";NQF28.1 Outcome check" )
  CALL beg_time (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  FOR (iter1 = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((lh_ep_reply->persons[iter1 ].special_group_two = 1 ) )
    IF ((lh_ep_reply->persons[iter1 ].special_group = 1 ) )
     SET lh_ep_reply->persons[iter1 ].outcome_ind = 1
     SET lh_ep_reply->persons[iter1 ].outcome = "Met, User"
    ELSEIF ((lh_ep_reply->persons[iter1 ].special_group = 2 ) )
     SET lh_ep_reply->persons[iter1 ].outcome_ind = 1
     SET lh_ep_reply->persons[iter1 ].outcome = "Met, Non-User"
    ENDIF
   ENDIF
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf28_2 (null )
  CALL lhprint (";NQF28.2 Outcome Check" )
  CALL beg_time (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  FOR (iter1 = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((lh_ep_reply->persons[iter1 ].outcome_ind = 0 ) )
    IF ((lh_ep_reply->persons[iter1 ].outcome_temp = 4 ) )
     SET lh_ep_reply->persons[iter1 ].outcome_ind = 1
     SET lh_ep_reply->persons[iter1 ].outcome = "Met, Cessation Done"
    ENDIF
   ENDIF
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf28_3 (null )
  CALL lhprint (";get outcome_pop3" )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE tob_counsel = i2 WITH noconstant (0 ) ,protect
  DECLARE med_ind = i2 WITH noconstant (0 ) ,protect
  CALL lhprint (";NQF28.3 outcome check" )
  CALL beg_time (0 )
  FOR (p_iter = 1 TO lh_ep_reply->person_cnt )
   SET lh_ep_reply->persons[p_iter ].exclude_ind = 0
   SET lh_ep_reply->persons[p_iter ].outcome_ind = 0
   SET lh_ep_reply->persons[p_iter ].outcome = "Not Met, Not Done"
   IF ((lh_ep_reply->persons[p_iter ].special_group = 2 ) )
    SET lh_ep_reply->persons[p_iter ].outcome_ind = 1
    SET lh_ep_reply->persons[p_iter ].outcome = "Met, Non-User"
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0028: TOB_COUNSEL_PROC: H5" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: E5" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: L5" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: L6" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: D5" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: A5" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: B5" ,
   "NQF2019_0028: TOB_COUNSEL_PROC: C5" ,
   "NQF2019_0028: TOB_COUNSEL_POC: D6" ,
   "NQF2019_0028: TOB_COUNSEL_POC: K6" ,
   "NQF2019_0028: TOB_COUNSEL_PAT_EDU: P11" ,
   "NQF2019_0028: MEDICATION: M7" ,
   "NQF2019_0028: MEDICATION: M8" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,tob_counsel = 0 ,med_ind = 0
   DETAIL
    IF ((lh_ep_reply->persons[pos ].special_group = 1 ) )
     CASE (ambqry.query_name )
      OF "NQF2019_0028: TOB_COUNSEL_PROC: H5" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: E5" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: L5" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: L6" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: D5" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: A5" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: B5" :
      OF "NQF2019_0028: TOB_COUNSEL_PROC: C5" :
      OF "NQF2019_0028: TOB_COUNSEL_POC: D6" :
      OF "NQF2019_0028: TOB_COUNSEL_PAT_EDU: P11" :
      OF "NQF2019_0028: TOB_COUNSEL_POC: K6" :
       IF ((pat.ep_dt_tm >= lh_ep_reply->persons[pos ].special_cond_dt_tm ) ) tob_counsel = 1
       ENDIF
      OF "NQF2019_0028: MEDICATION: M7" :
       IF ((lh_ep_reply->persons[pos ].special_cond_dt_tm BETWEEN pat.ep_dt_tm AND pat.ep_end_dt_tm
       ) ) med_ind = 1
       ENDIF
      OF "NQF2019_0028: MEDICATION: M8" :
       IF ((pat.ep_dt_tm >= lh_ep_reply->persons[pos ].special_cond_dt_tm ) ) med_ind = 1
       ENDIF
     ENDCASE
    ENDIF
   FOOT  pat.person_id
    IF ((((tob_counsel = 1 ) ) OR ((med_ind = 1 ) )) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Cessation Done" ,lh_ep_reply->persons[pos ].
     outcome_temp = 4
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getdenoexcep_nqf28_1 (null )
  CALL lhprint (";negation exclusion check Denominator exception 1" )
  CALL beg_time (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE event_date = dq8 WITH noconstant (0 ) ,protect
  DECLARE tob_use_screen = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_user = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_counsel = i2 WITH noconstant (0 ) ,protect
  DECLARE med_ind = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0028: NEGATION: E9" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((lh_ep_reply->persons[pos ].outcome_ind = 0 )
    AND (lhgetdatetimedifference (cnvtdatetime (end_extract_dt_tm ) ,pat.ep_dt_tm ,"MO" ) <= 24 ) )
     lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].outcome =
     "Denominator Exception" ,lh_ep_reply->persons[pos ].outcome_temp = 1
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";problem exclusion check Denominator exception 1" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name = "NQF2019_0028: LIFE_EXP_PROB: H8" )
   AND (nullcheck (pat.onset_dt_tm ,pat.beg_effective_dt_tm ,nullind (pat.onset_dt_tm ) ) <=
   cnvtdatetime (end_extract_dt_tm ) )
   AND (((pat.ep_end_dt_tm > cnvtdatetime (end_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((lh_ep_reply->persons[pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,
     lh_ep_reply->persons[pos ].outcome = "Denominator Exception" ,lh_ep_reply->persons[pos ].
     outcome_temp = 2
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getdenoexcep_nqf28_2 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE event_date = dq8 WITH noconstant (0 ) ,protect
  DECLARE tob_use_screen = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_user = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_counsel = i2 WITH noconstant (0 ) ,protect
  DECLARE med_ind = i2 WITH noconstant (0 ) ,protect
  CALL lhprint (";problem exclusion check Denominator exception 2" )
  CALL beg_time (0 )
  FOR (iter1 = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((lh_ep_reply->persons[iter1 ].outcome_ind = 0 )
   AND (lh_ep_reply->persons[iter1 ].outcome_temp IN (2 ,
   3 ) ) )
    SET lh_ep_reply->persons[iter1 ].outcome_ind = 3
    SET lh_ep_reply->persons[iter1 ].outcome = "Denominator Exception"
   ENDIF
  ENDFOR
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getdenoexcep_nqf28_3 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE event_date = dq8 WITH noconstant (0 ) ,protect
  DECLARE tob_use_screen = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_user = i2 WITH noconstant (0 ) ,protect
  DECLARE tob_counsel = i2 WITH noconstant (0 ) ,protect
  DECLARE med_ind = i2 WITH noconstant (0 ) ,protect
  CALL getdenoexcep_nqf28_1 (0 )
  CALL lhprint (";Negation exclusion check Denominator exception 3" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0028: NEGATION: E10" ,
   "NQF2019_0028: NEGATION: E11" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 )
    AND (lh_ep_reply->persons[pos ].special_group = 1 ) )
     IF ((pat.ep_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].special_cond_dt_tm ) ) )
      lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].outcome =
      "Denominator Exception" ,lh_ep_reply->persons[pos ].outcome_temp = 3
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  validateeps (null )
  CALL lhprint (";validating EPs" )
  CALL beg_time (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE p = i4 WITH protect ,noconstant (0 )
  FOR (iter1 = 1 TO size (ep_summary->eps ,5 ) )
   IF ((ep_summary->eps[iter1 ].reportmean = "NQF2019_0028*" ) )
    SET ep_summary->eps[iter1 ].exclude_ind = 1
    FOR (p = 1 TO ep_summary->eps[iter1 ].patient_cnt )
     SET ep_summary->eps[iter1 ].patients[p ].exclude_ind = 1
    ENDFOR
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   provider_id = ep_summary->eps[d1.seq ].provider_id ,
   person_id = ep_summary->eps[d1.seq ].patients[d2.seq ].person_id
   FROM (dummyt d1 WITH seq = size (ep_summary->eps ,5 ) ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (ep_summary->eps[d1.seq ].patients ,5 ) )
    AND (ep_summary->ep_cnt > 0 ) )
    JOIN (d2
    WHERE (ep_summary->eps[d1.seq ].patient_cnt > 0 ) )
   ORDER BY provider_id ,
    person_id
   HEAD d1.seq
    dummy = 0
   HEAD d2.seq
    dummy = 0
   DETAIL
    pos = 0 ,
    pos = locateval (iter1 ,1 ,size (lh_ep_provider->eps ,5 ) ,provider_id ,lh_ep_provider->eps[
     iter1 ].ep_id ,person_id ,lh_ep_provider->eps[iter1 ].person_id ) ,
    IF ((pos > 0 ) ) ep_summary->eps[d1.seq ].patients[d2.seq ].exclude_ind = 0 ,ep_summary->eps[d1
     .seq ].exclude_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  CALL removedummyitemexcludeonly (ep_summary ,"exclude_ind" )
  CALL end_time (0 )
 END ;Subroutine
 DECLARE getresults_nqf32 (null ) = null
 DECLARE getpopulation_nqf32 (null ) = null
 DECLARE getattribution_nqf32 (null ) = null
 DECLARE getexclusion_nqf32 (null ) = null
 DECLARE getoutcome_nqf32 (null ) = null
 SUBROUTINE  getresults_nqf32 (null )
  CALL geteprfilter ("32" )
  CALL getpopulation_nqf32 (0 )
  CALL getattribution_nqf32 (0 )
  CALL getexclusion_nqf32 (0 )
  CALL getoutcome_nqf32 (0 )
  CALL summaryreport ("MU_EC_0032_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf32 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE person_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE encntr_batch_size = i4 WITH constant (10 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query - most recent encounter is qualifying" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("POPULATION: NQF2019_0032: A1" ,
    "POPULATION: NQF2019_0032: B1" ,
    "POPULATION: NQF2019_0032: C1" ,
    "POPULATION: NQF2019_0032: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (p.sex_meaning = "FEMALE" )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("23,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) >= cnvtlookbehind ("64,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((mod (personcnt ,person_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons ,((
      personcnt + person_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].birth_date = p.birth_dt_tm ,lh_ep_reply->
    persons[personcnt ].special_group = 0 ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,
    lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((mod (encntrcnt ,encntr_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons[
      personcnt ].encntrs ,((encntrcnt + encntr_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,lh_ep_reply->persons[
    personcnt ].encntr_cnt = encntrcnt
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt ) ,
    lh_ep_reply->person_cnt = personcnt
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query - most recent encounter is qualifying" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf32 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (
   ";get exclusion - Hx of Hysterectomy procedure check before or during the measurement period" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_end_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0032: HYSTERECTOMY_PROC: A1" ,
   "NQF2019_0032: HYSTERECTOMY_PROC: B1" ,
   "NQF2019_0032: HYSTERECTOMY_PROC: C1" ,
   "NQF2019_0032: HYSTERECTOMY_PROC: D1" ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,
    IF ((person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";get exclusion - Hx of Hysterectomy procedure check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (
   ";get exclusion - Congenital Absence of Cervix problem check starts before end of MP" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (nullcheck (pat.onset_dt_tm ,pat.beg_effective_dt_tm ,nullind (pat.onset_dt_tm ) ) <
   cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name = "NQF2019_0032: ABSE_CERVIX_PROB: H1" )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,
    IF ((person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Hospice Exclusion check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0032: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0032: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0032: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0032: HOSPICE_CARE_AMB: E2" ,
    "NQF2019_0032: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0032: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0032: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0032: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0032: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0032: HOSPICE_CARE_AMB: E2" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf32 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome - Pap test check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (qry.query_name = "NQF2019_0032: PAP_TEST: E2" )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     IF ((lhgetdatetimedifference (cnvtdatetime (end_extract_dt_tm ) ,pat.ep_dt_tm ,"Y" ) <= 3 ) )
      lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome =
      "Met, Done"
     ELSE lh_ep_reply->persons[person_pos ].special_cond_dt_tm = pat.ep_dt_tm ,lh_ep_reply->persons[
      person_pos ].age = (datetimediff (cnvtdatetime (pat.ep_dt_tm ) ,lh_ep_reply->persons[
       person_pos ].birth_date ) / 365.25 ) ,lh_ep_reply->persons[person_pos ].special_group = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";get outcome - pap test check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";get outcome - HPV test check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind ,1 ,lh_ep_reply->persons[iter1 ].
    special_group )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name = "NQF2019_0032: HPV_TEST: E2" )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].age >= 30 )
    AND (lhgetdatetimedifference (cnvtdatetime (end_extract_dt_tm ) ,lh_ep_reply->persons[person_pos
     ].special_cond_dt_tm ,"Y" ) <= 5 )
    AND (lh_ep_reply->persons[person_pos ].special_cond_dt_tm > datetimeadd (pat.ep_dt_tm ,- (2 ) )
    )
    AND (lh_ep_reply->persons[person_pos ].special_cond_dt_tm < datetimeadd (pat.ep_dt_tm ,2 ) ) )
     lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome =
     "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";get outcome - hpv test check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf32 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0032" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0032" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0032" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0032" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0032_2019" ,br_filters->provider_attribution ,"NQF2019_0032" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf33 (null ) = null
 DECLARE getpopulation_nqf33 ((grp_num = i2 ) ) = null
 DECLARE getattribution_nqf33 ((grp_num = i2 ) ) = null
 DECLARE getoutcome_nqf33 (null ) = null
 DECLARE getexclusion_nqf33 (null ) = null
 SUBROUTINE  getresults_nqf33 (null )
  IF ((validate (lh_preg ) = 0 ) )
   RECORD lh_preg (
     1 person_cnt = i4
     1 persons [* ]
       2 person_id = f8
       2 date_cnt = i4
       2 dates [* ]
         3 preg_date = dq8
   ) WITH protect
  ENDIF
  CALL geteprfilter ("33" )
  CALL getpopulation_nqf33 (1 )
  CALL getattribution_nqf33 (1 )
  CALL getexclusion_nqf33 (0 )
  CALL getoutcome_nqf33 (0 )
  CALL summaryreport ("MU_EC_0033_2019.1" )
  SET stat = initrec (lh_preg )
  SET stat = initrec (lh_ep_reply )
  CALL getpopulation_nqf33 (2 )
  CALL getattribution_nqf33 (2 )
  CALL getexclusion_nqf33 (0 )
  CALL getoutcome_nqf33 (0 )
  CALL summaryreport ("MU_EC_0033_2019.2" )
  SET stat = initrec (lh_preg )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
  CALL sum_submeasures ("MU_EC_0033_2019.1" ,"MU_EC_0033_2019.2" ,"MU_EC_0033_2019.3" )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf33 (grp_num )
  DECLARE start_age = i2 WITH noconstant (0 ) ,protect
  DECLARE end_age = i2 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE female_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,57 ,"FEMALE" ) )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CASE (grp_num )
   OF 1 :
    SET start_age = 16
    SET end_age = 20
   OF 2 :
    SET start_age = 20
    SET end_age = 24
  ENDCASE
  CALL lhprint (";Initial Population Query: Qualifying Encounters" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0033: A1" ,
    "POPULATION: NQF2019_0033: B1" ,
    "POPULATION: NQF2019_0033: C1" ,
    "POPULATION: NQF2019_0033: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (cnvtupper (p.sex_display ) = "FEMALE" )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind (build (
      start_age ,",Y" ) ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind (build (end_age
      ,",Y" ) ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat =
    alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->
    persons[personcnt ].outcome = "Not Met, Not Done"
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint ("; Sexual Active Response: Assessments Identifying Sexual Activity" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,1 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
    AND (trim (pat.secondary_vset_cd ) != "" ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: SEXUALLY_ACTIVE_RSPNS: K1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RSPNS: E1" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->persons[pos ].
     special_group = 1
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("; Sexual Active Problems: Diagnoses Identifying Sexual Activity" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,1 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: SEXUALLY_ACTIVE_PROB: F1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: F2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: F3" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: G1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: G2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: G3" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: L1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: L2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: D1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: E1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: H1" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROB: H2" ,
    "NQF2019_0033: CONTRA_MED: M4" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    date_chck = 0 ,pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    CASE (qry.query_name )
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: F1" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: F2" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: F3" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: G1" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: G2" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: G3" :
      IF ((diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) date_chck =
       1
      ENDIF
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: L1" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: L2" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: D1" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: E1" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: H1" :
     OF "NQF2019_0033: SEXUALLY_ACTIVE_PROB: H2" :
     OF "NQF2019_0033: CONTRA_MED: M4" :
      IF ((((pat.ep_end_dt_tm >= cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null
      ) )) ) date_chck = 1
      ENDIF
    ENDCASE
   FOOT  pat.person_id
    IF ((pos > 0 )
    AND (date_chck = 1 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->persons[pos ].
     special_group = 1
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL lhprint (";Procedures and Results:" )
  CALL lhprint (";Active Contraceptive Medications" )
  CALL lhprint (";Laboratory Tests Identifying Sexual Activity But Not Pregnancy" )
  CALL lhprint (";Procedures  Identifying Sexual Activity" )
  CALL lhprint (";Ordered Contraceptive Medications" )
  CALL lhprint (";Diagnostic Studies Identifying Sexual Activity" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,1 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: SEXUALLY_ACTIVE_PROC: A2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROC: B2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROC: C2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROC: D2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROC: L2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROC: L3" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_PROC: E2" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RESULT: L3" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RESULT: L4" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RESULT: E3" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RESULT: L5" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RESULT: L6" ,
    "NQF2019_0033: SEXUALLY_ACTIVE_RESULT: E5" ,
    "NQF2019_0033: CONTRA_MED: M5" ) ) )
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->persons[pos ].
     special_group = 1
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (
   ";Retrieving all pregnancy tests during the reporting period: Laboratory Tests Identifying Sexual Activity"
   )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: PREGNANCY_RESULT: L3" ,
    "NQF2019_0033: PREGNANCY_RESULT: L4" ,
    "NQF2019_0033: PREGNANCY_RESULT: D3" ,
    "NQF2019_0033: PREGNANCY_RESULT: E3" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0 ,
    pcnt = 0
   HEAD pat.person_id
    person_ind = 0 ,pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id ) ,
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].special_group != 1 ) ) lh_ep_reply->persons[pos ].exclude_ind =
     0 ,lh_ep_reply->persons[pos ].special_group = 0 ,pcnt = (pcnt + 1 ) ,lh_preg->person_cnt = pcnt
    ,stat = alterlist (lh_preg->persons ,pcnt ) ,lh_preg->persons[pcnt ].person_id = pat.person_id ,
     person_ind = 1
    ENDIF
    ,dcnt = 0
   HEAD pat.ep_dt_tm
    IF ((person_ind = 1 ) ) dcnt = (dcnt + 1 ) ,lh_preg->persons[pcnt ].date_cnt = dcnt ,stat =
     alterlist (lh_preg->persons[pcnt ].dates ,dcnt ) ,lh_preg->persons[pcnt ].dates[dcnt ].preg_date
      = pat.ep_dt_tm
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf33 (grp_num )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0033" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"0033" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"0033" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0033" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0033" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0033" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata (build ("MU_EC_0033_2019." ,grp_num ) ,br_filters->provider_attribution ,
   "NQF2019_0033" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf33 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE date_iter = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";exclusion check Hospice Care: Hospice.Has Hospice" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0033: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0033: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0033: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0033: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0033: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0033: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0033: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0033: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0033: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";get Exclusion : Xray Results with Pregnancy Test Exclusion" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE (pat.active_ind = 1 )
    AND expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[iter1
     ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind ,0 ,lh_ep_reply->persons[iter1 ].
     special_group ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: XRAY_RESULT: L6" ,
    "NQF2019_0033: XRAY_RESULT: L7" ,
    "NQF2019_0033: XRAY_RESULT: E6" ,
    "NQF2019_0033: ISO_MED: M5" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0 ,
    person_pos = 0
   HEAD pat.person_id
    pos = locateval (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ) ,person_pos = locateval (iter2 ,1 ,size (lh_preg->persons ,5 ) ,pat
     .person_id ,lh_preg->persons[iter2 ].person_id )
   HEAD pat.ep_dt_tm
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     IF ((person_pos > 0 )
     AND (lh_preg->persons[person_pos ].date_cnt > 0 ) )
      FOR (date_iter = 1 TO lh_preg->persons[person_pos ].date_cnt )
       IF ((pat.ep_dt_tm >= cnvtdatetime (lh_preg->persons[person_pos ].dates[date_iter ].preg_date
        ) )
       AND (pat.ep_dt_tm <= datetimeadd (cnvtdatetime (lh_preg->persons[person_pos ].dates[date_iter
         ].preg_date ) ,7 ) ) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos
        ].outcome = "Denominator Exclusion"
       ENDIF
      ENDFOR
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf33 (null )
  SET stat = initrec (lh_preg )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome: CHLAMYDIA SCREENING" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0033: CHLAMYDIA_RESULT: E7" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome
     = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes - Chlamydia Screening for Women" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf34 (null ) = null
 DECLARE getpopulation_nqf34 (null ) = null
 DECLARE getattribution_nqf34 (null ) = null
 DECLARE getoutcome_nqf34 (null ) = null
 DECLARE getexclusion_nqf34 (null ) = null
 SUBROUTINE  getresults_nqf34 (null )
  CALL geteprfilter ("34" )
  CALL getpopulation_nqf34 (0 )
  CALL getattribution_nqf34 (0 )
  CALL getexclusion_nqf34 (0 )
  CALL getoutcome_nqf34 (0 )
  CALL summaryreport ("MU_EC_0034_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf34 (null )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  DECLARE p_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE e_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE p_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE e_batch_size = i4 WITH constant (10 ) ,protect
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0034: A1" ,
    "POPULATION: NQF2019_0034: B1" ,
    "POPULATION: NQF2019_0034: C1" ,
    "POPULATION: NQF2019_0034: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("50,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("75,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    p_total_size = p_batch_size ,
    stat = alterlist (lh_ep_reply->persons ,p_total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((p_total_size < personcnt ) ) p_total_size = (p_total_size + p_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons ,p_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[
    personcnt ].outcome = "Not Met, Not Done" ,lh_ep_reply->person_cnt = personcnt ,encntrcnt = 0 ,
    e_total_size = 10 ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((encntrcnt > e_total_size ) ) e_total_size = (e_total_size + e_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntr_cnt = encntrcnt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf34 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0034" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0034" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0034" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0034" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0034" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0034_2019" ,br_filters->provider_attribution ,"NQF2019_0034" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf34 (null )
  CALL lhprint (";get outcome" )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";FOBT check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name = "NQF2019_0034: FOBT_RESULT: E3" )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome
     = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Sig check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_end_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0034: FLEX_SIG_PROC: A4" ,
   "NQF2019_0034: FLEX_SIG_PROC: B4" ,
   "NQF2019_0034: FLEX_SIG_PROC: C4" ,
   "NQF2019_0034: FLEX_SIG_PROC: D4" ,
   "NQF2019_0034: FLEX_SIG_PROC: L4" ,
   "NQF2019_0034: FLEX_SIG_PROC: L5" ,
   "NQF2019_0034: FLEX_SIG_PROC: E4" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: A6" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: B6" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: C6" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: D6" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: E6" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: L7" ,
   "NQF2019_0034: CT_COLONOGRAPHY_PROC: L8" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    person_diff = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    person_diff = lhgetdatetimedifference (cnvtdatetime (end_extract_dt_tm ) ,pat.ep_end_dt_tm ,"Y"
     ) ,
    IF ((pos > 0 )
    AND (person_diff BETWEEN 0 AND 5 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Colonoscopy check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_end_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0034: COLONOSCOPY_PROC: A5" ,
   "NQF2019_0034: COLONOSCOPY_PROC: B5" ,
   "NQF2019_0034: COLONOSCOPY_PROC: C5" ,
   "NQF2019_0034: COLONOSCOPY_PROC: D5" ,
   "NQF2019_0034: COLONOSCOPY_PROC: F5" ,
   "NQF2019_0034: COLONOSCOPY_PROC: L5" ,
   "NQF2019_0034: COLONOSCOPY_PROC: L6" ,
   "NQF2019_0034: COLONOSCOPY_PROC: E5" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    person_diff = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    person_diff = lhgetdatetimedifference (cnvtdatetime (end_extract_dt_tm ) ,pat.ep_end_dt_tm ,"Y"
     ) ,
    IF ((pos > 0 )
    AND (person_diff BETWEEN 0 AND 10 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";FIT DNA Result check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name = "NQF2019_0034: FIT_DNA_RESULT: E7" )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    person_diff = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id ) ,person_diff = lhgetdatetimedifference (cnvtdatetime (
      end_extract_dt_tm ) ,pat.ep_end_dt_tm ,"Y" ) ,
    IF ((pos > 0 )
    AND (person_diff BETWEEN 0 AND 3 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->
     persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf34 (null )
  CALL lhprint (";get exclusions" )
  CALL beg_time (0 )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";problem exclusion check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
    persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0034: TOTAL_COLECTOMY_PROC: A1" ,
   "NQF2019_0034: TOTAL_COLECTOMY_PROC: B1" ,
   "NQF2019_0034: TOTAL_COLECTOMY_PROC: C1" ,
   "NQF2019_0034: TOTAL_COLECTOMY_PROC: D1" ,
   "NQF2019_0034: TOTAL_COLECTOMY_PROC: E1" ,
   "NQF2019_0034: MALIGNANT_COLON: F2" ,
   "NQF2019_0034: MALIGNANT_COLON: G2" ,
   "NQF2019_0034: MALIGNANT_COLON: H2" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[enc_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0034: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0034: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0034: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0034: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0034: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[enc_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0034: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0034: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0034: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0034: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0034: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf38 (null ) = null
 DECLARE getpopulation_nqf38 (null ) = null
 DECLARE getattribution_nqf38 (null ) = null
 DECLARE getoutcome_nqf38 (null ) = null
 DECLARE getexclusion_nqf38 (null ) = null
 SUBROUTINE  getresults_nqf38 (null )
  SET br_filters->provider_attribution = getproviderattribution ("38" )
  CALL geteprfilter ("38" )
  CALL getpopulation_nqf38 (0 )
  CALL getattribution_nqf38 (0 )
  CALL getexclusion_nqf38 (0 )
  CALL getoutcome_nqf38 (0 )
  CALL summaryreport ("MU_EC_0038_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf38 (null )
  CALL lhprint (";Initial Population Query Child Immuno" )
  CALL beg_time (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0038: A1" ,
    "POPULATION: NQF2019_0038: B1" ,
    "POPULATION: NQF2019_0038: C1" ,
    "POPULATION: NQF2019_0038: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (cnvtlookbehind ("2,Y" ,cnvtdatetime (end_extract_dt_tm ) ) >= nullcheck (p.birth_dt_tm ,
     null ,nullind (p.birth_dt_tm ) ) )
    AND (cnvtlookbehind ("2,Y" ,cnvtdatetime (beg_extract_dt_tm ) ) <= nullcheck (p.birth_dt_tm ,
     null ,nullind (p.birth_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    total_size = 20000 ,
    batch_size = 5000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[
    personcnt ].outcome = "Not Met, Not Done"
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf38 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0038" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"0038" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"0038" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0038" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0038_2019" ,br_filters->provider_attribution ,"NQF2019_0038" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf38 (null )
  CALL lhprint (";get outcome Child Immuno" )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL beg_time (0 )
  SELECT INTO "nl:"
   enc_date = format (pat.ep_dt_tm ,"MM/DD/YY ;;D" )
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm BETWEEN datetimeadd (cnvtdatetime (beg_extract_dt_tm ) ,- (730 ) ) AND
   cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = ambqry.d_query_id )
   AND (ambqry.query_name IN ("NQF2019_0038: DTAP_IMM: E1" ,
   "NQF2019_0038: DTAP_PROC: A2" ,
   "NQF2019_0038: DTAP_PROC: B2" ,
   "NQF2019_0038: DTAP_PROC: C2" ,
   "NQF2019_0038: DTAP_ALERT: N3" ,
   "NQF2019_0038: DTAP_ALERT: E3" ,
   "NQF2019_0038: DTAP_ALERT: H3" ,
   "NQF2019_0038: DTAP_PROB: F4" ,
   "NQF2019_0038: DTAP_PROB: G4" ,
   "NQF2019_0038: DTAP_PROB: H4" ,
   "NQF2019_0038: IPV_IMM: E1" ,
   "NQF2019_0038: IPV_PROC: A2" ,
   "NQF2019_0038: IPV_PROC: B2" ,
   "NQF2019_0038: IPV_PROC: C2" ,
   "NQF2019_0038: IPV_ALERT: N3" ,
   "NQF2019_0038: IPV_ALERT: E3" ,
   "NQF2019_0038: IPV_ALERT: H3" ,
   "NQF2019_0038: MMR_IMM: E1" ,
   "NQF2019_0038: MMR_PROC: A2" ,
   "NQF2019_0038: MMR_PROC: B2" ,
   "NQF2019_0038: MMR_PROC: B2" ,
   "NQF2019_0038: MMR_PROC: C2" ,
   "NQF2019_0038: MMR_ALERT: N3" ,
   "NQF2019_0038: MMR_ALERT: E3" ,
   "NQF2019_0038: MMR_ALERT: H3" ,
   "NQF2019_0038: MMR_PROB: F4" ,
   "NQF2019_0038: MMR_PROB: G4" ,
   "NQF2019_0038: MMR_PROB: H4" ,
   "NQF2019_0038: MEASLES_PROB: F5" ,
   "NQF2019_0038: MEASLES_PROB: G5" ,
   "NQF2019_0038: MEASLES_PROB: H5" ,
   "NQF2019_0038: MUMPS_PROB: F6" ,
   "NQF2019_0038: MUMPS_PROB: G6" ,
   "NQF2019_0038: MUMPS_PROB: H6" ,
   "NQF2019_0038: RUBELLA_PROB: F7" ,
   "NQF2019_0038: RUBELLA_PROB: G7" ,
   "NQF2019_0038: RUBELLA_PROB: H7" ,
   "NQF2019_0038: MUMPS_RESULT: E8" ,
   "NQF2019_0038: MEASLES_RESULT: E9" ,
   "NQF2019_0038: RUBELLA_RESULT: E10" ,
   "NQF2019_0038: MUMPS_RESULT: E11" ,
   "NQF2019_0038: MEASLES_RESULT: E12" ,
   "NQF2019_0038: RUBELLA_RESULT: E13" ,
   "NQF2019_0038: HIB_IMM: E1" ,
   "NQF2019_0038: HIB_PROC: A2" ,
   "NQF2019_0038: HIB_PROC: B2" ,
   "NQF2019_0038: HIB_PROC: C2" ,
   "NQF2019_0038: HIB_ALERT: N3" ,
   "NQF2019_0038: HIB_ALERT: E3" ,
   "NQF2019_0038: HIB_ALERT: H3" ,
   "NQF2019_0038: HEPB_IMM: E1" ,
   "NQF2019_0038: HEPB_PROC: A2" ,
   "NQF2019_0038: HEPB_PROC: B2" ,
   "NQF2019_0038: HEPB_PROC: B2" ,
   "NQF2019_0038: HEPB_PROC: C2" ,
   "NQF2019_0038: HEPB_ALERT: N3" ,
   "NQF2019_0038: HEPB_ALERT: E3" ,
   "NQF2019_0038: HEPB_ALERT: H3" ,
   "NQF2019_0038: HEPB_PROB: F4" ,
   "NQF2019_0038: HEPB_PROB: G4" ,
   "NQF2019_0038: HEPB_PROB: H4" ,
   "NQF2019_0038: HEPB_SURF: E2" ,
   "NQF2019_0038: VZV_IMM: E1" ,
   "NQF2019_0038: VZV_PROC: A2" ,
   "NQF2019_0038: VZV_PROC: B2" ,
   "NQF2019_0038: VZV_PROC: B2" ,
   "NQF2019_0038: VZV_PROC: C2" ,
   "NQF2019_0038: VZV_ALERT: N3" ,
   "NQF2019_0038: VZV_ALERT: E3" ,
   "NQF2019_0038: VZV_ALERT: H3" ,
   "NQF2019_0038: VZV_PROB: F4" ,
   "NQF2019_0038: VZV_PROB: G4" ,
   "NQF2019_0038: VZV_PROB: H4" ,
   "NQF2019_0038: VZV_RESULT: E5" ,
   "NQF2019_0038: VZV_RESULT: E6" ,
   "NQF2019_0038: PCV_IMM: E1" ,
   "NQF2019_0038: PCV_PROC: A2" ,
   "NQF2019_0038: PCV_PROC: B2" ,
   "NQF2019_0038: PCV_PROC: C2" ,
   "NQF2019_0038: PCV_ALERT: N3" ,
   "NQF2019_0038: PCV_ALERT: E3" ,
   "NQF2019_0038: PCV_ALERT: H3" ,
   "NQF2019_0038: HEPA_IMM: E1" ,
   "NQF2019_0038: HEPA_ANTI: E1" ,
   "NQF2019_0038: HEPA_PROC: A2" ,
   "NQF2019_0038: HEPA_PROC: B2" ,
   "NQF2019_0038: HEPA_PROC: B2" ,
   "NQF2019_0038: HEPA_PROC: C2" ,
   "NQF2019_0038: HEPA_ALERT: N3" ,
   "NQF2019_0038: HEPA_ALERT: E3" ,
   "NQF2019_0038: HEPA_ALERT: H3" ,
   "NQF2019_0038: HEPA_PROB: F4" ,
   "NQF2019_0038: HEPA_PROB: G4" ,
   "NQF2019_0038: HEPA_PROB: H4" ,
   "NQF2019_0038: HEPA_RESULT: E5" ,
   "NQF2019_0038: ROTA_IMM_2: E1" ,
   "NQF2019_0038: ROTA_PROC_2: A2" ,
   "NQF2019_0038: ROTA_PROC_2: B2" ,
   "NQF2019_0038: ROTA_PROC_2: C2" ,
   "NQF2019_0038: ROTA_IMM_3: E1" ,
   "NQF2019_0038: ROTA_PROC_3: A2" ,
   "NQF2019_0038: ROTA_PROC_3: B2" ,
   "NQF2019_0038: ROTA_PROC_3: C2" ,
   "NQF2019_0038: ROTA_ALERT: E3" ,
   "NQF2019_0038: ROTA_ALERT: H3" ,
   "NQF2019_0038: ROTA_ALERT: N3" ,
   "NQF2019_0038: ROTA_IMM_DX: F1" ,
   "NQF2019_0038: ROTA_IMM_DX: G1" ,
   "NQF2019_0038: ROTA_IMM_DX: H1" ,
   "NQF2019_0038: INFLU_IMM: E1" ,
   "NQF2019_0038: INFLU_PROC: A2" ,
   "NQF2019_0038: INFLU_PROC: B2" ,
   "NQF2019_0038: INFLU_PROC: B2" ,
   "NQF2019_0038: INFLU_PROC: C2" ,
   "NQF2019_0038: INFLU_ALERT: N3" ,
   "NQF2019_0038: INFLU_ALERT: E3" ,
   "NQF2019_0038: INFLU_ALERT: H3" ,
   "NQF2019_0038: INFLU_PROB: F4" ,
   "NQF2019_0038: INFLU_PROB: G4" ,
   "NQF2019_0038: INFLU_PROB: H4" ) )
   AND (ambqry.active_ind = 1 )
   ORDER BY pat.person_id ,
    enc_date ,
    ambqry.query_name
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,dtap_cnt = 0 ,ipv_cnt = 0 ,mmr_cnt = 0 ,hib_cnt = 0 ,hepb_cnt = 0 ,
    vzv_cnt = 0 ,pcv_cnt = 0 ,hepa_cnt = 0 ,rota2_cnt = 0 ,rota3_cnt = 0 ,influ_cnt = 0 ,dtap_prob =
    0 ,ipv_prob = 0 ,mmr_prob = 0 ,hib_prob = 0 ,hepb_prob = 0 ,vzv_prob = 0 ,pcv_prob = 0 ,
    hepa_prob = 0 ,rota_prob = 0 ,influ_prob = 0 ,measles_prob = 0 ,mumps_prob = 0 ,rub_prob = 0
   HEAD enc_date
    dtap_ind = 0 ,ipv_ind = 0 ,mmr_ind = 0 ,hib_ind = 0 ,hepb_ind = 0 ,vzv_ind = 0 ,pcv_ind = 0 ,
    hepa_ind = 0 ,rota2_ind = 0 ,rota3_ind = 0 ,influ_ind = 0
   HEAD ambqry.query_name
    CASE (ambqry.query_name )
     OF "NQF2019_0038: DTAP_ALERT: N3" :
     OF "NQF2019_0038: DTAP_ALERT: E3" :
     OF "NQF2019_0038: DTAP_ALERT: H3" :
     OF "NQF2019_0038: DTAP_PROB: F4" :
     OF "NQF2019_0038: DTAP_PROB: G4" :
     OF "NQF2019_0038: DTAP_PROB: H4" :
      dtap_prob = 1
     OF "NQF2019_0038: IPV_ALERT: N3" :
     OF "NQF2019_0038: IPV_ALERT: E3" :
     OF "NQF2019_0038: IPV_ALERT: H3" :
      ipv_prob = 1
     OF "NQF2019_0038: MMR_ALERT: N3" :
     OF "NQF2019_0038: MMR_ALERT: E3" :
     OF "NQF2019_0038: MMR_ALERT: H3" :
     OF "NQF2019_0038: MMR_PROB: F4" :
     OF "NQF2019_0038: MMR_PROB: G4" :
     OF "NQF2019_0038: MMR_PROB: H4" :
      mmr_prob = 1
     OF "NQF2019_0038: MEASLES_PROB: F5" :
     OF "NQF2019_0038: MEASLES_PROB: G5" :
     OF "NQF2019_0038: MEASLES_PROB: H5" :
     OF "NQF2019_0038: MEASLES_RESULT: E9" :
     OF "NQF2019_0038: MEASLES_RESULT: E12" :
      measles_prob = 1
     OF "NQF2019_0038: MUMPS_PROB: F6" :
     OF "NQF2019_0038: MUMPS_PROB: G6" :
     OF "NQF2019_0038: MUMPS_PROB: H6" :
     OF "NQF2019_0038: MUMPS_RESULT: E8" :
     OF "NQF2019_0038: MUMPS_RESULT: E11" :
      mumps_prob = 1
     OF "NQF2019_0038: RUBELLA_PROB: F7" :
     OF "NQF2019_0038: RUBELLA_PROB: G7" :
     OF "NQF2019_0038: RUBELLA_PROB: H7" :
     OF "NQF2019_0038: RUBELLA_RESULT: E10" :
     OF "NQF2019_0038: RUBELLA_RESULT: E13" :
      rub_prob = 1
     OF "NQF2019_0038: HIB_ALERT: N3" :
     OF "NQF2019_0038: HIB_ALERT: E3" :
     OF "NQF2019_0038: HIB_ALERT: H3" :
      hib_prob = 1
     OF "NQF2019_0038: HEPB_ALERT: N3" :
     OF "NQF2019_0038: HEPB_ALERT: E3" :
     OF "NQF2019_0038: HEPB_ALERT: H3" :
     OF "NQF2019_0038: HEPB_PROB: F4" :
     OF "NQF2019_0038: HEPB_PROB: G4" :
     OF "NQF2019_0038: HEPB_PROB: H4" :
      hepb_prob = 1
     OF "NQF2019_0038: VZV_ALERT: N3" :
     OF "NQF2019_0038: VZV_ALERT: E3" :
     OF "NQF2019_0038: VZV_ALERT: H3" :
     OF "NQF2019_0038: VZV_PROB: F4" :
     OF "NQF2019_0038: VZV_PROB: G4" :
     OF "NQF2019_0038: VZV_PROB: H4" :
     OF "NQF2019_0038: VZV_RESULT: E5" :
     OF "NQF2019_0038: VZV_RESULT: E6" :
      vzv_prob = 1
     OF "NQF2019_0038: PCV_ALERT: N3" :
     OF "NQF2019_0038: PCV_ALERT: E3" :
     OF "NQF2019_0038: PCV_ALERT: H3" :
      pcv_prob = 1
     OF "NQF2019_0038: HEPA_ALERT: N3" :
     OF "NQF2019_0038: HEPA_ALERT: E3" :
     OF "NQF2019_0038: HEPA_ALERT: H3" :
     OF "NQF2019_0038: HEPA_PROB: F4" :
     OF "NQF2019_0038: HEPA_PROB: G4" :
     OF "NQF2019_0038: HEPA_PROB: H4" :
     OF "NQF2019_0038: HEPA_RESULT: E5" :
     OF "NQF2019_0038: HEPA_ANTI: E1" :
      hepa_prob = 1
     OF "NQF2019_0038: ROTA_ALERT: E3" :
     OF "NQF2019_0038: ROTA_ALERT: N3" :
     OF "NQF2019_0038: ROTA_ALERT: H3" :
     OF "NQF2019_0038: ROTA_IMM_DX: F1" :
     OF "NQF2019_0038: ROTA_IMM_DX: H1" :
     OF "NQF2019_0038: ROTA_IMM_DX: G1" :
      rota_prob = 1
     OF "NQF2019_0038: INFLU_ALERT: N3" :
     OF "NQF2019_0038: INFLU_ALERT: E3" :
     OF "NQF2019_0038: INFLU_ALERT: H3" :
     OF "NQF2019_0038: INFLU_PROB: F4" :
     OF "NQF2019_0038: INFLU_PROB: G4" :
     OF "NQF2019_0038: INFLU_PROB: H4" :
      influ_prob = 1
    ENDCASE
    ,
    CASE (ambqry.query_name )
     OF "NQF2019_0038: DTAP_IMM: E1" :
     OF "NQF2019_0038: DTAP_PROC: A2" :
     OF "NQF2019_0038: DTAP_PROC: B2" :
     OF "NQF2019_0038: DTAP_PROC: C2" :
      dtap_ind = 1
     OF "NQF2019_0038: IPV_IMM: E1" :
     OF "NQF2019_0038: IPV_PROC: A2" :
     OF "NQF2019_0038: IPV_PROC: B2" :
     OF "NQF2019_0038: IPV_PROC: C2" :
      ipv_ind = 1
     OF "NQF2019_0038: MMR_IMM: E1" :
     OF "NQF2019_0038: MMR_PROC: A2" :
     OF "NQF2019_0038: MMR_PROC: B2" :
     OF "NQF2019_0038: MMR_PROC: C2" :
      mmr_ind = 1
     OF "NQF2019_0038: HIB_IMM: E1" :
     OF "NQF2019_0038: HIB_PROC: A2" :
     OF "NQF2019_0038: HIB_PROC: B2" :
     OF "NQF2019_0038: HIB_PROC: C2" :
      hib_ind = 1
     OF "NQF2019_0038: HEPB_IMM: E1" :
     OF "NQF2019_0038: HEPB_SURF: E2" :
     OF "NQF2019_0038: HEPB_PROC: A2" :
     OF "NQF2019_0038: HEPB_PROC: B2" :
     OF "NQF2019_0038: HEPB_PROC: C2" :
      hepb_ind = 1
     OF "NQF2019_0038: VZV_IMM: E1" :
     OF "NQF2019_0038: VZV_PROC: A2" :
     OF "NQF2019_0038: VZV_PROC: B2" :
     OF "NQF2019_0038: VZV_PROC: C2" :
      vzv_ind = 1
     OF "NQF2019_0038: PCV_IMM: E1" :
     OF "NQF2019_0038: PCV_PROC: A2" :
     OF "NQF2019_0038: PCV_PROC: B2" :
     OF "NQF2019_0038: PCV_PROC: C2" :
      pcv_ind = 1
     OF "NQF2019_0038: HEPA_IMM: E1" :
     OF "NQF2019_0038: HEPA_PROC: A2" :
     OF "NQF2019_0038: HEPA_PROC: B2" :
     OF "NQF2019_0038: HEPA_PROC: C2" :
      hepa_ind = 1
     OF "NQF2019_0038: ROTA_IMM_2: E1" :
     OF "NQF2019_0038: ROTA_PROC_2: A2" :
     OF "NQF2019_0038: ROTA_PROC_2: B2" :
     OF "NQF2019_0038: ROTA_PROC_2: C2" :
      rota2_ind = 1
     OF "NQF2019_0038: ROTA_IMM_3: E1" :
     OF "NQF2019_0038: ROTA_PROC_3: A2" :
     OF "NQF2019_0038: ROTA_PROC_3: B2" :
     OF "NQF2019_0038: ROTA_PROC_3: C2" :
      rota3_ind = 1
     OF "NQF2019_0038: INFLU_IMM: E1" :
     OF "NQF2019_0038: INFLU_PROC: A2" :
     OF "NQF2019_0038: INFLU_PROC: B2" :
     OF "NQF2019_0038: INFLU_PROC: C2" :
      influ_ind = 1
    ENDCASE
   FOOT  enc_date
    IF ((dtap_ind = 1 ) ) dtap_cnt = (dtap_cnt + 1 )
    ENDIF
    ,
    IF ((ipv_ind = 1 ) ) ipv_cnt = (ipv_cnt + 1 )
    ENDIF
    ,
    IF ((mmr_ind = 1 ) ) mmr_cnt = (mmr_cnt + 1 )
    ENDIF
    ,
    IF ((hib_ind = 1 ) ) hib_cnt = (hib_cnt + 1 )
    ENDIF
    ,
    IF ((hepb_ind = 1 ) ) hepb_cnt = (hepb_cnt + 1 )
    ENDIF
    ,
    IF ((vzv_ind = 1 ) ) vzv_cnt = (vzv_cnt + 1 )
    ENDIF
    ,
    IF ((pcv_ind = 1 ) ) pcv_cnt = (pcv_cnt + 1 )
    ENDIF
    ,
    IF ((hepa_ind = 1 ) ) hepa_cnt = (hepa_cnt + 1 )
    ENDIF
    ,
    IF ((rota2_ind = 1 ) ) rota2_cnt = (rota2_cnt + 1 )
    ENDIF
    ,
    IF ((rota3_ind = 1 ) ) rota3_cnt = (rota3_cnt + 1 )
    ENDIF
    ,
    IF ((influ_ind = 1 ) ) influ_cnt = (influ_cnt + 1 )
    ENDIF
   FOOT  pat.person_id
    IF ((measles_prob = 1 )
    AND (mumps_prob = 1 )
    AND (rub_prob = 1 ) ) mmr_prob = 1
    ENDIF
    ,
    IF ((((dtap_cnt >= 4 ) ) OR ((dtap_prob = 1 ) ))
    AND (((ipv_cnt >= 3 ) ) OR ((ipv_prob = 1 ) ))
    AND (((mmr_cnt >= 1 ) ) OR ((mmr_prob = 1 ) ))
    AND (((hib_cnt >= 3 ) ) OR ((hib_prob = 1 ) ))
    AND (((hepb_cnt >= 3 ) ) OR ((hepb_prob = 1 ) ))
    AND (((vzv_cnt >= 1 ) ) OR ((vzv_prob = 1 ) ))
    AND (((pcv_cnt >= 4 ) ) OR ((pcv_prob = 1 ) ))
    AND (((hepa_cnt >= 1 ) ) OR ((hepa_prob = 1 ) ))
    AND (((rota2_cnt >= 2 ) ) OR ((((rota3_cnt >= 3 ) ) OR ((rota_prob = 1 ) )) ))
    AND (((influ_cnt >= 2 ) ) OR ((influ_prob = 1 ) )) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf38 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0038: HOSPICE_CARE_AMB: A2" ,
    "NQF2019_0038: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0038: HOSPICE_CARE_AMB: D3" ,
    "NQF2019_0038: HOSPICE_CARE_AMB: E3" ,
    "NQF2019_0038: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0038: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0038: HOSPICE_CARE_AMB: A2" ,
     "NQF2019_0038: HOSPICE_CARE_AMB: D2" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0038: HOSPICE_CARE_AMB: D3" ,
     "NQF2019_0038: HOSPICE_CARE_AMB: E3" ) ) )
      IF ((((pat.ep_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
      ) out_flg = 1
      ENDIF
     ENDIF
     ,
     IF ((out_flg = 1 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
      person_pos ].outcome = "Denominator Exclusion"
     ENDIF
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 DECLARE getpopulation_nqf41 (null ) = null
 DECLARE getattribution_nqf41 (null ) = null
 DECLARE getdenom_nqf41 (null ) = null
 DECLARE getoutcome_nqf41 (null ) = null
 DECLARE getresults_nqf41 (null ) = null
 DECLARE getexceptions_nqf41 (null ) = null
 SUBROUTINE  getresults_nqf41 (null )
  CALL setfluseason (0 )
  CALL geteprfilter ("41" )
  CALL getpopulation_nqf41 (0 )
  CALL getattribution_nqf41 (0 )
  CALL getdenom_nqf41 (0 )
  CALL getoutcome_nqf41 (0 )
  CALL getexceptions_nqf41 (null )
  CALL summaryreport ("MU_EC_0041_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf41 (null )
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE batch_size = i4 WITH constant (10000 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";initial population" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0041" )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("6,M" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.encntr_id ,
    qry.query_name
   HEAD REPORT
    stat = initrec (lh_bill_encntr_date ) ,
    personcnt = 0 ,
    total_size = 20000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    encntrcnt = 0 ,personcnt = (personcnt + 1 ) ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->person_cnt = personcnt ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id
    ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].
    outcome_ind = 4 ,lh_ep_reply->persons[personcnt ].outcome = "IPP Only"
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,lh_ep_reply->persons[personcnt ].encntr_cnt = encntrcnt ,stat =
    alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,lh_ep_reply->persons[personcnt
    ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf41 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_SERV_GROUP_COUNSEL" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_SERVICES_OTHER" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_SERV_INDIV_COUNSEL" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"0041" ,"'CPT4','HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SER_NURSE_FAC_ENC" ,"0041" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0041" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("FACE_TO_FACE_INTERACTION" ,"0041" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PT_PROV_INTERACT_ENC" ,"0041" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HEMODIALYSIS_PROC" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PERITONEAL_DIAL_PROC" ,"0041" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0041_2019" ,br_filters->provider_attribution ,"NQF2019_0041" )
 END ;Subroutine
 SUBROUTINE  getdenom_nqf41 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";retrieve flu encounters" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_41 ) AND cnvtdatetime (
     end_extract_dt_tm_41 ) )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0041: INFLU_ENC: A1" ,
    "NQF2019_0041: INFLU_ENC: B1" ,
    "NQF2019_0041: INFLU_ENC: C1" ,
    "NQF2019_0041: INFLU_ENC: D1" ,
    "NQF2019_0041: DIALYSIS_PROC: A2" ,
    "NQF2019_0041: DIALYSIS_PROC: B2" ,
    "NQF2019_0041: DIALYSIS_PROC: C2" ,
    "NQF2019_0041: DIALYSIS_PROC: D2" ) ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   HEAD pat.encntr_id
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 0 ,lh_ep_reply->persons[pos ].outcome
     = "Not Met, Not Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf41 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE flu_evnt_beg_dt = dq8 WITH constant (datetimeadd (cnvtdatetime (beg_extract_dt_tm_41 ) ,- (
    61 ) ) ) ,protect
  CALL lhprint (";retrieve flu events" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (flu_evnt_beg_dt ) AND cnvtdatetime (end_extract_dt_tm_41
     ) )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0041: INFLU_VACCINE_PROC: A3" ,
    "NQF2019_0041: INFLU_VACCINE_PROC: B3" ,
    "NQF2019_0041: INFLU_VACCINE_PROC: C3" ,
    "NQF2019_0041: INFLU_VACCINE_PROC: L3" ,
    "NQF2019_0041: INFLU_VACCINE_PROC: L4" ,
    "NQF2019_0041: INFLU_VACCINE_PROC: E3" ,
    "NQF2019_0041: INFLU_VACCINE_IMM: E4" ,
    "NQF2019_0041: INFLU_VACCINE_RESULT: L5" ,
    "NQF2019_0041: INFLU_VACCINE_RESULT: L6" ,
    "NQF2019_0041: INFLU_VACCINE_RESULT: E5" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome
     = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getexceptions_nqf41 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE flu_evnt_beg_dt = dq8 WITH constant (datetimeadd (cnvtdatetime (beg_extract_dt_tm_41 ) ,- (
    61 ) ) ) ,protect
  CALL lhprint (";retrieve flu events" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (flu_evnt_beg_dt ) AND cnvtdatetime (end_extract_dt_tm_41
     ) )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0041: INFLU_VACCINE_DECLINED: L8" ,
    "NQF2019_0041: INFLU_VACCINE_DECLINED: L9" ,
    "NQF2019_0041: INFLU_VACCINE_DECLINED: E8" ,
    "NQF2019_0041: NEGATION: E9" ,
    "NQF2019_0041: NEGATION: E10" ,
    "NQF2019_0041: INFLU_VACCINE_PROC_CND: Q16" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exception"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";retrieve flu exceptions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm_41 ) )
    AND (((pat.ep_end_dt_tm >= cnvtdatetime (beg_extract_dt_tm_41 ) ) ) OR ((pat.ep_end_dt_tm = null
    ) )) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0041: ALLERGY_ALERT: L12" ,
    "NQF2019_0041: ALLERGY_ALERT: L13" ,
    "NQF2019_0041: ALLERGY_ALERT: E12" ,
    "NQF2019_0041: ALLERGY_ALERT: L14" ,
    "NQF2019_0041: ALLERGY_ALERT: L15" ,
    "NQF2019_0041: ALLERGY_ALERT: E14" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exception"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";retrieve flu allergies" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm_41 ) )
    AND (((pat.ep_end_dt_tm >= cnvtdatetime (beg_extract_dt_tm_41 ) ) ) OR ((pat.ep_end_dt_tm = null
    ) )) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0041: ALLERGY_ALERT: N12" ,
    "NQF2019_0041: ALLERGY_ALERT: N13" ,
    "NQF2019_0041: ALLERGY_ALERT: N14" ,
    "NQF2019_0041: NEGATION: N13" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exception"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Allergy problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm_41 ) )
    AND (((pat.ep_end_dt_tm >= cnvtdatetime (beg_extract_dt_tm_41 ) ) ) OR ((pat.ep_end_dt_tm = null
    ) )) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0041: ALLERGY_PROBLEM: F11" ,
    "NQF2019_0041: ALLERGY_PROBLEM: H11" ,
    "NQF2019_0041: ALLERGY_PROBLEM: H12" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exception"
    ENDIF
   WITH nocounter ,orahint ("index(EVNT XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 DECLARE getresults_nqf55 (null ) = null
 DECLARE getpopulation_nqf55 (null ) = null
 DECLARE getattribution_nqf55 ((measure_name = vc ) ) = null
 DECLARE getexclusion_nqf55 (null ) = null
 DECLARE getoutcome_nqf55 (null ) = null
 SUBROUTINE  getresults_nqf55 (null )
  SET br_filters->provider_attribution = getproviderattribution ("55" )
  CALL geteprfilter ("55" )
  CALL getpopulation_nqf55 (0 )
  CALL getattribution_nqf55 ("MU_EC_0055_2019" )
  CALL getexclusion_nqf55 (0 )
  CALL getoutcome_nqf55 (0 )
  CALL summaryreport ("MU_EC_0055_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf55 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE person_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE encntr_batch_size = i4 WITH constant (10 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query - qualifying encounters" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0055: A1" ,
    "POPULATION: NQF2019_0055: B1" ,
    "POPULATION: NQF2019_0055: C1" ,
    "POPULATION: NQF2019_0055: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("75,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((mod (personcnt ,person_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons ,((
      personcnt + person_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].person_id =
    pop.person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,
    encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((mod (encntrcnt ,encntr_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons[
      personcnt ].encntrs ,((encntrcnt + encntr_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,lh_ep_reply->persons[
    personcnt ].encntr_cnt = encntrcnt
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt ) ,
    lh_ep_reply->person_cnt = personcnt
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Initial Population Query - qualifying diabetes diagnosis" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0055: DIABETES: F1" ,
    "NQF2019_0055: DIABETES: G1" ,
    "NQF2019_0055: DIABETES: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[enc_iter ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     IF ((qry.query_name = "NQF2019_0055: DIABETES: H1" ) )
      IF ((lh_ep_reply->persons[pos ].exclude_ind != 0 )
      AND (checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.end_effective_dt_tm ) = 1 )
      AND (pat.prob_life_cycle_status_cd = active_cd ) ) lh_ep_reply->persons[pos ].exclude_ind = 0
      ENDIF
     ELSE
      IF ((pos > 0 )
      AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
       IF ((diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) lh_ep_reply
        ->persons[pos ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL removedummyitem (lh_ep_reply )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf55 (measure_name )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0055" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0055" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0055" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0055" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0055" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("OPHTHALMOLOGICAL_SERVICES" ,"0055" ,"'CPT4'" ,"1=1" )
  CALL getepdata (measure_name ,br_filters->provider_attribution ,"NQF2019_0055" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf55 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0055: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0055: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0055: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0055: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0055: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[enc_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0055: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0055: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0055: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0055: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0055: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf55 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (
   ";get outcome - had a retinal/dilated eye exam nagative result within 12 months before measurement start"
   )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
    persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm < cnvtdatetime (beg_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name = "NQF2019_0055: SECONDARY_VAL_SET: E3" )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,person_diff = lhgetdatetimedifference (cnvtdatetime (
      beg_extract_dt_tm ) ,pat.ep_dt_tm ,"Y" ) ,
    IF ((person_pos > 0 )
    AND (((person_diff = 0 ) ) OR ((person_diff = 1 ) )) ) lh_ep_reply->persons[person_pos ].
     outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (
    ";After get outcome - had a retinal/dilated eye exam nagative result within 12 months before measurement start"
    )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (
   ";get outcome - had a retinal/dilated eye exam nagative result during the measurement period" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
    persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0055: RETINAL_EYE_EXAM: E4" ,
   "NQF2019_0055: RETINAL_EYE_EXAM: A4" ,
   "NQF2019_0055: RETINAL_EYE_EXAM: D4" ,
   "NQF2019_0055: RETINAL_EYE_EXAM: L4" ,
   "NQF2019_0055: RETINAL_EYE_EXAM: L5" ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,
    IF ((lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[person_pos ].
     outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get outcome - had a retinal/dilated eye exam during the measurement period" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf59 (null ) = null
 DECLARE getpopulation_nqf_diabetes ((measure_name = vc ) ) = null
 DECLARE getexclusion_nqf59 (null ) = null
 DECLARE getattribution_nqf59 ((measure_name = vc ) ) = null
 DECLARE getoutcome_nqf59 (null ) = null
 DECLARE active_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,12030 ,"ACTIVE" ) )
 SUBROUTINE  getresults_nqf59 (null )
  SET br_filters->provider_attribution = getproviderattribution ("59" )
  CALL geteprfilter ("59" )
  CALL getpopulation_nqf_diabetes ("MU_EC_0059_2019" )
  CALL getattribution_nqf59 ("MU_EC_0059_2019" )
  CALL getexclusion_nqf59 (0 )
  CALL getoutcome_nqf59 (0 )
  CALL summaryreport ("MU_EC_0059_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf_diabetes (measure_name )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE person_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE encntr_batch_size = i4 WITH constant (10 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query - qualifying encounters" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0059: A1" ,
    "POPULATION: NQF2019_0059: B1" ,
    "POPULATION: NQF2019_0059: C1" ,
    "POPULATION: NQF2019_0059: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("75,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((mod (personcnt ,person_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons ,((
      personcnt + person_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].person_id =
    pop.person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,
    IF ((measure_name = "*59*" ) ) lh_ep_reply->persons[personcnt ].outcome_ind = 1 ,lh_ep_reply->
     persons[personcnt ].outcome = "Met, Not Done"
    ELSE lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome
     = "Not Met, Not Done"
    ENDIF
    ,encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((mod (encntrcnt ,encntr_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons[
      personcnt ].encntrs ,((encntrcnt + encntr_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,lh_ep_reply->persons[
    personcnt ].encntr_cnt = encntrcnt
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt ) ,
    lh_ep_reply->person_cnt = personcnt
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Initial Population Query - qualifying diabetes diagnosis" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0059: DIABETES: F1" ,
    "NQF2019_0059: DIABETES: G1" ,
    "NQF2019_0059: DIABETES: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[e_iter ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     IF ((qry.query_name = "NQF2019_0059: DIABETES: H1" ) )
      IF ((lh_ep_reply->persons[pos ].exclude_ind != 0 )
      AND (checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.end_effective_dt_tm ) = 1 )
      AND (pat.prob_life_cycle_status_cd = active_cd ) ) lh_ep_reply->persons[pos ].exclude_ind = 0
      ENDIF
     ELSE
      IF ((pos > 0 )
      AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
       IF ((diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) lh_ep_reply
        ->persons[pos ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL removedummyitem (lh_ep_reply )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf59 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE hba1c_limit = i4 WITH constant (9 ) ,protect
  CALL lhprint (";get outcome - HbA1c_Laboratory_Test" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id ,1 ,lh_ep_reply->persons[p_iter ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (isnumeric (pat.ce_result_val ) > 0 )
   AND (qry.query_name IN ("NQF2019_0059: HEMOGLOBIN: E1" ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[e_iter ].person_id ) ,
    IF ((cnvtreal (pat.ce_result_val ) > hba1c_limit ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Not Controlled"
    ELSE lh_ep_reply->persons[pos ].outcome_ind = 0 ,lh_ep_reply->persons[pos ].outcome =
     "Not Met, Controlled"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get outcome: HbA1c_Laboratory_Test" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf59 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,1 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0059: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0059: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0059: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0059: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0059: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[enc_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0059: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0059: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0059: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0059: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0059: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf59 (measure_name )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0059" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0059" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0059" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0059" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0059" ,"'HCPCS'" ,"1=1" )
  CALL getepdata (measure_name ,br_filters->provider_attribution ,"NQF2019_0059" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf62 (null ) = null
 DECLARE getpopulation_nqf62 (null ) = null
 DECLARE getexclusion_nqf62 (null ) = null
 DECLARE getoutcome_nqf62 (null ) = null
 DECLARE getattribution_nqf62 ((measure = vc ) ) = null
 DECLARE active_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,12030 ,"ACTIVE" ) )
 SUBROUTINE  getresults_nqf62 (null )
  CALL geteprfilter ("62" )
  CALL getpopulation_nqf62 (0 )
  CALL getattribution_nqf62 ("MU_EC_0062_2019" )
  CALL getexclusion_nqf62 (0 )
  CALL getoutcome_nqf62 (0 )
  CALL summaryreport ("MU_EC_0062_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf62 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE enccnt = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0062" )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (p.active_ind = 1 )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("75,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    total_size = 5000 ,
    batch_size = 5000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->person_cnt = personcnt ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id
    ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].
    outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,lh_ep_reply->
    persons[personcnt ].exclude_ind = 1 ,enccnt = 0 ,enc_total_size = 5 ,enc_batch_size = 5 ,stat =
    alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_total_size )
   HEAD pop.encntr_id
    enccnt = (enccnt + 1 ) ,
    IF ((enc_total_size < enccnt ) ) enc_total_size = (enc_total_size + enc_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntr_cnt = enccnt ,lh_ep_reply->persons[personcnt ].encntrs[
    enccnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[enccnt ].fin = pop
    .financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enccnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Population Diagnosis of Diabetes Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0062: DIABETES: F1" ,
    "NQF2019_0062: DIABETES: G1" ,
    "NQF2019_0062: DIABETES: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     IF ((qry.query_name = "NQF2019_0062: DIABETES: H1" ) )
      IF ((lh_ep_reply->persons[person_pos ].exclude_ind != 0 )
      AND (checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.end_effective_dt_tm ) = 1 )
      AND (pat.prob_life_cycle_status_cd = active_cd ) ) lh_ep_reply->persons[person_pos ].
       exclude_ind = 0
      ENDIF
     ELSE
      IF ((person_pos > 0 )
      AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
       IF ((diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) lh_ep_reply
        ->persons[person_pos ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Remove un-diagnosed patients" )
  CALL beg_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf62 (measure )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0062" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0062" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0062" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0062" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0062" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata (measure ,br_filters->provider_attribution ,"NQF2019_0062" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf62 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0062: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0062: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0062: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0062: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0062: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[enc_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0062: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0062: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0062: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0062: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0062: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf62 (null )
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";getOutcome_NQF62 non-problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0062: CONDITIONS_PROB: F4" ,
    "NQF2019_0062: CONDITIONS_PROB: G4" ,
    "NQF2019_0062: NEPHROPATHY_PROC: A5" ,
    "NQF2019_0062: NEPHROPATHY_PROC: B5" ,
    "NQF2019_0062: NEPHROPATHY_PROC: C5" ,
    "NQF2019_0062: NEPHROPATHY_PROC: D5" ,
    "NQF2019_0062: DIALYSIS_PROC: A6" ,
    "NQF2019_0062: DIALYSIS_PROC: D6" ,
    "NQF2019_0062: DIALYSIS_PROC: E6" ,
    "NQF2019_0062: ESRD_ENCOUNTER: A7" ,
    "NQF2019_0062: ESRD_ENCOUNTER: B7" ,
    "NQF2019_0062: ESRD_ENCOUNTER: C7" ,
    "NQF2019_0062: ESRD_ENCOUNTER: D7" ,
    "NQF2019_0062: URINE_PROTEIN_TEST: E8" ,
    "NQF2019_0062: DIALYSIS_PAT_EDU: P10" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,date_chck = 0
   DETAIL
    CASE (qry.query_name )
     OF "NQF2019_0062: CONDITIONS_PROB: F4" :
     OF "NQF2019_0062: CONDITIONS_PROB: G4" :
      IF ((pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
      AND (diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) date_chck =
       2
      ENDIF
     OF "NQF2019_0062: NEPHROPATHY_PROC: A5" :
     OF "NQF2019_0062: NEPHROPATHY_PROC: B5" :
     OF "NQF2019_0062: NEPHROPATHY_PROC: C5" :
     OF "NQF2019_0062: NEPHROPATHY_PROC: D5" :
     OF "NQF2019_0062: DIALYSIS_PROC: A6" :
     OF "NQF2019_0062: DIALYSIS_PROC: D6" :
     OF "NQF2019_0062: DIALYSIS_PROC: E6" :
     OF "NQF2019_0062: ESRD_ENCOUNTER: A7" :
     OF "NQF2019_0062: ESRD_ENCOUNTER: B7" :
     OF "NQF2019_0062: ESRD_ENCOUNTER: C7" :
     OF "NQF2019_0062: ESRD_ENCOUNTER: D7" :
     OF "NQF2019_0062: URINE_PROTEIN_TEST: E8" :
     OF "NQF2019_0062: DIALYSIS_PAT_EDU: P10" :
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) date_chck = 2
      ENDIF
    ENDCASE
   FOOT  pat.person_id
    IF ((person_pos > 0 )
    AND (date_chck = 2 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[
     person_pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,expand = 1 ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";getOutcome_NQF62 - Medication" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
    AND (((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
    ))
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name = "NQF2019_0062: MEDICATION: M3" ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   HEAD pat.encntr_id
    IF ((person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[
     person_pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,expand = 1 ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";getOutcome_NQF62 problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0062: CONDITIONS_PROB: H4" )
    AND (qry.active_ind = 1 )
    AND (pat.end_effective_dt_tm >= cnvtdatetime (beg_extract_dt_tm ) )
    AND (nullcheck (pat.onset_dt_tm ,pat.beg_effective_dt_tm ,nullind (pat.onset_dt_tm ) ) <=
    cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.prob_life_cycle_status_cd = active_cd ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   HEAD pat.encntr_id
    IF ((person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[
     person_pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf69 (null ) = null
 DECLARE getpopulation_nqf69 (null ) = null
 DECLARE getexclusion_nqf69 (null ) = null
 DECLARE getattribution_nqf69 (null ) = null
 DECLARE getoutcome_nqf69 (null ) = null
 SUBROUTINE  getpopulation_nqf69 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH protect ,noconstant (0 )
  DECLARE exclude_check = i4 WITH protect ,noconstant (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query: Qualifying Encounter" )
  CALL beg_time (0 )
  SELECT INTO "NL:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0069: A1" ,
    "POPULATION: NQF2019_0069: B1" ,
    "POPULATION: NQF2019_0069: C1" ,
    "POPULATION: NQF2019_0069: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("3,M" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat =
    alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].outcome_ind = 1 ,lh_ep_reply->
    persons[personcnt ].outcome = "Met, Antibiotic Not Ordered" ,encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome_ind =
    1 ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome = "Met, Antibiotic Not Ordered" ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";URI Problem and diagnosis : Encounter with Upper Respiratory Infection" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_year_start ) AND cnvtdatetime (
     end_extract_dt_tm_year_end ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0069: URI_DX: F2" ,
    "NQF2019_0069: URI_DX: H2" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (enc_iter = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      exclude_check = 0 ,
      IF ((lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].exclude_ind != 0 ) )
       IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].
        reg_dt_tm ) AND cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].
        disch_dt_tm ) ) ) exclude_check = 1
       ENDIF
       ,
       IF ((exclude_check = 0 )
       AND (pat.ep_dt_tm < cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].
        reg_dt_tm ) )
       AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].
        reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) exclude_check = 1
       ENDIF
       ,
       IF ((exclude_check = 1 ) ) lh_ep_reply->persons[person_pos ].exclude_ind = 0 ,lh_ep_reply->
        persons[person_pos ].encntrs[enc_iter ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf69 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE exc_flag = i2 WITH noconstant (0 ) ,protect
  DECLARE date_time = i2 WITH noconstant (0 ) ,protect
  CALL lhprint (";problem exclusion check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,1 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0069: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0069: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0069: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0069: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_0069: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_end_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    out_flg = 0 ,pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[enc_iter ].person_id )
   HEAD pat.ep_end_dt_tm
    dummy = 0
   DETAIL
    IF ((pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0069: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0069: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0069: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0069: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0069: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.ep_end_dt_tm
    IF ((out_flg = 1 )
    AND (pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].encntrs[i ].
      outcome = "Denominator Exclusion"
     ENDFOR
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|pos:" ,pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";get exclusion - Active prob or dx or antibiotic med within 3 days after URI dx" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0069: DEN_EX_PROB: F3" ,
    "NQF2019_0069: DEN_EX_PROB: G3" ,
    "NQF2019_0069: DEN_EX_PROB: H3" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[enc_iter ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 1 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].ep_ind = 1 )
      AND (lh_ep_reply->persons[pos ].ep_ind = 1 ) ) date_time = lhgetdatetimedifference (pat
        .ep_dt_tm ,cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) ,"D" ) ,
       IF ((pat.ep_dt_tm > cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
       AND (date_time <= 3 ) ) lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 2 ,lh_ep_reply->
        persons[pos ].encntrs[i ].outcome = "Denominator Exclusion"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes - Active prob or dx or antibiotic med within 3 days after URI dx" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";get exclusion - Active antibiotic med within 30 days before or during URI dx" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0069: MEDICATION: M5" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[enc_iter ].person_id ) ,exc_flag = 0
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind != 2 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].ep_ind = 1 )
      AND (lh_ep_reply->persons[pos ].ep_ind = 1 ) )
       IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
       AND (((pat.ep_end_dt_tm >= cnvtlookbehind ("30,D" ,cnvtdatetime (lh_ep_reply->persons[pos ].
         encntrs[i ].reg_dt_tm ) ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ]
        .encntrs[i ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
        "Denominator Exclusion"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion - Active antibiotic med within 30 days before or during URI dx"
    )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf69 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE date_time = i2 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome - order antibiotic med not within 3 days before or during URI dx" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,1 ,lh_ep_reply->persons[iter1 ].ep_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0069: MEDICATION: M4" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind != 2 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].ep_ind = 1 )
      AND (lh_ep_reply->persons[pos ].ep_ind = 1 ) ) date_time = lhgetdatetimedifference (pat
        .ep_dt_tm ,cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) ,"D" ) ,
       IF ((pat.ep_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
       AND (date_time <= 3 ) ) lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 ,lh_ep_reply->
        persons[pos ].encntrs[i ].outcome = "Not Met, Antibiotic Ordered"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes - Order antibiotic med not within 3 days before or during URI dx" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf69 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0069" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("EMERG_DEPT_VISIT_ENC" ,"0069" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"0069" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"0069" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOSP_OBS_CARE_INITIAL_ENC" ,"0069" ,"'CPT4'" ,"1=1" )
  CALL getepdata ("MU_EC_0069_2019" ,br_filters->provider_attribution ,"NQF2019_0069" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getresults_nqf69 (null )
  CALL geteprfilter ("69" )
  CALL getpopulation_nqf69 (0 )
  CALL getattribution_nqf69 (0 )
  CALL getexclusion_nqf69 (0 )
  CALL getoutcome_nqf69 (0 )
  CALL summaryreport ("MU_EC_0069_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 DECLARE getresults_nqf70 (null ) = null
 DECLARE process_d1 (null ) = null
 DECLARE process_d2 (null ) = null
 DECLARE getpopulation_nqf70 (null ) = null
 DECLARE getdenominator1_nqf70 (null ) = null
 DECLARE getdenominator2_nqf70 (null ) = null
 DECLARE getattribution_nqf70 ((measuremean = vc ) ) = null
 DECLARE getoutcome_nqf70 (null ) = null
 SUBROUTINE  getresults_nqf70 (null )
  CALL geteprfilter ("70" )
  CALL getpopulation_nqf70 (0 )
  CALL process_d1 (0 )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  CALL process_d2 (0 )
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  process_d1 (null )
  CALL getattribution_nqf70 ("MU_EC_0070_2019.1" )
  SET stat = moverec (lh_ep_reply ,lh_ep_reply_bk )
  CALL getdenominator1_nqf70 (0 )
  CALL getoutcome_nqf70 (0 )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   FOR (j = 1 TO size (lh_ep_reply->persons[i ].encntrs ,5 ) )
    SET lh_ep_reply->persons[i ].encntrs[j ].exclude_ind = 0
   ENDFOR
  ENDFOR
  CALL summaryreport ("MU_EC_0070_2019.1" )
 END ;Subroutine
 SUBROUTINE  process_d2 (null )
  CALL getattribution_nqf70 ("MU_EC_0070_2019.2" )
  CALL getdenominator2_nqf70 (0 )
  CALL getoutcome_nqf70 (0 )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   FOR (j = 1 TO size (lh_ep_reply->persons[i ].encntrs ,5 ) )
    SET lh_ep_reply->persons[i ].encntrs[j ].exclude_ind = 0
   ENDFOR
  ENDFOR
  CALL summaryreport ("MU_EC_0070_2019.2" )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf70 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0070: A1" ,
    "POPULATION: NQF2019_0070: B1" ,
    "POPULATION: NQF2019_0070: C1" ,
    "POPULATION: NQF2019_0070: D1" ,
    "POPULATION: NQF2019_0070: A2" ,
    "POPULATION: NQF2019_0070: B2" ,
    "POPULATION: NQF2019_0070: C2" ,
    "POPULATION: NQF2019_0070: D2" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.reg_dt_tm ,
    pop.encntr_id ,
    qry.query_name
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    enc = 0 ,enca = 0 ,enc_cnt = 0 ,enc_added = 0 ,personcnt = (personcnt + 1 ) ,lh_ep_reply->
    person_cnt = personcnt ,stat = alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->
    persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn = pop
    .comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ]
    .outcome_ind = 4 ,lh_ep_reply->persons[personcnt ].outcome = "IPP only" ,stat = initrec (
     lh_bill_encntr_date )
   HEAD pop.reg_dt_tm
    dummy = 0
   HEAD pop.encntr_id
    pos = locateval (iter2 ,1 ,size (lh_bill_encntr_date->days ,5 ) ,cnvtdate (pop.reg_dt_tm ) ,
     cnvtdate (lh_bill_encntr_date->days[iter2 ].encntrday ) ) ,
    IF ((pos = 0 ) ) pos = (lh_bill_encntr_date->daycnt + 1 ) ,lh_bill_encntr_date->daycnt = pos ,
     stat = alterlist (lh_bill_encntr_date->days ,pos ) ,lh_bill_encntr_date->days[pos ].encntrday =
     cnvtdate (pop.reg_dt_tm ) ,enc_added = 0
    ENDIF
    ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   DETAIL
    IF ((qry.query_name IN ("POPULATION: NQF2019_0070: A1" ,
    "POPULATION: NQF2019_0070: B1" ,
    "POPULATION: NQF2019_0070: C1" ,
    "POPULATION: NQF2019_0070: D1" ) ) ) lh_bill_encntr_date->days[pos ].b_ind = 1
    ELSE lh_bill_encntr_date->days[pos ].a_ind = 1 ,
     IF ((enc_added = 0 ) ) enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[
       personcnt ].encntrs ,enc_cnt ) ,lh_ep_reply->persons[personcnt ].encntr_cnt = enc_cnt ,
      lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
      persons[personcnt ].encntrs[enc_cnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
      personcnt ].encntrs[enc_cnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
      encntrs[enc_cnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
      enc_cnt ].exclude_ind = 1 ,enc_added = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    FOR (iter2 = 1 TO size (lh_bill_encntr_date->days ,5 ) )
     IF ((lh_bill_encntr_date->days[iter2 ].b_ind = 1 ) ) enc = (enc + 1 )
     ENDIF
     ,
     IF ((lh_bill_encntr_date->days[iter2 ].a_ind = 1 ) ) enca = 1
     ENDIF
    ENDFOR
    ,
    IF ((((enc < 2 ) ) OR ((enca = 0 ) )) ) personcnt = (personcnt - 1 ) ,lh_ep_reply->person_cnt =
     personcnt ,stat = alterlist (lh_ep_reply->persons ,personcnt )
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Dx check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0070: CAD_PROB: F1" ,
   "NQF2019_0070: CAD_PROB: G1" ,
   "NQF2019_0070: CAD_PROB: H1" ,
   "NQF2019_0070: CARDIAC_SURG_PROC: A2" ,
   "NQF2019_0070: CARDIAC_SURG_PROC: B2" ,
   "NQF2019_0070: CARDIAC_SURG_PROC: C2" ,
   "NQF2019_0070: CARDIAC_SURG_PROC: D2" ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    cad_prob = 0 ,
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind != 0 ) )
       IF ((qry.query_name = "NQF2019_0070: CAD_PROB:*" ) )
        IF ((pat.ep_dt_tm <= lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm )
        AND (((pat.ep_end_dt_tm >= lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) ) OR ((pat
        .ep_end_dt_tm = null ) )) ) cad_prob = 1
        ENDIF
       ELSE
        IF ((pat.ep_dt_tm < lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) cad_prob = 1
        ENDIF
       ENDIF
       ,
       IF ((cad_prob = 1 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->persons[pos ].
        encntrs[i ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo ("At Initial population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getdenominator1_nqf70 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE ef_val = i4 WITH constant (40 ) ,protect
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   FOR (j = 1 TO size (lh_ep_reply->persons[i ].encntrs ,5 ) )
    SET lh_ep_reply->persons[i ].encntrs[j ].exclude_ind = 1
   ENDFOR
  ENDFOR
  CALL lhprint (";Determine Denominator pop1" )
  CALL lhprint (";LVSD Problem check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0070: LVSD_PROB: H4" ,
   "NQF2019_0070: LVSD_SEVERE: H1" ) )
   AND (qry.active_ind = 1 )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 1 )
      AND (pat.ep_dt_tm < lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
       IF ((qry.query_name = "NQF2019_0070: LVSD_SEVERE: H1" ) )
        IF ((cnvtupper (pat.updt_source ) = "IMPORT*" ) )
         IF ((trim (pat.primary_vset_cd ) != "" )
         AND (trim (pat.secondary_vset_cd ) != "" ) ) lh_ep_reply->persons[pos ].special_group = 1 ,
          lh_ep_reply->persons[pos ].outcome_ind = 0 ,lh_ep_reply->persons[pos ].outcome =
          "Not Met, Not Done" ,lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0
         ENDIF
        ENDIF
       ELSE lh_ep_reply->persons[pos ].special_group = 1 ,lh_ep_reply->persons[pos ].outcome_ind = 0
       ,lh_ep_reply->persons[pos ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[pos ].encntrs[
        i ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Query to check for EJECTION FRACTION" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.query_name IN ("NQF2019_0070: EJECTION_FRACTION: E5" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   HEAD pat.ep_dt_tm
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 1 )
      AND (pat.ep_dt_tm < lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) lh_ep_reply->
       persons[pos ].special_group = 1 ,lh_ep_reply->persons[pos ].outcome_ind = 0 ,lh_ep_reply->
       persons[pos ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[pos ].encntrs[i ].
       exclude_ind = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After finding Denominator 1" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getdenominator2_nqf70 (null )
  DECLARE iter1 = i4 WITH noconstant (0 )
  DECLARE iter2 = i4 WITH noconstant (0 )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   FOR (j = 1 TO size (lh_ep_reply->persons[i ].encntrs ,5 ) )
    SET lh_ep_reply->persons[i ].encntrs[j ].exclude_ind = 1
   ENDFOR
  ENDFOR
  CALL lhprint (";Denominator for pop2" )
  CALL lhprint (";Myocardial Problem check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0070: MYOCARDIAL_INF_PROB: H3" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    dummy = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].special_group != 2 )
    AND (lh_ep_reply->persons[pos ].outcome_ind != 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 1 )
      AND (pat.ep_end_dt_tm < lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm )
      AND (lhgetdatetimedifference (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ,pat
       .ep_end_dt_tm ,"Y" ) <= 3 ) ) lh_ep_reply->persons[pos ].special_group = 2 ,lh_ep_reply->
       persons[pos ].outcome_ind = 0 ,lh_ep_reply->persons[pos ].outcome = "Not Met, Not Done" ,
       lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Denominator 2" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf70 (measuremean )
  CALL lhprint (build (";Attribution for " ,measuremean ) )
  CALL beg_time (0 )
  DECLARE ep_i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_i = i4 WITH noconstant (0 ) ,protect
  IF ((measuremean = "MU_EC_0070_2019.1" ) )
   CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0070" ,"'CPT4','SNMCT'" ,"1=1" )
   CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0070" ,"'CPT4','SNMCT'" ,"1=1" )
   CALL getnonmappednomenclature ("PT_PROV_INTERACT_ENC" ,"0070" ,"'SNMCT'" ,"1=1" )
   CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0070" ,"'CPT4','SNMCT'" ,"1=1" )
   CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"0070" ,"'CPT4','SNMCT'" ,"1=1" )
   CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0070" ,"'CPT4','SNMCT'" ,"1=1" )
   CALL getepdata (measuremean ,br_filters->provider_attribution ,"NQF2019_0070" )
  ELSE
   SET reportmean = "MU_EC_0070_2019.1"
   SET reportmean1 = measuremean
   SELECT INTO "nl:"
    FROM (dummyt d WITH seq = ep_summary->ep_cnt ),
     (dummyt d2 WITH seq = 1 ),
     (dummyt d3 WITH seq = 1 )
    PLAN (d
     WHERE (ep_summary->ep_cnt > 0 )
     AND (ep_summary->eps[d.seq ].reportmean = reportmean )
     AND maxrec (d2 ,ep_summary->eps[d.seq ].patient_cnt ) )
     JOIN (d2
     WHERE (ep_summary->eps[d.seq ].patient_cnt > 0 )
     AND maxrec (d3 ,ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt ) )
     JOIN (d3
     WHERE (ep_summary->eps[d.seq ].patients[d2.seq ].encntr_cnt > 0 ) )
    ORDER BY d.seq ,
     d2.seq ,
     d3.seq
    HEAD d.seq
     ep_pos = locateval (ep_i ,1 ,size (ep_summary->eps ,5 ) ,ep_summary->eps[d.seq ].provider_id ,
      ep_summary->eps[ep_i ].provider_id ,reportmean1 ,ep_summary->eps[ep_i ].reportmean ,ep_summary
      ->eps[d.seq ].tax_id_nbr_txt ,ep_summary->eps[ep_i ].tax_id_nbr_txt ) ,
     IF ((ep_pos > 0 ) ) epcnt1 = ep_pos
     ELSE epcnt = size (ep_summary->eps ,5 ) ,epcnt1 = (epcnt + 1 ) ,stat = alterlist (ep_summary->
       eps ,epcnt1 ) ,ep_summary->ep_cnt = epcnt1 ,ep_summary->eps[epcnt1 ].br_eligible_provider_id
      = ep_summary->eps[d.seq ].br_eligible_provider_id ,ep_summary->eps[epcnt1 ].provider_id =
      ep_summary->eps[d.seq ].provider_id ,ep_summary->eps[epcnt1 ].tax_id_nbr_txt = ep_summary->eps[
      d.seq ].tax_id_nbr_txt ,ep_summary->eps[epcnt1 ].gpro_name = ep_summary->eps[d.seq ].gpro_name
     ,ep_summary->eps[epcnt1 ].npi_nbr_txt = ep_summary->eps[d.seq ].npi_nbr_txt ,ep_summary->eps[
      epcnt1 ].reportmean = reportmean1 ,ep_summary->eps[epcnt1 ].name = ep_summary->eps[d.seq ].name
     ENDIF
     ,ptcnt = 0
    HEAD d2.seq
     person_pos = locateval (person_i ,1 ,size (ep_summary->eps[epcnt1 ].patients ,5 ) ,ep_summary->
      eps[d.seq ].patients[d2.seq ].person_id ,ep_summary->eps[epcnt1 ].patients[person_i ].person_id
       ) ,
     IF ((person_pos > 0 ) ) ptcnt = person_pos
     ELSE ptcnt = (ep_summary->eps[epcnt1 ].patient_cnt + 1 ) ,ep_summary->eps[epcnt1 ].patient_cnt
      = ptcnt ,stat = alterlist (ep_summary->eps[epcnt1 ].patients ,ptcnt ) ,ep_summary->eps[epcnt1 ]
      .patients[ptcnt ].person_id = ep_summary->eps[d.seq ].patients[d2.seq ].person_id ,ep_summary->
      eps[epcnt1 ].patients[ptcnt ].mrn = ep_summary->eps[d.seq ].patients[d2.seq ].mrn ,ep_summary->
      eps[epcnt1 ].patients[ptcnt ].birth_date = ep_summary->eps[d.seq ].patients[d2.seq ].birth_date
       ,ep_summary->eps[epcnt1 ].patients[ptcnt ].name = ep_summary->eps[d.seq ].patients[d2.seq ].
      name
     ENDIF
     ,ecnt = 0
    HEAD d3.seq
     ecnt = (ep_summary->eps[epcnt1 ].patients[ptcnt ].encntr_cnt + 1 ) ,ep_summary->eps[epcnt1 ].
     patients[ptcnt ].encntr_cnt = ecnt ,stat = alterlist (ep_summary->eps[epcnt1 ].patients[ptcnt ].
      encntrs ,ecnt ) ,ep_summary->eps[epcnt1 ].patients[ptcnt ].encntrs[ecnt ].encntr_id =
     ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].encntr_id ,ep_summary->eps[epcnt1 ].
     patients[ptcnt ].encntrs[ecnt ].br_eligible_provider_id = ep_summary->eps[d.seq ].patients[d2
     .seq ].encntrs[d3.seq ].br_eligible_provider_id ,ep_summary->eps[epcnt1 ].patients[ptcnt ].
     encntrs[ecnt ].visit_date = ep_summary->eps[d.seq ].patients[d2.seq ].encntrs[d3.seq ].
     visit_date ,ep_summary->eps[epcnt1 ].patients[ptcnt ].encntrs[ecnt ].fin = ep_summary->eps[d
     .seq ].patients[d2.seq ].encntrs[d3.seq ].fin
    WITH nocounter
   ;end select
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echo (build2 ("After attribution: measure=" ,measuremean ) )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf70 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Outcome query for First Met, Done decision point" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind ,0 ,lh_ep_reply->persons[iter1 ].
     outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0070: MEDICATION: M6" ,
    "NQF2019_0070: MEDICATION: M18" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    dummy = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (pat.ep_dt_tm BETWEEN lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm AND lh_ep_reply->
      persons[pos ].encntrs[i ].disch_dt_tm ) )
       CASE (qry.query_name )
        OF "NQF2019_0070: MEDICATION: M6" :
         IF ((lh_ep_reply->persons[pos ].special_group = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind
           = 1 ,lh_ep_reply->persons[pos ].outcome = "Met, Done"
         ENDIF
        OF "NQF2019_0070: MEDICATION: M18" :
         IF ((lh_ep_reply->persons[pos ].special_group = 2 ) ) lh_ep_reply->persons[pos ].outcome_ind
           = 1 ,lh_ep_reply->persons[pos ].outcome = "Met, Done"
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Outcome query for Second Met, Done decision point" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.query_name IN ("NQF2019_0070: MEDICATION: M7" ,
   "NQF2019_0070: MEDICATION: M19" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,med_active_ind = 0
   DETAIL
    IF ((pos > 0 )
    AND (med_active_ind != 1 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (pat.ep_dt_tm <= lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm )
      AND (((pat.ep_end_dt_tm >= lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) OR ((pat
      .ep_end_dt_tm = null ) )) )
       CASE (qry.query_name )
        OF "NQF2019_0070: MEDICATION: M7" :
         IF ((lh_ep_reply->persons[pos ].special_group = 1 ) ) med_active_ind = 1
         ENDIF
        OF "NQF2019_0070: MEDICATION: M19" :
         IF ((lh_ep_reply->persons[pos ].special_group = 2 ) ) med_active_ind = 1
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((med_active_ind = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos
     ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Query for Den Exception points" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0070: NEGATION: E8" ,
    "NQF2019_0070: NEGATION_HM: L8" ,
    "NQF2019_0070: NEGATION_HM: L9" ,
    "NQF2019_0070: NEGATION: E10" ,
    "NQF2019_0070: NEGATION_HM: L10" ,
    "NQF2019_0070: NEGATION_HM: L11" ,
    "NQF2019_0070: NEGATION: E12" ,
    "NQF2019_0070: NEGATION_HM: L12" ,
    "NQF2019_0070: NEGATION_HM: L13" ,
    "NQF2019_0070: BETA_BLOCKER_PROB: F15" ,
    "NQF2019_0070: BETA_BLOCKER_PROB: G15" ,
    "NQF2019_0070: BETA_BLOCKER_PROB: H15" ,
    "NQF2019_0070: BETA_BLOCKER_INGREDIENT: N16" ,
    "NQF2019_0070: BETA_BLOCKER_THERAPY: H16" ,
    "NQF2019_0070: HEART_RATE_PERF: E14" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    pat_reason_ind = 0 ,sys_reason_ind = 0 ,med_reason_ind = 0 ,pos = locatevalsort (iter2 ,1 ,size (
      lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].exclude_ind = 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 )
    AND (lh_ep_reply->persons[pos ].special_group IN (1 ,
    2 ) ) )
     FOR (i = 1 TO lh_ep_reply->persons[pos ].encntr_cnt )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 ) )
       CASE (qry.query_name )
        OF "NQF2019_0070: NEGATION: E10" :
        OF "NQF2019_0070: NEGATION_HM: L10" :
        OF "NQF2019_0070: NEGATION_HM: L11" :
         IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm AND lh_ep_reply->
         persons[pos ].encntrs[i ].disch_dt_tm ) ) pat_reason_ind = 1
         ENDIF
        OF "NQF2019_0070: NEGATION: E12" :
        OF "NQF2019_0070: NEGATION_HM: L12" :
        OF "NQF2019_0070: NEGATION_HM: L13" :
         IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm AND lh_ep_reply->
         persons[pos ].encntrs[i ].disch_dt_tm ) ) sys_reason_ind = 1
         ENDIF
        OF "NQF2019_0070: NEGATION: E8" :
        OF "NQF2019_0070: NEGATION_HM: L8" :
        OF "NQF2019_0070: NEGATION_HM: L9" :
        OF "NQF2019_0070: HEART_RATE_PERF: E14" :
         IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm AND lh_ep_reply->
         persons[pos ].encntrs[i ].disch_dt_tm ) ) med_reason_ind = 1
         ENDIF
        OF "NQF2019_0070: BETA_BLOCKER_PROB: F15" :
        OF "NQF2019_0070: BETA_BLOCKER_PROB: G15" :
        OF "NQF2019_0070: BETA_BLOCKER_PROB: H15" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
         AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm )
         ) ) OR ((pat.ep_end_dt_tm = null ) )) ) med_reason_ind = 1
         ENDIF
        OF "NQF2019_0070: BETA_BLOCKER_THERAPY: H16" :
        OF "NQF2019_0070: BETA_BLOCKER_INGREDIENT: N16" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
         AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm
          ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) med_reason_ind = 1
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((pat_reason_ind = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos
     ].outcome = "Denominator Exception, Patient"
    ELSEIF ((sys_reason_ind = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[
     pos ].outcome = "Denominator Exception, System"
    ELSEIF ((med_reason_ind = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[
     pos ].outcome = "Denominator Exception, Medical"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind ,0 ,lh_ep_reply->persons[iter1 ].
     exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0070: ATRIOVENTRICULAR_BLOCK: F16" ,
    "NQF2019_0070: ATRIOVENTRICULAR_BLOCK: G16" ,
    "NQF2019_0070: ATRIOVENTRICULAR_BLOCK: H16" ,
    "NQF2019_0070: CARDIAC_PACER_IN_SITU_NEG: F17" ,
    "NQF2019_0070: CARDIAC_PACER_IN_SITU_NEG: G17" ,
    "NQF2019_0070: CARDIAC_PACER_IN_SITU_NEG: H17" ,
    "NQF2019_0070: CARDIAC_PACER_NEG: A18" ,
    "NQF2019_0070: CARDIAC_PACER_ORD_NEG: D18" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,atri_done = 0 ,cardiac_pacer_situ = 0 ,cardiac_pacer = 0
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 ) )
       CASE (qry.query_name )
        OF "NQF2019_0070: ATRIOVENTRICULAR_BLOCK: F16" :
        OF "NQF2019_0070: ATRIOVENTRICULAR_BLOCK: G16" :
        OF "NQF2019_0070: ATRIOVENTRICULAR_BLOCK: H16" :
         IF ((((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm )
         ) ) OR ((pat.ep_end_dt_tm = null ) ))
         AND (pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) )
          atri_done = 1
         ENDIF
        OF "NQF2019_0070: CARDIAC_PACER_IN_SITU_NEG: F17" :
        OF "NQF2019_0070: CARDIAC_PACER_IN_SITU_NEG: G17" :
        OF "NQF2019_0070: CARDIAC_PACER_IN_SITU_NEG: H17" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
         AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm
          ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) cardiac_pacer_situ = 1
         ENDIF
        OF "NQF2019_0070: CARDIAC_PACER_NEG: A18" :
        OF "NQF2019_0070: CARDIAC_PACER_ORD_NEG: D18" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
         AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm
          ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) cardiac_pacer = 1
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((atri_done = 1 )
    AND (cardiac_pacer_situ != 1 )
    AND (cardiac_pacer != 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos
     ].outcome = "Denominator Exception, Medical"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
 END ;Subroutine
 DECLARE getresults_nqf81 (null ) = null
 DECLARE getpopulation_nqf81_1 (null ) = null
 DECLARE getpopulation_nqf81_2 (null ) = null
 DECLARE getattribution_nqf81 ((measuremean = vc ) ) = null
 DECLARE getoutcome_nqf81 (null ) = null
 DECLARE getoutcome_nqf81_2 (null ) = null
 DECLARE getdenom_nqf81 (null ) = null
 DECLARE getdenom_nqf81_2 (null ) = null
 DECLARE getexception_nqf81 (null ) = null
 DECLARE getexception_nqf81_2 (null ) = null
 SUBROUTINE  getresults_nqf81 (null )
  CALL geteprfilter ("81" )
  CALL getpopulation_nqf81_1 (0 )
  CALL getdenom_nqf81 (0 )
  CALL getattribution_nqf81 ("MU_EC_0081_2019.1" )
  CALL getoutcome_nqf81 (0 )
  CALL getexception_nqf81 (0 )
  CALL summaryreport ("MU_EC_0081_2019.1" )
  SET stat = initrec (lh_ep_reply )
  CALL getpopulation_nqf81_2 (0 )
  CALL getdenom_nqf81_2 (0 )
  CALL getattribution_nqf81 ("MU_EC_0081_2019.2" )
  CALL getoutcome_nqf81_2 (0 )
  CALL getexception_nqf81_2 (0 )
  CALL summaryreport ("MU_EC_0081_2019.2" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf81_1 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0081: A1" ,
    "POPULATION: NQF2019_0081: B1" ,
    "POPULATION: NQF2019_0081: C1" ,
    "POPULATION: NQF2019_0081: D1" ,
    "POPULATION: NQF2019_0081: A3" ,
    "POPULATION: NQF2019_0081: B3" ,
    "POPULATION: NQF2019_0081: C3" ,
    "POPULATION: NQF2019_0081: D3" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.reg_dt_tm DESC ,
    pop.encntr_id ,
    qry.query_name
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    out_cd = 0 ,enc_cd = 0 ,enc_cnt = 0 ,personcnt = (personcnt + 1 ) ,lh_ep_reply->person_cnt =
    personcnt ,stat = alterlist (lh_ep_reply->persons ,personcnt ) ,stat = initrec (
     lh_bill_encntr_date ) ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->
    persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 4 ,
    lh_ep_reply->persons[personcnt ].outcome = "IPP Only" ,lh_ep_reply->persons[personcnt ].
    exclude_ind = 1
   HEAD pop.reg_dt_tm
    dummy = 0
   HEAD pop.encntr_id
    person_pos = locateval (e_iter ,1 ,size (lh_bill_encntr_date->days ,5 ) ,cnvtdate (pop.reg_dt_tm
      ) ,cnvtdate (lh_bill_encntr_date->days[e_iter ].encntrday ) ) ,
    IF ((person_pos = 0 ) ) person_pos = (lh_bill_encntr_date->daycnt + 1 ) ,lh_bill_encntr_date->
     daycnt = person_pos ,stat = alterlist (lh_bill_encntr_date->days ,person_pos ) ,
     lh_bill_encntr_date->days[person_pos ].encntrday = cnvtdate (pop.reg_dt_tm )
    ENDIF
    ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   HEAD qry.query_name
    IF ((qry.query_name IN ("POPULATION: NQF2019_0081: A1" ,
    "POPULATION: NQF2019_0081: B1" ,
    "POPULATION: NQF2019_0081: C1" ,
    "POPULATION: NQF2019_0081: D1" ) ) ) lh_bill_encntr_date->days[person_pos ].a_ind = 1
    ELSE lh_bill_encntr_date->days[person_pos ].b_ind = 1 ,enc_cnt = (enc_cnt + 1 ) ,stat =
     alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_cnt ) ,lh_ep_reply->persons[personcnt ]
     .encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ]
     .fin = pop.financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].reg_dt_tm = pop
     .reg_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].disch_dt_tm = pop.disch_dt_tm ,
     lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].exclude_ind = 1 ,lh_ep_reply->persons[
     personcnt ].encntr_cnt = enc_cnt
    ENDIF
   FOOT  pop.person_id
    FOR (e_iter = 1 TO size (lh_bill_encntr_date->days ,5 ) )
     IF ((lh_bill_encntr_date->days[e_iter ].a_ind = 1 ) ) out_cd = (out_cd + 1 )
     ENDIF
     ,
     IF ((lh_bill_encntr_date->days[e_iter ].b_ind = 1 ) ) enc_cd = 1
     ENDIF
    ENDFOR
    ,
    IF ((((out_cd < 2 ) ) OR ((enc_cd = 0 ) )) ) lh_ep_reply->person_cnt = (personcnt - 1 ) ,
     personcnt = lh_ep_reply->person_cnt ,stat = alterlist (lh_ep_reply->persons ,personcnt )
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("DEBUG: |out:" ,out_cd ,"|enc_cd:" ,enc_cd ) ) ,
     CALL echorecord (lh_bill_encntr_date )
    ENDIF
    ,stat = initrec (lh_bill_encntr_date )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("; After inital population query " )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Prob check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: HEART_FAILURE: F1" ,
   "NQF2019_0081: HEART_FAILURE: G1" ,
   "NQF2019_0081: HEART_FAILURE: H1" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[
       person_pos ].encntrs[i ].reg_dt_tm ) ) )) ) lh_ep_reply->persons[person_pos ].encntrs[i ].
       exclude_ind = 0 ,lh_ep_reply->persons[person_pos ].exclude_ind = 0 ,
       IF ((((lh_ep_reply->persons[person_pos ].recent_encntr_date = null ) ) OR ((lh_ep_reply->
       persons[person_pos ].recent_encntr_date < lh_ep_reply->persons[person_pos ].encntrs[i ].
       disch_dt_tm ) )) ) lh_ep_reply->persons[person_pos ].recent_encntr_date = lh_ep_reply->
        persons[person_pos ].encntrs[i ].disch_dt_tm ,lh_ep_reply->persons[person_pos ].
        recent_encntr_id = lh_ep_reply->persons[person_pos ].encntrs[i ].encntr_id
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf81 (measuremean )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0081" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0081" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0081" ,"'CPT4','SNMCT" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"0081" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0081" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SERV_HOSP_INPT_ENC" ,"0081" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata (measuremean ,br_filters->provider_attribution ,"NQF2019_0081" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getdenom_nqf81 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get Denominator" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: LVSD_PROBLEM: H2" ,
   "NQF2019_0081: EJECTION_FRACTION: E3" ,
   "NQF2019_0081: LVSD_SEVERE: H1" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm ) )
       IF ((qry.query_name = "NQF2019_0081: LVSD_SEVERE: H1" ) )
        IF ((cnvtupper (pat.updt_source ) = "IMPORT*" )
        AND (trim (pat.primary_vset_cd ) != "" )
        AND (trim (pat.secondary_vset_cd ) != "" ) ) lh_ep_reply->persons[person_pos ].outcome_ind =
         0 ,lh_ep_reply->persons[person_pos ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[
         person_pos ].encntrs[i ].b2 = 1
        ENDIF
       ELSE lh_ep_reply->persons[person_pos ].outcome_ind = 0 ,lh_ep_reply->persons[person_pos ].
        outcome = "Not Met, Not Done" ,lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After getDenom_NQF81" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf81 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE estimated_stop_dt_tm = dq8 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get Outcome" )
  CALL lhprint ("Medication done check : M4" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0081: MEDICATION: M4" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 )
      AND (pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M4" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint ("Medication done check : M5" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name = "NQF2019_0081: MEDICATION: M5" )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 )
      AND (pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[
       person_pos ].encntrs[i ].disch_dt_tm ) ) )) ) lh_ep_reply->persons[person_pos ].outcome_ind =
       1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M5" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexception_nqf81 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE estimated_stop_dt_tm = dq8 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint ("check exceptions" )
  CALL lhprint (";PREGNANCY Diagnosis Check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].exclude_ind ,0 ,lh_ep_reply->persons[
     p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: PREGNANCY: F11" ,
    "NQF2019_0081: PREGNANCY: G11" ,
    "NQF2019_0081: PREGNANCY: H11" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[
       person_pos ].encntrs[i ].reg_dt_tm ) ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
       "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].special_group = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("; Allergy & Daignosis Probs check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].exclude_ind ,0 ,lh_ep_reply->persons[
     p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: NEGATION: N10" ,
    "NQF2019_0081: PREGNANCY: H12" ) )
    AND (qry.active_ind = 1 ) )
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
       disch_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
       "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].special_group = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("; Medical check exceptions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].exclude_ind ,0 ,lh_ep_reply->persons[
     p_iter ].outcome_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: NEGATION: E6" ,
    "NQF2019_0081: NEGATION: E7" ,
    "NQF2019_0081: NEGATION: E8" ,
    "NQF2019_0081: ACE_OR_ARB_RESULT: E12" ,
    "NQF2019_0081: ACE_OR_ARB_RESULT: L12" ,
    "NQF2019_0081: ACE_OR_ARB_RESULT: L13" ,
    "NQF2019_0081: MED_ACE_NEG_MED_HM: L23" ,
    "NQF2019_0081: MED_ACE_NEG_MED_HM: L24" ,
    "NQF2019_0081: PT_ACE_NEG_MED_HM: L25" ,
    "NQF2019_0081: PT_ACE_NEG_MED_HM: L26" ,
    "NQF2019_0081: SYS_ACE_NEG_MED_HM: L27" ,
    "NQF2019_0081: SYS_ACE_NEG_MED_HM: L28" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       CASE (qry.query_name )
        OF "NQF2019_0081: NEGATION: E6" :
        OF "NQF2019_0081: MED_ACE_NEG_MED_HM: L23" :
        OF "NQF2019_0081: MED_ACE_NEG_MED_HM: L24" :
         lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,
         lh_ep_reply->persons[person_pos ].outcome = "Denominator Exception, Medical" ,
         lh_ep_reply->persons[person_pos ].special_group = 1
        OF "NQF2019_0081: NEGATION: E7" :
        OF "NQF2019_0081: ACE_OR_ARB_RESULT: E12" :
        OF "NQF2019_0081: ACE_OR_ARB_RESULT: L12" :
        OF "NQF2019_0081: ACE_OR_ARB_RESULT: L13" :
        OF "NQF2019_0081: PT_ACE_NEG_MED_HM: L25" :
        OF "NQF2019_0081: PT_ACE_NEG_MED_HM: L26" :
         IF ((lh_ep_reply->persons[person_pos ].special_group != 1 ) ) lh_ep_reply->persons[
          person_pos ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
          "Denominator Exception, Patient"
         ENDIF
        OF "NQF2019_0081: NEGATION: E8" :
        OF "NQF2019_0081: SYS_ACE_NEG_MED_HM: L27" :
        OF "NQF2019_0081: SYS_ACE_NEG_MED_HM: L28" :
         IF ((lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[person_pos ]
          .outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
          "Denominator Exception, System"
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf81_2 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query Encounter Level" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0081: A2" ,
    "POPULATION: NQF2019_0081: B2" ,
    "POPULATION: NQF2019_0081: C2" ,
    "POPULATION: NQF2019_0081: D2" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    enc_cnt = 0 ,personcnt = (personcnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat = alterlist
    (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,
    lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt
   HEAD pop.encntr_id
    enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_cnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[enc_cnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[enc_cnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[enc_cnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
    enc_cnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].outcome_ind = 4 ,
    lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].outcome = "IPP Only" ,lh_ep_reply->persons[
    personcnt ].encntr_cnt = enc_cnt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("; After inital population query " )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Prob check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: HEART_FAILURE: F1" ,
   "NQF2019_0081: HEART_FAILURE: G1" ,
   "NQF2019_0081: HEART_FAILURE: H1" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[
       person_pos ].encntrs[i ].reg_dt_tm ) ) )) ) lh_ep_reply->persons[person_pos ].encntrs[i ].
       exclude_ind = 0 ,lh_ep_reply->persons[person_pos ].exclude_ind = 0 ,
       IF ((((lh_ep_reply->persons[person_pos ].recent_encntr_date = 0 ) ) OR ((lh_ep_reply->persons[
       person_pos ].recent_encntr_date < lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
       )) ) lh_ep_reply->persons[person_pos ].recent_encntr_date = lh_ep_reply->persons[person_pos ].
        encntrs[i ].disch_dt_tm ,lh_ep_reply->persons[person_pos ].recent_encntr_id = lh_ep_reply->
        persons[person_pos ].encntrs[i ].encntr_id
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getdenom_nqf81_2 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get Denominator" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: LVSD_PROBLEM: H2" ,
   "NQF2019_0081: EJECTION_FRACTION: E3" ,
   "NQF2019_0081: LVSD_SEVERE: H1" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm ) )
       IF ((qry.query_name = "NQF2019_0081: LVSD_SEVERE: H1" ) )
        IF ((cnvtupper (pat.updt_source ) = "IMPORT*" )
        AND (trim (pat.primary_vset_cd ) != "" )
        AND (trim (pat.secondary_vset_cd ) != "" ) ) lh_ep_reply->persons[person_pos ].encntrs[i ].
         outcome_ind = 0 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
         "Not Met, Not Done" ,lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ,lh_ep_reply->
         persons[person_pos ].outcome_ind = 0
        ENDIF
       ELSE lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 ,lh_ep_reply->persons[
        person_pos ].encntrs[i ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[person_pos ].
        encntrs[i ].b2 = 1 ,lh_ep_reply->persons[person_pos ].outcome_ind = 0
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After getDenom_NQF81" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf81_2 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE estimated_stop_dt_tm = dq8 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get Outcome" )
  CALL lhprint ("Medication done check : M4" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0081: MEDICATION: M4" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
       lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm ) ) lh_ep_reply->persons[person_pos
        ].encntrs[i ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
        "Met, Done"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M4" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint ("Medication done check : M5" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name = "NQF2019_0081: MEDICATION: M5" )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
        ) )
       AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[
        person_pos ].encntrs[i ].disch_dt_tm ) ) )) ) lh_ep_reply->persons[person_pos ].encntrs[i ].
        outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome = "Met, Done"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M5" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexception_nqf81_2 (null )
  DECLARE p_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE e_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE estimated_stop_dt_tm = dq8 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint ("check exceptions" )
  CALL lhprint (";PREGNANCY Diagnosis Check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].exclude_ind ,0 ,lh_ep_reply->persons[
     p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: PREGNANCY: F11" ,
    "NQF2019_0081: PREGNANCY: G11" ,
    "NQF2019_0081: PREGNANCY: H11" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
        ) )
       AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->
        persons[person_pos ].encntrs[i ].reg_dt_tm ) ) )) ) lh_ep_reply->persons[person_pos ].
        encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
        "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].special_group = 1
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("; Allergy & Daignosis Probs check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,0 ,lh_ep_reply->persons[p_iter ].exclude_ind ,0 ,lh_ep_reply->persons[
     p_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: NEGATION: N10" ,
    "NQF2019_0081: PREGNANCY: H12" ) )
    AND (qry.active_ind = 1 ) )
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
        ) )
       AND (((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
        disch_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[person_pos ].
        encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
        "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].special_group = 1
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("; Medical check exceptions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: NEGATION: E6" ,
    "NQF2019_0081: NEGATION: E7" ,
    "NQF2019_0081: NEGATION: E8" ,
    "NQF2019_0081: ACE_OR_ARB_RESULT: E12" ,
    "NQF2019_0081: ACE_OR_ARB_RESULT: L12" ,
    "NQF2019_0081: ACE_OR_ARB_RESULT: L13" ,
    "NQF2019_0081: MED_ACE_NEG_MED_HM: L23" ,
    "NQF2019_0081: MED_ACE_NEG_MED_HM: L24" ,
    "NQF2019_0081: PT_ACE_NEG_MED_HM: L25" ,
    "NQF2019_0081: PT_ACE_NEG_MED_HM: L26" ,
    "NQF2019_0081: SYS_ACE_NEG_MED_HM: L27" ,
    "NQF2019_0081: SYS_ACE_NEG_MED_HM: L28" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[e_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       CASE (qry.query_name )
        OF "NQF2019_0081: NEGATION: E6" :
        OF "NQF2019_0081: MED_ACE_NEG_MED_HM: L23" :
        OF "NQF2019_0081: MED_ACE_NEG_MED_HM: L24" :
         lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 3 ,
         lh_ep_reply->persons[person_pos ].encntrs[i ].outcome = "Denominator Exception, Medical" ,
         lh_ep_reply->persons[person_pos ].special_group = 1
        OF "NQF2019_0081: NEGATION: E7" :
        OF "NQF2019_0081: ACE_OR_ARB_RESULT: E12" :
        OF "NQF2019_0081: ACE_OR_ARB_RESULT: L12" :
        OF "NQF2019_0081: ACE_OR_ARB_RESULT: L13" :
        OF "NQF2019_0081: PT_ACE_NEG_MED_HM: L25" :
        OF "NQF2019_0081: PT_ACE_NEG_MED_HM: L26" :
         IF ((lh_ep_reply->persons[person_pos ].special_group != 1 ) ) lh_ep_reply->persons[
          person_pos ].encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].
          outcome = "Denominator Exception, Patient"
         ENDIF
        OF "NQF2019_0081: NEGATION: E8" :
        OF "NQF2019_0081: SYS_ACE_NEG_MED_HM: L27" :
        OF "NQF2019_0081: SYS_ACE_NEG_MED_HM: L28" :
         IF ((lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[person_pos ]
          .encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
          "Denominator Exception, System"
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf83 (null ) = null
 DECLARE getattribution_nqf83 ((measuremean = vc ) ) = null
 DECLARE getoutcome_nqf83 (null ) = null
 DECLARE getoutcome_nqf83_2 (null ) = null
 DECLARE getexception_nqf83 (null ) = null
 DECLARE getexception_nqf83_2 (null ) = null
 SUBROUTINE  getresults_nqf83 (null )
  CALL geteprfilter ("83" )
  CALL getpopulation_nqf81_1 (0 )
  CALL getdenom_nqf81 (0 )
  CALL getattribution_nqf83 ("MU_EC_0083_2019.1" )
  CALL getoutcome_nqf83 (0 )
  CALL getexception_nqf83 (0 )
  CALL summaryreport ("MU_EC_0083_2019.1" )
  SET stat = initrec (lh_ep_reply )
  CALL getpopulation_nqf81_2 (0 )
  CALL getdenom_nqf81_2 (0 )
  CALL getattribution_nqf83 ("MU_EC_0083_2019.2" )
  CALL getoutcome_nqf83_2 (0 )
  CALL getexception_nqf83_2 (0 )
  CALL summaryreport ("MU_EC_0083_2019.2" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf83 (measuremean )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0083" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0083" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0083" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"0083" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0083" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SERV_HOSP_INPT_ENC" ,"0083" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata (measuremean ,br_filters->provider_attribution ,"NQF2019_0081" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf83 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE estimated_stop_dt_tm = dq8 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";Medications get Outcome" )
  CALL lhprint ("done check for medication :M14" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0081: MEDICATION: M14" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((person_pos > 0 )
      AND (pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M14" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint ("done check for medication :M15" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name = "NQF2019_0081: MEDICATION: M15" )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[
       person_pos ].encntrs[i ].disch_dt_tm ) ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M15" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexception_nqf83 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE person_include_ind = i4 WITH protect ,noconstant (0 )
  DECLARE occa_date = dq8 WITH protect ,noconstant (0 )
  CALL lhprint ("check for exceptions" )
  CALL lhprint (" " )
  CALL lhprint (";Exception Heart rate check event :E22" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: HEART_RATE_PERFORM: E22" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,occa_date = 0 ,person_include_ind = 0
   DETAIL
    IF ((person_pos > 0 )
    AND (person_include_ind = 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm ) ) OR ((pat.encntr_id = lh_ep_reply
      ->persons[person_pos ].recent_encntr_id ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       IF ((occa_date = 0 ) ) occa_date = pat.ep_dt_tm
       ELSE
        IF ((pat.ep_dt_tm < occa_date ) ) person_include_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((person_include_ind = 1 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,lh_ep_reply->
     persons[person_pos ].outcome = "Denominator Exception, Medical" ,lh_ep_reply->persons[
     person_pos ].special_group = 1
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("check exceptions negation rules" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: NEGATION: E16" ,
    "NQF2019_0081: NEGATION: E17" ,
    "NQF2019_0081: NEGATION: E18" ,
    "NQF2019_0081: MED_BBT_NEG_MED_HM: L29" ,
    "NQF2019_0081: MED_BBT_NEG_MED_HM: L30" ,
    "NQF2019_0081: PT_BBT_NEG_MED_HM: L31" ,
    "NQF2019_0081: PT_BBT_NEG_MED_HM: L32" ,
    "NQF2019_0081: SYS_BBT_NEG_MED_HM: L33" ,
    "NQF2019_0081: SYS_BBT_NEG_MED_HM: L34" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       CASE (qry.query_name )
        OF "NQF2019_0081: NEGATION: E16" :
        OF "NQF2019_0081: MED_BBT_NEG_MED_HM: L29" :
        OF "NQF2019_0081: MED_BBT_NEG_MED_HM: L30" :
         lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,
         lh_ep_reply->persons[person_pos ].outcome = "Denominator Exception, Medical" ,
         lh_ep_reply->persons[person_pos ].special_group = 1
        OF "NQF2019_0081: NEGATION: E17" :
        OF "NQF2019_0081: PT_BBT_NEG_MED_HM: L31" :
        OF "NQF2019_0081: PT_BBT_NEG_MED_HM: L32" :
         IF ((lh_ep_reply->persons[person_pos ].special_group != 1 ) ) lh_ep_reply->persons[
          person_pos ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
          "Denominator Exception, Patient"
         ENDIF
        OF "NQF2019_0081: NEGATION: E18" :
        OF "NQF2019_0081: SYS_BBT_NEG_MED_HM: L33" :
        OF "NQF2019_0081: SYS_BBT_NEG_MED_HM: L34" :
         lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,
         lh_ep_reply->persons[person_pos ].outcome = "Denominator Exception, System"
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Exception Problems check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (qry.query_name IN ("NQF2019_0081: BETA_BLOCKER_PROB: F21" ,
   "NQF2019_0081: BETA_BLOCKER_PROB: G21" ,
   "NQF2019_0081: BETA_BLOCKER_PROB: H21" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
       reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
       "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].special_group = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Exception Problems check" )
  CALL lhprint (";Exception Problems check with overlap after :N20,:H22" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: BETA_BLOCKER_PROB: H22" ,
   "NQF2019_0081: NEGATION: N20" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
       disch_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].outcome =
       "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].special_group = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After BETA_BLOCKER_PROB" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind ,0 ,lh_ep_reply->persons[iter1 ].
     exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: ATRIOVENTRICULAR_BLOCK: F16" ,
    "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: G16" ,
    "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: H16" ,
    "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: F17" ,
    "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: G17" ,
    "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: H17" ,
    "NQF2019_0081: CARDIAC_PACER_NEG: A18" ,
    "NQF2019_0081: CARDIAC_PACER_ORD_NEG: D18" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,atri_done = 0 ,cardiac_pacer_situ = 0 ,cardiac_pacer = 0
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       CASE (qry.query_name )
        OF "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: F16" :
        OF "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: G16" :
        OF "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: H16" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
           ) )
         AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
          reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) atri_done = 1
         ENDIF
        OF "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: F17" :
        OF "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: G17" :
        OF "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: H17" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
           ) ) ) cardiac_pacer_situ = 1
         ENDIF
        OF "NQF2019_0081: CARDIAC_PACER_NEG: A18" :
        OF "NQF2019_0081: CARDIAC_PACER_ORD_NEG: D18" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
           ) )
         AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->
          persons[person_pos ].encntrs[i ].disch_dt_tm ) ) )) ) cardiac_pacer = 1
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((atri_done = 1 )
    AND (cardiac_pacer_situ != 1 )
    AND (cardiac_pacer != 1 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,lh_ep_reply->
     persons[person_pos ].outcome = "Denominator Exception, Medical" ,lh_ep_reply->persons[
     person_pos ].special_group = 1
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  IF ((debug_ind = 1 ) )
   CALL echo ("After exceptions" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf83_2 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE estimated_stop_dt_tm = dq8 WITH protect ,noconstant (0 )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";Medications get Outcome at encounter level" )
  CALL lhprint ("done check for medication :M14" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0081: MEDICATION: M14" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
     IF ((person_pos > 0 )
     AND (pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
     lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
     AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ].
      encntrs[i ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
      "Met, Done"
     ENDIF
    ENDFOR
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M14" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint ("done check for medication :M15" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name = "NQF2019_0081: MEDICATION: M15" )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[
       person_pos ].encntrs[i ].disch_dt_tm ) ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .encntrs[i ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
       "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome medication M15" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexception_nqf83_2 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE person_include_ind = i4 WITH protect ,noconstant (0 )
  DECLARE occa_date = dq8 WITH protect ,noconstant (0 )
  CALL lhprint ("check for exceptions" )
  CALL lhprint (" " )
  CALL lhprint (";Exception Heart rate check event :E22" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: HEART_RATE_PERFORM: E22" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    person_pos = 0 ,
    encntr_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,occa_date = 0
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
      lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       IF ((occa_date = 0 ) ) occa_date = pat.ep_dt_tm
       ELSE
        IF ((pat.ep_dt_tm < occa_date )
        AND (lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind != 3 ) ) lh_ep_reply->persons[
         person_pos ].encntrs[i ].c1 = 1 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind
         = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
         "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].encntrs[i ].
         special_group = 1
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("check exceptions negation rules" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: NEGATION: E16" ,
    "NQF2019_0081: NEGATION: E17" ,
    "NQF2019_0081: NEGATION: E18" ,
    "NQF2019_0081: MED_BBT_NEG_MED_HM: L29" ,
    "NQF2019_0081: MED_BBT_NEG_MED_HM: L30" ,
    "NQF2019_0081: PT_BBT_NEG_MED_HM: L31" ,
    "NQF2019_0081: PT_BBT_NEG_MED_HM: L32" ,
    "NQF2019_0081: SYS_BBT_NEG_MED_HM: L33" ,
    "NQF2019_0081: SYS_BBT_NEG_MED_HM: L34" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
     IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[i ].reg_dt_tm AND
     lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
     AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
      CASE (qry.query_name )
       OF "NQF2019_0081: NEGATION: E16" :
       OF "NQF2019_0081: MED_BBT_NEG_MED_HM: L29" :
       OF "NQF2019_0081: MED_BBT_NEG_MED_HM: L30" :
        lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 3 ,
        lh_ep_reply->persons[person_pos ].encntrs[i ].outcome = "Denominator Exception, Medical" ,
        lh_ep_reply->persons[person_pos ].encntrs[i ].special_group = 1
       OF "NQF2019_0081: NEGATION: E17" :
       OF "NQF2019_0081: PT_BBT_NEG_MED_HM: L31" :
       OF "NQF2019_0081: PT_BBT_NEG_MED_HM: L32" :
        IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].special_group != 1 ) ) lh_ep_reply->
         persons[person_pos ].encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[
         i ].outcome = "Denominator Exception, Patient"
        ENDIF
       OF "NQF2019_0081: NEGATION: E18" :
       OF "NQF2019_0081: SYS_BBT_NEG_MED_HM: L33" :
       OF "NQF2019_0081: SYS_BBT_NEG_MED_HM: L34" :
        lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 3 ,
        lh_ep_reply->persons[person_pos ].encntrs[i ].outcome = "Denominator Exception, System"
      ENDCASE
     ENDIF
    ENDFOR
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Exception Problems check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: BETA_BLOCKER_PROB: F21" ,
   "NQF2019_0081: BETA_BLOCKER_PROB: G21" ,
   "NQF2019_0081: BETA_BLOCKER_PROB: H21" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
       reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
       "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].encntrs[i ].special_group
       = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Exception Problems check" )
  CALL lhprint (";Exception Problems check with overlap after :N20,:H22" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0081: BETA_BLOCKER_PROB: H22" ,
   "NQF2019_0081: NEGATION: N20" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm )
      )
      AND (((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
       disch_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) ))
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) ) lh_ep_reply->persons[person_pos ]
       .encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
       "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].encntrs[i ].special_group
       = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After BETA_BLOCKER_PROB" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0081: ATRIOVENTRICULAR_BLOCK: F16" ,
    "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: G16" ,
    "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: H16" ,
    "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: F17" ,
    "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: G17" ,
    "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: H17" ,
    "NQF2019_0081: CARDIAC_PACER_NEG: A18" ,
    "NQF2019_0081: CARDIAC_PACER_ORD_NEG: D18" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   HEAD pat.encntr_id
    dummy = 0
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b2 = 1 ) )
       CASE (qry.query_name )
        OF "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: F16" :
        OF "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: G16" :
        OF "NQF2019_0081: ATRIOVENTRICULAR_BLOCK: H16" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
           ) )
         AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].
          reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[person_pos ].
          encntrs[i ].a1 = 1
         ENDIF
        OF "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: F17" :
        OF "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: G17" :
        OF "NQF2019_0081: CARDIAC_PACER_IN_SITU_NEG: H17" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
           ) ) ) lh_ep_reply->persons[person_pos ].encntrs[i ].a2 = 1
         ENDIF
        OF "NQF2019_0081: CARDIAC_PACER_NEG: A18" :
        OF "NQF2019_0081: CARDIAC_PACER_ORD_NEG: D18" :
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[i ].disch_dt_tm
           ) )
         AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm > cnvtdatetime (lh_ep_reply->
          persons[person_pos ].encntrs[i ].disch_dt_tm ) ) )) ) lh_ep_reply->persons[person_pos ].
          encntrs[i ].b1 = 1
         ENDIF
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.encntr_id
    FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
     IF ((lh_ep_reply->persons[person_pos ].encntrs[i ].a1 = 1 )
     AND (lh_ep_reply->persons[person_pos ].encntrs[i ].a2 != 1 )
     AND (lh_ep_reply->persons[person_pos ].encntrs[i ].b1 != 1 ) ) lh_ep_reply->persons[person_pos ]
      .encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos ].encntrs[i ].outcome =
      "Denominator Exception, Medical" ,lh_ep_reply->persons[person_pos ].encntrs[i ].special_group
      = 1
     ENDIF
    ENDFOR
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  IF ((debug_ind = 1 ) )
   CALL echo ("After exceptions" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf101 (null ) = null
 DECLARE getpopulation_nqf101 (null ) = null
 DECLARE getattribution_nqf101 (null ) = null
 DECLARE getexclusion_nqf101 (null ) = null
 DECLARE getoutcome_nqf101 (null ) = null
 SUBROUTINE  getpopulation_nqf101 (null )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  DECLARE p_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE e_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE p_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE e_batch_size = i4 WITH constant (10 ) ,protect
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0101" )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("65,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    p_total_size = p_batch_size ,
    stat = alterlist (lh_ep_reply->persons ,p_total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((p_total_size < personcnt ) ) p_total_size = (p_total_size + p_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons ,p_total_size )
    ENDIF
    ,lh_ep_reply->person_cnt = personcnt ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id
    ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].
    outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,enccnt = 0 ,
    e_total_size = 10 ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
   HEAD pop.encntr_id
    enccnt = (enccnt + 1 ) ,
    IF ((e_total_size < enccnt ) ) e_total_size = (e_total_size + e_batch_size ) ,stat = alterlist (
      lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntr_cnt = enccnt ,lh_ep_reply->persons[personcnt ].encntrs[
    enccnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[enccnt ].fin = pop
    .financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enccnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf101 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0101" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0101" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0101" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0101" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0101" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("OPHTHALMOLOGICAL_SERVICES" ,"0101" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_SERV_INDIV_COUNSEL" ,"0101" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SER_NURSE_FAC_ENC" ,"0101" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0101" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0101" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("AUDIOLOGY_VISIT" ,"0101" ,"'CPT4'" ,"1=1" )
  CALL getepdata ("MU_EC_0101_2019" ,br_filters->provider_attribution ,"NQF2019_0101" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf101 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_cnt = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Hospice Exclusion check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0101: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_0101: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_0101: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_0101: HOSPICE_CARE_AMB: E2" ,
    "NQF2019_0101: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[iter2 ].person_id ,0 ,lh_ep_reply->persons[iter2 ].outcome_ind
     )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0101: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0101: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_0101: HOSPICE_CARE_AMB: D1" ) )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_0101: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_0101: HOSPICE_CARE_AMB: E2" ) )
     AND (((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
     )) ) out_flg = 1
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Ambulatory Status check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0101: AMB_STATUS_PERF: E3" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    person_pos = 0 ,
    pcnt = 0
   HEAD pat.person_id
    person_ind = 0 ,person_pos = locateval (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id
     ,lh_ep_reply->persons[iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind ) ,
    IF ((person_pos > 0 ) ) pcnt = (pcnt + 1 ) ,amb_date->person_cnt = pcnt ,stat = alterlist (
      amb_date->persons ,pcnt ) ,amb_date->persons[pcnt ].person_id = pat.person_id ,person_ind = 1 ,
     enc_cnt = 0
    ENDIF
   DETAIL
    IF ((person_ind = 1 ) )
     IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
      ) )
     AND (cnvtdate (pat.ep_dt_tm ) != cnvtdate (amb_date->persons[pcnt ].dates[enc_cnt ].ep_date ) )
     ) enc_cnt = (enc_cnt + 1 ) ,amb_date->persons[pcnt ].date_cnt = enc_cnt ,stat = alterlist (
       amb_date->persons[pcnt ].dates ,enc_cnt ) ,amb_date->persons[pcnt ].dates[enc_cnt ].ep_date =
      cnvtdate (pat.ep_dt_tm ) ,amb_date->persons[pcnt ].dates[enc_cnt ].a1 = 1
     ELSEIF ((pat.ep_dt_tm < cnvtdatetime (beg_extract_dt_tm ) )
     AND (cnvtdate (pat.ep_dt_tm ) != cnvtdate (amb_date->persons[pcnt ].dates[enc_cnt ].ep_date ) )
     ) enc_cnt = (enc_cnt + 1 ) ,amb_date->persons[pcnt ].date_cnt = enc_cnt ,stat = alterlist (
       amb_date->persons[pcnt ].dates ,enc_cnt ) ,amb_date->persons[pcnt ].dates[enc_cnt ].ep_date =
      cnvtdate (pat.ep_dt_tm ) ,amb_date->persons[pcnt ].dates[enc_cnt ].a2 = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Patient not ambulatory check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_0101: PT_NOT_AMB: E4" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ,0 ,lh_ep_reply->persons[iter2 ].exclude_ind ) ,amb_pos = locateval
    (iter3 ,1 ,size (amb_date->persons ,5 ) ,pat.person_id ,amb_date->persons[iter3 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (amb_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (amb_date->persons[amb_pos ].dates ,5 ) )
      IF ((amb_date->persons[amb_pos ].dates[i ].a1 = 1 )
      AND (cnvtdate (pat.ep_dt_tm ) = cnvtdate (amb_date->persons[amb_pos ].dates[i ].ep_date ) ) )
       lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[person_pos ].outcome
       = "Denominator Exclusion"
      ELSEIF ((amb_date->persons[amb_pos ].dates[i ].a2 = 1 )
      AND (cnvtdate (pat.ep_dt_tm ) = cnvtdate (amb_date->persons[amb_pos ].dates[i ].ep_date ) ) )
       lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[person_pos ].outcome
       = "Denominator Exclusion"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf101 (null )
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0101: FALLS_SCREENING: E1" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,expand = 1 ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getresults_nqf101 (null )
  IF ((validate (amb_date ) = 0 ) )
   RECORD amb_date (
     1 person_cnt = i4
     1 persons [* ]
       2 person_id = f8
       2 date_cnt = i4
       2 dates [* ]
         3 ep_date = dq8
         3 a1 = i2
         3 a2 = i2
   ) WITH protect
  ENDIF
  SET br_filters->provider_attribution = getproviderattribution ("101" )
  CALL geteprfilter ("101" )
  CALL getpopulation_nqf101 (0 )
  CALL getattribution_nqf101 (0 )
  CALL getexclusion_nqf101 (0 )
  CALL getoutcome_nqf101 (0 )
  CALL summaryreport ("MU_EC_0101_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
  SET stat = initrec (amb_date )
 END ;Subroutine
 DECLARE getresults_nqf104 (null ) = null
 DECLARE getpopulation_nqf104 (null ) = null
 DECLARE getattribution_nqf104 (null ) = null
 DECLARE getoutcome_nqf104 (null ) = null
 SUBROUTINE  getresults_nqf104 (null )
  CALL geteprfilter ("104" )
  CALL getpopulation_nqf104 (0 )
  CALL getattribution_nqf104 (0 )
  CALL getoutcome_nqf104 (0 )
  CALL summaryreport ("MU_EC_0104_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf104 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE per_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0104" ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("17,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id ,
    pop.reg_dt_tm
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    enc_cnt = 0 ,personcnt = (personcnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat = alterlist
    (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,
    lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].
    exclude_ind = 1
   HEAD pop.encntr_id
    enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_cnt ) ,
    lh_ep_reply->persons[personcnt ].encntr_cnt = enc_cnt ,lh_ep_reply->persons[personcnt ].encntrs[
    enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].fin = pop
    .financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].reg_dt_tm = pop.reg_dt_tm
    ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->
    persons[personcnt ].encntrs[enc_cnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].encntrs[
    enc_cnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].outcome =
    "Not Met, Not Done" ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Major Depression check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0104: MAJOR_DEP_DIAG: F1" ,
    "NQF2019_0104: MAJOR_DEP_DIAG: G1" ,
    "NQF2019_0104: MAJOR_DEP_DIAG: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    per_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((per_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[per_pos ].encntrs ,5 ) )
      IF ((qry.query_name = "NQF2019_0104: MAJOR_DEP_DIAG: H1" ) )
       IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[per_pos ].encntrs[i ].disch_dt_tm ) )
       AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->
        persons[per_pos ].encntrs[i ].reg_dt_tm ) ) )) ) lh_ep_reply->persons[per_pos ].exclude_ind
        = 0 ,lh_ep_reply->persons[per_pos ].encntrs[i ].exclude_ind = 0
       ENDIF
      ELSE
       IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[per_pos ].encntrs[i ].reg_dt_tm
        ) AND cnvtdatetime (lh_ep_reply->persons[per_pos ].encntrs[i ].disch_dt_tm ) ) )
        IF ((qry.query_name = "NQF2019_0104: MAJOR_DEP_DIAG: F1" ) )
         IF ((pat.diag_priority >= 1 ) ) lh_ep_reply->persons[per_pos ].exclude_ind = 0 ,lh_ep_reply
          ->persons[per_pos ].encntrs[i ].exclude_ind = 0
         ENDIF
        ELSE lh_ep_reply->persons[per_pos ].exclude_ind = 0 ,lh_ep_reply->persons[per_pos ].encntrs[
         i ].exclude_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01lh_amb_event_data_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  SELECT INTO "NL:"
   person_id = lh_ep_reply->persons[d1.seq ].person_id ,
   encntr_id = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].encntr_id ,
   reg_date = lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].reg_dt_tm
   FROM (dummyt d1 WITH seq = lh_ep_reply->person_cnt ),
    (dummyt d2 WITH seq = 1 )
   PLAN (d1
    WHERE (lh_ep_reply->person_cnt > 0 )
    AND maxrec (d2 ,size (lh_ep_reply->persons[d1.seq ].encntrs ,5 ) ) )
    JOIN (d2
    WHERE (lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].encntr_id > 0 ) )
   ORDER BY person_id ,
    reg_date
   HEAD REPORT
    dummy = 0
   HEAD person_id
    dummy = 0
   HEAD encntr_id
    FOR (i = (d2.seq - 1 ) TO 1 BY - (1 ) )
     IF ((lhgetdatetimedifference (lh_ep_reply->persons[d1.seq ].encntrs[d2.seq ].reg_dt_tm ,
      lh_ep_reply->persons[d1.seq ].encntrs[i ].disch_dt_tm ,"D" ) < 105 ) ) lh_ep_reply->persons[d1
      .seq ].encntrs[d2.seq ].exclude_ind = 1
     ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf104 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0104" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_PSYCHOTHERAPY" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_DIAG_EVAL" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("EMERG_DEPT_VISIT_ENC" ,"0104" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCHOANALYSIS" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"0104" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_0104_2019" ,br_filters->provider_attribution ,"NQF2019_0104" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf104 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get Outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0104: SUICIDE_RISK: E2" ,
    "NQF2019_0104: SUICIDE_RISK: L2" ,
    "NQF2019_0104: SUICIDE_RISK: L3" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) AND
      cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) ) lh_ep_reply->persons[
       pos ].encntrs[i ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
       "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf384 (null ) = null
 DECLARE getpopulation_nqf384 (null ) = null
 DECLARE getpopulation_nqf384_2 (null ) = null
 DECLARE getattribution_nqf384 ((measuremean = vc ) ) = null
 DECLARE getoutcome_nqf384 (null ) = null
 SUBROUTINE  getresults_nqf384 (null )
  SET br_filters->provider_attribution = getproviderattribution ("384" )
  CALL geteprfilter ("384" )
  CALL getpopulation_nqf384 (0 )
  CALL getattribution_nqf384 ("MU_EC_0384_2019.1" )
  CALL getoutcome_nqf384 (0 )
  CALL summaryreport ("MU_EC_0384_2019.1" )
  SET stat = initrec (lh_ep_reply )
  CALL getpopulation_nqf384_2 (0 )
  CALL getattribution_nqf384 ("MU_EC_0384_2019.2" )
  CALL getoutcome_nqf384 (0 )
  CALL summaryreport ("MU_EC_0384_2019.2" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf384 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
   CALL lhprint (debug_clause )
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0384: A1" ,
    "POPULATION: NQF2019_0384: B1" ,
    "POPULATION: NQF2019_0384: C1" ,
    "POPULATION: NQF2019_0384: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat =
    alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].exclude_ind = 0
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome =
    "Not Met, Not Done" ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].exclude_ind = 1 ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("DEBUG: LH_EP_REPLY after inital patient population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Cancer diagnosis and problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0384: CANCER_PROB: F2" ,
    "NQF2019_0384: CANCER_PROB: G2" ,
    "NQF2019_0384: CANCER_PROB: H2" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[enc_i ].exclude_ind = 1 )
      AND (pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
       disch_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
       reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[person_pos ].encntrs[
       enc_i ].special_group = 1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE02LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After cancer problem check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Chemo within 30 days before and after encounter" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN datetimeadd (cnvtdatetime (beg_extract_dt_tm ) ,- (30 ) ) AND
    datetimeadd (cnvtdatetime (end_extract_dt_tm ) ,30 ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0384: CHEMO_PROC: A1" ,
    "NQF2019_0384: CHEMO_PROC: B1" ,
    "NQF2019_0384: CHEMO_PROC: C1" ,
    "NQF2019_0384: CHEMO_PROC: D1" ,
    "NQF2019_0384: CHEMO_PROC: E1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[enc_i ].special_group = 1 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].exclude_ind = 1 ) )
       IF ((pat.ep_dt_tm < cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
        disch_dt_tm ) )
       AND (pat.ep_dt_tm >= datetimeadd (cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[
         enc_i ].disch_dt_tm ) ,- (30 ) ) ) ) lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
        outpt_ind = 1
       ELSEIF ((pat.ep_dt_tm > cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
        disch_dt_tm ) )
       AND (pat.ep_dt_tm <= datetimeadd (cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[
         enc_i ].disch_dt_tm ) ,30 ) ) ) lh_ep_reply->persons[person_pos ].encntrs[enc_i ].inpt_ind
        = 1
       ENDIF
       ,
       IF ((lh_ep_reply->persons[person_pos ].encntrs[enc_i ].outpt_ind = 1 )
       AND (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].inpt_ind = 1 ) ) lh_ep_reply->persons[
        person_pos ].encntrs[enc_i ].exclude_ind = 0
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE02LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Inital population results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf384 (measuremean )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0384" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CHEMOTHERAPY_ADMINISTRATION" ,"0384" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("RADIATION_TREATMENT_MANAGEMENT" ,"0384" ,"'CPT4'" ,"1=1" )
  CALL getepdata (measuremean ,br_filters->provider_attribution ,"NQF2019_0384" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf384 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ce_result_val != " " ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0384: STD_PAIN_TOOL: E3" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 ) )
     FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[enc_i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].exclude_ind = 0 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
       reg_dt_tm ) AND cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].disch_dt_tm )
      ) ) lh_ep_reply->persons[person_pos ].encntrs[enc_i ].outcome_ind = 1 ,lh_ep_reply->persons[
       person_pos ].encntrs[enc_i ].outcome = "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf384_2 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
   CALL lhprint (debug_clause )
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0384: A2" ,
    "POPULATION: NQF2019_0384: B2" ,
    "POPULATION: NQF2019_0384: C2" ,
    "POPULATION: NQF2019_0384: D2" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat =
    alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].exclude_ind = 0
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome =
    "Not Met, Not Done" ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].exclude_ind = 1 ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("DEBUG: LH_EP_REPLY after inital patient population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Cancer diagnosis and problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0384: CANCER_PROB: F2" ,
    "NQF2019_0384: CANCER_PROB: G2" ,
    "NQF2019_0384: CANCER_PROB: H2" ) ) )
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   HEAD pat.encntr_id
    IF ((person_pos > 0 ) ) encntr_pos = locateval (iter3 ,1 ,size (lh_ep_reply->persons[person_pos ]
       .encntrs ,5 ) ,pat.encntr_id ,lh_ep_reply->persons[person_pos ].encntrs[iter3 ].encntr_id )
    ENDIF
   DETAIL
    IF ((encntr_pos > 0 ) )
     IF ((lh_ep_reply->persons[person_pos ].encntrs[encntr_pos ].exclude_ind = 1 )
     AND (pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[encntr_pos ].
      disch_dt_tm ) )
     AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[encntr_pos ].
      reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[person_pos ].encntrs[
      encntr_pos ].exclude_ind = 0
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE02LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After cancer problem check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf418 (null ) = null
 DECLARE getpopulation_nqf418 (null ) = null
 DECLARE getattribution_nqf418 (null ) = null
 DECLARE getoutcome_nqf418 (null ) = null
 DECLARE getexclusion_nqf418 (null ) = null
 DECLARE process_adults (null ) = null
 DECLARE process_adolescents (null ) = null
 DECLARE checkposscrnandnegscrn (null ) = null
 SUBROUTINE  getresults_nqf418 (null )
  CALL geteprfilter ("418" )
  CALL getpopulation_nqf418 (0 )
  CALL getattribution_nqf418 (0 )
  CALL getoutcome_nqf418 (0 )
  CALL summaryreport ("MU_EC_0418_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf418 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query - qualified encounters" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("POPULATION: NQF2019_0418: A1" ,
    "POPULATION: NQF2019_0418: B1" ,
    "POPULATION: NQF2019_0418: C1" ,
    "POPULATION: NQF2019_0418: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("12,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id ,
    pop.reg_dt_tm ,
    pop.pop_ep_dt_tm
   HEAD REPORT
    personcnt = 0 ,
    person_batch_size = 10000 ,
    encntr_batch_size = 10
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((mod (personcnt ,person_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons ,((
      personcnt + person_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[
    personcnt ].outcome = "Not Met, Not Done" ,
    IF (((datetimediff (cnvtdatetime (beg_extract_dt_tm ) ,p.birth_dt_tm ) / 365.25 ) < 18 ) )
     lh_ep_reply->persons[personcnt ].special_group = 20
    ELSEIF (((datetimediff (cnvtdatetime (beg_extract_dt_tm ) ,p.birth_dt_tm ) / 365.25 ) >= 18 ) )
     lh_ep_reply->persons[personcnt ].special_group = 10
    ENDIF
    ,encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((mod (encntrcnt ,encntr_batch_size ) = 1 ) ) stat = alterlist (lh_ep_reply->persons[
      personcnt ].encntrs ,((encntrcnt + encntr_batch_size ) - 1 ) )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,lh_ep_reply->persons[
    personcnt ].encntr_cnt = encntrcnt
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt ) ,
    lh_ep_reply->person_cnt = personcnt
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (
   ";get most recent depression screenint and divide population into two groups: adults and adolescents"
   )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) ) )
    JOIN (p
    WHERE (p.person_id = pat.person_id )
    AND (p.active_ind = 1 ) )
    JOIN (qry
    WHERE (qry.active_ind = 1 )
    AND (qry.d_query_id = pat.d_query_id )
    AND (qry.query_name IN ("NQF2019_0418: ADULT_DEP_SCRN_RESULT: E1" ,
    "NQF2019_0418: ADOLESC_DEP_SCRN_RESULT: E1" ) ) )
   ORDER BY pat.person_id ,
    qry.query_name ,
    pat.ep_dt_tm DESC
   HEAD pat.person_id
    person_pos = 0 ,person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id
     ,lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((qry.query_name = "NQF2019_0418: ADOLESC_DEP_SCRN_RESULT: E1" )
      AND (lh_ep_reply->persons[person_pos ].special_group = 20 ) ) lh_ep_reply->persons[person_pos ]
       .recent_encntr_id = 1 ,lh_ep_reply->persons[person_pos ].special_cond_dt_tm = pat.ep_dt_tm
      ENDIF
      ,
      IF ((qry.query_name = "NQF2019_0418: ADULT_DEP_SCRN_RESULT: E1" )
      AND (lh_ep_reply->persons[person_pos ].special_group = 10 ) ) lh_ep_reply->persons[person_pos ]
       .recent_encntr_id = 1 ,lh_ep_reply->persons[person_pos ].special_cond_dt_tm = pat.ep_dt_tm
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query - qualified encounters" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf418 (null )
  CALL getexclusion_nqf418 (0 )
  CALL checkposscrnandnegscrn (0 )
  CALL process_adults (0 )
  CALL process_adolescents (0 )
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf418 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: DEPRESSION_BIPOLAR: H1" ,
   "NQF2019_0418: DEPRESSION_BIPOLAR: H2" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 ) )
     FOR (enc_iter = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].reg_dt_tm > 0 ) )
       IF ((pat.ep_dt_tm < cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].
        reg_dt_tm ) )
       AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_iter ].
        reg_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[person_pos ].
        outcome_ind = 2 ,lh_ep_reply->persons[person_pos ].special_group = - (1 ) ,lh_ep_reply->
        persons[person_pos ].outcome = "Denominator Exclusion"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion: Active prob or dx of Depression and Bipolar disorder" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  checkposscrnandnegscrn (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome - negative depression screening" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: NEG_DEPRESSION_SCRN_RSLT: E2" ,
   "NQF2019_0418: NEG_DEPRESSION_SCRN_RSLT_NUMERIC: E3" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((lh_ep_reply->persons[person_pos ].special_group IN (10 ,
    20 ) )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 )
    AND (lh_ep_reply->persons[person_pos ].recent_encntr_id = 1 ) ) lh_ep_reply->persons[person_pos ]
     .outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Negative Screening" ,
     lh_ep_reply->persons[person_pos ].special_group = - (1 )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";get outcome - positive depression screening" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: POS_DEPRESSION_SCRN_RSLT: E2" ,
   "NQF2019_0418: POS_DEPRESSION_SCRN_RSLT_NUMERIC: E3" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((lh_ep_reply->persons[person_pos ].special_group IN (10 ,
    20 ) )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind = 0 )
    AND (lh_ep_reply->persons[person_pos ].recent_encntr_id = 1 ) ) lh_ep_reply->persons[person_pos ]
     .special_group = (lh_ep_reply->persons[person_pos ].special_group + 1 )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  DECLARE j = i4 WITH protect ,noconstant (0 )
  FOR (j = 1 TO lh_ep_reply->person_cnt )
   IF ((lh_ep_reply->persons[j ].special_group = 10 )
   AND NOT ((lh_ep_reply->persons[j ].outcome_ind IN (1 ,
   2 ) ) ) )
    SET lh_ep_reply->persons[j ].special_group = - (10 )
    SET lh_ep_reply->persons[j ].outcome_ind = 0
    SET lh_ep_reply->persons[j ].outcome = "Not Met, Not Done"
   ELSEIF ((lh_ep_reply->persons[j ].special_group = 20 )
   AND NOT ((lh_ep_reply->persons[j ].outcome_ind IN (1 ,
   2 ) ) ) )
    SET lh_ep_reply->persons[j ].special_group = - (20 )
    SET lh_ep_reply->persons[j ].outcome_ind = 0
    SET lh_ep_reply->persons[j ].outcome = "Not Met, Not Done"
   ENDIF
  ENDFOR
  DECLARE i = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO lh_ep_reply->person_cnt )
   IF ((lh_ep_reply->persons[i ].special_group = 11 ) )
    SET lh_ep_reply->persons[i ].special_group = 10
   ELSEIF ((lh_ep_reply->persons[i ].special_group = 21 ) )
    SET lh_ep_reply->persons[i ].special_group = 20
   ENDIF
  ENDFOR
  IF ((debug_ind = 1 ) )
   CALL echo (";get outcome - positive depression screening or dx of depression" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  process_adults (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE adult_dep_screen_dt_tm = dq8 WITH noconstant (0.0 ) ,protect
  CALL lhprint (";get outcome - the combination of three decision points" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: REFERRAL_DEP_ADULT: A4" ,
   "NQF2019_0418: REFERRAL_DEP_ADULT: D4" ,
   "NQF2019_0418: REFERRAL_DEP_ADULT: D5" ,
   "NQF2019_0418: REFERRAL_DEP_ADULT: E4" ,
   "NQF2019_0418: INTERVENTION_ADULT: A5" ,
   "NQF2019_0418: INTERVENTION_ADULT: A6" ,
   "NQF2019_0418: INTERVENTION_ADULT: D5" ,
   "NQF2019_0418: INTERVENTION_ADULT: D6" ,
   "NQF2019_0418: INTERVENTION_ADULT: E5" ,
   "NQF2019_0418: INTERVENTION_ADULT: E6" ,
   "NQF2019_0418: INTERVENTION_ADULT: L5" ,
   "NQF2019_0418: INTERVENTION_ADULT: L6" ,
   "NQF2019_0418: DEP_MED_ADULT: M6" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0 ,
    encntr_pos = 0 ,
    date_ind = 0
   HEAD pat.person_id
    adult_dep_screen_dt_tm = 0 ,person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,
     pat.person_id ,lh_ep_reply->persons[iter2 ].person_id ) ,adult_dep_screen_dt_tm = cnvtdatetime (
     lh_ep_reply->persons[person_pos ].special_cond_dt_tm )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].special_group = 10 ) )
     IF ((cnvtdate (pat.ep_dt_tm ) = cnvtdate (adult_dep_screen_dt_tm ) ) ) lh_ep_reply->persons[
      person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";get outcome - the combination of three decision points" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";get outcome - no intervention due to patient/medical reason (negation check)" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: NEGATION: E7" ,
   "NQF2019_0418: NEGATION: E8" ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,enc_pos = 0
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].special_group IN (10 ,
    - (10 ) ) ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos
     ].outcome = "Denominator Exception"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";;get outcome - no intervention due to patient/medical reason (negation check)" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  process_adolescents (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE adolsc_dep_screen_dt_tm = dq8 WITH noconstant (0.0 ) ,protect
  CALL lhprint (";get outcome - the combination of three decision points" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: REFERRAL_DEP_ADOLSC: A10" ,
   "NQF2019_0418: REFERRAL_DEP_ADOLSC: D10" ,
   "NQF2019_0418: REFERRAL_DEP_ADOLSC: D11" ,
   "NQF2019_0418: REFERRAL_DEP_ADOLSC: E10" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: A11" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: D11" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: E11" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: A12" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: D12" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: E12" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: L11" ,
   "NQF2019_0418: INTERVENTION_ADOLSC: L12" ,
   "NQF2019_0418: DEP_MED_ADOLSC: M12" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    person_pos = 0 ,
    adolsc_dep_screen_dt_tm = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,adolsc_dep_screen_dt_tm = cnvtdatetime (lh_ep_reply->persons[
     person_pos ].special_cond_dt_tm )
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].special_group = 20 ) )
     IF ((cnvtdate (pat.ep_dt_tm ) = cnvtdate (adolsc_dep_screen_dt_tm ) ) ) lh_ep_reply->persons[
      person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";get outcome - the combination of three decision points" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";get outcome - no intervention due to patient/medical reason (negation check)" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("NQF2019_0418: NEGATION: E13" ,
   "NQF2019_0418: NEGATION: E14" ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,enc_pos = 0
   DETAIL
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].special_group IN (20 ,
    - (20 ) ) ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,lh_ep_reply->persons[person_pos
     ].outcome = "Denominator Exception"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";;get outcome - no intervention due to patient/medical reason (negation check)" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf418 (null )
  CALL getnonmappednomenclature ("DEP_SCREEN_ENC_CDS" ,"0418" ,"'CPT4','HCPCS'" ,"1=1" )
  CALL getepdata ("MU_EC_0418_2019" ,br_filters->provider_attribution ,"NQF2019_0418" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf419 (null ) = null
 DECLARE getpopulation_nqf419 (null ) = null
 DECLARE getattribution_nqf419 (null ) = null
 DECLARE getexceptions_nqf419 (null ) = null
 DECLARE getoutcome_nqf419 (null ) = null
 DECLARE check_med_recncln ((encntr_id = f8 ) ) = null
 SUBROUTINE  getresults_nqf419 (null )
  SET br_filters->provider_attribution = getproviderattribution ("419" )
  CALL geteprfilter ("419" )
  CALL getpopulation_nqf419 (0 )
  CALL getattribution_nqf419 (0 )
  CALL getoutcome_nqf419 (0 )
  CALL getexceptions_nqf419 (0 )
  CALL summaryreport ("MU_EC_0419_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf419 (null )
  DECLARE p_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE e_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE p_batch_size = i4 WITH constant (10000 ) ,protect
  DECLARE e_batch_size = i4 WITH constant (10 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
   CALL echo (build ("debug: logical_domain_id_parser:" ,logical_domain_id_parser ) )
   CALL echo (build ("debug: org_id_parser:" ,org_id_parser ) )
   CALL echo (build ("debug: location_filter:" ,location_filter ) )
   CALL echorecord (lh_excl_loc )
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0419: A1" ,
    "POPULATION: NQF2019_0419: B1" ,
    "POPULATION: NQF2019_0419: C1" ,
    "POPULATION: NQF2019_0419: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    p_total_size = p_batch_size ,
    stat = alterlist (lh_ep_reply->persons ,p_total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((personcnt > p_total_size ) ) p_total_size = (p_total_size + p_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons ,p_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->person_cnt = personcnt ,encntrcnt = 0 ,e_total_size = 10 ,stat
    = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
   HEAD pop.encntr_id
    encntrcnt = (encntrcnt + 1 ) ,
    IF ((encntrcnt > e_total_size ) ) e_total_size = (e_total_size + e_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons[personcnt ].encntrs ,e_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome =
    "Not Met, Not Done" ,lh_ep_reply->persons[personcnt ].encntr_cnt = encntrcnt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf419 (null )
  CALL getnonmappednomenclature ("MEDS_ENCOUNTER_CS_ENC" ,"0419" ,"'CPT4','HCPCS'" ,"1=1" )
  CALL getepdata ("MU_EC_0419_2019" ,br_filters->provider_attribution ,"NQF2019_0419" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf419 (null )
  DECLARE p_iter = i4 WITH protect ,noconstant (0 )
  DECLARE e_iter = i4 WITH protect ,noconstant (0 )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,1 ,lh_ep_reply->persons[iter1 ].ep_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0419: CURR_MED_DOC: E1" ,
    "NQF2019_0419: CURR_MED_DOC: A1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].ep_ind = 1 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) AND
      cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) ) lh_ep_reply->persons[
       pos ].encntrs[i ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
       "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Numerator" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  IF ((validate (temp_request ) = 0 ) )
   RECORD temp_request (
     1 person_id = f8
     1 encounter_id = f8
     1 ppr_cd = f8
     1 inpatient_encounter_filter
       2 all_encounter_ind = i2
       2 focus_encounter_ind = i2
     1 load_admission_status_ind = i2
     1 load_discharge_status_ind = i2
     1 hide_discont_orders_amdin = i2
     1 hide_discont_orders_disch = i2
     1 override_org_security_ind = i2
     1 load_transfer_status_ind = i2
   ) WITH public
  ENDIF
  IF ((validate (temp_reply ) = 0 ) )
   RECORD temp_reply (
     1 admission_status
       2 incomplete_ind = i2
       2 complete_ind = i2
       2 performed_dt_tm = dq8
       2 performed_tz = i4
       2 performed_prsnl_id = f8
       2 performed_person_name = vc
       2 not_started_ind = i2
       2 pending_complete_ind = i2
       2 pending_partial_ind = i2
       2 cross_encntr_ind = i2
     1 discharge_status
       2 incomplete_ind = i2
       2 complete_ind = i2
       2 performed_dt_tm = dq8
       2 performed_tz = i4
       2 performed_prsnl_id = f8
       2 performed_person_name = vc
       2 not_started_ind = i2
       2 pending_complete_ind = i2
       2 pending_partial_ind = i2
       2 cross_encntr_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH public
  ENDIF
  CALL lhprint (";checking medication reconciliation" )
  CALL beg_time (0 )
  SET stat = initrec (lh_med_recs )
  SET med_rec_cnt = 0
  SET lh_med_recs->med_rec_cnt = 0
  FOR (p_iter = 1 TO size (lh_ep_reply->persons ,5 ) )
   FOR (e_iter = 1 TO size (lh_ep_reply->persons[p_iter ].encntrs ,5 ) )
    IF ((lh_ep_reply->persons[p_iter ].encntrs[e_iter ].outcome_ind != 1 ) )
     CALL check_med_recncln (lh_ep_reply->persons[p_iter ].encntrs[e_iter ].encntr_id )
     IF ((((temp_reply->discharge_status.complete_ind = 1 )
     AND (temp_reply->discharge_status.performed_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[
      p_iter ].encntrs[e_iter ].reg_dt_tm ) AND cnvtdatetime (lh_ep_reply->persons[p_iter ].encntrs[
      e_iter ].disch_dt_tm ) ) ) OR ((temp_reply->admission_status.complete_ind = 1 )
     AND (temp_reply->admission_status.performed_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[
      p_iter ].encntrs[e_iter ].reg_dt_tm ) AND cnvtdatetime (lh_ep_reply->persons[p_iter ].encntrs[
      e_iter ].disch_dt_tm ) ) )) )
      SET lh_ep_reply->persons[p_iter ].encntrs[e_iter ].outcome_ind = 1
      SET lh_ep_reply->persons[p_iter ].encntrs[e_iter ].outcome = "Met, Done"
      SET med_rec_cnt = (size (lh_med_recs->qual ,5 ) + 1 )
      SET stat = alterlist (lh_med_recs->qual ,med_rec_cnt )
      SET lh_med_recs->qual[med_rec_cnt ].encntr_id = lh_ep_reply->persons[p_iter ].encntrs[e_iter ].
      encntr_id
      IF ((temp_reply->discharge_status.performed_dt_tm > 0 ) )
       SET lh_med_recs->qual[med_rec_cnt ].rec_ep_dt_tm = temp_reply->discharge_status.
       performed_dt_tm
      ELSE
       SET lh_med_recs->qual[med_rec_cnt ].rec_ep_dt_tm = temp_reply->admission_status.
       performed_dt_tm
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
  ENDFOR
  SET lh_med_recs->med_rec_cnt = med_rec_cnt
  CALL end_time (0 )
  SET stat = initrec (temp_request )
  SET stat = initrec (temp_reply )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexceptions_nqf419 (null )
  DECLARE p_iter = i4 WITH protect ,noconstant (0 )
  DECLARE e_iter = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get exception" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (p_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     p_iter ].person_id ,1 ,lh_ep_reply->persons[pos ].ep_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name = "NQF2019_0419: NEGATION: E2" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (e_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[e_iter ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].ep_ind = 1 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) AND
      cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) ) lh_ep_reply->persons[
       pos ].encntrs[i ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
       "Denominator Exception"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Exception" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  check_med_recncln (encntr_id )
  SET stat = initrec (temp_request )
  SET stat = initrec (temp_reply )
  SET temp_request->encounter_id = encntr_id
  SET temp_request->inpatient_encounter_filter.all_encounter_ind = 0
  SET temp_request->inpatient_encounter_filter.focus_encounter_ind = 1
  SET temp_request->load_admission_status_ind = 1
  SET temp_request->load_discharge_status_ind = 1
  SET temp_request->override_org_security_ind = 1
  SET temp_request->hide_discont_orders_amdin = 1
  SET temp_request->hide_discont_orders_disch = 1
  EXECUTE orm_get_reconciliation_status WITH replace ("REQUEST" ,temp_request ) ,
  replace ("REPLY" ,temp_reply )
 END ;Subroutine
 DECLARE getresults_nqf421 (null ) = null
 DECLARE getpopulation_nqf421 (null ) = null
 DECLARE getoutcome_nqf421 (null ) = null
 DECLARE getattribution_nqf421 (null ) = null
 DECLARE getexclusions_nqf421 (null ) = null
 DECLARE getexceptions_nqf421 (null ) = null
 DECLARE underweight_limit = f8 WITH noconstant (18.5 )
 DECLARE overweight_limit = f8 WITH noconstant (25.0 )
 SUBROUTINE  getresults_nqf421 (null )
  SET br_filters->provider_attribution = getproviderattribution ("421" )
  CALL geteprfilter ("421" )
  CALL getpopulation_nqf421 (0 )
  CALL getattribution_nqf421 (0 )
  CALL getexclusions_nqf421 (0 )
  CALL getoutcome_nqf421 (0 )
  CALL getexceptions_nqf421 (null )
  CALL summaryreport ("MU_EC_0421_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf421 (null )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0421" )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("17,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id ,
    pop.reg_dt_tm
   HEAD REPORT
    personcnt = 0 ,
    total_size = 10000 ,
    batch_size = 5000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done"
   HEAD pop.encntr_id
    birth_check = 0 ,
    IF ((nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (pop.reg_dt_tm ) ) ) ) birth_check = 1
    ENDIF
    ,
    IF ((birth_check = 1 ) ) lh_ep_reply->persons[personcnt ].exclude_ind = 0 ,encntrcnt = (
     lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].encntr_cnt
     = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
     lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
     persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
     personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
     IF ((((pop.disch_dt_tm != null ) ) OR ((pop.disch_dt_tm != 0 ) )) ) lh_ep_reply->persons[
      personcnt ].encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm
     ELSE lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].disch_dt_tm = cnvtlookahead ("23,H" ,
       cnvtdatetimeutc (datetimetrunc (pop.reg_dt_tm ,"dd" ) ,2 ) )
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After Initial Population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getattribution_nqf421 (null )
  CALL getnonmappednomenclature ("BMI_ENC_CODE_SET" ,"0421" ,"'CPT4','HCPCS','SNMCT','CDT'" ,"1=1" )
  CALL getepdata (measure ,br_filters->provider_attribution ,"NQF2019_0421" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusions_nqf421 (null )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE person_iter = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE exclusion_check = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";getExclusions_NQF421" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind ,1 ,lh_ep_reply->persons[iter1 ].
     ep_ind ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0421: PALLIATIVE_CARE: A2" ,
    "NQF2019_0421: PALLIATIVE_CARE: D2" ,
    "NQF2019_0421: PALLIATIVE_CARE: D3" ,
    "NQF2019_0421: PALLIATIVE_CARE: E2" ,
    "NQF2019_0421: PALLIATIVE_CARE_ENC: F2" ,
    "NQF2019_0421: PALLIATIVE_CARE_ENC: G2" ,
    "NQF2019_0421: PREGNANCY_DX: F4" ,
    "NQF2019_0421: PREGNANCY_DX: G4" ,
    "NQF2019_0421: PREGNANCY_DX: H4" ,
    "NQF2019_0421: NEGATION: E2" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    person_pos = locateval (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[person_iter ].person_id ) ,exclusion_check = 0
   DETAIL
    IF ((person_pos > 0 ) )
     CASE (qry.query_name )
      OF "NQF2019_0421: PALLIATIVE_CARE_ENC: F2" :
      OF "NQF2019_0421: PALLIATIVE_CARE_ENC: G2" :
      OF "NQF2019_0421: PALLIATIVE_CARE: A2" :
      OF "NQF2019_0421: PALLIATIVE_CARE: D2" :
      OF "NQF2019_0421: PALLIATIVE_CARE: D3" :
      OF "NQF2019_0421: PALLIATIVE_CARE: E2" :
      OF "NQF2019_0421: NEGATION: E2" :
       FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
        IF ((qry.query_name = "NQF2019_0421: NEGATION: E2" ) )
         IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[person_pos ].encntrs[enc_i ].reg_dt_tm AND
         lh_ep_reply->persons[person_pos ].encntrs[enc_i ].disch_dt_tm ) ) exclusion_check = (
          exclusion_check + 1 )
         ENDIF
        ELSE
         IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
          disch_dt_tm ) ) ) exclusion_check = (exclusion_check + 1 )
         ENDIF
        ENDIF
       ENDFOR
      OF "NQF2019_0421: PREGNANCY_DX: F4" :
      OF "NQF2019_0421: PREGNANCY_DX: G4" :
       IF ((pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
       AND (diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) )
        exclusion_check = (exclusion_check + 1 )
       ENDIF
      OF "NQF2019_0421: PREGNANCY_DX: H4" :
       IF ((checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.end_effective_dt_tm ) = 1 ) )
        exclusion_check = (exclusion_check + 1 )
       ENDIF
     ENDCASE
    ENDIF
   FOOT  pat.person_id
    IF ((exclusion_check > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->
     persons[person_pos ].outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After exclusion check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf421 (null )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE iter2 = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE enc_i = i4 WITH protect ,noconstant (0 )
  DECLARE 12_mo_prior_to_beg_extract = dq8 WITH protect ,constant (datetimeadd (cnvtlookbehind (
     "13,M" ,cnvtdatetime (beg_extract_dt_tm ) ) ,1 ) )
  DECLARE datediff = i4 WITH protect ,noconstant (0 )
  DECLARE date_check = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";Recent BMI documented in the range?" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind ,1 ,lh_ep_reply->persons[iter1 ].
     ep_ind ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (12_mo_prior_to_beg_extract ) AND cnvtdatetime (
     end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0421: BMI_VS: E5" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm DESC
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,datediff = 0 ,person_flag = 0
   DETAIL
    IF ((person_pos > 0 )
    AND (person_flag = 0 ) )
     FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      datediff = lhgetdatetimedifference (cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[
        enc_i ].disch_dt_tm ) ,cnvtdatetime (pat.ep_dt_tm ) ,"MO" ) ,
      IF ((((datediff >= 0 )
      AND (datediff <= 12 ) ) OR ((pat.encntr_id = lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
      encntr_id ) )) ) person_flag = 1 ,
       IF ((cnvtreal (pat.ce_result_val ) >= overweight_limit ) ) lh_ep_reply->persons[person_pos ].
        special_group = 6
       ELSEIF ((cnvtreal (pat.ce_result_val ) < underweight_limit ) ) lh_ep_reply->persons[
        person_pos ].special_group = 5
       ELSEIF ((cnvtreal (pat.ce_result_val ) >= underweight_limit )
       AND (cnvtreal (pat.ce_result_val ) < overweight_limit ) ) lh_ep_reply->persons[person_pos ].
        special_group = 1 ,lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[
        person_pos ].outcome = "Met, Normal BMI"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Follow up of underweight and overweight" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind ,1 ,lh_ep_reply->persons[iter1 ].
     ep_ind ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (12_mo_prior_to_beg_extract ) AND cnvtdatetime (
     end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0421" )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0421: ABOVE_FOLLOW_UP_POC: A6" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_POC: B6" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_POC: C6" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_POC: D6" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_POC: K6" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_RSLT: E7" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_RSLT: L7" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_RSLT: L8" ,
    "NQF2019_0421: ABOVE_NORMAL_MEDICATION: M8" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_POC: A9" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_POC: B9" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_POC: C9" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_POC: D9" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_POC: K9" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_RSLT: E10" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_RSLT: L10" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_RSLT: L11" ,
    "NQF2019_0421: BELOW_NORMAL_MEDICATION: M11" ,
    "NQF2019_0421: FOLLOW_UP_PROC: A7" ,
    "NQF2019_0421: FOLLOW_UP_PROC: D7" ,
    "NQF2019_0421: FOLLOW_UP_PROC: D8" ,
    "NQF2019_0421: ABOVE_FOLLOW_UP_PAT_EDU: P12" ,
    "NQF2019_0421: BELOW_FOLLOW_UP_PAT_EDU: P13" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    datediff = 0 ,
    date_check = 0 ,
    IF ((person_pos > 0 )
    AND (lh_ep_reply->persons[person_pos ].special_group IN (5 ,
    6 ) )
    AND (lh_ep_reply->persons[person_pos ].outcome_ind != 1 ) )
     FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      datediff = lhgetdatetimedifference (cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[
        enc_i ].disch_dt_tm ) ,cnvtdatetime (pat.ep_dt_tm ) ,"MO" ) ,
      IF ((((datediff >= 0 )
      AND (datediff <= 12 ) ) OR ((pat.encntr_id = lh_ep_reply->persons[person_pos ].encntrs[enc_i ].
      encntr_id ) )) ) date_check = 1
      ENDIF
     ENDFOR
     ,
     IF ((qry.query_name = "NQF2019_0421*ABOVE*" ) )
      IF ((date_check = 1 )
      AND (lh_ep_reply->persons[person_pos ].special_group = 6 ) ) lh_ep_reply->persons[person_pos ].
       outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ELSEIF ((qry.query_name = "NQF2019_0421*BELOW*" ) )
      IF ((date_check = 1 )
      AND (lh_ep_reply->persons[person_pos ].special_group = 5 ) ) lh_ep_reply->persons[person_pos ].
       outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ELSEIF ((qry.query_name = "NQF2019_0421: FOLLOW_UP_PROC:*" ) )
      IF ((date_check = 1 )
      AND (((lh_ep_reply->persons[person_pos ].special_group = 5 ) ) OR ((lh_ep_reply->persons[
      person_pos ].special_group = 6 ) )) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,
       lh_ep_reply->persons[person_pos ].outcome = "Met, Done"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexceptions_nqf421 (null )
  DECLARE iter1 = i4 WITH protect ,noconstant (0 )
  DECLARE iter2 = i4 WITH protect ,noconstant (0 )
  DECLARE person_pos = i4 WITH protect ,noconstant (0 )
  DECLARE enc_i = i4 WITH protect ,noconstant (0 )
  DECLARE 12_mo_prior_to_beg_extract = dq8 WITH protect ,constant (datetimeadd (cnvtlookbehind (
     "13,M" ,cnvtdatetime (beg_extract_dt_tm ) ) ,1 ) )
  CALL lhprint (";getExceptions_NQF421" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind ,1 ,lh_ep_reply->persons[iter1 ].
     ep_ind ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (12_mo_prior_to_beg_extract ) AND cnvtdatetime (
     end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_0421" )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0421: NEGATION: E14" ,
    "NQF2019_0421: NEGATION: E15" ,
    "NQF2019_0421: NEGATION: E16" ,
    "NQF2019_0421: NEGATION: E17" ,
    "NQF2019_0421: NEGATION: E18" ,
    "NQF2019_0421: NEGATION: E19" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    person_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    datediff = 0 ,
    IF ((person_pos > 0 ) )
     FOR (enc_i = 1 TO size (lh_ep_reply->persons[person_pos ].encntrs ,5 ) )
      datediff = lhgetdatetimedifference (cnvtdatetime (lh_ep_reply->persons[person_pos ].encntrs[
        enc_i ].disch_dt_tm ) ,cnvtdatetime (pat.ep_dt_tm ) ,"MO" ) ,
      IF ((datediff >= 0 )
      AND (datediff <= 12 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 3 ,lh_ep_reply->
       persons[person_pos ].outcome = "Denominator Exception"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 DECLARE getresults_nqf710 (null ) = null
 DECLARE getpopulation_nqf710 (null ) = null
 DECLARE getexclusion_nqf710 (null ) = null
 DECLARE getattribution_nqf710 ((measure_name = vc ) ) = null
 DECLARE getoutcome_nqf710 (null ) = null
 DECLARE getagegroup_nqf710 ((rec_name = vc (ref ) ) ,(grp = i2 ) ) = null
 SUBROUTINE  getresults_nqf710 (null )
  DECLARE beg_dt_tm = dq8 WITH noconstant (0 ) ,protect
  DECLARE end_dt_tm = dq8 WITH noconstant (0 ) ,protect
  DECLARE beg_extract_dt_tm_710 = dq8 WITH protect ,noconstant (cnvtlookahead ("1,S" ,cnvtlookbehind
    ("14,M" ,beg_extract_dt_tm ) ) )
  DECLARE end_extract_dt_tm_710 = dq8 WITH protect ,noconstant (cnvtlookbehind ("1,S" ,
    cnvtlookbehind ("2,M" ,beg_extract_dt_tm ) ) )
  CALL geteprfilter ("710" )
  CALL getpopulation_nqf710 (0 )
  SET beg_dt_tm = beg_extract_dt_tm
  SET end_dt_tm = end_extract_dt_tm
  SET beg_extract_dt_tm = beg_extract_dt_tm_710
  SET end_extract_dt_tm = end_extract_dt_tm_710
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = moverec (lh_ep_reply ,lh_ep_reply_bk )
  CALL getagegroup_nqf710 (lh_ep_reply ,1 )
  CALL getattribution_nqf710 ("MU_EC_0710_2019.1" )
  SET beg_extract_dt_tm = beg_dt_tm
  SET end_extract_dt_tm = end_dt_tm
  CALL getexclusion_nqf710 (0 )
  CALL getoutcome_nqf710 (0 )
  CALL summaryreport ("MU_EC_0710_2019.1" )
  SET stat = initrec (lh_ep_reply )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  CALL getagegroup_nqf710 (lh_ep_reply ,2 )
  SET beg_extract_dt_tm = beg_extract_dt_tm_710
  SET end_extract_dt_tm = end_extract_dt_tm_710
  CALL getattribution_nqf710 ("MU_EC_0710_2019.2" )
  SET beg_extract_dt_tm = beg_dt_tm
  SET end_extract_dt_tm = end_dt_tm
  CALL getexclusion_nqf710 (0 )
  CALL getoutcome_nqf710 (0 )
  CALL summaryreport ("MU_EC_0710_2019.2" )
  CALL sum_submeasures ("MU_EC_0710_2019.1" ,"MU_EC_0710_2019.2" ,"MU_EC_0710_2019.3" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf710 (null )
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE birth_check = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial population query to get Office Visit and Psych Visit encounter" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.disch_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_710 ) AND cnvtdatetime (
     end_extract_dt_tm_710 ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0710: A1" ,
    "POPULATION: NQF2019_0710: B1" ,
    "POPULATION: NQF2019_0710: C1" ,
    "POPULATION: NQF2019_0710: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("12,Y" ,
     cnvtdatetime (beg_extract_dt_tm_710 ) ) )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat =
    alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[personcnt ].birth_date = p.birth_dt_tm ,lh_ep_reply->persons[
    personcnt ].deceased_date = p.deceased_dt_tm ,lh_ep_reply->persons[personcnt ].mrn = pop
    .comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ]
    .outcome = "Not Met, Not Done" ,lh_ep_reply->persons[personcnt ].age = floor ((datetimediff (
      cnvtdatetime (beg_extract_dt_tm_710 ) ,p.birth_dt_tm ) / 365.25 ) ) ,lh_ep_reply->persons[
    personcnt ].exclude_ind = 1
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].exclude_ind = 1 ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint ("Check for diagnosis and charge diagnosis" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_710 ) AND cnvtdatetime (
     end_extract_dt_tm_710 ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0710: MAJ_DEP_DIAG: F2" ,
    "NQF2019_0710: MAJ_DEP_DIAG: G2" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
      ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->
       persons[pos ].encntrs[i ].exclude_ind = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Check for Problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (((pat.end_effective_dt_tm >= cnvtdatetime (beg_extract_dt_tm_710 ) ) ) OR ((pat
    .end_effective_dt_tm = null ) ))
    AND (nullcheck (pat.onset_dt_tm ,pat.beg_effective_dt_tm ,nullind (pat.onset_dt_tm ) ) <=
    cnvtdatetime (end_extract_dt_tm_710 ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0710: MAJ_DEP_DIAG: H2" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
      ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->
       persons[pos ].encntrs[i ].exclude_ind = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   SET lh_ep_reply->persons[i ].exclude_ind = 1
   FOR (j = 1 TO size (lh_ep_reply->persons[i ].encntrs ,5 ) )
    SET lh_ep_reply->persons[i ].encntrs[j ].exclude_ind = 1
   ENDFOR
  ENDFOR
  CALL lhprint ("Check for PHQ 9 Tool on qualifying encounters" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (isnumeric (pat.ce_result_val ) > 0 ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name = "NQF2019_0710: PHQ_RESULT: E1" ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD pat.person_id
    birth_check = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id ) ,lh_ep_reply->persons[pos ].exclude_ind = 0 ,
    IF ((lh_ep_reply->persons[pos ].birth_date <= cnvtlookbehind ("12,Y" ,cnvtdatetime (pat.ep_dt_tm
      ) ) ) ) birth_check = 1
    ENDIF
   DETAIL
    IF ((pos > 0 )
    AND (birth_check = 1 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm AND lh_ep_reply->
      persons[pos ].encntrs[i ].disch_dt_tm )
      AND (cnvtreal (pat.ce_result_val ) > 9.0 ) ) lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind
        = 0 ,
       IF ((lh_ep_reply->persons[pos ].first_encntr_date = 0 ) ) lh_ep_reply->persons[pos ].
        first_encntr_date = pat.ep_dt_tm
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Calculation of denominator" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf710 (measure_name )
  CALL getnonmappednomenclature ("CONTACT_OR_OFFICE_VISIT" ,"0710" ,"'CPT4'" ,"1=1" )
  CALL getepdata (measure_name ,br_filters->provider_attribution ,"NQF2019_0710" )
  IF ((debug_ind = 1 ) )
   CALL echo (build2 ("After attribution: measure=" ,measure_name ) )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf710 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE exc_ind = i4 WITH noconstant (0 ) ,protect
  CALL lhprint ("Get Exclusions for deceased_date filter" )
  CALL beg_time (0 )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((lh_ep_reply->persons[i ].outcome_ind = 0 )
   AND (lh_ep_reply->persons[i ].deceased_date != null )
   AND (lh_ep_reply->persons[i ].deceased_date < cnvtdatetime (cnvtlookahead ("14,M" ,cnvtdatetime (
      lh_ep_reply->persons[i ].first_encntr_date ) ) ) ) )
    SET lh_ep_reply->persons[i ].outcome_ind = 2
    SET lh_ep_reply->persons[i ].outcome = "Denominator Exclusion"
   ENDIF
  ENDFOR
  CALL end_time (0 )
  CALL lhprint ("Get Exclusions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.query_name IN ("NQF2019_0710: CARE_SRV_ENC: A3" ,
   "NQF2019_0710: CARE_SRV_ENC: B3" ,
   "NQF2019_0710: CARE_SRV_ENC: C3" ,
   "NQF2019_0710: CARE_SRV_ENC: D3" ,
   "NQF2019_0710: BIPOLAR_DISORDER: F5" ,
   "NQF2019_0710: PERSONALITY_DISORDER: F6" ,
   "NQF2019_0710: BIPOLAR_DISORDER: G5" ,
   "NQF2019_0710: PERSONALITY_DISORDER: G6" ,
   "NQF2019_0710: BIPOLAR_DISORDER: H5" ,
   "NQF2019_0710: PERSONALITY_DISORDER: H6" ,
   "NQF2019_0710: PSYCHOTIC_DISORDER: F7" ,
   "NQF2019_0710: PSYCHOTIC_DISORDER: G7" ,
   "NQF2019_0710: PSYCHOTIC_DISORDER: H7" ,
   "NQF2019_0710: PERVASIVE_DISORDER: F8" ,
   "NQF2019_0710: PERVASIVE_DISORDER: G8" ,
   "NQF2019_0710: PERVASIVE_DISORDER: F8" ,
   "NQF2019_0710: PALLIATIVE_PROC: A6" ,
   "NQF2019_0710: PALLIATIVE_PROC: D6" ,
   "NQF2019_0710: PALLIATIVE_PROC: E6" ,
   "NQF2019_0710: PALLIATIVE_PROC: D7" ,
   "NQF2019_0710: PALLIATIVE_CARE_ENC: F6" ,
   "NQF2019_0710: PALLIATIVE_CARE_ENC: G6" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    exc_ind = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    exc_ind = 0 ,
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0710: PALLIATIVE_PROC:*" ) ) ) exc_ind = 1
     ENDIF
     ,
     IF ((((exc_ind = 1 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (cnvtlookahead ("10,M" ,cnvtdatetime (lh_ep_reply->
        persons[pos ].first_encntr_date ) ) ) AND cnvtdatetime (cnvtlookahead ("14,M" ,cnvtdatetime (
        lh_ep_reply->persons[pos ].first_encntr_date ) ) ) ) ) OR ((exc_ind = 0 )
     AND (pat.ep_dt_tm < cnvtdatetime (cnvtlookahead ("14,M" ,cnvtdatetime (lh_ep_reply->persons[pos
        ].first_encntr_date ) ) ) ) )) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->
      persons[pos ].outcome = "Denominator Exclusion"
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf710 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE month_check_flag_occa = i2 WITH noconstant (0 ) ,protect
  DECLARE month_check_flag_occb = i2 WITH noconstant (0 ) ,protect
  DECLARE month_check_flag_occc = i2 WITH noconstant (0 ) ,protect
  CALL lhprint ("Get outcomes" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.query_name = "NQF2019_0710: PHQ_RESULT: E1" )
   AND (qry.active_ind = 1 )
   AND (isnumeric (pat.ce_result_val ) > 0 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     IF ((cnvtreal (pat.ce_result_val ) < 5 )
     AND (lh_ep_reply->persons[pos ].outcome_ind != 2 )
     AND (pat.ep_dt_tm BETWEEN cnvtdatetime (cnvtlookahead ("10,M" ,cnvtdatetime (lh_ep_reply->
        persons[pos ].first_encntr_date ) ) ) AND cnvtdatetime (cnvtlookahead ("14,M" ,cnvtdatetime (
        lh_ep_reply->persons[pos ].first_encntr_date ) ) ) ) ) lh_ep_reply->persons[pos ].outcome =
      "Met, Done" ,lh_ep_reply->persons[pos ].outcome_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getagegroup_nqf710 (rec_name ,grp )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO size (rec_name->persons ,5 ) )
   IF ((grp = 1 )
   AND (rec_name->persons[i ].age > 17 ) )
    SET rec_name->persons[i ].exclude_ind = 1
   ELSEIF ((grp = 2 )
   AND (rec_name->persons[i ].age < 18 ) )
    SET rec_name->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
 END ;Subroutine
 DECLARE getresults_nqf712 (null ) = null
 DECLARE processmeasure_nqf712 ((measure = i2 ) ,(age_grp = i2 ) ) = null
 DECLARE getbegdate_nqf712 ((measure = i2 ) ) = dq8
 DECLARE getenddate_nqf712 ((measure = i2 ) ) = dq8
 DECLARE getpopulation_nqf712 (null ) = null
 DECLARE getexclusion_nqf712 (null ) = null
 DECLARE getattribution_nqf712 ((measuremean = vc ) ) = null
 DECLARE getoutcome_nqf712 (null ) = null
 DECLARE getagegroup_nqf712 ((rec_name = vc (ref ) ) ,(grp = i2 ) ) = null
 SUBROUTINE  getresults_nqf712 (null )
  DECLARE beg_extract_dt_tm_712 = dq8 WITH protect ,noconstant (0 )
  DECLARE end_extract_dt_tm_712 = dq8 WITH protect ,noconstant (0 )
  CALL geteprfilter ("712" )
  CALL lhprint ("/**** Measure:MU_EC_0712_2019.1.1 and MU_EC_0712_2019.1.2 ****/" )
  SET beg_extract_dt_tm_712 = getbegdate_nqf712 (1 )
  SET end_extract_dt_tm_712 = getenddate_nqf712 (1 )
  SET stat = initrec (lh_ep_reply_bk )
  CALL processmeasure_nqf712 (1 ,1 )
  CALL summaryreport ("MU_EC_0712_2019.1.1" )
  SET stat = initrec (lh_ep_reply )
  CALL processmeasure_nqf712 (1 ,2 )
  CALL summaryreport ("MU_EC_0712_2019.1.2" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  CALL sum_submeasures ("MU_EC_0712_2019.1.1" ,"MU_EC_0712_2019.1.2" ,"MU_EC_0712_2019.1.3" )
  CALL lhprint ("/**** Measure:MU_EC_0712_2019.2.1 and MU_EC_0712_2019.2.2 ****/" )
  SET beg_extract_dt_tm_712 = getbegdate_nqf712 (2 )
  SET end_extract_dt_tm_712 = getenddate_nqf712 (2 )
  CALL processmeasure_nqf712 (2 ,1 )
  CALL summaryreport ("MU_EC_0712_2019.2.1" )
  SET stat = initrec (lh_ep_reply )
  CALL processmeasure_nqf712 (2 ,2 )
  CALL summaryreport ("MU_EC_0712_2019.2.2" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  CALL sum_submeasures ("MU_EC_0712_2019.2.1" ,"MU_EC_0712_2019.2.2" ,"MU_EC_0712_2019.2.3" )
  CALL lhprint ("/**** Measure:MU_EC_0712_2019.3.1 & MU_EC_0712_2019.3.2 ****/" )
  SET beg_extract_dt_tm_712 = getbegdate_nqf712 (3 )
  SET end_extract_dt_tm_712 = getenddate_nqf712 (3 )
  CALL processmeasure_nqf712 (3 ,1 )
  CALL summaryreport ("MU_EC_0712_2019.3.1" )
  SET stat = initrec (lh_ep_reply )
  CALL processmeasure_nqf712 (3 ,2 )
  CALL summaryreport ("MU_EC_0712_2019.3.2" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  SET stat = initrec (br_filters )
  CALL sum_submeasures ("MU_EC_0712_2019.3.1" ,"MU_EC_0712_2019.3.2" ,"MU_EC_0712_2019.3.3" )
 END ;Subroutine
 SUBROUTINE  processmeasure_nqf712 (measure ,age_grp )
  DECLARE beg_dt_tmp = dq8 WITH noconstant (0 ) ,protect
  DECLARE end_dt_tmp = dq8 WITH noconstant (0 ) ,protect
  SET beg_dt_tmp = beg_extract_dt_tm
  SET end_dt_tmp = end_extract_dt_tm
  SET beg_extract_dt_tm = beg_extract_dt_tm_712
  SET end_extract_dt_tm = end_extract_dt_tm_712
  CALL getpopulation_nqf712 (0 )
  CALL getagegroup_nqf712 (lh_ep_reply ,age_grp )
  IF ((measure = 1 ) )
   IF ((age_grp = 1 ) )
    CALL getattribution_nqf712 ("MU_EC_0712_2019.1.1" )
   ELSE
    CALL getattribution_nqf712 ("MU_EC_0712_2019.1.2" )
   ENDIF
  ELSEIF ((measure = 2 ) )
   IF ((age_grp = 1 ) )
    CALL getattribution_nqf712 ("MU_EC_0712_2019.2.1" )
   ELSE
    CALL getattribution_nqf712 ("MU_EC_0712_2019.2.2" )
   ENDIF
  ELSEIF ((measure = 3 ) )
   IF ((age_grp = 1 ) )
    CALL getattribution_nqf712 ("MU_EC_0712_2019.3.1" )
   ELSE
    CALL getattribution_nqf712 ("MU_EC_0712_2019.3.2" )
   ENDIF
  ENDIF
  CALL getexclusion_nqf712 (0 )
  CALL getoutcome_nqf712 (0 )
  SET beg_extract_dt_tm = beg_dt_tmp
  SET end_extract_dt_tm = end_dt_tmp
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf712 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial population query to get Office Visit and Psych Visit encounter" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.disch_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_712 ) AND cnvtdatetime (
     end_extract_dt_tm_712 ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_0712: A1" ,
    "POPULATION: NQF2019_0712: B1" ,
    "POPULATION: NQF2019_0712: C1" ,
    "POPULATION: NQF2019_0712: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("12,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat =
    alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[personcnt ].birth_date = p.birth_dt_tm ,lh_ep_reply->persons[
    personcnt ].deceased_date = p.deceased_dt_tm ,lh_ep_reply->persons[personcnt ].mrn = pop
    .comm_mrn_txt ,lh_ep_reply->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ]
    .outcome = "Not Met, Not Done" ,lh_ep_reply->persons[personcnt ].age = floor ((datetimediff (
      cnvtdatetime (beg_extract_dt_tm ) ,p.birth_dt_tm ) / 365.25 ) ) ,lh_ep_reply->persons[
    personcnt ].exclude_ind = 1
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].
    encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].exclude_ind = 1 ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Check for diagnosis" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_712 ) AND cnvtdatetime (
     end_extract_dt_tm_712 ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_0712: MAJ_DEP_DIAG: F1" ,
    "NQF2019_0712: MAJ_DEP_DIAG: G1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].encntr_id = pat.encntr_id )
      AND (pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
      ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->
       persons[pos ].encntrs[i ].exclude_ind = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Check for Problem" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 )
    AND (((pat.end_effective_dt_tm >= cnvtdatetime (beg_extract_dt_tm_712 ) ) ) OR ((pat
    .end_effective_dt_tm = null ) ))
    AND (nullcheck (pat.onset_dt_tm ,pat.beg_effective_dt_tm ,nullind (pat.onset_dt_tm ) ) <=
    cnvtdatetime (end_extract_dt_tm_712 ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_0712: MAJ_DEP_DIAG: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
      ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->
       persons[pos ].encntrs[i ].exclude_ind = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After initial population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf712 (measuremean )
  CALL getnonmappednomenclature ("CONNECT_OFFICE_VISIT" ,"0712" ,"'CPT4'" ,"1=1" )
  CALL getepdata (measuremean ,br_filters->provider_attribution ,"NQF2019_0712" )
  IF ((debug_ind = 1 ) )
   CALL echo (build2 ("After attribution: measure=" ,measuremean ) )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf712 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE exc_ind = i2 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  CALL lhprint ("Get Exclusions for deceased_date filter" )
  CALL beg_time (0 )
  FOR (i = 1 TO size (lh_ep_reply->persons ,5 ) )
   IF ((lh_ep_reply->persons[i ].outcome_ind = 0 )
   AND (lh_ep_reply->persons[i ].deceased_date != null )
   AND (lh_ep_reply->persons[i ].deceased_date BETWEEN cnvtdatetime (beg_extract_dt_tm_712 ) AND
   cnvtdatetime (end_extract_dt_tm_712 ) ) )
    SET lh_ep_reply->persons[i ].outcome_ind = 2
    SET lh_ep_reply->persons[i ].outcome = "Denominator Exclusion"
   ENDIF
  ENDFOR
  CALL end_time (0 )
  CALL lhprint ("get exclusions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.query_name IN ("NQF2019_0712: PALLIATIVE_PROC: A5" ,
   "NQF2019_0712: PALLIATIVE_PROC: D5" ,
   "NQF2019_0712: PALLIATIVE_PROC: E5" ,
   "NQF2019_0712: PALLIATIVE_PROC: D6" ,
   "NQF2019_0712: PALLIATIVE_CARE_ENC: F6" ,
   "NQF2019_0712: PALLIATIVE_CARE_ENC: G6" ,
   "NQF2019_0712: CARE_SRV_ENC: A2" ,
   "NQF2019_0712: CARE_SRV_ENC: B2" ,
   "NQF2019_0712: CARE_SRV_ENC: C2" ,
   "NQF2019_0712: CARE_SRV_ENC: D2" ,
   "NQF2019_0712: PERSONALITY_DISORDER: F4" ,
   "NQF2019_0712: PERSONALITY_DISORDER: G4" ,
   "NQF2019_0712: PERSONALITY_DISORDER: H4" ,
   "NQF2019_0712: BIPOLAR_DISORDER: F5" ,
   "NQF2019_0712: BIPOLAR_DISORDER: G5" ,
   "NQF2019_0712: BIPOLAR_DISORDER: H5" ,
   "NQF2019_0712: PSYCHOTIC_DISORDER: F6" ,
   "NQF2019_0712: PSYCHOTIC_DISORDER: G6" ,
   "NQF2019_0712: PSYCHOTIC_DISORDER: H6" ,
   "NQF2019_0712: PERVASIVE_DISORDER: F7" ,
   "NQF2019_0712: PERVASIVE_DISORDER: G7" ,
   "NQF2019_0712: PERVASIVE_DISORDER: H7" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     IF ((qry.query_name IN ("NQF2019_0712: PALLIATIVE_PROC: A5" ,
     "NQF2019_0712: PALLIATIVE_PROC: D5" ,
     "NQF2019_0712: PALLIATIVE_PROC: E5" ,
     "NQF2019_0712: PALLIATIVE_PROC: D6" ) ) )
      IF ((pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm_712 ) ) ) lh_ep_reply->persons[pos ].
       outcome_ind = 2 ,lh_ep_reply->persons[pos ].outcome = "Denominator Exclusion"
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_0712: PALLIATIVE_CARE_ENC: F6" ,
     "NQF2019_0712: PALLIATIVE_CARE_ENC: G6" ,
     "NQF2019_0712: CARE_SRV_ENC: A2" ,
     "NQF2019_0712: CARE_SRV_ENC: B2" ,
     "NQF2019_0712: CARE_SRV_ENC: C2" ,
     "NQF2019_0712: CARE_SRV_ENC: D2" ) ) )
      IF ((pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm_712 ) )
      AND (((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm_712 ) ) ) OR ((pat.ep_end_dt_tm =
      null ) )) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].outcome =
       "Denominator Exclusion"
      ENDIF
     ELSE
      FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
       IF ((pat.ep_dt_tm < lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm )
       AND (((pat.ep_end_dt_tm > lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) ) OR ((pat
       .ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[
        pos ].outcome = "Denominator Exclusion"
       ENDIF
      ENDFOR
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf712 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint ("Get outcomes" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.active_ind = 1 )
   AND (qry.d_query_id = pat.d_query_id )
   AND (qry.query_name = "NQF2019_0712: PHQ_RESULT: E1" )
   AND (qry.active_ind = 1 )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_712 ) AND cnvtdatetime (
    end_extract_dt_tm_712 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((lh_ep_reply->persons[pos ].outcome_ind = 0 )
    AND (((pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm_712 ) AND cnvtdatetime (
     end_extract_dt_tm_712 ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].
     outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcome" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getbegdate_nqf712 (measure )
  CASE (measure )
   OF 1 :
    RETURN (cnvtlookahead ("1,S" ,cnvtlookbehind ("4,M" ,end_extract_dt_tm ) ) )
   OF 2 :
    RETURN (cnvtlookahead ("4,M" ,beg_extract_dt_tm ) )
   OF 3 :
    RETURN (beg_extract_dt_tm )
  ENDCASE
 END ;Subroutine
 SUBROUTINE  getenddate_nqf712 (measure )
  CASE (measure )
   OF 1 :
    RETURN (end_extract_dt_tm )
   OF 2 :
    RETURN (cnvtlookbehind ("1,S" ,cnvtlookahead ("8,M" ,beg_extract_dt_tm ) ) )
   OF 3 :
    RETURN (cnvtlookbehind ("1,S" ,cnvtlookahead ("4,M" ,beg_extract_dt_tm ) ) )
  ENDCASE
 END ;Subroutine
 SUBROUTINE  getagegroup_nqf712 (rec_name ,grp )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  FOR (i = 1 TO size (rec_name->persons ,5 ) )
   IF ((grp = 1 )
   AND (rec_name->persons[i ].age > 17 ) )
    SET rec_name->persons[i ].exclude_ind = 1
   ELSEIF ((grp = 2 )
   AND (rec_name->persons[i ].age < 18 ) )
    SET rec_name->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
 END ;Subroutine
 DECLARE getresults_nqf1365 (null ) = null
 DECLARE getpopulation_nqf1365 (null ) = null
 DECLARE getattribution_nqf1365 (null ) = null
 DECLARE getoutcome_nqf1365 (null ) = null
 SUBROUTINE  getresults_nqf1365 (null )
  CALL geteprfilter ("1365" )
  CALL getpopulation_nqf1365 (0 )
  CALL getattribution_nqf1365 (0 )
  CALL getoutcome_nqf1365 (0 )
  CALL summaryreport ("MU_EC_1365_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf1365 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE per_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_pos = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "NQF2019_1365" ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("6, Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ,2 ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("17, Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ,2 ) )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    enc_cd = 0 ,enc_cnt = 0 ,enc_a = 0 ,personcnt = (personcnt + 1 ) ,lh_ep_reply->person_cnt =
    personcnt ,stat = alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].
    person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->
    persons[personcnt ].exclude_ind = 1
   HEAD pop.encntr_id
    enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_cnt ) ,
    lh_ep_reply->persons[personcnt ].encntr_cnt = enc_cnt ,lh_ep_reply->persons[personcnt ].encntrs[
    enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].fin = pop
    .financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].reg_dt_tm = pop.reg_dt_tm
    ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->
    persons[personcnt ].encntrs[enc_cnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].encntrs[
    enc_cnt ].outcome = "Not Met, Not Done" ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02lh_amb_qual_encntr_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Inital patient population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";Prob and Dx check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_1365: MAJOR_DEP_DIAG: F1" ,
    "NQF2019_1365: MAJOR_DEP_DIAG: G1" ,
    "NQF2019_1365: MAJOR_DEP_DIAG: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    per_pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((per_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[per_pos ].encntrs ,5 ) )
      IF ((qry.query_name = "NQF2019_1365: MAJOR_DEP_DIAG: H1" ) )
       IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[per_pos ].encntrs[i ].disch_dt_tm ) )
       AND (((pat.ep_end_dt_tm = null ) ) OR ((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->
        persons[per_pos ].encntrs[i ].reg_dt_tm ) ) )) ) lh_ep_reply->persons[per_pos ].exclude_ind
        = 0 ,lh_ep_reply->persons[per_pos ].encntrs[i ].exclude_ind = 0
       ENDIF
      ELSE
       IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[per_pos ].encntrs[i ].reg_dt_tm
        ) AND cnvtdatetime (lh_ep_reply->persons[per_pos ].encntrs[i ].disch_dt_tm ) ) )
        IF ((qry.query_name = "NQF2019_1365: MAJOR_DEP_DIAG: F1" ) )
         IF ((pat.diag_priority >= 1 ) ) lh_ep_reply->persons[per_pos ].exclude_ind = 0 ,lh_ep_reply
          ->persons[per_pos ].encntrs[i ].exclude_ind = 0
         ENDIF
        ELSE lh_ep_reply->persons[per_pos ].exclude_ind = 0 ,lh_ep_reply->persons[per_pos ].encntrs[
         i ].exclude_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01lh_amb_event_data_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Prob and DX check" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL removedummyitem (lh_ep_reply )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf1365 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0104" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_PSYCHOTHERAPY" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_DIAG_EVAL" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_FAM_PSYTHER_ENC" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCHOANALYSIS" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("GROUP_PSYCHOTHERAPY_ENC" ,"0104" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"0104" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_1365_2019" ,br_filters->provider_attribution ,"NQF2019_1365" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf1365 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";get Outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].exclude_ind )
   AND (pat.active_ind = 1 )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_1365: SUICIDE_RISK: E2" ,
   "NQF2019_1365: SUICIDE_RISK: L2" ,
   "NQF2019_1365: SUICIDE_RISK: L3" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) AND
      cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) ) lh_ep_reply->persons[
       pos ].encntrs[i ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
       "Met, Done"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01lh_amb_event_data_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf2372 (null ) = null
 DECLARE getpopulation_nqf2372 (null ) = null
 DECLARE getattribution_nqf2372 (null ) = null
 DECLARE getoutcome_nqf2372 (null ) = null
 DECLARE getexclusion_nqf2372 (null ) = null
 SUBROUTINE  getresults_nqf2372 (null )
  SET br_filters->provider_attribution = getproviderattribution ("2372" )
  CALL geteprfilter ("2372" )
  CALL getpopulation_nqf2372 (0 )
  CALL getattribution_nqf2372 (0 )
  CALL getexclusion_nqf2372 (0 )
  CALL getoutcome_nqf2372 (0 )
  CALL summaryreport ("MU_EC_2372_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf2372 (null )
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_2372: A1" ,
    "POPULATION: NQF2019_2372: B1" ,
    "POPULATION: NQF2019_2372: C1" ,
    "POPULATION: NQF2019_2372: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (p.sex_meaning = cnvtupper ("FEMALE" ) )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("51,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("74,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    total_size = 20000 ,
    batch_size = 5000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 0 ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done"
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf2372 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"2372" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"2372" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"2372" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"2372" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"2372" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_2372_2019" ,br_filters->provider_attribution ,"NQF2019_2372" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_nqf2372 (null )
  CALL lhprint (";get exclusions" )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE check_date = dq8
  CALL lhprint (";uni/bilateral check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.ep_dt_tm < cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_2372: BILAT_MASTECT_PROC: A1" ,
   "NQF2019_2372: BILAT_MASTECT_PROC: D1" ,
   "NQF2019_2372: UNILAT_MASTECT_PROC: A2" ,
   "NQF2019_2372: UNILAT_MASTECT_PROC: B2" ,
   "NQF2019_2372: UNILAT_MASTECT_PROC: C2" ,
   "NQF2019_2372: UNILAT_MASTECT_PROC: D2" ,
   "NQF2019_2372: BILAT_MASTECTOMY: F5" ,
   "NQF2019_2372: BILAT_MASTECTOMY: H5" ,
   "NQF2019_2372: STATUS_POST_LEFT_MASTECTOMY: F5" ,
   "NQF2019_2372: STATUS_POST_RIGHT_MASTECTOMY: F5" ,
   "NQF2019_2372: STATUS_POST_LEFT_MASTECTOMY: H5" ,
   "NQF2019_2372: STATUS_POST_RIGHT_MASTECTOMY: H5" ,
   "NQF2019_2372: UNILAT_MASTECT_UNSP_LEFT: F5" ,
   "NQF2019_2372: UNILAT_MASTECT_UNSP_RIGHT: F5" ,
   "NQF2019_2372: UNILAT_MASTECT_UNSP_LEFT: H5" ,
   "NQF2019_2372: UNILAT_MASTECT_UNSP_RIGHT: H5" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    flag = 0 ,check_date = 0 ,lat_mammo_bi_ind = 0 ,lat_mammo_right_ind = 0 ,lat_mammo_left_ind = 0 ,
    unique_unilat = 0
   HEAD pat.ep_dt_tm
    IF ((qry.query_name = "NQF2019_2372: UNILAT_MASTECT_PROC:*" )
    AND (lhgetdatetimedifference (pat.ep_dt_tm ,check_date ,"D" ) >= 1 ) ) check_date = pat.ep_dt_tm
    ,flag = 0
    ENDIF
   DETAIL
    CASE (qry.query_name )
     OF "NQF2019_2372: BILAT_MASTECT_PROC: A1" :
     OF "NQF2019_2372: BILAT_MASTECT_PROC: D1" :
      IF ((((pat.ep_end_dt_tm < cnvtdatetime (end_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) lat_mammo_bi_ind = 1
      ENDIF
     OF "NQF2019_2372: BILAT_MASTECTOMY: F5" :
     OF "NQF2019_2372: BILAT_MASTECTOMY: H5" :
      lat_mammo_bi_ind = 1
     OF "NQF2019_2372: UNILAT_MASTECT_PROC: A2" :
     OF "NQF2019_2372: UNILAT_MASTECT_PROC: B2" :
     OF "NQF2019_2372: UNILAT_MASTECT_PROC: C2" :
     OF "NQF2019_2372: UNILAT_MASTECT_PROC: D2" :
      IF ((((pat.ep_end_dt_tm < cnvtdatetime (end_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      ))
      AND (flag = 0 ) ) unique_unilat = (unique_unilat + 1 ) ,check_date = pat.ep_dt_tm ,flag = 1
      ENDIF
     OF "NQF2019_2372: STATUS_POST_RIGHT_MASTECTOMY: F5" :
     OF "NQF2019_2372: STATUS_POST_RIGHT_MASTECTOMY: H5" :
     OF "NQF2019_2372: UNILAT_MASTECT_UNSP_RIGHT: F5" :
     OF "NQF2019_2372: UNILAT_MASTECT_UNSP_RIGHT: H5" :
      lat_mammo_right_ind = 1
     OF "NQF2019_2372: STATUS_POST_LEFT_MASTECTOMY: F5" :
     OF "NQF2019_2372: STATUS_POST_LEFT_MASTECTOMY: H5" :
     OF "NQF2019_2372: UNILAT_MASTECT_UNSP_LEFT: F5" :
     OF "NQF2019_2372: UNILAT_MASTECT_UNSP_LEFT: H5" :
      lat_mammo_left_ind = 1
    ENDCASE
   FOOT  pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((pos > 0 ) )
     IF ((((lat_mammo_bi_ind = 1 ) ) OR ((((unique_unilat = 2 ) ) OR ((lat_mammo_right_ind = 1 )
     AND (lat_mammo_left_ind = 1 ) )) )) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->
      persons[pos ].outcome = "Denominator Exclusion"
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";problem exclusion check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("NQF2019_2372: HOSPICE_CARE_AMB: A1" ,
    "NQF2019_2372: HOSPICE_CARE_AMB: D1" ,
    "NQF2019_2372: HOSPICE_CARE_AMB: D2" ,
    "NQF2019_2372: HOSPICE_CARE_AMB: E1" ,
    "NQF2019_2372: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    out_flg = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("NQF2019_2372: HOSPICE_CARE_AMB: A1" ,
     "NQF2019_2372: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("NQF2019_2372: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("NQF2019_2372: HOSPICE_CARE_AMB: D2" ,
     "NQF2019_2372: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (pos > 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].outcome
     = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|pos:" ,pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf2372 (null )
  CALL lhprint (";get outcome" )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";mammogram check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtlookbehind ("1,D" ,cnvtdatetime (end_extract_dt_tm ) ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("NQF2019_2372: MAMMOGRAM_RESULT: D4" ,
   "NQF2019_2372: MAMMOGRAM_RESULT: E4" ,
   "NQF2019_2372: MAMMOGRAM_RESULT: L4" ,
   "NQF2019_2372: MAMMOGRAM_RESULT: L5" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     IF ((qry.query_name IN ("NQF2019_2372: MAMMOGRAM_RESULT: D4" ,
     "NQF2019_2372: MAMMOGRAM_RESULT: E4" ) ) )
      IF ((lhgetdatetimedifference (cnvtlookbehind ("1,D" ,cnvtdatetime (end_extract_dt_tm ) ) ,pat
       .ep_end_dt_tm ,"MO" ) <= 27 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->
       persons[pos ].outcome = "Met, Done"
      ENDIF
     ELSE
      IF ((lhgetdatetimedifference (cnvtlookbehind ("1,D" ,cnvtdatetime (end_extract_dt_tm ) ) ,pat
       .ep_dt_tm ,"MO" ) <= 27 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[
       pos ].outcome = "Met, Done"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_nqf2872 (null ) = null
 DECLARE getpopulation_nqf2872 (null ) = null
 DECLARE getattribution_nqf2872 (null ) = null
 DECLARE getoutcome_nqf2872 (null ) = null
 SUBROUTINE  getresults_nqf2872 (null )
  CALL geteprfilter ("2872" )
  CALL getpopulation_nqf2872 (0 )
  CALL getattribution_nqf2872 (0 )
  CALL getoutcome_nqf2872 (0 )
  CALL summaryreport ("MU_EC_2872_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_nqf2872 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE num = i4 WITH noconstant (0 ) ,protect
  DECLARE newdatepos = i2 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encs_during_meas = i4 WITH noconstant (0 ) ,protect
  DECLARE had_at_least_one_enc = i2 WITH noconstant (0 ) ,protect
  DECLARE enc_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_added = i2 WITH noconstant (0 ) ,protect
  DECLARE enc_added_a2_d2 = i2 WITH noconstant (0 ) ,protect
  DECLARE enc_cnt_a2_d2 = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: NQF2019_2872: A1" ,
    "POPULATION: NQF2019_2872: B1" ,
    "POPULATION: NQF2019_2872: C1" ,
    "POPULATION: NQF2019_2872: D1" ,
    "POPULATION: NQF2019_2872: A2" ,
    "POPULATION: NQF2019_2872: D2" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    encs_during_meas = 0 ,had_at_least_one_enc = 0 ,enc_cnt = 0 ,enc_cnt_a2_d2 = 0 ,personcnt = (
    personcnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat = alterlist (lh_ep_reply->persons ,
     personcnt ) ,stat = initrec (lh_bill_encntr_date ) ,stat = alterlist (encntr_a2_d2->persons ,
     personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[
    personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply
    ->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome =
    "Not Met, Not Done"
   HEAD pop.encntr_id
    enc_added = 0 ,enc_added_a2_d2 = 0 ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   DETAIL
    IF ((qry.query_name IN ("POPULATION: NQF2019_2872: A2" ,
    "POPULATION: NQF2019_2872: D2" ) )
    AND (enc_added_a2_d2 = 0 ) ) enc_cnt_a2_d2 = (enc_cnt_a2_d2 + 1 ) ,stat = alterlist (encntr_a2_d2
      ->persons[personcnt ].encntrs ,enc_cnt_a2_d2 ) ,encntr_a2_d2->persons[personcnt ].person_id =
     pop.person_id ,encntr_a2_d2->persons[personcnt ].encntrs[enc_cnt_a2_d2 ].encntr_id = pop
     .encntr_id ,enc_added_a2_d2 = 1
    ENDIF
    ,
    IF ((qry.query_name IN ("POPULATION: NQF2019_2872: A1" ,
    "POPULATION: NQF2019_2872: B1" ,
    "POPULATION: NQF2019_2872: C1" ,
    "POPULATION: NQF2019_2872: D1" ) )
    AND (enc_added = 0 ) )
     IF ((size (encntr_a2_d2->persons[personcnt ].encntrs ,5 ) != 0 ) )
      FOR (i = 1 TO size (encntr_a2_d2->persons[personcnt ].encntrs ,5 ) )
       IF ((encntr_a2_d2->persons[personcnt ].encntrs[i ].encntr_id = pop.encntr_id ) ) enc_added =
        1
       ELSE enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,
         enc_cnt ) ,lh_ep_reply->persons[personcnt ].encntr_cnt = enc_cnt ,lh_ep_reply->persons[
        personcnt ].encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].
        encntrs[enc_cnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[
        enc_cnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].
        disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].exclude_ind
         = 1 ,enc_added = 1 ,had_at_least_one_enc = 1
       ENDIF
      ENDFOR
     ELSE enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,
       enc_cnt ) ,lh_ep_reply->persons[personcnt ].encntr_cnt = enc_cnt ,lh_ep_reply->persons[
      personcnt ].encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].
      encntrs[enc_cnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[
      enc_cnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].
      disch_dt_tm = pop.disch_dt_tm ,lh_ep_reply->persons[personcnt ].encntrs[enc_cnt ].exclude_ind
      = 1 ,enc_added = 1 ,had_at_least_one_enc = 1
     ENDIF
    ENDIF
    ,pos = locateval (num ,1 ,lh_bill_encntr_date->daycnt ,cnvtdate (pop.reg_dt_tm ) ,cnvtdate (
      lh_bill_encntr_date->days[num ].encntrday ) ) ,
    IF ((pos = 0 ) ) newdatepos = (lh_bill_encntr_date->daycnt + 1 ) ,lh_bill_encntr_date->daycnt =
     newdatepos ,stat = alterlist (lh_bill_encntr_date->days ,newdatepos ) ,lh_bill_encntr_date->
     days[newdatepos ].encntrday = cnvtdate (pop.reg_dt_tm ) ,encs_during_meas = (encs_during_meas +
     1 )
    ENDIF
   FOOT  pop.person_id
    IF ((((encs_during_meas < 2 ) ) OR ((had_at_least_one_enc = 0 ) )) ) personcnt = (personcnt - 1
     ) ,lh_ep_reply->person_cnt = personcnt ,stat = alterlist (lh_ep_reply->persons ,personcnt )
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Dementia and Mental Degenerations Dx and Problem Check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,1 ,lh_ep_reply->persons[iter1 ].exclude_ind )
    AND (pat.active_ind = 1 )
    AND (pat.lh_amb_event_data_2019_id > 0 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_2872: DEMENTIA_DEGEN_DX: F1" ,
    "NQF2019_2872: DEMENTIA_DEGEN_DX: G1" ,
    "NQF2019_2872: DEMENTIA_DEGEN_DX: H1" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD pat.person_id
    flag = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
      ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 ,
       flag = 1
      ENDIF
      ,
      IF ((flag = 1 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,flag = 0
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter Results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_nqf2872 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pat_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE cog_ind = i2 WITH protect ,noconstant (0 )
  DECLARE datediff_ind = i2 WITH protect ,noconstant (0 )
  CALL lhprint (";get cognitive result outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.active_ind = 1 )
   AND (qry.population_group = "NQF2019_2872" )
   AND (qry.query_name IN ("NQF2019_2872: COGNITIVE_RESULT: E2" ,
   "NQF2019_2872: COGNITIVE_PROC: A3" ,
   "NQF2019_2872: COGNITIVE_PROC: D3" ,
   "NQF2019_2872: COGNITIVE_PROC: E3" ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    cog_ind = 0 ,pat_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((debug_ind = 1 ) )
     CALL echo (build ("DEBUG: ep:" ,format (pat.ep_dt_tm ,";;q" ) ,"|enc_id:" ,pat.encntr_id ) )
    ENDIF
    ,
    IF ((pat_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pat_pos ].encntrs ,5 ) )
      datediff_ind = lhgetdatetimedifference (lh_ep_reply->persons[pat_pos ].encntrs[i ].disch_dt_tm
       ,pat.ep_dt_tm ,"MO" ) ,
      IF ((datediff_ind <= 12 )
      AND (datediff_ind >= 0 )
      AND (lh_ep_reply->persons[pat_pos ].outcome_ind = 0 )
      AND (cog_ind = 0 ) )
       IF ((qry.query_name IN ("NQF2019_2872: COGNITIVE_RESULT: E2" ) )
       AND (pat.ce_result_val != " " ) ) cog_ind = 1
       ELSEIF ((qry.query_name IN ("NQF2019_2872: COGNITIVE_PROC: A3" ,
       "NQF2019_2872: COGNITIVE_PROC: E3" ,
       "NQF2019_2872: COGNITIVE_PROC: D3" ) ) ) cog_ind = 1
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((cog_ind = 1 ) ) lh_ep_reply->persons[pat_pos ].outcome_ind = 1 ,lh_ep_reply->persons[
     pat_pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";get exceptions" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("NQF2019_2872: NEGATION: E8" ,
    "NQF2019_2872: NEGATION: E9" ) ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pat_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pat_pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pat_pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN lh_ep_reply->persons[pat_pos ].encntrs[i ].reg_dt_tm AND lh_ep_reply
      ->persons[pat_pos ].encntrs[i ].disch_dt_tm )
      AND (lh_ep_reply->persons[pat_pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[pat_pos ].
       outcome_ind = 3 ,lh_ep_reply->persons[pat_pos ].outcome = "Denominator Exception"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Outcome Exceptions" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_nqf2872 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_PSYCHOTHERAPY" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("OCCUPATIONAL_THERAPY_EVAL" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("BEHAV_NEUROPSYCH_ASSES_ENC" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PSYCH_VISIT_DIAG_EVAL" ,"2872" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PT_PROV_INTERACT_ENC" ,"2872" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"2872" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"2872" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"2872" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"2872" ,"'SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("OUTPATIENT_CONSULTATION" ,"2872" ,"'SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_2872_2019" ,br_filters->provider_attribution ,"NQF2019_2872" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After Attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_cms22 (null ) = null
 DECLARE getpopulation_cms22 (null ) = null
 DECLARE getattribution_cms22 (null ) = null
 DECLARE getoutcome_cms22 (null ) = null
 DECLARE getexclusion_cms22 (null ) = null
 SUBROUTINE  getresults_cms22 (null )
  CALL geteprfilter ("CMS22" )
  CALL getpopulation_cms22 (0 )
  CALL getattribution_cms22 (0 )
  CALL getexclusion_cms22 (0 )
  CALL getoutcome_cms22 (0 )
  CALL summaryreport ("MU_EC_CMS22_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_cms22 (null )
  DECLARE person_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_cnt = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: CMS2019_0022: A1" ,
    "POPULATION: CMS2019_0022: B1" ,
    "POPULATION: CMS2019_0022: C1" ,
    "POPULATION: CMS2019_0022: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.reg_dt_tm DESC ,
    pop.encntr_id
   HEAD REPORT
    person_cnt = 0
   HEAD pop.person_id
    person_cnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = person_cnt ,stat =
    alterlist (lh_ep_reply->persons ,person_cnt ) ,lh_ep_reply->persons[person_cnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[person_cnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    person_cnt ].exclude_ind = 0 ,lh_ep_reply->persons[person_cnt ].outcome_ind = 0 ,lh_ep_reply->
    persons[person_cnt ].outcome = "Not Met, Not Done" ,lh_ep_reply->persons[person_cnt ].
    recent_encntr_id = pop.encntr_id ,lh_ep_reply->persons[person_cnt ].recent_encntr_date = pop
    .reg_dt_tm ,lh_ep_reply->persons[person_cnt ].special_cond_dt_tm = pop.qual_reg_dt_tm ,
    encntr_cnt = 0
   HEAD pop.encntr_id
    encntr_cnt = (lh_ep_reply->persons[person_cnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[
    person_cnt ].encntr_cnt = encntr_cnt ,stat = alterlist (lh_ep_reply->persons[person_cnt ].encntrs
      ,encntr_cnt ) ,lh_ep_reply->persons[person_cnt ].encntrs[encntr_cnt ].encntr_id = pop
    .encntr_id ,lh_ep_reply->persons[person_cnt ].encntrs[encntr_cnt ].fin = pop.financial_nbr_txt ,
    lh_ep_reply->persons[person_cnt ].encntrs[encntr_cnt ].reg_dt_tm = pop.reg_dt_tm ,lh_ep_reply->
    persons[person_cnt ].encntrs[encntr_cnt ].disch_dt_tm = pop.disch_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[person_cnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[person_cnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[person_cnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[person_cnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[person_cnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[person_cnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[person_cnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[person_cnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_cms22 (null )
  CALL getnonmappednomenclature ("BP_SCRN_ENC_CDS" ,"0022" ,"'CPT4','HCPCS','CDT'" ,"1=1" )
  CALL getepdata ("MU_EC_CMS22_2019" ,br_filters->provider_attribution ,"CMS2019_0022" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_cms22 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Check for Active Dx of HTN" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0022: HTN_GROUPED: F1" ,
    "CMS2019_0022: HTN_GROUPED: G1" ,
    "CMS2019_0022: HTN_GROUPED: H1" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
     IF ((pat.ep_dt_tm < cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) ) )
      lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].outcome =
      "Denominator Exclusion"
     ENDIF
    ENDFOR
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getoutcome_cms22 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  DECLARE low_systolic_limit = i2 WITH constant (120 ) ,protect
  DECLARE low_diastolic_limit = i2 WITH constant (80 ) ,protect
  DECLARE high_systolic_limit = i2 WITH constant (140 ) ,protect
  DECLARE high_diastolic_limit = i2 WITH constant (90 ) ,protect
  DECLARE result_value = f8 WITH noconstant (0 ) ,protect
  DECLARE sys_met = i2 WITH noconstant (0 ) ,protect
  DECLARE dia_met = i2 WITH noconstant (0 ) ,protect
  DECLARE sys_done = i2 WITH noconstant (0 ) ,protect
  DECLARE dia_done = i2 WITH noconstant (0 ) ,protect
  DECLARE sys_not_high = i2 WITH noconstant (0 ) ,protect
  DECLARE dia_not_high = i2 WITH noconstant (0 ) ,protect
  DECLARE referral_code = i2 WITH noconstant (0 ) ,protect
  DECLARE rescreen_code = i2 WITH noconstant (0 ) ,protect
  DECLARE intervention_code = i2 WITH noconstant (0 ) ,protect
  DECLARE medication_code = i2 WITH noconstant (0 ) ,protect
  DECLARE lab_code = i2 WITH noconstant (0 ) ,protect
  DECLARE min_enc_date = dq8 WITH noconstant ,protect
  DECLARE max_enc_date = dq8 WITH noconstant ,protect
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter3 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter3 ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0022: SYSTOLIC: E2" ,
    "CMS2019_0022: DIASTOLIC: E2" ) )
    AND (isnumeric (pat.ce_result_val ) > 0 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,sys_met = 0 ,dia_met = 0 ,sys_done = 0 ,dia_done = 0 ,sys_not_high
    = 0 ,dia_not_high = 0 ,max_enc_date = cnvtdatetime (cnvtdate (lh_ep_reply->persons[pos ].
      recent_encntr_date ) ,235959 ) ,min_enc_date = cnvtlookbehind ("1,Y" ,cnvtdatetime (cnvtdate (
       lh_ep_reply->persons[pos ].recent_encntr_date ) ,0 ) )
   DETAIL
    flag = 0 ,
    IF ((pat.updt_source = "IMPORT*" ) )
     IF ((pat.qual_reg_dt_tm = lh_ep_reply->persons[pos ].special_cond_dt_tm ) ) flag = 1
     ENDIF
    ELSE
     IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (min_enc_date ) AND cnvtdatetime (max_enc_date ) ) )
      flag = 1
     ENDIF
    ENDIF
    ,
    IF ((flag = 1 ) ) result_value = cnvtreal (pat.ce_result_val ) ,
     IF ((qry.query_name = "CMS2019_0022: SYSTOLIC: E2" ) ) sys_done = 1 ,
      IF ((result_value < high_systolic_limit ) ) sys_not_high = 1 ,
       IF ((result_value < low_systolic_limit ) ) sys_met = 1
       ENDIF
      ENDIF
     ELSEIF ((qry.query_name = "CMS2019_0022: DIASTOLIC: E2" ) ) dia_done = 1 ,
      IF ((result_value < high_diastolic_limit ) ) dia_not_high = 1 ,
       IF ((result_value < low_diastolic_limit ) ) dia_met = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((lh_ep_reply->persons[pos ].outcome_ind != 2 ) )
     IF ((sys_done = 1 )
     AND (dia_done = 1 ) )
      IF ((sys_met = 1 )
      AND (dia_met = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].
       outcome = "Met, Controlled"
      ELSEIF ((sys_not_high = 1 )
      AND (dia_not_high = 1 ) ) lh_ep_reply->persons[pos ].special_group = 1
      ELSE lh_ep_reply->persons[pos ].special_group = 2
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Bp check on prior recent encounter" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm BETWEEN cnvtlookbehind ("1,Y" ,beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0022: SYSTOLIC: E2" ,
    "CMS2019_0022: DIASTOLIC: E2" ) )
    AND (isnumeric (pat.ce_result_val ) > 0 ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm ,
    pat.encntr_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,sys_met = 0 ,dia_met = 0 ,max_enc_date = cnvtdatetime (cnvtdate (
      lh_ep_reply->persons[pos ].recent_encntr_date ) ,235959 ) ,min_enc_date = cnvtlookbehind (
     "1,Y" ,cnvtdatetime (cnvtdate (lh_ep_reply->persons[pos ].recent_encntr_date ) ,0 ) )
   HEAD pat.ep_dt_tm
    sys_done = 0 ,dia_done = 0
   DETAIL
    IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (min_enc_date ) AND cnvtdatetime (max_enc_date ) ) )
     result_value = cnvtreal (pat.ce_result_val ) ,
     IF ((lh_ep_reply->persons[pos ].special_group = 2 ) )
      CASE (qry.query_name )
       OF "CMS2019_0022: SYSTOLIC: E2" :
        sys_done = 1 ,
        IF ((result_value < high_systolic_limit ) ) sys_met = 1
        ENDIF
       OF "CMS2019_0022: DIASTOLIC: E2" :
        dia_done = 1 ,
        IF ((result_value < high_diastolic_limit ) ) dia_met = 1
        ENDIF
      ENDCASE
     ENDIF
    ENDIF
   FOOT  pat.ep_dt_tm
    IF ((lh_ep_reply->persons[pos ].special_group >= 2 ) )
     IF ((sys_done = 1 )
     AND (dia_done = 1 ) )
      IF ((sys_met = 1 )
      AND (dia_met = 1 ) ) lh_ep_reply->persons[pos ].special_group = 2
      ELSE lh_ep_reply->persons[pos ].special_group = 3
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";REFERRAL" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("CMS2019_0022: REFERRAL_PROC: D3" ,
    "CMS2019_0022: REFERRAL_PROC: E3" ,
    "CMS2019_0022: REFERRAL_PROC: D4" ,
    "CMS2019_0022: RESCREEN_1_YEAR_PROC: D4" ,
    "CMS2019_0022: RESCREEN_1_YEAR_PROC: E4" ,
    "CMS2019_0022: RESCREEN_4_WEEKS_PROC: D7" ,
    "CMS2019_0022: RESCREEN_4_WEEKS_PROC: E7" ,
    "CMS2019_0022: RECOMMENDATION_PROC: D6" ,
    "CMS2019_0022: RECOMMENDATION_PROC: E6" ,
    "CMS2019_0022: MEDICATION: M8" ,
    "CMS2019_0022: RESCREEN_4_WEEKS_PROC_1: D9" ,
    "CMS2019_0022: RESCREEN_4_WEEKS_PROC_1: E9" ,
    "CMS2019_0022: RESCREEN_4_WEEKS_PROC_2: D9" ,
    "CMS2019_0022: RESCREEN_4_WEEKS_PROC_2: E9" ,
    "CMS2019_0022: RECOMMENDATION_PAT_EDU: P14" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,referral_code = 0 ,rescreen_code = 0 ,intervention_code = 0 ,
    medication_code = 0 ,lab_code = 0
   DETAIL
    IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (cnvtdate (lh_ep_reply->persons[pos ].recent_encntr_date
      ) ,0 ) AND cnvtdatetime (cnvtdate (lh_ep_reply->persons[pos ].recent_encntr_date ) ,235959 ) )
    )
     CASE (qry.query_name )
      OF "CMS2019_0022: REFERRAL_PROC: D3" :
      OF "CMS2019_0022: REFERRAL_PROC: D4" :
      OF "CMS2019_0022: REFERRAL_PROC: E3" :
       referral_code = 1
      OF "CMS2019_0022: RESCREEN_1_YEAR_PROC: D4" :
      OF "CMS2019_0022: RESCREEN_1_YEAR_PROC: E4" :
       IF ((lh_ep_reply->persons[pos ].special_group = 1 ) ) rescreen_code = 1
       ENDIF
      OF "CMS2019_0022: RESCREEN_4_WEEKS_PROC: D7" :
      OF "CMS2019_0022: RESCREEN_4_WEEKS_PROC: E7" :
       IF ((lh_ep_reply->persons[pos ].special_group = 2 ) ) rescreen_code = 1
       ENDIF
      OF "CMS2019_0022: RECOMMENDATION_PROC: D6" :
      OF "CMS2019_0022: RECOMMENDATION_PROC: E6" :
      OF "CMS2019_0022: RECOMMENDATION_PAT_EDU: P14" :
       intervention_code = 1
      OF "CMS2019_0022: MEDICATION: M8" :
       medication_code = 1
      OF "CMS2019_0022: RESCREEN_4_WEEKS_PROC_1: D9" :
      OF "CMS2019_0022: RESCREEN_4_WEEKS_PROC_1: E9" :
      OF "CMS2019_0022: RESCREEN_4_WEEKS_PROC_2: D9" :
      OF "CMS2019_0022: RESCREEN_4_WEEKS_PROC_2: E9" :
       lab_code = 1
     ENDCASE
    ENDIF
   FOOT  pat.person_id
    IF ((lh_ep_reply->persons[pos ].special_group != 0 ) )
     IF ((lh_ep_reply->persons[pos ].special_group = 3 ) )
      IF ((((referral_code = 1 ) ) OR ((intervention_code = 1 )
      AND (((lab_code = 1 ) ) OR ((medication_code = 1 ) )) )) ) lh_ep_reply->persons[pos ].
       outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome = "Met, Done"
      ENDIF
     ELSE
      IF ((((referral_code = 1 ) ) OR ((rescreen_code = 1 )
      AND (intervention_code = 1 ) )) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->
       persons[pos ].outcome = "Met, Done"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint ("Negation results" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0022: NEGATION: E10" ,
    "CMS2019_0022: NEGATION: E11" ,
    "CMS2019_0022: NEGATION: E12" ,
    "CMS2019_0022: NEGATION: E13" ,
    "CMS2019_0022: NEGATION: E14" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (cnvtdate (lh_ep_reply->persons[pos ].encntrs[i ].
        reg_dt_tm ) ,0 ) AND cnvtdatetime (cnvtdate (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm
         ) ,235959 ) ) ) lh_ep_reply->persons[pos ].outcome_ind = 3 ,lh_ep_reply->persons[pos ].
       outcome = "Denominator Exception"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_cms50 (null ) = null
 DECLARE getpopulation_cms50 (null ) = null
 DECLARE getattribution_cms50 (null ) = null
 DECLARE getoutcome_cms50 (null ) = null
 SUBROUTINE  getresults_cms50 (null )
  SET br_filters->provider_attribution = getproviderattribution ("CMS50" )
  CALL geteprfilter ("CMS50" )
  CALL getpopulation_cms50 (0 )
  CALL getattribution_cms50 (0 )
  CALL getoutcome_cms50 (0 )
  CALL summaryreport ("MU_EC_CMS50_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_cms50 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE encntrcnt = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: CMS2019_0050: A1" ,
    "POPULATION: CMS2019_0050: B1" ,
    "POPULATION: CMS2019_0050: C1" ,
    "POPULATION: CMS2019_0050: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    total_size = 10000 ,
    batch_size = 5000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,
    encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";get referrals" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (ambqry
    WHERE (pat.d_query_id = ambqry.d_query_id )
    AND (ambqry.query_name IN ("CMS2019_0050: REFERRAL_PROC: A1" ,
    "CMS2019_0050: REFERRAL_PROC: D1" ) )
    AND (ambqry.active_ind = 1 ) )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((pos > 0 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0 ,lh_ep_reply->persons[pos ].
     first_encntr_id = 1 ,lh_ep_reply->persons[pos ].first_encntr_date = pat.ep_dt_tm
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_cms50 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0050" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"0050" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0050" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0050" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"0050" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("OPHTHALMOLOGICAL_SERVICES" ,"0050" ,"'CPT4'" ,"1=1" )
  CALL getepdata ("MU_EC_CMS50_2019" ,br_filters->provider_attribution ,"CMS2019_0050" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms50 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query ambqry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (ambqry
    WHERE (pat.d_query_id = ambqry.d_query_id )
    AND (ambqry.query_name IN ("CMS2019_0050: CONSULTANT_REPORT: E2" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) )
     IF ((cnvtupper (pat.updt_source ) = "IMPORT*" ) )
      IF ((pat.ep_dt_tm > lh_ep_reply->persons[pos ].first_encntr_date ) ) lh_ep_reply->persons[pos ]
       .outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome = "Met, Done"
      ENDIF
     ELSE
      IF ((lh_ep_reply->persons[pos ].first_encntr_id = 1 )
      AND (pat.ep_dt_tm > lh_ep_reply->persons[pos ].first_encntr_date ) ) lh_ep_reply->persons[pos ]
       .outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome = "Met, Done"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_cms75 (null ) = null
 DECLARE getresults_cms74 (null ) = null
 DECLARE getpopulation_cms75 ((param_meas = i2 ) ) = null
 DECLARE getattribution_cms_74_75 ((report_mean = vc ) ) = null
 DECLARE getexclusion_cms_74_75 (null ) = null
 DECLARE getoutcome_cms75 (null ) = null
 DECLARE getoutcome_cms74 (null ) = null
 SUBROUTINE  getresults_cms75 (null )
  SET br_filters->provider_attribution = getproviderattribution ("CMS75" )
  CALL geteprfilter ("CMS75" )
  CALL getpopulation_cms75 (75 )
  CALL getattribution_cms_74_75 ("MU_EC_CMS75_2019" )
  CALL getexclusion_cms_74_75 (0 )
  CALL getoutcome_cms75 (0 )
  CALL summaryreport ("MU_EC_CMS75_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getresults_cms74 (null )
  DECLARE i = i4 WITH protect ,noconstant (0 )
  SET stat = initrec (lh_ep_reply_bk )
  SET br_filters->provider_attribution = getproviderattribution ("CMS74" )
  CALL geteprfilter ("CMS74" )
  CALL getpopulation_cms75 (74 )
  CALL lhprint ("Preparing population 1 for attribution and outcomes" )
  CALL beg_time (0 )
  SET stat = moverec (lh_ep_reply ,lh_ep_reply_bk )
  FOR (i = 1 TO lh_ep_reply->person_cnt )
   IF ((lh_ep_reply->persons[i ].special_group = 1 ) )
    SET lh_ep_reply->persons[i ].exclude_ind = 0
   ELSE
    SET lh_ep_reply->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  CALL end_time (0 )
  CALL getattribution_cms_74_75 ("MU_EC_CMS74_2019.1" )
  CALL getexclusion_cms_74_75 (0 )
  CALL getoutcome_cms74 (0 )
  CALL summaryreport ("MU_EC_CMS74_2019.1" )
  CALL lhprint ("Preparing population 2 for attribution and outcomes" )
  CALL beg_time (0 )
  SET stat = initrec (lh_ep_reply )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  FOR (i = 1 TO lh_ep_reply->person_cnt )
   IF ((lh_ep_reply->persons[i ].special_group = 2 ) )
    SET lh_ep_reply->persons[i ].exclude_ind = 0
   ELSE
    SET lh_ep_reply->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  CALL end_time (0 )
  CALL getattribution_cms_74_75 ("MU_EC_CMS74_2019.2" )
  CALL getexclusion_cms_74_75 (0 )
  CALL getoutcome_cms74 (0 )
  CALL summaryreport ("MU_EC_CMS74_2019.2" )
  CALL lhprint ("Preparing population 3 for attribution and outcomes" )
  CALL beg_time (0 )
  SET stat = initrec (lh_ep_reply )
  SET stat = moverec (lh_ep_reply_bk ,lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
  FOR (i = 1 TO lh_ep_reply->person_cnt )
   IF ((lh_ep_reply->persons[i ].special_group = 3 ) )
    SET lh_ep_reply->persons[i ].exclude_ind = 0
   ELSE
    SET lh_ep_reply->persons[i ].exclude_ind = 1
   ENDIF
  ENDFOR
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  CALL end_time (0 )
  CALL getattribution_cms_74_75 ("MU_EC_CMS74_2019.3" )
  CALL getexclusion_cms_74_75 (0 )
  CALL getoutcome_cms74 (0 )
  CALL summaryreport ("MU_EC_CMS74_2019.3" )
  CALL sum_submeasures ("MU_EC_CMS74_2019.1" ,"MU_EC_CMS74_2019.2" ,"MU_EC_CMS74_2019.0" )
  CALL sum_submeasures ("MU_EC_CMS74_2019.0" ,"MU_EC_CMS74_2019.3" ,"MU_EC_CMS74_2019.4" )
  CALL delete_submeasure ("MU_EC_CMS74_2019.0" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (lh_ep_reply_bk )
 END ;Subroutine
 SUBROUTINE  getpopulation_cms75 (param_meas )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: CMS2019_0075: A1" ,
    "POPULATION: CMS2019_0075: B1" ,
    "POPULATION: CMS2019_0075: C1" ,
    "POPULATION: CMS2019_0075: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("20,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtdatetime (
     end_extract_dt_tm ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    encntrcnt = 0 ,personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    stat = alterlist (lh_ep_reply->persons ,personcnt ) ,lh_ep_reply->persons[personcnt ].person_id
    = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,
    IF ((param_meas = 74 ) )
     IF ((floor ((datetimediff (cnvtdatetime (beg_extract_dt_tm ) ,p.birth_dt_tm ) / 365.25 ) ) <= 4
     ) ) lh_ep_reply->persons[personcnt ].special_group = 1
     ELSEIF ((floor ((datetimediff (cnvtdatetime (beg_extract_dt_tm ) ,p.birth_dt_tm ) / 365.25 ) )
     BETWEEN 5 AND 11 ) ) lh_ep_reply->persons[personcnt ].special_group = 2
     ELSE lh_ep_reply->persons[personcnt ].special_group = 3
     ENDIF
    ENDIF
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_cms_74_75 (report_mean )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"75" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("CLINICAL_ORAL_EVAL_ENC" ,"75" ,"'CDT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_0_17" ,"75" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_0_17" ,"75" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"75" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"75" ,"'CPT4'" ,"1=1" )
  CALL getepdata (report_mean ,br_filters->provider_attribution ,"CMS2019_0075" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_cms_74_75 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Exclusion check: Hospice Care" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0075: HOSPICE_CARE_AMB: A1" ,
    "CMS2019_0075: HOSPICE_CARE_AMB: D1" ,
    "CMS2019_0075: HOSPICE_CARE_AMB: D2" ,
    "CMS2019_0075: HOSPICE_CARE_AMB: E1" ,
    "CMS2019_0075: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("CMS2019_0075: HOSPICE_CARE_AMB: A1" ,
     "CMS2019_0075: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("CMS2019_0075: HOSPICE_CARE_AMB: D2" ,
     "CMS2019_0075: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("CMS2019_0075: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms75 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (
   ";Outcome Query - Active problem or diagnosis of dental caries during measurement period" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("CMS2019_0075: DENTAL_CARIES: F1" ,
   "CMS2019_0075: DENTAL_CARIES: G1" ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
    )) ) lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->persons[person_pos ].outcome
      = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (
    "After outcomes - Active problem or diagnosis of dental caries during measurement period" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms74 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";Outcome Query - Fluoride Varnish Application Procedure during measurement period"
   )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm )
   )
   AND (pat.active_ind = 1 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.active_ind = 1 )
   AND (qry.query_name IN ("CMS2019_0075: FLUORIDE_VARNISH_PROC: A2" ,
   "CMS2019_0075: FLUORIDE_VARNISH_PROC: B2" ,
   "CMS2019_0075: FLUORIDE_VARNISH_PROC: C2" ,
   "CMS2019_0075: FLUORIDE_VARNISH_PROC: D2" ,
   "CMS2019_0075: FLUORIDE_VARNISH_PROC: E2" ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    person_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply
     ->persons[iter2 ].person_id ) ,lh_ep_reply->persons[person_pos ].outcome_ind = 1 ,lh_ep_reply->
    persons[person_pos ].outcome = "Met, Done"
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes - Fluoride Varnish Application Procedure during measurement period" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_cms82 (null ) = null
 DECLARE getpopulation_cms82 (null ) = null
 DECLARE getattribution_cms82 (null ) = null
 DECLARE getoutcome_cms82 (null ) = null
 SUBROUTINE  getresults_cms82 (null )
  CALL geteprfilter ("CMS82" )
  CALL getpopulation_cms82 (0 )
  DECLARE beg_dt_tm = dq8 WITH protect ,constant (cnvtdatetime (beg_extract_dt_tm ) )
  SET beg_extract_dt_tm = cnvtlookbehind ("6,M" ,cnvtdatetime (beg_dt_tm ) )
  CALL getattribution_cms82 (0 )
  SET beg_extract_dt_tm = cnvtdatetime (beg_dt_tm )
  CALL getoutcome_cms82 (0 )
  CALL summaryreport ("MU_EC_CMS82_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_cms82 (null )
  DECLARE person_cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_cnt = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p ),
    (dummyt d )
   PLAN (pop
    WHERE (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter )
    AND (pop.reg_dt_tm BETWEEN cnvtlookbehind ("6,M" ,cnvtdatetime (beg_extract_dt_tm ) ) AND
    cnvtdatetime (end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtlookbehind ("6,M" ,cnvtdatetime (beg_extract_dt_tm ) ) AND
    cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "CMS2019_0082" ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND (p.birth_dt_tm > cnvtlookbehind ("6,M" ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.birth_dt_tm < cnvtlookahead ("6,M" ,cnvtdatetime (beg_extract_dt_tm ) ) )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 ) )
    JOIN (d
    WHERE (pop.reg_dt_tm >= p.birth_dt_tm )
    AND (pop.reg_dt_tm <= cnvtlookahead ("6, M" ,p.birth_dt_tm ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    person_cnt = 0
   HEAD pop.person_id
    enc_cnt = 0 ,person_cnt = (person_cnt + 1 ) ,lh_ep_reply->person_cnt = person_cnt ,stat =
    alterlist (lh_ep_reply->persons ,person_cnt ) ,lh_ep_reply->persons[person_cnt ].person_id = pop
    .person_id ,lh_ep_reply->persons[person_cnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[
    person_cnt ].birth_date = p.birth_dt_tm ,lh_ep_reply->persons[person_cnt ].outcome_ind = 0 ,
    lh_ep_reply->persons[person_cnt ].outcome = "Not Met, Not Done"
   HEAD pop.encntr_id
    enc_cnt = (enc_cnt + 1 ) ,stat = alterlist (lh_ep_reply->persons[person_cnt ].encntrs ,enc_cnt )
    ,lh_ep_reply->persons[person_cnt ].encntr_cnt = enc_cnt ,lh_ep_reply->persons[person_cnt ].
    encntrs[enc_cnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[person_cnt ].encntrs[enc_cnt ].
    fin = pop.financial_nbr_txt ,lh_ep_reply->persons[person_cnt ].encntrs[enc_cnt ].reg_dt_tm = pop
    .reg_dt_tm ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[person_cnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[person_cnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[person_cnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[person_cnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[person_cnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[person_cnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[person_cnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[person_cnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,person_cnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_cms82 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0082" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OV_0_17_1120" ,"0082" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OV_0_17_1110" ,"0082" ,"'CPT4'" ,"1=1" )
  CALL getepdata ("MU_EC_CMS82_2019" ,br_filters->provider_attribution ,"CMS2019_0082" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms82 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get Outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.ep_dt_tm BETWEEN cnvtlookbehind ("6,M" ,cnvtdatetime (beg_extract_dt_tm ) ) AND
    cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.population_group = "CMS2019_0082" )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (pat.ep_dt_tm > cnvtdatetime (lh_ep_reply->persons[pos ].birth_date ) )
    AND (pat.ep_dt_tm <= cnvtlookahead ("6, M" ,cnvtdatetime (lh_ep_reply->persons[pos ].birth_date
      ) ) ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].outcome =
     "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_cms90 (null ) = null
 DECLARE getpopulation_cms90 (null ) = null
 DECLARE getattribution_cms90 (null ) = null
 DECLARE getexclusion_cms90 (nulll ) = null
 DECLARE getoutcome_cms90 (null ) = null
 SUBROUTINE  getresults_cms90 (null )
  CALL geteprfilter ("CMS90" )
  CALL getpopulation_cms90 (0 )
  CALL getattribution_cms90 (0 )
  CALL getexclusion_cms90 (0 )
  CALL getoutcome_cms90 (0 )
  CALL summaryreport ("MU_EC_CMS90_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_cms90 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE addedenc = i4 WITH noconstant (0 ) ,protect
  DECLARE addedenc2 = i4 WITH noconstant (0 ) ,protect
  DECLARE inpopulation = i2 WITH noconstant (0 ) ,protect
  DECLARE per_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND (pop.lh_amb_qual_encntr_2019_id > 0 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: CMS2019_0090: A1" ,
    "POPULATION: CMS2019_0090: B1" ,
    "POPULATION: CMS2019_0090: C1" ,
    "POPULATION: CMS2019_0090: D1" ) )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (p.active_ind = 1 )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.reg_dt_tm ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0
   HEAD pop.person_id
    occa = cnvtdatetime ("01-jan-1900" ) ,addedenc = 0 ,addedenc2 = 0 ,inpopulation = 0 ,personcnt =
    (personcnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,stat = alterlist (lh_ep_reply->persons ,
     personcnt ) ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[
    personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,lh_ep_reply
    ->persons[personcnt ].outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome =
    "Not Met, Not Done"
   DETAIL
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
    ,
    IF ((floor (datetimediff (pop.reg_dt_tm ,cnvtdatetime (beg_extract_dt_tm ) ) ) <= 185 )
    AND (addedenc = 0 )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) ) ) stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,1 ) ,
     lh_ep_reply->persons[personcnt ].encntr_cnt = 1 ,lh_ep_reply->persons[personcnt ].encntrs[1 ].
     encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[1 ].fin = pop
     .financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[1 ].reg_dt_tm = pop.reg_dt_tm ,
     IF ((((pop.disch_dt_tm != null ) ) OR ((pop.disch_dt_tm != 0 ) )) ) lh_ep_reply->persons[
      personcnt ].encntrs[1 ].disch_dt_tm = pop.disch_dt_tm
     ELSE lh_ep_reply->persons[personcnt ].encntrs[1 ].disch_dt_tm = cnvtlookahead ("23,H" ,
       cnvtdatetime (datetimetrunc (pop.reg_dt_tm ,"dd" ) ) )
     ENDIF
     ,addedenc = 1 ,occa = pop.reg_dt_tm
    ENDIF
    ,
    IF ((addedenc = 1 )
    AND (addedenc2 = 0 ) ) stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,2 ) ,
     lh_ep_reply->persons[personcnt ].encntr_cnt = 2 ,lh_ep_reply->persons[personcnt ].encntrs[2 ].
     encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[2 ].fin = pop
     .financial_nbr_txt ,lh_ep_reply->persons[personcnt ].encntrs[2 ].reg_dt_tm = pop.reg_dt_tm ,
     IF ((((pop.disch_dt_tm != null ) ) OR ((pop.disch_dt_tm != 0 ) )) ) lh_ep_reply->persons[
      personcnt ].encntrs[2 ].disch_dt_tm = pop.disch_dt_tm
     ELSE lh_ep_reply->persons[personcnt ].encntrs[2 ].disch_dt_tm = cnvtlookahead ("23,H" ,
       cnvtdatetime (datetimetrunc (pop.reg_dt_tm ,"dd" ) ) )
     ENDIF
     ,
     IF ((floor (datetimediff (pop.reg_dt_tm ,occa ) ) BETWEEN 30 AND 180 ) ) inpopulation = 1 ,
      addedenc2 = 1
     ENDIF
    ENDIF
   FOOT  p.person_id
    IF ((inpopulation = 0 ) ) personcnt = (lh_ep_reply->person_cnt - 1 ) ,lh_ep_reply->person_cnt =
     personcnt ,stat = alterlist (lh_ep_reply->persons ,personcnt )
    ENDIF
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR)" )
  ;end select
  CALL end_time (0 )
  CALL lhprint (";get dx & prob of heart failure" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id )
   AND (pat.active_ind = 1 )
   AND (pat.lh_amb_event_data_2019_id > 0 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("CMS2019_0090: HEART_FAILURE: F1" ,
   "CMS2019_0090: HEART_FAILURE: G1" ,
   "CMS2019_0090: HEART_FAILURE: H1" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.ep_dt_tm
   HEAD REPORT
    per_pos = 0
   HEAD pat.person_id
    per_pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((per_pos > 0 ) )
     IF ((qry.query_name = "CMS2019_0090: HEART_FAILURE: H1" ) )
      IF ((checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.ep_end_dt_tm ) = 1 ) ) lh_ep_reply->
       persons[per_pos ].exclude_ind = 0
      ENDIF
     ELSE
      IF ((pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
      AND (diagnosisdatecheck (pat.ep_dt_tm ,pat.ep_end_dt_tm ,pat.updt_source ) = 1 ) ) lh_ep_reply
       ->persons[per_pos ].exclude_ind = 0
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("Add Encounter results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_cms90 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0090" ,"'CPT4','SNMCT','HCPCS'" ,"1=1" )
  CALL getepdata ("MU_EC_CMS90_2019" ,br_filters->provider_attribution ,"CMS2019_0090" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_cms90 (null )
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.lh_amb_event_data_2019_id > 0 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (qry.query_name IN ("CMS2019_0090: DEMENTIA_CANCER: H2" ,
   "CMS2019_0090: HOSPICE_CARE_AMB: A1" ,
   "CMS2019_0090: HOSPICE_CARE_AMB: D1" ,
   "CMS2019_0090: HOSPICE_CARE_AMB: D2" ,
   "CMS2019_0090: HOSPICE_CARE_AMB: E1" ,
   "CMS2019_0090: DISCH_HOME_HOSPIC_CARE: R1" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    out_flg = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("CMS2019_0090: DEMENTIA_CANCER: H2" ,
     "CMS2019_0090: HOSPICE_CARE_AMB: D2" ,
     "CMS2019_0090: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((checkoverlapsmeasurementperiod (pat.ep_dt_tm ,pat.ep_end_dt_tm ) = 1 ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("CMS2019_0090: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
      IF ((pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("CMS2019_0090: HOSPICE_CARE_AMB: A1" ,
     "CMS2019_0090: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 ) ) lh_ep_reply->persons[pos ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].
     outcome = "Denominator Exclusion"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  IF ((debug_ind = 1 ) )
   CALL echo ("After exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms90 (null )
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE enccnt = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   date = format (pat.ep_dt_tm ,"@SHORTDATE" )
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
    iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
   AND (pat.ep_dt_tm BETWEEN datetimeadd (cnvtdatetime (beg_extract_dt_tm ) ,- (14 ) ) AND
   cnvtdatetime (end_extract_dt_tm ) )
   AND (pat.active_ind = 1 )
   AND (pat.lh_amb_event_data_2019_id > 0 )
   AND (pat.d_query_id = qry.d_query_id )
   AND (pat.ce_result_val != " " )
   AND (qry.query_name IN ("CMS2019_0090: PROMIS29_RESULT: E1" ,
   "CMS2019_0090: PROMIS29_RESULT: E2" ,
   "CMS2019_0090: PROMIS29_RESULT: E3" ,
   "CMS2019_0090: PROMIS29_RESULT: E4" ,
   "CMS2019_0090: PROMIS29_RESULT: E5" ,
   "CMS2019_0090: PROMIS29_RESULT: E6" ,
   "CMS2019_0090: PROMIS29_RESULT: E7" ,
   "CMS2019_0090: KCCQ_RESULT: E1" ,
   "CMS2019_0090: KCCQ_RESULT: E2" ,
   "CMS2019_0090: KCCQ_RESULT: E3" ,
   "CMS2019_0090: KCCQ_RESULT: E4" ,
   "CMS2019_0090: KCCQ_RESULT: E5" ,
   "CMS2019_0090: KCCQ_RESULT: E6" ,
   "CMS2019_0090: VR12_RESULT: E1" ,
   "CMS2019_0090: VR12_RESULT: E2" ,
   "CMS2019_0090: VR36_RESULT: E1" ,
   "CMS2019_0090: VR36_RESULT: E2" ,
   "CMS2019_0090: PROMIS10_RESULT: E1" ,
   "CMS2019_0090: PROMIS10_RESULT: E2" ) )
   AND (qry.active_ind = 1 )
   ORDER BY pat.person_id ,
    pat.encntr_id ,
    date ,
    qry.query_name
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locateval (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter2 ].person_id ) ,
    IF ((pos > 0 ) ) enccnt = 0
    ENDIF
   HEAD date
    promis29_result = 0 ,kccq_result = 0 ,vr12_result = 0 ,vr36_result = 0 ,promis10_result = 0
   HEAD qry.query_name
    IF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E1" ) ) promis29_result = (promis29_result
     + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E2" ) ) promis29_result = (
     promis29_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E3" ) ) promis29_result = (
     promis29_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E4" ) ) promis29_result = (
     promis29_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E5" ) ) promis29_result = (
     promis29_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E6" ) ) promis29_result = (
     promis29_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS29_RESULT: E7" ) ) promis29_result = (
     promis29_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: KCCQ_RESULT: E1" ) ) kccq_result = (kccq_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: KCCQ_RESULT: E2" ) ) kccq_result = (kccq_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: KCCQ_RESULT: E3" ) ) kccq_result = (kccq_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: KCCQ_RESULT: E4" ) ) kccq_result = (kccq_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: KCCQ_RESULT: E5" ) ) kccq_result = (kccq_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: KCCQ_RESULT: E6" ) ) kccq_result = (kccq_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: VR12_RESULT: E1" ) ) vr12_result = (vr12_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: VR12_RESULT: E2" ) ) vr12_result = (vr12_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: VR36_RESULT: E1" ) ) vr36_result = (vr36_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: VR36_RESULT: E2" ) ) vr36_result = (vr36_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS10_RESULT: E1" ) ) promis10_result = (
     promis10_result + 1 )
    ELSEIF ((qry.query_name = "CMS2019_0090: PROMIS10_RESULT: E2" ) ) promis10_result = (
     promis10_result + 1 )
    ENDIF
   DETAIL
    IF ((((promis29_result = 7 ) ) OR ((((kccq_result = 6 ) ) OR ((((vr12_result = 2 ) ) OR ((((
    vr36_result = 2 ) ) OR ((promis10_result = 2 ) )) )) )) )) )
     IF ((enccnt = 0 )
     AND (pat.ep_end_dt_tm BETWEEN cnvtlookbehind ("14,D" ,cnvtdatetime (lh_ep_reply->persons[pos ].
       encntrs[1 ].disch_dt_tm ) ) AND cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[1 ].
      disch_dt_tm ) ) ) enccnt = 1 ,lh_ep_reply->persons[pos ].special_cond_dt_tm = pat.ep_end_dt_tm
     ELSEIF ((enccnt = 1 )
     AND (lhgetdatetimedifference (datetimetrunc (cnvtdatetime (pat.ep_dt_tm ) ,"DD" ) ,
      datetimetrunc (cnvtdatetime (lh_ep_reply->persons[pos ].special_cond_dt_tm ) ,"DD" ) ,"D" )
     BETWEEN 30 AND 180 ) ) enccnt = 2
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((enccnt = 2 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,lh_ep_reply->persons[pos ].
     outcome = "Met, Done"
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE getresults_cms127 (null ) = null
 DECLARE getpopulation_cms127 (null ) = null
 DECLARE getexclusion_cms127 (null ) = null
 DECLARE getattribution_cms127 (null ) = null
 DECLARE getoutcome_cms127 (null ) = null
 SUBROUTINE  getpopulation_cms127 (null )
  DECLARE personcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE enccnt = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE total_size = i4 WITH noconstant (0 ) ,protect
  DECLARE batch_size = i4 WITH constant (5000 ) ,protect
  DECLARE enc_batch_size = i4 WITH constant (5 ) ,protect
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  CALL lhprint (";Initial Population Query" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.population_group = "CMS2019_0127" )
    AND (qry.active_ind = 1 ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("65,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (p.active_ind = 1 )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    total_size = 20000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (personcnt + 1 ) ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->person_cnt = personcnt ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id
    ,lh_ep_reply->persons[personcnt ].mrn = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].
    outcome_ind = 0 ,lh_ep_reply->persons[personcnt ].outcome = "Not Met, Not Done" ,enccnt = 0 ,
    enc_total_size = 5 ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_total_size )
   HEAD pop.encntr_id
    enccnt = (enccnt + 1 ) ,
    IF ((enc_total_size < enccnt ) ) enc_total_size = (enc_total_size + enc_batch_size ) ,stat =
     alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enc_total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntr_cnt = enccnt ,lh_ep_reply->persons[personcnt ].encntrs[
    enccnt ].encntr_id = pop.encntr_id ,lh_ep_reply->persons[personcnt ].encntrs[enccnt ].fin = pop
    .financial_nbr_txt ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
   FOOT  pop.person_id
    stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,enccnt )
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population Query results" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getexclusion_cms127 (null )
  DECLARE person_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE enc_iter = i4 WITH noconstant (0 ) ,protect
  DECLARE person_pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";problem exclusion check" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (person_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[person_iter ].person_id ,0 ,lh_ep_reply->persons[person_iter ].outcome_ind )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0127: HOSPICE_CARE_AMB: A1" ,
    "CMS2019_0127: HOSPICE_CARE_AMB: D1" ,
    "CMS2019_0127: HOSPICE_CARE_AMB: D2" ,
    "CMS2019_0127: HOSPICE_CARE_AMB: E2" ,
    "CMS2019_0127: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.encntr_id
   HEAD REPORT
    person_pos = 0
   HEAD pat.person_id
    out_flg = 0 ,person_pos = locatevalsort (enc_iter ,1 ,size (lh_ep_reply->persons ,5 ) ,pat
     .person_id ,lh_ep_reply->persons[enc_iter ].person_id )
   DETAIL
    IF ((person_pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("CMS2019_0127: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("CMS2019_0127: HOSPICE_CARE_AMB: A1" ,
     "CMS2019_0127: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("CMS2019_0127: HOSPICE_CARE_AMB: D2" ,
     "CMS2019_0127: HOSPICE_CARE_AMB: E2" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.person_id
    IF ((out_flg = 1 )
    AND (person_pos > 0 ) ) lh_ep_reply->persons[person_pos ].outcome_ind = 2 ,lh_ep_reply->persons[
     person_pos ].outcome = "Denominator Exclusion"
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|person_pos:" ,person_pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getattribution_cms127 (null )
  CALL getnonmappednomenclature ("OFFICE_VISIT" ,"0127" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("HOME_HEALTH_SERVICES" ,"0127" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_ESTAB_OFFICE_VISIT_18_UP" ,"0127" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("PC_INITIAL_OFFICE_VISIT_18_UP" ,"0127" ,"'CPT4'" ,"1=1" )
  CALL getnonmappednomenclature ("ANNUAL_WELLNESS_VISIT" ,"0127" ,"'HCPCS'" ,"1=1" )
  CALL getnonmappednomenclature ("CS_LTR_FACILITY_ENC" ,"0127" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("NURSING_FACILITY_VISIT_ENC" ,"0127" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getnonmappednomenclature ("DISCHG_SER_NURSE_FAC_ENC" ,"0127" ,"'CPT4'" ,"1=1" )
  CALL getepdata ("MU_EC_CMS127_2019" ,br_filters->provider_attribution ,"CMS2019_0127" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms127 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  CALL lhprint (";get outcome" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id ,0 ,lh_ep_reply->persons[iter1 ].outcome_ind )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("CMS2019_0127: PNEUMO_VACCINE: E1" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: A2" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: B2" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: C2" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: D2" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: E2" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: L2" ,
    "CMS2019_0127: PNEUMO_VAC_ADMIN: L3" ) )
    AND (qry.active_ind = 1 ) )
   ORDER BY pat.person_id
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,
    IF ((pos > 0 )
    AND (lh_ep_reply->persons[pos ].outcome_ind = 0 ) ) lh_ep_reply->persons[pos ].outcome_ind = 1 ,
     lh_ep_reply->persons[pos ].outcome = "Met, Done"
    ENDIF
   WITH nocounter ,expand = 1 ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo ("After outcomes" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getresults_cms127 (null )
  SET br_filters->provider_attribution = getproviderattribution ("CMS127" )
  CALL geteprfilter ("CMS127" )
  CALL getpopulation_cms127 (0 )
  CALL getattribution_cms127 (0 )
  CALL getexclusion_cms127 (0 )
  CALL getoutcome_cms127 (0 )
  CALL summaryreport ("MU_EC_CMS127_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 DECLARE getresults_cms146 (null ) = null
 DECLARE getpopulation_cms146 (null ) = null
 DECLARE getattribution_cms146 (null ) = null
 DECLARE getoutcome_cms146 (null ) = null
 DECLARE getexclusion_cms146 (null ) = null
 SUBROUTINE  getresults_cms146 (null )
  CALL geteprfilter ("CMS146" )
  CALL getpopulation_cms146 (0 )
  CALL getattribution_cms146 (0 )
  CALL getexclusion_cms146 (0 )
  CALL getoutcome_cms146 (0 )
  CALL summaryreport ("MU_EC_CMS146_2019" )
  SET stat = initrec (lh_ep_reply )
  SET stat = initrec (br_filters )
 END ;Subroutine
 SUBROUTINE  getpopulation_cms146 (null )
  IF ((debug_ind = 1 ) )
   SET debug_clause = "pop.person_id = debug_pid"
  ENDIF
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE qual_flag = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";Initial Population Query : EDOrAmbulatoryVisit" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_qual_encntr_2019 pop ),
    (lh_d_query qry ),
    (lh_d_person p )
   PLAN (pop
    WHERE (pop.reg_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.pop_ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
     end_extract_dt_tm ) )
    AND (pop.active_ind = 1 )
    AND parser (debug_clause )
    AND parser (org_id_parser )
    AND parser (location_filter ) )
    JOIN (qry
    WHERE (pop.d_query_id = qry.d_query_id )
    AND (qry.query_name IN ("POPULATION: CMS2019_0146: A1" ,
    "POPULATION: CMS2019_0146: B1" ,
    "POPULATION: CMS2019_0146: C1" ,
    "POPULATION: CMS2019_0146: D1" ) ) )
    JOIN (p
    WHERE (p.person_id = pop.person_id )
    AND parser (logical_domain_id_parser )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) <= cnvtlookbehind ("3,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) )
    AND (nullcheck (p.birth_dt_tm ,null ,nullind (p.birth_dt_tm ) ) > cnvtlookbehind ("18,Y" ,
     cnvtdatetime (beg_extract_dt_tm ) ) ) )
   ORDER BY pop.person_id ,
    pop.encntr_id
   HEAD REPORT
    personcnt = 0 ,
    total_size = 10000 ,
    batch_size = 5000 ,
    stat = alterlist (lh_ep_reply->persons ,total_size )
   HEAD pop.person_id
    personcnt = (lh_ep_reply->person_cnt + 1 ) ,lh_ep_reply->person_cnt = personcnt ,
    IF ((total_size < personcnt ) ) total_size = (total_size + batch_size ) ,stat = alterlist (
      lh_ep_reply->persons ,total_size )
    ENDIF
    ,lh_ep_reply->persons[personcnt ].person_id = pop.person_id ,lh_ep_reply->persons[personcnt ].mrn
     = pop.comm_mrn_txt ,lh_ep_reply->persons[personcnt ].exclude_ind = 1 ,encntrcnt = 0
   HEAD pop.encntr_id
    encntrcnt = (lh_ep_reply->persons[personcnt ].encntr_cnt + 1 ) ,lh_ep_reply->persons[personcnt ].
    encntr_cnt = encntrcnt ,stat = alterlist (lh_ep_reply->persons[personcnt ].encntrs ,encntrcnt ) ,
    lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].encntr_id = pop.encntr_id ,lh_ep_reply->
    persons[personcnt ].encntrs[encntrcnt ].fin = pop.financial_nbr_txt ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].exclude_ind = 1 ,lh_ep_reply->persons[personcnt ].encntrs[
    encntrcnt ].reg_dt_tm = pop.reg_dt_tm ,
    IF ((((pop.disch_dt_tm != null ) ) OR ((pop.disch_dt_tm != 0 ) )) ) lh_ep_reply->persons[
     personcnt ].encntrs[encntrcnt ].disch_dt_tm = pop.disch_dt_tm
    ELSE lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].disch_dt_tm = datetimeadd (
      datetimetrunc (pop.reg_dt_tm ,"dd" ) ,0.999999 )
    ENDIF
    ,
    IF ((pop.updt_source = "IMPORT*" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 1 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 2
     ENDIF
    ENDIF
    ,
    IF ((pop.updt_source = "lh_nqf2019_load.prg" )
    AND (lh_ep_reply->persons[personcnt ].updt_src_ind != 3 ) )
     IF ((lh_ep_reply->persons[personcnt ].updt_src_ind = 2 ) ) lh_ep_reply->persons[personcnt ].
      updt_src_ind = 3
     ELSE lh_ep_reply->persons[personcnt ].updt_src_ind = 1
     ENDIF
    ENDIF
    ,lh_ep_reply->persons[personcnt ].encntrs[encntrcnt ].outcome_ind = 0 ,lh_ep_reply->persons[
    personcnt ].encntrs[encntrcnt ].outcome = "Not Met, Not Done"
   FOOT REPORT
    stat = alterlist (lh_ep_reply->persons ,personcnt )
   WITH nocounter ,orahint ("index(pop XIE02LH_AMB_QUAL_ENCNTR_2019)" )
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";Initial Population" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL end_time (0 )
  CALL lhprint (";Initial Population Query: Encounter With Antibiotic Ordered Within Three Days" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.ep_dt_tm < datetimeadd (cnvtdatetime (cnvtdate (end_extract_dt_tm ) ,0 ) ,3 ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name = "CMS2019_0146: MEDICATION: M2" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].special_group != 1 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) AND
      datetimeadd (cnvtdatetime (cnvtdate (cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].
          disch_dt_tm ) ) ,235959 ) ,3 ) ) ) lh_ep_reply->persons[pos ].encntrs[i ].special_group =
       1
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL lhprint (";Initial Population Query: Encounter With Pharyngitis or Tonsillitis" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (end_extract_dt_tm
     ) )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0146: ACUTE_PHAR_TON: F1" ,
    "CMS2019_0146: ACUTE_PHAR_TON: G1" ,
    "CMS2019_0146: ACUTE_PHAR_TON: H1" ) ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id ) ,qual_flag = 0
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].special_group = 1 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind != 0 )
      AND (pat.ep_dt_tm BETWEEN cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) AND
      cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].disch_dt_tm ) ) ) lh_ep_reply->persons[
       pos ].encntrs[i ].exclude_ind = 0 ,qual_flag = 1
      ENDIF
     ENDFOR
    ENDIF
   FOOT  pat.person_id
    IF ((qual_flag = 1 ) ) lh_ep_reply->persons[pos ].exclude_ind = 0
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  CALL removedummyitem (lh_ep_reply ,"exclude_ind" )
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getexclusion_cms146 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter3 = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE encntr_pos = i4 WITH noconstant (0 ) ,protect
  DECLARE exc_flag = i2 WITH noconstant (0 ) ,protect
  DECLARE cnt = i2 WITH noconstant (0 ) ,protect
  CALL lhprint (";Exclusion check: hospice care " )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 )
    AND (pat.ep_dt_tm <= cnvtdatetime (end_extract_dt_tm ) ) )
    JOIN (qry
    WHERE (qry.d_query_id = pat.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name IN ("CMS2019_0146: HOSPICE_CARE_AMB: A1" ,
    "CMS2019_0146: HOSPICE_CARE_AMB: D1" ,
    "CMS2019_0146: HOSPICE_CARE_AMB: D2" ,
    "CMS2019_0146: HOSPICE_CARE_AMB: E1" ,
    "CMS2019_0146: DISCH_HOME_HOSPIC_CARE: R1" ) ) )
   ORDER BY pat.person_id ,
    pat.ep_end_dt_tm
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    out_flg = 0 ,pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,
     lh_ep_reply->persons[iter2 ].person_id )
   HEAD pat.ep_end_dt_tm
    dummy = 0
   DETAIL
    IF ((pos > 0 )
    AND (out_flg = 0 ) )
     IF ((qry.query_name IN ("CMS2019_0146: DISCH_HOME_HOSPIC_CARE: R1" ) )
     AND (pat.ep_end_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
      end_extract_dt_tm ) ) ) out_flg = 1
     ELSEIF ((qry.query_name IN ("CMS2019_0146: HOSPICE_CARE_AMB: A1" ,
     "CMS2019_0146: HOSPICE_CARE_AMB: D1" ) ) )
      IF ((pat.ep_dt_tm BETWEEN cnvtdatetime (beg_extract_dt_tm ) AND cnvtdatetime (
       end_extract_dt_tm ) ) ) out_flg = 1
      ENDIF
     ELSEIF ((qry.query_name IN ("CMS2019_0146: HOSPICE_CARE_AMB: D2" ,
     "CMS2019_0146: HOSPICE_CARE_AMB: E1" ) ) )
      IF ((((pat.ep_end_dt_tm > cnvtdatetime (beg_extract_dt_tm ) ) ) OR ((pat.ep_end_dt_tm = null )
      )) ) out_flg = 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pat.ep_end_dt_tm
    IF ((out_flg = 1 )
    AND (pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 ) ) lh_ep_reply->persons[pos ].
       encntrs[i ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
       "Denominator Exclusion"
      ENDIF
     ENDFOR
    ENDIF
    ,
    IF ((debug_ind = 1 ) )
     CALL echo (build ("debug:" ,pat.person_id ,"|pos:" ,pos ) ) ,
     CALL echo (build ("debug:query:" ,qry.query_name ,"|EP Date:" ,format (pat.ep_dt_tm ,";;q" ) )
     ) ,
     CALL echo (build ("|ep end date:" ,format (pat.ep_end_dt_tm ,";;q" ) ) )
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
  CALL lhprint (";OUTCOME:Denominator Exclusion" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name = "CMS2019_0146: MEDICATION: M3" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind != 2 )
      AND (pat.ep_dt_tm <= cnvtdatetime (lh_ep_reply->persons[pos ].encntrs[i ].reg_dt_tm ) )
      AND (((pat.ep_end_dt_tm >= cnvtlookbehind ("30,D" ,cnvtdatetime (lh_ep_reply->persons[pos ].
        encntrs[i ].reg_dt_tm ) ) ) ) OR ((pat.ep_end_dt_tm = null ) )) ) lh_ep_reply->persons[pos ].
       encntrs[i ].outcome_ind = 2 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome =
       "Denominator Exclusion"
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
  IF ((debug_ind = 1 ) )
   CALL echo (";After get exclusion" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getoutcome_cms146 (null )
  DECLARE iter1 = i4 WITH noconstant (0 ) ,protect
  DECLARE iter2 = i4 WITH noconstant (0 ) ,protect
  DECLARE exc_flag = i2 WITH noconstant (0 ) ,protect
  DECLARE pos = i4 WITH noconstant (0 ) ,protect
  DECLARE i = i4 WITH protect ,noconstant (0 )
  CALL lhprint (";OUTCOME:Met, Done" )
  CALL beg_time (0 )
  SELECT INTO "nl:"
   FROM (lh_amb_event_data_2019 pat ),
    (lh_d_query qry )
   PLAN (pat
    WHERE expand (iter1 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->persons[
     iter1 ].person_id )
    AND (pat.active_ind = 1 ) )
    JOIN (qry
    WHERE (pat.d_query_id = qry.d_query_id )
    AND (qry.active_ind = 1 )
    AND (qry.query_name = "CMS2019_0146: STREP_PROC: E3" ) )
   ORDER BY pat.person_id
   HEAD REPORT
    pos = 0
   HEAD pat.person_id
    pos = locatevalsort (iter2 ,1 ,size (lh_ep_reply->persons ,5 ) ,pat.person_id ,lh_ep_reply->
     persons[iter2 ].person_id )
   DETAIL
    IF ((pos > 0 ) )
     FOR (i = 1 TO size (lh_ep_reply->persons[pos ].encntrs ,5 ) )
      IF ((lh_ep_reply->persons[pos ].encntrs[i ].exclude_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind = 0 )
      AND (lh_ep_reply->persons[pos ].encntrs[i ].ep_ind = 1 ) )
       IF ((pat.ep_dt_tm BETWEEN cnvtlookbehind ("3,D" ,cnvtdatetime (lh_ep_reply->persons[pos ].
         encntrs[i ].disch_dt_tm ) ) AND cnvtlookahead ("3,D" ,cnvtdatetime (lh_ep_reply->persons[
         pos ].encntrs[i ].disch_dt_tm ) ) ) ) lh_ep_reply->persons[pos ].encntrs[i ].outcome_ind =
        1 ,lh_ep_reply->persons[pos ].encntrs[i ].outcome = "Met, Done"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   WITH nocounter ,orahint ("index(pat XIE01LH_AMB_EVENT_DATA_2019)" ) ,expand = 1
  ;end select
  CALL end_time (0 )
 END ;Subroutine
 SUBROUTINE  getattribution_cms146 (null )
  CALL getnonmappednomenclature ("AMB_ED_VISIT" ,"0146" ,"'CPT4','SNMCT'" ,"1=1" )
  CALL getepdata ("MU_EC_CMS146_2019" ,br_filters->provider_attribution ,"CMS2019_0146" )
  IF ((debug_ind = 1 ) )
   CALL echo ("After attribution" )
   CALL echorecord (lh_ep_reply )
  ENDIF
 END ;Subroutine
 DECLARE al_batch_size = i4 WITH public ,noconstant (1000 )
 DECLARE report_start_dt_tm = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) )
 DECLARE report_end_dt_tm = dq8 WITH public
 DECLARE script_name = vc WITH protect ,constant ("lh_nqf2019_report" )
 DECLARE audit_filename = vc WITH protect ,noconstant (concat (script_name ,"_audit_" ) )
 DECLARE extract_dt_tm = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) )
 DECLARE beg_extract_dt_tm = dq8
 DECLARE end_extract_dt_tm = dq8
 DECLARE beg_year = i2
 DECLARE end_year = i2
 DECLARE beg_extract_dt_tm_year_start = dq8
 DECLARE end_extract_dt_tm_year_end = dq8
 DECLARE beg_extract_dt_tm_41 = dq8 WITH public ,noconstant (0 )
 DECLARE end_extract_dt_tm_41 = dq8 WITH public ,noconstant (0 )
 DECLARE logical_domain_id = f8 WITH public ,noconstant (0.0 )
 DECLARE category_mean = vc WITH noconstant ("MU_CQM_EC_2019" )
 DECLARE logical_domain_id_parser = vc WITH noconstant ("" ) ,protect
 DECLARE pwx_ind = i2 WITH noconstant (0 )
 DECLARE org_id_parser = vc WITH noconstant ("pop.organization_id in(" )
 DECLARE pwx_user_id = f8 WITH noconstant (0 )
 DECLARE log_ep_string = vc
 DECLARE log_measure_start_dt_tm = dq8 WITH noconstant (0 )
 DECLARE log_measure_end_dt_tm = dq8 WITH noconstant (0 )
 DECLARE output_style = i2 WITH noconstant (0 )
 DECLARE errclear = i4 WITH noconstant (0 ) ,protect
 DECLARE errcode = i4 WITH noconstant (0 ) ,protect
 DECLARE errmsg = vc WITH noconstant ("" ) ,protect
 DECLARE err_count = i4 WITH noconstant (0 ) ,protect
 DECLARE pos = i4 WITH noconstant (0 ) ,protect
 DECLARE target_file = vc WITH noconstant ("" )
 DECLARE log_measure_string = vc
 DECLARE date_range_error = vc WITH protect ,noconstant ("" )
 DECLARE epbool = i2 WITH protect ,noconstant (0 )
 DECLARE brdefeps = i2 WITH protect ,noconstant (1 )
 DECLARE num = i4 WITH protect ,noconstant (0 )
 DECLARE i = i4 WITH protect ,noconstant (0 )
 DECLARE j = i4 WITH protect ,noconstant (0 )
 DECLARE arr_size = i4 WITH protect ,noconstant (0 )
 DECLARE grpsumpos = i4 WITH protect ,noconstant (0 )
 DECLARE measbool = i2 WITH protect ,noconstant (0 )
 SET params->outdev =  $OUTDEV
 SET params->optinitiative =  $OPTINITIATIVE
 SET params->year =  $YEAR
 SET params->quarter_year_month =  $DT_QUARTER_YEAR
 SET params->start_dt = cnvtdatetime ( $START_DT )
 SET params->end_dt = cnvtdatetime ( $END_DT )
 SET params->chksummaryonly =  $CHKSUMMARYONLY
 SET params->orgfilter =  $ORGFILTER
 SET params->epfilter =  $EPFILTER
 SET params->brdefmeas = trim (build ( $BRDEFMEAS ) ,3 )
 SET params->report_by =  $REPORTBY
 IF (( $OUTDEV = "*.csv" ) )
  SET output_style = 1
 ENDIF
 CALL gettarget_file (0 )
 CALL getpwx_info (0 )
 SELECT INTO "nl:"
  FROM (prsnl pl )
  WHERE (pl.person_id = reqinfo->updt_id )
  DETAIL
   rpt->created_by = pl.name_full_formatted ,
   IF ((checkdic ("PRSNL.LOGICAL_DOMAIN_ID" ,"A" ,0 ) > 0 ) ) logical_domain_id = pl
    .logical_domain_id
   ELSE logical_domain_id = 0.0
   ENDIF
  WITH nocounter
 ;end select
 SET logical_domain_id_parser = build2 ("p.logical_domain_id = " ,logical_domain_id )
 CALL getepchargebimoption (0 )
 CALL addattributiontodqueryifneeded (0 )
 SET date_range_error = get_rpt_dt_range_prompt (params->optinitiative ,params->year ,params->
  quarter_year_month ,cnvtdatetime (params->start_dt ) ,cnvtdatetime (params->end_dt ) )
 IF ((date_range_error != "" ) )
  SET rpt->status = "F"
  SET rpt->message = date_range_error
 ENDIF
 SET params->chksummaryonly = cnvtupper (params->chksummaryonly )
 SET paramtype = substring (1 ,1 ,reflect (parameter (7 ,0 ) ) )
 SELECT INTO "NL:"
  FROM (dprotect d )
  WHERE (d.object = "P" )
  AND (d.object_name IN (cnvtupper (script_name ) ) )
  ORDER BY d.object_name
  HEAD REPORT
   obj_name = "" ,
   obj_version = ""
  HEAD d.object_name
   obj_name = build (d.object_name ) ,obj_version = build (format (d.datestamp ,"DD-MMM-YYYY;;D" ) ,
    "-" ,format (d.timestamp ,"HH:MM:SS;;M" ) )
  WITH nocounter ,separator = " " ,format
 ;end select
 SET paramtype = substring (1 ,1 ,reflect (parameter (10 ,0 ) ) )
 IF ((params->report_by = "GPRO" ) )
  SET epbool = determine_grps_from_prompt (paramtype ,params )
  CALL retrieve_group_eps (0 )
 ELSE
  SET epbool = determineepsfromprompt (paramtype ,params->epfilter ,params->orgfilter ,params )
 ENDIF
 IF ((params->brdefmeas != "-1" )
 AND (params->report_by != "CPC" ) )
  SET stat = initrec (tmp_br_def_epgpro_meas )
  IF ((params->report_by = "GPRO" ) )
   CALL base_getqrdabrgrpmeas_list (tmp_br_def_epgpro_meas )
   SET arr_size = size (params->grps ,5 )
   FOR (i = arr_size TO 1 BY - (1 ) )
    SET pos = locateval (num ,1 ,size (tmp_br_def_epgpro_meas->eps ,5 ) ,params->grps[i ].br_gpro_id
     ,tmp_br_def_epgpro_meas->eps[num ].br_eligible_provider_id )
    IF ((pos <= 0 ) )
     SET arr_size = (arr_size - 1 )
     SET stat = alterlist (params->grps ,arr_size ,(i - 1 ) )
     SET params->grp_cnt = arr_size
    ELSE
     SET stat = alterlist (params->grps[i ].measures ,size (tmp_br_def_epgpro_meas->eps[pos ].
       measures ,5 ) )
     SET grpsumpos = locateval (num ,1 ,size (grp_summary->grps ,5 ) ,params->grps[i ].br_gpro_id ,
      grp_summary->grps[num ].br_gpro_id )
     IF ((grpsumpos > 0 ) )
      SET stat = alterlist (grp_summary->grps[grpsumpos ].measures ,size (tmp_br_def_epgpro_meas->
        eps[pos ].measures ,5 ) )
     ENDIF
     FOR (j = 1 TO size (tmp_br_def_epgpro_meas->eps[pos ].measures ,5 ) )
      SET params->grps[i ].measures[j ].mean = tmp_br_def_epgpro_meas->eps[pos ].measures[j ].mean
      IF ((grpsumpos > 0 ) )
       SET grp_summary->grps[grpsumpos ].measures[j ].report_mean = tmp_br_def_epgpro_meas->eps[pos ]
       .measures[j ].mean
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   IF ((size (params->grps ,5 ) = 0 ) )
    SET brdefeps = 0
   ELSE
    CALL retrieve_group_eps (0 )
   ENDIF
  ELSE
   CALL base_getqrdabrepmeas_list (tmp_br_def_epgpro_meas )
   SET arr_size = size (params->eps ,5 )
   FOR (i = arr_size TO 1 BY - (1 ) )
    SET pos = locateval (num ,1 ,size (tmp_br_def_epgpro_meas->eps ,5 ) ,params->eps[i ].
     br_eligible_provider_id ,tmp_br_def_epgpro_meas->eps[num ].br_eligible_provider_id )
    IF ((pos <= 0 ) )
     SET arr_size = (arr_size - 1 )
     SET stat = alterlist (params->eps ,arr_size ,(i - 1 ) )
     SET params->ep_cnt = arr_size
    ELSE
     SET params->eps[i ].measure_cnt = size (tmp_br_def_epgpro_meas->eps[pos ].measures ,5 )
     SET stat = alterlist (params->eps[i ].measures ,params->eps[i ].measure_cnt )
     FOR (j = 1 TO size (tmp_br_def_epgpro_meas->eps[pos ].measures ,5 ) )
      SET params->eps[i ].measures[j ].mean = tmp_br_def_epgpro_meas->eps[pos ].measures[j ].mean
     ENDFOR
    ENDIF
   ENDFOR
   IF ((size (params->eps ,5 ) = 0 ) )
    SET brdefeps = 0
   ENDIF
  ENDIF
  SET stat = initrec (tmp_br_def_epgpro_meas )
 ENDIF
 IF ((epbool = 0 ) )
  SET rpt->status = "F"
  SET rpt->message = "ERROR: No EPs or groups specified"
  SET log_ep_string = rpt->message
 ELSEIF ((brdefeps = 0 ) )
  SET rpt->status = "F"
  SET rpt->message =
  "ERROR: EPs or groups were specified, but none of them are configured in Bedrock."
  SET log_ep_string = rpt->message
 ENDIF
 SET paramtype = substring (1 ,1 ,reflect (parameter (7 ,0 ) ) )
 IF ((params->brdefmeas != "-1" )
 AND (params->report_by != "CPC" ) )
  SET measbool = 1
 ELSE
  SET measbool = determinemeasuresfromprompt (paramtype ,params )
 ENDIF
 IF ((params->report_by = "GPRO" ) )
  CALL sync_prompt_grp_measures (params )
 ELSE
  CALL sync_prompt_ep_measures (params )
 ENDIF
 IF ((measbool = 0 ) )
  SET rpt->status = "F"
  SET rpt->message = "ERROR:No Measure Specified"
  SET log_measure_string = "ERROR:No Measure Specified"
 ENDIF
 DECLARE strt_pos = i2 WITH noconstant (0 )
 DECLARE end_pos = i2 WITH noconstant (0 )
 DECLARE cnt_meas = i2 WITH noconstant (1 )
 DECLARE meas_len = i2 WITH noconstant (0 )
 IF ((log_measure_string = "ALL" ) )
  SET audit_filename = concat (audit_filename ,"ALL_MEASURES_" )
 ELSE
  SET meas_len = size (log_measure_string ,1 )
  WHILE ((meas_len > 3 ) )
   SET strt_pos = end_pos
   SET end_pos = findstring ("," ,log_measure_string ,(strt_pos + 1 ) ,0 )
   IF ((end_pos != 0 ) )
    SET cnt_meas = (cnt_meas + 1 )
    SET meas_len = (meas_len - (end_pos - strt_pos ) )
   ELSE
    SET meas_len = 3
   ENDIF
  ENDWHILE
  IF ((cnt_meas = 1 ) )
   SET end_pos = findstring ("_" ,log_measure_string ,1 ,1 )
   SET audit_filename = concat (audit_filename ,substring (7 ,(end_pos - 7 ) ,log_measure_string ) ,
    "_" )
  ELSE
   SET strt_pos = findstring ("," ,log_measure_string ,1 ,0 )
   SET end_pos = findstring ("_" ,log_measure_string ,7 ,0 )
   SET audit_filename = concat (audit_filename ,substring (7 ,(end_pos - 7 ) ,log_measure_string ) ,
    "_" )
   SET audit_filename = concat (audit_filename ,"and_" ,trim (cnvtstring ((cnt_meas - 1 ) ) ,3 ) ,
    "_more_" )
  ENDIF
 ENDIF
 SET audit_filename = concat (audit_filename ,"LD" ,cnvtstring (logical_domain_id ) )
 SET audit_filename = concat (audit_filename ,"_" ,format (cnvtdatetime (curdate ,curtime3 ) ,
   "MM_DD_YYYY_HHMMSS;;Q" ) )
 CALL lhprint (build (";" ,script_name ) )
 CALL lhprint (build ("; Report start date :" ,format (report_start_dt_tm ,";;q" ) ) )
 CALL lhprint (build (" " ) )
 CALL lhprint (build ("; Created by :" ,rpt->created_by ) )
 CALL lhprint (build (" " ) )
 CALL lhprint (build ("/************************/" ) )
 CALL lhprint (build ("/****** Parameters ******/" ) )
 CALL lhprint (build ("/********************** */" ) )
 CALL lhprint (build (" " ) )
 CALL lhprint (build2 (";Reporting Time Frame____________________: " ,params->optinitiative ) )
 CALL lhprint (build2 (";Reporting Period Year __________________: " ,params->year ) )
 CALL lhprint (build2 (";Reporting Period Quarter Start Month ___: " ,params->quarter_year_month ) )
 CALL lhprint (build2 (";Reporting Period Start Date_____________: " ,format (beg_extract_dt_tm ,
    ";;q" ) ) )
 CALL lhprint (build2 (";Reporting Period End Date_______________: " ,format (end_extract_dt_tm ,
    ";;q" ) ) )
 CALL lhprint (build2 (";Report Printing Options_________________: " ,params->chksummaryonly ) )
 IF ((params->orgfilter = - (1 ) ) )
  CALL lhprint (build2 (";Organization____________________________: ALL" ) )
 ELSE
  CALL lhprint (build2 (";Organization____________________________: " ,params->orgfilter ) )
 ENDIF
 CALL lhprint (build2 (";Eligible Clinician Filter________________: " ,params->epfilter ) )
 CALL lhprint (build2 (";Charge Table option_____________________: " ,ep_charge_bim_option_ind ) )
 CALL lhprint (build2 (";Logical Domain ID_______________________: " ,logical_domain_id ) )
 CALL lhprint (build ("; OBJECT_NAME :" ,obj_name ) )
 CALL lhprint (build (";-------------------------------------" ) )
 CALL lhprint (build ("; OBJECT VERSION :" ,obj_version ) )
 SET obj_grant_var = ""
 CALL getgrant_script (cnvtupper (script_name ) )
 CALL lhprint (" " )
 CALL lhprint (" " )
 IF ((params->report_by = "GPRO" ) )
  CALL lhprint (build2 (";Group___________________________________: " ,log_ep_string ) )
 ELSEIF ((params->report_by = "CPC" ) )
  CALL lhprint (build2 (";CPC_____________________________________: " ,log_ep_string ) )
 ELSE
  CALL lhprint (build2 (";Eligible Clinician_______________________: " ,log_ep_string ) )
 ENDIF
 CALL lhprint (" " )
 CALL lhprint (build2 (";Quality Measure_________________________: " ,log_measure_string ) )
 CALL run_report_main (0 )
END GO

DROP PROGRAM lh_amb_report_nqf2019_param :dba GO
CREATE PROGRAM lh_amb_report_nqf2019_param :dba
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
  "Eligible Provider" = 0 ,
  "Filter Measures" = "-1" ,
  "Quarter Start Date" = "" ,
  "QRDA Mode" = "NQF" ,
  "Report By" = "INDV"
  WITH outdev ,optinitiative ,year ,start_dt ,end_dt ,chksummaryonly ,lstmeasure ,orgfilter ,
  epfilter ,lsteligbleprovider ,brdefmeas ,dt_quarter_year ,qrdamode ,reportby
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
 DECLARE ep_sel = i2 WITH noconstant (1 )
 DECLARE measure_sel = i2 WITH noconstant (1 )
 DECLARE go_sel = i2 WITH noconstant (1 )
 DECLARE period_sel = i2 WITH noconstant (1 )
 DECLARE mu_attest_sel = i2 WITH noconstant (1 )
 DECLARE output_msg = vc WITH noconstant ("" )
 DECLARE error_msg = vc WITH noconstant ("" )
 DECLARE errcode = i4 WITH noconstant (0 )
 DECLARE errmsg = vc WITH noconstant ("" )
 DECLARE detail_err_msg = vc WITH noconstant ("" )
 DECLARE insert_error_message = vc WITH noconstant ("" )
 DECLARE delete_error_message = vc WITH noconstant ("" )
 DECLARE report_type = i4 WITH noconstant (0 )
 DECLARE report_mean = vc WITH noconstant ("" )
 DECLARE ep_filter = vc WITH noconstant ("" )
 DECLARE err_insert_ind = i2 WITH noconstant (1 )
 DECLARE err_delete_ind = i2 WITH noconstant (1 )
 DECLARE delete_output_msg = vc WITH noconstant ("" )
 DECLARE logical_domain_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE output_to = vc WITH noconstant ("" )
 DECLARE beg_extract_dt_tm = dq8 WITH noconstant (0 )
 DECLARE end_extract_dt_tm = dq8 WITH noconstant (0 )
 DECLARE category_mean = vc WITH noconstant ("MU_CQM_EC_2019" )
 DECLARE log_measure_string = vc WITH protect ,noconstant ("" )
 DECLARE i = i4 WITH protect ,noconstant (0 )
 DECLARE pwx_ind = i2 WITH protect ,noconstant (0 )
 DECLARE pwx_user_id = f8 WITH noconstant (0 )
 DECLARE org_id_parser = vc WITH noconstant ("enc.organization_id in(" )
 DECLARE colstr = vc
 SET ep_filter = trim ( $EPFILTER ,3 )
 SET params->outdev =  $OUTDEV
 SET params->optinitiative =  $OPTINITIATIVE
 SET params->year =  $YEAR
 SET params->quarter_year_month =  $DT_QUARTER_YEAR
 SET params->start_dt = cnvtdatetime ( $START_DT )
 SET params->end_dt = cnvtdatetime ( $END_DT )
 SET params->chksummaryonly =  $CHKSUMMARYONLY
 SET params->orgfilter =  $ORGFILTER
 SET params->epfilter =  $EPFILTER
 SET params->brdefmeas = trim (build ( $BRDEFMEAS ) )
 SET params->qrdamode =  $QRDAMODE
 SET params->report_by =  $REPORTBY
 IF ((value ( $OUTDEV ) != "MINE" )
 AND (reqinfo->updt_id != 0 ) )
  IF ((validate (request->qual[1 ].parameter ) != 0 ) )
   SET output_to = value (request->qual[1 ].parameter )
  ELSE
   SET output_to =  $OUTDEV
  ENDIF
 ELSE
  SET output_to =  $OUTDEV
 ENDIF
 CALL getpwx_info (0 )
 SELECT INTO "nl:"
  FROM (prsnl pl )
  WHERE (pl.person_id = reqinfo->updt_id )
  DETAIL
   IF ((checkdic ("PRSNL.LOGICAL_DOMAIN_ID" ,"A" ,0 ) > 0 ) ) logical_domain_id = pl
    .logical_domain_id
   ELSE logical_domain_id = 0.0
   ENDIF
  WITH nocounter
 ;end select
 SET errcode = error (errmsg ,1 )
 SET errcode = error (errmsg ,0 )
 DELETE FROM (lh_amb_report_param prm )
  WHERE (prm.lh_amb_report_param_id > 0 )
  AND (cnvtupper (prm.updt_task ) = "LH_AMB_REPORT_NQF2019_PARAM.PRG" )
 ;end delete
 SET errcode = error (errmsg ,0 )
 IF ((errcode != 0 ) )
  SET delete_error_message = "Error: In LH_AMB_REPORT_PARAM Truncate"
  SET detail_err_msg = errmsg
  SET err_delete_ind = 1
  CALL echo (delete_error_message )
  CALL echo (detail_err_msg )
  ROLLBACK
 ELSE
  COMMIT
  SET delete_output_msg = "Success: LH_AMB_REPORT_PARAM table Truncated."
  SET err_delete_ind = 0
 ENDIF
 DECLARE epbool = i2 WITH protect ,noconstant (0 )
 DECLARE brdefeps = i2 WITH protect ,noconstant (1 )
 DECLARE pos = i4 WITH protect ,noconstant (0 )
 DECLARE num = i4 WITH protect ,noconstant (0 )
 DECLARE i = i4 WITH protect ,noconstant (0 )
 DECLARE j = i4 WITH protect ,noconstant (0 )
 SET paramtype = substring (1 ,1 ,reflect (parameter (10 ,0 ) ) )
 IF ((params->report_by = "GPRO" ) )
  SET epbool = determine_grps_from_prompt (paramtype ,params )
  CALL retrieve_group_eps (0 )
  SET params->ep_cnt = grp_summary->grp_cnt
  SET stat = alterlist (params->eps ,params->ep_cnt )
  FOR (i = 1 TO grp_summary->grp_cnt )
   SET params->eps[i ].br_eligible_provider_id = grp_summary->grps[i ].br_gpro_id
  ENDFOR
 ELSE
  SET epbool = determineepsfromprompt (paramtype ,params->epfilter ,params->orgfilter ,params )
 ENDIF
 DECLARE arr_size = i4 WITH protect ,noconstant (0 )
 DECLARE grpsumpos = i4 WITH protect ,noconstant (0 )
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
     SET params->grps[i ].measure_cnt = size (tmp_br_def_epgpro_meas->eps[pos ].measures ,5 )
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
  SET ep_sel = 0
  SET error_msg = "No EPs Specified"
 ELSEIF ((brdefeps = 0 ) )
  SET ep_sel = "F"
  SET error_msg = "ERROR: EPs or groups were specified, but none of them are configured in Bedrock."
 ENDIF
 SET paramtype = substring (1 ,1 ,reflect (parameter (7 ,0 ) ) )
 DECLARE measbool = i2 WITH protect ,noconstant (0 )
 IF ((params->brdefmeas != "-1" )
 AND (params->report_by != "CPC" ) )
  SET measbool = 1
 ELSE
  SET measbool = determinemeasuresfromprompt (paramtype ,params )
 ENDIF
 IF ((measbool = 0 ) )
  SET error_msg = "Failed to determine measures."
 ENDIF
 IF ((params->report_by = "GPRO" ) )
  CALL sync_prompt_grp_measures (params )
 ELSE
  CALL sync_prompt_ep_measures (params )
 ENDIF
 IF ((params->report_by = "GPRO" ) )
  SET params->ep_cnt = params->grp_cnt
  SET stat = alterlist (params->eps ,params->ep_cnt )
  FOR (i = 1 TO params->ep_cnt )
   SET params->eps[i ].br_eligible_provider_id = params->grps[i ].br_gpro_id
   SET params->eps[i ].logical_domain_id = params->grps[i ].logical_domain_id
   SET params->eps[i ].measure_cnt = params->grps[i ].measure_cnt
   SET params->eps[i ].measure_string = params->grps[i ].measure_string
   SET stat = alterlist (params->eps[i ].measures ,params->eps[i ].measure_cnt )
   FOR (j = 1 TO params->eps[i ].measure_cnt )
    SET params->eps[i ].measures[j ].mean = params->grps[i ].measures[j ].mean
   ENDFOR
  ENDFOR
 ENDIF
 DECLARE date_range_error = vc WITH protect ,noconstant ("" )
 SET date_range_error = get_rpt_dt_range_prompt ( $OPTINITIATIVE , $YEAR , $DT_QUARTER_YEAR ,
  cnvtdatetime ( $START_DT ) ,cnvtdatetime ( $END_DT ) )
 IF ((date_range_error != "" ) )
  SET period_sel = 0
  SET error_msg = date_range_error
 ENDIF
 IF ((ep_sel = 0 )
 AND (measure_sel = 0 ) )
  SET error_msg = "Errors: No EP(s) and Measure(s) Selected."
 ELSEIF ((((ep_sel = 0 ) ) OR ((measure_sel = 0 ) )) )
  IF ((ep_sel = 0 ) )
   SET error_msg = "Error: No EP(s) Selected."
  ELSEIF ((measure_sel = 0 ) )
   SET error_msg = "Error: No Measure(s) Selected."
  ENDIF
 ENDIF
 IF ((trim ( $CHKSUMMARYONLY ,3 ) = "MU_CSV*" )
 AND (cnvtupper (params->report_by ) != "INDV" ) )
  SET mu_attest_sel = 0
  SET error_msg = "Error: The MU Attestation CSV cannot be used for PQRS attestation."
 ENDIF
 IF ((period_sel = 1 )
 AND (ep_sel = 1 )
 AND (measure_sel = 1 )
 AND (mu_attest_sel = 1 ) )
  SET go_sel = 1
 ELSE
  SET go_sel = 0
 ENDIF
 IF ((go_sel = 1 ) )
  SET errcode = error (errmsg ,1 )
  SET errcode = error (errmsg ,0 )
  IF ((err_delete_ind = 0 ) )
   FOR (ep = 1 TO size (params->eps ,5 ) )
    INSERT FROM (lh_amb_report_param prm )
     SET prm.lh_amb_report_param_id = seq (reference_seq ,nextval ) ,
      prm.opt_initiative =  $OPTINITIATIVE ,
      prm.stage1a_dt_tm = cnvtdatetime ( $START_DT ) ,
      prm.stage1b_year = cnvtreal ( $YEAR ) ,
      prm.cust_start_dt_tm = cnvtdatetime ( $START_DT ) ,
      prm.cust_end_dt_tm = cnvtdatetime ( $END_DT ) ,
      prm.run_summary_report = - (1 ) ,
      prm.measure_name = params->eps[ep ].measure_string ,
      prm.organization_id =  $ORGFILTER ,
      prm.ep_name_filter = ep_filter ,
      prm.logical_domain_id = logical_domain_id ,
      prm.output_device = output_to ,
      prm.report_format =  $CHKSUMMARYONLY ,
      prm.cms_program = trim ( $QRDAMODE ,3 ) ,
      prm.br_eligible_provider_id = params->eps[ep ].br_eligible_provider_id ,
      prm.beg_extract_dt_tm = cnvtdatetime (datetimezone (cnvtdatetime (beg_extract_dt_tm ) ,
        curtimezoneapp ,1 ) ) ,
      prm.end_extract_dt_tm = cnvtdatetime (datetimezone (cnvtdatetime (end_extract_dt_tm ) ,
        curtimezoneapp ,1 ) ) ,
      prm.report_by =  $REPORTBY ,
      prm.active_ind = 1 ,
      prm.updt_task = "LH_AMB_REPORT_NQF2019_PARAM.PRG"
     PLAN (prm )
    ;end insert
   ENDFOR
  ENDIF
  SET errcode = error (errmsg ,0 )
  IF ((errcode != 0 ) )
   SET insert_error_message = "Error: In LH_AMB_REPORT_PARAM insert"
   SET detail_err_msg = errmsg
   SET err_insert_ind = 1
   CALL echo (insert_error_message )
   CALL echo (detail_err_msg )
   ROLLBACK
  ELSE
   COMMIT
   SET output_msg = "Success: LH_AMB_REPORT_PARAM table inserted."
   CALL echo (output_msg )
   SET err_insert_ind = 0
  ENDIF
  SET errcode = error (errmsg ,1 )
 ENDIF
 SET stat = initrec (params )
 SELECT INTO  $OUTDEV
  FROM (dummyt d1 )
  PLAN (d1 )
  HEAD REPORT
   SUBROUTINE  wrapdata (datastr ,col_len ,x_loc ,y_loc ,y_start ,uline )
    linesize = (size (trim (datastr ,3 ) ,1 ) + 1 ) ,begloc = 1 ,endloc = 1 ,high_val = (y_start - 6
    ) ,space_indx = 0 ,
    WHILE ((endloc < linesize ) )
     high_val = (high_val + 6 ) ,begloc = endloc ,endloc = minval ((begloc + col_len ) ,linesize ) ,
     space_indx = findstring (" " ,substring (begloc ,((endloc - begloc ) + 1 ) ,trim (datastr ,3 )
       ) ,1 ,1 ) ,
     IF ((endloc < linesize )
     AND (space_indx > 0 ) ) endloc = (begloc + space_indx ) ,colstr = substring (begloc ,((endloc -
       begloc ) - 1 ) ,trim (datastr ,3 ) )
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
  FOOT REPORT
   IF ((error_msg = "" )
   AND (err_insert_ind = 0 )
   AND (err_delete_ind = 0 ) )
    CALL print (calcpos (250 ,280 ) ) ,delete_output_msg ,
    CALL print (calcpos (250 ,300 ) ) ,output_msg
   ENDIF
   ,
   IF ((error_msg != "" ) )
    CALL print (calcpos (100 ,320 ) ) ,error_msg
   ENDIF
   ,
   IF ((err_insert_ind = 1 ) )
    CALL print (calcpos (120 ,50 ) ) ,insert_error_message ,maxyinc = 11 ,
    CALL wrapdata (detail_err_msg ,120 ,15 ,60 ,15 ,3 )
   ENDIF
   ,
   IF ((err_delete_ind = 1 ) )
    CALL print (calcpos (130 ,75 ) ) ,delete_error_message ,maxyinc = 11 ,
    CALL wrapdata (detail_err_msg ,130 ,15 ,60 ,15 ,3 )
   ENDIF
  WITH maxcol = 10000 ,maxrow = 500 ,landscape ,append ,dio = 08 ,noheading ,format = variable
 ;end select
END GO

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	
  Author:             Chad Cummings
  Date Written:       07/10/2020
  Solution:           
  Source file name:   cov_rpt_med_request_data.prg
  Object name:        cov_rpt_med_request_data
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   07/10/2020  Chad Cummings			Copied from Cerner script (rx_rpt_med_request_data)
001	  07/10/2020  Chad Cummings			Added FIN, updated prompts to use cov facility script (https://wiki.cerner.com/x/jaLriQ)
******************************************************************************/
DROP PROGRAM cov_rpt_med_request_data :dba GO
CREATE PROGRAM cov_rpt_med_request_data :dba
 PROMPT
  "Output to file/printer/MINE:" = "MINE" ,
  "Enter the START date range (mmddyyyy hhmm)  FROM :" = "SYSDATE" ,
  "(mmddyyyy hhmm)    TO :" = "SYSDATE" ,
  "Select facilities:" = 0
  WITH outdev ,startdate ,enddate ,facility
 IF ((reqinfo->updt_applctx <= 0 ) )
  CALL echo ("Report must be ran from Discern Explorer: Explorer Menu" )
  GO TO exit_script
 ENDIF
 DECLARE requestdatetime = dq8
 DECLARE actiondatetime = dq8
 DECLARE srequesttz = vc WITH protect ,noconstant ("" )
 DECLARE sprocesstz = vc WITH protect ,noconstant ("" )
 DECLARE requestdttmgmt = dq8
 DECLARE processdttmgmt = dq8
 DECLARE srequestdttm = vc WITH protect ,noconstant ("" )
 DECLARE sprocessdttm = vc WITH protect ,noconstant ("" )
 DECLARE delapsedtime = f8 WITH protect ,noconstant (0.0 )
 DECLARE scsvline = vc WITH protect ,noconstant ("" )
 DECLARE sstatus = vc WITH protect ,noconstant ("" )
 DECLARE ncnt = i4 WITH protect ,noconstant (0 )
 DECLARE spending = vc WITH protect ,constant ("PENDING" )
 DECLARE export_data_to_csv (0 ) = null
 DECLARE get_queue_time ((request_date_time = dq8 ) ,(action_date_time = dq8 ) ,(status = vc ) ) =
 f8
 FREE RECORD medreqdata
 RECORD medreqdata (
   1 qual [* ]
     2 patient_name = vc
     2 facility_cd = f8
     2 location_cd = f8
     2 order_desc = vc
     2 order_detail = vc
     2 requested_on = vc
     2 request_tz = vc
     2 request_gmt = dq8
     2 requested_by = vc
     2 priority_cd = f8
     2 request_reason_cd = f8
     2 request_comment = vc
     2 processed_on = vc
     2 process_tz = vc
     2 process_gmt = dq8
     2 processed_by = vc
     2 action_cd = f8
     2 status_cd = f8
     2 process_reason_cd = f8
     2 process_comment = vc
     2 elapsed_time = f8
     2 patient_fin = vc ;001
 )
 DECLARE utcdatetime ((ddatetime = vc ) ,(lindex = i4 ) ,(bshowtz = i2 ) ,(sformat = vc ) ) = vc
 DECLARE utcshorttz ((lindex = i4 ) ) = vc
 DECLARE sutcdatetime = vc WITH protect ,noconstant (" " )
 DECLARE dutcdatetime = f8 WITH protect ,noconstant (0.0 )
 DECLARE cutc = i2 WITH protect ,constant (curutc )
 SUBROUTINE  utcdatetime (sdatetime ,lindex ,bshowtz ,sformat )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewdatetime = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = vc WITH protect ,constant ("ZZZ" )
  IF ((lindex > 0 ) )
   SET lnewindex = lindex
  ENDIF
  SET snewdatetime = datetimezoneformat (sdatetime ,lnewindex ,sformat )
  IF ((cutc = 1 )
  AND (bshowtz = 1 ) )
   IF ((size (trim (snewdatetime ) ) > 0 ) )
    SET snewdatetime = concat (snewdatetime ," " ,datetimezoneformat (sdatetime ,lnewindex ,
      ctime_zone_format ) )
   ENDIF
  ENDIF
  SET snewdatetime = trim (snewdatetime )
  RETURN (snewdatetime )
 END ;Subroutine
 SUBROUTINE  utcshorttz (lindex )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewshorttz = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = i2 WITH protect ,constant (7 )
  IF ((cutc = 1 ) )
   IF ((lindex > 0 ) )
    SET lnewindex = lindex
   ENDIF
   SET snewshorttz = datetimezonebyindex (lnewindex ,offset ,daylight ,ctime_zone_format )
  ENDIF
  SET snewshorttz = trim (snewshorttz )
  RETURN (snewshorttz )
 END ;Subroutine
 SELECT INTO "nl:"
  FROM (rx_med_request rmr ),
   (orders o ),
   (person p ),
   (encounter e ),
   (encntr_alias ea), ;001
   (prsnl pr ),
   (prsnl prs ),
   (long_text l ),
   (long_text lt )
  PLAN (rmr
   WHERE (rmr.request_dt_tm BETWEEN cnvtdatetime ( $STARTDATE ) AND cnvtdatetime ( $ENDDATE ) ) )
   JOIN (o
   WHERE (o.order_id = rmr.order_id ) )
   JOIN (e
   WHERE (e.encntr_id = o.encntr_id )
   AND (e.loc_facility_cd =  $FACILITY ) )
   JOIN (p
   WHERE (p.person_id = o.person_id ) )
   JOIN (pr
   WHERE (pr.person_id = outerjoin (rmr.request_prsnl_id ) ) )
   JOIN (l
   WHERE (l.long_text_id = outerjoin (rmr.request_reason_long_text_id ) ) )
   JOIN (prs
   WHERE (prs.person_id = outerjoin (rmr.rx_action_prsnl_id ) ) )
   JOIN (lt
   WHERE (lt.long_text_id = outerjoin (rmr.rx_reason_long_text_id ) ) )
   /* start 001 */
   join ea
   	where ea.encntr_id = e.encntr_id
   	and   ea.active_ind = 1
   	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
   	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
   /* end 001 */
  ORDER BY rmr.request_dt_tm
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt + 1 ) ,
   IF ((curutc = 1 ) ) requestdttmgmt = cnvtdatetimeutc (cnvtdatetime (rmr.request_dt_tm ) ,1 ) ,
    processdttmgmt = cnvtdatetimeutc (cnvtdatetime (rmr.rx_action_dt_tm ) ,1 )
   ENDIF
   ,srequestdttm = utcdatetime (cnvtdatetime (rmr.request_dt_tm ) ,rmr.request_tz ,0 ,
    "@SHORTDATETIME" ) ,
   sprocessdttm = utcdatetime (cnvtdatetime (rmr.rx_action_dt_tm ) ,rmr.rx_action_tz ,0 ,
    "@SHORTDATETIME" ) ,
   srequesttz = utcshorttz (rmr.request_tz ) ,
   sprocesstz = utcshorttz (rmr.rx_action_tz ) ,
   requestdatetime = rmr.request_dt_tm ,
   actiondatetime = rmr.rx_action_dt_tm ,
   sstatus = uar_get_code_meaning (rmr.rx_status_cd ) ,
   delapsedtime = get_queue_time (requestdatetime ,actiondatetime ,sstatus ) ,
   IF ((mod (ncnt ,100 ) = 1 ) ) stat = alterlist (medreqdata->qual ,(ncnt + 99 ) )
   ENDIF
   ,medreqdata->qual[ncnt ].patient_name = p.name_full_formatted ,
   medreqdata->qual[ncnt ].facility_cd = e.loc_facility_cd ,
   medreqdata->qual[ncnt ].location_cd = e.loc_nurse_unit_cd ,
   medreqdata->qual[ncnt ].order_desc = o.ordered_as_mnemonic ,
   medreqdata->qual[ncnt ].order_detail = o.clinical_display_line ,
   medreqdata->qual[ncnt ].requested_on = srequestdttm ,
   medreqdata->qual[ncnt ].request_tz = srequesttz ,
   medreqdata->qual[ncnt ].request_gmt = requestdttmgmt ,
   medreqdata->qual[ncnt ].requested_by = pr.name_full_formatted ,
   medreqdata->qual[ncnt ].priority_cd = rmr.request_priority_cd ,
   medreqdata->qual[ncnt ].request_reason_cd = rmr.request_reason_cd ,
   medreqdata->qual[ncnt ].request_comment = l.long_text ,
   medreqdata->qual[ncnt ].processed_on = sprocessdttm ,
   medreqdata->qual[ncnt ].process_tz = sprocesstz ,
   medreqdata->qual[ncnt ].process_gmt = processdttmgmt ,
   medreqdata->qual[ncnt ].processed_by = prs.name_full_formatted ,
   medreqdata->qual[ncnt ].action_cd = rmr.rx_action_cd ,
   medreqdata->qual[ncnt ].status_cd = rmr.rx_status_cd ,
   medreqdata->qual[ncnt ].process_reason_cd = rmr.rx_reason_cd ,
   medreqdata->qual[ncnt ].process_comment = lt.long_text ,
   medreqdata->qual[ncnt ].elapsed_time = delapsedtime
   medreqdata->qual[ncnt ].patient_fin = trim(cnvtalias(ea.alias,ea.alias_pool_cd))	;001
  FOOT REPORT
   stat = alterlist (medreqdata->qual ,ncnt )
  WITH nocounter
 ;end select
 CALL export_data_to_csv (0 )
 SUBROUTINE  get_queue_time (request_date_time ,action_date_time ,status )
  SET delapsedtime = 0.0
  IF ((status = spending ) )
   SET action_date_time = cnvtdatetime (curdate ,curtime )
  ENDIF
  SET delapsedtime = floor (datetimediff (action_date_time ,request_date_time ,4 ) )
  RETURN (delapsedtime )
 END ;Subroutine
 SUBROUTINE  export_data_to_csv (dummy_m )
  IF ((size (medreqdata->qual ,5 ) = 0 ) )
   SELECT INTO  $OUTDEV
    "There is no data to output. Consider changing the prompt selections."
    FROM (dummyt )
    WITH nocounter ,format ,separator = " " ,maxcol = 5000 ,append ,formfeed = none
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    patient_name = substring (1 ,100 ,medreqdata->qual[d.seq ].patient_name ) ,
    patient_fin = substring(1,20,medreqdata->qual[d.seq ].patient_fin), ;001
    facility = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].facility_cd ) ) ,
    location = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].location_cd ) ) ,
    order_description = substring (1 ,100 ,medreqdata->qual[d.seq ].order_desc ) ,
    order_detail = substring (1 ,255 ,medreqdata->qual[d.seq ].order_detail ) ,
    requested_on = substring (1 ,20 ,medreqdata->qual[d.seq ].requested_on ) ,
    requested_timezone = substring (1 ,40 ,medreqdata->qual[d.seq ].request_tz ) ,
    requested_on_gmt = substring (1 ,20 ,format (medreqdata->qual[d.seq ].request_gmt ,
      "@SHORTDATETIME" ) ) ,
    requested_by = substring (1 ,100 ,medreqdata->qual[d.seq ].requested_by ) ,
    priority = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].priority_cd ) ) ,
    requested_reason = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].
      request_reason_cd ) ) ,
    requested_comment = check (substring (1 ,1000 ,medreqdata->qual[d.seq ].request_comment ) ,char (
      14 ) ) ,
    processed_on = substring (1 ,20 ,medreqdata->qual[d.seq ].processed_on ) ,
    processed_timezone = substring (1 ,40 ,medreqdata->qual[d.seq ].process_tz ) ,
    processed_on_gmt = substring (1 ,20 ,format (medreqdata->qual[d.seq ].process_gmt ,
      "@SHORTDATETIME" ) ) ,
    processed_by = substring (1 ,100 ,medreqdata->qual[d.seq ].processed_by ) ,
    action = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].action_cd ) ) ,
    status = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].status_cd ) ) ,
    processed_reason = substring (1 ,40 ,uar_get_code_display (medreqdata->qual[d.seq ].
      process_reason_cd ) ) ,
    processed_comment = check (substring (1 ,1000 ,medreqdata->qual[d.seq ].process_comment ) ,char (
      14 ) ) ,
    elapsed_time_min = medreqdata->qual[d.seq ].elapsed_time
    FROM (dummyt d WITH seq = size (medreqdata->qual ,5 ) )
    WITH nocounter ,format ,separator = " " ,maxcol = 5000 ,append ,formfeed = none
   ;end select
  ENDIF
 END ;Subroutine
 CALL echo ("Last Mod = 000" )
 CALL echo ("Mod Date = 23/06/2015" )
 CALL echo ("********** END COV_RPT_STD_MED_REQUEST **********" )
END GO

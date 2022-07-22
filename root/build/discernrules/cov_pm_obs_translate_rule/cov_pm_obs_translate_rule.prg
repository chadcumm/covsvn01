/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	COV_PM_OBS_TRANSLATE_RULE.prg
	Object name:		COV_PM_OBS_TRANSLATE_RULE
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	11/27/2021  Chad Cummings			Translated from PM_OBS_TRANSLATE_RULE
001 	11/27/2021  Chad Cummings			Changed Attending Provider Option
******************************************************************************/
DROP PROGRAM COV_PM_OBS_TRANSLATE_RULE :dba GO
CREATE PROGRAM COV_PM_OBS_TRANSLATE_RULE :dba
 CALL echo ("*****pm_obs_translate_rule.prg - 502402*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 560077*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 608439*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 645891*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 651255*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 652616*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 674999*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 676232*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 679539*****" )
 CALL echo ("*****pm_obs_translate_rule.prg - 716434*****" )
 IF ((validate (pm_helper_subs_include ,- (99 ) ) = - (99 ) ) )
  DECLARE pm_helper_subs_include = i4 WITH constant (1 )
  SUBROUTINE  (setreplystatusblock (soperationname =vc ,soperationstatus =vc ,stargetobjectname =vc ,
   stargetobjectvalue =vc ) =null )
   SET reply->status_data.subeventstatus[1 ].operationname = soperationname
   SET reply->status_data.subeventstatus[1 ].operationstatus = soperationstatus
   SET reply->status_data.subeventstatus[1 ].targetobjectname = stargetobjectname
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = stargetobjectvalue
  END ;Subroutine
 ENDIF
 DECLARE patient_event_discharge_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,4002773 ,
   "DISCHRG" ) ) ,protect
 DECLARE nondischargeeventexists (null ) = i2
 DECLARE checkdischargestate (null ) = i2
 DECLARE addpatientevent ((dpatienteventtypecd = f8 ) ) = null
 DECLARE removedeletedpatientevents (null ) = null
 SUBROUTINE  (obspatientevent (dcurrenteventtypecd =f8 ) =null )
  CASE (dcurrenteventtypecd )
   OF patient_event_outpatient_in_bed_cd :
    CALL uar_srvsetshort (hencntr ,"_outpatientInBedDateTime" ,1 )
    IF ((patient_event_request->patient_event[1 ].action = "ADD" ) )
     CALL uar_srvsetdate (hencntr ,"outpatientInBedDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ELSEIF ((patient_event_request->patient_event[1 ].action = "UPT" ) )
     CALL uar_srvsetdate (hencntr ,"outpatientInBedDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ENDIF
   OF patient_event_observation_start_cd :
    CALL uar_srvsetshort (hencntr ,"_observationStartDateTime" ,1 )
    IF ((patient_event_request->patient_event[1 ].action = "ADD" ) )
     CALL uar_srvsetdate (hencntr ,"observationStartDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ELSEIF ((patient_event_request->patient_event[1 ].action = "UPT" ) )
     CALL uar_srvsetdate (hencntr ,"observationStartDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ENDIF
   OF patient_event_inpatient_start_cd :
    CALL uar_srvsetshort (hencntr ,"_inpatientAdmitDateTime" ,1 )
    IF ((patient_event_request->patient_event[1 ].action = "ADD" ) )
     CALL uar_srvsetdate (hencntr ,"inpatientAdmitDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ELSEIF ((patient_event_request->patient_event[1 ].action = "UPT" ) )
     CALL uar_srvsetdate (hencntr ,"inpatientAdmitDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ENDIF
   OF patient_event_clinical_discharge_cd :
    CALL uar_srvsetshort (hencntr ,"_clinicalDischargeDateTime" ,1 )
    IF ((((patient_event_request->patient_event[1 ].action = "ADD" ) ) OR ((patient_event_request->
    patient_event[1 ].action = "UPT" ) )) )
     CALL uar_srvsetdate (hencntr ,"clinicalDischargeDateTime" ,cnvtdatetime (patient_event_request->
       patient_event[1 ].event_dt_tm ) )
    ENDIF
  ENDCASE
  CALL removedeletedpatientevents (null )
 END ;Subroutine
 SUBROUTINE  removedeletedpatientevents (null )
  IF (binactiveopinabed )
   CALL uar_srvsetshort (hencntr ,"_outpatientInBedDateTime" ,1 )
  ENDIF
  IF (binactiveobs )
   CALL uar_srvsetshort (hencntr ,"_observationStartDateTime" ,1 )
  ENDIF
  IF (binactiveinp )
   CALL uar_srvsetshort (hencntr ,"_inpatientAdmitDateTime" ,1 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (obspostpatientevent (dcurrenteventtypecd =f8 ) =null )
  DECLARE bprocessevent = i2 WITH noconstant (true ) ,protect
  DECLARE dcurrentprofitqueuecd = f8 WITH noconstant (0.0 ) ,protect
  DECLARE ldeleteeventsbit = i4 WITH noconstant (0 ) ,protect
  CASE (patient_event_request->patient_event[1 ].action )
   OF "ADD" :
    SET dcurrentprofitqueuecd = pft_queue_observation_review_required
    CASE (dcurrenteventtypecd )
     OF patient_event_outpatient_in_bed_cd :
     OF patient_event_observation_start_cd :
     OF patient_event_inpatient_start_cd :
      SET bnondischargeeventexists = true
      SET bprocessevent = checkdischargestate (null )
     OF patient_event_clinical_discharge_cd :
      SET bcheckdischargestate = true
      SET bprocessevent = nondischargeeventexists (null )
    ENDCASE
    ,
    IF ((bprocessevent = true ) )
     CASE (dcurrenteventtypecd )
      OF patient_event_outpatient_in_bed_cd :
       SET ldeleteeventsbit = 7
      OF patient_event_observation_start_cd :
       SET ldeleteeventsbit = 6
      OF patient_event_inpatient_start_cd :
       SET ldeleteeventsbit = 4
      OF patient_event_clinical_discharge_cd :
       SET ldeleteeventsbit = 8
     ENDCASE
     IF (btest (ldeleteeventsbit ,0 ) )
      CALL deletepatienteventbyeventcd (patient_event_outpatient_in_bed_cd )
      CALL checkevents (patient_event_outpatient_in_bed_cd )
     ENDIF
     IF (btest (ldeleteeventsbit ,1 ) )
      CALL deletepatienteventbyeventcd (patient_event_observation_start_cd )
      CALL checkevents (patient_event_observation_start_cd )
     ENDIF
     IF (btest (ldeleteeventsbit ,2 ) )
      CALL deletepatienteventbyeventcd (patient_event_inpatient_start_cd )
      CALL checkevents (patient_event_inpatient_start_cd )
     ENDIF
     IF (btest (ldeleteeventsbit ,3 ) )
      CALL deletepatienteventbyeventcd (patient_event_clinical_discharge_cd )
      CALL checkevents (patient_event_clinical_discharge_cd )
     ENDIF
    ENDIF
   OF "UPT" :
    SET dcurrentprofitqueuecd = pft_queue_observation_review_required
   OF "DEL" :
    SET dcurrentprofitqueuecd = pft_queue_observation_review_canceled
    CALL deletepatienteventbyeventcd (dcurrenteventtypecd )
  ENDCASE
  IF ((bprocessevent = true ) )
   IF ((dcurrentprofitqueuecd > 0.0 ) )
    IF ((dcurrenteventtypecd = patient_event_observation_start_cd ) )
     IF ((publishprofitworkitemevent (patient_event_request->encntr_id ,dcurrentprofitqueuecd ) =
     false ) )
      SET log_message = concat ("PFT ERROR: Failed publishing work item." )
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  CALL obspatientevent (dcurrenteventtypecd )
 END ;Subroutine
 SUBROUTINE  nondischargeeventexists (null )
  IF ((bnondischargeeventexistschecked = false ) )
   SET bnondischargeeventexistschecked = true
   IF ((bnondischargeeventexists = false ) )
    SELECT INTO "nl:"
     FROM (patient_event pe )
     WHERE (pe.encntr_id = patient_event_request->encntr_id )
     AND (pe.person_id = patient_event_request->person_id )
     AND (pe.event_type_cd IN (patient_event_outpatient_in_bed_cd ,
     patient_event_observation_start_cd ,
     patient_event_inpatient_start_cd ) )
     AND (pe.active_ind = 1 )
     WITH nocounter
    ;end select
    IF ((curqual <= 0 ) )
     IF ((((patient_event_request->patient_event[1 ].event_type_cd =
     patient_event_outpatient_in_bed_cd ) ) OR ((((patient_event_request->patient_event[1 ].
     event_type_cd = patient_event_observation_start_cd ) ) OR ((patient_event_request->
     patient_event[1 ].event_type_cd = patient_event_inpatient_start_cd ) )) )) )
      SET bnondischargeeventexists = true
     ENDIF
    ELSE
     SET bnondischargeeventexists = true
    ENDIF
   ENDIF
  ENDIF
  RETURN (bnondischargeeventexists )
 END ;Subroutine
 SUBROUTINE  checkdischargestate (null )
  DECLARE ddischargedttm = f8 WITH noconstant (0.0 ) ,protect
  IF ((bcheckdischargestatechecked = false ) )
   SET bcheckdischargestatechecked = true
   IF ((bcheckdischargestate = false ) )
    SELECT INTO "nl:"
     FROM (encounter e )
     WHERE (e.encntr_id = patient_event_request->encntr_id )
     DETAIL
      ddischargedttm = cnvtdatetime (e.disch_dt_tm )
     WITH nocounter
    ;end select
    IF ((ddischargedttm > 0.0 ) )
     SELECT INTO "nl:"
      FROM (patient_event pe )
      WHERE (pe.encntr_id = patient_event_request->encntr_id )
      AND (pe.person_id = patient_event_request->person_id )
      AND (pe.event_type_cd IN (patient_event_clinical_discharge_cd ,
      patient_event_discharge_cd ) )
      AND (pe.active_ind = 1 )
      WITH nocounter
     ;end select
     IF ((curqual <= 0 ) )
      IF ((patient_event_request->patient_event[1 ].event_type_cd =
      patient_event_clinical_discharge_cd ) )
       SET bcheckdischargestate = true
      ENDIF
     ELSE
      SET bcheckdischargestate = true
     ENDIF
    ELSE
     SET bcheckdischargestate = true
    ENDIF
   ENDIF
  ENDIF
  RETURN (bcheckdischargestate )
 END ;Subroutine
 SUBROUTINE  (deletepatienteventbyeventcd (dpatienteventtypecd =f8 ) =null )
  DECLARE dpatienteventid = f8 WITH protect ,noconstant (0.0 )
  DECLARE s_event_type = vc WITH constant (uar_get_code_display (dpatienteventtypecd ) )
  IF ((dpatienteventtypecd <= 0.0 ) )
   SET log_message = concat ("Error deleting patient event: " ,s_event_type )
   CALL setreplystatusblock (build2 (s_event_type ," Events Delete" ) ,"F" ,"" ,"" )
   GO TO 9999_exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM (patient_event pe )
   WHERE (pe.person_id = patient_event_request->person_id )
   AND (pe.encntr_id = patient_event_request->encntr_id )
   AND (pe.event_type_cd = dpatienteventtypecd )
   AND (pe.active_ind = 1 )
   DETAIL
    dpatienteventid = pe.patient_event_id
   WITH nocounter
  ;end select
  IF ((dpatienteventid > 0 ) )
   CALL deletepatienteventbyeventid (dpatienteventid ,s_event_type )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (deletepatienteventbyeventid (dpatienteventid =f8 ,eventtypestring =vc ) =null )
  IF ((hevents = 0 ) )
   SET hevents = uar_srvgetstruct (hrequest ,"events" )
  ENDIF
  SET hremoveeventlist = uar_srvadditem (hevents ,"removeEventList" )
  CALL uar_srvsetdouble (hremoveeventlist ,"id" ,dpatienteventid )
 END ;Subroutine
 SUBROUTINE  (publishprofitworkitemevent (dencntrid =f8 ,deventcd =f8 ) =i2 )
  DECLARE pft_work_item_event = f8 WITH constant (uar_get_code_by ("MEANING" ,23369 ,"WFEVENT" ) ) ,
  protect
  IF ((dencntrid > 0.0 )
  AND (deventcd > 0.0 )
  AND (pft_work_item_event > 0.0 ) )
   DECLARE happ = i4 WITH protect ,noconstant (0 )
   DECLARE htask = i4 WITH protect ,noconstant (0 )
   DECLARE hreq = i4 WITH protect ,noconstant (0 )
   DECLARE hstep = i4 WITH protect ,noconstant (0 )
   DECLARE hevent = i4 WITH protect ,noconstant (0 )
   DECLARE crmstatus = i4 WITH protect ,noconstant (0 )
   DECLARE happid = i4 WITH protect ,constant (100000 )
   DECLARE htaskid = i4 WITH protect ,constant (100000 )
   DECLARE hreqid = i4 WITH protect ,constant (4099263 )
   SET crmstatus = uar_crmbeginapp (happid ,happ )
   IF ((crmstatus = 0 ) )
    SET crmstatus = uar_crmbegintask (happ ,htaskid ,htask )
    IF ((crmstatus = 0 ) )
     SET crmstatus = uar_crmbeginreq (htask ,"" ,hreqid ,hstep )
     IF ((crmstatus = 0 ) )
      SET hreq = uar_crmgetrequest (hstep )
      IF ((hreq > 0 ) )
       SET hevent = uar_srvadditem (hreq ,"eventList" )
       SET stat = uar_srvsetstring (hevent ,"entityTypeKey" ,nullterm ("ENCOUNTER" ) )
       SET stat = uar_srvsetdouble (hevent ,"entityId" ,dencntrid )
       SET stat = uar_srvsetdouble (hevent ,"eventCd" ,deventcd )
       SET stat = uar_srvsetdouble (hevent ,"eventTypeCd" ,pft_work_item_event )
       SET crmstatus = uar_crmperform (hstep )
      ENDIF
      CALL uar_crmendreq (hstep )
     ENDIF
    ENDIF
   ENDIF
   CALL uar_crmendtask (htask )
   CALL uar_crmendapp (happ )
  ELSE
   RETURN (false )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (checkevents (dpatienteventcd =f8 ) =null )
  SELECT INTO "nl:"
   FROM (patient_event pe )
   WHERE (pe.encntr_id = patient_event_request->encntr_id )
   AND (pe.person_id = patient_event_request->person_id )
   AND (pe.event_type_cd IN (patient_event_outpatient_in_bed_cd ,
   patient_event_observation_start_cd ,
   patient_event_inpatient_start_cd ) )
   AND (pe.active_ind = 1 )
   DETAIL
    IF ((dpatienteventcd = patient_event_outpatient_in_bed_cd ) )
     IF ((pe.event_type_cd = patient_event_observation_start_cd )
     AND (pe.event_dt_tm <= patient_event_request->patient_event[1 ].event_dt_tm ) ) binactiveobs =
      true
     ENDIF
     ,
     IF ((pe.event_type_cd = patient_event_inpatient_start_cd )
     AND (pe.event_dt_tm <= patient_event_request->patient_event[1 ].event_dt_tm ) ) binactiveinp =
      true
     ENDIF
    ENDIF
    ,
    IF ((dpatienteventcd = patient_event_observation_start_cd ) )
     IF ((pe.event_type_cd = patient_event_outpatient_in_bed_cd )
     AND (pe.event_dt_tm >= patient_event_request->patient_event[1 ].event_dt_tm ) )
      binactiveopinabed = true
     ENDIF
     ,
     IF ((pe.event_type_cd = patient_event_inpatient_start_cd ) ) binactiveinp = true
     ENDIF
    ENDIF
    ,
    IF ((dpatienteventcd = patient_event_inpatient_start_cd ) )
     IF ((pe.event_type_cd = patient_event_outpatient_in_bed_cd )
     AND (pe.event_dt_tm >= patient_event_request->patient_event[1 ].event_dt_tm ) )
      binactiveopinabed = true
     ENDIF
     ,
     IF ((pe.event_type_cd = patient_event_observation_start_cd )
     AND (pe.event_dt_tm >= patient_event_request->patient_event[1 ].event_dt_tm ) ) binactiveobs =
      true
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (binactiveopinabed )
   CALL deletepatienteventbyeventcd (patient_event_outpatient_in_bed_cd )
  ENDIF
  IF (binactiveobs )
   CALL deletepatienteventbyeventcd (patient_event_observation_start_cd )
  ENDIF
  IF (binactiveinp )
   CALL deletepatienteventbyeventcd (patient_event_inpatient_start_cd )
  ENDIF
 END ;Subroutine
 DECLARE updateencounterinformation (null ) = null
 DECLARE populateorderinfo (null ) = null
 DECLARE obspostprocess (null ) = null
 DECLARE getobslos (null ) = null
 DECLARE getorderinfo (null ) = null
 DECLARE getcurrentphysicianandconditioncode (null ) = null
 DECLARE getaccomcode (null ) = null
 DECLARE getpersonnelrelationships (null ) = null
 DECLARE setpersonnelrelationships (null ) = null
 SUBROUTINE  getobslos (null )
  DECLARE observation_los_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,20790 ,"OBSLOS" ) ) ,
  protect
  IF ((observation_los_cd > 0.0 ) )
   SELECT INTO "nl:"
    FROM (code_value_extension cve )
    WHERE (cve.code_set = 20790 )
    AND (cve.code_value = observation_los_cd )
    AND (cve.field_name = "OPTION" )
    DETAIL
     IF ((trim (cve.field_value ,3 ) != "" ) ) order_info->los_codeset = cnvtreal (trim (cve
        .field_value ,3 ) )
     ENDIF
    WITH nocounter
   ;end select
   IF (bdebugme )
    CALL echo (build2 ("Level of Service code set:" ,order_info->los_codeset ) )
   ENDIF
  ELSE
   IF (bdebugme )
    CALL echo ("OBSERVATION_LOS_CD <= 0.0" )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  getorderinfo (null )
  CALL getobslos (null )
  SELECT INTO "nl:"
   FROM (order_action oa )
   WHERE (oa.order_id = patient_event_request->order_id )
   ORDER BY oa.action_sequence DESC
   HEAD oa.action_sequence
    order_info->order_physician_id = oa.order_provider_id
   WITH nocounter
  ;end select
  call echo(build2("attend_meaning_id=",attend_meaning_id)) ;001
  call echo(build2("admit_meaning_id=",admit_meaning_id)) ;001
  SELECT INTO "nl:"
   FROM (order_detail od ),
    (order_entry_fields oef )
   PLAN (od
    WHERE (od.order_id = patient_event_request->order_id ) )
    JOIN (oef
    WHERE (oef.oe_field_id = od.oe_field_id ) )
   DETAIL
   	call echo(build2("od.oe_field_meaning=",od.oe_field_meaning)) ;001
   	call echo(build2("od.oe_field_meaning_id=",od.oe_field_meaning_id)) ;001
   	call echo(build2("od.oe_field_value=",od.oe_field_value)) ;001
    IF ((od.oe_field_meaning = "CONDITIONCODE44" ) )
     IF ((od.oe_field_value = 1.0 ) ) order_info->code44_ind = true
     ENDIF
    ENDIF
    ,
    IF ((oef.codeset = order_info->los_codeset )
    AND (order_info->los_codeset > 0.0 ) ) order_info->los_cd = od.oe_field_value
    ELSEIF ((oef.codeset = medservice_codeset ) ) order_info->med_service_cd = od.oe_field_value
    ENDIF
    ,
    IF ((oef.oe_field_meaning_id = attend_meaning_id ) )
    	order_info->attend_physician_id = od.oe_field_value
    ELSEIF ((oef.oe_field_meaning_id = admit_meaning_id ) ) order_info->admit_physician_id = od
     .oe_field_value
    ENDIF
   WITH nocounter
  ;end select
  CALL getcurrentphysicianandconditioncode (null )
 END ;Subroutine
 SUBROUTINE  getcurrentphysicianandconditioncode (null )
  IF ((order_info->admit_physician_id = 0.0 ) )
   SET encntr_info->n_admit_p_id = order_info->order_physician_id
  ELSE
   SET encntr_info->n_admit_p_id = order_info->admit_physician_id
  ENDIF
  if ((order_info->attend_physician_id = 0.0 ) )
   SET battendphysblankonorder = true
   IF ((order_info->admit_physician_id = 0.0 ) )
    SET encntr_info->n_attend_p_id = order_info->order_physician_id
   ELSE
    SET encntr_info->n_attend_p_id = order_info->admit_physician_id
   ENDIF
  ELSE
   SET encntr_info->n_attend_p_id = order_info->attend_physician_id
   call echo("SET encntr_info->n_attend_p_id = order_info->attend_physician_id") ;001
  ENDIF
  SELECT INTO "nl:"
   FROM (encntr_condition_code ecc )
   WHERE (ecc.encntr_id = patient_event_request->encntr_id )
   AND (ecc.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
   AND (ecc.end_effective_dt_tm > cnvtdatetime (sysdate ) )
   AND (ecc.active_ind = 1 )
   DETAIL
    IF ((ecc.condition_cd = condition_code_44 ) ) encntr_info->code44_id = ecc.condition_code_id
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  getaccomcode (null )
  DECLARE accom_codeset = i4 WITH constant (10 ) ,protect
  DECLARE accomodation_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,30620 ,"CS10" ) ) ,
  protect
  DECLARE laccomcnt = i4 WITH noconstant (0 ) ,protect
  DECLARE bpprusageind = i2 WITH noconstant (false ) ,protect
  DECLARE dtempaccomcd = f8 WITH noconstant (0.0 ) ,protect
  SELECT INTO "nl:"
   FROM (filter_entity_reltn fer )
   WHERE (fer.filter_type_cd = accomodation_type_cd )
   AND (fer.filter_entity1_id = encntr_info->o_facility_cd )
   AND (fer.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
   AND (fer.end_effective_dt_tm > cnvtdatetime (sysdate ) )
   DETAIL
    bpprusageind = true
   WITH nocounter ,maxrec = 1
  ;end select
  IF ((bpprusageind = true ) )
   CALL echo ("ppr filter on " )
   SELECT INTO "nl:"
    FROM (code_value cv ),
     (code_value_group cvg ),
     (filter_entity_reltn fer )
    PLAN (cv
     WHERE (cv.code_set = order_info->los_codeset )
     AND (cv.code_value = order_info->los_cd ) )
     JOIN (cvg
     WHERE (cv.code_value = cvg.parent_code_value )
     AND (cvg.code_set = accom_codeset ) )
     JOIN (fer
     WHERE (fer.filter_type_cd = accomodation_type_cd )
     AND (fer.filter_entity1_id = encntr_info->o_facility_cd )
     AND (fer.parent_entity_id = cvg.child_code_value )
     AND (fer.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (fer.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
    HEAD REPORT
     laccomcnt = 0
    DETAIL
     laccomcnt +=1 ,
     dtempaccomcd = cvg.child_code_value
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (code_value cv ),
     (code_value_group cvg )
    PLAN (cv
     WHERE (cv.code_set = order_info->los_codeset )
     AND (cv.code_value = order_info->los_cd ) )
     JOIN (cvg
     WHERE (cv.code_value = cvg.parent_code_value )
     AND (cvg.code_set = accom_codeset ) )
    HEAD REPORT
     laccomcnt = 0
    DETAIL
     laccomcnt +=1 ,
     dtempaccomcd = cvg.child_code_value
    WITH nocounter
   ;end select
  ENDIF
  IF ((laccomcnt = 1 ) )
   SET order_info->accom_cd = dtempaccomcd
   IF (bdebugme )
    CALL echo ("*** GetAccomCode Values ***" )
    CALL echo (build2 ("bPPRUsageInd: " ,bpprusageind ) )
    CALL echo (build2 ("dTempAccomCd: " ,dtempaccomcd ) )
    CALL echo (build2 ("lAccomCnt: " ,laccomcnt ) )
   ENDIF
  ELSE
   IF (bdebugme )
    CALL echo ("*** Level of Service failed. More than one or nothing built up ***" )
    CALL echo (build2 ("bPPRUsageInd: " ,bpprusageind ) )
    CALL echo (build2 ("dTempAccomCd: " ,dtempaccomcd ) )
    CALL echo (build2 ("lAccomCnt: " ,laccomcnt ) )
    SET log_message = "Level of Service failed. More than one or nothing built up"
   ENDIF
  ENDIF
  IF ((order_info->accom_cd > 0.0 ) )
   SET encntr_info->n_accom_cd = order_info->accom_cd
  ENDIF
  IF ((order_info->med_service_cd > 0.0 ) )
   SET encntr_info->n_med_service_cd = order_info->med_service_cd
  ENDIF
 END ;Subroutine
 SUBROUTINE  getpersonnelrelationships (null )
  SELECT INTO "nl:"
   FROM (encntr_prsnl_reltn epr )
   WHERE (epr.encntr_id = patient_event_request->encntr_id )
   AND (epr.active_ind = 1 )
   AND (epr.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
   AND (epr.end_effective_dt_tm > cnvtdatetime (sysdate ) )
   ORDER BY epr.encntr_prsnl_r_cd ,
    epr.beg_effective_dt_tm
   DETAIL
    IF ((epr.encntr_prsnl_r_cd = attenddoc_cd ) ) encntr_info->o_attend_p_id = epr.prsnl_person_id ,
     encntr_info->o_attend_r_id = epr.encntr_prsnl_reltn_id
    ENDIF
    ,
    IF ((epr.encntr_prsnl_r_cd = admitdoc_cd ) ) encntr_info->o_admit_p_id = epr.prsnl_person_id ,
     encntr_info->o_admit_r_id = epr.encntr_prsnl_reltn_id
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  setpersonnelrelationships (null )
 
 call echo(build2("setpersonnelrelationships")) ;001
  call echo(build2("battendphysblankonorder=",battendphysblankonorder)) ;001
  IF ((transfer_order_mode = cnvtupper (trim (patient_event_request->order_mode ,3 ) ) ) )
   IF ((encntr_info->n_attend_p_id > 0.0 ) )
    IF ((encntr_info->o_attend_r_id > 0 ) )
     IF ((encntr_info->n_attend_p_id != encntr_info->o_attend_p_id )
     AND (battendphysblankonorder = false ) )
      IF ((hphysicians = 0 ) )
       SET hphysicians = uar_srvgetstruct (hrequest ,"personnelRelationships" )
      ENDIF
      call echo("inside setup") ;001
      SET hmodifyepr = uar_srvadditem (hphysicians ,"modifyPersonnelRelationshipList" )
      SET stat = uar_srvsetdouble (hmodifyepr ,"id" ,encntr_info->o_attend_r_id )
      SET stat = uar_srvsetshort (hmodifyepr ,"endAtTimeOfTransactionInd" ,1 )
      SET haddepr = uar_srvadditem (hphysicians ,"addPersonnelRelationshipList" )
      SET stat = uar_srvsetdouble (haddepr ,"personnelId" ,encntr_info->n_attend_p_id )
      SET stat = uar_srvsetdouble (haddepr ,"typeCd" ,attenddoc_cd )
      SET stat = uar_srvsetlong (haddepr ,"typePriority" ,1 )
      SET stat = uar_srvsetshort (haddepr ,"beginAtTimeOfTransactionInd" ,1 )
      SET bupdateind = true
     ELSE
      IF (bdebugme )
       CALL echo ("*** No attending doc to update. 1 ***" ) ;001
      ENDIF
     ENDIF
    ELSE
     IF ((hphysicians = 0 ) )
      SET hphysicians = uar_srvgetstruct (hrequest ,"personnelRelationships" )
     ENDIF
     SET haddepr = uar_srvadditem (hphysicians ,"addPersonnelRelationshipList" )
     SET stat = uar_srvsetdouble (haddepr ,"personnelId" ,encntr_info->n_attend_p_id )
     SET stat = uar_srvsetdouble (haddepr ,"typeCd" ,attenddoc_cd )
     SET stat = uar_srvsetlong (haddepr ,"typePriority" ,1 )
     SET stat = uar_srvsetshort (haddepr ,"beginAtTimeOfTransactionInd" ,1 )
     SET bupdateind = true
    ENDIF
   ELSE
    IF (bdebugme )
     CALL echo ("*** No attending doc to update. 2 ***" ) ;001
    ENDIF
   ENDIF
  ELSE
   IF ((encntr_info->n_admit_p_id > 0 ) )
    IF ((encntr_info->o_admit_r_id > 0 ) )
     IF ((encntr_info->n_admit_p_id != encntr_info->o_admit_p_id ) )
      IF ((hphysicians = 0 ) )
       SET hphysicians = uar_srvgetstruct (hrequest ,"personnelRelationships" )
      ENDIF
      SET hmodifyepr = uar_srvadditem (hphysicians ,"modifyPersonnelRelationshipList" )
      SET stat = uar_srvsetdouble (hmodifyepr ,"id" ,encntr_info->o_admit_r_id )
      SET stat = uar_srvsetshort (hmodifyepr ,"endAtTimeOfTransactionInd" ,1 )
      SET haddepr = uar_srvadditem (hphysicians ,"addPersonnelRelationshipList" )
      SET stat = uar_srvsetdouble (haddepr ,"personnelId" ,encntr_info->n_admit_p_id )
      SET stat = uar_srvsetdouble (haddepr ,"typeCd" ,admitdoc_cd )
      SET stat = uar_srvsetlong (haddepr ,"typePriority" ,1 )
      SET stat = uar_srvsetshort (haddepr ,"beginAtTimeOfTransactionInd" ,1 )
      SET bupdateind = true
     ELSE
      IF (bdebugme )
       CALL echo ("*** No admitting doc to update. ***" )
      ENDIF
     ENDIF
    ELSE
     IF ((hphysicians = 0 ) )
      SET hphysicians = uar_srvgetstruct (hrequest ,"personnelRelationships" )
     ENDIF
     SET haddepr = uar_srvadditem (hphysicians ,"addPersonnelRelationshipList" )
     SET stat = uar_srvsetdouble (haddepr ,"personnelId" ,encntr_info->n_admit_p_id )
     SET stat = uar_srvsetdouble (haddepr ,"typeCd" ,admitdoc_cd )
     SET stat = uar_srvsetlong (haddepr ,"typePriority" ,1 )
     SET stat = uar_srvsetshort (haddepr ,"beginAtTimeOfTransactionInd" ,1 )
     SET bupdateind = true
    ENDIF
   ELSE
    IF (bdebugme )
     CALL echo ("*** No admitting doc to update. ***" )
    ENDIF
   ENDIF
   IF ((encntr_info->n_attend_p_id > 0.0 ) )
    IF ((encntr_info->o_attend_r_id > 0 ) )
     IF ((encntr_info->n_attend_p_id != encntr_info->o_attend_p_id ) )
      IF ((hphysicians = 0 ) )
       SET hphysicians = uar_srvgetstruct (hrequest ,"personnelRelationships" )
      ENDIF
      SET hmodifyepr = uar_srvadditem (hphysicians ,"modifyPersonnelRelationshipList" )
      SET stat = uar_srvsetdouble (hmodifyepr ,"id" ,encntr_info->o_attend_r_id )
      SET stat = uar_srvsetshort (hmodifyepr ,"endAtTimeOfTransactionInd" ,1 )
      SET haddepr = uar_srvadditem (hphysicians ,"addPersonnelRelationshipList" )
      SET stat = uar_srvsetdouble (haddepr ,"personnelId" ,encntr_info->n_attend_p_id )
      SET stat = uar_srvsetdouble (haddepr ,"typeCd" ,attenddoc_cd )
      SET stat = uar_srvsetlong (haddepr ,"typePriority" ,1 )
      SET stat = uar_srvsetshort (haddepr ,"beginAtTimeOfTransactionInd" ,1 )
      SET bupdateind = true
     ELSE
      IF (bdebugme )
       CALL echo ("*** No attending doc to update. 3 ***" ) ;001
      ENDIF
     ENDIF
    ELSE
     IF ((hphysicians = 0 ) )
      SET hphysicians = uar_srvgetstruct (hrequest ,"personnelRelationships" )
     ENDIF
     SET haddepr = uar_srvadditem (hphysicians ,"addPersonnelRelationshipList" )
     SET stat = uar_srvsetdouble (haddepr ,"personnelId" ,encntr_info->n_attend_p_id )
     SET stat = uar_srvsetdouble (haddepr ,"typeCd" ,attenddoc_cd )
     SET stat = uar_srvsetlong (haddepr ,"typePriority" ,1 )
     SET stat = uar_srvsetshort (haddepr ,"beginAtTimeOfTransactionInd" ,1 )
     SET bupdateind = true
    ENDIF
   ELSE
    IF (bdebugme )
     CALL echo ("*** No attending doc to update. 4 ***" ) ;001
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (populatelocationid (dpatienteventtypecd =f8 ) =i2 )
  DECLARE emergency_type_class = f8 WITH constant (uar_get_code_by ("MEANING" ,69 ,"EMERGENCY" ) ) ,
  protect
  DECLARE edhold_attrib_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,17649 ,"EDHOLD" ) ) ,
  protect
  DECLARE facility_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"FACILITY" ) ) ,
  protect
  DECLARE building_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"BUILDING" ) ) ,
  protect
  DECLARE nurseunit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"NURSEUNIT" ) ) ,
  protect
  DECLARE room_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"ROOM" ) ) ,protect
  DECLARE bed_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,222 ,"BED" ) ) ,protect
  DECLARE facility_level = i4 WITH constant (5 ) ,protect
  DECLARE building_level = i4 WITH constant (4 ) ,protect
  DECLARE nurse_unit_level = i4 WITH constant (3 ) ,protect
  DECLARE room_level = i4 WITH constant (2 ) ,protect
  DECLARE bed_level = i4 WITH constant (1 ) ,protect
  DECLARE blocattribusageind = i2 WITH noconstant (false ) ,protect
  DECLARE dcurlocationlevel = i4 WITH noconstant (0 ) ,protect
  IF ((((dpatienteventtypecd = patient_event_observation_start_cd ) ) OR ((dpatienteventtypecd =
  patient_event_inpatient_start_cd ) ))
  AND (encntr_info->o_encntr_type_class_cd = emergency_type_class )
  AND (encntr_info->o_location_cd > 0.0 )
  AND (edhold_attrib_type_cd > 0.0 ) )
   SELECT INTO "nl:"
    FROM (pm_loc_attrib pla )
    WHERE (pla.attrib_type_cd = edhold_attrib_type_cd )
    AND (pla.active_ind = 1 )
    AND (pla.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (pla.end_effective_dt_tm > cnvtdatetime (sysdate ) )
    DETAIL
     blocattribusageind = true
    WITH nocounter ,maxrec = 1
   ;end select
   IF ((blocattribusageind = true ) )
    SELECT INTO "nl:"
     FROM (location l )
     WHERE (l.location_cd = encntr_info->o_location_cd )
     AND (l.active_ind = 1 )
     AND (l.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (l.end_effective_dt_tm > cnvtdatetime (sysdate ) )
     DETAIL
      CASE (l.location_type_cd )
       OF facility_type_cd :
        dcurlocationlevel = facility_level
       OF building_type_cd :
        dcurlocationlevel = building_level
       OF nurseunit_type_cd :
        dcurlocationlevel = nurse_unit_level
       OF room_type_cd :
        dcurlocationlevel = room_level
       OF bed_type_cd :
        dcurlocationlevel = bed_level
      ENDCASE
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (pm_loc_attrib pla )
     WHERE (pla.attrib_type_cd = edhold_attrib_type_cd )
     AND (pla.active_ind = 1 )
     AND (pla.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (pla.end_effective_dt_tm > cnvtdatetime (sysdate ) )
     DETAIL
      CASE (pla.location_cd )
       OF encntr_info->o_facility_cd :
        IF ((facility_level >= dcurlocationlevel ) ) encntr_info->n_facility_cd = pla.value_cd
        ENDIF
       OF encntr_info->o_building_cd :
        IF ((building_level >= dcurlocationlevel ) ) encntr_info->n_building_cd = pla.value_cd
        ENDIF
       OF encntr_info->o_nurse_unit_cd :
        IF ((nurse_unit_level >= dcurlocationlevel ) ) encntr_info->n_nurse_unit_cd = pla.value_cd
        ENDIF
       OF encntr_info->o_room_cd :
        IF ((room_level >= dcurlocationlevel ) ) encntr_info->n_room_cd = pla.value_cd
        ENDIF
       OF encntr_info->o_bed_cd :
        IF ((bed_level >= dcurlocationlevel ) ) encntr_info->n_bed_cd = pla.value_cd
        ENDIF
      ENDCASE
     WITH nocounter
    ;end select
    CASE (dcurlocationlevel )
     OF facility_level :
      IF ((encntr_info->n_facility_cd > 0.0 ) )
       SET encntr_info->n_location_cd = encntr_info->n_facility_cd
      ENDIF
     OF building_level :
      IF ((encntr_info->n_building_cd > 0.0 ) )
       SET encntr_info->n_location_cd = encntr_info->n_building_cd
      ENDIF
     OF nurse_unit_level :
      IF ((encntr_info->n_nurse_unit_cd > 0.0 ) )
       SET encntr_info->n_location_cd = encntr_info->n_nurse_unit_cd
      ENDIF
     OF room_level :
      IF ((encntr_info->n_room_cd > 0.0 ) )
       SET encntr_info->n_location_cd = encntr_info->n_room_cd
      ENDIF
     OF bed_level :
      IF ((encntr_info->n_bed_cd > 0.0 ) )
       SET encntr_info->n_location_cd = encntr_info->n_bed_cd
      ENDIF
    ENDCASE
   ELSE
    IF (bdebugme )
     CALL echo ("*** Location update failed. No ED Hold Attribute built up ***" )
    ENDIF
    RETURN (false )
   ENDIF
  ELSE
   IF (bdebugme )
    CALL echo ("*** Location update failed. Scenario is not qualified or building issue ***" )
   ENDIF
   RETURN (false )
  ENDIF
  IF (bdebugme )
   CALL echo ("*** PopulateLocationId Subroutine***" )
   CALL echo (build2 ("EDHOLD_ATTRIB_TYPE_CD: " ,edhold_attrib_type_cd ) )
   CALL echo (build2 ("dPatientEventTypeCd: " ,dpatienteventtypecd ) )
   CALL echo (build2 ("bLocAttribUsageInd: " ,blocattribusageind ) )
   CALL echo (build2 ("dCurLocationLevel: " ,dcurlocationlevel ) )
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  obspostprocess (null )
  CALL getpersonnelrelationships (null )
  call echo(build2("borderinforetrieved=",borderinforetrieved)) ;001
  IF ((borderinforetrieved = false ) )
  	call echo(build2("getorderinfo")) ;001
   CALL getorderinfo (null )
  ENDIF
  CALL getaccomcode (null )
  ; ;001IF (bdebugme )
   ; ;001CALL echorecord (encntr_info )
  ; ;001 CALL echorecord (order_info )
 ; ;001 ENDIF
  CALL updateencounterinformation (null )
 END ;Subroutine
 SUBROUTINE  updateencounterinformation (null )
  DECLARE saction = vc WITH noconstant ("" ) ,privateprotect
  DECLARE deventdatetime = f8 WITH noconstant (0.0 ) ,privateprotect
  DECLARE dpatienteventtypecd = f8 WITH noconstant (false ) ,protect
  IF ((transfer_order_mode = cnvtupper (trim (patient_event_request->order_mode ,3 ) ) ) )
   IF (bdebugme )
    CALL echo ("----TRANSFER_ORDER_MODE----" )
   ENDIF
   IF ((encntr_info->n_med_service_cd > 0.0 )
   AND (encntr_info->n_med_service_cd != encntr_info->o_med_service_cd ) )
    SET stat = uar_srvsetshort (hencntr ,"_medicalServiceCd" ,1 )
    SET stat = uar_srvsetdouble (hencntr ,"medicalServiceCd" ,encntr_info->n_med_service_cd )
    SET bupdateind = true
    IF (bdebugme )
     CALL echo (build2 ("hEncntr _medicalServiceCd: " ,uar_srvgetshort (hencntr ,"_medicalServiceCd"
        ) ) )
     CALL echo (build2 ("hEncntr medicalServiceCd: " ,uar_srvgetdouble (hencntr ,"medicalServiceCd"
        ) ) )
    ENDIF
   ELSE
    IF (bdebugme )
     CALL echo ("*** No Medical service to update. ***" )
    ENDIF
   ENDIF
   IF ((encntr_info->n_accom_cd > 0.0 )
   AND (encntr_info->n_accom_cd != encntr_info->o_accom_cd ) )
    SET stat = uar_srvsetshort (hencntr ,"_accommodationCd" ,1 )
    SET stat = uar_srvsetdouble (hencntr ,"accommodationCd" ,encntr_info->n_accom_cd )
    SET bupdateind = true
    IF (bdebugme )
     CALL echo (build2 ("hEncntr _accommodationCd: " ,uar_srvgetshort (hencntr ,"_accommodationCd" )
       ) )
     CALL echo (build2 ("hEncntr accommodationCd: " ,uar_srvgetdouble (hencntr ,"accommodationCd" )
       ) )
    ENDIF
   ELSE
    IF (bdebugme )
     CALL echo ("*** No Accommodation to update. ***" )
    ENDIF
   ENDIF
   call echo("setpersonnelrelationships") ;001
   CALL setpersonnelrelationships (null )
  ELSE
   IF (bdebugme )
    CALL echo ("----NOT TRANSFER_ORDER_MODE----" )
   ENDIF
   IF ((size (patient_event_request->patient_event ,5 ) > 0 ) )
    SET dpatienteventtypecd = patient_event_request->patient_event[1 ].event_type_cd
    SET saction = patient_event_request->patient_event[1 ].action
    SET deventdatetime = patient_event_request->patient_event[1 ].event_dt_tm
    IF ((((dpatienteventtypecd <= 0.0 ) ) OR ((((textlen (trim (saction ,3 ) ) <= 0 ) ) OR ((
    deventdatetime <= 0.0 ) )) )) )
     IF (bdebugme )
      CALL echo ("*** Missing data - UpdateEncounterInformation - patient_event data. ***" )
     ENDIF
     SET log_message = formatlogmessage (
      "*** Missing data - UpdateEncounterInformation - patient_event data. ***" )
     CALL setreplystatusblock ("No Patient Event Type Found" ,"F" ,"UpdateEncounterInformation" ,"0"
      )
     GO TO 9999_exit_program
    ENDIF
   ENDIF
   IF ((((dpatienteventtypecd = patient_event_observation_start_cd ) ) OR ((((dpatienteventtypecd =
   patient_event_inpatient_start_cd ) ) OR ((dpatienteventtypecd =
   patient_event_outpatient_in_bed_cd ) )) )) )
    SET encntr_info->n_encntr_type_cd = getencountertype (dpatienteventtypecd )
   ENDIF
   IF ((encntr_info->n_encntr_type_cd <= 0.0 ) )
    IF (bdebugme )
     CALL echo (build2 ("ERROR: codeValue for encounterTypeCd = " ,encntr_info->n_encntr_type_cd ,
       " not found." ) )
    ENDIF
    SET log_message = formatlogmessage (build2 ("ERROR: codeValue for encounterTypeCd = " ,
      encntr_info->n_encntr_type_cd ," not found." ) )
    CALL setreplystatusblock ("No Valid Encounter Type Found" ,"F" ,"UpdateEncounterInformation" ,
     "0" )
    GO TO 9999_exit_program
   ENDIF
   CASE (saction )
    OF "ADD" :
     IF ((order_info->code44_ind = true )
     AND (encntr_info->code44_id = 0.0 ) )
      SET hconditioncodes = uar_srvgetstruct (hrequest ,"conditionCodes" )
      SET haddconditioncode = uar_srvadditem (hconditioncodes ,"addConditionCodeList" )
      SET stat = uar_srvsetdouble (haddconditioncode ,"typeCd" ,condition_code_44 )
      SET stat = uar_srvsetshort (haddconditioncode ,"beginAtTimeOfTransactionInd" ,1 )
      SET bupdateind = true
      IF (bdebugme )
       CALL echo (build2 ("CONDITION_CODE_44 typeCd: " ,uar_srvgetdouble (haddconditioncode ,
          "typeCd" ) ) )
       CALL echo (build2 ("CONDITION_CODE_44 beginAtTimeOfInd: " ,uar_srvgetshort (haddconditioncode
          ," beginAtTimeOfTransactionInd" ) ) )
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo (build2 ("*** No Condition 44 to update. ***" ) )
      ENDIF
     ENDIF
     ,
     IF ((encntr_info->n_encntr_type_cd != encntr_info->o_encntr_type_cd ) )
      SET stat = uar_srvsetshort (hencntr ,"_typeCd" ,1 )
      SET stat = uar_srvsetdouble (hencntr ,"typeCd" ,encntr_info->n_encntr_type_cd )
      SET bupdateind = true
      IF (bdebugme )
       CALL echo (build2 ("Encounter _typeCd: " ,uar_srvgetshort (hencntr ,"_typeCd" ) ) )
       CALL echo (build2 ("Encounter typeCd: " ,uar_srvgetdouble (hencntr ,"typeCd" ) ) )
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo (build2 ("*** No Encounter type to update. ***" ) )
      ENDIF
     ENDIF
     ,
     IF ((encntr_info->n_med_service_cd > 0.0 )
     AND (encntr_info->n_med_service_cd != encntr_info->o_med_service_cd ) )
      SET stat = uar_srvsetshort (hencntr ,"_medicalServiceCd" ,1 )
      SET stat = uar_srvsetdouble (hencntr ,"medicalServiceCd" ,encntr_info->n_med_service_cd )
      SET bupdateind = true
      IF (bdebugme )
       CALL echo (build2 ("Encounter _medicalServiceCd: " ,uar_srvgetshort (hencntr ,
          "_medicalServiceCd" ) ) )
       CALL echo (build2 ("Encounter medicalServiceCd: " ,uar_srvgetdouble (hencntr ,
          "medicalServiceCd" ) ) )
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo ("*** No Medical service to update. ***" )
      ENDIF
     ENDIF
     ,
     IF ((encntr_info->n_accom_cd > 0.0 )
     AND (encntr_info->n_accom_cd != encntr_info->o_accom_cd ) )
      SET stat = uar_srvsetshort (hencntr ,"_accommodationCd" ,1 )
      SET stat = uar_srvsetdouble (hencntr ,"accommodationCd" ,encntr_info->n_accom_cd )
      SET bupdateind = true
      IF (bdebugme )
       CALL echo (build2 ("Encounter _accommodationCd: " ,uar_srvgetshort (hencntr ,
          "_accommodationCd" ) ) )
       CALL echo (build2 ("Encounter accommodationCd: " ,uar_srvgetdouble (hencntr ,
          "accommodationCd" ) ) )
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo ("*** No Accommodation to update. ***" )
      ENDIF
     ENDIF
     ,
     CASE (dpatienteventtypecd )
      OF patient_event_outpatient_in_bed_cd :
       IF ((encntr_info->inpatient_admit_dt_tm > 0.0 )
       AND (encntr_info->inpatient_admit_dt_tm < patient_event_request->patient_event[1 ].event_dt_tm
        ) )
        SET encntr_info->inpatient_admit_dt_tm = blank_date
        SET stat = uar_srvsetshort (hencntr ,"_inpatientAdmitDateTime" ,1 )
        SET bupdateind = true
        IF (bdebugme )
         CALL echo ("PATIENT_EVENT_OUTPATIENT_IN_BED_CD" )
         CALL echo (build2 ("Encounter _inpatientAdmitDateTime: " ,uar_srvgetshort (hencntr ,
            "_inpatientAdmitDateTime" ) ) )
        ENDIF
       ELSE
        IF (bdebugme )
         CALL echo ("*** No Inpatient admit date time to update.. ***" )
        ENDIF
       ENDIF
      OF patient_event_observation_start_cd :
       IF ((encntr_info->inpatient_admit_dt_tm > 0.0 ) )
        SET encntr_info->inpatient_admit_dt_tm = blank_date
        SET stat = uar_srvsetshort (hencntr ,"_inpatientAdmitDateTime" ,1 )
        SET bupdateind = true
        IF (bdebugme )
         CALL echo ("PATIENT_EVENT_OBSERVATION_START_CD" )
         CALL echo (build2 ("Encounter _inpatientAdmitDateTime: " ,uar_srvgetshort (hencntr ,
            "_inpatientAdmitDateTime" ) ) )
        ENDIF
       ELSE
        IF (bdebugme )
         CALL echo ("*** No Inpatient admit date time to update.. ***" )
        ENDIF
       ENDIF
      OF patient_event_inpatient_start_cd :
       IF ((encntr_info->inpatient_admit_dt_tm != patient_event_request->patient_event[1 ].
       event_dt_tm ) )
        SET encntr_info->inpatient_admit_dt_tm = patient_event_request->patient_event[1 ].event_dt_tm
        SET stat = uar_srvsetshort (hencntr ,"_inpatientAdmitDateTime" ,1 )
        SET stat = uar_srvsetdate (hencntr ,"inpatientAdmitDateTime" ,cnvtdatetime (encntr_info->
          inpatient_admit_dt_tm ) )
        SET bupdateind = true
        IF (bdebugme )
         CALL echo (build2 ("Encounter _inpatientAdmitDtTm: " ,uar_srvgetshort (hencntr ,
            "_inpatientAdmitDateTime" ) ) )
         CALL echo (build2 ("Encounter inpatientAdmitDtTm: " ,uar_srvgetdateptr (hencntr ,
            "inpatientAdmitDateTime" ) ) )
        ENDIF
       ELSE
        IF (bdebugme )
         CALL echo ("*** No Inpatient admit date time to update.. ***" )
        ENDIF
       ENDIF
     ENDCASE
     ,
     IF ((populatelocationid (dpatienteventtypecd ) = true ) )
      IF ((encntr_info->n_location_cd > 0.0 )
      AND (encntr_info->n_location_cd != encntr_info->o_location_cd ) )
       SET stat = uar_srvsetshort (hencntr ,"_locationId" ,1 )
       SET stat = uar_srvsetdouble (hencntr ,"locationId" ,encntr_info->n_location_cd )
       SET bupdateind = true
       IF (bdebugme )
        CALL echo (build2 ("Encounter _locationId: " ,uar_srvgetshort (hencntr ,"_locationId" ) ) )
        CALL echo (build2 ("Encounter locationId: " ,uar_srvgetshort (hencntr ,"locationId" ) ) )
       ENDIF
      ELSE
       IF (bdebugme )
        CALL echo ("*** No Location Change. ***" )
       ENDIF
      ENDIF
     ENDIF
     ,
     CALL setpersonnelrelationships (null )
    OF "DEL" :
     IF ((order_info->code44_ind = true )
     AND (encntr_info->code44_id > 0.0 ) )
      SET hconditioncodes = uar_srvgetstruct (hrequest ,"conditionCodes" )
      SET hremoveconditioncode = uar_srvadditem (hconditioncodes ,"removeConditionCodeList" )
      SET stat = uar_srvsetdouble (hremoveconditioncode ,"id" ,encntr_info->code44_id )
      SET bupdateind = true
      IF (bdebugme )
       CALL echo (build2 ("CONDITION_CODE_44 id: " ,uar_srvgetdouble (hremoveconditioncode ,"id" ) )
        )
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo ("*** No Conditon 44 to delete. ***" )
      ENDIF
     ENDIF
     ,
     IF ((encntr_info->o_encntr_type_class_cd > 0.0 ) )
      SELECT INTO "nl:"
       FROM (encntr_flex_hist efh )
       WHERE (efh.encntr_id = patient_event_request->encntr_id )
       AND (efh.active_ind = 1 )
       ORDER BY cnvtdatetime (efh.updt_dt_tm ) DESC
       DETAIL
        IF ((efh.encntr_type_cd != encntr_info->o_encntr_type_cd )
        AND (encntr_info->pre_encntr_type_cd <= 0.0 ) ) encntr_info->pre_encntr_type_cd = efh
         .encntr_type_cd
        ENDIF
       WITH nocounter
      ;end select
      SET stat = uar_srvsetshort (hencntr ,"_typeCd" ,1 )
      SET stat = uar_srvsetdouble (hencntr ,"typeCd" ,encntr_info->pre_encntr_type_cd )
      SET bupdateind = true
      IF (bdebugme )
       CALL echo (build2 ("Encounter _typeCd: " ,uar_srvgetshort (hencntr ,"_typeCd" ) ) )
       CALL echo (build2 ("Encounter typeCd: " ,uar_srvgetdouble (hencntr ,"typeCd" ) ) )
      ENDIF
      IF ((dpatienteventtypecd = patient_event_inpatient_start_cd )
      AND (encntr_info->inpatient_admit_dt_tm != null ) )
       SET stat = uar_srvsetshort (hencntr ,"_inpatientAdmitDateTime" ,1 )
       SET bupdateind = true
       IF (bdebugme )
        CALL echo (build2 ("Encounter _inpatientAdmitDateTime: " ,uar_srvgetshort (hencntr ,
           "_inpatientAdmitDateTime" ) ) )
       ENDIF
      ELSE
       IF (bdebugme )
        CALL echo ("*** No update to Revert encounter type and delete Inpatient Admit Dttm. ***" )
       ENDIF
      ENDIF
     ELSE
      IF (bdebugme )
       CALL echo ("*** No update to delete action. ***" )
      ENDIF
     ENDIF
   ENDCASE
  ENDIF
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  (getencountertype (dpatienteventtypecd =f8 ) =f8 )
  DECLARE dencntrtypecd = f8 WITH noconstant (- (1 ) ) ,protect
  DECLARE dencounterclasscd = f8 WITH noconstant (0.0 ) ,protect
  IF ((bmultiencntrtypeperfacility = false ) )
   CASE (dpatienteventtypecd )
    OF patient_event_observation_start_cd :
     SET dencntrtypecd = observation_visit_type_cd
    OF patient_event_inpatient_start_cd :
     SET dencntrtypecd = inpatient_visit_type_cd
    OF patient_event_outpatient_in_bed_cd :
     SET dencntrtypecd = outpatient_visit_type_cd
   ENDCASE
  ELSE
   CASE (dpatienteventtypecd )
    OF patient_event_observation_start_cd :
     SET dencounterclasscd = observation_visit_class
    OF patient_event_inpatient_start_cd :
     SET dencounterclasscd = inpatient_visit_class
    OF patient_event_outpatient_in_bed_cd :
     SET dencounterclasscd = outpatient_visit_class
   ENDCASE
   IF ((encntr_info->o_facility_cd > 0.0 )
   AND (dencounterclasscd > 0.0 ) )
    SELECT INTO "nl:"
     FROM (code_value_group cvg ),
      (code_value cv ),
      (code_value_group cvg2 )
     PLAN (cvg
      WHERE (cvg.code_set = 220 )
      AND (cvg.child_code_value = encntr_info->o_facility_cd ) )
      JOIN (cv
      WHERE (cv.code_value = cvg.parent_code_value )
      AND (cv.code_set = visit_type_codeset ) )
      JOIN (cvg2
      WHERE (cvg2.child_code_value = cv.code_value )
      AND (cvg2.parent_code_value = dencounterclasscd ) )
     DETAIL
      dencntrtypecd = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  RETURN (dencntrtypecd )
 END ;Subroutine
 DECLARE eks_result_failed = i4 WITH constant (- (1 ) ) ,protect
 DECLARE eks_result_false = i4 WITH constant (0 ) ,protect
 DECLARE eks_result_true = i4 WITH constant (100 ) ,protect
 DECLARE observation_from_registration = f8 WITH constant (uar_get_code_by ("MEANING" ,207902 ,
   "OBSCHGREG" ) ) ,protect
 DECLARE clinical_discharge_from_registration = f8 WITH constant (uar_get_code_by ("MEANING" ,207902
   ,"CLINDISREG" ) ) ,protect
 DECLARE log_level_debug = i4 WITH constant (4 ) ,protect
 DECLARE log_level_error = i4 WITH constant (0 ) ,protect
 DECLARE discrete_task_assay_code_set = i4 WITH constant (14003 ) ,protect
 DECLARE clinical_discharge_concept_cki = vc WITH constant (
  "CERNER!D44A10FA-0E1C-4B34-9119-6C711A29B3F2" ) ,protect
 DECLARE run_post_process_script = f8 WITH constant (uar_get_code_by ("MEANING" ,207902 ,
   "OBSPOSTPROC" ) ) ,protect
 DECLARE order_action_ordered_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,6003 ,"ORDER" ) ) ,
 protect
 DECLARE patient_event_outpatient_in_bed_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,4002773 ,
   "OUTPATINBED" ) ) ,protect
 DECLARE patient_event_observation_start_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,4002773 ,
   "STARTOBS" ) ) ,protect
 DECLARE patient_event_inpatient_start_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,4002773 ,
   "STARTINPAT" ) ) ,protect
 DECLARE patient_event_clinical_discharge_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,4002773
   ,"CLINDISCHRG" ) ) ,protect
 DECLARE pf_auth_verified = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE pf_modified = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) ) ,protect
 DECLARE pf_in_error = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) ) ,protect
 DECLARE outpatient_in_bed_mode = vc WITH constant ("OUTPATIENT_IN_BED_ORDER" ) ,protect
 DECLARE observation_mode = vc WITH constant ("OBSERVATION_ORDER" ) ,protect
 DECLARE inpatient_mode = vc WITH constant ("INPATIENT_ORDER" ) ,protect
 DECLARE clinical_discharge_mode = vc WITH constant ("CLINICAL_DISCHARGE_POWERFORM" ) ,protect
 DECLARE patient_transfer_mode = vc WITH constant ("TRANSFER_PATIENT_ORDER" ) ,protect
 DECLARE pft_queue_observation_review_required = f8 WITH constant (uar_get_code_by ("MEANING" ,29322
   ,"OBSCHRGREV" ) ) ,protect
 DECLARE pft_queue_observation_review_canceled = f8 WITH constant (uar_get_code_by ("MEANING" ,29322
   ,"OBSCHRGREVCN" ) ) ,protect
 DECLARE oe_outpatient_in_bed = vc WITH constant ("OUTPTBEDDTETME" ) ,protect
 DECLARE oe_charge_start_dt_tm = vc WITH constant ("CHARGESTARTDTTM" ) ,protect
 DECLARE oe_inpatient_admit_dt_tm = vc WITH constant ("INPTADMDTETME" ) ,protect
 DECLARE medservice_codeset = i4 WITH constant (34 ) ,protect
  ;001 DECLARE attend_meaning_id = f8 WITH constant (6028.0 ) ,protect             3303.00
 DECLARE attend_meaning_id = f8 WITH constant (3303.0 ) ,protect            
 DECLARE admit_meaning_id = f8 WITH constant (6027.0 ) ,protect
 DECLARE attenddoc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,333 ,"ATTENDDOC" ) ) ,protect
 DECLARE admitdoc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,333 ,"ADMITDOC" ) ) ,protect
 DECLARE transfer_order_mode = vc WITH constant ("TRANSFER_PATIENT_ORDER" ) ,protect
 DECLARE observation_visit_class = f8 WITH constant (uar_get_code_by ("MEANING" ,69 ,"OBSERVATION" )
  ) ,protect
 DECLARE inpatient_visit_class = f8 WITH constant (uar_get_code_by ("MEANING" ,69 ,"INPATIENT" ) ) ,
 protect
 DECLARE outpatient_visit_class = f8 WITH constant (uar_get_code_by ("MEANING" ,69 ,"OUTPATIENT" ) )
 ,protect
 DECLARE observation_visit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,71 ,"OBSERVATION"
   ) ) ,protect
 DECLARE inpatient_visit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,71 ,"INPATIENT" ) )
 ,protect
 DECLARE outpatient_visit_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,71 ,"OUTPATIENT" )
  ) ,protect
 DECLARE condition_code_44 = f8 WITH constant (uar_get_code_by ("MEANING" ,21790 ,"44" ) ) ,protect
 DECLARE visit_type_codeset = i4 WITH constant (71 ) ,protect
 DECLARE blank_date = f8 WITH constant (cnvtdatetime ("01-JAN-1800 00:00:00.00" ) ) ,protect
 DECLARE bcode44inorder = i2 WITH noconstant (false ) ,protect
 DECLARE bcode44inencntr = i2 WITH noconstant (false ) ,protect
 DECLARE dcurrentclinicaleventid = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dordereventtypecd = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dpowerformeventtypecd = f8 WITH noconstant (0.0 ) ,protect
 DECLARE scurrentorderentryfield = vc WITH noconstant ("" ) ,protect
 DECLARE sparamvalue = vc WITH noconstant ("" ) ,protect
 DECLARE dorderaction = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dclinicaldischargedtacd = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dcurrenteventtypecd = f8 WITH noconstant (0.0 ) ,protect
 DECLARE dcurrenteventdttm = f8 WITH noconstant (0.0 ) ,protect
 DECLARE bskippatientevent = i2 WITH noconstant (false ) ,protect
 DECLARE borderdateset = i2 WITH noconstant (false ) ,protect
 DECLARE battendphysblankonorder = i2 WITH noconstant (false ) ,protect
 DECLARE bnondischargeeventexists = i2 WITH noconstant (false ) ,protect
 DECLARE bnondischargeeventexistschecked = i2 WITH noconstant (false ) ,protect
 DECLARE bcheckdischargestate = i2 WITH noconstant (false ) ,protect
 DECLARE bcheckdischargestatechecked = i2 WITH noconstant (false ) ,protect
 DECLARE lencntrversion = i4 WITH noconstant (0 ) ,protect
 DECLARE binactiveopinabed = i2 WITH noconstant (false ) ,protect
 DECLARE binactiveobs = i2 WITH noconstant (false ) ,protect
 DECLARE binactiveinp = i2 WITH noconstant (false ) ,protect
 DECLARE bsuccessind = i2 WITH noconstant (false ) ,protect
 DECLARE hreplyhistid = f8 WITH noconstant (0.0 ) ,protect
 DECLARE borderinforetrieved = i2 WITH noconstant (false ) ,protect
 DECLARE bupdateind = i2 WITH noconstant (false ) ,protect
 DECLARE bmultiencntrtypeperfacility = i2 WITH noconstant (false ) ,protect
 DECLARE ejs_modify_encounter_request = i4 WITH constant (115552 ) ,protect
 DECLARE hmodencmsg = i4 WITH noconstant (0 ) ,protect
 DECLARE hrequest = i4 WITH noconstant (0 ) ,protect
 DECLARE hreply = i4 WITH noconstant (0 ) ,protect
 DECLARE hevents = i4 WITH noconstant (0 ) ,protect
 DECLARE hencntr = i4 WITH noconstant (0 ) ,protect
 DECLARE htransinfolist = i4 WITH noconstant (0 ) ,protect
 DECLARE haddeventlist = i4 WITH noconstant (0 ) ,protect
 DECLARE hremoveeventlist = i4 WITH noconstant (0 ) ,protect
 DECLARE htransstatus = i4 WITH noconstant (0 ) ,protect
 DECLARE hphysicians = i4 WITH noconstant (0 ) ,protect
 DECLARE hmodifyepr = i4 WITH noconstant (0 ) ,protect
 DECLARE haddepr = i4 WITH noconstant (0 ) ,protect
 DECLARE hconditioncodes = i4 WITH noconstant (0 ) ,protect
 DECLARE haddconditioncode = i4 WITH noconstant (0 ) ,protect
 DECLARE hremoveconditioncode = i4 WITH noconstant (0 ) ,protect
 DECLARE setuprequest (null ) = i2
 DECLARE executeejscall (null ) = i2
 DECLARE cleanuphandles (null ) = i2
 DECLARE populateencounterinfo (null ) = null
 DECLARE getorderaction (null ) = f8
 IF ((validate (bdebugme ,- (9 ) ) = - (9 ) ) )
  DECLARE bdebugme = i2 WITH noconstant (false )
 ENDIF
 IF ((validate (bdebugejscall ,- (9 ) ) = - (9 ) ) )
  ;001 DECLARE bdebugejscall = i2 WITH noconstant (false )
  DECLARE bdebugejscall = i2 WITH noconstant (true ) ;001
 ENDIF
 SET bmultiencntrtypeperfacility = false
 FREE RECORD patient_event_request
 RECORD patient_event_request (
   1 encntr_id = f8
   1 person_id = f8
   1 order_id = f8
   1 patient_event_qual = i4
   1 order_mode = vc
   1 patient_event [1 ]
     2 action = vc
     2 event_dt_tm = dq8
     2 event_type_cd = f8
     2 patient_event_id = f8
 )
 IF ((validate (reply->status_data.status ,"Z" ) = "Z" ) )
  FREE RECORD reply
  RECORD reply (
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD order_info
 RECORD order_info (
   1 med_service_cd = f8
   1 los_codeset = i4
   1 los_cd = f8
   1 accom_cd = f8
   1 order_physician_id = f8
   1 admit_physician_id = f8
   1 attend_physician_id = f8
   1 code44_ind = i2
 )
 FREE RECORD encntr_info
 RECORD encntr_info (
   1 version = i4
   1 contributor_sys_cd = f8
   1 o_med_service_cd = f8
   1 n_med_service_cd = f8
   1 o_accom_cd = f8
   1 n_accom_cd = f8
   1 o_encntr_type_cd = f8
   1 n_encntr_type_cd = f8
   1 o_encntr_type_class_cd = f8
   1 o_location_cd = f8
   1 o_facility_cd = f8
   1 o_building_cd = f8
   1 o_nurse_unit_cd = f8
   1 o_room_cd = f8
   1 o_bed_cd = f8
   1 n_location_cd = f8
   1 n_facility_cd = f8
   1 n_building_cd = f8
   1 n_nurse_unit_cd = f8
   1 n_room_cd = f8
   1 n_bed_cd = f8
   1 pre_encntr_type_class_cd = f8
   1 pre_encntr_type_cd = f8
   1 code44_id = f8
   1 inpatient_admit_dt_tm = dq8
   1 reg_dt_tm = dq8
   1 pre_reg_dt_tm = dq8
   1 disch_dt_tm = dq8
   1 arrive_dt_tm = dq8
   1 admit_decision_dt_tm = dq8
   1 current_event_dt_tm = dq8
   1 o_attend_p_id = f8
   1 o_attend_r_id = f8
   1 o_admit_p_id = f8
   1 o_admit_r_id = f8
   1 n_attend_p_id = f8
   1 n_admit_p_id = f8
 )
 SET reply->status_data.status = "F"
 SET retval = eks_result_failed
 SET sparamvalue = parameter (1 ,0 )
 SET sparamvalue = cnvtupper (trim (sparamvalue ,3 ) )
 IF ((textlen (sparamvalue ) <= 0 ) )
  SET log_message = "Invalid input - No Parameter passed in."
  CALL setreplystatusblock ("No Parameter Found" ,"F" ,"sParamValue" ,"EMPTY" )
  GO TO 9999_exit_program
 ENDIF
 IF ((trigger_encntrid <= 0.0 ) )
  SET log_message = "Invalid input - No Encounter ID passed in."
  CALL setreplystatusblock ("No Encounter ID Found" ,"F" ,"trigger_encntrid" ,build (
    trigger_encntrid ) )
  GO TO 9999_exit_program
 ENDIF
 IF ((trigger_personid <= 0.0 ) )
  SET log_message = "Invalid input - No Person ID passed in."
  CALL setreplystatusblock ("No Person ID Found" ,"F" ,"trigger_personid" ,build (trigger_personid )
   )
  GO TO 9999_exit_program
 ENDIF
 call echo(build2("sparamvalue=",sparamvalue)) ;001
 CASE (sparamvalue )
  OF outpatient_in_bed_mode :
   SET dordereventtypecd = patient_event_outpatient_in_bed_cd
   SET scurrentorderentryfield = oe_outpatient_in_bed
  OF observation_mode :
   SET dordereventtypecd = patient_event_observation_start_cd
   SET scurrentorderentryfield = oe_charge_start_dt_tm
  OF inpatient_mode :
   SET dordereventtypecd = patient_event_inpatient_start_cd
   SET scurrentorderentryfield = oe_inpatient_admit_dt_tm
  OF clinical_discharge_mode :
   SET dpowerformeventtypecd = patient_event_clinical_discharge_cd
  OF patient_transfer_mode :
   SET bskippatientevent = true
   IF ((trigger_orderid <= 0.0 ) )
    SET log_message = "Invalid input - No Order ID passed in."
    CALL setreplystatusblock ("No Order ID Found" ,"F" ,"trigger_orderid" ,build (trigger_orderid )
     )
    GO TO 9999_exit_program
   ENDIF
 ENDCASE
 
 call echo(build2("bskippatientevent=",bskippatientevent)) ;001
 call echo(build2("false=",false)) ;001
 
 IF ((setuprequest (null ) = false ) )
  SET log_message = "EJS Setup Fail, Error creating Encounter Modify Service 115552"
  GO TO 9999_exit_program
 ENDIF
 
 IF ((bskippatientevent = false ) )
  IF ((dordereventtypecd > 0.0 )
  AND (textlen (scurrentorderentryfield ) > 0 ) )
   IF ((observation_from_registration > 0.0 ) )
    SET log_message = "OBSCHGREG is enabled."
    CALL setreplystatusblock ("OBSCHGREG is enabled" ,"F" ,"OBSCHGREG in 207902" ,build (
      observation_from_registration ) )
    GO TO 9999_exit_program
   ENDIF
   IF ((trigger_orderid <= 0.0 ) )
    SET log_message = "Invalid input - No Order ID passed in."
    CALL setreplystatusblock ("No Order ID Found" ,"F" ,"trigger_orderid" ,"0" )
    GO TO 9999_exit_program
   ENDIF
   IF ((getorderaction (null ) = order_action_ordered_cd ) )
    SELECT INTO "nl:"
     FROM (patient_event pe )
     WHERE (pe.encntr_id = trigger_encntrid )
     AND (pe.event_type_cd IN (patient_event_outpatient_in_bed_cd ,
     patient_event_observation_start_cd ,
     patient_event_inpatient_start_cd ,
     patient_event_clinical_discharge_cd ) )
     AND (pe.active_ind = 1 )
     ORDER BY cnvtdatetime (pe.event_dt_tm ) DESC
     DETAIL
      IF ((dcurrenteventtypecd <= 0.0 ) ) dcurrenteventdttm = cnvtdatetime (pe.event_dt_tm ) ,
       dcurrenteventtypecd = pe.event_type_cd
      ENDIF
     WITH nocounter ,maxrec = 1
    ;end select
    SET encntr_info->current_event_dt_tm = dcurrenteventdttm
    SET borderinforetrieved = true
    CALL getobslos (null )
    call echo("finding order details") ;001
    SELECT INTO "nl:"
     FROM (orders o ),
      (order_action oa ),
      (order_detail od ),
      (order_entry_fields oef )
     PLAN (o
      WHERE (o.order_id = trigger_orderid )
      AND (o.active_ind = 1 ) )
      JOIN (oa
      WHERE (oa.order_id = o.order_id )
      AND (oa.action_type_cd IN (order_action_ordered_cd ) ) )
      JOIN (od
      WHERE (od.order_id = Outerjoin(o.order_id )) )
      JOIN (oef
      WHERE (oef.oe_field_id = Outerjoin(od.oe_field_id )) )
     ORDER BY oa.action_sequence DESC
     HEAD oa.action_sequence
      order_info->order_physician_id = oa.order_provider_id ,dorderaction = oa.action_type_cd
     DETAIL
      IF ((scurrentorderentryfield = od.oe_field_meaning ) )
       IF ((od.oe_field_dt_tm_value > 0.0 ) ) patient_event_request->patient_event[1 ].event_dt_tm =
        cnvtdatetime (od.oe_field_dt_tm_value )
       ELSE
        IF ((dordereventtypecd = dcurrenteventtypecd ) ) patient_event_request->patient_event[1 ].
         event_dt_tm = cnvtdatetime (dcurrenteventdttm )
        ELSE patient_event_request->patient_event[1 ].event_dt_tm = cnvtdatetime (o.status_dt_tm )
        ENDIF
       ENDIF
       ,borderdateset = true
      ELSE
       IF (NOT (borderdateset ) ) patient_event_request->patient_event[1 ].event_dt_tm =
        cnvtdatetime (o.status_dt_tm )
       ENDIF
      ENDIF
      ,
      IF ((od.oe_field_meaning = "CONDITIONCODE44" ) )
       IF ((od.oe_field_value = 1.0 ) ) order_info->code44_ind = true
       ENDIF
      ENDIF
      ,
      IF ((oef.codeset = order_info->los_codeset )
      AND (order_info->los_codeset > 0.0 ) ) order_info->los_cd = od.oe_field_value
      ELSEIF ((oef.codeset = medservice_codeset ) ) order_info->med_service_cd = od.oe_field_value
      ENDIF
      ,
      IF ((oef.oe_field_meaning_id = attend_meaning_id ) ) order_info->attend_physician_id = od
       .oe_field_value
      ELSEIF ((oef.oe_field_meaning_id = admit_meaning_id ) ) order_info->admit_physician_id = od
       .oe_field_value
      ENDIF
     WITH nocounter
    ;end select
    CALL getcurrentphysicianandconditioncode (null )
    IF ((patient_event_request->patient_event[1 ].event_dt_tm <= 0.0 ) )
     CALL setreplystatusblock ("Invalid order Date/Time" ,"F" ,"trigger_orderid" ,build (
       trigger_orderid ) )
     SET log_message = "No event date/time for order"
     GO TO 9999_exit_program
    ENDIF
    SET patient_event_request->patient_event[1 ].event_type_cd = dordereventtypecd
   ENDIF
   IF ((dorderaction = order_action_ordered_cd ) )
    SET patient_event_request->patient_event[1 ].action = "ADD"
   ELSE
    SET log_message = "No supported action found for order"
    CALL setreplystatusblock ("No supported action found" ,"F" ,"trigger_orderid" ,build (
      trigger_orderid ) )
    GO TO 9999_exit_program
   ENDIF
  ELSEIF ((dpowerformeventtypecd > 0.0 ) )
   IF ((clinical_discharge_from_registration > 0.0 ) )
    CALL setreplystatusblock ("CLINDISREG is enabled." ,"F" ,"CLINDISREG in 207902" ,build (
      clinical_discharge_from_registration ) )
    SET log_message = "CLINDISREG is enabled."
    GO TO 9999_exit_program
   ENDIF
   SET dcurrentclinicaleventid = eksdata->tqual[3 ].qual[1 ].clinical_event_id
   IF ((dcurrentclinicaleventid <= 0.0 ) )
    CALL setreplystatusblock ("No Clinical Event ID" ,"F" ,"dCurrentClinicalEventId" ,build (
      dcurrentclinicaleventid ) )
    SET log_message = "Invalid input - No Clinical Event ID passed in."
    GO TO 9999_exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM (code_value cv )
    WHERE (cv.code_set = discrete_task_assay_code_set )
    AND (cv.concept_cki = clinical_discharge_concept_cki )
    AND (cv.active_ind = 1 )
    DETAIL
     dclinicaldischargedtacd = cv.code_value
    WITH nocounter
   ;end select
   IF ((dclinicaldischargedtacd <= 0.0 ) )
    CALL setreplystatusblock ("No dClinicalDischargeDTACd" ,"F" ,"dClinicalDischargeDTACd" ,build (
      dclinicaldischargedtacd ) )
    SET log_message = "dClinicalDischargeDTACd not found"
    GO TO 9999_exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM (clinical_event ce ),
     (ce_date_result cedr )
    PLAN (ce
     WHERE (ce.clinical_event_id = dcurrentclinicaleventid )
     AND (ce.task_assay_cd = dclinicaldischargedtacd )
     AND (ce.valid_from_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ce.valid_until_dt_tm > cnvtdatetime (sysdate ) ) )
     JOIN (cedr
     WHERE (cedr.event_id = ce.event_id )
     AND (cedr.valid_until_dt_tm > cnvtdatetime (sysdate ) )
     AND (cedr.valid_from_dt_tm <= cnvtdatetime (sysdate ) ) )
    DETAIL
     CASE (ce.result_status_cd )
      OF pf_auth_verified :
      OF pf_modified :
       patient_event_request->patient_event[1 ].action = "ADD" ,
       patient_event_request->patient_event[1 ].event_dt_tm = cnvtdatetime (cedr.result_dt_tm )
      OF pf_in_error :
       patient_event_request->patient_event[1 ].action = "DEL"
     ENDCASE
    WITH nocounter
   ;end select
   IF ((curqual <= 0 ) )
    CALL setreplystatusblock ("Data Qualification" ,"F" ,"Clinical Discharge DtTm" ,"0" )
    SET log_message = "Data Qualification - No Clinical Discharge DtTm Found"
    GO TO 9999_exit_program
   ENDIF
   SET patient_event_request->patient_event[1 ].event_type_cd = dpowerformeventtypecd
  ELSE
   CALL setreplystatusblock ("Data Qualification" ,"F" ,"Data Qualificiation" ,"" )
   SET log_message = "Data Qualification - No Valid Event Type Found"
   GO TO 9999_exit_program
  ENDIF
  CALL obspostpatientevent (patient_event_request->patient_event[1 ].event_type_cd )
  SET bupdateind = true
 ENDIF
 
 
 IF ((dpowerformeventtypecd > 0.0 ) )
  CALL uar_srvsetdouble (htransinfolist ,"clinicalEventId" ,dcurrentclinicaleventid )
 ELSE
  CALL uar_srvsetdouble (htransinfolist ,"orderId" ,trigger_orderid )
 ENDIF
 
 
 SET patient_event_request->order_mode = sparamvalue
 call echo(build2("patient_event_request->order_mode=",patient_event_request->order_mode)) ;001
 call echo(build2("patient_event_request->patient_event[1 ].event_type_cd=",uar_get_code_display(
 	patient_event_request->patient_event[1 ].event_type_cd))) ;001
 
 IF ((run_post_process_script > 0.0 ) ) 
  IF ((((patient_event_request->patient_event[1 ].event_type_cd !=
  patient_event_clinical_discharge_cd ) ) OR ((bskippatientevent = true ) )) )
   call echo(build2("obspostprocess")) ;001
   CALL obspostprocess (null )
  ENDIF
 ENDIF
 
 
 CALL executeejscall (null )
 GO TO 9999_exit_program
 SUBROUTINE  setuprequest (null )
  SET hmodencmsg = uar_srvselectmessage (ejs_modify_encounter_request )
  IF ((hmodencmsg = 0 ) )
   CALL setreplystatusblock ("Failed to Create MESSAGE" ,"F" ,"SetupRequest" ,"0" )
   RETURN (false )
  ENDIF
  SET hrequest = uar_srvcreaterequest (hmodencmsg )
  IF ((hrequest = 0 ) )
   CALL setreplystatusblock ("Failed to Create REQUEST" ,"F" ,"SetupRequest" ,"0" )
   RETURN (false )
  ENDIF
  SET hreply = uar_srvcreatereply (hmodencmsg )
  IF ((hreply = 0 ) )
   CALL setreplystatusblock ("Failed to Create REPLY" ,"F" ,"SetupRequest" ,"0" )
   RETURN (false )
  ENDIF
  SET patient_event_request->encntr_id = trigger_encntrid
  SET patient_event_request->person_id = trigger_personid
  SET patient_event_request->order_id = trigger_orderid
  CALL populateencounterinfo (null )
  CALL uar_srvsetdouble (hrequest ,"encounterId" ,patient_event_request->encntr_id )
  CALL uar_srvsetdouble (hrequest ,"patientId" ,patient_event_request->person_id )
  CALL uar_srvsetlong (hrequest ,"version" ,encntr_info->version )
  SET htransinfolist = uar_srvadditem (hrequest ,"transactionInformation" )
  SET hencntr = uar_srvadditem (hrequest ,"encounter" )
  RETURN (true )
 END ;Subroutine
 SUBROUTINE  populateencounterinfo (null )
  SELECT INTO "nl:"
   FROM (encounter e )
   WHERE (e.encntr_id = patient_event_request->encntr_id )
   DETAIL
    encntr_info->o_encntr_type_cd = e.encntr_type_cd ,
    encntr_info->o_encntr_type_class_cd = e.encntr_type_class_cd ,
    encntr_info->o_location_cd = e.location_cd ,
    encntr_info->o_facility_cd = e.loc_facility_cd ,
    encntr_info->o_building_cd = e.loc_building_cd ,
    encntr_info->o_nurse_unit_cd = e.loc_nurse_unit_cd ,
    encntr_info->o_room_cd = e.loc_room_cd ,
    encntr_info->o_bed_cd = e.loc_bed_cd ,
    encntr_info->o_accom_cd = e.accommodation_cd ,
    encntr_info->o_med_service_cd = e.med_service_cd ,
    encntr_info->contributor_sys_cd = e.contributor_system_cd ,
    encntr_info->version = e.updt_cnt ,
    encntr_info->inpatient_admit_dt_tm = cnvtdatetime (e.inpatient_admit_dt_tm ) ,
    encntr_info->reg_dt_tm = cnvtdatetime (e.reg_dt_tm ) ,
    encntr_info->pre_reg_dt_tm = cnvtdatetime (e.pre_reg_dt_tm ) ,
    encntr_info->disch_dt_tm = cnvtdatetime (e.disch_dt_tm ) ,
    encntr_info->arrive_dt_tm = cnvtdatetime (e.arrive_dt_tm ) ,
    encntr_info->admit_decision_dt_tm = cnvtdatetime (e.admit_decision_dt_tm )
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  executeejscall (null )
  IF (bupdateind )
   IF (bdebugme )
    CALL uar_crmlogmessage (hrequest ,nullterm (build ("pm_obs_translate_rule_115552req_" ,cnvtint (
        patient_event_request->encntr_id ) ,"_.dat" ) ) )
    CALL echorecord (patient_event_request )
    CALL echorecord (order_info )
    CALL echorecord (encntr_info )
    call echo(build2("bdebugejscall=",bdebugejscall)) ;001
    IF (bdebugejscall )
     SET stat = uar_srvexecute (hmodencmsg ,hrequest ,hreply )
    ELSE
     GO TO 9999_exit_program
    ENDIF
   ELSE
    SET stat = uar_srvexecute (hmodencmsg ,hrequest ,hreply )
   ENDIF
   SET htransstatus = uar_srvgetstruct (hreply ,"transactionStatus" )
   SET bsuccessind = uar_srvgetshort (htransstatus ,"successIndicator" )
   IF ((bsuccessind = 1 ) )
    SET hreplyhistid = uar_srvgetdouble (hreply ,"transactionHistoryId" )
    SET reply->status_data.status = "S"
    CALL setreplystatusblock ("Patient Event Processed" ,"S" ,"ExecuteEJSCall" ,"0" )
    SET log_message = formatlogmessage ("Successfully process patient event" )
    SET retval = eks_result_true
    IF (bdebugme )
     CALL echo ("*** 373 returns success. ***" )
     CALL echorecord (reply )
     CALL uar_crmlogmessage (hreply ,nullterm (build ("pm_obs_translate_rule_115552rep_" ,cnvtint (
         patient_event_request->encntr_id ) ,"_.dat" ) ) )
    ENDIF
   ELSE
    DECLARE errormsg = vc WITH noconstant ("" ) ,private
    SET errormsg = uar_srvgetstringptr (htransstatus ,"debugErrorMessage" )
    SET log_message = formatlogmessage (concat ("Fail to process patient status from order: " ,
      errormsg ) )
    CALL setreplystatusblock ("Patient Event Failed" ,"F" ,"ExecuteEJSCall" ,"0" )
    IF (bdebugme )
     CALL echo (concat ("373 EJS Transaction Failure: " ,errormsg ) )
     CALL echorecord (reply )
     CALL uar_crmlogmessage (hreply ,nullterm (build ("pm_obs_translate_rule_115552rep_" ,cnvtint (
         patient_event_request->encntr_id ) ,"_.dat" ) ) )
    ENDIF
   ENDIF
  ELSE
   SET log_message = formatlogmessage ("No patient event to process" )
   CALL setreplystatusblock ("No Patient Event Found" ,"Z" ,"ExecuteEJSCall" ,"0" )
   SET retval = eks_result_true
   IF (bdebugme )
    CALL echo ("*** No item to process for 373. ***" )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (formatlogmessage (smessage =vc ) =vc )
  DECLARE logmessage = vc WITH noconstant ("" ) ,private
  DECLARE eventmessage = vc WITH noconstant ("" ) ,private
  DECLARE encountermessage = vc WITH noconstant ("" ) ,private
  DECLARE locationmessage = vc WITH noconstant ("" ) ,private
  DECLARE physicianmessage = vc WITH noconstant ("" ) ,private
  SET eventmessage = concat ("[Current Event Type: " ,trim (uar_get_code_display (encntr_info->
     o_encntr_type_cd ) ,3 ) ," (" ,build (encntr_info->o_encntr_type_cd ) ,"), " ,
   "Order Event Type: " ,trim (uar_get_code_display (encntr_info->n_encntr_type_cd ) ,3 ) ," (" ,
   build (encntr_info->n_encntr_type_cd ) ,"), " ,"Current Event Date: " ,trim (format (encntr_info->
     current_event_dt_tm ,";;q" ) ,3 ) ,", " ,"Order Event Date: " ,trim (format (
     patient_event_request->patient_event[1 ].event_dt_tm ,";;q" ) ,3 ) ,"]" )
  SET encountermessage = concat ("[Encounter Type: " ,trim (uar_get_code_display (encntr_info->
     o_encntr_type_cd ) ,3 ) ," (" ,build (encntr_info->o_encntr_type_cd ) ,"), " ,
   "Encounter Reg Date: " ,trim (format (encntr_info->reg_dt_tm ,";;q" ) ,3 ) ,", " ,
   "Encounter PreReg Date: " ,trim (format (encntr_info->pre_reg_dt_tm ,";;q" ) ,3 ) ,", " ,
   "Encounter Inpat Date: " ,trim (format (encntr_info->inpatient_admit_dt_tm ,";;q" ) ,3 ) ,", " ,
   "Encounter Admit Date: " ,trim (format (encntr_info->admit_decision_dt_tm ,";;q" ) ,3 ) ,", " ,
   "Encounter Arrive Date: " ,trim (format (encntr_info->arrive_dt_tm ,";;q" ) ,3 ) ,", " ,
   "Encounter Discharge Date: " ,trim (format (encntr_info->disch_dt_tm ,";;q" ) ,3 ) ,", " ,"]" )
  SET locationmessage = concat ("[Current Location: " ,trim (uar_get_code_display (encntr_info->
     o_location_cd ) ,3 ) ," (" ,build (encntr_info->o_location_cd ) ,"), " ,"New Location: " ,trim (
    uar_get_code_display (encntr_info->n_location_cd ) ,3 ) ," (" ,build (encntr_info->n_location_cd
    ) ,"), " ,"Current Facility: " ,trim (uar_get_code_display (encntr_info->o_facility_cd ) ,3 ) ,
   " (" ,build (encntr_info->o_facility_cd ) ,"), " ,"New Facility: " ,trim (uar_get_code_display (
     encntr_info->n_facility_cd ) ,3 ) ," (" ,build (encntr_info->n_facility_cd ) ,"), " ,
   "Current Building: " ,trim (uar_get_code_display (encntr_info->o_building_cd ) ,3 ) ," (" ,build (
    encntr_info->o_building_cd ) ,"), " ,"New Building: " ,trim (uar_get_code_display (encntr_info->
     n_building_cd ) ,3 ) ," (" ,build (encntr_info->n_building_cd ) ,"), " ,"Current Nurse Unit: " ,
   trim (uar_get_code_display (encntr_info->o_nurse_unit_cd ) ,3 ) ," (" ,build (encntr_info->
    o_nurse_unit_cd ) ,"), " ,"New Nurse Unit: " ,trim (uar_get_code_display (encntr_info->
     n_nurse_unit_cd ) ,3 ) ," (" ,build (encntr_info->n_nurse_unit_cd ) ,"), " ,"Current Room: " ,
   trim (uar_get_code_display (encntr_info->o_room_cd ) ,3 ) ," (" ,build (encntr_info->o_room_cd ) ,
   "), " ,"New Room: " ,trim (uar_get_code_display (encntr_info->n_room_cd ) ,3 ) ," (" ,build (
    encntr_info->n_room_cd ) ,"), " ,"Current Bed: " ,trim (uar_get_code_display (encntr_info->
     o_bed_cd ) ,3 ) ," (" ,build (encntr_info->o_bed_cd ) ,"), " ,"New Bed: " ,trim (
    uar_get_code_display (encntr_info->n_bed_cd ) ,3 ) ," (" ,build (encntr_info->n_bed_cd ) ,"), " ,
   "]" )
  SET physicianmessage = concat ("[Current Admitting: " ,build (encntr_info->o_admit_p_id ) ,
   " Admitting EPR_ID: " ,build (encntr_info->o_admit_r_id ) ," New Admitting: " ,build (encntr_info
    ->n_admit_p_id ) ," Current Attending: " ,build (encntr_info->o_attend_p_id ) ,
   " Attending EPR_ID: " ,build (encntr_info->o_attend_r_id ) ," New Attending: " ,build (encntr_info
    ->n_attend_p_id ) ,"]" )
  SET logmessage = concat (smessage ," || " ,eventmessage ," || " ,encountermessage ," || " ,
   locationmessage ," || " ,physicianmessage )
  RETURN (logmessage )
 END ;Subroutine
 SUBROUTINE  cleanuphandles (null )
  IF (hrequest )
   CALL uar_srvdestroyinstance (hrequest )
  ENDIF
  IF (hreply )
   CALL uar_srvdestroyinstance (hreply )
  ENDIF
  IF (hmodencmsg )
   CALL uar_srvdestroymessage (hmodencmsg )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getorderaction (null )
  DECLARE dlastorderaction = f8 WITH noconstant (0.0 ) ,protect
  SELECT INTO "nl:"
   FROM (orders o ),
    (order_action oa )
   PLAN (o
    WHERE (o.order_id = trigger_orderid )
    AND (o.active_ind = 1 ) )
    JOIN (oa
    WHERE (oa.order_id = o.order_id ) )
   ORDER BY oa.action_sequence
   DETAIL
    dlastorderaction = oa.action_type_cd
   WITH nocounter
  ;end select
  RETURN (dlastorderaction )
 END ;Subroutine
#9999_exit_program
 ;001 call echorecord(order_info) ;001
 ;001 call echorecord(patient_event_request) ;001
 IF ((reply->status_data.status = "S" ) )
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL cleanuphandles (null )
END GO

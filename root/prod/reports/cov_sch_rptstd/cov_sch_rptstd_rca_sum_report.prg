/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/29/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sch_rptstd_rca_sum_report.prg
	Object name:		cov_sch_rptstd_rca_sum_report
	Request #:			2069
 
	Program purpose:	Provides data for Single Location Schedule Summary.
 
	Executing from:		Scheduling Appointment Book Reports
 
 	Special Notes:		Called by Scheduling Reports (schreportexe.exe).
 						Translated and customized from Cerner program
 						sch_rptstd_rca_summary_report.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	08/29/2018	Todd A. Blanchard		Added scheduled order details.
002	02/11/2021	Todd A. Blanchard		Adjusted logic for order details.
 
******************************************************************************/
 
DROP PROGRAM cov_sch_rptstd_rca_sum_report:dba GO
CREATE PROGRAM cov_sch_rptstd_rca_sum_report:dba
 DECLARE s_uar_crmbeginapp ((s_app = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmbegintask ((s_happ = i4 ) ,(s_task = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmbeginreq ((s_htask = i4 ) ,(s_param = i4 ) ,(s_req = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmperform ((s_hstep = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmendreq ((s_hstep = i4 (ref ) ) ) = null
 DECLARE s_uar_crmendtask ((s_htask = i4 (ref ) ) ) = null
 DECLARE s_uar_crmendapp ((s_happ = i4 (ref ) ) ) = null
 DECLARE s_uar_echo_object ((s_hobject = i4 ) ) = null
 DECLARE s_uar_crmgetrequest ((s_hstep = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmgetreply ((s_hstep = i4 ) ,(s_option = i4 ) ) = i4
 DECLARE s_uar_crmperformas ((s_hstep = i4 ) ,(s_option = i4 ) ,(s_service = vc ) ) = i4
 
 ;001
 DECLARE confirmed_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
 DECLARE checkedin_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CHECKEDIN"))
 DECLARE order_status_future_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
 DECLARE order_status_ordered_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
 DECLARE order_status_completed_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "COMPLETED"))
 DECLARE attach_type_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
 DECLARE attach_state_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 23012, "ACTIVE"))
 ;
 
 SUBROUTINE  s_uar_crmbeginapp (s_app ,s_option )
  DECLARE s_happ = i4 WITH protect ,noconstant (0 )
  DECLARE my_stat = i2 WITH protect ,noconstant (0 )
  SET my_stat = uar_crmbeginapp (s_app ,s_happ )
  IF (my_stat )
   CASE (s_option )
    OF 0 :
     SET table_name = build ("ERROR-->s_uar_crmbeginapp (" ,s_app ,"," ,s_option ,") returned [" ,
      my_stat ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("ERROR-->s_uar_crmbeginapp (" ,s_app ,"," ,s_option ,") returned [" ,my_stat ,
       "]" ) )
   ENDCASE
  ENDIF
  RETURN (s_happ )
 END ;Subroutine
 SUBROUTINE  s_uar_crmbegintask (s_happ ,s_task ,s_option )
  DECLARE s_htask = i4 WITH protect ,noconstant (0 )
  DECLARE my_stat = i2 WITH protect ,noconstant (0 )
  SET my_stat = uar_crmbegintask (s_happ ,s_task ,s_htask )
  IF (my_stat )
   CASE (s_option )
    OF 0 :
     SET table_name = build ("ERROR-->s_uar_crmbegintask (" ,s_happ ,"," ,s_task ,"," ,s_option ,
      ") returned [" ,my_stat ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("ERROR-->s_uar_crmbegintask (" ,s_happ ,"," ,s_task ,"," ,s_option ,
       ") returned [" ,my_stat ,"]" ) )
   ENDCASE
  ENDIF
  RETURN (s_htask )
 END ;Subroutine
 SUBROUTINE  s_uar_crmbeginreq (s_htask ,s_param ,s_req ,s_option )
  DECLARE s_hstep = i4 WITH protect ,noconstant (0 )
  DECLARE my_stat = i2 WITH protect ,noconstant (0 )
  SET my_stat = uar_crmbeginreq (s_htask ,s_param ,s_req ,s_hstep )
  IF (my_stat )
   CASE (s_option )
    OF 0 :
     SET table_name = build ("ERROR-->s_uar_crmbeginreq (" ,s_htask ,"," ,s_param ,"," ,s_req ,"," ,
      s_option ,") returned [" ,my_stat ,"]" )
     CALL echo (table_name )
     SET failed = uar_error
     GO TO exit_script
    OF 1 :
     CALL echo (build ("ERROR-->s_uar_crmbeginreq (" ,s_htask ,"," ,s_param ,"," ,s_req ,"," ,
       s_option ,") returned [" ,my_stat ,"]" ) )
   ENDCASE
  ENDIF
  RETURN (s_hstep )
 END ;Subroutine
 SUBROUTINE  s_uar_crmperform (s_hstep ,s_option )
  IF ((s_hstep > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmperform (s_hstep )
   IF (my_stat )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmperform (" ,s_hstep ,"," ,s_option ,") returned [" ,
       my_stat ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmperform (" ,s_hstep ,"," ,s_option ,") returned [" ,
        my_stat ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (my_stat )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmperformas (s_hstep ,s_option ,s_service )
  IF ((s_hstep > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmperformas (s_hstep ,s_service )
   IF (my_stat )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmperformas (" ,s_hstep ,"," ,s_option ,") returned ["
       ,my_stat ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmperformas (" ,s_hstep ,"," ,s_option ,") returned [" ,
        my_stat ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (my_stat )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmgetrequest (s_hstep ,s_option )
  IF ((s_hstep > 0 ) )
   DECLARE s_hrequest = i4 WITH protect ,noconstant (0 )
   SET s_hrequest = uar_crmgetrequest (s_hstep )
   IF ((s_hrequest = 0 ) )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmgetrequest (" ,s_hstep ,"," ,s_option ,
       ") returned [" ,s_hrequest ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmgetrequest (" ,s_hstep ,"," ,s_option ,") returned [" ,
        s_hrequest ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (s_hrequest )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmgetreply (s_hstep ,s_option )
  IF ((s_hstep > 0 ) )
   DECLARE s_hreply = i4 WITH protect ,noconstant (0 )
   SET s_hreply = uar_crmgetreply (s_hstep )
   IF ((s_hreply = 0 ) )
    CASE (s_option )
     OF 0 :
      SET table_name = build ("ERROR-->s_uar_crmgetreply (" ,s_hstep ,"," ,s_option ,") returned [" ,
       s_hreply ,"]" )
      CALL echo (table_name )
      SET failed = uar_error
      GO TO exit_script
     OF 1 :
      CALL echo (build ("ERROR-->s_uar_crmgetreply (" ,s_hstep ,"," ,s_option ,") returned [" ,
        s_hreply ,"]" ) )
    ENDCASE
   ENDIF
   RETURN (s_hreply )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmendreq (s_hstep )
  IF ((s_hstep > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmendreq (s_hstep )
   SET s_hstep = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmendtask (s_htask )
  IF ((s_htask > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmendtask (s_htask )
   SET s_htask = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_crmendapp (s_happ )
  IF ((s_happ > 0 ) )
   DECLARE my_stat = i2 WITH protect ,noconstant (0 )
   SET my_stat = uar_crmendapp (s_happ )
   SET s_happ = 0
  ENDIF
 END ;Subroutine
 SUBROUTINE  s_uar_echo_object (s_hobject )
  IF ((s_hobject > 0 ) )
   CALL uar_oen_dump_object (s_hobject )
  ENDIF
 END ;Subroutine
 IF (NOT (validate (get_locgroup_exp_request ,0 ) ) )
  RECORD get_locgroup_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 sch_object_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_locgroup_exp_reply ,0 ) ) )
  RECORD get_locgroup_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 sch_object_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 location_cd = f8
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_request ,0 ) ) )
  RECORD get_res_group_exp_request (
    1 security_ind = i2
    1 call_echo_ind = i2
    1 qual [* ]
      2 res_group_id = f8
      2 duplicate_ind = i2
  )
 ENDIF
 IF (NOT (validate (get_res_group_exp_reply ,0 ) ) )
  RECORD get_res_group_exp_reply (
    1 qual_cnt = i4
    1 qual [* ]
      2 res_group_id = f8
      2 qual_cnt = i4
      2 qual [* ]
        3 resource_cd = f8
        3 mnemonic = vc
        3 description = vc
        3 quota = i4
        3 person_id = f8
        3 id_disp = vc
        3 res_type_flag = i2
        3 active_ind = i2
  )
 ENDIF
 FREE SET t_record
 RECORD t_record (
   1 resource_cd = f8
   1 location_cd = f8
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 locgroup_id = f8
   1 res_group_id = f8
   1 location_qual_cnt = i4
   1 location_qual [* ]
     2 location_cd = f8
   1 resource_qual_cnt = i4
   1 resource_qual [* ]
     2 resource_cd = f8
     2 person_id = f8
 )
 IF ((request->call_echo_ind = 1 ) )
  CALL echorecord (request )
 ENDIF
 FOR (i_input = 1 TO size (request->qual ,5 ) )
  CASE (trim (request->qual[i_input ].oe_field_meaning ) )
   OF "RESOURCE" :
    SET t_record->resource_cd = request->qual[i_input ].oe_field_value
   OF "BEGDTTM" :
    SET t_record->beg_dt_tm = request->qual[i_input ].oe_field_dt_tm_value
   OF "ENDDTTM" :
    SET t_record->end_dt_tm = request->qual[i_input ].oe_field_dt_tm_value
   OF "RESGROUP" :
    SET t_record->res_group_id = request->qual[i_input ].oe_field_value
   OF "LOCATION" :
    SET t_record->location_cd = request->qual[i_input ].oe_field_value
   OF "LOCGROUP" :
    SET t_record->locgroup_id = request->qual[i_input ].oe_field_value
  ENDCASE
 ENDFOR
 DECLARE script_name = vc WITH protect ,constant ("sch_rpt_rca_loc_res_appt_list" )
 DECLARE dash_line = c129 WITH public ,constant (fillstring (128 ,"-" ) )
 DECLARE happ = i4 WITH protect ,noconstant (0 )
 DECLARE htask = i4 WITH protect ,noconstant (0 )
 DECLARE hstep = i4 WITH protect ,noconstant (0 )
 DECLARE hreply = i4 WITH protect ,noconstant (0 )
 DECLARE hrequest = i4 WITH protect ,noconstant (0 )
 DECLARE hqual = i4 WITH protect ,noconstant (0 )
 DECLARE hschedqual = i4 WITH protect ,noconstant (0 )
 DECLARE happtqual = i4 WITH protect ,noconstant (0 )
 DECLARE lexpandcount = i4 WITH noconstant (0 )
 DECLARE pos = i4 WITH noconstant (0 ) ,public
 DECLARE num = i4 WITH noconstant (0 ) ,public
 FREE SET t_reply
 RECORD t_reply (
   1 reply [* ]
     2 resourcecd = f8
     2 locationcd = f8
     2 resourcename = vc
     2 appointmentdate = dq8
     2 appointmentdur = i4
     2 appointmentlocation = vc
     2 appointmenttype = vc
     2 visitreason = vc
     2 appointmentstatus = vc
     2 appointmentcomment = vc
     2 encounternumber = vc
     2 referringphysician = vc
     2 primaryinsurancepayer = vc
     2 primaryinsurancehealthplan = vc
     2 patientname = vc
     2 patientdateofbirth = vc
     2 patientage = vc
     2 birthtz = i4
     2 mrn = vc
     2 patientgender = vc
     2 patienthomephone = vc
     2 patientworkphone = vc
     2 patientworkext = vc
     2 patientmobliephone = vc
     2 datelong = i4
     2 personid = f8
 
     ;001
     2 procedures[*]
		3	order_id				= f8
		3	order_mnemonic			= c75
     ;
 )
 IF ((t_record->locgroup_id > 0 ) )
  SET get_locgroup_exp_request->call_echo_ind = 0
  SET get_locgroup_exp_request->security_ind = 1
  SET get_locgroup_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_locgroup_exp_request->qual ,get_locgroup_exp_reply->qual_cnt )
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt ].sch_object_id = t_record->
  locgroup_id
  SET get_locgroup_exp_request->qual[get_locgroup_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_locgroup_exp
  FOR (i_input = 1 TO get_locgroup_exp_reply->qual_cnt )
   SET t_record->location_qual_cnt = get_locgroup_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->location_qual ,t_record->location_qual_cnt )
   FOR (j_input = 1 TO t_record->location_qual_cnt )
    SET t_record->location_qual[j_input ].location_cd = get_locgroup_exp_reply->qual[i_input ].qual[
    j_input ].location_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->location_qual_cnt = 0
  IF ((t_record->location_cd > 0 ) )
   SET t_record->location_qual_cnt = 1
   SET stat = alterlist (t_record->location_qual ,t_record->location_qual_cnt )
   SET t_record->location_qual[1 ].location_cd = t_record->location_cd
  ENDIF
 ENDIF
 IF ((t_record->res_group_id > 0 ) )
  SET get_res_group_exp_request->call_echo_ind = 0
  SET get_res_group_exp_request->security_ind = 1
  SET get_res_group_exp_reply->qual_cnt = 1
  SET stat = alterlist (get_res_group_exp_request->qual ,get_res_group_exp_reply->qual_cnt )
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt ].res_group_id = t_record->
  res_group_id
  SET get_res_group_exp_request->qual[get_res_group_exp_reply->qual_cnt ].duplicate_ind = 1
  EXECUTE sch_get_res_group_exp
  FOR (i_input = 1 TO get_res_group_exp_reply->qual_cnt )
   SET t_record->resource_qual_cnt = get_res_group_exp_reply->qual[i_input ].qual_cnt
   SET stat = alterlist (t_record->resource_qual ,t_record->resource_qual_cnt )
   FOR (j_input = 1 TO t_record->resource_qual_cnt )
    SET t_record->resource_qual[j_input ].resource_cd = get_res_group_exp_reply->qual[i_input ].qual[
    j_input ].resource_cd
   ENDFOR
  ENDFOR
 ELSE
  SET t_record->resource_qual_cnt = 0
  IF ((t_record->resource_cd > 0 ) )
   SET t_record->resource_qual_cnt = 1
   SET stat = alterlist (t_record->resource_qual ,t_record->resource_qual_cnt )
   SET t_record->resource_qual[1 ].resource_cd = t_record->resource_cd
  ENDIF
 ENDIF
 EXECUTE crmrtl
 EXECUTE srvrtl
 SET crmstatus = uar_crmbeginapp (5000 ,happ )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Begin app failed with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Begin app(130000) failed with status: " ,cnvtstring (crmstatus ) )
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask (happ ,3202004 ,htask )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Begin task failed with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Begin task(130001) failed with status: " ,cnvtstring (crmstatus ) )
  SET stat = uar_crmendapp (happ )
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbeginreq (htask ,"" ,650942 ,hstep )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Begin req failed with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Begin req(650942) failed with status: " ,cnvtstring (crmstatus ) )
  SET stat = uar_crmendtask (htask )
  SET stat = uar_crmendapp (happ )
  GO TO exit_script
 ENDIF
 SET hrequest = uar_crmgetrequest (hstep )
 FOR (i_loc = 1 TO t_record->location_qual_cnt )
  SET hqual = uar_srvadditem (hrequest ,"locations" )
  SET stat = uar_srvsetdouble (hqual ,"location_cd" ,t_record->location_qual[i_loc ].location_cd )
 ENDFOR
 FOR (i_res = 1 TO t_record->resource_qual_cnt )
  SET hqual = uar_srvadditem (hrequest ,"resources" )
  SET stat = uar_srvsetdouble (hqual ,"resource_cd" ,t_record->resource_qual[i_res ].resource_cd )
 ENDFOR
 SET stat = uar_srvsetdate (hrequest ,"beg_dt_tm" ,cnvtdatetime (t_record->beg_dt_tm ) )
 SET stat = uar_srvsetdate (hrequest ,"end_dt_tm" ,cnvtdatetime (t_record->end_dt_tm ) )
 SET crmstatus = uar_crmperform (hstep )
 IF (crmstatus )
  IF (request->call_echo_ind )
   CALL echo (concat ("Perform failed(650942) with status: " ,cnvtstring (crmstatus ) ) )
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = concat (
   "Perform failed with status: " ,cnvtstring (crmstatus ) )
  SET stat = uar_crmendreq (hstep )
  SET stat = uar_crmendtask (htask )
  SET stat = uar_crmendapp (happ )
  GO TO exit_script
 ENDIF
 SET hreply = uar_crmgetreply (hstep )
 SET reply_cnt = uar_srvgetitemcount (hreply ,"report_summary" )
 SET stat = alterlist (t_reply->reply ,reply_cnt )
 FOR (reply_idx = 0 TO (reply_cnt - 1 ) )
  SET replyitem = (reply_idx + 1 )
  SET hreport_details = uar_srvgetitem (hreply ,"report_summary" ,reply_idx )
  SET t_reply->reply[replyitem ].resourcename = uar_srvgetstringptr (hreport_details ,
   "resource_Name" )
  SET stat = uar_srvgetdate (hreport_details ,"appointment_Date" ,t_reply->reply[replyitem ].
   appointmentdate )
  SET t_reply->reply[replyitem ].appointmentdur = uar_srvgetlong (hreport_details ,"appointment_Dur"
   )
  SET t_reply->reply[replyitem ].appointmentlocation = uar_srvgetstringptr (hreport_details ,
   "appointment_Location" )
  SET t_reply->reply[replyitem ].appointmenttype = uar_srvgetstringptr (hreport_details ,
   "appointment_Type" )
  SET t_reply->reply[replyitem ].visitreason = uar_srvgetstringptr (hreport_details ,"visit_Reason"
   )
  SET t_reply->reply[replyitem ].appointmentstatus = uar_srvgetstringptr (hreport_details ,
   "appointment_Status" )
  SET t_reply->reply[replyitem ].appointmentcomment = uar_srvgetstringptr (hreport_details ,
   "appointment_Comment" )
  SET t_reply->reply[replyitem ].encounternumber = uar_srvgetstringptr (hreport_details ,
   "encounter_Number" )
  SET t_reply->reply[replyitem ].referringphysician = uar_srvgetstringptr (hreport_details ,
   "referring_Physician" )
  SET t_reply->reply[replyitem ].primaryinsurancepayer = uar_srvgetstringptr (hreport_details ,
   "primary_Insurance_Payer" )
  SET t_reply->reply[replyitem ].patientname = uar_srvgetstringptr (hreport_details ,"patient_Name"
   )
  SET t_reply->reply[replyitem ].personid = uar_srvgetdouble (hreport_details ,"personId" )
  SET t_reply->reply[replyitem ].patientdateofbirth = uar_srvgetstringptr (hreport_details ,
   "patient_Date_Of_Birth" )
  SET t_reply->reply[replyitem ].patientage = uar_srvgetstringptr (hreport_details ,"patient_Age" )
  SET t_reply->reply[replyitem ].birthtz = uar_srvgetlong (hreport_details ,"birth_Tz" )
  SET t_reply->reply[replyitem ].mrn = uar_srvgetstringptr (hreport_details ,"mrn" )
  SET t_reply->reply[replyitem ].patientgender = uar_srvgetstringptr (hreport_details ,
   "patient_Gender" )
  SET t_reply->reply[replyitem ].patienthomephone = uar_srvgetstringptr (hreport_details ,
   "patient_Home_Phone" )
  SET t_reply->reply[replyitem ].patientworkphone = uar_srvgetstringptr (hreport_details ,
   "patient_Work_Phone" )
  SET t_reply->reply[replyitem ].patientworkext = uar_srvgetstringptr (hreport_details ,
   "patient_Work_Ext" )
  SET t_reply->reply[replyitem ].patientmobliephone = uar_srvgetstringptr (hreport_details ,
   "patient_Moblie_Phone" )
  SET t_reply->reply[replyitem ].resourcecd = uar_srvgetdouble (hreport_details ,"resourceCd" )
  SET t_reply->reply[replyitem ].locationcd = uar_srvgetdouble (hreport_details ,"locationCd" )
  SET t_reply->reply[replyitem ].datelong = cnvtdate (cnvtdatetime (t_reply->reply[replyitem ].
    appointmentdate ) )
 ENDFOR
 SET stat = uar_crmendreq (hstep )
 SET stat = uar_crmendtask (htask )
 SET stat = uar_crmendapp (happ )
 ; get person data ;001
 SELECT INTO "nl:"
  FROM (person p )
  WHERE expand (lexpandcount ,1 ,reply_cnt ,p.person_id ,t_reply->reply[lexpandcount ].personid )
  DETAIL
   pos = locateval (num ,1 ,size (t_reply->reply ,5 ) ,p.person_id ,t_reply->reply[num ].personid ) ,
   WHILE ((pos > 0 ) )
    IF ((p.abs_birth_dt_tm != null ) ) t_reply->reply[pos ].patientdateofbirth = format (p
      .abs_birth_dt_tm ,";4;D" )
    ENDIF
    ,pos = locateval (num ,(pos + 1 ) ,size (t_reply->reply ,5 ) ,p.person_id ,t_reply->reply[num ].
     personid )
   ENDWHILE
  WITH nocounter
 ;end select
 
 
 ; get order data ;001
 SELECT INTO "nl:"
 FROM
	SCH_APPT sa
 
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, checkedin_var)
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.sch_state_cd = attach_state_var
		and sea.order_status_cd in (
			order_status_future_var
			, order_status_ordered_var
			, order_status_completed_var
		)
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
 WHERE
	sa.beg_dt_tm between cnvtdatetime(t_record->beg_dt_tm) and cnvtdatetime(t_record->end_dt_tm)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
	and expand (lexpandcount ,1 ,reply_cnt ,
	  	sa.person_id ,t_reply->reply[lexpandcount ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[lexpandcount ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[lexpandcount ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[lexpandcount ].appointmentdate
  	)
 
 
 head sa.person_id
 	null ;002
 
 head sa.appt_location_cd
 	null ;002
 
 head sar.resource_cd
 	null ;002
 	
 head sev.appt_type_cd ;002
 	null ;002
 	
 head sa.beg_dt_tm
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(t_reply->reply, 5),
	  	sa.person_id ,t_reply->reply[numx ].personid ,
	  	sa.appt_location_cd ,t_reply->reply[numx ].locationcd ,
	  	sar.resource_cd ,t_reply->reply[numx ].resourcecd ,
	  	sa.beg_dt_tm ,t_reply->reply[numx ].appointmentdate ,
	  	uar_get_code_display(sev.appt_type_cd) ,t_reply->reply[numx ].appointmenttype ;002
	)
 
 detail
	if (idx > 0)
;		if (cnvtdate(o.current_start_dt_tm) = cnvtdate(t_reply->reply[idx].appointmentdate)) ;002
		if (o.current_start_dt_tm = sa.beg_dt_tm) ;002
			cntx = cntx + 1
 
			call alterlist(t_reply->reply[idx].procedures, cntx) ;002
 
			t_reply->reply[idx].procedures[cntx].order_id = nullval(o.order_id, 0.0)
			t_reply->reply[idx].procedures[cntx].order_mnemonic = nullval(trim(o.order_mnemonic, 3), " ")
		endif
	endif
 
 WITH nocounter, expand = 1
 ;end select
 
 
 IF ((t_record->resource_qual_cnt > 0 ) )
  SELECT INTO  $1
   begdateformatted = t_reply->reply[d.seq ].datelong ,
   location = t_reply->reply[d.seq ].appointmentlocation ,
   locationcd = t_reply->reply[d.seq ].locationcd ,
   resource = t_reply->reply[d.seq ].resourcename ,
   resourcecd = t_reply->reply[d.seq ].resourcecd ,
   begdate = t_reply->reply[reply_idx ].appointmentdate ,
   appttime = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" )
   FROM (dummyt d WITH seq = value (reply_cnt ) )
   PLAN (d
    WHERE (d.seq <= value (reply_cnt ) ) )
   ORDER BY begdateformatted ,
    resource ,
    resourcecd ,
    location ,
    locationcd
   HEAD REPORT
    generic_ind = 0 ,
    y_pos = 0 ,
    row 0 ,
    breakpage = 1
   HEAD PAGE
    CALL print ("{PS/792 0 translate 90 rotate/}" )
   HEAD begdateformatted
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD location
    null
   HEAD locationcd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD resourcecd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   DETAIL
    IF ((breakpage = 1 ) ) breakpage = 0 ,row 0 ,row + 1 ,"{F/0}{CPI/9}{LPI/5}" ,
     CALL print (calcpos (261 ,36 ) ) ,"{B}R E S O U R C E   S C H E D U L E{ENDB}" ,row + 1 ,row +
     1 ,"{F/0}{CPI/15}{LPI/5}" ,"{POS/702/54}Page " ,curpage "###" ,"{F/0}{CPI/11}{LPI/6}" ,
     "{POS/36/54}{B}Location: {ENDB}" ,t_reply->reply[d.seq ].appointmentlocation ,row + 1 ,
     "{POS/36/67}{B}Resource: {ENDB}" ,t_reply->reply[d.seq ].resourcename ,row + 1 ,datestring =
     format (t_reply->reply[d.seq ].appointmentdate ,"MM/DD/YYYY;;Q" ) ,"{POS/36/80}{B}Date: {ENDB}"
    ,datestring ,row + 1 ,
     CALL print (calcpos (36 ,93 ) ) ,"{B}Time" ,
     CALL print (calcpos (72 ,93 ) ) ,"Dur" ,
     CALL print (calcpos (144 ,93 ) ) ,"Name" ,
     CALL print (calcpos (360 ,93 ) ) ,"Appointment Type" ,
     CALL print (calcpos (540 ,93 ) ) ,"Visit Reason" ,
     CALL print (calcpos (684 ,93 ) ) ,"Status  {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,106 ) ) ,"{B}MRN" ,
     CALL print (calcpos (144 ,106 ) ) ,"DOB" ,
     CALL print (calcpos (216 ,106 ) ) ,"Age" ,
     CALL print (calcpos (270 ,106 ) ) ,"Sex" ,
     CALL print (calcpos (360 ,106 ) ) ,"Encounter" ,
     CALL print (calcpos (540 ,106 ) ) ,"Referring Physician {ENDB}" ,row + 1 ,
     CALL print (calcpos (360 ,119 ) ) ,"{B}Order {ENDB}" ,row + 1 , ;001
     CALL print (calcpos (36 ,120 ) ) ,"{B}{REPEAT/110/_/}{ENDB}" ,row + 1 ,y_pos = 133 ,row + 1
    ENDIF
    ,row + 1 ,
    "{F/4}{CPI/15}{LPI/6}" ,
    datestring = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" ) ,
    CALL print (calcpos (36 ,y_pos ) ) ,
    datestring ,
    CALL print (calcpos (72 ,y_pos ) ) ,
    t_reply->reply[d.seq ].appointmentdur "####" ,
    IF ((size (t_reply->reply[d.seq ].patientname ) > 60 ) ) field60 = substring (1 ,60 ,t_reply->
      reply[d.seq ].patientname ) ,
     CALL print (calcpos (144 ,y_pos ) ) ,field60
    ELSE
     CALL print (calcpos (144 ,y_pos ) ) ,t_reply->reply[d.seq ].patientname
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmenttype ) > 36 ) ) field36 = substring (1 ,36 ,t_reply
      ->reply[d.seq ].appointmenttype ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field36
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmenttype
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].visitreason ) > 30 ) ) field30 = substring (1 ,30 ,t_reply->
      reply[d.seq ].visitreason ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].visitreason
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmentstatus ) > 30 ) ) field30 = substring (1 ,30 ,
      t_reply->reply[d.seq ].appointmentstatus ) ,
     CALL print (calcpos (684 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (684 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentstatus
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].mrn ) > 15 ) ) field15 = substring (1 ,15 ,t_reply->reply[d
      .seq ].mrn ) ,
     CALL print (calcpos (36 ,y_pos ) ) ,field15
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].mrn
    ENDIF
    ,
    CALL print (calcpos (144 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientdateofbirth ,
    CALL print (calcpos (216 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientage ,
    CALL print (calcpos (270 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientgender ,
    IF ((size (t_reply->reply[d.seq ].encounternumber ) > 30 ) ) field30 = substring (1 ,30 ,t_reply
      ->reply[d.seq ].encounternumber ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].encounternumber
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].referringphysician ) > 45 ) ) field22 = substring (1 ,45 ,
      t_reply->reply[d.seq ].referringphysician ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].referringphysician
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
 
    ;001
    fieldOrder = fillstring(75, " ")
    ocnt = size (t_reply->reply[d.seq ].procedures, 5)
 
    for(i = 1 to ocnt)
	    IF (t_reply->reply[d.seq ].procedures[i].order_id > 0.0)
	    	fieldOrder = substring(1, 100, t_reply->reply[d.seq ].procedures[i].order_mnemonic)
	     CALL print (calcpos (360 ,y_pos ) ) ,fieldOrder
	    ENDIF
 
	    y_pos = (y_pos + 13 )
    endfor
    ;
 
    ,y_pos = (y_pos + 26 ) ,
    row + 2 ,
    IF ((y_pos > 527 ) )
     CALL print (calcpos (350 ,y_pos ) ) ,"*** To be continued ***" ,breakpage = 1 ,
     BREAK,row 0
    ENDIF
   WITH nullreport ,dio = postscript ,landscape ,nocounter ,maxcol = 220 ,formfeed = post
  ;end select
 ELSE
  SELECT INTO  $1
   begdateformatted = t_reply->reply[d.seq ].datelong ,
   location = t_reply->reply[d.seq ].appointmentlocation ,
   locationcd = t_reply->reply[d.seq ].locationcd ,
   resource = t_reply->reply[d.seq ].resourcename ,
   resourcecd = t_reply->reply[d.seq ].resourcecd ,
   begdate = t_reply->reply[reply_idx ].appointmentdate ,
   appttime = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" )
   FROM (dummyt d WITH seq = value (reply_cnt ) )
   PLAN (d
    WHERE (d.seq <= value (reply_cnt ) ) )
   ORDER BY begdateformatted ,
    location ,
    locationcd ,
    resource ,
    resourcecd
   HEAD REPORT
    generic_ind = 0 ,
    y_pos = 0 ,
    row 0 ,
    breakpage = 1
   HEAD PAGE
    CALL print ("{PS/792 0 translate 90 rotate/}" )
   HEAD begdateformatted
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD location
    null
   HEAD locationcd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   HEAD resourcecd
    IF ((breakpage = 0 ) ) row 0 ,breakpage = 1 ,
     BREAK
    ENDIF
   DETAIL
    IF ((breakpage = 1 ) ) breakpage = 0 ,row 0 ,row + 1 ,"{F/0}{CPI/9}{LPI/5}" ,
     CALL print (calcpos (261 ,36 ) ) ,"{B}R E S O U R C E   S C H E D U L E{ENDB}" ,row + 1 ,row +
     1 ,"{F/0}{CPI/15}{LPI/5}" ,"{POS/702/54}Page " ,curpage "###" ,"{F/0}{CPI/11}{LPI/6}" ,
     "{POS/36/54}{B}Location: {ENDB}" ,t_reply->reply[d.seq ].appointmentlocation ,row + 1 ,
     "{POS/36/67}{B}Resource: {ENDB}" ,t_reply->reply[d.seq ].resourcename ,row + 1 ,datestring =
     format (t_reply->reply[d.seq ].appointmentdate ,"MM/DD/YYYY;;Q" ) ,"{POS/36/80}{B}Date: {ENDB}"
    ,datestring ,row + 1 ,
     CALL print (calcpos (36 ,93 ) ) ,"{B}Time" ,
     CALL print (calcpos (72 ,93 ) ) ,"Dur" ,
     CALL print (calcpos (144 ,93 ) ) ,"Name" ,
     CALL print (calcpos (360 ,93 ) ) ,"Appointment Type" ,
     CALL print (calcpos (540 ,93 ) ) ,"Visit Reason" ,
     CALL print (calcpos (684 ,93 ) ) ,"Status  {ENDB}" ,row + 1 ,
     CALL print (calcpos (36 ,106 ) ) ,"{B}MRN" ,
     CALL print (calcpos (144 ,106 ) ) ,"DOB" ,
     CALL print (calcpos (216 ,106 ) ) ,"Age" ,
     CALL print (calcpos (270 ,106 ) ) ,"Sex" ,
     CALL print (calcpos (360 ,106 ) ) ,"Encounter" ,
     CALL print (calcpos (540 ,106 ) ) ,"Referring Physician {ENDB}" ,row + 1 ,
     CALL print (calcpos (360 ,119 ) ) ,"{B}Order {ENDB}" ,row + 1 , ;001
     CALL print (calcpos (36 ,120 ) ) ,"{B}{REPEAT/110/_/}{ENDB}" ,row + 1 ,y_pos = 133 ,row + 1
    ENDIF
    ,row + 1 ,
    "{F/4}{CPI/15}{LPI/6}" ,
    datestring = format (t_reply->reply[d.seq ].appointmentdate ,"hh:MM;;S" ) ,
    CALL print (calcpos (36 ,y_pos ) ) ,
    datestring ,
    CALL print (calcpos (72 ,y_pos ) ) ,
    t_reply->reply[d.seq ].appointmentdur "####" ,
    IF ((size (t_reply->reply[d.seq ].patientname ) > 60 ) ) field60 = substring (1 ,60 ,t_reply->
      reply[d.seq ].patientname ) ,
     CALL print (calcpos (144 ,y_pos ) ) ,field60
    ELSE
     CALL print (calcpos (144 ,y_pos ) ) ,t_reply->reply[d.seq ].patientname
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmenttype ) > 36 ) ) field36 = substring (1 ,36 ,t_reply
      ->reply[d.seq ].appointmenttype ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field36
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmenttype
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].visitreason ) > 30 ) ) field30 = substring (1 ,30 ,t_reply->
      reply[d.seq ].visitreason ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].visitreason
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].appointmentstatus ) > 30 ) ) field30 = substring (1 ,30 ,
      t_reply->reply[d.seq ].appointmentstatus ) ,
     CALL print (calcpos (684 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (684 ,y_pos ) ) ,t_reply->reply[d.seq ].appointmentstatus
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
    IF ((size (t_reply->reply[d.seq ].mrn ) > 15 ) ) field15 = substring (1 ,15 ,t_reply->reply[d
      .seq ].mrn ) ,
     CALL print (calcpos (36 ,y_pos ) ) ,field15
    ELSE
     CALL print (calcpos (36 ,y_pos ) ) ,t_reply->reply[d.seq ].mrn
    ENDIF
    ,
    CALL print (calcpos (144 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientdateofbirth ,
    CALL print (calcpos (216 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientage ,
    CALL print (calcpos (270 ,y_pos ) ) ,
    t_reply->reply[d.seq ].patientgender ,
    IF ((size (t_reply->reply[d.seq ].encounternumber ) > 30 ) ) field30 = substring (1 ,30 ,t_reply
      ->reply[d.seq ].encounternumber ) ,
     CALL print (calcpos (360 ,y_pos ) ) ,field30
    ELSE
     CALL print (calcpos (360 ,y_pos ) ) ,t_reply->reply[d.seq ].encounternumber
    ENDIF
    ,
    IF ((size (t_reply->reply[d.seq ].referringphysician ) > 45 ) ) field22 = substring (1 ,45 ,
      t_reply->reply[d.seq ].referringphysician ) ,
     CALL print (calcpos (540 ,y_pos ) ) ,field22
    ELSE
     CALL print (calcpos (540 ,y_pos ) ) ,t_reply->reply[d.seq ].referringphysician
    ENDIF
    ,row + 1 ,
    y_pos = (y_pos + 13 ) ,
 
    ;001
    fieldOrder = fillstring(75, " ")
    ocnt = size (t_reply->reply[d.seq ].procedures, 5)
 
    for(i = 1 to ocnt)
	    IF (t_reply->reply[d.seq ].procedures[i].order_id > 0.0)
	    	fieldOrder = substring(1, 100, t_reply->reply[d.seq ].procedures[i].order_mnemonic)
	     CALL print (calcpos (360 ,y_pos ) ) ,fieldOrder
	    ENDIF
 
	    y_pos = (y_pos + 13 )
    endfor
    ;
 
    ,y_pos = (y_pos + 26 ) ,
    row + 2 ,
    IF ((y_pos > 527 ) )
     CALL print (calcpos (350 ,y_pos ) ) ,"*** To be continued ***" ,breakpage = 1 ,
     BREAK,row 0
    ENDIF
   WITH nullreport ,dio = postscript ,landscape ,nocounter ,maxcol = 270 ,formfeed = post
  ;end select
 ENDIF
#exit_script
END GO
 

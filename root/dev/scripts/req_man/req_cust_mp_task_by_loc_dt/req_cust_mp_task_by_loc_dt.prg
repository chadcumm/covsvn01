/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   req_cust_mp_task_by_loc_dt.prg
  Object name:        req_cust_mp_task_by_loc_dt
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/20/2020  Chad Cummings			REMOVE OR UPDATE AFTER POC
001   12/01/2020  Chad Cummings			Updated to return CEID
******************************************************************************/
DROP PROGRAM req_cust_mp_task_by_loc_dt GO
CREATE PROGRAM req_cust_mp_task_by_loc_dt
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "User ID:" = 0.0 ,
  "Position Cd:" = 0.0 ,
  "Start Date:" = "" ,
  "End Date:" = "" ,
  "Ignore Limit:" = "" ,
  "Encounter Only:" = "" ,
  "Location:" = 0.0
  WITH outdev ,user_id ,position_cd ,start_dt ,end_dt ,loc_prompt
  
call echo(build("loading script:",curprog))
declare nologvar = i2 with noconstant(1)	;do not create log = 1		, create log = 0
declare debug_ind = i2 with noconstant(0)	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
declare rec_to_file = i2 with noconstant(0)

select into "nl:"
from
	 code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "PRINTTOPDF"
	and   cvs.code_set > 0.0
join cv
	where cv.code_set = cvs.code_set
	and   cv.active_ind 	= 1
	and   cv.cdf_meaning	= "LOGGING"
order by
	 cv.begin_effective_dt_tm desc
	,cv.cdf_meaning
head report
	stat = 0
head cv.cdf_meaning
	if (cnvtint(cv.definition) > 0)
		rec_to_file = 1
		nologvar = 0
	endif
with nocounter

%i cust_script:bc_play_routines.inc
%i cust_script:bc_play_req.inc
%i cust_script:req_cust_mp_task_by_loc_dt.inc

call bc_custom_code_set(0)

FREE RECORD record_data
RECORD record_data (
  1 date_used = i2
  1 document_start_date = dq8
  1 document_end_date = dq8
  1 start_check = vc
  1 end_check = vc
  1 task_info_text = vc
  1 allow_req_print = i2
  1 labreq_prg = vc
  1 autolog_spec_ind = i2
  1 lock_chart_access = i2
  1 label_print_type = vc
  1 label_print_auto_off = vc
  1 allow_depart = i2
  1 depart_label = vc
  1 adv_print_ind = i2
  1 adv_print_codeset = f8
  1 form_ind = i2
  1 formslist [* ]
    2 form_id = f8
    2 form_name = vc
  1 tlist [* ]
    2 person_id = f8
    2 encounter_id = f8
    2 person_name = vc
    2 gender = vc
    2 gender_char = vc
    2 dob = vc
    2 age = vc
    2 task_type = vc
    2 task_id = f8
    2 task_type_ind = i2
    2 task_describ = vc
    2 task_display = vc
    2 task_prn_ind = i2
    2 task_date = vc
    2 task_overdue = i2
    2 task_time = vc
    2 task_dt_tm_num = dq8
    2 task_dt_tm_utc = vc
    2 task_form_id = f8
    2 charge_ind = i2
    2 task_status = vc
    2 clerk_status = vc
    2 display_status = vc
    2 inprocess_ind = i2
    2 order_id = vc
    2 order_id_real = f8
    2 ordered_as_name = vc
    2 order_cdl = vc
    2 orig_order_dt = vc
    2 order_dt_tm_utc = vc
    2 ordering_provider = vc
    2 ord_comment = vc
    2 task_note = vc
    2 task_resched_time = i2
    2 can_chart_ind = i2
    2 visit_loc = vc
    2 visit_date = vc
    2 visit_date_display = vc
    2 visit_dt_tm_num = dq8
    2 visit_dt_utc = vc
    2 charted_by = vc
    2 charted_dt = vc
    2 charted_dt_utc = vc
    2 not_done = i2
    2 result_set_id = f8
    2 not_done_reason = vc
    2 not_done_reason_comm = vc
    2 status_reason_cd = f8
    2 powerplan_ind = i2
    2 powerplan_name = vc
    2 event_id = f8
    2 normal_ref_range_txt = vc
    2 requisition_format_cd = f8
    2 dfac_activity_id = f8
    2 olist [* ]
      3 order_name = vc
      3 ordering_prov = vc
      3 order_id = f8
      3 dlist [* ]
        4 rank_seq = vc
        4 diag = vc
        4 code = vc
    2 dlist [* ]
      3 rank_seq = vc
      3 diag = vc
      3 code = vc
    2 asc_num = vc
    2 contain_list [* ]
      3 contain_sent = vc
      3 task_id = f8
    2 order_cnt = i2
    2 abn_track_ids = vc
    2 abn_list [* ]
      3 order_disp = vc
      3 alert_date = vc
      3 alert_state = vc
  1 status_list [* ]
    2 status = vc
    2 selected = i2
  1 cler_status_list [* ]
    2 status = vc
    2 selected = i2
  1 type_pref_found = i2
  1 type_list [* ]
    2 type = vc
    2 selected = i2
  1 abn_form_list [* ]
    2 program_name = vc
    2 program_desc = vc
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
FREE RECORD lab_list
RECORD lab_list (
  1 llist [* ]
    2 task_id = f8
)
FREE RECORD order_id_list
RECORD order_id_list (
  1 olist [* ]
    2 order_id = f8
)
FREE RECORD task_stat
RECORD task_stat (
  1 slist [* ]
    2 status_cd = f8
    2 status = vc
)
RECORD abn_request (
  1 call_echo_ind = i2
  1 report_type_cd = f8
  1 report_type_meaning = c12
)
RECORD abn_reply (
  1 qual_cnt = i4
  1 qual [* ]
    2 sch_report_id = f8
    2 mnem = vc
    2 desc = vc
    2 program_name = vc
    2 report_type_cd = f8
    2 report_type_meaning = c12
    2 updt_cnt = i4
    2 active_ind = i2
    2 candidate_id = f8
    2 postscript_ind = i2
    2 advanced_ind = i2
  1 status_data
    2 status = c1
    2 subeventstatus [1 ]
      3 operationname = c25
      3 operationstatus = c1
      3 targetobjectname = c25
      3 targetobjectvalue = vc
)
DECLARE log_program_name = vc WITH protect ,noconstant ("" )
DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
SET log_program_name = curprog
SET log_override_ind = 1
DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
DECLARE hsys = i4 WITH protect ,noconstant (0 )
DECLARE sysstat = i4 WITH protect ,noconstant (0 )
DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
EXECUTE msgrtl
SET crsl_msg_default = uar_msgdefhandle ()
SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name) ) > " " ) )) )
 SET log_override_ind = 1
ENDIF
DECLARE log_message ((logmsg = vc ) ,(loglvl = i4 ) ) = null
DECLARE getencntrreltn ((dencntr_id = f8 ) ,(dreltn_cd = f8 ) ,(dprov_id = f8 ) ) = null
DECLARE validatefxreltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
DECLARE validatefx2reltn ((dencntr_id = f8 ) ,(dprov_id = f8 ) ) = f8
DECLARE validatecustomsettings ((codeset = f8 ) ,(encntrid = f8 ) ,(cve_fieldparse = vc ) ) = vc
DECLARE subroutine_status = f8 WITH noconstant (0 ) ,protect
IF ((validate (89_powerchart ,- (99 ) ) = - (99 ) ) )
 DECLARE 89_powerchart = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,89 ,"POWERCHART" ) )
ENDIF
IF ((validate (48_inactive ,- (99 ) ) = - (99 ) ) )
 DECLARE 48_inactive = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"INACTIVE" ) )
ENDIF
IF ((validate (48_active ,- (99 ) ) = - (99 ) ) )
 DECLARE 48_active = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
ENDIF

SET log_program_name = "REQ_CUST_MP_TASK_BY_LOC_DT"
DECLARE gathercomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
DECLARE gatherpagecomponentsettings ((parentid = f8 ) ) = null WITH protect ,copy
DECLARE gathertasksbylocdt (dummy ) = null WITH protect ,copy
DECLARE gatherlabsbylocdt (dummy ) = null WITH protect ,copy
DECLARE gatherorderdiags (dummy ) = null WITH protect ,copy
DECLARE gatherenctrorgsecurity ((persid = f8 ) ,(userid = f8 ) ) = null WITH protect ,copy
DECLARE gathertasktypes (dummy ) = null WITH protect ,copy
DECLARE gatheruserprefs ((prsnl_id = f8 ) ,(pref_id = vc ) ) = null WITH protect ,copy
DECLARE gatherpowerformname (dummy ) = null WITH protect ,copy
DECLARE gatheruserlockedchartsaccess ((userid = f8 ) ) = null WITH protect ,copy
DECLARE gatherclericalstatus (dummy ) = null WITH protect ,copy
DECLARE gathernotdonereason ((resultid = f8 ) ) = null WITH protect ,copy
DECLARE gatherchartedforms ((eventid = f8 ) ) = null WITH protect ,copy
DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,protect
DECLARE 6025_cont = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3243" ) )
DECLARE 6000_meds = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3079" ) )
DECLARE 6000_eandm = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!10700" ) )
DECLARE 6000_charge = f8 WITH public ,constant (uar_get_code_by ("DISPLAYKEY" ,6000 ,"CHARGES" ) )
DECLARE deleted = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17013" ) )
DECLARE completed = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2791" ) )
DECLARE inprocess = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2792" ) )
DECLARE 222_fac = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
DECLARE order_comment = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3944" ) )
DECLARE task_note = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2936879" ) )
DECLARE not_done = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17619" ) )
DECLARE ocfcomp_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,120 ,"OCFCOMP" ) )
DECLARE rtf_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,23 ,"RTF" ) )
DECLARE inerror = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) )
DECLARE 27113_mednec = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27113 ,"MEDNEC" ) )
DECLARE 27112_required = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,27112 ,"REQUIRED" ))
DECLARE abn_status_meaning = vc WITH constant ("ABNSTATUS" )
DECLARE start_parser = vc WITH public ,noconstant ("0" )
DECLARE end_parser = vc WITH public ,noconstant ("0" )
DECLARE dtformat = vc WITH public ,constant ("MM/DD/YYYY" )
DECLARE location_parser = vc WITH public ,noconstant ("" )
DECLARE encntr_location_parser = vc WITH public ,noconstant ("1=1" )
DECLARE task_type_parser = vc WITH public ,noconstant ("1=1" )
DECLARE task_type_cv_parser = vc WITH public ,noconstant ("1=1" )
DECLARE encntr_type_parser = vc WITH public ,noconstant ("1=1" )
DECLARE not_done_reason = vc WITH public ,noconstant ("" )
DECLARE not_done_reason_comm = vc WITH public ,noconstant ("" )
DECLARE charted_form_id = f8 WITH public ,noconstant (0.0 )
DECLARE position_bedrock_settings = i2
DECLARE user_pref_string = vc
DECLARE user_pref_found = i2
DECLARE tasks_back = i4
DECLARE task_max = i4
DECLARE tcnt = i2
DECLARE lcnt = i2
DECLARE ignore_data = i2
SET tasks_back = 200
DECLARE confid_ind = i2
DECLARE confid_level = i2
DECLARE confid_security_parser = vc WITH public ,noconstant ("1=1" )
DECLARE indx_type = i4 WITH protect ,noconstant (0 )
DECLARE logging = i4 WITH protect ,noconstant (0 )
declare replace_string = vc with protect, noconstant("")

CALL log_message (concat ("Begin script: " ,log_program_name ) ,log_level_debug )
SET record_data->status_data.status = "F"

CALL gathercomponentsettings ( $POSITION_CD )
IF ((position_bedrock_settings = 0 ) )
 CALL gathercomponentsettings (0.00 )
ENDIF

CALL gatherpagecomponentsettings ( $POSITION_CD )
IF ((position_bedrock_settings = 0 ) )
 CALL gatherpagecomponentsettings (0.00 )
ENDIF

SET record_data->allow_req_print = 0

SET record_data->end_check =  $END_DT
SET record_data->start_check =  $START_DT
SET stat = alterlist (record_data->status_list ,3 )
SET record_data->status_list[1 ].status = "Pending"
SET record_data->status_list[1 ].selected = 1
SET record_data->status_list[2 ].status = "Modified"
SET record_data->status_list[2 ].selected = 1
SET record_data->status_list[3 ].status = "Actioned"
SET record_data->status_list[3 ].selected = 1
;SET record_data->status_list[4 ].status = "Active"
;SET record_data->status_list[4 ].selected = 1
;SET record_data->status_list[5 ].status = "Complete"
;SET record_data->status_list[5 ].selected = 1
;SET record_data->status_list[6 ].status = "Discontinued"
;SET record_data->status_list[6 ].selected = 1

IF ((encntr_type_parser != "1=1" ) )
 SET encntr_type_parser = concat ("e.encntr_type_cd IN (" ,encntr_type_parser ,")" )
ENDIF

IF ((task_type_parser != "1=1" ) )
 SET task_type_cv_parser = concat ("cv.code_value IN (" ,task_type_parser ,")" )
 SET task_type_parser = concat ("ta.task_type_cd IN (" ,task_type_parser ,")" )
ELSE
 SET task_type_cv_parser = "1=1"
ENDIF

SELECT INTO "nl:"
 FROM (dm_info di )
 PLAN (di
  WHERE (di.info_domain = "SECURITY" )
  AND (di.info_name IN ("SEC_CONFID" ) ) )
 DETAIL
  IF ((di.info_name = "SEC_CONFID" )
  AND (di.info_number = 1 ) ) confid_ind = 1
  ENDIF
 WITH nocounter
;end select

IF ((confid_ind = 1 ) )
 ;CALL gatheruserlockedchartsaccess ( $USER_ID )
 IF ((confid_level = - (1 ) ) )
  SET confid_security_parser = "cv.collation_seq <= 0"
 ELSE
  SET confid_security_parser = concat ("cv.collation_seq <= " ,cnvtstring (confid_level ) )
 ENDIF
ENDIF

CALL gathertasktypes (0 )
CALL gatherclericalstatus (0 )

CALL gatheruserprefs ( $USER_ID ,"PWX_MPAGE_ORG_TASK_LIST_TYPES" )

IF ((user_pref_found = 1 ) )
	SET record_data->type_pref_found = 1
	FOR (tseq = 1 TO size (record_data->type_list ,5 ) )
		SET record_data->type_list[tseq ].selected = 0
	ENDFOR
	DECLARE start_comma = i4 WITH protect ,noconstant (1 )
	DECLARE end_comma = i4 WITH protect ,noconstant (findstring ("|" ,user_pref_string ,start_comma ))
	DECLARE task_type_pref = vc
	
	WHILE ((start_comma > 0 ) )
		IF (NOT (end_comma ) )
			SET task_type_pref = substring ((start_comma + 1 ) ,(textlen (user_pref_string ) - start_comma ),user_pref_string )
		ELSE
			SET task_type_pref = substring ((start_comma + 1 ) ,((end_comma - start_comma ) - 1 ) ,user_pref_string )
		ENDIF
		CALL log_message (task_type_pref ,log_level_debug )
		FOR (tseq = 1 TO size (record_data->type_list ,5 ) )
			IF ((record_data->type_list[tseq ].type = task_type_pref ) )
				SET record_data->type_list[tseq ].selected = 1
			ENDIF
		ENDFOR
		SET start_comma = end_comma
		IF (start_comma )
			SET end_comma = findstring ("|" ,user_pref_string ,(start_comma + 1 ) )
		ENDIF
	ENDWHILE
ENDIF

IF (( $LOC_PROMPT > 0 ) )
	IF ((checkdic ("AMB_CUST_LOCATION_ENCNTR_INDEX" ,"P" ,0 ) = 0 ) )
		CALL echo ("*** FAILURE ***" )
		CALL echo ("*** AMB_CUST_LOCATION_ENCNTR_INDEX program not in object library, exiting script.***"
		)
		CALL echo (
		"*** Validate AMB_CUST_LOCATION_ENCNTR_INDEX program is in the correct directory and included. ***"
		)
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
		2 location_tier = i2
		2 location_cd = f8
	1 loc_status_flag = c1
	)
	EXECUTE amb_cust_location_encntr_index location ,indx_type , logging WITH replace ("INDX_REC" ,"INDX_REPLY" )
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
		GO TO exit_program
	ENDIF
	IF ((logging = 1 ) AND (indx_type != 0 ) )
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
		IF ((indx_type != 0 ) )
			CALL echo (build ("Index Type: " ,indx_type_name ,"--Count: " ,indx_reply->indx_cnt ) )
			CALL echo (build ("PERSON at POS 1: " ,indx_reply->indx[1 ].person_id ) )
			CALL echo (build ("ENCNTR at POS 1: " ,indx_reply->indx[1 ].encntr_id ) )
		ENDIF
		CALL echo (build ("LOCATION at POS 1: " ,indx_reply->indx_loc[1 ].location_cd ) )
		CALL echo ("***VERIFICATION COMPLETE***" )
	ENDIF
	
	IF ((indx_reply->loc_status_flag = "S" ) AND (indx_reply->indx_loc_cnt > 0 ) )
		SET encntr_location_parser = ""
		FOR (loc_cnt = 0 TO indx_reply->indx_loc_cnt )
			IF ((indx_reply->indx_loc[loc_cnt ].location_tier <= 3 ) )
				IF ((location_parser = "" ) )
					SET location_parser = concat (trim (cnvtstring (indx_reply->indx_loc[loc_cnt ].location_cd ) ,3 ) ,".00" )
				ELSE
					SET location_parser = concat (location_parser ,
							"," ,trim (cnvtstring (indx_reply->indx_loc[loc_cnt ].location_cd ) ,3 ) ,".00" )
				ENDIF
			ENDIF
		ENDFOR
		SET location_parser = concat ("ta.location_cd IN (" ,location_parser ,")" )
	ELSE
		GO TO exit_script
	ENDIF
ENDIF

CALL gathertasksbylocdt (0)

SET stat = alterlist (record_data->tlist ,tcnt )

IF ((size (record_data->tlist ,5 ) > 0 ) )
 CALL gatherorderdiags (0 )
 FOR (eseq = 1 TO size (record_data->tlist ,5 ) )
  IF ((record_data->tlist[eseq ].result_set_id > 0 ) )
   CALL gathernotdonereason (record_data->tlist[eseq ].result_set_id )
   SET record_data->tlist[eseq ].not_done_reason = not_done_reason
   SET record_data->tlist[eseq ].not_done_reason_comm = not_done_reason_comm
  ENDIF
  IF ((record_data->tlist[eseq ].event_id > 0 ) AND (record_data->tlist[eseq ].task_type_ind = 2 ) )
   CALL gatherchartedforms (record_data->tlist[eseq ].event_id )
   SET record_data->tlist[eseq ].dfac_activity_id = charted_form_id
  ENDIF
 ENDFOR
ENDIF


SET record_data->status_data.status = "S"
SET modify maxvarlen 20000000
SET _memory_reply_string = cnvtrectojson (record_data )

 SUBROUTINE  gathertasksbylocdt (dummy )
  CALL log_message ("In GatherTasksByLocDt()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (curdate ,curtime3 ) ) ,private
  SET start_parser = concat ("ce.event_end_dt_tm >= " ," cnvtdatetime(cnvtdate2('" , $START_DT ,"','" ,dtformat ,"'),0)" )
  SET end_parser = concat ("ce.event_end_dt_tm <= " ," cnvtdatetime(cnvtdate2('" , $END_DT ,"','" ,dtformat ,"'),2359)" )
  SET record_data->date_used = 1

  /*
  SELECT INTO "nl:"
   task_date = datetimezoneformat (ta.task_dt_tm ,ta.task_tz ,"MM/DD/YY" ) ,
   task_time = datetimezoneformat (ta.task_dt_tm ,ta.task_tz ,"hh:mm tt" ) ,
   order_date = datetimezoneformat (o.orig_order_dt_tm ,o.orig_order_tz ,"MM/DD/YY" ) ,
   order_time = datetimezoneformat (o.orig_order_dt_tm ,o.orig_order_tz ,"hh:mm tt" ) ,
   task_type = trim (uar_get_code_display (ta.task_type_cd ) )
   FROM (task_activity ta ),
    (person p ),
    (orders o ),
    (order_comment oc ),
    (order_detail od3 ),
    (long_text lt ),
    (eem_abn_check eem ),
    (order_task ot ),
    (prsnl pr ),
    (prsnl pr2 ),
    (encounter e ),
    (code_value cv ),
    (pathway_catalog pc ),
    (order_task_position_xref otpx )
   PLAN (ta
    WHERE parser (location_parser )
    AND parser (start_parser )
    AND parser (end_parser )
    AND parser (task_type_parser )
    AND (ta.task_class_cd != 6025_cont )
    AND (ta.task_status_cd != deleted )
    AND (ta.active_ind = 1 ) )
    JOIN (e
    WHERE (e.encntr_id = ta.encntr_id )
    AND parser (encntr_type_parser ) )
    JOIN (cv
    WHERE (cv.code_value = e.confid_level_cd )
    AND parser (confid_security_parser ) )
    JOIN (p
    WHERE (p.person_id = ta.person_id ) )
    JOIN (o
    WHERE (o.order_id = outerjoin (ta.order_id ) )
    AND (o.order_id > outerjoin (0 ) ) )
    JOIN (od3
    WHERE (od3.order_id = outerjoin (o.order_id ) )
    AND (od3.oe_field_meaning = outerjoin (abn_status_meaning ) ) )
    JOIN (pc
    WHERE (pc.pathway_catalog_id = outerjoin (o.pathway_catalog_id ) ) )
    JOIN (oc
    WHERE (oc.order_id = outerjoin (o.order_id ) ) )
    JOIN (lt
    WHERE (lt.long_text_id = outerjoin (oc.long_text_id ) ) )
    JOIN (eem
    WHERE (eem.parent1_id = outerjoin (o.order_id ) )
    AND (eem.parent1_id != outerjoin (0 ) )
    AND (eem.parent1_table = outerjoin ("ORDERS" ) )
    AND (eem.med_status_cd != outerjoin (27113_mednec ) )
    AND (eem.high_status_cd = outerjoin (27112_required ) ) )
    JOIN (ot
    WHERE (ot.reference_task_id = ta.reference_task_id ) )
    JOIN (otpx
    WHERE (otpx.reference_task_id = outerjoin (ot.reference_task_id ) )
    AND (otpx.position_cd = outerjoin ( $POSITION_CD ) ) )
    JOIN (pr
    WHERE (pr.person_id = outerjoin (o.last_update_provider_id ) ) )
    JOIN (pr2
    WHERE (pr2.person_id = outerjoin (ta.updt_id ) ) )
   ORDER BY ta.task_dt_tm ,
    ta.task_id ,
    lt.updt_dt_tm ,
    eem.updt_dt_tm DESC
   HEAD REPORT
    lcnt = 0 ,
    ignore_data = 0
   HEAD ta.task_id
    abncnt = 0 ,
    IF ((ta.container_id > 0 ) ) lcnt = (lcnt + 1 ) ,
     IF ((mod (lcnt ,100 ) = 1 ) ) stat = alterlist (lab_list->llist ,(lcnt + 99 ) )
     ENDIF
     ,lab_list->llist[lcnt ].task_id = ta.task_id ,ignore_data = 1
    ELSE ignore_data = 0 ,tcnt = (tcnt + 1 ) ,
     IF ((mod (tcnt ,100 ) = 1 ) ) stat = alterlist (record_data->tlist ,(tcnt + 99 ) )
     ENDIF
     ,record_data->tlist[tcnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/dd/yyyy" ) ,
     record_data->tlist[tcnt ].encounter_id = ta.encntr_id ,record_data->tlist[tcnt ].gender =
     uar_get_code_display (p.sex_cd ) ,record_data->tlist[tcnt ].gender_char = cnvtupper (substring (
       1 ,1 ,record_data->tlist[tcnt ].gender ) ) ,age_str = cnvtlower (trim (substring (1 ,12 ,
        cnvtage (p.birth_dt_tm ) ) ,4 ) ) ,
     IF ((findstring ("days" ,age_str ,0 ) > 0 ) ) days = findstring ("days" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,days ,age_str )
     ELSEIF ((findstring ("weeks" ,age_str ,0 ) > 0 ) ) weeks = findstring ("weeks" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,weeks ,age_str )
     ELSEIF ((findstring ("months" ,age_str ,0 ) > 0 ) ) months = findstring ("months" ,age_str ,0 )
     ,record_data->tlist[tcnt ].age = substring (1 ,months ,age_str )
     ELSEIF ((findstring ("years" ,age_str ,0 ) > 0 ) ) years = findstring ("years" ,age_str ,0 ) ,
      record_data->tlist[tcnt ].age = substring (1 ,years ,age_str )
     ENDIF
     ,record_data->tlist[tcnt ].person_id = p.person_id ,record_data->tlist[tcnt ].person_name =
     trim (p.name_full_formatted ) ,record_data->tlist[tcnt ].task_id = ta.task_id ,record_data->
     tlist[tcnt ].task_describ = trim (ot.task_description ) ,record_data->tlist[tcnt ].task_display
     = record_data->tlist[tcnt ].task_describ ,record_data->tlist[tcnt ].visit_loc = trim (
      uar_get_code_description (e.location_cd ) ) ,record_data->tlist[tcnt ].visit_date = format (
      cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YYYY;;d" ) ,record_data->tlist[tcnt ].visit_date_display =
     format (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YY;;d" ) ,record_data->tlist[tcnt ].visit_dt_tm_num
     = e.reg_dt_tm ,record_data->tlist[tcnt ].visit_dt_utc = build (replace (datetimezoneformat (
        cnvtdatetime (e.reg_dt_tm ) ,datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,
        curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].charted_by = trim (pr2
      .name_full_formatted ) ,record_data->tlist[tcnt ].charted_dt = format (ta.updt_dt_tm ,
      "MM/DD/YYYY;4;D" ) ,record_data->tlist[tcnt ].charted_dt_utc = build (replace (
       datetimezoneformat (cnvtdatetime (ta.updt_dt_tm ) ,datetimezonebyname ("UTC" ) ,
        "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[tcnt ].
     display_status = trim (uar_get_code_display (ta.task_status_cd ) ) ,
     IF ((ta.task_status_cd = inprocess ) ) record_data->tlist[tcnt ].inprocess_ind = 1
     ENDIF
     ,
     FOR (tseq = 1 TO size (task_stat->slist ,5 ) )
      IF ((ta.task_status_cd = task_stat->slist[tseq ].status_cd ) ) record_data->tlist[tcnt ].
       task_status = task_stat->slist[tseq ].status
      ENDIF
     ENDFOR
     ,
     IF ((ta.task_status_reason_cd = not_done ) ) record_data->tlist[tcnt ].not_done = 1 ,record_data
      ->tlist[tcnt ].result_set_id = ta.result_set_id
     ENDIF
     ,record_data->tlist[tcnt ].task_type = trim (replace (task_type ,"* " ,"" ,0 ) ) ,record_data->
     tlist[tcnt ].task_date = task_date ,record_data->tlist[tcnt ].task_dt_tm_num = datetimezone (ta
      .task_dt_tm ,ta.task_tz ) ,record_data->tlist[tcnt ].task_dt_tm_utc = build (replace (
       datetimezoneformat (cnvtdatetime (ta.task_dt_tm ) ,datetimezonebyname ("UTC" ) ,
        "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,
     IF ((ta.task_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) ) record_data->tlist[tcnt ].
      task_overdue = 1
     ENDIF
     ,
     IF ((o.prn_ind = 1 ) ) record_data->tlist[tcnt ].task_prn_ind = 1
     ENDIF
     ,record_data->tlist[tcnt ].task_time = task_time ,record_data->tlist[tcnt ].order_id = trim (
      cnvtstring (ta.order_id ) ) ,record_data->tlist[tcnt ].order_id_real = ta.order_id ,record_data
     ->tlist[tcnt ].ordered_as_name = trim (o.ordered_as_mnemonic ) ,record_data->tlist[tcnt ].
     orig_order_dt = concat (order_date ," " ,order_time ) ,record_data->tlist[tcnt ].order_dt_tm_utc
      = build (replace (datetimezoneformat (cnvtdatetime (o.orig_order_dt_tm ) ,datetimezonebyname (
         "UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" ) ,record_data->tlist[
     tcnt ].order_cdl = trim (o.order_detail_display_line ) ,
     IF ((ot.allpositionchart_ind = 1 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
     ELSEIF ((otpx.reference_task_id > 0 ) ) record_data->tlist[tcnt ].can_chart_ind = 1
     ENDIF
     ,record_data->tlist[tcnt ].task_resched_time = ot.reschedule_time ,
     IF ((record_data->tlist[tcnt ].order_cdl = "" ) ) record_data->tlist[tcnt ].order_cdl = "--"
     ENDIF
     ,
     IF ((pr.person_id > 0 ) ) record_data->tlist[tcnt ].ordering_provider = trim (pr
       .name_full_formatted )
     ELSE record_data->tlist[tcnt ].ordering_provider = "--"
     ENDIF
     ,
     IF ((((o.catalog_type_cd = 6000_eandm ) ) OR ((o.catalog_type_cd = 6000_charge ) )) )
      record_data->tlist[tcnt ].charge_ind = 1
     ENDIF
     ,
     IF ((o.catalog_type_cd = 6000_meds ) ) record_data->tlist[tcnt ].task_type_ind = 1 ,record_data
      ->tlist[tcnt ].task_display = record_data->tlist[tcnt ].ordered_as_name ,record_data->tlist[
      tcnt ].order_cdl = trim (o.clinical_display_line )
     ENDIF
     ,
     IF ((ot.dcp_forms_ref_id > 0 ) ) record_data->tlist[tcnt ].task_form_id = ot.dcp_forms_ref_id ,
      record_data->tlist[tcnt ].task_type_ind = 2 ,
      IF ((ta.event_id > 0 ) ) record_data->tlist[tcnt ].event_id = ta.event_id
      ENDIF
     ENDIF
     ,
     IF ((o.pathway_catalog_id > 0 ) ) record_data->tlist[tcnt ].powerplan_ind = 1 ,record_data->
      tlist[tcnt ].powerplan_name = trim (pc.description )
     ENDIF
     ,
     IF ((eem.abn_tracking_id > 0 )
     AND (cnvtupper (od3.oe_field_display_value ) != "NOT REQUIRED" ) ) abncnt = (abncnt + 1 ) ,stat
      = alterlist (record_data->tlist[tcnt ].abn_list ,abncnt ) ,record_data->tlist[tcnt ].abn_list[
      abncnt ].alert_state = uar_get_code_display (eem.abn_state_cd ) ,record_data->tlist[tcnt ].
      abn_list[abncnt ].alert_date = format (eem.active_status_dt_tm ,"MM/DD/YYYY HH:MM:SS;;d" ) ,
      record_data->tlist[tcnt ].abn_list[abncnt ].order_disp = trim (o.ordered_as_mnemonic ) ,
      IF ((record_data->tlist[tcnt ].abn_track_ids = "" ) ) record_data->tlist[tcnt ].abn_track_ids
       = cnvtstring (eem.abn_tracking_id )
      ELSE record_data->tlist[tcnt ].abn_track_ids = concat (record_data->tlist[tcnt ].abn_track_ids
        ,"," ,cnvtstring (eem.abn_tracking_id ) )
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    IF ((ignore_data = 0 ) )
     IF ((oc.comment_type_cd = task_note ) ) record_data->tlist[tcnt ].task_note = trim (lt
       .long_text )
     ELSEIF ((oc.comment_type_cd = order_comment ) ) record_data->tlist[tcnt ].ord_comment = trim (lt
       .long_text )
     ENDIF
    ENDIF
   FOOT  ta.task_id
    IF ((ignore_data = 0 ) )
     IF ((record_data->tlist[tcnt ].ord_comment = "" ) ) record_data->tlist[tcnt ].ord_comment =
      "--"
     ENDIF
     ,
     IF ((record_data->tlist[tcnt ].task_note = "" ) ) record_data->tlist[tcnt ].task_note = "--"
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (lab_list->llist ,lcnt )
   WITH nocounter
  ;end select
  */
  
  
  CALL error_and_zero_check_rec (curqual ,"AMB_CUST_MP_TASK_LOC_DT" ,"GatherTasksByLocDt" ,1 ,0 ,record_data )
  CALL log_message (build ("Exit GatherTasksByLocDt(), Elapsed time in seconds:" ,
  		datetimediff (cnvtdatetime (curdate ,curtime3 ) ,begin_date_time ,5 ) ) ,log_level_debug )
 
  SET record_data->document_start_date = CNVTDATETIME(CNVTDATE2(record_data->start_check, dtformat),0)
  SET record_data->document_end_date = CNVTDATETIME(CNVTDATE2(record_data->end_check, dtformat),2359)
 

	declare notfnd = vc with constant("<not found>")
	declare order_string = vc with noconstant(" ")
	declare i = i2 with noconstant(0)
	declare k = i2 with noconstant(0)
	declare j = i2 with noconstant(0)
	declare pos = i2 with noconstant(0)
	
	select into "nl:"
	from
		 clinical_event ce
		,clinical_event pe
		,encounter e
		,ce_blob_result ceb
		,prsnl p1
		,person p
	plan ce
		where ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Req"))
		and	  ce.result_status_cd in(
										  value(uar_get_code_by("MEANING",8,"AUTH"))
										 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
									)
		
		and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		;and   ce.valid_from_dt_tm >= cnvtdatetime(curdate-60)
		and   ce.event_tag        != "Date\Time Correction"
	join pe
		where pe.event_id = ce.parent_event_id
		and	  pe.result_status_cd in(
										  value(uar_get_code_by("MEANING",8,"AUTH"))
										 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
										 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
									)
		
		and   pe.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   pe.event_tag        != "Date\Time Correction"
	join ceb
		where ceb.event_id = ce.event_id
	    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	join p1
		where p1.person_id = ce.verified_prsnl_id
	join e
		where e.encntr_id = ce.encntr_id
	join p
		where p.person_id = e.person_id
	order by
		;003 ce.event_end_dt_tm desc
		 pe.event_end_dt_tm desc ;003
		,ce.event_end_dt_tm ;003
		,ce.event_id
		,ce.clinical_event_id
     head report 
     	tcnt = size(record_data->tlist,5)
    	ignore_data = 0
    	order_string = ""
    	k = 1
   	HEAD ce.event_id
   	 call echo(concat("evaluating pe ",trim(pe.event_title_text)))
     ignore_data = 1
     order_string = ""
     if (record_data->date_used = 1)
     	if (cnvtdatetime(ce.event_end_dt_tm) 
     		between cnvtdatetime(record_data->document_start_date) and cnvtdatetime(record_data->document_end_date))
     		ignore_data = 0
     	endif
     else
     	ignore_data = 0
     endif
     ;if (ce.valid_from_dt_tm >= datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime3)), 'M', 'B', 'B'))
     ;	ignore_data = 1
    ;endif
     if (ignore_data = 0)
		tcnt = (tcnt + 1 )
     	IF ((mod (tcnt ,100 ) = 1 ) ) stat = alterlist (record_data->tlist ,(tcnt + 99 ) ) ENDIF
     	record_data->tlist[tcnt ].can_chart_ind = 1
     	
    	record_data->tlist[tcnt ].dob = datetimezoneformat (p.birth_dt_tm ,p.birth_tz ,"MM/dd/yyyy" ) 
     	record_data->tlist[tcnt ].encounter_id = e.encntr_id
	 	record_data->tlist[tcnt ].gender = uar_get_code_display (p.sex_cd )
	 	record_data->tlist[tcnt ].gender_char = cnvtupper (substring ( 1 ,1 ,record_data->tlist[tcnt ].gender ) )
	 	age_str = cnvtlower (trim (substring (1 ,12 , cnvtage (p.birth_dt_tm ) ) ,4 ) )
     	IF ((findstring ("days" ,age_str ,0 ) > 0 ) ) 
			days = findstring ("days" ,age_str ,0 )
			record_data->tlist[tcnt ].age = substring (1 ,days ,age_str )
     	ELSEIF ((findstring ("weeks" ,age_str ,0 ) > 0 ) ) 
			weeks = findstring ("weeks" ,age_str ,0 ) ,
			record_data->tlist[tcnt ].age = substring (1 ,weeks ,age_str )
     	ELSEIF ((findstring ("months" ,age_str ,0 ) > 0 ) ) 
			months = findstring ("months" ,age_str ,0 )
			record_data->tlist[tcnt ].age = substring (1 ,months ,age_str )
     	ELSEIF ((findstring ("years" ,age_str ,0 ) > 0 ) )
			years = findstring ("years" ,age_str ,0 ) ,
			record_data->tlist[tcnt ].age = substring (1 ,years ,age_str )
     	ENDIF
     
		 record_data->tlist[tcnt ].person_id = p.person_id ,record_data->tlist[tcnt ].person_name = trim (p.name_full_formatted )
		 ;001 record_data->tlist[tcnt ].task_id = ce.event_id
		 record_data->tlist[tcnt ].task_id = ce.clinical_event_id
		 record_data->tlist[tcnt ].event_id = ce.event_id
		 record_data->tlist[tcnt ].task_describ = trim( pe.event_title_text)
		 record_data->tlist[tcnt ].task_display = record_data->tlist[tcnt ].task_describ
		 record_data->tlist[tcnt ].visit_loc = trim (uar_get_code_description (e.location_cd ) )
		 record_data->tlist[tcnt ].visit_date = format (cnvtdatetime (e.reg_dt_tm ) ,"MM/DD/YYYY;;d" )
		 record_data->tlist[tcnt ].visit_date_display = format (cnvtdatetime (e.reg_dt_tm ) ,"dd-mm-yy hh:mm;;d" )
		 record_data->tlist[tcnt ].visit_dt_tm_num = e.reg_dt_tm
		 record_data->tlist[tcnt ].visit_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (e.reg_dt_tm ) ,
		 		datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
		record_data->tlist[tcnt ].charted_by = trim (p1.name_full_formatted )
		record_data->tlist[tcnt ].charted_dt = format (ce.event_end_dt_tm , "MM/DD/YYYY;4;D" )
		record_data->tlist[tcnt ].charted_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (ce.event_end_dt_tm ) ,
				datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
		
		record_data->tlist[tcnt ].task_status = piece(record_data->tlist[tcnt ].task_display,":",1,"")
		record_data->tlist[tcnt ].task_status = cnvtcap(record_data->tlist[tcnt ].task_status)
		call echo(concat("record status =",record_data->tlist[tcnt ].task_status))
		replace_string = concat(trim(cnvtupper(record_data->tlist[tcnt ].task_status)),":")
		call echo(concat("record status for conversion =",trim(replace_string)))
		
		if (record_data->tlist[tcnt ].task_status = record_data->tlist[tcnt ].task_display)
			record_data->tlist[tcnt ].task_status = "Pending"
		else
			call echo("replacing status")
			record_data->tlist[tcnt ].task_display = replace(record_data->tlist[tcnt ].task_display,replace_string,"")
		endif
		record_data->tlist[tcnt ].task_describ = record_data->tlist[tcnt ].task_describ
		record_data->tlist[tcnt ].display_status = record_data->tlist[tcnt ].task_status
	    record_data->tlist[tcnt ].task_type = ""
	    record_data->tlist[tcnt ].task_date = format (ce.event_end_dt_tm ,"MM/DD/YY;;q" )
	    record_data->tlist[tcnt ].task_time = format (ce.event_end_dt_tm ,"hh:mm tt;;q" )
	    record_data->tlist[tcnt ].task_dt_tm_num = datetimezone (ce.event_end_dt_tm ,ce.event_end_tz ) 
	    ;record_data->tlist[tcnt ].task_dt_tm_utc = build (replace (datetimezoneformat (cnvtdatetime (ce.event_end_dt_tm ) 
	    ;											,datetimezonebyname ("UTC" ) , "yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
 		record_data->tlist[tcnt ].task_dt_tm_utc = format(ce.event_end_dt_tm,"dd-mmm-yy hh:mm;;q")
 		record_data->tlist[tcnt ].normal_ref_range_txt = pe.normal_ref_range_txt
 		
 		k = 1
 		order_string = piece(record_data->tlist[tcnt ].normal_ref_range_txt,":",k,notfnd)
 		call echo(build("-->order_string=",order_string))
 		if (order_string = notfnd)
 			order_string = record_data->tlist[tcnt ].normal_ref_range_txt
		endif
 		record_data->tlist[tcnt ].order_id = order_string
		record_data->tlist[tcnt ].order_id_real = cnvtreal(order_string)
	endif
	with nocounter
    
    call echo("Starting query to find requisition type")
    select into "nl:"
	 event_id = record_data->tlist[d1.seq].event_id
	from
		 (dummyt d1 with seq=size(record_data->tlist,5))
		,(dummyt d3)
		,orders o
		,order_catalog oc
		,order_detail od
	plan d1
		where record_data->tlist[d1.seq].order_id_real > 0.0
	join o
		where (		(o.order_id = record_data->tlist[d1.seq].order_id_real)
				or 	(o.template_order_id = record_data->tlist[d1.seq].order_id_real)
				or 	(o.protocol_order_id = record_data->tlist[d1.seq].order_id_real)
			  )
				
		and   o.order_status_cd in(
										 value(uar_get_code_by("MEANING",6004,"FUTURE"))
										;002 ,value(uar_get_code_by("MEANING",6004,"ORDERED"))
									)
	join oc
		where oc.catalog_cd = o.catalog_cd
	join d3
	join od
		where od.order_id = o.order_id
		and   od.oe_field_meaning = "REQSTARTDTTM"
	order by
		 event_id
		,o.order_id
		,o.protocol_order_id
		,o.template_order_id
		,od.action_sequence
	head report
		stat = 0
		order_id = 0.0
		call echo("inside orders query")
	head event_id
		order_id = o.order_id
	head o.order_id
		record_data->tlist[d1.seq].requisition_format_cd = oc.requisition_format_cd
	foot o.order_id
	 	record_data->tlist[d1.seq ].visit_date = format (cnvtdatetime (od.oe_field_dt_tm_value ) ,"dd-mmm-yy hh:mm;;d" )
		record_data->tlist[d1.seq ].visit_date_display = format (cnvtdatetime (od.oe_field_dt_tm_value ) ,"dd-mmm-yy hh:mm;;d" )
		record_data->tlist[d1.seq ].visit_dt_tm_num = od.oe_field_dt_tm_value
		record_data->tlist[d1.seq ].visit_dt_utc = build (replace (datetimezoneformat (cnvtdatetime (od.oe_field_dt_tm_value ) ,
		 		datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
		null
		order_id = 0.0
	foot report
		stat = 0
	with nocounter,outerjoin=d3,nullreport
	
	for (i = 1 to size(record_data->tlist,5))
		set k = 1
		set order_string = ""
		if (record_data->tlist[i].requisition_format_cd > 0.0)
			set order_string = uar_get_code_meaning(record_data->tlist[i].requisition_format_cd)
		endif
		select into "nl:"
		from code_value cv 
		plan cv
			where cv.code_set = bc_common->code_set
			and   cv.active_ind = 1
			and   cv.description = order_string
		detail
			record_data->tlist[i].task_type = cv.display
			;record_data->tlist[i].task_describ = replace(record_data->tlist[tcnt ].task_describ,trim(cv.display),"")
			record_data->tlist[i].task_display = replace(record_data->tlist[i].task_display,concat(" - ",trim(cv.display)),"")
		with nocounter
	endfor
	
	select into "nl:"
		 
	from
		 (dummyt d1 with seq=size(record_data->tlist,5))
		,orders o
		,order_action oa
		,prsnl p
	plan d1
		where record_data->tlist[d1.seq].order_id_real > 0.0
	join o
		where o.order_id = record_data->tlist[d1.seq].order_id_real
	join oa
		where oa.order_id = o.order_id
	join p
		where p.person_id = oa.order_provider_id
	order by
		 o.order_id
		,oa.action_sequence desc
	head report
		stat = 0
		order_id = 0.0
		call echo("inside orders query")
	head o.order_id
		record_data->tlist[d1.seq].ordering_provider = p.name_full_formatted
	foot report
		stat = 0
	with nocounter,nullreport
 END ;Subroutine


#exit_script
#exit_program
 CALL log_message (concat ("Exiting script: " ,log_program_name ) ,log_level_debug )
 CALL log_message (build ("Total time in seconds:" ,
 	datetimediff (cnvtdatetime (curdate ,curtime3 ) ,current_date_time ,5 ) ) ,log_level_debug )
 call echorecord(record_data)
 FREE RECORD record_data
END GO

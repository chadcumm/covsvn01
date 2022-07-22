DROP PROGRAM cov_surg_operation GO
CREATE PROGRAM cov_surg_operation

;001 ccummin4 - removed time restriction


 RECORD sn (
   1 operation_cnt = i4
   1 operation [* ]
     2 surg_case_id = f8
     2 surg_case_proc_id = f8
     2 surg_proc_cd = f8
     2 surg_proc_cd_desc = vc
     2 surg_proc_detail = vc
     2 active_ind = i2
     2 modifier = vc
     2 surg_start_dt_tm = vc
 ) WITH protect
 DECLARE PUBLIC::get_surg_opnote_operation (null ) = i4 WITH protect ,copy
 DECLARE PUBLIC::format_output ((operation_cnt = i4 ) ) = null WITH protect ,copy
 DECLARE PUBLIC::build_procedure_line ((surg_proc_cd_description = vc ) ,(surg_proc_detail = vc ) ,(
  modifier = vc ) ) = vc WITH protect ,copy
 DECLARE PUBLIC::main (null ) = null WITH private
 FREE RECORD surg
 RECORD surg (
   1 case_cnt = i4
   1 cases [* ]
     2 surg_case_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 surg_prsnl_id = f8
     2 surg_start_dt_tm = dq8
     2 surg_stop_dt_tm = dq8
     2 preop_diag_text_id = f8
     2 postop_diag_text_id = f8
 ) WITH protect
 FREE RECORD output_rec
 RECORD output_rec (
   1 output_cnt = i4
   1 output_line [* ]
     2 output_text = vc
 ) WITH protect
 FREE RECORD code_rec
 RECORD code_rec (
   1 code_list_cnt = i4
   1 code_list [* ]
     2 code_value = f8
     2 code_meaning = vc
 ) WITH protect
 FREE RECORD meaning_rec
 RECORD meaning_rec (
   1 meaning_list_cnt = i4
   1 meaning_list [* ]
     2 meaning_code_set = i4
     2 meaning_value = vc
 ) WITH protect
 DECLARE encounter_id = f8 WITH protect ,constant (request->visit[1 ].encntr_id )
 DECLARE person_id = f8 WITH protect ,constant (request->person[1 ].person_id )
 DECLARE loggedin_id = f8 WITH protect ,constant (request->prsnl[1 ].prsnl_id )
 DECLARE no_qual_data_msg = vc WITH protect ,constant ("No qualifying data available." )
 DECLARE main_program_msg = vc WITH protect ,constant ("Main Program" )
 DECLARE success_msg = vc WITH protect ,constant ("Success" )
 DECLARE rhead_sans = vc WITH protect ,constant (
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}" )
 DECLARE rtf_eol = vc WITH protect ,constant ("\par " )
 DECLARE rtfeof = vc WITH protect ,constant ("}" )
 DECLARE rtf_pg = vc WITH protect ,constant ("\pard " )
 DECLARE rtf_head = vc WITH protect ,constant (
  "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss\fprq0\fcharset0 Microsoft Sans Serif;}}\f0\fs18 " )
 DECLARE auth_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE alt_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) )
 DECLARE mod_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) )
 DECLARE time_number_lb = vc WITH protect ,noconstant ("48" )
 DECLARE time_unit_lb = vc WITH protect ,noconstant ("D" )
 DECLARE lookbehind_str = vc WITH protect ,noconstant (concat ("'" ,time_number_lb ,"," ,
   time_unit_lb ,"'" ) )
 DECLARE errcode = i4 WITH protect ,noconstant (0 )
 DECLARE errmsg = vc WITH protect
 DECLARE PUBLIC::get_cases ((lkbehind_str = vc ) ) = i4 WITH protect ,copy
 DECLARE PUBLIC::get_encounter (null ) = null WITH protect ,copy
 DECLARE PUBLIC::set_reply_text (null ) = null WITH protect ,copy
 DECLARE PUBLIC::set_reply_status ((status = c1 ) ,(ostatus = c1 ) ,(oname = vc ) ,(toname = vc ) ,(
  tovalue = vc ) ) = null WITH protect ,copy
 DECLARE PUBLIC::get_code_value_by_meaning ((code_set = i4 ) ,(search_string = vc ) ,(
  latest_occurence = i4 ) ) = i4 WITH protect ,copy
 DECLARE PUBLIC::get_code_value_by_ccki ((ccki_code_set = i4 ) ,(ccki_search_str = vc ) ,(
  ccki_latest_idx = i4 ) ) = i4 WITH protect ,copy
 IF ((validate (pex_error_and_exit_subroutines_ind ) = false ) )
  EXECUTE pex_error_and_exit_subroutines
 ENDIF
 SUBROUTINE  PUBLIC::get_encounter (null )
  IF ((encounter_id = 0 ) )
   CALL set_reply_status ("F" ,"F" ,"Get_Encounter subroutine" ,curprog ,
    "Invalid or missing encntr_id" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  PUBLIC::get_cases (lkbehind_str )
  DECLARE case_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE current_dt_tm = dq100 WITH protect
  SET current_dt_tm = cnvtdatetime (curdate ,curtime3 )
  SELECT INTO "NL:"
   FROM (surgical_case sc )
   PLAN (sc
    WHERE (sc.person_id = person_id )
    AND (sc.encntr_id = encounter_id )
   ;001 AND (sc.surg_start_dt_tm BETWEEN cnvtlookbehind (lkbehind_str ,cnvtdatetime (curdate ,curtime3 )
   ;001  ) AND cnvtdatetime (curdate ,curtime3 ) )
    AND (sc.active_ind = 1 ) 
    and (sc.surg_complete_qty > 0))
   ORDER BY sc.surg_start_dt_tm DESC ,
    sc.surg_case_id DESC
   HEAD REPORT
    case_cnt = 0 ,
    stat = alterlist (surg->cases ,1 )
   HEAD sc.surg_case_id
    case_cnt = (case_cnt + 1 ) ,stat = alterlist (surg->cases ,case_cnt ) ,surg->cases[case_cnt ].
    surg_case_id = sc.surg_case_id ,surg->cases[case_cnt ].person_id = sc.person_id ,surg->cases[
    case_cnt ].encntr_id = sc.encntr_id ,surg->cases[case_cnt ].surg_prsnl_id = loggedin_id ,surg->
    cases[case_cnt ].surg_start_dt_tm = sc.surg_start_dt_tm ,surg->cases[case_cnt ].surg_stop_dt_tm
    = nullval (sc.surg_stop_dt_tm ,cnvtdatetime (curdate ,curtime3 ) ) ,surg->cases[case_cnt ].
    preop_diag_text_id = sc.preop_diag_text_id ,surg->cases[case_cnt ].postop_diag_text_id = sc
    .postop_diag_text_id
   WITH nocounter
  ;end select
  SET surg->case_cnt = case_cnt
  RETURN (case_cnt )
 END ;Subroutine
 SUBROUTINE  PUBLIC::get_code_value_by_meaning (code_set ,search_string ,latest_occurence )
  DECLARE code_list[20 ] = f8
  DECLARE total_remaining = i4 WITH protect ,noconstant (0 )
  DECLARE start_index = i4 WITH protect ,constant (1 )
  DECLARE occurrence = i4 WITH protect ,noconstant (20 )
  DECLARE cv_index = i4 WITH protect ,noconstant (0 )
  DECLARE total_occurence = i4 WITH protect ,noconstant (0 )
  CALL uar_get_code_list_by_meaning (code_set ,search_string ,start_index ,occurrence ,
   total_remaining ,code_list )
  IF ((occurrence > 0 ) )
   IF ((total_remaining > 0 ) )
    SET occurrence = (occurrence + total_remaining )
    SET stat = memrealloc (code_list ,occurrence ,"f8" )
    CALL uar_get_code_list_by_meaning (code_set ,search_string ,start_index ,occurrence ,
     total_remaining ,code_list )
   ENDIF
   SET total_occurence = (latest_occurence + occurrence )
   SET code_rec->code_list_cnt = total_occurence
   SET stat = alterlist (code_rec->code_list ,total_occurence )
   FOR (cv_index = 1 TO occurrence )
    IF ((code_list[cv_index ] > 0 ) )
     SET latest_occurence = (latest_occurence + 1 )
     SET code_rec->code_list[latest_occurence ].code_value = code_list[cv_index ]
     SET code_rec->code_list[latest_occurence ].code_meaning = search_string
    ENDIF
   ENDFOR
  ENDIF
  RETURN (latest_occurence )
 END ;Subroutine
 SUBROUTINE  PUBLIC::get_code_value_by_ccki (ccki_code_set ,ccki_search_str ,ccki_latest_idx )
  DECLARE code_list[20 ] = f8 WITH protect
  DECLARE total_remaining = i4 WITH protect ,noconstant (0 )
  DECLARE start_index = i4 WITH protect ,constant (1 )
  DECLARE occurrence = i4 WITH protect ,noconstant (20 )
  DECLARE cv_index = i4 WITH protect ,noconstant (0 )
  DECLARE total_occurence = i4 WITH protect ,noconstant (0 )
  CALL uar_get_code_list_by_conceptcki (ccki_code_set ,ccki_search_str ,start_index ,occurrence ,
   total_remaining ,code_list )
  IF ((occurrence > 0 ) )
   IF ((total_remaining > 0 ) )
    SET occurrence = (occurrence + total_remaining )
    SET stat = memrealloc (code_list ,occurrence ,"f8" )
    CALL uar_get_code_list_by_conceptcki (ccki_code_set ,ccki_search_str ,start_index ,occurrence ,
     total_remaining ,code_list )
   ENDIF
   SET total_occurence = (ccki_latest_idx + occurrence )
   SET code_rec->code_list_cnt = total_occurence
   SET stat = alterlist (code_rec->code_list ,total_occurence )
   FOR (cv_index = 1 TO occurrence )
    IF ((code_list[cv_index ] > 0 ) )
     SET ccki_latest_idx = (ccki_latest_idx + 1 )
     SET code_rec->code_list[ccki_latest_idx ].code_value = code_list[cv_index ]
     SET code_rec->code_list[ccki_latest_idx ].code_meaning = ccki_search_str
    ENDIF
   ENDFOR
  ENDIF
  RETURN (ccki_latest_idx )
 END ;Subroutine
 SUBROUTINE  PUBLIC::set_reply_text (null )
  DECLARE reply_idx = i4 WITH private ,noconstant (0 )
  IF ((output_rec->output_cnt > 0 ) )
   SET reply->text = rtf_head
   FOR (reply_idx = 1 TO output_rec->output_cnt )
    IF ((reply_idx != output_rec->output_cnt ) )
     SET reply->text = concat (reply->text ," " ,output_rec->output_line[reply_idx ].output_text ,
      rtf_eol )
    ELSE
     SET reply->text = concat (reply->text ," " ,output_rec->output_line[reply_idx ].output_text ,
      rtf_eol ,rtfeof )
    ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE  PUBLIC::set_reply_status (status ,ostatus ,oname ,toname ,tovalue )
  SET reply->status_data.status = status
  SET reply->status_data.subeventstatus.operationstatus = ostatus
  SET reply->status_data.subeventstatus.operationname = oname
  SET reply->status_data.subeventstatus.targetobjectname = toname
  SET reply->status_data.subeventstatus.targetobjectvalue = tovalue
  GO TO exit_script
 END ;Subroutine
 CALL main (null )
 SUBROUTINE  PUBLIC::main (null )
  DECLARE case_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE proc_cnt = i4 WITH protect ,noconstant (0 )
  SET reply->status_data.status = "F"
  CALL get_encounter (null )
  SET case_cnt = get_cases (lookbehind_str )
  IF ((case_cnt > 0 ) )
   SET proc_cnt = get_surg_opnote_operation (null )
   IF ((proc_cnt > 0 ) )
    CALL format_output (proc_cnt )
    CALL set_reply_text (null )
    CALL set_reply_status ("S" ,"S" ,main_program_msg ,curprog ,success_msg )
   ELSE
    CALL set_reply_status ("S" ,"S" ,main_program_msg ,curprog ,no_qual_data_msg )
   ENDIF
  ELSE
   CALL set_reply_status ("S" ,"S" ,main_program_msg ,curprog ,no_qual_data_msg )
  ENDIF
 END ;Subroutine
 SUBROUTINE  PUBLIC::get_surg_opnote_operation (null )
  DECLARE operation_cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (surg_case_procedure scp )
   PLAN (scp
    WHERE (scp.surg_case_id = surg->cases[1 ].surg_case_id )
    AND (scp.active_ind = 1 ) )
   ORDER BY scp.primary_proc_ind DESC ,
    scp.proc_end_dt_tm DESC
   HEAD REPORT
    operation_cnt = 0
   DETAIL
    operation_cnt = (operation_cnt + 1 ) ,
    stat = alterlist (sn->operation ,operation_cnt ) ,
    sn->operation[operation_cnt ].surg_case_id = scp.surg_case_id ,
    sn->operation[operation_cnt ].surg_case_proc_id = scp.surg_case_proc_id ,
    sn->operation[operation_cnt ].surg_proc_cd = scp.surg_proc_cd ,
    IF ((scp.surg_proc_cd != 0.0 ) ) sn->operation[operation_cnt ].surg_proc_cd_desc = trim (
      uar_get_code_display (scp.surg_proc_cd ) ,3 )
    ENDIF
    ,sn->operation[operation_cnt ].surg_proc_detail = trim (scp.proc_text ,3 ) ,
    sn->operation[operation_cnt ].active_ind = scp.active_ind ,
    sn->operation[operation_cnt ].modifier = trim (scp.modifier ,3 )
   WITH nocounter
  ;end select
  SET sn->operation_cnt = operation_cnt
  RETURN (operation_cnt )
 END ;Subroutine
 SUBROUTINE  PUBLIC::format_output (operation_cnt )
  DECLARE op_idx = i4 WITH protect ,noconstant (0 )
  DECLARE line_text = vc WITH protect ,noconstant ("" )
  SET output_rec->output_cnt = operation_cnt
  SET stat = alterlist (output_rec->output_line ,output_rec->output_cnt )
  FOR (op_idx = 1 TO operation_cnt )
   SET output_rec->output_line[op_idx ].output_text = build_procedure_line (sn->operation[op_idx ].
    surg_proc_cd_desc ,sn->operation[op_idx ].surg_proc_detail ,sn->operation[op_idx ].modifier,sn->operation[op_idx].
    surg_start_dt_tm )
  ENDFOR
 END ;Subroutine
 SUBROUTINE  build_procedure_line (surg_proc_cd_desc ,surg_proc_detail ,modifier )
  IF ((surg_proc_cd_desc = "" ) )
   SET surg_proc_cd_desc = surg_proc_detail
  ENDIF
  IF ((surg_proc_detail = surg_proc_cd_desc ) )
   SET surg_proc_detail = ""
  ENDIF
  IF ((surg_proc_cd_desc > " " )
  AND (surg_proc_detail > " " )
  AND (modifier > " " ) )
   RETURN (concat (surg_proc_cd_desc ,", " ,surg_proc_detail ,", " ,modifier ) )
  ELSEIF ((surg_proc_cd_desc > " " )
  AND (surg_proc_detail > " " ) )
   RETURN (concat (surg_proc_cd_desc ,", " ,surg_proc_detail ) )
  ELSEIF ((surg_proc_cd_desc > " " )
  AND (modifier > " " ) )
   RETURN (concat (surg_proc_cd_desc ,", " ,modifier ) )
  ELSE
   RETURN (surg_proc_cd_desc )
  ENDIF
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4 ) ) OR ((validate (debug_ind ,0 ) > 0 ) )) )
 ; CALL echorecord (code_value_rec )
  CALL echorecord (sn )
  CALL echorecord (reply )
  CALL echo (reply->text )
 ENDIF
END GO

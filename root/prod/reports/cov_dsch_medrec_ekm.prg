 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		DEC'21
	Solution:			Quality/Pharmacy
	Source file name:		cov_dsch_medrec_ekm.prg
	Object name:		cov_dsch_medrec_ekm
	Request#:
	Program purpose:	      CCL will call a rule
	Executing from:		Rule
 	Special Notes:		Expert_event Rule name :
 
;********************************************************************************/
 
 
drop program cov_dsch_medrec_ekm:dba go
create program cov_dsch_medrec_ekm:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
; Include files used to call EXPERT_EVENT
; The first include file creates the EKSOPSRequest record structure which is used to pass patient info to the Discern Expert System
 
 
%i cclsource:eks_rprq3091001.inc
%i cclsource:eks_run3091001.inc
 
 
/**************************************************************
; VARIABLE DECLARATION
**************************************************************/
 
declare dsch_inst_var	  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Discharge Instructions')), protect
declare dsch_sum_var	  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Discharge Summary')), protect
declare cnt = i4
 
declare encntrid = f8 with noconstant(0.0), protect
declare personid = f8 with noconstant(0.0), protect
declare q1_var = vc with noconstant(" "), protect
declare q2_var = vc with noconstant(" "), protect
declare q3_var = vc with noconstant(" "), protect
 
set personid = trigger_personid
set encntrid = trigger_encntrid
set log_retval = 0
 
declare log_message = vc with noconstant('')
declare log_misc1 = vc with noconstant('')
 
/**************************************************************
; CCL SCRIPT STARTS HERE
**************************************************************/
 
Record usr(
	1 rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 personid = f8
		2 userid = f8
		2 user_name = vc
		2 reltn_type = vc
		2 dsch_instru_dt = dq8
		2 dsch_summ_dt = dq8
		2 case_mgmnt_alertid = f8
		2 case_mgmnt_alert_subject = vc
		2 case_mgmnt_alert_dt = dq8
		2 nursing_alertid = f8
		2 nursing_alert_subject = vc
		2 nursing_alert_dt = dq8
		2 user_nursing_alert_received = vc
		2 user_nursing_alert_received_dt = dq8
		2 user_casemgnt_alert_received = vc
		2 user_casemgnt_alert_received_dt = dq8
)
 
 /*
Record EKSOPSRequest (
   1 expert_trigger = vc
   1 qual[*]
	   2 person_id = f8
         2 sex_cd = f8
         2 birth_dt_tm = dq8
         2 encntr_id = f8
         2 accession_id = f8
         2 order_id = f8
         2 data[*]
      	   3 vc_var  = vc
               3 double_var = f8
               3 long_var  = i4
               3 short_var = i2
   )*/
 
 
;-------------------------------------------------------------------------
;User relationship
 
select into $outdev
 
epr.encntr_id, prsnl_reltn = uar_get_code_display(epr.encntr_prsnl_r_cd), epr.expire_dt_tm
, pr.name_full_formatted, pr.position_cd, pr.username
 
from encntr_prsnl_reltn epr, prsnl pr
 
plan epr where epr.encntr_id = encntrid ;125446402.00; 125379942.00
	and epr.prsnl_person_id = request->updt_id ;12428721.00
	and epr.expire_dt_tm = null
	and epr.active_ind = 1
	and epr.encntr_prsnl_r_cd in(
		 value(uar_get_code_by("DISPLAY", 333, "Database Coordinator"))
		,value(uar_get_code_by("DISPLAY", 333, "Chart Review"))
		,value(uar_get_code_by("DISPLAY", 333, "Chart Review/Audit"))
		,value(uar_get_code_by("DISPLAY", 333, "ED Charge Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "ED Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Graduate Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Imaging Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Long Term Care Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Nurse Practitioner"))
		,value(uar_get_code_by("DISPLAY", 333, "Oncology RN"))
		,value(uar_get_code_by("DISPLAY", 333, "OR Management"))
		,value(uar_get_code_by("DISPLAY", 333, "Registered Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "RN Surgical Services"))
		,value(uar_get_code_by("DISPLAY", 333, "RN Team Lead"))
		,value(uar_get_code_by("DISPLAY", 333, "Secondary Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Specialty Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Student Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Vascular Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Wound Care Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Case Manager"))
		,value(uar_get_code_by("DISPLAY", 333, "Administrative"))
		,value(uar_get_code_by("DISPLAY", 333, "Auditor/Appeals"))
		,value(uar_get_code_by("DISPLAY", 333, "UM"))
		,value(uar_get_code_by("DISPLAY", 333, "RN Liaison")) )
 
join pr where pr.person_id = epr.prsnl_person_id
	and pr.active_ind = 1
 
order by pr.username
 
Head report
	cnt = 0
Head pr.username
	cnt += 1
	usr->rec_cnt = cnt
	call alterlist(usr->list, cnt)
	usr->list[cnt].encntrid = epr.encntr_id
	usr->list[cnt].personid = personid
	usr->list[cnt].userid = epr.prsnl_person_id
	usr->list[cnt].user_name = pr.username
	usr->list[cnt].reltn_type =
		if( (prsnl_reltn = 'Case Manager')
			or (prsnl_reltn = 'Administrative')
			or (prsnl_reltn = 'Auditor/Appeals')
			or (prsnl_reltn = 'UM')
			or (prsnl_reltn = 'RN Liaison') ) 'CASE MANAGEMENT' else 'NURSING'
		endif
 
with nocounter
 
if(usr->rec_cnt > 0)
 
;-------------------------------------------------------------------------
;Discharge Instruction/summary dt
 
select into $outdev
 
from (dummyt d with seq = size(usr->list, 5))
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = usr->list[d.seq].encntrid
	and ce.event_cd in(dsch_inst_var, dsch_sum_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd )
 
Order by ce.encntr_id, ce.event_id
 
Head ce.event_id
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,value(size(usr->list,5)) ,ce.encntr_id ,usr->list[icnt].encntrid)
Detail
	if(idx > 0)
		case(ce.event_cd)
			of dsch_inst_var:
				usr->list[idx].dsch_instru_dt = ce.event_end_dt_tm
			of dsch_sum_var:
				usr->list[idx].dsch_summ_dt = ce.event_end_dt_tm
		endcase
	endif
with nocounter
 
 
;-------------------------------------------------------------------------
;Latest Nurse Alert
 
select into $outdev
eh.encntr_id, usrid = usr->list[d.seq].userid, eh.*
 
from (dummyt d with seq = size(usr->list, 5))
	,eks_alert_esc_hist eh
 
plan d
 
join eh where eh.encntr_id = usr->list[d.seq].encntrid ;125379942.00
	and eh.msg_type_cd = 680278.00 ;Notify
	and eh.subject_text = '*Discharge Medication Alert - Nursing'
	and eh.alert_source = 'COV_DSCH_MED_REC_TASK'
 
order by eh.encntr_id, eh.alert_id desc
 
Head eh.alert_id
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,value(size(usr->list,5)), eh.encntr_id, usr->list[icnt].encntrid)
Detail
	if(idx > 0)
		usr->list[idx].nursing_alertid = eh.alert_id
		usr->list[idx].nursing_alert_subject = eh.subject_text
		usr->list[idx].case_mgmnt_alert_dt = eh.send_dt_tm
  	endif
 
with nocounter
 
 
;-------------------------------------------------------------------------
;Latest Case Management Alert
 
select into $outdev
 
eh.encntr_id, usrid = usr->list[d.seq].userid, eh.*
 
from (dummyt d with seq = size(usr->list, 5))
	,eks_alert_esc_hist eh
 
plan d
 
join eh where eh.encntr_id = usr->list[d.seq].encntrid
	and eh.msg_type_cd = 680278.00 ;Notify
	and eh.subject_text = '*Discharge Medication Alert - Case Management'
	and eh.alert_source = 'COV_DSCH_MED_REC_TASK'
 
order by eh.encntr_id, eh.alert_id desc
 
Head eh.alert_id
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,value(size(usr->list,5)), eh.encntr_id, usr->list[icnt].encntrid)
Detail
	if(idx > 0)
		usr->list[idx].case_mgmnt_alertid = eh.alert_id
		usr->list[idx].case_mgmnt_alert_subject = eh.subject_text
		usr->list[idx].nursing_alert_dt = eh.send_dt_tm
  	endif
 
with nocounter
 
;-------------------------------------------------------------------------
;User received nursing alert?
 
select into $outdev
eh.*
 
from (dummyt d with seq = size(usr->list, 5))
	,eks_alert_esc_hist eh
 
plan d
 
join eh where eh.encntr_id = usr->list[d.seq].encntrid
	and eh.alert_id = usr->list[d.seq].nursing_alertid
	and eh.parent_entity_id = usr->list[d.seq].userid
	and eh.parent_entity_name = 'PERSON'
	and eh.msg_type_cd = 680278.00 ;Notify
	and eh.subject_text = '*Discharge Medication Alert - Nursing'
	and eh.alert_source = 'COV_DSCH_MED_REC_TASK'
 
order by eh.encntr_id, eh.parent_entity_id
 
Head eh.encntr_id
 
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,value(size(usr->list,5)), eh.encntr_id, usr->list[icnt].encntrid)
Detail
	if(idx > 0)
 		usr->list[idx].user_nursing_alert_received = 'Yes'
 		usr->list[idx].user_nursing_alert_received_dt = eh.send_dt_tm
 	endif
with nocounter
 
;-------------------------------------------------------------------------
;User received Case management alert?
 
select into $outdev
eh.*
 
from (dummyt d with seq = size(usr->list, 5))
	,eks_alert_esc_hist eh
 
plan d
 
join eh where eh.encntr_id = usr->list[d.seq].encntrid
	and eh.alert_id = usr->list[d.seq].case_mgmnt_alertid
	and eh.parent_entity_id = usr->list[d.seq].userid
	and eh.parent_entity_name = 'PERSON'
	and eh.msg_type_cd = 680278.00 ;Notify
	and eh.subject_text = '*Discharge Medication Alert - Case Management'
	and eh.alert_source = 'COV_DSCH_MED_REC_TASK'
 
order by eh.encntr_id, eh.parent_entity_id
 
Head eh.encntr_id
 
	idx = 0
	icnt = 0
	idx = locateval(icnt ,1 ,value(size(usr->list,5)), eh.encntr_id, usr->list[icnt].encntrid)
Detail
	if(idx > 0)
 		usr->list[idx].user_casemgnt_alert_received = 'Yes'
 		usr->list[idx].user_casemgnt_alert_received_dt = eh.send_dt_tm
 	endif
with nocounter
 
;-------------------------------------------------------------------------
;Final evaluation
;Discharge instruction/summary printed after last rule firing?
	;If 'Yes' then no need to alert
	;If 'No' and user didn't receive the latest alert then 'SEND ALERT'
 
select into $outdev
 
enc = usr->list[d.seq].encntrid
 
from (dummyt d with seq = size(usr->list, 5))
 
plan d
 
Order by enc
 
Head enc
	if(usr->list[d.seq].reltn_type = 'NURSING')
		if(usr->list[d.seq].dsch_instru_dt > usr->list[d.seq].nursing_alert_dt)
			log_message = "Discharge Instruction Printed after last alert"
			log_retval =  0
			log_misc1 = 'NURSING'
		elseif(usr->list[d.seq].user_nursing_alert_received = ' ')
			log_message = "Alert the user..."
			log_misc1 = 'NURSING'
			log_retval = 100
		endif
	else
		if(usr->list[d.seq].dsch_summ_dt > usr->list[d.seq].case_mgmnt_alert_dt)
			log_message = "Discharge Summary Printed after last alert"
			log_retval = 0
			log_misc1 = 'CASEMGNT'
		elseif(usr->list[d.seq].user_casemgnt_alert_received = ' ')
			log_message = "Alert the user..."
			log_misc1 = 'CASEMGNT'
			log_retval = 100
		endif
	endif
with nocounter
 
 
call echo(build2('log message = ',log_message, '-- logmisc1 = ', log_misc1, '--  retval = ', log_retval))
 
 
 
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
;-------------------------------------------------------------------------
 
call echorecord(usr)
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
 
 
 
 
 
 
 
 
;-------------------------------------------------------------------------
 
 
/*
Head report
	cnt = 0
	EKSOPSRequest->expert_trigger = "CALL_FLU_IMM_EKM_FROM_OPS"
 
Detail
	cnt += 1
	if(mod(cnt,10) = 1)
		stat = alterlist(EKSOPSRequest->qual, cnt + 9)
	endif
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].encntr_id = e.encntr_id
 
Foot report
stat = alterlist(EKSOPSRequest->qual, cnt)
 
with nocounter
 
call echorecord(EKSOPSRequest)
 
 
 
;**********************************************
; Call EXPERT_EVENT
;**********************************************
 /*
if (cnt > 0)
	set dparam = 0
      call srvRequest(dparam)
endif
*/
 
endif ;rec_cnt
 
end
go
 
 

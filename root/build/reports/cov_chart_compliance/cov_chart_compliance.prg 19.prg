/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				   Chad Cummings
	Date Written:		   03/01/2019
	Solution:			   Behavior Health
	Source file name:	   cov_chart_compliance
	Object name:		   cov_chart_compliance
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_chart_compliance:dba go
create program cov_chart_compliance:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to
	, "Position" = VALUE(31767941.000000)     ;* Select a Position to Audit
	, "Personnel" = 0
	, "Beginning Date and Time" = "SYSDATE"   ;* First date and time to look for encounter relationships 

with OUTDEV, POSITION, USERS, BEG_DT_TM

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free record t_rec
record t_rec
(
	1 beg_dt_tm = dq8
	1 encntr_prsnl_reltn_cnt = i2
	1 encntr_prsnl_reltn_qual[*]
	 2 encntr_prsnl_r_cd = f8
	1 position_cnt = i2
	1 position_qual[*]
	 2 position_cd = f8
	 2 position_display = vc
	1 prsnl_cnt = i2
	1 prsnl_qual[*]
	 2 person_id = f8
	 2 name_full_formatted = vc
	 2 encntr_cnt = i2
	 2 encntr_qual[*]
	  3 encntr_id = f8
)

set t_rec->encntr_prsnl_reltn_cnt = (t_rec->encntr_prsnl_reltn_cnt + 3)
set stat = alterlist(t_rec->encntr_prsnl_reltn_qual,t_rec->encntr_prsnl_reltn_cnt)
set t_rec->encntr_prsnl_reltn_qual[1].encntr_prsnl_r_cd = code_values->cv.cs_333.attenddoc_cd
set t_rec->encntr_prsnl_reltn_qual[2].encntr_prsnl_r_cd = code_values->cv.cs_333.admitdoc_cd
set t_rec->encntr_prsnl_reltn_qual[3].encntr_prsnl_r_cd = code_values->cv.cs_333.nurseprac_cd


if (program_log->run_from_ops = 1)
	set t_rec->beg_dt_tm = datetimefind(cnvtlookbehind("7,D",cnvtdatetime(program_log->ops_date)), 'D', 'B', 'B')
else
	set t_rec->beg_dt_tm = cnvtdatetime($BEG_DT_TM)
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Positions **********************************"))

select into "nl:"
from
	code_value cv1
plan cv1
	where cv1.code_value = $POSITION
	and   cv1.active_ind = 1
order by
	cv1.code_value
head cv1.code_value
	t_rec->position_cnt = (t_rec->position_cnt + 1)
	stat = alterlist(t_rec->position_qual,t_rec->position_cnt)
	t_rec->position_qual[t_rec->position_cnt].position_cd = cv1.code_value
	t_rec->position_qual[t_rec->position_cnt].position_display = cv1.display
	call writeLog(build2("-->Found Position:",
							trim(cnvtstring(cv1.code_value)),":",cv1.display))
with nocounter

if (t_rec->position_cnt <= 0)
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "POSITIONS"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "position_cd"
	set reply->status_data.subeventstatus.targetobjectvalue = "No positions selected in CS 88"
	go to exit_script
endif

call writeLog(build2("* END   Finding Positions **********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Personnel **********************************"))

select 
if (program_log->run_from_ops = 1)
	where expand(i,1,t_rec->position_cnt,p1.position_cd,t_rec->position_qual[i].position_cd)
	and   p1.active_ind = 1
	and   p1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   p1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
else
	where p1.person_id = $USERS
	and   p1.active_ind = 1
	and   p1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   p1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
endif
into "nl:"
from
	prsnl p1
plan p1
order by
	 p1.name_full_formatted
	,p1.person_id
head p1.person_id
	t_rec->prsnl_cnt = (t_rec->prsnl_cnt + 1)
	stat = alterlist(t_rec->prsnl_qual,t_rec->prsnl_cnt)
	t_rec->prsnl_qual[t_rec->prsnl_cnt].person_id = p1.person_id
	t_rec->prsnl_qual[t_rec->prsnl_cnt].name_full_formatted = p1.name_full_formatted
	call writeLog(build2("-->Found Personnel:",
							trim(cnvtstring(p1.person_id)),":",p1.name_full_formatted))
with nocounter

if (t_rec->prsnl_cnt <= 0)
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "PRSNL"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "prsnl_id"
	set reply->status_data.subeventstatus.targetobjectvalue = "No personnel selected from positions"
	go to exit_script
endif

call writeLog(build2("* END   Finding Personnel **********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Relationships ******************************"))

select into "nl:"
from
	 encntr_prsnl_reltn epr
	,encounter e
plan epr
	where expand(i,1,t_rec->prsnl_cnt,epr.prsnl_person_id,t_rec->prsnl_qual[i].person_id)
	and   expand(ii,1,t_rec->encntr_prsnl_reltn_cnt,epr.encntr_prsnl_r_cd,t_rec->encntr_prsnl_reltn_qual[ii].encntr_prsnl_r_cd)
	and   epr.end_effective_dt_tm >= cnvtdatetime(t_rec->beg_dt_tm)
	and   epr.expiration_ind = 0
join e
	where e.encntr_id = epr.encntr_id
order by
	 epr.prsnl_person_id
	,epr.encntr_id
head report
	cnt = 0
head epr.prsnl_person_id
	 idx = locateval(j,1,t_rec->prsnl_cnt,epr.prsnl_person_id,t_rec->prsnl_qual[j].person_id)
	 call writeLog(build2("->Located Provider:",
							trim(cnvtstring(idx)),":",
							t_rec->prsnl_qual[idx].name_full_formatted,":",
							trim(cnvtstring(epr.prsnl_person_id))))
head epr.encntr_id
	 if (idx > 0)
		t_rec->prsnl_qual[idx].encntr_cnt = (t_rec->prsnl_qual[idx].encntr_cnt + 1)
		stat = alterlist(t_rec->prsnl_qual[idx].encntr_qual,t_rec->prsnl_qual[idx].encntr_cnt)
		t_rec->prsnl_qual[idx].encntr_qual[t_rec->prsnl_qual[idx].encntr_cnt].encntr_id = e.encntr_id
		call writeLog(build2("-->Found Encounter:",
							trim(cnvtstring(e.encntr_id)),":",
							trim(cnvtstring(epr.encntr_prsnl_r_cd)),":",
							trim(cnvtstring(epr.expiration_ind))))
	 endif
with nocounter

call writeLog(build2("* END   Finding Relationships ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Personnel **********************************"))
call writeLog(build2("* END   Finding Positions **********************************"))
call writeLog(build2("************************************************************"))	
/*
select distinct into $OUTDEV
	 sending_position=uar_get_code_display(p1.position_cd)
	,sending_prsnl=p1.name_full_formatted
	,assigned_position=uar_get_code_display(p2.position_cd)
	,assigned_prsnl=p2.name_full_formatted
	,date_sent=ta.task_dt_tm ";;q"
	,task_type=uar_get_code_display(ta.task_type_cd)
	,task_status=uar_get_code_display(ta.task_status_cd)
	,activity_updt_dt_tm=taa.updt_dt_tm ";;q"
	,ta.msg_subject
	,ea.alias
	,p.name_full_formatted
	,facility=uar_get_code_display(e.loc_facility_cd)
	,unit=uar_get_code_display(e.loc_nurse_unit_cd)
	,event=uar_get_code_display(ce.event_cd)
	,ce.performed_dt_tm ";;q"
	,e.reg_dt_tm ";;q"
	,e.disch_dt_tm ";;q"
	;,ta.*
	;,taa.*
 
from
	task_activity_assignment taa
	,task_activity ta
	;,code_value cv1
	,prsnl p1
	,prsnl p2
	,clinical_event ce
	,encounter e
	,person p
	,encntr_alias ea
;plan cv1
;	where cv1.code_set = 88
;	and   cv1.display = "BH - Family Nurse Practitioner"
;	and   cv1.active_ind = 1
plan p1
	where p1.person_id = $USERS
join ta
	where ta.msg_sender_id = p1.person_id
	and   ta.task_type_cd = value(uar_get_code_by("MEANING",6026,"ENDORSE"))
	and   ta.active_ind = 1
join taa
	where taa.task_id = ta.task_id
	and   taa.beg_eff_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   taa.end_eff_dt_tm >= cnvtdatetime(curdate,curtime3)
join p2
	where p2.person_id = taa.assign_prsnl_id
join ce
	where ce.event_id = ta.event_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	;wand   ce.result_val        >  " "
join e
	where e.encntr_id = ce.encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.active_ind = 1
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	 p1.name_full_formatted
	,p2.name_full_formatted
	,ea.alias
with format,seperator= " ",nocounter
*/

set reply->status_data.status = "S"
set reply->status_data.subeventstatus.operationname = "SCRIPT"
set reply->status_data.subeventstatus.operationstatus = "S"
set reply->status_data.subeventstatus.targetobjectname = "script"
set reply->status_data.subeventstatus.targetobjectvalue = "Script executed successfully"

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)
call echorecord(reply)

end 
go

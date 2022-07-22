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
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Position" = VALUE(31767941.000000)    ;* Select a Position to Audit
	, "Personnel" = 0 

with OUTDEV, POSITION, USERS

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
stat = 1

with nocounter


call writeLog(build2("* END   Finding Positions **********************************"))
call writeLog(build2("************************************************************"))

	

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

#exit_script


end 
go

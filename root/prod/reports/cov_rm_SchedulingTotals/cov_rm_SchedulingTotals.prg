/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/02/2021
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_SchedulingTotals.prg
	Object name:		cov_rm_SchedulingTotals
	Request #:			6539
 
	Program purpose:	Lists totals for scheduled accounts.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_rm_SchedulingTotals:DBA go
create program cov_rm_SchedulingTotals:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Include Subtotals?" = 0 

with OUTDEV, start_datetime, end_datetime, report_type
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare canceled_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CANCELED"))
declare confirmed_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare hold_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "HOLD"))
declare noshow_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "NOSHOW"))
declare rescheduled_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))
declare attenddoc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDDOC"))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

;002
record sch_data (
	1 cnt						= i4
	1 list[*]
		2 plan_name				= c100
		2 health_plan_id		= f8
		2 scheduling_action		= c40
		2 action_dt_tm			= dq8
		2 total_action			= i4
)

;002
record calc_data (
	1 cnt							= i4
	1 list[*]
		2 plan_name					= c100
		2 health_plan_id			= f8
		2 total						= i4
		
		2 acnt						= i4
		2 actions[*]
			3 scheduling_action		= c40
			3 total_action			= i4
			
			3 adcnt					= i4
			3 action_dates[*]
				4 action_dt_tm		= dq8
				4 total_action_date	= i4
)

 
/**************************************************************/
; select scheduling data ;002
select distinct into "NL:"
	plan_name				= hp.plan_name
	, health_plan_id		= hp.health_plan_id
	, scheduling_action		= uar_get_code_display(sev.sch_state_cd)
	, action_dt_tm			= datetimetrunc(sea.action_dt_tm, "dd")
		
	, total_action			= count(distinct datetimetrunc(sea.action_dt_tm, "dd")) 
								over(partition by hp.health_plan_id, sev.sch_event_id, sev.sch_state_cd)
 
from
	ENCOUNTER e
 
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
		
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.end_effective_dt_tm > sysdate
		and hp.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = e.person_id
		and p.name_last_key not in ("ZZZ*")
		and p.active_ind = 1)
 
	, (inner join SCH_APPT sa on sa.encntr_id = e.encntr_id
		and sa.person_id = e.person_id
		and sa.role_meaning = "PATIENT"
		and sa.active_ind = 1)
 
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.role_meaning != "PATIENT"
		and sar.active_ind = 1)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.schedule_seq = sa.schedule_seq
		and sev.sch_state_cd in (confirmed_var)
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_ACTION sea on sea.sch_event_id = sev.sch_event_id
		and sea.action_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sea.active_ind = 1)
 
where
	e.active_ind = 1
 
order by
	plan_name
	, hp.health_plan_id
	, scheduling_action
	, action_dt_tm
	, sev.sch_event_id
 
 
; populate record structure
head report
	cnt = 0
	
detail
	cnt = cnt + 1
 
	call alterlist(sch_data->list, cnt)
 
	sch_data->cnt							= cnt
	sch_data->list[cnt].plan_name			= plan_name
	sch_data->list[cnt].health_plan_id		= health_plan_id
	sch_data->list[cnt].scheduling_action	= scheduling_action
	sch_data->list[cnt].action_dt_tm		= action_dt_tm
	sch_data->list[cnt].total_action		= total_action
	 
with nocounter
 
 
/**************************************************************/
; select calculated data ;002
select into "NL:"
	plan_name				= sch_data->list[d1.seq].plan_name
	, health_plan_id		= sch_data->list[d1.seq].health_plan_id
	, scheduling_action		= sch_data->list[d1.seq].scheduling_action
	, action_dt_tm			= sch_data->list[d1.seq].action_dt_tm
	
from
	(dummyt d1 with seq = value(sch_data->cnt))
 
plan d1
 
order by
	plan_name
	, health_plan_id
	, scheduling_action
	, action_dt_tm
 
 
; populate record structure
head report
	cnt = 0
	
head health_plan_id
	acnt = 0
	
	cnt = cnt + 1
 
	call alterlist(calc_data->list, cnt)
	
	calc_data->cnt							= cnt
	calc_data->list[cnt].plan_name			= sch_data->list[d1.seq].plan_name
	calc_data->list[cnt].health_plan_id		= sch_data->list[d1.seq].health_plan_id
	
head scheduling_action
	adcnt = 0
	
	acnt = acnt + 1
 
	call alterlist(calc_data->list[cnt].actions, acnt)
	
	calc_data->list[cnt].acnt								= acnt
	calc_data->list[cnt].actions[acnt].scheduling_action	= sch_data->list[d1.seq].scheduling_action
	
head action_dt_tm
	adcnt = adcnt + 1
 
	call alterlist(calc_data->list[cnt].actions[acnt].action_dates, adcnt)
	
	calc_data->list[cnt].actions[acnt].adcnt								= adcnt
	calc_data->list[cnt].actions[acnt].action_dates[adcnt].action_dt_tm		= sch_data->list[d1.seq].action_dt_tm
	
foot action_dt_tm 
	calc_data->list[cnt].actions[acnt].action_dates[adcnt].total_action_date = sum(sch_data->list[d1.seq].total_action)
	
foot scheduling_action 
	calc_data->list[cnt].actions[acnt].total_action = sum(sch_data->list[d1.seq].total_action)
	
foot health_plan_id 
	calc_data->list[cnt].total = sum(sch_data->list[d1.seq].total_action)
	
 
with nocounter
 
 
/**************************************************************/
; select final data ;002
select 
	if ($report_type = 1)
		plan_name				= calc_data->list[d1.seq].plan_name
		, scheduling_action		= calc_data->list[d1.seq].actions[d2.seq].scheduling_action
		, action_dt_tm			= calc_data->list[d1.seq].actions[d2.seq].action_dates[d3.seq].action_dt_tm ";;d"
		, sub_total				= calc_data->list[d1.seq].actions[d2.seq].action_dates[d3.seq].total_action_date	
		, total					= calc_data->list[d1.seq].total
		
		order by
			plan_name
			, calc_data->list[d1.seq].health_plan_id
			, scheduling_action
			, calc_data->list[d1.seq].actions[d2.seq].action_dates[d3.seq].action_dt_tm
	
	else
		plan_name				= calc_data->list[d1.seq].plan_name
		, scheduling_action		= calc_data->list[d1.seq].actions[d2.seq].scheduling_action
		, total					= calc_data->list[d1.seq].total
		
		order by
			plan_name
			, calc_data->list[d1.seq].health_plan_id
			, scheduling_action
		
	endif		
	
distinct into $OUTDEV
from
	(dummyt d1 with seq = value(calc_data->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
 
plan d1 where maxrec(d2, calc_data->list[d1.seq].acnt)
join d2 where maxrec(d3, calc_data->list[d1.seq].actions[d2.seq].adcnt)
join d3
 
order by
	plan_name
	, calc_data->list[d1.seq].health_plan_id
	, scheduling_action
	, calc_data->list[d1.seq].actions[d2.seq].action_dates[d3.seq].action_dt_tm
 
with nocounter, separator = " ", format, time = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
;call echorecord(sch_data)
;call echorecord(calc_data)

#exitscript
 
end
go
 

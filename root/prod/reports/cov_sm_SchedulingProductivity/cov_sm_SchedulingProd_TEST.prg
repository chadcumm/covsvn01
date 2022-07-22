/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/31/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingProductivity.prg
	Object name:		cov_sm_SchedulingProductivity
	Request #:			4325, 11683
 
	Program purpose:	Lists productivity totals for schedulers.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/06/2019	Todd A. Blanchard		Added check for HOLD status to criteria.
002	02/06/2020	Todd A. Blanchard		Revised CCL for accuracy.
003	12/03/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
 
******************************************************************************/
 
drop program cov_sm_SchedulingProd_TEST:DBA go
create program cov_sm_SchedulingProd_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Start Date" = "SYSDATE" 
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, start_datetime, end_datetime
 
 
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
declare op_facility_var						= c2 with noconstant("")
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

;002
record sch_data (
	1 cnt						= i4
	1 list[*]
		2 scheduler				= c100
		2 scheduler_id			= f8
		2 scheduling_action		= c40
		2 total_action			= i4
)

;002
record calc_data (
	1 cnt							= i4
	1 list[*]
		2 scheduler					= c100
		2 scheduler_id				= f8
		
		2 acnt						= i4
		2 actions[*]
			3 scheduling_action		= c40
			3 total_action			= i4
			
		2 total						= i4
)

 
/**************************************************************/
; select scheduling data ;002
select distinct into "NL:"
	scheduler				= per2.name_full_formatted
	, scheduler_id			= sea.action_prsnl_id
	, scheduling_action		= uar_get_code_display(sev.sch_state_cd)
		
	, total_action			= count(distinct datetimetrunc(sea.action_dt_tm, "dd")) 
								over(partition by sea.action_prsnl_id, sev.sch_event_id, sev.sch_state_cd)
 
from
	ENCOUNTER e
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = 1077.00 ; fin
		and eaf.active_ind = 1)
 
	, (left join ENCNTR_PRSNL_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.encntr_prsnl_r_cd = attenddoc_var
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join PRSNL per on per.person_id = epr.prsnl_person_id
		and per.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = e.person_id
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
		and sev.sch_state_cd in (canceled_var, confirmed_var, hold_var, noshow_var, rescheduled_var)
;		and sev.sch_state_cd in (hold_var) ; TESTING
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_ACTION sea on sea.sch_event_id = sev.sch_event_id
		and sea.action_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sea.active_ind = 1)
 
	, (inner join PRSNL per2 on per2.person_id = sea.action_prsnl_id
		and per2.person_id > 0.0
		and per2.active_ind = 1)
 
where
	operator(e.organization_id, op_facility_var, $facility)
	and e.organization_id in (
		3144501.00,
		675844.00,
		3144505.00,
		3144499.00,
		3144502.00,
		3144503.00,
		3144504.00,
		3234074.00,
		3898154.00	;003
	)
	and e.active_ind = 1
;	and sea.action_prsnl_id = 16561536.00 ; TESTING
 
order by
	scheduler
	, sea.action_prsnl_id
	, scheduling_action
	, sev.sch_event_id
 
 
; populate record structure
head report
	cnt = 0
	
detail
	cnt = cnt + 1
 
	call alterlist(sch_data->list, cnt)
 
	sch_data->cnt							= cnt
	sch_data->list[cnt].scheduler			= scheduler
	sch_data->list[cnt].scheduler_id		= scheduler_id
	sch_data->list[cnt].scheduling_action	= scheduling_action
	sch_data->list[cnt].total_action		= total_action
	 
with nocounter
 
 
/**************************************************************/
; select calculated data ;002
select into "NL:"
	scheduler				= sch_data->list[d1.seq].scheduler
	, scheduler_id			= sch_data->list[d1.seq].scheduler_id
	, scheduling_action		= sch_data->list[d1.seq].scheduling_action
	
from
	(dummyt d1 with seq = value(sch_data->cnt))
 
plan d1
 
order by
	scheduler
	, scheduler_id
	, scheduling_action
 
 
; populate record structure
head report
	cnt = 0
	
head scheduler_id
	acnt = 0
	
	cnt = cnt + 1
 
	call alterlist(calc_data->list, cnt)
	
	calc_data->cnt							= cnt
	calc_data->list[cnt].scheduler			= sch_data->list[d1.seq].scheduler
	calc_data->list[cnt].scheduler_id		= sch_data->list[d1.seq].scheduler_id
	
head scheduling_action
	acnt = acnt + 1
 
	call alterlist(calc_data->list[cnt].actions, acnt)
	
	calc_data->list[cnt].acnt								= acnt
	calc_data->list[cnt].actions[acnt].scheduling_action	= sch_data->list[d1.seq].scheduling_action
	
foot scheduling_action 
	calc_data->list[cnt].actions[acnt].total_action			= sum(sch_data->list[d1.seq].total_action)
	
foot scheduler_id 
	calc_data->list[cnt].total								= sum(sch_data->list[d1.seq].total_action)
	
 
with nocounter
 
 
/**************************************************************/
; select final data ;002
select into $OUTDEV
	scheduler				= calc_data->list[d1.seq].scheduler
	, scheduling_action		= calc_data->list[d1.seq].actions[d2.seq].scheduling_action
	, total_action			= calc_data->list[d1.seq].actions[d2.seq].total_action	
	, total					= calc_data->list[d1.seq].total
	
from
	(dummyt d1 with seq = value(calc_data->cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, calc_data->list[d1.seq].acnt)
join d2
 
order by
	scheduler
	, calc_data->list[d1.seq].scheduler_id
	, scheduling_action
 
with nocounter, separator = " ", format, time = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
;call echorecord(sch_data)
;call echorecord(calc_data)

#exitscript
 
end
go
 

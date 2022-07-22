/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/19/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingResource_PBH.prg
	Object name:		cov_sm_SchedulingResource_PBH
	Request #:			3613, 12349
 
	Program purpose:	Lists scheduled resources from Report Request module.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	11/30/2018	Todd A. Blanchard		Adjusted CCL logic.
 										Added prompt for patient.
 	12/04/2018	Todd A. Blanchard		Adjusted patient parameter.
 	12/20/2018	Todd A. Blanchard		Adjusted queue prompt and limited results to
 										behavioral health data.
	03/08/2022	Todd A. Blanchard		Changed practice site display to org name.
 
******************************************************************************/
 
drop program cov_sm_SchedulingResource_PBH:DBA go
create program cov_sm_SchedulingResource_PBH:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Request List Queue" = 0
	, "Patient" = VALUE(0.0) 

with OUTDEV, request_queue, patient
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare pending_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 23018, "PENDING"))
declare request_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "REQUEST"))
declare request_list_queue_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16146, "REQUESTLISTQUEUE"))
declare sch_auth_number_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHAUTHNUMBER"))
declare ord_physician_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULING ORDERING PHYSICIAN"))
declare num								= i4 with noconstant(0)
declare novalue							= vc with constant("Not Available")
declare op_request_queue_var			= c2 with noconstant("")
declare op_patient_var					= c2 with noconstant("")
 
 
; define operator for $request_queue
if (substring(1, 1, reflect(parameter(parameter2($request_queue), 0))) = "L") ; multiple values selected
    set op_request_queue_var = "IN"
elseif (parameter(parameter2($request_queue), 1) = 0.0) ; any selected
    set op_request_queue_var = "!="
else
    set op_request_queue_var = "=" ; single value selected
endif
 
 
; define operator for $patient
if (substring(1, 1, reflect(parameter(parameter2($patient), 0))) = "L") ; multiple values selected
    set op_patient_var = "IN"
elseif (parameter(parameter2($patient), 1) = 0.0) ; any selected
    set op_patient_var = "!="
else
    set op_patient_var = "=" ; single value selected
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_obj (
	1	bh_flg							= i2
 
	1	sched_cnt						= i4
	1	list[*]
		2	sch_object_id				= f8
		2	sch_obj_desc				= c100
 
		2	sch_entry_id				= f8
		2	sch_action_id				= f8
		2	sch_appt_id					= f8
		2	req_action					= c20
		2	appt_type					= c100
		2	earliest_dt_tm				= dq8
 
		2	sch_event_id				= f8
		2	ordering_physician			= c100
		2	ord_phys_group				= c100
 
		2	order_id					= f8
		2	order_mnemonic				= c100
		2	order_dt_tm					= dq8
		2	prior_auth					= c30
 
		2	sch_dt_tm					= dq8
		2	sch_resource				= c100
 
		2	person_id					= f8
		2	patient_name				= c100
 
 		2	encntr_id					= f8
 
		2	health_plan					= c35
)
 
 
/**************************************************************/
; select scheduled object data
select into "NL:"
from
	SCH_OBJECT so
 
	, (inner join SCH_ENTRY sen on sen.queue_id = so.sch_object_id
		and sen.entry_state_cd = pending_var ; pending
		and sen.active_ind = 1)
 
	, (inner join SCH_EVENT_ACTION seva on seva.sch_action_id = sen.sch_action_id
		and seva.version_dt_tm > sysdate)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = seva.sch_event_id
		and sev.version_dt_tm > sysdate)
 
	, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.oe_field_id = ord_physician_var
		and sed.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
		and sed.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and sed.active_ind = 1)
 
	, (left join PRSNL per on per.person_id = sed.oe_field_value
		and per.active_ind = 1)
 
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 
	, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id)
 
	, (left join SCH_APPT sa on sa.sch_event_id = sev.sch_event_id
		and sa.role_meaning = "PATIENT"
		and sa.version_dt_tm > sysdate)
 
	, (left join SCH_APPT sar on sar.sch_event_id = sev.sch_event_id
		and sar.role_meaning != "PATIENT"
		and sar.version_dt_tm > sysdate)
 
	, (inner join PERSON p on p.person_id = sen.person_id
		and operator(p.person_id, op_patient_var, $patient)) ; patient
 
	, (left join ENCOUNTER e on e.encntr_id = sen.encntr_id
		and e.active_ind = 1)
 
where
	operator(so.sch_object_id, op_request_queue_var, $request_queue) ; request queue
	and so.object_type_cd = request_list_queue_var
	and so.mnemonic_key in ("BH*", "PBH*")
	and so.active_ind = 1
		
order by
	so.sch_object_id
	, sev.sch_event_id
 
 
; populate sched_obj record structure
head report
	cnt = 0
 
	call alterlist(sched_obj->list, 100)
 
head so.sch_object_id
	null
 
head sev.sch_event_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_obj->list, cnt + 9)
	endif
 
	sched_obj->sched_cnt							= cnt
	sched_obj->list[cnt].sch_object_id				= so.sch_object_id
	sched_obj->list[cnt].sch_obj_desc				= so.description
 
	sched_obj->list[cnt].sch_entry_id				= sen.sch_entry_id
	sched_obj->list[cnt].sch_action_id				= sen.sch_action_id
	sched_obj->list[cnt].sch_appt_id				= sen.sch_appt_id
	sched_obj->list[cnt].req_action					= trim(uar_get_code_display(sen.req_action_cd), 3)
	sched_obj->list[cnt].appt_type					= trim(uar_get_code_display(sen.appt_type_cd), 3)
	sched_obj->list[cnt].earliest_dt_tm				= sen.earliest_dt_tm
 
	sched_obj->list[cnt].sch_event_id				= sev.sch_event_id
	sched_obj->list[cnt].ordering_physician			= trim(sed.oe_field_display_value, 3)
	sched_obj->list[cnt].ord_phys_group				= trim(org_ps.org_name, 3)
 
	sched_obj->list[cnt].person_id					= p.person_id
	sched_obj->list[cnt].patient_name				= p.name_full_formatted
 
	sched_obj->list[cnt].sch_dt_tm					= sa.beg_dt_tm
	sched_obj->list[cnt].sch_resource				= trim(uar_get_code_display(sar.resource_cd), 3)
 
 	sched_obj->list[cnt].encntr_id					= e.encntr_id
 
foot report
	call alterlist(sched_obj->list, cnt)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select scheduled procedures data
select distinct into "NL:"
from
	SCH_EVENT_ATTACH sea
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_id = sch_auth_number_var)
 
where
	expand(num, 1, size(sched_obj->list, 5), sea.sch_event_id, sched_obj->list[num].sch_event_id)
	and sea.order_status_meaning not in ("CANCELED", "COMPLETED", "DISCONTINUED")
	and sea.state_meaning != "REMOVED"
	and sea.active_ind = 1
 
order by
	sea.sch_event_id
	, o.order_id
 
 
; populate sched_obj record structure with procedure data
head sea.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sea.sch_event_id, sched_obj->list[numx].sch_event_id)
 
detail
	sched_obj->list[idx].order_id = o.order_id
	sched_obj->list[idx].order_mnemonic = trim(o.order_mnemonic, 3)
	sched_obj->list[idx].order_dt_tm = o.current_start_dt_tm
	sched_obj->list[idx].prior_auth = trim(od.oe_field_display_value, 3)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select encounter health plan data
select into "NL:"
from
	SCH_ENTRY sen
 
	; encounter health plan
	, (inner join ENCNTR_PLAN_RELTN epr on epr.encntr_id = sen.encntr_id
		and epr.priority_seq = (
			select min(eprm.priority_seq)
			from ENCNTR_PLAN_RELTN eprm
			where
				eprm.encntr_id = epr.encntr_id
				and eprm.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
				and eprm.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
				and eprm.active_ind = 1
		)
		and epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
		and epr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
		and epr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1)
 
where
	expand(num, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[num].sch_event_id)
	and sen.active_ind = 1
 
order by
	sen.sch_event_id
 
 
; populate sched_obj record structure with health plan data
head sen.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[numx].sch_event_id)
 
detail
 	sched_obj->list[idx].health_plan = trim(hp.plan_name, 3)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select patient health plan data
select into "NL:"
from
	SCH_ENTRY sen
 
	; patient health plan
	, (inner join PERSON_PLAN_RELTN ppr on ppr.person_id = sen.person_id
		and ppr.priority_seq = (
			select min(pprm.priority_seq)
			from PERSON_PLAN_RELTN pprm
			where
				pprm.person_id = ppr.person_id
				and pprm.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
				and pprm.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
				and pprm.active_ind = 1
		)
		and ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
		and ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
		and ppr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = ppr.health_plan_id
		and hp.active_ind = 1)
 
where
	expand(num, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[num].sch_event_id)
	and sen.active_ind = 1
 
order by
	sen.sch_event_id
 
 
; populate sched_obj record structure with health plan data
head sen.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[numx].sch_event_id)
 
detail
	if (sched_obj->list[idx].encntr_id <= 0)
 		sched_obj->list[idx].health_plan = trim(hp.plan_name, 3)
	endif
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select data
select into $OUTDEV
	request_list_queue		= sched_obj->list[d1.seq].sch_obj_desc
	, request_action		= sched_obj->list[d1.seq].req_action
	, patient_name			= sched_obj->list[d1.seq].patient_name
	, prior_auth			= sched_obj->list[d1.seq].prior_auth
	, health_plan			= sched_obj->list[d1.seq].health_plan
	, appt_type				= sched_obj->list[d1.seq].appt_type
	, earliest_date			= evaluate2(
								if (cnvtdate(sched_obj->list[d1.seq].earliest_dt_tm) > 1)
									cnvtupper(build2(
										format(sched_obj->list[d1.seq].earliest_dt_tm, "mm/dd/yyyy;;d"), " - ",
										format(sched_obj->list[d1.seq].earliest_dt_tm, "hh:mm;;s")))
								else
									""
								endif
								)
	, time					= evaluate2(
								if (format(sched_obj->list[d1.seq].earliest_dt_tm, "hh:mm;;d") != "00:00")
									format(sched_obj->list[d1.seq].earliest_dt_tm, "hh:mm;;d")
								else
									""
								endif
								)
	, order_date			= evaluate2(
								if (sched_obj->list[d1.seq].order_dt_tm > 0)
									cnvtupper(build2(
										format(sched_obj->list[d1.seq].order_dt_tm, "mm/dd/yyyy;;d"), " - ",
										format(sched_obj->list[d1.seq].order_dt_tm, "hh:mm;;s")))
								else
									""
								endif
								)
	, orders				= sched_obj->list[d1.seq].order_mnemonic
	, ordering_phy			= sched_obj->list[d1.seq].ordering_physician
	, group_practice		= sched_obj->list[d1.seq].ord_phys_group
	, scheduled_date		= evaluate2(
								if (sched_obj->list[d1.seq].sch_dt_tm > 0)
									cnvtupper(build2(
										format(sched_obj->list[d1.seq].sch_dt_tm, "mm/dd/yyyy;;d"), " - ",
										format(sched_obj->list[d1.seq].sch_dt_tm, "hh:mm;;s")))
								else
									""
								endif
								)
	, scheduled_resource	= sched_obj->list[d1.seq].sch_resource
 
from
	(dummyt d1 with seq = value(sched_obj->sched_cnt))
 
plan d1
 
order by
	sched_obj->list[d1.seq].sch_obj_desc
;	, sched_obj->list[d1.seq].sch_entry_id
	, sched_obj->list[d1.seq].sch_action_id
	, sched_obj->list[d1.seq].sch_appt_id
 
with nocounter, separator = " ", format, time = 60
 
 
call echorecord(sched_obj)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

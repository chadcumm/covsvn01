/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		03/23/2020
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Scheduling_Addon.prg
	Object name:		cov_sm_Scheduling_Addon
	Request #:			7174, 11683
 
	Program purpose:	Provides information regarding add-on patients.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	12/03/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
 
******************************************************************************/
 
drop program cov_sm_Scheduling_Addon:DBA go
create program cov_sm_Scheduling_Addon:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"            ;* Enter or select the printer or file name to send this report to.
	, "Report or Grid" = 0
	, "Facility" = 0
	, "Department" = 0
	, "Appointment Start/End Date" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Scheduled Action Start/End Date" = "SYSDATE"
	, "End Date/Time" = "SYSDATE" 

with OUTDEV, report_grid, facility, department, appt_start_datetime, 
	appt_end_datetime, action_start_datetime, action_end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare get_LocationCode(data = f8) = f8
declare get_OrganizationId(data = f8) = f8
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare home_phone_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare confirm_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CONFIRM"))
declare cancel_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CANCEL"))
declare confirmed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare canceled_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CANCELED"))
declare admitphys_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN"))
declare attach_type_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare ord_physician_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULING ORDERING PHYSICIAN"))
declare attach_state_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 23012, "ACTIVE"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare order_status_future_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare order_status_ordered_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare schedauthnbr_var			= f8 with constant(124.00)
declare location_var				= f8 with noconstant(0.0)
declare organization_var			= f8 with noconstant(0.0)
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
declare op_department_var			= c2 with noconstant("")
 
 
; get locations
set location_var = get_LocationCode($facility)
 
; get organization
set organization_var = get_OrganizationId(location_var)
 
 
; define operator for $department
if (substring(1, 1, reflect(parameter(parameter2($department), 0))) = "L") ; multiple values selected
    set op_department_var = "IN"
elseif (parameter(parameter2($department), 1) = 0.0) ; any selected
    set op_department_var = "!="
else ; single value selected
    set op_department_var = "="
endif
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
free record sched_appt
record sched_appt (
	1	appt_start_datetime			= dq8
	1	appt_end_datetime			= dq8
	1	action_start_datetime		= dq8
	1	action_end_datetime			= dq8
	
	1	sched_cnt					= i4
	1	list[*]
		2	sch_appt_id				= f8
		2	appt_dt_tm				= dq8
		2	appt_type				= c40
		2	resource				= c40
		2	resource_seq			= i4
		2	location				= c40
		2	loc_seq					= i4
		2	dept					= c40
		2	dept_seq				= i4
		2	loc_facility			= c40
		2	org_name				= c100
 
		2	sch_event_id			= f8
		2	ord_phys_id				= f8
		2	ord_phys				= c100
		2	order_id				= f8
		2	order_mnemonic			= c100
		
		2	sch_action				= c40
		2	action_dt_tm			= dq8
		2	action_prsnl			= c100
		
		2	encntr_id				= f8
		2	encntr_type				= c40
		2	encntr_status			= c40
		
		2	auth_nbr				= c50		
		2	prior_auth				= c30
 
		2	person_id				= f8
		2	patient_name			= c100
		2	dob						= dq8
		2	home_phone				= c20
		2	fin						= c20
 
		2	appt_book_id			= f8
) with persistscript


; set prompt values
set sched_appt->appt_start_datetime		= cnvtdatetime($appt_start_datetime)
set sched_appt->appt_end_datetime		= cnvtdatetime($appt_end_datetime)
set sched_appt->action_start_datetime	= cnvtdatetime($action_start_datetime)
set sched_appt->action_end_datetime		= cnvtdatetime($action_end_datetime)
 
 
; select scheduled appointment data
select into "NL:"
from
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($appt_start_datetime) and cnvtdatetime($appt_end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd in (confirmed_var, canceled_var)
		and sar.active_ind = 1)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = $facility) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on operator(sab2.appt_book_id, op_department_var, $department) ; department
		and sab2.appt_book_id = sbl.child_appt_book_id)
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource (resource)
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id) ; resource
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource (resource)
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
 	; scheduled event
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, canceled_var)
		and sev.active_ind = 1)
		
	, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.oe_field_id = ord_physician_var
		and sed.end_effective_dt_tm > sysdate
		and sed.active_ind = 1)
  
	; last confirm
	, (inner join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
		and seva.action_meaning in ("CONFIRM", "CANCEL")
		and seva.action_dt_tm between cnvtdatetime($action_start_datetime) and cnvtdatetime($action_end_datetime)
		and seva.action_dt_tm = (
			select max(action_dt_tm)
			from SCH_EVENT_ACTION
			where
				sch_event_id = seva.sch_event_id
				and action_meaning in ("CONFIRM", "CANCEL")
				and action_dt_tm between cnvtdatetime($action_start_datetime) and cnvtdatetime($action_end_datetime)
				and active_ind = 1
			group by
				sch_event_id
		)
		and seva.active_ind = 1
		)
 
	, (inner join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id)
	
	; order
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.attach_type_cd = attach_type_var
;		and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED")
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.template_order_id = 0.0
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning_id = schedauthnbr_var)
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
;		and oa.action_type_cd = order_var
		and oa.action_sequence > 0)
 
	, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id)
				
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var ; home
		and ph.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.person_id = p.person_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var) ; fin
 
	; health plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
		and epar.active_ind = 1)
 
	, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
		and au.active_ind = 1)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id)
 
where
	sa.beg_dt_tm between cnvtdatetime($appt_start_datetime) and cnvtdatetime($appt_end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd in (confirmed_var, canceled_var)
	and sa.active_ind = 1
	and
		sar.resource_cd = evaluate2(
			if (sbl2.resource_cd = 0.0)
				sbl3.resource_cd
			else
				sbl2.resource_cd
			endif)
 
order by
	p.name_full_formatted
	, p.person_id
	, sa.sch_appt_id
 
 
; populate sched_appt record structure
head report
	cnt = 0
 
	call alterlist(sched_appt->list, 100)
 
head sa.sch_appt_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_appt->list, cnt + 9)
	endif
 
	sched_appt->sched_cnt						= cnt
	sched_appt->list[cnt].sch_appt_id			= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm			= sa.beg_dt_tm
	sched_appt->list[cnt].appt_type				= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].resource				= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].resource_seq			= sbl3.seq_nbr
	sched_appt->list[cnt].location				= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].loc_seq				= sbl2.seq_nbr
	sched_appt->list[cnt].dept					= trim(sab2.mnemonic, 3)
	sched_appt->list[cnt].dept_seq				= sbl.seq_nbr
	sched_appt->list[cnt].loc_facility			= trim(uar_get_code_display(e.loc_facility_cd), 3) 
	sched_appt->list[cnt].org_name				= trim(org.org_name, 3) 
 
	sched_appt->list[cnt].sch_event_id			= sa.sch_event_id
														
	sched_appt->list[cnt].ord_phys				= evaluate2(
													if (size(trim(sed.oe_field_display_value, 3)) > 0)
														trim(sed.oe_field_display_value, 3)
													else
														trim(per_oa.name_full_formatted, 3)
													endif
													)
														
	sched_appt->list[cnt].order_id				= o.order_id
	sched_appt->list[cnt].order_mnemonic		= o.order_mnemonic
	
	sched_appt->list[cnt].sch_action			= trim(uar_get_code_display(sev.sch_state_cd), 3)
	sched_appt->list[cnt].action_dt_tm			= seva.action_dt_tm
	sched_appt->list[cnt].action_prsnl			= per_seva.name_full_formatted
	
	sched_appt->list[cnt].encntr_id				= e.encntr_id
	sched_appt->list[cnt].encntr_type			= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[cnt].encntr_status			= trim(uar_get_code_display(e.encntr_status_cd), 3)
 
	sched_appt->list[cnt].auth_nbr				= au.auth_nbr	
	sched_appt->list[cnt].prior_auth			= od.oe_field_display_value
	
	sched_appt->list[cnt].person_id				= p.person_id
	sched_appt->list[cnt].patient_name			= trim(p.name_full_formatted, 3)
	sched_appt->list[cnt].dob					= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
	sched_appt->list[cnt].home_phone			= trim(ph.phone_num, 3)
	sched_appt->list[cnt].fin					= trim(eaf.alias, 3)
	
	sched_appt->list[cnt].appt_book_id			= sab.appt_book_id
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter
 
 
/**************************************************************/
; select final data
if ($report_grid = 1)
	select into $OUTDEV
		appt_dt_tm				= build2(format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yy;;q"), " ", 
										 format(sched_appt->list[d1.seq].appt_dt_tm, "hh:mm;;s"))
										 
		, appt_type				= trim(sched_appt->list[d1.seq].appt_type, 3)
		, sch_action			= trim(sched_appt->list[d1.seq].sch_action, 3)
		
		, name					= trim(sched_appt->list[d1.seq].patient_name, 3)
		, dob					= format(sched_appt->list[d1.seq].dob, "mm/dd/yyyy;;d")
		
		, phone					= evaluate2(
									if (sched_appt->list[d1.seq].home_phone > " ")
										format(sched_appt->list[d1.seq].home_phone, "###-###-####")
									endif
									)

		, fin					= trim(sched_appt->list[d1.seq].fin, 3)
		, auth					= evaluate2(
									if (size(trim(sched_appt->list[d1.seq].auth_nbr, 3)) > 0)
										trim(sched_appt->list[d1.seq].auth_nbr, 3)
									else
										trim(sched_appt->list[d1.seq].prior_auth, 3)
									endif
									)
										 
		, sch_person			= trim(sched_appt->list[d1.seq].action_prsnl, 3)
		
		, sch_action_dt_tm		= build2(format(sched_appt->list[d1.seq].action_dt_tm, "mm/dd/yy;;q"), " ", 
										 format(sched_appt->list[d1.seq].action_dt_tm, "hh:mm;;s"))
		
		, ordering_physician	= trim(sched_appt->list[d1.seq].ord_phys, 3)
		, facility				= trim(sched_appt->list[d1.seq].loc_facility, 3)
		, location				= trim(sched_appt->list[d1.seq].location, 3)
		
		, order_description		= trim(sched_appt->list[d1.seq].order_mnemonic, 3)
		
		, appts_for				= build2(
									if (cnvtdate(sched_appt->appt_start_datetime) = cnvtdate(sched_appt->appt_end_datetime))
										format(cnvtdate(sched_appt->appt_start_datetime), "mm/dd/yyyy;;d")
									else
										build2(
											format(cnvtdate(sched_appt->appt_start_datetime), "mm/dd/yyyy;;d"), " to ",
											format(cnvtdate(sched_appt->appt_end_datetime), "mm/dd/yyyy;;d")
										)
									endif			
									)
			
		, sch_actions_on		= build2(
									if (cnvtdate(sched_appt->action_start_datetime) = cnvtdate(sched_appt->action_end_datetime))
										build2(
											format(cnvtdate(sched_appt->action_start_datetime), "mm/dd/yyyy;;d"), " from ",
											format(cnvtdatetime(sched_appt->action_start_datetime), "hh:mm;;s"), " to ",
											format(cnvtdatetime(sched_appt->action_end_datetime), "hh:mm;;s")
										)
									else
										build2(
											format(cnvtdate(sched_appt->action_start_datetime), "mm/dd/yyyy;;d"), " ",
											format(cnvtdatetime(sched_appt->action_start_datetime), "hh:mm;;s"), " to ",
											format(cnvtdate(sched_appt->action_end_datetime), "mm/dd/yyyy;;d"), " ",
											format(cnvtdatetime(sched_appt->action_end_datetime), "hh:mm;;s")
										)
									endif
									)
			
		, report_dt_tm			= build2(curdate, " ", curtime)
	
	from
		(dummyt d1 with seq = value(sched_appt->sched_cnt))
	 
	plan d1
	 
	order by
		sched_appt->list[d1.seq].action_dt_tm
		, name
		, sched_appt->list[d1.seq].person_id
		, appt_type
	 
	with nocounter, separator = " ", format, time = 60
endif

 
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 


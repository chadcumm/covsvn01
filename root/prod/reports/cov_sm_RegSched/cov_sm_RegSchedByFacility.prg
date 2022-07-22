/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		07/11/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_RegSchedByFacility.prg
	Object name:		cov_sm_RegSchedByFacility
	Request #:			2328, 7456, 11683, 11819
 
	Program purpose:	Lists scheduled appointments for selected facility.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	09/06/2018	Todd A. Blanchard		Added FSR West Diagnostic Center to prompt.
002	09/10/2018	Todd A. Blanchard		Corrected prompt for FSR.
003	10/29/2018	Todd A. Blanchard		Added MHHS Regional Diagnostic Center to prompt.
004	10/31/2018	Todd A. Blanchard		Adjusted criteria to filter out display-related 
 										bookshelf items.
005	06/18/2020	Todd A. Blanchard		Added report/grid prompt.
006	12/02/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
007	02/11/2022	Todd A. Blanchard		Added insurance data.
 
******************************************************************************/
 
drop program cov_sm_RegSchedByFacility:DBA go
create program cov_sm_RegSchedByFacility:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report or Grid" = 0
	, "Facility" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, report_grid, facility, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare get_ApptBookId(data = f8) = f8
declare get_OrganizationId(data = f8) = f8
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare home_phone_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare confirmed_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare attach_type_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare num				= i4 with noconstant(0)
declare novalue			= vc with constant("Not Available")
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_appt (
	1	p_facility			= vc
	1	p_appt_book			= f8
	1	p_organization		= f8
	1	p_start_datetime	= vc
	1	p_end_datetime		= vc
 
	1	sched_cnt			= i4
	1	list[*]
		2	sch_appt_id		= f8
		2	appt_dt_tm		= dq8
		2	room			= c40
		2	room_seq		= i4
		2	location		= c40
		2	loc_seq			= i4
		2	location_type	= c12
		2	dept			= c100
		2	dept_seq		= i4
 
		2	sch_event_id	= f8
		2	appt_type		= c40
		2	reason_exam		= c255
		2	instructions	= c255
 
		2 proc_cnt			= i4
		2 procedures[*]
			3	order_id				= f8
			3	order_mnemonic			= c100
			3	oe_field_dt_tm_value	= dq8
 
		2	person_id		= f8
		2	patient_name	= c100
		2	ssn				= c11
		2	dob				= dq8
		2	dob_tz			= i4
		2	mrn				= c20
		2	home_phone		= c20
 
 		2	encntr_id		= f8
 		2	encntr_type		= c40
		2	fin				= c20
 
		2	health_plan		= c35 ;007
 
		2	appt_book_id	= f8
)
 
 
/**************************************************************/
; populate record structure with prompt data
set sched_appt->p_facility = uar_get_code_description($facility)
set sched_appt->p_appt_book = get_ApptBookId($facility)
set sched_appt->p_organization = get_OrganizationId($facility)
set sched_appt->p_start_datetime = format(cnvtdate2($start_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
set sched_appt->p_end_datetime = format(cnvtdate2($end_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
 
/**************************************************************/
; select scheduled appointment data
select into "NL:"
from
	SCH_APPT sa
 
 	; scheduled room
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.primary_role_ind = 1
		and sar.state_meaning in ("CONFIRMED")
		and sar.active_ind = 1)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
	, (inner join ORGANIZATION o on o.organization_id = l.organization_id
		and o.organization_id = sched_appt->p_organization)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = sched_appt->p_appt_book) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on sab2.appt_book_id = sbl.child_appt_book_id
		; filter out display-type books
		and sab2.appt_book_id not in (
			1675708.00, 1674964.00, 1675706.00
		))	; department
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id) ; room
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
 	; scheduled event
	, (left join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var)
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_meaning = "SPECINX"
		and sed2.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var
		and ph.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (inner join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var)
 
	, (inner join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var)
 
where
	sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED")
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
	, format(sa.beg_dt_tm, "mm/dd/yyyy;;d")
	, sbl.seq_nbr
	, sbl2.seq_nbr
	, sbl3.seq_nbr
	, sa.beg_dt_tm
	, sa.end_dt_tm
 
 
; populate sched_appt record structure
head report
	cnt = 0
 
	call alterlist(sched_appt->list, 100)
 
head sa.sch_appt_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_appt->list, cnt + 9)
	endif
 
	sched_appt->sched_cnt					= cnt
	sched_appt->list[cnt].sch_appt_id		= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm		= sa.beg_dt_tm
	sched_appt->list[cnt].room				= uar_get_code_display(sar.resource_cd)
	sched_appt->list[cnt].room_seq			= sbl3.seq_nbr
	sched_appt->list[cnt].location			= uar_get_code_display(sa.appt_location_cd)
	sched_appt->list[cnt].location_type		= uar_get_code_meaning(l.location_type_cd)
	sched_appt->list[cnt].loc_seq			= sbl2.seq_nbr
	sched_appt->list[cnt].dept				= sab2.mnemonic
	sched_appt->list[cnt].dept_seq			= sbl.seq_nbr
 
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].appt_type			= uar_get_code_display(sev.appt_type_cd)
	sched_appt->list[cnt].reason_exam		= trim(sed1.oe_field_display_value, 3)
	sched_appt->list[cnt].instructions		= trim(sed2.oe_field_display_value, 3)
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].ssn				= cnvtalias(pas.alias, pas.alias_pool_cd)
	sched_appt->list[cnt].dob				= p.birth_dt_tm
	sched_appt->list[cnt].dob_tz			= p.birth_tz
	sched_appt->list[cnt].mrn				= eam.alias
	sched_appt->list[cnt].home_phone		= trim(ph.phone_num, 3)
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	sched_appt->list[cnt].fin				= eaf.alias
 
	sched_appt->list[cnt].appt_book_id		= sab.appt_book_id
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, separator = " ", format, time = 60
 
 
/**************************************************************/
; select scheduled procedures data
select distinct into "NL:"
from
	SCH_APPT sa
	
	, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.active_ind = 1)
 
	, (left join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
where
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sa.sch_event_id, sched_appt->list[num].sch_event_id)
		
order by
	sa.sch_appt_id
	, sa.sch_event_id
	, o.current_start_dt_tm
 
 
; populate sched_appt record structure with procedure data
head sa.sch_appt_id
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sa.sch_event_id, sched_appt->list[numx].sch_event_id)
 
detail
	cntx = cntx + 1
 
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
 	sched_appt->list[idx].proc_cnt = cntx
	sched_appt->list[idx].procedures[cntx].order_id = o.order_id
	sched_appt->list[idx].procedures[cntx].order_mnemonic = o.order_mnemonic
	sched_appt->list[idx].procedures[cntx].oe_field_dt_tm_value = o.current_start_dt_tm
 
foot sa.sch_appt_id
	if (cntx = 0)
		cntx = 1
	endif

 	sched_appt->list[idx].proc_cnt = cntx
 	
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, separator=" ", format, expand = 1, time = 60
 
 
/**************************************************************/
; select encounter health plan data ;007
select into "NL:"
from
	SCH_APPT sa
 
	; encounter health plan
	, (inner join ENCNTR_PLAN_RELTN epr on epr.encntr_id = sa.encntr_id
		and epr.priority_seq = (
			select min(eprm.priority_seq)
			from ENCNTR_PLAN_RELTN eprm
			where
				eprm.encntr_id = epr.encntr_id
				and eprm.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)
				and eprm.end_effective_dt_tm > cnvtdatetime (curdate, curtime3)
				and eprm.priority_seq > 0
				and eprm.active_ind = 1
		)
		and epr.beg_effective_dt_tm <= cnvtdatetime (curdate, curtime3)
		and epr.end_effective_dt_tm > cnvtdatetime (curdate, curtime3)
		and epr.priority_seq > 0
		and epr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1)
 
where
	expand(num, 1, size(sched_appt->list, 5), sa.sch_event_id, sched_appt->list[num].sch_event_id)
	and sa.active_ind = 1
 
order by
	sa.sch_event_id
 
 
; populate record structure with health plan data
head sa.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sa.sch_event_id, sched_appt->list[numx].sch_event_id)
 
detail
 	sched_appt->list[idx].health_plan = trim(hp.plan_name, 3)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select final data
if ($report_grid = 1)
	select distinct into $OUTDEV
		location				= build2(trim(sched_appt->list[d1.seq].location_type, 3), " | ",
									trim(sched_appt->list[d1.seq].location, 3))
		
		, name					= trim(sched_appt->list[d1.seq].patient_name, 3)
		, ssn					= trim(sched_appt->list[d1.seq].ssn, 3)
		, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob,
																	  sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
		
		, fin					= trim(sched_appt->list[d1.seq].fin, 3)
		, encntr_type			= trim(sched_appt->list[d1.seq].encntr_type, 3)
		
		, appt_type				= build2(trim(sched_appt->list[d1.seq].appt_type, 3), 
									evaluate(sched_appt->list[d1.seq].procedures[d2.seq].order_id, 0.0, "", 
										build2(" | ", trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3))
									))
		
		, appt_dt_tm			= build2(format(sched_appt->list[d1.seq].appt_dt_tm, "mmm dd, yyyy;;q"), " ", 
									format(sched_appt->list[d1.seq].appt_dt_tm, "hh:mm;;s"))
									
		, health_plan			= trim(sched_appt->list[d1.seq].health_plan, 3) ;007
										 	
	from
		(dummyt d1 with seq = value(sched_appt->sched_cnt))		
		, (dummyt d2 with seq = 1)
	 
	plan d1 where maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
	join d2
	 
	order by		
		name
		, format(sched_appt->list[d1.seq].appt_dt_tm, "yyyy/mm/dd;;d")
		, sched_appt->list[d1.seq].appt_dt_tm
		, sched_appt->list[d1.seq].dept_seq
		, sched_appt->list[d1.seq].loc_seq
		, sched_appt->list[d1.seq].room_seq
		, sched_appt->list[d1.seq].sch_appt_id
	 
	with nocounter, separator = " ", format, time = 60
endif
 
 
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/18/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_ApptFlow_Current.prg
	Object name:		cov_sm_ApptFlow_Current
	Request #:			3317, 6087, 11683
 
	Program purpose:	Accomodates foreign registration workflows surrounding
						scheduling and registration communication.
						Used by schedulers and insurance verifiers.
 
	Executing from:		CCL
 
 	Special Notes:		Does not include future appointments.
						Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	12/13/2018	Todd A. Blanchard		Added perioperative departments to prompts.
 										Revised logic for department prompt.
002	12/18/2018	Todd A. Blanchard		Revised queries for FINs.
003	12/19/2018	Todd A. Blanchard		Revised queries for Comments.
004	01/11/2019	Todd A. Blanchard		Added ssn alias_pool_cd to record structure
 										to support masking in layout builder.
005	10/25/2019	Todd A. Blanchard		Revised CCL for cpt codes and comments.
006	02/27/2020	Todd A. Blanchard		Revised logic for phone numbers due to 
										2018.01 upgrade.
007	04/28/2021	Todd A. Blanchard		Added checks for version_dt_tm. 
008	12/02/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
 
******************************************************************************/
 
drop program cov_sm_ApptFlow_Current:DBA go
create program cov_sm_ApptFlow_Current:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Department" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, department, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare home_phone_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare bus_phone_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "BUSINESS"))
declare pcp_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 331, "PRIMARYCAREPHYSICIAN"))
declare confirmed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare checkedin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CHECKEDIN"))
declare attach_type_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare attach_state_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 23012, "ACTIVE"))
declare order_status_future_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare order_status_ordered_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare order_status_completed_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "COMPLETED"))
declare cpt4_var					= f8 with constant(3362.00)
declare cpt_hcpcs_var				= f8 with constant(9000.00)
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
declare op_department_var			= c2 with noconstant("")
 
 
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
 
record sched_appt (
	1	p_facility			= vc
	1	p_dept				= vc
	1	p_startdate			= vc
	1	p_enddate			= vc
 
	1	person_cnt			= i4
	1	list[*]
		2	person_id		= f8
		2	patient_name	= vc
		2	home_phone		= vc
		2	ssn				= vc
		2	ssn_pool_cd		= f8
		2	dob				= dq8
		2	mrn				= vc
		2	fin				= vc
		2	pcp				= vc
		2	ins_cnt			= i4
		2	plan_names		= vc
 
		2	appt_book_id	= f8
 
		; scheduled appointments
		2	sched_cnt		= i4
		2	sched_appts[*]
			3	sch_appt_id				= f8
			3	room					= vc
			3	room_seq				= i4
			3	location				= vc
			3	loc_seq					= i4
			3	dept					= vc
			3	dept_seq				= i4
			3	dept_dt_tm				= dq8
			3	sch_event_id			= f8
			3	diagnosis				= vc
			3	insurance				= vc
			3	order_phy				= vc
			3	order_phy_phone			= vc
			3	primary_surgeon			= vc
			3	primary_surgeon_phone	= vc
			3	comment					= vc
 
			; scheduled procedures
			3 proc_cnt			= i4
			3 procedures[*]
				4	order_id				= f8
				4	order_mnemonic			= vc
				4	oe_field_dt_tm_value	= dq8
				4	cptcd					= vc
				4	cpt_hcpcs				= vc
)
 
record sched_patient (
	1	person_cnt			= i4
	1	list[*]
		2	person_id		= f8
)
 
/**************************************************************/
; set prompt data
set sched_appt->p_facility			= cnvtstring($facility)
set sched_appt->p_dept				= cnvtstring($department)
set sched_appt->p_startdate			= $start_datetime
set sched_appt->p_enddate			= $end_datetime
 
 
/**************************************************************/
; select scheduled appointment patient data
select into "NL:"
from
	SCH_APPT sa
 
 	; scheduled room for specified timeframe
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = $facility) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on sab2.appt_book_id = sbl.child_appt_book_id)	; department
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id) ; room or sub-department
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource (room or sub-department)
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
where
	; scheduled patient for specified timeframe
	sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
	and
		sar.resource_cd = evaluate2(
			if (sbl2.resource_cd = 0.0)
				sbl3.resource_cd
			else
				sbl2.resource_cd
			endif
			)
 	and (
		operator(sab2.appt_book_id, op_department_var, $department)	; department
		or operator(sab3.appt_book_id, op_department_var, $department) ; room or sub-department
 	)
 
order by
	sa.person_id
 
 
; populate sched_patient record structure
head report
	cnt = 0
 
	call alterlist(sched_patient->list, 100)
 
head sa.person_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_patient->list, cnt + 9)
	endif
 
	sched_patient->person_cnt					= cnt
	sched_patient->list[cnt].person_id			= sa.person_id
 
foot report
	call alterlist(sched_patient->list, cnt)
 
WITH nocounter, separator=" ", format
 
 
/**************************************************************/
; select scheduled appointment data
select distinct into "NL:"
from
	SCH_APPT sa
 
 	; scheduled room on/after specified start date
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = $facility) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on sab2.appt_book_id != 0.0
		and sab2.appt_book_id = sbl.child_appt_book_id) ; all departments
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id) ; room
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
	, (left join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, checkedin_var)
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "SURGDIAGNOSIS"
		and sed1.version_dt_tm > sysdate ;007
		and sed1.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_id in (
			select oef.oe_field_id
			from
				ORDER_ENTRY_FIELDS oef
				, OE_FIELD_MEANING ofm
			where
				cnvtupper(oef.description) = "COMMENT TEXT 1"
				and ofm.oe_field_meaning_id = oef.oe_field_meaning_id
				and ofm.oe_field_meaning in ("COMMENTTEXT1", "OTHER")
		)
		and sed2.version_dt_tm > sysdate ;007
		and sed2.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning = "SCHORDPHYS"
		and sed3.version_dt_tm > sysdate ;007
		and sed3.active_ind = 1)
 
 	;006
	, (left join PHONE sed3ph on sed3ph.parent_entity_id = sed3.oe_field_value
		and sed3ph.parent_entity_name = "PERSON"
		and sed3ph.phone_type_cd = bus_phone_var
		and isnumeric(sed3ph.phone_num_key) = 1
		and sed3ph.beg_effective_dt_tm <= sysdate
		and sed3ph.end_effective_dt_tm > sysdate
		and sed3ph.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed4 on sed4.sch_event_id = sev.sch_event_id
		and sed4.oe_field_meaning = "SURGEON1"
		and sed4.version_dt_tm > sysdate ;007
		and sed4.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed5 on sed5.sch_event_id = sev.sch_event_id
		and sed5.oe_field_meaning = "SPECINX"
		and sed5.version_dt_tm > sysdate ;007
		and sed5.active_ind = 1)
 
 	;006
	, (left join PHONE sed4ph on sed4ph.parent_entity_id = sed4.oe_field_value
		and sed4ph.parent_entity_name = "PERSON"
		and sed4ph.phone_type_cd = bus_phone_var
		and isnumeric(sed4ph.phone_num_key) = 1
		and sed4ph.beg_effective_dt_tm <= sysdate
		and sed4ph.end_effective_dt_tm > sysdate
		and sed4ph.active_ind = 1)
 
	, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.sch_state_cd = attach_state_var
		and sea.order_status_cd in (
			order_status_future_var
			, order_status_ordered_var
			, order_status_completed_var
		)
		and sea.active_ind = 1)
 
	, (left join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
	
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning_id in (cpt4_var, cpt_hcpcs_var))
	
	, (left join ORDER_ENTRY_FIELDS oef on oef.oe_field_meaning_id = od.oe_field_meaning_id
		and oef.oe_field_id = od.oe_field_id
		and oef.description = "CPT/HCPCS Code")
 
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
 	;006
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var
		and isnumeric(ph.phone_num_key) = 1
		and ph.beg_effective_dt_tm <= sysdate
		and ph.end_effective_dt_tm > sysdate
		and ph.active_ind = 1)
 
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var)
 
	, (left join PERSON_PRSNL_RELTN ppr on ppr.person_id = p.person_id
		and ppr.prsnl_person_id = (
			select prsnl_person_id = max(ppr2.prsnl_person_id)
			from PERSON_PRSNL_RELTN ppr2
			where ppr2.person_id = p.person_id
				and ppr2.person_prsnl_r_cd = pcp_var
				and ppr2.end_effective_dt_tm >= sysdate
				and ppr2.active_ind = 1
			group by ppr2.person_id
		)
		and ppr.person_prsnl_r_cd = pcp_var
		and ppr.end_effective_dt_tm >= sysdate
		and ppr.active_ind = 1)
 
	, (left join PRSNL pprper on pprper.person_id = ppr.prsnl_person_id
		and pprper.physician_ind = 1
		and pprper.end_effective_dt_tm >= sysdate
		and pprper.active_ind = 1)
 
where
	; scheduled patient on/after specified start date
	sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
	and
		sar.resource_cd = evaluate2(
			if (sbl2.resource_cd = 0.0)
				sbl3.resource_cd
			else
				sbl2.resource_cd
			endif)
 
	; patients in specified department
	and expand(num, 1, sched_patient->person_cnt, sa.person_id, sched_patient->list[num].person_id)
 
order by
	sa.person_id
	, sa.sch_appt_id
	, o.order_id
 
 
; populate sched_appt record structure
head report
	cnt = 0
 
	call alterlist(sched_appt->list, 100)
 
head sa.person_id
	acnt = 0
 
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_appt->list, cnt + 9)
	endif
 
	sched_appt->person_cnt					= cnt
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].home_phone		= ph.phone_num
	sched_appt->list[cnt].ssn				= pas.alias
	sched_appt->list[cnt].ssn_pool_cd		= pas.alias_pool_cd
	sched_appt->list[cnt].dob				= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
	sched_appt->list[cnt].mrn				= eam.alias
	sched_appt->list[cnt].fin				= eaf.alias
	sched_appt->list[cnt].pcp				= pprper.name_full_formatted
	sched_appt->list[cnt].appt_book_id		= sab.appt_book_id
 
head sa.sch_appt_id
	pcnt = 0
 
	acnt = acnt + 1
 
	call alterlist(sched_appt->list[cnt].sched_appts, acnt)
 
	sched_appt->list[cnt].sched_cnt									= acnt
	sched_appt->list[cnt].sched_appts[acnt].sch_appt_id				= sa.sch_appt_id
	sched_appt->list[cnt].sched_appts[acnt].room					= uar_get_code_display(sar.resource_cd)
	sched_appt->list[cnt].sched_appts[acnt].room_seq				= sbl3.seq_nbr
	sched_appt->list[cnt].sched_appts[acnt].location				= uar_get_code_display(sa.appt_location_cd)
	sched_appt->list[cnt].sched_appts[acnt].loc_seq					= sbl2.seq_nbr
	sched_appt->list[cnt].sched_appts[acnt].dept					= sab2.mnemonic
	sched_appt->list[cnt].sched_appts[acnt].dept_seq				= sbl.seq_nbr
	sched_appt->list[cnt].sched_appts[acnt].dept_dt_tm				= sar.beg_dt_tm
	sched_appt->list[cnt].sched_appts[acnt].sch_event_id			= sa.sch_event_id
	sched_appt->list[cnt].sched_appts[acnt].diagnosis				= sed1.oe_field_display_value
	sched_appt->list[cnt].sched_appts[acnt].insurance				= sed2.oe_field_display_value
	sched_appt->list[cnt].sched_appts[acnt].order_phy				= sed3.oe_field_display_value
	sched_appt->list[cnt].sched_appts[acnt].order_phy_phone			= sed3ph.phone_num
	sched_appt->list[cnt].sched_appts[acnt].primary_surgeon			= sed4.oe_field_display_value
	sched_appt->list[cnt].sched_appts[acnt].primary_surgeon_phone	= sed4ph.phone_num
	sched_appt->list[cnt].sched_appts[acnt].comment					= sed5.oe_field_display_value
 
head o.order_id
	pcnt = pcnt + 1
 
	call alterlist(sched_appt->list[cnt].sched_appts[acnt].procedures, pcnt)
 
	sched_appt->list[cnt].sched_appts[acnt].proc_cnt = 								pcnt
	sched_appt->list[cnt].sched_appts[acnt].procedures[pcnt].order_id = 			o.order_id
	sched_appt->list[cnt].sched_appts[acnt].procedures[pcnt].order_mnemonic = 		nullval(o.order_mnemonic, novalue)
	sched_appt->list[cnt].sched_appts[acnt].procedures[pcnt].oe_field_dt_tm_value =	o.current_start_dt_tm
		
head od.oe_field_display_value
	if (od.oe_field_meaning_id = cpt4_var)
		sched_appt->list[cnt].sched_appts[acnt].procedures[pcnt].cptcd = trim(od.oe_field_display_value, 3)
		
	elseif ((od.oe_field_meaning_id = cpt_hcpcs_var) and (oef.description = "CPT/HCPCS Code"))
		sched_appt->list[cnt].sched_appts[acnt].procedures[pcnt].cpt_hcpcs = trim(od.oe_field_display_value, 3)
		
	endif
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; select insurance data
select into "NL:"
from
	PERSON_PLAN_RELTN ppr
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = ppr.health_plan_id
		and hp.end_effective_dt_tm >= sysdate
		and hp.active_ind = 1)
 
where
	expand(num, 1, sched_appt->person_cnt, ppr.person_id, sched_appt->list[num].person_id)
	and ppr.end_effective_dt_tm >= sysdate
	and ppr.active_ind = 1
 
order by
	ppr.person_id
	, ppr.end_effective_dt_tm desc
 
 
; populate sched_appt record structure with insurance data
head ppr.person_id
	numx = 0
	idx = 0
	cntx = 0
	ins_values = fillstring(100, " ")
 
	idx = locateval(numx, 1, sched_appt->person_cnt, ppr.person_id, sched_appt->list[numx].person_id)
 
detail
	if (idx > 0)
		cntx = cntx + 1
 
		if (cntx > 0 and cntx <= 4) ; limit list to 4 items
	 		sched_appt->list[idx].ins_cnt = cntx
 
			ins_values = build(trim(ins_values, 3), trim(hp.plan_name, 3), ",")
		endif
	endif
 
foot ppr.person_id
	sched_appt->list[idx].plan_names = replace(trim(ins_values, 3), ",", "", 2)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
call echorecord(sched_patient)
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/30/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_PreRegNotes.prg
	Object name:		cov_sm_PreRegNotes
	Request #:			11, 6085, 7312, 11683, 13598
 
	Program purpose:	Accomodates foreign registration workflows surrounding
						scheduling and registration communication.
						Used by schedulers and insurance verifiers.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/22/2018	Todd A. Blanchard		Revised query for bookshelf resources.
 										Revised CCL for empty procedures list.
002	05/28/2018	Todd A. Blanchard		Revised queries for order entry fields
 										and health plans.
003	05/30/2018	Todd A. Blanchard		Revised queries for health plans.
004	06/05/2018	Todd A. Blanchard		Revised query for procedures.
005	07/23/2018	Todd A. Blanchard		Revised prompt for facilities.
006	07/31/2018	Todd A. Blanchard		Revised criteria for orders query.
007	08/02/2018	Todd A. Blanchard		Revised queries for scheduled events and procedures.
008	08/13/2018	Todd A. Blanchard		Revised CCL for diagnosis code.
009	09/17/2018	Todd A. Blanchard		Revised queries to exclude Joint Class resources.
010	11/01/2018	Todd A. Blanchard		Revised DOB to account for timezone.
011	10/24/2019	Todd A. Blanchard		Revised CCL for cpt codes and comments.
012	03/16/2020	Todd A. Blanchard		Revised CCL for surgeon.
013	12/02/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
014	09/06/2022	Todd A. Blanchard		Revised query to exclude FLMC Radiologist resource.
 
******************************************************************************/
 
drop program cov_sm_PreRegNotes:DBA go
create program cov_sm_PreRegNotes:DBA
 
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
 
declare get_LocationCode(data = f8) = f8
declare get_OrganizationId(data = f8) = f8
 
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
declare canceled_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "CANCELED"))
declare orderphys_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ORDERINGPHYSICIAN"))
declare attach_type_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare attach_state_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 23012, "ACTIVE")) ;006
declare order_status_future_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE")) ;007
declare order_status_ordered_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED")) ;007
declare cpt4_var					= f8 with constant(3362.00) ;011
declare cpt_hcpcs_var				= f8 with constant(9000.00) ;011
declare location_var				= f8 with noconstant(0.0)
declare organization_var			= f8 with noconstant(0.0)
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
declare op_department_var			= c2 with noconstant("")
 
 
; get location
set location_var = get_LocationCode($facility)
 
; get organization
set organization_var = get_OrganizationId(location_var)
 
 
; define operator for $department ;005
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
	1	sched_cnt			= i4
	1	list[*]
		2	sch_appt_id		= f8
		2	dos				= dq8
		2	room			= vc
		2	room_seq		= i4
		2	location		= vc
		2	loc_seq			= i4
		2	dept			= vc
		2	dept_seq		= i4
		2	date_time		= dq8
		2	sch_event_id	= f8
		2	encntr_id		= f8 ;007
		2	reason_exam		= vc ;007
		2	comment			= vc ;011
 
		; scheduled procedures
		2 proc_cnt			= i4
		2 procedures[*]
			3	order_id				= f8
			3	order_mnemonic			= vc
			3	oe_field_dt_tm_value	= dq8
			3	cptcd					= vc ;011
			3	cpt_hcpcs				= vc ;011
 
		2	diagnosis		= vc
		2	diag_code		= vc ;008
		2	insurance		= vc
 
		; insurances
		2	ins_cnt			= i4
		2	plan_names		= vc ;002
 
		2	person_id		= f8
		2	patient_name	= vc
		2	ssn				= vc
		2	dob				= dq8
		2	mrn				= vc
		2	appt_book_id	= f8
		2	pcp				= vc
		2	order_phy		= vc
		2	surgeon			= vc
)
 
/**************************************************************/
; select scheduled appointment data
select into "NL:"
from
	SCH_APPT sa
 
 	; scheduled room
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	; bookshelf items ;001
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = $facility) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on operator(sab2.appt_book_id, op_department_var, $department) ; department ;005
		and sab2.appt_book_id = sbl.child_appt_book_id
		and sab2.appt_book_id not in ( ;009
			1639442.00		; MMC Joint Center
			, 1644773.00	; PWMC Joint Center
		))
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id ; room
		and sab3.appt_book_id not in ( ;009
			1639442.00		; MMC Joint Center
			, 1644773.00	; PWMC Joint Center
			, 1669309.00	; FLMC Radiologist ;014
		))
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
	, (left join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var, checkedin_var)
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning in ("SURGDIAGNOSIS", "*ICD*") ;008
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
				and ofm.oe_field_meaning in ("COMMENTTEXT1", "OTHER") ;002
		)
		and sed2.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning = "SCHORDPHYS"
		and sed3.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed4 on sed4.sch_event_id = sev.sch_event_id ;007
		and sed4.oe_field_meaning = "REASONFOREXAM"
		and sed4.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed5 on sed5.sch_event_id = sev.sch_event_id ;011
		and sed5.oe_field_meaning = "SPECINX"
		and sed5.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed6 on sed6.sch_event_id = sev.sch_event_id ;012
		and sed6.oe_field_meaning = "SURGEON1"
		and sed6.active_ind = 1)
 
	, (left join NOMENCLATURE n on n.source_string = sed1.oe_field_display_value ;007
		and n.end_effective_dt_tm > sysdate
		and n.active_ind = 1)
 
	, (left join PHONE sed3ph on sed3ph.parent_entity_id = sed3.oe_field_value
		and sed3ph.parent_entity_name = "PERSON"
		and sed3ph.phone_type_cd = bus_phone_var
		and sed3ph.active_ind = 1)
 
	, (left join PHONE sed6ph on sed6ph.parent_entity_id = sed6.oe_field_value ;012
		and sed6ph.parent_entity_name = "PERSON"
		and sed6ph.phone_type_cd = bus_phone_var
		and sed6ph.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var
		and ph.active_ind = 1)
 
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = mrn_var)
 
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
 
;	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
;
;	, (inner join ORGANIZATION org on org.organization_id = l.organization_id
;		and org.organization_id = organization_var)
 
where
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
 
order by
	format(sa.beg_dt_tm, "mm/dd/yyyy;;d")
	, sbl.seq_nbr
	, sbl2.seq_nbr
	, sbl3.seq_nbr
	, sa.beg_dt_tm
	, sa.end_dt_tm
	, p.name_full_formatted
 
 
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
	sched_appt->list[cnt].dos				= sa.beg_dt_tm
	sched_appt->list[cnt].room				= uar_get_code_display(sar.resource_cd)
	sched_appt->list[cnt].room_seq			= sbl3.seq_nbr
	sched_appt->list[cnt].location			= uar_get_code_display(sa.appt_location_cd)
	sched_appt->list[cnt].loc_seq			= sbl2.seq_nbr
	sched_appt->list[cnt].dept				= sab2.mnemonic
	sched_appt->list[cnt].dept_seq			= sbl.seq_nbr
	sched_appt->list[cnt].date_time			= sa.beg_dt_tm
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].encntr_id			= e.encntr_id ;007
	sched_appt->list[cnt].diagnosis			= trim(sed1.oe_field_display_value, 3) ;008
	sched_appt->list[cnt].diag_code			= trim(n.source_identifier, 3) ;008
	sched_appt->list[cnt].insurance			= trim(sed2.oe_field_display_value, 3) ;007
	sched_appt->list[cnt].reason_exam		= trim(sed4.oe_field_display_value, 3) ;007
	sched_appt->list[cnt].comment			= trim(sed5.oe_field_display_value, 3) ;011
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].ssn				= pas.alias
	sched_appt->list[cnt].dob				= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;010
	sched_appt->list[cnt].mrn				= ea.alias
	sched_appt->list[cnt].appt_book_id		= sab.appt_book_id
	sched_appt->list[cnt].pcp				= pprper.name_full_formatted
	sched_appt->list[cnt].order_phy			= trim(sed3.oe_field_display_value, 3)
	sched_appt->list[cnt].surgeon			= trim(sed6.oe_field_display_value, 3) ;012
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, separator=" ", format
 
 
/**************************************************************/
; select scheduled procedures data ;004
select distinct into "NL:"
from
	SCH_EVENT_ATTACH sea
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
	
	;011
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning_id in (cpt4_var, cpt_hcpcs_var))
	
	;011
	, (left join ORDER_ENTRY_FIELDS oef on oef.oe_field_meaning_id = od.oe_field_meaning_id
		and oef.oe_field_id = od.oe_field_id
		and oef.description = "CPT/HCPCS Code")
 
where
	expand(num, 1, size(sched_appt->list, 5), sea.sch_event_id, sched_appt->list[num].sch_event_id)
	and sea.attach_type_cd = attach_type_var
	and sea.sch_state_cd = attach_state_var ;006
	and sea.order_status_cd in ( ;007
		order_status_future_var
		, order_status_ordered_var
	)
	and sea.active_ind = 1
 
order by
	sea.sch_event_id
	, o.current_start_dt_tm
	, o.order_id ;011
 
 
; populate sched_appt record structure with procedure data
head sea.sch_event_id
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sea.sch_event_id, sched_appt->list[numx].sch_event_id)
 
	if (idx > 0)
		call alterlist(sched_appt->list[idx].procedures, 10)
	endif

head o.current_start_dt_tm ;011
	null

head o.order_id ;011
	if (idx > 0)
		if (cnvtdate(o.current_start_dt_tm) = cnvtdate(sched_appt->list[idx].dos))
			cntx = cntx + 1
 
			if (mod(cntx, 10) = 1 and cntx > 10)
				call alterlist(sched_appt->list[idx].procedures, cntx + 9)
			endif
 
	 		sched_appt->list[idx].proc_cnt = cntx
			sched_appt->list[idx].procedures[cntx].order_id = o.order_id
			sched_appt->list[idx].procedures[cntx].order_mnemonic = nullval(o.order_mnemonic, novalue)
			sched_appt->list[idx].procedures[cntx].oe_field_dt_tm_value = o.current_start_dt_tm
			
			;011
			if (od.oe_field_meaning_id = cpt4_var)
				sched_appt->list[idx].procedures[cntx].cptcd = trim(od.oe_field_display_value, 3)
				
			elseif ((od.oe_field_meaning_id = cpt_hcpcs_var) and (oef.description = "CPT/HCPCS Code"))
				sched_appt->list[idx].procedures[cntx].cpt_hcpcs = trim(od.oe_field_display_value, 3)
				
			endif
		endif
	endif
 
foot sea.sch_event_id
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; validate procedures ;001
select into "NL:"
from
	DUMMYT
 
head report
	numx = sched_appt->sched_cnt
	cntx = 0
	i = 0
 
	for (i = 1 to numx)
		cntx = sched_appt->list[i].proc_cnt
 
		if (cntx = 0)
			call alterlist(sched_appt->list[i].procedures, 1)
 
			sched_appt->list[i].proc_cnt = 1
			sched_appt->list[i].procedures[1].order_id = 0.0
			sched_appt->list[i].procedures[1].order_mnemonic = novalue
			sched_appt->list[i].procedures[1].oe_field_dt_tm_value = 0
			sched_appt->list[i].procedures[1].cptcd = "" ;011
			sched_appt->list[i].procedures[1].cpt_hcpcs = "" ;011
		endif
	endfor
 
WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; select insurance data ;003
select into "NL:"
from
	SCH_APPT sa
 
	, (inner join PERSON_PLAN_RELTN ppr on ppr.person_id = sa.person_id
		and ppr.end_effective_dt_tm >= sysdate
		and ppr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = ppr.health_plan_id
		and hp.end_effective_dt_tm >= sysdate
		and hp.active_ind = 1
	)
 
where
	expand(num, 1, size(sched_appt->list, 5), sa.sch_appt_id, sched_appt->list[num].sch_appt_id)
 
order by
	sa.sch_appt_id
	, ppr.end_effective_dt_tm desc
 
 
; populate sched_appt record structure with insurance data
head sa.sch_appt_id
	numx = 0
	idx = 0
	cntx = 0
	ins_values = fillstring(100, " ")
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sa.sch_appt_id, sched_appt->list[numx].sch_appt_id)
 
detail
	if (idx > 0)
		cntx = cntx + 1
 
		if (cntx > 0 and cntx <= 4) ; limit list to 4 items
	 		sched_appt->list[idx].ins_cnt = cntx
 
			ins_values = build2(trim(ins_values, 3), trim(hp.plan_name, 3), ", ")
		endif
	endif
 
foot sa.sch_appt_id
	sched_appt->list[idx].plan_names = replace(trim(ins_values, 3), ",", "", 2)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 

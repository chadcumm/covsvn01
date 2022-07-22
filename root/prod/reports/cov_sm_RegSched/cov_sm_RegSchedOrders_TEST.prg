/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/27/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_RegSchedOrders.prg
	Object name:		cov_sm_RegSchedOrders
	Request #:			5185, 11683
 
	Program purpose:	Lists scheduled appointments where orders have been cancelled.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	12/02/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
 
******************************************************************************/
 
drop program cov_sm_RegSchedOrders_TEST:DBA go
create program cov_sm_RegSchedOrders_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare get_ApptBookId(data = f8) = f8
declare get_OrganizationId(data = f8) = f8
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare home_phone_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare confirmed_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare attach_type_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare canceled_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "CANCELED"))
declare inpatient_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT"))
declare ancilsurg_var		= f8 with constant(uar_get_code_by("MEANING", 222, "ANCILSURG"))
declare cancel_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "CANCEL"))

declare num					= i4 with noconstant(0)
declare novalue				= vc with constant("Not Available")
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

free record sched_appt
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
		2	room			= vc
		2	room_seq		= i4
		2	location		= vc
		2	loc_seq			= i4
		2	location_type	= vc
		2	dept			= vc
		2	dept_seq		= i4
 
		2	sch_event_id	= f8
		2	appt_type		= vc
		2	reason_exam		= vc
		2	instructions	= vc
 
		2 proc_cnt			= i4
		2 procedures[*]
			3	order_id					= f8
			3	order_synonym_id			= f8
			3	order_mnemonic				= vc
			3	oe_field_dt_tm_value		= dq8
			3	order_status				= vc			
			3	order_action_dt_tm			= dq8
			3	order_action_personnel_id	= f8
			3	order_action_prsnl_name		= vc
 
		2	person_id		= f8
		2	patient_name	= vc
		2	ssn				= vc
		2	dob				= dq8
		2	mrn				= vc
		2	home_phone		= vc
 
 		2	encntr_id		= f8
 		2	encntr_type		= vc
		2	fin				= vc
 
		2	appt_book_id	= f8
) with persistscript
 
 
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
		and sar.state_meaning in ("CONFIRMED")
		and sar.active_ind = 1)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd
		and l.location_type_cd not in (ancilsurg_var))
	
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id
		and org.organization_id = sched_appt->p_organization)
 
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
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (confirmed_var)
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_meaning = "SPECINX"
		and sed2.active_ind = 1)
	
	; scheduled orders
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.order_status_cd = canceled_var)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = cancel_var) ; CANCEL
	
	, (inner join PRSNL per_oa on per_oa.person_id = oa.action_personnel_id
		and per_oa.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id
		and p.active_ind = 1)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var
		and ph.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.encntr_type_cd not in (inpatient_var)
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
	sa.sch_appt_id
	, sea.sch_attach_id
 
 
; populate sched_appt record structure
head report
	cnt = 0
	 
head sa.sch_appt_id
	pcnt = 0
	
	cnt = cnt + 1
 
	call alterlist(sched_appt->list, cnt)
 
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
	sched_appt->list[cnt].ssn				= pas.alias
	sched_appt->list[cnt].dob				= p.birth_dt_tm
	sched_appt->list[cnt].mrn				= eam.alias
	sched_appt->list[cnt].home_phone		= trim(ph.phone_num, 3)
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	sched_appt->list[cnt].fin				= eaf.alias
 
	sched_appt->list[cnt].appt_book_id		= sab.appt_book_id
	
head sea.sch_attach_id	
	pcnt = pcnt + 1
 
	call alterlist(sched_appt->list[cnt].procedures, pcnt)
	
	sched_appt->list[cnt].proc_cnt										= pcnt
	sched_appt->list[cnt].procedures[pcnt].order_id						= o.order_id
	sched_appt->list[cnt].procedures[pcnt].order_synonym_id				= o.synonym_id
	sched_appt->list[cnt].procedures[pcnt].order_mnemonic				= o.order_mnemonic
	sched_appt->list[cnt].procedures[pcnt].oe_field_dt_tm_value			= o.current_start_dt_tm
	sched_appt->list[cnt].procedures[pcnt].order_status					= uar_get_code_display(o.order_status_cd)			
	sched_appt->list[cnt].procedures[pcnt].order_action_dt_tm			= oa.action_dt_tm
	sched_appt->list[cnt].procedures[pcnt].order_action_personnel_id	= oa.action_personnel_id
	sched_appt->list[cnt].procedures[pcnt].order_action_prsnl_name		= per_oa.name_full_formatted
	 
WITH nocounter, separator = " ", format 

 
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 

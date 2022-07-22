/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Apr'2020
	Solution:			Schedule
	Source file name:	      cov_sn_sched_dept_count.prg
	Object name:		cov_sn_sched_dept_count
	Request#:			7550
	Program purpose:		Dashboard - Surgery anesthesia and Covid-19 summary
	Executing from:		DA2
 	Special Notes:		supporting ccl for cov_sn_surgery_covid_dashboard
 					Modified from cov_schedule_department
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_sn_sched_dept_count:DBA go
create program cov_sn_sched_dept_count:DBA
 
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
;declare get_ApptBookId(data = f8) = f8
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare home_phone_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare confirmed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare admitphys_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN"))
declare attach_type_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare attach_state_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 23012, "ACTIVE"))
declare order_status_future_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare order_status_ordered_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare location_var				= f8 with noconstant(0.0)
declare organization_var			= c200 with noconstant("")
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
declare op_department_var			= c2 with noconstant("")

/* added for me 
; get Book id
;set book_id_var = get_ApptBookId($facility)
;set location_var = get_LocationCode(book_id_var)
*/

; get location
set location_var = get_LocationCode($facility)
 
call echo(build2('location = ',location_var))
 
; get organization
if ($facility = 1651454.00)
	set organization_var = build2("org.organization_id in (",
		"3234083.00,",	; Thompson Oncology Group - Blount
		"3234084.00,",	; Thompson Oncology Group - Downtown
		"3234085.00,",	; Thompson Oncology Group - Lenoir City
		"3234086.00,",	; Thompson Oncology Group - Morristown
		"3242296.00,",	; Thompson Oncology Group - Oak Ridge
		"3234088.00,",	; Thompson Oncology Group - Sevier
		"3234089.00",	; Thompson Oncology Group - West
		")")
else
	set organization_var = build2("org.organization_id = ", get_OrganizationId(location_var))
endif
 
call echo(organization_var)
 
 
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
free set sched_appt
record sched_appt (
	1	sched_cnt					= i4
	1	list[*]
		2	sch_appt_id				= f8
		2	appt_dt_tm				= dq8
		2	appt_type				= vc
		2	room					= vc
		2	room_seq				= i4
		2	location				= vc
		2	loc_seq					= i4
		2	dept					= vc
		2	dept_seq				= i4
		2	loc_facility			= vc
		2	org_name				= vc
 		2     org_id                        = f8
		2	reason_exam				= vc
		2	instructions			= vc
		2	order_phy				= vc ;004
		2	admit_phys_id			= f8
		2	admit_phys				= vc
 
		2	sch_event_id			= f8
		2	encntr_id				= f8
		2	encntr_type				= vc
		2	encntr_status			= vc
		2	loc_nurse_unit			= vc
 
		2 proc_cnt						= i4
		2 procedures[*]
			3	order_id				= f8
			3	order_mnemonic			= c100
			3	order_dt_tm				= dq8
			3	order_comment			= c300
			3	prior_auth				= c30
 
		2	person_id				= f8
		2	patient_name			= vc
		2	ssn						= vc
		2	dob						= dq8
		2	home_phone				= vc
		2	mrn						= vc
		2	fin						= vc
		2	primary_health_plan		= vc
 
		2	appt_book_id			= f8
)with persistscript
 
 
/**************************************************************/
; select scheduled appointment data
select into "NL:"
from
	SCH_APPT sa
 
 	; scheduled room
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd = confirmed_var
		and sar.active_ind = 1)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = $facility) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on operator(sab2.appt_book_id, op_department_var, $department) ; department
		and sab2.appt_book_id = sbl.child_appt_book_id
		; filter out display-type books and joint centers
		and sab2.appt_book_id not in (
			1639442.00		; MMC Joint Center
			, 1644773.00	; PWMC Joint Center
			, 1674964.00	; MHHS/ MRDC Rad
			, 1675706.00	; MRDC Rad Display
			, 1675708.00	; MHHS Rad Display
 
		))
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id ; room
		; filter out display-type books and joint centers
		and sab3.appt_book_id not in (
			1639442.00		; MMC Joint Center
			, 1644773.00	; PWMC Joint Center
			, 1674964.00	; MHHS/ MRDC Rad
			, 1675706.00	; MRDC Rad Display
			, 1675708.00	; MHHS Rad Display
		))
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource (room)
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
 	; scheduled event
	, (left join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd = confirmed_var
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and (sed1.version_dt_tm > sysdate or sed1.version_dt_tm is null)
		and sed1.end_effective_dt_tm > sysdate
		and sed1.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_meaning = "SPECINX"
		and (sed2.version_dt_tm > sysdate or sed2.version_dt_tm is null)
		and sed2.end_effective_dt_tm > sysdate
		and sed2.active_ind = 1)
 
 	;004
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning = "SCHORDPHYS"
		and (sed3.version_dt_tm > sysdate or sed3.version_dt_tm is null)
		and sed3.end_effective_dt_tm > sysdate
		and sed3.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var ; ssn
		and pas.active_ind = 1)
 
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
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var) ; mrn
 
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.beg_effective_dt_tm <= sysdate
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1)
 
	, (left join ENCNTR_PRSNL_RELTN eperr on eperr.encntr_id = e.encntr_id
		and eperr.encntr_prsnl_r_cd = admitphys_var ; admitting physician
		and eperr.end_effective_dt_tm > sysdate
		and eperr.active_ind = 1)
 
	, (left join PRSNL per on per.person_id = eperr.prsnl_person_id)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id
		and parser(organization_var)) ; facility
 
where
	sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd = confirmed_var
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
 	loc_sched_cnt = cnt
	sched_appt->sched_cnt						= cnt
	sched_appt->list[cnt].sch_appt_id			= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm			= sa.beg_dt_tm
	sched_appt->list[cnt].appt_type				= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].room					= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].room_seq				= sbl3.seq_nbr
	sched_appt->list[cnt].location				= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].loc_seq				= sbl2.seq_nbr
	sched_appt->list[cnt].dept					= trim(sab2.mnemonic, 3)
	sched_appt->list[cnt].dept_seq				= sbl.seq_nbr
	sched_appt->list[cnt].loc_facility			= trim(uar_get_code_display(l.location_cd), 3)
	sched_appt->list[cnt].org_name				= trim(org.org_name, 3)
	sched_appt->list[cnt].org_id                     = org.organization_id
 
	sched_appt->list[cnt].reason_exam			= trim(sed1.oe_field_display_value, 3)
	sched_appt->list[cnt].instructions			= trim(sed2.oe_field_display_value, 3)
	sched_appt->list[cnt].order_phy				= trim(sed3.oe_field_display_value, 3) ;004
	sched_appt->list[cnt].admit_phys_id			= per.person_id
	sched_appt->list[cnt].admit_phys			= trim(per.name_full_formatted, 3)
 
	sched_appt->list[cnt].sch_event_id			= sa.sch_event_id
	sched_appt->list[cnt].encntr_id				= e.encntr_id
	sched_appt->list[cnt].encntr_type			= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[cnt].encntr_status			= trim(uar_get_code_display(e.encntr_status_cd), 3)
	sched_appt->list[cnt].loc_nurse_unit		= trim(uar_get_code_display(e.loc_nurse_unit_cd), 3)
 
	sched_appt->list[cnt].person_id				= p.person_id
	sched_appt->list[cnt].patient_name			= trim(p.name_full_formatted, 3)
	sched_appt->list[cnt].ssn					= trim(pas.alias, 3)
	sched_appt->list[cnt].dob					= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
	sched_appt->list[cnt].home_phone			= trim(ph.phone_num, 3)
	sched_appt->list[cnt].mrn					= trim(eam.alias, 3)
	sched_appt->list[cnt].fin					= trim(eaf.alias, 3)
	sched_appt->list[cnt].primary_health_plan	= trim(hp.plan_name, 3)
 
	sched_appt->list[cnt].appt_book_id			= sab.appt_book_id
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, separator=" ", format
 
 
/**************************************************************/
; select scheduled procedures data
select into "NL:"
from
	SCH_EVENT_ATTACH sea
 
	, (inner join SCH_APPT sa on sa.sch_event_id = sea.sch_event_id
		and sa.schedule_id > 0.0
		and sa.role_meaning = "PATIENT"
		and sa.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "SCHEDAUTHNBR")
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
	, (inner join PRSNL per on per.person_id = oa.action_personnel_id)
 
	, (left join ORDER_COMMENT oc on o.order_id = oc.order_id)
 
	, (left join LONG_TEXT lt on lt.long_text_id = oc.long_text_id
		and lt.parent_entity_id = oc.order_id
		and lt.parent_entity_name = "ORDER_COMMENT")
 
where
	expand(num, 1, size(sched_appt->list, 5), sea.sch_event_id, sched_appt->list[num].sch_event_id
		, sa.sch_appt_id, sched_appt->list[num].sch_appt_id)
	and sea.attach_type_cd = attach_type_var
	and sea.active_ind = 1
 
order by
	sea.sch_event_id
	, sa.sch_appt_id
	, o.order_id
 
 
; populate sched_appt record structure with procedure data
head sea.sch_event_id
	null
 
head sa.sch_appt_id
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sea.sch_event_id, sched_appt->list[numx].sch_event_id
		, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id)
 
	if (idx > 0)
		call alterlist(sched_appt->list[idx].procedures, 10)
	endif
 
detail
	if (cnvtdate(o.current_start_dt_tm) = cnvtdate(sched_appt->list[idx].appt_dt_tm))
		cntx = cntx + 1
 
		if (mod(cntx, 10) = 1 and cntx > 10)
			call alterlist(sched_appt->list[idx].procedures, cntx + 9)
		endif
 
 		sched_appt->list[idx].proc_cnt = cntx
		sched_appt->list[idx].procedures[cntx].order_id = o.order_id
		sched_appt->list[idx].procedures[cntx].order_mnemonic = trim(o.order_mnemonic, 3)
		sched_appt->list[idx].procedures[cntx].order_dt_tm = o.current_start_dt_tm
		sched_appt->list[idx].procedures[cntx].prior_auth = trim(od.oe_field_display_value, 3)
 
		sched_appt->list[idx].procedures[cntx].order_comment = lt.long_text
 
		sched_appt->list[idx].procedures[cntx].order_comment = replace(
			sched_appt->list[idx].procedures[cntx].order_comment, char(13), " ", 4)
 
		sched_appt->list[idx].procedures[cntx].order_comment = replace(
			sched_appt->list[idx].procedures[cntx].order_comment, char(10), " ", 4)
 
		sched_appt->list[idx].procedures[cntx].order_comment = replace(
			sched_appt->list[idx].procedures[cntx].order_comment, char(0), " ", 4)
 
		sched_appt->list[idx].procedures[cntx].order_comment = trim(sched_appt->list[idx].procedures[cntx].order_comment, 3)
	endif
 
foot sa.sch_appt_id
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, expand = 1, time = 60
 
 
;call echorecord(sched_appt)
;------------------------------------------------------------------------------------------
;Added 5/5/20 for me

SELECT INTO $outdev
 
	person_id = sched_appt->list[d1.seq].person_id
	, patient_name = substring(1, 30, sched_appt->list[d1.seq].patient_name)
	, sched_appt_sched_cnt = sched_appt->sched_cnt
	, appt_dt_tm = format(sched_appt->list[d1.seq].appt_dt_tm, 'mm/dd/yyyy hh:mm:ss;;q')
	, appt_type = substring(1, 300, sched_appt->list[d1.seq].appt_type)
	, location = substring(1, 30, sched_appt->list[d1.seq].location)
	, loc_facility = substring(1, 30, sched_appt->list[d1.seq].loc_facility)
	, reason_exam = substring(1, 300, sched_appt->list[d1.seq].reason_exam)
	, instructions = substring(1, 500, sched_appt->list[d1.seq].instructions)
	;, procedure_order_mnemonic = sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic
	, org_name = substring(1, 30, sched_appt->list[d1.seq].org_name)
 	, org_id =  sched_appt->list[d1.seq].org_id
 
FROM
	(dummyt   d1  with seq = size(sched_appt->list, 5))
 
;, (DUMMYT   D2  WITH SEQ = 1)
plan d1
 
; WHERE MAXREC(D2, SIZE(SCHED_APPT->list[D1.SEQ].procedures, 5))
;JOIN D2
 
WITH nocounter, separator=" ", format

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 

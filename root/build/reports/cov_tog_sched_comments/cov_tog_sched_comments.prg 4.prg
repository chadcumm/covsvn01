/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/17/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingAudit.prg
	Object name:		cov_sm_SchedulingAudit
	Request #:			2191, 3502
 
	Program purpose:	Lists scheduled appointments for selected facility.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	08/21/2018	Todd A. Blanchard		Changed facility prompt to listbox.
 										Restructured CCL to handle prompt change.
 	08/22/2018	Todd A. Blanchard		Added DOB to CCL.
 										Adjusted height of facility listbox prompt.
 	09/10/2018	Todd A. Blanchard		Corrected prompt for FSR.
 	10/09/2018	Todd A. Blanchard		Added admitting and attending physicians.
 										Changed criteria to include all event states.
 										Added event sequence data.
 										Restructured CCL for efficiency.
 	10/10/2018	Todd A. Blanchard		Formatted dates.
 										Restructured CCL to be encounter-centric.
 
******************************************************************************/
 
drop program cov_tog_sched_comments:DBA go
create program cov_tog_sched_comments:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, FACILITY, START_DATETIME, END_DATETIME
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var								= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var								= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var								= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare home_phone_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare confirmed_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare surgery_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERY"))
declare surgerypatonly_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLY"))
declare surgerypatonlyflm_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYFLM"))
declare surgerypatonlyfsr_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYFSR"))
declare surgerypatonlylcm_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYLCM"))
declare surgerypatonlymha_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYMHA"))
declare surgerypatonlymhh_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYMHH"))
declare surgerypatonlymmc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYMMC"))
declare surgerypatonlypwm_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYPWM"))
declare surgerypatonlyrmc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYPATONLYRMC"))
declare surgerywpat_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "SURGERYWPAT"))
declare attach_type_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare admitting_physician_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN"))
declare attending_physician_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN"))
declare num									= i4 with noconstant(0)
declare novalue								= vc with constant("Not Available")
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
 
record sched_appt (
	1	p_start_datetime	= vc
	1	p_end_datetime		= vc
 
	1	sched_cnt			= i4
	1	list[*]
		2	sch_appt_id		= f8
		2	appt_dt_tm		= dq8
		2	room			= c100
		2	location		= c100
		2	location_type	= c100
		2	org_name		= c100
 
		2	schedule_id		= f8
		2	sch_event_id	= f8
		2	appt_type		= c100
		2	appt_state		= c30
		2	action_dt_tm	= dq8
		2	action			= c30
		2	reason_exam		= c100
		2	order_phy		= c100
		2	admit_phy		= c100
		2	attend_phy		= c100
 
		2 proc_cnt			= i4
		2 procedures[*]
			3	order_id				= f8
			3	order_mnemonic			= c100
			3	oe_field_dt_tm_value	= dq8
			3	prior_auth				= c30
 
		2	person_id		= f8
		2	patient_name	= c100
		2	dob				= dq8
 
 		2	encntr_id		= f8
 		2	encntr_type		= c100
 		2	encntr_status	= c30
		2	fin				= c10
		2   mrn				= c10
		2	health_plan		= c100
		2   person_comment  = c500
		
)
 
 
/**************************************************************/
; populate record structure with prompt data
set sched_appt->p_start_datetime = format(cnvtdate2($start_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
set sched_appt->p_end_datetime = format(cnvtdate2($end_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
 
/**************************************************************/
; select scheduled appointment data
select into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled room
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd in (
			select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
		)
		and sar.active_ind = 1)
 
 	; scheduled event
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (
			select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
		)
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning = "SCHORDPHYS"
		and sed3.active_ind = 1)
 
	, (left join SCH_EVENT_ACTION seact on seact.sch_event_id = sev.sch_event_id
		and seact.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
 	; encounter
	, (inner join ENCOUNTER e on operator(e.organization_id, op_facility_var, $facility) ; facility
		and e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
	, (left join ENCNTR_ALIAS eaf2 on eaf2.encntr_id = e.encntr_id
		and eaf2.encntr_alias_type_cd = mrn_var
		and eaf2.active_ind = 1)
 
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.end_effective_dt_tm > sysdate
		and hp.active_ind = 1)
 
	, (left join ENCNTR_PRSNL_RELTN eper1 on eper1.encntr_id = e.encntr_id
		and eper1.encntr_prsnl_r_cd = admitting_physician_var
		and eper1.active_ind = 1)
 
	, (left join PRSNL per1 on per1.person_id = eper1.prsnl_person_id)
 
	, (left join ENCNTR_PRSNL_RELTN eper2 on eper2.encntr_id = e.encntr_id
		and eper2.encntr_prsnl_r_cd = attending_physician_var
		and eper2.active_ind = 1)
 
	, (left join PRSNL per2 on per2.person_id = eper2.prsnl_person_id)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
 
where
	sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd in (
		select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
	)
	and sa.active_ind = 1
 
order by
	sa.sch_appt_id
 
 
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
	sched_appt->list[cnt].room				= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].location			= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].location_type		= trim(uar_get_code_meaning(l.location_type_cd), 3)
	sched_appt->list[cnt].org_name			= trim(org.org_name, 3)
 
	sched_appt->list[cnt].schedule_id		= sa.schedule_id
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].action_dt_tm		= seact.action_dt_tm
	sched_appt->list[cnt].appt_type			= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].appt_state		= trim(sa.state_meaning, 3)
	sched_appt->list[cnt].action			= trim(seact.action_meaning, 3)
	sched_appt->list[cnt].reason_exam		= trim(sed1.oe_field_display_value, 3)
	sched_appt->list[cnt].order_phy			= trim(sed3.oe_field_display_value, 3)
	sched_appt->list[cnt].admit_phy			= per1.name_full_formatted
	sched_appt->list[cnt].attend_phy		= per2.name_full_formatted
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].dob				= p.birth_dt_tm
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[cnt].encntr_status		= trim(uar_get_code_display(e.encntr_status_cd), 3)
	sched_appt->list[cnt].fin				= eaf.alias
	sched_appt->list[cnt].health_plan		= trim(hp.plan_name, 3)
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, expand = 1, time = 60

/**************************************************************/
; select person comments
select into "nl:"
from
	 sch_date_comment sdc
	,long_text lt
	,(dummyt d1 with seq = value(size(sched_appt->list,5)))
plan d1
join sdc
	where sdc.parent_id = sched_appt->list[d1.seq].person_id
	and   sdc.parent_table = "PERSON"
	;and   sdc.active_ind = 1
join lt
	where lt.long_text_id = sdc.text_id
	and   lt.active_ind = 1
order by
	 sdc.parent_id
	,sdc.action_dt_tm 
head report
	cnt = 0
head sdc.parent_id
	cnt = 0
detail 
	cnt = (cnt + 1)
	if (cnt = 1)
		sched_appt->list[d1.seq].person_comment = trim(lt.long_text)
	else
		sched_appt->list[d1.seq].person_comment = concat(
				sched_appt->list[d1.seq].person_comment," ,",
				trim(lt.long_text))
	endif
foot sdc.parent_id
	cnt = 0
foot report
	cnt = 0
with nocounter
 
/**************************************************************/
; select scheduled procedures data
select distinct into "NL:"
from
	SCH_EVENT_ATTACH sea
 
	, (left join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "SCHEDAUTHNBR")
 
where
	expand(num, 1, size(sched_appt->list, 5), sea.sch_event_id, sched_appt->list[num].sch_event_id)
	and sea.attach_type_cd = attach_type_var
	and sea.active_ind = 1
 
order by
	sea.sch_event_id
	, o.order_id
 
 
; populate sched_appt record structure with procedure data
head sea.sch_event_id
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sea.sch_event_id, sched_appt->list[numx].sch_event_id)
 
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
		sched_appt->list[idx].procedures[cntx].order_mnemonic = nullval(trim(o.order_mnemonic, 3), novalue)
		sched_appt->list[idx].procedures[cntx].oe_field_dt_tm_value = o.current_start_dt_tm
		sched_appt->list[idx].procedures[cntx].prior_auth = nullval(trim(od.oe_field_display_value, 3), novalue)
	endif
 
foot sea.sch_event_id
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select data
select into $OUTDEV
	patient_name			= sched_appt->list[d1.seq].patient_name
	, appt_type				= sched_appt->list[d1.seq].appt_type
	;, schedule_id			= sched_appt->list[d1.seq].schedule_id
	, location				= sched_appt->list[d1.seq].location
 
	;, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, fin					= sched_appt->list[d1.seq].fin
	, facility				= sched_appt->list[d1.seq].org_name
	, encntr_type			= sched_appt->list[d1.seq].encntr_type
	, encntr_status			= sched_appt->list[d1.seq].encntr_status
	, appt_state			= sched_appt->list[d1.seq].appt_state
 
	;, person_id				= sched_appt->list[d1.seq].person_id
	, dob					= format(sched_appt->list[d1.seq].dob, "mm/dd/yy;;D")
	;, admit_phy				= sched_appt->list[d1.seq].admit_phy
	;, attend_phy			= sched_appt->list[d1.seq].attend_phy
	;, order_phy				= sched_appt->list[d1.seq].order_phy
	;, order_mnemonic		= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3)
	;, prior_auth			= trim(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth, 3)
	;, health_plan			= sched_appt->list[d1.seq].health_plan
    , person_comment		= sched_appt->list[d1.seq].person_comment
	;, sch_event_id			= sched_appt->list[d1.seq].sch_event_id
	;, sch_appt_id			= sched_appt->list[d1.seq].sch_appt_id
	;, action_dt_tm			= format(sched_appt->list[d1.seq].action_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	;, action				= sched_appt->list[d1.seq].action
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
orjoin d2
 
order by
      location
	, patient_name
	, appt_type
	, schedule_id
	;, location
	, sched_appt->list[d1.seq].appt_dt_tm
	, sched_appt->list[d1.seq].action_dt_tm
 
with nocounter, separator = " ", format, time = 60
 
 
call echorecord(sched_appt)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

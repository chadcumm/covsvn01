/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/17/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingAudit.prg
	Object name:		cov_sm_SchedulingAudit
	Request #:			2191, 3502, 4076, 4365, 4388, 12349
 
	Program purpose:	Lists scheduled appointments for selected facility.
 
	Executing from:		CCL
 
 	Special Notes:		
 
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
 	01/28/2019	Todd A. Blanchard		Added order detail for Inpatient Only Procedure.
 	02/11/2019	Todd A. Blanchard		Added logic for authorization numbers.
 	02/18/2019	Todd A. Blanchard		Added logic for cancel reason, group practice,
 										inpatient only procedure, order signed, order scanned,
 										and comments.
 	02/20/2019	Todd A. Blanchard		Changed cancel reason to action comment.
 										Added time zone adjustment to DOB.
	09/09/2019	Daniel Claus			Added entry_state to report.
										Added SCH_ENTRY TO QUERY LINKED TO SCH_EVENT
	03/08/2022	Todd A. Blanchard		Changed practice site display to org name.
 
******************************************************************************/
 
drop program cov_sm_SchedulingAudit:DBA go
create program cov_sm_SchedulingAudit:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
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
 
declare ssn_var								= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var								= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var								= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare attach_type_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare admitting_physician_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN"))
declare attending_physician_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN"))
declare cancel_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CANCEL"))
declare view_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "VIEW"))
declare action_comments_text_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 15149, "ACTIONCOMMENTS"))
declare action_comments_sub_text_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 15589, "ACTIONCOMMENTS"))
declare physician_order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER"))
declare outside_order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER"))
declare perform_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM"))
declare order_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
 
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
		2	entry_state		= c30
		2	action_dt_tm	= dq8
		2	action			= c30
		2	reason_exam		= c100
		2	action_comment	= c300
 
		2	order_phy			= c100
		2	order_phy_group		= c100
		2	performed_prsnl_id	= f8
		2	admit_phy			= c100
		2	attend_phy			= c100
 
		2 proc_cnt			= i4
		2 procedures[*]
			3	order_id			= f8
			3	order_mnemonic		= c100
			3	order_dt_tm			= dq8
			3	prior_auth			= c30
			3	inpat_only_proc		= c3
			3	order_signed_yn		= c3
			3	order_scanned_yn	= c3
 
		2	person_id		= f8
		2	patient_name	= c100
		2	dob				= dq8
		2	dob_tz			= i4
 
 		2	encntr_id		= f8
 		2	encntr_type		= c100
 		2	encntr_status	= c30
		2	fin				= c10
		2	health_plan		= c100
		2	auth_nbr		= c50
 
		2	comments		= c255
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
 
 	; scheduled resource
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
		
	; schedule entry
	, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
	
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_meaning = "SPECINX"
		and sed2.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning = "SCHORDPHYS"
		and sed3.active_ind = 1)
 
	, (left join PRSNL per on per.person_id = sed3.oe_field_value
		and per.active_ind = 1)
 
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 
	, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id)
 
	, (left join SCH_EVENT_ACTION seact on seact.sch_event_id = sev.sch_event_id
		and seact.sch_action_cd != view_var
		and seact.active_ind = 1)
 
	, (left join SCH_EVENT_COMM sec on sec.sch_event_id = seact.sch_event_id
		and sec.sch_action_id = seact.sch_action_id
		and sec.text_type_cd = action_comments_text_var
		and sec.sub_text_cd = action_comments_sub_text_var
		and sec.active_ind = 1)
 
	, (left join LONG_TEXT lt on lt.long_text_id = sec.text_id
		and lt.active_ind = 1)
 
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
 
	; health plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
		and epar.active_ind = 1)
 
	, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
		and au.active_ind = 1)
 
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.end_effective_dt_tm > sysdate
		and hp.active_ind = 1)
 
	; scanned order
	, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and ce.event_cd in (physician_order_var, outside_order_var))
 
	, (left join CE_EVENT_PRSNL ceper on ceper.event_id = ce.event_id
		and ceper.action_type_cd = perform_var)
 
 	; physicians
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
	, seact.sch_action_id
 
 
; populate sched_appt record structure
head report
	cnt = 0
 
	call alterlist(sched_appt->list, 100)
 
head sa.sch_appt_id
	null
 
head seact.sch_action_id
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
	sched_appt->list[cnt].entry_state		= trim(uar_get_code_display(sen.entry_state_cd), 30)
 
	sched_appt->list[cnt].action_comment	= lt.long_text
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(13), " ", 4)
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(10), " ", 4)
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(0), " ", 4)
	sched_appt->list[cnt].action_comment	= trim(sched_appt->list[cnt].action_comment, 3)
 
	sched_appt->list[cnt].order_phy				= trim(sed3.oe_field_display_value, 3)
	sched_appt->list[cnt].order_phy_group		= trim(org_ps.org_name, 3)
	sched_appt->list[cnt].performed_prsnl_id	= ce.performed_prsnl_id
 
	sched_appt->list[cnt].admit_phy			= per1.name_full_formatted
	sched_appt->list[cnt].attend_phy		= per2.name_full_formatted
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].dob				= p.birth_dt_tm
	sched_appt->list[cnt].dob_tz			= p.birth_tz
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[cnt].encntr_status		= trim(uar_get_code_display(e.encntr_status_cd), 3)
	sched_appt->list[cnt].fin				= eaf.alias
	sched_appt->list[cnt].health_plan		= trim(hp.plan_name, 3)
	sched_appt->list[cnt].auth_nbr			= trim(au.auth_nbr, 3)
 
	sched_appt->list[cnt].comments			= replace(sed2.oe_field_display_value, char(13), " ", 4)
	sched_appt->list[cnt].comments			= replace(sched_appt->list[cnt].comments, char(10), " ", 4)
	sched_appt->list[cnt].comments			= replace(sched_appt->list[cnt].comments, char(0), " ", 4)
	sched_appt->list[cnt].comments			= trim(sched_appt->list[cnt].comments, 3)
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, time = 60
 
 
/**************************************************************/
; select scheduled procedures data
 
select distinct into "NL:"
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
 
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_meaning = "SURGUSER1")
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
	, (inner join PRSNL per on per.person_id = oa.action_personnel_id)
 
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
		sched_appt->list[idx].procedures[cntx].inpat_only_proc = trim(od2.oe_field_display_value, 3)
		sched_appt->list[idx].procedures[cntx].order_signed_yn = evaluate(per.physician_ind, 1, "YES", "NO")
		sched_appt->list[idx].procedures[cntx].order_scanned_yn = evaluate2(
			if (sched_appt->list[idx].performed_prsnl_id > 0.0)
				"YES"
			else
				"NO"
			endif
			)
	endif
 
foot sa.sch_appt_id
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select data
select into $OUTDEV
	patient_name			= sched_appt->list[d1.seq].patient_name
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, schedule_id			= sched_appt->list[d1.seq].schedule_id
	, location				= sched_appt->list[d1.seq].location
 
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, fin					= sched_appt->list[d1.seq].fin
	, facility				= sched_appt->list[d1.seq].org_name
	, encntr_type			= sched_appt->list[d1.seq].encntr_type
	, encntr_status			= sched_appt->list[d1.seq].encntr_status
	, appt_state			= sched_appt->list[d1.seq].appt_state
 	, entry_state			= sched_appt->list[d1.seq].entry_state
 	
	, person_id				= sched_appt->list[d1.seq].person_id
	, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob, 
								sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
								
	, admit_phy				= sched_appt->list[d1.seq].admit_phy
	, attend_phy			= sched_appt->list[d1.seq].attend_phy
	, order_phy				= sched_appt->list[d1.seq].order_phy
	, order_mnemonic		= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3)
 
	, auth_nbr				= if (trim(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth, 3) =
								trim(sched_appt->list[d1.seq].auth_nbr, 3))
								trim(sched_appt->list[d1.seq].auth_nbr, 3)
 
							  elseif (size(trim(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth, 3)) > 0
							  	and size(trim(sched_appt->list[d1.seq].auth_nbr, 3)) = 0)
							  	trim(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth, 3)
 
							  elseif (size(trim(sched_appt->list[d1.seq].auth_nbr, 3)) > 0
							  	and size(trim(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth, 3)) = 0)
							  	trim(sched_appt->list[d1.seq].auth_nbr, 3)
 
							  else
							  	build2(trim(sched_appt->list[d1.seq].auth_nbr, 3), " / ",
							  		trim(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth, 3))
 
							  endif
 
	, health_plan			= sched_appt->list[d1.seq].health_plan
 
	, sch_event_id			= sched_appt->list[d1.seq].sch_event_id
	, sch_appt_id			= sched_appt->list[d1.seq].sch_appt_id
	, action_dt_tm			= format(sched_appt->list[d1.seq].action_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, action				= sched_appt->list[d1.seq].action
 
	, action_comment		= trim(sched_appt->list[d1.seq].action_comment, 3)
 
	, group_practice		= sched_appt->list[d1.seq].order_phy_group
	, inpat_only_proc		= trim(sched_appt->list[d1.seq].procedures[d2.seq].inpat_only_proc, 3)
 
	, order_signed_yn		= if (isnumeric(sched_appt->list[d1.seq].procedures[d2.seq].order_signed_yn) = 0)
								sched_appt->list[d1.seq].procedures[d2.seq].order_signed_yn
							  else
							  	""
							  endif
 
	, order_scanned_yn		= if (isnumeric(sched_appt->list[d1.seq].procedures[d2.seq].order_scanned_yn) = 0)
								sched_appt->list[d1.seq].procedures[d2.seq].order_scanned_yn
							  else
							  	""
							  endif
 
	, comments				= sched_appt->list[d1.seq].comments
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
orjoin d2
 
order by
	patient_name
	, sched_appt->list[d1.seq].appt_dt_tm
	, sched_appt->list[d1.seq].action_dt_tm
;	, appt_type
	, schedule_id
	, location
 
with nocounter, separator = " ", format, time = 60
 
 
;call echorecord(sched_appt)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		02/19/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingActions.prg
	Object name:		cov_sm_SchedulingActions
	Request #:			4438, 5571, 6537, 7275, 7508, 11683, 12349, 12450
 
	Program purpose:	Lists scheduled appointments for selected scheduled
						event actions.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	09/17/2019	Daniel Claus			Facility Prompt: Filter to non acute only.
 										Action Prompt: Added "No Show".
 										Added Practice Group Prompt.
 										Added Practice Group filter to PRACTICE_SITE join.
002	10/29/2019	Todd A. Blanchard		Added value 'Cancel-Unable to reach patient to sched'
 										to Scheduled Event Action prompt from Cancel Reason.
003	01/10/2020	Todd A. Blanchard		Corrected criteria for practice group.
004	03/31/2020	Todd A. Blanchard		Added Prior Auth and Action Completed By.
005	06/25/2020	Todd A. Blanchard		Added Organization and Location.
 										Added Fort Sanders West to facility prompt.
006	01/18/2021  Dawn Greer, DBA			Changed query timeout from 60 to 300.
007	12/03/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
008	03/08/2022	Todd A. Blanchard		Changed practice site display to org name.
009	03/21/2022	Todd A. Blanchard		Added FSR Thompson Comprehensive Breast Center to prompt.
******************************************************************************/
 
drop program cov_sm_SchedulingActions_TEST:DBA go
create program cov_sm_SchedulingActions_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"               ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Scheduled Event Action" = VALUE(       4518.00)
	, "Physician Group" = VALUE(0.0             ) 

with OUTDEV, facility, start_datetime, end_datetime, action, physician_group
 
 
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
declare confirm_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CONFIRM"))
declare cancel_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CANCEL"))
declare noshow_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "NOSHOW"))
declare cancel_unable_sched_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14229, "CANCELUNABLETOREACHPATIENTTOSCHED"))
declare action_comments_text_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 15149, "ACTIONCOMMENTS"))
declare action_comments_sub_text_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 15589, "ACTIONCOMMENTS"))
declare physician_order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER"))
declare outside_order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER"))
declare perform_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM"))
declare order_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
 
declare num									= i4 with noconstant(0)
declare novalue								= vc with constant("Not Available")
declare op_facility_var						= vc with noconstant("")
declare op_action_var						= vc with noconstant("")
declare op_practice_var						= vc with noconstant("") ;001
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
; define operator for $action
if (substring(1, 1, reflect(parameter(parameter2($action), 0))) = "L") ; multiple values selected
    set op_action_var = "IN"
else ; single value selected
    set op_action_var = "="
endif
 
 
; define operator for $practice ;001
if (substring(1, 1, reflect(parameter(parameter2($physician_group), 0))) = "L") ; multiple values selected
    set op_practice_var = "IN"
else ; single value selected
    set op_practice_var = "="
endif

 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_appt (
	1	p_start_datetime	= vc
	1	p_end_datetime		= vc
 
	1	sched_cnt			= i4
	1	list[*]
		2	sch_appt_id			= f8
		2	appt_dt_tm			= dq8
		2	room				= c100
		2	location			= c100
		2	location_type		= c100
		2	org_name			= c100
 
		2	schedule_id			= f8
		2	sch_event_id		= f8
		2	appt_type			= c100
		2	appt_state			= c30
		2	action_dt_tm		= dq8
		2	action				= c30
		2	action_prsnl_id		= f8 ;004
		2	action_prsnl		= c100 ;004
		2	reason				= c40
		2	reason_exam			= c100
		2	action_comment		= c300
 
		2	order_phy			= c100
		2	order_phy_group		= c100
		2	performed_prsnl_id	= f8
		2	admit_phy			= c100
		2	attend_phy			= c100
 
		2 proc_cnt				= i4
		2 procedures[*]
			3	order_id			= f8
			3	order_mnemonic		= c100
			3	order_dt_tm			= dq8
			3	order_comment		= c300
			3	prior_auth			= c30
			3	inpat_only_proc		= c3
			3	order_signed_yn		= c3
			3	order_scanned_yn	= c3
 
		2	person_id			= f8
		2	patient_name		= c100
		2	dob					= dq8
		2	dob_tz				= i4
 
 		2	encntr_id			= f8
 		2	encntr_type			= c100
 		2	encntr_status		= c30
		2	fin					= c10
		2	health_plan			= c100
		2	auth_nbr			= c50
 
		2	comments			= c255
)
 
 
/**************************************************************/
; populate record structure with prompt data
set sched_appt->p_start_datetime = format(cnvtdate2($start_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
set sched_appt->p_end_datetime = format(cnvtdate2($end_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
 
/**************************************************************/
; select scheduled appointment data
select
	;003
	if (substring(1, 1, reflect(parameter(parameter2($physician_group), 0))) = "I")
		; practice site not selected
		where
			sa.role_meaning = "PATIENT"
			and sa.sch_state_cd in (
				select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
			)
			and sa.active_ind = 1
	else
		; practice site selected
		where
			sa.role_meaning = "PATIENT"
			and sa.sch_state_cd in (
				select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
			)
			and sa.active_ind = 1
			and operator(ps.practice_site_id, op_practice_var, $physician_group)
	endif
	
into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.schedule_id = sa.schedule_id ;005
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
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id) ;003
 
	, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id) ;008
 
 	; action
	, (inner join SCH_EVENT_ACTION seact on seact.sch_event_id = sev.sch_event_id
		and seact.schedule_id = sa.schedule_id
		and seact.action_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		;002
		and (
			(operator(seact.sch_action_cd, op_action_var, $action)
				and seact.sch_action_cd in (confirm_var, cancel_var, noshow_var)) ;001
 
			or
 
			(operator(seact.sch_reason_cd, op_action_var, $action) ;002
				and seact.sch_reason_cd in (cancel_unable_sched_var)) ;002
		)
		and seact.active_ind = 1)
 
	, (inner join PRSNL per3 on per3.person_id = seact.action_prsnl_id) ;004
 
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
	sched_appt->list[cnt].action			= trim(uar_get_code_display(seact.sch_action_cd), 3)
	sched_appt->list[cnt].action_prsnl_id	= seact.action_prsnl_id ;004
	sched_appt->list[cnt].action_prsnl		= per3.name_full_formatted ;004
	sched_appt->list[cnt].reason			= trim(uar_get_code_display(seact.sch_reason_cd), 3)
	sched_appt->list[cnt].reason_exam		= trim(sed1.oe_field_display_value, 3)
 
	sched_appt->list[cnt].action_comment	= lt.long_text
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(13), " ", 4)
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(10), " ", 4)
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(0), " ", 4)
	sched_appt->list[cnt].action_comment	= trim(sched_appt->list[cnt].action_comment, 3)
 
	sched_appt->list[cnt].order_phy				= trim(sed3.oe_field_display_value, 3)
	sched_appt->list[cnt].order_phy_group		= trim(org_ps.org_name, 3) ;008
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
 
WITH nocounter, time = 300	;006
 
 
/**************************************************************/
; select scheduled procedures data ;005 
select into "NL:"
from
	SCH_APPT sa
	
	, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.active_ind = 1)
 
	, (left join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "SCHEDAUTHNBR")
 
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_meaning = "SURGUSER1")
 
	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
	, (left join PRSNL per on per.person_id = oa.action_personnel_id)
 
	, (left join ORDER_COMMENT oc on oc.order_id = o.order_id)
 
	, (left join LONG_TEXT lt on lt.long_text_id = oc.long_text_id
		and lt.parent_entity_id = oc.order_id
		and lt.parent_entity_name = "ORDER_COMMENT")
 
where
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sa.sch_event_id, sched_appt->list[num].sch_event_id)
 
order by
	sa.sch_appt_id
	, sa.sch_event_id
	, o.order_id
 
 
; populate sched_appt record structure with procedure data
head sea.sch_event_id
	null
 
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
 
	sched_appt->list[idx].procedures[cntx].order_comment = lt.long_text
 
	sched_appt->list[idx].procedures[cntx].order_comment = replace(
		sched_appt->list[idx].procedures[cntx].order_comment, char(13), " ", 4)
 
	sched_appt->list[idx].procedures[cntx].order_comment = replace(
		sched_appt->list[idx].procedures[cntx].order_comment, char(10), " ", 4)
 
	sched_appt->list[idx].procedures[cntx].order_comment = replace(
		sched_appt->list[idx].procedures[cntx].order_comment, char(0), " ", 4)
 
	sched_appt->list[idx].procedures[cntx].order_comment = trim(sched_appt->list[idx].procedures[cntx].order_comment, 3)
 
foot sa.sch_appt_id
	if (cntx = 0)
		cntx = 1
	endif

 	sched_appt->list[idx].proc_cnt = cntx
 	
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, expand = 1, time = 300	;006
 
 
/**************************************************************/
; select data
select distinct into $OUTDEV
	patient_name			= sched_appt->list[d1.seq].patient_name
	, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob,
																  sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
 
;	, person_id				= sched_appt->list[d1.seq].person_id
	, fin					= sched_appt->list[d1.seq].fin
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, appt_state			= sched_appt->list[d1.seq].appt_state
 
;	, schedule_id			= sched_appt->list[d1.seq].schedule_id
	, location				= sched_appt->list[d1.seq].location ;005
	, facility				= sched_appt->list[d1.seq].org_name ;005
;	, encntr_type			= sched_appt->list[d1.seq].encntr_type
;	, encntr_status			= sched_appt->list[d1.seq].encntr_status
;	, admit_phy				= sched_appt->list[d1.seq].admit_phy
;	, attend_phy			= sched_appt->list[d1.seq].attend_phy
 
	, order_dt_tm			= format(sched_appt->list[d1.seq].procedures[d2.seq].order_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, order_mnemonic		= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3)
	, order_phy				= sched_appt->list[d1.seq].order_phy
	, group_practice		= sched_appt->list[d1.seq].order_phy_group
 
;	, inpat_only_proc		= trim(sched_appt->list[d1.seq].procedures[d2.seq].inpat_only_proc, 3)
 
;	, order_signed_yn		= if (isnumeric(sched_appt->list[d1.seq].procedures[d2.seq].order_signed_yn) = 0)
;								sched_appt->list[d1.seq].procedures[d2.seq].order_signed_yn
;							  else
;							  	""
;							  endif
 
;	, order_scanned_yn		= if (isnumeric(sched_appt->list[d1.seq].procedures[d2.seq].order_scanned_yn) = 0)
;								sched_appt->list[d1.seq].procedures[d2.seq].order_scanned_yn
;							  else
;							  	""
;							  endif
 
	, order_comment			= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_comment, 3)
 
	, action_dt_tm			= format(sched_appt->list[d1.seq].action_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, action				= sched_appt->list[d1.seq].action
	, action_prsnl			= sched_appt->list[d1.seq].action_prsnl ;004
	, action_comment		= trim(sched_appt->list[d1.seq].action_comment, 3)
	, reason				= trim(sched_appt->list[d1.seq].reason, 3)
 
;	, comments				= sched_appt->list[d1.seq].comments
 
 	;004
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

from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
join d2 ;005
 
order by
	patient_name
	, sched_appt->list[d1.seq].person_id
	, fin
	, sched_appt->list[d1.seq].appt_dt_tm
;	, appt_type
;	, sched_appt->list[d1.seq].schedule_id
	, sched_appt->list[d1.seq].action_dt_tm
;	, action
;	, location
 
with nocounter, separator = " ", format, time = 300 	;006
 
 
;call echorecord(sched_appt)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

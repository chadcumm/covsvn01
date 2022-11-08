/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				David Baumgardner
	Date Written:		08/26/20
	Solution:			Ambulatory
	Source file name:	cov_amb_SchedulingActions.prg
	Object name:		cov_amb_SchedulingActions
	Request #:			7864
 
	Program purpose:	Lists scheduled appointments for selected scheduled
						event actions.
 
	Executing from:		CCL
 
 	Special Notes:		Originally cov_am_schedulingActions.prg
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 		Mod Date	Developer				Comment
 		----------	--------------------	--------------------------------------
001		01/24/21	David Baumgardner		Adding in the extract capabilities for the Report to web functionality
002		02/08/21	David Baumgardner		CR9086 update to pull 30 days of data instead of just the day of running.
003		02/15/21	David Baumgardner		CR9086 Update for the following changes:
												- Only the latest action would return on the report
												- Eliminate Action, Scheduling_dt_tm, and Action_dt_tm
        02/17/21    David Baumgardner    		- fix Auth_exp
004		02/25/21	David Baumgardner		Requested to reenable the scheduling_dt_tm and to report out the org_name
005		04/14/21	David Baumgardner		Requested to omit rescheduled items.  Marsha Keck on 4/12 noting this caused issues
												"not reporting the correct appointment date"
006		04/19/21	David Baumgardner		Marsha had a note on an item that was not previously listed on this report that should
											have shown.
007		05/17/21	David Baumgardner		Report noted to not be pulling the latest comment or the latest preauth items.  Added
											correction to this data.
008		05/24/21	David Baumgardner		Upgrade last Thursday night caused degradation of the subqueries.
009		07/23/21	David Baumgardner		CR10725   Add in the next the patient's next office visit appt with the ordering provider group
******************************************************************************/
 
drop program COV_AMB_SCHEDULINGACTIONS_TEST:DBA go
create program COV_AMB_SCHEDULINGACTIONS_TEST:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"                                                                                ;* Enter
	, "Facility" = VALUE(3144501.00, 675844.00, 3234047.00, 3144499.00, 3144505.00, 3144502.00, 3144503.00, 3144504.00)
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Scheduled Event Action" = VALUE(       4521.00)
	, "Physician Group" = VALUE(0.0             )
	, "Provider" = 0
	, "Automated CMGExport" = "0"
 
with OUTDEV, facility, start_datetime, end_datetime, action, physician_group,
	userProvider, CMGExport
 
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
declare view_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "VIEW"))
 
declare num									= i4 with noconstant(0)
declare novalue								= vc with constant("Not Available")
declare op_facility_var						= vc with noconstant("")
declare op_action_var						= vc with noconstant("")
declare op_practice_var						= vc with noconstant("")
declare op_provider_var						= vc with noconstant("")
;declare order_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare orgdoc_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR"))
declare stardoc_var = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))
 
;setup file path information
declare file_var						= vc with constant(build(format(curdate, "mm-dd-yyyy;;d"), "_schedulingactions_cmg.csv")) ;013
 
declare temppath_var					= vc with constant(build("cer_temp:", file_var)) ;013
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var)) ;013
 
;013
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
;declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
;															 	 "_cust/to_client_site/CernerCCL/", file_var))
 
declare cmd								= vc with noconstant("") ;013
declare len								= i4 with noconstant(0) ;013
declare stat							= i4 with noconstant(0) ;013
DECLARE bdate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE edate	 = f8 WITH NOCONSTANT(0.0), PROTECT
 
set output_var = value(temppath_var)
 
 
 
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
 
 
; define operator for $provider
if (substring(1, 1, reflect(parameter(parameter2($userProvider), 0))) = "L") ; multiple values selected
    set op_provider_var = "IN"
else ; single value selected
    set op_provider_var = "="
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
		2	location_id			= f8
		2	location			= c100
		2	location_type		= c100
		2	org_name			= c100
 
		2	schedule_id			= f8
		2	sch_event_id		= f8
		2	appt_type			= c100
		2	appt_state			= c30
		2	action_dt_tm		= dq8
		2	action				= c30
		2	action_prsnl_id		= f8
		2	action_prsnl		= c100
		2	reason				= c40
		2	reason_exam			= c100
		2	action_comment		= c300
		2	schedule_dt_tm		= dq8
 
		2	order_phy			= c100
		2	order_phy_group		= c100
		2	performed_prsnl_id	= f8
		2	admit_phy			= c100
		2	attend_phy			= c100
 
		;009 next appointment
		2	next_appt_dt_tm		= dq8
		2	primary_practice_entity = f8
 
		2 proc_cnt				= i4
		2 procedures[*]
			3	order_id			= f8
			3   order_location_id	= f8
			3   order_location		= c100
			3	order_mnemonic		= c100
			3	order_dt_tm			= dq8
			3	order_comment		= c300
			3   order_comment_as	= i4 ; action_sequence for comment
			3	prior_auth			= c30
			3	inpat_only_proc		= c3
			3	order_signed_yn		= c3
			3	order_scanned_yn	= c3
			3   prior_auth_exp		= c30
			3   auth_as				= i4 ; action_sequence for authorization number
 
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
		2	auth_expire_dt		= dq8
 
		2	comments			= c255
		2   star_id				= c50
)
 
 
record organizationList (
  1 olist[*]
  	2 organization = f8
)
 
/**************************************************************/
; populate record structure with prompt data
set sched_appt->p_start_datetime = format(cnvtdate2($start_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
set sched_appt->p_end_datetime = format(cnvtdate2($end_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
;002 update the edate and bdate to pull for 30 days from now for the export.
if($CMGExport = "0")
	SET bdate = CNVTDATETIME($start_datetime)
	SET edate = CNVTDATETIME($end_datetime)
else
	SET bdate = CNVTDATETIME(CURDATE, 0)
	SET edate = CNVTDATETIME(CURDATE+30,235959)
endif
 
;001 CMG Export build data
if (NOT($CMGExport = "0"))
 
	SELECT *
	FROM ORG_SET_ORG_R ORG_S_ORG_R
	WHERE ORG_S_ORG_R.org_set_id = 3875838.00
	head report
    	ocnt = 0
	    stat = alterlist(organizationList->olist,50)
		numx = 0
	head ORG_S_ORG_R.organization_id
		ocnt = ocnt+1
		if(mod(ocnt,10)=1 and ocnt > 50)
			stat = alterlist(organizationList->olist,ocnt+9)
		endif
		organizationList->olist[ocnt].organization = ORG_S_ORG_R.organization_id
 
	foot report
		stat = alterlist(organizationList->olist, ocnt)
	with nocount
endif
 
/**************************************************************/
; select scheduled appointment data
select
	if (substring(1, 1, reflect(parameter(parameter2($physician_group), 0))) = "I"
		and substring(1, 1, reflect(parameter(parameter2($userProvider), 0))) = "I")
		; practice site not selected
		where
			sa.role_meaning = "PATIENT"
			and sa.sch_state_cd in (
				select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
			)
			and sa.active_ind = 1
			and sa.sch_state_cd != 4545.00
			and sa.beg_dt_tm between cnvtdatetime(bdate) and cnvtdatetime(edate)
	elseif (substring(1, 1, reflect(parameter(parameter2($userProvider), 0))) = "I")
		where
			sa.role_meaning = "PATIENT"
			and sa.sch_state_cd in (
				select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
			)
			and sa.active_ind = 1
			and sa.sch_state_cd != 4545.00
			and operator(ps.practice_site_id, op_practice_var, $physician_group)
			and sa.beg_dt_tm between cnvtdatetime(bdate) and cnvtdatetime(edate)
	elseif (substring(1, 1, reflect(parameter(parameter2($physician_group), 0))) = "I")
		where
			sa.role_meaning = "PATIENT"
			and sa.sch_state_cd in (
				select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
			)
			and sa.active_ind = 1
			and sa.sch_state_cd != 4545.00
			and operator(per.person_id, op_provider_var, $userProvider)
			and sa.beg_dt_tm between cnvtdatetime(bdate) and cnvtdatetime(edate)
	else
		; practice site selected
		where
			sa.role_meaning = "PATIENT"
			and sa.sch_state_cd in (
				select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
			)
			and sa.active_ind = 1
			and sa.sch_state_cd != 4545.00
			and operator(per.person_id, op_provider_var, $userProvider)
			and operator(ps.practice_site_id, op_practice_var, $physician_group)
			and sa.beg_dt_tm between cnvtdatetime(bdate) and cnvtdatetime(edate)
 
	endif
 
into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
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
		and sev.active_ind = 1
		and sev.appt_type_cd not in (
			select cv.code_value from CODE_VALUE cv where cv.code_set = 14230 and cv.active_ind = 1
			and (cv.display like "IV Inf*"
			or cv.display like "ONC Lab"
			or cv.display like "IV Inj*")
		))
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
	, (inner join PRSNL_ALIAS pera_oa on pera_oa.person_id = per.person_id
                                and pera_oa.prsnl_alias_type_cd = orgdoc_var
                                and pera_oa.alias_pool_cd = stardoc_var
                                and pera_oa.end_effective_dt_tm > sysdate
                                and pera_oa.active_ind = 1)
 
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id
		and ps.practice_site_display NOT LIKE "*DO NOT USE*")
 
 	; action  009 Update to counter degradation of sub queries
	, (inner join SCH_EVENT_ACTION seact on seact.sch_event_id = sev.sch_event_id
		and seact.schedule_id = sa.schedule_id
;		and seact.action_meaning != "VIEW"
;		and seact.sch_action_id = (
;			SELECT MAX(sub_seact.sch_action_id)
;			from sch_event_action sub_seact
;			where sub_seact.action_meaning != "VIEW"
;			and sub_seact.schedule_id = sa.schedule_id
;			and sub_seact.sch_event_id = sev.sch_event_id
;			and sub_seact.active_ind = 1
;			and (
;			(operator(sub_seact.sch_action_cd, op_action_var, $action)
;				and sub_seact.sch_action_cd in (confirm_var, cancel_var, noshow_var))
;
;			or
;
;			(operator(sub_seact.sch_reason_cd, op_action_var, $action)
;				and sub_seact.sch_reason_cd in (cancel_unable_sched_var))
;			)
;;			group by
;;				sch_event_id,
;;				schedule_id
;		)
 
 
		and seact.active_ind = 1
;		and seact.action_meaning = "SCHEDULE"
		)
 
	, (inner join PRSNL per3 on per3.person_id = seact.action_prsnl_id)
 
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
		and e.organization_id != 0.00
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
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id
		and org.active_ind = 1)
 
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
	sched_appt->list[cnt].location_id		= sa.appt_location_cd
	sched_appt->list[cnt].location			= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].location_type		= trim(uar_get_code_meaning(l.location_type_cd), 3)
	sched_appt->list[cnt].org_name			= trim(org.org_name, 3)
;	sched_appt->list[cnt].org_name			= trim("", 3)
 
	sched_appt->list[cnt].schedule_id		= sa.schedule_id
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].action_dt_tm		= seact.action_dt_tm
	sched_appt->list[cnt].schedule_dt_tm	= seact.action_dt_tm
	sched_appt->list[cnt].appt_type			= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].appt_state		= trim(sa.state_meaning, 3)
	sched_appt->list[cnt].action			= trim(uar_get_code_display(seact.sch_action_cd), 3)
	sched_appt->list[cnt].action_prsnl_id	= seact.action_prsnl_id
	sched_appt->list[cnt].action_prsnl		= per3.name_full_formatted
	sched_appt->list[cnt].reason			= trim(uar_get_code_display(seact.sch_reason_cd), 3)
	sched_appt->list[cnt].reason_exam		= trim(sed1.oe_field_display_value, 3)
 
	sched_appt->list[cnt].action_comment	= lt.long_text
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(13), " ", 4)
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(10), " ", 4)
	sched_appt->list[cnt].action_comment	= replace(sched_appt->list[cnt].action_comment, char(0), " ", 4)
	sched_appt->list[cnt].action_comment	= trim(sched_appt->list[cnt].action_comment, 3)
 
	sched_appt->list[cnt].order_phy			= trim(sed3.oe_field_display_value, 3)
	sched_appt->list[cnt].order_phy_group	= trim(ps.practice_site_display, 3)
	sched_appt->list[cnt].primary_practice_entity = sa.appt_location_cd
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
	sched_appt->list[cnt].auth_expire_dt	= au.auth_expire_dt_tm
 
	sched_appt->list[cnt].comments			= replace(sed2.oe_field_display_value, char(13), " ", 4)
	sched_appt->list[cnt].comments			= replace(sched_appt->list[cnt].comments, char(10), " ", 4)
	sched_appt->list[cnt].comments			= replace(sched_appt->list[cnt].comments, char(0), " ", 4)
	sched_appt->list[cnt].comments			= trim(sched_appt->list[cnt].comments, 3)
	sched_appt->list[cnt].star_id			= pera_oa.alias
 
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, time = 1000
 
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
	expand(num, 1, size(sched_appt->list, 5), sen.sch_event_id, sched_appt->list[num].sch_event_id)
	and sen.active_ind = 1
 
order by
	sen.sch_event_id
 
 
; populate sched_obj record structure with health plan data
head sen.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sen.sch_event_id, sched_appt->list[numx].sch_event_id)
 
detail
	if (sched_appt->list[idx].encntr_id <= 0)
 		sched_appt->list[idx].health_plan = trim(hp.plan_name, 3)
	endif
 
WITH nocounter, expand = 1, time = 600
 
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
		and od.oe_field_meaning = "SCHEDAUTHNBR"
; 007 Add a section to ensure we are pulling the latest action_sequence
		and od.action_sequence = (SELECT MAX(sub_od.action_sequence)
									FROM ORDER_DETAIL sub_od
									where sub_od.order_id = o.order_id
									and sub_od.oe_field_meaning = "SCHEDAUTHNBR"
									; 008
									;GROUP BY SUB_OD.order_id
									)
; end 007
		)
 
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_meaning = "SURGUSER1")
; PULL THE AUTH EXPIRE DT from the order detail.
	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_meaning = "SURGRECOVERYDUR"
		and od3.action_sequence = (SELECT MAX(OD.action_sequence)
								FROM ORDER_DETAIL OD
								WHERE od3.order_id = OD.order_id
									and OD.oe_field_meaning = "SURGRECOVERYDUR")
		)
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
	, (inner join PRSNL per on per.person_id = oa.action_personnel_id)
 
	, (left join ORDER_COMMENT oc on oc.order_id = o.order_id
; 007 Add a section to ensure we are pulling the latest action_sequence
		and oc.action_sequence = (SELECT MAX(sub_oc.action_sequence)
								  FROM ORDER_COMMENT SUB_OC
								  where SUB_OC.order_id = O.order_id
								  ;008
								  ;GROUP BY SUB_OC.order_id
								  )
; end 007
	)
 
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
		sched_appt->list[idx].procedures[cntx].prior_auth_exp = trim(od3.oe_field_display_value, 3)
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
 
	endif
 
foot sa.sch_appt_id
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, expand = 1, time = 1000
 
;009 Get patient's next scheduled appointment with the ordering provider's physicians group.
select distinct into "NL:"
from
	SCH_APPT sa
WHERE
	EXPAND(num, 1, size(sched_appt->list, 5)
		,sa.person_id,sched_appt->list[num].person_id
		,sa.appt_location_cd, sched_appt->list[num].location_id
		)
 
	and sa.beg_dt_tm = (SELECT MIN(sub_sa.beg_dt_tm)
		from SCH_APPT sub_sa
		where sub_sa.person_id = sa.person_id
			and sa.appt_location_cd = sub_sa.appt_location_cd
			and sub_sa.beg_dt_tm >= sysdate
			and sub_sa.state_meaning != "CANCELED")
head sa.person_id
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(sched_appt->list, 5), sa.person_id, sched_appt->list[numx].person_id
		, sa.appt_location_cd, sched_appt->list[numx].location_id)
	next = 0
 
detail
	sched_appt->list[idx].next_appt_dt_tm = sa.beg_dt_tm
	next = locateval(numx, idx+1, size(sched_appt->list, 5), sa.person_id, sched_appt->list[numx].person_id
		, sa.appt_location_cd, sched_appt->list[numx].location_id)
	while (next != 0)
		sched_appt->list[next].next_appt_dt_tm = sa.beg_dt_tm
		next = locateval(numx, next+1, size(sched_appt->list, 5), sa.person_id, sched_appt->list[numx].person_id
		, sa.appt_location_cd, sched_appt->list[numx].location_id)
	endwhile
 
WITH nocounter, time = 600, expand =1
 
 
; 001 extract capabilities
if ($CMGExport = "0")
	CALL OUTPUT_SPREADSHEET(null)
else
	CALL OUTPUT_ASTREAM(null)
endif
 
SUBROUTINE OUTPUT_SPREADSHEET(null)
/**************************************************************/
; select data
select DISTINCT into $OUTDEV
	schedule_event_id				= sched_appt->list[d1.seq].sch_event_id
	, schedule_appt_id				= sched_appt->list[d1.seq].sch_appt_id
	, order_id				= sched_appt->list[d1.seq].procedures[d2.seq].order_id
	,patient_name			= sched_appt->list[d1.seq].patient_name
	, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob,
																  sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
 
	, fin					= sched_appt->list[d1.seq].fin
	, order_phy				= sched_appt->list[d1.seq].order_phy
;004 add in the org_name
	, org_name				= sched_appt->list[d1.seq].org_name
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, health_plan			= sched_appt->list[d1.seq].health_plan
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
 
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
; 	, sch_evnt_id			= sched_appt->list[d1.seq].sch_appt_id
;	, order_id				= sched_appt->list[d1.seq].procedures[d2.seq].order_id
	, order_comment			= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_comment, 3)
 
	, auth_expire_dt		= build2(format(sched_appt->list[d1.seq].auth_expire_dt, "mm/dd/yyyy hh:mm:ss;;Q"),
								TRIM(sched_appt->list[d1.seq].procedures[d2.seq].prior_auth_exp,3))
	, group_practice		= sched_appt->list[d1.seq].order_phy_group
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
 
	, appt_state			= sched_appt->list[d1.seq].appt_state
 
	, order_dt_tm			= format(sched_appt->list[d1.seq].procedures[d2.seq].order_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, order_mnemonic		= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3)
 
	, schedule_dt_tm		= format(sched_appt->list[d1.seq].schedule_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
;
;	, action_dt_tm			= format(sched_appt->list[d1.seq].action_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
;	, action				= sched_appt->list[d1.seq].action
	, action_prsnl			= sched_appt->list[d1.seq].action_prsnl
	, action_comment		= trim(sched_appt->list[d1.seq].action_comment, 3)
	, reason				= trim(sched_appt->list[d1.seq].reason, 3)
	, next_appt_dt_tm		= format(sched_appt->list[d1.seq].next_appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, person_id				= sched_appt->list[d1.seq].person_id
	, location				= uar_get_code_display(sched_appt->list[D1.seq].primary_practice_entity)
 
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
orjoin d2
 
order by
; 003 02/15/21 update the sorting order to only sort by appt_dt_tm then fin
;	patient_name
;	, sched_appt->list[d1.seq].person_id
;	, fin
	 sched_appt->list[d1.seq].appt_dt_tm
	, fin
	, appt_type
;	, appt_type
;	, sched_appt->list[d1.seq].schedule_id
;	, sched_appt->list[d1.seq].action_dt_tm
;	, action
;	, location
 
with nocounter, separator = " ", format, time = 1000
 
END
 
SUBROUTINE OUTPUT_ASTREAM(null)
 
SELECT DISTINCT INTO value(output_var)
	patient_name			= sched_appt->list[d1.seq].patient_name
	, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob,
																  sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
 
	, fin					= sched_appt->list[d1.seq].fin
	, order_phy				= sched_appt->list[d1.seq].order_phy
	, org_name				= sched_appt->list[d1.seq].org_name
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, health_plan			= sched_appt->list[d1.seq].health_plan
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
 
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
; 	, sch_evnt_id			= sched_appt->list[d1.seq].sch_appt_id
;	, order_id				= sched_appt->list[d1.seq].procedures[d2.seq].order_id
	, order_comment			= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_comment, 3)
 
;	, auth_expire_dt		= build2(format(sched_appt->list[d1.seq].auth_expire_dt, "mm/dd/yyyy hh:mm:ss;;Q"),
;								sched_appt->list[d1.seq].procedures[d2.seq].prior_auth_exp)
	, AUTH_EXPIRE_DT		= sched_appt->list[d1.seq].procedures[d2.seq].prior_auth_exp
	, group_practice		= sched_appt->list[d1.seq].order_phy_group
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, next_appt_dt_tm		= sched_appt->list[d1.seq].next_appt_dt_tm
 
	, appt_state			= sched_appt->list[d1.seq].appt_state
 
	, order_dt_tm			= format(sched_appt->list[d1.seq].procedures[d2.seq].order_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, order_mnemonic		= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3)
 
	, schedule_dt_tm		= format(sched_appt->list[d1.seq].schedule_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
;
;	, action_dt_tm			= format(sched_appt->list[d1.seq].action_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
;	, action				= sched_appt->list[d1.seq].action
	, action_prsnl			= sched_appt->list[d1.seq].action_prsnl
	, action_comment		= trim(sched_appt->list[d1.seq].action_comment, 3)
	, reason				= trim(sched_appt->list[d1.seq].reason, 3)
	, star_id				= sched_appt->list[d1.seq].star_id
 
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
orjoin d2
 
order by
; 003 02/15/21 update the sorting order to only sort by appt_dt_tm then fin
;	patient_name
;	, sched_appt->list[d1.seq].person_id
;	, fin
	 sched_appt->list[d1.seq].appt_dt_tm
	, fin
;	, appt_type
;	, sched_appt->list[d1.seq].schedule_id
;	, sched_appt->list[d1.seq].action_dt_tm
;	, action
;	, location
 
WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
END
;call echorecord(sched_appt)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
 

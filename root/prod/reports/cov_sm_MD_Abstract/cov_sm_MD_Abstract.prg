/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/10/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_MD_Abstract.prg
	Object name:		cov_sm_MD_Abstract
	Request #:			4139
 
	Program purpose:	Schedule of all patients where the answer to the
						Accept Format question "MD Abstract?" = "Yes".
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_sm_MD_Abstract:DBA go
create program cov_sm_MD_Abstract:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Department" = 0.0
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
declare confirmed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare checkedin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CHECKEDIN"))
declare oe_schmdabstract_var		= f8 with constant(2581344697.00)
declare oe_other_var				= f8 with constant(9000.00)
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
 
	1	sched_cnt			= i4
	1	list[*]
		2	sch_appt_id		= f8
		2	appt_dt_tm		= dq8
		2	resource		= vc ;c100
		2	location		= vc ;c100
		2	location_type	= vc ;c100
		2	org_name		= vc ;c100
 
		2	schedule_id		= f8
		2	sch_event_id	= f8
		2	appt_type		= vc ;c100
		2	appt_state		= vc ;c100
 
		2	md_abstract		= vc ;c10
		2	updt_dt_tm		= dq8
		2	prsnl_id		= f8
		2	prsnl_name		= vc ;c100
 
		2	person_id		= f8
		2	patient_name	= vc ;c100
		2	ssn				= vc ;c11
		2	ssn_pool_cd		= f8
		2	dob				= dq8
		2	dob_tz			= i4
 
 		2	encntr_id		= f8
 		2	encntr_type		= vc ;c100
 		2	encntr_status	= vc ;c30
		2	fin				= vc ;c10
		2	fin_pool_cd		= f8
		2	mrn				= vc ;c20
		2	mrn_pool_cd		= f8
)
 
 
/**************************************************************/
; set prompt data
set sched_appt->p_facility			= cnvtstring($facility)
set sched_appt->p_dept				= cnvtstring($department)
set sched_appt->p_startdate			= $start_datetime
set sched_appt->p_enddate			= $end_datetime
 
 
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
		and sar.active_ind = 1)
 
 	; scheduled event
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd = sar.sch_state_cd
		and sev.active_ind = 1)
 
 	; MD Abstract
	, (inner join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.oe_field_id = oe_schmdabstract_var ; Sch MDAbstract?
		and sed.oe_field_meaning_id = oe_other_var ; OTHER
		and sed.oe_field_display_value = "Yes"
		and sed.version_dt_tm > sysdate
		and sed.active_ind = 1)
 
	, (inner join PRSNL per on per.person_id = sed.updt_id)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var
		and eam.active_ind = 1)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id)
 
where
	operator(sa.appt_location_cd, op_department_var, $department) ; department
	and sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd = sev.sch_state_cd
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
	sched_appt->list[cnt].resource			= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].location			= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].location_type		= trim(uar_get_code_meaning(l.location_type_cd), 3)
	sched_appt->list[cnt].org_name			= trim(org.org_name, 3)
 
	sched_appt->list[cnt].schedule_id		= sa.schedule_id
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].appt_type			= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].appt_state		= trim(sev.sch_meaning, 3)
 
	sched_appt->list[cnt].md_abstract		= trim(sed.oe_field_display_value, 3)
	sched_appt->list[cnt].updt_dt_tm		= sed.updt_dt_tm
	sched_appt->list[cnt].prsnl_id			= sed.updt_id
	sched_appt->list[cnt].prsnl_name		= per.name_full_formatted
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].ssn				= pas.alias
	sched_appt->list[cnt].ssn_pool_cd		= pas.alias_pool_cd
	sched_appt->list[cnt].dob				= p.birth_dt_tm
	sched_appt->list[cnt].dob_tz			= p.birth_tz
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[cnt].encntr_status		= trim(uar_get_code_display(e.encntr_status_cd), 3)
	sched_appt->list[cnt].fin				= eaf.alias
	sched_appt->list[cnt].fin_pool_cd		= eaf.alias_pool_cd
	sched_appt->list[cnt].mrn				= eam.alias
	sched_appt->list[cnt].mrn_pool_cd		= eam.alias_pool_cd
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, expand = 1, time = 60
 
 
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 

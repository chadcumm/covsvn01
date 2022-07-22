/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		03/18/2019
	Solution:			Revenue Cycle - Acute Care Management
	Source file name:	cov_acm_ImportantMsgMedicare.prg
	Object name:		cov_acm_ImportantMsgMedicare
	Request #:			4357
 
	Program purpose:	List of all Medicare patients that have/have not had
						the Follow-Up Important Message from Medicare documented
						on the Continued Care Note - Case Management form.
 
	Executing from:		CCL
 
 	Special Notes:		Inpatient with length of stay > 2 days.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/23/2019	Todd A. Blanchard		Changed criteria to include check for
 										health plan financial class.
002	08/06/2019	Todd A. Blanchard		Changed logic to eliminate duplicates.
003	11/04/2019	Todd A. Blanchard		Added record structure.
										Changed los calculation to calendar days.
004	11/11/2019	Todd A. Blanchard		Increased timeout value.
005	11/12/2019	Todd A. Blanchard		Revised for performance improvements.
006	01/07/2020	Todd A. Blanchard		Revised calculation of los.
007	01/08/2020	Todd A. Blanchard		Increased timeout value until tuning 
										can be performed.
 
******************************************************************************/
 
drop program cov_acm_ImportantMsgMedicare:DBA go
create program cov_acm_ImportantMsgMedicare:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Start Date of Discharge" = "SYSDATE"
	, "End Date of Discharge" = "SYSDATE"
	, "Discharge Planner" = VALUE(0.0)
 
with OUTDEV, facility, start_datetime, end_datetime, planner
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare medicaremsg_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "DISCHARGEMEDICAREMESSAGEPROVIDED"))
declare inpatient_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 321, "INPATIENT"))
declare discharged_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 261, "DISCHARGED"))
declare los_var					= f8 with constant(2.0)
declare op_facility_var			= c2 with noconstant("")
declare op_planner_var			= c2 with noconstant("")
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
; define operator for $planner
if (substring(1, 1, reflect(parameter(parameter2($planner), 0))) = "L") ; multiple values selected
    set op_planner_var = "IN"
elseif (parameter(parameter2($planner), 1) = 0.0) ; any selected
    set op_planner_var = "!="
else ; single value selected
    set op_planner_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record encntr (
	1	cnt						= i4
	1	list[*]
		2	encntr_id			= f8
		2	reg_dt_tm			= dq8
		2	disch_dt_tm			= dq8
		2	loc_facility		= c40
		2	loc_room			= c40
 
		2	person_id			= f8
		2	patient_name		= c100
		2	fin					= c20
		2	los					= i2
		2	disch_disp			= c100
 
		2	documented			= c1
		2	performed_by		= c100
		2	message_dt_tm		= dq8
 
		2	member_nbr			= c100
		2	plan_name			= c100
		2	plan_type			= c40
)
 
 
/**************************************************************/
; select data
select
	if (parameter(parameter2($planner), 1) != 0.0)
		; discharge planner selected
		where
			operator(e.loc_facility_cd, op_facility_var, $facility)
			and e.encntr_class_cd = inpatient_var
			and e.encntr_status_cd = discharged_var
			and datetimediff(e.disch_dt_tm, e.reg_dt_tm) > los_var ;003
			and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
			and operator(ce.performed_prsnl_id, op_planner_var, $planner)
			;002 ;005
			and (
				(ce.encntr_id = cemin.encntr_id
					and ce.performed_dt_tm = cemin.performed_dt_tm)
				or (ce.encntr_id is null)
			)
	else
		; any selected
		where
			operator(e.loc_facility_cd, op_facility_var, $facility)
			and e.encntr_class_cd = inpatient_var
			and e.encntr_status_cd = discharged_var
			and datetimediff(e.disch_dt_tm, e.reg_dt_tm) > los_var ;003
			and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
			;002 ;005
			and (
				(ce.encntr_id = cemin.encntr_id
					and ce.performed_dt_tm = cemin.performed_dt_tm)
				or (ce.encntr_id is null)
			)
	endif
 
distinct into "NL:" ;002
from
	ENCOUNTER e
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.end_effective_dt_tm > sysdate ;002
		and eaf.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = e.person_id
		and p.end_effective_dt_tm > sysdate ;002
		and p.active_ind = 1) ;002
 
	, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.result_status_cd >= 0.0
		and ce.event_cd = medicaremsg_var)
 
	, (left join CE_DATE_RESULT cedr on cedr.event_id = ce.event_id)
 
	, (left join PRSNL per on per.person_id = ce.performed_prsnl_id)
 
	, (inner join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.beg_effective_dt_tm <= e.disch_dt_tm
		and epr.end_effective_dt_tm >= e.disch_dt_tm
		and epr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and (
			hp.plan_type_cd in (
			select cv.code_value
			from CODE_VALUE cv
			where
				cv.code_set = 367
				and cv.cdf_meaning = "MEDICARE"
				and cv.active_ind = 1
			)
 		;001
		or
			hp.financial_class_cd in (
			select cv.code_value
			from CODE_VALUE cv
			where
				cv.code_set = 354
				and cv.cdf_meaning = "MEDICARE"
				and cv.active_ind = 1
			))
		and hp.beg_effective_dt_tm <= e.disch_dt_tm ;002
		and hp.end_effective_dt_tm >= e.disch_dt_tm ;002
		and hp.active_ind = 1) ;002
 
	;002 ;005
	; first clinical event
	, ((
		select
			ce2.encntr_id
			, performed_dt_tm = min(ce2.performed_dt_tm)
 
		from
			CLINICAL_EVENT ce2
 
		where
			ce2.result_status_cd >= 0.0
			and ce2.event_cd = medicaremsg_var
			and ce2.valid_until_dt_tm > sysdate
 
		group by
			ce2.encntr_id
 
		with sqltype("f8", "dq8")
 
		)cemin)
 
order by
	e.disch_dt_tm
	, p.name_full_formatted
 
 
;003
; populate record structure
head report
	cnt = 0
 
detail
	; determine time period in calendar days
	if ((cnvtdate(e.disch_dt_tm) - cnvtdate(e.reg_dt_tm)) > los_var) ;006
		cnt += 1
 
		call alterlist(encntr->list, cnt)
 
		encntr->cnt							= cnt
		encntr->list[cnt].encntr_id			= e.encntr_id
		encntr->list[cnt].reg_dt_tm			= e.reg_dt_tm
		encntr->list[cnt].disch_dt_tm		= e.disch_dt_tm
		encntr->list[cnt].loc_facility		= uar_get_code_display(e.loc_facility_cd)
		encntr->list[cnt].loc_room			= uar_get_code_display(e.loc_room_cd)
 
		encntr->list[cnt].person_id			= p.person_id
		encntr->list[cnt].patient_name		= p.name_full_formatted
		encntr->list[cnt].fin				= cnvtalias(eaf.alias, eaf.alias_pool_cd)
		encntr->list[cnt].los				= (cnvtdate(e.disch_dt_tm) - cnvtdate(e.reg_dt_tm)) ;003 ;006
		encntr->list[cnt].disch_disp		= uar_get_code_description(e.disch_disposition_cd) ;001
 
		encntr->list[cnt].documented		= evaluate(ce.clinical_event_id, 0.0, "N", "Y")
		encntr->list[cnt].performed_by		= per.name_full_formatted
		encntr->list[cnt].message_dt_tm		= cedr.result_dt_tm
 
		encntr->list[cnt].member_nbr		= epr.member_nbr
		encntr->list[cnt].plan_name			= hp.plan_name
		encntr->list[cnt].plan_type			= uar_get_code_display(hp.plan_type_cd)
	endif
 
WITH nocounter, time = 600 ;004 ;007
 
 
/**************************************************************/
; select data
select distinct into $OUTDEV
	encntr_id			= encntr->list[d1.seq].encntr_id
	, reg_dt_tm			= encntr->list[d1.seq].reg_dt_tm "@SHORTDATETIME"
	, disch_dt_tm		= encntr->list[d1.seq].disch_dt_tm "@SHORTDATETIME"
	, loc_facility		= encntr->list[d1.seq].loc_facility
	, loc_room			= encntr->list[d1.seq].loc_room
 
	, patient_name		= encntr->list[d1.seq].patient_name
	, fin				= encntr->list[d1.seq].fin
	, los				= encntr->list[d1.seq].los
	, disch_disp		= encntr->list[d1.seq].disch_disp
 
	, documented		= encntr->list[d1.seq].documented
	, performed_by		= encntr->list[d1.seq].performed_by
	, message_dt_tm		= encntr->list[d1.seq].message_dt_tm "@SHORTDATETIME"
 
	, member_nbr		= encntr->list[d1.seq].member_nbr
	, plan_name			= encntr->list[d1.seq].plan_name
	, plan_type			= encntr->list[d1.seq].plan_type
 
from
	(dummyt d1 with seq = value(encntr->cnt))
 
plan d1
 
order by
	encntr->list[d1.seq].disch_dt_tm
	, patient_name
 
WITH nocounter, format, separator = " "
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 

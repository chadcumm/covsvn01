/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		07/19/2018
	Solution:			Rehab / Therapies
	Source file name:	cov_reh_ChargeSheet_SIM.prg
	Object name:		cov_reh_ChargeSheet_SIM
	Request #:			2363
 
	Program purpose:	Lists scheduled appointments for selected therapists.
						Used by front desk scheduling staff.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	07/24/2018	Todd A. Blanchard		Adjusted criteria to exclude rooms that
 										are not 'PT', 'OT', 'ST'.
 	08/24/2018	Todd A. Blanchard		Adjusted criteria to include patients
 										scheduled on dates not equal to the
 										resource dates.
 	09/10/2018	Todd A. Blanchard		Adjusted prompt for facility.
 	09/12/2018	Todd A. Blanchard		Adjusted criteria to include patients
 										without encounters.
 	09/19/2018	Todd A. Blanchard		Adjusted prompts to include resource.
 	02/24/2020	Todd A. Blanchard		Reset prompts due to 2018.01.11 code upgrade.
 
******************************************************************************/
 
drop program cov_reh_ChargeSheet_SIM:DBA go
create program cov_reh_ChargeSheet_SIM:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Department" = 0
	, "Resource" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, department, resource, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare get_ApptBookId(data = f8) = f8
declare get_LocationCode(data = f8) = f8
declare get_OrganizationId(data = f8) = f8
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare confirmed_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare org_id_var			= f8 with noconstant(0.0)
declare num					= i4 with noconstant(0)
declare novalue				= vc with constant("Not Available")
declare op_department_var	= c2 with noconstant("")
declare op_resource_var		= c2 with noconstant("")
 
 
; set variables
set org_id_var = get_OrganizationId(get_LocationCode($facility))
 
 
; define operator for $department
if (substring(1, 1, reflect(parameter(parameter2($department), 0))) = "L") ; multiple values selected
    set op_department_var = "IN"
elseif (parameter(parameter2($department), 1) = 0.0) ; any selected
    set op_department_var = "!="
else ; single value selected
    set op_department_var = "="
endif
 
 
; define operator for $resource
if (substring(1, 1, reflect(parameter(parameter2($resource), 0))) = "L") ; multiple values selected
    set op_resource_var = "IN"
elseif (parameter(parameter2($resource), 1) = 0.0) ; any selected
    set op_resource_var = "!="
else ; single value selected
    set op_resource_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_appt (
	1	p_organization		= vc
	1	p_start_datetime	= vc
	1	p_end_datetime		= vc
 
	1	sched_cnt			= i4
	1	list[*]
		2	sch_appt_id		= f8
		2	appt_dt_tm		= dq8
		2	resource		= vc
		2	location		= vc
		2	dept			= vc
		2	room			= vc
 
		2	person_id		= f8
		2	patient_name	= vc
 
 		2	encntr_id		= f8
		2	fin				= vc
 
		2	appt_book_id	= f8
)
 
 
/**************************************************************/
; select prompt data
select into "NL:"
from
	ORGANIZATION org
where
	org.organization_id = org_id_var
 
 
; populate record structure with prompt data
head report
	sched_appt->p_organization = org.org_name
	sched_appt->p_start_datetime = $start_datetime
	sched_appt->p_end_datetime = $end_datetime
 
 
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
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
	, (inner join ORGANIZATION o on o.organization_id = l.organization_id)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on sab.appt_book_id = $facility) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on sab2.appt_book_id = sbl.child_appt_book_id
		and operator(sab2.appt_book_id, op_department_var, $department))	; department
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id
		and cnvtupper(sab3.mnemonic) not like "*DISPLAY*"
		and cnvtupper(sab3.mnemonic) not like "*ADULT*"
		and cnvtupper(sab3.mnemonic) not like "*PEDS*"
		and operator(sab3.appt_book_id, op_resource_var, $resource)) ; resource
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
 	; encounter
	, (left join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var)
 
where
	(
		sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		or sa.beg_effective_dt_tm <= cnvtdatetime($start_datetime) and sa.end_effective_dt_tm >= cnvtdatetime($end_datetime)
	)
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
	sr3.mnemonic
	, sar.beg_dt_tm
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
	sched_appt->list[cnt].appt_dt_tm		= sar.beg_dt_tm
	sched_appt->list[cnt].resource			= uar_get_code_display(sar.resource_cd)
	sched_appt->list[cnt].location			= uar_get_code_display(sa.appt_location_cd)
	sched_appt->list[cnt].dept				= sab2.mnemonic
	sched_appt->list[cnt].room 				= sab3.mnemonic
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].fin				= eaf.alias
 
	sched_appt->list[cnt].appt_book_id		= sab.appt_book_id
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, separator = " ", format
 
 
call echorecord(sched_appt)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
end
go
 

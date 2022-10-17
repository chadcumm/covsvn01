/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/22/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedAuditQuery.prg
	Object name:		cov_sm_SchedAuditQuery
	Request #:			6565, 6750, 8378, 8942
 
	Program purpose:	Lists scheduled appointments for selected facilities.
 
	Executing from:		CCL
 
 	Special Notes:		Exported data is used by external process.
 						Default start date is run date.
 						Default end date is run date plus three days.
 						
 						Output file: sched_audit.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	11/26/2019	Todd A. Blanchard		Added option to export file via scheduled job.
002	08/11/2020	Todd A. Blanchard		Added Fort Sanders West to facility prompt.
003	11/11/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to facility prompt.
 
******************************************************************************/
 
drop program cov_sm_SchedAuditQuery:DBA go
create program cov_sm_SchedAuditQuery:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0            )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, facility, start_datetime, end_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime			= dq8 with noconstant(cnvtdatetime(curdate, 000000)) ;001
declare end_datetime			= dq8 with noconstant(cnvtdatetime(curdate + 3, 235959)) ;001
 
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare rescheduled_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))

declare file_var				= vc with constant("sched_audit.csv") ;001
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var)) ;001
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var)) ;001
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var)) ;001
 
declare output_var				= vc with noconstant("") ;001
 
declare cmd						= vc with noconstant("") ;001
declare len						= i4 with noconstant(0) ;001
declare stat					= i4 with noconstant(0) ;001

declare num						= i4 with noconstant(0)
declare op_facility_var			= c2 with noconstant("")
 
 
; define output value ;001
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
	
	
;001
if (validate(request->batch_selection) != 1)
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
endif
 
 
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
		2	location		= c40
		2	location_type	= c12
		2	org_name		= c100
 
		2	schedule_id		= f8
		2	sch_event_id	= f8
		2	appt_type		= c40
		2	appt_state		= c12
		2	reason_exam		= c100 
 
		2	person_id		= f8
		2	patient_name	= c100
 
 		2	encntr_id		= f8
 		2	encntr_type		= c40
 		2	encntr_status	= c40
		2	fin				= c10
)
 
 
/**************************************************************/
; populate record structure with prompt data
set sched_appt->p_start_datetime	= format(start_datetime, "mm/dd/yyyy;;d") ;001
set sched_appt->p_end_datetime		= format(end_datetime, "mm/dd/yyyy;;d") ;001
 
 
/**************************************************************/
; select scheduled appointment data
select
	if (op_facility_var = "!=")
		where
			sa.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
			and sa.sch_state_cd not in (rescheduled_var)
			and sa.role_meaning = "PATIENT"
			and sa.active_ind = 1
			and e.organization_id in (
				; acute
        		3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00, 3144503.00, 3144504.00, 
        		3234047.00, 3898154.00 ;002 ;003
			)
	else
		where
			sa.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
			and sa.sch_state_cd not in (rescheduled_var)
			and sa.role_meaning = "PATIENT"
			and sa.active_ind = 1
	endif

distinct into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and sar.sch_state_cd not in (rescheduled_var)
		and sar.role_meaning != "PATIENT"
		and sar.active_ind = 1)
 
 	; scheduled event
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd not in (rescheduled_var)
		and sev.active_ind = 1) 
 
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
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
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
 
 
; populate sched_appt record structure
head report
	cnt = 0
 
	call alterlist(sched_appt->list, 100)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_appt->list, cnt + 9)
	endif
 
	sched_appt->sched_cnt					= cnt
	sched_appt->list[cnt].sch_appt_id		= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm		= sa.beg_dt_tm
	sched_appt->list[cnt].location			= uar_get_code_display(sa.appt_location_cd)
	sched_appt->list[cnt].location_type		= uar_get_code_meaning(l.location_type_cd)
	sched_appt->list[cnt].org_name			= org.org_name
 
	sched_appt->list[cnt].schedule_id		= sa.schedule_id
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].appt_type			= uar_get_code_display(sev.appt_type_cd)
	sched_appt->list[cnt].appt_state		= sa.state_meaning
	sched_appt->list[cnt].reason_exam		= sed1.oe_field_display_value
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	sched_appt->list[cnt].encntr_status		= uar_get_code_display(e.encntr_status_cd)
	sched_appt->list[cnt].fin				= eaf.alias
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, time = 60
 
 
/**************************************************************/
; select data 

;001
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
;

into value(output_var)
	patient_name			= sched_appt->list[d1.seq].patient_name
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, schedule_id			= sched_appt->list[d1.seq].schedule_id
	, location				= build2(
								trim(sched_appt->list[d1.seq].location_type, 3), " - ", 
								trim(sched_appt->list[d1.seq].location, 3)
								)
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, appt_state			= sched_appt->list[d1.seq].appt_state	
	, fin					= sched_appt->list[d1.seq].fin
	, encntr_type			= sched_appt->list[d1.seq].encntr_type
	, encntr_status			= sched_appt->list[d1.seq].encntr_status	
	, org_name				= sched_appt->list[d1.seq].org_name
	 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
 
plan d1

where sched_appt->list[d1.seq].schedule_id > 0.0 ;001
 
order by
	patient_name
	, appt_type
	, schedule_id
	, location
	, sched_appt->list[d1.seq].appt_dt_tm
	, reason_exam
	, appt_state
	, fin
	
with nocounter
 
 
/**************************************************************/
; copy file to AStream ;001
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif

 
;call echorecord(sched_appt)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
 

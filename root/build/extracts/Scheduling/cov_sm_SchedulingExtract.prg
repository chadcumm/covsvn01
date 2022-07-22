/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/12/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingExtract.prg
	Object name:		cov_sm_SchedulingExtract
	Request #:			3740
 
	Program purpose:	Lists scheduled appointments for selected organizations.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	12/19/2018	Todd A. Blanchard		Changed $end_datetime prompt default to 15 days.
 	01/29/2019	Todd A. Blanchard		Changed $start_datetime prompt default to 10 days.
 
******************************************************************************/
 
drop program cov_sm_SchedulingExtract:DBA go
create program cov_sm_SchedulingExtract:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date" = "SYSDATE"               ;* Previous 10 Days
	, "End Date" = "SYSDATE"                 ;* Next 15 Days
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, facility, start_datetime, end_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime			= dq8 with noconstant(cnvtlookbehind("10, d", cnvtdatetime(curdate, 000000)))
declare end_datetime			= dq8 with noconstant(cnvtlookahead("15, d", cnvtdatetime(curdate, 235959)))
declare ssn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare personnel_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 213, "PERSONNEL"))
declare novalue					= vc with constant("Not Available")
declare op_facility_var			= c2 with noconstant("")
declare num						= i4 with noconstant(0)
declare crlf					= vc with constant(build(char(13), char(10)))
 
declare file_var				= vc with constant("sched_extract.csv")
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
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
		2	room			= vc ;c100
		2	location		= vc ;c100
		2	location_type	= vc ;c100
		2	org_name		= vc ;c100
 
		2	schedule_id		= f8
		2	sch_event_id	= f8
		2	appt_type		= vc ;c100
		2	appt_state		= vc ;c30
		2	reason_exam		= vc ;c100
		2	insurance		= vc ;c100
		2	prsnl_name		= vc ;c100
 
		2	person_id		= f8
		2	patient_name	= vc ;c100
		2	ssn				= vc ;c11
		2	dob				= dq8
		2	dob_tz			= i4
 
 		2	encntr_id		= f8
 		2	encntr_type		= vc ;c100
 		2	encntr_status	= vc ;c30
		2	fin				= vc ;c10
		2	mrn				= vc ;c20
)
 
 
/**************************************************************/
; populate record structure with prompt data
if (validate(request->batch_selection) = 1)
	set sched_appt->p_start_datetime = format(start_datetime, "mm/dd/yyyy hh:mm;;q")
	set sched_appt->p_end_datetime = format(end_datetime, "mm/dd/yyyy hh:mm;;q")
else
	set sched_appt->p_start_datetime = format(cnvtdatetime($start_datetime), "mm/dd/yyyy hh:mm;;q")
	set sched_appt->p_end_datetime = format(cnvtdatetime($end_datetime), "mm/dd/yyyy hh:mm;;q")
 
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
endif
 
 
/**************************************************************/
; select scheduled appointment data
select into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.active_ind = 1)
 
	, (left join SCH_RESOURCE sr on sr.resource_cd = sar.resource_cd
		and sr.active_ind = 1)
 
	, (left join PERSON_NAME pn on pn.person_id = sr.person_id
		and pn.name_type_cd = personnel_var
		and pn.active_ind = 1)
 
 	; scheduled event
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd in (
			select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
		)
		and sev.sch_state_cd = sar.sch_state_cd
		and sev.active_ind = 1)
 
 	; reason for exam
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
 	; insurance
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_id in (
			select oef.oe_field_id
			from
				ORDER_ENTRY_FIELDS oef
				, OE_FIELD_MEANING ofm
			where
				cnvtupper(oef.description) = "COMMENT TEXT 1"
				and ofm.oe_field_meaning_id = oef.oe_field_meaning_id
				and ofm.oe_field_meaning in ("COMMENTTEXT1", "OTHER")
		)
		and sed2.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on operator(e.organization_id, op_facility_var, $facility) ; facility
		and e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
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
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
 
where
	sa.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
	and sa.role_meaning = "PATIENT"
;	and sa.sch_state_cd in (
;		select cv.code_value from CODE_VALUE cv where cv.code_set = 14233 and cv.active_ind = 1
;	)
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
	sched_appt->list[cnt].room				= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].location			= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].location_type		= trim(uar_get_code_meaning(l.location_type_cd), 3)
	sched_appt->list[cnt].org_name			= trim(org.org_name, 3)
 
	sched_appt->list[cnt].schedule_id		= sa.schedule_id
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
	sched_appt->list[cnt].appt_type			= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].appt_state		= trim(sev.sch_meaning, 3)
	sched_appt->list[cnt].reason_exam		= trim(replace(sed1.oe_field_display_value, crlf, " ", 4), 3)
	sched_appt->list[cnt].insurance			= trim(replace(sed2.oe_field_display_value, crlf, " ", 4), 3)
	sched_appt->list[cnt].prsnl_name		= pn.name_full
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= p.name_full_formatted
	sched_appt->list[cnt].ssn				= pas.alias
	sched_appt->list[cnt].dob				= p.birth_dt_tm
	sched_appt->list[cnt].dob_tz			= p.birth_tz
 
 	sched_appt->list[cnt].encntr_id			= e.encntr_id
	sched_appt->list[cnt].encntr_type		= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[cnt].encntr_status		= trim(uar_get_code_display(e.encntr_status_cd), 3)
	sched_appt->list[cnt].fin				= eaf.alias
	sched_appt->list[cnt].mrn				= eam.alias
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format, time = 60
endif
 
into value(output_var)
	person_id				= sched_appt->list[d1.seq].person_id
	, patient_name			= sched_appt->list[d1.seq].patient_name
	, dob					= format(cnvtdatetimeutc(datetimezone(
								sched_appt->list[d1.seq].dob,
								sched_appt->list[d1.seq].dob_tz),
								1), "mm/dd/yyyy;;d")
	, ssn					= sched_appt->list[d1.seq].ssn
	, mrn					= sched_appt->list[d1.seq].mrn
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, insurance				= sched_appt->list[d1.seq].insurance
	, prsnl_name			= sched_appt->list[d1.seq].prsnl_name
	, schedule_id			= sched_appt->list[d1.seq].schedule_id
	, location				= sched_appt->list[d1.seq].location
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm:ss;;Q")
	, fin					= sched_appt->list[d1.seq].fin
	, org_name				= sched_appt->list[d1.seq].org_name
	, encntr_type			= sched_appt->list[d1.seq].encntr_type
	, appt_state			= sched_appt->list[d1.seq].appt_state
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
 
plan d1
 
order by
	patient_name
	, sched_appt->list[d1.seq].appt_dt_tm
	, appt_type
	, location
 
 
; copy file to AStream
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
 

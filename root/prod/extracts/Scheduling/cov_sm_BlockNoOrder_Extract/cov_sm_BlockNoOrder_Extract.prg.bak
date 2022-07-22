/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		02/03/2021
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_BlockNoOrder_Extract.prg
	Object name:		cov_sm_BlockNoOrder_Extract
	Request #:			9351, 11683, 13126
 
	Program purpose:	Called by ops job(s).
 
	Executing from:		CCL
 
 	Special Notes:		Derived from DA2 report Cov - Block No Order Report. 						
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	12/06/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West to prompt.
002	06/23/2022	Todd A. Blanchard		Adjusted timeframe to today + 9.
 
******************************************************************************/
 
drop program cov_sm_BlockNoOrder_Extract:DBA go
create program cov_sm_BlockNoOrder_Extract:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0           )
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
 
declare start_datetime			= dq8 with noconstant(cnvtdatetime(curdate, 000000))
declare end_datetime			= dq8 with noconstant(cnvtlookahead("9, d", cnvtdatetime(curdate, 235959))) ;002
 
declare ssn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "MRN"))
declare home_phone_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare blocknoorder_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14230, "BLOCKNOORDER"))
declare confirmed_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare op_facility_var			= c2 with noconstant("")
 
declare file_var				= vc with constant("block_no_order.csv")

declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))

declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
											"_cust/to_client_site/RevenueCycle/Scheduling/Centralized/", file_var))
															 
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
	
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_appt (
	1	sched_cnt					= i4
	1	list[*]
		2	sch_appt_id				= f8
		2	appt_dt_tm				= dq8
		2	appt_type				= c40
		2	resource				= c40
		2	resource_seq			= i4
		2	location				= c40
		2	loc_seq					= i4
		2	dept					= c40
		2	dept_seq				= i4
		2	loc_facility			= c40
		2	org_name				= c100
 
		2	reason_exam				= c100
		2	instructions			= c100
		2	order_phy				= c100
 
		2	sch_event_id			= f8
 
		2	person_id				= f8
		2	patient_name			= c100
		2	ssn						= c11
		2	dob						= dq8
		2	home_phone				= c20
		2	mrn						= c20
 
		2	appt_book_id			= f8
)
 
 
/**************************************************************/
; set date range
if (validate(request->batch_selection) != 1)
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
endif
 
 
/**************************************************************/
; select scheduled appointment data
select into "NL:"
	ssn = cnvtalias(pm_get_alias("SSN", 0, p.person_id, 0, sysdate), pas.alias_pool_cd)
	, mrn = cnvtalias(pm_get_alias("MRN", 0, p.person_id, 0, sysdate), pam.alias_pool_cd)
	
from
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.schedule_id = sa.schedule_id
		and sar.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd = confirmed_var
		and sar.active_ind = 1)
 
	; bookshelf items
	, (inner join SCH_APPT_BOOK sab on operator(sab.appt_book_id, op_facility_var, $facility)) ; facility
	, (inner join SCH_BOOK_LIST sbl on sbl.appt_book_id = sab.appt_book_id)
 
	, (inner join SCH_APPT_BOOK sab2 on sab2.appt_book_id = sbl.child_appt_book_id
		; filter out display-type books and joint centers
		and sab2.appt_book_id not in (
			1639442.00		; MMC Joint Center
			, 1644773.00	; PWMC Joint Center
			, 1674964.00	; MHHS/ MRDC Rad
			, 1675706.00	; MRDC Rad Display
			, 1675708.00	; MHHS Rad Display
 
		))
	, (inner join SCH_BOOK_LIST sbl2 on sbl2.appt_book_id = sab2.appt_book_id)
 
 	; level-2 link between bookshelf and scheduled appointment resource
	, (left join SCH_RESOURCE sr2 on sr2.resource_cd = sbl2.resource_cd)
 
	, (left join SCH_APPT_BOOK sab3 on sab3.appt_book_id = sbl2.child_appt_book_id
		; filter out display-type books and joint centers
		and sab3.appt_book_id not in (
			1639442.00		; MMC Joint Center
			, 1644773.00	; PWMC Joint Center
			, 1674964.00	; MHHS/ MRDC Rad
			, 1675706.00	; MRDC Rad Display
			, 1675708.00	; MHHS Rad Display
		))
	, (left join SCH_BOOK_LIST sbl3 on sbl3.appt_book_id = sab3.appt_book_id)
 
 	; level-3 link between bookshelf and scheduled appointment resource
	, (left join SCH_RESOURCE sr3 on sr3.resource_cd = sbl3.resource_cd)
 
 	; scheduled event
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.appt_type_cd = blocknoorder_var
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
 
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning = "SCHORDPHYS"
		and (sed3.version_dt_tm > sysdate or sed3.version_dt_tm is null)
		and sed3.end_effective_dt_tm > sysdate
		and sed3.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id
		and p.active_ind = 1)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.active_ind = 1)
 
	, (left join PERSON_ALIAS pam on pam.person_id = p.person_id
		and pam.person_alias_type_cd = mrn_var
		and pam.active_ind = 1)
 
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var
		and ph.phone_type_seq = 1
		and ph.active_ind = 1)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id)
		
where
	sa.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
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
 
head sa.sch_appt_id
	cnt = cnt + 1
 
	call alterlist(sched_appt->list, cnt)
 
	sched_appt->sched_cnt					= cnt
	sched_appt->list[cnt].sch_appt_id		= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm		= sa.beg_dt_tm
	sched_appt->list[cnt].appt_type			= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[cnt].resource			= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].resource_seq		= sbl3.seq_nbr
	sched_appt->list[cnt].location			= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].loc_seq			= sbl2.seq_nbr
	sched_appt->list[cnt].dept				= trim(sab2.mnemonic, 3)
	sched_appt->list[cnt].dept_seq			= sbl.seq_nbr
	sched_appt->list[cnt].loc_facility		= trim(uar_get_code_display(l.location_cd), 3)
	sched_appt->list[cnt].org_name			= trim(org.org_name, 3)
 
	sched_appt->list[cnt].reason_exam		= trim(sed1.oe_field_display_value, 3)
	sched_appt->list[cnt].instructions		= trim(sed2.oe_field_display_value, 3)
	sched_appt->list[cnt].order_phy			= trim(sed3.oe_field_display_value, 3)
 
	sched_appt->list[cnt].sch_event_id		= sa.sch_event_id
 
	sched_appt->list[cnt].person_id			= p.person_id
	sched_appt->list[cnt].patient_name		= trim(p.name_full_formatted, 3)
	sched_appt->list[cnt].ssn				= ssn
	sched_appt->list[cnt].mrn				= mrn
	sched_appt->list[cnt].dob				= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
	sched_appt->list[cnt].home_phone		= trim(ph.phone_num, 3)
 
	sched_appt->list[cnt].appt_book_id		= sab.appt_book_id
 
WITH nocounter
 
call echorecord(sched_appt)

 
/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, expand = 1, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, expand = 1, separator = " ", format, time = 600
endif

into value(output_var)
	appt_dt_tm		= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, appt_type			= sched_appt->list[d1.seq].appt_type
	, resource			= sched_appt->list[d1.seq].resource
	, location			= sched_appt->list[d1.seq].location
	, dept				= sched_appt->list[d1.seq].dept
	, facility			= sched_appt->list[d1.seq].loc_facility
	, org_name			= sched_appt->list[d1.seq].org_name
	, reason_exam		= sched_appt->list[d1.seq].reason_exam
	, instructions		= sched_appt->list[d1.seq].instructions
	, order_phy			= sched_appt->list[d1.seq].order_phy
	, patient_name		= sched_appt->list[d1.seq].patient_name
	, ssn				= sched_appt->list[d1.seq].ssn
	, mrn				= sched_appt->list[d1.seq].mrn
	, dob				= format(sched_appt->list[d1.seq].dob, "mm/dd/yyyy;;d")
	, home_phone		= sched_appt->list[d1.seq].home_phone
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
 
plan d1

with nocounter

 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
;%i cust_script:cov_CommonLibrary.inc
 
end
go
 


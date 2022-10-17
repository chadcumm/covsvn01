/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/12/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingExtract.prg
	Object name:		cov_sm_SchedulingExtract
	Request #:			3740, 6711, 7783, 8541, 8942, 9327, 10339, 12349, 13343
 
	Program purpose:	Lists scheduled appointments for selected organizations.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	12/19/2018	Todd A. Blanchard		Changed $end_datetime prompt default to 15 days.
002	01/29/2019	Todd A. Blanchard		Changed $start_datetime prompt default to 10 days.
003	03/11/2019	Todd A. Blanchard		Increased timeout values.
004	12/17/2019	Todd A. Blanchard		Added ordering physician and STAR ID to query.
										Adjusted record structure lengths.
										Adjusted CCL for performance.
005	01/16/2020	Todd A. Blanchard		Increased timeout values.
006	06/03/2020	Todd A. Blanchard		Added order data and additional appointment data.
										Restructured CCL to accommodate new data.
										Changed default date range values.
007	06/04/2020	Todd A. Blanchard		Changed default date range values.
008	07/20/2020	Todd A. Blanchard		Adjusted criteria for last action data.
009	09/29/2020	Todd A. Blanchard		Added FSR West Diagnostic Center to facility prompt.
010	02/02/2021	Todd A. Blanchard		Increased timeout values.
										Changed $facility prompt values.
										Adusted criteria for use of $facility prompt.
										Adjusted joins for sch_event_id values.
										Adjusted query for procedures.
011	05/12/2021	Todd A. Blanchard		Added CMG and scanned order indicators.
012	05/27/2021	Todd A. Blanchard		Added aliases for subquery tables.
013	11/10/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West.
014	01/18/2022	Todd A. Blanchard		Added person language and estimated arrival date.
015	01/27/2022	Todd A. Blanchard		Added person gender.
016	03/08/2022	Todd A. Blanchard		Changed practice site display to org name.
017	08/03/2022	Todd A. Blanchard		Changed default date range values.
 
******************************************************************************/
 
drop program cov_sm_SchedulingExtract_TEST:DBA go
create program cov_sm_SchedulingExtract_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0)
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
 
declare start_datetime			= dq8 with noconstant(cnvtlookbehind("35, d", cnvtdatetime(curdate, 000000))) ;002 ;006; 017
declare end_datetime			= dq8 with noconstant(cnvtlookahead("70, d", cnvtdatetime(curdate, 235959))) ;001 ;006 ;007

declare ssn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare cmrn_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "COMMUNITYMEDICALRECORDNUMBER")) ;014
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare personnel_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 213, "PERSONNEL"))
declare order_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER")) ;004
declare contrib_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 13016, "ORDCAT")) ;006
declare bill_item_type_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13019, "BILLCODE")) ;006
declare cpt_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "CPT")) ;006
declare cpt4_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 400, "CPT4")) ;006
declare attach_type_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER")) ;004
declare stardoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER")) ;004 ;006
declare covenant_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT")) ;006
declare physician_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER")) ;011
declare outside_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER")) ;011

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
	1	p_start_datetime		= vc
	1	p_end_datetime			= vc
 
	1	sched_cnt				= i4
	1	list[*]
		2	sch_appt_id			= f8
		2	appt_dt_tm			= dq8
		2	resource			= c40	;004 ;006
		2	location			= c40	;004
		2	location_type		= c12	;004
		2	org_name			= c100	;004
		2	facility			= c1	;006
 
		2	schedule_id			= f8
		2	sch_event_id		= f8
		2	appt_type			= c40	;004
		2	sch_state			= c12	;006
		2	reason_exam			= c100	;004
		2	order_phy			= c100	;004
		2	order_phy_id		= c20	;004
		2	ord_phys_group		= c100	;006
		2	practice_site_id	= f8	;011
		2	is_cmg				= i2	;011
;		2	prsnl_name			= c100	;004
		
		2	sch_action_dt_tm	= dq8	;006
		2	sch_action_type		= c40	;006
		2	sch_action_prsnl	= c100	;006
;		2	sch_tat_days		= i4	;006
		
		2	pre_reg_dt_tm			= dq8	;006
		2	est_arrive_dt_tm		= dq8	;014
		2	entry_state				= c40	;006
		2	earliest_dt_tm			= dq8	;006
;		2	appt_tat_days			= i4	;006
 
		2 proc_cnt						= i4	;006
		2 procedures[*]
			3	order_id				= f8	;006
			3	order_mnemonic			= c100	;006
			3	order_dt_tm				= dq8	;006
			3	order_entered_by		= c100	;006
			3	order_action_dt_tm		= dq8	;006
			3	order_action_type		= c40	;006
			3	order_comment			= c255	;006
			3	request_start_dt_tm		= dq8	;006
			3	exam_start_dt_tm		= dq8	;006
			3	prior_auth				= c50	;006
			3	auth_entered_by			= c100	;006
			3	auth_dt_tm				= dq8	;006
;			3	auth_tat_days			= i4	;006
			3	cpt_cd					= c10	;006
			3	cpt_desc				= c100	;006
 
		2	person_id				= f8
		2	patient_name			= c100	;004
		2	ssn						= c11	;004
		2	dob						= dq8
		2	dob_tz					= i4
		2	gender					= c12	;015
		2	language				= c40	;014
 
 		2	encntr_id				= f8
 		2	encntr_type				= c40	;004
 		2	encntr_status			= c40	;004
		2	fin						= c20	;004
		2	mrn						= c20	;004
		2	cmrn					= c20	;014
		2	icd10					= c50	;006
		2	icd10_desc				= c255	;006
		2	health_plan				= c100	;006
		2	auth_nbr				= c50	;006
		2	auth_nbr_entered_by		= c100	;006
		2	has_scanned_order		= i2	;011
		2	comment					= c255	;006
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
; select scheduled appointment data - primary data set ;006
select into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.schedule_id = sa.schedule_id ;006
		and sar.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd > 0.0
		and sar.primary_role_ind = 1
		and sar.active_ind = 1)
 
	; first confirm
	, (left join SCH_EVENT_ACTION seva on seva.sch_event_id = sa.sch_event_id
		and seva.schedule_id = sa.schedule_id ;006
		and seva.action_meaning = "CONFIRM"
		and seva.action_dt_tm = (
			select min(seva12.action_dt_tm)
			from SCH_EVENT_ACTION seva12 ;012
			where
				seva12.sch_event_id = seva.sch_event_id
				and seva12.action_meaning = "CONFIRM"
				and seva12.active_ind = 1
			group by
				seva12.sch_event_id
		)
		and seva.active_ind = 1
		)
 
	, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id
		;and per_seva.person_id >= 0.0
		)
 
	; last confirm
	, (left join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sa.sch_event_id
		and seva2.schedule_id = sa.schedule_id ;006
		and seva2.action_meaning = "CONFIRM"
		and seva2.action_dt_tm = (
			select max(seva22.action_dt_tm)
			from SCH_EVENT_ACTION seva22 ;012
			where
				seva22.sch_event_id = seva2.sch_event_id
				and seva22.action_meaning = "CONFIRM"
				and seva22.active_ind = 1
			group by
				seva22.sch_event_id
		)
		and seva2.active_ind = 1
		)
 
	, (left join PRSNL per_seva2 on per_seva2.person_id = seva2.action_prsnl_id
		;and per_seva2.person_id >= 0.0
		)
		
	; last action
	, (left join SCH_EVENT_ACTION seva3 on seva3.sch_event_id = sa.sch_event_id
		and seva3.schedule_id = sa.schedule_id
		and seva3.action_meaning not in ("LINK", "SHUFFLE", "UNDO", "VIEW")
		and seva3.action_dt_tm = (
			select max(seva32.action_dt_tm)
			from SCH_EVENT_ACTION seva32 ;012
			where
				seva32.sch_event_id = seva3.sch_event_id
				and seva32.schedule_id = seva3.schedule_id
				and seva32.action_meaning not in ("LINK", "SHUFFLE", "UNDO", "VIEW")
				and seva32.active_ind = 1
			group by
				seva32.sch_event_id
				, seva32.schedule_id
		)
		;008
;		and seva3.action_dt_tm between 
;			cnvtdatetime(datetimefind(cnvtlookbehind("1,D"), "D", "B", "B")) and
;			cnvtdatetime(datetimefind(cnvtlookbehind("1,D"), "D", "E", "E"))
		and seva3.active_ind = 1
		)
 
	, (left join PRSNL per_seva3 on per_seva3.person_id = seva3.action_prsnl_id
		;and per_seva3.person_id >= 0.0
		)
 
 	; encounter
;	, (inner join ENCOUNTER e on e.organization_id in ($facility) ; facility ;010
	, (inner join ENCOUNTER e on operator(e.organization_id, op_facility_var, $facility) ; facility ;010
		and e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
		and e.active_ind = 1)
 
where
	sa.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd > 0.0
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
 
	sched_appt->sched_cnt							= cnt
	sched_appt->list[cnt].sch_appt_id				= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm				= sa.beg_dt_tm
	sched_appt->list[cnt].resource					= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].location					= trim(uar_get_code_display(sa.appt_location_cd), 3)
	
	sched_appt->list[cnt].schedule_id				= sa.schedule_id
	sched_appt->list[cnt].sch_event_id				= sa.sch_event_id
	sched_appt->list[cnt].sch_state					= trim(sa.state_meaning, 3)
;	sched_appt->list[cnt].prsnl_name				= pn.name_full
	
	if (seva.sch_action_id > 0.0 or seva2.sch_action_id > 0.0)
		if (seva.action_dt_tm = seva2.action_dt_tm)
			; first confirm
			sched_appt->list[cnt].sch_action_dt_tm			= seva.action_dt_tm		
			sched_appt->list[cnt].sch_action_type			= trim(uar_get_code_display(seva.sch_action_cd), 3)				
			sched_appt->list[cnt].sch_action_prsnl			= per_seva.name_full_formatted			
;			sched_appt->list[cnt].sch_tat_days				= datetimediff(seva.action_dt_tm, od.oe_field_dt_tm_value)
		else
			; last confirm
			sched_appt->list[cnt].sch_action_dt_tm			= seva2.action_dt_tm			
			sched_appt->list[cnt].sch_action_type			= trim(uar_get_code_display(seva2.sch_action_cd), 3)				
			sched_appt->list[cnt].sch_action_prsnl			= per_seva2.name_full_formatted			
;			sched_appt->list[cnt].sch_tat_days				= datetimediff(seva2.action_dt_tm, od.oe_field_dt_tm_value)
		endif
	else
		; get last action
		sched_appt->list[cnt].sch_action_dt_tm				= seva3.action_dt_tm
		sched_appt->list[cnt].sch_action_type				= trim(uar_get_code_display(seva3.sch_action_cd), 3)
		sched_appt->list[cnt].sch_action_prsnl				= per_seva3.name_full_formatted
;		sched_appt->list[cnt].sch_tat_days					= datetimediff(seva3.action_dt_tm, od.oe_field_dt_tm_value)
	endif
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, time = 1800 ;010
 
 
/**************************************************************/
; select scheduled appointment data - secondary data set ;006
select into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.schedule_id = sa.schedule_id
		and sar.beg_dt_tm not between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd > 0.0
		and sar.primary_role_ind = 1
		and sar.active_ind = 1)
		
	; last action from previous day
	, (inner join SCH_EVENT_ACTION seva on seva.sch_event_id = sa.sch_event_id
		and seva.schedule_id = sa.schedule_id
		and seva.action_meaning not in ("LINK", "SHUFFLE", "UNDO", "VIEW")
		and seva.action_dt_tm = (
			select max(seva12.action_dt_tm)
			from SCH_EVENT_ACTION seva12 ;012
			where
				seva12.sch_event_id = seva.sch_event_id
				and seva12.schedule_id = seva.schedule_id
				and seva12.action_meaning not in ("LINK", "SHUFFLE", "UNDO", "VIEW")
				and seva12.active_ind = 1
			group by
				seva12.sch_event_id
				, seva12.schedule_id
		)
		and seva.action_dt_tm between 
			cnvtdatetime(datetimefind(cnvtlookbehind("1,D"), "D", "B", "B")) and
			cnvtdatetime(datetimefind(cnvtlookbehind("1,D"), "D", "E", "E"))
		and seva.active_ind = 1
		)
 
	, (inner join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id
		;and per_seva.person_id >= 0.0
		)
 
 	; encounter
;	, (inner join ENCOUNTER e on e.organization_id in ($facility) ; facility ;010
	, (inner join ENCOUNTER e on operator(e.organization_id, op_facility_var, $facility) ; facility ;010
		and e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
		and e.active_ind = 1)
 
where
	sa.beg_dt_tm not between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd > 0.0
	and sa.active_ind = 1
 
order by
	sa.sch_appt_id
 
 
; populate sched_appt record structure
head report
	cnt = sched_appt->sched_cnt
 
head sa.sch_appt_id
	cnt = cnt + 1

	call alterlist(sched_appt->list, cnt)
 
	sched_appt->sched_cnt							= cnt
	sched_appt->list[cnt].sch_appt_id				= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm				= sa.beg_dt_tm
	sched_appt->list[cnt].resource					= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].location					= trim(uar_get_code_display(sa.appt_location_cd), 3)
	
	sched_appt->list[cnt].schedule_id				= sa.schedule_id
	sched_appt->list[cnt].sch_event_id				= sa.sch_event_id
	sched_appt->list[cnt].sch_state					= trim(sa.state_meaning, 3)
;	sched_appt->list[cnt].prsnl_name				= pn.name_full
	
	sched_appt->list[cnt].sch_action_dt_tm			= seva.action_dt_tm	
	sched_appt->list[cnt].sch_action_type			= trim(uar_get_code_display(seva.sch_action_cd), 3)		
	sched_appt->list[cnt].sch_action_prsnl			= per_seva.name_full_formatted	
;	sched_appt->list[cnt].sch_tat_days				= datetimediff(seva.action_dt_tm, od.oe_field_dt_tm_value)
 
WITH nocounter, time = 1800 ;010


/**************************************************************/
; select additional scheduled appointment data ;006
select into "NL:"
from
 	; scheduled event
	SCH_APPT sa	
	
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd > 0.0
		and sev.active_ind = 1)
 
 	; reason for exam
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
 	;004
 	; ordering physician
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_meaning = "SCHORDPHYS"
		and sed2.active_ind = 1)
 
	;006
	, (left join PRSNL per2 on per2.person_id = sed2.oe_field_value
		and per2.active_ind = 1)
 
	, (left join PRSNL_ALIAS pera2 on pera2.person_id = per2.person_id
		and pera2.alias_pool_cd = stardoc_var
		and pera2.active_ind = 1)
 
	; first practice site ;006
	, (left join PRSNL_RELTN pr on pr.person_id = per2.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1
		and pr.parent_entity_id = (
			select min(pr2.parent_entity_id)
			from PRSNL_RELTN pr2
			where
				pr2.person_id = pr.person_id
				and pr2.parent_entity_name = pr.parent_entity_name
				and pr2.active_ind = pr.active_ind
			group by
				pr2.person_id
		))
 
 	;006
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
	
	;016
	, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id)
	
	;006
	; comments
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning in ("SPECINX")
		and sed3.active_ind = 1)
	
 	;006
 	, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.person_alias_id > 0.0 ;004
		and pas.active_ind = 1)
 
 	;014
	, (left join PERSON_ALIAS pac on pac.person_id = p.person_id
		and pac.person_alias_type_cd = cmrn_var
		and pac.person_alias_id > 0.0
		and pac.active_ind = 1)
 
 	; encounter
;	, (inner join ENCOUNTER e on e.organization_id in ($facility) ; facility ;010
	, (inner join ENCOUNTER e on operator(e.organization_id, op_facility_var, $facility) ; facility ;010
		and e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var
		and eam.active_ind = 1)
		
	;006
	; diagnosis
	, (left join DIAGNOSIS d on d.encntr_id = e.encntr_id
		and d.active_ind = 1)
	
	;006
	, (left join NOMENCLATURE n on n.nomenclature_id = d.nomenclature_id
		and n.source_vocabulary_cd in (
			select cv.code_value
			from CODE_VALUE cv
			where
				cv.code_set = 400
				and cv.display_key in ("ICD10*")
				and cv.active_ind = 1
		))
 
 	;006
 	; health plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 	
 	;006
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id)
 
 	;006
	, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
		and epar.active_ind = 1)
 
 	;006
	, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
		and au.active_ind = 1)
 
 	;006
	, (left join PRSNL per_au on per_au.person_id = au.updt_id)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
	
	;006
	, (inner join LOCATION l2 on l2.organization_id = org.organization_id)
 
 	;006
	, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = l2.location_cd
		and cvo.code_set = 220
		and cvo.alias_type_meaning = "FACILITY"
		and cvo.contributor_source_cd = covenant_var)

where
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sev.sch_event_id, sched_appt->list[num].sch_event_id) ;010

order by
	sa.sch_appt_id
	, sev.sch_event_id ;010
 
 
; populate sched_appt record structure
head sa.sch_appt_id
	idx = 0
	numx = 0
	
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sev.sch_event_id, sched_appt->list[numx].sch_event_id) ;010
	
detail 
	sched_appt->list[idx].location_type				= trim(uar_get_code_meaning(l.location_type_cd), 3)
	sched_appt->list[idx].org_name					= trim(org.org_name, 3)
	sched_appt->list[idx].facility					= trim(cvo.alias, 3)
	sched_appt->list[idx].appt_type					= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[idx].reason_exam				= trim(replace(sed1.oe_field_display_value, crlf, " ", 4), 3)
	
	;004
	sched_appt->list[idx].order_phy					= trim(sed2.oe_field_display_value, 3) ;006
	sched_appt->list[idx].order_phy_id				= trim(pera2.alias, 3) ;006
	sched_appt->list[idx].ord_phys_group			= trim(org_ps.org_name, 3) ;006 ;016
	sched_appt->list[idx].practice_site_id			= ps.practice_site_id ;011
												  
	sched_appt->list[idx].pre_reg_dt_tm				= e.pre_reg_dt_tm ;006
	sched_appt->list[idx].est_arrive_dt_tm			= e.est_arrive_dt_tm ;014
	sched_appt->list[idx].entry_state				= trim(uar_get_code_display(sen.entry_state_cd), 3) ;006
	
	;006
	sched_appt->list[idx].earliest_dt_tm			= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
														and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))
															sen.earliest_dt_tm
													  endif
	
	;006
;	sched_appt->list[idx].appt_tat_days				= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
;														and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))														
;															datetimediff(sa.beg_dt_tm, sen.earliest_dt_tm)
;													  endif
	
	sched_appt->list[idx].person_id					= p.person_id
	sched_appt->list[idx].patient_name				= p.name_full_formatted
	sched_appt->list[idx].ssn						= trim(pas.alias, 3)
	sched_appt->list[idx].dob						= p.birth_dt_tm
	sched_appt->list[idx].dob_tz					= p.birth_tz
	sched_appt->list[idx].gender					= trim(uar_get_code_meaning(p.sex_cd), 3) ;015
	sched_appt->list[idx].language					= trim(uar_get_code_display(p.language_cd), 3) ;014
	
	sched_appt->list[idx].encntr_id					= e.encntr_id
	sched_appt->list[idx].encntr_type				= trim(uar_get_code_display(e.encntr_type_cd), 3)
	sched_appt->list[idx].encntr_status				= trim(uar_get_code_display(e.encntr_status_cd), 3)
	sched_appt->list[idx].fin						= trim(eaf.alias, 3)
	sched_appt->list[idx].mrn						= trim(cnvtalias(eam.alias, eam.alias_pool_cd), 3)
	sched_appt->list[idx].cmrn						= trim(pac.alias, 3) ;014
	
	sched_appt->list[idx].icd10						= trim(n.source_identifier, 3) ;006
	sched_appt->list[idx].icd10_desc				= trim(n.source_string, 3) ;006
	
	sched_appt->list[idx].health_plan				= trim(hp.plan_name, 3) ;006
	sched_appt->list[idx].auth_nbr					= trim(au.auth_nbr, 3) ;006

	;006
	sched_appt->list[idx].auth_nbr_entered_by		= if (size(trim(au.auth_nbr, 3)) > 0)
														per_au.name_full_formatted
													  endif
													  
	;006
 	comment = fillstring(255, " ") 	
	comment	= trim(sed3.oe_field_display_value, 3)
	comment = replace(comment, char(13), " ", 4)
	comment = replace(comment, char(10), " ", 4)
	comment = replace(comment, char(0), " ", 4)
	
	;006
	sched_appt->list[idx].comment					= trim(comment, 3)
 
WITH nocounter, expand = 1, time = 1800 ;003 ;005 ;010
 
 
/**************************************************************/
; select scheduled procedures data ;006
select into "NL:"
from	
	SCH_APPT sa
	
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED")
		and sea.active_ind = 1)
	
;	, (left join SCH_ENTRY sen on sen.sch_event_id = sea.sch_event_id)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "SCHEDAUTHNBR"
		and od.action_sequence = (
			select max(od12.action_sequence)
			from ORDER_DETAIL od12 ;012
			where 
				od12.order_id = od.order_id
				and od12.oe_field_meaning = "SCHEDAUTHNBR"
			group by
				od12.order_id
		))
 
	, (left join PRSNL per_od on per_od.person_id = od.updt_id)
 
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_meaning = "SURGEON1"
		and od2.action_sequence = (
			select max(od22.action_sequence)
			from ORDER_DETAIL od22 ;012
			where 
				od22.order_id = od2.order_id
				and od22.oe_field_meaning = "SURGEON1"
			group by
				od22.order_id
		))
 
	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_meaning = "REQSTARTDTTM"
		and od3.action_sequence = (
			select max(od32.action_sequence)
			from ORDER_DETAIL od32 ;012
			where 
				od32.order_id = od3.order_id
				and od32.oe_field_meaning = "REQSTARTDTTM"
			group by
				od32.order_id
		))
 
 	;006
	, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
		and od4.oe_field_meaning = "SPECINX"
		and od4.action_sequence = (
			select max(od42.action_sequence)
			from ORDER_DETAIL od42 ;012
			where 
				od42.order_id = od4.order_id
				and od42.oe_field_meaning = "SPECINX"
			group by
				od42.order_id
		))
				
	, (left join OMF_RADMGMT_ORDER_ST oros on oros.order_id = o.order_id)
 
	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
		
	, (left join ORDER_CATALOG ocat on ocat.catalog_cd = o.catalog_cd
		and ocat.active_ind = 1)
	
	, (left join BILL_ITEM bi on bi.ext_parent_reference_id = ocat.catalog_cd
		and bi.ext_parent_contributor_cd = contrib_var
		and bi.ext_owner_cd = ocat.activity_type_cd
		and bi.ext_child_reference_id = 0.0
		and bi.parent_qual_cd = 1.0
		and bi.active_ind = 1)
 
	, (left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
		and bim.bill_item_type_cd = bill_item_type_var
		and bim.key1_id = cpt_var
		and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bim.active_ind = 1)
		
	, (left join NOMENCLATURE n on n.nomenclature_id = bim.key3_id
		and n.source_vocabulary_cd = cpt4_var
		and n.active_ind = 1)
 
where
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sea.sch_event_id, sched_appt->list[num].sch_event_id) ;010
 
order by
	sa.sch_appt_id
	, sea.sch_event_id ;010
	, o.order_id
 
 
; populate sched_appt record structure with procedure data	
head sa.sch_appt_id
	cntx = 0
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sea.sch_event_id, sched_appt->list[numx].sch_event_id) ;010
	
detail
	cntx = cntx + 1
 
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
 	sched_appt->list[idx].proc_cnt								= cntx
	sched_appt->list[idx].procedures[cntx].order_id				= o.order_id
	sched_appt->list[idx].procedures[cntx].order_mnemonic		= trim(o.order_mnemonic, 3)
	sched_appt->list[idx].procedures[cntx].order_dt_tm			= o.current_start_dt_tm
	sched_appt->list[idx].procedures[cntx].order_entered_by		= trim(od2.oe_field_display_value, 3)
	sched_appt->list[idx].procedures[cntx].order_action_dt_tm	= oa.action_dt_tm
	sched_appt->list[idx].procedures[cntx].order_action_type	= trim(uar_get_code_display(oa.action_type_cd), 3)
 
 	;006
 	comment = fillstring(255, " ") 	
	comment	= trim(od4.oe_field_display_value, 3)
	comment = replace(comment, char(13), " ", 4)
	comment = replace(comment, char(10), " ", 4)
	comment = replace(comment, char(0), " ", 4)
	
	sched_appt->list[idx].procedures[cntx].order_comment 		= trim(comment, 3)

	sched_appt->list[idx].procedures[cntx].request_start_dt_tm	= od3.oe_field_dt_tm_value ;006
	sched_appt->list[idx].procedures[cntx].exam_start_dt_tm		= oros.start_dt_tm ;006

	sched_appt->list[idx].procedures[cntx].prior_auth			= trim(od.oe_field_display_value, 3)
	
	sched_appt->list[idx].procedures[cntx].auth_entered_by		= if (size(trim(od.oe_field_display_value, 3)) > 0)
																	per_od.name_full_formatted
																  endif
																  
	sched_appt->list[idx].procedures[cntx].auth_dt_tm			= od.updt_dt_tm
	
;	sched_appt->list[idx].procedures[cntx].auth_tat_days		= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
;																	and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100"))
;																	and (od.updt_dt_tm > 0))
;																		datetimediff(od.updt_dt_tm, sen.earliest_dt_tm)
;																	endif
	
	sched_appt->list[idx].procedures[cntx].cpt_cd				= trim(bim.key6, 3) ;006
	sched_appt->list[idx].procedures[cntx].cpt_desc				= trim(n.source_string, 3) ;006
	
;010
;foot sa.sch_appt_id
;	if (cntx = 0)
;		cntx = 1
;	endif
;	
;	call alterlist(sched_appt->list[idx].procedures, cntx)
 
WITH nocounter, expand = 1, time = 1800 ;010

;call echorecord(sched_appt)
call echo(sched_appt->sched_cnt)

;go to exitscript


/**************************************************************/
; select scanned order data ;011
select into "NL:"
from
	CLINICAL_EVENT ce
	
	, (dummyt d1 with seq = value(sched_appt->sched_cnt))

plan d1

join ce
where
	ce.encntr_id = sched_appt->list[d1.seq].encntr_id
	and ce.person_id = sched_appt->list[d1.seq].person_id
	and ce.event_cd in (
		physician_order_var, outside_order_var
	)
 
 
; populate tat_data record structure
detail
	sched_appt->list[d1.seq].has_scanned_order = 1
	
with nocounter, time = 1800

;call echorecord(sched_appt)


/**************************************************************/
; select org set data ;011
select into "NL:"
	; derive cmg indicator
	is_cmg = if (os.name like "*CMG*") 1
		elseif (org.org_name_key like "THOMPSONONCOLOGYGROUP*") 1 
		elseif (org.org_name_key like "FSRSLEEPDISORDERSCENTER*") 1
		elseif (ps.practice_site_display like "Thompson Cancer*") 1
		elseif (ps.practice_site_display like "Peninsula*Clinic*") 1
		else 0 
		endif
		
from
	PRACTICE_SITE ps
	
	, (left join ORG_SET_ORG_R osor on osor.organization_id = ps.organization_id
		and osor.active_ind = 1)
	
	, (left join ORG_SET os on os.org_set_id = osor.org_set_id
		and os.active_ind = 1)
		
	, (left join ORGANIZATION org on org.organization_id = osor.organization_id
		and org.active_ind = 1)
	
	, (dummyt d1 with seq = value(sched_appt->sched_cnt))

plan d1

join ps
where
	ps.practice_site_id = sched_appt->list[d1.seq].practice_site_id
	
join osor
join os
join org
 
 
; populate record structure
detail
	if (is_cmg = 1)
		sched_appt->list[d1.seq].is_cmg = is_cmg
	endif
	
with nocounter, time = 1800
 
;call echorecord(sched_appt)

 
/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, outerjoin = d1, pcformat (^"^, ^,^, 1), format = stream, format, time = 1800 ;003 ;005 ;010
else
	with nocounter, outerjoin = d1, separator = " ", format, time = 1800 ;003 ;005 ;010
endif

;006
into value(output_var)
	person_id				= sched_appt->list[d1.seq].person_id
	, patient_name			= sched_appt->list[d1.seq].patient_name
	, fin					= sched_appt->list[d1.seq].fin
	, fac					= sched_appt->list[d1.seq].facility
	, patient_acct_nbr		= build(sched_appt->list[d1.seq].facility, sched_appt->list[d1.seq].fin)
	
	, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob,
								sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
	
	, gender				= sched_appt->list[d1.seq].gender ;015	
	, language				= sched_appt->list[d1.seq].language ;014	
	, ssn					= sched_appt->list[d1.seq].ssn
	, mrn					= sched_appt->list[d1.seq].mrn
	, cmrn					= sched_appt->list[d1.seq].cmrn ;014
	, encntr_type			= sched_appt->list[d1.seq].encntr_type
	, encntr_status			= sched_appt->list[d1.seq].encntr_status
	
	, order_id				= sched_appt->list[d1.seq].procedures[d2.seq].order_id
	, order_mnemonic		= sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic
	, order_phy_id			= sched_appt->list[d1.seq].order_phy_id
	, order_phy				= sched_appt->list[d1.seq].order_phy
	, ord_phys_group		= sched_appt->list[d1.seq].ord_phys_group
	
	;011
	, is_cmg				= if (trim(sched_appt->list[d1.seq].ord_phys_group, 3) > "")
								evaluate(sched_appt->list[d1.seq].is_cmg, 1, "Y", "N")
							  else
							  	" "
							  endif
	
	, order_entered_by		= sched_appt->list[d1.seq].procedures[d2.seq].order_entered_by
	, order_action_dt_tm	= format(sched_appt->list[d1.seq].procedures[d2.seq].order_action_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, order_action_type		= sched_appt->list[d1.seq].procedures[d2.seq].order_action_type
	, cpt_cd				= sched_appt->list[d1.seq].procedures[d2.seq].cpt_cd
	, cpt_desc				= sched_appt->list[d1.seq].procedures[d2.seq].cpt_desc
	, icd10					= sched_appt->list[d1.seq].icd10
	, icd10_desc			= sched_appt->list[d1.seq].icd10_desc
	, order_comment			= sched_appt->list[d1.seq].procedures[d2.seq].order_comment
	
	, org_name				= sched_appt->list[d1.seq].org_name
	, health_plan			= sched_appt->list[d1.seq].health_plan
	, schedule_id			= sched_appt->list[d1.seq].schedule_id
	, sch_state				= sched_appt->list[d1.seq].sch_state
	, location				= sched_appt->list[d1.seq].location
	, resource				= sched_appt->list[d1.seq].resource
	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, appt_type				= sched_appt->list[d1.seq].appt_type
	, reason_exam			= sched_appt->list[d1.seq].reason_exam
	, sch_action_dt_tm		= format(sched_appt->list[d1.seq].sch_action_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, sch_action_type		= sched_appt->list[d1.seq].sch_action_type
	, sch_action_prsnl		= sched_appt->list[d1.seq].sch_action_prsnl
	
	, pre_reg_dt_tm			= format(sched_appt->list[d1.seq].pre_reg_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, est_arrive_dt_tm		= format(sched_appt->list[d1.seq].est_arrive_dt_tm, "mm/dd/yyyy hh:mm;;q") ;014
	, exam_start_dt_tm		= format(sched_appt->list[d1.seq].procedures[d2.seq].exam_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, entry_state			= sched_appt->list[d1.seq].entry_state
	, earliest_dt_tm		= format(sched_appt->list[d1.seq].earliest_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, request_start_dt_tm	= format(sched_appt->list[d1.seq].procedures[d2.seq].request_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, prior_auth			= sched_appt->list[d1.seq].procedures[d2.seq].prior_auth
	, prior_auth_entered_by	= sched_appt->list[d1.seq].procedures[d2.seq].auth_entered_by
	, prior_auth_dt_tm		= format(sched_appt->list[d1.seq].procedures[d2.seq].auth_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, auth_nbr				= sched_appt->list[d1.seq].auth_nbr
	, auth_nbr_entered_by	= sched_appt->list[d1.seq].auth_nbr_entered_by
	, has_scanned_order		= evaluate(sched_appt->list[d1.seq].has_scanned_order, 1, "Y", "N") ;011	
	, comment				= sched_appt->list[d1.seq].comment
 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	
	, (dummyt d2 with seq = 1)
 
plan d1
where
	maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
	
join d2
 
order by
	org_name
	, patient_name
	, sched_appt->list[d1.seq].appt_dt_tm

with nocounter, outerjoin = d1 ;010
 
 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

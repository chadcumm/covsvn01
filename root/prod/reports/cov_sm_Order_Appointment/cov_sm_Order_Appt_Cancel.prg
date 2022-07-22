/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/07/2021
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appt_Cancel.prg
	Object name:		cov_sm_Order_Appt_Cancel
	Request #:			9973, 11683
 
	Program purpose:	Lists cancelled appointments for turnaround time data.
 
	Executing from:		CCL
 
 	Special Notes:		This is a report/extract CCL.  Changes have to be
						coordinated with downstream processes.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/07/2021	Todd A. Blanchard		Modified extract file name.
002	11/11/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West.

******************************************************************************/
 
drop program cov_sm_Order_Appt_Cancel:DBA go
create program cov_sm_Order_Appt_Cancel:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, start_datetime, end_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime					= dq8 with noconstant(cnvtdatetime(curdate, 000000))
declare end_datetime					= dq8 with noconstant(cnvtdatetime(curdate, 235959))

declare fin_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare rescheduled_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))
declare action_comments_text_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 15149, "ACTIONCOMMENTS"))
declare action_comments_sub_text_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 15589, "ACTIONCOMMENTS"))

declare file_dt_tm						= vc with constant(format(sysdate, "mm-dd-yyyy;;d")) ;001
declare file_var						= vc with constant(build("can", file_dt_tm, ".csv")) ;001

declare dir_var							= vc with noconstant("Centralized/TATCancel/")
 
declare temppath_var					= vc with constant(build("cer_temp:", file_var))
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var))

declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
																 "_cust/to_client_site/RevenueCycle/Scheduling/", dir_var, file_var))
															 
declare output_var						= vc with noconstant("")
 
declare cmd								= vc with noconstant("")
declare len								= i4 with noconstant(0)
declare stat							= i4 with noconstant(0)


; define dates
if (validate(request->batch_selection) = 1)
	set start_datetime = cnvtdatetime(start_datetime)
	set end_datetime = cnvtlookahead("5,D", end_datetime)
else
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)	
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

record tat_data (
	1	cnt							= i4
	1	list[*]
		2	fin						= c20
		2	appt_dt_tm				= dq8
		2	sch_action				= c30
		2	sch_action_dt_tm		= dq8
		2	sch_action_prsnl		= c100
		2	sch_reason				= c40
		2	sch_action_comment		= c300
)
 
 
/**************************************************************/
; select appointment data
select into "NL:"
from
	SCH_APPT sa
 
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var)
 
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id
		; practice site exclusions
		and org.organization_id not in (
			select ps.organization_id
			from PRACTICE_SITE ps
			where 
				ps.practice_site_id > 0.0
				and ps.organization_id not in (
					; acutes
					3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00, 3144503.00, 3144504.00,
					3898154.00, 0.0 ;002
				)
		)
		; organization exclusions
		and org.org_name_key not in ("CARDIOLOGY*ASSOCIATES*OF*EAST*TENNESSEE*")
		and org.org_name_key not in ("CROSSVILLE*MEDICAL*GROUP*")
		and org.org_name_key not in ("SOUTHERN*MEDICAL*GROUP*")
		and org.org_name_key not in ("UROLOGY*SPECIALISTS*OF*EAST*TENNESSEE*")
		and org.org_name_key not in ("KNOXVILLE*HEART*GROUP*")
		and org.org_name_key not in ("HAMBLEN*UROLOGY*")
		)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.active_ind = 1)
 
	, (inner join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
		and seva.action_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and seva.action_meaning = "CANCEL"
		and seva.active_ind = 1)
 
	, (left join SCH_EVENT_COMM sec on sec.sch_event_id = seva.sch_event_id
		and sec.sch_action_id = seva.sch_action_id
		and sec.text_type_cd = action_comments_text_var
		and sec.sub_text_cd = action_comments_sub_text_var
		and sec.active_ind = 1)
 
	, (left join LONG_TEXT lt on lt.long_text_id = sec.text_id
		and lt.active_ind = 1)
 
	, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id)
	
	, (inner join PERSON p on p.person_id = sa.person_id)
 
where
	sa.schedule_id > 0.0
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd != rescheduled_var
	; location exclusions
	and sa.appt_location_cd not in (
		select cv.code_value
		from CODE_VALUE cv
		where ((
			cv.code_set > 0
			and cv.cdf_meaning in ("ANCILSURG", "SURGAREA", "SURGOP", "AMBULATORY")
			and (
				cv.display_key in ("*MAIN*OR")
				or cv.display_key in ("*PREADM*TESTING")
				or cv.display_key in ("*NON*SURGICAL")
				or cv.display_key in ("*ENDOSCOPY")
				or cv.display_key in ("*LABOR*DELIVERY")
				or cv.display_key in ("*ECOR")
			))
			or (
				cv.cdf_meaning in ("AMBULATORY")
				and cv.description in ("*INFUSION*")
			))
			and cv.active_ind = 1
	)
	and sa.active_ind = 1
 
 
; populate tat_data record structure
head report
	cnt = 0
 
	call alterlist(tat_data->list, 100)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(tat_data->list, cnt + 9)
	endif
 
	tat_data->cnt								= cnt
	tat_data->list[cnt].fin						= cnvtalias(eaf.alias, eaf.alias_pool_cd)
	
	tat_data->list[cnt].appt_dt_tm				= sa.beg_dt_tm
	tat_data->list[cnt].sch_action				= trim(seva.action_meaning, 3)
	tat_data->list[cnt].sch_action_dt_tm		= seva.action_dt_tm
	tat_data->list[cnt].sch_action_prsnl		= per_seva.name_full_formatted
	tat_data->list[cnt].sch_reason				= trim(uar_get_code_display(seva.sch_reason_cd), 3)
 
	tat_data->list[cnt].sch_action_comment		= lt.long_text
	tat_data->list[cnt].sch_action_comment		= replace(tat_data->list[cnt].sch_action_comment, char(13), " ", 4)
	tat_data->list[cnt].sch_action_comment		= replace(tat_data->list[cnt].sch_action_comment, char(10), " ", 4)
	tat_data->list[cnt].sch_action_comment		= replace(tat_data->list[cnt].sch_action_comment, char(0), " ", 4)
	tat_data->list[cnt].sch_action_comment		= trim(tat_data->list[cnt].sch_action_comment, 3)
 
with nocounter, time = 600

;call echorecord(tat_data)


/**************************************************************/
; select data

if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, separator = " ", format, time = 600
endif

distinct into value(output_var)
	fin								= tat_data->list[d1.seq].fin
	, appt_dt_tm					= tat_data->list[d1.seq].appt_dt_tm "@SHORTDATETIME"
	, sch_action					= tat_data->list[d1.seq].sch_action
	, sch_action_dt_tm				= tat_data->list[d1.seq].sch_action_dt_tm "@SHORTDATETIME"
	, sch_action_prsnl				= tat_data->list[d1.seq].sch_action_prsnl 
	, sch_reason					= tat_data->list[d1.seq].sch_reason 
	, sch_action_comment			= trim(tat_data->list[d1.seq].sch_action_comment, 3)
 
from
	(dummyt d1 with seq = value(tat_data->cnt))
 
plan d1
 
order by
	fin
	, tat_data->list[d1.seq].appt_dt_tm
	, tat_data->list[d1.seq].sch_action_dt_tm
	, sch_action_prsnl
	, sch_reason 

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
 
#exitscript
 
end
go
 

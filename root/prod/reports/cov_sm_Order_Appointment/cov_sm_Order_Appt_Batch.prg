/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/08/2021
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appt_Batch.prg
	Object name:		cov_sm_Order_Appt_Batch
	Request #:			10599
 
	Program purpose:	Lists modified orders for turnaround time data.
						Breaks data into smaller batches and generates
						related extract files.
 
	Executing from:		CCL
 
 	Special Notes:		Prompts change the where statement to filter by:
							- 0: Appointment Date
							- 1: Scheduled Date Action
							- 2: Order Date Action
							- 3: Pre-Reg Date
							
						This is a report/extract CCL.  Changes have to be
						coordinated with downstream processes.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------

******************************************************************************/
 
drop program cov_sm_Order_Appt_Batch:DBA go
create program cov_sm_Order_Appt_Batch:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 0 

with OUTDEV, start_datetime, end_datetime, report_type

 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

declare extractdata ((s = dq8), (e = dq8), (o = vc), (t2 = vc), (f = vc)) = null
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare span_days			= i4 with noconstant(0), private
declare span_weeks			= i4 with noconstant(0), private
declare span_daysmod		= i4 with noconstant(0), private
declare day_factor			= i4 with constant(14), private

declare start_dt_tm			= dq8 with noconstant(0.0), private
declare end_dt_tm			= dq8 with noconstant(0.0), private

declare file_var			= vc with noconstant(""), private

declare dir_var				= vc with constant("Centralized/TATBatch/"), private
 
declare temppath_var		= vc with noconstant(""), private
declare temppath2_var		= vc with noconstant(""), private

declare filepath_var		= vc with noconstant(""), private
															 
declare output_var			= vc with noconstant(""), private

declare num					= i4 with noconstant(0), private
 
 
/**************************************************************
 DVDev Start Coding
**************************************************************/

free record data
record data (
	1 qual [1]
		2 span_weeks	= i4
		2 span_daysmod	= i4
)

set span_days			= round(datetimediff(cnvtdatetime($end_datetime), cnvtdatetime($start_datetime)), 0)
set span_weeks			= floor(span_days / day_factor)
set span_daysmod		= mod(span_days, day_factor)

set data->qual[1].span_weeks = span_weeks
set data->qual[1].span_daysmod = span_daysmod

;call echo(build2("span_days: ", span_days))
;call echo(build2("span_weeks: ", span_weeks))
;call echo(build2("span_daysmod: ", span_daysmod))

for (i = 0 to span_weeks - 1)
;	call echo(build2("week: ", i))
	
	set start_dt_tm = cnvtlookahead(build(i * day_factor, " d"), cnvtdatetime($start_datetime))
	set end_dt_tm = cnvtlookahead(build(day_factor - 1, " d"), cnvtdatetime(start_dt_tm, 235959))
	
;	call echo(build2("start_dt_tm: ", format(start_dt_tm, ";;q")))
;	call echo(build2("end_dt_tm: ", format(end_dt_tm, ";;q")))
	
	set file_var			= build("tat_", 
								format(start_dt_tm, "yyyymmdd;;d"),
								"_",
								format(end_dt_tm, "yyyymmdd;;d"), 
								".csv")
	 
	set temppath_var		= build("cer_temp:", file_var)
	set temppath2_var		= build("$cer_temp/", file_var)
	
	set filepath_var		= build("/cerner/w_custom/", cnvtlower(curdomain),
									"_cust/to_client_site/RevenueCycle/Scheduling/", dir_var, file_var)
																 
	set output_var			= temppath_var
	
	call echo(filepath_var)
	
	call extractdata (start_dt_tm, end_dt_tm, output_var, temppath2_var, filepath_var)
endfor

if (span_weeks > 0)
	if (span_daysmod > 0)
		set start_dt_tm = cnvtlookahead("1 d", cnvtdatetime(cnvtdate(end_dt_tm), 000000))
		set end_dt_tm = cnvtlookahead(build(span_daysmod, " d"), cnvtdatetime(end_dt_tm, 235959))

;		call echo("")
;		call echo(build2("start_dt_tm: ", format(start_dt_tm, ";;q")))
;		call echo(build2("end_dt_tm: ", format(end_dt_tm, ";;q")))
	
		set file_var			= build("tat_", 
									format(start_dt_tm, "yyyymmdd;;d"),
									"_",
									format(end_dt_tm, "yyyymmdd;;d"), 
									".csv")
		 
		set temppath_var		= build("cer_temp:", file_var)
		set temppath2_var		= build("$cer_temp/", file_var)
		
		set filepath_var		= build("/cerner/w_custom/", cnvtlower(curdomain),
										"_cust/to_client_site/RevenueCycle/Scheduling/", dir_var, file_var)
																	 
		set output_var			= temppath_var
		
		call echo(filepath_var)
	
		call extractdata (start_dt_tm, end_dt_tm, output_var, temppath2_var, filepath_var)
	endif
else
	set start_dt_tm = cnvtdatetime($start_datetime)
	set end_dt_tm = cnvtlookahead(build(span_daysmod - 1, " d"), cnvtdatetime(start_dt_tm, 235959))	

;	call echo("")
;	call echo(build2("start_dt_tm: ", format(start_dt_tm, ";;q")))
;	call echo(build2("end_dt_tm: ", format(end_dt_tm, ";;q")))
	
	set file_var			= build("tat_", 
								format(start_dt_tm, "yyyymmdd;;d"),
								"_",
								format(end_dt_tm, "yyyymmdd;;d"), 
								".csv")
	 
	set temppath_var		= build("cer_temp:", file_var)
	set temppath2_var		= build("$cer_temp/", file_var)
	
	set filepath_var		= build("/cerner/w_custom/", cnvtlower(curdomain),
									"_cust/to_client_site/RevenueCycle/Scheduling/", dir_var, file_var)
																 
	set output_var			= temppath_var
	
	call echo(filepath_var)
	
	call extractdata (start_dt_tm, end_dt_tm, output_var, temppath2_var, filepath_var)
endif


select into $OUTDEV
from
	(dummyt d1 with seq = 1)
	
detail
	span_weeks = evaluate(data->qual[d1.seq].span_weeks, 0, 0, data->qual[d1.seq].span_weeks)
	span_daysmod = evaluate(data->qual[d1.seq].span_daysmod, 0, 0, 1)
	span_total = span_weeks + span_daysmod
	
	result = build2(
		"Process complete: ", span_total, " file(s) created.", char(10), char(10), char(13),
		"Folder: ",
		"\\file01\Shared\InformationServices\RevCycle\WorkingFiles\Input\CentralizedScheduling\Batch_TAT",
		char(10), char(10), char(13),
		"Please wait up to 5 minutes for file(s) to be transferred from AStream."
		)

	col 0 result
	
with nocounter, separator = " ", format, maxcol = 500

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

subroutine extractdata(s, e, o, t2, f)

	declare cmd		= vc with noconstant(""), private
	declare len		= i4 with noconstant(0), private
	declare stat	= i4 with noconstant(0), private

	call echo(build2("extractdata (", s, ", ", e, ")"))
	
	; select base turnaround time data
	execute cov_sm_Order_Appointment_TAT $OUTDEV, s, e, $report_type, 0
	
	
	; select data
	set modify filestream
	
	select distinct into value(o)
		person_id						= tat_data->list[d1.seq].person_id
		, name_full_formatted			= tat_data->list[d1.seq].name_full_formatted
		, dob							= format(cnvtdatetimeutc(datetimezone(
											tat_data->list[d1.seq].birth_dt_tm, 
											tat_data->list[d1.seq].birth_tz), 1), "mm/dd/yyyy;;d") ;015
		, fin							= tat_data->list[d1.seq].fin
		, encntr_type					= tat_data->list[d1.seq].encntr_type
		, encntr_status					= tat_data->list[d1.seq].encntr_status
		, order_id						= tat_data->list[d1.seq].order_id
		, order_mnemonic				= tat_data->list[d1.seq].order_mnemonic
		, ordering_physician			= tat_data->list[d1.seq].ordering_physician
		, ord_phys_group				= tat_data->list[d1.seq].ord_phys_group	
		, is_cmg						= evaluate(tat_data->list[d1.seq].is_cmg, 1, "Y", "N") ;015
		, appt_location					= tat_data->list[d1.seq].appt_location
		, org_name						= tat_data->list[d1.seq].org_name
		, sch_state						= tat_data->list[d1.seq].sch_state
		, pre_reg_dt_tm					= tat_data->list[d1.seq].pre_reg_dt_tm "@SHORTDATETIME"
		, pre_reg_prsnl					= tat_data->list[d1.seq].pre_reg_prsnl
		, appt_dt_tm					= tat_data->list[d1.seq].appt_dt_tm "@SHORTDATETIME"
		, exam_start_dt_tm				= tat_data->list[d1.seq].exam_start_dt_tm "@SHORTDATETIME"
		, entry_state					= tat_data->list[d1.seq].entry_state
		, earliest_dt_tm				= tat_data->list[d1.seq].earliest_dt_tm "@SHORTDATETIME"
		, appt_tat_days					= format(tat_data->list[d1.seq].appt_tat_days, ";R;I")
		, requested_start_dt_tm			= tat_data->list[d1.seq].requested_start_dt_tm "@SHORTDATETIME"
		, order_entered_by				= tat_data->list[d1.seq].order_entered_by
		, order_action_dt_tm			= tat_data->list[d1.seq].order_action_dt_tm "@SHORTDATETIME"
		, order_action_type				= tat_data->list[d1.seq].order_action_type
		, sch_action_dt_tm				= tat_data->list[d1.seq].sch_action_dt_tm "@SHORTDATETIME"
		, sch_action_type				= tat_data->list[d1.seq].sch_action_type
		, sch_action_prsnl				= tat_data->list[d1.seq].sch_action_prsnl
		, sch_tat_days					= format(tat_data->list[d1.seq].sch_tat_days, ";R;I")
		, prior_auth					= tat_data->list[d1.seq].prior_auth
		, auth_entered_by				= tat_data->list[d1.seq].auth_entered_by
		, auth_dt_tm					= tat_data->list[d1.seq].auth_dt_tm "@SHORTDATETIME"
		, auth_tat_days					= format(tat_data->list[d1.seq].auth_tat_days, ";R;I")
		, auth_nbr						= tat_data->list[d1.seq].auth_nbr
		, auth_nbr_entered_by			= tat_data->list[d1.seq].auth_nbr_entered_by
		, health_plan					= tat_data->list[d1.seq].health_plan
		, auc_order_adhere_mod			= tat_data->list[d1.seq].sch_auc_order_adhere_mod
		, qual_cdsm_utilized			= tat_data->list[d1.seq].sch_qual_cdsm_utilized
		, ecare_auc_order_adhere_mod	= tat_data->list[d1.seq].ord_auc_order_adhere_mod
		, ecare_qual_cdsm_utilized		= tat_data->list[d1.seq].ord_qual_cdsm_utilized
		, has_scanned_order				= evaluate(tat_data->list[d1.seq].has_scanned_order, 1, "Y", "N") ;014	
		, comment						= tat_data->list[d1.seq].comment
	 
	from
		(dummyt d1 with seq = value(tat_data->cnt))
	 
	plan d1
	 
	order by
		build(tat_data->list[d1.seq].name_full_formatted, tat_data->list[d1.seq].person_id)
		, tat_data->list[d1.seq].appt_dt_tm
		, tat_data->list[d1.seq].sch_action_dt_tm
		, tat_data->list[d1.seq].requested_start_dt_tm
		, tat_data->list[d1.seq].earliest_dt_tm
		, tat_data->list[d1.seq].exam_start_dt_tm
		, build(tat_data->list[d1.seq].order_action_dt_tm, tat_data->list[d1.seq].order_id)
		, build(tat_data->list[d1.seq].appt_tat_days, tat_data->list[d1.seq].sch_tat_days, tat_data->list[d1.seq].auth_tat_days)
		, build(tat_data->list[d1.seq].prior_auth, tat_data->list[d1.seq].auth_nbr)
		, comment
	
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
	
	 
	; copy file to AStream
	set cmd = build2("cp ", t2, " ", f)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))

end

 
#exitscript
 
end
go
 

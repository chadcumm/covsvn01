/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/30/2021
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appt_Recovery.prg
	Object name:		cov_sm_Order_Appt_Recovery
	Request #:			10754
 
	Program purpose:	Lists orders for turnaround time data for disaster
						recovery purposes.
 
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
 
drop program cov_sm_Order_Appt_Recovery:DBA go
create program cov_sm_Order_Appt_Recovery:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 0
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, start_datetime, end_datetime, report_type, output_file


/**************************************************************/
; set up date parameters
declare start_date		= dq8 with noconstant(0.0)
declare end_date		= dq8 with noconstant(0.0)

if (validate(request->batch_selection) = 1)
 	set start_date = datetimefind(cnvtdatetime(curdate, 000000),'D','B','B')
	set end_date   = datetimefind(cnvtdatetime(curdate+30, 235959),'D','B','E')
 else
	set start_date  = cnvtdatetime($start_datetime)
	set end_date    = cnvtdatetime($end_datetime)
endif


/**************************************************************/
; select base turnaround time data
execute cov_sm_Order_Appointment_TAT $OUTDEV, start_date, end_date, $report_type, 0

 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare file0_var					= vc with constant("dr_tatappt.csv")
declare file1_var					= vc with constant("dr_tatsched.csv")
declare file_var					= vc with noconstant("")

declare dir0_var					= vc with noconstant("Centralized/TATRecovery/")
declare dir1_var					= vc with noconstant("Centralized/TATRecovery/")
declare dir_var						= vc with noconstant("")

if ($report_type = 0)
	set file_var = file0_var
	set dir_var = dir0_var
	
elseif ($report_type = 1)
	set file_var = file1_var
	set dir_var = dir1_var
	
endif
 
declare temppath_var				= vc with constant(build("cer_temp:", file_var))
declare temppath2_var				= vc with constant(build("$cer_temp/", file_var))

declare filepath_var				= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
												"_cust/to_client_site/RevenueCycle/Scheduling/", dir_var, file_var))
															 
declare output_var					= vc with noconstant("")

declare num							= i4 with noconstant(0)

declare cmd							= vc with noconstant("")
declare len							= i4 with noconstant(0)
declare stat						= i4 with noconstant(0)
	
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
 DVDev Start Coding
**************************************************************/

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
	person_id						= tat_data->list[d1.seq].person_id
	, name_full_formatted			= tat_data->list[d1.seq].name_full_formatted
	, dob							= format(cnvtdatetimeutc(datetimezone(
										tat_data->list[d1.seq].birth_dt_tm, 
										tat_data->list[d1.seq].birth_tz), 1), "mm/dd/yyyy;;d")
	, fin							= tat_data->list[d1.seq].fin
	, encntr_type					= tat_data->list[d1.seq].encntr_type
	, encntr_status					= tat_data->list[d1.seq].encntr_status
	, order_id						= tat_data->list[d1.seq].order_id
	, order_mnemonic				= tat_data->list[d1.seq].order_mnemonic
	, ordering_physician			= tat_data->list[d1.seq].ordering_physician
	, ord_phys_group				= tat_data->list[d1.seq].ord_phys_group	
	, is_cmg						= evaluate(tat_data->list[d1.seq].is_cmg, 1, "Y", "N")
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
	, has_scanned_order				= evaluate(tat_data->list[d1.seq].has_scanned_order, 1, "Y", "N")	
	, comment						= tat_data->list[d1.seq].comment
 
from
	(dummyt d1 with seq = value(tat_data->cnt))
 
plan d1
 
order by
	name_full_formatted
	, person_id
	, fin

with nocounter, outerjoin = d1

 
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
 

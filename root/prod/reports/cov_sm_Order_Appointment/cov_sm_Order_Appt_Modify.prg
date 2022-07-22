/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		12/14/2020
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appt_Modify.prg
	Object name:		cov_sm_Order_Appt_Modify
	Request #:			9030, 9876, 12349
 
	Program purpose:	Lists modified orders for turnaround time data.
 
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
001	03/24/2021	Todd A. Blanchard		Added logic for unauthorized physicians.
002	03/07/2022	Todd A. Blanchard		Changed practice site display to org name.

******************************************************************************/
 
drop program cov_sm_Order_Appt_Modify:DBA go
create program cov_sm_Order_Appt_Modify:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 0
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, start_datetime, end_datetime, report_type, output_file
 

/**************************************************************/
; select base turnaround time data
execute cov_sm_Order_Appointment_TAT $OUTDEV, $start_datetime, $end_datetime, $report_type, 0

 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare modify_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "MODIFY"))
declare unauth_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 8, "UNAUTH")) ;001

declare file0_var					= vc with constant("mod_tatappt.csv")
declare file1_var					= vc with constant(build("mod_", format(curdate, "mm-dd-yyyy;;d"), "_tat.csv"))
declare file_var					= vc with noconstant("")

declare dir0_var					= vc with noconstant("Centralized/TATModify/")
declare dir1_var					= vc with noconstant("Centralized/TATModify/")
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

record mod_data (
	1	cnt							= i4
	1	list[*]
		2	order_id				= f8
		2	ordering_physician		= c100
		2	ord_phys_group			= c100
		2	order_action_dt_tm		= dq8
		2	order_action_type		= c40
)

 
/**************************************************************/
; select modified order data
select distinct into "NL:"	
from
	ORDER_ACTION oa
	 
	, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id)
 
	; first practice site
	, (left join PRSNL_RELTN pr_oa on pr_oa.person_id = per_oa.person_id
		and pr_oa.parent_entity_name = "PRACTICE_SITE"
		and pr_oa.active_ind = 1
		and pr_oa.parent_entity_id = (
			select min(pr_oa2.parent_entity_id)
			from PRSNL_RELTN pr_oa2
			where
				pr_oa2.person_id = pr_oa.person_id
				and pr_oa2.parent_entity_name = pr_oa.parent_entity_name
				and pr_oa2.active_ind = pr_oa.active_ind
			group by
				pr_oa2.person_id
		))
 
	, (left join PRACTICE_SITE ps_oa on ps_oa.practice_site_id = pr_oa.parent_entity_id)
 
	, (left join ORGANIZATION org_psoa on org_psoa.organization_id = ps_oa.organization_id) ;002
		
	, (dummyt d1 with seq = value(tat_data->cnt))
	
plan d1

join oa	
where
	oa.order_id = tat_data->list[d1.seq].order_id
	and oa.action_type_cd in (modify_var)
	and oa.action_sequence = (
		select max(oam.action_sequence)
		from ORDER_ACTION oam
		where
			oam.order_id = oa.order_id
			and oam.action_type_cd in (modify_var)
		group by
			oam.order_id
	)
	
join per_oa
join pr_oa
join ps_oa
join org_psoa ;002
	
order by
	oa.order_id
 
 
; populate mod_data record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	call alterlist(mod_data->list, cnt)
	
	mod_data->cnt								= cnt
	mod_data->list[cnt].order_id				= oa.order_id
	
	;001
	mod_data->list[cnt].ordering_physician		= if (per_oa.data_status_cd = unauth_var)
													"Unauthorized Physician"
												  else
													trim(per_oa.name_full_formatted, 3)
												  endif
												  
	mod_data->list[cnt].ord_phys_group			= trim(org_psoa.org_name, 3) ;002
	mod_data->list[cnt].order_action_dt_tm		= oa.action_dt_tm
	mod_data->list[cnt].order_action_type		= uar_get_code_display(oa.action_type_cd)
		
with nocounter, time = 600

call echorecord(mod_data)


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
	person_id						= tat_data->list[d2.seq].person_id
	, name_full_formatted			= tat_data->list[d2.seq].name_full_formatted
	, dob							= format(cnvtdatetimeutc(datetimezone(
										tat_data->list[d2.seq].birth_dt_tm, 
										tat_data->list[d2.seq].birth_tz), 1), "mm/dd/yyyy;;d")
	, fin							= tat_data->list[d2.seq].fin
	, order_id						= mod_data->list[d1.seq].order_id
	, order_mnemonic				= tat_data->list[d2.seq].order_mnemonic
	, ordering_physician			= mod_data->list[d1.seq].ordering_physician
	, ord_phys_group				= mod_data->list[d1.seq].ord_phys_group
	, order_action_dt_tm			= mod_data->list[d1.seq].order_action_dt_tm "@SHORTDATETIME"
	, order_action_type				= mod_data->list[d1.seq].order_action_type
 
from
	(dummyt d1 with seq = value(mod_data->cnt))
	, (dummyt d2 with seq = value(tat_data->cnt))
 
plan d1

join d2 where tat_data->list[d2.seq].order_id = mod_data->list[d1.seq].order_id
 
order by
	name_full_formatted
	, person_id
	, fin
	, mod_data->list[d1.seq].order_action_dt_tm
	, mod_data->list[d1.seq].order_id

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
 

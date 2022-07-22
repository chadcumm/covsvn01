/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dan Herren
	Date Written:		May 2019
	Solution:			Revenue Cycle - Charge Services
	Source file name:	cov_cs_ChrgSrvsAccessXtract.prg
	Object name:		cov_cs_ChrgSrvsAccessXtract
	Request #:			4398
 
	Program purpose:	Report of accesses in an Application Groups, Positions
						with the Charge Services Application Groups, and
						people in the Positions.
 
	Executing from:		CCL
 
 	Special Notes:		Output files:
 							app_group_access.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  Mod Date		Developer				Comment
  ----------	--------------------	--------------------------------------
 
 
******************************************************************************/
 
drop program cov_cs_ChrgSrvsAccessXtract:DBA go
create program cov_cs_ChrgSrvsAccessXtract:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Output To File" = 0
 
with OUTDEV, OUTPUT_FILE
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare filename_dt_tm	= vc with constant(format(sysdate, "yyyymmddhhmm;;d"))
declare filename_var	= vc with constant(build("chrgsrvs_access_extract_", filename_dt_tm, ".csv"))
;declare filename_var	= vc with constant(build("zzzdjhtest", ".csv"))
 
declare dirname1_var	= vc with constant(build("cer_temp:",  filename_var))
declare dirname2_var	= vc with constant(build("$cer_temp/", filename_var))
 
declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													"_cust/to_client_site/RevenueCycle/ChargeServices/", filename_var))
declare output_var		= vc with noconstant("")
declare cmd				= vc with noconstant("")
declare len				= i4 with noconstant(0)
declare stat			= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(dirname1_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
 
select
	if (validate(request->batch_selection) = 1 or $output_file = 1)
		with nocounter, pcformat (^"^, ^|^, 1), format = stream, format, time = 240
	else
		with nocounter, separator = " ", format, time = 240
	endif
 
distinct into value(output_var)
	 app_group 	= uar_get_code_display(ag.app_group_cd)
	,position	= uar_get_code_display(ac.position_cd)
	,name 		= ac.name
	,username 	= cnvtlower(ac.username)
	,task_desc 	= at.description
	,task_text 	= at.text
	,app_name 	= a.description
 
from APPLICATION a
 
	,(inner join APPLICATION_CONTEXT ac on ac.application_number = a.application_number
;		and ac.position_cd not in (441, 2893454803) ;dba, dba lite
		and a.active_ind = 1)
 
	,(inner join APPLICATION_GROUP ag on ag.position_cd = ac.position_cd
		and ag.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and ag.application_group_id > 0)
 
	,(inner join APPLICATION_TASK_R atr on atr.application_number = a.application_number)
 
	,(inner join APPLICATION_TASK at on at.task_number = atr.task_number
		and at.active_ind = 1)
 
	,(inner join CODE_VALUE cv on cv.code_value = ag.app_group_cd
		and cv.display_key in ("PHARMNETOUTPTDBTOOLS", "PHARMNETDBTOOLS", "*CHARGE*SERVICE*")
		and cv.code_set = 500
		and cv.active_ind = 1)
 
where a.application_number in (951400,951080,951007,951100,951060,
            951210,951050,951001,952400,951005,951004,951250,951900)
 
order by app_group, position, name, task_desc, app_name
 
;==============================
; COPY FILE TO AStream
;==============================
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", dirname2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
end
go

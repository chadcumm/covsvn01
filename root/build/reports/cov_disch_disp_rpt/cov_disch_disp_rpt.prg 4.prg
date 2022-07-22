/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			   	
	Source file name:	 	cov_disch_disp_rpt.prg
	Object name:		   	cov_disch_disp_rpt
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_disch_disp_rpt:dba go
create program cov_disch_disp_rpt:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Beginning Discharge Date and Time" = "SYSDATE"
	, "Ending Discharge Date and Time" = "SYSDATE"
	, "Facility" = 0 

with OUTDEV, BEG_DISCH_DT_TM, END_DISCH_DT_TM, FACILITY


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 org_cnt		= i4
	1 org_qual[*]
	 2 org_id		= f8
	 2 ord_desc		= vc
	1 cnt			= i4
	1 qual[*]
	 2 encntr_id	= f8
)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Adding Organizations   ************************************"))

call writeLog(build2("* END   Adding Organizations   ************************************"))

call writeLog(build2("* START Finding Encounters   ************************************"))

select into "nl:"
from
	encounter e
plan e
	where 	e.organization_id = $FACILITY
	and 	e.disch_dt_tm between 
	
call writeLog(build2("* END   Finding Encounters   ************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go

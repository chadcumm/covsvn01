/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			Perioperative
	Source file name:	 	cov_log_eks.prg
	Object name:		   	cov_log_eks
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

drop program cov_log_eks:dba go
create program cov_log_eks:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
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
	1 cnt			= i4
	1 filename_a      = vc
	1 filename_b    = vc
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->filename_a = concat("cclscratch:eks_eksdata_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_b = concat("cclscratch:eks_request_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

if (validate(eksdata))
	call echojson(eksdata, t_rec->filename_a , 0) 
endif


if (validate(request))
	call echojson(request, t_rec->filename_b , 0) 
endif


set retval = 100

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

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

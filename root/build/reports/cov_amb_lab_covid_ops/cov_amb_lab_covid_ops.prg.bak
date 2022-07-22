/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/21/2020
	Solution:			Perioperative
	Source file name:	cov_amb_lab_covid_ops.prg
	Object name:		cov_amb_lab_covid_ops
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/21/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_amb_lab_covid_ops:dba go
create program cov_amb_lab_covid_ops:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
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
	1 params
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->params.end_dt_tm 	= datetimefind(cnvtlookbehind("0,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E') 
set t_rec->params.start_dt_tm 	= datetimefind(cnvtlookbehind("7,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Custom   *******************************************"))
/*
"MINE"
, VALUE(2552503613.00)
, VALUE(0.0)
, VALUE(2543.00)
, VALUE(3349587789.00, 3453222221.00, 3446833499.00, 3397231567.00, 3363721503.00, 3427729423.00, 
	3358207083.00, 3363387807.00, 3610635753.00, 3361700765.00, 3593981395.00,
	 3482845931.00, 3402256447.00, 3348598617.00, 3348530075.00, 3438761809.00)
, "29-NOV-2020 00:00:00"
, "01-DEC-2020 23:59:00"
, "DP "
*/
execute cov_amb_lab_covid_test
	 $OUTDEV
	,VALUE(2552503635.00, 2552503653.00, 2552503639.00, 2552503645.00, 21250403.00, 2552503613.00, 2552503649.00)
	,VALUE(0.0)
	,VALUE(2543.00, 2546.00, 2548.00, 2550.00, 643466.00)
	,VALUE(   3349587789.00
			, 3453222221.00
			, 3446833499.00
			, 3397231567.00
			, 3363721503.00
			, 3427729423.00
			, 3358207083.00
			, 3363387807.00
			, 3610635753.00
			, 3361700765.00
			, 3593981395.00
			, 3482845931.00
			, 3402256447.00
			, 3348598617.00
			, 3348530075.00
			, 3438761809.00)
	,format(cnvtdatetime(t_rec->params.start_dt_tm),";;q")
	,format(cnvtdatetime(t_rec->params.end_dt_tm),";;q")
	,"DP "

call writeLog(build2("* END   Custom   *******************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2(cnvtrectojson(t_rec)))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go

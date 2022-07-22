/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_bh_alert_audit.prg
	Object name:		cov_bh_alert_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_bh_alert_audit:dba go
create program cov_bh_alert_audit:dba

prompt 
	"Output to File/Printer/MINE (MINE):" = "MINE"   ;* Enter or select the printer or file name to send this report to
	, "Begin Date, mmddyy (today):" = "CURDATE"      ;* Enter the begin date for this report
	, "BeginTime, hhmm (0000):" = "0000"             ;* Enter the begin time for this report
	, "End Date, mmddyy (today):" = "CURDATE"        ;* Enter the end date for this report
	, "End Time, hhmm (2359):" = "2359"              ;* Enter the end time for this report
	, "FIN (optional):" = "" 

with outdev, begindate, begintime, enddate, endtime, FIN


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
	1 prompts
	 2 outdev		= vc
	 2 begindate    = vc
	 2 begintime	= vc
	 2 enddate		= vc
	 2 endtime		= vc
	 2 fin			= vc
	1 cons
	 2 encntr_id = f8
)

set t_rec->prompts.outdev 		= $OUTDEV
set t_rec->prompts.begindate 	= $BEGINDATE
set t_rec->prompts.begintime	= $BEGINTIME
set t_rec->prompts.enddate 		= $ENDDATE
set t_rec->prompts.endtime		= $ENDTIME
set t_rec->prompts.fin			= $FIN

;call addEmailLog("chad.cummings@covhlth.com")

if (t_rec->prompts.fin > " ")
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where ea.alias = t_rec->prompts.fin
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	detail
		stat = 0s
	with nocounter
endif

execute 
	eks_dlg_audit
	 t_rec->prompts.outdev
	,t_rec->prompts.begindate
	,t_rec->prompts.begintime
	,t_rec->prompts.enddate
	,t_rec->prompts.endtime
	,"*PSO*CERT_*"
	,"F "
	,"D "
	,"M "


;"MINE", "092721", "0000", "092721", "2359", "*RECERT*", "F ", "D ", "M "

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go

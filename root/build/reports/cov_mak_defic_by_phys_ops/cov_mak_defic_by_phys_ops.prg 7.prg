/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			   	Perioperative
	Source file name:	 	cov_mak_defic_by_phys_ops.prg
	Object name:		   	cov_mak_defic_by_phys_ops
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

drop program cov_mak_defic_by_phys_ops:dba go
create program cov_mak_defic_by_phys_ops:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


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
	1 cnt			= i4
	1 report_name_1 = vc
	1 report_name_2 = vc
)

set t_rec->report_name_1 = build(
										 cnvtlower(trim(curdomain))
										,"_1_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".csv"
										)
set t_rec->report_name_2 = build(
										 cnvtlower(trim(curdomain))
										,"_2_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".csv"
										)


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Execute First Deficiency Report ********************"))
execute 2_cov_him_mak_defic_by_phys value(concat(program_log->files.file_path,t_rec->report_name_1)),value(0),value(0)
call addAttachment(program_log->files.file_path,t_rec->report_name_1)
call writeLog(build2("* END   Execute First Deficiency Report ********************"))

call writeLog(build2("* START Execute Last Deficiency Report *********************"))
execute 2_cov_him_mak_defic_by_phys value(concat(program_log->files.file_path,t_rec->report_name_2)),value(0),value(0)
call addAttachment(program_log->files.file_path,t_rec->report_name_2)
call writeLog(build2("* END   Execute Last Deficiency Report *********************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

set reply->status_data.status = "S"

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)


end
go

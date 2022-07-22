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

set modify maxvarlen 268435456 ;increases max file size

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
	1 filename_c = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)


call addEmailLog("chad.cummings@covhlth.com")

set t_rec->filename_a = concat("cclscratch:eks_eksdata_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_b = concat("cclscratch:eks_request_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_c = concat("cclscratch:eks_audit_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

if (validate(eksdata))
	call echojson(eksdata, t_rec->filename_a , 0) 
endif


if (validate(request))
	call echojson(request, t_rec->filename_b , 0) 
endif

call echojson(t_rec, t_rec->filename_c , 0) 

/*
record eksdata(
1 tqual[4] ;data, evoke, logic and action
2 temptype = c10
2 qual[*]
3 accession_id = f8
3 order_id = f8
3 encntr_id = f8
3 person_id = f8
3 task_assay_cd = f8
3 clinical_event_id = f8
3 logging = vc
3 template_name = c30
3 cnt = i4
3 data[*]
4 misc = vc
)
*/
if (validate(eksdata))
	for (ii=1 to size(eksdata->tqual,5))
		for (i=1 to size(eksdata->tqual[ii].qual,5))
			set t_rec->audit_cnt = (t_rec->audit_cnt + 1 )
			set stat = alterlist(t_rec->audit,t_rec->audit_cnt)
		endfor
	endfor
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

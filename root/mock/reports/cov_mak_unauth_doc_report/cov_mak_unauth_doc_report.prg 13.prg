/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			
	Source file name:	 	cov_mak_unauth_doc_report.prg
	Object name:		   	cov_mak_unauth_doc_report
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	08/26/2019  Chad Cummings
******************************************************************************/

drop program cov_mak_unauth_doc_report:dba go
create program cov_mak_unauth_doc_report:dba

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
)

free set him_request
record him_request
(
  1 sort_flag = i2
  1 date_flag = i2
  1 start_dt_tm = dq8
  1 end_dt_tm = dq8
  1 org_qual[*]
    2 organization_id = f8
  1 debug_ind = i2
)

free set him_temp
record him_temp
(
 1  qual[*]
     2  encntr_id               = f8
     2  person_id               = f8
     2  mrn_formatted           = c20
     2  fin_formatted           = c20
     2  name_full_formatted     = c35
     2  encntr_type_disp        = c15
     2  med_service_cd			= f8
     2  visit_age               = i2
     2  visit_alloc_dt_tm       = dq8
     2  disch_dt_tm             = dq8
     2  tdo                     = c20
     2  organization_id         = f8
     2  org_name                = vc
     2  doc_qual[*]
         3 clinical_event_id    = f8
         3 event_disp           = c20
         2 event_cd				= f8
         2 verified_prsnl_id    = f8
         2 verified_prsnl  		= vc
         3 valid_from_dt_tm     = dq8
)

call addEmailLog("chad.cummings@covhlth.com")

set him_request->date_flag = 1
set him_request->debug_ind = 1
set him_request->sort_flag = 1
set him_request->start_dt_tm = cnvtdatetime(curdate-1,0)
set him_request->end_dt_tm = cnvtdatetime(curdate,235900)


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Execute him_mak_unauth_doc_report *******************"))

free set reply
record reply
(
  1 file_name = vc
%i cclsource:status_block.inc
)

execute cov_mak_unauth_doc_driver with replace(request,him_request), replace(temp,him_temp)

call writeLog(build2("* END   Execute him_mak_unauth_doc_report *******************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
call echorecord(him_request)
call echorecord(him_temp)

end
go

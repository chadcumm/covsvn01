/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			   	Perioperative
	Source file name:	 	cov_ccl_template.prg
	Object name:		   	cov_ccl_template
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

drop program cov_cpdi_act_audit:dba go
create program cov_cpdi_act_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Beginning Activity Date" = "SYSDATE" 

with OUTDEV, BEG_DT


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
	1 beg_dt_tm				= dq8
	1 cnt					= i4
	1 qual[*]
	 2 cdi_trans_log_id	 	= f8
	 2 person_id			= f8
	 2 perforing_prsnl		= vc
	 2 patient				= vc
	 2 description			= vc
	 2 action_dt_tm			= dq8
	 2 ax_docid				= vc
	 2 batch_name			= vc
	 2 c_cdi_queue_disp		= vc
	 2 create_dt_tm			= dq8
	 2 device_name			= vc
	 2 document_type_alias	= vc	
	 2 doc_type				= vc			
	 2 financial_nbr		= vc
	 2 mrn					= vc
	 2 page_cnt				= i2
	 2 parent_entity_name	= vc
	 2 patient_name			= vc
	 2 c_reason_disp		= vc
	 2 updt_dt_tm			= dq8
)

call addEmailLog("chad.cummings@covhlth.com")



call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding CDI Transactions ***************************"))

select into "nl:"
from
	cdi_trans_log ctl
plan ctl
	where ctl.action_dt_tm >= cnvtdatetime()
with nocounter

call writeLog(build2("* END   Finding CDI Transactions ***************************"))

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
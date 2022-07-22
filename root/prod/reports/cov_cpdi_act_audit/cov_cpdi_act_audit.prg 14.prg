/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			   	Perioperative
	Source file name:	 	cov_cpdi_act_audit.prg
	Object name:		   	cov_cpdi_act_audit
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
	, "Batch Name" = "" 

with OUTDEV, BEG_DT_TM, BATCH_NAME


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
	1 batch_name			= vc
	1 qual[*]
	 2 cdi_trans_log_id	 	= f8
	 2 person_id			= f8
	 2 performing_prsnl		= vc
	 2 performing_prsnl_pos = vc
	 2 performing_prsnl_id	= f8
	 2 patient				= vc
	 2 description			= vc
	 2 action_dt_tm			= dq8
	 2 ax_docid				= i4
	 2 batch_name			= vc
	 2 c_cdi_queue_disp		= vc
	 2 create_dt_tm			= dq8
	 2 device_name			= vc
	 2 document_type_alias	= vc	
	 2 doc_type				= vc			
	 2 financial_nbr		= vc
	 2 mrn					= vc
	 2 page_cnt				= i2
	 2 parent_entity_name	= c32
	 2 patient_name			= c255
	 2 c_reason_disp		= vc
	 2 updt_dt_tm			= dq8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->beg_dt_tm = cnvtdatetime($BEG_DT_TM)

if (t_rec->beg_dt_tm <= 0.0)
	set t_rec->beg_dt_tm = cnvtdatetime(curdate,0)
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding CDI Transactions ***************************"))

select into "nl:"
from
	 cdi_trans_log ctl
plan ctl
	where ctl.action_dt_tm >= cnvtdatetime(t_rec->beg_dt_tm)
head report
	t_rec->cnt = 0
detail
	t_rec->cnt = (t_rec->cnt + 1)
	if ((mod(t_rec->cnt,1000) = 1) or (t_rec->cnt = 1))
		stat = alterlist(t_rec->qual,(t_rec->cnt + 999))
 	endif
 	t_rec->qual[t_rec->cnt].action_dt_tm				= ctl.action_dt_tm
 	t_rec->qual[t_rec->cnt].ax_docid					= ctl.ax_docid
 	t_rec->qual[t_rec->cnt].batch_name					= ctl.batch_name
 	t_rec->qual[t_rec->cnt].c_cdi_queue_disp			= uar_get_code_display(ctl.cdi_queue_cd)
 	t_rec->qual[t_rec->cnt].c_reason_disp				= uar_get_code_display(ctl.reason_cd)
 	t_rec->qual[t_rec->cnt].cdi_trans_log_id			= ctl.cdi_trans_log_id
 	t_rec->qual[t_rec->cnt].create_dt_tm				= ctl.create_dt_tm
 	;t_rec->qual[t_rec->cnt].description					= 
 	t_rec->qual[t_rec->cnt].device_name					= ctl.device_name
 	t_rec->qual[t_rec->cnt].doc_type					= ctl.doc_type
 	t_rec->qual[t_rec->cnt].document_type_alias			= ctl.document_type_alias
 	t_rec->qual[t_rec->cnt].financial_nbr				= ctl.financial_nbr
 	t_rec->qual[t_rec->cnt].mrn							= ctl.mrn
 	t_rec->qual[t_rec->cnt].page_cnt					= ctl.page_cnt
 	t_rec->qual[t_rec->cnt].parent_entity_name			= ctl.parent_entity_name
 	t_rec->qual[t_rec->cnt].performing_prsnl_id			= ctl.perf_prsnl_id	 
 	t_rec->qual[t_rec->cnt].patient_name				= ctl.patient_name
 	t_rec->qual[t_rec->cnt].person_id					= ctl.person_id
 	t_rec->qual[t_rec->cnt].updt_dt_tm					= ctl.updt_dt_tm
foot report
	stat = alterlist(t_rec->qual,t_rec->cnt)
with nocounter

call writeLog(build2("* END   Finding CDI Transactions ***************************"))

call writeLog(build2("* START Finding Performing Prsnl and Patient ***************"))

select into "nl:"
from
	 (dummyt d1 with seq=value(t_rec->cnt))
	,prsnl p1
	,person p
plan d1
join p1
	where p1.person_id = outerjoin(t_rec->qual[d1.seq].performing_prsnl_id)
join p
	where p.person_id = outerjoin(t_rec->qual[d1.seq].person_id)
detail
	t_rec->qual[d1.seq].performing_prsnl 	= p1.name_full_formatted 
	t_rec->qual[d1.seq].performing_prsnl_pos = uar_get_code_display(p1.position_cd)
	t_rec->qual[d1.seq].patient				= p.name_full_formatted
call writeLog(build2("* END   Custom Performing Prsnl and Patient  ***************"))

call writeLog(build2("* START Generating Output ************************************"))

select into $OUTDEV
	 CDI_TRANS_LOG_ID 		= t_rec->qual[d1.seq].cdi_trans_log_id
	,PERSON_ID				= t_rec->qual[d1.seq].person_id
	,PERFORMING_PRSNL		= trim(substring(1,100,t_rec->qual[d1.seq].performing_prsnl))
	,PERFORMING_POSITION	= trim(substring(1,100,t_rec->qual[d1.seq].performing_prsnl_pos))
	,PATIENT				= trim(substring(1,100,t_rec->qual[d1.seq].patient))
	;,DESCRIPTION			= trim(t_rec->qual[d1.seq].description)
	,ACTION_DT_TM			= trim(format(t_rec->qual[d1.seq].action_dt_tm,";;q"))
	,AX_DOCID				= t_rec->qual[d1.seq].ax_docid
	,BATCH_NAME				= trim(substring(1,100,t_rec->qual[d1.seq].batch_name))
	,C_CDI_QUEUE_DISP		= trim(substring(1,100,t_rec->qual[d1.seq].c_cdi_queue_disp))
	,CREATE_DT_TM			= trim(format(t_rec->qual[d1.seq].create_dt_tm,";;q"))
	,DEVICE_NAME			= trim(t_rec->qual[d1.seq].device_name)
	,DOCUMENT_TYPE_ALIAS	= trim(substring(1,100,t_rec->qual[d1.seq].document_type_alias))
	,DOC_TYPE				= trim(substring(1,100,t_rec->qual[d1.seq].doc_type))
	,FINANCIAL_NBR			= trim(t_rec->qual[d1.seq].financial_nbr)
	,MRN					= trim(t_rec->qual[d1.seq].mrn)
	,PAGE_CNT				= t_rec->qual[d1.seq].page_cnt
	,PARENT_ENTITY_NAME		= trim(substring(1,100,t_rec->qual[d1.seq].parent_entity_name))
	,PATIENT_NAME			= trim(substring(1,100,t_rec->qual[d1.seq].patient_name))
	,C_REASON_DISP			= trim(substring(1,100,t_rec->qual[d1.seq].c_reason_disp))
	,UPDT_DT_TM				= trim(format(t_rec->qual[d1.seq].updt_dt_tm,";;q"))
from	
	(dummyt d1 with seq=value(t_rec->cnt))
order by
	ACTION_DT_TM
with nocounter, format, separator= " "
call writeLog(build2("* END   Generating Output ************************************"))

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

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Todd A. Blanchard
	Date Written:		01/20/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_cpdi_act_audit_print.prg
	Object name:		cov_cpdi_act_audit_print
	Request #:			6874

	Program purpose:	CDI transaction log of printed documents.

	Executing from:		CCL

 	Special Notes:		Calls base report: cov_cpdi_act_audit

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod	Mod Date	Developer				Comment
---	----------	--------------------	--------------------------------------

******************************************************************************/

drop program cov_cpdi_act_audit_print:dba go
create program cov_cpdi_act_audit_print:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Beginning Activity Date" = "SYSDATE"
	, "Ending Date and Time" = "SYSDATE" 

with OUTDEV, BEG_DT_TM, END_DT_TM
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare printdocument_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 257572, "PRINTDOCUMENT"))

  
/**************************************************************
; DVDev Start Coding
**************************************************************/

/**************************************************************/
; select cdi transaction log data 
execute cov_cpdi_act_audit $OUTDEV, $BEG_DT_TM, $END_DT_TM, ""


/**************************************************************/
; select final data 
select into $OUTDEV
	 CDI_TRANS_LOG_ID 		= t_rec->qual[d1.seq].cdi_trans_log_id
	,PERSON_ID				= t_rec->qual[d1.seq].person_id
	,PERFORMING_PRSNL		= trim(substring(1,100,t_rec->qual[d1.seq].performing_prsnl))
	,PERFORMING_POSITION	= trim(substring(1,100,t_rec->qual[d1.seq].performing_prsnl_pos))
	,PATIENT				= trim(substring(1,100,t_rec->qual[d1.seq].patient))
	;,DESCRIPTION			= trim(t_rec->qual[d1.seq].description)
	,ACTION_DT_TM			= trim(format(t_rec->qual[d1.seq].action_dt_tm,";;q"))
	,ACTION_WEEKDAY			= cnvtupper(format(t_rec->qual[d1.seq].action_dt_tm,"www;;d"))
	,ACTION_HOUR			= hour(t_rec->qual[d1.seq].action_dt_tm)
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
where
	t_rec->qual[d1.seq].reason_cd = printdocument_var
order by
	t_rec->qual[d1.seq].action_dt_tm
	
with nocounter, format, separator= " "

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript

end
go


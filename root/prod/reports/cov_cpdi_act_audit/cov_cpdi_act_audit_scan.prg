/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Todd A. Blanchard
	Date Written:		01/20/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_cpdi_act_audit_scan.prg
	Object name:		cov_cpdi_act_audit_scan
	Request #:			6874

	Program purpose:	CDI transaction log of scanned documents.

	Executing from:		CCL

 	Special Notes:		Calls base report: cov_cpdi_act_audit

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod	Mod Date	Developer				Comment
---	----------	--------------------	--------------------------------------

******************************************************************************/

drop program cov_cpdi_act_audit_scan:dba go
create program cov_cpdi_act_audit_scan:dba

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


record prsnl_rec (
	1 cnt					= i4
	1 list[*]
		2 person_id			= f8
)

record final_rec
(
	1 cnt					= i4
	1 list[*]
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
	 2 reason_cd			= f8
	 2 c_reason_disp		= vc
	 2 updt_dt_tm			= dq8
)
  
  
/**************************************************************
; DVDev Start Coding
**************************************************************/

/**************************************************************/
; select prsnl data
select into "NL:"
from 
	PRSNL per
where 
	per.name_last_key in ("CERNER", "SYSTEM")
	and per.name_first_key in ("CERNER", "CPDISERVICE")
	and per.end_effective_dt_tm > sysdate
	and per.active_ind = 1

head report
	prsnl_rec->cnt = 0
detail
	prsnl_rec->cnt = (prsnl_rec->cnt + 1)
	
	call alterlist(prsnl_rec->list, prsnl_rec->cnt)
	
 	prsnl_rec->list[prsnl_rec->cnt].person_id = per.person_id
 	
with nocounter


/**************************************************************/
; select cdi transaction log data 
execute cov_cpdi_act_audit $OUTDEV, $BEG_DT_TM, $END_DT_TM, ""


/**************************************************************/
; select cdi transaction log data 
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
	
plan d1
where
	t_rec->qual[d1.seq].reason_cd != printdocument_var
	and t_rec->qual[d1.seq].batch_name != patstring("WQM*")

head report
	final_rec->cnt = 0
detail
	found = 0
	
	for (i = 1 to prsnl_rec->cnt)
		if (t_rec->qual[d1.seq].performing_prsnl_id = prsnl_rec->list[i].person_id)
			found = 1
		endif
	endfor
	
	if (found = 0)
		final_rec->cnt = (final_rec->cnt + 1)
		
		call alterlist(final_rec->list, final_rec->cnt)
		
		final_rec->list[final_rec->cnt].cdi_trans_log_id 		= t_rec->qual[d1.seq].cdi_trans_log_id
		final_rec->list[final_rec->cnt].person_id				= t_rec->qual[d1.seq].person_id
		final_rec->list[final_rec->cnt].performing_prsnl		= t_rec->qual[d1.seq].performing_prsnl
		final_rec->list[final_rec->cnt].performing_prsnl_pos	= t_rec->qual[d1.seq].performing_prsnl_pos
		final_rec->list[final_rec->cnt].patient					= t_rec->qual[d1.seq].patient
		;final_rec->list[final_rec->cnt].description			= t_rec->qual[d1.seq].description
		final_rec->list[final_rec->cnt].action_dt_tm			= t_rec->qual[d1.seq].action_dt_tm
		final_rec->list[final_rec->cnt].ax_docid				= t_rec->qual[d1.seq].ax_docid
		final_rec->list[final_rec->cnt].batch_name				= t_rec->qual[d1.seq].batch_name
		final_rec->list[final_rec->cnt].c_cdi_queue_disp		= t_rec->qual[d1.seq].c_cdi_queue_disp
		final_rec->list[final_rec->cnt].create_dt_tm			= t_rec->qual[d1.seq].create_dt_tm
		final_rec->list[final_rec->cnt].device_name				= t_rec->qual[d1.seq].device_name
		final_rec->list[final_rec->cnt].document_type_alias		= t_rec->qual[d1.seq].document_type_alias
		final_rec->list[final_rec->cnt].doc_type				= t_rec->qual[d1.seq].doc_type
		final_rec->list[final_rec->cnt].financial_nbr			= t_rec->qual[d1.seq].financial_nbr
		final_rec->list[final_rec->cnt].mrn						= t_rec->qual[d1.seq].mrn
		final_rec->list[final_rec->cnt].page_cnt				= t_rec->qual[d1.seq].page_cnt
		final_rec->list[final_rec->cnt].parent_entity_name		= t_rec->qual[d1.seq].parent_entity_name
		final_rec->list[final_rec->cnt].patient_name			= t_rec->qual[d1.seq].patient_name
		final_rec->list[final_rec->cnt].c_reason_disp			= t_rec->qual[d1.seq].c_reason_disp
		final_rec->list[final_rec->cnt].updt_dt_tm				= t_rec->qual[d1.seq].updt_dt_tm
	endif
 	
with nocounter


/**************************************************************/
; select final data 
select into $OUTDEV
	 CDI_TRANS_LOG_ID 		= final_rec->list[d1.seq].cdi_trans_log_id
	,PERSON_ID				= final_rec->list[d1.seq].person_id
	,PERFORMING_PRSNL		= trim(substring(1,100,final_rec->list[d1.seq].performing_prsnl))
	,PERFORMING_POSITION	= trim(substring(1,100,final_rec->list[d1.seq].performing_prsnl_pos))
	,PATIENT				= trim(substring(1,100,final_rec->list[d1.seq].patient))
	;,DESCRIPTION			= trim(final_rec->list[d1.seq].description)
	,ACTION_DT_TM			= trim(format(final_rec->list[d1.seq].action_dt_tm,";;q"))
	,ACTION_WEEKDAY			= cnvtupper(format(final_rec->list[d1.seq].action_dt_tm,"www;;d"))
	,ACTION_HOUR			= hour(final_rec->list[d1.seq].action_dt_tm)
	,AX_DOCID				= final_rec->list[d1.seq].ax_docid
	,BATCH_NAME				= trim(substring(1,100,final_rec->list[d1.seq].batch_name))
	,C_CDI_QUEUE_DISP		= trim(substring(1,100,final_rec->list[d1.seq].c_cdi_queue_disp))
	,CREATE_DT_TM			= trim(format(final_rec->list[d1.seq].create_dt_tm,";;q"))
	,DEVICE_NAME			= trim(final_rec->list[d1.seq].device_name)
	,DOCUMENT_TYPE_ALIAS	= trim(substring(1,100,final_rec->list[d1.seq].document_type_alias))
	,DOC_TYPE				= trim(substring(1,100,final_rec->list[d1.seq].doc_type))
	,FINANCIAL_NBR			= trim(final_rec->list[d1.seq].financial_nbr)
	,MRN					= trim(final_rec->list[d1.seq].mrn)
	,PAGE_CNT				= final_rec->list[d1.seq].page_cnt
	,PARENT_ENTITY_NAME		= trim(substring(1,100,final_rec->list[d1.seq].parent_entity_name))
	,PATIENT_NAME			= trim(substring(1,100,final_rec->list[d1.seq].patient_name))
	,C_REASON_DISP			= trim(substring(1,100,final_rec->list[d1.seq].c_reason_disp))
	,UPDT_DT_TM				= trim(format(final_rec->list[d1.seq].updt_dt_tm,";;q"))
from	
	(dummyt d1 with seq=value(final_rec->cnt))
	
plan d1
	
order by
	final_rec->list[d1.seq].action_dt_tm
	
with nocounter, format, separator= " "

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

;call echorecord(prsnl_rec)
;call echorecord(t_rec)
;call echorecord(final_rec)
 
#exitscript

end
go


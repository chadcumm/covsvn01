/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/03/2022
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_BH_Consults.prg
	Object name:		cov_him_BH_Consults
	Request #:			12978
 
	Program purpose:	Lists behavioral health consultation documents
						for selected FIN.
 
	Executing from:		CCL
 
 	Special Notes:		Used by external apps.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	
******************************************************************************/
 
drop program cov_him_BH_Consults_TEST:DBA go
create program cov_him_BH_Consults_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, FIN
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare perform_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM"))
declare mdoc_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC"))
declare bh_consult_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "BEHAVIORALHEALTHCONSULTATION"))
declare covenant_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
; select data 
select into value($OUTDEV)
	person_id				= p.person_id
	, patient_name			= trim(p.name_full_formatted, 3)
	, fin					= trim(ea.alias, 3)
	, event					= trim(uar_get_code_display(ce.event_cd), 3)
	, result_dt_tm 			= ce.event_end_dt_tm "mm/dd/yyyy hh:mm:ss;;q"
	, provider_name			= per.name_full_formatted
 
from
	CLINICAL_EVENT ce 
	
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_var
		and cep.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
		
	, (inner join PRSNL per on per.person_id = cep.action_prsnl_id)
	
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = ce.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.alias = $FIN)
	
	, (inner join PERSON p on p.person_id = ce.person_id)

where
	ce.event_cd = bh_consult_var
	and ce.event_class_cd = mdoc_var
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
 
order by
	ce.event_end_dt_tm desc
	, cep.action_dt_tm

with nocounter, noheading, separator = "|", format, time = 60
;with nocounter, separator = " ", format, time = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

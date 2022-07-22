/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/11/2021
	Solution:			Revenue Cycle - Charge Services
	Source file name:	cov_cs_Order_Synonym_Extract.prg
	Object name:		cov_cs_Order_Synonym_Extract
	Request #:			6975
 
	Program purpose:	Select data from order catalog synonym table to be extracted 
						to files.
 
	Executing from:		CCL
 
 	Special Notes:		Output files:
 							order_synonym.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_cs_Order_Synonym_Extract:DBA go
create program cov_cs_Order_Synonym_Extract:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;declare hcpcs_vocab_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 400, "HCPCS"))
;declare cpt4_vocab_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 400, "CPT4"))
declare pharmacy_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "PHARMACY"))
declare cspecpharmacy_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "COMMUNITYSPECIALITYPHARMACY"))
declare primary_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 6011, "PRIMARY"))
declare ordcat_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 13016, "ORDCAT"))
declare taskassay_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 13016, "TASKASSAY"))
declare billcode_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 13019, "BILLCODE"))
declare hospitalcdmprof_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITALCDMPROF"))
declare hospitalcdmtech_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITALCDMTECH"))
declare hospitalcdmtechnocharge_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITALCDMTECHNOCHARGE"))
declare hospitalmedicarecdmtech_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITALMEDICARECDMTECH"))
;declare hcpcs_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HCPCS"))
;declare cpt_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "CPT"))
declare report_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14003, "REPORT"))

declare file_var				= vc with constant("order_synonym.csv")
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/ChargeServices/", file_var))
													 
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)

declare crlf					= vc with constant(build(char(13), char(10)))
declare lf						= vc with constant(char(10))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select data
;set modify filestream

select into value(temppath_var)
;select into value($OUTDEV)
	oc.catalog_cd
	, catalog 					= trim(uar_get_code_display(oc.catalog_cd), 3)
	, oc.catalog_type_cd
	, catalog_type 				= trim(uar_get_code_display(oc.catalog_type_cd), 3)
	, oc.activity_type_cd
	, activity_type 			= trim(uar_get_code_display(oc.activity_type_cd), 3)
	, oc.activity_subtype_cd
	, activity_subtype 			= trim(uar_get_code_display(oc.activity_subtype_cd), 3)
	, primary_mnemonic 			= trim(replace(replace(oc.primary_mnemonic, char(10), ""), char(13), ""), 3)

	, ocs.synonym_id
	, mnemonic 					= trim(replace(replace(ocs.mnemonic, char(10), ""), char(13), ""), 3)
	, mnemonic_type 			= trim(uar_get_code_display(ocs.mnemonic_type_cd), 3)
	, primary_flag				= evaluate(ocs.mnemonic_type_cd, primary_var, 1, 0)

	, bi.bill_item_id
	
	, bim.bill_item_mod_id
	, bill_code_schedule		= trim(uar_get_code_display(bim.key1_id), 3)
	, beg_effective_dt_tm		= bim.beg_effective_dt_tm "mm/dd/yyyy;;d"
	, end_effective_dt_tm		= bim.end_effective_dt_tm "mm/dd/yyyy;;d"
	, bill_code					= bim.key6
	, description				= trim(replace(replace(bim.key7, char(10), ""), char(13), ""), 3)
	
;	, cdm						= trim(replace(replace(bim.key6, crlf, ""), lf, ""), 3)
;	
;	, hcpcs						= trim(replace(replace(bim2.key6, crlf, ""), lf, ""), 3)
;	, hcpcs_key3_entity_name	= trim(bim2.key3_entity_name, 3)
;	, hcpcs_key3_id				= bim2.key3_id
;	, hcpcs_source_identifier	= trim(n2.source_identifier, 3)
;	, hcpcs_source_string		= trim(replace(replace(n2.source_string, crlf, ""), lf, ""), 3)
;	, hcpcs_source_vocabulary	= trim(uar_get_code_display(n2.source_vocabulary_cd), 3)
;	
;	, cpt						= trim(replace(replace(bim3.key6, crlf, ""), lf, ""), 3)
;	, cpt_key3_entity_name		= trim(bim3.key3_entity_name, 3)
;	, cpt_key3_id				= bim3.key3_id
;	, cpt_source_identifier		= trim(n3.source_identifier, 3)
;	, cpt_source_string			= trim(replace(replace(n3.source_string, crlf, ""), lf, ""), 3)
;	, cpt_source_vocabulary		= trim(uar_get_code_display(n3.source_vocabulary_cd), 3)
	
from
	ORDER_CATALOG oc
	
	, (left join ORDER_CATALOG_SYNONYM ocs on ocs.catalog_cd = oc.catalog_cd
		and ocs.catalog_type_cd = oc.catalog_type_cd
		and ocs.active_ind = 1)
	
	, (left join BILL_ITEM bi on bi.ext_parent_reference_id = oc.catalog_cd
		and bi.ext_parent_contributor_cd = ordcat_var
		and bi.ext_owner_cd = oc.activity_type_cd
		and bi.ext_child_reference_id != report_var
		and bi.ext_child_contributor_cd = taskassay_var
		and bi.active_ind = 1)

	, (left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
		and bim.bill_item_type_cd = billcode_var
		and bim.key1_id in (
			hospitalcdmprof_var, 
			hospitalcdmtech_var, 
			hospitalcdmtechnocharge_var, 
			hospitalmedicarecdmtech_var
		)
		and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bim.active_ind = 1)
		
;	, (left join BILL_ITEM_MODIFIER bim2 on bim2.bill_item_id = bi.bill_item_id
;		and bim2.bill_item_type_cd = billcode_var
;		and bim2.key1_id = hcpcs_var
;		and bim2.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
;		and bim2.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
;		and bim2.active_ind = 1)
;		
;	, (left join NOMENCLATURE n2 on n2.nomenclature_id = bim2.key3_id
;		and n2.source_vocabulary_cd = hcpcs_vocab_var)
; 
;	, (left join BILL_ITEM_MODIFIER bim3 on bim3.bill_item_id = bi.bill_item_id
;		and bim3.bill_item_type_cd = billcode_var
;		and bim3.key1_id = cpt_var
;		and bim3.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
;		and bim3.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
;		and bim3.active_ind = 1)
;		
;	, (left join NOMENCLATURE n3 on n3.nomenclature_id = bim3.key3_id
;		and n3.source_vocabulary_cd = cpt4_vocab_var
;		)
		
where
	1 = 1
	and oc.catalog_type_cd not in (pharmacy_var, cspecpharmacy_var)
	and oc.active_ind = 1
	
;	and oc.catalog_cd between 2909185.00 and 2909985.00 ;TODO: TEST
	
order by
	catalog_type
	, catalog
	, primary_flag desc
	, mnemonic
 
with nocounter, pcformat (^"^, ^|^, 1), format = stream, format
;with nocounter, format, separator = " ", time = 30
 
 
; copy file to AStream
set cmd = build2("cp ", temppath2_var, " ", filepath_var)
set len = size(trim(cmd))
 
call dcl(cmd, len, stat)
call echo(build2(cmd, " : ", stat))
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

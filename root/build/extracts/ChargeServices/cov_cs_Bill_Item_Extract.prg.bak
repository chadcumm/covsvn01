/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/19/2018
	Solution:			Revenue Cycle - Charge Services
	Source file name:	cov_cs_Bill_Item_Extract.prg
	Object name:		cov_cs_Bill_Item_Extract
	Request #:			3272
 
	Program purpose:	Selected data from tables to be extracted to files:
							- BILL_ITEM
							- BILL_ITEM_MODIFIER
 
	Executing from:		CCL
 
 	Special Notes:		Output files:
 							bill_item.csv
 							bill_item_modifier.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	12/04/2018	Todd A. Blanchard		Removed test parameter.
 										Auto-derive domain path for AStream.
 	12/14/2018	Todd A. Blanchard		Formatted date columns.
 
******************************************************************************/
 
drop program cov_cs_Bill_Item_Extract:DBA go
create program cov_cs_Bill_Item_Extract:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare file_bi_var			= vc with constant("bill_item.csv")
declare file_bim_var		= vc with constant("bill_item_modifier.csv")
 
declare temppath_var		= vc with constant("cer_temp:")
declare temppath_bi_var		= vc with constant(build(temppath_var, file_bi_var))
declare temppath_bim_var	= vc with constant(build(temppath_var, file_bim_var))
 
declare temppath2_var		= vc with constant("$cer_temp/")
declare temppath2_bi_var	= vc with constant(build(temppath2_var, file_bi_var))
declare temppath2_bim_var	= vc with constant(build(temppath2_var, file_bim_var))
 
declare filepath_var		= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													 "_cust/to_client_site/RevenueCycle/ChargeServices/"))
 
declare filepath_bi_var		= vc with constant(build(filepath_var, file_bi_var))
declare filepath_bim_var	= vc with constant(build(filepath_var, file_bim_var))
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)

declare crlf				= vc with constant(build(char(13), char(10)))
declare lf					= vc with constant(char(10))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select bill_item data
set modify filestream
 
select into value(temppath_bi_var)
	bi.bill_item_id
	, bi.ext_parent_reference_id
	, bi.ext_parent_contributor_cd
	, ext_parent_contributor_disp = trim(uar_get_code_display(bi.ext_parent_contributor_cd), 3)
	, bi.ext_child_reference_id
	, bi.ext_child_contributor_cd
	, ext_child_contributor_disp = trim(uar_get_code_display(bi.ext_child_contributor_cd), 3)
	, ext_description = replace(replace(bi.ext_description, crlf, ""), lf, "")
	, bi.ext_owner_cd
	, ext_owner_disp = trim(uar_get_code_display(bi.ext_owner_cd), 3)
	, bi.parent_qual_cd
	, parent_qual_disp = trim(uar_get_code_display(bi.parent_qual_cd), 3)
	, bi.charge_point_cd
	, charge_point_disp = trim(uar_get_code_display(bi.charge_point_cd), 3)
	, bi.physician_qual_cd
	, physician_qual_disp = trim(uar_get_code_display(bi.physician_qual_cd), 3)
	, bi.calc_type_cd
	, calc_type_disp = trim(uar_get_code_display(bi.calc_type_cd), 3)
	, bi.updt_cnt
	, updt_dt_tm = format(bi.updt_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, bi.updt_id
	, bi.updt_task
	, bi.updt_applctx
	, bi.active_ind
	, bi.active_status_cd
	, active_status_dt_tm = format(bi.active_status_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, bi.active_status_prsnl_id
	, beg_effective_dt_tm = format(bi.beg_effective_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, end_effective_dt_tm = format(bi.end_effective_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, ext_short_desc = replace(replace(bi.ext_short_desc, crlf, ""), lf, "")
	, bi.ext_parent_entity_name
	, bi.ext_child_entity_name
	, bi.careset_ind
	, bi.workload_only_ind
	, bi.parent_qual_ind
	, bi.misc_ind
	, bi.stats_only_ind
	, bi.child_seq
	, bi.num_hits
	, bi.late_chrg_excl_ind
	, bi.cost_basis_amt
	, bi.tax_ind
	, bi.logical_domain_id
	, bi.logical_domain_enabled_ind
	, bi.last_utc_ts
	, bi.ext_sub_owner_cd
	, ext_sub_owner_disp = trim(uar_get_code_display(bi.ext_sub_owner_cd), 3)
	, bi.txn_id_text
	, per.name_full_formatted
from
	BILL_ITEM bi
 
	, (left join PRSNL per on bi.updt_id = per.person_id)
 
with nocounter, pcformat (^"^, ^|^, 1), format = stream, format
 
 
/**************************************************************/
; select bill_item_modifier data
set modify filestream
 
select into value(temppath_bim_var)
	bim.bill_item_mod_id
	, bim.bill_item_id
	, bim.bill_item_type_cd
	, bill_item_type_disp = trim(uar_get_code_display(bim.bill_item_type_cd), 3)
	, key1 = replace(replace(bim.key1, crlf, ""), lf, "")
	, key2 = replace(replace(bim.key2, crlf, ""), lf, "")
	, key3 = replace(replace(bim.key3, crlf, ""), lf, "")
	, key4 = replace(replace(bim.key4, crlf, ""), lf, "")
	, key5 = replace(replace(bim.key5, crlf, ""), lf, "")
	, key6 = replace(replace(bim.key6, crlf, ""), lf, "")
	, key7 = replace(replace(bim.key7, crlf, ""), lf, "")
	, key8 = replace(replace(bim.key8, crlf, ""), lf, "")
	, key9 = replace(replace(bim.key9, crlf, ""), lf, "")
	, key10 = replace(replace(bim.key10, crlf, ""), lf, "")
	, key11 = replace(replace(bim.key11, crlf, ""), lf, "")
	, key12 = replace(replace(bim.key12, crlf, ""), lf, "")
	, key13 = replace(replace(bim.key13, crlf, ""), lf, "")
	, key14 = replace(replace(bim.key14, crlf, ""), lf, "")
	, key15 = replace(replace(bim.key15, crlf, ""), lf, "")
	, bim.updt_cnt
	, updt_dt_tm = format(bim.updt_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, bim.updt_id
	, bim.updt_task
	, bim.updt_applctx
	, bim.active_ind
	, bim.active_status_cd
	, active_status_dt_tm = format(bim.active_status_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, bim.active_status_prsnl_id
	, beg_effective_dt_tm = format(bim.beg_effective_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, end_effective_dt_tm = format(bim.end_effective_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
	, bim.key1_entity_name
	, bim.key2_entity_name
	, bim.key3_entity_name
	, bim.key4_entity_name
	, bim.key5_entity_name
	, bim.key1_id
	, key1_disp = trim(uar_get_code_display(bim.key1_id), 3)
	, bim.key2_id
	, key2_disp = trim(uar_get_code_display(bim.key2_id), 3)
	, bim.key3_id
	, key3_disp = trim(uar_get_code_display(bim.key3_id), 3)
	, bim.key4_id
	, key4_disp = trim(uar_get_code_display(bim.key4_id), 3)
	, bim.key5_id
	, key5_disp = trim(uar_get_code_display(bim.key5_id), 3)
	, bim.key11_id
	, key11_disp = trim(uar_get_code_display(bim.key11_id), 3)
	, bim.key12_id
	, key12_disp = trim(uar_get_code_display(bim.key12_id), 3)
	, bim.key13_id
	, key13_disp = trim(uar_get_code_display(bim.key13_id), 3)
	, bim.key14_id
	, key14_disp = trim(uar_get_code_display(bim.key14_id), 3)
	, bim.key15_id
	, key15_disp = trim(uar_get_code_display(bim.key15_id), 3)
	, bim.bim1_int
	, bim.bim2_int
	, bim.bim_ind
	, bim.bim1_nbr
	, bim.bim1_ind
	, bim.last_utc_ts
	, bim.txn_id_text
	, per.name_full_formatted
from
	BILL_ITEM_MODIFIER bim
 
	, (left join PRSNL per on bim.updt_id = per.person_id)
 
with nocounter, pcformat (^"^, ^|^, 1), format = stream, format
 
 
; copy bill_item file to AStream
set cmd = build2("cp ", temppath2_bi_var, " ", filepath_bi_var)
set len = size(trim(cmd))
 
call dcl(cmd, len, stat)
call echo(build2(cmd, " : ", stat))
 
 
; copy bill_item_modifier file to AStream
set cmd = build2("cp ", temppath2_bim_var, " ", filepath_bim_var)
set len = size(trim(cmd))
 
call dcl(cmd, len, stat)
call echo(build2(cmd, " : ", stat))
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

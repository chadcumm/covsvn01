/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		03/11/2019
	Solution:			Revenue Cycle - Charge Services
	Source file name:	cov_cs_PharmacyChargeMaster.prg
	Object name:		cov_cs_PharmacyChargeMaster
	Request #:			3681, 6011
 
	Program purpose:	Produces extract file of pharmacy data for
						Charge Master audit tools.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	04/18/2019	Todd A. Blanchard		Changed DispItemId value from
 										MEDICATION_DEFINITION.item_id to
 										BILL_ITEM.bill_item_id.
002	04/30/2019	Todd A. Blanchard		Adjusted criteria for BILL_ITEM_MODIFIER.
003	06/07/2019	Todd A. Blanchard		Adjusted criteria for BILL_ITEM_MODIFIER.
 
******************************************************************************/
 
drop program cov_cs_PharmacyChargeMaster:DBA go
create program cov_cs_PharmacyChargeMaster:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 2552552449.00
	, "Output To File" = 0                   ;* Output to file
 
with OUTDEV, facility, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare hcpcs1_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HCPCS"))
declare cpt1_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "CPT"))
declare hosp1_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITAL340BTECHJGTB"))
declare hosp2_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITAL340BTECHMODIFIER"))
declare hosp3_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITAL340BTECHORPHANED"))
declare hosp4_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITAL340BTECHSTANDARD"))
declare brand_name_var			= f8 with constant(uar_get_code_by("MEANING", 11000, "BRAND_NAME"))
declare cdm_var					= f8 with constant(uar_get_code_by("MEANING", 11000, "CDM"))
declare desc_var				= f8 with constant(uar_get_code_by("MEANING", 11000, "DESC"))
declare desc_short_var			= f8 with constant(uar_get_code_by("MEANING", 11000, "DESC_SHORT"))
declare generic_name_var		= f8 with constant(uar_get_code_by("MEANING", 11000, "GENERIC_NAME"))
declare hcpcs2_var           	= f8 with constant(uar_get_code_by("MEANING", 11000, "HCPCS"))
declare inner_ndc_var			= f8 with constant(uar_get_code_by("MEANING", 11000, "INNER_NDC"))
declare ndc_var					= f8 with constant(uar_get_code_by("MEANING", 11000, "NDC"))
declare pyxis_var           	= f8 with constant(uar_get_code_by("MEANING", 11000, "PYXIS"))
declare med_def_flex_var		= f8 with constant(uar_get_code_by("MEANING", 13016, "MED DEF FLEX"))
declare awp_var					= f8 with constant(uar_get_code_by("MEANING", 4050, "AWP"))
declare syspkgtyp_var			= f8 with constant(uar_get_code_by("MEANING", 4062, "SYSPKGTYP"))
declare system_var				= f8 with constant(uar_get_code_by("MEANING", 4062, "SYSTEM"))
declare inpatient_var			= f8 with constant(uar_get_code_by("MEANING", 4500, "INPATIENT"))
declare primary_var				= f8 with constant(uar_get_code_by("MEANING", 6011, "PRIMARY"))
 
declare novalue					= vc with constant("Not Available")
declare op_facility_var			= c2 with noconstant("")
declare num						= i4 with noconstant(0)
declare crlf					= vc with constant(build(char(13), char(10)))
 
declare file_dt_tm				= vc with constant(format(sysdate, "yyyymmddhhmm;;d"))
declare file_var				= vc with constant(build("pharmacy_extract_", file_dt_tm, ".csv"))
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/ChargeServices/", file_var))
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record pharm_data (
	1	pharm_cnt			= i4
	1	list[*]
		2	cdm				= c200
		2	default_dose	= c255
		2	item_id			= f8
		2	facility		= c40
		2	form			= c40
		2	given_strength	= c25
		2	primary_ndc		= c200
		2	awp				= f8
		2	description		= c200
		2	brand_name		= c200
		2	price_schedule	= c200
		2	generic_name	= c200
		2	cs_qcf			= f8
		2	cs_hcpcs		= c200
)
 
 
/**************************************************************/
; select pharmacy data
select distinct into "NL:"
from
	MEDICATION_DEFINITION md
 
	, (inner join MED_DISPENSE mdisp on mdisp.item_id = md.item_id
    	and mdisp.pharmacy_type_cd = inpatient_var)
 
	, (inner join MED_DEF_FLEX mdf on mdf.item_id = md.item_id
	    and mdf.flex_type_cd = system_var
	    and mdf.pharmacy_type_cd = inpatient_var
	    and mdf.active_ind = 1)
 
	, (inner join MED_FLEX_OBJECT_IDX mfoi on mfoi.med_def_flex_id = mdf.med_def_flex_id
    	and mfoi.parent_entity_name = "MED_OE_DEFAULTS")
 
	, (inner join MED_OE_DEFAULTS mod on mod.med_oe_defaults_id = mfoi.parent_entity_id)
 
	, (inner join MED_IDENTIFIER mi on mi.item_id = md.item_id
	    and mi.primary_ind = 1
	    and mi.med_product_id = 0
	    and mi.med_identifier_type_cd = desc_var
	    and mi.pharmacy_type_cd = inpatient_var
		and mi.active_ind = 1)
 
	, (inner join MED_IDENTIFIER mi2 on mi2.item_id = md.item_id
	    and mi2.med_identifier_type_cd = ndc_var
	    and mi2.active_ind = 1)
 
	, (inner join MED_FLEX_OBJECT_IDX mfoi3 on mfoi3.parent_entity_id = mi2.med_product_id
		and mfoi3.sequence = 1)
 
	, (left join MED_COST_HX mch on mch.med_product_id = mi2.med_product_id
	    and mch.cost_type_cd = awp_var
	    and mch.active_ind = 1)
 
	, (inner join MED_DEF_FLEX mdf2 on mdf2.item_id = md.item_id
	    and mdf2.flex_type_cd = syspkgtyp_var
	    and mdf2.pharmacy_type_cd = inpatient_var
	    and mdf2.active_ind = 1)
 
	, (inner join MED_FLEX_OBJECT_IDX mfoi2 on mfoi2.med_def_flex_id = mdf2.med_def_flex_id)
 
	, (inner join CODE_VALUE cv1 on cv1.code_value = mfoi2.parent_entity_id
	    and cv1.code_set = 220
	    and operator(cv1.code_value, op_facility_var, $facility)
	    and cv1.cdf_meaning = "FACILITY")
 
	, (inner join ORDER_CATALOG_ITEM_R ocir on ocir.item_id = md.item_id)
 
	, (left join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = mod.ord_as_synonym_id)
 
	, (left join ORDER_CATALOG_SYNONYM ocs2 on ocs2.catalog_cd = ocir.catalog_cd
   		and ocs2.mnemonic_type_cd = primary_var)
 
	, (left join PRICE_SCHED p on p.price_sched_id = mod.price_sched_id)
 
	, (inner join NOMENCLATURE n on n.nomenclature_id = md.mdx_gfc_nomen_id)
 
	, (inner join ORDER_CATALOG oc on oc.catalog_cd = ocir.catalog_cd)
 
	, (left join MED_IDENTIFIER mi3 on mi3.item_id = md.item_id
	    and mi3.med_identifier_type_cd = pyxis_var
	    and mi3.active_ind = 1)
 
	, (left join MED_IDENTIFIER mi5 on mi5.item_id = mi.item_id
	    and mi5.primary_ind = 1
	    and mi5.med_product_id = 0
	    and mi5.med_identifier_type_cd = brand_name_var
	    and mi5.active_ind = 1)
 
	, (left join MED_IDENTIFIER mi6 on mi6.item_id = mi.item_id
	    and mi6.primary_ind = 1
	    and mi6.med_product_id = 0
	    and mi6.med_identifier_type_cd = cdm_var
	    and mi6.active_ind = 1)
 
	, (left join MED_IDENTIFIER mi7 on mi7.item_id = mi.item_id
	    and mi7.primary_ind = 1
	    and mi7.med_product_id = 0
	    and mi7.med_identifier_type_cd = generic_name_var
	    and mi7.active_ind = 1)
 
	, (left join MED_IDENTIFIER mi8 on mi8.item_id = mi.item_id
	    and mi8.primary_ind = 1
	    and mi8.med_product_id = 0
	    and mi8.med_identifier_type_cd = hcpcs2_var
	    and mi8.active_ind = 1)
 
	, (left join MED_IDENTIFIER mi9 on mi9.item_id = mi.item_id
	    and mi9.primary_ind = 1
	    and mi9.med_product_id = 0
	    and mi9.med_identifier_type_cd = desc_short_var
	    and mi9.active_ind = 1)
 
	, (left join MED_IDENTIFIER mi4 on mi4.item_id = mi2.item_id
	    and mi4.med_identifier_type_cd = inner_ndc_var
	    and mi4.med_product_id = mi2.med_product_id
	    and mi4.active_ind = 1)
 
	, (inner join MED_PACKAGE_TYPE mpt on mpt.med_package_type_id = mdf2.med_package_type_id)
 
	, (left join BILL_ITEM bi on bi.ext_parent_reference_id = mdf.med_def_flex_id
		and bi.ext_parent_contributor_cd = med_def_flex_var
		and bi.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bi.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bi.active_ind = 1)
 
 	;002 ;003
	, (left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
		and bim.key1_id in (hcpcs1_var, cpt1_var, hosp1_var, hosp2_var, hosp3_var, hosp4_var)
		and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bim.active_ind = 1)
 
where
	md.item_id > 0.0
 
order by
	cnvtupper(oc.primary_mnemonic)
	, mi.value_key
	, mfoi3.sequence
	, md.item_id
 
 
; populate pharm_data record structure
head report
	cnt = 0
 
	call alterlist(pharm_data->list, 100)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(pharm_data->list, cnt + 9)
	endif
 
	pharm_data->pharm_cnt					= cnt
	pharm_data->list[cnt].cdm				= trim(cnvtalphanum(mi6.value, 1), 3)
	pharm_data->list[cnt].default_dose		= evaluate2(
											    if (mod.strength_unit_cd > 0)
											    	concat(trim(format(mod.strength, "#######.####;T(1)"), 7), " ",
											    		uar_get_code_display(mod.strength_unit_cd))
											    elseif (mod.volume_unit_cd > 0)
											    	concat(trim(format(mod.volume, "#######.####;T(1)"), 7), " ",
											    		uar_get_code_display(mod.volume_unit_cd))
											    else
											    	trim(mod.freetext_dose, 3)
											    endif
											   )
	pharm_data->list[cnt].item_id			= bi.bill_item_id ;001
	pharm_data->list[cnt].facility			= trim(cv1.display, 3)
	pharm_data->list[cnt].form				= trim(uar_get_code_display(md.form_cd), 3)
	pharm_data->list[cnt].given_strength	= trim(md.given_strength, 3)
	pharm_data->list[cnt].primary_ndc		= trim(mi2.value, 3)
	pharm_data->list[cnt].awp				= mch.cost
	pharm_data->list[cnt].description		= trim(mi.value, 3)
	pharm_data->list[cnt].brand_name		= trim(mi5.value, 3)
	pharm_data->list[cnt].price_schedule	= trim(replace(replace(p.price_sched_desc, char(10), ""), char(13), ""), 3)
	pharm_data->list[cnt].generic_name		= trim(mi7.value, 3)
	pharm_data->list[cnt].cs_qcf			= bim.bim1_nbr
	pharm_data->list[cnt].cs_hcpcs			= trim(bim.key6, 3)
 
foot report
	call alterlist(pharm_data->list, cnt)
 
WITH nocounter, time = 60
 
 
/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1, 0), format = stream, format, time = 240
else
	with nocounter, separator = " ", format, time = 240
endif
 
into value(output_var)
	FormularyCode				= pharm_data->list[d1.seq].cdm
	, DispenseSize 				= pharm_data->list[d1.seq].default_dose
	, DispItemID 				= pharm_data->list[d1.seq].item_id
;	, ServiceType				= " "
	, Facility					= pharm_data->list[d1.seq].facility
;	, InvItemID					= " "
	, Form						= pharm_data->list[d1.seq].form
	, Strength					= pharm_data->list[d1.seq].given_strength
;	, Solution					= " "
;	, NdcProductID				= " "
;	, NDCItemID					= " "
	, NDC						= pharm_data->list[d1.seq].primary_ndc
	, CurrentAWP				= pharm_data->list[d1.seq].awp "#####.###"
;	, ProdProductID				= " "
	, FIMDescription			= pharm_data->list[d1.seq].description
	, CurrentBrandName			= pharm_data->list[d1.seq].brand_name
;	, HCPCSCode					= " "
	, PricingFormula			= pharm_data->list[d1.seq].price_schedule
	, GenericName				= pharm_data->list[d1.seq].generic_name
	, QCF						= pharm_data->list[d1.seq].cs_qcf "#####.#####"
	, HCPCS						= pharm_data->list[d1.seq].cs_hcpcs
 
from
	(dummyt d1 with seq = value(pharm_data->pharm_cnt))
 
plan d1
 
where
	size(pharm_data->list[d1.seq].cdm) > 0
 
order by
	d1.seq
 
 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
;call echorecord(pharm_data)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

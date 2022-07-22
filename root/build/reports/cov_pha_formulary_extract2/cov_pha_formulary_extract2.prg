/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:				Translated
	Date Written:
	Solution:			Pharmacy
	Source file name:  	cov_pha_Formulary_Extract2.prg
	Object name:		cov_pha_Formulary_Extract2
	CR#:
 
	Program purpose:
	Executing from:		CCL
  	Special Notes:		Total revised. Added record structure to make mods.
 
******************************************************************************
*   GENERATED MODIFICATION CONTROL LOG
*
*   Revision #   Mod Date    Developer             Comment
*   -----------  ----------  --------------------  ----------------------------
*	001			 OCT 2019	 Dan Herren			   CR6297 (Revised/Formatted)
*	002			 JUL 2021	 Dan Herren			   CR 10862
*
*
*******************************************************************************/
 
drop program cov_pha_formulary_extract2:dba GO
create program cov_pha_formulary_extract2:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0
	, "Primary NDC Extract Only" = "Yes"
	, "Medication   (Optional)" = ""         ;*   <<<<<   WILDCARD ( * )   >>>>>
	, "Drug Class 1 (Optional)" = ""         ;*   <<<<<   WILDCARD ( * )   >>>>>
	, "Drug Class 2 (Optional)" = ""         ;*   <<<<<   WILDCARD ( * )   >>>>>
	, "Drug Class 3 (Optional)" = ""         ;*   <<<<<   WILDCARD ( * )   >>>>>
	;<<hidden>>"" = ""
	;<<hidden>>"" = ""
	;<<hidden>>"" = ""
	;<<hidden>>"" = ""
 
with OUTDEV, FACILITY, ALLNDC, MEDICATION, DRUGCLASS1, DRUGCLASS2, DRUGCLASS3
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare MED_VAR        = vc with noconstant(fillstring(1000," ")) ;001
declare DRUGCLASS1_VAR = vc with noconstant(fillstring(1000," ")) ;001
declare DRUGCLASS2_VAR = vc with noconstant(fillstring(1000," ")) ;001
declare DRUGCLASS3_VAR = vc with noconstant(fillstring(1000," ")) ;001
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
record rec(
	1 rec_cnt						= i4
	1 list[*]
		2 facility      			= vc
		2 med_id   					= vc
		2 item_id	    			= f8
		2 description   			= vc
		2 order_catalog_primary		= vc
		2 mmdc 						= vc
		2 oc_cki					= vc
		2 drug_formulation			= vc
		2 primary_ndc           	= vc
		2 inner_ndc      			= vc
		2 default_route       		= vc
		2 form						= vc
		2 strength     				= f8
		2 strength_unit    			= vc
		2 volume  					= f8
		2 volume_unit				= vc
		2 given_strength			= vc
		2 divisible_ind				= vc
		2 infinite_divisible 		= vc
		2 min_divisible 			= f8
		2 default_order_type 		= vc
		2 med_filter 				= i2
		2 int_filter 				= i2
		2 cont_filter 				= i2
		2 ordered_as_synonym 		= vc
		2 dispense_category 		= vc
		2 include_total_volume 		= vc
		2 default_dose 				= vc
		2 default_freq 				= vc
		2 duration 					= f8
		2 duration_unit 			= vc
		2 stop_type 				= vc
		2 default_infuse_over 		= f8
		2 default_infuse_over_unit	= vc
		2 brand_name 				= vc
		2 cdm 						= vc
		2 price_schedule 			= vc
		2 dispense_qty 				= f8
		2 dispense_qty_unit 		= vc
		2 dispense_factor 			= f8
		2 gpo						= f8 ;002
		2 awp 						= f8
		2 CS_HCPCS 					= vc
		2 CS_QCF 					= f8
		2 bill_item_id 				= f8
		2 generic_name 				= vc
		2 rx_mnemonic 				= vc
		2 legal_status 				= vc
		2 ndc 						= vc
		2 formulary_status 			= vc
		2 price_schedule 			= vc
		2 rx_mnemonic 				= vc
		2 value_key					= vc
		2 therapeutic_class			= vc ;001
		2 drug_identifier			= vc ;001
		2 drug_class_code1			= vc ;001
		2 drug_class_code2			= vc ;001
		2 drug_class_code3			= vc ;001
		2 drug_class_description1	= vc ;001
		2 drug_class_description2	= vc ;001
		2 drug_class_description3	= vc ;001
)
 
;==========================================================================================
;SET SEARCH VARIABLES  ;BEGIN 001
;==========================================================================================
if($MEDICATION = "")
	set MED_VAR = "1=1"
else
	set MED_VAR = build2("cnvtlower(rec->list[d.seq].order_catalog_primary) = '", $MEDICATION,"'")
endif
 
if($DRUGCLASS1 = "")
	set DC1_VAR = "1=1"
else
	set DC1_VAR = build2("cnvtlower(rec->list[d.seq].drug_class_description1) = '", $DRUGCLASS1,"'")
endif
 
if($DRUGCLASS2 = "")
	set DC2_VAR = "1=1"
else
	set DC2_VAR = build2("cnvtlower(rec->list[d.seq].drug_class_description2) = '", $DRUGCLASS2,"'")
endif
 
if($DRUGCLASS3 = "")
	set DC3_VAR = "1=1"
else
	set DC3_VAR = build2("cnvtlower(rec->list[d.seq].drug_class_description3) = '", $DRUGCLASS3,"'")
endif
;---- END 001
 
 
if ($ALLNDC = "Yes")
 
	select into "NL:"
		 med_id 					= trim(mi3.value ,1)
		,item_id					= md.item_id
	   	,description 				= trim(mi.value ,1)
	   	,order_catalog_primary 		= trim(oc.primary_mnemonic)
		,oc_cki						= evaluate2(
										if(substring(1,8,oc.cki) = "MUL.ORD!") trim(substring(9, textlen(oc.cki), oc.cki))
										else ""
										endif) ;001 oc_cki link to MLTM_CATEGORY_DRUG_XREF table
	   	,mmdc 						= md.cki
	   	,drug_formulation 			= n.source_string
	   	,primary_ndc 				= mi2.value
	   	,inner_ndc 					= mi4.value
	   	,default_route 				= uar_get_code_display(mod.route_cd)
	   	,form 						= uar_get_code_display(md.form_cd)
	   	,strength 					= mdisp.strength
	   	,strength_unit 				= uar_get_code_display(mdisp.strength_unit_cd)
	   	,volume 					= mdisp.volume
	   	,volume_unit 				= uar_get_code_display(mdisp.volume_unit_cd)
	   	,given_strength 			= md.given_strength
	   	,divisible_ind 				= evaluate(mdisp.divisible_ind ,0, "No" ,1, "Yes")
	   	,infinite_divisible 		= evaluate(mdisp.infinite_div_ind ,0, "No" ,1, "Yes")
	   	,min_divisible 				= mdisp.base_issue_factor
	   	,default_order_type 		= evaluate(cnvtint(mdisp.oe_format_flag), cnvtint(0), "None" ,cnvtint(1),
	   									"Medication" ,cnvtint(2), "Continuous", cnvtint(3), "Intermittent", "Indeterminate")
	   	,med_filter 				= mdisp.med_filter_ind
	   	,int_filter 				= mdisp.intermittent_filter_ind
	   	,cont_filter 				= mdisp.continuous_filter_ind
	   	,ordered_as_synonym 		= ocs.mnemonic
	   	,dispense_category 			= uar_get_code_display(mod.dispense_category_cd)
	   	,include_total_volume 		= evaluate(cnvtint(mdisp.used_as_base_ind) ,cnvtint(0), "Never" ,
	    								cnvtint(1), "Sometimes", cnvtint(2), "Always")
	   	,default_dose 				= evaluate2(
									    if((mod.strength_unit_cd > 0)) concat(trim(format(mod.strength, "#######.####;T(1)") ,7)
									     , " " ,uar_get_code_display(mod.strength_unit_cd))
									    elseif((mod.volume_unit_cd > 0)) concat(trim(format(mod.volume, "#######.####;T(1)") ,7)
									     , " " ,uar_get_code_display(mod.volume_unit_cd))
									    else mod.freetext_dose
									    endif)
	   	,default_freq 				= uar_get_code_display(mod.frequency_cd)
	   	,duration 					= mod.duration
	   	,duration_unit 				= uar_get_code_display(mod.duration_unit_cd)
	   	,stop_type 					= uar_get_code_display(mod.stop_type_cd)
	   	,default_infuse_over 		= evaluate(mod.infuse_over, -1, 0, mod.infuse_over)
	   	,default_infuse_over_unit	= uar_get_code_display(mod.infuse_over_cd)
	   	,brand_name 				= trim(mi5.value, 1)
	   	,cdm 						= trim(mi6.value, 1)
	   	,price_schedule 			= trim(replace(replace(p.price_sched_desc, char(10), ""), char(13), ""))
	   	,dispense_qty 				= mpt.dispense_qty
	   	,dispense_qty_unit 			= uar_get_code_display(mpt.uom_cd)
	   	,dispense_factor 			= mdisp.dispense_factor
	   	,gpo 						= mch2.cost "#####.#####" ;002
	   	,awp 						= mch.cost "#####.#####"
	  	,CS_HCPCS 					= trim(bim.key6)
	   	,CS_QCF 					= bim.bim1_nbr "#####.#####"
	   	,bill_item_id				= bi.bill_item_id
	   	,generic_name 				= trim(mi7.value ,1)
	   	,rx_mnemonic 				= trim(mi9.value ,1)
	   	,legal_status 				= uar_get_code_display(mdisp.legal_status_cd)
	   	,facility 					= cv1.display
		,value_key					= mi.value_key
 
	from MEDICATION_DEFINITION 	md
 
	,(inner join MED_DISPENSE mdisp on mdisp.item_id = md.item_id
    	and mdisp.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT")))
 
    ,(inner join MED_DEF_FLEX mdf on mdf.item_id = md.item_id
    	and mdf.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
   		and mdf.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    	and mdf.active_ind = 1)
 
    ,(inner join MED_FLEX_OBJECT_IDX mfoi on mfoi.med_def_flex_id = mdf.med_def_flex_id
    	and mfoi.parent_entity_name = "MED_OE_DEFAULTS")
 
    ,(inner join MED_OE_DEFAULTS mod on mod.med_oe_defaults_id = mfoi.parent_entity_id)
 
    ,(inner join MED_IDENTIFIER mi on mi.item_id = md.item_id
    	and mi.primary_ind = 1
    	and mi.med_product_id = 0
    	and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    	and mi.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    	and mi.active_ind = 1)
 
    ,(inner join MED_IDENTIFIER mi2 on mi2.item_id = md.item_id
    	and mi2.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "NDC"))
    	and mi2.active_ind = 1)
 
    ,(inner join MED_FLEX_OBJECT_IDX mfoi3 on mfoi3.parent_entity_id = mi2.med_product_id
   		and mfoi3.sequence = 1)
 
    ,(left join MED_COST_HX mch on mch.med_product_id = mi2.med_product_id
   		and mch.cost_type_cd = value(uar_get_code_by("MEANING", 4050, "AWP"))
    	and mch.active_ind = 1)
 
    ,(left join MED_COST_HX mch2 on mch2.med_product_id = mi2.med_product_id ;002
   		and mch2.cost_type_cd = value(uar_get_code_by("DISPLAY", 4050, "GPO"))
    	and mch2.active_ind = 1)
 
    ,(inner join MED_DEF_FLEX mdf2 on mdf2.item_id = md.item_id
    	and mdf2.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSPKGTYP"))
    	and mdf2.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    	and mdf2.active_ind = 1)
 
    ,(inner join MED_FLEX_OBJECT_IDX mfoi2 on mfoi2.med_def_flex_id = mdf2.med_def_flex_id)
 
    ,(inner join CODE_VALUE cv1 on cv1.code_value = mfoi2.parent_entity_id
    	and cv1.code_set = 220
    	and cv1.code_value = $FACILITY
    	and cv1.cdf_meaning = "FACILITY")
 
    ,(inner join ORDER_CATALOG_ITEM_R ocir on ocir.item_id = md.item_id)
 
    ,(left join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = mod.ord_as_synonym_id)
 
    ,(left join ORDER_CATALOG_SYNONYM ocs2 on ocs2.catalog_cd = ocir.catalog_cd
    	and ocs2.mnemonic_type_cd = value(uar_get_code_by("MEANING", 6011, "PRIMARY")))
 
    ,(left join PRICE_SCHED p on p.price_sched_id = mod.price_sched_id)
 
    ,(inner join NOMENCLATURE n on n.nomenclature_id = md.mdx_gfc_nomen_id)
 
    ,(inner join ORDER_CATALOG oc on oc.catalog_cd = ocir.catalog_cd)
 
    ,(left join MED_IDENTIFIER mi3 on mi3.item_id = md.item_id
		and mi3.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "PYXIS"))
    	and mi3.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi5 on mi5.item_id = mi.item_id
    	and mi5.primary_ind = 1
    	and mi5.med_product_id = 0
    	and mi5.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "BRAND_NAME"))
    	and mi5.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi6 on mi6.item_id = mi.item_id
    	and mi6.primary_ind = 1
    	and mi6.med_product_id = 0
    	and mi6.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "CDM"))
    	and mi6.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi7 on mi7.item_id = mi.item_id
    	and mi7.primary_ind = 1
    	and mi7.med_product_id = 0
    	and mi7.med_identifier_type_cd = value(uar_get_code_by("MEANING",11000,"GENERIC_NAME"))
    	and mi7.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi8 on mi8.item_id = mi.item_id
    	and mi8.primary_ind = 1
    	and mi8.med_product_id = 0
    	and mi8.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "HCPCS"))
    	and mi8.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi9 on mi9.item_id = mi.item_id
    	and mi9.primary_ind = 1
    	and mi9.med_product_id = 0
    	and mi9.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000 , "DESC_SHORT"))
    	and mi9.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi4 on mi4.item_id = mi2.item_id
    	and mi4.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "INNER_NDC"))
    	and mi4.med_product_id = mi2.med_product_id
    	and mi4.active_ind = 1)
 
	,(inner join MED_PACKAGE_TYPE mpt on mpt.med_package_type_id = mdf2.med_package_type_id)
 
	,(left join BILL_ITEM bi on bi.ext_parent_reference_id = mdf.med_def_flex_id
		and bi.ext_parent_contributor_cd = value(UAR_GET_CODE_BY("MEANING", 13016, "MED DEF FLEX"))
		and bi.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bi.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bi.active_ind = 1)
 
	,(left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
    	and bim.key1_id = value(UAR_GET_CODE_BY("DISPLAYKEY",14002, "HCPCS"))
    	and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
    	and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
    	and bim.active_ind = 1)
 
   	order by cnvtupper(oc.primary_mnemonic), mi.value_key, md.item_id
 
	head report
		cnt  = 0
 
	detail
	 	cnt = cnt + 1
		call alterlist(rec->list, cnt)
 
		rec->rec_cnt							= cnt
		rec->list[cnt].med_id 					= med_id
		rec->list[cnt].item_id 					= item_id
		rec->list[cnt].description 				= description
		rec->list[cnt].order_catalog_primary 	= order_catalog_primary
		rec->list[cnt].oc_cki					= oc_cki
		rec->list[cnt].mmdc 					= mmdc
		rec->list[cnt].drug_formulation 		= drug_formulation
		rec->list[cnt].primary_ndc 				= primary_ndc
		rec->list[cnt].inner_ndc 				= inner_ndc
		rec->list[cnt].default_route 			= default_route
		rec->list[cnt].form 					= form
		rec->list[cnt].strength 				= strength
		rec->list[cnt].strength_unit 			= strength_unit
		rec->list[cnt].volume 					= volume
		rec->list[cnt].volume_unit 				= volume_unit
		rec->list[cnt].default_order_type 		= default_order_type
		rec->list[cnt].med_filter 				= med_filter
		rec->list[cnt].int_filter 				= int_filter
		rec->list[cnt].cont_filter 				= cont_filter
		rec->list[cnt].ordered_as_synonym 		= ordered_as_synonym
		rec->list[cnt].dispense_category 		= dispense_category
		rec->list[cnt].include_total_volume 	= include_total_volume
		rec->list[cnt].default_dose 			= default_dose
		rec->list[cnt].default_freq 			= default_freq
		rec->list[cnt].duration 				= duration
		rec->list[cnt].duration_unit 			= duration_unit
		rec->list[cnt].stop_type 				= stop_type
		rec->list[cnt].default_infuse_over 		= default_infuse_over
		rec->list[cnt].default_infuse_over_unit	= default_infuse_over_unit
		rec->list[cnt].brand_name 				= brand_name
		rec->list[cnt].cdm 						= cdm
		rec->list[cnt].price_schedule 			= price_schedule
		rec->list[cnt].dispense_qty 			= dispense_qty
		rec->list[cnt].dispense_qty_unit 		= dispense_qty_unit
		rec->list[cnt].dispense_factor 			= dispense_factor
		rec->list[cnt].gpo 						= gpo ;002
		rec->list[cnt].awp 						= awp
		rec->list[cnt].CS_HCPCS 				= CS_HCPCS
		rec->list[cnt].CS_QCF 					= CS_QCF
		rec->list[cnt].bill_item_id 			= bill_item_id
		rec->list[cnt].legal_status 			= legal_status
		rec->list[cnt].facility       			= facility
		rec->list[cnt].given_strength 			= given_strength
		rec->list[cnt].divisible_ind 			= divisible_ind
		rec->list[cnt].infinite_divisible 		= infinite_divisible
		rec->list[cnt].min_divisible 			= min_divisible
		rec->list[cnt].generic_name 			= generic_name
		rec->list[cnt].rx_mnemonic 				= rx_mnemonic
		rec->list[cnt].value_key				= value_key
 
   	with nocounter ,separator = " " ,format
 
else
 
	select into "NL:"
		 med_id 					= trim(mi3.value ,1)
	   	,item_id					= md.item_id
	   	,description 				= trim(mi.value ,1)
	   	,order_catalog_primary 		= oc.primary_mnemonic
		,oc_cki						= evaluate2(
										if(substring(1,8,oc.cki) = "MUL.ORD!") trim(substring(9, textlen(oc.cki), oc.cki))
										else ""
										endif)
	   	,mmdc 						= md.cki
	   	,drug_formulation 			= n.source_string
	   	,primary_ndc 				= evaluate(mfoi3.sequence, 1, "X", "")
	   	,ndc 						= mi2.value
	   	,inner_ndc 					= mi4.value
	   	,default_route 				= uar_get_code_display(mod.route_cd)
	   	,form 						= uar_get_code_display(md.form_cd)
	   	,strength 					= mdisp.strength
	   	,strength_unit 				= uar_get_code_display(mdisp.strength_unit_cd)
	   	,volume 					= mdisp.volume
	   	,volume_unit 				= uar_get_code_display(mdisp.volume_unit_cd)
	   	,default_order_type 		= evaluate(cnvtint(mdisp.oe_format_flag), cnvtint(0), "None", cnvtint(1)
						     			,"Medication", cnvtint(2), "Continuous", cnvtint(3), "Intermittent", "Indeterminate")
	   	,med_filter 				= mdisp.med_filter_ind
	   	,int_filter 				= mdisp.intermittent_filter_ind
	   	,cont_filter 				= mdisp.continuous_filter_ind
	   	,ordered_as_synonym 		= ocs.mnemonic
	   	,dispense_category 			= uar_get_code_display(mod.dispense_category_cd)
	   	,formulary_status 			= uar_get_code_display(mdisp.formulary_status_cd)
	   	,include_total_volume 		= evaluate(cnvtint(mdisp.used_as_base_ind), cnvtint(0), "Never",
	    								cnvtint(1), "Sometimes", cnvtint(2), "Always")
	   	,default_dose 				= evaluate2(
									    if((mod.strength_unit_cd > 0)) concat(trim(format(mod.strength, "#######.####;T(1)"), 7)
									    ,  " ", uar_get_code_display(mod.strength_unit_cd))
									    elseif((mod.volume_unit_cd > 0)) concat(trim(format(mod.volume, "#######.####;T(1)"), 7)
									    ,  " ", uar_get_code_display(mod.volume_unit_cd))
									    else mod.freetext_dose
									    endif)
	   	,default_freq 				= uar_get_code_display(mod.frequency_cd)
	   	,duration 					= mod.duration
	   	,duration_unit 				= uar_get_code_display(mod.duration_unit_cd)
	   	,stop_type 					= uar_get_code_display(mod.stop_type_cd)
	   	,default_infuse_over 		= evaluate(mod.infuse_over, -1, 0, mod.infuse_over)
	   	,default_infuse_over_unit	= uar_get_code_display(mod.infuse_over_cd)
	   	,price_schedule 			= p.price_sched_desc
	   	,brand_name 				= trim(mi5.value, 1)
	   	,cdm 						= trim(mi6.value, 1)
	   	,generic_name 				= trim(mi7.value, 1)
	   	,rx_mnemonic 				= trim(mi9.value, 1)
	   	,cdm 						= trim(mi6.value, 1)
	   	,price_schedule 			= p.price_sched_desc
	   	,dispense_qty 				= mpt.dispense_qty
	   	,dispense_qty_unit 			= uar_get_code_display(mpt.uom_cd)
	   	,dispense_factor 			= mdisp.dispense_factor
	   	,gpo						= mch2.cost "#####.#####" ;002
	   	,awp 						= mch.cost "#####.#####"
	   	,CS_HCPCS 					= trim(bim.key6)
	   	,CS_QCF 					= bim.bim1_nbr "#####.#####"
	   	,bill_item_id				= bi.bill_item_id
	   	,legal_status 				= uar_get_code_display(mdisp.legal_status_cd)
	   	,facility 					= cv1.display
		,value_key					= mi.value_key
 
	from MEDICATION_DEFINITION 	md
 
	,(inner join MED_DISPENSE mdisp on mdisp.item_id = md.item_id
    	and mdisp.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT")))
 
    ,(inner join MED_DEF_FLEX mdf on mdf.item_id = md.item_id
    	and mdf.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSTEM"))
    	and mdf.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    	and mdf.active_ind = 1)
 
    ,(inner join MED_FLEX_OBJECT_IDX mfoi on mfoi.med_def_flex_id = mdf.med_def_flex_id
    	and mfoi.parent_entity_name = "MED_OE_DEFAULTS")
 
    ,(inner join MED_OE_DEFAULTS mod on mod.med_oe_defaults_id = mfoi.parent_entity_id)
 
    ,(inner join MED_IDENTIFIER mi on mi.item_id = md.item_id
    	and mi.primary_ind = 1
    	and mi.med_product_id = 0
    	and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC"))
    	and mi.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    	and mi.active_ind = 1)
 
    ,(inner join MED_IDENTIFIER mi2 on mi2.item_id = md.item_id
    	and mi2.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "NDC"))
    	and mi2.active_ind = 1)
 
    ,(inner join MED_FLEX_OBJECT_IDX mfoi3 on mfoi3.parent_entity_id = mi2.med_product_id)
 
    ,(left join MED_COST_HX mch on mch.med_product_id = mi2.med_product_id
    	and mch.cost_type_cd = value(uar_get_code_by("MEANING", 4050, "AWP"))
    	and mch.active_ind = 1)
 
    ,(left join MED_COST_HX mch2 on mch2.med_product_id = mi2.med_product_id ;002
   		and mch2.cost_type_cd = value(uar_get_code_by("DISPLAY", 4050, "GPO"))
    	and mch2.active_ind = 1)
 
    ,(inner join MED_DEF_FLEX mdf2 on mdf2.item_id = md.item_id
    	and mdf2.flex_type_cd = value(uar_get_code_by("MEANING", 4062, "SYSPKGTYP"))
    	and mdf2.pharmacy_type_cd = value(uar_get_code_by("MEANING", 4500, "INPATIENT"))
    	and mdf2.active_ind = 1)
 
    ,(inner join MED_FLEX_OBJECT_IDX mfoi2 on mfoi2.med_def_flex_id = mdf2.med_def_flex_id)
 
    ,(inner join CODE_VALUE cv1 on cv1.code_value = mfoi2.parent_entity_id
    	and cv1.code_set = 220
    	and cv1.code_value = $FACILITY
    	and cv1.cdf_meaning = "FACILITY")
 
    ,(inner join ORDER_CATALOG_ITEM_R ocir on ocir.item_id = md.item_id)
 
    ,(left join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = mod.ord_as_synonym_id)
 
    ,(left join ORDER_CATALOG_SYNONYM ocs2 on ocs2.catalog_cd = ocir.catalog_cd
   		and ocs2.mnemonic_type_cd = value(uar_get_code_by("MEANING", 6011, "PRIMARY")))
 
    ,(left join PRICE_SCHED p on p.price_sched_id = mod.price_sched_id)
 
    ,(inner join NOMENCLATURE n on n.nomenclature_id = md.mdx_gfc_nomen_id)
 
    ,(inner join ORDER_CATALOG oc on oc.catalog_cd = ocir.catalog_cd)
 
    ,(left join MED_IDENTIFIER mi3 on mi3.item_id = md.item_id
    	and mi3.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "PYXIS"))
    	and mi3.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi5 on mi5.item_id = mi.item_id
    	and mi5.primary_ind = 1
    	and mi5.med_product_id = 0
    	and mi5.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "BRAND_NAME"))
    	and mi5.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi6 on mi6.item_id = mi.item_id
    	and mi6.primary_ind = 1
    	and mi6.med_product_id = 0
    	and mi6.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "CDM"))
    	and mi6.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi7 on mi7.item_id = mi.item_id
    	and mi7.primary_ind = 1
    	and mi7.med_product_id = 0
    	and mi7.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000 , "GENERIC_NAME"))
    	and mi7.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi8 on mi8.item_id = mi.item_id
    	and mi8.primary_ind = 1
    	and mi8.med_product_id = 0
    	and mi8.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "HCPCS"))
    	and mi8.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi9 on mi9.item_id = mi.item_id
    	and mi9.primary_ind = 1
    	and mi9.med_product_id = 0
    	and mi9.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "DESC_SHORT"))
    	and mi9.active_ind = 1)
 
    ,(left join MED_IDENTIFIER mi4 on mi4.item_id = mi2.item_id
    	and mi4.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "INNER_NDC"))
    	and mi4.med_product_id = mi2.med_product_id
    	and mi4.active_ind = 1)
 
	,(inner join MED_PACKAGE_type mpt on mpt.med_package_type_id = mdf2.med_package_type_id)
 
	,(left join BILL_ITEM bi on bi.ext_parent_reference_id = mdf.med_def_flex_id
		and bi.ext_parent_contributor_cd = value(UAR_GET_CODE_BY("MEANING", 13016, "MED DEF FLEX"))
		and bi.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bi.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bi.active_ind = 1)
 
	,(left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
		and bim.key1_id = value(UAR_GET_CODE_BY("DISPLAYKEY",14002, "HCPCS"))
		and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bim.active_ind = 1)
 
	order by cnvtupper(oc.primary_mnemonic), mi.value_key, mfoi3.sequence, md.item_id
 
	head report
		cnt  = 0
 
	detail
	 	cnt = cnt + 1
		call alterlist(rec->list, cnt)
 
		rec->rec_cnt							= cnt
		rec->list[cnt].med_id 					= med_id
		rec->list[cnt].item_id 					= item_id
		rec->list[cnt].description 				= description
		rec->list[cnt].order_catalog_primary 	= order_catalog_primary
		rec->list[cnt].oc_cki					= oc_cki
		rec->list[cnt].mmdc 					= mmdc
		rec->list[cnt].drug_formulation 		= drug_formulation
		rec->list[cnt].primary_ndc 				= primary_ndc
		rec->list[cnt].inner_ndc 				= inner_ndc
		rec->list[cnt].default_route 			= default_route
		rec->list[cnt].form 					= form
		rec->list[cnt].strength 				= strength
		rec->list[cnt].strength_unit 			= strength_unit
		rec->list[cnt].volume 					= volume
		rec->list[cnt].volume_unit 				= volume_unit
		rec->list[cnt].default_order_type 		= default_order_type
		rec->list[cnt].med_filter 				= med_filter
		rec->list[cnt].int_filter 				= int_filter
		rec->list[cnt].cont_filter 				= cont_filter
		rec->list[cnt].ordered_as_synonym 		= ordered_as_synonym
		rec->list[cnt].dispense_category 		= dispense_category
		rec->list[cnt].include_total_volume 	= include_total_volume
		rec->list[cnt].default_dose 			= default_dose
		rec->list[cnt].default_freq 			= default_freq
		rec->list[cnt].duration 				= duration
		rec->list[cnt].duration_unit 			= duration_unit
		rec->list[cnt].stop_type 				= stop_type
		rec->list[cnt].default_infuse_over 		= default_infuse_over
		rec->list[cnt].default_infuse_over_unit	= default_infuse_over_unit
		rec->list[cnt].brand_name 				= brand_name
		rec->list[cnt].cdm 						= cdm
		rec->list[cnt].price_schedule 			= price_schedule
		rec->list[cnt].dispense_qty 			= dispense_qty
		rec->list[cnt].dispense_qty_unit 		= dispense_qty_unit
		rec->list[cnt].dispense_factor 			= dispense_factor
		rec->list[cnt].gpo						= gpo ;002
		rec->list[cnt].awp 						= awp
		rec->list[cnt].CS_HCPCS 				= CS_HCPCS
		rec->list[cnt].CS_QCF 					= CS_QCF
		rec->list[cnt].bill_item_id 			= bill_item_id
		rec->list[cnt].legal_status 			= legal_status
		rec->list[cnt].facility       			= facility
		rec->list[cnt].ndc 						= ndc
		rec->list[cnt].formulary_status 		= formulary_status
		rec->list[cnt].price_schedule 			= price_schedule
		rec->list[cnt].rx_mnemonic 				= rx_mnemonic
		rec->list[cnt].value_key				= value_key
 
   	with nocounter ,separator = " " ,format
 
endif
 
 
;==========================================================================================
; GET DRUG CLASS DATA  ;BEGIN 001
;==========================================================================================
select into "nl:"
from MLTM_DRUG_CATEGORIES dc1
 
	,(inner join MLTM_CATEGORY_SUB_XREF dcs1 on dcs1.multum_category_id = dc1.multum_category_id)
 
	,(inner join MLTM_DRUG_CATEGORIES dc2 on dc2.multum_category_id = dcs1.sub_category_id)
 
	,(left join  MLTM_CATEGORY_SUB_XREF dcs2 on dcs2.multum_category_id = dc2.multum_category_id)
 
	,(left join  MLTM_DRUG_CATEGORIES dc3 on dc3.multum_category_id = dcs2.sub_category_id)
 
	,(inner join MLTM_CATEGORY_DRUG_XREF mcdx on ((mcdx.multum_category_id = dc1.multum_category_id)
		or (mcdx.multum_category_id = dc2.multum_category_id)
		or (mcdx.multum_category_id = dc3.multum_category_id))
		and expand(cnt, 1, rec->rec_cnt, mcdx.drug_identifier, rec->list[cnt].oc_cki))
 
where not(exists(
		select mcsx.multum_category_id
		from MLTM_CATEGORY_SUB_XREF mcsx
		where mcsx.sub_category_id = dc1.multum_category_id))
 
order by mcdx.drug_identifier
 
head mcdx.drug_identifier
	idx = 0
	cnt = 0
    idx = locateval(cnt, 1, rec->rec_cnt, mcdx.drug_identifier, rec->list[cnt].oc_cki)
 
    while(idx > 0)
		rec->list[idx].drug_identifier = mcdx.drug_identifier
		if(dc1.multum_category_id != 0)
			rec->list[idx].drug_class_code1 = trim(cnvtstring(dc1.multum_category_id), 3)
			rec->list[idx].drug_class_description1 = dc1.category_name
	    endif
 
	    if(dc2.multum_category_id != 0)
			rec->list[idx].drug_class_code2 = trim(cnvtstring(dc2.multum_category_id), 3)
			rec->list[idx].drug_class_description2 = dc2.category_name
	    endif
 
	    if(dc3.multum_category_id != 0)
			rec->list[idx].drug_class_code3 = trim(cnvtstring(dc3.multum_category_id), 3)
			rec->list[idx].drug_class_description3 = dc3.category_name
	    endif
 
    	idx = locateval(cnt,(idx+1), rec->rec_cnt, mcdx.drug_identifier ,rec->list[cnt].oc_cki)
    endwhile
 
foot  mcdx.drug_identifier
    null
 
with nocounter, expand = 1
;--- END 001
 
 
;==========================================================================================
; GET THERAPEUTIC CLASS
;==========================================================================================
select into "nl:"
from MEDICATION_DEFINITION 	md
 
	,(inner join ITEM_DEFINITION id on id.item_id = md.item_id
		and id.item_type_cd = value(uar_get_code_by("MEANING", 11001, "MED_DEF")))
 
	,(inner join ORDER_CATALOG_ITEM_R ocir on ocir.item_id = md.item_id
		and expand(cnt, 1, rec->rec_cnt, ocir.item_id, rec->list[cnt].item_id))
 
	,(inner join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = ocir.synonym_id)
 
	,(left  join ALT_SEL_LIST al on al.synonym_id = ocir.synonym_id)
 
	,(left  join ALT_SEL_CAT ac on ac.alt_sel_category_id = al.alt_sel_category_id
		and ac.ahfs_ind = 1)
 
order by md.item_id
 
head md.item_id
	idx = 0
	cnt = 0
    idx = locateval(cnt, 1, rec->rec_cnt, md.item_id, rec->list[cnt].item_id)
 
    while(idx > 0)
		rec->list[idx].therapeutic_class = ac.long_description
 
		idx = locateval(cnt, (idx+1), rec->rec_cnt, md.item_id, rec->list[cnt].item_id)
	endwhile
 
foot md.item_id
    null
 
with nocounter, expand = 1
 
 
;==========================================================================================
; REPORT OUTPUT
;==========================================================================================
if ($ALLNDC = "Yes")
 
	select distinct into value($OUTDEV)
		 med_id 					= rec->list[d.seq].med_id
		,item_id 					= rec->list[d.seq].item_id
		,description 				= substring(1,120,rec->list[d.seq].description)
		,medication			 		= substring(1,120,cnvtlower(rec->list[d.seq].order_catalog_primary))
		,therapeutic_class			= substring(1,120,rec->list[d.seq].therapeutic_class)
;		,oc_cki						= substring(1,99,rec->list[d.seq].oc_cki)
;		,drug_identifier			= rec->list[d.seq].drug_identifier
		,drug_class_code1			= rec->list[d.seq].drug_class_code1
		,drug_class_description1	= substring(1,60,rec->list[d.seq].drug_class_description1)
		,drug_class_code2			= rec->list[d.seq].drug_class_code2
		,drug_class_description2	= substring(1,60,rec->list[d.seq].drug_class_description2)
		,drug_class_code3			= rec->list[d.seq].drug_class_code3
		,drug_class_description3	= substring(1,60,rec->list[d.seq].drug_class_description3)
		,mmdc 						= substring(1,30,rec->list[d.seq].mmdc)
		,drug_formulation 			= substring(1,100,rec->list[d.seq].drug_formulation)
		,primary_ndc 				= substring(1,30,rec->list[d.seq].primary_ndc)
		,inner_ndc 					= substring(1,50,rec->list[d.seq].inner_ndc)
		,default_route 				= rec->list[d.seq].default_route
		,form 						= substring(1,30,rec->list[d.seq].form)
		,strength 					= rec->list[d.seq].strength
		,strength_unit 				= rec->list[d.seq].strength_unit
		,volume 					= rec->list[d.seq].volume
		,volume_unit 				= rec->list[d.seq].volume_unit
		,default_order_type 		= rec->list[d.seq].default_order_type
		,med_filter 				= rec->list[d.seq].med_filter
		,int_filter 				= rec->list[d.seq].int_filter
		,cont_filter 				= rec->list[d.seq].cont_filter
		,ordered_as_synonym 		= substring(1,99,rec->list[d.seq].ordered_as_synonym)
		,dispense_category 			= substring(1,50,rec->list[d.seq].dispense_category)
		,include_total_volume 		= rec->list[d.seq].include_total_volume
		,default_dose 				= rec->list[d.seq].default_dose
		,default_freq 				= substring(1,50,rec->list[d.seq].default_freq)
		,duration 					= rec->list[d.seq].duration
		,duration_unit 				= rec->list[d.seq].duration_unit
		,stop_type 					= rec->list[d.seq].stop_type
		,default_infuse_over 		= rec->list[d.seq].default_infuse_over
		,default_infuse_over_unit	= rec->list[d.seq].default_infuse_over_unit
		,brand_name 				= substring(1,80,rec->list[d.seq].brand_name)
		,cdm 						= rec->list[d.seq].cdm
		,price_schedule 			= substring(1,50,rec->list[d.seq].price_schedule)
		,dispense_qty 				= rec->list[d.seq].dispense_qty
		,dispense_qty_unit 			= rec->list[d.seq].dispense_qty_unit
		,dispense_factor 			= rec->list[d.seq].dispense_factor
		,gpo 						= format(rec->list[d.seq].gpo, "####.#####") ;002
		,awp 						= format(rec->list[d.seq].awp, "####.#####")
		,CS_HCPCS 					= rec->list[d.seq].CS_HCPCS
		,CS_QCF 					= rec->list[d.seq].CS_QCF
		,bill_item_id 				= rec->list[d.seq].bill_item_id
		,legal_status 				= rec->list[d.seq].legal_status
 		,given_strength 			= substring(1,60,rec->list[d.seq].given_strength)
		,divisible_ind 				= rec->list[d.seq].divisible_ind
		,infinite_divisible 		= rec->list[d.seq].infinite_divisible
		,min_divisible 				= rec->list[d.seq].min_divisible
		,generic_name 				= substring(1,99,rec->list[d.seq].generic_name)
		,rx_mnemonic 				= substring(1,60,rec->list[d.seq].rx_mnemonic)
		,value_key					= substring(1,150,rec->list[d.seq].value_key)
		,facility 					= rec->list[d.seq].facility
 
	from
		(dummyt d with seq = value(size(rec->list,5)))
	plan d
		where parser(MED_VAR)	;001
			and parser(DC1_VAR)	;001
			and parser(DC2_VAR)	;001
			and parser(DC3_VAR)	;001
	with nocounter, format, check, separator = " "
 
else
 
	select distinct into value($OUTDEV)
		 med_id 					= rec->list[d.seq].med_id
		,item_id 					= rec->list[d.seq].item_id
		,description 				= substring(1,120,rec->list[d.seq].description)
		,medication 				= substring(1,120,cnvtlower(rec->list[d.seq].order_catalog_primary))
		,therapeutic_class			= substring(1,120,rec->list[d.seq].therapeutic_class)
;		,oc_cki						= substring(1,99,rec->list[d.seq].oc_cki)
;		,drug_identifier			= rec->list[d.seq].drug_identifier
		,drug_class_code1			= rec->list[d.seq].drug_class_code1
		,drug_class_description1	= substring(1,60,rec->list[d.seq].drug_class_description1)
		,drug_class_code2			= rec->list[d.seq].drug_class_code2
		,drug_class_description2	= substring(1,60,rec->list[d.seq].drug_class_description2)
		,drug_class_code3			= rec->list[d.seq].drug_class_code3
		,drug_class_description3	= substring(1,60,rec->list[d.seq].drug_class_description3)
		,mmdc 						= substring(1,30,rec->list[d.seq].mmdc)
		,drug_formulation 			= substring(1,100,rec->list[d.seq].drug_formulation)
		,primary_ndc 				= substring(1,30,rec->list[d.seq].primary_ndc)
		,inner_ndc 					= substring(1,50,rec->list[d.seq].inner_ndc)
		,default_route 				= rec->list[d.seq].default_route
		,form 						= substring(1,30,rec->list[d.seq].form)
		,strength 					= rec->list[d.seq].strength
		,strength_unit 				= rec->list[d.seq].strength_unit
		,volume 					= rec->list[d.seq].volume
		,volume_unit 				= rec->list[d.seq].volume_unit
		,default_order_type 		= rec->list[d.seq].default_order_type
		,med_filter 				= rec->list[d.seq].med_filter
		,int_filter 				= rec->list[d.seq].int_filter
		,cont_filter 				= rec->list[d.seq].cont_filter
		,ordered_as_synonym 		= substring(1,99,rec->list[d.seq].ordered_as_synonym)
		,dispense_category 			= substring(1,50,rec->list[d.seq].dispense_category)
		,include_total_volume 		= rec->list[d.seq].include_total_volume
		,default_dose 				= rec->list[d.seq].default_dose
		,default_freq 				= substring(1,50,rec->list[d.seq].default_freq)
		,duration 					= rec->list[d.seq].duration
		,duration_unit 				= rec->list[d.seq].duration_unit
		,stop_type 					= rec->list[d.seq].stop_type
		,default_infuse_over 		= rec->list[d.seq].default_infuse_over
		,default_infuse_over_unit	= rec->list[d.seq].default_infuse_over_unit
		,brand_name 				= substring(1,80,rec->list[d.seq].brand_name)
		,cdm 						= rec->list[d.seq].cdm
		,price_schedule 			= substring(1,50,rec->list[d.seq].price_schedule)
		,dispense_qty 				= rec->list[d.seq].dispense_qty
		,dispense_qty_unit 			= rec->list[d.seq].dispense_qty_unit
		,dispense_factor 			= rec->list[d.seq].dispense_factor
		,gpo 						= format(rec->list[d.seq].gpo, "####.#####") ;002
		,awp 						= format(rec->list[d.seq].awp, "####.#####")
		,CS_HCPCS 					= rec->list[d.seq].CS_HCPCS
		,CS_QCF 					= rec->list[d.seq].CS_QCF
		,bill_item_id 				= rec->list[d.seq].bill_item_id
		,legal_status 				= rec->list[d.seq].legal_status
		,ndc 						= rec->list[d.seq].ndc
		,formulary_status 			= rec->list[d.seq].formulary_status
		,price_schedule 			= rec->list[d.seq].price_schedule
		,rx_mnemonic 				= substring(1,60,rec->list[d.seq].rx_mnemonic)
		,value_key					= substring(1,150,rec->list[d.seq].value_key)
		,facility 					= rec->list[d.seq].facility
 
	from
		(dummyt d with seq = value(size(rec->list,5)))
	plan d
		where parser(MED_VAR)	;001
			and parser(DC1_VAR)	;001
			and parser(DC2_VAR)	;001
			and parser(DC3_VAR)	;001
	with nocounter, format, check, separator = " "
 
endif
 
end
go
 
 
 
;;;========================
;;;CODE BEFORE CR6297
;;;========================
;;DROP PROGRAM cov_pha_formulary_extract2:dba GO
;;CREATE PROGRAM cov_pha_formulary_extract2:dba
;; PROMPT
;;  "Output to File/Printer/MINE" = "MINE" ,
;;  "Facility" = 24614639.00 ,
;;  "Primary NDC Extract Only" = ""
;;  WITH outdev ,facility ,allndc
;; SET cur_ndc =  $ALLNDC
;; SET cur_facility_cd = cnvtreal ( $FACILITY )
;; IF (cur_ndc = "Yes")
;;  SELECT INTO $OUTDEV
;;   med_id = trim (mi3.value ,1 ) ,
;;   md.item_id,
;;   description = trim (mi.value ,1 ) ,
;;   order_catalog_primary = trim (oc.primary_mnemonic ) ,
;;   mmdc = md.cki ,
;;   oc.cki,
;;   drug_formulation = n.source_string ,
;;   primary_ndc = mi2.value ,
;;   inner_ndc = mi4.value ,
;;   default_route = uar_get_code_display (mod.route_cd ) ,
;;   form = uar_get_code_display (md.form_cd ) ,
;;   strength = mdisp.strength ,
;;   strength_unit = uar_get_code_display (mdisp.strength_unit_cd ) ,
;;   volume = mdisp.volume ,
;;   volume_unit = uar_get_code_display (mdisp.volume_unit_cd ) ,
;;   given_strength = md.given_strength,
;;   divisible_ind = evaluate (mdisp.divisible_ind ,0 ,"No" ,1 ,"Yes" ) ,
;;   infinite_divisible = evaluate (mdisp.infinite_div_ind ,0 ,"No" ,1 ,"Yes" ) ,
;;   min_divisible = mdisp.base_issue_factor ,
;;   default_order_type = evaluate (cnvtint (mdisp.oe_format_flag ) ,cnvtint (0 ) ,"None" ,cnvtint (1) ,
;;   	"Medication" ,cnvtint (2 ) ,"Continuous" ,cnvtint (3 ) ,"Intermittent" ,"Indeterminate" ) ,
;;   med_filter = mdisp.med_filter_ind ,
;;   int_filter = mdisp.intermittent_filter_ind ,
;;   cont_filter = mdisp.continuous_filter_ind ,
;;   ordered_as_synonym = ocs.mnemonic ,
;;   dispense_category = uar_get_code_display (mod.dispense_category_cd ) ,
;;   therapeutic_class = ac.long_description ,
;;
;;   include_total_volume = evaluate (cnvtint (mdisp.used_as_base_ind ) ,cnvtint (0 ) ,"Never" ,
;;    cnvtint (1 ) ,"Sometimes" ,cnvtint (2 ) ,"Always" ) ,
;;   default_dose = evaluate2 (
;;    IF ((mod.strength_unit_cd > 0 ) ) concat (trim (format (mod.strength ,"#######.####;T(1)" ) ,7 )
;;      ," " ,uar_get_code_display (mod.strength_unit_cd ) )
;;    ELSEIF ((mod.volume_unit_cd > 0 ) ) concat (trim (format (mod.volume ,"#######.####;T(1)" ) ,7 )
;;      ," " ,uar_get_code_display (mod.volume_unit_cd ) )
;;    ELSE mod.freetext_dose
;;    ENDIF
;;    ) ,
;;   default_freq = uar_get_code_display (mod.frequency_cd ) ,
;;   duration = mod.duration ,
;;   duration_unit = uar_get_code_display (mod.duration_unit_cd ) ,
;;   stop_type = uar_get_code_display (mod.stop_type_cd ) ,
;;   default_infuse_over = evaluate(mod.infuse_over, -1, 0, mod.infuse_over) ,
;;   default_infuse_over_unit = uar_get_code_display (mod.infuse_over_cd ) ,
;;   brand_name = trim (mi5.value ,1 ) ,
;;   cdm = trim (mi6.value ,1 ) ,
;;   price_schedule = trim(replace(replace(p.price_sched_desc, char(10), ""), char(13), "")) ,
;;   dispense_qty = mpt.dispense_qty,
;;   dispense_qty_unit = uar_get_code_display(mpt.uom_cd),
;;   dispense_factor = mdisp.dispense_factor,
;;   AWP = mch.cost "#####.###" ,
;;   CS_HCPCS = trim(bim.key6),
;;   CS_QCF = bim.bim1_nbr "#####.#####",
;;   bi.bill_item_id,
;;   generic_name = trim (mi7.value ,1 ) ,
;;   rx_mnemonic = trim (mi9.value ,1 ) ,
;;   legal_status = uar_get_code_display (mdisp.legal_status_cd ) ,
;;   facility = cv1.display
;;   FROM
;;    medication_definition md,
;;    med_dispense mdisp,
;;    med_oe_defaults mod,
;;    order_catalog_synonym ocs,
;;    order_catalog_synonym ocs2,
;;    med_def_flex mdf,
;;    med_flex_object_idx mfoi,
;;    price_sched p,
;;    med_identifier mi,
;;    med_identifier mi2,
;;    med_def_flex mdf2,
;;    med_flex_object_idx mfoi3,
;;    med_cost_hx mch,
;;    med_identifier mi3,
;;    med_identifier mi4,
;;    nomenclature n,
;;    order_catalog_item_r ocir,
;;    order_catalog oc,
;;    med_identifier mi5,
;;    med_identifier mi6,
;;    med_identifier mi7,
;;    med_identifier mi8,
;;    med_identifier mi9,
;;    med_flex_object_idx mfoi2,
;;    code_value cv1,
;;    med_package_type mpt,
;;    bill_item bi,
;;    bill_item_modifier bim,
;;    alt_sel_list al,
;;    alt_sel_cat  ac
;;
;;	PLAN md
;;	JOIN mdisp WHERE mdisp.item_id = md.item_id
;;    	AND mdisp.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
;;    JOIN mdf WHERE mdf.item_id = md.item_id
;;    	AND mdf.flex_type_cd = value (uar_get_code_by ("MEANING" ,4062 ,"SYSTEM"))
;;   		AND mdf.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
;;    	AND mdf.active_ind = 1
;;    JOIN mfoi WHERE mfoi.med_def_flex_id = mdf.med_def_flex_id
;;    	AND mfoi.parent_entity_name = "MED_OE_DEFAULTS"
;;    JOIN mod WHERE mod.med_oe_defaults_id = mfoi.parent_entity_id
;;    JOIN mi WHERE mi.item_id = md.item_id
;;	    AND mi.active_ind = 1
;;	    AND mi.primary_ind = 1
;;	    AND mi.med_product_id = 0
;;	    AND mi.med_identifier_type_cd = value(uar_get_code_by ("MEANING" ,11000 ,"DESC"))
;;	    AND mi.pharmacy_type_cd = value(uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
;;    JOIN mi2 WHERE mi2.item_id = md.item_id
;;	    AND mi2.active_ind = 1
;;	    AND mi2.med_identifier_type_cd = value (uar_get_code_by ("MEANING" ,11000 ,"NDC"))
;;    JOIN mfoi3 WHERE mfoi3.parent_entity_id = mi2.med_product_id
;;   		AND mfoi3.sequence = 1
;;    JOIN mch WHERE mch.med_product_id = outerjoin (mi2.med_product_id)
;;   		AND mch.cost_type_cd = outerjoin(value(uar_get_code_by ("MEANING" ,4050 ,"AWP")))
;;    	AND mch.active_ind = outerjoin(1)
;;    JOIN mdf2 WHERE mdf2.item_id = md.item_id
;;	    AND mdf2.flex_type_cd = value (uar_get_code_by ("MEANING" ,4062 ,"SYSPKGTYP" ))
;;	    AND mdf2.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
;;	    AND mdf2.active_ind = 1
;;    JOIN mfoi2	WHERE mfoi2.med_def_flex_id = mdf2.med_def_flex_id
;;    JOIN cv1 WHERE cv1.code_value = mfoi2.parent_entity_id
;;	    AND cv1.code_set = 220
;;	    AND cv1.code_value = cur_facility_cd
;;	    AND cv1.cdf_meaning = "FACILITY"
;;    JOIN ocir WHERE ocir.item_id = md.item_id
;;    JOIN ocs WHERE ocs.synonym_id = outerjoin(mod.ord_as_synonym_id)
;;    JOIN ocs2 WHERE ocs2.catalog_cd = outerjoin(ocir.catalog_cd)
;;    	AND ocs2.mnemonic_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,6011 ,"PRIMARY")))
;;    JOIN p WHERE p.price_sched_id = outerjoin(mod.price_sched_id)
;;    JOIN n WHERE n.nomenclature_id = md.mdx_gfc_nomen_id
;;    JOIN oc WHERE oc.catalog_cd = ocir.catalog_cd
;;    JOIN mi3 WHERE mi3.item_id = outerjoin (md.item_id)
;;    	AND mi3.active_ind = outerjoin (1)
;;    	AND mi3.med_identifier_type_cd = outerjoin(value(uar_get_code_by ("MEANING" ,11000 ,"PYXIS")))
;;    JOIN mi5 WHERE mi5.item_id = outerjoin(mi.item_id)
;;	    AND mi5.active_ind = outerjoin(1)
;;	    AND mi5.primary_ind = outerjoin(1)
;;	    AND mi5.med_product_id = outerjoin(0)
;;	    AND mi5.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"BRAND_NAME")))
;;    JOIN mi6 WHERE mi6.item_id = outerjoin(mi.item_id)
;;	    AND mi6.active_ind = outerjoin(1)
;;	    AND mi6.primary_ind = outerjoin(1)
;;	    AND mi6.med_product_id = outerjoin(0)
;;	    AND mi6.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"CDM")))
;;    JOIN mi7 WHERE mi7.item_id = outerjoin(mi.item_id)
;;	    AND mi7.active_ind = outerjoin(1)
;;	    AND mi7.primary_ind = outerjoin(1)
;;	    AND mi7.med_product_id = outerjoin(0)
;;	    AND mi7.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING",11000,"GENERIC_NAME")))
;;    JOIN mi8 WHERE mi8.item_id = outerjoin(mi.item_id)
;;	    AND mi8.active_ind = outerjoin(1)
;;	    AND mi8.primary_ind = outerjoin(1)
;;	    AND mi8.med_product_id = outerjoin(0)
;;	    AND mi8.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"HCPCS")))
;;    JOIN mi9 WHERE mi9.item_id = outerjoin(mi.item_id)
;;	    AND mi9.active_ind = outerjoin(1)
;;	    AND mi9.primary_ind = outerjoin(1)
;;	    AND mi9.med_product_id = outerjoin(0)
;;	    AND mi9.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 , "DESC_SHORT")))
;;    JOIN mi4 WHERE mi4.item_id = outerjoin(mi2.item_id)
;;	    AND mi4.active_ind = outerjoin(1)
;;	    AND mi4.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"INNER_NDC")))
;;	    AND mi4.med_product_id = outerjoin(mi2.med_product_id)
;;	join mpt where mpt.med_package_type_id = mdf2.med_package_type_id
;;	join bi where bi.ext_parent_reference_id = outerjoin(mdf.med_def_flex_id)
;;	  and bi.ext_parent_contributor_cd = outerjoin(value(UAR_GET_CODE_BY("MEANING", 13016, "MED DEF FLEX")))
;;	  and bi.active_ind = outerjoin(1)
;;	  and bi.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
;;	  and bi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
;;	join bim where bim.bill_item_id = outerjoin(bi.bill_item_id)
;;	  and bim.key1_id = outerjoin(value(UAR_GET_CODE_BY("DISPLAYKEY",14002 ,"HCPCS")))
;;	  and bim.active_ind = outerjoin(1)
;;	  and bim.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
;;	  and bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
;;	join al where outerjoin(ocir.synonym_id) = al.synonym_id
;;    join ac where outerjoin(al.alt_sel_category_id) = ac.alt_sel_category_id
;;
;;   ORDER BY
;;   	cnvtupper(oc.primary_mnemonic),
;;   	mi.value_key ,
;;    md.item_id
;;   WITH nocounter ,separator = " " ,format
;; ELSE
;;  SELECT INTO $OUTDEV
;;	med_id = trim (mi3.value ,1 )
;;	, md.item_id
;;	, description = trim (mi.value ,1 )
;;	, order_catalog_primary = oc.primary_mnemonic
;;	, MMDC = md.cki
;;	, drug_formulation = n.source_string
;;	, primary_ndc = evaluate(mfoi3.sequence, 1, "X", "")
;;	, ndc = mi2.value
;;	, inner_ndc = mi4.value
;;	, default_route = uar_get_code_display (mod.route_cd )
;;	, form = uar_get_code_display (md.form_cd )
;;	, strength = mdisp.strength
;;	, strength_unit = uar_get_code_display (mdisp.strength_unit_cd )
;;	, volume = mdisp.volume
;;	, volume_unit = uar_get_code_display (mdisp.volume_unit_cd )
;;	, default_order_type = evaluate (cnvtint (mdisp.oe_format_flag ) ,cnvtint (0 ) ,"None" ,cnvtint (1
;;     ) ,"Medication" ,cnvtint (2 ) ,"Continuous" ,cnvtint (3 ) ,"Intermittent" ,"Indeterminate" )
;;	, med_filter = mdisp.med_filter_ind
;;	, int_filter = mdisp.intermittent_filter_ind
;;	, cont_filter = mdisp.continuous_filter_ind
;;	, ordered_as_synonym = ocs.mnemonic
;;	, dispense_category = uar_get_code_display (mod.dispense_category_cd )
;;	, formulary_status = uar_get_code_display (mdisp.formulary_status_cd )
;;	, include_total_volume = evaluate (cnvtint (mdisp.used_as_base_ind ) ,cnvtint (0 ) ,"Never" ,
;;    cnvtint (1 ) ,"Sometimes" ,cnvtint (2 ) ,"Always" )
;;	, default_dose = evaluate2 (
;;    IF ((mod.strength_unit_cd > 0 ) ) concat (trim (format (mod.strength ,"#######.####;T(1)" ) ,7 )
;;      ," " ,uar_get_code_display (mod.strength_unit_cd ) )
;;    ELSEIF ((mod.volume_unit_cd > 0 ) ) concat (trim (format (mod.volume ,"#######.####;T(1)" ) ,7 )
;;      ," " ,uar_get_code_display (mod.volume_unit_cd ) )
;;    ELSE mod.freetext_dose
;;    ENDIF
;;    )
;;	, default_freq = uar_get_code_display (mod.frequency_cd )
;;	, duration = mod.duration
;;	, duration_unit = uar_get_code_display (mod.duration_unit_cd )
;;	, stop_type = uar_get_code_display (mod.stop_type_cd )
;;	, default_infuse_over = evaluate(mod.infuse_over, -1, 0, mod.infuse_over)
;;	, default_infuse_over_unit = uar_get_code_display (mod.infuse_over_cd )
;;	, price_schedule = p.price_sched_desc
;;	, brand_name = trim (mi5.value ,1 )
;;	, cdm = trim (mi6.value ,1 )
;;	, generic_name = trim (mi7.value ,1 )
;;	, rx_mnemonic = trim (mi9.value ,1 )
;;	, cdm = trim (mi6.value ,1 )
;;	, price_schedule = p.price_sched_desc
;;	, dispense_qty = mpt.dispense_qty
;;	, dispense_qty_unit = uar_get_code_display(mpt.uom_cd)
;;	, dispense_factor = mdisp.dispense_factor
;;	, AWP = mch.cost "#####.###"
;;	, mdisp.WASTE_CHARGE_IND
;;	, CS_HCPCS = trim(bim.key6)
;;	, CS_QCF = bim.bim1_nbr "#####.#####"
;;	, bi.bill_item_id
;;	, legal_status = uar_get_code_display (mdisp.legal_status_cd )
;;	, facility = cv1.display
;;
;;FROM
;;	medication_definition   md
;;	, med_dispense   mdisp
;;	, med_oe_defaults   mod
;;	, order_catalog_synonym   ocs
;;	, order_catalog_synonym   ocs2
;;	, med_def_flex   mdf
;;	, med_flex_object_idx   mfoi
;;	, price_sched   p
;;	, med_identifier   mi
;;	, med_identifier   mi2
;;	, med_def_flex   mdf2
;;	, med_flex_object_idx   mfoi3
;;	, med_cost_hx   mch
;;	, med_identifier   mi3
;;	, med_identifier   mi4
;;	, nomenclature   n
;;	, order_catalog_item_r   ocir
;;	, order_catalog   oc
;;	, med_identifier   mi5
;;	, med_identifier   mi6
;;	, med_identifier   mi7
;;	, med_identifier   mi8
;;	, med_identifier   mi9
;;	, med_flex_object_idx   mfoi2
;;	, code_value   cv1
;;	, med_package_type   mpt
;;	, bill_item   bi
;;	, bill_item_modifier   bim
;;
;;PLAN md
;;	JOIN mdisp WHERE mdisp.item_id = md.item_id
;;    	AND mdisp.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
;;    JOIN mdf WHERE mdf.item_id = md.item_id
;;	    AND mdf.flex_type_cd = value(uar_get_code_by("MEANING" ,4062 ,"SYSTEM"))
;;	    AND mdf.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
;;	    AND mdf.active_ind = 1
;;    JOIN mfoi WHERE mfoi.med_def_flex_id = mdf.med_def_flex_id
;;    	AND mfoi.parent_entity_name = "MED_OE_DEFAULTS"
;;    JOIN mod WHERE mod.med_oe_defaults_id = mfoi.parent_entity_id
;;    JOIN mi WHERE mi.item_id = md.item_id
;;	    AND mi.active_ind = 1
;;	    AND mi.primary_ind = 1
;;	    AND mi.med_product_id = 0
;;	    AND mi.med_identifier_type_cd = value(uar_get_code_by("MEANING" ,11000 ,"DESC"))
;;	    AND mi.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
;;    JOIN mi2 WHERE mi2.item_id = md.item_id
;;	    AND mi2.active_ind = 1
;;	    AND mi2.med_identifier_type_cd = value(uar_get_code_by("MEANING" ,11000 ,"NDC"))
;;    JOIN mfoi3 WHERE mfoi3.parent_entity_id = mi2.med_product_id
;;    JOIN mch WHERE mch.med_product_id = outerjoin(mi2.med_product_id)
;;	    AND mch.cost_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,4050 ,"AWP")))
;;	    AND mch.active_ind = outerjoin(1)
;;    JOIN mdf2 WHERE mdf2.item_id = md.item_id
;;	    AND mdf2.flex_type_cd = value(uar_get_code_by("MEANING" ,4062 ,"SYSPKGTYP" ))
;;	    AND mdf2.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
;;	    AND mdf2.active_ind = 1
;;    JOIN mfoi2 WHERE mfoi2.med_def_flex_id = mdf2.med_def_flex_id
;;    JOIN cv1 WHERE cv1.code_value = mfoi2.parent_entity_id
;;	    AND cv1.code_set = 220
;;	    AND cv1.code_value = cur_facility_cd
;;	    AND cv1.cdf_meaning = "FACILITY"
;;    JOIN ocir WHERE ocir.item_id = md.item_id
;;    JOIN ocs WHERE ocs.synonym_id = outerjoin(mod.ord_as_synonym_id)
;;    JOIN ocs2 WHERE ocs2.catalog_cd = outerjoin(ocir.catalog_cd)
;;   		AND ocs2.mnemonic_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,6011 ,"PRIMARY")))
;;    JOIN p WHERE p.price_sched_id = outerjoin(mod.price_sched_id )
;;    JOIN n WHERE n.nomenclature_id = md.mdx_gfc_nomen_id
;;    JOIN oc WHERE oc.catalog_cd = ocir.catalog_cd
;;    JOIN mi3 WHERE mi3.item_id = outerjoin(md.item_id)
;;	    AND mi3.active_ind = outerjoin(1)
;;	    AND mi3.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"PYXIS")))
;;    JOIN mi5 WHERE mi5.item_id = outerjoin(mi.item_id)
;;	    AND mi5.active_ind = outerjoin(1)
;;	    AND mi5.primary_ind = outerjoin(1)
;;	    AND mi5.med_product_id = outerjoin(0 )
;;	    AND mi5.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"BRAND_NAME")))
;;    JOIN mi6 WHERE mi6.item_id = outerjoin(mi.item_id)
;;	    AND mi6.active_ind = outerjoin(1)
;;	    AND mi6.primary_ind = outerjoin(1)
;;	    AND mi6.med_product_id = outerjoin(0)
;;	    AND mi6.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"CDM")))
;;    JOIN mi7 WHERE mi7.item_id = outerjoin(mi.item_id)
;;	    AND mi7.active_ind = outerjoin(1 )
;;	    AND mi7.primary_ind = outerjoin(1 )
;;	    AND mi7.med_product_id = outerjoin(0  )
;;	    AND mi7.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 , "GENERIC_NAME")))
;;    JOIN mi8 WHERE mi8.item_id = outerjoin(mi.item_id)
;;	    AND mi8.active_ind = outerjoin(1)
;;	    AND mi8.primary_ind = outerjoin(1)
;;	    AND mi8.med_product_id = outerjoin(0  )
;;	    AND mi8.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"HCPCS")))
;;    JOIN mi9 WHERE mi9.item_id = outerjoin(mi.item_id)
;;	    AND mi9.active_ind = outerjoin(1)
;;	    AND mi9.primary_ind = outerjoin(1)
;;	    AND mi9.med_product_id = outerjoin(0 )
;;	    AND mi9.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"DESC_SHORT")))
;;    JOIN mi4 WHERE mi4.item_id = outerjoin(mi2.item_id )
;;	    AND mi4.active_ind = outerjoin(1 )
;;	    AND mi4.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"INNER_NDC")))
;;	    AND mi4.med_product_id = outerjoin(mi2.med_product_id)
;;	join mpt where mpt.med_package_type_id = mdf2.med_package_type_id
;;	join bi where bi.ext_parent_reference_id = outerjoin(mdf.med_def_flex_id)
;;	  and bi.ext_parent_contributor_cd = outerjoin(value(UAR_GET_CODE_BY("MEANING", 13016, "MED DEF FLEX")))
;;	  and bi.active_ind = outerjoin(1)
;;	  and bi.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
;;	  and bi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
;;	join bim where bim.bill_item_id = outerjoin(bi.bill_item_id)
;;	  and bim.key1_id = outerjoin(value(UAR_GET_CODE_BY("DISPLAYKEY",14002 ,"HCPCS")))
;;	  and bim.active_ind = outerjoin(1)
;;	  and bim.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
;;	  and bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
;;
;;ORDER BY
;;	cnvtupper(oc.primary_mnemonic)
;;	, mi.value_key
;;	, mfoi3.sequence
;;	, md.item_id
;;
;;WITH nocounter ,separator = " ",format
;; ENDIF
;;END GO

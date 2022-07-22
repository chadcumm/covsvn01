DROP PROGRAM COV_PHA_FORMULARY_EXTRACT_OPS GO
CREATE PROGRAM COV_PHA_FORMULARY_EXTRACT_OPS
 prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Primary NDC Extract Only" = "No"
 
with OUTDEV, ALLNDC
 SET cur_ndc =  $ALLNDC
 ;SET cur_facility_cd = cnvtreal ( $FACILITY )
 IF (cur_ndc = "Yes")
  SELECT INTO $OUTDEV
	med_id = trim (mi3.value ,1 )
	, md.item_id
	, description = trim (mi.value ,1 )
	, order_catalog_primary = trim (oc.primary_mnemonic )
	, mmdc = md.cki
	, drug_formulation = n.source_string
	, primary_ndc = mi2.value
	, inner_ndc = mi4.value
	, default_route = uar_get_code_display (mod.route_cd )
	, form = uar_get_code_display (md.form_cd )
	, strength = mdisp.strength
	, strength_unit = uar_get_code_display (mdisp.strength_unit_cd )
	, volume = mdisp.volume
	, volume_unit = uar_get_code_display (mdisp.volume_unit_cd )
	, given_strength = md.given_strength
	, divisible_ind = evaluate (mdisp.divisible_ind ,0 ,"No" ,1 ,"Yes" )
	, infinite_divisible = evaluate (mdisp.infinite_div_ind ,0 ,"No" ,1 ,"Yes" )
	, min_divisible = mdisp.base_issue_factor
	, default_order_type = evaluate (cnvtint (mdisp.oe_format_flag ) ,cnvtint (0 ) ,"None" ,cnvtint (1) ,
   	"Medication" ,cnvtint (2 ) ,"Continuous" ,cnvtint (3 ) ,"Intermittent" ,"Indeterminate" )
	, med_filter = mdisp.med_filter_ind
	, int_filter = mdisp.intermittent_filter_ind
	, cont_filter = mdisp.continuous_filter_ind
	, ordered_as_synonym = ocs.mnemonic
	, dispense_category = uar_get_code_display (mod.dispense_category_cd )
	, include_total_volume = evaluate (cnvtint (mdisp.used_as_base_ind ) ,cnvtint (0 ) ,"Never" ,
    cnvtint (1 ) ,"Sometimes" ,cnvtint (2 ) ,"Always" )
	, default_dose = evaluate2 (
    IF ((mod.strength_unit_cd > 0 ) ) concat (trim (format (mod.strength ,"#######.####;T(1)" ) ,7 )
      ," " ,uar_get_code_display (mod.strength_unit_cd ) )
    ELSEIF ((mod.volume_unit_cd > 0 ) ) concat (trim (format (mod.volume ,"#######.####;T(1)" ) ,7 )
      ," " ,uar_get_code_display (mod.volume_unit_cd ) )
    ELSE mod.freetext_dose
    ENDIF
    )
	, default_freq = uar_get_code_display (mod.frequency_cd )
	, duration = mod.duration
	, duration_unit = uar_get_code_display (mod.duration_unit_cd )
	, stop_type = uar_get_code_display (mod.stop_type_cd )
	, default_infuse_over = evaluate(mod.infuse_over, -1, 0, mod.infuse_over)
	, default_infuse_over_unit = uar_get_code_display (mod.infuse_over_cd )
	, brand_name = trim (mi5.value ,1 )
	, cdm = trim (mi6.value ,1 )
	, price_schedule = trim(replace(replace(check(p.price_sched_desc), char(10), ""), char(13), ""))
	, dispense_qty = mpt.dispense_qty
	, dispense_qty_unit = uar_get_code_display(mpt.uom_cd)
	, dispense_factor = mdisp.dispense_factor
	, GPO = mch2.cost "#####.#####" ;001
	, AWP = mch.cost "#####.#######"
	, mdisp.WASTE_CHARGE_IND
	, CS_HCPCS = trim(bim.key6)
	, CS_QCF = bim.bim1_nbr "#####.#####"
	, bi.bill_item_id
	, generic_name = trim (mi7.value ,1 )
	, rx_mnemonic = trim (mi9.value ,1 )
	, legal_status = uar_get_code_display (mdisp.legal_status_cd )
   ;facility = cv1.display
 
FROM
	medication_definition   md
	, med_dispense   mdisp
	, med_oe_defaults   mod
	, order_catalog_synonym   ocs
	, order_catalog_synonym   ocs2
	, med_def_flex   mdf
	, med_flex_object_idx   mfoi
	, price_sched   p
	, med_identifier   mi
	, med_identifier   mi2
	, med_def_flex   mdf2
	, med_def_flex mdf3
	, med_flex_object_idx   mfoi3
	, med_def_flex mdf4
	, med_flex_object_idx   mfoi4
	, med_cost_hx   mch
		,MED_COST_HX   			mch2 ;001
	, med_identifier   mi3
	, med_identifier   mi4
	, nomenclature   n
	, order_catalog_item_r   ocir
	, order_catalog   oc
	, med_identifier   mi5
	, med_identifier   mi6
	, med_identifier   mi7
	, med_identifier   mi8
	, med_identifier   mi9
	, med_package_type   mpt
	, bill_item   bi
	, bill_item_modifier   bim
 
PLAN md
	JOIN mdisp WHERE mdisp.item_id = md.item_id
    	AND mdisp.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
    JOIN mdf WHERE mdf.item_id = md.item_id
    	AND mdf.flex_type_cd = value (uar_get_code_by ("MEANING" ,4062 ,"SYSTEM"))
   		AND mdf.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
    	AND mdf.active_ind = 1
    JOIN mfoi WHERE mfoi.med_def_flex_id = mdf.med_def_flex_id
    	AND mfoi.parent_entity_name = "MED_OE_DEFAULTS"
    JOIN mod WHERE mod.med_oe_defaults_id = mfoi.parent_entity_id
    JOIN mi WHERE mi.item_id = md.item_id
	    AND mi.active_ind = 1
	    AND mi.primary_ind = 1
	    AND mi.med_product_id = 0
	    AND mi.med_identifier_type_cd = value(uar_get_code_by ("MEANING" ,11000 ,"DESC"))
	    AND mi.pharmacy_type_cd = value(uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
    JOIN mi2 WHERE mi2.item_id = md.item_id
	    AND mi2.active_ind = 1
	    AND mi2.med_identifier_type_cd = value (uar_get_code_by ("MEANING" ,11000 ,"NDC"))
    JOIN mfoi3 WHERE mfoi3.parent_entity_id = mi2.med_product_id
   		AND mfoi3.sequence = 1 and mfoi3.active_ind = 1
   	join mdf3 where mdf3.med_def_flex_id= mfoi3.med_def_flex_id
    		  and mdf3.active_ind = 1
    		  ;;;;
    JOIN mch WHERE mch.med_product_id = outerjoin (mi2.med_product_id)
   		AND mch.cost_type_cd = outerjoin(value(uar_get_code_by ("MEANING" ,4050 ,"AWP")))
    	AND mch.active_ind = outerjoin(1)
    	AND mch.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	    AND mch.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
	JOIN mch2 WHERE mch2.med_product_id = outerjoin(mi2.med_product_id) ;001
	    AND mch2.cost_type_cd = outerjoin(value(uar_get_code_by("DISPLAY" ,4050 ,"GPO")))
	    AND mch2.active_ind = outerjoin(1)
	    AND mch2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	    AND mch2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    JOIN mdf2 WHERE mdf2.item_id = md.item_id
	    AND mdf2.flex_type_cd = value (uar_get_code_by ("MEANING" ,4062 ,"SYSPKGTYP" ))
	    AND mdf2.pharmacy_type_cd = value (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT"))
	    AND mdf2.active_ind = 1
    ;JOIN mfoi2	WHERE mfoi2.med_def_flex_id = mdf2.med_def_flex_id
    ;JOIN cv1 WHERE cv1.code_value = mfoi2.parent_entity_id
	    ;AND cv1.code_set = 220
	    ;AND cv1.code_value = cur_facility_cd
	    ;AND cv1.cdf_meaning = "FACILITY"
    JOIN ocir WHERE ocir.item_id = md.item_id
    JOIN ocs WHERE ocs.synonym_id = outerjoin(mod.ord_as_synonym_id)
    JOIN ocs2 WHERE ocs2.catalog_cd = outerjoin(ocir.catalog_cd)
    	AND ocs2.mnemonic_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,6011 ,"PRIMARY")))
    JOIN p WHERE p.price_sched_id = outerjoin(mod.price_sched_id)
    JOIN n WHERE n.nomenclature_id = md.mdx_gfc_nomen_id
    JOIN oc WHERE oc.catalog_cd = ocir.catalog_cd
    JOIN mi3 WHERE mi3.item_id = outerjoin (md.item_id)
    	AND mi3.active_ind = outerjoin (1)
    	AND mi3.med_identifier_type_cd = outerjoin(value(uar_get_code_by ("MEANING" ,11000 ,"PYXIS")))
    JOIN mi5 WHERE mi5.item_id = outerjoin(mi.item_id)
	    AND mi5.active_ind = outerjoin(1)
	    AND mi5.primary_ind = outerjoin(1)
	    AND mi5.med_product_id = outerjoin(0)
	    AND mi5.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"BRAND_NAME")))
    JOIN mi6 WHERE mi6.item_id = outerjoin(mi.item_id)
	    AND mi6.active_ind = outerjoin(1)
	    AND mi6.primary_ind = outerjoin(1)
	    AND mi6.med_product_id = outerjoin(0)
	    AND mi6.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"CDM")))
    JOIN mi7 WHERE mi7.item_id = outerjoin(mi.item_id)
	    AND mi7.active_ind = outerjoin(1)
	    AND mi7.primary_ind = outerjoin(1)
	    AND mi7.med_product_id = outerjoin(0)
	    AND mi7.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING",11000,"GENERIC_NAME")))
    JOIN mi8 WHERE mi8.item_id = outerjoin(mi.item_id)
	    AND mi8.active_ind = outerjoin(1)
	    AND mi8.primary_ind = outerjoin(1)
	    AND mi8.med_product_id = outerjoin(0)
	    AND mi8.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"HCPCS")))
    JOIN mi9 WHERE mi9.item_id = outerjoin(mi.item_id)
	    AND mi9.active_ind = outerjoin(1)
	    AND mi9.primary_ind = outerjoin(1)
	    AND mi9.med_product_id = outerjoin(0)
	    AND mi9.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 , "DESC_SHORT")))
    JOIN mi4 WHERE mi4.item_id = outerjoin(mi2.item_id)
	    AND mi4.active_ind = outerjoin(1)
	    AND mi4.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"INNER_NDC")))
	    AND mi4.med_product_id = outerjoin(mi2.med_product_id)
	    and mi4.primary_ind = outerjoin(1)
	    and trim(mi4.value) > outerjoin("")
	JOIN mfoi4 WHERE mfoi4.parent_entity_id = outerjoin(mi4.med_product_id)
   		AND mfoi4.sequence = outerjoin(1 )
   		and mfoi4.active_ind = outerjoin(1)
   	join mdf4 where mdf4.med_def_flex_id= outerjoin(mfoi4.med_def_flex_id)
    		  and mdf4.active_ind = outerjoin(1)
	join mpt where mpt.med_package_type_id = mdf2.med_package_type_id
	join bi where bi.ext_parent_reference_id = outerjoin(mdf.med_def_flex_id)
	  and bi.ext_parent_contributor_cd = outerjoin(value(UAR_GET_CODE_BY("MEANING", 13016, "MED DEF FLEX")))
	  and bi.active_ind = outerjoin(1)
	  and bi.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
	  and bi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
	join bim where bim.bill_item_id = outerjoin(bi.bill_item_id)
	  and bim.key1_id = outerjoin(value(UAR_GET_CODE_BY("DISPLAYKEY",14002 ,"HCPCS")))
	  and bim.active_ind = outerjoin(1)
	  and bim.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
	  and bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
 
ORDER BY
	cnvtupper(oc.primary_mnemonic)
	, mi.value_key
	, md.item_id
 
with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
 ELSE
  SELECT INTO  $OUTDEV
   med_id = trim (mi3.value ,1 ),
   md.item_id,
   description = trim (mi.value ,1 ) ,
   order_catalog_primary = oc.primary_mnemonic ,
   MMDC = md.cki,
   drug_formulation = n.source_string ,
   primary_ndc = evaluate(mfoi3.sequence, 1, "X", ""),
   ndc = mi2.value ,
   inner_ndc = mi4.value ,
   default_route = uar_get_code_display (mod.route_cd ) ,
   form = uar_get_code_display (md.form_cd ) ,
   strength = mdisp.strength ,
   strength_unit = uar_get_code_display (mdisp.strength_unit_cd ) ,
   volume = mdisp.volume ,
   volume_unit = uar_get_code_display (mdisp.volume_unit_cd ) ,
   default_order_type = evaluate (cnvtint (mdisp.oe_format_flag ) ,cnvtint (0 ) ,"None" ,cnvtint (1
     ) ,"Medication" ,cnvtint (2 ) ,"Continuous" ,cnvtint (3 ) ,"Intermittent" ,"Indeterminate" ) ,
   med_filter = mdisp.med_filter_ind ,
   int_filter = mdisp.intermittent_filter_ind ,
   cont_filter = mdisp.continuous_filter_ind ,
   ordered_as_synonym = ocs.mnemonic ,
   dispense_category = uar_get_code_display (mod.dispense_category_cd ) ,
   formulary_status = uar_get_code_display (mdisp.formulary_status_cd ) ,
   include_total_volume = evaluate (cnvtint (mdisp.used_as_base_ind ) ,cnvtint (0 ) ,"Never" ,
    cnvtint (1 ) ,"Sometimes" ,cnvtint (2 ) ,"Always" ) ,
   default_dose = evaluate2 (
    IF ((mod.strength_unit_cd > 0 ) ) concat (trim (format (mod.strength ,"#######.####;T(1)" ) ,7 )
      ," " ,uar_get_code_display (mod.strength_unit_cd ) )
    ELSEIF ((mod.volume_unit_cd > 0 ) ) concat (trim (format (mod.volume ,"#######.####;T(1)" ) ,7 )
      ," " ,uar_get_code_display (mod.volume_unit_cd ) )
    ELSE mod.freetext_dose
    ENDIF
    ) ,
   default_freq = uar_get_code_display (mod.frequency_cd ) ,
   duration = mod.duration ,
   duration_unit = uar_get_code_display (mod.duration_unit_cd ) ,
   stop_type = uar_get_code_display (mod.stop_type_cd ) ,
   default_infuse_over = evaluate(mod.infuse_over, -1, 0, mod.infuse_over) ,
   default_infuse_over_unit = uar_get_code_display (mod.infuse_over_cd ) ,
   price_schedule = check(p.price_sched_desc) ,
   brand_name = trim (mi5.value ,1 ) ,
   cdm = trim (mi6.value ,1 ) ,
   generic_name = trim (mi7.value ,1 ) ,
   rx_mnemonic = trim (mi9.value ,1 ) ,
   cdm = trim (mi6.value ,1 ) ,
   price_schedule = p.price_sched_desc ,
   dispense_qty = mpt.dispense_qty,
   dispense_qty_unit = uar_get_code_display(mpt.uom_cd),
   GPO = mch2.cost "#####.#####",  ;001
   dispense_factor = mdisp.dispense_factor,
   AWP = mch.cost "#####.#######" ,
   CS_HCPCS = trim(bim.key6),
   CS_QCF = bim.bim1_nbr "#####.#####",
   bi.bill_item_id,
   legal_status = uar_get_code_display (mdisp.legal_status_cd )
   ;facility = cv1.display
   FROM medication_definition md,
    med_dispense mdisp,
    med_oe_defaults mod,
    order_catalog_synonym ocs,
    order_catalog_synonym ocs2,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    price_sched p,
    med_identifier mi,
    med_identifier mi2,
    med_def_flex mdf2,
    med_def_flex mdf3,
    med_def_flex mdf4,
    med_flex_object_idx mfoi3,
    med_flex_object_idx mfoi4,
    med_cost_hx mch,
    MED_COST_HX 			mch2, ;001
    med_identifier mi3,
    med_identifier mi4,
    nomenclature n,
    order_catalog_item_r ocir,
    order_catalog oc,
    med_identifier mi5,
    med_identifier mi6,
    med_identifier mi7,
    med_identifier mi8,
    med_identifier mi9,
    ;med_flex_object_idx mfoi2,
    ;code_value cv1,
    med_package_type mpt,
    bill_item bi,
    bill_item_modifier bim
	PLAN md
	JOIN mdisp WHERE mdisp.item_id = md.item_id
    	AND mdisp.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
    JOIN mdf WHERE mdf.item_id = md.item_id
	    AND mdf.flex_type_cd = value(uar_get_code_by("MEANING" ,4062 ,"SYSTEM"))
	    AND mdf.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
	    AND mdf.active_ind = 1
    JOIN mfoi WHERE mfoi.med_def_flex_id = mdf.med_def_flex_id
    	AND mfoi.parent_entity_name = "MED_OE_DEFAULTS"
    JOIN mod WHERE mod.med_oe_defaults_id = mfoi.parent_entity_id
    JOIN mi WHERE mi.item_id = md.item_id
	    AND mi.active_ind = 1
	    AND mi.primary_ind = 1
	    AND mi.med_product_id = 0
	    AND mi.med_identifier_type_cd = value(uar_get_code_by("MEANING" ,11000 ,"DESC"))
	    AND mi.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
    JOIN mi2 WHERE mi2.item_id = md.item_id
	    AND mi2.active_ind = 1
	    AND mi2.med_identifier_type_cd = value(uar_get_code_by("MEANING" ,11000 ,"NDC"))
    JOIN mfoi3 WHERE mfoi3.parent_entity_id = mi2.med_product_id and mfoi3.active_ind = 1
    join mdf3 where mdf3.med_def_flex_id= mfoi3.med_def_flex_id
    		  and mdf3.active_ind = 1
 
    JOIN mch WHERE mch.med_product_id = outerjoin(mi2.med_product_id)
	    AND mch.cost_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,4050 ,"AWP")))
	    AND mch.active_ind = outerjoin(1)
	    AND mch.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	    AND mch.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
	JOIN mch2 WHERE mch2.med_product_id = outerjoin(mi2.med_product_id) ;001
	    AND mch2.cost_type_cd = outerjoin(value(uar_get_code_by("DISPLAY" ,4050 ,"GPO")))
	    AND mch2.active_ind = outerjoin(1)
	    AND mch2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	    AND mch2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    JOIN mdf2 WHERE mdf2.item_id = md.item_id
	    AND mdf2.flex_type_cd = value(uar_get_code_by("MEANING" ,4062 ,"SYSPKGTYP" ))
	    AND mdf2.pharmacy_type_cd = value(uar_get_code_by("MEANING" ,4500 ,"INPATIENT"))
	    AND mdf2.active_ind = 1
    ;JOIN mfoi2 WHERE mfoi2.med_def_flex_id = mdf2.med_def_flex_id
    ;JOIN cv1 WHERE cv1.code_value = mfoi2.parent_entity_id
	    ;AND cv1.code_set = 220
	    ;AND cv1.code_value = cur_facility_cd
	    ;AND cv1.cdf_meaning = "FACILITY"
    JOIN ocir WHERE ocir.item_id = md.item_id
    JOIN ocs WHERE ocs.synonym_id = outerjoin(mod.ord_as_synonym_id)
    JOIN ocs2 WHERE ocs2.catalog_cd = outerjoin(ocir.catalog_cd)
   		AND ocs2.mnemonic_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,6011 ,"PRIMARY")))
    JOIN p WHERE p.price_sched_id = outerjoin(mod.price_sched_id )
    JOIN n WHERE n.nomenclature_id = md.mdx_gfc_nomen_id
    JOIN oc WHERE oc.catalog_cd = ocir.catalog_cd
    JOIN mi3 WHERE mi3.item_id = outerjoin(md.item_id)
	    AND mi3.active_ind = outerjoin(1)
	    AND mi3.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"PYXIS")))
    JOIN mi5 WHERE mi5.item_id = outerjoin(mi.item_id)
	    AND mi5.active_ind = outerjoin(1)
	    AND mi5.primary_ind = outerjoin(1)
	    AND mi5.med_product_id = outerjoin(0 )
	    AND mi5.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"BRAND_NAME")))
    JOIN mi6 WHERE mi6.item_id = outerjoin(mi.item_id)
	    AND mi6.active_ind = outerjoin(1)
	    AND mi6.primary_ind = outerjoin(1)
	    AND mi6.med_product_id = outerjoin(0)
	    AND mi6.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"CDM")))
    JOIN mi7 WHERE mi7.item_id = outerjoin(mi.item_id)
	    AND mi7.active_ind = outerjoin(1 )
	    AND mi7.primary_ind = outerjoin(1 )
	    AND mi7.med_product_id = outerjoin(0  )
	    AND mi7.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 , "GENERIC_NAME")))
    JOIN mi8 WHERE mi8.item_id = outerjoin(mi.item_id)
	    AND mi8.active_ind = outerjoin(1)
	    AND mi8.primary_ind = outerjoin(1)
	    AND mi8.med_product_id = outerjoin(0  )
	    AND mi8.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"HCPCS")))
    JOIN mi9 WHERE mi9.item_id = outerjoin(mi.item_id)
	    AND mi9.active_ind = outerjoin(1)
	    AND mi9.primary_ind = outerjoin(1)
	    AND mi9.med_product_id = outerjoin(0 )
	    AND mi9.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"DESC_SHORT")))
    JOIN mi4 WHERE mi4.item_id = outerjoin(mi2.item_id )
	    AND mi4.active_ind = outerjoin(1 )
	    AND mi4.med_identifier_type_cd = outerjoin(value(uar_get_code_by("MEANING" ,11000 ,"INNER_NDC")))
	    AND mi4.med_product_id = outerjoin(mi2.med_product_id)
	    and trim(mi4.value) > outerjoin("")
    JOIN mfoi4 WHERE mfoi4.parent_entity_id = outerjoin(mi4.med_product_id)
    	and mfoi4.active_ind = outerjoin(1)
    join mdf4 where mdf4.med_def_flex_id= outerjoin(mfoi4.med_def_flex_id)
    		  and mdf4.active_ind = outerjoin(1)
	join mpt where mpt.med_package_type_id = mdf2.med_package_type_id
	join bi where bi.ext_parent_reference_id = outerjoin(mdf.med_def_flex_id)
	  and bi.ext_parent_contributor_cd = outerjoin(value(UAR_GET_CODE_BY("MEANING", 13016, "MED DEF FLEX")))
	  and bi.active_ind = outerjoin(1)
	  and bi.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
	  and bi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
	join bim where bim.bill_item_id = outerjoin(bi.bill_item_id)
	  and bim.key1_id = outerjoin(value(UAR_GET_CODE_BY("DISPLAYKEY",14002 ,"HCPCS")))
	  and bim.active_ind = outerjoin(1)
	  and bim.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate, curtime3))
	  and bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime3))
   ORDER BY
   		cnvtupper(oc.primary_mnemonic),
   		mi.value_key,
	    mfoi3.sequence,
	    md.item_id
   with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
 
 ENDIF
END GO

/***********************************************************************************************************************
  Program Name:       	BC_ALL_MP_ONC_MED_DISP.PRG
  Source File Name:   	BC_ALL_MP_ONC_MED_DISP.PRG
  Program Written By: 	John Simpson
  Date:  			  	18-Feb-2019
  Program Purpose:   	Oncology Medication Dispense MPage data retrieval
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  18-Feb-2019  CST-37011  John Simpson           Created
001  18-Mar-2020  CST-54290  John Simpson           Added support for parent orders
002  15-Jul-2020  CST-85766  Travis Cazes			Added Brandname to durg name
***********************************************************************************************************************/
 
drop program bc_all_mp_onc_med_disp:dba go
create program bc_all_mp_onc_med_disp:dba
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "personId" = ""
 
with OUTDEV, personId
 
;bc_all_mp_onc_med_disp "MINE","13700939" go
 
execute bc_all_all_date_routines
 
; Misc variables
declare nPersonId = f8 with noconstant(cnvtreal($personId))
declare nNum = i4
declare cXML = vc
 
; Collect code values
declare cvOncologyPathway = f8 with noconstant(uar_get_code_by("DISPLAYKEY", 30184, "ONCOLOGY"))
declare cvPathwayCompleted = f8 with noconstant(uar_get_code_by("MEANING", 16769, "COMPLETED"))
declare cvPathwayInitiated = f8 with noconstant(uar_get_code_by("MEANING", 16769, "INITIATED"))
declare cvCompActivated = f8 with noconstant(uar_get_code_by("MEANING", 16789, "ACTIVATED"))
declare cvCompIncluded = f8 with noconstant(uar_get_code_by("MEANING", 16789, "INCLUDED"))
 
declare cvPathwayExcluded = f8 with noconstant(uar_get_code_by("MEANING", 16769, "EXCLUDED"))
declare cvPathwayFuture = f8 with noconstant(uar_get_code_by("MEANING", 16769, "FUTURE"))
declare cvPathwayFutureReview = f8 with noconstant(uar_get_code_by("MEANING", 16769, "FUTUREREVIEW"))
declare cvPathwayFuturePropose = f8 with noconstant(uar_get_code_by("MEANING", 16769, "FUTUREPROPOSE"))
declare cvPathwayPlanned = f8 with noconstant(uar_get_code_by("MEANING", 16769, "PLANNED"))
 
declare cvCanceled = f8 with noconstant(uar_get_code_by("MEANING", 6004, "CANCELED"))
declare cvDeleted = f8 with noconstant(uar_get_code_by("MEANING", 6004, "DELETED"))
declare cvFuture = f8 with noconstant(uar_get_code_by("MEANING", 6004, "FUTURE"))
declare cvVoidResult = f8 with noconstant(uar_get_code_by("MEANING", 6004, "VOIDEDWRSLT"))
declare cvCAPApprovedProtocol = f8 with noconstant(uar_get_code_by("DISPLAYKEY", 200, "CAPAPPROVEDPROTOCOL"))
 
;bradname med identifier
declare cvBrandName = f8 with constant(uar_get_code_by("MEANING", 11000, "BRAND_NAME")), protect ;002
 
; Declare internal subroutines
declare ParseXMLTag(cXML = vc, cTag = vc) = vc with persist
 
; Define the report structure
record response (
	1 data[*]
		2 order_id					= f8
		2 cycle						= i4
		2 regimen					= vc
		2 day_of_treatment			= i4
		2 treatment_date			= vc
		2 drug_name					= vc
		2 target_dose				= vc
		2 actual_dose				= vc
		2 dose_adjust_reason		= vc
		2 dose_administered			= vc
		2 route						= vc
		2 cap_indicator             = vc
		2 orig_ord_as_flag			= i4
		2 oi_action_sequence		= i4	;used to get brand name
		2 oi_comp_sequence			= i4	;used to get brand name
		2 oi_item_id				= i4	;used to get brand name
)
 
; Define the reference record structure
record ref (
	1 antineoplastics[*]
		2 synonym_id				= f8
)
 
; Store the Antineoplastics
select into "nl:"
    synonym_id = if (asl.synonym_id != 0)
    				asl.synonym_id
       			 else
       			 	asl2.synonym_id
        		 endif
from	alt_sel_list		asl,
        alt_sel_cat			a,
        alt_sel_cat			a2,
        alt_sel_list		asl2
plan asl
join a
	where a.alt_sel_category_id = asl.alt_sel_category_id
	and a.short_description = "20"
	and a.long_description_key_cap = "ANTINEOPLASTICS"
join a2
	where a2.alt_sel_category_id = asl.child_alt_sel_cat_id
join asl2
	where asl2.alt_sel_category_id = a2.alt_sel_category_id
order by synonym_id
head report
	nCount = 0
head synonym_id
	nCount = nCount + 1
	stat = alterlist(ref->antineoplastics, nCount)
	ref->antineoplastics[nCount].synonym_id = synonym_id
with counter
 
 
; Collect the core data
select  into "nl:"
	order_id				= o.order_id,
	regimen					= substring(1,150,p.pw_group_desc),
	cycle					= p.cycle_nbr,
	day_of_treatment		= if (p.period_nbr = 0)
								1
							  else
							  	p.period_nbr
							  endif,
	treatment_date			= p.start_dt_tm,
	drug_type_indicator		= o.orig_ord_as_flag,
	drug_name				= uar_get_code_display(oi.catalog_cd),
	target_dose				= if (oi.ordered_dose > 0.0)
								concat(trim(format(oi.ordered_dose, "#######.####;t(1)"),3)," ",
											uar_get_code_display(oi.ordered_dose_unit_cd))
							  endif,
	admin_start_dt_tm		= ce.admin_start_dt_tm,
	dose_adjust_reason		= oi.dose_adjustment_display,
	dose_administered		= ce.event_tag,
	action_sequence			= oi.action_sequence,
	med_qual				= if (apc.chemo_ind = 1 or o.orig_ord_as_flag = 1 or
									locateval(nNum, 1, size(ref->antineoplastics, 5), o.synonym_id,
															ref->antineoplastics[nNum].synonym_id) > 0)
								;if (apc.chemo_ind = 1 or asl.synonym_id > 0 or o.orig_ord_as_flag = 1)
								1
							  endif,
	cancel_ind				= if (o.discontinue_ind = 1 and ce.order_id = 0)
								1
							  endif,
	long_text				= lt.long_text,
	cap_indicator           = if (cap.pw_group_nbr > 0)
	                              "Yes"
	                          endif
from	pathway				p,
		act_pw_comp			apc,
		orders				o,
		order_ingredient	oi,
		long_text			lt,
		((		; Med Admin           -- 001
			select
			    order_id = ceol.parent_order_ident,
				ce.catalog_cd,
				ce.event_tag,
				cmr.admin_start_dt_tm
			from	clinical_event		ce,
					ce_med_result		cmr,
					ce_event_order_link ceol
			where ce.authentic_flag = 1
			and ce.valid_until_dt_tm > sysdate
			and cmr.event_id = ce.event_id
			and cmr.valid_until_dt_tm > sysdate
			and ceol.event_id = cmr.event_id
			and ceol.valid_until_dt_tm > sysdate
			with sqltype("f8","f8","vc","dq8")) ce
		),
/*
		((		; Med Admin
			select
				ce.order_id,
				ce.catalog_cd,
				ce.event_tag,
				cmr.admin_start_dt_tm
			from	clinical_event		ce,
					ce_med_result		cmr
			where ce.authentic_flag = 1
			and ce.valid_until_dt_tm > sysdate
			and cmr.event_id = ce.event_id
			and cmr.valid_until_dt_tm > sysdate
			with sqltype("f8","f8","vc","dq8")) ce
		),
*/
		((        ; CAP Identifier
		  select p.pw_group_nbr
		  from    pathway               p,
		          act_pw_comp           apc,
		          orders                o
		  where p.type_mean = "PHASE"
		  and apc.pathway_id = p.pathway_id
		  and apc.parent_entity_name = "ORDERS"
		  and o.order_id = apc.parent_entity_id
		  and o.catalog_cd = cvCAPApprovedProtocol
		  with sqltype("f8")) cap
		)
		;,
/*
		((		; Ther Category (20/antineoplastics)
			select
				asl.synonym_id,
				a.short_description,
				a.long_description
			from	alt_sel_list		asl,
					alt_sel_cat			a
			where a.alt_sel_category_id = asl.alt_sel_category_id
			and a.short_description = "20"
			and a.long_description_key_cap = "ANTINEOPLASTICS"
			with sqltype("f8","vc","vc")) asl
		)
*/
plan p
	where p.person_id = nPersonId
	and p.pathway_class_cd = cvOncologyPathway
;	and p.pw_status_cd not in (cvPathwayExcluded,cvPathwayFuture,cvPathwayFutureReview,cvPathwayFuturePropose,cvPathwayPlanned)
	;and p.pw_status_cd in (cvPathwayCompleted, cvPathwayInitiated)
;	and p.type_mean = "DOT"
	and p.active_ind = 1
join apc
	where apc.pathway_id = p.pathway_id
	and apc.parent_entity_name = "ORDERS"
	and apc.parent_entity_id > 0
	and apc.comp_status_cd in (cvCompActivated, cvCompIncluded)	; Not on spec, need to check with analyst
;	and apc.chemo_ind = 1
	and apc.active_ind = 1
join o
	where o.order_id = apc.parent_entity_id
	and o.template_order_flag != 7
	and o.order_status_cd not in (cvCanceled, cvDeleted, cvFuture, cvVoidResult)
join oi
	where oi.order_id = o.order_id
	and oi.ingredient_type_flag in (1, 3)		; Medication, Additive
;	and oi.action_sequence = o.last_action_sequence
	and oi.action_sequence = o.last_ingred_action_sequence
	and oi.clinically_significant_flag = 2
join lt
	where lt.long_text_id = oi.dose_calculator_long_text_id
join ce
	where ce.order_id = outerjoin(oi.order_id)
	and ce.catalog_cd = outerjoin(oi.catalog_cd)
;join asl
;	where asl.synonym_id = outerjoin(o.synonym_id)
join cap
    where cap.pw_group_nbr = outerjoin(p.pw_group_nbr)
order treatment_date desc, regimen, cycle, day_of_treatment, admin_start_dt_tm desc, order_id, action_sequence
;/*
head report
	nCount = 0
head treatment_date
	x = 0
head regimen
	x = 0
head cycle
	x = 0
head day_of_treatment
	x = 0
head admin_start_dt_tm
	x = 0
head order_id
	x = 0
/*
	if (med_qual = 1)
		nCount = nCount + 1
		stat = alterlist(response->data, nCount)
 
		response->data[nCount].order_id = order_id
		response->data[nCount].cycle = cycle
		response->data[nCount].regimen = regimen
		response->data[nCount].day_of_treatment = day_of_treatment
		response->data[nCount].treatment_date = sCST_DATE(treatment_date)
		response->data[nCount].drug_name = drug_name
		;response->data[nCount].target_dose = target_dose
		response->data[nCount].dose_administered = dose_administered
 
		; If there is XML, convert it to a structure and parse out the values we need
		if (findstring("<DosageInformation>", long_text) > 0)
			response->data[nCount].target_dose = concat(ParseXMLTag(long_text, "TargetDose"), " ",
													ParseXMLTag(long_text, "TargetDoseUnitDisp"))
			response->data[nCount].actual_dose = concat(ParseXMLTag(long_text, "ActualFinalDose"), " ",
													ParseXMLTag(long_text, "ActualFinalDoseUnitDisp"))
		endif
	endif
*/
head action_sequence
	x = 0
detail
	if (med_qual = 1 and cancel_ind != 1)
		nCount = nCount + 1
		stat = alterlist(response->data, nCount)
 
		response->data[nCount].order_id = order_id
		response->data[nCount].cycle = cycle
		response->data[nCount].regimen = regimen
		response->data[nCount].day_of_treatment = day_of_treatment
		response->data[nCount].treatment_date = sCST_DATE(treatment_date)
		response->data[nCount].drug_name = drug_name
		response->data[nCount].cap_indicator = cap_indicator
		response->data[nCount].orig_ord_as_flag = o.orig_ord_as_flag
 
 		response->data[nCount].oi_action_sequence = oi.action_sequence ;002
 		response->data[nCount].oi_comp_sequence = oi.comp_sequence ;002
 
		;response->data[nCount].target_dose = target_dose
		if (o.orig_ord_as_flag = 1)
		  response->data[nCount].dose_administered = concat(ParseXMLTag(long_text, "FinalDose"), " ",
		                      ParseXMLTag(long_text, "FinalDoseUnitDisp"))
		else
		  response->data[nCount].dose_administered = dose_administered
	    endif
 
		; If there is XML, convert it to a structure and parse out the values we need
		if (findstring("<DosageInformation>", long_text) > 0)
			response->data[nCount].target_dose = concat(ParseXMLTag(long_text, "TargetDose"), " ",
													ParseXMLTag(long_text, "TargetDoseUnitDisp"))
			response->data[nCount].actual_dose = concat(ParseXMLTag(long_text, "ActualFinalDose"), " ",
													ParseXMLTag(long_text, "ActualFinalDoseUnitDisp"))
		elseif (oi.comp_sequence > 1 and oi.strength != 0.0)
			response->data[nCount].actual_dose = concat(trim(format(oi.strength,"#########.####;T(1)")),
														" ", uar_get_code_display(oi.strength_unit))
		elseif (oi.comp_sequence > 1)
			response->data[nCount].actual_dose = concat(trim(format(oi.volume,"#########.####;T(1)")),
														" ", uar_get_code_display(oi.volume_unit))
		endif
	endif
 
	if (med_qual = 1 and trim(dose_adjust_reason) != "")
		response->data[nCount].dose_adjust_reason = dose_adjust_reason
	endif
with counter
;*/
 
; Create empty result if no data qualified
if (size(response->data, 5) = 0)
	set stat = alterlist(response->data, 1)
	set response->data[1].regimen = "NODATA"
	set response->data[1].drug_name = "No data qualified for this patient."
 
	go to end_program
endif
 
; Collect the order details
select into "nl:"
	order_id					= od.order_id,
	oe_field_meaning			= od.oe_field_meaning,
	action_sequence				= od.action_sequence,
	oe_field_display_value		= od.oe_field_display_value
from	order_detail			od
plan od
	where expand(nNum, 1, size(response->data, 5), od.order_id, response->data[nNum].order_id)
	and od.oe_field_meaning in ("STRENGTHDOSE", "STRENGTHDOSEUNIT","VOLUMEDOSE","VOLUMEDOSEUNIT","RXROUTE")
order order_id, oe_field_meaning, action_sequence
head order_id
	cRoute = fillstring(40, " ")
	cStrengthDose = fillstring(40, " ")
	cStrengthUnit = fillstring(40, " ")
	cVolumeDose = fillstring(40, " ")
	cVolumeDoseUnit = fillstring(40, " ")
head oe_field_meaning
	x = 0
head action_sequence
	x = 0
detail
	case (oe_field_meaning)
		of "RXROUTE":			cRoute = oe_field_display_value
		of "STRENGTHDOSE":		cStrengthDose = oe_field_display_value
		of "STRENGTHDOSEUNIT":	cStrengthUnit = oe_field_display_value
		of "VOLUMEDOSE":		cVolumeDose = oe_field_display_value
		of "VOLUMEDOSEUNIT":	cVolumeDoseUnit = oe_field_display_value
	endcase
foot action_sequence
	x = 0
foot oe_field_meaning
	x = 0
foot order_id
	nPos = 0
	while (locateval(nNum, nPos + 1, size(response->data, 5), order_id, response->data[nNum].order_id) > 0)
		nPos = nNum		; Do not remove or endless loop will occur
 
		response->data[nNum].route = cRoute
 
		if (trim(response->data[nNum].actual_dose) = "")
			if (trim(cStrengthDose) != "")
				response->data[nNum].actual_dose = concat(trim(cStrengthDose), " ", trim(cStrengthUnit))
			else
	 			response->data[nNum].actual_dose = concat(trim(cVolumeDose), " ", trim(cVolumeDoseUnit))
	 		endif
 		endif
 
 		if (response->data[nNum].orig_ord_as_flag = 1)
 			response->data[nNum].dose_administered = response->data[nNum].actual_dose
 		endif
 
	endwhile
with expand=2, counter
 
; Collect the order brand name *002
select into $outdev;"nl:"
	order_id				= op.order_id
	, brandName	 			= cnvtUpper(mid.value)
 
from	order_product		op
		, med_identifier 	mid
 
plan op		where	expand(nNum, 1, size(response->data, 5),op.order_id,response->data[nNum].order_id
													,op.action_sequence,response->data[nNum].oi_action_sequence
													,op.ingred_sequence,response->data[nNum].oi_comp_sequence		)
 
join mid 	where 	mid.item_id 					= 	op.item_id
		    and 	mid.active_ind 					= 	1
		    and 	mid.primary_ind 				= 	1
		    and 	mid.med_identifier_type_cd 		= 	cvBrandName
			and		mid.med_product_id 				= 	0
 
order order_id, op.action_sequence, op.ingred_sequence, mid.primary_ind, mid.updt_dt_tm
 
head order_id				x=0
head op.action_sequence		x=0
head op.ingred_sequence 	nPos = 0
foot op.ingred_sequence		while (locateval(nNum, nPos+1, size(response->data, 5), order_id,response->data[nNum].order_id
																		 ,op.action_sequence,response->data[nNum].oi_action_sequence
														 				 ,op.ingred_sequence,response->data[nNum].oi_comp_sequence) > 0)
								nPos = nNum		; Do not remove or endless loop will occur
								response->data[nNum].drug_name =  concat(trim(response->data[nNum].drug_name,3)," (",trim(brandName,3),")")
							endwhile		;*/
foot op.action_sequence 	x=0
foot order_id				x=0
with format, separator=' ', expand=2, counter
 
; Subroutine to pull element from XML string
subroutine ParseXMLTag(cXMLString, cXMLTag)
	set cRetVal = fillstring(40, " ")
	set nFromXml = findstring(">", cXMLString, findstring(concat("<",trim(cXMLTag)), cXMLString))
	set nToXml = findstring(concat("</",trim(cXMLTag),">"), cXMLString)
 
 
	if (nFromXml > 0 and nToXML > nFromXML)
		set cRetVal = substring(nFromXml + 1, nToXML - nFromXML - 1, cXMLString)
 
		; Check to see if it is a number
		if (cnvtreal(cRetVal) != 0.0)
			return (trim(format(cnvtreal(cretval),"########.###;T(1)"),3))
		else
			return (cRetVal)
		endif
 
	else
		return (nFromXml)
	endif
end
 
#end_program
 
SET _Memory_Reply_String = cnvtrectojson(response, 4, 1)
 
end go
 

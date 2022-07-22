 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Des'2018
	Solution:			Pharmacy/PharmNet
	Source file name:	      cov_pha_scorecard_charges.prg
	Object name:		cov_pha_scorecard_charges
 
	Request#:			3487
	Program purpose:	      Pharmacy Score card Charge extract.
	Executing from:		Ops
 	Special Notes:          Astream to Jerry Inman
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
DROP PROGRAM cov_pha_scorecard_charges :dba go
CREATE PROGRAM cov_pha_scorecard_charges :dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "FacilityListBox" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
/***************************************************************************
	DECLARED VARIABLES
***************************************************************************/
declare mcnt = i4 with noconstant(0), protect
declare cnt = i4 with noconstant(0),protect
declare idx = i4 with protect ,noconstant (0 )
declare item_number = vc with protect ,noconstant ("" )
declare star_var         = f8 with constant(uar_get_code_by("DISPLAY", 263, 'STAR Doctor Number')), protect
 
declare oe_freq = f8 with protect ,constant (12690.00 )
declare oe_strengthdose = f8 with protect ,constant (12715.00 )
declare oe_strengthdoseunit = f8 with protect ,constant (12716.00 )
declare oe_volumedose = f8 with protect ,constant (12718.00 )
declare oe_volumedoseunit = f8 with protect ,constant (12719.00 )
declare oe_drugform = f8 with protect ,constant (12693.00 )
declare oe_duration = f8 with protect ,constant (12721.00 )
declare oe_durationunit = f8 with protect ,constant (12723.00 )
declare oe_rxroute = f8 with protect ,constant (12711.00 )
declare oe_rate = f8 with protect ,constant (12704.00 )
declare oe_rate_unit = f8 with protect ,constant (633585.00 )
declare expand_idx = i4 with protect ,noconstant (0 )
 
declare frequency_code = f8 with protect ,noconstant (0.0 )
declare frequency = vc with protect ,noconstant ("" )
declare strength_dose = vc with protect ,noconstant ("" )
declare strength_dose_unit = vc with protect ,noconstant ("" )
declare volume_dose = vc with protect ,noconstant ("" )
declare volume_dose_unit = vc with protect ,noconstant ("" )
declare drug_form = vc with protect ,noconstant ("" )
declare duration = vc with protect ,noconstant ("" )
declare duration_unit = vc with protect ,noconstant ("" )
declare rate = vc with protect ,noconstant ("" )
declare rate_unit = vc with protect ,noconstant ("" )
declare route = vc with protect ,noconstant ("" )
 
declare drug_brand_name = vc with protect ,noconstant ("" )
declare drug_generic_name = vc with protect ,noconstant ("" )
declare item_number = vc with protect ,noconstant ("" )
declare brandname_var = f8 with constant(uar_get_code_by("DISPLAY", 11000, "Brand Name")),protect
declare chargenumber_var = f8 with constant(uar_get_code_by("DISPLAY", 11000, "Charge Number")),protect
declare genericname_var = f8 with constant(uar_get_code_by("DISPLAY", 11000, "Generic Name")),protect
 
declare mcnt = i4 with noconstant(0), protect
declare cnt = i4 with noconstant(0),protect
declare idx = i4 with protect ,noconstant (0 )
declare output_charges = vc
 
 
/*
;Ops setup
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
declare filename_var = vc WITH noconstant(CONCAT('cer_temp:',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_pha_scorecard_charges.txt')), PROTECT
declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_pha_scorecard_charges.txt')), PROTECT
declare astream_filepath_var = vc with noconstant("/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Pharmacy/PAExports/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
*/
 
/***************************************************************************
	RECORD STRUCTURE
***************************************************************************/
Record charge(
	1 rec_cnt = i4
	1 clist[*]
		2 facility_cd = f8
		2 strata_facility_cd = vc
		2 fin = vc
		2 mrn = vc
		2 cmrn = vc
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 parent_charge_item_id = f8
		2 template_ord_id = f8
		2 template_ord_flag = i4
		2 ce_event_id = f8
		2 order_cki = vc
		2 action_sequence = i4
		2 item_id = f8
		2 synonym_id = f8
		2 bill_item_id = f8
		2 item_number = vc
		2 charge_event_id = f8
		2 charge_event_act_id = f8
		2 strength_dose = vc
		2 strength_dose_unit = vc
		2 volume_dose = vc
		2 volume_dose_unit = vc
		2 service_dt = vc
		2 credited_dt = vc
		2 quantity = f8
		2 quantity_unit_cd = vc
		2 charge_type = vc
		2 charge_description = vc
		2 activity_type = vc
		2 activity_sub_type = vc
		2 admit_dt = vc
		2 disch_dt = vc
		2 drug_class_code1 = vc
		2 drug_class_code2 = vc
		2 drug_class_code3 = vc
		2 pr_chrg_entered = f8
		2 pr_name_chrg_entered = vc
 
)
 
;----------------------------------------------------------------------------------------------------
;get Charge Details
 
select distinct into 'NL:'
 
 ch.person_id, ch.encntr_id,ch.order_id, ch.bill_item_id, ch.charge_item_id
, ch.charge_description, ch.item_quantity
, char_type = uar_get_code_display(ch.charge_type_cd)
, service_dt = format(ch.service_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, credited_dt = format(ch.credited_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from
	charge ch
	,encounter e
	,orders o
	,order_catalog_item_r oci
 
plan ch where ch.service_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ch.charge_type_cd != 3491.00 ;NO CHARGE
	and ch.activity_type_cd = 705.00 ;Pharmacy
	and ch.active_ind = 1
	and ch.encntr_id != 0
	and ch.order_id != 0
 
join e where e.loc_facility_cd = $facility_list
	and e.person_id = ch.person_id
	and e.encntr_id = ch.encntr_id
	and e.active_ind = 1
 
join o where o.order_id = ch.order_id
	and o.order_id != 0
	and o.active_ind = 1
 
join oci where oci.catalog_cd = o.catalog_cd
 
order by ch.encntr_id, ch.order_id, ch.bill_item_id, ch.charge_type_cd, ch.service_dt_tm
	, ch.credited_dt_tm,ch.charge_description, ch.charge_event_id, ch.charge_item_id
 
 
Head report
	mcnt = 0
	call alterlist(charge->clist, 100)
 
Head ch.charge_item_id
	 mcnt += 1
	 charge->rec_cnt = mcnt
 	call alterlist(charge->clist, mcnt)
 
Detail
      cki_pos = findstring("!" ,o.cki )
      cki_len = textlen(o.cki)
	cki_val = trim(substring((cki_pos + 1 ) ,cki_len ,o.cki))
 
	charge->clist[mcnt].facility_cd = e.loc_facility_cd
	charge->clist[mcnt].strata_facility_cd =
		if(e.loc_facility_cd = 21250403.00) '20' ;FSR
		 	elseif(e.loc_facility_cd = 2552503613.00) '24' ;MMC
		 	elseif(e.loc_facility_cd = 2553765579.00) '65' ;G
		 	elseif(e.loc_facility_cd = 2552503635.00) '28' ;FLMC
		 	elseif(e.loc_facility_cd = 2552503639.00) '25' ;MHHS
			elseif(e.loc_facility_cd = 2552503645.00) '22' ;PW
		 	elseif(e.loc_facility_cd = 2552503649.00) '27' ;RMC
		 	elseif(e.loc_facility_cd = 2552503653.00) '26' ;LCMC
		endif
	charge->clist[mcnt].personid = ch.person_id
	charge->clist[mcnt].encntrid = ch.encntr_id
	charge->clist[mcnt].orderid = ch.order_id
	charge->clist[mcnt].template_ord_flag = o.template_order_flag
	charge->clist[mcnt].template_ord_id = o.template_order_id
 	charge->clist[mcnt].order_cki = cki_val
 	charge->clist[mcnt].item_id = oci.item_id
 	charge->clist[mcnt].parent_charge_item_id = ch.parent_charge_item_id
 	charge->clist[mcnt].charge_event_id = ch.charge_event_id
 	charge->clist[mcnt].charge_event_act_id = ch.charge_event_act_id
 	charge->clist[mcnt].charge_description = ch.charge_description
	charge->clist[mcnt].service_dt = format(ch.service_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	charge->clist[mcnt].charge_type = char_type
	charge->clist[mcnt].credited_dt = format(ch.credited_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	charge->clist[mcnt].bill_item_id = ch.bill_item_id
	charge->clist[mcnt].quantity = ch.item_quantity
	charge->clist[mcnt].pr_chrg_entered = ch.updt_id
	charge->clist[mcnt].activity_type = uar_get_code_display(ch.activity_type_cd)
	charge->clist[mcnt].activity_sub_type = uar_get_code_display(ch.activity_sub_type_cd)
 
	/*if(charge->clist[mcnt].template_ord_flag = 4);child orders
		if(o.template_order_id != 0)
			charge->clist[mcnt].orderid = o.template_order_id
		endif
	endif*/
 
Foot ch.charge_item_id
 	call alterlist(charge->clist, mcnt)
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;get item quantity unit
 
select distinct into 'NL:'
 
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	, order_product op
 
plan d
 
join op where op.order_id = charge->clist[d.seq].orderid
	and op.action_sequence = charge->clist[d.seq].action_sequence
 
order by op.order_id
 
Head op.order_id
	cnt = 0
	idx = 0
      idx = locateval(cnt,1,size(charge->clist,5),op.order_id, charge->clist[cnt].orderid)
 
      while(idx > 0)
		if(charge->clist[idx].quantity_unit_cd = '')
			charge->clist[idx].quantity_unit_cd = uar_get_code_display(op.dose_quantity_unit_cd)
		endif
		if(charge->clist[idx].item_id = 0) charge->clist[idx].item_id = op.item_id endif
 
 		idx = locateval(cnt,(idx+1),size(charge->clist,5),op.order_id, charge->clist[cnt].orderid)
	endwhile
 
Foot op.order_id
	null
 
With nocounter
 
;------------------------------------------------------------------------------------------------------------
 
select distinct into 'nl:' ;$outdev
 
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	, order_ingredient oi
 
plan d
 
join oi where oi.order_id = charge->clist[d.seq].orderid
	and oi.dose_quantity_unit != 0
	;and oi.synonym_id = charge->clist[d.seq].synonym_id
	;and oi.action_sequence = (select max(oi2.action_sequence) from order_ingredient oi2
	;	where oi2.order_id = oi.order_id)
 
order by oi.order_id
 
 
Head oi.order_id
	idx = 0
	vcnt = 0
	idx = locateval(vcnt,1,size(charge->clist,5),oi.order_id, charge->clist[vcnt].orderid)
 
	while(idx > 0)
		if(charge->clist[idx].strength_dose = '0.000' or charge->clist[idx].strength_dose = '')
			if(oi.strength = 0)
			 	charge->clist[idx].strength_dose = cnvtstring(oi.strength, 15,3)
			 else
				charge->clist[idx].strength_dose = cnvtstring(oi.strength)
			endif
			charge->clist[idx].strength_dose_unit = uar_get_code_display(oi.strength_unit)
		endif
		if(charge->clist[idx].volume_dose = '')
			charge->clist[idx].volume_dose = cnvtstring(oi.volume)
			charge->clist[idx].volume_dose_unit = uar_get_code_display(oi.volume_unit)
		endif
		if(charge->clist[idx].quantity != 0)
			;charge->clist[idx].quantity = oi.dose_quantity
			if(charge->clist[idx].quantity_unit_cd = '')
				charge->clist[idx].quantity_unit_cd = uar_get_code_display(oi.dose_quantity_unit)
			endif
		endif
 
		idx = locateval(vcnt,(idx+1),size(charge->clist,5),oi.order_id, charge->clist[vcnt].orderid)
 	endwhile
 
Foot oi.order_id
	Null
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;get Patient Demographic
 
select distinct into 'NL:'
 
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	, encounter e
	, encntr_alias ea
	, encntr_alias ea1
	, person_alias pa
 
plan d
 
join e where e.person_id = charge->clist[d.seq].personid
	and e.encntr_id = charge->clist[d.seq].encntrid
	and e.encntr_id != 0.00
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1079 ;MRN
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.active_ind = 1
	and ea1.encntr_alias_type_cd = 1077 ;FIN
 
join pa where pa.person_id = outerjoin(charge->clist[d.seq].personid)
	and pa.person_alias_type_cd = outerjoin(2) ;CMRN
 
order by e.encntr_id
 
Head e.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt,1,size(charge->clist,5),e.encntr_id, charge->clist[cnt].encntrid)
 
      while(idx > 0)
		charge->clist[idx].fin = ea1.alias
		charge->clist[idx].mrn = ea.alias
		charge->clist[idx].cmrn = pa.alias
		charge->clist[idx].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		charge->clist[idx].disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 		idx = locateval(cnt,(idx+1),size(charge->clist,5),e.encntr_id, charge->clist[cnt].encntrid)
	endwhile
 
Foot e.encntr_id
	null
 
With nocounter
 
;-------------------------------------------------------------------------------------------------------------
;Order Details
 
select distinct into "NL:"
 
 ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
		over (partition by charge->clist[d.seq].encntrid, od.order_id, od.oe_field_id)
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = charge->clist[d.seq].orderid
    and od.oe_field_id IN (oe_freq, oe_strengthdose,oe_strengthdoseunit ,oe_volumedose ,oe_volumedoseunit ,oe_drugform ,
    	oe_duration ,oe_durationunit ,oe_rate ,oe_rate_unit ,oe_rxroute )
 
order by od.order_id , od.oe_field_id
 
Head od.order_id
	frequency = '', volume_dose = '', volume_dose_unit = '', drug_form = '', duration = '', duration_unit = '',
	rate = '', rate_unit = '', route = '', strength_dose = '', strength_dose_unit = ''
 
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(charge->clist,5),od.order_id, charge->clist[cnt].orderid)
 
Head od.oe_field_id
	CASE (od.oe_field_id )
	     OF oe_freq :
			frequency = trim(ord,3)
	     OF oe_volumedose :
	     		volume_dose = trim(ord,3)
	     OF oe_volumedoseunit :
	      	volume_dose_unit = trim(ord,3)
	     OF oe_drugform :
	      	drug_form = trim(ord,3)
	     OF oe_duration :
	      	duration = trim(ord,3)
	     OF oe_durationunit :
	     		duration_unit = trim(ord,3)
	     OF oe_rate :
	            rate = trim(ord,3)
	     OF oe_rate_unit :
	      	rate_unit = trim(ord,3)
	     OF oe_rxroute :
	     		 route = trim(ord,3)
	     OF oe_strengthdose :
	      	strength_dose = trim(ord ,3 )
	     OF oe_strengthdoseunit :
	     		 strength_dose_unit = trim(ord ,3 )
	ENDCASE
 
Foot  od.order_id
 
	while(idx > 0)
		if(strength_dose != '')
			charge->clist[idx].strength_dose = strength_dose ;cnvtstring(cnvtreal(strength_dose), 15,3)
			charge->clist[idx].strength_dose_unit = strength_dose_unit
		elseif(strength_dose = '')
			charge->clist[idx].strength_dose = format(0.000, "#.###;p0");need to show 3 decimal places if strength is 0
		endif
 
		if(charge->clist[idx].volume_dose = '')
			charge->clist[idx].volume_dose = volume_dose
			charge->clist[idx].volume_dose_unit = volume_dose_unit
		endif
		idx = locateval(cnt,(idx+1),size(charge->clist,5),od.order_id, charge->clist[cnt].orderid)
	endwhile
 
with nocounter
 
call echorecord(charge)
 
;------------------------------------------------------------------------------------------
;Medication Strength & Volume details
 
select distinct into 'NL:'
 
qty_unit = uar_get_code_display(oi.dose_quantity_unit)
 
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	, order_ingredient oi
 
plan d
 
join oi where oi.order_id = charge->clist[d.seq].orderid
	and oi.synonym_id = charge->clist[d.seq].synonym_id
	and oi.action_sequence = (select max(oi2.action_sequence) from order_ingredient oi2
		where oi2.order_id = oi.order_id)
 
order by oi.order_id
 
Head oi.order_id
	idx = 0
	vcnt = 0
 
	idx = locateval(vcnt,1,size(charge->clist,5),oi.order_id, charge->clist[vcnt].orderid)
 
	while(idx > 0)
		if(charge->clist[idx].strength_dose = '0.000' or charge->clist[idx].strength_dose = '')
			if(oi.strength = 0)
			 	charge->clist[idx].strength_dose = cnvtstring(oi.strength, 15,3)
			 else
				charge->clist[idx].strength_dose = cnvtstring(oi.strength)
			endif
			charge->clist[idx].strength_dose_unit = uar_get_code_display(oi.strength_unit)
		endif
		if(charge->clist[idx].volume_dose = '')
			charge->clist[idx].volume_dose = cnvtstring(oi.volume)
			charge->clist[idx].volume_dose_unit = uar_get_code_display(oi.volume_unit)
		endif
		idx = locateval(vcnt,(idx+1),size(charge->clist,5),oi.order_id, charge->clist[vcnt].orderid)
 	endwhile
 
Foot oi.order_id
	Null
 
with nocounter
 
;----------------------------------------------------------------------------------------------------
;get Drug Class data
 
select distinct into 'NL:'
 
  mcdx.drug_identifier ,
   dc1.multum_category_id ,
   parent_category = substring (1 ,50 ,dc1.category_name ) ,
   dc2.multum_category_id ,
   sub_category = substring (1 ,50 ,dc2.category_name ) ,
   dc3.multum_category_id ,
   sub_sub_category = substring (1 ,50 ,dc3.category_name )
 
from
	 mltm_category_drug_xref mcdx
	, mltm_drug_categories dc1
      , mltm_category_sub_xref dcs1
      , mltm_drug_categories dc2
	, mltm_category_sub_xref dcs2
      , mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id )))
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id )
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
      and expand(cnt ,1 ,charge->rec_cnt, mcdx.drug_identifier ,charge->clist[cnt].order_cki )
 
order by mcdx.drug_identifier
 
 
Head mcdx.drug_identifier
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,charge->rec_cnt ,mcdx.drug_identifier ,charge->clist[cnt].order_cki)
 
      while(idx > 0)
		if(dc1.multum_category_id != 0)
			charge->clist[idx].drug_class_code1 = trim(cnvtstring(dc1.multum_category_id ) ,3 )
			;charge->clist[idx].drug_class_description1 = dc1.category_name
	     endif
	     if(dc2.multum_category_id != 0)
			charge->clist[idx].drug_class_code2 = trim(cnvtstring(dc2.multum_category_id ) ,3 )
			;charge->clist[idx].drug_class_description2 = dc2.category_name
	     endif
	     if(dc3.multum_category_id != 0)
			charge->clist[idx].drug_class_code3 = trim(cnvtstring(dc3.multum_category_id ) ,3 )
			;charge->clist[idx].drug_class_description3 = dc3.category_name
	     endif
 
           idx = locateval(cnt,(idx+1) ,charge->rec_cnt ,mcdx.drug_identifier ,charge->clist[cnt].order_cki)
    endwhile
 
Foot  mcdx.drug_identifier
    null
 
With nocounter
 
;---------------------------------------------------------------------------------------------------------------------
;get Personnel info
 
select distinct into 'nl:'
 
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	,prsnl pr
 
plan d
 
join pr where pr.person_id = charge->clist[d.seq].pr_chrg_entered
 
order by pr.person_id
 
Head 	pr.person_id
	idx = 0
	cnt = 0
 	idx = locateval(cnt,1,size(charge->clist,5),pr.person_id, charge->clist[cnt].pr_chrg_entered)
 
	while(idx > 0)
		charge->clist[idx].pr_name_chrg_entered = pr.name_full_formatted
		idx = locateval(cnt,(idx+1),size(charge->clist,5), pr.person_id, charge->clist[cnt].pr_chrg_entered)
 	endwhile
 
Foot pr.person_id
	Null
 
with nocounter
 
;call echorecord(charge)
 
;------------------------------------------------------------------------------------------------------------------
;get item number
 
select distinct into 'NL:'
 
from
	(dummyt d WITH seq = value(size(charge->clist,5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = charge->clist[d.seq].item_id
    and mi.primary_ind = 1
    and mi.med_product_id = 0
    and mi.med_identifier_type_cd in(brandname_var, chargenumber_var , genericname_var )
    and mi.active_ind = 1
 
order by mi.item_id, mi.med_identifier_type_cd
 
Head mi.item_id
	idx = 0
	cnt = 0
      drug_brand_name = "" ,item_number = "" ,drug_generic_name = ""
      idx = locateval(cnt ,1, charge->rec_cnt ,mi.item_id ,charge->clist[cnt].item_id)
 
Head mi.med_identifier_type_cd
 	case (mi.med_identifier_type_cd)
	     of brandname_var :
		      drug_brand_name = trim(mi.value ,3 )
	     of chargenumber_var :
		      item_number = trim(mi.value ,3 )
	     of genericname_var :
		      drug_generic_name = trim(mi.value ,3 )
	endcase
 
Foot mi.med_identifier_type_cd
    null
 
Foot  mi.item_id
    while(idx > 0)
	    ; charge->clist[idx].drug_brand_name = drug_brand_name
	     charge->clist[idx].item_number = item_number
	     ;charge->clist[idx].drug_generic_name = drug_generic_name
	     idx = locateval(cnt,(idx+1), charge->rec_cnt ,mi.item_id ,charge->clist[cnt].item_id)
    endwhile
 
With nocounter ,expand = 1
 
 
;---------------------------------------------------------------------------------------------------------------------
 
;If($to_file = 1) ;Screen Display
 
SELECT DISTINCT INTO value($outdev)
	FACILITY = SUBSTRING(1, 30, charge->clist[D1.SEQ].strata_facility_cd)
	, FIN = SUBSTRING(1, 30, charge->clist[D1.SEQ].fin)
	, MRN = SUBSTRING(1, 30, charge->clist[D1.SEQ].mrn)
	, CMRN = SUBSTRING(1, 30, charge->clist[D1.SEQ].cmrn)
		;, encntr_id = charge->clist[D1.SEQ].encntrid
		, item_id = charge->clist[D1.SEQ].item_id
		;, cki = SUBSTRING(1, 30, charge->clist[D1.SEQ].order_cki)
		;, synonym_id = charge->clist[D1.SEQ].synonym_id
		;, bill_item_id = CHARGE->clist[D1.SEQ].bill_item_id
	, PRESCRIPTION_NUMBER = charge->clist[D1.SEQ].orderid
	;,some of them are empty - ITEM_NUMBER = SUBSTRING(1, 30, charge->clist[D1.SEQ].item_number)
		;, MED_ADMIN_DT = SUBSTRING(1, 30, charge->clist[D1.SEQ].med_admin_dt)
	, STRENGTH_DOSE = SUBSTRING(1, 30, charge->clist[D1.SEQ].strength_dose)
	, STRENGTH_DOSE_UNIT = SUBSTRING(1, 30, charge->clist[D1.SEQ].strength_dose_unit)
	, VOLUME_DOSE = SUBSTRING(1, 30, charge->clist[D1.SEQ].volume_dose)
	, VOLUME_DOSE_UNIT = SUBSTRING(1, 30, charge->clist[D1.SEQ].volume_dose_unit)
	, CHARGE_DESCRIPTION = SUBSTRING(1, 300, CHARGE->clist[D1.SEQ].charge_description)
		;, activity_type = SUBSTRING(1, 300, CHARGE->clist[D1.SEQ].activity_type)
		;, activity_sub_type = SUBSTRING(1, 300, CHARGE->clist[D1.SEQ].activity_sub_type)
	, SERVICE_DT = SUBSTRING(1, 30, charge->clist[D1.SEQ].service_dt)
	, QUANTITY = charge->clist[D1.SEQ].quantity
	; some of them are empty, QUANTITY_UNIT = charge->clist[D1.SEQ].quantity_unit_cd
	, CHARGE_TYPE = SUBSTRING(1, 30, CHARGE->clist[D1.SEQ].charge_type)
	, CREDITED_DT = SUBSTRING(1, 30, CHARGE->clist[D1.SEQ].credited_dt)
	, DRUG_CLASS_CODE1 = SUBSTRING(1, 30, charge->clist[D1.SEQ].drug_class_code1)
	, DRUG_CLASS_CODE2 = SUBSTRING(1, 30, charge->clist[D1.SEQ].drug_class_code2)
	, DRUG_CLASS_CODE3 = SUBSTRING(1, 30, charge->clist[D1.SEQ].drug_class_code3)
	, ADMIT_DT = SUBSTRING(1, 30, charge->clist[D1.SEQ].admit_dt)
	, DISCH_DT = SUBSTRING(1, 30, charge->clist[D1.SEQ].disch_dt)
	, CHARGE_CREATED_BY = SUBSTRING(1, 50, CHARGE->clist[D1.SEQ].pr_name_chrg_entered)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(charge->clist, 5)))
 
PLAN D1
 
ORDER BY FACILITY, FIN, PRESCRIPTION_NUMBER, CHARGE_DESCRIPTION, CHARGE_TYPE, SERVICE_DT, CREDITED_DT
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
;endif ;Screen Display
 
 
/*****************************************************************************
	;Subroutins
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
/*****************************************************************************/
 
 
 
end go

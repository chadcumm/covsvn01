/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		July 2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_item_cost_extract.prg
	Object name:		cov_pha_item_cost_extract
	Request#:			4951
	Program purpose:	      Decision Support
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_pha_item_cost_extract:dba go
create program cov_pha_item_cost_extract:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare charge_num_var  = f8 with constant(uar_get_code_by("DISPLAY", 11000, "Charge Number")),protect
declare item_num_var    = f8 with constant(uar_get_code_by("DISPLAY", 11000, "Item Number")),protect
declare ndc_num_var     = f8 with constant(uar_get_code_by("DISPLAY", 11000, "NDC")),protect
declare desc_var        = f8 with constant(uar_get_code_by("DISPLAY", 11000, "Description")),protect
declare hcpcs_cpt_var   = f8 with constant(uar_get_code_by("DISPLAY", 11000, "HCPCS Code")),protect
declare AWP_var         = f8 with constant(uar_get_code_by("DISPLAY", 4050,  "AWP")),protect
declare GPO_var         = f8 with constant(uar_get_code_by("DISPLAY", 4050,  "GPO")),protect
 
;----------------------------------------------------------------------------------------------
 
Record drug(
	1 rec_cnt = i4
	1 olist[*]
		2 catalog_cd = f8
		2 drug_description = vc
		2 drug_mnemonic = vc
		2 cki = vc
		2 synonymid = f8
		2 charge_number = vc
		2 sim = vc
		2 hcpcs = vc
		2 item_id = f8
		2 flist[*]
			3 facility = vc
			3 location = vc
			3 orgid = f8
		2 nlist[*]
			3 ndc = vc
			3 primary_ndc = i4
			3 med_product_id = f8
			3 awp = vc
			3 unit_cost = vc
)
 
Record fac(
	1 list[*]
		2 facility = vc
		2 org_id = f8
		2 org_name = vc
	)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;Get Facility Prefix
 
select distinct into $outdev
 
 o.org_name, o.organization_id, fac_prefix = trim(uar_get_code_description(l.facility_accn_prefix_cd))
 ,loc = uar_get_code_display(l.location_cd)
 
from  organization o
	, location l
 
plan o where o.organization_id in(3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00,3144503.00,3144504.00,3234074.00) 
	and o.active_ind = 1
 
join l where l.organization_id = o.organization_id
	and l.facility_accn_prefix_cd != 0.00
 
;with nocounter, separator=" ", format
;go to exitscript


Head report
	fcnt = 0
Head o.organization_id
	fcnt += 1
	call alterlist(fac->list, fcnt)
Detail
	fac->list[fcnt].org_id = o.organization_id
	fac->list[fcnt].facility = fac_prefix
	fac->list[fcnt].org_name = trim(o.org_name)
 
with nocounter

;---------------------------------------------------------------------------------------------------------
;Get Drug and Facility
select into 'nl:'
 
oc.catalog_cd, ocs.synonym_id, ocs.item_id, drug = ocs.mnemonic
 
from	  order_catalog oc
	, order_catalog_synonym ocs
 
plan oc where oc.catalog_type_cd = 2516.00 ;Pharmacy
	and oc.active_ind = 1
	and oc.cki != 'IGNORE'
 
join ocs where ocs.catalog_cd = oc.catalog_cd
	and ocs.mnemonic_type_cd = 2584 ;RX Mnemonic
	and ocs.active_ind = 1
 
order by oc.catalog_cd, ocs.synonym_id, ocs.item_id
 
Head report
	cnt = 0
 
Head ocs.synonym_id
	cnt += 1
	call alterlist(drug->olist, cnt)
Detail
	drug->olist[cnt].catalog_cd = oc.catalog_cd
	drug->olist[cnt].cki = oc.cki
	drug->olist[cnt].synonymid = ocs.synonym_id
	drug->olist[cnt].drug_mnemonic = trim(ocs.mnemonic)
	drug->olist[cnt].item_id = ocs.item_id
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Get Location for all meds
 
select into 'nl:'
 
sa.item_id, drug = drug->olist[d.seq].drug_mnemonic, org = trim(o.org_name)
 
from (dummyt d with seq = value(size(drug->olist, 5)))
	, stored_at sa
	, location l
	, organization o
 
plan d
 
join sa where sa.item_id = drug->olist[d.seq].item_id
 
join l where l.location_cd = sa.location_cd
	and l.active_ind = 1
	and l.location_cd != 0.00
 
join o where o.organization_id = l.organization_id
	and o.organization_id in(3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00,3144503.00,3144504.00,3234074.00) 
	and o.active_ind = 1
	and o.org_name != ''
 
order by sa.item_id, o.organization_id
 
Head sa.item_id
	lcnt = 0
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), sa.item_id ,drug->olist[cnt].item_id)
 
Head o.organization_id
	lcnt += 1
	call alterlist(drug->olist[idx].flist, lcnt)
	drug->olist[idx].flist[lcnt].orgid = o.organization_id
	drug->olist[idx].flist[lcnt].facility = trim(o.org_name)
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------
;Get Charge number
select into 'nl:'
 
 mi.item_id, med_identifier = uar_get_code_display(mi.med_identifier_type_cd)
  ,value = trim(mi.value ,3), mi.med_identifier_id
 
from	(dummyt d with seq = value(size(drug->olist, 5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = drug->olist[d.seq].item_id
	and mi.active_ind = 1
	and mi.med_identifier_type_cd = charge_num_var
 
order by mi.item_id
 
Head mi.item_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), mi.item_id ,drug->olist[cnt].item_id)
      if(idx > 0)
		drug->olist[idx].charge_number = trim(mi.value ,3)
		val = trim(mi.value ,3)
	      pos = findstring("X", cnvtupper(val))
		len = textlen(val)
		drug->olist[idx].sim = substring((pos+1) ,len, val)
	endif
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------
;Get NDC's
select into 'nl:'
 
 mi.item_id, med_identifier = uar_get_code_display(mi.med_identifier_type_cd)
  ,hcpcs_code = trim(mi.value ,3), mi.med_identifier_id
 
from	(dummyt d with seq = value(size(drug->olist, 5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = drug->olist[d.seq].item_id
	and mi.flex_type_cd = 665857.00 ;System
	and mi.active_ind = 1
	and mi.primary_ind = 1
	and mi.med_type_flag = 0 ;product
	and mi.med_product_id > 0
	and mi.med_identifier_type_cd = ndc_num_var
 
order by mi.item_id, mi.med_identifier_id
 
Head mi.item_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), mi.item_id ,drug->olist[cnt].item_id)
	ncnt = 0
 
Head mi.med_identifier_id
	ncnt += 1
	call alterlist(drug->olist[idx].nlist, ncnt)
Detail
	drug->olist[idx].nlist[ncnt].ndc = trim(mi.value ,3)
	drug->olist[idx].nlist[ncnt].med_product_id = mi.med_product_id
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------
;Assign Primary NDC
select into 'nl:'
 
from
	(dummyt   d1  with seq = size(drug->olist, 5))
	, (dummyt   d2  with seq = 1)
	, (dummyt   d3  with seq = 1)
	,  med_identifier mi
	,  med_flex_object_idx mfo
 
plan d1 where maxrec(d2, size(drug->olist[d1.seq].flist, 5))
	and maxrec(d3, size(drug->olist[d1.seq].nlist, 5))
 
join d2
join d3
 
join mi where mi.item_id = drug->olist[d1.seq].item_id
 
join mfo where mfo.parent_entity_id = mi.med_product_id
	and mfo.med_def_flex_id = mi.med_def_flex_id
	and mfo.parent_entity_name = "MED_PRODUCT"
	and mfo.sequence = 1
	and mfo.active_ind = 1
	and mfo.flex_object_type_cd = 665860.00 ;Med Product
 
order by mi.item_id, mi.med_product_id
 
Head mi.med_product_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), mi.med_product_id ,drug->olist[d1.seq].nlist[cnt].med_product_id)
	if(idx > 0)
		drug->olist[d1.seq].nlist[idx].primary_ndc = 1
 	endif
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Get drug description
select into 'nl:'
 
 mi.item_id, med_identifier = uar_get_code_display(mi.med_identifier_type_cd)
  ,value = trim(mi.value ,3), mi.med_identifier_id
 
from	(dummyt d with seq = value(size(drug->olist, 5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = drug->olist[d.seq].item_id
	and mi.active_ind = 1
	and mi.med_identifier_type_cd = desc_var
 
order by mi.item_id
 
Head mi.item_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), mi.item_id ,drug->olist[cnt].item_id)
      if(idx > 0)
		drug->olist[idx].drug_description = trim(mi.value ,3)
	endif
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Get HCPCS
select into 'nl:'
 
 mi.item_id, med_identifier = uar_get_code_display(mi.med_identifier_type_cd) ,value = trim(mi.value ,3)
 
from	(dummyt d with seq = value(size(drug->olist, 5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = drug->olist[d.seq].item_id
	and mi.active_ind = 1
	and mi.med_identifier_type_cd = hcpcs_cpt_var
 
order by mi.item_id
 
Head mi.item_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), mi.item_id ,drug->olist[cnt].item_id)
      if(idx > 0)
		drug->olist[idx].hcpcs = trim(mi.value ,3)
	endif
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Get unit cost & AWP
select into $outdev
 
item_id = drug->olist[d1.seq].item_id, cost_type = uar_get_code_display(mch.cost_type_cd)
, cost = cnvtstring(mch.cost,15,5) , drug = drug->olist[d1.seq].drug_description
, ndc = trim(substring(1, 13, drug->olist[d1.seq].nlist[d2.seq].ndc))
, med_product_id = drug->olist[d1.seq].nlist[d2.seq].med_product_id
 
from
	(dummyt   d1  with seq = size(drug->olist, 5))
	,(dummyt   d2  with seq = 1)
	, med_cost_hx mch
 
plan d1 where maxrec(d2, size(drug->olist[d1.seq].nlist, 5))
join d2
 
join mch where mch.med_product_id = drug->olist[d1.seq].nlist[d2.seq].med_product_id
	and mch.cost_type_cd in(AWP_var, GPO_var)
	and mch.active_ind = 1
 
order by mch.med_product_id, mch.cost_type_cd
 
Head mch.med_product_id
	gcnt = 0
Head mch.cost_type_cd
	case(mch.cost_type_cd)
		of AWP_var:
			drug->olist[d1.seq].nlist[d2.seq].awp = cnvtstring(mch.cost, 15,5)
		of GPO_var:
			drug->olist[d1.seq].nlist[d2.seq].unit_cost = cnvtstring(mch.cost, 15,5)
	endcase
 
with nocounter
 
 
;--------------------------------------------------------------------------------------------
/*
;Get AWP
select into 'nl:'
 
item_id = drug->olist[d1.seq].item_id
, ndc = trim(substring(1, 13, drug->olist[d1.seq].nlist[d2.seq].ndc))
, med_product_id = drug->olist[d1.seq].nlist[d2.seq].med_product_id
 
from
	(dummyt   d1  with seq = size(drug->olist, 5))
	, (dummyt   d2  with seq = 1)
	, med_cost_hx mch
 
plan d1 where maxrec(d2, size(drug->olist[d1.seq].nlist, 5))
join d2
 
join mch where mch.med_product_id = drug->olist[d1.seq].nlist[d2.seq].med_product_id
	and mch.cost_type_cd = 2431.00 ;AWP
	and mch.active_ind = 1
 
order by mch.med_product_id
 
Head mch.med_product_id
	drug->olist[d1.seq].nlist[d2.seq].awp = mch.cost
 
with nocounter
 
;-------------------------------------------------------------------------------------
;Get unit cost - spoke with Tommy(8/20/19) - this is not the way we calculate the unti price.(this is the price we charge the patient)
;For this report we need manufacturers unit price.
;As of now final result section won't show this column
/*select into 'nl:'
 
md.item_id, md.dispense_qty, md.dispense_factor, md.pkg_qty_per_pkg
,awp = drug->olist[d1.seq].nlist[d2.seq].awp
,unit_cost = (drug->olist[d1.seq].nlist[d2.seq].awp * md.dispense_factor)
,med_prod_id = drug->olist[d1.seq].nlist[d2.seq].med_product_id
 
;Cost(base cost*dispense factor*Chg qty).
 
from	(dummyt   d1  with seq = size(drug->olist, 5))
	, (dummyt   d2  with seq = 1)
	, med_dispense md
 
plan d1 where maxrec(d2, size(drug->olist[d1.seq].nlist, 5))
join d2
 
join md where md.item_id = drug->olist[d1.seq].item_id
 
order by md.item_id, drug->olist[d1.seq].nlist[d2.seq].med_product_id
 
Head med_prod_id
	drug->olist[d1.seq].nlist[d2.seq].unit_cost = (drug->olist[d1.seq].nlist[d2.seq].awp * md.dispense_factor)
 
with nocounter
 
call echorecord(drug)
 */
;---------------------------------------------------------------------------------
;Testing - from 5/14/20 - Cost based on AWP
;Commenting this out as cost info updated in DB as per Jeff.N 07/20/20
/*select into $outdev
md.item_id, mi.med_product_id, ndc = mndc.ndc_formatted
,package_cost = mnc.cost, md.dispense_factor
,pack_size = if(mndc.inner_package_size != 0.00) mndc.inner_package_size else 1.00 endif
,pack_qty = if(mndc.outer_package_size != 0.00) mndc.outer_package_size else 1.00 endif
;,cost_per_dose = (package_cost /(pack_size * pack_qty)) * md.dispense_factor
 
from	(dummyt d1 with seq = size(drug->olist, 5))
	, (dummyt d2 with seq = 1)
	, med_dispense md
	, mltm_ndc_cost mnc
      , mltm_ndc_core_description mndc
      , med_identifier mi
 
plan d1 where maxrec(d2, size(drug->olist[d1.seq].nlist, 5))
join d2
 
join md where md.item_id = drug->olist[d1.seq].item_id
 
join mi where mi.item_id = md.item_id
	and mi.active_ind = 1
	and mi.med_identifier_type_cd = value(uar_get_code_by("MEANING", 11000, "NDC"))
 
join mndc where mndc.ndc_formatted = mi.value
	;and mndc.ndc_formatted = '61703-0350-38'
 
join mnc where mnc.ndc_code = mndc.ndc_code
	and mnc.inventory_type = 'A'
 
order by mi.med_product_id, mndc.ndc_formatted
 
Head mndc.ndc_formatted
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(drug->olist,5), mndc.ndc_formatted, drug->olist[d1.seq].nlist[cnt].ndc)
	if(idx > 0)
		drug->olist[d1.seq].nlist[idx].awp = mnc.cost
		drug->olist[d1.seq].nlist[idx].unit_cost = (package_cost /(pack_size * pack_qty)) * md.dispense_factor
	endif
with nocounter */
 
 
call echorecord(drug)
;-----------------------------------------------------------------------------------------------------------------------
 
select into $outdev
 	facility = trim(substring(1, 200, drug->olist[d1.seq].flist[d2.seq].facility))
	,drug_description = trim(substring(1, 300, drug->olist[d1.seq].drug_description))
	,ndc = trim(substring(1, 30, drug->olist[d1.seq].nlist[d3.seq].ndc))
	,primary_ndc = drug->olist[d1.seq].nlist[d3.seq].primary_ndc
	,gpo_cost_per_dose = trim(substring(1,10, drug->olist[d1.seq].nlist[d3.seq].unit_cost))
	,awp_per_dose = trim(substring(1,10, drug->olist[d1.seq].nlist[d3.seq].awp))
	,charge_number = trim(substring(1, 30, drug->olist[d1.seq].charge_number))
	,sim = trim(substring(1, 30, drug->olist[d1.seq].sim))
	,hcpcs = trim(substring(1, 30, drug->olist[d1.seq].hcpcs))
 
	;,item_id = drug->olist[d1.seq].item_id
	;,med_product_id = drug->olist[d1.seq].nlist[d3.seq].med_product_id
	;,location = trim(substring(1, 300, drug->olist[d1.seq].flist[d2.seq].location))
from
	(dummyt   d1  with seq = size(drug->olist, 5))
	, (dummyt   d2  with seq = 1)
	, (dummyt   d3  with seq = 1)
 
plan d1 where maxrec(d2, size(drug->olist[d1.seq].flist, 5))
	and maxrec(d3, size(drug->olist[d1.seq].nlist, 5))
	and substring(1,4, trim(substring(1, 30, drug->olist[d1.seq].charge_number))) != 'NCRX' ;Non Chargeable items
join d2
join d3
 
order by charge_number, facility
 
with nocounter, separator=" ", format
 
#exitscript
 
end go
 
 
;----------------- 
 
/* 
select * from organization o where cnvtupper(o.org_name_key) = '*PENI*'

select * from organization o where o.organization_id 
in(3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00,3144503.00,3144504.00,3144500.00) 


select loc = uar_get_code_display(l.location_cd), type =  uar_get_code_display(l.location_type_cd)
,l.location_type_cd, l.facility_accn_prefix_cd, o.org_name, o.organization_id
from organization o, location l 
where o.organization_id = l.organization_id
and cnvtupper(o.org_name_key) = '*PENI*'
and l.location_type_cd = 783




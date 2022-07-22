 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Feb'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_disch_rx_analysis.prg
	Object name:		cov_pha_disch_rx_analysis
 	Request#:			Child data feed (3512 & 4105 combined)
	Program purpose:	      Prescribrd medications at patient discharge
	Executing from:		Ops
 	Special Notes:          Data feed to Tommy. This feed will be helping Tommy for analysing data for
 					cov_pha_discharge_rx_meds (CR# 3512 & 4105)
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_disch_rx_analysis:DBA go
create program cov_pha_disch_rx_analysis:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End Discharge  Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
*************************************************************/
 
declare filename_var = vc with constant('cer_temp:disch_rx_narcotic.csv'), PROTECT
 
;declare filename_var = vc WITH noconstant(build2('cer_temp:disch_rx_narcotic_',sysdate,'.txt')), PROTECT
;select tt = build2('cer_temp:disch_rx_narcotic_',sysdate,'.txt') from dummyt
;select tt = build2('cer_temp:disch_rx_narcotic_',format(CNVTDATETIME(CURDATE, CURTIME3), 'mm/dd/yy hh:mm;;d'),'.txt') from dummyt
 
 
declare oe_freq             = f8 with protect ,constant (12690.00)
declare oe_strengthdose     = f8 with protect ,constant (12715.00)
declare oe_strengthdoseunit = f8 with protect ,constant (12716.00)
declare oe_volumedose       = f8 with protect ,constant (12718.00)
declare oe_volumedoseunit   = f8 with protect ,constant (12719.00)
declare oe_drugform         = f8 with protect ,constant (12693.00)
declare oe_duration         = f8 with protect ,constant (12721.00)
declare oe_durationunit     = f8 with protect ,constant (12723.00)
declare oe_rxroute          = f8 with protect ,constant (12711.00)
declare oe_rate             = f8 with protect ,constant (12704.00)
declare oe_rate_unit        = f8 with protect ,constant (633585.00)
declare oe_disp_qty         = f8 with protect ,constant (12694.00)
declare oe_disp_unit        = f8 with protect ,constant (633598.00)
declare oe_no_refill        = f8 with protect ,constant (12628.00)
declare oe_tot_refill       = f8 with protect ,constant (634309.00)
declare oe_start_dt         = f8 with protect ,constant (12620.00)
declare oe_stop_dt          = f8 with protect ,constant (12731.00)
declare oe_prn_inst         = f8 with protect ,constant (633597.00)
declare oe_indicat          = f8 with protect ,constant (12590.00)
declare oe_pharm_route      = f8 with protect ,constant (4056695.00)
declare oe_pharmacy         = f8 with protect ,constant (4376093.00)
 
declare frequency_code      = f8 with protect ,noconstant (0.0 )
declare frequency           = vc with protect ,noconstant ("" )
declare strength_dose       = vc with protect ,noconstant ("" )
declare strength_dose_unit  = vc with protect ,noconstant ("" )
declare volume_dose         = vc with protect ,noconstant ("" )
declare volume_dose_unit    = vc with protect ,noconstant ("" )
declare drug_form           = vc with protect ,noconstant ("" )
declare duration            = vc with protect ,noconstant ("" )
declare duration_unit       = vc with protect ,noconstant ("" )
declare rate                = vc with protect ,noconstant ("" )
declare rate_unit           = vc with protect ,noconstant ("" )
declare route               = vc with protect ,noconstant ("" )
declare disp_qty            = vc with protect ,noconstant ("" )
declare disp_unit           = vc with protect ,noconstant ("" )
declare no_refill           = vc with protect ,noconstant ("" )
declare tot_refill          = vc with protect ,noconstant ("" )
declare start_dt            = vc with protect ,noconstant ("" )
declare stop_dt             = vc with protect ,noconstant ("" )
declare prn_inst            = vc with protect ,noconstant ("" )
declare indicat             = vc with protect ,noconstant ("" )
declare pharm_route         = vc with protect ,noconstant ("" )
declare pharmacy            = vc with protect ,noconstant ("" )
 
declare mcnt = i4 with noconstant(0), protect
declare cnt  = i4 with noconstant(0),protect
declare idx  = i4 with protect ,noconstant (0 )
declare expand_idx = i4 with protect ,noconstant (0 )
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD rx(
	1 rx_rec_cnt = i4
	1 olist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 patient_name = vc
		2 orderid = f8
		2 medication_name = vc
		2 order_date = vc
		2 synonymid = f8
		2 charge_number = vc
		2 status = vc
		2 strength_dose = vc
		2 strength_dose_unit = vc
		2 route_of_admin_tmp = vc
		2 route_of_admin = vc
		2 volume_dose = vc
		2 volume_dose_unit = vc
		2 rate = vc
		2 rate_unit = vc
		2 drug_form = vc
		2 frequency = vc
		2 duration = vc
		2 duration_unit = vc
		2 quantity = f8
		2 quantity_unit = vc
		2 disp_qty = vc
		2 disp_unit = vc
		2 no_refil = vc
		2 tot_refil = vc
		2 prescriber = vc
		2 order_cki = vc
		2 drug_class_code1 = vc
		2 drug_class_description1 = vc
		2 drug_class_code2 = vc
		2 drug_class_description2 = vc
		2 drug_class_code3 = vc
		2 drug_class_description3 = vc
		2 drug_generic_name = vc
		2 drug_brand_name = vc
		2 item_number = vc
		2 special_instruction = vc
 		2 med_start_date = vc
 		2 med_stop_date = vc
 		2 prn_instruction = vc
 		2 indication = vc
 		2 pharmacy_route = vc
 		2 pharmacy_name = vc
)
 
;--------------------------------------------------------------------------------------------------------------
;Order qualification
 
select distinct into 'nl:'
 
Facility = uar_get_code_display(e.loc_facility_cd)
, fin = ea.alias
, pat_name = p.name_full_formatted
, order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, med = o.ordered_as_mnemonic
, status = uar_get_code_display(o.order_status_cd)
, o.order_id
 
from
	encounter e
	, orders o
	, order_action oa
	, encntr_alias ea
	, person p
	, prsnl pr
 
plan e ;where e.loc_facility_cd = $all_cov_facilities
	where e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	and e.encntr_id != 0
 
join o where o.encntr_id = e.encntr_id
	and o.orig_ord_as_flag = 1 ;Prescription/Discharge Order
	and o.active_ind = 1
	and o.order_status_cd in(2550.00) ;Ordered
	and o.activity_type_cd = 705.00 ;Pharmacy
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pr where pr.person_id = oa.order_provider_id
	and pr.active_ind = 1
 
order by facility, fin, order_dt, o.order_id
 
Head report
 	cnt = 0
	call alterlist(rx->olist, 100)
 
Head o.order_id
 	cnt += 1
 	rx->rx_rec_cnt = cnt
	call alterlist(rx->olist, cnt)
 
Detail
      cki_pos = findstring("!" ,o.cki )
      cki_len = textlen(o.cki)
	cki_val = trim(substring((cki_pos + 1 ) ,cki_len ,o.cki))
 	rx->olist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
 	rx->olist[cnt].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
 	rx->olist[cnt].personid = e.person_id
 	rx->olist[cnt].encntrid = e.encntr_id
 	rx->olist[cnt].fin = ea.alias
 	rx->olist[cnt].patient_name = p.name_full_formatted
 	rx->olist[cnt].orderid = o.order_id
 	rx->olist[cnt].synonymid = o.synonym_id
 	rx->olist[cnt].medication_name = o.ordered_as_mnemonic
 	rx->olist[cnt].order_date = order_dt
 	rx->olist[cnt].status = uar_get_code_display(o.order_status_cd)
 	rx->olist[cnt].prescriber = pr.name_full_formatted
	rx->olist[cnt].order_cki = cki_val
	rx->olist[cnt].special_instruction = o.simplified_display_line
 
Foot o.order_id
	call alterlist(rx->olist, cnt)
 
with nocounter
 
call echorecord(rx->olist)
;-------------------------------------------------------------------------------------------------
 
;Order Details
 
select distinct into "NL:"
 ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
		over (partition by rx->olist[d.seq].encntrid, od.order_id, od.oe_field_id)
from
	(dummyt d WITH seq = value(size(rx->olist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = rx->olist[d.seq].orderid
    and od.oe_field_id IN (oe_freq, oe_strengthdose,oe_strengthdoseunit ,oe_volumedose ,oe_volumedoseunit ,oe_drugform ,
    	oe_duration ,oe_durationunit ,oe_rate ,oe_rate_unit ,oe_rxroute, oe_disp_qty, oe_disp_unit, oe_no_refill,
    	oe_tot_refill, oe_start_dt, oe_stop_dt, oe_prn_inst, oe_indicat, oe_pharm_route, oe_pharmacy)
 
order by od.order_id , od.oe_field_id
 
Head od.order_id
 
	frequency = '',volume_dose = '',volume_dose_unit = '',drug_form = '',duration = '',	duration_unit = '', rate = '',
	rate_unit = '',route = '',strength_dose = '',strength_dose_unit = '', disp_qty = '', disp_unit= '', no_refill = '',
	tot_refill = '', start_dt = '', stop_dt = '', prn_inst = '', indicat = '', pharm_route = '', pharmacy = ''
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(rx->olist,5),od.order_id, rx->olist[cnt].orderid)
 
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
	     OF oe_disp_qty :
     		 	disp_qty = trim(ord,3)
 	     OF oe_disp_unit :
     		 	disp_unit = trim(ord,3)
	     OF oe_no_refill :
     		 	no_refill = trim(ord,3)
	     OF oe_tot_refill :
     		 	tot_refill = trim(ord,3)
	     OF oe_start_dt :
    		 	start_dt = trim(ord,3)
    	     OF oe_stop_dt :
    		 	stop_dt = trim(ord,3)
	     OF oe_prn_inst :
     		 	prn_inst = trim(ord,3)
	     OF oe_indicat :
     		 	indicat = trim(ord,3)
     	     OF oe_pharm_route:
     	     		pharm_route = trim(ord,3)
	     OF oe_pharmacy :
     		 	pharmacy = trim(ord,3)
	ENDCASE
 
Foot  od.order_id
 
	while(idx > 0)
		rx->olist[idx].drug_form = drug_form
 		rx->olist[idx].duration = duration
		rx->olist[idx].duration_unit = duration_unit
		rx->olist[idx].rate = rate
	 	rx->olist[idx].rate_unit = rate_unit
		rx->olist[idx].frequency = frequency
		rx->olist[idx].route_of_admin = route
		rx->olist[idx].strength_dose = strength_dose ;cnvtstring(cnvtreal(strength_dose), 15,3)
		rx->olist[idx].strength_dose_unit = strength_dose_unit
		rx->olist[idx].volume_dose = volume_dose
		rx->olist[idx].volume_dose_unit = volume_dose_unit
		rx->olist[idx].disp_qty = disp_qty
		rx->olist[idx].disp_unit = disp_unit
		rx->olist[idx].no_refil = no_refill
		rx->olist[idx].tot_refil = tot_refill
		rx->olist[idx].med_start_date = start_dt
		rx->olist[idx].med_stop_date = stop_dt
		rx->olist[idx].prn_instruction = prn_inst
		rx->olist[idx].pharmacy_route = pharm_route
		rx->olist[idx].pharmacy_name = pharmacy
		idx = locateval(cnt,(idx+1),size(rx->olist,5),od.order_id, rx->olist[cnt].orderid)
	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------
;Get charge/RX number (CDM)
 
/*
select distinct mi.*
from orders o, order_catalog_item_r oci, med_identifier mi
where o.order_id = 1739171865.00
and oci.catalog_cd = o.catalog_cd
and mi.item_id = oci.item_id
and mi.med_identifier_type_cd = 3096.00 ;Charge Number CDM
and mi.active_ind = 1
*/
 
select into 'nl:'
 
from  (dummyt d WITH seq = value(size(rx->olist,5)))
	, order_product op
	, med_identifier mi
 
plan d
 
join op where op.order_id = rx->olist[d.seq].orderid
 
join mi where mi.item_id = op.item_id
	and mi.med_identifier_type_cd = 3096.00 ;Charge Number CDM
	and mi.active_ind = 1
 
order	by op.order_id
 
Head op.order_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,op.order_id ,rx->olist[cnt].orderid)
 
	while(idx > 0 )
		rx->olist[idx].charge_number = trim(mi.value ,3)
		idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,op.order_id ,rx->olist[cnt].orderid)
	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------
;Get Pharmacy info for missing pharmacy name(patient level if it is not available in order level)
 /* 7/9/19 as of today all info exist in order_detail table so commenting this off
 
select into 'nl:'
 
pp.person_id, gmc.pharmacy_name, gmc.prescriber_name
 
from 	(dummyt d WITH seq = value(size(rx->olist,5)))
	,person_preferred_pharmacy pp
	,gs_med_claim gmc
 
plan d
 
join pp where pp.person_id = rx->olist[d.seq].personid
	and pp.active_ind = 1
 
join gmc where gmc.person_id = pp.person_id
	and gmc.pharmacy_identifier = pp.preferred_pharmacy_uid
	and gmc.active_ind = 1
 
Head pp.person_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,pp.person_id ,rx->olist[cnt].personid)
 
	while(idx > 0 )
		if(trim(rx->olist[idx].pharmacy_name) = ' ' and trim(rx->olist[idx].pharmacy_route) != 'Print Requisition'
			and trim(rx->olist[idx].pharmacy_route) != 'Do Not Route' )
			rx->olist[idx].pharmacy_name = trim(gmc.pharmacy_name)
		endif
		idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,pp.person_id ,rx->olist[cnt].personid)
	endwhile
 
with nocounter
 */
;----------------------------------------------------------------------------------------------------
;Drug Class data
 
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
	;and dc1.multum_category_id = 57 ;central nervous system agents
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id
	;and dc2.multum_category_id = 58 ;analgesics
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id )
	;and dc3.multum_category_id in(60, 191) ;narcotic analgesics; narcotic analgesic combinations
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
      and expand(cnt ,1 ,rx->rx_rec_cnt, mcdx.drug_identifier ,rx->olist[cnt].order_cki )
 
order by mcdx.drug_identifier
 
Head mcdx.drug_identifier
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,mcdx.drug_identifier ,rx->olist[cnt].order_cki)
 
      while(idx > 0)
		if(dc1.multum_category_id != 0)
			rx->olist[idx].drug_class_code1 = trim(cnvtstring(dc1.multum_category_id ) ,3 )
			rx->olist[idx].drug_class_description1 = dc1.category_name
	     endif
	     if(dc2.multum_category_id != 0)
			rx->olist[idx].drug_class_code2 = trim(cnvtstring(dc2.multum_category_id ) ,3 )
			rx->olist[idx].drug_class_description2 = dc2.category_name
	     endif
	     if(dc3.multum_category_id != 0)
			rx->olist[idx].drug_class_code3 = trim(cnvtstring(dc3.multum_category_id ) ,3 )
			rx->olist[idx].drug_class_description3 = dc3.category_name
	     endif
 
           idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,mcdx.drug_identifier ,rx->olist[cnt].order_cki)
    endwhile
 
Foot  mcdx.drug_identifier
    null
 
With nocounter ,expand = 1
 
call echorecord(rx)
 
 
;--------------------------------------------------------------------------------------------------------------
 
SELECT DISTINCT INTO $outdev ;(filename_var)
 
	 FACILITY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].facility))
	, NURSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].nurse_unit))
	, FIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].fin))
	;, PERSONID = RX->olist[D1.SEQ].personid
	;, ENCNTRID = RX->olist[D1.SEQ].encntrid
	;, ORDER_CKI = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_cki))
	, ORDERID = RX->olist[D1.SEQ].orderid
	, ORDER_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_date))
	, SYNONYM_ID = RX->olist[D1.SEQ].synonymid
	;, CHARGE_NUMBER = trim(SUBSTRING(1, 10, RX->olist[D1.SEQ].charge_number))
	, PATIENT_NAME = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].patient_name))
	, MEDICATION_NAME = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].medication_name))
	, PRESCRIBER = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].prescriber))
	, Pharmacy_routing_type = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_route))
	, Pharmacy_name = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_name))
	, STATUS = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].status))
	, STRENGTH_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose))
	, STRENGTH_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose_unit))
	, ROUTE_OF_ADMIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].route_of_admin))
	, VOLUME_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose))
	, VOLUME_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose_unit))
	, DRUG_FORM = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_form))
	, FREQUENCY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].frequency))
	, DURATION = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration))
	, DURATION_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration_unit))
	, DISPENSE_QTY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_qty))
	, DISPENSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_unit))
	, NUMBER_OF_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].no_refil))
	, TOTAL_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].tot_refil))
	, SPECIAL_INSTRUCTION = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].special_instruction))
	, MED_START_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_start_date))
	, MED_STOP_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_stop_date))
	, PRN_INSTRUCTION = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].prn_instruction))
	, INDICATION = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].indication))
	, DRUG_CLASS_CODE1 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code1))
	, DRUG_CLASS_DESCRIPTION1 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description1))
	, DRUG_CLASS_CODE2 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code2))
	, DRUG_CLASS_DESCRIPTION2 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description2))
	, DRUG_CLASS_CODE3 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code3))
	, DRUG_CLASS_DESCRIPTION3 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description3))
 
	FROM
		(DUMMYT   D1  WITH SEQ = SIZE(RX->olist, 5))
 
	PLAN D1 where cnvtint(rx->olist[D1.SEQ].drug_class_code3) in(60, 191)
 
	ORDER BY FACILITY, ORDER_DATE
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

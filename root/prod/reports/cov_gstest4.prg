 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May 2019
	Solution:			Quality/INA/Pharmacy
	Source file name:	      cov_phq_bcma_prsnl_detail.prg
	Object name:		cov_phq_bcma_prsnl_detail
	Request#:			5016
	Program purpose:	      BCMA - Compliance details on Nurse unit and Personnel level
	Executing from:		DA2
 	Special Notes:          Removed all Leapfrog sections in LB as per this CR
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-----------------------------------------------------------------
5/29/19     Geetha      CR#5017 - Include all depts/organizations (including Ambulatory locations)
06/04/19    Geetha      CR#4955 - Dispense category - "Dummy Item COA" excluded
07/11/19    Geetha      CR 5246 - add nurse unit description
09/10/19	Geetha	CR#5389 - exclude Template-Non-Formulary intermitent and continuous from BCMA reports
06/04/20    Geetha      CR#7524 - BCMA - Process to exclude drugs from Scan Rate reports - ongoing special project
 
******************************************************************************/
 
drop program cov_gstest4:DBA go
create program cov_gstest4:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Report Type" = 2
	, "Facility" = 0
	, "Nurse Unit" = 0 

with OUTDEV, start_datetime, end_datetime, repo_type, acute_facilities, 
	nurse_unit
 
/**************************************************************
; Variable Declaration
**************************************************************/
declare fac_var = vc with noconstant(' ')
declare opr_nu_var    = vc with noconstant("")
declare initcap() = c100
declare username           = vc with protect
declare inpatient_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
declare observation_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Observation")), protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD bcma_sum(
	1 report_ran_by = vc
	1 list[*]
		2 facility_cd = f8
		2 facility = vc
		2 location_cd = f8
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
		2 nurse_unit = vc
		2 nurse_unit_cd = f8
		2 leapfrog_unit = vc
		2 lp_unit_tot_med_given = f8
		2 lp_unit_tot_compliance = f8
		2 unit_tot_med_given = f8
		2 unit_tot_med_scan = f8
		2 unit_tot_wrist_scan = f8
		2 unit_tot_compliance = f8
		2 prsnl_name = vc
		2 prsnl_role = vc
		2 pr_tot_med_given = f8
		2 pr_tot_med_scan = f8
		2 pr_tot_wrist_scan = f8
		2 pr_tot_compliance = f8
		2 lp_pr_tot_med_given = f8
		2 lp_pr_tot_compliance = f8
)
 
;--------------- Helpers -------------------------------------------------------------
 
Record bcma(
	1 rec_cnt = i4
	1 plist[*]
		2 facility_cd = f8
		2 facility = vc
		2 location_cd = f8
		2 nurse_unit = vc
		2 nurse_unit_cd = f8
		2 prsnl_name = vc
		2 prsnl_position = vc
		2 encntrid = f8
		2 med_admin_eventid = f8
		2 event_cnt = i4
		2 eventid = f8
		2 orderid = f8
		2 catalogcd = f8
		2 positive_med_ind = i4
		2 positive_patient_ind = i4
		2 itemid = f8
		2 charge_number = vc
		2 non_bcma_med = vc
		2 order_mnemonic = vc
		2 met_compli = i2
		2 lp_eve_cnt = i2
		2 lp_met_compli = i2
)
 
Record nu(
	1 list[*]
		2 n_unit_cd = f8
		2 n_unit = vc
		2 nu_tot_med_given = f8
		2 nu_tot_med_scan = f8
		2 nu_tot_wrist_scan = f8
		2 nu_tot_compliance = f8
		2 lp_nu_tot_med_given = f8
		2 lp_nu_tot_compliance = f8
)
 
Record fac(
	1 list[*]
		2 facility_cd = f8
		2 facility = vc
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
	)
 
;--------------------------------------------------------
;Get facility name
 
case ($acute_facilities)
 of 2553225851.00: set fac_var = 'Fort Sanders Regional Medical Center' ;FSR
 of 2553225859.00: set fac_var = 'LeConte Medical Center' ;LCMC
 of 2554055089.00: set fac_var = 'Morristown-Hamblen Healthcare System' ;MHHS
 of 2554055109.00: set fac_var = 'Parkwest Medical Center' ;PWMC
 of 2554055117.00: set fac_var = 'Methodist Medical Center' ;MMC
 of 2554055131.00: set fac_var = 'Roane Medical Center' ;RMC
 of 2554055139.00: set fac_var = 'Fort Loudoun Medical Center' ;FLMC
endcase
 
call echo(build2('fac_var = ', fac_var))
 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif
 
 
;--------------------------------------------------------
;Get user in action
select into "NL:"
from	prsnl p
where p.person_id = reqinfo->updt_id
detail
	bcma_sum->report_ran_by = p.username
with nocounter
 
;----------------------------------------------------------------------------------------------------------
;Get Med admins
select into $outdev
 
e.encntr_id, fac = trim(fac_var), nurse_unit = uar_get_code_display(mae.nurse_unit_cd)
, prsnl_name = initcap(pr.name_full_formatted), role = uar_get_code_display(pr.position_cd)
, mae.event_id, mae.med_admin_event_id,  mae.nurse_unit_cd, mae.event_cnt, o.order_id
, mae.positive_med_ident_ind, mae.positive_patient_ident_ind, pr.name_full_formatted, o.hna_order_mnemonic
, met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif )
, lp_event_cnt = evaluate2(if(e.encntr_type_cd = inpatient_var) 1 else 0 endif )
, lp_met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1
  					and e.encntr_type_cd = inpatient_var)1 else 0 endif )
 
from location l
	, encounter e
	, clinical_event ce
	, med_admin_event mae
	, order_ingredient oi
  	, prsnl pr
  	, order_dispense od
	, orders o
  	,(left join order_product op on op.order_id = o.order_id)
 	,(left join med_identifier mi on mi.item_id = op.item_id
		and mi.med_identifier_type_cd = 3096.00 ;Charge Number
		and mi.active_ind = 1)
 
plan l where l.facility_accn_prefix_cd = $acute_facilities
	and l.active_ind = 1
 
join e where e.loc_facility_cd = l.location_cd
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.result_status_cd in(25, 34, 35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 
join mae where mae.event_id = ce.event_id
	and mae.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
	and operator(mae.nurse_unit_cd, opr_nu_var, $nurse_unit)
  	;and mae.nurse_unit_cd = $nurse_unit
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
 
join op
join mi
 
join oi where oi.order_id =  mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join od where od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
 
join pr where pr.person_id = mae.prsnl_id
	and pr.active_ind = 1
 
order by mae.event_id
 
Head report
	cnt = 0
Head mae.event_id
	cnt += 1
	call alterlist(bcma->plist, cnt)
	bcma->plist[cnt].facility_cd = $acute_facilities
	bcma->plist[cnt].facility = fac_var
	bcma->plist[cnt].location_cd = l.location_cd
	bcma->plist[cnt].nurse_unit = uar_get_code_display(mae.nurse_unit_cd)
	bcma->plist[cnt].nurse_unit_cd = mae.nurse_unit_cd
	bcma->plist[cnt].prsnl_name = prsnl_name
	bcma->plist[cnt].prsnl_position = role
	bcma->plist[cnt].encntrid = e.encntr_id
	bcma->plist[cnt].lp_eve_cnt = lp_event_cnt
	bcma->plist[cnt].lp_met_compli = lp_met_comp
	bcma->plist[cnt].met_compli = met_comp
	bcma->plist[cnt].orderid = o.order_id
	bcma->plist[cnt].catalogcd = o.catalog_cd
	bcma->plist[cnt].itemid = op.item_id
	bcma->plist[cnt].charge_number = trim(mi.value, 3)
	bcma->plist[cnt].order_mnemonic = cnvtlower(o.order_mnemonic)
	bcma->plist[cnt].eventid = mae.event_id
	bcma->plist[cnt].event_cnt = mae.event_cnt
	bcma->plist[cnt].med_admin_eventid = mae.med_admin_event_id
	bcma->plist[cnt].positive_med_ind = mae.positive_med_ident_ind
	bcma->plist[cnt].positive_patient_ind = mae.positive_patient_ident_ind
 
with nocounter
 
;----------- OLD -----------------------------------------------------------------------------------------------
/*
;Get Med admins
select into 'nl:'
 
fac = trim(fac_var) ;uar_get_code_description(i.location_cd)
, i.encntr_id, i.event_id
, nurse_unit = uar_get_code_display(i.nurse_unit_cd)
, prsnl_name = initcap(i.name_full_formatted)
, role = uar_get_code_display(i.position_cd)
 
from(
 (select distinct
   e.location_cd,e.encntr_id, mae.event_id, mae.med_admin_event_id,  mae.nurse_unit_cd, mae.event_cnt, o.order_id
  , mae.positive_med_ident_ind, mae.positive_patient_ident_ind, pr.name_full_formatted, pr.position_cd, o.hna_order_mnemonic
  , met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif )
  , lp_event_cnt = evaluate2(if(e.encntr_type_cd = inpatient_var) 1 else 0 endif )
  , lp_met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1
  					and e.encntr_type_cd = inpatient_var)1 else 0 endif )
 
  from location l, encounter e, clinical_event ce, med_admin_event mae, orders o, order_ingredient oi
  		,prsnl pr, order_dispense od
	where l.facility_accn_prefix_cd = $acute_facilities
	and e.loc_facility_cd = l.location_cd
	and e.active_ind = 1
	and ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.result_status_cd in(25, 34, 35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and mae.event_id = ce.event_id
	and mae.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
  	and mae.nurse_unit_cd = $nurse_unit
	and o.order_id = mae.template_order_id
	and o.active_ind = 1
	and oi.order_id =  mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
	and od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
	and pr.person_id = mae.prsnl_id
	with sqltype('f8','f8','f8','f8','f8','f8','f8','i2','i2','vc','f8','vc','i2','i2','i2')
  )i
)
 
plan i
 
order by i.event_id
 
Head report
	cnt = 0
Head i.event_id
	cnt += 1
	call alterlist(bcma->plist, cnt)
	bcma->plist[cnt].facility_cd = $acute_facilities
	bcma->plist[cnt].facility = fac_var
	bcma->plist[cnt].location_cd = i.location_cd
	bcma->plist[cnt].nurse_unit = uar_get_code_display(i.nurse_unit_cd)
	bcma->plist[cnt].nurse_unit_cd = i.nurse_unit_cd
	bcma->plist[cnt].prsnl_name = prsnl_name
	bcma->plist[cnt].prsnl_position = role
	bcma->plist[cnt].encntrid = i.encntr_id
	bcma->plist[cnt].lp_eve_cnt = i.lp_event_cnt
	bcma->plist[cnt].lp_met_compli = i.lp_met_comp
	bcma->plist[cnt].met_compli = i.met_comp
	bcma->plist[cnt].orderid = i.order_id
	bcma->plist[cnt].order_mnemonic = cnvtlower(i.hna_order_mnemonic)
	bcma->plist[cnt].eventid = i.event_id
	bcma->plist[cnt].event_cnt = i.event_cnt
	bcma->plist[cnt].med_admin_eventid = i.med_admin_event_id
	bcma->plist[cnt].positive_med_ind = i.positive_med_ident_ind
	bcma->plist[cnt].positive_patient_ind = i.positive_patient_ident_ind
 
with nocounter
 
;--------------------------------------------------------------------------------
;Get Item id
select into 'nl:'
 
from	(dummyt d with seq = value(size(bcma->plist, 5)))
	, order_product op
 
plan d
 
join op where op.order_id = outerjoin(bcma->plist[d.seq].orderid)
 
order by op.item_id
 
Head op.order_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(bcma->plist,5), op.order_id ,bcma->plist[icnt].orderid)
      if(idx > 0)
		bcma->plist[idx].itemid = op.item_id
	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Find missing Item_id's
select into 'nl:'
     mair.event_id, mai.item_id, mai.med_product_id
from
	(dummyt d WITH seq = value(size(bcma->plist,5)))
      , ce_med_admin_ident_reltn mair
	, ce_med_admin_ident mai
 
plan d where bcma->plist[d.seq].itemid = 0
 
join mair where mair.event_id = bcma->plist[d.seq].eventid
 
join mai where mai.ce_med_admin_ident_id = outerjoin(mair.ce_med_admin_ident_id)
 
order by mair.event_id
 
Head mair.event_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(bcma->plist,5), mair.event_id ,bcma->plist[icnt].eventid)
      if(idx > 0)
      	if(bcma->plist[idx].itemid = 0)
			bcma->plist[idx].itemid = mai.item_id
		endif
	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Get Charge numbers
select into 'nl:'
 
 mi.item_id, value = trim(mi.value ,3), mi.med_identifier_id
 
from	(dummyt d with seq = value(size(bcma->plist, 5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = bcma->plist[d.seq].itemid
	and mi.active_ind = 1
	and mi.med_identifier_type_cd = 3096.00 ;charge_num_var
 
order by mi.item_id
 
Head mi.item_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(bcma->plist,5), mi.item_id ,bcma->plist[icnt].itemid)
      while(idx > 0)
		bcma->plist[idx].charge_number = trim(mi.value ,3)
	      idx = locateval(icnt,(idx+1), size(bcma->plist,5), mi.item_id ,bcma->plist[icnt].itemid)
	endwhile
 
with nocounter */
;------------------ END old ----------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------
 
;Flag Non-BCMA meds as per pharmacy exclusion list
select into $outdev
 
charge_num = trim(cv1.display, 3) ;trim(bcma->plist[d.seq].charge_number, 3)
, cat = bcma->plist[d.seq].catalogcd, item = bcma->plist[d.seq].itemid
 
from	(dummyt d with seq = value(size(bcma->plist, 5)))
  	, code_value cv1
  	, code_value_extension cve
  	, code_value_extension cve1
 
plan cv1 where cv1.code_set = 100499
	and cv1.cdf_meaning = 'BCMA_RX'
	and cv1.active_ind = 1
 
join d where trim(bcma->plist[d.seq].charge_number, 3) = trim(cv1.display, 3)
 
join cve where cve.code_set = cv1.code_set
	and cv1.code_value = cv1.code_value
	and cve.field_name = 'Catalog_cd'
	and cnvtreal(cve.field_value) = bcma->plist[d.seq].catalogcd
 
join cve1 where cve1.code_set = cv1.code_set
	and cve1.code_value = cv1.code_value
	and cve1.field_name = 'Item_id'
	and cnvtreal(cve1.field_value) = bcma->plist[d.seq].itemid
 
order by charge_num
 
Head charge_num
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,size(bcma->plist,5) ,charge_num ,trim(bcma->plist[cnt].charge_number, 3))
      while(idx > 0)
		bcma->plist[idx].non_bcma_med = 'Yes'
	      idx = locateval(cnt ,(idx+1) ,size(bcma->plist,5) ,charge_num ,trim(bcma->plist[cnt].charge_number, 3))
	endwhile
 
With nocounter
 
 
;----------------------------------------------------------------------------------------------------
;----------- Aggregated Results - seperate sections(bec's of the Non-RDBMS table) -------------------
;----------------------------------------------------------------------------------------------------
 
;Get aggregated results for PRSNL
select into 'nl:'
 fac_cd = bcma->plist[d1.seq].facility_cd
, loc = bcma->plist[d1.seq].location_cd
, nurse_unit = trim(substring(1,100,bcma->plist[d1.seq].nurse_unit))
, nurse_unit_cd =	bcma->plist[d1.seq].nurse_unit_cd
, prsnl_name = bcma->plist[d1.seq].prsnl_name
, role = substring(1,100,bcma->plist[d1.seq].prsnl_position)
, event_cnt = bcma->plist[d1.seq].event_cnt
, event_id = bcma->plist[d1.seq].eventid
, positive_med_ind = bcma->plist[d1.seq].positive_med_ind
, positive_patient_ind = bcma->plist[d1.seq].positive_patient_ind
, met_compli = cnvtint(bcma->plist[d1.seq].met_compli)
, lp_event_cnt = bcma->plist[d1.seq].lp_eve_cnt
, lp_met_comp = bcma->plist[d1.seq].lp_met_compli
 
from	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1 where bcma->plist[d1.seq].non_bcma_med != 'Yes'
 
/*Non-Formulary Items
where substring(1,4, trim(substring(1, 30, bcma->plist[d1.seq].charge_number ))) != 'NCRX' ;non chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by fac_cd, nurse_unit, prsnl_name, event_id
 
Head report
	cnt = 0
Head prsnl_name
	cnt += 1
	call alterlist(bcma_sum->list, cnt)
Foot prsnl_name
	bcma_sum->list[cnt].facility_cd = fac_cd
	bcma_sum->list[cnt].facility = fac_var
	bcma_sum->list[cnt].location_cd = loc
	bcma_sum->list[cnt].nurse_unit_cd = nurse_unit_cd
	bcma_sum->list[cnt].nurse_unit = nurse_unit
	bcma_sum->list[cnt].prsnl_name = prsnl_name
	bcma_sum->list[cnt].prsnl_role = role
	bcma_sum->list[cnt].pr_tot_med_given = sum(event_cnt)
	bcma_sum->list[cnt].pr_tot_med_scan =sum(positive_med_ind)
	bcma_sum->list[cnt].pr_tot_wrist_scan = sum(positive_patient_ind)
	bcma_sum->list[cnt].pr_tot_compliance = sum(met_compli)
	bcma_sum->list[cnt].lp_pr_tot_med_given = sum(lp_event_cnt)
	bcma_sum->list[cnt].lp_pr_tot_compliance = sum(lp_met_comp)
 
with nocounter
 
;--------------------------------------------------------------------------------------------
;Get aggregated results for Nurse Units
select into 'nl:'
 fac_cd = bcma->plist[d1.seq].facility_cd
, loc = bcma->plist[d1.seq].location_cd
, nurse_unit = bcma->plist[d1.seq].nurse_unit
, nurse_unit_cd =	bcma->plist[d1.seq].nurse_unit_cd
, prsnl_name = bcma->plist[d1.seq].prsnl_name
, role = bcma->plist[d1.seq].prsnl_position
, event_cnt = bcma->plist[d1.seq].event_cnt
, event_id = bcma->plist[d1.seq].eventid
, positive_med_ind = bcma->plist[d1.seq].positive_med_ind
, positive_patient_ind = bcma->plist[d1.seq].positive_patient_ind
, met_compli = cnvtint(bcma->plist[d1.seq].met_compli)
, lp_event_cnt = bcma->plist[d1.seq].lp_eve_cnt
, lp_met_comp = bcma->plist[d1.seq].lp_met_compli
 
from	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1 where bcma->plist[d1.seq].non_bcma_med != 'Yes'
 
/*Non-Formulary Items
 where substring(1,4, trim(substring(1, 30, bcma->plist[d1.seq].charge_number ))) != 'NCRX' ;non chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by fac_cd, nurse_unit_cd, event_id
 
Head report
	ncnt = 0
Head nurse_unit_cd
	ncnt += 1
	call alterlist(nu->list, ncnt)
 
Foot nurse_unit_cd
	nu->list[ncnt].n_unit_cd = nurse_unit_cd
	nu->list[ncnt].n_unit = uar_get_code_display(nurse_unit_cd)
	nu->list[ncnt].nu_tot_med_given = sum(event_cnt)
	nu->list[ncnt].nu_tot_med_scan = sum(positive_med_ind)
	nu->list[ncnt].nu_tot_wrist_scan = sum(positive_patient_ind)
	nu->list[ncnt].nu_tot_compliance = sum(met_compli)
	nu->list[ncnt].lp_nu_tot_med_given = sum(lp_event_cnt)
	nu->list[ncnt].lp_nu_tot_compliance = sum(lp_met_comp)
 
with nocounter
 
call echorecord(nu)
 
;--------------------------------------------------------
;Assign Nurse Unit results to bcma_sum
select into 'nl:'
 
n_unit = nu->list[d2.seq].n_unit_cd
,unit = uar_get_code_display(nu->list[d2.seq].n_unit_cd)
 
from (dummyt   d1  with seq = size(bcma_sum->list, 5))
	,(dummyt   d2  with seq = size(nu->list, 5))
 
plan d1
 
join d2 where bcma_sum->list[d1.seq].nurse_unit_cd = nu->list[d2.seq].n_unit_cd
 
order by n_unit
 
Head n_unit
	num = 0
	idx = 0
      idx = locateval(num ,1 ,size(bcma_sum->list ,5), n_unit ,bcma_sum->list[num].nurse_unit_cd)
      while(idx > 0)
		bcma_sum->list[idx].unit_tot_med_given = nu->list[d2.seq].nu_tot_med_given
		bcma_sum->list[idx].unit_tot_med_scan = nu->list[d2.seq].nu_tot_med_scan
		bcma_sum->list[idx].unit_tot_wrist_scan = nu->list[d2.seq].nu_tot_wrist_scan
		bcma_sum->list[idx].unit_tot_compliance = nu->list[d2.seq].nu_tot_compliance
		bcma_sum->list[idx].lp_unit_tot_med_given = nu->list[d2.seq].lp_nu_tot_med_given
		bcma_sum->list[idx].lp_unit_tot_compliance = nu->list[d2.seq].lp_nu_tot_compliance
	      idx = locateval(num,(idx+1),size(bcma_sum->list ,5), n_unit ,bcma_sum->list[num].nurse_unit_cd)
	endwhile
 
with nocounter
 
call echorecord(bcma_sum)
 
;--------------------------------------------------------------------------------------------
;Get aggregated results for Facility
select into 'nl:'
 fac_cd = bcma->plist[d1.seq].facility_cd
, loc = bcma->plist[d1.seq].location_cd
, nurse_unit = bcma->plist[d1.seq].nurse_unit
, prsnl_name = bcma->plist[d1.seq].prsnl_name
, event_cnt = bcma->plist[d1.seq].event_cnt
, event_id = bcma->plist[d1.seq].eventid
, positive_med_ind = bcma->plist[d1.seq].positive_med_ind
, positive_patient_ind = bcma->plist[d1.seq].positive_patient_ind
, met_compli = cnvtint(bcma->plist[d1.seq].met_compli)
 
from	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1 where bcma->plist[d1.seq].non_bcma_med != 'Yes'
 
/*Non-Formulary Items
where substring(1,4, trim(substring(1, 30, bcma->plist[d1.seq].charge_number ))) != 'NCRX' ;non chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by fac_cd, nurse_unit, prsnl_name, event_id
 
Head report
	fcnt = 0
Head fac_cd
	fcnt += 1
	call alterlist(fac->list, fcnt)
Foot fac_cd
	fac->list[fcnt].facility_cd = fac_cd
	fac->list[fcnt].fac_tot_med_given = sum(event_cnt)
	fac->list[fcnt].fac_tot_med_scan = sum(positive_med_ind)
	fac->list[fcnt].fac_tot_wrist_scan = sum(positive_patient_ind)
	fac->list[fcnt].fac_tot_compliance = sum(met_compli)
with nocounter
 
;call echorecord(fac)
 
;--------------------------------------------------------
;Assign facility results to bcma_sum
select into 'nl:'
 
fac_cd = fac->list[d2.seq].facility_cd
 
from (dummyt   d1  with seq = size(bcma_sum->list, 5))
	,(dummyt   d2  with seq = size(fac->list, 5))
 
plan d1
 
join d2 where bcma_sum->list[d1.seq].facility_cd = fac->list[d2.seq].facility_cd
 
order by fac_cd
 
Head fac_cd
	lnum = 0
	idx = 0
      idx = locateval(lnum ,1 ,size(bcma_sum->list ,5), fac_cd, bcma_sum->list[lnum].facility_cd)
      while(idx > 0)
		bcma_sum->list[idx].fac_tot_med_given = fac->list[d2.seq].fac_tot_med_given
		bcma_sum->list[idx].fac_tot_med_scan = fac->list[d2.seq].fac_tot_med_scan
		bcma_sum->list[idx].fac_tot_wrist_scan = fac->list[d2.seq].fac_tot_wrist_scan
		bcma_sum->list[idx].fac_tot_compliance = fac->list[d2.seq].fac_tot_compliance
	      idx = locateval(lnum,(idx+1),size(bcma_sum->list ,5), fac_cd ,bcma_sum->list[lnum].facility_cd)
	endwhile
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;**** Flag LeapFrog departments/units ***** This section not used in report as per new CR
/*
select into 'nl:'
 
 nunit = substring(1, 30, bcma_sum->list[d.seq].nurse_unit)
 
from	(dummyt d  with seq = size(bcma_sum->list, 5))
 
plan d where bcma_sum->list[d.seq].nurse_unit in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU' )
 
order by nunit
 
Head nunit
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bcma_sum->list,5), nunit, bcma_sum->list[cnt].nurse_unit)
	while(idx > 0)
		bcma_sum->list[idx].leapfrog_unit = 'Y' ;flag indicating leapfrog unit
		;bcma_sum->list[idx].nurse_unit = build2(bcma_sum->list[idx].nurse_unit, '*') ;leapfrog units ;removed as per new CR
		idx = locateval(cnt,(idx+1) ,size(bcma_sum->list,5) ,nunit ,bcma_sum->list[cnt].nurse_unit)
	endwhile
 
with nocounter
 
call echorecord(bcma_sum)
*/
;-----------------------------------------------------------------------
if($repo_type = 3);Unit total only 

select distinct into $outdev
 	nurse_unit = trim(uar_get_code_description(bcma_sum->list[d1.seq].nurse_unit_cd))
	, total_medications_given = bcma_sum->list[d1.seq].unit_tot_med_given
	, medications_scanned = bcma_sum->list[d1.seq].unit_tot_med_scan
 	, medications_scan_percent = 
 	    build2(((bcma_sum->list[d1.seq].unit_tot_med_scan / bcma_sum->list[d1.seq].unit_tot_med_given) * 100), '%')
	, wristbands_scanned = bcma_sum->list[d1.seq].unit_tot_wrist_scan
	, wristbands_scan_percent = 
	    build2(((bcma_sum->list[d1.seq].unit_tot_wrist_scan / bcma_sum->list[d1.seq].unit_tot_med_given) * 100), '%')
 
from
	(dummyt   d1  with seq = size(bcma_sum->list, 5))
 
plan d1
 
order by nurse_unit
 
with nocounter, separator=" ", format
 
elseif($repo_type = 2);PRSNL detail only 

select into $outdev
	 nurse_unit = trim(uar_get_code_description(bcma_sum->list[d1.seq].nurse_unit_cd))
	, personnel_name = trim(substring(1, 30, bcma_sum->list[d1.seq].prsnl_name))
	, role = trim(substring(1, 100, bcma_sum->list[d1.seq].prsnl_role))
	, total_medications_given = bcma_sum->list[d1.seq].pr_tot_med_given
	, medications_scanned = bcma_sum->list[d1.seq].pr_tot_med_scan
 	, medications_scan_percent = 
 	  build2(((bcma_sum->list[d1.seq].pr_tot_med_scan / bcma_sum->list[d1.seq].pr_tot_med_given) * 100), '%')
	, wristbands_scanned = bcma_sum->list[d1.seq].pr_tot_wrist_scan
	, wristbands_scan_percent = 
	  build2(((bcma_sum->list[d1.seq].pr_tot_wrist_scan / bcma_sum->list[d1.seq].pr_tot_med_given) * 100), '%')
 
from
	(dummyt   d1  with seq = size(bcma_sum->list, 5))
 
plan d1
 
order by nurse_unit
 
with nocounter, separator=" ", format

endif


;-----------temp-----------------------------------------------------------
;All data combined for final result
 
/*SELECT into $outdev
 
	FACILITY = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].facility)
	, FAC_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].fac_tot_med_given
	, FAC_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_med_scan
	, FAC_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_wrist_scan
	, FAC_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].fac_tot_compliance
	, NURSE_UNIT = SUBSTRING(1, 100, BCMA_SUM->list[D1.SEQ].nurse_unit)
	, LEAPFROG_UNIT = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].leapfrog_unit)
	, UNIT_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].unit_tot_med_given
	, UNIT_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].unit_tot_med_scan
	, UNIT_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].unit_tot_wrist_scan
	, UNIT_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].unit_tot_compliance
	, PRSNL_NAME = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_name)
	, PRSNL_ROLE = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_role)
	, PR_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].pr_tot_med_given
	, PR_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_med_scan
	, PR_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_wrist_scan
	, PR_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].pr_tot_compliance
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA_SUM->list, 5))
 
PLAN D1
 
order by NURSE_UNIT
 
with nocounter, separator=" ", format
*/


end go
;----------------------------------------------------------------------------
 
 
 
 

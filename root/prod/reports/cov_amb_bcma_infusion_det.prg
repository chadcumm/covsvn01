 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		APR'2019
	Solution:			Quality/Ambulatory
	Source file name:	      cov_amb_bcma_infusion_det.prg
	Object name:		cov_amb_bcma_infusion_det
	Request#:			4752
	Program purpose:	      Patient level BCMA details for ambulatory infusion centers
	Executing from:		DA2
 	Special Notes:          Ambulatory Infusion centers
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
------------------------------------------------------------------------------------------------------
06/04/19    Geetha     CR#4955 - Dispense category - "Dummy Item COA" excluded
09/10/19	Geetha     CR#5389 - exclude Template-Non-Formulary intermitent and continuous from BCMA reports
06/04/20    Geetha     CR#7524 - BCMA - Process to exclude drugs from Scan Rate reports - ongoing special project
01/11/22    Geetha     CR#11707 - Termed users need to be included in BCMA reports
***************************************************************************************************/
 
drop program cov_amb_bcma_infusion_det:dba go
create program cov_amb_bcma_infusion_det:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Infusion Center" = 0 

with OUTDEV, start_datetime, end_datetime, infusion_center
 

/**************************************************************
; Variable Declaration
**************************************************************/

declare opr_nu_var    = vc with noconstant("")
 
 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($infusion_center),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($infusion_center),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif
 
 
;--------------------------------------------------------------------------------------------------------- 
RECORD bcma(
	1 plist[*]
		2 facility = vc
	  	2 Nurse_unit = vc
	  	2 fin = vc
		2 Patient_Name = vc
		2 encounter_type = vc
		2 Result_Status = vc
		2 medication_scanned = vc
		2 wristband_scanned = vc
		2 med_admin_count = i4
		2 order_mnemonic = vc
		2 medication = vc
		2 admin_dt = vc
		2 Personnel_Name = vc
		2 personnel_Position  = vc
		2 source = vc
		2 orderid = f8
		2 catalogcd = f8
		2 eventid = f8
		2 itemid = f8
		2 charge_number = vc
		2 non_bcma_med = vc
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
select into 'nl:'
 
  facility = trim(uar_get_code_display(e.loc_facility_cd))
  , nurse_unit = trim(uar_get_code_description(mae.nurse_unit_cd))
  , fin = trim(ea.alias)
  , pat_Name = trim(p.name_full_formatted)
  , enc_type = uar_get_code_display(e.encntr_type_cd)
  , Result_Status = uar_get_code_display(ce.result_status_cd)
  , med_scanned = if(mae.positive_med_ident_ind = 1) 'Y' else 'N' endif
  , wrist_scanned = if(mae.positive_patient_ident_ind = 1) 'Y' else 'N' endif
  , med_admin_count = mae.event_cnt
  , order_mnemonic = trim(o.order_mnemonic)
  , admin_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
  , prsnl_name = trim(pr.name_full_formatted)
  , prsnl_position = trim(uar_get_code_display(mae.position_cd))
  , source =
  	if(mae.source_application_flag = 0)'Unknown Application'
		elseif(mae.source_application_flag = 1)'CareMobile'
		elseif(mae.source_application_flag = 2)'CareAdmin'
		elseif(mae.source_application_flag = 3)'PowerChart'
	 	elseif(mae.source_application_flag is null) 'Unknown Application'
 	endif
 
FROM
 	 med_admin_event mae
 	, clinical_event ce
	, encounter e
	, order_ingredient oi
	, order_dispense od
	, prsnl pr
	, person p
	, encntr_alias ea
	, orders o
  	, (left join order_product op on op.order_id = o.order_id)
 	, (left join med_identifier mi on mi.item_id = op.item_id
			and mi.med_identifier_type_cd = 3096.00 ;Charge Number
			and mi.active_ind = 1)
 
plan mae where operator(mae.nurse_unit_cd, opr_nu_var, $infusion_center)
	;mae.nurse_unit_cd = $infusion_center
	and mae.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
  	and mae.nurse_unit_cd is not null
 
join ce where ce.event_id = mae.event_id
	and ce.result_status_cd in(25, 34, 35)
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
	
join op
join mi	
 
join e where e.person_id = ce.person_id
	and e.encntr_id = ce.encntr_id
	and e.active_ind = 1
 
join oi where oi.order_id =  mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join od where od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
 
join pr where pr.person_id = mae.prsnl_id
	;and mae.prsnl_id != 0
 
join p where p.person_id = e.person_id
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by mae.event_id
 
Head report
	cnt = 0
Head  mae.event_id
	cnt += 1
	call alterlist(bcma->plist, cnt)
Detail
	bcma->plist[cnt].facility = facility
	bcma->plist[cnt].fin = fin
	bcma->plist[cnt].admin_dt = admin_dt
	bcma->plist[cnt].encounter_type = enc_type
	bcma->plist[cnt].Result_Status = Result_Status
	bcma->plist[cnt].medication_scanned = med_scanned
	bcma->plist[cnt].wristband_scanned = wrist_scanned
	bcma->plist[cnt].med_admin_count = med_admin_count
	bcma->plist[cnt].nurse_unit = nurse_unit
	bcma->plist[cnt].eventid = mae.event_id
	bcma->plist[cnt].medication = trim(o.order_mnemonic)
	bcma->plist[cnt].order_mnemonic = cnvtlower(o.hna_order_mnemonic)
	bcma->plist[cnt].orderid = o.order_id
	bcma->plist[cnt].catalogcd = o.catalog_cd
	bcma->plist[cnt].itemid = op.item_id
	bcma->plist[cnt].charge_number = trim(mi.value,3)
	bcma->plist[cnt].Patient_Name = pat_name
	bcma->plist[cnt].Personnel_Name = prsnl_name
	bcma->plist[cnt].personnel_Position = prsnl_position
	bcma->plist[cnt].source = source
 
with nocounter
 
;---------------------- Old ----------------------------------------------------------
/*
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
 
with nocounter
 
call echorecord(bcma)
*/ 
;-----------------------------------------------------------------------------------------------------------
 
;Flag Non-BCMA meds as per pharmacy exclusion list
select into $outdev
 
charge_num = trim(cv1.display, 3)
, cat = bcma->plist[d.seq].catalogcd, item = bcma->plist[d.seq].itemid, drug = bcma->plist[d.seq].medication
 
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
 
;====================== End of Non-BCMA meds ==========================================================================
 
call echorecord(bcma)

;-----------------------------------------------------------------------------------------------------------

select into $outdev
 
	facility = trim(substring(1, 300, bcma->plist[d1.seq].facility))
	, nurse_unit = trim(substring(1, 100, bcma->plist[d1.seq].nurse_unit))
	, fin = trim(substring(1, 10, bcma->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, bcma->plist[d1.seq].patient_name))
	, encounter_type = trim(substring(1, 50, bcma->plist[d1.seq].encounter_type))
	, result_status = trim(substring(1, 50, bcma->plist[d1.seq].result_status))
	, medication_scanned = trim(substring(1, 30, bcma->plist[d1.seq].medication_scanned))
	, wristband_scanned = trim(substring(1, 30, bcma->plist[d1.seq].wristband_scanned))
	, med_admin_count = bcma->plist[d1.seq].med_admin_count
	, medication = trim(substring(1, 500, bcma->plist[d1.seq].medication))
	, non_bcma_med = trim(substring(1, 3, bcma->plist[d1.seq].non_bcma_med))
	, administration_dt_tm  = substring(1, 30, bcma->plist[d1.seq].admin_dt)
	, personnel_name = trim(substring(1, 50, bcma->plist[d1.seq].personnel_name))
	, personnel_position = trim(substring(1, 100, bcma->plist[d1.seq].personnel_position))
	, source = substring(1, 30, bcma->plist[d1.seq].source)
	, charge_number = trim(substring(1, 30, bcma->plist[d1.seq].charge_number))
	;, order_id = bcma->plist[d1.seq].orderid
	;, catalog_cd = bcma->plist[d1.seq].catalogcd
	;, item_id = bcma->plist[d1.seq].itemid
	;, event_id = bcma->plist[d1.seq].eventid
 
from
	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1 where bcma->plist[d1.seq].non_bcma_med != 'Yes'

/*Non-Formulary Items
where substring(1,4, trim(substring(1, 30, bcma->plist[d1.seq].charge_number ))) != 'NCRX' ;non chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by facility, nurse_unit, personnel_name, patient_name, administration_dt_tm
 
with nocounter, separator=" ", format
 
end go
 
 
 
 

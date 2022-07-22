/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb'2021
	Solution:			Quality/INA/Pharmacy
	Source file name:	      cov_phq_BCMA_corphosp.prg
	Object name:		cov_phq_BCMA_corphosp
	Request#:			9696
	Program purpose:	      BCMA Compliance Detail - Patient level with COV CORP
	Executing from:		DA2
 	Special Notes:          Testing Cov Corp Hospitals only (IT internal use only) 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------

********************************************************************************************************************/
 
drop program cov_phq_BCMA_corphosp:DBA go
create program cov_phq_BCMA_corphosp:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Nurse Unit" = 0
	, "Personnel Type" = 0
 
with OUTDEV, acute_facilities, start_datetime, end_datetime, nurse_unit,
	prsnl_type
 
 
; 2552552449.00	COV CORP HOSP	FACILITY
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
declare initcap()     = c100
declare opr_nu_var    = vc with noconstant("")
declare opr_prsnl_var = vc with noconstant("")
declare num  = i4 with noconstant(0)
 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif
 
 
;Set Prsnl variable
if(substring(1,1,reflect(parameter(parameter2($prsnl_type),0))) = "L");multiple values were selected
	set opr_prsnl_var = "in"
elseif(parameter(parameter2($prsnl_type),1)= 0.0)	;all[*] values were selected
	set opr_prsnl_var = "!="
else									;a single value was selected
	set opr_prsnl_var = "="
endif
 
;----------------------------------------------------------------------------------------------
Record bcma(
	1 plist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 prsnl_name = vc
		2 prsnl_position = vc
		2 fin = vc
		2 patient_name = vc
		2 medication = vc
		2 med_admin_dt = vc
		2 med_admin_eventid = f8
		2 medication_scanned = vc
		2 wristband_scanned = vc
		2 med_over_reason = vc
		2 armband_over_reason = vc
		2 med_admin_alertid = f8
		2 med_admin_count = i4
		2 result_status = vc
		2 source = vc
		2 eventid = f8
		2 orderid = f8
		2 catalogcd = f8
		2 non_bcma_med = vc
		2 order_mnemonic = vc
		2 itemid = f8
		2 charge_number = vc
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
select into $outdev
 
facility = trim(uar_get_code_description(l.facility_accn_prefix_cd))
 ,o.order_id, op.item_id, mae.event_id
  , Nurse_unit = trim(uar_get_code_description(mae.nurse_unit_cd))
  , Personnel_Name = trim(pr.name_full_formatted)
  , personnel_Position = trim(uar_get_code_display(pr.position_cd))
  , fin = trim(ea.alias)
  , Patient_Name = trim(p.name_full_formatted)
  , Medication = trim(o.order_mnemonic)
  , Administration_Dt_Tm = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
  , medication_scanned = if(mae.positive_med_ident_ind = 1) 'Y' else 'N' endif
  , wristband_scanned = if(mae.positive_patient_ident_ind = 1) 'Y' else 'N' endif
  , med_admin_count = mae.event_cnt
  , Result_Status = uar_get_code_display(ce.result_status_cd)
  , source =
  	if(mae.source_application_flag = 0)'Unknown Application'
		elseif(mae.source_application_flag = 1)'CareMobile'
		elseif(mae.source_application_flag = 2)'CareAdmin'
		elseif(mae.source_application_flag = 3)'PowerChart'
	 	elseif(mae.source_application_flag is null) 'Unknown Application'
 	endif
 
from location l
	, encounter e
	, clinical_event ce
	, med_admin_event mae
	, order_ingredient oi
  	, prsnl pr
  	, person p
  	, encntr_alias ea
  	, order_dispense od
	, orders o
  	,(left join order_product op on op.order_id = o.order_id)
 	,(left join med_identifier mi on mi.item_id = op.item_id
			and mi.med_identifier_type_cd = 3096.00 ;Charge Number
			and mi.active_ind = 1)
 
plan l where(l.facility_accn_prefix_cd = $acute_facilities or (l.location_cd = 2552552449.00));COV CORP HOSP
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
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
 
join op
join mi
 
join oi where oi.order_id = mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join od where od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
 
join pr where pr.person_id = mae.prsnl_id
	and operator(pr.position_cd, opr_prsnl_var, $prsnl_type)
	and pr.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by mae.event_id
 
Head report
	cnt = 0
Head mae.event_id
	cnt += 1
	call alterlist(bcma->plist, cnt)
	bcma->plist[cnt].facility = facility
	bcma->plist[cnt].nurse_unit = nurse_unit
	bcma->plist[cnt].fin = fin
	bcma->plist[cnt].med_admin_count = med_admin_count
	bcma->plist[cnt].med_admin_dt = Administration_Dt_Tm
	bcma->plist[cnt].med_admin_eventid = mae.med_admin_event_id
	bcma->plist[cnt].medication = medication
	bcma->plist[cnt].medication_scanned = medication_scanned
	bcma->plist[cnt].patient_name = patient_name
	bcma->plist[cnt].prsnl_name = Personnel_Name
	bcma->plist[cnt].prsnl_position = personnel_Position
	bcma->plist[cnt].wristband_scanned = wristband_scanned
	bcma->plist[cnt].result_status = Result_Status
	bcma->plist[cnt].source = source
	bcma->plist[cnt].orderid = o.order_id
	bcma->plist[cnt].catalogcd = o.catalog_cd
	bcma->plist[cnt].order_mnemonic = cnvtlower(o.order_mnemonic)
	bcma->plist[cnt].eventid = mae.event_id
	bcma->plist[cnt].itemid = op.item_id
	bcma->plist[cnt].charge_number = trim(mi.value ,3)
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Get Med override reason
select into $outdev
 
mame.event_id, mame.med_admin_alert_id, med_reason = trim(uar_get_code_display(mame.reason_cd))
,maa.med_admin_alert_id
 
from	med_admin_med_error mame
	,med_admin_alert maa
 
plan mame where expand(num, 1, value(size(bcma->plist,5)), mame.event_id, bcma->plist[num].eventid)
 
join maa where maa.med_admin_alert_id = mame.med_admin_alert_id
	and maa.alert_type_cd =  2557969843.00 ;Medication Scan Override
 
order by mame.event_id
 
Head mame.event_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,size(bcma->plist,5) ,mame.event_id ,bcma->plist[cnt].eventid)
	if(idx > 0)
		bcma->plist[idx].med_over_reason = trim(uar_get_code_display(mame.reason_cd))
	endif
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------------------------------------
;Get Armband override reason
 
select into $outdev
 
mae.med_admin_event_id, maa.alert_type_cd, alert_type = uar_get_code_display(maa.alert_type_cd)
, reason = uar_get_code_display(mape.reason_cd)
 
from 	 med_admin_event mae
	,med_admin_alert maa
	,med_admin_pt_error mape
 
plan mae where expand(num, 1, value(size(bcma->plist,5)), mae.med_admin_event_id, bcma->plist[num].med_admin_eventid)
 
join maa where maa.nurse_unit_cd = mae.nurse_unit_cd
	and maa.prsnl_id = mae.prsnl_id
	and (maa.event_dt_tm between mae.beg_dt_tm and mae.end_dt_tm OR mae.updt_dt_tm = maa.updt_dt_tm)	
	and maa.alert_type_cd =  2557969911.00 ;PPID Override
 
join mape where mape.med_admin_alert_id = maa.med_admin_alert_id
	and mape.updt_id = maa.updt_id
 
order by mae.med_admin_event_id
 
Head mae.med_admin_event_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,size(bcma->plist,5) ,mae.med_admin_event_id ,bcma->plist[cnt].med_admin_eventid)
	if(idx > 0)
		bcma->plist[idx].armband_over_reason = trim(uar_get_code_display(mape.reason_cd))
	endif
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------------------------------------
 
;Flag Non-BCMA meds as per pharmacy exclusion list
select into $outdev
 
charge_num = trim(cv1.display, 3) ;trim(bcma->plist[d.seq].charge_number, 3)
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
 
call echorecord(bcma)
 
;-----------------------------------------------------------------------------------------------
 
select into $outdev
 
	facility = trim(substring(1, 10, bcma->plist[d1.seq].facility))
	, nurse_unit = trim(substring(1, 100, bcma->plist[d1.seq].nurse_unit))
	, personnel_name = trim(substring(1, 80, bcma->plist[d1.seq].prsnl_name))
	, personnel_position = trim(substring(1, 100, bcma->plist[d1.seq].prsnl_position))
	, fin = trim(substring(1, 10, bcma->plist[d1.seq].fin))
 	, patient_name = trim(substring(1, 80, bcma->plist[d1.seq].patient_name))
	, medication = trim(substring(1, 300, bcma->plist[d1.seq].medication))
	, non_bcma_med = trim(substring(1, 5, bcma->plist[d1.seq].non_bcma_med))
	, charge_number = trim(substring(1, 10, bcma->plist[d1.seq].charge_number))
	, administered_dt_tm = trim(substring(1, 30, bcma->plist[d1.seq].med_admin_dt))
	, medication_scanned = trim(substring(1, 30, bcma->plist[d1.seq].medication_scanned))
	, wristband_scanned = trim(substring(1, 30, bcma->plist[d1.seq].wristband_scanned))
	, med_override_reason = trim(substring(1, 100, bcma->plist[d1.seq].med_over_reason))
	, armband_override_reason = trim(substring(1, 100, bcma->plist[d1.seq].armband_over_reason))
	, med_admin_count = bcma->plist[d1.seq].med_admin_count
	, result_status = trim(substring(1, 30, bcma->plist[d1.seq].result_status))
	, source = trim(substring(1, 30, bcma->plist[d1.seq].source))
 	, orderid = bcma->plist[d1.seq].orderid
	, itemid = bcma->plist[d1.seq].itemid
	, catalog_cd = bcma->plist[d1.seq].catalogcd
 
from
	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1
 
/*Non-Formulary Items
WHERE SUBSTRING(1,4, trim(SUBSTRING(1, 30, BCMA->plist[D1.SEQ].charge_number ))) != 'NCRX' ;Non Chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by facility, nurse_unit, personnel_position, personnel_name, medication
 
with nocounter, separator=" ", format
 
#exitscript
 
end go
 
 
 

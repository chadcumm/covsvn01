/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/INA/Pharmacy
	Source file name:	      cov_phq_BCMA_leapfrog_compl.prg
	Object name:		cov_phq_BCMA_leapfrog_compl
	Request#:			3546
	Program purpose:	      BCMA Compliance Detail - Patient level
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
5/29/19     Geetha                  CR#5017 - Include all depts/organizations and sort order to personnel, Medication Name
06/04/19    Geetha                  CR#4955 - Dispense category - "Dummy Item COA" excluded
07/11/19    Geetha                  CR#5246 - add nurse unit description
08/27/19    Geetha                  CR#5406 - add prompt/filter by Personnel type
09/10/19	Geetha			CR#5389 - exclude Template-Non-Formulary intermitent and continuous from BCMA reports
06/04/20    Geetha       CR#7524 - BCMA - Process to exclude drugs from Scan Rate reports - ongoing special project

******************************************************************************/
 
drop program cov_gstest5:DBA go
create program cov_gstest5:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Nurse Unit" = 0
	, "Personnel Type" = "" 

with OUTDEV, acute_facilities, start_datetime, end_datetime, nurse_unit, 
	prsnl_type
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
declare initcap() = c100

declare opr_nu_var    = vc with noconstant(" ")
declare opr_prsnl_var = vc with noconstant(" ")

 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "l");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif

;------------------------------------------------------
;Set Prsnl variable
if(substring(1,1,reflect(parameter(parameter2($prsnl_type),0))) = "l");multiple values were selected
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
		2 medication_scanned = vc
		2 wristband_scanned = vc
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
	, orders o
  	,(left join order_product op on op.order_id = o.order_id)
 	,(left join med_identifier mi on mi.item_id = op.item_id
			and mi.med_identifier_type_cd = 3096.00 ;Charge Number
			and mi.active_ind = 1)
	, order_ingredient oi
  	, prsnl pr
  	, person p
  	, encntr_alias ea
  	, order_dispense od
  	
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
	and operator(mae.nurse_unit_cd, operate_nu_var, $nurse_unit)
	;and mae.nurse_unit_cd = $nurse_unit
  	
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
	;and pr.position_cd = $prsnl_type
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
 
;go to exitscript 
 
;============== old ======================================================= 
/*
select into 'nl:'
 
facility = trim(uar_get_code_description(i.facility_accn_prefix_cd))
 ,i.order_id, i.item_id, i.event_id
  , Nurse_unit = trim(uar_get_code_description(i.nurse_unit_cd))
  , Personnel_Name = trim(i.pr_name)
  , personnel_Position = trim(uar_get_code_display(i.position_cd))
  , fin = trim(i.alias)
  , Patient_Name = trim(i.name_full_formatted)
  , Medication = trim(i.order_mnemonic)
  , Administration_Dt_Tm = format(i.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
  , medication_scanned = if(i.positive_med_ident_ind = 1) 'Y' else 'N' endif
  , wristband_scanned = if(i.positive_patient_ident_ind = 1) 'Y' else 'N' endif
  , med_admin_count = i.event_cnt
  , Result_Status = uar_get_code_display(i.result_status_cd)
  , source =
  	if(i.source_application_flag = 0)'Unknown Application'
		elseif(i.source_application_flag = 1)'CareMobile'
		elseif(i.source_application_flag = 2)'CareAdmin'
		elseif(i.source_application_flag = 3)'PowerChart'
	 	elseif(i.source_application_flag is null) 'Unknown Application'
 	endif
 
from(
 
 (select distinct
   l.facility_accn_prefix_cd, mae.nurse_unit_cd, pr_name = pr.name_full_formatted, pr.position_cd, ea.alias, p.name_full_formatted
   , o.order_mnemonic, ce.event_end_dt_tm, mae.positive_med_ident_ind, mae.positive_patient_ident_ind, mae.event_cnt
   , ce.result_status_cd, mae.source_application_flag, mae.event_id, mae.med_admin_event_id, o.order_id, o.hna_order_mnemonic
   , o.catalog_cd
 
  from location l, encounter e, clinical_event ce, med_admin_event mae, orders o, order_ingredient oi
  		,prsnl pr, person p, encntr_alias ea, order_dispense od
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
	and oi.order_id = mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
	and od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
	and pr.person_id = mae.prsnl_id
	and pr.position_cd = $prsnl_type
	and p.person_id = e.person_id
	and ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
	with sqltype('f8','f8','vc','f8','vc','vc','vc','dq8','i2','i2','i4','f8','i2','f8','f8','f8','vc','f8')
  )i
)
 
plan i
 
order by i.event_id
 
Head report
	cnt = 0
Head i.event_id
	cnt += 1
	call alterlist(bcma->plist, cnt)
	bcma->plist[cnt].facility = facility
	bcma->plist[cnt].nurse_unit = nurse_unit
	bcma->plist[cnt].fin = fin
	bcma->plist[cnt].med_admin_count = med_admin_count
	bcma->plist[cnt].med_admin_dt = Administration_Dt_Tm
	bcma->plist[cnt].medication = medication
	bcma->plist[cnt].medication_scanned = medication_scanned
	bcma->plist[cnt].patient_name = patient_name
	bcma->plist[cnt].prsnl_name = Personnel_Name
	bcma->plist[cnt].prsnl_position = personnel_Position
	bcma->plist[cnt].wristband_scanned = wristband_scanned
	bcma->plist[cnt].result_status = Result_Status
	bcma->plist[cnt].source = source
	bcma->plist[cnt].orderid = i.order_id
	bcma->plist[cnt].catalogcd = i.catalog_cd
	bcma->plist[cnt].order_mnemonic = cnvtlower(i.hna_order_mnemonic)
	bcma->plist[cnt].eventid = i.event_id
 
with nocounter
;============== end old ======================================================= 

 
;---------------------------------------------------------------------------------------
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
      while(idx > 0)
		if(bcma->plist[idx].itemid = 0)
			bcma->plist[idx].itemid = op.item_id
		endif
	    idx = locateval(icnt,(idx+1) ,size(bcma->plist,5), op.order_id ,bcma->plist[icnt].orderid)
	endwhile
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
/*
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
*/
;-----------------------------------------------------------------------------------------------
/*
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
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(bcma->plist,5), mi.item_id ,bcma->plist[cnt].itemid)
      while(idx > 0)
      	if(bcma->plist[idx].charge_number = ' ')
			bcma->plist[idx].charge_number = trim(mi.value ,3)
		endif
	      idx = locateval(cnt,(idx+1), size(bcma->plist,5), mi.item_id ,bcma->plist[cnt].itemid)
	endwhile
 
with nocounter
*/ 
 
;====================== Start Non-BCMA meds Filter ====================================================================
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
 
;====================== End of Non-BCMA meds ==========================================================================
 
call echorecord(bcma)
 
;-----------------------------------------------------------------------------------------------
 
SELECT INTO $OUTDEV
 
	FACILITY = TRIM(SUBSTRING(1, 10, BCMA->plist[D1.SEQ].facility))
	, NURSE_UNIT = TRIM(SUBSTRING(1, 100, BCMA->plist[D1.SEQ].nurse_unit))
	, PERSONNEL_NAME = TRIM(SUBSTRING(1, 80, BCMA->plist[D1.SEQ].prsnl_name))
	, PERSONNEL_POSITION = TRIM(SUBSTRING(1, 100, BCMA->plist[D1.SEQ].prsnl_position))
	, FIN = TRIM(SUBSTRING(1, 10, BCMA->plist[D1.SEQ].fin))
 	, PATIENT_NAME = TRIM(SUBSTRING(1, 80, BCMA->plist[D1.SEQ].patient_name))
	, MEDICATION = TRIM(SUBSTRING(1, 300, BCMA->plist[D1.SEQ].medication))
	, NON_BCMA_MED = TRIM(SUBSTRING(1, 5, BCMA->plist[D1.SEQ].non_bcma_med))
	, charge_number = TRIM(SUBSTRING(1, 10, BCMA->plist[D1.SEQ].charge_number))
	, ADMINISTERED_DT_TM = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].med_admin_dt)
	, MEDICATION_SCANNED = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].medication_scanned)
	, WRISTBAND_SCANNED = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].wristband_scanned)
	, MED_ADMIN_COUNT = BCMA->plist[D1.SEQ].med_admin_count
	, RESULT_STATUS = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].result_status)
	, SOURCE = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].source)
 	, orderid = BCMA->plist[D1.SEQ].orderid
	, itemid = BCMA->plist[D1.SEQ].itemid
	, catalog_cd = BCMA->plist[D1.SEQ].catalogcd
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA->plist, 5))
 
PLAN D1
/*Non-Formulary Items
WHERE SUBSTRING(1,4, trim(SUBSTRING(1, 30, BCMA->plist[D1.SEQ].charge_number ))) != 'NCRX' ;Non Chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
;ORDER BY FACILITY, NURSE_UNIT, PERSONNEL_POSITION, PERSONNEL_NAME, MEDICATION
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
#exitscript
 
end go
 
 
 
 

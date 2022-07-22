 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Mar'2022
	Solution:			Quality
	Source file name:	      cov_phq_bcma_lfrog_detail.prg
	Object name:		cov_phq_bcma_lfrog_detail
	Request#:			12520
	Program purpose:	      BCMA & Leapfrog scorecard Detail level
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-----------------------------------------------------------------
03/28/22    Geetha   CR#12520  Initial Release
 
******************************************************************************/
 
drop program cov_phq_bcma_lfrog_detail:DBA go
create program cov_phq_bcma_lfrog_detail:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
;-----------------------------------------------------------------------
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
declare initcap() = c100
declare username = vc with protect
declare inpatient_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
declare getmonth(imonth = i4) = null
declare month_var = vc
declare sm = i2
declare em = i2
declare mcount = i2
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
RECORD meds(
	1 list[*]
		2 facility_prefix_cd = f8
		2 fin = vc
		2 pat_name = vc
		2 pat_type = vc
		2 encntrid = f8
		2 personid = f8
		2 eventid = f8
		2 med_admin_eventid = f8
		2 nurse_unit_cd = f8
		2 nurse_unit_name = vc
		2 lfrog_unit = vc
		2 event_cnt = i4
		2 positive_med_ident = i4
		2 positive_patient_ident = i4
		2 beg_dt_tm = dq8
		2 order_mnemonic = vc
		2 itemid = f8
		2 orderid = f8
		2 catalogcd = f8
		2 charge_number = vc
		2 non_bcma_med = vc
		2 met_comp = i4
		2 lp_event_cnt = i4
		2 lp_met_comp = i4
)
 
;----------------------------------------------------------
 
;Get BCMA numbers
select into 'nl:'
 
   l.facility_accn_prefix_cd, e.encntr_id, mae.event_id, mae.med_admin_event_id,  mae.nurse_unit_cd, mae.event_cnt
  , mae.positive_med_ident_ind, mae.positive_patient_ident_ind, mae.beg_dt_tm, op.item_id, rx = trim(mi.value,3)
  , met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif );scan compli
  , lp_event_cnt = evaluate2(if(e.encntr_type_cd = inpatient_var) 1 else 0 endif );encounter compliance
  , lp_met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1
  		and e.encntr_type_cd = inpatient_var)1 else 0 endif );met both compliance
 
from  location l
  	, encounter e
  	, clinical_event ce
  	, med_admin_event mae
  	, order_ingredient oi
  	, order_dispense od
  	, orders o
  	,(left join order_product op on op.order_id = o.order_id)
 	,(left join med_identifier mi on mi.item_id = op.item_id
		and mi.med_identifier_type_cd = 3096.00 ;Charge Number
		and mi.active_ind = 1)
 
 
plan l where l.facility_accn_prefix_cd in(2553225851.00,2553225859.00,2554055089.00,2554055109.00,2554055117.00,2554055131.00,2554055139.00)
	;FSR,  LCMC,  MHHS,  PWMC,  MMC,  RMC,  FLMC - all organizations/depts are included by using facility_accn_prefix_cd
 
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
  	and mae.nurse_unit_cd is not null
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
 
join oi where oi.order_id = mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join od where od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
 
join op
join mi
 
order by mae.event_id
 
Head report
 	cnt = 0
Head mae.event_id
 	cnt += 1
	call alterlist(meds->list, cnt)
Detail
 	meds->list[cnt].facility_prefix_cd = l.facility_accn_prefix_cd
 	meds->list[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
 	meds->list[cnt].nurse_unit_cd = mae.nurse_unit_cd
 	meds->list[cnt].nurse_unit_name = uar_get_code_display(mae.nurse_unit_cd)
 	meds->list[cnt].encntrid = e.encntr_id
 	meds->list[cnt].personid = e.person_id
 	meds->list[cnt].eventid = mae.event_id
 	meds->list[cnt].orderid = o.order_id
 	meds->list[cnt].catalogcd = o.catalog_cd
 	meds->list[cnt].itemid = op.item_id
 	meds->list[cnt].charge_number = trim(cnvtupper(mi.value), 3)
 	meds->list[cnt].event_cnt = mae.event_cnt
 	meds->list[cnt].med_admin_eventid = mae.med_admin_event_id
 	meds->list[cnt].beg_dt_tm =  mae.beg_dt_tm
 	meds->list[cnt].order_mnemonic = cnvtlower(o.order_mnemonic)
 	meds->list[cnt].positive_med_ident = mae.positive_med_ident_ind
 	meds->list[cnt].positive_patient_ident = mae.positive_patient_ident_ind
 	meds->list[cnt].met_comp = met_comp
 	meds->list[cnt].lp_event_cnt = lp_event_cnt
 	meds->list[cnt].lp_met_comp = lp_met_comp
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Non-BCMA meds Filter
 
select into 'nl:'
 
charge_num = trim(cv1.display, 3) ;trim(meds->list[d.seq].charge_number, 3)
, cat = meds->list[d.seq].catalogcd, item = meds->list[d.seq].itemid, drug = meds->list[d.seq].order_mnemonic
 
from	(dummyt d with seq = value(size(meds->list, 5)))
  	, code_value cv1
  	, code_value_extension cve
  	, code_value_extension cve1
 
plan cv1 where cv1.code_set = 100499
	and cv1.cdf_meaning = 'BCMA_RX'
	and cv1.active_ind = 1
 
join d where trim(meds->list[d.seq].charge_number, 3) = trim(cnvtupper(cv1.display), 3)
 
join cve where cve.code_set = cv1.code_set
	and cve.code_value = cv1.code_value
	and cve.field_name = 'Catalog_cd'
	and cnvtreal(cve.field_value) = meds->list[d.seq].catalogcd
 
join cve1 where cve1.code_set = cv1.code_set
	and cve1.code_value = cv1.code_value
	and cve1.field_name = 'Item_id'
	and cnvtreal(cve1.field_value) = meds->list[d.seq].itemid
 
order by charge_num
 
Head charge_num
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,size(meds->list,5) ,charge_num ,trim(meds->list[cnt].charge_number, 3))
	while(idx > 0)
		meds->list[idx].non_bcma_med = 'Yes'
		idx = locateval(cnt ,(idx+1) ,size(meds->list,5) ,charge_num ,trim(meds->list[cnt].charge_number, 3))
 	endwhile
 
With nocounter
 
;----------------------------------------------------------------------------------------------------------------------
;Flag LeapFrog departments
 
select into $outdev
 
 nunit = trim(substring(1,30, meds->list[d.seq].nurse_unit_name))
, cv_unit = trim(cv1.display, 3)
 
from	(dummyt d with seq = value(size(meds->list, 5)))
	,code_value cv1
 
plan d
 
join cv1 where trim(cv1.display, 3) = trim(substring(1,30, meds->list[d.seq].nurse_unit_name))
	and cv1.code_set = 100499
	and cv1.cdf_meaning = 'LEAPFROG_DEP'
	and cv1.active_ind = 1
 
order by nunit
 
Head nunit
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(meds->list,5), nunit, meds->list[cnt].nurse_unit_name)
      while(idx > 0)
		meds->list[idx].lfrog_unit = 'Yes' ;leapfrog units
 		idx = locateval(cnt,(idx+1),size(meds->list,5), nunit, meds->list[cnt].nurse_unit_name)
 	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Demographic
 
select into $outdev
 
from (dummyt d with seq = value(size(meds->list, 5)))
	,encntr_alias ea
	,person p
 
plan d
 
join ea where ea.encntr_id = meds->list[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join p where p.person_id = meds->list[d.seq].personid
	and p.active_ind = 1
 
order by ea.encntr_id
 
Head ea.encntr_id
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(meds->list,5), ea.encntr_id, meds->list[cnt].encntrid)
      while(idx > 0)
      	meds->list[idx].pat_name = p.name_full_formatted
      	meds->list[idx].fin = ea.alias
 		idx = locateval(cnt,(idx+1),size(meds->list,5), ea.encntr_id, meds->list[cnt].encntrid)
 	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
 
call echorecord(meds)
 
;----------------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = trim(uar_get_code_description(meds->list[d1.seq].facility_prefix_cd))
	;, encntrid = meds->list[d1.seq].encntrid
	, fin = substring(1, 30, meds->list[d1.seq].fin)
	, patient_name = substring(1, 50, meds->list[d1.seq].pat_name)
	, encounter_type = substring(1, 50, meds->list[d1.seq].pat_type)
	, nurse_unit = substring(1, 30, meds->list[d1.seq].nurse_unit_name)
	, lfrog_unit = substring(1, 30, meds->list[d1.seq].lfrog_unit)
	;, event_cnt = meds->list[d1.seq].event_cnt
	, med_scan = meds->list[d1.seq].positive_med_ident
	, armband_scan = meds->list[d1.seq].positive_patient_ident
	, begin_dt = format(meds->list[d1.seq].beg_dt_tm, 'mm/dd/yy hh:mm:ss;;d')
	, non_bcma_med = substring(1, 30, meds->list[d1.seq].non_bcma_med)
	, order_name = substring(1, 30, meds->list[d1.seq].order_mnemonic)
	;, met_comp = meds->list[d1.seq].met_comp ;scan compliance (med & arm)
	;, lp_event_cnt = meds->list[d1.seq].lp_event_cnt ; pat type
	;, lp_met_comp = meds->list[d1.seq].lp_met_comp ;compliance (med,arm & pat type)
	, order_id = meds->list[d1.seq].orderid
	, charge_number = substring(1, 30, meds->list[d1.seq].charge_number)
 
from
	(dummyt   d1  with seq = size(meds->list, 5))
 
plan d1
 
order by facility, fin, order_id
 
with nocounter, separator=" ", format
 
 
 
#exitscript
 
end go
 
 
/*
;Facility_accn_prefix_cd
 
select cv1.code_value, cv1.display, cv1.description
from code_value cv1
where cv1.code_set =  2062 and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
order by cv1.description
 
 
;Get Nurse unit description
select Leapfrog_unit = cv1.display, cv1.description
from code_value cv1 where cv1.code_set = 220
and cv1.cdf_meaning = 'NURSEUNIT'
and cv1.display in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'PW 2D', 'PW 3D', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S',
	'LCMC ICU', 'LCMC IMC',	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU' )
order by cv1.display
 
*/
 
;LEAPFROG_DEP
 
/*where bc->list[d.seq].nurse_unit in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC',
	'FSR 2N',	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU',
	'FSR CV SD', 'FSR ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'FSR NEURO ICU',
	'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2', 'PW CB', 'PW 2D', 'PW 3D', 'PW 5R',
	'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'MHHS 3N',
	'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC', 'LCMC OB', 'FLMC CCU', 'FLMC MSU',
	'RMC 2N', 'RMC ICU' )*/
 

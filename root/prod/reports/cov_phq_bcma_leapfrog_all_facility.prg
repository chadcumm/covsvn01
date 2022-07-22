
;**** look for gstest3 *****
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/INA/Pharmacy
	Source file name:	      cov_phq_bcma_leapfrog_all_facility.prg
	Object name:		cov_phq_bcma_leapfrog_all_facility
	Request#:			4549
	Program purpose:	      BCMA & Leapfrog Overall compliance
	Executing from:		DA2
 	Special Notes:          Aggregated data for all Facilities.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_bcma_leapfrog_all_faci:DBA go
create program cov_phq_bcma_leapfrog_all_faci:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
RECORD bcma_sum(
	1 report_ran_by = vc
	1 list[*]
		2 facility = vc
		2 fac_tot_med_given = f8
		2 fac_tot_compliance = f8
		2 nurse_unit = vc
		2 leapfrog_unit = vc
		2 unit_tot_med_given = f8
		2 unit_tot_compliance = f8
)
 
;--------------------------------------------------------
;Get user in action
select into 'nl:'
from	prsnl p
where p.person_id = reqinfo->updt_id
 
detail
	bcma_sum->report_ran_by = p.username
with nocounter
 
;--------------------------------------------------------
;Get aggregated results
select distinct into $outdev ;'nl:'
 
  year = year(sysdate), month = month(i.beg_dt_tm)
, fac = uar_get_code_description(i.loc_facility_cd)
, fac_tot_medi_given = sum(i.event_cnt) over(partition by i.loc_facility_cd, month(i.beg_dt_tm))
, fac_tot_compli = sum(cnvtint(i.met_comp)) over(partition by i.loc_facility_cd, month(i.beg_dt_tm))
 
/*, nurse_unit = uar_get_code_display(i.nurse_unit_cd)
, nu_tot_medi_given = sum(i.event_cnt) over(partition by i.nurse_unit_cd)
, nu_tot_compli = sum(i.met_comp) over(partition by i.nurse_unit_cd)
*/
 
from(
 
 (select distinct
   e.loc_facility_cd, e.encntr_id, mae.event_id, mae.nurse_unit_cd, mae.event_cnt
  , mae.positive_med_ident_ind, mae.positive_patient_ident_ind, mae.beg_dt_tm
  , met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif )
 
  from encounter e, clinical_event ce, med_admin_event mae, orders o, order_ingredient oi, order_catalog_synonym ocs
	where e.loc_facility_cd = 2552503649.00
	/*in(21250403.00, 2552503613.00, 2553765579.00, 2552503635.00, 2552503639.00,
						2552503645.00, 2552503649.00, 2552503653.00)*/
	and e.active_ind = 1
	and ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.result_status_cd in(25, 34, 35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and mae.event_id = ce.event_id
	;and mae.beg_dt_tm between cnvtdatetime("01-JAN-2019 00:00:00") and cnvtdatetime("31-JAN-2019 23:59:00")
		;and mae.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and month(mae.beg_dt_tm) = 1
		and year(mae.beg_dt_tm) = 2019
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
	and mae.nurse_unit_cd is not null
	and mae.event_cnt = 0
	and o.order_id = mae.template_order_id
	and o.active_ind = 1
	and oi.order_id =  mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
	and ocs.synonym_id = o.synonym_id
	group by  e.loc_facility_cd, e.encntr_id, mae.event_id, mae.nurse_unit_cd, mae.event_cnt
	  , mae.positive_med_ident_ind, mae.positive_patient_ident_ind, mae.beg_dt_tm
	
	With sqltype('f8','f8','f8','f8', 'f8', 'i2','i2','dq8','i2')
  )i
)
 
plan i
 
order by year, month, i.loc_facility_cd
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT;, time = 120
 
/*
 
Head report
   cnt = 0
 
Head i.name_full_formatted
 	cnt += 1
	call alterlist(bcma_sum->list, cnt)
 
Detail
	bcma_sum->list[cnt].facility = fac
	bcma_sum->list[cnt].fac_tot_med_given = fac_tot_medi_given
	bcma_sum->list[cnt].fac_tot_med_scan = fac_tot_medi_scan
	bcma_sum->list[cnt].fac_tot_wrist_scan = fac_tot_arm_scan
	bcma_sum->list[cnt].fac_tot_compliance = fac_tot_compli
	bcma_sum->list[cnt].nurse_unit = trim(nurse_unit)
	bcma_sum->list[cnt].unit_tot_med_given = nu_tot_medi_given
	bcma_sum->list[cnt].unit_tot_med_scan = nu_tot_medi_scan
	bcma_sum->list[cnt].unit_tot_wrist_scan = nu_tot_arm_scan
	bcma_sum->list[cnt].unit_tot_compliance = nu_tot_compli
	bcma_sum->list[cnt].prsnl_name = prsnl_name
	bcma_sum->list[cnt].prsnl_role = role
	bcma_sum->list[cnt].pr_tot_med_given = pr_tot_medi_given
	bcma_sum->list[cnt].pr_tot_med_scan = pr_tot_medi_scan
	bcma_sum->list[cnt].pr_tot_wrist_scan = pr_tot_arm_scan
	bcma_sum->list[cnt].pr_tot_compliance = pr_tot_compli
 
Foot i.name_full_formatted
 	call alterlist(bcma_sum->list, cnt)
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Flag LeapFrog departments/units
 
select distinct into 'nl:'
 
 nunit = bcma_sum->list[d.seq].nurse_unit
 ,prsnl = bcma_sum->list[d.seq].prsnl_name
 
from	(dummyt d  with seq = size(bcma_sum->list, 5))
 
plan d where bcma_sum->list[d.seq].nurse_unit in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU' )
 
order by nunit, prsnl
 
Head nunit
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bcma_sum->list,5), nunit, bcma_sum->list[cnt].nurse_unit)
	while(idx > 0)
		bcma_sum->list[idx].leapfrog_unit = 'Y' ;flag indicating leapfrog unit
		bcma_sum->list[idx].nurse_unit = build2(bcma_sum->list[idx].nurse_unit, '*') ;leapfrog units
		idx = locateval(cnt,(idx+1) ,size(bcma_sum->list,5) ,nunit ,bcma_sum->list[cnt].nurse_unit)
	endwhile
 
with nocounter
 
call echorecord(bcma_sum)
 
 
;-----------temp-----------------------------------------------------------
/*
SELECT into $outdev
 
	LIST_FACILITY = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].facility)
	, LIST_FAC_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].fac_tot_med_given
	, LIST_FAC_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_med_scan
	, LIST_FAC_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_wrist_scan
	, LIST_FAC_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].fac_tot_compliance
	, LIST_NURSE_UNIT = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].nurse_unit)
	, LIST_LEAPFROG_UNIT = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].leapfrog_unit)
	, LIST_UNIT_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].unit_tot_med_given
	, LIST_UNIT_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].unit_tot_med_scan
	, LIST_UNIT_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].unit_tot_wrist_scan
	, LIST_UNIT_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].unit_tot_compliance
	, LIST_PRSNL_NAME = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_name)
	, LIST_PRSNL_ROLE = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_role)
	, LIST_PR_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].pr_tot_med_given
	, LIST_PR_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_med_scan
	, LIST_PR_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_wrist_scan
	, LIST_PR_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].pr_tot_compliance
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA_SUM->list, 5))
 
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
;----------------------------------------------------------------------------
*/
 
end go
 
 
 
 
 
/*
LeapFrog Departments for compliance
 
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU'
*/

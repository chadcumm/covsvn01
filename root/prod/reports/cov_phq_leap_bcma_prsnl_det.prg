 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/INA/Pharmacy
	Source file name:	      cov_phq_leap_bcma_prsnl_det.prg
	Object name:		cov_phq_leap_bcma_prsnl_det
	Request#:			3546
	Program purpose:	      BCMA & Leapfrog compliance details on Nurse unit and Personnel level
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_leap_bcma_prsnl_det:DBA go
create program cov_phq_leap_bcma_prsnl_det:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Nurse Unit" = 0
 
with OUTDEV, acute_facility_list, start_datetime, end_datetime, nurse_unit
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
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
		2 facility = vc
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
		2 nurse_unit = vc
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
 
;--------------------------------------------------------
;Get user in action
select into "NL:"
from	prsnl p
where p.person_id = reqinfo->updt_id
 
detail
	bcma_sum->report_ran_by = p.username
with nocounter
 
;--------------------------------------------------------
;Get aggregated results
select into 'nl:'
 
 ;IF(LIST_LEAPFROG_UNIT = 'Y') cnvtint(LIST_LP_UNIT_TOT_MED_GIVEN) else cnvtint(LIST_UNIT_TOT_MED_GIVEN) endif
 ; Use this in layout builder if you want to display value for Leapfrog unit
 
  fac = uar_get_code_description(i.loc_facility_cd)
, fac_tot_medi_given = sum(i.event_cnt) over()
, fac_tot_medi_scan = sum(i.positive_med_ident_ind) over()
, fac_tot_arm_scan = sum(i.positive_patient_ident_ind) over()
, fac_tot_compli = sum(cnvtint(i.met_comp)) over()
 
, nurse_unit = uar_get_code_display(i.nurse_unit_cd)
, nu_tot_medi_given = sum(i.event_cnt) over(partition by i.nurse_unit_cd)
, nu_tot_medi_scan = sum(i.positive_med_ident_ind) over(partition by i.nurse_unit_cd)
, nu_tot_arm_scan = sum(i.positive_patient_ident_ind) over(partition by i.nurse_unit_cd)
, nu_tot_compli = sum(i.met_comp) over(partition by i.nurse_unit_cd)
, lp_nu_tot_med_given = sum(i.lp_event_cnt) over(partition by i.nurse_unit_cd)
, lp_nu_tot_compliance = sum(i.lp_met_comp) over(partition by i.nurse_unit_cd)
 
, prsnl_name = initcap(i.name_full_formatted)
, role = uar_get_code_display(i.position_cd)
, pr_tot_medi_given = sum(i.event_cnt) over(partition by i.nurse_unit_cd, i.name_full_formatted)
, pr_tot_medi_scan = sum(i.positive_med_ident_ind) over(partition by i.nurse_unit_cd, i.name_full_formatted)
, pr_tot_arm_scan = sum(i.positive_patient_ident_ind) over(partition by i.nurse_unit_cd, i.name_full_formatted)
, pr_tot_compli = sum(i.met_comp) over(partition by i.nurse_unit_cd, i.name_full_formatted)
, lp_pr_tot_medi_given = sum(i.lp_event_cnt) over(partition by i.nurse_unit_cd, i.name_full_formatted)
, lp_pr_tot_compli = sum(i.lp_met_comp) over(partition by i.nurse_unit_cd, i.name_full_formatted)
 
from(
 
 (select distinct
   e.loc_facility_cd, e.encntr_id, mae.event_id, mae.med_admin_event_id,  mae.nurse_unit_cd, mae.event_cnt
  , mae.positive_med_ident_ind, mae.positive_patient_ident_ind
  , pr.name_full_formatted, pr.position_cd
  ;, lp_positive_med_ident = evaluate2( if(mae.positive_med_ident_ind = 1 and e.encntr_type_cd = inpatient_var)1 else 0 endif )
  ;, lp_positive_pat_ident = evaluate2( if(mae.positive_patient_ident_ind = 1	and e.encntr_type_cd = inpatient_var)1 else 0 endif )
 
  , lp_event_cnt = evaluate2(if(e.encntr_type_cd = inpatient_var) 1 else 0 endif )
  , met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif )
  , lp_met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1
  					and e.encntr_type_cd = inpatient_var)1 else 0 endif )
 
  from encounter e, clinical_event ce, med_admin_event mae, orders o, order_ingredient oi, order_catalog_synonym ocs, prsnl pr
	where e.loc_facility_cd = $acute_facility_list
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
	and ocs.synonym_id = o.synonym_id
	and pr.person_id = mae.prsnl_id
 
	with sqltype('f8','f8','f8','f8','f8','f8', 'i2','i2','vc','f8','i2','i2','i2')
  )i
)
 
plan i
 
order by i.loc_facility_cd, nurse_unit, i.name_full_formatted
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120
 
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
	bcma_sum->list[cnt].nurse_unit = nurse_unit
	bcma_sum->list[cnt].unit_tot_med_given = nu_tot_medi_given
	bcma_sum->list[cnt].unit_tot_med_scan = nu_tot_medi_scan
	bcma_sum->list[cnt].unit_tot_wrist_scan = nu_tot_arm_scan
	bcma_sum->list[cnt].unit_tot_compliance = nu_tot_compli
	bcma_sum->list[cnt].lp_unit_tot_med_given = lp_nu_tot_med_given
	bcma_sum->list[cnt].lp_unit_tot_compliance = lp_nu_tot_compliance
	bcma_sum->list[cnt].lp_pr_tot_med_given = lp_pr_tot_medi_given
	bcma_sum->list[cnt].lp_pr_tot_compliance = lp_pr_tot_compli
	bcma_sum->list[cnt].prsnl_name = prsnl_name
	bcma_sum->list[cnt].prsnl_role = role
	bcma_sum->list[cnt].pr_tot_med_given = pr_tot_medi_given
	bcma_sum->list[cnt].pr_tot_med_scan = pr_tot_medi_scan
	bcma_sum->list[cnt].pr_tot_wrist_scan = pr_tot_arm_scan
	bcma_sum->list[cnt].pr_tot_compliance = pr_tot_compli
 
Foot i.name_full_formatted
 	call alterlist(bcma_sum->list, cnt)
 
with nocounter
 
call echorecord(bcma_sum)
 
;------------------------------------------------------------------------------------------------------------
;Flag LeapFrog departments/units
 
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
 
DiscernAnalyticsUtil.cond(row["Nurse Unit"] === 'MMC 2W'  || row["Nurse Unit"] === 'MMC 3E'  || row["Nurse Unit"] === 'MMC 3W' || row["Nurse Unit"] === 'MMC 4W' || row["Nurse Unit"] === 'MMC 5W' || row["Nurse Unit"] === 'MMC Stepdown' ||
	row["Nurse Unit"] === 'MMC CCU' || row["Nurse Unit"] === 'MMC CVU' ||	row["Nurse Unit"] === 'MMC ICU' || row["Nurse Unit"] === 'MMC FBC'  ||
	row["Nurse Unit"] === 'FSR 2N'  || row["Nurse Unit"] === 'FSR 3N'  || row["Nurse Unit"] === 'FSR 3W'  || row["Nurse Unit"] === 'FSR 4E'  || row["Nurse Unit"] === 'FSR 4W'  || 	row["Nurse Unit"] === 'FSR 5N'  || 	row["Nurse Unit"] === 'FSR 5W'  ||
	row["Nurse Unit"] === 'FSR 6E'  || row["Nurse Unit"] === 'FSR 6N'  || 	row["Nurse Unit"] === 'FSR 6W'  || 	row["Nurse Unit"] === 'FSR 7N'  || 	row["Nurse Unit"] === 'FSR 8N'  || 	row["Nurse Unit"] === 'FSR 9N'  || row["Nurse Unit"] === 'FSR CV ICU'  ||
	row["Nurse Unit"] === 'FSR CV SD'  || 	row["Nurse Unit"] === 'FSR  ICU'  || 	row["Nurse Unit"] === 'FSR IMC'  || 	row["Nurse Unit"] === 'FSR NEURO'  || row["Nurse Unit"] === 'FSR LD' ||
	row["Nurse Unit"] === 'PW 1G'  || row["Nurse Unit"] === 'PW 2M' || row["Nurse Unit"] === 'PW 3C'  || row["Nurse Unit"] === 'PW 3M' || row["Nurse Unit"] === 'PW 3R'  || row["Nurse Unit"] === 'PW 4M' ||
	row["Nurse Unit"] === 'PW 4R' || 	row["Nurse Unit"] === 'PW C1' || 	row["Nurse Unit"] === 'PW C2' || 	row["Nurse Unit"] === 'PW CB' ||
	row["Nurse Unit"] === 'MHHS 2S' || row["Nurse Unit"] === 'MHHS 3G' || row["Nurse Unit"] === 'MHHS 3S' || row["Nurse Unit"] === 'MHHS 4S' || 	row["Nurse Unit"] === 'MHHS CCU' || row["Nurse Unit"] === 'MHHS IMC' || row["Nurse Unit"] === 'MHHS LD' ||
	row["Nurse Unit"] === 'LCMC 3M' || row["Nurse Unit"] === 'LCMC 3S' || 	row["Nurse Unit"] === 'LCMC ICU' || row["Nurse Unit"] === 'LCMC IMC' || row["Nurse Unit"] === 'LCMC OB' ||
	row["Nurse Unit"] === 'FLMC CCU' || row["Nurse Unit"] === 'FLMC MSU' ||
	row["Nurse Unit"] === 'RMC 2N' || row["Nurse Unit"] === 'RMC ICU'   ,
	(Math.min(row["Gr Meds Scanned"], row["Gr Tot Wristband Scanned"]) / row["Gr Total Meds Given"]) ,  0)
 
*/

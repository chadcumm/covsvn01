 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/INA/Pharmacy
	Source file name:	      cov_phq_BCMA_leapfrog_overall.prg
	Object name:		cov_phq_BCMA_leapfrog_overall
	Request#:			3884
	Program purpose:	      BCMA - Both Leapfrog and Overall compliance
	Executing from:		DA2
 	Special Notes:          By Facility and Nurse unit.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_BCMA_leapfrog_overall:DBA go
create program cov_phq_BCMA_leapfrog_overall:DBA
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Year" = 0
	, "Month" = 0
 
with OUTDEV, acute_facility_list, year_prmt, month
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
declare newborn_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Newborn")), protect
declare observation_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Observation")), protect
declare inpatient_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
declare month_var = vc with noconstant('')
 
case ($month)
	of 1  : set month_var = 'January'
	of 2  : set month_var = 'February'
	of 3  : set month_var = 'March'
	of 4  : set month_var = 'April'
	of 5  : set month_var = 'May'
	of 6  : set month_var = 'June'
 	of 7  : set month_var = 'July'
	of 8  : set month_var = 'August'
	of 9  : set month_var = 'September'
	of 10 : set month_var = 'October'
	of 11 : set month_var = 'November'
	of 12 : set month_var = 'December'
endcase
 
;------------------------------------------------------------------------------------
 
RECORD bcma(
	1 bcma_rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 nurse_unit_cd = f8
		2 nurse_unit = vc
		2 pat_type_flag = vc
		2 encounter_id = f8
		2 eventid = f8
		2 med_admin_eventid = f8
		2 med_scan = vc
		2 armband_scan = vc
		2 leapfrog_flag = vc
		2 med_admin_cnt = i4
		2 med_admin_dt = vc
)
 
RECORD bcma_tot(
	1 tot_rec_cnt = i4
	1 month_selected = vc
	1 year_selected = i4
	1 facility = vc
	1 fac_tot_admin = f8
	1 fac_tot_comp_admin = f8
	1 fac_tot_leap_admin = f8
	1 fac_tot_leap_comp_admin = f8
	1 unit[*]
		2 nurse_unit = vc
		2 nu_tot_admin = f8
		2 nu_tot_comp_admin = f8
		2 leapfrog_unit = vc
		2 lp_nu_tot_admin = f8
		2 lp_nu_tot_comp_admin = f8
 
	)
 
;------------------------------------------------------------------------------------
 
select into 'nl:'
 
  e.encntr_id, e.loc_facility_cd, mae.nurse_unit_cd
  , pat_type = if(e.encntr_type_cd != inpatient_var) 'NB' else ' ' endif
  , Nurse_unit = uar_get_code_display(mae.nurse_unit_cd)
  , medication_scanned = if(mae.positive_med_ident_ind = 1) 'Y' else 'N' endif
  , wristband_scanned = if(mae.positive_patient_ident_ind = 1) 'Y' else 'N' endif
  , med_admin_count = mae.event_cnt
  , admin_dt = format(mae.beg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
FROM
	 encounter e
 	, clinical_event ce
	, med_admin_event mae
	, orders o
	, order_ingredient oi
	, order_catalog_synonym ocs
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.result_status_cd in(25, 34, 35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 
join mae where mae.event_id = ce.event_id
	and month(mae.beg_dt_tm) = $month
	and year(mae.beg_dt_tm) = $year_prmt
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
  	and mae.nurse_unit_cd is not null
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
 
join oi where oi.order_id =  mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join ocs where ocs.synonym_id = o.synonym_id
 
order by e.loc_facility_cd, mae.nurse_unit_cd, e.encntr_id, mae.event_id, mae.med_admin_event_id
 
Head report
 	cnt = 0
	call alterlist(bcma->plist, 100)
 
Head mae.med_admin_event_id
 	cnt += 1
 	bcma->bcma_rec_cnt = cnt
	call alterlist(bcma->plist, cnt)
Detail
 	bcma->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
 	bcma->plist[cnt].nurse_unit_cd = mae.nurse_unit_cd
 	bcma->plist[cnt].nurse_unit = uar_get_code_display(mae.nurse_unit_cd)
 	bcma->plist[cnt].pat_type_flag = pat_type
 	bcma->plist[cnt].encounter_id = e.encntr_id
 	bcma->plist[cnt].eventid = mae.event_id
 	bcma->plist[cnt].med_admin_eventid = mae.med_admin_event_id
 	bcma->plist[cnt].med_admin_dt = admin_dt
 	bcma->plist[cnt].med_admin_cnt = mae.event_cnt
 	bcma->plist[cnt].med_scan = medication_scanned
 	bcma->plist[cnt].armband_scan = wristband_scanned
 
Foot ce.event_id
	call alterlist(bcma->plist, cnt)
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------------
;Flag LeapFrog department's admins
 
select into 'nl:'
 
 nunit = bcma->plist[d.seq].nurse_unit
,encntrid = bcma->plist[d.seq].encounter_id
,med_admin_id = bcma->plist[d.seq].med_admin_eventid
 
from	(dummyt d  with seq = size(bcma->plist, 5))
 
plan d where bcma->plist[d.seq].nurse_unit in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU' )
 
order by nunit, encntrid, med_admin_id
 
Head med_admin_id
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bcma->plist,5), med_admin_id, bcma->plist[cnt].med_admin_eventid)
	bcma->plist[idx].leapfrog_flag = 'Y' ;event belongs to leapfrog dept/nurse unit
	bcma->plist[idx].nurse_unit = build2(bcma->plist[idx].nurse_unit, ' *') ;leapfrog units
 
Foot med_admin_id
	null
 
with nocounter
 
;call echorecord(bcma)
 
;----------------------------------------------------------------------------------------------------------------------
 
SELECT into 'nl:'
 
	FACILITY = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].facility)
	, NURSE_UNIT_CD = BCMA->plist[D1.SEQ].nurse_unit_cd
	, NURS_UNIT = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].nurse_unit)
	, PAT_TYPE = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].pat_type_flag)
	, ENCNTRID = BCMA->plist[D1.SEQ].encounter_id
	, MED_EVENT_ID = BCMA->plist[D1.SEQ].med_admin_eventid
	, MED_SCAN = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].med_scan)
	, ARMBAND_SCAN = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].armband_scan)
	, LEAPFROG_FLAG = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].leapfrog_flag)
	, MED_ADMIN_CNT = BCMA->plist[D1.SEQ].med_admin_cnt
	, MED_ADMIN_DT = SUBSTRING(1, 30, BCMA->plist[D1.SEQ].med_admin_dt)
 
FROM	(DUMMYT   D1  WITH SEQ = SIZE(BCMA->plist, 5))
 
PLAN D1
 
ORDER BY FACILITY, NURS_UNIT, ENCNTRID, MED_EVENT_ID
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120
 
 
Head report
	num = 0
	ncnt = 0
 	bcma_tot-> month_selected = month_var
 	bcma_tot->year_selected = $year_prmt
Head facility
	itr = 0
	num += 1
	fac_tot_admins = 0
	bcma_tot->facility = facility
 
Head nurs_unit
	ntr = 0
	ncnt = ncnt + 1
	nu_tot_admins = 0
	lp_nu_tot_admins = 0
	call alterlist(bcma_tot->unit, 100)
 
Head med_event_id
	itr = 0
	nu_tot_admins += med_admin_cnt
	if(pat_type = ' ')
		lp_nu_tot_admins += med_admin_cnt
	endif
	fac_tot_admins += med_admin_cnt
Detail
 	itr += 1
 
Foot nurs_unit
	bcma_tot->unit[ncnt].nurse_unit = nurs_unit
	bcma_tot->unit[ncnt].nu_tot_admin = nu_tot_admins
	bcma_tot->unit[ncnt].lp_nu_tot_admin = lp_nu_tot_admins
 
	if(leapfrog_flag = 'Y')
		bcma_tot->unit[ncnt].leapfrog_unit = 'Y'
	endif
 
 	bcma_tot->unit[ncnt].nu_tot_comp_admin = sum(med_admin_cnt where med_scan = 'Y' and armband_scan = 'Y')
 	bcma_tot->unit[ncnt].lp_nu_tot_comp_admin = sum(med_admin_cnt where med_scan = 'Y' and armband_scan = 'Y' and pat_type = ' ')
 	call alterlist(bcma_tot->unit, ncnt)
 
Foot facility
	bcma_tot->fac_tot_admin = fac_tot_admins
	bcma_tot->fac_tot_comp_admin = sum(med_admin_cnt where med_scan = 'Y' and armband_scan = 'Y')
	bcma_tot->fac_tot_leap_admin = count(med_admin_cnt where leapfrog_flag = 'Y' and pat_type = ' ' )
	bcma_tot->fac_tot_leap_comp_admin = count(med_admin_cnt where leapfrog_flag = 'Y' and pat_type = ' '
											 and med_scan = 'Y' and armband_scan = 'Y')
 
with nocounter
 
call echorecord(bcma_tot)
 
 
end
go
 
 
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

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Saravanan
	Date Written:		March, 2018
	Solution:			Pharmacy
	Source file name:	      cov_pha_Productivity_Extract.prg
	Object name:		cov_pha_Productivity_Extract
 
	Request#:			998
	Program purpose:	      Daily Productivity data extract by facility for all facilities.
 
	Executing from:		DA2 or Operational schedular
 
 	Special Notes:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_extract_peninsulaFix:dba go
create program cov_pha_extract_peninsulaFix:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare pharmacy_var  = f8 with constant(uar_get_code_BY("DISPLAY", 106, "Pharmacy")), protect
declare ord_stat_var  = f8 with constant(uar_get_code_BY("DISPLAY", 6004, "Completed")), protect
declare faci          = vc
declare output_orders = vc
;declare filename_var  = vc with constant('cer_temp:covhlth_pr_rx_stats.txt'), protect
 
;To create file on all nodes
declare filename_var = vc with constant(build("/cerner/w_custom/p0665_cust/code/script/", "CovHlth_PR_Rx_Stats.txt")), protect
 
;To create file with current date
;declare filename_var  = vc with constant(build('cer_temp:CovHlth_PR_Rx_Stats_',FORMAT(CURDATE,'YYYYMMDD;;Q'),'.txt')), PROTECT
 
/*
;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("1,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)
*/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record orders(
	1 ord_cnt               = i4
	1 list[*]
		2 facility        = f8
		2 company         = vc
		2 department      = vc
		2 activity_code   = vc
		2 date_of_service = vc
		2 weight          = vc
		2 ip_value        = i4
		2 op_value        = i4
		2 total_value     = i4
)
 
 
select distinct into 'NL:'
 
 i.loc_facility_cd, i.ipop
 , service_date = format(i.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
 ;, service_trunc_format = format(datetimetrunc(i.order_dt_tm, 'DD'), ';;q')
 , service_trunc = datetimetrunc(i.order_dt_tm, 'DD')
 , ordr_cnt = count(i.order_id)over(partition by i.loc_facility_cd, i.ipop, datetimetrunc(i.order_dt_tm, 'DD'))
 
from
 
(
    (select distinct e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_id, o.order_id, o.order_mnemonic
    		 , oa.order_dt_tm, ipop = evaluate2(if(e.encntr_type_class_cd = 391.00)'I' else 'O' endif)
 
 	from orders o, order_action oa, encounter e, code_value cv, prsnl p;, code_value cvpcd;, charge c, charge_mod cm
 
 	where o.activity_type_cd = 705 ;pharmacy_var
		and o.active_ind = 1
		;and o.order_status_cd in(2543,2546,2547,2548,2550)
		and o.order_status_cd in(2543, 2550);completed, ordered    ;,2550,2543,2546,2547,2548)
		;and c.encntr_id = o.encntr_id
		;and c.order_id = o.order_id
		and oa.order_id = o.order_id
		and oa.needs_verify_ind in(0,3);no verify needed, verified
		and (oa.order_dt_tm between cnvtdatetime("20-AUG-2018 00:00:00") and cnvtdatetime("30-AUG-2018 23:59:00"))
		and e.encntr_id = o.encntr_id
		and cv.code_value = e.loc_facility_cd
		and cv.code_set = 220
		and cv.cdf_meaning = "FACILITY"
		;and cm.charge_item_id = c.charge_item_id
		;and cm.field1_id in(3691) ;CDM
		and e.encntr_type_class_cd in(391.00, 392.00, 393.00, 389.00)
		and e.active_ind = 1
		and p.person_id = oa.action_personnel_id
		and oa.action_personnel_id != 1
		and p.username not in('IS Analyst', 'ISANALYST', 'SUPERUSER', 'ADT', 'AUTO')
		;and (cvpcd.code_value = p.position_cd and cvpcd.code_set = 88 and cvpcd.cdf_meaning = "RPH");Pharmacist only
 
  		and( (e.loc_facility_cd = 21250403.00 and o.order_mnemonic not in( ;Fort Sanders - FSR
 			'THERAPEUTIC MONITORING   EA',
			'DC THE PREOP ORDERS  1 EA',
			'OPEN HEART TRAY  1 EA',
			'VEIN SPARING  1 ML',
			'PRECISION STRIP HOLDER  1 EA',
			'EAR TRAY CHARGE  1 EA',
			'EYE TRAY CHARGE  1 EA',
			'DC THE L&D ORDERS  1 EA',
			'DC MS-NIPRIDE-DEMEROL-DOPAMINE  1 EA',
			'ANTICOAGULANT CLINIC CHG LMT  1 EA',
			'ANTICOAGULANT CLINIC CHG EXT  1 EA',
			'DISCHARGE TODAY ??  1 EA',
			'NOSE TRAY CHARGE  1 EA',
			'DISCHARGE TODAY ?  1 EA',
			'ALBUMIN REORDER  1 EA',
			'PCA PUMP RENTAL DAILY  1 EA',
			'COUMADIN MAOI EDUCATION MAR  1 EA',
			'PHARMACOKINETIC MONITORING  1 EA',
			'MYELOGRAM TRAY  1 EA',
			'HUMULIN N INSULIN PER UNIT 1 UNIT 1 EA',
			'VANCO PULSE DOSING  1 EA',
			'DRESSING CHANGE  1 EA',
			'PREMIX IV DRIP  1 EA',
			'PROLASTIN MIXING FEE  1 EA',
			'ANTICOAG CLINIC MONITORING  1 EA',
			'INR VERIFICATION  1 EA',
			'1 EA',
			'IVIG ADMINISTRATIVE N/A  EA',
			'REMOVE PATCH   1 EA',
			'CHECK PATIENT PATCH Q-SHIFT  1 EA',
			'1 EA',
			'PEAK - VANCOMYCIN  1 EA',
			'TROUGH - VANCOMYCIN  1 EA',
			'PHARMACY CONSULT FOR DISCHARGE  1 EA',
			'TROUGH-GENTAMICIN  1 EA',
			'PEAK-GENTAMICIN  1 EA',
			'PEAK-TOBRAMYCIN  1 EA',
			'TROUGH-TOBRAMYCIN  1 EA',
			'PEAK-AMIKACIN  1 EA',
			'TROUGH-AMIKACIN  1 EA',
			'RANDOM - VANCOMYCIN  1 EA',
			'LEVEL - ANTI XA  1 EA',
			'BISPHOSPHONATE MESSAGE  1 EA',
			'FLU VACCINE UNAVAILABLE  1 EA',
			'TOBRAMYCIN RANDOM  1 EA',
			'LOVENOX TEACHING 1 EA 1 EA',
			'RX TO SEND ANTICOAG EDUCATION  1 EA',
			'AMIKACIN RANDOM  1 EA',
			'GENTAMICIN RANDOM  1 EA',
			'ALTERNATIVE MEDICATION MESSAGE  1 EA',
			'BOWEL PREP OPTION 1  1 EA',
			'BOWEL PREP OPTION 2  1 EA',
			'1 EA',
			'CONDITIONAL ORDER  1 EA',
			'SUSPEND ORDER  1 EA',
			'PHARMACY COMMUNICATION  1 EA',
			'ENSURE PAIN REASSESSED MISC 1 EA',
			'DOCUMENT DIABETIC VIDEO EDUCATION  1 EA',
			'PATIENT HOME MEDS IN PHARMACY  1 EA',
			'EYE TRAY EMERGENCY ROOM  1 EA',
			'ASSESSMENT ORDER  1 EA',
			'CT W/CONTRAST ORDERED  1 EA',
			'DOCUMENT ATIVAN AMT GIVEN',
			'DOCUMENT FENTANYL AMT GIVEN',
			'DOCUMENT MORPHINE AMT GIVEN',
			'DOCUMENT PROPOFOL AMT GIVEN',
			'DOCUMENT VERSED AMT GIVEN',
			'NARCOTIC CHARTING  1 EA') )
 
 		 or (e.loc_facility_cd = 2553765579.00 and o.order_mnemonic not in( ;Peninsula - G
		 	'THERAPEUTIC MONITORING   EA',
			'DC THE PREOP ORDERS  1 EA',
			'OPEN HEART TRAY  1 EA',
			'VEIN SPARING  1 ML',
			'PRECISION STRIP HOLDER  1 EA',
			'COUMADIN DOSE TODAY ?  1 EA',
			'EAR TRAY CHARGE  1 EA',
			'EYE TRAY CHARGE  1 EA',
			'DC THE L&D ORDERS  1 EA',
			'DC MS-NIPRIDE-DEMEROL-DOPAMINE  1 EA',
			'ANTICOAGULANT CLINIC CHG LMT  1 EA',
			'ANTICOAGULANT CLINIC CHG EXT  1 EA',
			'DISCHARGE TODAY ??  1 EA',
			'NOSE TRAY CHARGE  1 EA',
			'DISCHARGE TODAY ?  1 EA',
			'ALBUMIN REORDER  1 EA',
			'PCA PUMP RENTAL DAILY  1 EA',
			'COUMADIN MAOI EDUCATION MAR  1 EA',
			'PHARMACOKINETIC MONITORING  1 EA',
			'MYELOGRAM TRAY  1 EA',
			'HUMULIN N INSULIN PER UNIT 1 UNIT 1 EA',
			'VANCO PULSE DOSING  1 EA',
			'DRESSING CHANGE  1 EA',
			'PROLASTIN MIXING FEE  1 EA',
			'ANTICOAG CLINIC MONITORING  1 EA',
			'INR VERIFICATION  1 EA',
			'NITRATE FREE INTERVAL  1 EA',
			'IVIG ADMINISTRATIVE N/A  EA',
			'1 EA',
			'REMOVE PATCH   1 EA',
			'CHECK PATIENT PATCH Q-SHIFT  1 EA',
			'1 EA',
			'FLU VACCINE UNAVAILABLE  1 EA',
			'TOBRAMYCIN RANDOM  1 EA',
			'LOVENOX TEACHING 1 EA 1 EA',
			'RX TO SEND ANTICOAG EDUCATION  1 EA',
			'TROUGH-GENTAMICIN  1 EA',
			'AMIKACIN RANDOM  1 EA',
			'GENTAMICIN RANDOM  1 EA',
			'TROUGH-AMIKACIN  1 EA',
			'TROUGH-TOBRAMYCIN  1 EA',
			'ALTERNATIVE MEDICATION MESSAGE  1 EA',
			'GRANT PATIENT  1 EA',
			'BOWEL PREP OPTION 1  1 EA',
			'BOWEL PREP OPTION 2  1 EA',
			'1 EA',
			'CONDITIONAL ORDER  1 EA',
			'SUSPEND ORDER  1 EA',
			'PHARMACY COMMUNICATION  1 EA',
			'ENSURE PAIN REASSESSED MISC 1 EA',
			'DOCUMENT DIABETIC VIDEO EDUCATION  1 EA',
			'PATIENT HOME MEDS IN PHARMACY  1 EA',
			'EYE TRAY EMERGENCY ROOM  1 EA',
			'ASSESSMENT ORDER  1 EA',
			'NARCOTIC CHARTING  1 EA') )
 
		 or (e.loc_facility_cd = 2552503635.00 and o.order_mnemonic not in( ;Loudoun - FLMC
		 	'THERAPEUTIC MONITORING   EA',
			'DC THE PREOP ORDERS  1 EA',
			'OPEN HEART TRAY  1 EA',
			'VEIN SPARING  1 ML',
			'PRECISION STRIP HOLDER  1 EA',
			'EAR TRAY CHARGE  1 EA',
			'EYE TRAY CHARGE  1 EA',
			'DC THE L&D ORDERS  1 EA',
			'DC MS-NIPRIDE-DEMEROL-DOPAMINE  1 EA',
			'COUMADIN PHARMACY PROTOCOL  1 EA',
			'ANTICOAGULANT CLINIC CHG LMT  1 EA',
			'ANTICOAGULANT CLINIC CHG EXT  1 EA',
			'DISCHARGE TODAY ??  1 EA',
			'NOSE TRAY CHARGE  1 EA',
			'DISCHARGE TODAY ?  1 EA',
			'ALBUMIN REORDER  1 EA',
			'PCA PUMP RENTAL DAILY  1 EA',
			'COUMADIN MAOI EDUCATION MAR  1 EA',
			'PHARMACOKINETIC MONITORING  1 EA',
			'MYELOGRAM TRAY  1 EA',
			'HUMULIN N INSULIN PER UNIT 1 UNIT 1 EA',
			'VANCO PULSE DOSING  1 EA',
			'DRESSING CHANGE  1 EA',
			'PROLASTIN MIXING FEE  1 EA',
			'ANTICOAG CLINIC MONITORING  1 EA',
			'INR VERIFICATION  1 EA',
			'1 EA',
			'IVIG ADMINISTRATIVE N/A  EA',
			'REMOVE PATCH   1 EA',
			'CHECK PATIENT PATCH Q-SHIFT  1 EA',
			'1 EA',
			'START INSULIN DRIP  1 EA',
			'TRANSITION INSULIN  1 EA',
			'FLU VACCINE UNAVAILABLE  1 EA',
			'INSULIN MANAGEMENT MESSAGE  1 EA',
			'PEAK - VANCOMYCIN  1 EA',
			'TROUGH - VANCOMYCIN  1 EA',
			'RANDOM - VANCOMYCIN  1 EA',
			'PEAK-GENTAMICIN  1 EA',
			'TROUGH-GENTAMICIN  1 EA',
			'PEAK-TOBRAMYCIN  1 EA',
			'NO NSAID EXCEPT ASPIRIN  1 EA',
			'COMPLETE HEART FAILURE EDU  1 EA',
			'VCA PATIENT EDUCATION  1 EA',
			'PATIENT VTE ASSESS  1 EA',
			'COPD EDUCATION  1 EA',
			'TOBRAMYCIN RANDOM  1 EA',
			'LOVENOX TEACHING 1 EA 1 EA',
			'RX TO SEND ANTICOAG EDUCATION  1 EA',
			'PEAK-AMIKACIN  1 EA',
			'AMIKACIN RANDOM  1 EA',
			'GENTAMICIN RANDOM  1 EA',
			'TROUGH-AMIKACIN  1 EA',
			'TROUGH-TOBRAMYCIN  1 EA',
			'ALTERNATIVE MEDICATION MESSAGE  1 EA',
			'KEY  1 EA',
			'BOWEL PREP OPTION 1  1 EA',
			'BOWEL PREP OPTION 2  1 EA',
			'1 EA',
			'CONDITIONAL ORDER  1 EA',
			'SUSPEND ORDER  1 EA',
			'PHARMACY COMMUNICATION  1 EA',
			'ENSURE PAIN REASSESSED MISC 1 EA',
			'DOCUMENT DIABETIC VIDEO EDUCATION  1 EA',
			'PATIENT HOME MEDS IN PHARMACY  1 EA',
			'EYE TRAY EMERGENCY ROOM  1 EA',
			'ASSESSMENT ORDER  1 EA',
			'CT W/CONTRAST ORDERED  1 EA',
			'NARCOTIC CHARTING  1 EA') )
 
 		or (e.loc_facility_cd = 2552503639.00 and o.order_mnemonic not in( ;Morriston Hamblen - MHHS
			'THERAPEUTIC MONITORING   EA',
			'DC THE PREOP ORDERS  1 EA',
			'OPEN HEART TRAY  1 EA',
			'VEIN SPARING  1 ML',
			'PRECISION STRIP HOLDER  1 EA',
			'EAR TRAY CHARGE  1 EA',
			'EYE TRAY CHARGE  1 EA',
			'DC THE L&D ORDERS  1 EA',
			'DC MS-NIPRIDE-DEMEROL-DOPAMINE  1 EA',
			'ANTICOAGULANT CLINIC CHG LMT  1 EA',
			'ANTICOAGULANT CLINIC CHG EXT  1 EA',
			'DISCHARGE TODAY ??  1 EA',
			'NOSE TRAY CHARGE  1 EA',
			'DISCHARGE TODAY ?  1 EA',
			'ALBUMIN REORDER  1 EA',
			'PCA PUMP RENTAL DAILY  1 EA',
			'COUMADIN MAOI EDUCATION MAR  1 EA',
			'PHARMACOKINETIC MONITORING  1 EA',
			'MYELOGRAM TRAY  1 EA',
			'HUMULIN N INSULIN PER UNIT 1 UNIT 1 EA',
			'VANCO PULSE DOSING  1 EA',
			'DRESSING CHANGE  1 EA',
			'PREMIX IV DRIP  1 EA',
			'PROLASTIN MIXING FEE  1 EA',
			'ANTICOAG CLINIC MONITORING  1 EA',
			'INR VERIFICATION  1 EA',
			'1 EA',
			'IVIG ADMINISTRATIVE N/A  EA',
			'REMOVE PATCH   1 EA',
			'CHECK PATIENT PATCH Q-SHIFT  1 EA',
			'1 EA',
			'PEAK - VANCOMYCIN  1 EA',
			'TROUGH - VANCOMYCIN  1 EA',
			'PHARMACY CONSULT FOR DISCHARGE  1 EA',
			'TROUGH-GENTAMICIN  1 EA',
			'PEAK-GENTAMICIN  1 EA',
			'PEAK-TOBRAMYCIN  1 EA',
			'TROUGH-TOBRAMYCIN  1 EA',
			'PEAK-AMIKACIN  1 EA',
			'TROUGH-AMIKACIN  1 EA',
			'RANDOM - VANCOMYCIN  1 EA',
			'LEVEL - ANTI XA  1 EA',
			'BISPHOSPHONATE MESSAGE  1 EA',
			'FLU VACCINE UNAVAILABLE  1 EA',
			'TOBRAMYCIN RANDOM  1 EA',
			'LOVENOX TEACHING 1 EA 1 EA',
			'RX TO SEND ANTICOAG EDUCATION  1 EA',
			'CHANGE IV SITE  1 EA',
			'CHANGE IV TUBING  1 EA',
			'DAILY WEIGHT  1 EA',
			'CHG BATH  1 EA',
			'MEASURE PPD  1 EA',
			'SEDATION VACATION  1 EA',
			'RESIDUALS  1 EA',
			'1 EA',
			'GENTAMICIN RANDOM N/A 1 EA',
			'GENTAMICIN RANDOM  1 EA',
			'ALTERNATIVE MEDICATION MESSAGE  1 EA',
			'ENSURE PAIN REASSESSED MISC 1 EA',
			'BOWEL PREP OPTION 1  1 EA',
			'BOWEL PREP OPTION 2  1 EA',
			'1 EA',
			'CONDITIONAL ORDER  1 EA',
			'SUSPEND ORDER  1 EA',
			'PHARMACY COMMUNICATION  1 EA',
			'DOCUMENT DIABETIC VIDEO EDUCATION  1 EA',
			'PATIENT HOME MEDS IN PHARMACY  1 EA',
			'EYE TRAY EMERGENCY ROOM  1 EA',
			'AMIKACIN RANDOM  1 EA',
			'ASSESSMENT ORDER  1 EA',
			'NARCOTIC CHARTING  1 EA') )
 
		or (e.loc_facility_cd = 2552503645.00 and o.order_mnemonic not in( ;Park West - PW
			'THERAPEUTIC MONITORING   EA',
			'DC THE PREOP ORDERS  1 EA',
			'OPEN HEART TRAY  1 EA',
			'VEIN SPARING  1 ML',
			'PRECISION STRIP HOLDER  1 EA',
			'EAR TRAY CHARGE  1 EA',
			'EYE TRAY CHARGE  1 EA',
			'DC THE L&D ORDERS  1 EA',
			'DC MS-NIPRIDE-DEMEROL-DOPAMINE  1 EA',
			'ANTICOAGULANT CLINIC CHG LMT  1 EA',
			'ANTICOAGULANT CLINIC CHG EXT  1 EA',
			'DISCHARGE TODAY ??  1 EA',
			'NOSE TRAY CHARGE  1 EA',
			'DISCHARGE TODAY ?  1 EA',
			'ALBUMIN REORDER  1 EA',
			'PCA PUMP RENTAL DAILY  1 EA',
			'COUMADIN MAOI EDUCATION MAR  1 EA',
			'PHARMACOKINETIC MONITORING  1 EA',
			'MYELOGRAM TRAY  1 EA',
			'HUMULIN N INSULIN PER UNIT 1 UNIT 1 EA',
			'VANCO PULSE DOSING  1 EA',
			'DRESSING CHANGE  1 EA',
			'PROLASTIN MIXING FEE  1 EA',
			'ANTICOAG CLINIC MONITORING  1 EA',
			'INR VERIFICATION  1 EA',
			'NITRATE FREE INTERVAL  1 EA',
			'IVIG ADMINISTRATIVE N/A  EA',
			'1 EA',
			'REMOVE PATCH   1 EA',
			'CHECK PATIENT PATCH Q-SHIFT  1 EA',
			'NOT CONTINUED',
			'1 EA',
			'PEAK - VANCOMYCIN  1 EA',
			'RANDOM - VANCOMYCIN  1 EA',
			'TROUGH - VANCOMYCIN  1 EA',
			'PEAK-GENTAMICIN  1 EA',
			'TROUGH-GENTAMICIN  1 EA',
			'HOME MED CLARIFICATION  1 EA',
			'FLU VACCINE UNAVAILABLE  1 EA',
			'POST HEMODIALYSIS ANTIBIOTIC?  1 EA',
			'1 EA',
			'TOBRAMYCIN RANDOM  1 EA',
			'LOVENOX TEACHING 1 EA 1 EA',
			'RX TO SEND ANTICOAG EDUCATION  1 EA',
			'WARFARIN PATIENT  1 EA',
			'PEAK-AMIKACIN  1 EA',
			'AMIKACIN RANDOM  1 EA',
			'GENTAMICIN RANDOM  1 EA',
			'TROUGH-AMIKACIN  1 EA',
			'TROUGH-TOBRAMYCIN  1 EA',
			'ALTERNATIVE MEDICATION MESSAGE  1 EA',
			'CT W/CONTRAST ORDERED  1 EA',
			'BOWEL PREP OPTION 1  1 EA',
			'BOWEL PREP OPTION 2  1 EA',
			'CONDITIONAL ORDER  1 EA',
			'SUSPEND ORDER  1 EA',
			'PHARMACY COMMUNICATION  1 EA',
			'ENSURE PAIN REASSESSED MISC 1 EA',
			'DOCUMENT DIABETIC VIDEO EDUCATION  1 EA',
			'PATIENT HOME MEDS IN PHARMACY  1 EA',
			'EYE TRAY EMERGENCY ROOM  1 EA',
			'ASSESSMENT ORDER  1 EA',
			'REMOVE DINOPROSTONE VAG INSERT  1 EA',
			'NARCOTIC CHARTING  1 EA') )
 
		or (e.loc_facility_cd = 2552503653.00 and o.order_mnemonic not in( ;Leconte - LCMC
			'THERAPEUTIC MONITORING   EA',
			'DC THE PREOP ORDERS  1 EA',
			'OPEN HEART TRAY  1 EA',
			'VEIN SPARING  1 ML',
			'PRECISION STRIP HOLDER  1 EA',
			'EAR TRAY CHARGE  1 EA',
			'EYE TRAY CHARGE  1 EA',
			'DC THE L&D ORDERS  1 EA',
			'DC MS-NIPRIDE-DEMEROL-DOPAMINE  1 EA',
			'ANTICOAGULANT CLINIC CHG LMT  1 EA',
			'ANTICOAGULANT CLINIC CHG EXT  1 EA',
			'DISCHARGE TODAY ??  1 EA',
			'NOSE TRAY CHARGE  1 EA',
			'DISCHARGE TODAY ?  1 EA',
			'ALBUMIN REORDER  1 EA',
			'PCA PUMP RENTAL DAILY  1 EA',
			'COUMADIN MAOI EDUCATION MAR  1 EA',
			'PHARMACOKINETIC MONITORING  1 EA',
			'MYELOGRAM TRAY  1 EA',
			'HUMULIN N INSULIN PER UNIT 1 UNIT 1 EA',
			'VANCO PULSE DOSING  1 EA',
			'DRESSING CHANGE  1 EA',
			'PROLASTIN MIXING FEE  1 EA',
			'ANTICOAG CLINIC MONITORING  1 EA',
			'INR VERIFICATION  1 EA',
			'1 EA',
			'IVIG ADMINISTRATIVE N/A  EA',
			'CHECK PATIENT PATCH Q-SHIFT  1 EA',
			'REMOVE PATCH   1 EA',
			'1 EA',
			'TROUGH - VANCOMYCIN  1 EA',
			'PEAK - VANCOMYCIN  1 EA',
			'TROUGH - AMINOGLYCOSIDE  1 EA',
			'INTRA-ARTICULAR  1 EA',
			'1 EA',
			'FLU VACCINE UNAVAILABLE  1 EA',
			'TOBRAMYCIN RANDOM  1 EA',
			'LOVENOX TEACHING 1 EA 1 EA',
			'RX TO SEND ANTICOAG EDUCATION  1 EA',
			'TROUGH-GENTAMICIN  1 EA',
			'TROUGH-TOBRAMYCIN  1 EA',
			'TROUGH-AMIKACIN  1 EA',
			'PEAK-AMIKACIN  1 EA',
			'PEAK-GENTAMICIN  1 EA',
			'PEAK-TOBRAMYCIN  1 EA',
			'AMIKACIN RANDOM  1 EA',
			'RANDOM - VANCOMYCIN  1 EA',
			'GENTAMICIN RANDOM  1 EA',
			'ALTERNATIVE MEDICATION MESSAGE  1 EA',
			'BOWEL PREP OPTION 1  1 EA',
			'BOWEL PREP OPTION 2  1 EA',
			'1 EA',
			'CONDITIONAL ORDER  1 EA',
			'SUSPEND ORDER  1 EA',
			'PHARMACY COMMUNICATION  1 EA',
			'ENSURE PAIN REASSESSED MISC 1 EA',
			'DOCUMENT DIABETIC VIDEO EDUCATION  1 EA',
			'PATIENT HOME MEDS IN PHARMACY  1 EA',
			'EYE TRAY EMERGENCY ROOM  1 EA',
			'ASSESSMENT ORDER  1 EA',
			'PHARMACIST INTERVENTIONS  1 EA',
			'NARCOTIC CHARTING  1 EA') )
 		)
 
 		group by e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_id, o.order_id, o.order_mnemonic
    		 ,oa.order_dt_tm
 
		WITH SQLTYPE("f8","f8","f8",'f8','vc','dq8','vc') )i
)
 
order by  i.loc_facility_cd, i.ipop, service_trunc
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120;, MAXREC = 10000
 
 
;/********************************************************************************************************************************
 
;Populate orders count into the record structure
Head report
 
	cnt = 0
	call alterlist(orders->list, 10)
 
Detail
	cnt = cnt + 1
	call alterlist(orders->list, cnt)
 
 	orders->ord_cnt = cnt
 	orders->list[cnt].facility = i.loc_facility_cd
 
	if(i.loc_facility_cd = 21250403.00)
		orders->list[cnt].company = "20" 	;FSR
 	elseif(i.loc_facility_cd = 2552503645)
	 	orders->list[cnt].company = "22"	;PW
 	elseif(i.loc_facility_cd = 2552503639.00)
	 	orders->list[cnt].company = "25"	;MHHS
 	elseif(i.loc_facility_cd = 2552503653.00)
	 	orders->list[cnt].company = "26"	;LCMC
 	elseif(i.loc_facility_cd = 2552503635.00)
	 	orders->list[cnt].company = "28"	;FLMC
 	elseif(i.loc_facility_cd = 2553765579.00)
	 	orders->list[cnt].company = "65"	;G
 
 	else
 		orders->list[cnt].company = " "
	endif
 
 
 	if(i.loc_facility_cd = 2553765579.00) ;G
 		orders->list[cnt].department = "721500"
	else
		orders->list[cnt].department = "720000"
	endif
 
 	if(i.ipop = 'I') ;Inpatient
		orders->list[cnt].activity_code = "400000UNIT"
	 	orders->list[cnt].ip_value      = ordr_cnt
 	 	orders->list[cnt].op_value      = 0
 	 elseif(i.ipop = 'O') ;Outpatient
		orders->list[cnt].activity_code = "420000UNIT"
	 	orders->list[cnt].ip_value      = 0
 	 	orders->list[cnt].op_value      = ordr_cnt
 	endif
 
 	orders->list[cnt].date_of_service      = format(cnvtdatetime(service_trunc), 'mm/dd/yyyy;;d')
 			;format(CNVTDATETIME(CURDATE-1, CURTIME3),"MM/DD/YYYY;;D")
 	orders->list[cnt].weight               = "1"
 	orders->list[cnt].total_value          = ordr_cnt
 
Foot report
 	call alterlist(orders->list, cnt)
 
with nocounter
 
;call echojson(orders,"rec.out", 0)
call echorecord(orders)
 
 
 
;******** Build the CSV file *****************************
 
if(orders->ord_cnt > 0)
 
	Select into $outdev ;value(filename_var)
 
	from (dummyt dt with seq = orders->ord_cnt)
	order by dt.seq
 
	;build output
	Head report
		row 0
		col 0 "Company|Department|Activity_Code|Date_of_Service|Weight|IP_Value|OP_Value|Total_Value"
		row + 1
 
	Head dt.seq
		output_orders = ""
		num = size(orders->list[dt.seq], 5)
 
		output_orders = build(
			output_orders
			,wrap3(trim(orders->list[dt.seq].company))
			,wrap3(orders->list[dt.seq].department)
			,wrap3(orders->list[dt.seq].activity_code)
			,wrap3(orders->list[dt.seq].date_of_service)
			,wrap3(orders->list[dt.seq].weight)
			,wrap3(cnvtstring(orders->list[dt.seq].ip_value))
			,wrap3(cnvtstring(orders->list[dt.seq].op_value))
			,cnvtstring(orders->list[dt.seq].total_value)
		)
 
 		output_orders = trim(output_orders, 3)
 		output_orders = replace(replace(output_orders, char(13), " " ,0), char(10), " ",0)
 
	 Foot dt.seq
	 	col 0 output_orders
	 	row + 1
 
	with  format, format = stream ;to get ride of extra line feed and carriage return.
 
/*ELSE
 
	Select into value(filename_var)
 
	from (dummyt dt with seq = orders->ord_cnt)
	order by dt.seq
 
	;build output
	Head report
		row 0
		col 0 "Company|Department|Activity_Code|Date_of_Service|Weight|IP_Value|OP_Value|Total_Value"
		row + 1
 
	Head dt.seq
		output_orders = ""
 		output_orders = trim(output_orders, 3)
 		output_orders = replace(replace(output_orders, char(13), " " ,0), char(10), " ",0)
 	Foot dt.seq
	 	col 0 output_orders
	 	row + 1
 
	with  format, format = stream, nullreport */
 
 
ENDIF
 
 
/*****************************************************************************
	;Subroutins
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end go
 
 
 
 
/*
 
 
-- From Ryan/cerner
CDM/SIM number is on the charge_mod table.
Check field "FIELD6" and you can qualify down to whatever CDM schedule(s) in field1_id (code value from code set 14002).
 
 
* Since Methodist and Roane pharmacy data isn't in Strata, exclude them from the file
* Department needs to be extracted from Cerner. (Fim from STAR/first half of the item charge code)
* The Activity_Code can be hardcoded based on IP (400000UNIT) or OP (420000UNIT).
 
 
*/
 
 
/**** Facilities used - Cerner ****
 
    21250403.00	        220	FACILITY	FSR	FSR	Fort Sanders Regional Medical Center
 2552503613.00	        220	FACILITY	MMC	MMC	Methodist Medical Center
 2553765579.00	        220	FACILITY	G	G	Peninsula - A Division of Parkwest Medical Center
 2552503635.00	        220	FACILITY	FLMC	FLMC	Fort Loudoun Medical Center
 2552503639.00	        220	FACILITY	MHHS	MHHS	Morristown-Hamblen Hospital Association
 2552503645.00	        220	FACILITY	PW	PW	Parkwest Medical Center
 2552503649.00	        220	FACILITY	RMC	RMC	Roane Medical Center
 2552503653.00	        220	FACILITY	LCMC	LCMC	LeConte Medical Center
 2552503657.00	        220	FACILITY	CMC	CMC	Cumberland Medical Center, Inc
 
 
Map facility codes to Strata code
 21250403.00     -20    ;FSR
 ;2552503613.00, -24	;MMC - excluded as per Jeff Nedrow
 2553765579.00   -65    ;G
 2552503635.00,  -28	;FLMC
 2552503639.00,  -25	;MHHS
 2552503645.00,  -22 	;PW
 ;2552503649.00, -27	;RMC - excluded as per Jeff Nedrow
 2552503653.00,  -26	;LCMC
 2552503657.00	;CMC
 
 
*/
 
 
 
 

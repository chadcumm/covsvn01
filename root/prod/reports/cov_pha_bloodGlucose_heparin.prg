 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		Aug'2018
	Solution:			Pharmacy
	Source file name:  	cov_pha_bloodGlucose_heparin.prg
	Object name:		cov_pha_bloodGlucose_heparin
	Request#:			1306
 
	Program purpose:	      Glucose/Heparin/PTT log
	Executing from:		Data Feed
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_bloodGlucose_heparin:dba go
create program cov_pha_bloodGlucose_heparin:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Admit Date/Time" = "SYSDATE"
	, "End Admit Date/Time" = "SYSDATE"
	, "Choose Lab Type" = 1
	, "Facility" = 2552503613
 
with OUTDEV, start_datetime, end_datetime, lab, facility
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var 	 = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare cmrn_var   = f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
declare mrn_var    = f8 with constant(uar_get_code_by("MEANING",319,"MRN")),protect
 
declare glucose_poc_var   = f8 with constant(20136462.00), protect
declare glucose_art_var   = f8 with constant(2556636107.00), protect
declare blood_glucose_var = f8 with constant(2569900609.00), protect
declare ptt_var           = f8 with constant(21705254.00), protect
 
declare lab_parser_var = vc
declare result_parser_var = vc
 
; ce.event_cd = 2797919.00 ;heparin

IF($lab = 3)

select distinct into $outdev

facility = uar_get_code_display(e.loc_facility_cd)
, patient_name = p.name_full_formatted
, dob = p.birth_dt_tm
, e.person_id
, e.encntr_id
, mrn = ea1.alias
, cmrn = pa.alias
, fin = ea.alias
, admit_dt_tm = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_cd
, event = uar_get_code_display(ce.event_cd)
, result_val = cnvtint(ce.result_val)
;, result_val = parser(result_parser_var)
;set result_parser_var = 'cnvtint(ce.result_val)'
, unit = uar_get_code_display(ce.result_units_cd)
, source = uar_get_code_display(ce.contributor_system_cd)
, result_status = uar_get_code_display(ce.result_status_cd)
, event_start_dt = format(ce.event_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
, event_end_dt = format(ce.event_end_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, performed_dt = format(ce.performed_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, verified_dt_tm  = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")

 
from
 
 encounter e
 
 ,(left join encntr_alias ea on ea.encntr_id = e.encntr_id
 		and ea.encntr_alias_type_cd = fin_var
 		and ea.active_ind = 1
 		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join encntr_alias ea1 on ea1.encntr_id = e.encntr_id
 		and ea1.encntr_alias_type_cd = mrn_var
 		and ea1.active_ind = 1
 		and ea1.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join person_alias pa on pa.person_id = e.person_id
 		and pa.person_alias_type_cd = cmrn_var
 		and pa.active_ind = 1
 		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )

, pregnancy_instance pi
, problem pm
, clinical_event ce
, person p
 
plan e where e.loc_facility_cd = $facility
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;and e.encntr_type_cd = 309308.00 ;Inpatient
	and e.active_ind = 1
 
join ea
join ea1
join pa

join pi where pi.person_id = e.person_id
	and pi.organization_id = e.organization_id
	and pi.active_ind = 1
	;and pi.preg_end_dt_tm <= sysdate
	and pi.historical_ind = 0 ;non historical items

join pm where pm.person_id = pi.person_id
	and pm.problem_id = pi.problem_id
	and pm.nomenclature_id = 7777483.00 ;Pregnant
 
join ce where ce.person_id = e.person_id
	and ce.result_val != " "
	and (ce.event_cd in(glucose_poc_var, glucose_art_var, blood_glucose_var) and isnumeric(ce.result_val) > 0)
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.loc_facility_cd, e.person_id, e.encntr_id, event_start_dt, event_end_dt, performed_dt, verified_dt_tm, ce.event_cd


WITH NOCOUNTER, SEPARATOR=" ", FORMAT

;--------------------------------------------------------------------------------------------------------------------------------

ELSE ;Lab - report type

if($lab = 1)
	set lab_parser_var = 'ce.event_cd in(glucose_poc_var, glucose_art_var, blood_glucose_var) and isnumeric(ce.result_val) > 0'
	set result_parser_var = 'cnvtint(ce.result_val)'
elseif($lab = 2)
	set lab_parser_var = 'ce.event_cd = ptt_var'
	set result_parser_var = 'ce.result_val'
endif
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
select distinct into $outdev
 
facility = uar_get_code_display(e.loc_facility_cd)
, patient_name = p.name_full_formatted
, dob = p.birth_dt_tm
, e.person_id
, e.encntr_id
, mrn = ea1.alias
, cmrn = pa.alias
, fin = ea.alias
, admit_dt_tm = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_cd
, event = uar_get_code_display(ce.event_cd)
, result_val = parser(result_parser_var)
, unit = uar_get_code_display(ce.result_units_cd)
, source = uar_get_code_display(ce.contributor_system_cd)
, result_status = uar_get_code_display(ce.result_status_cd)
, event_start_dt = format(ce.event_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
, event_end_dt = format(ce.event_end_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, performed_dt = format(ce.performed_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, verified_dt_tm  = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")
 
from
 
 encounter e
 
 ,(left join encntr_alias ea on ea.encntr_id = e.encntr_id
 		and ea.encntr_alias_type_cd = fin_var
 		and ea.active_ind = 1
 		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join encntr_alias ea1 on ea1.encntr_id = e.encntr_id
 		and ea1.encntr_alias_type_cd = mrn_var
 		and ea1.active_ind = 1
 		and ea1.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join person_alias pa on pa.person_id = e.person_id
 		and pa.person_alias_type_cd = cmrn_var
 		and pa.active_ind = 1
 		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 
, clinical_event ce
 
, person p
 
 
plan e where e.loc_facility_cd = $facility
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd = 309308.00 ;Inpatient
	and e.active_ind = 1
 
join ea
join ea1
join pa
 
join ce where ce.person_id = e.person_id
	and ce.result_val != " "
	and parser(lab_parser_var)
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.loc_facility_cd, e.person_id, e.encntr_id, event_start_dt, event_end_dt, performed_dt, verified_dt_tm, ce.event_cd
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120;, maxrec = 10000
 
ENDIF ;Lab - report type 
 
end
go
 
 
/********** Heparin rate findings ***************************
 
select distinct into $outdev
 
          CE.EVENT_ID
          , CE.order_id
          , CE.EVENT_START_DT_TM ";;q"
          , CE.EVENT_END_DT_TM ";;q"
          , ce.performed_dt_tm ';;q'
          , ce.verified_dt_tm ';;q'
          ;, o.order_mnemonic, o.order_detail_display_line, o.clinical_display_line, o.dept_misc_line, o.order_detail_display_line
          , clinical_event = uar_get_code_display(ce.event_cd)
          , status = uar_get_code_display(ce.result_status_cd)
          ;, ce.result_val
          , rate = CE.EVENT_TAG
          , iv_event = uar_get_code_display(cr.iv_event_cd)
 
 
          ;, RATE_UNIT = UAR_GET_CODE_DISPLAY(CE.RESULT_UNITS_CD)
 
FROM  CLINICAL_EVENT CE, ce_med_result cr
where cr.event_id = ce.event_id
;and o.ORDER_ID in(491567147.00, 490044881.00)
and ce.person_id = 16050864.00
and ce.event_cd = 679984 ;Administration Infomation
 
 
;ORDER BY CE.EVENT_START_DT_TM
 
;select * from clinical_event
;where person_id = 16050864.00
;and event_cd = 679984
 
;select * from ce_med_result where event_id = 373285982.00
 
************************************************************************************************
 
 
 
 
 
 
/* Initial separate code for PTT and Glucose
 
;******************** PTT **********************************************
select distinct into $outdev
 
facility = uar_get_code_display(e.loc_facility_cd)
, patient_name = p.name_full_formatted
, dob = p.birth_dt_tm
, e.person_id
, e.encntr_id
, mrn = ea1.alias
, cmrn = pa.alias
, fin = ea.alias
, admit_dt_tm = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_cd
, event = uar_get_code_display(ce.event_cd)
, result_val = ce.result_val
, unit = uar_get_code_display(ce.result_units_cd)
, source = uar_get_code_display(ce.contributor_system_cd)
, result_status = uar_get_code_display(ce.result_status_cd)
, event_start_dt = format(ce.event_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
, event_end_dt = format(ce.event_end_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, performed_dt = format(ce.performed_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, verified_dt_tm  = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")
 
from
 
 encounter e
 
 ,(left join encntr_alias ea on ea.encntr_id = e.encntr_id
 		and ea.encntr_alias_type_cd = fin_var
 		and ea.active_ind = 1
 		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join encntr_alias ea1 on ea1.encntr_id = e.encntr_id
 		and ea1.encntr_alias_type_cd = mrn_var
 		and ea1.active_ind = 1
 		and ea1.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join person_alias pa on pa.person_id = e.person_id
 		and pa.person_alias_type_cd = cmrn_var
 		and pa.active_ind = 1
 		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 
, clinical_event ce
 
, person p
 
, ( ( select code_value, display, display_key, description
	from code_value cv
	;where cv.display in('Prothrombin Time', 'Partial Thromboplastin Time')
	where cv.display in('Partial Thromboplastin Time')
	with sqltype('f8', 'vc', 'vc', 'vc')
    )i
)
 
plan e where e.loc_facility_cd = 2552503645.00 ;Park West
	;and e.reg_dt_tm between cnvtdatetime("24-JUL-2018 00:00:00") and cnvtdatetime("31-JUL-2018 23:59:00")
	and e.encntr_id = 110865969.00
	and e.encntr_type_cd = 309308.00 ;Inpatient
	and e.active_ind = 1
 
join ea
join ea1
join pa
join i
 
join ce where ce.person_id = e.person_id
	and ce.event_cd = i.code_value
 	and ce.result_val != " "
	;and isnumeric(ce.result_val) > 0
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.loc_facility_cd, e.person_id, e.encntr_id, event_start_dt, event_end_dt, performed_dt, verified_dt_tm, ce.event_cd
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120;, maxrec = 10000
 
 
end
go
*/
 
 
/*
 
;******************** GLUCOSE **********************************************
 
select distinct into $outdev
 
facility = uar_get_code_display(e.loc_facility_cd)
, patient_name = p.name_full_formatted
, dob = p.birth_dt_tm
, e.person_id
, e.encntr_id
, mrn = ea1.alias
, cmrn = pa.alias
, fin = ea.alias
, admit_dt_tm = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_cd
, event = uar_get_code_display(ce.event_cd)
, result_val = cnvtint(ce.result_val)
, unit = uar_get_code_display(ce.result_units_cd)
, source = uar_get_code_display(ce.contributor_system_cd)
, result_status = uar_get_code_display(ce.result_status_cd)
, event_start_dt = format(ce.event_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
, event_end_dt = format(ce.event_end_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, performed_dt = format(ce.performed_dt_tm  , "mm/dd/yyyy hh:mm;;d")
, verified_dt_tm  = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")
 
from
 
 encounter e
 
 ,(left join encntr_alias ea on ea.encntr_id = e.encntr_id
 		and ea.encntr_alias_type_cd = fin_var
 		and ea.active_ind = 1
 		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join encntr_alias ea1 on ea1.encntr_id = e.encntr_id
 		and ea1.encntr_alias_type_cd = mrn_var
 		and ea1.active_ind = 1
 		and ea1.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join person_alias pa on pa.person_id = e.person_id
 		and pa.person_alias_type_cd = cmrn_var
 		and pa.active_ind = 1
 		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 
, clinical_event ce
 
, person p
 
, ( ( select code_value, display, display_key, description
	from code_value cv
	where cv.display = "*Glucose*"
	with sqltype('f8', 'vc', 'vc', 'vc')
    )i
)
 
plan e where e.loc_facility_cd = 2552503645.00 ;Park West
	and e.reg_dt_tm between cnvtdatetime("24-JUL-2018 00:00:00") and cnvtdatetime("31-JUL-2018 23:59:00")
	and e.encntr_type_cd = 309308.00 ;Inpatient
	and e.active_ind = 1
 
join ea
join ea1
join pa
join i
 
join ce where ce.person_id = e.person_id
	and ce.event_cd = i.code_value
 	and ce.event_cd in(20136462.00,  2556636107.00, 2569900609.00) ;Glucose POC, Glucose Art, Blood Glucose
 	and ce.result_val != " "
	and isnumeric(ce.result_val) > 0
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
 
order by e.loc_facility_cd, e.person_id, e.encntr_id, event_start_dt, event_end_dt, performed_dt, verified_dt_tm, ce.event_cd
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120;, maxrec = 10000
 
 
end
go
 
*/
 
/***********************************************************************************************************************************
BG - Blood Glucose
 
Heparin   -  Easy to draw blood or while doing dialysis and used for different situations.
		 Heparin is a drug that inhibits blood clotting (anticoagulant) and is used to treat people who have developed
		 dangerous blood clots (thrombi) or have a high risk of developing them.
 
PPT level -  Partial Thromboplastin Time - Test, which measures how quickly your blood clots(one of the clot factor).
		 (test tells you how long it takes your blood to clot)
 
Xa level  -  This test indirectly measures the amount of heparin in a person's blood by measuring its inhibition of factor
		 Xa activity, one of the proteins involved in blood clot formation (known as heparin anti-Xa activity).
 
	    -  The amount of factor Xa in blood is affected by the amount of heparin in the body.
	       This test is used to monitor heparin levels in patients being treated with standard heparin[1][2][4]
	       or low molecular weight heparin[5][6][7][1][3].
 
**************************************************************************************************************************************/
 
/*
	;2552503613.00 ;Methodist
	;2552503649.00 ;Roane
	;2552503645.00 ;Park West
	;2552503635.00 ;Loudun
 
	/*;and ce.task_assay_cd = 316530
 	;and ce.result_status_cd in(25,34,35)
 	and ce.event_cd not in(20680621.00, 22346600.00, 21705166.00, 709469.00, 4169843.00, 2560385525.00,
 	4253554.00, 21826983.00, 274981121.00, 274981135.00, 274981149.00, 47474565.00, 4156788.00, 4253554.00,
 	21702839.00,709472.00, 2557031653.00, 215504213.00, 23357246.00, 2558870633.00) */
 
/*
;Excluded as per Tommy's request
select code_value, display from code_value
where code_value in(20680621.00, 22346600.00, 21705166.00, 709469.00, 4169843.00, 2560385525.00,
 	4253554.00, 21826983.00, 274981121.00, 274981135.00, 274981149.00, 47474565.00, 4156788.00,
 	4253554.00,  21702839.00,  709472.00, 2557031653.00, 31007271.00, 215504213.00, 20136462.00, 23357246.00,
 	2558870633.00)
 
 
select * from encntr_alias where alias = '1820900905' ;eid = 110865969.00
 
select * from encounter where encntr_id = 110865969.00
 
select * from encntr_alias where alias = '1820700054' ;eid =    110579810.00
 
select * from result where person_id =  15955259.00 and task_assay_cd = 316530
 
select * from perform_result where result_id in(288107255.00, 288204634.00)
 
 
 
 
select * from code_value cv WHERE cv.display = "*Heparin*"
   ;"*Glucose*" ;"*Heparin*"
and cv.code_set = 72
 
select * from code_value cv where cv.code_value = 316530 ; 14003

/*
****************************************************************************
*  Covenant Health Information Technology
*  Knoxville, Tennessee
*****************************************************************************
 
  Author:            Mark Maples
  Date Written:      September 2022
  Solution:          Emergency Medgicine / FirstNet
  Source file name:  cov_ed_opperf_extract.prg
  Object name:       cov_ed_opperf_extract
  Request #:
 
  Program purpose:   Copy of program cov_ed_opperf_extract with pipe delimited output
 
  Executing from:    CCL.
 
  Special Notes:
 
**********************************************************************************
*/
 
drop program cov_ed_opperf_extract go
create program cov_ed_opperf_extract
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Disposition Date (>=)" = "SYSDATE"
 
with OUTDEV, STARTDATE_PMPT
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
 
RECORD OpPerf_fac
(
1	startdate			= c50
1	enddate				= c50
1	fac_tot				= f8
1   peds_tot			= f8
1	adult_tot			= f8
 
1 	dispo_admit_fac_tot	= i4
1 	dispo_dc_fac_tot	= i4
1 	ems_fac_tot			= i4
1	lwbs_tot			= i4
1	lwbs_perc			= f8
1	lwbs_peds_tot		= i4
1	lwbs_peds_perc		= f8
1	lwbs_adult_tot		= i4
1	lwbs_adult_perc		= f8
1	lwbt_tot			= i4
1	lwbt_perc			= f8
1	lwbt_peds_tot		= i4
1	lwbt_peds_perc		= f8
1	lwbt_adult_tot		= i4
1	lwbt_adult_perc		= f8
1	lwtc_tot			= i4
1	lwtc_perc			= f8
1	lwtc_peds_tot		= i4
1	lwtc_peds_perc		= f8
1	lwtc_adult_tot		= i4
1	lwtc_adult_perc		= f8
 
1 list [*]
;-----------demo data----------
	2 fac_name					= c50
	2 fac_abbr					= c20
	2 fac_group     			= c50
 
	2 encntr_id 				= f8
	2 person_id 				= f8
	2 fin           			= c20
	2 mrn						= vc
	2 age		    			= i4
	2 sex						= vc
	2 tracking_id 				= f8
	2 dept_id					= c3
 
;-----------dates--------------
	2 chkin_dt					= dq8
	2 chkout_dt 				= dq8
	2 star_dc					= dq8
	2 triage_start_dt			= dq8
	2 triage_stop_dt			= dq8
	2 bed_dt					= dq8
	2 md_ts						= dq8
	2 dtd_dt					= dq8
	2 adm_dtd_dt				= dq8
	2 dc_dtd_dt					= dq8
	2 pso_dttm					= dq8	;002
	2 first_nonED_bed_dt		= dq8	;002
	2 first_nonED_bed			= vc	;003
 
 
;-----------disposition info---
 
	2 dispo_admit				= f8
	2 dispo_dc					= f8
	2 dispo_type 				= c1
	2 disposition				= c100
	2 HUC_disposition			= c100
	2 arrival_to_triage			= f8
	2 arrival_to_bed			= f8
	2 arrival_to_MD 			= f8
	2 bed_to_MD					= f8
	2 triage_startstop			= f8
	2 triage_startstop_median	= f8
	2 arrival_to_triage_median	= f8
	2 arrival_to_bed_median		= f8
	2 arrival_to_md_median		= f8
	2 bed_to_MD_median			= f8
	2 mdtodtd					= f8
	2 mdtodtd_adm				= f8
	2 mdtodtd_dc				= f8
	2 dtdtodc					= f8
	2 dtdtodc_adm				= f8
	2 dtdtodc_dc				= f8
	2 ems						= i4
	2 lwbs						= i4
	2 lwbs_adult				= i4
	2 lwbs_peds 				= i4
	2 lwbt						= i4
	2 lwbt_adult				= i4
	2 lwbt_peds 				= i4
	2 lwtc						= i4
	2 lwtc_adult				= i4
	2 lwtc_peds 				= i4
	2 LOS						= f8
	2 LOS_DC					= f8
	2 LOS_ADM					= f8
	2 mLOS						= f8
	2 mLOS_DC					= f8
	2 mLOS_ADM					= f8
	2 mmdtodtd					= f8
	2 mmdtodtd_adm				= f8
	2 mmdtodtd_dc				= f8
	2 mdtdtodc_adm				= f8
	2 mdtdtodc_dc				= f8
	2 rfv						= c100
	2 moa						= c100
	2 esi						= c2
	2 room						= vc
	2 ped						= i4
	;staff
	2 provider	    			= c100    ;ER doctor
	2 edrn		   				= c100    ;ER nurse
	2 bh						= i4	;behavioral health patient
	2 rfac						= c100
	2 pcp						= c100
	2 isolation					= c100
	2 restraint					= c100
	2 dc_dx						= c100
 
)
 
RECORD OpPerf_room
(
1 list[*]
;	2	fac			= vc
;	2	fac_cv		= f8
;	2	building	= vc
;	2	dept		= vc
	2	dept_cd		= f8
	2	room		= vc
;	2	room_cd		= f8
;	2	bed			= vc
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE fin_var				= f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
 
DECLARE INITCAP()			= C100
 
DECLARE num					= i4 with noconstant(0)
 
DECLARE idx					= i4 WITH protect
 
DECLARE pos 				= i4 WITH protect
 
DECLARE triage_start_var	= f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",6200,"TRIAGEEVENT")),protect
 
;the RN exam start time is the Triage stop time per email from Jennifer Farrar email from 02/08/2019
DECLARE triage_stop_var		= f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",6200,"NURSESEEEVENT")),protect
 
DECLARE bed_time_var		= f8 WITH constant(UAR_GET_CODE_BY("DISPLAY_KEY",6200,"BEDASSIGNMENTEVENT")),protect
 
DECLARE MD_time_var			= f8 WITH constant(UAR_GET_CODE_BY("DISPLAY",72,"ED Provider Pt Seen Date/Time Form")),protect
 
DECLARE ED_DC_to_var		= f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",72,"EDDISCHARGEDTO")),protect
 
DECLARE EMS_var		 		= f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",72,"LYNXMODEOFARRIVAL")),protect
DECLARE ESI_var		 		= f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",72,"TRACKINGACUITY")),protect
 
DECLARE PSO1_var		 	= f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",200,"PSOADMITTOINPATIENT")),protect
DECLARE PSO2_var		 	= f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",200,"PSOOBSERVATION")),protect
 
DECLARE DISPO_COND_ADMIT_VAR = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTOADMIT")),protect
DECLARE DISPO_COND_TRANS_VAR = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTOTRANSFER")),protect
DECLARE DISPO_COND_DISCH_VAR = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTODISCHARGE")),protect
 
DECLARE accepting_fac_var	= f8 WITH constant(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAHOSPITALACCEPTANCEFACILITY')),protect
DECLARE isolation_var		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'ISOLATIONTYPE')),protect
DECLARE restraint_var		= f8 WITH constant(UAR_GET_CODE_BY('DISPLAYKEY',72,'RESTRAINTACTIVITYTYPE')),protect
 
DECLARE DIAG_DISCH_VAR		 = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",17,"DISCHARGE")),PROTECT
 
DECLARE BH_Powerplan_var	 = f8 WITH protect ,constant (2560333213)
 
DECLARE FAC_VAR           	 = vc WITH noCONSTANT(fillstring(1000," "))
 
DECLARE FAC_FLMC_VAR      	 = f8 SET FAC_FLMC_VAR	= 2552503635.00
DECLARE FAC_FSR_VAR       	 = f8 SET FAC_FSR_VAR	=   21250403.00
DECLARE FAC_LCMC_VAR      	 = f8 SET FAC_LCMC_VAR	= 2552503653.00
DECLARE FAC_MHHS_VAR      	 = f8 SET FAC_MHHS_VAR	= 2552503639.00
DECLARE FAC_MMC_VAR       	 = f8 SET FAC_MMC_VAR	= 2552503613.00
DECLARE FAC_PWMC_VAR      	 = f8 SET FAC_PWMC_VAR	= 2552503645.00
DECLARE FAC_RMC_VAR       	 = f8 SET FAC_RMC_VAR	= 2552503649.00
 
DECLARE FLMC_TRKGRP_VAR   	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"FLMCEDTRACKINGGROUP")),PROTECT
DECLARE FSR_TRKGRP_VAR    	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"FSREDTRACKINGGROUP")),PROTECT
DECLARE LCMC_TRKGRP_VAR   	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"LCMCEDTRACKINGGROUP")),PROTECT
DECLARE MHHS_TRKGRP_VAR   	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"MHHSEDTRACKINGGROUP")),PROTECT
DECLARE MMC_TRKGRP_VAR    	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"MMCEDTRACKINGGROUP")),PROTECT
DECLARE PWMC_TRKGRP_VAR   	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"PWMCEDTRACKINGGROUP")),PROTECT
DECLARE RMC_TRKGRP_VAR    	 = f8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",16370,"RMCEDTRACKINGGROUP")),PROTECT
 
DECLARE INITCAP() = C100
 
DECLARE output_var = vc with noconstant("")
DECLARE stat			 = i4 with noconstant(0)
 
;-----------------------------
; DEFINE OUTPUT VALUE
;-----------------------------
set output_var = value($OUTDEV)        ;DISPLAY TO SCREEN
 
;***************************************************************
;***************************************************************
;***************************************************************
;	FACILITY SPECIFIC STATISTICS
;***************************************************************
;***************************************************************
;***************************************************************
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;************************************
;	populate the bed record structure
;	based on the FirstNet bed build.
;	only FirstNet beds will populate RS
;************************************
 
SELECT DISTINCT INTO 'NL:'
	 dept_cd	= cv5.code_value
	,room		= cv6.display
;	,bed		= UAR_GET_CODE_DISPLAY(lg5.child_loc_cd)
FROM
	 code_value cv1
	,location_group lg1
	,code_value cv2
	,location_group lg2
	,code_value cv3
	,location_group lg3
	,code_value cv4
	,location_group lg4
	,code_value cv5
	,location_group lg5
	,code_value cv6
 
PLAN cv1 WHERE cv1.code_set = 220
	AND cv1.cdf_meaning = "PTTRACKROOT"
	AND cv1.active_ind = 1
	AND (cv1.display = "* ED *" OR cv1.display = "* EB *")
;location view
JOIN lg1 WHERE lg1.parent_loc_cd = cv1.code_value
	AND lg1.active_ind = 1
;facility
JOIN cv2 WHERE lg1.child_loc_cd = cv2.code_value
	AND cv2.active_ind = 1
JOIN lg2 WHERE lg1.child_loc_cd = lg2.parent_loc_cd
	AND lg2.root_loc_cd = cv1.code_value
	AND lg2.active_ind = 1
JOIN cv3 WHERE lg2.parent_loc_cd = cv3.code_value
	AND cv3.active_ind = 1
;	AND cv3.code_value = $FACILITY_PMPT
;	AND cv3.code_value IN ( 2560254871.00)
	AND cv3.code_value IN (2552503613,2552503649,2552503653,2552503635,2552503645,21250403,2552503639)
;Building
JOIN lg3 WHERE lg2.child_loc_cd = lg3.parent_loc_cd
	AND lg3.root_loc_cd = cv1.code_value
	AND lg3.active_ind = 1
JOIN cv4 WHERE lg3.parent_loc_cd = cv4.code_value
	AND cv4.active_ind = 1
;	AND cv4.display = "PW"
;unit
JOIN lg4 WHERE lg3.child_loc_cd = lg4.parent_loc_cd
	AND lg4.root_loc_cd = cv1.code_value
	AND lg4.active_ind = 1
JOIN cv5 WHERE lg4.parent_loc_cd = cv5.code_value
;	AND (cv5.display = "* ED" OR
;		 cv5.display = "* EB")
	AND cv5.active_ind = 1
;room
JOIN cv6 WHERE lg4.child_loc_cd = cv6.code_value
	AND cv6.active_ind = 1
;bed
JOIN lg5 WHERE OUTERJOIN(lg4.child_loc_cd) = lg5.parent_loc_cd
	AND lg5.active_ind = 1
;WAITING ROOM DOESN'T PULL IN THE ABOVE QUERY SO ADDING THEM WITH THE BELOW UNIONS -- ONE FOR EACH FACILITY ED
UNION
(select
	 dept_cd = 28170721
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2553912779
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2554024621
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2553913493
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2557555261
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2556761187
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2556758093
	,room = "EDWR"
FROM
	DUAL
UNION
(select
	 dept_cd = 2560254871
	,room = "EDWR"
FROM
	DUAL
))))))))
ORDER BY
	 dept_cd
	,room
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
 
	/* if needed add 10 positions on the list list_item */
	IF (MOD(cnt,10) = 1 or cnt = 10)
		STAT = ALTERLIST(OpPerf_room->LIST,cnt + 9)
	ENDIF
 
	OpPerf_room->LIST[cnt].dept_cd	= dept_cd	;cv5.code_value
	OpPerf_room->LIST[cnt].room		= room	;cv6.display
 
FOOT REPORT
 
	stat = alterlist(OpPerf_room->LIST, cnt)
 
WITH nocounter, separator = " ", format, RDBUNION
 
;CALL ECHORECORD(OpPerf_room)
;GO TO exitscript
 
;***************************************
;	get patient and tracking information
;***************************************
 
SELECT INTO 'NL:'
	 mrn			= cnvtalias(omf_get_alias("MRN", e.encntr_id),omf_get_alias_pool_cd("MRN",319, e.encntr_id))
	,age 			= datetimediff(e.reg_dt_tm, p.birth_dt_tm ,9)
	,sex			= evaluate2(IF(p.sex_cd=363) "M" ELSEIF(p.sex_cd=362) "F" ELSE "ukn" ENDIF)
	,checkin_dt		= MIN(tc.checkin_dt_tm) OVER(PARTITION BY e.encntr_id)	;get the first checkin date
	,checkout_dt	= MIN(tc.checkout_dt_tm) OVER(PARTITION BY e.encntr_id)	;get the first checkout date
	,dispo_type		= IF (CNVTUPPER(ce.result_val) = "*OBSERVATION*") "A" ELSEIF (CNVTUPPER(ce.result_val) = "*DISCHARGE*") "D" ENDIF
    ,dispo_admit	= IF (CNVTUPPER(ce.result_val) = "*OBSERVATION*") CNVTINT(1) ENDIF
    ,dispo_dc		= IF (CNVTUPPER(ce.result_val) = "*DISCHARGE*") CNVTINT(1) ENDIF
    ,lwbs			= IF (CNVTUPPER(ce.result_val) = "*LEFT WITHOUT BEING SEEN*") CNVTINT(1) ENDIF
    ,lwbt			= IF (CNVTUPPER(ce.result_val) = "*LEFT WITHOUT TRIAGE*") CNVTINT(1) ENDIF
    ,lwtc			= IF (CNVTUPPER(ce.result_val) = "*LEFT WITHOUT TREATMENT COMPLETION*") CNVTINT(1) ENDIF
	,disposition	= ce.result_val
	,HUC_disposition = uar_get_code_display(tc.checkout_disposition_cd)
	,edrn			= REPLACE(INITCAP(staff.name_full_formatted)," Rn"," RN")
	,pcp			= REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(INITCAP(pcp_name.name_full_formatted))," Md"," MD")," Pa"," PA")," Do"," DO")," Apn"," APN"),"PAul","Paul")
	,dept_id		= IF(tc.tracking_group_cd = FLMC_TRKGRP_VAR) "EDL"
							ELSEIF(tc.tracking_group_cd = FSR_TRKGRP_VAR) "EDF"
							ELSEIF(tc.tracking_group_cd = LCMC_TRKGRP_VAR) "EDS"
							ELSEIF(tc.tracking_group_cd = MHHS_TRKGRP_VAR) "EDM"
							ELSEIF(tc.tracking_group_cd = MMC_TRKGRP_VAR) "EDB"
							ELSEIF(tc.tracking_group_cd = PWMC_TRKGRP_VAR) "EDP"
							ELSEIF(tc.tracking_group_cd = RMC_TRKGRP_VAR) "EDR"
						ENDIF
	,fac_name		= IF(tc.tracking_group_cd = FLMC_TRKGRP_VAR) "Loudoun"
							ELSEIF(tc.tracking_group_cd = FSR_TRKGRP_VAR) "Regional"
							ELSEIF(tc.tracking_group_cd = LCMC_TRKGRP_VAR) "LeConte"
							ELSEIF(tc.tracking_group_cd = MHHS_TRKGRP_VAR) "Morristown"
							ELSEIF(tc.tracking_group_cd = MMC_TRKGRP_VAR) "Methodist"
							ELSEIF(tc.tracking_group_cd = PWMC_TRKGRP_VAR) "Parkwest"
							ELSEIF(tc.tracking_group_cd = RMC_TRKGRP_VAR) "Roane"
						ENDIF
FROM
	tracking_checkin tc
	,(INNER JOIN tracking_item ti ON ti.tracking_id = tc.tracking_id
		AND ti.active_ind = 1
	 )
	,(INNER JOIN person p ON p.person_id = ti.person_id
		AND p.active_ind = 1
		AND p.end_effective_dt_tm >= SYSDATE
	 )
	,(INNER JOIN encounter e ON e.person_id = p.person_id
 		AND e.encntr_id = ti.encntr_id
		AND e.active_ind = 1
;		AND e.encntr_id in (126110151)
		AND e.end_effective_dt_tm >= SYSDATE
	 )
	;MADE A LEFT JOIN BECAUSE NOT ALL PATIENTS WILL HAVE A FIN#
	,(LEFT JOIN encntr_alias ea ON ea.encntr_id = e.encntr_id
		AND ea.encntr_alias_type_cd = fin_var
		AND ea.active_ind = 1
	 )
	,(LEFT JOIN clinical_event ce ON ce.encntr_id = e.encntr_id
		AND ce.person_id = e.person_id
		AND ce.event_cd = ED_DC_to_var	;   37175697
		AND ce.event_end_dt_tm < cnvtdatetime(SYSDATE)
		AND ce.valid_until_dt_tm >= cnvtdatetime(SYSDATE)
		AND CNVTUPPER(ce.event_title_text) != "DATE\TIME CORRECTION"
	 )
	,(LEFT JOIN prsnl staff ON staff.person_id = tc.primary_nurse_id)
	,(LEFT JOIN person_prsnl_reltn pcp ON pcp.person_id = p.person_id
        AND pcp.active_ind = 1 ;active
        AND pcp.person_prsnl_r_cd = 1115  ;PCP
        AND pcp.beg_effective_dt_tm < sysdate
        AND pcp.end_effective_dt_tm > sysdate
     )
    ,(LEFT JOIN prsnl pcp_name ON pcp.prsnl_person_id = pcp_name.person_id)
    ,(LEFT JOIN pm_transaction pmt ON (pmt.n_encntr_id = e.encntr_id); or pmt.o_encntr_id = e.encntr_id)
    	AND pmt.transaction = "DSCH"
     )
WHERE
    tc.active_ind = 1
    AND tc.checkin_dt_tm = e.arrive_dt_tm	;002
    AND tc.tracking_group_cd IN (FLMC_TRKGRP_VAR,FSR_TRKGRP_VAR,LCMC_TRKGRP_VAR,MHHS_TRKGRP_VAR,MMC_TRKGRP_VAR,PWMC_TRKGRP_VAR,RMC_TRKGRP_VAR)
    AND tc.checkout_dt_tm > cnvtdatetime($STARTDATE_PMPT)
 
ORDER BY
	 e.encntr_id
	,checkin_dt
	,ce.clinical_event_id DESC	;get last charting
 
HEAD REPORT
 
	cnt = 0
	peds_cnt = 0
	adult_cnt = 0
 
	fac_adm_tot		= 0
	fac_dc_tot		= 0
	lwbs_tot		= 0
	lwbs_peds_tot	= 0
	lwbs_adult_tot	= 0
	lwbt_tot		= 0
	lwbt_peds_tot	= 0
	lwbt_adult_tot	= 0
	lwtc_tot		= 0
	lwtc_peds_tot	= 0
	lwtc_adult_tot	= 0
 
HEAD e.encntr_id
 
	cnt = cnt + 1
 
	/* if needed add 10 positions on the list list_item */
	IF (MOD(cnt,10) = 1 or cnt = 10)
		STAT = ALTERLIST(OpPerf_fac->LIST,cnt + 9)
	ENDIF
 
	IF (age < 18)
		peds_cnt = peds_cnt + 1
		lwbs_peds_tot = lwbs_peds_tot + lwbs
		lwbt_peds_tot = lwbt_peds_tot + lwbt
		lwtc_peds_tot = lwtc_peds_tot + lwtc
	ELSE
		adult_cnt = adult_cnt + 1
		lwbs_adult_tot = lwbs_adult_tot + lwbs
		lwbt_adult_tot = lwbt_adult_tot + lwbt
		lwtc_adult_tot = lwtc_adult_tot + lwtc
	ENDIF
 
	;store the record information in the record structure
	OpPerf_fac->LIST[cnt].fac_name		= fac_name
	OpPerf_fac->LIST[cnt].fac_abbr		= UAR_GET_CODE_DISPLAY(e.loc_facility_cd)			;facility short name
	OpPerf_fac->LIST[cnt].fac_group    	= UAR_GET_CODE_DISPLAY(tc.tracking_group_cd)		;patient tracking view (room grouping)
	OpPerf_fac->LIST[cnt].dept_id		= dept_id
	OpPerf_fac->LIST[cnt].fin			= ea.alias
	OpPerf_fac->LIST[cnt].mrn			= mrn
	OpPerf_fac->LIST[cnt].encntr_id		= e.encntr_id										;EID
	OpPerf_fac->LIST[cnt].person_id		= e.person_id										;PID
	OpPerf_fac->LIST[cnt].age			= age
	OpPerf_fac->LIST[cnt].sex			= sex
	OpPerf_fac->LIST[cnt].tracking_id	= ti.tracking_id									;pulled in for JOINing purposes to get the
	OpPerf_fac->LIST[cnt].chkin_dt 		= checkin_dt;tc.checkin_dt_tm									;check in date
	OpPerf_fac->LIST[cnt].chkout_dt		= checkout_dt;tc.checkout_dt_tm									;check out date
	OpPerf_fac->LIST[cnt].star_dc	 	= pmt.updt_dt_tm
	OpPerf_fac->LIST[cnt].los			= datetimediff(checkout_dt, checkin_dt,4)
	OpPerf_fac->fac_tot = cnt
	OpPerf_fac->peds_tot = peds_cnt
	OpPerf_fac->adult_tot = adult_cnt
 
	fac_adm_tot = fac_adm_tot + dispo_admit	;totaling the admit dispositions
	fac_dc_tot = fac_dc_tot + dispo_dc	;totaling the admit dispositions
 
	lwbs_tot = lwbs_tot + lwbs	;totaling the lwbs patients
	lwbt_tot = lwbt_tot + lwbt	;totaling the lwbt patients
	lwtc_tot = lwtc_tot + lwtc	;totaling the lwbt patients
 
	OpPerf_fac->LIST[cnt].dispo_type	= dispo_type
	OpPerf_fac->LIST[cnt].dispo_admit	= dispo_admit
	OpPerf_fac->LIST[cnt].dispo_dc		= dispo_dc
	OpPerf_fac->LIST[cnt].disposition	= disposition
	OpPerf_fac->LIST[cnt].HUC_disposition = HUC_disposition
	OpPerf_fac->LIST[cnt].LOS_DC		= IF (dispo_type = "D") OpPerf_fac->LIST[cnt].los ENDIF
	OpPerf_fac->LIST[cnt].LOS_ADM		= IF (dispo_type = "A") OpPerf_fac->LIST[cnt].los ENDIF
	OpPerf_fac->LIST[cnt].lwbs			= lwbs
	OpPerf_fac->LIST[cnt].lwbs_adult    = IF (LWBS = 1 AND OpPerf_fac->LIST[cnt].age >= 18) CNVTINT(1) ENDIF
	OpPerf_fac->LIST[cnt].lwbs_peds		= IF (LWBS = 1 AND OpPerf_fac->LIST[cnt].age < 18) CNVTINT(1) ENDIF
	OpPerf_fac->LIST[cnt].lwbt			= lwbt
	OpPerf_fac->LIST[cnt].lwbt_adult    = IF (LWBT = 1 AND OpPerf_fac->LIST[cnt].age >= 18) CNVTINT(1) ENDIF
	OpPerf_fac->LIST[cnt].lwbt_peds		= IF (LWBT = 1 AND OpPerf_fac->LIST[cnt].age < 18) CNVTINT(1) ENDIF
	OpPerf_fac->LIST[cnt].lwtc			= lwtc
	OpPerf_fac->LIST[cnt].lwtc_adult    = IF (lwtc = 1 AND OpPerf_fac->LIST[cnt].age >= 18) CNVTINT(1) ENDIF
	OpPerf_fac->LIST[cnt].lwtc_peds		= IF (lwtc = 1 AND OpPerf_fac->LIST[cnt].age < 18) CNVTINT(1) ENDIF
	OpPerf_fac->LIST[cnt].ped			= IF (OpPerf_fac->LIST[cnt].age < 18) CNVTINT(1) ENDIF
 
	OpPerf_fac->dispo_admit_fac_tot = fac_adm_tot
	OpPerf_fac->dispo_dc_fac_tot = fac_dc_tot
	OpPerf_fac->lwbs_tot = lwbs_tot
	OpPerf_fac->lwbs_peds_tot = lwbs_peds_tot
	OpPerf_fac->lwbs_adult_tot = lwbs_adult_tot
	OpPerf_fac->lwbs_perc = (OpPerf_fac->lwbs_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwbs_peds_perc = (lwbs_peds_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwbs_adult_perc = (lwbs_adult_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwbt_tot = lwbt_tot
	OpPerf_fac->lwbt_peds_tot = lwbt_peds_tot
	OpPerf_fac->lwbt_adult_tot = lwbt_adult_tot
	OpPerf_fac->lwbt_perc = (OpPerf_fac->lwbt_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwbt_peds_perc = (lwbt_peds_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwbt_adult_perc = (lwbt_adult_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwtc_tot = lwtc_tot
	OpPerf_fac->lwtc_peds_tot = lwtc_peds_tot
	OpPerf_fac->lwtc_adult_tot = lwtc_adult_tot
	OpPerf_fac->lwtc_perc = (OpPerf_fac->lwtc_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwtc_peds_perc = (lwtc_peds_tot / OpPerf_fac->fac_tot)*100
	OpPerf_fac->lwtc_adult_perc = (lwtc_adult_tot / OpPerf_fac->fac_tot)*100
 
	OpPerf_fac->LIST[cnt].rfv = e.reason_for_visit
	OpPerf_fac->LIST[cnt].edrn = edrn
	OpPerf_fac->LIST[cnt].pcp = pcp_name.name_full_formatted
 
FOOT REPORT
 
	stat = alterlist(OpPerf_fac->LIST, cnt)
 
WITH NOCOUNTER
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
;***************************************
;	get patient and room information
;***************************************
 
SELECT
	 ti.encntr_id
	,tl.loc_room_cd
	,tl.location_cd
	,dept = uar_get_code_display(tl.loc_nurse_unit_cd)
	,dept_cd = tl.loc_nurse_unit_cd
	,room = rm.display
	,bed = bed.display
	,fac_group = fac.display
	,tc.tracking_group_cd
	,tl.arrive_dt_tm "@SHORTDATETIME"
FROM
	 tracking_item ti
	,(INNER JOIN tracking_locator tl ON tl.tracking_id = ti.tracking_id)
	,(INNER JOIN tracking_checkin tc ON tc.tracking_id = ti.tracking_id)
	,(INNER JOIN code_value fac ON fac.code_value = tc.tracking_group_cd)
	,(INNER JOIN code_value bed ON bed.code_value = tl.loc_bed_cd)
	,(INNER JOIN code_value rm ON rm.code_value = tl.loc_room_cd
			;eliminate checkout location
			AND rm.code_value NOT IN
				(SELECT cv.code_value
				 FROM code_value cv
				 WHERE cv.cdf_meaning = "CHECKOUT"
				 	AND cv.code_set = 220
				 	AND cv.display = "CHKT"
				 	AND cv.active_ind = 1
				 )
	  )
WHERE	expand(num, 1, size(OpPerf_fac->LIST, 5), ti.encntr_id, OpPerf_fac->LIST[num].encntr_id);, ti.person_id, OpPerf_fac->LIST[num].person_id)
		;join on the department code_value and room
	AND expand(num, 1, size(OpPerf_room->LIST, 5), rm.display, OpPerf_room->LIST[num].room, tl.loc_nurse_unit_cd, OpPerf_room->LIST[num].dept_cd)
 
ORDER BY
	 ti.encntr_id
	,tl.arrive_dt_tm asc
 
HEAD REPORT
 
	cnt			= 0
	idx			= 0
 
DETAIL
 
	;get patient position
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), ti.encntr_id, OpPerf_fac->LIST[cnt].encntr_id)
 
	IF(idx>0)
		OpPerf_fac->list[idx].room = room
	ENDIF
 
WITH nocounter, separator=" ", format, expand = 1
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
;***************************************
;GETTING EMS ARRIVAL COUNT AND ESI LEVEL
;***************************************
 
SELECT DISTINCT INTO "NL:"
	 ems = CNVTINT(1);IF(ce.event_cd = EMS_var) 1 ELSE 0 ENDIF 	;CNVTINT(1)
 
FROM
	 clinical_event ce
 
PLAN ce
WHERE
		expand(num, 1, size(OpPerf_fac->LIST, 5), ce.encntr_id, OpPerf_fac->LIST[num].encntr_id, ce.person_id, OpPerf_fac->LIST[num].person_id)
	AND ce.event_cd IN (EMS_var,ESI_var)
	AND ce.valid_until_dt_tm >= CNVTDATETIME(SYSDATE)
	AND ce.event_end_dt_tm < CNVTDATETIME(SYSDATE)
	AND ce.event_tag != "In Error"
;	AND (
;		CNVTUPPER(ce.result_val) = "*AMBULANCE*" OR
;		CNVTUPPER(ce.event_title_text) = "TRACKING ACUITY - TRACKING"
;		)
	AND (
		CNVTUPPER(ce.event_title_text) = "LYNX MODE OF ARRIVAL"
		OR
		CNVTUPPER(ce.event_title_text) = "TRACKING ACUITY - TRACKING"
		)
 
ORDER BY
	 ce.encntr_id
	,ce.event_cd
	,ce.clinical_event_id DESC	;get last charting
 
HEAD REPORT
 
	cnt			= 0
	idx			= 0
	ems_fac_tot	= 0
 
HEAD ce.event_cd
	NULL
 
HEAD ce.encntr_id
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), ce.encntr_id, OpPerf_fac->LIST[cnt].encntr_id, ce.person_id, OpPerf_fac->LIST[cnt].person_id)
 
	IF(ce.event_cd = EMS_var)
		IF(CNVTUPPER(ce.result_val) = "*AMBULANCE*")
			OpPerf_fac->LIST[idx].ems = ems
			ems_fac_tot = ems_fac_tot + ems	;totaling the ems arrivals
		ENDIF
		OpPerf_fac->LIST[idx].moa = ce.result_val
	ELSE
		OpPerf_fac->LIST[idx].esi = SUBSTRING(1,1,ce.result_val)
	ENDIF
 
FOOT REPORT
 
	OpPerf_fac->ems_fac_tot = ems_fac_tot
 
WITH nocounter, separator=" ", format, expand = 1
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
;*****************************************************
;pull tracking events
;	*	getting the arrival to triage date difference.
;*****************************************************
 
 
SELECT DISTINCT INTO "NL:"
FROM
	tracking_checkin tc
	,(INNER JOIN tracking_item ti ON
			ti.tracking_id = tc.tracking_id
		AND ti.active_ind = 1
	 )
	,(INNER JOIN tracking_event	te ON
			te.tracking_id = ti.tracking_id
		AND te.tracking_group_cd = tc.tracking_group_cd
		AND te.active_ind = 1
	 )
	,(INNER JOIN track_event te2 ON
			te2.track_event_id = te.track_event_id
		AND te2.tracking_group_cd = tc.tracking_group_cd
		AND te2.active_ind = 1
		AND te2.event_use_mean_cd IN (bed_time_var,triage_start_var,triage_stop_var)
	 )
WHERE
		expand(num, 1, size(OpPerf_fac->LIST, 5), ti.encntr_id, OpPerf_fac->LIST[num].encntr_id)
	AND tc.active_ind = 1
	AND tc.tracking_group_cd IN (FLMC_TRKGRP_VAR,FSR_TRKGRP_VAR,LCMC_TRKGRP_VAR,MHHS_TRKGRP_VAR,MMC_TRKGRP_VAR,PWMC_TRKGRP_VAR,RMC_TRKGRP_VAR)
 
ORDER BY
	 ti.encntr_id
	,te.tracking_id
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
DETAIL
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), ti.encntr_id, OpPerf_fac->LIST[cnt].encntr_id)
 
	IF(te2.event_use_mean_cd = bed_time_var)
		OpPerf_fac->list[idx].bed_dt = te.complete_dt_tm
		OpPerf_fac->LIST[idx].arrival_to_bed = DATETIMEDIFF(OpPerf_fac->list[idx].bed_dt,OpPerf_fac->LIST[idx].chkin_dt,4)
	ENDIF
 
	IF(te2.event_use_mean_cd = triage_start_var)
		OpPerf_fac->LIST[idx].triage_start_dt	= te.onset_dt_tm
		OpPerf_fac->LIST[idx].arrival_to_triage = DATETIMEDIFF(OpPerf_fac->LIST[idx].triage_start_dt,OpPerf_fac->LIST[idx].chkin_dt,4)
 	ENDIF
 
	IF(te2.event_use_mean_cd = triage_stop_var)
		OpPerf_fac->LIST[idx].triage_stop_dt	= te.requested_dt_tm
 	ENDIF
 
 OpPerf_fac->LIST[idx].triage_startstop = DATETIMEDIFF(OpPerf_fac->LIST[idx].triage_stop_dt,OpPerf_fac->LIST[idx].triage_start_dt,4)
 
WITH nocounter, separator=" ", format, expand = 1
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
;**********************************
;pull patient seen by MD time stamp
;**********************************
 
SELECT DISTINCT INTO "NL:"
	 eid = ce.encntr_id
	,md_ts = ce.event_end_dt_tm	;MAX(ce.event_end_dt_tm) KEEP (DENSE_RANK FIRST ORDER BY ce.event_end_dt_tm) OVER (PARTITION BY ce.encntr_id)
FROM
	clinical_event ce
 
PLAN ce
WHERE
		expand(num, 1, size(OpPerf_fac->LIST, 5), ce.encntr_id, OpPerf_fac->LIST[num].encntr_id, ce.person_id, OpPerf_fac->LIST[num].person_id)
	AND ce.event_cd = MD_time_var
	AND ce.valid_until_dt_tm >= SYSDATE
	AND ce.event_end_dt_tm < SYSDATE
 
ORDER BY
	 ce.encntr_id
	,ce.event_end_dt_tm	;get first date
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
HEAD ce.encntr_id
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), ce.encntr_id, OpPerf_fac->LIST[cnt].encntr_id, ce.person_id, OpPerf_fac->LIST[cnt].person_id)
 
	OpPerf_fac->list[idx].md_ts 		= md_ts
	OpPerf_fac->list[idx].bed_to_md 	= DATETIMEDIFF(OpPerf_fac->list[idx].md_ts,OpPerf_fac->list[idx].bed_dt,4)
	OpPerf_fac->list[idx].arrival_to_md = DATETIMEDIFF(OpPerf_fac->list[idx].md_ts,OpPerf_fac->list[idx].chkin_dt,4)
 
WITH nocounter, separator=" ", format, expand = 1
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
;*************
;pull provider
;*************
 
SELECT DISTINCT INTO "NL:"
	 MD = REPLACE(REPLACE(REPLACE(REPLACE(INITCAP(NULLVAL(md.pri_prov,md.sec_prov))," Md"," MD")," Pa"," PA")," Do"," DO")," Apn"," APN")
	,md.eid
FROM
	((SELECT
		 eid = ti.encntr_id
		,pri_prov = MAX(pprov.name_full_formatted) OVER(PARTITION BY ti.encntr_id)
		,sec_prov = MAX(sprov.name_full_formatted) OVER(PARTITION BY ti.encntr_id)
	FROM
		tracking_checkin tc
		,(INNER JOIN tracking_item ti ON tc.tracking_id = ti.tracking_id AND ti.active_ind = 1)
		,(LEFT JOIN prsnl pprov ON tc.primary_doc_id = pprov.person_id AND pprov.active_ind = 1)
		,(LEFT JOIN prsnl sprov ON tc.secondary_doc_id = sprov.person_id AND sprov.active_ind = 1)
	WHERE
			expand(num, 1, size(OpPerf_fac->LIST, 5), ti.encntr_id, OpPerf_fac->LIST[num].encntr_id)
;		AND tc.checkin_dt_tm BETWEEN cnvtdatetime("09-AUG-2020 00:00") AND cnvtdatetime("09-AUG-2020 23:59")
;		AND tc.tracking_group_cd =     2553913775.00
	WITH SQLTYPE("f8","vc","vc")
	)MD)
ORDER BY
	md.eid
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
HEAD md.eid
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), md.eid, OpPerf_fac->LIST[cnt].encntr_id)
 
	OpPerf_fac->list[idx].provider = md
 
WITH nocounter, separator=" ", format, expand = 1
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
 
;***************************
;GET DECISION TO DISPOSITION
;***************************
 
SELECT DISTINCT INTO "NL:"
	 eid = o.encntr_id
	,dtd_dt = o.orig_order_dt_tm;MAX(o.orig_order_dt_tm) KEEP (DENSE_RANK FIRST ORDER BY o.orig_order_dt_tm) OVER (PARTITION BY o.encntr_id)
FROM
	 orders o
PLAN o
WHERE
			expand(num, 1, size(OpPerf_fac->LIST, 5), o.person_id, OpPerf_fac->LIST[num].person_id, o.encntr_id, OpPerf_fac->LIST[num].encntr_id)
		AND o.person_id > 0.0						;001
		AND o.catalog_cd in (DISPO_COND_ADMIT_VAR,DISPO_COND_TRANS_VAR,DISPO_COND_DISCH_VAR);2558812301, 2561117261, 2561117857)
		AND o.active_ind = 1
ORDER BY
	  o.encntr_id
	 ,o.orig_order_dt_tm
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
HEAD o.encntr_id
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), o.person_id, OpPerf_fac->LIST[cnt].person_id, o.encntr_id, OpPerf_fac->LIST[cnt].encntr_id)
 
	OpPerf_fac->list[idx].dtd_dt = dtd_dt	;get all decision to dispositions
	OpPerf_fac->LIST[idx].mdtodtd = DATETIMEDIFF(OpPerf_fac->list[idx].dtd_dt,OpPerf_fac->list[idx].md_ts,4) ;get all MD to DTD
	OpPerf_fac->LIST[idx].dtdtodc = DATETIMEDIFF(OpPerf_fac->list[idx].chkout_dt,OpPerf_fac->list[idx].dtd_dt,4)	;get all DTD to DC
 
	IF(OpPerf_fac->list[idx].dispo_type = "A")
		OpPerf_fac->list[idx].adm_dtd_dt = OpPerf_fac->list[idx].dtd_dt
		OpPerf_fac->LIST[idx].mdtodtd_adm = DATETIMEDIFF(OpPerf_fac->list[idx].adm_dtd_dt,OpPerf_fac->list[idx].md_ts,4)
		OpPerf_fac->LIST[idx].dtdtodc_adm = DATETIMEDIFF(OpPerf_fac->list[idx].chkout_dt,OpPerf_fac->list[idx].adm_dtd_dt,4)
	ENDIF
 
	IF(OpPerf_fac->list[idx].dispo_type = "D")
		OpPerf_fac->list[idx].dc_dtd_dt = OpPerf_fac->list[idx].dtd_dt
		OpPerf_fac->LIST[idx].mdtodtd_dc = DATETIMEDIFF(OpPerf_fac->list[idx].dc_dtd_dt,OpPerf_fac->list[idx].md_ts,4)
		OpPerf_fac->LIST[idx].dtdtodc_dc = DATETIMEDIFF(OpPerf_fac->list[idx].chkout_dt,OpPerf_fac->list[idx].dc_dtd_dt,4)
	ENDIF
 
WITH nocounter, separator=" ", format, expand = 1
 
 
;CALL ECHORECORD(OpPerf_fac)
;GO TO exitscript
 
SELECT
	bh = CNVTINT(1)
FROM
	 encounter e
	,orders o
WHERE
		expand(num, 1, size(OpPerf_fac->LIST, 5), e.encntr_id, OpPerf_fac->LIST[num].encntr_id)
	AND o.encntr_id = e.encntr_id
	AND o.person_id > 0.0
	and (o.pathway_catalog_id = BH_Powerplan_var ;in (2560333213.00)
		OR
		o.catalog_cd IN (PSO1_var,	; PSO Admit to Inpatient
						PSO2_var)
		)
;	and o.orig_order_dt_tm between cnvtdatetime("01-jun-2020 00:00") AND cnvtdatetime("19-jul-2020 23:59")
ORDER BY
	e.encntr_id
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
HEAD e.encntr_id
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), e.encntr_id, OpPerf_fac->LIST[cnt].encntr_id)
 
	IF(o.pathway_catalog_id = BH_Powerplan_var)
		OpPerf_fac->list[idx].bh = bh
	ELSE
		OpPerf_fac->list[idx].pso_dttm = o.orig_order_dt_tm
	ENDIF
 
WITH nocounter, separator=" ", format, expand = 1
 
;*********************************************
;*********************************************
;	receiving facility, MD, and receiving date
;*********************************************
;*********************************************
SELECT into 'nl:'
 
FROM
	clinical_event ce
 
WHERE
		expand(num, 1, size(OpPerf_fac->LIST, 5), ce.encntr_id, OpPerf_fac->LIST[num].encntr_id, ce.person_id, OpPerf_fac->LIST[num].person_id)
	;	ce.encntr_id = 116707872
	AND	ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
	AND ce.event_end_dt_tm < CNVTDATETIME(SYSDATE)
	AND ce.event_cd IN (accepting_fac_var,isolation_var,restraint_var)
 
ORDER BY
	 ce.encntr_id
	,ce.event_cd
	,ce.performed_dt_tm
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
DETAIL
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), ce.encntr_id, OpPerf_fac->LIST[cnt].encntr_id, ce.person_id, OpPerf_fac->LIST[cnt].person_id)
 
	IF (ce.event_cd = accepting_fac_var) OpPerf_fac->LIST[idx].rfac 	= replace(replace(ce.result_val,char(10),""),char(13),"") ENDIF ;001
	IF (ce.event_cd = isolation_var) OpPerf_fac->LIST[idx].isolation	= ce.result_val ENDIF
	IF (ce.event_cd = restraint_var) OpPerf_fac->LIST[idx].restraint	= ce.result_val ENDIF
 
WITH nocounter, separator=" ", format, expand = 1
 
 
;*********************************************
;*********************************************
;	discharge diagnosis
;*********************************************
;*********************************************
 
 
SELECT INTO 'NL:'
;SELECT INTO VALUE ($OUTDEV)
	  dtcode	=	d.diag_type_cd
	, dx		=	d.diagnosis_display
FROM
	 diagnosis    d
	,(INNER JOIN nomenclature n ON n.nomenclature_id = d.nomenclature_id
		AND n.active_ind = 1
		AND d.diag_type_cd = DIAG_DISCH_VAR
	 )
WHERE
	expand(num, 1, size(OpPerf_fac->LIST, 5), d.encntr_id, OpPerf_fac->LIST[num].encntr_id)
		AND d.active_ind = 1
 
ORDER BY
	 d.encntr_id
 	,d.diagnosis_id desc
 
HEAD REPORT
 
	cnt = 0
 
	idx = 0
 
HEAD d.encntr_id
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), d.encntr_id, OpPerf_fac->LIST[cnt].encntr_id)
 
	desc_var = fillstring(300," ")
 
	desc_out = fillstring(300," ")
 
DETAIL
 
	desc_out = d.diagnosis_display
 
	desc_var = build2(TRIM(desc_var),TRIM(desc_out),",")
 
FOOT d.encntr_id
 
	OpPerf_fac->list[idx].dc_dx = REPLACE(TRIM(desc_var),",","",2)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
 
/************************************************************/
/************************************************************/
/*	get PSO order date/time and first NON-ED bed date/time	*/
/************************************************************/
/************************************************************/
 
SELECT INTO 'NL:'
FROM
	 encntr_loc_hist t
	,dummyt dt
PLAN t WHERE
		expand(num, 1, size(OpPerf_fac->LIST, 5), t.encntr_id, OpPerf_fac->LIST[num].encntr_id)
JOIN dt WHERE UAR_GET_CODE_DISPLAY(t.loc_nurse_unit_cd) NOT IN ("* ED *","* EB *","* QE *")
ORDER BY
	 t.encntr_id
	,t.transaction_dt_tm asc
 
HEAD REPORT
 
	cnt = 0
	idx = 0
 
HEAD t.encntr_id
 
	idx = locateval(cnt, 1, size(OpPerf_fac->LIST, 5), t.encntr_id, OpPerf_fac->LIST[cnt].encntr_id)
 
	OpPerf_fac->list[idx].first_nonED_bed		= BUILD(UAR_GET_CODE_DISPLAY(t.loc_nurse_unit_cd),"-",UAR_GET_CODE_DISPLAY(t.loc_room_cd),"-",UAR_GET_CODE_DISPLAY(t.loc_bed_cd))
	OpPerf_fac->list[idx].first_nonED_bed_dt	= t.transaction_dt_tm	;003
 
WITH nocounter, separator=" ", format, expand = 1
 
 
;============================
;============================
; REPORT OUTPUT
;============================
;============================
 
select ;distinct
  into value(output_var)
 
			 patient_id					= OpPerf_fac->LIST[d.seq].fin
			,medrec_id					= OpPerf_fac->LIST[d.seq].mrn
			,arrival_dttm				= FORMAT(OpPerf_fac->LIST[d.seq].chkin_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,decision_dttm				= FORMAT(OpPerf_fac->LIST[d.seq].dtd_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,LOS						= OpPerf_fac->LIST[d.seq].los
			,age						= OpPerf_fac->LIST[d.seq].age
			,sex						= OpPerf_fac->LIST[d.seq].sex
			,chief_complaint			= OpPerf_fac->LIST[d.seq].rfv
			,triage_category			= OpPerf_fac->LIST[d.seq].esi
			,disposition				= OpPerf_fac->LIST[d.seq].disposition
			,fac						= OpPerf_fac->LIST[d.seq].fac_name
			,dept_id					= OpPerf_fac->LIST[d.seq].dept_id
			,disposition_dttm			= FORMAT(OpPerf_fac->LIST[d.seq].chkout_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,room_id					= TRIM(concat(OpPerf_fac->LIST[d.seq].room,"         "))
			,assigned_bed_ddt			= FORMAT(OpPerf_fac->LIST[d.seq].bed_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,misc_3						= ""
			,chart_dt					= ""
			,triage_ddt					= FORMAT(OpPerf_fac->LIST[d.seq].triage_start_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,triage_staff_seq			= ""
			,pcmd						= TRIM(OpPerf_fac->LIST[d.seq].pcp)
			,edrn						= TRIM(OpPerf_fac->LIST[d.seq].edrn)
			,staff_edmd					= TRIM(OpPerf_fac->LIST[d.seq].provider)
			,dispo_type					= OpPerf_fac->LIST[d.seq].dispo_type
			,md_ts						= FORMAT(OpPerf_fac->LIST[d.seq].md_ts,"MM/DD/YYYY hh:mm:ss;;d")
			,moa						= OpPerf_fac->LIST[d.seq].moa
			,bed_id						= ""
			,access_id					= ""
			,group_id					= ""
			,triage_stop_dt				= FORMAT(OpPerf_fac->LIST[d.seq].triage_stop_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,ems						= OpPerf_fac->LIST[d.seq].ems
			,bh							= OpPerf_fac->LIST[d.seq].bh
			,ped						= OpPerf_fac->LIST[d.seq].ped
			,HUC_disposition			= OpPerf_fac->LIST[d.seq].HUC_disposition
			,trans_to_fac				= OpPerf_fac->LIST[d.seq].rfac
			,star_dc					= FORMAT(OpPerf_fac->LIST[d.seq].star_dc,"MM/DD/YYYY hh:mm:ss;;d")
			,isolation					= OpPerf_fac->LIST[d.seq].isolation
			,restraint					= OpPerf_fac->LIST[d.seq].restraint
			,dc_diag					= OpPerf_fac->LIST[d.seq].dc_dx
			,pso_dttm					= FORMAT(OpPerf_fac->LIST[d.seq].pso_dttm,"MM/DD/YYYY hh:mm:ss;;d")
			,first_nonED_bed_dttm		= FORMAT(OpPerf_fac->LIST[d.seq].first_nonED_bed_dt,"MM/DD/YYYY hh:mm:ss;;d")
			,first_nonED_bed			= OpPerf_fac->LIST[d.seq].first_nonED_bed	;003
 
		FROM
			(dummyt d WITH seq = value(size(OpPerf_fac->LIST,5)))
 
		PLAN d
 
   with nocounter, separator = "|", format, time = 240
 
 
#exitscript
 
end
go

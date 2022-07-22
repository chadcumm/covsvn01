/************************** Program Header *******************************************
Development Date:  	7/17/2018
 
Author:  			Alix Govatsos
 
Requestor/ Site:	Lori Myers
WO/CHG Number:
 
Report Description: Retreive a list of orders task type "Continuous Infusion Billing"
 
/*************************************************************************************
*                       MODIFICATION CONTROL LOG		                             *
**************************************************************************************
*                                                                                    *
Mod Date       Worker        		Comment                                          *
--- ---------- --------------------	-------------------------------------------------*
001 07/17/18   Alix Govatsos		Initial Development
002 10/16/18   Todd A. Blanchard	Added temp bed exclusions.
003 11/14/18   Todd A. Blanchard	Added temp bed exclusions to final output.
**************************************************************************************/
 
DROP PROGRAM COV_PHA_INFUSION_TASK_ALL:dba GO
CREATE PROGRAM COV_PHA_INFUSION_TASK_ALL:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0)
	, "Beginning Date:" = "SYSDATE"
	, "Ending Date:" = "SYSDATE"
 
with OUTDEV, Pfac, beg_date, end_date
 
 
/***************************************************************************************
* Prompt Evaluation																	   *
***************************************************************************************/
 
IF ($BEG_DATE = "CURDATE-1")
	SET BEG_DATE_QUAL =  FORMAT(CNVTDATETIME(CURDATE-1, 0), ";;Q")
ELSE
   SET BEG_DATE_QUAL = $BEG_DATE
ENDIF
 
IF ($END_DATE = "CURDATE-1")
	SET END_DATE_QUAL =  FORMAT(CNVTDATETIME(CURDATE-1, 2359), ";;Q")
ELSE
   SET END_DATE_QUAL = $END_DATE
ENDIF
 
 
 ; location used for the exam location
if(substring(1,1,reflect(parameter(parameter2($pFAC ),0))) = "L") ;multiple dispositions were selected
	set FAC_VAR = "in"
	elseif(parameter(parameter2($pFAC ),1) = 0.0) ;all (any) dispositions were selected
		set FAC_VAR = "!="
	else ;a single value was selected
		set FAC_VAR = "="
endif
 
 
/***************************************************************************************
* Variable and Record Definition													   *
***************************************************************************************/
 
RECORD rDATA(
	1 ENC[*]
		2 NURSE_UNIT		= C50
		2 NURSE_UNIT_CD		= F8
		2 ROOM				= C20
		2 BED			 	= C20
		2 PATIENT_NAME		= C100
		2 FIN				= C30
		2 MRN				= C15
		2 ENCNTR_ID			= F8
		2 PERSON_ID			= F8
		2 PAT_TYPE			= c150
		2 ADMIT_DATE		= C20
		2 ORD[*]
			3 ORDER_MNEMONIC	= C100
			3 ORDER_ID			= F8
			3 ADMIN_START_DATE	= C20
			3 INFUSION_TASK_DATE= C20
			3 ADMIN_PRSNL		= C100
			3 TASK_STATUS		= C50
)WITH PUBLIC
 
 
DECLARE OVERDUE_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",79,"OVERDUE"))
DECLARE PENDING_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",79,"PENDING"))
DECLARE INFUSEBILL_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",6026,"INFUSEBILL"))
DECLARE AUTH_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",8,"AUTH"))
DECLARE MODIFIED_CD		= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",8,"MODIFIED"))
DECLARE CENSUS_CD		= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",339,"CENSUS"))
DECLARE FAC_TYPE_CD		= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",222,"FACILITY"))
declare fin_encntr_alias_type_cd = f8 with constant(uar_get_code_by("MEANING", 319, "FIN NBR"))
declare mrn_encntr_alias_type_cd = f8 with constant(uar_get_code_by("MEANING", 319, "MRN"))
 
 
;contributor source
DECLARE COV_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",73,"COVENANT"))
 
 
SET IDX = 0
SET POS = 0
 
CALL ECHO(FORMAT(CNVTDATETIME(BEG_DATE_QUAL),"@SHORTDATETIME"))
CALL ECHO(FORMAT(CNVTDATETIME(END_DATE_QUAL),"@SHORTDATETIME"))
 
 
/***************************************************************************************
* DATA GATHERING QUERIES															   *
***************************************************************************************/
 
SELECT
	fin_nbr = cnvtalias(fin.alias, fin.alias_pool_cd)
	, mrn_nbr = cnvtalias(mrn.alias, mrn.alias_pool_cd)
	, pat_type = uar_get_code_display(e.encntr_type_cd)
 
FROM
	ENCNTR_LOC_HIST ELH
	, ENCOUNTER E
	, code_value_outbound cvo
	, encntr_alias mrn
	, encntr_alias fin
	, ORDERS O
	, PERSON P
	, TASK_ACTIVITY TA
	, CLINICAL_EVENT CE
	, CE_MED_RESULT CMR
	, PRSNL PR
 
PLAN ELH
	WHERE ELH.END_EFFECTIVE_DT_TM > CNVTDATETIME(BEG_DATE_QUAL)
	AND ELH.BEG_EFFECTIVE_DT_TM < CNVTDATETIME(END_DATE_QUAL)
    AND operator(ELH.loc_facility_cd, FAC_VAR, $pFAC)
	AND ELH.LOC_NURSE_UNIT_CD IN (
		2552508789, 2552516975, 2552503845, 2552503877, 2552507525, 2552509009, 2552509149, 2552503897, 2550798939, 2552507837,
		2552509417, 2552507961, 2552512729, 2552517431, 2552509721, 2552509989, 2552508061, 2552518355, 2552510409, 2552518651,
		2552518871, 2552518891, 2552519167, 2552519315, 2552519611, 2552511121, 2552511237, 2552511369, 2552503829, 2552508305,
		2552520299, 2552520343, 2557548461, 2552511841, 2619633665, 2552508361, 2552513125, 2552520747, 2582188655, 2557555119,
		2552513193, 2561582141, 2552508441, 2552507117, 38616903, 2552513857, 2557553045, 2552503797, 2552504293, 2552504537,
		2552504909, 2552505277, 2552505625, 2552505741, 2552505957, 2555128693, 2555130189, 2576089705, 2552512545
	)
 
;		; TODO: Determine if this is needed.
 
;	AND ELH.LOC_NURSE_UNIT_CD IN (
 
 
;		select * from code_value cv
;		where
;			cv.code_set = 220
;			and cv.cdf_meaning = "NURSEUNIT"
;			and (
;				cv.display like "FLMC*"
;				or cv.display like "FSR*"
;				or cv.display like "LCMC*"
;				or cv.display like "MHHS*"
;				or cv.display like "MMC*"
;				or cv.display like "PW*"
;				or cv.display like "RMC*"
;			)
;			and cv.display not like "*TEMP*"
;			and cv.display not like "*zzz*"
;			and cv.active_ind = 1
;	)
	;002
	AND ELH.LOC_NURSE_UNIT_CD NOT IN (
		; exclusions
		select cv.code_value
		from code_value cv
		where
			cv.code_set = 220
			and cv.cdf_meaning = "NURSEUNIT"
			and cv.display like "*TEMP*"
			and cv.active_ind = 1
	)
	;
 
JOIN E
	WHERE E.ENCNTR_ID = ELH.ENCNTR_ID
	;003
	AND E.LOC_NURSE_UNIT_CD NOT IN (
		; exclusions
		select cv.code_value
		from code_value cv
		where
			cv.code_set = 220
			and cv.cdf_meaning = "NURSEUNIT"
			and cv.display like "*TEMP*"
			and cv.active_ind = 1
	)
	;
 
join cvo
	where elh.encntr_type_cd = cvo.code_value
	and cvo.code_set = 71
	and cvo.contributor_source_cd = cov_cd
	and cvo.alias = "NV"
 
JOIN P
	WHERE P.PERSON_ID = E.PERSON_ID
	AND P.ACTIVE_IND = 1
	AND P.BEG_EFFECTIVE_DT_TM < CNVTDATETIME(CURDATE,CURTIME3)
	AND P.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
 
join mrn
   where mrn.encntr_id = e.encntr_id
     and mrn.active_ind = 1
     and mrn.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
     and mrn.encntr_alias_type_cd = mrn_encntr_alias_type_cd
 
join fin
   where fin.encntr_id = e.encntr_id
     and fin.active_ind = 1
     and fin.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
     and fin.encntr_alias_type_cd = fin_encntr_alias_type_cd
 
JOIN TA
	WHERE TA.TASK_TYPE_CD = INFUSEBILL_CD
	AND TA.ENCNTR_ID = E.ENCNTR_ID
 
JOIN O
	WHERE O.ORDER_ID = TA.ORDER_ID
	AND O.CURRENT_START_DT_TM BETWEEN CNVTDATETIME(BEG_DATE_QUAL) AND CNVTDATETIME(END_DATE_QUAL)
 
JOIN CE
	WHERE CE.ORDER_ID = O.ORDER_ID
 
JOIN CMR
	WHERE CMR.EVENT_ID = CE.EVENT_ID
 
JOIN PR
	WHERE PR.PERSON_ID = CE.PERFORMED_PRSNL_ID
 
ORDER BY E.ENCNTR_ID
		,O.ORDER_ID
		,CMR.ADMIN_START_DT_TM DESC
 
HEAD REPORT
	CNT = 0
 
HEAD E.ENCNTR_ID
	O_CNT = 0
	CNT = CNT + 1
	STAT = ALTERLIST(rDATA->ENC,CNT)
 
	rDATA->ENC[CNT].PATIENT_NAME	= P.NAME_FULL_FORMATTED
 	rDATA->ENC[CNT].ENCNTR_ID		= E.ENCNTR_ID
 	rDATA->ENC[CNT].PERSON_ID		= P.PERSON_ID
 	rDATA->ENC[CNT].NURSE_UNIT		= UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD)
 	rDATA->ENC[CNT].NURSE_UNIT_CD	= E.LOC_NURSE_UNIT_CD
	rDATA->ENC[CNT].ROOM			= UAR_GET_CODE_DISPLAY(E.LOC_ROOM_CD)
	rDATA->ENC[CNT].BED				= UAR_GET_CODE_DISPLAY(E.LOC_BED_CD)
 	rDATA->ENC[CNT].MRN				= mrn_nbr
 	rDATA->ENC[CNT].FIN				= fin_nbr
 	rDATA->ENC[CNT].ADMIT_DATE		= FORMAT(E.REG_DT_TM,"@SHORTDATETIME")
 	rDATA->ENC[CNT].PAT_TYPE		= pat_type
 
HEAD O.ORDER_ID
	O_CNT = O_CNT +1
	STAT = ALTERLIST(rDATA->ENC[CNT]->ORD,O_CNT)
 
	rDATA->ENC[CNT]->ORD[O_CNT].ORDER_MNEMONIC		= O.ORDERED_AS_MNEMONIC
	rDATA->ENC[CNT]->ORD[O_CNT].ORDER_ID			= O.ORDER_ID
	rDATA->ENC[CNT]->ORD[O_CNT].INFUSION_TASK_DATE 	= FORMAT(TA.TASK_DT_TM,"@SHORTDATETIME")
	rDATA->ENC[CNT]->ORD[O_CNT].TASK_STATUS			= UAR_GET_CODE_DISPLAY(TA.TASK_STATUS_CD)
 	rDATA->ENC[CNT]->ORD[O_CNT].ADMIN_PRSNL			= PR.NAME_FULL_FORMATTED
 
HEAD CMR.ADMIN_START_DT_TM
	rDATA->ENC[CNT]->ORD[O_CNT].ADMIN_START_DATE = FORMAT(CMR.ADMIN_START_DT_TM,"@SHORTDATETIME")
 
WITH TIME = 955
 
 
/***************************************************************************************
* FINAL QUERY																		   *
***************************************************************************************/
SELECT INTO $OUTDEV
	NURSE_UNIT = RDATA->ENC[D1.SEQ].NURSE_UNIT
	, ROOM = CONCAT(TRIM(RDATA->ENC[D1.SEQ].ROOM),"-",TRIM(RDATA->ENC[D1.SEQ].BED))
	, PATIENT_NAME = RDATA->ENC[D1.SEQ].PATIENT_NAME
	, FIN = RDATA->ENC[D1.SEQ].FIN
	, MRN = RDATA->ENC[D1.SEQ].MRN
	, PAT_TYPE = RDATA->ENC[D1.SEQ].PAT_TYPE
	, ADMIT_DATE = RDATA->ENC[D1.SEQ].ADMIT_DATE
	, ORDER_MNEMONIC = RDATA->ENC[D1.SEQ].ORD[D2.SEQ].ORDER_MNEMONIC
	, ADMIN_START_DATE = RDATA->ENC[D1.SEQ].ORD[D2.SEQ].ADMIN_START_DATE
	, ADMIN_PERSONNEL = RDATA->ENC[D1.SEQ].ORD[D2.SEQ].ADMIN_PRSNL
	, INFUSION_BILLING_TASK_DATE = RDATA->ENC[D1.SEQ].ORD[D2.SEQ].INFUSION_TASK_DATE
 	, TASK_STATUS = RDATA->ENC[D1.SEQ].ORD[D2.SEQ].TASK_STATUS
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(RDATA->ENC, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1 WHERE MAXREC(D2, SIZE(RDATA->ENC[D1.SEQ].ORD, 5))
JOIN D2
 
ORDER BY
	NURSE_UNIT
	, PATIENT_NAME
	, ADMIN_START_DATE
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
#EXIT_REPORT
CALL ECHORECORD(rDATA)
END GO
 

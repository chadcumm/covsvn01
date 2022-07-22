/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	08/17/2021
Program Title	:	cov_amb_bmi_review_rpt
Source File     :	cov_amb_bmi_review_rpt.prg
Object Name     :	cov_amb_bmi_review_rpt
Directory       :	cust_script
 
Purpose         : 	Allow the users to fix BMI issues before data is sent to
                    vendors to meet Vendor Measures
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     08/17/2021  Dawn Greer, DBA         Original Release - CR 11064
 
************************************************************************************/
drop program cov_amb_bmi_review_rpt go
create program cov_amb_bmi_review_rpt
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Select Facility" = VALUE(0.0        )
	, "Select Appt Begin Date" = "SYSDATE"
	, "Select Appt End Date" = "SYSDATE"
 
with OUTDEV, FAC, BDATE, EDATE
 
RECORD exp_data (
	1 output_cnt = i4
	1 p_facility = c100
	1 p_start_date = vc
	1 p_end_date = vc
	1 list[*]
	    2 Facility  = C150
	    2 Provider = C150
	    2 Patient = C150
	    2 Patient_DOB = VC
	    2 Age_as_of_DOS = VC
	    2 FIN = VC
	    2 DOS = VC
	    2 Policy_ID = VC
	    2 Insurance = C150
	    2 Problem_Code = VC
	    2 Problem_Desc = C150
	    2 Weight_Loinc = VC
	    2 Weight_Value = VC
	    2 Weight_Units = VC
	    2 Weight_Report_Date = VC
	    2 Height_Loinc = VC
	    2 Height_Value = VC
	    2 Height_Units = VC
	    2 Height_Report_Date = VC
	    2 Systolic_Loinc = VC
	    2 Systolic_Value = VC
	    2 Systolic_Units = VC
	    2 Systolic_Report_Date = VC
	    2 Diastolic_Loinc = VC
	    2 Diastolic_Value = VC
	    2 Diastolic_Units = VC
	    2 Diastolic_Report_Date = VC
	    2 BMI_Measured_Loinc = VC
	    2 BMI_Measured_Value = VC
	    2 BMI_Measured_Units = VC
	    2 BMI_Measured_Report_Date = VC
	    2 BMI_Percentile_Loinc = VC
	    2 BMI_Percentile_Value = VC
	    2 BMI_Percentile_Units = VC
	    2 BMI_Percentile_Report_Date = VC
	)
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE faclist = c4000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
 
/**********************************************************
Get CMG Facility Data
***********************************************************/
CALL ECHO ("Get Facility Prompt Data")
 
SELECT DISTINCT facnum = CNVTSTRING(org.organization_id)
FROM organization org, organization_alias oa
WHERE org.organization_id = oa.organization_id
AND org.active_ind = 1
AND org.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND org.data_status_cd = 25.00 /*Auth*/
AND oa.active_ind = 1
AND oa.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND oa.org_alias_type_cd = 1130.00 /*Encounter organization Alias*/
ORDER BY CNVTUPPER(TRIM(org.org_name,3))
 
HEAD REPORT
	faclist = FILLSTRING(2000,' ')
 	faclist = '('
DETAIL
	faclist = BUILD(BUILD(faclist, facnum), ', ')
 
FOOT REPORT
	faclist = BUILD(faclist,')')
	faclist = REPLACE(faclist,',','',2)
 
WITH nocounter
 
;Facility Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($FAC),0))) = "L")		;multiple options selected
	SET facprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($FAC),0))))
 
	FOR (i = 1 TO num)
		SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),i))
		SET facprompt = BUILD(facprompt,facitem)
		IF (i != num)
			SET facprompt = BUILD(facprompt, ",")
		ENDIF
	ENDFOR
	SET facprompt = BUILD(facprompt, ")")
	SET facprompt = BUILD("org.organization_id IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($FAC),1)= 0.00)  ;any was selected
	SET facprompt = BUILD("org.organization_id IN ", faclist)
ELSE 	;single value selected
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("org.organization_id = ", facitem)
ENDIF
 
; Get Facility prompt data selected
SELECT DISTINCT facname = TRIM(org.org_name)
, facnum = CNVTSTRING(org.organization_id)
FROM organization org, organization_alias oa
WHERE org.organization_id = oa.organization_id
AND org.active_ind = 1
AND org.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND org.data_status_cd = 25.00 /*Auth*/
AND oa.active_ind = 1
AND oa.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND oa.org_alias_type_cd = 1130.00 /*Encounter organization Alias*/
AND PARSER(facprompt)
ORDER BY CNVTUPPER(TRIM(org.org_name,3))
 
HEAD REPORT
	facnamelist = FILLSTRING(2000,' ')
 
DETAIL
	facnamelist = BUILD(BUILD(facnamelist, facname), ', ')
 
FOOT REPORT
	facnamelist = REPLACE(facnamelist,',','',2)
	exp_data->p_facility = EVALUATE2(IF(PARAMETER(PARAMETER2($FAC),1) = 0.0) "Facilities: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($FAC),0))) = "L") CONCAT("Facilities: ",TRIM(facnamelist,3))
		ELSE CONCAT("Facilities: ",TRIM(facname,3)) ENDIF)
 
WITH nocounter
 
CALL ECHO ("Get the Other Prompts")
/**************************************************************
; Other Prompts
**************************************************************/
 
SELECT INTO "NL:"
FROM DUMMYT d
 
HEAD REPORT
	exp_data->p_start_date = CONCAT("Begin: ", FORMAT(CNVTDATE2($bdate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 00:00")
	exp_data->p_end_date = CONCAT("End: ", FORMAT(CNVTDATE2($edate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 23:59")
WITH nocounter
 
 
CALL ECHO ("Get BMI Data")
/************************************************************************************
; Get BMI Data
*************************************************************************************/
SELECT DISTINCT
	Facility = EVALUATE2(IF (SIZE(org.org_name) = 0) " " ELSE TRIM(org.org_name,3) ENDIF)
	,Provider = EVALUATE2(IF (SIZE(prov.name_full_formatted) = 0) " " ELSE TRIM(prov.name_full_formatted,3) ENDIF)
	,Patient = EVALUATE2(IF (SIZE(pat.name_full_formatted) = 0) " " ELSE TRIM(pat.name_full_formatted,3) ENDIF)
	,Patient_DOB = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1), "MM/DD/YYYY;;q") ENDIF)
	,Age_as_of_DOS = FLOOR((DATETIMEDIFF(enc.reg_dt_tm, pat.birth_dt_tm)/365))
	,FIN = EVALUATE2(IF (SIZE(fin_nbr.alias) = 0) " " ELSE TRIM(fin_nbr.alias,3) ENDIF)
	,DOS = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "MM/DD/YYYY;;q") ENDIF)
	,Policy_ID = TRIM(enc_ins.MEMBER_NBR,3)
	,Insurance = EVALUATE2(IF (SIZE(hp_ins.plan_name) = 0) " " ELSE TRIM(hp_ins.plan_name,3) ENDIF)
	,Problem_Code = EVALUATE2(IF (SIZE(TRIM(nom_diag.source_identifier,3)) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,Problem_Desc = EVALUATE2(IF (SIZE(TRIM(nom_diag.source_string,3)) = 0) " " ELSE TRIM(nom_diag.source_string,3) ENDIF)
	,Weight_Loinc = EVALUATE2(IF (SIZE(TRIM(CEWT.result_val,3)) = 0) " " ELSE '3141-9' ENDIF)
	,Weight_Value = EVALUATE2(IF (SIZE(TRIM(CEWT.result_val,3)) = 0) " " ELSE TRIM(CEWT.result_val,3) ENDIF)
	,Weight_Units = EVALUATE2(IF (CEWT.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CEWT.result_units_cd),3) ENDIF)
	,Weight_Report_Date = EVALUATE2(IF (TRIM(CNVTSTRING(CNVTDATETIMEUTC(CEWT.event_end_dt_tm),1),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CEWT.event_end_dt_tm, "MM/DD/YYYY;;q") ENDIF)
	,Height_Loinc = EVALUATE2(IF (SIZE(TRIM(CEHT.result_val,3)) = 0) " " ELSE '3137-7' ENDIF)
	,Height_Value = EVALUATE2(IF (SIZE(TRIM(CEHT.result_val,3)) = 0) " " ELSE TRIM(CEHT.result_val,3) ENDIF)
	,Height_Units = EVALUATE2(IF (CEHT.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CEHT.result_units_cd),3) ENDIF)
	,Height_Report_Date = EVALUATE2(IF (TRIM(CNVTSTRING(CEHT.event_end_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CEHT.event_end_dt_tm,  "MM/DD/YYYY;;q") ENDIF)
	,Systolic_Loinc = EVALUATE2(IF (SIZE(TRIM(CESY.result_val,3)) = 0) " " ELSE '8480-6' ENDIF)
	,Systolic_Value = EVALUATE2(IF (SIZE(TRIM(CESY.result_val,3)) = 0) " " ELSE TRIM(CESY.result_val,3) ENDIF)
	,Systolic_Units = EVALUATE2(IF (CESY.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CESY.result_units_cd),3) ENDIF)
	,Systolic_Report_Date = EVALUATE2(IF (TRIM(CNVTSTRING(CESY.event_end_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CESY.event_end_dt_tm,  "MM/DD/YYYY;;q") ENDIF)
	,Diastolic_Loinc = EVALUATE2(IF (SIZE(TRIM(CEDI.result_val,3)) = 0) " " ELSE '8462-4' ENDIF)
	,Diastolic_Value = EVALUATE2(IF (SIZE(TRIM(CEDI.result_val,3)) = 0) " " ELSE TRIM(CEDI.result_val,3) ENDIF)
	,Diastolic_Units = EVALUATE2(IF (CEDI.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CEDI.result_units_cd),3) ENDIF)
	,Diastolic_Report_Date = EVALUATE2(IF (TRIM(CNVTSTRING(CEDI.event_end_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CEDI.event_end_dt_tm,  "MM/DD/YYYY;;q") ENDIF)
	,BMI_Measured_Loinc = EVALUATE2(IF (SIZE(TRIM(CEBM.result_val,3)) = 0) " " ELSE '39156-5' ENDIF)
	,BMI_Measured_Value = EVALUATE2(IF (SIZE(TRIM(CEBM.result_val,3)) = 0) " " ELSE TRIM(CEBM.result_val,3) ENDIF)
	,BMI_Measured_Units = EVALUATE2(IF (CEBM.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CEBM.result_units_cd),3) ENDIF)
	,BMI_Measured_Report_Date = EVALUATE2(IF (TRIM(CNVTSTRING(CEBM.event_end_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CEBM.event_end_dt_tm,  "MM/DD/YYYY;;q") ENDIF)
	,BMI_Percentile_Loinc = EVALUATE2(IF (SIZE(TRIM(CEBP.result_val,3)) = 0) " " ELSE '59574-4' ENDIF)
	,BMI_Percentile_Value = EVALUATE2(IF (SIZE(TRIM(CEBP.result_val,3)) = 0) " " ELSE TRIM(CEBP.result_val,3) ENDIF)
	,BMI_Percentile_Units = EVALUATE2(IF (CEBP.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CEBP.result_units_cd),3) ENDIF)
	,BMI_Percentile_Report_Date = EVALUATE2(IF (TRIM(CNVTSTRING(CEBP.event_end_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CEBP.event_end_dt_tm,  "MM/DD/YYYY;;q") ENDIF)
FROM
	ENCOUNTER   enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
			AND fin_nbr.active_ind = 1
			AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		AND fin_nbr.encntr_alias_type_cd = 1077 /*FIN*/
    		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
			AND pat.active_ind = 1
			AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
			))
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
			AND enc_ins.active_ind = 1
			AND enc_ins.member_nbr != ' '
			AND (enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
			AND hp_ins.active_ind = 1
			AND (hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			AND hp_ins.health_plan_id IN (2982979 /*Blue Cross Cover Kids*/,2986644 /*Blue Cross Empire*/,
    			2985790 /*Blue Cross Exchange P*/,2985794 /*Blue Cross Exchange S*/,
    			2982980 /*Blue Cross Network E*/,2982981 /*Blue Cross Network P*/,
    			2985798 /*Blue Cross Network P OOS*/,2982982 /*Blue Cross Network S*/,
    			2985802 /*Blue Cross Network S OOS*/,2986597 /*BlueCross Behavioral*/,
    			2982971 /*Medicare Blue IP Denial Part B*/,2982963 /*Medicare BlueCare Plus*/,
    			2982962 /*Medicare BlueCross Advantage*/,2982960 /*Medicare BlueCross Anthem*/,
    			2982964 /*Medicare BlueCross Highmark*/,2985934 /*Medicare BlueCross Tennessee Part B*/,
    			2986039 /*Misc Medicare BlueCross HMO*/,2982974 /*BlueCare*/,
    			2986277 /*Medicaid BlueCare QMB*/,2982973 /*Tenncare Select BlueCare*/,
    			2982968.00 /*Medicare Humana*/,2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
   				2985957.00 /*Medicare UHC Dual Complete Part B*/,2985961.00 /*Medicare UHC IP Denial Part B*/,
   				2983341.00 /*Misc United Healthcare*/,2983161.00 /*United Healthcare*/,
   				2983345.00 /*United Healthcare Community*/)
			))
	, (INNER JOIN ENCNTR_PRSNL_RELTN epr ON (enc.encntr_id = epr.encntr_id
			AND epr.priority_seq = 1
			AND epr.encntr_prsnl_r_cd IN (1116/*Admitting*/,1119/*Attending*/,681283/*NP*/,681284 /*PA*/)
			AND epr.active_ind = 1
			AND (epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (INNER JOIN PRSNL prov ON (epr.prsnl_person_id = prov.person_id
    		AND prov.active_ind = 1
    		AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
    		AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
			AND npi.active_ind = 1
			AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
			))
	, (INNER JOIN ORGANIZATION org ON (enc.organization_id = org.organization_id
			AND org.active_ind = 1
			AND org.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND org.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN CLINICAL_EVENT CEWT ON (CEWT.encntr_id = enc.encntr_id
			AND CEWT.event_cd IN (4154123.00 /*Weight*/)
			AND CEWT.result_val != ' '
			AND CEWT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CEWT.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CEWT.encntr_id
				AND ce.event_cd IN (4154123.00 /*Weight*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN CLINICAL_EVENT CEHT ON (CEHT.encntr_id = enc.encntr_id
			AND CEHT.event_cd IN (4154126.00 /*Height*/)
			AND CEHT.result_val != ' '
			AND CEHT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CEHT.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CEHT.encntr_id
				AND ce.event_cd IN (4154126.00 /*Height*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN CLINICAL_EVENT CESY ON (CESY.encntr_id = enc.encntr_id
			AND CESY.event_cd IN (703501.00 /*Systolic*/)
			AND CESY.result_val != ' '
			AND CESY.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CESY.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CESY.encntr_id
				AND ce.event_cd IN (703501.00 /*Systolic*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN CLINICAL_EVENT CEDI ON (CEDI.encntr_id = enc.encntr_id
			AND CEDI.event_cd IN (703516.00 /*Diastolic*/)
			AND CEDI.result_val != ' '
			AND CEDI.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CEDI.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CEDI.encntr_id
				AND ce.event_cd IN (703516.00 /*Diastolic*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN CLINICAL_EVENT CEBM ON (CEBM.encntr_id = enc.encntr_id
			AND CEBM.event_cd IN (4154132.00 /*BMI Measured*/)
			AND CEBM.result_val != ' '
			AND CEBM.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CEBM.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CEBM.encntr_id
				AND ce.event_cd IN (4154132.00 /*BMI Measured*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN CLINICAL_EVENT CEBP ON (CEBP.encntr_id = enc.encntr_id
			AND CEBP.event_cd IN (2550556697.00 /*BMI Percentile*/)
			AND CEBP.result_val != ' '
			AND CEBP.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CEBP.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CEBP.encntr_id
				AND ce.event_cd IN (2550556697.00 /*BMI Percentile*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN DIAGNOSIS diag ON (enc.encntr_id = diag.encntr_id
			AND diag.active_ind = 1
			AND (diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = diag.nomenclature_id
			AND nom_diag.active_ind = 1
			AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			AND ((nom_diag.source_identifier >= "V85.0" AND nom_diag.source_identifier <="V85.5")
				OR (nom_diag.source_identifier >= "Z68.00" AND nom_diag.source_identifier <= "Z68.54"))
			))
	, (INNER JOIN SCH_APPT res ON (enc.encntr_id = res.encntr_id
			AND res.sch_role_cd = 273061037.00 /*Resource*/
			AND res.sch_state_cd = 4537.00 /*Checked Out*/
			))
	, (INNER JOIN SCH_EVENT se ON (res.sch_event_id = se.sch_event_id
			AND se.sch_state_cd = 4537.00 /*Checked Out*/
			AND se.appt_type_cd NOT IN (2553464417.00 /*Lab*/)
			AND (se.appt_reason_free NOT IN ('Telemedicine') OR NULLIND(se.appt_reason_free) = 1)
			))
WHERE enc.active_ind = 1
	AND (enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
		2560523697/*Results Only*/,20058643 /*Legacy Data*/)
	AND TRIM(nom_diag.source_identifier,3) != ' '
	AND ((nom_diag.nomenclature_id IN (9482133.00,291198680.00,291198628.00,291198647.00,291198679.00)
			AND FLOOR((DATETIMEDIFF(enc.reg_dt_tm, pat.birth_dt_tm)/365)) > 18)
		OR (nom_diag.nomenclature_id NOT IN (9482133.00,291198680.00,291198628.00,291198647.00,291198679.00)
			AND FLOOR((DATETIMEDIFF(enc.reg_dt_tm, pat.birth_dt_tm)/365)) <= 18)
		OR (NULLIND(CEWT.result_val) = 1 AND NULLIND(CEHT.result_val) = 1 AND
			NULLIND(CESY.result_val) = 1 AND NULLIND(CEDI.result_val) = 1 AND
			NULLIND(CEBM.result_val) = 1 AND NULLIND(CEBP.result_val) = 1))
 	AND (enc.reg_dt_tm >= CNVTDATETIME($bdate) AND enc.reg_dt_tm <= CNVTDATETIME($edate))
 	AND PARSER(facprompt)
 
/****************************************************************************
	Populate Record structure with BMI Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(exp_data->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
	exp_data->list[cnt].Facility = Facility
	exp_data->list[cnt].Provider = Provider
	exp_data->list[cnt].Patient = Patient
	exp_data->list[cnt].Patient_DOB = Patient_DOB
	exp_data->list[cnt].Age_as_of_Dos = CNVTSTRING(Age_as_of_Dos)
	exp_data->list[cnt].FIN = FIN
	exp_data->list[cnt].DOS = DOS
	exp_data->list[cnt].Policy_ID = Policy_ID
	exp_data->list[cnt].Insurance = Insurance
	exp_data->list[cnt].Problem_Code = Problem_Code
	exp_data->list[cnt].Problem_Desc = Problem_Desc
	exp_data->list[cnt].Weight_Loinc = Weight_Loinc
	exp_data->list[cnt].Weight_Value = Weight_Value
	exp_data->list[cnt].Weight_Units = Weight_Units
	exp_data->list[cnt].Weight_Report_Date = Weight_Report_Date
	exp_data->list[cnt].Height_Loinc = Height_Loinc
	exp_data->list[cnt].Height_Value = Height_Value
	exp_data->list[cnt].Height_Units = Height_Units
	exp_data->list[cnt].Height_Report_Date = Height_Report_Date
	exp_data->list[cnt].Systolic_Loinc = Systolic_Loinc
	exp_data->list[cnt].Systolic_Value = Systolic_Value
	exp_data->list[cnt].Systolic_Units = Systolic_Units
	exp_data->list[cnt].Systolic_Report_Date = Systolic_Report_Date
	exp_data->list[cnt].Diastolic_Loinc = Diastolic_Loinc
	exp_data->list[cnt].Diastolic_Value = Diastolic_Value
	exp_data->list[cnt].Diastolic_Units = Diastolic_Units
	exp_data->list[cnt].Diastolic_Report_Date = Diastolic_Report_Date
	exp_data->list[cnt].BMI_Measured_Loinc = BMI_Measured_Loinc
	exp_data->list[cnt].BMI_Measured_Value = BMI_Measured_Value
	exp_data->list[cnt].BMI_Measured_Units = BMI_Measured_Units
	exp_data->list[cnt].BMI_Measured_Report_Date = BMI_Measured_Report_Date
	exp_data->list[cnt].BMI_Percentile_Loinc = BMI_Percentile_Loinc
	exp_data->list[cnt].BMI_Percentile_Value = BMI_Percentile_Value
	exp_data->list[cnt].BMI_Percentile_Units = BMI_Percentile_Units
	exp_data->list[cnt].BMI_Percentile_Report_Date = BMI_Percentile_Report_Date
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
/***************************************************************************
	Output Report
****************************************************************************/
 
CALL ECHO("Detail Report")
 
IF (exp_data->output_cnt > 0)
	SELECT INTO $outdev
		Facility = exp_data->list[d.seq].Facility,
		Provider = exp_data->list[d.seq].Provider,
		Patient = exp_data->list[d.seq].Patient,
		Patient_DOB = exp_data->list[d.seq].Patient_DOB,
		Age_as_of_DOS = exp_data->list[d.seq].Age_as_of_DOS,
		Fin = exp_data->list[d.seq].fin,
		DOS = exp_data->list[d.seq].DOS,
		Policy_ID = exp_data->list[d.seq].Policy_ID,
		Insurance = exp_data->list[d.seq].Insurance,
		Problem_Code = exp_data->list[d.seq].Problem_Code,
		Problem_Desc = exp_data->list[d.seq].Problem_Desc,
		Weight_Loinc = exp_data->list[d.seq].Weight_Loinc,
		Weight_Value = exp_data->list[d.seq].Weight_Value,
		Weight_Units = exp_data->list[d.seq].Weight_Units,
		Weight_Report_Date = exp_data->list[d.seq].Weight_Report_Date,
		Height_Loinc = exp_data->list[d.seq].Height_Loinc,
		Height_Value = exp_data->list[d.seq].Height_Value,
		Height_Units = exp_data->list[d.seq].Height_Units,
		Height_Report_Date = exp_data->list[d.seq].Height_Report_Date,
		Systolic_Loinc = exp_data->list[d.seq].Systolic_Loinc,
		Systolic_Value = exp_data->list[d.seq].Systolic_Value,
		Systolic_Units = exp_data->list[d.seq].Systolic_Units,
		Systolic_Report_Date = exp_data->list[d.seq].Systolic_Report_Date,
		Diastolic_Loinc = exp_data->list[d.seq].Diastolic_Loinc,
		Diastolic_Value = exp_data->list[d.seq].Diastolic_Value,
		Diastolic_Units = exp_data->list[d.seq].Diastolic_Units,
		Diastolic_Report_Date = exp_data->list[d.seq].Diastolic_Report_Date,
		BMI_Measured_Loinc = exp_data->list[d.seq].BMI_Measured_Loinc,
		BMI_Measured_Value = exp_data->list[d.seq].BMI_Measured_Value,
		BMI_Measured_Units = exp_data->list[d.seq].BMI_Measured_Units,
		BMI_Measured_Report_Date = exp_data->list[d.seq].BMI_Measured_Report_Date,
		BMI_Percentile_Loinc = exp_data->list[d.seq].BMI_Percentile_Loinc,
		BMI_Percentile_Value = exp_data->list[d.seq].BMI_Percentile_Value,
		BMI_Percentile_Units = exp_data->list[d.seq].BMI_Percentile_Units,
		BMI_Percentile_Report_Date = exp_data->list[d.seq].BMI_Percentile_Report_Date,
		Prompt_Values = CONCAT(CONCAT(CONCAT("Facility = ",TRIM(exp_data->p_facility,3)),
			"     Start Date = ",TRIM(exp_data->p_start_date,3)),
			"     End_Date = ",TRIM(exp_data->p_end_date,3))
	FROM (dummyt d WITH seq = exp_data->output_cnt)
	ORDER BY Facility, Provider, Patient
	WITH nocounter, format, separator = ' '
ELSE
	SELECT INTO $outdev
		Message = "No data for the prompt values",
		Facility_Prompt = exp_data->p_facility,
		Begin_Date_Prompt = exp_data->p_start_date,
		End_Date_Prompt = exp_data->p_end_date
	FROM (dummyt d )
	WITH nocounter, format, separator = ' '
ENDIF
 
 
;CALL ECHORECORD(exp_data)
 
END
GO
 
 

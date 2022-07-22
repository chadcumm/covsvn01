/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		01/12/2019
	Solution:			Ambulatory
	Source file name:	cov_bcbs_screen_lab_export.prg
	Object name:		cov_bcbs_screen_lab_export
	Request #:			1552
 
	Program purpose:	Export Colonoscopy/Breast/BMI/Lab data to send to
						BCBS for meeting measures.
 
	Executing from:		CCL
 
 	Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Date	 	Developer			Comment
----	---------- 	----------			---------------------------------------
001 	08/07/2019 	Dawn Greer, DBA     Removed duplicate field from record
	                                    structure
002 	09/16/2019 	Dawn Greer, DBA     Fix LOINC Codes for Diastolic/Systolic
003 	11/20/2019 	Dawn Greer, DBA     Added more Health Plans to pull
004 	01/21/2020 	Dawn Greer, DBA     Added Fix for DOB display
005 	01/21/2020 	Dawn Greer, DBA     Added BMI query blocks (height, BMI Measured,
                                        BMI Percentile) to the BMI query blocks
                                        currently pulling (weight, diastolic,
                                        systolic).
006 	05/15/2020 	Dawn Greer, DBA     MRN not required change to LEFT JOIN
                                        Added Lab System to PerformLoc values
                                        to look for.
                                        Added logic to get first entered Diagnosis
                                        when the priority is zero.
007 	07/02/2020  Dawn Greer, DBA     Add criteria to check for Auth (Verified) and
    									modified as Result_Status_cd and add check
    									for the Valid_Until_Dt_tm to the Clinical
    									Event join.  Added code to remove line feed
    									in the lab result value field.
008		08/17/2020 	Dawn Greer, DBA     Change the BMI data to have either the ICD10
                                        code or the LOINC Code.  Change LOINCs based
                                        on other criteria.  Copied from PROD.
******************************************************************************/
 
drop program cov_bcbs_screen_lab_BMI_TEST go
create program cov_bcbs_screen_lab_BMI_TEST
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	,"Output To File" = 1
 
WITH OUTDEV, output_file
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE cov_crlf 			= vc WITH constant(build(char(13),char(10)))
DECLARE cov_lf              = vc WITH constant(char(10))
DECLARE cov_pipe			= vc WITH constant(char(124))
 
DECLARE file_var			= vc WITH noconstant("umcov001_B10CFF_")
DECLARE cur_date_var  		= vc WITH noconstant(build(YEAR(curdate),FORMAT(MONTH(curdate),"##;P0"),FORMAT(DAY(curdate),"##;P0")))
DECLARE filepath_var		= vc WITH noconstant("")
DECLARE temppath_var  		= vc WITH noconstant("cer_temp:")
DECLARE temppath2_var		= vc WITH noconstant("$cer_temp/")
DECLARE output_var			= vc WITH noconstant("")
DECLARE output_rec  		= vc WITH noconstant("")
 
DECLARE cmd					= vc WITH noconstant("")
DECLARE len					= i4 WITH noconstant(0)
DECLARE stat				= i4 WITH noconstant(0)
 
DECLARE startdate			= F8
DECLARE enddate				= F8
 
SET startdate = CNVTDATETIME(CURDATE-21,0)		;21
SET enddate = CNVTDATETIME(CURDATE-15,235959)	;15
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/BCBS/Screenings_Lab/"
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/BCBS/"			;TESTING
SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q")," *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
 
RECORD exp_data (
	1 output_cnt = i4
	1 list[*]
	    2 FileExtractDate  = VC
	    2 Patient_MRN = VC
	    2 BCBSPolicyID = VC
	    2 Patient_Fname = VC
	    2 Patient_Mname = VC
	    2 Patient_Lname = VC
	    2 Patient_SSN = VC
	    2 Patient_DOB = VC
	    2 Patient_Gender = VC
	    2 Patient_Addr_Line1 = VC
	    2 Patient_Addr_Line2 = VC
	    2 Patient_Addr_City = VC
	    2 Patient_Addr_State = VC
	    2 Patient_Addr_Zip = VC
	    2 EncounterID = VC
	    2 EncounterType_Code = VC
	    2 EncounterType_CodeType = VC
	    2 EncounterType_CodeDesc = VC
	    2 ServiceDate = VC
	    2 AdmitDate = VC
	    2 DischargeDate = VC
	    2 Provider_NPI = VC
	    2 Provider_BCBSTID = VC
	    2 Provider_Fname = VC
	    2 Provider_Mname = VC
	    2 Provider_Lname = VC
	    2 Provider_OrgNPI = VC
	    2 Provider_OrgTaxid = VC
	    2 Provider_OrgLegalName = VC
	    2 Procedure_Code = VC
	    2 Procedure_CodeType = VC
	    2 Procedure_Desc = VC
	    2 Procedure_Status = VC
	    2 Procedure_BeginDate = VC
	    2 Procedure_EndDate = VC
	    2 Problem_Code = VC
	    2 Problem_CodeType = VC
	    2 Problem_Desc = VC
	    2 Problem_Status = VC
	    2 Problem_BeginDate = VC
	    2 Problem_EndDate = VC
	    2 LabOrder_Code = VC
	    2 LabOrder_CodeType = VC
	    2 LabOrder_Desc = VC
	    2 LabOrder_Date = VC
	    2 LabResult_Code = VC
	    2 LabResult_CodeType = VC
	    2 LabResult_Desc = VC
	    2 LabResult_Value = VC
	    2 LabResult_ValueUOM = VC
	    2 LabResult_Range = VC
	    2 LabResult_Status = VC
	    2 LabResult_ReportDate = VC
	    2 VitalSign_Code = VC
	    2 VitalSign_CodeType = VC
	    2 VitalSign_CodeDesc = VC
	    2 VitalSign_Value = VC
	    2 VitalSign_ValueUOM = VC
	    2 VitalSign_ReportDate = VC
	    2 MedicationDrug_Code = VC
	    2 MedicationDrug_CodeType = VC
	    2 MedicationDrug_CodeDesc = VC
	    2 Medication_Status = VC
	    2 Medication_BeginDate = VC
	    2 Medication_EndDate = VC
	    2 VaccineDrug_Code = VC
	    2 VaccineDrug_CodeType = VC
	    2 VaccineDrug_CodeDesc = VC
	    2 Vaccine_Status = VC
	    2 Vaccine_AdminDate = VC
	    2 AllergyCat_Code = VC
	    2 AllergyCat_CodeType = VC
	    2 AllergyCat_CodeDesc = VC
	    2 Allergen_Code = VC
	    2 Allergen_CodeType = VC
	    2 Allergen_CodeDesc = VC
	    2 Allergy_Status = VC
	    2 Allergy_BeginDate = VC
	    2 Allergy_EndDate = VC
	)
 
 
; 005 Start
CALL ECHO ("***** GETTING BMI DATA *****")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get BMI Data
**************************************************************/
SELECT DISTINCT
	FileExtractDate = FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM-DD-YYYY;;q")
	,Patient_MRN = EVALUATE2(IF (SIZE(mrn_nbr.alias) = 0) " " ELSE TRIM(mrn_nbr.alias,3) ENDIF)
	,BCBSPolicyID = TRIM(ins.MEMBER_NBR,3)
	,Patient_Fname = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,Patient_Mname = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,Patient_Lname = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,Patient_SSN = EVALUATE2(IF (SIZE(ssn.alias) = 0) " " ELSE TRIM(ssn.alias,3) ENDIF)
	,Patient_DOB = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1), "MM-DD-YYYY;;q") ENDIF)
	,Patient_Gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,Patient_Addr_Line1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
	,Patient_Addr_Line2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
	,Patient_Addr_City = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
	,Patient_Addr_State = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
	,Patient_Addr_Zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
	,EncounterID = EVALUATE2(IF (SIZE(fin_nbr.alias) = 0) " " ELSE TRIM(fin_nbr.alias,3) ENDIF)
	,EncounterType_Code = " "
	,EncounterType_CodeType = " "
	,EncounterType_CodeDesc = " "
	,ServiceDate = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "MM-DD-YYYY;;q") ENDIF)
	,AdmitDate = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "MM-DD-YYYY;;q") ENDIF)
	,DischargeDate = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "MM-DD-YYYY;;q") ENDIF)
	,Provider_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Provider_BCBSTID = " "
	,Provider_Fname = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,Provider_Mname = " "
	,Provider_Lname = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,Provider_OrgNPI = "1457302010"
	,Provider_OrgTaxID = EVALUATE2(IF (SIZE(org.federal_tax_id_nbr) = 0) " " ELSE TRIM(org.federal_tax_id_nbr,3) ENDIF)
	,Provider_OrgLegalName = EVALUATE2(IF (SIZE(org.org_name) = 0) " " ELSE TRIM(org.org_name,3) ENDIF)
	,Procedure_Code = " "
	,Procedure_CodeType = " "
	,Procedure_Desc = " "
	,Procedure_Status = " "
	,Procedure_BeginDate = " "
	,Procedure_EndDate = " "
	,Problem_Code = EVALUATE2(IF (SIZE(TRIM(diag_info.source_identifier,3)) = 0) " " ELSE TRIM(diag_info.source_identifier,3) ENDIF)
	,Problem_CodeType = EVALUATE2(IF (SIZE(TRIM(diag_info.source_identifier,3)) = 0) " " ELSE "ICD10" ENDIF)
	,Problem_Desc = EVALUATE2(IF (SIZE(TRIM(diag_info.source_string,3)) = 0) " " ELSE TRIM(diag_info.source_string,3) ENDIF)
	,Problem_Status = " "
	,Problem_BeginDate = EVALUATE2(IF (SIZE(TRIM(diag_info.source_identifier,3)) = 0
			OR TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "MM-DD-YYYY;;q") ENDIF)
	,Problem_EndDate = EVALUATE2(IF (SIZE(TRIM(diag_info.source_identifier,3)) = 0
			OR TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "MM-DD-YYYY;;q") ENDIF)
	,LabOrder_Code = " "
	,LabOrder_CodeType = " "
	,LabOrder_Desc = " "
	,LabOrder_Date = " "
	,LabResult_Code = " "
	,LabResult_CodeType = " "
	,LabResult_Desc = " "
	,LabResult_Value = " "
	,LabResult_ValueUOM = " "
	,LabResult_Range = " "
	,LabResult_Status = " "
	,LabResult_ReportDate = " "
	,VitalSign_Code = EVALUATE(CEBMI.event_cd,
		703516.00 /*Diastolic*/, "8462-4",
		703501.00 /*Systolic*/, "8480-6",
		4154126.00 /*Height*/, "3137-7",
		4154123.00 /*Weight*/, "3141-9",
		4154132 /*BMI Measured*/,"39156-5",
		4154144 /*BMI Estimated*/,"89270-3",
		2550556697.00 /*BMI Percentile*/, "59574-4", " ")
	,VitalSign_CodeType = "LOINC"
	,VitalSign_CodeDesc = EVALUATE(CEBMI.event_cd,
		703516.00 /*Diastolic*/, "Diastolic",
		703501.00 /*Systolic*/, "Systolic",
		4154126.00 /*Height*/, "Height",
		4154123.00 /*Weight*/, "Weight",
		4154132 /*BMI Measured*/,"BMI Measured",
		4154144 /*BMI Estimated*/,"BMI Estimated",
		2550556697.00 /*BMI Percentile*/, "BMI Percentile", " ")
	,VitalSign_Value = EVALUATE2(IF (SIZE(CEBMI.result_val) = 0) " " ELSE TRIM(CEBMI.result_val,3) ENDIF)
	,VitalSign_ValueUOM = EVALUATE2(IF (CEBMI.result_units_cd = 0) " "
		ELSE TRIM(UAR_GET_CODE_DISPLAY(CEBMI.result_units_cd),3) ENDIF)
	,VitalSign_ReportDate = EVALUATE2(IF (TRIM(CNVTSTRING(CEBMI.performed_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CEBMI.performed_dt_tm, "MM-DD-YYYY;;q") ENDIF)
	,MedicationDrug_Code = " "
	,MedicationDrug_CodeType = " "
	,MedicationDrug_CodeDesc = " "
	,Medication_Status = " "
	,Medication_BeginDate = " "
	,Medication_EndDate = " "
	,VaccineDrug_Code = " "
	,VaccineDrug_CodeType = " "
	,VaccineDrug_CodeDesc = " "
	,Vaccine_Status = " "
	,Vaccine_AdminDate = " "
	,AllergyCat_Code = " "
	,AllergyCat_CodeType = " "
	,AllergyCat_CodeDesc = " "
	,Allergen_Code = " "
	,Allergen_CodeType = " "
	,Allergen_CodeDesc = " "
	,Allergy_Status = " "
	,Allergy_BeginDate = " "
	,Allergy_EndDate = " "
FROM
	ENCOUNTER   enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
			AND fin_nbr.active_ind = 1
			AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		AND fin_nbr.encntr_alias_type_cd = 1077.00   ;FIN
    		))
	, (LEFT JOIN ENCNTR_ALIAS mrn_nbr ON (enc.encntr_id = mrn_nbr.encntr_id		;006
			AND mrn_nbr.active_ind = 1
			AND mrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND mrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		AND mrn_nbr.alias_pool_cd =  2554138271.00   ;MRN
    		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
			AND pat.active_ind = 1
			AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
			))
	, (INNER JOIN PERSON_ALIAS ssn ON (enc.person_id = ssn.person_id
			AND pat.person_id = ssn.person_id
			AND ssn.active_ind = 1
			AND ssn.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND ssn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		AND ssn.alias_pool_cd = 683997.00   ;SSN
    		))
	, (INNER JOIN ADDRESS addr ON (enc.person_id = addr.parent_entity_id
			AND pat.person_id = addr.parent_entity_id
			AND addr.parent_entity_name = "PERSON"
			AND addr.active_ind = 1
			AND addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		AND addr.address_type_cd = 756.00   ;HOME
			AND addr.address_id IN (SELECT MAX(addr1.address_id) FROM address addr1
				WHERE addr1.parent_entity_id = pat.person_id
				AND addr1.parent_entity_name = "PERSON"
				AND addr1.active_ind = 1
				AND addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
				AND addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
				AND addr1.address_type_cd = 756.00)   ;HOME
    		))
	, (INNER JOIN (SELECT enc_ins.encntr_id, enc_ins.member_nbr, hp_ins.plan_name,
			row_num = ROW_NUMBER () OVER(PARTITION BY enc_ins.encntr_id ORDER BY enc_ins.priority_seq)
		FROM ENCNTR_PLAN_RELTN enc_ins
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
    			2986277 /*Medicaid BlueCare QMB*/,2982973 /*Tenncare Select BlueCare*/)
			))
		WHERE enc_ins.active_ind = 1
		AND enc_ins.member_nbr != ' '
		AND (enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(member_nbr,"vc")
	    	,DATATYPE(plan_name, "vc")
	    	,DATATYPE(row_num, "i4"))
		) ins ON ins.encntr_id = enc.encntr_id AND ins.row_num = 1)
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
	, (INNER JOIN CLINICAL_EVENT CEBMI ON (CEBMI.encntr_id = enc.encntr_id
			AND CEBMI.event_cd IN (4154132.00 /*BMI Measured*/,
				    4154144.00 /*BMI Estimated*/,  2550556697.00 /*BMI Percentile*/,
				    703516.00 /*Diastolic*/,703501.00 /*Systolic*/,
				    4154126.00 /*Height*/,4154123.00 /*Weight*/)
			AND CEBMI.result_val != ' '
			AND CEBMI.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND CEBMI.performed_dt_tm = (SELECT MAX(ce.performed_dt_tm)
				FROM clinical_event ce
				WHERE ce.encntr_id = CEBMI.encntr_id
				AND ce.event_cd IN (4154132.00 /*BMI Measured*/,
				    4154144.00 /*BMI Estimated*/,  2550556697.00 /*BMI Percentile*/,
				    703516.00 /*Diastolic*/,703501.00 /*Systolic*/,
				    4154126.00 /*Height*/,4154123.00 /*Weight*/)
				AND ce.result_val != ' '
				AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
	, (LEFT JOIN (SELECT diag.encntr_id, nom_diag.source_identifier, nom_diag.source_string
		FROM  DIAGNOSIS diag
		, (INNER JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = diag.nomenclature_id
			AND nom_diag.active_ind = 1
			AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			AND (nom_diag.source_identifier >= "Z68.00" AND nom_diag.source_identifier <= "Z68.54")
			))
		WHERE diag.active_ind = 1
			AND (diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(source_identifier,"vc")
	    	,DATATYPE(source_string, "vc"))
		) diag_info ON diag_info.encntr_id = enc.encntr_id)
WHERE enc.active_ind = 1
	AND (enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
		2560523697/*Results Only*/,20058643/*Legacy Data*/)
 	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate) AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
/****************************************************************************
	Populate Record structure with BMI Data
*****************************************************************************/
HEAD REPORT
	cnt = exp_data->output_cnt
 
	IF(mod(cnt,10)> 0)
   		CALL alterlist(exp_data->list, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
 
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
	exp_data->list[cnt].FileExtractDate = FileExtractDate
	exp_data->list[cnt].Patient_MRN = Patient_MRN
	exp_data->list[cnt].BCBSPolicyID = BCBSPolicyID
	exp_data->list[cnt].Patient_Fname = Patient_Fname
	exp_data->list[cnt].Patient_Mname = Patient_Mname
	exp_data->list[cnt].Patient_Lname = Patient_Lname
	exp_data->list[cnt].Patient_SSN = Patient_SSN
	exp_data->list[cnt].Patient_DOB = Patient_DOB
	exp_data->list[cnt].Patient_Gender = Patient_Gender
	exp_data->list[cnt].Patient_Addr_Line1 = Patient_Addr_Line1
	exp_data->list[cnt].Patient_Addr_Line2 = Patient_Addr_Line2
	exp_data->list[cnt].Patient_Addr_City = Patient_Addr_City
	exp_data->list[cnt].Patient_Addr_State = Patient_Addr_State
	exp_data->list[cnt].Patient_Addr_Zip = Patient_Addr_Zip
	exp_data->list[cnt].EncounterID = EncounterID
	exp_data->list[cnt].EncounterType_Code = EncounterType_Code
	exp_data->list[cnt].EncounterType_CodeType = EncounterType_CodeType
	exp_data->list[cnt].EncounterType_CodeDesc = EncounterType_CodeDesc
	exp_data->list[cnt].ServiceDate = ServiceDate
	exp_data->list[cnt].AdmitDate = AdmitDate
	exp_data->list[cnt].DischargeDate = DischargeDate
	exp_data->list[cnt].Provider_NPI = Provider_NPI
	exp_data->list[cnt].Provider_BCBSTID = Provider_BCBSTID
	exp_data->list[cnt].Provider_Fname = Provider_Fname
	exp_data->list[cnt].Provider_Mname = Provider_Mname
	exp_data->list[cnt].Provider_Lname = Provider_Lname
	exp_data->list[cnt].Provider_OrgNPI = Provider_OrgNPI
	exp_data->list[cnt].Provider_OrgTaxid = Provider_OrgTaxid
	exp_data->list[cnt].Provider_OrgLegalName = Provider_OrgLegalName
	exp_data->list[cnt].Procedure_Code = Procedure_Code
	exp_data->list[cnt].Procedure_CodeType = Procedure_CodeType
	exp_data->list[cnt].Procedure_Desc = Procedure_Desc
	exp_data->list[cnt].Procedure_Status = Procedure_Status
	exp_data->list[cnt].Procedure_BeginDate = Procedure_BeginDate
	exp_data->list[cnt].Procedure_EndDate = Procedure_EndDate
	exp_data->list[cnt].Problem_Code = Problem_Code
	exp_data->list[cnt].Problem_CodeType = Problem_CodeType
	exp_data->list[cnt].Problem_Desc = Problem_Desc
	exp_data->list[cnt].Problem_Status = Problem_Status
	exp_data->list[cnt].Problem_BeginDate = Problem_BeginDate
	exp_data->list[cnt].Problem_EndDate = Problem_EndDate
	exp_data->list[cnt].LabOrder_Code = LabOrder_Code
	exp_data->list[cnt].LabOrder_CodeType = LabOrder_CodeType
	exp_data->list[cnt].LabOrder_CodeType = LabOrder_CodeType
	exp_data->list[cnt].LabOrder_Desc = LabOrder_Desc
	exp_data->list[cnt].LabOrder_Date = LabOrder_Date
	exp_data->list[cnt].LabResult_Code = LabResult_Code
	exp_data->list[cnt].LabResult_CodeType = LabResult_CodeType
	exp_data->list[cnt].LabResult_Desc = LabResult_Desc
	exp_data->list[cnt].LabResult_Value = LabResult_Value
	exp_data->list[cnt].LabResult_ValueUOM = LabResult_ValueUOM
	exp_data->list[cnt].LabResult_Range = LabResult_Range
	exp_data->list[cnt].LabResult_Status = LabResult_Status
	exp_data->list[cnt].LabResult_ReportDate = LabResult_ReportDate
	exp_data->list[cnt].VitalSign_Code = VitalSign_Code
	exp_data->list[cnt].VitalSign_CodeType = VitalSign_CodeType
	exp_data->list[cnt].VitalSign_CodeDesc = VitalSign_CodeDesc
	exp_data->list[cnt].VitalSign_Value = VitalSign_Value
	exp_data->list[cnt].VitalSign_ValueUOM = VitalSign_ValueUOM
	exp_data->list[cnt].VitalSign_ReportDate = VitalSign_ReportDate
	exp_data->list[cnt].MedicationDrug_Code = MedicationDrug_Code
	exp_data->list[cnt].MedicationDrug_CodeType = MedicationDrug_CodeType
	exp_data->list[cnt].MedicationDrug_CodeDesc = MedicationDrug_CodeDesc
	exp_data->list[cnt].Medication_Status = Medication_Status
	exp_data->list[cnt].Medication_BeginDate = Medication_BeginDate
	exp_data->list[cnt].Medication_EndDate = Medication_EndDate
	exp_data->list[cnt].VaccineDrug_Code = VaccineDrug_Code
	exp_data->list[cnt].VaccineDrug_CodeType = VaccineDrug_CodeType
	exp_data->list[cnt].VaccineDrug_CodeDesc = VaccineDrug_CodeDesc
	exp_data->list[cnt].Vaccine_Status = Vaccine_Status
	exp_data->list[cnt].Vaccine_AdminDate = Vaccine_AdminDate
	exp_data->list[cnt].AllergyCat_Code = AllergyCat_Code
	exp_data->list[cnt].AllergyCat_CodeType = AllergyCat_CodeType
	exp_data->list[cnt].AllergyCat_CodeDesc = AllergyCat_CodeDesc
	exp_data->list[cnt].Allergen_Code = Allergen_Code
	exp_data->list[cnt].Allergen_CodeType = Allergen_CodeType
	exp_data->list[cnt].Allergen_CodeDesc = Allergen_CodeDesc
	exp_data->list[cnt].Allergy_Status = Allergy_Status
	exp_data->list[cnt].Allergy_BeginDate = Allergy_BeginDate
	exp_data->list[cnt].Allergy_EndDate = Allergy_EndDate
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
 
CALL ECHO ("***** BUILD Output ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/****************************************************************************
	Build Output
*****************************************************************************/
IF (exp_data->output_cnt > 0)
 	CALL ECHO ("******* Build Output *******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",exp_data->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("FileExtractDate", cov_pipe,
				"Patient_MRN", cov_pipe,
				"BCBSPolicyID", cov_pipe,
				"Patient_Fname", cov_pipe,
				"Patient_Mname", cov_pipe,
				"Patient_Lname", cov_pipe,
				"Patient_SSN", cov_pipe,
				"Patient_DOB", cov_pipe,
				"Patient_Gender", cov_pipe,
				"Patient_Addr_Line1", cov_pipe,
				"Patient_Addr_Line2", cov_pipe,
				"Patient_Addr_City", cov_pipe,
				"Patient_Addr_State", cov_pipe,
				"Patient_Addr_Zip", cov_pipe,
				"EncounterID", cov_pipe,
				"EncounterType_Code", cov_pipe,
				"EncounterType_CodeType", cov_pipe,
				"EncounterType_CodeDesc", cov_pipe,
				"ServiceDate", cov_pipe,
				"AdmitDate", cov_pipe,
				"DischargeDate", cov_pipe,
				"Provider_NPI", cov_pipe,
				"Provider_BCBSTID", cov_pipe,
				"Provider_Fname", cov_pipe,
				"Provider_Mname", cov_pipe,
				"Provider_Lname", cov_pipe,
				"Provider_OrgNPI", cov_pipe,
				"Provider_OrgTaxid", cov_pipe,
				"Provider_OrgLegalName", cov_pipe,
				"Procedure_Code", cov_pipe,
				"Procedure_CodeType", cov_pipe,
				"Procedure_Desc", cov_pipe,
				"Procedure_Status", cov_pipe,
				"Procedure_BeginDate", cov_pipe,
				"Procedure_EndDate", cov_pipe,
				"Problem_Code", cov_pipe,
				"Problem_CodeType", cov_pipe,
				"Problem_Desc", cov_pipe,
				"Problem_Status", cov_pipe,
				"Problem_BeginDate", cov_pipe,
				"Problem_EndDate", cov_pipe,
				"LabOrder_Code", cov_pipe,
				"LabOrder_CodeType", cov_pipe,
				"LabOrder_Desc", cov_pipe,
				"LabOrder_Date", cov_pipe,
				"LabResult_Code", cov_pipe,
				"LabResult_CodeType", cov_pipe,
				"LabResult_Desc", cov_pipe,
				"LabResult_Value", cov_pipe,
				"LabResult_ValueUOM", cov_pipe,
				"LabResult_Range", cov_pipe,
				"LabResult_Status", cov_pipe,
				"LabResult_ReportDate", cov_pipe,
				"VitalSign_Code", cov_pipe,
				"VitalSign_CodeType", cov_pipe,
				"VitalSign_CodeDesc", cov_pipe,
				"VitalSign_Value", cov_pipe,
				"VitalSign_ValueUOM", cov_pipe,
				"VitalSign_ReportDate", cov_pipe,
				"MedicationDrug_Code", cov_pipe,
				"MedicationDrug_CodeType", cov_pipe,
				"MedicationDrug_CodeDesc", cov_pipe,
				"Medication_Status", cov_pipe,
				"Medication_BeginDate", cov_pipe,
				"Medication_EndDate", cov_pipe,
				"VaccineDrug_Code", cov_pipe,
				"VaccineDrug_CodeType", cov_pipe,
				"VaccineDrug_CodeDesc", cov_pipe,
				"Vaccine_Status", cov_pipe,
				"Vaccine_AdminDate", cov_pipe,
				"AllergyCat_Code", cov_pipe,
				"AllergyCat_CodeType", cov_pipe,
				"AllergyCat_CodeDesc", cov_pipe,
				"Allergen_Code", cov_pipe,
				"Allergen_CodeType", cov_pipe,
				"Allergen_CodeDesc", cov_pipe,
				"Allergy_Status", cov_pipe,
				"Allergy_BeginDate", cov_pipe,
				"Allergy_EndDate")
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						exp_data->list[dt.seq].FileExtractDate, cov_pipe,
						exp_data->list[dt.seq].Patient_MRN, cov_pipe,
						exp_data->list[dt.seq].BCBSPolicyID, cov_pipe,
						exp_data->list[dt.seq].Patient_Fname, cov_pipe,
						exp_data->list[dt.seq].Patient_Mname, cov_pipe,
						exp_data->list[dt.seq].Patient_Lname, cov_pipe,
						exp_data->list[dt.seq].Patient_SSN, cov_pipe,
						exp_data->list[dt.seq].Patient_DOB, cov_pipe,
						exp_data->list[dt.seq].Patient_Gender, cov_pipe,
						exp_data->list[dt.seq].Patient_Addr_Line1, cov_pipe,
						exp_data->list[dt.seq].Patient_Addr_Line2, cov_pipe,
						exp_data->list[dt.seq].Patient_Addr_City, cov_pipe,
						exp_data->list[dt.seq].Patient_Addr_State, cov_pipe,
						exp_data->list[dt.seq].Patient_Addr_Zip, cov_pipe,
						exp_data->list[dt.seq].EncounterID, cov_pipe,
						exp_data->list[dt.seq].EncounterType_Code, cov_pipe,
						exp_data->list[dt.seq].EncounterType_CodeType, cov_pipe,
						exp_data->list[dt.seq].EncounterType_CodeDesc, cov_pipe,
						exp_data->list[dt.seq].ServiceDate, cov_pipe,
						exp_data->list[dt.seq].AdmitDate, cov_pipe,
						exp_data->list[dt.seq].DischargeDate, cov_pipe,
						exp_data->list[dt.seq].Provider_NPI, cov_pipe,
						exp_data->list[dt.seq].Provider_BCBSTID, cov_pipe,
						exp_data->list[dt.seq].Provider_Fname, cov_pipe,
						exp_data->list[dt.seq].Provider_Mname, cov_pipe,
						exp_data->list[dt.seq].Provider_Lname, cov_pipe,
						exp_data->list[dt.seq].Provider_OrgNPI, cov_pipe,
						exp_data->list[dt.seq].Provider_OrgTaxid, cov_pipe,
						exp_data->list[dt.seq].Provider_OrgLegalName, cov_pipe,
						exp_data->list[dt.seq].Procedure_Code, cov_pipe,
						exp_data->list[dt.seq].Procedure_CodeType, cov_pipe,
						exp_data->list[dt.seq].Procedure_Desc, cov_pipe,
						exp_data->list[dt.seq].Procedure_Status, cov_pipe,
						exp_data->list[dt.seq].Procedure_BeginDate, cov_pipe,
						exp_data->list[dt.seq].Procedure_EndDate, cov_pipe,
						exp_data->list[dt.seq].Problem_Code, cov_pipe,
						exp_data->list[dt.seq].Problem_CodeType, cov_pipe,
						exp_data->list[dt.seq].Problem_Desc, cov_pipe,
						exp_data->list[dt.seq].Problem_Status, cov_pipe,
						exp_data->list[dt.seq].Problem_BeginDate, cov_pipe,
						exp_data->list[dt.seq].Problem_EndDate, cov_pipe,
						exp_data->list[dt.seq].LabOrder_Code, cov_pipe,
						exp_data->list[dt.seq].LabOrder_CodeType, cov_pipe,
						exp_data->list[dt.seq].LabOrder_Desc, cov_pipe,
						exp_data->list[dt.seq].LabOrder_Date, cov_pipe,
						exp_data->list[dt.seq].LabResult_Code, cov_pipe,
						exp_data->list[dt.seq].LabResult_CodeType, cov_pipe,
						exp_data->list[dt.seq].LabResult_Desc, cov_pipe,
						exp_data->list[dt.seq].LabResult_Value, cov_pipe,
						exp_data->list[dt.seq].LabResult_ValueUOM, cov_pipe,
						exp_data->list[dt.seq].LabResult_Range, cov_pipe,
						exp_data->list[dt.seq].LabResult_Status, cov_pipe,
						exp_data->list[dt.seq].LabResult_ReportDate, cov_pipe,
						exp_data->list[dt.seq].VitalSign_Code, cov_pipe,
						exp_data->list[dt.seq].VitalSign_CodeType, cov_pipe,
						exp_data->list[dt.seq].VitalSign_CodeDesc, cov_pipe,
						exp_data->list[dt.seq].VitalSign_Value, cov_pipe,
						exp_data->list[dt.seq].VitalSign_ValueUOM, cov_pipe,
						exp_data->list[dt.seq].VitalSign_ReportDate, cov_pipe,
						exp_data->list[dt.seq].MedicationDrug_Code, cov_pipe,
						exp_data->list[dt.seq].MedicationDrug_CodeType, cov_pipe,
						exp_data->list[dt.seq].MedicationDrug_CodeDesc, cov_pipe,
						exp_data->list[dt.seq].Medication_Status, cov_pipe,
						exp_data->list[dt.seq].Medication_BeginDate, cov_pipe,
						exp_data->list[dt.seq].Medication_EndDate, cov_pipe,
						exp_data->list[dt.seq].VaccineDrug_Code, cov_pipe,
						exp_data->list[dt.seq].VaccineDrug_CodeType, cov_pipe,
						exp_data->list[dt.seq].VaccineDrug_CodeDesc, cov_pipe,
						exp_data->list[dt.seq].Vaccine_Status, cov_pipe,
						exp_data->list[dt.seq].Vaccine_AdminDate, cov_pipe,
						exp_data->list[dt.seq].AllergyCat_Code, cov_pipe,
						exp_data->list[dt.seq].AllergyCat_CodeType, cov_pipe,
						exp_data->list[dt.seq].AllergyCat_CodeDesc, cov_pipe,
						exp_data->list[dt.seq].Allergen_Code, cov_pipe,
						exp_data->list[dt.seq].Allergen_CodeType, cov_pipe,
						exp_data->list[dt.seq].Allergen_CodeDesc, cov_pipe,
						exp_data->list[dt.seq].Allergy_Status, cov_pipe,
						exp_data->list[dt.seq].Allergy_BeginDate, cov_pipe,
						exp_data->list[dt.seq].Allergy_EndDate)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ENDIF
 
;CALL ECHORECORD (exp_data)
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("cp ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
END
GO
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		01/13/2019
	Solution:			Ambulatory
	Source file name:	cov_humana_lab_export.prg
	Object name:		cov_humana_lab_export
	Request #:			1542
 
	Program purpose:	Export Acute/Ambulatory Lab data to send to
						Humana for meeting measures.
 
	Executing from:		CCL
 
 	Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	---------------------------------------
  001 7/29/2019 Dawn Greer, DBA         Set every field to blank if it was NULL
******************************************************************************/
 
drop program cov_humana_lab_export go
create program cov_humana_lab_export
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	,"Output To File" = 1
 
WITH OUTDEV, output_file
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE cov_crlf			= vc WITH constant(BUILD(CHAR(13),CHAR(10)))
DECLARE cov_pipe			= vc WITH constant(CHAR(124))
 
DECLARE file_var			= vc WITH noconstant("covenant_humana_cerner_lab_export_")
DECLARE cur_date_var  		= vc WITH noconstant(BUILD(YEAR(CURDATE),FORMAT(MONTH(CURDATE),"##;P0"),FORMAT(DAY(CURDATE),"##;P0")))
DECLARE filepath_var		= vc WITH noconstant("")
DECLARE temppath_var  		= vc WITH noconstant("cer_temp:")
DECLARE temppath2_var		= vc WITH noconstant("$cer_temp/")
DECLARE output_var			= vc WITH noconstant("")
DECLARE output_rec  		= vc WITH noconstant(" ")
 
DECLARE cmd					= vc WITH noconstant(" ")
DECLARE len					= i4 WITH noconstant(0)
DECLARE stat				= i4 WITH noconstant(0)
 
DECLARE header				= vc WITH noconstant("")
DECLARE footer              = vc WITH noconstant("")
 
DECLARE varRecord_Type			= vc WITH noconstant(" ")
DECLARE varName_of_Facility	= vc WITH noconstant(" ")
DECLARE varExtraction_Date     = vc WITH noconstant(BUILD(FORMAT(CURDATE,"YYYYMMDD")))
 
DECLARE startdate			= F8
DECLARE enddate				= F8
 
SET startdate = CNVTDATETIME(CURDATE-21,0)
SET enddate = CNVTDATETIME(CURDATE-15,235959)
 
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q")," *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
 
RECORD exp_data (
	1 output_cnt = i4
	1 list[*]
	    2 Record_Type  = VC
	    2 Service_Date= VC
	    2 Accession_Number = VC
	    2 Medical_Record_Number = VC
	    2 Patient_First_Name = VC
	    2 Patient_Middle_Name = VC
	    2 Patient_Last_Name = VC
	    2 Address_1 = VC
	    2 Address_2= VC
	    2 City = VC
	    2 State = VC
	    2 Zip_Code = VC
	    2 Phone_Number = VC
	    2 Birth_Date = VC
	    2 Gender = VC
	    2 SSN = VC
	    2 Humana_ID = VC
	    2 Medicare_ID = VC
	    2 Medicaid_ID = VC
	    2 Group_Number = VC
	    2 Specimen_Collection_Date = VC
	    2 Ordering_PCP_TIN = VC
	    2 Ordering_PCP_UPIN = VC
	    2 Ordering_PCP_NPI = VC
	    2 ICD_Code_1 = VC
	    2 ICD_Code_2 = VC
	    2 ICD_Code_3 = VC
	    2 ICD_Code_4 = VC
	    2 ICD_Code_5 = VC
	    2 Lab_Test_ID = VC
	    2 Lab_Test_Name = VC
	    2 Test_Panel_ID = VC
	    2 Test_Panel_Name = VC
	    2 Local_Lab_Code = VC
	    2 Specimen_Type = VC
	    2 Test_Method = VC
	    2 Testing_Equipment_ID = VC
	    2 LOINC = VC
	    2 Test_Result = VC
	    2 Result_Units = VC
	    2 Low_Limit_of_the_Normal_Range = VC
	    2 High_Limit_of_the_Normal_Range = VC
	    2 Normal_Range = VC
	    2 Abnormal_Indicator = VC
	    2 CPT = VC
	    2 Amended_Result_Indicator = VC
	    2 Inpatient_Indicator = VC
	    2 Patient_Race = VC
	    2 Fasting_Indicator = VC
	    2 Lab_Partner_Name = VC
	    2 Comment_Field_1 = VC
	    2 Comment_Field_2 = VC
	    2 Comment_Field_3 = VC
	    2 Comment_Field_4 = VC
	    2 Comment_Field_5 = VC
		2 Comment_Field_6 = VC
		2 Comment_Field_7 = VC
	)
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/Humana/Labs/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
CALL ECHO ("***** GETTING LAB Header DATA ******")
/**************************************************************
; Get Lab Header Data
**************************************************************/
 
SELECT DISTINCT
	Record_Type = "01"
	,Name_of_Facility = "Covenant Health"
	,Extraction_Date = TO_CHAR(SYSDATE, "YYYYMMDD")
FROM DUAL
 
/****************************************************************************
	Populate variables with Lab Header Data
*****************************************************************************/
DETAIL
 
	header = BUILD2 (Record_Type,"|",Name_of_Facility,"|",Extraction_Date)
 
FOOT REPORT
	CALL ECHO (header)
 
WITH nocounter
 
CALL ECHO ("***** GETTING LAB DETAIL DATA ******")
/**************************************************************
; Get Lab Detail Data
**************************************************************/
SELECT DISTINCT
	Record_Type = "02"
	,Service_Date = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm,"YYYYMMDD") ENDIF)
	,Accession_Number = EVALUATE2(IF (SIZE(TRIM(aor.accession,3)) = 0) " " ELSE TRIM(aor.accession,3)ENDIF)
	,Medical_Record_Number = EVALUATE2(IF (SIZE(TRIM(mrn_nbr.alias,3)) = 0) " "
		ELSE SUBSTRING(1,45,TRIM(mrn_nbr.alias,3)) ENDIF)
	,Patient_First_Name = EVALUATE2(IF (SIZE(TRIM(pat.name_first_key,3)) = 0) " "
		ELSE SUBSTRING(1,30,TRIM(pat.name_first_key,3)) ENDIF)
	,Patient_Middle_Name = EVALUATE2(IF (SIZE(TRIM(pat.name_middle_key,3)) = 0) " "
		ELSE SUBSTRING(1,20,TRIM(pat.name_middle_key,3)) ENDIF)
	,Patient_Last_Name = EVALUATE2(IF (SIZE(TRIM(pat.name_last_KEY,3)) = 0) " "
		ELSE SUBSTRING(1,30,TRIM(pat.name_last_key,3)) ENDIF)
	,Address_1 = EVALUATE2(IF (SIZE(TRIM(addr.street_addr,3)) = 0) " " ELSE SUBSTRING(1,30,TRIM(addr.street_addr,3)) ENDIF)
	,Address_2 = EVALUATE2(IF (SIZE(TRIM(addr.street_addr2,3)) = 0) " " ELSE SUBSTRING(1,30,TRIM(addr.street_addr2,3)) ENDIF)
	,City = EVALUATE2(IF (SIZE(TRIM(addr.city,3)) = 0) " " ELSE SUBSTRING(1,25,TRIM(addr.city,3)) ENDIF)
	,State = EVALUATE2(IF (SIZE(TRIM(addr.state,3)) = 0) " " ELSE SUBSTRING(1,2,TRIM(addr.state,3)) ENDIF)
	,Zip_Code = EVALUATE2(IF (SIZE(TRIM(addr.zipcode_key,3)) = 0) " " ELSE SUBSTRING(1,9,TRIM(addr.zipcode_key,3)) ENDIF)
	,Phone_Number = EVALUATE2(IF (SIZE(TRIM(phone.phone_num_key,3)) = 0) " "
		ELSE SUBSTRING(1,12,BUILD(SUBSTRING(1,3,TRIM(phone.phone_num_key,3)),"-",
		SUBSTRING(4,3,TRIM(phone.phone_num_key,3)),"-",SUBSTRING(7,4,TRIM(phone.phone_num_key,3)))) ENDIF)
	,Birth_Date = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(CNVTDATETIMEUTC(DATETIMEZONE(pat.birth_dt_tm, pat.birth_tz), 1), "yyyymmdd;;d") ENDIF)
	,Gender = EVALUATE(pat.sex_cd, 362, "F", 363, "M","U")
	,SSN = EVALUATE2(IF (SIZE(TRIM(ssn.alias,3)) = 0) " " ELSE SUBSTRING(1,9,TRIM(ssn.alias,3)) ENDIF)
	,Humana_ID = EVALUATE2 (IF (SIZE(TRIM(enc_ins.member_nbr,3)) = 0) " "
		ELSE SUBSTRING(1,30,TRIM(enc_ins.member_nbr,3)) ENDIF)
	,Medicare_ID = " "
	,Medicaid_ID = " "
	,Group_Number = EVALUATE2 (IF (SIZE(TRIM(enc_ins.group_nbr,3)) = 0) " "
		ELSE SUBSTRING(1,16,TRIM(enc_ins.group_nbr,3)) ENDIF)
	,Specimen_Collection_Date = EVALUATE2(IF (TRIM(CNVTSTRING(ord_det.oe_field_dt_tm_value),3) IN ("0","31558644000")) " "
		ELSE FORMAT(ord_det.oe_field_dt_tm_value, "YYYYMMDD") ENDIF)
	,Ordering_PCP_TIN = " "
	,Ordering_PCP_UPIN = " "
	,Ordering_PCP_NPI = EVALUATE2(IF (SIZE(TRIM(npi.alias,3)) = 0) " " ELSE SUBSTRING(1,10,trim(npi.alias,3)) ENDIF)
	,ICD_Code_1 = EVALUATE2(IF (SIZE(TRIM(nom1.source_identifier,3)) = 0) " "
		ELSE SUBSTRING(1,9,TRIM(nom1.source_identifier,3)) ENDIF)
	,ICD_Code_2 = EVALUATE2(IF (SIZE(TRIM(nom2.source_identifier,3)) = 0) " "
		ELSE SUBSTRING(1,9,TRIM(nom2.source_identifier,3)) ENDIF)
	,ICD_Code_3 = EVALUATE2(IF (SIZE(TRIM(nom3.source_identifier,3)) = 0) " "
		ELSE SUBSTRING(1,9,TRIM(nom3.source_identifier,3)) ENDIF)
	,ICD_Code_4 = EVALUATE2(IF (SIZE(TRIM(nom4.source_identifier,3)) = 0) " "
		ELSE SUBSTRING(1,9,TRIM(nom4.source_identifier,3)) ENDIF)
	,ICD_Code_5 = EVALUATE2(IF (SIZE(TRIM(nom5.source_identifier,3)) = 0) " "
		ELSE SUBSTRING(1,9,TRIM(nom5.source_identifier,3)) ENDIF)
	,Lab_Test_ID = EVALUATE2(IF (SIZE(TRIM(CNVTSTRING(ce_cv1.code_value),3)) = 0) " "
		ELSE SUBSTRING(1,30,TRIM(CNVTSTRING(ce_cv1.code_value),3)) ENDIF)
	,Lab_Test_Name = EVALUATE2(IF (SIZE(TRIM(ce_cv1.description,3)) = 0) " "
		ELSE SUBSTRING(1,50,TRIM(ce_cv1.description,3)) ENDIF)
	,Test_Panel_ID = EVALUATE2(IF (SIZE(TRIM(CNVTSTRING(ord_cat.catalog_cd),3)) = 0) " "
		ELSE SUBSTRING(1,30,TRIM(CNVTSTRING(ord_cat.catalog_cd),3)) ENDIF)
	,Test_Panel_Name = EVALUATE2(IF (SIZE(TRIM(ord_cat.description,3)) = 0) " "
		ELSE SUBSTRING(1,60,TRIM(ord_cat.description,3)) ENDIF)
	,Local_Lab_Code = SUBSTRING(1,20,TRIM(BUILD(EVALUATE2(IF (od_perform_loc.oe_field_value
		NOT IN (2560368733.00 /*LabCorp*/, 2560368555.00 /*Quest*/)) TRIM(od_perform_loc.oe_field_display_value,3)
		ELSE "" ENDIF),EVALUATE2(IF (ce.resource_cd NOT IN (2554394831.00 /*COV Telcor*/))
		  	BUILD(SUBSTRING(1,FINDSTRING(" ",TRIM(UAR_GET_CODE_DISPLAY(ce.resource_cd),3))-1,
				TRIM(UAR_GET_CODE_DISPLAY(ce.resource_cd),3)), IF(SIZE(SUBSTRING(1,FINDSTRING(" ",
				TRIM(UAR_GET_CODE_DISPLAY(ce.resource_cd),3))-1,
				TRIM(UAR_GET_CODE_DISPLAY(ce.resource_cd),3))) != 0) " LABORATORY" ENDIF)
			ELSEIF (ce.resource_cd IN (2554394831.00 /*Cov Telcor*/))
				TRIM(UAR_GET_CODE_DISPLAY(ce.resource_cd),3)
			ELSE " " ENDIF)),3))
	,Specimen_Type = EVALUATE2(IF (SIZE(TRIM(od_spec_type.oe_field_display_value,3)) = 0) " "
		ELSE SUBSTRING(1,30,TRIM(od_spec_type.oe_field_display_value,3)) ENDIF)
	,Test_Method = " "
	,Testing_Equipment_ID = " "
	,LOINC = EVALUATE2(IF (SIZE(TRIM(cid.concept_cki,3)) = 0) " "
		ELSE SUBSTRING(7,SIZE(TRIM(cid.concept_cki,3)),(TRIM(cid.concept_cki,3))) ENDIF)
	,Test_Result = EVALUATE2(IF (SIZE(TRIM(ce.result_val,3)) = 0) " "
		ELSE SUBSTRING(1,25,TRIM(ce.result_val,3)) ENDIF)
	,Result_Units = EVALUATE2(IF (SIZE(TRIM(ce_cv2.display,3)) = 0) " "
		ELSE SUBSTRING(1,18,TRIM(ce_cv2.display,3)) ENDIF)
	,Low_Limit_of_the_Normal_Range = EVALUATE2(IF (SIZE(TRIM(ce.normal_low,3)) = 0) " "
		ELSE SUBSTRING(1,23,TRIM(ce.normal_low,3)) ENDIF)
	,High_Limit_of_the_Normal_Range = EVALUATE2 (IF (SIZE(TRIM(ce.normal_high,3)) = 0) " "
		ELSE SUBSTRING(1,23,TRIM(ce.normal_high,3)) ENDIF)
	,Normal_Range = SUBSTRING(1,20,BUILD(IF (SIZE(TRIM(ce.normal_low,3)) = 0) " "
			ELSE TRIM(ce.normal_low,3) ENDIF,
			IF (SIZE(TRIM(ce.normal_low,3)) = 0 AND SIZE(TRIM(ce.normal_high,3)) = 0) " "
			ELSEIF (SIZE(TRIM(ce.normal_low,3)) > 0 AND SIZE(TRIM(ce.normal_high,3)) = 0) " "
			ELSE "-" ENDIF,
			IF (SIZE(TRIM(ce.normal_high,3)) = 0) " "
			ELSE TRIM(ce.normal_high,3) ENDIF))
	,Abnormal_Indicator = " "
	,CPT = EVALUATE2(IF (SIZE(TRIM(cm.field6,3)) = 0) " " ELSE SUBSTRING(1,5,TRIM(cm.field6,3)) ENDIF)
	,Amended_Result_Indicator = EVALUATE(ce.result_status_cd,35.00,"Y",34.00,"Y","N")
	,Inpatient_Indicator = EVALUATE(enc.encntr_type_cd,309308.00,"Y","N")
	,Patient_Race = EVALUATE2(IF (pat.race_cd = 0.00) " "
		ELSE SUBSTRING(1,10,TRIM(UAR_GET_CODE_DESCRIPTION(pat.race_cd),3)) ENDIF)
	,Fasting_Indicator = EVALUATE2(IF (SIZE(TRIM(od_fasting.oe_field_display_value,3)) = 0) " "
		ELSE SUBSTRING(1,1,TRIM(od_fasting.oe_field_display_value,3)) ENDIF)
	,Lab_Partner_Name = SUBSTRING(1,50,EVALUATE2(IF (od_perform_loc.oe_field_value
		IN (2560368733.00 /*LabCorp*/, 2560368555.00 /*Quest*/)) TRIM(od_perform_loc.oe_field_display_value,3)
		ELSE " " ENDIF))
	,Comment_Field_1 = " "
	,Comment_Field_2 = " "
	,Comment_Field_3 = " "
	,Comment_Field_4 = " "
	,Comment_Field_5 = " "
	,Comment_Field_6 = " "
	,Comment_Field_7 = " "
FROM ENCOUNTER enc
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
			AND pat.active_ind = 1
			AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
			))
	, (INNER JOIN PERSON_ALIAS ssn ON (pat.person_id = ssn.person_id
			AND ssn.alias_pool_cd = 683997.00 ;SSN
			AND ssn.active_ind = 1
			))
	, (INNER JOIN ADDRESS addr ON (pat.person_id = addr.parent_entity_id
			AND addr.parent_entity_name = "PERSON"
			AND addr.address_type_cd = 756.00 ;Home
			AND addr.active_ind = 1
			))
	, (INNER JOIN PHONE phone ON (pat.person_id = phone.parent_entity_id
			AND phone.parent_entity_name = "PERSON"
			AND phone.phone_type_cd = 170.00 ;Home
			AND phone.active_ind = 1
			))
	, (INNER JOIN ENCNTR_ALIAS mrn_nbr ON (enc.encntr_id = mrn_nbr.encntr_id
			AND mrn_nbr.active_ind = 1
    		AND mrn_nbr.encntr_alias_type_cd = 1079.00  ;MRN
    		))
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
			AND enc_ins.active_ind = 1
			))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
			AND hp_ins.active_ind = 1
			AND hp_ins.health_plan_id IN (2982968.00 /*Medicare Humana*/)
			))
	, (INNER JOIN ORDERS ord ON (ord.person_id = enc.person_id
			AND ord.encntr_id = enc.encntr_id
			AND ord.catalog_type_cd = 2513.00   ;Laboratory
			AND ord.activity_type_cd IN (692.00 /*Gen Lab*/, 674.00 /*Blood Bank*/,
			47576777.00 /*Blood Gases*/, 696.00 /*Microbiology*/)
			AND ord.order_status_cd = 2543.00   ;Completed
			))
	, (INNER JOIN ORDER_ACTION ord_act ON (ord.order_id = ord_act.order_id
			AND ord_act.action_type_cd = 2534.00 ;order
			))
	, (INNER JOIN PRSNL prov ON (ord_act.order_provider_id = prov.person_id
			AND prov.active_ind = 1
			))
	, (INNER JOIN PRSNL_ALIAS npi ON (prov.person_id = npi.person_id
			AND npi.active_ind = 1
			AND npi.alias_pool_cd = 26026547.00 ; npi
			AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
			))
	, (INNER JOIN ORDER_CATALOG ord_cat ON (ord.catalog_cd = ord_cat.catalog_cd
			AND ord_cat.active_ind = 1
			AND ord_cat.catalog_type_cd IN (2513.00 /*Laboratory*/)
			AND ord_cat.activity_type_cd IN (692.00 /*Gen Lab*/, 674.00 /*Blood Bank*/,
			47576777.00 /*Blood Gases*/, 696.00 /*Microbiology*/)
			))
	, (INNER JOIN ORDER_DETAIL ord_det ON (ord.order_id = ord_det.order_id
			AND ord_det.oe_field_meaning_id = 51.00 ;"REQSTARTDTTM"
			AND ord_det.action_sequence IN (SELECT MAX(od.action_sequence)
				FROM ORDER_DETAIL od
				WHERE ord_det.order_id = od.order_id
				AND od.oe_field_meaning_id = 51.00) ;"REQSTARTDTTM"
			))
	, (INNER JOIN ORDER_DETAIL od_spec_type ON (ord.order_id = od_spec_type.order_id
			AND od_spec_type.oe_field_meaning_id = 9.00 ; "SPECIMEN TYPE"
			AND od_spec_type.action_sequence IN (SELECT MAX(od.action_sequence)
				FROM ORDER_DETAIL od
				WHERE od_spec_type.order_id = od.order_id
				AND od.oe_field_meaning_id = 9.00); "SPECIMEN TYPE"
			))
	, (LEFT JOIN ORDER_DETAIL od_perform_loc ON (ord.order_id = od_perform_loc.order_id
				AND od_perform_loc.oe_field_meaning_id = 18.00 ; "PERFORMLOC"
			))
	, (LEFT JOIN ORDER_DETAIL od_fasting ON (ord.order_id = od_fasting.order_id
			AND od_fasting.oe_field_meaning_ID = 96.00  ; "FASTING"
			))
	, (INNER JOIN CHARGE_EVENT chgeve ON (chgeve.order_id = ord.order_id
			AND chgeve.active_ind = 1
			))
	, (INNER JOIN CHARGE c ON (c.charge_event_id = chgeve.charge_event_id
			AND c.active_ind = 1
			))
	, (INNER JOIN CHARGE_MOD cm ON (cm.charge_item_id = c.charge_item_id
			AND cm.field1_id IN (615214.00 /*CPT4*/, 3692.00 /*CPT4 MOD*/, 2555056221.00/*CPT4 MOD*/)
			AND NOT cm.FIELD6 = NULL
			AND cm.ACTIVE_IND = 1
			))
	, (INNER JOIN CLINICAL_EVENT ce ON (ord.person_id = ce.person_id
			AND ord.encntr_id = ce.encntr_id
			AND ord.order_id = ce.order_id
			AND ord_cat.catalog_cd = ce.catalog_cd
			AND TRIM(ce.result_val,3) != ""
			))
	, (INNER JOIN CODE_VALUE ce_cv1 ON (ce.event_cd = ce_cv1.code_value
			AND ce_cv1.code_set = 72  ;Description for ce.event_cd
			AND ce_cv1.active_ind = 1
			))
	, (LEFT JOIN CODE_VALUE ce_cv2 ON (ce.result_units_cd = ce_cv2.code_value
			AND ce_cv2.code_set = 54	;Description for CE.Result_Units_cd
			AND ce_cv2.active_ind = 1
			))
	, (LEFT JOIN PROFILE_TASK_R ptr ON (ord_cat.catalog_cd = ptr.catalog_cd
			AND ce.catalog_cd = ptr.catalog_cd
			AND ce.task_assay_cd = ptr.task_assay_cd
			AND ptr.active_ind = 1
			))
	, (LEFT JOIN CONCEPT_IDENTIFIER_DTA cid ON (cid.task_assay_cd = ptr.task_assay_cd
			AND cid.specimen_type_cd = od_spec_type.oe_field_value
			AND ce.resource_cd = cid.service_resource_cd
			AND ce.task_assay_cd = cid.task_assay_cd
			AND cid.active_ind = 1
			))
	, (LEFT JOIN ACCESSION_ORDER_R aor ON (ord.order_id = aor.order_id))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner1 ON (ner1.encntr_id = enc.encntr_id
			AND ner1.parent_entity_name = "ORDERS"
			AND ner1.parent_entity_id = ord.order_id
			AND ner1.person_id = enc.person_id
			AND ner1.person_id = ord.person_id
			AND ner1.active_ind = 1
			AND ner1.priority = 1
			))
	, (LEFT JOIN NOMENCLATURE nom1 ON (nom1.nomenclature_id = ner1.nomenclature_id
			AND nom1.active_ind = 1
			AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner2 ON (ner2.encntr_id = enc.encntr_id
			AND ner2.parent_entity_name = "ORDERS"
			AND ner2.parent_entity_id = ord.order_id
			AND ner2.person_id = enc.person_id
			AND ner2.person_id = ord.person_id
			AND ner2.active_ind = 1
			AND ner2.priority = 2
			))
	, (LEFT JOIN NOMENCLATURE nom2 ON (nom2.nomenclature_id = ner2.nomenclature_id
			AND nom2.active_ind = 1
			AND nom2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom2.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner3 ON (ner3.encntr_id = enc.encntr_id
			AND ner3.parent_entity_name = "ORDERS"
			AND ner3.parent_entity_id = ord.order_id
			AND ner3.person_id = enc.person_id
			AND ner3.person_id = ord.person_id
			AND ner3.active_ind = 1
			AND ner3.priority = 3
			))
	, (LEFT JOIN NOMENCLATURE nom3 ON (nom3.nomenclature_id = ner3.nomenclature_id
			AND nom3.active_ind = 1
			AND nom3.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom3.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner4 ON (ner4.encntr_id = enc.encntr_id
			AND ner4.parent_entity_name = "ORDERS"
			AND ner4.parent_entity_id = ord.order_id
			AND ner4.person_id = enc.person_id
			AND ner4.person_id = ord.person_id
			AND ner4.active_ind = 1
			AND ner4.priority = 4
			))
	, (LEFT JOIN NOMENCLATURE nom4 ON (nom4.nomenclature_id = ner4.nomenclature_id
			AND nom4.active_ind = 1
			AND nom4.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom4.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner5 ON (ner5.encntr_id = enc.encntr_id
			AND ner5.parent_entity_name = "ORDERS"
			AND ner5.parent_entity_id = ord.order_id
			AND ner5.person_id = enc.person_id
			AND ner5.person_id = ord.person_id
			AND ner5.active_ind = 1
			AND ner5.priority = 5
			))
	, (LEFT JOIN NOMENCLATURE nom5 ON (nom4.nomenclature_id = ner5.nomenclature_id
			AND nom5.active_ind = 1
			AND nom5.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom5.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
WHERE enc.active_ind = 1
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate)
		AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
/****************************************************************************
	Populate Record structure with Lab Detail Data
*****************************************************************************/
HEAD REPORT
	cnt = exp_data->output_cnt
 
	IF(mod(cnt,10)> 0)
   		CALL alterlist(exp_data->list, cnt + (10-mod(cnt,10)))
	ENDIF
 
	CALL ECHO ("Lab Detail Data")
    CALL ECHO (cnt)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
	exp_data->list[cnt].Record_Type = Record_Type
	exp_data->list[cnt].Service_Date = Service_Date
	exp_data->list[cnt].Accession_Number = Accession_Number
	exp_data->list[cnt].Medical_Record_Number = Medical_Record_Number
	exp_data->list[cnt].Patient_First_Name = Patient_First_Name
	exp_data->list[cnt].Patient_Middle_Name = Patient_Middle_Name
	exp_data->list[cnt].Patient_Last_Name = Patient_Last_Name
	exp_data->list[cnt].Address_1 = Address_1
	exp_data->list[cnt].Address_2 = Address_2
	exp_data->list[cnt].City = City
	exp_data->list[cnt].State = State
	exp_data->list[cnt].Zip_Code = Zip_Code
	exp_data->list[cnt].Phone_Number = Phone_Number
	exp_data->list[cnt].Birth_Date = Birth_Date
	exp_data->list[cnt].Gender = Gender
	exp_data->list[cnt].SSN = SSN
	exp_data->list[cnt].Humana_ID = Humana_ID
	exp_data->list[cnt].Medicare_ID = Medicare_ID
	exp_data->list[cnt].Medicaid_ID = Medicaid_ID
	exp_data->list[cnt].Group_Number = Group_Number
	exp_data->list[cnt].Specimen_Collection_Date = Specimen_Collection_Date
	exp_data->list[cnt].Ordering_PCP_TIN = Ordering_PCP_TIN
	exp_data->list[cnt].Ordering_PCP_UPIN = Ordering_PCP_UPIN
	exp_data->list[cnt].Ordering_PCP_NPI = Ordering_PCP_NPI
	exp_data->list[cnt].ICD_Code_1 = ICD_Code_1
	exp_data->list[cnt].ICD_Code_2 = ICD_Code_2
	exp_data->list[cnt].ICD_Code_3 = ICD_Code_3
	exp_data->list[cnt].ICD_Code_4 = ICD_Code_4
	exp_data->list[cnt].ICD_Code_5 = ICD_Code_5
	exp_data->list[cnt].Lab_Test_ID = Lab_Test_ID
	exp_data->list[cnt].Lab_Test_Name = Lab_Test_Name
	exp_data->list[cnt].Test_Panel_ID = Test_Panel_ID
	exp_data->list[cnt].Test_Panel_Name = Test_Panel_Name
	exp_data->list[cnt].Local_Lab_Code = Local_Lab_Code
	exp_data->list[cnt].Specimen_Type = Specimen_Type
	exp_data->list[cnt].Test_Method = Test_Method
	exp_data->list[cnt].Testing_Equipment_ID = Testing_Equipment_ID
	exp_data->list[cnt].LOINC = LOINC
	exp_data->list[cnt].Test_Result = Test_Result
	exp_data->list[cnt].Result_Units = Result_Units
	exp_data->list[cnt].Low_Limit_of_the_Normal_Range = Low_Limit_of_the_Normal_Range
	exp_data->list[cnt].High_Limit_of_the_Normal_Range = High_Limit_of_the_Normal_Range
	exp_data->list[cnt].Normal_Range = Normal_Range
	exp_data->list[cnt].Abnormal_Indicator = Abnormal_Indicator
	exp_data->list[cnt].CPT = CPT
	exp_data->list[cnt].Amended_Result_Indicator = Amended_Result_Indicator
	exp_data->list[cnt].Inpatient_Indicator = Inpatient_Indicator
	exp_data->list[cnt].Patient_Race = Patient_Race
	exp_data->list[cnt].Fasting_Indicator = Fasting_Indicator
	exp_data->list[cnt].Lab_Partner_Name = Lab_Partner_Name
	exp_data->list[cnt].Comment_Field_1 = Comment_Field_1
	exp_data->list[cnt].Comment_Field_2 = Comment_Field_2
	exp_data->list[cnt].Comment_Field_3 = Comment_Field_3
	exp_data->list[cnt].Comment_Field_4 = Comment_Field_4
	exp_data->list[cnt].Comment_Field_5 = Comment_Field_5
	exp_data->list[cnt].Comment_Field_6 = Comment_Field_6
	exp_data->list[cnt].Comment_Field_7 = Comment_Field_7
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 
 	CALL ECHO (cnt)
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO ("***** GETTING LAB Footer DATA ******")
/**************************************************************
; Get Lab Footer Data
**************************************************************/
 
SELECT DISTINCT
	Record_Type = "03"
	,Name_of_Facility = "Covenant Health"
	,Distinct_Patients = COUNT(DISTINCT enc_ins.member_nbr)
FROM ENCOUNTER enc
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
			AND pat.active_ind = 1
			AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
			))
	, (INNER JOIN PERSON_ALIAS ssn ON (pat.person_id = ssn.person_id
			AND ssn.alias_pool_cd = 683997.00 ;SSN
			AND ssn.active_ind = 1
			))
	, (INNER JOIN ADDRESS addr ON (pat.person_id = addr.parent_entity_id
			AND addr.parent_entity_name = "PERSON"
			AND addr.address_type_cd = 756.00 ;Home
			AND addr.active_ind = 1
			))
	, (INNER JOIN PHONE phone ON (pat.person_id = phone.parent_entity_id
			AND phone.parent_entity_name = "PERSON"
			AND phone.phone_type_cd = 170.00 ;Home
			AND phone.active_ind = 1
			))
	, (INNER JOIN ENCNTR_ALIAS mrn_nbr ON (enc.encntr_id = mrn_nbr.encntr_id
			AND mrn_nbr.active_ind = 1
    		AND mrn_nbr.encntr_alias_type_cd = 1079.00  ;MRN
    		))
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
			AND enc_ins.active_ind = 1
			))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
			AND hp_ins.active_ind = 1
			AND hp_ins.health_plan_id IN (2982968.00 /*Medicare Humana*/)
			))
	, (INNER JOIN ORDERS ord ON (ord.person_id = enc.person_id
			AND ord.encntr_id = enc.encntr_id
			AND ord.catalog_type_cd = 2513.00   ;Laboratory
			AND ord.activity_type_cd IN (692.00 /*Gen Lab*/, 674.00 /*Blood Bank*/,
			47576777.00 /*Blood Gases*/, 696.00 /*Microbiology*/)
			AND ord.order_status_cd = 2543.00   ;Completed
			))
	, (INNER JOIN ORDER_ACTION ord_act ON (ord.order_id = ord_act.order_id
			AND ord_act.action_type_cd = 2534.00 ;order
			))
	, (INNER JOIN PRSNL prov ON (ord_act.order_provider_id = prov.person_id
			AND prov.active_ind = 1
			))
	, (INNER JOIN PRSNL_ALIAS npi ON (prov.person_id = npi.person_id
			AND npi.active_ind = 1
			AND npi.alias_pool_cd = 26026547.00 ; npi
			AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
			))
	, (INNER JOIN ORDER_CATALOG ord_cat ON (ord.catalog_cd = ord_cat.catalog_cd
			AND ord_cat.active_ind = 1
			AND ord_cat.catalog_type_cd IN (2513.00 /*Laboratory*/)
			AND ord_cat.activity_type_cd IN (692.00 /*Gen Lab*/, 674.00 /*Blood Bank*/,
			47576777.00 /*Blood Gases*/, 696.00 /*Microbiology*/)
			))
	, (INNER JOIN ORDER_DETAIL ord_det ON (ord.order_id = ord_det.order_id
			AND ord_det.oe_field_meaning_id = 51.00 ;"REQSTARTDTTM"
			AND ord_det.action_sequence IN (SELECT MAX(od.action_sequence)
				FROM ORDER_DETAIL od
				WHERE ord_det.order_id = od.order_id
				AND od.oe_field_meaning_id = 51.00) ;"REQSTARTDTTM"
			))
	, (INNER JOIN ORDER_DETAIL od_spec_type ON (ord.order_id = od_spec_type.order_id
			AND od_spec_type.oe_field_meaning_id = 9.00 ; "SPECIMEN TYPE"
			AND od_spec_type.action_sequence IN (SELECT MAX(od.action_sequence)
				FROM ORDER_DETAIL od
				WHERE od_spec_type.order_id = od.order_id
				AND od.oe_field_meaning_id = 9.00); "SPECIMEN TYPE"
			))
	, (LEFT JOIN ORDER_DETAIL od_perform_loc ON (ord.order_id = od_perform_loc.order_id
				AND od_perform_loc.oe_field_meaning_id = 18.00 ; "PERFORMLOC"
			))
	, (LEFT JOIN ORDER_DETAIL od_fasting ON (ord.order_id = od_fasting.order_id
			AND od_fasting.oe_field_meaning_ID = 96.00  ; "FASTING"
			))
	, (INNER JOIN CHARGE_EVENT chgeve ON (chgeve.order_id = ord.order_id
			AND chgeve.active_ind = 1
			))
	, (INNER JOIN CHARGE c ON (c.charge_event_id = chgeve.charge_event_id
			AND c.active_ind = 1
			))
	, (INNER JOIN CHARGE_MOD cm ON (cm.charge_item_id = c.charge_item_id
			AND cm.field1_id IN (615214.00 /*CPT4*/, 3692.00 /*CPT4 MOD*/, 2555056221.00/*CPT4 MOD*/)
			AND NOT cm.FIELD6 = NULL
			AND cm.ACTIVE_IND = 1
			))
	, (INNER JOIN CLINICAL_EVENT ce ON (ord.person_id = ce.person_id
			AND ord.encntr_id = ce.encntr_id
			AND ord.order_id = ce.order_id
			AND ord_cat.catalog_cd = ce.catalog_cd
			AND TRIM(ce.result_val,3) != ""
			))
	, (INNER JOIN CODE_VALUE ce_cv1 ON (ce.event_cd = ce_cv1.code_value
			AND ce_cv1.code_set = 72  ;Description for ce.event_cd
			AND ce_cv1.active_ind = 1
			))
	, (LEFT JOIN CODE_VALUE ce_cv2 ON (ce.result_units_cd = ce_cv2.code_value
			AND ce_cv2.code_set = 54	;Description for CE.Result_Units_cd
			AND ce_cv2.active_ind = 1
			))
	, (LEFT JOIN PROFILE_TASK_R ptr ON (ord_cat.catalog_cd = ptr.catalog_cd
			AND ce.catalog_cd = ptr.catalog_cd
			AND ce.task_assay_cd = ptr.task_assay_cd
			AND ptr.active_ind = 1
			))
	, (LEFT JOIN CONCEPT_IDENTIFIER_DTA cid ON (cid.task_assay_cd = ptr.task_assay_cd
			AND cid.specimen_type_cd = od_spec_type.oe_field_value
			AND ce.resource_cd = cid.service_resource_cd
			AND ce.task_assay_cd = cid.task_assay_cd
			AND cid.active_ind = 1
			))
	, (LEFT JOIN ACCESSION_ORDER_R aor ON (ord.order_id = aor.order_id))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner1 ON (ner1.encntr_id = enc.encntr_id
			AND ner1.parent_entity_name = "ORDERS"
			AND ner1.parent_entity_id = ord.order_id
			AND ner1.person_id = enc.person_id
			AND ner1.person_id = ord.person_id
			AND ner1.active_ind = 1
			AND ner1.priority = 1
			))
	, (LEFT JOIN NOMENCLATURE nom1 ON (nom1.nomenclature_id = ner1.nomenclature_id
			AND nom1.active_ind = 1
			AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner2 ON (ner2.encntr_id = enc.encntr_id
			AND ner2.parent_entity_name = "ORDERS"
			AND ner2.parent_entity_id = ord.order_id
			AND ner2.person_id = enc.person_id
			AND ner2.person_id = ord.person_id
			AND ner2.active_ind = 1
			AND ner2.priority = 2
			))
	, (LEFT JOIN NOMENCLATURE nom2 ON (nom2.nomenclature_id = ner2.nomenclature_id
			AND nom2.active_ind = 1
			AND nom2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom2.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner3 ON (ner3.encntr_id = enc.encntr_id
			AND ner3.parent_entity_name = "ORDERS"
			AND ner3.parent_entity_id = ord.order_id
			AND ner3.person_id = enc.person_id
			AND ner3.person_id = ord.person_id
			AND ner3.active_ind = 1
			AND ner3.priority = 3
			))
	, (LEFT JOIN NOMENCLATURE nom3 ON (nom3.nomenclature_id = ner3.nomenclature_id
			AND nom3.active_ind = 1
			AND nom3.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom3.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner4 ON (ner4.encntr_id = enc.encntr_id
			AND ner4.parent_entity_name = "ORDERS"
			AND ner4.parent_entity_id = ord.order_id
			AND ner4.person_id = enc.person_id
			AND ner4.person_id = ord.person_id
			AND ner4.active_ind = 1
			AND ner4.priority = 4
			))
	, (LEFT JOIN NOMENCLATURE nom4 ON (nom4.nomenclature_id = ner4.nomenclature_id
			AND nom4.active_ind = 1
			AND nom4.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom4.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (LEFT JOIN NOMEN_ENTITY_RELTN ner5 ON (ner5.encntr_id = enc.encntr_id
			AND ner5.parent_entity_name = "ORDERS"
			AND ner5.parent_entity_id = ord.order_id
			AND ner5.person_id = enc.person_id
			AND ner5.person_id = ord.person_id
			AND ner5.active_ind = 1
			AND ner5.priority = 5
			))
	, (LEFT JOIN NOMENCLATURE nom5 ON (nom4.nomenclature_id = ner5.nomenclature_id
			AND nom5.active_ind = 1
			AND nom5.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom5.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
WHERE enc.active_ind = 1
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate)
		AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
/****************************************************************************
	Populate variables with Lab Footer Data
*****************************************************************************/
DETAIL
 
	footer = BUILD2 (Record_Type,"|",Name_of_Facility,"|",TRIM(CNVTSTRING(Distinct_Patients),3),"|")
 
FOOT REPORT
	CALL ECHO (footer)
 
WITH nocounter
 
/****************************************************************************
	Build Output
*****************************************************************************/
 
IF (exp_data->output_cnt > 0)
 	CALL ECHO ("******* Build Output *******")
 
 	SET output_rec = ""
 
 	CALL ECHO ("cnt")
 	CALL ECHO (cnt)
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	ORDER BY dt.seq
 
	head dt.seq
		output_rec = ""
		IF (dt.seq = 1) output_rec = BUILD(TRIM(header,3),cov_crlf)
		ENDIF
		output_rec = BUILD(output_rec,
			exp_data->list[dt.seq].Record_Type, cov_pipe,
			exp_data->list[dt.seq].Service_Date, cov_pipe,
			exp_data->list[dt.seq].Accession_Number, cov_pipe,
			exp_data->list[dt.seq].Medical_Record_Number, cov_pipe,
			exp_data->list[dt.seq].Patient_First_Name, cov_pipe,
			exp_data->list[dt.seq].Patient_Middle_Name, cov_pipe,
			exp_data->list[dt.seq].Patient_Last_Name, cov_pipe,
			exp_data->list[dt.seq].Address_1, cov_pipe,
			exp_data->list[dt.seq].Address_2, cov_pipe,
			exp_data->list[dt.seq].City, cov_pipe,
			exp_data->list[dt.seq].State, cov_pipe,
			exp_data->list[dt.seq].Zip_Code, cov_pipe,
			exp_data->list[dt.seq].Phone_Number, cov_pipe,
			exp_data->list[dt.seq].Birth_Date, cov_pipe,
			exp_data->list[dt.seq].Gender, cov_pipe,
			exp_data->list[dt.seq].SSN, cov_pipe,
			exp_data->list[dt.seq].Humana_ID, cov_pipe,
			exp_data->list[dt.seq].Medicare_ID, cov_pipe,
			exp_data->list[dt.seq].Medicaid_ID, cov_pipe,
			exp_data->list[dt.seq].Group_Number, cov_pipe,
			exp_data->list[dt.seq].Specimen_Collection_Date, cov_pipe,
			exp_data->list[dt.seq].Ordering_PCP_TIN, cov_pipe,
			exp_data->list[dt.seq].Ordering_PCP_UPIN, cov_pipe,
			exp_data->list[dt.seq].Ordering_PCP_NPI, cov_pipe,
			exp_data->list[dt.seq].ICD_Code_1, cov_pipe,
			exp_data->list[dt.seq].ICD_Code_2, cov_pipe,
			exp_data->list[dt.seq].ICD_Code_3, cov_pipe,
			exp_data->list[dt.seq].ICD_Code_4, cov_pipe,
			exp_data->list[dt.seq].ICD_Code_5, cov_pipe,
			exp_data->list[dt.seq].Lab_Test_ID, cov_pipe,
			exp_data->list[dt.seq].Lab_Test_Name, cov_pipe,
			exp_data->list[dt.seq].Test_Panel_ID, cov_pipe,
			exp_data->list[dt.seq].Test_Panel_Name, cov_pipe,
			exp_data->list[dt.seq].Local_Lab_Code, cov_pipe,
			exp_data->list[dt.seq].Specimen_Type, cov_pipe,
			exp_data->list[dt.seq].Test_Method, cov_pipe,
			exp_data->list[dt.seq].Testing_Equipment_ID, cov_pipe,
			exp_data->list[dt.seq].LOINC, cov_pipe,
			exp_data->list[dt.seq].Test_Result, cov_pipe,
			exp_data->list[dt.seq].Result_Units, cov_pipe,
			exp_data->list[dt.seq].Low_Limit_of_the_Normal_Range, cov_pipe,
			exp_data->list[dt.seq].High_Limit_of_the_Normal_Range, cov_pipe,
			exp_data->list[dt.seq].Normal_Range, cov_pipe,
			exp_data->list[dt.seq].Abnormal_Indicator, cov_pipe,
			exp_data->list[dt.seq].CPT, cov_pipe,
			exp_data->list[dt.seq].Amended_Result_Indicator, cov_pipe,
			exp_data->list[dt.seq].Inpatient_Indicator, cov_pipe,
			exp_data->list[dt.seq].Patient_Race, cov_pipe,
			exp_data->list[dt.seq].Fasting_Indicator, cov_pipe,
			exp_data->list[dt.seq].Lab_Partner_Name, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_1, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_2, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_3, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_4, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_5, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_6, cov_pipe,
			exp_data->list[dt.seq].Comment_Field_7)
 		IF (dt.seq = exp_data->output_cnt)
 			output_rec = BUILD2(output_rec,cov_crlf,footer,TRIM(CNVTSTRING(exp_data->output_cnt),3))
 		ENDIF
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, format=stream, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
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

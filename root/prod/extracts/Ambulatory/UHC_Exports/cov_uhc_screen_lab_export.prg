/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		8/22/2019
	Solution:			Ambulatory
	Source file name:	cov_uhc_screen_lab_export.prg
	Object name:		cov_uhc_screen_lab_export
	Request #:			5394
 
	Program purpose:	Export Colonoscopy/Breast/BMI/Lab data to send to
						UHC for meeting measures.
 
	Executing from:		CCL
 
 	Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	---------------------------------------
 
******************************************************************************/
 
drop program cov_uhc_screen_lab_export go
create program cov_uhc_screen_lab_export
 
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
 
DECLARE file_var			= vc WITH noconstant("tn_covenant_test_uhc_")
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
 
SET startdate = CNVTDATETIME(CURDATE-45,0)
SET enddate = CNVTDATETIME(CURDATE-15,235959)
 
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q")," *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
 
RECORD exp_data (
	1 output_cnt = i4
	1 list[*]
	    2 pt_id_no = VC
	    2 subscriber_id = VC
	    2 medicaid_subscriber_nbr = VC
	    2 medicare_subscriber_nbr = VC
	    2 member_alt_id_1 = VC
	    2 member_alt_id_2 = VC
	    2 member_alt_id_3 = VC
	    2 member_first_nm = VC
	    2 member_middle_nm = VC
	    2 member_last_nm = VC
	    2 member_date_of_birth = VC
	    2 member_gender = VC
	    2 race = VC
	    2 member_address_1 = VC
	    2 member_address_2 = VC
	    2 member_city = VC
	    2 member_state = VC
	    2 member_zip = VC
	    2 member_phone_1 = VC
	    2 dependent_number = VC
	    2 Rendering_NPI = VC
	    2 Rendering_MPIN = VC
	    2 Rendering_TIN = VC
	    2 Rend_Prov_Specialty = VC
	    2 Ordering_NPI = VC
	    2 Ordering_MPIN = VC
	    2 Ordering_TIN = VC
	    2 Ordering_Prov_Specialty = VC
	    2 rendering_provider_first_nm = VC
	    2 rendering_provider_middle_nm = VC
	    2 rendering_provider_last_nm = VC
	    2 rendering_provider_dea_code = VC
	    2 rendering_provider_deg_cd = VC
	    2 rendering_provider_address_1 = VC
	    2 rendering_provider_address_2 = VC
	    2 rendering_provider_city = VC
	    2 rendering_provider_state = VC
	    2 rendering_provider_zip = VC
	    2 rendering_provider_phone_1 = VC
	    2 rendering_provider_phone_2 = VC
	    2 rendering_provider_alt_id = VC
	    2 Service_Date_From = VC
	    2 Service_Date_Through = VC
	    2 icd_code_type = VC
	    2 icd_diagnosis_cd_1 = VC
	    2 icd_diagnosis_cd_2 = VC
	    2 icd_diagnosis_cd_3 = VC
	    2 icd_diagnosis_cd_4 = VC
	    2 icd_diagnosis_cd_5 = VC
	    2 icd_diagnosis_cd_6 = VC
	    2 icd_diagnosis_cd_7 = VC
	    2 icd_diagnosis_cd_8 = VC
	    2 icd_diagnosis_cd_9 = VC
	    2 cpt_code = VC
	    2 cpt_code_mod_1 = VC
	    2 cpt_code_mod_2 = VC
	    2 cpt2_code = VC
	    2 hcpcs_code = VC
	    2 hcpcs_mod = VC
	    2 icd_procedure_cd_1 = VC
	    2 icd_procedure_cd_2 = VC
	    2 UB_Revenue_Code = VC
	    2 type_of_service_code = VC
	    2 quantity_of_service = VC
	    2 pcp_flg = VC
	    2 BP_Systolic = VC
	    2 BP_Diastolic = VC
	    2 BMI_Result = VC
	    2 BMI_Percentile = VC
	    2 Member_Height = VC
	    2 Member_Weight = VC
	    2 clin_user_defined_1= VC
	    2 clin_user_defined_2 = VC
	    2 clin_user_defined_3 = VC
	    2 clin_user_defined_4 = VC
	    2 clin_user_defined_5 = VC
	    2 clin_user_defined_6 = VC
	    2 place_of_service_code = VC
	    2 ref_range = VC
	    2 ab_ind = VC
	    2 Fill_ord_num = VC
	    2 lab_claim_id_1 = VC
	    2 lab_id = VC
	    2 lab_user_defined_1 = VC
	    2 lab_user_defined_2 = VC
	    2 loinc = VC
	    2 lab_test_desc = VC
	    2 obs_rslt_status = VC
	    2 result_dt = VC
	    2 order_dt = VC
	    2 service_dt = VC
	    2 pos_neg_rslt = VC
	    2 lab_result_text = VC
	    2 result = VC
	    2 snomed = VC
	    2 unit = VC
	    2 National_drug_cd = VC
	    2 qty_dispensed = VC
	    2 fill_date = VC
	    2 days_supply = VC
	    2 dea_nbr = VC
	    2 denied_flg = VC
	    2 generic_sts = VC
	    2 Pharmacy_ID = VC
	    2 pharmacy_nm = VC
	    2 pharmacy_type_cd = VC
	    2 prescribing_prov_id = VC
	    2 rx_claim_alt_id_1 = VC
	    2 rx_claim_alt_id_2 = VC
	    2 rx_claim_alt_id_3 = VC
	    2 rx_claim_alt_id_4 = VC
	    2 requested_amt = VC
	    2 supply_flag = VC
	    2 cvx = VC
	    2 Practice_TIN = VC
	)
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/UHC/Screenings_Lab/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
CALL ECHO ("***** GETTING COLONOSCOPY ORDER DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Colonoscopy Order Data
**************************************************************/
 
SELECT DISTINCT
	pt_id_no = EVALUATE2(IF (SIZE(cmrn_nbr.alias) = 0) " " ELSE TRIM(cmrn_nbr.alias,3) ENDIF)
	,subscriber_id = EVALUATE2(IF (SIZE(enc_ins.MEMBER_NBR) = 0) " " ELSE TRIM(enc_ins.MEMBER_NBR,3) ENDIF)
	,medicaid_subscriber_nbr = " "
	,medicare_subscriber_nbr = " "
	,member_alt_id_1 = " "
	,member_alt_id_2 = " "
	,member_alt_id_3 = " "
	,member_first_nm = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,member_middle_nm = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,member_last_nm = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,member_date_of_birth = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(pat.birth_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,member_gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,race = EVALUATE(pat.race_cd, 0.00, "Other Race None", 309318.00, "American Indian or Alaska Native",
	     309317.00,	"Asian", 309315.00, "Black or African American", 23274729.00, "Other Race Multiple",
    	4189861.00, "Native Hawaiian or Pacific Islander", 18702439.00,	"Other Race Patient Declined",
	   25804105.00,	"Other Race Unavailable",309316.00, "White"," ")
    ,member_address_1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
    ,member_address_2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
    ,member_city = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
    ,member_state = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
    ,member_zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
    ,member_phone_1 = " "
    ,dependent_number = " "
	,Rendering_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Rendering_MPIN = " "
	,Rendering_TIN = " "
	,Rend_Prov_Specialty = EVALUATE2(IF (prov_spec.specialty_cd = 0.00) " "
			ELSE UAR_GET_CODE_DISPLAY(prov_spec.specialty_cd) ENDIF)
	,Ordering_NPI = " "
	,Ordering_MPIN = " "
	,Ordering_TIN = " "
	,Ordering_Prov_Specialty = " "
	,rendering_provider_first_nm = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,rendering_provider_middle_nm = " "
	,rendering_provider_last_nm = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,rendering_provider_dea_code = EVALUATE2(IF (SIZE(dea.alias) = 0) " " ELSE TRIM(dea.alias,3) ENDIF)
	,rendering_provider_deg_cd = " "
	,rendering_provider_address_1 = EVALUATE2(IF (SIZE(prov_addr.street_addr) = 0) " "
		ELSE TRIM(prov_addr.street_addr,3) ENDIF)
	,rendering_provider_address_2 = EVALUATE2(IF (SIZE(prov_addr.street_addr2) = 0) " "
		ELSE TRIM(prov_addr.street_addr2,3) ENDIF)
	,rendering_provider_city = EVALUATE2(IF (SIZE(prov_addr.city) = 0) " " ELSE TRIM(prov_addr.city,3) ENDIF)
	,rendering_provider_state = EVALUATE2(IF (SIZE(prov_addr.state) = 0) " " ELSE TRIM(prov_addr.State,3) ENDIF)
	,rendering_provider_zip = EVALUATE2(IF (SIZE(prov_addr.zipcode_key) = 0) " "
		ELSE TRIM(SUBSTRING(1,5,prov_addr.zipcode_key),3) ENDIF)
	,rendering_provider_phone_1 = " "
	,rendering_provider_phone_2 = " "
	,rendering_provider_alt_id = " "
    ,Service_Date_From = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,Service_Date_Through = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,icd_code_type = "0"
	,icd_diagnosis_cd_1 = EVALUATE2(IF (SIZE(nom_diag.source_identifier) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,icd_diagnosis_cd_2 = " "
	,icd_diagnosis_cd_3 = " "
	,icd_diagnosis_cd_4 = " "
	,icd_diagnosis_cd_5 = " "
	,icd_diagnosis_cd_6 = " "
	,icd_diagnosis_cd_7 = " "
	,icd_diagnosis_cd_8 = " "
	,icd_diagnosis_cd_9 = " "
	,cpt_code = EVALUATE2(IF (SIZE(ord_cat.description) = 0) " "
			ELSE SUBSTRING(FINDSTRING(' ',TRIM(ord_cat.description,3),1,1)+1,5,TRIM(ord_cat.description,3)) ENDIF)
	,cpt_code_mod_1 = " "
	,cpt_code_mod_2 = " "
	,cpt2_code = " "
	,hcpcs_code = " "
	,hcpcs_mod = " "
	,icd_procedure_cd_1 = " "
	,icd_procedure_cd_2 = " "
	,UB_Revenue_Code = " "
	,type_of_service_code = "Outpatient"
	,quantity_of_service = " "
	,pcp_flg = "Y"
	,BP_Systolic = " "
	,BP_Diastolic = " "
	,BMI_Result = " "
	,BMI_Percentile = " "
	,Member_Height = " "
	,Member_Weight = " "
	,clin_user_defined_1 = " "
	,clin_user_defined_2 = " "
	,clin_user_defined_3 = " "
	,clin_user_defined_4 = " "
	,clin_user_defined_5 = " "
	,clin_user_defined_6 = " "
	,place_of_service_code = "OC"
	,ref_range = " "
	,ab_ind = " "
	,Fill_ord_num = " "
	,lab_claim_id_1 = " "
	,lab_id = " "
	,lab_user_defined_1 = " "
	,lab_user_defined_2 = " "
	,loinc = " "
	,lab_test_desc = " "
	,obs_rslt_status = " "
	,result_dt = " "
	,order_dt = " "
	,service_dt = " "
	,pos_neg_rslt = " "
	,lab_result_text = " "
	,result = " "
	,snomed = " "
	,unit = " "
	,National_drug_cd = " "
	,qty_dispensed = " "
	,fill_date = " "
	,days_supply = " "
	,dea_nbr = " "
	,denied_flg = " "
	,generic_sts = " "
	,Pharmacy_ID = " "
	,pharmacy_nm = " "
	,pharmacy_type_cd = " "
	,prescribing_prov_id = " "
	,rx_claim_alt_id_1 = " "
	,rx_claim_alt_id_2 = " "
	,rx_claim_alt_id_3 = " "
	,rx_claim_alt_id_4 = " "
	,requested_amt = " "
	,supply_flag = " "
	,cvx = " "
	,Practice_TIN = "62-1282917"
FROM ENCOUNTER enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
		AND fin_nbr.active_ind = 1
		AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND fin_nbr.alias_pool_cd = 2554138229.00   ;FIN
   		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
		AND pat.active_ind = 1
		AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
		))
	, (INNER JOIN PERSON_ALIAS cmrn_nbr ON (pat.person_id = cmrn_nbr.person_id
		AND cmrn_nbr.active_ind = 1
		AND cmrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cmrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND cmrn_nbr.person_alias_type_cd =  2.00   ;CMRN
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
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
		AND enc_ins.active_ind = 1
		AND enc_ins.priority_seq = 1
		AND enc_ins.member_nbr != ' '
		AND enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
		AND hp_ins.active_ind = 1
		AND hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.health_plan_id IN (2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
   			2985957.00 /*Medicare UHC Dual Complete Part B*/,2985961.00 /*Medicare UHC IP Denial Part B*/,
   			2983341.00 /*Misc United Healthcare*/,2983161.00 /*United Healthcare*/,
   			2983345.00 /*United Healthcare Community*/)
		))
	, (INNER JOIN ENCNTR_PRSNL_RELTN epr ON (enc.encntr_id = epr.encntr_id
		AND epr.priority_seq = 1
		AND epr.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
		AND epr.active_ind = 1
		AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		))
    , (INNER JOIN PRSNL prov ON (epr.prsnl_person_id = prov.person_id
   		AND prov.active_ind = 1
   		AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		))
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN prov_spec ON (prov.person_id = prov_spec.prsnl_id
		AND prov_spec.active_ind = 1
		AND prov_spec.primary_ind = 1
		AND prov_spec.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_spec.end_effective_dt_Tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
		))
	, (LEFT JOIN PRSNL_ALIAS dea ON (epr.prsnl_person_id = dea.person_id
		AND dea.active_ind = 1
		AND dea.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.prsnl_alias_type_cd = 1084.00  ;dea
		))
	, (INNER JOIN ADDRESS prov_addr ON (prov.person_id = prov_addr.parent_entity_id
		AND prov_addr.parent_entity_name = "PERSON"
		AND prov_addr.active_ind = 1
		AND prov_addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov_addr.address_type_cd = 754.00   ;BUSINESS
   		AND prov_addr.address_type_seq = 1
		AND prov_addr.address_id IN (SELECT MAX(prov_addr1.address_id) FROM address prov_addr1
			WHERE prov_addr1.parent_entity_id = prov.person_id
			AND prov_addr1.parent_entity_name = "PERSON"
			AND prov_addr1.active_ind = 1
			AND prov_addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.address_type_cd = 754.00 ;BUSINESS
			AND prov_addr1.address_type_seq = 1
			)   
   		))
	, (INNER JOIN ORDERS ord ON (ord.encntr_id = enc.encntr_id
		AND ord.person_id = pat.person_id
		AND ord.order_status_cd = 2543.00   ;Completed
		))
	, (INNER JOIN ORDER_CATALOG ord_cat ON (ord.catalog_cd = ord_cat.catalog_cd
		AND ord_cat.active_ind = 1
		AND ord_cat.catalog_cd IN ( 2557640891.00 /*44388*/,211716411 /*44391*/,2557640951.00 /*45330*/,2557640971 /*45378*/,
			211717815 /*45379*/,2557640981 /*45380*/,2557642351 /*45381*/,2557642361 /*45382*/,2557642371 /*45384*/,
			2557642381 /*45385*/,2557711759 /*45388*/,2557711769 /*45393*/,2557711749 /*4537853*/,2559797587.00 /*82274*/,
			2552573681.00 /*G0104*/, 2557732691.00 /*G0105*/, 2557732701.00 /*G0121*/,2557495729.00 /*G0328*/)
		AND ord_cat.catalog_type_cd IN (20454826.00 /*Ambulatory POC*/, 20460012.00 /*Ambulatory procedures*/)
		))
	, (INNER JOIN NOMEN_ENTITY_RELTN ner ON (ner.encntr_id = enc.encntr_id
		AND ner.parent_entity_id = ord.order_id
		AND ner.person_id = enc.person_id AND ner.person_id = ord.person_id
		AND ner.active_ind = 1
		AND ner.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND ner.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND ner.priority = 1
		))
	, (INNER JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = ner.nomenclature_id
		AND nom_diag.active_ind = 1
		AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
WHERE enc.active_ind = 1
	AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,2560523697/*Results Only*/,20058643/*Legacy Data*/)
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate)
	AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
 
/****************************************************************************
	Populate Record structure with Colonoscopy Order Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(exp_data->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
	exp_data->list[cnt].pt_id_no = pt_id_no
	exp_data->list[cnt].subscriber_id = subscriber_id
	exp_data->list[cnt].medicaid_subscriber_nbr = medicaid_subscriber_nbr
	exp_data->list[cnt].medicare_subscriber_nbr = medicare_subscriber_nbr
	exp_data->list[cnt].member_alt_id_1 = member_alt_id_1
	exp_data->list[cnt].member_alt_id_2 = member_alt_id_2
	exp_data->list[cnt].member_alt_id_3 = member_alt_id_3
	exp_data->list[cnt].member_first_nm = member_first_nm
	exp_data->list[cnt].member_middle_nm = member_middle_nm
	exp_data->list[cnt].member_last_nm = member_last_nm
	exp_data->list[cnt].member_date_of_birth = member_date_of_birth
	exp_data->list[cnt].member_gender = member_gender
	exp_data->list[cnt].race = race
	exp_data->list[cnt].member_address_1 = member_address_1
	exp_data->list[cnt].member_address_2 = member_address_2
	exp_data->list[cnt].member_city = member_city
	exp_data->list[cnt].member_state = member_state
	exp_data->list[cnt].member_zip = member_zip
	exp_data->list[cnt].member_phone_1 = member_phone_1
	exp_data->list[cnt].dependent_number = dependent_number
	exp_data->list[cnt].Rendering_NPI = Rendering_NPI
	exp_data->list[cnt].Rendering_MPIN = Rendering_MPIN
	exp_data->list[cnt].Rendering_TIN = Rendering_TIN
	exp_data->list[cnt].Rend_Prov_Specialty = Rend_Prov_Specialty
	exp_data->list[cnt].Ordering_NPI = Ordering_NPI
	exp_data->list[cnt].Ordering_MPIN = Ordering_MPIN
	exp_data->list[cnt].Ordering_TIN = Ordering_TIN
	exp_data->list[cnt].Ordering_Prov_Specialty = Ordering_Prov_Specialty
	exp_data->list[cnt].rendering_provider_first_nm = rendering_provider_first_nm
	exp_data->list[cnt].rendering_provider_middle_nm = rendering_provider_middle_nm
	exp_data->list[cnt].rendering_provider_last_nm = rendering_provider_last_nm
	exp_data->list[cnt].rendering_provider_dea_code = rendering_provider_dea_code
	exp_data->list[cnt].rendering_provider_deg_cd = rendering_provider_deg_cd
	exp_data->list[cnt].rendering_provider_address_1 = rendering_provider_address_1
	exp_data->list[cnt].rendering_provider_address_2 = rendering_provider_address_2
	exp_data->list[cnt].rendering_provider_city = rendering_provider_city
	exp_data->list[cnt].rendering_provider_state = rendering_provider_state
	exp_data->list[cnt].rendering_provider_zip = rendering_provider_zip
	exp_data->list[cnt].rendering_provider_phone_1 = rendering_provider_phone_1
	exp_data->list[cnt].rendering_provider_phone_2 = rendering_provider_phone_2
	exp_data->list[cnt].rendering_provider_alt_id = rendering_provider_alt_id
	exp_data->list[cnt].Service_Date_From = Service_Date_From
	exp_data->list[cnt].Service_Date_Through = Service_Date_Through
	exp_data->list[cnt].icd_code_type = icd_code_type
	exp_data->list[cnt].icd_diagnosis_cd_1 = icd_diagnosis_cd_1
	exp_data->list[cnt].icd_diagnosis_cd_2 = icd_diagnosis_cd_2
	exp_data->list[cnt].icd_diagnosis_cd_3 = icd_diagnosis_cd_3
	exp_data->list[cnt].icd_diagnosis_cd_4 = icd_diagnosis_cd_4
	exp_data->list[cnt].icd_diagnosis_cd_5 = icd_diagnosis_cd_5
	exp_data->list[cnt].icd_diagnosis_cd_6 = icd_diagnosis_cd_6
	exp_data->list[cnt].icd_diagnosis_cd_7 = icd_diagnosis_cd_7
	exp_data->list[cnt].icd_diagnosis_cd_8 = icd_diagnosis_cd_8
	exp_data->list[cnt].icd_diagnosis_cd_9 = icd_diagnosis_cd_9
	exp_data->list[cnt].cpt_code = cpt_code
	exp_data->list[cnt].cpt_code_mod_1 = cpt_code_mod_1
	exp_data->list[cnt].cpt_code_mod_2 = cpt_code_mod_2
	exp_data->list[cnt].cpt2_code = cpt2_code
	exp_data->list[cnt].hcpcs_code = hcpcs_code
	exp_data->list[cnt].hcpcs_mod = hcpcs_mod
	exp_data->list[cnt].icd_procedure_cd_1 = icd_procedure_cd_1
	exp_data->list[cnt].icd_procedure_cd_2 = icd_procedure_cd_2
	exp_data->list[cnt].UB_Revenue_Code = UB_Revenue_Code
	exp_data->list[cnt].type_of_service_code = type_of_service_code
	exp_data->list[cnt].quantity_of_service = quantity_of_service
	exp_data->list[cnt].pcp_flg = pcp_flg
	exp_data->list[cnt].BP_Systolic = BP_Systolic
	exp_data->list[cnt].BP_Diastolic = BP_Diastolic
	exp_data->list[cnt].BMI_Result = BMI_Result
	exp_data->list[cnt].BMI_Percentile = BMI_Percentile
	exp_data->list[cnt].Member_Height = Member_Height
	exp_data->list[cnt].Member_Weight = Member_Weight
	exp_data->list[cnt].clin_user_defined_1 = clin_user_defined_1
	exp_data->list[cnt].clin_user_defined_2 = clin_user_defined_2
	exp_data->list[cnt].clin_user_defined_3 = clin_user_defined_3
	exp_data->list[cnt].clin_user_defined_4 = clin_user_defined_4
	exp_data->list[cnt].clin_user_defined_5 = clin_user_defined_5
	exp_data->list[cnt].clin_user_defined_6 = clin_user_defined_6
	exp_data->list[cnt].place_of_service_code = place_of_service_code
	exp_data->list[cnt].ref_range = ref_range
	exp_data->list[cnt].ab_ind = ab_ind
	exp_data->list[cnt].Fill_ord_num = Fill_ord_num
	exp_data->list[cnt].lab_claim_id_1 = lab_claim_id_1
	exp_data->list[cnt].lab_id = lab_id
	exp_data->list[cnt].lab_user_defined_1 = lab_user_defined_1
	exp_data->list[cnt].lab_user_defined_2 = lab_user_defined_2
	exp_data->list[cnt].loinc = loinc
	exp_data->list[cnt].lab_test_desc = lab_test_desc
	exp_data->list[cnt].obs_rslt_status = obs_rslt_status
	exp_data->list[cnt].result_dt = result_dt
	exp_data->list[cnt].order_dt = order_dt
	exp_data->list[cnt].service_dt = service_dt
	exp_data->list[cnt].pos_neg_rslt = pos_neg_rslt
	exp_data->list[cnt].lab_result_text = lab_result_text
	exp_data->list[cnt].result = result
	exp_data->list[cnt].snomed = snomed
	exp_data->list[cnt].unit = unit
	exp_data->list[cnt].National_drug_cd = National_drug_cd
	exp_data->list[cnt].qty_dispensed = qty_dispensed
	exp_data->list[cnt].fill_date = fill_date
	exp_data->list[cnt].days_supply = days_supply
	exp_data->list[cnt].dea_nbr = dea_nbr
	exp_data->list[cnt].denied_flg = denied_flg
	exp_data->list[cnt].generic_sts = generic_sts
	exp_data->list[cnt].Pharmacy_ID = Pharmacy_ID
	exp_data->list[cnt].pharmacy_nm = pharmacy_nm
	exp_data->list[cnt].pharmacy_type_cd = pharmacy_type_cd
	exp_data->list[cnt].prescribing_prov_id = prescribing_prov_id
	exp_data->list[cnt].rx_claim_alt_id_1 = rx_claim_alt_id_1
	exp_data->list[cnt].rx_claim_alt_id_2 = rx_claim_alt_id_2
	exp_data->list[cnt].rx_claim_alt_id_3 = rx_claim_alt_id_3
	exp_data->list[cnt].rx_claim_alt_id_4 = rx_claim_alt_id_4
	exp_data->list[cnt].requested_amt = requested_amt
	exp_data->list[cnt].supply_flag = supply_flag
	exp_data->list[cnt].cvx = cvx
	exp_data->list[cnt].Practice_TIN = Practice_TIN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
    CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
 
CALL ECHO ("***** GETTING COLONOSCOPY PROCEDURE DATA *****")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Colonoscopy Procedure Data
**************************************************************/
SELECT DISTINCT
	pt_id_no = EVALUATE2(IF (SIZE(cmrn_nbr.alias) = 0) " " ELSE TRIM(cmrn_nbr.alias,3) ENDIF)
	,subscriber_id = EVALUATE2(IF (SIZE(enc_ins.MEMBER_NBR) = 0) " " ELSE TRIM(enc_ins.MEMBER_NBR,3) ENDIF)
	,medicaid_subscriber_nbr = " "
	,medicare_subscriber_nbr = " "
	,member_alt_id_1 = " "
	,member_alt_id_2 = " "
	,member_alt_id_3 = " "
	,member_first_nm = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,member_middle_nm = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,member_last_nm = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,member_date_of_birth = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(pat.birth_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,member_gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,race = EVALUATE(pat.race_cd, 0.00, "Other Race None", 309318.00, "American Indian or Alaska Native",
	     309317.00,	"Asian", 309315.00, "Black or African American", 23274729.00, "Other Race Multiple",
    	4189861.00, "Native Hawaiian or Pacific Islander", 18702439.00,	"Other Race Patient Declined",
	   25804105.00,	"Other Race Unavailable",309316.00, "White"," ")
    ,member_address_1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
    ,member_address_2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
    ,member_city = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
    ,member_state = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
    ,member_zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
    ,member_phone_1 = " "
    ,dependent_number = " "
	,Rendering_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Rendering_MPIN = " "
	,Rendering_TIN = " "
	,Rend_Prov_Specialty = EVALUATE2(IF (prov_spec.specialty_cd = 0.00) " "
			ELSE UAR_GET_CODE_DISPLAY(prov_spec.specialty_cd) ENDIF)
	,Ordering_NPI = " "
	,Ordering_MPIN = " "
	,Ordering_TIN = " "
	,Ordering_Prov_Specialty = " "
	,rendering_provider_first_nm = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,rendering_provider_middle_nm = " "
	,rendering_provider_last_nm = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,rendering_provider_dea_code = EVALUATE2(IF (SIZE(dea.alias) = 0) " " ELSE TRIM(dea.alias,3) ENDIF)
	,rendering_provider_deg_cd = " "
	,rendering_provider_address_1 = EVALUATE2(IF (SIZE(prov_addr.street_addr) = 0) " "
		ELSE TRIM(prov_addr.street_addr,3) ENDIF)
	,rendering_provider_address_2 = EVALUATE2(IF (SIZE(prov_addr.street_addr2) = 0) " "
		ELSE TRIM(prov_addr.street_addr2,3) ENDIF)
	,rendering_provider_city = EVALUATE2(IF (SIZE(prov_addr.city) = 0) " " ELSE TRIM(prov_addr.city,3) ENDIF)
	,rendering_provider_state = EVALUATE2(IF (SIZE(prov_addr.state) = 0) " " ELSE TRIM(prov_addr.State,3) ENDIF)
	,rendering_provider_zip = EVALUATE2(IF (SIZE(prov_addr.zipcode_key) = 0) " "
		ELSE TRIM(SUBSTRING(1,5,prov_addr.zipcode_key),3) ENDIF)
	,rendering_provider_phone_1 = " "
	,rendering_provider_phone_2 = " "
	,rendering_provider_alt_id = " "
    ,Service_Date_From = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,Service_Date_Through = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,icd_code_type = "0"
	,icd_diagnosis_cd_1 = EVALUATE2(IF (SIZE(nom_diag.source_identifier) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,icd_diagnosis_cd_2 = " "
	,icd_diagnosis_cd_3 = " "
	,icd_diagnosis_cd_4 = " "
	,icd_diagnosis_cd_5 = " "
	,icd_diagnosis_cd_6 = " "
	,icd_diagnosis_cd_7 = " "
	,icd_diagnosis_cd_8 = " "
	,icd_diagnosis_cd_9 = " "
	,cpt_code = EVALUATE2(IF (SIZE(cv_nom.display) = 0 OR TRIM(cv_nom.display,3) IN ("CPT4","SNOMED CT")) nom.source_identifier
		ELSE SUBSTRING(1,SIZE(cv_nom.display),TRIM(cv_nom.display,3)) ENDIF)
	,cpt_code_mod_1 = " "
	,cpt_code_mod_2 = " "
	,cpt2_code = " "
	,hcpcs_code = " "
	,hcpcs_mod = " "
	,icd_procedure_cd_1 = " "
	,icd_procedure_cd_2 = " "
	,UB_Revenue_Code = " "
	,type_of_service_code = "Outpatient"
	,quantity_of_service = " "
	,pcp_flg = "Y"
	,BP_Systolic = " "
	,BP_Diastolic = " "
	,BMI_Result = " "
	,BMI_Percentile = " "
	,Member_Height = " "
	,Member_Weight = " "
	,clin_user_defined_1 = " "
	,clin_user_defined_2 = " "
	,clin_user_defined_3 = " "
	,clin_user_defined_4 = " "
	,clin_user_defined_5 = " "
	,clin_user_defined_6 = " "
	,place_of_service_code = "OC"
	,ref_range = " "
	,ab_ind = " "
	,Fill_ord_num = " "
	,lab_claim_id_1 = " "
	,lab_id = " "
	,lab_user_defined_1 = " "
	,lab_user_defined_2 = " "
	,loinc = " "
	,lab_test_desc = " "
	,obs_rslt_status = " "
	,result_dt = " "
	,order_dt = " "
	,service_dt = " "
	,pos_neg_rslt = " "
	,lab_result_text = " "
	,result = " "
	,snomed = " "
	,unit = " "
	,National_drug_cd = " "
	,qty_dispensed = " "
	,fill_date = " "
	,days_supply = " "
	,dea_nbr = " "
	,denied_flg = " "
	,generic_sts = " "
	,Pharmacy_ID = " "
	,pharmacy_nm = " "
	,pharmacy_type_cd = " "
	,prescribing_prov_id = " "
	,rx_claim_alt_id_1 = " "
	,rx_claim_alt_id_2 = " "
	,rx_claim_alt_id_3 = " "
	,rx_claim_alt_id_4 = " "
	,requested_amt = " "
	,supply_flag = " "
	,cvx = " "
	,Practice_TIN = "62-1282917"
FROM ENCOUNTER   enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
		AND fin_nbr.active_ind = 1
		AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    	AND fin_nbr.alias_pool_cd = 2554138229.00   ;FIN
  		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
		AND pat.active_ind = 1
		AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
		))
	, (INNER JOIN PERSON_ALIAS cmrn_nbr ON (pat.person_id = cmrn_nbr.person_id
		AND cmrn_nbr.active_ind = 1
		AND cmrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cmrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND cmrn_nbr.person_alias_type_cd =  2.00   ;CMRN
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
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
		AND enc_ins.active_ind = 1
		AND enc_ins.priority_seq = 1
		AND enc_ins.member_nbr != ' '
		AND enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
		AND hp_ins.active_ind = 1
		AND hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.health_plan_id IN (2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
    		2985957.00 /*Medicare UHC Dual Complete Part B*/,2985961.00 /*Medicare UHC IP Denial Part B*/,
    		2983341.00 /*Misc United Healthcare*/,2983161.00 /*United Healthcare*/,
    		2983345.00 /*United Healthcare Community*/)
		))
	, (INNER JOIN ENCNTR_PRSNL_RELTN epr ON (enc.encntr_id = epr.encntr_id
		AND epr.priority_seq = 1
		AND epr.encntr_prsnl_r_cd IN (1116/*Admitting*/,1119/*Attending*/,681283/*NP*/,681284 /*PA*/)
		AND epr.active_ind = 1
		AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL prov ON (epr.prsnl_person_id = prov.person_id
    	AND prov.active_ind = 1
    	AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
    	AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    	))
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN prov_spec ON (prov.person_id = prov_spec.prsnl_id
		AND prov_spec.active_ind = 1
		AND prov_spec.primary_ind = 1
		AND prov_spec.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_spec.end_effective_dt_Tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
		))
	, (LEFT JOIN PRSNL_ALIAS dea ON (epr.prsnl_person_id = dea.person_id
		AND dea.active_ind = 1
		AND dea.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.prsnl_alias_type_cd = 1084.00  ;dea
		))
	, (INNER JOIN ADDRESS prov_addr ON (prov.person_id = prov_addr.parent_entity_id
		AND prov_addr.parent_entity_name = "PERSON"
		AND prov_addr.active_ind = 1
		AND prov_addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov_addr.address_type_cd = 754.00   ;BUSINESS
		AND prov_addr.address_id IN (SELECT MAX(prov_addr1.address_id) FROM address prov_addr1
			WHERE prov_addr1.parent_entity_id = prov.person_id
			AND prov_addr1.parent_entity_name = "PERSON"
			AND prov_addr1.active_ind = 1
			AND prov_addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.address_type_cd = 754.00)   ;BUSINESS
   		))
	, (INNER JOIN PROCEDURE proc ON (proc.encntr_id = ENC.encntr_id
		AND proc.active_ind = 1
		AND proc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND proc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND (proc.proc_dt_tm >= CNVTDATETIME(startdate) AND proc.proc_dt_tm <= CNVTDATETIME(enddate))
		))
	, (INNER JOIN NOMENCLATURE nom ON (proc.nomenclature_id = nom.nomenclature_id
		AND nom.active_ind = 1
		AND nom.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND nom.nomenclature_id IN (60677402/*44388*/,283988885/*44388*/,60658190/*44389*/,283992216/*44389*/,
			60677404/*44391*/,60677405/*44392*/,283990970/*44392*/,284004260/*44394*/,60680371/*44394*/,60683826/*44402*/,
			60683828/*44403*/,60683829/*44404*/,60683461/*44406*/,283288958/*45378*/,60677829/*45378*/,284167497/*45379*/,
			60677830/*45379*/,283288974/*45380*/,60677831/*45380*/,283291100/*45381*/,60677832/*45381*/,60677833/*45382*/,
			283873498/*45382*/,60677834/*45384*/,283291331/*45384*/,60677835/*45385*/,283288961/*45385*/,60677836/*45386*/,
			283886808/*45386*/,284008188/*45387*/,283872489/*45388*/,60676447/*45388*/,60676448/*45389*/,60676449/*45390*/,
			283848121/*45390*/,60677838/*45391*/,60677839/*45392*/,60676450/*45393*/,284000320/*45398*/,60676451/*45398*/,
			281116934/*G6024*/)
		))
	, (INNER JOIN CODE_VALUE cv_nom ON (nom.source_vocabulary_cd = cv_nom.code_value
		AND cv_nom.code_set = 400
		AND cv_nom.active_ind = 1
		AND cv_nom.begin_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cv_nom.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN DIAGNOSIS diag ON (enc.encntr_id = diag.encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.diagnosis_id IN (SELECT MIN(d.diagnosis_id) FROM DIAGNOSIS d
			WHERE enc.encntr_id = d.encntr_id
			AND d.active_ind = 1
			AND d.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND d.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			ORDER BY d.clinical_diag_priority)
		))
	, (INNER JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = diag.nomenclature_id
			AND nom_diag.active_ind = 1
			AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
			))
WHERE enc.active_ind = 1
	AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,2560523697/*Results Only*/,20058643/*Legacy Data*/)
 	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate) AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
 
/****************************************************************************
	Populate Record structure with Colonoscopy Procedure Data
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
	exp_data->list[cnt].pt_id_no = pt_id_no
	exp_data->list[cnt].subscriber_id = subscriber_id
	exp_data->list[cnt].medicaid_subscriber_nbr = medicaid_subscriber_nbr
	exp_data->list[cnt].medicare_subscriber_nbr = medicare_subscriber_nbr
	exp_data->list[cnt].member_alt_id_1 = member_alt_id_1
	exp_data->list[cnt].member_alt_id_2 = member_alt_id_2
	exp_data->list[cnt].member_alt_id_3 = member_alt_id_3
	exp_data->list[cnt].member_first_nm = member_first_nm
	exp_data->list[cnt].member_middle_nm = member_middle_nm
	exp_data->list[cnt].member_last_nm = member_last_nm
	exp_data->list[cnt].member_date_of_birth = member_date_of_birth
	exp_data->list[cnt].member_gender = member_gender
	exp_data->list[cnt].race = race
	exp_data->list[cnt].member_address_1 = member_address_1
	exp_data->list[cnt].member_address_2 = member_address_2
	exp_data->list[cnt].member_city = member_city
	exp_data->list[cnt].member_state = member_state
	exp_data->list[cnt].member_zip = member_zip
	exp_data->list[cnt].member_phone_1 = member_phone_1
	exp_data->list[cnt].dependent_number = dependent_number
	exp_data->list[cnt].Rendering_NPI = Rendering_NPI
	exp_data->list[cnt].Rendering_MPIN = Rendering_MPIN
	exp_data->list[cnt].Rendering_TIN = Rendering_TIN
	exp_data->list[cnt].Rend_Prov_Specialty = Rend_Prov_Specialty
	exp_data->list[cnt].Ordering_NPI = Ordering_NPI
	exp_data->list[cnt].Ordering_MPIN = Ordering_MPIN
	exp_data->list[cnt].Ordering_TIN = Ordering_TIN
	exp_data->list[cnt].Ordering_Prov_Specialty = Ordering_Prov_Specialty
	exp_data->list[cnt].rendering_provider_first_nm = rendering_provider_first_nm
	exp_data->list[cnt].rendering_provider_middle_nm = rendering_provider_middle_nm
	exp_data->list[cnt].rendering_provider_last_nm = rendering_provider_last_nm
	exp_data->list[cnt].rendering_provider_dea_code = rendering_provider_dea_code
	exp_data->list[cnt].rendering_provider_deg_cd = rendering_provider_deg_cd
	exp_data->list[cnt].rendering_provider_address_1 = rendering_provider_address_1
	exp_data->list[cnt].rendering_provider_address_2 = rendering_provider_address_2
	exp_data->list[cnt].rendering_provider_city = rendering_provider_city
	exp_data->list[cnt].rendering_provider_state = rendering_provider_state
	exp_data->list[cnt].rendering_provider_zip = rendering_provider_zip
	exp_data->list[cnt].rendering_provider_phone_1 = rendering_provider_phone_1
	exp_data->list[cnt].rendering_provider_phone_2 = rendering_provider_phone_2
	exp_data->list[cnt].rendering_provider_alt_id = rendering_provider_alt_id
	exp_data->list[cnt].Service_Date_From = Service_Date_From
	exp_data->list[cnt].Service_Date_Through = Service_Date_Through
	exp_data->list[cnt].icd_code_type = icd_code_type
	exp_data->list[cnt].icd_diagnosis_cd_1 = icd_diagnosis_cd_1
	exp_data->list[cnt].icd_diagnosis_cd_2 = icd_diagnosis_cd_2
	exp_data->list[cnt].icd_diagnosis_cd_3 = icd_diagnosis_cd_3
	exp_data->list[cnt].icd_diagnosis_cd_4 = icd_diagnosis_cd_4
	exp_data->list[cnt].icd_diagnosis_cd_5 = icd_diagnosis_cd_5
	exp_data->list[cnt].icd_diagnosis_cd_6 = icd_diagnosis_cd_6
	exp_data->list[cnt].icd_diagnosis_cd_7 = icd_diagnosis_cd_7
	exp_data->list[cnt].icd_diagnosis_cd_8 = icd_diagnosis_cd_8
	exp_data->list[cnt].icd_diagnosis_cd_9 = icd_diagnosis_cd_9
	exp_data->list[cnt].cpt_code = cpt_code
	exp_data->list[cnt].cpt_code_mod_1 = cpt_code_mod_1
	exp_data->list[cnt].cpt_code_mod_2 = cpt_code_mod_2
	exp_data->list[cnt].cpt2_code = cpt2_code
	exp_data->list[cnt].hcpcs_code = hcpcs_code
	exp_data->list[cnt].hcpcs_mod = hcpcs_mod
	exp_data->list[cnt].icd_procedure_cd_1 = icd_procedure_cd_1
	exp_data->list[cnt].icd_procedure_cd_2 = icd_procedure_cd_2
	exp_data->list[cnt].UB_Revenue_Code = UB_Revenue_Code
	exp_data->list[cnt].type_of_service_code = type_of_service_code
	exp_data->list[cnt].quantity_of_service = quantity_of_service
	exp_data->list[cnt].pcp_flg = pcp_flg
	exp_data->list[cnt].BP_Systolic = BP_Systolic
	exp_data->list[cnt].BP_Diastolic = BP_Diastolic
	exp_data->list[cnt].BMI_Result = BMI_Result
	exp_data->list[cnt].BMI_Percentile = BMI_Percentile
	exp_data->list[cnt].Member_Height = Member_Height
	exp_data->list[cnt].Member_Weight = Member_Weight
	exp_data->list[cnt].clin_user_defined_1 = clin_user_defined_1
	exp_data->list[cnt].clin_user_defined_2 = clin_user_defined_2
	exp_data->list[cnt].clin_user_defined_3 = clin_user_defined_3
	exp_data->list[cnt].clin_user_defined_4 = clin_user_defined_4
	exp_data->list[cnt].clin_user_defined_5 = clin_user_defined_5
	exp_data->list[cnt].clin_user_defined_6 = clin_user_defined_6
	exp_data->list[cnt].place_of_service_code = place_of_service_code
	exp_data->list[cnt].ref_range = ref_range
	exp_data->list[cnt].ab_ind = ab_ind
	exp_data->list[cnt].Fill_ord_num = Fill_ord_num
	exp_data->list[cnt].lab_claim_id_1 = lab_claim_id_1
	exp_data->list[cnt].lab_id = lab_id
	exp_data->list[cnt].lab_user_defined_1 = lab_user_defined_1
	exp_data->list[cnt].lab_user_defined_2 = lab_user_defined_2
	exp_data->list[cnt].loinc = loinc
	exp_data->list[cnt].lab_test_desc = lab_test_desc
	exp_data->list[cnt].obs_rslt_status = obs_rslt_status
	exp_data->list[cnt].result_dt = result_dt
	exp_data->list[cnt].order_dt = order_dt
	exp_data->list[cnt].service_dt = service_dt
	exp_data->list[cnt].pos_neg_rslt = pos_neg_rslt
	exp_data->list[cnt].lab_result_text = lab_result_text
	exp_data->list[cnt].result = result
	exp_data->list[cnt].snomed = snomed
	exp_data->list[cnt].unit = unit
	exp_data->list[cnt].National_drug_cd = National_drug_cd
	exp_data->list[cnt].qty_dispensed = qty_dispensed
	exp_data->list[cnt].fill_date = fill_date
	exp_data->list[cnt].days_supply = days_supply
	exp_data->list[cnt].dea_nbr = dea_nbr
	exp_data->list[cnt].denied_flg = denied_flg
	exp_data->list[cnt].generic_sts = generic_sts
	exp_data->list[cnt].Pharmacy_ID = Pharmacy_ID
	exp_data->list[cnt].pharmacy_nm = pharmacy_nm
	exp_data->list[cnt].pharmacy_type_cd = pharmacy_type_cd
	exp_data->list[cnt].prescribing_prov_id = prescribing_prov_id
	exp_data->list[cnt].rx_claim_alt_id_1 = rx_claim_alt_id_1
	exp_data->list[cnt].rx_claim_alt_id_2 = rx_claim_alt_id_2
	exp_data->list[cnt].rx_claim_alt_id_3 = rx_claim_alt_id_3
	exp_data->list[cnt].rx_claim_alt_id_4 = rx_claim_alt_id_4
	exp_data->list[cnt].requested_amt = requested_amt
	exp_data->list[cnt].supply_flag = supply_flag
	exp_data->list[cnt].cvx = cvx
	exp_data->list[cnt].Practice_TIN = Practice_TIN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
CALL ECHO ("***** GETTING BREAST ORDER DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Breast Order Data
**************************************************************/
 
SELECT DISTINCT
	pt_id_no = EVALUATE2(IF (SIZE(cmrn_nbr.alias) = 0) " " ELSE TRIM(cmrn_nbr.alias,3) ENDIF)
	,subscriber_id = EVALUATE2(IF (SIZE(enc_ins.MEMBER_NBR) = 0) " " ELSE TRIM(enc_ins.MEMBER_NBR,3) ENDIF)
	,medicaid_subscriber_nbr = " "
	,medicare_subscriber_nbr = " "
	,member_alt_id_1 = " "
	,member_alt_id_2 = " "
	,member_alt_id_3 = " "
	,member_first_nm = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,member_middle_nm = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,member_last_nm = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,member_date_of_birth = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(pat.birth_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,member_gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,race = EVALUATE(pat.race_cd, 0.00, "Other Race None", 309318.00, "American Indian or Alaska Native",
	     309317.00,	"Asian", 309315.00, "Black or African American", 23274729.00, "Other Race Multiple",
    	4189861.00, "Native Hawaiian or Pacific Islander", 18702439.00,	"Other Race Patient Declined",
	   25804105.00,	"Other Race Unavailable",309316.00, "White"," ")
    ,member_address_1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
    ,member_address_2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
    ,member_city = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
    ,member_state = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
    ,member_zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
    ,member_phone_1 = " "
    ,dependent_number = " "
	,Rendering_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Rendering_MPIN = " "
	,Rendering_TIN = " "
	,Rend_Prov_Specialty = EVALUATE2(IF (prov_spec.specialty_cd = 0.00) " "
			ELSE UAR_GET_CODE_DISPLAY(prov_spec.specialty_cd) ENDIF)
	,Ordering_NPI = " "
	,Ordering_MPIN = " "
	,Ordering_TIN = " "
	,Ordering_Prov_Specialty = " "
	,rendering_provider_first_nm = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,rendering_provider_middle_nm = " "
	,rendering_provider_last_nm = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,rendering_provider_dea_code = EVALUATE2(IF (SIZE(dea.alias) = 0) " " ELSE TRIM(dea.alias,3) ENDIF)
	,rendering_provider_deg_cd = " "
	,rendering_provider_address_1 = EVALUATE2(IF (SIZE(prov_addr.street_addr) = 0) " "
		ELSE TRIM(prov_addr.street_addr,3) ENDIF)
	,rendering_provider_address_2 = EVALUATE2(IF (SIZE(prov_addr.street_addr2) = 0) " "
		ELSE TRIM(prov_addr.street_addr2,3) ENDIF)
	,rendering_provider_city = EVALUATE2(IF (SIZE(prov_addr.city) = 0) " " ELSE TRIM(prov_addr.city,3) ENDIF)
	,rendering_provider_state = EVALUATE2(IF (SIZE(prov_addr.state) = 0) " " ELSE TRIM(prov_addr.State,3) ENDIF)
	,rendering_provider_zip = EVALUATE2(IF (SIZE(prov_addr.zipcode_key) = 0) " "
		ELSE TRIM(SUBSTRING(1,5,prov_addr.zipcode_key),3) ENDIF)
	,rendering_provider_phone_1 = " "
	,rendering_provider_phone_2 = " "
	,rendering_provider_alt_id = " "
    ,Service_Date_From = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,Service_Date_Through = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,icd_code_type = "0"
	,icd_diagnosis_cd_1 = EVALUATE2(IF (SIZE(nom_diag.source_identifier) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,icd_diagnosis_cd_2 = " "
	,icd_diagnosis_cd_3 = " "
	,icd_diagnosis_cd_4 = " "
	,icd_diagnosis_cd_5 = " "
	,icd_diagnosis_cd_6 = " "
	,icd_diagnosis_cd_7 = " "
	,icd_diagnosis_cd_8 = " "
	,icd_diagnosis_cd_9 = " "
	,cpt_code = EVALUATE2(IF (SIZE(ord_cat.description) = 0) " "
			ELSE SUBSTRING(FINDSTRING(' ',TRIM(ord_cat.description,3),1,1)+1,5,TRIM(ord_cat.description,3)) ENDIF)
	,cpt_code_mod_1 = " "
	,cpt_code_mod_2 = " "
	,cpt2_code = " "
	,hcpcs_code = " "
	,hcpcs_mod = " "
	,icd_procedure_cd_1 = " "
	,icd_procedure_cd_2 = " "
	,UB_Revenue_Code = " "
	,type_of_service_code = "Outpatient"
	,quantity_of_service = " "
	,pcp_flg = "Y"
	,BP_Systolic = " "
	,BP_Diastolic = " "
	,BMI_Result = " "
	,BMI_Percentile = " "
	,Member_Height = " "
	,Member_Weight = " "
	,clin_user_defined_1 = " "
	,clin_user_defined_2 = " "
	,clin_user_defined_3 = " "
	,clin_user_defined_4 = " "
	,clin_user_defined_5 = " "
	,clin_user_defined_6 = " "
	,place_of_service_code = "OC"
	,ref_range = " "
	,ab_ind = " "
	,Fill_ord_num = " "
	,lab_claim_id_1 = " "
	,lab_id = " "
	,lab_user_defined_1 = " "
	,lab_user_defined_2 = " "
	,loinc = " "
	,lab_test_desc = " "
	,obs_rslt_status = " "
	,result_dt = " "
	,order_dt = " "
	,service_dt = " "
	,pos_neg_rslt = " "
	,lab_result_text = " "
	,result = " "
	,snomed = " "
	,unit = " "
	,National_drug_cd = " "
	,qty_dispensed = " "
	,fill_date = " "
	,days_supply = " "
	,dea_nbr = " "
	,denied_flg = " "
	,generic_sts = " "
	,Pharmacy_ID = " "
	,pharmacy_nm = " "
	,pharmacy_type_cd = " "
	,prescribing_prov_id = " "
	,rx_claim_alt_id_1 = " "
	,rx_claim_alt_id_2 = " "
	,rx_claim_alt_id_3 = " "
	,rx_claim_alt_id_4 = " "
	,requested_amt = " "
	,supply_flag = " "
	,cvx = " "
	,Practice_TIN = "62-1282917"
FROM ENCOUNTER enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
		AND fin_nbr.active_ind = 1
		AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND fin_nbr.alias_pool_cd = 2554138229.00   ;FIN
   		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
		AND pat.active_ind = 1
		AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
		))
	, (INNER JOIN PERSON_ALIAS cmrn_nbr ON (pat.person_id = cmrn_nbr.person_id
		AND cmrn_nbr.active_ind = 1
		AND cmrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cmrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND cmrn_nbr.person_alias_type_cd =  2.00   ;CMRN
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
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
		AND enc_ins.active_ind = 1
		AND enc_ins.priority_seq = 1
		AND enc_ins.member_nbr != ' '
		AND enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
		AND hp_ins.active_ind = 1
		AND hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.health_plan_id IN (2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
   			2985957.00 /*Medicare UHC Dual Complete Part B*/,2985961.00 /*Medicare UHC IP Denial Part B*/,
   			2983341.00 /*Misc United Healthcare*/,2983161.00 /*United Healthcare*/,
   			2983345.00 /*United Healthcare Community*/)
		))
	, (INNER JOIN ENCNTR_PRSNL_RELTN epr ON (enc.encntr_id = epr.encntr_id
		AND epr.priority_seq = 1
		AND epr.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
		AND epr.active_ind = 1
		AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    	))
    , (INNER JOIN PRSNL prov ON (epr.prsnl_person_id = prov.person_id
    	AND prov.active_ind = 1
    	AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
    	AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    	))
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN prov_spec ON (prov.person_id = prov_spec.prsnl_id
		AND prov_spec.active_ind = 1
		AND prov_spec.primary_ind = 1
		AND prov_spec.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_spec.end_effective_dt_Tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
		))
	, (LEFT JOIN PRSNL_ALIAS dea ON (epr.prsnl_person_id = dea.person_id
		AND dea.active_ind = 1
		AND dea.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.prsnl_alias_type_cd = 1084.00  ;dea
		))
	, (INNER JOIN ADDRESS prov_addr ON (prov.person_id = prov_addr.parent_entity_id
		AND prov_addr.parent_entity_name = "PERSON"
		AND prov_addr.active_ind = 1
		AND prov_addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov_addr.address_type_cd = 754.00   ;BUSINESS
		AND prov_addr.address_id IN (SELECT MAX(prov_addr1.address_id) FROM address prov_addr1
			WHERE prov_addr1.parent_entity_id = prov.person_id
			AND prov_addr1.parent_entity_name = "PERSON"
			AND prov_addr1.active_ind = 1
			AND prov_addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.address_type_cd = 754.00)   ;BUSINESS
   		))
	, (INNER JOIN ORDERS ord ON (ord.encntr_id = enc.encntr_id
		AND ord.person_id = pat.person_id
		AND ord.order_status_cd = 2543.00   ;Completed
		))
	, (INNER JOIN ORDER_CATALOG ord_cat ON (ord.catalog_cd = ord_cat.catalog_cd
		AND ord_cat.active_ind = 1
		AND ord_cat.catalog_cd IN (2557870887,2557870909,2556629075,2556629175,2556629185,2556629105,2556629125,
			2556629085,2556629055,2556629045,2556629095,2556629115,2556629155,2556629165,2559401783,2556628945,
			2556629015,2556629025,2556628955,2556628975,2556629035,2556628985,2556628995,2556628965,2552790731,
			2552790699,2552790715,2552777119,2552776591,2552777103) /*Mammogram*/
		AND ord_cat.catalog_type_cd IN (2517.00 /*Radiology*/,20454826.00 /*Ambulatory POC*/,
			20460012.00 /*Ambulatory procedures*/)
		))
	, (INNER JOIN NOMEN_ENTITY_RELTN ner ON (ner.encntr_id = enc.encntr_id
		AND ner.parent_entity_id = ord.order_id
		AND ner.person_id = enc.person_id AND ner.person_id = ord.person_id
		AND ner.active_ind = 1
		AND ner.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND ner.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND ner.priority = 1
		))
	, (INNER JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = ner.nomenclature_id
		AND nom_diag.active_ind = 1
		AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
WHERE enc.active_ind = 1
	AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,2560523697/*Results Only*/,20058643/*Legacy Data*/)
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate) AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
 
/****************************************************************************
	Populate Record structure with Breast Order Data
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
 
	exp_data->list[cnt].pt_id_no = pt_id_no
	exp_data->list[cnt].subscriber_id = subscriber_id
	exp_data->list[cnt].medicaid_subscriber_nbr = medicaid_subscriber_nbr
	exp_data->list[cnt].medicare_subscriber_nbr = medicare_subscriber_nbr
	exp_data->list[cnt].member_alt_id_1 = member_alt_id_1
	exp_data->list[cnt].member_alt_id_2 = member_alt_id_2
	exp_data->list[cnt].member_alt_id_3 = member_alt_id_3
	exp_data->list[cnt].member_first_nm = member_first_nm
	exp_data->list[cnt].member_middle_nm = member_middle_nm
	exp_data->list[cnt].member_last_nm = member_last_nm
	exp_data->list[cnt].member_date_of_birth = member_date_of_birth
	exp_data->list[cnt].member_gender = member_gender
	exp_data->list[cnt].race = race
	exp_data->list[cnt].member_address_1 = member_address_1
	exp_data->list[cnt].member_address_2 = member_address_2
	exp_data->list[cnt].member_city = member_city
	exp_data->list[cnt].member_state = member_state
	exp_data->list[cnt].member_zip = member_zip
	exp_data->list[cnt].member_phone_1 = member_phone_1
	exp_data->list[cnt].dependent_number = dependent_number
	exp_data->list[cnt].Rendering_NPI = Rendering_NPI
	exp_data->list[cnt].Rendering_MPIN = Rendering_MPIN
	exp_data->list[cnt].Rendering_TIN = Rendering_TIN
	exp_data->list[cnt].Rend_Prov_Specialty = Rend_Prov_Specialty
	exp_data->list[cnt].Ordering_NPI = Ordering_NPI
	exp_data->list[cnt].Ordering_MPIN = Ordering_MPIN
	exp_data->list[cnt].Ordering_TIN = Ordering_TIN
	exp_data->list[cnt].Ordering_Prov_Specialty = Ordering_Prov_Specialty
	exp_data->list[cnt].rendering_provider_first_nm = rendering_provider_first_nm
	exp_data->list[cnt].rendering_provider_middle_nm = rendering_provider_middle_nm
	exp_data->list[cnt].rendering_provider_last_nm = rendering_provider_last_nm
	exp_data->list[cnt].rendering_provider_dea_code = rendering_provider_dea_code
	exp_data->list[cnt].rendering_provider_deg_cd = rendering_provider_deg_cd
	exp_data->list[cnt].rendering_provider_address_1 = rendering_provider_address_1
	exp_data->list[cnt].rendering_provider_address_2 = rendering_provider_address_2
	exp_data->list[cnt].rendering_provider_city = rendering_provider_city
	exp_data->list[cnt].rendering_provider_state = rendering_provider_state
	exp_data->list[cnt].rendering_provider_zip = rendering_provider_zip
	exp_data->list[cnt].rendering_provider_phone_1 = rendering_provider_phone_1
	exp_data->list[cnt].rendering_provider_phone_2 = rendering_provider_phone_2
	exp_data->list[cnt].rendering_provider_alt_id = rendering_provider_alt_id
	exp_data->list[cnt].Service_Date_From = Service_Date_From
	exp_data->list[cnt].Service_Date_Through = Service_Date_Through
	exp_data->list[cnt].icd_code_type = icd_code_type
	exp_data->list[cnt].icd_diagnosis_cd_1 = icd_diagnosis_cd_1
	exp_data->list[cnt].icd_diagnosis_cd_2 = icd_diagnosis_cd_2
	exp_data->list[cnt].icd_diagnosis_cd_3 = icd_diagnosis_cd_3
	exp_data->list[cnt].icd_diagnosis_cd_4 = icd_diagnosis_cd_4
	exp_data->list[cnt].icd_diagnosis_cd_5 = icd_diagnosis_cd_5
	exp_data->list[cnt].icd_diagnosis_cd_6 = icd_diagnosis_cd_6
	exp_data->list[cnt].icd_diagnosis_cd_7 = icd_diagnosis_cd_7
	exp_data->list[cnt].icd_diagnosis_cd_8 = icd_diagnosis_cd_8
	exp_data->list[cnt].icd_diagnosis_cd_9 = icd_diagnosis_cd_9
	exp_data->list[cnt].cpt_code = cpt_code
	exp_data->list[cnt].cpt_code_mod_1 = cpt_code_mod_1
	exp_data->list[cnt].cpt_code_mod_2 = cpt_code_mod_2
	exp_data->list[cnt].cpt2_code = cpt2_code
	exp_data->list[cnt].hcpcs_code = hcpcs_code
	exp_data->list[cnt].hcpcs_mod = hcpcs_mod
	exp_data->list[cnt].icd_procedure_cd_1 = icd_procedure_cd_1
	exp_data->list[cnt].icd_procedure_cd_2 = icd_procedure_cd_2
	exp_data->list[cnt].UB_Revenue_Code = UB_Revenue_Code
	exp_data->list[cnt].type_of_service_code = type_of_service_code
	exp_data->list[cnt].quantity_of_service = quantity_of_service
	exp_data->list[cnt].pcp_flg = pcp_flg
	exp_data->list[cnt].BP_Systolic = BP_Systolic
	exp_data->list[cnt].BP_Diastolic = BP_Diastolic
	exp_data->list[cnt].BMI_Result = BMI_Result
	exp_data->list[cnt].BMI_Percentile = BMI_Percentile
	exp_data->list[cnt].Member_Height = Member_Height
	exp_data->list[cnt].Member_Weight = Member_Weight
	exp_data->list[cnt].clin_user_defined_1 = clin_user_defined_1
	exp_data->list[cnt].clin_user_defined_2 = clin_user_defined_2
	exp_data->list[cnt].clin_user_defined_3 = clin_user_defined_3
	exp_data->list[cnt].clin_user_defined_4 = clin_user_defined_4
	exp_data->list[cnt].clin_user_defined_5 = clin_user_defined_5
	exp_data->list[cnt].clin_user_defined_6 = clin_user_defined_6
	exp_data->list[cnt].place_of_service_code = place_of_service_code
	exp_data->list[cnt].ref_range = ref_range
	exp_data->list[cnt].ab_ind = ab_ind
	exp_data->list[cnt].Fill_ord_num = Fill_ord_num
	exp_data->list[cnt].lab_claim_id_1 = lab_claim_id_1
	exp_data->list[cnt].lab_id = lab_id
	exp_data->list[cnt].lab_user_defined_1 = lab_user_defined_1
	exp_data->list[cnt].lab_user_defined_2 = lab_user_defined_2
	exp_data->list[cnt].loinc = loinc
	exp_data->list[cnt].lab_test_desc = lab_test_desc
	exp_data->list[cnt].obs_rslt_status = obs_rslt_status
	exp_data->list[cnt].result_dt = result_dt
	exp_data->list[cnt].order_dt = order_dt
	exp_data->list[cnt].service_dt = service_dt
	exp_data->list[cnt].pos_neg_rslt = pos_neg_rslt
	exp_data->list[cnt].lab_result_text = lab_result_text
	exp_data->list[cnt].result = result
	exp_data->list[cnt].snomed = snomed
	exp_data->list[cnt].unit = unit
	exp_data->list[cnt].National_drug_cd = National_drug_cd
	exp_data->list[cnt].qty_dispensed = qty_dispensed
	exp_data->list[cnt].fill_date = fill_date
	exp_data->list[cnt].days_supply = days_supply
	exp_data->list[cnt].dea_nbr = dea_nbr
	exp_data->list[cnt].denied_flg = denied_flg
	exp_data->list[cnt].generic_sts = generic_sts
	exp_data->list[cnt].Pharmacy_ID = Pharmacy_ID
	exp_data->list[cnt].pharmacy_nm = pharmacy_nm
	exp_data->list[cnt].pharmacy_type_cd = pharmacy_type_cd
	exp_data->list[cnt].prescribing_prov_id = prescribing_prov_id
	exp_data->list[cnt].rx_claim_alt_id_1 = rx_claim_alt_id_1
	exp_data->list[cnt].rx_claim_alt_id_2 = rx_claim_alt_id_2
	exp_data->list[cnt].rx_claim_alt_id_3 = rx_claim_alt_id_3
	exp_data->list[cnt].rx_claim_alt_id_4 = rx_claim_alt_id_4
	exp_data->list[cnt].requested_amt = requested_amt
	exp_data->list[cnt].supply_flag = supply_flag
	exp_data->list[cnt].cvx = cvx
	exp_data->list[cnt].Practice_TIN = Practice_TIN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
 
CALL ECHO ("***** GETTING BREAST PROCEDURE DATA *****")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Breast Procedure Data
**************************************************************/
SELECT DISTINCT
	pt_id_no = EVALUATE2(IF (SIZE(cmrn_nbr.alias) = 0) " " ELSE TRIM(cmrn_nbr.alias,3) ENDIF)
	,subscriber_id = EVALUATE2(IF (SIZE(enc_ins.MEMBER_NBR) = 0) " " ELSE TRIM(enc_ins.MEMBER_NBR,3) ENDIF)
	,medicaid_subscriber_nbr = " "
	,medicare_subscriber_nbr = " "
	,member_alt_id_1 = " "
	,member_alt_id_2 = " "
	,member_alt_id_3 = " "
	,member_first_nm = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,member_middle_nm = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,member_last_nm = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,member_date_of_birth = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(pat.birth_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,member_gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,race = EVALUATE(pat.race_cd, 0.00, "Other Race None", 309318.00, "American Indian or Alaska Native",
	     309317.00,	"Asian", 309315.00, "Black or African American", 23274729.00, "Other Race Multiple",
    	4189861.00, "Native Hawaiian or Pacific Islander", 18702439.00,	"Other Race Patient Declined",
	   25804105.00,	"Other Race Unavailable",309316.00, "White"," ")
    ,member_address_1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
    ,member_address_2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
    ,member_city = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
    ,member_state = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
    ,member_zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
    ,member_phone_1 = " "
    ,dependent_number = " "
	,Rendering_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Rendering_MPIN = " "
	,Rendering_TIN = " "
	,Rend_Prov_Specialty = EVALUATE2(IF (prov_spec.specialty_cd = 0.00) " "
			ELSE UAR_GET_CODE_DISPLAY(prov_spec.specialty_cd) ENDIF)
	,Ordering_NPI = " "
	,Ordering_MPIN = " "
	,Ordering_TIN = " "
	,Ordering_Prov_Specialty = " "
	,rendering_provider_first_nm = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,rendering_provider_middle_nm = " "
	,rendering_provider_last_nm = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,rendering_provider_dea_code = EVALUATE2(IF (SIZE(dea.alias) = 0) " " ELSE TRIM(dea.alias,3) ENDIF)
	,rendering_provider_deg_cd = " "
	,rendering_provider_address_1 = EVALUATE2(IF (SIZE(prov_addr.street_addr) = 0) " "
		ELSE TRIM(prov_addr.street_addr,3) ENDIF)
	,rendering_provider_address_2 = EVALUATE2(IF (SIZE(prov_addr.street_addr2) = 0) " "
		ELSE TRIM(prov_addr.street_addr2,3) ENDIF)
	,rendering_provider_city = EVALUATE2(IF (SIZE(prov_addr.city) = 0) " " ELSE TRIM(prov_addr.city,3) ENDIF)
	,rendering_provider_state = EVALUATE2(IF (SIZE(prov_addr.state) = 0) " " ELSE TRIM(prov_addr.State,3) ENDIF)
	,rendering_provider_zip = EVALUATE2(IF (SIZE(prov_addr.zipcode_key) = 0) " "
		ELSE TRIM(SUBSTRING(1,5,prov_addr.zipcode_key),3) ENDIF)
	,rendering_provider_phone_1 = " "
	,rendering_provider_phone_2 = " "
	,rendering_provider_alt_id = " "
    ,Service_Date_From = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,Service_Date_Through = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,icd_code_type = "0"
	,icd_diagnosis_cd_1 = EVALUATE2(IF (SIZE(nom_diag.source_identifier) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,icd_diagnosis_cd_2 = " "
	,icd_diagnosis_cd_3 = " "
	,icd_diagnosis_cd_4 = " "
	,icd_diagnosis_cd_5 = " "
	,icd_diagnosis_cd_6 = " "
	,icd_diagnosis_cd_7 = " "
	,icd_diagnosis_cd_8 = " "
	,icd_diagnosis_cd_9 = " "
	,cpt_code = EVALUATE2(IF (SIZE(cv_nom.display) = 0 OR TRIM(cv_nom.display,3) IN ("CPT4","SNOMED CT")) nom.source_identifier
		ELSE SUBSTRING(1,SIZE(cv_nom.display),TRIM(cv_nom.display,3)) ENDIF)
	,cpt_code_mod_1 = " "
	,cpt_code_mod_2 = " "
	,cpt2_code = " "
	,hcpcs_code = " "
	,hcpcs_mod = " "
	,icd_procedure_cd_1 = " "
	,icd_procedure_cd_2 = " "
	,UB_Revenue_Code = " "
	,type_of_service_code = "Outpatient"
	,quantity_of_service = " "
	,pcp_flg = "Y"
	,BP_Systolic = " "
	,BP_Diastolic = " "
	,BMI_Result = " "
	,BMI_Percentile = " "
	,Member_Height = " "
	,Member_Weight = " "
	,clin_user_defined_1 = " "
	,clin_user_defined_2 = " "
	,clin_user_defined_3 = " "
	,clin_user_defined_4 = " "
	,clin_user_defined_5 = " "
	,clin_user_defined_6 = " "
	,place_of_service_code = "OC"
	,ref_range = " "
	,ab_ind = " "
	,Fill_ord_num = " "
	,lab_claim_id_1 = " "
	,lab_id = " "
	,lab_user_defined_1 = " "
	,lab_user_defined_2 = " "
	,loinc = " "
	,lab_test_desc = " "
	,obs_rslt_status = " "
	,result_dt = " "
	,order_dt = " "
	,service_dt = " "
	,pos_neg_rslt = " "
	,lab_result_text = " "
	,result = " "
	,snomed = " "
	,unit = " "
	,National_drug_cd = " "
	,qty_dispensed = " "
	,fill_date = " "
	,days_supply = " "
	,dea_nbr = " "
	,denied_flg = " "
	,generic_sts = " "
	,Pharmacy_ID = " "
	,pharmacy_nm = " "
	,pharmacy_type_cd = " "
	,prescribing_prov_id = " "
	,rx_claim_alt_id_1 = " "
	,rx_claim_alt_id_2 = " "
	,rx_claim_alt_id_3 = " "
	,rx_claim_alt_id_4 = " "
	,requested_amt = " "
	,supply_flag = " "
	,cvx = " "
	,Practice_TIN = "62-1282917"
FROM ENCOUNTER enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
		AND fin_nbr.active_ind = 1
		AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND fin_nbr.alias_pool_cd = 2554138229.00   ;FIN
   		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
		AND pat.active_ind = 1
		AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
		))
	, (INNER JOIN PERSON_ALIAS cmrn_nbr ON (pat.person_id = cmrn_nbr.person_id
		AND cmrn_nbr.active_ind = 1
		AND cmrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cmrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND cmrn_nbr.person_alias_type_cd =  2.00   ;CMRN
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
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
		AND enc_ins.active_ind = 1
		AND enc_ins.priority_seq = 1
		AND enc_ins.member_nbr != ' '
		AND enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
		AND hp_ins.active_ind = 1
		AND hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.health_plan_id IN (2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
    		2985957.00 /*Medicare UHC Dual Complete Part B*/,2985961.00 /*Medicare UHC IP Denial Part B*/,
    		2983341.00 /*Misc United Healthcare*/,2983161.00 /*United Healthcare*/,
    		2983345.00 /*United Healthcare Community*/)
		))
	, (INNER JOIN ENCNTR_PRSNL_RELTN epr ON (enc.encntr_id = epr.encntr_id
		AND epr.priority_seq = 1
		AND epr.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
		AND epr.active_ind = 1
		AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		))
    , (INNER JOIN PRSNL prov ON (epr.prsnl_person_id = prov.person_id
   		AND prov.active_ind = 1
   		AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		))
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN prov_spec ON (prov.person_id = prov_spec.prsnl_id
		AND prov_spec.active_ind = 1
		AND prov_spec.primary_ind = 1
		AND prov_spec.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_spec.end_effective_dt_Tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
		))
	, (LEFT JOIN PRSNL_ALIAS dea ON (epr.prsnl_person_id = dea.person_id
		AND dea.active_ind = 1
		AND dea.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.prsnl_alias_type_cd = 1084.00  ;dea
		))
	, (INNER JOIN ADDRESS prov_addr ON (prov.person_id = prov_addr.parent_entity_id
		AND prov_addr.parent_entity_name = "PERSON"
		AND prov_addr.active_ind = 1
		AND prov_addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov_addr.address_type_cd = 754.00   ;BUSINESS
		AND prov_addr.address_id IN (SELECT MAX(prov_addr1.address_id) FROM address prov_addr1
			WHERE prov_addr1.parent_entity_id = prov.person_id
			AND prov_addr1.parent_entity_name = "PERSON"
			AND prov_addr1.active_ind = 1
			AND prov_addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.address_type_cd = 754.00)   ;BUSINESS
   		))
	, (INNER JOIN PROCEDURE proc ON (proc.encntr_id = ENC.encntr_id
		AND proc.active_ind = 1
		AND proc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND proc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND (proc.proc_dt_tm >= CNVTDATETIME(startdate) AND proc.proc_dt_tm <= CNVTDATETIME(enddate))
		))
	, (INNER JOIN NOMENCLATURE nom ON (proc.nomenclature_id = nom.nomenclature_id
		AND nom.active_ind = 1
		AND nom.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND nom.nomenclature_id IN (284004575/*77051*/,280898282/*77067*/,279820132/*726741000124117*/,
			283849742/*77065*/,281116876/*G0204*/,279824926/*3330609010*/,6697303/*384223018*/,279662173/*77067*/,
			280731040/*3332409014*/,8203423/*119035015*/,7783111/*208630014*/,281116957/*G0202*/,279812288/*3330608019*/,
			8059732/*119040011*/,280898281/*77066*/,279662157/*77066*/,281116938/*G0202*/,281116878/*G0206*/,
			284004005/*77057*/,283888471/*77056*/,273236614/*361026012*/,8132303/*481971012*/,7694111/*208625010*/,
			280898280/*77065*/,283849769/*77066*/,10990346/*2696031015*/,279810951/*3330622019*/,7062984/*361029017*/,
			8059733/*72085010*/,283887602/*77067*/,7213365/*41281017*/,60681301/*3014F*/,8132302/*481970013*/,
			281243731/*3525671013*/,279662156/*77065*/,280731041/*3332410016*/)
		))
	, (INNER JOIN CODE_VALUE cv_nom ON (nom.source_vocabulary_cd = cv_nom.code_value
		AND cv_nom.code_set = 400
		AND cv_nom.active_ind = 1
		AND cv_nom.begin_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cv_nom.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN DIAGNOSIS diag ON (enc.encntr_id = diag.encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.diagnosis_id IN (SELECT MIN(d.diagnosis_id) FROM DIAGNOSIS d
			WHERE enc.encntr_id = d.encntr_id
			AND d.active_ind = 1
			AND d.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND d.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			ORDER BY d.clinical_diag_priority)
		))
	, (INNER JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
WHERE enc.active_ind = 1
	AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,2560523697/*Results Only*/,20058643/*Legacy Data*/)
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate) AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
 
/****************************************************************************
	Populate Record structure with Breast Procedure Data
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
 
	exp_data->list[cnt].pt_id_no = pt_id_no
	exp_data->list[cnt].subscriber_id = subscriber_id
	exp_data->list[cnt].medicaid_subscriber_nbr = medicaid_subscriber_nbr
	exp_data->list[cnt].medicare_subscriber_nbr = medicare_subscriber_nbr
	exp_data->list[cnt].member_alt_id_1 = member_alt_id_1
	exp_data->list[cnt].member_alt_id_2 = member_alt_id_2
	exp_data->list[cnt].member_alt_id_3 = member_alt_id_3
	exp_data->list[cnt].member_first_nm = member_first_nm
	exp_data->list[cnt].member_middle_nm = member_middle_nm
	exp_data->list[cnt].member_last_nm = member_last_nm
	exp_data->list[cnt].member_date_of_birth = member_date_of_birth
	exp_data->list[cnt].member_gender = member_gender
	exp_data->list[cnt].race = race
	exp_data->list[cnt].member_address_1 = member_address_1
	exp_data->list[cnt].member_address_2 = member_address_2
	exp_data->list[cnt].member_city = member_city
	exp_data->list[cnt].member_state = member_state
	exp_data->list[cnt].member_zip = member_zip
	exp_data->list[cnt].member_phone_1 = member_phone_1
	exp_data->list[cnt].dependent_number = dependent_number
	exp_data->list[cnt].Rendering_NPI = Rendering_NPI
	exp_data->list[cnt].Rendering_MPIN = Rendering_MPIN
	exp_data->list[cnt].Rendering_TIN = Rendering_TIN
	exp_data->list[cnt].Rend_Prov_Specialty = Rend_Prov_Specialty
	exp_data->list[cnt].Ordering_NPI = Ordering_NPI
	exp_data->list[cnt].Ordering_MPIN = Ordering_MPIN
	exp_data->list[cnt].Ordering_TIN = Ordering_TIN
	exp_data->list[cnt].Ordering_Prov_Specialty = Ordering_Prov_Specialty
	exp_data->list[cnt].rendering_provider_first_nm = rendering_provider_first_nm
	exp_data->list[cnt].rendering_provider_middle_nm = rendering_provider_middle_nm
	exp_data->list[cnt].rendering_provider_last_nm = rendering_provider_last_nm
	exp_data->list[cnt].rendering_provider_dea_code = rendering_provider_dea_code
	exp_data->list[cnt].rendering_provider_deg_cd = rendering_provider_deg_cd
	exp_data->list[cnt].rendering_provider_address_1 = rendering_provider_address_1
	exp_data->list[cnt].rendering_provider_address_2 = rendering_provider_address_2
	exp_data->list[cnt].rendering_provider_city = rendering_provider_city
	exp_data->list[cnt].rendering_provider_state = rendering_provider_state
	exp_data->list[cnt].rendering_provider_zip = rendering_provider_zip
	exp_data->list[cnt].rendering_provider_phone_1 = rendering_provider_phone_1
	exp_data->list[cnt].rendering_provider_phone_2 = rendering_provider_phone_2
	exp_data->list[cnt].rendering_provider_alt_id = rendering_provider_alt_id
	exp_data->list[cnt].Service_Date_From = Service_Date_From
	exp_data->list[cnt].Service_Date_Through = Service_Date_Through
	exp_data->list[cnt].icd_code_type = icd_code_type
	exp_data->list[cnt].icd_diagnosis_cd_1 = icd_diagnosis_cd_1
	exp_data->list[cnt].icd_diagnosis_cd_2 = icd_diagnosis_cd_2
	exp_data->list[cnt].icd_diagnosis_cd_3 = icd_diagnosis_cd_3
	exp_data->list[cnt].icd_diagnosis_cd_4 = icd_diagnosis_cd_4
	exp_data->list[cnt].icd_diagnosis_cd_5 = icd_diagnosis_cd_5
	exp_data->list[cnt].icd_diagnosis_cd_6 = icd_diagnosis_cd_6
	exp_data->list[cnt].icd_diagnosis_cd_7 = icd_diagnosis_cd_7
	exp_data->list[cnt].icd_diagnosis_cd_8 = icd_diagnosis_cd_8
	exp_data->list[cnt].icd_diagnosis_cd_9 = icd_diagnosis_cd_9
	exp_data->list[cnt].cpt_code = cpt_code
	exp_data->list[cnt].cpt_code_mod_1 = cpt_code_mod_1
	exp_data->list[cnt].cpt_code_mod_2 = cpt_code_mod_2
	exp_data->list[cnt].cpt2_code = cpt2_code
	exp_data->list[cnt].hcpcs_code = hcpcs_code
	exp_data->list[cnt].hcpcs_mod = hcpcs_mod
	exp_data->list[cnt].icd_procedure_cd_1 = icd_procedure_cd_1
	exp_data->list[cnt].icd_procedure_cd_2 = icd_procedure_cd_2
	exp_data->list[cnt].UB_Revenue_Code = UB_Revenue_Code
	exp_data->list[cnt].type_of_service_code = type_of_service_code
	exp_data->list[cnt].quantity_of_service = quantity_of_service
	exp_data->list[cnt].pcp_flg = pcp_flg
	exp_data->list[cnt].BP_Systolic = BP_Systolic
	exp_data->list[cnt].BP_Diastolic = BP_Diastolic
	exp_data->list[cnt].BMI_Result = BMI_Result
	exp_data->list[cnt].BMI_Percentile = BMI_Percentile
	exp_data->list[cnt].Member_Height = Member_Height
	exp_data->list[cnt].Member_Weight = Member_Weight
	exp_data->list[cnt].clin_user_defined_1 = clin_user_defined_1
	exp_data->list[cnt].clin_user_defined_2 = clin_user_defined_2
	exp_data->list[cnt].clin_user_defined_3 = clin_user_defined_3
	exp_data->list[cnt].clin_user_defined_4 = clin_user_defined_4
	exp_data->list[cnt].clin_user_defined_5 = clin_user_defined_5
	exp_data->list[cnt].clin_user_defined_6 = clin_user_defined_6
	exp_data->list[cnt].place_of_service_code = place_of_service_code
	exp_data->list[cnt].ref_range = ref_range
	exp_data->list[cnt].ab_ind = ab_ind
	exp_data->list[cnt].Fill_ord_num = Fill_ord_num
	exp_data->list[cnt].lab_claim_id_1 = lab_claim_id_1
	exp_data->list[cnt].lab_id = lab_id
	exp_data->list[cnt].lab_user_defined_1 = lab_user_defined_1
	exp_data->list[cnt].lab_user_defined_2 = lab_user_defined_2
	exp_data->list[cnt].loinc = loinc
	exp_data->list[cnt].lab_test_desc = lab_test_desc
	exp_data->list[cnt].obs_rslt_status = obs_rslt_status
	exp_data->list[cnt].result_dt = result_dt
	exp_data->list[cnt].order_dt = order_dt
	exp_data->list[cnt].service_dt = service_dt
	exp_data->list[cnt].pos_neg_rslt = pos_neg_rslt
	exp_data->list[cnt].lab_result_text = lab_result_text
	exp_data->list[cnt].result = result
	exp_data->list[cnt].snomed = snomed
	exp_data->list[cnt].unit = unit
	exp_data->list[cnt].National_drug_cd = National_drug_cd
	exp_data->list[cnt].qty_dispensed = qty_dispensed
	exp_data->list[cnt].fill_date = fill_date
	exp_data->list[cnt].days_supply = days_supply
	exp_data->list[cnt].dea_nbr = dea_nbr
	exp_data->list[cnt].denied_flg = denied_flg
	exp_data->list[cnt].generic_sts = generic_sts
	exp_data->list[cnt].Pharmacy_ID = Pharmacy_ID
	exp_data->list[cnt].pharmacy_nm = pharmacy_nm
	exp_data->list[cnt].pharmacy_type_cd = pharmacy_type_cd
	exp_data->list[cnt].prescribing_prov_id = prescribing_prov_id
	exp_data->list[cnt].rx_claim_alt_id_1 = rx_claim_alt_id_1
	exp_data->list[cnt].rx_claim_alt_id_2 = rx_claim_alt_id_2
	exp_data->list[cnt].rx_claim_alt_id_3 = rx_claim_alt_id_3
	exp_data->list[cnt].rx_claim_alt_id_4 = rx_claim_alt_id_4
	exp_data->list[cnt].requested_amt = requested_amt
	exp_data->list[cnt].supply_flag = supply_flag
	exp_data->list[cnt].cvx = cvx
	exp_data->list[cnt].Practice_TIN = Practice_TIN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
 
CALL ECHO ("***** GETTING BMI DATA Weight/Height/BP Diastolic/BP Systolic/BMI Measured/BMI Percentile *****")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/************************************************************************************
; Get BMI Data - Weight/Height/BP Diastolic/BP Systolic/BMI Measured/BMI Percentile
*************************************************************************************/
SELECT DISTINCT
	pt_id_no = EVALUATE2(IF (SIZE(cmrn_nbr.alias) = 0) " " ELSE TRIM(cmrn_nbr.alias,3) ENDIF)
	,subscriber_id = EVALUATE2(IF (SIZE(enc_ins.MEMBER_NBR) = 0) " " ELSE TRIM(enc_ins.MEMBER_NBR,3) ENDIF)
	,medicaid_subscriber_nbr = " "
	,medicare_subscriber_nbr = " "
	,member_alt_id_1 = " "
	,member_alt_id_2 = " "
	,member_alt_id_3 = " "
	,member_first_nm = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,member_middle_nm = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,member_last_nm = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,member_date_of_birth = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(pat.birth_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,member_gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,race = EVALUATE(pat.race_cd, 0.00, "Other Race None", 309318.00, "American Indian or Alaska Native",
	     309317.00,	"Asian", 309315.00, "Black or African American", 23274729.00, "Other Race Multiple",
    	4189861.00, "Native Hawaiian or Pacific Islander", 18702439.00,	"Other Race Patient Declined",
	   25804105.00,	"Other Race Unavailable",309316.00, "White"," ")
    ,member_address_1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
    ,member_address_2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
    ,member_city = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
    ,member_state = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
    ,member_zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
    ,member_phone_1 = " "
    ,dependent_number = " "
	,Rendering_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Rendering_MPIN = " "
	,Rendering_TIN = " "
	,Rend_Prov_Specialty = EVALUATE2(IF (prov_spec.specialty_cd = 0.00) " "
			ELSE UAR_GET_CODE_DISPLAY(prov_spec.specialty_cd) ENDIF)
	,Ordering_NPI = " "
	,Ordering_MPIN = " "
	,Ordering_TIN = " "
	,Ordering_Prov_Specialty = " "
	,rendering_provider_first_nm = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,rendering_provider_middle_nm = " "
	,rendering_provider_last_nm = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,rendering_provider_dea_code = EVALUATE2(IF (SIZE(dea.alias) = 0) " " ELSE TRIM(dea.alias,3) ENDIF)
	,rendering_provider_deg_cd = " "
	,rendering_provider_address_1 = EVALUATE2(IF (SIZE(prov_addr.street_addr) = 0) " "
		ELSE TRIM(prov_addr.street_addr,3) ENDIF)
	,rendering_provider_address_2 = EVALUATE2(IF (SIZE(prov_addr.street_addr2) = 0) " "
		ELSE TRIM(prov_addr.street_addr2,3) ENDIF)
	,rendering_provider_city = EVALUATE2(IF (SIZE(prov_addr.city) = 0) " " ELSE TRIM(prov_addr.city,3) ENDIF)
	,rendering_provider_state = EVALUATE2(IF (SIZE(prov_addr.state) = 0) " " ELSE TRIM(prov_addr.State,3) ENDIF)
	,rendering_provider_zip = EVALUATE2(IF (SIZE(prov_addr.zipcode_key) = 0) " "
		ELSE TRIM(SUBSTRING(1,5,prov_addr.zipcode_key),3) ENDIF)
	,rendering_provider_phone_1 = " "
	,rendering_provider_phone_2 = " "
	,rendering_provider_alt_id = " "
    ,Service_Date_From = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,Service_Date_Through = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,icd_code_type = "0"
	,icd_diagnosis_cd_1 = EVALUATE2(IF (SIZE(nom_diag.source_identifier) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,icd_diagnosis_cd_2 = " "
	,icd_diagnosis_cd_3 = " "
	,icd_diagnosis_cd_4 = " "
	,icd_diagnosis_cd_5 = " "
	,icd_diagnosis_cd_6 = " "
	,icd_diagnosis_cd_7 = " "
	,icd_diagnosis_cd_8 = " "
	,icd_diagnosis_cd_9 = " "
	,cpt_code = " "
	,cpt_code_mod_1 = " "
	,cpt_code_mod_2 = " "
	,cpt2_code = " "
	,hcpcs_code = " "
	,hcpcs_mod = " "
	,icd_procedure_cd_1 = " "
	,icd_procedure_cd_2 = " "
	,UB_Revenue_Code = " "
	,type_of_service_code = "Outpatient"
	,quantity_of_service = " "
	,pcp_flg = "Y"
	,BP_Systolic = EVALUATE2(IF (SIZE(CESY.result_val) = 0) " " ELSE TRIM(CESY.result_val,3) ENDIF)
	,BP_Diastolic = EVALUATE2(IF (SIZE(CEDI.result_val) = 0) " " ELSE TRIM(CEDI.result_val,3) ENDIF)
	,BMI_Result = EVALUATE2(IF (SIZE(BMI_MEASURED.result_val) = 0) " " ELSE TRIM(BMI_MEASURED.result_val,3) ENDIF)
	,BMI_Percentile = EVALUATE2(IF (SIZE(BMI_PERCENT.result_val) = 0) " " ELSE TRIM(BMI_PERCENT.result_val,3) ENDIF)
	,Member_Height = EVALUATE2(IF (SIZE(CEHT.result_val) = 0) " " ELSE TRIM(CEHT.result_val,3) ENDIF)
	,Member_Weight = EVALUATE2(IF (SIZE(CEWT.result_val) = 0) " " ELSE TRIM(CEWT.result_val,3) ENDIF)
	,clin_user_defined_1 = " "
	,clin_user_defined_2 = " "
	,clin_user_defined_3 = " "
	,clin_user_defined_4 = " "
	,clin_user_defined_5 = " "
	,clin_user_defined_6 = " "
	,place_of_service_code = "OC"
	,ref_range = " "
	,ab_ind = " "
	,Fill_ord_num = " "
	,lab_claim_id_1 = " "
	,lab_id = " "
	,lab_user_defined_1 = " "
	,lab_user_defined_2 = " "
	,loinc = " "
	,lab_test_desc = " "
	,obs_rslt_status = " "
	,result_dt = " "
	,order_dt = " "
	,service_dt = " "
	,pos_neg_rslt = " "
	,lab_result_text = " "
	,result = " "
	,snomed = " "
	,unit = " "
	,National_drug_cd = " "
	,qty_dispensed = " "
	,fill_date = " "
	,days_supply = " "
	,dea_nbr = " "
	,denied_flg = " "
	,generic_sts = " "
	,Pharmacy_ID = " "
	,pharmacy_nm = " "
	,pharmacy_type_cd = " "
	,prescribing_prov_id = " "
	,rx_claim_alt_id_1 = " "
	,rx_claim_alt_id_2 = " "
	,rx_claim_alt_id_3 = " "
	,rx_claim_alt_id_4 = " "
	,requested_amt = " "
	,supply_flag = " "
	,cvx = " "
	,Practice_TIN = "62-1282917"
FROM
	ENCOUNTER   enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
		AND fin_nbr.active_ind = 1
		AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND fin_nbr.alias_pool_cd = 2554138229.00   ;FIN
   		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
		AND pat.active_ind = 1
		AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
		))
	, (INNER JOIN PERSON_ALIAS cmrn_nbr ON (pat.person_id = cmrn_nbr.person_id
		AND cmrn_nbr.active_ind = 1
		AND cmrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cmrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND cmrn_nbr.person_alias_type_cd =  2.00   ;CMRN
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
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
		AND enc_ins.active_ind = 1
		AND enc_ins.priority_seq = 1
		AND enc_ins.member_nbr != ' '
		AND (enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
		AND hp_ins.active_ind = 1
		AND (hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		AND hp_ins.health_plan_id IN (2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
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
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN prov_spec ON (prov.person_id = prov_spec.prsnl_id
		AND prov_spec.active_ind = 1
		AND prov_spec.primary_ind = 1
		AND prov_spec.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_spec.end_effective_dt_Tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
		))
	, (LEFT JOIN PRSNL_ALIAS dea ON (epr.prsnl_person_id = dea.person_id
		AND dea.active_ind = 1
		AND dea.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.prsnl_alias_type_cd = 1084.00  ;dea
		))
	, (INNER JOIN ADDRESS prov_addr ON (prov.person_id = prov_addr.parent_entity_id
		AND prov_addr.parent_entity_name = "PERSON"
		AND prov_addr.active_ind = 1
		AND prov_addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov_addr.address_type_cd = 754.00   ;BUSINESS
		AND prov_addr.address_id IN (SELECT MAX(prov_addr1.address_id) FROM address prov_addr1
			WHERE prov_addr1.parent_entity_id = prov.person_id
			AND prov_addr1.parent_entity_name = "PERSON"
			AND prov_addr1.active_ind = 1
			AND prov_addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.address_type_cd = 754.00)   ;BUSINESS
   		))
	, (INNER JOIN CLINICAL_EVENT CEWT ON (CEWT.encntr_id = enc.encntr_id
		AND CEWT.event_cd = 4154123.00/*Weight*/
		AND CEWT.result_val != ' '
		AND CEWT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN CLINICAL_EVENT CEHT ON (CEHT.encntr_id = enc.encntr_id
		AND CEHT.event_cd = 4154126.00/*Height*/
		AND CEHT.result_val != ' '
		AND CEHT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND CEHT.parent_event_id = CEWT.parent_event_id
		))
	, (INNER JOIN CLINICAL_EVENT CESY ON (CESY.encntr_id = enc.encntr_id
		AND CESY.event_cd = 703501.00/*Systolic*/
		AND CESY.result_val != ' '
		AND CESY.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND CESY.parent_event_id = CEHT.parent_event_id
		))
	, (INNER JOIN CLINICAL_EVENT CEDI ON (CEDI.encntr_id = enc.encntr_id
		AND CEDI.event_cd = 703516.00/*Diastolic*/
		AND CEDI.result_val != ' '
		AND CEDI.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND CEDI.parent_event_id = CESY.parent_event_id
		))
	, (LEFT JOIN CLINICAL_EVENT BMI_MEASURED ON (BMI_MEASURED.encntr_id = enc.encntr_id
		AND BMI_MEASURED.event_cd = 4154132.00 /*BMI Measured*/
 		AND BMI_MEASURED.result_val != ' '
		AND BMI_MEASURED.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND BMI_MEASURED.parent_event_id = CEDI.parent_event_id
		))
	, (LEFT JOIN CLINICAL_EVENT BMI_PERCENT ON (BMI_PERCENT.encntr_id = enc.encntr_id
		AND BMI_PERCENT.event_cd = 2550556697.00/*BMI Percentile*/
 		AND BMI_PERCENT.result_val != ' '
		AND BMI_PERCENT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND BMI_PERCENT.parent_event_id = BMI_MEASURED.parent_event_id
		))
	, (LEFT JOIN DIAGNOSIS diag ON (enc.encntr_id = diag.encntr_id
		AND diag.active_ind = 1
		AND (diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
	, (INNER JOIN NOMENCLATURE nom_diag ON (nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		AND ((nom_diag.source_identifier >= "V85.0" AND nom_diag.source_identifier <="V85.5")
			OR (nom_diag.source_identifier >= "Z68.00" AND nom_diag.source_identifier <= "Z68.54"))
		))
WHERE enc.active_ind = 1
	AND (enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,2560523697/*Results Only*/,
		20058643/*Legacy Data*/)
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate) AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
/****************************************************************************************************************
	Populate Record structure with BMI Data - Weight/Height/BP Diastolic/BP Systolic/BMI Measured/BMI Percentile
*****************************************************************************************************************/
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
 
	exp_data->list[cnt].pt_id_no = pt_id_no
	exp_data->list[cnt].subscriber_id = subscriber_id
	exp_data->list[cnt].medicaid_subscriber_nbr = medicaid_subscriber_nbr
	exp_data->list[cnt].medicare_subscriber_nbr = medicare_subscriber_nbr
	exp_data->list[cnt].member_alt_id_1 = member_alt_id_1
	exp_data->list[cnt].member_alt_id_2 = member_alt_id_2
	exp_data->list[cnt].member_alt_id_3 = member_alt_id_3
	exp_data->list[cnt].member_first_nm = member_first_nm
	exp_data->list[cnt].member_middle_nm = member_middle_nm
	exp_data->list[cnt].member_last_nm = member_last_nm
	exp_data->list[cnt].member_date_of_birth = member_date_of_birth
	exp_data->list[cnt].member_gender = member_gender
	exp_data->list[cnt].race = race
	exp_data->list[cnt].member_address_1 = member_address_1
	exp_data->list[cnt].member_address_2 = member_address_2
	exp_data->list[cnt].member_city = member_city
	exp_data->list[cnt].member_state = member_state
	exp_data->list[cnt].member_zip = member_zip
	exp_data->list[cnt].member_phone_1 = member_phone_1
	exp_data->list[cnt].dependent_number = dependent_number
	exp_data->list[cnt].Rendering_NPI = Rendering_NPI
	exp_data->list[cnt].Rendering_MPIN = Rendering_MPIN
	exp_data->list[cnt].Rendering_TIN = Rendering_TIN
	exp_data->list[cnt].Rend_Prov_Specialty = Rend_Prov_Specialty
	exp_data->list[cnt].Ordering_NPI = Ordering_NPI
	exp_data->list[cnt].Ordering_MPIN = Ordering_MPIN
	exp_data->list[cnt].Ordering_TIN = Ordering_TIN
	exp_data->list[cnt].Ordering_Prov_Specialty = Ordering_Prov_Specialty
	exp_data->list[cnt].rendering_provider_first_nm = rendering_provider_first_nm
	exp_data->list[cnt].rendering_provider_middle_nm = rendering_provider_middle_nm
	exp_data->list[cnt].rendering_provider_last_nm = rendering_provider_last_nm
	exp_data->list[cnt].rendering_provider_dea_code = rendering_provider_dea_code
	exp_data->list[cnt].rendering_provider_deg_cd = rendering_provider_deg_cd
	exp_data->list[cnt].rendering_provider_address_1 = rendering_provider_address_1
	exp_data->list[cnt].rendering_provider_address_2 = rendering_provider_address_2
	exp_data->list[cnt].rendering_provider_city = rendering_provider_city
	exp_data->list[cnt].rendering_provider_state = rendering_provider_state
	exp_data->list[cnt].rendering_provider_zip = rendering_provider_zip
	exp_data->list[cnt].rendering_provider_phone_1 = rendering_provider_phone_1
	exp_data->list[cnt].rendering_provider_phone_2 = rendering_provider_phone_2
	exp_data->list[cnt].rendering_provider_alt_id = rendering_provider_alt_id
	exp_data->list[cnt].Service_Date_From = Service_Date_From
	exp_data->list[cnt].Service_Date_Through = Service_Date_Through
	exp_data->list[cnt].icd_code_type = icd_code_type
	exp_data->list[cnt].icd_diagnosis_cd_1 = icd_diagnosis_cd_1
	exp_data->list[cnt].icd_diagnosis_cd_2 = icd_diagnosis_cd_2
	exp_data->list[cnt].icd_diagnosis_cd_3 = icd_diagnosis_cd_3
	exp_data->list[cnt].icd_diagnosis_cd_4 = icd_diagnosis_cd_4
	exp_data->list[cnt].icd_diagnosis_cd_5 = icd_diagnosis_cd_5
	exp_data->list[cnt].icd_diagnosis_cd_6 = icd_diagnosis_cd_6
	exp_data->list[cnt].icd_diagnosis_cd_7 = icd_diagnosis_cd_7
	exp_data->list[cnt].icd_diagnosis_cd_8 = icd_diagnosis_cd_8
	exp_data->list[cnt].icd_diagnosis_cd_9 = icd_diagnosis_cd_9
	exp_data->list[cnt].cpt_code = cpt_code
	exp_data->list[cnt].cpt_code_mod_1 = cpt_code_mod_1
	exp_data->list[cnt].cpt_code_mod_2 = cpt_code_mod_2
	exp_data->list[cnt].cpt2_code = cpt2_code
	exp_data->list[cnt].hcpcs_code = hcpcs_code
	exp_data->list[cnt].hcpcs_mod = hcpcs_mod
	exp_data->list[cnt].icd_procedure_cd_1 = icd_procedure_cd_1
	exp_data->list[cnt].icd_procedure_cd_2 = icd_procedure_cd_2
	exp_data->list[cnt].UB_Revenue_Code = UB_Revenue_Code
	exp_data->list[cnt].type_of_service_code = type_of_service_code
	exp_data->list[cnt].quantity_of_service = quantity_of_service
	exp_data->list[cnt].pcp_flg = pcp_flg
	exp_data->list[cnt].BP_Systolic = BP_Systolic
	exp_data->list[cnt].BP_Diastolic = BP_Diastolic
	exp_data->list[cnt].BMI_Result = BMI_Result
	exp_data->list[cnt].BMI_Percentile = BMI_Percentile
	exp_data->list[cnt].Member_Height = Member_Height
	exp_data->list[cnt].Member_Weight = Member_Weight
	exp_data->list[cnt].clin_user_defined_1 = clin_user_defined_1
	exp_data->list[cnt].clin_user_defined_2 = clin_user_defined_2
	exp_data->list[cnt].clin_user_defined_3 = clin_user_defined_3
	exp_data->list[cnt].clin_user_defined_4 = clin_user_defined_4
	exp_data->list[cnt].clin_user_defined_5 = clin_user_defined_5
	exp_data->list[cnt].clin_user_defined_6 = clin_user_defined_6
	exp_data->list[cnt].place_of_service_code = place_of_service_code
	exp_data->list[cnt].ref_range = ref_range
	exp_data->list[cnt].ab_ind = ab_ind
	exp_data->list[cnt].Fill_ord_num = Fill_ord_num
	exp_data->list[cnt].lab_claim_id_1 = lab_claim_id_1
	exp_data->list[cnt].lab_id = lab_id
	exp_data->list[cnt].lab_user_defined_1 = lab_user_defined_1
	exp_data->list[cnt].lab_user_defined_2 = lab_user_defined_2
	exp_data->list[cnt].loinc = loinc
	exp_data->list[cnt].lab_test_desc = lab_test_desc
	exp_data->list[cnt].obs_rslt_status = obs_rslt_status
	exp_data->list[cnt].result_dt = result_dt
	exp_data->list[cnt].order_dt = order_dt
	exp_data->list[cnt].service_dt = service_dt
	exp_data->list[cnt].pos_neg_rslt = pos_neg_rslt
	exp_data->list[cnt].lab_result_text = lab_result_text
	exp_data->list[cnt].result = result
	exp_data->list[cnt].snomed = snomed
	exp_data->list[cnt].unit = unit
	exp_data->list[cnt].National_drug_cd = National_drug_cd
	exp_data->list[cnt].qty_dispensed = qty_dispensed
	exp_data->list[cnt].fill_date = fill_date
	exp_data->list[cnt].days_supply = days_supply
	exp_data->list[cnt].dea_nbr = dea_nbr
	exp_data->list[cnt].denied_flg = denied_flg
	exp_data->list[cnt].generic_sts = generic_sts
	exp_data->list[cnt].Pharmacy_ID = Pharmacy_ID
	exp_data->list[cnt].pharmacy_nm = pharmacy_nm
	exp_data->list[cnt].pharmacy_type_cd = pharmacy_type_cd
	exp_data->list[cnt].prescribing_prov_id = prescribing_prov_id
	exp_data->list[cnt].rx_claim_alt_id_1 = rx_claim_alt_id_1
	exp_data->list[cnt].rx_claim_alt_id_2 = rx_claim_alt_id_2
	exp_data->list[cnt].rx_claim_alt_id_3 = rx_claim_alt_id_3
	exp_data->list[cnt].rx_claim_alt_id_4 = rx_claim_alt_id_4
	exp_data->list[cnt].requested_amt = requested_amt
	exp_data->list[cnt].supply_flag = supply_flag
	exp_data->list[cnt].cvx = cvx
	exp_data->list[cnt].Practice_TIN = Practice_TIN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
 
CALL ECHO ("***** GETTING Lab Data *****")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Lab Data
**************************************************************/
SELECT DISTINCT
	pt_id_no = EVALUATE2(IF (SIZE(cmrn_nbr.alias) = 0) " " ELSE TRIM(cmrn_nbr.alias,3) ENDIF)
	,subscriber_id = EVALUATE2(IF (SIZE(enc_ins.MEMBER_NBR) = 0) " " ELSE TRIM(enc_ins.MEMBER_NBR,3) ENDIF)
	,medicaid_subscriber_nbr = " "
	,medicare_subscriber_nbr = " "
	,member_alt_id_1 = " "
	,member_alt_id_2 = " "
	,member_alt_id_3 = " "
	,member_first_nm = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(pat.name_first_key,3) ENDIF)
	,member_middle_nm = EVALUATE2(IF (SIZE(pat.name_middle_key) = 0) " " ELSE TRIM(pat.name_middle_key,3) ENDIF)
	,member_last_nm = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(pat.name_last_key,3) ENDIF)
	,member_date_of_birth = EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(pat.birth_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,member_gender = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M",364.00, "U", 0.00, "U"," ")
	,race = EVALUATE(pat.race_cd, 0.00, "Other Race None", 309318.00, "American Indian or Alaska Native",
	     309317.00,	"Asian", 309315.00, "Black or African American", 23274729.00, "Other Race Multiple",
    	4189861.00, "Native Hawaiian or Pacific Islander", 18702439.00,	"Other Race Patient Declined",
	   25804105.00,	"Other Race Unavailable",309316.00, "White"," ")
    ,member_address_1 = EVALUATE2(IF (SIZE(addr.street_addr) = 0) " " ELSE TRIM(addr.street_addr,3) ENDIF)
    ,member_address_2 = EVALUATE2(IF (SIZE(addr.street_addr2) = 0) " " ELSE TRIM(addr.street_addr2,3) ENDIF)
    ,member_city = EVALUATE2(IF (SIZE(addr.city) = 0) " " ELSE TRIM(addr.city,3) ENDIF)
    ,member_state = EVALUATE2(IF (SIZE(addr.state) = 0) " " ELSE TRIM(addr.State,3) ENDIF)
    ,member_zip = EVALUATE2(IF (SIZE(addr.zipcode_key) = 0) " " ELSE TRIM(SUBSTRING(1,5,addr.zipcode_key),3) ENDIF)
    ,member_phone_1 = " "
    ,dependent_number = " "
	,Rendering_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	,Rendering_MPIN = " "
	,Rendering_TIN = " "
	,Rend_Prov_Specialty = EVALUATE2(IF (prov_spec.specialty_cd = 0.00) " "
			ELSE UAR_GET_CODE_DISPLAY(prov_spec.specialty_cd) ENDIF)
	,Ordering_NPI = " "
	,Ordering_MPIN = " "
	,Ordering_TIN = " "
	,Ordering_Prov_Specialty = " "
	,rendering_provider_first_nm = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(prov.name_first_key,3) ENDIF)
	,rendering_provider_middle_nm = " "
	,rendering_provider_last_nm = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(prov.name_last_key,3) ENDIF)
	,rendering_provider_dea_code = EVALUATE2(IF (SIZE(dea.alias) = 0) " " ELSE TRIM(dea.alias,3) ENDIF)
	,rendering_provider_deg_cd = " "
	,rendering_provider_address_1 = EVALUATE2(IF (SIZE(prov_addr.street_addr) = 0) " "
		ELSE TRIM(prov_addr.street_addr,3) ENDIF)
	,rendering_provider_address_2 = EVALUATE2(IF (SIZE(prov_addr.street_addr2) = 0) " "
		ELSE TRIM(prov_addr.street_addr2,3) ENDIF)
	,rendering_provider_city = EVALUATE2(IF (SIZE(prov_addr.city) = 0) " " ELSE TRIM(prov_addr.city,3) ENDIF)
	,rendering_provider_state = EVALUATE2(IF (SIZE(prov_addr.state) = 0) " " ELSE TRIM(prov_addr.State,3) ENDIF)
	,rendering_provider_zip = EVALUATE2(IF (SIZE(prov_addr.zipcode_key) = 0) " "
		ELSE TRIM(SUBSTRING(1,5,prov_addr.zipcode_key),3) ENDIF)
	,rendering_provider_phone_1 = " "
	,rendering_provider_phone_2 = " "
	,rendering_provider_alt_id = " "
    ,Service_Date_From = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,Service_Date_Through = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,icd_code_type = "0"
	,icd_diagnosis_cd_1 = EVALUATE2(IF (SIZE(nom_diag.source_identifier) = 0) " " ELSE TRIM(nom_diag.source_identifier,3) ENDIF)
	,icd_diagnosis_cd_2 = " "
	,icd_diagnosis_cd_3 = " "
	,icd_diagnosis_cd_4 = " "
	,icd_diagnosis_cd_5 = " "
	,icd_diagnosis_cd_6 = " "
	,icd_diagnosis_cd_7 = " "
	,icd_diagnosis_cd_8 = " "
	,icd_diagnosis_cd_9 = " "
	,cpt_code = EVALUATE2(IF (SIZE(cm.field6) = 0) " " ELSE TRIM(cm.field6,3) ENDIF)
	,cpt_code_mod_1 = " "
	,cpt_code_mod_2 = " "
	,cpt2_code = " "
	,hcpcs_code = " "
	,hcpcs_mod = " "
	,icd_procedure_cd_1 = " "
	,icd_procedure_cd_2 = " "
	,UB_Revenue_Code = " "
	,type_of_service_code = "Outpatient"
	,quantity_of_service = " "
	,pcp_flg = "Y"
	,BP_Systolic = " "
	,BP_Diastolic = " "
	,BMI_Result = " "
	,BMI_Percentile = " "
	,Member_Height = " "
	,Member_Weight = " "
	,clin_user_defined_1 = " "
	,clin_user_defined_2 = " "
	,clin_user_defined_3 = " "
	,clin_user_defined_4 = " "
	,clin_user_defined_5 = " "
	,clin_user_defined_6 = " "
	,place_of_service_code = "OC"
	,ref_range = BUILD(IF (SIZE(TRIM(ce.normal_low,3)) = 0) " "
		ELSE TRIM(ce.normal_low,3) ENDIF,
		IF (SIZE(TRIM(ce.normal_low,3)) = 0 AND SIZE(TRIM(ce.normal_high,3)) = 0) " "
			ELSEIF (SIZE(TRIM(ce.normal_low,3)) > 0 AND SIZE(TRIM(ce.normal_high,3)) = 0) " "
			ELSE "-" ENDIF,
			IF (SIZE(TRIM(ce.normal_high,3)) = 0) " "
			ELSE TRIM(ce.normal_high,3) ENDIF)
	,ab_ind = " "
	,Fill_ord_num = " "
	,lab_claim_id_1 = " "
	,lab_id = " "
	,lab_user_defined_1 = " "
	,lab_user_defined_2 = " "
	,loinc = EVALUATE2(IF (cid.CONCEPT_IDENTIFIER_DTA_ID IS NULL AND nom_loinc.nomenclature_id != 0.00)
					TRIM(nom_loinc.source_identifier,3)
				ELSEIF (cid.CONCEPT_IDENTIFIER_DTA_ID IS NOT NULL AND nom_loinc.nomenclature_id != 0.00)
					SUBSTRING(7,SIZE(TRIM(cid.concept_cki,3)),(TRIM(cid.concept_cki,3)))
				ELSE " " ENDIF)
	,lab_test_desc = EVALUATE2(IF (SIZE(ord_cat.description) = 0) " " ELSE TRIM(ord_cat.description,3) ENDIF)
	,obs_rslt_status = "F"
	,result_dt = EVALUATE2(IF (TRIM(CNVTSTRING(ce.performed_dt_tm),3) IN ("0","31558644000"))
		EVALUATE2(IF (TRIM(CNVTSTRING(ord.orig_order_dt_tm),3) IN ("0","31558644000")) " "
			ELSE FORMAT(ord.orig_order_dt_tm, "YYYY-MM-DD;;Q") ENDIF)
		ELSE FORMAT(ce.performed_dt_tm,"YYYY-MM-DD;;Q") ENDIF)
	,order_dt = EVALUATE2(IF (TRIM(CNVTSTRING(ord.orig_order_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(ord.orig_order_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,service_dt = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
		ELSE FORMAT(enc.reg_dt_tm, "YYYY-MM-DD;;q") ENDIF)
	,pos_neg_rslt = " "
	,lab_result_text = EVALUATE2(IF (SIZE(ce_cv1.description) = 0) " " ELSE TRIM(ce_cv1.description,3) ENDIF)
	,result = EVALUATE2(IF (SIZE(ce.result_val) = 0) " " ELSE TRIM(ce.result_val,3) ENDIF)
	,snomed = " "
	,unit = EVALUATE2(IF (SIZE(ce_cv2.display) = 0) " " ELSE TRIM(ce_cv2.display,3) ENDIF)
	,National_drug_cd = " "
	,qty_dispensed = " "
	,fill_date = " "
	,days_supply = " "
	,dea_nbr = " "
	,denied_flg = " "
	,generic_sts = " "
	,Pharmacy_ID = " "
	,pharmacy_nm = " "
	,pharmacy_type_cd = " "
	,prescribing_prov_id = " "
	,rx_claim_alt_id_1 = " "
	,rx_claim_alt_id_2 = " "
	,rx_claim_alt_id_3 = " "
	,rx_claim_alt_id_4 = " "
	,requested_amt = " "
	,supply_flag = " "
	,cvx = " "
	,Practice_TIN = "62-1282917"
FROM
	ENCOUNTER   enc
	, (INNER JOIN ENCNTR_ALIAS fin_nbr ON (enc.encntr_id = fin_nbr.encntr_id
		AND fin_nbr.active_ind = 1
		AND fin_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND fin_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND fin_nbr.alias_pool_cd = 2554138229.00   ;FIN
   		))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
		AND pat.active_ind = 1
		AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
		))
	, (INNER JOIN PERSON_ALIAS cmrn_nbr ON (pat.person_id = cmrn_nbr.person_id
		AND cmrn_nbr.active_ind = 1
		AND cmrn_nbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND cmrn_nbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND cmrn_nbr.person_alias_type_cd =  2.00   ;CMRN
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
	, (INNER JOIN ENCNTR_PLAN_RELTN enc_ins ON (enc.encntr_id = enc_ins.encntr_id
		AND enc_ins.active_ind = 1
		AND enc_ins.priority_seq = 1
		AND enc_ins.member_nbr != ' '
		AND (enc_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
	, (INNER JOIN HEALTH_PLAN hp_ins ON (enc_ins.health_plan_id = hp_ins.health_plan_id
		AND hp_ins.active_ind = 1
		AND (hp_ins.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND hp_ins.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		AND hp_ins.health_plan_id IN (2983249.00 /*Medicare UHC Advantage*/,2985861.00 /*Medicare UHC Dual Complete*/,
			2985957.00 /*Medicare UHC Dual Complete Part B*/,2985961.00 /*Medicare UHC IP Denial Part B*/,
			2983341.00 /*Misc United Healthcare*/,2983161.00 /*United Healthcare*/,
			2983345.00 /*United Healthcare Community*/)
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
   		AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (LEFT JOIN PRSNL_SPECIALTY_RELTN prov_spec ON (prov.person_id = prov_spec.prsnl_id
		AND prov_spec.active_ind = 1
		AND prov_spec.primary_ind = 1
		AND prov_spec.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_spec.end_effective_dt_Tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN PRSNL_ALIAS npi ON (prov.person_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
		))
	, (LEFT JOIN PRSNL_ALIAS dea ON (prov.person_id = dea.person_id
		AND dea.active_ind = 1
		AND dea.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND dea.prsnl_alias_type_cd = 1084.00  ;dea
		))
	, (INNER JOIN ADDRESS prov_addr ON (prov.person_id = prov_addr.parent_entity_id
		AND prov_addr.parent_entity_name = "PERSON"
		AND prov_addr.active_ind = 1
		AND prov_addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND prov_addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov_addr.address_type_cd = 754.00   ;BUSINESS
		AND prov_addr.address_id IN (SELECT MAX(prov_addr1.address_id) FROM address prov_addr1
			WHERE prov_addr1.parent_entity_id = prov.person_id
			AND prov_addr1.parent_entity_name = "PERSON"
			AND prov_addr1.active_ind = 1
			AND prov_addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND prov_addr1.address_type_cd = 754.00)   ;BUSINESS
   		))
	, (INNER JOIN ORDER_CATALOG ord_cat ON (ord.catalog_cd = ord_cat.catalog_cd
		AND ord_cat.active_ind = 1
		AND ord_cat.catalog_type_cd IN (2513.00 /*Laboratory*/)
		AND ord_cat.activity_type_cd IN (692.00 /*Gen Lab*/, 674.00 /*Blood Bank*/,
			47576777.00 /*Blood Gases*/, 696.00 /*Microbiology*/)
		))
	, (INNER JOIN ORDER_DETAIL od_perform_loc ON (ord.order_id = od_perform_loc.order_id
		AND od_perform_loc.oe_field_meaning_id = 18.00 ; "PERFORMLOC"
		AND od_perform_loc.oe_field_value IN (2560368733.00 /*LabCorp*/, 2560368555.00 /*Quest*/)
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
		AND TRIM(ce.result_val,3) != ' '
		AND ce.event_cd NOT IN ( 2562136019.00)
		))
	, (INNER JOIN CODE_VALUE ce_cv1 ON (ce.event_cd = ce_cv1.code_value
		AND ce_cv1.code_set = 72  ;Description for ce.event_cd
		AND ce_cv1.active_ind = 1
		))
	, (LEFT JOIN CODE_VALUE ce_cv2 ON (ce.result_units_cd = ce_cv2.code_value
		AND ce_cv2.code_set = 54	;Description for CE.Result_Units_cd
		AND ce_cv2.active_ind = 1
		))
	, (INNER JOIN ORDER_DETAIL od_spec_type ON (ord.order_id = od_spec_type.order_id
		AND od_spec_type.oe_field_meaning_id = 9.00 ; "SPECIMEN TYPE"
		AND od_spec_type.action_sequence IN (SELECT MAX(od.action_sequence)
			FROM ORDER_DETAIL od
			WHERE od_spec_type.order_id = od.order_id
			AND od.oe_field_meaning_id = 9.00); "SPECIMEN TYPE"
		))
    , (LEFT JOIN REF_CD_MAP_HEADER rcmh ON (ord.encntr_id = rcmh.encntr_id
   		AND ord.person_id = rcmh.person_id
   		AND ce.event_id = rcmh.event_id
   		))
    , (LEFT JOIN REF_CD_MAP_DETAIL rcmd ON (rcmh.ref_cd_map_header_id = rcmd.ref_cd_map_header_id
   		))
    , (LEFT JOIN NOMENCLATURE nom_loinc ON (rcmd.nomenclature_id = nom_loinc.nomenclature_id
   		AND nom_loinc.active_ind = 1
   		AND (nom_loinc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
   		AND nom_loinc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
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
	, (INNER JOIN DIAGNOSIS diag ON (enc.encntr_id = diag.encntr_id
		AND diag.active_ind = 1
		AND (diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
	, (INNER JOIN NOMEN_ENTITY_RELTN ner ON (ner.encntr_id = enc.encntr_id
		AND ner.parent_entity_name = "ORDERS"
		AND ner.parent_entity_id = ord.order_id
		AND ner.person_id = enc.person_id
		AND ner.person_id = ord.person_id
		AND ner.active_ind = 1
		AND ner.priority = 1
		))
	, (INNER JOIN NOMENCLATURE nom_diag ON (ner.nomenclature_id = nom_diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND (nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))
		))
WHERE enc.active_ind = 1
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate) AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
  	AND NULLIND(cid.concept_identifier_dta_id) != 0		;Exclude results with No LOINC
 	AND nom_loinc.nomenclature_id != 0.00		;Exclude results with No LOINC
ORDER BY ord.order_id
 
/****************************************************************************
	Populate Record structure with Lab Data
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
 
	exp_data->list[cnt].pt_id_no = pt_id_no
	exp_data->list[cnt].subscriber_id = subscriber_id
	exp_data->list[cnt].medicaid_subscriber_nbr = medicaid_subscriber_nbr
	exp_data->list[cnt].medicare_subscriber_nbr = medicare_subscriber_nbr
	exp_data->list[cnt].member_alt_id_1 = member_alt_id_1
	exp_data->list[cnt].member_alt_id_2 = member_alt_id_2
	exp_data->list[cnt].member_alt_id_3 = member_alt_id_3
	exp_data->list[cnt].member_first_nm = member_first_nm
	exp_data->list[cnt].member_middle_nm = member_middle_nm
	exp_data->list[cnt].member_last_nm = member_last_nm
	exp_data->list[cnt].member_date_of_birth = member_date_of_birth
	exp_data->list[cnt].member_gender = member_gender
	exp_data->list[cnt].race = race
	exp_data->list[cnt].member_address_1 = member_address_1
	exp_data->list[cnt].member_address_2 = member_address_2
	exp_data->list[cnt].member_city = member_city
	exp_data->list[cnt].member_state = member_state
	exp_data->list[cnt].member_zip = member_zip
	exp_data->list[cnt].member_phone_1 = member_phone_1
	exp_data->list[cnt].dependent_number = dependent_number
	exp_data->list[cnt].Rendering_NPI = Rendering_NPI
	exp_data->list[cnt].Rendering_MPIN = Rendering_MPIN
	exp_data->list[cnt].Rendering_TIN = Rendering_TIN
	exp_data->list[cnt].Rend_Prov_Specialty = Rend_Prov_Specialty
	exp_data->list[cnt].Ordering_NPI = Ordering_NPI
	exp_data->list[cnt].Ordering_MPIN = Ordering_MPIN
	exp_data->list[cnt].Ordering_TIN = Ordering_TIN
	exp_data->list[cnt].Ordering_Prov_Specialty = Ordering_Prov_Specialty
	exp_data->list[cnt].rendering_provider_first_nm = rendering_provider_first_nm
	exp_data->list[cnt].rendering_provider_middle_nm = rendering_provider_middle_nm
	exp_data->list[cnt].rendering_provider_last_nm = rendering_provider_last_nm
	exp_data->list[cnt].rendering_provider_dea_code = rendering_provider_dea_code
	exp_data->list[cnt].rendering_provider_deg_cd = rendering_provider_deg_cd
	exp_data->list[cnt].rendering_provider_address_1 = rendering_provider_address_1
	exp_data->list[cnt].rendering_provider_address_2 = rendering_provider_address_2
	exp_data->list[cnt].rendering_provider_city = rendering_provider_city
	exp_data->list[cnt].rendering_provider_state = rendering_provider_state
	exp_data->list[cnt].rendering_provider_zip = rendering_provider_zip
	exp_data->list[cnt].rendering_provider_phone_1 = rendering_provider_phone_1
	exp_data->list[cnt].rendering_provider_phone_2 = rendering_provider_phone_2
	exp_data->list[cnt].rendering_provider_alt_id = rendering_provider_alt_id
	exp_data->list[cnt].Service_Date_From = Service_Date_From
	exp_data->list[cnt].Service_Date_Through = Service_Date_Through
	exp_data->list[cnt].icd_code_type = icd_code_type
	exp_data->list[cnt].icd_diagnosis_cd_1 = icd_diagnosis_cd_1
	exp_data->list[cnt].icd_diagnosis_cd_2 = icd_diagnosis_cd_2
	exp_data->list[cnt].icd_diagnosis_cd_3 = icd_diagnosis_cd_3
	exp_data->list[cnt].icd_diagnosis_cd_4 = icd_diagnosis_cd_4
	exp_data->list[cnt].icd_diagnosis_cd_5 = icd_diagnosis_cd_5
	exp_data->list[cnt].icd_diagnosis_cd_6 = icd_diagnosis_cd_6
	exp_data->list[cnt].icd_diagnosis_cd_7 = icd_diagnosis_cd_7
	exp_data->list[cnt].icd_diagnosis_cd_8 = icd_diagnosis_cd_8
	exp_data->list[cnt].icd_diagnosis_cd_9 = icd_diagnosis_cd_9
	exp_data->list[cnt].cpt_code = cpt_code
	exp_data->list[cnt].cpt_code_mod_1 = cpt_code_mod_1
	exp_data->list[cnt].cpt_code_mod_2 = cpt_code_mod_2
	exp_data->list[cnt].cpt2_code = cpt2_code
	exp_data->list[cnt].hcpcs_code = hcpcs_code
	exp_data->list[cnt].hcpcs_mod = hcpcs_mod
	exp_data->list[cnt].icd_procedure_cd_1 = icd_procedure_cd_1
	exp_data->list[cnt].icd_procedure_cd_2 = icd_procedure_cd_2
	exp_data->list[cnt].UB_Revenue_Code = UB_Revenue_Code
	exp_data->list[cnt].type_of_service_code = type_of_service_code
	exp_data->list[cnt].quantity_of_service = quantity_of_service
	exp_data->list[cnt].pcp_flg = pcp_flg
	exp_data->list[cnt].BP_Systolic = BP_Systolic
	exp_data->list[cnt].BP_Diastolic = BP_Diastolic
	exp_data->list[cnt].BMI_Result = BMI_Result
	exp_data->list[cnt].BMI_Percentile = BMI_Percentile
	exp_data->list[cnt].Member_Height = Member_Height
	exp_data->list[cnt].Member_Weight = Member_Weight
	exp_data->list[cnt].clin_user_defined_1 = clin_user_defined_1
	exp_data->list[cnt].clin_user_defined_2 = clin_user_defined_2
	exp_data->list[cnt].clin_user_defined_3 = clin_user_defined_3
	exp_data->list[cnt].clin_user_defined_4 = clin_user_defined_4
	exp_data->list[cnt].clin_user_defined_5 = clin_user_defined_5
	exp_data->list[cnt].clin_user_defined_6 = clin_user_defined_6
	exp_data->list[cnt].place_of_service_code = place_of_service_code
	exp_data->list[cnt].ref_range = ref_range
	exp_data->list[cnt].ab_ind = ab_ind
	exp_data->list[cnt].Fill_ord_num = Fill_ord_num
	exp_data->list[cnt].lab_claim_id_1 = lab_claim_id_1
	exp_data->list[cnt].lab_id = lab_id
	exp_data->list[cnt].lab_user_defined_1 = lab_user_defined_1
	exp_data->list[cnt].lab_user_defined_2 = lab_user_defined_2
	exp_data->list[cnt].loinc = loinc
	exp_data->list[cnt].lab_test_desc = lab_test_desc
	exp_data->list[cnt].obs_rslt_status = obs_rslt_status
	exp_data->list[cnt].result_dt = result_dt
	exp_data->list[cnt].order_dt = order_dt
	exp_data->list[cnt].service_dt = service_dt
	exp_data->list[cnt].pos_neg_rslt = pos_neg_rslt
	exp_data->list[cnt].lab_result_text = lab_result_text
	exp_data->list[cnt].result = result
	exp_data->list[cnt].snomed = snomed
	exp_data->list[cnt].unit = unit
	exp_data->list[cnt].National_drug_cd = National_drug_cd
	exp_data->list[cnt].qty_dispensed = qty_dispensed
	exp_data->list[cnt].fill_date = fill_date
	exp_data->list[cnt].days_supply = days_supply
	exp_data->list[cnt].dea_nbr = dea_nbr
	exp_data->list[cnt].denied_flg = denied_flg
	exp_data->list[cnt].generic_sts = generic_sts
	exp_data->list[cnt].Pharmacy_ID = Pharmacy_ID
	exp_data->list[cnt].pharmacy_nm = pharmacy_nm
	exp_data->list[cnt].pharmacy_type_cd = pharmacy_type_cd
	exp_data->list[cnt].prescribing_prov_id = prescribing_prov_id
	exp_data->list[cnt].rx_claim_alt_id_1 = rx_claim_alt_id_1
	exp_data->list[cnt].rx_claim_alt_id_2 = rx_claim_alt_id_2
	exp_data->list[cnt].rx_claim_alt_id_3 = rx_claim_alt_id_3
	exp_data->list[cnt].rx_claim_alt_id_4 = rx_claim_alt_id_4
	exp_data->list[cnt].requested_amt = requested_amt
	exp_data->list[cnt].supply_flag = supply_flag
	exp_data->list[cnt].cvx = cvx
	exp_data->list[cnt].Practice_TIN = Practice_TIN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** BUILD Output ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/****************************************************************************
	Build Output
*****************************************************************************/
 
IF (exp_data->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",exp_data->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("pt_id_no", cov_pipe,
			"subscriber_id", cov_pipe,
			"medicaid_subscriber_nbr", cov_pipe,
			"medicare_subscriber_nbr", cov_pipe,
			"member_alt_id_1", cov_pipe,
			"member_alt_id_2", cov_pipe,
			"member_alt_id_3", cov_pipe,
			"member_first_nm", cov_pipe,
			"member_middle_nm", cov_pipe,
			"member_last_nm", cov_pipe,
			"member_date_of_birth", cov_pipe,
			"member_gender", cov_pipe,
			"race", cov_pipe,
			"member_address_1", cov_pipe,
			"member_address_2", cov_pipe,
			"member_city", cov_pipe,
			"member_state", cov_pipe,
			"member_zip", cov_pipe,
			"member_phone_1", cov_pipe,
			"dependent_number", cov_pipe,
			"Rendering_NPI", cov_pipe,
			"Rendering_MPIN", cov_pipe,
			"Rendering_TIN", cov_pipe,
			"Rend_Prov_Specialty", cov_pipe,
			"Ordering_NPI", cov_pipe,
			"Ordering_MPIN", cov_pipe,
			"Ordering_TIN", cov_pipe,
			"Ordering_Prov_Specialty", cov_pipe,
			"rendering_provider_first_nm", cov_pipe,
			"rendering_provider_middle_nm", cov_pipe,
			"rendering_provider_last_nm", cov_pipe,
			"rendering_provider_dea_code", cov_pipe,
			"rendering_provider_deg_cd", cov_pipe,
			"rendering_provider_address_1", cov_pipe,
			"rendering_provider_address_2", cov_pipe,
			"rendering_provider_city", cov_pipe,
			"rendering_provider_state", cov_pipe,
			"rendering_provider_zip", cov_pipe,
			"rendering_provider_phone_1", cov_pipe,
			"rendering_provider_phone_2", cov_pipe,
			"rendering_provider_alt_id", cov_pipe,
			"Service_Date_From", cov_pipe,
			"Service_Date_Through", cov_pipe,
			"icd_code_type", cov_pipe,
			"icd_diagnosis_cd_1", cov_pipe,
			"icd_diagnosis_cd_2", cov_pipe,
			"icd_diagnosis_cd_3", cov_pipe,
			"icd_diagnosis_cd_4", cov_pipe,
			"icd_diagnosis_cd_5", cov_pipe,
			"icd_diagnosis_cd_6", cov_pipe,
			"icd_diagnosis_cd_7", cov_pipe,
			"icd_diagnosis_cd_8", cov_pipe,
			"icd_diagnosis_cd_9", cov_pipe,
			"cpt_code", cov_pipe,
			"cpt_code_mod_1", cov_pipe,
			"cpt_code_mod_2", cov_pipe,
			"cpt2_code", cov_pipe,
			"hcpcs_code", cov_pipe,
			"hcpcs_mod", cov_pipe,
			"icd_procedure_cd_1", cov_pipe,
			"icd_procedure_cd_2", cov_pipe,
			"UB_Revenue_Code", cov_pipe,
			"type_of_service_code", cov_pipe,
			"quantity_of_service", cov_pipe,
			"pcp_flg", cov_pipe,
			"BP_Systolic", cov_pipe,
			"BP_Diastolic", cov_pipe,
			"BMI_Result", cov_pipe,
			"BMI_Percentile", cov_pipe,
			"Member_Height", cov_pipe,
			"Member_Weight", cov_pipe,
			"clin_user_defined_1", cov_pipe,
			"clin_user_defined_2", cov_pipe,
			"clin_user_defined_3", cov_pipe,
			"clin_user_defined_4", cov_pipe,
			"clin_user_defined_5", cov_pipe,
			"clin_user_defined_6", cov_pipe,
			"place_of_service_code", cov_pipe,
			"ref_range", cov_pipe,
			"ab_ind", cov_pipe,
			"Fill_ord_num", cov_pipe,
			"lab_claim_id_1", cov_pipe,
			"lab_id", cov_pipe,
			"lab_user_defined_1", cov_pipe,
			"lab_user_defined_2", cov_pipe,
			"loinc", cov_pipe,
			"lab_test_desc", cov_pipe,
			"obs_rslt_status", cov_pipe,
			"result_dt", cov_pipe,
			"order_dt", cov_pipe,
			"service_dt", cov_pipe,
			"pos_neg_rslt", cov_pipe,
			"lab_result_text", cov_pipe,
			"result", cov_pipe,
			"snomed", cov_pipe,
			"unit", cov_pipe,
			"National_drug_cd", cov_pipe,
			"qty_dispensed", cov_pipe,
			"fill_date", cov_pipe,
			"days_supply", cov_pipe,
			"dea_nbr", cov_pipe,
			"denied_flg", cov_pipe,
			"generic_sts", cov_pipe,
			"Pharmacy_ID", cov_pipe,
			"pharmacy_nm", cov_pipe,
			"pharmacy_type_cd", cov_pipe,
			"prescribing_prov_id", cov_pipe,
			"rx_claim_alt_id_1", cov_pipe,
			"rx_claim_alt_id_2", cov_pipe,
			"rx_claim_alt_id_3", cov_pipe,
			"rx_claim_alt_id_4", cov_pipe,
			"requested_amt", cov_pipe,
			"supply_flag", cov_pipe,
			"cvx", cov_pipe,
			"Practice_TIN")
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						exp_data->list[dt.seq].pt_id_no, cov_pipe,
						exp_data->list[dt.seq].subscriber_id, cov_pipe,
						exp_data->list[dt.seq].medicaid_subscriber_nbr, cov_pipe,
						exp_data->list[dt.seq].medicare_subscriber_nbr, cov_pipe,
						exp_data->list[dt.seq].member_alt_id_1, cov_pipe,
						exp_data->list[dt.seq].member_alt_id_2, cov_pipe,
						exp_data->list[dt.seq].member_alt_id_3, cov_pipe,
						exp_data->list[dt.seq].member_first_nm, cov_pipe,
						exp_data->list[dt.seq].member_middle_nm, cov_pipe,
						exp_data->list[dt.seq].member_last_nm, cov_pipe,
						exp_data->list[dt.seq].member_date_of_birth, cov_pipe,
						exp_data->list[dt.seq].member_gender, cov_pipe,
						exp_data->list[dt.seq].race, cov_pipe,
						exp_data->list[dt.seq].member_address_1, cov_pipe,
						exp_data->list[dt.seq].member_address_2, cov_pipe,
						exp_data->list[dt.seq].member_city, cov_pipe,
						exp_data->list[dt.seq].member_state, cov_pipe,
						exp_data->list[dt.seq].member_zip, cov_pipe,
						exp_data->list[dt.seq].member_phone_1, cov_pipe,
						exp_data->list[dt.seq].dependent_number, cov_pipe,
						exp_data->list[dt.seq].Rendering_NPI, cov_pipe,
						exp_data->list[dt.seq].Rendering_MPIN, cov_pipe,
						exp_data->list[dt.seq].Rendering_TIN, cov_pipe,
						exp_data->list[dt.seq].Rend_Prov_Specialty, cov_pipe,
						exp_data->list[dt.seq].Ordering_NPI, cov_pipe,
						exp_data->list[dt.seq].Ordering_MPIN, cov_pipe,
						exp_data->list[dt.seq].Ordering_TIN, cov_pipe,
						exp_data->list[dt.seq].Ordering_Prov_Specialty, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_first_nm, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_middle_nm, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_last_nm, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_dea_code, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_deg_cd, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_address_1, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_address_2, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_city, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_state, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_zip, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_phone_1, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_phone_2, cov_pipe,
						exp_data->list[dt.seq].rendering_provider_alt_id, cov_pipe,
						exp_data->list[dt.seq].Service_Date_From, cov_pipe,
						exp_data->list[dt.seq].Service_Date_Through, cov_pipe,
						exp_data->list[dt.seq].icd_code_type, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_1, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_2, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_3, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_4, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_5, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_6, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_7, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_8, cov_pipe,
						exp_data->list[dt.seq].icd_diagnosis_cd_9, cov_pipe,
						exp_data->list[dt.seq].cpt_code, cov_pipe,
						exp_data->list[dt.seq].cpt_code_mod_1, cov_pipe,
						exp_data->list[dt.seq].cpt_code_mod_2, cov_pipe,
						exp_data->list[dt.seq].cpt2_code, cov_pipe,
						exp_data->list[dt.seq].hcpcs_code, cov_pipe,
						exp_data->list[dt.seq].hcpcs_mod, cov_pipe,
						exp_data->list[dt.seq].icd_procedure_cd_1, cov_pipe,
						exp_data->list[dt.seq].icd_procedure_cd_2, cov_pipe,
						exp_data->list[dt.seq].UB_Revenue_Code, cov_pipe,
						exp_data->list[dt.seq].type_of_service_code, cov_pipe,
						exp_data->list[dt.seq].quantity_of_service, cov_pipe,
						exp_data->list[dt.seq].pcp_flg, cov_pipe,
						exp_data->list[dt.seq].BP_Systolic, cov_pipe,
						exp_data->list[dt.seq].BP_Diastolic, cov_pipe,
						exp_data->list[dt.seq].BMI_Result, cov_pipe,
						exp_data->list[dt.seq].BMI_Percentile, cov_pipe,
						exp_data->list[dt.seq].Member_Height, cov_pipe,
						exp_data->list[dt.seq].Member_Weight, cov_pipe,
						exp_data->list[dt.seq].clin_user_defined_1, cov_pipe,
						exp_data->list[dt.seq].clin_user_defined_2, cov_pipe,
						exp_data->list[dt.seq].clin_user_defined_3, cov_pipe,
						exp_data->list[dt.seq].clin_user_defined_4, cov_pipe,
						exp_data->list[dt.seq].clin_user_defined_5, cov_pipe,
						exp_data->list[dt.seq].clin_user_defined_6, cov_pipe,
						exp_data->list[dt.seq].place_of_service_code, cov_pipe,
						exp_data->list[dt.seq].ref_range, cov_pipe,
						exp_data->list[dt.seq].ab_ind, cov_pipe,
						exp_data->list[dt.seq].Fill_ord_num, cov_pipe,
						exp_data->list[dt.seq].lab_claim_id_1, cov_pipe,
						exp_data->list[dt.seq].lab_id, cov_pipe,
						exp_data->list[dt.seq].lab_user_defined_1, cov_pipe,
						exp_data->list[dt.seq].lab_user_defined_2, cov_pipe,
						exp_data->list[dt.seq].loinc, cov_pipe,
						exp_data->list[dt.seq].lab_test_desc, cov_pipe,
						exp_data->list[dt.seq].obs_rslt_status, cov_pipe,
						exp_data->list[dt.seq].result_dt, cov_pipe,
						exp_data->list[dt.seq].order_dt, cov_pipe,
						exp_data->list[dt.seq].service_dt, cov_pipe,
						exp_data->list[dt.seq].pos_neg_rslt, cov_pipe,
						exp_data->list[dt.seq].lab_result_text, cov_pipe,
						exp_data->list[dt.seq].result, cov_pipe,
						exp_data->list[dt.seq].snomed, cov_pipe,
						exp_data->list[dt.seq].unit, cov_pipe,
						exp_data->list[dt.seq].National_drug_cd, cov_pipe,
						exp_data->list[dt.seq].qty_dispensed, cov_pipe,
						exp_data->list[dt.seq].fill_date, cov_pipe,
						exp_data->list[dt.seq].days_supply, cov_pipe,
						exp_data->list[dt.seq].dea_nbr, cov_pipe,
						exp_data->list[dt.seq].denied_flg, cov_pipe,
						exp_data->list[dt.seq].generic_sts, cov_pipe,
						exp_data->list[dt.seq].Pharmacy_ID, cov_pipe,
						exp_data->list[dt.seq].pharmacy_nm, cov_pipe,
						exp_data->list[dt.seq].pharmacy_type_cd, cov_pipe,
						exp_data->list[dt.seq].prescribing_prov_id, cov_pipe,
						exp_data->list[dt.seq].rx_claim_alt_id_1, cov_pipe,
						exp_data->list[dt.seq].rx_claim_alt_id_2, cov_pipe,
						exp_data->list[dt.seq].rx_claim_alt_id_3, cov_pipe,
						exp_data->list[dt.seq].rx_claim_alt_id_4, cov_pipe,
						exp_data->list[dt.seq].requested_amt, cov_pipe,
						exp_data->list[dt.seq].supply_flag, cov_pipe,
						exp_data->list[dt.seq].cvx, cov_pipe,
						exp_data->list[dt.seq].Practice_TIN)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ENDIF
 
;CALL ECHORECORD (exp_data)
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
END
GO

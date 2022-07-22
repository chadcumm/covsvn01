/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		01/22/2020
	Solution:			Ambulatory
	Source file name:	cov_amb_pharmacy_rpt_export.prg
	Object name:		cov_amb_pharmacy_rpt_export
	Request #:
 
	Program purpose:	Export Pharmacy Information
 
	Executing from:		CCL
 
 	Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	 Developer				Comment
 	----------	 --------------------	---------------------------------------
 
******************************************************************************/
 
drop program cov_amb_pharmacy_rpt_export go
create program cov_amb_pharmacy_rpt_export
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Output To File" = 0
 
with OUTDEV, OUTPUT_FILE
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE cov_crlf 			= vc WITH constant(build(char(13),char(10)))
DECLARE cov_lf              = vc WITH constant(char(10))
DECLARE cov_pipe			= vc WITH constant(char(124))
DECLARE cov_tab				= vc WITH constant(char(9))
 
DECLARE file_var			= vc WITH noconstant("cov_amb_pharmacy_rpt_")
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
 
 
SET startdate = CNVTDATETIME(CURDATE-58,0)
SET enddate = CNVTDATETIME(CURDATE-28,235959)
 
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Ambulatory/PharmacyReport/"
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
	    2 Facility = VC
		2 Facility_Tax_ID = VC
		2 FIN = VC
		2 PatientName = VC
		2 Patient_DOB = VC
		2 Appt_Type = VC
		2 Enc_Type = VC
		2 Enc_Date_DOS = VC
		2 Encntr_id = F8
		2 Rendering_Provider = vc
		2 Enc_Diag_Code1 = VC
		2 Enc_Diag_Desc1 = VC
		2 Enc_Diag_Code2 = VC
		2 Enc_Diag_Desc2 = VC
		2 Enc_Diag_Code3 = VC
		2 Enc_Diag_Desc3 = VC
		2 Enc_Diag_Code4 = VC
		2 Enc_Diag_Desc4 = VC
		2 Enc_Diag_Code5 = VC
		2 Enc_Diag_Desc5 = VC
		2 Enc_Diag_Code6 = VC
		2 Enc_Diag_Desc6 = VC
		2 Enc_Diag_Code7 = VC
		2 Enc_Diag_Desc7 = VC
		2 Enc_Diag_Code8 = VC
		2 Enc_Diag_Desc8 = VC
		2 Enc_Diag_Code9 = VC
		2 Enc_Diag_Desc9 = VC
		2 Enc_Diag_Code10 = VC
		2 Enc_Diag_Desc10 = VC
		2 ordcnt = i4
		2 ordlist [*]
			3 Order_Provider = VC
			3 Order_Provider_NPI = VC
			3 Supervising_Provider = VC
			3 Supervising_Provider_NPI = VC
			3 Order_id = F8
			3 Order_Date = VC
			3 Order_CKI = VC
			3 Order_Communication_Type = VC
			3 Medication = VC
			3 Order_Status = VC
			3 Special_Instructions = VC
			3 Frequency = VC
			3 Volume_Dose = VC
			3 Volume_Dose_Unit = VC
			3 Drug_Form = VC
			3 Duration = VC
			3 Duration_Unit = VC
			3 Rate = VC
			3 Rate_Unit = VC
			3 RX_Route = VC
			3 Strength_Dose = VC
			3 Strength_Dose_Unit = VC
			3 Disp_Qty = VC
			3 Disp_Unit = VC
			3 Nbr_Refill = VC
			3 Total_Refill = VC
			3 Start_Date = VC
			3 Stop_Date = VC
			3 Prn_Instruction = VC
			3 Indication = VC
			3 Pharmacy_Route = VC
			3 Pharmacy_Name = VC
			3 eRX_Note = VC
			3 Diagnosis_Code1 = VC
			3 Diagnosis_Desc1 = VC
			3 Diagnosis_Code2 = VC
			3 Diagnosis_Desc2 = VC
			3 Diagnosis_Code3 = VC
			3 Diagnosis_Desc3 = VC
			3 Diagnosis_Code4 = VC
			3 Diagnosis_Desc4 = VC
			3 Diagnosis_Code5 = VC
			3 Diagnosis_Desc5 = VC
			3 Drug_Identifier = VC
			3 Parent_Category_Id = F8
			3 Parent_Category = VC
			3 Sub_Category_ID = F8
			3 Sub_Category = VC
			3 Sub_Sub_Category_ID = F8
			3 Sub_Sub_Category = VC
	)
 
CALL ECHO ("***** GETTING SCHEDULE DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Schedule Data
**************************************************************/
 
SELECT DISTINCT
	Facility = TRIM(org.org_name,3)
	,Facility_Tax_ID = TRIM(org.federal_tax_id_nbr,3)
	,FIN = TRIM(fin_nbr.alias,3)
	,PatientName = pat.name_full_formatted
	,Patient_DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1), "MM/DD/YYYY;;q")
	,Enc_Type = UAR_GET_CODE_DISPLAY(enc.encntr_type_cd)
	,Enc_Date_DOS = FORMAT(enc.reg_dt_tm, "MM/DD/YYYY hh:mm:ss;;q")
	,Encntr_id = enc.encntr_id
	,Appt_Type = UAR_GET_CODE_DISPLAY(se.appt_type_cd)
FROM SCH_APPT sch
	, (INNER JOIN SCH_EVENT se ON (sch.sch_event_id = se.sch_event_id			;;0001
		AND se.appt_type_cd IN (2893954647 /*Clayton Homes*/, 2553464245 /*DOT Self Pay*/, 2553464375 /*Industrial Medicine*/,
		2553464457 /*New Patient*/, 2553464477 /*Newborn*/, 2555201865 /*Office Visit*/, 3220694461 /*Online Self-Scheduling*/,
		2553464527 /*Physical*/, 2553464549 /*Procedure*/, 2553464569 /*Same Day*/, 2553464631 /*Walk In*/,
		2553464653 /*Work In*/, 2553464673 /*Worker's Compensation*/)
		))
	, (INNER JOIN ENCOUNTER enc ON (sch.encntr_id = enc.encntr_id
		AND enc.active_ind = 1
		AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
			2560523697/*Results Only*/,20058643/*Legacy Data*/)
		))
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
	, (INNER JOIN ORGANIZATION org ON (enc.organization_id = org.organization_id
		AND org.active_ind = 1
		AND org.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND org.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
	, (INNER JOIN ENCNTR_PRSNL_RELTN epr ON (enc.encntr_id = epr.encntr_id
		AND epr.priority_seq = 1
		AND epr.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
		AND epr.active_ind = 1
		AND epr.data_status_cd = 25.00 /* Auth Verified */   ;0003
		AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    	))
    , (INNER JOIN PRSNL rend_prov ON (epr.prsnl_person_id = rend_prov.person_id
   		AND rend_prov.active_ind = 1
   		AND rend_prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
   		AND rend_prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   		))
WHERE sch.sch_state_cd = 4537.00 /*'CHECKED OUT'*/
	AND sch.sch_role_cd = 4572.00 /*'PATIENT'*/
	AND (sch.beg_dt_tm >= CNVTDATETIME(startdate)
	AND sch.beg_dt_tm <= CNVTDATETIME(enddate))
	AND org.organization_id IN (3192077.00 /*Medical Associates of Carter*/,3192078.00 /*Mountain View Family Medicine*/,
    3192079.00 /*New Horizon Medical Associates*/,3192091.00 /*Hamblen Primary Care*/,3192037.00 /*Claiborne Medical Associates*/,
    3192051.00 /*Great Smokies Family Medicine*/,3829177.00 /*Mountain View Family Medicine - Pigeon Forge*/,
    3192037.00 /*Claiborne Medical Associates*/,3863285.00 /*Claiborne Primary Care	     3863285.00*/)

 
/****************************************************************************
	Populate Record structure with Schedule Data
*****************************************************************************/
HEAD REPORT enc.encntr_id
	cnt = 0
	CALL alterlist(exp_data->list, 10)
 
DETAIL
 
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
		exp_data->list[cnt].Facility = Facility
		exp_data->list[cnt].Facility_Tax_ID = Facility_Tax_ID
		exp_data->list[cnt].FIN = FIN
		exp_data->list[cnt].Encntr_id = Encntr_id
		exp_data->list[cnt].PatientName = PatientName
		exp_data->list[cnt].Patient_DOB = Patient_DOB
		exp_data->list[cnt].Enc_Type = Enc_Type
		exp_data->list[cnt].Enc_Date_DOS = Enc_Date_DOS
		exp_data->list[cnt].Rendering_Provider = rend_prov.name_full_formatted 
		exp_data->list[cnt].Appt_Type = Appt_Type
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHONE ENC DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Phone Enc Data
**************************************************************/
 
SELECT DISTINCT
	Facility = TRIM(org.org_name,3)
	,Facility_Tax_ID = TRIM(org.federal_tax_id_nbr,3)
	,FIN = TRIM(fin_nbr.alias,3)
	,PatientName = pat.name_full_formatted
	,Patient_DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1), "MM/DD/YYYY;;q")
	,Enc_Type = UAR_GET_CODE_DISPLAY(enc.encntr_type_cd)
	,Enc_Date_DOS = FORMAT(enc.reg_dt_tm, "MM/DD/YYYY hh:mm:ss;;q")
	,Encntr_id = enc.encntr_id
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
	, (INNER JOIN ORGANIZATION org ON (enc.organization_id = org.organization_id
		AND org.active_ind = 1
		AND org.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND org.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		))
WHERE enc.active_ind = 1
	AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.encntr_type_cd IN (2554389963/*Phone Message*/,
			2560523697/*Results Only*/,20058643/*Legacy Data*/)
	AND (enc.reg_dt_tm >= CNVTDATETIME(startdate)
	AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
	AND org.organization_id IN (3192077.00	/*Medical Associates of Carter*/,3192078.00 /*Mountain View Family Medicine*/,
    3192079.00 /*New Horizon Medical Associates*/,3192091.00 /*Hamblen Primary Care*/,3192037.00 /*Claiborne Medical Associates*/,
    3192051.00 /*Great Smokies Family Medicine*/,3829177.00 /*Mountain View Family Medicine - Pigeon Forge*/)
 
/****************************************************************************
	Populate Record structure with Phone Enc Data
*****************************************************************************/
HEAD REPORT enc.encntr_id
	cnt = exp_data->output_cnt
 
	IF(mod(cnt,10)> 0)
   		CALL alterlist(exp_data->list, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
 
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
		exp_data->list[cnt].Facility = Facility
		exp_data->list[cnt].Facility_Tax_ID = Facility_Tax_ID
		exp_data->list[cnt].FIN = FIN
		exp_data->list[cnt].Encntr_id = Encntr_id
		exp_data->list[cnt].PatientName = PatientName
		exp_data->list[cnt].Patient_DOB = Patient_DOB
		exp_data->list[cnt].Enc_Type = Enc_Type
		exp_data->list[cnt].Enc_Date_DOS = Enc_Date_DOS
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Data
**************************************************************/
 
SELECT DISTINCT
	Order_Provider = prov.name_full_formatted
	,Order_Provider_NPI = TRIM(npi.alias,3)
	,Supervising_Provider = prov_sup.name_full_formatted
	,Supervising_Provider_NPI = TRIM(npi_sup.alias,3)
	,Order_id = ord.order_id
	,Order_Date = FORMAT(ord.orig_order_dt_tm, "MM/DD/YYYY hh:mm:ss;;q")
	,ORDER_CKI = TRIM(SUBSTRING(FINDSTRING("!",ord.cki)+1,TEXTLEN(ord.cki),ord.cki),3)
	,Order_Communication_Type = UAR_GET_CODE_DISPLAY(ord_act.communication_type_cd)
	,Medication = TRIM(ord.ordered_as_mnemonic,3)
	,Order_Status = UAR_GET_CODE_DISPLAY(ord.order_status_cd)
	,Special_Instructions = ord.simplified_display_line
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,ORDERS ord
	,ORDER_CATALOG ord_cat
	,ORDER_ACTION ord_act
	,PRSNL prov
	,PRSNL_ALIAS npi
	,PRSNL prov_sup
	,PRSNL_ALIAS npi_sup
PLAN D
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].Encntr_id
		AND (ord.orig_order_dt_tm >= CNVTDATETIME(startdate)
		AND ord.orig_order_dt_tm <= CNVTDATETIME(enddate))
JOIN ord_cat WHERE ord.catalog_cd = ord_cat.catalog_cd
		AND ord_cat.active_ind = 1
		AND ord_cat.catalog_type_cd IN (2516.00 /*Pharmacy*/)
JOIN ord_act WHERE ord.order_id = ord_act.order_id
		AND ord_act.action_type_cd = 2534.00 /*Order*/
JOIN prov WHERE ord_act.order_provider_id = prov.person_id
   		AND prov.active_ind = 1
   		AND prov.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
   		AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
JOIN npi WHERE ord_act.order_provider_id = npi.person_id
		AND npi.active_ind = 1
		AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
JOIN prov_sup WHERE prov_sup.person_id = OUTERJOIN(ord_act.supervising_provider_id)
   		AND prov_sup.active_ind = OUTERJOIN(1)
   		AND prov_sup.beg_effective_dt_tm <= OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
   		AND prov_sup.end_effective_dt_tm > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
JOIN npi_sup WHERE npi_sup.person_id = OUTERJOIN(ord_act.supervising_provider_id)
		AND npi_sup.active_ind = OUTERJOIN(1)
		AND npi_sup.beg_effective_dt_tm <= OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
		AND npi_sup.end_effective_dt_tm > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
		AND npi_sup.prsnl_alias_type_cd = OUTERJOIN(4038127.00)  ;npi
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Data
*****************************************************************************/
HEAD ord.encntr_id
	cnt = 0
	idx = 0
	subcnt = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
	subcnt = subcnt + 1
 
	IF (mod(subcnt,10)>0)
		CALL ALTERLIST(exp_data->list[idx].ordlist, subcnt + (10-mod(subcnt,10)))
	ENDIF
 
FOOT ord.order_id
 
	IF (mod(subcnt,10)=1)
		CALL ALTERLIST(exp_data->list[idx].ordlist, subcnt + 9)
	ENDIF
 
	exp_data->list[idx].Ordlist[subcnt].Order_Provider = TRIM(Order_Provider,3)
	exp_data->list[idx].Ordlist[subcnt].Order_Provider_NPI = TRIM(Order_Provider_NPI,3)
	exp_data->list[idx].Ordlist[subcnt].Supervising_Provider = TRIM(Supervising_Provider,3)
	exp_data->list[idx].Ordlist[subcnt].Supervising_Provider_NPI = TRIM(Supervising_Provider_NPI,3)
	exp_data->list[idx].Ordlist[subcnt].Order_id = Order_id
	exp_data->list[idx].Ordlist[subcnt].Order_Date = Order_Date
	exp_data->list[idx].Ordlist[subcnt].Order_CKI = TRIM(Order_CKI,3)
	exp_data->list[idx].Ordlist[subcnt].Order_Communication_Type = TRIM(Order_Communication_Type,3)
	exp_data->list[idx].Ordlist[subcnt].Medication = TRIM(Medication,3)
	exp_data->list[idx].Ordlist[subcnt].Order_Status = TRIM(Order_Status,3)
	exp_data->list[idx].Ordlist[subcnt].Special_Instructions = TRIM(Special_Instructions,3)
 
FOOT ord.encntr_id
	exp_data->list[idx].ordcnt = subcnt
	CALL ALTERLIST(exp_data->list[idx].ordlist, subcnt)
 
	idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DETAIL DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Detail Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
 ord = MAX(od.oe_field_display_value) KEEP (DENSE_RANK last ORDER BY od.action_sequence ASC)
		OVER (PARTITION BY exp_data->list[d.seq].encntr_id, od.order_id, od.oe_field_id)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,orders ord
	,order_detail od
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].Encntr_id
JOIN od WHERE od.order_id = ord.order_id
    AND od.oe_field_id IN (12690 /*FREQ*/,12718 /*VOLUMEDOSE*/,12719 /*VOLUMEDOSEUNIT*/,12693 /*DRUGFORM*/,12721 /*DURATION*/,
    12723 /*DURATIONUNIT*/,12704 /*RATE*/,633585 /*RATEUNIT*/,12711 /*RXROUTE*/,12715 /*STRENGTHDOSE*/,12716 /*STRENGTHDOSEUNIT*/,
    12694 /*DISPQTY*/,633598 /*DISPUNIT*/,12628 /*NBRREFILL*/,634309 /*TOTALREFILL*/,12620 /*REQSTARTDTTM*/,12731 /*STOPDTTM*/,
	633597 /*PRNINSTRUCTIONS*/,12590 /*INDICATIONS*/,4056695 /*PHARMACYROUTE*/,4376093 /*PHARMACYNAME*/,19908153 /*ERXNOTE*/)
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Detail Data
*****************************************************************************/
 
HEAD od.order_id
 	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = LOCATEVAL(cnt,1,SIZE(exp_data->list[idx].ordlist,5), od.order_id, exp_data->list[idx].ordlist[subcnt].order_ID)
 
HEAD od.oe_field_id
	CASE (od.oe_field_id )
	     OF 12690 /*FREQ*/ :
			frequency = trim(ord,3)
	     OF 12718 /*VOLUMEDOSE*/ :
	     	volume_dose = trim(ord,3)
	     OF 12719 /*VOLUMEDOSEUNIT*/ :
	      	volume_dose_unit = trim(ord,3)
	     OF 12693 /*DRUGFORM*/ :
	      	drug_form = trim(ord,3)
	     OF 12721 /*DURATION*/ :
	      	duration = trim(ord,3)
	     OF 12723 /*DURATIONUNIT*/ :
	     	duration_unit = trim(ord,3)
	     OF 12704 /*RATE*/ :
	        rate = trim(ord,3)
	     OF 633585 /*RATEUNIT*/ :
	      	rate_unit = trim(ord,3)
	     OF 12711 /*RXROUTE*/ :
	     	rx_route = trim(ord,3)
	     OF 12715 /*STRENGTHDOSE*/ :
	      	strength_dose = trim(ord,3)
	     OF 12716 /*STRENGTHDOSEUNIT*/ :
	     	strength_dose_unit = trim(ord,3)
	     OF 12694 /*DISPQTY*/ :
     		disp_qty = trim(ord,3)
 	     OF 633598 /*DISPUNIT*/ :
     		disp_unit = trim(ord,3)
	     OF 12628 /*NBRREFILL*/ :
     		nbr_refill = trim(ord,3)
	     OF 634309 /*TOTALREFILL*/ :
     		total_refill = trim(ord,3)
	     OF 12620 /*REQSTARTDTTM*/ :
    		start_date = trim(ord,3)
    	 OF 12731 /*STOPDTTM*/ :
    	 	stop_date = trim(ord,3)
	     OF 633597 /*PRNINSTRUCTIONS*/ :
     		prn_instruction = trim(ord,3)
	     OF 12590 /*INDICATIONS*/ :
     		indication = trim(ord,3)
     	 OF 4056695 /*PHARMACYROUTE*/:
     	 	pharmacy_route = trim(ord,3)
	     OF 4376093 /*PHARMACYNAME*/ :
     		pharmacy_name = trim(ord,3)
     	 OF 19908153 /*ERXNOTE*/ :
     		eRx_note = trim(ord,3)
	ENDCASE
 
FOOT od.order_id
	WHILE(idx > 0)
		FOR (i = 1 to exp_data->list[idx].ordcnt)
			exp_data->list[idx].ordlist[subcnt].drug_form = TRIM(drug_form,3)
	 		exp_data->list[idx].ordlist[subcnt].duration = TRIM(duration,3)
			exp_data->list[idx].ordlist[subcnt].duration_unit = TRIM(duration_unit,3)
			exp_data->list[idx].ordlist[subcnt].rate = TRIM(rate,3)
		 	exp_data->list[idx].ordlist[subcnt].rate_unit = TRIM(rate_unit,3)
			exp_data->list[idx].ordlist[subcnt].frequency = TRIM(frequency,3)
			exp_data->list[idx].ordlist[subcnt].rx_route = TRIM(rx_route,3)
			exp_data->list[idx].ordlist[subcnt].strength_dose = TRIM(strength_dose,3)
			exp_data->list[idx].ordlist[subcnt].strength_dose_unit = TRIM(strength_dose_unit,3)
			exp_data->list[idx].ordlist[subcnt].volume_dose = TRIM(volume_dose,3)
			exp_data->list[idx].ordlist[subcnt].volume_dose_unit = TRIM(volume_dose_unit,3)
			exp_data->list[idx].ordlist[subcnt].disp_qty = TRIM(disp_qty,3)
			exp_data->list[idx].ordlist[subcnt].disp_unit = TRIM(disp_unit,3)
			exp_data->list[idx].ordlist[subcnt].nbr_refill = TRIM(nbr_refill,3)
			exp_data->list[idx].ordlist[subcnt].total_refill = TRIM(total_refill,3)
			exp_data->list[idx].ordlist[subcnt].start_date = TRIM(start_date,3)
			exp_data->list[idx].ordlist[subcnt].stop_date = TRIM(stop_date,3)
			exp_data->list[idx].ordlist[subcnt].prn_instruction = TRIM(prn_instruction,3)
			exp_data->list[idx].ordlist[subcnt].indication = TRIM(indication,3)
			exp_data->list[idx].ordlist[subcnt].pharmacy_route = TRIM(pharmacy_route,3)
			exp_data->list[idx].ordlist[subcnt].pharmacy_name = TRIM(pharmacy_name,3)
			exp_data->list[idx].ordlist[subcnt].eRx_Note = TRIM(eRx_Note,3)
			subcnt = LOCATEVAL(cnt,(subcnt+1),SIZE(exp_data->list[idx].ordlist,5), od.order_id,
						exp_data->list[idx].ordlist[cnt].order_ID)
		ENDFOR
		idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	ENDWHILE
WITH nocounter
 
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DIAGNOSIS 1 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Diagnosis 1 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Diagnosis_Code1 = TRIM(nom_diag1.source_identifier,3)
	,Diagnosis_Desc1 = TRIM(nom_diag1.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,ORDERS ord
	,NOMEN_ENTITY_RELTN ner1
	,NOMENCLATURE nom_diag1
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].encntr_id
JOIN ner1 WHERE ner1.encntr_id = ord.encntr_id
	AND ner1.parent_entity_id = ord.order_id
	AND ner1.active_ind = 1
	AND ner1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ner1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ner1.priority = 1
JOIN nom_diag1 WHERE nom_diag1.nomenclature_id = ner1.nomenclature_id
	AND nom_diag1.active_ind = 1
	AND nom_diag1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND nom_diag1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Diagnosis 1 Data
*****************************************************************************/
HEAD ord.encntr_id
	cnt = 0
	idx = 0
	subcnt = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
 
	subcnt = LOCATEVAL(cnt,1,SIZE(exp_data->list[idx].ordlist,5), ord.order_id, exp_data->list[idx].ordlist[cnt].order_ID)
 
FOOT ord.order_id
 	IF (subcnt != 0)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Code1 = TRIM(Diagnosis_Code1,3)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Desc1 = TRIM(Diagnosis_Desc1,3)
	ENDIF
 
FOOT ord.encntr_id
 
	idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DIAGNOSIS 2 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Diagnosis 2 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Diagnosis_Code2 = TRIM(nom_diag2.source_identifier,3)
	,Diagnosis_Desc2 = TRIM(nom_diag2.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,ORDERS ord
	,NOMEN_ENTITY_RELTN ner2
	,NOMENCLATURE nom_diag2
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].encntr_id
JOIN ner2 WHERE ner2.encntr_id = ord.encntr_id
	AND ner2.parent_entity_id = ord.order_id
	AND ner2.active_ind = 1
	AND ner2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ner2.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ner2.priority = 2
JOIN nom_diag2 WHERE nom_diag2.nomenclature_id = ner2.nomenclature_id
	AND nom_diag2.active_ind = 1
	AND nom_diag2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND nom_diag2.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Diagnosis 2 Data
*****************************************************************************/
 
HEAD ord.encntr_id
	cnt = 0
	idx = 0
	subcnt = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
 
	subcnt = LOCATEVAL(cnt,1,SIZE(exp_data->list[idx].ordlist,5), ord.order_id, exp_data->list[idx].ordlist[cnt].order_ID)
 
FOOT ord.order_id
 	IF (subcnt != 0)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Code2 = TRIM(Diagnosis_Code2,3)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Desc2 = TRIM(Diagnosis_Desc2,3)
	ENDIF
 
FOOT ord.encntr_id
 
	idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
 
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DIAGNOSIS 3 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Diagnosis 3 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Diagnosis_Code3 = TRIM(nom_diag3.source_identifier,3)
	,Diagnosis_Desc3 = TRIM(nom_diag3.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,ORDERS ord
	,NOMEN_ENTITY_RELTN ner3
	,NOMENCLATURE nom_diag3
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].encntr_id
JOIN ner3 WHERE ner3.encntr_id = ord.encntr_id
	AND ner3.parent_entity_id = ord.order_id
	AND ner3.active_ind = 1
	AND ner3.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ner3.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ner3.priority = 3
JOIN nom_diag3 WHERE nom_diag3.nomenclature_id = ner3.nomenclature_id
	AND nom_diag3.active_ind = 1
	AND nom_diag3.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND nom_diag3.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Diagnosis 3 Data
*****************************************************************************/
HEAD ord.encntr_id
	cnt = 0
	idx = 0
	subcnt = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
 
	subcnt = LOCATEVAL(cnt,1,SIZE(exp_data->list[idx].ordlist,5), ord.order_id, exp_data->list[idx].ordlist[cnt].order_ID)
 
FOOT ord.order_id
 	IF (subcnt != 0)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Code3 = TRIM(Diagnosis_Code3,3)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Desc3 = TRIM(Diagnosis_Desc3,3)
	ENDIF
 
FOOT ord.encntr_id
 
	idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DIAGNOSIS 4 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Diagnosis 4 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Diagnosis_Code4 = TRIM(nom_diag4.source_identifier,3)
	,Diagnosis_Desc4 = TRIM(nom_diag4.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,ORDERS ord
	,NOMEN_ENTITY_RELTN ner4
	,NOMENCLATURE nom_diag4
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].encntr_id
JOIN ner4 WHERE ner4.encntr_id = ord.encntr_id
	AND ner4.parent_entity_id = ord.order_id
	AND ner4.active_ind = 1
	AND ner4.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ner4.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ner4.priority = 4
JOIN nom_diag4 WHERE nom_diag4.nomenclature_id = ner4.nomenclature_id
	AND nom_diag4.active_ind = 1
	AND nom_diag4.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND nom_diag4.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Diagnosis 4 Data
*****************************************************************************/
 
HEAD ord.encntr_id
	cnt = 0
	idx = 0
	subcnt = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
 
	subcnt = LOCATEVAL(cnt,1,SIZE(exp_data->list[idx].ordlist,5), ord.order_id, exp_data->list[idx].ordlist[cnt].order_ID)
 
FOOT ord.order_id
 	IF (subcnt != 0)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Code4 = TRIM(Diagnosis_Code4,3)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Desc4 = TRIM(Diagnosis_Desc4,3)
	ENDIF
 
FOOT ord.encntr_id
 
	idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ORDER DIAGNOSIS 5 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Order Diagnosis 5 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Diagnosis_Code5 = TRIM(nom_diag5.source_identifier,3)
	,Diagnosis_Desc5 = TRIM(nom_diag5.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,ORDERS ord
	,NOMEN_ENTITY_RELTN ner5
	,NOMENCLATURE nom_diag5
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].encntr_id
JOIN ner5 WHERE ner5.encntr_id = ord.encntr_id
	AND ner5.parent_entity_id = ord.order_id
	AND ner5.active_ind = 1
	AND ner5.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ner5.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ner5.priority = 5
JOIN nom_diag5 WHERE nom_diag5.nomenclature_id = ner5.nomenclature_id
	AND nom_diag5.active_ind = 1
	AND nom_diag5.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND nom_diag5.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Order Diagnosis 5 Data
*****************************************************************************/
 
HEAD ord.encntr_id
	cnt = 0
	idx = 0
	subcnt = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
 
	subcnt = LOCATEVAL(cnt,1,SIZE(exp_data->list[idx].ordlist,5), ord.order_id, exp_data->list[idx].ordlist[cnt].order_ID)
 
FOOT ord.order_id
 	IF (subcnt != 0)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Code5 = TRIM(Diagnosis_Code5,3)
		exp_data->list[idx].ordlist[subcnt].Diagnosis_Desc5 = TRIM(Diagnosis_Desc5,3)
	ENDIF
 
FOOT ord.encntr_id
 
	idx = LOCATEVAL(cnt,(idx+1),SIZE(exp_data->list,5),ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 1 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 1 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code1 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc1 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	,NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 1
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 1 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code1 = TRIM(Enc_Diag_Code1,3)
		exp_data->list[idx].Enc_Diag_Desc1 = TRIM(Enc_Diag_Desc1,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 2 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 2 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code2 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc2 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 2
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 2 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code2 = TRIM(Enc_Diag_Code2,3)
		exp_data->list[idx].Enc_Diag_Desc2 = TRIM(Enc_Diag_Desc2,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 3 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 3 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code3 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc3 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 3
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 3 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code3 = TRIM(Enc_Diag_Code3,3)
		exp_data->list[idx].Enc_Diag_Desc3 = TRIM(Enc_Diag_Desc3,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 4 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 4 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code4 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc4 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 4
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 4 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code4 = TRIM(Enc_Diag_Code4,3)
		exp_data->list[idx].Enc_Diag_Desc4 = TRIM(Enc_Diag_Desc4,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 5 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 5 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code5 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc5 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 5
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 5 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code5 = TRIM(Enc_Diag_Code5,3)
		exp_data->list[idx].Enc_Diag_Desc5 = TRIM(Enc_Diag_Desc5,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 6 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 6 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code6 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc6 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 6
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 6 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code6 = TRIM(Enc_Diag_Code6,3)
		exp_data->list[idx].Enc_Diag_Desc6 = TRIM(Enc_Diag_Desc6,3)
	ENDIF
 
WITH nocounter
 
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 7 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 7 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code7 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc7 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 7
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 7 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code7 = TRIM(Enc_Diag_Code7,3)
		exp_data->list[idx].Enc_Diag_Desc7 = TRIM(Enc_Diag_Desc7,3)
	ENDIF
 
WITH nocounter
 
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 8 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 8 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code8 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc8 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 8
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 8 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code8 = TRIM(Enc_Diag_Code8,3)
		exp_data->list[idx].Enc_Diag_Desc8 = TRIM(Enc_Diag_Desc8,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 9 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 9 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code9 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc9 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 9
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 9 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code9 = TRIM(Enc_Diag_Code9,3)
		exp_data->list[idx].Enc_Diag_Desc9 = TRIM(Enc_Diag_Desc9,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY ENC DIAGNOSIS 10 DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
; Get Pharmacy Enc Diagnosis 10 Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Enc_Diag_Code10 = TRIM(nom_diag.source_identifier,3)
	,Enc_Diag_Desc10 = TRIM(nom_diag.source_string,3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,DIAGNOSIS diag
	, NOMENCLATURE nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = exp_data->list[d.seq].encntr_id
		AND diag.active_ind = 1
		AND diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND diag.clinical_diag_priority = 10
JOIN nom_diag WHERE nom_diag.nomenclature_id = diag.nomenclature_id
		AND nom_diag.active_ind = 1
		AND nom_diag.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND nom_diag.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
/****************************************************************************
	Populate Record structure with Pharmacy Enc Diagnosis 10 Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag.encntr_id, exp_data->list[cnt].encntr_id)
 
 	IF (idx != 0)
		exp_data->list[idx].Enc_Diag_Code10 = TRIM(Enc_Diag_Code10,3)
		exp_data->list[idx].Enc_Diag_Desc10 = TRIM(Enc_Diag_Desc10,3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
CALL ECHO ("***** GETTING PHARMACY DRUG CATEGORY DATA ******")
CALL ECHO (BUILD("***** Start Date: ",FORMAT(startdate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
CALL ECHO (BUILD("***** End Date: ",FORMAT(enddate, "MM/DD/YYYY HH:mm:ss;;q"), " *****"))
/**************************************************************
 Get Pharmacy Drug Category Data
**************************************************************/
 
SELECT DISTINCT INTO "NL:"
	Drug_Identifier = mcdx.drug_identifier
	,Parent_Category_Id = dc1.multum_category_id
	,Parent_Category = dc1.category_name
	,Sub_Category_ID = dc2.multum_category_id
	,Sub_Category = dc2.category_name
	,Sub_Sub_Category_ID = dc3.multum_category_id
	,Sub_Sub_Category = dc3.category_name
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,orders ord
	,mltm_category_drug_xref mcdx
	,mltm_drug_categories dc1
	,mltm_category_sub_xref dcs1
	,mltm_drug_categories dc2
	,mltm_category_sub_xref dcs2
	,mltm_drug_categories dc3
PLAN d
JOIN ord WHERE ord.encntr_id = exp_data->list[d.seq].encntr_id
	AND (ord.orig_order_dt_tm >= CNVTDATETIME(startdate)
		AND ord.orig_order_dt_tm <= CNVTDATETIME(enddate))
JOIN dc1 WHERE NOT(EXISTS((SELECT mcsx.multum_category_id FROM mltm_category_sub_xref mcsx
				WHERE mcsx.sub_category_id = dc1.multum_category_id)))
JOIN dcs1 WHERE dcs1.multum_category_id = dc1.multum_category_id
JOIN dc2 WHERE dc2.multum_category_id = dcs1.sub_category_id
JOIN dcs2 WHERE dcs2.multum_category_id = OUTERJOIN(dc2.multum_category_id)
JOIN dc3 WHERE dc3.multum_category_id = OUTERJOIN(dcs2.sub_category_id)
JOIN mcdx WHERE (mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id)
	AND mcdx.drug_identifier = TRIM(SUBSTRING(FINDSTRING("!",ord.cki)+1,TEXTLEN(ord.cki),ord.cki),3)
ORDER BY mcdx.drug_identifier
 
/****************************************************************************
	Populate Record structure with Pharmacy Drug Category Data
*****************************************************************************/
 
HEAD ord.encntr_id
 	cnt = 0
 	idx = 0
 	subcnt = 0
 	idx = LOCATEVAL(cnt, 1, SIZE(exp_data->list,5), ord.encntr_id, exp_data->list[cnt].encntr_id)
 
HEAD ord.order_id
 	subcnt = LOCATEVAL(cnt, 1, SIZE(exp_data->list[idx].ordlist,5), ord.order_id, exp_data->list[idx].ordlist[cnt].order_id)
 
FOOT ord.order_id
	IF (subcnt != 0)
		IF (dc1.multum_category_id != 0)
			exp_data->list[idx].ordlist[subcnt].Drug_Identifier = Drug_Identifier
			exp_data->list[idx].ordlist[subcnt].Parent_Category_Id = Parent_Category_Id
			exp_data->list[idx].ordlist[subcnt].Parent_Category = Parent_Category
		ENDIF
 
		IF (dc2.multum_category_id != 0)
			exp_data->list[idx].ordlist[subcnt].Sub_Category_ID = Sub_Category_ID
			exp_data->list[idx].ordlist[subcnt].Sub_Category = Sub_Category
		ENDIF
 
		IF (dc3.multum_category_id != 0)
			exp_data->list[idx].ordlist[subcnt].Sub_Sub_Category_ID = Sub_Sub_Category_ID
			exp_data->list[idx].ordlist[subcnt].Sub_Sub_Category = Sub_Sub_Category
		ENDIF
 	ENDIF
 
FOOT ord.encntr_id
	idx = LOCATEVAL(cnt, (idx+1), exp_data->output_cnt, ord.encntr_id, exp_data->list[cnt].encntr_id)
	subcnt = 0
 
WITH nocounter
 
 
CALL ECHO (BUILD("**Output_Cnt:",exp_data->output_cnt))
 
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
 
 
	HEAD REPORT
		output_rec = build("Facility", cov_pipe,
					"Facility_Tax_ID", cov_pipe,
					"FIN", cov_pipe,
					"PatientName", cov_pipe,
					"Patient_DOB", cov_pipe,
					"Appt_Type", cov_pipe,
					"Encntr_Id", cov_pipe,
					"Enc_Type", cov_pipe,
					"Rendering_Provider", cov_pipe,
					"Enc_Date_DOS", cov_pipe,
					"Enc_Diag_Code1", cov_pipe,
					"Enc_Diag_Desc1", cov_pipe,
					"Enc_Diag_Code2", cov_pipe,
					"Enc_Diag_Desc2", cov_pipe,
					"Enc_Diag_Code3", cov_pipe,
					"Enc_Diag_Desc3", cov_pipe,
					"Enc_Diag_Code4", cov_pipe,
					"Enc_Diag_Desc4", cov_pipe,
					"Enc_Diag_Code5", cov_pipe,
					"Enc_Diag_Desc5", cov_pipe,
					"Enc_Diag_Code6", cov_pipe,
					"Enc_Diag_Desc6", cov_pipe,
					"Enc_Diag_Code7", cov_pipe,
					"Enc_Diag_Desc7", cov_pipe,
					"Enc_Diag_Code8", cov_pipe,
					"Enc_Diag_Desc8", cov_pipe,
					"Enc_Diag_Code9", cov_pipe,
					"Enc_Diag_Desc9", cov_pipe,
					"Enc_Diag_Code10", cov_pipe,
					"Enc_Diag_Desc10", cov_pipe,
					"Order_Provider", cov_pipe,
					"Order_Provider_NPI", cov_pipe,
					"Supervising_Provider", cov_pipe,
					"Supervising_Provider_NPI", cov_pipe,
					"Order_id", cov_pipe,
					"Order_Date", cov_pipe,
					"Order_Communication_Type", cov_pipe,
					"Medication", cov_pipe,
					"Order_Status", cov_pipe,
					"Special_Instructions", cov_pipe,
					"Frequency", cov_pipe,
					"Volume_Dose", cov_pipe,
					"Volume_Dose_Unit", cov_pipe,
					"Drug_Form", cov_pipe,
					"Duration", cov_pipe,
					"Duration_Unit", cov_pipe,
					"Rate", cov_pipe,
					"Rate_Unit", cov_pipe,
					"RX_Route", cov_pipe,
					"Strength_Dose", cov_pipe,
					"Strength_Dose_Unit", cov_pipe,
					"Disp_Qty", cov_pipe,
					"Disp_Unit", cov_pipe,
					"Nbr_Refill", cov_pipe,
					"Total_Refill", cov_pipe,
					"Start_Date", cov_pipe,
					"Stop_Date", cov_pipe,
					"Prn_Instruction", cov_pipe,
					"Indication", cov_pipe,
					"Pharmacy_Route", cov_pipe,
					"Pharmacy_Name", cov_pipe,
					"eRX_Note", cov_pipe,
					"Diagnosis_Code1", cov_pipe,
					"Diagnosis_Desc1", cov_pipe,
					"Diagnosis_Code2", cov_pipe,
					"Diagnosis_Desc2", cov_pipe,
					"Diagnosis_Code3", cov_pipe,
					"Diagnosis_Desc3", cov_pipe,
					"Diagnosis_Code4", cov_pipe,
					"Diagnosis_Desc4", cov_pipe,
					"Diagnosis_Code5", cov_pipe,
					"Diagnosis_Desc5", cov_pipe,
					"Drug_Identifier", cov_pipe,
					"Parent_Category_Id", cov_pipe,
					"Parent_Category", cov_pipe,
					"Sub_Category_ID", cov_pipe,
					"Sub_Category", cov_pipe,
					"Sub_Sub_Category_ID", cov_pipe,
					"Sub_Sub_Category")
		col 0 output_rec
		row + 1
 
	head dt.seq
		IF (exp_data->list[dt.seq].ordcnt != 0)
 
			FOR (ww = 1 TO exp_data->list[dt.seq].ordcnt)
				output_rec = ""
				output_rec = build(output_rec,
						exp_data->list[dt.seq].Facility, cov_pipe,
						exp_data->list[dt.seq].Facility_Tax_ID, cov_pipe,
						exp_data->list[dt.seq].FIN, cov_pipe,
						exp_data->list[dt.seq].PatientName, cov_pipe,
						exp_data->list[dt.seq].Patient_DOB, cov_pipe,
						exp_data->list[dt.seq].Appt_Type, cov_pipe,
						exp_data->list[dt.seq].Encntr_id, cov_pipe,
						exp_data->list[dt.seq].Enc_Type, cov_pipe,
						exp_data->list[dt.seq].Rendering_Provider, cov_pipe,
						exp_data->list[dt.seq].Enc_Date_DOS, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code1, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc1, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code2, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc2, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code3, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc3, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code4, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc4, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code5, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc5, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code6, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc6, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code7, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc7, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code8, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc8, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code9, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc9, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code10, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc10, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Order_Provider, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Order_Provider_NPI, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Supervising_Provider, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Supervising_Provider_NPI, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Order_id, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Order_Date, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Order_Communication_Type, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Medication, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Order_Status, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Special_Instructions, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Frequency, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Volume_Dose, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Volume_Dose_Unit, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Drug_Form, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Duration, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Duration_Unit, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Rate, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Rate_Unit, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].RX_Route, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Strength_Dose, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Strength_Dose_Unit, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Disp_Qty, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Disp_Unit, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Nbr_Refill, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Total_Refill, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Start_Date, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Stop_Date, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Prn_Instruction, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Indication, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Pharmacy_Route, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Pharmacy_Name, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].eRX_Note, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Code1, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Desc1, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Code2, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Desc2, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Code3, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Desc3, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Code4, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Desc4, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Code5, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Diagnosis_Desc5, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Drug_Identifier, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Parent_Category_Id, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Parent_Category, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Sub_Category_ID, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Sub_Category, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Sub_Sub_Category_ID, cov_pipe,
						exp_data->list[dt.seq].ordlist[ww].Sub_Sub_Category, cov_crlf)
					output_rec = trim(output_rec,3)
					col 0 output_rec
					row + 1
				ENDFOR
			ELSE
				output_rec = ""
				output_rec = build(output_rec,
						exp_data->list[dt.seq].Facility, cov_pipe,
						exp_data->list[dt.seq].Facility_Tax_ID, cov_pipe,
						exp_data->list[dt.seq].FIN, cov_pipe,
						exp_data->list[dt.seq].PatientName, cov_pipe,
						exp_data->list[dt.seq].Patient_DOB, cov_pipe,
						exp_data->list[dt.seq].Appt_Type, cov_pipe,
						exp_data->list[dt.seq].Encntr_id, cov_pipe,
						exp_data->list[dt.seq].Enc_Type, cov_pipe,
						exp_data->list[dt.seq].Rendering_Provider, cov_pipe,
						exp_data->list[dt.seq].Enc_Date_DOS, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code1, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc1, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code2, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc2, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code3, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc3, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code4, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc4, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code5, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc5, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code6, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc6, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code7, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc7, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code8, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc8, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code9, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc9, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Code10, cov_pipe,
						exp_data->list[dt.seq].Enc_Diag_Desc10, cov_crlf)
				output_rec = trim(output_rec,3)
				col 0 output_rec
				row + 1
 			ENDIF
	FOOT dt.seq
		row + 0
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ENDIF
 
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("cp ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
 
END
GO
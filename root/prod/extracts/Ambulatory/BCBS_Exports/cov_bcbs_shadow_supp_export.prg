/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		7/8/2020
	Solution:			Ambulatory
	Source file name:	cov_bcbs_shadow_supp_export.prg
	Object name:		cov_bcbs_shadow_supp_export
	Request #:			7915
 
	Program purpose:	Export Colonoscopy/Breast/BMI data to send to
						BCBS for meeting measures.
 
	Executing from:		CCL
 
 	Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 Mod Date	    Developer				Comment
 --- -------	--------------------	---------------------------------------
 001 08/06/2020 Dawn Greer, DBA         Added code to remove the period from the
                                        diagnosis.
 002 08/26/2020 Dawn Greer, DBA         Fixed issue with Tax ID.  Changed the
                                        way the insurance is pulling.
 003 08/31/2020 Dawn Greer, DBA         Fixed the DOS_FROM/DOS_TO date formate
 004 09/03/2020 Dawn Greer, DBA         Changed the file name
                                        from covenant_bcbs_cerner_shadow_supp_export
                                        to cov_cerner_bcbs_shadow_supp_export
 005 01/06/2021 Dawn Greer, DBA         Setup to run monthly for the previous month                                        
******************************************************************************/
 
drop program cov_bcbs_shadow_supp_export go
create program cov_bcbs_shadow_supp_export
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	,"Output To File" = 1
 
WITH OUTDEV, output_file
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE crlf				= vc WITH constant(build(char(13),char(10)))
DECLARE cov_pipe			= vc WITH constant(char(124))
 
DECLARE file_var			= vc WITH noconstant("cov_cerner_bcbs_shadow_supp_export_")
DECLARE cur_date_var  		= vc WITH noconstant(build(YEAR(curdate),FORMAT(MONTH(curdate),"##;P0"),FORMAT(DAY(curdate),"##;P0")))
DECLARE filepath_var		= vc WITH noconstant("")
DECLARE temppath_var  		= vc WITH noconstant("cer_temp:")
DECLARE temppath2_var		= vc WITH noconstant("$cer_temp/")
DECLARE output_var			= vc WITH noconstant("")
DECLARE output_rec  		= vc WITH noconstant(" ")
 
DECLARE cmd					= vc WITH noconstant(" ")
DECLARE len					= i4 WITH noconstant(0)
DECLARE stat				= i4 WITH noconstant(0)
 
DECLARE startdate			= F8
DECLARE enddate				= F8
 
SET startdate = CNVTDATETIME(DATETIMEFIND(CNVTLOOKBEHIND("1,M"),"M","B","B"))  ;005 Previous Month Start
SET enddate = CNVTDATETIME(DATETIMEFIND(CNVTLOOKBEHIND("1,M"),"M","E","E"))  ;005 Previous Month End
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/BCBS/Shadow_Supp/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".csv"))
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
	    2 GROUP_NAME  = VC
	    2 GROUPER_ID  = VC
	    2 BP_TAX_ID = VC
	    2 BP_NPI_ID = VC
	    2 MBR_H = VC
	    2 MBR_LAST_NAME = VC
	    2 MBR_FIRST_NAME = VC
	    2 MBR_DOB = VC
	    2 MBR_GENDER = VC
	    2 MBR_HIC_NBR = VC
	    2 CHARGE_AMT = VC
	    2 PAID_AMT = VC
	    2 ALLOW_AMT = VC
	    2 TYPE_OF_BILL = VC
	    2 PLACE_OF_TREATMENT = VC
	    2 ENCOUNTER_ID = VC
	    2 DOS_FROM = VC
	    2 DOS_THRU = VC
	    2 ICD_PRIMARY_CODE = VC
	    2 DIAG_CNT = I4
	    2 DIAG_LIST[*]
	    	3 ICD_CODE1 = VC
	    	3 ICD_CODE2 = VC
		    3 ICD_CODE3 = VC
		    3 ICD_CODE4 = VC
		    3 ICD_CODE5 = VC
		    3 ICD_CODE6 = VC
		    3 ICD_CODE7 = VC
		    3 ICD_CODE8 = VC
		    3 ICD_CODE9 = VC
		    3 ICD_CODE10 = VC
		    3 ICD_CODE11 = VC
		    3 ICD_CODE12 = VC
		    3 ICD_CODE13 = VC
		    3 ICD_CODE14 = VC
		    3 ICD_CODE15 = VC
		    3 ICD_CODE16 = VC
		    3 ICD_CODE17 = VC
		    3 ICD_CODE18 = VC
		    3 ICD_CODE19 = VC
		    3 ICD_CODE20 = VC
		    3 ICD_CODE21 = VC
		    3 ICD_CODE22 = VC
		    3 ICD_CODE23 = VC
		    3 ICD_CODE24 = VC
	    2 CLAIM_TYPE = VC
	    2 HCPCS_CPT_CD = VC
	    2 CPT_MODIFIER_A = VC
	    2 CPT_MODIFIER_B = VC
	    2 REV_CODE = VC
	    2 PROV_NPI = VC
	    2 PROV_TAX_ID = VC
	    2 PROV_LAST_NAME = VC
	    2 PROV_FIRST_NAME = VC
	    2 FACILITY_NAME = VC
	    2 LOB_CD = VC
	    2 FIN_NBR = VC
	    2 ENCNTR_ID = F8
	)
 
CALL ECHO ("***** GETTING SHADOW SUPPLEMENTAL DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Shadow Supplemental
**************************************************************/
 
SELECT DISTINCT GROUP_NAME = 'CMG_COVENANT'
	    ,GROUPER_ID = " "
	    ,BP_TAX_ID = EVALUATE2(IF (SIZE(TRIM(REPLACE(bep.tax_id_nbr_txt,'-',''),3)) = 0) " "		;002
	    	ELSE TRIM(REPLACE(bep.tax_id_nbr_txt,'-',''),3) ENDIF)									;002
	    ,BP_NPI_ID = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	    ,MBR_H = EVALUATE2(IF (SIZE(TRIM(ins.MEMBER_NBR,3)) = 0.00) " " ELSE TRIM(CNVTUPPER(ins.MEMBER_NBR),3) ENDIF)
	    ,MBR_LAST_NAME = EVALUATE2(IF (SIZE(pat.name_last_key) = 0) " " ELSE TRIM(REPLACE(pat.name_last_key,',',''),3) ENDIF)
	    ,MBR_FIRST_NAME = EVALUATE2(IF (SIZE(pat.name_first_key) = 0) " " ELSE TRIM(REPLACE(pat.name_first_key,',',''),3) ENDIF)
	    ,MBR_DOB =  EVALUATE2(IF (TRIM(CNVTSTRING(pat.birth_dt_tm),3) IN ("0","31558644000")) " "
				ELSE FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1), "MM/DD/YYYY;;q") ENDIF)
	    ,MBR_GENDER = EVALUATE(pat.sex_cd, 362.00, "F", 363.00, "M", 364.00, "U", 0.00, "U")
	    ,MBR_HIC_NBR = " "
	    ,CHARGE_AMT = " "
	    ,PAID_AMT = " "
	    ,ALLOW_AMT = " "
	    ,TYPE_OF_BILL = " "
	    ,PLACE_OF_TREATMENT = '11'
	    ,ENCOUNTER_ID = EVALUATE2(IF (SIZE(finnbr.alias) = 0) " " ELSE finnbr.alias ENDIF)
	    ,DOS_FROM = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
			ELSE FORMAT(enc.reg_dt_tm, "MM/DD/YYYY;;q") ENDIF)	;003
	    ,DOS_THRU = EVALUATE2(IF (TRIM(CNVTSTRING(enc.reg_dt_tm),3) IN ("0","31558644000")) " "
			ELSE FORMAT(enc.reg_dt_tm, "MM/DD/YYYY;;q") ENDIF)	;003
	    ,CLAIM_TYPE = 'P'
		,HCPCS_CPT_CD = EVALUATE2(IF (SIZE(TRIM(cm.field6,3)) = 0) " " ELSE SUBSTRING(1,5,TRIM(cm.field6,3)) ENDIF)
		,CPT_MODIFIER_A = EVALUATE2(IF (SIZE(TRIM(cmmod.field6,3)) = 0) " " ELSE SUBSTRING(1,5,TRIM(cmmod.field6,3)) ENDIF)
	    ,CPT_MODIFIER_B = " "
	    ,REV_CODE = " "
	    ,PROV_NPI = EVALUATE2(IF (SIZE(npi.alias) = 0) " " ELSE TRIM(npi.alias,3) ENDIF)
	    ,PROV_TAX_ID = EVALUATE2(IF (SIZE(bep.tax_id_nbr_txt) = 0) " " ELSE TRIM(REPLACE(bep.tax_id_nbr_txt,'-',''),3) ENDIF);002
	    ,PROV_LAST_NAME = EVALUATE2(IF (SIZE(prov.name_last_key) = 0) " " ELSE TRIM(REPLACE(prov.name_last_key,',',''),3) ENDIF)
	    ,PROV_FIRST_NAME = EVALUATE2(IF (SIZE(prov.name_first_key) = 0) " " ELSE TRIM(REPLACE(prov.name_first_key,',',''),3) ENDIF)
	    ,FACILITY_NAME = EVALUATE2(IF (org.organization_id = 0.00) " " ELSE TRIM(org.org_name,3) ENDIF)
	    ,LOB_CD = 'MER'
	    ,FIN_NBR = EVALUATE2(IF (SIZE(finnbr.alias) = 0) " " ELSE finnbr.alias ENDIF)
	    ,ENCNTR_ID = enc.encntr_id
FROM ENCOUNTER enc
	, (INNER JOIN ENCNTR_ALIAS finnbr ON (enc.encntr_id = finnbr.encntr_id
			AND finnbr.active_ind = 1
			AND finnbr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND finnbr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		AND finnbr.encntr_alias_type_cd = 1077   ;FIN
    		))
	, (INNER JOIN DIAGNOSIS diag ON (enc.encntr_id = diag.encntr_id
			AND diag.active_ind = 1
			))
	, (INNER JOIN PERSON pat ON (enc.person_id = pat.person_id
			AND pat.active_ind = 1
			AND pat.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND pat.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND pat.name_last_key NOT IN ("TTTT*","FFFF*","ZZZ*")
			))
	, (INNER JOIN (SELECT enc_ins.encntr_id, enc_ins.member_nbr, hp_ins.plan_name,			;002
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
			AND epr.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
			AND epr.active_ind = 1
			AND epr.data_status_cd = 25.00 /* Auth Verified */
			AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    		))
	, (INNER JOIN PRSNL_ALIAS npi ON (epr.prsnl_person_id = npi.person_id
			AND npi.active_ind = 1
			AND npi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			AND npi.prsnl_alias_type_cd = 4038127.00  ;npi
			))
	, (INNER JOIN PRSNL prov ON (npi.person_id = prov.person_id
			))
	, (INNER JOIN BR_ELIGIBLE_PROVIDER bep ON (prov.person_id = bep.provider_id			;002
			))
	, (INNER JOIN ORGANIZATION org ON (enc.organization_id = org.organization_id
			AND org.active_ind = 1
			AND org.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
			AND org.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
			))
	, (INNER JOIN CHARGE_EVENT chgeve ON (chgeve.encntr_id = enc.encntr_id
			AND chgeve.active_ind = 1
			))
	, (INNER JOIN CHARGE c ON (c.charge_event_id = chgeve.charge_event_id
			AND c.active_ind = 1
			AND c.activity_type_cd = 636674.00 /*Evaluation and Managemente*/
			))
	, (INNER JOIN CHARGE_MOD cm ON (cm.charge_item_id = c.charge_item_id
			AND cm.field1_id IN (615214.00 /*CPT4*/, 3692.00 /*CPT4 MOD*/, 2555056221.00/*CPT4 MOD*/)
			AND NOT cm.FIELD6 = NULL
			AND cm.ACTIVE_IND = 1
			AND NULLVAL(cm.charge_mod_source_cd,0) IN (0.00, 3319225965.00 /*REFERENCE DATA*/)
			AND cm.field3_id = 0.00
			AND cm.field6 NOT IN ('9','76700','81002','82075','93000','93010','93227','93306',
			'93307','93308','93320','93325','93880','93923','93925','93926','93970','93971','94010',
			'99999','ABICHS','AHACPR','APUA','ARTBLCHS','ARTULCHS','AS','ATRAY','AUCHS','Balfwd','Botx1',
			'Botx2','Botx3','Bp','BREATH','BTX11','Btx12','Btx13','CARCHS','CareC','CCMV','CLFFSR','COLL',
			'COPAY','CPAP NC','Ctray','Cvscath','CWRPC','Deposit','DEVRE','DiabC','DOPFSR','DOT','E2DFSR',
			'ECHCCH','ECHCHS','ECHFCS','ECHFSR','ECHIMW','ECHODC','ECHSC','ECHSMG','EKGFSR','EKGODC',
			'EKGTOC','EKGTUTOR','EMEKG','EMXRAY','Error','EVRFSR','EXCISION','ExTrn','FCSPT','FMLA',
			'GAC','GENC','Gyn','HA','HCG','HOLCCH','HOLCHS','HOLFSR','HT2','HTA2','HTTR1','HYMNP','I001',
			'I001A','I002','I005','I300','I303','I500','I501','I502','I503','I599','I6005','I6602','I6603',
			'I6604','I6605','I6606','I71010','I72100','I900','I901','I903','I904','I90632','I90636','I90658',
			'I90716','I90746','I9250','I9251','I9252','I9253','I9254','I9255','I92551','I93000','I94010',
			'I991','I99999','IDC O','INCTO','INDIG','INSFM','InTrn','INVBL','IRXSF','ITRAY','IWCDS','J3301BRM10',
			'J3301BRM40','J7325BRM16','LAB','LABPL','LATI9','LazFU','Lazin','Laznc','Lazsp','Lazst','Laztx',
			'LBIAP','Left','LIPOB','LIPOC','LIPOD','LMTFSR','LVR','MCADD','MECHFSR','MEGAB','MPSCCH','MPSSMG',
			'MR','MRCLP','MROFEE','MRX','MUGCCH','NARRA','NCADM','NCCE','NCLAB','NGYN','NOB','NOSHO','NP',
			'Nurse','O502F','OCC90688','OCMDED','OV','OVTM','OVUNDOC','P001O','P002','P002A','P003','P003v',
			'P004','P00425','P005F','P006A','P1012','P102','P104','P104G','P105','P106','P201','P201D',
			'P301','P302','P303','P401','P401FF','P403','P504OB','P900','P900PT','P900UD','P902','P902RC','P904',
			'P932','P935','P941','P942','PA003AM','PA003B','PA003C','PA003E','PA003I','PC','PE150','PE175',
			'PE200','PE225','PE250','PE275','PE300','PE325','PE350','PE75','PI','Po','Pp','PPBP','PPWOU','PREOP',
			'PTRVLCON','Q2038SAN','RC','REFLAB','RESEARCH','ROB','RVU-1','RVU-II','RVU-IR','RX','SSV','Staple',
			'T005E','T005EC','Tb','TMCCH','TMSMG','ULTRAB','VAGPL','VASER','VENBLCHS','VENULCHS','WtCK','XXXXX')
			))
	, (LEFT JOIN CHARGE_MOD cmmod ON (cmmod.charge_item_id = c.charge_item_id		;002
			AND cmmod.field1_id IN (615214.00 /*CPT4*/, 3692.00 /*CPT4 MOD*/, 2555056221.00/*CPT4 MOD*/)
			AND NOT cmmod.FIELD6 = NULL
			AND cmmod.ACTIVE_IND = 1
			AND cm.charge_item_id = cmmod.charge_item_id
			AND cmmod.field3_id != 0.00
			))
WHERE diag.diagnosis_id != 0.00
AND enc.active_ind = 1
AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,2560523697/*Results Only*/,20058643/*Legacy Data*/)
AND (enc.reg_dt_tm >= CNVTDATETIME(startdate)
AND enc.reg_dt_tm <= CNVTDATETIME(enddate))
 
/****************************************************************************
	Populate Record structure with Shadow Supplemental
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(exp_data->list, 100)
 
DETAIL
	cnt = cnt + 1
 
 	IF(mod(cnt,10) = 1 AND cnt > 10)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
	exp_data->list[cnt].GROUP_NAME = GROUP_NAME
	exp_data->list[cnt].GROUPER_ID = GROUPER_ID
	exp_data->list[cnt].BP_TAX_ID = BP_TAX_ID
	exp_data->list[cnt].BP_NPI_ID = BP_NPI_ID
	exp_data->list[cnt].MBR_H = MBR_H
	exp_data->list[cnt].MBR_LAST_NAME = MBR_LAST_NAME
	exp_data->list[cnt].MBR_FIRST_NAME = MBR_FIRST_NAME
	exp_data->list[cnt].MBR_DOB = MBR_DOB
	exp_data->list[cnt].MBR_GENDER = MBR_GENDER
	exp_data->list[cnt].MBR_HIC_NBR = MBR_HIC_NBR
	exp_data->list[cnt].CHARGE_AMT = CHARGE_AMT
	exp_data->list[cnt].PAID_AMT = PAID_AMT
	exp_data->list[cnt].ALLOW_AMT = ALLOW_AMT
	exp_data->list[cnt].TYPE_OF_BILL = TYPE_OF_BILL
	exp_data->list[cnt].PLACE_OF_TREATMENT = PLACE_OF_TREATMENT
	exp_data->list[cnt].ENCOUNTER_ID = ENCOUNTER_ID
	exp_data->list[cnt].DOS_FROM = DOS_FROM
	exp_data->list[cnt].DOS_THRU = DOS_THRU
	exp_data->list[cnt].CLAIM_TYPE = CLAIM_TYPE
	exp_data->list[cnt].HCPCS_CPT_CD = HCPCS_CPT_CD
	exp_data->list[cnt].CPT_MODIFIER_A = CPT_MODIFIER_A
	exp_data->list[cnt].CPT_MODIFIER_B = CPT_MODIFIER_B
	exp_data->list[cnt].REV_CODE = REV_CODE
	exp_data->list[cnt].PROV_NPI = PROV_NPI
	exp_data->list[cnt].PROV_TAX_ID = PROV_TAX_ID
	exp_data->list[cnt].PROV_LAST_NAME = PROV_LAST_NAME
	exp_data->list[cnt].PROV_FIRST_NAME = PROV_FIRST_NAME
	exp_data->list[cnt].FACILITY_NAME = FACILITY_NAME
	exp_data->list[cnt].LOB_CD = LOB_CD
	exp_data->list[cnt].FIN_NBR = FIN_NBR
	exp_data->list[cnt].ENCNTR_ID = ENCNTR_ID
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 1 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 1
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 1)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 1
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
 	CALL alterlist(exp_data->list[idx].diag_list, subcnt + 9)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].ICD_PRIMARY_CODE = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
	exp_data->list[idx].diag_list[subcnt].ICD_CODE1 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 2 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 2
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 2)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 2
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE2 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 3 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 3
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 3)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 3
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE3 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 4 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 4
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 4)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 4
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE4 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 5 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 5
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 5)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 5
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE5 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 6 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 6
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 6)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 6
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE6 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 7 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 7
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 7)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 7
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE7 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 8 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 8
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 8)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 8
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE8 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 9 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 9
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 9)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 9
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE9 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 10 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 10
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 10)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 10
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE10 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 11 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 11
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 11)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 1
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE11 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 12 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 12
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 12)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 12
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE12 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 13 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 13
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 13)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 13
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE13 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 14 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 14
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 14)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 14
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE14 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 15 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 15
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 15)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 15
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE15 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 16 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 16
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 16)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 16
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE16 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 17 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 17
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 17)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 17
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE17 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 18 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 18
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 18)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 18
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE18 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 19 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 19
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 19)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 19
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE19 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 20 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 2
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 20)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 20
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE20 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 21 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 21
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 21)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 21
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE21 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 22 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 22
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 22)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 22
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE22 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 23 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 23
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 23)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 23
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE23 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 24 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 24
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 24)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 24
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 1
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE24 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 25 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 25
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 25)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 25
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
	CALL alterlist(exp_data->list[idx].diag_list, subcnt + 9)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE1 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 26 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 26
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 26)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 26
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE2 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 27 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 27
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 27)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 27
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE3 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 28 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 26
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 28)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 28
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE4 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 29 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 29
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 29)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 29
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE5 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 30 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 30
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 30)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 30
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE6 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 31 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 31
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 31)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 31
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE7 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 32 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 32
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 32)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 32
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE8 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 33 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 33
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 33)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 33
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE9 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 34 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 34
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 34)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 34
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE10 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 35 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 35
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 35)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 35
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE11 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 36 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 36
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 36)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 36
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE12 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 37 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 37
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 37)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 37
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE13 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 38 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 38
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 38)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 38
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE14 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 39 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 39
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 39)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 39
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE15 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 40 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 40
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 40)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 40
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE16 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 41 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 41
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 41)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 41
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE17 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 42 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 42
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 42)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 42
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE18 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
CALL ECHO ("***** GETTING DIAGNOSIS 43 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 43
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 43)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 43
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE19 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 44 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 44
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 44)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 44
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE20 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 45 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 45
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 45)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 45
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE21 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 46 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 46
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 46)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 46
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE22 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 47 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 47
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 47)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 47
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE23 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
 
CALL ECHO ("***** GETTING DIAGNOSIS 48 DATA ******")
CALL ECHO(BUILD("Current Date/Time", CHAR(9), FORMAT(SYSDATE, "MM/DD/YYYY HH:mm:ss;;q")))
/**************************************************************
; Get Diagnosis Data 48
**************************************************************/
SELECT INTO "NL:"  diag_list1.encntr_id, diag_list1.diag_code, diag_list1.row_num
	FROM (dummyt d WITH seq = value(size(exp_data->list ,5)))
	,((SELECT encntr_id = diag1.encntr_id,
	    diag_code = nom1.source_identifier,
	    row_num = ROW_NUMBER () OVER(PARTITION BY diag1.encntr_id ORDER BY diag1.encntr_id,
	    	EVALUATE2 (IF (diag1.clinical_diag_priority = 0) (diag1.clinical_diag_priority + 99)
	     		ELSE diag1.clinical_diag_priority ENDIF))
	    FROM diagnosis diag1
	     ,(INNER JOIN nomenclature nom1 ON (nom1.nomenclature_id = diag1.nomenclature_id
	     		AND nom1.active_ind = 1
	     		AND nom1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	    		AND nom1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	    	))
	    WHERE diag1.active_ind = 1
	    WITH SQLTYPE(DATATYPE(encntr_id, "F8")
	    	,DATATYPE(diag_code,"vc")
	    	,DATATYPE(row_num, "i4"))
		)diag_list1)
PLAN d
JOIN (diag_list1
WHERE (diag_list1.encntr_id = exp_data->list[d.seq ].encntr_id)
AND diag_list1.row_num = 48)
 
/****************************************************************************
	Populate Record structure with Diagnosis Data 48
*****************************************************************************/
HEAD diag_list1.encntr_id
	cnt = 0
	idx = 0
	subcnt = 2
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),diag_list1.encntr_id, exp_data->list[cnt].encntr_id)
 
FOOT diag_list1.encntr_id
	exp_data->list[idx].diag_list[subcnt].ICD_CODE24 = TRIM(REPLACE(diag_list1.diag_code,'.',''),3)		;001
 
	exp_data->list[idx].DIAG_CNT = subcnt
	CALL ALTERLIST(exp_data->list[idx].diag_list, subcnt)
 
WITH nocounter
 
/****************************************************************************
	Build Output
*****************************************************************************/
IF (exp_data->output_cnt > 0)
 	CALL ECHO ("******* Build Output *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("GROUP_NAME", cov_pipe,
				"GROUPER_ID", cov_pipe,
				"BP_TAX_ID", cov_pipe,
				"BP_NPI_ID", cov_pipe,
				"MBR_H", cov_pipe,
				"MBR_LAST_NAME", cov_pipe,
				"MBR_FIRST_NAME", cov_pipe,
				"MBR_DOB", cov_pipe,
				"MBR_GENDER", cov_pipe,
				"MBR_HIC_NBR", cov_pipe,
				"CHARGE_AMT", cov_pipe,
				"PAID_AMT", cov_pipe,
				"ALLOW_AMT", cov_pipe,
				"TYPE_OF_BILL", cov_pipe,
				"PLACE_OF_TREATMENT", cov_pipe,
				"ENCOUNTER_ID", cov_pipe,
				"DOS_FROM", cov_pipe,
				"DOS_THRU", cov_pipe,
				"ICD_PRIMARY_CODE", cov_pipe,
				"ICD_CODE1", cov_pipe,
				"ICD_CODE2", cov_pipe,
				"ICD_CODE3", cov_pipe,
				"ICD_CODE4", cov_pipe,
				"ICD_CODE5", cov_pipe,
				"ICD_CODE6", cov_pipe,
				"ICD_CODE7", cov_pipe,
				"ICD_CODE8", cov_pipe,
				"ICD_CODE9", cov_pipe,
				"ICD_CODE10", cov_pipe,
				"ICD_CODE11", cov_pipe,
				"ICD_CODE12", cov_pipe,
				"ICD_CODE13", cov_pipe,
				"ICD_CODE14", cov_pipe,
				"ICD_CODE15", cov_pipe,
				"ICD_CODE16", cov_pipe,
				"ICD_CODE17", cov_pipe,
				"ICD_CODE18", cov_pipe,
				"ICD_CODE19", cov_pipe,
				"ICD_CODE20", cov_pipe,
				"ICD_CODE21", cov_pipe,
				"ICD_CODE22", cov_pipe,
				"ICD_CODE23", cov_pipe,
				"ICD_CODE24", cov_pipe,
				"CLAIM_TYPE", cov_pipe,
				"HCPCS_CPT_CD", cov_pipe,
				"CPT_MODIFIER_A", cov_pipe,
				"CPT_MODIFIER_B", cov_pipe,
				"REV_CODE", cov_pipe,
				"PROV_NPI", cov_pipe,
				"PROV_TAX_ID", cov_pipe,
				"PROV_LAST_NAME", cov_pipe,
				"PROV_FIRST_NAME", cov_pipe,
				"FACILITY_NAME", cov_pipe,
				"LOB_CD", cov_pipe,
				"FIN_NBR")
		col 0 output_rec
		row + 1
 
 
	HEAD dt.seq
 
		IF (exp_data->list[dt.seq].diag_cnt != 0)
			FOR (ww = 1 TO exp_data->list[dt.seq].diag_cnt)
 
				output_rec = ""
				output_rec = build(output_rec,
					exp_data->list[dt.seq].GROUP_NAME, cov_pipe,
					exp_data->list[dt.seq].GROUPER_ID, cov_pipe,
					exp_data->list[dt.seq].BP_TAX_ID, cov_pipe,
					exp_data->list[dt.seq].BP_NPI_ID, cov_pipe,
					exp_data->list[dt.seq].MBR_H, cov_pipe,
					exp_data->list[dt.seq].MBR_LAST_NAME, cov_pipe,
					exp_data->list[dt.seq].MBR_FIRST_NAME, cov_pipe,
					exp_data->list[dt.seq].MBR_DOB, cov_pipe,
					exp_data->list[dt.seq].MBR_GENDER, cov_pipe,
					exp_data->list[dt.seq].MBR_HIC_NBR, cov_pipe,
					exp_data->list[dt.seq].CHARGE_AMT, cov_pipe,
					exp_data->list[dt.seq].PAID_AMT, cov_pipe,
					exp_data->list[dt.seq].ALLOW_AMT, cov_pipe,
					exp_data->list[dt.seq].TYPE_OF_BILL, cov_pipe,
					exp_data->list[dt.seq].PLACE_OF_TREATMENT, cov_pipe,
					exp_data->list[dt.seq].ENCOUNTER_ID, cov_pipe,
					exp_data->list[dt.seq].DOS_FROM, cov_pipe,
					exp_data->list[dt.seq].DOS_THRU, cov_pipe,
					exp_data->list[dt.seq].ICD_PRIMARY_CODE, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code1, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code2, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code3, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code4, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code5, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code6, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code7, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code8, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code9, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code10, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code11, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code12, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code13, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code14, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code15, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code16, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code17, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code18, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code19, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code20, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code21, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code22, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code23, cov_pipe,
					exp_data->list[dt.seq].diag_list[ww].ICD_Code24, cov_pipe,
					exp_data->list[dt.seq].CLAIM_TYPE, cov_pipe,
					exp_data->list[dt.seq].HCPCS_CPT_CD, cov_pipe,
					exp_data->list[dt.seq].CPT_MODIFIER_A, cov_pipe,
					exp_data->list[dt.seq].CPT_MODIFIER_B, cov_pipe,
					exp_data->list[dt.seq].REV_CODE, cov_pipe,
					exp_data->list[dt.seq].PROV_NPI, cov_pipe,
					exp_data->list[dt.seq].PROV_TAX_ID, cov_pipe,
					exp_data->list[dt.seq].PROV_LAST_NAME, cov_pipe,
					exp_data->list[dt.seq].PROV_FIRST_NAME, cov_pipe,
					exp_data->list[dt.seq].FACILITY_NAME, cov_pipe,
					exp_data->list[dt.seq].LOB_CD,cov_pipe,
					exp_data->list[dt.seq].FIN_NBR)
 
				output_rec = trim(output_rec,3)
				col 0 output_rec
				IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
			ENDFOR
		ENDIF
 
	WITH nocounter, maxcol = 32000, format=stream, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
CALL ECHORECORD (exp_data)
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("cp ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
FREE RECORD exp_data
END
GO
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		08/19/2021
	Solution:			Radiology
	Source file name:	cov_aspen_lung_patient_export.prg
	Object name:		cov_aspen_lung_patient_export
	Request #:			10765
 
	Program purpose:	Export patients for Aspen Lung Go Live
 
	Executing from:		CCL
 
 	Special Notes:
	Execute Example:
 
***********************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***********************************************************************************************
 
 Mod   Date	          Developer				 Comment
 ----  ----------	  --------------------	 --------------------------------------------------
 0001  08/19/2021     Dawn Greer, DBA        Original Release
 0002  08/30/2021     Dawn Greer, DBA        Add Accession number for the orders.
***********************************************************************************************/
 
drop program cov_aspen_lung_patient_export go
create program cov_aspen_lung_patient_export
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Output To File" = 1
 
with OUTDEV, OUTPUT_FILE
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE cov_crlf 			= vc WITH constant(build(char(13),char(10)))
DECLARE cov_lf              = vc WITH constant(char(10))
DECLARE cov_pipe			= vc WITH constant(char(124))
DECLARE cov_quote			= vc WITH constant(char(34))
 
DECLARE file_var			= vc WITH noconstant("cov_aspen_lung_patient_extract_")
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
 
SET startdate = CNVTDATETIME(CURDATE-100,0)
SET enddate = CNVTDATETIME(CURDATE-1,235959)
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/AspenLungExtract/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
RECORD exp_data (
	1 output_cnt = i4
	1 list[*]
	    2 Patient = VC
	    2 Patient_Last = VC
	    2 Patient_First = VC
	    2 Patient_Middle = VC
	    2 DOB = VC
	    2 SSN = VC
	    2 Refused_SSN = VC
	    2 CMRN = VC
	    2 Person_id = VC
 		2 Address_1 = VC
	    2 Address_2 = VC
	    2 City = VC
	    2 State = VC
	    2 Zip = VC
	    2 Country = VC
	    2 Email = VC
	    2 Home_Phone = VC
	    2 Mobile_Phone = VC
	    2 Work_Phone = VC
	    2 Gender = VC
	    2 Ethnicity = VC
	    2 Is_Hispanic = VC
	    2 CLMC_MRN = VC
	    2 CMC_MRN = VC
	    2 FLMC_MRN = VC
	    2 FSR_MRN = VC
	    2 LCMC_MRN = VC
	    2 MHHS_MRN = VC
	    2 MMC_MRN = VC
	    2 PBH_MRN = VC
	    2 PW_MRN = VC
	    2 RMC_MRN = VC
	    2 TOG_MRN = VC
	    2 Enc_Date = VC
	    2 Enc_Type = VC
	   	2 FIN = VC
	   	2 Encntr_id = VC
	    2 Facility = VC
	    2 Facility_NPI = VC
		2 Facility_Code = VC
	    2 Org_Facility = VC
	    2 Order_id = VC
	    2 Accession = VC	;0002
	    2 Order_Mnemonic = VC
	    2 Current_Start_Date= VC
	    2 Order_Date = VC
	    2 Order_Status = VC
	    2 Order_Encntr_id = VC
	    2 Order_Originating_Encntr_Id = VC
	    2 Order_Provider = VC
	    2 Order_Provider_NPI = VC
	    2 Rad_Prsnl = VC
	    2 Rad_Prsnl_NPI = VC
	    2 Height = VC
	    2 Weight = VC
	    2 Current_Smoker = VC
	)
 
CALL ECHO ("***** GETTING PATIENT DATA ******")
/**************************************************************
; Get Patient Data
**************************************************************/
 
SELECT DISTINCT Patient = pat.name_full_formatted
,Patient_Last = TRIM(pat.name_last,3)
,Patient_First = TRIM(pat.name_first,3)
,Patient_Middle = TRIM(pat.name_middle,3)
,DOB = FORMAT(pat.birth_dt_tm, "MM/DD/YYYY")
,SSN = EVALUATE2(IF (TRIM(ssn.alias,3) IN ('000000000','111111111','222222222',
	'333333333','444444444','555555555','666666666','777777777','888888888',
	'999999999')) " " ELSE TRIM(ssn.alias,3) ENDIF)
,Refused_SSN = UAR_GET_CODE_DISPLAY(pi.value_cd)
,CMRN = TRIM(cmrn.alias,3)
,Person_id = CNVTSTRING(pat.person_id)
,Address_1 = TRIM(addr.street_addr,3)
,Address_2 = TRIM(addr.street_addr2,3)
,City = TRIM(addr.city,3)
,State = TRIM(addr.state,3)
,Zip = TRIM(addr.zipcode,3)
,Country = TRIM(UAR_GET_CODE_DISPLAY(addr.country_cd),3)
,Email = EVALUATE2(IF (SIZE(email.street_addr) = 0
	  	OR CNVTUPPER(email.street_addr) = 'NONE'
	  	OR email.street_addr NOT LIKE '*@*'
	  	OR CNVTUPPER(email.street_addr) LIKE '*@.COM*'
	  	OR CNVTUPPER(email.street_addr) LIKE '*REFUSED*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'DECLINED*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'ASK@*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'ASKFOREMAIL@*') " " ELSE TRIM(email.street_addr,3) ENDIF)
,Home_Phone = TRIM(REPLACE(REPLACE(REPLACE(home_phone.phone_num,'(',''),')',''),'-',''),3)
,Mobile_Phone = TRIM(REPLACE(REPLACE(REPLACE(Mobile_Phone.phone_num,'(',''),')',''),'-',''),3)
,Work_Phone = TRIM(REPLACE(REPLACE(REPLACE(Work_Phone.phone_num,'(',''),')',''),'-',''),3)
,Gender = EVALUATE2(IF(pp.birth_sex_cd = 0) UAR_GET_CODE_DISPLAY(pat.sex_cd) ELSE UAR_GET_CODE_DISPLAY(pp.birth_sex_cd) ENDIF)
,Ethnicity = EVALUATE(pat.race_cd, 23274729 /*Multiple*/, '8', 309315 /*Black or African American*/, '4',
	309316 /*White*/, '9', 309317 /*Asian*/, '3', 309318, '2', 18702439 /*Patient Declined*/, '7',
	4189861 /*Native Hawaiian or Pactific Islander*/, '6', 25804105 /*Unavailable*/, '8','7')
,Is_Hispanic = EVALUATE(pat.ethnic_grp_cd, 312506, '1', 312507, '2', '3')
,CLMC_MRN = TRIM(CLMC_MRN.alias,3)
,CMC_MRN = TRIM(CMC_MRN.alias,3)
,FLMC_MRN = TRIM(FLMC_MRN.alias,3)
,FSR_MRN = TRIM(FSR_MRN.alias,3)
,LCMC_MRN = TRIM(LCMC_MRN.alias,3)
,MHHS_MRN = TRIM(MHHS_MRN.alias,3)
,MMC_MRN = TRIM(MMC_MRN.alias,3)
,PBH_MRN = TRIM(PBH_MRN.alias,3)
,PW_MRN = TRIM(PW_MRN.alias,3)
,RMC_MRN = TRIM(RMC_MRN.alias,3)
,TOG_MRN = TRIM(TOG_MRN.alias,3)
,Enc_Date = FORMAT(enc.reg_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
,Enc_Type = UAR_GET_CODE_DISPLAY(enc.encntr_type_cd)
,FIN = TRIM(fin.alias,3)
,Encntr_id = CNVTSTRING(enc.encntr_id)
,Facility = UAR_GET_CODE_DISPLAY(enc.loc_facility_cd)
,Facility_NPI = TRIM(orga.alias,3)
,Facility_Code = EVALUATE2(IF (orga_cov.alias = 'MMCH') 'B'
		ELSEIF (orga_cov.alias = 'FSWD') 'T'
		ELSEIF (orga_cov.alias = 'MMEC') 'B'
		ELSEIF (orga_cov.alias = 'MHDC') 'M'
		ELSEIF (orga_cov.alias = 'LCCR') 'S'
		ELSEIF (orga_cov.alias = 'FSBC') 'F'
		ELSE TRIM(orga_cov.alias,3)ENDIF)
,Org_Facility = TRIM(org.org_name,3)
,Order_Id = CNVTSTRING(ord.order_id)
,Accession = CONCAT(SUBSTRING(4,2,aor.accession), "-",		;0002
	SUBSTRING(6,2,aor.accession),"-",SUBSTRING(10,2,aor.accession),"-",
	SUBSTRING(13,SIZE(aor.accession),aor.accession))
,Order_Mnemonic = TRIM(ord.order_mnemonic,3)
,Current_Start_Date = ord.current_start_dt_tm "MM/DD/YYYY hh:mm:ss;;d"
,Order_Date = ord.orig_order_dt_tm "MM/DD/YYYY hh:mm:ss;;d"
,Order_Status = UAR_GET_CODE_DISPLAY(ord.order_status_cd)
,Order_Encntr_id = CNVTSTRING(ord.encntr_id)
,Order_Originating_Encntr_Id = CNVTSTRING(ord.originating_encntr_id)
,Order_Provider = TRIM(ord_prov.name_full_formatted,3)
,Order_Provider_NPI = TRIM(ord_prov_npi.alias,3)
,Rad_Prsnl = TRIM(radp.name_full_formatted,3)
,Rad_prsnl_NPI = TRIM(radpa.alias,3)
,Height = EVALUATE2(IF (SIZE(CEHT.result_val) = 0) " " ELSE TRIM(CEHT.result_val,3) ENDIF)
,Weight = EVALUATE2(IF (SIZE(CEWT.result_val) = 0) " " ELSE TRIM(CEWT.result_val,3) ENDIF)
,Current_Smoker = EVALUATE(smoker.result_val, 'No','3','Yes','1','Current','1','Greater than 1 year ago','2',
	'None','3','Within the past year','1','Current every day smoker','1','Former smoker','2',
	'Light tobacco smoker','1','Never smoker','3','Unknown if ever smoked','5','5')
FROM orders ord
,(INNER JOIN person pat ON (ord.person_id = pat.person_id
	AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')))
,(INNER JOIN encounter enc ON (ord.encntr_id = enc.encntr_id))
,(LEFT JOIN person_alias CMRN ON (pat.person_id = cmrn.person_id
	AND cmrn.person_alias_type_cd = 2.00 /*CMRN*/
	AND cmrn.active_ind = 1
	AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias SSN ON (pat.person_id = SSN.person_id
	AND SSN.person_alias_type_cd = 18.00 /*SSN*/
	AND SSN.active_ind = 1
	AND SSN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN encntr_alias fin ON (ord.encntr_id = fin.encntr_id
	AND fin.encntr_alias_type_cd = 1077 /*FIN*/
	AND fin.active_ind = 1
	AND fin.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN order_action oa ON (ord.order_id = oa.order_id
	AND oa.action_type_cd = 2534.00 /*Order*/))
,(LEFT JOIN prsnl ord_prov ON (oa.order_provider_id = ord_Prov.person_id))
,(LEFT JOIN prsnl_alias ord_prov_npi ON (ord_prov.person_id = ord_prov_npi.person_id
	AND ord_prov_npi.prsnl_alias_type_cd = 4038127.00 /*NPI*/
	AND ord_prov_npi.active_ind = 1
	AND ord_prov_npi.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN rad_report rp ON (ord.order_id = rp.order_id
	AND rp.sequence IN (SELECT MAX(r.sequence) FROM rad_report r
		WHERE ord.order_Id = r.order_id)))
,(LEFT JOIN prsnl radp ON (rp.dictated_by_id = radp.person_id))
,(LEFT JOIN prsnl_alias radpa ON (radp.person_id = radpa.person_Id
	AND radpa.prsnl_alias_type_cd = 4038127.00 /*NPI*/
	AND radpa.active_ind = 1
	AND radpa.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN organization org ON (enc.organization_id = org.organization_id))
,(LEFT JOIN organization_alias orga ON (org.organization_id = orga.organization_id
	AND orga.org_alias_type_cd = 4045119.00 /*NPI*/
	AND orga.active_ind = 1
	AND orga.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN organization_alias orga_cov ON (org.organization_id = orga_cov.organization_id
	AND orga_cov.org_alias_type_cd = 1130.00 /*Encounter organization Alias*/
	AND orga_cov.active_ind = 1
	AND orga_cov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN address addr ON (pat.person_id = addr.parent_entity_id
	AND addr.address_type_cd = 756.00 /*Home*/
	AND addr.address_type_seq = 1
	AND addr.active_ind = 1
	AND addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND NULLIND(addr.street_addr) = 0))
,(LEFT JOIN address email ON (pat.person_id = email.parent_entity_id
	AND email.address_type_cd = 755.00 /*Email*/
	AND email.address_type_seq = 1
	AND email.active_ind = 1
	AND email.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND NULLIND(email.street_addr) = 0))
,(LEFT JOIN phone home_phone ON (pat.person_id = home_phone.parent_entity_id
	AND home_phone.parent_entity_name = 'PERSON'
	AND home_phone.phone_type_cd = 170 /*Home*/
	AND home_phone.phone_type_seq = 1
	AND home_phone.active_ind = 1
	AND NULLIND(home_phone.phone_num) = 0
	AND home_phone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND home_phone.data_status_cd = 25.00 /*Auth*/
	AND home_phone.contact_method_cd != 0.00
	AND home_phone.updt_dt_tm IN (SELECT MAX(hp.updt_dt_tm) FROM phone hp
		WHERE hp.parent_entity_id = home_phone.parent_entity_id
		AND hp.parent_entity_name = 'PERSON'
		AND hp.phone_type_cd = 170 /*Home*/
		AND hp.phone_type_seq = 1
		AND hp.active_ind = 1
		AND NULLIND(hp.phone_num) = 0
		AND hp.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND hp.data_status_cd = 25.00 /*Auth*/
		AND hp.contact_method_cd != 0.00)))
,(LEFT JOIN phone mobile_phone ON (pat.person_id = mobile_phone.parent_entity_id
	AND mobile_phone.parent_entity_name = 'PERSON'
	AND mobile_phone.phone_type_cd = 4149712.00 /*Mobile*/
	AND mobile_phone.phone_type_seq = 1
	AND mobile_phone.active_ind = 1
	AND NULLIND(mobile_phone.phone_num) = 0
	AND mobile_phone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND mobile_phone.data_status_cd = 25.00 /*Auth*/
	AND mobile_phone.contact_method_cd != 0.00
	AND mobile_phone.updt_dt_tm IN (SELECT MAX(mp.updt_dt_tm) FROM phone mp
		WHERE mp.parent_entity_id = mobile_phone.parent_entity_id
		AND mp.parent_entity_name = 'PERSON'
		AND mp.phone_type_cd = 170 /*Home*/
		AND mp.phone_type_seq = 1
		AND mp.active_ind = 1
		AND NULLIND(mp.phone_num) = 0
		AND mp.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND mp.data_status_cd = 25.00 /*Auth*/
		AND mp.contact_method_cd != 0.00)))
,(LEFT JOIN phone work_phone ON (pat.person_id = work_phone.parent_entity_id
	AND work_phone.parent_entity_name = 'PERSON'
	AND work_phone.phone_type_cd = 163.00 /*Business*/
	AND work_phone.phone_type_seq = 1
	AND work_phone.active_ind = 1
	AND NULLIND(work_phone.phone_num) = 0
	AND work_phone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND work_phone.data_status_cd = 25.00 /*Auth*/
	AND work_phone.contact_method_cd != 0.00
	AND work_phone.updt_dt_tm IN (SELECT MAX(wp.updt_dt_tm) FROM phone wp
		WHERE wp.parent_entity_id = work_phone.parent_entity_id
		AND wp.parent_entity_name = 'PERSON'
		AND wp.phone_type_cd = 170 /*Home*/
		AND wp.phone_type_seq = 1
		AND wp.active_ind = 1
		AND NULLIND(wp.phone_num) = 0
		AND wp.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND wp.data_status_cd = 25.00 /*Auth*/
		AND wp.contact_method_cd != 0.00)))
,(LEFT JOIN person_alias CLMC_MRN ON (pat.person_id = CLMC_MRN.person_id
	AND CLMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND CLMC_MRN.alias_pool_cd = 2554148473 /*CLMC*/
	AND CLMC_MRN.active_ind = 1
	AND CLMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias CMC_MRN ON (pat.person_id = CMC_MRN.person_id
	AND CMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND CMC_MRN.alias_pool_cd = 25541484 /*CMC*/
	AND CMC_MRN.active_ind = 1
	AND CMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias FLMC_MRN ON (pat.person_id = FLMC_MRN.person_id
	AND FLMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND FLMC_MRN.alias_pool_cd = 2554148493 /*FLMC*/
	AND FLMC_MRN.active_ind = 1
	AND FLMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias FSR_MRN ON (pat.person_id = FSR_MRN.person_id
	AND FSR_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND FSR_MRN.alias_pool_cd = 2554148457 /*FSR*/
	AND FSR_MRN.active_ind = 1
	AND FSR_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias LCMC_MRN ON (pat.person_id = LCMC_MRN.person_id
	AND LCMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND LCMC_MRN.alias_pool_cd = 2554148483 /*LCMC*/
	AND LCMC_MRN.active_ind = 1
	AND LCMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias MHHS_MRN ON (pat.person_id = MHHS_MRN.person_id
	AND MHHS_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND MHHS_MRN.alias_pool_cd = 2554148501 /*MHHS*/
	AND MHHS_MRN.active_ind = 1
	AND MHHS_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias MMC_MRN ON (pat.person_id = MMC_MRN.person_id
	AND MMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND MMC_MRN.alias_pool_cd = 2554143671 /*MMC*/
	AND MMC_MRN.active_ind = 1
	AND MMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias PBH_MRN ON (pat.person_id = PBH_MRN.person_id
	AND PBH_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND PBH_MRN.alias_pool_cd = 2554156611 /*PBH*/
	AND PBH_MRN.active_ind = 1
	AND PBH_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias PW_MRN ON (pat.person_id = PW_MRN.person_id
	AND PW_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND PW_MRN.alias_pool_cd = 2554154983 /*PW*/
	AND PW_MRN.active_ind = 1
	AND PW_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias RMC_MRN ON (pat.person_id = RMC_MRN.person_id
	AND RMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND RMC_MRN.alias_pool_cd = 2554143663 /*RMC*/
	AND RMC_MRN.active_ind = 1
	AND RMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias TOG_MRN ON (pat.person_id = TOG_MRN.person_id
	AND TOG_MRN.person_alias_type_cd = 10.00 /*MRN*/
	AND TOG_MRN.alias_pool_cd = 2554158829 /*TOG*/
	AND TOG_MRN.active_ind = 1
	AND TOG_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(INNER JOIN clinical_event CEHT ON (CEHT.person_id = enc.person_id
	AND CEHT.event_cd = 4154126.00 /*Height*/
	AND CEHT.result_val != ' '
	AND CEHT.result_units_cd != 0.00
	AND CEHT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND CEHT.clinical_event_id = (SELECT MAX(ce.clinical_event_id)
		FROM clinical_event ce
		WHERE ce.person_id = CEHT.person_id
		AND ce.event_cd = 4154126.00 /*Height*/
		AND ce.result_val != ' '
		AND ce.result_units_cd != 0.00
		AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))))
,(INNER JOIN clinical_event CEWT ON (CEWT.person_id = enc.person_id
	AND CEWT.event_cd = 4154123.00 /*Weight*/
	AND CEWT.result_val != ' '
	AND CEWT.result_units_cd != 0.00
	AND CEWT.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND CEWT.clinical_event_id = (SELECT MAX(ce.clinical_event_id)
		FROM clinical_event ce
		WHERE ce.person_id = CEWT.person_id
		AND ce.event_cd = 4154123.00 /*Weight*/
		AND ce.result_val != ' '
		AND ce.result_units_cd != 0.00
		AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))))
,(LEFT JOIN clinical_event smoker ON (smoker.person_id = enc.person_id
	AND smoker.event_cd IN (2570651969.00 /*EPSDT Tobacco use*/,
		2559259237.00 /*EPSDT Say no to alcohol, drugs, tobacco*/,
	 	705199.00/*Tobacco Use*/, 25618495.00 /*Tobacco use quick*/)
	AND smoker.result_val != ' '
	AND smoker.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND smoker.clinical_event_id = (SELECT MAX(ce.clinical_event_id)
		FROM clinical_event ce
		WHERE ce.person_id = smoker.person_id
		AND ce.event_cd IN (2570651969.00 /*EPSDT Tobacco use*/,
			2559259237.00 /*EPSDT Say no to alcohol, drugs, tobacco*/,
	 		705199.00/*Tobacco Use*/, 25618495.00 /*Tobacco use quick*/)
		AND ce.result_val != ' '
		AND ce.valid_until_dt_tm > CNVTDATETIME(CURDATE,CURTIME3))))
,(LEFT JOIN person_info pi ON (pat.person_id = pi.person_id		;No SSN Reason
	AND pi.active_ind = 1
	AND pi.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND pi.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
	AND pi.value_cd != 0
	AND pi.info_type_cd = 1170.00 /*User Defined*/
	AND pi.info_sub_type_cd = 684147.00 /*No SSN*/))
,(LEFT JOIN person_patient pp ON (pat.person_id = pp.person_id		;Birth_Gender
	AND pp.active_ind = 1
	AND pp.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND pp.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN accession_order_r aor ON (ord.order_id = aor.order_id))		;0002
WHERE ord.catalog_cd IN (2557868381,2552736855) /*Low Dose*/
AND ord.order_status_cd IN (2543.00 /*Completed*/)
AND enc.encntr_type_cd NOT IN (22282402.00 /*Clinic*/, 2554389963.00 /*Phone Message*/)
 
/****************************************************************************
	Populate Record structure with Patient Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(exp_data->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(exp_data->list, cnt + 9)
	ENDIF
 
	exp_data->list[cnt].Patient = Patient
	exp_data->list[cnt].Patient_Last = Patient_Last
	exp_data->list[cnt].Patient_First = Patient_First
	exp_data->list[cnt].Patient_Middle = Patient_Middle
	exp_data->list[cnt].DOB = DOB
	exp_data->list[cnt].SSN = SSN
	exp_data->list[cnt].Refused_SSN = Refused_SSN
	exp_data->list[cnt].CMRN = CMRN
	exp_data->list[cnt].person_id = person_id
	exp_data->list[cnt].Address_1 = Address_1
	exp_data->list[cnt].Address_2 = Address_2
	exp_data->list[cnt].City = City
	exp_data->list[cnt].State = State
	exp_data->list[cnt].Zip = Zip
	exp_data->list[cnt].Country = Country
	exp_data->list[cnt].Email = Email
	exp_data->list[cnt].Home_Phone = Home_Phone
	exp_data->list[cnt].Mobile_Phone = Mobile_Phone
	exp_data->list[cnt].Work_Phone = Work_Phone
	exp_data->list[cnt].Gender = Gender
	exp_data->list[cnt].Ethnicity = Ethnicity
	exp_data->list[cnt].Is_Hispanic = Is_Hispanic
	exp_data->list[cnt].CLMC_MRN = CLMC_MRN
	exp_data->list[cnt].CMC_MRN = CMC_MRN
	exp_data->list[cnt].FLMC_MRN = FLMC_MRN
	exp_data->list[cnt].FSR_MRN = FSR_MRN
	exp_data->list[cnt].LCMC_MRN = LCMC_MRN
	exp_data->list[cnt].MHHS_MRN = MHHS_MRN
	exp_data->list[cnt].MMC_MRN = MMC_MRN
	exp_data->list[cnt].PBH_MRN = PBH_MRN
	exp_data->list[cnt].PW_MRN = PW_MRN
	exp_data->list[cnt].RMC_MRN = RMC_MRN
	exp_data->list[cnt].TOG_MRN = TOG_MRN
	exp_data->list[cnt].Enc_Date = Enc_Date
	exp_data->list[cnt].Enc_Type = Enc_Type
	exp_data->list[cnt].FIN = FIN
	exp_data->list[cnt].Encntr_id = CNVTSTRING(Encntr_Id)
	exp_data->list[cnt].Facility = Facility
	exp_data->list[cnt].Facility_NPI = Facility_NPI
	exp_data->list[cnt].Facility_Code = Facility_Code
	exp_data->list[cnt].Org_Facility = Org_Facility
	exp_data->list[cnt].order_id = CNVTSTRING(ord.order_Id)
	exp_data->list[cnt].accession = TRIM(accession)
	exp_data->list[cnt].order_mnemonic = TRIM(ord.order_mnemonic,3)
	exp_data->list[cnt].current_start_date = FORMAT(ord.current_start_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
	exp_data->list[cnt].Order_Date = FORMAT(ord.orig_order_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
	exp_data->list[cnt].Order_Status = Order_Status
	exp_data->list[cnt].Order_Encntr_id = Order_Encntr_id
	exp_data->list[cnt].Order_Originating_Encntr_id = Order_Originating_Encntr_id
	exp_data->list[cnt].Order_Provider = Order_Provider
	exp_data->list[cnt].Order_Provider_NPI = Order_Provider_NPI
	exp_data->list[cnt].Rad_Prsnl = Rad_Prsnl
	exp_data->list[cnt].Rad_Prsnl_NPI = Rad_Prsnl_NPI
	exp_data->list[cnt].Height = Height
	exp_data->list[cnt].Weight = Weight
	exp_data->list[cnt].Current_Smoker = Current_Smoker
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
 
 
CALL ECHO ("***** BUILD Output ******")
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
		output_rec = build("Patient", cov_pipe,
						"Patient_Last", cov_pipe,
						"Patient_First", cov_pipe,
						"Patient_Middle", cov_pipe,
						"DOB", cov_pipe,
						"SSN", cov_pipe,
						"Refused_SSN", cov_pipe,
						"CMRN", cov_pipe,
						"Person_Id", cov_pipe,
						"Address_1", cov_pipe,
						"Address_2", cov_pipe,
						"City", cov_pipe,
						"State", cov_pipe,
						"Zip", cov_pipe,
						"Country", cov_pipe,
						"Email", cov_pipe,
						"Home_Phone", cov_pipe,
						"Mobile_Phone", cov_pipe,
						"Work_Phone", cov_pipe,
						"Gender", cov_pipe,
						"Ethnicity", cov_pipe,
						"Is_Hispanic", cov_pipe,
						"CLMC_MRN", cov_pipe,
						"CMC_MRN", cov_pipe,
						"FLMC_MRN", cov_pipe,
						"FSR_MRN", cov_pipe,
						"LCMC_MRN", cov_pipe,
						"MHHS_MRN", cov_pipe,
						"MMC_MRN", cov_pipe,
						"PBH_MRN", cov_pipe,
						"PW_MRN", cov_pipe,
						"RMC_MRN", cov_pipe,
						"TOG_MRN", cov_pipe,
						"Enc_Date", cov_pipe,
						"Enc_Type", cov_pipe,
						"FIN", cov_pipe,
						"Encntr_id", cov_pipe,
						"Facility", cov_pipe,
						"Facility_NPI", cov_pipe,
						"Facility_Code", cov_pipe,
						"Org_Facility", cov_pipe,
						"Order_id", cov_pipe,
						"Accession", cov_pipe,
						"Order_Mnemonic", cov_pipe,
						"Current_Start_Date", cov_pipe,
						"Order_Date", cov_pipe,
						"Order_Status", cov_pipe,
						"Order_Encntr_id", cov_pipe,
						"Order_Originating_Encntr_id", cov_pipe,
						"Order_Provider", cov_pipe,
						"Order_Provider_NPI", cov_pipe,
						"Rad_Prsnl", cov_pipe,
						"Rad_Prsnl_NPI", cov_pipe,
						"Height", cov_pipe,
						"Weight", cov_pipe,
						"Current_Smoker")
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						exp_data->list[dt.seq].Patient, cov_pipe,
						exp_data->list[dt.seq].Patient_Last, cov_pipe,
						exp_data->list[dt.seq].Patient_First, cov_pipe,
						exp_data->list[dt.seq].Patient_Middle, cov_pipe,
						exp_data->list[dt.seq].DOB, cov_pipe,
						exp_data->list[dt.seq].SSN, cov_pipe,
						exp_data->list[dt.seq].Refused_SSN, cov_pipe,
						exp_data->list[dt.seq].CMRN, cov_pipe,
						exp_data->list[dt.seq].Person_id, cov_pipe,
						exp_data->list[dt.seq].Address_1, cov_pipe,
						exp_data->list[dt.seq].Address_2, cov_pipe,
						exp_data->list[dt.seq].City, cov_pipe,
						exp_data->list[dt.seq].State, cov_pipe,
						exp_data->list[dt.seq].Zip, cov_pipe,
						exp_data->list[dt.seq].Country, cov_pipe,
						exp_data->list[dt.seq].Email, cov_pipe,
						exp_data->list[dt.seq].Home_Phone, cov_pipe,
						exp_data->list[dt.seq].Mobile_Phone, cov_pipe,
						exp_data->list[dt.seq].Work_Phone, cov_pipe,
						exp_data->list[dt.seq].Gender, cov_pipe,
						exp_data->list[dt.seq].Ethnicity, cov_pipe,
						exp_data->list[dt.seq].Is_Hispanic, cov_pipe,
						exp_data->list[dt.seq].CLMC_MRN, cov_pipe,
						exp_data->list[dt.seq].CMC_MRN, cov_pipe,
						exp_data->list[dt.seq].FLMC_MRN, cov_pipe,
						exp_data->list[dt.seq].FSR_MRN, cov_pipe,
						exp_data->list[dt.seq].LCMC_MRN, cov_pipe,
						exp_data->list[dt.seq].MHHS_MRN, cov_pipe,
						exp_data->list[dt.seq].MMC_MRN, cov_pipe,
						exp_data->list[dt.seq].PBH_MRN, cov_pipe,
						exp_data->list[dt.seq].PW_MRN, cov_pipe,
						exp_data->list[dt.seq].RMC_MRN, cov_pipe,
						exp_data->list[dt.seq].TOG_MRN, cov_pipe,
						exp_data->list[dt.seq].Enc_Date, cov_pipe,
						exp_data->list[dt.seq].Enc_Type, cov_pipe,
						exp_data->list[dt.seq].FIN, cov_pipe,
						exp_data->list[dt.seq].Encntr_id, cov_pipe,
						exp_data->list[dt.seq].Facility, cov_pipe,
						exp_data->list[dt.seq].Facility_NPI, cov_pipe,
						exp_data->list[dt.seq].Facility_Code, cov_pipe,
						exp_data->list[dt.seq].Org_Facility, cov_pipe,
						exp_data->list[dt.seq].Order_id, cov_pipe,
						exp_data->list[dt.seq].accession, cov_pipe,
						exp_data->list[dt.seq].Order_Mnemonic, cov_pipe,
						exp_data->list[dt.seq].Current_Start_Date, cov_pipe,
						exp_data->list[dt.seq].Order_Date, cov_pipe,
						exp_data->list[dt.seq].Order_Status, cov_pipe,
						exp_data->list[dt.seq].Order_Encntr_id, cov_pipe,
						exp_data->list[dt.seq].Order_Originating_Encntr_id, cov_pipe,
						exp_data->list[dt.seq].Order_Provider, cov_pipe,
						exp_data->list[dt.seq].Order_Provider_NPI, cov_pipe,
						exp_data->list[dt.seq].Rad_Prsnl, cov_pipe,
						exp_data->list[dt.seq].Rad_Prsnl_NPI, cov_pipe,
						exp_data->list[dt.seq].Height, cov_pipe,
						exp_data->list[dt.seq].Weight, cov_pipe,
						exp_data->list[dt.seq].Current_Smoker)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",exp_data->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Patient", cov_pipe,
						"Patient_Last", cov_pipe,
						"Patient_First", cov_pipe,
						"Patient_Middle", cov_pipe,
						"DOB", cov_pipe,
						"SSN", cov_pipe,
						"Refused_SSN", cov_pipe,
						"CMRN", cov_pipe,
						"Person_Id", cov_pipe,
						"Address_1", cov_pipe,
						"Address_2", cov_pipe,
						"City", cov_pipe,
						"State", cov_pipe,
						"Zip", cov_pipe,
						"Country", cov_pipe,
						"Email", cov_pipe,
						"Home_Phone", cov_pipe,
						"Mobile_Phone", cov_pipe,
						"Work_Phone", cov_pipe,
						"Gender", cov_pipe,
						"Ethnicity", cov_pipe,
						"Is_Hispanic", cov_pipe,
						"CLMC_MRN", cov_pipe,
						"CMC_MRN", cov_pipe,
						"FLMC_MRN", cov_pipe,
						"FSR_MRN", cov_pipe,
						"LCMC_MRN", cov_pipe,
						"MHHS_MRN", cov_pipe,
						"MMC_MRN", cov_pipe,
						"PBH_MRN", cov_pipe,
						"PW_MRN", cov_pipe,
						"RMC_MRN", cov_pipe,
						"TOG_MRN", cov_pipe,
						"Enc_Date", cov_pipe,
						"Enc_Type", cov_pipe,
						"FIN", cov_pipe,
						"Encntr_id", cov_pipe,
						"Facility", cov_pipe,
						"Facility_NPI", cov_pipe,
						"Facility_Code", cov_pipe,
						"Org_Facility", cov_pipe,
						"Order_id", cov_pipe,
						"Accession", cov_pipe,
						"Order_Mnemonic", cov_pipe,
						"Current_Start_Date", cov_pipe,
						"Order_Date", cov_pipe,
						"Order_Status", cov_pipe,
						"Order_Encntr_id", cov_pipe,
						"Order_Originating_Encntr_id", cov_pipe,
						"Order_Provider", cov_pipe,
						"Order_Provider_NPI", cov_pipe,
						"Rad_Prsnl", cov_pipe,
						"Rad_Prsnl_NPI", cov_pipe,
						"Height", cov_pipe,
						"Weight", cov_pipe,
						"Current_Smoker")
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
CALL ECHORECORD (exp_data)
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
END
GO

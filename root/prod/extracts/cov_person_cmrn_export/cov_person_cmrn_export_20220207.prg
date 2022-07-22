/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		11/05/2021
	Solution:			Radiology
	Source file name:	cov_person_cmrn_export.prg
	Object name:		cov_person_cmrn_export
	Request #:			11570
 
	Program purpose:	Export patients for Aspen Lung Go Live
 
	Executing from:		CCL
 
 	Special Notes:
	Execute Example:
 
***********************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***********************************************************************************************
 
 Mod   Date	          Developer				 Comment
 ----  ----------	  --------------------	 --------------------------------------------------
 0001  11/05/2021     Dawn Greer, DBA        Original Release
 
***********************************************************************************************/
 
drop program cov_person_cmrn_export go
create program cov_person_cmrn_export
 
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
 
DECLARE file_var			= vc WITH noconstant("cov_person_cmrn_extract_")
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
 
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/from_client_site/dg_folder/"
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
	    2 Patient = C100
	    2 Patient_Last = C50
	    2 Patient_First = C50
	    2 Patient_Middle = C50
	    2 DOB = C10
	    2 Deceased = C5
	    2 Deceased_Date = C10
	    2 SSN = C11
	    2 CMRN = C20
	    2 Person_id = F8
 		2 Address_1 = C50
	    2 Address_2 = C50
	    2 City = C50
	    2 State = C5
	    2 Zip = C10
	    2 Country = C10
	    2 Ethnicity = C10
	    2 Is_Hispanic = C10
	    2 Email = C100
	    2 Home_Phone = C10
	    2 Mobile_Phone = C10
	    2 Work_Phone = C10
	    2 Gender = C10
	    2 CLMC_MRN = C20
	    2 CMC_MRN = C20
	    2 FLMC_MRN = C20
	    2 FSR_MRN = C20
	    2 LCMC_MRN = C20
	    2 MHHS_MRN = C20
	    2 MMC_MRN = C20
	    2 PBH_MRN = C20
	    2 PW_MRN = C20
	    2 RMC_MRN = C20
	    2 TOG_MRN = C20
	    2 Pat_Primary_Ins = C100
	    2 Pat_Primary_Ins_Plan = C100
	    2 Pat_Primary_Ins_Member_Num = C20
	    2 Pat_Primary_Ins_Group_Num = C20
	    2 Pat_Primary_Ins_Policy_Num = C20
	    2 Pat_Primary_Ins_Street_Addr = C50
	    2 Pat_Primary_Ins_Street_Addr2 = C50
	    2 Pat_Primary_Ins_City = C50
	    2 Pat_Primary_Ins_State = C5
	    2 Pat_Primary_Ins_ZipCode = C10
	    2 Pat_Primary_Ins_Phone = C10
	    2 Pat_Secondary_Ins = C100
	    2 Pat_Secondary_Ins_Plan = C100
	    2 Pat_Secondary_Ins_Member_Num = C20
	    2 Pat_Secondary_Ins_Group_Num = C20
	    2 Pat_Secondary_Ins_Policy_Num = C20
	    2 Pat_Secondary_Ins_Street_Addr = C50
	    2 Pat_Secondary_Ins_Street_Addr2 = C50
	    2 Pat_Secondary_Ins_City = C50
	    2 Pat_Secondary_Ins_State = C5
	    2 Pat_Secondary_Ins_ZipCode = C10
	    2 Pat_Secondary_Ins_Phone = C10
	    2 Enc_Primary_Ins = C100
	    2 Enc_Primary_Ins_Plan = C100
	    2 Enc_Primary_Ins_Member_Num = C20
	    2 Enc_Primary_Ins_Group_Num = C20
	    2 Enc_Primary_Ins_Policy_Num = C20
	    2 Enc_Primary_Ins_Street_Addr = C50
	    2 Enc_Primary_Ins_Street_Addr2 = C50
	    2 Enc_Primary_Ins_City = C50
	    2 Enc_Primary_Ins_State = C5
	    2 Enc_Primary_Ins_ZipCode = C10
	    2 Enc_Primary_Ins_Phone = C10
	    2 Enc_Secondary_Ins = C100
	    2 Enc_Secondary_Ins_Plan = C100
	    2 Enc_Secondary_Ins_Member_Num = C20
	    2 Enc_Secondary_Ins_Group_Num = C20
	    2 Enc_Secondary_Ins_Policy_Num = C20
	    2 Enc_Secondary_Ins_Street_Addr = C50
	    2 Enc_Secondary_Ins_Street_Addr2 = C50
	    2 Enc_Secondary_Ins_City = C50
	    2 Enc_Secondary_Ins_State = C5
	    2 Enc_Secondary_Ins_ZipCode = C10
	    2 Enc_Secondary_Ins_Phone = C10
	    2 Medication1 = C50
	    2 Med1_Category1 = C50
	    2 Med1_Category2 = C50
	    2 Med1_Category3 = C50
	    2 Medication2 = C50
	    2 Med2_Category1 = C50
	    2 Med2_Category2 = C50
	    2 Med2_Category3 = C50
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** GETTING PATIENT DATA ******")
/**************************************************************
; Get Patient Data
**************************************************************/
 
SELECT DISTINCT INTO "noforms"
Patient = pat.name_full_formatted
,Patient_Last = TRIM(pat.name_last,3)
,Patient_First = TRIM(pat.name_first,3)
,Patient_Middle = TRIM(pat.name_middle,3)
,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm, 1) ,"MM/DD/YYYY;;d" )
,Deceased = TRIM(UAR_GET_CODE_DISPLAY(pat.deceased_cd),3)
,Deceased_Date = FORMAT(CNVTDATETIMEUTC(pat.deceased_dt_tm, 1) ,"MM/DD/YYYY;;d" )
,SSN = EVALUATE2(IF (TRIM(ssn.alias,3) IN ('000000000','111111111','222222222',
	'333333333','444444444','555555555','666666666','777777777','888888888',
	'999999999')) " " ELSE TRIM(ssn.alias,3) ENDIF)
,CMRN = TRIM(cmrn.alias,3)
,Person_id = pat.person_id
,Address_1 = TRIM(addr.street_addr,3)
,Address_2 = TRIM(addr.street_addr2,3)
,City = TRIM(addr.city,3)
,State = TRIM(addr.state,3)
,Zip = TRIM(addr.zipcode,3)
,Country = TRIM(UAR_GET_CODE_DISPLAY(addr.country_cd),3)
,Ethnicity = EVALUATE(pat.race_cd, 23274729 /*Multiple*/, '8', 309315 /*Black or African American*/, '4',
	309316 /*White*/, '9', 309317 /*Asian*/, '3', 309318, '2', 18702439 /*Patient Declined*/, '7',
	4189861 /*Native Hawaiian or Pactific Islander*/, '6', 25804105 /*Unavailable*/, '8','7')
,Is_Hispanic = EVALUATE(pat.ethnic_grp_cd, 312506, '1', 312507, '2', '3')
,Email = EVALUATE2(IF (SIZE(email.street_addr) = 0
	  	OR CNVTUPPER(email.street_addr) = 'NONE'
	  	OR email.street_addr NOT LIKE '*@*'
	  	OR CNVTUPPER(email.street_addr) LIKE '*@.COM*'
	  	OR CNVTUPPER(email.street_addr) LIKE '*REFUSED*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'DECLINED*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'ASK@*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'ASKFOREMAIL@*') " " ELSE TRIM(email.street_addr,3) ENDIF)
,Home_Phone = EVALUATE2(IF (home_phone.phone_num_key LIKE '*^MOBILE*' OR home_phone.phone_num_key LIKE '*NONE*'
	  	OR SIZE(home_phone.phone_num_key) < 10 OR home_phone.phone_Num_key IN ('9999999999','8888888888','7777777777',
	  	'6666666666','5555555555','4444444444','3333333333','2222222222','1111111111','0000000000')) " "
	  	ELSE TRIM(REPLACE(REPLACE(REPLACE(home_phone.phone_num_key,'(',''),')',''),'-',''),3) ENDIF)
,Mobile_Phone = EVALUATE2(IF (Mobile_Phone.phone_num_key LIKE '*^MOBILE*' OR Mobile_Phone.phone_num_key LIKE '*NONE*'
	  	OR SIZE(Mobile_Phone.phone_num_key) < 10 OR Mobile_Phone.phone_Num_key IN ('9999999999','8888888888','7777777777',
	  	'6666666666','5555555555','4444444444','3333333333','2222222222','1111111111','0000000000')) " "
	  	ELSE TRIM(REPLACE(REPLACE(REPLACE(Mobile_Phone.phone_num_key,'(',''),')',''),'-',''),3) ENDIF)
,Work_Phone = EVALUATE2(IF (Work_Phone.phone_num_key LIKE '*^MOBILE*' OR Work_Phone.phone_num_key LIKE '*NONE*'
	  	OR SIZE(Work_Phone.phone_num_key) < 10 OR Work_Phone.phone_Num_key IN ('9999999999','8888888888','7777777777',
	  	'6666666666','5555555555','4444444444','3333333333','2222222222','1111111111','0000000000')) " "
	  	ELSE TRIM(REPLACE(REPLACE(REPLACE(Work_Phone.phone_num_key,'(',''),')',''),'-',''),3) ENDIF)
,Gender = EVALUATE2(IF(pp.birth_sex_cd = 0) UAR_GET_CODE_DISPLAY(pat.sex_cd) ELSE UAR_GET_CODE_DISPLAY(pp.birth_sex_cd) ENDIF)
;,CLMC_MRN = TRIM(CLMC_MRN.alias,3)
;,CMC_MRN = TRIM(CMC_MRN.alias,3)
;,FLMC_MRN = TRIM(FLMC_MRN.alias,3)
;,FSR_MRN = TRIM(FSR_MRN.alias,3)
;,LCMC_MRN = TRIM(LCMC_MRN.alias,3)
;,MHHS_MRN = TRIM(MHHS_MRN.alias,3)
;,MMC_MRN = TRIM(MMC_MRN.alias,3)
;,PBH_MRN = TRIM(PBH_MRN.alias,3)
;,PW_MRN = TRIM(PW_MRN.alias,3)
;,RMC_MRN = TRIM(RMC_MRN.alias,3)
;,TOG_MRN = TRIM(TOG_MRN.alias,3)
FROM person pat
,(LEFT JOIN person_patient pp ON (pat.person_id = pp.person_id		;Birth_Gender
	AND pp.active_ind = 1
	AND pp.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND pp.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)))
,(INNER JOIN encounter enc ON (pat.person_id = enc.person_id
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
	AND enc.active_ind = 1
	AND enc.encntr_id = (SELECT MAX(e.encntr_id)
		FROM encounter e
		WHERE e.person_id = enc.person_id
		AND encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
		AND e.active_ind = 1)))
,(LEFT JOIN person_alias CMRN ON (pat.person_id = cmrn.person_id
	AND cmrn.person_alias_type_cd = 2.00 /*CMRN*/
	AND cmrn.active_ind = 1
	AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
,(LEFT JOIN person_alias SSN ON (pat.person_id = SSN.person_id
	AND SSN.person_alias_type_cd = 18.00 /*SSN*/
	AND SSN.active_ind = 1
	AND SSN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
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
;,(LEFT JOIN person_alias CLMC_MRN ON (pat.person_id = CLMC_MRN.person_id
;	AND CLMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND CLMC_MRN.alias_pool_cd = 2554148473 /*CLMC*/
;	AND CLMC_MRN.active_ind = 1
;	AND CLMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias CMC_MRN ON (pat.person_id = CMC_MRN.person_id
;	AND CMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND CMC_MRN.alias_pool_cd = 25541484 /*CMC*/
;	AND CMC_MRN.active_ind = 1
;	AND CMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias FLMC_MRN ON (pat.person_id = FLMC_MRN.person_id
;	AND FLMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND FLMC_MRN.alias_pool_cd = 2554148493 /*FLMC*/
;	AND FLMC_MRN.active_ind = 1
;	AND FLMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias FSR_MRN ON (pat.person_id = FSR_MRN.person_id
;	AND FSR_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND FSR_MRN.alias_pool_cd = 2554148457 /*FSR*/
;	AND FSR_MRN.active_ind = 1
;	AND FSR_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias LCMC_MRN ON (pat.person_id = LCMC_MRN.person_id
;	AND LCMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND LCMC_MRN.alias_pool_cd = 2554148483 /*LCMC*/
;	AND LCMC_MRN.active_ind = 1
;	AND LCMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias MHHS_MRN ON (pat.person_id = MHHS_MRN.person_id
;	AND MHHS_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND MHHS_MRN.alias_pool_cd = 2554148501 /*MHHS*/
;	AND MHHS_MRN.active_ind = 1
;	AND MHHS_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias MMC_MRN ON (pat.person_id = MMC_MRN.person_id
;	AND MMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND MMC_MRN.alias_pool_cd = 2554143671 /*MMC*/
;	AND MMC_MRN.active_ind = 1
;	AND MMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias PBH_MRN ON (pat.person_id = PBH_MRN.person_id
;	AND PBH_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND PBH_MRN.alias_pool_cd = 2554156611 /*PBH*/
;	AND PBH_MRN.active_ind = 1
;	AND PBH_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias PW_MRN ON (pat.person_id = PW_MRN.person_id
;	AND PW_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND PW_MRN.alias_pool_cd = 2554154983 /*PW*/
;	AND PW_MRN.active_ind = 1
;	AND PW_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias RMC_MRN ON (pat.person_id = RMC_MRN.person_id
;	AND RMC_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND RMC_MRN.alias_pool_cd = 2554143663 /*RMC*/
;	AND RMC_MRN.active_ind = 1
;	AND RMC_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
;,(LEFT JOIN person_alias TOG_MRN ON (pat.person_id = TOG_MRN.person_id
;	AND TOG_MRN.person_alias_type_cd = 10.00 /*MRN*/
;	AND TOG_MRN.alias_pool_cd = 2554158829 /*TOG*/
;	AND TOG_MRN.active_ind = 1
;	AND TOG_MRN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)))
WHERE pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST','ZZZTESTTWENTYONE','AAATEST','AAATEST HERO','AAAtestpatient','NNNTEST','TEST','TEST 4','TESTFAMILY',
	'TESTPATIENT')
AND pat.active_ind = 1
AND pat.name_last_key IN ('TABBAA',
'TABOR',
'TALLENT',
'TALLEY',
'TALLMAN',
'TALLON',
'TAMOSIUNAS',
'TAMPAS',
'TANTLINGER',
'TAPLIN',
'TARWATER',
'TATE',
'TAUBE',
'TAYLOR',
'TEAGUE',
'TEDDER',
'TEFFETELLER',
'TEMME',
'TEMPLETON',
'TENPENNY',
'TERRELL',
'TERRY',
'THACKER',
'THARP',
'THARPE',
'THIBEAULT',
'THIEL',
'THIENEL',
'THIER',
'THIGPEN',
'THOMAS',
'THOMPSON',
'THORNBURG',
'THORNBURGH',
'THORNHILL',
'THORPE',
'THRASHER',
'THREET',
'THRESS',
'THURMAN',
'THURMER',
'TIESLER',
'TILDEN',
'TILLERY',
'TILLEY',
'TILLMAN',
'TIMMONS',
'TINCH',
'TINDEL',
'TINDELL',
'TINO',
'TINSLEY',
'TIPTON',
'TITTLE',
'TODD',
'TOLLIVER',
'TOLMAN',
'TOLOPKA',
'TOMLINSON',
'TOOMEY',
'TORBETT',
'TOULSON',
'TOUTON',
'TOWNSEND',
'TOZZI',
'TRABOLD',
'TRAVINS',
'TRAVIS',
'TRAYNUM',
'TREADWAY',
'TRENT',
'TRENTHAM',
'TREW',
'TRIPLETT',
'TRIVETT',
'TROGLIN',
'TROTTER',
'TROUT',
'TROXEL',
'TSCHUDY',
'TSITSEKLIS',
'TUCKER',
'TUDETHUOT',
'TUGGLE',
'TULLOCK',
'TURBEVILLE',
'TURNER',
'TURPIN',
'TUSTISON',
'TUTTLE',
'TYE',
'TYRE',
'UDE',
'ULMER',
'UMLAUF',
'UMSTEAD',
'UNDERDOWN',
'UNDERWOOD',
'UPCHURCH',
'UPTON',
'URBAN',
'VALENTINE',
'VALENTINI',
'VAN CAMP',
'VAN DALEY',
'VAN ES',
'VANAUKEN',
'VANCE',
'VANDELL',
'VANDENBORRE',
'VANDERGRIFF',
'VANDERPOOLE',
'VANDERWIELE',
'VANEK',
'VANGUNDY',
'VANHOOZIER',
'VANN',
'VANOSS',
'VANVALKENBURG',
'VARGO',
'VAUGHAN',
'VAUGHN',
'VAUX',
'VAVREK',
'VAZQUEZ COLON',
'VEALS',
'VENABLE',
'VERDERESE',
'VERNON',
'VERRAN',
'VESS',
'VIAR',
'VIARS',
'VICARS',
'VILES',
'VINEYARD',
'VOGUS',
'VOILES',
'VONESH',
'VOTAW',
'VOWELL',
'WADDELL',
'WADE',
'WADSWORTH',
'WAGNER',
'WAGONER',
'WAITINAS',
'WALCH',
'WALDECK',
'WALDO',
'WALDROP',
'WALDROUP',
'WALKDEN',
'WALKER',
'WALKER ALLISON',
'WALL',
'WALLACE',
'WALLEN',
'WALLIS',
'WALLS',
'WALSH',
'WALTERS',
'WAMPLER',
'WANG',
'WARD',
'WARNER',
'WARREN',
'WARRIX',
'WARWICK',
'WASHAM',
'WASHINGTON',
'WATERHOUSE',
'WATERS',
'WATKINS',
'WATSON',
'WATT',
'WATTENBARGER',
'WEAKLEY',
'WEATHERBY',
'WEATHERFORD',
'WEATHERHEAD',
'WEATHERS',
'WEAVER',
'WEBB',
'WEBB MILLINGTON',
'WEBBER',
'WEBER',
'WEBSTER',
'WEECH',
'WEEKS',
'WEESNER',
'WEIDENBURNER',
'WEIER',
'WEIGEL',
'WEIR',
'WEISS',
'WELCH',
'WELKER',
'WELLNER',
'WELLS',
'WENRICH',
'WENZEL',
'WERNER',
'WERNTZ',
'WERRE',
'WERT',
'WEST',
'WESTERN',
'WESTMORELAND',
'WESTON',
'WEY',
'WHALEN',
'WHALEY',
'WHEAT',
'WHEATLEY',
'WHEELER',
'WHELESS',
'WHISMAN',
'WHISNANT',
'WHITAKER',
'WHITE',
'WHITEHEAD',
'WHITFIELD',
'WHITING',
'WHITLEY',
'WHITMAN',
'WHITNEY',
'WHITT',
'WHITTAKER',
'WHITTED',
'WHITTEN',
'WHITTLE',
'WHYTE',
'WICKS',
'WIELAND',
'WIEMER',
'WIGGINS',
'WILBUR',
'WILBURN',
'WILCOX',
'WILD',
'WILDER',
'WILHOITE',
'WILKE',
'WILKERSON',
'WILKEY',
'WILKIE',
'WILKINS',
'WILKINSON',
'WILLARD',
'WILLETT',
'WILLETTE',
'WILLEY',
'WILLIAMS',
'WILLIAMSEN',
'WILLIAMSON',
'WILLIFORD',
'WILLINGS',
'WILLIS',
'WILMOTH',
'WILSON',
'WIMBERLY',
'WINCH',
'WINDER',
'WINDSOR',
'WINKEL',
'WINKLE',
'WINKLER',
'WINSTEAD',
'WINSTON',
'WINTER',
'WINTON',
'WISE',
'WITCHEN',
'WITENBARGER',
'WITHERSPOON',
'WITMER',
'WITT',
'WITTIBSLAGER',
'WOCHELE',
'WOFSY',
'WOJNAROWSKI',
'WOLF',
'WOLFE',
'WOLFENBARGER',
'WOLFORD',
'WOMAC',
'WOMACK',
'WOOD',
'WOODALL',
'WOODARD',
'WOODBY',
'WOODFORD',
'WOODROW',
'WOODRUFF',
'WOODS',
'WOODWARD',
'WOODY',
'WOOLARD',
'WOOLIVER',
'WOOTTON',
'WORD',
'WORKMAN',
'WORLEY',
'WORMSLEY',
'WORTH',
'WORTHINGTON',
'WRIGHT',
'WYANT',
'WYLIE',
'WYRICK',
'YARBOROUGH',
'YARBROUGH AUTEN',
'YARDLEY',
'YARNELL',
'YASTE',
'YEAGER',
'YEARY',
'YEBOAH',
'YERKES',
'YOAKUM',
'YODER',
'YOKLEY',
'YORK',
'YOUNG',
'YOUNGBLOOD',
'YOW',
'YUSE',
'YUTZY',
'ZAAR',
'ZABEL',
'ZACHMANN',
'ZADES',
'ZANOLLI',
'ZATYKO',
'ZEIGLER',
'ZETTEL',
'ZEVENEY',
'ZHAO',
'ZICK',
'ZIEBEL',
'ZIMMER',
'ZIMMERMAN',
'ZINDLE',
'ZIOBRO',
'ZIRKLE',
'ZISMAN',
'ZOOK')
 
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
	exp_data->list[cnt].Deceased = Deceased
	exp_data->list[cnt].Deceased_Date = Deceased_Date
	exp_data->list[cnt].SSN = SSN
	exp_data->list[cnt].CMRN = CMRN
	exp_data->list[cnt].person_id = person_id
	exp_data->list[cnt].Address_1 = Address_1
	exp_data->list[cnt].Address_2 = Address_2
	exp_data->list[cnt].City = City
	exp_data->list[cnt].State = State
	exp_data->list[cnt].Zip = Zip
	exp_data->list[cnt].Country = Country
	exp_data->list[cnt].Ethnicity = Ethnicity
	exp_data->list[cnt].Is_Hispanic = Is_Hispanic
	exp_data->list[cnt].Email = Email
	exp_data->list[cnt].Home_Phone = Home_Phone
	exp_data->list[cnt].Mobile_Phone = Mobile_Phone
	exp_data->list[cnt].Work_Phone = Work_Phone
	exp_data->list[cnt].Gender = Gender
;	exp_data->list[cnt].CLMC_MRN = CLMC_MRN
;	exp_data->list[cnt].CMC_MRN = CMC_MRN
;	exp_data->list[cnt].FLMC_MRN = FLMC_MRN
;	exp_data->list[cnt].FSR_MRN = FSR_MRN
;	exp_data->list[cnt].LCMC_MRN = LCMC_MRN
;	exp_data->list[cnt].MHHS_MRN = MHHS_MRN
;	exp_data->list[cnt].MMC_MRN = MMC_MRN
;	exp_data->list[cnt].PBH_MRN = PBH_MRN
;	exp_data->list[cnt].PW_MRN = PW_MRN
;	exp_data->list[cnt].RMC_MRN = RMC_MRN
;	exp_data->list[cnt].TOG_MRN = TOG_MRN
 
FOOT REPORT
 	exp_data->output_cnt = cnt
 	CALL alterlist(exp_data->list, cnt)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO ("***** GETTING PERSON PRIMARY INSURANCE DATA ******")
/**************************************************************
; Get Person Primary Insurance Data
**************************************************************/
 
SELECT DISTINCT INTO "noforms"
Person_id = ppr1.person_id
,Pat_Primary_Ins = TRIM(org1.org_name,3)
,Pat_Primary_Ins_Plan = TRIM(hp1.plan_name,3)
,Pat_Primary_Ins_Member_Num = TRIM(ppr1.member_nbr,3)
,Pat_Primary_Ins_Group_Num = TRIM(ppr1.group_nbr,3)
,Pat_Primary_Ins_Policy_Num = TRIM(ppr1.policy_nbr,3)
,Pat_Primary_Ins_Street_Addr = TRIM(addr1.street_addr,3)
,Pat_Primary_Ins_Street_Addr2 = TRIM(addr1.street_addr2,3)
,Pat_Primary_Ins_City = TRIM(addr1.city,3)
,Pat_Primary_Ins_State = TRIM(addr1.state,3)
,Pat_Primary_Ins_ZipCode = TRIM(addr1.zipcode,3)
,Pat_Primary_Ins_Phone = TRIM(REPLACE(REPLACE(REPLACE(ph1.phone_num,'-',''),')',''),'(',''),3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,person_plan_reltn ppr1
	,person_plan_profile_reltn pppr1
	,person_plan_profile ppp1
	,address addr1
	,phone ph1
	,health_plan hp1
	,organization org1
	,person pat
	,encounter enc
PLAN d
JOIN ppr1 WHERE ppr1.person_id = exp_data->list[d.seq].person_id
	AND ppr1.active_ind = 1
	AND ppr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ppr1.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN pppr1 WHERE ppr1.person_plan_reltn_id = pppr1.person_plan_reltn_id
	AND pppr1.active_ind = 1
	AND pppr1.priority_seq = 1
JOIN ppp1 WHERE pppr1.person_plan_profile_id = ppp1.person_plan_profile_id
	AND ppp1.profile_type_cd = 23838228.00 /*Health Professional*/
	AND ppp1.active_ind = 1
JOIN addr1 WHERE ppr1.person_plan_reltn_id = addr1.parent_entity_id
	AND addr1.address_type_cd = 754.00 /*Business*/
	AND addr1.active_ind = 1
	AND addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND addr1.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN ph1 WHERE ppr1.person_plan_reltn_id = ph1.parent_entity_id
	AND ph1.phone_type_cd = 163.00 /*Business*/
	AND ph1.active_ind = 1
	AND ph1.phone_type_seq = 1
	AND ph1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ph1.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN hp1 WHERE ppr1.health_plan_id = hp1.health_plan_id
JOIN org1 WHERE ppr1.organization_id = org1.organization_id
JOIN enc WHERE ppr1.person_id = enc.person_id
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
	AND enc.active_ind = 1
	AND enc.encntr_id = (SELECT MAX(e.encntr_id)
		FROM encounter e
		WHERE e.person_id = enc.person_id
		AND encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
		AND e.active_ind = 1)
JOIN pat WHERE ppr1.person_id = pat.person_id
AND pat.name_last_key IN ('TABBAA',
'TABOR',
'TALLENT',
'TALLEY',
'TALLMAN',
'TALLON',
'TAMOSIUNAS',
'TAMPAS',
'TANTLINGER',
'TAPLIN',
'TARWATER',
'TATE',
'TAUBE',
'TAYLOR',
'TEAGUE',
'TEDDER',
'TEFFETELLER',
'TEMME',
'TEMPLETON',
'TENPENNY',
'TERRELL',
'TERRY',
'THACKER',
'THARP',
'THARPE',
'THIBEAULT',
'THIEL',
'THIENEL',
'THIER',
'THIGPEN',
'THOMAS',
'THOMPSON',
'THORNBURG',
'THORNBURGH',
'THORNHILL',
'THORPE',
'THRASHER',
'THREET',
'THRESS',
'THURMAN',
'THURMER',
'TIESLER',
'TILDEN',
'TILLERY',
'TILLEY',
'TILLMAN',
'TIMMONS',
'TINCH',
'TINDEL',
'TINDELL',
'TINO',
'TINSLEY',
'TIPTON',
'TITTLE',
'TODD',
'TOLLIVER',
'TOLMAN',
'TOLOPKA',
'TOMLINSON',
'TOOMEY',
'TORBETT',
'TOULSON',
'TOUTON',
'TOWNSEND',
'TOZZI',
'TRABOLD',
'TRAVINS',
'TRAVIS',
'TRAYNUM',
'TREADWAY',
'TRENT',
'TRENTHAM',
'TREW',
'TRIPLETT',
'TRIVETT',
'TROGLIN',
'TROTTER',
'TROUT',
'TROXEL',
'TSCHUDY',
'TSITSEKLIS',
'TUCKER',
'TUDETHUOT',
'TUGGLE',
'TULLOCK',
'TURBEVILLE',
'TURNER',
'TURPIN',
'TUSTISON',
'TUTTLE',
'TYE',
'TYRE',
'UDE',
'ULMER',
'UMLAUF',
'UMSTEAD',
'UNDERDOWN',
'UNDERWOOD',
'UPCHURCH',
'UPTON',
'URBAN',
'VALENTINE',
'VALENTINI',
'VAN CAMP',
'VAN DALEY',
'VAN ES',
'VANAUKEN',
'VANCE',
'VANDELL',
'VANDENBORRE',
'VANDERGRIFF',
'VANDERPOOLE',
'VANDERWIELE',
'VANEK',
'VANGUNDY',
'VANHOOZIER',
'VANN',
'VANOSS',
'VANVALKENBURG',
'VARGO',
'VAUGHAN',
'VAUGHN',
'VAUX',
'VAVREK',
'VAZQUEZ COLON',
'VEALS',
'VENABLE',
'VERDERESE',
'VERNON',
'VERRAN',
'VESS',
'VIAR',
'VIARS',
'VICARS',
'VILES',
'VINEYARD',
'VOGUS',
'VOILES',
'VONESH',
'VOTAW',
'VOWELL',
'WADDELL',
'WADE',
'WADSWORTH',
'WAGNER',
'WAGONER',
'WAITINAS',
'WALCH',
'WALDECK',
'WALDO',
'WALDROP',
'WALDROUP',
'WALKDEN',
'WALKER',
'WALKER ALLISON',
'WALL',
'WALLACE',
'WALLEN',
'WALLIS',
'WALLS',
'WALSH',
'WALTERS',
'WAMPLER',
'WANG',
'WARD',
'WARNER',
'WARREN',
'WARRIX',
'WARWICK',
'WASHAM',
'WASHINGTON',
'WATERHOUSE',
'WATERS',
'WATKINS',
'WATSON',
'WATT',
'WATTENBARGER',
'WEAKLEY',
'WEATHERBY',
'WEATHERFORD',
'WEATHERHEAD',
'WEATHERS',
'WEAVER',
'WEBB',
'WEBB MILLINGTON',
'WEBBER',
'WEBER',
'WEBSTER',
'WEECH',
'WEEKS',
'WEESNER',
'WEIDENBURNER',
'WEIER',
'WEIGEL',
'WEIR',
'WEISS',
'WELCH',
'WELKER',
'WELLNER',
'WELLS',
'WENRICH',
'WENZEL',
'WERNER',
'WERNTZ',
'WERRE',
'WERT',
'WEST',
'WESTERN',
'WESTMORELAND',
'WESTON',
'WEY',
'WHALEN',
'WHALEY',
'WHEAT',
'WHEATLEY',
'WHEELER',
'WHELESS',
'WHISMAN',
'WHISNANT',
'WHITAKER',
'WHITE',
'WHITEHEAD',
'WHITFIELD',
'WHITING',
'WHITLEY',
'WHITMAN',
'WHITNEY',
'WHITT',
'WHITTAKER',
'WHITTED',
'WHITTEN',
'WHITTLE',
'WHYTE',
'WICKS',
'WIELAND',
'WIEMER',
'WIGGINS',
'WILBUR',
'WILBURN',
'WILCOX',
'WILD',
'WILDER',
'WILHOITE',
'WILKE',
'WILKERSON',
'WILKEY',
'WILKIE',
'WILKINS',
'WILKINSON',
'WILLARD',
'WILLETT',
'WILLETTE',
'WILLEY',
'WILLIAMS',
'WILLIAMSEN',
'WILLIAMSON',
'WILLIFORD',
'WILLINGS',
'WILLIS',
'WILMOTH',
'WILSON',
'WIMBERLY',
'WINCH',
'WINDER',
'WINDSOR',
'WINKEL',
'WINKLE',
'WINKLER',
'WINSTEAD',
'WINSTON',
'WINTER',
'WINTON',
'WISE',
'WITCHEN',
'WITENBARGER',
'WITHERSPOON',
'WITMER',
'WITT',
'WITTIBSLAGER',
'WOCHELE',
'WOFSY',
'WOJNAROWSKI',
'WOLF',
'WOLFE',
'WOLFENBARGER',
'WOLFORD',
'WOMAC',
'WOMACK',
'WOOD',
'WOODALL',
'WOODARD',
'WOODBY',
'WOODFORD',
'WOODROW',
'WOODRUFF',
'WOODS',
'WOODWARD',
'WOODY',
'WOOLARD',
'WOOLIVER',
'WOOTTON',
'WORD',
'WORKMAN',
'WORLEY',
'WORMSLEY',
'WORTH',
'WORTHINGTON',
'WRIGHT',
'WYANT',
'WYLIE',
'WYRICK',
'YARBOROUGH',
'YARBROUGH AUTEN',
'YARDLEY',
'YARNELL',
'YASTE',
'YEAGER',
'YEARY',
'YEBOAH',
'YERKES',
'YOAKUM',
'YODER',
'YOKLEY',
'YORK',
'YOUNG',
'YOUNGBLOOD',
'YOW',
'YUSE',
'YUTZY',
'ZAAR',
'ZABEL',
'ZACHMANN',
'ZADES',
'ZANOLLI',
'ZATYKO',
'ZEIGLER',
'ZETTEL',
'ZEVENEY',
'ZHAO',
'ZICK',
'ZIEBEL',
'ZIMMER',
'ZIMMERMAN',
'ZINDLE',
'ZIOBRO',
'ZIRKLE',
'ZISMAN',
'ZOOK')
 
 
/****************************************************************************
	Populate Record Structure with Person Primary Insurance Data
*****************************************************************************/
HEAD ppr1.person_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ppr1.person_id, exp_data->list[cnt].person_id)
 
FOOT ppr1.person_id
 
	exp_data->list[idx].Pat_Primary_Ins = Pat_Primary_Ins
	exp_data->list[idx].Pat_Primary_Ins_Plan = Pat_Primary_Ins_Plan
	exp_data->list[idx].Pat_Primary_Ins_Member_Num = Pat_Primary_Ins_Member_Num
	exp_data->list[idx].Pat_Primary_Ins_Group_Num = Pat_Primary_Ins_Group_Num
	exp_data->list[idx].Pat_Primary_Ins_Policy_Num = Pat_Primary_Ins_Policy_Num
	exp_data->list[idx].Pat_Primary_Ins_Street_Addr = Pat_Primary_Ins_Street_Addr
	exp_data->list[idx].Pat_Primary_Ins_Street_Addr2 = Pat_Primary_Ins_Street_Addr2
	exp_data->list[idx].Pat_Primary_Ins_City = Pat_Primary_Ins_City
	exp_data->list[idx].Pat_Primary_Ins_State = Pat_Primary_Ins_State
	exp_data->list[idx].Pat_Primary_Ins_ZipCode = Pat_Primary_Ins_ZipCode
	exp_data->list[idx].Pat_Primary_Ins_Phone = Pat_Primary_Ins_Phone
 
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ppr1.person_id, exp_data->list[cnt].person_id)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO ("***** GETTING PERSON SECONDARY INSURANCE DATA ******")
/**************************************************************
; Get Person Secondary Insurance Data
**************************************************************/
 
SELECT DISTINCT INTO "noforms"
Person_id = ppr2.person_id
,Pat_Secondary_Ins = TRIM(org2.org_name,3)
,Pat_Secondary_Ins_Plan = TRIM(hp2.plan_name,3)
,Pat_Secondary_Ins_Member_Num = TRIM(ppr2.member_nbr,3)
,Pat_Secondary_Ins_Group_Num = TRIM(ppr2.group_nbr,3)
,Pat_Secondary_Ins_Policy_Num = TRIM(ppr2.policy_nbr,3)
,Pat_Secondary_Ins_Street_Addr = TRIM(addr2.street_addr,3)
,Pat_Secondary_Ins_Street_Addr2 = TRIM(addr2.street_addr2,3)
,Pat_Secondary_Ins_City = TRIM(addr2.city,3)
,Pat_Secondary_Ins_State = TRIM(addr2.state,3)
,Pat_Secondary_Ins_ZipCode = TRIM(addr2.zipcode,3)
,Pat_Secondary_Ins_Phone = TRIM(REPLACE(REPLACE(REPLACE(ph2.phone_num,'-',''),')',''),'(',''),3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,person_plan_reltn ppr2
	,person_plan_profile_reltn pppr2
	,person_plan_profile ppp2
	,address addr2
	,phone ph2
	,health_plan hp2
	,organization org2
	,person pat
	,encounter enc
PLAN d
JOIN ppr2 WHERE ppr2.person_id = exp_data->list[d.seq].person_id
	AND ppr2.active_ind = 1
	AND ppr2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ppr2.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN pppr2 WHERE ppr2.person_plan_reltn_id = pppr2.person_plan_reltn_id
	AND pppr2.active_ind = 1
	AND pppr2.priority_seq = 2
JOIN ppp2 WHERE pppr2.person_plan_profile_id = ppp2.person_plan_profile_id
	AND ppp2.profile_type_cd = 23838228.00 /*Health Professional*/
	AND ppp2.active_ind = 1
JOIN addr2 WHERE addr2.parent_entity_id = ppr2.person_plan_reltn_id
	AND addr2.address_type_cd = 754.00 /*Business*/
	AND addr2.active_ind = 1
	AND addr2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND addr2.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN ph2 WHERE ph2.parent_entity_id = ppr2.person_plan_reltn_id
	AND ph2.phone_type_cd = 163.00 /*Business*/
	AND ph2.active_ind = 1
	AND ph2.phone_type_seq = 1
	AND ph2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ph2.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN hp2 WHERE hp2.health_plan_id = ppr2.health_plan_id
JOIN org2 WHERE org2.organization_id = ppr2.organization_id
JOIN enc WHERE ppr2.person_id = enc.person_id
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
	AND enc.active_ind = 1
	AND enc.encntr_id = (SELECT MAX(e.encntr_id)
		FROM encounter e
		WHERE e.person_id = enc.person_id
		AND encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
		AND e.active_ind = 1)
JOIN pat WHERE ppr2.person_id = pat.person_id
AND pat.name_last_key IN ('TABBAA',
'TABOR',
'TALLENT',
'TALLEY',
'TALLMAN',
'TALLON',
'TAMOSIUNAS',
'TAMPAS',
'TANTLINGER',
'TAPLIN',
'TARWATER',
'TATE',
'TAUBE',
'TAYLOR',
'TEAGUE',
'TEDDER',
'TEFFETELLER',
'TEMME',
'TEMPLETON',
'TENPENNY',
'TERRELL',
'TERRY',
'THACKER',
'THARP',
'THARPE',
'THIBEAULT',
'THIEL',
'THIENEL',
'THIER',
'THIGPEN',
'THOMAS',
'THOMPSON',
'THORNBURG',
'THORNBURGH',
'THORNHILL',
'THORPE',
'THRASHER',
'THREET',
'THRESS',
'THURMAN',
'THURMER',
'TIESLER',
'TILDEN',
'TILLERY',
'TILLEY',
'TILLMAN',
'TIMMONS',
'TINCH',
'TINDEL',
'TINDELL',
'TINO',
'TINSLEY',
'TIPTON',
'TITTLE',
'TODD',
'TOLLIVER',
'TOLMAN',
'TOLOPKA',
'TOMLINSON',
'TOOMEY',
'TORBETT',
'TOULSON',
'TOUTON',
'TOWNSEND',
'TOZZI',
'TRABOLD',
'TRAVINS',
'TRAVIS',
'TRAYNUM',
'TREADWAY',
'TRENT',
'TRENTHAM',
'TREW',
'TRIPLETT',
'TRIVETT',
'TROGLIN',
'TROTTER',
'TROUT',
'TROXEL',
'TSCHUDY',
'TSITSEKLIS',
'TUCKER',
'TUDETHUOT',
'TUGGLE',
'TULLOCK',
'TURBEVILLE',
'TURNER',
'TURPIN',
'TUSTISON',
'TUTTLE',
'TYE',
'TYRE',
'UDE',
'ULMER',
'UMLAUF',
'UMSTEAD',
'UNDERDOWN',
'UNDERWOOD',
'UPCHURCH',
'UPTON',
'URBAN',
'VALENTINE',
'VALENTINI',
'VAN CAMP',
'VAN DALEY',
'VAN ES',
'VANAUKEN',
'VANCE',
'VANDELL',
'VANDENBORRE',
'VANDERGRIFF',
'VANDERPOOLE',
'VANDERWIELE',
'VANEK',
'VANGUNDY',
'VANHOOZIER',
'VANN',
'VANOSS',
'VANVALKENBURG',
'VARGO',
'VAUGHAN',
'VAUGHN',
'VAUX',
'VAVREK',
'VAZQUEZ COLON',
'VEALS',
'VENABLE',
'VERDERESE',
'VERNON',
'VERRAN',
'VESS',
'VIAR',
'VIARS',
'VICARS',
'VILES',
'VINEYARD',
'VOGUS',
'VOILES',
'VONESH',
'VOTAW',
'VOWELL',
'WADDELL',
'WADE',
'WADSWORTH',
'WAGNER',
'WAGONER',
'WAITINAS',
'WALCH',
'WALDECK',
'WALDO',
'WALDROP',
'WALDROUP',
'WALKDEN',
'WALKER',
'WALKER ALLISON',
'WALL',
'WALLACE',
'WALLEN',
'WALLIS',
'WALLS',
'WALSH',
'WALTERS',
'WAMPLER',
'WANG',
'WARD',
'WARNER',
'WARREN',
'WARRIX',
'WARWICK',
'WASHAM',
'WASHINGTON',
'WATERHOUSE',
'WATERS',
'WATKINS',
'WATSON',
'WATT',
'WATTENBARGER',
'WEAKLEY',
'WEATHERBY',
'WEATHERFORD',
'WEATHERHEAD',
'WEATHERS',
'WEAVER',
'WEBB',
'WEBB MILLINGTON',
'WEBBER',
'WEBER',
'WEBSTER',
'WEECH',
'WEEKS',
'WEESNER',
'WEIDENBURNER',
'WEIER',
'WEIGEL',
'WEIR',
'WEISS',
'WELCH',
'WELKER',
'WELLNER',
'WELLS',
'WENRICH',
'WENZEL',
'WERNER',
'WERNTZ',
'WERRE',
'WERT',
'WEST',
'WESTERN',
'WESTMORELAND',
'WESTON',
'WEY',
'WHALEN',
'WHALEY',
'WHEAT',
'WHEATLEY',
'WHEELER',
'WHELESS',
'WHISMAN',
'WHISNANT',
'WHITAKER',
'WHITE',
'WHITEHEAD',
'WHITFIELD',
'WHITING',
'WHITLEY',
'WHITMAN',
'WHITNEY',
'WHITT',
'WHITTAKER',
'WHITTED',
'WHITTEN',
'WHITTLE',
'WHYTE',
'WICKS',
'WIELAND',
'WIEMER',
'WIGGINS',
'WILBUR',
'WILBURN',
'WILCOX',
'WILD',
'WILDER',
'WILHOITE',
'WILKE',
'WILKERSON',
'WILKEY',
'WILKIE',
'WILKINS',
'WILKINSON',
'WILLARD',
'WILLETT',
'WILLETTE',
'WILLEY',
'WILLIAMS',
'WILLIAMSEN',
'WILLIAMSON',
'WILLIFORD',
'WILLINGS',
'WILLIS',
'WILMOTH',
'WILSON',
'WIMBERLY',
'WINCH',
'WINDER',
'WINDSOR',
'WINKEL',
'WINKLE',
'WINKLER',
'WINSTEAD',
'WINSTON',
'WINTER',
'WINTON',
'WISE',
'WITCHEN',
'WITENBARGER',
'WITHERSPOON',
'WITMER',
'WITT',
'WITTIBSLAGER',
'WOCHELE',
'WOFSY',
'WOJNAROWSKI',
'WOLF',
'WOLFE',
'WOLFENBARGER',
'WOLFORD',
'WOMAC',
'WOMACK',
'WOOD',
'WOODALL',
'WOODARD',
'WOODBY',
'WOODFORD',
'WOODROW',
'WOODRUFF',
'WOODS',
'WOODWARD',
'WOODY',
'WOOLARD',
'WOOLIVER',
'WOOTTON',
'WORD',
'WORKMAN',
'WORLEY',
'WORMSLEY',
'WORTH',
'WORTHINGTON',
'WRIGHT',
'WYANT',
'WYLIE',
'WYRICK',
'YARBOROUGH',
'YARBROUGH AUTEN',
'YARDLEY',
'YARNELL',
'YASTE',
'YEAGER',
'YEARY',
'YEBOAH',
'YERKES',
'YOAKUM',
'YODER',
'YOKLEY',
'YORK',
'YOUNG',
'YOUNGBLOOD',
'YOW',
'YUSE',
'YUTZY',
'ZAAR',
'ZABEL',
'ZACHMANN',
'ZADES',
'ZANOLLI',
'ZATYKO',
'ZEIGLER',
'ZETTEL',
'ZEVENEY',
'ZHAO',
'ZICK',
'ZIEBEL',
'ZIMMER',
'ZIMMERMAN',
'ZINDLE',
'ZIOBRO',
'ZIRKLE',
'ZISMAN',
'ZOOK')
 
 
/****************************************************************************
	Populate Record Structure with Person Secondary Insurance Data
*****************************************************************************/
HEAD ppr2.person_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ppr2.person_id, exp_data->list[cnt].person_id)
 
FOOT ppr2.person_id
 
	exp_data->list[idx].Pat_Secondary_Ins = Pat_Secondary_Ins
	exp_data->list[idx].Pat_Secondary_Ins_Plan = Pat_Secondary_Ins_Plan
	exp_data->list[idx].Pat_Secondary_Ins_Member_Num = Pat_Secondary_Ins_Member_Num
	exp_data->list[idx].Pat_Secondary_Ins_Group_Num = Pat_Secondary_Ins_Group_Num
	exp_data->list[idx].Pat_Secondary_Ins_Policy_Num = Pat_Secondary_Ins_Policy_Num
	exp_data->list[idx].Pat_Secondary_Ins_Street_Addr = Pat_Secondary_Ins_Street_Addr
	exp_data->list[idx].Pat_Secondary_Ins_Street_Addr2 = Pat_Secondary_Ins_Street_Addr2
	exp_data->list[idx].Pat_Secondary_Ins_City = Pat_Secondary_Ins_City
	exp_data->list[idx].Pat_Secondary_Ins_State = Pat_Secondary_Ins_State
	exp_data->list[idx].Pat_Secondary_Ins_ZipCode = Pat_Secondary_Ins_ZipCode
	exp_data->list[idx].Pat_Secondary_Ins_Phone = Pat_Secondary_Ins_Phone
 
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ppr2.person_id, exp_data->list[cnt].person_id)
WITH nocounter
 
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO ("***** GETTING LAST ENC PRIMARY INSURANCE DATA ******")
/**************************************************************
; Get Last Enc Primary Insurance Data
**************************************************************/
 
SELECT DISTINCT INTO "noforms"
Person_id = epr1.person_id
,Enc_Primary_Ins = TRIM(org1.org_name,3)
,Enc_Primary_Ins_Plan = TRIM(hp1.plan_name,3)
,Enc_Primary_Ins_Member_Num = TRIM(epr1.member_nbr,3)
,Enc_Primary_Ins_Group_Num = TRIM(epr1.group_nbr,3)
,Enc_Primary_Ins_Policy_Num = TRIM(epr1.policy_nbr,3)
,Enc_Primary_Ins_Street_Addr = TRIM(addr1.street_addr,3)
,Enc_Primary_Ins_Street_Addr2 = TRIM(addr1.street_addr2,3)
,Enc_Primary_Ins_City = TRIM(addr1.city,3)
,Enc_Primary_Ins_State = TRIM(addr1.state,3)
,Enc_Primary_Ins_ZipCode = TRIM(addr1.zipcode,3)
,Enc_Primary_Ins_Phone = TRIM(REPLACE(REPLACE(REPLACE(ph1.phone_num,'-',''),')',''),'(',''),3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,encounter enc
	,encntr_plan_reltn epr1
	,address addr1
	,phone ph1
	,health_plan hp1
	,organization org1
	,person pat
PLAN d
JOIN enc WHERE enc.person_id = exp_data->list[d.seq].person_id
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
	AND enc.active_ind = 1
	AND enc.encntr_id = (SELECT MAX(e.encntr_id)
		FROM encounter e
		WHERE e.person_id = enc.person_id
		AND encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
		AND e.active_ind = 1)
JOIN epr1 WHERE epr1.encntr_id = enc.encntr_id
	AND epr1.active_ind = 1
	AND epr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND epr1.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
	AND epr1.priority_seq = 1
JOIN addr1 WHERE epr1.encntr_plan_reltn_id = addr1.parent_entity_id
	AND addr1.address_type_cd = 754.00 /*Business*/
	AND addr1.active_ind = 1
	AND addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND addr1.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN ph1 WHERE epr1.person_plan_reltn_id = ph1.parent_entity_id
	AND ph1.phone_type_cd = 163.00 /*Business*/
	AND ph1.active_ind = 1
	AND ph1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ph1.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN hp1 WHERE epr1.health_plan_id = hp1.health_plan_id
JOIN org1 WHERE epr1.organization_id = org1.organization_id
JOIN pat WHERE enc.person_id = pat.person_id
AND pat.name_last_key IN ('TABBAA',
'TABOR',
'TALLENT',
'TALLEY',
'TALLMAN',
'TALLON',
'TAMOSIUNAS',
'TAMPAS',
'TANTLINGER',
'TAPLIN',
'TARWATER',
'TATE',
'TAUBE',
'TAYLOR',
'TEAGUE',
'TEDDER',
'TEFFETELLER',
'TEMME',
'TEMPLETON',
'TENPENNY',
'TERRELL',
'TERRY',
'THACKER',
'THARP',
'THARPE',
'THIBEAULT',
'THIEL',
'THIENEL',
'THIER',
'THIGPEN',
'THOMAS',
'THOMPSON',
'THORNBURG',
'THORNBURGH',
'THORNHILL',
'THORPE',
'THRASHER',
'THREET',
'THRESS',
'THURMAN',
'THURMER',
'TIESLER',
'TILDEN',
'TILLERY',
'TILLEY',
'TILLMAN',
'TIMMONS',
'TINCH',
'TINDEL',
'TINDELL',
'TINO',
'TINSLEY',
'TIPTON',
'TITTLE',
'TODD',
'TOLLIVER',
'TOLMAN',
'TOLOPKA',
'TOMLINSON',
'TOOMEY',
'TORBETT',
'TOULSON',
'TOUTON',
'TOWNSEND',
'TOZZI',
'TRABOLD',
'TRAVINS',
'TRAVIS',
'TRAYNUM',
'TREADWAY',
'TRENT',
'TRENTHAM',
'TREW',
'TRIPLETT',
'TRIVETT',
'TROGLIN',
'TROTTER',
'TROUT',
'TROXEL',
'TSCHUDY',
'TSITSEKLIS',
'TUCKER',
'TUDETHUOT',
'TUGGLE',
'TULLOCK',
'TURBEVILLE',
'TURNER',
'TURPIN',
'TUSTISON',
'TUTTLE',
'TYE',
'TYRE',
'UDE',
'ULMER',
'UMLAUF',
'UMSTEAD',
'UNDERDOWN',
'UNDERWOOD',
'UPCHURCH',
'UPTON',
'URBAN',
'VALENTINE',
'VALENTINI',
'VAN CAMP',
'VAN DALEY',
'VAN ES',
'VANAUKEN',
'VANCE',
'VANDELL',
'VANDENBORRE',
'VANDERGRIFF',
'VANDERPOOLE',
'VANDERWIELE',
'VANEK',
'VANGUNDY',
'VANHOOZIER',
'VANN',
'VANOSS',
'VANVALKENBURG',
'VARGO',
'VAUGHAN',
'VAUGHN',
'VAUX',
'VAVREK',
'VAZQUEZ COLON',
'VEALS',
'VENABLE',
'VERDERESE',
'VERNON',
'VERRAN',
'VESS',
'VIAR',
'VIARS',
'VICARS',
'VILES',
'VINEYARD',
'VOGUS',
'VOILES',
'VONESH',
'VOTAW',
'VOWELL',
'WADDELL',
'WADE',
'WADSWORTH',
'WAGNER',
'WAGONER',
'WAITINAS',
'WALCH',
'WALDECK',
'WALDO',
'WALDROP',
'WALDROUP',
'WALKDEN',
'WALKER',
'WALKER ALLISON',
'WALL',
'WALLACE',
'WALLEN',
'WALLIS',
'WALLS',
'WALSH',
'WALTERS',
'WAMPLER',
'WANG',
'WARD',
'WARNER',
'WARREN',
'WARRIX',
'WARWICK',
'WASHAM',
'WASHINGTON',
'WATERHOUSE',
'WATERS',
'WATKINS',
'WATSON',
'WATT',
'WATTENBARGER',
'WEAKLEY',
'WEATHERBY',
'WEATHERFORD',
'WEATHERHEAD',
'WEATHERS',
'WEAVER',
'WEBB',
'WEBB MILLINGTON',
'WEBBER',
'WEBER',
'WEBSTER',
'WEECH',
'WEEKS',
'WEESNER',
'WEIDENBURNER',
'WEIER',
'WEIGEL',
'WEIR',
'WEISS',
'WELCH',
'WELKER',
'WELLNER',
'WELLS',
'WENRICH',
'WENZEL',
'WERNER',
'WERNTZ',
'WERRE',
'WERT',
'WEST',
'WESTERN',
'WESTMORELAND',
'WESTON',
'WEY',
'WHALEN',
'WHALEY',
'WHEAT',
'WHEATLEY',
'WHEELER',
'WHELESS',
'WHISMAN',
'WHISNANT',
'WHITAKER',
'WHITE',
'WHITEHEAD',
'WHITFIELD',
'WHITING',
'WHITLEY',
'WHITMAN',
'WHITNEY',
'WHITT',
'WHITTAKER',
'WHITTED',
'WHITTEN',
'WHITTLE',
'WHYTE',
'WICKS',
'WIELAND',
'WIEMER',
'WIGGINS',
'WILBUR',
'WILBURN',
'WILCOX',
'WILD',
'WILDER',
'WILHOITE',
'WILKE',
'WILKERSON',
'WILKEY',
'WILKIE',
'WILKINS',
'WILKINSON',
'WILLARD',
'WILLETT',
'WILLETTE',
'WILLEY',
'WILLIAMS',
'WILLIAMSEN',
'WILLIAMSON',
'WILLIFORD',
'WILLINGS',
'WILLIS',
'WILMOTH',
'WILSON',
'WIMBERLY',
'WINCH',
'WINDER',
'WINDSOR',
'WINKEL',
'WINKLE',
'WINKLER',
'WINSTEAD',
'WINSTON',
'WINTER',
'WINTON',
'WISE',
'WITCHEN',
'WITENBARGER',
'WITHERSPOON',
'WITMER',
'WITT',
'WITTIBSLAGER',
'WOCHELE',
'WOFSY',
'WOJNAROWSKI',
'WOLF',
'WOLFE',
'WOLFENBARGER',
'WOLFORD',
'WOMAC',
'WOMACK',
'WOOD',
'WOODALL',
'WOODARD',
'WOODBY',
'WOODFORD',
'WOODROW',
'WOODRUFF',
'WOODS',
'WOODWARD',
'WOODY',
'WOOLARD',
'WOOLIVER',
'WOOTTON',
'WORD',
'WORKMAN',
'WORLEY',
'WORMSLEY',
'WORTH',
'WORTHINGTON',
'WRIGHT',
'WYANT',
'WYLIE',
'WYRICK',
'YARBOROUGH',
'YARBROUGH AUTEN',
'YARDLEY',
'YARNELL',
'YASTE',
'YEAGER',
'YEARY',
'YEBOAH',
'YERKES',
'YOAKUM',
'YODER',
'YOKLEY',
'YORK',
'YOUNG',
'YOUNGBLOOD',
'YOW',
'YUSE',
'YUTZY',
'ZAAR',
'ZABEL',
'ZACHMANN',
'ZADES',
'ZANOLLI',
'ZATYKO',
'ZEIGLER',
'ZETTEL',
'ZEVENEY',
'ZHAO',
'ZICK',
'ZIEBEL',
'ZIMMER',
'ZIMMERMAN',
'ZINDLE',
'ZIOBRO',
'ZIRKLE',
'ZISMAN',
'ZOOK')
 
/****************************************************************************
	Populate Record Structure with Last Enc Primary Insurance Data
*****************************************************************************/
HEAD epr1.person_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),epr1.person_id, exp_data->list[cnt].person_id)
 
FOOT epr1.person_id
 
	exp_data->list[idx].Enc_Primary_Ins = Enc_Primary_Ins
	exp_data->list[idx].Enc_Primary_Ins_Plan = Enc_Primary_Ins_Plan
	exp_data->list[idx].Enc_Primary_Ins_Member_Num = Enc_Primary_Ins_Member_Num
	exp_data->list[idx].Enc_Primary_Ins_Group_Num = Enc_Primary_Ins_Group_Num
	exp_data->list[idx].Enc_Primary_Ins_Policy_Num = Enc_Primary_Ins_Policy_Num
	exp_data->list[idx].Enc_Primary_Ins_Street_Addr = Enc_Primary_Ins_Street_Addr
	exp_data->list[idx].Enc_Primary_Ins_Street_Addr2 = Enc_Primary_Ins_Street_Addr2
	exp_data->list[idx].Enc_Primary_Ins_City = Enc_Primary_Ins_City
	exp_data->list[idx].Enc_Primary_Ins_State = Enc_Primary_Ins_State
	exp_data->list[idx].Enc_Primary_Ins_ZipCode = Enc_Primary_Ins_ZipCode
	exp_data->list[idx].Enc_Primary_Ins_Phone = Enc_Primary_Ins_Phone
 
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),epr1.person_id, exp_data->list[cnt].person_id)
WITH nocounter
 
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO ("***** GETTING LAST ENC SECONDARY INSURANCE DATA ******")
/**************************************************************
; Get Last Enc Secondary Insurance Data
**************************************************************/
 
SELECT DISTINCT INTO "noforms"
Person_id = epr2.person_id
,Enc_Secondary_Ins = TRIM(org2.org_name,3)
,Enc_Secondary_Ins_Plan = TRIM(hp2.plan_name,3)
,Enc_Secondary_Ins_Member_Num = TRIM(epr2.member_nbr,3)
,Enc_Secondary_Ins_Group_Num = TRIM(epr2.group_nbr,3)
,Enc_Secondary_Ins_Policy_Num = TRIM(epr2.policy_nbr,3)
,Enc_Secondary_Ins_Street_Addr = TRIM(addr2.street_addr,3)
,Enc_Secondary_Ins_Street_Addr2 = TRIM(addr2.street_addr2,3)
,Enc_Secondary_Ins_City = TRIM(addr2.city,3)
,Enc_Secondary_Ins_State = TRIM(addr2.state,3)
,Enc_Secondary_Ins_ZipCode = TRIM(addr2.zipcode,3)
,Enc_Secondary_Ins_Phone = TRIM(REPLACE(REPLACE(REPLACE(ph2.phone_num,'-',''),')',''),'(',''),3)
FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
	,encounter enc
	,encntr_plan_reltn epr2
	,address addr2
	,phone ph2
	,health_plan hp2
	,organization org2
	,person pat
PLAN d
JOIN enc WHERE enc.person_id = exp_data->list[d.seq].person_id
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
	AND enc.active_ind = 1
	AND enc.encntr_id = (SELECT MAX(e.encntr_id)
		FROM encounter e
		WHERE e.person_id = enc.person_id
		AND encntr_type_cd IN (22282402 /*Clinic*/,
		20058643.00 /*Legacy_Data-Historical*/)
		AND e.active_ind = 1)
JOIN epr2 WHERE epr2.encntr_id = enc.encntr_id
	AND epr2.active_ind = 1
	AND epr2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND epr2.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
	AND epr2.priority_seq = 2
JOIN addr2 WHERE addr2.parent_entity_id = epr2.encntr_plan_reltn_id
	AND addr2.address_type_cd = 754.00 /*Business*/
	AND addr2.active_ind = 1
	AND addr2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND addr2.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN ph2 WHERE ph2.parent_entity_id = epr2.person_plan_reltn_id
	AND ph2.phone_type_cd = 163.00 /*Business*/
	AND ph2.active_ind = 1
	AND ph2.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ph2.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
JOIN hp2 WHERE hp2.health_plan_id = epr2.health_plan_id
JOIN org2 WHERE org2.organization_id = epr2.organization_id
JOIN pat WHERE enc.person_id = pat.person_id
AND pat.name_last_key IN ('TABBAA',
'TABOR',
'TALLENT',
'TALLEY',
'TALLMAN',
'TALLON',
'TAMOSIUNAS',
'TAMPAS',
'TANTLINGER',
'TAPLIN',
'TARWATER',
'TATE',
'TAUBE',
'TAYLOR',
'TEAGUE',
'TEDDER',
'TEFFETELLER',
'TEMME',
'TEMPLETON',
'TENPENNY',
'TERRELL',
'TERRY',
'THACKER',
'THARP',
'THARPE',
'THIBEAULT',
'THIEL',
'THIENEL',
'THIER',
'THIGPEN',
'THOMAS',
'THOMPSON',
'THORNBURG',
'THORNBURGH',
'THORNHILL',
'THORPE',
'THRASHER',
'THREET',
'THRESS',
'THURMAN',
'THURMER',
'TIESLER',
'TILDEN',
'TILLERY',
'TILLEY',
'TILLMAN',
'TIMMONS',
'TINCH',
'TINDEL',
'TINDELL',
'TINO',
'TINSLEY',
'TIPTON',
'TITTLE',
'TODD',
'TOLLIVER',
'TOLMAN',
'TOLOPKA',
'TOMLINSON',
'TOOMEY',
'TORBETT',
'TOULSON',
'TOUTON',
'TOWNSEND',
'TOZZI',
'TRABOLD',
'TRAVINS',
'TRAVIS',
'TRAYNUM',
'TREADWAY',
'TRENT',
'TRENTHAM',
'TREW',
'TRIPLETT',
'TRIVETT',
'TROGLIN',
'TROTTER',
'TROUT',
'TROXEL',
'TSCHUDY',
'TSITSEKLIS',
'TUCKER',
'TUDETHUOT',
'TUGGLE',
'TULLOCK',
'TURBEVILLE',
'TURNER',
'TURPIN',
'TUSTISON',
'TUTTLE',
'TYE',
'TYRE',
'UDE',
'ULMER',
'UMLAUF',
'UMSTEAD',
'UNDERDOWN',
'UNDERWOOD',
'UPCHURCH',
'UPTON',
'URBAN',
'VALENTINE',
'VALENTINI',
'VAN CAMP',
'VAN DALEY',
'VAN ES',
'VANAUKEN',
'VANCE',
'VANDELL',
'VANDENBORRE',
'VANDERGRIFF',
'VANDERPOOLE',
'VANDERWIELE',
'VANEK',
'VANGUNDY',
'VANHOOZIER',
'VANN',
'VANOSS',
'VANVALKENBURG',
'VARGO',
'VAUGHAN',
'VAUGHN',
'VAUX',
'VAVREK',
'VAZQUEZ COLON',
'VEALS',
'VENABLE',
'VERDERESE',
'VERNON',
'VERRAN',
'VESS',
'VIAR',
'VIARS',
'VICARS',
'VILES',
'VINEYARD',
'VOGUS',
'VOILES',
'VONESH',
'VOTAW',
'VOWELL',
'WADDELL',
'WADE',
'WADSWORTH',
'WAGNER',
'WAGONER',
'WAITINAS',
'WALCH',
'WALDECK',
'WALDO',
'WALDROP',
'WALDROUP',
'WALKDEN',
'WALKER',
'WALKER ALLISON',
'WALL',
'WALLACE',
'WALLEN',
'WALLIS',
'WALLS',
'WALSH',
'WALTERS',
'WAMPLER',
'WANG',
'WARD',
'WARNER',
'WARREN',
'WARRIX',
'WARWICK',
'WASHAM',
'WASHINGTON',
'WATERHOUSE',
'WATERS',
'WATKINS',
'WATSON',
'WATT',
'WATTENBARGER',
'WEAKLEY',
'WEATHERBY',
'WEATHERFORD',
'WEATHERHEAD',
'WEATHERS',
'WEAVER',
'WEBB',
'WEBB MILLINGTON',
'WEBBER',
'WEBER',
'WEBSTER',
'WEECH',
'WEEKS',
'WEESNER',
'WEIDENBURNER',
'WEIER',
'WEIGEL',
'WEIR',
'WEISS',
'WELCH',
'WELKER',
'WELLNER',
'WELLS',
'WENRICH',
'WENZEL',
'WERNER',
'WERNTZ',
'WERRE',
'WERT',
'WEST',
'WESTERN',
'WESTMORELAND',
'WESTON',
'WEY',
'WHALEN',
'WHALEY',
'WHEAT',
'WHEATLEY',
'WHEELER',
'WHELESS',
'WHISMAN',
'WHISNANT',
'WHITAKER',
'WHITE',
'WHITEHEAD',
'WHITFIELD',
'WHITING',
'WHITLEY',
'WHITMAN',
'WHITNEY',
'WHITT',
'WHITTAKER',
'WHITTED',
'WHITTEN',
'WHITTLE',
'WHYTE',
'WICKS',
'WIELAND',
'WIEMER',
'WIGGINS',
'WILBUR',
'WILBURN',
'WILCOX',
'WILD',
'WILDER',
'WILHOITE',
'WILKE',
'WILKERSON',
'WILKEY',
'WILKIE',
'WILKINS',
'WILKINSON',
'WILLARD',
'WILLETT',
'WILLETTE',
'WILLEY',
'WILLIAMS',
'WILLIAMSEN',
'WILLIAMSON',
'WILLIFORD',
'WILLINGS',
'WILLIS',
'WILMOTH',
'WILSON',
'WIMBERLY',
'WINCH',
'WINDER',
'WINDSOR',
'WINKEL',
'WINKLE',
'WINKLER',
'WINSTEAD',
'WINSTON',
'WINTER',
'WINTON',
'WISE',
'WITCHEN',
'WITENBARGER',
'WITHERSPOON',
'WITMER',
'WITT',
'WITTIBSLAGER',
'WOCHELE',
'WOFSY',
'WOJNAROWSKI',
'WOLF',
'WOLFE',
'WOLFENBARGER',
'WOLFORD',
'WOMAC',
'WOMACK',
'WOOD',
'WOODALL',
'WOODARD',
'WOODBY',
'WOODFORD',
'WOODROW',
'WOODRUFF',
'WOODS',
'WOODWARD',
'WOODY',
'WOOLARD',
'WOOLIVER',
'WOOTTON',
'WORD',
'WORKMAN',
'WORLEY',
'WORMSLEY',
'WORTH',
'WORTHINGTON',
'WRIGHT',
'WYANT',
'WYLIE',
'WYRICK',
'YARBOROUGH',
'YARBROUGH AUTEN',
'YARDLEY',
'YARNELL',
'YASTE',
'YEAGER',
'YEARY',
'YEBOAH',
'YERKES',
'YOAKUM',
'YODER',
'YOKLEY',
'YORK',
'YOUNG',
'YOUNGBLOOD',
'YOW',
'YUSE',
'YUTZY',
'ZAAR',
'ZABEL',
'ZACHMANN',
'ZADES',
'ZANOLLI',
'ZATYKO',
'ZEIGLER',
'ZETTEL',
'ZEVENEY',
'ZHAO',
'ZICK',
'ZIEBEL',
'ZIMMER',
'ZIMMERMAN',
'ZINDLE',
'ZIOBRO',
'ZIRKLE',
'ZISMAN',
'ZOOK')
 
/****************************************************************************
	Populate Record Structure with Last Enc Secondary Insurance Data
*****************************************************************************/
HEAD epr2.person_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),epr2.person_id, exp_data->list[cnt].person_id)
 
FOOT epr2.person_id
 
	exp_data->list[idx].Enc_Secondary_Ins = Enc_Secondary_Ins
	exp_data->list[idx].Enc_Secondary_Ins_Plan = Enc_Secondary_Ins_Plan
	exp_data->list[idx].Enc_Secondary_Ins_Member_Num = Enc_Secondary_Ins_Member_Num
	exp_data->list[idx].Enc_Secondary_Ins_Group_Num = Enc_Secondary_Ins_Group_Num
	exp_data->list[idx].Enc_Secondary_Ins_Policy_Num = Enc_Secondary_Ins_Policy_Num
	exp_data->list[idx].Enc_Secondary_Ins_Street_Addr = Enc_Secondary_Ins_Street_Addr
	exp_data->list[idx].Enc_Secondary_Ins_Street_Addr2 = Enc_Secondary_Ins_Street_Addr2
	exp_data->list[idx].Enc_Secondary_Ins_City = Enc_Secondary_Ins_City
	exp_data->list[idx].Enc_Secondary_Ins_State = Enc_Secondary_Ins_State
	exp_data->list[idx].Enc_Secondary_Ins_ZipCode = Enc_Secondary_Ins_ZipCode
	exp_data->list[idx].Enc_Secondary_Ins_Phone = Enc_Secondary_Ins_Phone
 
	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),epr2.person_id, exp_data->list[cnt].person_id)
WITH nocounter
 
;CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
;CALL ECHO ("***** GETTING MEDICATION 1 ANTIARRHYTHMIC DATA ******")
;/**************************************************************
; Get Medication 1 Antiarrhythmic Data
;**************************************************************/
;
;SELECT DISTINCT
;Person_id = ord.person_id
;,Medication1 = TRIM(UAR_GET_CODE_DISPLAY(ord.catalog_cd),3)
;,Med1_Category1 = TRIM(dc1.category_name,3)
;,Med1_Category2 = TRIM(dc2.category_name,3)
;,Med1_Category3 = TRIM(dc3.category_name,3)
;FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
;	,orders ord
;	,order_action oa
;	,encounter enc
;	,mltm_drug_categories dc1
;	,mltm_category_sub_xref dcs1
;	,mltm_drug_categories dc2
;	,mltm_category_sub_xref dcs2
;	,mltm_drug_categories dc3
;	,mltm_category_drug_xref mcdx
;PLAN d
;JOIN ord WHERE ord.person_id = exp_data->list[d.seq].person_id
;	AND ord.activity_type_cd = 705.00 /*Pharmacy*/
;	AND ord.order_status_cd = 2550.00 /*Ordered*/
;	AND ord.order_id IN (SELECT MAX(o.order_id)
;		FROM orders o
;		,(INNER JOIN mltm_drug_categories dc1 ON (NOT(EXISTS((SELECT mcsx.multum_category_id FROM mltm_category_sub_xref mcsx
;			WHERE mcsx.sub_category_id = dc1.multum_category_id)))
;		))
;		,(INNER JOIN mltm_category_sub_xref dcs1 ON (dcs1.multum_category_id = dc1.multum_category_id
;		))
;		,(INNER JOIN mltm_drug_categories dc2 ON (dc2.multum_category_id = dcs1.sub_category_id
;			AND dc2.multum_category_id IN (46 /*antiarrhythmic agents*/)
;		))
;		,(INNER JOIN mltm_category_sub_xref dcs2 ON (dcs2.multum_category_id = dc2.multum_category_id
;		))
;		,(INNER JOIN mltm_drug_categories dc3 ON (dc3.multum_category_id = dcs2.sub_category_id
;		))
;		,(INNER JOIN mltm_category_drug_xref mcdx ON ((mcdx.multum_category_id = dc1.multum_category_id
;			OR mcdx.multum_category_id = dc2.multum_category_id
;			OR mcdx.multum_category_id = dc3.multum_category_id)
;			AND mcdx.drug_identifier = TRIM(SUBSTRING(FINDSTRING("!",o.cki)+1,TEXTLEN(o.cki),o.cki),3)
;		))
;		WHERE o.activity_type_cd = 705.00 /*Pharmacy*/
;		AND o.person_id = ord.person_id
;		)
;JOIN oa WHERE oa.order_id = ord.order_id
;	AND oa.action_type_cd = 2534 /*Order*/
;JOIN enc WHERE ord.encntr_id = enc.encntr_id
;	AND enc.encntr_type_cd = 22282402.00 /*Clinic*/
;	AND enc.active_ind = 1
;	AND enc.loc_facility_cd IN ( 2553454889.00, 2553028365.00, 2553028415.00, 2553454689.00, 2553454705.00, 2553028245.00,
;		 2553028275.00, 2557509303.00, 2557509379.00, 2562474765.00, 2568267787.00, 3100887697.00, 3418097693.00, 3418099801.00)
;JOIN dc1 WHERE NOT(EXISTS((SELECT mcsx.multum_category_id FROM mltm_category_sub_xref mcsx
;	WHERE mcsx.sub_category_id = dc1.multum_category_id)))
;JOIN dcs1 WHERE dcs1.multum_category_id = dc1.multum_category_id
;JOIN dc2 WHERE dc2.multum_category_id = dcs1.sub_category_id
;	AND dc2.multum_category_id IN (46 /*antiarrhythmic agents*/)
;JOIN dcs2 WHERE dcs2.multum_category_id = dc2.multum_category_id
;JOIN dc3 WHERE dc3.multum_category_id = dcs2.sub_category_id
;JOIN mcdx WHERE (mcdx.multum_category_id = dc1.multum_category_id
;	OR mcdx.multum_category_id = dc2.multum_category_id
;	OR mcdx.multum_category_id = dc3.multum_category_id)
;	AND mcdx.drug_identifier = TRIM(SUBSTRING(FINDSTRING("!",ord.cki)+1,TEXTLEN(ord.cki),ord.cki),3)
 
;/****************************************************************************
;	Populate Record Structure with Medicaton 1 Antiarrhythmic Data
;*****************************************************************************/
;HEAD ord.person_id
; 	cnt = 0
;	idx = 0
;	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.person_id, exp_data->list[cnt].person_id)
;
;FOOT ord.person_id
;
;	exp_data->list[idx].Medication1 = Medication1
;	exp_data->list[idx].Med1_Category1 = Med1_Category1
;	exp_data->list[idx].Med1_Category2 = Med1_Category2
;	exp_data->list[idx].Med1_Category3 = Med1_Category3
;
;	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.person_id, exp_data->list[cnt].person_id)
;WITH nocounter
;
;CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
;CALL ECHO ("***** GETTING MEDICATION 2 ANTICOAGULANTS DATA ******")
;/**************************************************************
;; Get Medication 2 Anticoagulants Data
;**************************************************************/
;
;SELECT DISTINCT
;Person_id = ord.person_id
;,Medication2 = TRIM(UAR_GET_CODE_DISPLAY(ord.catalog_cd),3)
;,Med2_Category1 = TRIM(dc1.category_name,3)
;,Med2_Category2 = TRIM(dc2.category_name,3)
;,Med2_Category3 = TRIM(dc3.category_name,3)
;FROM (dummyt d WITH seq = VALUE(SIZE(exp_data->list,5)))
;	,orders ord
;	,order_action oa
;	,encounter enc
;	,mltm_drug_categories dc1
;	,mltm_category_sub_xref dcs1
;	,mltm_drug_categories dc2
;	,mltm_category_sub_xref dcs2
;	,mltm_drug_categories dc3
;	,mltm_category_drug_xref mcdx
;PLAN d
;JOIN ord WHERE ord.person_id = exp_data->list[d.seq].person_id
;	AND ord.activity_type_cd = 705.00 /*Pharmacy*/
;	AND ord.order_status_cd = 2550.00 /*Ordered*/
;	AND ord.order_id IN (SELECT MAX(o.order_id)
;		FROM orders o
;		,(INNER JOIN mltm_drug_categories dc1 ON (NOT(EXISTS((SELECT mcsx.multum_category_id FROM mltm_category_sub_xref mcsx
;			WHERE mcsx.sub_category_id = dc1.multum_category_id)))
;		))
;		,(INNER JOIN mltm_category_sub_xref dcs1 ON (dcs1.multum_category_id = dc1.multum_category_id
;		))
;		,(INNER JOIN mltm_drug_categories dc2 ON (dc2.multum_category_id = dcs1.sub_category_id
;			AND dc2.multum_category_id IN (488 /*anticoagulant reversal agents*/,82 /*anticoagulants*/)
;		))
;		,(INNER JOIN mltm_category_sub_xref dcs2 ON (dcs2.multum_category_id = dc2.multum_category_id
;		))
;		,(INNER JOIN mltm_drug_categories dc3 ON (dc3.multum_category_id = dcs2.sub_category_id
;		))
;		,(INNER JOIN mltm_category_drug_xref mcdx ON ((mcdx.multum_category_id = dc1.multum_category_id
;			OR mcdx.multum_category_id = dc2.multum_category_id
;			OR mcdx.multum_category_id = dc3.multum_category_id)
;			AND mcdx.drug_identifier = TRIM(SUBSTRING(FINDSTRING("!",o.cki)+1,TEXTLEN(o.cki),o.cki),3)
;		))
;		WHERE o.activity_type_cd = 705.00 /*Pharmacy*/
;		AND o.person_id = ord.person_id
;		)
;JOIN oa WHERE oa.order_id = ord.order_id
;	AND oa.action_type_cd = 2534 /*Order*/
;JOIN enc WHERE ord.encntr_id = enc.encntr_id
;	AND enc.encntr_type_cd = 22282402.00 /*Clinic*/
;	AND enc.active_ind = 1
;	AND enc.loc_facility_cd IN ( 2553454889.00, 2553028365.00, 2553028415.00, 2553454689.00, 2553454705.00, 2553028245.00,
;		 2553028275.00, 2557509303.00, 2557509379.00, 2562474765.00, 2568267787.00, 3100887697.00, 3418097693.00, 3418099801.00)
;JOIN dc1 WHERE NOT(EXISTS((SELECT mcsx.multum_category_id FROM mltm_category_sub_xref mcsx
;	WHERE mcsx.sub_category_id = dc1.multum_category_id)))
;JOIN dcs1 WHERE dcs1.multum_category_id = dc1.multum_category_id
;JOIN dc2 WHERE dc2.multum_category_id = dcs1.sub_category_id
;	AND dc2.multum_category_id IN (488 /*anticoagulant reversal agents*/,82 /*anticoagulants*/)
;JOIN dcs2 WHERE dcs2.multum_category_id = dc2.multum_category_id
;JOIN dc3 WHERE dc3.multum_category_id = dcs2.sub_category_id
;JOIN mcdx WHERE (mcdx.multum_category_id = dc1.multum_category_id
;	OR mcdx.multum_category_id = dc2.multum_category_id
;	OR mcdx.multum_category_id = dc3.multum_category_id)
;	AND mcdx.drug_identifier = TRIM(SUBSTRING(FINDSTRING("!",ord.cki)+1,TEXTLEN(ord.cki),ord.cki),3)
;
;/****************************************************************************
;	Populate Record Structure with Medicaton 2 Anticoagulants Data
;*****************************************************************************/
;HEAD ord.person_id
; 	cnt = 0
;	idx = 0
;	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.person_id, exp_data->list[cnt].person_id)
;
;FOOT ord.person_id
;
;	exp_data->list[idx].Medication2 = Medication2
;	exp_data->list[idx].Med2_Category1 = Med2_Category1
;	exp_data->list[idx].Med2_Category2 = Med2_Category2
;	exp_data->list[idx].Med2_Category3 = Med2_Category3
;
;	idx = LOCATEVAL(cnt,1,SIZE(exp_data->list,5),ord.person_id, exp_data->list[cnt].person_id)
;WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(exp_data->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output
*****************************************************************************/
 
IF (exp_data->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	;ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("Patient", cov_pipe,
						"Patient_Last", cov_pipe,
						"Patient_First", cov_pipe,
						"Patient_Middle", cov_pipe,
						"DOB", cov_pipe,
						"Deceased", cov_pipe,
						"Deceased_Date", cov_pipe,
						"SSN", cov_pipe,
						"CMRN", cov_pipe,
						"Person_Id", cov_pipe,
						"Address_1", cov_pipe,
						"Address_2", cov_pipe,
						"City", cov_pipe,
						"State", cov_pipe,
						"Zip", cov_pipe,
						"Country", cov_pipe,
						"Ethnicity", cov_pipe,
						"Is_Hispanic", cov_pipe,
						"Email", cov_pipe,
						"Home_Phone", cov_pipe,
						"Mobile_Phone", cov_pipe,
						"Work_Phone", cov_pipe,
						"Gender", cov_pipe,
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
						"Pat_Primary_Ins", cov_pipe,
						"Pat_Primary_Ins_Plan", cov_pipe,
						"Pat_Primary_Ins_Member_Num", cov_pipe,
						"Pat_Primary_Ins_Group_Num", cov_pipe,
						"Pat_Primary_Ins_Policy_Num", cov_pipe,
						"Pat_Primary_Ins_Street_Addr", cov_pipe,
						"Pat_Primary_Ins_Street_Addr2", cov_pipe,
						"Pat_Primary_Ins_City", cov_pipe,
						"Pat_Primary_Ins_State", cov_pipe,
						"Pat_Primary_Ins_ZipCode", cov_pipe,
						"Pat_Primary_Ins_Phone", cov_pipe,
						"Pat_Secondary_Ins", cov_pipe,
						"Pat_Secondary_Ins_Plan", cov_pipe,
						"Pat_Secondary_Ins_Member_Num", cov_pipe,
						"Pat_Secondary_Ins_Group_Num", cov_pipe,
						"Pat_Secondary_Ins_Policy_Num", cov_pipe,
						"Pat_Secondary_Ins_Street_Addr", cov_pipe,
						"Pat_Secondary_Ins_Street_Addr2", cov_pipe,
						"Pat_Secondary_Ins_City", cov_pipe,
						"Pat_Secondary_Ins_State", cov_pipe,
						"Pat_Secondary_Ins_ZipCode", cov_pipe,
						"Pat_Secondary_Ins_Phone", cov_pipe,
						"Enc_Primary_Ins", cov_pipe,
						"Enc_Primary_Ins_Plan", cov_pipe,
						"Enc_Primary_Ins_Member_Num", cov_pipe,
						"Enc_Primary_Ins_Group_Num", cov_pipe,
						"Enc_Primary_Ins_Policy_Num", cov_pipe,
						"Enc_Primary_Ins_Phone", cov_pipe,
						"Enc_Primary_Ins_Street_Addr", cov_pipe,
						"Enc_Primary_Ins_Street_Addr2", cov_pipe,
						"Enc_Primary_Ins_City", cov_pipe,
						"Enc_Primary_Ins_State", cov_pipe,
						"Enc_Primary_Ins_ZipCode", cov_pipe,
						"Enc_Secondary_Ins", cov_pipe,
						"Enc_Secondary_Ins_Plan", cov_pipe,
						"Enc_Secondary_Ins_Member_Num", cov_pipe,
						"Enc_Secondary_Ins_Group_Num", cov_pipe,
						"Enc_Secondary_Ins_Policy_Num", cov_pipe,
						"Enc_Secondary_Ins_Phone", cov_pipe,
						"Enc_Secondary_Ins_Street_Addr", cov_pipe,
						"Enc_Secondary_Ins_Street_Addr2", cov_pipe,
						"Enc_Secondary_Ins_City", cov_pipe,
						"Enc_Secondary_Ins_State", cov_pipe,
						"Enc_Secondary_Ins_ZipCode", cov_pipe,
						"Medication1", cov_pipe,
						"Med1_Category1", cov_pipe,
						"Med1_Category2", cov_pipe,
						"Med1_Category3", cov_pipe,
						"Medication2", cov_pipe,
						"Med2_Category1", cov_pipe,
						"Med2_Category2", cov_pipe,
						"Med2_Category3")
 
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
						exp_data->list[dt.seq].Deceased, cov_pipe,
						exp_data->list[dt.seq].Deceased_Date, cov_pipe,
						exp_data->list[dt.seq].SSN, cov_pipe,
						exp_data->list[dt.seq].CMRN, cov_pipe,
						REPLACE(CNVTSTRING(exp_data->list[dt.seq].Person_id),".00",""), cov_pipe,
						exp_data->list[dt.seq].Address_1, cov_pipe,
						exp_data->list[dt.seq].Address_2, cov_pipe,
						exp_data->list[dt.seq].City, cov_pipe,
						exp_data->list[dt.seq].State, cov_pipe,
						exp_data->list[dt.seq].Zip, cov_pipe,
						exp_data->list[dt.seq].Country, cov_pipe,
						exp_data->list[dt.seq].Ethnicity, cov_pipe,
						exp_data->list[dt.seq].Is_Hispanic, cov_pipe,
						exp_data->list[dt.seq].Email, cov_pipe,
						exp_data->list[dt.seq].Home_Phone, cov_pipe,
						exp_data->list[dt.seq].Mobile_Phone, cov_pipe,
						exp_data->list[dt.seq].Work_Phone, cov_pipe,
						exp_data->list[dt.seq].Gender, cov_pipe,
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
						exp_data->list[dt.seq].Pat_Primary_Ins, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Plan, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Member_Num, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Group_Num, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Policy_Num, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Street_Addr, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Street_Addr2, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_City, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_State, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_ZipCode, cov_pipe,
						exp_data->list[dt.seq].Pat_Primary_Ins_Phone, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Plan, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Member_Num, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Group_Num, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Policy_Num, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Street_Addr, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Street_Addr2, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_City, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_State, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_ZipCode, cov_pipe,
						exp_data->list[dt.seq].Pat_Secondary_Ins_Phone, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Plan, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Member_Num, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Group_Num, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Policy_Num, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Phone, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Street_Addr, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_Street_Addr2, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_City, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_State, cov_pipe,
						exp_data->list[dt.seq].Enc_Primary_Ins_ZipCode, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Plan, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Member_Num, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Group_Num, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Policy_Num, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Phone, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Street_Addr, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_Street_Addr2, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_City, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_State, cov_pipe,
						exp_data->list[dt.seq].Enc_Secondary_Ins_ZipCode, cov_pipe,
						exp_data->list[dt.seq].Medication1, cov_pipe,
						exp_data->list[dt.seq].Med1_Category1, cov_pipe,
						exp_data->list[dt.seq].Med1_Category2, cov_pipe,
						exp_data->list[dt.seq].Med1_Category3, cov_pipe,
						exp_data->list[dt.seq].Medication2, cov_pipe,
						exp_data->list[dt.seq].Med2_Category1, cov_pipe,
						exp_data->list[dt.seq].Med2_Category2, cov_pipe,
						exp_data->list[dt.seq].Med2_Category3)
 
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
						"Deceased", cov_pipe,
						"Deceased_Date", cov_pipe,
						"SSN", cov_pipe,
						"CMRN", cov_pipe,
						"Person_Id", cov_pipe,
						"Address_1", cov_pipe,
						"Address_2", cov_pipe,
						"City", cov_pipe,
						"State", cov_pipe,
						"Zip", cov_pipe,
						"Country", cov_pipe,
						"Ethnicity", cov_pipe,
						"Is_Hispanic", cov_pipe,
						"Email", cov_pipe,
						"Email", cov_pipe,
						"Home_Phone", cov_pipe,
						"Mobile_Phone", cov_pipe,
						"Work_Phone", cov_pipe,
						"Gender", cov_pipe,
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
						"Pat_Primary_Ins", cov_pipe,
						"Pat_Primary_Ins_Plan", cov_pipe,
						"Pat_Primary_Ins_Member_Num", cov_pipe,
						"Pat_Primary_Ins_Group_Num", cov_pipe,
						"Pat_Primary_Ins_Policy_Num", cov_pipe,
						"Pat_Primary_Ins_Street_Addr", cov_pipe,
						"Pat_Primary_Ins_Street_Addr2", cov_pipe,
						"Pat_Primary_Ins_City", cov_pipe,
						"Pat_Primary_Ins_State", cov_pipe,
						"Pat_Primary_Ins_ZipCode", cov_pipe,
						"Pat_Primary_Ins_Phone", cov_pipe,
						"Pat_Secondary_Ins", cov_pipe,
						"Pat_Secondary_Ins_Plan", cov_pipe,
						"Pat_Secondary_Ins_Member_Num", cov_pipe,
						"Pat_Secondary_Ins_Group_Num", cov_pipe,
						"Pat_Secondary_Ins_Policy_Num", cov_pipe,
						"Pat_Secondary_Ins_Street_Addr", cov_pipe,
						"Pat_Secondary_Ins_Street_Addr2", cov_pipe,
						"Pat_Secondary_Ins_City", cov_pipe,
						"Pat_Secondary_Ins_State", cov_pipe,
						"Pat_Secondary_Ins_ZipCode", cov_pipe,
						"Pat_Secondary_Ins_Phone", cov_pipe,
						"Enc_Primary_Ins", cov_pipe,
						"Enc_Primary_Ins_Plan", cov_pipe,
						"Enc_Primary_Ins_Member_Num", cov_pipe,
						"Enc_Primary_Ins_Group_Num", cov_pipe,
						"Enc_Primary_Ins_Policy_Num", cov_pipe,
						"Enc_Primary_Ins_Phone", cov_pipe,
						"Enc_Primary_Ins_Street_Addr", cov_pipe,
						"Enc_Primary_Ins_Street_Addr2", cov_pipe,
						"Enc_Primary_Ins_City", cov_pipe,
						"Enc_Primary_Ins_State", cov_pipe,
						"Enc_Primary_Ins_ZipCode", cov_pipe,
						"Enc_Secondary_Ins", cov_pipe,
						"Enc_Secondary_Ins_Plan", cov_pipe,
						"Enc_Secondary_Ins_Member_Num", cov_pipe,
						"Enc_Secondary_Ins_Group_Num", cov_pipe,
						"Enc_Secondary_Ins_Policy_Num", cov_pipe,
						"Enc_Secondary_Ins_Phone", cov_pipe,
						"Enc_Secondary_Ins_Street_Addr", cov_pipe,
						"Enc_Secondary_Ins_Street_Addr2", cov_pipe,
						"Enc_Secondary_Ins_City", cov_pipe,
						"Enc_Secondary_Ins_State", cov_pipe,
						"Enc_Secondary_Ins_ZipCode", cov_pipe,
						"Medication1", cov_pipe,
						"Med1_Category1", cov_pipe,
						"Med1_Category2", cov_pipe,
						"Med1_Category3", cov_pipe,
						"Medication2", cov_pipe,
						"Med2_Category1", cov_pipe,
						"Med2_Category2", cov_pipe,
						"Med2_Category3")
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
;CALL ECHORECORD (exp_data)
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
END
GO

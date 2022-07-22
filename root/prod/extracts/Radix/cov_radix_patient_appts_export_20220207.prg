/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		11/16/2021
	Solution:			Radiology
	Source file name:	cov_radix_patient_appts_export.prg
	Object name:		cov_radix_patient_appts_export
	Request #:			10834
 
	Program purpose:	Export patients for Radix Appt Data
 
	Executing from:		CCL
 
 	Special Notes:
	Execute Example:
 
***********************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***********************************************************************************************
 
 Mod   Date	          Developer				 Comment
 ----  ----------	  --------------------	 --------------------------------------------------
 0001  11/16/2021     Dawn Greer, DBA        Original Release
 
***********************************************************************************************/
 
drop program cov_radix_patient_appts_export go
create program cov_radix_patient_appts_export
 
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
 
DECLARE file_var			= vc WITH noconstant("cov_radix_patient_demographics_extract_")
DECLARE cur_date_var  		= vc WITH noconstant(build(YEAR(curdate),FORMAT(MONTH(curdate),"##;P0"),FORMAT(DAY(curdate),"##;P0")))
DECLARE filepath_var 		= vc WITH noconstant("")
DECLARE temppath_Var		= vc WITH noconstant("cer_temp:")
DECLARE temppath2_var		= vc WITH noconstant("$cer_temp/")
 
DECLARE output_var  		= vc WITH noconstant("")
DECLARE output_rec  		= vc WITH noconstant("")
 
DECLARE cmd					= vc WITH noconstant("")
DECLARE len					= i4 WITH noconstant(0)
DECLARE stat				= i4 WITH noconstant(0)
 
DECLARE startdate			= F8
DECLARE enddate				= F8
 
;  Set astream path
;SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/RadixExtract/"
;SET file_var = "cov_radix_patient_demographics_extract_"
;SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
;SET filepath_var = build(filepath_var, file_var)
;SET temppath2_var = build(temppath2_var, file_var)
 
 
RECORD exp_data (
	1 output_cnt = i4
	1 list[*]
	    2 Patient_ID = VC
	    2 Person_ID = F8
	    2 Patient_First_Name = VC
	    2 Patient_Middle_Name = VC
	    2 Patient_Last_Name = VC
	    2 Patient_Suffix = VC
	    2 Patient_Street1 = VC
	    2 Patient_Street2 = VC
	    2 Patient_City = VC
	    2 Patient_State = VC
 		2 Patient_Zip_Code = VC
 		2 Patient_Country = VC
	    2 Patient_SSN = VC
	    2 Patient_Sex = VC
	    2 Patient_DOB = VC
	    2 Patient_EthnicBackground = VC
	    2 Patient_Marital_Status = VC
	    2 Patient_Home_Phone = VC
	    2 Patient_Mobile_Phone = VC
	    2 Patient_Work_Phone = VC
	    2 Patient_Work_Ext = VC
	    2 Patient_Email = VC
	    2 Patient_Language = VC
	    2 Patient_Status = VC
	    2 Patient_Race = VC
	    2 Patient_Deceased_Date = VC
	    2 Referring_Provider_Id	= VC
	    2 Referring_Provider_NPI = VC
	    2 Referring_Provider_Name = VC
	    2 Preferred_Facility_ID	= VC
	    2 Preferred_Provider_ID = VC
		2 Guarantor_First_Name = VC
		2 Guarantor_Last_Name = VC
		2 Guarantor_Middle_Name = VC
		2 Guarantor_DOB = VC
		2 Guarantor_Email = VC
		2 Guarantor_Gender = VC
		2 Guarantor_Phone_Home = VC
		2 Guarantor_Phone_Business = VC
		2 Guarantor_Address_Line_One = VC
		2 Guarantor_Address_Line_Two = VC
		2 Guarantor_City = VC
		2 Guarantor_State = VC
		2 Guarantor_Zip = VC
		2 Guarantor_Country = VC
		2 Guarantor_SSN = VC
		2 Guarantor_Relationship_with_Patient = VC
		2 Guarantor_Phone_Cell = VC
		2 Patient_Insurance_ID = VC
		2 Insurance_Priority = VC
		2 Insurance_Company_ID = VC
		2 Insurance_Policy_ID_Plan_Id = VC
		2 Insurance_Group = VC
		2 Insurance_Finance_Group_Name = VC
		2 Insurance_Finance_Group_ID = VC
		2 Insurance_Member_ID = VC
		2 Insurance_Effective_Date = VC
		2 Insurance_Effective_End_Date = VC
		2 Policyholder_Person_ID = VC
		2 Policyholder_Patient_Relation = VC
		2 Policyholder_First_Name = VC
		2 Policyholder_Middle_Name = VC
		2 Policyholder_Last_Name = VC
		2 Policyholder_SSN = VC
		2 Policyholder_DOB = VC
		2 Policyholder_Email = VC
		2 Policyholder_Phone_Number = VC
		2 Policyholder_Phone_Type = VC
		2 Policyholder_Address = VC
		2 Policyholder_City = VC
		2 Policyholder_State = VC
		2 Policyholder_Zip = VC
		2 Policyholder_Country = VC
		2 Insurance_Verification_Status = VC
		2 Patient_Deductible_Amount = VC
		2 Patient_Copay_Amount = VC
		2 Active_Flag = VC
		2 Patient_Percentage = VC
		2 Insurance_Percentage = VC
		2 Insurance_Phone = VC
		2 Appointment_ID = VC
		2 Appt_Date = VC
		2 Appointment_Begin_time = VC
		2 Appointment_End_time = VC
		2 Appt_TypeID = VC
		2 Appt_Notes = VC
		2 Provider_Resource_ID = VC
		2 Facility_ID = VC
		2 Appointment_Status = VC
		2 Appt_Created_Ts = VC
		2 Appt_Created_By = VC
		2 Appt_Updated_Ts = VC
		2 Appt_Updated_By = VC
		2 Appointment_ID = VC
		2 Appt_Note_ID = VC
		2 Appt_Note_Text = VC
		2 Pat_Note_ID = VC
		2 Pat_Note_Text = VC
		2 Consent = VC
)
 
CALL ECHO ("***** GETTING PATIENT DATA ******")
/**************************************************************
; Get Patient Data
**************************************************************/
 
SELECT DISTINCT
	Patient_ID = TRIM(cmrn.alias,3)
  	,Person_ID = pat.person_id
  	,Patient_First_Name = TRIM(pat.name_first,3)
  	,Patient_Middle_Name = TRIM(pat.name_middle,3)
  	,Patient_Last_Name = TRIM(pat.name_last,3)
  	,Patient_Suffix = TRIM(pn.name_suffix,3)
  	,Patient_Street1 = TRIM(addr.street_addr,3)
  	,Patient_Street2 = TRIM(addr.street_addr2,3)
  	,Patient_City = TRIM(addr.city,3)
  	,Patient_State = TRIM(addr.state,3)
  	,Patient_Zip_Code = REPLACE(TRIM(addr.zipcode,3),"-","")
  	,Patient_Country = TRIM(UAR_GET_CODE_DISPLAY(addr.country_cd),3)
	,Patient_SSN = EVALUATE2(IF (TRIM(ssn.alias,3) IN ('000000000','111111111','222222222',
		'333333333','444444444','555555555','666666666','777777777','888888888',
		'999999999')) " " ELSE TRIM(ssn.alias,3) ENDIF)
  	,Patient_Sex = REPLACE(CNVTSTRING(pat.sex_cd),'.00','')
  	,Patient_DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
	,Patient_EthnicBackground = REPLACE(CNVTSTRING(pat.ethnic_grp_cd),'.00','')
	,Patient_Marital_Status = REPLACE(CNVTSTRING(pat.marital_type_cd),'.00','')
	,Patient_Home_Phone = EVALUATE2(IF (home_phone.phone_num_key LIKE '*^MOBILE*' OR home_phone.phone_num_key LIKE '*NONE*'
	  	OR SIZE(home_phone.phone_num_key) < 10 OR home_phone.phone_Num_key IN ('9999999999','8888888888','7777777777',
	  	'6666666666','5555555555','4444444444','3333333333','2222222222','1111111111','0000000000')) " "
	  	ELSE TRIM(REPLACE(REPLACE(REPLACE(home_phone.phone_num_key,'(',''),')',''),'-',''),3) ENDIF)
	,Patient_Mobile_Phone = EVALUATE2(IF (mobile_phone.phone_num_key LIKE '*^MOBILE*' OR mobile_phone.phone_num_key LIKE '*NONE*'
	  	OR SIZE(mobile_phone.phone_num_key) < 10 OR mobile_phone.phone_Num_key IN ('9999999999','8888888888','7777777777',
	  	'6666666666','5555555555','4444444444','3333333333','2222222222','1111111111','0000000000')) " "
	  	ELSE TRIM(REPLACE(REPLACE(REPLACE(mobile_phone.phone_num_key,'(',''),')',''),'-',''),3) ENDIF)
	,Patient_Work_Phone = EVALUATE2(IF (Work_Phone.phone_num_key LIKE '*^MOBILE*' OR Work_Phone.phone_num_key LIKE '*NONE*'
	  	OR SIZE(Work_Phone.phone_num_key) < 10 OR Work_Phone.phone_Num_key IN ('9999999999','8888888888','7777777777',
	  	'6666666666','5555555555','4444444444','3333333333','2222222222','1111111111','0000000000')) " "
	  	ELSE TRIM(REPLACE(REPLACE(REPLACE(Work_Phone.phone_num_key,'(',''),')',''),'-',''),3) ENDIF)
  	,Patient_Work_Ext = EVALUATE2(IF (SIZE(TRIM(work_phone.extension,3)) = 0) '' ELSE TRIM(Work_Phone.extension,3) ENDIF)
	,Patient_Email = EVALUATE2(IF (SIZE(email.street_addr) = 0
	  	OR CNVTUPPER(email.street_addr) = 'NONE'
	  	OR email.street_addr NOT LIKE '*@*'
	  	OR CNVTUPPER(email.street_addr) LIKE '*@.COM*'
	  	OR CNVTUPPER(email.street_addr) LIKE '*REFUSED*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'DECLINED*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'ASK@*'
	  	OR CNVTUPPER(email.street_addr) LIKE 'ASKFOREMAIL@*') " " ELSE TRIM(email.street_addr,3) ENDIF)
	,Patient_Language = REPLACE(CNVTSTRING(pat.language_cd),'.00','')
  	,Patient_Status = 'Active'
	,Patient_Race = REPLACE(CNVTSTRING(pat.race_cd),'.00','')
  	,Patient_Deceased_Date = FORMAT(pat.deceased_dt_tm, "MM/DD/YYYY")
 	,Referring_Provider_ID = ''
 	,Referring_Provider_NPI = ''
 	,Referring_Provider_Name = ''
 	,Preferred_Facility_ID = ''
 	,Preferred_Provider_ID = ''
 	,Guarantor_First_Name = ''
 	,Guarantor_Last_Name = ''
 	,Guarantor_Middle_Name = ''
 	,Guarantor_DOB = ''
 	,Guarantor_Email = ''
 	,Guarantor_Gender = ''
 	,Guarantor_Phone_Home = ''
 	,Guarantor_Phone_Business = ''
 	,Guarantor_Address_Line_One = ''
 	,Guarantor_address_Line_Two = ''
 	,Guarantor_City = ''
 	,Guarantor_State = ''
 	,Guarantor_Zip = ''
 	,Guarantor_Country = ''
 	,Guarantor_SSN = ''
 	,Guarantor_Relationship_with_Patient = ''
 	,Guarantor_Phone_Cell = ''
 	,Patient_Insurance_ID = 'xxx'
 	,Insurance_Priority = '0'
 	,Insurance_Company_ID = ''
 	,Insurance_Policy_ID_Plan_ID = '0'
 	,Insurance_Company_ID = ''
 	,Insurance_Group = ''
 	,Insurance_Finance_Group_Name = ''
 	,Insurance_Finance_Group_ID = ''
 	,Insurance_Member_ID = ''
 	,Insurance_Effective_Date = '01/01/1900'
 	,Insurance_Effective_End_Date = '01/01/1900'
 	,Policyholder_Person_ID = '0'
 	,Policyholder_Patient_Relation = ''
 	,Policyholder_First_Name = ''
 	,Policyholder_Middle_Name = ''
 	,Policyholder_Last_Name = ''
 	,Policyholder_SSN = ''
 	,Policyholder_DOB = ''
 	,Policyholder_Email = ''
 	,Policyholder_Phone_Number = ''
 	,Policyholder_Phone_Type = ''
 	,Policyholder_Address = ''
 	,Policyholder_City = ''
 	,Policyholder_State = ''
 	,Policyholder_Zip = ''
 	,Policyholder_Country = ''
 	,Insurance_Verification_Status = ''
 	,Patient_Deductible_Amount = '0'
 	,Patient_Copay_Amount = '0'
 	,Active_Flag = ''
 	,Patient_Percentage = ''
 	,Insurance_Percentage = ''
 	,Insurance_Phone = ''
	,Appointment_ID = REPLACE(CNVTSTRING(se.sch_event_id),'.00','')
 	,Appt_Date = FORMAT(sa_res.beg_dt_tm, "MM/DD/YYYY;;d")
	,Appointment_Begin_Time = DATETIMEZONEFORMAT(sa_res.beg_dt_tm,DATETIMEZONEBYNAME(t.time_zone), "hh:mm;;d")
 	,Appointment_End_Time = DATETIMEZONEFORMAT(sa_res.end_dt_tm,DATETIMEZONEBYNAME(t.time_zone), "hh:mm;;d")
	,Appt_TypeID = REPLACE(CNVTSTRING(se.appt_type_cd),'.00','')
	,Appt_Notes = TRIM(REPLACE(REPLACE(se.appt_reason_free,CHAR(13),""),CHAR(10),""),3)
	,Provider_Resource_ID = REPLACE(CNVTSTRING(sa_res.resource_cd),'.00','')
	,Facility_ID = REPLACE(CNVTSTRING(fac_loc.location_cd),'.00','')
 	,Appointment_Status = REPLACE(CNVTSTRING(se.sch_state_cd),'.00','')
 	,Appt_Created_TS = FORMAT(sea.action_dt_tm, "MM/DD/YYYY hh:mm;;d")
 	,Appt_Created_By = TRIM(sea_pr.name_full_formatted,3)
 	,Appt_Updated_TS = FORMAT(se.updt_dt_tm, "MM/DD/YYYY hh:mm;;d")
 	,Appt_Updated_By = TRIM(se_up_pr.name_full_formatted,3)
 	,Appt_Note_ID = ''
 	,Appt_Note_Text = ''
 	,Pat_Note_ID = ''
 	,Pat_Note_Text = ''
 	,Consent = REPLACE(CNVTSTRING(sed.oe_field_value),'.00','')
FROM person pat
,(LEFT JOIN person_name pn ON (pat.person_id = pn.person_id
	AND pn.name_type_cd = 766.00 /*Current*/
	AND pn.active_ind = 1
	))
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
		AND hp.contact_method_cd != 0.00)
	))
,(LEFT JOIN ADDRESS addr ON (pat.person_id = addr.parent_entity_id
	AND pat.person_id = addr.parent_entity_id
	AND addr.parent_entity_name = "PERSON"
	AND addr.active_ind = 1
	AND addr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND addr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
   	AND addr.address_type_cd = 756.00   /*HOME*/
	AND addr.address_id IN (SELECT MAX(addr1.address_id) FROM address addr1
		WHERE addr1.parent_entity_id = pat.person_id
		AND addr1.parent_entity_name = "PERSON"
		AND addr1.active_ind = 1
		AND addr1.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND addr1.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND addr1.address_type_cd = 756.00   /*HOME*/
		GROUP BY addr1.address_type_cd)
	))
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
		AND mp.contact_method_cd != 0.00)
	))
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
		AND wp.contact_method_cd != 0.00)
	))
,(LEFT JOIN address email ON (pat.person_id = email.parent_entity_id
	AND email.address_type_cd = 755.00 /*Email*/
	AND email.address_type_seq = 1
	AND email.active_ind = 1
	AND email.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND NULLIND(email.street_addr) = 0
	))
,(LEFT JOIN person_alias SSN ON (pat.person_id = SSN.person_id
	AND SSN.person_alias_type_cd = 18.00 /*SSN*/
	AND SSN.active_ind = 1
	AND SSN.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	))
, (LEFT JOIN PERSON_ALIAS cmrn ON (pat.person_id = cmrn.person_id
	AND cmrn.active_ind = 1
	AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND cmrn.person_alias_type_cd = 2 /*CMRN*/
	))
,(INNER JOIN SCH_APPT sa_pat ON (sa_pat.person_id = pat.person_id
  	AND sa_pat.role_meaning = "PATIENT"
  	AND sa_pat.state_meaning NOT IN ("RESCHEDULED")
	))
,(INNER JOIN SCH_EVENT se ON (se.sch_event_id = sa_pat.sch_event_id
    ))
,(LEFT JOIN SCH_EVENT_DETAIL sed ON (sed.sch_event_id = se.sch_event_id
	AND sed.oe_field_id = 23372832 /*Patient Reminder*/
	AND sed.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
,(INNER JOIN SCH_EVENT_ACTION sea ON (se.sch_event_id = sea.sch_event_id
	AND sea.sch_action_cd = 4517 /*Book*/
	AND sea.action_dt_tm IN (SELECT MAX(s.action_dt_tm) FROM SCH_EVENT_ACTION s
		WHERE sea.sch_event_id = s.sch_event_id
		AND s.sch_action_cd = 4517 /*Book*/)
	))
,(INNER JOIN PRSNL sea_pr ON (sea.action_prsnl_id = sea_pr.person_id
	))
,(INNER JOIN PRSNL se_up_pr ON (se.updt_id = se_up_pr.person_id
	))
,(INNER JOIN SCH_APPT sa_res ON (sa_res.sch_event_id = se.sch_event_id
	AND sa_res.role_meaning IN ("RESOURCE","DEFRESROLE","EXAMROOM")
	AND sa_res.state_meaning NOT IN ("RESCHEDULED")
	AND sa_pat.schedule_id = sa_res.schedule_id
  	))
,(INNER JOIN SCH_RESOURCE sr_all ON (sa_res.resource_cd = sr_all.resource_cd
    ))
,(INNER JOIN SCH_SCHEDULE ss ON (sa_res.sch_event_Id = ss.sch_event_Id
	AND sa_res.schedule_id = ss.schedule_id
	AND sa_pat.schedule_id = ss.schedule_id
	AND ss.schedule_id = (SELECT MAX(s.schedule_Id) FROM SCH_SCHEDULE s
		WHERE s.sch_event_id = ss.sch_event_id)
	))
,(LEFT JOIN LOCATION amb_loc ON (sa_res.appt_location_cd = amb_loc.location_cd
	AND amb_loc.location_type_cd IN (772.00 /*Nurse Unit*/, 794.00 /*Ambulatory*/)
	AND amb_loc.active_ind = 1))
,(LEFT JOIN LOCATION_GROUP bld_loc_grp ON (bld_loc_grp.child_loc_cd = amb_loc.location_cd
	AND bld_loc_grp.active_ind = 1
	AND bld_loc_grp.root_loc_cd = 0))
,(LEFT JOIN LOCATION bld_loc ON (bld_loc.location_cd = bld_loc_grp.parent_loc_cd
	AND bld_loc.location_type_cd = 778.00 /*Building*/
	AND bld_loc.active_ind = 1))
,(LEFT JOIN LOCATION_GROUP fac_loc_grp ON (fac_loc_grp.child_loc_cd = bld_loc.location_cd
	AND fac_loc_grp.active_ind = 1
	AND fac_loc_grp.sequence = 1))
,(LEFT JOIN LOCATION fac_loc ON (fac_loc_grp.parent_loc_cd = fac_loc.location_cd
	AND fac_loc.location_type_cd = 783.00 /*FACILITY*/
	AND fac_loc.active_ind = 1))
,(LEFT JOIN CODE_VALUE cv_fac ON (fac_loc.location_cd = cv_fac.code_value))
,(LEFT JOIN TIME_ZONE_R t ON (fac_loc.location_cd = t.parent_entity_id))
WHERE pat.active_ind = 1
AND sr_all.mnemonic_key IS NOT NULL
AND sr_all.mnemonic_key != ' '
AND sa_res.slot_state_cd IN (0,9541)
AND sa_res.role_seq IN (1,0)
AND cv_fac.code_value != 0
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND sa_res.beg_dt_tm >= CNVTDATETIME('01-JAN-2022 00:00')
AND sa_res.beg_dt_tm <= CNVTDATETIME('11-JAN-2022 23:59:59')
;AND se.sch_state_cd NOT IN (4535,4542,4543)	; Future appointments
AND cv_fac.code_value IN (2553028365,2553028415,2553028275,2557509379,2553028245,3166555943,2553454721,2553454729,2553454745,
2553454753,2558809797,3857922517,3086911417,2553454777,2553454769,2553454785,2553454793,2553454801,2553455081,2558809999,
2553455089,2553455097,2553454817,2553455137,2553455113,2553455121,2553455329,2553455017,2553455009,2553455001,2786360667,
2553454825,2553455145,2553455169,2553455177,2568267787,3100887697,2553455185,2553455193,2553455201,2553455209,2553455217,
2553455225,2553454833,2553454873,2553454865,2553454841,2559325883,2553454849,2553454857,2553454881,3757127663,2712289989,
2553455345,2553454889,2553454897,2553454913,2553455241,2553455249,2553455033,2553455265,2561114047,2553455041,2851009053,
2553455049,2553455273,2553455305,3418097693,3418099801,2562474765,2601576519,2553455353,2553455369,2553455377,2562470009,
2553454993,2553454929,2553455057,2553455065,2553028439,2553454945,2553454937,2553454953,2553454969,2553455073,2553454985,
2553454977,2553028299,3612179491,2555024809,2553765315,2553765323,2552503635,21250403,2553765563,2553765571,2553455025,
2553765643,2553765363,2553765427,2553765435,2552503653,2552503613,2553765491,2553765483,2553765283,2555024801,2553765683,
2553455257,2552503639,2552503645,2553765579,2553765587,2553765603,2553765611,2553765619,2553765499,2553765507,2553765539,
2555024825,2552503649,2553765651,2553765659,2553765667,2553765675,2555024817,2553765691,2553765699,2553765379,2553765387,
2553765411,2553765419,2553765395,2553765403,3612558839,3612562151,3612565269,3612568411,3612572895,3612572895,361257547)
ORDER BY se.sch_event_id
 
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
 
	exp_data->list[cnt].Patient_ID = Patient_ID
	exp_data->list[cnt].Person_ID = Person_ID
	exp_data->list[cnt].Patient_First_Name = Patient_First_Name
	exp_data->list[cnt].Patient_Middle_Name  = Patient_Middle_Name
	exp_data->list[cnt].Patient_Last_Name = Patient_Last_Name
	exp_data->list[cnt].Patient_Suffix = Patient_Suffix
	exp_data->list[cnt].Patient_Street1 = Patient_Street1
	exp_data->list[cnt].Patient_Street2 = Patient_Street2
	exp_data->list[cnt].Patient_City = Patient_City
	exp_data->list[cnt].Patient_State  = Patient_State
	exp_data->list[cnt].Patient_Zip_Code = Patient_Zip_Code
	exp_data->list[cnt].Patient_Country = Patient_Country
	exp_data->list[cnt].Patient_SSN = Patient_SSN
	exp_data->list[cnt].Patient_Sex = Patient_Sex
	exp_data->list[cnt].Patient_DOB = Patient_DOB
	exp_data->list[cnt].Patient_EthnicBackground = Patient_EthnicBackground
	exp_data->list[cnt].Patient_Marital_Status = Patient_Marital_Status
	exp_data->list[cnt].Patient_Home_Phone = Patient_Home_Phone
	exp_data->list[cnt].Patient_Mobile_Phone = Patient_Mobile_Phone
	exp_data->list[cnt].Patient_Work_Phone = Patient_Work_Phone
	exp_data->list[cnt].Patient_Work_Ext = Patient_Work_Ext
	exp_data->list[cnt].Patient_Email = Patient_Email
	exp_data->list[cnt].Patient_Language = Patient_Language
	exp_data->list[cnt].Patient_Status = Patient_Status
	exp_data->list[cnt].Patient_Race = Patient_Race
	exp_data->list[cnt].Patient_Deceased_Date = Patient_Deceased_Date
	exp_data->list[cnt].Referring_Provider_ID = Referring_Provider_ID
	exp_data->list[cnt].Referring_Provider_NPI = Referring_Provider_NPI
	exp_data->list[cnt].Referring_Provider_Name = Referring_Provider_Name
	exp_data->list[cnt].Preferred_Facility_ID = Preferred_Facility_ID
	exp_data->list[cnt].Preferred_Provider_ID = Preferred_Provider_ID
	exp_data->list[cnt].Guarantor_First_Name = Guarantor_First_Name
	exp_data->list[cnt].Guarantor_Last_Name = Guarantor_Last_Name
	exp_data->list[cnt].Guarantor_Middle_Name = Guarantor_Middle_Name
	exp_data->list[cnt].Guarantor_DOB = Guarantor_DOB
	exp_data->list[cnt].Guarantor_Email = Guarantor_Email
	exp_data->list[cnt].Guarantor_Gender = Guarantor_Gender
	exp_data->list[cnt].Guarantor_Phone_Home = Guarantor_Phone_Home
	exp_data->list[cnt].Guarantor_Phone_Business = Guarantor_Phone_Business
	exp_data->list[cnt].Guarantor_Address_Line_One = Guarantor_Address_Line_One
	exp_data->list[cnt].Guarantor_address_Line_Two = Guarantor_address_Line_Two
	exp_data->list[cnt].Guarantor_City = Guarantor_City
	exp_data->list[cnt].Guarantor_State = Guarantor_State
	exp_data->list[cnt].Guarantor_Zip = Guarantor_Zip
	exp_data->list[cnt].Guarantor_Country = Guarantor_Country
	exp_data->list[cnt].Guarantor_SSN = Guarantor_SSN
	exp_data->list[cnt].Guarantor_Relationship_with_Patient = Guarantor_Relationship_with_Patient
	exp_data->list[cnt].Guarantor_Phone_Cell = Guarantor_Phone_Cell
	exp_data->list[cnt].Patient_Insurance_ID = Patient_Insurance_ID
	exp_data->list[cnt].Insurance_Priority = Insurance_Priority
	exp_data->list[cnt].Insurance_Company_ID = Insurance_Company_ID
	exp_data->list[cnt].Insurance_Policy_ID_Plan_ID = Insurance_Policy_ID_Plan_ID
	exp_data->list[cnt].Insurance_Company_ID = Insurance_Company_ID
	exp_data->list[cnt].Insurance_Group = Insurance_Group
	exp_data->list[cnt].Insurance_Finance_Group_Name = Insurance_Finance_Group_Name
	exp_data->list[cnt].Insurance_Finance_Group_ID = Insurance_Finance_Group_ID
	exp_data->list[cnt].Insurance_Member_ID = Insurance_Member_ID
	exp_data->list[cnt].Insurance_Effective_Date = Insurance_Effective_Date
	exp_data->list[cnt].Insurance_Effective_End_Date = Insurance_Effective_End_Date
	exp_data->list[cnt].Policyholder_Person_ID = Policyholder_Person_ID
	exp_data->list[cnt].Policyholder_Patient_Relation = Policyholder_Patient_Relation
	exp_data->list[cnt].Policyholder_First_Name = Policyholder_First_Name
	exp_data->list[cnt].Policyholder_Middle_Name = Policyholder_Middle_Name
	exp_data->list[cnt].Policyholder_Last_Name = Policyholder_Last_Name
	exp_data->list[cnt].Policyholder_SSN = Policyholder_SSN
	exp_data->list[cnt].Policyholder_DOB = Policyholder_DOB
	exp_data->list[cnt].Policyholder_Email = Policyholder_Email
	exp_data->list[cnt].Policyholder_Phone_Number = Policyholder_Phone_Number
	exp_data->list[cnt].Policyholder_Phone_Type = Policyholder_Phone_Type
	exp_data->list[cnt].Policyholder_Address = Policyholder_Address
	exp_data->list[cnt].Policyholder_City = Policyholder_City
	exp_data->list[cnt].Policyholder_State = Policyholder_State
	exp_data->list[cnt].Policyholder_Zip = Policyholder_Zip
	exp_data->list[cnt].Policyholder_Country = Policyholder_Country
	exp_data->list[cnt].Insurance_Verification_Status = Insurance_Verification_Status
	exp_data->list[cnt].Patient_Deductible_Amount = Patient_Deductible_Amount
	exp_data->list[cnt].Patient_Copay_Amount = Patient_Copay_Amount
	exp_data->list[cnt].Active_Flag = Active_Flag
	exp_data->list[cnt].Patient_Percentage = Patient_Percentage
	exp_data->list[cnt].Insurance_Percentage = Insurance_Percentage
	exp_data->list[cnt].Insurance_Phone = Insurance_Phone
	exp_data->list[cnt].Appointment_ID = Appointment_ID
	exp_data->list[cnt].Appt_Date = Appt_Date
	exp_data->list[cnt].Appointment_Begin_Time = Appointment_Begin_Time
	exp_data->list[cnt].Appointment_End_Time = Appointment_End_Time
	exp_data->list[cnt].Appt_TypeID = Appt_TypeID
	exp_data->list[cnt].Appt_Notes = Appt_Notes
	exp_data->list[cnt].Provider_Resource_ID = Provider_Resource_ID
	exp_data->list[cnt].Facility_ID = Facility_ID
	exp_data->list[cnt].Appointment_Status = Appointment_Status
	exp_data->list[cnt].Appt_Created_TS = Appt_Created_TS
	exp_data->list[cnt].Appt_Created_By = Appt_Created_By
	exp_data->list[cnt].Appt_Updated_TS = Appt_Updated_TS
	exp_data->list[cnt].Appt_Updated_By = Appt_Updated_By
	exp_data->list[cnt].Appt_Note_ID = Appt_Note_ID
	exp_data->list[cnt].Appt_Note_Text = Appt_Note_Text
	exp_data->list[cnt].Pat_Note_ID = Pat_Note_ID
	exp_data->list[cnt].Pat_Note_Text = Pat_Note_Text
	exp_data->list[cnt].Consent = Consent
 
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
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",exp_data->output_cnt))
 
 	CALL ECHO ("***** Build Patient Demographics Data *******")
 
	;Set astream path / Patient Demographic Data
	SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/RadixExtract/"
	SET file_var = "cov_radix_pat_demo_extract_"
	SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
	SET filepath_var = build(filepath_var, file_var)
 
	SET temppath_var = build(temppath_var, file_var)
	SET temppath2_var = build(temppath2_var, file_var)
 
	IF (validate(request->batch_selection) = 1 or $output_file = 1)
		SET output_var = value(temppath_var)
	ELSE
		SET output_var = value($OUTDEV)
	ENDIF
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("Patient_ID", cov_pipe,
			"Patient_First_Name", cov_pipe,
			"Patient_Middle_Name ", cov_pipe,
			"Patient_Last_Name", cov_pipe,
			"Patient_Suffix", cov_pipe,
			"Patient_Street1", cov_pipe,
			"Patient_Street2", cov_pipe,
			"Patient_City", cov_pipe,
			"Patient_State ", cov_pipe,
			"Patient_Zip_Code", cov_pipe,
			"Patient_Country", cov_pipe,
			"Patient_SSN", cov_pipe,
			"Patient_Sex", cov_pipe,
			"Patient_DOB", cov_pipe,
			"Patient_EthnicBackground", cov_pipe,
			"Patient_Marital_Status", cov_pipe,
			"Patient_Home_Phone", cov_pipe,
			"Patient_Mobile_Phone", cov_pipe,
			"Patient_Work_Phone", cov_pipe,
			"Patient_Work_Ext", cov_pipe,
			"Patient_Email", cov_pipe,
			"Patient_Language", cov_pipe,
			"Patient_Status", cov_pipe,
			"Patient_Race", cov_pipe,
			"Patient_Deceased_Date")
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
			exp_data->list[dt.seq].Patient_ID, cov_pipe,
			exp_data->list[dt.seq].Patient_First_Name, cov_pipe,
			exp_data->list[dt.seq].Patient_Middle_Name , cov_pipe,
			exp_data->list[dt.seq].Patient_Last_Name, cov_pipe,
			exp_data->list[dt.seq].Patient_Suffix, cov_pipe,
			exp_data->list[dt.seq].Patient_Street1, cov_pipe,
			exp_data->list[dt.seq].Patient_Street2, cov_pipe,
			exp_data->list[dt.seq].Patient_City, cov_pipe,
			exp_data->list[dt.seq].Patient_State , cov_pipe,
			exp_data->list[dt.seq].Patient_Zip_Code, cov_pipe,
			exp_data->list[dt.seq].Patient_Country, cov_pipe,
			exp_data->list[dt.seq].Patient_SSN, cov_pipe,
			exp_data->list[dt.seq].Patient_Sex, cov_pipe,
			exp_data->list[dt.seq].Patient_DOB, cov_pipe,
			exp_data->list[dt.seq].Patient_EthnicBackground, cov_pipe,
			exp_data->list[dt.seq].Patient_Marital_Status, cov_pipe,
			exp_data->list[dt.seq].Patient_Home_Phone, cov_pipe,
			exp_data->list[dt.seq].Patient_Mobile_Phone, cov_pipe,
			exp_data->list[dt.seq].Patient_Work_Phone, cov_pipe,
			exp_data->list[dt.seq].Patient_Work_Ext, cov_pipe,
			exp_data->list[dt.seq].Patient_Email, cov_pipe,
			exp_data->list[dt.seq].Patient_Language, cov_pipe,
			exp_data->list[dt.seq].Patient_Status, cov_pipe,
			exp_data->list[dt.seq].Patient_Race, cov_pipe,
			exp_data->list[dt.seq].Patient_Deceased_Date)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
	; Copy file to AStream / Patient Demographic Data
	IF (validate(request->batch_selection) = 1 OR $output_file = 1)
		SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
		SET len = size(trim(cmd))
 
		CALL dcl(cmd, len, stat)
		CALL echo(build2(cmd, " : ", stat))
	ENDIF
 
	CALL ECHO ("***** Build Appointment Data *******")
 
 	SET output_rec = ""
	SET file_var = ""
	SET filepath_var = ""
	SET temppath_var = ""
	SET temppath2_var = ""
 
	;  Set astream path	 / Appointment Data
	SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/RadixExtract/"
	SET file_var = "cov_radix_appts_extract_"
	SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
	SET filepath_var = build(filepath_var, file_var)
	SET temppath_Var = "cer_temp:"
	SET temppath2_var = "$cer_temp/"
	SET temppath_var = build(temppath_var, file_var)
	SET temppath2_var = build(temppath2_var, file_var)
 
	IF (validate(request->batch_selection) = 1 or $output_file = 1)
		SET output_var = value(temppath_var)
	ELSE
		SET output_var = value($OUTDEV)
	ENDIF
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = exp_data->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("Appointment_ID", cov_pipe,
			"Patient_ID", cov_pipe,
			"Appt_Date", cov_pipe,
			"Appointment_Begin_Time", cov_pipe,
			"Appointment_End_Time", cov_pipe,
			"Appt_TypeID", cov_pipe,
			"Appt_Notes", cov_pipe,
			"Provider_Resource_ID", cov_pipe,
			"Facility_ID", cov_pipe,
			"Appointment_Status", cov_pipe,
			"Appt_Created_TS", cov_pipe,
			"Appt_Created_By", cov_pipe,
			"Appt_Updated_TS", cov_pipe,
			"Appt_Updated_By", cov_pipe,
			"Consent")
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
			exp_data->list[dt.seq].Appointment_ID, cov_pipe,
			exp_data->list[dt.seq].Patient_id, cov_pipe,
			exp_data->list[dt.seq].Appt_Date, cov_pipe,
			exp_data->list[dt.seq].Appointment_Begin_Time, cov_pipe,
			exp_data->list[dt.seq].Appointment_End_Time, cov_pipe,
			exp_data->list[dt.seq].Appt_TypeID, cov_pipe,
			exp_data->list[dt.seq].Appt_Notes, cov_pipe,
			exp_data->list[dt.seq].Provider_Resource_ID, cov_pipe,
			exp_data->list[dt.seq].Facility_ID, cov_pipe,
			exp_data->list[dt.seq].Appointment_Status, cov_pipe,
			exp_data->list[dt.seq].Appt_Created_TS, cov_pipe,
			exp_data->list[dt.seq].Appt_Created_By, cov_pipe,
			exp_data->list[dt.seq].Appt_Updated_TS, cov_pipe,
			exp_data->list[dt.seq].Appt_Updated_By, cov_pipe,
			exp_data->list[dt.seq].Consent)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < exp_data->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
	; Copy file to AStream / Appointment Data
	IF (validate(request->batch_selection) = 1 OR $output_file = 1)
		SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
		SET len = size(trim(cmd))
 
		CALL dcl(cmd, len, stat)
		CALL echo(build2(cmd, " : ", stat))
	ENDIF
 
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
	SET file_var = ""
	SET filepath_var = ""
	SET temppath_var = ""
	SET temppath2_var = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",exp_data->output_cnt))
 
 	CALL ECHO ("***** Build Patient Demographics Data *******")
 
	;Set astream path / Patient Demographic Data
	SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/RadixExtract/"
	SET file_var = "cov_radix_pat_demo_extract_"
	SET file_var = cnvtlower(build(file_var,cur_date_var,".txt"))
	SET filepath_var = build(filepath_var, file_var)
	SET temppath_var = "cer_temp:"
	SET temppath2_var = "$cer_temp/"
	SET temppath_var = build(temppath_var, file_var)
	SET temppath2_var = build(temppath2_var, file_var)
 
	IF (validate(request->batch_selection) = 1 or $output_file = 1)
		SET output_var = value(temppath_var)
	ELSE
		SET output_var = value($OUTDEV)
	ENDIF
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Patient_ID", cov_pipe,
			"Patient_First_Name", cov_pipe,
			"Patient_Middle_Name ", cov_pipe,
			"Patient_Last_Name", cov_pipe,
			"Patient_Suffix", cov_pipe,
			"Patient_Street1", cov_pipe,
			"Patient_Street2", cov_pipe,
			"Patient_City", cov_pipe,
			"Patient_State ", cov_pipe,
			"Patient_Zip_Code", cov_pipe,
			"Patient_Country", cov_pipe,
			"Patient_SSN", cov_pipe,
			"Patient_Sex", cov_pipe,
			"Patient_DOB", cov_pipe,
			"Patient_EthnicBackground", cov_pipe,
			"Patient_Marital_Status", cov_pipe,
			"Patient_Home_Phone", cov_pipe,
			"Patient_Mobile_Phone", cov_pipe,
			"Patient_Work_Phone", cov_pipe,
			"Patient_Work_Ext", cov_pipe,
			"Patient_Email", cov_pipe,
			"Patient_Language", cov_pipe,
			"Patient_Status", cov_pipe,
			"Patient_Race", cov_pipe,
			"Patient_Deceased_Date")
 
		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
	; Copy file to AStream / Patient Demographic Data
	IF (validate(request->batch_selection) = 1 OR $output_file = 1)
		SET cmd = build2("mv ", temppath_var, " ", filepath_var)
		SET len = size(trim(cmd))
 
		CALL dcl(cmd, len, stat)
		CALL echo(build2(cmd, " : ", stat))
	ENDIF
 
ENDIF
 
;CALL ECHORECORD (exp_data)
 
END
GO

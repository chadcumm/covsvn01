/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		07/26/2022
	Solution:			Lab
	Source file name:	cov_lab_acumen_ref_data_ext.prg
	Object name:		cov_lab_acumen_ref_data_ext
	Request #:			13324
 
	Program purpose:	Export Lab Reference Data for Acumen Project
 
	Executing from:		CCL
 
 	Special Notes:
	Execute Example:
 
***********************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***********************************************************************************************
 
 Mod   Date	          Developer				 Comment
 ----  ----------	  --------------------	 --------------------------------------------------
 0001  07/26/2022     Dawn Greer, DBA        Original Release
 
***********************************************************************************************/
 
drop program cov_lab_acumen_ref_data_ext go
create program cov_lab_acumen_ref_data_ext
 
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
 
DECLARE file_var			= vc WITH noconstant("")
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
 
/****************************************************************************
	Lab Test Codes
*****************************************************************************/
 
;  Set astream path
SET file_var = "Covenant_LabTestCodes_"
SET filepath_var = "/cerner/w_custom/p0665_cust/from_client_site/dg_folder/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".dsv"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
RECORD Lab_Test_Codes (
	1 output_cnt = i4
	1 list[*]
	    2 Hospital_Code = F8
	    2 Hospital_Name = C100
	    2 Order_Test_Code = F8
	    2 Order_Test_Name = C100
	    2 Analyte_Test_Code = F8
	    2 Analyte_Test_Name = C100
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Lab Test Codes Data ******")
/**************************************************************
; Get Lab Test Codes Data
**************************************************************/
 
SELECT DISTINCT
Hospital_Code = org.organization_id
,Hospital_Name = TRIM(org.org_name,3)
,Order_Test_Code = ptr.catalog_cd
,Order_Test_Name = UAR_GET_CODE_DESCRIPTION(ptr.catalog_cd)
,Analyte_Test_Code = ptr.task_assay_cd
,Analyte_Test_Name = UAR_GET_CODE_DESCRIPTION(ptr.task_assay_cd)
FROM ORDER_CATALOG oc
, PROFILE_TASK_R ptr
, ASSAY_PROCESSING_R apr
, SERVICE_RESOURCE sr
, ORGANIZATION org
PLAN oc WHERE oc.catalog_type_cd = 2513.00 /*LABORATORY*/
AND oc.active_ind = 1
JOIN ptr WHERE ptr.catalog_cd = oc.catalog_cd
	AND ptr.active_ind = 1
JOIN apr WHERE apr.task_assay_cd = ptr.task_assay_cd
	AND apr.active_ind = 1
JOIN sr WHERE sr.service_resource_cd = apr.service_resource_cd
AND sr.active_ind = 1
JOIN org WHERE org.organization_id = sr.organization_id
AND org.active_ind = 1
ORDER BY Hospital_code, CNVTUPPER(UAR_GET_CODE_DESCRIPTION(ptr.catalog_cd)),
ptr.sequence, CNVTUPPER(UAR_GET_CODE_DESCRIPTION(ptr.task_assay_cd))
 
/****************************************************************************
	Populate Record structure with Lab Test Codes Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(Lab_Test_Codes->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(Lab_Test_Codes->list, cnt + 9)
	ENDIF
 
	Lab_Test_Codes->list[cnt].Hospital_Code = Hospital_Code
	Lab_Test_Codes->list[cnt].Hospital_Name = Hospital_Name
	Lab_Test_Codes->list[cnt].Order_Test_Code = Order_Test_Code
	Lab_Test_Codes->list[cnt].Order_Test_Name = Order_Test_Name
	Lab_Test_Codes->list[cnt].Analyte_Test_Code = Analyte_Test_Code
	Lab_Test_Codes->list[cnt].Analyte_Test_Name = Analyte_Test_Name
 
FOOT REPORT
 	Lab_Test_Codes->output_cnt = cnt
 	CALL alterlist(Lab_Test_Codes->list, cnt)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(Lab_Test_Codes->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output Lab Test Codes Data
*****************************************************************************/
 
IF (Lab_Test_Codes->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = Lab_Test_Codes->output_cnt)
 
	HEAD REPORT
		output_rec = build("Hospital_Code", cov_pipe,
						"Hospital_Name", cov_pipe,
						"Order_Test_Code", cov_pipe,
						"Order_Test_Name", cov_pipe,
						"Analyte_Test_Code", cov_pipe,
						"Analyte_Test_Name"
						)
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						Lab_Test_Codes->list[dt.seq].Hospital_Code, cov_pipe,
						Lab_Test_Codes->list[dt.seq].Hospital_Name, cov_pipe,
						Lab_Test_Codes->list[dt.seq].Order_Test_Code, cov_pipe,
						Lab_Test_Codes->list[dt.seq].Order_Test_Name, cov_pipe,
						Lab_Test_Codes->list[dt.seq].Analyte_Test_Code, cov_pipe,
						Lab_Test_Codes->list[dt.seq].Analyte_Test_Name
						)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < Lab_Test_Codes->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",Lab_Test_Codes->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Hospital_Code", cov_pipe,
						"Hospital_Name", cov_pipe,
						"Order_Test_Code", cov_pipe,
						"Order_Test_Name", cov_pipe,
						"Analyte_Test_Code", cov_pipe,
						"Analyte_Test_Name"
						)
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
;CALL ECHORECORD (Lab_Test_Codes)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
/****************************************************************************
	Patient Type Codes
*****************************************************************************/
 
;  Set astream path
SET file_var = "Covenant_PatientTypeCodes_"
SET filepath_var = "/cerner/w_custom/p0665_cust/from_client_site/dg_folder/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".dsv"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
RECORD Patient_Type_Codes (
	1 output_cnt = i4
	1 list[*]
	    2 Hospital_Code = C100
	    2 Patient_Type_Code = F8
	    2 Patient_Type_Description = C100
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Patient Type Codes Data ******")
/**************************************************************
; Get Patient Type Codes Data
**************************************************************/
 
SELECT DISTINCT
Hospital_Code = ''
, Patient_Type_Code = cv1.code_value
, Patient_Type_Description = TRIM(cv1.description,3)
FROM CODE_VALUE cv1
PLAN cv1 WHERE cv1.code_set = 71
	AND cv1.active_ind = 1
ORDER BY CNVTUPPER(TRIM(cv1.description,3)), Patient_Type_Code
 
 
/****************************************************************************
	Populate Record structure with Patient Type Codes Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(Patient_Type_Codes->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(Patient_Type_Codes->list, cnt + 9)
	ENDIF
 
	Patient_Type_Codes->list[cnt].Hospital_Code = Hospital_Code
	Patient_Type_Codes->list[cnt].Patient_Type_Code = Patient_Type_Code
	Patient_Type_Codes->list[cnt].Patient_Type_Description = Patient_Type_Description
 
FOOT REPORT
 	Patient_Type_Codes->output_cnt = cnt
 	CALL alterlist(Patient_Type_Codes->list, cnt)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(Patient_Type_Codes->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output Patient Type Codes Data
*****************************************************************************/
 
IF (Patient_Type_Codes->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = Patient_Type_Codes->output_cnt)
 
	HEAD REPORT
		output_rec = build("Hospital_Code", cov_pipe,
						"Patient_Type_Code", cov_pipe,
						"Patient_Type_Description"
						)
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						Patient_Type_Codes->list[dt.seq].Hospital_Code, cov_pipe,
						Patient_Type_Codes->list[dt.seq].Patient_Type_Code, cov_pipe,
						Patient_Type_Codes->list[dt.seq].Patient_Type_Description
						)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < Patient_Type_Codes->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",Patient_Type_Codes->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Hospital_Code", cov_pipe,
						"Patient_Type_Code", cov_pipe,
						"Patient_Type_Description"
						)
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
;CALL ECHORECORD (Patient_Type_Codes)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
/****************************************************************************
	Hospital Location Codes
*****************************************************************************/
 
;  Set astream path
SET file_var = "Covenant_HospitalLocationCodes_"
SET filepath_var = "/cerner/w_custom/p0665_cust/from_client_site/dg_folder/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".dsv"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
RECORD Hospital_Location_Codes (
	1 output_cnt = i4
	1 list[*]
	    2 Location_Code = C100
	    2 Location_Description = C100
	    2 Region_Code = C100
	    2 Region_Name = C100
	    2 Hospital_Code = C100
	    2 Hospital_Name = C100
	    2 Location_Type_Code = C100
	    2 Location_Type_Description = C100
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Hospital Location Codes Data ******")
/**************************************************************
; Get Hospital Location Codes Data
**************************************************************/
 
SELECT DISTINCT
REGION_SVC_AREA = UAR_GET_CODE_DISPLAY(LGSA.PARENT_LOC_CD)
, HOSPITAL = UAR_GET_CODE_DISPLAY(LGH.PARENT_LOC_CD)
, BUILDING = UAR_GET_CODE_DISPLAY(LGH.CHILD_LOC_CD)
, NURSE_AMB = UAR_GET_CODE_DISPLAY(LGB.CHILD_LOC_CD)
, ROOM = UAR_GET_CODE_DISPLAY(LGN.CHILD_LOC_CD)
, BED = UAR_GET_CODE_DISPLAY(LGR.CHILD_LOC_CD)
, HOSPITAL_DESC = UAR_GET_CODE_DESCRIPTION(LGH.PARENT_LOC_CD)
, BUILDING_DESC = UAR_GET_CODE_DESCRIPTION(LGH.CHILD_LOC_CD)
, NURSE_DESC = UAR_GET_CODE_DESCRIPTION(LGB.CHILD_LOC_CD)
, NURSE_AMB_LOC_TYPE = UAR_GET_CODE_DISPLAY(LGN.LOCATION_GROUP_TYPE_CD)
, ROOM_DESC = UAR_GET_CODE_DESCRIPTION(LGN.CHILD_LOC_CD)
, BED_DESC = UAR_GET_CODE_DESCRIPTION(LGR.CHILD_LOC_CD)
, HOSPITAL_CD = LGH.PARENT_LOC_CD
, BUILDING_CD = LGH.CHILD_LOC_CD
, NURSE_AMB_CD = LGB.CHILD_LOC_CD
, ROOM_CD = LGN.CHILD_LOC_CD
, BED_CD = LGR.CHILD_LOC_CD
, Location_Code = ''
, Location_Description = ''
, Region_Code = ''
, Region_Name = ''
, Hospital_Code = ''
, Hospital_Name = ''
, Location_Type_Code = ''
, Location_Type_Description = ''
FROM LOCATION_GROUP LGH
, LOCATION_GROUP LGB
, LOCATION_GROUP LGN
, LOCATION_GROUP LGR
, LOCATION_GROUP LGSA
PLAN LGH ;HOSPITAL
WHERE LGH.LOCATION_GROUP_TYPE_CD = 783 ;FACILITY
JOIN LGB ;BUILDING
WHERE LGB.PARENT_LOC_CD = LGH.CHILD_LOC_CD
AND LGB.LOCATION_GROUP_TYPE_CD = 778 ;BUILDING
JOIN LGN ;NURSE/AMBULATORY
WHERE LGN.PARENT_LOC_CD = LGB.CHILD_LOC_CD
AND LGN.LOCATION_GROUP_TYPE_CD IN (794 /*Nurse Unite*/, 772 /*Ambulatory*/) ;NURSE UNIT/AMB
JOIN LGR ;ROOM
WHERE LGR.PARENT_LOC_CD = LGN.CHILD_LOC_CD
AND LGR.LOCATION_GROUP_TYPE_CD = 801 ;ROOM
JOIN LGSA ;REGION/SERVICE AREA
WHERE LGSA.CHILD_LOC_CD = OUTERJOIN(LGB.PARENT_LOC_CD)
AND LGSA.LOCATION_GROUP_TYPE_CD = OUTERJOIN(805) ;SERVICE AREA
ORDER BY HOSPITAL
, BUILDING
, NURSE_AMB
, ROOM
, BED
, REGION_SVC_AREA
 
 
/****************************************************************************
	Populate Record structure with Hospital Location Codes Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(Hospital_Location_Codes->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(Hospital_Location_Codes->list, cnt + 9)
	ENDIF
 
	Hospital_Location_Codes->list[cnt].Location_Code = Location_Code
	Hospital_Location_Codes->list[cnt].Location_Description = Location_Description
	Hospital_Location_Codes->list[cnt].Region_Code = Region_Code
	Hospital_Location_Codes->list[cnt].Region_Name = Region_Name
	Hospital_Location_Codes->list[cnt].Hospital_Code = Hospital_Code
	Hospital_Location_Codes->list[cnt].Hospital_Name = Hospital_Name
	Hospital_Location_Codes->list[cnt].Location_Type_Code = Location_Type_Code
	Hospital_Location_Codes->list[cnt].Location_Type_Description = Location_Type_Description
 
FOOT REPORT
 	Hospital_Location_Codes->output_cnt = cnt
 	CALL alterlist(Hospital_Location_Codes->list, cnt)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(Hospital_Location_Codes->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output Hospital Location Codes Data
*****************************************************************************/
 
IF (Hospital_Location_Codes->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = Hospital_Location_Codes->output_cnt)
 
	HEAD REPORT
		output_rec = build("Location_Code", cov_pipe,
							"Location_Description", cov_pipe,
							"Region_Code", cov_pipe,
							"Region_Name", cov_pipe,
							"Hospital_Code", cov_pipe,
							"Hospital_Name", cov_pipe,
							"Location_Type_Code", cov_pipe,
							"Location_Type_Description"
						)
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						Hospital_Location_Codes->list[dt.seq].Location_Code, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Location_Description, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Region_Code, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Region_Name, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Hospital_Code, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Hospital_Name, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Location_Type_Code, cov_pipe,
						Hospital_Location_Codes->list[dt.seq].Location_Type_Description
						)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < Hospital_Location_Codes->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",Hospital_Location_Codes->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Location_Code", cov_pipe,
							"Location_Description", cov_pipe,
							"Region_Code", cov_pipe,
							"Region_Name", cov_pipe,
							"Hospital_Code", cov_pipe,
							"Hospital_Name", cov_pipe,
							"Location_Type_Code", cov_pipe,
							"Location_Type_Description"
						)
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
;CALL ECHORECORD (Hospital_Location_Codes)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
/****************************************************************************
	Provider Details
*****************************************************************************/
 
;  Set astream path
SET file_var = "Covenant_ProviderDetails_"
SET filepath_var = "/cerner/w_custom/p0665_cust/from_client_site/dg_folder/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".dsv"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
RECORD Provider_Details (
	1 output_cnt = i4
	1 list[*]
	    2 Provider_ID = F8
	    2 Provider_Name = C100
	    2 NPI = C20
	    2 Specialty_Code = F8
	    2 Specialty_Description = C100
	    2 Department_Code = F8
	    2 Department_Name = C100
	    2 Practice_Name = C100
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Provider Details Data ******")
/**************************************************************
; Get Provider Details Data
**************************************************************/
 
SELECT DISTINCT
PROVIDER_ID = P.PERSON_ID
, PROVIDER_NAME = P.NAME_FULL_FORMATTED
, NPI = PA.ALIAS
, SPECIALTY_CODE = PG.PRSNL_GROUP_TYPE_CD
, SPECIALTY_DESCRIPTION = PG.PRSNL_GROUP_NAME
, DEPARTMENT_CODE = P.POSITION_CD
, DEPARTMENT_NAME = UAR_GET_CODE_DISPLAY(P.POSITION_CD)
, PHYSICIAN_STATUS = UAR_GET_CODE_DISPLAY(P.PHYSICIAN_STATUS_CD)
, PRACTICE_CODE = PO.ORGANIZATION_ID
, PRACTICE_NAME = ORG.ORG_NAME
FROM PRSNL P
, PRSNL_ALIAS PA
, PRSNL_GROUP_RELTN PGR
, PRSNL_GROUP PG
, PRSNL_ORG_RELTN PO
, ORGANIZATION ORG
PLAN P WHERE P.PHYSICIAN_IND = 1
AND p.person_id = 12401322  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;REMOVE
JOIN PA WHERE PA.PERSON_ID = OUTERJOIN(P.PERSON_ID)
AND PA.PRSNL_ALIAS_TYPE_CD = 4038127.00 ;NPI
JOIN PGR WHERE PGR.PERSON_ID = OUTERJOIN(P.PERSON_ID)
JOIN PG WHERE PG.PRSNL_GROUP_ID = OUTERJOIN(PGR.PRSNL_GROUP_ID)
AND PG.PRSNL_GROUP_CLASS_CD = OUTERJOIN(678635.00  /* Service */)
JOIN PO WHERE PO.PERSON_ID = OUTERJOIN(P.PERSON_ID)
JOIN ORG WHERE ORG.ORGANIZATION_ID = OUTERJOIN(PO.ORGANIZATION_ID)
ORDER BY PROVIDER_NAME
, NPI
, SPECIALTY_DESCRIPTION
, DEPARTMENT_NAME
, PRACTICE_NAME
 
 
/****************************************************************************
	Populate Record structure with Provider Details Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(Provider_Details->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(Provider_Details->list, cnt + 9)
	ENDIF
 
	Provider_Details->list[cnt].Provider_ID = Provider_ID
	Provider_Details->list[cnt].Provider_Name = Provider_Name
	Provider_Details->list[cnt].NPI = NPI
	Provider_Details->list[cnt].Specialty_Code = Specialty_Code
	Provider_Details->list[cnt].Specialty_Description = Specialty_Description
	Provider_Details->list[cnt].Department_Code = Department_Code
	Provider_Details->list[cnt].Department_Name = Department_Name
	Provider_Details->list[cnt].Practice_Name = Practice_Name
 
FOOT REPORT
 	Provider_Details->output_cnt = cnt
 	CALL alterlist(Provider_Details->list, cnt)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(Provider_Details->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output Provider Details Data
*****************************************************************************/
 
IF (Provider_Details->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = Provider_Details->output_cnt)
 
	HEAD REPORT
		output_rec = build("Provider_ID", cov_pipe,
							"Provider_Name", cov_pipe,
							"NPI", cov_pipe,
							"Specialty_Code", cov_pipe,
							"Specialty_Description", cov_pipe,
							"Department_Code", cov_pipe,
							"Department_Name", cov_pipe,
							"Practice_Name"
						)
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						Provider_Details->list[dt.seq].Provider_ID, cov_pipe,
						Provider_Details->list[dt.seq].Provider_Name, cov_pipe,
						Provider_Details->list[dt.seq].NPI, cov_pipe,
						Provider_Details->list[dt.seq].Specialty_Code, cov_pipe,
						Provider_Details->list[dt.seq].Specialty_Description, cov_pipe,
						Provider_Details->list[dt.seq].Department_Code, cov_pipe,
						Provider_Details->list[dt.seq].Department_Name, cov_pipe,
						Provider_Details->list[dt.seq].Practice_Name
						)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < Provider_Details->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",Provider_Details->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Provider_ID", cov_pipe,
							"Provider_Name", cov_pipe,
							"NPI", cov_pipe,
							"Specialty_Code", cov_pipe,
							"Specialty_Description", cov_pipe,
							"Department_Code", cov_pipe,
							"Department_Name", cov_pipe,
							"Practice_Name"
						)
 
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
;CALL ECHORECORD (Provider_Details)
 
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

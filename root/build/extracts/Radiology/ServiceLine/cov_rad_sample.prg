/*****************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 2008 Cerner Corporation                      *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
      ***********************************************************************/
 
/*****************************************************************************
 
******************************************************************************/
/***********************************************************************************************************************
*                           GENERATED MODIFICATION CONTROL LOG
************************************************************************************************************************
*                                                                                                                      *
* Feature  Mod Date       Engineer      Comment                                                                        *
* -------  --- ---------- ---------- ----------------------------------------------------------------------------------*
* 		   000 05/14/2018 ARG     	Initial release (Alix Govatsos)                                                    *
* 		   001 10/10/2018 TAB     	Added physician: WOOLDRIDGE, THOMAS MAJOR MD                                       *
* 		   002 10/11/2018 TAB     	Adjusted for efficiency                                                            *
* 		   003 10/17/2018 TAB     	Added logic for symbol mapping                                                     *
 
************************* END OF ALL MODCONTROL BLOCKS *****************************************************************/
 
DROP PROGRAM 	COV_RAD_VISTA_EXT:dba GO
CREATE PROGRAM 	COV_RAD_VISTA_EXT:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date:" = "SYSDATE"
	, "End Date:" = "SYSDATE"
	, "Select a Facility:" = VALUE(0.0)
 
with POUTDEV, pSTART_DATE, pEND_DATE, pFACILITY
 
/***************************************************************************************
* Prompt Evaluation																	   *
***************************************************************************************/
 
 
;ops setup
if (VALIDATE(request->batch_selection) = 1)
	SET iOpsInd = 1
 	SET START_DATE = DATETIMEFIND(CNVTDATETIME(CURDATE-3, 000000),'D','B','B')
	SET END_DATE   = DATETIMEFIND(CNVTDATETIME(CURDATE-3, 235959),'D','B','E')
 else
 
	SET START_DATE  = CNVTDATETIME($pSTART_DATE)
	SET END_DATE    = CNVTDATETIME($pEND_DATE)
 
endif
 
CALL ECHO(BUILD('bdate :', START_DATE))
CALL ECHO(BUILD('edate :', END_DATE))
 
 
/***************************************************************************************
* Variable Declarations																   *
***************************************************************************************/
 
record output (
	1 temp = vc
	1 locator = vc
	1 filename = vc
	1 filenameD = vc
	1 directory = vc
	1 astream = vc
	1 temp_demo = vc
	1 temp_dict = vc
)
 
set output->directory = logical("cer_temp")
set output->filename = concat(format(curdate, "yyyymmdd;;d"), '_cer', '.vst')
set output->filenamed = concat('vistacode',format(curdate, "yyyymmdd;;d"), '_cer', '.del')
set output->astream = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Radiology/Extracts/Vista/"
set output->temp_demo = concat('cer_temp:' , format(curdate, "yyyymmdd;;d"), '_cer', '.vst')
set output->temp_dict = concat('cer_temp:' , 'vistacode',  format(curdate, "yyyymmdd;;d"),'_cer', '.del')
 
call echorecord (output)
 
RECORD rDATA(
1 ENC[*]						;one occurrence per exam per encouonter per patient
2	ENCNTR_ID	= 	f8
2	PERSON_ID	= 	f8
2	FIRST_NAME	= 	vc
2	LAST_NAME	= 	vc
2	M_name 		= 	vc
2	NAME		= 	vc ;	3
2	ADDRESS		= 	vc	 ;	28
2	ADDRESS2	= 	vc	 ;	50
2	CITY	 	= 	vc	 ;	65
2	STATE	 	= 	vc	 ;	80
2	ZIPCODE	 	= 	vc	 ;	82
2	PHONE_HOME	= 	vc	 ;	92
2	PHONE_BIZ	= 	vc	 ;	102
2	BIRTH_DT_TM	= 	dq8
2	student_ind	= 	vc
2	emp_stat_ind	= vc
2	DOB	 		= 	c6	 ;	112
2	dob_year	= c4	;	format(p.birth_dt_tm ,"yyyy;;d")
2	dob_month	= c2  	;	format(p.birth_dt_tm ,"mm;;d")
2	dob_day		= c2	;	format(p.birth_dt_tm ,"dd;;d")
2	SEX	 		= 	VC
2	SEX_ALIAS	= 	vc	 ;	118
2	FIN	 = 	vc ;	119
2	emp_status	= vc
2 	emp_name 	= vc
2 	EMP_CITY 	= vc
2 	EMP_ADDR1 	= vc
2 	EMP_ADDR2 	= vc
2 	EMP_ZIP		= vc
2 	EMP_ST 		= vc
2	SSN	 		= 	vc	 ;	170
2	FAMILY_NAME	= 	vc ;	181
2	MARITAL	 = 	VC
2   ethnicity = vc
2	MARITAL_ALIAS	 = 	vc	 ;	335
2	admit_dt_tm	 = 	dq8
2	admit_date	 = 	c6	 ;	339
2	disch_dt_tm	 = 	dq8
2	disch_date	 = 	c6	 ;	345
2	pat_type_ioe = 	c1	 ;	351
2	MRN	 		= 	vc	 ;	358
;	haglines2	= 	c25	 ;	375
2   encntr_plan_reltn_id_A = f8
2   encntr_plan_reltn_id_B = f8
2   encntr_plan_reltn_id_C = f8
2	Insurance_Plan_Name_A 	= 	vc	 ;	401
2	Insurance_Address_1_A 	= 	vc	 ;	421
2	Insurance_City_A 	 	= 	vc	 ;	441
2	Insurance_State_A 	 	= 	vc	 ;	456
2	Insurance_Zip_Code_A 	= 	vc	 ;	458
2   Insurance_Phone_A		=   vc
2	Insurance_Insured_A 	= 	vc	 ;	468
2   II_A_person_id	= f8
2	Insurance_Subscriber_Address_1_A = vc	 ;	488
2	Insurance_Subscriber_City_A	 	 = vc	 ;	508
2	Insurance_Subscriber_State_A	 = vc	 ;	523
2	Insurance_Subscriber_Zip_Code_A	 = vc	 ;	525
2	Insurance_Policy_No_A 	 	= vc	 ;	535
2	Insurance_Group_No_A 	 	= vc	 ;	549
;	pinsdiag_code	 		= 	c8	 ;	563
2	Insurance_Rel_to_Pt_A 	= 	VC	 ;	571
;	pacptasn	 			= 	c1	 ;	573
2	Insurance_Plan_Code_A 	= 	vc	 ;	574
2	Insurance_SuscriberPhone_A 		= 	vc
2 	Insurance_SuscriberNameF_A		= 	vc
2 	Insurance_SuscriberNameL_A		= 	vc
2 	Insurance_SuscriberNameM_A		= 	vc
2 	Insurance_SuscriberEmpName_A	= 	vc
2 	Insurance_SuscriberEmpAdd1_A	= 	vc
2 	Insurance_SuscriberEmpZip_A		= 	vc
2 	Insurance_Suscriber_A	= 	vc
2	Insurance_Plan_Name_B	 	= vc	 ;	601
2	Insurance_Address_1_B	 	= vc	 ;	621
2	Insurance_City_B	 	 	= vc	 ;	641
2	Insurance_State_B	 	 	= vc	 ;	656
2	Insurance_Zip_Code_B	 	= vc	 ;	658
2   Insurance_Phone_B			= vc
2	Insurance_Insured_B	 	 	= vc	 ;	668
2   II_B_person_id	= f8
2	Insurance_Subscriber_Address_1_B 	= 	c20	 ;	688
2	Insurance_Subscriber_City_B 	 	= 	c15	 ;	708
2	Insurance_Subscriber_State_B 	 	= 	c2	 ;	723
2	Insurance_Subscriber_Zip_Code_B 	= 	c10	 ;	725
2	Insurance_Policy_No_B	= vc	 ;	735
2	Insurance_Group_No_B	= 	 vc	 ;	749
2	Insurance_Rel_to_Pt_B 	= 	 vc	 ;	771
2	Insurance_Plan_Code_B	= 	 vc	 ;	774
2	Insurance_SuscriberPhone_B 		= 	vc
2 	Insurance_SuscriberNameF_B		= 	vc
2 	Insurance_SuscriberNameL_B		= 	vc
2 	Insurance_SuscriberNameM_B		= 	vc
2 	Insurance_SuscriberEmpName_B	= 	vc
2 	Insurance_SuscriberEmpAdd1_B	= 	vc
2 	Insurance_SuscriberEmpZip_B		= 	vc
;	saglines4	 			= vc
2	Insurance_Plan_Name_C		= vc
2	Insurance_Address_1_C		= vc
2	Insurance_City_C	 		= vc
2	Insurance_State_C	 		= vc
2	Insurance_Zip_Code_C		= vc
2   Insurance_Phone_C			=   vc
2	Insurance_Insured_C	 		= vc
2   II_C_person_id	= f8
2	Insurance_Subscriber_Address_1_C		= vc
2	Insurance_Subscriber_City_C	 			= vc
2	Insurance_Subscriber_State_C	 		= vc
2	Insurance_Subscriber_Zip_Code_C	 		= vc
2	Insurance_Policy_No_C	 		= vc
2	Insurance_Group_No_C	 		= vc
;	tinsdiag_code	 		 		= vc
2	Insurance_Rel_to_Pt_C	 		= vc
;	tacptasn	 			 		= vc
2	Insurance_Plan_Code_C	 		= vc
;	taglines5	 			 		= vc
2	Insurance_SuscriberPhone_C 		= 	vc
2 	Insurance_SuscriberNameF_C		= 	vc
2 	Insurance_SuscriberNameL_C		= 	vc
2 	Insurance_SuscriberNameM_C		= 	vc
2 	Insurance_SuscriberEmpName_C	= 	vc
2 	Insurance_SuscriberEmpAdd1_C	= 	vc
2 	Insurance_SuscriberEmpZip_C		= 	vc
2	Authorization_Number_A 	 		= vc
2	Authorization_Number_B 	 		= vc
2	Authorization_Number_C 	 		= vc
2 	RADIOLOGIST_ID	=	VC
2 	rad_dr_name_f	=   vc
2 	rad_dr_name_l  	=  Vc
2	rad_dr_name 	=  vc
2 	ATTENDING_ID	=	 VC
2   rad_report_id 	= f8
2 	PCP_ID 			=	 VC
2 	pcp_name		=	 Vc
2 	FAMILY_ID 		=	 VC
2   guarperson_id	= 	f8
2 	guarFirstName	=	 Vc
2	guarLastName	=	 Vc
2	guarMiddleName	=	 Vc
2	guarDateOfBirth	=	 dq8
2	guarAddress1	=	 Vc
2	guarAddress2	=	 Vc
2	guarZipcode		=	 Vc
2	guarPhone		=	 Vc
2	guarSSN	  		=	 Vc
2	guarempName		=	 Vc
2	guarempAddress1	=	 Vc
2	guarempZipcode	=	 Vc
2	guarempPhone	=	 Vc
2	guarRel			= 	 vc
2   REFERRING_ID	=	 VC
2   referring_name	=    Vc
2   referring_upin	=   Vc
2 ORDERING_ID		=	 VC
2 ord_dr_name_f		=   vc
2 ord_dr_name_l  	=   vc
2 ord_dr_name 		=   vc
2 order_id 			=	f8
2 oid_disp			= vc
2 order_mnem		= 	vc
2 order_cat_cd		= vc
2 RAD_PROC_TYPE		= VC
2 PRINCIPAL_DX		=	 VC
2 ADMIT_DX			= VC
2 FINAL_DX			= VC
2 work_dx			= vc
2 event_id			=	 f8
2 RESULT_STATUS_CD	 = F8
2 accession			=    vc
2 accessiond		= vc
2 check_in_dt_tm	= 	dq8
2 check_in_d		= 	 c2
2 check_in_m		= 	 c2
2 check_out_dt_tm	= 	dq8
2 check_out_d		= 	 c2
2 check_out_m		= 	 c2
2 check_out_y		= 	 c2
2 check_in_y		= 	 c2
2 expired			=	 vc
2 expired_alias		 	 	= vc
2 FACILITY_CD		=	 F8
2 FACILITYCD		=	 vc
2 FACILITY			=	 VC
2 site					= vc
2 NU_CD				=	 F8
2 NU 				=	 VC
2 acc_dt_tm			= 	dq8
2 acc_loc			=   Vc
2 acc_st 			= vc
2 acc_type			= 	vc
2 acc_ore			= 	vc
2 pat_type			=	vc
2 pat_type_alias	=	c3
2 pat_type_class	=	vc
2 perf_dept			=	vc ;003
2 note_sig			= 	vc
2 ADDENDED	 		= 	vc
2 APPROVED	 		= 	vc
2 CORRECTED	 		= 	vc
2 COSIGNED	 		= 	vc
2 DICTATED	 		= 	vc
2 MODIFIED	 		= 	vc
2 TRANSCRIBED 		= 	vc
2 ADDENDED_dt_tm	= 	dq8
2 APPROVED_dt_tm	= 	dq8
2 CORRECTED_dt_tm	= 	dq8
2 COSIGNED_dt_tm	= 	dq8
2 DICTATED_dt_tm	= 	dq8
2 MODIFIED_dt_tm	= 	dq8
2 TRANSCRIBed_dt_tm = 	dq8
2 cptcd				= vc
2 cptcdmod			= vc
1 total = i4
1 subt_demo = i4
1 subt_dict = i4
)
 
set ins_seq_count = 0
 
;CREATE RECORD STRUCTURE
FREE RECORD FREC
RECORD FREC(
    1 FILE_DESC = I4
    1 FILE_NAME = VC
    1 FILE_BUF = VC
    1 FILE_DIR = I4
    1 FILE_OFFSET = I4
)
 
 
;***********************************************************************************************************
;Non constants
SET CNT = 0 ;Already defined in include file
 
DECLARE OUTPUT_FILENAME = VC
DECLARE OUTPUT_STRING = VC WITH NOCONSTANT(" "), PUBLIC
SET CARRIAGE_RETURN  = CHAR(13)
declare num = i4 with noconstant(0), protect
declare cntr = i4 with noconstant(0), protect
declare numx = i4 with noconstant(0), protect
declare cntx = i4 with noconstant(0), protect
declare pos = i4 with noconstant(0), protect
declare idx = i4 with noconstant(0), protect
set pcvar = concat("|",char(9))
 
;Clinical_event Status
DECLARE INERROR_ROW_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!8419")) ;Row created in error
DECLARE INERROR_MUT_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!20644")) ;In Error - Non-mutable
DECLARE INERROR_DISP_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!20645")) ;In Error - do not display
DECLARE INERROR_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!7982")) ;In Error
declare auth_ver_cd		= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!2628")) ;AUTH
DECLARE TRANSCRIBED_CD  = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 8, "TRANSCRIBED")) ;TRANSCRIBED
declare altered_cd		= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!16901"));	MODIFIED
declare modified_cd		= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!2636"));	MODIFIED
 
;event actions
declare	MODIFY_21_cd	 	= 	 f8 with Constant(uar_get_code_by("MEANING",21, "MODIFY"	)),protect
declare	PERFORM_21_cd	 	= 	 f8 with Constant(uar_get_code_by("MEANING",21, "PERFORM"	)),protect
declare	REVIEW_21_cd	 	= 	 f8 with Constant(uar_get_code_by("MEANING",21, "REVIEW"	)),protect
declare	SIGN_21_cd	 		= 	 f8 with Constant(uar_get_code_by("MEANING",21, "SIGN"	)),protect
declare	TRANSCRIBE_21_cd	= 	 f8 with Constant(uar_get_code_by("MEANING",21, "TRANSCRIBE"	)),protect
declare	VERIFY_21_cd	 	= 	 f8 with Constant(uar_get_code_by("MEANING",21, "VERIFY"	)),protect
 
declare	ADDENDED_28880_cd	 = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "ADDENDED")),protect
declare	APPROVED_28880_cd	 = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "APPROVED")),protect
declare	CORRECTED_28880_cd	 = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "CORRECTED")),protect
declare	COSIGNED_28880_cd	 = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "COSIGNED")),protect
declare	DICTATED_28880_cd	 = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "DICTATED")),protect
declare	MODIFIED_28880_cd	 = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "MODIFIED")),protect
declare	TRANSCRIBED_28880_cd = 	 f8 with Constant(uar_get_code_by("MEANING",28880, "TRANSCRIBED")),protect
 
DECLARE OTHERETHNICITY_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",356,"OTHERETHNICITY"))
DECLARE OTHERRACE_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",356,"OTHERRACE"))
DECLARE HISPANIC_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",27,"HISPANIC"))
DECLARE NOTHISPANIC_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",27,"NOTHISPANIC"))
 
declare defguar_cd 			= f8 with Constant(uar_get_code_by("MEANING", 351, "DEFGUAR")), protect
 
;dept status 14281
declare	COMPLETED_14281_CD 		= f8 with Constant(uar_get_code_by("MEANING",14281, "COMPLETED")),protect
declare	CVSIGNED_14281_CD  		= f8 with Constant(uar_get_code_by("MEANING",14281, "CVSIGNED")),protect
declare	CVVERIFIED_14281_CD 	= f8 with Constant(uar_get_code_by("MEANING",14281, "CVVERIFIED")),protect
declare	RADCOMPLETED_14281_CD 	= f8 with Constant(uar_get_code_by("MEANING",14281, "RADCOMPLETED")),protect
 
 
;Order Status
DECLARE COMPLETED_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!3100")) ;COMPLETED
DECLARE CANCELED_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!3099")) ;Canceled
DECLARE DELETED_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!44311")) ;Void W/o Results
DECLARE VOIDWRESULT_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!2488992")) ;Void W Results
DECLARE TRANSFER_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!406488")) ;Transfer/Cancel
 
 ; patient events
declare STARTINPAT_CD 	= f8 with Constant(uar_get_code_by("MEANING",4002773,"STARTINPAT")),protect
declare STARTOBS_CD 	= f8 with Constant(uar_get_code_by("MEANING",4002773,"STARTOBS")),protect
declare OUTPATINBED_CD 	= f8 with Constant(uar_get_code_by("MEANING",4002773,"OUTPATINBED")),protect
declare DISCHRG_CD		= f8 with Constant(uar_get_code_by("MEANING",4002773,"DISCHRG")),protect
 
 
;EPR reltn
DECLARE ATTENDDOC_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4024"))
DECLARE REFERDOC_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4597"))
DECLARE PROVIDER_GROUP_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!111133"))
 
;PPR reltn
declare PCP_CD 		= f8 with Constant(uar_get_code_by("MEANING",331,"PCP")),protect
declare FAMILY_CD	= f8 with Constant(uar_get_code_by("MEANING",331,"FAMILYDOC")),protect
 
;NPI ALIAS
DECLARE NPI_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!2160654021"))
 
 ;Problem/DX vocabulary (code set 400)
DECLARE ICD10_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!56781"))
DECLARE FINAL_DX_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"FINAL"))
DECLARE PRINCIPAL_DX_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"PRINCIPAL"))
DECLARE VISITREASON_DX_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"REASONFORVISIT"))
DECLARE ADMIT_DX_CD         = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"ADMITTING"))
DECLARE DISCH_DX_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"DISCHARGE"))
DECLARE WORKING_DX_CD		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"WORKING"))
DECLARE ICD10PCS_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4101496118"))
DECLARE ICD10CM_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4101498946"))
 
DECLARE HCPCS_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!42457"))
declare pned_cd 			= f8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!723952686"))
 DECLARE CPT4_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14002,"CPT"))
 DECLARE CPT4_MOD_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",14002,"CPTMODIFIER"))
 
 
;Procedure rank
DECLARE CM_ICD9PROC_CD	= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!3474"))
 
;Address type
DECLARE HOME_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!4018"))
DECLARE TEMPORARY_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!8014"))
DECLARE ALTERNATE_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!9559"))
DECLARE USA_CD	 	 = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",15,"US"))
 
;Financial class
DECLARE MEDICAID_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",354,"MEDICAID"))
DECLARE WORKERSCOMP_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",354,"WORKERSCOMP"))
DECLARE AUTO_CD 			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",354,"AUTO"))
DECLARE FREECARE_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",354,"FREECARE"))
DECLARE SELFPAY_CD 			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",354,"SELFPAY"))
 
;Encounter types
DECLARE OUTPATIENT_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",71,"OUTPATIENT"))
DECLARE INPATIENT_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",71,"INPATIENT"))
DECLARE EMERGENCY_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",71,"EMERGENCY"))
DECLARE OBSERVATION_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",71,"OBSERVATION"))
DECLARE INPATIENT_CLASS_CD = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",69,"INPATIENT"))
 
;Radiology order exam status
declare rad_canceled_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"CANCELED"))
declare rad_completed_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"COMPLETED"))
declare rad_inprocess_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"INPROCESS"))
declare rad_onhold_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"ONHOLD"))
declare rad_ordered_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"ORDERED"))
declare rad_removed_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"REMOVED"))
declare rad_replaced_CD 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"REPLACED"))
declare rad_started_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY" ,14192 ,"STARTED"))
 
 
;Alias
DECLARE MRN_CD	 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",4,"MRN"))
declare cmrn_cd 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",4,"CMRN"))
DECLARE MRN_POOL_CD	= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",263,"MRN"))
DECLARE SSN_CD	 	= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",4,"SSN"))
DECLARE FIN_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("MEANING",319,"FIN NBR"))
 
 
if(substring(1,1,reflect(parameter(parameter2($pFACILITY),0))) = "L") ;multiple dispositions were selected
	set FAC_VAR = "in"
	elseif(parameter(parameter2($pFACILITY),1) = 0.0) ;all (any) dispositions were selected
		set FAC_VAR = "!="
	else ;a single value was selected
		set FAC_VAR = "="
endif
 
 
;contributor source
DECLARE COV_CD 		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",73,"COVENANT"))
declare iso_cd 		= f8 with constant(uar_Get_code_by("DISPLAYKEY", 73, "ISO"))
 
;HEALTH PLAN POOL
declare hplan_cd 	= f8 with constant(uar_Get_code_by("DISPLAYKEY", 263, "HEALTHPLAN"))
 
;doc numbers
declare stardoc_cd	= f8 with constant(uar_Get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))
declare statedoc_cd	= f8 with constant(uar_Get_code_by("DISPLAYKEY", 263, "STATELICENSENUMBER"))
 
 
/***************************************************************************************
* SUBROUTINE
***************************************************************************************/
DECLARE GET_CODE_VALUE_ALIAS(_CODE_VALUE = F8) = VC
 
SUBROUTINE GET_CODE_VALUE_ALIAS(_CODE_VALUE)
	DECLARE _CV_ALIAS = VC
 	IF (_CODE_VALUE > 0.0)
		SELECT into "nl:"
		CVA.ALIAS
		FROM CODE_VALUE_OUTBOUND CVA
		WHERE CVA.CODE_VALUE = _CODE_VALUE
			AND CVA.CONTRIBUTOR_SOURCE_CD = COV_CD
		DETAIL
			_CV_ALIAS = CVA.ALIAS
		WITH nocounter
		IF (TRIM(_CV_ALIAS) > "")
			RETURN(_CV_ALIAS)
		ELSE
			RETURN("X")
		ENDIF
 
	ELSE
		RETURN("")
	ENDIF
END ;SUBROUTINE
 
 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!***ENCOUNTER & PATIENT DATA
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;SELECT distinct INTO "NL:"
SELECT DISTINCT INTO VALUE ($POUTDEV)
	 encntr_id = e.encntr_id
	, person_id = e.person_id
	, name_first = p.name_first
	, name_last = p.name_last
	, marital = cnvtstring(p.marital_type_cd)
	, name_mi = cnvtupper(substring(1,1,p.name_middle))
	, dob_year = format(p.birth_dt_tm ,"yyyy;;d")
	, dob_month = format(p.birth_dt_tm ,"mm;;d")
	, dob_day = format(p.birth_dt_tm ,"dd;;d")
	, fin = ea.alias
	, cmrn = cnvtalias(pa3.alias, pa3.alias_pool_cd)
;	, mrn = pa1.alias
	, ssn = pa2.alias
	, sex = cnvtstring( p.sex_cd )
	, expired = cnvtstring(p.deceased_cd)
	, pat_type = cnvtstring(e.encntr_type_cd)
	, PAT_TYPE_CLASS = CNVTSTRING(E.encntr_type_class_cD)
	, fac = cnvtstring(e.loc_facility_cd)
	, fac_cd = e.loc_facility_cd
	, fac_disp = uar_get_code_display(e.loc_facility_cd)
	, nu_disp = uar_get_code_display(e.loc_nurse_unit_cd)
	, reg_dt_tm = e.reg_dt_tm "mm/dd/yyyy hh:mm;;d"
	, dsch_dt_tm = e.disch_dt_tm "mm/dd/yyyy hh:mm;;d"
	, pat_type = uar_get_code_display(e.encntr_type_cd)
	, perf_dept = uar_get_code_display(oros.perf_dept_cd) ;003
	, accession_o = cnvtacc(o.accession)
	, accession_ce = cnvtacc (ce.accession_nbr)
	, rad_order = uar_get_code_display (o.catalog_cd)
	, order_dt_tm = o.start_dt_tm "mm/dd/yyyy hh:mm;;d"
	, complete_dt_tm = o.complete_dt_tm "mm/dd/yyyy hh:mm;;d"
	, dept_status_cd = uar_get_code_display(ord.dept_status_cd)
	, ord.dept_status_cd
;	, posted_final = rr.posted_final_dt_tm "mm/dd/yyyy hh:mm;;d"
	, order_id = o.order_id
	, ord_type = uar_get_code_display(ord.catalog_type_cd )
	, CE.parent_event_id
	, ce.event_id
	, ce.view_level
	, oros.dictate_dt_tm "mm/dd/yyyy hh:mm;;d"
	, oros.exam_complete_dt_tm "mm/dd/yyyy hh:mm;;d"
	, oros.final_dt_tm "mm/dd/yyyy hh:mm;;d"
	, oros_exam_loc_cd = e.loc_facility_cd
	, oros_exam_loc_disp = uar_get_code_display(e.loc_facility_cd)
	, ORD_PHYS_NAME_FIRST = pr.name_first
	, ORD_PHYS_NAME_LAST = pr.name_last
	, ORD_PHYS_ALIAS = pa.alias
 
 
 
 FROM
	OMF_RADMGMT_ORDER_ST   OROS
	,ENCOUNTER   E
	, (left JOIN person_alias pa2 ON (e.person_id = pa2.person_id
 			AND pa2.person_alias_type_cd = SSN_CD
			AND pa2.ACTIVE_IND = 1
			AND pa2.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)))
	, person   p
	, encntr_alias   ea
;	, person_alias   pa1
	, person_alias   pa3
;	, code_value_outbound   cvo
	, orders   ord
	, PRSNL   PR
	, PRSNL_ALIAS   PA
	, clinical_event   ce
	, order_radiology   o
 
 
plan  oros
where not oros.final_dt_tm is NULL
and oros.updt_dt_tm between cnvtdatetime(start_date ) and cnvtdatetime(end_date)
; vista docs
AND oros.radiologist_id IN (
  12402904,12407702,12405172,12414755,12403265,12408509,12407618,12412601,12412551,12415167,12410379,
  12408644,12412518,12415268,12401868,12406088,12407676,12409657,12402011,12402163,12402124,12413640,
  12402832,12401881,12415299,12412431,12408616,12404314,12401913,12414350,12402135,12408728,12414620,
  12404066,12403157,12697806,12697932,12698094,16481313,12412689,12410454,12407333,12404833,12405095,
  16711957) ;001
 
 
join e
where e.encntr_id = oros.encntr_id
and operator(e.loc_facility_cd,  FAC_VAR, $pFACILITY)
 
 
JOIN  ea where ea.encntr_id = e.encntr_id
 			AND	 EA.ENCNTR_ALIAS_TYPE_CD = FIN_CD
			AND EA.ACTIVE_IND = 1
			AND EA.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
 
join 	p where  p.person_id = e.person_id
and  	p.active_ind = 1
 
 
;JOIN pa1 where e.person_id = pa1.person_id
; 			AND pa1.person_alias_type_cd = MRN_CD
;			AND pa1.ACTIVE_IND = 1
;			AND pa1.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
JOIN   pa3 where e.person_id = pa3.person_id
 			AND pa3.person_alias_type_cd = CMRN_CD
			AND pa3.ACTIVE_IND = 1
			AND pa3.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
;join 	CVO
;WHERE 	cvo.code_value = e.loc_facility_cd
;and  	CVO.code_set = 220
;AND 	CVO.ALIAS_TYPE_MEANING in ( "FACILITY", "AMBULATORY")
;AND 	CVO.contributor_source_cd =         2552933345.00
;
/*;discussion on 7/18 to NOT start with locations as it will be too hard to maintain over time.
;go by the docs only below and sort by location
;AND 	(CVO.alias IN ("F", "L", "P", "S", "R")
;or  	SUBSTRING(1,3,CVO.ALIAS) in ("EDF", "EDL", "EDP", "EDS", "EDR")) */
 
 
join  	o
where 	o.encntr_id = e.encntr_id
;and  	o.exam_status_cd in (rad_completed_CD) ;confirm
and 	o.accession = oros.accession_nbr
 
 
join ord
where ord.order_id = o.order_id
and ord.order_status_cd = COMPLETED_CD
 
join 	ce  ; do NOT use ce.encntr_id as some report records dont store the encntr_id issue for ambulatory discovered 8/23
where   ce.person_id = o.person_id
and 	ce.order_id = o.order_id
and		ce.valid_from_dt_tm >= cnvtdatetime(start_date)
and 	ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
and 	ce.event_end_dt_tm >= cnvtdatetime(start_date )
and 	ce.result_status_cd in ( auth_ver_cd, altered_cd, modified_cd)
and 	not substring(6,2,ce.accession_nbr) in ('CA', 'NP', 'SC')
 
/* old verson
where 	ce.person_id = o.person_id
and 	ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
and 	ce.event_end_dt_tm <  cnvtdatetime(end_date)
;and 	ce.encntr_id = o.encntr_id
and 	ce.event_end_dt_tm >= cnvtdatetime(start_date )
AND 	CE.parent_event_id > 0.0
and 	ce.view_level = 0
and 	ce.result_status_cd in ( auth_ver_cd, altered_cd, modified_cd)
and 	not substring(6,2,ce.accession_nbr) in ('CA', 'NP', 'SC')
*/
 
 
join pr
where pr.person_id  = o.order_physician_id
 
join pa
where 	pa.person_id = pr.person_id
and 	PA.alias_pool_cd in (STARDOC_CD, statedoc_cd)
and 	(pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ; check on this type
or 		pa.end_effective_dt_tm between cnvtdatetime(start_date ) and cnvtdatetime(end_date))
 
 
 
join pa2
 
ORDER BY
 ; encntr_id
 ;,fin
 ;,oros.order_id
 ;,oros.final_dt_tm
 ;,accession_ce
 ;,rad_order
 
  ce.order_id
 ,ce.event_id
 ,ce.view_level
 
 head report
 cnt = 0
;HEAD CE.EVENT_ID  ; need to use this now that the doc license id either star or state ID
detail
 
CNT = CNT + 1
STAT = ALTERLIST (rData->ENC, cnt)
 
rDATA->ENC[cnt].ENCNTR_ID = e.encntr_id
rDATA->ENC[cnt].PERSON_ID = e.person_id
rDATA->ENC[cnt].NAME = concat(trim(p.name_first,3), char(32), trim(p.name_middle,3), char(32), trim(p.name_last,3))
rDATA->ENC[cnt].FIRST_NAME = trim(p.name_first,3)
rDATA->ENC[cnt].LAST_NAME =  trim(p.name_last,3)
rDATA->ENC[cnt].M_NAME = trim(p.name_middle,3)
rDATA->ENC[cnt].marital = cnvtstring(p.marital_type_cd)
rDATA->ENC[cnt].MRN = trim(cnvtalias(pa3.alias, pa3.alias_pool_cd),3)
rDATA->ENC[cnt].FIN =  trim(ea.alias,3)
rDATA->ENC[cnt].DOB = format(p.birth_dt_tm, "MMDDYY;;d") ;dob_year
rDATA->ENC[cnt].dob_year  		=format(p.birth_dt_tm ,"yyyy;;d")
rDATA->ENC[cnt].dob_month  		=format(p.birth_dt_tm ,"mm;;d")
rDATA->ENC[cnt].dob_day  		= format(p.birth_dt_tm ,"dd;;d")
rDATA->ENC[cnt].birth_dt_tm = p.birth_dt_tm
rDATA->ENC[cnt].SEX = cnvtstring( p.sex_cd )
rDATA->ENC[cnt].disch_dt_tm = e.disch_dt_tm
rDATA->ENC[cnt].admit_dt_tm = e.reg_dt_tm
rDATA->ENC[cnt].FACILITY_CD = E.loc_facility_cd
rDATA->ENC[cnt].FACILITYCD = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
rDATA->ENC[cnt].FACILITY = cnvtstring(e.loc_facility_cd)
rDATA->ENC[cnt].NU_CD = E.loc_nurse_unit_cd
rDATA->ENC[cnt].NU = UAR_GET_CODE_DISPLAY(E.loc_nurse_unit_cd)
rDATA->ENC[cnt].PAT_TYPE  		=  cnvtstring(e.encntr_type_cd)
rDATA->ENC[cnt].PAT_TYPE_CLASS	= CNVTSTRING(E.encntr_type_class_cD)
rDATA->ENC[cnt].perf_dept = uar_get_code_display(oros.perf_dept_cd) ;003
rDATA->ENC[cnt].expired = cnvtstring(p.deceased_cd)
rDATA->ENC[cnt].ORDERING_ID = pa.alias
rDATA->ENC[cnt].order_id = o.order_id
rDATA->ENC[cnt].oid_disp = build(cnvtstring(cnvtint(o.order_id)))
rDATA->ENC[cnt].event_id = ce.event_id
rDATA->ENC[cnt].RESULT_STATUS_CD = ce.result_status_cd
rDATA->ENC[cnt].accession = ce.accession_nbr
rDATA->ENC[cnt].accessiond = cnvtacc(ce.accession_nbr)
rDATA->ENC[cnt].ord_dr_name_f =  pr.name_first
rDATA->ENC[cnt].ord_dr_name_l = pr.name_last
rDATA->ENC[cnt].ord_dr_name = pr.name_full_formatted
rDATA->ENC[cnt].ethnicity = cnvtstring( p.ethnic_grp_cd)
rDATA->ENC[CNT].SSN	= format( trim(PA2.ALIAS,3),"#########;p0")
 
 
 foot report
 rDATA->total = cnt
 
 
WITH NOCOUNTER;, memsort ; , format, separator = " ", check ;002
 
 IF(CURQUAL = 0)
	GO TO EXIT_SCRIPT
ENDIF
 
 
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; ADMITTING Diagnosis
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT distinct INTO "NL:"
;SELECT distinct INTO VALUE ($POUTDEV)
 dx.encntr_id
,dx.diagnosis_id
,fin = rDATA->ENC[d.seq].fin
,testingdx = replace(trim(n.source_string,3), char(44), "")
,type = uar_get_code_display(dx.diag_type_cd)
,source = uar_get_code_display(n.source_vocabulary_cd)
 
FROM DIAGNOSIS Dx
	,NOMENCLATURE N
	,	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
PLAN D
join dx
	WHERE dx.encntr_id = rDATA->ENC[d.seq].ENCNTR_ID
	AND Dx.ACTIVE_IND = 1
	AND Dx.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
	AND Dx.DIAG_TYPE_CD in (
 	  PRINCIPAL_DX_CD 	; F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"PRINCIPAL"))
	, VISITREASON_DX_CD 	; F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"REASONFORVISIT"))
	, ADMIT_DX_CD         ; F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"ADMITTING"))
 	, WORKING_DX_CD		; F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",17,"WORKING"))
 )
 
	;AND D.DIAG_PRSNL_ID > 0.0 ;Only qualifies those entered by a clinician
 
JOIN N
	WHERE N.NOMENCLATURE_ID =  dx.NOMENCLATURE_ID
	AND N.SOURCE_VOCABULARY_CD in   (pned_cd , ICD10CM_CD ); ICD10_CD
 
 
ORDER BY D.SEQ ;Dx.ENCNTR_ID
		, DX.diag_priority
		,Dx.DIAGNOSIS_ID
 
detail
 	;	if (dx.diag_type_cd = admit_dx_cd)
 			rDATA->ENC[d.seq].ADMIT_DX = testingdx
 	;	elseif (dx.diag_type_cd = working_dx_cd)
 			rDATA->ENC[d.seq].work_DX = testingdx
 	;	endif
 
WITH NOCOUNTER   ;, format, separator = " ", check
 
 
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; FINAL Diagnosis
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT distinct INTO "NL:"
;SELECT distinct INTO VALUE ($POUTDEV)
 dx.encntr_id
,dx.diagnosis_id
,fin = rDATA->ENC[d.seq].fin
,testingdx = replace(trim(n.source_string,3), char(44), "")
,type = uar_get_code_display(dx.diag_type_cd)
,source = uar_get_code_display(n.source_vocabulary_cd)
 
FROM DIAGNOSIS Dx
	,NOMENCLATURE N
	,(dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
PLAN D
join dx
	WHERE dx.encntr_id = rDATA->ENC[d.seq].ENCNTR_ID
	AND Dx.ACTIVE_IND = 1
	AND Dx.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
	AND Dx.DIAG_TYPE_CD in ( DISCH_DX_CD, FINAL_DX_CD)
 
	;AND D.DIAG_PRSNL_ID > 0.0 ;Only qualifies those entered by a clinician
 
JOIN N
	WHERE N.NOMENCLATURE_ID =  dx.NOMENCLATURE_ID
	AND N.SOURCE_VOCABULARY_CD = ICD10CM_CD
 
 
ORDER BY D.SEQ ;Dx.ENCNTR_ID
		, DX.diag_priority
		,Dx.DIAGNOSIS_ID
detail
		rDATA->ENC[d.seq].FINAL_DX = testingdx
		if (trim(rDATA->ENC[d.seq].work_DX,3) = "")
			rDATA->ENC[d.seq].work_DX = testingdx
		endif
 
 
WITH NOCOUNTER   , format, separator = " ", check
 
 
;-----------------------------------
; radiologist alias
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
	 fin = rdata->ENC[d.seq].fin
	, exam_st_dt = oros.Start_dt_tm
	, exam_end_dt = oros.exam_complete_dt_tm
	, RAD_PROC_TYPE = UAR_GET_CODE_DISPLAY(O.catalog_type_cd)
	, doc_name = pr.name_full_formatted
	, alias = trim(pa.alias,3)
	, rrp.ACTION_DT_TM
	, RRD_TASK_ASSAY_DISP = UAR_GET_CODE_DISPLAY(RRD.TASK_ASSAY_CD)
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, order_Radiology   ord
	, orders   o
	, rad_report   rr
	, rad_report_prsnl   rrp
	, rad_report_detail   rrd
	, OMF_RADMGMT_ORDER_ST   OROS
	, prsnl_alias   pa
	, prsnl   pr
 
Plan d
join ord where ord.order_id = rDATA->ENC[d.seq].order_id
join o where o.order_id = ord.order_id
join oros where oros.order_id = ord.order_id
join rr where (rr.order_id = ord.parent_order_id)
join rrd where (rrd.rad_report_id = rr.rad_report_id)
join rrp where (rrp.rad_report_id = rr.rad_report_id
and rrp.prsnl_relation_flag = 2)
join pa
where 	pa.person_id = rrp.report_prsnl_id
and 	PA.alias_pool_cd = STARDOC_CD
and 	pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ; check on this type
join pr
where pr.person_id = pa.person_id
 
order by d.seq, ord.order_id, rr.rad_report_id
 
detail
rDATA->ENC[d.seq].RADIOLOGIST_ID = trim(pa.alias,3)
rDATA->ENC[d.seq].check_in_dt_tm   	= exam_st_dt
rDATA->ENC[d.seq].check_in_d   		= format( exam_st_dt, "dd;;d")
rDATA->ENC[d.seq].check_in_m   		= format( exam_st_dt, "mm;;d")
rDATA->ENC[d.seq].check_in_y  		= format( exam_st_dt, "yy;;d")
rDATA->ENC[d.seq].check_out_dt_tm  	= exam_end_dt
rDATA->ENC[d.seq].check_out_d  		= format( exam_end_dt, "dd;;d")
rDATA->ENC[d.seq].check_out_m  		= format( exam_end_dt, "mm;;d")
rDATA->ENC[d.seq].check_in_y  		= format( exam_end_dt, "yy;;d")
rDATA->ENC[d.seq].rad_dr_name_f		= pr.name_first
rDATA->ENC[d.seq].rad_dr_name_l  	= pr.name_last
rDATA->ENC[d.seq].rad_dr_name 		= pr.name_full_formatted
rDATA->ENC[d.seq].order_mnem 		= o.order_mnemonic
rDATA->ENC[d.seq].RAD_PROC_TYPE 	= RAD_PROC_TYPE
rDATA->ENC[d.seq].order_cat_cd  	= cnvtstring(o.catalog_cd)
rDATA->ENC[d.seq].rad_report_id = rr.rad_report_id
 
WITH NOCOUNTER ;,  format, separator = " ", check
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
;student status
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
student_ind = uar_get_code_display(pp.student_cd)
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, person_patient pp
 
	Plan d
 
 	join 	pp
 	where 	pp.person_id = rDATA->ENC[d.seq].person_id
 
order d.seq
 
detail
 rDATA->ENC[d.seq].student_ind = replace(trim(student_ind,3), char(0), "")
 
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!
;guarantor name add phone
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, ENCNTR_PERSON_RELTN   epr
	, person 	pr
	, (left JOIN person_alias pa ON (pr.person_id = pa.person_id
 		AND pa.person_alias_type_cd = SSN_CD))
 	, (left join address a on (pr.person_id = a.parent_entity_id
			and 	a.parent_entity_name =  "PERSON"
    		AND 	A.ACTIVE_IND	= 1
    		AND 	A.ADDRESS_TYPE_CD =  756))  ;home
	, (left join phone p on (pr.person_id = p.parent_entity_id
			and 	P.parent_entity_name =  "PERSON")
    		AND 	P.ACTIVE_IND =  1
    		AND 	P.PHONE_TYPE_CD =  170) ;home
 
Plan d
 
 	join 	epr
 	where 	epr.encntr_id = rDATA->ENC[d.seq].encntr_id
 	and 	epr.PERSON_RELTN_TYPE_CD = defguar_cd
 	and 	epr.active_ind = 1
 
 	JOIN    pr
 	where 	pr.person_id = epr.related_person_id
 join pa
 join a
 join p
 
 
 
 order by d.seq, a.address_id, p.phone_id
 
detail
 rDATA->ENC[d.seq].guarPerson_id	= epr.related_person_id
 rDATA->ENC[d.seq].guarFirstName 	= pr.name_first
 rDATA->ENC[d.seq].guarLastName  	= pr.name_last
 rDATA->ENC[d.seq].guarMiddleName  	= substring(1,1,trim(pr.name_middle,3))
 rDATA->ENC[d.seq].guarDateOfBirth  = pr.birth_dt_tm
 rDATA->ENC[d.seq].guarAddress1  	= a.street_addr
 rDATA->ENC[d.seq].guarAddress2  	= substring(1,30,trim(a.street_addr2,3))
 rDATA->ENC[d.seq].guarZipcode  	 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].guarPhone  		= p.phone_num_key
 rDATA->ENC[d.seq].guarSSN  		= pa.alias
 rDATA->ENC[d.seq].guarRel  		= cnvtstring(epr.person_reltn_cd)
 
 
WITH nocounter ;, format, separator = " "
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; guar  business and phone
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 
FROM
	  (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, person_org_reltn p
	, organization o
 	, (left join address a on (o.organization_id= a.parent_entity_id
			and 	a.parent_entity_name =  "ORGANIZATION"
    		AND 	A.ACTIVE_IND	= 1
    		AND 	A.ADDRESS_TYPE_CD =  754))
	, (left join phone ph on (o.organization_id = ph.parent_entity_id
			and 	Ph.parent_entity_name =  "ORGANIZATION"
    		AND 	Ph.ACTIVE_IND =  1
    		AND 	Ph.PHONE_TYPE_CD =  163))
 
plan d
join p
where p.person_id 		  =     rDATA->ENC[d.seq].guarPerson_id
and p.person_org_reltn_cd =     1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
join a
join ph
 
 order by d.seq, a.address_id, pH.phone_id
 
detail
 rDATA->ENC[d.seq].guarempname 		= trim(o.org_name,3)
 rDATA->ENC[d.seq].guarempaddress1 	= tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].guarEMPZIPCODE		 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].guarEMPphONE		= trim (ph.phone_num_key,3)
 
WITH NOCOUNTER; , format, separator = " ", check
 
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; exam reading names and dates
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT distinct  INTO "NL:"
;SELECT distinct INTO value ($poutdev)
	  d.seq
	, fin = rdata->ENC[d.seq].fin
	, ord = rdata->ENC[d.seq].order_mnem
	, acc = rdata->ENC[d.seq].accession
	, pr.person_id
	, name_disp = concat (trim(pr.name_first_key,3), char(32), trim(pr.name_last_key, 3), char(44), char(32),
									trim(uar_get_code_display(pr.position_cd),3))
	, name_disp2 = concat(trim(pr.name_full_formatted,3), char(32),  trim(uar_get_code_display(pr.position_cd),3))
	, rr.RAD_REPORT_ID
	, rr.REPORT_EVENT_ID
	, rr.SEQUENCE
	, rr.addendum_ind
	, rr.POSTED_FINAL_DT_TM
	, RH_ACTION_DISP = UAR_GET_CODE_DISPLAY(RH.ACTION_CD)
	, RH.ACTION_CD
	, rh.ACTION_DT_TM "mm/dd/yyyy hh:mm:ss;;d"
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, order_Radiology   ord
	, rad_report   rr
	, rad_rpt_prsnl_hist   rh
	, prsnl   pr
 
Plan d
join ord where ord.order_id = rDATA->ENC[d.seq].order_id
;and ord.order_id = 405234261
join rr where rr.order_id = ord.parent_order_id
;added line for troubleshooting addendums and date ranges 6/29
and 	rr.posted_final_dt_tm between cnvtdatetime(start_date ) and cnvtdatetime(end_date)
 
join rh where rh.rad_report_id = rr.rad_report_id
 
and rh.action_dt_tm between cnvtdatetime(start_date ) and cnvtdatetime(end_date)
join pr
where pr.person_id = rh.report_prsnl_id
 
ORDER BY
	d.seq
	, rr.order_id
	, rr.rad_report_id
	, rr.report_event_id
	, rr.sequence
 	, RH.ACTION_CD
 
 
detail
case (rh.ACTION_CD)
 
of	ADDENDED_28880_cd :
	rDATA->ENC[d.seq].ADDENDED_dt_tm = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].ADDENDED  = name_disp
 
of	APPROVED_28880_cd :
	rDATA->ENC[d.seq].APPROVED_dt_tm  = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].APPROVED  = name_disp
 
of	CORRECTED_28880_cd :
	rDATA->ENC[d.seq].CORRECTED_dt_tm  = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].CORRECTED  = name_disp
 
of	COSIGNED_28880_cd :
	rDATA->ENC[d.seq].COSIGNED_dt_tm  = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].COSIGNED  = name_disp
 
of	DICTATED_28880_cd :
	rDATA->ENC[d.seq].DICTATED_dt_tm  = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].DICTATED  = name_disp
 
of	MODIFIED_28880_cd :
	rDATA->ENC[d.seq].MODIFIED_dt_tm  = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].MODIFIED  = name_disp
 
of	TRANSCRIBED_28880_cd :
	rDATA->ENC[d.seq].TRANSCRIBed_dt_tm  = rh.ACTION_DT_TM,
	rDATA->ENC[d.seq].TRANSCRIBED  = name_disp
endcase
 
WITH NOCOUNTER ; , SEPARATOR=" ", FORMAT,check
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; ATTENDING PHYSICIANS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;set log = log_time("Retrieve Attending doctor")
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
	ALIAS 		=  SUBSTRING(1,12,trim(PA.ALIAS,3))
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, ENCOUNTER E
	, ENCNTR_PRSNL_RELTN   EPR
	, PRSNL   PR
	, ADDRESS A
	, PRSNL_ALIAS   PA
 
plan d
join  E
	WHERE E.ENCNTR_ID = rDATA->ENC[d.seq].ENCNTR_ID
JOIN EPR
	WHERE EPR.encntr_id = E.encntr_id
	AND EPR.ENCNTR_PRSNL_R_CD = ATTENDDOC_CD
	AND EPR.beg_effective_dt_tm >= E.reg_dt_tm
	AND (EPR.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME3)
			OR EPR.end_effective_dt_tm <= E.end_effective_dt_tm)
 
JOIN PR
	WHERE PR.PERSON_ID = EPR.PRSNL_PERSON_ID
JOIN A
	WHERE A.parent_entity_id = PR.person_id
join PA
	WHERE PA.PERSON_ID = OUTERJOIN(PR.PERSON_ID)
	AND Pa.ALIAS_POOL_CD =         OUTERJOIN(STARDOC_CD)
	and pa.active_ind = 1
 
 
ORDER BY D.SEQ, EPR.beg_effective_dt_tm DESC , pa.beg_effective_dt_tm desc
 
detail
rDATA->ENC[D.seq].ATTENDING_ID  = ALIAS
 
 
WITH NOCOUNTER
; , format, separator = " ", check
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; REFERRING PHYSICIANS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;set log = log_time("Retrieve Attending doctor")
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
	ALIAS 		=  SUBSTRING(1,12,trim(PA.ALIAS,3))
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, ENCOUNTER E
	, ENCNTR_PRSNL_RELTN   EPR
	, PRSNL   PR
	, ADDRESS A
	, PRSNL_ALIAS   PA
 	, PRSNL_ALIAS   PA2
 
plan d
join  E
	WHERE E.ENCNTR_ID = rDATA->ENC[d.seq].ENCNTR_ID
JOIN EPR
	WHERE EPR.encntr_id = E.encntr_id
	AND EPR.ENCNTR_PRSNL_R_CD = REFERDOC_CD
	AND EPR.beg_effective_dt_tm >= E.reg_dt_tm
	AND (EPR.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME3)
			OR EPR.end_effective_dt_tm <= E.end_effective_dt_tm)
 
JOIN PR
	WHERE PR.PERSON_ID = EPR.PRSNL_PERSON_ID
JOIN A
	WHERE A.parent_entity_id = PR.person_id
join PA
	WHERE PA.PERSON_ID 		= OUTERJOIN(PR.PERSON_ID)
	AND Pa.ALIAS_POOL_CD 	= OUTERJOIN(STARDOC_CD)
	and pa.active_ind 		= outerjoin(1)
join PA2
	WHERE PA2.PERSON_ID 		= OUTERJOIN(PR.PERSON_ID)
	AND Pa2.prsnl_alias_type_cd	= outerjoin(npi_cd)
	and pa2.active_ind 		= outerjoin(1)
 
ORDER BY D.SEQ, EPR.beg_effective_dt_tm DESC , pa.beg_effective_dt_tm desc
 
detail
rDATA->ENC[D.seq].REFERRING_ID  = pa.alias
rDATA->ENC[D.seq].REFERRING_NAME = PR.name_full_formatted
rDATA->ENC[d.seq].referring_upin = pa2.alias
WITH NOCOUNTER
; , format, separator = " ", check
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; PCP PHYSICIANS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;set log = log_time("Retrieve Attending doctor")
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 	ALIAS 		=  SUBSTRING(1,12,trim(PA.ALIAS,3))
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, ENCOUNTER E
	, PERSON_PRSNL_RELTN   EPR
	, PRSNL   PR
	, ADDRESS A
	, PRSNL_ALIAS   PA
 
plan d
join  E
	WHERE E.ENCNTR_ID = rDATA->ENC[d.seq].ENCNTR_ID
JOIN EPR
	WHERE EPR.person_id = E.person_id
	AND EPR.PERSON_PRSNL_R_CD  IN (PCP_CD, FAMILY_CD )
	AND EPR.beg_effective_dt_tm >= E.reg_dt_tm
	AND (EPR.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME3)
			OR EPR.end_effective_dt_tm <= E.end_effective_dt_tm)
 
JOIN PR
	WHERE PR.PERSON_ID = EPR.PRSNL_PERSON_ID
JOIN A
	WHERE A.parent_entity_id = PR.person_id
join PA
	WHERE PA.PERSON_ID 		= OUTERJOIN(PR.PERSON_ID)
	AND Pa.ALIAS_POOL_CD 	= OUTERJOIN(STARDOC_CD)
	and pa.active_ind 		= outerjoin(1)
 
 
ORDER BY D.SEQ, EPR.beg_effective_dt_tm DESC , pa.beg_effective_dt_tm desc
 
detail
	rDATA->ENC[D.seq].PCP_ID  = ALIAS
 	rDATA->ENC[D.seq].pcp_name = pr.name_full_formatted
 
WITH NOCOUNTER
; , format, separator = " ", check
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; FAMILY PHYSICIANS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;set log = log_time("Retrieve Attending doctor")
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 
	ALIAS 		=  SUBSTRING(1,12,trim(PA.ALIAS,3))
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, ENCOUNTER E
	, PERSON_PRSNL_RELTN   EPR
	, PRSNL   PR
	, ADDRESS A
	, PRSNL_ALIAS   PA
 
plan d
join  E
	WHERE E.ENCNTR_ID = rDATA->ENC[d.seq].ENCNTR_ID
JOIN EPR
	WHERE EPR.person_id = E.person_id
	AND EPR.PERSON_PRSNL_R_CD  IN ( FAMILY_CD )
	AND EPR.beg_effective_dt_tm >= E.reg_dt_tm
	AND (EPR.end_effective_dt_tm > CNVTDATETIME(CURDATE, CURTIME3)
			OR EPR.end_effective_dt_tm <= E.end_effective_dt_tm)
 
JOIN PR
	WHERE PR.PERSON_ID = EPR.PRSNL_PERSON_ID
JOIN A
	WHERE A.parent_entity_id = PR.person_id
join PA
	WHERE PA.PERSON_ID 		= OUTERJOIN(PR.PERSON_ID)
	AND Pa.ALIAS_POOL_CD 	= OUTERJOIN(STARDOC_CD)
	and pa.active_ind 		= outerjoin(1)
 
 
ORDER BY D.SEQ, EPR.beg_effective_dt_tm DESC , pa.beg_effective_dt_tm desc
 
detail
 
	rDATA->ENC[D.seq].FAMILY_ID  = ALIAS
	rDATA->ENC[D.seq].family_name = pr.name_full_formatted
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;Phone - biz and home
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
SELECT distinct INTO "NL:"
;SELECT distinct INTO value ($poutdev)
 
	d.seq
	, person_id = a.parent_entity_id
 	, phone = a.phone_num_key
 
 FROM
	PHone  A
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
plan d
join a wHERE A.PARENT_ENTITY_ID = rDATA->ENC[d.seq].PERSON_ID
		AND A.PARENT_ENTITY_NAME = "PERSON"
		AND A.phone_TYPE_CD IN (163, 170)
		AND A.phone_TYPE_SEQ = 1
		AND A.ACTIVE_IND = 1
		AND A.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
ORDER BY
	d.seq
	, A.PARENT_ENTITY_ID
	, a.phone_type_cd
 
detail
 	if (a.phone_type_cd  = 163)
 		rDATA->ENC[d.seq].phone_biz =  phone
	elseif (a.phone_type_cd = 170)
		rDATA->ENC[d.seq].phone_home =  phone
	endif
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;Address and Temp address
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SELECT distinct INTO "NL:"
;SELECT distinct INTO value ($poutdev)
	d.seq
	, person_id = a.parent_entity_id
	,ADDR_SORT = IF (A.ADDRESS_TYPE_CD = HOME_CD)
					1
				ELSEIF (A.ADDRESS_TYPE_CD = TEMPORARY_CD)
					2
				ELSE
					3
				ENDIF
	, state_disp = uar_get_code_display(a.state_cd)
 
 
FROM
	ADDRESS   A
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
plan d
join a wHERE A.PARENT_ENTITY_ID = rDATA->ENC[d.seq].PERSON_ID
		AND A.PARENT_ENTITY_NAME = "PERSON"
		AND A.ADDRESS_TYPE_CD IN (home_cd, TEMPORARY_CD,ALTERNATE_CD)
		AND A.ADDRESS_TYPE_SEQ = 1
		AND A.ACTIVE_IND = 1
		AND A.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
ORDER BY
	d.seq
	, A.PARENT_ENTITY_ID
	, ADDR_SORT
 
HEAD d.seq ; A.PARENT_ENTITY_ID
 
	rDATA->ENC[d.seq].ADDRESS = A.STREET_ADDR
	rDATA->ENC[d.seq].ADDRESS2 = A.street_addr2
	rDATA->ENC[d.seq].CITY = A.CITY
	rDATA->ENC[d.seq].STATE   =  state_disp ;CNVTSTRING(A.STATE_CD)
	rDATA->ENC[d.seq].ZIPCODE     = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 
WITH NOCOUNTER
; , format, separator = " ", check
;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; employer business
SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
 
FROM
	person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
 
plan d
join p
where p.person_id =     rDATA->ENC[d.seq].PERSON_ID
and p.person_org_reltn_cd =             1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
 
join a
where a.parent_entity_id = o.organization_id
and a.parent_entity_name = "ORGANIZATION"
and a.active_ind = 1
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].emp_name 	= trim(o.org_name,3)
 rDATA->ENC[d.seq].EMP_CITY 	= TRIM(A.city,3)
 rDATA->ENC[d.seq].EMP_ADDR1 	= tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].EMP_ADDR2 	= tRIM(a.street_addr2,3)
 rDATA->ENC[d.seq].EMP_ZIP		 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].EMP_ST 		= tRIM(A.state,3)
 rDATA->ENC[d.seq].emp_status	= cnvtstring(p.empl_status_cd)
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
; insurance carriers
SELECT DISTINCT INTO "NL:"
;SELECT distinct INTO value ($pOutdev)
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, encounter   enc
	, ENCNTR_PLAN_RELTN   E
	, ORGANIZATION   ORG
	, PERSON   PE
	, ADDRESS   A
	, PHONE   P
	, encntr_person_reltn   EP
	, health_plan   hp
	, health_plan_alias   hpa
	, person_org_reltn   por
	, address   asub
	, address   ah
 
plan d
join enc
where enc.encntr_id = rdata->enc[d.seq].ENCNTR_ID
 
join e
where E.ENCNTR_ID = outerjoin(enc.encntr_id)
  AND E.ACTIVE_IND= outerjoin(1)
  and e.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
  and e.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
join Org
where Org.ORGANIZATION_ID = outerjoin(E.ORGANIZATION_ID)
  and org.active_ind = outerjoin(1)
  and org.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
  and org.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
join EP
where ep.encntr_id = outerjoin(e.encntr_id)
  and ep.related_person_id = outerjoin(e.person_id)
  and ep.active_ind = outerjoin(1)
  and ep.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
  and ep.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
  and ep.person_reltn_type_cd = outerjoin(1158)
 
join pe
where pe.PERSON_ID = outerjoin(EP.RELATED_PERSON_ID)
  and pe.active_ind = outerjoin(1)
  and pe.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
  and pe.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
 
join a where a.parent_entity_id = outerjoin(e.encntr_plan_reltn_id)
       AND A.ACTIVE_IND=outerjoin(1)
      AND A.ADDRESS_TYPE_CD = outerjoin(754)
  and a.parent_entity_name = outerjoin("ENCNTR_PLAN_RELTN")
 
join p where p.parent_entity_id = outerjoin(e.encntr_plan_reltn_id)
        AND P.ACTIVE_IND = outerjoin(1)
      AND P.PHONE_TYPE_CD = outerjoin(163)
  and p.parent_entity_name = outerjoin("ENCNTR_PLAN_RELTN")
 
join hp
where hp.health_plan_id = outerjoin(e.health_plan_id)
 and hp.active_ind = outerjoin(1)
 and hp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
 and hp.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
join ah
where ah.parent_entity_id = outerjoin(hp.health_plan_id)
and	ah.parent_entity_name = "HEALTH_PLAN"
and 	ah.active_ind = outerjoin(1)
 
join hpa
where hpa.health_plan_id = outerjoin(hp.health_plan_id)
 and hpa.active_ind = outerjoin(1)
 and hpa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
 and hpa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
join por
where por.person_id = outerjoin(pe.person_id)
  and por.person_org_reltn_cd = outerjoin(1137)
  and por.active_ind = outerjoin(1)
  and por.priority_seq = outerjoin(1)
  and por.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
  and por.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
 
 
join asub
where asub.parent_entity_id = outerjoin(ep.related_person_id)
  AND asub.ACTIVE_IND=outerjoin(1)
  AND asub.ADDRESS_TYPE_CD = outerjoin(756)
  and asub.parent_entity_name = outerjoin("PERSON")
 
ORDER BY
	d.seq
	, e.encntr_id
	, e.priority_seq
	, e.health_plan_id
 
head report
 ins_seq_count = 0
 
head d.seq ; fixed from encntr nbr
   ins_seq_count = 0
;DETAIL
head e.priority_seq
  if (e.priority_seq > 0)
    ins_seq_count = ins_seq_count + 1
 
 ;   if (ins_seq_count = 1)
 	if (e.priority_seq = 1)
      rdata->enc[d.seq].encntr_plan_reltn_id_A = e.encntr_plan_reltn_id
      rdata->enc[d.seq].Insurance_Plan_Code_A = TRIM(AH.street_addr4,3)
      rdata->enc[d.seq].Insurance_Plan_Name_A= hp.plan_name
;     rdata->enc[d.seq].Insurance_FC_A = substring(1,10,UAR_GET_CODE_DISPLAY(hp.financial_class_cd))
 
      if (trim(E.subs_member_nbr,3) > " ")
      	rdata->enc[d.seq].Insurance_Policy_No_A = E.subs_member_nbr
      else
      	rdata->enc[d.seq].Insurance_Policy_No_A = E.member_nbr
      endif
 
      rdata->enc[d.seq].Insurance_Group_No_A = E.GROUP_NBR
      rdata->enc[d.seq].Insurance_Address_1_A = A.STREET_ADDR
;     rdata->enc[d.seq].Insurance_Address_2_A = A.STREET_ADDR2
;     rdata->enc[d.seq].Insurance_Address_4_A = A.street_addr4
      rdata->enc[d.seq].Insurance_City_A = A.CITY
      rdata->enc[d.seq].Insurance_State_A = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_A = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
     rdata->enc[d.seq].Insurance_Phone_A = P.PHONE_NUM_key
      rdata->enc[d.seq].Insurance_Insured_A = pe.name_full_formatted
      rDATA->ENC[d.seq].II_A_person_id = ep.related_person_id
      rdata->enc[d.seq].Insurance_Rel_to_Pt_A = CNVTSTRING( EP.PERSON_RELTN_CD )
;     rdata->enc[d.seq].Insurance_Name_on_Card_A = e.insured_card_name
;     rdata->enc[d.seq].Insurance_Effective_Date_A = format(e.health_card_issue_dt_tm, "@SHORTDATE4YR")
;     rdata->enc[d.seq].Insurance_Group_Name_A = E.GROUP_NAME
;     rdata->enc[d.seq].Insurance_Subscriber_Retirement_Date_A = format(por.empl_retire_dt_tm, "@SHORTDATE4YR")
	  rdata->enc[d.seq].Insurance_Subscriber_Address_1_A = asub.street_addr
	  rdata->enc[d.seq].Insurance_Subscriber_City_A = asub.city
	  rdata->enc[d.seq].Insurance_Subscriber_State_A = asub.state
	  rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_A  = CONCAT (substring(1,5,format(trim(ASUB.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(ASUB.ZIPCODE_key),"#########")))
 
 		rdata->enc[d.seq].Insurance_SuscriberNameF_A = trim(pe.name_first,3)
 		rdata->enc[d.seq].Insurance_SuscriberNameL_A = trim(pe.name_last,3)
 		rdata->enc[d.seq].Insurance_SuscriberNameM_A = substring(1,1,trim(pe.name_middle,3))
 
 
;   elseif (ins_seq_count = 2)
   elseif (e.priority_seq = 2)
      rdata->enc[d.seq].encntr_plan_reltn_id_B = e.encntr_plan_reltn_id
      rdata->enc[d.seq].Insurance_Plan_Code_B = TRIM(AH.street_addr4,3)
;     rdata->enc[d.seq].Insurance_FC_B = substring(1,10,UAR_GET_CODE_DISPLAY(hp.financial_class_cd))
      rdata->enc[d.seq].Insurance_Plan_Name_B = hp.plan_name
 
      if (trim(E.subs_member_nbr,3) > " ")
      	rdata->enc[d.seq].Insurance_Policy_No_B = E.subs_member_nbr
      else
      	rdata->enc[d.seq].Insurance_Policy_No_B = E.member_nbr
      endif
      rdata->enc[d.seq].Insurance_Group_No_B = E.GROUP_NBR
      rdata->enc[d.seq].Insurance_Address_1_B = A.STREET_ADDR
;;    rdata->enc[d.seq].Insurance_Address_2_B = A.STREET_ADDR2
;;    rdata->enc[d.seq].Insurance_Address_4_B = A.street_addr4
      rdata->enc[d.seq].Insurance_City_B = A.CITY
      rdata->enc[d.seq].Insurance_State_B = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_B  = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
    rdata->enc[d.seq].Insurance_Phone_B = P.PHONE_NUM_key
      rdata->enc[d.seq].Insurance_Insured_B = pe.name_full_formatted
      rDATA->ENC[d.seq].II_B_person_id = ep.related_person_id
      rdata->enc[d.seq].Insurance_Rel_to_Pt_B  = CNVTSTRING( EP.PERSON_RELTN_CD )
;;    rdata->enc[d.seq].Insurance_Name_on_Card_B = e.insured_card_name
;;    rdata->enc[d.seq].Insurance_Effective_Date_B = format(e.health_card_issue_dt_tm, "@SHORTDATE4YR")
;;    rdata->enc[d.seq].Insurance_Group_Name_B = E.GROUP_NAME
;;    rdata->enc[d.seq].Insurance_Subscriber_Retirement_Date_B = format(por.empl_retire_dt_tm, "@SHORTDATE4YR")
	  rdata->enc[d.seq].Insurance_Subscriber_Address_1_B = asub.street_addr
		rdata->enc[d.seq].Insurance_Subscriber_City_B = asub.city
		rdata->enc[d.seq].Insurance_Subscriber_State_B = asub.state
		rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_B = CONCAT (substring(1,5,format(trim(ASUB.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(ASUB.ZIPCODE_key),"#########")))
 
  		rdata->enc[d.seq].Insurance_SuscriberNameF_B = trim(pe.name_first,3)
 		rdata->enc[d.seq].Insurance_SuscriberNameL_B = trim(pe.name_last,3)
		rdata->enc[d.seq].Insurance_SuscriberNameM_B = substring(1,1,trim(pe.name_middle,3))
 
;    elseif (ins_seq_count = 3)
    elseif (e.priority_seq = 3)
     rdata->enc[d.seq].encntr_plan_reltn_id_C = e.encntr_plan_reltn_id
      rdata->enc[d.seq].Insurance_Plan_Code_C = TRIM(AH.street_addr4,3)
      rdata->enc[d.seq].Insurance_Plan_Name_C = hp.plan_name
      if (trim(E.subs_member_nbr,3) > " ")
      	rdata->enc[d.seq].Insurance_Policy_No_C = E.subs_member_nbr
      else
      	rdata->enc[d.seq].Insurance_Policy_No_C = E.member_nbr
      endif
;     rdata->enc[d.seq].Insurance_FC_C = substring(1,10,UAR_GET_CODE_DISPLAY(hp.financial_class_cd))
      rdata->enc[d.seq].Insurance_Group_No_C = E.GROUP_NBR
      rdata->enc[d.seq].Insurance_Address_1_C = A.STREET_ADDR
;     rdata->enc[d.seq].Insurance_Address_2_C = A.STREET_ADDR2
;     rdata->enc[d.seq].Insurance_Address_4_C = A.street_addr4
      rdata->enc[d.seq].Insurance_City_C = A.CITY
      rdata->enc[d.seq].Insurance_State_C = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_C = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
     rdata->enc[d.seq].Insurance_Phone_C = P.PHONE_NUM_key
      rdata->enc[d.seq].Insurance_Insured_C = pe.name_full_formatted
      rdata->enc[d.seq].Insurance_Rel_to_Pt_C = CNVTSTRING( EP.PERSON_RELTN_CD )
      rDATA->ENC[d.seq].II_C_person_id = ep.related_person_id
;     rdata->enc[d.seq].Insurance_Name_on_Card_C = e.insured_card_name
;     rdata->enc[d.seq].Insurance_Effective_Date_C = format(e.health_card_issue_dt_tm, "@SHORTDATE4YR")
;     rdata->enc[d.seq].Insurance_Group_Name_C = E.GROUP_NAME
;     rdata->enc[d.seq].Insurance_Subscriber_Retirement_Date_C = format(por.empl_retire_dt_tm, "@SHORTDATE4YR")
	 rdata->enc[d.seq].Insurance_Subscriber_Address_1_C = asub.street_addr
	 rdata->enc[d.seq].Insurance_Subscriber_City_C = asub.city
	 rdata->enc[d.seq].Insurance_Subscriber_State_C = asub.state
	 rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_C = CONCAT (substring(1,5,format(trim(ASUB.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(ASUB.ZIPCODE_key),"#########")))
 
   	rdata->enc[d.seq].Insurance_SuscriberNameF_C = trim(pe.name_first,3)
 	rdata->enc[d.seq].Insurance_SuscriberNameL_C = trim(pe.name_last,3)
 	rdata->enc[d.seq].Insurance_SuscriberNameM_C = substring(1,1,trim(pe.name_middle,3))
 
  endif
ENDIF
 
WITH nocounter ; , format, separator = " ", check
 
 
; ------------------------------------------------------------------------
; Get Authorization Info
;SELECT INTO VALUE($POUTDEV)
select into "nl:"
 
  E.encntr_id
, E.priority_seq
, auth.auth_nbr
 
;select into "nl:"
from
(dummyt   d  with seq = value (size(rDATA->ENC,5)))
, encntr_plan_reltn   e
, encntr_plan_auth_r   epar
, authorization   auth
, auth_detail autd
 
plan d
join e
where e.encntr_id =  rdata->enc[d.seq].ENCNTR_ID
  AND E.ACTIVE_IND= (1)
  and e.beg_effective_dt_tm <= (cnvtdatetime(curdate, curtime3))
  and e.end_effective_dt_tm >= (cnvtdatetime(curdate, curtime3))
 
join epar
where epar.encntr_plan_reltn_id = (e.encntr_plan_reltn_id)
  and epar.active_ind = (1)
  and epar.beg_effective_dt_tm <= (cnvtdatetime(curdate, curtime3))
  and epar.end_effective_dt_tm >= (cnvtdatetime(curdate, curtime3))
 
join auth
where auth.authorization_id = (epar.authorization_id)
  and auth.auth_type_cd != 0.0
  and auth.active_ind = (1)
  and auth.beg_effective_dt_tm <= (cnvtdatetime(curdate, curtime3))
  and auth.end_effective_dt_tm >= (cnvtdatetime(curdate, curtime3))
 
join autd
where autd.authorization_id = (auth.authorization_id)
  and autd.active_ind = (1)
  and autd.beg_effective_dt_tm <= (cnvtdatetime(curdate, curtime3))
  and autd.end_effective_dt_tm >= (cnvtdatetime(curdate, curtime3))
ORDER BY
d.seq
, e.encntr_id
, E.priority_seq
,auth.auth_nbr
 
detail
 
 
  if (e.encntr_plan_reltn_id = rdata->enc[d.seq].encntr_plan_reltn_id_A)
    rdata->enc[d.seq].Authorization_Number_A = auth.auth_nbr
  elseif(e.encntr_plan_reltn_id = rdata->enc[d.seq].encntr_plan_reltn_id_B)
    rdata->enc[d.seq].Authorization_Number_B = auth.auth_nbr
 
  elseif(e.encntr_plan_reltn_id = rdata->enc[d.seq].encntr_plan_reltn_id_C)
    rdata->enc[d.seq].Authorization_Number_C = auth.auth_nbr
  endif
with nocounter ;, FORMAT, SEPARATOR = " " , CHECK
; ------------------------------------------------------------------------
; get accident info
;SELECT INTO VALUE ($poutdev)
SELECT INTO "nl:"
      ACC_ACCIDENT_DISP = UAR_GET_CODE_DISPLAY(ACC.ACCIDENT_CD)
 	, ACC_ACC_DEATH_DISP = UAR_GET_CODE_DISPLAY(ACC.ACC_DEATH_CD)
	, ACC_ACC_JOB_RELATED_DISP = UAR_GET_CODE_DISPLAY(ACC.ACC_JOB_RELATED_CD)
	, ACC_ACC_STATE_DISP = UAR_GET_CODE_DISPLAY(ACC.ACC_STATE_CD)
	, ACC_ACTIVE_STATUS_DISP = UAR_GET_CODE_DISPLAY(ACC.ACTIVE_STATUS_CD)
 	, ACC_AMBULANCE_ARRIVE_DISP = UAR_GET_CODE_DISPLAY(ACC.AMBULANCE_ARRIVE_CD)
	, ACC_AMBULANCE_GEO_DISP = UAR_GET_CODE_DISPLAY(ACC.AMBULANCE_GEO_CD)
 
 
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, encntr_accident   acc
 
plan d
join acc
where ACC.encntr_id =  rdata->enc[d.seq].ENCNTR_ID
  AND ACC.ACTIVE_IND= (1)
  and ACC.beg_effective_dt_tm <= (cnvtdatetime(curdate, curtime3))
  and ACC.end_effective_dt_tm >= (cnvtdatetime(curdate, curtime3))
 
detail
	rdata->ENC[d.seq].acc_dt_tm = acc.accident_dt_tm
	rdata->ENC[d.seq].acc_loc	= substring(1,25,trim(acc.accident_loctn,3))
	rdata->ENC[d.seq].acc_st 	= ACC_ACC_STATE_DISP
	rdata->ENC[d.seq].acc_ore	= ACC_ACC_JOB_RELATED_DISP
 	rdata->ENC[d.seq].acc_type	= cnvtstring(acc.accident_cd) ;ACC_ACCIDENT_DISP
 
WITH nocounter ; , CHECK, format, separator = " "
 
 
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; carrier emloyers A B C
SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
FROM
	  person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
 
plan d
join p
where p.person_id =     rDATA->ENC[d.seq].II_A_person_id
and p.person_org_reltn_cd =             1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
 
join a
where a.parent_entity_id = o.organization_id
and a.parent_entity_name = "ORGANIZATION"
and a.active_ind = 1
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].Insurance_SuscriberEmpName_A = trim(o.org_name,3)
 rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_A = tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_A	= CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
FROM
	  person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
 
plan d
join p
where p.person_id =     rDATA->ENC[d.seq].II_B_person_id
and p.person_org_reltn_cd =             1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
 
join a
where a.parent_entity_id = o.organization_id
and a.parent_entity_name = "ORGANIZATION"
and a.active_ind = 1
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].Insurance_SuscriberEmpName_B = trim(o.org_name,3)
 rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_B = tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_B	= CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
FROM
	  person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
 
plan d
join p
where p.person_id =     rDATA->ENC[d.seq].II_C_person_id
and p.person_org_reltn_cd =             1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
 
join a
where a.parent_entity_id = o.organization_id
and a.parent_entity_name = "ORGANIZATION"
and a.active_ind = 1
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].Insurance_SuscriberEmpName_C = trim(o.org_name,3)
 rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_C = tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_C	= CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 
WITH NOCOUNTER
; , format, separator = " ", check
 
; ------------------------------------------------------------------------
; get cpt
;SELECT   INTO VALUE ($poutdev)
SELECT   INTO "nl:"
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, charge_event   ce
	, charge   c
	, charge_mod   cm
	, orders   ord
plan d
join ce where ce.accession =  rData->ENC[d.seq].accession
;and ce.ext_i_event_cont_cd =        3445.00  7/31 issue reported where the cmg clinics use a different code
join c where c.charge_event_id = ce.charge_event_id
join cm where cm.charge_item_id = c.charge_item_id
and cm.field1_id in ( cpt4_cd, cpt4_mod_cd )
				  AND NOT CM.FIELD6 = NULL
  				  AND CM.ACTIVE_IND = 1
  				  and cm.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
join ord
where ord.order_id = ce.order_id
 
ORDER BY
	 d.seq
	, ce.order_id
	, ce.charge_event_id
	, cm.charge_item_id
	, cm.charge_mod_id
	, cm.field1_id
	, cm.field6
 
detail
 
if (cm.field1_id = cpt4_cd)
	rDATA->ENC[d.seq].cptcd = trim(cm.field6,3)
elseif(cm.field1_id = cpt4_mod_cd)
	rDATA->ENC[d.seq].cptcdmod  = trim(cm.field6,3)
endif
 
WITH NOCOUNTER ; , format, separator = " ", check
 
 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
; outbound aliasing
FOR (I = 1 TO SIZE(rDATA->ENC,5))
  	set rDATA->ENC[I].Insurance_Rel_to_Pt_A = trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_Rel_to_Pt_A)),3)
  	set rDATA->ENC[I].Insurance_Rel_to_Pt_B = trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_Rel_to_Pt_B)),3)
   	set rDATA->ENC[I].Insurance_Rel_to_Pt_C = trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_Rel_to_Pt_C)),3)
	set rDATA->ENC[I].PAT_TYPE	= concat(
										trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].pat_type)),3),
										trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].facility)),3))
	SET rDATA->ENC[I].SEX_alias			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].SEX)),3)
	set rDATA->ENC[I].pat_type_ioe	    =  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].PAT_TYPE_CLASS)),3)
	set rDATA->ENC[I].expired_alias 	=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].expired)),3)
	set rDATA->ENC[I].marital_alias 	=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].marital)),3)
 	set rDATA->ENC[I].FACILITY			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].FACILITY)),3)
 	SET rDATA->ENC[I].guarRel			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].guarRel)),3)
 	set rDATA->ENC[I].ethnicity 		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].ethnicity)),3)
	set rDATA->ENC[I].acc_type			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].acc_type)),3)
 
; The following will need to be outbound aliased for the longer term
 
  if (  rDATA->ENC[I].FACILITY_CD in (
  2553455113.00
, 2553456217.00
, 2553456225.00
, 2561621245.00
, 2553455121.00
, 2553456233.00
, 2553456241.00
, 2561623709.00
, 2611189755.00
, 2561652641.00
, 2561652569.00
, 2553455129.00
, 2553456249.00
, 2553456257.00
, 2561623787.00
))
		set rDATA->ENC[I].FACILITY = "G"
 endif
 
 
 
 
 
 
 	;marital status field 21
 
 	case (rDATA->ENC[I].MARITAL_alias)
		of "M": set rDATA->ENC[I].MARITAL_ALIAS  = "M"
		of "P": set rDATA->ENC[I].MARITAL_ALIAS  = "U"
		of "X": set rDATA->ENC[I].MARITAL_ALIAS  = "S"
		of "U": set rDATA->ENC[I].MARITAL_ALIAS  = "K"
 		of "D": set rDATA->ENC[I].MARITAL_ALIAS  = "D"
 		of "S": set rDATA->ENC[I].MARITAL_ALIAS  = "I"
 		of "W": set rDATA->ENC[I].MARITAL_ALIAS  = "W"
 		of " ": set rDATA->ENC[I].MARITAL_ALIAS  = "|"
 		of "" : set rDATA->ENC[I].MARITAL_ALIAS  = "|"
 		else 	set rDATA->ENC[I].MARITAL_ALIAS  = "R"
 	endcase
 
 	;ethnic code field 24
 	case (rDATA->ENC[I].ethnicity)
		of "1": set rDATA->ENC[I].ethnicity  = "H"
		of "2": set rDATA->ENC[I].ethnicity  = "UK"
		of "4": set rDATA->ENC[I].ethnicity  = "UK"
		of "5": set rDATA->ENC[I].ethnicity  = "UK"
 		else 	set rDATA->ENC[I].ethnicity  = "UK"
 	endcase
 
	;accident field 209
	 case (rDATA->ENC[I].acc_type )
		of "1": set rDATA->ENC[I].acc_type  	= "AA"
		of "2": set rDATA->ENC[I].acc_type  	= "OA"
		of "3": set rDATA->ENC[I].acc_type  	= "OA"
		of "4": set rDATA->ENC[I].acc_type  	= "EM"
		of "5": set rDATA->ENC[I].acc_type  	= "OA"
		of "6": set rDATA->ENC[I].acc_type  	= "OA"
 		else   set rDATA->ENC[I].acc_type 		= "|"
 	 endcase
 
	;patient employment field 22
	 case (rDATA->ENC[I].emp_status )
		of "1": set rDATA->ENC[I].emp_status  	= "FT"
		of "2": set rDATA->ENC[I].emp_status  	= "PT"
		of "3": set rDATA->ENC[I].emp_status  	= "NE"
		of "4": set rDATA->ENC[I].emp_status  	= "SE"
		of "5": set rDATA->ENC[I].emp_status  	= "RT"
		of "6": set rDATA->ENC[I].emp_status  	= "AU"
		of "7": set rDATA->ENC[I].emp_status  	= "UK"
		of "9": set rDATA->ENC[I].emp_status  	= "UK"
 		else    set rDATA->ENC[I].emp_status 	= "UK"
 	 endcase
 
 	;  RELATIONSHIP fields 46, 144, 174, 204
 case (rDATA->ENC[I].guarRel )
		of "1": set rDATA->ENC[I].guarRel  	= "14"
		of "2": set rDATA->ENC[I].guarRel  	= "34"
		of "3": set rDATA->ENC[I].guarRel  	=  "2"
		of "4": set rDATA->ENC[I].guarRel  	= "34"
		of "5": set rDATA->ENC[I].guarRel  	=  "5"
		of "6": set rDATA->ENC[I].guarRel  	= "10"
		of "7": set rDATA->ENC[I].guarRel  	=  "4"
		of "8": set rDATA->ENC[I].guarRel  	=  "3"
		of "9": set rDATA->ENC[I].guarRel 	=  "1"
		of "N": set rDATA->ENC[I].guarRel  	= "34"
		of "O": set rDATA->ENC[I].guarRel  	= "34"
		of "P": set rDATA->ENC[I].guarRel  	= "18"
		of "V": set rDATA->ENC[I].guarRel  	= "34"
		of "X": set rDATA->ENC[I].guarRel  	= "34"
		of "Y": set rDATA->ENC[I].guarRel  	= "34"
		of "Z": set rDATA->ENC[I].guarRel  	= "34"
 		of " ": set rDATA->ENC[I].guarRel   = "|"
 		of "" : set rDATA->ENC[I].guarRel  	= "|"
		else    set rDATA->ENC[I].guarRel 	= "21"
 	 endcase
 
 	; GUARENTOR RELATIONSHIP fields 46, 144, 174, 204
 case (rDATA->ENC[I].Insurance_Rel_to_Pt_A )
		of "1": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "14"
		of "2": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "34"
		of "3": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	=  "2"
		of "4": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "34"
		of "5": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	=  "5"
		of "6": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "10"
		of "7": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	=  "4"
		of "8": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	=  "3"
		of "9": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	=  "1"
		of "N": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "34"
		of "O": set rDATA->ENC[I].Insurance_Rel_to_Pt_A 	= "34"
		of "P": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "18"
		of "V": set rDATA->ENC[I].Insurance_Rel_to_Pt_A 	= "34"
		of "X": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "34"
		of "Y": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "34"
		of "Z": set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "34"
 		of " ": set rDATA->ENC[I].Insurance_Rel_to_Pt_A 	= "|"
 		of "" : set rDATA->ENC[I].Insurance_Rel_to_Pt_A  	= "|"
		else    set rDATA->ENC[I].Insurance_Rel_to_Pt_A 	= "21"
 	 endcase
 
 	; GUARENTOR RELATIONSHIP fields 46, 144, 174, 204
 case (rDATA->ENC[I].Insurance_Rel_to_Pt_B )
		of "1": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "14"
		of "2": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "34"
		of "3": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	=  "2"
		of "4": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "34"
		of "5": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	=  "5"
		of "6": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "10"
		of "7": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	=  "4"
		of "8": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	=  "3"
		of "9": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	=  "1"
		of "N": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "34"
		of "O": set rDATA->ENC[I].Insurance_Rel_to_Pt_B  	= "34"
		of "P": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "18"
		of "V": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "34"
		of "X": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "34"
		of "Y": set rDATA->ENC[I].Insurance_Rel_to_Pt_B  	= "34"
		of "Z": set rDATA->ENC[I].Insurance_Rel_to_Pt_B   	= "34"
 		of " ": set rDATA->ENC[I].Insurance_Rel_to_Pt_B  	= "|"
 		of "" : set rDATA->ENC[I].Insurance_Rel_to_Pt_B 	= "|"
		else    set rDATA->ENC[I].Insurance_Rel_to_Pt_B 	= "21"
 	 endcase
 
 	; GUARENTOR RELATIONSHIP fields 46, 144, 174, 204
 case (rDATA->ENC[I].Insurance_Rel_to_Pt_C )
		of "1": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "14"
		of "2": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "3": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	=  "2"
		of "4": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "5": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	=  "5"
		of "6": set rDATA->ENC[I].Insurance_Rel_to_Pt_C  	= "10"
		of "7": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	=  "4"
		of "8": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	=  "3"
		of "9": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	=  "1"
		of "N": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "O": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "P": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "18"
		of "V": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "X": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "Y": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
		of "Z": set rDATA->ENC[I].Insurance_Rel_to_Pt_C   	= "34"
 		of " ": set rDATA->ENC[I].Insurance_Rel_to_Pt_C 	= "|"
 		of "" : set rDATA->ENC[I].Insurance_Rel_to_Pt_C 	= "|"
		else    set rDATA->ENC[I].Insurance_Rel_to_Pt_C  	= "21"
 	 endcase
 
 endfor
 
 
;demographic output
; SELECT distinct INTO VALUE ($POUTDEV)
sELECT  distinct INTO VALUE (output->temp_demo)
;select distinct  into "NL:"
 
dispfac	= concat(replace(rDATA->ENC[d.seq].facility ,CHAR(0),"|"), char(32),
  								replace(rDATA->ENC[d.seq].pat_type_ioe,CHAR(0),"|"), char(32),
								replace(rDATA->ENC[d.seq].pat_type,CHAR(0),"|"))
,namef  			= evaluate2(if (substring(1,12,trim(rDATA->ENC[d.seq].first_name,3))> char(32))
 		substring(1,12,trim(rDATA->ENC[d.seq].first_name,3)) else "|" endif)
,namel				= evaluate2(if (substring(1,33,trim(rDATA->ENC[d.seq].last_name,3))> char(32))
 		substring(1,33,trim(rDATA->ENC[d.seq].last_name,3)) else "|" endif)
,namem = evaluate2(if (substring(1,1,trim(rDATA->ENC[d.seq].M_name,3))> char(32))
 		substring(1,1,trim(rDATA->ENC[d.seq].M_name,3)) else "|" endif)
,DOB		= replace(FORMAT(rDATA->ENC[d.seq].BIRTH_DT_TM, "YYYYMMDD;;D"),char(0), "|")
,filler6	= "|"
,SEX		= replace(substring(1,1, rDATA->ENC[d.seq].SEX_alias),CHAR(0),"|")
,ADDRESS 	=  evaluate2(if (trim(rDATA->ENC[d.seq].ADDRESS ,3)		> char(32))
 	substring(1,30,trim(rDATA->ENC[d.seq].ADDRESS ,3)) else "|" endif)
,ADDRESS2 	=  evaluate2(if (trim(rDATA->ENC[d.seq].ADDRESS2 ,3)	> char(32))
 	substring(1,30,trim(rDATA->ENC[d.seq].ADDRESS2 ,3)) else "|" endif)
,zipcode 	=  evaluate2(if (trim(rDATA->ENC[d.seq].ZIPCODE ,3)		> char(32))
 	substring(1,9,trim(rDATA->ENC[d.seq].ZIPCODE ,3)) else "|" endif)
,phone_h 	=  evaluate2(if (trim(rDATA->ENC[d.seq].PHONE_HOME ,3)	> char(32))
		substring(1,10,trim(rDATA->ENC[d.seq].PHONE_HOME ,3)) else "|" endif)
, filler12			= "|"
, SSN  				=  evaluate2(if (trim(rDATA->ENC[d.seq].ssn ,3)		> char(32))
 	substring(1,9,trim(rDATA->ENC[d.seq].ssn ,3)) else "|" endif)
 
, PatEMPName		=  evaluate2(if (trim(rDATA->ENC[d.seq].emp_name ,3)> char(32))
	substring(1, 50	,trim(rDATA->ENC[d.seq].emp_name ,3)) else "|" endif)
 
 
, PatEMPAddress1	=  evaluate2(if (trim(rDATA->ENC[d.seq].EMP_ADDR1 ,3)> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].EMP_ADDR1 ,3)) else "|" endif)
, filler16			= "|"
, PatEMPZipcode		= 	evaluate2(if (trim(rDATA->ENC[d.seq].EMP_ZIP  ,3)	> char(32))
							substring(1,9,trim(rDATA->ENC[d.seq].EMP_ZIP  ,3)) else "|" endif)
, PatEMPPhone		= evaluate2(if (trim(rDATA->ENC[d.seq].PHONE_BIZ  ,3)		> char(32))
		substring(1,10	,trim(rDATA->ENC[d.seq].PHONE_BIZ  ,3)) else "|" endif)
, CMRN  	 		= evaluate2(if (trim(rDATA->ENC[d.seq].mrn  ,3)		> char(32))
			substring(1,20	,trim(rDATA->ENC[d.seq].mrn  ,3)) else "|" endif)
, FIN  	 			= evaluate2(if (trim(rDATA->ENC[d.seq].fin  ,3)		> char(32))
			substring(1,20	,trim(rDATA->ENC[d.seq].fin  ,3)) else "|" endif)
, marital			= evaluate2(if (trim(rDATA->ENC[d.seq].MARITAL_ALIAS  ,3) > char(32))
 	substring(1,1	,trim(rDATA->ENC[d.seq].MARITAL_ALIAS  ,3)) else "|" endif)
, PatEmpStatus		= evaluate2(if (trim(rDATA->ENC[d.seq].emp_status  ,3)		> char(32))
	substring(1,2	,trim(rDATA->ENC[d.seq].emp_status  ,3)) else "|" endif)
, PatStudentStatus 	=  "|"
, PatEthnicCode		= evaluate2(if (trim(rDATA->ENC[d.seq].ethnicity  ,3)		> char(32))
	substring(1,1	,trim(rDATA->ENC[d.seq].ethnicity  ,3)) else "|" endif)
, GuarFirstName	 	= evaluate2(if (trim(rDATA->ENC[d.seq].guarFirstName  ,3)		> char(32))
	substring(1,12	,trim(rDATA->ENC[d.seq].guarFirstName   ,3)) else "|" endif)
, GuarLastName	 	=  evaluate2(if (trim(rDATA->ENC[d.seq].guarLastName  ,3)		> char(32))
	substring(1,33	,trim(rDATA->ENC[d.seq].guarLastName   ,3)) else "|" endif)
, GuarMiddleName	= evaluate2(if (trim(rDATA->ENC[d.seq].guarMiddleName  ,3)		> char(32))
	substring(1,1	,trim(rDATA->ENC[d.seq].guarMiddleName ,3)) else "|" endif)
, GuarDateOfBirth	= FORMAT(rDATA->ENC[d.seq].guarDateOfBirth, "YYYYMMDD;;D")
, filler29			= "|"
, GuarAddress1	 	= evaluate2(if (trim(rDATA->ENC[d.seq].guarAddress1,3)		> char(32))
						substring(1, 30	,trim(rDATA->ENC[d.seq].guarAddress1  ,3)) else "|" endif)
, GuarAddress2		= evaluate2(if (trim(rDATA->ENC[d.seq].guarAddress2,3)		> char(32))
						substring(1, 30	,trim(rDATA->ENC[d.seq].guarAddress2  ,3)) else "|" endif)
, GuarZipcode		= evaluate2(if (trim(rDATA->ENC[d.seq].guarZipcode  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].guarZipcode   ,3)) else "|" endif)
, GuarPhone	 		= evaluate2(if (trim(rDATA->ENC[d.seq].guarPhone  ,3)		> char(32))
						substring(1,10	,trim(rDATA->ENC[d.seq].guarPhone ,3)) else "|" endif)
, filler34			= "|"
, GuarSSN	 		= evaluate2(if (trim(rDATA->ENC[d.seq].guarSSN  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].guarSSN  ,3)) else "|" endif)
, GuarempName		= evaluate2(if (trim(rDATA->ENC[d.seq].guarempName  ,3)		> char(32))
						substring(1,50	,trim(rDATA->ENC[d.seq].guarempName  ,3)) else "|" endif)
, GuarempAddress1	= evaluate2(if (trim(rDATA->ENC[d.seq].guarempAddress1  ,3)		> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].guarempAddress1  ,3)) else "|" endif)
, filler38			= "|"
, GuarempZipcode	= evaluate2(if (trim(rDATA->ENC[d.seq].guarempZipcode  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].guarempZipcode  ,3)) else "|" endif)
, GuarempPhone	 	= evaluate2(if (trim(rDATA->ENC[d.seq].guarempPhone ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].guarempPhone   ,3)) else "|" endif)
, filler41 			= "|"
, filler42			= "|"
, filler43			= "|"
, filler44 			= "|"
, filler45 			= "|"
, GuarRelationship	=  evaluate2(if (trim(rDATA->ENC[d.seq].guarRel  ,3)		> char(32))
						substring(1,2	,trim(rDATA->ENC[d.seq].guarRel  ,3)) else "|" endif)
, filler47 = "|"
, filler48 = "|"
, filler49 = "|"
, filler50 = "|"
, filler51 = "|"
, filler52 = "|"
, filler53 = "|"
, filler54 = "|"
, filler55 = "|"
, filler56 = "|"
, filler57 = "|"
, filler58 = "|"
, filler59 = "|"
, filler60 = "|"
, filler61 = "|"
, filler62 = "|"
, filler63 = "|"
, filler64 = "|"
, filler65 = "|"
, filler66 = "|"
, filler67 = "|"
, filler68 = "|"
, filler69 = "|"
, filler70 = "|"
, filler71 = "|"
, filler72 = "|"
, filler73 = "|"
, filler74 = "|"
, filler75 = "|"
, filler76 = "|"
, filler77 = "|"
, filler78 = "|"
, filler79 = "|"
, filler80 = "|"
, filler81 = "|"
, filler82 = "|"
, filler83 = "|"
, filler84 = "|"
, filler85 = "|"
, filler86 = "|"
, filler87 = "|"
, filler88 = "|"
, filler89 = "|"
, filler90 = "|"
, filler91 = "|"
, filler92 = "|"
, filler93 = "|"
, filler94 = "|"
, filler95 = "|"
, filler96 = "|"
, filler97 = "|"
, filler98 = "|"
, filler99 = "|"
, filler100 = "|"
, filler101 = "|"
, filler102 = "|"
, filler103 = "|"
, filler104 = "|"
, filler105 = "|"
, filler106 = "|"
, filler107 = "|"
, filler108 = "|"
, filler109 = "|"
 , refProviderCode 	= evaluate2(if (trim(rDATA->ENC[d.seq].REFERRING_ID  ,3)		> char(32))
						substring(1, 20	,trim(rDATA->ENC[d.seq].REFERRING_ID  ,3)) else "|" endif)
, refProviderName 	= evaluate2(if (trim(rDATA->ENC[d.seq].REFERRING_NAME  ,3)		> char(32))
						substring(1, 50	,trim(rDATA->ENC[d.seq].REFERRING_NAME   ,3)) else "|" endif)
, refProviderUPIN 	= evaluate2(if (trim(rDATA->ENC[d.seq].referring_upin  ,3)		> char(32))
						substring(1, 20	,trim(rDATA->ENC[d.seq].referring_upin  ,3)) else "|" endif)
, ProfileID			= evaluate2(if (trim(rDATA->ENC[d.seq].acc_type  ,3)			> char(32))
						substring(1, 2	,trim(rDATA->ENC[d.seq].acc_type   ,3)) else "|" endif)
, filler114 = "|"
, TheirPCarrierID	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Plan_Code_A  ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Plan_Code_A   ,3)) else "|" endif)
, PCarrierName		= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Plan_Name_A  ,3)		> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_Plan_Name_A   ,3)) else "|" endif)
, POwnerPolicyNumber = evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Policy_No_A  ,3)	> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Policy_No_A  ,3)) else "|" endif)
, POwnerGroupNumber	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Group_No_A  ,3)	> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Group_No_A  ,3)) else "|" endif)
, PCarrierAddress1	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Address_1_A  ,3)	> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_Address_1_A  ,3)) else "|" endif)
, filler120 = "|"
, PCarrierZip	 	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Zip_Code_A  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_Zip_Code_A  ,3)) else "|" endif)
, PCarrierPhone	 	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_phone_A  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_phone_A  ,3)) else "|" endif)
, filler123 = "|"
, POwnerFirstName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameF_A  ,3)	> char(32))
						substring(1,12	,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameF_A  ,3)) else "|" endif)
, POwnerLastName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameL_A  ,3)	> char(32))
						substring(1,33	,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameL_A  ,3)) else "|" endif)
, POwnerMiddleName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameM_A  ,3)	> char(32))
						substring(1,1,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameM_A,3)) else "|" endif)
, filler127 = "|"
, filler128 = "|"
 , POwnerAddress1	= evaluate2(if (	trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_A,3) > char(32))
						substring(1,30 ,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_A,3)) else "|" endif)
, filler130 = "|"
, POwnerZipcode	 	=  evaluate2(if (	 trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_A,3) > char(32))
 						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_A,3)) else "|" endif)
, filler132 = "|"
, filler133 = "|"
, filler134 = "|"
, POwnerEmployerName  = evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpName_A  ,3)		> char(32))
						substring(1,50	,trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpName_A  ,3)) else "|" endif)
, POwnerEmployerAddress1 = evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_A  ,3)	> char(32))
 					substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_A   ,3)) else "|" endif)
, filler137 = "|"
, POwnerEmployerZipcode	 = evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_A  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_A   ,3)) else "|" endif)
, filler139 = "|"
, filler140 = "|"
, filler141 = "|"
, filler142 = "|"
, filler143 = "|"
, PInsuredRelationship	= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_A  ,3)		> char(32))
						substring(1,2	,trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_A    ,3)) else "|" endif)
, TheirSCarrierID		= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_Plan_Code_B  ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Plan_Code_B    ,3)) else "|" endif)
, SCarrierName	 		= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_plan_name_B  ,3)		> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_plan_name_B  ,3)) else "|" endif)
, SOwnerPolicyNumber	= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_Policy_No_B  ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Policy_No_B   ,3)) else "|" endif)
, SOwnerGroupNumber	 	= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_Group_No_B  ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Group_No_B   ,3)) else "|" endif)
, SCarrierAddress1	 	= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_Address_1_B  ,3)		> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_Address_1_B   ,3)) else "|" endif)
, filler150 = "|"
, SCarrierZip	 	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Zip_Code_B  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_Zip_Code_B   ,3)) else "|" endif)
, SCarrierPhone	 	=  evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_phone_B  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_phone_B  ,3)) else "|" endif)
, filler153 = "|"
, SOwnerFirstName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameF_B  ,3)	> char(32))
						substring(1,12	,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameF_B  ,3)) else "|" endif)
, SOwnerLastName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameL_B  ,3)	> char(32))
						substring(1,33	,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameL_B  ,3)) else "|" endif)
, SOwnerMiddleName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameM_B  ,3)	> char(32))
						substring(1,1,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameM_B,3)) else "|" endif)
, filler157 = "|"
, filler158 = "|"
, SOwnerAddress1	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_B  ,3)		> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_B  ,3)) else "|" endif)
, filler160 = "|"
, SOwnerZipcode	 	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_B  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_B  ,3)) else "|" endif)
, filler162 = "|"
, filler163 = "|"
, filler164 = "|"
, SOwnerEmployerName = evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpName_B ,3)		> char(32))
					substring(1,50	 ,trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpName_B ,3)) else "|" endif)
 
, SOwnerEmployerAddress1	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_B   ,3)		> char(32))
						substring(1,10	,   trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_B   ,3)) else "|" endif)
 
, filler167 = "|"
, SOwnerEmployerZipcode		= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_B  ,3)		> char(32))
						substring(1,19	,trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_B  ,3)) else "|" endif)
, filler169 = "|"
, filler170 = "|"
, filler171 = "|"
, filler172 = "|"
, filler173 = "|"
 , SInsuredRelationship	= evaluate2(if ( trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_B  ,3)		> char(32))
						substring(1,2	,trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_B   ,3)) else "|" endif)
, TheirTCarrierID	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Plan_Code_C  ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Plan_Code_C   ,3)) else "|" endif)
, TCarrierName	 	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Plan_Name_C  ,3)		> char(32))
						substring(1,50	,trim(rDATA->ENC[d.seq].Insurance_Plan_Name_C   ,3)) else "|" endif)
, TOwnerPolicyNumber = evaluate2(if (    trim(rDATA->ENC[d.seq].Insurance_Policy_No_C   ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Policy_No_C   ,3)) else "|" endif)
, TOwnerGroupNumber	 = evaluate2(if (    trim(rDATA->ENC[d.seq].Insurance_Group_No_C  ,3)		> char(32))
						substring(1,20	,trim(rDATA->ENC[d.seq].Insurance_Group_No_C   ,3)) else "|" endif)
, TCarrierAddress1	 = evaluate2(if (    trim(rDATA->ENC[d.seq].Insurance_Address_1_C  ,3)		> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_Address_1_C   ,3)) else "|" endif)
, filler180 = "|"
, TCarrierZip	 	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Zip_Code_C  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_Zip_Code_C  ,3)) else "|" endif)
, TCarrierPhone	 	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_phone_C  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_phone_C  ,3)) else "|" endif)
, filler183 = "|"
, TOwnerFirstName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameF_C  ,3)	> char(32))
						substring(1,12	,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameF_C  ,3)) else "|" endif)
, TOwnerLastName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameL_C  ,3)	> char(32))
						substring(1,33	,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameL_C  ,3)) else "|" endif)
, TOwnerMiddleName	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberNameM_C  ,3)	> char(32))
						substring(1,1,trim(rDATA->ENC[d.seq].Insurance_SuscriberNameM_C,3)) else "|" endif)
, filler187 = "|"
, filler188 = "|"
, TOwnerAddress1	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_C  ,3)	> char(32))
						substring(1,30	,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_C    ,3)) else "|" endif)
, filler190 = "|"
, TOwnerZipcode	 	= evaluate2(if (     trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_C  ,3)		> char(32))
						substring(1,9	,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_C    ,3)) else "|" endif)
, filler192 = "|"
, filler193 = "|"
, filler194 = "|"
, TOwnerEmployerName	 	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpName_C   ,3)	> char(32))
						substring(1,50	,   trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpName_C   ,3)) else "|" endif)
, TOwnerEmployerAddress1	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_C  ,3)	> char(32))
						substring(1,30	,   trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpAdd1_C   ,3)) else "|" endif)
, filler197 = "|"
, TOwnerEmployerZipcode		= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_C   ,3)	> char(32))
						substring(1,9	,   trim(rDATA->ENC[d.seq].Insurance_SuscriberEmpZip_C   ,3)) else "|" endif)
, filler199 = "|"
, filler200 = "|"
, filler201 = "|"
, filler202 = "|"
, filler203 = "|"
, TInsuredRelationship	= evaluate2(if (trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_C  ,3)	> char(32))
							substring(1,2	,trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_C   ,3)) else "|" endif)
, ADM_Dt_tm  			= evaluate2(if (FORMAT(rData->ENC[d.seq].admit_dt_tm, "YYYMMDD;;D")	> char(32))
							FORMAT(rData->ENC[d.seq].admit_dt_tm, "YYYYMMDD;;D") else "|" endif)
, DISCH_Dt_tm  			= evaluate2(if (FORMAT(rData->ENC[d.seq].disch_dt_tm, "YYYYMMDD;;D")	> char(32))
							FORMAT(rData->ENC[d.seq].disch_dt_tm, "YYYYMMDD;;D") else "|" endif)
, DOAccDate 			= evaluate2(if (FORMAT(rData->ENC[d.seq].acc_dt_tm, "YYYYMMDD;;D")	> char(32))
							FORMAT(rData->ENC[d.seq].acc_dt_tm, "YYYYMMDD;;D") else "|" endif)
, StateOfAccident		= evaluate2(if (trim(rDATA->ENC[d.seq].acc_st  ,3)					> char(32))
							substring(1,2	,trim(rDATA->ENC[d.seq].acc_st  ,3)) else "|" endif)
, AccidentOrEmplInd		= evaluate2(if (trim(rDATA->ENC[d.seq].acc_type   ,3)				> char(32))
							substring(1,2	,trim(rDATA->ENC[d.seq].acc_type   ,3)) else "|" endif)
 
FROM
(dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
 
 
 order by
  rDATA->ENC[d.seq].FACILITYCD
 ,CMRN
 ,FIN
 ,namel
 ,namef
 ,DOB
 ,SEX
 ,SSN
 
 
 
 WITH PCFORMAT ("", value(char(9)) ,1,1)  ,FORMAT = CRSTREAM
 
 set rDATA->subt_demo = value(curqual)
 
 
;;***** declare blob working variables
declare OCFCOMP_VAR = f8 with Constant(uar_get_code_by("MEANING",120,"OCFCOMP")),protect
declare NOCOMP_VAR = f8 with Constant(uar_get_code_by("MEANING",120,"NOCOMP")),protect
declare good_blob = vc with protect
declare print_blob = c6000 with protect
declare outbuf = c32768  with protect
declare blobout = vc with protect
declare BlobNoRTF =  c6000 with protect
 
declare retlen = i4 with protect
declare offset = i4 with protect
declare newsize = i4 with protect
declare nortfsize = i4 with protect
declare finlen = i4 with protect
declare xlen=i4 with protect
declare crvar = c1 with protect
;declare num	= i4 with noconstant(0)
set tabVar = char(9)
set tvar = char(126)
set lfVar = char(10)
set crVar = char(13)
set setvar = concat(char(10), char(13))
set num 	= 0
set num1 	= 0
;
 
 
;dictation output with signatures
;SELECT INTO VALUE ($POUTDEV)
SELECT  INTO VALUE (output->temp_dict)
	  ce.person_id
	, ce.encntr_id
	, ce.order_id
	, ce.event_id
	, cb.EVENT_ID
	, cb.BLOB_LENGTH
	, cb.BLOB_SEQ_NUM
	, CB_COMPRESSION_DISP = UAR_GET_CODE_DISPLAY(CB.COMPRESSION_CD)
 
FROM
	  ce_blob   cb
	, clinical_event   ce
 
plan ce
where 	expand(num, 1, size(rDATA->ENC, 5), ce.event_id ,rDATA->ENC[num].event_id)
;where 	expand(num, 1, size(rDATA->ENC, 5), ce.order_id,rDATA->ENC[num].order_id)
and 	ce.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
and  	ce.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
AND   	ce.RESULT_STATUS_CD in ( auth_ver_cd, altered_cd, modified_cd)
 
join cb
where cb.event_id = ce.event_id
and 	cb.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
and  	cb.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
and 	cb.compression_cd = ocfcomp_var
 
 
/*plan cb
where
	expand(num, 1, size(rDATA->ENC, 5), cb.event_id ,rDATA->ENC[num].event_id)
	and 	cb.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
	and  	cb.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
	and 	cb.compression_cd = ocfcomp_var
join ce where ce.event_id = cb.event_id
AND   ce.RESULT_STATUS_CD in ( auth_ver_cd, altered_cd, modified_cd)
 
 
join oros
where oros.order_id = ce.order_id
 
  */
 
ORDER BY
	  ce.person_id
	, cb.event_id
	, cb.blob_seq_num
 
/*ORDER BY
	  ce.person_id
	, oros.encntr_id
	, oros.rad_report_id
	, ce.order_id
	, ce.last_utc_ts desc
	, cb.event_id
	, cb.blob_seq_num
*/
 
head report
 	cntd = 0
 	num = 0
 	numx = 0
	idx = 0
	cntx = 0
      	blob_out = " "
    	outbuf = " "
   	 	good_blob = " "
   	 	BlobNoRTF = " "
    	blobout = " "
    	print_blob = " "
 
  head  	cb.event_id
; head 	oros.rad_report_id
 	cntd = cntd + 1
 	num = 0
 	numx = 0
	idx = 0
	cntx = 0
	idx = locateval(numx, 1, size(rDATA->ENC, 5), cb.event_id ,rDATA->ENC[numx].event_id)
 
 ;	if (idx > 0)
    	blob_out = " "
    	outbuf = " "
   	 	good_blob = " "
   	 	BlobNoRTF = " "
    	blobout = " "
    	print_blob = " "
 
   ;****** initialize blobout to a size that will be large enough to hold the full uncompressed blob
    ;****** initialize space for the 32k segments
    for (x = 1 to (cb.blob_length/32768) )
      blobout = notrim(concat(notrim(blobout),notrim(fillstring(32768, " "))))
    endfor
    finlen = mod(cb.blob_length,32768)
    ;****** initialize space for the final segment.  the final segment will less than 32k.
    blobout = notrim(concat(notrim(blobout),notrim(substring(1,finlen,fillstring(32768, " ")))))
 
  ;  col 0 "*****************FIN:"   fin, crVar,    row +1
   ; col 0 "*****************Event ID:"  cb.event_id, crVar, row +1
 
 
		cntx = cntx + 1
   		retlen = 1
    	offset = 0
 
 ; TODO: Build fac with symbol mappings.
 ;			perf_dept = uar_get_code_display(oros.perf_dept_cd)
 
	;LINE 1
	pat_type  		=	replace(trim(rDATA->ENC[idx].pat_type, 3), CHAR(0), "") ;003
 
 	;003
	,fac			=	evaluate2(
							if (pat_type = "DCF")
								"W"
							elseif (pat_type = "CNF" and D.DPT = "XRF")
								"@"
							elseif (pat_type = "CNF" and D.DPT = "XRD")
								"#"
							elseif (pat_type = "AOF" and I.EXAM_CD_KEY = 41016)
								"%"
							elseif (pat_type = "COS" and D.DPT = "XRS")
								"$"
							else
								D.DPT
							endif
						)
	;
; 	 fac			=   build(replace(substring(1,1,  trim(rDATA->ENC[idx].FACILITY,3)), char(0),  "" )) ;003
 	,PAT_ACCT_NBR   = 	build(concat(trim(rDATA->ENC[idx].fin,3)))
 	,CK_IN_NUM		= 	build(trim(rDATA->ENC[idx].accessiond,3))
 	,CK_IN_DT_Y 	=   build(FORMAT(rDATA->ENC[idx].check_in_dt_tm, "YYYY;;D"),tvar)
	,CK_IN_DT_M  	= 	build(FORMAT(rDATA->ENC[idx].check_in_dt_tm, "MM;;D")  ,tvar)
	,CK_IN_DT_D  	= 	build(FORMAT(rDATA->ENC[idx].check_in_dt_tm, "DD;;D")  ,tvar)
	,CK_IN_DT_T  	= 	build(FORMAT(rDATA->ENC[idx].check_in_dt_tm, "HHMM;;D") ,tvar)
	,RAD_DR_ID  	=   build(trim(replace(trim(rDATA->ENC[idx].RADIOLOGIST_ID,3),CHAR(0),""),3))
	,RAD_DR_FISRT   = 	build(trim(replace(trim(rDATA->ENC[idx].rad_dr_name_f,3),CHAR(0),""),3))
	,RAD_DR_LAST  	= 	trim(replace(trim(rDATA->ENC[idx].rad_dr_name_l,3),CHAR(0),""),3)
	,ORD_DR_ID  	= 	trim(replace(trim(rDATA->ENC[idx].ORDERING_ID,3),CHAR(0),""),3)
	,ORD_DR_FIRST   = 	trim(replace(trim(rDATA->ENC[idx].ord_dr_name_f,3),CHAR(0),""),3)
	,ORD_DR_LAST  	= 	trim(replace(trim(rDATA->ENC[idx].ord_dr_name_l,3),CHAR(0),""),3)
	,pat_type_ioe	= 	trim(replace(trim(rDATA->ENC[idx].pat_type_ioe,3),CHAR(0),""),3)
	,ofill			=   build(concat(trim(rDATA->ENC[idx].oid_disp,3)))
	,ofill2			=   trim(replace(build(cnvtstring(cnvtint(rDATA->ENC[idx].order_id))),CHAR(32),""),3)
	if (substring(4,2,cnvtupper(rDATA->ENC[idx].accessiond)) = "IR")
			RAD_PROC_TYPE	=	trim("INVA",3) ;replace(rDATA->ENC[idx].RAD_PROC_TYPE,CHAR(0),"")
		else
			RAD_PROC_TYPE	=	trim("DIAG",3) ;replace(rDATA->ENC[idx].RAD_PROC_TYPE,CHAR(0),"")
		ENDIF
 
		col 0 	fac, tvar,
				pat_acct_nbr, 		tvar,
				ofill, 				tvar,
				CK_IN_DT_Y ,
				CK_IN_DT_M,
				CK_IN_DT_D,
				CK_IN_DT_T ,
				rad_dr_id, 			tvar,
				RAD_DR_FISRT, 		tvar,
				RAD_DR_LAST 		tvar,
				ORD_DR_ID , 		tvar,
				ORD_DR_FIRST, 		tvar,
				ORD_DR_LAST , 		tvar,
				pat_type_ioe,		tvar,
				RAD_PROC_TYPE 		crvar,
 
		row + 1
 
	;;LINE 2
		 UNIT_NBR		= trim(rDATA->ENC[idx].mrn,3)
		,FIRST_NAME  	= build(replace(trim(rDATA->ENC[idx].FIRST_NAME,3),CHAR(0),""))
		,M_name  		= replace(trim(rDATA->ENC[idx].M_name,3),CHAR(0),"")
		,LAST_NAME   	= build(replace(trim(rDATA->ENC[idx].LAST_NAME,3),CHAR(0),""))
		,dob_year   	= FORMAT( rDATA->ENC[idx].BIRTH_DT_TM, "YYYY;;D")
		,dob_month   	= FORMAT( rDATA->ENC[idx].BIRTH_DT_TM, "MM;;D")
		,dob_day   		= FORMAT( rDATA->ENC[idx].BIRTH_DT_TM, "DD;;D")
		,SEX_ALIAS   	= replace(trim(rDATA->ENC[idx].SEX_ALIAS,3),CHAR(0),"")
		,IPlan_Name    	= replace(trim(rDATA->ENC[idx].Insurance_Plan_Name_A,3),CHAR(0),"")
		,IPlan_Code    	= replace(trim(rDATA->ENC[idx].Insurance_Plan_Code_A,3),CHAR(0),"")
;		,pat_type  		= replace(trim(rDATA->ENC[idx].pat_type,3),CHAR(0),"") ;003
 
 
		col 0 	UNIT_NBR,		 	tvar,
				FIRST_NAME, 		tvar,
				M_name, 			tvar,
				LAST_NAME, 			tvar,
				dob_year, 			tvar,
				dob_month , 		tvar,
				dob_day, 			tvar,
				SEX_ALIAS, 			tvar,
				IPlan_Name, 		tvar,
				IPlan_Code, 		tvar,
				pat_type ,			crvar,
		row + 1
;
;;LINE 3
		,RAD_ORD_PROC 	= concat("Procedure Ordered: " , rDATA->ENC[idx].order_mnem)
		,ADMIT_DX  		= concat("Admitting DX: ",  rDATA->ENC[idx].ADMIT_DX )
		,WORK_DX  		= concat("Working DX: ",  rDATA->ENC[idx].work_dx )
		,rad_dr			= rDATA->ENC[idx].RADIOLOGIST_ID
 
 
 		col 0 "Procedure Ordered: ", ck_in_num, tvar
 		rDATA->ENC[idx].order_cat_cd  , tvar,
 		rDATA->ENC[idx].order_mnem, tvar,
 		rDATA->ENC[idx].cptcd,
 		rDATA->ENC[idx].cptcdmod, tvar,
 		ofill2, crvar,
 
 		row + 1, ; rad_ord_proc, crvar,row + 1
 ;;LINE 4
  		col 0 "Admitting DX: ", rDATA->ENC[idx].ADMIT_DX , crvar, row + 1, ; ADMIT_DX   ,crvar,row + 1,
 ;;line 5
  		col 0 "Working DX: ", rDATA->ENC[idx].work_dx, crvar, row + 1,  ;WORK_DX, crvar,row + 1,
 ;;line 6
 		col 0 crvar, row + 1
 
 ; 	endif
 DETAIL
 
   ;*** get the blob segments and concat them into a single variable named good_blob
    ;*** the following while loop is used in case the blob_contents is actually more than 32k
    ;*** in most cases the while loop will only be executed one time because the blob is stored
    ;*** in 32k segments
 
    while (retlen > 0)
       ;;; ***  this gets a segment of the blob upto 32000 specified by retlen, offset is an accum of retlen
        retlen = blobget(outbuf, offset, cb.blob_contents)
        offset = offset + retlen
        if(retlen!=0)
            ;*** when dealing with CE_BLOB each row is ended with the tag "ocf_blob"
            ;*** these tags need to be excluded when the blob segments are re-assembled
            xlen = findstring("ocf_blob",outbuf,1)-1
 
            if(xlen<1)
              xlen = retlen
            endif
 
            good_blob = notrim(concat(notrim(good_blob), notrim(substring(1,xlen,outbuf))))
 
        endif
    endwhile
 
foot  	cb.event_id
;foot 	oros.rad_report_id
 
    newsize = 0
    good_blob = concat(notrim(good_blob),"ocf_blob")
    blob_un = uar_ocf_uncompress(good_blob, size(good_blob),
                            blobout, size(blobout),newsize )
   	stat = memrealloc(BlobNoRTF,1,build("c",size(blobout)))
    stat = uar_rtf2(blobout,
                    size(blobout),
                    BlobNoRTF,
                    size(BlobNoRTF),
                    nortfsize,
                    1)
 
    offset = 1
    while (offset < size(trim(BlobNoRTF,3)))
          print_blob = substring(offset, 5999, trim(BlobNoRTF,3))
	      ;print_blob = replace(replace(trim(print_blob,3),char(13),"|"),char(10),"")
        if (size(print_blob) > 0)
 
            col  0 print_blob, crvar
            row +1
        endif
        offset = offset + 5999
    endwhile
    		IF (IDX > 0)
    		row +1
			transcriptionist = concat ("Transcriptionist- ",  rDATA->ENC[idx].TRANSCRIBED )
			readby			 = concat ("Read By- ",   rDATA->ENC[idx].TRANSCRIBED )
			revby			 = concat ("Reviewed and E-Signed By- ",  rDATA->ENC[idx].APPROVED )
			released		 = concat ("Released Date Time- ",format(rDATA->ENC[idx].APPROVED_dt_tm, "mm/dd/yy hh:mm;;d"))
 
 IF (rDATA->ENC[idx].TRANSCRIBED  >  " ")
			col 5 "Transcriptionist- ", rDATA->ENC[idx].TRANSCRIBED     ,crvar, row+ 1,   ;transcriptionist, crvar, row+ 1,
			col 5 "Read By- ",rDATA->ENC[idx].TRANSCRIBED     , crvar, row+ 1  ;readby, crvar, row+ 1,
 ELSE
 			col 5 "Transcriptionist- ", rDATA->ENC[idx].DICTATED     ,crvar, row+ 1,   ;transcriptionist, crvar, row+ 1,
 			col 5 "Read By- ",rDATA->ENC[idx].DICTATED     , crvar, row+ 1  ;readby, crvar, row+ 1,
 ENDIF
 
 			col 5 "Reviewed and E-Signed By- ",rDATA->ENC[idx].APPROVED 		, crvar, row+ 1,	;revby, crvar, row+ 1,
			col 5 released, crvar, row+ 1,
			col 0 "------------------------------------------------------------------------------", crvar, row + 1
 			col 0 "|", crvar,
			row + 1
			ENDIF
 foot report
 	rDATA->subt_dict = cntd
 
 
 
  WITH  RDBARRAYFETCH = 1,  maxcol = 6003, check, expand = 1
  ,PCFORMAT ("", value(char(32)) ,1,1), maxrow = 1
     ,FORMAT = CRSTREAM, formfeed = none
 
;WITH memsort, nocounter, format, check, separator = " "
 
 
 call echorecord(rdata)
; for testing only once this is validated then the calls to astream file location will be via operations
 
 set statx = 0
 ; demo file
set  output->temp  = concat("cp $cer_temp/", output->filename," ",output->astream, output->filename)
call echo (output->temp);
call dcl( output->temp ,size(output->temp  ), statx)
set output->temp = ""
 
; dictation file
set  output->temp  = concat("cp $cer_temp/", output->filenamed," ",output->astream, output->filenamed)
call echo (output->temp);
call dcl( output->temp ,size(output->temp  ), statx)
set output->temp = ""
 
 
 
#exit_script
 FREE RECORD rdata
end go
 

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
* Feature	Mod	Date		Engineer	Comment                                                                        *
* -------	---	----------	----------	-------------------------------------------------------------------------------*
			000	09/14/2018	ARG			Initial release (Alix Govatsos)
			001	10/22/2018	TAB			Corrected date formats.
			002	10/23/2018	TAB			Adjusted start date prompt.
			003	10/24/2018	TAB			Updated list of radiologists.
			004 11/08/2018  DG          Added DOB for Insurance Subscribers to export file in the *BD fields.
			005 12/10/2018  TAB			Adjusted CCL to correct missing or incorrect fields for export file.
			006	01/04/2019	TAB			Updated list of radiologists.
			007	01/09/2019	TAB			Fixed missing outerjoin for insurances.
			008	01/16/2019	TAB			Updated list of radiologists.
			009	01/17/2019	TAB			Removed accession exclusion of CA.
			010	02/01/2019	TAB			Updated list of radiologists.
			011	06/06/2019	TAB			Updated list of radiologists.
			012	06/14/2019	TAB			Updated list of radiologists.
			013	08/02/2019	TAB			Updated list of radiologists.
			014	08/26/2019	TAB			Updated list of radiologists.
			015	09/23/2019	TAB			Corrected list of radiologists.
			016	09/24/2019	TAB			Moved list of radiologists to include file.
			017	02/04/2021	TAB			Added logic for contract accounts.
 
************************* END OF ALL MODCONTROL BLOCKS *****************************************************************/
 
 
DROP PROGRAM 	cov_aur_rad_demog:dba GO
CREATE PROGRAM 	cov_aur_rad_demog:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"           ;* Enter or select the printer or file name to send this report to.
	, "Start Date:" = "SYSDATE"
	, "End Date:" = "SYSDATE"
	, "Select a Facility:" = VALUE(0.0           )
 
with pOUTDEV, pSTART_DATE, pEND_DATE, pFACILITY
 
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
	1 dt_range = vc
)
 
set output->directory = logical("cer_temp")
set output->filename  = concat('aurcovdemog',format(curdate, "yyyymmdd;;d"), '_cer',  '.txt')
set output->astream = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Radiology/Extracts/AUR/"
set output->temp_demo = concat('cer_temp:aurcovdemog' ,  format(curdate, "yyyymmdd;;d"),'_cer', '.txt')
 
call echorecord (output)
 
 RECORD rDATA(
1 ENC[*]						;one occurrence per exam per encouonter per patient
2	ENCNTR_ID	= 	f8
2	PERSON_ID	= 	f8
2	FIRST_NAME	= 	C18
2	LAST_NAME	= 	C25
2	M_name 		= 	C18
2	NAME		= 	vc ;
2	ADDRESS		= 	C30	 ;
2	ADDRESS2	= 	C30	 ;
2	CITY	 	= 	vc	 ;
2	STATE	 	= 	vc	 ;
2	ZIPCODE	 	= 	C9	 ;
2	PHONE_HOME	= 	C10	 ;
2	PHONE_BIZ	= 	C10	 ;
2	BIRTH_DT_TM	= 	dq8
2	deceased_dt_tm = dq8
2	student_ind	= 	vc
2	emp_stat_ind	= vc
2	DOB	 		= 	c6
2	dob_year	= c4	;	format(p.birth_dt_tm ,"yyyy;;d")
2	dob_month	= c2  	;	format(p.birth_dt_tm ,"mm;;d")
2	dob_day		= c2	;	format(p.birth_dt_tm ,"dd;;d")
2	SEX	 		= 	VC
2	SEX_ALIAS	= 	C1
2	FIN	 = 	C20
2	emp_status	= vc
2 	emp_name 	= C33
2 	EMP_CITY 	= vc
2 	EMP_ADDR1 	= C30
2 	EMP_ADDR2 	= C30
2 	EMP_ZIP		= C9
2 	EMP_ST 		= vc
2	SSN	 		= 	C9
2	FAMILY_NAME	= 	vc
2	MARITAL	 = 	VC
2   ethnicity = vc
2	MARITAL_ALIAS	 = 	C1
2	admit_dt_tm	 = 	dq8
2	admit_date	 = 	c6
2	disch_dt_tm	 = 	dq8
2	disch_date	 = 	c6
2	pat_type_ioe = 	c1
2	MRN	 		= 	C20

2   encntr_plan_reltn_id_A = f8
2   encntr_plan_reltn_id_B = f8
2   encntr_plan_reltn_id_C = f8
 
2	Insurance_Plan_Name_A 	= 	C33
2	Insurance_Address_1_A 	= 	C30
2	Insurance_Address_2_A 	= 	C30
2	Insurance_City_A 	 	= 	vc
2	Insurance_State_A 	 	= 	vc
2	Insurance_Zip_Code_A 	= 	C9
2   Insurance_Phone_A		=   C10
2	Insurance_Insured_A 	= 	vc
2   II_A_person_id	= f8
2	Insurance_Subscriber_Address_1_A = C30
2	Insurance_Subscriber_Address_2_A = C30
2	Insurance_Subscriber_City_A	 	 = vc
2	Insurance_Subscriber_State_A	 = vc
2	Insurance_Subscriber_Zip_Code_A	 = C9
2	Insurance_Policy_No_A 	 	= vc
2	Insurance_Group_No_A 	 	= vc
2	Authorization_Number_A 	 		= vc	;005
2	Insurance_Rel_to_Pt_A 	= 	VC
2	Insurance_Plan_Code_A 	= 	vc
2	Insurance_SubscriberPhone_A 		= 	C10
2	Insurance_SubscriberPhoneBiz_A 		= 	C10		;005
2 	Insurance_SubscriberNameF_A		= 	C18
2 	Insurance_SubscriberNameL_A		= 	C25
2 	Insurance_SubscriberNameM_A		= 	C18
2   Insurance_SubscriberDOB_A		=   DQ8			;004
2   Insurance_SubscriberSex_A		=   vc			;005
2	Insurance_SubscriberSSN_A 		= 	C9			;005
2 	Insurance_SubscriberEmpName_A	= 	C33
2 	Insurance_SubscriberEmpAdd1_A	= 	C30
2 	Insurance_SubscriberEmpAdd2_A	= 	C30
2 	Insurance_SubscriberEmpCity_A	= vc
2 	Insurance_SubscriberEmpState_A	= vc
2 	Insurance_SubscriberEmpZip_A		= 	C9
2	Insurance_SubscriberEmpPhone_A 		= 	C10
 
2	Insurance_Plan_Name_B	 	= vc
2	Insurance_Address_1_B	 	= C30
2	Insurance_Address_2_B	 	= C30
2	Insurance_City_B	 	 	= VC
2	Insurance_State_B	 	 	= vc
2	Insurance_Zip_Code_B	 	= C9
2   Insurance_Phone_B			= C10
2	Insurance_Insured_B	 	 	= vc
2   II_B_person_id	= f8
2	Insurance_Subscriber_Address_1_B 	= 	cC30
2	Insurance_Subscriber_Address_2_B 	= C30
2	Insurance_Subscriber_City_B 	 	= 	vc
2	Insurance_Subscriber_State_B 	 	= 	vc
2	Insurance_Subscriber_Zip_Code_B 	= 	c9
2	Insurance_Policy_No_B	= vc
2	Insurance_Group_No_B	= 	 vc
2	Authorization_Number_B 	 		= vc	;005
2	Insurance_Rel_to_Pt_B 	= 	 vc
2	Insurance_Plan_Code_B	= 	 vc
2	Insurance_SubscriberPhone_B 		= 	C10
2	Insurance_SubscriberPhoneBiz_B 		= 	C10		;005
2 	Insurance_SubscriberNameF_B		= 	C18
2 	Insurance_SubscriberNameL_B		= 	C25
2 	Insurance_SubscriberNameM_B		= 	C18
2   Insurance_SubscriberDOB_B        =   DQ8		;004
2   Insurance_SubscriberSex_B		=   vc			;005
2	Insurance_SubscriberSSN_B 		= 	C9			;005
2 	Insurance_SubscriberEmpName_B	= 	C33
2 	Insurance_SubscriberEmpAdd1_B	= 	C30
2 	Insurance_SubscriberEmpAdd2_B	= 	C30
2 	Insurance_SubscriberEmpCity_B	= vc
2 	Insurance_SubscriberEmpState_B	= vc
2 	Insurance_SubscriberEmpZip_B		= 	C9
2	Insurance_SubscriberEmpPhone_B 		= 	C10
 
2	Insurance_Plan_Name_C		= vc
2	Insurance_Address_1_C		= C30
2	Insurance_Address_2_C 	= 	C30
2	Insurance_City_C	 		= vc
2	Insurance_State_C	 		= vc
2	Insurance_Zip_Code_C		= C9
2   Insurance_Phone_C			= C10
2	Insurance_Insured_C	 		= vc
2   II_C_person_id	= f8
2	Insurance_Subscriber_Address_1_C = C30
2	Insurance_Subscriber_Address_2_C = C30
2	Insurance_Subscriber_City_C	 			= vc
2	Insurance_Subscriber_State_C	 		= vc
2	Insurance_Subscriber_Zip_Code_C	 		= C9
2	Insurance_Policy_No_C	 		= vc
2	Insurance_Group_No_C	 		= vc
2	Authorization_Number_C 	 		= vc	;005
2	Insurance_Rel_to_Pt_C	 		= vc
2	Insurance_Plan_Code_C	 		= vc
2	Insurance_SubscriberPhone_C 		= 	C10
2	Insurance_SubscriberPhoneBiz_C 		= 	C10		;005
2 	Insurance_SubscriberNameF_C		= 	C18
2 	Insurance_SubscriberNameL_C		= 	C25
2 	Insurance_SubscriberNameM_C		= 	C18
2   Insurance_SubscriberDOB_C        =   DQ8			;004
2   Insurance_SubscriberSex_C		=   vc			;005
2	Insurance_SubscriberSSN_C 		= 	C9			;005
2 	Insurance_SubscriberEmpName_C	= 	C33
2 	Insurance_SubscriberEmpAdd1_C	= 	C30
2 	Insurance_SubscriberEmpAdd2_C	= 	C30
2 	Insurance_SubscriberEmpCity_C	= vc
2 	Insurance_SubscriberEmpState_C	= vc
2 	Insurance_SubscriberEmpZip_C		= 	C9
2	Insurance_SubscriberEmpPhone_C 		= 	C10
 
2 	ATTENDING_ID	=	 VC
2 	PCP_ID 			=	 VC
2 	pcp_name		=	 Vc
2 	FAMILY_ID 		=	 VC
 
2   guarperson_id	= 	f8
2 	guarFirstName	=	 C18
2	guarLastName	=	 C25
2	guarMiddleName	=	 C18
2   guarSex			=    vc
2	guarDateOfBirth	=	 dq8
2	guarAddress1	=	 C30
2	guarAddress2	=	 C30
2   guarCity		=    vc
2   guarstate		=    vc
2	guarZipcode		=	 C9
2	guarPhone		=	 C10
2	guarPhonebiz	=	 C10
2	guarSSN	  		=	 C9
2	guarRel			= 	 vc
2   guarmarital		= vc
2   guarethnic		= vc
2   guaremp			= vc
2	guarempName		=	 C33
2	guarempAddress1	=	 C30
2	guarempAddress2	=	 C30
2	guarempcity		= 	 vc
2	guarempZipcode	=	 C9
2   guarempstate	=    vc
2	guarempPhone	=	 C10
 
2   NOKperson_id	= 	 f8
2 	NOKFirstName	=	 C18
2	NOKLastName		=	 C25
2	NOKMiddleName	=	 C18
2	NOKDateOfBirth	=	 dq8
2	NOKAddress1		=	 C30
2	NOKAddress2		=	 C30
2   NOKCity			= 	 vc
2 	NOKState		= 	 vc
2	NOKZipcode		=	 C9
2	NOKPhone		=	 C10
2	NOKPhonebiz		=	 C10
2	NOKSSN	  		=	 C9
2	NOKempName		=	 C33
2	NOKempAddress1	=	 C30
2	NOKempAddress2	=	 C30
2	NOKempCity		=    vc
2   NOKempState		=    vc
2	NOKempZipcode	=	 C9
2	NOKempPhone		=	 C10
2	NOKSEX			= 	 VC
2   NOKRel			= 	 vc
2   NOKethnic		= 	 vc
2   NOKemp			= 	 vc
2   NOKmarital		=    vc
2   REFERRING_ID	=	 VC
2   referring_name	=    Vc
2   referring_upin	=    Vc
 
2 expired			=	 vc
2 expired_alias		= 	 vc
2 FACILITY_CD		=	 F8
2 FACILITYCD		=	 vc
2 FACILITY			=	 VC
2 site				= vc
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
declare  nok_cd 			= f8 with Constant(uar_get_code_by("MEANING", 351, "NOK")), protect
 
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

; contracts ;017
DECLARE contract_cd 			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",356,"CONTRACTNUMBER"))
DECLARE org_alias_cd			= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",334,"ENCOUNTERORGANIZATIONALIAS"))
DECLARE address_business_cd		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",212,"BUSINESS"))
DECLARE phone_business_cd		= F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY",43,"BUSINESS"))

 
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
 
 
%i cust_script:aur_radiologists.inc ;016
 
 
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
SELECT distinct INTO "NL:"
;SELECT DISTINCT INTO VALUE ($POUTDEV)
	  encntr_id 			= e.encntr_id
	, person_id 			= e.person_id
	, name_first 			= p.name_first
	, name_last 			= p.name_last
	, marital 				= cnvtstring(p.marital_type_cd)
	, name_mi 				= cnvtupper(substring(1,1,p.name_middle))
	, dob_year  			= format(p.birth_dt_tm ,"yyyy;;d")
	, dob_month  			= format(p.birth_dt_tm ,"mm;;d")
	, dob_day  				= format(p.birth_dt_tm ,"dd;;d")
	, fin  					= ea.alias
	, cmrn  				= cnvtalias(pa3.alias, pa3.alias_pool_cd)
	, ssn  			 		= pa2.alias
	, sex  			 		= cnvtstring( p.sex_cd )
	, expired  				= cnvtstring(p.deceased_cd)
	, pat_type  			= cnvtstring(e.encntr_type_cd)
	, PAT_TYPE_CLASS  		= CNVTSTRING(E.encntr_type_class_cD)
	, fac  			 		= cnvtstring(e.loc_facility_cd)
	, fac_disp  			= uar_get_code_display(e.loc_facility_cd)
	, nu_disp  				= uar_get_code_display(e.loc_nurse_unit_cd)
	, reg_dt_tm  			= e.reg_dt_tm "mm/dd/yyyy hh:mm;;d"
	, dsch_dt_tm  			= e.disch_dt_tm "mm/dd/yyyy hh:mm;;d"
	, o.accession
	, accession_ce  		= cnvtacc (ce.accession_nbr)
	, rad_order  			= uar_get_code_display (o.catalog_cd)
	, order_dt_tm  			= o.start_dt_tm "mm/dd/yyyy hh:mm;;d"
	, complete_dt_tm  		= o.complete_dt_tm "mm/dd/yyyy hh:mm;;d"
	, order_id  			= o.order_id
	, ord_type  			= uar_get_code_display(ord.catalog_type_cd )
	, CE.parent_event_id
	, ce.event_id
 	, ORD_PHYS_NAME_FIRST 	=  pr.name_first
	, ORD_PHYS_NAME_LAST 	=  pr.name_last
	, ORD_PHYS_ALIAS 		=  pa.alias
	, ord_phys_ap 			=  uar_get_code_display(PA.alias_pool_cd)
 
 
FROM
	OMF_RADMGMT_ORDER_ST   OROS
	,ENCOUNTER   E
	, (left JOIN person_alias pa2 ON (e.person_id = pa2.person_id
 			AND pa2.person_alias_type_cd = SSN_CD
			AND pa2.ACTIVE_IND = 1
			AND pa2.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)))
	, person   p
	, encntr_alias   ea
	, person_alias   pa3
	, orders   ord
	, PRSNL   PR
	, PRSNL_ALIAS   PA
	, clinical_event   ce
	, order_radiology   o
	, OMF_RADREPORT_ST ORRS
	, ce_blob cb
 
 
plan oros
where operator(oros.loc_at_exam_cmplt_cd,  FAC_VAR, $pFACILITY)
 
join e
where e.encntr_id = oros.encntr_id
 
JOIN  ea where ea.encntr_id = e.encntr_id
 			AND EA.ENCNTR_ALIAS_TYPE_CD = FIN_CD
			AND EA.ACTIVE_IND = 1
			AND EA.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
join 	p where  p.person_id = e.person_id
and  	p.active_ind = 1
; eliminate the zzz patients
and  	p.name_last_key !="Z*TEST*"
 
 
 
JOIN   pa3 where e.person_id = pa3.person_id
 			AND pa3.person_alias_type_cd = CMRN_CD;
			AND pa3.ACTIVE_IND = 1
			AND pa3.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
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
and 	not substring(6,2,ce.accession_nbr) in ('NP', 'SC') ;009
 
join cb
where cb.event_id = ce.event_id
 
join pr
where pr.person_id  = o.order_physician_id
 
join pa
where 	pa.person_id = pr.person_id
and 	PA.alias_pool_cd in (STARDOC_CD, statedoc_cd)
and 	(pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ; check on this type
or 		pa.end_effective_dt_tm between cnvtdatetime(start_date ) and cnvtdatetime(end_date))
 
 
join 	orrs
where 	((o.parent_order_id > 0.00 AND orrs.order_id = o.parent_order_id)
OR 		orrs.order_id = o.order_id)
and 	orrs.order_ID != 0.00
AND 	orrs.final_dt_tm  between cnvtdatetime(start_date ) and cnvtdatetime(end_date)
 
; AUR docs from include file
  and expand(num, 1, radiologists->cnt, orrs.radiologist_id, radiologists->list[num].person_id) ;016
 
join pa2
 
ORDER BY
  encntr_id
 ,fin
 ,oros.order_id
 ,oros.final_dt_tm
 ,accession_ce
 ,rad_order
 ,order_id
 ,ce.event_id
 
HEAD REPORT
CNT = 0
 
HEAD CE.EVENT_ID  ; need to use this now that the doc license id either star or state ID
;detail
CNT = CNT + 1
STAT = ALTERLIST (rData->ENC, cnt)
 
rDATA->ENC[cnt].ENCNTR_ID 	= e.encntr_id
rDATA->ENC[cnt].PERSON_ID 	= e.person_id
rDATA->ENC[cnt].NAME 		= ;concat(trim(p.name_first,3), char(32), trim(p.name_middle,3), char(32), trim(p.name_last,3))
SUBSTRING(1,25,concat(TRIM(P.name_last_key,3),CHAR(32),TRIM(P.name_first_key,3),CHAR(32),substring(1,1,trim(p.name_middle_key,3))))
 
rDATA->ENC[cnt].FIRST_NAME = p.name_first
rDATA->ENC[cnt].LAST_NAME 	= p.name_last ; concat("TEST",cnvtstring(cnt)) ;for testing only - mask the namep.name_last
rDATA->ENC[cnt].M_NAME 		= name_mi
rDATA->ENC[cnt].marital 	= marital
rDATA->ENC[cnt].MRN 		= cmrn
rDATA->ENC[cnt].FIN 		= fin
rDATA->ENC[cnt].DOB 		= format(p.birth_dt_tm, "MMDDYY;;d")
rDATA->ENC[cnt].deceased_dt_tm = p.deceased_dt_tm
rDATA->ENC[cnt].dob_year  	= dob_year
rDATA->ENC[cnt].dob_month  	= dob_month
rDATA->ENC[cnt].dob_day  	= dob_day
rDATA->ENC[cnt].birth_dt_tm = p.birth_dt_tm
rDATA->ENC[cnt].SEX 		= sex
rDATA->ENC[cnt].disch_dt_tm = e.disch_dt_tm
rDATA->ENC[cnt].admit_dt_tm = e.reg_dt_tm
rDATA->ENC[cnt].FACILITY_CD = E.loc_facility_cd
rDATA->ENC[cnt].FACILITY 	= cnvtstring(e.loc_facility_cd)
rDATA->ENC[cnt].NU_CD 		= E.loc_nurse_unit_cd
rDATA->ENC[cnt].NU 			= UAR_GET_CODE_DISPLAY(E.loc_nurse_unit_cd)
rDATA->ENC[cnt].PAT_TYPE  	=  cnvtstring(e.encntr_type_cd)
rDATA->ENC[cnt].PAT_TYPE_CLASS	= PAT_TYPE_CLASS
rDATA->ENC[cnt].expired 	= expired
rDATA->ENC[cnt].ethnicity = cnvtstring( p.ethnic_grp_cd)
rDATA->ENC[CNT].SSN	= format( trim(PA2.ALIAS,3),"#########;p0")
 
;ssn formatting
; rDATA->ENC[cnt].SSN = ssn
; rDATA->ENC[CNT].SSN					= format( trim(PA2.ALIAS,3),"###-##-####;p0") ;005
;	IF (cnvtint(rDATA->ENC[CNT].SSN) <=0  )
;		rDATA->ENC[CNT].SSN	 = ""
 
;	ENDIF
 
  foot report
 rDATA->total = cnt
 
WITH NOCOUNTER, memsort;, format, separator = " ", check
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!
;guarantor name and phone
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 state_disp = uar_get_code_display(a.state_cd)
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
	, (left join phone pb on (pr.person_id = pb.parent_entity_id
			and 	Pb.parent_entity_name =  "PERSON")
    		AND 	Pb.ACTIVE_IND =  1
    		AND 	Pb.PHONE_TYPE_CD =  163) ;biz
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
 join pb
 
 
 order by d.seq, a.address_id, p.phone_id
 
detail
 rDATA->ENC[d.seq].guarPerson_id	= epr.related_person_id
 rDATA->ENC[d.seq].guarFirstName 	= pr.name_first
 rDATA->ENC[d.seq].guarLastName  	= pr.name_last
 rDATA->ENC[d.seq].guarMiddleName  	= substring(1,1,trim(pr.name_middle,3))
 rDATA->ENC[d.seq].guarDateOfBirth  = pr.birth_dt_tm
 rDATA->ENC[d.seq].guarAddress1  	= a.street_addr
 rDATA->ENC[d.seq].guarSex			= cnvtstring (pr.sex_cd)
 rDATA->ENC[d.seq].guarAddress2  	= substring(1,30,trim(a.street_addr2,3))
 rDATA->ENC[d.seq].guarZipcode  	 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].guarcity			= trim(a.city,3)
 rDATA->ENC[d.seq].guarstate	 	= state_disp
 rDATA->ENC[d.seq].guarPhone  		= p.phone_num_key
 rDATA->ENC[d.seq].guarPhoneBiz  	= pb.phone_num_key
 rDATA->ENC[d.seq].guarSSN  		= pa.alias
 rDATA->ENC[d.seq].guarRel  		= cnvtstring(epr.person_reltn_cd)
 rDATA->ENC[d.seq].guarethnic 		= cnvtstring(pr.ethnic_grp_cd)
 
WITH nocounter ;, format, separator = " "
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; guar business and phone
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 state_disp = uar_get_code_display(a.state_cd)
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
 rDATA->ENC[d.seq].guarempaddress2  = trim(a.street_addr2,3)
 rDATA->ENC[d.seq].guarempstate		= state_disp
 rDATA->ENC[d.seq].guarempcity		= trim(a.city,3)
 rDATA->ENC[d.seq].guarEMPZIPCODE		 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].guarEMPphONE		= trim (ph.phone_num_key,3)
 rDATA->ENC[d.seq].guaremp			= cnvtstring(p.empl_status_cd)
 
WITH NOCOUNTER; , format, separator = " ", check
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!
;NOK name and phone
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 state_disp = uar_get_code_display(a.state_cd)
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
	, (left join phone pb on (pr.person_id = pb.parent_entity_id
			and 	Pb.parent_entity_name =  "PERSON")
    		AND 	Pb.ACTIVE_IND =  1
    		AND 	Pb.PHONE_TYPE_CD =  163) ;biz
Plan d
 
 	join 	epr
 	where 	epr.encntr_id = rDATA->ENC[d.seq].encntr_id
 	and 	epr.PERSON_RELTN_TYPE_CD = NOK_cd
 	and 	epr.active_ind = 1
 
 	JOIN    pr
 	where 	pr.person_id = epr.related_person_id
 join pa
 join a
 join p
 join pb
 
 
 order by d.seq, a.address_id, p.phone_id
 
detail
 rDATA->ENC[d.seq].NOKPerson_id	= epr.related_person_id
 rDATA->ENC[d.seq].NOKFirstName 	= pr.name_first
 rDATA->ENC[d.seq].NOKLastName  	= pr.name_last
 rDATA->ENC[d.seq].NOKMiddleName  	= substring(1,1,trim(pr.name_middle,3))
 rDATA->ENC[d.seq].NOKDateOfBirth  = pr.birth_dt_tm
 rDATA->ENC[d.seq].NOKAddress1  	= a.street_addr
 rDATA->ENC[d.seq].NOKSex			= cnvtstring (pr.sex_cd)
 rDATA->ENC[d.seq].NOKAddress2  	= substring(1,30,trim(a.street_addr2,3))
 rDATA->ENC[d.seq].NOKZipcode  	 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].NOKcity			= trim(a.city,3)
 rDATA->ENC[d.seq].NOKstate	 	= state_disp
 rDATA->ENC[d.seq].NOKPhone  		= p.phone_num_key
 rDATA->ENC[d.seq].NOKPhoneBiz  	= pb.phone_num_key
 rDATA->ENC[d.seq].NOKSSN  		= pa.alias
 rDATA->ENC[d.seq].NOKRel  		= cnvtstring(epr.person_reltn_cd)
 rDATA->ENC[d.seq].NOKethnic 		= cnvtstring(pr.ethnic_grp_cd)
 
WITH nocounter ;, format, separator = " "
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; NOK business and phone
 
SELECT DISTINCT INTO "NL:"
;SELECT DISTINCT INTO value ($poutdev)
 state_disp = uar_get_code_display(a.state_cd)
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
where p.person_id 		  =     rDATA->ENC[d.seq].NOKPerson_id
and p.person_org_reltn_cd =     1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
join a
join ph
 
 order by d.seq, a.address_id, pH.phone_id
 
detail
 rDATA->ENC[d.seq].NOKempname 		= trim(o.org_name,3)
 rDATA->ENC[d.seq].NOKempaddress1 	= tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].NOKempaddress2  = trim(a.street_addr2,3)
 rDATA->ENC[d.seq].NOKempstate		= state_disp
 rDATA->ENC[d.seq].NOKempcity		= trim(a.city,3)
 rDATA->ENC[d.seq].NOKEMPZIPCODE		 = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].NOKEMPphONE		= trim (ph.phone_num_key,3)
 rDATA->ENC[d.seq].NOKemp			= cnvtstring(p.empl_status_cd)
 
WITH NOCOUNTER; , format, separator = " ", check
 
 
 
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
	rDATA->ENC[d.seq].CITY = trIM(A.CITY,3)
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
 	state_disp = uar_get_code_display(a.state_cd)
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
  rDATA->ENC[d.seq].EMP_ST 		= state_disp
  rDATA->ENC[d.seq].EMP_CITY	= trim(a.city,3)
 rDATA->ENC[d.seq].emp_status	= cnvtstring(p.empl_status_cd)
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
;go to exit_script
 
 
; ------------------------------------------------------------------------
; insurance carriers
SELECT DISTINCT INTO "NL:"
;SELECT distinct INTO value ($pOutdev)
FROM
	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, encounter   enc
	, ENCNTR_PLAN_RELTN   E
	, ORGANIZATION   ORG
	, PERSON   PE
	, PERSON_ALIAS pa
	, ADDRESS   A
	, PHONE   P
	, encntr_person_reltn   EP
	, health_plan   hp
	, health_plan_alias   hpa
	, person_org_reltn   por
	, address   asub
	, address   ah
	, PHONE psub
	, PHONE psubb
 
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
  and ep.person_reltn_type_cd = outerjoin(1158) ; 1158.00 INSURED
 
 
join pe
where pe.PERSON_ID = outerjoin(EP.RELATED_PERSON_ID)
  and pe.active_ind = outerjoin(1)
  and pe.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
  and pe.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
;005
join pa
where pa.person_id = outerjoin(pe.person_id)
  and pa.person_alias_type_cd = outerjoin(SSN_CD)
  and pa.active_ind = outerjoin(1)
 
join a where a.parent_entity_id = outerjoin(e.encntr_plan_reltn_id)
       AND A.ACTIVE_IND=outerjoin(1)
      AND A.ADDRESS_TYPE_CD = outerjoin(754) ; 754.00 BUSINESS
  and a.parent_entity_name = outerjoin("ENCNTR_PLAN_RELTN")
 
join p where p.parent_entity_id = outerjoin(e.encntr_plan_reltn_id)
        AND P.ACTIVE_IND = outerjoin(1)
      AND P.PHONE_TYPE_CD = outerjoin(163) ; 163.00 BUSINESS
  and p.parent_entity_name = outerjoin("ENCNTR_PLAN_RELTN")
 
join hp
where hp.health_plan_id = outerjoin(e.health_plan_id)
 and hp.active_ind = outerjoin(1)
 and hp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
 and hp.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
join ah
where ah.parent_entity_id = outerjoin(hp.health_plan_id)
and	ah.parent_entity_name = outerjoin("HEALTH_PLAN") ;007
and 	ah.active_ind = outerjoin(1)
 
join hpa
where hpa.health_plan_id = outerjoin(hp.health_plan_id)
 and hpa.active_ind = outerjoin(1)
 and hpa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate, curtime3))
 and hpa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate, curtime3))
 
join por
where por.person_id = outerjoin(pe.person_id)
  and por.person_org_reltn_cd = outerjoin(1137) ; 1137.00 INSURANCE CO
  and por.active_ind = outerjoin(1)
  and por.priority_seq = outerjoin(1)
  and por.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
  and por.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
 
join asub
where asub.parent_entity_id = outerjoin(ep.related_person_id)
  and asub.parent_entity_name = outerjoin("PERSON")
  AND asub.ACTIVE_IND=outerjoin(1)
  AND asub.ADDRESS_TYPE_CD = outerjoin(756) ; 756.00 HOME
 
;005
join psub
where psub.parent_entity_id = outerjoin(ep.related_person_id)
  and psub.parent_entity_name = outerjoin("PERSON")
  and psub.active_ind = outerjoin(1)
  and psub.phone_type_cd = outerjoin(170) ; 170.00 HOME
 
;005
join psubb
where psubb.parent_entity_id = outerjoin(ep.related_person_id)
  and psubb.parent_entity_name = outerjoin("PERSON")
  and psubb.active_ind = outerjoin(1)
  and psubb.phone_type_cd = outerjoin(163) ; 163.00 BUSINESS
 
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
      rdata->enc[d.seq].Insurance_Address_2_A = A.STREET_ADDR2
      rdata->enc[d.seq].Insurance_City_A = A.CITY
      rdata->enc[d.seq].Insurance_State_A = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_A = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
      rdata->enc[d.seq].Insurance_Phone_A = P.PHONE_NUM_key
      rdata->enc[d.seq].Insurance_Insured_A = pe.name_full_formatted
      rDATA->ENC[d.seq].II_A_person_id = ep.related_person_id
      rdata->enc[d.seq].Insurance_Rel_to_Pt_A = CNVTSTRING( EP.PERSON_RELTN_CD )
	  rdata->enc[d.seq].Insurance_Subscriber_Address_1_A = asub.street_addr
	  rdata->enc[d.seq].Insurance_Subscriber_Address_2_A = asub.street_addr2
	  rdata->enc[d.seq].Insurance_Subscriber_City_A = asub.city
	  rdata->enc[d.seq].Insurance_Subscriber_State_A = asub.state
	  rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_A  = CONCAT (substring(1,5,format(trim(ASUB.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(ASUB.ZIPCODE_key),"#########")))
 
 		rdata->enc[d.seq].Insurance_SubscriberNameF_A = trim(pe.name_first,3)
 		rdata->enc[d.seq].Insurance_SubscriberNameL_A = trim(pe.name_last,3)
 		rdata->enc[d.seq].Insurance_SubscriberNameM_A = substring(1,1,trim(pe.name_middle,3))
 		rdata->enc[d.seq].Insurance_SubscriberDOB_A = pe.birth_dt_tm		;004
 		rdata->enc[d.seq].Insurance_SubscriberSex_A = cnvtstring(pe.sex_cd)		;005
 
      rdata->enc[d.seq].Insurance_SubscriberPhone_A = psub.PHONE_NUM_key		;005
      rdata->enc[d.seq].Insurance_SubscriberPhoneBiz_A = psubb.PHONE_NUM_key		;005
      rdata->enc[d.seq].Insurance_SubscriberSSN_A = pa.alias		;005
 
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
      rdata->enc[d.seq].Insurance_Address_2_B = A.STREET_ADDR2
      rdata->enc[d.seq].Insurance_City_B = A.CITY
      rdata->enc[d.seq].Insurance_State_B = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_B  = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
      rdata->enc[d.seq].Insurance_Phone_B = P.PHONE_NUM_key
      rdata->enc[d.seq].Insurance_Insured_B = pe.name_full_formatted
      rDATA->ENC[d.seq].II_B_person_id = ep.related_person_id
      rdata->enc[d.seq].Insurance_Rel_to_Pt_B  = CNVTSTRING( EP.PERSON_RELTN_CD )
	  rdata->enc[d.seq].Insurance_Subscriber_Address_1_B = asub.street_addr
	  rdata->enc[d.seq].Insurance_Subscriber_Address_2_B = asub.street_addr2
	  rdata->enc[d.seq].Insurance_Subscriber_City_B = asub.city
	  rdata->enc[d.seq].Insurance_Subscriber_State_B = asub.state
	  rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_B = CONCAT (substring(1,5,format(trim(ASUB.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(ASUB.ZIPCODE_key),"#########")))
 
  		rdata->enc[d.seq].Insurance_SubscriberNameF_B = trim(pe.name_first,3)
 		rdata->enc[d.seq].Insurance_SubscriberNameL_B = trim(pe.name_last,3)
		rdata->enc[d.seq].Insurance_SubscriberNameM_B = substring(1,1,trim(pe.name_middle,3))
		rdata->enc[d.seq].Insurance_SubscriberDOB_B = pe.birth_dt_tm		;004
 		rdata->enc[d.seq].Insurance_SubscriberSex_B = cnvtstring(pe.sex_cd)		;005
 
      rdata->enc[d.seq].Insurance_SubscriberPhone_B = psub.PHONE_NUM_key		;005
      rdata->enc[d.seq].Insurance_SubscriberPhoneBiz_B = psubb.PHONE_NUM_key		;005
      rdata->enc[d.seq].Insurance_SubscriberSSN_B = pa.alias		;005
 
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
      rdata->enc[d.seq].Insurance_Address_2_C = A.STREET_ADDR2
      rdata->enc[d.seq].Insurance_City_C = A.CITY
      rdata->enc[d.seq].Insurance_State_C = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_C = CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
      rdata->enc[d.seq].Insurance_Phone_C = P.PHONE_NUM_key
      rdata->enc[d.seq].Insurance_Insured_C = pe.name_full_formatted
      rdata->enc[d.seq].Insurance_Rel_to_Pt_C = CNVTSTRING( EP.PERSON_RELTN_CD )
      rDATA->ENC[d.seq].II_C_person_id = ep.related_person_id
 	  rdata->enc[d.seq].Insurance_Subscriber_Address_1_C = asub.street_addr
	  rdata->enc[d.seq].Insurance_Subscriber_Address_2_C = asub.street_addr2
	  rdata->enc[d.seq].Insurance_Subscriber_City_C = asub.city
	  rdata->enc[d.seq].Insurance_Subscriber_State_C = asub.state
	  rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_C = CONCAT (substring(1,5,format(trim(ASUB.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(ASUB.ZIPCODE_key),"#########")))
 
   	  rdata->enc[d.seq].Insurance_SubscriberNameF_C = trim(pe.name_first,3)
 	  rdata->enc[d.seq].Insurance_SubscriberNameL_C = trim(pe.name_last,3)
 	  rdata->enc[d.seq].Insurance_SubscriberNameM_C = substring(1,1,trim(pe.name_middle,3))
 	  rdata->enc[d.seq].Insurance_SubscriberDOB_C = pe.birth_dt_tm		;004
 	  rdata->enc[d.seq].Insurance_SubscriberSex_C = cnvtstring(pe.sex_cd)		;005
 
      rdata->enc[d.seq].Insurance_SubscriberPhone_C = psub.PHONE_NUM_key		;005
      rdata->enc[d.seq].Insurance_SubscriberPhoneBiz_C = psubb.PHONE_NUM_key		;005
      rdata->enc[d.seq].Insurance_SubscriberSSN_C = pa.alias		;005
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
; get contract info ;017
SELECT INTO "NL:"
FROM
	(dummyt d  with seq = value (size(rDATA->ENC,5)))
	, ENCOUNTER enc
	, ENCNTR_INFO ei	
	, ORGANIZATION_ALIAS oa	
	, ORGANIZATION org	
	, ADDRESS a
	, PHONE ph		
	, PERSON p
 
plan d
join enc
where enc.encntr_id = rdata->enc[d.seq].ENCNTR_ID

join ei
where ei.encntr_id = enc.encntr_id
  and ei.info_sub_type_cd = contract_cd
  and ei.active_ind= 1
  and ei.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and ei.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
 
join oa
where oa.alias = cnvtstring(ei.value_numeric)
  and oa.org_alias_type_cd = org_alias_cd
  and oa.active_ind = 1
  and oa.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and oa.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
 
join org
where org.organization_id = oa.organization_id
  and org.active_ind = 1
  and org.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
  and org.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
 
join a where a.parent_entity_id = outerjoin(org.organization_id)
  and a.active_ind = outerjoin(1)
  and a.address_type_cd = outerjoin(address_business_cd)
  and a.parent_entity_name = outerjoin("ORGANIZATION")
 
join ph where ph.parent_entity_id = outerjoin(org.organization_id)
  and ph.active_ind = outerjoin(1)
  and ph.phone_type_cd = outerjoin(phone_business_cd)
  and ph.parent_entity_name = outerjoin("ORGANIZATION")
  
join p where p.person_id = enc.person_id
  and p.active_ind = 1
 
ORDER BY
	d.seq
	
head d.seq
      rdata->enc[d.seq].encntr_plan_reltn_id_A = 0.0
      rdata->enc[d.seq].Insurance_Plan_Code_A = oa.alias
      rdata->enc[d.seq].Insurance_Plan_Name_A = org.org_name
      rdata->enc[d.seq].Insurance_Policy_No_A = ""
      rdata->enc[d.seq].Insurance_Group_No_A = ""
      rdata->enc[d.seq].Insurance_Address_1_A = a.street_addr
      rdata->enc[d.seq].Insurance_Address_2_A = a.street_addr2
      rdata->enc[d.seq].Insurance_City_A = a.city
      rdata->enc[d.seq].Insurance_State_A = a.state
      rdata->enc[d.seq].Insurance_Zip_Code_A = concat(substring(1,5,format(trim(a.zipcode_key),"#########")),
													  substring(6,4,format(trim(a.zipcode_key),"#########")))
      rdata->enc[d.seq].Insurance_Phone_A = ph.phone_num_key
      rdata->enc[d.seq].Insurance_Insured_A = p.name_full_formatted
      rDATA->ENC[d.seq].II_A_person_id = 0.0
      rdata->enc[d.seq].Insurance_Rel_to_Pt_A = ""
	  rdata->enc[d.seq].Insurance_Subscriber_Address_1_A = ""
	  rdata->enc[d.seq].Insurance_Subscriber_Address_2_A = ""
	  rdata->enc[d.seq].Insurance_Subscriber_City_A = ""
	  rdata->enc[d.seq].Insurance_Subscriber_State_A = ""
	  rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_A = ""	   
	  rdata->enc[d.seq].Insurance_SubscriberNameF_A = ""
	  rdata->enc[d.seq].Insurance_SubscriberNameL_A = ""
	  rdata->enc[d.seq].Insurance_SubscriberNameM_A = ""
	  rdata->enc[d.seq].Insurance_SubscriberDOB_A = 0
	  rdata->enc[d.seq].Insurance_SubscriberSex_A = "" 
      rdata->enc[d.seq].Insurance_SubscriberPhone_A = ""
      rdata->enc[d.seq].Insurance_SubscriberPhoneBiz_A = ""
      rdata->enc[d.seq].Insurance_SubscriberSSN_A = ""
 
WITH nocounter
	
 
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
 
 
; ------------------------------------------------------------------------
; carrier emloyer A
SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
FROM
	  person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
	, phone ph
 
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
 
join ph
where ph.parent_entity_id = outerjoin(o.organization_id)
and ph.parent_entity_name =  outerjoin("ORGANIZATION")
and ph.active_ind =  outerjoin(1)
and ph.phone_type_cd = outerjoin(163) ; 163.00 BUSINESS
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].Insurance_SubscriberEmpName_A = trim(o.org_name,3)
 rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_A = tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_A	= CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_A = ph.phone_num_key
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
; ------------------------------------------------------------------------
; carrier emloyer B
SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
FROM
	  person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
	, phone ph
 
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
 
join ph
where ph.parent_entity_id = outerjoin(o.organization_id)
and ph.parent_entity_name =  outerjoin("ORGANIZATION")
and ph.active_ind =  outerjoin(1)
and ph.phone_type_cd = outerjoin(163) ; 163.00 BUSINESS
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].Insurance_SubscriberEmpName_B = trim(o.org_name,3)
 rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_B = tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_B	= CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_B = ph.phone_num_key
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
; ------------------------------------------------------------------------
; carrier emloyer C
SELECT   INTO "NL:"
;SELECT  INTO value ($poutdev)
FROM
	  person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
	, address a
	, phone ph
 
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
 
join ph
where ph.parent_entity_id = outerjoin(o.organization_id)
and ph.parent_entity_name =  outerjoin("ORGANIZATION")
and ph.active_ind =  outerjoin(1)
and ph.phone_type_cd = outerjoin(163) ; 163.00 BUSINESS
 
ORDER BY D.SEQ
 
detail
 rDATA->ENC[d.seq].Insurance_SubscriberEmpName_C = trim(o.org_name,3)
 rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_C = tRIM(A.street_addr,3)
 rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_C	= CONCAT (substring(1,5,format(trim(A.ZIPCODE_key),"#########")),
	 										SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########")))
 rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_C = ph.phone_num_key
 
WITH NOCOUNTER
; , format, separator = " ", check
 
 
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
 	set rDATA->ENC[I].ethnicity 		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].ethnicity)),3)
	set rDATA->ENC[I].acc_type			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].acc_type)),3)
	set rDATA->ENC[I].emp_status		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].emp_status)),3)
	SET rDATA->ENC[I].guarSex			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].guarSEX)),3)
	set rDATA->ENC[I].guarmarital		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].guarmarital)),3)
 	set rDATA->ENC[I].guaremp			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].guaremp)),3)
 	SET rDATA->ENC[I].guarRel			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].guarRel)),3)
	set rDATA->ENC[I].guarethnic   		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].guarethnic)),3)
	SET rDATA->ENC[I].NOKSex			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].NOKSEX)),3)
	set rDATA->ENC[I].NOKmarital		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].NOKmarital)),3)
 	set rDATA->ENC[I].NOKemp			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].NOKemp)),3)
 	SET rDATA->ENC[I].NOKRel			=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].NOKRel)),3)
	set rDATA->ENC[I].NOKethnic   		=  trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].NOKethnic)),3)
 
	SET rDATA->ENC[I].Insurance_SubscriberSex_A	= trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_SubscriberSex_A)),3)
	SET rDATA->ENC[I].Insurance_SubscriberSex_B	= trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_SubscriberSex_B)),3)
	SET rDATA->ENC[I].Insurance_SubscriberSex_C	= trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_SubscriberSex_C)),3)
 
/*  dont think we need these for AUR like we did Vista
 
 	;  RELATIONSHIP
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
 
 	;
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
 */
 endfor ;end call to the aliasing subroutine
 
 
; CALL ECHORECORD(rData)
 
;demographic output
;SELECT distinct INTO VALUE ($POUTDEV)
SELECT distinct INTO VALUE (output->temp_demo)
 
001_FAC  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].FACILITY,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].FACILITY,3)) else " " endif)
,002_IOE  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].pat_type_ioe,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].pat_type_ioe,3))else " " endif)
,003_PATTYPE  = evaluate2 (if (trim(rDATA->ENC[d.seq].pat_type,3)		> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].pat_type,3)) else " " endif)
,004_ADMDT  	 = evaluate2 (if (FORMAT(rData->ENC[d.seq].admit_dt_tm, "YYYYMMDD;;D") > char(32)) ;001
	FORMAT(rData->ENC[d.seq].admit_dt_tm,  "YYYYMMDD;;D") else " " endif) ;001
,005_DSCHDT 	 = evaluate2 (if (FORMAT(rData->ENC[d.seq].disch_dt_tm, "YYYYMMDD;;D") > char(32)) ;001
	FORMAT(rData->ENC[d.seq].disch_dt_tm,  "YYYYMMDD;;D") else " " endif) ;001
,006_ACDTDT   = evaluate2 (if (FORMAT(rData->ENC[d.seq].acc_dt_tm,   "YYYYMMDD;;D") > char(32)) ;001
	FORMAT(rData->ENC[d.seq].acc_dt_tm,  "YYYYMMDD;;D") else " " endif) ;001
,007_PFN  	 = evaluate2 (if (substring(1,12,trim(rDATA->ENC[d.seq].first_name,3)) > char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].first_name,3)) else " " endif)
,008_PLN  	 = evaluate2 (if (substring(1,33,trim(rDATA->ENC[d.seq].last_name,3)) > char(32))
	substring(1,25,trim(rDATA->ENC[d.seq].last_name,3)) else " " endif)
,009_PMN  	 = evaluate2 (if (substring(1,1,trim(rDATA->ENC[d.seq].M_name,3)) > char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].M_name,3)) else " " endif)
,010_PBD  	 = evaluate2 (if (FORMAT(rData->ENC[d.seq].birth_dt_tm,  "YYYYMMDD;;D") > char(32)) ;001
	FORMAT(rData->ENC[d.seq].birth_dt_tm,  "YYYYMMDD;;D") else " " endif) ;001
,011_PED  	 = evaluate2 (if (FORMAT(rData->ENC[d.seq].deceased_dt_tm,  "YYYYMMDD;;D")> char(32)) ;001
	FORMAT(rData->ENC[d.seq].deceased_dt_tm,  "YYYYMMDD;;D") else " " endif) ;001
,012_PSEX  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].SEX_alias,3)	> char(32))
	substring(1,1,trim(rDATA->ENC[d.seq].SEX_alias,3)) else " " endif)
,013_PAD1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].ADDRESS,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].ADDRESS,3)) else " " endif)
,014_PAD2  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].ADDRESS2,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].ADDRESS2,3)) else " " endif)
,015_PCTY1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].CITY,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].CITY,3)) else " " endif)
,016_PST1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].STATE,3)		> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].STATE,3)) else " " endif)
,017_PZIP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].ZIPCODE,3)		> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].ZIPCODE,3)) else " " endif)
,018_PHP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].PHONE_HOME,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].PHONE_HOME,3)) else " " endif)
,019_PWP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].PHONE_BIZ ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].PHONE_BIZ,3)) else " " endif)
,020_PSSN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].ssn,3)		> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].ssn,3)) else " " endif)
,021_PEN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].emp_name,3)	> char(32))
	substring(1,33,trim(rDATA->ENC[d.seq].emp_name,3)) else " " endif)
,022_PEAD1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].EMP_ADDR1,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].EMP_ADDR1,3)) else " " endif)
,023_PEAD2  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].EMP_ADDR2,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].EMP_ADDR2,3)) else " " endif)
,024_PCTY1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].EMP_CITY,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].EMP_CITY,3)) else " " endif)
,025_PST1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].EMP_ST,3)	> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].EMP_ST,3)) else " " endif)
,026_PEZIP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].EMP_ZIP ,3)		> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].EMP_ZIP,3)) else " " endif)
,027_PEPH  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].PHONE_BIZ ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].PHONE_BIZ,3)) else " " endif)
,028_PMRN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].mrn ,3)		> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].mrn,3)) else " " endif)
,029_PPAT  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].fin ,3)		> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].fin,3)) else " " endif)
,030_PMS  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].MARITAL_ALIAS ,3)	> char(32))
	substring(1, 1,trim(rDATA->ENC[d.seq].MARITAL_ALIAS,3)) else " " endif)
,031_PEMS  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].emp_status ,3)	> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].emp_status,3)) else " " endif)
,032_PREC  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].ethnicity ,3)	> char(32))
	substring(1, 1,trim(rDATA->ENC[d.seq].ethnicity,3)) else " " endif)
 
,033_GFN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarFirstName ,3)	> char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].guarFirstName ,3)) else " " endif)
,034_GLN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarLastName  ,3)		> char(32))
	substring(1,25,trim(rDATA->ENC[d.seq].guarLastName ,3)) else " " endif)
,035_GMN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarMiddleName  ,3)	> char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].guarMiddleName ,3)) else " " endif)
,036_GBD  	 = FORMAT (rDATA->ENC[d.seq].guarDateOfBirth,  "YYYYMMDD;;D") ;001
,037_GSEX  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarsex,3)		> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].guarsex,3)) else " " endif)
,038_GAD1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarAddress1,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guarAddress1,3)) else " " endif)
,039_GAD2  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarAddress2,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guarAddress2,3)) else " " endif)
,040_GCTY1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].CITY,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].CITY,3)) else " " endif)
,041_GST1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].STATE ,3)		> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].state,3)) else " " endif)
,042_GZIP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarZipcode ,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].guarZipcode,3)) else " " endif)
,043_GHP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarPhone ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].guarPhone,3)) else " " endif)
,044_GWP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarPhonebiz ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].guarPhonebiz,3)) else " " endif)
,045_GSSN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarSSN ,3)		> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].guarSSN,3)) else " " endif)
,046_GEN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempName ,3)	> char(32))
	substring(1,33,trim(rDATA->ENC[d.seq].guarempName,3)) else " " endif)
,047_GEAD1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempAddress1 ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guarempAddress1,3)) else " " endif)
,048_GEAD2  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempAddress2 ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guarempAddress2,3)) else " " endif)
,049_GECTY1   = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempcity ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guarempcity,3)) else " " endif)
,050_GEST1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempstate ,3)	> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].guarempstate,3)) else " " endif)
,051_GEZIP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempZipcode ,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].guarempZipcode,3)) else " " endif)
,052_GEPH  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarempPhone,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].guarempPhone,3)) else " " endif)
,053_GSC  	 = "|"
,054_GMS  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarmarital ,3) 	> char(32))
	substring(1,1,trim(rDATA->ENC[d.seq].guarmarital,3)) else " " endif)
,055_GEMS  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guaremp ,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guaremp,3)) else " " endif)
,056_GREC  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarEthnic,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].guarEthnic,3)) else " " endif)
,057_GPRC  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].guarRel ,3)		> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].guarRel,3)) else " " endif)
 
,058_RFN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKFirstName ,3)		> char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].NOKFirstName ,3)) else " " endif)
,059_RLN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKLastName  ,3)		> char(32))
	substring(1,25,trim(rDATA->ENC[d.seq].NOKLastName ,3)) else " " endif)
,060_RMN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKMiddleName  ,3)	> char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].NOKMiddleName ,3)) else " " endif)
,061_RBD  	 = FORMAT (rDATA->ENC[d.seq].NOKDateOfBirth,  "YYYYMMDD;;D") ;001
,062_RSEX  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKsex,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].NOKsex,3)) else " " endif)
,063_RAD1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKAddress1,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKAddress1,3)) else " " endif)
,064_RAD2  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKAddress2,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKAddress2,3)) else " " endif)
,065_GCTY1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKCity,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKCity,3)) else " " endif)
,066_GST1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKState ,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].NOKState,3)) else " " endif)
,067_RZIP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKZipcode ,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].NOKZipcode,3)) else " " endif)
,068_RHP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKPhone ,3)		> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].NOKPhone,3)) else " " endif)
,069_RWP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKPhonebiz ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].NOKPhonebiz,3)) else " " endif)
,070_RSSN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKSSN ,3)		> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].NOKSSN,3)) else " " endif)
,071_REN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempName ,3)	> char(32))
	substring(1,33,trim(rDATA->ENC[d.seq].NOKempName,3)) else " " endif)
,072_READ1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempAddress1 ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKempAddress1,3)) else " " endif)
,073_READ2  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempAddress2 ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKempAddress2,3)) else " " endif)
;005
,074_GCTY1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempCity ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKempCity,3)) else " " endif)
,075_GST1  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempState,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].NOKempState,3)) else " " endif)
,076_REZIP  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempZipcode ,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].NOKempZipcode,3)) else " " endif)
,077_REPH  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKempPhone ,3) 	> char(32))
	substring(1,1,trim(rDATA->ENC[d.seq].NOKempPhone,3)) else " " endif)
,078_RMS  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKmarital ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKmarital,3)) else " " endif)
,079_REMS  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKemp,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].NOKemp,3)) else " " endif)
,080_RREC  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKethnic ,3)		> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].NOKethnic,3)) else " " endif)
,081_RPRC  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].NOKRel ,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].NOKRel,3)) else " " endif)
 
,082_PHNBR  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].REFERRING_ID ,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].REFERRING_ID,3)) else " " endif)
,083_PHNAME   = evaluate2 (if (trim(rDATA->ENC[d.seq].REFERRING_NAME ,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].REFERRING_NAME,3)) else " " endif)
,084_UPIN  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].referring_upin ,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].referring_upin,3)) else " " endif)
 
,085_OCC1  	 = "|"
,086_OCC2  	 = "|"
 
,087_INS1CCD  	 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Plan_Code_A,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Plan_Code_A,3)) else " " endif)
,088_INS1CND  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Plan_Name_A,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Plan_Name_A,3)) else " " endif)
,089_INS1PN  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Policy_No_A,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Policy_No_A,3)) else " " endif)
,090_INS1GN   = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Group_No_A,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Group_No_A,3)) else " " endif)
,091_INS1AUTH   = evaluate2 (if (trim(rDATA->ENC[d.seq].Authorization_Number_A,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].Authorization_Number_A,3)) else " " endif)
,092_INS1AD1   = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Address_1_A,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Address_1_A,3)) else " " endif)
,093_INS1AD2  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Address_2_A,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Address_2_A,3)) else " " endif)
,094_INS1CITY  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_City_A,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_City_A,3)) else " " endif)
,095_INS1STATE = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_State_A ,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_State_A,3)) else " " endif)
,096_INS1ZIP	 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Zip_Code_A ,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_Zip_Code_A,3)) else " " endif)
,097_INS1CPH	 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_phone_A ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_phone_A,3)) else " " endif)
,098_INS1PAN	 = "|"
,099_INS1OFN	 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameF_A,3) > char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameF_A,3)) else " " endif)
,100_INS1OLN	 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameL_A,3) > char(32))
	substring(1,25,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameL_A,3)) else " " endif)
,101_INS1OMN	 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameM_A,3) > char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameM_A,3)) else " " endif)
,102_INS1OBD	 = evaluate2 (if (FORMAT(rData->ENC[d.seq].Insurance_SubscriberDOB_A,  "YYYYMMDD;;D") > char(32)) ;001	;004
	FORMAT(rData->ENC[d.seq].Insurance_SubscriberDOB_A,  "YYYYMMDD;;D") else " " endif) ;001			;004
,103_INS1OSEX = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberSex_A,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberSex_A,3)) else " " endif)
,104_INS1OA1 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_A,3) > char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_A,3)) else " " endif)
,105_INS1OA2  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_2_A,3) > char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_2_A,3)) else " " endif)
,106_INS1OCITY  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_City_A,3)	 > char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_City_A,3)) else " " endif)
,107_INS1OSTATE  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_State_A,3) 	 > char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_Subscriber_State_A,3)) else " " endif)
,108_INS1OPZIP  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_A,3)	 > char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_A,3)) else " " endif)
,109_INS1OPH  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberPhone_A ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberPhone_A,3)) else " " endif)
,110_INS1OWPH = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberPhoneBiz_A ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberPhoneBiz_A,3)) else " " endif)
,111_INS1OSSN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberSSN_A ,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberSSN_A,3)) else " " endif)
,112_INS1OEN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpName_A,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpName_A,3)) else " " endif)
,113_INS1OEA1  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_A,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_A,3)) else " " endif)
,114_INS1OEA2 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd2_A,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd2_A,3)) else " " endif)
,115_INS1OECITY = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpCity_A,3)	> char(32))
	substring(1, 30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpCity_A,3)) else " " endif)
,116_INS1OESTATE  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpState_A,3)	> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpState_A,3)) else " " endif)
,117_INS1OEZIP = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_A,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_A,3)) else " " endif)
,118_INS1OEPH = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_A ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_A,3)) else " " endif)
,119_INS1OMS  = "|" ; marital status
,120_INS1OEMS = "|" ; employment status
,121_INS1OREC = "|" ; ethnicity
,122_INS1ORLC = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_A,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_A ,3)) else " " endif)
 
,123_INS2CCD = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Plan_Code_B,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Plan_Code_B,3)) else " " endif)
,124_INS2CND = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Plan_Name_B,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Plan_Name_B,3)) else " " endif)
,125_INS2PN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Policy_No_B,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Policy_No_B,3)) else " " endif)
,126_INS2GN  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Group_No_B,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Group_No_B,3)) else " " endif)
,127_INS2AUTH   = evaluate2 (if (trim(rDATA->ENC[d.seq].Authorization_Number_B,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].Authorization_Number_B,3)) else " " endif)
,128_INS2AD1  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Address_1_B,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Address_1_B,3)) else " " endif)
,129_INS2AD2 = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Address_2_B,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Address_2_B,3)) else " " endif)
,130_INS2CITY = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_City_B,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_City_B,3)) else " " endif)
,131_INS2STATE	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_State_B ,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_State_B,3)) else " " endif)
,132_INS2ZIP	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Zip_Code_B ,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].Insurance_Zip_Code_B,3)) else " " endif)
,133_INS2CPH  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_phone_B ,3)	> char(32))
	substring(1, 10,trim(rDATA->ENC[d.seq].Insurance_phone_B,3)) else " " endif)
,134_INS2PAN = "|"
,135_INS2OFN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameF_B,3)	> char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameF_B,3)) else " " endif)
,136_INS2OLN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameL_B,3)	> char(32))
	substring(1,25,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameL_B,3)) else " " endif)
,137_INS2OMN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameM_B,3)	> char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameM_B,3)) else " " endif)
,138_INS2OBD = evaluate2 (if (FORMAT(rData->ENC[d.seq].Insurance_SubscriberDOB_B, "YYYYMMDD;;D") > char(32)) ;001	;004
	FORMAT(rData->ENC[d.seq].Insurance_SubscriberDOB_B, "YYYYMMDD;;D") else " " endif) ;001			;004
,139_INS2OSEX  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberSex_B,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberSex_B,3)) else " " endif)
,140_INS2OADDR1	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_B,3) > char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_B,3)) else " " endif)
,141_INS2OADDR2  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_2_B,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_2_B,3)) else " " endif)
,142_INS2OCITY  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_City_B,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_City_B,3)) else " " endif)
,143_INS2OSTATE  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_State_B ,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_Subscriber_State_B,3)) else " " endif)
,144_INS2OPZIP  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_B,3) 	> char(32))
	substring(1 ,9,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_B,3)) else " " endif)
,145_INS1OPH  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberPhone_B ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberPhone_B,3)) else " " endif)
,146_INS1OWPH = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberPhoneBiz_B ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberPhoneBiz_B,3)) else " " endif)
,147_INS1OSSN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberSSN_B ,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberSSN_B,3)) else " " endif)
,148_INS2OEN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpName_B ,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpName_B,3)) else " " endif)
,149_INS2OEA1  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_B ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_B,3)) else " " endif)
,150_INS2OEA2  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd2_B ,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd2_B,3)) else " " endif)
,151_INS2OECITY  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpCity_B,3)	> char(32))
	substring(1, 30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpCity_B,3)) else " " endif)
,152_INS2OESTATE  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpState_B,3)	> char(32))
	substring(1, 2,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpState_B,3)) else " " endif)
,153_INS2OEZIP 	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_B ,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_B,3)) else " " endif)
,154_INS2OEPH = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_B ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_B,3)) else " " endif)
,155_INS2OMS  	= "|" ; marital status
,156_INS2OEMS  	= "|" ; employment status
,157_INS2OREC  	= "|" ; ethnicity
,158_INS2ORLC  	= evaluate2 (if ( trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_B ,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_B ,3)) else " " endif)
 
,159_INS3CCD  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Plan_Code_C,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Plan_Code_C,3)) else " " endif)
,160_INS3CND  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Plan_Name_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Plan_Name_C,3)) else " " endif)
,161_INS3PN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Policy_No_C,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Policy_No_C,3)) else " " endif)
,162_INS3GN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Group_No_C,3)	> char(32))
	substring(1,20,trim(rDATA->ENC[d.seq].Insurance_Group_No_C,3)) else " " endif)
,163_INS3AUTH   = evaluate2 (if (trim(rDATA->ENC[d.seq].Authorization_Number_C,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].Authorization_Number_C,3)) else " " endif)
,164_INS3AD1  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Address_1_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Address_1_C,3)) else " " endif)
,165_INS3AD2  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Address_2_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Address_2_C,3)) else " " endif)
,166_INS3CITY  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_City_C,3)		> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_City_C,3)) else " " endif)
,167_INS3STATE  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_State_C,3)		> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_State_C,3)) else " " endif)
,168_INS3ZIP  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Zip_Code_C,3)	> char(32))
	substring(1, 9,trim(rDATA->ENC[d.seq].Insurance_Zip_Code_C,3)) else " " endif)
,169_INS3CPH  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_phone_C,3)	> char(32))
	substring(1, 10,trim(rDATA->ENC[d.seq].Insurance_phone_C,3)) else " " endif)
,170_INS3PAN  	= "|"
,171_INS3OFN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameF_C,3) > char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameF_C,3)) else " " endif)
,172_INS3OLN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameL_C,3) > char(32))
	substring(1,25,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameL_C,3)) else " " endif)
,173_INS3OMN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberNameM_C,3) > char(32))
	substring(1,18,trim(rDATA->ENC[d.seq].Insurance_SubscriberNameM_C,3)) else " " endif)
,174_INS3OBD  	= evaluate2 (if (FORMAT(rData->ENC[d.seq].Insurance_SubscriberDOB_C,  "YYYYMMDD;;D") > char(32)) ;001	;004
	FORMAT(rData->ENC[d.seq].Insurance_SubscriberDOB_C,  "YYYYMMDD;;D") else " " endif) ;001			;004
,175_INS3OSEX  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberSex_C,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberSex_C,3)) else " " endif)
,176_INS3OADDR1  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_C,3) > char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_1_C,3)) else " " endif)
,177_INS3OADDR2  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_2_C,3) > char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Address_2_C,3)) else " " endif)
,178_INS3OCITY  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_City_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_Subscriber_City_C,3)) else " " endif)
,179_INS3OSTATE  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_State_C ,3)	> char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_Subscriber_State_C,3)) else " " endif)
,180_INS3OPZIP  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_C,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_Subscriber_Zip_Code_C,3)) else " " endif)
,181_INS1OPH  = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberPhone_C ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberPhone_C,3)) else " " endif)
,182_INS1OWPH = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberPhoneBiz_C ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberPhoneBiz_C,3)) else " " endif)
,183_INS1OSSN = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberSSN_C ,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberSSN_C,3)) else " " endif)
,184_INS3OEN  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpName_C,3)	> char(32))
	substring(1,50,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpName_C,3)) else " " endif)
,185_INS3OEA1  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd1_C,3)) else " " endif)
,186_INS3OEA2  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd2_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpAdd2_C,3)) else " " endif)
,187_INS3OECITY  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpCity_C,3)	> char(32))
	substring(1,30,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpCity_C,3)) else " " endif)
,188_INS3OESTATE  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpState_C,3) > char(32))
	substring(1,2,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpState_C,3)) else " " endif)
,189_INS3OEZIP  	= evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_C,3)	> char(32))
	substring(1,9,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpZip_C,3)) else " " endif)
,190_INS3OEPH = evaluate2 (if (trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_C ,3)	> char(32))
	substring(1,10,trim(rDATA->ENC[d.seq].Insurance_SubscriberEmpPhone_C,3)) else " " endif)
,191_INS3OMS  	= "|" ; marital status
,192_INS3OEMS  	= "|" ; employment status
,193_INS3OREC  	= "|" ; ethnicity
,194_INS3ORLC  	= evaluate2 (if ( trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_C ,3)
	> char(32))substring(1,2,trim(rDATA->ENC[d.seq].Insurance_Rel_to_Pt_C ,3)) else " " endif)
;
 
 
FROM
(dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
 order by
   rDATA->ENC[d.seq].FACILITYCD
  ,028_PMRN
  ,029_PPAT
 
 
 WITH PCFORMAT ("", value(char(9)) ,0,1)  ,FORMAT = CRSTREAM, memsort
;; for testing only once this is validated then the calls to astream file location will be via operations
; with format, separator = " ", check
  set statx = 0
;
 ; demo file
 
set  output->temp  = concat("cp $cer_temp/", output->filename," ",output->astream, output->filename)
call echo (output->temp);
call dcl( output->temp ,size(output->temp  ), statx)
set output->temp = ""
;
;
 
#exit_script
 FREE RECORD rdata
end go

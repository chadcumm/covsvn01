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
* Feature	Mod Date		Engineer	Comment                                                                        *
* -------	--- ----------	----------	-------------------------------------------------------------------------------*
			000 05/14/2018	ARG			Initial release (Alix Govatsos)
			001 10/08/2018	TAB			Added physicians:
											DO, DANIEL VU MD
											BLANKNER, JOANNA GABRIEL MD
			002 11/20/2018	TAB			Added physician: JORDAN, BENJAMIN E MD
			003 01/04/2019	TAB			Added physician: ALDERMAN, DANIEL FRANCIS MD
 
************************* END OF ALL MODCONTROL BLOCKS *****************************************************************/
 
 
DROP PROGRAM 	COV_MBM_RAD_EXT:dba GO
CREATE PROGRAM 	COV_MBM_RAD_EXT:dba
 
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
set output->filename  = concat(format(curdate, "yyyymmdd;;d"), '_cer',  '.mbm')
set output->filenamed = concat('mbmcode',format(curdate, "yyyymmdd;;d"), '_cer', '.del')
set output->astream = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Radiology/Extracts/MBM/"
set output->temp_demo = concat('cer_temp:' ,  format(curdate, "yyyymmdd;;d"),'_cer', '.mbm')
set output->temp_dict = concat('cer_temp:' , 'mbmcode',  format(curdate, "yyyymmdd;;d"),'_cer', '.del')
 
call echorecord (output)
 
 
 
RECORD rDATA(
1 ENC[*]						;one occurrence per exam per encouonter per patient
2	ENCNTR_ID	= 	f8
2	PERSON_ID	= 	f8
2	FIRST_NAME	= 	vc
2	LAST_NAME	= 	vc
2	M_name 		= 	vc
2	NAME		= 	c25	 ;	3
2	ADDRESS		= 	c22	 ;	28
2	ADDRESS2	= 	c15	 ;	50
2	CITY	 	= 	c15	 ;	65
2	STATE	 	= 	c2	 ;	80
2	ZIPCODE	 	= 	c10	 ;	82
2	PHONE_HOME	= 	c10	 ;	92
2	PHONE_BIZ	= 	c10	 ;	102
2	BIRTH_DT_TM	= 	dq8
2	DOB	 		= 	c6	 ;	112
2	dob_year	= c4	;	format(p.birth_dt_tm ,"yyyy;;d")
2	dob_month	= c2  	;	format(p.birth_dt_tm ,"mm;;d")
2	dob_day		= c2	;	format(p.birth_dt_tm ,"dd;;d")
2	SEX	 		= 	VC
2	SEX_ALIAS	= 	c1	 ;	118
2	FIN	 = 	vc	 ;	119
2	REFERRING_ID	 = 	VC
2	REFERRING_NAME	 = 	c12	 ;	130
2	EMP_NAME	 = 	c28	 ;	142
2	SSN	 		= 	c11	 ;	170
2	FAMILY_NAME	= 	c18	 ;	181
;	hsite_code	= 	c2	 ;	199
2	haglines1	= 	c134	 ;	201
2	MARITAL	 = 	VC
2	MARITAL_ALIAS	 = 	c1	 ;	335
;	hspecial_cd	 = 	c3	 ;	336
2	admit_dt_tm	 = 	dq8
2	admit_date	 = 	c6	 ;	339
2	disch_dt_tm	 = 	dq8
2	disch_date	 = 	c6	 ;	345
2	pat_type_ioe = 	c1	 ;	351
;	Accident Date	 = 	c6	 ;	352
2	MRN	 		= 	vc ;	358
;	haglines2	= 	c25	 ;	375
2   encntr_plan_reltn_id_A = f8
2   encntr_plan_reltn_id_B = f8
2   encntr_plan_reltn_id_C = f8
2	Insurance_Plan_Name_A 	= 	vc	 ;	401
2	Insurance_Address_1_A 	= 	c20	 ;	421
2	Insurance_City_A 	 	= 	c15	 ;	441
2	Insurance_State_A 	 	= 	c2	 ;	456
2	Insurance_Zip_Code_A 	= 	c10	 ;	458
2	Insurance_Insured_A 	= 	c20	 ;	468
2	Insurance_Subscriber_Address_1_A = c20	 ;	488
2	Insurance_Subscriber_City_A	 	 = c15	 ;	508
2	Insurance_Subscriber_State_A	 = c2	 ;	523
2	Insurance_Subscriber_Zip_Code_A	 = c10	 ;	525
2	Insurance_Policy_No_A 	= 	c14	 ;	535
2	Insurance_Group_No_A 	= 	c14	 ;	549
;	pinsdiag_code	 		= 	c8	 ;	563
2	Insurance_Rel_to_Pt_A 	= 	VC	 ;	571
;	pacptasn	 			= 	c1	 ;	573
2	Insurance_Plan_Code_A 	= 	vc	 ;	574
;	paglines3	 			= 	c20	 ;	580
2	Insurance_Plan_Name_B	= 	c20	 ;	601
2	Insurance_Address_1_B	= 	c20	 ;	621
2	Insurance_City_B	 	= 	c15	 ;	641
2	Insurance_State_B	 	= 	c2	 ;	656
2	Insurance_Zip_Code_B	= 	c10	 ;	658
2	Insurance_Insured_B	 	= 	c20	 ;	668
2	Insurance_Subscriber_Address_1_B 	= 	c20	 ;	688
2	Insurance_Subscriber_City_B 	 	= 	c15	 ;	708
2	Insurance_Subscriber_State_B 	 	= 	c2	 ;	723
2	Insurance_Subscriber_Zip_Code_B 	= 	c10	 ;	725
2	Insurance_Policy_No_B	= 	c14	 ;	735
2	Insurance_Group_No_B	= 	c14	 ;	749
;	sinsdiag_code	 		= 	c8	 ;	763
2	Insurance_Rel_to_Pt_B 	= 	VC	 ;	771
;	sacptasn	 			= 	c1	 ;	773
2	Insurance_Plan_Code_B	= 	c6	 ;	774
;	saglines4	 			= 	c20	 ;	780
2	Insurance_Plan_Name_C	= 	c20	 ;	801
2	Insurance_Address_1_C	= 	c20	 ;	821
2	Insurance_City_C	 	= 	c15	 ;	841
2	Insurance_State_C	 	= 	c2	 ;	856
2	Insurance_Zip_Code_C	= 	c10	 ;	858
2	Insurance_Insured_C	 	= 	c20	 ;	868
2	Insurance_Subscriber_Address_1_C	= c20	 ;	888
2	Insurance_Subscriber_City_C	 		= c15	 ;	908
2	Insurance_Subscriber_State_C	 	= c2	 ;	923
2	Insurance_Subscriber_Zip_Code_C	 	= c10	 ;	925
2	Insurance_Policy_No_C	= 	c14	 ;	935
2	Insurance_Group_No_C	= 	c14	 ;	949
;	tinsdiag_code	 		= 	c8	 ;	963
2	Insurance_Rel_to_Pt_C	= 	VC	 ;	971
;	tacptasn	 			= 	c1	 ;	973
2	Insurance_Plan_Code_C	= 	c6	 ;	974
;	taglines5	 			= 	c21	 ;	980
2	Authorization_Number_A 	= 	c20	 ;	1026
2	Authorization_Number_B 	= 	c20	 ;	1026
2	Authorization_Number_C 	= 	c20	 ;	1026
2 	RADIOLOGIST_ID	=	 VC
2   rad_report_id = f8
2 	rad_dr_name_f		=   vc
2 	rad_dr_name_l  	=  vc
2	rad_dr_name 		=  vc
2 	ATTENDING_ID		=	 VC
2 PCP_ID 			=	 VC
2 pcp_name			=	 c18
2 FAMILY_ID 		=	 VC
2 REFERRING_ID		=	 VC
2 ORDERING_ID		=	 VC
2 ord_dr_name_f		=   vc
2 ord_dr_name_l  	=   vc
2 ord_dr_name 		=   vc
2 order_id 			=	f8
2 order_mnem		= 	vc
2 RAD_PROC_TYPE		= VC
2 PRINCIPAL_DX		=	 VC
2 ADMIT_DX			= VC
2 FINAL_DX			= VC
2 work_dx			= vc
2 event_id			=	 f8
2 RESULT_STATUS_CD	 = F8
2 accession			=    vc
2 accessiond  = vc
2 check_in_dt_tm	= 	dq8
2 check_in_d		= 	 c2
2 check_in_m		= 	 c2
2 check_out_dt_tm	= 	dq8
2 check_out_d		= 	 c2
2 check_out_m		= 	 c2
2 check_out_y		= 	 c2
2 check_in_y		= 	 c2
2 expired			=	 vc
2 expired_alias		=	 c1
2 emp_name			=	 c100
2 FACILITY_CD		=	 F8
2 FACILITYCD		=  	 VC
2 FACILITY			=	 VC
2 site				= 	 c2
2 NU_CD				=	 F8
2 NU 				=	 VC
2 acc_dt_tm			= 	dq8
2 acc_loc			=   c25
2 pat_type			=	vc
2 pat_type_alias	=	c3
2 pat_type_class	=	vc
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
 set tabvar = char(9)
 
 
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
DECLARE CPT4_CD				= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!2954"))
DECLARE HCPCS_CD			= F8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!42457"))
declare pned_cd 			= f8 WITH CONSTANT(UAR_GET_CODE_BY_CKI("CKI.CODEVALUE!723952686"))
 
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
	, oros.order_id
	, oros.dictate_dt_tm "mm/dd/yyyy hh:mm;;d"
	, oros.exam_complete_dt_tm "mm/dd/yyyy hh:mm;;d"
	, oros.final_dt_tm "mm/dd/yyyy hh:mm;;d"
	, cmrn  				= cnvtalias(pa3.alias, pa3.alias_pool_cd)
;	 ;mrn  		 			= pa1.alias
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
	, person_alias   pa1
	, person_alias   pa3
	, code_value_outbound   cvo
	, orders   ord
	, PRSNL   PR
	, PRSNL_ALIAS   PA
	, clinical_event   ce
	, order_radiology   o
	, OMF_RADREPORT_ST ORRS
 
;plan e
;where e.encntr_id = oros.encntr_id
;where operator(E.loc_facility_cd, FAC_VAR, $pFACILITY)
;AND E.ACTIVE_IND = 1
 
;join oros
; where e.encntr_id = oros.encntr_id
 
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
 
 
JOIN pa1 where e.person_id = pa1.person_id
 			AND pa1.person_alias_type_cd = MRN_CD
			AND pa1.ACTIVE_IND = 1
			AND pa1.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
JOIN   pa3 where e.person_id = pa3.person_id
 			AND pa3.person_alias_type_cd = CMRN_CD
			AND pa3.ACTIVE_IND = 1
			AND pa3.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
join 	CVO
WHERE 	cvo.code_value = oros.loc_at_exam_cmplt_cd ; e.loc_facility_cd
and  	CVO.code_set = 220
AND 	CVO.ALIAS_TYPE_MEANING in ( "FACILITY", "AMBULATORY")
AND 	CVO.contributor_source_cd =         2552933345.00
 
; discussion on 7/18 to NOT use a filter for location is a better maintenance plan
; and go by docs only, and sort by location
 
;AND 	(CVO.alias IN ("S", "F", "L", "B", "R")
;AND 	(CVO.alias IN ("B", "F", "P")
;or  	SUBSTRING(1,3,CVO.ALIAS) in ("EDB", "EDF", "EDP"))
 
 
join  	o
where 	o.encntr_id = e.encntr_id
;and  	o.exam_status_cd in (rad_completed_CD) ;confirm
and 	o.accession = oros.accession_nbr
 
 
join ord
where ord.order_id = o.order_id
and ord.dept_status_cd IN
(
COMPLETED_14281_CD 		; f8 with Constant(uar_get_code_by("MEANING",14281, "COMPLETED")),protect
,CVSIGNED_14281_CD  		; f8 with Constant(uar_get_code_by("MEANING",14281, "CVSIGNED")),protect
,CVVERIFIED_14281_CD 	 ;f8 with Constant(uar_get_code_by("MEANING",14281, "CVVERIFIED")),protect
,RADCOMPLETED_14281_CD 	; f8 with Constant(uar_get_code_by("MEANING",14281, "RADCOMPLETED")),protect
)
and ord.order_status_cd = COMPLETED_CD
 
join 	ce
where 	ce.person_id = o.person_id
and 	ce.order_id = o.order_id
and 	ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
and 	ce.event_end_dt_tm <  cnvtdatetime(end_date)  ;between cnvtdatetime(start_date ) and cnvtdatetime(end_date)
and 	ce.encntr_id = o.encntr_id
;and 	ce.event_end_dt_tm >= cnvtdatetime(start_date )
and 	ce.result_status_cd in ( auth_ver_cd, altered_cd, modified_cd)
AND 	CE.parent_event_id > 0.0
and 	ce.view_level = 0
and 	not substring(6,2,ce.accession_nbr) in ('CA', 'NP', 'SC')
 
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
  ; updated based upon the mbm and the vrad docs
  AND orrs.radiologist_id IN (
		 12698067.00 ; AHMED, SHAWN IBRAR MD					53850
		,12697909.00 ; ALDERMAN, DANIEL FRANCIS MD				53673	;003
		,12402066.00 ; BABUSIS, ALGIS V MD						52485
		,12402161.00 ; BARRON, DAVID M MD						1828
		,16481662.00 ; BLANKNER, JOANNA GABRIEL MD				54095	;001
		,12697698.00 ; BLATT, ELLEN ROSE MD						53436
		,12402928.00 ; BONETTI, RENEE WITTENDORFE MD			53192
		,12402950.00 ; BOSH, GREGORY ALAN MD					53088
		,16481661.00 ; BOZMAN, RAYMOND ELWOOD MD				54094
		,12403012.00 ; BRECKWOLDT, REID D MD					52486
		,12403058.00 ; BRONSTEIN, YULIA L MD					52507
		,12698005.00 ; BROWNING, JARED C MD						53783
		,12697984.00 ; BURDETTE, DAVID DUKE MD					53760
		,12403170.00 ; BURKHOLZ, KIMBERLY J MD					52504
		,12697920.00 ; CASEY, KRISTIN L MD						53685
		,12697894.00 ; COLBY, JAY M MD							53658
		,12698029.00 ; DANN, PHOEBE HOPE MD						53808
		,12697890.00 ; DERR, DAVID R MD							53654
		,12404911.00 ; DO, DANIEL VU MD							52654	;001
		,12405014.00 ; DYM, JEAN-PAUL MD						52508
		,12405148.00 ; FALISZEK, JAMES E MD						52489
		,12405198.00 ; FERNANDEZ, JAMES REZA MD					53111
		,12698079.00 ; GIOVANNETTI, MARK JOSEPH MD				53862
		,12406060.00 ; GORADIA, DHAWAL A MD						52496
		,12698015.00 ; GREENSPAN, STACY LYNN DO					53793
		,12406209.00 ; GUTIERREZ, JENNIFER SUR MD				53073
		,12697650.00 ; HAL, JEFFREY TERRANCE MD					53384
		,12698025.00 ; HAMBURG, CAROLE S MD						53803
		,12407345.00 ; HARRIGAL, CHIVONNE L MD					52453
		,12407756.00 ; HURT, CHRISTOPHER J MD					52484
		,12407813.00 ; IZADI, KAMRON MD							52487
		,12697896.00 ; JONES, NORMAN E MD						53660
		,17185381.00 ; JORDAN, BENJAMIN E MD					54255	;002
		,12408546.00 ; KARIDAS, STEVEN MD						52498
		,12697928.00 ; KIM, DAVID YOUNG MD						53693
		,12697929.00 ; LANOUE, MARK ZAK MD						53694
		,12409421.00 ; LEMOND, THOMAS C MD						51265
		,12409574.00 ; LUTTRELL, LINDSAY GEORGE MD				53063
		,12698089.00 ; MACFARLANE, PATRICIA OWENS MD			53872
		,12409593.00 ; MACK, JOSEPH MD							52493
		,12409667.00 ; MARINO JR, PHILIP JR,PHILIP ANTHONY MD	53203
		,12410728.00 ; MYERS, WENDELL STEPHEN MD				53072
		,12411374.00 ; NWANKWO, JOHN IKECHI MD					7494
		,16481641.00 ; PAPPAS, CHARLES NICHOLAS MD				54070
		,12411710.00 ; PIRKLE, JACOB K MD						50977
		,12411728.00 ; POLLARD, BRADLEY MD						52641
		,12412374.00 ; RAUSCH, ROBERT O MD						3576
		,12412433.00 ; REX, DAVID L MD							52495
		,16651431.00 ; RIDEAU, ALECIA M MD						54143
		,12412690.00 ; SARAI, PAUL S MD							52506
		,16481664.00 ; SCIULLI, ROBERT LOUIS MD					54097
		,12697987.00 ; SHAFFREY, JULIE K MD						53763
		,12697946.00 ; SHELDON, LUCAS M MD						53711
		,12413492.00 ; SLOVES, JAMES H MD						52494
		,12697956.00 ; SNODGRASS, DOUGLAS DAVID MD				53725
		,12697982.00 ; TORTORELLI, CYNTHIA L MD					53758
		,12414456.00 ; TRAMONTANA, JAMES M MD					3581
		,12414461.00 ; TRAVIS, MITCHELL E MD					52505
		,12698011.00 ; UNSELL, BRYAN J MD						53789
		,12414618.00 ; VRLA, ROLF F MD							52491
		,16481652.00 ; WATTS, ROBERT EDWARD MD					54086
		,12415250.00 ; WOLKE, IRA STEPHEN MD					53239
		,16481651.00 ; WONG, WILLIAM JOSEPH MD					54085
		,16481640.00 ; YOSKIN, MAURICE PRATT MD					54067
	)
 
 
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
SUBSTRING(1,25, concat(TRIM(P.name_last_key,3),CHAR(32),TRIM(P.name_first_key,3),CHAR(32),substring(1,1,trim(p.name_middle_key,3))))
 
rDATA->ENC[cnt].FIRST_NAME = p.name_first
rDATA->ENC[cnt].LAST_NAME 	= p.name_last ; concat("TEST",cnvtstring(cnt)) ;for testing only - mask the namep.name_last
rDATA->ENC[cnt].M_NAME 		= name_mi
rDATA->ENC[cnt].marital 	= marital
rDATA->ENC[cnt].MRN 		= cmrn
rDATA->ENC[cnt].FIN 		= fin
rDATA->ENC[cnt].DOB 		= format(p.birth_dt_tm, "MMDDYY;;d") ;dob_year
rDATA->ENC[cnt].dob_year  	= dob_year
rDATA->ENC[cnt].dob_month  	= dob_month
rDATA->ENC[cnt].dob_day  	= dob_day
rDATA->ENC[cnt].birth_dt_tm = p.birth_dt_tm
rDATA->ENC[cnt].SEX 		= sex
rDATA->ENC[cnt].disch_dt_tm = e.disch_dt_tm
rDATA->ENC[cnt].admit_dt_tm = e.reg_dt_tm
rDATA->ENC[cnt].FACILITY_CD = E.loc_facility_cd
rDATA->ENC[cnt].FACILITYCD  = UAR_GET_CODE_DISPLAY(E.loc_facility_cd)
rDATA->ENC[cnt].FACILITY 	= cnvtstring(e.loc_facility_cd)
rDATA->ENC[cnt].NU_CD 		= E.loc_nurse_unit_cd
rDATA->ENC[cnt].NU 			= UAR_GET_CODE_DISPLAY(E.loc_nurse_unit_cd)
rDATA->ENC[cnt].PAT_TYPE  		=  cnvtstring(e.encntr_type_cd)
rDATA->ENC[cnt].PAT_TYPE_CLASS	= PAT_TYPE_CLASS
rDATA->ENC[cnt].expired 	= expired
rDATA->ENC[cnt].ORDERING_ID = ORD_PHYS_ALIAS
rDATA->ENC[cnt].order_id 	= o.order_id
rDATA->ENC[cnt].event_id 	= ce.event_id
rDATA->ENC[cnt].RESULT_STATUS_CD = ce.result_status_cd
rDATA->ENC[cnt].accession 	=  ce.accession_nbr
rDATA->ENC[cnt].accessiond 	= cnvtacc(ce.accession_nbr)
rDATA->ENC[cnt].ord_dr_name_f = ORD_PHYS_NAME_FIRST
rDATA->ENC[cnt].ord_dr_name_l = ORD_PHYS_NAME_LAST
rDATA->ENC[cnt].ord_dr_name = pr.name_full_formatted
 
;ssn formatting
; rDATA->ENC[cnt].SSN = ssn
 rDATA->ENC[CNT].SSN					= format( trim(PA2.ALIAS,3),"###-##-####;p0")
;	IF (cnvtint(rDATA->ENC[CNT].SSN) <=0  )
;		rDATA->ENC[CNT].SSN	 = ""
 
;	ENDIF
 
  foot report
 rDATA->total = cnt
 
WITH NOCOUNTER  ; , format, separator = " ", check
 
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
	,	(dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
PLAN D
join dx
	WHERE dx.encntr_id = rDATA->ENC[d.seq].ENCNTR_ID
	AND Dx.ACTIVE_IND = 1
	AND Dx.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
	AND Dx.DIAG_TYPE_CD in ( DISCH_DX_CD, FINAL_DX_CD)
 	; not consistently seeing final or discharge dx codes i've seen both
	;AND D.DIAG_PRSNL_ID > 0.0 ;Only qualifies those entered by a clinician
 
JOIN N
	WHERE N.NOMENCLATURE_ID =  dx.NOMENCLATURE_ID
	AND N.SOURCE_VOCABULARY_CD = ICD10CM_CD
 
 
ORDER BY D.SEQ ;Dx.ENCNTR_ID
		, DX.diag_priority
		,Dx.DIAGNOSIS_ID
 
detail
 
 			rDATA->ENC[d.seq].FINAL_DX = testingdx
 
 
WITH NOCOUNTER   ;, format, separator = " ", check
 
 
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
rDATA->ENC[d.seq].RADIOLOGIST_ID 	= trim(pa.alias,3)
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
rDATA->ENC[d.seq].rad_report_id 	= rr.rad_report_id
 
WITH NOCOUNTER ;,  format, separator = " ", check
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
 
;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; ATTENDING PHYSICIANS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
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
 
 
ORDER BY D.SEQ, EPR.beg_effective_dt_tm DESC , pa.beg_effective_dt_tm desc
 
detail
rDATA->ENC[D.seq].REFERRING_ID  = ALIAS
rDATA->ENC[D.seq].REFERRING_NAME = PR.name_full_formatted
WITH NOCOUNTER
; , format, separator = " ", check
 
 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; PCP PHYSICIANS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
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
	; not consistently seeing these filled out so capturing either
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
	rDATA->ENC[d.seq].ZIPCODE     = substring(1,5,format(trim(A.ZIPCODE_key),"#########"))
	;rDATA->ENC[d.seq].EXT_ZIPCODE = SUBSTRING(6,4,FORMAT(TRIM(A.ZIPCODE_key),"#########"))
 
WITH NOCOUNTER
; , format, separator = " ", check
;
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; business
SELECT distinct INTO "NL:"
;SELECT distinct INTO value ($poutdev)
FROM
	person_org_reltn p
	, organization o
	, (dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
plan d
join p
where p.person_id =     rDATA->ENC[d.seq].PERSON_ID
and p.person_org_reltn_cd =             1136.00
and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
 
join o
where o.organization_id = p.organization_id
and o.active_ind = 1
 
detail
 rDATA->ENC[d.seq].emp_name = trim(o.org_name,3)
 
WITH NOCOUNTER
; , format, separator = " ", check
;
 
 
 
; insurance carriers
SELECT distinct  INTO "NL:"
;select distinct into value ($pOutdev)
	d.seq
	, E.ENCNTR_ID
	, E.ENCNTR_PLAN_RELTN_ID
	, E.END_EFFECTIVE_DT_TM
	, E.EXT_PAYER_IDENT
	, E.EXT_PAYER_NAME
	, E.GENERIC_HEALTH_PLAN_NAME
	, E.GROUP_NAME
	, E.GROUP_NBR
	, E.PERSON_ID
	, E.PRIORITY_SEQ
	, E_SUBSCRIBER_TYPE_DISP = UAR_GET_CODE_DISPLAY(E.SUBSCRIBER_TYPE_CD)
	, E.SUBS_MEMBER_NBR
 
FROM
(dummyt   d  with seq = value (size(rDATA->ENC,5))),
encounter  enc,
ENCNTR_PLAN_RELTN  E,
ORGANIZATION  ORG,
PERSON  PE,
ADDRESS  A,
address ah,
PHONE  P,
encntr_person_reltn  EP,
health_plan hp,
health_plan_alias hpa,
person_org_reltn  por,
address asub
 
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
and ah.parent_entity_name = outerjoin("HEALTH_PLAN")
and ah.active_ind = outerjoin(1)
 
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
 
 
order by
d.seq,
e.encntr_id,
e.priority_seq,
e.health_plan_id
 
 
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
      	rdata->enc[d.seq].Insurance_Plan_Code_A = trim(ah.street_addr4, 3) ;trim(hpa.alias);UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
      	rdata->enc[d.seq].Insurance_Plan_Name_A= hp.plan_name
;     	rdata->enc[d.seq].Insurance_FC_A = substring(1,10,UAR_GET_CODE_DISPLAY(hp.financial_class_cd))
 
      	; issue reported that sometimes these are blank
      	if (trim(E.subs_member_nbr,3) > " ")
      		rdata->enc[d.seq].Insurance_Policy_No_A = E.subs_member_nbr
      	else
      		rdata->enc[d.seq].Insurance_Policy_No_A = E.member_nbr
      	endif
       	rdata->enc[d.seq].Insurance_Group_No_A = E.GROUP_NBR
      	rdata->enc[d.seq].Insurance_Address_1_A = A.STREET_ADDR
      	rdata->enc[d.seq].Insurance_City_A = A.CITY
      	rdata->enc[d.seq].Insurance_State_A = A.STATE
      	rdata->enc[d.seq].Insurance_Zip_Code_A = A.ZIPCODE
      	rdata->enc[d.seq].Insurance_Insured_A = pe.name_full_formatted
     	rdata->enc[d.seq].Insurance_Rel_to_Pt_A = CNVTSTRING( EP.PERSON_RELTN_CD )
		rdata->enc[d.seq].Insurance_Subscriber_Address_1_A = asub.street_addr
		rdata->enc[d.seq].Insurance_Subscriber_City_A = asub.city
		rdata->enc[d.seq].Insurance_Subscriber_State_A = asub.state
		rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_A = asub.zipcode
 
 
;   elseif (ins_seq_count = 2)
   elseif (e.priority_seq = 2)
     	rdata->enc[d.seq].encntr_plan_reltn_id_B = e.encntr_plan_reltn_id
     	; more discussions needed no this field addr4 vs plan type cd
      	rdata->enc[d.seq].Insurance_Plan_Code_B = trim(ah.street_addr4, 3) ;trim(hpa.alias);UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
      	rdata->enc[d.seq].Insurance_Plan_Name_B = hp.plan_name
      	; issue reported that sometimes these are blank
      	if (trim(E.subs_member_nbr,3) > " ")
      		rdata->enc[d.seq].Insurance_Policy_No_B = E.subs_member_nbr
      	else
      		rdata->enc[d.seq].Insurance_Policy_No_B = E.member_nbr
      	endif
     	rdata->enc[d.seq].Insurance_Group_No_B = E.GROUP_NBR
     	rdata->enc[d.seq].Insurance_Address_1_B = A.STREET_ADDR
      	rdata->enc[d.seq].Insurance_City_B = A.CITY
      	rdata->enc[d.seq].Insurance_State_B = A.STATE
      	rdata->enc[d.seq].Insurance_Zip_Code_B = A.ZIPCODE
      	rdata->enc[d.seq].Insurance_Insured_B = pe.name_full_formatted
      	rdata->enc[d.seq].Insurance_Rel_to_Pt_B  = CNVTSTRING( EP.PERSON_RELTN_CD )
		rdata->enc[d.seq].Insurance_Subscriber_Address_1_B = asub.street_addr
		rdata->enc[d.seq].Insurance_Subscriber_City_B = asub.city
		rdata->enc[d.seq].Insurance_Subscriber_State_B = asub.state
		rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_B = asub.zipcode
 
 
 
;    elseif (ins_seq_count = 3)
    elseif (e.priority_seq = 3)
     rdata->enc[d.seq].encntr_plan_reltn_id_C = e.encntr_plan_reltn_id
      rdata->enc[d.seq].Insurance_Plan_Code_C = trim(ah.street_addr4, 3) ;trim(hpa.alias);UAR_GET_CODE_DISPLAY(hp.plan_type_cd)
      rdata->enc[d.seq].Insurance_Plan_Name_C = hp.plan_name
 
      if (trim(E.subs_member_nbr,3) > " ")
      	rdata->enc[d.seq].Insurance_Policy_No_C = E.subs_member_nbr
      else
      	rdata->enc[d.seq].Insurance_Policy_No_C = E.member_nbr
      endif
      rdata->enc[d.seq].Insurance_Group_No_C = E.GROUP_NBR
      rdata->enc[d.seq].Insurance_Address_1_C = A.STREET_ADDR
 
      rdata->enc[d.seq].Insurance_City_C = A.CITY
      rdata->enc[d.seq].Insurance_State_C = A.STATE
      rdata->enc[d.seq].Insurance_Zip_Code_C = A.ZIPCODE
      rdata->enc[d.seq].Insurance_Insured_C = pe.name_full_formatted
      rdata->enc[d.seq].Insurance_Rel_to_Pt_C = CNVTSTRING( EP.PERSON_RELTN_CD )
		rdata->enc[d.seq].Insurance_Subscriber_Address_1_C = asub.street_addr
		rdata->enc[d.seq].Insurance_Subscriber_City_C = asub.city
		rdata->enc[d.seq].Insurance_Subscriber_State_C = asub.state
		rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_C = asub.zipcode
 
 
  endif
ENDIF
 
with nocounter ;, format, separator = " ", check
 
 
; ------------------------------------------------------------------------
; Get Authorization Info
;SELECT INTO VALUE($POUTDEV)
select into "nl:"
 E.encntr_id
, E.priority_seq
,auth.auth_nbr
 
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
; SELECT INTO VALUE ($poutdev)
 select into "nl:"
 
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
 
WITH nocounter;
 
 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
; outbound aliasing
FOR (I = 1 TO SIZE(rDATA->ENC,5))
  	set rDATA->ENC[I].Insurance_Rel_to_Pt_A
  		= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_Rel_to_Pt_A	)),3))
  	set rDATA->ENC[I].Insurance_Rel_to_Pt_B
  		= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_Rel_to_Pt_B	)),3))
   	set rDATA->ENC[I].Insurance_Rel_to_Pt_C
  		= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].Insurance_Rel_to_Pt_C	)),3))
	set rDATA->ENC[I].PAT_TYPE	= concat(
										trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].pat_type)),3),
										trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].facility)),3))
	SET rDATA->ENC[I].SEX_alias			= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].SEX)),3))
	set rDATA->ENC[I].pat_type_ioe	    = substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].PAT_TYPE_CLASS)),3))
	set rDATA->ENC[I].expired_alias 	= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].expired)),3))
	set rDATA->ENC[I].marital_alias 	= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].marital)),3))
 	set rDATA->ENC[I].FACILITY			= substring(1,1,trim(GET_CODE_VALUE_ALIAS(CNVTREAL(rDATA->ENC[I].FACILITY)),3))
 
 
	case (rDATA->ENC[I].FACILITY)
		of "B": set rDATA->ENC[I].site = "21"
		of "E": set rDATA->ENC[I].site = "22"
		of "F": set rDATA->ENC[I].site = "01"
		of "L": set rDATA->ENC[I].site = "40"
 		of "P": set rDATA->ENC[I].site = "09"
 		of "S": set rDATA->ENC[I].site = "60"
 		of "W": set rDATA->ENC[I].site = "99"
 	endcase
 
endfor
 
; CALL ECHORECORD(rData)
 
;demographic output
;SELECT  distinct INTO VALUE ($POUTDEV)
sELECT distinct INTO VALUE (output->temp_demo)
;select distinct  into "NL:"
;XXX =  rDATA->ENC[D.SEQ].FACILITYCD
 PAT_NAME  		= 	substring(1,25,replace(rDATA->ENC[d.seq].NAME ,CHAR(0)," "))
,ADDRESS  		= 	substring(1,22,replace(rData->ENC[d.seq].ADDRESS,CHAR(0)," "))
,ADDRESS2  		= 	substring(1,15,replace(rData->ENC[d.seq].ADDRESS2,CHAR(0)," "))
,CITY  			= 	substring(1,15, replace(rData->ENC[d.seq].CITY,CHAR(0)," "))
,STATE  		= 	substring(1,2,replace(rData->ENC[d.seq].STATE,CHAR(0)," "))
,zipcode  		= 	substring(1,10,replace(rData->ENC[d.seq].zipcode,CHAR(0)," "))
,phone_home		=	substring(1,10,replace(rData->ENC[d.seq].phone_home,CHAR(0)," "))
,phone_biz		=	substring(1,10,replace(rData->ENC[d.seq].phone_biz,CHAR(0)," "))
,birth_dt_tm  	= 	replace(FORMAT(rData->ENC[d.seq].birth_dt_tm , "MMDDYY;;D"),CHAR(0)," ")
,SEX  	 		= 	substring(1,1,replace(rDATA->ENC[d.seq].SEX_alias,CHAR(0)," "))
,FIN  	 		= 	substring(1,11,concat(rDATA->ENC[d.seq].FACILITY, replace(rDATA->ENC[d.seq].fin,CHAR(0)," ")))
,REFER_DOC 		= 	substring(1,12, replace(rData->ENC[d.seq].REFERRING_NAME,CHAR(0)," "))
,employer		=   substring(1,28,replace(rData->ENC[d.seq].emp_name,CHAR(0)," "))
,SSN  			= 	replace(rData->ENC[d.seq].ssn,CHAR(0)," ")
,family_name	= 	substring(1,18,evaluate2(
								if (rData->ENC[d.seq].FAMILY_ID > "" )
									replace(replace(rData->ENC[d.seq].family_name,CHAR(0)," "), char(44), "")
								elseif (rData->ENC[d.seq].PCP_ID > "" )
									replace(replace(rData->ENC[d.seq].pcp_name,CHAR(0)," "), char(44),"")
								endif))
,marital		= 	substring(1,1,replace(rDATA->ENC[d.seq].marital_alias,CHAR(0)," "))
,hsite_code		=   substring(1,2,replace(rDATA->ENC[d.seq].site,CHAR(0)," "))
,ADM_Dt_tm  	= 	replace(FORMAT(rData->ENC[d.seq].admit_dt_tm, "MMDDYY;;D"),CHAR(0)," ")
,DISCH_Dt_tm  	= 	replace(FORMAT(rData->ENC[d.seq].DISCH_Dt_tm, "MMDDYY;;D"),CHAR(0)," ")
,pat_type_ioe	= 	substring(1,1,replace(rDATA->ENC[d.seq].pat_type_ioe,CHAR(0)," "))
,acc_dt						= format(rdata->ENC[d.seq].acc_dt_tm , "mmddyy;;d")
,CMRN  	 		= 	substring(1,11,replace(rDATA->ENC[d.seq].MRN,CHAR(0)," "))
,Insurance_Plan_Code_A  	= substring(1,6, replace(rData->ENC[d.seq].Insurance_Plan_Code_A ,CHAR(0)," "))
;,Insurance_FC_A  			= replace(rData->ENC[d.seq].Insurance_FC_A,CHAR(0)," ")
,Insurance_Plan_Name_A  	= substring(1,20,replace(rData->ENC[d.seq].Insurance_Plan_Name_A ,CHAR(0)," "))
,Insurance_Policy_No_A  	= substring(1,14,replace(rData->ENC[d.seq].Insurance_Policy_No_A,CHAR(0)," "))
,Insurance_Group_No_A  		= substring(1,14,replace(rData->ENC[d.seq].Insurance_Group_No_A,CHAR(0)," "))
,Insurance_Address_1_A  	= substring(1,20,replace(rData->ENC[d.seq].Insurance_Address_1_A,CHAR(0)," "))
;,Insurance_Address_2_A  	= replace(rData->ENC[d.seq].Insurance_Address_2_A,CHAR(0)," ")
;,Insurance_Address_4_A  	= replace(rData->ENC[d.seq].Insurance_Address_4_A,CHAR(0)," ")
,Insurance_City_A  			= substring(1,15,	replace(rData->ENC[d.seq].Insurance_City_A,CHAR(0)," "))
,Insurance_State_A  		= substring(1,2,	replace(rData->ENC[d.seq].Insurance_State_A,CHAR(0)," "))
,Insurance_Zip_Code_A  		= substring(1,10,	replace(rData->ENC[d.seq].Insurance_Zip_Code_A,CHAR(0)," "))
,Insurance_Insured_A  		= substring(1,20,	replace(replace(rData->ENC[d.seq].Insurance_Insured_A,CHAR(0)," "),char(44),""))
,pinsured_adr1 				= substring(1,20,	replace(rdata->enc[d.seq].Insurance_Subscriber_Address_1_A  ,CHAR(0)," "))
,pinsured_city				= substring(1,15,	replace(rdata->enc[d.seq].Insurance_Subscriber_City_A  ,CHAR(0)," "))
,pinsured_stat				= substring(1,2, 	replace(rdata->enc[d.seq].Insurance_Subscriber_State_A  ,CHAR(0)," "))
,pinsured_zip				= substring(1,10,	replace(rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_A ,CHAR(0)," "))
,Insurance_Rel_to_Pt_A  	= substring(1,2, 	rData->ENC[d.seq].Insurance_Rel_to_Pt_A)
,Insurance_Plan_Code_B  	= substring(1,6,  	replace(rData->ENC[d.seq].Insurance_Plan_Code_B,CHAR(0)," "))
,Insurance_Plan_Name_B  	= substring(1,20,  	replace(rData->ENC[d.seq].Insurance_Plan_Name_B,CHAR(0)," "))
,Insurance_Policy_No_B  	= substring(1,14 , 	replace(rData->ENC[d.seq].Insurance_Policy_No_B,CHAR(0)," "))
,Insurance_Group_No_B  		= substring(1,14,  	replace(rData->ENC[d.seq].Insurance_Group_No_B,CHAR(0)," "))
,Insurance_Address_1_B  	= substring(1,20,  	replace(rData->ENC[d.seq].Insurance_Address_1_B,CHAR(0)," "))
,Insurance_City_B  			= substring(1,15,  	replace(rData->ENC[d.seq].Insurance_City_B,CHAR(0)," "))
,Insurance_State_B  		= substring(1,2,  	replace(rData->ENC[d.seq].Insurance_State_B,CHAR(0)," "))
,Insurance_Zip_Code_B  		= substring(1,10,  	replace(rData->ENC[d.seq].Insurance_Zip_Code_B,CHAR(0)," "))
,Insurance_Insured_B  		= substring(1,20,  	replace(replace(rData->ENC[d.seq].Insurance_Insured_B,CHAR(0)," "), char(44), ""))
,sinsured_adr1 				= substring(1,20,  	replace(rdata->enc[d.seq].Insurance_Subscriber_Address_1_B  ,CHAR(0)," "))
,sinsured_city				= substring(1,15,  	replace(rdata->enc[d.seq].Insurance_Subscriber_City_B  ,CHAR(0)," "))
,sinsured_stat				= substring(1,2,  	replace(rdata->enc[d.seq].Insurance_Subscriber_State_B  ,CHAR(0)," "))
,sinsured_zip				= substring(1,10,  	replace(rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_B ,CHAR(0)," "))
,Insurance_Rel_to_Pt_B  	= substring(1,2,  	replace(rData->ENC[d.seq].Insurance_Rel_to_Pt_B,CHAR(0)," "))
,Insurance_Plan_Code_C  	= substring(1,6,  	replace(rData->ENC[d.seq].Insurance_Plan_Code_C,CHAR(0)," "))
,Insurance_Plan_Name_C  	= substring(1,20,  	replace(rData->ENC[d.seq].Insurance_Plan_Name_C,CHAR(0)," "))
,Insurance_Policy_No_C  	= substring(1,14,  	replace(rData->ENC[d.seq].Insurance_Policy_No_C,CHAR(0)," "))
,Insurance_Group_No_C  		= substring(1,14,  	replace(rData->ENC[d.seq].Insurance_Group_No_C,CHAR(0)," "))
,Insurance_Address_1_C  	= substring(1,20,  	replace(rData->ENC[d.seq].Insurance_Address_1_C,CHAR(0)," "))
,Insurance_City_C  			= substring(1,15,  	replace(rData->ENC[d.seq].Insurance_City_C,CHAR(0)," "))
,Insurance_State_C  		= substring(1,2 , 	replace(rData->ENC[d.seq].Insurance_State_C,CHAR(0)," "))
,Insurance_Zip_Code_C  		= substring(1,10,  	replace(rData->ENC[d.seq].Insurance_Zip_Code_C,CHAR(0)," "))
,Insurance_Insured_C  		= substring(1,50,  	replace(replace(rData->ENC[d.seq].Insurance_Insured_C,CHAR(0)," "), char(44), ""))
,tinsured_adr1 				= substring(1,20,  	replace(rdata->enc[d.seq].Insurance_Subscriber_Address_1_C  ,CHAR(0)," "))
,tinsured_city				= substring(1,15,  	replace(rdata->enc[d.seq].Insurance_Subscriber_City_C  ,CHAR(0)," "))
,tinsured_stat				= substring(1,2,  	replace(rdata->enc[d.seq].Insurance_Subscriber_State_C  ,CHAR(0)," "))
,tinsured_zip				= substring(1,10,  	replace(rdata->enc[d.seq].Insurance_Subscriber_Zip_Code_C ,CHAR(0)," "))
,Insurance_Rel_to_Pt_C  	= substring(1,2,  	rData->ENC[d.seq].Insurance_Rel_to_Pt_C)
,ins_auth					= substring(1,20,  	replace(rData->ENC[d.seq].Authorization_Number_A,CHAR(0)," "))
,pat_type					= substring(1,3,  	replace(rDATA->ENC[d.seq].pat_type,CHAR(0)," "))
,acc_loc					=  replace(rData->ENC[d.seq].acc_loc,CHAR(0)," ")
,FAC  	 					= substring(1,1,  rDATA->ENC[d.seq].FACILITY)
,cr_var						= char(13)
 
FROM
(dummyt   d  with seq = value (size(rDATA->ENC,5)))
 
WHERE NOT rDATA->ENC[D.SEQ].Insurance_Plan_Code_A IN (
'711015','711016','711017','711018','711019',
            '711020','711021','711022')
 
 
 
order by
 rDATA->ENC[D.SEQ].FACILITYCD
,CMRN
,FIN
,SSN
,PAT_NAME
,SEX
 
head report
cntd = 0
 
head fin
cntd = cntd + 1
 
col     0       'M'
,col 	2		PAT_NAME
,col 	27		ADDRESS
,col 	49		ADDRESS2
,col 	64		CITY
,col 	79		STATE
,col 	81		zipcode
,col 	91		phone_home
,col 	101		phone_biz
,col 	111		birth_dt_tm
,col 	117		SEX
,col 	118		FIN
,col 	129		REFER_DOC
,col 	141		employer
,col 	169		SSN
,col 	180		family_name
,col 	198		hsite_code
;col 	200		haglines1
,col 	334		marital
;col 	335		hspecial_cd
,col 	338		ADM_Dt_tm
,col 	344		DISCH_Dt_tm
,col 	350		pat_type_ioe
,col 	351		acc_dt
,col 	357		CMRN
;col 	368		filler1
;col 	374		haglines2
;col 	399		filler2
,col 	400		Insurance_Plan_Name_A
,col 	420		Insurance_Address_1_A
,col 	440		Insurance_City_A
,col 	455		Insurance_State_A
,col 	457		Insurance_Zip_Code_A
,col 	467		Insurance_Insured_A
,col 	487		pinsured_adr1
,col 	507		pinsured_city
,col 	522		pinsured_stat
,col 	524		pinsured_zip
,col 	534		Insurance_Policy_No_A
,col 	548		Insurance_Group_No_A
;col 	562		pinsdiag_code
,col 	570		rData->ENC[d.seq].Insurance_Rel_to_Pt_A
;col 	572		"Y" ;pacptasn
,col 	573		Insurance_Plan_Code_A
;col 	579		paglines3
 
 
;col 	599		filler3
,col 	600		Insurance_Plan_Name_B
,col 	620		Insurance_Address_1_B
,col 	640		Insurance_City_B
,col 	655		Insurance_State_B
,col 	657		Insurance_Zip_Code_B
,col 	667		Insurance_Insured_B
,col 	687		sinsured_adr1
,col 	707		sinsured_city
,col 	722		sinsured_stat
,col 	724		sinsured_zip
,col 	734		Insurance_Policy_No_B
,col 	748		Insurance_Group_No_B
;col 	762		sinsdiag_code
,col 	770		rData->ENC[d.seq].Insurance_Rel_to_Pt_B
,col 	772		"Y" ;sacptasn
,col 	773		Insurance_Plan_Code_B
;col 	779		saglines4
 
 
;col 	799		filler4
,col 	800		Insurance_Plan_Name_C
,col 	820		Insurance_Address_1_C
,col 	840		Insurance_City_C
,col 	855		Insurance_State_C
,col 	857		Insurance_Zip_Code_C
,col 	867		Insurance_Insured_C
,col 	887		tinsured_adr1
,col 	907		tinsured_city
,col 	922		tinsured_stat
,col 	924		tinsured_zip
,col 	934		Insurance_Policy_No_C
,col 	948		Insurance_Group_No_C
;col 	962		tinsdiag_code
,col 	970		rData->ENC[d.seq].Insurance_Rel_to_Pt_C
col 	972		"Y" ;tacptasn
,col 	973		Insurance_Plan_Code_C
;col 	979		taglines5
,col 	1000	acc_loc
,col 	1025	ins_auth
,col	1085	pat_type
COL		1088    cr_var
row + 1
 
 foot report
  rDATA->subt_demo  = cntd
 
 
;WITH NOCOUNTER , separator = " ", format, check
WITH PCFORMAT ("", value(char(32)) ,1,1), maxrow = 1, maxcol = 1090
     ,FORMAT = CRSTREAM
 
 
 
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
;;
;
 
 ;dictation output with signatures
;SELECT   INTO VALUE ($POUTDEV)
SELECT  INTO VALUE (output->temp_dict)
FROM
	OMF_RADMGMT_ORDER_ST   OROS
	, ce_blob   cb
	, clinical_event   ce
 
plan cb
where
	expand(num, 1, size(rDATA->ENC, 5), cb.event_id ,rDATA->ENC[num].event_id)
;	and 	cb.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
;	and  	cb.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
	and 	cb.compression_cd = ocfcomp_var
 
join ce where ce.event_id = cb.event_id
; AND   ce.RESULT_STATUS_CD in ( auth_ver_cd, altered_cd, modified_cd)
 
join oros
where oros.order_id = ce.order_id
 
ORDER BY
	  ce.person_id
	, oros.encntr_id
	, oros.rad_report_id
	, ce.order_id
	, ce.last_utc_ts desc
	, cb.event_id
	, cb.blob_seq_num
 
head report
 	cntd = 0
	numx = 0
	idx = 0
	cntx = 0
      	blob_out = " "
    	outbuf = " "
   	 	good_blob = " "
   	 	BlobNoRTF = " "
    	blobout = " "
    	print_blob = " "
 
 head  cb.event_id
 	cntd = cntd + 1
	numx = 0
	idx = 0
	cntx = 0
	idx = locateval(numx, 1, size(rDATA->ENC, 5), cb.event_id ,rDATA->ENC[numx].event_id)
 
 	if (idx > 0)
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
 
   		cntx = cntx + 1
   		retlen = 1
    	offset = 0
 
 	;LINE 1
 		fac				=   replace(substring(1,1,  trim(rDATA->ENC[idx].FACILITY,3)), char(0),  "" )
 		PAT_ACCT_NBR   	= 	 concat(trim(rDATA->ENC[idx].FACILITY,3), trim(rDATA->ENC[idx].fin,3))
 		CK_IN_NUM		= 	rDATA->ENC[idx].accessiond
 		CK_IN_DT_Y 		=   FORMAT(rDATA->ENC[idx].check_in_dt_tm, "YYYY;;D")
		CK_IN_DT_M  	= 	FORMAT(rDATA->ENC[idx].check_in_dt_tm, "MM;;D")
		CK_IN_DT_D  	= 	FORMAT(rDATA->ENC[idx].check_in_dt_tm, "DD;;D")
		RAD_DR_ID  		=   replace(trim(rDATA->ENC[idx].RADIOLOGIST_ID,3),CHAR(0),"")
		RAD_DR_FISRT   	= 	replace(trim(rDATA->ENC[idx].rad_dr_name_f,3),CHAR(0),"")
		RAD_DR_LAST  	= 	replace(trim(rDATA->ENC[idx].rad_dr_name_l,3),CHAR(0),"")
		ORD_DR_ID  		= 	replace(trim(rDATA->ENC[idx].ORDERING_ID,3),CHAR(0),"")
		ORD_DR_FIRST   	= 	replace(trim(rDATA->ENC[idx].ord_dr_name_f,3),CHAR(0),"")
		ORD_DR_LAST  	= 	replace(trim(rDATA->ENC[idx].ord_dr_name_l,3),CHAR(0),"")
		pat_type_ioe	= 	replace(trim(rDATA->ENC[idx].pat_type_ioe,3),CHAR(0),"")
		if (substring(4,2,cnvtupper(rDATA->ENC[idx].accessiond)) = "IR")
			RAD_PROC_TYPE	=	trim("INVA",3) ;replace(rDATA->ENC[idx].RAD_PROC_TYPE,CHAR(0),"")
		else
			RAD_PROC_TYPE	=	trim("DIAG",3) ;replace(rDATA->ENC[idx].RAD_PROC_TYPE,CHAR(0),"")
		ENDIF
 
 	;;LINE 2
		UNIT_NBR		= concat(trim(rDATA->ENC[idx].FACILITY,3), trim(rDATA->ENC[idx].mrn,3))
		FIRST_NAME  	= replace(trim(rDATA->ENC[idx].FIRST_NAME,3),CHAR(0),"")
		M_name  		= replace(trim(rDATA->ENC[idx].M_name,3),CHAR(0),"")
		LAST_NAME   	= replace(trim(rDATA->ENC[idx].LAST_NAME,3),CHAR(0),"")
		dob_year   		= FORMAT( rDATA->ENC[idx].BIRTH_DT_TM, "YYYY;;D")
		dob_month   	= FORMAT( rDATA->ENC[idx].BIRTH_DT_TM, "MM;;D")
		dob_day   		= FORMAT( rDATA->ENC[idx].BIRTH_DT_TM, "DD;;D")
		SEX_ALIAS   	= replace(trim(rDATA->ENC[idx].SEX_ALIAS,3),CHAR(0),"")
		IPlan_Name    	= replace(trim(rDATA->ENC[idx].Insurance_Plan_Name_A,3),CHAR(0),"")
		IPlan_Code    	= replace(trim(rDATA->ENC[idx].Insurance_Plan_Code_A,3),CHAR(0),"")
		pat_type  		= replace(trim(rDATA->ENC[idx].pat_type,3),CHAR(0),"")
 
	;line 3
		RAD_ORD_PROC 	=  replace(trim(rDATA->ENC[idx].order_mnem,3),CHAR(0),"")
		ADMIT_DX  		= replace(trim(rDATA->ENC[idx].ADMIT_DX ,3),CHAR(0),"")
		WORK_DX  		= replace(trim(rDATA->ENC[idx].work_dx ,3),CHAR(0),"")
		rad_dr			= replace(trim(rDATA->ENC[idx].RADIOLOGIST_ID ,3),CHAR(0),"")
 
	;sig
	 	transcriptionist = concat ("Transcriptionist- ",  rDATA->ENC[idx].TRANSCRIBED )
		readby			 = concat ("Read By- ",   rDATA->ENC[idx].TRANSCRIBED )
		revby			 = concat ("Reviewed and E-Signed By- ",  rDATA->ENC[idx].APPROVED )
		released		 = concat ("Released Date Time- ",format(rDATA->ENC[idx].APPROVED_dt_tm, "mm/dd/yy hh:mm;;d"))
 
col 0
;LINE 1
	fac				,tabVar,
	PAT_ACCT_NBR   	,tabVar,
	CK_IN_NUM 		,tabVar,
	CK_IN_DT_Y 		,tabVar,
	CK_IN_DT_M  	,tabVar,
	CK_IN_DT_D  	,tabVar,
	RAD_DR_ID  		,tabVar,
	RAD_DR_FISRT 	,tabVar,
	RAD_DR_LAST  	,tabVar,
	ORD_DR_ID  		,tabVar,
	ORD_DR_FIRST  	,tabVar,
	ORD_DR_LAST  	,tabVar,
	pat_type_ioe	,tabVar,
	RAD_PROC_TYPE	,crVar
	row + 1
;LINE 2
	UNIT_NBR		,tabVar,
	FIRST_NAME 		,tabVar,
	M_name  		,tabVar,
	LAST_NAME  		,tabVar,
	dob_year   		,tabVar,
	dob_month  		,tabVar,
	dob_day   		,tabVar,
	SEX_ALIAS   	,tabVar,
	IPlan_Name  	,tabVar,
	IPlan_Code   	,tabVar,
	pat_type  		,crVar
  	row + 1
;LINE 3
	"Procedure Ordered: ", RAD_ORD_PROC	,crVar, row + 1
	"Admitting DX: ", ADMIT_DX  		,crVar, row + 1
	"Working DX: ", WORK_DX  			,crVar, row + 1
 
  	endif
 DETAIL
 
 
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
 
 
foot cb.event_id
     		IF (IDX > 0)
    newsize = 0
    ;;;***** put the ocf_blob terminator back on the end of the re-assembled blob
    good_blob = concat(notrim(good_blob),"ocf_blob")
   ;;;***** uncompress the re-assembled blob
    blob_un = uar_ocf_uncompress(good_blob, size(good_blob),
                            blobout, size(blobout),newsize )
   ;reallocate BlobNoRTF to a fixed length character variable that is the size of blobout
   stat = memrealloc(BlobNoRTF,1,build("c",size(blobout)))
;    call echo(build("size of BlobNoRTF:",size(BlobNoRTF)))
    ;;;***** use uar_rtf2 to strip the rtf from the blob
    stat = uar_rtf2(blobout,
                    size(blobout),
                    BlobNoRTF,
                    size(BlobNoRTF),
                    nortfsize,
                    1)
 
    offset = 1
 while (offset < size(trim(BlobNoRTF,3)))
          print_blob = substring(offset, 5999, trim(BlobNoRTF,3))
	     ; print_blob = replace(replace(trim(print_blob,3),char(13),"|"),char(10),"")
        if (size(print_blob) > 0)
 
            col  0 print_blob, crvar
            row +1
        endif
        offset = offset + 5999
    endwhile
 
    		row +1
			;sig = replace (rDATA->ENC[idx].note_sig, "|", char(10))
			;col 0 sig, crvar
			;row + 1
; while the above code commented out will display the sig line exactly as written in the blob ce_event_note, the customer needs
; the information exactly as 4 lines of code below:
 
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
 
 
; for testing only once this is validated then the calls to astream file location will be via operations
; ;with format, separator = " ", check
;  set statx = 0
 
 ; demo file
;
;set  output->temp  = concat("cp $cer_temp/", output->filename," ",output->astream, output->filename)
;call echo (output->temp);
;call dcl( output->temp ,size(output->temp  ), statx)
;set output->temp = ""
;
;set  output->temp  = concat("cp $cer_temp/", output->filenamed," ",output->astream, output->filenamed)
;call echo (output->temp);
;call dcl( output->temp ,size(output->temp  ), statx)
;set output->temp = ""
 
;select into value($poutdev)
;  total_pats =  rDATA->total
;  , total_demo = rDATA->subt_demo
;  , total_dict = rDATA->subt_dict
;with check,  format, separator = " "
 
 
#exit_script
 FREE RECORD rdata
end go

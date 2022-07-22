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
* 		   000 07/10/2018 ARG     	Initial release (Alix Govatsos)                                                   *
 
************************* END OF ALL MODCONTROL BLOCKS *****************************************************************/
 
DROP PROGRAM 	cov_rad_dly_impress_rpt:dba GO
CREATE PROGRAM 	cov_rad_dly_impress_rpt:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date:" = "SYSDATE"
	, "End Date:" = "SYSDATE"
	, "Select an ED:" = 2553913493.00
	, "Exam Modality:" = ""
 
with POUTDEV, pSTART_DATE, pEND_DATE, pFACILITY, Modality
 
/***************************************************************************************
* Prompt Evaluation																	   *
***************************************************************************************/
 
 ; location used for the exam location
if(substring(1,1,reflect(parameter(parameter2($pFACILITY),0))) = "L") ;multiple dispositions were selected
	set FAC_VAR = "in"
	elseif(parameter(parameter2($pFACILITY),1) = 0.0) ;all (any) dispositions were selected
		set FAC_VAR = "!="
	else ;a single value was selected
		set FAC_VAR = "="
endif
 
 ; modality used for the exam qualification on accession nbr
if(substring(1,1,reflect(parameter(parameter2($Modality),0))) = "L") ;multiple dispositions were selected
	set mod_VAR = "in"
	elseif(parameter(parameter2($pFACILITY),1) = 0.0) ;all (any) dispositions were selected
		set mod_VAR = "!="
	else ;a single value was selected
		set mod_VAR = "="
endif
 
 
 
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
	1 location = vc
)
;
;set output->directory = logical("cer_temp")
;set output->filename = concat( format(curdate, "yyyymmdd;;d"), '.vst')
;set output->filenamed = concat('test7_vistacode',format(curdate, "yyyymmdd;;d"), '.del')
;set output->astream = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Radiology/Extracts/Vista/"
;set output->temp_demo = concat('cer_temp:' , 'test7_', format(curdate, "yyyymmdd;;d"), '.vst')
;set output->temp_dict = concat('cer_temp:' , 'test7_vistacode',  format(curdate, "yyyymmdd;;d"), '.del')
 
 
select into "nl:"
from location l, organization org
plan l
where l.location_cd = value ($pfacility)
join org
where org.organization_id = l.organization_id
head l.location_cd
output->location = org.org_name
with nocounter
 
call echorecord (output)
 
 
;;***** declare blob working variables
declare OCFCOMP_VAR = f8 with Constant(uar_get_code_by("MEANING",120,"OCFCOMP")),protect
declare NOCOMP_VAR = f8 with Constant(uar_get_code_by("MEANING",120,"NOCOMP")),protect
declare good_blob = vc with protect
declare print_blob = c120 with protect
declare outbuf = c32768  with protect
declare blobout = vc with protect
declare BlobNoRTF =  c120 with protect
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
 
 
 
RECORD rDATA(
1 ENC[*]						;one occurrence per exam per encouonter per patient
2	ENCNTR_ID	= 	f8
2	PERSON_ID	= 	f8
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
2	FIN	 = 	vc ;	119
2	admit_dt_tm	 = 	dq8
2	admit_date	 = 	c6	 ;	339
2	disch_dt_tm	 = 	dq8
2	disch_date	 = 	c6	 ;	345
2	pat_type_ioe = 	c1	 ;	351
2	MRN	 		= 	vc	 ;	358
2 	RADIOLOGIST_ID	=	VC
2 	rad_dr_name_f	=   vc
2 	rad_dr_name_l  	=  	Vc
2	rad_dr_name 	=  	vc
2 	ATTENDING_ID	=	VC
2   rad_report_id 	= 	f8
2 order_id 			=	f8
2 oid_disp			= 	vc
2 order_mnem		= 	vc
2 order_cat_cd		= 	vc
2 RAD_PROC_TYPE		= 	VC
2 PRINCIPAL_DX		=	VC
2 ADMIT_DX			= 	VC
2 FINAL_DX			= 	VC
2 work_dx			= 	vc
2 event_id			=	f8
2 RESULT_STATUS_CD	= 	F8
2 accession			=   vc
2 accessiond		= 	vc
2 check_out_dt_tm	= 	dq8
2 FACILITY_CD		=	F8
2 FACILITY			=	VC
2 site				= 	vc
2 NU_CD				=	F8
2 NU 				=	VC
2 acc_dt_tm			= 	dq8
2 acc_loc			=   Vc
2 acc_st 			= 	vc
2 acc_type			= 	vc
2 acc_ore			= 	vc
2 pat_type			=	vc
2 pat_type_alias	=	c3
2 pat_type_class	=	vc
2 note_sig			= 	vc
2 exam_status		= 	vc
2 exam_location 	= 	vc
 
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
	  encntr_id = e.encntr_id
	, person_id = e.person_id
	, dob = format(p.birth_dt_tm ,"mm/dd/yyyy;;d")
	, fin = ea.alias
	, cmrn = cnvtalias(pa3.alias, pa3.alias_pool_cd)
	, pat_type = cnvtstring(e.encntr_type_cd)
	, fac = cnvtstring(e.loc_facility_cd)
	, fac_disp = uar_get_code_display(e.loc_facility_cd)
	, nu_disp = uar_get_code_display(e.loc_nurse_unit_cd)
	, reg_dt_tm = e.reg_dt_tm "mm/dd/yyyy hh:mm;;d"
	, dsch_dt_tm = e.disch_dt_tm "mm/dd/yyyy hh:mm;;d"
	, accession = cnvtacc(o.accession)
	, rad_order = uar_get_code_display (o.catalog_cd)
	, order_dt_tm = o.start_dt_tm "mm/dd/yyyy hh:mm;;d"
	, complete_dt_tm = oros.exam_complete_dt_tm "mm/dd/yyyy hh:mm;;d"
	, posted_final_dt_tm = orrs.final_dt_tm "mm/dd/yyyy hh:mm;;d"
	, order_id = o.order_id
	, dictated_dt_tm = oros.dictate_dt_tm "mm/dd/yyyy hh:mm;;d"
	, exam_status = uar_get_code_display(o.exam_status_cd)
	, exam_loc = uar_get_code_display(oros.loc_at_exam_cmplt_cd)
 	, check_out_dt_tm = foe.checkout_dt_tm
 
 
 FROM
	OMF_RADMGMT_ORDER_ST   OROS
	,ENCOUNTER   E
	, person   p
	, encntr_alias   ea
	, person_alias   pa1
	, person_alias   pa3
	, code_value_outbound   cvo
	, orders   ord
	;, PRSNL   PR
	;, PRSNL_ALIAS   PA
	, clinical_event   ce
	, order_radiology   o
	, OMF_RADREPORT_ST ORRS
	, FN_OMF_ENCNTR FOE
 
plan e
 
join oros
 where e.encntr_id = oros.encntr_id
 and   operator(oros.loc_at_exam_cmplt_cd , FAC_VAR, $pFACILITY) ;note this amb loc on cvo table
join foe
where foe.encntr_id = e.encntr_id
 
JOIN  ea where ea.encntr_id = e.encntr_id
 			AND	 EA.ENCNTR_ALIAS_TYPE_CD = FIN_CD
			AND EA.ACTIVE_IND = 1
			AND EA.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
 
join 	p where  p.person_id = e.person_id
and  	p.active_ind = 1
 
JOIN pa1 where e.person_id = pa1.person_id
 			AND pa1.person_alias_type_cd = MRN_CD
			AND pa1.ACTIVE_IND = 1
			AND pa1.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
JOIN   pa3 where e.person_id = pa3.person_id
 			AND pa3.person_alias_type_cd = CMRN_CD
			AND pa3.ACTIVE_IND = 1
			AND pa3.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)
 
join 	CVO
WHERE 	cvo.code_value = oros.loc_at_exam_cmplt_cd
and  	CVO.code_set = 220
AND 	CVO.ALIAS_TYPE_MEANING = "AMBULATORY"
AND 	CVO.contributor_source_cd =         2552933345.00
and	  	SUBSTRING(1,2,CVO.ALIAS) = "ED"
 
 
join  	o
where 	o.encntr_id = e.encntr_id
;and  	o.exam_status_cd in (rad_completed_CD) ;confirm
and 	o.accession = oros.accession_nbr
and   	operator(substring(6,2,oros.accession_nbr) , MOD_VAR, $MODALITY) ;note this amb loc on cvo table
 
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
;and 	substring(6,2,ce.accession_nbr) = 'XR'
and   	operator(substring(6,2,ce.accession_nbr) , MOD_VAR, $MODALITY) ;note this amb loc on cvo table
 
 
 
 
join 	orrs
where 	((o.parent_order_id > 0.00 AND orrs.order_id = o.parent_order_id)
OR 		orrs.order_id = o.order_id)
and 	orrs.order_ID != 0.00
AND 	orrs.final_dt_tm  between cnvtdatetime(start_date ) and cnvtdatetime(end_date)
 
 
ORDER BY
  encntr_id
 ,fin
 ,oros.order_id
 ,oros.final_dt_tm
 ,accession
 ,rad_order
 ,order_id
 ,ce.event_id
 
 
HEAD REPORT
CNT = 0
 
HEAD CE.EVENT_ID  ; need to use this now that the doc license id either star or state ID
 
CNT = CNT + 1
STAT = ALTERLIST (rData->ENC, cnt)
 
 
rDATA->ENC[cnt].ENCNTR_ID = e.encntr_id
rDATA->ENC[cnt].PERSON_ID = e.person_id
rDATA->ENC[cnt].NAME = TRIM(P.name_full_formatted, 3)
rDATA->ENC[cnt].MRN = trim(cnvtalias(pa3.alias, pa3.alias_pool_cd),3)
rDATA->ENC[cnt].FIN =  trim(ea.alias,3)
rDATA->ENC[cnt].DOB = format(p.birth_dt_tm, "MMDDYY;;d") ;dob_year
rDATA->ENC[cnt].birth_dt_tm = p.birth_dt_tm
rDATA->ENC[cnt].disch_dt_tm = e.disch_dt_tm
rDATA->ENC[cnt].admit_dt_tm = e.reg_dt_tm
rDATA->ENC[cnt].FACILITY_CD = E.loc_facility_cd
rDATA->ENC[cnt].FACILITY = cnvtstring(e.loc_facility_cd)
rDATA->ENC[cnt].NU_CD = E.loc_nurse_unit_cd
rDATA->ENC[cnt].NU = UAR_GET_CODE_DISPLAY(E.loc_nurse_unit_cd)
rDATA->ENC[cnt].PAT_TYPE  		=  cnvtstring(e.encntr_type_cd)
rDATA->ENC[cnt].PAT_TYPE_CLASS	= CNVTSTRING(E.encntr_type_class_cD)
rDATA->ENC[cnt].order_id = o.order_id
rDATA->ENC[cnt].oid_disp = build(cnvtstring(cnvtint(o.order_id)))
rDATA->ENC[cnt].event_id = ce.event_id
rDATA->ENC[cnt].RESULT_STATUS_CD = ce.result_status_cd
rDATA->ENC[cnt].accession = ce.accession_nbr
rDATA->ENC[cnt].accessiond = cnvtacc(ce.accession_nbr)
rDATA->ENC[CNT].exam_status = exam_status
rDATA->ENC[CNT].exam_location = exam_loc
rDATA->ENC[CNT].check_out_dt_tm = foe.checkout_dt_tm
 
 foot report
 rDATA->total = cnt
 
WITH NOCOUNTER ; , format, separator = " ", check
 
 IF(CURQUAL = 0)
	GO TO EXIT_SCRIPT
ENDIF
 
 
 
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
rDATA->ENC[d.seq].rad_dr_name_f		= pr.name_first
rDATA->ENC[d.seq].rad_dr_name_l  	= pr.name_last
rDATA->ENC[d.seq].rad_dr_name 		= pr.name_full_formatted
rDATA->ENC[d.seq].order_mnem 		= o.order_mnemonic
rDATA->ENC[d.seq].RAD_PROC_TYPE 	= RAD_PROC_TYPE
rDATA->ENC[d.seq].order_cat_cd  	= cnvtstring(o.catalog_cd)
rDATA->ENC[d.seq].rad_report_id = rr.rad_report_id
 
WITH NOCOUNTER, nullreport ;,  format, separator = " ", check
 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 
SET OcfCD = 0.0
Set stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,OcfCD)
set BlobOut2= fillstring( 32768, ' ' )
 
 
 #exit_script
;IMPRESSION output with signatures
SELECT INTO VALUE ($POUTDEV)
 
FROM
	OMF_RADMGMT_ORDER_ST   OROS
	, ce_blob   cb
	, clinical_event   ce
 
 
 
plan cb
where
	expand(num, 1, size(rDATA->ENC, 5), cb.event_id ,rDATA->ENC[num].event_id)
	and 	cb.VALID_FROM_DT_TM < cnvtdatetime(curdate,curtime3)
	and  	cb.VALID_UNTIL_DT_TM > cnvtdatetime(curdate,curtime3)
	and 	cb.compression_cd = ocfcomp_var
 
 
join ce where ce.event_id = cb.event_id
 AND   ce.RESULT_STATUS_CD in ( auth_ver_cd, altered_cd, modified_cd)
 
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
 
 
  ; col 0 call center ("Roane Medical Center", 0, 125)
  ; row + 1
   col 0 call center ("Rad Impressions for ED Rad Exams", 5, 125)
   row + 1
   col 0 call center (trim(output->location,3) , 5 , 125)
 
   row + 1
col 0 call center (concat("For the dates ",format(start_date, "mm/dd/yyyy;;d"), " thru ",format(end_date, "mm/dd/yyyy;;d")),5,125)
   row + 1
 
 
  head  	cb.event_id
 
 	cntd = cntd + 1
 	num = 0
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
 
 ;		cntx = cntx + 1
   		retlen = 1
    	offset = 0
    	oset = 10 ; print left margin offset
 
	;LINE 1
 	 fac			=   build(replace(substring(1,1,  trim(rDATA->ENC[idx].FACILITY,3)), char(0),  "" ))
 	,PAT_ACCT_NBR   = 	build(concat(trim(rDATA->ENC[idx].fin,3)))
 	,exam_loc 		=   build(concat(trim(rDATA->ENC[idx].exam_location, 3)))
 	,disc_loc		=   build(concat(trim(rDATA->ENC[idx].nu, 3)))
 	,exam_status 	=   build(concat(trim(rDATA->ENC[idx].exam_status,3)))
 	,disch			=   FORMAT(rDATA->ENC[idx].disch_dt_tm, "MM/DD/YYYY HH:MM;;D")
 	,CK_IN_NUM		= 	build(trim(rDATA->ENC[idx].accessiond,3))
 	,CK_out_DT	 	=   FORMAT(rDATA->ENC[idx].check_out_dt_tm, "MM/DD/YYYY HH:MM;;D")
	,pat_type_ioe	= 	trim(replace(trim(rDATA->ENC[idx].pat_type_ioe,3),CHAR(0),""),3)
	,UNIT_NBR		=   concat(trim(rDATA->ENC[idx].FACILITY,3), trim(rDATA->ENC[idx].mrn,3))
	,pat_name 		=   build(replace(trim(rDATA->ENC[idx].NAME,3),CHAR(0),""))
	,pat_type  		=   replace(trim(rDATA->ENC[idx].pat_type,3),CHAR(0),"")
	,RAD_ORD_PROC 	=   substring(1,120, TRIM(rDATA->ENC[idx].order_mnem,3))
     row + 1
 	 col  0 + oset  "Patient: ", PAT_NAME
 	 COL  50 + oset "FIN: ", PAT_ACCT_NBR
 	 COL  75 + oset "ED Check Out: ", CK_out_DT
 	; col 120 "ACC: ", ck_in_num
 	 ROW + 1
 	 COL  50 + oset "Exam Status: ", EXAM_STATUS
 	 COL  75 + oset "Discharge DT: ", CK_out_DT
 	 ROW + 1
 	 col 50 + oset "Exam Location: ", exam_loc
 	 col 75 + oset "Discharge Loc: ", disc_loc
  	 ROW + 1
  	 col 0 + oset  "Exam: ", RAD_ORD_PROC
  	 row + 1
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
    BlobNoRTF =  substring(findstring("IMPRESSION", trim(cnvtupper(BlobNoRTF),3)), size(trim(BlobNoRTF,3)), trim(BlobNoRTF,3))
 
    ;while (offset < size(trim(BlobNoRTF,3)))
     while (offset < size(trim(BlobNoRTF,3)))
          print_blob = substring(offset, 120, trim(BlobNoRTF,3))
	      print_blob = replace(replace(trim(print_blob,3),char(13),"|"),char(10),"")
 
        if (size(print_blob) > 0)
 
            col  0 + oset print_blob, crvar
            row +1
        endif
        offset = offset + 120
    endwhile
    	col  0  + oset "Report End"
    	row + 1
 
 
 foot report
 	rDATA->subt_dict = cntd
 	col 0 call center ("-------------------END OF REPORT-------------------", 0, 125)
    row + 2
 
  WITH nullreport, RDBARRAYFETCH = 1,  maxcol = 150, check, expand = 1
  ,PCFORMAT ("", value(char(32)) ,1,1)
  , maxrow =1
  ,FORMAT = CRSTREAM, formfeed = none
 
 
 
 FREE RECORD rdata
end go
 

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		08/03/2022
	Solution:			Lab
	Source file name:	cov_lab_acumen_pat_data_ext.prg
	Object name:		cov_lab_acumen_pat_data_ext
	Request #:			13324
 
	Program purpose:	Export Patient Data for Acumen Project
 
	Executing from:		CCL
 
 	Special Notes:
	Execute Example:
 
***********************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***********************************************************************************************
 
 Mod   Date	          Developer				 Comment
 ----  ----------	  --------------------	 --------------------------------------------------
 0001  08/03/2022     Dawn Greer, DBA        Original Release
 
***********************************************************************************************/
 
drop program cov_lab_acumen_pat_data_ext go
create program cov_lab_acumen_pat_data_ext
 
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
 
SET startdate = CNVTDATETIME("01-MAR-2022 00:00")
SET enddate = CNVTDATETIME("31-MAR-2022 23:59:59")
 
/****************************************************************************
	Lab Test Orders
*****************************************************************************/
 
;  Set astream path
SET file_var = "Covenant_TestOrders_"
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
 
RECORD Lab_Test_Orders (
	1 output_cnt = i4
	1 list[*]
	    2 Patient_Encounter_ID = C50
	    2 Local_Patient_ID = C50
	    2 Universal_Patient_ID = C50
	    2 Patient_Type_ID = C100
	    2 Patient_Type_Name = C100
	    2 Patient_Care_Facility_ID = C100
	    2 Patient_Care_Facility_Name = C100
	    2 Parent_Order_ID = F8
	    2 Child_Order_ID = F8
	    2 Order_ID_Accession_Number = C50
	    2 Ordering_Provider_ID = F8
	    2 Ordering_Provider_Name = C100
	    2 Test_Order_Date_Time = DQ8
	    2 Scheduled_Date_Time = DQ8
	    2 Ordered_Test_Code = C100
	    2 Ordered_Test_Name = C100
	    2 Ordering_Location_Code = F8
	    2 Ordering_Location_Description = C100
	    2 Order_Comment = C200
	    2 Test_Priority = C50
	    2 Cancelled_Date_Time = DQ8
	    2 Cancelled_Reason = C100
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Lab Test Orders Data ******")
/**************************************************************
 Get Lab Test Orders Data
**************************************************************/
 
SELECT INTO "NL:"
FROM orders ord
,order_action oa_order
,prsnl pr
,encounter enc
,organization org
,encntr_alias fin
,encntr_alias mrn
,person_alias cmrn
,order_detail od_priority
,accession_order_r aor
,order_container_r ocr
,collection_list_container c
,collection_list cl
,order_action oa_cancel
,order_detail od_cancel
PLAN ord WHERE ord.orig_order_dt_tm BETWEEN CNVTDATETIME(startdate) AND CNVTDATETIME(enddate)
	AND ord.order_status_cd IN (2542.00 /*Cancelled*/, 2543.00 /*Completed*/)
	AND ord.catalog_type_cd IN (2513.00 /*Laboratory*/)
JOIN oa_order WHERE ord.order_id = oa_order.order_id
	AND oa_order.action_type_cd IN (2534 /*order*/)
JOIN pr WHERE pr.person_id = oa_order.order_provider_id
JOIN enc WHERE enc.encntr_id = ord.encntr_id
	AND enc.encntr_type_cd NOT IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
			2560523697/*Results Only*/,20058643/*Legacy Data*/)
JOIN org WHERE org.organization_id = enc.organization_id
	AND org.organization_id IN (3234038 /*Claiborne Medical Center*/,
		3144506 /*Cumberland Medical Center*/, 3144501 /*Fort Loudoun Medical Center*/,
		675844 /*Fort Sanders Regional Medical Center*/, 3144505 /*LeConte Medical Center*/,
		3144499 /*Methodist Medical Center*/, 3144503 /*Parkwest Medical Center*/,
		3144504 /*Roane Medical Center*/, 3144502 /*Morristown-Hamblen Healthcare System*/)
JOIN fin WHERE fin.encntr_id = enc.encntr_id
	AND fin.encntr_alias_type_cd = 1077 /*FIN*/
JOIN mrn WHERE mrn.encntr_id = enc.encntr_id
	AND mrn.encntr_alias_type_cd = 1079 /*MRN*/
JOIN cmrn WHERE cmrn.person_id = enc.person_id
	AND cmrn.person_alias_type_cd = 2 /*CMRN*/
JOIN od_priority WHERE od_priority.order_id = OUTERJOIN(ord.order_id)
	AND od_priority.oe_field_meaning = OUTERJOIN("collpri")
JOIN aor WHERE aor.order_id = OUTERJOIN(ord.order_id)
	AND aor.primary_flag = OUTERJOIN(0)
JOIN ocr WHERE ocr.order_id = OUTERJOIN(ord.order_id)
	AND ocr.collection_status_flag != OUTERJOIN(7)
JOIN c WHERE c.container_id = OUTERJOIN(ocr.container_id)
JOIN cl WHERE cl.collection_list_id = OUTERJOIN(c.collection_list_id)
JOIN oa_cancel WHERE oa_cancel.order_id = OUTERJOIN(ord.order_id)
	AND oa_cancel.action_type_cd = OUTERJOIN(2526 /*cancel*/)
JOIN od_cancel WHERE od_cancel.order_id = OUTERJOIN(ord.order_id)
	AND od_cancel.oe_field_meaning = OUTERJOIN("CANCELREASON")
 
/****************************************************************************
	Populate Record structure with Lab Test Orders Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(Lab_Test_Orders->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(Lab_Test_Orders->list, cnt + 9)
	ENDIF
 
	Lab_Test_Orders->list[cnt].Patient_Encounter_ID = TRIM(fin.alias,3)
	Lab_Test_Orders->list[cnt].Local_Patient_ID = TRIM(mrn.alias,3)
	Lab_Test_Orders->list[cnt].Universal_Patient_ID = TRIM(cmrn.alias,3)
	Lab_Test_Orders->list[cnt].Patient_Type_ID = UAR_GET_CODE_DISPLAY(enc.encntr_type_cd)
	Lab_Test_Orders->list[cnt].Patient_Type_Name = UAR_GET_CODE_DESCRIPTION(enc.encntr_type_cd)
	Lab_Test_Orders->list[cnt].Patient_Care_Facility_ID = CNVTSTRING(org.organization_id)
	Lab_Test_Orders->list[cnt].Patient_Care_Facility_Name = TRIM(org.org_name,3)
	Lab_Test_Orders->list[cnt].Parent_Order_ID = ord.order_id
	Lab_Test_Orders->list[cnt].Child_Order_ID = 0.00
	Lab_Test_Orders->list[cnt].Order_ID_Accession_Number = CNVTACC(aor.accession)
	Lab_Test_Orders->list[cnt].Ordering_Provider_ID = oa_order.order_provider_id
	Lab_Test_Orders->list[cnt].Ordering_Provider_Name = TRIM(pr.name_full_formatted,3)
	Lab_Test_Orders->list[cnt].Test_Order_Date_Time = ord.orig_order_dt_tm
	Lab_Test_Orders->list[cnt].Scheduled_Date_Time = cl.collection_list_dt_tm
	Lab_Test_Orders->list[cnt].Ordered_Test_Code = TRIM(ord.order_mnemonic,3)
	Lab_Test_Orders->list[cnt].Ordered_Test_Name = UAR_GET_CODE_DESCRIPTION(ord.catalog_cd)
	Lab_Test_Orders->list[cnt].Ordering_Location_Code = oa_order.order_locn_cd
	Lab_Test_Orders->list[cnt].Ordering_Location_Description = UAR_GET_CODE_DESCRIPTION(oa_order.order_locn_cd)
	Lab_Test_Orders->list[cnt].Test_Priority = TRIM(od_priority.oe_field_display_value,3)
	Lab_Test_Orders->list[cnt].Cancelled_Date_Time = oa_cancel.action_dt_tm
	Lab_Test_Orders->list[cnt].Cancelled_Reason = TRIM(od_cancel.oe_field_display_value,3)
 
FOOT REPORT
 	Lab_Test_Orders->output_cnt = cnt
 	CALL alterlist(Lab_Test_Orders->list, cnt)
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Lab Test Order Comments Data ******")
/**************************************************************
 Get Lab Test Order Comments Data
**************************************************************/
 
SELECT INTO "NL:"
FROM  (dummyt d WITH seq = VALUE(SIZE(Lab_Test_Orders->list,5)))
,order_comment ord_comment
,long_text lt_comment
PLAN d
JOIN ord_comment WHERE ord_comment.order_id = Lab_Test_Orders->list[d.seq].Parent_Order_ID
	AND ord_comment.comment_type_cd = 66.00 /*Order Comment*/
	AND ord_comment.action_sequence IN (SELECT MAX(ocomm.action_sequence)
		FROM order_comment ocomm
		WHERE ocomm.comment_type_cd = 66.00 /*Order Comment*/
		AND ord_comment.order_id = ocomm.order_id)
JOIN lt_comment WHERE ord_comment.long_text_id = lt_comment.long_text_id
 
/****************************************************************************
	Populate Record structure with Lab Test Order Comment Data
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(Lab_Test_Orders->list,5),ord_comment.order_id, Lab_Test_Orders->list[cnt].Parent_Order_ID)
 
 	IF (idx != 0)
		Lab_Test_Orders->list[cnt].Order_Comment = TRIM(REPLACE(REPLACE(lt_comment.long_text,CHAR(13),' '),CHAR(10),' '),3)
	ENDIF
 
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(Lab_Test_Orders->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output Lab Test Orders Data
*****************************************************************************/
 
IF (Lab_Test_Orders->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = Lab_Test_Orders->output_cnt)
 
	HEAD REPORT
		output_rec = build("Patient_Encounter_ID", cov_pipe,
						"Local_Patient_ID", cov_pipe,
						"Universal_Patient_ID", cov_pipe,
						"Patient_Type_ID", cov_pipe,
						"Patient_Type_Name", cov_pipe,
						"Patient_Care_Facility_ID", cov_pipe,
						"Patient_Care_Facility_Name", cov_pipe,
						"Parent_Order_ID", cov_pipe,
						"Child_Order_ID", cov_pipe,
						"Order_ID_Accession_Number", cov_pipe,
						"Ordering_Provider_ID", cov_pipe,
						"Ordering_Provider_Name", cov_pipe,
						"Test_Order_Date_Time", cov_pipe,
						"Scheduled_Date_Time", cov_pipe,
						"Ordered_Test_Code", cov_pipe,
						"Ordered_Test_Name", cov_pipe,
						"Ordering_Location_Code", cov_pipe,
						"Ordering_Location_Description", cov_pipe,
						"Order_Comment", cov_pipe,
						"Test_Priority", cov_pipe,
						"Cancelled_Date_Time", cov_pipe,
						"Cancelled_Reason"
						)
 
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						Lab_Test_Orders->list[dt.seq].Patient_Encounter_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Local_Patient_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Universal_Patient_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Patient_Type_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Patient_Type_Name, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Patient_Care_Facility_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Patient_Care_Facility_Name, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Parent_Order_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Child_Order_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Order_ID_Accession_Number, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Ordering_Provider_ID, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Ordering_Provider_Name, cov_pipe,
						FORMAT(Lab_Test_Orders->list[dt.seq].Test_Order_Date_Time, "MM/DD/YYYY hh:mm:ss;;d"), cov_pipe,
						FORMAT(Lab_Test_Orders->list[dt.seq].Scheduled_Date_Time, "MM/DD/YYYY hh:mm:ss;;d"), cov_pipe,
						Lab_Test_Orders->list[dt.seq].Ordered_Test_Code, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Ordered_Test_Name, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Ordering_Location_Code, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Ordering_Location_Description, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Order_Comment, cov_pipe,
						Lab_Test_Orders->list[dt.seq].Test_Priority, cov_pipe,
						FORMAT(Lab_Test_Orders->list[dt.seq].Cancelled_Date_Time, "MM/DD/YYYY hh:mm:ss;;d"), cov_pipe,
						Lab_Test_Orders->list[dt.seq].Cancelled_Reason
						)
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < Lab_Test_Orders->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",Lab_Test_Orders->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt)
 
	HEAD REPORT
		output_rec = build("Patient_Encounter_ID", cov_pipe,
						"Local_Patient_ID", cov_pipe,
						"Universal_Patient_ID", cov_pipe,
						"Patient_Type_ID", cov_pipe,
						"Patient_Type_Name", cov_pipe,
						"Patient_Care_Facility_ID", cov_pipe,
						"Patient_Care_Facility_Name", cov_pipe,
						"Parent_Order_ID", cov_pipe,
						"Child_Order_ID", cov_pipe,
						"Order_ID_Accession_Number", cov_pipe,
						"Ordering_Provider_ID", cov_pipe,
						"Ordering_Provider_Name", cov_pipe,
						"Test_Order_Date_Time", cov_pipe,
						"Scheduled_Date_Time", cov_pipe,
						"Ordered_Test_Code", cov_pipe,
						"Ordered_Test_Name", cov_pipe,
						"Ordering_Location_Code", cov_pipe,
						"Ordering_Location_Description", cov_pipe,
						"Order_Comment", cov_pipe,
						"Test_Priority", cov_pipe,
						"Cancelled_Date_Time", cov_pipe,
						"Cancelled_Reason"
						)
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
;CALL ECHORECORD (Lab_Test_Orders)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("mv ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
/****************************************************************************
	Lab Result Details
*****************************************************************************/
 
;  Set astream path
SET file_var = "Covenant_ResultDetails_"
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
 
RECORD Lab_Tests_Results (
	1 output_cnt = i4
	1 list[*]
	    2 Patient_Encounter_ID = C50
	    2 Local_Patient_ID = C50
	    2 Universal_Patient_ID = C50
	    2 Parent_Order_ID = F8
	    2 Child_Order_ID = F8
	    2 Order_ID_Accession_Number = C50
	    2 Ordered_Test_Code = C100
	    2 Ordered_Test_Name = C100
	    2 Patient_Location_Code_At_Collection = C100
	    2 Patient_Location_Description_At_Collection = C100
	    2 Collection_Employee_ID = F8
	    2 Collection_Employee_Name = C100
	    2 Collection_Date_Time = DQ8
	    2 Received_In_Lab_Date_Time = DQ8
	    2 Result_Date_Time = DQ8
	    2 Corrected_Date_Time = DQ8
	    2 Send_Out_Flag = C1
	    2 POC_Flag = C20
	    2 Verified_By_Employe_ID = F8
	    2 Verified_By_Username = C100
	    2 Performing_Lab_ID = C100
	    2 Performing_Lab_Name = C100
	    2 Performing_Lab_Department_ID = C100
	    2 Performing_Lab_Department_Name = C100
	    2 Performing_Lab_Sub_Department_ID = C100
	    2 Performing_Lab_Sub_Department_Name = C100
)
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
 
CALL ECHO ("***** Getting Lab Result Order Data ******")
/**************************************************************
 Get Lab Result Order Data
**************************************************************/
 
SELECT INTO "NL:"
FROM orders ord
,order_catalog oc
,encounter enc
,organization org
,encntr_alias fin
,encntr_alias mrn
,person_alias cmrn
PLAN ord WHERE ord.orig_order_dt_tm BETWEEN CNVTDATETIME(startdate) AND CNVTDATETIME(enddate)
	AND ord.order_status_cd IN (2543.00 /*Completed*/)
	AND ord.catalog_type_cd IN (2513.00 /*Laboratory*/)
JOIN oc WHERE ord.catalog_cd = oc.catalog_cd
JOIN enc WHERE enc.encntr_id = ord.encntr_id
	AND enc.encntr_type_cd NOT IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
			2560523697/*Results Only*/,20058643/*Legacy Data*/)
JOIN org WHERE org.organization_id = enc.organization_id
	AND org.organization_id IN (3234038 /*Claiborne Medical Center*/,
		3144506 /*Cumberland Medical Center*/, 3144501 /*Fort Loudoun Medical Center*/,
		675844 /*Fort Sanders Regional Medical Center*/, 3144505 /*LeConte Medical Center*/,
		3144499 /*Methodist Medical Center*/, 3144503 /*Parkwest Medical Center*/,
		3144504 /*Roane Medical Center*/, 3144502 /*Morristown-Hamblen Healthcare System*/)
JOIN fin WHERE fin.encntr_id = enc.encntr_id
	AND fin.encntr_alias_type_cd = 1077 /*FIN*/
JOIN mrn WHERE mrn.encntr_id = enc.encntr_id
	AND mrn.encntr_alias_type_cd = 1079 /*MRN*/
JOIN cmrn WHERE cmrn.person_id = enc.person_id
	AND cmrn.person_alias_type_cd = 2 /*CMRN*/
 
 
/****************************************************************************
	Populate Record structure with Lab Result Order Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(Lab_Tests_Results->list, 10)
 
DETAIL
	cnt = cnt + 1
 
	IF(mod(cnt,10) = 1)
		CALL alterlist(Lab_Tests_Results->list, cnt + 9)
	ENDIF
 
	Lab_Tests_Results->list[cnt].Patient_Encounter_ID = TRIM(fin.alias,3)
	Lab_Tests_Results->list[cnt].Local_Patient_ID = TRIM(mrn.alias,3)
	Lab_Tests_Results->list[cnt].Universal_Patient_ID = TRIM(cmrn.alias,3)
	Lab_Tests_Results->list[cnt].Parent_Order_ID = ord.order_id
	Lab_Tests_Results->list[cnt].Child_Order_ID = 0.00
	Lab_Tests_Results->list[cnt].Ordered_Test_Code = TRIM(ord.order_mnemonic,3)
	Lab_Tests_Results->list[cnt].Ordered_Test_Name = UAR_GET_CODE_DESCRIPTION(ord.catalog_cd)
	Lab_Tests_Results->list[cnt].Send_Out_Flag = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
	Lab_Tests_Results->list[cnt].POC_Flag = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
	Lab_Tests_Results->list[cnt].Performing_Lab_ID = ''
	Lab_Tests_Results->list[cnt].Performing_Lab_Name = ''
	Lab_Tests_Results->list[cnt].Performing_Lab_Department_ID = UAR_GET_CODE_DISPLAY(oc.activity_type_cd)
	Lab_Tests_Results->list[cnt].Performing_Lab_Department_Name = UAR_GET_CODE_DESCRIPTION(oc.activity_type_cd)
	Lab_Tests_Results->list[cnt].Performing_Lab_Sub_Department_ID = UAR_GET_CODE_DISPLAY(oc.activity_subtype_cd)
	Lab_Tests_Results->list[cnt].Performing_Lab_Sub_Department_Name = UAR_GET_CODE_DESCRIPTION(oc.activity_subtype_cd)
 
FOOT REPORT
 	Lab_Tests_Results->output_cnt = cnt
 	CALL alterlist(Lab_Tests_Results->list, cnt)
WITH nocounter
 
CALL ECHO ("***** Getting Lab Result Details Data ******")
/**************************************************************
 Get Lab Result Details Data
**************************************************************/
 
SELECT INTO "NL:"
FROM (dummyt d WITH seq = VALUE(SIZE(Lab_Tests_Results->list,5)))
,accession_order_r aor
,order_container_r ocr
,container_event ce
,prsnl pr_drawn
,result r
,result_event re_perform
,result_event re_verify
,prsnl pr_verify
,result_event re_corrected
PLAN d
JOIN aor WHERE aor.order_id = Lab_Tests_Results->list[d.seq].Parent_Order_ID
	AND aor.primary_flag = 0
JOIN ocr WHERE ocr.order_id = aor.order_id
	AND ocr.collection_status_flag != 7
JOIN ce WHERE ce.container_id = ocr.container_id
	AND ce.event_type_cd = 1807 /*Received*/
JOIN pr_drawn WHERE pr_drawn.person_id = ce.drawn_id
JOIN r WHERE r.order_id = aor.order_id
JOIN re_perform WHERE re_perform.result_id = r.result_id
	AND re_perform.event_type_cd = 1733 /*Performed*/
JOIN re_verify WHERE re_verify.result_id = r.result_id
	AND re_verify.event_type_cd = 1738 /*Verified*/
JOIN pr_verify WHERE pr_verify.person_id = re_verify.event_personnel_id
JOIN re_corrected WHERE re_corrected.result_id = r.result_id
	AND re_corrected.event_type_cd = 1723 /*Corrected*/
 
 
/****************************************************************************
	Populate Record structure with Lab Result Details Data
*****************************************************************************/
DETAIL
	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(Lab_Tests_Results->list,5),aor.order_id, Lab_Tests_Results->list[cnt].parent_order_id)
 
 	IF (idx != 0)
		Lab_Tests_Results->list[idx].Order_ID_Accession_Number = CNVTACC(aor.accession)
		Lab_Tests_Results->list[idx].Patient_Location_Code_At_Collection = UAR_GET_CODE_DISPLAY(ce.current_location_cd)
		Lab_Tests_Results->list[idx].Patient_Location_Description_At_Collection = UAR_GET_CODE_DESCRIPTION(ce.current_location_cd)
		Lab_Tests_Results->list[idx].Collection_Employee_ID = pr_drawn.person_id
		Lab_Tests_Results->list[idx].Collection_Employee_Name = TRIM(pr_drawn.name_full_formatted,3)
		Lab_Tests_Results->list[idx].Collection_Date_Time = ce.drawn_dt_tm
		Lab_Tests_Results->list[idx].Received_In_Lab_Date_Time = ce.received_dt_tm
		Lab_Tests_Results->list[idx].Result_Date_Time = re_perform.event_dt_tm
		Lab_Tests_Results->list[idx].Corrected_Date_Time = re_corrected.event_dt_tm
		Lab_Tests_Results->list[idx].Verified_By_Employe_ID = pr_verify.person_id
		Lab_Tests_Results->list[idx].Verified_By_Username = TRIM(pr_verify.name_full_formatted,3)
	ENDIF
WITH nocounter
 
CALL ECHO (FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;d"))
CALL ECHO (BUILD("**Output_Cnt:",CNVTSTRING(Lab_Tests_Results->output_cnt)))
CALL ECHO ("***** BUILD Output ******")
/****************************************************************************
	Build Output Lab Result Details Data
*****************************************************************************/
 
IF (Lab_Tests_Results->output_cnt > 0)
 	CALL ECHO ("******* Build Output - Data in Record Structure *******")
 
 	SET output_rec = ""
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT d with seq = Lab_Tests_Results->output_cnt)
 
	HEAD REPORT
		output_rec = build("Patient_Encounter_ID", cov_pipe,
						"Local_Patient_ID", cov_pipe,
						"Universal_Patient_ID", cov_pipe,
						"Parent_Order_ID", cov_pipe,
						"Child_Order_ID", cov_pipe,
						"Order_ID_Accession_Number", cov_pipe,
						"Ordered_Test_Code", cov_pipe,
						"Ordered_Test_Name", cov_pipe,
						"Patient_Location_Code_At_Collection", cov_pipe,
						"Patient_Location_Description_At_Collection", cov_pipe,
						"Collection_Employee_ID", cov_pipe,
						"Collection_Employee_Name", cov_pipe,
						"Collection_Date_Time", cov_pipe,
						"Received_In_Lab_Date_Time", cov_pipe,
						"Result_Date_Time", cov_pipe,
						"Corrected_Date_Time", cov_pipe,
						"Send_Out_Flag", cov_pipe,
						"POC_Flag", cov_pipe,
						"Verified_By_Employe_ID", cov_pipe,
						"Verified_By_Username", cov_pipe,
						"Performing_Lab_ID", cov_pipe,
						"Performing_Lab_Name", cov_pipe,
						"Performing_Lab_Department_ID", cov_pipe,
						"Performing_Lab_Department_Name", cov_pipe,
						"Performing_Lab_Sub_Department_ID", cov_pipe,
						"Performing_Lab_Sub_Department_Name"
						)
 
		col 0 output_rec
		row + 1
 
	head d.seq
		output_rec = ""
		output_rec = build(output_rec,
						Lab_Tests_Results->list[d.seq].Patient_Encounter_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Local_Patient_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Universal_Patient_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Parent_Order_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Child_Order_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Order_ID_Accession_Number, cov_pipe,
						Lab_Tests_Results->list[d.seq].Ordered_Test_Code, cov_pipe,
						Lab_Tests_Results->list[d.seq].Ordered_Test_Name, cov_pipe,
						Lab_Tests_Results->list[d.seq].Patient_Location_Code_At_Collection, cov_pipe,
						Lab_Tests_Results->list[d.seq].Patient_Location_Description_At_Collection, cov_pipe,
						Lab_Tests_Results->list[d.seq].Collection_Employee_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Collection_Employee_Name, cov_pipe,
						Lab_Tests_Results->list[d.seq].Collection_Date_Time, cov_pipe,
						Lab_Tests_Results->list[d.seq].Received_In_Lab_Date_Time, cov_pipe,
						Lab_Tests_Results->list[d.seq].Result_Date_Time, cov_pipe,
						Lab_Tests_Results->list[d.seq].Corrected_Date_Time, cov_pipe,
						Lab_Tests_Results->list[d.seq].Send_Out_Flag, cov_pipe,
						Lab_Tests_Results->list[d.seq].POC_Flag, cov_pipe,
						Lab_Tests_Results->list[d.seq].Verified_By_Employe_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Verified_By_Username, cov_pipe,
						Lab_Tests_Results->list[d.seq].Performing_Lab_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Performing_Lab_Name, cov_pipe,
						Lab_Tests_Results->list[d.seq].Performing_Lab_Department_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Performing_Lab_Department_Name, cov_pipe,
						Lab_Tests_Results->list[d.seq].Performing_Lab_Sub_Department_ID, cov_pipe,
						Lab_Tests_Results->list[d.seq].Performing_Lab_Sub_Department_Name
						)
 
		output_rec = trim(output_rec,3)
 
	FOOT d.seq
		col 0 output_rec
		IF (d.seq < Lab_Tests_Results->output_cnt) row + 1 ELSE row + 0 ENDIF
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
ELSE
 	CALL ECHO ("******* Build Output - Headers when no data ******")
 
 	SET output_rec = ""
 
 	CALL ECHO (BUILD("**Output_Cnt: ",Lab_Tests_Results->output_cnt))
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT d)
 
	HEAD REPORT
		output_rec = build("Patient_Encounter_ID", cov_pipe,
						"Local_Patient_ID", cov_pipe,
						"Universal_Patient_ID", cov_pipe,
						"Patient_Type_ID", cov_pipe,
						"Patient_Type_Name", cov_pipe,
						"Patient_Care_Facility_ID", cov_pipe,
						"Patient_Care_Facility_Name", cov_pipe,
						"Parent_Order_ID", cov_pipe,
						"Child_Order_ID", cov_pipe,
						"Order_ID_Accession_Number", cov_pipe,
						"Ordering_Provider_ID", cov_pipe,
						"Ordering_Provider_Name", cov_pipe,
						"Test_Order_Date_Time", cov_pipe,
						"Scheduled_Date_Time", cov_pipe,
						"Ordered_Test_Code", cov_pipe,
						"Ordered_Test_Name", cov_pipe,
						"Ordering_Location_Code", cov_pipe,
						"Ordering_Location_Description", cov_pipe,
						"Order_Comment", cov_pipe,
						"Test_Priority", cov_pipe,
						"Cancelled_Date_Time", cov_pipe,
						"Cancelled_Reason"
						)
 		col 0 output_rec
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
ENDIF
 
CALL ECHORECORD (Lab_Tests_Results)
 
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

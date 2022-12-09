/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			David Baumgardner
	Date Written:		September 2019
	Solution:
	Source file name:  	cov_amb_diaagg_rpt.prg
	Object name:		cov_amb_diaagg_rpt
	Request#:
 
	Program purpose:	Report the COV Ambulatory Orders - Diagnostic Aggregate report
	Executing from:		CCL/DA2/Ambulatory Folder
  	Special Notes:
  		This is to be a CCL version of the Diagnostics Aggregate report
		to replace the business objects report.  This should be a solution
		that runs much quicker.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
07/22/20	David Baumgardner		CR6588 - add communication type to the report.
08/19/20	David Baumgardner		Adding the schedule tat data per CR 6766
06/01/21	David Baumgardner		Remove the description from the file for typo and not needed.  Pasted into the Special Notes
										Previously :
											This is to be a CCL version of the Diagnostics Aggregate report
											to replace the business objects report.  This should be a solution
											that runs much quicker.
10/20/21	David Baumgardner		Adding in the R2W piece to put this report out into the Astream folders
******************************************************************************/
 
DROP PROGRAM cov_amb_diaagg_rpt_test GO
CREATE PROGRAM cov_amb_diaagg_rpt_test
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Provider:" = 0
	, "Order Status" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "CMGExport" = "0"
 
with OUTDEV, userFacility, userProvider, orderStatus, startDate, endDate,
	CMGExport
 
declare num					= i4 with noconstant(0)
declare op_facility_var		= c2 with noconstant("")
declare op_status_var		= c2 with noconstant("")
declare op_provider_var		= c2 with noconstant("")
declare schedauthnbr_var			= f8 with constant(124.00)
declare reqstartdttm_var			= f8 with constant(51.00)
 
;10/20/21
;setup file path information
declare file_var						= vc with constant(build(format(curdate, "mm-dd-yyyy;;d"), "_cov_amb_diaagg_rpt.csv")) ;013
 
declare temppath_var					= vc with constant(build("cer_temp:", file_var)) ;013
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var)) ;013
 
 
;declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
;															 	 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/CernerCCL/", file_var))
 
declare cmd								= vc with noconstant("") ;013
declare len								= i4 with noconstant(0) ;013
declare stat							= i4 with noconstant(0) ;013
DECLARE bdate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE edate	 = f8 WITH NOCONSTANT(0.0), PROTECT
 
set output_var = value(temppath_var)
 
record orderencounter (
  1 olist[*]
    2 provider = c40
    2 facility = c40
    2 patient_name = c40
    2 patient_dob = dq8
    2 fin = c20
    2 encounter_id = f8
    2 order_id = f8
    2 order_date = dq8
    2 days_outstanding = i4
    2 time_frame = i4
    2 sched_appt = dq8
    2 status_date = dq8
    2 order_status = c15
    2 order_desc = c40
    2 future_loc = c40
    2 sched_loc = c40
    2 auth_num = c20
    2 comments = c100
    2 communication_type = f8
    /*next fields are to work with schedule tat information 08/19/20*/
    2 sa_beg_dt_tm = dq8
    2 appt_tat_days = i4
    2 sch_tat_days = i4
    2 auth_tat_days = i4
)
 
;002 update the edate and bdate to pull for 30 days from now for the export.
if($CMGExport = "0")
	SET bdate = CNVTDATETIME($startDate)
	SET edate = CNVTDATETIME($endDate)
else
	SET bdate = CNVTDATETIME(CURDATE-30, 0)
	SET edate = CNVTDATETIME(CURDATE,235959)
endif
 
; set the variable for the OPERATOR for the facility
if (substring(1, 1, reflect(parameter(parameter2($userFacility), 0))) = "L") ; multiple values
    set op_facility_var = "IN"
elseif (parameter(parameter2($userFacility), 1) = 0.0) ; any/no value
    set op_facility_var = "!="
else ; single value
    set op_facility_var = "="
endif
 
; set the variable for the OPERATOR for the order status
if (substring(1, 1, reflect(parameter(parameter2($orderStatus), 0))) = "L") ; multiple values
    set op_status_var = "IN"
elseif (parameter(parameter2($orderStatus), 1) = 0.0) ; any/no value
    set op_status_var = "!="
else ; single value
    set op_status_var = "="
endif
 
; set the variable for the OPERATOR for the provider
if (substring(1, 1, reflect(parameter(parameter2($userProvider), 0))) = "L") ; multiple values
    set op_provider_var = "IN"
elseif (parameter(parameter2($userProvider), 1) = 0.0) ; any/no value
    set op_provider_var = "!="
else ; single value
    set op_provider_var = "="
endif
 
 
 
 
/*Build the main data for the record of the report*/
SELECT DISTINCT INTO $OUTDEV
	FACILITY = UAR_GET_CODE_DESCRIPTION(E.LOC_FACILITY_CD)
	, ORDER_PROVIDER = OP.name_full_formatted
	, PATIENT = P.name_full_formatted
	, DOB = cnvtdatetimeutc (P.birth_dt_tm, 1)
	, ORDER_ID = O.order_id
	, ORDER_DATE = O.ORIG_ORDER_DT_TM
	, ORDER_STATUS = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD)
	, ORDER_DESCRIPTION = OC.description
	, FUTURE_LOCATION = UAR_GET_CODE_DESCRIPTION(O.future_location_facility_cd)
	, OD.oe_field_display_value
	, OFI.order_future_info_id
FROM
	ENCOUNTER   E
	, ORDERS   O
	, ORDER_DETAIL   OD
	, PERSON   P
	, PERSON   OP
	, ORDER_CATALOG   OC
	, ORDER_ACTION   OA
	, ORDER_ACTION	OA_COMPLETE
	, ORDER_ACTION	OA_DISCONTINUE
	, ORDER_ACTION	OA_CANCEL
	, ORDER_ACTION	OA_VOID
	, ORDER_FUTURE_INFO OFI
PLAN E WHERE OPERATOR(E.LOC_FACILITY_CD , op_facility_var, $userFacility)
JOIN O WHERE O.originating_encntr_id = E.encntr_id
JOIN OD WHERE OUTERJOIN(O.ORDER_ID) = OD.order_ID
	AND OD.oe_field_MEANING IN ('REQSTARTDTTM')
JOIN P WHERE P.PERSON_ID = OUTERJOIN(O.PERSON_ID)
JOIN OC WHERE OC.CATALOG_CD = O.catalog_cd
JOIN OA WHERE OA.order_id = OUTERJOIN(O.ORDER_ID)
JOIN OA_COMPLETE WHERE (OA_COMPLETE.ORDER_ID = OUTERJOIN(O.order_id)
	AND OA_COMPLETE.ACTION_TYPE_cd = OUTERJOIN(2529.00))
JOIN OA_DISCONTINUE WHERE (OA_DISCONTINUE.ORDER_ID = OUTERJOIN(O.order_id)
	AND OA_DISCONTINUE.ACTION_TYPE_cd = OUTERJOIN(2532.00))
JOIN OA_CANCEL WHERE (OA_CANCEL.ORDER_ID = OUTERJOIN(O.order_id)
	AND OA_CANCEL.ACTION_TYPE_cd = OUTERJOIN(2526.00))
JOIN OA_VOID WHERE (OA_VOID.ORDER_ID = OUTERJOIN(O.order_id)
	AND OA_VOID.ACTION_TYPE_cd = OUTERJOIN(2530.00))
JOIN OP WHERE OP.PERSON_ID = OA.order_provider_id
	AND OPERATOR(OA.order_provider_id , op_provider_var, $userProvider)
JOIN OFI WHERE OFI.order_id = OUTERJOIN(O.order_id)
	AND OPERATOR(O.ORDER_STATUS_CD , op_status_var, $orderStatus)
	AND O.ORIG_ORDER_DT_TM BETWEEN cnvtdatetime(bdate) AND cnvtdatetime(edate)
	AND OC.CATALOG_TYPE_CD = 2517 ; code this to only report Radiology
 
ORDER BY
	OP.name_full_formatted
	, P.name_full_formatted
	, O.ORIG_ORDER_DT_TM
	, O.order_id
 
 
head report
    ocnt = 0
    stat = alterlist(orderEncounter->olist,50)
head o.order_id
	ocnt = ocnt + 1
	if(mod(ocnt,10)=1 and ocnt > 50)
		stat = alterlist(orderEncounter->olist,ocnt+9)
	endif
	case(ORDER_STATUS)
		OF "Voided":
			orderencounter->olist[ocnt].status_date = OA_VOID.action_dt_tm
			orderencounter->olist[ocnt].days_outstanding = ROUND(DATETIMEDIFF(OA_VOID.action_dt_tm,ORDER_DATE,1),0)
		OF "Completed":
			orderencounter->olist[ocnt].status_date = OA_COMPLETE.action_dt_tm
			orderencounter->olist[ocnt].days_outstanding = ROUND(DATETIMEDIFF(OA_COMPLETE.action_dt_tm,ORDER_DATE,1),0)
		OF "Discontinued":
			orderencounter->olist[ocnt].status_date = OA_DISCONTINUE.action_dt_tm
			orderencounter->olist[ocnt].days_outstanding = ROUND(DATETIMEDIFF(OA_DISCONTINUE.action_dt_tm,ORDER_DATE,1),0)
		OF "Canceled":
 
			orderencounter->olist[ocnt].status_date = OA_CANCEL.action_dt_tm
			orderencounter->olist[ocnt].days_outstanding = ROUND(DATETIMEDIFF(OA_CANCEL.action_dt_tm,ORDER_DATE,1),0)
		ELSE
			if(OD.oe_field_dt_tm_value != 0)
				orderencounter->olist[ocnt].days_outstanding = ROUND(DATETIMEDIFF(OD.oe_field_dt_tm_value,ORDER_DATE,1),0)
			else
				orderencounter->olist[ocnt].days_outstanding = ROUND(DATETIMEDIFF(CNVTDATETIME(CURDATE,CURTIME3),ORDER_DATE,1),0)
			endif
			orderencounter->olist[ocnt].status_date = null
 
	endcase
	orderencounter->olist[ocnt].sched_appt = OD.oe_field_dt_tm_value
	orderencounter->olist[ocnt].provider = ORDER_PROVIDER
	orderencounter->olist[ocnt].facility = FACILITY
	orderencounter->olist[ocnt].patient_name = PATIENT
	orderencounter->olist[ocnt].patient_dob = DOB
	orderencounter->olist[ocnt].order_id = ORDER_ID
	orderencounter->olist[ocnt].order_date = ORDER_DATE
	orderencounter->olist[ocnt].future_loc = FUTURE_LOCATION
	orderencounter->olist[ocnt].order_status = ORDER_STATUS
	orderencounter->olist[ocnt].order_desc = ORDER_DESCRIPTION
	orderencounter->olist[ocnt].communication_type = OA.communication_type_cd
	orderencounter->olist[ocnt].encounter_id = E.encntr_id
;	orderencounter->olist[ocnt].auth_num = OD.oe_field_display_value  will populate below.
foot report
	stat = alterlist(orderEncounter->olist, ocnt)
 
WITH nocounter, separator=" ", format, time = 500
 
/*Build the order FIN data*/
SELECT INTO $outdev
FROM ORDERS O
	, (LEFT JOIN ENCNTR_ALIAS EA ON O.encntr_id = EA.encntr_id)
WHERE
	expand(num, 1, size(orderencounter->olist, 5), O.order_id, orderencounter->olist[num].order_id)
    AND EA.active_ind = 1
	AND EA.end_effective_dt_tm > SYSDATE
	AND EA.ENCNTR_ALIAS_TYPE_CD = 1077
 
head O.order_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(orderencounter->olist, 5), O.order_id, orderencounter->olist[numx].order_id)
 
detail
	if (idx > 0)
		orderencounter->olist[idx].fin = EA.ALIAS
	endif
foot O.order_id
	orderencounter->olist[idx].fin = EA.ALIAS
 
WITH nocounter, separator=" ", format, time = 500, EXPAND = 1
 
 
/*Build the order detail for auth numbers*/
SELECT INTO $outdev
FROM ORDER_DETAIL OD
WHERE
	expand(num, 1, size(orderencounter->olist, 5), OD.order_id, orderencounter->olist[num].order_id)
	AND OD.oe_field_MEANING IN ('PRIORAUTH','SCHEDAUTHNBR')
 
head OD.order_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(orderencounter->olist, 5), OD.order_id, orderencounter->olist[numx].order_id)
 
detail
	if (idx > 0)
		orderencounter->olist[idx].auth_num = OD.oe_field_display_value
	endif
foot OD.order_id
	orderencounter->olist[idx].auth_num = OD.oe_field_display_value
 
WITH nocounter, separator=" ", format, time = 500, EXPAND = 1
 
/*Build the scheduled order data*/
SELECT INTO $outdev
FROM ORDER_DETAIL OD
	, (LEFT JOIN ORDER_ACTION ORDER_ACTION_ALL_GENERIC ON ORDER_ACTION_ALL_GENERIC.ORDER_ID = OD.ORDER_ID)
  	, (LEFT JOIN CODE_VALUE CV_ORD_ACTION_TYPE ON CV_ORD_ACTION_TYPE.CODE_VALUE = ORDER_ACTION_ALL_GENERIC.ACTION_TYPE_CD)
WHERE
	expand(num, 1, size(orderencounter->olist, 5), OD.order_id, orderencounter->olist[num].order_id)
	AND (OD.action_sequence = (SELECT MAX(SOD.ACTION_SEQUENCE)
                FROM ORDER_DETAIL SOD
                WHERE OD.ORDER_ID = SOD.ORDER_ID
                AND OD.OE_FIELD_MEANING = SOD.OE_FIELD_MEANING)  )
    AND OD.oe_field_meaning IN ('REQSTARTDTTM')
    AND ORDER_ACTION_ALL_GENERIC.ORDER_ID = OD.order_id
    AND CV_ORD_ACTION_TYPE.CODE_SET = 6003
 
head OD.order_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(orderencounter->olist, 5), OD.order_id, orderencounter->olist[numx].order_id)
 
detail
	if (idx > 0)
		orderencounter->olist[idx].sched_appt = OD.oe_field_dt_tm_value
		if(od.oe_field_dt_tm_value)
			orderencounter->olist[idx].time_frame = ROUND(DATETIMEDIFF(OD.oe_field_dt_tm_value,orderencounter->olist[idx].
			order_date,1),0)
		endif
		if(orderencounter->olist[idx].status_date != null)
			orderencounter->olist[idx].days_outstanding =
				ROUND(DATETIMEDIFF(orderencounter->olist[idx].status_date,orderencounter->olist[idx].order_date,1),0)
		ELSE
			if(OD.oe_field_dt_tm_value != 0)
				orderencounter->olist[idx].days_outstanding =
					ROUND(DATETIMEDIFF(OD.oe_field_dt_tm_value,orderencounter->olist[idx].order_date,1),0)
			else
				orderencounter->olist[idx].days_outstanding =
					ROUND(DATETIMEDIFF(CNVTDATETIME(CURDATE,CURTIME3),orderencounter->olist[idx].order_date,1),0)
			endif
			orderencounter->olist[idx].status_date = null
		endif
	endif
foot OD.order_id
	orderencounter->olist[idx].sched_appt = OD.oe_field_dt_tm_value
 
WITH nocounter, separator=" ", format, time = 500, EXPAND = 1
 
/*Build Schedule Appt data*/
SELECT sa.beg_dt_tm, sa.encntr_id
FROM
SCH_APPT sa
 
WHERE
	expand(num, 1, size(orderencounter->olist, 5), sa.encntr_id, orderencounter->olist[num].encounter_id)
head sa.encntr_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(orderencounter->olist, 5), sa.encntr_id, orderencounter->olist[numx].encounter_id)
detail
	while (idx > 0)
		orderencounter->olist[idx].sa_beg_dt_tm = sa.beg_dt_tm
		;moving it one line
		idx = locateval(numx, idx+1, size(orderencounter->olist, 5), sa.encntr_id, orderencounter->olist[numx].encounter_id)
	endwhile
WITH nocounter, separator=" ", format, time = 500, expand = 1
 
/*Build the schedule data*/
SELECT *
FROM
SCH_EVENT_ATTACH sea
, (left join SCH_EVENT sev on sev.sch_event_id = sea.sch_event_id
	and sev.active_ind = 1)
, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
, (left join ORDER_DETAIL OD on OD.order_id = sea.order_id
	and	od.oe_field_meaning_id = reqstartdttm_var)
, (inner join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sev.sch_event_id
	and seva2.action_meaning = "CONFIRM" ;009
	and seva2.action_dt_tm = (
		select max(action_dt_tm)
		from SCH_EVENT_ACTION
		where
			sch_event_id = seva2.sch_event_id
			and action_meaning = "CONFIRM" ;009
			and active_ind = 1
		group by
			sch_event_id
	)
	and seva2.active_ind = 1
	)
, (left join ORDER_DETAIL od3 on od3.order_id = SEA.order_id
				and od3.oe_field_meaning_id = schedauthnbr_var)
WHERE
	expand (num,1,size(orderencounter->olist, 5), SEA.order_id, orderencounter->olist[num].order_id)
	AND sea.active_ind =1
head sea.order_id
	numx = 0
	idx = 0
	sample = 0
	idx = locateval(numx, 1, size(orderencounter->olist, 5), sea.order_id, orderencounter->olist[numx].order_id)
detail
	while (idx > 0)
		orderencounter->olist[idx].appt_tat_days = if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
													and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))
														datetimediff(orderencounter->olist[idx].sa_beg_dt_tm, sen.earliest_dt_tm)
													endif
		orderencounter->olist[idx].sch_tat_days = datetimediff(seva2.action_dt_tm, od.oe_field_dt_tm_value)
		orderencounter->olist[idx].auth_tat_days = if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
													and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100"))
													and (od3.updt_dt_tm > 0))
														datetimediff(od3.updt_dt_tm, sen.earliest_dt_tm)
													endif
		idx = locateval(numx, idx+1, size(orderencounter->olist, 5), sea.order_id, orderencounter->olist[numx].order_id)
	endwhile
WITH nocounter, separator=" ", format, time = 500, expand = 1
 
 
/*Build the comment data.  This is a little different due to the nature of the blob data type.*/
SELECT INTO $outdev
FROM ORDER_COMMENT OC
		, (left join LONG_TEXT LT on OC.long_text_id = LT.long_text_id)
WHERE
	expand(num, 1, size(orderencounter->olist, 5), OC.order_id, orderencounter->olist[num].order_id)
 
head OC.order_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(orderencounter->olist, 5), OC.order_id, orderencounter->olist[numx].order_id)
detail
	if (idx > 0)
		orderencounter->olist[idx].comments = replace(replace(substring(0,100,LT.long_text), char(13), " " ,0), char(10), " ",0)
	endif
foot OC.order_id
	orderencounter->olist[idx].comments = replace(replace(substring(0,100,LT.long_text), char(13), " " ,0), char(10), " ",0)
WITH nocounter, separator=" ", format, time = 500, expand = 1
 
/*If the users output is set to MINE use the standard output for the users.  Otherwise use the Layout Builder version.*/
if ($CMGExport = "0")
 
	CALL OUTPUT_RECORD_SPREADSHEET(null)
else
	CALL OUTPUT_ASTREAM(null)
endif
 
 
/*
 Output to the spreadsheet.  This will enable the users to use Excel
*/
SUBROUTINE OUTPUT_RECORD_SPREADSHEET(null)
 
 
	SELECT DISTINCT INTO $outdev
	FACILITY = orderencounter->olist[D1.SEQ].facility
	,ORDERING_PROVIDER = orderencounter->olist[D1.SEQ].provider
	,PATIENT = orderencounter->olist[D1.SEQ].patient_name
	,DOB = FORMAT(orderencounter->olist[D1.SEQ].patient_dob,"mm/dd/yyyy;;d")
	,FIN = SUBSTRING(1, 30, ORDERENCOUNTER->olist[D1.SEQ].fin)
	,OrderID = orderencounter->olist[D1.SEQ].order_id
	,ORDER_DATE = FORMAT(orderencounter->olist[D1.SEQ].order_date,"mm/dd/yyyy;;d")
	,DAYS_OUTSTANDING =orderencounter->olist[D1.SEQ].days_outstanding
	,TIME_FRAME = orderencounter->olist[D1.SEQ].time_frame
	,SCHED_APPT = FORMAT(orderencounter->olist[D1.SEQ].sched_appt,"mm/dd/yyyy;;d")
	,STATUS_DATE = FORMAT(orderencounter->olist[D1.SEQ].status_date,"mm/dd/yyyy hh:mm:ss a")
	,ORDER_STATUS = orderencounter->olist[D1.SEQ].order_status
	,ORDER_DESC = orderencounter->olist[D1.SEQ].order_desc
	,FUTURE_LOCATION = orderencounter->olist[D1.SEQ].future_loc
	,AUTH_NUMBER = SUBSTRING(1, 30, ORDERENCOUNTER->olist[D1.SEQ].auth_num)
	,COMMUNICATION_TYPE = UAR_GET_CODE_DESCRIPTION(orderencounter->olist[D1.SEQ].communication_type)
	,COMMENTS = SUBSTRING(1, 100, ORDERENCOUNTER->olist[D1.SEQ].comments)
	,APPT_TAT_DAYS = orderencounter->olist[D1.SEQ].appt_tat_days
	,AUTH_TAT_DAYS = orderencounter->olist[D1.SEQ].auth_tat_days
	,SCH_TAT_DAYS = orderencounter->olist[D1.SEQ].sch_tat_days
 
	FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderencounter->olist, 5)))
 
	PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
END
 
 
 
	/*10/20/21 David Baumgardner */
SUBROUTINE OUTPUT_ASTREAM(null)
 
 
	SELECT DISTINCT INTO value(output_var)
	FACILITY = orderencounter->olist[D1.SEQ].facility
	,ORDERING_PROVIDER = orderencounter->olist[D1.SEQ].provider
	,PATIENT = orderencounter->olist[D1.SEQ].patient_name
	,DOB = FORMAT(orderencounter->olist[D1.SEQ].patient_dob,"mm/dd/yyyy;;d")
	,FIN = SUBSTRING(1, 30, ORDERENCOUNTER->olist[D1.SEQ].fin)
	,OrderID = orderencounter->olist[D1.SEQ].order_id
	,ORDER_DATE = FORMAT(orderencounter->olist[D1.SEQ].order_date,"mm/dd/yyyy;;d")
	,DAYS_OUTSTANDING =orderencounter->olist[D1.SEQ].days_outstanding
	,TIME_FRAME = orderencounter->olist[D1.SEQ].time_frame
	,SCHED_APPT = FORMAT(orderencounter->olist[D1.SEQ].sched_appt,"mm/dd/yyyy;;d")
	,STATUS_DATE = FORMAT(orderencounter->olist[D1.SEQ].status_date,"mm/dd/yyyy hh:mm:ss a")
	,ORDER_STATUS = orderencounter->olist[D1.SEQ].order_status
	,ORDER_DESC = orderencounter->olist[D1.SEQ].order_desc
	,FUTURE_LOCATION = orderencounter->olist[D1.SEQ].future_loc
	,AUTH_NUMBER = SUBSTRING(1, 30, ORDERENCOUNTER->olist[D1.SEQ].auth_num)
	,COMMUNICATION_TYPE = UAR_GET_CODE_DESCRIPTION(orderencounter->olist[D1.SEQ].communication_type)
	,COMMENTS = SUBSTRING(1, 100, ORDERENCOUNTER->olist[D1.SEQ].comments)
	,APPT_TAT_DAYS = orderencounter->olist[D1.SEQ].appt_tat_days
	,AUTH_TAT_DAYS = orderencounter->olist[D1.SEQ].auth_tat_days
	,SCH_TAT_DAYS = orderencounter->olist[D1.SEQ].sch_tat_days
 
	FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderencounter->olist, 5)))
 
	PLAN D1
 
	WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR=",", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
END
 
END GO
 
 
 

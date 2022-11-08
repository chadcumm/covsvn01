/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			David Baumgardner
	Date Written:		October 2019
	Solution:
	Source file name:  	cov_amb_lab_aggregate_rpt.prg
	Object name:		cov_amb_lab_aggregate_rpt
	Request#:
 
	Program purpose:	Report the COV Ambulatory Orders - Lab Aggregate report
	Executing from:		CCL/DA2/Ambulatory Folder
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod	Mod Date	Developer			     Comment
	----------	--------------------	------------------------------------------
001	01/29/20	David Baumgardner		Endorsement not showing pulled out to its own query.
002	05/08/20	David Baumgardner		CR9551 CR6588 Update to add communication type and grid output.
003	06/03/21	David Baumgardner		CR7473 Speed issue and client bill
004 08/26/21	David Baumgardner		CR11113 Issue with some performing locations and provider endorsements not pulling
										for every lab order.
005 11/04/21	David Baumgardner		Update to exclude test patients and extend time limit to 5000 from 500.
006 10/25/2022  Dawn Greer, DBA         CR 13882 - changed the link between from order and encounter.
                                        Changed from o.originating_encnter_id = e.encntr_id
                                        to o.encntr_id = e.encntr_id
******************************************************************************/
 
DROP PROGRAM cov_amb_lab_aggregate_rpt GO
CREATE PROGRAM cov_amb_lab_aggregate_rpt
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Provider:" = 0
	, "Order Status" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Output" = "Grid"
 
with OUTDEV, userFacility, userProvider, orderStatus, startDate, endDate,
	userOutput
 
; 05/08/20 DWB If calling for report version call the layout builder version and exit.  It will call this program with the grid
; 			version so it can parse data into report format.
if($userOutput = "Report")
 
		EXECUTE COV_AMB_LAB_AGG_RPT_LB $OUTDEV, $userFacility, $userProvider, $orderStatus,
			$startDate, $endDate
	RETURN
endif
 
declare num					= i4 with noconstant(0)
declare op_facility_var		= c2 with noconstant("")
declare op_status_var		= c2 with noconstant("")
declare op_provider_var		= c2 with noconstant("")
declare ocnt				= i4 with noconstant(0)
 
record orderencounter (
  1 olist[*]
  /*01/29/20 added encounter_id for the endorsement data*/
  	2 encounter_id = f8
    2 provider = c30
    2 facility = c30
    2 patient_name = c40
    2 patient_dob = dq8
    2 fin = c12
    2 order_id = f8
    2 order_date = dq8
    2 days_outstanding = i4
    2 time_frame = i4
    2 sched_appt = dq8
    2 status_date = dq8
    2 order_status = c15
    2 order_desc = vc
    2 future_loc = c30
    2 sched_loc = c30
    2 endorsed_by = c30
    2 endorsed_date = dq8
    2 comments = c100
    2 schedule_location = c30
    2 auth_num = c20
    2 drawn_date = dq8
    2 container_id = f8
    2 communication_type = f8
)
 
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
	, DOB = cnvtdatetimeutc(P.birth_dt_tm,1)
	, ORDER_ID = O.order_id
	, ORDER_DATE = O.ORIG_ORDER_DT_TM
	, ORDER_STATUS = UAR_GET_CODE_DISPLAY(O.ORDER_STATUS_CD)
	, ORDER_DESCRIPTION = OC.description
	, OFI.order_future_info_id
FROM
	ENCOUNTER   E
	, ORDERS   O
	, ORDER_DETAIL   OD
	, PERSON   P
	, PERSON   OP
	, ORDER_CATALOG   OC
	, ORDER_ACTION   OA
	, ORDER_FUTURE_INFO OFI
	, ENCNTR_ALIAS EA
;	, CODE_VALUE CV_ENCNTR_ALIAS_TYPE
PLAN E WHERE OPERATOR(E.LOC_FACILITY_CD , op_facility_var, $userFacility)
JOIN EA WHERE (EA.encntr_id = E.encntr_id
	AND EA.active_ind = 1
	and ea.encntr_alias_type_cd = 1077)
; 003
;JOIN CV_ENCNTR_ALIAS_TYPE WHERE CV_ENCNTR_ALIAS_TYPE.code_value = EA.encntr_alias_type_cd
;	AND (CV_ENCNTR_ALIAS_TYPE.cdf_meaning = 'FIN NBR'
;		AND CV_ENCNTR_ALIAS_TYPE.CODE_SET = 319)
JOIN O WHERE O.encntr_id = E.encntr_id		;006
JOIN OD WHERE (OD.order_id = O.order_id
	AND (OD.action_sequence = (SELECT MAX(SOD.ACTION_SEQUENCE)
                FROM ORDER_DETAIL SOD
                WHERE O.ORDER_ID = SOD.ORDER_ID
                AND SOD.OE_FIELD_MEANING IN ('REQSTARTDTTM'))  )
    AND OD.OE_field_meaning IN ('REQSTARTDTTM')
    AND OD.oe_field_dt_tm_value BETWEEN cnvtdatetime($startDate) AND cnvtdatetime($endDate)
)
JOIN P WHERE P.PERSON_ID = OUTERJOIN(O.PERSON_ID)
; 005 adding this in on 10/03 caused issue with the speed moved down to the last query
;	and p.name_full_formatted NOT LIKE "ZZZ*"
JOIN OC WHERE OC.CATALOG_CD = O.catalog_cd
JOIN OA WHERE OA.order_id = OUTERJOIN(O.ORDER_ID)
JOIN OP WHERE OP.PERSON_ID = OA.order_provider_id
	AND OPERATOR(OP.PERSON_ID , op_provider_var, $userProvider)
JOIN OFI WHERE OFI.order_id = OUTERJOIN(O.order_id)
	AND OPERATOR(O.ORDER_STATUS_CD , op_status_var, $orderStatus)
	AND OC.CATALOG_TYPE_CD = 2513 ; code this to only report Laboratory
 
ORDER BY
	OP.name_full_formatted
	, P.name_full_formatted
	, O.ORIG_ORDER_DT_TM
;004 Add this order by so if they are listed multiple times for an order it will keep them grouped
	, O.order_id
 
 
head report
    ocnt = 0
    stat = alterlist(orderEncounter->olist,50)
head o.order_id
	ocnt = ocnt + 1
	if(mod(ocnt,10)=1 and ocnt > 50)
		stat = alterlist(orderEncounter->olist,ocnt+9)
	endif
 
	orderencounter->olist[ocnt].encounter_id = E.encntr_id
	orderencounter->olist[ocnt].provider = ORDER_PROVIDER
	orderencounter->olist[ocnt].facility = FACILITY
	orderencounter->olist[ocnt].patient_name = PATIENT
	orderencounter->olist[ocnt].patient_dob = DOB
	orderencounter->olist[ocnt].order_id = ORDER_ID
	orderencounter->olist[ocnt].order_date = ORDER_DATE
	orderencounter->olist[ocnt].order_status = ORDER_STATUS
	orderencounter->olist[ocnt].order_desc = ORDER_DESCRIPTION
	orderencounter->olist[ocnt].fin = EA.alias
	orderencounter->olist[ocnt].drawn_date = OD.oe_field_dt_tm_value
	; 05/08/21 DWB Add communication type to the output.
	orderencounter->olist[ocnt].communication_type = OA.communication_type_cd
 
foot report
	stat = alterlist(orderEncounter->olist, ocnt)
; 005
WITH nocounter, separator=" ", format, time = 5000
 
 
/*Build the Scheduled location*/
SELECT INTO $outdev
FROM ORDER_DETAIL OD
WHERE expand(num, 1, ocnt, OD.order_id, orderencounter->olist[num].order_id)
	AND OD.oe_field_meaning IN ('PERFORMLOC','COMMENTTYPE2')
	AND OD.action_sequence = (SELECT MAX(ODS.ACTION_SEQUENCE)
                FROM ORDER_DETAIL ODS
                WHERE OD.ORDER_ID = ODS.ORDER_ID
                AND OD.OE_FIELD_MEANING = ODS.OE_FIELD_MEANING
                AND ODS.OE_FIELD_MEANING IN ('PERFORMLOC','COMMENTTYPE2'))
 
head OD.order_id
	numx = 0
	idx = 0
	idx2 = 0
	sample = 0
	next = 0
 
	idx = locateval(numx, 1, size(orderencounter->olist, 5), OD.order_id, orderencounter->olist[numx].order_id)
	next = idx+1
 
detail
	if (idx > 0)
		orderencounter->olist[idx].schedule_location = OD.oe_field_display_value
		while(next <= ocnt	AND orderencounter->olist[next].order_id = orderencounter->olist[idx].order_id)
			orderencounter->olist[next].schedule_location = OD.oe_field_display_value
			next = next+1
		endwhile
	endif
foot OD.order_id
	orderencounter->olist[idx].schedule_location = OD.oe_field_display_value
 
WITH nocounter, separator=" ", format, time = 5000, EXPAND = 1
 
/*Build the Endorsement Data Added 01/29/20*/
SELECT INTO $outdev
	CE.ORDER_ID
	, EC_PRSNL.EVENT_ID
	, EC_PRSNL_ACTION_TYPE_DISP = UAR_GET_CODE_DISPLAY(EC_PRSNL.ACTION_TYPE_CD)
	, EC_PRSNL.ACTION_PRSNL_ID
 
FROM
	CE_EVENT_PRSNL   EC_PRSNL
	, PRSNL   PRSNL_CE_ACTION
	, CLINICAL_EVENT   CE
 
PLAN CE WHERE expand(num, 1, ocnt, CE.order_id, orderencounter->olist[num].order_id)
JOIN EC_PRSNL WHERE (EC_PRSNL.event_id = CE.event_id
	AND EC_PRSNL.action_type_cd = 678654.00)
JOIN PRSNL_CE_ACTION WHERE PRSNL_CE_ACTION.person_id = EC_PRSNL.action_prsnl_id
 
head CE.order_id
	numx = 0
	idx = 0
	idx2 = 0
	sample = 0
	next = 0
 
	idx = locateval(numx, 1, ocnt, CE.order_id, orderencounter->olist[numx].order_id)
	next = idx+1
detail
	if (idx > 0)
		orderencounter->olist[idx].endorsed_by = PRSNL_CE_ACTION.name_full_formatted
		orderencounter->olist[idx].endorsed_date = EC_PRSNL.ACTION_DT_TM
		while(next <= ocnt	AND orderencounter->olist[next].order_id = orderencounter->olist[idx].order_id)
			orderencounter->olist[next].endorsed_by = PRSNL_CE_ACTION.name_full_formatted
			orderencounter->olist[next].endorsed_date = EC_PRSNL.ACTION_DT_TM
			next = next+1
		endwhile
	endif
foot CE.order_id
	orderencounter->olist[idx].endorsed_by = PRSNL_CE_ACTION.name_full_formatted
	orderencounter->olist[idx].endorsed_date = EC_PRSNL.ACTION_DT_TM
; 005
WITH nocounter, separator=" ", format, time = 5000, EXPAND = 1
 
 
 
SELECT INTO $outdev
FROM ORDER_COMMENT OC
		, (left join LONG_TEXT LT on OC.long_text_id = LT.long_text_id)
WHERE
	expand(num, 1, ocnt, OC.order_id, orderencounter->olist[num].order_id)
 
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
WITH nocounter, separator=" ", format, time = 5000, expand = 1
 
/*Use the standard output for the users.*/
CALL OUTPUT_RECORD_SPREADSHEET(null)
 
/*
 Output to the spreadsheet.  This will enable the users to use Excel
*/
SUBROUTINE OUTPUT_RECORD_SPREADSHEET(null)
 
	SELECT INTO $outdev
	PROVIDER = orderencounter->olist[D1.SEQ].provider
	,PATIENT = orderencounter->olist[D1.SEQ].patient_name
	,DOB = FORMAT(orderencounter->olist[D1.SEQ].patient_dob,"mm/dd/yyyy;;d")
	,FIN = SUBSTRING(1, 30, orderencounter->olist[D1.SEQ].fin)
	,ORDER_DESC = orderencounter->olist[D1.SEQ].order_desc
	,ORDER_DATE = FORMAT(orderencounter->olist[D1.SEQ].order_date,"mm/dd/yyyy;;d")
	,COLLECTED_DATE = FORMAT(orderencounter->olist[D1.SEQ].drawn_date,"mm/dd/yyyy;;d")
	,SCHEDULE_LOCATION = orderencounter->olist[D1.SEQ].schedule_location
	,OrderID = orderencounter->olist[D1.SEQ].order_id
	,ORDER_STATUS = orderencounter->olist[D1.SEQ].order_status
	,COMMENTS = SUBSTRING(1, 100, ORDERENCOUNTER->olist[D1.SEQ].comments)
	,ENDORSED_BY = orderencounter->olist[D1.SEQ].endorsed_by
	,ENDORSED_DATE = FORMAT(orderencounter->olist[D1.SEQ].endorsed_date,"mm/dd/yyyy;;d")
; 05/08/21 DWB Add communication type to the output.
	,COMMUNICATION_TYPE = UAR_GET_CODE_DESCRIPTION(orderencounter->olist[D1.SEQ].communication_type)
 
 
	FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderencounter->olist, 5)))
 
	PLAN D1
; 11/05/21 removed testing patients per Teresa Loy
	WHERE orderencounter->olist[D1.SEQ].patient_name NOT LIKE "ZZZ*"
 
	ORDER BY
	PROVIDER, PATIENT, ORDER_DATE
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
END
 
END GO
 
 
 
 
 
 

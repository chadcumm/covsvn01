/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			David Baumgardner
	Date Written:		March 2020
	Solution:
	Source file name:  	cov_amb_lab_covid_test.prg
	Object name:		cov_amb_lab_covid_test
	Request#:
 
	Program purpose:	Report the COVID test and results
	Executing from:		CCL/DA2/Response Coordination
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
11/16/20	David Baumgardner		Result pulling from incorrect clinical event.  Updating the pulling section to pull only
									result for SARS-CoV-2.
04/01/20	David Baumgardner		Request to add the Reason for Lab Testing.  Added in a secondary query as other tests will not
									have the Reason for Lab testing.
03/27/20	David Baumgardner		Request to add the new version of the COVID19 Reference Lab to the tests for the report.
03/25/20	David Baumgardner		Request to add the new Diatherix test to the selection of test.
08/02/21	David Baumgardner		Request from Tiffany to be able to export to excel.  Added a quick selection to allow it to
									come out in grid form.
06/21/22	David Baumgardner		Found a new Clinical Event item that needs to be excluded.
10/06/2022  Dawn Greer, DBA         CR 13765 - Fixed errors found when running the report.  Changed the timeout to 700 from 500.
******************************************************************************/
 
DROP PROGRAM testing_cov_amb_lab_covid_test GO
CREATE PROGRAM testing_cov_amb_lab_covid_test
 
prompt
	"Output to File/Printer/MINE" = "MINE"                                                                                  ;* Ent
	, "Facility" = VALUE(0.0           )
	, "Provider:" = VALUE(0.0           )
	, "Order Status" = VALUE(0.0           )
	, "Test Name" = VALUE( 3349587789.00,  3348598617.00,  3348530075.00,  3363387807.00,  3361700765.00,  3358207083.00)
	, "Reason For Lab Testing" = VALUE(0.0           )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = "DP"
 
with OUTDEV, userFacility, userProvider, orderStatus, userTest,
	userReasonForLab, startDate, endDate, userReportType
 
declare num					= i4 with noconstant(0)
declare op_facility_var		= c2 with noconstant("")
declare op_status_var		= c2 with noconstant("")
declare op_provider_var		= c2 with noconstant("")
declare op_test_var			= c2 with noconstant("")
declare op_reason_for_lab_var	= c2 with noconstant("")
declare tempfacility		= c40 with noconstant("")
declare tempOrdDesc 		= c40 with noconstant("")
declare tempResult	 		= c40 with noconstant("")
declare tempOrganization	= c40 with noconstant("")
declare ocnt				= i4 with noconstant(0)
declare rcnt				= i4 with noconstant(0)
declare facility_test_cnt	= i4 with noconstant(0)
declare org_filter			= c4 with noconstant("")
declare org_location		= i4 with noconstant(0)
 
record organizationList (
  1 olist[*]
  	2 organization = f8
)
 
record organizationGroups(
  1 olist[*]
  	2 organization = f8
  	2 organization_group = c40
)
 
record orderencounter (
  1 olist[*]
  /*01/29/20 added encounter_id for the endorsement data*/
  	2 encounter_id = f8
    2 provider = c30
    2 facility = c30
    2 nurse_unit = c30
    2 patient_name = c40
    2 patient_last_name = c40
    2 patient_first_name = c40
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
    2 dept = c30
    2 result_disp = c30
    2 result_units = c30
    2 patient_id = f8
    2 cMRN = c30
    2 reason_for_testing = c30
    2 organization = c30
    2 organization_group = c30
    2 catalog_cd = f8
    2 reason_for_testing_id = f8
)
record orderSummary(
	1 olist[*]
		2 organization_group = c30
		2 facility = c30
		2 catalog_item = c30
		2 count = i4
		2 total_detected = i4
		2 total_not_detected = i4
		2 total_pending = i4
		2 reflab_count = i4
		2 reflab_total_detected = i4
		2 reflab_total_not_detected = i4
		2 reflab_total_pending = i4
		2 amb_poc_count = i4
		2 amb_poc_total_detected = i4
		2 amb_poc_total_not_detected = i4
		2 amb_poc_total_pending = i4
		2 rlist[*]
			3 facility = c30
			3 total_count = i4
			3 total_detected = i4
			3 total_not_detected = i4
			3 total_pending = i4
			3 reflab_total_count = i4
			3 reflab_total_detected = i4
			3 reflab_total_not_detected = i4
			3 reflab_total_pending = i4
			3 amb_poc_total_count = i4
			3 amb_poc_total_detected = i4
			3 amb_poc_total_not_detected = i4
			3 amb_poc_total_pending = i4
			3 result_name = c30
			3 result_count = i4
)

CALL ECHO(CONCAT("Started at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
SELECT *
FROM ORG_SET_ORG_R ORG_S_ORG_R
WHERE ORG_S_ORG_R.org_set_id = 3875838.00
head report
    ocnt = 0
    stat = alterlist(organizationList->olist,50)
	numx = 0
head ORG_S_ORG_R.organization_id
	ocnt = ocnt+1
	if(mod(ocnt,10)=1 and ocnt > 50)
		stat = alterlist(organizationList->olist,ocnt+9)
	endif
	organizationList->olist[ocnt].organization = ORG_S_ORG_R.organization_id
 
foot report
	stat = alterlist(organizationList->olist, ocnt)
with nocounter		;CR 13765

CALL ECHO(CONCAT("Build Organization Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
/*build organization List*/
SELECT
                O.ACTIVE_IND
                , O.NAME
                , ORG.ACTIVE_IND
                , ORG.ORG_NAME
                , os.org_set_id
                , org.organization_id
FROM
                ORG_SET   O
                , ORG_SET_ORG_R   OS
                , ORGANIZATION   ORG
 
WHERE o.org_set_id = os.org_set_id
AND os.organization_id = org.organization_Id
AND os.active_ind = 1
AND os.org_set_id IN (3244682.00, 3244730.00, 3244682.00, 3244689.00, 3244539.00,
3244660.00, 3244676.00, 3244730.00, 3244783.00, 3244943.00, 3570127.00)
head report
    ocnt = 0
    stat = alterlist(organizationGroups->olist,50)
    ocnt += 1
	organizationGroups->olist[ocnt].organization = 3885059.00
	organizationGroups->olist[ocnt].organization_group = "FSR"
 
	numx = 0
head OS.organization_id
	ocnt = ocnt+1
	if(mod(ocnt,10)=1 and ocnt > 50)
		stat = alterlist(organizationGroups->olist,ocnt+9)
	endif
 
	organizationGroups->olist[ocnt].organization = org.organization_id
 
	if(os.org_set_id = 3244730.00)
		organizationGroups->olist[ocnt].organization_group = "FSR"
	elseif (os.org_set_id = 3244539.00)
		organizationGroups->olist[ocnt].organization_group = "MMC"
	elseif (os.org_set_id = 3244676.00)
		organizationGroups->olist[ocnt].organization_group = "FLMC"
	elseif (os.org_set_id = 3244689.00)
		organizationGroups->olist[ocnt].organization_group = "LCMC"
	elseif (os.org_set_id = 3244682.00)
		organizationGroups->olist[ocnt].organization_group = "MHHS"
	elseif (os.org_set_id = 3570127.00)
		organizationGroups->olist[ocnt].organization_group = "PWMC"
	elseif (os.org_set_id = 3244660.00)
		organizationGroups->olist[ocnt].organization_group = "RMC"
	else
		organizationGroups->olist[ocnt].organization_group = "Ambulatory"
	endif
 
foot report
	stat = alterlist(organizationGroups->olist, ocnt)
WITH MAXREC = 1000, NOCOUNTER, SEPARATOR=" ", FORMAT

CALL ECHO(CONCAT("Facility Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
; set the variable for the OPERATOR for the facility
if (substring(1, 1, reflect(parameter(parameter2($userFacility), 0))) = "L") ; multiple values
    set op_facility_var = "IN"
elseif (parameter(parameter2($userFacility), 1) = 0.0) ; any/no value
    set op_facility_var = "!="
else ; single value
    set op_facility_var = "="
endif
 
CALL ECHO(CONCAT("Order Status Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
; set the variable for the OPERATOR for the order status
if (substring(1, 1, reflect(parameter(parameter2($orderStatus), 0))) = "L") ; multiple values
    set op_status_var = "IN"
elseif (parameter(parameter2($orderStatus), 1) = 0.0) ; any/no value
    set op_status_var = "!="
else ; single value
    set op_status_var = "="
endif

CALL ECHO(CONCAT("Provider Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
; set the variable for the OPERATOR for the provider
if (substring(1, 1, reflect(parameter(parameter2($userProvider), 0))) = "L") ; multiple values
    set op_provider_var = "IN"
elseif (parameter(parameter2($userProvider), 1) = 0.0) ; any/no value
    set op_provider_var = "!="
else ; single value
    set op_provider_var = "="
endif

CALL ECHO(CONCAT("Test Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
; set the variable for the OPERATOR for the test
if (substring(1, 1, reflect(parameter(parameter2($userTest), 0))) = "L") ; multiple values
    set op_test_var = "IN"
elseif (parameter(parameter2($userTest), 1) = 0.0) ; any/no value
    set op_test_var = "!="
else ; single value
    set op_test_var = "="
endif

CALL ECHO(CONCAT("Reason For Lab Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
; set the variable for the OPERATOR for the test
if (substring(1, 1, reflect(parameter(parameter2($userReasonForLab), 0))) = "L") ; multiple values
    set op_reason_for_lab_var = "IN"
elseif (parameter(parameter2($userReasonForLab), 1) = 0.0) ; any/no value
    set op_reason_for_lab_var = "!="
else ; single value
    set op_reason_for_lab_var = "="
endif
 
CALL ECHO(CONCAT("Main Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
/*Build the main data for the record of the report*/
SELECT DISTINCT INTO $OUTDEV
	FACILITY = UAR_GET_CODE_DESCRIPTION(E.LOC_FACILITY_CD)
	, ORGANIZATION = UAR_GET_CODE_DESCRIPTION(E.organization_id)
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
	, PERSON_ALIAS PA
PLAN E WHERE OPERATOR(E.LOC_FACILITY_CD , op_facility_var, $userFacility)
JOIN EA WHERE e.encntr_id = ea.encntr_id
	AND ea.encntr_alias_type_cd = 1077 /*FIN*/
JOIN O WHERE O.encntr_id = E.encntr_id
JOIN OD WHERE (OD.order_id = O.order_id
	AND (OD.action_sequence = (SELECT MAX(SOD.ACTION_SEQUENCE)
                FROM ORDER_DETAIL SOD
                WHERE O.ORDER_ID = SOD.ORDER_ID
                AND SOD.OE_FIELD_MEANING IN ('REQSTARTDTTM'))  )
    AND OD.OE_field_meaning IN ('REQSTARTDTTM')
    AND OD.oe_field_dt_tm_value BETWEEN cnvtdatetime($startDate) AND cnvtdatetime($endDate)
)
JOIN P WHERE P.PERSON_ID = OUTERJOIN(O.PERSON_ID)
JOIN PA WHERE p.person_id = pa.person_id
	AND pa.person_alias_type_cd = 2 /*CMRN*/
JOIN OC WHERE OC.CATALOG_CD = O.catalog_cd
AND OPERATOR(OC.catalog_cd, op_test_var, $userTest)
JOIN OA WHERE OA.order_id = OUTERJOIN(O.ORDER_ID)
JOIN OP WHERE OP.PERSON_ID = OA.order_provider_id
	AND OPERATOR(OP.PERSON_ID , op_provider_var, $userProvider)
JOIN OFI WHERE OFI.order_id = OUTERJOIN(O.order_id)
	AND OPERATOR(O.ORDER_STATUS_CD , op_status_var, $orderStatus)
	AND (OC.CATALOG_TYPE_CD = 2513 ; code this to only report Laboratory
		OR OC.catalog_type_cd = 20454826.00)
AND P.name_full_formatted NOT LIKE "ZZZ*"
AND P.name_full_formatted NOT LIKE "COVTEST*"
ORDER BY P.name_full_formatted, OP.name_full_formatted, O.ORIG_ORDER_DT_TM
 
 
head report
    ocnt = 0
    stat = alterlist(orderEncounter->olist,50)
	numx = 0
head o.order_id
	if($userReportType = "D" OR $userReportType = "S" OR $userReportType = "DP" OR
	(locateval(numx, 1, size(organizationList->olist, 5), E.organization_id, organizationList->olist[numx].organization) > 0
	AND ($userReportType = "AD" OR $userReportType = "AS")))
 
		ocnt = ocnt + 1
		if(mod(ocnt,10)=1 and ocnt > 50)
			stat = alterlist(orderEncounter->olist,ocnt+9)
		endif
 
		orderencounter->olist[ocnt].encounter_id = E.encntr_id
		orderencounter->olist[ocnt].provider = ORDER_PROVIDER
		orderencounter->olist[ocnt].facility = FACILITY
		orderencounter->olist[ocnt].nurse_unit = UAR_GET_CODE_DESCRIPTION(E.loc_nurse_unit_cd)
		orderencounter->olist[ocnt].patient_name = PATIENT
		orderencounter->olist[ocnt].patient_first_name = P.name_first
		orderencounter->olist[ocnt].patient_last_name = P.name_last
		orderencounter->olist[ocnt].patient_dob = DOB
		orderencounter->olist[ocnt].order_id = ORDER_ID
		orderencounter->olist[ocnt].order_date = ORDER_DATE
		orderencounter->olist[ocnt].order_status = ORDER_STATUS
		orderencounter->olist[ocnt].order_desc = ORDER_DESCRIPTION
		orderencounter->olist[ocnt].FIN = EA.alias
		orderencounter->olist[ocnt].CMRN = PA.alias
		orderencounter->olist[ocnt].drawn_date = OD.oe_field_dt_tm_value
		orderencounter->olist[ocnt].dept = OC.dept_display_name
		orderencounter->olist[ocnt].patient_id = P.person_id
		orderencounter->olist[ocnt].catalog_cd = O.catalog_cd
		orderencounter->olist[ocnt].organization = ORGANIZATION
		org_location = locateval(numx, 1, size(organizationGroups->olist, 5), E.organization_id,
			organizationGroups->olist[numx].organization)
		if (org_location > 0)
			orderencounter->olist[ocnt].organization_group = organizationGroups->olist[org_location].organization_group
		else
			orderencounter->olist[ocnt].organization_group = "Ambulatory"
		endif
 
	endif
 
foot report
	stat = alterlist(orderEncounter->olist, ocnt)
 
WITH nocounter, separator=" ", format, time = 700	;CR 13765
 
CALL ECHO(CONCAT("Schedule Location Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
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
 
WITH nocounter, separator=" ", format, time = 700, EXPAND = 1	;CR 13765
 
CALL ECHO(CONCAT("Result Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
/*build result data*/
SELECT DISTINCT *
FROM
	CLINICAL_EVENT CE
WHERE expand(num, 1, ocnt, CE.order_id, orderencounter->olist[num].order_id)
   	AND ((ce.valid_until_dt_tm + 0 ) > cnvtdatetime (curdate ,curtime3 ) )
   	AND ((ce.publish_flag + 0 ) = 1 )
   	AND ((ce.view_level + 0 ) = 1 )
   	;exclude the events that aren't pertaining to true results.
   	AND (CE.event_cd NOT IN ( 3350124443.00, 3350118409.00,4476768.00, 3438766215.00, 3438838009.00, 11895.00,
   	3438770033.00, 3438912287.00,3438767797.00,  3438765971.00, 3486045281.00, 3486049519.00, 3486050865.00,
   	3486052177.00, 3486053863.00, 3486055423.00, 3486057969.00, 3486059329.00,
   	;exlude these items for the Respiratory Panel
   	3486053863.00, 3486055423.00, 2913050003.00, 2913051157.00, 2913051411.00,
   	2913052181.00, 2913053767.00, 3494667105.00, 3494672633.00, 3494674419.00, 3494675539.00, 3494686321.00,
   	3494686895.00, 3494687955.00, 3494688573.00, 3494690627.00, 3494691683.00, 3494692387.00, 3494693047.00,
   	3494693891.00,     632707.00, 3486045281.00, 3486049519.00, 3486052177.00, 3486059329.00, 3486057969.00,
   	3563383785.00, 3563383773.00, 2556643361.00,
   	;exclude the following item added to the POC test 06/21/22
   	4343427305.00))
 
   	AND (CE.event_tag NOT LIKE "SARS-CoV-2")
 
head CE.order_id
	numx = 0
	idx = 0
	idx2 = 0
	sample = 0
	next = 0
	idx = locateval(numx, 1, ocnt, CE.order_id, orderencounter->olist[numx].order_id)
 
detail
	if (idx > 0)
; 11/16/20 David Baumgardner
;modifying this to be specific for the result needed for the Resp Panel as it seems to be changing what is included in it
 
		if(orderencounter->olist[idx].order_status = "Completed")
			if(orderencounter->olist[idx].catalog_cd = 3482845931.00)
				if(ce.event_cd = 3358526621.00)
					orderencounter->olist[idx].result_disp = CE.event_tag
					orderencounter->olist[idx].result_units = uar_get_code_display (ce.result_units_cd )
				endif
			elseif(orderencounter->olist[idx].catalog_cd = 3397231567.00)
				if(ce.event_cd = 3358526621.00 OR ce.event_cd = 3624612187.00)
					orderencounter->olist[idx].result_disp = CE.event_tag
					orderencounter->olist[idx].result_units = uar_get_code_display (ce.result_units_cd )
;					orderencounter->olist[idx].result_event_id = ce.event_cd
				endif
			else
				orderencounter->olist[idx].result_disp = CE.event_tag
				orderencounter->olist[idx].result_units = uar_get_code_display (ce.result_units_cd )
			endif
 
		endif
;end 11/16/20 David Baumgardner
	endif
foot CE.order_id
	next = 0
WITH nocounter, separator=" ", format, time = 700, EXPAND = 1	;CR 13765
 
CALL ECHO(CONCAT("Reason for Visit Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
/*04/01/20 Build the reason for the visit*/
SELECT DISTINCT
	 OD.oe_field_display_value,
	 OEF.description
FROM
	ORDER_DETAIL OD
	, ORDER_ENTRY_FIELDS OEF
WHERE expand(num, 1, ocnt, OD.order_id, orderencounter->olist[num].order_id)
	AND OEF.oe_field_id = OD.oe_field_id
	AND OEF.description LIKE "Reason for Lab Testing*"
head OD.order_id
	numx = 0
	idx = 0
	idx2 = 0
	sample = 0
	next = 0
	idx = locateval(numx, 1, ocnt, OD.order_id, orderencounter->olist[numx].order_id)
 
detail
	if (idx > 0)
		orderencounter->olist[idx].reason_for_testing = OD.oe_field_display_value
		orderencounter->olist[idx].reason_for_testing_id = OD.oe_field_value
 
	endif
foot OD.order_id
	next = 0
WITH nocounter, separator=" ", format, time = 700, EXPAND = 1	;CR 13765
 
CALL ECHO(CONCAT("Comment Data for the report at ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))
 
 
/*build comment data*/
 
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
WITH nocounter, separator=" ", format, time = 700, EXPAND = 1	;CR 13765
 
/*Use the standard output for the users.*/
if ($userReportType = "D" OR $userReportType = "AD")
	CALL OUTPUT_RECORD_SPREADSHEET(null)
else
	if($userReportType = "DP")
		EXECUTE COV_AMB_LAB_COVID_TEST_LB $OUTDEV, $userFacility, $userProvider, $orderStatus,
			$userTest,$userReasonForLab, $startDate, $endDate, $userReportType
	endif
	if($userReportType = "S" OR $userReportType = "AS")
		CALL OUTPUT_SUMMARY_SPREADSHEET(null)
	endif
endif

CALL ECHO(CONCAT("Output to spreadsheet ",FORMAT(CNVTDATETIME(CURDATE,CURTIME3),"MM/DD/YYYY hh:mm:ss;;d")))

CALL ECHORECORD(orderencounter) 

/*
 Output to the spreadsheet.  This will enable the users to use Excel
*/
SUBROUTINE OUTPUT_RECORD_SPREADSHEET(null)
 
	SELECT INTO $outdev
	PATIENT_NAME = orderencounter->olist[D1.SEQ].patient_name
	,DOB = FORMAT(orderencounter->olist[D1.SEQ].patient_dob,"mm/dd/yyyy;;d")
	,CMRN = orderencounter->olist[D1.SEQ].cMRN
	,ORDER_DATE = FORMAT(orderencounter->olist[D1.SEQ].order_date,"mm/dd/yyyy;;d")
	,PROVIDER = orderencounter->olist[D1.SEQ].provider
	,FACILITY = TRIM(orderencounter->olist[D1.SEQ].facility)
	,NURSE_UNIT = TRIM(orderencounter->olist[D1.SEQ].nurse_unit)
	,ORDER_DESC = orderencounter->olist[D1.SEQ].order_desc
	,DEPT = orderencounter->olist[d1.SEQ].dept
	,FIN = SUBSTRING(1, 30, orderencounter->olist[D1.SEQ].fin)
	,ORDER_STATUS = orderencounter->olist[D1.SEQ].order_status
	,REASON_FOR_LAB_TESTING = orderencounter->olist[D1.SEQ].reason_for_testing
;	,REASON_FOR_LAB_TESTING_ID = orderencounter->olist[D1.SEQ].reason_for_testing_id
;	,ORGANIZATION = orderencounter->olist[D1.seq].organization
;	,ORGANIZATION_GROUP = orderencounter->olist[D1.seq].organization_group
	,RESULT = orderencounter->olist[D1.SEQ].result_disp
	,RESULT_UNIT = orderencounter->olist[D1.SEQ].result_units
 
 
 
	FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderencounter->olist, 5)))
 
	PLAN D1 WHERE (OPERATOR(orderencounter->olist[D1.seq].reason_for_testing_id , op_reason_for_lab_var, $userReasonForLab) OR
		orderencounter->olist[D1.seq].reason_for_testing_id = 0.0)
 
	ORDER BY
	FACILITY, NURSE_UNIT, PATIENT_NAME, ORDER_DATE, PROVIDER
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
END
 
SUBROUTINE OUTPUT_SUMMARY_SPREADSHEET(null)
 
	SELECT INTO $outdev
	FACILITY = orderencounter->olist[D1.SEQ].nurse_unit
	,ORDER_DATE = orderencounter->olist[D1.SEQ].patient_first_name
	,DOB = FORMAT(orderencounter->olist[D1.SEQ].patient_dob,"mm/dd/yyyy;;d")
	,ORDER_DATE = FORMAT(orderencounter->olist[D1.SEQ].order_date,"mm/dd/yyyy;;d")
	,PROVIDER = orderencounter->olist[D1.SEQ].provider
	,ORDER_DESC = orderencounter->olist[D1.SEQ].order_desc
	,DEPT = orderencounter->olist[d1.SEQ].dept
	,FIN = SUBSTRING(1, 30, orderencounter->olist[D1.SEQ].fin)
	,ORDER_STATUS = orderencounter->olist[D1.SEQ].order_status
	,RESULT = orderencounter->olist[D1.SEQ].result_disp
	,ORGANIZATION_GROUP = orderencounter->olist[D1.SEQ].organization_group
	,REASON_FOR_LAB = orderencounter->olist[D1.seq].reason_for_testing_id
 	FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderencounter->olist, 5)))
 
	PLAN D1 WHERE (OPERATOR(orderencounter->olist[D1.seq].reason_for_testing_id , op_reason_for_lab_var, $userReasonForLab) OR
		orderencounter->olist[D1.seq].reason_for_testing_id = 0.0)
 
	ORDER BY
	ORGANIZATION_GROUP, FACILITY, ORDER_DESC, RESULT
 
 
; build total data
	head report
    	ocnt = 0
    	rcnt = 0
    	stat = alterlist(orderSummary->olist,50)
		tempResult = ""
		tempOrganization = ""
		tempFacility = ""
	detail
		if(ORDER_STATUS != 'Canceled' AND ORDER_STATUS != 'Discontinued' AND ORDER_STATUS != 'Voided')
			ocnt = ocnt + 1
			if(mod(ocnt,10)=1 and ocnt > 50)
				stat = alterlist(orderSummary->olist,ocnt+9)
			endif
			if (tempOrganization != ORGANIZATION_GROUP AND (
				orderencounter->olist[D1.SEQ].catalog_cd = 3358207083.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3363387807.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3363721503.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3427729423.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3438761809.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3453222221.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3482845931.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3397231567.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3593981395.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3384602607.00))
				orderSummary->olist[ocnt].organization_group = ORGANIZATION_GROUP
				if(tempOrganization != ORGANIZATION_GROUP)
					orderSummary->olist[ocnt].count = 0
				;	orderSummary->olist[ocnt].count = orderSummary->olist[ocnt].count + 1
				endif
				tempOrganization = ORGANIZATION_GROUP
 
				stat = alterlist(orderSummary->olist[ocnt-1]->rlist,rcnt)
				rcnt = 0
				stat = alterlist(orderSummary->olist[ocnt]->rlist,10)
				if(FACILITY != tempFacility)
					tempFacility = FACILITY
					rcnt += 1
					orderSummary->olist[ocnt]->rlist[rcnt].facility = FACILITY
				endif
 
				if (orderencounter->olist[D1.SEQ].catalog_cd != 3358207083.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3363387807.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3427729423.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3438761809.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3453222221.00)
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].total_not_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].total_not_detected += 1
					elseif (RESULT = "Detected" OR RESULT = "Positive")
						orderSummary->olist[ocnt].total_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].total_detected += 1
					else
						orderSummary->olist[ocnt].total_pending += 1
						orderSummary->olist[ocnt].rlist[rcnt].total_pending += 1
					endif
					orderSummary->olist[ocnt].count += 1
					orderSummary->olist[ocnt].rlist[rcnt].total_count += 1
 				elseif (orderencounter->olist[D1.SEQ].catalog_cd != 3438761809.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3453222221.00)
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].reflab_total_not_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].reflab_total_not_detected += 1
					elseif (RESULT = "Detected" OR RESULT = "Positive")
						orderSummary->olist[ocnt].reflab_total_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].reflab_total_detected += 1
					else
						orderSummary->olist[ocnt].reflab_total_pending += 1
						orderSummary->olist[ocnt].rlist[rcnt].reflab_total_pending += 1
					endif
					orderSummary->olist[ocnt].reflab_count += 1
					orderSummary->olist[ocnt].rlist[rcnt].reflab_total_count += 1
 
				else
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].amb_poc_total_not_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_not_detected += 1
					elseif (RESULT = "Detected" OR RESULT = "Positive")
						orderSummary->olist[ocnt].amb_poc_total_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_detected += 1
					else
						orderSummary->olist[ocnt].amb_poc_total_pending += 1
						orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_pending += 1
					endif
					orderSummary->olist[ocnt].amb_poc_count += 1
					orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_count += 1
 
				endif
			elseif (
				orderencounter->olist[D1.SEQ].catalog_cd = 3358207083.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3363387807.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3363721503.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3427729423.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3438761809.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3453222221.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3482845931.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3397231567.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3593981395.00 OR
				orderencounter->olist[D1.SEQ].catalog_cd = 3384602607.00)
				ocnt = ocnt-1
 
				if (tempFacility != FACILITY)
					rcnt = rcnt + 1
					IF (MOD(rcnt,10) = 1 AND rcnt != 1)
						STAT = ALTERLIST(orderSummary->olist[ocnt].rlist,rcnt + 9)
					ENDIF
					orderSummary->olist[ocnt]->rlist[rcnt].result_name = RESULT
					orderSummary->olist[ocnt]->rlist[rcnt].result_count = 1
					orderSummary->olist[ocnt]->rlist[rcnt].facility = FACILITY
					tempFacility = FACILITY
				else
					orderSummary->olist[ocnt]->rlist[rcnt].result_count = orderSummary->olist[ocnt]->rlist[rcnt].result_count + 1
				endif
 
				if (orderencounter->olist[D1.SEQ].catalog_cd != 3358207083.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3363387807.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3427729423.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3438761809.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3453222221.00)
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].total_not_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].total_not_detected += 1
					elseif (RESULT = "Detected" OR FINDSTRING("Pos",RESULT))
						orderSummary->olist[ocnt].total_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].total_detected += 1
					else
						orderSummary->olist[ocnt].total_pending += 1
						orderSummary->olist[ocnt].rlist[rcnt].total_pending += 1
					endif
					orderSummary->olist[ocnt].count += 1
					orderSummary->olist[ocnt].rlist[rcnt].total_count += 1
 
				elseif (orderencounter->olist[D1.SEQ].catalog_cd != 3438761809.00 AND
					orderencounter->olist[D1.SEQ].catalog_cd != 3453222221.00)
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].reflab_total_not_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].reflab_total_not_detected += 1
					elseif (RESULT = "Detected" OR RESULT = "Positive")
						orderSummary->olist[ocnt].reflab_total_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].reflab_total_detected += 1
					else
						orderSummary->olist[ocnt].reflab_total_pending += 1
						orderSummary->olist[ocnt].rlist[rcnt].reflab_total_pending += 1
					endif
					orderSummary->olist[ocnt].reflab_count += 1
					orderSummary->olist[ocnt].rlist[rcnt].reflab_total_count += 1
				else
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].amb_poc_total_not_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_not_detected += 1
					elseif (RESULT = "Detected" OR RESULT = "Positive")
						orderSummary->olist[ocnt].amb_poc_total_detected += 1
						orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_detected += 1
					else
						orderSummary->olist[ocnt].amb_poc_total_pending += 1
						orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_pending += 1
					endif
					orderSummary->olist[ocnt].amb_poc_count += 1
					orderSummary->olist[ocnt].rlist[rcnt].amb_poc_total_count += 1
 
 
				endif
 			else
 				if(op_test_var = "=")
					orderSummary->olist[ocnt].organization_group = ORGANIZATION_GROUP
					if(tempOrganization != ORGANIZATION_GROUP)
						orderSummary->olist[ocnt].count = 0
						orderSummary->olist[ocnt].organization_group = ORGANIZATION_GROUP
					else
						ocnt = ocnt-1
					endif
					tempOrganization = ORGANIZATION_GROUP
					if (RESULT = "Not Detected" OR RESULT = "Negative" OR RESULT = "Inconclusive")
						orderSummary->olist[ocnt].total_not_detected += 1
					elseif (RESULT = "Detected" OR RESULT = "Positive")
						orderSummary->olist[ocnt].total_detected += 1
					else
						orderSummary->olist[ocnt].total_pending += 1
					endif
					orderSummary->olist[ocnt].count += 1
 				else
 					ocnt = ocnt-1
 				endif
			endif
		endif
	foot report
		stat = alterlist(orderSummary->olist, ocnt)
		stat = alterlist(orderSummary->olist[ocnt]->rlist,rcnt)
; 08/02/21 DWB
SELECT  INTO $outdev
	FACILITY = orderSummary->olist[D1.SEQ]->rlist[D2.SEQ].facility
	, ORGANIZATION_GROUP = orderSummary->olist[D1.SEQ].organization_group
	, FAC_TOTAL_CNT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].total_count
	, FAC_TOTAL_DETECT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].total_detected
	, FAC_TOTAL_NOT_DETECT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].total_not_detected
	, FAC_TOTAL_PENDING = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].total_pending
	, FAC_REF_TOTAL_CNT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].reflab_total_count
	, FAC_REF_TOTAL_DETECT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].reflab_total_detected
	, FAC_REF_TOTAL_NOT_DETECT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].reflab_total_not_detected
	, FAC_REF_TOTAL_PENDING = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].reflab_total_pending
	, AMB_POC_TOTAL_CNT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].amb_poc_total_count
	, AMB_POC_TOTAL_DETECT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].amb_poc_total_detected
	, AMB_POC_TOTAL_NOT_DETECT = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].amb_poc_total_not_detected
	, AMB_POC_TOTAL_PENDING = ORDERSUMMARY->olist[D1.SEQ].rlist[D2.SEQ].amb_poc_total_pending
	, ORG_TOTAL_CNT = orderSummary->olist[D1.SEQ].count
	, ORG_DETECT = orderSummary->olist[D1.SEQ].total_detected
	, ORG_NOT_DETECT = orderSummary->olist[D1.SEQ].total_not_detected
	, ORG_PENDING = orderSummary->olist[D1.SEQ].total_pending
	, ORG_REF_TOTAL = orderSummary->olist[D1.SEQ].reflab_count
	, ORG_REF_DETECT = orderSummary->olist[D1.SEQ].reflab_total_detected
	, ORG_REF_NOT_DETECT = orderSummary->olist[D1.SEQ].reflab_total_not_detected
	, ORG_REF_PENDING = orderSummary->olist[D1.SEQ].reflab_total_pending
	, ORG_AMB_POC_TOTAL = orderSummary->olist[D1.SEQ].amb_poc_count
	, ORG_AMB_POC_DETECT = orderSummary->olist[D1.SEQ].amb_poc_total_detected
	, ORG_AMB_POC_NOT_DETECT = orderSummary->olist[D1.SEQ].amb_poc_total_not_detected
	, ORG_POC_PENDING = orderSummary->olist[D1.SEQ].amb_poc_total_pending
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderSummary->olist, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1
 
	 WHERE MAXREC(D2, SIZE(ORDERSUMMARY->olist[D1.SEQ].rlist, 5))
	JOIN D2

ORDER BY
	orderSummary->olist[D1.SEQ].organization_group
	, FACILITY
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
; end 08/02/21 DWB
 
END
 
END GO
 
 
 
 
 
 

 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			David Baumgardner
	Date Written:		Mar '2022
	Solution:			Laboratory
	Source file name:	      cov_lab_POC_Lactate_TAT.prg
	Object name:		cov_lab_POC_Lactate_TAT
	Request#:			11373
	Program purpose:	      ED POC Lactate TAT
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------
********************************************************************************************************************/
 
drop program cov_lab_POC_Lactate_TAT:DBA go
create program cov_lab_POC_Lactate_TAT:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Location - Facility (Order)" = 0
	, "Location - Nurse Unit (Order)" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
 
with OUTDEV, userFacility, userNurseUnit, userStartDate, userEndDate
 
 
declare op_nurse_unit_var	= c2 with noconstant("")
declare op_facility_var		= c2 with noconstant("")
 
; set the variable for the OPERATOR for the facility
if (substring(1, 1, reflect(parameter(parameter2($userFacility), 0))) = "L") ; multiple values
    set op_facility_var = "IN"
elseif (parameter(parameter2($userFacility), 1) = 0.0) ; any/no value
    set op_facility_var = "!="
else ; single value
    set op_facility_var = "="
endif
 
 
; set the variable for the OPERATOR for the nurseUnit
if (substring(1, 1, reflect(parameter(parameter2($userNurseUnit), 0))) = "L") ; multiple values
    set op_nurse_unit_var = "IN"
elseif (parameter(parameter2($userNurseUnit), 1) = 0.0) ; any/no value
    set op_nurse_unit_var = "!="
else ; single value
    set op_nurse_unit_var = "="
endif
 
 
SELECT DISTINCT INTO $OUTDEV
	TEST_DESCRIPTION = UAR_GET_CODE_DISPLAY(O.catalog_cd),
	PRIORITY = UAR_GET_CODE_DISPLAY(ORDER_LAB.report_priority_cd),
	FIN = EA.alias,
	ACCESSION = ACC.accession,
	ORDER_LOCATION = UAR_GET_CODE_DISPLAY(ELH.loc_nurse_unit_cd),
	ORDER_DT_TM = cnvtupper(build2(FORMAT(cnvtdatetimeutc(datetimezone(O.orig_order_dt_tm,
																  o.orig_order_tz), 1),"mm/dd/yyyy;;d"), " - ",
						format(O.orig_order_dt_tm, "hh:mm;;s"))),
	COLLECTED = cnvtupper(build2(FORMAT(CONTAINER.drawn_dt_TM,"mm/dd/yyyy;;d"), " - ",
						format(CONTAINER.drawn_dt_TM, "hh:mm;;s"))),
	ORDER_TO_COLL_TAT = DATETIMEDIFF(o.orig_order_dt_tm,container.drawn_dt_tm,4),
	COLLECTED_BY = "",
	RECEIVED_DT_TM =  cnvtupper(build2(FORMAT(CONTAINER.received_dt_tm,  "mm/dd/yyyy;;d"), " - ",
						format(CONTAINER.received_dt_tm, "hh:mm;;s"))),
	COLLECTEDTORECEIVEDTAT = evaluate2(if (container.received_dt_tm > container.drawn_dt_tm)
		DATETIMEDIFF(CONTAINER.drawn_dt_tm,container.received_dt_tm,4)
	else
		0
	endif),
	RECEIVED_BY = P_RECEIVED.name_full_formatted,
	PERFORM_DT_TM = cnvtupper(build2(FORMAT(cnvtdatetimeutc(datetimezone(PR.perform_dt_tm,
																  PR.perform_tz), 1),"mm/dd/yyyy;;d"), " - ",
						format(PR.perform_dt_tm, "hh:mm;;s"))),
	ORDER_COMPLETED = cnvtupper(build2(FORMAT(cnvtdatetimeutc(datetimezone(OA.action_dt_tm,
																  OA.action_tz), 1),"mm/dd/yyyy;;d"), " - ",
						format(OA.action_dt_tm, "hh:mm;;s"))),
	RECEIVEDTOCOMPLETE = evaluate2(if (container.received_dt_tm > OA.action_dt_tm)
		DATETIMEDIFF(OA.action_dt_tm,container.received_dt_tm,4)
	else
		0
	endif),
	COMPLETED_BY = P_COMPLETED.name_full_formatted,
	PERFORMING_LOCATION = UAR_GET_CODE_DISPLAY(ELH.loc_facility_cd),
	ORDERTOPERFORM = evaluate2(if (o.orig_order_dt_tm < PR.perform_dt_tm)
		DATETIMEDIFF(PR.perform_dt_tm,o.current_start_dt_tm,4)
	else 0
	endif),
	PATIENT_CARE_ORDER_DT_TM =  cnvtupper(build2(FORMAT(LACTIC_ORDER.orig_order_dt_tm,"mm/dd/yyyy;;d"), " - ",
						format(LACTIC_ORDER.orig_order_dt_tm, "hh:mm;;s"))),
	TAT = DATETIMEDIFF( OA.action_dt_tm,LACTIC_ORDER.orig_order_dt_tm,4)
 
FROM
	ORDERS O,
	(left join ORDERS LACTIC_ORDER on LACTIC_ORDER.encntr_id = o.encntr_id
		and LACTIC_ORDER.catalog_cd =   3825554851.00),
	(left join ORDER_ORDER_RELTN O_Relation on O_Relation.related_from_order_id = O.order_id),
;	(inner join ORDER_CATALOG OC on OC.catalog_cd = O.catalog_cd),
	(inner join ORDER_LABORATORY Order_lab on O.order_id = Order_lab.order_id),
	(inner join ACCESSION_ORDER_R AO on Order_lab.order_id = AO.order_id),
	(inner join ACCESSION ACC on ACC.accession_id = AO.accession_id),
	(inner join ENCNTR_ALIAS EA on EA.encntr_id = O.encntr_id
		AND EA.encntr_alias_type_cd = 1077
		AND EA.active_ind = 1),
	(inner join ENCNTR_LOC_HIST ELH on O.encntr_id = ELH.encntr_id
		AND ELH.transaction_dt_tm =
			(SELECT MAX(SUBELH.TRANSACTION_DT_TM)
			FROM ENCNTR_LOC_HIST SUBELH
			WHERE SUBELH.TRANSACTION_DT_TM <= O.ORIG_ORDER_DT_TM
				AND O.ENCNTR_ID = SUBELH.ENCNTR_ID
				AND SUBELH.ACTIVE_IND = 1)
		AND OPERATOR(ELH.loc_nurse_unit_cd, op_nurse_unit_var, $userNurseUnit)
		AND OPERATOR(ELH.loc_facility_cd , op_facility_var, $userFacility)
	),
	(inner join ORDER_CONTAINER_R ORDER_CONTAINER on ORDER_CONTAINER.order_id = O.order_id),
	(inner join CONTAINER CONTAINER on CONTAINER.container_id = ORDER_CONTAINER.container_id),
	(inner join PERFORM_RESULT PR on PR.container_id = CONTAINER.container_id
		AND PR.result_status_cd IN (1721,1738)),
	(inner join PRSNL P_RECEIVED on P_RECEIVED.person_id = CONTAINER.received_id),
	(inner join ORDER_ACTION OA on OA.order_id = O.order_id
		AND OA.ACTION_TYPE_CD = 2529.00), /*PI_CDF('COMPLETE',6003)*/
	(inner join PRSNL P_COMPLETED on P_COMPLETED.person_id = OA.action_personnel_id)
 
WHERE
	O.catalog_cd = 3777199959.00
	AND O.ORIG_ORDER_DT_TM BETWEEN cnvtdatetime($userStartDate) AND cnvtdatetime($userEndDate)
ORDER BY
	TAT
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
#exitscript
 
end go
 

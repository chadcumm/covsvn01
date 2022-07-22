/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			David Baumgardner
	Date Written:		Dec 2020
	Solution:
	Source file name:  	cov_amb_outsidelocation_orders.prg
	Object name:		cov_amb_outsidelocation_orders
	Request#:
 
	Program purpose:	Report the outside locations for the TOG to move away from the MPTL
	Executing from:		CCL/DA2/Response Coordination
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod	Mod Date	Developer			     Comment
---	----------	--------------------	------------------------------------------
001	02/09/2021	David Baumgardner		Notes from TOG saying there were orders not being included.
002	07/08/2021	David Baumgardner		Add in the comments section CR8908 request from 5/13/21.
003 09/03/2021	David Baumgardner		CR11161 Request to add in a filter on order status.   Defaulted to Future and the priority to the
										output.
*****************************************************************************/
 
drop program cov_amb_outsidelocation_orders:DBA go
create program cov_amb_outsidelocation_orders:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "Physician Group" = 0
	, "Start Date Time" = ""
	, "End Date Time" = ""
	, "Provider" = 0
	, "Order Status" = VALUE(       2546.00)
 
with OUTDEV, physician_group, start_datetime, end_datetime, userProvider,
	userStatus
 
record outside_order (
	1 	olist[*]
		2	PATIENT_NAME 	= c50
		2   DOB				= dq8
		2   DOB_TZ			= i4
		2	FIN				= c50
		2	ORDER_PHY		= c50
		2	APPT_TYPE		= c50
		2	ORDER_AUTH_NBR	= c50
		2	AUTH_EXPIRE_DT	= C50
		2	GROUP_PRACTICE	= c50
		2	REASON_EXAM		= c50
		2	ORDER_STATE		= c50
		2	ORDER_DT_TM		= dq8
		2	ORDER_MNEMONIC	= c50
		2	ORDER_ID		= f8
		2	REQ_DT_TM		= c50
		2	ACTION_PRSNL	= c50
		2	COMMENTS			= c100
		2	PRIORITY		= c50
)
 
declare num					= i4 with noconstant(0)
declare op_physician_group_var		= c2 with noconstant("")
declare op_status_var		= c2 with noconstant("")
 
if (substring(1, 1, reflect(parameter(parameter2($physician_group), 0))) = "L") ; multiple values
    set op_physician_group_var = "IN"
elseif (parameter(parameter2($physician_group), 1) = 0.0) ; any/no value
    set op_physician_group_var = "!="
else ; single value
    set op_physician_group_var = "="
endif
 
;003 build the operator for the userStatus Filter.
if (substring(1, 1, reflect(parameter(parameter2($userStatus), 0))) = "L") ; multiple values
    set op_status_var = "IN"
elseif (parameter(parameter2($userStatus), 1) = 0.0) ; any/no value
    set op_status_var = "!="
else ; single value
    set op_status_var = "="
endif
; end 003
 
SELECT DISTINCT INTO $outdev
	PATIENT_NAME 	= p.name_full_formatted
	, dob 			= p.birth_dt_tm
	, FIN 			= eaf.alias
	, ORDER_PHY 	= OP.name_full_formatted
	, APPT_TYPE 	= UAR_GET_CODE_DESCRIPTION(o.catalog_cd)
	, ORDER_AUTH_NBR 		= OD_AUTH.oe_field_display_value
	, AUTH_EXPIRE_DT = OD_AUTH_DATE.oe_field_display_value
	, GROUP_PRACTICE = UAR_GET_CODE_DESCRIPTION(E.loc_facility_cd)
	, REASON_EXAM 	= OD_REASON.oe_field_display_value
	, ORDER_STATE 	= UAR_GET_CODE_DESCRIPTION(O.order_status_cd)
	, ORDER_DT_TM 	= o.orig_order_dt_tm
	, ORDER_MNEMONIC = TRIM(o.order_mnemonic,3)
	, REQ_DT_TM 	= ACTION_DT_TM.oe_field_display_value
	, ACTION_PRSNL 	= ACTION_PERSON.oe_field_display_value
	, PRIORITY		= OD_PRIORITY.oe_field_display_value
FROM
	ORDERS O
	, (inner join ORDER_DETAIL ACTION_DT_TM on ACTION_DT_TM.order_id = o.order_id
		and ACTION_DT_TM.oe_field_id =  12620.00
		and ACTION_DT_TM.oe_field_dt_tm_value BETWEEN cnvtdatetime($start_datetime) AND cnvtdatetime($end_datetime)
;003 eliminating duplicate
		and ACTION_DT_TM.action_sequence = (SELECT MAX(sub_od_ACTION_DT_TM.action_sequence)
											FROM ORDER_DETAIL sub_od_ACTION_DT_TM
											WHERE sub_od_ACTION_DT_TM.order_id = o.order_id
												and sub_od_ACTION_DT_TM.oe_field_id = 12620.00
											)
	)
	,(inner join ENCOUNTER E on E.encntr_id = o.originating_encntr_id
		and OPERATOR(E.LOC_FACILITY_CD , op_physician_group_var, $physician_group)
	)
;	,(inner join ORDER_DETAIL OD on od.order_id = o.order_id)
	,(inner join ORDER_DETAIL OD_PRIORITY on OD_PRIORITY.order_id = o.order_id
		and OD_PRIORITY.oe_field_meaning = "PRIORITY"
;003 eliminating duplicate
		and OD_PRIORITY.action_sequence = (SELECT MAX(sub_od_priority.action_sequence)
											FROM ORDER_DETAIL sub_od_priority
											WHERE sub_od_priority.order_id = o.order_id
												and sub_od_priority.oe_field_meaning = "PRIORITY"
											)
	)
	,(inner join ORDER_DETAIL OD_COMMENTTYPE2 on OD_COMMENTTYPE2.order_id = o.order_id
		and OD_COMMENTTYPE2.oe_field_meaning = "COMMENTTYPE2"
		and OD_COMMENTTYPE2.oe_field_display_value = "Outside Location")
	,(left join ORDER_DETAIL OD_NOTES on OD_NOTES.order_id = o.order_id
		and OD_NOTES.oe_field_id = 12654.00)
	,(left join ORDER_DETAIL OD_AUTH_DATE on OD_AUTH_DATE.order_id = o.order_id
		and OD_AUTH_DATE.oe_field_id = 156117623.00
;003 eliminating duplicate
		and OD_AUTH_DATE.action_sequence = (SELECT MAX(sub_od_auth_date.action_sequence)
											FROM ORDER_DETAIL sub_od_auth_date
											WHERE sub_od_auth_date.order_id = o.order_id
												and sub_od_auth_date.oe_field_id = 156117623.00
											)
	)
	,(left join ORDER_DETAIL OD_AUTH on OD_AUTH.order_id = o.order_id
		and OD_AUTH.oe_field_id = 20316465.00
;003
		and OD_AUTH.action_sequence = (SELECT MAX(sub_od_auth.action_sequence)
											FROM ORDER_DETAIL sub_od_auth
											WHERE sub_od_auth.order_id = o.order_id
												and sub_od_auth.oe_field_id = 20316465.00
											)
		)
;end 003
	,(left join PERSON P on p.person_id = o.person_id)
	,(left join ORDER_DETAIL OD_REASON on OD_REASON.order_id = o.order_id
		and OD_REASON.oe_field_id = 12683.00)
	,(inner join ORDER_ACTION OA on OA.order_id = O.order_id
		and oa.action_type_cd =        2534.00)
	,(inner join PERSON OP on OP.person_id = OA.order_provider_id)
	, (inner join ORDER_DETAIL ACTION_PERSON on ACTION_PERSON.order_id = o.order_id
		and ACTION_PERSON.oe_field_id = 73801613.00)
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = 1077.00
		and eaf.active_ind = 1)
;003
WHERE
	OPERATOR(O.order_status_cd , op_status_var, $userStatus)
;end 003
HEAD REPORT
	CNT = 0
	stat = alterlist(outside_order->olist, 100)
DETAIL
	cnt = cnt + 1
    comment = " "
 
	IF(mod(cnt,10) = 1 AND cnt > 100)
		stat = alterlist(outside_order->olist, cnt + 9)
	ENDIF
	outside_order->olist[cnt].PATIENT_NAME = PATIENT_NAME
	outside_order->olist[cnt].ACTION_PRSNL = ACTION_PRSNL
	outside_order->olist[cnt].APPT_TYPE = APPT_TYPE
	outside_order->olist[cnt].AUTH_EXPIRE_DT = AUTH_EXPIRE_DT
	outside_order->olist[cnt].DOB = DOB
	outside_order->olist[cnt].DOB_TZ = p.birth_tz
;
	outside_order->olist[cnt].FIN = FIN
	outside_order->olist[cnt].GROUP_PRACTICE = GROUP_PRACTICE
	outside_order->olist[cnt].ORDER_AUTH_NBR = ORDER_AUTH_NBR
	outside_order->olist[cnt].ORDER_DT_TM = ORDER_DT_TM
	outside_order->olist[cnt].ORDER_MNEMONIC = ORDER_MNEMONIC
	outside_order->olist[cnt].ORDER_PHY = ORDER_PHY
	outside_order->olist[cnt].ORDER_STATE = ORDER_STATE
	outside_order->olist[cnt].REASON_EXAM = REASON_EXAM
	outside_order->olist[cnt].REQ_DT_TM = REQ_DT_TM
	outside_order->olist[cnt].order_id = o.order_id
	outside_order->olist[cnt].priority = PRIORITY
foot report
	stat = alterlist(outside_order->olist, cnt)
 
WITH nocounter,  separator = " ",expand = 1, format, time = 500
 
;002
;build comment data
SELECT INTO $outdev
FROM ORDER_COMMENT OC
		, (left join LONG_TEXT LT on OC.long_text_id = LT.long_text_id)
WHERE
	expand(num, 1, size(outside_order->olist, 5), OC.order_id, outside_order->olist[num].order_id)
 
head OC.order_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(outside_order->olist, 5), OC.order_id, outside_order->olist[numx].order_id)
detail
	if (idx > 0)
		outside_order->olist[idx].comments = replace(replace(substring(0,100,LT.long_text), char(13), " " ,0), char(10), " ",0)
	endif
foot OC.order_id
	outside_order->olist[idx].comments = replace(replace(substring(0,100,LT.long_text), char(13), " " ,0), char(10), " ",0)
WITH nocounter, separator=" ", format, time = 500, expand = 1
 
 
CALL OUTPUT_RECORD_SPREADSHEET(null)
 
SUBROUTINE OUTPUT_RECORD_SPREADSHEET(null)
 
 
	SELECT INTO $outdev
 
	PATIENT_NAME 	= outside_order->olist[D1.seq].PATIENT_NAME
	, dob 			= FORMAT(cnvtdatetimeutc(datetimezone(outside_order->olist[D1.seq].dob,
																  outside_order->olist[D1.seq].dob_tz), 1),"mm/dd/yyyy;;d")
	, FIN 			= outside_order->olist[D1.seq].fin
	, ORDER_PHY 	= outside_order->olist[D1.seq].ORDER_PHY
	, APPT_TYPE 	= outside_order->olist[D1.seq].APPT_TYPE
	, ORDER_AUTH_NBR 		= outside_order->olist[D1.seq].ORDER_AUTH_NBR
	, AUTH_EXPIRE_DT = outside_order->olist[D1.seq].AUTH_EXPIRE_DT
	, GROUP_PRACTICE = outside_order->olist[D1.seq].GROUP_PRACTICE
	, REASON_EXAM 	= outside_order->olist[D1.seq].REASON_EXAM
	, ORDER_STATE 	= outside_order->olist[D1.seq].ORDER_STATE
;003 added the format for the output
	, ORDER_DT_TM 	= FORMAT(outside_order->olist[D1.seq].ORDER_DT_TM,";;Q" )
	, ORDER_MNEMONIC = outside_order->olist[D1.seq].ORDER_MNEMONIC
	, ORDER_PRIORITY = outside_order->olist[D1.seq].priority
	, REQ_DT_TM 	= outside_order->olist[D1.seq].REQ_DT_TM
	, ACTION_PRSNL 	= outside_order->olist[D1.seq].ACTION_PRSNL
	, COMMENT		= outside_order->olist[d1.seq].comments
 
	FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(outside_order->olist, 5)))
 
	PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
end
end
go

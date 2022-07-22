/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/31/2018
	Solution:			Ambulatory
	Source file name:	cov_amb_Orders_Diagnostics.prg
	Object name:		cov_amb_Orders_Diagnostics
	Request #:			1025
 
	Program purpose:	Display patient diagnostic orders.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 001 8/2/2018   Dawn Greer, DBA         Filter out ZZZTEST, ZZZRegression,
                                       TTTTLAB from the report.
 002 8/3/2018   Dawn Greer, DBA         Filter out TEST patients (ZZZ*, TTTT*, FFFF*)
 003 2/28/2019  Dawn Greer, DBA         Fixed DOB displaying wrong date issue.
******************************************************************************/
 
drop program cov_amb_Orders_Diagnostics:DBA go
create program cov_amb_Orders_Diagnostics:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Practice" = 0
	, "Provider" = VALUE(0.0)
	, "Referral Date (Start)" = "SYSDATE"
	, "Referral Date (End)" = "SYSDATE"
	, "Order Status" = VALUE(0.0)
 
with OUTDEV, practice, provider, start_date, end_date, order_status
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare diagnostictests_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16389, "DIAGNOSTICTESTS"))
declare ambulatorys_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 222, "AMBULATORYS"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare order_loc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "DIAGNOSISEXTERNALLOCATIONS"))
declare order_noncov_reasons_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "NONCOVREASONS"))
declare order_previsit_test_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "DIAGNOSTICPREVISITTESTS"))
declare order_appt_date_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "DIAGNOSTICAPPOINTMENTDATE"))
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
declare crlf 						= vc with constant(concat(char(13), char(10)))
declare op_practice_var				= c2 with noconstant("")
declare op_provider_var				= c2 with noconstant("")
declare op_order_status_var			= c2 with noconstant("")
 
 
; define operator for $practice
if (substring(1, 1, reflect(parameter(parameter2($practice), 0))) = "L") ; multiple values selected
    set op_practice_var = "IN"
elseif (parameter(parameter2($practice), 1) = 0.0) ; any selected
    set op_practice_var = "!="
else ; single value selected
    set op_practice_var = "="
endif
 
 
; define operator for $provider
if (substring(1, 1, reflect(parameter(parameter2($provider), 0))) = "L") ; multiple values selected
    set op_provider_var = "IN"
elseif (parameter(parameter2($provider), 1) = 0.0) ; any selected
    set op_provider_var = "!="
else ; single value selected
    set op_provider_var = "="
endif
 
 
; define operator for $order_status
if (substring(1, 1, reflect(parameter(parameter2($order_status), 0))) = "L") ; multiple values selected
    set op_order_status_var = "IN"
elseif (parameter(parameter2($order_status), 1) = 0.0) ; any selected
    set op_order_status_var = "!="
else ; single value selected
    set op_order_status_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record orders_data (
	1	p_practice					= vc
	1	p_provider					= vc
	1	p_start_date				= vc
	1	p_end_date					= vc
	1	p_order_status				= vc
 
	1	orders_cnt					= i4
	1	list[*]
		2	order_id				= f8
		2	order_type_cd			= f8
		2	order_type				= vc
		2	hna_order_mnemonic		= vc
		2	clinical_comment		= vc
 
		2	order_dt_tm				= dq8
		2	order_status_cd			= f8
		2	order_status			= vc
		2	days_outstanding		= i4
		2	time_frame				= vc
		2	due_dt_tm				= dq8
 
 		2	action_comments_cnt		= i4
		2	action_comments			= vc
 
 		2	appt_ind				= i2
		2	appt_date				= dq8
		2	appt_location			= vc
		2	appt_provider			= vc
		2	appt_type				= vc
 
		2	encntr_id				= f8
		2	enc_date				= dq8
		2	enc_number				= vc
 
		2	patient_id				= f8
		2	patient_name			= vc
		2	dob						= dq8
 
		2	diagnosis				= vc
 
		2	order_practice			= vc
		2	order_provider_id		= f8
		2	order_provider_name		= vc
)
 
 
/**************************************************************/
; select practice prompt data
select into "NL:"
from
	ORGANIZATION org
where
	org.organization_id = $practice
 
 
; populate orders_data record structure with practice prompt data
head report
	orders_data->p_practice = org.org_name
 
 
/**************************************************************/
; select provider prompt data
select
if (op_provider_var = "=")
	where
		per.person_id = $provider
else
	where
		per.person_id = 0.0
endif
into "NL:"
from
	PRSNL per
 
 
; populate orders_data record structure with provider prompt data
head report
	orders_data->p_provider = evaluate(op_provider_var, "IN", "Multiple", "!=", "Any (*)", "=", per.name_full_formatted)
 
 
/**************************************************************/
; select order_status prompt data
select
if (op_order_status_var = "=")
	where
		cv.code_value = $order_status
else
	where
		cv.code_value = 0.0
endif
into "NL:"
from
	CODE_VALUE cv
 
 
; populate orders_data record structure with order_status prompt data
head report
	orders_data->p_order_status = evaluate(op_order_status_var, "IN", "Multiple", "!=", "Any (*)", "=", cv.display)
 
 
/**************************************************************/
; select remaining prompt data
select into "NL:"
from
	dummyt
 
 
; populate orders_data record structure with remaining prompt data
head report
	orders_data->p_start_date = format(cnvtdate2($start_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy hh:mm;;d")
	orders_data->p_end_date = format(cnvtdate2($end_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy hh:mm;;d")
 
 
/**************************************************************/
; select diagnostic order data
select into "NL:"
from
	ORDERS o
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_sequence = o.last_action_sequence
		and operator(oa.order_provider_id, op_provider_var, $provider))
 
	, (left join ORDER_COMMENT oc on o.order_id = oc.order_id)
 
	, (left join LONG_TEXT lt on lt.long_text_id = oc.long_text_id
		and lt.parent_entity_id = oc.order_id
		and lt.parent_entity_name = "ORDER_COMMENT")
 
	, (inner join PRSNL per1 on per1.person_id = oa.order_provider_id)
 
	, (inner join PERSON p on p.person_id = o.person_id)
 
	, (inner join ENCOUNTER e on e.encntr_id = evaluate(o.encntr_id, 0.0, o.originating_encntr_id, o.encntr_id))
 
    , (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
    	and ea.encntr_alias_type_cd = fin_var
    	and ea.active_ind = 1)
 
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id
		and operator(org.organization_id, op_practice_var, $practice))
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.action_sequence = o.last_action_sequence
		and od.oe_field_meaning = "ICD9")
 
	, (left join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = od.oe_field_id)
 
    , (left join NOMENCLATURE n on n.nomenclature_id = od.oe_field_value)
 
where
	o.orig_order_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
	and operator(o.order_status_cd, op_order_status_var, $order_status)
	and o.dcp_clin_cat_cd = diagnostictests_var
	and o.active_ind = 1
	and p.name_last_key NOT IN ("ZZZ*","TTTT*","FFFF*") ;002 - Changed to use wildcard ;001 - Filtering out test patients
 
order by
	o.order_id
 
 
; populate orders_data record structure
head report
	cnt = 0
 
	call alterlist(orders_data->list, 100)
 
head o.order_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(orders_data->list, cnt + 9)
	endif
 
	orders_data->orders_cnt						= cnt
	orders_data->list[cnt].order_id				= o.order_id
	orders_data->list[cnt].order_type_cd		= o.dcp_clin_cat_cd
	orders_data->list[cnt].order_type			= uar_get_code_display(o.dcp_clin_cat_cd)
	orders_data->list[cnt].hna_order_mnemonic	= o.hna_order_mnemonic
	orders_data->list[cnt].clinical_comment		= trim(lt.long_text, 3)
 
	orders_data->list[cnt].order_dt_tm			= o.orig_order_dt_tm
	orders_data->list[cnt].order_status_cd		= o.order_status_cd
	orders_data->list[cnt].order_status			= uar_get_code_display(o.order_status_cd)
 
 	if (o.current_start_dt_tm > 0)
		orders_data->list[cnt].days_outstanding = evaluate2(
			if (datetimediff(
				cnvtdatetimerdb(cnvtdatetime(curdate, curtime)),
				cnvtdatetimerdb(o.current_start_dt_tm)) <= 0) 0
			else datetimediff(
				cnvtdatetimerdb(cnvtdatetime(curdate, curtime)),
				cnvtdatetimerdb(o.current_start_dt_tm))
			endif
			)
	endif
;
 	if ((o.orig_order_dt_tm > 0) and (o.current_start_dt_tm > 0))
 		if (o.orig_order_dt_tm <= o.current_start_dt_tm)
			orders_data->list[cnt].time_frame = cnvtage2(
				cnvtdatetimerdb(o.orig_order_dt_tm),
				cnvtdatetimerdb(o.current_start_dt_tm),
				0
				)
 		endif
	endif
 
	orders_data->list[cnt].due_dt_tm				= o.current_start_dt_tm
 
	orders_data->list[cnt].encntr_id				= e.encntr_id
	orders_data->list[cnt].enc_date					= e.create_dt_tm
	orders_data->list[cnt].enc_number				= ea.alias
 
	orders_data->list[cnt].patient_id				= p.person_id
	orders_data->list[cnt].patient_name				= p.name_full_formatted
	orders_data->list[cnt].dob	= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;003-DOB fix
 
	orders_data->list[cnt].diagnosis				= trim(n.source_string, 3)
 
	orders_data->list[cnt].order_practice			= org.org_name
	orders_data->list[cnt].order_provider_id		= per1.person_id
	orders_data->list[cnt].order_provider_name		= per1.name_full_formatted;
 
foot report
	call alterlist(orders_data->list, cnt)
 
WITH nocounter, separator=" ", format, time = 30
 
 
;/**************************************************************/
;; select diagnostic order action comments
;select into "NL:"
;from
;	RVC_COMMENT rc
;
;where
;	expand(num, 1, size(orders_data->list, 5), rc.parent_entity_id , orders_data->list[num].referral_id)
;	and rc.parent_entity_name = "REFERRAL"
;
;order by
;	rc.parent_entity_id
;	, rc.updt_dt_tm
;
;
;; populate orders_data record structure with action comment data
;head rc.parent_entity_id
;	numx = 0
;	idx = 0
;	cntx = 0
;	comments = fillstring(1000, " ")
;
;	idx = locateval(numx, 1, size(orders_data->list, 5), rc.parent_entity_id, orders_data->list[numx].referral_id)
;
;detail
;	if (idx > 0)
;		cntx = cntx + 1
;
;		orders_data->list[idx].action_comments_cnt = cntx
;
;		comments = build2(trim(comments, 3), " ", trim(rc.comment_text, 3))
;	endif
;
;foot rc.parent_entity_id
;	orders_data->list[idx].action_comments = trim(comments, 3)
;
;WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; select diagnostic order associated appointments
select into "NL:"
from
	SCH_APPT sa
 
	, (inner join SCH_BOOKING sb on sb.beg_dt_tm = sa.beg_dt_tm
		and sb.location_cd = sa.appt_location_cd
		and sb.status_meaning = "WRITTEN"
		and (sb.role_meaning = "PATIENT" or sb.role_meaning is null)
		and sb.active_ind = 1)
 
	, (inner join SCH_EVENT se on se.sch_event_id = sa.sch_event_id
		and se.active_ind = 1)
 
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = se.sch_event_id
		and sea.attach_type_cd = order_var
		and sea.active_ind = 1)
 
	, (inner join LOCATION l on l.location_cd = sb.location_cd
		and l.location_type_cd = ambulatorys_var
		and l.active_ind = 1)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id)
 
	, (inner join PERSON p on p.person_id = sa.person_id)
 
where
	expand(num, 1, size(orders_data->list, 5), sea.order_id , orders_data->list[num].order_id)
	and sa.role_meaning = "PATIENT"
	and sa.active_ind = 1
	and p.name_last_key NOT IN ("ZZZ*","TTTT*","FFFF*") ;002 - Changed to use wildcard ;001 - Filtering out test patients
 
order by
	sea.order_id
 
 
; populate orders_data record structure with associated appointment data
head sea.order_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(orders_data->list, 5), sea.order_id, orders_data->list[numx].order_id)
 
	if (idx > 0)
		orders_data->list[idx].appt_ind = 1
		orders_data->list[idx].appt_date = sb.beg_dt_tm
		orders_data->list[idx].appt_location = uar_get_code_display(sb.location_cd)
		orders_data->list[idx].appt_provider = uar_get_code_display(sb.resource_cd)
		orders_data->list[idx].appt_type = uar_get_code_display(sb.appt_type_cd)
	endif
 
WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; select diagnostic order ad hoc forms data
select into "NL:"
from
	ORDERS o
 
	, (inner join DCP_FORMS_ACTIVITY dfa on dfa.encntr_id = o.encntr_id
		and cnvtupper(dfa.description) = "DIAGNOSTIC NON-COV TRACKING"
		and dfa.flags = 2
		and dfa.active_ind = 1)
 
	, (inner join DCP_FORMS_ACTIVITY_COMP dfac on dfac.dcp_forms_activity_id = dfa.dcp_forms_activity_id
    	and dfac.component_cd = value(uar_get_code_by("DISPLAY_KEY", 18189, "PRIMARYEVENTID"))
		and dfac.parent_entity_name = "CLINICAL_EVENT")
 
	, (inner join CLINICAL_EVENT ce1 on ce1.event_id = dfac.parent_entity_id
	    and ce1.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		and ce1.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "ROOT")))
 
	, (inner join CLINICAL_EVENT ce2 on ce2.parent_event_id = ce1.event_id
	    and ce2.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		and ce2.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "CHILD")))
 
	, (inner join CLINICAL_EVENT ce3 on ce3.parent_event_id = ce2.event_id
	    and ce3.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		and ce3.event_reltn_cd = value(uar_get_code_by("MEANING", 24, "CHILD")))
 
	, (left join CE_DATE_RESULT cedr on cedr.event_id = ce3.event_id
	    and cedr.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"))
 
where
	expand(num, 1, size(orders_data->list, 5), o.order_id, orders_data->list[num].order_id)
 
order by
	o.order_id
	, ce3.event_id
 
 
; populate orders_data record structure with ad hoc forms data
head o.order_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(orders_data->list, 5), o.order_id, orders_data->list[numx].order_id)
 
detail
 	if (idx > 0)
 		if (orders_data->list[idx].appt_ind = 0)
			case (ce3.event_cd)
				of order_appt_date_var	: orders_data->list[idx].appt_date = cedr.result_dt_tm
				of order_loc_var		: orders_data->list[idx].appt_location = trim(ce3.result_val, 3)
			endcase
 		endif
 	endif
 
foot o.order_id
 	if (idx > 0)
		if (orders_data->list[idx].appt_ind = 0)
			orders_data->list[idx].appt_ind = 1
		endif
	endif
 
WITH nocounter, separator=" ", format, expand = 1
 
 
call echorecord(orders_data)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

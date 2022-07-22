/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/30/2018
	Solution:			Ambulatory
	Source file name:	cov_amb_Orders_Referrals.prg
	Object name:		cov_amb_Orders_Referrals
	Request #:			1025
 
	Program purpose:	Display patient referral orders.
 
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
 
drop program cov_amb_Orders_Referrals:DBA go
create program cov_amb_Orders_Referrals:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"        ;* Enter or select the printer or file name to send this report to.
	, "Practice" = 0
	, "Provider" = VALUE(0.0)
	, "Referral Date (Start)" = "SYSDATE"
	, "Referral Date (End)" = "SYSDATE"
	, "Referral Status" = VALUE(0.0)
 
with OUTDEV, practice, provider, start_date, end_date, ref_status
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare referral_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "REFERRAL"))
declare confirmed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED"))
declare ambulatorys_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 222, "AMBULATORYS"))
declare external_ps_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4358008, "EXTERNAL"))
declare external_otr_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 278, "EXTERNAL"))
declare compress_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 120, "NOCOMPRESSION"))
declare nocompress_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 120, "OCFCOMPRESSION"))
declare ref_info_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "ADDITIONALREFERRALINFORMATION"))
declare ref_appt_date_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "REFERRALAPPOINTMENTDATE"))
declare ref_provider_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "REFERRALPROVIDER"))
declare ref_noncov_reasons_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "NONCOVREASONS"))
declare ref_ord_details_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "AMBREFERRALORDERDETAILS"))
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
declare crlf 						= vc with constant(concat(char(13), char(10)))
declare op_practice_var				= c2 with noconstant("")
declare op_provider_var				= c2 with noconstant("")
declare op_ref_status_var			= c2 with noconstant("")
 
 
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
 
 
; define operator for $ref_status
if (substring(1, 1, reflect(parameter(parameter2($ref_status), 0))) = "L") ; multiple values selected
    set op_ref_status_var = "IN"
elseif (parameter(parameter2($ref_status), 1) = 0.0) ; any selected
    set op_ref_status_var = "!="
else ; single value selected
    set op_ref_status_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record orders_data (
	1	p_practice					= vc
	1	p_provider					= vc
	1	p_start_date				= vc
	1	p_end_date					= vc
	1	p_ref_status				= vc
 
	1	orders_cnt					= i4
	1	list[*]
		2	order_id				= f8
		2	order_type_cd			= f8
		2	order_type				= vc
		2	hna_order_mnemonic		= vc
		2	clinical_comment		= vc
 
		2	referral_id				= f8
		2	ref_dt_tm				= dq8
		2	ref_status_cd			= f8
		2	ref_status				= vc
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
		2	refer_from_id			= f8
		2	refer_from_name			= vc
		2	refer_to_id				= f8
		2	refer_to_name			= vc
		2	refer_to_practice_id	= f8
		2	refer_to_practice_name	= vc
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
; select ref_status prompt data
select
if (op_ref_status_var = "=")
	where
		cv.code_value = $ref_status
else
	where
		cv.code_value = 0.0
endif
into "NL:"
from
	CODE_VALUE cv
 
 
; populate orders_data record structure with ref_status prompt data
head report
	orders_data->p_ref_status = evaluate(op_ref_status_var, "IN", "Multiple", "!=", "Any (*)", "=", cv.display)
 
 
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
; select referral order data
select into "NL:"
from
	REFERRAL r
 
	, (inner join ORDERS o on o.order_id = r.order_id)
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_sequence = o.last_action_sequence
		and operator(oa.order_provider_id, op_provider_var, $provider))
 
	, (left join ORDER_COMMENT oc on o.order_id = oc.order_id)
 
	, (left join LONG_TEXT lt on lt.long_text_id = oc.long_text_id
		and lt.parent_entity_id = oc.order_id
		and lt.parent_entity_name = "ORDER_COMMENT")
 
	, (inner join PRSNL per1 on per1.person_id = oa.order_provider_id)
 
	, (left join PRSNL per2 on per2.person_id = r.refer_from_provider_id)
 
	, (left join PRSNL per3 on per3.person_id = r.refer_to_provider_id)
 
	, (inner join PERSON p on p.person_id = r.person_id)
 
	, (inner join ENCOUNTER e on e.encntr_id = r.outbound_encntr_id)
 
    , (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
    	and ea.encntr_alias_type_cd = fin_var
    	and ea.active_ind = 1)
 
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id
		and operator(org.organization_id, op_practice_var, $practice))
 
   	, (left join PRACTICE_SITE ps on ps.practice_site_id = r.refer_to_practice_site_id)
 
   	, (left join ORG_TYPE_RELTN otr on otr.organization_id = ps.primary_entity_id
		and otr.org_type_cd = external_otr_var)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.action_sequence = o.last_action_sequence
		and od.oe_field_meaning = "ICD9")
 
	, (left join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = od.oe_field_id)
 
    , (left join NOMENCLATURE n on n.nomenclature_id = od.oe_field_value)
 
where
	r.requested_start_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
	and operator(r.referral_status_cd, op_ref_status_var, $ref_status)
	and r.active_ind = 1
	and p.name_last_key NOT IN ("ZZZ*","TTTT*","FFFF*") ;002 - Changed to use wildcard ;001 - Filtering out test patients
 
order by
	r.referral_id
 
 
; populate orders_data record structure
head report
	cnt = 0
 
	call alterlist(orders_data->list, 100)
 
head r.referral_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(orders_data->list, cnt + 9)
	endif
 
	orders_data->orders_cnt						= cnt
	orders_data->list[cnt].order_id				= o.order_id
	orders_data->list[cnt].order_type_cd		= o.catalog_type_cd
	orders_data->list[cnt].order_type			= uar_get_code_display(o.catalog_type_cd)
	orders_data->list[cnt].hna_order_mnemonic	= o.hna_order_mnemonic
	orders_data->list[cnt].clinical_comment		= trim(lt.long_text, 3)
 
	orders_data->list[cnt].referral_id			= r.referral_id
	orders_data->list[cnt].ref_dt_tm			= r.referral_written_dt_tm
	orders_data->list[cnt].ref_status_cd		= r.referral_status_cd
	orders_data->list[cnt].ref_status			= uar_get_code_display(r.referral_status_cd)
 
 	if (r.service_by_dt_tm > 0)
		orders_data->list[cnt].days_outstanding	= evaluate2(
			if (datetimediff(
				cnvtdatetimerdb(cnvtdatetime(curdate, curtime)),
				cnvtdatetimerdb(r.service_by_dt_tm)) <= 0) 0
			else datetimediff(
				cnvtdatetimerdb(cnvtdatetime(curdate, curtime)),
				cnvtdatetimerdb(r.service_by_dt_tm))
			endif
			)
	endif
 
 	if ((r.requested_start_dt_tm > 0) and (r.service_by_dt_tm > 0))
		orders_data->list[cnt].time_frame		= cnvtage2(
			cnvtdatetimerdb(r.requested_start_dt_tm),
			cnvtdatetimerdb(r.service_by_dt_tm),
			0
			)
	endif
 
	orders_data->list[cnt].due_dt_tm				= r.service_by_dt_tm
 
	orders_data->list[cnt].encntr_id				= e.encntr_id
	orders_data->list[cnt].enc_date					= e.create_dt_tm
	orders_data->list[cnt].enc_number				= ea.alias
 
	orders_data->list[cnt].patient_id				= p.person_id
	orders_data->list[cnt].patient_name				= p.name_full_formatted
	orders_data->list[cnt].dob		= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;003-DOB fix
 
	orders_data->list[cnt].diagnosis				= trim(n.source_string, 3)
 
	orders_data->list[cnt].order_practice			= org.org_name
	orders_data->list[cnt].order_provider_id		= per1.person_id
	orders_data->list[cnt].order_provider_name		= per1.name_full_formatted
	orders_data->list[cnt].refer_from_id			= per2.person_id
	orders_data->list[cnt].refer_from_name			= per2.name_full_formatted
	orders_data->list[cnt].refer_to_id				= per3.person_id
	orders_data->list[cnt].refer_to_name			= per3.name_full_formatted
	orders_data->list[cnt].refer_to_practice_id		= r.refer_to_practice_site_id
	orders_data->list[cnt].refer_to_practice_name	= ps.practice_site_display
 
foot report
	call alterlist(orders_data->list, cnt)
 
WITH nocounter, separator=" ", format, time = 30
 
 
/**************************************************************/
; select referral order action comments
select into "NL:"
from
	RVC_COMMENT rc
 
where
	expand(num, 1, size(orders_data->list, 5), rc.parent_entity_id , orders_data->list[num].referral_id)
	and rc.parent_entity_name = "REFERRAL"
 
order by
	rc.parent_entity_id
	, rc.updt_dt_tm
 
 
; populate orders_data record structure with action comment data
head rc.parent_entity_id
	numx = 0
	idx = 0
	cntx = 0
	comments = fillstring(1000, " ")
 
	idx = locateval(numx, 1, size(orders_data->list, 5), rc.parent_entity_id, orders_data->list[numx].referral_id)
 
detail
	if (idx > 0)
		cntx = cntx + 1
 
		orders_data->list[idx].action_comments_cnt = cntx
 
		comments = build2(trim(comments, 3), " ", trim(rc.comment_text, 3))
	endif
 
foot rc.parent_entity_id
	orders_data->list[idx].action_comments = trim(comments, 3)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; select referral order associated appointments
select into "NL:"
from
	REFERRAL_ENTITY_RELTN rer
 
	, (inner join SCH_APPT sa on sa.sch_event_id = rer.parent_entity_id
		and sa.role_meaning = "PATIENT"
		and sa.active_ind = 1)
 
	, (inner join SCH_BOOKING sb on sb.beg_dt_tm = sa.beg_dt_tm
		and sb.location_cd = sa.appt_location_cd
		and sb.status_meaning = "WRITTEN"
		and (sb.role_meaning = "RESOURCE" or sb.role_meaning is null)
		and sb.active_ind = 1)
 
	, (inner join LOCATION l on l.location_cd = sb.location_cd
		and l.location_type_cd = 772.00
		and l.active_ind = 1)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id)
 
	, (inner join PERSON p on p.person_id = sa.person_id)
 
where
	expand(num, 1, size(orders_data->list, 5), rer.referral_id , orders_data->list[num].referral_id)
	and rer.parent_entity_name = "SCH_EVENT"
	and p.name_last_key NOT IN ("ZZZ*","TTTT*","FFFF*") ;002 - Changed to use wildcard ;001 - Filtering out test patients
 
order by
	rer.referral_id
	, sb.beg_dt_tm
 
 
; populate orders_data record structure with associated appointment data
head rer.referral_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(orders_data->list, 5), rer.referral_id, orders_data->list[numx].referral_id)
 
	if (idx > 0)
		orders_data->list[idx].appt_ind = 1
		orders_data->list[idx].appt_date = sb.beg_dt_tm
		orders_data->list[idx].appt_location = uar_get_code_display(sb.location_cd)
		orders_data->list[idx].appt_provider = uar_get_code_display(sb.resource_cd)
		orders_data->list[idx].appt_type = uar_get_code_display(sb.appt_type_cd)
	endif
 
WITH nocounter, separator=" ", format, expand = 1
 
 
/**************************************************************/
; select referral order ad hoc forms data
select into "NL:"
from
	REFERRAL r
 
	, (inner join DCP_FORMS_ACTIVITY dfa on dfa.encntr_id = r.outbound_encntr_id
		and cnvtupper(dfa.description) = "REFERRAL INFORMATION"
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
	expand(num, 1, size(orders_data->list, 5), r.referral_id, orders_data->list[num].referral_id)
 
order by
	r.referral_id
	, ce3.event_id
 
 
; populate orders_data record structure with ad hoc forms data
head r.referral_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(orders_data->list, 5), r.referral_id, orders_data->list[numx].referral_id)
 
detail
 	if (idx > 0)
 		if (orders_data->list[idx].appt_ind = 0)
			case (ce3.event_cd)
				of ref_appt_date_var		: orders_data->list[idx].appt_date = cedr.result_dt_tm
				of ref_provider_var			: orders_data->list[idx].appt_provider = trim(ce3.result_val, 3)
			endcase
 		endif
 	endif
 
foot r.referral_id
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
 

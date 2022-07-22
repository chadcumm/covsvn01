/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/18/2018
	Solution:			Ambulatory
	Source file name:	cov_amb_Orders_Diags_Referrals.prg
	Object name:		cov_amb_Orders_Diags_Referrals
	Request #:			1025
 
	Program purpose:	Display patient orders that are ordered and/or
						not completed.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_amb_Orders_Diags_Referrals:DBA go
create program cov_amb_Orders_Diags_Referrals:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Practice(s)" = 0
	, "Provider(s)" = 0
	, "Date Prescribed (Start)" = "CURDATE"
	, "Date Prescribed (End)" = "CURDATE"
 
with OUTDEV, practice, provider, start_date, end_date
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare referral_o_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "REFERRAL"))
declare radiology_o_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "RADIOLOGY"))
declare ordered_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare num						= i4 with noconstant(0)
declare novalue					= vc with constant("Not Available")
declare op_practice_var			= c2 with noconstant("")
declare op_provider_var			= c2 with noconstant("")
 
 
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
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record orders_data (
	1	p_practice				= vc
	1	p_provider				= vc
	1	p_start_date			= vc
	1	p_end_date				= vc
 
	1	orders_cnt				= i4
	1	list[*]
		2	order_id			= f8
		2	order_type_cd		= f8
		2	order_type			= vc
		2	order_status_cd		= f8
		2	order_status		= vc
		2	order_dt_tm			= dq8
		2	hna_order_mnemonic	= vc
		2	days_outstanding	= i4
		2	appt_dt_tm			= dq8
		2	time_frame			= vc
		2	due_dt_tm			= dq8
 
		2	referral_id			= f8
 		2	ref_comments_cnt	= i4
		2	ref_comments[*]		= i4	; action comments
			3	parent_id		= f8
			3	parent_name		= vc
			3	comment_text	= vc
 
		2	encntr_id			= f8
		2	enc_date			= dq8
		2	enc_number			= vc
 
		2	patient				= f8
		2	patient_name		= vc
		2	dob					= dq8
 
		2	diagnosis			= vc
 
		2	practice			= vc
		2	provider			= f8
		2	provider_name		= vc
		2	specialist			= f8
		2	specialist_name		= vc
)
 
 
; select practice prompt data
select into "NL:"
from
	ORGANIZATION org
where
	org.organization_id = $practice
 
 
; populate orders_data record structure with practice prompt data
head report
	orders_data->p_practice = org.org_name
 
 
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
 
 
; select remaining prompt data
select into "NL:"
from
	dummyt
 
 
; populate orders_data record structure with remaining prompt data
head report
	orders_data->p_start_date = format(cnvtdate2($start_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
	orders_data->p_end_date = format(cnvtdate2($end_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
 
; select referral order data
select into "NL:"
from
	ORDERS o
 
	, (left join REFERRAL r on r.order_id = o.order_id)
 
    , (inner join ORDER_ACTION oa on oa.order_id = o.order_id
    	and oa.action_sequence = o.last_action_sequence)
 
    , (inner join PRSNL pero on pero.person_id = oa.order_provider_id
;    	and operator(pero.person_id, op_provider_var, $provider))
)
 
;    , (inner join PRSNL pera on pera.person_id = oa.action_personnel_id)
 
	, (inner join PERSON p on p.person_id = o.person_id)
 
	, (inner join ENCOUNTER e on e.encntr_id = o.encntr_id)
;		and e.active_ind = 1)
 
    , (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
    	and ea.encntr_alias_type_cd = fin_var
    	and ea.active_ind = 1)
;
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id
;		and operator(org.organization_id, op_practice_var, $practice))
)
 
where
	o.orig_order_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
	and o.catalog_type_cd in (referral_o_var, radiology_o_var)
;	and o.order_status_cd = ordered_var ; TODO: Uncomment after testing.
 
	and o.person_id = 15556719.00 ; TODO: Remove after testing.
 
 
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
	orders_data->list[cnt].order_type_cd		= o.catalog_type_cd
	orders_data->list[cnt].order_type			= uar_get_code_display(o.catalog_type_cd)
	orders_data->list[cnt].order_status_cd		= o.order_status_cd
	orders_data->list[cnt].order_status			= uar_get_code_display(o.order_status_cd)
	orders_data->list[cnt].order_dt_tm			= o.current_start_dt_tm
	orders_data->list[cnt].hna_order_mnemonic	= o.hna_order_mnemonic
 
 	if (r.service_by_dt_tm > 0)
		orders_data->list[cnt].days_outstanding		= evaluate2(
			if (datetimediff(
				cnvtdatetimerdb(cnvtdatetime(curdate, curtime)),
				cnvtdatetimerdb(r.service_by_dt_tm)) <= 0) 0
			else datetimediff(
				cnvtdatetimerdb(cnvtdatetime(curdate, curtime)),
				cnvtdatetimerdb(r.service_by_dt_tm))
			endif
			)
	endif
 
;	orders_data->list[cnt].appt_dt_tm			= ?
 
 	if ((r.requested_start_dt_tm > 0) and (r.service_by_dt_tm > 0))
		orders_data->list[cnt].time_frame			= cnvtage2(
			cnvtdatetimerdb(r.requested_start_dt_tm),
			cnvtdatetimerdb(r.service_by_dt_tm),
			0
			)
	endif
 
	orders_data->list[cnt].referral_id			= r.referral_id
	orders_data->list[cnt].due_dt_tm			= r.service_by_dt_tm
 
	orders_data->list[cnt].encntr_id			= e.encntr_id
	orders_data->list[cnt].enc_date				= e.create_dt_tm
	orders_data->list[cnt].enc_number			= ea.alias
 
	orders_data->list[cnt].patient				= p.person_id
	orders_data->list[cnt].patient_name			= p.name_full_formatted
	orders_data->list[cnt].dob					= p.birth_dt_tm
 
;	orders_data->list[cnt].diagnosis			= ?
 
	orders_data->list[cnt].practice				= org.org_name
	orders_data->list[cnt].provider				= pero.person_id
	orders_data->list[cnt].provider_name		= pero.name_full_formatted
;	orders_data->list[cnt].specialist			= ?.person_id
;	orders_data->list[cnt].specialist_name		= ?.name_full_formatted
 
foot report
	call alterlist(orders_data->list, cnt)
 
WITH nocounter, separator=" ", format, time = 30
 
 
; select referral order comments (action comments)
select into "NL:"
from
	RVC_COMMENT rc
 
where
	expand(num, 1, size(orders_data->list, 5), rc.parent_entity_id , orders_data->list[num].referral_id)
	and rc.parent_entity_name = "REFERRAL"
 
order by
	rc.updt_dt_tm
 
 
; populate orders_data record structure with referral order comment data
head rc.parent_entity_id
	numx = 0
	idx = 0
	cntx = 0
 
	idx = locateval(numx, 1, size(orders_data->list, 5), rc.parent_entity_id, orders_data->list[numx].referral_id)
 
	if (idx > 0)
		call alterlist(orders_data->list[idx].ref_comments, 10)
	endif
 
detail
	if (idx > 0)
		cntx = cntx + 1
 
		if (mod(cntx, 10) = 1 and cntx > 10)
			call alterlist(orders_data->list[idx].ref_comments, cntx + 9)
		endif
 
		orders_data->list[idx].ref_comments_cnt = cntx
		orders_data->list[idx].ref_comments[cntx].parent_id = rc.parent_entity_id
		orders_data->list[idx].ref_comments[cntx].parent_name = rc.parent_entity_name
		orders_data->list[idx].ref_comments[cntx].comment_text = trim(rc.comment_text, 3)
	endif
 
foot rc.parent_entity_id
	call alterlist(orders_data->list[idx].ref_comments, cntx)
 
WITH nocounter, separator=" ", format, expand = 1
 
 
call echorecord(orders_data)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

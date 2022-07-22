/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Alix Govatsos
	Date Written:		05/22/2018
	Solution:			Ambulatory
	Source file name:	cov_amb_ref_arg
	Object name:		cov_amb_ref_arg
	Request #:			1025
 
	Program purpose:	Display patient referral orders.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program 	cov_amb_ref_arg:DBA go
create program 	cov_amb_ref_arg:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Practice" = 0
	, "Provider" = 0
	, "Referral Date (Start)" = "SYSDATE"
	, "Referral Date (End)" = "SYSDATE"
	, "Referral Status" = 0
 
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
declare num							= i4 with noconstant(0)
declare novalue						= vc with constant("Not Available")
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
	1	p_practice				= vc
	1	p_provider				= vc
	1	p_start_date			= vc
	1	p_end_date				= vc
	1	p_ref_status			= vc
 
	1	orders_cnt				= i4
	1	list[*]
		2	order_id			= f8
		2	order_type_cd		= f8
		2	order_type			= vc
		2	hna_order_mnemonic	= vc
		2	clinical_comment	= vc
 
		2	referral_id			= f8
		2	ref_dt_tm			= dq8
		2	ref_status_cd		= f8
		2	ref_status			= vc
		2	days_outstanding	= i4
		2	time_frame			= vc
		2	due_dt_tm			= dq8
 
 		2	action_comments_cnt	= i4
		2	action_comments[*]
			3	parent_id		= f8
			3	parent_name		= vc
			3	action_comment	= vc
 
 		2	appts_cnt			= i4
		2	appts[*]
			3	patient_id		= f8
			3	due_date		= dq8
			3	location_cd		= f8
			3	location		= vc
			3	resource_cd		= f8
			3	resource		= vc
			3	appt_type_cd	= f8
			3	appt_type		= vc
 
		2	encntr_id			= f8
		2	enc_date			= dq8
		2	enc_number			= vc
 
		2	patient_id			= f8
		2	patient_name		= vc
		2	dob					= dq8
 
		2	diagnosis			= vc
 
		2	practice			= vc
		2	provider_id			= f8
		2	provider_name		= vc
		2	specialist_id		= f8
		2	specialist_name		= vc
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
 
with nocounter
 
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
 
 with nocounter
 
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
 
with nocounter
 
 
 
 
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
 
call echorecord(orders_data)
 
;; select referral order comments (action comments)
;select into "NL:"
;from
;	RVC_COMMENT rc
;
;where
;	expand(num, 1, size(orders_data->list, 5), rc.parent_entity_id , orders_data->list[num].referral_id)
;	and rc.parent_entity_name = "REFERRAL"
;
;order by
;	rc.updt_dt_tm
;
;
;; populate orders_data record structure with referral order comment data
;head rc.parent_entity_id
;	numx = 0
;	idx = 0
;	cntx = 0
;
;	idx = locateval(numx, 1, size(orders_data->list, 5), rc.parent_entity_id, orders_data->list[numx].referral_id)
;
;	if (idx > 0)
;		call alterlist(orders_data->list[idx].action_comments, 10)
;	endif
;
;detail
;	if (idx > 0)
;		cntx = cntx + 1
;
;		if (mod(cntx, 10) = 1 and cntx > 10)
;			call alterlist(orders_data->list[idx].action_comments, cntx + 9)
;		endif
;
;		orders_data->list[idx].action_comments_cnt = cntx
;		orders_data->list[idx].action_comments[cntx].parent_id = rc.parent_entity_id
;		orders_data->list[idx].action_comments[cntx].parent_name = rc.parent_entity_name
;		orders_data->list[idx].action_comments[cntx].action_comment = trim(rc.comment_text, 3)
;	endif
;
;foot rc.parent_entity_id
;	call alterlist(orders_data->list[idx].action_comments, cntx)
;
;WITH nocounter, separator=" ", format, expand = 1
;
 
;/**************************************************************/
;; select scheduled appointments
;select into "NL:"
;from
;	SCH_BOOKING sb
;
;	, (inner join SCH_APPT sa on sa.beg_dt_tm = sb.beg_dt_tm
;		and sa.appt_location_cd = sb.location_cd
;		and sa.sch_state_cd = confirmed_var
;		and sa.role_meaning = "PATIENT"
;		and sa.active_ind = 1)
;
;	, (inner join LOCATION l on l.location_cd = sb.location_cd
;		and l.location_type_cd = ambulatorys_var
;		and l.active_ind = 1)
;
;	, (inner join ORGANIZATION org on org.organization_id = l.organization_id)
;
;	, (inner join PERSON p on p.person_id = sa.person_id)
;
;where
;	expand(num, 1, size(orders_data->list, 5), sa.person_id, orders_data->list[num].patient_id)
;	and sb.status_meaning = "WRITTEN"
;	and (sb.role_meaning = "RESOURCE" or sb.role_meaning is null)
;	and sb.beg_dt_tm >= cnvtdatetime(cnvtdate(sysdate), 0)
;	and sb.active_ind = 1
;
;order by
;	sa.person_id
;	, sb.beg_dt_tm
;
;
;; populate orders_data record structure with scheduled appointment data
;head report
;	numx = size(orders_data->list, 5)
;
;head sa.person_id
;	cntx = 0
;
;head sb.beg_dt_tm
;	cntx = cntx + 1
;
; 	for (i = 1 to numx)
;		if (orders_data->list[i].patient_id = sa.person_id)
;			call alterlist(orders_data->list[i].appts, cntx)
;
;			orders_data->list[i].appts_cnt = cntx
;			orders_data->list[i].appts[cntx].patient_id = sa.person_id
;			orders_data->list[i].appts[cntx].due_date = sb.beg_dt_tm
;			orders_data->list[i].appts[cntx].location_cd = sb.location_cd
;			orders_data->list[i].appts[cntx].location = uar_get_code_display(sb.location_cd)
;			orders_data->list[i].appts[cntx].resource_cd = sb.resource_cd
;			orders_data->list[i].appts[cntx].resource = uar_get_code_display(sb.resource_cd)
;			orders_data->list[i].appts[cntx].appt_type_cd = sb.appt_type_cd
;			orders_data->list[i].appts[cntx].appt_type = uar_get_code_display(sb.appt_type_cd)
;		endif
; 	endfor
;
;WITH nocounter, separator=" ", format, expand = 1
;
;
;call echorecord(orders_data)
;
;/**************************************************************
;; DVDev DEFINED SUBROUTINES
;**************************************************************/
;
end
go
 
 

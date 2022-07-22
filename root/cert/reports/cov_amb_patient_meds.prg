/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/14/2018
	Solution:			Ambulatory
	Source file name:	cov_amb_Patient_Meds.prg
	Object name:		cov_amb_Patient_Meds
	Request #:			1026
 
	Program purpose:	Display patient medications and samples.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 001 8/2/2018   Dawn Greer, DBA         Filter out ZZZTEST, ZZZRegression,
                                        TTTTLAB from the report.
 002 10/02/2019 David Baumgardner,      Needing to add the communication type 
                Programmer Analyst      for the auditing of the misuse of the 
                                        Contingency / No cosign order type.  Please see CR6200 (old system 5299)
******************************************************************************/
 
drop program cov_amb_Patient_Meds:DBA go
create program cov_amb_Patient_Meds:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Practice(s)" = 0
	, "Date Prescribed (Start)" = "CURDATE"
	, "Date Prescribed (End)" = "CURDATE"
	, "Provider(s)" = 0
	, "Show Samples Only?" = 0
	, "Dispensed Only?" = 0
	, "Medication Name" = ""                  ;* Use Exact or Wildcards (*)
 
with OUTDEV, practice, start_date, end_date, provider, samples_only,
	dispensed_only, med_name
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare pharmacy_o_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 106, "PHARMACY"))
declare pharmacy_oef_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "PHARMACY"))
declare order_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare ordered_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare num					= i4 with noconstant(0)
declare novalue				= vc with constant("Not Available")
declare op_practice_var		= c2 with noconstant("")
declare op_provider_var		= c2 with noconstant("")
 
 
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
 
record pat_meds (
	1	p_practice				= vc
	1	p_start_date			= vc
	1	p_end_date				= vc
	1	p_provider				= vc
	1	p_samples_only			= vc
	1	p_dispensed_only		= vc
	1	p_med_name				= vc
 
	1	meds_cnt				= i4
	1	list[*]
		2	order_id			= f8
		2	practice			= vc
		2	provider			= f8
		2	provider_name		= vc
		2	patient				= f8
		2	patient_name		= vc
		2	dob					= dq8
 
		2	encntr_id			= f8
		2	enc_date			= dq8
		2	enc_number			= vc
 
		2	med_type			= vc
		2	med_name			= vc
		2	med_qty				= vc
		2	med_start_dt_tm		= dq8
		2	med_stop_dt_tm		= dq8
 
		2	samples				= vc
		2	lot_number 			= vc
		2	sample_exp_dt_tm	= dq8
 
		2	last_audit			= vc
		2	created_by			= f8
		2	created_name		= vc
		2	created_dt_tm 		= dq8
		
		; 002 adding communication per CR6200
		2	communication_type	= vc
)
 
 
; select practice prompt data
select into "NL:"
from
	ORGANIZATION org
where
	org.organization_id = $practice
 
 
; populate pat_meds record structure with practice prompt data
head report
	pat_meds->p_practice = org.org_name
 
 
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
 
 
; populate pat_meds record structure with provider prompt data
head report
	pat_meds->p_provider = evaluate(op_provider_var, "IN", "Multiple", "!=", "Any (*)", "=", per.name_full_formatted)
 
 
; select remaining prompt data
select into "NL:"
from
	dummyt
 
 
; populate pat_meds record structure with remaining prompt data
head report
	pat_meds->p_start_date = format(cnvtdate2($start_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
	pat_meds->p_end_date = format(cnvtdate2($end_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
	pat_meds->p_samples_only = evaluate(cnvtstring($samples_only), "1", "Y", "N")
	pat_meds->p_dispensed_only = evaluate(cnvtstring($dispensed_only), "1", "Y", "N")
	pat_meds->p_med_name = $med_name
 
 
; select patient medication data
select
if (($samples_only = 1) and ($dispensed_only = 0))
	where
		o.current_start_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
		and o.activity_type_cd = pharmacy_o_var
		and (
			cnvtlower(o.hna_order_mnemonic) like $med_name
			or cnvtlower(o.order_mnemonic) like $med_name
			or cnvtlower(o.ordered_as_mnemonic) like $med_name
			or $med_name = ""
		)
		and o.order_id in (
			select
				od.order_id
			from
				ORDER_DETAIL od
 
			    , (inner join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = od.oe_field_id
			    	and oef.catalog_type_cd = pharmacy_oef_var
			    	and oef.description in ("Pharmacy Lot Number for Samples Given", "Pharmacy Sample Expiration Date"))
			where
	    		od.oe_field_meaning = "OTHER"
				and od.action_sequence = 1
		)
elseif (($samples_only = 0) and ($dispensed_only = 1))
	where
		o.current_start_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
		and o.activity_type_cd = pharmacy_o_var
		and (
			cnvtlower(o.hna_order_mnemonic) like $med_name
			or cnvtlower(o.order_mnemonic) like $med_name
			or cnvtlower(o.ordered_as_mnemonic) like $med_name
			or $med_name = ""
		)
		and o.order_id in (
			select
				od.order_id
			from
				ORDER_DETAIL od
			where
				od.oe_field_meaning = "DISPENSEQTY"
				and od.action_sequence = 1
				and isnumeric(od.oe_field_display_value) = 1
				and od.oe_field_display_value != "0"
		)
elseif (($samples_only = 1) and ($dispensed_only = 1))
	where
		o.current_start_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
		and o.activity_type_cd = pharmacy_o_var
		and (
			cnvtlower(o.hna_order_mnemonic) like $med_name
			or cnvtlower(o.order_mnemonic) like $med_name
			or cnvtlower(o.ordered_as_mnemonic) like $med_name
			or $med_name = ""
		)
		and o.order_id in (
			select
				od.order_id
			from
				ORDER_DETAIL od
 
			    , (inner join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = od.oe_field_id
			    	and oef.catalog_type_cd = pharmacy_oef_var
			    	and oef.description in ("Pharmacy Lot Number for Samples Given", "Pharmacy Sample Expiration Date"))
			where
	    		od.oe_field_meaning = "OTHER"
				and od.action_sequence = 1
		)
		and o.order_id in (
			select
				od.order_id
			from
				ORDER_DETAIL od
			where
				od.oe_field_meaning = "DISPENSEQTY"
				and od.action_sequence = 1
				and isnumeric(od.oe_field_display_value) = 1
				and od.oe_field_display_value != "0"
		)
endif
into "NL:"
from
	ORDERS o
 
	, (inner join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = o.synonym_id)
 
    , (inner join ORDER_ACTION oa on oa.order_id = o.order_id
    	and oa.action_sequence = 1)
 
    , (inner join PRSNL pero on pero.person_id = oa.order_provider_id
    	and operator(pero.person_id, op_provider_var, $provider))
 
    , (inner join PRSNL pera on pera.person_id = oa.action_personnel_id)
 
	, (inner join PERSON p on p.person_id = o.person_id)
 
	, (inner join ENCOUNTER e on e.encntr_id = o.encntr_id
		and e.active_ind = 1)
 
    , (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
    	and ea.encntr_alias_type_cd = fin_var
    	and ea.active_ind = 1)
 
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id
		and operator(org.organization_id, op_practice_var, $practice))
 
where
	o.current_start_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
	and o.activity_type_cd = pharmacy_o_var
	and (
		cnvtlower(o.hna_order_mnemonic) like $med_name
		or cnvtlower(o.order_mnemonic) like $med_name
		or cnvtlower(o.ordered_as_mnemonic) like $med_name
		or $med_name = ""
	)
	and p.name_last_key NOT IN ("ZZZ*","TTTT*","FFFF*")      ;001 - Filtering out test patients
 
 
; populate pat_meds record structure
head report
	cnt = 0
 
	call alterlist(pat_meds->list, 100)
 
head o.order_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(pat_meds->list, cnt + 9)
	endif
 
	pat_meds->meds_cnt						= cnt
	pat_meds->list[cnt].order_id			= o.order_id
	pat_meds->list[cnt].practice			= org.org_name
	pat_meds->list[cnt].provider			= pero.person_id
	pat_meds->list[cnt].provider_name		= pero.name_full_formatted
	pat_meds->list[cnt].patient				= p.person_id
	pat_meds->list[cnt].patient_name		= p.name_full_formatted
	pat_meds->list[cnt].dob					= p.birth_dt_tm
 
	pat_meds->list[cnt].encntr_id			= e.encntr_id
	pat_meds->list[cnt].enc_date			= e.create_dt_tm
	pat_meds->list[cnt].enc_number			= ea.alias
 
	pat_meds->list[cnt].med_type			= uar_get_code_display(ocs.mnemonic_type_cd)
	pat_meds->list[cnt].med_name			= build(o.order_mnemonic, " (", o.ordered_as_mnemonic, ")")
	pat_meds->list[cnt].med_qty				= "0"
	pat_meds->list[cnt].med_start_dt_tm		= o.current_start_dt_tm
	pat_meds->list[cnt].med_stop_dt_tm		= o.projected_stop_dt_tm
 
	pat_meds->list[cnt].samples				= ""
	pat_meds->list[cnt].lot_number			= ""
	pat_meds->list[cnt].sample_exp_dt_tm	= null
 
	pat_meds->list[cnt].last_audit			= ""
	pat_meds->list[cnt].created_by			= pera.person_id
	pat_meds->list[cnt].created_name		= pera.name_full_formatted
	pat_meds->list[cnt].created_dt_tm		= o.orig_order_dt_tm
	; 002 adding communication per CR6200
	pat_meds->list[cnt].communication_type	= uar_get_code_display(o.last_communication_type_cd)
 
foot report
	call alterlist(pat_meds->list, cnt)
 
WITH nocounter, separator=" ", format, time = 30
 
 
; select order details
select into "NL:"
from
	ORDER_DETAIL od
 
    , (left join ORDER_ENTRY_FIELDS oef on oef.oe_field_id = od.oe_field_id
    	and oef.catalog_type_cd = pharmacy_oef_var
    	and oef.description in ("Pharmacy Lot Number for Samples Given", "Pharmacy Sample Expiration Date"))
 
where
	expand(num, 1, size(pat_meds->list, 5), od.order_id, pat_meds->list[num].order_id)
    and od.oe_field_meaning in ("DISPENSEQTY", "REQROUTINGTYPE", "OTHER")
	and od.action_sequence = 1
 
 
; populate pat_meds record structure with order detail data
head od.order_id
	numx = 0
	idx = 0
	sample = 0
 
	idx = locateval(numx, 1, size(pat_meds->list, 5), od.order_id, pat_meds->list[numx].order_id)
 
detail
	if (idx > 0)
		case (od.oe_field_meaning)
			of "DISPENSEQTY":
				pat_meds->list[idx].med_qty = evaluate(isnumeric(od.oe_field_display_value), 1, od.oe_field_display_value, "0")
 
			of "REQROUTINGTYPE":
				pat_meds->list[idx].last_audit = trim(od.oe_field_display_value, 3)
 
			of "OTHER":
				case (oef.description)
					of "Pharmacy Lot Number for Samples Given":
						pat_meds->list[idx].lot_number = trim(od.oe_field_display_value, 3)
						sample = 1
 
					of "Pharmacy Sample Expiration Date":
						pat_meds->list[idx].sample_exp_dt_tm = cnvtdate2(trim(od.oe_field_display_value, 3), "mm/dd/yy")
						sample = 1
				endcase
		endcase
	endif
 
foot od.order_id
	pat_meds->list[idx].samples = evaluate(sample, 1, "Y", "N")
 
WITH nocounter, separator=" ", format, time = 30, expand = 1
 
 
call echorecord(pat_meds)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
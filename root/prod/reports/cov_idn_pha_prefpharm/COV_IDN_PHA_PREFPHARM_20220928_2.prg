/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Ryan Gotsche
	Date Written:		12/06/2017
	Solution:			Pharmacy
	Source file name:	cov_idn_pha_prefpharm.prg
	Object name:		cov_idn_pha_prefpharm
	Request #:
 
	Program purpose:	Returns patients who are in-house that do not have
						a preferred pharmacy documented for them or
						have it documented and the reason indicated is
						"Unable to obtain preferred pharmacy".
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	05/17/2019	Todd A. Blanchard		Corrected criteria for prompt.
 										Revised overall CCL and adjusted criteria.
 	06/14/2019	Todd A. Blanchard		Adjusted criteria.
    01/11/2021  Dawn Greer, DBA         CR 9291 - Cov - Patient Preferred Pharmacy Compliance
                                        report executes with a timeout error.
                                        Changed query timeout to 60
    09/28/2022  Steve Czubek			CR 9291 - Add Nurse Unit and Encounter Type Prompts and orahintcbo
    09/28/2022  Dawn Greer, DBA         CR 9291 - Changed the order of the Prompts from Facility, Encounter Type
                                        Nurse Unit to Facility, Nurse Unit, Encounter Type
******************************************************************************/
 
drop program cov_idn_pha_prefpharm go
create program cov_idn_pha_prefpharm
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Please Select your Facility" = 0
	, "Nurse Unit" = 0
	, "Encounter Type" = 0
 
with OUTDEV, FACILITY, nurse_unit, encntr_type
 
%i cust_script:sc_cps_get_prompt_list.inc
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare yes_var					= f8 with constant(uar_get_code_by("MEANING", 268, "YES")), protect
declare active_var				= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!3980")), protect
declare preadmit_var			= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!1005616")), protect
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare unabletoobtain_var		= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!4112973523")), protect
declare unit_parser = vc with protect, noconstant("1=1")
declare encntr_type_parser = vc with protect, noconstant("1=1")
set encntr_type_parser = GetPromptList(3, "e.encntr_type_cd")
set unit_parser = GetPromptList(4, "e.loc_nurse_unit_cd")
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
SELECT DISTINCT INTO $outdev
	facility = uar_get_code_display(e.loc_facility_cd)
	, unit = uar_get_code_display(e.loc_nurse_unit_cd)
	, room = uar_get_code_display(e.loc_room_cd)
	, bed = uar_get_code_display(e.loc_bed_cd)
	, encntr_type = uar_get_code_display(e.encntr_type_cd)
	, reg_date = e.reg_dt_tm
	, los = format(datetimediff(cnvtdatetime(curdate, curtime3), e.reg_dt_tm ), "dd days hh:mm:ss;;z")
	, fin = eaf.alias
	, mrn = eam.alias
	, patient_name = p.name_full_formatted
 
;	, p.person_id
;;
;	, ppp.person_preferred_pharmacy_id
;	, ppp.preferred_pharmacy_uid
;	, ppp.reason_cd
;	, ppp.reason_text
;
;	, od.action_sequence
;	, od.detail_sequence
;	, od.oe_field_display_value
 
FROM
	ENCOUNTER   e
	, (inner JOIN ENCNTR_ALIAS eaf ON (eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and eaf.active_ind = 1))
	, (inner JOIN ENCNTR_ALIAS eam ON (eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var
		and eam.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and eam.active_ind = 1))
	, (inner JOIN PERSON p ON (p.person_id = e.person_id
		and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and p.deceased_cd != yes_var
		and p.active_ind = 1))
	, (left JOIN PERSON_PREFERRED_PHARMACY ppp ON (ppp.person_id = e.person_id
		and ppp.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and ppp.active_ind = 1))
	, (left JOIN ORDERS o ON (o.person_id = e.person_id
		and o.active_ind = 1))
	, (left JOIN ORDER_DETAIL od ON (od.order_id = o.order_id
		and od.oe_field_id = 4056696.00))
 
; ROUTINGPHARMACYID
where
	e.organization_id = $facility
	and e.encntr_class_cd != preadmit_var
	and e.encntr_status_cd = active_var
	and parser(encntr_type_parser)
	and parser(unit_parser)
	and e.disch_dt_tm = null
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and e.active_ind = 1
 
 	; no preferred pharmacy or unable to obtain
	and (
		ppp.person_preferred_pharmacy_id is null
		or nullval(ppp.preferred_pharmacy_uid, "") = ""
		or nullval(ppp.reason_cd, 0.0) = unabletoobtain_var
	)
 
 	; has preferred pharmacy
	and p.person_id not in (
		select person_id
		from PERSON_PREFERRED_PHARMACY
		where
			person_id = p.person_id
			and (
				preferred_pharmacy_uid != ""
				or trim(reason_text, 3) != ""
			)
			and end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
			and active_ind = 1
	)
 
	; has pharmacy obtained from orders
	and p.person_id not in (
		select o2.person_id
		from
			ORDERS o2
			, (inner join ORDER_DETAIL od2 on od2.order_id = o2.order_id
				and od2.oe_field_id = 4056696.00) ; ROUTINGPHARMACYID
		where
			o2.person_id = p.person_id
			and o2.active_ind = 1
			and od2.updt_dt_tm > nullval(ppp.updt_dt_tm, cnvtdatetime("01-JAN-1970 000000"))
	)
 
ORDER BY
	facility
	, unit
	, room
	, bed
	, e.encntr_id
	, p.person_id
	, ppp.person_preferred_pharmacy_id
 
WITH orahintcbo("index(e xie4encounter)"), separator = " ", format, time = 120
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

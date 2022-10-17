/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/15/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appt_TAT_TOG.prg
	Object name:		cov_sm_Order_Appt_TAT_TOG
	Request #:			6700, 6708, 12349
 
	Program purpose:	Lists turnaround time between when the order is placed
						and the appointment is scheduled.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	03/08/2022	Todd A. Blanchard		Changed practice site display to org name.
 
******************************************************************************/
 
drop program cov_sm_Order_Appt_TAT_TOG:DBA go
create program cov_sm_Order_Appt_TAT_TOG:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare confirm_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CONFIRM"))
declare request_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "REQUEST"))
declare noshow_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "NOSHOW"))
declare rescheduled_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))
declare scheduling_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "SCHEDULING"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare ord_physician_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULING ORDERING PHYSICIAN"))
declare attachtype_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare requestlistqueue_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16146, "REQUESTLISTQUEUE"))
declare reqstartdttm_var			= f8 with constant(51.00)
declare specinx_var					= f8 with constant(1103.00)
declare schedauthnbr_var			= f8 with constant(124.00)
declare commenttype2_var			= f8 with constant(2088.00)
declare column_var					= vc with noconstant("")
declare op_facility_var				= c2 with noconstant("")
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select appointment data
select distinct into $OUTDEV
	p.person_id
	, patient_name = p.name_full_formatted
	, fin = cnvtalias(eaf.alias, eaf.alias_pool_cd)
	, encntr_type = uar_get_code_display(e.encntr_type_cd)
 
	, o.order_id
	, o.order_mnemonic
	, ordering_physician = evaluate2(
		if (size(trim(sed.oe_field_display_value, 3)) > 0)
			trim(sed.oe_field_display_value, 3)
		else
			trim(per_oa.name_full_formatted, 3)
		endif
		)
 
	, ord_phys_group = evaluate2(
		if (size(trim(ps.practice_site_display, 3)) > 0)
			trim(org_ps.org_name, 3) ;001
		else
			trim(org_psoa.org_name, 3) ;001
		endif
		)
 
	, appt_location = evaluate2(
		if (sa.appt_location_cd > 0.0)
			uar_get_code_display(sa.appt_location_cd)
		else
			trim(od4.oe_field_display_value, 3)
		endif
		)
 
	, org.org_name
 
	, appt_dt_tm = sa.beg_dt_tm "@SHORTDATETIME"
 
	, entry_state = uar_get_code_display(sen.entry_state_cd)
 
	, earliest_dt_tm = if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
		and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))
			sen.earliest_dt_tm
		endif "@SHORTDATETIME"
 
	, appt_tat_days = if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
		and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))
			format(datetimediff(sa.beg_dt_tm, sen.earliest_dt_tm), ";R;I")
		endif
		
	, requested_start_dt_tm = od.oe_field_dt_tm_value "@SHORTDATETIME"
 
	, order_action_dt_tm = oa.action_dt_tm "@SHORTDATETIME"
	, order_action_type = uar_get_code_display(oa.action_type_cd)
 
	, sch_action_dt_tm = if (seva.action_dt_tm = seva2.action_dt_tm)
			seva.action_dt_tm
		else
			seva2.action_dt_tm
		endif "@SHORTDATETIME"
 
	, sch_action_type = if (seva.action_dt_tm = seva2.action_dt_tm)
			uar_get_code_display(seva.sch_action_cd)
		else
			uar_get_code_display(seva2.sch_action_cd)
		endif
 
	, sch_action_prsnl = if (seva.action_dt_tm = seva2.action_dt_tm)
			per_seva.name_full_formatted
		else
			per_seva2.name_full_formatted
		endif
 
	, sch_tat_days = if (seva.action_dt_tm = seva2.action_dt_tm)
			format(datetimediff(seva.action_dt_tm, od.oe_field_dt_tm_value), ";R;I")
		else
			format(datetimediff(seva2.action_dt_tm, od.oe_field_dt_tm_value), ";R;I")
		endif
	
	, request_queue = so.description
		
	, perform_dt_tm = seva3.perform_dt_tm "@SHORTDATETIME"	
	, sch_action = uar_get_code_display(seva3.sch_action_cd)	
	, req_action = uar_get_code_display(seva3.req_action_cd) 
	, req_action_prsnl = per_seva3.name_full_formatted
 
	, prior_auth = trim(od3.oe_field_display_value, 3)
 
	, auth_entered_by = if (size(trim(od3.oe_field_display_value, 3)) > 0)
			per_od3.name_full_formatted
		endif
 
	, auth_dt_tm = od3.updt_dt_tm "@SHORTDATETIME"
 
	, auth_tat_days = if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
		and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100"))
		and (od3.updt_dt_tm > 0))
			format(datetimediff(od3.updt_dt_tm, sen.earliest_dt_tm), ";R;I")
		endif
 
 	, auth_nbr = trim(au.auth_nbr, 3)
 
	, auth_nbr_entered_by = if (size(trim(au.auth_nbr, 3)) > 0)
			per_au.name_full_formatted
		endif
 
	, comment = trim(replace(replace(od2.oe_field_display_value, char(13), " ", 4), char(10), " ", 4), 3)
	
from
	SCH_APPT sa
 
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var)
 
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
	, (inner join ORGANIZATION org on org.organization_id = l.organization_id
		; practice site exclusions
		and org.organization_id not in (
			select ps.organization_id
			from PRACTICE_SITE ps
			where 
				ps.primary_entity_name in ("LOCATION", "ORGANIZATION")
				and cnvtupper(ps.practice_site_display) not in ("*THOMPSON*ONC*")
		)
		; organization exclusions
		and org.organization_id not in (
			3162038.00, 3192042.00, 3192056.00, 3192070.00, 3192081.00, 3242243.00, 3245331.00, 3278330.00
		))
 
	, (left join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.active_ind = 1)
 
	, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.oe_field_id = ord_physician_var
		and sed.beg_effective_dt_tm <= sysdate
		and sed.end_effective_dt_tm > sysdate
		and sed.active_ind = 1)
 
	, (left join PRSNL per on per.person_id = sed.oe_field_value
		and per.active_ind = 1)
 
 	; first practice site - scheduled event detail personnel
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1
		and pr.parent_entity_id = (
			select min(pr2.parent_entity_id)
			from PRSNL_RELTN pr2
			where
				pr2.person_id = pr.person_id
				and pr2.parent_entity_name = pr.parent_entity_name
				and pr2.active_ind = pr.active_ind
			group by
				pr2.person_id
		))
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 
	, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id) ;001
 
	; first confirm
	, (left join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
		and seva.action_meaning = "CONFIRM"
		and seva.action_dt_tm = (
			select min(action_dt_tm)
			from SCH_EVENT_ACTION
			where
				sch_event_id = seva.sch_event_id
				and action_meaning = "CONFIRM"
				and active_ind = 1
			group by
				sch_event_id
		)
		and seva.active_ind = 1
		)
 
	, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id)
 
	; last confirm
	, (left join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sev.sch_event_id
		and seva2.action_meaning = "CONFIRM"
		and seva2.action_dt_tm = (
			select max(action_dt_tm)
			from SCH_EVENT_ACTION
			where
				sch_event_id = seva2.sch_event_id
				and action_meaning = "CONFIRM"
				and active_ind = 1
			group by
				sch_event_id
		)
		and seva2.active_ind = 1
		)
 
	, (left join PRSNL per_seva2 on per_seva2.person_id = seva2.action_prsnl_id)
 
	; request
	, (left join SCH_EVENT_ACTION seva3 on seva3.sch_event_id = sev.sch_event_id
		and seva3.sch_action_cd = request_var
		and seva3.active_ind = 1
		)
 
	, (left join PRSNL per_seva3 on per_seva3.person_id = seva3.action_prsnl_id)
 
	, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
	
	; request list queue
	, (left join SCH_OBJECT so on so.sch_object_id = sen.queue_id
		and so.object_type_cd = requestlistqueue_var)
 
	, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.attach_type_cd = attachtype_order_var
		and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED")
		and sea.active_ind = 1)
 
	, (left join ORDERS o on o.order_id = sea.order_id
		and o.template_order_id = 0.0
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and	od.oe_field_meaning_id = reqstartdttm_var)
 
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and	od2.oe_field_meaning_id = specinx_var)
 
	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_meaning_id = schedauthnbr_var)
 
	, (left join PRSNL per_od3 on per_od3.person_id = od3.updt_id)
 
	, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
		and od4.oe_field_meaning_id = commenttype2_var)
 
	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var
		and oa.action_sequence > 0)
 
	, (left join PRSNL per_oa on per_oa.person_id = oa.order_provider_id)
 
 	; first practice site - order action personnel
	, (left join PRSNL_RELTN pr_oa on pr_oa.person_id = per_oa.person_id
		and pr_oa.parent_entity_name = "PRACTICE_SITE"
		and pr_oa.active_ind = 1
		and pr_oa.parent_entity_id = (
			select min(pr_oa2.parent_entity_id)
			from PRSNL_RELTN pr_oa2
			where
				pr_oa2.person_id = pr_oa.person_id
				and pr_oa2.parent_entity_name = pr_oa.parent_entity_name
				and pr_oa2.active_ind = pr_oa.active_ind
			group by
				pr_oa2.person_id
		))
 
	, (left join PRACTICE_SITE ps_oa on ps_oa.practice_site_id = pr_oa.parent_entity_id)
 
	, (left join ORGANIZATION org_psoa on org_psoa.organization_id = ps_oa.organization_id) ;001
 
	, (inner join PERSON p on p.person_id = sa.person_id)
 
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
		and epar.active_ind = 1)
 
	, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
		and au.active_ind = 1)
 
	, (left join PRSNL per_au on per_au.person_id = au.updt_id)
 
where
	sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sa.schedule_id > 0.0
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd != rescheduled_var
	and operator(sa.appt_location_cd, op_facility_var, $facility)
	and sa.appt_location_cd in (
		select cv.code_value
		from CODE_VALUE cv
		where
			cv.cdf_meaning in ("AMBULATORY")
			and cv.description in ("*INFUSION*", "*TOG*")
			and cv.display_key not in ("*ZZZ*")
			and cv.active_ind = 1
	)
	and sa.active_ind = 1
 
order by
	p.name_last_key
	, p.name_first_key
	, p.person_id
	, sa.beg_dt_tm
	, od.oe_field_dt_tm_value
	, seva2.action_dt_tm
	, seva3.perform_dt_tm
 
with nocounter, separator = " ", format, time = 120
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

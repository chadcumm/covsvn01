/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/03/2020
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appt_Analysis.prg
	Object name:		cov_sm_Order_Appt_Analysis
	Request #:			
 
	Program purpose:	Used for data analysis and statistics.
 
	Executing from:		CCL
 
 	Special Notes:		Prompts change the where statement to filter by:
							- Appointment Date
							- Scheduled Date Action
							- Order Date Action
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_sm_Order_Appt_Analysis:DBA go
create program cov_sm_Order_Appt_Analysis:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0            )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 0 

with OUTDEV, facility, start_datetime, end_datetime, report_type
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare confirm_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CONFIRM"))
declare cancel_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CANCEL"))
declare noshow_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "NOSHOW"))
declare hold_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "HOLD"))
declare checkin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CHECKIN"))
declare checkout_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CHECKOUT"))
declare rescheduled_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare ord_physician_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULING ORDERING PHYSICIAN"))
declare attachtype_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare reqstartdttm_var			= f8 with constant(51.00)
declare specinx_var					= f8 with constant(1103.00)
declare schedauthnbr_var			= f8 with constant(124.00)
declare commenttype2_var			= f8 with constant(2088.00)
declare column_var					= vc with noconstant("")

declare op_facility_var				= c2 with noconstant("")
declare op_datefilter_var			= vc with noconstant("")
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
; define operator for $datefilter
if ($report_type = 0) ; appointment date
	set column_var = "sa.beg_dt_tm"
 
elseif ($report_type = 1) ; scheduled action date
	set column_var = "seva2.action_dt_tm"
 
elseif ($report_type = 2) ; order action date
	set column_var = "oa.action_dt_tm"
 
endif
 
set op_datefilter_var = build2(
		column_var, " between cnvtdatetime('", $start_datetime, "') and cnvtdatetime('", $end_datetime, "')"
	)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select appointment data
select
	if ($report_type in (0, 1))
		; appointment date or scheduled action date
		from
			SCH_APPT sa
 
			, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
				and e.active_ind = 1)
 
			, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
				and eaf.encntr_alias_type_cd = fin_var)
 
			, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
			, (inner join ORGANIZATION org on operator(org.organization_id, op_facility_var, $facility)
				and org.organization_id = l.organization_id)
 
			, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
				and sev.active_ind = 1)
 
 			, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
				and sed.oe_field_id = ord_physician_var
				and sed.beg_effective_dt_tm <= sysdate
				and sed.end_effective_dt_tm > sysdate
				and sed.active_ind = 1)
 
 			, (left join PRSNL per on per.person_id = sed.oe_field_value
				and per.active_ind = 1)
 
 			; first practice site 
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
 
			, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id)
 
			; first action
			, (inner join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
				and seva.sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
				and seva.action_dt_tm = (
					select min(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva.sch_event_id
						and sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
					group by
						sch_event_id
				)
				and seva.active_ind = 1
				)
 
;			, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id) 
 
			; last action
			, (inner join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sev.sch_event_id
				and seva2.sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
				and seva2.action_dt_tm = (
					select max(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva2.sch_event_id
						and sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
					group by
						sch_event_id
				)
				and seva2.active_ind = 1
				)
 
;			, (left join PRSNL per_seva2 on per_seva2.person_id = seva2.action_prsnl_id) 
 
;			, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
 
			, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
				and sea.attach_type_cd = attachtype_order_var
				and sea.active_ind = 1)
 
			, (inner join ORDERS o on o.order_id = sea.order_id
				and o.template_order_id = 0.0 
				and o.active_ind = 1)
 
			, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
				and	od2.oe_field_meaning_id = specinx_var)
 
			, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
				and od4.oe_field_meaning_id = commenttype2_var)
 
			, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
				and oa.action_type_cd = order_var
				and oa.action_sequence > 0)
 
			, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id)
 
 			; first practice site 
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
 
			, (left join ORGANIZATION org_psoa on org_psoa.organization_id = ps_oa.organization_id)
 
			, (inner join PERSON p on p.person_id = sa.person_id)
 
		where
			parser(op_datefilter_var)
			and sa.schedule_id > 0.0
			and sa.role_meaning = "PATIENT"
			and sa.sch_state_cd != rescheduled_var
			; location exclusions
			and sa.appt_location_cd not in (
				select cv.code_value
				from CODE_VALUE cv
				where ((
					cv.code_set > 0
					and cv.cdf_meaning in ("ANCILSURG", "SURGAREA", "SURGOP", "AMBULATORY")
					and (
						cv.display_key in ("*MAIN*OR")
						or cv.display_key in ("*PREADM*TESTING")
						or cv.display_key in ("*NON*SURGICAL")
						or cv.display_key in ("*ENDOSCOPY")
						or cv.display_key in ("*LABOR*DELIVERY")
						or cv.display_key in ("*ECOR")
					))
					or (
						cv.cdf_meaning in ("AMBULATORY")
						and cv.description in ("*INFUSION*")
					))
					and cv.active_ind = 1
			)
			and sa.active_ind = 1
 
	else
		; order action date 
		from
			ORDERS o
 
			, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
				and	od2.oe_field_meaning_id = specinx_var)
 
			, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
				and od4.oe_field_meaning_id = commenttype2_var)
 
			, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
				and oa.action_type_cd = order_var
				and oa.action_sequence > 0)
 
			, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id)
 
 			; first practice site
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
 
			, (left join ORGANIZATION org_psoa on org_psoa.organization_id = ps_oa.organization_id)
 
			, (left join SCH_EVENT_ATTACH sea on sea.order_id = o.order_id
				and sea.attach_type_cd = attachtype_order_var
				and sea.active_ind = 1)
 
			, (left join SCH_EVENT sev on sev.sch_event_id = sea.sch_event_id
				and sev.active_ind = 1)
 
 			, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
				and sed.oe_field_id = ord_physician_var
				and sed.beg_effective_dt_tm <= sysdate
				and sed.end_effective_dt_tm > sysdate
				and sed.active_ind = 1)
 
			, (left join SCH_APPT sa on sa.sch_event_id = sev.sch_event_id
				and sa.schedule_id > 0.0
				and sa.role_meaning = "PATIENT"
				and sa.sch_state_cd != rescheduled_var
				; location exclusions
				and sa.appt_location_cd not in (
					select cv.code_value
					from CODE_VALUE cv
					where ((
						cv.code_set > 0
						and cv.cdf_meaning in ("ANCILSURG", "SURGAREA", "SURGOP", "AMBULATORY")
						and (
							cv.display_key in ("*MAIN*OR")
							or cv.display_key in ("*PREADM*TESTING")
							or cv.display_key in ("*NON*SURGICAL")
							or cv.display_key in ("*ENDOSCOPY")
							or cv.display_key in ("*LABOR*DELIVERY")
							or cv.display_key in ("*ECOR")
						))
						or (
							cv.cdf_meaning in ("AMBULATORY")
							and cv.description in ("*INFUSION*")
						))
						and cv.active_ind = 1
				)
				and sa.active_ind = 1
				)
 
			, (left join ENCOUNTER e on ((e.encntr_id = sa.encntr_id)
				or (e.encntr_id = o.encntr_id))
				and e.active_ind = 1)
 
			, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
				and eaf.encntr_alias_type_cd = fin_var)
 
			, (left join LOCATION l on l.location_cd = sa.appt_location_cd)
 
			, (left join ORGANIZATION org on operator(org.organization_id, op_facility_var, $facility)
				and org.organization_id = l.organization_id)
 
 			, (left join PRSNL per on per.person_id = sed.oe_field_value
				and per.active_ind = 1)
 
 			; first practice site 
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
 
			, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id)
 
			; first action
			, (left join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
				and seva.sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
				and seva.action_dt_tm = (
					select min(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva.sch_event_id
						and sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
					group by
						sch_event_id
				)
				and seva.active_ind = 1
				)
 
;			, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id) 
 
			; last action
			, (left join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sev.sch_event_id
				and seva2.sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
				and seva2.action_dt_tm = (
					select max(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva2.sch_event_id
						and sch_action_cd in (confirm_var, cancel_var, noshow_var, hold_var, checkin_var, checkout_var)
					group by
						sch_event_id
				)
				and seva2.active_ind = 1
				)
 
;			, (left join PRSNL per_seva2 on per_seva2.person_id = seva2.action_prsnl_id) 
 
;			, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
 
			, (left join PERSON p on (p.person_id = sa.person_id)
				or (p.person_id = o.person_id))
 
			, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
				and epr.priority_seq = 1
				and epr.end_effective_dt_tm > sysdate
				and epr.active_ind = 1)
 
			, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id) 
 
 			, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
				and epar.active_ind = 1)
 
 			, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
				and au.active_ind = 1)
 
			, (left join PRSNL per_au on per_au.person_id = au.updt_id)
 
		where
			parser(op_datefilter_var)
			and o.catalog_type_cd not in (
				2511.00, 2512.00, 2513.00, 2515.00, 2516.00, 2518.00,
				636063.00, 636064.00, 636067.00, 636727.00,
				20460012.00, 20454826.00, 23276383.00
			)
			and o.template_order_id = 0.0 
			and o.active_ind = 1
 
	endif
 
distinct into $OUTDEV
;	p.person_id
	p.name_full_formatted
	, fin = cnvtalias(eaf.alias, eaf.alias_pool_cd)
 
	, encntr_type = uar_get_code_display(e.encntr_type_cd)
 
;	, o.order_id
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
			trim(org_ps.org_name, 3)
		else
			trim(org_psoa.org_name, 3)
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
 
;	, entry_state = uar_get_code_display(sen.entry_state_cd)
 
;	, order_action_dt_tm = oa.action_dt_tm "@SHORTDATETIME"
;	, order_action_type = uar_get_code_display(oa.action_type_cd)
 
 	; first action
	, first_sch_action_dt_tm = seva.action_dt_tm "@SHORTDATETIME"
 
	, first_sch_action_type = uar_get_code_display(seva.sch_action_cd)
 
;	, first_sch_action_prsnl = per_seva.name_full_formatted
 
 	; last action
	, last_sch_action_dt_tm = seva2.action_dt_tm "@SHORTDATETIME"
 
	, last_sch_action_type = uar_get_code_display(seva2.sch_action_cd)
 
;	, last_sch_action_prsnl = per_seva2.name_full_formatted
 
	, comment = trim(replace(replace(od2.oe_field_display_value, char(13), " ", 4), char(10), " ", 4), 3)
 
order by
	p.name_last_key
	, p.name_first_key
	, p.person_id
	, sa.beg_dt_tm
	, seva.action_dt_tm
	, seva2.action_dt_tm
 
with nocounter, separator = " ", format, time = 600
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

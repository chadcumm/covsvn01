/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		02/12/2020
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Appointments_NonCMG.prg
	Object name:		cov_sm_Appointments_NonCMG
	Request #:			7095, 12449
 
	Program purpose:	Lists orders and appointments for non-CMG offices.
 
	Executing from:		CCL
 
 	Special Notes:		Exported data is used by external process.
 
 						Output file: noncmg_appts.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	07/27/2020	Todd A. Blanchard		Adjusted timeout values.
002	08/27/2020	Todd A. Blanchard		Adjusted CCL for performance.
003	08/10/2021	Todd A. Blanchard		Made record structure persistent for calling CCLs.
004	03/15/2022	Todd A. Blanchard		Adjusted timeframe for queries to 90 days in the future.
 
******************************************************************************/
 
drop program cov_sm_Appointments_NonCMG:DBA go
create program cov_sm_Appointments_NonCMG:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare fin_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare orgdoc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR"))
declare stardoc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))

declare canceluponreview_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CANCELUPONREVIEW"))
declare cardiacdiagnostics_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CARDIACDIAGNOSTICS"))
declare cheyenneoutpatientclinic_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CHEYENNEOUTPATIENTCLINIC"))
declare diagnosticcenteroutpatient_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "DIAGNOSTICCENTEROUTPATIENT"))
declare multidayopdiagnostic_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "MULTIDAYOPDIAGNOSTIC"))
declare outpatient_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENT"))
declare prereg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "PREREG"))
declare recurring_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "RECURRING"))
declare scheduled_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "SCHEDULED"))

declare ct_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "CTOUTSIDEIMAGES"))
declare mg_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "MGOUTSIDEIMAGES"))
declare mri_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "MRIOUTSIDEIMAGES"))
declare nm_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "NMOUTSIDEIMAGES"))
declare pet_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "PETOUTSIDEIMAGES"))
declare us_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "USOUTSIDEIMAGES"))
declare xr_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "XROUTSIDEIMAGES"))

declare view_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "VIEW"))

declare attachtype_order_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))

declare admittransferdischarge_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "ADMITTRANSFERDISCHARGE"))
declare ambulatorypoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "AMBULATORYPOC"))
declare ambulatoryprocedures_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "AMBULATORYPROCEDURES"))
declare consults_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "CONSULTS"))
declare dialysis_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "DIALYSIS"))
declare discernruleorder_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "DISCERNRULEORDER"))
declare evaluationandmanagement_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "EVALUATIONANDMANAGEMENT"))
declare laboratory_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "LABORATORY"))
declare nutritionservices_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "NUTRITIONSERVICES"))
declare patientcare_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "PATIENTCARE"))
declare pharmacy_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "PHARMACY"))
declare referral_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "REFERRAL"))
declare scheduling_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "SCHEDULING"))
declare surgery_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "SURGERY"))

declare order_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))

declare future_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare inprocess_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "INPROCESS"))
declare ordered_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare pendingcomplete_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "PENDINGCOMPLETE"))
declare pendingreview_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "PENDINGREVIEW"))

declare rescheduled_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))

declare act_comm_text_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 15149, "ACTIONCOMMENTS"))
declare act_comm_sub_text_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 15589, "ACTIONCOMMENTS"))
declare schedauthnbr_var				= f8 with constant(124.00)

declare todaybeg_var					= dq8 with constant(datetimefind(sysdate, "D", "B", "B"))
declare todayend_var					= dq8 with constant(datetimefind(sysdate, "D", "E", "E"))
declare yesterday_var					= dq8 with constant(datetimefind(cnvtlookbehind("1, D"), "D", "B", "B"))
declare next30days_var					= dq8 with constant(datetimefind(cnvtlookahead("30, D"), "D", "E", "E"))
declare next90days_var					= dq8 with constant(datetimefind(cnvtlookahead("90, D"), "D", "E", "E")) ;004
declare prev30days_var					= dq8 with constant(datetimefind(cnvtlookbehind("30, D"), "D", "B", "B"))

declare file_var						= vc with constant("noncmg_appts.csv")
 
declare temppath_var					= vc with constant(build("cer_temp:", file_var))
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															"_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
 
declare output_var						= vc with noconstant("")
 
declare cmd								= vc with noconstant("")
declare len								= i4 with noconstant(0)
declare stat							= i4 with noconstant(0)

declare num								= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

free record noncmg_data ;003
record noncmg_data (
	1	cnt							= i4
	1	list[*]
		2	order_id				= f8
		2	order_mnemonic			= c100
		2	order_status			= c40
		2	orig_order_dt_tm		= dq8		
		2	final_dt_tm				= dq8
		2	order_physician_id		= f8
		2	order_physician			= c100
		2	order_physician_alias	= c20
;		2	order_action_dt_tm		= dq8 ;002
;		2	order_action_type		= c40 ;002
		
		2	person_id				= f8
		2	patient_name			= c100
		2	dob						= dq8
		
 		2	encntr_id				= f8
 		2	encntr_type_cd			= f8
; 		2	encntr_type				= c40 ;002
; 		2	encntr_type_class_cd	= f8 ;002
; 		2	encntr_type_class		= c40
		2	fin						= c10
		2	auth_nbr				= c50
		
		2	prior_auth				= c30
		
		2	sch_appt_id				= f8
		2	appt_dt_tm				= dq8
		2	appt_state				= c40
		2	appt_location			= c100
		2	org_name				= c100
 
		2	schedule_id				= f8
		2	sch_event_id			= f8
		2	sch_entry_id			= f8
		2	earliest_dt_tm			= dq8
		2	sch_action_id			= f8
		2	sch_action_dt_tm		= dq8
;		2	sch_action				= c40 ;002
;		2	action_reason			= c40 ;002
;		2	action_comment			= c300 ;002
)
with persistscript ;003


/**************************************************************/
; select appointments with orders data
select into "NL:"
from
	SCH_APPT sa
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.active_ind = 1)
		
	, (inner join SCH_EVENT_ACTION seact on seact.sch_event_id = sa.sch_event_id
		and seact.schedule_id = sa.schedule_id
		and seact.action_meaning != "VIEW"
		and seact.sch_action_id = (
			select max(sch_action_id)
			from SCH_EVENT_ACTION
			where
				sch_event_id = seact.sch_event_id
				and schedule_id = seact.schedule_id
				and action_meaning != "VIEW"
				and active_ind = 1
			group by
				sch_event_id
				, schedule_id
		)
		and seact.active_ind = 1)

;002
;	, (left join SCH_EVENT_COMM sec on sec.sch_event_id = seact.sch_event_id
;		and sec.sch_action_id = seact.sch_action_id
;		and sec.text_type_cd = act_comm_text_var
;		and sec.sub_text_cd = act_comm_sub_text_var
;		and sec.updt_id > 1.00
;		and sec.active_ind = 1)
; 
;	, (left join LONG_TEXT lt on lt.long_text_id = sec.text_id
;		and lt.active_ind = 1)
 
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.attach_type_cd = attachtype_order_var
		and sea.active_ind = 1)
		
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.catalog_type_cd not in (
			admittransferdischarge_var,
			ambulatorypoc_var,
			ambulatoryprocedures_var,
			consults_var,
			dialysis_var,
			discernruleorder_var,
			evaluationandmanagement_var,
			laboratory_var,
			nutritionservices_var,
			patientcare_var,
			pharmacy_var,
			referral_var,
			scheduling_var,
			surgery_var
		)
		and o.catalog_cd not in (
			ct_var, mg_var, mri_var, nm_var, pet_var, us_var, xr_var
		)
		and o.template_order_id = 0.0
		and o.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning_id = schedauthnbr_var
		;002
		and od.action_sequence = (
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od.order_id
				and oe_field_id = od.oe_field_id
			group by
				order_id
		))
		
	; first order action
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var			
		and oa.action_sequence = 1)
 
 	; ordering physician
	, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id
		and per_oa.active_ind = 1)
		
	, (inner join PRSNL_ALIAS pera_oa on pera_oa.person_id = per_oa.person_id
		and pera_oa.prsnl_alias_type_cd = orgdoc_var
		and pera_oa.alias_pool_cd = stardoc_var	
		and pera_oa.end_effective_dt_tm > sysdate
		and pera_oa.active_ind = 1)			
	
	; last order action
	, (inner join ORDER_ACTION oa_last on oa_last.order_id = o.order_id	
		and	(
			; future, inprocess, ordered, pending complete, pending review
			;
			; occurred today or prior
			oa_last.order_status_cd in (future_var, inprocess_var, ordered_var, pendingcomplete_var, pendingreview_var)

			or 
			
			; other statuses
			;
			; occurred today or yesterday
			(oa_last.order_status_cd not in (future_var, inprocess_var, ordered_var, pendingcomplete_var, pendingreview_var)
				and oa_last.action_dt_tm >= cnvtdatetime(yesterday_var))
		)				
		and oa_last.action_sequence = (
			select max(action_sequence)
			from ORDER_ACTION
			where
				order_id = oa_last.order_id
				and action_sequence >= 1 ;002
			group by
				order_id
		))

;002
; 	; ordering physician
;	, (inner join PRSNL per_oa_last on per_oa_last.person_id = oa_last.order_provider_id
;		and per_oa_last.active_ind = 1)
;		
;	, (inner join PRSNL_ALIAS pera_oa_last on pera_oa_last.person_id = per_oa_last.person_id
;		and pera_oa_last.prsnl_alias_type_cd = orgdoc_var
;		and pera_oa_last.alias_pool_cd = stardoc_var
;		and pera_oa_last.end_effective_dt_tm > sysdate
;		and pera_oa_last.active_ind = 1)

	, (left join RAD_REPORT rr on rr.order_id = o.order_id)
		
	, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id
		and p.name_last_key not in ("ZZZ*") ;002
		and p.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.encntr_type_cd in (
			cardiacdiagnostics_var,
			cheyenneoutpatientclinic_var,
			diagnosticcenteroutpatient_var,
			multidayopdiagnostic_var,
			outpatient_var,
			prereg_var,
			recurring_var,
			scheduled_var
		)
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
 
	; encounter location
	, (inner join LOCATION l2 on l2.location_cd = e.loc_facility_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org2 on org2.organization_id = l2.organization_id
		and org2.organization_id not in (	
			select
				os.organization_id		
			from
				ORG_SET o
				, ORG_SET_ORG_R os	
			where
				o.name like "*CMG*"
				and o.org_set_id = os.org_set_id
				and os.active_ind = 1	
		)
		and org2.active_ind = 1)
 
	; health plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
		and epar.active_ind = 1)
 
	, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
		and au.active_ind = 1)
 
	; appointment location
	, (left join LOCATION l on l.location_cd = sa.appt_location_cd)
	
where
	sa.beg_dt_tm between cnvtdatetime(todaybeg_var) and cnvtdatetime(next90days_var) ;004
	and sa.role_meaning = "PATIENT"
	and sa.sch_state_cd != rescheduled_var
	and sa.version_dt_tm > sysdate
	and sa.active_ind = 1
 
 
; populate record structure
head report
	cnt = 0
 
	call alterlist(noncmg_data->list, 100)
	
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(noncmg_data->list, cnt + 9)
	endif
	
	noncmg_data->cnt								= cnt
	noncmg_data->list[cnt].order_id					= o.order_id
	noncmg_data->list[cnt].order_mnemonic			= trim(o.order_mnemonic, 3)
	noncmg_data->list[cnt].order_status				= uar_get_code_display(o.order_status_cd)
	noncmg_data->list[cnt].orig_order_dt_tm			= o.orig_order_dt_tm
	noncmg_data->list[cnt].final_dt_tm				= rr.final_dt_tm
	noncmg_data->list[cnt].order_physician_id		= per_oa.person_id
	noncmg_data->list[cnt].order_physician			= per_oa.name_full_formatted
	noncmg_data->list[cnt].order_physician_alias	= pera_oa.alias	
;002
;	noncmg_data->list[cnt].order_action_dt_tm		= oa_last.action_dt_tm
;	noncmg_data->list[cnt].order_action_type		= uar_get_code_display(oa_last.action_type_cd)
	
	noncmg_data->list[cnt].person_id				= p.person_id
	noncmg_data->list[cnt].patient_name				= p.name_full_formatted
	noncmg_data->list[cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
		
	noncmg_data->list[cnt].encntr_id				= e.encntr_id
;002
;	noncmg_data->list[cnt].encntr_type_cd			= e.encntr_type_cd
;	noncmg_data->list[cnt].encntr_type				= uar_get_code_display(e.encntr_type_cd)
;	noncmg_data->list[cnt].encntr_type_class_cd		= e.encntr_type_class_cd
;	noncmg_data->list[cnt].encntr_type_class		= uar_get_code_display(e.encntr_type_class_cd)
	noncmg_data->list[cnt].fin						= eaf.alias
	noncmg_data->list[cnt].auth_nbr					= au.auth_nbr
	
	noncmg_data->list[cnt].prior_auth				= od.oe_field_display_value
	
	noncmg_data->list[cnt].sch_appt_id				= sa.sch_appt_id
	noncmg_data->list[cnt].appt_dt_tm				= sa.beg_dt_tm
	noncmg_data->list[cnt].appt_state				= sa.state_meaning
	noncmg_data->list[cnt].appt_location			= uar_get_code_display(l.location_cd)
	noncmg_data->list[cnt].org_name					= org2.org_name
	
	noncmg_data->list[cnt].schedule_id				= sa.schedule_id
	noncmg_data->list[cnt].sch_event_id				= sa.sch_event_id
	noncmg_data->list[cnt].sch_entry_id				= sen.sch_entry_id
	
	noncmg_data->list[cnt].earliest_dt_tm			= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
														and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))
															sen.earliest_dt_tm
													  endif
												  
	noncmg_data->list[cnt].sch_action_id			= seact.sch_action_id
	noncmg_data->list[cnt].sch_action_dt_tm			= seact.action_dt_tm
;002
;	noncmg_data->list[cnt].sch_action				= uar_get_code_display(seact.sch_action_cd)
;	noncmg_data->list[cnt].action_reason			= uar_get_code_display(seact.sch_reason_cd)
;	noncmg_data->list[cnt].action_comment			= replace(replace(
;														substring(1, 300, lt.long_text), 
;														char(13), " ", 4), 
;														char(10), " ", 4)
	
foot report
	call alterlist(noncmg_data->list, cnt)
	
with nocounter, time = 900 ;001
	

/**************************************************************/
; select orders without appointments data
select into "NL:"
from
	ORDERS o
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning_id = schedauthnbr_var
		;002
		and od.action_sequence = (
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od.order_id
				and oe_field_id = od.oe_field_id
			group by
				order_id
		))
		
	; first order action
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var
		and oa.action_sequence = 1)
 
 	; ordering physician
	, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id
		and per_oa.active_ind = 1)
		
	, (inner join PRSNL_ALIAS pera_oa on pera_oa.person_id = per_oa.person_id
		and pera_oa.prsnl_alias_type_cd = orgdoc_var
		and pera_oa.alias_pool_cd = stardoc_var	
		and pera_oa.end_effective_dt_tm > sysdate
		and pera_oa.active_ind = 1)		
		
	; last order action
	, (inner join ORDER_ACTION oa_last on oa_last.order_id = o.order_id	
		and	(
			; future, inprocess, ordered, pending complete, pending review
			;
			; occurred today or prior
			oa_last.order_status_cd in (future_var, inprocess_var, ordered_var, pendingcomplete_var, pendingreview_var)
			
			or
			
			; other statuses
			;
			; occurred today or yesterday
			(oa_last.order_status_cd not in (future_var, inprocess_var, ordered_var, pendingcomplete_var, pendingreview_var)
				and oa_last.action_dt_tm >= cnvtdatetime(yesterday_var))
		)
		and oa_last.action_sequence = (
			select max(action_sequence)
			from ORDER_ACTION
			where
				order_id = oa_last.order_id
				and action_sequence >= 1 ;002
			group by
				order_id
		))

;002
; 	; ordering physician
;	, (inner join PRSNL per_oa_last on per_oa_last.person_id = oa_last.order_provider_id
;		and per_oa_last.active_ind = 1)
;		
;	, (inner join PRSNL_ALIAS pera_oa_last on pera_oa_last.person_id = per_oa_last.person_id
;		and pera_oa_last.prsnl_alias_type_cd = orgdoc_var
;		and pera_oa_last.alias_pool_cd = stardoc_var
;		and pera_oa_last.end_effective_dt_tm > sysdate
;		and pera_oa_last.active_ind = 1)

	, (left join RAD_REPORT rr on rr.order_id = o.order_id)
 
	, (left join SCH_EVENT_ATTACH sea on sea.order_id = o.order_id
		and sea.attach_type_cd = attachtype_order_var
		and sea.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = o.encntr_id
		and e.encntr_type_cd in (			
			cardiacdiagnostics_var,
			cheyenneoutpatientclinic_var,
			diagnosticcenteroutpatient_var,
			multidayopdiagnostic_var,
			outpatient_var,
			prereg_var,
			recurring_var,
			scheduled_var
		)
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
 
	; encounter location
	, (inner join LOCATION l2 on l2.location_cd = e.loc_facility_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org2 on org2.organization_id = l2.organization_id
		and org2.organization_id not in (	
			select
				os.organization_id		
			from
				ORG_SET o
				, ORG_SET_ORG_R os	
			where
				o.name like "*CMG*"
				and o.org_set_id = os.org_set_id
				and os.active_ind = 1	
		)
		and org2.active_ind = 1)
 
	; health plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
		and epar.active_ind = 1)
 
	, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
		and au.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = e.person_id ;002
		and p.name_last_key not in ("ZZZ*") ;002
		and p.active_ind = 1)
	
where
	o.order_id > 0.0
	and o.orig_order_dt_tm between cnvtdatetime(prev30days_var) and cnvtdatetime(next90days_var) ;004
	and o.catalog_type_cd not in (
		admittransferdischarge_var,
		ambulatorypoc_var,
		ambulatoryprocedures_var,
		consults_var,
		dialysis_var,
		discernruleorder_var,
		evaluationandmanagement_var,
		laboratory_var,
		nutritionservices_var,
		patientcare_var,
		pharmacy_var,
		referral_var,
		scheduling_var,
		surgery_var
	)
	and o.catalog_cd not in (
		ct_var, mg_var, mri_var, nm_var, pet_var, us_var, xr_var
	)
	and o.template_order_id = 0.0
	and o.active_ind = 1	
	and sea.sch_attach_id is null

;002
;order by
;	o.order_id
 
 
; populate record structure
head report
	cnt = noncmg_data->cnt
	
detail
	cnt = cnt + 1
 
	call alterlist(noncmg_data->list, cnt)
	
	noncmg_data->cnt								= cnt
	noncmg_data->list[cnt].order_id					= o.order_id
	noncmg_data->list[cnt].order_mnemonic			= trim(o.order_mnemonic, 3)
	noncmg_data->list[cnt].order_status				= uar_get_code_display(o.order_status_cd)
	noncmg_data->list[cnt].orig_order_dt_tm			= o.orig_order_dt_tm
	noncmg_data->list[cnt].final_dt_tm				= rr.final_dt_tm
	noncmg_data->list[cnt].order_physician_id		= per_oa.person_id
	noncmg_data->list[cnt].order_physician			= per_oa.name_full_formatted
	noncmg_data->list[cnt].order_physician_alias	= pera_oa.alias	
;002
;	noncmg_data->list[cnt].order_action_dt_tm		= oa_last.action_dt_tm
;	noncmg_data->list[cnt].order_action_type		= uar_get_code_display(oa_last.action_type_cd)
	
	noncmg_data->list[cnt].person_id				= p.person_id
	noncmg_data->list[cnt].patient_name				= p.name_full_formatted
	noncmg_data->list[cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
	
	noncmg_data->list[cnt].encntr_id				= e.encntr_id
;002
;	noncmg_data->list[cnt].encntr_type_cd			= e.encntr_type_cd
;	noncmg_data->list[cnt].encntr_type				= uar_get_code_display(e.encntr_type_cd)
;	noncmg_data->list[cnt].encntr_type_class_cd		= e.encntr_type_class_cd
;	noncmg_data->list[cnt].encntr_type_class		= uar_get_code_display(e.encntr_type_class_cd)
	noncmg_data->list[cnt].fin						= eaf.alias
	noncmg_data->list[cnt].auth_nbr					= au.auth_nbr
	
	noncmg_data->list[cnt].prior_auth				= od.oe_field_display_value
	
	noncmg_data->list[cnt].org_name					= org2.org_name
	 
with nocounter, time = 900 ;001
 

;call echorecord(noncmg_data)
	
;go to exitscript


/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
else
	with nocounter, separator = " ", format
endif
 
distinct into value(output_var)
	patient_name			= trim(noncmg_data->list[d1.seq].patient_name, 3)
	, dob					= format(noncmg_data->list[d1.seq].dob, "mm/dd/yyyy;;d") 
	, fin					= trim(noncmg_data->list[d1.seq].fin, 3)
	
	, ordering_physician	= trim(noncmg_data->list[d1.seq].order_physician, 3)
	, physician_number		= trim(noncmg_data->list[d1.seq].order_physician_alias, 3)
	
	, order_name			= trim(noncmg_data->list[d1.seq].order_mnemonic, 3)
	, order_received		= format(noncmg_data->list[d1.seq].orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	
	, appt_status			= trim(noncmg_data->list[d1.seq].appt_state	, 3)
	, appt_date				= format(noncmg_data->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, appt_location			= trim(noncmg_data->list[d1.seq].appt_location, 3)
	, location_org_name		= trim(noncmg_data->list[d1.seq].org_name, 3)
	
	, final_result_date		= format(noncmg_data->list[d1.seq].final_dt_tm, "mm/dd/yyyy hh:mm;;q")
	
	, auth					= evaluate2(
								if (size(trim(noncmg_data->list[d1.seq].auth_nbr, 3)) > 0)
									trim(noncmg_data->list[d1.seq].auth_nbr, 3)
								else
									trim(noncmg_data->list[d1.seq].prior_auth, 3)
								endif
								)

from
	(dummyt d1 with seq = value(noncmg_data->cnt))
 
plan d1
where
	(
		noncmg_data->list[d1.seq].appt_dt_tm between cnvtdatetime(todaybeg_var) and cnvtdatetime(next90days_var) ;004
		or (
			noncmg_data->list[d1.seq].appt_dt_tm <= 0
			and (
				noncmg_data->list[d1.seq].orig_order_dt_tm between cnvtdatetime(prev30days_var) and cnvtdatetime(next90days_var) ;004
				or noncmg_data->list[d1.seq].earliest_dt_tm between cnvtdatetime(prev30days_var) and cnvtdatetime(next90days_var) ;004
			)
		)
	)
	and not (
		noncmg_data->list[d1.seq].appt_state = "CHECKED IN"
		and noncmg_data->list[d1.seq].final_dt_tm < sysdate
	)
 
order by
	patient_name
	, noncmg_data->list[d1.seq].person_id
	, noncmg_data->list[d1.seq].appt_dt_tm
	, fin
	, noncmg_data->list[d1.seq].orig_order_dt_tm
	, noncmg_data->list[d1.seq].order_status
	, noncmg_data->list[d1.seq].order_id
	, noncmg_data->list[d1.seq].order_physician_id
	, noncmg_data->list[d1.seq].sch_action_dt_tm
	, noncmg_data->list[d1.seq].sch_event_id
	
with nocounter
 
 
/**************************************************************/
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go


/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/05/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Order_Appointment_TAT.prg
	Object name:		cov_sm_Order_Appointment_TAT
	Request #:			4670, 5456, 5536, 6739, 7510, 7807, 8309, 8361, 8496,
						8652, 9030, 9876, 10860, 10972, 11683, 11958, 12349,
						14015
 
	Program purpose:	Lists turnaround time between when the order is placed
						and the appointment is scheduled.
 
	Executing from:		CCL
 
 	Special Notes:		Prompts change the where statement to filter by:
							- 0: Appointment Date
							- 1: Scheduled Date Action
							- 2: Order Date Action
							- 3: Pre-Reg Date
							
						This is a report/extract CCL.  Changes have to be
						coordinated with downstream processes.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	08/27/2019	Todd A. Blanchard		Added name of personnel responsible for
 										scheduling actions taken.
002	08/29/2019	Todd A. Blanchard		Added ordering physician and physician group.
003	09/11/2019	Daniel Claus			Added prompts for various date actions.
										Added auth number for encounter.
004	09/13/2019	Todd A. Blanchard		Revised CCL for order date action prompt.
005	09/16/2019	Todd A. Blanchard		Added encounter type.
 										Changed logic to get first practice site for each physician.
006	09/30/2019	Todd A. Blanchard		Added name of personnel for auth numbers.
 										Changed logic to get only template orders.
007	11/21/2019	Todd A. Blanchard		Added health plan.
008	01/07/2020	Todd A. Blanchard		Adjusted criteria for practice site exclusions.
009	03/16/2020	Todd A. Blanchard		Added pre-reg date/time, exam start date/time,
										scheduled state, order entered by, and encounter status.
										Adjusted criteria for scheduled event actions.
010	04/22/2020	Todd A. Blanchard		Adjusted criteria for scheduled event attachments.
										Restructured CCL to accurately produce distinct values.
011	05/27/2020	Todd A. Blanchard		Adjusted criteria for organization exclusions.
										Added name of personnel for prereg dt/tm.
012	08/04/2020	Todd A. Blanchard		Added additional scheduling OE field values.
013	08/10/2020	Todd A. Blanchard		Added additional order OE field values.
014	08/20/2020	Todd A. Blanchard		Added scanned order indicator.
015	09/02/2020	Todd A. Blanchard		Added CMG vs Non-CMG indicator.
										Added exceptions for Thompson Oncology and Thompson Cancer.
										Added prompt option for Pre-Reg Action.
										Added patient DOB.
016	09/21/2020	Todd A. Blanchard		Adjusted logic for CMG vs Non-CMG indicator.
017	09/30/2020	Todd A. Blanchard		Added hidden prompt and functionality to export scheduled action
										data to file.
018	10/13/2020	Todd A. Blanchard		Added functionality to export appointment data to file.
019	10/22/2020	Todd A. Blanchard		Changed date parameters from 4 to 5 day timeframe for export options.
020	10/28/2020	Todd A. Blanchard		Adjusted logic for CMG vs Non-CMG indicator.
021	11/09/2020	Todd A. Blanchard		Added separate paths for files.
022	12/14/2020	Todd A. Blanchard		Added option to persist record structure.
023	01/04/2021	Todd A. Blanchard		Adjusted logic for CMG vs Non-CMG indicator.
024	01/19/2021	Todd A. Blanchard		Adjusted logic for pre-reg personnel.
025	01/26/2021	Todd A. Blanchard		Added logic to remove non-printable characters from auth number values.
026	03/23/2021	Todd A. Blanchard		Added logic for unauthorized physicians.
027	04/08/2021	Todd A. Blanchard		Changed date parameters from 5 to 6 day timeframe for export options.
028	06/09/2021	Todd A. Blanchard		Added free record statement.
029	07/15/2021	Todd A. Blanchard		Changed exclusion logic to use record set.
										Removed exclusions for locations Main OR and Endoscopy when selected
										report type is Appointment Date.
030	08/02/2021	Todd A. Blanchard		Changed date parameters from 6 to 9 day timeframe for export options.
										Reverted changes to exclusions for locations Main OR and Endoscopy.
031	11/11/2021	Todd A. Blanchard		Added Covenant Health Diagnostics West.
032	01/17/2022	Todd A. Blanchard		Added location nurse unit.
033	03/07/2022	Todd A. Blanchard		Changed practice site display to org name.
034	03/24/2022	Todd A. Blanchard		Added logic to filter out patients with last name ZZZ*
										when report type is 0, 1, or 3.
035	11/17/2022	Todd A. Blanchard		Changed date parameters from 9 to 11 day timeframe for export options.
******************************************************************************/
 
drop program cov_sm_Order_Appt_TAT_TEST:DBA go
create program cov_sm_Order_Appt_TAT_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 0
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, start_datetime, end_datetime, report_type, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime				= dq8 with noconstant(cnvtdatetime(curdate, 000000)) ;017
declare end_datetime				= dq8 with noconstant(cnvtdatetime(curdate, 235959)) ;017

declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare confirm_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CONFIRM"))
declare rescheduled_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare ord_physician_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULING ORDERING PHYSICIAN"))
declare auc_ord_adhere_mod_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "AUCORDERADHERENCEMODIFIER")) ;012
declare qual_cdsm_utilized_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "QUALIFIEDCDSMUTILIZED")) ;012
declare attachtype_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare physician_order_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER"))
declare outside_order_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER"))
declare unauth_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 8, "UNAUTH")) ;026

declare reqstartdttm_var			= f8 with constant(51.00)
declare specinx_var					= f8 with constant(1103.00)
declare schedauthnbr_var			= f8 with constant(124.00)
declare commenttype2_var			= f8 with constant(2088.00)
declare enteredby_var				= f8 with constant(3303.00)
declare aucord_adheremod_var		= f8 with constant(6059.00) ;013
declare qualcdsm_utilized_var		= f8 with constant(6058.00) ;013
declare golive_dt_tm_var			= vc with constant("01-MAY-2018 000000") ;015

declare column_var					= vc with noconstant("")
declare op_datefilter_var			= vc with noconstant("")
declare num							= i4 with noconstant(0) ;029

declare file0_var					= vc with constant("tatappt.csv") ;018
declare file1_var					= vc with constant(build(format(curdate, "mm-dd-yyyy;;d"), "_tat.csv")) ;017 ;018
declare file_var					= vc with noconstant("") ;018

declare dir0_var					= vc with noconstant("Centralized/TATAppt/") ;021
declare dir1_var					= vc with noconstant("Centralized/TAT/") ;021
declare dir_var						= vc with noconstant("") ;021

;018 ;021
if ($report_type = 0)
	set file_var = file0_var
	set dir_var = dir0_var
	
elseif ($report_type = 1)
	set file_var = file1_var
	set dir_var = dir1_var
	
endif
 
declare temppath_var				= vc with constant(build("cer_temp:", file_var)) ;017
declare temppath2_var				= vc with constant(build("$cer_temp/", file_var)) ;017

;017 ;021
declare filepath_var				= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
												"_cust/to_client_site/RevenueCycle/Scheduling/", dir_var, file_var))
															 
declare output_var					= vc with noconstant("") ;017
 
declare cmd							= vc with noconstant("") ;017
declare len							= i4 with noconstant(0) ;017
declare stat						= i4 with noconstant(0) ;017


; define dates ;017 ;018
if (validate(request->batch_selection) = 1)
	if (($report_type = 0) or ($report_type = 1)) ;027
		set start_datetime = cnvtdatetime(start_datetime)
		set end_datetime = cnvtlookahead("11,D", end_datetime) ;019 ;027 ;030 ;035
	endif
else
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)	
endif


; define column value ;003
if ($report_type = 0) ; appointment date
	set column_var = "sa.beg_dt_tm"
 
elseif ($report_type = 1) ; scheduled action date
	set column_var = "seva2.action_dt_tm"
 
elseif ($report_type = 2) ; order action date
	set column_var = "oa.action_dt_tm"

;015
elseif ($report_type = 3) ; pre-reg date
	set column_var = "e.pre_reg_dt_tm"
 
endif

set op_datefilter_var = build2(
		column_var, " between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)" ;017
	)
	
 
; define output value ;017
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

;029
free record loc_exclusion_data
record loc_exclusion_data (
	1	cnt							= i4
	1	list[*]
		2	location_cd				= f8
)

;010
free record tat_data ;028
record tat_data (
	1	cnt							= i4
	1	list[*]
		2	person_id				= f8
		2	name_full_formatted		= c100
		2	birth_dt_tm				= dq8 ;015
		2	birth_tz				= i4 ;015
		2	fin						= c20
		2	encntr_id				= f8 ;014
		2	encntr_type				= c40
		2	encntr_status			= c40
		2	loc_nurse_unit			= c40 ;032
		2	order_id				= f8
		2	order_mnemonic			= c100
		2	ordering_physician		= c100
		2	ord_phys_group			= c100
		2	practice_site_id		= f8 ;015
		2	is_cmg					= i2 ;015
		2	appt_location			= c40
		2	org_name				= c100
		2	sch_state				= c40
		2	pre_reg_dt_tm			= dq8
		2	pre_reg_prsnl			= c100
		2	appt_dt_tm				= dq8
		2	exam_start_dt_tm		= dq8
		2	entry_state				= c40
		2	earliest_dt_tm			= dq8
		2	appt_tat_days			= i4
		2	requested_start_dt_tm	= dq8
		2	order_entered_by		= c100
		2	order_action_dt_tm		= dq8
		2	order_action_type		= c40
		2	sch_action_dt_tm		= dq8
		2	sch_action_type			= c40
		2	sch_action_prsnl		= c100
		2	sch_tat_days			= i4
		2	prior_auth				= c50
		2	auth_entered_by			= c100
		2	auth_dt_tm				= dq8
		2	auth_tat_days			= i4
		2	auth_nbr				= c50
		2	auth_nbr_entered_by		= c100
		2	health_plan				= c100
		2	sch_auc_order_adhere_mod	= c100 ;012 ;013
		2	sch_qual_cdsm_utilized		= c100 ;012 ;013
		2	ord_auc_order_adhere_mod	= c100 ;013
		2	ord_qual_cdsm_utilized		= c100 ;013
		2	ord_qual_cdsm_utilized		= c100 ;013
		2	has_scanned_order		= i2 ;014
		2	comment					= c255
)
with persistscript ;022
 
 
/**************************************************************/
; select location exclusion data ;029
select
	if ($report_type >= 0) ;030
;030
;	if ($report_type = 0)
;		where
;			cv.code_set > 0
;			and ((
;				cv.cdf_meaning in ("ANCILSURG", "SURGAREA", "SURGOP", "AMBULATORY")
;				and (
;					cv.display_key in ("*PREADM*TESTING")
;					or cv.display_key in ("*NON*SURGICAL")
;					or cv.display_key in ("*LABOR*DELIVERY")
;					or cv.display_key in ("*ECOR")
;				))
;			or (
;				cv.cdf_meaning in ("AMBULATORY")
;				and cv.description in ("*INFUSION*")
;			))
;			and cv.active_ind = 1
;	else
		where
			cv.code_set > 0
			and ((
				cv.cdf_meaning in ("ANCILSURG", "SURGAREA", "SURGOP", "AMBULATORY")
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
	endif
	
into "NL:"

from
	CODE_VALUE cv
 
 
; populate location exclusion record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	
	call alterlist(loc_exclusion_data->list, cnt)
	
	loc_exclusion_data->cnt							= cnt
	loc_exclusion_data->list[cnt].location_cd		= cv.code_value

with nocounter, time = 600

call echorecord(loc_exclusion_data)


/**************************************************************/
; select appointment data
select
	if ($report_type in (0, 1, 3))
		; appointment date, scheduled action date, pre-reg date
		from
			SCH_APPT sa
 
			, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
				and e.active_ind = 1)
 
			, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
				and eaf.encntr_alias_type_cd = fin_var)
			
			;011
			, (left join PRSNL per_e on per_e.person_id = e.pre_reg_prsnl_id
				;and per_e.active_ind = 1 ;024
				)
 
			, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
			, (inner join ORGANIZATION org on org.organization_id = l.organization_id
				; practice site exclusions ;008
				and org.organization_id not in (
					select ps.organization_id
					from PRACTICE_SITE ps
					where 
						ps.practice_site_id > 0.0 ;012
						and ps.organization_id not in (
							; acutes
							3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00, 3144503.00, 3144504.00, 
							3898154.00, 0.0 ;031
						)
				)
				; organization exclusions ;011
				and org.org_name_key not in ("CARDIOLOGY*ASSOCIATES*OF*EAST*TENNESSEE*")
				and org.org_name_key not in ("CROSSVILLE*MEDICAL*GROUP*")
				and org.org_name_key not in ("SOUTHERN*MEDICAL*GROUP*")
				and org.org_name_key not in ("UROLOGY*SPECIALISTS*OF*EAST*TENNESSEE*")
				and org.org_name_key not in ("KNOXVILLE*HEART*GROUP*")
				and org.org_name_key not in ("HAMBLEN*UROLOGY*")
				)
 
			, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
				and sev.active_ind = 1)
 
 			;002
			, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
				and sed.oe_field_id = ord_physician_var
				and sed.beg_effective_dt_tm <= sysdate
				and sed.end_effective_dt_tm > sysdate
				and sed.active_ind = 1)
 
 			;012
			, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
				and sed2.oe_field_id = auc_ord_adhere_mod_var
				and sed2.beg_effective_dt_tm <= sysdate
				and sed2.end_effective_dt_tm > sysdate
				and sed2.active_ind = 1)
 
 			;012
			, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
				and sed3.oe_field_id = qual_cdsm_utilized_var
				and sed3.beg_effective_dt_tm <= sysdate
				and sed3.end_effective_dt_tm > sysdate
				and sed3.active_ind = 1)
 
 			;002
			, (left join PRSNL per_sed on per_sed.person_id = sed.oe_field_value
				and per_sed.active_ind = 1)
 
 			; first practice site ;005
			, (left join PRSNL_RELTN pr on pr.person_id = per_sed.person_id
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
			
			, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id) ;033
 
			; first confirm
			, (inner join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
				and seva.action_meaning = "CONFIRM" ;009
				and seva.action_dt_tm = (
					select min(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva.sch_event_id
						and action_meaning = "CONFIRM" ;009
						and active_ind = 1
					group by
						sch_event_id
				)
				and seva.active_ind = 1
				)
 
			, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id) ;001
 
			; last confirm
			, (inner join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sev.sch_event_id
				and seva2.action_meaning = "CONFIRM" ;009
				and seva2.action_dt_tm = (
					select max(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva2.sch_event_id
						and action_meaning = "CONFIRM" ;009
						and active_ind = 1
					group by
						sch_event_id
				)
				and seva2.active_ind = 1
				)
 
			, (left join PRSNL per_seva2 on per_seva2.person_id = seva2.action_prsnl_id) ;001
 
			, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
 
			, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
				and sea.attach_type_cd = attachtype_order_var
;				and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED") ;010
				and sea.active_ind = 1)
 
			, (inner join ORDERS o on o.order_id = sea.order_id
				and o.template_order_id = 0.0 ;006
				and o.active_ind = 1)
 
			, (left join ORDER_DETAIL od on od.order_id = o.order_id
				and	od.oe_field_meaning_id = reqstartdttm_var)
 
			, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
				and	od2.oe_field_meaning_id = specinx_var)
 
 			;003
			, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
				and od3.oe_field_meaning_id = schedauthnbr_var)
 
			, (left join PRSNL per_od3 on per_od3.person_id = od3.updt_id)
 
			, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
				and od4.oe_field_meaning_id = commenttype2_var)
 
			;009
			, (left join ORDER_DETAIL od5 on od5.order_id = o.order_id
				and od5.oe_field_meaning_id = enteredby_var)
 
 			;013
			, (left join ORDER_DETAIL od6 on od6.order_id = o.order_id
				and od6.oe_field_meaning_id = aucord_adheremod_var)
 
 			;013
			, (left join ORDER_DETAIL od7 on od7.order_id = o.order_id
				and od7.oe_field_meaning_id = qualcdsm_utilized_var)
				
			;009
			, (left join OMF_RADMGMT_ORDER_ST oros on oros.order_id = o.order_id)
 
			, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
				and oa.action_type_cd = order_var
				and oa.action_sequence > 0)
 
			, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id)
 
 			; first practice site ;005
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
			
			, (left join ORGANIZATION org_psoa on org_psoa.organization_id = ps_oa.organization_id) ;033
 
			, (inner join PERSON p on p.person_id = sa.person_id
				and p.name_last_key not in ("ZZZ*")) ;034
 
			, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
				and epr.priority_seq = 1
				and epr.end_effective_dt_tm > sysdate
				and epr.active_ind = 1)
 
			, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id) ;007
 
 			;003
			, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
				and epar.active_ind = 1)
 
 			;003
			, (left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
				and au.active_ind = 1)
 
			, (left join PRSNL per_au on per_au.person_id = au.updt_id)
 
		where
			parser(op_datefilter_var)
			and sa.schedule_id > 0.0
			and sa.role_meaning = "PATIENT"
			and sa.sch_state_cd != rescheduled_var
			; location exclusions ;029
			and not expand(num, 1, loc_exclusion_data->cnt, sa.appt_location_cd, loc_exclusion_data->list[num].location_cd)
			and sa.active_ind = 1
 
	else
		; order action date ;004
		from
			ORDERS o
 
			, (left join ORDER_DETAIL od on od.order_id = o.order_id
				and	od.oe_field_meaning_id = reqstartdttm_var)
 
			, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
				and	od2.oe_field_meaning_id = specinx_var)
 
 			;003
			, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
				and od3.oe_field_meaning_id = schedauthnbr_var)
 
			, (left join PRSNL per_od3 on per_od3.person_id = od3.updt_id)
 
			, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
				and od4.oe_field_meaning_id = commenttype2_var)
 
			;009
			, (left join ORDER_DETAIL od5 on od5.order_id = o.order_id
				and od5.oe_field_meaning_id = enteredby_var)
 
 			;013
			, (left join ORDER_DETAIL od6 on od6.order_id = o.order_id
				and od6.oe_field_meaning_id = aucord_adheremod_var)
 
 			;013
			, (left join ORDER_DETAIL od7 on od7.order_id = o.order_id
				and od7.oe_field_meaning_id = qualcdsm_utilized_var)
				
			;009
			, (left join OMF_RADMGMT_ORDER_ST oros on oros.order_id = o.order_id)
 
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
 
			, (left join ORGANIZATION org_psoa on org_psoa.organization_id = ps_oa.organization_id) ;033
 
			, (left join SCH_EVENT_ATTACH sea on sea.order_id = o.order_id
				and sea.attach_type_cd = attachtype_order_var
;				and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED") ;010
				and sea.active_ind = 1)
 
			, (left join SCH_EVENT sev on sev.sch_event_id = sea.sch_event_id
				and sev.active_ind = 1)
 
 			;002
			, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
				and sed.oe_field_id = ord_physician_var
				and sed.beg_effective_dt_tm <= sysdate
				and sed.end_effective_dt_tm > sysdate
				and sed.active_ind = 1)
 
 			;012
			, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
				and sed2.oe_field_id = auc_ord_adhere_mod_var
				and sed2.beg_effective_dt_tm <= sysdate
				and sed2.end_effective_dt_tm > sysdate
				and sed2.active_ind = 1)
 
 			;012
			, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
				and sed3.oe_field_id = qual_cdsm_utilized_var
				and sed3.beg_effective_dt_tm <= sysdate
				and sed3.end_effective_dt_tm > sysdate
				and sed3.active_ind = 1)
 
			, (left join SCH_APPT sa on sa.sch_event_id = sev.sch_event_id
				and sa.schedule_id > 0.0
				and sa.role_meaning = "PATIENT"
				and sa.sch_state_cd != rescheduled_var
				; location exclusions ;029
				and not expand(num, 1, loc_exclusion_data->cnt, sa.appt_location_cd, loc_exclusion_data->list[num].location_cd)
				and sa.active_ind = 1
				)
 
			, (left join ENCOUNTER e on ((e.encntr_id = sa.encntr_id)
				or (e.encntr_id = o.encntr_id))
				and e.active_ind = 1)
 
			, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
				and eaf.encntr_alias_type_cd = fin_var)
			
			;011
			, (left join PRSNL per_e on per_e.person_id = e.pre_reg_prsnl_id
				;and per_e.active_ind = 1 ;024
				)
 
			, (left join LOCATION l on l.location_cd = sa.appt_location_cd)
 
			, (left join ORGANIZATION org on org.organization_id = l.organization_id
				; practice site exclusions ;008
				and org.organization_id not in (
					select ps.organization_id
					from PRACTICE_SITE ps
					where
						ps.practice_site_id > 0.0
						and ps.organization_id not in (
							; acutes
							3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00, 3144503.00, 3144504.00,  
							3898154.00, 0.0 ;031
						)
				)
				; organization exclusions ;011
				and org.org_name_key not in ("CARDIOLOGY*ASSOCIATES*OF*EAST*TENNESSEE*")
				and org.org_name_key not in ("CROSSVILLE*MEDICAL*GROUP*")
				and org.org_name_key not in ("SOUTHERN*MEDICAL*GROUP*")
				and org.org_name_key not in ("UROLOGY*SPECIALISTS*OF*EAST*TENNESSEE*")
				and org.org_name_key not in ("KNOXVILLE*HEART*GROUP*")
				and org.org_name_key not in ("HAMBLEN*UROLOGY*")
				)
 
 			;002
			, (left join PRSNL per_sed on per_sed.person_id = sed.oe_field_value
				and per_sed.active_ind = 1)
 
 			; first practice site ;005
			, (left join PRSNL_RELTN pr on pr.person_id = per_sed.person_id
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
 
			, (left join ORGANIZATION org_ps on org_ps.organization_id = ps.organization_id) ;033
 
			; first confirm
			, (left join SCH_EVENT_ACTION seva on seva.sch_event_id = sev.sch_event_id
				and seva.action_meaning = "CONFIRM" ;009
				and seva.action_dt_tm = (
					select min(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva.sch_event_id
						and action_meaning = "CONFIRM" ;009
						and active_ind = 1
					group by
						sch_event_id
				)
				and seva.active_ind = 1
				)
 
			, (left join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id) ;001
 
			; last confirm
			, (left join SCH_EVENT_ACTION seva2 on seva2.sch_event_id = sev.sch_event_id
				and seva2.action_meaning = "CONFIRM" ;009
				and seva2.action_dt_tm = (
					select max(action_dt_tm)
					from SCH_EVENT_ACTION
					where
						sch_event_id = seva2.sch_event_id
						and action_meaning = "CONFIRM" ;009
						and active_ind = 1
					group by
						sch_event_id
				)
				and seva2.active_ind = 1
				)
 
			, (left join PRSNL per_seva2 on per_seva2.person_id = seva2.action_prsnl_id) ;001
 
			, (left join SCH_ENTRY sen on sen.sch_event_id = sev.sch_event_id)
 
			, (left join PERSON p on (p.person_id = sa.person_id)
				or (p.person_id = o.person_id))

			, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
				and epr.priority_seq = 1
				and epr.end_effective_dt_tm > sysdate
				and epr.active_ind = 1)
 
			, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id) ;007
 
 			;003
			, (left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
				and epar.active_ind = 1)
 
 			;003
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
			and o.template_order_id = 0.0 ;006
			and o.active_ind = 1 
			and nullval(p.name_last_key, "") not in ("ZZZ*") ;034
	endif
 
into "NL:" ;010
 
 
; populate tat_data record structure
head report
	cnt = 0
 
	call alterlist(tat_data->list, 100)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(tat_data->list, cnt + 9)
	endif
 
	tat_data->cnt								= cnt
	tat_data->list[cnt].person_id				= p.person_id
	tat_data->list[cnt].name_full_formatted		= p.name_full_formatted
	tat_data->list[cnt].birth_dt_tm				= p.birth_dt_tm ;015
	tat_data->list[cnt].birth_tz				= p.birth_tz ;015
	tat_data->list[cnt].fin						= cnvtalias(eaf.alias, eaf.alias_pool_cd)
	tat_data->list[cnt].encntr_id				= e.encntr_id
	tat_data->list[cnt].encntr_type				= uar_get_code_display(e.encntr_type_cd) ;005
	tat_data->list[cnt].encntr_status			= uar_get_code_display(e.encntr_status_cd) ;009
	tat_data->list[cnt].loc_nurse_unit			= uar_get_code_display(e.loc_nurse_unit_cd) ;032
	tat_data->list[cnt].order_id				= o.order_id
	tat_data->list[cnt].order_mnemonic			= o.order_mnemonic
	
	;002 ;026
	tat_data->list[cnt].ordering_physician		= if (per_oa.data_status_cd = unauth_var)
													"Unauthorized Physician"
												  else
												  	if (sed.oe_field_value > 0.0) ;015
														trim(sed.oe_field_display_value, 3)
													else
														trim(per_oa.name_full_formatted, 3)
													endif
												  endif
		
 	;005
	tat_data->list[cnt].ord_phys_group			= if (ps.practice_site_id > 0.0) ;015
													trim(org_ps.org_name, 3) ;033
												  else
													trim(org_psoa.org_name, 3) ;033
												  endif
	
	;015
	tat_data->list[cnt].practice_site_id		= if (ps.practice_site_id > 0.0)
													ps.practice_site_id
												  else
												  	ps_oa.practice_site_id
												  endif
													
	tat_data->list[cnt].appt_location			= if (sa.appt_location_cd > 0.0)
													uar_get_code_display(sa.appt_location_cd)
												  else
													trim(od4.oe_field_display_value, 3)
												  endif
													
	tat_data->list[cnt].org_name				= org.org_name
	
	tat_data->list[cnt].sch_state				= uar_get_code_display(sa.sch_state_cd) ;009
	tat_data->list[cnt].pre_reg_dt_tm			= e.pre_reg_dt_tm ;009
	tat_data->list[cnt].pre_reg_prsnl			= per_e.name_full_formatted ;011
	tat_data->list[cnt].appt_dt_tm				= sa.beg_dt_tm
	tat_data->list[cnt].exam_start_dt_tm		= oros.start_dt_tm ;009
	tat_data->list[cnt].entry_state				= uar_get_code_display(sen.entry_state_cd)
	
	tat_data->list[cnt].earliest_dt_tm			= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
													and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))
														sen.earliest_dt_tm
												  endif
		
	tat_data->list[cnt].appt_tat_days			= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
													and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100")))														
														datetimediff(sa.beg_dt_tm, sen.earliest_dt_tm)
												  endif
		
	tat_data->list[cnt].requested_start_dt_tm	= od.oe_field_dt_tm_value
	tat_data->list[cnt].order_entered_by		= trim(od5.oe_field_display_value, 3) ;009
	tat_data->list[cnt].order_action_dt_tm		= oa.action_dt_tm
	tat_data->list[cnt].order_action_type		= uar_get_code_display(oa.action_type_cd)
	
	tat_data->list[cnt].sch_action_dt_tm		= if (seva.action_dt_tm = seva2.action_dt_tm)
													seva.action_dt_tm
												  else
													seva2.action_dt_tm
												  endif
		
	tat_data->list[cnt].sch_action_type			= if (seva.action_dt_tm = seva2.action_dt_tm)
													uar_get_code_display(seva.sch_action_cd)
												  else
													uar_get_code_display(seva2.sch_action_cd)
												  endif
													
 	;001
	tat_data->list[cnt].sch_action_prsnl		= if (seva.action_dt_tm = seva2.action_dt_tm)
													per_seva.name_full_formatted
												  else
													per_seva2.name_full_formatted
												  endif
													
	tat_data->list[cnt].sch_tat_days			= if (seva.action_dt_tm = seva2.action_dt_tm);														
													datetimediff(seva.action_dt_tm, od.oe_field_dt_tm_value)
												  else
													datetimediff(seva2.action_dt_tm, od.oe_field_dt_tm_value)
												  endif
		
	tat_data->list[cnt].prior_auth				= trim(replace(replace(
													od3.oe_field_display_value, char(13), " ", 4), char(10), " ", 4), 3) ;003 ;025
	
	tat_data->list[cnt].auth_entered_by			= if (size(trim(od3.oe_field_display_value, 3)) > 0)
													per_od3.name_full_formatted
												  endif
		
	tat_data->list[cnt].auth_dt_tm				= od3.updt_dt_tm
	
	tat_data->list[cnt].auth_tat_days			= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
													and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100"))
													and (od3.updt_dt_tm > 0))
														datetimediff(od3.updt_dt_tm, sen.earliest_dt_tm)
												  endif
	
	tat_data->list[cnt].auth_nbr				= trim(replace(replace(
													au.auth_nbr, char(13), " ", 4), char(10), " ", 4), 3) ;003 ;025
	
	tat_data->list[cnt].auth_nbr_entered_by		= if (size(trim(au.auth_nbr, 3)) > 0)
													per_au.name_full_formatted
												  endif
													
	tat_data->list[cnt].health_plan				= hp.plan_name ;007
	
	tat_data->list[cnt].sch_auc_order_adhere_mod	= trim(sed2.oe_field_display_value, 3) ;012 ;013
	tat_data->list[cnt].sch_qual_cdsm_utilized		= trim(sed3.oe_field_display_value, 3) ;012 ;013
	
	tat_data->list[cnt].ord_auc_order_adhere_mod	= trim(od6.oe_field_display_value, 3) ;013
	tat_data->list[cnt].ord_qual_cdsm_utilized		= trim(od7.oe_field_display_value, 3) ;013
	
	tat_data->list[cnt].comment					= trim(replace(replace(od2.oe_field_display_value, char(13), " ", 4), char(10), " ", 4), 3)
 
with nocounter, expand = 1, time = 600

;call echorecord(tat_data)


/**************************************************************/
; select scanned order data ;014
select into "NL:"
from
	CLINICAL_EVENT ce
	
	, (dummyt d1 with seq = value(tat_data->cnt))

plan d1

join ce
where
	ce.encntr_id = tat_data->list[d1.seq].encntr_id
	and ce.person_id = tat_data->list[d1.seq].person_id
	and ce.event_cd in (
		physician_order_var, outside_order_var
	)
 
 
; populate tat_data record structure
detail
	tat_data->list[d1.seq].has_scanned_order = 1
	
with nocounter, time = 600

;call echorecord(tat_data)


/**************************************************************/
; select org set data ;015 ;016
select into "NL:"
	; derive cmg indicator - tog is the exception
	is_cmg = if (os.name like "*CMG*") 1
		elseif (org.org_name_key like "THOMPSONONCOLOGYGROUP*") 1 
		elseif (org.org_name_key like "FSRSLEEPDISORDERSCENTER*") 1 ;023
		elseif (ps.practice_site_display like "Thompson Cancer*") 1 ;015
		elseif (ps.practice_site_display like "Peninsula*Clinic*") 1 ;020
		else 0 
		endif
		
from
	PRACTICE_SITE ps
	
	, (left join ORG_SET_ORG_R osor on osor.organization_id = ps.organization_id
		and osor.active_ind = 1)
	
	, (left join ORG_SET os on os.org_set_id = osor.org_set_id
		and os.active_ind = 1)
		
	, (left join ORGANIZATION org on org.organization_id = osor.organization_id
		and org.active_ind = 1)
	
	, (dummyt d1 with seq = value(tat_data->cnt))

plan d1

join ps
where
	ps.practice_site_id = tat_data->list[d1.seq].practice_site_id
	
join osor
join os
join org
 
 
; populate tat_data record structure ;016
detail
	if (is_cmg = 1)
		tat_data->list[d1.seq].is_cmg = is_cmg
	endif
	
with nocounter, time = 600

;call echorecord(tat_data)


/**************************************************************/
; select data

;017
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

;017
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, separator = " ", format, time = 600
endif

;017
distinct into value(output_var)
	person_id						= tat_data->list[d1.seq].person_id
	, name_full_formatted			= tat_data->list[d1.seq].name_full_formatted
	, dob							= format(cnvtdatetimeutc(datetimezone(
										tat_data->list[d1.seq].birth_dt_tm, 
										tat_data->list[d1.seq].birth_tz), 1), "mm/dd/yyyy;;d") ;015
	, fin							= tat_data->list[d1.seq].fin
	, encntr_type					= tat_data->list[d1.seq].encntr_type
	, encntr_status					= tat_data->list[d1.seq].encntr_status
	, order_id						= tat_data->list[d1.seq].order_id
	, order_mnemonic				= tat_data->list[d1.seq].order_mnemonic
	, ordering_physician			= tat_data->list[d1.seq].ordering_physician
	, ord_phys_group				= tat_data->list[d1.seq].ord_phys_group	
	, is_cmg						= evaluate(tat_data->list[d1.seq].is_cmg, 1, "Y", "N") ;015
	, appt_location					= tat_data->list[d1.seq].appt_location
	, org_name						= tat_data->list[d1.seq].org_name
	, sch_state						= tat_data->list[d1.seq].sch_state
	, pre_reg_dt_tm					= tat_data->list[d1.seq].pre_reg_dt_tm "@SHORTDATETIME"
	, pre_reg_prsnl					= tat_data->list[d1.seq].pre_reg_prsnl
	, appt_dt_tm					= tat_data->list[d1.seq].appt_dt_tm "@SHORTDATETIME"
	, exam_start_dt_tm				= tat_data->list[d1.seq].exam_start_dt_tm "@SHORTDATETIME"
	, entry_state					= tat_data->list[d1.seq].entry_state
	, earliest_dt_tm				= tat_data->list[d1.seq].earliest_dt_tm "@SHORTDATETIME"
	, appt_tat_days					= format(tat_data->list[d1.seq].appt_tat_days, ";R;I")
	, requested_start_dt_tm			= tat_data->list[d1.seq].requested_start_dt_tm "@SHORTDATETIME"
	, order_entered_by				= tat_data->list[d1.seq].order_entered_by
	, order_action_dt_tm			= tat_data->list[d1.seq].order_action_dt_tm "@SHORTDATETIME"
	, order_action_type				= tat_data->list[d1.seq].order_action_type
	, sch_action_dt_tm				= tat_data->list[d1.seq].sch_action_dt_tm "@SHORTDATETIME"
	, sch_action_type				= tat_data->list[d1.seq].sch_action_type
	, sch_action_prsnl				= tat_data->list[d1.seq].sch_action_prsnl
	, sch_tat_days					= format(tat_data->list[d1.seq].sch_tat_days, ";R;I")
	, prior_auth					= tat_data->list[d1.seq].prior_auth
	, auth_entered_by				= tat_data->list[d1.seq].auth_entered_by
	, auth_dt_tm					= tat_data->list[d1.seq].auth_dt_tm "@SHORTDATETIME"
	, auth_tat_days					= format(tat_data->list[d1.seq].auth_tat_days, ";R;I")
	, auth_nbr						= tat_data->list[d1.seq].auth_nbr
	, auth_nbr_entered_by			= tat_data->list[d1.seq].auth_nbr_entered_by
	, health_plan					= tat_data->list[d1.seq].health_plan
	, auc_order_adhere_mod			= tat_data->list[d1.seq].sch_auc_order_adhere_mod
	, qual_cdsm_utilized			= tat_data->list[d1.seq].sch_qual_cdsm_utilized
	, ecare_auc_order_adhere_mod	= tat_data->list[d1.seq].ord_auc_order_adhere_mod
	, ecare_qual_cdsm_utilized		= tat_data->list[d1.seq].ord_qual_cdsm_utilized
	, has_scanned_order				= evaluate(tat_data->list[d1.seq].has_scanned_order, 1, "Y", "N") ;014	
	, comment						= tat_data->list[d1.seq].comment
	, loc_nurse_unit				= tat_data->list[d1.seq].loc_nurse_unit ;032
 
from
	(dummyt d1 with seq = value(tat_data->cnt))
 
plan d1
 
order by
	build(tat_data->list[d1.seq].name_full_formatted, tat_data->list[d1.seq].person_id)
	, tat_data->list[d1.seq].appt_dt_tm
	, tat_data->list[d1.seq].sch_action_dt_tm
	, tat_data->list[d1.seq].requested_start_dt_tm
	, tat_data->list[d1.seq].earliest_dt_tm
	, tat_data->list[d1.seq].exam_start_dt_tm
	, build(tat_data->list[d1.seq].order_action_dt_tm, tat_data->list[d1.seq].order_id)
	, build(tat_data->list[d1.seq].appt_tat_days, tat_data->list[d1.seq].sch_tat_days, tat_data->list[d1.seq].auth_tat_days)
	, build(tat_data->list[d1.seq].prior_auth, tat_data->list[d1.seq].auth_nbr)
	, comment

with nocounter

 
; copy file to AStream ;017
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
 

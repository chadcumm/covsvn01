/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/19/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingResource.prg
	Object name:		cov_sm_SchedulingResource
	Request #:			3613, 4365, 4481, 5092, 5516, 6080, 8487, 8563, 8652, 
						8965, 9016, 9086
 
	Program purpose:	Lists scheduled resources from Report Request module.
 
	Executing from:		CCL
 
 	Special Notes:		This is a report/extract CCL.  Changes have to be
						coordinated with downstream processes.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	11/30/2018	Todd A. Blanchard		Adjusted CCL logic.
 										Added prompt for patient.
002	12/04/2018	Todd A. Blanchard		Adjusted patient parameter.
003	12/20/2018	Todd A. Blanchard		Adjusted queue prompt and limited results to
 										non-behavioral health data.
004	02/07/2019	Todd A. Blanchard		Added prompt for physician group.
 										Adjusted prompt for request list queue.
005	02/20/2019	Todd A. Blanchard		Added DOB with time zone adjustment.
006	03/21/2019	Todd A. Blanchard		Adjusted query for prior auth data.
007	08/13/2019	Todd A. Blanchard		Adjusted criteria to include all resources.
008	09/05/2019	Todd A. Blanchard		Added comments.
009	10/01/2019	Daniel Claus			Added Physician Group filter to prompts and query.
010	02/19/2020	Todd A. Blanchard		Changed data sources of earliest_date and 
 										order_date columns.
 										Added verification for protocol data.
 										Added handling of non-printable characters.
011	08/26/2020	Todd A. Blanchard		Revised prompts.
										Adjusted patient criteria.
										Adjusted order detail queries.
										Adjusted order by clause.
012	09/10/2020	Todd A. Blanchard		Revised sort order for request queue prompt.
013	10/01/2020	Todd A. Blanchard		Added hidden prompt and functionality to export data to file.
014	11/09/2020	Todd A. Blanchard		Adjusted criteria for exclusions.
015	11/19/2020	Todd A. Blanchard		Adjusted order action queries to include ordering physician.
016	11/30/2020	Todd A. Blanchard		Added column to separate encounter and person health plan data.
017	12/11/2020	Todd A. Blanchard		Added prompt and logic to filter CMG vs non-CMG data.
										Added physician number to queries.
018	01/20/2021	Todd A. Blanchard		Added FIN and revised sort order for request queue prompt.
019 05/21/2021  Chad Cummings			Updated Order detail selections to include an alias per CWx 
020 05/22/2021  Chad Cummings			Removed group by in nested OD selections 
021 08/05/2021  Chad Cummings			Added order priority
******************************************************************************/
 
drop program 2cov_sm_SchedulingResource:DBA go
create program 2cov_sm_SchedulingResource:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"          ;* Enter or select the printer or file name to send this report to.
	, "Request List Queue" = 0
	, "Physician Group" = VALUE(0.0             )
	, "Patient" = ""
	, "CMG Only" = 0                                ;* CMG Only
	, "Output To File" = 0                          ;* Output to file 

with OUTDEV, request_queue, physician_group, patient, cmg_only, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var							= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare pending_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 23018, "PENDING"))
declare request_list_queue_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16146, "REQUESTLISTQUEUE"))
declare sch_auth_number_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHAUTHNUMBER"))
declare ord_physician_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULING ORDERING PHYSICIAN"))
declare sch_instructions_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULINGINSTRUCTIO12654"))
declare special_instructions_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "SPECIALINSTRUCTIONS"))
declare requested_start_datetime_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "REQUESTEDSTARTDATETIME")) ;010
declare rescheduled_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "RESCHEDULED")) ;012
declare order_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER")) ;015
declare orgdoc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR")) ;017
declare stardoc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER")) ;017
declare priority_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 16449, "PRIORITY")) ;021

declare num								= i4 with noconstant(0)

declare op_request_queue_var			= c2 with noconstant("")
declare op_physician_group_var			= c2 with noconstant("")
declare patient_sql						= vc with noconstant("1 = 1") ;011
declare cmg_sql							= vc with noconstant("1 = 1") ;017

declare file_var						= vc with noconstant("") ;017
declare file1_var						= vc with constant(build(format(curdate, "mm-dd-yyyy;;d"), "_resourcedetail.csv")) ;013 ;017
declare file2_var						= vc with constant(build(format(curdate, "mm-dd-yyyy;;d"), "_resourcedetail_cmg.csv")) ;017

;017
if ($cmg_only = 1)
	set file_var = file2_var
else
	set file_var = file1_var
endif
 
declare temppath_var					= vc with constant(build("cer_temp:", file_var)) ;013
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var)) ;013

;013
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
															 
declare output_var						= vc with noconstant("") ;013
 
declare cmd								= vc with noconstant("") ;013
declare len								= i4 with noconstant(0) ;013
declare stat							= i4 with noconstant(0) ;013
 
 
; define operator for $request_queue
if (substring(1, 1, reflect(parameter(parameter2($request_queue), 0))) = "L") ; multiple values selected
    set op_request_queue_var = "IN"
elseif (parameter(parameter2($request_queue), 1) = 0.0) ; any selected
    set op_request_queue_var = "!="
else
    set op_request_queue_var = "=" ; single value selected
endif
 
 
; define operator for $physician_group
if (substring(1, 1, reflect(parameter(parameter2($physician_group), 0))) = "L") ; multiple values selected
    set op_physician_group_var = "IN"
elseif (parameter(parameter2($physician_group), 1) = 0.0) ; any selected
    set op_physician_group_var = ">="
else
    set op_physician_group_var = "=" ; single value selected
endif
 
 
; define sql for $patient ;011
if ($patient != "") ; value entered
    set patient_sql = build2("p.name_full_formatted = '*", $patient, "*'")
endif


; define sql for $cmg_only ;017
if ($cmg_only = 1)
	set cmg_sql = "expand(num, 1, cmg_data->cnt, sched_obj->list[d1.seq].ord_phys_group_id, cmg_data->list[num].practice_site_id)"
endif
	
 
; define output value ;013
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_obj (
	1	bh_flg							= i2
 
	1	sched_cnt						= i4
	1	list[*]
		2	sch_object_id				= f8
		2	sch_obj_desc				= c100
 
		2	sch_entry_id				= f8
		2	sch_action_id				= f8
		2	sch_appt_id					= f8
		2	req_action					= c20
		2	appt_type					= c100
		2	earliest_dt_tm				= dq8 
		2	sch_event_id				= f8
		
		2	ordering_physician_id		= f8
		2	ordering_physician			= c100
		2	ordering_physician_alias	= c20
		2	ord_phys_group_id			= f8
		2	ord_phys_group				= c100
 
		2	order_id					= f8
		2	order_mnemonic				= c100
		2	order_dt_tm					= dq8
		2	prior_auth					= c30
		2	sch_inst					= c255
		2	special_inst				= c255
		2   priority					= c30 ;021
 
		2	sch_dt_tm					= dq8
		2	sch_resource				= c100
 
		2	person_id					= f8
		2	patient_name				= c100
		2	dob							= dq8
		2	dob_tz						= i4
 
 		2	encntr_id					= f8
 		2	fin							= c20 ;018
 
		2	health_plan_enc				= c35 ;016
		2	health_plan_per				= c35 ;016
)

;017
record cmg_data (
	1	cnt								= i4
	1	list[*]
		2	practice_site_id			= f8
)


/**************************************************************/
; select cmg practice data ;017
if ($cmg_only = 1)
	select distinct
		data.practice_site_id
	
	from ((	
		select
			ps.practice_site_id
			
			, is_cmg = evaluate2(
				if (os.name like "*CMG*") 1
				elseif (org.org_name_key like "THOMPSONONCOLOGYGROUP*") 1 
				elseif (ps.practice_site_display like "Thompson Cancer*") 1
				else 0 
				endif
				)
		
		from
			PRACTICE_SITE ps
			
			, (left join ORG_SET_ORG_R osor on osor.organization_id = ps.organization_id
				and osor.active_ind = 1)
			
			, (left join ORG_SET os on os.org_set_id = osor.org_set_id
				and os.active_ind = 1)
				
			, (left join ORGANIZATION org on org.organization_id = osor.organization_id
				and org.active_ind = 1)
		
		where
			ps.practice_site_id > 0.0
			and ps.practice_site_display not in ("*DO NOT USE*")
			
		with sqltype("f8", "i4")
	) data)
	
	where
		data.is_cmg = 1
		
	order by
		data.practice_site_id
	 
	 
	; populate record structure
	head report
		cnt = 0
	 
	detail
		cnt = cnt + 1
	 
		call alterlist(cmg_data->list, cnt)
	 
		cmg_data->cnt							= cnt
		cmg_data->list[cnt].practice_site_id	= data.practice_site_id
	
	WITH nocounter, time = 60
endif

call echorecord(cmg_data)
 
 
/**************************************************************/
; select scheduled object data - based on event detail
select into "NL:"
from
	SCH_OBJECT so
 
	, (inner join SCH_ENTRY sen on sen.queue_id = so.sch_object_id
		and sen.entry_state_cd = pending_var ; pending
		and sen.active_ind = 1)
 
	, (inner join SCH_EVENT_ACTION seva on seva.sch_action_id = sen.sch_action_id
		and seva.version_dt_tm > sysdate)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = seva.sch_event_id
		and sev.version_dt_tm > sysdate)
 
	, (left join SCH_EVENT_DETAIL sed on sed.sch_event_id = sev.sch_event_id
		and sed.sch_action_id >= 0.0
		and sed.oe_field_id = ord_physician_var
		and sed.beg_effective_dt_tm <= sysdate
		and sed.end_effective_dt_tm > sysdate
		and sed.seq_nbr >= 0
		and sed.version_dt_tm > sysdate
		and sed.active_ind = 1)
 
	, (left join PRSNL per on per.person_id = sed.oe_field_value
		and per.active_ind = 1)
	
	;017
	, (left join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = orgdoc_var
		and pera.alias_pool_cd = stardoc_var
		and pera.end_effective_dt_tm > sysdate
		and pera.active_ind = 1)
 
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 
	, (left join SCH_APPT sa on sa.sch_event_id = sev.sch_event_id
		and sa.role_meaning = "PATIENT"
		and sa.sch_state_cd != rescheduled_var ;012
		and sa.version_dt_tm > sysdate)
 
	, (left join SCH_APPT sar on sar.sch_event_id = sev.sch_event_id
		and sar.role_meaning != "PATIENT"
		and sar.version_dt_tm > sysdate)
 
	, (inner join PERSON p on p.person_id = sen.person_id
		and parser(patient_sql) ;011
		and p.active_ind = 1)
 
	, (left join ENCOUNTER e on e.encntr_id = sen.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.active_ind = 1)
 
where
	operator(so.sch_object_id, op_request_queue_var, $request_queue) ; request queue
	and so.object_type_cd = request_list_queue_var
	and so.mnemonic_key not in ("BH*", "PBH*", "AMB*")
    and so.mnemonic_key not in ("*IT*USE*ONLY*") ;014
	and so.active_ind = 1
	and operator(nullval(ps.practice_site_id, 0.0), op_physician_group_var, $physician_group)
 
order by
	so.sch_object_id
	, sev.sch_event_id
 
 
; populate sched_obj record structure
head report
	cnt = 0
 
head so.sch_object_id
	null
 
detail
	cnt = cnt + 1
 
	call alterlist(sched_obj->list, cnt)
 
	sched_obj->sched_cnt							= cnt
	sched_obj->list[cnt].sch_object_id				= so.sch_object_id
	sched_obj->list[cnt].sch_obj_desc				= so.description
 
	sched_obj->list[cnt].sch_entry_id				= sen.sch_entry_id
	sched_obj->list[cnt].sch_action_id				= sen.sch_action_id
	sched_obj->list[cnt].sch_appt_id				= sen.sch_appt_id
	sched_obj->list[cnt].req_action					= trim(uar_get_code_display(sen.req_action_cd), 3)
	sched_obj->list[cnt].appt_type					= trim(uar_get_code_display(sen.appt_type_cd), 3)
;	sched_obj->list[cnt].earliest_dt_tm				= sen.earliest_dt_tm ;010 
	sched_obj->list[cnt].sch_event_id				= sev.sch_event_id
														
	sched_obj->list[cnt].ordering_physician_id		= sed.oe_field_value ;017
	sched_obj->list[cnt].ordering_physician			= trim(sed.oe_field_display_value, 3)
	sched_obj->list[cnt].ordering_physician_alias	= trim(pera.alias, 3) ;017
	sched_obj->list[cnt].ord_phys_group_id			= ps.practice_site_id
	sched_obj->list[cnt].ord_phys_group				= trim(ps.practice_site_display, 3)
 
	sched_obj->list[cnt].person_id					= p.person_id
	sched_obj->list[cnt].patient_name				= p.name_full_formatted
	sched_obj->list[cnt].dob						= p.birth_dt_tm
	sched_obj->list[cnt].dob_tz						= p.birth_tz
 
	sched_obj->list[cnt].sch_dt_tm					= sa.beg_dt_tm
	sched_obj->list[cnt].sch_resource				= trim(uar_get_code_display(sar.resource_cd), 3)
 
 	sched_obj->list[cnt].encntr_id					= e.encntr_id
 	sched_obj->list[cnt].fin						= ea.alias
 
WITH nocounter, time = 600

;call echorecord(sched_obj)
;
;go to exitscript
 
 
/**************************************************************/
; select scheduled object data - based on order action ;015
select into "NL:"
from
	SCH_OBJECT so
 
	, (inner join SCH_ENTRY sen on sen.queue_id = so.sch_object_id
		and sen.entry_state_cd = pending_var ; pending
		and sen.active_ind = 1)
 
	, (inner join SCH_EVENT_ACTION seva on seva.sch_action_id = sen.sch_action_id
		and seva.version_dt_tm > sysdate)
 
	, (inner join SCH_EVENT sev on sev.sch_event_id = seva.sch_event_id
		and sev.version_dt_tm > sysdate)

	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.order_id > 0.0
		and sea.state_meaning != "REMOVED"
		and sea.active_ind = 1)
 
 	;015
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
		
	;015
	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
 	;015
	, (left join PRSNL per on per.person_id = oa.action_personnel_id)
	
	;017
	, (left join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = orgdoc_var
		and pera.alias_pool_cd = stardoc_var
		and pera.end_effective_dt_tm > sysdate
		and pera.active_ind = 1)
 
 	;015
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
 	;015
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 
	, (left join SCH_APPT sa on sa.sch_event_id = sev.sch_event_id
		and sa.role_meaning = "PATIENT"
		and sa.sch_state_cd != rescheduled_var ;012
		and sa.version_dt_tm > sysdate)
 
	, (left join SCH_APPT sar on sar.sch_event_id = sev.sch_event_id
		and sar.role_meaning != "PATIENT"
		and sar.version_dt_tm > sysdate)
 
	, (inner join PERSON p on p.person_id = sen.person_id
		and parser(patient_sql) ;011
		and p.active_ind = 1)
 
	, (left join ENCOUNTER e on e.encntr_id = sen.encntr_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.active_ind = 1)
 
where
	operator(so.sch_object_id, op_request_queue_var, $request_queue) ; request queue
	and so.object_type_cd = request_list_queue_var
	and so.mnemonic_key not in ("BH*", "PBH*", "AMB*")
    and so.mnemonic_key not in ("*IT*USE*ONLY*") ;014
	and so.active_ind = 1
	and operator(nullval(ps.practice_site_id, 0.0), op_physician_group_var, $physician_group)
 
order by
	so.sch_object_id
	, sev.sch_event_id
 
 
; populate sched_obj record structure
head report
	cnt = sched_obj->sched_cnt
 
head so.sch_object_id
	null
 
detail
	cnt = cnt + 1
 
	call alterlist(sched_obj->list, cnt)
 
	sched_obj->sched_cnt							= cnt
	sched_obj->list[cnt].sch_object_id				= so.sch_object_id
	sched_obj->list[cnt].sch_obj_desc				= so.description
 
	sched_obj->list[cnt].sch_entry_id				= sen.sch_entry_id
	sched_obj->list[cnt].sch_action_id				= sen.sch_action_id
	sched_obj->list[cnt].sch_appt_id				= sen.sch_appt_id
	sched_obj->list[cnt].req_action					= trim(uar_get_code_display(sen.req_action_cd), 3)
	sched_obj->list[cnt].appt_type					= trim(uar_get_code_display(sen.appt_type_cd), 3)
;	sched_obj->list[cnt].earliest_dt_tm				= sen.earliest_dt_tm ;010 
	sched_obj->list[cnt].sch_event_id				= sev.sch_event_id
														
	sched_obj->list[cnt].ordering_physician_id		= per.person_id ;017
	sched_obj->list[cnt].ordering_physician			= per.name_full_formatted
	sched_obj->list[cnt].ordering_physician_alias	= trim(pera.alias, 3) ;017
	sched_obj->list[cnt].ord_phys_group_id			= ps.practice_site_id
	sched_obj->list[cnt].ord_phys_group				= trim(ps.practice_site_display, 3)		
		
	sched_obj->list[cnt].person_id					= p.person_id
	sched_obj->list[cnt].patient_name				= p.name_full_formatted
	sched_obj->list[cnt].dob						= p.birth_dt_tm
	sched_obj->list[cnt].dob_tz						= p.birth_tz
 
	sched_obj->list[cnt].sch_dt_tm					= sa.beg_dt_tm
	sched_obj->list[cnt].sch_resource				= trim(uar_get_code_display(sar.resource_cd), 3)
 
 	sched_obj->list[cnt].encntr_id					= e.encntr_id
 	sched_obj->list[cnt].fin						= ea.alias
 
WITH nocounter, time = 600

;call echorecord(sched_obj)
;
;go to exitscript
 
 
/**************************************************************/
; select scheduled procedures data for non-protocol events ;010
select distinct into "NL:"
from	
	SCH_EVENT sev

	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.order_id > 0.0
		and sea.state_meaning != "REMOVED"
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
 	;011
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_id = sch_auth_number_var
		and od.action_sequence = (
			;019 select max(action_sequence)
			;019 from ORDER_DETAIL
			;019 where 
			;019 	order_id = od.order_id
			;019 	and oe_field_id = od.oe_field_id
			;019 group by
			;019 	order_id
			select max(od22.action_sequence)			;019
			from ORDER_DETAIL od22						;019
			where 										;019
				od22.order_id = od.order_id				;019
			 	and od22.oe_field_id = od.oe_field_id	;019
			;020 group by									;019
			;020  	od22.order_id							;019
		))
 
 	;011
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_id = sch_instructions_var
		and od2.action_sequence = (
			;019 select max(action_sequence)
			;019 from ORDER_DETAIL
			;019 where 
			;019 	order_id = od2.order_id
			;019 	and oe_field_id = od2.oe_field_id
			;019 group by
			;019 	order_id
			
			select max(od23.action_sequence)			;019 
			from ORDER_DETAIL od23						;019 
			where 										;019 
				od23.order_id = od2.order_id			;019 
				and od23.oe_field_id = od2.oe_field_id	;019 
			;020 group by									;019 
			;020 	od23.order_id								;019 
		))
 
 	;011
	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_id = special_instructions_var
		and od3.action_sequence = (
			/* start 019
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od3.order_id
				and oe_field_id = od3.oe_field_id
			group by
				order_id */
			/*start 019*/
			select max(od24.action_sequence)
			from ORDER_DETAIL od24
			where 
				od24.order_id = od3.order_id
				and od24.oe_field_id = od3.oe_field_id
			;020 group by
			;020 	od24.order_id
			/*end 019*/
		))

 	;011
	, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
		and od4.oe_field_id = requested_start_datetime_var
		and od4.action_sequence = (
			/*start 019
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od4.order_id
				and oe_field_id = od4.oe_field_id
			group by
				order_id */
			
			/*start 019*/
			select max(action_sequence)
			from ORDER_DETAIL od25
			where 
				od25.order_id = od4.order_id
				and od25.oe_field_id = od4.oe_field_id
			;020 group by
			;020 	od25.order_id
			/*end 019*/
		))
		
	;015
	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
 	;015
	, (left join PRSNL per on per.person_id = oa.action_personnel_id)
	
	;017
	, (left join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = orgdoc_var
		and pera.alias_pool_cd = stardoc_var
		and pera.end_effective_dt_tm > sysdate
		and pera.active_ind = 1)
 
 	;015
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
 	;015
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 	
 	;021
	, (left join ORDER_DETAIL od5 on od5.order_id = o.order_id
		and od5.oe_field_id = priority_var
		and od5.action_sequence = (
			/*start 019
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od4.order_id
				and oe_field_id = od4.oe_field_id
			group by
				order_id */
			
			/*start 019*/
			select max(action_sequence)
			from ORDER_DETAIL od26
			where 
				od26.order_id = od5.order_id
				and od26.oe_field_id = od5.oe_field_id
			;020 group by
			;020 	od25.order_id
			/*end 019*/
		)) 
where
	expand(num, 1, size(sched_obj->list, 5), sev.sch_event_id, sched_obj->list[num].sch_event_id)
	and sev.version_dt_tm > sysdate
;	and operator(nullval(ps.practice_site_id, 0.0), op_physician_group_var, $physician_group)
 
order by
	sev.sch_event_id
	, o.order_id
 
 
; populate sched_obj record structure with procedure data
head sev.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sev.sch_event_id, sched_obj->list[numx].sch_event_id)
 
head o.order_id
	sched_obj->list[idx].order_id = o.order_id	
 
	if (sea.order_status_meaning not in ("CANCELED", "COMPLETED", "DISCONTINUED"))
		sched_obj->list[idx].order_mnemonic = trim(o.order_mnemonic, 3)
		
		;017
		if (sched_obj->list[idx].ordering_physician_id = 0.0)
			sched_obj->list[idx].ordering_physician_id = per.person_id
		endif
		
		;015
		if (textlen(trim(sched_obj->list[idx].ordering_physician, 3)) = 0)
			sched_obj->list[idx].ordering_physician	= per.name_full_formatted
		endif
		
		;017
		if (textlen(trim(sched_obj->list[idx].ordering_physician_alias, 3)) = 0)
			sched_obj->list[idx].ordering_physician_alias = trim(pera.alias, 3)
		endif
	
		;015	
		if (sched_obj->list[idx].ord_phys_group_id = 0.0)
			sched_obj->list[idx].ord_phys_group_id = ps.practice_site_id
		endif
		
		;015		
		if (textlen(trim(sched_obj->list[idx].ord_phys_group, 3)) = 0)
			sched_obj->list[idx].ord_phys_group = trim(ps.practice_site_display, 3)
		endif
		
		;015
		if (sev.protocol_parent_id = 0.0)
			sched_obj->list[idx].earliest_dt_tm = cnvtdate(od4.oe_field_dt_tm_value)
		endif
			
		sched_obj->list[idx].priority			= od5.oe_field_display_value	;021												
		sched_obj->list[idx].order_dt_tm		= o.orig_order_dt_tm
		sched_obj->list[idx].prior_auth			= trim(od.oe_field_display_value, 3)
		
		sched_obj->list[idx].sch_inst			= replace(od2.oe_field_display_value, char(13), " ", 4)
		sched_obj->list[idx].sch_inst			= replace(sched_obj->list[idx].sch_inst, char(10), " ", 4)
		sched_obj->list[idx].sch_inst			= replace(sched_obj->list[idx].sch_inst, char(0), " ", 4)
		sched_obj->list[idx].sch_inst			= trim(sched_obj->list[idx].sch_inst, 3)
		
		sched_obj->list[idx].special_inst		= replace(od3.oe_field_display_value, char(13), " ", 4)
		sched_obj->list[idx].special_inst		= replace(sched_obj->list[idx].special_inst, char(10), " ", 4)
		sched_obj->list[idx].special_inst		= replace(sched_obj->list[idx].special_inst, char(0), " ", 4)
		sched_obj->list[idx].special_inst		= trim(sched_obj->list[idx].special_inst, 3)
	endif
 
WITH nocounter, expand = 1, time = 600

;call echorecord(sched_obj)
;
;go to exitscript
 
 
/**************************************************************/
; select scheduled procedures data for protocol events ;010
select distinct into "NL:"
from
	SCH_EVENT sev

	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.order_id > 0.0
		and sea.state_meaning != "REMOVED"
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
 
 	;011
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_id = sch_auth_number_var
		and od.action_sequence = (
			/*start 019
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od.order_id
				and oe_field_id = od.oe_field_id
			group by
				order_id
			*/
			select max(od26.action_sequence)
			from ORDER_DETAIL od26
			where 
				od26.order_id = od.order_id
				and od26.oe_field_id = od.oe_field_id
			;020 group by
			;020 	od26.order_id
		))
 
 	;011
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_id = sch_instructions_var
		and od2.action_sequence = (
			/* start 019
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od2.order_id
				and oe_field_id = od2.oe_field_id
			group by
				order_id */
			
			select max(od27.action_sequence)
			from ORDER_DETAIL od27
			where 
				od27.order_id = od2.order_id
				and od27.oe_field_id = od2.oe_field_id
			;020 group by
			;020 	od27.order_id
		))
 
 	;011
	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_id = special_instructions_var
		and od3.action_sequence = (
			/* start 019 select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od3.order_id
				and oe_field_id = od3.oe_field_id
			group by
				order_id
			*/ 
			select max(od28.action_sequence)
			from ORDER_DETAIL od28
			where 
				od28.order_id = od3.order_id
				and od28.oe_field_id = od3.oe_field_id
			;020 group by
			;020 	od28.order_id
		))

 	;011
	, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
		and od4.oe_field_id = requested_start_datetime_var
		and od4.action_sequence = (
			/* start 019 select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od4.order_id
				and oe_field_id = od4.oe_field_id
			group by
				order_id
			*/
			
			select max(od29.action_sequence)
			from ORDER_DETAIL od29
			where 
				od29.order_id = od4.order_id
				and od29.oe_field_id = od4.oe_field_id
			;020 group by
			;020 	od29.order_id
		))
		
	;015
	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var)
 
 	;015
	, (left join PRSNL per on per.person_id = oa.action_personnel_id)
	
	;017
	, (left join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = orgdoc_var
		and pera.alias_pool_cd = stardoc_var
		and pera.end_effective_dt_tm > sysdate
		and pera.active_ind = 1)
 
 	;015
	, (left join PRSNL_RELTN pr on pr.person_id = per.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1)
 
 	;015
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
	;021
	, (left join ORDER_DETAIL od5 on od5.order_id = o.order_id
		and od5.oe_field_id = priority_var
		and od5.action_sequence = (
			/*start 019
			select max(action_sequence)
			from ORDER_DETAIL
			where 
				order_id = od4.order_id
				and oe_field_id = od4.oe_field_id
			group by
				order_id */
			
			/*start 019*/
			select max(action_sequence)
			from ORDER_DETAIL od30
			where 
				od30.order_id = od5.order_id
				and od30.oe_field_id = od5.oe_field_id
			;020 group by
			;020 	od25.order_id
			/*end 019*/
		))
where
	expand(num, 1, size(sched_obj->list, 5), sev.protocol_parent_id, sched_obj->list[num].sch_event_id)
	and sev.version_dt_tm > sysdate
;	and operator(nullval(ps.practice_site_id, 0.0), op_physician_group_var, $physician_group)
 
order by
	sev.sch_event_id
	, o.order_id
	, od4.action_sequence desc
 
 
; populate sched_obj record structure with procedure data
head sev.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sev.protocol_parent_id, sched_obj->list[numx].sch_event_id)
	
head o.order_id
	sched_obj->list[idx].order_id = o.order_id	
 
	if (sea.order_status_meaning not in ("CANCELED", "COMPLETED", "DISCONTINUED"))
		sched_obj->list[idx].order_mnemonic = trim(o.order_mnemonic, 3)
		
		;017
		if (sched_obj->list[idx].ordering_physician_id = 0.0)
			sched_obj->list[idx].ordering_physician_id = per.person_id
		endif
		
		;015		
		if (textlen(trim(sched_obj->list[idx].ordering_physician, 3)) = 0)
			sched_obj->list[idx].ordering_physician	= per.name_full_formatted
		endif
		
		;017
		if (textlen(trim(sched_obj->list[idx].ordering_physician_alias, 3)) = 0)
			sched_obj->list[idx].ordering_physician_alias = trim(pera.alias, 3)
		endif
	
		;015		
		if (sched_obj->list[idx].ord_phys_group_id = 0.0)
			sched_obj->list[idx].ord_phys_group_id = ps.practice_site_id
		endif
		
		;015		
		if (textlen(trim(sched_obj->list[idx].ord_phys_group, 3)) = 0)
			sched_obj->list[idx].ord_phys_group = trim(ps.practice_site_display, 3)
		endif
		
		;015
		if (sev.protocol_parent_id > 0.0)
			sched_obj->list[idx].earliest_dt_tm = cnvtdate(od4.oe_field_dt_tm_value)
		endif
													
		sched_obj->list[idx].order_dt_tm		= o.orig_order_dt_tm
		sched_obj->list[idx].prior_auth			= trim(od.oe_field_display_value, 3)
		sched_obj->list[idx].priority			= od5.oe_field_display_value	;021
		sched_obj->list[idx].sch_inst			= replace(od2.oe_field_display_value, char(13), " ", 4)
		sched_obj->list[idx].sch_inst			= replace(sched_obj->list[idx].sch_inst, char(10), " ", 4)
		sched_obj->list[idx].sch_inst			= replace(sched_obj->list[idx].sch_inst, char(0), " ", 4)
		sched_obj->list[idx].sch_inst			= trim(sched_obj->list[idx].sch_inst, 3)
		
		sched_obj->list[idx].special_inst		= replace(od3.oe_field_display_value, char(13), " ", 4)
		sched_obj->list[idx].special_inst		= replace(sched_obj->list[idx].special_inst, char(10), " ", 4)
		sched_obj->list[idx].special_inst		= replace(sched_obj->list[idx].special_inst, char(0), " ", 4)
		sched_obj->list[idx].special_inst		= trim(sched_obj->list[idx].special_inst, 3)
	endif
 
WITH nocounter, expand = 1, time = 600

;call echorecord(sched_obj)
;
;go to exitscript
 
 
/**************************************************************/
; select encounter health plan data
select into "NL:"
from
	SCH_ENTRY sen
 
	; encounter health plan
	, (inner join ENCNTR_PLAN_RELTN epr on epr.encntr_id = sen.encntr_id
		and epr.priority_seq = (
			select min(eprm.priority_seq)
			from ENCNTR_PLAN_RELTN eprm
			where
				eprm.encntr_id = epr.encntr_id
				and eprm.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
				and eprm.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
				and eprm.active_ind = 1
		)
		and epr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
		and epr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
		and epr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1)
 
where
	expand(num, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[num].sch_event_id)
	and sen.active_ind = 1
 
order by
	sen.sch_event_id
 
 
; populate sched_obj record structure with health plan data
head sen.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[numx].sch_event_id)
 
detail
 	sched_obj->list[idx].health_plan_enc = trim(hp.plan_name, 3) ;016
 
WITH nocounter, expand = 1, time = 600

;call echorecord(sched_obj)
;
;go to exitscript
 
 
/**************************************************************/
; select patient health plan data
select into "NL:"
from
	SCH_ENTRY sen
 
	; patient health plan
	, (inner join PERSON_PLAN_RELTN ppr on ppr.person_id = sen.person_id
		and ppr.priority_seq = (
			select min(pprm.priority_seq)
			from PERSON_PLAN_RELTN pprm
			where
				pprm.person_id = ppr.person_id
				and pprm.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
				and pprm.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
				and pprm.active_ind = 1
		)
		and ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 )
		and ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 )
		and ppr.active_ind = 1)
 
	, (inner join HEALTH_PLAN hp on hp.health_plan_id = ppr.health_plan_id
		and hp.active_ind = 1)
 
where
	expand(num, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[num].sch_event_id)
	and sen.active_ind = 1
 
order by
	sen.sch_event_id
 
 
; populate sched_obj record structure with health plan data
head sen.sch_event_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(sched_obj->list, 5), sen.sch_event_id, sched_obj->list[numx].sch_event_id)
 
detail
 	sched_obj->list[idx].health_plan_per = trim(hp.plan_name, 3) ;016

 
WITH nocounter, expand = 1, time = 600

call echorecord(sched_obj)
;
;go to exitscript

 
/**************************************************************/
; select data

;013
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

;013
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, expand = 1, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, expand = 1, separator = " ", format, time = 600
endif

;013
distinct into value(output_var)
	request_list_queue		= trim(sched_obj->list[d1.seq].sch_obj_desc, 3)
	, request_action		= trim(sched_obj->list[d1.seq].req_action, 3)
	, patient_name			= trim(sched_obj->list[d1.seq].patient_name, 3)
	, dob					= format(cnvtdatetimeutc(datetimezone(sched_obj->list[d1.seq].dob, sched_obj->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
	, fin					= trim(sched_obj->list[d1.seq].fin, 3) ;018
	, prior_auth			= trim(sched_obj->list[d1.seq].prior_auth, 3)
	, health_plan			= trim(sched_obj->list[d1.seq].health_plan_enc, 3) ;016
	, revcycle_health_plan	= trim(sched_obj->list[d1.seq].health_plan_per, 3) ;016
	, appt_type				= trim(sched_obj->list[d1.seq].appt_type, 3)
	, earliest_date			= evaluate2(
								if (cnvtdate(sched_obj->list[d1.seq].earliest_dt_tm) > 1)
									cnvtupper(build2(
										format(sched_obj->list[d1.seq].earliest_dt_tm, "mm/dd/yyyy;;d"), " - ",
										format(sched_obj->list[d1.seq].earliest_dt_tm, "hh:mm;;s")))
								else
									" "
								endif
								)
 
	, time					= evaluate2(
								if (format(sched_obj->list[d1.seq].earliest_dt_tm, "hh:mm;;d") != "00:00")
									format(sched_obj->list[d1.seq].earliest_dt_tm, "hh:mm;;d")
								else
									" "
								endif
								)
 
	, order_date			= evaluate2(
								if (sched_obj->list[d1.seq].order_dt_tm > 0)
									cnvtupper(build2(
										format(sched_obj->list[d1.seq].order_dt_tm, "mm/dd/yyyy;;d"), " - ",
										format(sched_obj->list[d1.seq].order_dt_tm, "hh:mm;;s")))
								else
									" "
								endif
								)
 
	, orders				= trim(sched_obj->list[d1.seq].order_mnemonic, 3)
	, ordering_phy			= trim(sched_obj->list[d1.seq].ordering_physician, 3)
	, physician_num			= trim(sched_obj->list[d1.seq].ordering_physician_alias, 3) ;017
	, group_practice		= trim(sched_obj->list[d1.seq].ord_phys_group, 3)
	, scheduled_date		= evaluate2(
								if (sched_obj->list[d1.seq].sch_dt_tm > 0)
									cnvtupper(build2(
										format(sched_obj->list[d1.seq].sch_dt_tm, "mm/dd/yyyy;;d"), " - ",
										format(sched_obj->list[d1.seq].sch_dt_tm, "hh:mm;;s")))
								else
									" "
								endif
								)
 
	, scheduled_resource	= trim(sched_obj->list[d1.seq].sch_resource, 3)
	, notes					= trim(sched_obj->list[d1.seq].sch_inst, 3)
	, comments				= trim(sched_obj->list[d1.seq].special_inst, 3)
	, order_priority		= trim(sched_obj->list[d1.seq].priority,3) ;021
from
	(dummyt d1 with seq = value(sched_obj->sched_cnt))
 
plan d1
where
	operator(sched_obj->list[d1.seq].ord_phys_group_id, op_physician_group_var, $physician_group)
	and parser(cmg_sql) ;017
 
order by
;	sched_obj->list[d1.seq].sch_obj_desc ;011
	;011
	if (cnvtupper(sched_obj->list[d1.seq].sch_obj_desc) in ("*CENTRALIZED*", "FSR*WEST*DIAGNOSTIC*CENTER"))
		build("0", sched_obj->list[d1.seq].sch_obj_desc)
    elseif (cnvtupper(sched_obj->list[d1.seq].sch_obj_desc) in ("*HOLD*")) ;012
        build("1", sched_obj->list[d1.seq].sch_obj_desc) ;012
	else
		sched_obj->list[d1.seq].sch_obj_desc
	endif
	, sched_obj->list[d1.seq].sch_action_id
	, sched_obj->list[d1.seq].sch_appt_id 

with nocounter

 
; copy file to AStream ;013
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
 

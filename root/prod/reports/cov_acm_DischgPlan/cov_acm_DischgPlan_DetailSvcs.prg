/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/04/2019
	Solution:			Revenue Cycle - Acute Care Management
	Source file name:	cov_acm_DischargePlan_DetailSvcs.prg
	Object name:		cov_acm_DischargePlan_DetailSvcs
	Request #:			4804, 6752
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001 12/17/2019	Todd A. Blanchard		Added room location from encounter.
 
******************************************************************************/
 
drop program cov_acm_DischgPlan_DetailSvcs:DBA go
create program cov_acm_DischgPlan_DetailSvcs:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date of Discharge" = "SYSDATE"
	, "End Date of Discharge" = "SYSDATE" 

with OUTDEV, facility, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare attending_phy_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN"))
declare social_worker_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "SOCIALWORKER"))
 
declare op_facility_var			= c2 with noconstant("")
 
 
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
 
record encntr_drg (
	1	p_facility			= vc
	1	p_startdate			= vc
	1	p_enddate			= vc
 
	1	cnt					= i4
	1	list[*]
		2	encntr_id		= f8
		2	facility		= c100
		2	business_name	= c100
		2	service			= c40
 
		2	person_id		= f8
		2	patient_name	= c100
		2	mrn				= c20
		2	fin				= c20
		2	discharge_date	= dq8
		2	loc_room		= c40 ;001
 
		2	attending_physician_name	= c100
		2	discharge_planner			= c100
		2	social_worker				= c100
		2	primary_payer				= c100
		2	pref						= i4
 
		2	drg_tfr						= c1
		2	drg_source_id				= c50
		2	drg_type					= c40
		2	drg_description				= c255
 
		2	service_comment				= c200
)
 
/**************************************************************/
; set prompt data
set encntr_drg->p_facility		= cnvtstring($facility)
set encntr_drg->p_startdate		= $start_datetime
set encntr_drg->p_enddate		= $end_datetime
 
 
/**************************************************************/
; select data
select if (parameter(parameter2($facility), 1) = 0.0) ; any selected
	where
		e.organization_id in (
			3144501.00, 675844.00, 3144505.00, 3144499.00, 3144502.00, 3144503.00, 3144504.00, 3234074.00
			)
		and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and e.active_ind = 1
		and (
			nullval(eosr.final_selection_ind, 0) = 1
			or (
				nullval(rts.final_tlc_facility_id, 0.0) = nullval(rtsfr.rcm_tlc_facility_id, 0.0)
				and nullval(rts.final_tlc_facility_id, 0.0) > 0.0
			)
		)
else
	where
		operator(e.organization_id, op_facility_var, $facility)
		and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and e.active_ind = 1
		and (
			nullval(eosr.final_selection_ind, 0) = 1
			or (
				nullval(rts.final_tlc_facility_id, 0.0) = nullval(rtsfr.rcm_tlc_facility_id, 0.0)
				and nullval(rts.final_tlc_facility_id, 0.0) > 0.0
			)
		)
endif

into "NL:"
	business_name	= evaluate2(
						if (nullval(eosr.organization_id, 0.0) > 0.0)
							org_eosr.org_name
						else
							rtf.tlc_facility_name
						endif
						)
 
from
	ENCOUNTER e
 
	, (inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	, (inner join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.end_effective_dt_tm > sysdate
		and eaf.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var
		and eam.end_effective_dt_tm > sysdate
		and eam.active_ind = 1)
 
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.beg_effective_dt_tm <= sysdate
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join ENCNTR_PRSNL_RELTN eper on eper.encntr_id = e.encntr_id
		and eper.encntr_prsnl_r_cd = attending_phy_var
		and eper.end_effective_dt_tm > sysdate
		and eper.active_ind = 1)
 
	, (left join PRSNL per_eper on per_eper.person_id = eper.prsnl_person_id)
 
	, (left join ENCNTR_PRSNL_RELTN eper2 on eper2.encntr_id = e.encntr_id
		and eper2.encntr_prsnl_r_cd = social_worker_var
		and eper2.end_effective_dt_tm > sysdate
		and eper2.active_ind = 1)
 
	, (left join PRSNL per_eper2 on per_eper2.person_id = eper2.prsnl_person_id)
 
	, (left join ENCNTR_ORG_SERVICE_RELTN eosr on eosr.encntr_id = e.encntr_id
		and eosr.active_ind = 1)
 
	, (left join LONG_TEXT lt on eosr.comment_long_text_id = lt.long_text_id)
 
	, (left join DRG d on d.encntr_id = e.encntr_id
		and d.active_ind = 1)
 
	, (left join NOMENCLATURE n on n.nomenclature_id = d.nomenclature_id)
 
	, (left join DRG_EXTENSION de on de.source_identifier = n.source_identifier
		and de.source_vocabulary_cd = n.source_vocabulary_cd
		and de.end_effective_dt_tm > sysdate
		and de.active_ind = 1)
 
	, (left join RCM_TLC_SERVICE rts on rts.encntr_id = e.encntr_id)
 
	, (left join RCM_TLC_SERVICE_FAC_R rtsfr on rtsfr.rcm_tlc_service_id = rts.rcm_tlc_service_id
		and rtsfr.version_dt_tm > sysdate)
 
	, (left join RCM_TLC_FACILITY rtf on rtf.rcm_tlc_facility_id = rtsfr.rcm_tlc_facility_id)
 
	, (left join RCM_ACTION ra on ra.parent_entity_id = rts.rcm_tlc_service_id
		and ra.parent_entity_name = "RCM_TLC_SERVICE"
		and ra.action_meaning = "CREATED")
 
	, (left join PRSNL per_ra on per_ra.person_id = ra.action_prsnl_id)
 
	, (left join RCM_ACTION ras on ras.parent_entity_id = eosr.encntr_org_service_reltn_id
		and ras.parent_entity_name = "ENCNTR_ORG_SERVICE_RELTN"
		and ras.action_meaning = "CREATED")
 
	, (left join PRSNL per_ras on per_ras.person_id = ras.action_prsnl_id)
 
	, (inner join ORGANIZATION org_e on org_e.organization_id = e.organization_id)
 
	, (left join ORGANIZATION org_epr on org_epr.organization_id = epr.organization_id)
 
	, (left join ORGANIZATION org_eosr on org_eosr.organization_id = eosr.organization_id)
 
order by
	org_e.organization_id
	, business_name
	, p.person_id
 
 
; populate encntr_drg record structure
head report
	cnt = 0
 
	call alterlist(encntr_drg->list, 100)
 
head org_e.organization_id
	null
 
head business_name
	null
 
head p.person_id
	null
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(encntr_drg->list, cnt + 9)
	endif
 
	encntr_drg->cnt									= cnt
	encntr_drg->list[cnt].encntr_id					= e.encntr_id
	encntr_drg->list[cnt].facility					= org_e.org_name
 
	encntr_drg->list[cnt].business_name				= evaluate2(
														if (nullval(eosr.organization_id, 0.0) > 0.0)
															org_eosr.org_name
														else
															rtf.tlc_facility_name
														endif
														)
 
	encntr_drg->list[cnt].service					= trim(uar_get_code_display(rts.service_cd), 3)
 
	encntr_drg->list[cnt].person_id					= p.person_id
	encntr_drg->list[cnt].patient_name				= p.name_full_formatted
	encntr_drg->list[cnt].mrn						= eam.alias
	encntr_drg->list[cnt].fin						= eaf.alias
	encntr_drg->list[cnt].discharge_date			= e.disch_dt_tm
	encntr_drg->list[cnt].loc_room					= uar_get_code_display(e.loc_room_cd) ;001
 
	encntr_drg->list[cnt].attending_physician_name	= per_eper.name_full_formatted
 
	encntr_drg->list[cnt].discharge_planner			= evaluate2(
														if (nullval(eosr.organization_id, 0.0) > 0.0)
															per_ras.name_full_formatted
														else
															per_ra.name_full_formatted
														endif
														)
 
	encntr_drg->list[cnt].social_worker				= per_eper2.name_full_formatted
	encntr_drg->list[cnt].primary_payer				= org_epr.org_name
 
	encntr_drg->list[cnt].pref						= evaluate2(
														if (nullval(eosr.organization_id, 0.0) > 0.0)
															eosr.priority_seq
														else
															rtsfr.priority_seq
														endif
														)
 
	encntr_drg->list[cnt].drg_tfr					= evaluate(de.transfer_rule_ind, 1, "Y", "N")
	encntr_drg->list[cnt].drg_source_id				= n.source_identifier
 
	encntr_drg->list[cnt].drg_type					= evaluate2(
														if (uar_get_code_display(n.contributor_system_cd) = " ")
															""
														elseif (uar_get_code_display(n.contributor_system_cd) = "CAREMGMT")
															"F"
														elseif (uar_get_code_display(n.contributor_system_cd) != "CAREMGMT")
															"W"
														endif
														)
 
	encntr_drg->list[cnt].drg_description			= n.source_string
 
	encntr_drg->list[cnt].service_comment			= replace(lt.long_text, char(13), " ", 4)
	encntr_drg->list[cnt].service_comment			= replace(encntr_drg->list[cnt].service_comment, char(10), " ", 4)
	encntr_drg->list[cnt].service_comment			= replace(encntr_drg->list[cnt].service_comment, char(0), " ", 4)
	encntr_drg->list[cnt].service_comment			= trim(encntr_drg->list[cnt].service_comment, 3)
 
foot report
	call alterlist(encntr_drg->list, cnt)
 
WITH nocounter, time = 120
 
 
/**************************************************************/
; select data
select distinct into $OUTDEV
	encntr_id					= encntr_drg->list[d1.seq].encntr_id
	, facility					= encntr_drg->list[d1.seq].facility
	, business_name				= encntr_drg->list[d1.seq].business_name
	, service					= encntr_drg->list[d1.seq].service
 
	, person_id					= encntr_drg->list[d1.seq].person_id
	, patient_name				= encntr_drg->list[d1.seq].patient_name
	, mrn						= encntr_drg->list[d1.seq].mrn
	, fin						= encntr_drg->list[d1.seq].fin
	, discharge_date			= format(encntr_drg->list[d1.seq].discharge_date, "mm/dd/yyyy;;D")
	, loc_room					= encntr_drg->list[d1.seq].loc_room ;001
 
	, attending_physician_name	= encntr_drg->list[d1.seq].attending_physician_name
	, discharge_planner			= encntr_drg->list[d1.seq].discharge_planner
	, social_worker				= encntr_drg->list[d1.seq].social_worker
	, primary_payer				= encntr_drg->list[d1.seq].primary_payer
	, pref						= encntr_drg->list[d1.seq].pref
 
	, drg_tfr					= encntr_drg->list[d1.seq].drg_tfr
	, drg_source_id				= encntr_drg->list[d1.seq].drg_source_id
	, drg_type					= encntr_drg->list[d1.seq].drg_type
	, drg_description			= encntr_drg->list[d1.seq].drg_description
 
	, service_comment			= trim(encntr_drg->list[d1.seq].service_comment, 3)
 
from
	(dummyt d1 with seq = value(encntr_drg->cnt))
 
plan d1
 
order by
	facility
	, business_name
	, patient_name
	, person_id
 
with nocounter, separator = " ", format, time = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 

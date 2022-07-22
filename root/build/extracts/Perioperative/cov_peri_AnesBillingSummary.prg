/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/26/2018
	Solution:			Perioperative
	Source file name:	cov_peri_AnesBillingSummary.prg
	Object name:		cov_peri_AnesBillingSummary
	Request #:			38
 
	Program purpose:	Anesthesia Billing Summary data for Anesthesia third-party billers.
 
	Executing from:		CCL
 
 	Special Notes:		Finalized Anesthesia records.
 						Information to bill for professional services.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	---------------------------------------
 
******************************************************************************/
 
drop program cov_peri_AnesBillingSummary:DBA go
create program cov_peri_AnesBillingSummary:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0.0
	, "Start Date" = "SYSDATE"
	, "Stop Date" = "SYSDATE"
 
with OUTDEV, facility, start_datetime, stop_datetime
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare wrap(data = vc) 		= vc
declare wrap2(data = vc) 		= vc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var 				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare home_address_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "HOME"))
declare business_address_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "BUSINESS"))
declare home_phone_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare employer_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 338, "EMPLOYER"))
declare guarantor_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 351, "DEFAULTGUARANTOR"))
declare facility_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 222, "FACILITYS"))
declare finnbr_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare icd_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 400, "ICD10CM"))
declare num						= i4 with noconstant(0)
declare num2					= i4 with noconstant(0)
declare num3					= i4 with noconstant(0)
 
declare filepath_var			= vc with noconstant("")
declare output_var				= vc with noconstant("")
 
declare output_main				= vc
declare output_diagnosis		= vc
declare output_action			= vc
declare output_group			= vc
declare output_item				= vc
declare output_personnel		= vc
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record main (
	1 p_facility								= vc
	1 p_fac										= vc
	1 p_start_datetime							= vc
	1 p_stop_datetime							= vc
 
	1 main_cnt									= i4
	1 list[*]
		; surgical case
		2 surg_case_id					    	= f8
		2 surg_case_nbr					    	= vc
 
	 	; patient
	 	2 person_id						    	= f8
		2 patient_name					    	= vc
		2 patient_ssn					    	= vc
		2 patient_street_addr			    	= vc
		2 patient_city					    	= vc
		2 patient_state					    	= vc
		2 patient_zipcode				    	= vc
		2 patient_phone_num				    	= vc
		2 patient_dob					   		= vc
		2 patient_age					    	= vc
		2 patient_gender				    	= vc
		2 patient_marital_status		    	= vc
 
	 	; patient employer
		2 employer						    	= vc
		2 employer_street_addr			    	= vc
		2 employer_city					    	= vc
		2 employer_state				    	= vc
		2 employer_zipcode				    	= vc
 
		; encounter
		2 encntr_id						    	= f8
		2 accident_related_ind			    	= vc
		2 accident_text					    	= vc
		2 reason_for_visit				    	= vc
		2 visit_type					    	= vc
 
		; diagnosis
		2 diag_cnt								= i4
		2 diagnosis[*]
			3 diagnosis_id 				    	= f8
			3 diagnosis_display 		    	= vc
 
		; insured
		2 relation_to_insured			    	= vc
		2 insured_name                      	= vc
		2 insured_ssn                       	= vc
		2 insured_street_addr               	= vc
		2 insured_city                      	= vc
		2 insured_state                     	= vc
		2 insured_zipcode                   	= vc
		2 insured_phone_num                 	= vc
		2 insured_dob                       	= vc
		2 insured_gender                    	= vc
		2 subscriber_policy_nbr             	= vc
		2 member_policy_nbr                 	= vc
		2 insured_group_nbr                 	= vc
		2 insured_plan_name                 	= vc
		2 insured_employer                  	= vc
		2 ins_prov_name                     	= vc
		2 ins_prov_street_addr              	= vc
		2 ins_prov_city                     	= vc
		2 ins_prov_state                    	= vc
		2 ins_prov_zipcode                  	= vc
 
		; other insured
		2 other_insured_name                	= vc
		2 other_insured_ssn                 	= vc
		2 other_insured_street_addr         	= vc
		2 other_insured_city                	= vc
		2 other_insured_state               	= vc
		2 other_insured_zipcode             	= vc
		2 other_insured_phone_num           	= vc
		2 other_insured_dob                 	= vc
		2 other_insured_gender              	= vc
		2 other_subscriber_policy_nbr       	= vc
		2 other_member_policy_nbr           	= vc
		2 other_insured_group_nbr           	= vc
		2 other_insured_plan_name           	= vc
		2 other_insured_employer            	= vc
		2 other_ins_prov_name               	= vc
		2 other_ins_prov_street_addr        	= vc
		2 other_ins_prov_city               	= vc
		2 other_ins_prov_state              	= vc
		2 other_ins_prov_zipcode            	= vc
 
		; guarantor
		2 guarantor_name				    	= vc
		2 guarantor_ssn					    	= vc
		2 guarantor_street_addr			    	= vc
		2 guarantor_city				    	= vc
		2 guarantor_state				    	= vc
		2 guarantor_zipcode				    	= vc
		2 guarantor_phone_num			    	= vc
		2 guarantor_dob					    	= vc
		2 guarantor_gender				    	= vc
		2 guarantor_marital_status		   		= vc
		2 guarantor_employer			    	= vc
		2 guarantor_employer_street_addr		= vc
		2 guarantor_employer_city		    	= vc
		2 guarantor_employer_state		    	= vc
		2 guarantor_employer_zipcode	    	= vc
 
		; facility/surgery
		2 facility                          	= vc
		2 facility_name                     	= vc
		2 federal_tax_id_nbr                	= vc
		2 facility_street_addr              	= vc
		2 facility_city                     	= vc
		2 facility_state                    	= vc
		2 facility_zipcode                  	= vc
		2 patient_account_nbr               	= vc
		2 patient_mrn                       	= vc
		2 primary_surgeon                   	= vc
		2 post_op_diag                      	= vc
		2 admit_dt_tm					    	= vc
		2 disch_dt_tm					    	= vc
		2 or_suite                          	= vc
 
		; anesthesia
		2 sa_anesthesia_record_id		    	= f8
		2 primary_proc                      	= vc
		2 proc_text                         	= vc
		2 anesthesia_type                   	= vc
		2 anes_prov_start_dt_tmt            	= vc
		2 anes_prov_stop_dt_tm              	= vc
		2 anes_prov_total                   	= vc
		2 units                             	= vc
		2 asa_class                         	= vc
 
		; action
		2 action_cnt							= i4
		2 action[*]
			3 sa_action_id 				    	= f8
			3 action_dt_tm 				    	= vc
			3 action_name 				    	= vc
 
			3 group_cnt							= i4
			3 group[*]
				4 sa_ref_group_id				= f8
				4 group_prompt					= vc
 
				4 item_cnt						= i4
				4 item[*]
					5 action_item_description	= vc
					5 action_value				= vc
 
		; personnel
		2 per_cnt								= i4
		2 personnel[*]
			3 person_id					    	= f8
			3 name_full_formatted 		    	= vc
			3 activity_type 			    	= vc
			3 start_time 				    	= vc
			3 stop_time 				    	= vc
			3 duration 					    	= vc
)
 
 
/**************************************************************/
; populate main record structure with prompt data
set main->p_facility = uar_get_code_description($facility)
set main->p_fac = uar_get_code_display($facility)
set main->p_start_datetime = format(cnvtdate2($start_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
set main->p_stop_datetime = format(cnvtdate2($stop_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
; build file name
;set filepath_var = build("cer_temp:Cov_AnesBillingSummary_", sched_fac->p_fac, ".csv")
;
;if (validate(request->batch_selection) = 1)
;	set output_var = value(filepath_var)
;else
	set output_var = value($OUTDEV)
;endif
 
 
/**************************************************************/
; select surgery/anesthesia data
select into "NL:"
from
	; surgical case
	SURGICAL_CASE sc
 
 	; patient
	, (inner join PERSON p on p.person_id = sc.person_id)
 
	, (left join PERSON_ALIAS pa on pa.person_id = p.person_id
		and pa.person_alias_type_cd = ssn_var)
 
	, (left join ADDRESS a on a.parent_entity_id = p.person_id
		and	a.parent_entity_name = "PERSON"
		and a.address_type_cd = home_address_var)
 
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and	ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = home_phone_var)
 
 	; patient employer
	, (left join PERSON_ORG_RELTN por on por.person_id = p.person_id
		and por.person_org_reltn_cd = employer_var)
 
	, (left join ORGANIZATION org on org.organization_id = por.organization_id)
 
	, (left join ADDRESS oa on oa.parent_entity_id = org.organization_id
		and	oa.parent_entity_name = "ORGANIZATION"
		and oa.address_type_cd = business_address_var)
 
	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sc.encntr_id)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = finnbr_var)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var)
 
	, (left join ENCNTR_ACCIDENT eacc on eacc.encntr_id = e.encntr_id
		and eacc.active_ind = 1)
 
	; facility
	, (inner join LOCATION l on l.location_cd = e.loc_facility_cd
		and l.location_type_cd = facility_var
		and l.location_cd = $facility)
 
	, (inner join ORGANIZATION lo on lo.organization_id = l.organization_id)
 
	, (left join ADDRESS loa on loa.parent_entity_id = lo.organization_id
		and	loa.parent_entity_name = "ORGANIZATION"
		and loa.address_type_cd = business_address_var)
 
	; surgery/anesthesia
	, (inner join PRSNL scper on scper.person_id = sc.surgeon_prsnl_id)
 
	, (inner join LONG_TEXT lt1 on lt1.long_text_id = sc.postop_diag_text_id)
 
	, (inner join SURG_CASE_PROCEDURE scp on scp.surg_case_id = sc.surg_case_id
		and scp.active_ind = 1)
 
	, (inner join SA_ANESTHESIA_RECORD sar on sar.surgical_case_id = sc.surg_case_id
		and sar.active_ind = 1
		and sar.event_id > 0.0) ; 0.0 = finalized
 
	, (inner join SA_ANESTHESIA_REC_STATUS sars on sars.sa_anesthesia_record_id = sar.sa_anesthesia_record_id
		and sars.active_ind = 1
		and sars.status_type_flag = 0) ; 0 = finalized
 
where
	sc.surg_start_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($stop_datetime)
	and sc.surg_stop_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($stop_datetime)
 
order by
	sc.surg_case_nbr_formatted
 
 
; populate main record structure with surgery/anesthesia data
head report
	cnt = 0
 
	call alterlist(main->list, 100)
 
head sc.surg_case_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(main->list, cnt + 9)
	endif
 
	; surgical case
	main->list[cnt].surg_case_id = sc.surg_case_id
	main->list[cnt].surg_case_nbr = sc.surg_case_nbr_formatted
 
 	; patient
	main->list[cnt].person_id = p.person_id
	main->list[cnt].patient_name = p.name_full_formatted
	main->list[cnt].patient_ssn = pa.alias
	main->list[cnt].patient_street_addr = a.street_addr
	main->list[cnt].patient_city = a.city
	main->list[cnt].patient_state = uar_get_code_display(a.state_cd)
	main->list[cnt].patient_zipcode = a.zipcode
	main->list[cnt].patient_phone_num = ph.phone_num
	main->list[cnt].patient_dob = format(p.birth_dt_tm, "mm/dd/yy")
	main->list[cnt].patient_age = cnvtage(p.birth_dt_tm)
	main->list[cnt].patient_gender = uar_get_code_display(p.sex_cd)
	main->list[cnt].patient_marital_status = uar_get_code_display(p.marital_type_cd)
 
 	; patient employer
	main->list[cnt].employer = org.org_name
	main->list[cnt].employer_street_addr = oa.street_addr
	main->list[cnt].employer_city = oa.city
	main->list[cnt].employer_state = uar_get_code_display(oa.state_cd)
	main->list[cnt].employer_zipcode = oa.zipcode
 
	; encounter
	main->list[cnt].encntr_id = e.encntr_id
	main->list[cnt].accident_related_ind = evaluate2(if (eacc.encntr_accident_id > 0.0) "Yes" else "No" endif)
	main->list[cnt].accident_text = uar_get_code_display(eacc.accident_cd)
	main->list[cnt].reason_for_visit = e.reason_for_visit
	main->list[cnt].visit_type = uar_get_code_display(e.encntr_type_cd)
 
	; facility/surgery
	main->list[cnt].facility = uar_get_code_display(l.location_cd)
	main->list[cnt].facility_name = lo.org_name
	main->list[cnt].federal_tax_id_nbr = lo.federal_tax_id_nbr
	main->list[cnt].facility_street_addr = loa.street_addr
	main->list[cnt].facility_city = loa.city
	main->list[cnt].facility_state = uar_get_code_display(loa.state_cd)
	main->list[cnt].facility_zipcode = loa.zipcode
	main->list[cnt].patient_account_nbr = eaf.alias
	main->list[cnt].patient_mrn = build(
		main->list[cnt].facility
		, substring(textlen(trim(eam.alias, 3)) + 1, 10, build("0000000000", eam.alias))
	)
	main->list[cnt].primary_surgeon = scper.name_full_formatted
	main->list[cnt].post_op_diag = substring(1, 100, lt1.long_text)
	main->list[cnt].admit_dt_tm = format(e.reg_dt_tm, "mm/dd/yy hh:mm:ss")
	main->list[cnt].disch_dt_tm = format(e.disch_dt_tm, "mm/dd/yy hh:mm:ss")
	main->list[cnt].or_suite = uar_get_code_display(sc.sched_op_loc_cd)
 
	; anesthesia
	main->list[cnt].sa_anesthesia_record_id = sar.sa_anesthesia_record_id
	main->list[cnt].primary_proc = build2(
		trim(uar_get_code_display(scp.surg_proc_cd), 3)
		, evaluate2(if (trim(scp.modifier, 3) != "") build2(" (", trim(scp.modifier, 3), ")") endif)
	)
	main->list[cnt].proc_text = substring(1, 100, scp.proc_text)
	main->list[cnt].anesthesia_type = uar_get_code_display(scp.sched_anesth_type_cd)
	main->list[cnt].anes_prov_start_dt_tmt = ""
	main->list[cnt].anes_prov_stop_dt_tm = ""
	main->list[cnt].anes_prov_total = "0"
	main->list[cnt].units = "0.0"
	main->list[cnt].asa_class = uar_get_code_display(sc.asa_class_cd)
 
foot report
	main->main_cnt = cnt
 
	call alterlist(main->list, cnt)
 
with time = 30, nocounter
 
 
/**************************************************************/
; select insured data
select into "NL:"
from
	; insured
	ENCNTR_PLAN_RELTN epr
 
	, (inner join HEALTH_PLAN eprhp on eprhp.health_plan_id = epr.health_plan_id)
 
	, (inner join ORGANIZATION epro on epro.organization_id = epr.organization_id)
 
	, (inner join ADDRESS eproa on eproa.parent_entity_id = epro.organization_id
		and	eproa.parent_entity_name = "ORGANIZATION"
		and eproa.address_type_cd = business_address_var
		and eproa.beg_effective_dt_tm = (
			select max(a.beg_effective_dt_tm)
			from ADDRESS a
			where
				a.parent_entity_id = eproa.parent_entity_id
				and a.parent_entity_name = eproa.parent_entity_name
				and a.end_effective_dt_tm > sysdate)
		and eproa.end_effective_dt_tm > sysdate)
 
 	; insured subscriber
	, (inner join PERSON_PLAN_RELTN ppr on ppr.person_plan_reltn_id = epr.person_plan_reltn_id
		and ppr.active_ind = 1)
 
	, (inner join PERSON_PERSON_RELTN ppr2 on ppr2.related_person_id = ppr.subscriber_person_id
		and ppr2.active_ind = 1)
 
	, (inner join PERSON pprp on pprp.person_id = ppr2.person_id)
 
	, (left join PERSON_ALIAS pprppa on pprppa.person_id = pprp.person_id
		and pprppa.person_alias_type_cd = ssn_var)
 
	, (left join ADDRESS pprpa on pprpa.parent_entity_id = pprp.person_id
		and	pprpa.parent_entity_name = "PERSON"
		and pprpa.address_type_cd = home_address_var)
 
	, (left join PHONE pprpph on pprpph.parent_entity_id = pprp.person_id
		and	pprpph.parent_entity_name = "PERSON"
		and pprpph.phone_type_cd = home_phone_var)
 
 	; insured employer
	, (left join PERSON_ORG_RELTN pprppor on pprppor.person_id = pprp.person_id
		and pprppor.person_org_reltn_cd = employer_var)
 
	, (left join ORGANIZATION pprpo on pprpo.organization_id = pprppor.organization_id)
 
where expand(num, 1, size(main->list, 5), epr.encntr_id, main->list[num].encntr_id)
	and epr.end_effective_dt_tm > sysdate
	and epr.priority_seq = 1
	and epr.active_ind = 1
 
 
; populate main record structure with insured data
head epr.encntr_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(main->list, 5), epr.encntr_id, main->list[numx].encntr_id)
 
	if (idx > 0)
		main->list[idx].relation_to_insured = uar_get_code_display(ppr2.related_person_reltn_cd)
		main->list[idx].insured_name = pprp.name_full_formatted
		main->list[idx].insured_ssn = pprppa.alias
		main->list[idx].insured_street_addr = pprpa.street_addr
		main->list[idx].insured_city = pprpa.city
		main->list[idx].insured_state = uar_get_code_display(pprpa.state_cd)
		main->list[idx].insured_zipcode = pprpa.zipcode
		main->list[idx].insured_phone_num = pprpph.phone_num
		main->list[idx].insured_dob = format(pprp.birth_dt_tm, "mm/dd/yy")
		main->list[idx].insured_gender = uar_get_code_display(pprp.sex_cd)
		main->list[idx].subscriber_policy_nbr = epr.subs_member_nbr
		main->list[idx].member_policy_nbr = epr.member_nbr
		main->list[idx].insured_group_nbr = epr.group_nbr
		main->list[idx].insured_plan_name = eprhp.plan_name
		main->list[idx].insured_employer = pprpo.org_name
		main->list[idx].ins_prov_name = epro.org_name
		main->list[idx].ins_prov_street_addr = build2(
			trim(eproa.street_addr, 3), ", "
			, evaluate2(if (eproa.street_addr2 != "") build2(trim(eproa.street_addr2, 3), " ") else "" endif)
			, evaluate2(if (eproa.street_addr3 != "") build2(trim(eproa.street_addr3, 3), " ") else "" endif)
		)
		main->list[idx].ins_prov_city = eproa.city
		main->list[idx].ins_prov_state = uar_get_code_display(eproa.state_cd)
		main->list[idx].ins_prov_zipcode = eproa.zipcode
	endif
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select other insured data
select into "NL:"
from
	; other insured
	ENCNTR_PLAN_RELTN epr
 
	, (inner join HEALTH_PLAN eprhp on eprhp.health_plan_id = epr.health_plan_id)
 
	, (inner join ORGANIZATION epro on epro.organization_id = epr.organization_id)
 
	, (inner join ADDRESS eproa on eproa.parent_entity_id = epro.organization_id
		and	eproa.parent_entity_name = "ORGANIZATION"
		and eproa.address_type_cd = business_address_var
		and eproa.beg_effective_dt_tm = (
			select max(a.beg_effective_dt_tm)
			from ADDRESS a
			where
				a.parent_entity_id = eproa.parent_entity_id
				and a.parent_entity_name = eproa.parent_entity_name
				and a.end_effective_dt_tm > sysdate)
		and eproa.end_effective_dt_tm > sysdate)
 
 	; other insured subscriber
	, (inner join PERSON_PLAN_RELTN ppr on ppr.person_plan_reltn_id = epr.person_plan_reltn_id
		and ppr.active_ind = 1)
 
	, (inner join PERSON_PERSON_RELTN ppr2 on ppr2.related_person_id = ppr.subscriber_person_id
		and ppr2.active_ind = 1)
 
	, (inner join PERSON pprp on pprp.person_id = ppr2.person_id)
 
	, (left join PERSON_ALIAS pprppa on pprppa.person_id = pprp.person_id
		and pprppa.person_alias_type_cd = ssn_var)
 
	, (left join ADDRESS pprpa on pprpa.parent_entity_id = pprp.person_id
		and	pprpa.parent_entity_name = "PERSON"
		and pprpa.address_type_cd = home_address_var)
 
	, (left join PHONE pprpph on pprpph.parent_entity_id = pprp.person_id
		and	pprpph.parent_entity_name = "PERSON"
		and pprpph.phone_type_cd = home_phone_var)
 
 	; other insured employer
	, (left join PERSON_ORG_RELTN pprppor on pprppor.person_id = pprp.person_id
		and pprppor.person_org_reltn_cd = employer_var)
 
	, (left join ORGANIZATION pprpo on pprpo.organization_id = pprppor.organization_id)
 
where expand(num, 1, size(main->list, 5), epr.encntr_id, main->list[num].encntr_id)
	and epr.end_effective_dt_tm > sysdate
	and epr.priority_seq = 2
	and epr.active_ind = 1
 
 
; populate main record structure with other insured data
head epr.encntr_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(main->list, 5), epr.encntr_id, main->list[numx].encntr_id)
 
	if (idx > 0)
		main->list[idx].other_insured_name = pprp.name_full_formatted
		main->list[idx].other_insured_ssn = pprppa.alias
		main->list[idx].other_insured_street_addr = pprpa.street_addr
		main->list[idx].other_insured_city = pprpa.city
		main->list[idx].other_insured_state = uar_get_code_display(pprpa.state_cd)
		main->list[idx].other_insured_zipcode = pprpa.zipcode
		main->list[idx].other_insured_phone_num = pprpph.phone_num
		main->list[idx].other_insured_dob = format(pprp.birth_dt_tm, "mm/dd/yy")
		main->list[idx].other_insured_gender = uar_get_code_display(pprp.sex_cd)
		main->list[idx].other_subscriber_policy_nbr = epr.subs_member_nbr
		main->list[idx].other_member_policy_nbr = epr.member_nbr
		main->list[idx].other_insured_group_nbr = eprhp.group_nbr
		main->list[idx].other_insured_plan_name = eprhp.plan_name
		main->list[idx].other_insured_employer = pprpo.org_name
		main->list[idx].other_ins_prov_name = epro.org_name
		main->list[idx].other_ins_prov_street_addr = build2(
			trim(eproa.street_addr, 3), ", "
			, evaluate2(if (eproa.street_addr2 != "") build2(trim(eproa.street_addr2, 3), " ") else "" endif)
			, evaluate2(if (eproa.street_addr3 != "") build2(trim(eproa.street_addr3, 3), " ") else "" endif)
		)
		main->list[idx].other_ins_prov_city = eproa.city
		main->list[idx].other_ins_prov_state = uar_get_code_display(eproa.state_cd)
		main->list[idx].other_ins_prov_zipcode = eproa.zipcode
	endif
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select guarantor data
select into "NL:"
from
	; guarantor
	ENCNTR_PERSON_RELTN epr
 
	, (left join PERSON eprp on eprp.person_id = epr.related_person_id)
 
	, (left join PERSON_ALIAS eprppa on eprppa.person_id = eprp.person_id
		and eprppa.person_alias_type_cd = ssn_var)
 
	, (left join ADDRESS eprpa on eprpa.parent_entity_id = eprp.person_id
		and	eprpa.parent_entity_name = "PERSON"
		and eprpa.address_type_cd = home_address_var)
 
	, (left join PHONE eprpph on eprpph.parent_entity_id = eprp.person_id
		and	eprpph.parent_entity_name = "PERSON"
		and eprpph.phone_type_cd = home_phone_var)
 
 	; guarantor employer
	, (left join PERSON_ORG_RELTN eprppor on eprppor.person_id = eprp.person_id
		and eprppor.person_org_reltn_cd = employer_var)
 
	, (left join ORGANIZATION eprpo on eprpo.organization_id = eprppor.organization_id)
 
	, (left join ADDRESS eprpoa on eprpoa.parent_entity_id = eprpo.organization_id
		and	eprpoa.parent_entity_name = "ORGANIZATION"
		and eprpoa.address_type_cd = business_address_var)
 
where expand(num, 1, size(main->list, 5), epr.encntr_id, main->list[num].encntr_id)
	and epr.person_reltn_type_cd = guarantor_var
	and epr.active_ind = 1
 
 
; populate main record structure with guarantor data
head epr.encntr_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(main->list, 5), epr.encntr_id, main->list[numx].encntr_id)
 
	if (idx > 0)
		main->list[idx].guarantor_name = eprp.name_full_formatted
		main->list[idx].guarantor_ssn = eprppa.alias
		main->list[idx].guarantor_street_addr = eprpa.street_addr
		main->list[idx].guarantor_city = eprpa.city
		main->list[idx].guarantor_state = uar_get_code_display(eprpa.state_cd)
		main->list[idx].guarantor_zipcode = eprpa.zipcode
		main->list[idx].guarantor_phone_num = eprpph.phone_num
		main->list[idx].guarantor_dob = format(eprp.birth_dt_tm, "mm/dd/yy")
		main->list[idx].guarantor_gender = uar_get_code_display(eprp.sex_cd)
		main->list[idx].guarantor_marital_status = uar_get_code_display(eprp.marital_type_cd)
		main->list[idx].guarantor_employer = eprpo.org_name
		main->list[idx].guarantor_employer_street_addr = eprpoa.street_addr
		main->list[idx].guarantor_employer_city = eprpoa.city
		main->list[idx].guarantor_employer_state = uar_get_code_display(eprpoa.state_cd)
		main->list[idx].guarantor_employer_zipcode = eprpoa.zipcode
	endif
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select diagnosis data
select into "NL:"
from
	DIAGNOSIS d
 
	, (inner join NOMENCLATURE n on n.nomenclature_id = d.nomenclature_id
		and n.source_vocabulary_cd = icd_var
		and n.active_ind = 1)
 
where expand(num, 1, size(main->list, 5), d.encntr_id, main->list[num].encntr_id)
	and d.active_ind = 1
 
order by
	d.encntr_id
	, d.clinical_diag_priority
 
 
; populate main record structure with diagnosis data
head d.encntr_id
	numx = 0
	idx = 0
	cnt = 0
	cnt_limit = 3 ; limit list
 
	idx = locateval(numx, 1, size(main->list, 5), d.encntr_id, main->list[numx].encntr_id)
 
	if (idx > 0)
		call alterlist(main->list[idx].diagnosis, 10)
	endif
 
detail
	if (idx > 0 and cnt < cnt_limit)
		cnt = cnt + 1
 
		if (mod(cnt, 10) = 1 and cnt > 10)
			call alterlist(main->list[idx].diagnosis, cnt + 9)
		endif
 
		main->list[idx].diagnosis[cnt].diagnosis_id = d.diagnosis_id
		main->list[idx].diagnosis[cnt].diagnosis_display = trim(n.source_string, 3)
	endif
 
foot d.encntr_id
	main->list[idx].diag_cnt = cnt
 
	call alterlist(main->list[idx].diagnosis, cnt)
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select action data
select into "NL:"
from
	SA_ACTION sa
 
	, (inner join SA_REF_ACTION sra on sra.sa_ref_action_id = sa.sa_ref_action_id
		and sra.active_ind = 1)
 
where expand(num, 1, size(main->list, 5), sa.sa_anesthesia_record_id, main->list[num].sa_anesthesia_record_id)
	and sa.active_ind = 1
 
order by
	sa.sa_anesthesia_record_id
	, sa.sa_action_id
 
 
; populate main record structure with action data
head sa.sa_anesthesia_record_id
	numx = 0
	idx = 0
	cnt = 0
 
	idx = locateval(numx, 1, size(main->list, 5), sa.sa_anesthesia_record_id, main->list[numx].sa_anesthesia_record_id)
 
	if (idx > 0)
		call alterlist(main->list[idx].action, 10)
	endif
 
detail
	if (idx > 0)
		cnt = cnt + 1
 
		if (mod(cnt, 10) = 1 and cnt > 10)
			call alterlist(main->list[idx].action, cnt + 9)
		endif
 
		main->list[idx].action[cnt].sa_action_id = sa.sa_action_id
		main->list[idx].action[cnt].action_dt_tm = format(sa.action_dt_tm, "mm/dd/yy hh:mm:ss")
		main->list[idx].action[cnt].action_name = sra.action_name
	endif
 
foot sa.sa_anesthesia_record_id
	main->list[idx].action_cnt = cnt
 
	call alterlist(main->list[idx].action, cnt)
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select action group data
select distinct into "NL:"
from
	SA_ACTION sa
 
	, (inner join SA_REF_ACTION sra on sra.sa_ref_action_id = sa.sa_ref_action_id
		and sra.active_ind = 1)
 
	, (inner join SA_REF_ACTION_GROUP_R srag on srag.sa_ref_action_id = sra.sa_ref_action_id
		and srag.active_ind = 1)
 
	, (inner join SA_REF_GROUP srg on srg.sa_ref_group_id = srag.sa_ref_group_id
		and srg.active_ind = 1)
 
	, (inner join SA_REF_GROUP_ACTION_ITEM_R srgai on srgai.sa_ref_group_id = srg.sa_ref_group_id
		and srgai.active_ind = 1)
 
	, (inner join SA_REF_ACTION_ITEM srai on srai.sa_ref_action_item_id = srgai.sa_ref_action_item_id
		and srai.active_ind = 1)
 
	, (inner join SA_ACTION_ITEM sai on sai.sa_ref_action_item_id = srai.sa_ref_action_item_id
		and sai.sa_action_id = sa.sa_action_id
		and sai.active_ind = 1)
 
where expand(num, 1, size(main->list, 5), sa.sa_anesthesia_record_id, main->list[num].sa_anesthesia_record_id)
	and sa.active_ind = 1
 
order by
	sa.sa_anesthesia_record_id
	, sa.sa_action_id
	, srag.sequence
 
 
; populate main record structure with action group data
head sa.sa_anesthesia_record_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(main->list, 5), sa.sa_anesthesia_record_id, main->list[numx].sa_anesthesia_record_id)
 
head sa.sa_action_id
	aidx = 0
	cnt = 0
 
	if (idx > 0)
		aidx = locateval(numx, 1, size(main->list[idx].action, 5), sa.sa_action_id, main->list[idx].action[numx].sa_action_id)
 
		if (aidx > 0)
			call alterlist(main->list[idx].action[aidx].group, 10)
		endif
	endif
 
detail
	if (aidx > 0)
		cnt = cnt + 1
 
		if (mod(cnt, 10) = 1 and cnt > 10)
			call alterlist(main->list[idx].action[aidx].group, cnt + 9)
		endif
 
		main->list[idx].action[aidx].group[cnt].sa_ref_group_id = srag.sa_ref_group_id
		main->list[idx].action[aidx].group[cnt].group_prompt = srg.group_prompt
	endif
 
foot sa.sa_action_id
	main->list[idx].action[aidx].group_cnt = cnt
 
	call alterlist(main->list[idx].action[aidx].group, cnt)
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select action group item data
select distinct into "NL:"
from
	SA_ACTION sa
 
	, (inner join SA_REF_ACTION sra on sra.sa_ref_action_id = sa.sa_ref_action_id
		and sra.active_ind = 1)
 
	, (inner join SA_REF_ACTION_GROUP_R srag on srag.sa_ref_action_id = sra.sa_ref_action_id
		and srag.active_ind = 1)
 
	, (inner join SA_REF_GROUP srg on srg.sa_ref_group_id = srag.sa_ref_group_id
		and srg.active_ind = 1)
 
	, (inner join SA_REF_GROUP_ACTION_ITEM_R srgai on srgai.sa_ref_group_id = srg.sa_ref_group_id
		and srgai.active_ind = 1)
 
	, (inner join SA_REF_ACTION_ITEM srai on srai.sa_ref_action_item_id = srgai.sa_ref_action_item_id
		and srai.active_ind = 1)
 
	, (inner join SA_ACTION_ITEM sai on sai.sa_ref_action_item_id = srai.sa_ref_action_item_id
		and sai.sa_action_id = sa.sa_action_id
		and sai.active_ind = 1)
 
where expand(num, 1, size(main->list, 5), sa.sa_anesthesia_record_id, main->list[num].sa_anesthesia_record_id)
	and sa.active_ind = 1
 
order by
	sa.sa_anesthesia_record_id
	, sa.sa_action_id
	, srag.sequence
	, srgai.sequence
 
 
; populate main record structure with action group item data
head sa.sa_anesthesia_record_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(main->list, 5), sa.sa_anesthesia_record_id, main->list[numx].sa_anesthesia_record_id)
 
head sa.sa_action_id
	aidx = 0
 
	if (idx > 0)
		aidx = locateval(numx, 1, size(main->list[idx].action, 5), sa.sa_action_id, main->list[idx].action[numx].sa_action_id)
	endif
 
head srag.sequence
	gidx = 0
	cnt = 0
 
	if (aidx > 0)
		gidx = locateval(numx, 1, size(main->list[idx].action[aidx].group, 5),
			srg.sa_ref_group_id, main->list[idx].action[aidx].group[numx].sa_ref_group_id)
 
		if (gidx > 0)
			call alterlist(main->list[idx].action[aidx].group[numx].item, 10)
		endif
	endif
 
detail
	if (gidx > 0)
		cnt = cnt + 1
 
		if (mod(cnt, 10) = 1 and cnt > 10)
			call alterlist(main->list[idx].action[aidx].group[gidx].item, cnt + 9)
		endif
 
		main->list[idx].action[aidx].group[gidx].item[cnt].action_item_description = srai.action_item_description
		main->list[idx].action[aidx].group[gidx].item[cnt].action_value = sai.action_value
	endif
 
foot srag.sequence
	main->list[idx].action[aidx].group[gidx].item_cnt = cnt
 
	call alterlist(main->list[idx].action[aidx].group[gidx].item, cnt)
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; select personnel data
select into "NL:"
from
	SA_PRSNL_ACTIVITY spa
 
	, (inner join SA_PRSNL_ACTIVITY_TIME spat on spat.sa_prsnl_activity_id = spa.sa_prsnl_activity_id
		and spat.active_ind = 1)
 
	, (inner join PRSNL per on per.person_id = spa.prsnl_id
		and per.active_ind = 1)
 
where expand(num, 1, size(main->list, 5), spa.sa_anesthesia_record_id, main->list[num].sa_anesthesia_record_id)
	and spa.active_ind = 1
 
order by
	spa.sa_anesthesia_record_id
	, per.name_full_formatted
 
 
; populate main record structure with personnel data
head spa.sa_anesthesia_record_id
	numx = 0
	idx = 0
	cnt = 0
 
	idx = locateval(numx, 1, size(main->list, 5), spa.sa_anesthesia_record_id, main->list[numx].sa_anesthesia_record_id)
 
	if (idx > 0)
		call alterlist(main->list[idx].personnel, 10)
	endif
 
detail
	if (idx > 0)
		cnt = cnt + 1
 
		if (mod(cnt, 10) = 1 and cnt > 10)
			call alterlist(main->list[idx].personnel, cnt + 9)
		endif
 
		main->list[idx].personnel[cnt].person_id = per.person_id
		main->list[idx].personnel[cnt].name_full_formatted = per.name_full_formatted
		main->list[idx].personnel[cnt].activity_type = uar_get_code_display(spa.prsnl_activity_type_cd)
		main->list[idx].personnel[cnt].start_time = format(min(spat.start_dt_tm), "mm/dd/yy hh:mm:ss;;d")
		main->list[idx].personnel[cnt].stop_time = format(max(spat.end_dt_tm), "mm/dd/yy hh:mm:ss;;d")
		main->list[idx].personnel[cnt].duration = cnvtstring(sum(datetimediff(spat.end_dt_tm, spat.start_dt_tm, 4)))
	endif
 
foot spa.sa_anesthesia_record_id
	main->list[idx].per_cnt = cnt
 
	call alterlist(main->list[idx].personnel, cnt)
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; build output
if (main->main_cnt > 0)
	; select main record structure data
	select into value(output_var)
	from
		(DUMMYT dt with seq = main->main_cnt)
	order by
		dt.seq
 
	; build output
	head dt.seq
		; diagnosis
		output_diagnosis = ""
		num = main->list[dt.seq].diag_cnt
 
 		; add post-op diagnosis as first diagnosis in list
		output_diagnosis = wrap2(main->list[dt.seq].post_op_diag)
 
		; add remaining listed diagnoses
		for(i = 1 to num)
			output_diagnosis = build(
				output_diagnosis
				, wrap2(main->list[dt.seq].diagnosis[i].diagnosis_display)
			)
		endfor
 
		if (output_diagnosis = "")
			output_diagnosis = wrap2("")
		endif
 
		; action
		output_action = ""
		num = main->list[dt.seq].action_cnt
 
		for(i = 1 to num)
			output_action = build2(
				output_action
				, main->list[dt.seq].action[i].action_name, " "
				, main->list[dt.seq].action[i].action_dt_tm, " "
			)
 
			; action group
			output_group = ""
			num2 = main->list[dt.seq].action[i].group_cnt
 
			for(j = 1 to num2)
				output_group = build2(
					output_group
					, main->list[dt.seq].action[i].group[j].group_prompt, ": "
				)
 
				; action group item
				output_item = ""
				num3 = main->list[dt.seq].action[i].group[j].item_cnt
 
				for(k = 1 to num3)
					output_item = build2(
						output_item
						, main->list[dt.seq].action[i].group[j].item[k].action_item_description, " - "
						, main->list[dt.seq].action[i].group[j].item[k].action_value, ", "
					)
				endfor
 
				output_group = build2(output_group, output_item)
			endfor
 
			output_action = build2(output_action, output_group)
		endfor
 
		if (output_action = "")
			output_action = wrap2("")
		else
			output_action = wrap2(output_action)
		endif
 
		; personnel
		output_personnel = ""
		num = main->list[dt.seq].per_cnt
 
		for(i = 1 to num)
			output_personnel = build(
				output_personnel
				, wrap2(main->list[dt.seq].personnel[i].name_full_formatted)
				, wrap2(main->list[dt.seq].personnel[i].activity_type)
				, wrap2(main->list[dt.seq].personnel[i].start_time)
				, wrap2(main->list[dt.seq].personnel[i].stop_time)
				, wrap2(main->list[dt.seq].personnel[i].duration)
			)
		endfor
 
		if (output_personnel = "")
			output_personnel = build(
				wrap2("")
				, wrap2("")
				, wrap2("")
				, wrap2("")
				, wrap2("")
			)
		endif
 
		; main
		output_main = ""
		output_main = build(
			; surgical case
			wrap2(main->list[dt.seq].surg_case_nbr)
 
	 		; patient
			, wrap2(main->list[dt.seq].patient_name)
			, wrap2(main->list[dt.seq].patient_ssn)
			, wrap2(main->list[dt.seq].patient_street_addr)
			, wrap2(main->list[dt.seq].patient_city)
			, wrap2(main->list[dt.seq].patient_state)
			, wrap2(main->list[dt.seq].patient_zipcode)
			, wrap2(main->list[dt.seq].patient_phone_num)
			, wrap2(main->list[dt.seq].patient_dob)
			, wrap2(main->list[dt.seq].patient_age)
			, wrap2(main->list[dt.seq].patient_gender)
			, wrap2(main->list[dt.seq].patient_marital_status)
 
		 	; patient employer
			, wrap2(main->list[dt.seq].employer)
			, wrap2(main->list[dt.seq].employer_street_addr)
			, wrap2(main->list[dt.seq].employer_city)
			, wrap2(main->list[dt.seq].employer_state)
			, wrap2(main->list[dt.seq].employer_zipcode)
 
			; encounter
			, wrap2(main->list[dt.seq].accident_related_ind)
			, wrap2(main->list[dt.seq].accident_text)
			, wrap2(main->list[dt.seq].reason_for_visit)
			, wrap2(main->list[dt.seq].visit_type)
 
			; diagnosis
			, trim(output_diagnosis, 3)
 
			; insured
			, wrap2(main->list[dt.seq].relation_to_insured)
			, wrap2(main->list[dt.seq].insured_name)
			, wrap2(main->list[dt.seq].insured_ssn)
			, wrap2(main->list[dt.seq].insured_street_addr)
			, wrap2(main->list[dt.seq].insured_city)
			, wrap2(main->list[dt.seq].insured_state)
			, wrap2(main->list[dt.seq].insured_zipcode)
			, wrap2(main->list[dt.seq].insured_phone_num)
			, wrap2(main->list[dt.seq].insured_dob)
			, wrap2(main->list[dt.seq].insured_gender)
			, wrap2(main->list[dt.seq].subscriber_policy_nbr)
			, wrap2(main->list[dt.seq].member_policy_nbr)
			, wrap2(main->list[dt.seq].insured_group_nbr)
			, wrap2(main->list[dt.seq].insured_plan_name)
			, wrap2(main->list[dt.seq].insured_employer)
			, wrap2(main->list[dt.seq].ins_prov_name)
			, wrap2(main->list[dt.seq].ins_prov_street_addr)
			, wrap2(main->list[dt.seq].ins_prov_city)
			, wrap2(main->list[dt.seq].ins_prov_state)
			, wrap2(main->list[dt.seq].ins_prov_zipcode)
 
			; other insured
			, wrap2(main->list[dt.seq].other_insured_name)
			, wrap2(main->list[dt.seq].other_insured_ssn)
			, wrap2(main->list[dt.seq].other_insured_street_addr)
			, wrap2(main->list[dt.seq].other_insured_city)
			, wrap2(main->list[dt.seq].other_insured_state)
			, wrap2(main->list[dt.seq].other_insured_zipcode)
			, wrap2(main->list[dt.seq].other_insured_phone_num)
			, wrap2(main->list[dt.seq].other_insured_dob)
			, wrap2(main->list[dt.seq].other_insured_gender)
			, wrap2(main->list[dt.seq].other_subscriber_policy_nbr)
			, wrap2(main->list[dt.seq].other_member_policy_nbr)
			, wrap2(main->list[dt.seq].other_insured_group_nbr)
			, wrap2(main->list[dt.seq].other_insured_plan_name)
			, wrap2(main->list[dt.seq].other_insured_employer)
			, wrap2(main->list[dt.seq].other_ins_prov_name)
			, wrap2(main->list[dt.seq].other_ins_prov_street_addr)
			, wrap2(main->list[dt.seq].other_ins_prov_city)
			, wrap2(main->list[dt.seq].other_ins_prov_state)
			, wrap2(main->list[dt.seq].other_ins_prov_zipcode)
 
			; guarantor
			, wrap2(main->list[dt.seq].guarantor_name)
			, wrap2(main->list[dt.seq].guarantor_ssn)
			, wrap2(main->list[dt.seq].guarantor_street_addr)
			, wrap2(main->list[dt.seq].guarantor_city)
			, wrap2(main->list[dt.seq].guarantor_state)
			, wrap2(main->list[dt.seq].guarantor_zipcode)
			, wrap2(main->list[dt.seq].guarantor_phone_num)
			, wrap2(main->list[dt.seq].guarantor_dob)
			, wrap2(main->list[dt.seq].guarantor_gender)
			, wrap2(main->list[dt.seq].guarantor_marital_status)
			, wrap2(main->list[dt.seq].guarantor_employer)
			, wrap2(main->list[dt.seq].guarantor_employer_street_addr)
			, wrap2(main->list[dt.seq].guarantor_employer_city)
			, wrap2(main->list[dt.seq].guarantor_employer_state)
			, wrap2(main->list[dt.seq].guarantor_employer_zipcode)
 
			; facility/surgery
			, wrap2(main->list[dt.seq].facility)
			, wrap2(main->list[dt.seq].facility_name)
			, wrap2(main->list[dt.seq].federal_tax_id_nbr)
			, wrap2(main->list[dt.seq].facility_street_addr)
			, wrap2(main->list[dt.seq].facility_city)
			, wrap2(main->list[dt.seq].facility_state)
			, wrap2(main->list[dt.seq].facility_zipcode)
			, wrap2(main->list[dt.seq].patient_account_nbr)
			, wrap2(main->list[dt.seq].patient_mrn)
			, wrap2(main->list[dt.seq].primary_surgeon)
			, wrap2(main->list[dt.seq].post_op_diag)
			, wrap2(main->list[dt.seq].admit_dt_tm)
			, wrap2(main->list[dt.seq].disch_dt_tm)
			, wrap2(main->list[dt.seq].or_suite)
 
			; anesthesia
			, wrap2(main->list[dt.seq].primary_proc)
			, wrap2(main->list[dt.seq].proc_text)
			, wrap2(main->list[dt.seq].anesthesia_type)
			, wrap2(main->list[dt.seq].anes_prov_start_dt_tmt)
			, wrap2(main->list[dt.seq].anes_prov_stop_dt_tm)
			, wrap2(main->list[dt.seq].anes_prov_total)
			, wrap2(main->list[dt.seq].units)
			, wrap2(main->list[dt.seq].asa_class)
 
			; action
			, trim(output_action, 3)
 
			; personnel
			, trim(output_personnel, 3)
		)
 
		output_main = replace(output_main, ",", "", 2)
 
	foot dt.seq
		col 0 output_main
		row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
endif
 
 
call echo(build2("filepath_var = ", filepath_var))
call echorecord(main)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end
go
 
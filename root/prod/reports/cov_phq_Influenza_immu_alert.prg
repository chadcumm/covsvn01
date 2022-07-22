 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		Sep'2018
	Solution:			population Health Quality
	Source file name:  	cov_phq_Influenza_immu_alert.prg
	Object name:		cov_phq_Influenza_immu_alert
	Request#:			1210
 
	Program purpose:	      Influenza Immunization details and alert information.
	Executing from:		CCL/DA2/Quality folder
  	Special Notes:          Excel file.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer	     Comment
----------	-----------	------------------------------------------
09-28-19  	Geetha 	CR# 6298  - Add option to filterout non-discharged(active) patients.
09-15-20    Geetha      CR# 8565  - Add Room column, sort by dept. & Copy the report to case managemant folder
09-29-20    Geetha      CR# 8642  - SBU locations added to the prompt
10-04-21    Geetha      CR# 11299 - Add VIS information
10-25-21    Geetha      CR# 11470 - Attestation section should be pointing to Nurse who complete the discharge instruction.
******************************************************************************/
 
drop program cov_phq_Influenza_immu_alert:DBA go
create program cov_phq_Influenza_immu_alert:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE"
	, "Patient Status" = 1
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, patient_status, facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare initcap() = c100
declare adult_pat_his_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Adult Patient History Form')),protect
declare vacin_indicate_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Influenza Vaccine Indicated')),protect
declare vacin_not_indicate_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Influenza Vaccine Not Indicated')),protect
declare vacin_status_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Influenza Vaccine Status')),protect
declare vacin_admin_INF_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'INF Admin Influenza Vaccine')),protect
 
declare vacin_admin_inact_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'influenza virus vaccine, inactivated')),protect
declare not_given_resnVC_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reg PN Influenza Not Given Reason vC')),protect
declare not_given_resn_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Influenza Vacc Not Given Reason')),protect
declare not_given_resnVE_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reg PN Influenza Not Given Reason vE')),protect
declare not_given_resn52_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'QM Rea Influenza Vaccine NtGvn v5.2')),protect
declare not_given_resn42_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'QM Reason Influenza Vaccine NtGvn v4.2')),protect
declare not_given_resn54_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'QM Rea Influenza Vaccine NtGvn v5.4')),protect
declare not_given_resnVD_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reg PN Influenza Not Given Reason vD')),protect
declare not_given_resn50_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'QM Rea Influenza Vaccine NtGvn v5.0')),protect
 
declare Influenza_given_var      = f8 with constant(2658579259.00), protect ;Influenza Vaccine Given
declare Influenza_var            = f8 with constant(uar_get_code_by("DISPLAY", 200, 'influenza virus vaccine, inactivated')), protect
declare discharge_instru_var     = f8 with constant(uar_get_code_by("DISPLAY", 72 , 'Discharge Instructions')), protect
declare disch_summary_var        = f8 with constant(2820588.00), protect ;pulling MD name
declare Nurs_disch_sum_var       = f8 with constant(2700609.00), protect
declare OB_disch_summary_var     = f8 with constant(2565158339.00), protect
declare WH_disch_summary_var     = f8 with constant(2587455053.00), protect
declare BH_disch_summary_var     = f8 with constant(2563735465.00), protect
declare ED_disch_summary_var     = f8 with constant(37180437.00), protect
 
declare cnt = i4 with noconstant(0)
declare start_date = f8
set start_date = cnvtlookbehind("2,D")
set start_date = datetimefind(start_date,"D","B","B")
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record flu(
	1 reccnt = i4
	1 plist[*]
		2 cnt = i4
		2 facility = f8
		2 personid = f8
		2 encntrid = f8
		2 fin = vc
		2 mrn = vc
		2 pat_name = vc
		2 age = vc
		2 gender = vc
		2 patient_type = vc
		2 arrive_dt = dq8 ;vc
		2 admit_dt = dq8 ;vc
		2 cur_room = vc
		2 cur_nurse_unit = vc
		2 disch_dt = vc
		2 dsch_attest = vc
		2 disch_nurse = vc
		2 disch_other = vc
		2 dish_room = vc
		2 dish_nurse_unit = vc
		2 pat_status_flag = vc
		2 vacin_order_id = f8
		2 verified_pr_id = f8
		2 verify_dt = dq8
		2 patient_history = vc
		2 influ_vacin_assemnt = vc
		2 influ_vacin_status = vc
		2 vacin_contra_refuse = vc
		2 vacin_pat_family_refuse = vc
		2 vacin_indicated = vc
		2 vacin_not_indicated = vc
		2 refused_mar = vc
		2 vacin_order_dt = vc
		2 vacin_admin_dt = vc
		2 vacin_admin_doc = vc
		2 open_chart_alert = vc ;yes or no
		2 open_chart_alert_dt = vc
		2 disch_page_rule = vc ;yes or no
		2 disch_page_rule_dt = vc
		2 vis_published = vc
		2 vis_given = vc
	)
 
 Record pager(
	1 mlis[*]
		2 module_name = vc
		2 log = vc
		2 begin_dt = dq8
		2 module_id = f8
)
 
;---------------------------------------------------------------------------------------
;Discharge Summary Pager Alert details
select into 'NL:'
 
ema.module_name, mad.logging, mad.updt_dt_tm, ema.begin_dt_tm, mad.module_audit_id, ema.rec_id
from eks_module_audit_det mad, eks_module_audit ema
	where mad.module_audit_id = ema.rec_id
	and CNVTUPPER(ema.module_name) = 'COV_CE_INFLUENZA_DC_ORDER'
	and mad.logging = '*DC without Influenza*'
	and ema.begin_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
order by ema.module_name, mad.module_audit_id
 
Head report
 	mcnt = 0
	call alterlist(pager->mlis, 100)
 
Head mad.module_audit_id
 	mcnt = mcnt + 1
	call alterlist(pager->mlis, mcnt)
 	pager->mlis[mcnt].module_name = ema.module_name
 	pager->mlis[mcnt].log = mad.logging
 	pager->mlis[mcnt].begin_dt = ema.begin_dt_tm
 	pager->mlis[mcnt].module_id = mad.module_audit_id
 
Foot Report
	call alterlist(pager->mlis, mcnt)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------
;Qualification - Discharged Patients Population
select into 'nl:'
 
e.loc_facility_cd, e.person_id, e.encntr_id
, pat_type = uar_get_code_display(e.encntr_type_cd)
, arriv_dt = format(e.arrive_dt_tm, "mm/dd/yyyy hh:mm;;d")
, adm_dt = if(e.reg_dt_tm is not null) e.reg_dt_tm else e.arrive_dt_tm endif
, dis_dt = format(e.disch_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_cd, ce.order_id
, event = uar_get_code_display(ce.event_cd)
, tag = ce.event_tag
, ce.result_val
, verified_dt = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
, verified_prsnl = initcap(pr.name_full_formatted)
 
from
 
 encounter e
,(left join clinical_event ce on ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.event_cd in (adult_pat_his_var, vacin_indicate_var, vacin_status_var, not_given_resnVC_var, vacin_not_indicate_var
		, not_given_resn_var, not_given_resnVE_var, not_given_resn52_var, not_given_resn42_var, not_given_resn54_var
		, not_given_resnVD_var, not_given_resn50_var, vacin_admin_INF_var, vacin_admin_inact_var, Influenza_given_var
		, Nurs_disch_sum_var, OB_disch_summary_var, WH_disch_summary_var, BH_disch_summary_var, ED_disch_summary_var
		, disch_summary_var, discharge_instru_var)
	and ce.event_id =
		(select max(ce1.event_id)
		 	from clinical_event ce1
 		 	where ce1.encntr_id = e.encntr_id and ce1.event_cd = ce.event_cd
 		 	and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 		 	group by ce1.encntr_id, ce1.event_cd)
 )
 
,(left join prsnl pr on pr.person_id = ce.verified_prsnl_id)
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.disch_dt_tm is not null
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.encntr_id != 0.0
 
join ce
join pr
 
order by e.loc_facility_cd, e.encntr_id, ce.event_cd
 
Head report
 	cnt = 0
	call alterlist(flu->plist, 100)
Head e.encntr_id
 	cnt = cnt + 1
 	flu->reccnt = cnt
	call alterlist(flu->plist, cnt)
Detail
 	flu->plist[cnt].facility = e.loc_facility_cd
 	flu->plist[cnt].personid = e.person_id
 	flu->plist[cnt].encntrid = e.encntr_id
	flu->plist[cnt].patient_type = pat_type
	flu->plist[cnt].arrive_dt = e.arrive_dt_tm
	flu->plist[cnt].admit_dt = adm_dt
	flu->plist[cnt].disch_dt = dis_dt
	flu->plist[cnt].pat_status_flag = 'D'
	flu->plist[cnt].open_chart_alert = 'No'
	flu->plist[cnt].disch_page_rule = 'No'
 
 	case (ce.event_cd)
		of vacin_status_var:
	 		flu->plist[cnt].influ_vacin_assemnt = 'Yes'
	 		flu->plist[cnt].influ_vacin_status  = ce.result_val
		of not_given_resnVC_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resnVE_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn52_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn42_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn54_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resnVD_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn50_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of vacin_indicate_var:
			flu->plist[cnt].vacin_indicated = if(ce.result_val = 'Vaccine Indicated') 'Yes' endif
		of vacin_not_indicate_var:
			flu->plist[cnt].vacin_not_indicated = if(ce.result_val = 'Vaccine Not Indicated') 'No' endif
		of vacin_admin_INF_var:
			flu->plist[cnt].vacin_order_id = ce.order_id
			flu->plist[cnt].vacin_admin_dt = verified_dt
			;flu->plist[cnt].verify_dt = ce.verified_dt_tm
		of vacin_admin_inact_var:
			flu->plist[cnt].vacin_order_id = ce.order_id
			flu->plist[cnt].vacin_admin_dt = verified_dt
			flu->plist[cnt].vacin_pat_family_refuse = ce.event_tag
 		of Influenza_given_var:
 			flu->plist[cnt].vacin_admin_doc = 'Yes'
 		of discharge_instru_var:
			flu->plist[cnt].dsch_attest = 'Yes'
			flu->plist[cnt].disch_nurse = verified_prsnl
		of disch_summary_var:
			flu->plist[cnt].disch_other = verified_prsnl
		/*of Nurs_disch_sum_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of OB_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of WH_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of BH_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of ED_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl*/
 	endcase
 
Foot e.encntr_id
 
	if(flu->plist[cnt].vacin_indicated = ' ')
		if(flu->plist[cnt].vacin_not_indicated = 'No')
			flu->plist[cnt].vacin_indicated = 'No'
		endif
	endif
 	if(flu->plist[cnt].vacin_indicated = 'Yes')
 		if(flu->plist[cnt].vacin_not_indicated = 'No')
 			flu->plist[cnt].refused_mar = 'Yes' ;vacin indicated & ordered but refused after.
 		endif
 	endif
 	if(flu->plist[cnt].influ_vacin_assemnt = ' ')
 		flu->plist[cnt].influ_vacin_assemnt = 'No'
 	endif
 	;if(flu->plist[cnt].disch_nurse = ' ')
 	;	flu->plist[cnt].disch_nurse = flu->plist[cnt].disch_other
 	;endif
 
with nocounter


;---------------------------------------------------------------------------------------------
;Discharged Nurse unit and Room
select into $outdev
 
encntrid = flu->plist[d1.seq].encntrid
,admin_dt = flu->plist[d1.seq].verify_dt "@SHORTDATETIME"
,nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,beg = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME"
 
from (dummyt d1 WITH seq = value(size(flu->plist,5)))
	, encntr_loc_hist elh
 
plan d1 where flu->plist[d1.seq].pat_status_flag = 'D'
 
join elh where elh.encntr_id = flu->plist[d1.seq].encntrid
	and elh.active_ind = 1
	and elh.beg_effective_dt_tm = (select max(elh1.beg_effective_dt_tm)
			from encntr_loc_hist elh1 where elh1.encntr_id = elh.encntr_id
			and elh.active_ind = 1
			group by elh1.encntr_id)
 
order by elh.encntr_id
 
Head elh.encntr_id
 	num = 0
 	idx = 0
	idx = locateval(num, 1, size(flu->plist, 5), elh.encntr_id, flu->plist[num].encntrid)
Detail
    if(idx > 0)
	flu->plist[num].dish_nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 	flu->plist[num].dish_room = uar_get_code_display(elh.loc_room_cd)
    endif
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Qualification - Active Patients Population (append to the discharged patients)
select into 'nl:'
 
e.loc_facility_cd, e.person_id, e.encntr_id
, pat_type = uar_get_code_display(e.encntr_type_cd)
, arriv_dt = format(e.arrive_dt_tm, "mm/dd/yyyy hh:mm;;d")
, adm_dt = if(e.reg_dt_tm is not null) e.reg_dt_tm else e.arrive_dt_tm endif
, dis_dt = format(e.disch_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_cd, ce.order_id
, event = uar_get_code_display(ce.event_cd)
, tag = ce.event_tag
, ce.result_val
, verified_dt = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
, verified_prsnl = initcap(pr.name_full_formatted)
 
from
 encounter e
,(left join clinical_event ce on ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.event_cd in (adult_pat_his_var, vacin_indicate_var, vacin_status_var, not_given_resnVC_var, vacin_not_indicate_var
		, not_given_resn_var, not_given_resnVE_var, not_given_resn52_var, not_given_resn42_var, not_given_resn54_var
		, not_given_resnVD_var, not_given_resn50_var, vacin_admin_INF_var, vacin_admin_inact_var, Influenza_given_var
		, Nurs_disch_sum_var, OB_disch_summary_var, WH_disch_summary_var, BH_disch_summary_var, ED_disch_summary_var
		, disch_summary_var, discharge_instru_var)
	and ce.event_id =
		(select max(ce1.event_id)
		 	from clinical_event ce1
 		 	where ce1.encntr_id = e.encntr_id and ce1.event_cd = ce.event_cd
 		 	and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 		 	group by ce1.encntr_id, ce1.event_cd)
 )
 
,(left join prsnl pr on pr.person_id = ce.verified_prsnl_id)
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm is null
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.encntr_id != 0.0
 
join ce
join pr
 
order by e.loc_facility_cd, e.encntr_id, ce.event_cd
 
Head e.encntr_id
 	cnt += 1
 	flu->reccnt = cnt
	call alterlist(flu->plist, cnt)
Detail
 	flu->plist[cnt].facility = e.loc_facility_cd
 	flu->plist[cnt].personid = e.person_id
 	flu->plist[cnt].encntrid = e.encntr_id
	flu->plist[cnt].patient_type = pat_type
	flu->plist[cnt].arrive_dt = e.arrive_dt_tm
	flu->plist[cnt].admit_dt = adm_dt
	flu->plist[cnt].disch_dt = dis_dt
	flu->plist[cnt].pat_status_flag = 'A'
	flu->plist[cnt].open_chart_alert = 'No'
	flu->plist[cnt].disch_page_rule = 'No'
 
 	case (ce.event_cd)
		of vacin_status_var:
	 		flu->plist[cnt].influ_vacin_assemnt = 'Yes'
	 		flu->plist[cnt].influ_vacin_status  = ce.result_val
		of not_given_resnVC_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resnVE_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn52_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn42_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn54_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resnVD_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of not_given_resn50_var:
			flu->plist[cnt].vacin_contra_refuse = ce.result_val
		of vacin_indicate_var:
			flu->plist[cnt].vacin_indicated = if(ce.result_val = 'Vaccine Indicated') 'Yes' endif
		of vacin_not_indicate_var:
			flu->plist[cnt].vacin_not_indicated = if(ce.result_val = 'Vaccine Not Indicated') 'No' endif
		of vacin_admin_INF_var:
			flu->plist[cnt].vacin_order_id = ce.order_id
			flu->plist[cnt].vacin_admin_dt = verified_dt
			;flu->plist[cnt].verify_dt = ce.verified_dt_tm
		of vacin_admin_inact_var:
			flu->plist[cnt].vacin_order_id = ce.order_id
			flu->plist[cnt].vacin_admin_dt = verified_dt
			flu->plist[cnt].vacin_pat_family_refuse = ce.event_tag
 		of Influenza_given_var:
 			flu->plist[cnt].vacin_admin_doc = 'Yes'
 		of discharge_instru_var:
			flu->plist[cnt].dsch_attest = 'Yes'
			flu->plist[cnt].disch_nurse = verified_prsnl
		of disch_summary_var:
			flu->plist[cnt].disch_other = verified_prsnl
		/*of Nurs_disch_sum_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of OB_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of WH_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of BH_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl
		of ED_disch_summary_var:
			flu->plist[cnt].disch_nurse = verified_prsnl*/
 	endcase
 
Foot e.encntr_id
 
	if(flu->plist[cnt].vacin_indicated = ' ')
		if(flu->plist[cnt].vacin_not_indicated = 'No')
			flu->plist[cnt].vacin_indicated = 'No'
		endif
	endif
 	if(flu->plist[cnt].vacin_indicated = 'Yes')
 		if(flu->plist[cnt].vacin_not_indicated = 'No')
 			flu->plist[cnt].refused_mar = 'Yes' ;vacin indicated & ordered but refused after.
 		endif
 	endif
 	if(flu->plist[cnt].influ_vacin_assemnt = ' ')
 		flu->plist[cnt].influ_vacin_assemnt = 'No'
 	endif
 	;if(flu->plist[cnt].disch_nurse = ' ')
 	;	flu->plist[cnt].disch_nurse = flu->plist[cnt].disch_other
 	;endif
 
with nocounter
 
;---------------------------------------------------------------------------------------------
;Active patients Nurse unit and Room
select into $outdev
 
encntrid = flu->plist[d1.seq].encntrid
,admin_dt = flu->plist[d1.seq].verify_dt "@SHORTDATETIME"
,nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,beg = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME"
 
from (dummyt d1 WITH seq = value(size(flu->plist,5)))
	, encntr_loc_hist elh
 
plan d1 where flu->plist[d1.seq].pat_status_flag = 'A'
 
join elh where elh.encntr_id = flu->plist[d1.seq].encntrid
	and (cnvtdatetime(curdate, curtime3) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id
 
Head elh.encntr_id
 	num = 0
 	idx = 0
	idx = locateval(num, 1, size(flu->plist, 5), elh.encntr_id, flu->plist[num].encntrid)
Detail
    if(idx > 0)
	flu->plist[num].cur_nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 	flu->plist[num].cur_room = uar_get_code_display(elh.loc_room_cd)
    endif
 
with nocounter
 
 
IF(flu->reccnt > 0)
 
;----------------------------------------------------------------------------------------------
;Get Demographic info
select into 'nl:'
 
ea.encntr_id, fin = ea.alias
, mrn = ea1.alias, name = initcap(p.name_full_formatted)
, reg_age = substring(1,3,cnvtage(p.birth_dt_tm, flu->plist[d.seq].admit_dt, 0))
 
from (dummyt d WITH seq = value(size(flu->plist,5)))
	, encntr_alias ea
	, encntr_alias ea1
	, person p
 
plan d
 
join ea where ea.encntr_id = flu->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = flu->plist[d.seq].encntrid
	and ea1.encntr_alias_type_cd = 1079 ;mrn
	and ea1.active_ind = 1
 
join p where p.person_id = flu->plist[d.seq].personid
	and p.active_ind = 1
 
order by ea.encntr_id
 
Head ea.encntr_id
 	num = 0
 	idx = 0
	idx = locateval(num, 1, size(flu->plist, 5), ea.encntr_id, flu->plist[num].encntrid)
Detail
 
   if(idx > 0)
 	flu->plist[num].fin = fin
 	flu->plist[num].mrn = mrn
	flu->plist[num].pat_name = name
	flu->plist[num].age = reg_age
   endif
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Get Influenza Order detail
 
select into 'nl:'
	o.encntr_id, o.person_id, o.order_id
	, order_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
	, oa.action_sequence, oa.needs_verify_ind
 
from
	(dummyt d WITH seq = value(size(flu->plist,5)))
	, orders o
	, order_action oa
 
plan d
 
join o where o.person_id = flu->plist[d.seq].personid
	and o.encntr_id = flu->plist[d.seq].encntrid
	and o.catalog_cd = Influenza_var
 
join oa where oa.order_id = o.order_id
 	and oa.order_status_cd = 2550.00 ;ordered
 	and oa.needs_verify_ind = 3 ;verified
 
order by o.encntr_id, o.order_id
 
Head o.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(flu->plist, 5), o.encntr_id, flu->plist[cnt].encntrid)
Detail
   if(idx > 0)
	flu->plist[idx].vacin_order_dt = order_dt
   endif
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Open chart alert details - Discharged patients
select into 'NL:'
 
 e.person_id, e.encntr_id
 , chart_alert_dt = format(min(ede.dlg_dt_tm),'mm/dd/yyyy hh:mm;;q')
 
 ;, ede.dlg_event_id, ede.dlg_name
 ;, ede.dlg_prsnl_id
 ;, pr.name_full_formatted
 
from	  encounter e
 	, eks_dlg_event ede
 	, prsnl pr
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.disch_dt_tm is not null
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.encntr_id != 0.0
 
join ede where ede.person_id = e.person_id
	and ede.encntr_id = e.encntr_id
	and ede.dlg_name = 'COV_EKM!COV_OC_INFLUENZA_DC_ORDER'
	and ede.active_ind = 1
 
join pr where ede.dlg_prsnl_id = pr.person_id
 
group by e.person_id, e.encntr_id
 
order by  e.person_id, e.encntr_id, chart_alert_dt
 
Head e.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(flu->plist, 5), e.encntr_id, flu->plist[cnt].encntrid)
 
Detail
 
   if(idx > 0)
	flu->plist[idx].open_chart_alert_dt = chart_alert_dt
   endif
 
Foot e.encntr_id
 
	if(flu->plist[idx].open_chart_alert_dt != ' ')
		flu->plist[idx].open_chart_alert = 'Yes'
	elseif(flu->plist[idx].open_chart_alert_dt = '')
		flu->plist[idx].open_chart_alert = 'No'
	endif
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Open chart alert details - Active patients
select into 'NL:'
 
 e.person_id, e.encntr_id
 , chart_alert_dt = format(min(ede.dlg_dt_tm),'mm/dd/yyyy hh:mm;;q')
 
 ;, ede.dlg_event_id, ede.dlg_name
 ;, ede.dlg_prsnl_id
 ;, pr.name_full_formatted
 
from	  encounter e
 	, eks_dlg_event ede
 	, prsnl pr
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm is null
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.encntr_id != 0.0
 
join ede where ede.person_id = e.person_id
	and ede.encntr_id = e.encntr_id
	and ede.dlg_name = 'COV_EKM!COV_OC_INFLUENZA_DC_ORDER'
	and ede.active_ind = 1
 
join pr where ede.dlg_prsnl_id = pr.person_id
 
group by e.person_id, e.encntr_id
 
order by  e.person_id, e.encntr_id, chart_alert_dt
 
Head e.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(flu->plist, 5), e.encntr_id, flu->plist[cnt].encntrid)
Detail
 
   if(idx > 0)
	flu->plist[idx].open_chart_alert_dt = chart_alert_dt
   endif
 
Foot e.encntr_id
 
	if(flu->plist[idx].open_chart_alert_dt != ' ')
		flu->plist[idx].open_chart_alert = 'Yes'
	elseif(flu->plist[idx].open_chart_alert_dt = '')
		flu->plist[idx].open_chart_alert = 'No'
	endif
 
with nocounter
 
;-------------------------------------------------------------------------------
;Pager Alert finalization - Discharged patients
;Use the Module_id from pager record structure to get the patient demographic
 
select into 'NL:'
   module_id = pager->mlis[d.seq].module_id
 , emd.person_id, emd.encntr_id, e.loc_facility_cd
 , page_dt = format(pager->mlis[d.seq].begin_dt, 'mm/dd/yyyy hh:mm;;q')
 
from (dummyt d with seq = value(size(pager->mlis, 5)))
	, encounter e
	, eks_module_audit_det emd
 
plan d
 
join emd where emd.module_audit_id = pager->mlis[d.seq].module_id
	and emd.encntr_id != 0.0
 
join e where e.person_id = emd.person_id
	and e.encntr_id = emd.encntr_id
	and e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.disch_dt_tm is not null
	and e.encntr_id != 0.0
 
order by module_id, emd.person_id, emd.encntr_id, e.loc_facility_cd
 
Head e.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(flu->plist, 5), e.encntr_id, flu->plist[cnt].encntrid)
Detail
 
   if(idx > 0)
	flu->plist[idx].disch_page_rule_dt = page_dt
   endif
Foot e.encntr_id
 
	if(flu->plist[idx].disch_page_rule_dt != ' ')
		flu->plist[idx].disch_page_rule = 'Yes'
	elseif(flu->plist[idx].disch_page_rule_dt = '')
		flu->plist[idx].disch_page_rule = 'No'
	endif
 
with nocounter
 
;-------------------------------------------------------------------------------
;Pager Alert finalization - Active patients
;Use the Module_id from pager record structure to get the patient demographic
 
select into 'NL:'
   module_id = pager->mlis[d.seq].module_id
 , emd.person_id, emd.encntr_id, e.loc_facility_cd
 , page_dt = format(pager->mlis[d.seq].begin_dt, 'mm/dd/yyyy hh:mm;;q')
 
from (dummyt d with seq = value(size(pager->mlis, 5)))
	, encounter e
	, eks_module_audit_det emd
 
plan d
 
join emd where emd.module_audit_id = pager->mlis[d.seq].module_id
	and emd.encntr_id != 0.0
 
join e where e.person_id = emd.person_id
	and e.encntr_id = emd.encntr_id
	and e.loc_facility_cd = $facility_list
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.disch_dt_tm is null
	and e.encntr_id != 0.0
 
order by module_id, emd.person_id, emd.encntr_id, e.loc_facility_cd
 
Head e.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(flu->plist, 5), e.encntr_id, flu->plist[cnt].encntrid)
Detail
 
   if(idx > 0)
	flu->plist[idx].disch_page_rule_dt = page_dt
   endif
Foot e.encntr_id
 
	if(flu->plist[idx].disch_page_rule_dt != ' ')
		flu->plist[idx].disch_page_rule = 'Yes'
	elseif(flu->plist[idx].disch_page_rule_dt = '')
		flu->plist[idx].disch_page_rule = 'No'
	endif
 
with nocounter
 
endif

;---------------------------------------------------------------------------------------------
;VIS info

select into $outdev
c_catalog_disp = uar_get_code_display(ce.catalog_cd), admin_date = format(cmr.admin_end_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
, vac_info_sheet = uar_get_code_display(im.vis_cd), vis_publish_date = format(im.vis_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
, vis_given_date = format(im.vis_provided_on_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')

from
	(dummyt d WITH seq = value(size(flu->plist,5)))
	, clinical_event ce
	, ce_med_result cmr
	, immunization_modifier im

plan d

join ce where ce.encntr_id = flu->plist[d.seq].encntrid
	and ce.event_class_cd = 228 ;immunizations for uhs
	and ce.order_id > 0 ;shows it was documented on the mar
	and ce.event_end_dt_tm<= cnvtdatetime ( curdate, curtime3 )
	and ce.valid_until_dt_tm>= cnvtdatetime ( curdate, curtime3 )
	and ce.record_status_cd= 188 
	
join cmr where cmr.event_id = ce.event_id

join im where im.person_id = ce.person_id
	and im.event_id = ce.event_id

order by ce.encntr_id, ce.event_id

Head ce.encntr_id
 	num = 0
 	idx = 0
	idx = locateval(num, 1, size(flu->plist, 5), ce.encntr_id, flu->plist[num].encntrid)
Detail
    if(idx > 0)
	flu->plist[num].vis_given = vis_given_date
 	flu->plist[num].vis_published = vis_publish_date
    endif
 
with nocounter

;---------------------------------------------------------------------------------------------------

call echorecord(flu)
 
;*******************************************  FINAL OUTPUT **************************************************************************
 
if($patient_status = 1);Discharged patients only
 
	select distinct into value($outdev)
		facility = uar_get_code_display(flu->plist[d1.seq].facility)
		, fin = substring(1, 30, flu->plist[d1.seq].fin)
		, mrn = substring(1, 30, flu->plist[d1.seq].mrn)
		, patient_name = substring(1, 50, flu->plist[d1.seq].pat_name)
		, unit = trim(substring(1, 30, flu->plist[d1.seq].dish_nurse_unit))
		, room = trim(substring(1, 30, flu->plist[d1.seq].dish_room))
		, age = substring(1, 30, flu->plist[d1.seq].age)
		, admit_date = format(flu->plist[d1.seq].admit_dt, 'mm/dd/yyyy hh:mm;;q')
		, discharged_date = substring(1, 30, flu->plist[d1.seq].disch_dt)
		, patient_type = substring(1, 30, flu->plist[d1.seq].patient_type)
		, influenza_assessment_completed = substring(1, 5, flu->plist[d1.seq].influ_vacin_assemnt)
		, influenza_vaccine_status = substring(1, 30, flu->plist[d1.seq].influ_vacin_status)
		, influenza_vaccine_contraindicated_refused = substring(1, 100, flu->plist[d1.seq].vacin_contra_refuse)
		, influenza_vaccine_administration_status = substring(1, 100, flu->plist[d1.seq].vacin_pat_family_refuse)
		, influenza_vaccine_indicated = substring(1, 30, flu->plist[d1.seq].vacin_indicated)
		, influenza_vaccine_ordered_date = substring(1, 30, flu->plist[d1.seq].vacin_order_dt)
		, refused_in_mar = substring(1, 30, flu->plist[d1.seq].refused_mar)
		, influenza_vaccine_administered_date = substring(1, 30, flu->plist[d1.seq].vacin_admin_dt)
		, vis_given_dt = substring(1, 30, flu->plist[d1.seq].vis_given)
		, vis_published_dt = substring(1, 30, flu->plist[d1.seq].vis_published)
		;, dc_attestation_completed  = substring(1, 30, flu->plist[d1.seq].vacin_admin_doc)
		, dc_attestation_completed  = substring(1, 30, flu->plist[d1.seq].dsch_attest)
		, nurse_discharged = substring(1, 50, flu->plist[d1.seq].disch_nurse)
		, open_chart_alert = substring(1, 30, flu->plist[d1.seq].open_chart_alert)
		, open_chart_alert_date = substring(1, 30, flu->plist[d1.seq].open_chart_alert_dt)
		, discharge_summary_pager_alert = substring(1, 30, flu->plist[d1.seq].disch_page_rule)
		, discharge_summary_pager_alert_date= substring(1, 30, flu->plist[d1.seq].disch_page_rule_dt)
 
	from	(dummyt   d1  with seq = value(size(flu->plist, 5)))
 
	plan d1 where flu->plist[d1.seq].disch_dt != ''
		and flu->plist[d1.seq].fin != ''
 
	order by facility, unit, admit_date, patient_name, fin
 
	with nocounter, separator=" ", format
 
else ;active patients only
 
	select distinct into value($outdev)
		facility = uar_get_code_display(flu->plist[d1.seq].facility)
		, fin = substring(1, 30, flu->plist[d1.seq].fin)
		, mrn = substring(1, 30, flu->plist[d1.seq].mrn)
		, patient_name = trim(substring(1, 50, flu->plist[d1.seq].pat_name))
		, unit = trim(substring(1, 30, flu->plist[d1.seq].cur_nurse_unit))
		, room = trim(substring(1, 30, flu->plist[d1.seq].cur_room))
		, age = substring(1, 30, flu->plist[d1.seq].age)
		, admit_date = format(flu->plist[d1.seq].admit_dt, 'mm/dd/yyyy hh:mm;;q')
		, discharged_date = substring(1, 30, flu->plist[d1.seq].disch_dt)
		, patient_type = substring(1, 30, flu->plist[d1.seq].patient_type)
		, influenza_assessment_completed = substring(1, 5, flu->plist[d1.seq].influ_vacin_assemnt)
		, influenza_vaccine_status = substring(1, 30, flu->plist[d1.seq].influ_vacin_status)
		, influenza_vaccine_contraindicated_refused = substring(1, 100, flu->plist[d1.seq].vacin_contra_refuse)
		, influenza_vaccine_administration_status = substring(1, 100, flu->plist[d1.seq].vacin_pat_family_refuse)
		, influenza_vaccine_indicated = substring(1, 30, flu->plist[d1.seq].vacin_indicated)
		, influenza_vaccine_ordered_date = substring(1, 30, flu->plist[d1.seq].vacin_order_dt)
		, refused_in_mar = substring(1, 30, flu->plist[d1.seq].refused_mar)
		, influenza_vaccine_administered_date = substring(1, 30, flu->plist[d1.seq].vacin_admin_dt)
		, vis_given_dt = substring(1, 30, flu->plist[d1.seq].vis_given)
		, vis_published_dt = substring(1, 30, flu->plist[d1.seq].vis_published)
		;, dc_attestation_completed  = substring(1, 30, flu->plist[d1.seq].vacin_admin_doc)
		, dc_attestation_completed  = substring(1, 30, flu->plist[d1.seq].dsch_attest)
		, nurse_discharged = substring(1, 50, flu->plist[d1.seq].disch_nurse)
		, open_chart_alert = substring(1, 30, flu->plist[d1.seq].open_chart_alert)
		, open_chart_alert_date = substring(1, 30, flu->plist[d1.seq].open_chart_alert_dt)
		, discharge_summary_pager_alert = substring(1, 30, flu->plist[d1.seq].disch_page_rule)
		, discharge_summary_pager_alert_date= substring(1, 30, flu->plist[d1.seq].disch_page_rule_dt)
 
	from	(dummyt   d1  with seq = value(size(flu->plist, 5)))
 
	plan d1 where flu->plist[d1.seq].disch_dt = ''
		and flu->plist[d1.seq].fin != ''
 
	order by facility, unit, admit_date, patient_name, fin
 
	with nocounter, separator=" ", format
 
#exitscript
 
endif ;patient_status
 
;***************************************************************************************************
 
end go
 
 
 
 
 

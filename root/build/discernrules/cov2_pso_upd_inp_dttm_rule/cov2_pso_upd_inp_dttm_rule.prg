/***********************Change Log*************************
VERSION  DATE       ENGINEER            COMMENT
-------	 -------    -----------         ------------------------
0.1		7/19/2018	Chris Grobbel		Initial Code Sample
1.0		7/20/2018	Ryan Gotsche		Standardization/Modifications for CHS_TN (CR-2593)
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Description - Script is called from Discern Expert and will update the
	inpatient_admit_dt_tm field based on the logic within the rule
	and logic below.
 
Discern Rule - COV_PSO_UPD_INP_DT_TM2
 
**************************************************************/
drop program cov2_pso_upd_inp_dttm_rule:dba go
create program cov2_pso_upd_inp_dttm_rule:dba
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare 6003_MODIFY = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!3093")),protect
declare 6003_ORDER = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!3094")),protect
declare 6003_CANCELDISCONTINUE = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!42386")),protect
declare 6003_CANCEL = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!3090")),protect
declare 6003_VOID = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!42385")),protect
/************************************************************
 *                      Define Records                      *
 ************************************************************/
; Request fo rpm_upt_encounter
free record encntr_req
record encntr_req (
  1 encounter_qual = i4
  1 esi_ensure_type = c3
  1 mode = i2
  1 encounter [*]
    2 mental_health_cd = f8
    2 mental_health_dt_tm = dq8
    2 action_type = c3
    2 new_person = c1
    2 pm_hist_tracking_id = f8
    2 transaction_dt_tm = dq8
    2 transaction_reason_cd = f8
    2 encntr_id = f8
    2 person_id = f8
    2 active_ind_ind = i2
    2 active_ind = i2
    2 active_status_cd = f8
    2 active_status_dt_tm = dq8
    2 active_status_prsnl_id = f8
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 encntr_class_cd = f8
    2 encntr_type_cd = f8
    2 encntr_type_class_cd = f8
    2 encntr_status_cd = f8
    2 pre_reg_dt_tm = dq8
    2 pre_reg_prsnl_id = f8
    2 reg_dt_tm = dq8
    2 reg_prsnl_id = f8
    2 est_arrive_dt_tm = dq8
    2 est_depart_dt_tm = dq8
    2 arrive_dt_tm = dq8
    2 depart_dt_tm = dq8
    2 admit_type_cd = f8
    2 admit_src_cd = f8
    2 admit_mode_cd = f8
    2 admit_with_medication_cd = f8
    2 referring_comment = c100
    2 disch_disposition_cd = f8
    2 disch_to_loctn_cd = f8
    2 preadmit_nbr = c100
    2 preadmit_testing_cd = f8
    2 preadmit_testing_list_ind = i2
    2 preadmit_testing [*]
      3 value_cd = f8
    2 readmit_cd = f8
    2 accommodation_cd = f8
    2 accommodation_request_cd = f8
    2 alt_result_dest_cd = f8
    2 ambulatory_cond_cd = f8
    2 courtesy_cd = f8
    2 diet_type_cd = f8
    2 isolation_cd = f8
    2 med_service_cd = f8
    2 result_dest_cd = f8
    2 confid_level_cd = f8
    2 vip_cd = f8
    2 name_last_key = c200
    2 name_first_key = c200
    2 name_full_formatted = c200
    2 name_last = c200
    2 name_first = c200
    2 name_phonetic = c200
    2 sex_cd = f8
    2 birth_dt_cd = f8
    2 birth_dt_tm = dq8
    2 species_cd = f8
    2 data_status_cd = f8
    2 data_status_dt_tm = dq8
    2 data_status_prsnl_id = f8
    2 contributor_system_cd = f8
    2 location_cd = f8
    2 loc_facility_cd = f8
    2 loc_building_cd = f8
    2 loc_nurse_unit_cd = f8
    2 loc_room_cd = f8
    2 loc_bed_cd = f8
    2 disch_dt_tm = dq8
    2 guarantor_type_cd = f8
    2 loc_temp_cd = f8
    2 organization_id = f8
    2 EsiOrgAlias [*]
      3 alias_pool_cd = f8
      3 alias_type_cd = f8
      3 alias = c200
    2 def_organization_id = f8
    2 reason_for_visit = c500
    2 encntr_financial_id = f8
    2 name_first_synonym_id = f8
    2 financial_class_cd = f8
    2 bbd_procedure_cd = f8
    2 info_given_by = c100
    2 safekeeping_cd = f8
    2 trauma_cd = f8
    2 triage_cd = f8
    2 triage_dt_tm = dq8
    2 visitor_status_cd = f8
    2 valuables_cd = f8
    2 valuables_list_ind = i2
    2 valuables [*]
      3 value_cd = f8
    2 security_access_cd = f8
    2 refer_facility_cd = f8
    2 trauma_dt_tm = dq8
    2 accomp_by_cd = f8
    2 accommodation_reason_cd = f8
    2 program_service_cd = f8
    2 specialty_unit_cd = f8
    2 updt_cnt = i4
    2 CHART_COMPLETE_DT_TM = dq8
    2 ENCNTR_COMPLETE_DT_TM = dq8
    2 ZERO_BALANCE_DT_TM = dq8
    2 ARCHIVE_DT_TM_EST = dq8
    2 ARCHIVE_DT_TM_ACT = dq8
    2 PURGE_DT_TM_EST = dq8
    2 PURGE_DT_TM_ACT = dq8
    2 PA_CURRENT_STATUS_DT_TM = dq8
    2 PA_CURRENT_STATUS_CD = f8
    2 PARENT_RET_CRITERIA_ID = f8
    2 SERVICE_CATEGORY_CD = f8
    2 TRANSACTION_DT_TM_OLD = dq8
    2 ENCNTR_FIN_HIST_TYPE_CD = f8
    2 est_length_of_stay = i4
    2 contract_status_cd = f8
    2 attend_prsnl_id = f8
    2 assign_to_loc_dt_tm = dq8
    2 alt_lvl_care_cd = f8
    2 alt_lvl_care_dt_tm = dq8
    2 alc_reason_cd = f8
    2 alc_decomp_dt_tm = dq8
    2 region_cd = f8
    2 sitter_required_cd = f8
    2 doc_rcvd_dt_tm = dq8
    2 referral_rcvd_dt_tm = dq8
    2 place_auth_prsnl_id = f8
    2 patient_classification_cd = f8
    2 mental_category_cd = f8
    2 psychiatric_status_cd = f8
    2 inpatient_admit_dt_tm = dq8
    2 result_acc_dt_tm = dq8
    2 pregnancy_status_cd = f8
    2 expected_delivery_dt_tm = dq8
    2 last_menstrual_period_dt_tm = dq8
    2 onset_dt_tm = dq8
    2 level_of_service_cd = f8
    2 abn_status_cd = f8
  1 EncntrLocHistOverride = i2
)
 
; Reply for pm_upt_encounter
free record encntr_reply
record encntr_reply
( 1 encounter_qual        = i2
  1 encounter[*]
    2 encntr_id           = f8
    2 pm_hist_tracking_id = f8
%i cclsource:status_block.inc
)

call echo(build2("trigger_orderid=",trigger_orderid))
call echo(6003_MODIFY)
call echo(6003_ORDER)

; Get the inpatient_admit_dt_tm from the order details and populate encntr_req
; 1. This will process the Order and Modify actions
select into "nl:"
from (dummyt d with seq=size(request->orderList,5)),
     (dummyt d2 with seq=1)
plan d
   where request->orderList[d.seq].orderId = trigger_orderid
      and request->orderList[d.seq].actionTypeCd in (6003_MODIFY, 6003_ORDER)   ; Modify, Order
      and maxrec(d2,size(request->orderList[d.seq]->detailList,5))
join d2
   where request->orderList[d.seq]->detailList[d2.seq].oeFieldMeaning = "INPTADMDTETME"  ; replace with oe_field_meaning of the
                                                                                        ; inpatient_admit_dt_tm order detail
head report
   ;Populate request structure for pm_upt_encounter
   stat = alterlist(encntr_req->encounter, 1)
   encntr_req->encounter_qual                      = 1
   encntr_req->encounter[1]->encntr_id             = trigger_encntrid
   encntr_req->encounter[1]->person_id             = trigger_personid
   encntr_req->encounter[1]->inpatient_admit_dt_tm = request->orderList[d.seq]->detailList[d2.seq].oeFieldDtTmValue
with nocounter
 
; 2. This will process the Void actions
select into "nl:"
from (dummyt d with seq=size(request->orderList,5))
plan d
   where request->orderList[d.seq].orderId = trigger_orderid
      and request->orderList[d.seq].actionTypeCd in (6003_VOID)   ; Void
head report
   ;Populate request structure for pm_upt_encounter
   stat = alterlist(encntr_req->encounter, 1)
   encntr_req->encounter_qual                      = 1
   encntr_req->encounter[1]->encntr_id             = trigger_encntrid
   encntr_req->encounter[1]->person_id             = trigger_personid
   encntr_req->encounter[1]->inpatient_admit_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00") ; this tells  pm_upt_encounter to
                                                                                             ; blank out the date
   encntr_req->encounter[1].attend_prsnl_id =    2.0
with nocounter
 
;call pm_upt_encounter
if (encntr_req->encounter_qual > 0)
   execute pm_upt_encounter with replace("REQUEST", ENCNTR_REQ),replace("REPLY", ENCNTR_REPLY)
endif
 
#exit_script
call echorecord(encntr_req) 
set retval = 100
 
end
go
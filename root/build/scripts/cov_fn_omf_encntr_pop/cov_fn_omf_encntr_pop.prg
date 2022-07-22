DROP PROGRAM cov_fn_omf_encntr_pop :dba GO
CREATE PROGRAM cov_fn_omf_encntr_pop :dba
 RECORD reply (
   1 ops_event = cv
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 DECLARE fncomplete = f8 WITH private ,noconstant (curtime3 )
 DECLARE serrmsg = vc
 DECLARE v_start_date = q8 WITH public ,noconstant (0.0 )
 DECLARE v_end_date = q8 WITH public ,noconstant (0.0 )
 DECLARE v_pcp_cd = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,331 ,"PCP" ) )
 DECLARE status_complete_cd = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,460 ,"COMPLETE" ) )
 DECLARE ti_loop_count = i4 WITH public ,noconstant (0 )
 DECLARE arr_loop_count = i4 WITH public ,noconstant (0 )
 DECLARE fn_omf_pop_req_num = i4 WITH public ,constant (4250395 )
 DECLARE stat = i4 WITH public ,noconstant (0 )
 DECLARE nidx = i4 WITH noconstant (0 )
 DECLARE idx = i4 WITH noconstant (0 )
 DECLARE nnewcnt = i4 WITH noconstant (0 )
 DECLARE nmodcnt = i4 WITH noconstant (0 )
 FREE RECORD rfnomf
 RECORD rfnomf (
   1 list [* ]
     2 new_record_flag = i2
     2 active_ind = i2
     2 fn_omf_encntr_id = f8
     2 fn_omf_id = vc
     2 tracking_id = f8
     2 tracking_group_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 checkin_acuity_id = f8
     2 checkout_acuity_id = f8
     2 primary_care_physician_id = f8
     2 primary_doc_id = f8
     2 secondary_doc_id = f8
     2 primary_nurse_id = f8
     2 secondary_nurse_id = f8
     2 specialty_id = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_ambulatory_unit_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_grp = i4
     2 loc_room_cd = f8
     2 loc_room_grp = i4
     2 loc_bed_cd = f8
     2 loc_bed_grp = i4
     2 checkin_dt_tm = dq8
     2 checkin_omf_dt = i4
     2 checkin_omf_tm = i4
     2 checkout_dt_tm = dq8
     2 checkout_omf_dt = i4
     2 checkout_omf_tm = i4
     2 arrive_req_evt_dt_tm = dq8
     2 arrive_req_evt_omf_dt = i4
     2 arrive_req_evt_omf_tm = i4
     2 triage_comp_evt_dt_tm = dq8
     2 triage_comp_evt_omf_dt = i4
     2 triage_comp_evt_omf_tm = i4
     2 bed_assign_comp_evt_dt_tm = dq8
     2 bed_assign_comp_evt_omf_dt = i4
     2 bed_assign_comp_evt_omf_tm = i4
     2 rn_assess_start_evt_dt_tm = dq8
     2 rn_assess_start_evt_omf_dt = i4
     2 rn_assess_start_evt_omf_tm = i4
     2 md_assess_start_evt_dt_tm = dq8
     2 md_assess_start_evt_omf_dt = i4
     2 md_assess_start_evt_omf_tm = i4
     2 reg_comp_evt_dt_tm = dq8
     2 reg_comp_evt_omf_dt = i4
     2 reg_comp_evt_omf_tm = i4
     2 dispo_req_evt_dt_tm = dq8
     2 dispo_req_evt_omf_dt = i4
     2 dispo_req_evt_omf_tm = i4
     2 dispo_comp_evt_dt_tm = dq8
     2 dispo_comp_evt_omf_dt = i4
     2 dispo_comp_evt_omf_tm = i4
     2 disch_diag = vc
 )
 FREE RECORD revent
 RECORD revent (
   1 list [* ]
     2 cdf_str = c12
     2 event_code = f8
 )
 FREE RECORD rtrack
 RECORD rtrack (
   1 list [* ]
     2 tracking_id = f8
     2 updt_dt_tm = dq8
     2 encntr_id = f8
     2 person_id = f8
 )
 FREE RECORD rnewomf
 RECORD rnewomf (
   1 list [* ]
     2 new_record_flag = i2
     2 active_ind = i2
     2 fn_omf_encntr_id = f8
     2 fn_omf_id = vc
     2 tracking_id = f8
     2 tracking_group_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 checkin_acuity_id = f8
     2 checkout_acuity_id = f8
     2 primary_care_physician_id = f8
     2 primary_doc_id = f8
     2 secondary_doc_id = f8
     2 primary_nurse_id = f8
     2 secondary_nurse_id = f8
     2 specialty_id = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_ambulatory_unit_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_grp = i4
     2 loc_room_cd = f8
     2 loc_room_grp = i4
     2 loc_bed_cd = f8
     2 loc_bed_grp = i4
     2 checkin_dt_tm = dq8
     2 checkin_omf_dt = i4
     2 checkin_omf_tm = i4
     2 checkout_dt_tm = dq8
     2 checkout_omf_dt = i4
     2 checkout_omf_tm = i4
     2 arrive_req_evt_dt_tm = dq8
     2 arrive_req_evt_omf_dt = i4
     2 arrive_req_evt_omf_tm = i4
     2 triage_comp_evt_dt_tm = dq8
     2 triage_comp_evt_omf_dt = i4
     2 triage_comp_evt_omf_tm = i4
     2 bed_assign_comp_evt_dt_tm = dq8
     2 bed_assign_comp_evt_omf_dt = i4
     2 bed_assign_comp_evt_omf_tm = i4
     2 rn_assess_start_evt_dt_tm = dq8
     2 rn_assess_start_evt_omf_dt = i4
     2 rn_assess_start_evt_omf_tm = i4
     2 md_assess_start_evt_dt_tm = dq8
     2 md_assess_start_evt_omf_dt = i4
     2 md_assess_start_evt_omf_tm = i4
     2 reg_comp_evt_dt_tm = dq8
     2 reg_comp_evt_omf_dt = i4
     2 reg_comp_evt_omf_tm = i4
     2 dispo_req_evt_dt_tm = dq8
     2 dispo_req_evt_omf_dt = i4
     2 dispo_req_evt_omf_tm = i4
     2 dispo_comp_evt_dt_tm = dq8
     2 dispo_comp_evt_omf_dt = i4
     2 dispo_comp_evt_omf_tm = i4
     2 disch_diag = vc
 )
 FREE RECORD rmodomf
 RECORD rmodomf (
   1 list [* ]
     2 new_record_flag = i2
     2 active_ind = i2
     2 fn_omf_encntr_id = f8
     2 fn_omf_id = vc
     2 tracking_id = f8
     2 tracking_group_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 checkin_acuity_id = f8
     2 checkout_acuity_id = f8
     2 primary_care_physician_id = f8
     2 primary_doc_id = f8
     2 secondary_doc_id = f8
     2 primary_nurse_id = f8
     2 secondary_nurse_id = f8
     2 specialty_id = f8
     2 loc_building_cd = f8
     2 loc_facility_cd = f8
     2 loc_ambulatory_unit_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_grp = i4
     2 loc_room_cd = f8
     2 loc_room_grp = i4
     2 loc_bed_cd = f8
     2 loc_bed_grp = i4
     2 checkin_dt_tm = dq8
     2 checkin_omf_dt = i4
     2 checkin_omf_tm = i4
     2 checkout_dt_tm = dq8
     2 checkout_omf_dt = i4
     2 checkout_omf_tm = i4
     2 arrive_req_evt_dt_tm = dq8
     2 arrive_req_evt_omf_dt = i4
     2 arrive_req_evt_omf_tm = i4
     2 triage_comp_evt_dt_tm = dq8
     2 triage_comp_evt_omf_dt = i4
     2 triage_comp_evt_omf_tm = i4
     2 bed_assign_comp_evt_dt_tm = dq8
     2 bed_assign_comp_evt_omf_dt = i4
     2 bed_assign_comp_evt_omf_tm = i4
     2 rn_assess_start_evt_dt_tm = dq8
     2 rn_assess_start_evt_omf_dt = i4
     2 rn_assess_start_evt_omf_tm = i4
     2 md_assess_start_evt_dt_tm = dq8
     2 md_assess_start_evt_omf_dt = i4
     2 md_assess_start_evt_omf_tm = i4
     2 reg_comp_evt_dt_tm = dq8
     2 reg_comp_evt_omf_dt = i4
     2 reg_comp_evt_omf_tm = i4
     2 dispo_req_evt_dt_tm = dq8
     2 dispo_req_evt_omf_dt = i4
     2 dispo_req_evt_omf_tm = i4
     2 dispo_comp_evt_dt_tm = dq8
     2 dispo_comp_evt_omf_dt = i4
     2 dispo_comp_evt_omf_tm = i4
     2 disch_diag = vc
 )
 
 
 DECLARE populatelists (null ) = null
 
 DECLARE addrecords (null ) = null
 
 DECLARE updaterecords (null ) = null
 
 SUBROUTINE  populatelists (null )
  CALL echo ("populateLists" )
  IF ((checkin_count > 0 ) )
   SET stat = alterlist (rnewomf->list ,checkin_count )
   SET stat = alterlist (rmodomf->list ,checkin_count )
   FOR (nidx = 1 TO checkin_count )
    IF ((rfnomf->list[nidx ].new_record_flag = 1 ) )
     SET nnewcnt = (nnewcnt + 1 )
     SET rnewomf->list[nnewcnt ].new_record_flag = rfnomf->list[nidx ].new_record_flag
     SET rnewomf->list[nnewcnt ].fn_omf_encntr_id = rfnomf->list[nidx ].fn_omf_encntr_id
     SET rnewomf->list[nnewcnt ].fn_omf_id = rfnomf->list[nidx ].fn_omf_id
     SET rnewomf->list[nnewcnt ].tracking_group_cd = rfnomf->list[nidx ].tracking_group_cd
     SET rnewomf->list[nnewcnt ].tracking_id = rfnomf->list[nidx ].tracking_id
     SET rnewomf->list[nnewcnt ].encntr_id = rfnomf->list[nidx ].encntr_id
     SET rnewomf->list[nnewcnt ].person_id = rfnomf->list[nidx ].person_id
     SET rnewomf->list[nnewcnt ].checkin_acuity_id = rfnomf->list[nidx ].checkin_acuity_id
     SET rnewomf->list[nnewcnt ].checkout_acuity_id = rfnomf->list[nidx ].checkout_acuity_id
     SET rnewomf->list[nnewcnt ].primary_care_physician_id = rfnomf->list[nidx ].
     primary_care_physician_id
     SET rnewomf->list[nnewcnt ].primary_doc_id = rfnomf->list[nidx ].primary_doc_id
     SET rnewomf->list[nnewcnt ].secondary_doc_id = rfnomf->list[nidx ].secondary_doc_id
     SET rnewomf->list[nnewcnt ].primary_nurse_id = rfnomf->list[nidx ].primary_nurse_id
     SET rnewomf->list[nnewcnt ].secondary_nurse_id = rfnomf->list[nidx ].secondary_nurse_id
     SET rnewomf->list[nnewcnt ].specialty_id = rfnomf->list[nidx ].specialty_id
     SET rnewomf->list[nnewcnt ].loc_building_cd = rfnomf->list[nidx ].loc_building_cd
     SET rnewomf->list[nnewcnt ].loc_facility_cd = rfnomf->list[nidx ].loc_facility_cd
     SET rnewomf->list[nnewcnt ].loc_ambulatory_unit_cd = rfnomf->list[nidx ].loc_ambulatory_unit_cd
     SET rnewomf->list[nnewcnt ].loc_nurse_unit_cd = rfnomf->list[nidx ].loc_nurse_unit_cd
     SET rnewomf->list[nnewcnt ].loc_nurse_unit_grp = rfnomf->list[nidx ].loc_nurse_unit_grp
     SET rnewomf->list[nnewcnt ].loc_room_cd = rfnomf->list[nidx ].loc_room_cd
     SET rnewomf->list[nnewcnt ].loc_room_grp = rfnomf->list[nidx ].loc_room_grp
     SET rnewomf->list[nnewcnt ].loc_bed_cd = rfnomf->list[nidx ].loc_bed_cd
     SET rnewomf->list[nnewcnt ].loc_bed_grp = rfnomf->list[nidx ].loc_bed_grp
     SET rnewomf->list[nnewcnt ].checkin_dt_tm = rfnomf->list[nidx ].checkin_dt_tm
     SET rnewomf->list[nnewcnt ].checkin_omf_dt = rfnomf->list[nidx ].checkin_omf_dt
     SET rnewomf->list[nnewcnt ].checkin_omf_tm = rfnomf->list[nidx ].checkin_omf_tm
     SET rnewomf->list[nnewcnt ].checkout_dt_tm = rfnomf->list[nidx ].checkout_dt_tm
     SET rnewomf->list[nnewcnt ].checkout_omf_dt = rfnomf->list[nidx ].checkout_omf_dt
     SET rnewomf->list[nnewcnt ].checkout_omf_tm = rfnomf->list[nidx ].checkout_omf_tm
     SET rnewomf->list[nnewcnt ].arrive_req_evt_dt_tm = rfnomf->list[nidx ].arrive_req_evt_dt_tm
     SET rnewomf->list[nnewcnt ].arrive_req_evt_omf_dt = rfnomf->list[nidx ].arrive_req_evt_omf_dt
     SET rnewomf->list[nnewcnt ].arrive_req_evt_omf_tm = rfnomf->list[nidx ].arrive_req_evt_omf_tm
     SET rnewomf->list[nnewcnt ].triage_comp_evt_dt_tm = rfnomf->list[nidx ].triage_comp_evt_dt_tm
     SET rnewomf->list[nnewcnt ].triage_comp_evt_omf_dt = rfnomf->list[nidx ].triage_comp_evt_omf_dt
     SET rnewomf->list[nnewcnt ].triage_comp_evt_omf_tm = rfnomf->list[nidx ].triage_comp_evt_omf_tm
     SET rnewomf->list[nnewcnt ].bed_assign_comp_evt_dt_tm = rfnomf->list[nidx ].
     bed_assign_comp_evt_dt_tm
     SET rnewomf->list[nnewcnt ].bed_assign_comp_evt_omf_dt = rfnomf->list[nidx ].
     bed_assign_comp_evt_omf_dt
     SET rnewomf->list[nnewcnt ].bed_assign_comp_evt_omf_tm = rfnomf->list[nidx ].
     bed_assign_comp_evt_omf_tm
     SET rnewomf->list[nnewcnt ].rn_assess_start_evt_dt_tm = rfnomf->list[nidx ].
     rn_assess_start_evt_dt_tm
     SET rnewomf->list[nnewcnt ].rn_assess_start_evt_omf_dt = rfnomf->list[nidx ].
     rn_assess_start_evt_omf_dt
     SET rnewomf->list[nnewcnt ].rn_assess_start_evt_omf_tm = rfnomf->list[nidx ].
     rn_assess_start_evt_omf_tm
     SET rnewomf->list[nnewcnt ].md_assess_start_evt_dt_tm = rfnomf->list[nidx ].
     md_assess_start_evt_dt_tm
     SET rnewomf->list[nnewcnt ].md_assess_start_evt_omf_dt = rfnomf->list[nidx ].
     md_assess_start_evt_omf_dt
     SET rnewomf->list[nnewcnt ].md_assess_start_evt_omf_tm = rfnomf->list[nidx ].
     md_assess_start_evt_omf_tm
     SET rnewomf->list[nnewcnt ].reg_comp_evt_dt_tm = rfnomf->list[nidx ].reg_comp_evt_dt_tm
     SET rnewomf->list[nnewcnt ].reg_comp_evt_omf_dt = rfnomf->list[nidx ].reg_comp_evt_omf_dt
     SET rnewomf->list[nnewcnt ].reg_comp_evt_omf_tm = rfnomf->list[nidx ].reg_comp_evt_omf_tm
     SET rnewomf->list[nnewcnt ].dispo_req_evt_dt_tm = rfnomf->list[nidx ].dispo_req_evt_dt_tm
     SET rnewomf->list[nnewcnt ].dispo_req_evt_omf_dt = rfnomf->list[nidx ].dispo_req_evt_omf_dt
     SET rnewomf->list[nnewcnt ].dispo_req_evt_omf_tm = rfnomf->list[nidx ].dispo_req_evt_omf_tm
     SET rnewomf->list[nnewcnt ].dispo_comp_evt_dt_tm = rfnomf->list[nidx ].dispo_comp_evt_dt_tm
     SET rnewomf->list[nnewcnt ].dispo_comp_evt_omf_dt = rfnomf->list[nidx ].dispo_comp_evt_omf_dt
     SET rnewomf->list[nnewcnt ].dispo_comp_evt_omf_tm = rfnomf->list[nidx ].dispo_comp_evt_omf_tm
     SET rnewomf->list[nnewcnt ].active_ind = rfnomf->list[nidx ].active_ind
     SET rnewomf->list[nnewcnt ].disch_diag = trim (substring (1 ,250 ,rfnomf->list[nidx ].disch_diag
        ) )
    ELSE
     SET nmodcnt = (nmodcnt + 1 )
     SET rmodomf->list[nmodcnt ].new_record_flag = rfnomf->list[nidx ].new_record_flag
     SET rmodomf->list[nmodcnt ].fn_omf_encntr_id = rfnomf->list[nidx ].fn_omf_encntr_id
     SET rmodomf->list[nmodcnt ].fn_omf_id = rfnomf->list[nidx ].fn_omf_id
     SET rmodomf->list[nmodcnt ].tracking_group_cd = rfnomf->list[nidx ].tracking_group_cd
     SET rmodomf->list[nmodcnt ].tracking_id = rfnomf->list[nidx ].tracking_id
     SET rmodomf->list[nmodcnt ].encntr_id = rfnomf->list[nidx ].encntr_id
     SET rmodomf->list[nmodcnt ].person_id = rfnomf->list[nidx ].person_id
     SET rmodomf->list[nmodcnt ].checkin_acuity_id = rfnomf->list[nidx ].checkin_acuity_id
     SET rmodomf->list[nmodcnt ].checkout_acuity_id = rfnomf->list[nidx ].checkout_acuity_id
     SET rmodomf->list[nmodcnt ].primary_care_physician_id = rfnomf->list[nidx ].
     primary_care_physician_id
     SET rmodomf->list[nmodcnt ].primary_doc_id = rfnomf->list[nidx ].primary_doc_id
     SET rmodomf->list[nmodcnt ].secondary_doc_id = rfnomf->list[nidx ].secondary_doc_id
     SET rmodomf->list[nmodcnt ].primary_nurse_id = rfnomf->list[nidx ].primary_nurse_id
     SET rmodomf->list[nmodcnt ].secondary_nurse_id = rfnomf->list[nidx ].secondary_nurse_id
     SET rmodomf->list[nmodcnt ].specialty_id = rfnomf->list[nidx ].specialty_id
     SET rmodomf->list[nmodcnt ].loc_building_cd = rfnomf->list[nidx ].loc_building_cd
     SET rmodomf->list[nmodcnt ].loc_facility_cd = rfnomf->list[nidx ].loc_facility_cd
     SET rmodomf->list[nmodcnt ].loc_ambulatory_unit_cd = rfnomf->list[nidx ].loc_ambulatory_unit_cd
     SET rmodomf->list[nmodcnt ].loc_nurse_unit_cd = rfnomf->list[nidx ].loc_nurse_unit_cd
     SET rmodomf->list[nmodcnt ].loc_nurse_unit_grp = rfnomf->list[nidx ].loc_nurse_unit_grp
     SET rmodomf->list[nmodcnt ].loc_room_cd = rfnomf->list[nidx ].loc_room_cd
     SET rmodomf->list[nmodcnt ].loc_room_grp = rfnomf->list[nidx ].loc_room_grp
     SET rmodomf->list[nmodcnt ].loc_bed_cd = rfnomf->list[nidx ].loc_bed_cd
     SET rmodomf->list[nmodcnt ].loc_bed_grp = rfnomf->list[nidx ].loc_bed_grp
     SET rmodomf->list[nmodcnt ].checkin_dt_tm = rfnomf->list[nidx ].checkin_dt_tm
     SET rmodomf->list[nmodcnt ].checkin_omf_dt = rfnomf->list[nidx ].checkin_omf_dt
     SET rmodomf->list[nmodcnt ].checkin_omf_tm = rfnomf->list[nidx ].checkin_omf_tm
     SET rmodomf->list[nmodcnt ].checkout_dt_tm = rfnomf->list[nidx ].checkout_dt_tm
     SET rmodomf->list[nmodcnt ].checkout_omf_dt = rfnomf->list[nidx ].checkout_omf_dt
     SET rmodomf->list[nmodcnt ].checkout_omf_tm = rfnomf->list[nidx ].checkout_omf_tm
     SET rmodomf->list[nmodcnt ].arrive_req_evt_dt_tm = rfnomf->list[nidx ].arrive_req_evt_dt_tm
     SET rmodomf->list[nmodcnt ].arrive_req_evt_omf_dt = rfnomf->list[nidx ].arrive_req_evt_omf_dt
     SET rmodomf->list[nmodcnt ].arrive_req_evt_omf_tm = rfnomf->list[nidx ].arrive_req_evt_omf_tm
     SET rmodomf->list[nmodcnt ].triage_comp_evt_dt_tm = rfnomf->list[nidx ].triage_comp_evt_dt_tm
     SET rmodomf->list[nmodcnt ].triage_comp_evt_omf_dt = rfnomf->list[nidx ].triage_comp_evt_omf_dt
     SET rmodomf->list[nmodcnt ].triage_comp_evt_omf_tm = rfnomf->list[nidx ].triage_comp_evt_omf_tm
     SET rmodomf->list[nmodcnt ].bed_assign_comp_evt_dt_tm = rfnomf->list[nidx ].
     bed_assign_comp_evt_dt_tm
     SET rmodomf->list[nmodcnt ].bed_assign_comp_evt_omf_dt = rfnomf->list[nidx ].
     bed_assign_comp_evt_omf_dt
     SET rmodomf->list[nmodcnt ].bed_assign_comp_evt_omf_tm = rfnomf->list[nidx ].
     bed_assign_comp_evt_omf_tm
     SET rmodomf->list[nmodcnt ].rn_assess_start_evt_dt_tm = rfnomf->list[nidx ].
     rn_assess_start_evt_dt_tm
     SET rmodomf->list[nmodcnt ].rn_assess_start_evt_omf_dt = rfnomf->list[nidx ].
     rn_assess_start_evt_omf_dt
     SET rmodomf->list[nmodcnt ].rn_assess_start_evt_omf_tm = rfnomf->list[nidx ].
     rn_assess_start_evt_omf_tm
     SET rmodomf->list[nmodcnt ].md_assess_start_evt_dt_tm = rfnomf->list[nidx ].
     md_assess_start_evt_dt_tm
     SET rmodomf->list[nmodcnt ].md_assess_start_evt_omf_dt = rfnomf->list[nidx ].
     md_assess_start_evt_omf_dt
     SET rmodomf->list[nmodcnt ].md_assess_start_evt_omf_tm = rfnomf->list[nidx ].
     md_assess_start_evt_omf_tm
     SET rmodomf->list[nmodcnt ].reg_comp_evt_dt_tm = rfnomf->list[nidx ].reg_comp_evt_dt_tm
     SET rmodomf->list[nmodcnt ].reg_comp_evt_omf_dt = rfnomf->list[nidx ].reg_comp_evt_omf_dt
     SET rmodomf->list[nmodcnt ].reg_comp_evt_omf_tm = rfnomf->list[nidx ].reg_comp_evt_omf_tm
     SET rmodomf->list[nmodcnt ].dispo_req_evt_dt_tm = rfnomf->list[nidx ].dispo_req_evt_dt_tm
     SET rmodomf->list[nmodcnt ].dispo_req_evt_omf_dt = rfnomf->list[nidx ].dispo_req_evt_omf_dt
     SET rmodomf->list[nmodcnt ].dispo_req_evt_omf_tm = rfnomf->list[nidx ].dispo_req_evt_omf_tm
     SET rmodomf->list[nmodcnt ].dispo_comp_evt_dt_tm = rfnomf->list[nidx ].dispo_comp_evt_dt_tm
     SET rmodomf->list[nmodcnt ].dispo_comp_evt_omf_dt = rfnomf->list[nidx ].dispo_comp_evt_omf_dt
     SET rmodomf->list[nmodcnt ].dispo_comp_evt_omf_tm = rfnomf->list[nidx ].dispo_comp_evt_omf_tm
     SET rmodomf->list[nmodcnt ].active_ind = rfnomf->list[nidx ].active_ind
     SET rmodomf->list[nmodcnt ].disch_diag = trim (substring (1 ,250 ,rfnomf->list[nidx ].disch_diag
        ) )
    ENDIF
   ENDFOR
   SET stat = alterlist (rnewomf->list ,nnewcnt )
   SET stat = alterlist (rmodomf->list ,nmodcnt )
  ENDIF
 END ;Subroutine
 SUBROUTINE  addrecords (null )
  CALL echo (build ("Add Records" ) )
  INSERT FROM (fn_omf_encntr foe ),
    (dummyt d WITH seq = value (nnewcnt ) )
   SET foe.fn_omf_encntr_id = seq (tracking_seq ,nextval ) ,
    foe.tracking_group_cd = rnewomf->list[d.seq ].tracking_group_cd ,
    foe.tracking_id = rnewomf->list[d.seq ].tracking_id ,
    foe.encntr_id = rnewomf->list[d.seq ].encntr_id ,
    foe.person_id = rnewomf->list[d.seq ].person_id ,
    foe.checkin_acuity_id = rnewomf->list[d.seq ].checkin_acuity_id ,
    foe.checkout_acuity_id = rnewomf->list[d.seq ].checkout_acuity_id ,
    foe.primary_care_physician_id = rnewomf->list[d.seq ].primary_care_physician_id ,
    foe.primary_doc_id = rnewomf->list[d.seq ].primary_doc_id ,
    foe.secondary_doc_id = rnewomf->list[d.seq ].secondary_doc_id ,
    foe.primary_nurse_id = rnewomf->list[d.seq ].primary_nurse_id ,
    foe.secondary_nurse_id = rnewomf->list[d.seq ].secondary_nurse_id ,
    foe.disch_diag = rnewomf->list[d.seq ].disch_diag ,
    foe.specialty_id = rnewomf->list[d.seq ].specialty_id ,
    foe.loc_building_cd = rnewomf->list[d.seq ].loc_building_cd ,
    foe.loc_facility_cd = rnewomf->list[d.seq ].loc_facility_cd ,
    foe.loc_ambulatory_unit_cd = rnewomf->list[d.seq ].loc_ambulatory_unit_cd ,
    foe.loc_nurse_unit_cd = rnewomf->list[d.seq ].loc_nurse_unit_cd ,
    foe.loc_nurse_unit_grp = rnewomf->list[d.seq ].loc_nurse_unit_grp ,
    foe.loc_room_cd = rnewomf->list[d.seq ].loc_room_cd ,
    foe.loc_room_grp = rnewomf->list[d.seq ].loc_room_grp ,
    foe.loc_bed_cd = rnewomf->list[d.seq ].loc_bed_cd ,
    foe.loc_bed_grp = rnewomf->list[d.seq ].loc_bed_grp ,
    foe.checkin_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].checkin_dt_tm ) ,
    foe.checkin_omf_dt = rnewomf->list[d.seq ].checkin_omf_dt ,
    foe.checkin_omf_tm = rnewomf->list[d.seq ].checkin_omf_tm ,
    foe.checkout_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].checkout_dt_tm ) ,
    foe.checkout_omf_dt = rnewomf->list[d.seq ].checkout_omf_dt ,
    foe.checkout_omf_tm = rnewomf->list[d.seq ].checkout_omf_tm ,
    foe.arrive_req_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].arrive_req_evt_dt_tm ) ,
    foe.arrive_req_evt_omf_dt = rnewomf->list[d.seq ].arrive_req_evt_omf_dt ,
    foe.arrive_req_evt_omf_tm = rnewomf->list[d.seq ].arrive_req_evt_omf_tm ,
    foe.triage_comp_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].triage_comp_evt_dt_tm ) ,
    foe.triage_comp_evt_omf_dt = rnewomf->list[d.seq ].triage_comp_evt_omf_dt ,
    foe.triage_comp_evt_omf_tm = rnewomf->list[d.seq ].triage_comp_evt_omf_tm ,
    foe.bed_assign_comp_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].bed_assign_comp_evt_dt_tm ) ,
    foe.bed_assign_comp_evt_omf_dt = rnewomf->list[d.seq ].bed_assign_comp_evt_omf_dt ,
    foe.bed_assign_comp_evt_omf_tm = rnewomf->list[d.seq ].bed_assign_comp_evt_omf_tm ,
    foe.rn_assess_start_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].rn_assess_start_evt_dt_tm ) ,
    foe.rn_assess_start_evt_omf_dt = rnewomf->list[d.seq ].rn_assess_start_evt_omf_dt ,
    foe.rn_assess_start_evt_omf_tm = rnewomf->list[d.seq ].rn_assess_start_evt_omf_tm ,
    foe.md_assess_start_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].md_assess_start_evt_dt_tm ) ,
    foe.md_assess_start_evt_omf_dt = rnewomf->list[d.seq ].md_assess_start_evt_omf_dt ,
    foe.md_assess_start_evt_omf_tm = rnewomf->list[d.seq ].md_assess_start_evt_omf_tm ,
    foe.reg_comp_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].reg_comp_evt_dt_tm ) ,
    foe.reg_comp_evt_omf_dt = rnewomf->list[d.seq ].reg_comp_evt_omf_dt ,
    foe.reg_comp_evt_omf_tm = rnewomf->list[d.seq ].reg_comp_evt_omf_tm ,
    foe.dispo_req_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].dispo_req_evt_dt_tm ) ,
    foe.dispo_req_evt_omf_dt = rnewomf->list[d.seq ].dispo_req_evt_omf_dt ,
    foe.dispo_req_evt_omf_tm = rnewomf->list[d.seq ].dispo_req_evt_omf_tm ,
    foe.dispo_comp_evt_dt_tm = cnvtdatetime (rnewomf->list[d.seq ].dispo_comp_evt_dt_tm ) ,
    foe.dispo_comp_evt_omf_dt = rnewomf->list[d.seq ].dispo_comp_evt_omf_dt ,
    foe.dispo_comp_evt_omf_tm = rnewomf->list[d.seq ].dispo_comp_evt_omf_tm ,
    foe.active_ind = rnewomf->list[d.seq ].active_ind ,
    foe.updt_id = reqinfo->updt_id ,
    foe.updt_task = reqinfo->updt_task ,
    foe.updt_applctx = reqinfo->updt_applctx ,
    foe.updt_cnt = 0 ,
    foe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 )
   PLAN (d )
    JOIN (foe )
   WITH nocounter ,maxcommit = 500 ,check
  ;end insert
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  updaterecords (null )
  CALL echo (build ("Update Records" ) )
  UPDATE FROM (fn_omf_encntr foe ),
    (dummyt d WITH seq = value (nmodcnt ) )
   SET foe.tracking_group_cd = rmodomf->list[d.seq ].tracking_group_cd ,
    foe.tracking_id = rmodomf->list[d.seq ].tracking_id ,
    foe.encntr_id = rmodomf->list[d.seq ].encntr_id ,
    foe.person_id = rmodomf->list[d.seq ].person_id ,
    foe.checkin_acuity_id = rmodomf->list[d.seq ].checkin_acuity_id ,
    foe.checkout_acuity_id = rmodomf->list[d.seq ].checkout_acuity_id ,
    foe.primary_care_physician_id = rmodomf->list[d.seq ].primary_care_physician_id ,
    foe.primary_doc_id = rmodomf->list[d.seq ].primary_doc_id ,
    foe.secondary_doc_id = rmodomf->list[d.seq ].secondary_doc_id ,
    foe.primary_nurse_id = rmodomf->list[d.seq ].primary_nurse_id ,
    foe.secondary_nurse_id = rmodomf->list[d.seq ].secondary_nurse_id ,
    foe.disch_diag = rmodomf->list[d.seq ].disch_diag ,
    foe.specialty_id = rmodomf->list[d.seq ].specialty_id ,
    foe.loc_building_cd = rmodomf->list[d.seq ].loc_building_cd ,
    foe.loc_facility_cd = rmodomf->list[d.seq ].loc_facility_cd ,
    foe.loc_ambulatory_unit_cd = rmodomf->list[d.seq ].loc_ambulatory_unit_cd ,
    foe.loc_nurse_unit_cd = rmodomf->list[d.seq ].loc_nurse_unit_cd ,
    foe.loc_nurse_unit_grp = rmodomf->list[d.seq ].loc_nurse_unit_grp ,
    foe.loc_room_cd = rmodomf->list[d.seq ].loc_room_cd ,
    foe.loc_room_grp = rmodomf->list[d.seq ].loc_room_grp ,
    foe.loc_bed_cd = rmodomf->list[d.seq ].loc_bed_cd ,
    foe.loc_bed_grp = rmodomf->list[d.seq ].loc_bed_grp ,
    foe.checkin_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].checkin_dt_tm ) ,
    foe.checkin_omf_dt = rmodomf->list[d.seq ].checkin_omf_dt ,
    foe.checkin_omf_tm = rmodomf->list[d.seq ].checkin_omf_tm ,
    foe.checkout_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].checkout_dt_tm ) ,
    foe.checkout_omf_dt = rmodomf->list[d.seq ].checkout_omf_dt ,
    foe.checkout_omf_tm = rmodomf->list[d.seq ].checkout_omf_tm ,
    foe.arrive_req_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].arrive_req_evt_dt_tm ) ,
    foe.arrive_req_evt_omf_dt = rmodomf->list[d.seq ].arrive_req_evt_omf_dt ,
    foe.arrive_req_evt_omf_tm = rmodomf->list[d.seq ].arrive_req_evt_omf_tm ,
    foe.triage_comp_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].triage_comp_evt_dt_tm ) ,
    foe.triage_comp_evt_omf_dt = rmodomf->list[d.seq ].triage_comp_evt_omf_dt ,
    foe.triage_comp_evt_omf_tm = rmodomf->list[d.seq ].triage_comp_evt_omf_tm ,
    foe.bed_assign_comp_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].bed_assign_comp_evt_dt_tm ) ,
    foe.bed_assign_comp_evt_omf_dt = rmodomf->list[d.seq ].bed_assign_comp_evt_omf_dt ,
    foe.bed_assign_comp_evt_omf_tm = rmodomf->list[d.seq ].bed_assign_comp_evt_omf_tm ,
    foe.rn_assess_start_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].rn_assess_start_evt_dt_tm ) ,
    foe.rn_assess_start_evt_omf_dt = rmodomf->list[d.seq ].rn_assess_start_evt_omf_dt ,
    foe.rn_assess_start_evt_omf_tm = rmodomf->list[d.seq ].rn_assess_start_evt_omf_tm ,
    foe.md_assess_start_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].md_assess_start_evt_dt_tm ) ,
    foe.md_assess_start_evt_omf_dt = rmodomf->list[d.seq ].md_assess_start_evt_omf_dt ,
    foe.md_assess_start_evt_omf_tm = rmodomf->list[d.seq ].md_assess_start_evt_omf_tm ,
    foe.reg_comp_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].reg_comp_evt_dt_tm ) ,
    foe.reg_comp_evt_omf_dt = rmodomf->list[d.seq ].reg_comp_evt_omf_dt ,
    foe.reg_comp_evt_omf_tm = rmodomf->list[d.seq ].reg_comp_evt_omf_tm ,
    foe.dispo_req_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].dispo_req_evt_dt_tm ) ,
    foe.dispo_req_evt_omf_dt = rmodomf->list[d.seq ].dispo_req_evt_omf_dt ,
    foe.dispo_req_evt_omf_tm = rmodomf->list[d.seq ].dispo_req_evt_omf_tm ,
    foe.dispo_comp_evt_dt_tm = cnvtdatetime (rmodomf->list[d.seq ].dispo_comp_evt_dt_tm ) ,
    foe.dispo_comp_evt_omf_dt = rmodomf->list[d.seq ].dispo_comp_evt_omf_dt ,
    foe.dispo_comp_evt_omf_tm = rmodomf->list[d.seq ].dispo_comp_evt_omf_tm ,
    foe.active_ind = rmodomf->list[d.seq ].active_ind ,
    foe.updt_id = reqinfo->updt_id ,
    foe.updt_task = reqinfo->updt_task ,
    foe.updt_applctx = reqinfo->updt_applctx ,
    foe.updt_cnt = (foe.updt_cnt + 1 ) ,
    foe.updt_dt_tm = cnvtdatetime (curdate ,curtime3 )
   PLAN (d )
    JOIN (foe
    WHERE (foe.fn_omf_encntr_id = rmodomf->list[d.seq ].fn_omf_encntr_id ) )
   WITH nocounter ,maxcommit = 500 ,check
  ;end update
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 END ;Subroutine
 
 
 call echo(build2("starting script declarations"))
 
 DECLARE event_count = i4 WITH public ,constant (15 )
 SET stat = alterlist (revent->list ,event_count )
 DECLARE arrive_evt = i4 WITH public ,constant (1 )
 DECLARE bed_assign_evt = i4 WITH public ,constant (2 )
 DECLARE md_assess_evt = i4 WITH public ,constant (3 )
 DECLARE reg_evt = i4 WITH public ,constant (4 )
 DECLARE rn_assess_evt = i4 WITH public ,constant (5 )
 DECLARE triage_evt = i4 WITH public ,constant (6 )
 DECLARE nurse_evt = i4 WITH public ,constant (7 )
 DECLARE dispo_evt = i4 WITH public ,constant (8 )
 DECLARE discharge_evt = i4 WITH public ,constant (9 )
 DECLARE inbedrequest_evt = i4 WITH public ,constant (10 )
 DECLARE inbedassign_evt = i4 WITH public ,constant (11 )
 DECLARE inbedready_evt = i4 WITH public ,constant (12 )
 DECLARE transfer_evt = i4 WITH public ,constant (13 )
 DECLARE admit_evt = i4 WITH public ,constant (14 )
 DECLARE obs_evt = i4 WITH public ,constant (15 )
 SET revent->list[arrive_evt ].cdf_str = "ARRIVE"
 SET revent->list[bed_assign_evt ].cdf_str = "BEDASSIGN"
 SET revent->list[md_assess_evt ].cdf_str = "DOCTORSEE"
 SET revent->list[reg_evt ].cdf_str = "REGSTAT"
 SET revent->list[rn_assess_evt ].cdf_str = "NURSESEE"
 SET revent->list[triage_evt ].cdf_str = "TRIAGE"
 SET revent->list[nurse_evt ].cdf_str = "NURSE"
 SET revent->list[dispo_evt ].cdf_str = "CAREALL"
 SET revent->list[discharge_evt ].cdf_str = "DISCHARGE"
 SET revent->list[inbedrequest_evt ].cdf_str = "INBEDREQUEST"
 SET revent->list[inbedassign_evt ].cdf_str = "INBEDASSIGN"
 SET revent->list[inbedready_evt ].cdf_str = "INBEDREADY"
 SET revent->list[transfer_evt ].cdf_str = "TRANSFER"
 SET revent->list[admit_evt ].cdf_str = "ADMIT"
 SET revent->list[obs_evt ].cdf_str = "OBS"
 FOR (nidx = 1 TO event_count )
  SET stat = uar_get_meaning_by_codeset (6200 ,revent->list[nidx ].cdf_str ,1 ,revent->list[nidx ].
   event_code )
 ENDFOR
 call echo(build2("finsihed finding r revents, displaying"))
 CALL echorecord (revent )
 
 call echo(build2("determining dates"))
 IF ((request->batch_selection = null ) )
  SET v_start_date = 0.0
 ELSE
  SET v_start_date = cnvtdatetime (request->batch_selection )
 ENDIF
 IF ((request->output_dist = null ) )
  SET v_end_date = cnvtdatetime (curdate ,curtime3 )
 ELSE
  SET v_end_date = cnvtdatetime (request->output_dist )
 ENDIF
 CALL echo (build ("v_start_date > " ,format (v_start_date ,"@LONGDATETIME" ) ) )
 CALL echo (build ("v_end_date > " ,format (v_end_date ,"@LONGDATETIME" ) ) )
 IF ((v_start_date = 0.0 ) AND (stat = 0 ) )
  call echo(build2("determining dates from previous ops run"))
  SELECT INTO "nl:"
   FROM (ops2_step_template ost ),
    (ops2_job oj ),
    (ops2_sched_job osj )
   PLAN (ost
    WHERE (ost.request_nbr = fn_omf_pop_req_num )
    AND (ost.active_ind = 1 )
    AND (ost.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ost.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (oj
    WHERE (oj.ops2_job_template_id = (ost.ops2_job_template_id + 0 ) )
    AND (oj.active_ind = 1 )
    AND (oj.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (oj.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
    JOIN (osj
    WHERE (osj.ops2_job_id = (oj.ops2_job_id + 0 ) )
    AND ((osj.status_cd + 0 ) = status_complete_cd )
    AND ((osj.active_ind + 0 ) = 1 )
    AND ((osj.actual_end_dt_tm + 0 ) < cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY osj.actual_end_dt_tm
   HEAD osj.actual_end_dt_tm
    v_start_date = cnvtdatetime (osj.actual_start_dt_tm )
   WITH nocounter ,check ,rdbrange
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname =
   "SELECT - date/time last successful run"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  IF ((curqual = 0 ) )
   SET v_start_date = cnvtlookbehind ("1,W" )
   SET reply->ops_event = "Date not passed and last complete not found."
  ENDIF
 ENDIF
 
 call echo(build2("finished dates, ",trim(reply->ops_event)))
 CALL echo (build ("v_start_date > " ,format (v_start_date ,"@LONGDATETIME" ) ) )
 CALL echo (build ("v_end_date > " ,format (v_end_date ,"@LONGDATETIME" ) ) )
 
 DECLARE item_count = i4 WITH noconstant (0 )
 DECLARE checkin_count = i4 WITH noconstant (0 )
 DECLARE batch_size = i4 WITH constant (100 )
 DECLARE lvindex = i4 WITH noconstant (0 )
 DECLARE currecord = i4 WITH noconstant (0 )
 DECLARE startposition = i4 WITH noconstant (1 )
 DECLARE location_found = i4 WITH noconstant (0 )
 DECLARE fntrack = f8 WITH private ,noconstant (curtime3 )
 
 call echo(build2("finding tracking items"))
 SELECT INTO "nl:"
  ti.tracking_id ,
  ti.updt_dt_tm
  FROM (tracking_item ti )
  WHERE (ti.updt_dt_tm >= cnvtdatetime (v_start_date ) )
  AND (ti.updt_dt_tm <= cnvtdatetime (v_end_date ) )
  AND ((ti.tracking_id + 0 ) != 0.0 )
  AND ((ti.person_id + 0 ) != 0.0 )
  AND ((ti.encntr_id + 0 ) != 0.0 )
  AND (ti.active_ind = 1 )
  ORDER BY ti.tracking_id
  DETAIL
   IF ((mod (item_count ,batch_size ) = 0 ) ) stat = alterlist (rtrack->list ,(item_count +
     batch_size ) )
   ENDIF
   ,item_count = (item_count + 1 ) ,
   rtrack->list[item_count ].tracking_id = ti.tracking_id ,
   rtrack->list[item_count ].updt_dt_tm = ti.updt_dt_tm ,
   rtrack->list[item_count ].encntr_id = ti.encntr_id ,
   rtrack->list[item_count ].person_id = ti.person_id
  WITH nocounter ,check
 ;end select
 IF ((error (serrmsg ,0 ) > 0 ) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
  SET reply->status_data.subeventstatus[1 ].operationname = "SELECT - tracking item count"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 
 CALL echo (build ("item_count > " ,item_count ) )
 CALL echo (build ("FNTrack -> " ,build2 (cnvtint ((curtime3 - fntrack ) ) ) ,"0 ms" ) )
 DECLARE fntrackingcheckin = f8 WITH private ,noconstant (curtime3 )
 
 call echo(build2("starting tracking_checkin"))
 
 IF ((item_count > 0 ) )
  SET ti_loop_count = ceil ((cnvtreal (item_count ) / batch_size ) )
  FOR (nidx = (item_count + 1 ) TO (ti_loop_count * batch_size ) )
   call echo(build2("inside tracking_checkin loop:",trim(cnvtstring(nidx))))
   SET rtrack->list[nidx ].tracking_id = rtrack->list[item_count ].tracking_id
   SET rtrack->list[nidx ].updt_dt_tm = rtrack->list[item_count ].updt_dt_tm
   SET rtrack->list[nidx ].encntr_id = rtrack->list[item_count ].encntr_id
   SET rtrack->list[nidx ].person_id = rtrack->list[item_count ].person_id
  ENDFOR
  
  call echo(build2("-->starting tracking_checkin select statement"))
  SELECT INTO "nl:"
   fn_omf_id = concat (trim (cnvtstring (tc.tracking_id ) ) ,"," ,trim (cnvtstring (tc
      .tracking_group_cd ) ) )
   FROM (tracking_checkin tc ),
    (dummyt d1 WITH seq = value (ti_loop_count ) )
   PLAN (d1 )
    JOIN (tc
    WHERE expand (idx ,(((d1.seq - 1 ) * batch_size ) + 1 ) ,(d1.seq * batch_size ) ,tc.tracking_id ,
     rtrack->list[idx ].tracking_id )
    AND ((tc.tracking_group_cd + 0 ) != 0.0 ) )
   ORDER BY tc.tracking_id ,
    fn_omf_id ,
    tc.active_ind DESC
   HEAD fn_omf_id
    lvindex = locatevalsort (currecord ,startposition ,item_count ,tc.tracking_id ,rtrack->list[
     currecord ].tracking_id ) ,
    IF ((lvindex > 0 ) )
     IF ((mod (checkin_count ,batch_size ) = 0 ) ) stat = alterlist (rfnomf->list ,(checkin_count +
       batch_size ) )
     ENDIF
     ,checkin_count = (checkin_count + 1 ) ,rfnomf->list[checkin_count ].fn_omf_id = fn_omf_id ,
     rfnomf->list[checkin_count ].tracking_id = rtrack->list[lvindex ].tracking_id ,rfnomf->list[
     checkin_count ].encntr_id = rtrack->list[lvindex ].encntr_id ,rfnomf->list[checkin_count ].
     person_id = rtrack->list[lvindex ].person_id ,rfnomf->list[checkin_count ].new_record_flag = 1 ,
     rfnomf->list[checkin_count ].active_ind = tc.active_ind ,rfnomf->list[checkin_count ].
     tracking_group_cd = tc.tracking_group_cd ,rfnomf->list[checkin_count ].checkin_acuity_id = tc
     .acuity_level_id ,rfnomf->list[checkin_count ].checkout_acuity_id = tc.acuity_level_id ,rfnomf->
     list[checkin_count ].primary_doc_id = tc.primary_doc_id ,rfnomf->list[checkin_count ].
     secondary_doc_id = tc.secondary_doc_id ,rfnomf->list[checkin_count ].primary_nurse_id = tc
     .primary_nurse_id ,rfnomf->list[checkin_count ].secondary_nurse_id = tc.secondary_nurse_id ,
     rfnomf->list[checkin_count ].checkin_dt_tm = tc.checkin_dt_tm ,
     IF ((tc.checkout_dt_tm = cnvtdatetime ("31-DEC-2100" ) ) ) rfnomf->list[checkin_count ].
      checkout_dt_tm = cnvtdatetime (curdate ,curtime3 )
     ELSE rfnomf->list[checkin_count ].checkout_dt_tm = tc.checkout_dt_tm
     ENDIF
     ,rfnomf->list[checkin_count ].specialty_id = tc.specialty_id ,rfnomf->list[checkin_count ].
     loc_nurse_unit_grp = 0 ,rfnomf->list[checkin_count ].loc_room_grp = 0 ,rfnomf->list[
     checkin_count ].loc_bed_grp = 0 ,startposition = lvindex
    ENDIF
   FOOT  fn_omf_id
    rfnomf->list[checkin_count ].checkin_omf_dt = cnvtdate (rfnomf->list[checkin_count ].
     checkin_dt_tm ) ,rfnomf->list[checkin_count ].checkin_omf_tm = (cnvtmin (cnvttime (rfnomf->list[
      checkin_count ].checkin_dt_tm ) ) + 1 ) ,rfnomf->list[checkin_count ].checkout_omf_dt =
    cnvtdate (rfnomf->list[checkin_count ].checkout_dt_tm ) ,rfnomf->list[checkin_count ].
    checkout_omf_tm = (cnvtmin (cnvttime (rfnomf->list[checkin_count ].checkout_dt_tm ) ) + 1 )
   WITH nocounter ,check
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT - active tracking checkins"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo (build ("checkin_count > " ,checkin_count ) )
 CALL echo (build ("FNTrackingCheckin -> " ,build2 (cnvtint ((curtime3 - fntrackingcheckin ) ) ) ,
   "0 ms" ) )
   
   call echo(build2("starting second tracking_checkin"))
 IF ((checkin_count > 0 ) )
  SET arr_loop_count = ceil ((cnvtreal (checkin_count ) / batch_size ) )
  FOR (nidx = (checkin_count + 1 ) TO (arr_loop_count * batch_size ) )
   call echo(build2("inside second tracking_checkin loop:",trim(cnvtstring(nidx))))
   SET rfnomf->list[nidx ].fn_omf_id = rfnomf->list[checkin_count ].fn_omf_id
   SET rfnomf->list[nidx ].tracking_id = rfnomf->list[checkin_count ].tracking_id
   SET rfnomf->list[nidx ].encntr_id = rfnomf->list[checkin_count ].encntr_id
   SET rfnomf->list[nidx ].person_id = rfnomf->list[checkin_count ].person_id
   SET rfnomf->list[nidx ].new_record_flag = rfnomf->list[checkin_count ].new_record_flag
   SET rfnomf->list[nidx ].active_ind = rfnomf->list[checkin_count ].active_ind
   SET rfnomf->list[nidx ].tracking_group_cd = rfnomf->list[checkin_count ].tracking_group_cd
   SET rfnomf->list[nidx ].checkin_acuity_id = rfnomf->list[checkin_count ].checkin_acuity_id
   SET rfnomf->list[nidx ].checkout_acuity_id = rfnomf->list[checkin_count ].checkout_acuity_id
   SET rfnomf->list[nidx ].primary_doc_id = rfnomf->list[checkin_count ].primary_doc_id
   SET rfnomf->list[nidx ].secondary_doc_id = rfnomf->list[checkin_count ].secondary_doc_id
   SET rfnomf->list[nidx ].primary_nurse_id = rfnomf->list[checkin_count ].primary_nurse_id
   SET rfnomf->list[nidx ].secondary_nurse_id = rfnomf->list[checkin_count ].secondary_nurse_id
   SET rfnomf->list[nidx ].checkin_dt_tm = rfnomf->list[checkin_count ].checkin_dt_tm
   SET rfnomf->list[nidx ].checkout_dt_tm = rfnomf->list[checkin_count ].checkout_dt_tm
   SET rfnomf->list[nidx ].specialty_id = rfnomf->list[checkin_count ].specialty_id
   SET rfnomf->list[nidx ].loc_nurse_unit_grp = rfnomf->list[checkin_count ].loc_nurse_unit_grp
   SET rfnomf->list[nidx ].loc_room_grp = rfnomf->list[checkin_count ].loc_room_grp
   SET rfnomf->list[nidx ].loc_bed_grp = rfnomf->list[checkin_count ].loc_bed_grp
   SET rfnomf->list[nidx ].checkin_omf_dt = rfnomf->list[checkin_count ].checkin_omf_dt
   SET rfnomf->list[nidx ].checkin_omf_tm = rfnomf->list[checkin_count ].checkin_omf_tm
   SET rfnomf->list[nidx ].checkout_omf_dt = rfnomf->list[checkin_count ].checkout_omf_dt
   SET rfnomf->list[nidx ].checkout_omf_tm = rfnomf->list[checkin_count ].checkout_omf_tm
  ENDFOR
  SET startposition = 1
  DECLARE fntrackingevent = f8 WITH private ,noconstant (curtime3 )
  
  call echo(build2("-->starting second tracking_checkin select statement"))
  
  SELECT INTO "nl:"
   fn_omf_id = concat (trim (cnvtstring (te.tracking_id ) ) ,"," ,trim (cnvtstring (te
      .tracking_group_cd ) ) )
   FROM (tracking_checkin tc ),
    (tracking_event te ),
    (track_event ter ),
    (dummyt d1 WITH seq = value (ti_loop_count ) )
   PLAN (d1 )
    JOIN (tc
    WHERE expand (idx ,(((d1.seq - 1 ) * batch_size ) + 1 ) ,(d1.seq * batch_size ) ,tc.tracking_id ,
     rtrack->list[idx ].tracking_id ) )
    JOIN (ter
    WHERE (ter.tracking_group_cd = tc.tracking_group_cd )
    AND expand (nidx ,1 ,event_count ,ter.event_use_mean_cd ,revent->list[nidx ].event_code ) )
    JOIN (te
    WHERE (te.tracking_id = tc.tracking_id )
    AND (te.tracking_id != 0.0 )
    AND (te.track_event_id = ter.track_event_id )
    AND ((te.active_ind + 0 ) = 1 )
    AND (te.requested_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (te.onset_dt_tm < cnvtdatetime (curdate ,curtime3 ) )
    AND (te.complete_dt_tm < cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY tc.tracking_id ,
    fn_omf_id ,
    te.track_event_id ,
    te.requested_dt_tm
   DETAIL
    lvindex = locateval (currecord ,startposition ,size (rfnomf->list ,5 ) ,fn_omf_id ,rfnomf->list[
     currecord ].fn_omf_id ) ,
    IF ((lvindex > 0 ) ) startposition = lvindex ,
     CASE (ter.event_use_mean_cd )
      OF revent->list[arrive_evt ].event_code :
       IF ((((te.complete_dt_tm < rfnomf->list[lvindex ].arrive_req_evt_dt_tm ) ) OR ((rfnomf->list[
       lvindex ].arrive_req_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].arrive_req_evt_dt_tm = te
        .requested_dt_tm
       ENDIF
      OF revent->list[triage_evt ].event_code :
      OF revent->list[nurse_evt ].event_code :
       IF ((((te.complete_dt_tm < rfnomf->list[lvindex ].triage_comp_evt_dt_tm ) ) OR ((rfnomf->list[
       lvindex ].triage_comp_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].triage_comp_evt_dt_tm =
        te.complete_dt_tm
       ENDIF
      OF revent->list[bed_assign_evt ].event_code :
       IF ((((te.complete_dt_tm < rfnomf->list[lvindex ].bed_assign_comp_evt_dt_tm ) ) OR ((rfnomf->
       list[lvindex ].bed_assign_comp_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].
        bed_assign_comp_evt_dt_tm = te.complete_dt_tm
       ENDIF
      OF revent->list[rn_assess_evt ].event_code :
       IF ((((te.onset_dt_tm < rfnomf->list[lvindex ].rn_assess_start_evt_dt_tm ) ) OR ((rfnomf->
       list[lvindex ].rn_assess_start_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].
        rn_assess_start_evt_dt_tm = te.onset_dt_tm
       ENDIF
      OF revent->list[md_assess_evt ].event_code :
       IF ((((te.onset_dt_tm < rfnomf->list[lvindex ].md_assess_start_evt_dt_tm ) ) OR ((rfnomf->
       list[lvindex ].md_assess_start_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].
        md_assess_start_evt_dt_tm = te.onset_dt_tm
       ENDIF
      OF revent->list[reg_evt ].event_code :
       IF ((((te.complete_dt_tm > rfnomf->list[lvindex ].reg_comp_evt_dt_tm ) ) OR ((rfnomf->list[
       lvindex ].reg_comp_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].reg_comp_evt_dt_tm = te
        .complete_dt_tm
       ENDIF
      OF revent->list[dispo_evt ].event_code :
      OF revent->list[discharge_evt ].event_code :
      OF revent->list[inbedrequest_evt ].event_code :
      OF revent->list[inbedassign_evt ].event_code :
      OF revent->list[inbedready_evt ].event_code :
      OF revent->list[transfer_evt ].event_code :
      OF revent->list[admit_evt ].event_code :
      OF revent->list[obs_evt ].event_code :
       IF ((((te.requested_dt_tm < rfnomf->list[lvindex ].dispo_req_evt_dt_tm ) ) OR ((rfnomf->list[
       lvindex ].dispo_req_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].dispo_req_evt_dt_tm = te
        .requested_dt_tm
       ENDIF
       ,
       IF ((((te.complete_dt_tm > rfnomf->list[lvindex ].dispo_comp_evt_dt_tm ) ) OR ((rfnomf->list[
       lvindex ].dispo_comp_evt_dt_tm = null ) )) ) rfnomf->list[lvindex ].dispo_comp_evt_dt_tm = te
        .complete_dt_tm
       ENDIF
     ENDCASE
    ENDIF
   WITH nocounter ,check ,orahintcbo ("INDEX (TER XIE1TRACK_EVENT)" ,"INDEX (TE XIE3TRACKING_EVENT)"
     )
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT - tracking events"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  CALL echo (build ("FNTrackingEvent -> " ,build2 (cnvtint ((curtime3 - fntrackingevent ) ) ) ,
    "0 ms" ) )
    
   
   call echo(build2("starting person_prsnl_reltn"))
    
  FOR (nidx = 1 TO checkin_count )
   call echo(build2("inside loop before person_prsnl_reltn:",trim(cnvtstring(nidx))))
   SET rfnomf->list[nidx ].arrive_req_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].arrive_req_evt_dt_tm
     )
   SET rfnomf->list[nidx ].arrive_req_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     arrive_req_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].triage_comp_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].
    triage_comp_evt_dt_tm )
   SET rfnomf->list[nidx ].triage_comp_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     triage_comp_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].bed_assign_comp_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].
    bed_assign_comp_evt_dt_tm )
   SET rfnomf->list[nidx ].bed_assign_comp_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     bed_assign_comp_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].rn_assess_start_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].
    rn_assess_start_evt_dt_tm )
   SET rfnomf->list[nidx ].rn_assess_start_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     rn_assess_start_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].md_assess_start_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].
    md_assess_start_evt_dt_tm )
   SET rfnomf->list[nidx ].md_assess_start_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     md_assess_start_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].reg_comp_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].reg_comp_evt_dt_tm )
   SET rfnomf->list[nidx ].reg_comp_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     reg_comp_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].dispo_req_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].dispo_req_evt_dt_tm
    )
   SET rfnomf->list[nidx ].dispo_req_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     dispo_req_evt_dt_tm ) ) + 1 )
   SET rfnomf->list[nidx ].dispo_comp_evt_omf_dt = cnvtdate (rfnomf->list[nidx ].dispo_comp_evt_dt_tm
     )
   SET rfnomf->list[nidx ].dispo_comp_evt_omf_tm = (cnvtmin (cnvttime (rfnomf->list[nidx ].
     dispo_comp_evt_dt_tm ) ) + 1 )
  ENDFOR
  DECLARE fnpersonprsnlreltn = f8 WITH private ,noconstant (curtime3 )
  
  call echo(build2("-->starting person_prsnl_reltn select statement"))
  call echo(build2("---->SKIPPING"))
  
  call echojson(rfnomf,"rfnomf.dat")
  
  /*
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (arr_loop_count ) ),
    (person_prsnl_reltn ppr )
   PLAN (d )
    JOIN (ppr
    WHERE expand (idx ,(((d.seq - 1 ) * batch_size ) + 1 ) ,(d.seq * batch_size ) ,ppr.person_id ,
     rfnomf->list[idx ].person_id )
    AND ((ppr.person_prsnl_r_cd + 0 ) = v_pcp_cd )
    AND ((ppr.active_ind + 0 ) = 1 )
    AND (ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
   ORDER BY d.seq ,
    ppr.beg_effective_dt_tm DESC ,
    ppr.person_id
   HEAD ppr.person_id
    call echo(build2("inside query:",trim(cnvtstring(ppr.person_id))))
    FOR (nidx = 1 TO checkin_count )
     call echo(build2("inside loop for:",trim(cnvtstring(ppr.person_id)),":",trim(cnvtstring(nidx))))
     IF ((rfnomf->list[nidx ].person_id = ppr.person_id ) ) rfnomf->list[nidx ].
      primary_care_physician_id = ppr.prsnl_person_id
     ENDIF
    ENDFOR
   WITH nocounter ,check
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT - PCP"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  CALL echo (build ("FNPersonPrsnlReltn -> " ,build2 (cnvtint ((curtime3 - fnpersonprsnlreltn ) ) ) ,"0 ms" ) )
   
   */ 
    
  call echo(build2("starting tracking_locator"))
  call echo(build2("-->starting tracking_locator select statement"))
    
  DECLARE fnlocation = f8 WITH private ,noconstant (curtime3 )
  SET startposition = 1
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (arr_loop_count ) ),
    (tracking_locator tl )
   PLAN (d )
    JOIN (tl
    WHERE expand (idx ,(((d.seq - 1 ) * batch_size ) + 1 ) ,(d.seq * batch_size ) ,tl.tracking_id ,
     rfnomf->list[idx ].tracking_id )
    AND ((tl.location_cd + 0 ) != 0.0 ) )
   ORDER BY tl.tracking_id ,
    tl.locator_create_date DESC
   HEAD tl.tracking_id
    lvindex = locateval (currecord ,startposition ,size (rfnomf->list ,5 ) ,tl.tracking_id ,rfnomf->
     list[currecord ].tracking_id ) ,
    IF ((lvindex > 0 ) ) startposition = lvindex
    ENDIF
    ,location_found = 0
   DETAIL
    
    IF ((lvindex > 0 ) )
     IF ((location_found = 0 ) )
      IF ((rfnomf->list[lvindex ].loc_nurse_unit_grp = 0 ) )
       IF ((uar_get_code_meaning (tl.location_cd ) != "CHECKOUT" ) )
        FOR (nidx = lvindex TO checkin_count )
         call echo(build2("inside tracking_locator loop for:",trim(cnvtstring(nidx)),":",trim(cnvtstring(checkin_count))))
         IF ((rfnomf->list[nidx ].tracking_id = rfnomf->list[lvindex ].tracking_id ) ) rfnomf->list[
          nidx ].loc_ambulatory_unit_cd = tl.loc_nurse_unit_cd ,rfnomf->list[nidx ].loc_nurse_unit_cd
           = tl.loc_nurse_unit_cd ,
          IF ((tl.loc_nurse_unit_cd != 0.0 ) ) rfnomf->list[nidx ].loc_nurse_unit_grp = 1
          ELSE rfnomf->list[nidx ].loc_nurse_unit_grp = 0
          ENDIF
          ,rfnomf->list[nidx ].loc_room_cd = tl.loc_room_cd ,
          IF ((tl.loc_room_cd != 0.0 ) ) rfnomf->list[nidx ].loc_room_grp = 1
          ELSE rfnomf->list[nidx ].loc_room_grp = 0
          ENDIF
          ,rfnomf->list[nidx ].loc_bed_cd = tl.loc_bed_cd ,
          IF ((tl.loc_bed_cd != 0.0 ) ) rfnomf->list[nidx ].loc_bed_grp = 1
          ELSE rfnomf->list[nidx ].loc_bed_grp = 0
          ENDIF
         ELSE nidx = checkin_count
         ENDIF
        ENDFOR
        ,location_found = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,check
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT - Last location"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  CALL echo (build ("FNLocation -> " ,build2 (cnvtint ((curtime3 - fnlocation ) ) ) ,"0 ms" ) )
  DECLARE fnnurseunit = f8 WITH private ,noconstant (curtime3 )
  
  call echo(build2("starting nurse_unit"))
  call echo(build2("-->starting nurse_unit select statement"))
  
  SET startposition = 1
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (arr_loop_count ) ),
    (nurse_unit nu )
   PLAN (d )
    JOIN (nu
    WHERE expand (idx ,(((d.seq - 1 ) * batch_size ) + 1 ) ,(d.seq * batch_size ) ,nu.location_cd ,
     rfnomf->list[idx ].loc_ambulatory_unit_cd )
    AND ((nu.location_cd + 0 ) != 0 ) )
   ORDER BY nu.location_cd
   HEAD nu.location_cd
    FOR (nidx = 1 TO checkin_count )
     ;call echo(build2("inside nurse_unit loop for:",trim(cnvtstring(nu.location_cd))
     ;,":",trim(cnvtstring(nidx)),":",trim(cnvtstring(checkin_count))))
     IF ((rfnomf->list[nidx ].loc_ambulatory_unit_cd = nu.location_cd ) ) rfnomf->list[nidx ].
      loc_facility_cd = nu.loc_facility_cd ,rfnomf->list[nidx ].loc_building_cd = nu.loc_building_cd
     ENDIF
    ENDFOR
   WITH nocounter ,check
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname =
   "SELECT - find facility and building cd"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  CALL echo (build ("FNNurseUnit -> " ,build2 (cnvtint ((curtime3 - fnnurseunit ) ) ) ,"0 ms" ) )
  
  
  call echo(build2("starting fn_omf_encntr"))
  call echo(build2("-->starting fn_omf_encntr select statement"))
  
  DECLARE fnomfencounter = f8 WITH private ,noconstant (curtime3 )
  SET startposition = 1
  SELECT INTO "nl:"
   fn_omf_id = concat (trim (cnvtstring (foe.tracking_id ) ) ,"," ,trim (cnvtstring (foe
      .tracking_group_cd ) ) )
   FROM (dummyt d WITH seq = value (arr_loop_count ) ),
    (fn_omf_encntr foe )
   PLAN (d )
    JOIN (foe
    WHERE expand (idx ,(((d.seq - 1 ) * batch_size ) + 1 ) ,(d.seq * batch_size ) ,foe.tracking_id ,
     rfnomf->list[idx ].tracking_id ,foe.tracking_group_cd ,rfnomf->list[idx ].tracking_group_cd ) )
   ORDER BY foe.tracking_id ,
    fn_omf_id
   DETAIL
    lvindex = locateval (currecord ,startposition ,size (rfnomf->list ,5 ) ,fn_omf_id ,rfnomf->list[
     currecord ].fn_omf_id ) ,
    IF ((lvindex > 0 ) ) startposition = lvindex ,rfnomf->list[lvindex ].new_record_flag = 0 ,rfnomf
     ->list[lvindex ].fn_omf_encntr_id = foe.fn_omf_encntr_id
    ENDIF
   WITH nocounter ,check
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT - set new_record flag"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  CALL echo (build ("FNOMFEncounter -> " ,build2 (cnvtint ((curtime3 - fnomfencounter ) ) ) ,"0 ms"
    ) )
    
    
  call echo(build2("starting diagnosis"))
  call echo(build2("-->starting diagnosis select statement"))
    
  DECLARE fnomfdiagnosis = f8 WITH private ,noconstant (curtime3 )
  DECLARE discharge_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,17 ,"DISCHARGE" ) )
  DECLARE active_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
  SELECT INTO "nl:"
   FROM (diagnosis dx ),
    (dummyt d1 WITH seq = value (arr_loop_count ) )
   PLAN (d1 )
    JOIN (dx
    WHERE expand (idx ,(((d1.seq - 1 ) * batch_size ) + 1 ) ,(d1.seq * batch_size ) ,dx.encntr_id ,
     rfnomf->list[idx ].encntr_id )
    AND (dx.diag_type_cd = discharge_cd )
    AND (dx.active_ind = 1 )
    AND (dx.active_status_cd = active_cd ) )
   DETAIL
    lvindex = locateval (currecord ,1 ,checkin_count ,dx.encntr_id ,rfnomf->list[currecord ].
     encntr_id ) ,
    WHILE ((lvindex > 0 ) )
     call echo(build2("inside diagnosis loop for:",trim(cnvtstring(lvindex)),":",trim(cnvtstring(checkin_count))))
     IF ((rfnomf->list[lvindex ].disch_diag = "" ) ) rfnomf->list[lvindex ].disch_diag = trim (dx
       .diagnosis_display )
     ELSE rfnomf->list[lvindex ].disch_diag = concat (rfnomf->list[lvindex ].disch_diag ,";" ,trim (
        dx.diagnosis_display ) )
     ENDIF
     ,lvindex = locateval (currecord ,(lvindex + 1 ) ,checkin_count ,dx.encntr_id ,rfnomf->list[
      currecord ].encntr_id )
    ENDWHILE
   WITH nocounter
  ;end select
  IF ((error (serrmsg ,0 ) > 0 ) )
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
   SET reply->status_data.subeventstatus[1 ].operationname = "SELECT DIAGNOSIS"
   SET reply->status_data.subeventstatus[1 ].targetobjectname = "fn_omf_encntr"
   SET reply->status_data.subeventstatus[1 ].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  CALL echo (build ("FNOMFDiagnosis -> " ,build2 (cnvtint ((curtime3 - fnomfdiagnosis ) ) ) ,"0 ms"
    ) )
  SET stat = alterlist (rfnomf->list ,checkin_count )
  
  call echo(build2("calling populatelists()"))
  CALL populatelists (null )
  
  
  CALL echo (build ("batch_selection > " ,request->batch_selection ) )
  CALL echo (build ("checkin_count > " ,checkin_count ) )
  CALL echo (build ("nNewCnt > " ,nnewcnt ) )
  CALL echo (build ("nModCnt > " ,nmodcnt ) )
  DECLARE fninsert = f8 WITH private ,noconstant (curtime3 )
  IF ((nnewcnt > 0 ) )
   ;CALL addrecords (null )
   set stat = 0
  ENDIF
  CALL echo (build ("FNInsert -> " ,build2 (cnvtint ((curtime3 - fninsert ) ) ) ,"0 ms" ) )
  DECLARE fnmodify = f8 WITH private ,noconstant (curtime3 )
  IF ((nmodcnt > 0 ) )
   ;CALL updaterecords (null )
   set stat = 0
  ENDIF
  CALL echo (build ("FNModify -> " ,build2 (cnvtint ((curtime3 - fnmodify ) ) ) ,"0 ms" ) )
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status = "S" ) )
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE SET rfnomf
 FREE SET revent
 FREE SET rtrack
 FREE SET rnewomf
 FREE SET rmodomf
 CALL echo (build ("FNComplete -> " ,build2 (cnvtint ((curtime3 - fncomplete ) ) ) ,"0 ms" ) )
END GO

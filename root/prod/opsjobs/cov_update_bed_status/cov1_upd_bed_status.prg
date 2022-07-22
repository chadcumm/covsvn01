drop program cov1_upd_bed_status go
create program cov1_upd_bed_status
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare AVAILABLE_VAR = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!11813")),protect
declare ASSIGNED_VAR = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!10128")),protect
declare DISCHARGE_VAR = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!17019")),protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Update the bed to available where it isn't available and the account is dischaged
update into bed
set bed_status_cd = AVAILABLE_VAR,
updt_dt_tm = cnvtdatetime(curdate,curtime3),
updt_id = reqinfo->updt_id,
updt_task = 2241
where bed_status_cd != AVAILABLE_VAR
and active_ind = 1
and end_effective_dt_tm > sysdate
and location_cd in (select e.loc_bed_cd
					from encounter e
					where e.disch_dt_tm !=null
						and e.active_ind = 1
						and e.encntr_status_cd = DISCHARGE_VAR
						and e.loc_bed_cd !=0
						)
and location_cd not in (
	select e2.loc_bed_cd from encounter e2
	where e2.active_ind = 1
	and e2.loc_bed_cd !=0
	and e2.loc_nurse_unit_cd in (
		select code_value from code_value
		where code_set = 220
		and active_ind = 1
		and cdf_meaning = "AMBULATORY"
		and end_effective_dt_tm > sysdate
		and display = "*ED"))
 
;Update the bed to assigned when it isn't already assigned and the account is not discharged
update into bed
set bed_status_cd = ASSIGNED_VAR,
updt_dt_tm = cnvtdatetime(curdate,curtime3),
updt_id = reqinfo->updt_id,
updt_task = 2241
where bed_status_cd != ASSIGNED_VAR
and active_ind = 1
and end_effective_dt_tm > sysdate
and location_cd in (select e.loc_bed_cd
					from encounter e
					where e.disch_dt_tm =null
						and e.active_ind = 1
						and e.encntr_status_cd != DISCHARGE_VAR
						and e.loc_bed_cd !=0)
and location_cd not in (
	select e2.loc_bed_cd from encounter e2
	where e2.active_ind = 1
	and e2.loc_bed_cd !=0
	and e2.loc_nurse_unit_cd in (
		select code_value from code_value
		where code_set = 220
		and active_ind = 1
		and cdf_meaning = "AMBULATORY"
		and end_effective_dt_tm > sysdate
		and display = "*ED"))
 
update into bed
set bed_status_cd = AVAILABLE_VAR,
updt_dt_tm = cnvtdatetime(curdate,curtime3),
updt_id = reqinfo->updt_id,
updt_task = 2241
where bed_status_cd != AVAILABLE_VAR
and location_cd not in (select loc_bed_cd from encounter where disch_dt_tm = null)
and location_cd not in (
	select e2.loc_bed_cd from encounter e2
	where e2.active_ind = 1
	and e2.loc_bed_cd !=0
	and e2.loc_nurse_unit_cd in (
		select code_value from code_value
		where code_set = 220
		and active_ind = 1
		and cdf_meaning = "AMBULATORY"
		and end_effective_dt_tm > sysdate
		and display = "*ED"))
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
commit
end
go
 

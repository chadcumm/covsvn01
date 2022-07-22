/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/24/2021
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_Update_Bed_Status.prg
	Object name:		cov_Update_Bed_Status
	Request #:			
 
	Program purpose:	Maintains bed status availability due to data not
						updating properly after patients are moved out of beds.
 
	Executing from:		Olympus
 
 	Special Notes:		Original CCL (cov1_upd_bed_status) written by 
 						Cerner consulting.						
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_Update_Bed_Status:dba go
create program cov_Update_Bed_Status:dba
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare available_var	= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!11813")), protect
declare assigned_var	= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!10128")), protect
declare discharge_var	= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!17019")), protect
 

/**************************************************************
; DVDev Start Coding
**************************************************************/

free record data
record data (
	1 cnt					= i4
	1 qual [*]
		2 location_cd		= f8
)

		
/**************************************************************/
; select beds where not available and accounts are dischaged
set data->cnt = 0

call alterlist(data->qual, 0)
	
select into "nl:"
from 
	BED b
where 
	b.bed_status_cd != available_var
	and b.active_ind = 1
	and b.end_effective_dt_tm > sysdate
	and b.location_cd in (
		select e.loc_bed_cd
		from ENCOUNTER e
		where 
			e.disch_dt_tm != null
			and e.active_ind = 1
			and e.encntr_status_cd = discharge_var
			and e.loc_bed_cd != 0
		group by
			e.loc_bed_cd
	)
	and b.location_cd not in (
		select e2.loc_bed_cd 
		from ENCOUNTER e2
		where 
			e2.active_ind = 1
			and e2.loc_bed_cd != 0
			and e2.loc_nurse_unit_cd in (
				select cv.code_value 
				from CODE_VALUE cv
				where 
					cv.code_set = 220
					and cv.active_ind = 1
					and cv.cdf_meaning = "AMBULATORY"
					and cv.end_effective_dt_tm > sysdate
					and cv.display = "*ED"
			)
		group by
			e2.loc_bed_cd
	)
	
; populate record structure
head report
	cnt = 0
	
detail
	cnt += 1
	
	call alterlist(data->qual, cnt)
	
	data->cnt						= cnt
	data->qual[cnt].location_cd		= b.location_cd
	
with nocounter

call echorecord(data)
	

/**************************************************************/
; update beds to available
set i = 0

for (i = 1 to data->cnt)
	call echo(build2(i, ": update bed: ", data->qual[i].location_cd))
	
	update into BED
	set 
		bed_status_cd	= available_var,
		updt_dt_tm		= cnvtdatetime(curdate,curtime3),
		updt_id			= reqinfo->updt_id,
		updt_task		= 2241
	where 
		location_cd = data->qual[i].location_cd
		
	with nocounter
	
	commit 
endfor


/**************************************************************/
; select beds where not assigned and accounts are not discharged
set data->cnt = 0

call alterlist(data->qual, 0)
	
select into "nl:"
from
	BED b
where 
	b.bed_status_cd != assigned_var
	and b.active_ind = 1
	and b.end_effective_dt_tm > sysdate
	and b.location_cd in (
		select e.loc_bed_cd
		from ENCOUNTER e
		where 
			e.disch_dt_tm = null
			and e.active_ind = 1
			and e.encntr_status_cd != discharge_var
			and e.loc_bed_cd != 0
		group by
			e.loc_bed_cd
	)
	and b.location_cd not in (
		select e2.loc_bed_cd 
		from ENCOUNTER e2
		where 
			e2.active_ind = 1
			and e2.loc_bed_cd != 0
			and e2.loc_nurse_unit_cd in (
				select cv.code_value 
				from CODE_VALUE cv
				where 
					cv.code_set = 220
					and cv.active_ind = 1
					and cv.cdf_meaning = "AMBULATORY"
					and cv.end_effective_dt_tm > sysdate
					and cv.display = "*ED"
			)
		group by
			e2.loc_bed_cd
	)
	
; populate record structure
head report
	cnt = 0
	
	call alterlist(data->qual, cnt)
	
detail
	cnt += 1
	
	call alterlist(data->qual, cnt)
	
	data->cnt						= cnt
	data->qual[cnt].location_cd		= b.location_cd
	
with nocounter

call echorecord(data)
	

/**************************************************************/
; update beds to assigned
set i = 0

for (i = 1 to data->cnt)
	call echo(build2(i, ": update bed: ", data->qual[i].location_cd))
	
	update into BED
	set 
		bed_status_cd = assigned_var,
		updt_dt_tm = cnvtdatetime(curdate,curtime3),
		updt_id = reqinfo->updt_id,
		updt_task = 2241
	where 
		location_cd = data->qual[i].location_cd
		
	with nocounter
	
	commit 
endfor

		
/**************************************************************/
; select beds where not available for remaining accounts
set data->cnt = 0

call alterlist(data->qual, 0)
	
select into "nl:"
from 
	BED b
where 
	b.bed_status_cd != available_var
	and b.location_cd not in (
		select e.loc_bed_cd 
		from ENCOUNTER e
		where 
			e.disch_dt_tm = null
		group by
			e.loc_bed_cd
	)
	and b.location_cd not in (
		select e2.loc_bed_cd 
		from ENCOUNTER e2
		where 
			e2.active_ind = 1
			and e2.loc_bed_cd != 0
			and e2.loc_nurse_unit_cd in (
				select cv.code_value 
				from CODE_VALUE cv
				where 
					cv.code_set = 220
					and cv.active_ind = 1
					and cv.cdf_meaning = "AMBULATORY"
					and cv.end_effective_dt_tm > sysdate
					and cv.display = "*ED"
			)
		group by
			e2.loc_bed_cd
	)
	
; populate record structure
head report
	cnt = 0
	
detail
	cnt += 1
	
	call alterlist(data->qual, cnt)
	
	data->cnt						= cnt
	data->qual[cnt].location_cd		= b.location_cd
	
with nocounter

call echorecord(data)
	

/**************************************************************/
; update beds to available
set i = 0

for (i = 1 to data->cnt)
	call echo(build2(i, ": update bed: ", data->qual[i].location_cd))
	
	update into BED
	set 
		bed_status_cd	= available_var,
		updt_dt_tm		= cnvtdatetime(curdate,curtime3),
		updt_id			= reqinfo->updt_id,
		updt_task		= 2241
	where 
		location_cd = data->qual[i].location_cd
		
	with nocounter
	
	commit 
endfor

	
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

end
go
 

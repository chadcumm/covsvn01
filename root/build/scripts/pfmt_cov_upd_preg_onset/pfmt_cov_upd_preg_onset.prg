/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	01/22/2020
	Solution:				
	Source file name:	 	pfmt_cov_upd_preg_onset.prg
	Object name:		   	pfmt_cov_upd_preg_onset
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	01/20/2020  Chad Cummings			Initial Deployment
******************************************************************************/

drop program pfmt_cov_upd_preg_onset:dba go
create program pfmt_cov_upd_preg_onset:dba

free set t_rec
record t_rec
(
	1 person_id = f8
	1 problem_id = f8
	1 pregnancy_instance_id = f8
	1 pregnancy_id = f8
	1 onset_dt_tm = dq8
	1 new_onset_dt_tm = dq8
	1 begin_date = dq8
	1 end_date = dq8
	1 log_file_requestin = vc
	1 log_file_path = vc
	1 log_file = vc
	1 update_req = i2
)

set t_rec->person_id 	= requestin->request->patient_id
set t_rec->begin_date 	= datetimefind(cnvtlookbehind("0,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->end_date 	= datetimefind(cnvtlookbehind("0,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
set t_rec->log_file_requestin = build(
										 cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".log"
										)
set t_rec->log_file_path = build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
set t_rec->log_file = build(t_rec->log_file_path,t_rec->log_file_requestin)


select into "nl:"
from
	pregnancy_instance pi
	,problem p
plan pi
	where pi.person_id 	= t_rec->person_id
	and   pi.active_ind = 1
join p
	where p.problem_id = pi.problem_id
	and   p.active_ind = 1
	and   p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
detail
	t_rec->problem_id 				= p.problem_id
	t_rec->pregnancy_instance_id 	= pi.pregnancy_instance_id
	t_rec->onset_dt_tm				= p.onset_dt_tm
	t_rec->pregnancy_id 			= pi.pregnancy_id
with nocounter

set t_rec->new_onset_dt_tm = datetimeadd(t_rec->onset_dt_tm, -1)


if (cnvtdatetime(t_rec->onset_dt_tm) between cnvtdatetime(t_rec->begin_date) and cnvtdatetime(t_rec->end_date))
	set t_rec->update_req = 1
endif

if (t_rec->update_req = 0)
	go to exit_script
else
	update into problem 
	set 
		onset_dt_tm = cnvtdatetime(t_rec->new_onset_dt_tm), 
		updt_cnt 	= (updt_cnt + 1), 
		updt_id 	= reqinfo->updt_id,
		updt_dt_tm 	= cnvtdatetime(curdate,curtime3),
		updt_task   = 9999
	where 
		problem_id = t_rec->problem_id
	commit 
	
	update into pregnancy_instance
	set
		preg_start_dt_tm 	= cnvtdatetime(t_rec->new_onset_dt_tm), 
		updt_cnt 			= (updt_cnt + 1), 
		updt_id 			= reqinfo->updt_id,
		updt_dt_tm 			= cnvtdatetime(curdate,curtime3),
		updt_task   		= 9999
	where 
		pregnancy_instance_id = t_rec->pregnancy_instance_id
	commit 
endif
#exit_script

if (validate(requestin))
	call echojson(requestin,t_rec->log_file,1)
	call echorecord(requestin)
endif

if (validate(request))
	call echojson(request,t_rec->log_file,1)
	call echorecord(request)
endif

if (validate(t_rec))
	call echojson(t_rec,t_rec->log_file,1)
	call echorecord(t_rec)
endif

end go

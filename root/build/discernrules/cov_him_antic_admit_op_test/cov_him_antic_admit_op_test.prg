drop program cov_him_antic_admit_op_test go
create program cov_him_antic_admit_op_test

record EKSOPSRequest (
   1 expert_trigger	= vc
   1 qual[*]
	2 person_id	= f8
	2 sex_cd	= f8
	2 birth_dt_tm	= dq8
	2 encntr_id	= f8
	2 accession_id	= f8
	2 order_id	= f8
	2 data[*]
	     3 vc_var		= vc
	     3 double_var	= f8
	     3 long_var		= i4
	     3 short_var	= i2
)

%i cclsource:eks_rprq3091001.inc

select into "NL:"
	e.encntr_id,
	e.person_id,
	e.reg_dt_tm,
	p.birth_dt_tm,
	p.sex_cd
from
	person p,
	encounter e,
	encntr_alias ea
plan e where e.reg_dt_tm between cnvtdatetime(curdate - 30,0)
							and cnvtdatetime(curdate - 0,235959)
							and e.encntr_type_cd in(         309308.00,309312.00, 19962820.00)
join p where p.person_id= e.person_id
join ea
	where	ea.encntr_id = e.encntr_id
	and		ea.encntr_alias_type_cd	= 1077
	and		ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and		ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and     ea.active_ind = 1
head report
	cnt = 0
	EKSOPSRequest->expert_trigger = "cov_him_antic_admit_op_test"
detail
	cnt = cnt +1
	if(mod(cnt,100) = 1)
		stat = alterlist(EKSOPSRequest->qual, cnt +99)
	endif
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
	EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
	EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
	call echo(ea.alias)
foot report
	 stat = alterlist(EKSOPSRequest->qual, cnt)
with nocounter

call echorecord(EKSOPSRequest)
/*
Use the following commands to create and call the sub-routine that sends
the data in the EKSOPSRequest to the Expert Servers.
*/

%i cclsource:eks_run3091001.inc
set dparam = 0
call srvRequest(dparam)

end go

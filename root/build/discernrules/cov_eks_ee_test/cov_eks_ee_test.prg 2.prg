drop program cov_eks_ee_test go
create program cov_eks_ee_test
 
free record t_rec
record t_rec
(
	1 cnt = i2
	1 qual[*]
	 2 encntr_id = f8
)
 
select into "nl:"
from
	clinical_event ce2
	,encntr_alias ea
	,prsnl p
plan ce2
	where ce2.event_cd = 30601759
	and   ce2.result_status_cd = 24
	;and   ce2.event_start_dt_tm >= cnvtdatetime("01-NOV-2018 00:00:00")
 
/*	and   ce2.encntr_id  in(
 
select
 
	ce.encntr_id
 
from
 
	clinical_event ce
 
	where ce.event_cd in(   40129133.00, 2550908897.00, 2820708.00, 3016950.00, 3016951.00)
 
	and   ce.result_status_cd = 25
 
)
*/
join ea
	where ea.encntr_id = ce2.encntr_id
	and   ea.encntr_alias_type_cd = 1077
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id = ce2.performed_prsnl_id
order by
	ce2.encntr_id
head report
	cnt = 0
head ce2.encntr_id
	cnt = (cnt +1 )
	stat = alterlist(t_rec->qual,cnt)
	t_rec->qual[cnt].encntr_id = ce2.encntr_id
foot report
	t_rec->cnt = cnt
with nocounter
 
 
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
	(dummyt d with seq=t_rec->cnt)
plan d
join e where e.encntr_id = t_rec->qual[d.seq].encntr_id
join p where p.person_id= e.person_id
head report
	cnt = 0
	EKSOPSRequest->expert_trigger = "COV_EE_REMOTE_ANTIC"
detail
	cnt = cnt +1
	if(mod(cnt,100) = 1)
		stat = alterlist(EKSOPSRequest->qual, cnt +99)
	endif
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
	EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
	EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
 
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

drop program cov_eks_get_insurance:dba go
create program cov_eks_get_insurance:dba

free record t_rec
record t_rec
(
	1 log_message 		= vc
	1 misc1				= vc
	1 retval 			= i2
	1 continue_ind 		= i2
	1 encntr_id			= f8
	1 prim_hp			= vc
	1 sec_hp			= vc
)

set t_rec->retval 		= -1 ;initialize to failed
set t_rec->continue_ind	= 0
set t_rec->encntr_id	= link_encntrid

set t_rec->log_message = concat(trim(cnvtstring(link_encntrid)),":"trim(cnvtstring(t_rec->encntr_id)))

select into "nl:"
from 
	 encounter e
	,encntr_plan_reltn epr
 	,health_plan hp 
plan e 
	where e.encntr_id = t_rec->encntr_id
join epr 
 	where epr.encntr_id = e.encntr_id 
 	and epr.active_ind = 1 
 	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) 
 	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) 
 	and epr.priority_seq in(1,2) 
join hp 
	where hp.health_plan_id = epr.health_plan_id
	and hp.active_ind = 1 
	and hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) 
	and hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	 e.encntr_id
	,epr.priority_seq
	,epr.beg_effective_dt_tm desc
head report 
	cnt = 0
head e.encntr_id	
	cnt = 0
head epr.priority_seq
	case (epr.priority_seq)
		of 1:	t_rec->prim_hp	= hp.plan_name
		of 2:	t_rec->sec_hp	= hp.plan_name
	endcase
	t_rec->continue_ind = 1
foot repor
	cnt = 0
with nocounter

if (t_rec->continue_ind = 1)
	set t_rec->log_message  = concat(log_message,";Found HP(s)")
	set t_rec->misc1	 	= concat(trim(t_rec->prim_hp))
	if (t_rec->sec_hp > "")
		set t_rec->misc1	= concat(t_rec->misc1,";",trim(t_rec->sec_hp))
	endif
else
	set t_rec->misc1 = "No Health Plan"
endif

set t_rec->retval = 100

#exit_script
set retval		= t_rec->retval
set log_misc1 	= t_rec->misc1
set log_message = t_rec->log_message

end go


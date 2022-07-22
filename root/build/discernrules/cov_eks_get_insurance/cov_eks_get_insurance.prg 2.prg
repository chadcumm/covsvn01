drop program cov_eks_get_insurance:dba go
create program cov_eks_get_insurance:dba

free record t_rec
record t_rec
(
	1 log_message 		= vc
	1 retval 			= i2
	1 continue_ind 		= i2
	1 encntr_id			= f8
	1 prim_hp			= vc
	1 sec_hp			= vc
)

set t_rec->retval 		= -1 ;initialize to failed
set t_rec->continue_ind	= 1

set t_rec->log_message = concat(trim(cnvtstring(link_encntrid)),":")

select into "nl:"
from 
	 encounter e
	,encntr_plan_reltn epr
 	,health_plan hp 
plan e 
	where e.encntr_id = t_rec->encntr_id join epr 
 where epr.encntr_id = e.encntr_id and epr.active_ind = 1 and 
 epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and 
 epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) and
  epr.priority_seq = 1 join hp where hp.health_plan_id =
   epr.health_plan_id and hp.active_ind = 1 and 
   hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
head report log_retval = 100 detail log_misc1 = hp.plan_name with nocounter go

end go


set link_encntrid = 0.0 go
set link_personid = 0.0 go
set debug_ind = 1 go

select into "nl:"
from 
	 encntr_alias ea
	,encounter e
plan ea
	where ea.alias = "2009200043"
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
join e
	where e.encntr_id = ea.encntr_id
order by 
	 ea.beg_effective_dt_tm desc
	,e.encntr_id
head report
	stat = 0
head e.encntr_id
	link_encntrid = e.encntr_id
	link_personid = e.person_id
with nocounter go

execute cov_wh_find_appt go



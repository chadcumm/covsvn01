select *
from v500_event_code vec where vec.event_set_name = "IntraOp*"





select 
	 ea.alias
	,ce2.event_end_dt_tm ";;q"
	,ce2.event_title_text
	,uar_get_code_display(ce2.result_status_cd)
	,p.name_full_formatted
	,ce2.event_id
from
	clinical_event ce2
	,encntr_alias ea
	,prsnl p
plan ce2
	where ce2.event_cd = 2557737129
	and   ce2.result_status_cd = 24
	and   ce2.event_start_dt_tm >= cnvtdatetime("28-NOV-2018 00:00:00")
	and   ce2.encntr_id not in(
select
	ce.encntr_id
from 
	clinical_event ce
	where ce.event_cd in(   40129133.00, 2550908897.00, 2820708.00, 3016950.00, 3016951.00)
	and   ce.result_status_cd = 25
)
join ea
	where ea.encntr_id = ce2.encntr_id
	and   ea.encntr_alias_type_cd = 1077
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p	
	where p.person_id = ce2.performed_prsnl_id

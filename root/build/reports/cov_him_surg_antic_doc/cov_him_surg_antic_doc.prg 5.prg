drop program cov_him_surg_antic_doc go
create program cov_him_surg_antic_doc

select into "nl:"
	 ce.clinical_event_id
	,uar_Get_code_display(ce.event_cd)
	,uar_Get_code_display(ce.result_status_cd)
	,ce.event_title_text
	,ce.result_status_cd
	,ce.event_end_dt_tm ";;q"
	,ce.performed_prsnl_id
	,ce.encntr_id
from
	clinical_event ce
plan ce
	where ce.event_cd =  2557737129.00
	and   ce.result_status_cd not in( 29.00,30,31)
	and   ce.result_status_cd =            24.00
	;and   ce.encntr_id = 113479748   
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ce.event_end_dt_tm >= cnvtdatetime("06-JUN-2019 00:00:00")
	
end 
go
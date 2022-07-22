drop program cov_him_inprogress_notes go
create program cov_him_inprogress_notes

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


select into $OUTDEV
	 updt_position = uar_get_code_display(p1.position_cd)
	,updt_prsnl = p1.name_full_formatted
	,performed_position = uar_get_code_display(p2.position_cd)
	,performed_prsnl = p2.name_full_formatted
	,event_code=uar_get_code_display(ce.event_cd)
	;,status=uar_get_code_display(ce.result_status_cd)
	,ce.event_title_text
	,ce.performed_dt_tm ";;q"
	,entry=uar_get_code_display(ce.entry_mode_cd)
	,event_class=uar_get_code_display(ce.event_class_cd)
	,facility=uar_get_code_display(e.loc_facility_cd)
	,unit=uar_get_code_display(e.loc_nurse_unit_cd)
	,fin=ea.alias
	,ce.event_id
from	
	 clinical_event ce
	,prsnl p1
	,prsnl p2
	,encounter e
	,encntr_alias ea
plan ce	
	where ce.verified_prsnl_id = 0.0
	and   ce.result_status_cd = value(uar_get_code_by("MEANING",8,"IN PROGRESS"))
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ce.view_level = 1
	and   ce.entry_mode_cd =      677004.00
	and   ce.clinsig_updt_dt_tm >= cnvtdatetime("01-JAN-2021 00:00:00")
join p2	
	where p2.person_id = ce.performed_prsnl_id
	and   p2.person_id > 0.0
join p1	
	where p1.person_id = ce.updt_id
	and   p1.person_id > 0.0
join e	
	where e.encntr_id = ce.encntr_id
	and   e.encntr_id > 0.0
join ea	
	where ea.encntr_id = e.encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
with nocounter,format,separator=" "
end
go

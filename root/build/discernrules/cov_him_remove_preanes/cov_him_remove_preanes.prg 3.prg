drop program cov_him_remove_preanes go
create program cov_him_remove_preanes

 
free record t_rec
record t_rec
(
	1 cnt = i2
	1 qual[*]
	 2 encntr_id = f8
	 2 clinical_event_id  = f8
)

	
 
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

select into "nl:"
	 ea.alias
	,facility=uar_get_code_display(e.loc_facility_cd)
	,document=uar_get_code_display(ce.event_cd)
	,ce.event_title_text
	,ce.event_end_dt_tm ";;q"
	,ce.performed_dt_tm ";;q"
	,status = uar_get_code_display(ce.result_status_cd)
	,p1.name_full_formatted
	,position=uar_get_code_display(p1.position_cd)
	,ce.event_id
from
	clinical_event ce
	,encntr_alias ea
	,encounter e
	,prsnl p1
	,person p
plan ce
	where ce.event_cd = value(uar_get_code_by("DISPLAY",72,"PreAnesthesia Note"))
	and   ce.event_end_dt_tm <= cnvtdatetime("01-APR-2019")
	and   ce.result_status_cd = value(uar_get_code_by("MEANING",8,"IN PROGRESS"))
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
join e
	where e.encntr_id = ce.encntr_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
join p1
	where p1.person_id = ce.performed_prsnl_id
join p
	where p.person_id = e.person_id
order by
	 facility
	,ea.alias
	,ce.event_end_dt_tm
	,ce.clinical_event_id
head report
	cnt = 0
	;EKSOPSRequest->expert_trigger = "HIM_REMOVE_DOCUMENTS"
head ce.clinical_event_id
	cnt = cnt +1
	if(mod(cnt,100) = 1)
		stat = alterlist(t_rec->qual, cnt +99)
	endif
	;EKSOPSRequest->qual[cnt].person_id = p.person_id
	;EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
	;EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
	;EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
	;stat = alterlist(EKSOPSRequest->qual[cnt].data,1)
	;EKSOPSRequest->qual[cnt].data[1].double_var = ce.clinical_event_id
	t_rec->qual[cnt].event_id = ce.clinical_event_id
foot report
	 stat = alterlist(t_rec->qual, cnt)
	 t_rec->cnt = cnt
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


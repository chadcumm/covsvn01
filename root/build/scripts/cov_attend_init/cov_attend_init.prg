drop program cov_attend_init go
create program cov_attend_init


free set requestin 
record requestin
(
	1 request
	 2 n_encntr_id = f8
	 2 N_ATTEND_DOC_ID = f8
	 2 O_ATTEND_DOC_ID = f8
) 

free set t_rec 
record t_rec
(
	1 cnt = i4
	1 qual[*]
	 2 encntr_id = f8
)
; 3135284459.00
select into "nl:"
from
	encntr_domain ed
	,encounter e
plan ed
	where ed.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and   ed.encntr_id not in(
								select ce.encntr_id
								from
									clinical_event ce
								where ce.encntr_id = ed.encntr_id
								and   ce.event_cd = 3135284459
								and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
							)
	and	  ed.active_ind = 1
	join e	
		where e.encntr_id = ed.encntr_id
		and   e.encntr_type_class_cd not in(
												value(uar_get_code_by("MEANING",69,"OUTPATIENT"))
											)
		and   e.active_ind = 1
		and   e.encntr_status_cd in(
										value(uar_get_code_by("MEANING",261,"ACTIVE"))
									)	
		and   e.reg_dt_tm >= cnvtdatetime(curdate-14,0)
order by
	ed.encntr_id
head ed.encntr_id
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].encntr_id = ed.encntr_id
with nocounter

for (i=1 to t_rec->cnt)
	set stat = initrec(requestin)
	set requestin->request.n_encntr_id = t_rec->qual[i].encntr_id
	set requestin->request.O_ATTEND_DOC_ID = 1.0
	set requestin->request.N_ATTEND_DOC_ID = 2.0
	call echorecord(requestin)
	execute pfmt_cov_updt_attend
endfor

call echorecord(t_rec)


end go



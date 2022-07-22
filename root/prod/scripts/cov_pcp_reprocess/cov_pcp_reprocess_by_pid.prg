/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/20/2020
  Solution:           
  Source file name:   cov_pcp_reprocess.prg
  Object name:        cov_pcp_reprocess
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   02/20/2020  Chad Cummings			Initial Release (https://wiki.cerner.com/x/4Si_hQ)
******************************************************************************/

drop program cov_pcp_reprocess_by_pid go
create program cov_pcp_reprocess_by_pid

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "PERSON_ID" = 0 

with OUTDEV, pid


free set requestin 
record requestin
(
	1 request
	 2 n_encntr_id = f8
	 2 N_ATTEND_DOC_ID = f8
	 2 O_ATTEND_DOC_ID = f8
	 2 TRANSACTION  = vc
	 2 n_person_id = f8
) 

free set t_rec
record t_rec
(
	1 cnt = i4
	1 prompt_pid = f8
	1 qual[*]
	 2 person_id = f8
	 2 encntr_id = f8
	 2 event_id  = f8
	 2 event_prsnl = vc
	 2 event_valid_from_dt_tm = dq8
	 2 fin = vc
	 2 ppr_id = f8
	 2 ppr_prsnl = vc
	 2 ppr_beg_effective_dt_tm = dq8
	 2 comment = c50
)

set t_rec->prompt_pid = $PID

if (t_rec->prompt_pid <= 0.0)
	go to exit_script
endif

select into "nl:"
from
	 code_value cv1
	,clinical_event ce
	,encntr_alias ea
	,encounter e
	,person p
plan cv1
	where cv1.code_set = 72
	and   cv1.display in(
							"D-Primary Care Physician"
						)
	and   cv1.active_ind = 1
join ce
	where ce.event_cd = cv1.code_value
	and   ce.person_id = t_rec->prompt_pid
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
join p
	where p.person_id = ce.person_id
join e
	where e.encntr_id = ce.encntr_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	 ce.person_id
	,ce.valid_from_dt_tm desc
head report
	t_rec->cnt = 0
head ce.person_id
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)	
	t_rec->qual[t_rec->cnt].person_id = p.person_id
	t_rec->qual[t_rec->cnt].encntr_id = e.encntr_id
	t_rec->qual[t_rec->cnt].event_id = ce.event_id
	t_rec->qual[t_rec->cnt].event_valid_from_dt_tm = ce.valid_from_dt_tm
	t_rec->qual[t_rec->cnt].event_prsnl = trim(ce.result_val)
	t_rec->qual[t_rec->cnt].fin = ea.alias
with nocounter

if (t_rec->cnt > 0)
	
	select into "nl:"
	from
		(dummyt d1 with seq=t_rec->cnt)
		,person_prsnl_reltn ppr
		,prsnl p1
	plan d1
	join ppr
		where 	ppr.person_id = t_rec->qual[d1.seq].person_id
		and		ppr.person_prsnl_r_cd = value(uar_get_code_by("MEANING",331,"PCP"))
		and   	ppr.active_ind = 1
		and   	ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   	ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	join p1
		where 	p1.person_id = ppr.prsnl_person_id
	order by
		 ppr.person_id
		,ppr.beg_effective_dt_tm
	head ppr.person_id
		stat =0
	detail
		t_rec->qual[d1.seq].ppr_id = ppr.person_prsnl_reltn_id
		t_rec->qual[d1.seq].ppr_prsnl = trim(p1.name_full_formatted)
		t_rec->qual[d1.seq].ppr_beg_effective_dt_tm = ppr.beg_effective_dt_tm
	foot ppr.person_id
		if (trim(p1.name_full_formatted) != trim(t_rec->qual[d1.seq].event_prsnl))
			t_rec->qual[d1.seq].comment = "MISSMATCH"
		endif
	with nocounter
endif
call echo("calling script")
call echo(t_rec->cnt)
set j = 0
for (i=1 to t_rec->cnt)
	if (j <=500)
	if (t_rec->qual[i].comment = "MISSMATCH")
		set stat = initrec(requestin)
		;set requestin->request.n_encntr_id = t_rec->qual[i].encntr_id
		set requestin->request.n_person_id = t_rec->qual[i].person_id
		set requestin->request.TRANSACTION = "UMPI"
		
		;set requestin->request.O_ATTEND_DOC_ID = 1.0
		;set requestin->request.N_ATTEND_DOC_ID = 2.0
		call echo(build2("t_rec->qual[",trim(cnvtstring(i)),"].person_id=",t_rec->qual[i].person_id))
		call echo(build2("t_rec->qual[",trim(cnvtstring(i)),"].encntr_id=",t_rec->qual[i].encntr_id))
		call echo(build2("t_rec->qual[",trim(cnvtstring(i)),"].event_id=",t_rec->qual[i].event_id))
		call echo("pfmt_cov_updt_pcp")
		execute pfmt_cov_updt_pcp
		set j = (j + 1)
		call echo(j)
	endif
	endif
endfor

;call echorecord(t_rec)

#exit_script

end go



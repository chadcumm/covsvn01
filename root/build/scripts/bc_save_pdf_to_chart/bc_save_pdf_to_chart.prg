drop program bc_save_pdf_to_chart go
create program bc_save_pdf_to_chart

prompt 
	"ENCNTR_ID" = 0 

with ENCNTR_ID



free set t_rec 
record t_rec
(
	1 person_id = f8
	1 encntr_id = f8
	1 event_id = f8
	1 event_cd = f8
	1 ppr_cd = f8
	1 prsnl_id = f8
	1 identifier = vc
) 

select into "nl:"
	 e.person_id
	,e.encntr_id
from
	encounter e
	,person p
	,encntr_prsnl_reltn epr
plan e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
join epr
	where epr.encntr_id = outerjoin(e.encntr_id)
	and   epr.prsnl_person_id = outerjoin(t_rec->prsnl_id)
detail
	t_rec->encntr_id = e.encntr_id
	t_rec->person_id = e.person_id
	t_rec->ppr_cd = epr.encntr_prsnl_r_cd
with nocounter

free record mmf_store_reply 
record mmf_store_reply
(
   1 identifier = vc 
%i cclsource:status_block.inc
) 
 
free set mmf_store_request
record mmf_store_request
(
   1 filename = vc
   1 contentType = vc
   1 mediaType = vc
   1 name = vc
   1 personId = f8
   1 encounterId = f8
) 

end
go

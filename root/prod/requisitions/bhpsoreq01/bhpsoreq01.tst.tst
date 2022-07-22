set trace recpersist go
free set request go
record request(
    1 person_id             = f8
    1 print_prsnl_id        = f8
    1 order_dr_id			= f8
    1 order_qual[*]
        2 order_id          = f8
        2 encntr_id         = f8
        2 conversation_id   = f8
    1 printer_name          = c50
) go
 
;set request->printer_name = "cpt_b_revcycl_a_mfp" go
 
select into "nl:"
from
	orders o
	,order_action oa
plan o
	where o.order_id in(  811514281)
join oa
	where oa.order_id = o.order_id
order by
	 oa.action_dt_tm desc
	,o.order_id
head report
	cnt = 0
head o.order_id
	cnt = (cnt + 1)
	stat = alterlist(request->order_qual,cnt)
	request->print_prsnl_id 			= oa.action_personnel_id
	request->person_id 					= o.person_id
	request->order_qual[cnt]->encntr_id 	= o.encntr_id
	request->order_qual[cnt]->order_id 	= o.order_id
with nocounter go

select into "nl:"
from prsnl p where p.name_full_formatted = "ARTURI, MARIA ANN MD"
detail
request->order_dr_id = p.person_id
with nocounter

call echo(request->order_dr_id) go
 
execute bhpsoreq01:dba go
 

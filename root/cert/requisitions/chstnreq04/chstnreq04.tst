set trace recpersist go
free set request go
record request(
    1 person_id             = f8
    1 print_prsnl_id        = f8
    1 order_qual[1]
        2 order_id          = f8
        2 encntr_id         = f8
        2 conversation_id   = f8
    1 printer_name          = c50
) go
 
set request->printer_name = "cpt_b_revcycl_a_mfp" go
 
select into "nl:"
from
	orders o
	,order_action oa
plan o
	where o.order_id =  802277821
join oa
	where oa.order_id = o.order_id
order by
	 oa.action_dt_tm desc
	,o.order_id
head o.order_id
	request->print_prsnl_id 			= oa.action_personnel_id
	request->person_id 					= o.person_id
	request->order_qual[1]->encntr_id 	= o.encntr_id
	request->order_qual[1]->order_id 	= o.order_id
with nocounter go
 
execute chstnreq04:dba go
 

drop program cov_get_amb_encounter go
create program cov_get_amb_encounter 

free set t_rec
record t_rec
(
	1 log_message 		= vc
	1 misc1				= vc
	1 retval 			= i2
	1 continue_ind 		= i2
	1 encntr_id			= f8
	1 orig_encntr_id	= f8
	1 orig_encntr_type	= f8
	1 person_id			= f8

)


select into "nl:" 
from 
	orders o
	,encounter e
plan o
	where o.order_id = trigger_orderid
join e
	where e.encntr_id = o.encntr_id
detail
	t_rec->orig_encntr_id = o.originating_encntr_id
	t_rec->orig_encntr_type = e.encntr_type_cd
with nocounter

if (t_rec->orig_encntr_type = value(uar_get_code_by("DISPLAY",71,"Clinic"))
	set t_rec->encntr_id = t_rec->orig_encntr_id
else
	select into "nl:"
	from encoutner e
	with nocounter
	
endif

end 
go


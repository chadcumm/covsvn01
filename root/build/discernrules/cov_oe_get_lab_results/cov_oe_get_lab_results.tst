set link_orderid = 2001010821.00 go
set link_encntrid = 0.0 go
set link_personid = 0.0 go

select into "nl:"
from orders o
plan o
	where o.order_id = link_orderid
detail
	link_encntrid = o.encntr_id
	link_personid = o.person_id
with nocounter go


execute cov_oe_get_lab_results go
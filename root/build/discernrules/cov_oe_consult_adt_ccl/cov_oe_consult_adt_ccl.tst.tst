 
declare trigger_orderid = f8 with public  go
declare trigger_personid = f8 with public go
declare trigger_encntrid = f8 with public go
declare log_message = vc with public go

select into "nl:"
from orders o
where o.order_id = 405471453
	cnt = 0
detail
	cnt = (cnt + 1)
	trigger_orderid = o.order_id
	trigger_personid = o.person_id
	trigger_encntrid = o.encntr_id

with nocounter go
set EKMLOG_IND = 1 go
 
call echo(build("trigger_orderid=",trigger_orderid))
call echo(build("trigger_personid=",trigger_personid))
call echo(build("trigger_encntrid=",trigger_encntrid))

;set trigger_orderid = 396101003
;set trigger_personid = 16583008
;set trigger_encntrid = 110433461
;set link_personid = 16580646  go
;set link_encntrid = 110433678 go
 
set link_template = 1 go
 
;call echorecord(request) go
 
;execute cov_plan_pp_med_rec go
execute cov_oe_consult_adt_ccl:dba go
 
 

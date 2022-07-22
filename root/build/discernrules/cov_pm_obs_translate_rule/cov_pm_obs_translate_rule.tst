set retval = -1.0 go
set trigger_orderid = 0.0 go
set trigger_encntrid = 0.0 go
set trigger_personid = 0.0 go


select into "nl:"
from
	orders o
plan o
	where o.order_id = 407418881 ;obersvation order=407418881 ;
	;where o.order_id =  407418937 ;inpatient order=407418937 ; 
order by
	o.order_id
head o.order_id
	trigger_personid	= o.person_id
	trigger_encntrid 	= o.encntr_id
	trigger_orderid 	= o.order_id
with nocounter go
 execute cov_pm_obs_translate_rule "OBSERVATION_ORDER" go
 ;execute cov_pm_obs_translate_rule "INPATIENT_ORDER" go
 


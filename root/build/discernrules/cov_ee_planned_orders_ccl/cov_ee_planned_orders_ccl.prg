drop program cov_ee_planned_orders_ccl go
create program cov_ee_planned_orders_ccl

prompt 
	"Unit Name" = "" 

with UNIT_NAME

free record request 
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) 
 
Free record reply
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) 
 
set request->batch_selection = build2("cov_ops_planned_orders ",trim($UNIT_NAME))
set request->output_dist = "chad.cummings@covhlth.com" 
set request->ops_date = cnvtdatetime(curdate+0,curtime3) 
set reqinfo->updt_req = 4903 
 
execute sys_runccl

end go
 

 

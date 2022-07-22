/*
;OPERATIONS -> sys_runccl (4903)
 
free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) go
 
Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 
set request->batch_selection = "cov_rpt_op_readiness" go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go
 
execute sys_runccl go
 
call echorecord(reply) go
 


 
free record request go
record request (
  1 program_name = vc
  1 query_command = vc
  1 output_device = vc
  1 Is_printer = i1
  1 Is_Odbc = i1
  1 IsBlob = i1
  1 params = vc
  1 qual[*]
    2 parameter = vc
    2 data_type = i1
  1 blob_in = gvc
) go
 
set request->program_name = "cov_rpt_op_readiness" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go
 
execute VCCL_RUN_PROGRAM go
*/
;set debug_ind = 1 go
execute cov_rpt_op_readiness_dev 
	 "MINE"
	 , 1
	 , VALUE(2552503635.00, 21250403.00, 2552503653.00, 2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00)
	 , 1
	 , "01-JUN-2020 00:00:00"
	 , "24-JUN-2020 23:59:00"
	 , 0
go

 

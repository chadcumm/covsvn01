/*
;OPERATIONS - >sys_runccl (4903)
 
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
 
set request->batch_selection = ^temp_cov_echo_extract_sl "mine", "sysdate","sysdate", 1^ go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 3053000 go
 
execute ccl_run_program_from_ops go
 
call echorecord(reply) go
 

;1 - ccl_run_program_from_ops	cov_echo_extract_sl		No	Yes	ccl_run_program_from_ops	3053000				America/New_York	
 
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
 
set request->program_name = "cov_rad_extract_sl" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go
 
execute VCCL_RUN_PROGRAM go
*/
;execute COV_ECHO_EXTRACT_SL "MINE", "06-JUN-2020 00:00:00", "07-JUL-2020 23:59:00", 0 go
;execute COV_ECHO_EXTRACT_SL "MINE", "01-JAN-2020 00:00:00", "07-JUL-2020 23:59:00", 1 go
execute COV_ECHO_EXTRACT_SL "MINE", "10-JUL-2020 00:00:00", "12-JUL-2020 23:59:00", 1 go

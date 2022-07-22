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
 
set request->batch_selection = ^djherren_nhsnpacu "mine", 1, "Bdate", "Edate"^ go
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
 
set request->program_name = "cov2_sn_sched" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go
 
execute VCCL_RUN_PROGRAM go
*/
;"MINE", 675844.00, VALUE(25442735.00), "14-MAR-2019 00:00:00", "14-MAR-2019 23:59:00"
set debug_ind = 1 go 
;execute cov2_sn_sched 
execute cov_sn_surg_Sched:dba
;execute cov_sn_sched_driver:Dba
	"MINE", 1, 3144501.00, VALUE(2557236019.00, 2557236003.00, 2557236583.00), "05-JUN-2019 00:00:00", "05-JUN-2019 23:59:00"
	;¬"MINE", 1, 675844.00, VALUE(25442723.00), "07-MAY-2019 00:00:00", "08-MAY-2019 23:59:00"
go
 
 
 

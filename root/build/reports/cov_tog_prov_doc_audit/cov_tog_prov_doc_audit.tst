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
 
set request->batch_selection = "cov_tog_prov_doc_audit" go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go
 
execute sys_runccl go
 
call echorecord(reply) go
 
Oncology Office Visit New/Consul

 
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
 
set request->program_name = "cov_tog_prov_doc_audit" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go
 
execute VCCL_RUN_PROGRAM go
*/
 
set debug_ind = 1 go
execute cov_tog_prov_doc_audit
; "MINE", 2553766379.00, VALUE(2783164247.00), "10-AUG-2019 00:00:00", "30-SEP-2019 23:59:00"
;"MINE", 2553766379.00, VALUE(2562821711.00), "01-SEP-2019 00:00:00", "30-SEP-2019 23:59:00",0
;"MINE", VALUE(2562821711.00), "01-JUL-2019 00:00:00", "14-OCT-2019 23:59:00", 1
;"MINE", VALUE(3008076049.00), "26-AUG-2019 00:00:00", "26-SEP-2019 23:59:00", 1, 90
;"MINE", VALUE(3008076049.00), "05-AUG-2019 00:00:00", "31-OCT-2019 23:59:00", 1, 60
;"MINE", VALUE(2565870427.00), "01-MAY-2020 00:00:00", "30-MAY-2020 23:59:00", 0, 90 ;campbell
"MINE", VALUE(3082617853.00), "01-MAY-2020 00:00:00", "31-MAY-2020 23:59:00", 1, 90
go
 

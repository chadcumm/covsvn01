/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   cov_test_html.prg
  Object name:        cov_test_html
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_test_html:dba go
create program cov_test_html:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"         ;* Enter or select the printer or file name to send this report to.
	, "Backend HTML File" = "cov_html_test.html" 

with OUTDEV, FILE

 
free record t_rec
record t_rec
(
	1 file_name = vc
	1 data = vc
)

set t_rec->file_name = $FILE

free set replyOut
record replyOut(
   	1 info_line [*]
   	2 new_line = vc
)

free set getREPLY
record getREPLY (
   	1 INFO_LINE[*]
   		2 new_line               = vc
   	1 data_blob                 = gvc
   	1 data_blob_size            = i4
%i cclsource:status_block.inc
)

free set getREQUEST
record getREQUEST (
   	1 Module_Dir = vc
   	1 Module_Name = vc
    1 bAsBlob = i2
)

set getrequest->module_dir= "cust_script:"
set getrequest->Module_name = trim(t_rec->file_name)
set getrequest->bAsBlob = 1

execute eks_get_source with replace (REQUEST,getREQUEST),replace(REPLY,getREPLY)


free set putreply
record putreply (
   	1 INFO_LINE [*]
		2 new_line = vc
%i cclsource:status_block.inc
)

free set putREQUEST
record putREQUEST (
   	1 source_dir = vc
    1 source_filename = vc
    1 nbrlines = i4
    1 line [*]
		2 lineData = vc
	1 OverFlowPage [*]
		2 ofr_qual [*]
			3 ofr_line = vc
	1 IsBlob = c1
	1 document_size = i4
	1 document = gvc
)

call echo(build("t_rec->data ------------>",t_rec->data))
call echorecord(getReply)

set putRequest->source_dir = $outdev
set putRequest->IsBlob = "1"
set putRequest->document = replace(getReply->data_blob,"sXMLData",t_rec->data,0)
set putRequest->document_size = size(putRequest->document)

call echorecord(putREQUEST)
		
execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)


end 
go

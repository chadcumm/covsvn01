drop program pfmt_print_to_pdf_req_tst:dba go
create program pfmt_print_to_pdf_req_tst:dba
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Script" = "pfmt_test_s_print_to_pdf_req"
	, "Filename" = "" 

with OUTDEV, SCRIPT, FILENAME

if ($FILENAME = "")
	DECLARE FILEPATH = VC WITH CONSTANT( "CCLUSERDIR:transplant.json" ) 
else
	DECLARE FILEPATH = VC WITH CONSTANT(concat("CCLUSERDIR:",$FILENAME ) )
endif
 
free set requestin 

declare line_in = vc 

FREE DEFINE RTL3 
DEFINE RTL3 IS FILEPATH 
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter 
;call echo(line_in) go
set stat = cnvtjsontorec(line_in) 
set parser_param = concat("execute ",cnvtupper(trim($SCRIPT))," go")
call parser(parser_param)
;call echorecord(requestin) 
end go

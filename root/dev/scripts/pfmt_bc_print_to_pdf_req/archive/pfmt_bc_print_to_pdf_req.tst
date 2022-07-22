free set requestin go
DECLARE FILEPATH = VC WITH CONSTANT( "CCLUSERDIR:requestin_560201_test.dat" ) go
declare line_in = vc go

FREE DEFINE RTL3 go
DEFINE RTL3 IS FILEPATH go
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter go
;call echo(line_in) go
set stat = cnvtjsontorec(line_in) go
;call echorecord(requestin) go

execute pfmt_test_print_to_pdf_req go

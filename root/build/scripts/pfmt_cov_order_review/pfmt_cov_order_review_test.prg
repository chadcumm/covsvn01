drop program pfmt_cov_order_review_test:dba go
create program pfmt_cov_order_review_test:dba
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Filename" = "" 

with OUTDEV, FILENAME

if ($FILENAME = "")
	DECLARE FILEPATH = VC WITH CONSTANT( "cclscratch:m0665_pfmt_cov_order_review_sample.json" ) 
else
	DECLARE FILEPATH = VC WITH CONSTANT($FILENAME ) 
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

execute pfmt_cov_order_review 

;call echorecord(requestin) 
end go


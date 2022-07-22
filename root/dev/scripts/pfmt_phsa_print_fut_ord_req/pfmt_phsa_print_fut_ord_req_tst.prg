drop program pfmt_phsa_print_fut_ord_req_ts:dba go
create program pfmt_phsa_print_fut_ord_req_ts:dba
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Filename" = "" 

with OUTDEV, FILENAME

if ($FILENAME = "")
	DECLARE FILEPATH = VC WITH CONSTANT( "CCLUSERDIR:json.txt" ) 
else
	DECLARE FILEPATH = VC WITH CONSTANT($FILENAME ) 
endif
 
free set requestin 

declare line_in = vc 
DECLARE vDEBUG = I2
FREE DEFINE RTL3 
DEFINE RTL3 IS FILEPATH 
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter 
;call echo(line_in) go
set stat = cnvtjsontorec(line_in) 
set vDEBUG=1
;execute pfmt_phsa_print_fut_ord_req 

execute pfmt_phsa_print_fut_ord_req 
call echorecord(requestin) 
end go

;requestin_560201_20201002103227.dat

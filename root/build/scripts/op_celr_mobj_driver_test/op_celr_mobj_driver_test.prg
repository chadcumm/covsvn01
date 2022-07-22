drop program op_celr_mobj_driver_test:dba go 
create program op_celr_mobj_driver_test:dba 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "OEN Reply:" = "" 

with OUTDEV, FILENAME1

free subroutine oencpm_msglog
declare oencpm_msglog(message=vc)=i2
subroutine oencpm_msglog(message)
	call echo(message)
end

if ($FILENAME1 = "")
	DECLARE FILEPATH = VC WITH CONSTANT( "CCLUSERDIR:cov_celr_mobj_oen_reply_1.dat" ) else
	DECLARE FILEPATH = VC WITH CONSTANT(concat("CCLUSERDIR:",$FILENAME1 )) endif

set stat = cnvtjsontorec(
							concat(^{"OENSTATUS":{ "IGNORE":0, "STATUS":1, "STATUS_DETAIL":0, "STATUS_TEXT":"", "NEXTSTEP":"", "IGNORE_TEXT":""}}^) 
						)
free set oen_reply

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

execute op_celr_mobj_driver
;call echorecord(oen_reply)
end go



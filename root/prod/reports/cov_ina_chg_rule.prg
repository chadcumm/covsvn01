/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Nov'2020
	Solution:			INA/Pre OP
	Source file name:	      cov_ina_chg_rule.prg
	Object name:		cov_ina_chg_rule
	Request#:			8788
	Program purpose:	      Rule Action Template call
	Executing from:		Rule
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_ina_chg_rule:dba go
create program cov_ina_chg_rule:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DECLARE VARIABLES
**************************************************************/
 
 
 
declare start_date = f8
declare convert_start_dt = vc with noconstant('')
 
 
;live
set start_date = cnvtlookahead("1,SEC")
set start_date = datetimefind(start_date,"D","B","B")
set convert_start_dt = format(cnvtlookahead("9,H", cnvtdatetime(start_date)),";;q")
 
call echo(build2('convert_start_dt = ',convert_start_dt ))
 
;Send back to rule
set cclprogram_status = 1
set cclprogram_message = convert_start_dt
 
 
;call echo(format(cnvtlookahead("9,h", cnvtdatetime(start_date)),";;q"))
 
 
;test
;set start_date = cnvtlookahead("1,D")
;set start_date = datetimefind(start_date,"D","B","B")
;set convert_start_dt = format(cnvtdatetime(start_date), 'dd-mmm-yyyy hh:mm:ss;;d')
 
 
 
 
 
 
 
end
go
 
 
 

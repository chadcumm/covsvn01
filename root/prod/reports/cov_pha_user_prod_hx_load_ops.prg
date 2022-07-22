/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Mar'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_user_prod_hx_load_ops.prg
	Object name:		cov_pha_user_prod_hx_load_ops.prg
	Request#:			3450
	Program purpose:	      Pharmacy Productivity data - historical back load
	Executing from:		Ops
 	Special Notes:          Aggregated data - by Facility.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_user_prod_hx_load_ops:dba go
create program cov_pha_user_prod_hx_load_ops:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
declare getdates(imonth = i4) = null
declare bdatevar = f8 with noconstant(0.0), protect
declare edatevar = f8 with noconstant(0.0), protect
declare iyear = i4 with noconstant(0), protect
declare bdate = vc with noconstant(fillstring(25,' ')), protect
declare edate = vc with noconstant(fillstring(25,' ')), protect
declare end_date   = f8
declare bdate_str = vc with noconstant(fillstring(25,' ')), protect
declare edate_str = vc with noconstant(fillstring(25,' ')), protect
 
declare filename = vc with constant('cer_temp:pha_productivity_hx_load_mar2019.txt'), protect
;declare filename = vc with constant('cer_temp:productivity_hx_test.txt'), protect
 
set iyear = year(curdate)
set imonth = month(curdate)
call getdates(imonth)
 
;Build heading to append with data file
SELECT into VALUE(filename) from dummyt d22
 
plan d22
 
HEAD REPORT
	crlf = CONCAT(CHAR(13))
	'Company','|',
	'Department','|',
	'Activity_Code','|',
	'Date_of_service','|',
	'Weight','|',
	'IP_Value','|',
	'OP_Value','|',
	'Total_Value',
	;crlf,
	ROW + 1
 
	ACT_CODE =FILLSTRING(1,' ')
	IP_VAL = FILLSTRING(1,' ')
	OP_VAL = FILLSTRING(1,' ')
	TOTAL_VAL = FILLSTRING(1,' ')
 
WITH nocounter, format = STREAM
 
while (bdatevar <= edatevar)
 
	set bdate_str = format(bdatevar,"dd-mmm-yyyy hh:mm;;q")
	set end_date = cnvtlookahead("1,d", bdatevar)
	set edate_str = format(cnvtlookbehind("1,sec", end_date),"dd-mmm-yyyy hh:mm;;q")
 
 	;execute cov_pha_user_prod_hx_load "mine", bdate_str, edate_str, 1.0
 
  	set bdatevar = cnvtlookahead("1,d", bdatevar)
 
	;execute cov_pha_user_prod_hx_load "mine", "13-MAR-2019 00:00:00", "13-MAR-2019 23:59:00", 1.0
 
endwhile
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
subroutine getdates(imonth)
	;set iyear = iyear - 1
	set iyear = year(curdate)
	set bdate = build('01-','mar-',iyear)
	set edate = build('18-','mar-',iyear)
	set bdatevar = cnvtdatetime(bdate)
	set edatevar = cnvtdatetime(edate)
end
 
 
end
go
 

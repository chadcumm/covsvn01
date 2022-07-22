/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jul'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_discharge_rx_ops.prg
	Object name:		cov_pha_discharge_rx_ops
	Request#:			3512 & 4105 combined
	Program purpose:	      Prescribrd medications at patient discharge
	Executing from:		Ops - Data feed (Astream - Jerry Inman)
 	Special Notes:          cov_pha_discharge_rx_meds.prg for users in DA2 with extra promt
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_disch_rx_bkload_ops:dba go
create program cov_pha_disch_rx_bkload_ops:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("1,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)
 
 
call echo(build2('start = ', format(cnvtdatetime(start_date),'mm/dd/yyyy hh:mm;;d')
	,' end = ',  format(cnvtdatetime(end_date),'mm/dd/yyyy hh:mm;;d') ))
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;All Facilities together including clinics
 
;EXECUTE cov_pha_discharge_rx_meds "mine", start_date, end_date, 0, "", 0, 0
 
EXECUTE cov_pha_disch_rx_backload "mine", "16-DEC-2018 00:00:00", "31-DEC-2018 23:59:00", 0, "", value(0), 0
 
 
end go
 
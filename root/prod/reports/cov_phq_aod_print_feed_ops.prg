 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Paramasivam
	Date Written:		03/13/2020
	Solution:			Quality
	Source file name:	      cov_phq_aod_print_feed_ops.prg
	Object name:		cov_phq_aod_print_feed_ops
	Request #:			7129
 	Program purpose:		Accounting of disclosure(AOD) - by using Report Request Tool
	Executing from:		OPS
 	Special Notes:		Part of AOD feed - one of the script and data source
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod	Mod Date	Developer				Comment
---	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_phq_aod_print_feed_ops:dba go
create program cov_phq_aod_print_feed_ops:dba
 
prompt
	"Output to File/Printer/MINe" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Start Request Date/Time" = "SYSDATE"
	, "End Request Date/Time" = "SYSDATE"
	, "Screen Display" = 1
 
with OUTDEV, start_datetime, end_datetime, to_file
 
 
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
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Everyday live 
EXECUTE cov_phq_aod_print_feed "mine", start_date, end_date, 0
 
 
;set up for hiostorical load 
;EXECUTE cov_phq_aod_print_feed "mine", "12-OCT-2020 00:00:00", "14-OCT-2020 23:59:00", 0
 
 
end go

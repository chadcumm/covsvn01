 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Paramasivam
	Date Written:		Apr'21
	Solution:			Quality
	Source file name:	      cov_phq_aod_pform_feed_ops.prg
	Object name:		cov_phq_aod_pform_feed_ops
	Request #:			7123
 	Program purpose:		Accounting of disclosure(AOD) - by using Power Form
	Executing from:		OPS
 	Special Notes:		Part of AOD feed
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod	Mod Date	Developer				Comment
---	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_phq_aod_pform_feed_ops:dba go
create program cov_phq_aod_pform_feed_ops:dba
 
prompt 
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

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
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
EXECUTE cov_phq_aod_pform_feed "mine", start_date, end_date, 0
 
 
;set up for hiostorical load
;EXECUTE cov_phq_aod_print_feed "mine", "12-OCT-2020 00:00:00", "14-OCT-2020 23:59:00", 0
 
 
end go

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Jan'2020
	Solution:			Pharmacy
	Source file name:  	cov_pha_blood_glucose_feed.prg
	Object name:		cov_pha_blood_glucose_feed
	Request#:			7042
	Program purpose:	      Glucose feed set up to Strata
	Executing from:		Ops
  	Special Notes:          Based on cov_pha_bloodglucose_heparin.prg but feed set up only for Glucose
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_blood_glucose_ops:dba go
create program cov_pha_blood_glucose_ops:dba
 
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
 
;All Facilities together
 
;Daily Feed
EXECUTE cov_pha_blood_glucose_feed "mine", start_date, end_date, 0, "", 0, 0

;Historical Load 
;EXECUTE cov_pha_blood_glucose_feed "mine", "01-JAN-2020 00:00:00", "28-JAN-2020 23:59:00"
 
 
end go
 

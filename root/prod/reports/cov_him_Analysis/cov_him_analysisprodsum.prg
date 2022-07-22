/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/12/2019
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_AnalysisProdSum.prg
	Object name:		cov_him_AnalysisProdSum
	Request #:			6687
 
	Program purpose:	Wrapper for HIM_MAK_PROD_ANALYSIS_SUM_LYT.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	11/14/2019	Todd A. Blanchard		Removed date prompts from wrapper.
 
******************************************************************************/
 
drop program cov_him_AnalysisProdSum:DBA go
create program cov_him_AnalysisProdSum:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare startdate	= dq8 with noconstant(cnvtdatetime((curdate - 1), 000000))
declare enddate		= dq8 with noconstant(cnvtdatetime((curdate - 1), 000000))
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
execute HIM_MAK_PROD_ANALYSIS_SUM_LYT $OUTDEV, 0, startdate, enddate, 0, 0, 1
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 

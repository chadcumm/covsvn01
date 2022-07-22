/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		 2021
	Solution:			
	Source file name:	      .prg
	Object name:		
	Request#:			000
	Program purpose:	      
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 

drop program cov_gs_prom_shell:dba go
create program cov_gs_prom_shell:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime


/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

/**************************************************************
; DVDev Start Coding
**************************************************************/


;    Your Code Goes Here


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

end
go


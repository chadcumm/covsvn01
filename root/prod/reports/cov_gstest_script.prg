/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		'2022
	Solution:			
	Source file name:	      
	Object name:		
	Request#:			
	Program purpose:	      
	Executing from:		DA2
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
-------------------------------------------------------------------------------
 
/22    Geetha    CR#     Initial release
 
******************************************************************************/


drop program cov_gstest_script:dba go
create program cov_gstest_script:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list


/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

declare inpatient_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
 
declare initcap() = c100


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


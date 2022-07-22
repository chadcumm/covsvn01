/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				   Chad Cummings
	Date Written:		   03/01/2019
	Solution:			   Behavior Health
	Source file name:	   cov_chart_compliance
	Object name:		   cov_chart_compliance
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_chart_compliance:dba go
create program cov_chart_compliance:dba
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Position" = VALUE(31767941.000000)    ;* Select a Position to Audit
	, "Personnel" = 0 

with OUTDEV, POSITION, USERS

end 
go

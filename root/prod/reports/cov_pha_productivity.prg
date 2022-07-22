/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Saravanan
	Date Written:		Feb'2018
	Solution:			Pharmacy
	Source file name:	      cov_ph_Productivity.prg
	Object name:		cov_ph_Productivity
 
	Request#:			998
	Program purpose:	      Daily data extract for each facility and each pharmacist to identify all order actions
					that have been completed over the course of the day.
 
	Executing from:		CCL data extract & Reporting Portal
 
 	Special Notes:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_pha_Productivity:DBA go
create program cov_pha_Productivity:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

SELECT DISTINCT INTO $OUTDEV

o.order_id, o.activity_type_cd, 
activityType = uar_get_code_display(o.activity_type_cd), 
catalogCD = uar_get_code_display(o.catalog_cd),
catalogType = uar_get_code_display(o.catalog_cd),
orderType = uar_get_code_display(o.med_order_type_cd),
o.order_detail_display_line,
orderStatus = uar_get_code_display(o.order_status_cd),
source = uar_get_code_display(o.source_cd)
,o.encntr_id,
o.status_prsnl_id

from orders o

plan o where o.activity_type_cd = 705 ;Pharmacy




WITH NOCOUNTER, SEPARATOR=" ", FORMAT, MAXREC = 10000



 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

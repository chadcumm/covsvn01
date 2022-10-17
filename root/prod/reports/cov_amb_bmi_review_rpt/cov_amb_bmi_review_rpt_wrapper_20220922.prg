/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	08/17/2021
Program Title	:	cov_amb_bmi_review_rpt_wrapper
Source File     :	cov_amb_bmi_review_rpt_wrapper.prg
Object Name     :	cov_amb_bmi_review_rpt_wrapper
Directory       :	cust_script
 
Purpose         : 	Used to run the Layout Builder report in Ops Jobs (Olympus) to
                    pass date prompt
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     03/21/2022  Dawn Greer, DBA         Original Release - CR 11064
 
************************************************************************************/
drop program cov_amb_bmi_review_rpt_wrapper go
create program cov_amb_bmi_review_rpt_wrapper
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = VALUE(0)
 
with OUTDEV, FAC
 
 
DECLARE bdate = F8
DECLARE edate = F8
 
SET bdate = CNVTDATETIME(CURDATE-1,0)
SET edate = CNVTDATETIME(CURDATE-1,235959)
 
EXECUTE cov_amb_bmi_review_rpt_lb "CER_TEMP\cmg__cov_amb_bmi_review_rpt.pdf", $FAC, CNVTDATETIME(CURDATE-1,0),
CNVTDATETIME(CURDATE-1,235959)
 
END
GO

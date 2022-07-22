drop program cov_mpage_svc_fin_test go
create program cov_mpage_svc_fin_test 

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, FIN

set _MEMORY_REPLY_STRING = "<html><body>script executed, nothing returned</body></html>"
/*
Passed in parameter:
·         Financial Number (for example, at Methodist currently Inpatient, 1900901710)
 
Web page would return:
·         Facility
·         Unit/Department
·         Room
·         Bed
·         CMRN
·         Facility MRN (alias pool)
·         Facility Financial Number
·         Patient Name (Last, First, MI)
·         Patient Date of Birth
·         Patient Birth Gender
·         Encounter Admit Date
·         Encounter Discharge Date
*/



end
go

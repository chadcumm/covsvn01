drop program cov_eks_dlg_audit_ops go
create program cov_eks_dlg_audit_ops
 
prompt
	"Output to File/Printer/MINE" = "eks_dlg_hist.dat"   ;* output file name to send this report to.
	, "Begin Date, mmddyy (today):" = CURDATE-60      ;* Enter the begin date for this report
	, "End Date, mmddyy (today):" = CURDATE-30        ;* Enter the end date for this report
	, "Output Type - (B)ackend CSV, (F)rontend CSV, or (R)eport (R):" = "R"   ;* Select an output type for this report
 
with OUTDEV, BeginDate, EndDate, OutType

record reply
(
%i cclsource:status_block.inc
)

declare _beginDttm = vc
declare _endDttm = vc
set _beginDttm = format(cnvtdate(cnvtdatetime($BeginDate,0000)),"mmddyy;;d")
set _endDttm = format(cnvtdate(cnvtdatetime($EndDate,0000)),"mmddyy;;d")
 
set reply->status_data->status = "F"
set failed = "F"
 
execute eks_dlg_audit value($1), value(_beginDttm), "0000", value(_endDttm), "0000", "*", $OutType, "D", "M"
 
if(curqual > 0)
    set reply->status_data->status = "S"
else
  ;log error
  set errmsg = fillstring(132," ")
  set errcode = error(errmsg,1)
  if (errcode = 0)
    set reply->status_data->status = "Z"
  endif
endif
 
 
end
go
 

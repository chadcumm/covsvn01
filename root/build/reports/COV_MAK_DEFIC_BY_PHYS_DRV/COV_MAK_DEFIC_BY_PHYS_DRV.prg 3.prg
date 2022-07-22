drop program cov_mak_defic_by_phys_drv go
create program cov_mak_defic_by_phys_drv

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Physician(s)" = 0

with OUTDEV, ORGANIZATIONS, PHYSICIANS



execute ReportRtl
%i cclsource:him_reports_prompts.inc
%i cclsource:him_reports_layout.inc
%i cclsource:him_mak_defic_by_phys_prmpt.inc


call echorecord(data)

end go

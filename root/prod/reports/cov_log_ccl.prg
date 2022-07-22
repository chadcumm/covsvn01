drop program cov_log_ccl go
create program cov_log_ccl
 
free set t_rec
record t_rec
(
	1 cnt			= i4
	1 filename_a      = vc
	1 filename_b    = vc
	1 filename_c = vc
	1 filename_d = vc
	1 filename_e = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)
 
call addEmailLog("chad.cummings@covhlth.com")
 
set t_rec->filename_a = concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
if (validate(request))
	call echojson(request, t_rec->filename_a , 1)
endif
 
if (validate(reqinfo))
	call echojson(reqinfo,t_rec->filename_a, 1)
endif
 
end
go

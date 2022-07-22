free set t_rec go
record t_rec 
(
	1 cnt			= i4
	1 start_date	= c6
	1 start_time	= c4
	1 end_date		= c6
	1 end_time		= c4
	1 module_name	= vc
	1 outtype		= c1
	1 details		= c1
	1 sort			= c1
	1 filename		= vc
	1 full_path		= vc
	1 file_path		= vc
	1 astream_path	= vc
	1 astream_mv	= vc
) go

set t_rec->astream_path = build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/Export/") go

set t_rec->file_path 	= build("/cerner/d_",cnvtlower(trim(curdomain)),"/temp/") go
set t_rec->filename		= build(
										 cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim("eks_dlg_audit"))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".csv"
										) go

set t_rec->full_path	= concat(t_rec->file_path,t_rec->filename) go
set t_rec->astream_mv = build2("cp ",t_rec->full_path," ",t_rec->astream_path,t_rec->filename) go

set dclstat = 0 go
call dcl(t_rec->astream_mv, size(trim(t_rec->astream_mv)), dclstat)  go
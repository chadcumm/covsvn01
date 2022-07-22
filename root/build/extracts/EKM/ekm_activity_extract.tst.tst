free set t_rec go
record t_rec
(
	1 cnt = i2
	1 start_dt = dq8
	1 end_dt = dq8
	1 qual[*]
	 2 module_name = vc
	 2 executions = i4
	 2 elapsed = f8
) go

select into "nl:"
;concat("cer_temp:",value(format(cnvtdatetime(sysdate),"yyyymmdd;;q")),"_ekm_system.aud")
	 ema.module_name
	,ema.server_class
	,elapsed=datetimediff(ema.end_dt_tm,ema.begin_dt_tm,6)
	,ema.begin_dt_tm ";;q"
	,ema.end_dt_tm ";;q"
from EKS_MODULE_AUDIT ema 
where ema.rec_id > 0
;where ema.begin_dt_tm between cnvtdatetime("23-JUN-2019") and cnvtdatetime("30-JUN-2019")
;with separator=",", pcformat (^"^, ^,^, 1) go
order by 
	 ema.module_name
	,ema.rec_id
head report
	t_rec->cnt = 0
	t_rec->start_dt = cnvtdatetime(curdate,curtime3)
	t_rec->end_dt = cnvtdatetime(curdate-1)
head ema.module_name
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].module_name = ema.module_name
head ema.rec_id
	t_rec->qual[t_rec->cnt].executions = (t_rec->qual[t_rec->cnt].executions + 1)
	t_rec->qual[t_rec->cnt].elapsed = t_rec->qual[t_rec->cnt].elapsed + 
		datetimediff(ema.end_dt_tm,ema.begin_dt_tm,6)
	if (ema.begin_dt_tm < t_rec->start_dt)
		t_rec->start_dt = ema.begin_dt_tm
	endif
	if (ema.end_dt_tm > t_rec->end_dt)
		t_rec->end_dt = ema.end_dt_tm
	endif
with nocounter go

call echojson(t_rec,"ekm_activity_audit.dat") go


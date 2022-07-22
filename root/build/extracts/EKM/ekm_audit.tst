select into concat("cer_temp:",value(format(cnvtdatetime(sysdate),"yyyymmdd;;q")),"_ekm_system.aud")
	 ema.module_name
	,ema.server_class
	,elapsed=datetimediff(ema.end_dt_tm,ema.begin_dt_tm,6)
	,ema.begin_dt_tm ";;q"
	,ema.end_dt_tm ";;q"
from EKS_MODULE_AUDIT ema ;where ema.conclude >= 2
with separator=",", pcformat (^"^, ^,^, 1) go







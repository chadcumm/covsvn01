drop program cov_mpage_svc_userlogin_csv:dba go
create program cov_mpage_svc_userlogin_csv:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Username (ALL CAPS)" = "SUMMAPLES" 

with OUTDEV, STRUSERNAME
 
SELECT INTO $OUTDEV
  start_dt_tm = format(c.start_dt_tm, 'mm/dd/yyyy hh:mm:ss'),
  p.name_last,
  p.name_first,
  p.username,
  person_id = format(p.person_id, ";L"),
  c.application_image,
  c.client_node_name,
  c.tcpip_address,
  app_ctx_id = format(c.app_ctx_id, ";L")
from
  application_context c,
  prsnl p
where
  0=0
  and c.person_id = p.person_id
  and c.start_dt_tm > sysdate - 7
  and p.username = $strUserName
order by
  c.start_dt_tm desc
 
with nocounter, format, noheading, separator="|"
 
#exit_script
 
end
go
 

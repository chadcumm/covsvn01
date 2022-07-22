drop program cov_position_audit go
create program cov_position_audit

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


select into $OUTDEV
	 position=uar_get_code_display(p.position_cd)
	,p.name_full_formatted
	,p.physician_ind
	,p.username
from
	prsnl p
plan p
	where p.position_cd > 0.0
	and   p.active_ind = 1 
	and   p.username > " "
order by
	 position
	,p.name_full_formatted
with format(date,";;q"),uar_code(d),format,separator = " "


end go

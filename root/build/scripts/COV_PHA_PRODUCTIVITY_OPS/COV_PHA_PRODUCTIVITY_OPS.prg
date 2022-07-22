drop program COV_PHA_PRODUCTIVITY_OPS go
create program COV_PHA_PRODUCTIVITY_OPS
 
free record m_rec
record m_rec
(
	1 orig_date     = dq8
	1 cnt			= i2
	1 i				= i2
	1 qual[*]
	 2 start_date	= dq8
	 2 end_date		= dq8
	 2 parser_line  = vc
)
declare iii = i2 with protect
set m_rec->orig_date = cnvtdatetime("31-DEC-2018 00:00:00")
for (i=1 to 21)
	set m_rec->cnt = (m_rec->cnt + 1)
	set stat = alterlist(m_rec->qual,m_rec->cnt)
	set m_rec->qual[m_rec->cnt].start_date
							= datetimefind(cnvtlookahead(concat(^"^,cnvtstring(i),^,M"^),cnvtdatetime(m_rec->orig_date)), 'M', 'B', 'B')
	set m_rec->qual[m_rec->cnt].end_date
							= datetimefind(cnvtlookahead(concat(^"^,cnvtstring(i),^,M"^),cnvtdatetime(m_rec->orig_date)), 'M', 'E', 'E')
	set m_rec->qual[m_rec->cnt].parser_line = concat(^execute cov_pha_productivity_rpt ^
											,^ "OPS",0,"^,format(m_rec->qual[i].start_date,";;q"),^","^
											,format(m_rec->qual[i].end_date,";;q"),^",value(1.0) ,0 go^)
endfor
set debug_ind = 1
call echorecord(m_rec)
set iii=1
for (iii=1 to m_rec->cnt)
call echo(concat("iii=",cnvtstring(iii)))
call echo(format(m_rec->qual[iii].start_date,";;q"))
call echo(format(m_rec->qual[iii].end_date,";;q"))
 
;execute cov_pha_productivity_rpt
;"OPS",0,format(m_rec->qual[k].start_date,";;q"),format(m_rec->qual[k].end_date,";;q"),value(1.0) ,0
 
call parser(m_rec->qual[iii].parser_line)
 
endfor
 
call echorecord(m_rec)
end go
 

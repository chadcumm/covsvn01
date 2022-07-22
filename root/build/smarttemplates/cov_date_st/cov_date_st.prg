3:46

drop program cov_date_st:dba go
create program cov_date_st:dba

call echo(build("loading script:",curprog))
set nologvar = 1
set noaudvar = 1
%i ccluserdir:cov_custom_ccl_common.inc

call set_codevalues(null)
call set_rtf_commands(null)


declare SRVRESULTSSTR = VC WITH NOCONSTANT ("")
set width_val1 = 5000
set width_val2 = width_val1 + 5000
set rtf_commands->st.rtcel1 = 	concat("\cellx",trim(cnvtstring(width_val1))," ")
set rtf_commands->st.rtcel2 = 	concat("\cellx",trim(cnvtstring(width_val2))," ")

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call echo("starting template")

set SRVRESULTSSTR = rtf_commands->st.rhead

set SRVRESULTSSTR = concat(SRVRESULTSSTR,rtf_commands->st.wr)

set SRVRESULTSSTR = build2(SRVRESULTSSTR,"the time is ",format(sysdate,"dd-mmm-yyyy;;d")," ")


set SRVRESULTSSTR = concat(SRVRESULTSSTR,rtf_commands->st.rtfeof)

set reply->text = SRVRESULTSSTR
call echorecord(rtf_commands)
call echorecord(reply)

end
go

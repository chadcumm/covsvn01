/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2021
	Solution:
	Source file name:	      cov_gs_users_position.prg
	Object name:		cov_gs_users_position
	Request#:
	Program purpose:	      AdHoc
	Executing from:
 	Special Notes:
 
******************************************************************************/
 
 
drop program cov_gs_users_position:dba go
create program cov_gs_users_position:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "User Last Name" = ""
	, "User Position" = ""
 
with OUTDEV, last_name, user_position
 
 
;----------------------------------------------------------------------------------------------
 
select into $outdev
pr.name_full_formatted, pr.username, pos = uar_get_code_display(pr.position_cd)
from prsnl pr, code_value cv1
where pr.position_cd = cv1.code_value
and cv1.code_set = 88
and cv1.active_ind = 1
and pr.active_ind = 1
and (cnvtlower(pr.name_last) = cnvtlower($last_name) or cnvtlower(cv1.display) = cnvtlower($user_position))
 
with nocounter, separator=" ", format
 
end
go
 

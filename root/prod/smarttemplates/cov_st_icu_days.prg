/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren / Chad Cummings
	Date Written:		May 2021
	Solution:
	Source file name:	cov_st_icu_days.prg
	Object name:		cov_st_icu_days
	CR#:				9684
 
	Program purpose:	Smart Template - EICU ICU Day
						Code Value:  3161689207
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
drop program cov_st_icu_days:dba go
create program cov_st_icu_days:dba
 
prompt
	"Output to File/Printer/MINE " = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
%i cust_script:cov_eicu_st_common.inc
;%i cust_script:cov_st_EICU_Number_Days.inc
 
set reply->text = build2(
 
	"{\rtf1\ansi{\colortbl;\red255\green255\blue255;}{\*\revtbl{Unknown;}}\viewkind4\cb1"
	,"ICU Days:",cnvtstring(rec->list[1].icu_days)
	,"}"
)
 
#exitscript
end go

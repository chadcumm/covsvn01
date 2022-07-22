/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren / Chad Cummings
	Date Written:		May 2021
	Solution:
	Source file name:	cov_st_vent_days.prg
	Object name:		cov_st_vent_days
	CR#:				9684
 
	Program purpose:	Smart Template - EICU Vent Day
						Code Value:  3161689203
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
drop program cov_st_vent_days go
create program cov_st_vent_days
 
prompt
	"Output to File/Printer/MINE " = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
%i cust_script:cov_eicu_st_common.inc
;%i cust_script:cov_st_EICU_Number_Days.prg
 
set reply->text = build2(
 
	"{\rtf1\ansi{\colortbl;\red255\green255\blue255;}{\*\revtbl{Unknown;}}\viewkind4\cb1"
	,"Ventilator Days:",cnvtstring(rec->list[1].vent_days)
	,"}"
)
 
#exitscript
end go

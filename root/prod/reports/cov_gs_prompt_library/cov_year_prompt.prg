/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		Sep' 2018
	Source file name:  	cov_year_prompt.prg
	Object name:		cov_year_prompt
	Request#:			custom dev
 
	Program purpose:	      Custom prompt to disply only years from 2017(go live) to current year
	Executing from:		Prompt_library
  	Special Notes:          Import and use as other prompts
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_year_prompt:dba go
create program cov_year_prompt:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
declare start_yr = int
declare current_yr = int
declare end_yr = int
 
set start_yr = 2017
set current_yr = cnvtint(format(sysdate, 'yyyy;;d'))
set end_yr = start_yr
 
Record yr(
	1 list[*]
		2 year_val = i4
)
 
 
select into 'nl:' from dummyt d
 
Head report
  cnt = 0
  call alterlist(yr->list, 10)
 
Detail
  while(current_yr >= end_yr)
  	cnt = cnt + 1
  	yr->list[cnt].year_val = end_yr
	end_yr = end_yr + 1
  endwhile
 
Foot report
   call alterlist(yr->list, cnt)
 
With Nocounter
 
 
execute ccl_prompt_api_dataset "autoset"
 
SELECT INTO 'NL:'
	 YEAR_VAL = YR->list[D1.SEQ].year_val
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(YR->list, 5)))
 
PLAN D1
 
ORDER BY YEAR_VAL
 
Head Report
	 stat = MakeDataSet(2)
Detail
	stat = writeRecord(0)
Foot Report
	stat = CloseDataSet(0)
 
WITH nocounter, reporthelp, check
 
 
end go
 
 

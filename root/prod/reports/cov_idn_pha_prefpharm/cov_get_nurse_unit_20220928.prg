/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Steve Czubek
	Date Written:		09/28/2022
	Source file name:	cov_get_nurse_unit.prg
	Object name:		cov_get_nurse_unit
	Request #:
 
	Program purpose:	Returns nurse units for a give organization
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	09/28/2022	Steve Czubek     		Initial release
 
******************************************************************************/
drop program cov_get_nurse_unit:dba go
create program cov_get_nurse_unit:dba
 
prompt
	"Facility" = 0
 
with FACILITY
 
%i cust_script:SC_CPS_GET_PROMPT_LIST.inc
 
declare org_prompt_parser = vc with protect, constant(GetPromptList(1, "l.organization_id"))
declare AMBULATORYS = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 222, "AMBULATORYS"))
declare NURSEUNITS = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 222, "NURSEUNITS"))
 
execute ccl_prompt_api_dataset "autoset"
 
select into "nl:"
	cv.display
	,cv.code_value
from
	location l
	,code_value cv
plan l
	where parser(org_prompt_parser)
	and l.location_type_cd in (AMBULATORYS, NURSEUNITS)
join cv
	where cv.code_value = l.location_cd
order
	cv.display
head report
                                             ;Initialize the data set
	stat = MakeDataSet(100)
detail
	call echo("in detail")
                                             ;copy each that was selected into the data set
	stat = WriteRecord(0)
foot report
                                             ;Close the data set
	stat = CloseDataSet(0)
 
WITH  ReportHelp, Check
 
end
go
 
 
 

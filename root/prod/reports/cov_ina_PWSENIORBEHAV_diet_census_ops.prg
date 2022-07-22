 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Nursing/Nutrition
	Request#:			3579 - BTG
 
	Program purpose:	      Diet Census
	Executing from:		Ops sheduler
  	Special Notes:          Break the glass set up - reports will be generated every 2 hours and
  					will be stored in BTG/KC server in Kansas city
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_ina_PWSENIORBEHAV_cs_ops:dba go
create program cov_ina_PWSENIORBEHAV_cs_ops:dba
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;BTG set up - Diet Worksheet
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
declare filename_var = vc WITH noconstant(CONCAT('cer_temp:', 'pw_seniorbehav_diet_census.pdf')), PROTECT
declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/', 'pw_seniorbehav_diet_census.pdf')), PROTECT
declare astream_filepath_var = vc with noconstant("/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Dietary/")
 
if(VALIDATE(request->batch_selection) = 1)
	SET iOpsInd = 1
endif
 
if(iOpsInd = 1)
	execute cov_ina_dietcensus_lb VALUE(filename_var), VALUE(2553765531.00)
 	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var)
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
end go
 
 
 

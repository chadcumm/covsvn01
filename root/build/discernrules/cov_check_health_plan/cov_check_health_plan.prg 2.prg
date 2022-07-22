/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				     Chad Cummings
	Date Written:		   03/01/2019
	Solution:			     Discern Expert
	Source file name:	 	cov_check_health_plan.prg
	Object name:		   cov_check_health_plan
	Request #:

	Program purpose:

	Executing from:		EKS

 	Special Notes:		Called by Discern Expert template(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_check_health_plan:dba go
create program cov_check_health_plan:dba

free record t_rec
record t_rec
(
	1 person_id	= f8
	1 encntr_id = f8
	
)

#exit_script




end
go

/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	01/22/2020
	Solution:				
	Source file name:	 	cov_upd_preg_onset.prg
	Object name:		   	cov_upd_preg_onset
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	01/20/2020  Chad Cummings			Initial Deployment
******************************************************************************/

drop program cov_upd_preg_onset:dba go
create program cov_upd_preg_onset:dba

free set t_rec
record t_rec
(
	1 person_id = f8
	1 problem_id = f8
	1 pregnancy_instance_id = f8
)

set t_rec->person_id = requestin->request->patient_id


select into "nl:"
	*
from
	pregnancy_instance pi
	,problem p
plan pi
	where pi.person_id =    18807612.00
	and   pi.active_ind = 1
join p
	where p.problem_id = pi.problem_id
with format(date,";;q"),uar_code(d)
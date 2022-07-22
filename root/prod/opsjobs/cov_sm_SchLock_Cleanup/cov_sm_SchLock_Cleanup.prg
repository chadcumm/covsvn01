/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/05/2020
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchLock_Cleanup.prg
	Object name:		cov_sm_SchLock_Cleanup
	Request #:			7921
 
	Program purpose:	Clears locks from table SCH_LOCK.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_sm_SchLock_Cleanup:DBA go
create program cov_sm_SchLock_Cleanup:DBA

/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/ 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

delete
from
	SCH_LOCK sl
where 
	sl.status_meaning IN ("IN-PROGRESS", "VERIFIED")
	and sl.granted_dt_tm < sysdate-(2*(1/24))
	and sl.parent_table = "SCH_EVENT"
	and sl.sch_lock_id > 0.0

commit


if (validate(request->batch_selection) = 1)
	set reply->status_data.status = "S"
endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

;#exitscript
 
end
go


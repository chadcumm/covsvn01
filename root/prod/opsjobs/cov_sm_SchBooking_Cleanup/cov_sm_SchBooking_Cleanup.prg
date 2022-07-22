/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/26/2021
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchBooking_Cleanup.prg
	Object name:		cov_sm_SchBooking_Cleanup
	Request #:			9555
 
	Program purpose:	Clears locks from table SCH_BOOKING.
 
	Executing from:		CCL
 
 	Special Notes:		Runs from Ops Job 'COV Scheduled Booking Cleanup'.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/19/2021	Todd A. Blanchard		Adjusted time frame for granted date/time.
 
******************************************************************************/
 
drop program cov_sm_SchBooking_Cleanup:DBA go
create program cov_sm_SchBooking_Cleanup:DBA

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


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
	SCH_BOOKING sb
where
	sb.location_cd in (
		select cv.code_value
		from 
			CODE_VALUE cv
		where 
			cv.code_set = 220
			and cv.active_ind = 1
			and cv.cdf_meaning in ("AMBULATORY", "NURSEUNIT", "ANCILSURG")
			and exists (
				select "x"
				from 
					SCH_APPT_LOC sal
				where 
					sal.location_cd = cv.code_value
					and rownum = 1
			)
	)
	and sb.beg_dt_tm > sysdate - 1
	and sb.status_flag in (1, 2)
	and sb.granted_dt_tm < sysdate-(1.5*(1/24))

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



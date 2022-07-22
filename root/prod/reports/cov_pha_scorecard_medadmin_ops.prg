 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Pharmacy/PharmNet
	Source file name:  	cov_pha_scorecard_medadmin_ops.prg
	Object name:		cov_pha_scorecard_medadmin_ops
	Request#:			3579 - BTG
 
	Program purpose:	      Medication administration details.
	Executing from:		Ops sheduler
  	Special Notes:          Astream to Jerry Inman
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_scorecard_medadmin_ops:dba go
create program cov_pha_scorecard_medadmin_ops:dba


/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("1,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)

 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
RECORD facility(
	1 rec_cnt =	i4
	1 flist[*]
		2 facility_cd   =	f8
		2 facility_desc =	vc
)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get facilities
select into 'NL:'
  facility_name = uar_get_displaykey(l.location_cd), l.location_cd
 
from location l
where l.location_type_cd = 783.00
and l.active_ind = 1
and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2553765579.00,2552503645.00,2552503649.00)
 
order by facility_name
 
 
Head report
	cnt = 0
Detail
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 		stat = alterlist(facility->flist, cnt + 9)
 	endif
 
	facility->flist[cnt].facility_cd	= l.location_cd
	facility->flist[cnt].facility_desc	= facility_name
	facility->rec_cnt		      	= cnt
 
Foot report
	stat = alterlist(facility->flist, cnt)
 
With nocounter
 

;Loop through all facilities.
For(fcnt = 1 to facility->rec_cnt)
	
	;one time
	EXECUTE cov_pha_scorecard_extract "mine", 0, "01-DEC-2018 00:00:00", "12-DEC-2018 23:59:00", facility->flist[fcnt].facility_cd
 
 	;everyday
 	;EXECUTE cov_pha_scorecard_extract "mine", 0, start_date, end_date, facility->flist[fcnt].facility_cd
 
	;test 
 	;EXECUTE cov_pha_scorecard_extract "mine", 0, "01-NOV-2018 00:00:00", "01-NOV-2018 23:59:00", 2552503635
	;EXECUTE cov_pha_scorecard_extract "mine", facility->flist[fcnt].facility_cd
Endfor

 
end
go
 
 
/*
	 2552503635.00	Fort Loudoun Medical Center	FLMC
	   21250403.00	Fort Sanders Regional Medical Center	FSR
	 2552503653.00	LeConte Medical Center	LCMC
	 2552503639.00	Morristown-Hamblen Hospital Association	MHHS
	 2552503613.00	Methodist Medical Center	MMC
	 2553765579.00	Peninsula Behavioral Health - Div of Parkwest Medical Center	PBHPENINSULA
	 2552503645.00	Parkwest Medical Center	PW
	 2552503649.00	Roane Medical Center	RMC
 
 */
 

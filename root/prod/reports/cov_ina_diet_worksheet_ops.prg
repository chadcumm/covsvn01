 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Nursing/Nutrition
	Source file name:  	cov_ina_diet_worksheet_ops.prg
	Object name:		cov_ina_diet_worksheet_ops
	Request#:			3579 - BTG
 
	Program purpose:	      Report will show all patient's diet information.
	Executing from:		Ops sheduler
  	Special Notes:          Break the glass set up - reports will be generated for all facilities for every 2 hours and the
  					will be stored in BTG/KC server in Kansas city
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_ina_diet_worksheet_ops:dba go
create program cov_ina_diet_worksheet_ops:dba
 
 
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
and l.location_cd IN (2552503635.00,21250403.00,2553765707,2553765627,2553765571,2552503653.00,2553765371.00,2552503613.00,
	2552503639.00,2553765475.00,2552503645.00,2553765531,2552503649.00,2553765291.00,2552503657.00,2553765579.00)
 
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
 
call echorecord(facility)
 
;Loop through facilities to get report for all facilities.
For(fcnt = 1 to facility->rec_cnt)
	EXECUTE cov_ina_dietitian_worksheet "mine", facility->flist[fcnt].facility_cd
Endfor
 
 
end
go
 
/*
	 2553765291.00	Claiborne Medical Center	CLMC
	 2552503657.00	Cumberland Medical Center, Inc	CMC
	 2552503635.00	Fort Loudoun Medical Center	FLMC
	   21250403.00	Fort Sanders Regional Medical Center	FSR
	 2553765571.00	FSR Patricia Neal Rehabilitation Center	FSRPATNEAL
	 2553765627.00	FSR Select Specialty Hospital	FSRSELECTSPEC
	 2553765707.00	FSR Transitional Care Unit	FSRTCU
	 2552503653.00	LeConte Medical Center	LCMC
	 2553765371.00	LCMC Ft Sanders Sevier Nursing Home-Div of LeConte Medical	LCMCNSGHOME
	 2552503639.00	Morristown-Hamblen Hospital Association	MHHS
	 2553765475.00	MHHS Behavioral Health	MHHSBEHAVHLTH
	 2552503613.00	Methodist Medical Center	MMC
	 2553765579.00	Peninsula Behavioral Health - Div of Parkwest Medical Center	PBHPENINSULA
	 2552503645.00	Parkwest Medical Center	PW
	 2553765531.00	PW Senior Behavioral Unit	PWSENIORBEHAV
	 2552503649.00	Roane Medical Center	RMC
 
 */
 

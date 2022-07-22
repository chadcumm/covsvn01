/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb 2022
	Solution:			Quality
	Source file name:	      cov_phq_urinary_cath_ops.prg
	Object name:		cov_phq_urinary_cath_ops
	Request#:			12113
	Program purpose:	      Feed to Spotfire
	Executing from:		DA2/Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_urinary_cath_ops:dba go
create program cov_phq_urinary_cath_ops:dba
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_date = f8
declare end_date   = f8
declare tmp_date   = f8

;Date setup - Runs for the previous day.
/*set start_date = cnvtlookbehind("1,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)*/

;Look back 1 Week 
set start_date = cnvtlookbehind("1,W")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,W",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)
 
set sdt = format(start_date, 'mm/dd/yy hh:mm:ss ;;q')
set edt = format(end_date, 'mm/dd/yy hh:mm:ss ;;q')
call echo(build('start_date = ', sdt , 'end_date = ', edt))
 
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
and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00)
 
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
 
 
;Every Week's Ops call 
EXECUTE cov_phq_urinary_cath_feed "mine", start_date, end_date,
	value(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00), 0


 
;set up for data back load 
;EXECUTE cov_phq_urinary_cath_feed "mine", "01-JAN-2022 00:00:00", "31-JAN-2022 23:59:00",
;	value(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00), 0
 

 
 
/*
;Loop through all facilities.
For(fcnt = 1 to facility->rec_cnt)
 
  	;everyday
 	;EXECUTE cov_phq_sepsis_dream "mine", start_date, end_date, facility->flist[fcnt].facility_cd, 0
 
 	;Backload
	;EXECUTE cov_phq_sepsis_dream "mine", 0, "27-FEB-2019 00:00:00", "28-FEB-2019 23:59:00", facility->flist[fcnt].facility_cd
 
 	;One Facility
 	;EXECUTE cov_phq_sepsis_dream "mine", "01-FEB-2019 00:00:00", "01-FEB-2019 23:59:00", 2552503649.00, 0 ;RMC
 
Endfor */
 
 
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
 

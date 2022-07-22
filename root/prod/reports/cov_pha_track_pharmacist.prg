/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_track_pharmacist.prg
	Object name:		cov_pha_track_pharmacist
 
	Request#:			Adhoc
	Program purpose:	      Pharmacists and their work location
	Special Instruction:    Address4 is pharmacist work location - used for Pharmacy productivity data feed 
	Executing from:		

******************************************************************************/

drop program cov_pha_track_pharmacist:dba go
create program cov_pha_track_pharmacist:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

select distinct into $outdev
 
pr.name_full_formatted, position = uar_get_code_display(pr.position_cd)
, address_type = uar_get_code_display(a.address_type_cd)
, a.street_addr, a.street_addr2, a.street_addr3
, street_addr4 = trim(a.street_addr4), a.zipcode
 
from 	prsnl pr, address a
 
plan pr where pr.position_cd in(24379693.00, 637053.00)
 
join a where a.parent_entity_id = outerjoin(pr.person_id)
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120
 
 
end
go
 

 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Aug'2021
	Solution:			Quality
	Source file name:  	cov_phq_vendorid_lookup.prg
	Object name:		cov_phq_vendorid_lookup
	Request#:			10603
 	Program purpose:	      AdHoc for Quality/HIM
	Executing from:		DA2
  	Special Notes:		Jutana and team will utilize this report
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_phq_vendorid_lookup:dba go
create program cov_phq_vendorid_lookup:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Enter Vendor ID" = "" 

with OUTDEV, vendor_id
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare cnt = i4 with noconstant(0)
declare num = i4 with noconstant(0)
declare itr_var = i4 with noconstant(0)
declare vid_length_var = i4 with noconstant(0)
declare eid = vc with noconstant('')

set vid_length_var = textlen($vendor_id) 
set itr_var = 1
set cnt = 0
set num = 0

/**************************************************************
; DVDev Source Code Starts Here
**************************************************************/

Record enc(
	1 list[*]
		2 vendorid = f8
)


;-------------------------------------------------------------------
;Get encntr_id from prompt

while(itr_var <= vid_length_var)
	set cnt += 1
	set eid = substring(itr_var,9, $vendor_id)
	set itr_var += 10
	call alterlist(enc->list, cnt)
	set enc->list[cnt].vendorid = cnvtreal(eid)
endwhile

call echorecord(enc)

;-------------------------------------------------------------------
;Patient pool 
 
select into $outdev
fin = trim(ea.alias), patient_name = trim(p.name_full_formatted)
, dob = format(p.birth_dt_tm, 'mm/dd/yyyy ;;d'), mrn = trim(ea1.alias), encounter_id = e.encntr_id
, facility = uar_get_code_display(e.loc_facility_cd), disch_dt = e.disch_dt_tm ';;q'
from 
	encounter e
	, encntr_alias ea
	, encntr_alias ea1
	, person p

plan e where expand(num,1,size(enc->list,5), e.encntr_id ,enc->list[num].vendorid)
	and e.active_ind = 1
	
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1	
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1079
	and ea.active_ind = 1	

join p where p.person_id = e.person_id
	and p.active_ind = 1

with nocounter, separator=" ", format 
 
 
end go
 
 

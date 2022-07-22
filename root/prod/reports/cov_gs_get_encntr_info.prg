/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2021
	Solution:
	Source file name:	      cov_gs_get_encntr_info.prg
	Object name:		cov_gs_get_encntr_info
	Request#:
	Program purpose:	      AdHoc
	Executing from:
 	Special Notes:
 
******************************************************************************/

drop program cov_gs_get_encntr_info:dba go
create program cov_gs_get_encntr_info:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Encounter Id" = 0
	, "Alias " = "" 

with OUTDEV, enc_id, alias_prt



/**************************************************************
; DVDev Start Coding
**************************************************************/

select into $outdev

ea.alias,e.encntr_id, e.person_id, fac = uar_get_code_display(e.loc_facility_cd)
, loc = uar_get_code_display(e.location_cd),e.loc_nurse_unit_cd, p.birth_dt_tm ';;q'
, age = cnvtage(p.birth_dt_tm, e. reg_dt_tm,0), p.name_full_formatted
, nu = uar_get_code_display(e.loc_nurse_unit_cd) ,enc_type = uar_get_code_display(e.encntr_type_cd)
, e.location_cd, e.loc_facility_cd, e.encntr_type_cd, e.reg_dt_tm "@SHORTDATETIME", e.disch_dt_tm "@SHORTDATETIME"
from encounter e, encntr_alias ea, person p
where e.encntr_id = ea.encntr_id
and p.person_id = e.person_id
and (e.encntr_id = $enc_id or ea.alias = $alias_prt)
and ea.encntr_alias_type_cd = 1077

with nocounter, separator=" ", format

end
go


/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       02/22/2020
  Solution:           
  Source file name:   cov_anes_unath_notes_rpt.prg
  Object name:        cov_anes_unath_notes_rpt
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   02/22/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_anes_unath_notes_rpt:dba go
create program cov_anes_unath_notes_rpt

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


select	into $OUTDEV					
	  status = trim(substring(1,40,uar_get_code_display(ce.result_status_cd)))						
	, ev_cd_name = trim(substring(1,40,uar_get_code_display(ce.event_cd)))						
	, doc_name = trim(substring(1,255,ce.event_title_text))						
	, doc_prov = trim(substring(1,100,pr.name_full_formatted))						
	, ver_prov = trim(substring(1,100,pr2.name_full_formatted))						
	, ce.event_end_dt_tm"@SHORTDATETIME"						
	, facility = trim(substring(1,40,uar_get_code_display(e.loc_facility_cd)))						
	, mrn = trim(substring(1,14,pa.alias))						
	, fin = trim(substring(1,18,ea.alias))						
	, pt_name = trim(substring(1,100,p.name_full_formatted))						
	, ce.event_id						
from							
	clinical_event ce						
	, encounter e						
	, prsnl pr						
	, prsnl pr2						
	, person p						
	, person_alias pa						
	, encntr_alias ea						
plan ce							
	where ce.person_id > 0						
	and ce.event_cd in (value(uar_get_code_by("DISPLAYKEY",72,"ANESTHESIOLOGYPROGRESSNOTE"))						
							,value(uar_get_code_by("DISPLAYKEY",72,"PREANESTHESIANOTE"))
							,value(uar_get_code_by("DISPLAYKEY",72,"POSTANESTHESIANOTE"))
							,value(uar_get_code_by("DISPLAYKEY",72,"ANESTHESIAPROCEDURENOTE")))
	and ce.result_status_cd in(
									value(uar_get_code_by("MEANING",8,"UNAUTH"))
								)				
	and ce.valid_until_dt_tm > sysdate						
join e							
	where e.encntr_id = ce.encntr_id						
join pr							
	where pr.person_id = ce.performed_prsnl_id						
join pr2							
	where pr2.person_id = ce.verified_prsnl_id						
join p							
	where p.person_id = ce.person_id						
join ea							
	where ea.encntr_id = ce.encntr_id						
	and ea.encntr_alias_type_cd = value(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))						
	and ea.active_ind = 1						
join pa							
	where pa.person_id = p.person_id						
	and pa.alias_pool_cd = value(uar_get_code_by("DISPLAYKEY",263,"CMRN"))						
	and pa.active_ind = 1						
order							
	mrn
	, ce.event_end_dt_tm						
	, ce.event_id						
	, ev_cd_name						
	, doc_name						
	, doc_prov						
	, ver_prov						
with time = 600, format(date,";;q"),uar_code(d),seperator=" ",format					

end go

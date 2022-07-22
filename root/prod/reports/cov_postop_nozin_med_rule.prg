 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan'2019
	Solution:			Quality
	Source file name:	      cov_postop_nozin_med_rule.prg
	Object name:		cov_postop_nozin_med_rule
	Request#:			Post Op Nozin rule
	Program purpose:	      Find the documentation of SN - PACU I - CTm - Discharge from PACUI
	Executing from:		CCL
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------*/

drop program cov_postop_nozin_med_rule go
create program cov_postop_nozin_med_rule

declare pacu_disch_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "SN - PACU I - CTm - Discharge from PACUI")), protect
declare encntrid = f8 with noconstant(0.0), protect
declare personid = f8 with noconstant(0.0), protect
declare disch_doc_var = vc with noconstant(" "), protect
 
set personid = trigger_personid
set encntrid = trigger_encntrid
set retval = 0
 
;------------------------------------------------------------------------------------ 
;Evaluate discharge documentation
 
select into 'nl:'
ce.encntr_id, ce.event_cd, ce.result_val	
 
from clinical_event ce

plan ce where ce.encntr_id = trigger_encntrid
and ce.event_cd = pacu_disch_var
and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 
			where ce1.encntr_id = ce.encntr_id
			and ce1.event_cd = ce.event_cd
			and ce1.result_status_cd in(25,34,35)
			and ce1.valid_until_dt_tm > sysdate
			and ce1.valid_from_dt_tm <= sysdate
			group by ce1.encntr_id, ce1.event_cd)
detail
	disch_doc_var = ce.result_val
 
with nocounter
 
call echo(build2('val = ', disch_doc_var))
 
;-----------------------------------------------------------------------------------------------

if(disch_doc_var != '') 
	 set retval = 100
endif
 
call echo(build2('retval = ', retval))
 
 
end
go


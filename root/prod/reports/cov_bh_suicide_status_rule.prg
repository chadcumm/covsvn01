 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		May'2020
	Solution:			Behavior Health
	Source file name:	      cov_bh_suicide_status_rule.prg
	Object name:		cov_bh_suicide_status_rule
	Request#:			6476
 	Program purpose:	      Find the latest suicide risk status for the rule
 	Executing from:		Rule
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_bh_suicide_status_rule:DBA GO
CREATE PROGRAM cov_bh_suicide_status_rule:DBA
 
declare encntrid_var = f8 with noconstant(0.0), protect
declare personid_var = f8 with noconstant(0.0), protect
declare suicide_status_var = vc with noconstant(" ")
 
set personid_var = trigger_personid
set encntrid_var = trigger_encntrid
set retval = 0
 
;------------------------------------------------------------------------------------
;Assessed Risk clinical events

select into 'nl:'
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.event_cd, ce.result_val
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, rank_ord = rank() over(partition by ce.person_id order by ce.person_id, ce.event_id desc)
 
from 	clinical_event ce
 
plan ce where ce.person_id = personid_var
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	and ce.event_cd = 31580383.00 ;assessed_risk
 
order by ce.person_id, rank_ord

detail
	if(rank_ord = 1) 
		suicide_status_var = trim(ce.result_val)
	endif	
 
with nocounter

;------------------------------------------------------------------------------------

if(suicide_status_var != '')
	 set retval = 100
endif

call echo(build2('Risk status = ', suicide_status_var)) 
call echo(build2('retval = ', retval))

end go

;------------------------------------------------------------------------------------



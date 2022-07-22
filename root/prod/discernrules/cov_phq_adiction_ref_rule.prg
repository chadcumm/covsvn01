 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			    Geetha Saravanan
	Date Written:		APR'2018
	Solution:			Population Health Quality
	Source file name:	cov_phq_adiction_ref_rule.prg
	Object name:		cov_phq_adiction_ref_rule
	Request#:			794
 
	Program purpose:	To see if there's any referral made already on this encounter.
 
	Executing from:		CCL
 
 	Special Notes:      Called by cov_phq_adiction_refral rule
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_phq_adiction_ref_rule:DBA GO
CREATE PROGRAM cov_phq_adiction_ref_rule:DBA
 
;declare retval       = i4 with noconstant(0), PROTECT
declare encntrid_var = f8 with noconstant(0.0), PROTECT
declare personid_var = f8 with noconstant(0.0), PROTECT
declare refral_var   = f8 WITH constant(uar_get_code_by('DISPLAY', 72, 'Reg Outpt Substance Treatment Refer')), PROTECT
 
SET retval = 0
SET encntrid_var = trigger_encntrid ;104006555;trigger_encntrid
SET personid_var = trigger_personid
 
SELECT INTO "NL:"
 
  ce.result_val
, ce.updt_dt_tm
, event = uar_get_code_display(ce.event_cd)
 
from clinical_event ce
 
where ce.encntr_id = encntrid_var
and ce.person_id = personid_var
and ce.event_cd = refral_var
 
HEAD REPORT
	cnt = 0
DETAIL
	cnt = cnt + 1
FOOT REPORT
 
	if (cnt > 1)
		retval = 100
	endif
 
WITH nocounter
 
 
 
/*WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
IF (CURQUAL > 0)
	set retval = 100
ENDIF
*/
 
call echo(build('retval = ',retval))
 
END
GO
 
 
 
 

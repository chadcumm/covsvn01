/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Jun'2022
	Solution:			Quality
	Source file name:	      cov_phq_find_codeblue.prg
	Object name:		cov_phq_find_codeblue
	Request#:			13014
	Program purpose:	      Alert on Code Blue event
	Executing from:		Rule / Smart Zone
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
-------------------------------------------------------------------------------
 
/22    Geetha    CR#13014     Initial release
 
******************************************************************************/

drop program cov_phq_find_codeblue:dba go
create program cov_phq_find_codeblue:dba


/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare inpatient_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect

;Encounter type: Inpt, Observation, Outpt in a bed for procedure, ED, Outpt, Behavorial Health (really for SBH only).

;   21910883.00	Date, Time of Cardiopulmonary Arrest
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

select ce.encntr_id, ce.event_cd,  ce.result_val, ce.event_end_dt_tm
from clinical_event ce
where ce.event_cd = 21910883.00
and ce.event_end_dt_tm >= cnvtdatetime('01-JAN-2022 00:00:00')
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



  125348890.00
  125238273.00


#exitscript
end go








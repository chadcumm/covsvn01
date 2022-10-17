/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Jun'2022
	Solution:			Quality
	Source file name:	      cov_eks_get_codeblue.prg
	Object name:		cov_eks_get_codeblue
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

drop program cov_eks_get_codeblue:dba go
create program cov_eks_get_codeblue:dba


/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare encntrid_var = f8 with noconstant(0.0), protect
declare personid_var = f8 with noconstant(0.0), protect
;declare log_message = vc with noconstant(' '), protect
;declare log_misc1 = vc with noconstant(' '), protect

declare result_dt_var = vc with noconstant(' '), protect
declare result_dt_var_dq = dq8 ;with noconstant(0), protect
declare diff_var = i4 with noconstant(0), protect
 
set personid_var = trigger_personid
set encntrid_var = trigger_encntrid ;125348890.00, 125359334.00 - dev,grp
set retval = 0

declare inpatient_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
declare obs_var        = f8 with constant(uar_get_code_by("DISPLAY", 71, "Observation")), protect
declare outpat_bed_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Outpatient in a Bed")), protect
declare ed_var         = f8 with constant(uar_get_code_by("DISPLAY", 71, "Emergency")), protect
declare outpat_var     = f8 with constant(uar_get_code_by("DISPLAY", 71, "Outpatient")), protect
declare bh_var         = f8 with constant(uar_get_code_by("DISPLAY", 71, "Behavioral Health")), protect
declare cardio_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date, Time of Cardiopulmonary Arrest")), protect

 
/**************************************************************
; DVDev Start Coding
**************************************************************/

select into 'nl:'

ce.encntr_id, ce.event_cd,  ce.result_val, ce.event_end_dt_tm

from encounter e
	, clinical_event ce
	, (left join ce_date_result cdr on cdr.event_id = ce.event_id)

plan e where e.encntr_id = encntrid_var
	and e.encntr_status_cd = 854.00 ;Active
	and e.encntr_type_cd in(inpatient_var, obs_var, outpat_bed_var, ed_var, outpat_var, bh_var)

join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = cardio_var
		and ce1.result_val != ' '
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
join cdr 
	
order by ce.encntr_id

Head report
	log_message = "Cardio Arrest record Not Found"
	retval = 0
Detail
	if(cdr.result_dt_tm != null)
	 	result_dt_var = format(cdr.result_dt_tm, 'mm/dd/yy hh:mm:ss;;q')
	 	result_dt_var_dq = cdr.result_dt_tm
	else
	 	result_dt_var = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm:ss;;q')	
	 	result_dt_var_dq = ce.event_end_dt_tm
	endif
	diff_var = datetimediff(cnvtdatetime(curdate,curtime3), cnvtdatetime(result_dt_var_dq) ,3)	
	if(diff_var < 48)
		log_message = build2("Cardio Arrest record found within ",trim(cnvtstring(diff_var)), "Hrs - ", result_dt_var)
		log_misc1 = result_dt_var
		retval = 100
	endif	
with nocounter

call echo(build2('cur_dt = ', format(cnvtdatetime(curdate,curtime3), 'mm/dd/yy hh:mm:ss;;q')))
call echo(build2('rslt_dt = ', format(result_dt_var_dq, 'mm/dd/yy hh:mm:ss;;q')))
call echo(build2('retval = ', retval))
call echo(build2('log_message = ', log_message))
call echo(build2('log_misc1 = ', log_misc1))

end go


/*
  125348890.00
  125238273.00


ALIAS	ENCNTR_ID	PERSON_ID
2124600147	  125348890.00	   20753789.00

ALIAS	ENCNTR_ID	PERSON_ID
2119001211	  125238273.00	   15459793.00
 */






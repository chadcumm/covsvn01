/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				     Chad Cummings
	Date Written:		   03/01/2019
	Solution:			     Discern Expert
	Source file name:	 	cov_check_health_plan.prg
	Object name:		   cov_check_health_plan
	Request #:

	Program purpose:

	Executing from:		EKS

 	Special Notes:		Called by Discern Expert template(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_check_health_plan:dba go
create program cov_check_health_plan:dba

free record t_rec
record t_rec
(
	1 person_id	= f8
	1 encntr_id = f8
	
)

select
	hp.plan_name
	,uar_get_code_display(hp.financial_class_cd)
	,uar_get_code_meaning(hp.financial_class_cd)
	,hp.financial_class_cd
from
	 encounter e
	,encntr_plan_reltn epr
	,health_plan hp
	,code_value cv1
plan e
	;where e.encntr_id = ENCOUNTERID:{PatientInfo}                
join epr
	where epr.encntr_id = e.encntr_id
	and   epr.active_ind = 1
	and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   epr.priority_seq in(1,2)
join hp
	where hp.health_plan_id = epr.health_plan_id
	and   hp.active_ind = 1
	and   hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join cv1
	where cv1.code_value = hp.financial_class_cd
	and   cv1.cdf_meaning = "MEDICARE"
order by
	 e.encntr_id
	,epr.priority_seq
	,hp.health_plan_id
head report
	log_retval = 0
	log_message = "Primary or Secondary insurance finanical class is not MEDICARE"
head e.encntr_id
	log_message = ""
head hp.health_plan_id
	log_retval = 100
	log_message = concat(log_message,trim(hp.plan_name)
			," found on encounter as ",trim(cnvtstring(epr.priority_seq)),";")
with nocounter,nullreport 
#exit_script




end
go

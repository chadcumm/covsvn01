 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		Feb'2018
	Solution:			PathNet - General laboratory - Speciman Management
	Source file name:	      cov_gl_bluecare_ins_rule.prg
	Object name:		cov_gl_bluecare_ins_rule
	Request#:			42
 	Program purpose:	      Find the insurance plan name for an encounter that is passed as a parameter
					from cov_gl_bluecare_insu EKM and return the logical value to EKM.
 	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	---------------------------------------------------------------------------------------
02/20/2019   Geetha   CR# 4459 - Rule will also look back previous encounter's insurance info if it not
			    finding with current encounter
 
06/26/2019   Geetha   CR# 5156 - Need to have the rule 1) look for BlueCare/Tenncare as the Primary insurance only and
			    2) remove Medicare BlueCare Plus
 
08/16/2202   Geetha   CR# 12200 - Modification applied to find the primary insurance 

******************************************************************************/
 
DROP PROGRAM cov_gl_bluecare_ins_rule:DBA GO
CREATE PROGRAM cov_gl_bluecare_ins_rule:DBA
 
declare encntrid = f8 with noconstant(0.0), protect
declare personid = f8 with noconstant(0.0), protect
declare q1_plan_name_var = vc with noconstant(" ")
declare q2_plan_name_var = vc with noconstant(" ")
declare q3_plan_name_var = vc with noconstant(" ")
 
set personid = trigger_personid
set encntrid = trigger_encntrid
set retval = 0
 
;--------------------------------------------------------------------------
;CCL - 06/26/2019 CR# 5156
;--------------------------------------------------------------------------
 
;----- q1 ------------------------------------
;Current encounter have Blue or Tenn?
select distinct into 'nl:'
 
	h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq
from
	health_plan h, encntr_plan_reltn epr
 
plan epr where epr.encntr_id = encntrid
	and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and epr.priority_seq = 1
	and epr.active_ind = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and (cnvtupper(h.plan_name) = "BLUECARE" or cnvtupper(h.plan_name) = "TENNCARE*")
	and (cnvtupper(h.plan_name) != "BLUECARE PLUS")
	and h.active_ind = 1
 
detail
	q1_plan_name_var = h.plan_name
	call echo(build2('q1 = ', q1_plan_name_var)) ;Current encounter have BLUECARE/TENNCARE  as a primary (rule should alert)
 
with nocounter
 
;----- q2 -------------------------------------
;Previous Encounter have Blue or Tenn?
 
select distinct into 'nl:'
  h.plan_name, h.active_ind, h.beg_effective_dt_tm
, h.end_effective_dt_tm, h.health_plan_id
, epr.encntr_id, epr.person_id
 
from health_plan h, encntr_plan_reltn epr
,((	select distinct e.person_id, e.encntr_id, e.reg_dt_tm
	,erank = rank() over(partition by e.person_id order by e.reg_dt_tm desc)
	from person p, encounter e
	where e.person_id = (select e1.person_id from encounter e1 where e1.encntr_id = encntrid)
	and p.person_id = e.person_id
	;and e.disch_dt_tm != null
	with sqltype("f8", "f8", "dq8", "i4") )i
 )
 
plan i where i.erank = 2
 
join epr where epr.encntr_id = i.encntr_id
	and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and epr.priority_seq = 1
	and epr.active_ind = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and (cnvtupper(h.plan_name) = "BLUECARE" or cnvtupper(h.plan_name) = "TENNCARE*")
	and (cnvtupper(h.plan_name) != "BLUECARE PLUS")
	and h.active_ind = 1
 
detail
	q2_plan_name_var = h.plan_name
	call echo(build2('q2 = ', q2_plan_name_var)) ;(previous encounter have BLUECARE/TENN as a primary)
with nocounter
 
;----- q3 ------------------------------------
 
;Current encounter - is there a primary insurance(any kind)? If so then rule should not look into the previous encounter.
select distinct into 'nl:'
 	h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq
from
	health_plan h, encntr_plan_reltn epr
 
plan epr where epr.encntr_id = encntrid
	and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and epr.priority_seq = 1
	and epr.active_ind = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and h.active_ind = 1
 
detail
	q3_plan_name_var = h.plan_name
 	call echo(build2('q3 = ', q3_plan_name_var)) ;(current encounter have some kind of active primary insurance)
with nocounter
 
;-----------------------------------------------------------------------------------------------
 
if(q1_plan_name_var != '') ;(current have BULECARE as a primary so rule should alert)
	 set retval = 100
	 call echo(build2('retval = ', retval))
	 call echo(build2('q1 = ', retval))
elseif(q2_plan_name_var != '' and q3_plan_name_var = '') ;(currrent have no primary(any kind) and previous have BLUE/TENNCARE as primary
	set retval = 100
	 call echo(build2('retval = ', retval))
	 call echo(build2('q2 & q3 = ', retval))
 
endif
 

;--------------------------------------------------------------------------------------
;Final 
call echo(build2('Final section - retval = ',retval , '-- q1 = ', q1_plan_name_var)) 
call echo(build2('Final section - retval = ',retval , '-- q2 = ', q2_plan_name_var)) 
call echo(build2('Final section - retval = ',retval , '-- q3 = ', q3_plan_name_var)) 



end
go
 
 
/* 11/18/22
;Person level primary

select ea.alias, e.person_id, e.encntr_id, e.reg_dt_tm, epr.priority_seq, epr.active_ind, epr.member_nbr
from encounter e, encntr_alias ea,encntr_plan_reltn epr
where e.person_id = 16419557.00
and ea.encntr_id = e.encntr_id
and ea.encntr_alias_type_cd = 1077
and epr.encntr_id = e.encntr_id
and epr.active_ind = 1
and epr.priority_seq = 1
and epr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
order by e.reg_dt_tm desc, ea.alias
 
;----------------------------------------------------- 
;History of insurance update

select epr.* 
from encntr_plan_reltn epr
where epr.person_id = 16419557.00
;where epr.encntr_id =     132500933.00
order by epr.encntr_id


drop program cov_eks_get_veteran_info:dba go
create program cov_eks_get_veteran_info:dba

free record t_rec
record t_rec
(
	1 log_message 		= vc
	1 misc1				= vc
	1 retval 			= i2
	1 continue_ind 		= i2
	1 encntr_id			= f8
	1 person_id			= f8
	1 serve_us_military	= vc
	1 branch_us_military= vc
	1 era_served		= vc
	1 prim_hp			= vc
	1 sec_hp			= vc
	1 patient_name		= vc
	1 fin				= vc
)

set t_rec->retval 		= -1 ;initialize to failed
set t_rec->continue_ind	= 0
set t_rec->encntr_id	= link_encntrid

set t_rec->log_message = concat(trim(cnvtstring(link_encntrid)),":",trim(cnvtstring(t_rec->encntr_id)))

if (t_rec->encntr_id = 0.0)
	go to exit_script
endif

select into "nl:" 
from 
	 encounter e 
 	,person p
 	,encntr_alias ea
plan e
	where e.encntr_id = t_rec->encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)	
order by
	 e.encntr_id
	,ea.beg_effective_dt_tm desc
head e.encntr_id
	t_rec->person_id = e.person_id
	t_rec->fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->patient_name = p.name_full_formatted
with nocounter

set t_rec->log_message = concat(trim(t_rec->log_message),";",trim(cnvtstring(t_rec->person_id)))

if (t_rec->person_id = 0.0)
	go to exit_script
endif
	
select into "nl:"
from
	clinical_Event ce 
plan ce
	where 	ce.person_id = t_rec->person_id
	and		ce.event_cd in(
							 value(uar_get_code_by("DISPLAY",72,"Serve US Military"))
							,value(uar_get_code_by("DISPLAY",72,"Branch of US Military"))
							,value(uar_get_code_by("DISPLAY",72,"Era Served US Military"))
							
							)
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.person_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
head report
	t_rec->continue_ind = 0
head ce.event_cd
	case (uar_get_code_display(ce.event_cd))
		of "Serve US Military":			t_rec->serve_us_military 	= ce.result_val	
		of "Branch of US Military":		t_rec->branch_us_military	= ce.result_val
		of "Era Served US Military":	t_rec->era_served			= ce.result_val
	endcase
foot report
	if (t_rec->serve_us_military = "Yes")
		t_rec->continue_ind = 1
		if (t_rec->era_served in("Cold War","Gulf War"))
			t_rec->era_served = build2("in the ",t_rec->era_served)
		elseif (t_rec->era_served in("Korea","Vietnam","Afghanistan/Iraq"))
			t_rec->era_served = build2("in ",t_rec->era_served)
		else
			t_rec->era_served = build2("during ",t_rec->era_served)
		endif
	endif
with nocounter

if (t_rec->continue_ind != 1)
	set t_rec->retval = 0
	go to exit_script
endif

set t_rec->misc1	= build2(
								 "This patient served in the "
								,trim(t_rec->branch_us_military)
								," branch of the US Military "
								,trim(t_rec->era_served)
								,"."	
							)

select into "nl:"
from 
	 encounter e
	,encntr_plan_reltn epr
 	,health_plan hp 
plan e 
	where e.encntr_id = t_rec->encntr_id
join epr 
 	where epr.encntr_id = e.encntr_id 
 	and epr.active_ind = 1 
 	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) 
 	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) 
 	and epr.priority_seq in(1,2) 
join hp 
	where hp.health_plan_id = epr.health_plan_id
	and hp.active_ind = 1 
	and hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) 
	and hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	;and hp.plan_name_key = "SELF*"
order by
	 e.encntr_id
	,epr.priority_seq
	,epr.beg_effective_dt_tm desc
head report 
	cnt = 0
head e.encntr_id	
	cnt = 0
head epr.priority_seq
	case (epr.priority_seq)
		of 1:	t_rec->prim_hp	= hp.plan_name
		of 2:	t_rec->sec_hp	= hp.plan_name
	endcase
foot report
	cnt = 0
with nocounter

if (	(cnvtupper(t_rec->prim_hp) = "SELF*") or (cnvtupper(t_rec->sec_hp) = "SELF*"))
	set t_rec->misc1	= build2(	 t_rec->misc1
								 	," @NEWLINE@NEWLINE@NEWLINE "
								 	,"This patient is Self Pay"
								 )
endif

set t_rec->retval = 100

#exit_script

set t_rec->log_message = concat(trim(t_rec->log_message),";",trim(cnvtrectojson(t_rec)))

set retval		= t_rec->retval
set log_misc1 	= t_rec->misc1
set log_message = t_rec->log_message

call echorecord(t_rec)

end go


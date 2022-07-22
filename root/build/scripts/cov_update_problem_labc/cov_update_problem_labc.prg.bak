drop program cov_update_problem_labc go
create program cov_update_problem_labc
 
prompt
	"Person_Id" = 0
 
with PERSON_ID
 
record t_rec
(
	1 prompt_val
	 2 person_id			= f8
	1 parser
	 2 person				= vc
	1 max_persons			= i2
	1 cnt	 				= i2
	1 qual[*]
	 2 person_id 			= f8
	 2 name					= vc
	 2 problem_cnt			= i2
	 2 problem_qual[*]
	  3 problem_id 			= f8
	  3 problem_instance_id = f8
	  3 nomenclature_id 	= f8
	  3 source_identifier 	= vc
	  3 source_string		= vc
)
 
set t_rec->max_persons = 1000
 
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->prompt_val.person_id = value(parameter(1,0))
endif
 
record 4170165_request (
  1 person_id = f8
  1 problem [*]
    2 problem_action_ind = i2
    2 problem_id = f8
    2 problem_instance_id = f8
    2 organization_id = f8
    2 nomenclature_id = f8
    2 annotated_display = vc
    2 source_vocabulary_cd = f8
    2 source_identifier = vc
    2 problem_ftdesc = vc
    2 classification_cd = f8
    2 confirmation_status_cd = f8
    2 qualifier_cd = f8
    2 life_cycle_status_cd = f8
    2 life_cycle_dt_tm = dq8
    2 persistence_cd = f8
    2 certainty_cd = f8
    2 ranking_cd = f8
    2 probability = f8
    2 onset_dt_flag = i2
    2 onset_dt_cd = f8
    2 onset_dt_tm = dq8
    2 course_cd = f8
    2 severity_class_cd = f8
    2 severity_cd = f8
    2 severity_ftdesc = vc
    2 prognosis_cd = f8
    2 person_aware_cd = f8
    2 family_aware_cd = f8
    2 person_aware_prognosis_cd = f8
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 status_upt_precision_flag = i2
    2 status_upt_precision_cd = f8
    2 status_upt_dt_tm = dq8
    2 cancel_reason_cd = f8
    2 problem_comment [*]
      3 problem_comment_id = f8
      3 comment_action_ind = i2
      3 comment_dt_tm = dq8
      3 comment_tz = i4
      3 comment_prsnl_id = f8
      3 problem_comment = vc
      3 beg_effective_dt_tm = dq8
      3 end_effective_dt_tm = dq8
    2 problem_discipline [*]
      3 discipline_action_ind = i2
      3 problem_discipline_id = f8
      3 management_discipline_cd = f8
      3 beg_effective_dt_tm = dq8
      3 end_effective_dt_tm = dq8
    2 problem_prsnl [*]
      3 prsnl_action_ind = i2
      3 problem_reltn_dt_tm = dq8
      3 problem_reltn_cd = f8
      3 problem_prsnl_id = f8
      3 problem_reltn_prsnl_id = f8
      3 beg_effective_dt_tm = dq8
      3 end_effective_dt_tm = dq8
    2 secondary_desc_list [*]
      3 group_sequence = i4
      3 group [*]
        4 secondary_desc_id = f8
        4 nomenclature_id = f8
        4 sequence = i4
    2 related_problem_list [*]
      3 active_ind = i2
      3 child_entity_id = f8
      3 reltn_subtype_cd = f8
      3 priority = i4
      3 child_nomen_id = f8
      3 child_ftdesc = vc
    2 contributor_system_cd = f8
    2 problem_uuid = vc
    2 problem_instance_uuid = vc
    2 problem_type_flag = i4
    2 show_in_pm_history_ind = i2
    2 life_cycle_dt_cd = f8
    2 life_cycle_dt_flag = i2
    2 laterality_cd = f8
    2 originating_nomenclature_id = f8
    2 onset_tz = i4
  1 user_id = f8
  1 skip_fsi_trigger = i2
  1 interfaced_problems_flag = i2
)
 
declare person_where = vc with noconstant("")
 
if (t_rec->prompt_val.person_id > 0.0)
	set t_rec->parser.person = build2(" p.person_id = ",t_rec->prompt_val.person_id)
else
	set t_rec->parser.person = " 1=1"
	;go to exit_script
endif
 
set person_where = t_rec->parser.person
call echo(build("person_where=",person_where))
call echo("Looking for problems")
 
 
select into "nl:"
from
	 problem p
	,nomenclature n
	,person p1
plan p
	where 	p.active_ind = 1
	and 	p.active_status_prsnl_id in(17149833.00, 1)
	and     p.confirmation_status_cd = value(uar_get_code_by("MEANING",12031,"CONFIRMED"))
	and     p.classification_cd = value(uar_get_code_by("MEANING",12033,"PATSTATED"))
	and     p.life_cycle_status_cd = value(uar_get_code_by("MEANING",12030,"ACTIVE"))
	;and     p.updt_task 				= 3055000
	and     parser(person_where)
join n
	where 	n.nomenclature_id			 = p.nomenclature_id
	and 	n.nomenclature_id 			 not in(      8789191.00,    22058869.00)
	and     n.source_identifier in(	"202940017",
									"2771092016",
									"3897180018",
									"3083600011",
									"3873507016",
									"2158600017",
									"2470393015",
									"3286559017",
									"11203012",
									;"1494811646", ;covid
									"10871012",
									"3873501015",
									"713743")
join p1
	where p1.person_id = p.person_id
order by
	 p.person_id
	,p.problem_id
head report
	t_rec->cnt = 0
head p.person_id
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].person_id			= p.person_id
	t_rec->qual[t_rec->cnt].name				= p1.name_full_formatted
head p.problem_id
	t_rec->qual[t_rec->cnt].problem_cnt = (t_rec->qual[t_rec->cnt].problem_cnt + 1)
	stat = alterlist(t_rec->qual[t_rec->cnt].problem_qual,t_rec->qual[t_rec->cnt].problem_cnt)
	t_rec->qual[t_rec->cnt].problem_qual[t_rec->qual[t_rec->cnt].problem_cnt].nomenclature_id 		= p.nomenclature_id
	t_rec->qual[t_rec->cnt].problem_qual[t_rec->qual[t_rec->cnt].problem_cnt].problem_id			= p.problem_id
	t_rec->qual[t_rec->cnt].problem_qual[t_rec->qual[t_rec->cnt].problem_cnt].problem_instance_id	= p.problem_instance_id
	t_rec->qual[t_rec->cnt].problem_qual[t_rec->qual[t_rec->cnt].problem_cnt].source_identifier		= n.source_identifier
	t_rec->qual[t_rec->cnt].problem_qual[t_rec->qual[t_rec->cnt].problem_cnt].source_string			= n.source_string
with nocounter
 
for (i=1 to t_rec->cnt)
 if (i <= t_rec->max_persons)
	set stat = initrec(4170165_request)
	free record 4170165_reply
 
	set 4170165_request->person_id = t_rec->qual[i].person_id
 
	for (k=1 to t_rec->qual[i].problem_cnt)
		set stat = alterlist(4170165_request->problem,k)
		set 4170165_request->problem[k].problem_id 			= t_rec->qual[i].problem_qual[k].problem_id
		set 4170165_request->problem[k].problem_instance_id	= t_rec->qual[i].problem_qual[k].problem_instance_id
	endfor
 
	select into "nl:"
		p.nomenclature_id
	from
		problem p,
		(dummyt d1 with seq = value(size(4170165_request->problem,5)))
	plan d1
		where 4170165_request->problem[d1.seq].problem_instance_id > 0
	join p
		where p.problem_instance_id = 4170165_request->problem[d1.seq].problem_instance_id
	detail
		4170165_request->problem[d1.seq].problem_action_ind			= 2
		4170165_request->problem[d1.seq].nomenclature_id 			= p.nomenclature_id
		4170165_request->problem[d1.seq].classification_cd 			= value(uar_get_code_by("DISPLAY",12033,"Lab Confirmed"))
		4170165_request->problem[d1.seq].persistence_cd 			= p.persistence_cd
		4170165_request->problem[d1.seq].confirmation_status_cd 	= p.confirmation_status_cd
		4170165_request->problem[d1.seq].life_cycle_status_cd 		= p.life_cycle_status_cd
		4170165_request->problem[d1.seq].life_cycle_dt_tm 			= p.life_cycle_dt_tm
		4170165_request->problem[d1.seq].onset_dt_cd 				= p.onset_dt_cd
		4170165_request->problem[d1.seq].onset_dt_tm 				= p.onset_dt_tm
		4170165_request->problem[d1.seq].ranking_cd 				= p.ranking_cd
		4170165_request->problem[d1.seq].certainty_cd 				= p.certainty_cd
		4170165_request->problem[d1.seq].probability 				= p.probability
		4170165_request->problem[d1.seq].person_aware_cd 			= p.person_aware_cd
		4170165_request->problem[d1.seq].prognosis_cd 				= p.prognosis_cd
		4170165_request->problem[d1.seq].person_aware_prognosis_cd	= p.person_aware_prognosis_cd
		4170165_request->problem[d1.seq].family_aware_cd 			= p.family_aware_cd
		4170165_request->problem[d1.seq].cancel_reason_cd 			= p.cancel_reason_cd
		4170165_request->problem[d1.seq].course_cd 					= p.course_cd
		4170165_request->problem[d1.seq].onset_dt_flag 				= p.onset_dt_flag
		4170165_request->problem[d1.seq].status_upt_precision_cd 	= p.status_updt_precision_cd
		4170165_request->problem[d1.seq].status_upt_precision_flag	= p.status_updt_flag
		4170165_request->problem[d1.seq].qualifier_cd 				= p.qualifier_cd
		4170165_request->problem[d1.seq].annotated_display 			= p.annotated_display
		4170165_request->problem[d1.seq].severity_class_cd 			= p.severity_class_cd
		4170165_request->problem[d1.seq].severity_cd 				= p.severity_cd
		4170165_request->problem[d1.seq].severity_ftdesc 			= p.severity_ftdesc
		4170165_request->problem[d1.seq].problem_instance_uuid		= p.problem_instance_uuid
		4170165_request->problem[d1.seq].problem_uuid				= p.problem_uuid
		4170165_request->problem[d1.seq].contributor_system_cd		= p.contributor_system_cd
		4170165_request->problem[d1.seq].problem_ftdesc				= p.problem_ftdesc
	with nocounter
	call echorecord(4170165_request)
	if (size(4170165_request->problem,5) > 0)
		set stat = tdbexecute(600005,3072000,4170165,"REC",4170165_request,"REC",4170165_reply,1)
		call echorecord(4170165_reply)
	endif
 endif
endfor
 
#exit_script
;call echorecord(t_rec)
end go

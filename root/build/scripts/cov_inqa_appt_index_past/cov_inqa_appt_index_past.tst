
free set 651164Request go
record 651164Request (
  1 call_echo_ind = i2   
  1 program_name = vc  
  1 advanced_ind = i2   
  1 query_type_cd = f8   
  1 query_meaning = vc  
  1 sch_query_id = f8   
  1 qual [*]   
    2 parameter = vc  
    2 oe_field_id = f8   
    2 oe_field_value = f8   
    2 oe_field_display_value = vc  
    2 oe_field_dt_tm_value = dq8   
    2 oe_field_meaning_id = f8   
    2 oe_field_meaning = vc  
    2 label_text = vc  
) go

free set 651164Reply go
set 651164Request->call_echo_ind = 1 go
set 651164Request->program_name = "cov_inqa_appt_index_past" go
set 651164Request->advanced_ind = 1 go
set 651164Request->query_type_cd = 4054263 go
set 651164Request->query_meaning = "APPTINDEXPAS" go
set 651164Request->sch_query_id = 614425 go
set stat = alterlist(651164Request->qual,1) go
set 651164Request->qual[1].oe_field_value =  15553745 go
set 651164Request->qual[1].oe_field_meaning = "PERSON" go

select into "nl:"
	e.person_id
from
	encntr_alias ea
	,encounter e
plan ea
	where ea.alias = "2105602557"
	and   ea.active_ind = 1
join e
	where e.encntr_id = ea.encntr_id
detail
	651164Request->qual[1].oe_field_value =  e.person_id
with nocounter go

;set stat = tdbexecute(600005,652000,651164,"REC",651164Request,"REC",651164Reply) go
execute cov_inqa_appt_index_past with replace(REQUEST,651164REQUEST), replace(REPLY,651164REPLY) go

;call echorecord(651164Reply) go

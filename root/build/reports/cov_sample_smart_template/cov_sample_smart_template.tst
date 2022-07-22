free set request go
record request
(
  1 output_device     = vc
  1 script_name       = vc
  1 person_cnt        = i4
  1 person[*]
      2 person_id     = f8
  1 visit_cnt = i4
  1 visit[*]
      2 encntr_id     = f8
  1 prsnl_cnt = i4
  1 prsnl[*]
      2 prsnl_id      = f8
  1 nv_cnt = i4
  1 nv[*]
      2 pvc_name      = vc
      2 pvc_value     = vc
  1 batch_selection   = vc
) go
 
select into "nl:"
from
	encntr_alias ea
	,encounter e
plan ea
	where ea.alias = "1835300010"
join e
	where e.encntr_id = ea.encntr_id
head report
	cnt = 1
detail
	request->visit_cnt = cnt
	stat = alterlist(request->visit,cnt)
	request->visit[cnt].encntr_id = e.encntr_id
 
	request->person_cnt = cnt
	stat = alterlist(request->person,cnt)
	request->person[cnt].person_id = e.person_id
with nocounter go
 
execute cov_sample_smart_template go

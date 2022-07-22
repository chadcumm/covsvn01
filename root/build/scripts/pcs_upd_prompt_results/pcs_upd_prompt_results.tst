free record request go
record REQUEST (
  1 order_id = f8
  1 catalog_cd = f8
  1 accession_id = f8
  1 accession = vc
  1 order_mnemonic = vc
  1 result_list [*]
    2 oe_field_id = f8
    2 result_value = f8
    2 result_dt_tm_value = dq8
    2 result_display_value = vc
  1 result_personnel_id = f8
) go
 
set request->order_id = 2293724693 go
 
 
select into "nl:"
from
	orders o
	,accession_order_r aor
plan o
	where o.order_id = request->order_id
join aor
	where aor.order_id = o.order_id
detail
	request->catalog_cd =  o.catalog_cd
	request->order_mnemonic = "COVID19 In-house"
	request->accession_id = aor.accession_id
	request->accession = aor.accession
	request->result_personnel_id = o.updt_id
	stat = alterlist(request->result_list,8)
	request->result_list[1].oe_field_id = 3154115347
	request->result_list[1].result_value = 959901
	request->result_list[1].result_display_value = "Yes"
	request->result_list[2].oe_field_id = 3154115351
	request->result_list[2].result_value = 959901
	request->result_list[2].result_display_value = "Yes"
	request->result_list[3].oe_field_id = 3154115355
	request->result_list[3].result_value = 959903
	request->result_list[3].result_display_value = "No"
	request->result_list[4].oe_field_id = 3154115359
	request->result_list[4].result_value = 959903
	request->result_list[4].result_display_value = "No"
	request->result_list[5].oe_field_id = 3154115363
	request->result_list[5].result_value = 959903
	request->result_list[5].result_display_value = "No"
	request->result_list[6].oe_field_id = 3154115367
	request->result_list[6].result_value = 959903
	request->result_list[6].result_display_value = "No"
	request->result_list[7].oe_field_id = 3154115371
	request->result_list[7].result_value = 292428329
	request->result_list[7].result_display_value = "Not Pregnant"
	request->result_list[8].oe_field_id = 3154558365
	request->result_list[8].result_dt_tm_value = cnvtdatetime(curdate,curtime3)
	request->result_list[8].result_display_value = format(cnvtdatetime(curdate,curtime3),";;q")
 
with nocounter go
 
 
;set stat = tdbexecute(560201,273020,1050056,"REC",REQUEST,"REC",REPLY) go
call echorecord(request) go
 
execute pcs_upd_prompt_results go
commit go

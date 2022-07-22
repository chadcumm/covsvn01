
free record ops_request2 go

record ops_request2 (
  1 Output_Dist = c100  
  1 Batch_Selection = c100  
  1 Ops_Date = dq8   
  1 address_location_cd = f8   
  1 cur_owner_area_cd = f8   
  1 cur_inv_area_cd = f8   
) go


 
Free record ops_reply2 go
record ops_reply2 (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 
set ops_request2->batch_selection = "MODE[UPDATE] SORT[NAME] OWN[2554362747] INV[2554362755] LOC[2552503613] PATENCSTATUS[0]" go
set ops_request2->output_dist = "cpt_b_revcycl_a_mfp" go
set ops_request2->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 225211 go
	
;set stat = tdbexecute(4800,4801,225211,"REC",ops_request2,"REC",ops_reply2) go

execute cov_bbt_ops_batch_release with replace("REQUEST",OPS_REQUEST2,2), replace("REPLY",OPS_REPLY2,2) go
  
call echorecord(ops_reply2) go



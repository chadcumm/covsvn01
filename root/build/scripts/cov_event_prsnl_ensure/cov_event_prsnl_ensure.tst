
free record 1000015_request go
record 1000015_request (
  1 ensure_type = i2   
  1 version_dt_tm = dq8   
  1 version_dt_tm_ind = i2   
  1 event_prsnl  
    2 event_prsnl_id = f8   
    2 person_id = f8   
    2 event_id = f8   
    2 action_type_cd = f8   
    2 request_dt_tm = dq8   
    2 request_dt_tm_ind = i2   
    2 request_prsnl_id = f8   
    2 request_prsnl_ft = vc  
    2 request_comment = vc  
    2 action_dt_tm = dq8   
    2 action_dt_tm_ind = i2   
    2 action_prsnl_id = f8   
    2 action_prsnl_ft = vc  
    2 proxy_prsnl_id = f8   
    2 proxy_prsnl_ft = vc  
    2 action_status_cd = f8   
    2 action_comment = vc  
    2 change_since_action_flag = i2   
    2 change_since_action_flag_ind = i2   
    2 action_prsnl_pin = vc  
    2 defeat_succn_ind = i2   
    2 ce_event_prsnl_id = f8   
    2 valid_from_dt_tm = dq8   
    2 valid_from_dt_tm_ind = i2   
    2 valid_until_dt_tm = dq8   
    2 valid_until_dt_tm_ind = i2   
    2 updt_dt_tm = dq8   
    2 updt_dt_tm_ind = i2   
    2 updt_task = i4   
    2 updt_task_ind = i2   
    2 updt_id = f8   
    2 updt_cnt = i4   
    2 updt_cnt_ind = i2   
    2 updt_applctx = i4   
    2 updt_applctx_ind = i2   
    2 long_text_id = f8   
    2 linked_event_id = f8   
    2 request_tz = i4   
    2 action_tz = i4   
    2 system_comment = vc  
    2 event_action_modifier_list [*]   
      3 ce_event_action_modifier_id = f8   
      3 event_action_modifier_id = f8   
      3 event_id = f8   
      3 event_prsnl_id = f8   
      3 action_type_modifier_cd = f8   
      3 valid_from_dt_tm = dq8   
      3 valid_from_dt_tm_ind = i2   
      3 valid_until_dt_tm = dq8   
      3 valid_until_dt_tm_ind = i2   
      3 updt_dt_tm = dq8   
      3 updt_dt_tm_ind = i2   
      3 updt_task = i4   
      3 updt_task_ind = i2   
      3 updt_id = f8   
      3 updt_cnt = i4   
      3 updt_cnt_ind = i2   
      3 updt_applctx = i4   
      3 updt_applctx_ind = i2   
    2 ensure_type = i2   
    2 digital_signature_ident = vc  
    2 action_prsnl_group_id = f8   
    2 request_prsnl_group_id = f8   
    2 receiving_person_id = f8   
    2 receiving_person_ft = vc  
  1 ensure_type2 = i2   
  1 clinsig_updt_dt_tm_flag = i2   
  1 clinsig_updt_dt_tm = dq8   
  1 clinsig_updt_dt_tm_ind = i2   
) go

free record 1000015_reply
record 1000015_reply (
  1 event_prsnl_id = f8   
  1 event_id = f8   
  1 action_prsnl_id = f8   
  1 action_type_cd = f8   
  1 sb  
    2 severityCd = i4   
    2 statusCd = i4   
    2 statusText = vc  
    2 subStatusList [*]   
      3 subStatusCd = i4   
)  go


SET stat = tdbexecute (1000015 ,1000015 ,1000015 ,"REC" ,1000015_request ,"REC" ,1000015_reply ,1 ) go


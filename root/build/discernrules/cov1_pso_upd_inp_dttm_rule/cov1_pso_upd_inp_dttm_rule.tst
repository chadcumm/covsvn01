 
free record request go
record REQUEST (
 
  1 Req_type_cd = f8
 
  1 Passthru_ind = i2
 
  1 Trigger_app = i4
 
  1 Person_id = f8
 
  1 Encntr_id = f8
 
  1 Position_cd = f8
 
  1 Sex_cd = f8
 
  1 Birth_dt_tm = dq8
 
  1 Weight = f8
 
  1 Weight_unit_cd = f8
 
  1 Height = f8
 
  1 Height_unit_cd = f8
 
  1 OrderList [*]
 
    2 synonym_code = f8
 
    2 catalog_code = f8
 
    2 catalogTypeCd = f8
 
    2 orderId = f8
 
    2 actionTypeCd = f8
 
    2 activityTypeCd = f8
 
    2 activitySubTypeCd = f8
 
    2 dose = f8
 
    2 dose_unit = f8
 
    2 start_dt_tm = dq8
 
    2 end_dt_tm = dq8
 
    2 route = f8
 
    2 frequency = f8
 
    2 physician = f8
 
    2 rate = f8
 
    2 infuse_over = i4
 
    2 infuse_over_unit_cd = f8
 
    2 DetailList [*]
 
      3 oeFieldId = f8
 
      3 oeFieldValue = f8
 
      3 oeFieldDisplayValue = vc
 
      3 oeFieldDtTmValue = dq8
 
      3 oeFieldMeaning = vc
 
    2 DiagnosisList [*]
 
      3 dx = vc
 
    2 IngredientList [*]
 
      3 catalogCd = f8
 
      3 synonymId = f8
 
      3 item_id = f8
 
      3 strengthDose = f8
 
      3 strengthUnit = f8
 
      3 volumeDose = f8
 
      3 volumeUnit = f8
 
      3 bag_frequency_cd = f8
 
      3 freetextDose = vc
 
      3 doseQuantity = f8
 
      3 doseQuantityUnit = f8
 
      3 ivseq = i4
 
      3 normalized_rate = f8
 
      3 normalized_rate_unit = f8
 
    2 protocol_order_ind = i2
 
    2 DayOfTreatment_order_ind = i2
 
  1 Alert_Titlebar = vc
 
  1 commonreply_ind = i2
 
  1 freetextParam = vc
 
  1 expert_trigger = vc
 
) go

declare trigger_orderid = f8 with public  go
declare trigger_personid = f8 with public go
declare trigger_encntrid = f8 with public go

select into "nl:"
from orders o,order_detail od where o.order_id =  405216985             
and o.order_id = od.order_id
order by
od.detail_sequence
head report
	stat = alterlist(request->OrderList,1)
	request->OrderList[1].actionTypeCd = 2534
	cnt = 0
detail
	cnt = (cnt + 1)
	request->OrderList[1].orderId = o.order_id
	trigger_orderid = o.order_id
	trigger_personid = o.person_id
	trigger_encntrid = o.encntr_id
	stat = alterlist(request->OrderList->detailList,cnt)
	request->OrderList[1].detailList[cnt].oeFieldMeaning = od.oe_field_meaning
	request->OrderList[1].detailList[cnt].oeFieldDtTmValue = od.oe_field_dt_tm_value
with nocounter go
 

;set request->OrderList[1].orderId = 396101003


 
set EKMLOG_IND = 1 go
 
 
;set trigger_orderid = 396101003
;set trigger_personid = 16583008
;set trigger_encntrid = 110433461
;set link_personid = 16580646  go
;set link_encntrid = 110433678 go
 
 
set link_template = 1 go

call echorecord(request) go

;execute cov_plan_pp_med_rec go
execute cov1_pso_upd_inp_dttm_rule:dba go

 

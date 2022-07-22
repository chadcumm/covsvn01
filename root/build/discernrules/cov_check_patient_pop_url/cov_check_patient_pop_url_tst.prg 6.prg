
drop program cov_check_patient_pop_url_tst go
create program cov_check_patient_pop_url_tst
set debug_ind = 1 
/* 
set debug_ind = 0
set link_encntrid = 106417540 
set link_personid = 15167250 

execute cov_check_patient_pop_url "fnPopulationGroupShowAlert" 

for (ii = 1 to 100)
	execute cov_check_patient_pop_url ^fnPopulationGroupShowAlert^
endfor
*/

free record 3072006_request
record 3072006_REQUEST (
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
) 

set 3072006_request->Req_type_cd = 3343
set 3072006_request->Person_id = 15167250
set 3072006_request->Encntr_id = 106417540
set 3072006_request->Position_cd = 441
set 3072006_request->Sex_cd = 362
set 3072006_request->Birth_dt_tm = cnvtdatetime("01-DEC-1991")
set 3072006_request->Alert_Titlebar = "Open Chart - ZZZMOCK, TIFFANY AMBER"
set 3072006_request->commonreply_ind = 1

free set 3072006_reply
record 3072006_reply
(
%i cclsource:status_block.inc
)

for (ii=1 to 200)
set stat = tdbexecute(600005, 3072000, 3072006, "REC", 3072006_request, "REC", 3072006_reply)
endfor

end
go

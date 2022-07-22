
drop program cov_test_patient_pop_url go
create program cov_test_patient_pop_url

set debug_ind = 1 

free record r_rec
record r_rec
(
	1 cnt = i2
	1 max_cnt = i2
	1 req_type_cd = f8
	1 qual[*]
	 2 encntr_id = f8
	 2 person_id = f8
	 2 sex_cd = f8
	 2 birth_Dt_tm = dq8
	 2 Alert_Titlebar = vc
	 2 prsnl_id = f8
)

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

set r_rec->max_cnt = 10
set r_rec->req_type_cd = uar_Get_code_by("MEANING",12600,"CPS_OPN_CHT")


select into "nl:"
from
	encntr_domain ed
	,encounter e
	,person p
plan ed
	where ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ed.active_ind = 1
join e
	where e.encntr_id = ed.encntr_id
join p
	where p.person_id = e.person_id
order by
	 e.reg_dt_tm desc
	,e.encntr_id
head e.encntr_id
	r_rec->cnt = (r_rec->cnt + 1)
	stat = alterlist(r_rec->qual,r_rec->cnt)
	r_rec->qual[r_rec->cnt].encntr_id = e.encntr_id
	r_rec->qual[r_rec->cnt].person_id = e.person_id
	r_rec->qual[r_rec->cnt].sex_cd = p.sex_cd
	r_rec->qual[r_rec->cnt].birth_Dt_tm = p.birth_dt_tm
	r_rec->qual[r_rec->cnt].Alert_Titlebar = concat("Open Chart - ",trim(p.name_full_formatted))
with nocounter, maxqual(ed,value(r_rec->max_cnt))

select into "nl:"
from 
	prsnl p
plan p 
	where p.active_ind =1
	and   p.username > " "
	and   p.position_cd > 0.0
head report
	cnt = 0
detail
	cnt = (cnt + 1)
	if (cnt <= r_rec->cnt)
		r_rec->qual[cnt].prsnl_id = p.person_id
	endif
with nocounter, maxqual(p,value(r_rec->max_cnt))


set 3072006_request->Req_type_cd = 3343 ;       3343.00	      12600	CPS_OPN_CHT
set 3072006_request->Person_id = 17891780        ;15167250
set 3072006_request->Encntr_id = 113489963                ;106417540
set 3072006_request->Position_cd = 2781910071
set 3072006_request->Sex_cd = 362
set 3072006_request->Birth_dt_tm = cnvtdatetime("01-DEC-1991")
set 3072006_request->Alert_Titlebar = "Open Chart - ZZZMOCK, TIFFANY AMBER"
set 3072006_request->commonreply_ind = 1

free set 3072006_reply
record 3072006_reply
(
%i cclsource:status_block.inc
)

;set trace TDBDEBUG2 
;set trace TDBDEBUG2
set stat = tdbexecute(600005, 3072000, 3072006, "REC", 3072006_request, "REC", 3072006_reply)
 


call echorecord(3072006_reply)

set link_encntrid = 3072006_request->Encntr_id 
set link_personid = 3072006_request->Person_id 

execute cov_check_patient_pop_url "fnPopulationGroupShowAlert" 

end
go

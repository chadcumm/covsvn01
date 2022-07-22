/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_discerndiaglogue_test.prg
  Object name:        cov_discerndiaglogue_test
  Request #:
  Program purpose:
  Executing from:     CCL
  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_discerndiaglogue_test go
create program cov_discerndiaglogue_test
 

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
	 2 position_cd = f8
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

free set 3072006_reply
record 3072006_reply
(
  1 Status = vc
  1 Reason = vc
  1 ProgId = vc
  1 SPIndex = i2
  1 cer_hnam_location = vc
  1 parameterlist[*]
    2 parameter = vc
  1 Numreply = i4
  1 Qual[*]
    2 Status = vc
    2 Reason = vc
    2 ProgId = vc
    2 SPIndex = i2
    2 parameterlist[*]
      3 parameter = vc
%i cclsource:status_block.inc
)

set r_rec->req_type_cd = uar_Get_code_by("MEANING",12600,"CPS_OPN_CHT")

if(size(trim(reflect(parameter(1,0))),1) > 0)
  set r_rec->max_cnt = cnvtint(value(parameter(1,0)))
endif

if (r_rec->max_cnt <= 0)
	set r_rec->max_cnt = 10
endif

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
	and   p.person_id > 100.0
head report
	cnt = 0
detail
	cnt = (cnt + 1)
	if (cnt <= r_rec->cnt)
		r_rec->qual[cnt].prsnl_id = p.person_id
		r_rec->qual[cnt].position_cd = p.position_cd
	endif
with nocounter, maxqual(p,value(r_rec->max_cnt))

call echorecord(r_rec)

for (i = 1 to r_rec->cnt)
	set stat = initrec(3072006_request)
	set stat = initrec(3072006_reply)
	set 3072006_request->Req_type_cd = r_rec->req_type_cd
	set 3072006_request->Person_id = r_rec->qual[i].person_id        
	set 3072006_request->Encntr_id = r_rec->qual[i].encntr_id               
	set 3072006_request->Position_cd = r_rec->qual[i].position_cd
	set 3072006_request->Sex_cd = r_rec->qual[i].sex_cd
	set 3072006_request->Birth_dt_tm = cnvtdatetime(r_rec->qual[i].birth_Dt_tm)
	set 3072006_request->Alert_Titlebar = r_rec->qual[i].Alert_Titlebar
	set 3072006_request->commonreply_ind = 1
	set reqinfo->updt_id = r_rec->qual[i].person_id

	set stat = tdbexecute(600005, 3072000, 3072006, "REC", 3072006_request, "REC", 3072006_reply)
	call echorecord(3072006_reply)
endfor

end
go

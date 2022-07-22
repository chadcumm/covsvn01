drop program cov_transfer_medrec_st go
create program cov_transfer_medrec_st

free set 510001_REQUEST  
record 510001_REQUEST (
  1 person_id = f8   
  1 encounter_id = f8   
  1 override_org_security = i2   
  1 personnel_id = f8   
  1 diagnosis_ind = i2   
) 

free set 510001_REPLY 
record 510001_REPLY (
  1 transaction_status  
    2 success_ind = i2   
    2 debug_error_message = vc  
  1 home_medications [*]   
    2 order_id = f8   
    2 order_name = vc  
    2 order_detail_line = vc  
    2 order_comments = vc  
    2 ordering_physician = vc  
    2 indication = vc  
    2 diagnoses [*]   
      3 nomenclature_id = f8   
      3 priority = i2   
      3 annotated_display = vc  
      3 originating_display = vc  
      3 nomenclature_code = vc  
  1 continued_medications [*]   
    2 proposal_id = f8   
    2 order_name = vc  
    2 order_detail_line = vc  
    2 order_comments = vc  
    2 ordering_physician = vc  
    2 indication = vc  
    2 diagnoses [*]   
      3 nomenclature_id = f8   
      3 priority = i2   
      3 annotated_display = vc  
      3 originating_display = vc  
      3 nomenclature_code = vc  
  1 continued_non_medications [*]   
    2 proposal_id = f8   
    2 order_name = vc  
    2 order_detail_line = vc  
    2 order_comments = vc  
    2 ordering_physician = vc  
    2 indication = vc  
    2 diagnoses [*]   
      3 nomenclature_id = f8   
      3 priority = i2   
      3 annotated_display = vc  
      3 originating_display = vc  
      3 nomenclature_code = vc  
    2 clinical_category_cd = f8   
) 

set 510001_REQUEST->person_id = 16611335  
set 510001_REQUEST->encounter_id = 110459715  
set 510001_REQUEST->override_org_security = 1 
set 510001_REQUEST->personnel_id = reqinfo->updt_id 
set 510001_REQUEST->diagnosis_ind = 1 

set stat = tdbexecute(600005, 500195, 510001, "REC", 510001_REQUEST, "REC", 510001_REPLY) 

call echorecord(510001_reply) 


end go


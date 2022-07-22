

free record request go
record REQUEST (
  1 patient_id = f8   
  1 encntr_id = f8   
  1 org_sec_override = i2   
) go

;PowerForm Documented 2300803288
set request->patient_id = 18245808.00 go
set request->encntr_id = 114691890.00 go

;Active Pregnancy 1922000001
;set request->patient_id = 18257847.00 go
set request->encntr_id = 114707835.00 go
;

free record reply go
RECORD reply (
   1 pregnancy_id = f8
   1 pregnancy_instance_id = f8
   1 onset_dt_tm = dq8
   1 onset_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript go
 
 
execute dcp_chk_active_preg go

call echorecord(reply) go

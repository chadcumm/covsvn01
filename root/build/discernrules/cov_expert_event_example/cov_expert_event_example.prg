drop program cov_expert_event_example go
create program cov_expert_event_example
;------------------------------------------------
; Include files used to call EXPERT_EVENT
;------------------------------------------------
%i cclsource:eks_rprq3091001.inc
%i cclsource:eks_run3091001.inc

;The first include file creates the EKSOPSRequest 
;record structure which is used to pass a list of persons, 
;encounters, and/or orders to the Discern Expert System

;record EKSOPSRequest (
;   1 expert_trigger = vc
;   1 qual[*]
;               2 person_id = f8
;               2 sex_cd = f8
;               2 birth_dt_tm = dq8
;               2 encntr_id = f8
;               2 accession_id = f8
;               2 order_id = f8
;               2 data[*]
;                               3 vc_var  = vc
;                               3 double_var = f8
;                               3 long_var  = i4
;                               3 short_var = i2)

;----------------------------------------
; Qualify records to send to rule
;----------------------------------------

declare cnt = i4


select into "nl:"
from encounter enc
plan enc where enc.disch_dt_tm between cnvtdatetime(curdate-3, 0)
and cnvtdatetime(curdate ,2359)

order by enc.encntr_id

head report
cnt = 0
EKSOPSRequest->expert_trigger = cnvtupper(curprog) 
detail
cnt = cnt + 1
stat = alterlist(EKSOPSRequest->qual,cnt)
EKSOPSrequest->qual[cnt].person_id = enc.person_id
EKSOPSrequest->qual[cnt].encntr_id = enc.encntr_id

 

with nocounter
call echorecord(EKSOPSRequest)
;----------------------------------------
; Call EXPERT_EVENT
;----------------------------------------
if (cnt > 0)
set dparam = 0
  call srvRequest(dparam)
endif
end
go

drop program cov_expert_event_by_fin go
create program cov_expert_event_by_fin

prompt
   "Expert Trigger" = "EKS_RUN_ESCALATION"
  ,"Patient FIN" = ""
with $TRIGGER, $FIN

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
from
  encounter e
  ,encntr_alias ea
plan ea
  where ea.alias = $FIN
  and   ea.encntr_alias_type_cd = value(UAR_GET_CODE_BY("MEANING",319,"FIN NBR"))
  and   ea.active_ind =1
  and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
  and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by enc.encntr_id
head report
cnt = 0
EKSOPSRequest->expert_trigger = $TRIGGER
detail
cnt = cnt + 1
stat = alterlist(EKSOPSRequest->qual,cnt)
EKSOPSrequest->qual[cnt].person_id = enc.person_id
EKSOPSrequest->qual[cnt].encntr_id = enc.encntr_id

with nocounter

;----------------------------------------
; Call EXPERT_EVENT
;----------------------------------------
if (cnt > 0)
set dparam = 0
  call srvRequest(dparam)
endif
RECORD  _FILESTAT  (

1  FILE_DESC  =  I4

1  FILE_NAME  =  VC

1  FILE_BUF  =  VC

1  FILE_OFFSET  =  I4

1  FILE_DIR  =  I4

) WITH  PROTECT

 

SET _FILESTAT->FILE_DESC=0

SET _FILESTAT->FILE_NAME=concat("CCLUSERDIR:",trim(curprog),".dat")

SET _FILESTAT->FILE_BUF="w"

SET STAT = CCLIO("OPEN",_FILESTAT)

IF(STAT=1)

SET _FILESTAT->FILE_DIR = 2

SET STAT = CCLIO("SEEK",_FILESTAT)

SET LEN = CCLIO("TELL",_FILESTAT)

SET _FILESTAT->FILE_DIR = 0

SET STAT = CCLIO("SEEK",_FILESTAT)

SET _FILESTAT->FILE_BUF = cnvtrectojson(EKSOPSRequest)

SET STAT = CCLIO("WRITE",_FILESTAT)

SET STAT = CCLIO("CLOSE",_FILESTAT)
ENDIF
call echorecord(EKSOPSRequest)
end
go

drop program cov_expert_event_by_fin go
create program cov_expert_event_by_fin

prompt 
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Expert Trigger" = "EKS_RUN_ESCALATION"
	, "Patient FIN" = "" 

with OUTDEV, TRIGGER, FIN

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
join e
  where e.encntr_id = ea.encntr_id
  and   e.active_ind = 1
order by e.encntr_id
head report
cnt = 0
EKSOPSRequest->expert_trigger = $TRIGGER
detail
cnt = cnt + 1
stat = alterlist(EKSOPSRequest->qual,cnt)
EKSOPSrequest->qual[cnt].person_id = e.person_id
EKSOPSrequest->qual[cnt].encntr_id = e.encntr_id

with nocounter

;----------------------------------------
; Call EXPERT_EVENT
;----------------------------------------
if (cnt > 0)
set dparam = 0
  call srvRequest(dparam)
endif

record  _filestat  (
1  file_desc  =  i4
1  file_name  =  vc
1  file_buf  =  vc
1  file_offset  =  i4
1  file_dir  =  i4
) with  protect

set _filestat->file_desc=0
set _filestat->file_name=concat("ccluserdir:",trim(curprog),".dat")
set _filestat->file_buf="w"
set stat = cclio("OPEN",_filestat)

if(stat=1)

set _filestat->file_dir = 2

set stat = cclio("SEEK",_filestat)

SET _FILESTAT->FILE_DIR = 0
SET STAT = CCLIO("SEEK",_FILESTAT)
SET _FILESTAT->FILE_BUF = cnvtrectojson(EKSOPSRequest)
SET STAT = CCLIO("WRITE",_FILESTAT)
SET STAT = CCLIO("CLOSE",_FILESTAT)
ENDIF

execute CCL_READFILE $OUTDEV,value(concat("CCLUSERDIR:",trim(curprog),".dat")),0,11,8.5
call echorecord(EKSOPSRequest)
end
go

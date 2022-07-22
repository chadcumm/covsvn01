/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		FEB'22
	Solution:			All
	Source file name:		cov_medrec_alert_dismiss_ekm.prg
	Object name:		cov_medrec_alert_dismiss_ekm
	Request#:			10022
	Program purpose:	      Call to a rule
	Executing from:		Html/Rule
 	Special Notes:		Rule name : COV_DSCH_MEDREC_DISMISS
 
;********************************************************************************/
 
 
drop program cov_medrec_alert_dismiss_ekm:dba go
create program cov_medrec_alert_dismiss_ekm:dba
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
%i cclsource:eks_rprq3091001.inc
%i cclsource:eks_run3091001.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare encntrid_var = f8 with noconstant(0.0), protect
declare personid_var = f8 with noconstant(0.0), protect
declare userid_var    = f8 with noconstant(0.0), protect
declare log_message = vc with noconstant('')
declare log_misc1   = vc with noconstant('')
 
set encntrid_var = 125359334 ;trigger_encntrid ;125359334
set userid_var   = reqinfo->updt_id ;12428721.00
set retval = 0
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/*Record EKSOPSRequest (
   1 expert_trigger = vc
   1 qual[*]
	   2 person_id = f8
         2 sex_cd = f8
         2 birth_dt_tm = dq8
         2 encntr_id = f8
         2 accession_id = f8
         2 order_id = f8
         2 data[*]
      	   3 vc_var  = vc
               3 double_var = f8
               3 long_var  = i4
               3 short_var = i2
   )*/
 
 
select into 'nl:'
from encounter e
where e.encntr_id = encntrid_var
order by e.encntr_id 
 
 
Head report
	cnt = 0
	EKSOPSRequest->expert_trigger = "medrec_alert_dismiss"
Head e.encntr_id
	dcnt = 0	
	cnt += 1
	if(mod(cnt,10) = 1)
		stat = alterlist(EKSOPSRequest->qual, cnt + 9)
	endif
	EKSOPSRequest->qual[cnt].person_id = e.person_id
	EKSOPSRequest->qual[cnt].encntr_id = e.encntr_id
Detail
	dcnt += 1
	if(mod(dcnt,10) = 1)
		stat = alterlist(EKSOPSRequest->qual[cnt].data, dcnt + 9)
	endif
	EKSOPSRequest->qual[cnt].data[dcnt].double_var = userid_var
Foot e.encntr_id	
	stat = alterlist(EKSOPSRequest->qual[cnt].data, dcnt)	
Foot report
	stat = alterlist(EKSOPSRequest->qual, cnt)
 
with nocounter
 
call echorecord(EKSOPSRequest)
 
 
 
;**********************************************
; Call EXPERT_EVENT
;**********************************************
 
if (cnt > 0)
	set dparam = 0
      call srvRequest(dparam)
endif
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_manage_lock.prg
  Object name:        cov_eks_manage_lock
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_manage_lock:dba go
create program cov_eks_manage_lock:dba

prompt 
	"LOCK_DOMAIN" = ""
	, "ACTION" = "" 

with LOCK_DOMAIN, ACTION


set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 params
	 2 lock_domain = vc
	 2 action = vc
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->params.lock_domain				= $LOCK_DOMAIN
set t_rec->params.action					= $ACTION


if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->params.lock_domain = "")
	set t_rec->log_message = concat("lock domain not found")
	go to exit_script
endif

if (t_rec->params.action = "")
	set t_rec->log_message = concat("action not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

free record lock_reply
record lock_reply
(
    1 isAvailable                = i2 ;0 = false , 1 = true
    1 Locked_Prsnl_id            = f8
    1 Locked_Prsnl_name          = vc
    1 expire_dt_tm				 = dq8
%i cclsource:status_block.inc
) 

case (t_rec->params.lock_domain)
	of "ENCNTR_ID":	go to encntr_domain_start
	else go to exit_script
endcase


#encntr_domain_start

set t_rec->return_value = "FALSE"

execute cov_eks_encntr_lock "NOFORMS",value(t_rec->patient.encntr_id),3 with replace("REPLY",lock_reply)


if (t_rec->params.action = "ADD")
	if ((lock_reply->isAvailable = 1) or (cnvtdatetime(curdate,curtime3) > cnvtdatetime(lock_reply->expire_dt_tm)))
		set stat = initrec(lock_reply)
		execute cov_eks_encntr_lock "NOFORMS",value(t_rec->patient.encntr_id),1 with replace("REPLY",lock_reply)
		if (lock_reply->status_data.status = "S")
			set t_rec->log_message = concat("Lock for encntr_id acquired")
			set t_rec->return_value = "TRUE"
		else
			set t_rec->log_message = concat("Lock for encntr_id failed")
		endif
	else
		set t_rec->log_message = concat("Lock for encntr_id is not available")
		go to exit_script
	endif
elseif (t_rec->params.action = "REMOVE")
	if (lock_reply->isAvailable = 0)
		set stat = initrec(lock_reply)
		execute cov_eks_encntr_lock "NOFORMS",value(t_rec->patient.encntr_id),2 with replace("REPLY",lock_reply)
		if (lock_reply->status_data.status = "S")
				set t_rec->log_message = concat("Lock for encntr_id removed")
				set t_rec->return_value = "TRUE"
		else
			set t_rec->log_message = concat("Unlock for encntr_id failed")
		endif
	else
		set t_rec->log_message = concat("encntr_id was not locked")
		set t_rec->return_value = "TRUE"
	endif
endif

go to exit_script
;encntr_domain end

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go

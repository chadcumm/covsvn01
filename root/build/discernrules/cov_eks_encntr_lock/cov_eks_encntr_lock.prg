drop program cov_eks_encntr_lock:dba go
create program cov_eks_encntr_lock:dba

prompt
    "Output to File/Printer/MINE" = "MINE",
    "Encntr ID" = "",
    "Function" = "1"  ;1 - lock, 2 - unlock, 3 - inquire
with OUTDEV, ENCNTRID, FUNCTION
 
/**
    This is the reply structure for the script
    @reply
*/
free record entity_lock 
record entity_lock(
1 lock_seq_id = f8
1 entity_id = f8
1 entity_name = c35
1 prsnl_id = f8
1 lock_type = i4
1 lock_dt_tm = c14
1 expire_dt_tm = c14
1 lockkeyid = f8
1 updt_applctx = f8
1 status = i4
1 status_data = c1
1 lock_minutes = i4
1 prsnl_name = c40
1 entity_desc = c40
1 dt_lock_dt_tm = dq8
1 dt_expire_dt_tm = dq8
1 srv_version = i2
1 scr_startup_version = i2
1 scr_lock_version = i2
1 scr_renew_version = i2
1 scr_break_version = i2
1 scr_steal_version = i2
1 scr_unlock_version = i2
1 scr_check_version = i2
1 scr_inquire_version = i2
) with persistscript
 
free record Inquire
record Inquire
(
    1 Unlocked                   = i2 ;0 = no , 1 = yes
    1 Locked                     = i2 ;0 = no , 1 = yes
    1 Expired                    = i2 ;0 = no , 1 = yes
    1 Locked_by_user             = i2 ;0 = no , 1 = yes
    1 Locked_by_other            = i2 ;0 = no , 1 = yes 
    1 locked_user_id             = f8
    1 expire_dt_tm               = dq8
    
) 
if (not(validate(reply,0)))
	record reply
	(
	    1 isAvailable                = i2 ;0 = false , 1 = true
	    1 Locked_Prsnl_id            = f8
	    1 Locked_Prsnl_name          = vc
	    1 expire_dt_tm				 = dq8
%i cclsource:status_block.inc
	) 
endif
 
/**************************************************************
; Include Files
**************************************************************/
%i cclsource:mp_script_logging.inc
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
declare public::Main(null)                                  = null
declare public::InquireLock(encntrID = f8, prsnlID = f8)   = null
declare public::UnlockRequest(encntrID = f8)               = null
declare public::LockRequest(encntrID = f8, prsnlId = f8)   = null
declare public::ExpireCheck(null)                           = null
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
/**************************************************************
; Constant Variables
**************************************************************/
declare LOCK_EXPIRE_TIME                       = i2 with protect, constant(1)
declare LOCK_PRSNL_ID 						   = f8 with protect, constant(1.0) 
/**
    determine the status of the request.
    @param encntrID
        encntr_id from encounter table
    @param prsnlId
        prnsl_id currently requesting the lock.
    @returns null
*/
subroutine public::InquireLock(encntrID,prsnlId)
 call log_message("Entering subroutine InquireLock()", LOG_LEVEL_DEBUG)

select into "nl:"
from entity_lock el 
plan el where el.entity_id = encntrID
          and el.entity_name = "EKSEncntrLock"
          and el.lock_type = 1
order by el.lock_dt_tm desc
detail
  inquire->expire_dt_tm = el.expire_dt_tm
  inquire->locked_user_id = el.lock_prsnl_id
with nocounter
         
    if(curqual >= 1) ;There is/was a lock on the record, could be expired though or unlocked.  
           ;if a request is locked always pass who it is locked by.  
           set reply->Locked_Prsnl_id = inquire->locked_user_id
           set reply->expire_dt_tm = inquire->expire_dt_tm
           select into "nl:"
              from prsnl p
              where p.person_id = inquire->locked_user_id
              detail
              reply->Locked_Prsnl_name = trim(p.name_full_formatted)
           with nocounter  
       if(inquire->expire_dt_tm < cnvtdatetime(curdate,curtime)) ;lock has expired.
           set Inquire->Expired = 1
       elseif(inquire->locked_user_id = prsnlId)
           set inquire->Locked_by_user = 1
       else
           set inquire->Locked_by_other = 1  

       endif
    else ;no lock on the request
        set Inquire->Unlocked = 1
    endif
 	call echorecord(inquire)
    call log_message("Exiting subroutine InquireLock()", LOG_LEVEL_DEBUG)
end

/**
    Issue a unlock for the request_id.
    @param encntrID
        encntr_id from encounter table
    @param prsnlId
        prnsl_id currently requesting the lock.
    @returns null
*/
subroutine UnlockRequest(encntrID,prsnlId)
    call log_message("Entering subroutine UnLock()", LOG_LEVEL_DEBUG)
 
    set entity_lock->srv_version = 1
    set entity_lock->entity_id = encntrID
    set entity_lock->entity_name = "EKSEncntrLock"
    set entity_lock->entity_desc = "EKS Encntr Lock"
    set entity_lock->prsnl_id = prsnlId
 
    execute entity_unlock
    
    if(entity_lock->status_data = "F")
       set reply->status_data.subeventstatus[1].TargetObjectValue = build2("Failed to unlock EKS Encntr Lock Receipt: ", encntrID)
       go to exit_script  
    endif       
    
end;UnlockRequest

/**
    Issue a lock for the request_id.
    @param encntrID
        encntr_id from encouter table
    @param prsnlId
        prnsl_id currently requesting the lock.
    @returns null
*/
subroutine LockRequest(encntrID,prsnlId)
    call log_message("Entering subroutine LockRequest()", LOG_LEVEL_DEBUG)
 
    set entity_lock->srv_version = 1
    set entity_lock->entity_id = encntrID
    set entity_lock->entity_name = "EKSEncntrLock"
    set entity_lock->entity_desc = "EKS Encntr Lock"
    set entity_lock->prsnl_id = prsnlId
    set entity_lock->lock_minutes = LOCK_EXPIRE_TIME
 	
 	call echo("execute entity_lock")
    execute entity_lock
    

    if(entity_lock->status_data = "F")
       set reply->status_data.subeventstatus[1].TargetObjectValue = build2("Failed to lock EKS Encntr Lock Receipt: ", encntrID)
       go to exit_script  
    endif   
    
end;LockRequest


/**
    Main Function of this script.
    @param null
    @returns null
*/
subroutine public::Main(null)
  call log_message("Entering subroutine Main()", LOG_LEVEL_DEBUG)
 
  set reply->status_data.status = "F"
    
  call InquireLock($ENCNTRID, LOCK_PRSNL_ID)  ;always call the inquire
  
;1 - Want to lock, 2 - Want to unlock, 3 - inquire 
  Case($Function)
  of 1: if(Inquire->unlocked = 1 or inquire->Expired = 1)
           call LockRequest($ENCNTRID, LOCK_PRSNL_ID)
           if(entity_lock->status_data = "S")
              set reply->isAvailable = 1
           endif
        elseif(inquire->Locked_by_user = 1)
           set reply->isAvailable = 0
        elseif(inquire->Locked_by_other = 1)
           set reply->isAvailable = 0
        endif
  of 2: if(inquire->Unlocked = 1)
           set reply->isAvailable = 0 ;user must have a lock on the request to unlock and save.
        elseif(inquire->Locked_by_user = 1)
           call UnlockRequest($ENCNTRID, LOCK_PRSNL_ID)
           if(entity_lock->status_data = "S")   
              set reply->isAvailable = 1
           endif
        elseif(inquire->Locked_by_other = 1) ;lock must have expired and locked by another user
           set reply->isAvailable = 0
        elseif(inquire->Expired = 1)
           set reply->isAvailable = 0          
        endif      
  of 3: if(inquire->Unlocked = 1)
          set reply->isAvailable = 1
        else
          set reply->isAvailable = 0
        endif
  endcase
 
    call log_message("Exiting subroutine Main()", LOG_LEVEL_DEBUG)
end
 
/**************************************************************
; Main Program
**************************************************************/
call Main(null)
set reply->status_data.status = "S"
 
#EXIT_SCRIPT
 
if(validate(_memory_reply_string, 0)) ; this would be used if you are calling from mpages with a json as paramter
    set stat = copyrec(reply, record_data, 1)
    set _memory_reply_string = cnvtrectojson(record_data)
endif
 
if(validate(debug_ind, 0) = 1)
    call echorecord(entity_lock)
    call echorecord(reply)
endif
 
end
go


 


drop program cov_send_a08_by_fin:dba go
create program cov_send_a08_by_fin:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, FIN


/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/

/****************************************************************************
        Source file name:       pfmt_cov_notify_eso.prg
        Object name:            pfmt_cov_notify_eso
        Request #:
        Product:
        Product Team:           
        HNA Version:
        CCL Version:

        Program purpose:

        Tables read:
        Tables updated:
        Executing from:		600312 - pts_add_prsnl_reltn
        					600313 - pts_chg_prsnl_reltn
        					101305 - PM_ENS_ENCNTR_PRSNL_RELTN
        					        					        				

        Special Notes:

****************************************************************************/

;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     *000 05/2008     			 Initial Release                    *
;~DE~************************************************************************

;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

call echo(build("loading script: ",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

if (program_log->run_from_ops = 1)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus[1].operationname		= "STARTUP"
	set reply->status_data.subeventstatus[1].operationstatus	= "F"
	set reply->status_data.subeventstatus[1].targetobjectname	= ""
	set reply->status_data.subeventstatus[1].targetobjectvalue	= "Script Started and Ended"
endif

call set_codevalues(null)
call check_ops(null)



free record t_rec
record t_rec
(
	1 cnt = i2
	1 start_dt_tm = dq8
	1 audit_mode = i2
	1 trigger = vc
	1 ce_id = f8
	1 fin = vc
	1 qual[*]
	 2 encntr_id  = f8
	 2 person_id = f8
) 

set t_rec->fin = $FIN

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Encounter **********************************"))

select into "nl:"
	facility=uar_get_code_display(e.loc_facility_cd)
from
	 encntr_alias ea
	,encounter e
	,person p
plan ea
	where ea.alias = t_rec->fin
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
order by
	 e.encntr_id
	,ea.beg_effective_dt_tm desc
head report
	cnt = 0
head e.encntr_id
	cnt = cnt +1
	if(mod(cnt,100) = 1)
		stat = alterlist(t_rec->qual, cnt +99)
	endif
	call writeLog(build2("->Adding encounter=",trim(cnvtstring(e.encntr_id))))
	t_rec->qual[cnt].encntr_id = e.encntr_id
	t_rec->qual[cnt].person_id = e.person_id
foot report
	 stat = alterlist(t_rec->qual, cnt)
	 t_rec->cnt = cnt
	 call writeLog(build2("-->Total to process:",trim(cnvtstring(t_rec->cnt))))
with nocounter

call writeLog(build2("* END   Finding Encounter **********************************"))
call writeLog(build2("************************************************************"))

if (t_rec->cnt = 0)
	if (program_log->run_from_ops = 1)
		set reply->status_data.status = "Z"
		set reply->status_data.subeventstatus[1].operationname		= "ENCNTR"
		set reply->status_data.subeventstatus[1].operationstatus	= "Z"
		set reply->status_data.subeventstatus[1].targetobjectname	= "ENCOUNTER"
		set reply->status_data.subeventstatus[1].targetobjectvalue	= "No Encounters qualified"
	endif
	go to exit_script
endif



SUBROUTINE EchoOut(echo_str)
  call echo(concat(echo_str,"  ",format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM:SS;;D")))
END ;EchoOut

call EchoOut("initializing")

if (validate(iSend_Outbound_Exists, -999) = -999)

;Declare subroutines
declare send_outbound(ob_person_id = f8, ob_encntr_id = f8, ob_subtype = f8, ob_trigger = vc) = null
declare pm_destroy_handles(iDummy = i2) = NULL

subroutine send_outbound(ob_person_id, ob_encntr_id, ob_subtype, ob_trigger)

  ;Crm Routines
  execute crmrtl
  ;Srv Routines
  execute srvrtl
/***************************************************/
/*  Declarations                                   */
/***************************************************/

  declare so_x = i4
  declare so_cnt = i4
  declare so_status = c1
  declare so_continue_yn = c1
  declare so_err_cnt = i4
  declare iSend_Outbound_Exists = i2 with public, noconstant(1)

  ;crm variables
  declare so_create_reply_err_msg = vc
  declare so_hApp    = i4
  declare so_hReply    = i4
  declare so_hTask     = i4
  declare so_hReq      = i4
  declare so_crmStatus = i2
  ;declare stat      = i4
  declare so_AppNum    = i4
  declare so_TaskNum   = i4
  declare so_ReqNum    = i4
  declare so_hStep     = i4
  declare so_hStatus   = i4
  declare so_hList     = i4


  set so_continue_yn = "Y" ;
/***************************************************/
/*  Main                                           */
/***************************************************/
  call echo("start Main")
  set so_AppNum  = 100000
  set so_TaskNum = 100000

  ;Begin the application
  call echo("start crmStatus")
  set so_crmStatus = uar_CrmBeginApp(so_AppNum, so_hApp)
  if (so_crmStatus = 0)
        set so_crmStatus = uar_CrmBeginTask(so_hApp, so_TaskNum, so_hTask)
        if(so_crmStatus != 0)
      set so_create_reply_err_msg = concat("BEGINTASK=", cnvtstring(so_crmStatus))
      call uar_CrmEndApp(so_hApp)
    endif
  else
    set so_create_reply_err_msg = concat("BEGINAPP=", cnvtstring(so_crmStatus))
  endif

  if (so_crmStatus > 0)
    call echo("cmrStatus failed")
    set reply->status_data->status = "F"
    set reply->status_data->subeventstatus[1]->operationname = trim(so_create_reply_err_msg)
    set reply->status_data->subeventstatus[1]->operationstatus = "F"
    set reply->status_data->subeventstatus[1]->targetobjectname = "app/task 100030"
    call pm_destroy_handles(1)
    return
  endif


/***************************************************/
;PMGETPATDATA
/***************************************************/
  call echo("start pgpd")

      ;Passing message into 114604 to trigger PM
      if(so_hTask > 0)
        call echo("pm_get_patient_data")
        set so_ReqNum = 114604
        ;001
        free set action
        declare action = i4
        ;001 end
        set action = 201
        set so_all_person_aliases = 0
        set so_crmStatus = uar_CrmBeginReq(so_hTask, "", so_ReqNum, so_hStep)
        call echo(build("hStep->",so_hstep))
       if(so_crmStatus = 0)
          ;Get Request handle
          set so_hReq = uar_CrmGetRequest(so_hStep)

          ;Fill out request structure
          set stat = uar_SrvSetDouble(so_hReq, "person_id", ob_person_id) ;
          set stat = uar_SrvSetDouble(so_hReq, "encntr_id", ob_encntr_id) ;
          set stat = uar_SrvSetShort(so_hReq, "action", action)
          set stat = uar_SrvSetShort(so_hReq, "all_person_aliases", so_all_person_aliases)
          set stat = uar_CrmPerform(so_hStep)

          if(stat != 0)
            set so_continue_yn = "N"
            set so_err_cnt = so_err_cnt + 1
            set stat = alterlist(err->list,so_err_cnt)
            set err->list[so_err_cnt]->msg = concat("%Error -- Calling Pm_get_patient_data(encntr_id = ",
                trim(cnvtstring(ob_encntr_id)),")")
          endif

          set so_hReply = uar_CrmGetReply(so_hStep)
call echo(build("hReply->", so_hReply))
          if(so_hReply = 0)
            set so_continue_yn = "N"
            set so_err_cnt = so_err_cnt + 1
            set stat = alterlist(err->list,so_err_cnt)
            set err->list[so_err_cnt]->msg = concat("%Error -- Calling Pm_get_patient_data(encntr_id = ",
                trim(cnvtstring(ob_encntr_id)),")")
          endif


          set so_hPatPersonInfo = uar_SrvGetStruct(so_hReply, "person")
          set so_hPatEncntrInfo = uar_SrvGetStruct(so_hReply, "encounter")
          call echo(build("hPatPersonInfo", so_hPatPersonInfo))
          if(so_hPatPersonInfo = 0)
            set so_continue_yn = "N"
            set so_err_cnt = so_err_cnt + 1
            set stat = alterlist(err->list,so_err_cnt)
            set err->list[so_err_cnt]->msg = concat("%Error -- Calling Pm_get_patient_data(encntr_id = ",
                trim(cnvtstring(ob_encntr_id)),")")
          endif

        else
          set so_err_cnt = so_err_cnt + 1
          set stat = alterlist(err->list,so_err_cnt)
          set err->list[so_err_cnt]->msg = concat("BEGINREQ=", cnvtstring(so_crmStatus))
        endif
      endif



;PMGETPATDATA_END
/*--------------------------------------------------*/

/***************************************************/
;COPYSTRUCT_SEND
/***************************************************/


  call echo("start outbound :")

      declare so_hMsgStruct = i4
      declare so_hCQMInfoStruct = i4
      declare so_hTrigInfoStruct = i4
      declare so_hTransInfoStruct = i4
      declare so_hPersonStruct = i4
      declare so_hEncntrStruct = i4
      declare so_hESOInfo = i4
      declare so_hReqStruct = i4
      ;Define outbound variables
      declare so_hMsg = i4
      declare so_hReqMsg = i4
      declare so_hCQMMsg = i4
      declare so_hCQMInfo = i4
      declare so_hTRIGInfo = i4
      declare so_hTemp1 = i4
      declare so_hTemp2 = i4
      declare so_hTemp3 = i4
      declare so_hTemp4 = i4

    set so_hReqMsg = uar_SrvSelectMessage(1215013)


    if( so_hReqMsg = 0)
        set reply->status_data->status = "F"
            set reply->status_data->subeventstatus[1]->operationname = "Unable to obtain message for TDB 1215013"
            set reply->status_data->subeventstatus[1]->operationstatus = "F"
            set reply->status_data->subeventstatus[1]->targetobjectname = "req1215013"
            call pm_destroy_handles(1)
            return
    endif

    ;get request structure
    set so_hReqStruct = uar_SrvCreateRequest(so_hReqMsg)
    call uar_SrvDestroyMessage(so_hReqMsg)

    ;Fill out request structure
    set so_hMsgStruct = uar_SrvGetStruct(so_hReqStruct, "message")
    set so_hCQMInfoStruct = uar_SrvGetStruct(so_hMsgStruct, "cqminfo")

      set date_disp = format(cnvtdatetime(curdate, curtime3),";;Q")
          ;Fill out request structure
          set stat = uar_SrvSetString(so_hCQMInfoStruct, "AppName", "FSIESO")
          set stat = uar_SrvSetString(so_hCQMInfoStruct, "ContribAlias", "PM_TRANSACTION")
          set stat = uar_SrvSetString(so_hCQMInfoStruct, "ContribRefnum", "114700")
          set stat = uar_SrvSetDate(so_hCQMInfoStruct, "ContribDtTm", cnvtdatetime(curdate, curtime3))
          set stat = uar_SrvSetString(so_hCQMInfoStruct, "Class", "PM_TRANS")
          set stat = uar_SrvSetLong(so_hCQMInfoStruct, "Priority", 99)
          set stat = uar_SrvSetString(so_hCQMInfoStruct, "Type", "ADT")
          set stat = uar_SrvSetString(so_hCQMInfoStruct, "Subtype", nullterm(ob_trigger))
          set stat = uar_SrvSetLong(so_hCQMInfoStruct,  "Verbosity_Flag", 1)
          ; Copy the Two Stuctures 114605(pm_get_patient_data) into 1215013

          if(so_continue_yn = "Y")
            set so_hESOInfoStruct = uar_SrvGetStruct(so_hMsgStruct, "ESOInfo")
            call echo(build("hESOInfoStruct", so_hESOInfoStruct))
            if(so_hESOInfoStruct = 0)
              set so_continue_yn = "N"
              set so_err_cnt = so_err_cnt + 1
              set stat = alterlist(err->list,so_err_cnt)
              set err->list[so_err_cnt]->msg = concat("%Error -- Retrieving Reply --> triginfo")
            endif
          endif

            record longlist(
               1 qual[4]
                 2 val = i4
                 2 str = vc
              )
            set longlist->qual[1]->val = 0
            set longlist->qual[1]->str = "person first event"
            set longlist->qual[2]->val = 0
            set longlist->qual[2]->str = "encntr first event"
            set longlist->qual[3]->val = 1
            set longlist->qual[3]->str = "encntr event ind"
            set longlist->qual[4]->val = 201
            set longlist->qual[4]->str = "action type"

            for(xyz = 1 to 4)
              set so_hList = uar_SrvAddItem(so_hESOInfoStruct, "longList")
              if(so_hList > 0)
                set stat = uar_SrvSetLong(so_hList, "lVal", longlist->qual[xyz]->val )
                set stat = uar_SrvSetString(so_hlist, "StrMeaning", nullterm(longlist->qual[xyz]->str))
              else
                set so_continue_yn = "N"
                set so_err_cnt = so_err_cnt + 1
                set stat = alterlist(err->list,so_err_cnt)
                set err->list[so_err_cnt]->msg = concat("%Error -- Retrieving Reply --> triginfo")
                set xyz = 4
              endif
            endfor

          if(so_continue_yn = "Y")
            set so_hTrigInfoStruct = uar_SrvGetStruct(so_hMsgStruct, "TRIGInfo")
 call echo(build("hTrigInfoStruct->", so_hTrigInfoStruct))
            if(so_hTrigInfoStruct = 0)
              set so_continue_yn = "N"
              set so_err_cnt = so_err_cnt + 1
              set stat = alterlist(err->list,so_err_cnt)
              set err->list[so_err_cnt]->msg = concat("%Error -- Retrieving Reply --> triginfo")
            endif
          endif

          set stat = uar_SrvSetShort(so_hTrigInfoStruct, "transaction_type", 201)

          if(so_continue_yn = "Y")
            set so_hTransInfoStruct = uar_SrvGetStruct(so_hTrigInfoStruct, "transaction_info")
 call echo(build("hTransInfoStruct->", so_hTransInfoStruct))
            if(so_hTransInfoStruct = 0)
              set so_continue_yn = "N"
              set so_err_cnt = so_err_cnt + 1
              set stat = alterlist(err->list,so_err_cnt)
              set err->list[so_err_cnt]->msg = concat("%Error -- Retrieving Reply --> triginfo")
            endif
          endif

          set stat = uar_SrvSetDouble(so_hTransInfoStruct, "prsnl_id", reqinfo->updt_id)
          set stat = uar_SrvSetLong(so_hTransInfoStruct, "applctx", reqinfo->updt_applctx)
          set stat = uar_SrvSetLong(so_hTransInfoStruct, "updt_task", reqinfo->updt_task)
          set stat = uar_SrvSetDate(so_hTransInfoStruct, "trans_dt_tm", cnvtdatetime(curdate,curtime3))
          set stat = uar_SrvSetShort(so_hTransInfoStruct, "print_doc_ind", 0)

          if(so_continue_yn = "Y")
            set so_hPersonStruct = uar_SrvGetStruct(so_hTrigInfoStruct, "person")
            set so_hEncntrStruct = uar_SrvGetStruct(so_hTrigInfoStruct, "encounter")
            call echo(build("hPersonStruct", so_hPersonStruct))
            if(so_hPersonStruct = 0)
              set so_continue_yn = "N"
              set so_err_cnt = so_err_cnt + 1
              set stat = alterlist(err->list,so_err_cnt)
              set err->list[so_err_cnt]->msg = concat("%Error -- Retrieving Reply --> person")
            endif
          endif

          call echo(build("hPatPersonInfo", so_hPatPersonInfo))
          set stat = uar_SrvCopy(so_hPersonStruct, so_hPatPersonInfo)
          set stat = uar_SrvCopy(so_hEncntrStruct, so_hPatEncntrInfo)

          if(so_continue_yn = "Y")
            set so_hSubPersonStruct = uar_SrvGetStruct(so_hPersonStruct, "person")
            call echo(build("hSubPersonStruct", so_hSubPersonStruct))
            if(so_hSubPersonStruct = 0)
              set so_continue_yn = "N"
              set so_err_cnt = so_err_cnt + 1
              set stat = alterlist(err->list,so_err_cnt)
              set err->list[so_err_cnt]->msg = concat("%Error -- Retrieving Reply --> person")
            endif
          endif


          if(so_continue_yn = "Y")
            set Chk_PID = uar_SrvGetDouble(so_hSubPersonStruct, "person_id")
      call echo(build("Chk_ID", Chk_PID))
            if( Chk_PID = 0 )
              set so_continue_yn = "N"
              set so_err_cnt = so_err_cnt + 1
              set stat = alterlist(err->list,so_err_cnt)
              set err->list[so_err_cnt]->msg = concat("%Error -- Srv Copy Failed Person_id = 0")
            endif
          endif
          if(so_continue_yn = "Y")
           ; Send the Transaction
    ;Get handle for request 1215001
    set so_hMsg = uar_SrvSelectMessage(1215001)


          if( so_hMsg = 0)
            set reply->status_data->status = "F"
            set reply->status_data->subeventstatus[1]->operationname = "Unable to obtain message for TDB 1215001"
            set reply->status_data->subeventstatus[1]->operationstatus = "F"
            set reply->status_data->subeventstatus[1]->targetobjectname = "req1215001"
            call pm_destroy_handles(1)
            return
          endif

                set so_hReqMsg = uar_SrvSelectMessage(1215013)
                set so_hReply = uar_SrvCreateReply(so_hReqMsg)
                call uar_SrvDestroyMessage(so_hReqMsg)

                set stat = 0
                set stat = uar_SrvExecute(so_hMsg, so_hReqStruct, so_hReply)

                if(stat != 0)
                  set so_continue_yn = "N"
                  set so_err_cnt = so_err_cnt + 1
                  set stat = alterlist(err->list,so_err_cnt)
                  set err->list[so_err_cnt]->msg = concat("%Error -- Error sending outbound message (encntr_id = ",
                      trim(cnvtstring(ob_encntr_id)),")")
                  set so_err_cnt = so_err_cnt + 1
                  set stat = alterlist(err->list,so_err_cnt)
                 case(stat)
                   of 1:
                     set err->list[so_err_cnt]->msg = "    Communication error in SrvExecute (1215001), no server available."
                   of 2:
                     set err->list[so_err_cnt]->msg = "    Data inconsistency or mismatch in message in SrvExecute (1215001)."
                   of 3:
                     set err->list[so_err_cnt]->msg = "    No handler to service request in SrvExecute (1215001)."
                 endcase
               else
                ;Get status and data from reply structure
                set so_hStatus = uar_SrvGetStruct(so_hReply, "Sb")
                set stat = uar_SrvGetLong(so_hStatus, "STATUS_CD")

                if(stat != 0)
                   set so_continue_yn = "N"
                   set so_err_cnt = so_err_cnt + 1
                   set stat = alterlist(err->list,so_err_cnt)
                   set err->list[so_err_cnt]->msg = concat("%Error -- Error sending outbound message (encntr_id = ",
                       trim(cnvtstring(ob_encntr_id)),")")
                   set so_err_cnt = so_err_cnt + 1
                   set stat = alterlist(err->list,so_err_cnt)
                   set err->list[so_err_cnt]->msg = "    Request to FSI_SRVCQM Server failed."
                endif
               endif

               ;Destroy reply
               if (so_hReply)
                  call uar_SrvDestroyInstance(so_hReply)
                  set so_hReply = 0
               endif

        else
          set so_err_cnt = so_err_cnt + 1
          set stat = alterlist(err->list,so_err_cnt)
          set err->list[so_err_cnt]->msg = concat("BEGINREQ=", cnvtstring(so_crmStatus))
      endif

;Clean up the srv handles

   call pm_destroy_handles(1)

;COPYSTRUCT_SEND_EXIT

;
end

subroutine pm_destroy_handles(iDummy)

   if (validate(so_hReply, -999) != -999)
     if (so_hReply)
		call uar_SrvDestroyInstance(so_hReply)
		set so_hReply = 0
	 endif
   endif

   if (validate(so_hReqStruct, -999) != -999)
     if (so_hReqStruct)
		call uar_SrvDestroyInstance(so_hReqStruct)
		set so_hReqStruct = 0
	 endif
   endif

   if (validate(so_hReq, -999) != -999)
      if (so_hReq)
         call uar_CrmEndReq(so_hReq)
         set so_hReq = 0
      endif
   endif

   if (validate(so_hReqMsg, -999) != -999)
      if (so_hReqMsg)
         set stat = uar_SrvDestroyMessage(so_hReqMsg)
         set so_hReqMsg = 0
      endif
   endif

   if (validate(so_hMsg, -999) != -999)
      if (so_hMsg)
         set stat = uar_SrvDestroyMessage(so_hMsg)
         set so_hMsg = 0
      endif
   endif

   if (validate(so_hStep, -999) != -999)
      if (so_hStep)
         call uar_CrmEndReq(so_hStep)
         set so_hStep = 0
      endif
   endif

   if (validate(so_hTask, -999) != -999)
      if (so_hTask)
         call uar_CrmEndTask(so_hTask)
         set so_hTask = 0
      endif
   endif

   if (validate(so_hApp, -999) != -999)
      if (so_hApp)
         call uar_CrmEndApp(so_hApp)
         set so_hApp= 0
      endif
   endif

end

endif

;create rows record struct
free record rows
record rows
( 1 qual[*]
    2 id_start = f8
    2 id_end = f8
)



for (i = 1 to size(t_rec->qual,5))
	;call send_outbound(t_rec->qual[i].person_id,t_rec->qual[i].encntr_id,t_rec->qual[i].person_id,"A08")
	call send_outbound(t_rec->qual[i].person_id,t_rec->qual[i].encntr_id,t_rec->qual[i].person_id,"A31")
endfor



#exit_script
call exitScript(null)
call echorecord(t_rec)

end go

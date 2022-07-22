drop program pfmt_cov_notify_eso:dba go
create program pfmt_cov_notify_eso:dba

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
        Executing from:		CCL

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

%i ccluserdir:glb_script_logging.inc  
call log_message("pfmt_cov_notify_eso debug execution...", log_level_debug)

if ( ( validate ( last_mod ,  "NOMOD" ) = "NOMOD" ) )
 declare  last_mod  =  c100  with  noconstant ( " " ), private
endif

set  last_mod  =  "000 custom ccl not supported by the irc/iac"

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

declare fillcontrolstructure(inmax = f8,inbatch = i2) = i2

;subroutine for setting up the batches of rows
subroutine fillcontrolstructure(inmax,inbatch)
   set loopcnt = cnvtint(inmax / inbatch) + 1
   set stat = alterlist(rows->qual,loopcnt)
   for (sub_xx = 1 to loopcnt)
      set rows->qual[sub_xx].id_start = inbatch * (sub_xx - 1)
      set rows->qual[sub_xx].id_end = rows->qual[sub_xx].id_start + inbatch
      if ( rows->qual[sub_xx].id_end > inmax)
         set rows->qual[sub_xx].id_end = inmax + 1
      endif
      ;call echo(build("Start:",rows->qual[sub_xx].id_start))
      ;call echo(build("End:",rows->qual[sub_xx].id_end))
   endfor  ;sub_xx
end ;fillcontrolstructure

declare populateEncounterDetails(index = i4) = i2
subroutine populateEncounterDetails(index)

  select into "nl:"
  from encounter e
  where e.encntr_id            = encounters->list[index].encounter_id
    and e.active_ind           = 1
    and e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  head report
    encounters->list[index].patient_id    = e.person_id
    encounters->list[index].status_cd     = e.encntr_status_cd
    encounters->list[index].type_cd       = e.encntr_type_cd
    encounters->list[index].type_class_cd = e.encntr_type_class_cd
    encounters->list[index].create_dt_tm  = e.create_dt_tm
    encounters->list[index].updt_dt_tm    = e.updt_dt_tm
    encounters->list[index].loc_facility_cd = e.loc_facility_cd
  with nocounter
  return (1)
end

/* Request from pm_ens_encntr_prsnl_reltn (101305)
record request (
  1 encntr_prsnl_reltn_qual = i4
  1 esi_ensure_type = vc
  1 encntr_prsnl_reltn[*]
    2 action_type = vc
    2 new_person = vc
    2 encntr_prsnl_reltn_id = f8
    2 prsnl_person_id = f8
    2 encntr_prsnl_r_cd = f8
    2 encntr_id = f8
    2 active_ind_ind = i2
    2 active_ind = i2
    2 active_status_cd = f8
    2 active_status_dt_tm = dq8
    2 active_status_prsnl_id = f8
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 data_status_cd = f8
    2 data_status_dt_tm = dq8
    2 data_status_prsnl_id = f8
    2 contributor_system_cd = f8
    2 free_text_cd = f8
    2 ft_prsnl_name = vc
    2 priority_seq = i4
    2 internal_seq = i4
    2 updt_cnt = i4
    2 expiration_ind_ind = i2
    2 expiration_ind = i2
    2 manual_create_by_id = f8
    2 manual_inact_by_id = f8
    2 manual_create_dt_tm = dq8
    2 manual_inact_dt_tm = dq8
    2 manual_create_ind_ind = i2
    2 manual_create_ind = i2
    2 manual_inact_ind_ind = i2
    2 manual_inact_ind = i2
    2 notification_cd = f8
    2 transaction_dt_tm = dq8
    2 pm_hist_tracking_id = f8
    2 expire_dt_tm = dq8
    2 activity_dt_tm = dq8
    2 demog_reltn_id = f8
    2 encntr_type_cd = f8
    2 phys_override_prsnl_id = f8
    2 phys_override_comments = vc
    2 phys_override_ind = i2
  1 mode = i2
)
*/

free record encounters
record encounters
(
1 list[*]
  2 encounter_id  = f8
  2 patient_id    = f8
  2 status_cd     = f8
  2 type_cd       = f8
  2 type_class_cd = f8
  2 create_dt_tm  = f8
  2 updt_dt_tm    = f8
  2 loc_facility_cd = f8
)

call log_message("pfmt_cov_notify_eso validating 1 request...", log_level_debug)
if(validate(requestin->request->encntr_prsnl_reltn_qual))
	call log_message("pfmt_cov_notify_eso inside validate(requestin->request->encntr_prsnl_reltn_qual)", log_level_debug)
  if(size(requestin->request->encntr_prsnl_reltn_qual,5) > 0)
    call log_message("pfmt_cov_notify_eso inside request->encntr_prsnl_reltn_qual,5) > 0", log_level_debug)
    set stat = alterlist(encounters->list, size(requestin->request->encntr_prsnl_reltn,5))
    for(count = 1 to size(requestin->request->encntr_prsnl_reltn,5))
      set encounters->list[count].encounter_id = requestin->request->encntr_prsnl_reltn[count].encntr_id
      set reportText = concat(reportText, " EncounterID: ", cnvtstring(encounters->list[count].encounter_id))
    endfor
  endif
endif

call log_message("pfmt_cov_notify_eso validating request...", log_level_debug)
if(validate(requestin->request->encntr_id))
	call log_message("pfmt_cov_notify_eso inside validate(requestin->request->encntr_id)", log_level_debug)
      set stat = alterlist(encounters->list,1)
      set encounters->list[1].encounter_id = requestin->request->encntr_id
      set reportText = concat(reportText, " EncounterID: ", cnvtstring(encounters->list[count].encounter_id))
endif

call log_message("pfmt_cov_notify_eso validating encounters->list...", log_level_debug)
if(size(encounters->list,5) = 0)
	call log_message("pfmt_cov_notify_eso encounters->list empty exit_script", log_level_debug)
  go to exit_script
endif

call echorecord(encounters)

for(count = 1 to size(encounters->list,5))
call log_message(build2("pfmt_cov_notify_eso calling ",cnvtstring(count)," of ",
		cnvtstring(size(encounters->list,5))),log_level_debug)
    call populateEncounterDetails(count)
    call send_outbound(
    	encounters->list[count].patient_id,encounters->list[count].encounter_id,encounters->list[count].patient_id,"A08")

endfor
call log_message("pfmt_cov_notify_eso finished processing...", log_level_debug)

#exit_script

call log_message("pfmt_cov_notify_eso exiting...", log_level_debug)

end go

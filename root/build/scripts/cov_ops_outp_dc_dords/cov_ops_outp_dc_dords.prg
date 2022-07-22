
drop program cov_ops_outp_dc_dords:dba go
create program 	:dba

declare PROGRAM_VERSION = vc with private, constant("013")

record reply
(
%i cclsource:status_block.inc
)

set reply->status_data->status = "F"

declare failed_ind = i2
set     failed_ind = 0


;CrmStatus constants
declare CRM_STATUS_OK = i2 with protect, constant(0)
declare CRM_STATUS_COM_ERROR = i2 with protect, constant(1)
declare CRM_STATUS_SEC_CONTEXT_ERR = i2 with protect, constant(69)


;*********************************************************************
;* SUBROUTINE isDebugModeOn                                          *
;* user can manually turn on debug mode by : set isDebug = 1 go      *
;*********************************************************************
declare isDebugModeOn(null) = i2
subroutine isDebugModeOn(null)
   
   declare debug_mode_on = i2 with noconstant (0)
   if (validate(isDebug) = 1)
      if(build(isDebug)="1")
         set debug_mode_on = 1
         call message_line("******************")
         call message_line(" Debug Mode is on ")
         call message_line("******************")
      endif
   endif   
   return (debug_mode_on)
    
end

;*********************************************************************
;* SUBROUTINE populateOrderWriteRequest                              *
;* this call adds one order to request structure each time           *
;*********************************************************************
declare populateOrderWriteRequest (orderListItem=i4, orderId=f8, actionTypeCd=f8, oeFormatId=f8, catalogTypeCd=f8, updtCnt=i4,
catalogCd=f8, orderStatusCd=f8, discontinueTypeCd=f8) = null
subroutine populateOrderWriteRequest (orderListItem, orderId, actionTypeCd, oeFormatId, catalogTypeCd, updtCnt, catalogCd,
orderStatusCd, discontinueTypeCd)
   declare srvStat    = i4 with protect, noconstant (0)
   set srvStat = uar_SrvSetDouble (orderListItem, "orderId", orderId)
   set srvStat = uar_SrvSetDouble (orderListItem, "actionTypeCd", actionTypeCd)
   set srvStat = uar_SrvSetDouble (orderListItem, "oeFormatId", oeFormatId)
   set srvStat = uar_SrvSetDouble (orderListItem, "catalogTypeCd", catalogTypeCd)
   set srvStat = uar_SrvSetLong (orderListItem, "lastUpdtCnt", updtCnt)
   set srvStat = uar_SrvSetDouble (orderListItem, "catalogCd", catalogCd)
   set srvStat = uar_SrvSetDouble (orderListItem, "orderStatusCd", orderStatusCd)
   set srvStat = uar_SrvSetDouble (orderListItem, "discontinueTypeCd", discontinueTypeCd)
end
 
;**************************************************************************
;* SUBROUTINE logOrderWriteProgress                                       *
;* param: numberOfReqItems - number of items in request                   *
;* param: currentNumberProcessed - number of items been processed         *
;* param: totalNumberProcessed - total number of items to be processed    *
;* this call display current process status                               *
;**************************************************************************
declare logOrderWriteProgress (numberOfReqItems=i4, currentNumberProcessed=i4, totalNumberProcessed=i4) = null
subroutine logOrderWriteProgress (numberOfReqItems, currentNumberProcessed, totalNumberProcessed)
 
   call echo(build("> Process status update: [", numberOfReqItems," items, ",
	format(((cnvtreal(currentNumberProcessed)/cnvtreal(totalNumberProcessed))*100.0), "###.##"),"% complete]..."))
end
 
;*********************************************************************
;* SUBROUTINE callOrderWriteServer                                   *
;* param: stepHandle - Order Write Synch step handle                 *
;* param: requestListSize - Size of the orderList list in request    *
;* param: logErrorMessageInd - debug mode indicator. debug mode is   *
;* set only if logErrorMessageInd                                    *
;* return: CRM status of the call                                    *
;* Calls the Order Write server with the request associated to the   *
;* supplied stepHandle.                                              *
;*********************************************************************
/*
declare callOrderWriteServer(stepHandle=i4, requestListSize=i4, logErrorMessageInd =i2 ) = i4
subroutine callOrderWriteServer(stepHandle, requestListSize,logErrorMessageInd )
   declare crmStatus = i4 with protect, noconstant(uar_CrmPerform(stepHandle))
   if(crmStatus != 0)
      call echo(build2("CRM error in calling Order Write Synch server: ", crmStatus))
      return (crmStatus)
   endif
 
   ; this is debug mode
   if(logErrorMessageInd = 1)
      declare owsReply              = i4 with noconstant(uar_CrmGetReply(stepHandle))
      declare owsReplyStatusBlock   = i4 with protect, noconstant(uar_SrvGetStruct(owsReply,"status_data"))
      declare owsReplyStatus        = vc with noconstant (uar_SrvGetStringPtr(owsReplyStatusBlock,"status"))
 
   ; Checks to see if any orders failed
      if (owsReplyStatus = "F")
         declare orderListRepItem      = i4 with noconstant(0)
 
         ; Process the reply - report any errors that are encountered
         for (replyListIdx = 0 to requestListSize)
            set orderListRepItem = uar_SrvGetItem(owsReply, "orderList", replyListIdx)
 
            ;if the orderList->errorNbr > 0, then this orderList item failed
            if (uar_SrvGetLong(orderListRepItem,"errorNbr") > 0)
               call echo(build("-> Order (ID:", uar_SrvGetDouble(orderListRepItem, "orderId"), ") failed due to ->",
               getOrderWriteErrorMessagesFromReply (orderListRepItem)))
            endif
         endfor
         set orderListRepItem = 0
      endif
   endif
 
   set stepHandle = 0
   return (crmStatus)
end
*/ 
;************************************************************************
;* SUBROUTINE getOrderWriteErrorMessagesFromReply                       *
;* param: orderListReplyItem - orderList reply item                     *
;* return: Specific error message for the supply orderListReplyItem     *
;************************************************************************
declare getOrderWriteErrorMessagesFromReply(orderListReplyItem=i4) = vc
subroutine getOrderWriteErrorMessagesFromReply(orderListReplyItem)
 
   declare specificErrorStr   = vc with noconstant("")
   declare substrBegin        = i4 with noconstant(0)
   declare substrLength       = i4 with noconstant(0)
 
   set specificErrorStr = uar_SrvGetStringPtr(orderListReplyItem,"specificErrorStr")
   if (specificErrorStr != "")
      set substrBegin = findstring("]: ", specificErrorStr, 1) + 3
      set substrLength = size(specificErrorStr, 1) - substrBegin + 1
      return (substring(substrBegin, substrLength, specificErrorStr))
   endif
 
   return ("")
 
end
 
 
;************************************************************************
;* SUBROUTINE message_line                                              *
;* param: msg - message to display                                      *
;* this is just a helper subroutine to print out debug message          *
;************************************************************************
declare message_line(msg =vc) = null
subroutine message_line(msg)
 
   call echo(build2("********************", msg, "********************"))
 
end
 


; number max orders per request
declare MAX_ORDERS_SIZE = i4 with constant(50)

;this variable keep track of the number of orders that will be processed
declare number_of_orders = i4 with noconstant(0)

; user can manually turn on debug mode by : set isDebug = 1 go
declare debug_mode_on = i2 with noconstant (0)

if (validate(isDebug) = 1)
   
   if(build(isDebug)="1")
      set debug_mode_on = 1
      call message_line("******************")
      call message_line(" Debug Mode is on ")
      call message_line("******************")
   endif
endif

/*********************************************/
/*****  DATA STRUCTURES                  *****/
/*********************************************/

   record hold
   (
      1 enc_cnt             = i4
      1 enc[*]
        2 encntr_id         = f8
        2 ord_cnt           = i4
        2 ord[*]
          3 order_id        = f8
          3 order_status_cd = f8
          3 action_type_cd  = f8
          3 action          = c20
          3 catalog_cd      = f8
          3 catalog_type_cd = f8
          3 updt_cnt        = i4
          3 oe_format_id    = f8
   )


   record cval
   (
      1 inprocess_status_cd    = f8
      1 ordered_status_cd      = f8
      1 discontinued_status_cd = f8
      1 canceled_status_cd     = f8
      1 medstudent_status_cd   = f8
      1 incomplete_status_cd   = f8
      1 suspended_status_cd    = f8
      1 discontinue_action_cd  = f8
      1 cancel_action_cd       = f8
      1 inpatient_cd           = f8
      1 disc_type_cd           = f8          
   )

   record dstat
   ( 
      1 cnt                = i4
      1 qual[*]
        2 dstat_code_value = f8
   )

/*********************************************/
/***** read DCPCNCLPRN, DCPCNCLUNSCH, and  ***/
/***** OUTDSCH_HRS from config_prefs table ***/
/*********************************************/

   declare dcp_allow_cancel_unsch = i2 with protect, noconstant (0)
   declare dcp_allow_cancel_prn = i2 with protect, noconstant (0)
   declare dsch_hours = f8 with protect, noconstant(12.0)
	
   call echo ("Looking up preferences from config_prefs table...")

   select into "nl:"
      cp.config_name
   from
      config_prefs cp
   where
      cp.config_name in ("DCPCNCLUNSCH", "DCPCNCLPRN", "OUTDSCH_HRS")
   detail
      if(cp.config_name = "DCPCNCLUNSCH" and cp.config_value= "1")
         dcp_allow_cancel_unsch = 1
      elseif(cp.config_name = "DCPCNCLPRN" and cp.config_value= "1")
         dcp_allow_cancel_prn = 1
      elseif(cp.config_name = "OUTDSCH_HRS")
         dsch_hours = cnvtreal(trim(cp.config_value))
      endif
		
   with nocounter
   
   call echo (build("DCPCNCLUNSCH:",dcp_allow_cancel_unsch))
   call echo (build("DCPCNCLPRN:",dcp_allow_cancel_prn))
   call echo (build("disch hours: ",dsch_hours))

/*********************************************/
/*****  GET OUTDSCH_FLAG PREFERENCES     *****/
/*********************************************/

   declare check_start_ind = i2
   set     check_start_ind = 0
 
   declare start_plus_hrs = i4                               
   set     start_plus_hrs = 0            
	
   declare start_check_time = f8 with protect, noconstant(cnvtdatetime(curdate,curtime3))
	
   declare dsch_cancel_flag = i2
   set     dsch_cancel_flag = 3

   select into "nl:"
      cp.config_name
   from
      config_prefs cp
   where
      cp.config_name = "OUTDSCH_FLAG"
   detail
      tmp_val = substring(1,3,trim(cp.config_value))
      if (tmp_val = "ALL")
         dsch_cancel_flag = 1
      elseif (tmp_val = "ORD")
         dsch_cancel_flag = 2
      else
         dsch_cancel_flag = 3
      endif  
      if (dsch_cancel_flag = 1 or dsch_cancel_flag = 2)     
         tmp_val2 = substring(4,1,trim(cp.config_value))    
         if (tmp_val2 = ">")                                
            tmp_val3 = substring(5,1,trim(cp.config_value)) 
            if (tmp_val3 > " ")                             
               start_plus_hrs = dsch_hours                  
               if (start_plus_hrs >= 0)                     
                  check_start_ind = 1                       
               endif                                        
            endif                                           
         endif                                              
      endif                                                 
   with nocounter

   CALL ECHO (BUILD("disch cancel flag: ",dsch_cancel_flag))

/*********************************************/
/*****  DETERMINE TIME RANGE             *****/
/*********************************************/
 
   declare clean_days = i4         ;009
   set clean_days = 0            ;009

   declare dsch_days = i4         ;009
   set dsch_days = (dsch_hours/24) + 2      ;009
   call echo (build("dsch_days-->", dsch_days))   ;009

   declare check_clean_ind = i2
   set check_clean_ind = 0

   declare clean_hours = i4
   set     clean_hours = 0

   if (check_start_ind = 1 or dsch_cancel_flag = 2)                                      
      select into "nl:"                                          
         cp.config_name                                          
      from                                                       
         config_prefs cp                                         
      where                                                      
         cp.config_name = "OUTCLEAN_HRS"                          
      detail                                                     
         clean_hours = cnvtreal(trim(cp.config_value))           
      with nocounter                                             
                   
      if (clean_hours > 0)                                       
         CALL ECHO (BUILD("disch hours: ",dsch_hours))           
         set check_clean_ind = 1                                 
         set     clean_days = (clean_hours/24) + 2      ;009
         call echo (build("clean_days-->", clean_days))      ;009
      endif                                                      
   endif                                                         

   declare now         = f8 with protect, constant(cnvtdatetime(curdate,curtime3))
   declare min_dsch_dt_tm = f8 with protect, noconstant(0.0)
   declare max_dsch_dt_tm = f8 with protect, noconstant(0.0)
   call echo (build("now->", format(now, ";;q")))

   if (dsch_days > clean_days)               ;009
      set min_dsch_dt_tm  = datetimeadd(now, -(dsch_days))   ;009
   else                        ;009
      set min_dsch_dt_tm  = datetimeadd(now, -(clean_days))   ;009
   endif                     ;009
   call echo (build("min_dsch_dt_tm->", format(min_dsch_dt_tm, ";;q")))     ;009

   set max_dsch_dt_tm = cnvtdatetime(curdate,curtime3)     ;009
   if (dsch_hours > 0)                                           
      set max_dsch_dt_tm  = datetimeadd(now,-(dsch_hours/24.0)) ;009
   endif                                                         
   call echo (build("max_dsch_dt_tm->", format(max_dsch_dt_tm, ";;q")))    ;009

/*********************************************/
/**********  LOAD CODE VALUES   **************/
/*********************************************/

   call echo ("Looking up code_values...")

   set cval->ordered_status_cd      = uar_get_code_by("MEANING",6004,"ORDERED")
   set cval->inprocess_status_cd    = uar_get_code_by("MEANING",6004,"INPROCESS")
   set cval->discontinued_status_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
   set cval->canceled_status_cd     = uar_get_code_by("MEANING",6004,"CANCELED")
   set cval->incomplete_status_cd   = uar_get_code_by("MEANING",6004,"INCOMPLETE")
   set cval->medstudent_status_cd   = uar_get_code_by("MEANING",6004,"MEDSTUDENT")
   set cval->suspended_status_cd    = uar_get_code_by("MEANING",6004,"SUSPENDED")
   set cval->inpatient_cd           = uar_get_code_by("MEANING",69,"INPATIENT")
   set cval->disc_type_cd           = uar_get_code_by("MEANING",4038,"SYSTEMDISCH")
   set cval->discontinue_action_cd  = uar_get_code_by("MEANING",6003,"DISCONTINUE")
   set cval->cancel_action_cd       = uar_get_code_by("MEANING",6003,"CANCEL")  
   
   if (cval->canceled_status_cd = 0 or cval->discontinued_status_cd = 0)
      call echo("**** missing an order status code****")
      set failed_ind=1
      set reply->status_data->subeventstatus[1]->operationname = "dcp_ops_outp_dc_dords"
      set reply->status_data->subeventstatus[1]->operationstatus = "F"
      set reply->status_data->subeventstatus[1]->targetobjectname = "order status missing"
      go to exit_script
   endif
  
   if (cval->inpatient_cd = 0 )
      call echo("**** missing inpatient encntr type class on codeset 69 ****")
      set failed_ind=1
      set reply->status_data->subeventstatus[1]->operationname = "dcp_ops_outp_dc_dords"
      set reply->status_data->subeventstatus[1]->operationstatus = "F"
      set reply->status_data->subeventstatus[1]->targetobjectname = "inpatient (cs 69) missing"
      go to exit_script
   endif
   
   if (cval->discontinue_action_cd = 0 or cval->cancel_action_cd = 0)
      call echo("**** missing an order action code****")
      set failed_ind=1
      set reply->status_data->subeventstatus[1]->operationname = "dcp_ops_outp_dc_dords"
      set reply->status_data->subeventstatus[1]->operationstatus = "F"
      set reply->status_data->subeventstatus[1]->targetobjectname = "order action missing"
      go to exit_script
   endif
 
/************************************************/
/*** LOAD CANCELLABLE DEPT STATUS CODE VALUES ***/
/************************************************/

   select into "nl:"
      cve.code_value
   from code_value_extension cve
   where cve.code_set = 14281 and cve.field_name = "DCP_ALLOW_CANCEL_IND"
   detail
      cancel_ind = cnvtint(trim(cve.field_value))
      if (cancel_ind = 1)
         dstat->cnt = dstat->cnt + 1
         stat = alterlist(dstat->qual,dstat->cnt)
         dstat->qual[dstat->cnt].dstat_code_value = cve.code_value
         call echo(uar_get_code_display(cve.code_value))
      endif
   with nocounter

   call echo("Searching for qualified orders...")

/************************************************/
/*** GET ENCOUNTERS/ORDERS THAT QUALIFY       ***/
/***  FOR "ALL" PREFERENCE                    ***/
/************************************************/
   set hold->enc_cnt = 0
   declare cancel_ind = i2 with protect, noconstant (0)
   declare oc = i4 with protect, noconstant (0)
	
   if (dsch_cancel_flag = 1)
      select into "nl:"
         e.encntr_id,
         o.order_id
      from encounter e,
           orders o
      plan e 
      where e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm) ;009
      and   e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm) ;009
      and   e.encntr_type_class_cd+0 != cval->inpatient_cd 
      and   e.encntr_id = 116212832
      join o 
      where o.encntr_id = e.encntr_id 
      and   o.order_status_cd+0 in (cval->ordered_status_cd, cval->inprocess_status_cd,
                                    cval->medstudent_status_cd, cval->incomplete_status_cd, 
                                    cval->suspended_status_cd)
      and o.orig_ord_as_flag+0 in (0,5)   

      order by e.encntr_id

      head e.encntr_id
         hold->enc_cnt = hold->enc_cnt + 1
         if (hold->enc_cnt > size (hold->enc,5))
            stat = alterlist(hold->enc, hold->enc_cnt+5)
         endif
         hold->enc[hold->enc_cnt].ord_cnt = 0
         hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      detail
         cancel_ind = 0		
         /***********************************************************************
         * If they are careset/supergroup parents we don't want them to qualify *
         *  unless they are a template, prn or constant                         *
         ***********************************************************************/
         if (o.cs_flag in (1, 3, 4, 6))     
            cancel_ind = 0                  
         else                               
            cancel_ind = 0
            for (dd = 1 to dstat->cnt)
                if (dstat->qual[dd].dstat_code_value = o.dept_status_cd)
                   if (check_start_ind = 1)                                                      
                      start_check_time = datetimeadd(e.disch_dt_tm,start_plus_hrs/24.0)          
                      if (o.current_start_dt_tm > cnvtdatetime(start_check_time) and             
                          o.template_order_flag in (0,1,2,6))                                    
                         cancel_ind = 1                                                          
                      else                                                                       
                         if (check_clean_ind = 1)                                                
                            clean_disch_time = datetimeadd(e.disch_dt_tm,clean_hours/24.0)       
                            ;call echo (build("clean disch:",clean_disch_time))                    
                            ;call echo (build("now:",now))                                        
                            if (cnvtdatetime(curdate,curtime3) > cnvtdatetime(clean_disch_time)) 
                               cancel_ind = 1                                                    
                               call echo ("build because of clean one")                              
                            endif                                                                
                         endif                                                                   
                      endif                                                                      
                   else                                                                          
                     cancel_ind = 1
                   endif                                                                        
                endif                                                             
            endfor
         endif                               

         if (o.template_order_flag = 1 or                                                  
             o.prn_ind = 1 or                                                              
             o.constant_ind = 1 or
             o.freq_type_flag = 5)
				
            /********************************************************************************************************
            * Unscheduled orders will honor the code value extension DCP_ALLOW_CANCEL setting when DCPCNCLUNSCH = 1 *
            * PRN orders will honor the code value extension DCP_ALLOW_CANCEL setting when DCPCNCLPRN = 1           *
            ********************************************************************************************************/
            if((o.prn_ind = 1 and dcp_allow_cancel_prn = 1) or (o.freq_type_flag = 5 and dcp_allow_cancel_unsch = 1))
               for (dd = 1 to dstat->cnt)
                  if (dstat->qual[dd].dstat_code_value = o.dept_status_cd)               
                     cancel_ind = 1
                  endif                                                                         
               endfor
            else
               cancel_ind = 1
            endif
				
         endif                                                                             

         if (cancel_ind = 1)
            hold->enc[hold->enc_cnt].ord_cnt = hold->enc[hold->enc_cnt].ord_cnt + 1
            oc = hold->enc[hold->enc_cnt].ord_cnt
            if (oc > size (hold->enc[hold->enc_cnt].ord,5))
               stat = alterlist(hold->enc[hold->enc_cnt].ord, oc+5)
            endif
            hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id
            hold->enc[hold->enc_cnt].ord[oc].catalog_cd = o.catalog_cd
            hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd
            hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt
            hold->enc[hold->enc_cnt].ord[oc].oe_format_id = o.oe_format_id
            if (o.current_start_dt_tm < cnvtdatetime (curdate, curtime3) and
                o.order_status_cd != cval->medstudent_status_cd) ;010 
               hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd
               hold->enc[hold->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd
               hold->enc[hold->enc_cnt].ord[oc].action = "DISCONTINUE"
            else
               hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->canceled_status_cd
               hold->enc[hold->enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd
               hold->enc[hold->enc_cnt].ord[oc].action = "CANCEL"
            endif 
            number_of_orders = number_of_orders + 1
         endif
      foot e.encntr_id
         stat = alterlist (hold->enc[hold->enc_cnt].ord, oc)
      with nocounter 

      if (hold->enc_cnt = 0)
         go to exit_script
      endif
   endif

/************************************************/
/*** GET ENCOUNTERS/ORDERS THAT QUALIFY       ***/
/***  FOR "ORD" PREFERENCE                    ***/
/************************************************/

   if (dsch_cancel_flag = 2)
   call echorecord(dstat)
      select into "nl:"
         e.encntr_id,
         o.order_id,
         oc.catalog_cd
      from encounter e,
           orders o,
           order_catalog oc
      plan e 
      where ;e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm) ;009
     ; and   
      e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm) ;009
      and   e.encntr_type_class_cd+0 != cval->inpatient_cd 
      and   e.encntr_id=116212832
      join o 
      where o.encntr_id = e.encntr_id 
      and   o.order_status_cd+0 in (cval->ordered_status_cd,    cval->inprocess_status_cd,
                                    cval->medstudent_status_cd, cval->incomplete_status_cd, 
                                    cval->suspended_status_cd)
      and o.orig_ord_as_flag in (0,5)                    

      join oc 
      where oc.catalog_cd = o.catalog_cd 

      order by e.encntr_id

      head e.encntr_id
         hold->enc_cnt = hold->enc_cnt + 1
         if (hold->enc_cnt > size(hold->enc,5))
            stat = alterlist(hold->enc, hold->enc_cnt+5)
         endif
         hold->enc[hold->enc_cnt].ord_cnt = 0
         hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      detail
         cancel_ind = 0
         /**********************************************************************************
         * If they are careset/supergroup parents we don't want them to qualify            *
         *  unless they are a template, prn or constant (prn and constant shouldn't apply) *
         **********************************************************************************/
         if (o.cs_flag in (1, 3, 4, 6))     
            cancel_ind = 0                  
         else                               
            cancel_ind = 0
            for (dd = 1 to dstat->cnt)
                if (dstat->qual[dd].dstat_code_value = o.dept_status_cd)
                   if (check_start_ind = 1)                                                       
                      start_check_time = datetimeadd(e.disch_dt_tm,start_plus_hrs/24.0)           
                      if (o.current_start_dt_tm > cnvtdatetime(start_check_time) and              
                          o.template_order_flag in (0,1,2,6))                                     
                         cancel_ind = 1                                                           
                      else                                                                        
                         if (check_clean_ind = 1)                                                 
                            clean_disch_time = datetimeadd(e.disch_dt_tm,clean_hours/24.0)        
                            call echo (build("clean disch:",clean_disch_time))                     
                            call echo (build("now:",now))                                         
                            if (cnvtdatetime(curdate,curtime3) > cnvtdatetime(clean_disch_time))  
                               cancel_ind = 1                                                     
                               call echo ("build because of clean two")                               
                            endif                                                                 
                         endif                                                                    
                      endif                                                                       
                   else                                                                           
                      cancel_ind = 1
                   endif                                                                          
                endif
            endfor
         endif                              

         orc_cancel_ind = 0

         if (o.template_order_flag = 1 or
             o.prn_ind = 1             or                                                      
             o.constant_ind = 1        or                                                      
             oc.auto_cancel_ind = 1    or
             o.freq_type_flag = 5)
            orc_cancel_ind = 1
            if (o.template_order_flag = 1 or                                                   
                o.prn_ind = 1             or                                                   
                o.constant_ind = 1        or
                o.freq_type_flag = 5)
               
               /********************************************************************************************************
               * Unscheduled orders will honor the code value extension DCP_ALLOW_CANCEL setting when DCPCNCLUNSCH = 1 *
               * PRN orders will honor the code value extension DCP_ALLOW_CANCEL setting when DCPCNCLPRN = 1           *
               ********************************************************************************************************/
               if((o.prn_ind = 1 and dcp_allow_cancel_prn = 1) or (o.freq_type_flag = 5 and dcp_allow_cancel_unsch = 1))
                  for (dd = 1 to dstat->cnt)
                     if (dstat->qual[dd].dstat_code_value = o.dept_status_cd)                        
                        cancel_ind = 1
                     endif                                                                         
                  endfor
               else
                  cancel_ind = 1
               endif					
                                                                 
            endif                                                                              
         endif

         if (cancel_ind = 1 and orc_cancel_ind = 1)
            hold->enc[hold->enc_cnt].ord_cnt = hold->enc[hold->enc_cnt].ord_cnt + 1
            oc = hold->enc[hold->enc_cnt].ord_cnt
            if (oc > size (hold->enc[hold->enc_cnt].ord,5))
               stat = alterlist(hold->enc[hold->enc_cnt].ord, oc+10)
            endif
            hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id
            hold->enc[hold->enc_cnt].ord[oc].catalog_cd = o.catalog_cd
            hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd
            hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt
            hold->enc[hold->enc_cnt].ord[oc].oe_format_id = o.oe_format_id
           if (o.current_start_dt_tm < cnvtdatetime (curdate, curtime3) and  ;002
               o.order_status_cd != cval->medstudent_status_cd)  ;010  
              hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd
              hold->enc[hold->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd
              hold->enc[hold->enc_cnt].ord[oc].action = "DISCONTINUE"
           else
              hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->canceled_status_cd
              hold->enc[hold->enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd
              hold->enc[hold->enc_cnt].ord[oc].action = "CANCEL"
           endif 
           number_of_orders = number_of_orders + 1
        endif
      foot e.encntr_id 
         stat = alterlist(hold->enc[hold->enc_cnt].ord, oc)
      with nocounter 
   
      if (hold->enc_cnt = 0)
         go to exit_script
      endif
   endif

/************************************************/
/*** GET ENCOUNTERS/ORDERS THAT QUALIFY       ***/
/***  FOR "ORD" PREFERENCE                    ***/
/************************************************/

   if (dsch_cancel_flag = 3)
     
      select into "nl:"
         e.encntr_id,
         o.order_id
      from encounter e,
           orders o
      plan  e 
      where e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm) ;009
      and   e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm) ;009
      and   e.encntr_type_class_cd + 0 != cval->inpatient_cd 
      and   e.encntr_id = 116212832
      join o where (o.encntr_id = e.encntr_id 
      and  o.order_status_cd+0 in (cval->ordered_status_cd,    cval->inprocess_status_cd,
                                  cval->medstudent_status_cd, cval->incomplete_status_cd, 
                                  cval->suspended_status_cd)
      and o.orig_ord_as_flag in (0,5)               
      and (o.template_order_flag = 1 
      or   o.prn_ind = 1            
      or   o.constant_ind = 1
      or   o.freq_type_flag = 5))

      head e.encntr_id
         hold->enc_cnt = hold->enc_cnt + 1
         if (hold->enc_cnt > size(hold->enc, 5)) 
            stat = alterlist(hold->enc, hold->enc_cnt+5)
         endif
         hold->enc[hold->enc_cnt].ord_cnt = 0
         hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      detail
         hold->enc[hold->enc_cnt].ord_cnt = hold->enc[hold->enc_cnt].ord_cnt + 1
         oc = hold->enc[hold->enc_cnt].ord_cnt
         if (oc > size(hold->enc[hold->enc_cnt].ord,5))
            stat = alterlist(hold->enc[hold->enc_cnt].ord, oc+10)
         endif
         hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id
         hold->enc[hold->enc_cnt].ord[oc].catalog_cd = o.catalog_cd
         hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd
         hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt
         hold->enc[hold->enc_cnt].ord[oc].oe_format_id = o.oe_format_id
         if (o.current_start_dt_tm < cnvtdatetime (curdate, curtime3) and
             o.order_status_cd != cval->medstudent_status_cd) ;010 
            hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd
            hold->enc[hold->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd
            hold->enc[hold->enc_cnt].ord[oc].action = "DISCONTINUE"
         else
            hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->canceled_status_cd
            hold->enc[hold->enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd
            hold->enc[hold->enc_cnt].ord[oc].action = "CANCEL"
         endif
         number_of_orders = number_of_orders + 1
      foot e.encntr_id 
         stat = alterlist(hold->enc[hold->enc_cnt].ord, oc)
      with nocounter 
 
      if (hold->enc_cnt = 0)
         go to exit_script
      endif
   endif

   call message_line("********************")
   call echo(build("Number of qualified encounters =", hold->enc_cnt))
   call echo(build("Number of qualified orders =", number_of_orders))
   call message_line("********************")

   ;****************************************************************
   ;* Calling the Order Write server using the UAR CRM calls       *
   ;****************************************************************
   ;CRM VARIABLES
   declare hApp       = i4 with protect, noconstant (0)
   declare hTask      = i4 with protect, noconstant (0)
   declare hStep      = i4 with protect, noconstant (0)
 
   ;Include the CRMRTL UARS
   execute crmrtl
   execute srvrtl
    
   declare hReq       = i4 with protect, noconstant (0)
   declare hItem      = i4 with protect, noconstant (0)
   declare srvStat    = i4 with protect, noconstant (0)
   declare ows_request_size = i4 with protect, noconstant(0)
      
   ;Create CRM Handle for the App
   set crmStatus = uar_CrmBeginApp(560210, hApp)
   if(crmStatus != 0)
      call echo("Error in Begin App for application 560210.")
      call echo(build("Crm Status:", crmStatus))
      go to exit_script
   endif
      
      ;Create CRM Handle for the Task
   set crmStatus = uar_CrmBeginTask(hApp, 500210, hTask)
   if(crmStatus != 0)
      call echo("Error in Begin Task for task 500210.")
      call echo(build("Crm Status:", crmStatus))
      go to exit_script
    endif
   
   ;Create CRM Handle for the Request
   set crmStatus = uar_CrmBeginReq(hTask, "", 560201, hStep)
   if(crmStatus != 0)
      call echo("Error in Begin Request for request 560201.")
      call echo(build("Crm Status:", crmStatus))
      go to exit_script
   endif
    
   ;Initialize the hReq to begin populating   
   set hReq = uar_CrmGetRequest(hStep)

   call echo (build2("Orders will be processed in blocks of: ", build(MAX_ORDERS_SIZE)))
   call echo("Updating qualified orders...")
   
   ;current number of orders have been put into request
   declare orders_counter = i4 with noconstant(0)

   set stat = alterlist(hold->enc, hold->enc_cnt)

   for (encntr = 1 to hold->enc_cnt)
       
      for (ord = 1 to hold->enc[encntr].ord_cnt)
            
         ; contructing Request
         set hItem = uar_SrvAddItem(hReq, "orderList")   
         call populateOrderWriteRequest(hItem, hold->enc[encntr].ord[ord]->order_id,
                                         hold->enc[encntr].ord[ord]->action_type_cd,
                                         hold->enc[encntr].ord[ord]->oe_format_id,
                                         hold->enc[encntr].ord[ord]->catalog_type_cd,
                                         hold->enc[encntr].ord[ord]->updt_cnt,
                                         hold->enc[encntr].ord[ord]->catalog_cd,
                                         hold->enc[encntr].ord[ord]->order_status_cd,
                                         cval->disc_type_cd
                                         )   

         set orders_counter = orders_counter + 1

         ;check if there are 50 orders ready to be processed
         if (mod(orders_counter, MAX_ORDERS_SIZE) = 0)
      
            ; call order write server to process 50 orders
           ; DO NOT REMOVE ORDERS set failed_ind = callOrderWriteServer(hStep, MAX_ORDERS_SIZE, debug_mode_on)
           
            ; free up the request
            call uar_SrvReset(hReq, 0)
            
          ;  if (debug_mode_on)
             ;call message_line(build2("Memory Status after ", build(orders_counter/MAX_ORDERS_SIZE) ," call/calls to the server"))
             ;  call trace(7)
			;	   call message_line("********************************************************")
           ; endif
               
            ;If the Order Write Server call fails, exit the script
            if (failed_ind)
                 go to exit_script
              endif

            ;call logOrderWriteProgress (MAX_ORDERS_SIZE, orders_counter, number_of_orders)
         endif
      endfor
   endfor

   ;checked and processed remaining orders in the request
   if(mod(orders_counter, MAX_ORDERS_SIZE) != 0)

     ; set failed_ind = callOrderWriteServer(hStep, MAX_ORDERS_SIZE, debug_mode_on)
    
      ; free up the request
      call uar_SrvReset(hReq, 0)
            
      if (debug_mode_on)
         call message_line(build2("Memory Status after ", build(orders_counter/MAX_ORDERS_SIZE+1) ," call/calls to the server"))
         call trace(7)
			call message_line("********************************************************")
      endif

      ;If the Order Write Server call fails, exit the script
      if (failed_ind)
         go to exit_script
      endif 
      
     ; call logOrderWriteProgress (mod(orders_counter, MAX_ORDERS_SIZE), orders_counter, number_of_orders)
   endif

;************************
;* exiting script       *
;************************
#exit_script
   
   if (failed_ind=0)
      set reply->status_data->status="S"
      call echo(build("status:", reply->status_data->status))
   else
      call echo("Error occured!")
      set reply->status_data->status="F"
      call echo(build("status:", reply->status_data->status))
      call echo(build("failed uar:", reply->status_data->subeventstatus[1]->targetobjectname))
      call echo(build("buf string:", reply->status_data->subeventstatus[1]->targetobjectvalue)) 
   endif
  
   if(hold->enc_cnt>0)

      ;Clean up CRM handles and ensure they are set to 0 before exiting
      ; Clean up step
        if (hStep != 0)
         call uar_CrmEndReq(hStep)
         set hStep = 0
      endif
      ; Clean up task
      if (hTask != 0)
         call uar_CrmEndTask(hTask)
         set hTask = 0
      endif
      ; Clean up app
      if (hApp != 0)
         call uar_CrmEndApp(hApp)
         set hApp = 0
      endif
   else
      call message_line(" no encounter qualified! ")
   endif
   ;Free internal structures
   call echojson(hold,"holdrec.dat")
   free record hold 
   free record cval
   free record dstat

end go



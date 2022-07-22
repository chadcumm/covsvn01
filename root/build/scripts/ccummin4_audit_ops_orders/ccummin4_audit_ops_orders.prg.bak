
drop program ccummin4_audit_ops_orders:dba go
create program ccummin4_audit_ops_orders:dba

declare PROGRAM_VERSION = vc with private, constant("013")

record reply
(
%i cclsource:status_block.inc
)

set reply->status_data->status = "F"

declare failed_ind = i2
set     failed_ind = 0

;************************************************************************
;* SUBROUTINE message_line                                              *
;* param: msg - message to display                                      *
;* this is just a helper subroutine to print out debug message          *
;************************************************************************
declare message_line(msg =vc) = null
subroutine message_line(msg)
 
   call echo(build2("********************", msg, "********************"))
 
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
/***** INDSCH_HRS from config_prefs table  ***/
/*********************************************/

   declare dcp_allow_cancel_unsch = i2 with protect, noconstant (0)
   declare dcp_allow_cancel_prn = i2 with protect, noconstant (0)
   declare dsch_hours = f8 with protect, noconstant(0.0)
	
   call echo ("Looking up preferences from config_prefs table...")

   select into "nl:"
      cp.config_name
   from
      config_prefs cp
   where
      cp.config_name in ("DCPCNCLUNSCH", "DCPCNCLPRN", "INDSCH_HRS")
   detail
      if(cp.config_name = "DCPCNCLUNSCH" and cp.config_value= "1")
         dcp_allow_cancel_unsch = 1
      elseif(cp.config_name = "DCPCNCLPRN" and cp.config_value= "1")
         dcp_allow_cancel_prn = 1
      elseif(cp.config_name = "INDSCH_HRS")
         dsch_hours = cnvtreal(trim(cp.config_value))
      endif
		
   with nocounter
   
   call echo (build("DCPCNCLUNSCH:",dcp_allow_cancel_unsch))
   call echo (build("DCPCNCLPRN:",dcp_allow_cancel_prn))
   call echo (build("dsch_hours:",dsch_hours))

/**********************************************/
/*****  GET INDSCH_FLAG PREFERENCE        *****/
/**********************************************/

   call echo ("looking up INDSCH_FLAG preference")

   declare dsch_cancel_flag = i2
   set     dsch_cancel_flag = 3

   declare check_start_ind = i2                        
   set     check_start_ind = 0                       

   declare start_plus_hrs = i4                        
   set     start_plus_hrs = 0                      

   declare start_check_time = f8 with protect, noconstant(cnvtdatetime(curdate,curtime3))

   select into "nl:"
      cp.config_name
   from
      config_prefs cp
   where
      cp.config_name = "INDSCH_FLAG"
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

   call echo (build("dsch_cancel_flag:",dsch_cancel_flag))
   call echo (build("check_start_ind:",check_start_ind))
   call echo (build("start_plus_hrs:",start_plus_hrs))

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

   declare clean_hours = f8                              
   set clean_hours = 0                                       

   if (check_start_ind = 1 or dsch_cancel_flag = 2)       ;009                                  
                                                            
      call echo ("looking up INCLEAN_HRS preference")

      select into "nl:"                                     
         cp.config_name                                   
      from config_prefs cp                               
      where                                                 
         cp.config_name = "INCLEAN_HRS"                     
      detail                                                 
         clean_hours = cnvtreal(trim(cp.config_value))       
      with nocounter                                         
                                                             
      if (clean_hours > 0)                                   
         CALL ECHO (BUILD("clean hours: ",clean_hours))       
         set check_clean_ind = 1                            
         set clean_days = (clean_hours/24) + 2         ;009
         call echo (build("clean_days-->", clean_days))      ;009
      endif                                                    
   endif                                                    

   declare now         = f8 with protect, constant(cnvtdatetime(curdate,curtime3))
   declare min_dsch_dt_tm = f8 with protect, noconstant(0.0)
   declare max_dsch_dt_tm = f8 with protect, noconstant(0.0)
   call echo (build("now->", format(now, ";;q")))

   if (dsch_days > clean_days)               ;009
      set min_dsch_dt_tm  = datetimeadd(now, -(dsch_days))   ;009
   else
      set min_dsch_dt_tm  = datetimeadd(now, -(clean_days))   ;009
   endif
   call echo (build("min_dsch_dt_tm->", format(min_dsch_dt_tm, ";;q")))   ;009
	
   set max_dsch_dt_tm = cnvtdatetime(curdate,curtime3)      ;009
   if (dsch_hours > 0)
      set max_dsch_dt_tm  = datetimeadd(now,-(dsch_hours/24.0)) ;009
   endif
   call echo (build("max_dsch_dt_tm->", format(max_dsch_dt_tm, ";;q")))       ;009

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
      set reply->status_data->subeventstatus[1]->operationname = "dcp_ops_inp_dc_dords"
      set reply->status_data->subeventstatus[1]->operationstatus = "F"
      set reply->status_data->subeventstatus[1]->targetobjectname = "order status missing"
      go to exit_script
   endif
  
   if (cval->inpatient_cd = 0 )
      call echo("**** missing inpatient encntr type class on codeset 69 ****")
      set failed_ind=1
      set reply->status_data->subeventstatus[1]->operationname = "dcp_ops_inp_dc_dords"
      set reply->status_data->subeventstatus[1]->operationstatus = "F"
      set reply->status_data->subeventstatus[1]->targetobjectname = "inpatient (cs 69) missing"
      go to exit_script
   endif
   
   if (cval->discontinue_action_cd = 0 or cval->cancel_action_cd = 0)
      call echo("**** missing an order action code****")
      set failed_ind=1
      set reply->status_data->subeventstatus[1]->operationname = "dcp_ops_inp_dc_dords"
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
      plan  e 
      where e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm) ;009
      and   e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm) ;009
      and   e.encntr_type_class_cd + 0 = cval->inpatient_cd 
      join o 
      where o.encntr_id = e.encntr_id 
      and   o.order_status_cd+0 in (cval->ordered_status_cd,    cval->inprocess_status_cd,
                                     cval->medstudent_status_cd, cval->incomplete_status_cd, 
                                     cval->suspended_status_cd)
      and o.orig_ord_as_flag+0 in (0,5)              

      order by e.encntr_id
      head e.encntr_id
         hold->enc_cnt = hold->enc_cnt + 1
         if (hold->enc_cnt > size (hold->enc, 5))
            stat = alterlist(hold->enc, hold->enc_cnt+5)
         endif
         hold->enc[hold->enc_cnt].ord_cnt = 0
         hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      detail
         cancel_ind = 0
         /************************************************************************
         * If they are careset orsupergroup parents we don't want them to qualify*
         *  unless they are a template, prn or constant                          *
         ************************************************************************/
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
                               call echo ("build because of clean")                              
                            endif                                                                
                         endif                                                                   
                      endif                                                                      
                   else                                                                          
                      cancel_ind = 1
                   endif                                                                         
                endif
            endfor
         endif                              

         if (o.template_order_flag = 1 or o.prn_ind = 1 or o.constant_ind = 1 or o.freq_type_flag = 5)
				
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
               stat = alterlist(hold->enc[hold->enc_cnt].ord, oc+10)
            endif
            hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id
            hold->enc[hold->enc_cnt].ord[oc].catalog_cd = o.catalog_cd
            hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd
            hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt
            hold->enc[hold->enc_cnt].ord[oc].oe_format_id = o.oe_format_id
            if (o.current_start_dt_tm < cnvtdatetime (curdate, curtime3) and  
                o.order_status_cd != cval->medstudent_status_cd )   ;010
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

   if (dsch_cancel_flag = 2)
      select into "nl:"
         e.encntr_id,
         o.order_id,
         oc.catalog_cd
      from encounter e,
           orders o,
           order_catalog oc
      plan e 
      where e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm) ;009
      and   e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm) ;009
      and   e.encntr_type_class_cd + 0 = cval->inpatient_cd 
      join o
      where o.encntr_id = e.encntr_id 
      and   o.order_status_cd + 0 in (cval->ordered_status_cd,    cval->inprocess_status_cd,
                                      cval->medstudent_status_cd, cval->incomplete_status_cd, 
                                      cval->suspended_status_cd)
      and o.orig_ord_as_flag in (0,5)            

      join oc 
      where oc.catalog_cd = o.catalog_cd 

      order by e.encntr_id

      head e.encntr_id
         hold->enc_cnt = hold->enc_cnt + 1
         if (hold->enc_cnt > size (hold->enc, 5))
            stat = alterlist(hold->enc, hold->enc_cnt+5)
         endif
         hold->enc[hold->enc_cnt].ord_cnt = 0
         hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      detail
         cancel_ind = 0
         /************************************************************************
         * If they are careset/supergroup parents we don't want them to qualify  *
         *  unless they are a template, prn or constant                          *
         ************************************************************************/
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
                               call echo ("build because of clean")                              
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
            if (o.current_start_dt_tm < cnvtdatetime (curdate, curtime3) and  
                o.order_status_cd != cval->medstudent_status_cd )   ;010          
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
/***  FOR "TEMP" PREFERENCE                   ***/
/************************************************/

   if (dsch_cancel_flag = 3)
      select into "nl:"
         e.encntr_id,
         o.order_id
      from encounter e,
           orders o
      plan e 
      where e.disch_dt_tm > cnvtdatetime(min_dsch_dt_tm) ;009
      and   e.disch_dt_tm < cnvtdatetime(max_dsch_dt_tm) ;009 
      and   e.encntr_type_class_cd + 0 = cval->inpatient_cd 
      join o 
      where (o.encntr_id = e.encntr_id 
      and    o.order_status_cd+0 in (cval->ordered_status_cd,    cval->inprocess_status_cd,
                                     cval->medstudent_status_cd, cval->incomplete_status_cd, 
                                     cval->suspended_status_cd)
      and o.orig_ord_as_flag in (0,5)           
      and (o.template_order_flag = 1 
       or  o.prn_ind             = 1                                   
       or  o.constant_ind        = 1
       or  o.freq_type_flag      = 5))

      order by e.encntr_id

      head e.encntr_id
         hold->enc_cnt = hold->enc_cnt + 1
         if (hold->enc_cnt > size (hold->enc, 5))
            stat = alterlist(hold->enc, hold->enc_cnt+5)
         endif
         hold->enc[hold->enc_cnt].ord_cnt = 0
         hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
      detail
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
         if (o.current_start_dt_tm < cnvtdatetime (curdate, curtime3) and  
             o.order_status_cd != cval->medstudent_status_cd )   ;010         
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
      call message_line(" No encounter qualified! ")
   endif
   set filename = concat("CCLUSERDIR:AUDIT_OPS_ORDERS_",
   	trim(format(cnvtdatetime(curdate,curtime3),"yyyyMMddhhmmss;;q")),".json")
   
   call echoxml(hold,filename)
   ;Free internal structures
   free record hold 
   free record cval
   free record dstat


end go





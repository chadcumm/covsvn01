/************************************************************************
 *                                                                      *
 *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
 *                       Technology, Inc.                               *
 *      Revision     (c) 1984-2000 Cerner Corporation                   *
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
 ************************************************************************
 
        Date Written:      04/03/17
        Source file name:  pfmt_phsa_print_fut_ord_req.prg
        Object name:       pfmt_phsa_print_fut_ord_req
        Request #:
 
        Product:           Edge Team, US Consulting
        Product Team:
        HNA Version:       HNA Millennium
        CCL Version:       n/a
 
        Program purpose:   Executed from request 506201 inAppReg.exe
 
        Tables read:       n/a
        Tables updated:
        Executing from:
 
        Special Notes:     Custom script for client.
 
 *******************************************************************************************************
 *              GENERATED MODIFICATION CONTROL LOG                                                     *
 *******************************************************************************************************
 *                                                                                                     *
 *Mod      Date        Engineer               Comment                                                  *
 *-------  --------    ---------------------  ---------------------------------------------------------*
 * 000     10/01/2017  Chris Grobbel          Original development                                     *
 * 001     03/16/2018  Chris Grobbel          Allow printing of modified orders with printreqind = 0   *
 * 002     04/23/2018  Chris Grobbel          Back out mod 001                                         *
 * 003     06/21/2018  Chris Grobbel          For LGH ED print to ordering and scheduled location      *
 * 004     06/21/2018  Chris Grobbel          Look to REQUEST->ORDERLOCNCD for WTS Location            *
 * 005     07/31/2018  Chris Grobbel          For LGH ED do not print to ordering location             *
 * 006     11/01/2019  Jeremy Gunn            Included ambulatory procedure for future orders          *
 * 007     12/10/2019  Jeremy Gunn            Commented out remaining echoxml debugging statements     *
 * 008     09/21/2020  Barry Wong             Added ECHOJSON statements and change the print logic to  *
 *                                            subroutine (printRequisition).                           *
 *                                            Added logic to parse the DREC structure into individual  *
 *                                            TDBEXECUTE calls if the printers are not the same across *
 *                                            each printer level.                                      *
 *                                            Added permanent tracing statements                       *
 *******************************************************************************************************/
drop program pfmt_phsa_print_fut_ord_req:dba go
create program pfmt_phsa_print_fut_ord_req:dba
 
/************************************************************************
 *                     Echo out record structure                        *
 ************************************************************************/
;call echorecord(requestin)
;go to exit_script
 
;008 Start
/************************************************************************
 *                     Debug & trace setup                              *
 ************************************************************************/
declare log_file = vc with constant("pfmt_phsa_print_fut_ord2.log")
declare recd_trace = i2
declare debug_patient = f8 with constant(15462939.00)
 
;IMPORTANT: If recd_trace is set ON then the debug_patient variable must also be assigned
set recd_trace = 0
;008 End
 
/************************************************************************
 *                        Declare Variables                             *
 ************************************************************************/
declare cntr = i4 with public, noconstant(0)
declare idx = i4 with public, noconstant(0)
declare idx2 = i4 with public, noconstant(0)
declare num = i4 with public, noconstant(0)
declare num2 = i4 with public, noconstant(0)
declare printInd = i2 with public, noconstant(0)
declare sysdate_string = vc with public,constant(format(sysdate,"yyyymmddhhmmss;;d"))
declare file_name = vc with public,noconstant("")
 
declare scheduling_location_field_id = f8 with public,noconstant(0.00)
declare scheduling_location_field_non_radiology_id = f8 with public,noconstant(0.00)
 
declare general_lab_cd = f8 with public,constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
declare radiology_cd = f8 with public,constant(uar_get_code_by("MEANING",6000,"RADIOLOGY"))
;declare radiology_cd = f8 with public,constant(uar_get_code_by("MEANING",6000,"ORTHOPEDICS"))
declare respiratory_therapy_cd = f8 with public,constant(uar_get_code_by("MEANING",6000,"RESP THER"))
declare ambulatory_referrals_cd = f8 with public,constant(uar_get_code_by("MEANING",6000,"AMB REFERRAL"))
declare cardiology_cd = f8 with public,constant(uar_get_code_by("MEANING",6000,"CARDIOLOGY"))
declare amb_proc_cd = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,6000 ,"AMB PROC")) ;006
 
; Keep this one
declare transfusion_notification_req_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",6002,"LABORDTRANSFUSIONMED"))
 
; New as of 03/20/2018
declare lab_tm_ivig_notification_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",6002,"LABTMIVIGNOTIFICATION"))
;call echo(build("lab_tm_ivig_notification_cd = ",lab_tm_ivig_notification_cd))
 
;???
declare cond_transfusion_notification_req_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",6002,"LABREQCONDTRANSFUSION"))
;call echo(build("cond_transfusion_notification_req_cd = ",cond_transfusion_notification_req_cd))
 
; 001
declare modify_action_cd = f8 with public,constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 
declare future_cd = f8 with public,constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 
declare ord_loc_routing_cd = f8 with public,constant(uar_get_code_by("MEANING",6007,"ORDLOC"))
declare pat_fac_routing_cd = f8 with public,constant(uar_get_code_by("MEANING",6007,"PTFACIL"))
declare pat_loc_routing_cd = f8 with public,constant(uar_get_code_by("MEANING",6007,"PTLOC"))
 
declare print_to_paper_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",100301,"PRINTTOPAPER"))
declare paper_referral_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",100173,"PAPERREFERRAL"))
 
declare LGH_Med_Imaging_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",100301,"LGHMEDIMAGING")) ;003
declare LGH_ED_Ambulatory_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",220,"LGHED"))  ; 003
 
;008 Start
declare number_of_orders = i4
declare curr_printer = c50
declare ocntr = i4
declare plevel = i4
;008 End
 
/************************************************************************
 *                      Declare Subroutines                             *
 ************************************************************************/
declare processRequestinWithRequest(null) = null
declare processRequestinWithoutRequest(null) = null
;008 Start
declare printRequisition(null) = null
declare parseDREC(null) = i2
declare sWrite_Trace_Line(debug_msg = vc, debug_filename = vc) = null
;008 End
 
/************************************************************************
 *                         Define Records                               *
 ************************************************************************/
free record request560601
record request560601 (
  1 personId = f8
  1 consFormInd = i2
  1 reqInd = i2
  1 osInd = i2
  1 orderList [*]
    2 encntrId = f8
    2 orderId = f8
    2 consFormInd = i2
    2 consFormPrinterName = vc
    2 reqInd = i2
    2 reqPrinterName = vc
    2 osInd = i2
    2 osPrinterName = vc
)
 
free record reply560601
record reply560601 (
  1 status_data
    2 status = c1
    2 subeventstatus[1]
      3 OperationName = c25
      3 OperationStatus = c1
      3 TargetObjectName = c25
      3 TargetObjectValue = vc
)
 
free record drec
record drec(
  1 qual[*]
    2 order_id = f8
    2 person_id = f8
    2 ordering_location = f8
    2 scheduling_location = f8
    2 originating_encounter_id = f8
    2 requisition_routing_cd = f8
    2 print_ind = i2
    2 printers[*]
      3 printer_name = vc
)
 
;set file_name = ""
;set file_name = concat("requestin_560201_",sysdate_string,".dat")
;call echo(file_name)
;call echoxml(requestin,value(file_name))
 
;; NOTE:  04/04/2018
;;For ambulatory referrals (catalogtypecd = ambulatory_referrals_cd only print future orders when Paper Referal is selected
 
/************************************************************************************
 *                   Get the Scheduling Location Field Id                           *
 ************************************************************************************/
select into "nl:"
  from order_entry_fields o
plan o
where o.description = "Scheduling Location"
  and o.codeset = 100301
 
head report
  scheduling_location_field_id = o.oe_field_id
with nocounter
 
;call echo(build("scheduling_location_field_id = ",scheduling_location_field_id ))
 
; Non-Radiology
select into "nl:"
  from order_entry_fields o
plan o
where o.description = "Scheduling Locations - Non Radiology"
  and o.codeset = 100173
 
head report
  scheduling_location_field_non_radiology_id = o.oe_field_id
with nocounter
 
;call echo(build("scheduling_location_field_non_radiology_id = ",scheduling_location_field_non_radiology_id ))
 
/************************************************************************************
 *  Call the appropriate subroutine for requestin processing:                       *
 *  - If the order is processed by the async order server, request 560200 is used.  *
 *    The requestin for 560200 does not have the request sub-level.                 *
 *  - If the order is processed by the sync order server, request 560201 is used.   *
 *    The requestin for 560201 does have the request sub-level.                     *
 ************************************************************************************/
; Check to see whether we got requestin-request or just requestin
if (not validate(requestin->request,0))
  ; Order was processed by async order server and request 560200.  Therefore we got requestin as requestin.
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call sWrite_Trace_Line("REQUESTIN w/o REQUEST...", log_file)
    call ECHOJSON(requestin, "CG_RqstIn_wo_Request", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  call processRequestinWithoutRequest(null)
else
  ; Order was processed by sync order server and request 560201.  Therefore we got requestin as requestin->request.
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call sWrite_Trace_Line("REQUESTIN w/ REQUEST...", log_file)
    call ECHOJSON(requestin, "CG_RqstIn_w_Request", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  call processRequestinWithRequest(null)
endif
 
;>>>>>>>>>> Start trace
if (recd_trace = 1 and requestin->personid = debug_patient )
  call ECHOJSON(drec, "CG_DREC_Dump1", 1 )
endif
;<<<<<<<<<< End trace
 
; If no records qualify, exit the script
if (size(drec->qual,5) = 0)
;  call echorecord(drec)
  go to exit_script
endif
 
; The scheduling location is a code set 100301 or 100173 value.
; Get the actual code set 220 value from code_value_group
select into "nl:"
 from (dummyt d with seq=size(drec->qual,5)),
       code_value cv,
       code_value_group cvg
plan d
where drec->qual[d.seq].scheduling_location != 0.00
 
join cv
where cv.code_value = drec->qual[d.seq].scheduling_location
 
join cvg
where cvg.parent_code_value = cv.code_value
  and cvg.code_set = 220
 
detail
  drec->qual[d.seq].ordering_location = cvg.child_code_value
with nocounter
 
/************************************************************************************
 *                        Get the Printer from the routing code                     *
 ************************************************************************************/
select into "nl:"
       loc = uar_get_code_display(dfr.value1_cd),
       dfp.printer_name,
       dfr.*
  from (dummyt d with seq=size(drec->qual,5)),
        dcp_flex_rtg dfr,
	      dcp_flex_printer dfp
 
plan d
 
join dfr
where dfr.dcp_output_route_id = drec->qual[d.seq].requisition_routing_cd
  and dfr.value1_cd = drec->qual[d.seq].ordering_location
 
join dfp
where dfr.dcp_flex_rtg_id = dfp.dcp_flex_rtg_id
  and dfp.printer_name > " "
 
order by d.seq, dfp.printer_name
 
head report
  printInd = 1 ; there is at least one order to print
  cntr = 0
head d.seq
  cntr = 0
detail
  cntr = cntr+1
  stat = alterlist(drec->qual[d.seq]->printers,cntr)
  drec->qual[d.seq]->printers[cntr].printer_name = dfp.printer_name
  drec->qual[d.seq].print_ind = 1 ; print this order
;  call echo(build("dfp.printer_name = ",dfp.printer_name))
with nocounter
 
;>>>>>>>>>> Start trace
if (recd_trace = 1 and requestin->personid = debug_patient )
  call ECHOJSON(drec, "CG_DREC_Dump2", 1 )
endif
;<<<<<<<<<< End trace
 
;call echorecord(drec)
;go to exit_script
 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;008 Start
;------------------------------------------------
; Print the requisition(s)
;------------------------------------------------
if (printInd = 1 )
  ; Does orders have different number of printers OR are the printer names different at the same level?
  if (parseDREC(null) = 1 )
    ; Save DREC information into work record
    set stat = copyrec(drec, temprec, 1 )
    set number_of_orders = size(drec->qual, 5 )
 
    ;>>>>>>>>>> Start trace
    if (recd_trace = 1 and requestin->personid = debug_patient )
      call ECHOJSON(temprec, "CG_TEMPREC_Dump", 1 )
      call sWrite_Trace_Line(concat("Number of Orders: ", cnvtstring(number_of_orders ) ), log_file)
      call sWrite_Trace_Line("Entered printer parsing logic...", log_file)
    endif
    ;<<<<<<<<<< End trace
 
    ;----------------------------------------------------------------------------------
    ; Process orders for each printer level; grouping by distinct printer name
    ;----------------------------------------------------------------------------------
    for (plevel = 1 to 3 )
 
      ;>>>>>>>>>> Start trace
      if (recd_trace = 1 and requestin->personid = debug_patient )
        call sWrite_Trace_Line(concat("plevel: ", cnvtstring(plevel ) ), log_file)
      endif
      ;<<<<<<<<<< End trace
 
      for (i = 1 to number_of_orders )
 
        ;>>>>>>>>>> Start trace
        if (recd_trace = 1 and requestin->personid = debug_patient )
          call sWrite_Trace_Line(concat("  I: ", cnvtstring(i ) ), log_file)
          call sWrite_Trace_Line(concat("    # of printers: ", cnvtstring(size(temprec->qual[i].printers, 5 ) ) ), log_file)
        endif
        ;<<<<<<<<<< End trace
 
        ; Does order have a printer at this level?
        if (size(temprec->qual[i].printers, 5 ) >= plevel )
          ; Unprocessed order found?
          if (temprec->qual[i].printers[plevel].printer_name not = "Done" )
 
            set ocntr = 0
            set curr_printer = temprec->qual[i].printers[plevel].printer_name
 
            ;>>>>>>>>>> Start trace
            if (recd_trace = 1 and requestin->personid = debug_patient )
              call sWrite_Trace_Line(concat("      Current printer: ", curr_printer), log_file)
            endif
            ;<<<<<<<<<< End trace
 
            ; Recreate new drec
            free record drec
            set stat = copyrec(temprec, drec, 0 )
 
            ;>>>>>>>>>> Start trace
            if (recd_trace = 1 and requestin->personid = debug_patient )
              call sWrite_Trace_Line("      Create new DREC ", log_file)
              call sWrite_Trace_Line("      Loop through J ", log_file)
            endif
            ;<<<<<<<<<< End trace
 
            ; Check all remaining orders for the same printer and level
            ; If found then insert into new drec
            for (j = i to number_of_orders )
 
              ;>>>>>>>>>> Start trace
              if (recd_trace = 1 and requestin->personid = debug_patient )
                call sWrite_Trace_Line(concat("      J: ", cnvtstring(j ) ), log_file)
                call sWrite_Trace_Line(concat("        # of printers: ", cnvtstring(size(temprec->qual[j].printers, 5 ) ) ), log_file)
              endif
              ;<<<<<<<<<< End trace
 
              ; Does order have a printer at this level?
              if (size(temprec->qual[j].printers, 5 ) >= plevel )
 
                ;>>>>>>>>>> Start trace
                if (recd_trace = 1 and requestin->personid = debug_patient )
                  call sWrite_Trace_Line(concat("          Printer: ", temprec->qual[j].printers[plevel].printer_name ), log_file)
                endif
                ;<<<<<<<<<< End trace
 
                ; Is the printer the same as the one that is being searched for?
                if (temprec->qual[j].printers[plevel].printer_name = curr_printer )
                  ; Save order information
                  set ocntr = ocntr+1
                  set stat = alterlist(drec->qual, ocntr )
                  set drec->qual[ocntr].order_id = temprec->qual[j].order_id
                  set drec->qual[ocntr].person_id = temprec->qual[j].person_id
                  set drec->qual[ocntr].ordering_location = temprec->qual[j].ordering_location
                  set drec->qual[ocntr].scheduling_location = temprec->qual[j].scheduling_location
                  set drec->qual[ocntr].originating_encounter_id = temprec->qual[j].originating_encounter_id
                  set drec->qual[ocntr].requisition_routing_cd = temprec->qual[j].requisition_routing_cd
                  set drec->qual[ocntr].print_ind = temprec->qual[j].print_ind
                  set stat = alterlist(drec->qual[ocntr].printers, 1 )
                  set drec->qual[ocntr].printers[1].printer_name = curr_printer
 
                  ;>>>>>>>>>> Start trace
                  if (recd_trace = 1 and requestin->personid = debug_patient )
                    call sWrite_Trace_Line("          Insert order into DREC...", log_file)
                  endif
                  ;<<<<<<<<<< End trace
 
                  ; Set printer in temprec to blanks to indicated that the order has been processed for the current level
                  set temprec->qual[j].printers[plevel].printer_name = "Done"
 
                  ;>>>>>>>>>> Start trace
                  if (recd_trace = 1 and requestin->personid = debug_patient )
                    call sWrite_Trace_Line(concat("          Printer: ", temprec->qual[j].printers[plevel].printer_name ), log_file)
                  endif
                  ;<<<<<<<<<< End trace
 
                endif
              endif
            endfor
 
            ;>>>>>>>>>> Start trace
            if (recd_trace = 1 and requestin->personid = debug_patient )
              call ECHOJSON(drec, "CG_NEWDREC_Dump", 1 )
              call sWrite_Trace_Line("*** Execute printRequisition subroutine... ", log_file)
              call sWrite_Trace_Line("                                           ", log_file)
            endif
            ;<<<<<<<<<< End trace
 
            ; Process drec with the printRequisition subroutine
            call printRequisition(null)
          endif
        endif
      endfor
    endfor
  else
 
    ;>>>>>>>>>> Start trace
    if (recd_trace = 1 and requestin->personid = debug_patient )
      call sWrite_Trace_Line("Entered original printer logic...", log_file)
      call sWrite_Trace_Line("*** Execute printRequisition subroutine... ", log_file)
      call sWrite_Trace_Line("                                           ", log_file)
      call ECHOJSON(drec, "CG_ORIGDREC_Dump", 1 )
    endif
    ;<<<<<<<<<< End trace
 
    call printRequisition(null)
  endif
endif
;008 End
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
;==============================================================================
; Subroutines
;==============================================================================
subroutine processRequestinWithRequest(null)
  /************************************************************************************
   *   Get the Lab and Rad Future Orders that are configured to print a requisition   *
   ************************************************************************************/
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpA", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  select into "nl:"
         orderId = requestin->request.orderlist[d.seq].orderid
    from (dummyt d with seq=size(requestin->request->orderlist,5)),
          orders o,
          encounter e,   ; 001
          order_catalog oc,
          dcp_output_route dor
  plan d
  where requestin->request->orderlist[d.seq].catalogtypecd in (general_lab_cd,
                                                               radiology_cd,
                                                               cardiology_cd,
                                                               ambulatory_referrals_cd,
                                                               amb_proc_cd) ;006
 
;006            in (general_lab_cd,radiology_cd,cardiology_cd,ambulatory_referrals_cd) ; Rad Lab
    and requestin->request->orderlist[d.seq].orderstatuscd = future_cd ; Future
;    and requestin->request.orderlist[d.seq].actiontypecd in (2534.00,2533.00,2524.00) ; Order, Modify, Activate
    and (requestin->request->orderlist[d.seq].printreqind = 1)
            /*  002 - Backout the  feature to print on Modify/Reschedule
              or (requestin->request->orderlist[d.seq].printreqind = 0
                  and requestin->request.orderlist[d.seq].actiontypecd = modify_action_cd))  ; 001
            */
    and requestin->request->orderlist[d.seq].requisitionformatcd not in (transfusion_notification_req_cd,
                                                                         lab_tm_ivig_notification_cd)
  join o
  where o.order_id = requestin->request->orderlist[d.seq].orderid
 
  join e                                       ; 001
  where e.encntr_id = o.originating_encntr_id  ; 001
 
  join oc
  where oc.catalog_cd = o.catalog_cd
 
  join dor
  where dor.dcp_output_route_id = oc.requisition_routing_cd
 
  order by orderId
 
  head report
    cntr = 0
  head orderId
    cntr = cntr+1
    stat = alterlist(drec->qual,cntr)
    drec->qual[cntr].order_id = requestin->request->orderlist[d.seq].orderid
    drec->qual[cntr].originating_encounter_id = o.originating_encntr_id
    if (requestin->request->orderlist[d.seq].requisitionroutingcd > 0.00)     ;001
      drec->qual[cntr].requisition_routing_cd = requestin->request->orderlist[d.seq].requisitionroutingcd
    else                                                                      ;001
      drec->qual[cntr].requisition_routing_cd = oc.requisition_routing_cd     ;001
    endif                                                                     ;001
    drec->qual[cntr].person_id = requestin->request->personid
    drec->qual[cntr].print_ind = 0
    if (dor.param1_cd = ord_loc_routing_cd); Order Location
      idx = 0
      idx = locateval(num,
                      1,
                      size(requestin->request->orderlist[d.seq]->detaillist,5),
                      "ORDERLOC",
                      requestin->request->orderlist[d.seq]->detaillist[num].oefieldmeaning
                     )
      if (idx > 0)
        drec->qual[cntr].ordering_location = requestin->request.orderlist[d.seq]->detaillist[idx].oefieldvalue
      else
        drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd    ; 001
      endif
      ;004 - If there is a WTS Location, use it
      if (requestin->request->orderlocncd > 0.00)
        drec->qual[cntr].ordering_location = requestin->request->orderlocncd
      endif
    endif
 
    if (dor.param1_cd = pat_loc_routing_cd); Patient Location
      drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd        ; 001
    endif
 
    if (dor.param1_cd = pat_fac_routing_cd); Patient Facility
      drec->qual[cntr].ordering_location = e.loc_facility_cd          ; 001
    endif
 
  with nocounter
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpB", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  ; If no records qualify, exit the subroutine
  if (size(drec->qual,5) = 0)
    return
  endif
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpC", 1 )
  endif
   ;<<<<<<<<<< End trace
 
  /***********************************************************************************************
   *   Check the Scheduling Location Field to see whether to supercede the ORDERLOC - Radiology  *
   ***********************************************************************************************/
  ; First, check to see if a value other than "Print to Paper" was selected at the Scheduling Location field
  select into "nl:"
         order_id = drec->qual[d.seq].order_id
    from (dummyt d with seq=size(drec->qual,5))
  plan d
 
  detail
    idx = locateval(num,1,size(requestin->request->orderlist,5),order_id,requestin->request->orderlist[num].orderid)
;    call echo(build("idx = ",idx))
    if (idx > 0)
      idx2 = locateval(num2,
                       1,
                       size(requestin->request->orderlist[idx]->detaillist,5),
                       scheduling_location_field_id,
                       requestin->request.orderlist[idx]->detaillist[num2].oefieldid )
      if (idx2 > 0)
;        call echo(build("idx2 = ",idx2))
        if (requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue not in (0.00,
                                                                                     print_to_paper_cd,
                                                                                     paper_referral_cd ))
          drec->qual[d.seq].scheduling_location = requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue
 
               ; 003 - 6/21/2018 - If the ordering location is LGH ED and the Scheduled location is LGH Med Imaging
               ; send a print request for both.
               ; 005 - 07/31/2018 - Remove this per LGH ED request
               ;if(drec->qual[d.seq].ordering_location =  LGH_ED_Ambulatory_cd ; LGH ED
               ;      and drec->qual[d.seq].scheduling_location = LGH_Med_Imaging_cd); 100301 ; LGH Med Imaging
                  ; Add another item to drec for the ordering location
               ;   cntr = size(drec->qual,5)
               ;   cntr = cntr+1
               ;   stat = alterlist(drec->qual,cntr)
               ;   drec->qual[cntr].order_id = drec->qual[d.seq].order_id
               ;   drec->qual[cntr].person_id = drec->qual[d.seq].person_id
               ;   drec->qual[cntr].ordering_location = drec->qual[d.seq].ordering_location
               ;   drec->qual[cntr].originating_encounter_id = drec->qual[d.seq].originating_encounter_id
               ;   drec->qual[cntr].requisition_routing_cd = drec->qual[d.seq].requisition_routing_cd
               ;endif
        endif
      endif
    endif
  with nocounter
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpD", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  /***************************************************************************************************
   *   Check the Scheduling Location Field to see whether to supercede the ORDERLOC - Non Radiology  *
   ***************************************************************************************************/
  ; First, check to see if a value other than "Print to Paper" was selected at the Scheduling Location field
  select into "nl:"
         order_id = drec->qual[d.seq].order_id
    from (dummyt d with seq=size(drec->qual,5))
  plan d
 
  detail
    idx = locateval(num,1,size(requestin->request->orderlist,5),order_id,requestin->request->orderlist[num].orderid)
;    call echo(build("idx = ",idx))
    if (idx > 0)
      idx2 = locateval(num2,
                       1,
                       size(requestin->request->orderlist[idx]->detaillist,5),
                       scheduling_location_field_non_radiology_id,
                       requestin->request.orderlist[idx]->detaillist[num2].oefieldid )
      if (idx2 > 0)
;        call echo(build("idx2 = ",idx2))
        if (requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue not in (0.00,
                                                                                     print_to_paper_cd,
                                                                                     paper_referral_cd ))
          drec->qual[d.seq].scheduling_location = requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue
        endif
      endif
    endif
  with nocounter
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpE", 1 )
  endif
  ;<<<<<<<<<< End trace
 
end ; processRequestinWithRequest(null)
 
;---------------------------------------------------------------------------------------------------------------------------
subroutine processRequestinWithoutRequest(null)
  /************************************************************************************
   *   Get the Lab and Rad Future Orders that are configured to print a requisition   *
   ************************************************************************************/
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpA", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  select into "nl:"
         orderId = requestin->orderlist[d.seq].orderid
    from (dummyt d with seq=size(requestin->orderlist,5)),
           orders o,
           encounter e,   ; 001
           order_catalog oc,
           dcp_output_route dor
  plan d
  where requestin->orderlist[d.seq].catalogtypecd in (general_lab_cd,
                                                      radiology_cd,
                                                      cardiology_cd,
                                                      ambulatory_referrals_cd,
                                                      amb_proc_cd) ; 006
 
;006            in (general_lab_cd,radiology_cd,cardiology_cd,ambulatory_referrals_cd) ; Rad Lab
    and requestin->orderlist[d.seq].orderstatuscd = future_cd ; Future
    and (requestin->orderlist[d.seq].printreqind = 1)
         /* 002 - Backout the  feature to print on Modify/Reschedule
              or (requestin->orderlist[d.seq].printreqind = 0
                  and requestin->orderlist[d.seq].actiontypecd = modify_action_cd))  ; 001
         */
    and requestin->orderlist[d.seq].requisitionformatcd not in (transfusion_notification_req_cd,
                                                                lab_tm_ivig_notification_cd)
 
  join o
  where o.order_id = requestin->orderlist[d.seq].orderid
 
  join e                                       ; 001
  where e.encntr_id = o.originating_encntr_id  ; 001
 
  join oc
  where oc.catalog_cd = o.catalog_cd
 
  join dor
  where dor.dcp_output_route_id = oc.requisition_routing_cd
 
  order by orderId
 
  head report
    cntr = 0
  head orderId
    cntr = cntr+1
    stat = alterlist(drec->qual,cntr)
    drec->qual[cntr].order_id = requestin->orderlist[d.seq].orderid
    drec->qual[cntr].originating_encounter_id = o.originating_encntr_id
 
    if (requestin->orderlist[d.seq].requisitionroutingcd > 0.00)              ;001
      drec->qual[cntr].requisition_routing_cd = requestin->orderlist[d.seq].requisitionroutingcd
    else                                                                      ;001
      drec->qual[cntr].requisition_routing_cd = oc.requisition_routing_cd     ;001
    endif                                                                     ;001
 
    drec->qual[cntr].person_id = requestin->personid
    drec->qual[cntr].print_ind = 0
 
    ; Order location route
    if (dor.param1_cd = ord_loc_routing_cd)
      idx = 0
      idx = locateval(num,
                      1,
                      size(requestin->orderlist[d.seq]->detaillist,5),
                      "ORDERLOC",
                      requestin->orderlist[d.seq]->detaillist[num].oefieldmeaning
                     )
      if (idx > 0)
        drec->qual[cntr].ordering_location = requestin->orderlist[d.seq]->detaillist[idx].oefieldvalue
      else
        ; If the routing is by Order Location but there is no ORDERLOC order detail, use nurseunitcd
        drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd ;001
      endif
      ;004 - If there is a WTS Location, use it
      if (requestin->orderlocncd > 0.00)
        drec->qual[cntr].ordering_location = requestin->orderlocncd
      endif
    endif
 
    ; Patient location route
    if (dor.param1_cd = pat_loc_routing_cd)
      drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd ;001
    endif
 
    ; Patient Facilty route
    if (dor.param1_cd = pat_fac_routing_cd)
      drec->qual[cntr].ordering_location = e.loc_facility_cd ;001
    endif
  with nocounter
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpB", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  ; If no records qualify, exit the subroutine
  if(size(drec->qual,5) = 0)
     return
  endif
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpC", 1 )
  endif
   ;<<<<<<<<<< End trace
 
  /***********************************************************************************************
   *   Check the Scheduling Location Field to see whether to supercede the ORDERLOC - Radiology  *
   ***********************************************************************************************/
  ; First, check to see if a value other than "Print to Paper" was selected at the Scheduling Location field
  select into "nl:"
        order_id = drec->qual[d.seq].order_id
    from (dummyt d with seq=size(drec->qual,5))
  plan d
 
  detail
    idx = locateval(num,1,size(requestin->orderlist,5),order_id,requestin->orderlist[num].orderid)
;    call echo(build("idx = ",idx))
    if (idx > 0)
      idx2 = locateval(num2,
                       1,
                       size(requestin->orderlist[idx]->detaillist,5),
                       scheduling_location_field_id,
                       requestin->orderlist[idx]->detaillist[num2].oefieldid )
      if (idx2 > 0)
;        call echo(build("idx2 = ",idx2))
        if (requestin->orderlist[idx]->detaillist[idx2].oefieldvalue not in (0.00,
                                                                             print_to_paper_cd,
                                                                             paper_referral_cd ))
          drec->qual[d.seq].scheduling_location = requestin->orderlist[idx]->detaillist[idx2].oefieldvalue
 
               ; 003 - 6/21/2018 - If the ordering location is LGH ED and the Schduled location is LGH Med Imaging
               ; send a print request for both.
               ; 005 - 07/31/2018 - Remove this per LGH ED request
               ;if(drec->qual[d.seq].ordering_location =  LGH_ED_Ambulatory_cd ; LGH ED
               ;      and drec->qual[d.seq].scheduling_location = LGH_Med_Imaging_cd); 100301 ; LGH Med Imaging
                  ; Add another item to drec for the ordering location
               ;   cntr = size(drec->qual,5)
               ;   cntr = cntr+1
               ;   stat = alterlist(drec->qual,cntr)
               ;   drec->qual[cntr].order_id = drec->qual[d.seq].order_id
               ;   drec->qual[cntr].person_id = drec->qual[d.seq].person_id
               ;   drec->qual[cntr].ordering_location = drec->qual[d.seq].ordering_location
               ;   drec->qual[cntr].originating_encounter_id = drec->qual[d.seq].originating_encounter_id
               ;   drec->qual[cntr].requisition_routing_cd = drec->qual[d.seq].requisition_routing_cd
               ;endif
        endif
      endif
    endif
  with nocounter
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpD", 1 )
  endif
  ;<<<<<<<<<< End trace
 
  /***************************************************************************************************
   *   Check the Scheduling Location Field to see whether to supercede the ORDERLOC - Non Radiology  *
   ***************************************************************************************************/
  ; First, check to see if a value other than "Print to Paper" was selected at the Scheduling Location field
  select into "nl:"
         order_id = drec->qual[d.seq].order_id
    from (dummyt d with seq=size(drec->qual,5))
  plan d
 
  detail
    idx = locateval(num,1,size(requestin->orderlist,5),order_id,requestin->orderlist[num].orderid)
;    call echo(build("idx = ",idx))
    if (idx > 0)
      idx2 = locateval(num2,
                       1,
                       size(requestin->orderlist[idx]->detaillist,5),
                       scheduling_location_field_non_radiology_id,
                       requestin->orderlist[idx]->detaillist[num2].oefieldid )
      if (idx2 > 0)
;        call echo(build("idx2 = ",idx2))
        if (requestin->orderlist[idx]->detaillist[idx2].oefieldvalue not in(0.00,
                                                                            print_to_paper_cd,
                                                                            paper_referral_cd ))
          drec->qual[d.seq].scheduling_location = requestin->orderlist[idx]->detaillist[idx2].oefieldvalue
        endif
      endif
    endif
  with nocounter
 
  ;>>>>>>>>>> Start trace
  if (recd_trace = 1 and requestin->personid = debug_patient )
    call ECHOJSON(drec, "CG_DREC_DumpE", 1 )
  endif
  ;<<<<<<<<<< End trace
 
end ; processRequestinWithoutRequest(null)
 
;008 Start
;---------------------------------------------------------------------------------------------------------------------------
subroutine printRequisition(null)
  declare printIndicator = i2 with noconstant(1)  ;008 Will initially = 1 when the subroutine is called
  declare idx2a = i4
 
;  set file_name = ""
;  set file_name = concat("drec_pfmt_",sysdate_string,".dat")
;  call echo(file_name)
;  call echoxml(drec,value(file_name))
  ;-----------------------------------
  ; Send request to Printer #1
  ;-----------------------------------
  set cntr = 0
  set stat = initrec(request560601)
  set request560601->personId = drec->qual[1].person_id
  set request560601->reqInd = 1
 
  for (idx2a = 1 to size(drec->qual,5))
    if (drec->qual[idx2a].print_ind = 1)
      set cntr = cntr+1
      set stat = alterlist(request560601->orderList,cntr)
      set request560601->orderList[cntr].encntrId = drec->qual[idx2a].originating_encounter_id
      set request560601->orderList[cntr].orderId = drec->qual[idx2a].order_id
      set request560601->orderList[cntr].reqInd = 1
      set request560601->orderList[cntr].reqPrinterName = drec->qual[idx2a]->printers[1].printer_name
    endif
  endfor
 
  if (printIndicator = 1) ; there is at least one order to print
;    set file_name = ""
;    set file_name = concat("request560601_",sysdate_string,"_printer1.dat")
;    call echo(file_name)
;    call echorecord(request560601)
;    call echoxml(request560601,value(file_name))
 
    ;>>>>>>>>>> Start trace
    if (recd_trace = 1 and requestin->personid = debug_patient )
      call ECHOJSON(request560601, "CG_R560601_Printer1", 1 )
    endif
    ;<<<<<<<<<< End trace
 
    ; Make the server call using TDBEXECUTE
    ;   Application=600005  :  Power Chart
    ;   Task=500196         :  UPDATE PowerChart Orders
    ;   Request=560601      :  DCP.OutputReprint
    if (size(request560601->orderList,5) > 0)
      set stat = tdbexecute(600005,500196,560601,"REC",request560601,"REC",reply560601)
    endif
 
;    set file_name = ""
;    set file_name = concat("reply560601_",sysdate_string,"_printer1.dat")
;    call echo(file_name)
;    call echoxml(reply560601,value(file_name))
  endif
 
  ;-----------------------------------
  ; Send request to Printer #2
  ;-----------------------------------
  set printIndicator = 0 ; set back to not print, assume there is no second printer
  set cntr = 0
  set stat = initrec(request560601)
  set request560601->personId = drec->qual[1].person_id
  set request560601->reqInd = 1
 
  for (idx2a = 1 to size(drec->qual,5))
    if (drec->qual[idx2a].print_ind = 1)
      if (size(drec->qual[idx2a]->printers,5) > 1)
        set cntr = cntr+1
        set stat = alterlist(request560601->orderList,cntr)
        set request560601->orderList[cntr].encntrId = drec->qual[idx2a].originating_encounter_id
        set request560601->orderList[cntr].orderId = drec->qual[idx2a].order_id
        set request560601->orderList[cntr].reqInd = 1
        set request560601->orderList[cntr].reqPrinterName = drec->qual[idx2a]->printers[2].printer_name
        set printIndicator = 1 ; there is at least one order to print to a second printer
      endif
    endif
  endfor
 
  if (printIndicator = 1) ; there is at least one order to print to a second printer
;    set file_name = ""
;    set file_name = concat("request560601_",sysdate_string,"_printer2.dat")
;    call echo(file_name)
;    call echorecord(request560601)
;    call echoxml(request560601,value(file_name))
 
    ;>>>>>>>>>> Start trace
    if (recd_trace = 1 and requestin->personid = debug_patient )
      call ECHOJSON(request560601, "CG_R560601_Printer2", 1 )
    endif
    ;<<<<<<<<<< End trace
 
    ; Make the server call using TDBEXECUTE
    ;   Application=600005  :  Power Chart
    ;   Task=500196         :  UPDATE PowerChart Orders
    ;   Request=560601      :  DCP.OutputReprint
    if (size(request560601->orderList,5) > 0)
      set stat = tdbexecute(600005,500196,560601,"REC",request560601,"REC",reply560601)
    endif
 
;    set file_name = ""
;    set file_name = concat("reply560601_",sysdate_string,"_printer2.dat")
;    call echo(file_name)
;    call echoxml(reply560601,value(file_name))
  endif
 
  ;-----------------------------------
  ; Send request to Printer #3
  ;-----------------------------------
  set printIndicator = 0 ; set back to not print, assume there is no third printer
  set cntr = 0
  set stat = initrec(request560601)
  set request560601->personId = drec->qual[1].person_id
  set request560601->reqInd = 1
 
  for (idx2a = 1 to size(drec->qual,5))
    if (drec->qual[idx2a].print_ind = 1)
      if (size(drec->qual[idx2a]->printers,5) > 2)
        set cntr = cntr+1
        set stat = alterlist(request560601->orderList,cntr)
        set request560601->orderList[cntr].encntrId = drec->qual[idx2a].originating_encounter_id
        set request560601->orderList[cntr].orderId = drec->qual[idx2a].order_id
        set request560601->orderList[cntr].reqInd = 1
        set request560601->orderList[cntr].reqPrinterName = drec->qual[idx2a]->printers[3].printer_name
        set printIndicator = 1 ; there is at least one order to print to a third printer
      endif
    endif
  endfor
 
  if (printIndicator = 1) ; there is at least one order to print to a third printer
;    set file_name = ""
;    set file_name = concat("request560601_",sysdate_string,"_printer3.dat")
;    call echo(file_name)
;    call echorecord(request560601)
;    call echoxml(request560601,value(file_name))
 
    ;>>>>>>>>>> Start trace
    if (recd_trace = 1 and requestin->personid = debug_patient )
      call ECHOJSON(request560601, "CG_R560601_Printer3", 1 )
    endif
    ;<<<<<<<<<< End trace
 
    ; Make the server call using TDBEXECUTE
    ;   Application=600005  :  Power Chart
    ;   Task=500196         :  UPDATE PowerChart Orders
    ;   Request=560601      :  DCP.OutputReprint
    if (size(request560601->orderList,5) > 0)
      set stat = tdbexecute(600005,500196,560601,"REC",request560601,"REC",reply560601)
    endif
 
;    set file_name = ""
;    set file_name = concat("reply560601_",sysdate_string,"_printer3.dat")
;    call echo(file_name)
;    call echoxml(reply560601,value(file_name))
  endif
end ; printRequisition(null)
 
;---------------------------------------------------------------------------------------------------------------------------
subroutine parseDREC(null)
  declare parse_ind = i2
  declare order_count = i4
  declare current_printer = c50
  declare print_level = i4
  declare idx1a = i4
  declare idx1b = i4
  declare idx1c = i4
 
  set parse_ind = 0
  set order_count = size(drec->qual, 5 )
  set print_level = size(drec->qual[1].printers, 5 )
 
  ; Check if all orders have the same number of printers
  for (idx1a = 1 to order_count )
    if (size(drec->qual[idx1a].printers, 5 ) not = print_level )
      set parse_ind = 1
    endif
  endfor
 
  ; Check if each printer is the same on each level
  if (parse_ind = 0 )
    for (idx1b = 1 to print_level )
      set current_printer = drec->qual[1].printers[idx1b].printer_name
      for (idx1c = 1 to order_count)
        if (drec->qual[idx1c].printers[idx1b].printer_name not = current_printer )
          set parse_ind = 1
        endif
      endfor
    endfor
  endif
 
  return(parse_ind)
end ; parseDREC(null)
 
;---------------------------------------------------------------------------------------------------------------------------
subroutine sWrite_Trace_Line(debug_msg, debug_filename)
  select into concat("ccluserdir/",debug_filename)
    from dummyt   d
  detail
    print_msg = concat(debug_msg," > ",format(cnvtdatetime(curdate, curtime), "DD-MMM-YYYY HH:MM;;Q"))
    col 2, print_msg
  with nocounter, noheading, noformat, append
end
;---------------------------------------------------------------------------------------------------------------------------
;008 End
 
#exit_script
 
end
go

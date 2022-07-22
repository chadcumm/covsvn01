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
 * 008     09/21/2020  Barry Wong             Added temporary ECHOJSON statements                      *
 * 009     09/23/2020  Jeremy Gunn            Added ECHOJSON statement for requestin temporarily       *
 *******************************************************************************************************/
drop program pfmt_phsa_print_fut_ord_req:dba go
create program pfmt_phsa_print_fut_ord_req:dba
 
/************************************************************************
 *                     Echo out record structure                        *
 ************************************************************************/
;call echorecord(requestin)
;go to exit_script
 
DECLARE vDEBUG = I2 ;009
SET vDEBUG = 0 ;009
 
 
IF ((FINDFILE("PFMT_LOG.LOG") = 1) AND (requestin->request->personid = 14236940)) ;009
  IF (requestin->request->orderlist[1].printreqind = 0)
    SET vDEBUG = 1
    EXECUTE BC_ALL_ALL_STD_ROUTINES
    CALL sWRITE_MESSAGE_NOFLAG("Debugging Start ...","PFMT_LOG.LOG")
    call ECHOJSON(requestin, "PFMT_LOG.LOG", 1 )
  ENDIF
ENDIF
 
 
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
call echo(build("lab_tm_ivig_notification_cd = ",lab_tm_ivig_notification_cd))
 
;???
declare cond_transfusion_notification_req_cd = f8 with public,constant(uar_get_code_by("DISPLAY_KEY",6002,"LABREQCONDTRANSFUSION"))
call echo(build("cond_transfusion_notification_req_cd = ",cond_transfusion_notification_req_cd))
 
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
 
/************************************************************************
 *                      Declare Subroutines                             *
 ************************************************************************/
declare processRequestinWithRequest(null)=null
declare processRequestinWithoutRequest(null)=null
 
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
 
set file_name = ""
set file_name = concat("requestin_560201_",sysdate_string,".dat")
call echo(file_name)
;007 call echoxml(requestin,value(file_name))
 
 
;; NOTE:  04/04/2018
;For ambulatory referrals (catlagtypecd = ambulatory_referrals_cd only print future orders when Paper Referal is selected
 
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
call echo(build("scheduling_location_field_id = ",scheduling_location_field_id ))
 
; Non-Radiology
select into "nl:"
from order_entry_fields o
plan o
   where o.description = "Scheduling Locations - Non Radiology"
      and o.codeset = 100173
head report
   scheduling_location_field_non_radiology_id = o.oe_field_id
with nocounter
call echo(build("scheduling_location_field_non_radiology_id = ",scheduling_location_field_non_radiology_id ))
 
/************************************************************************************
 *  Call the appropriate subroutine for requestin processing:                       *
 *  - If the order is processed by the async order server, request 560200 is used.  *
 *    The requestin for 560200 does not have the request sub-level.                 *
 *  - If the order is processed by the sync order server, request 560201 is used.   *
 *    The requestin for 560201 does have the request sub-level.                     *
 ************************************************************************************/
; Check to see whether we got reestin-request or just requestin
if(not validate(requestin->request,0))
   ; Order was processed by async order server and request 560200.  Therefore we got requestin as requestin.
;   call ECHOJSON(requestin, "CG_RqstIn_wo_Request", 1 ) ;008
   call processRequestinWithoutRequest(null)
else
   ; Order was processed by sync order server and request 560201.  Therefore we got requestin as requestin->request.
;   call ECHOJSON(requestin, "CG_RqstIn_w_Request", 1 )  ;008
   call processRequestinWithRequest(null)
endif
 
;call ECHOJSON(drec, "CG_DREC_Dump1", 1 )  ;008
 
; If no records qualify, exit the script
if(size(drec->qual,5) = 0)
   call echorecord(drec)
   go to exit_script
endif
 
subroutine processRequestinWithRequest(null)
   /************************************************************************************
    *   Get the Lab and Rad Future Orders that are configured to print a requisition   *
    ************************************************************************************/
   call echo("CJG - subroutine processRequestinWithRequest")
 
   IF (vDEBUG = 1) ;009
     CALL sWRITE_MESSAGE_NOFLAG("Reseting print flag ...","PFMT_LOG.LOG")
     ;set requestin->request->orderlist[1].printreqind = 1
   ENDIF
 
   select into "nl:"
      orderId = requestin->request.orderlist[d.seq].orderid
   from (dummyt d with seq=size(requestin->request->orderlist,5)),
         orders o,
         encounter e,   ; 001
         order_catalog oc,
         dcp_output_route dor
   plan d
      where requestin->request->orderlist[d.seq].catalogtypecd
;006            in (general_lab_cd,radiology_cd,cardiology_cd,ambulatory_referrals_cd) ; Rad Lab
            in (general_lab_cd,radiology_cd,cardiology_cd,ambulatory_referrals_cd,amb_proc_cd) ;006
         and requestin->request->orderlist[d.seq].orderstatuscd = future_cd ; Future
;         and requestin->request.orderlist[d.seq].actiontypecd in (2534.00,2533.00,2524.00) ; Order, Modify, Activate
         and (requestin->request->orderlist[d.seq].printreqind = 1)
            /*  002 - Backout the  feature to print on Modify/Reschedule
              or (requestin->request->orderlist[d.seq].printreqind = 0
                  and requestin->request.orderlist[d.seq].actiontypecd = modify_action_cd))  ; 001
            */
         and requestin->request->orderlist[d.seq].requisitionformatcd
           not in(transfusion_notification_req_cd,lab_tm_ivig_notification_cd)
     ;    and requestin->request->orderlist[d.seq].orderid  = 351875789.00
   join o
      where o.order_id = requestin->request->orderlist[d.seq].orderid
   join e                                          ; 001
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
         drec->qual[cntr].requisition_routing_cd = oc.requisition_routing_cd    ;001
      endif                                                                     ;001
      drec->qual[cntr].person_id = requestin->request->personid
      drec->qual[cntr].print_ind = 0
      if(dor.param1_cd = ord_loc_routing_cd); Order Location
         idx = 0
         idx = locateval(num,
                           1,
                           size(requestin->request->orderlist[d.seq]->detaillist,5),
                           "ORDERLOC",
                           requestin->request->orderlist[d.seq]->detaillist[num].oefieldmeaning
                        )
         if(idx > 0)
            drec->qual[cntr].ordering_location = requestin->request.orderlist[d.seq]->detaillist[idx].oefieldvalue
         else
            drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd    ; 001
         endif
         ;004 - If there is a WTS Location, use it
         if (requestin->request->orderlocncd > 0.00)
            drec->qual[cntr].ordering_location = requestin->request->orderlocncd
         endif
      endif
 
      if(dor.param1_cd = pat_loc_routing_cd); Patient Location
         drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd        ; 001
      endif
 
      if(dor.param1_cd = pat_fac_routing_cd); Patient Facility
         drec->qual[cntr].ordering_location = e.loc_facility_cd          ; 001
      endif
 
   with nocounter
 
 
   ; If no records qualify, exit the subroutine
   if(size(drec->qual,5) = 0)
      return
   endif
 
   set vStatus = "Before Query" ;009
 
   IF (vDEBUG = 1) ;009
     CALL sWRITE_MESSAGE_NOFLAG("Before Query","PFMT_LOG.LOG")
   ENDIF
 
   /***********************************************************************************************
    *   Check the Scheduling Location Field to see whether to supercede the ORDERLOC - Radiology  *
    ***********************************************************************************************/
   ; First, check to see if a value other than "Print to Paper" was selected at the Scheduling Location field
   select into "nl:"
      order_id = drec->qual[d.seq].order_id
   from (dummyt d with seq=size(drec->qual,5))
   plan d
   detail
      vStatus = "In Query 1" ;009
      idx = locateval(num,1,size(requestin->request->orderlist,5),order_id,requestin->request->orderlist[num].orderid)
      call echo(build("idx = ",idx))
      if(idx > 0)
         vStatus = "In Query 2" ;009
         idx2 = locateval(num2,1,size(requestin->request->orderlist[idx]->detaillist,5),scheduling_location_field_id,
                      requestin->request.orderlist[idx]->detaillist[num2].oefieldid)
         if(idx2 > 0)
            vStatus = "In Query 3" ;009
            call echo(build("idx2 = ",idx2))
            vStatus = BUILD(build("idx2 = ",idx2)) ;009
            if(requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue not in(0.00,print_to_paper_cd,paper_referral_cd))
               drec->qual[d.seq].scheduling_location = requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue
               vStatus = "In Query 4" ;009
 
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
 
   IF (vDEBUG = 1) ;009
     CALL sWRITE_MESSAGE_NOFLAG("Schedule Location...","PFMT_LOG.LOG")
     CALL sWRITE_MESSAGE_NOFLAG("Vstatus...","PFMT_LOG.LOG")
     CALL sWRITE_MESSAGE_NOFLAG(build(vStatus),"PFMT_LOG.LOG")
     CALL ECHOJSON(drec, "PFMT_LOG.LOG", 1 )
   ENDIF
 
 
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
      call echo(build("idx = ",idx))
      if(idx > 0)
         idx2 = locateval(num2,1,size(requestin->request->orderlist[idx]->detaillist,5),scheduling_location_field_non_radiology_id,
                         requestin->request.orderlist[idx]->detaillist[num2].oefieldid)
         if(idx2 > 0)
            call echo(build("idx2 = ",idx2))
            if(requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue not in(0.00,print_to_paper_cd,paper_referral_cd))
               drec->qual[d.seq].scheduling_location = requestin->request.orderlist[idx]->detaillist[idx2].oefieldvalue
            endif
         endif
      endif
   with nocounter
 
   IF (vDEBUG = 1) ;009
     CALL sWRITE_MESSAGE_NOFLAG("End of routine...","PFMT_LOG.LOG")
     CALL ECHOJSON(drec, "PFMT_LOG.LOG", 1 )
   ENDIF
 
 
end ; processRequestinWithRequest(null)
 
subroutine processRequestinWithoutRequest(null)
   /************************************************************************************
    *   Get the Lab and Rad Future Orders that are configured to print a requisition   *
    ************************************************************************************/
   call echo("CJG - subroutine processRequestinWithoutRequest")
   select into "nl:"
      orderId = requestin->orderlist[d.seq].orderid
   from (dummyt d with seq=size(requestin->orderlist,5)),
         orders o,
         encounter e,   ; 001
         order_catalog oc,
         dcp_output_route dor
   plan d
      where requestin->orderlist[d.seq].catalogtypecd
;006            in (general_lab_cd,radiology_cd,cardiology_cd,ambulatory_referrals_cd) ; Rad Lab
            in (general_lab_cd,radiology_cd,cardiology_cd,ambulatory_referrals_cd,amb_proc_cd) ; 006
         and requestin->orderlist[d.seq].orderstatuscd = future_cd ; Future
         and (requestin->orderlist[d.seq].printreqind = 1)
         /* 002 - Backout the  feature to print on Modify/Reschedule
              or (requestin->orderlist[d.seq].printreqind = 0
                  and requestin->orderlist[d.seq].actiontypecd = modify_action_cd))  ; 001
         */
         and requestin->orderlist[d.seq].requisitionformatcd not in(transfusion_notification_req_cd,lab_tm_ivig_notification_cd)
 
   join o
      where o.order_id = requestin->orderlist[d.seq].orderid
   join e                                          ; 001
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
         drec->qual[cntr].requisition_routing_cd = oc.requisition_routing_cd    ;001
      endif                                                                     ;001
 
      drec->qual[cntr].person_id = requestin->personid
      drec->qual[cntr].print_ind = 0
      if(dor.param1_cd = ord_loc_routing_cd); Order Location
         idx = 0
         idx = locateval(num,
                           1,
                           size(requestin->orderlist[d.seq]->detaillist,5),
                           "ORDERLOC",
                           requestin->orderlist[d.seq]->detaillist[num].oefieldmeaning
                        )
         if(idx > 0)
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
 
      if(dor.param1_cd = pat_loc_routing_cd); Patient Location
         drec->qual[cntr].ordering_location = e.loc_nurse_unit_cd ;001
      endif
 
      if(dor.param1_cd = pat_fac_routing_cd); Patient Facility
         drec->qual[cntr].ordering_location = e.loc_facility_cd ;001
      endif
   with nocounter
 
   ; If no records qualify, exit the subroutine
   if(size(drec->qual,5) = 0)
      return
   endif
 
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
      call echo(build("idx = ",idx))
      if(idx > 0)
         idx2 = locateval(num2,1,size(requestin->orderlist[idx]->detaillist,5),scheduling_location_field_id,
                      requestin->orderlist[idx]->detaillist[num2].oefieldid)
         if(idx2 > 0)
            call echo(build("idx2 = ",idx2))
            if(requestin->orderlist[idx]->detaillist[idx2].oefieldvalue not in(0.00,print_to_paper_cd,paper_referral_cd))
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
      call echo(build("idx = ",idx))
      if(idx > 0)
         idx2 = locateval(num2,1,size(requestin->orderlist[idx]->detaillist,5),scheduling_location_field_non_radiology_id,
                         requestin->orderlist[idx]->detaillist[num2].oefieldid)
         if(idx2 > 0)
            call echo(build("idx2 = ",idx2))
            if(requestin->orderlist[idx]->detaillist[idx2].oefieldvalue not in(0.00,print_to_paper_cd,paper_referral_cd))
               drec->qual[d.seq].scheduling_location = requestin->orderlist[idx]->detaillist[idx2].oefieldvalue
            endif
         endif
      endif
   with nocounter
end ; processRequestinWithoutRequest(null)
 
; The scheduling location is a code set 100301 or 100173 value.  Get the actual code set 220 value from code_value_group
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
/*
; The scheduling location is a code set 100173 value.  Get the actual code set 220 value from code_value_group
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
*/
 
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
   call echo(build("dfp.printer_name = ",dfp.printer_name))
with nocounter
 
call ECHOJSON(drec, "CG_DREC_Dump2", 1 )  ;008
 
call echorecord(drec)
;go to exit_script
/************************************************************************************
 *                            Print the requisition                                 *
 ************************************************************************************/
   IF (vDEBUG = 1);009
     CALL sWRITE_MESSAGE_NOFLAG("Print Flag","PFMT_LOG.LOG")
     CALL sWRITE_MESSAGE_NOFLAG(BUILD(printInd),"PFMT_LOG.LOG")
     CALL sWRITE_MESSAGE_NOFLAG("Drec ...","PFMT_LOG.LOG")
     CALL ECHOJSON(drec, "PFMT_LOG.LOG", 1 )
   ENDIF
 
 
if (printInd = 1) ; there is at least one order to print
   set file_name = ""
   set file_name = concat("drec_pfmt_",sysdate_string,".dat")
   call echo(file_name)
   ;007 call echoxml(drec,value(file_name))
 
   ; Send request up to 3 printers
 
   ; Printer #1
   set cntr = 0
   set stat = initrec(request560601)
   set request560601->personId = drec->qual[1].person_id
   set request560601->reqInd = 1
 
   for(i=1 to size(drec->qual,5))
      if (drec->qual[i].print_ind = 1)
         set cntr = cntr+1
         set stat = alterlist(request560601->orderList,cntr)
         set request560601->orderList[cntr].encntrId = drec->qual[i].originating_encounter_id
         set request560601->orderList[cntr].orderId = drec->qual[i].order_id
         set request560601->orderList[cntr].reqInd = 1
 
         set request560601->orderList[cntr].reqPrinterName = drec->qual[i]->printers[1].printer_name
      endif
   endfor ; i
 
   if (printInd = 1) ; there is at least one order to print
      set file_name = ""
      set file_name = concat("request560601_",sysdate_string,"_printer1.dat")
      call echo(file_name)
      call echorecord(request560601)
      ;007 call echoxml(request560601,value(file_name))
      ;Application=600005  :  Power Chart
      ;Task=500196         :  UPDATE PowerChart Orders
      ;Request=560601      :  DCP.OutputReprint
 
      call ECHOJSON(request560601, "CG_R560601_Printer1", 1 )  ;008
 
      ; make the server call using TDBEXECUTE
      if (size(request560601->orderList,5) > 0)
         set stat = tdbexecute(600005,500196,560601,"REC",request560601,"REC",reply560601)
      endif
 
      set file_name = ""
      set file_name = concat("reply560601_",sysdate_string,"_printer1.dat")
      call echo(file_name)
      ;007 call echoxml(reply560601,value(file_name))
   endif
 
   ; Printer #2
   set printInd = 0 ; set back to not print, assume there is no second printer
   set cntr = 0
   set stat = initrec(request560601)
   set request560601->personId = drec->qual[1].person_id
   set request560601->reqInd = 1
 
   for(i=1 to size(drec->qual,5))
      if (drec->qual[i].print_ind = 1)
         if(size(drec->qual[i]->printers,5) > 1)
            set cntr = cntr+1
            set stat = alterlist(request560601->orderList,cntr)
            set request560601->orderList[cntr].encntrId = drec->qual[i].originating_encounter_id
            set request560601->orderList[cntr].orderId = drec->qual[i].order_id
            set request560601->orderList[cntr].reqInd = 1
 
            set request560601->orderList[cntr].reqPrinterName = drec->qual[i]->printers[2].printer_name
            set printInd = 1 ; there is at least one order to print to a second printer
         endif
      endif
   endfor ; i
 
   if (printInd = 1) ; there is at least one order to print to a second printer
      set file_name = ""
      set file_name = concat("request560601_",sysdate_string,"_printer2.dat")
      call echo(file_name)
      call echorecord(request560601)
;      call echoxml(request560601,value(file_name))
      ;Application=600005  :  Power Chart
      ;Task=500196         :  UPDATE PowerChart Orders
      ;Request=560601      :  DCP.OutputReprint
 
      call ECHOJSON(request560601, "CG_R560601_Printer2", 1 )  ;008
 
      ; make the server call using TDBEXECUTE
      if (size(request560601->orderList,5) > 0)
         set stat = tdbexecute(600005,500196,560601,"REC",request560601,"REC",reply560601)
      endif
 
      set file_name = ""
      set file_name = concat("reply560601_",sysdate_string,"_printer2.dat")
      call echo(file_name)
;      call echoxml(reply560601,value(file_name))
   endif
 
   ; Printer #3
   set printInd = 0 ; set back to not print, assume there is no third printer
   set cntr = 0
   set stat = initrec(request560601)
   set request560601->personId = drec->qual[1].person_id
   set request560601->reqInd = 1
 
   for(i=1 to size(drec->qual,5))
      if (drec->qual[i].print_ind = 1)
         if(size(drec->qual[i]->printers,5) > 2)
            set cntr = cntr+1
            set stat = alterlist(request560601->orderList,cntr)
            set request560601->orderList[cntr].encntrId = drec->qual[i].originating_encounter_id
            set request560601->orderList[cntr].orderId = drec->qual[i].order_id
            set request560601->orderList[cntr].reqInd = 1
 
            set request560601->orderList[cntr].reqPrinterName = drec->qual[i]->printers[3].printer_name
            set printInd = 1 ; there is at least one order to print to a third printer
         endif
      endif
   endfor ; i
 
   if (printInd = 1) ; there is at least one order to print to a third printer
      set file_name = ""
      set file_name = concat("request560601_",sysdate_string,"_printer3.dat")
      call echo(file_name)
      call echorecord(request560601)
;      call echoxml(request560601,value(file_name))
      ;Application=600005  :  Power Chart
      ;Task=500196         :  UPDATE PowerChart Orders
      ;Request=560601      :  DCP.OutputReprint
 
      call ECHOJSON(request560601, "CG_R560601_Printer3", 1 )  ;008
 
      ; make the server call using TDBEXECUTE
      if (size(request560601->orderList,5) > 0)
      set stat = tdbexecute(600005,500196,560601,"REC",request560601,"REC",reply560601)
      endif
 
      set file_name = ""
         set file_name = concat("reply560601_",sysdate_string,"_printer3.dat")
      call echo(file_name)
;      call echoxml(reply560601,value(file_name))
   endif
endif
 
/*
<Request>
	<personId>11854656</personId>
	<consFormInd>0</consFormInd>
	<reqInd>1</reqInd>
	<osInd>0</osInd>
	<orderList 1:1>
		<encntrId>96945443</encntrId>
		<orderId>308541267</orderId>
		<consFormInd>0</consFormInd>
		<consFormPrinterName></consFormPrinterName>
		<reqInd>1</reqInd>
		<reqPrinterName>590_1stfl_t1</reqPrinterName>
		<osInd>0</osInd>
		<osPrinterName></osPrinterName>
	</orderList 1:1>
</Request>
*/
 
#exit_script
 
end
go

/*************************************************************************************************************************
 
Source file name:		BC_ALL_CARD_ALLSTATUS_REQ.PRG
Object name:			  CRDASTATREQ
 
Program purpose:		Cardiology Laboratory Holter and Stress test requisition
 
Executing from:			PowerChart
 
Special Notes:      This requisition can be used for all Cardiology tests which allow printing of active and future
                    orders.
 
*************************************************************************************************************************
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  06-AUG-2019  CST-48311  Barry Wong             Created
001  04-SEP-2019  CST-99999  Barry Wong             Modified to not print future orders
002  27-SEP-2019  CST-53887  Barry Wong             Modified to add Scheduled As OEF to requisition, re-instate future
                                                    logic only when the scheduling location = Paper Referral
                                                    Added MUSE bypass logic from the ECG requisition
003  21-NOV-2019  CST-61640  Barry Wong             Modified to include Supervising MD and Primary Care Provider
004  03-Dec-2019  CST-66313  Barry Wong             Added Scheduling Priority
005  03-APR-2020  CST-83593  Barry Wong             Modified to print multiple isolation orders
006  29-MAY-2020  CST-83593  Barry Wong             Added watermark logic; changes in %Includes and Layout
                                                    Update order filter to allow all reprints
                                                    Modified to allow reprinting of future orders
                                                    Modified to pass future order indicator to layout to prevent the
                                                    printing of isolation and alerts.
                                                    Modified to check the original status of a canceled, discontinued and
                                                    voided to determine if the future header is to be printed.
007  01-SEP-2020  CST-90901  Jeremy Gunn            Added code for Approx, Sometime before and Exact request dates
*************************************************************************************************************************/
 
drop program crdastatreq:dba go
create program crdastatreq:dba
 
;=====================================================
; DVDev DECLARED SUBROUTINES
;=====================================================
execute bc_all_all_std_routines
execute bc_all_all_date_routines
execute bc_all_all_req_prt_check  ;006
 
declare log_file = vc with constant("BC_ALL_CARD_ALLSTATUS_REQ.LOG")
set C3_debug_on = 0
set C3_trace_on = 0
 
;=====================================================
; DEBUG - Free REQUEST record
;=====================================================
if (C3_debug_on = 1 )
  free set request
endif
 
;=====================================================
; DVDev Record structure
;=====================================================
record request(
  1 person_id         = f8
  1 print_prsnl_id    = f8
  1 order_qual[*]
    2 order_id        = f8
    2 encntr_id       = f8
    2 conversation_id = f8
  1 printer_name      = c50
)
 
if (C3_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Entered program...", log_file)
endif
 
;=====================================================
; DEBUG - Setup REQUEST information for test order
;=====================================================
if (C3_debug_on = 1 )
  set request->person_id = 15462939.00
  set request->print_prsnl_id = 0.00
  set request->printer_name = "MINE"
  set stat = alterlist(request->order_qual, 1 )
  set request->order_qual[1 ].order_id = 443705783.00  ;Holter test
;  set request->order_qual[1 ].order_id = 443707675.00  ;Graded Exercise test
  set request->order_qual[1 ].encntr_id = 110090141.00
  set request->order_qual[1 ].conversation_id = 0.00
endif
 
if (C3_trace_on = 1 )
  call ECHOJSON(request, "ECHOJSONC3A", 1 )
endif
 
;=====================================================
; DVDev Record structure
;=====================================================
free set common_rec
record common_rec(
  1 pat_data
    2 weight_val      = vc
    2 weight_unit     = vc
    2 height_val      = vc
    2 height_unit     = vc
    2 process_alert   = vc
    2 disease_alert   = vc
  1 allergy
    2 allergy1        = vc
    2 allergy2        = vc
    2 allergy3        = vc
    2 allergy4        = vc
    2 more_allergy    = vc
  1 relevent_lab
    2 creatinine      = vc
    2 eGFR            = vc
    2 INR             = vc
    2 PTT             = vc
    2 PLT             = vc
    2 FallRiskScore   = vc
)
with persistscript
 
%i CUST_SCRIPT:bc_all_all_requisition_patrecd.inc
%i CUST_SCRIPT:bc_all_card_nonecg_ordrecd.inc
%i CUST_SCRIPT:bc_all_card_nonecg_prtrecd.inc
 
;=====================================================
; Declarations
;=====================================================
declare cvFuture  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare order_idx = i4
declare order_num = i4 with noconstant(0)
declare iFuture_ind = i2
 
; Variable declaration common to requisitions based on RadNet requisition design logic
%i CUST_SCRIPT:bc_all_all_req_inc_dcls.inc
%i CUST_SCRIPT:bc_all_all_req_isolation_dcls.inc   ;005
 
;=====================================================
; Get Patient information
;=====================================================
%i CUST_SCRIPT:bc_all_all_requisition_patinfo.inc
 
if (request->person_id > 0.00 )
  if (size(request->order_qual, 5) > 0 )
    set orders_rec->spoolout_ind = 1
    ;=====================================================
    ; Allocate ORDERS_REC structure for # of orders
    ;=====================================================
    set stat = alterlist(orders_rec->qual, size(request->order_qual, 5) )
 
    ;=====================================================
    ; Get information common to all orders
    ;=====================================================
%i CUST_SCRIPT:bc_all_all_req_patdata.inc
%i CUST_SCRIPT:bc_all_all_req_allergydata.inc
%i CUST_SCRIPT:bc_all_all_req_labdata.inc
 
    ;=====================================================
    ; Get information specific to each order
    ;=====================================================
    for (order_idx = 1 to size(request->order_qual, 5) )
 
;002      set iFuture_ind = sORDER_TYPE_EQUAL(request->order_qual[order_idx ].order_id, cvFuture )
 
      ;=====================================================
      ; Process if order is not cancelled, completed or
      ; discontinued (1,1,1)
      ;=====================================================
;002      if (sBYPASS_PRINT_ON_STATUS(request->order_qual[order_idx ].order_id, 1, 1, 1 ) = 0 and iFuture_ind = 0 )
 
;006      if ((sBYPASS_PRINT_ON_STATUS(request->order_qual[order_idx ].order_id, 1, 1, 1 ) = 0 ) and  ;002
;006          (sECG_MUSE_BYPASS(request->order_qual[order_idx ].order_id ) = 0 ) )                    ;002
 
      if (request->print_prsnl_id > 5.00 or                                                        ;006
          ((sBYPASS_PRINT_ON_STATUS(request->order_qual[order_idx ].order_id, 1, 1, 1 ) = 0 ) and  ;006
           (sECG_MUSE_BYPASS(request->order_qual[order_idx ].order_id ) = 0 ) ) )                  ;006
 
        set order_num = order_num + 1
 
        ;=====================================================
        ; Assign originating encounter ID if required
        ;=====================================================
        if (request->order_qual[order_idx ].encntr_id = 0.00 )
          set request->order_qual[order_idx ].encntr_id = sGET_ORIG_ENCNTR_ID(request->order_qual[order_idx ].order_id )
        endif
 
%i CUST_SCRIPT:bc_all_all_req_encdata.inc
%i CUST_SCRIPT:bc_all_card_nonecg_ordinfo.inc
%i CUST_SCRIPT:bc_all_all_req_isolation_extr.inc   ;005
 
      endif
    endfor
  endif
endif
 
if (C3_trace_on = 1 )
  call ECHOJSON(orders_rec, "ECHOJSONC3B", 1 )
endif
 
;=====================================================
; Bypass if no requisitions to print otherwise pack
; the OUTREC data structure
;=====================================================
if (order_num > 0 )
  set stat = alterlist(orders_rec->qual, order_num )
endif
 
;=====================================================
; Print requisitions one at a time after inpatient
; encounter verification
;=====================================================
if (orders_rec->spoolout_ind = 1 and order_num > 0 )
  for (order_idx = 1 to size(orders_rec->qual, 5) )
 
    ;002 Start
    set iFuture_ind = sORDER_TYPE_EQUAL(orders_rec->qual[order_idx ].order_id, cvFuture )
;006    if (iFuture_ind = 0 or (iFuture_ind = 1 and orders_rec->qual[order_idx ].order_detail.scheduling_locn = "Paper Referral" ) )
    ;002 End
 
    ;006 Start
    if ( iFuture_ind = 0 or
        (iFuture_ind = 1 and request->print_prsnl_id > 5.00 ) or
        (iFuture_ind = 1 and orders_rec->qual[order_idx ].order_detail.scheduling_locn = "Paper Referral" )
       )
    ;006 End
 
      ;007 Overide Order Request Date
      IF (iFuture_ind = 1)
        SET ORDERS_REC->QUAL[ORDER_IDX].ORDER_RQSTDTTM = SUBSTRING(1,11,ORDERS_REC->QUAL[ORDER_IDX].ORDER_RQSTDTTM)
      ENDIF
      SET ORDERS_REC->QUAL[ORDER_IDX].ORDER_RQSTDTTM =
        sGET_APPROX_SOMETIME_EXACT_RQSTTIME(ORDERS_REC->QUAL[ORDER_IDX].ORDER_ID,ORDERS_REC->QUAL[ORDER_IDX].ORDER_RQSTDTTM)
 
 
      ;=====================================================
      ; Assign an order to the layout print record
      ;=====================================================
      set print_order->spoolout_ind       = orders_rec->spoolout_ind
      set print_order->perform_location   = orders_rec->perform_location
      set print_order->printer_reassigned = orders_rec->printer_reassigned
      set print_order->order_location     = orders_rec->order_location
      ; Order information
      set print_order->order_id           = orders_rec->qual[order_idx ].order_id
      set print_order->encntr_id          = orders_rec->qual[order_idx ].encntr_id
      set print_order->encntr_num         = orders_rec->qual[order_idx ].encntr_num
      set print_order->site               = orders_rec->qual[order_idx ].site
      set print_order->nurseunit          = orders_rec->qual[order_idx ].nurseunit
      set print_order->room               = orders_rec->qual[order_idx ].room
      set print_order->bed                = orders_rec->qual[order_idx ].bed
      set print_order->ordering_md        = orders_rec->qual[order_idx ].ordering_md
      set print_order->order_by_name      = orders_rec->qual[order_idx ].order_by_name
      set print_order->order_as_mnemonic  = orders_rec->qual[order_idx ].order_as_mnemonic
      set print_order->order_frequency    = orders_rec->qual[order_idx ].order_frequency
      set print_order->order_priority     = orders_rec->qual[order_idx ].order_priority
      set print_order->sch_priority       = orders_rec->qual[order_idx ].sch_priority       ;004
      set print_order->order_rqstdttm     = orders_rec->qual[order_idx ].order_rqstdttm
      set print_order->ordering_md_id     = orders_rec->qual[order_idx ].ordering_md_id
      set print_order->ordering_md_MSP    = orders_rec->qual[order_idx ].ordering_md_MSP
      set print_order->ordering_md_phone  = orders_rec->qual[order_idx ].ordering_md_phone
      set print_order->supervising_md     = orders_rec->qual[order_idx ].supervising_md     ;003
      set print_order->primary_care_phys  = orders_rec->qual[order_idx ].primary_care_phys  ;003
      set print_order->order_dt_tm        = orders_rec->qual[order_idx ].order_dt_tm
      set print_order->isolation          = orders_rec->qual[order_idx ].isolation
      set print_order->ins_plan_name      = orders_rec->qual[order_idx ].health_plan.ins_plan_name
      set print_order->ins_plan_nbr       = orders_rec->qual[order_idx ].health_plan.ins_plan_nbr
      set print_order->ins_plan_expdt     = orders_rec->qual[order_idx ].health_plan.ins_plan_expdt
      set print_order->patient_type       = orders_rec->qual[order_idx ].patient_type
      set print_order->callback_number    = orders_rec->qual[order_idx ].order_detail.callback_number
      ; Order details
      set print_order->relevent_meds      = orders_rec->qual[order_idx ].order_detail.relevent_meds
      set print_order->scheduling_locn    = orders_rec->qual[order_idx ].order_detail.scheduling_locn
      set print_order->scheduled_as       = orders_rec->qual[order_idx ].order_detail.scheduled_as    ;002
      set print_order->procedure_reason   = orders_rec->qual[order_idx ].order_detail.procedure_reason
      set print_order->future_order       = orders_rec->qual[order_idx ].order_detail.future_order
      set print_order->pacemaker          = orders_rec->qual[order_idx ].order_detail.pacemaker
      set print_order->ICD                = orders_rec->qual[order_idx ].order_detail.ICD
      set print_order->ICD_shock_zone     = orders_rec->qual[order_idx ].order_detail.ICD_shock_zone
      set print_order->anticoagulants     = orders_rec->qual[order_idx ].order_detail.anticoagulants
      set print_order->refer_to_md        = orders_rec->qual[order_idx ].order_detail.refer_to_md
      set print_order->request_md         = orders_rec->qual[order_idx ].order_detail.request_md
      set print_order->research_study     = orders_rec->qual[order_idx ].research_study
      set print_order->spec_instructions  = orders_rec->qual[order_idx ].order_detail.spec_instructions
      set print_order->program_mode       = orders_rec->qual[order_idx ].order_detail.program_mode
      set print_order->device_type        = orders_rec->qual[order_idx ].order_detail.device_type
      set print_order->lower_rate         = orders_rec->qual[order_idx ].order_detail.lower_rate
      set print_order->upper_rate         = orders_rec->qual[order_idx ].order_detail.upper_rate
      set print_order->watermark          = orders_rec->qual[order_idx ].watermark                   ;006
      set print_order->future_order_ind   = iFuture_ind                                              ;006
      if (iFuture_ind = 0 )                                                                          ;006
        set print_order->future_order_ind = sCard_PrevStatus(orders_rec->qual[order_idx ].order_id ) ;006
      endif                                                                                          ;006
 
      ; Remove the leading comma and trailing semi-colon from the concatenated fields
      set print_order->addl_copies_to     = trim(replace(orders_rec->qual[order_idx ].order_detail.addl_copies_to, ",", "", 1 ), 3 )
      set print_order->device_type        = trim(replace(orders_rec->qual[order_idx ].order_detail.device_type, ";", "", 2 ), 3 )
      set print_order->procedure_reason   = trim(replace(orders_rec->qual[order_idx ].order_detail.procedure_reason, ";", "", 2 ),3)
 
      if (C3_trace_on = 1 )
         call ECHOJSON(print_order, "ECHOJSONC3C", 1 )
      endif
 
      ;=====================================================
      ; Print only if not in debug mode
      ;=====================================================
      if (C3_debug_on = 0 )
        ; Call the layout to print the requisition to Cardiology Lab
        if (C3_trace_on = 1 )
          call sWRITE_MESSAGE_NOFLAG("Before layout call...", log_file)
          call sWRITE_MESSAGE_NOFLAG(concat("Order#...", cnvtstring(print_order->order_id )), log_file )
        endif
        execute bc_all_card_allstatus_req_lyt value(request->printer_name )
        if (C3_trace_on = 1 )
          call sWRITE_MESSAGE_NOFLAG("After layout call...", log_file)
        endif
      endif
 
    endif  ;002
  endfor
endif
 
if (C3_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Exiting program...", log_file)
endif
 
#exit_script
 
set C3_trace_on = 0
 
SUBROUTINE sGET_APPROX_SOMETIME_EXACT_RQSTTIME(pORDERID,pRQSTDATE) ;007
 
  DECLARE cvFORDGRACENUMBER = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "FUTUREORDERGRACENUMBER"))
  DECLARE cvFORDGRACEUNIT = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "FUTUREORDERGRACEUNIT"))
  DECLARE cvFORDTYPE = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "FUTUREORDERTYPE"))
  DECLARE cvFORDINAPPROXDURATIONNUMBER = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "FUTUREORDERINAPPROXDURATIONNUMBER"))
  DECLARE cvFORDINAPPROXDURATIONUNIT = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "FUTUREORDERINAPPROXDURATIONUNIT"))
 
  DECLARE cvINAPPROXIMATELY = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 4002781, "INAPPROXIMATELY"))
  DECLARE cvONEXACTLY = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 4002781, "ONEXACTLY"))
  DECLARE cvSOMETIMEBEFORE = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 4002781, "SOMETIMEBEFORE"))
 
 
  DECLARE vLINE = VC
  DECLARE vFORDGRACENBR = VC WITH NOCONSTANT(""),PROTECT
  DECLARE vFORDGRACEUNIT = VC WITH NOCONSTANT(""),PROTECT
  DECLARE vFORDTYPE = F8 WITH NOCONSTANT(0.0),PROTECT
  DECLARE vFORDINAPPROXDURATIONNBR = VC WITH NOCONSTANT(""),PROTECT
  DECLARE vFORDINAPPROXDURATIONUNIT = VC WITH NOCONSTANT(""),PROTECT
 
  DECLARE vPROJ_START = DQ8
  DECLARE vPROJ_END = DQ8
 
 
 
  SELECT INTO "NL:"
    OEF_ID = OD.OE_FIELD_ID
  FROM ORDER_DETAIL   OD
  WHERE OD.ORDER_ID = pORDERID
    AND OD.OE_FIELD_ID IN (cvFORDGRACENUMBER,cvFORDGRACEUNIT,cvFORDTYPE,cvFORDINAPPROXDURATIONNUMBER,cvFORDINAPPROXDURATIONUNIT)
 
 
  ORDER BY
    OD.OE_FIELD_ID,
    OD.ACTION_SEQUENCE DESC,
    OD.UPDT_DT_TM
 
  HEAD OD.OE_FIELD_ID
    CURRENT_FIELD_ID = OD.OE_FIELD_ID
    CURRENT_ACT_SEQ = OD.ACTION_SEQUENCE
 
  DETAIL
    IF (OD.OE_FIELD_ID = CURRENT_FIELD_ID AND OD.ACTION_SEQUENCE = CURRENT_ACT_SEQ )
      CASE (OEF_ID )
        OF cvFORDGRACENUMBER             : vFORDGRACENBR = CNVTSTRING(OD.OE_FIELD_VALUE)
        OF cvFORDGRACEUNIT               : vFORDGRACEUNIT = OD.OE_FIELD_DISPLAY_VALUE
        OF cvFORDTYPE                    : vFORDTYPE = OD.OE_FIELD_VALUE
        OF cvFORDINAPPROXDURATIONNUMBER  : vFORDINAPPROXDURATIONNBR = OD.OE_FIELD_DISPLAY_VALUE
        OF cvFORDINAPPROXDURATIONUNIT    : vFORDINAPPROXDURATIONUNIT = OD.OE_FIELD_DISPLAY_VALUE
      ENDCASE
    ENDIF
 
  WITH NOCOUNTER
 
  IF (vFORDTYPE = cvINAPPROXIMATELY)
    SET vLINE = CONCAT(TRIM(UAR_GET_CODE_DISPLAY(vFORDTYPE),3)," ",vFORDINAPPROXDURATIONNBR," ",vFORDINAPPROXDURATIONUNIT," = ",
                SUBSTRING(1,11,pRQSTDATE),", Grace Period (+/-) ",vFORDGRACENBR," ",vFORDGRACEUNIT)
  ELSEIF (vFORDTYPE = cvSOMETIMEBEFORE)
    SET vPROJ_START = CNVTDATETIME(SUBSTRING(1,11,pRQSTDATE))
    SET vFORDGRACENBR = CONCAT("'",vFORDGRACENBR,",",SUBSTRING(1,1,CNVTUPPER(vFORDGRACEUNIT)),"'")
    SET vPROJ_END = CNVTDATETIME(CNVTLOOKAHEAD(vFORDGRACENBR, vPROJ_START))
    SET vLINE = CONCAT("Sometime Before: ",FORMAT(vPROJ_END,"dd-mmm-yyyy;;q"))
  ELSEIF (vFORDTYPE = cvONEXACTLY)
    SET vLINE = CONCAT(TRIM(UAR_GET_CODE_DISPLAY(vFORDTYPE),3)," = ",SUBSTRING(1,11,pRQSTDATE))
  ELSE
    SET vLINE = pRQSTDATE
  ENDIF
 
  RETURN(vLINE)
 
END ;sGET_APPROX_SOMETIME_EXACT_RQSTTIME
 
end
go
 

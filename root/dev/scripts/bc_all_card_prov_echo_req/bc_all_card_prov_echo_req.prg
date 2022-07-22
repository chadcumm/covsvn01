/*****************************************************************************
 
Source file name:  BC_ALL_CARD_PROV_ECHO_REQ.PRG
Object name:       provechoreq
 
Program purpose:   Provincial Echocardiogram requsition
 
Executing from:    PowerChart
 
Special Notes:
 
*************************************************************************************************************************
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  23-JUL-2019  CST-48589  Barry Wong             Created.
001  22-NOV-2019  CST-61646  Barry Wong             Added MUSE bypass logic.
002  03-APR-2020  CST-83593  Barry Wong             Modified to print multiple isolation orders.
                                                    This CCL does not use the include bc_all_all_req_isolation_extr.inc
                                                    as the Isolation string is at the root level. Isolation updated in
                                                    bc_all_card_req_ordinfo.inc
003  12-MAY-2020  CST-87848  Barry Wong             Added encounter ID reset logic.
004  28-MAY-2020  CST-83593  Barry Wong             Added watermark logic; changes in %Includes and Layout
                                                    Update order filter to allow all reprints
005  03-JUL-2020  CST-93324  Jeremy Gunn            Added requisition audit logic
006  02-SEP-2020  CST-98324  Jeremy Gunn            Moved sGET_ORIG_ENCNTR_ID up before order qualification logic
007  04-SEP-2020  CST-98324  Jeremy Gunn            Commented out cv6003_Order as it's declared in bc_all_all_req_prt_check
008  16-SEP-2020  CST-98324  Jeremy Gunn            Added logic from Cerner's pfmt_560601_resend_reprint to grab originating encntr
*************************************************************************************************************************/
 
drop program provechoreq:dba go
create program provechoreq:dba
 
;=====================================================
; DVDev DECLARED SUBROUTINES
;=====================================================
declare sGET_ENC(NULL) = null with Protect
execute bc_all_all_std_routines
execute bc_all_all_date_routines
execute bc_all_all_req_prt_check
execute bc_all_all_req_audit_updt ;005
 
declare log_file = vc with constant("BC_ALL_CARD_PROV_ECHO_REG.LOG")
declare requisition_printed = i2 with noconstant(0) ;005
set C4_debug_on = 0
set C4_trace_on = 0
 
;=====================================================
; DEBUG - Free REQUEST record
;=====================================================
if (C4_debug_on = 1 )
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
 
if (C4_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Entered program...", log_file)
endif
 
;=====================================================
; DEBUG - Setup REQUEST information for test order
;=====================================================
if (C4_debug_on = 1 )
  set request->person_id = 11925675.00
  set request->print_prsnl_id = 0.00
  set request->printer_name = "MINE"
  set stat = alterlist(request->order_qual, 1 )
  set request->order_qual[1 ].order_id = 316977231.00
  set request->order_qual[1 ].encntr_id = 0.00
  set request->order_qual[1 ].conversation_id = 0.00
endif
 
if (C4_trace_on = 1 )
  call ECHOJSON(request, "ECHOJSONC4A", 1 )
endif
 
;=====================================================
; Constant declaration
;=====================================================
; Maximum number of disease and process alerts to be concatenated
declare max_alerts = i4 with public, constant(5)
 
;=====================================================
; Variable declaration
;=====================================================
declare disease_alert = vc
declare process_alert = vc
declare alert_count = i4 with public, noconstant(0)
declare labtype_height = f8
declare labtype_weight = f8
declare labtype_FSR = f8
declare isolation_string = vc
declare output_printer = c50
 
set output_printer = request->printer_name
 
;=====================================================
; Code value declaration
;=====================================================
declare cv8_Auth               = f8 with public, constant(uar_get_code_by("MEANING", 8, "AUTH"))
declare cv8_Modified           = f8 with public, constant(uar_get_code_by("MEANING", 8, "MODIFIED"))
declare cv8_Altered            = f8 with public, constant(uar_get_code_by("MEANING", 8, "ALTERED"))
declare cv319_FinNbr           = f8 with public, constant(uar_get_code_by("MEANING", 319, "FIN NBR"))
;007 declare cv6003_Order           = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare cv320_MSP              = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 320, "MSP"))
declare cv43_Business          = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 43, "BUSINESS"))
declare cv200_PatientIsolation = f8 with public, constant(uar_get_code_by("DISPLAY_KEY", 200, "PATIENTISOLATION" ))
declare cv6004_Ordered         = f8 with public, constant(uar_get_code_by("DISPLAY_KEY", 6004, "ORDERED" ))
declare cv331_PCP              = f8 with public, constant(uar_get_code_by("MEANING" ,331 ,"PCP" ))
 
;=====================================================
; OEF declaration
;=====================================================
%i CUST_SCRIPT:bc_all_card_echo_oef_dcl.inc
 
;=====================================================
; Common isolation declares
;=====================================================
declare cv_ordered_status_cd = f8 with constant(uar_get_code_by("display_key", 6004, "ORDERED" ) ), protect   ;002
%i CUST_SCRIPT:bc_all_all_req_isolation_dcls.inc   ;002
 
;=====================================================
; DVDev Record structure
;=====================================================
%i CUST_SCRIPT:bc_all_all_requisition_patrecd.inc  ;Common patient demographic information
%i CUST_SCRIPT:bc_all_card_req_patrecd.inc         ;Patient related information (measurements, lab results)
%i CUST_SCRIPT:bc_all_card_req_encrecd.inc         ;Encounter related information
%i CUST_SCRIPT:bc_all_card_req_ordrecd.inc         ;Order related information
 
;=====================================================
; Main Logic - Extract requisition data and print
;=====================================================
if (request->person_id > 0.00 )
  if (size(request->order_qual, 5) > 0 )
 
    ; Get patient related information
%i CUST_SCRIPT:bc_all_all_requisition_patinfo.inc
%i CUST_SCRIPT:bc_all_card_req_patinfo.inc
 
 
    ;------------------------------------------------------------------------------------
    ; Get information specific to each encounter/order
    ; Each loop will update the encounter and order information and print the requisition
    ;------------------------------------------------------------------------------------
    for (order_idx = 1 to size(request->order_qual, 5) )
 
      ;=====================================================
      ; Assign originating encounter ID if required 006
      ;=====================================================
      if (request->order_qual[order_idx ].encntr_id = 0.00 )                                                           ;003
        set request->order_qual[order_idx ].encntr_id = sGET_ORIG_ENCNTR_ID(request->order_qual[order_idx ].order_id ) ;003
        call sGET_ORIG_ENCNTR_ID_FROM_ENCOUNTER(NULL)                                                                  ;008
      endif                                                                                                            ;003
 
;004      if (sECG_MUSE_BYPASS(request->order_qual[order_idx ].order_id ) = 0 )   ;001
      if (sECG_MUSE_BYPASS(request->order_qual[order_idx ].order_id ) = 0 or request->print_prsnl_id > 5.00 )  ;004
 
;006        ;=====================================================
;006        ; Assign originating encounter ID if required
;006        ;=====================================================
;006        if (request->order_qual[order_idx ].encntr_id = 0.00 )                                                           ;003
;006          set request->order_qual[order_idx ].encntr_id = sGET_ORIG_ENCNTR_ID(request->order_qual[order_idx ].order_id ) ;003
;006        endif                                                                                                            ;003
 
      ; Get encounter related information
%i CUST_SCRIPT:bc_all_card_req_encinfo.inc
 
      ; Get order related information
%i CUST_SCRIPT:bc_all_card_req_ordinfo.inc         ;Order details common for any order
%i CUST_SCRIPT:bc_all_card_req_echoinfo.inc        ;Order details specific to this requisition
 
;      if (C4_trace_on = 1 )
;        ; Dump extract for current order if trace is on
;        call echojson(patient, "ECHOJSONC4_PATIENT")
;        call echojson(pat_req_info, "ECHOJSONC4_PATINFO")
;        call echojson(enc_req_info, "ECHOJSONC4_ENCINFO")
;        call echojson(orders_rec, "ECHOJSONC4_ORDERINFO")
;      endif
 
        ; Print requisition for current order only if debug is off
        if (C4_debug_on = 0 )
          if (C4_trace_on = 1 )
            call sWRITE_MESSAGE_NOFLAG("Before layout call...", log_file)
            call sWRITE_MESSAGE_NOFLAG(concat("Order#...", cnvtstring(orders_rec->order_id)), log_file)
          endif
 
          execute bc_all_card_prov_echo_req_lyt value(output_printer )
          call write_reqn_info("C4", request, orders_rec, enc_req_info, "" ) ;005
          set requisition_printed = 1 ;005
 
 
 
          if (C4_trace_on = 1 )
            call sWRITE_MESSAGE_NOFLAG("After layout call...", log_file)
          endif
        endif
 
      endif   ;001
    endfor
  endif
endif
 
; Write an audit record if a requisition did not print
if (requisition_printed = 0 and C4_debug_on = 0 )  ;005
  call write_rqst_info("C4", request )             ;005
endif
 
set C4_trace_on = 0
 
 
SUBROUTINE sGET_ORIG_ENCNTR_ID_FROM_ENCOUNTER(NULL)
 
  if (request->print_prsnl_id > 5.00)
    ;===========================================================================
    ; Get Originating Encounter (taken from Cerner's pfmt_560601_resend_reprint)
    ;===========================================================================
    ; First check for the originating_encntr_id of the order
    select into "nl:"
    from (dummyt d with seq=size(request->order_qual,5)),
          orders o,
          order_action oa
    plan d
    where request->order_qual[d.seq].encntr_id = 0.00
      and request->order_qual[d.seq].order_id != 0.00
      and request->printer_name > " "
 
    join o
    where o.order_id = request->order_qual[d.seq].order_id
      and o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"CARDIOLOGY"))
      and o.originating_encntr_id != 0.00
 
    join oa
    where oa.order_id = o.order_id
      and oa.action_sequence =
        (select max(action_sequence) from order_action
         where order_id = o.order_id)
 
    detail
       request->order_qual[d.seq].conversation_id = oa.order_conversation_id
       request->order_qual[d.seq].encntr_id = o.originating_encntr_id
    with nocounter
 
    ; If there is no originating_encntr_id on the order (eg the order was placed in scheduling) get the encntr_id of the last encntr
    select into "nl:"
    from
      (dummyt d with seq=size(request->order_qual,5)),
      orders o,
      order_action oa,
      person p,
      encounter e
 
    plan d
    where request->order_qual[d.seq].encntr_id = 0.00
      and request->order_qual[d.seq].order_id != 0.00
      and request->printer_name > " "
 
    join o
    where o.order_id = request->order_qual[d.seq].order_id
      and o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"CARDIOLOGY"))
 
    join oa
    where oa.order_id = o.order_id
    and oa.action_sequence =
      (select max(action_sequence) from order_action
       where order_id = o.order_id)
 
    join p
    where p.person_id = o.person_id
 
    join e
    where e.reg_dt_tm = p.last_encntr_dt_tm
 
    detail
      request->order_qual[d.seq].conversation_id = oa.order_conversation_id
      request->order_qual[d.seq].encntr_id = e.encntr_id
    with nocounter
  endif
end ;sGET_ORIG_ENCNTR_ID_FROM_ENCOUNTER
 
 
 
 
 
end
go
 

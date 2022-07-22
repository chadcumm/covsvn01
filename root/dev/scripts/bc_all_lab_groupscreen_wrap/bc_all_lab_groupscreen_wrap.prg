/************************************************************************************************************************
 
Source file name:  BC_ALL_LAB_GROUPSCREEN_WRAP.PRG
Object name:       GRPSCRNWRAP
 
Program purpose:   Transfusion Medicine Services Requisition Form
 
Executing from:    PowerChart
 
Special Notes:     This is a special wrapper program used to process Group and Screen orders. Current orders are sent to
                   program reqtransmed and future orders to program laboutpat.
 
*************************************************************************************************************************
Rev  Date         IssueTrak  Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  16-JAN-2018             Barry Wong             Created.
001  16-MAR-2018             Barry Wong             Modified to call new version of lab future requisition.
002  20-MAR-2018             Barry Wong             Change request->order_qual[].conversation_id to 0 as order is not
                                                    used by Oncology
003  08-NOV-2019  CST-55951  Barry Wong             Modified to process orders from Lab Day of Treatment powerplans.
                                                    Changed W2_debug_on to W2_debug_on
*************************************************************************************************************************/
 
drop program grpscrnwrap:dba go
create program grpscrnwrap:dba
 
;=====================================================
; DVDev DECLARED SUBROUTINES
;=====================================================
execute bc_all_all_std_routines
 
declare log_file = vc with constant("BC_ALL_LAB_GROUPSCREEN_WRAP.LOG")
declare W2_debug_on = i2 with protect
declare W2_trace_on = i2 with protect
declare cidx = i2 with protect  ;002
 
set W2_debug_on = 0
set W2_trace_on = 0
 
;=====================================================
; DEBUG - Free REQUEST record
;=====================================================
if (W2_debug_on = 1 )
  free set request
endif
 
;=====================================================
; DVDev Record structure
;=====================================================
record request(
  1 person_id = f8
  1 print_prsnl_id = f8
  1 order_qual[*]
    2 order_id = f8
    2 encntr_id = f8
    2 conversation_id = f8
  1 printer_name = c50
)
with persistscript
 
if (W2_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Entered program...", log_file)
endif
 
;=====================================================
; Declarations
;=====================================================
declare cvFuture = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
 
;=====================================================
; DEBUG - Setup REQUEST information for test order
;=====================================================
if (W2_debug_on = 1 )
  set request->person_id = 11852305.00
  set request->print_prsnl_id = 0.00
  set request->printer_name = " "
  set stat = alterlist(request->order_qual, 1)
  set request->order_qual[order_idx ].order_id = 289412233.00
  set request->order_qual[order_idx ].encntr_id = 96868138.00
  set request->order_qual[order_idx ].conversation_id = 0.00
endif
 
if (W2_trace_on = 1 )
  call ECHOJSON(request, "ECHOJSONW2A", 1)
endif
 
;=====================================================
; Determine order status and redirect processing
;=====================================================
 
if (request->person_id > 0.00 )
  if (size(request->order_qual, 5) > 0 )  ; Must have at least one order passed from PC
    if (sORDER_TYPE_EQUAL(request->order_qual[1 ].order_id, cvFuture ) = 1 )
 
      if (W2_trace_on = 1 )
        call sWRITE_MESSAGE_NOFLAG("Before future requisition call...", log_file)
      endif
;003 Start
      ; Backup REQUEST record
      set stat = copyrec(request, request_gs, 1 )
 
      if (W2_trace_on = 1 )
        call ECHOJSON(request, "ECHOJSONW2B", 1)
        call ECHOJSON(request_gs, "ECHOJSONW2C", 1)
      endif
 
      ; Recreate REQUEST record
      free set request
      record request(
        1 person_id = f8
        1 print_prsnl_id = f8
        1 order_qual[*]
          2 order_id = f8
          2 encntr_id = f8
          2 conversation_id = f8
        1 printer_name = c50
      )
      with persistscript
 
      ; Initialize level 1 fields
      set request->person_id = request_gs->person_id
      set request->print_prsnl_id = request_gs->print_prsnl_id
      set request->printer_name = request_gs->printer_name
      set stat = alterlist(request->order_qual, 1 )
 
      ; Process each Group and Screen order individually
      for (cidx = 1 to size(request_gs->order_qual, 5 ) )
        set request->order_qual[1 ].order_id = request_gs->order_qual[cidx ].order_id
        set request->order_qual[1 ].encntr_id = request_gs->order_qual[cidx ].encntr_id
        set request->order_qual[1 ].conversation_id = 0.00
        if (sLAB_DOT_ORDER(request->order_qual[1 ].order_id ) = 1 )
          ;Day of Treatment
          set request->order_qual[1 ].conversation_id = 2.00
        elseif (sLAB_DOT_ORDER(request->order_qual[1 ].order_id ) = 2 )
          ;Single & Multi-phase
          set request->order_qual[1 ].conversation_id = 3.00
        endif
 
        if (W2_trace_on = 1 )
          call ECHOJSON(request, "ECHOJSONW2D", 1)
        endif
 
  	    execute laboutpatw
      endfor
;003 End
	    ; Call Outpatient requisition
;001	    execute laboutpat
;003	    execute laboutpatw  ;001
 
      if (W2_trace_on = 1 )
        call sWRITE_MESSAGE_NOFLAG("After future requisition call...", log_file)
      endif
 
	  else
 
      if (W2_trace_on = 1 )
        call sWRITE_MESSAGE_NOFLAG("Before current requisition call...", log_file)
      endif
 
	    ; Call Group and Screen requisition
      execute reqtransmed
 
      if (W2_trace_on = 1 )
        call sWRITE_MESSAGE_NOFLAG("After current requisition call...", log_file)
      endif
 
	  endif
  endif
endif
 
if (W2_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Exiting program...", log_file)
endif
 
set W2_trace_on = 0
 
#exit_script
 
end go
 

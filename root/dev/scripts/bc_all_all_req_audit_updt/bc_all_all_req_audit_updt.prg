/***********************************************************************************************************************
Source Code File: BC_ALL_ALL_REQ_AUDIT_UPDT.PRG
Original Author:  Barry Wong
Date Written:     April 2020
 
Comments: Program
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  17-Apr-2020             Barry Wong             Created
001  27-Jul-2020  CST-52530  Jeremy Gunn            Added L14 - Lab - Transfusion Medicine Neonatal
002  30-Jul-2020  CST-92435  Barry Wong             Added A3 - Acute - Oral Diet
                                                    Added A4 - Acute - Nutrition Supplement
                                                    Added A5 - Acute - Enteral Feeding
                                                    Added A6 - Acute - Diet Communication
                                                    Added A7 - Acute - Fluid Restriction
***********************************************************************************************************************/
drop program bc_all_all_req_audit_updt go
create program bc_all_all_req_audit_updt
 
;-----------------------------------------
; Declaration
;-----------------------------------------
declare write_reqn_info(pReq_ID = c3,
                        pRqstRecd = vc(REF),
                        pOrdRecd = vc(REF),
                        pSiteRecd = vc(REF),
                        pPrinter2 = vc) = null with copy, persist
 
declare write_rqst_info(pReq_ID = c3,
                        pRqstRecd = vc(REF)) = null with copy, persist
 
;-----------------------------------------
; Subroutines
;-----------------------------------------
subroutine write_reqn_info(pReq_ID, pRqstRecd, pOrdRecd, pSiteRecd, pPrinter2 )
 
  declare t_encntr_id       = f8 with noconstant(0.00)
  declare t_loc_facility_cd = f8 with noconstant(0.00)
  declare t_site            = vc
  declare t_order_id        = f8 with noconstant(0.00)
  declare t_order_string    = vc
  declare t_person_id       = f8 with noconstant(0.00)
  declare t_prsnl_id        = f8 with noconstant(0.00)
  declare t_printer         = vc
  declare t_req_name        = vc
  declare t_trace_id        = c3
  declare audit_idx         = i4 with noconstant(0)
  declare write_flag        = i2
 
  set write_flag = 0
 
  ; Requisition Group #1
  if (pReq_ID = "A1"  or  ; Ambulatory - Referral
      pReq_ID = "A2"  or  ; Acute - Patient Pass with Meds
      pReq_ID = "D1"  or  ; Diet - Advanced Diet as Tolerated
      pReq_ID = "D2"  or  ; Diet - Fluid Restriction
      pReq_ID = "D3"  or  ; Diet - Infant Formula
      pReq_ID = "D4"  or  ; Diet - NPO
      pReq_ID = "D5"  or  ; Diet - Oral
      pReq_ID = "D6"  or  ; Diet - Supplement
      pReq_ID = "D7"  or  ; Diet - Tube Feeding
      pReq_ID = "L1"  or  ; Lab - Blood Gas
      pReq_ID = "L2"  or  ; Lab - Cord Blood
      pReq_ID = "L3"  or  ; Lab - Transfusion Medicine
      pReq_ID = "L4"  or  ; Lab - Group and Screen
      pReq_ID = "L5"  or  ; Lab - Conditional Transfusion
      pReq_ID = "L6"  or  ; Lab - TM AMB IVIg
      pReq_ID = "L7"  or  ; Lab - Pathology Surgical Request
      pReq_ID = "L8"  or  ; Lab - Pathology Oral Request
      pReq_ID = "L10" or  ; Lab - IV Transfusion
      pReq_ID = "L11" or  ; Lab - Venous Samples
      pReq_ID = "L13" or  ; Lab - Non-GYN Cytology
      pReq_ID = "L14" or  ; Lab - Transfusion Medicine Neonatal ;001
      pReq_ID = "P1"      ; Reg - Decease Notification
     )
 
    set t_person_id  = pRqstRecd->person_id
    set t_prsnl_id   = pRqstRecd->print_prsnl_id
    set t_printer    = pRqstRecd->printer_name
    set t_trace_id   = pReq_ID
 
    case (pReq_ID )
      of "A1":  set t_req_name = "Ambulatory - Referral"
      of "A2":  set t_req_name = "Acute - Patient Pass with Meds"
      of "D1":  set t_req_name = "Diet - Advanced Diet as Tolerated"
      of "D2":  set t_req_name = "Diet - Fluid Restriction"
      of "D3":  set t_req_name = "Diet - Infant Formula"
      of "D4":  set t_req_name = "Diet - NPO"
      of "D5":  set t_req_name = "Diet - Oral"
      of "D6":  set t_req_name = "Diet - Supplement"
      of "D7":  set t_req_name = "Diet - Tube Feeding"
      of "L1":  set t_req_name = "Lab - Blood Gas"
      of "L2":  set t_req_name = "Lab - Cord Blood"
      of "L3":  set t_req_name = "Lab - Transfusion Medicine"
      of "L4":  set t_req_name = "Lab - Group and Screen"
      of "L5":  set t_req_name = "Lab - Conditional Transfusion"
      of "L6":  set t_req_name = "Lab - TM AMB IVIg"
      of "L7":  set t_req_name = "Lab - Pathology Surgical Request"
      of "L8":  set t_req_name = "Lab - Pathology Oral Request"
      of "L10": set t_req_name = "Lab - IV Transfusion"
      of "L11": set t_req_name = "Lab - Venous Samples"
      of "L13": set t_req_name = "Lab - Non-GYN Cytology"
      of "L14": set t_req_name = "Lab - Transfusion Medicine Neonatal" ;001
      of "P1":  set t_req_name = "Reg - Decease Notification"
    endcase
 
    for (audit_idx = 1 to size(pOrdRecd->qual, 5) )
      if (audit_idx = 1 )
        set t_encntr_id    = pOrdRecd->qual[audit_idx ].encntr_id
        set t_site         = pOrdRecd->qual[audit_idx ].site
        set t_order_id     = pOrdRecd->qual[audit_idx ].order_id
        set t_order_string = trim(cnvtstring(pOrdRecd->qual[audit_idx ].order_id, 10, 0 ))
      else
        set t_order_string = concat(t_order_string, ",",
                                    trim(cnvtstring(pOrdRecd->qual[audit_idx ].order_id, 10, 0 )))
      endif
    endfor
    set write_flag = 1
  endif
 
  ; Requisition Group 2
  if (pReq_ID = "L9" )  ; Lab - Outpatient
    set t_encntr_id    = pOrdRecd->encntr_id
    set t_site         = pOrdRecd->site
    set t_person_id    = pRqstRecd->person_id
    set t_prsnl_id     = pRqstRecd->print_prsnl_id
    set t_printer      = pRqstRecd->printer_name
    set t_req_name     = "Lab - Outpatient"
    set t_trace_id     = pReq_ID
    for (audit_idx = 1 to size(pOrdRecd->qual, 5) )
      if (audit_idx = 1 )
        set t_order_id     = pOrdRecd->qual[audit_idx ].order_id
        set t_order_string = trim(cnvtstring(pOrdRecd->qual[audit_idx ].order_id, 10, 0 ))
      else
        set t_order_string = concat(t_order_string, ",",
                                    trim(cnvtstring(pOrdRecd->qual[audit_idx ].order_id, 10, 0 )))
      endif
    endfor
    set write_flag = 1
  endif
 
  ; Requisition Group #3
  if (pReq_ID = "L12" )  ; Lab - Bone Marrow Biopsy and Aspirate
    set t_encntr_id    = pOrdRecd->encntr_id
    set t_site         = pOrdRecd->site
    set t_order_id     = pOrdRecd->order_id
    set t_order_string = trim(cnvtstring(pOrdRecd->order_id, 10, 0 ))
    set t_person_id    = pRqstRecd->person_id
    set t_prsnl_id     = pRqstRecd->print_prsnl_id
    set t_printer      = pRqstRecd->printer_name
    set t_trace_id     = pReq_ID
 
    case (pReq_ID )
      of "L12":  set t_req_name = "Lab - Bone Marrow Biopsy and Aspirate"
    endcase
 
    for (audit_idx = 1 to size(pOrdRecd->qual, 5) )
      set t_order_string = concat(t_order_string, ",",
                                  trim(cnvtstring(pOrdRecd->qual[audit_idx ].order_id, 10, 0 )))
    endfor
    set write_flag = 1
  endif
 
  ; Requisition Group #4
  if (pReq_ID = "A3" or  ; Acute - Oral Diet
      pReq_ID = "A4" or  ; Acute - Nutrition Supplement
      pReq_ID = "A5" or  ; Acute - Enteral Feeding
      pReq_ID = "A6" or  ; Acute - Diet Communication
      pReq_ID = "A7" or  ; Acute - Fluid Restriction
      pReq_ID = "C1A" or ; Cardiology - Electrocardiogram (Copy 1)
      pReq_ID = "C1B" or ; Cardiology - Electrocardiogram (Copy 2)
      pReq_ID = "C2" or  ; Cardiology - Future
      pReq_ID = "C3" or  ; Cardiology - Holter, Graded Exercise, Cardiac Event
      pReq_ID = "M1"     ; MI - Future Requisition
     )
    set t_encntr_id    = pOrdRecd->encntr_id
    set t_site         = pOrdRecd->site
    set t_order_id     = pOrdRecd->order_id
    set t_order_string = trim(cnvtstring(pOrdRecd->order_id, 10, 0 ))
    set t_person_id    = pRqstRecd->person_id
    set t_prsnl_id     = pRqstRecd->print_prsnl_id
    set t_printer      = pRqstRecd->printer_name
    set t_trace_id     = pReq_ID
 
    case (pReq_ID )
      of "A3":  set t_req_name = "Acute - Oral Diet"
      of "A4":  set t_req_name = "Acute - Nutrition Supplement"
      of "A5":  set t_req_name = "Acute - Enteral Feeding"
      of "A6":  set t_req_name = "Acute - Diet Communication"
      of "A7":  set t_req_name = "Acute - Fluid Restriction"
      of "C1A": set t_req_name = "Cardiology - Electrocardiogram (Copy 1)",
                set t_trace_id = "C1"
      of "C1B": set t_req_name = "Cardiology - Electrocardiogram (Copy 2)",
                set t_printer  = pPrinter2
                set t_trace_id = "C1"
      of "C2":  set t_req_name = "Cardiology - Future"
      of "C3":  set t_req_name = "Cardiology - Holter, Graded Exercise, Cardiac Event"
      of "M1":  set t_req_name = "MI - Future Requisition"
    endcase
    set write_flag = 1
  endif
 
  ; Requisition Group #5
  if (pReq_ID = "C4" )   ; Cardiology - ECHO Cardiogram
    set t_encntr_id    = pSiteRecd->encntr_id
    set t_site         = pSiteRecd->site
    set t_order_id     = pOrdRecd->order_id
    set t_order_string = trim(cnvtstring(pOrdRecd->order_id, 10, 0 ))
    set t_person_id    = pRqstRecd->person_id
    set t_prsnl_id     = pRqstRecd->print_prsnl_id
    set t_printer      = pRqstRecd->printer_name
    set t_trace_id     = pReq_ID
    case (pReq_ID )
      of "C4":  set t_req_name = "Cardiology - ECHO Cardiogram"
    endcase
    set write_flag = 1
  endif
 
  ; Requisition Group #6
  if (pReq_ID = "R1" )  ; Med Management - Prescription
    set t_person_id    = pRqstRecd->person_id
    set t_prsnl_id     = pRqstRecd->print_prsnl_id
    set t_printer      = pRqstRecd->printer_name
    set t_trace_id     = pReq_ID
 
    case (pReq_ID )
      of "R1":  set t_req_name = "Med Management - Prescription"
    endcase
 
    if (size(pRqstRecd->order_qual, 5) > 0 )
      set t_encntr_id = pRqstRecd->order_qual[1].encntr_id
 
      ;Derive the site from the encounter (always available)
      select into "nl:"
        from encounter e,
             org_type_reltn otr,
             code_value cv
      plan e
      where e.encntr_id = t_encntr_id
        and e.active_ind = 1
 
      join otr
      where otr.organization_id = e.organization_id
        and otr.active_ind = 1
 
      join cv
      where cv.code_set = 278
        and cv.code_value = otr.org_type_cd
        and cv.display_key like "SITE*"
        and cv.active_ind = 1
 
      detail
        t_site = cv.description
 
      with nocounter, time=10
    endif
 
    for (audit_idx = 1 to size(pOrdRecd->med_info, 5) )
      if (audit_idx = 1 )
        set t_order_id     = pOrdRecd->med_info[audit_idx ].order_id
        set t_order_string = trim(cnvtstring(pOrdRecd->med_info[audit_idx ].order_id, 10, 0 ))
      else
        set t_order_string = concat(t_order_string, ",",
                                    trim(cnvtstring(pOrdRecd->med_info[audit_idx ].order_id, 10, 0 )))
      endif
    endfor
    set write_flag = 0
  endif
 
  ;-----------------------------------------------
  ; Insert row into CUST_REPT_REQNSTATS
  ;-----------------------------------------------
  if (write_flag = 1 )
    ; Truncate order string if it exceed VC255
    if (textlen(t_order_string) > 250 )
      set t_order_string = concat(substring(1, 250, t_order_string ), "..." )
    endif
 
    ; Get code value for site as derived from the encounter
    if (t_site not = null )
      select into "nl:"
             cv.code_value
        from code_value   cv
      plan cv
      where cv.code_set = 278
        and cv.display_key like "SITE*"
        and cv.description = t_site
      detail
        t_loc_facility_cd = cv.code_value
      with nocounter
    endif
 
    insert into cust_rept_reqnstats crr
       set crr.print_dt_tm     = sysdate
          ,crr.reqn_name       = t_req_name
          ,crr.reqn_trace_id   = t_trace_id
          ,crr.loc_facility_cd = t_loc_facility_cd
          ,crr.site            = t_site
          ,crr.person_id       = t_person_id
          ,crr.encntr_id       = t_encntr_id
          ,crr.print_prsnl_id  = t_prsnl_id
          ,crr.printer_name    = t_printer
          ,crr.order_id        = t_order_id
          ,crr.order_string    = t_order_string
    with nocounter
    commit
  endif
end ;write_reqn_info
 
;---------------------------------------------------------------------------------
subroutine write_rqst_info(pReq_ID, pRqstRecd )
 
  declare t_encntr_id       = f8 with noconstant(0.00)
  declare t_loc_facility_cd = f8 with noconstant(0.00)
  declare t_site            = vc
  declare t_order_id        = f8 with noconstant(0.00)
  declare t_order_string    = vc
  declare t_person_id       = f8 with noconstant(0.00)
  declare t_prsnl_id        = f8 with noconstant(0.00)
  declare t_printer         = vc
  declare t_req_name        = vc
  declare t_trace_id        = c3
  declare audit_idx         = i4 with noconstant(0)
 
  set t_person_id  = pRqstRecd->person_id
  set t_prsnl_id   = pRqstRecd->print_prsnl_id
  set t_printer    = pRqstRecd->printer_name
  set t_trace_id   = pReq_ID
  set t_site       = "* Requisition triggered; no qualifying orders*"
 
  case (pReq_ID )
    of "A1":  set t_req_name = "Ambulatory - Referral"
    of "A2":  set t_req_name = "Acute - Patient Pass with Meds"
    of "A3":  set t_req_name = "Acute - Oral Diet"
    of "A4":  set t_req_name = "Acute - Nutrition Supplement"
    of "A5":  set t_req_name = "Acute - Enteral Feeding"
    of "A6":  set t_req_name = "Acute - Diet Communication"
    of "A7":  set t_req_name = "Acute - Fluid Restriction"
    of "C1":  set t_req_name = "Cardiology - Electrocardiogram",
    of "C2":  set t_req_name = "Cardiology - Future"
    of "C3":  set t_req_name = "Cardiology - Holter, Graded Exercise, Cardiac Event"
    of "C4":  set t_req_name = "Cardiology - ECHO Cardiogram"
    of "D1":  set t_req_name = "Diet - Advanced Diet as Tolerated"
    of "D2":  set t_req_name = "Diet - Fluid Restriction"
    of "D3":  set t_req_name = "Diet - Infant Formula"
    of "D4":  set t_req_name = "Diet - NPO"
    of "D5":  set t_req_name = "Diet - Oral"
    of "D6":  set t_req_name = "Diet - Supplement"
    of "D7":  set t_req_name = "Diet - Tube Feeding"
    of "L1":  set t_req_name = "Lab - Blood Gas"
    of "L2":  set t_req_name = "Lab - Cord Blood"
    of "L3":  set t_req_name = "Lab - Transfusion Medicine"
    of "L4":  set t_req_name = "Lab - Group and Screen"
    of "L5":  set t_req_name = "Lab - Conditional Transfusion"
    of "L6":  set t_req_name = "Lab - TM AMB IVIg"
    of "L7":  set t_req_name = "Lab - Pathology Surgical Request"
    of "L8":  set t_req_name = "Lab - Pathology Oral Request"
    of "L9":  set t_req_name = "Lab - Outpatient"
    of "L10": set t_req_name = "Lab - IV Transfusion"
    of "L11": set t_req_name = "Lab - Venous Samples"
    of "L12": set t_req_name = "Lab - Bone Marrow Biopsy and Aspirate"
    of "L13": set t_req_name = "Lab - Non-GYN Cytology"
    of "L14": set t_req_name = "Lab - Transfusion Medicine Neonatal" ;001
    of "M1":  set t_req_name = "MI - Future Requisition"
    of "P1":  set t_req_name = "Reg - Decease Notification"
    of "R1":  set t_req_name = "Med Management - Prescription"
  endcase
 
  for (audit_idx = 1 to size(pRqstRecd->order_qual, 5) )
    if (audit_idx = 1 )
      set t_encntr_id    = pRqstRecd->order_qual[audit_idx ].encntr_id
      set t_order_id     = pRqstRecd->order_qual[audit_idx ].order_id
      set t_order_string = trim(cnvtstring(pRqstRecd->order_qual[audit_idx ].order_id, 10, 0 ))
    else
      set t_order_string = concat(t_order_string, " ",
                                  trim(cnvtstring(pRqstRecd->order_qual[audit_idx ].order_id, 10, 0 )))
    endif
  endfor
 
  ; Truncate order string if it exceed VC255
  if (textlen(t_order_string) > 250 )
    set t_order_string = concat(substring(1, 250, t_order_string ), "..." )
  endif
 
  insert into cust_rept_reqnstats crr
     set crr.print_dt_tm     = sysdate
        ,crr.reqn_name       = t_req_name
        ,crr.reqn_trace_id   = t_trace_id
        ,crr.loc_facility_cd = t_loc_facility_cd
        ,crr.site            = t_site
        ,crr.person_id       = t_person_id
        ,crr.encntr_id       = t_encntr_id
        ,crr.print_prsnl_id  = t_prsnl_id
        ,crr.printer_name    = t_printer
        ,crr.order_id        = t_order_id
        ,crr.order_string    = t_order_string
  with nocounter
  commit
end ;write_rqst_info
 
end go
 
 

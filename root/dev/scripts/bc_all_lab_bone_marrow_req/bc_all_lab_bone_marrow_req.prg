/************************************************************************************************************************
 
Source file name:  BC_ALL_LAB_BONE_MARROW_REQ.PRG
Object name:       LABBONEMARR
 
Program purpose:   Patient pathology surgical requisition template
 
Executing from:    PowerChart
 
Special Notes:     This requisition is used for the BM Biopsy and Aspirate order plus any other secondary orders. The
                   secondary order are reported in a table so these will be formatted in the DETAIL section in the
                   layout.
 
*************************************************************************************************************************
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  28-AUG-2019  CST-50948  Barry Wong             Created.
001  03-OCT-2019  CST-50948  Barry Wong             Changed OEF source for Reason for Testing and suppress Clinical HX OEF
002  10-OCT-2019  CST-50948  Barry Wong             Changed OEF source for Relevant Clinical History, Reason for Testing
                                                    and Special Instructions to Lab
003  11-OCT-2019  CST-50948  Barry Wong             Changed OEF source for Additional Information
004  18-OCT-2019  CST-50948  Jeremy Gunn            Modified cv200_BMAspirateAndBiopsy
005  04-NOV-2019  CST-50948  Jeremy Gunn            Re-activated cv16449_ReasonForTesting
006  04-NOV-2019  CST-50948  Jeremy Gunn            Added code to pull in other orders from powerplan
007  12-NOV-2019  CST-50948  Jeremy Gunn            Modified Special Instructions code value variable
008  13-NOV-2019  CST-50948  Jeremy Gunn            Modified Scheduling details logic
009  27-FEB-2020  CST-79453  Barry Wong             Replaced Scheduling OEF NOTESTOSCHEDULER with SPECIALINSTRUCTIONS
010  02-APR-2020  CST-80742  Barry Wong             Add logic to bypass BM requisitions which are triggered by an
                                                    Activate action (status changes from Future to Ordered)
011  03-APR-2020  CST-76159  Barry Wong             Added attending provider information
012  22-APR-2020  CST-37379  Barry Wong             Added requisition audit logic
*************************************************************************************************************************/
 
drop program labbonemarr:dba go
create program labbonemarr:dba
 
;=====================================================
; DVDev DECLARED SUBROUTINES
;=====================================================
execute bc_all_all_std_routines
execute bc_all_all_date_routines
execute bc_all_all_req_prt_check
execute bc_all_all_req_audit_updt ;012
 
declare log_file = vc with constant("BC_ALL_LAB_BONE_MARROW_REQ.LOG")
set L12_debug_on = 0
set L12_trace_on = 0
 
if (L12_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Entered program...", log_file)
endif
;=====================================================
; DEBUG - Free REQUEST record
;=====================================================
if (L12_debug_on = 1 )
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
 
;=====================================================
; DEBUG - Setup REQUEST information for test order
;=====================================================
if (L12_debug_on = 1 )
  set request->person_id = 20463042.00
  set request->print_prsnl_id = 0.00
  set request->printer_name = "750_7thflr_l1"
  set stat = alterlist(request->order_qual, 1)  ;This is set up for 4 orders
  set request->order_qual[1].order_id = 484714559.00
  set request->order_qual[1].encntr_id = 110278071.00
  set request->order_qual[1].conversation_id = 484714615.00
endif
 
if (L12_trace_on = 1 )
  call ECHOJSON(request, "ECHOJSONL12A", 1 )
endif
 
;=====================================================
; DVDev Record structure
;=====================================================
free set orders_rec
record orders_rec(
  1 spoolout_ind = i2
  1 perform_location       = f8
  1 printer_reassigned     = i2
  ; Header information
  1 order_id               = f8
  1 encntr_id              = f8
  1 encntr_num             = vc
  1 site                   = vc
  1 nurseunit              = vc
  1 room                   = vc
  1 bed                    = vc
  1 ordering_md            = vc
  1 ordering_md_msp        = vc
  1 attending_md           = vc  ;011
  1 attending_md_msp       = vc  ;011
  1 order_by_name          = vc
  1 order_by_name_msp      = vc
  1 family_md              = vc
  1 family_md_msp          = vc
  1 copy_to_1              = vc
  1 copy_to_1_msp          = vc
  1 copy_to_2              = vc
  1 copy_to_2_msp          = vc
  1 copy_to_3              = vc
  1 copy_to_3_msp          = vc
  ; Primary order (BM Biopsy & Aspirate )
  1 order_mnemonic         = vc
  1 order_dttm             = vc
  1 scheduling_details     = vc
  1 clinical_history       = vc
  1 reason_for_testing     = vc
  1 priority               = vc
  1 special_instructions   = vc
  ; Supplemental orders
  1 qual[*]
    2 order_id            = f8
    2 order_mnemonic      = vc
    2 additional_info     = vc
)
with persistscript
 
%i CUST_SCRIPT:bc_all_all_requisition_patrecd.inc
 
;=====================================================
; Constant Declarations
;=====================================================
declare cv6004_Future = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare cv319_FinNbr  = f8 with protect, constant(uar_get_code_by("MEANING", 319, "FIN NBR" ) )
declare cv6003_Order  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER" ) )
declare cv331_PCP     = f8 with protect, constant(uar_get_code_by("MEANING" ,331 ,"PCP" ) )
declare cv320_MSP     = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 320, "MSP"))
declare cv6004_Future  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE" ))
declare cv14281_OnHold = f8 with protect, constant(uar_get_code_by("MEANING",    14281, "ONHOLD" ))
declare cvAttend_MD = f8 with protect, constant(uar_get_code_by("MEANING", 333, "ATTENDDOC" ) )  ;011
 
; Primary Order processed by this requisition
declare cv200_BMAspirateAndBiopsy = f8 with protect,
              ;004 constant(uar_get_code_by("DISPLAYKEY", 200, "SCHEDULEBONEMARROWBIOPSYANDASPIRATE" ) )
              constant(uar_get_code_by("DISPLAYKEY", 200, "BONEMARROWBIOPSYANDASPIRATEPROCEDUR" ) );004
;=====================================================
; Order Detail fields to be extracted
;=====================================================
declare cv16449_CCProvider            = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "CCPROVIDER" ) )
declare cv16449_CCProvider2           = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "CCPROVIDER2" ) )
declare cv16449_CCProvider3           = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "CCPROVIDER3" ) )
declare cv16449_ReqStartDttm          = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "REQUESTED START DATE/TIME" ) )
declare cv16449_SchedulingLocationsNonRadiology = f8 with protect,
                constant(uar_get_code_by("DISPLAY_KEY", 16449, "SCHEDULINGLOCATIONSNONRADIOLOGY" ) )
; Scheduling Priority
declare cv16449_SchPriority           = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "SCHPRIORITY" ) )
;009 declare cv16449_NotesToScheduler      = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "NOTESTOSCHEDULER" ) )
declare cv16449_ClinicalFeatures      = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "CLINICALFEATURES" ) )
declare cv16449_ReasonForTesting      = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "REASONFORTESTING" ) ) ;005
;002 declare cv16449_ReasonForExam         = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "REASONFOREXAM" ) )  ;001
; Resulting Priority
declare cv16449_Priority              = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "PRIORITY" ) )
declare cv16449_SpecialInstructions   = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "SPECIALINSTRUCTIONS" ) )
;003 declare cv16449_AdditionalInformation = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "ADDITIONALINFORMATION" ) )
declare cv16449_LabRequisitionNote = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "LABREQUISITIONNOTE" ) )  ;003
 
;002 Start
declare cv16449_OtherClinicalInfo     = f8 with protect, constant(uar_get_code_by("DISPLAY_KEY", 16449, "OTHERCLINICALINFO" ) )
declare cv16449_SpecialInstructionsWhenToProceed = f8 with protect,
;007                constant(uar_get_code_by("DISPLAY_KEY", 16449, "SPECIALINSTRUCTIONSWHENTOPROCEED" ) )
                constant(uar_get_code_by("DISPLAY_KEY", 16449, "SPECIALINSTRUCTIONSAMBPROC" ) ) ;007
;002 End
 
;=====================================================
; Variable Declarations
;=====================================================
declare output_printer = C50
declare order_idx = i4
declare order_num = i4
declare current_catalog_cd = f8
declare current_order_name = vc
declare BM_Primary_Order_Found = i2
;008 declare sch_detail_string = vc
declare sch_detail_strg = vc ;008
declare sch_location_strg = vc
declare sch_priority_strg = vc
declare sch_notes_strg = vc
 
; Variables used to save MSP# for CC'ed providers
declare ccProvider1_ID = f8 with noconstant(0.00)
declare ccProvider2_ID = f8 with noconstant(0.00)
declare ccProvider3_ID = f8 with noconstant(0.00)
declare requisition_printed = i2  ;012
 
set requisition_printed = 0       ;012
set output_printer = request->printer_name
 
;=====================================================
; Get Patient information
;=====================================================
%i CUST_SCRIPT:bc_all_all_requisition_patinfo.inc
 
;=====================================================
; Verify that BM Biopsy and Aspirate order exists
; before processing
;=====================================================
set BM_Primary_Order_Found = 0;
 
for (order_idx = 1 to size(request->order_qual, 5) )
  select into "nl:"
    from orders   o
   where o.order_id = request->order_qual[order_idx ].order_id
     and o.catalog_cd = cv200_BMAspirateAndBiopsy
 
  detail
    if (o.order_status_cd = cv6004_Future and
        o.dept_status_cd = cv14281_OnHold )
      BM_Primary_Order_Found = 1
    endif
 
  with nocounter
endfor
 
;Bypass requisition if no BM procedure order found
if (BM_Primary_Order_Found = 0 )
  go to exit_script
endif
 
;006 Retrieve other orders in Powerplan
declare vOrdSize = I4
 
set vOrdSize = 1
 
SELECT INTO "NL:"
FROM
  ACT_PW_COMP   A
  , ACT_PW_COMP   A1
  , ORDERS O
 
PLAN A
WHERE A.parent_entity_id = request->order_qual[1].order_id
  and a.parent_entity_name = "ORDERS"
  and a.active_ind = 1
 
JOIN A1
WHERE A1.pathway_id = a.pathway_id
  and a1.parent_entity_name = "ORDERS"
  and A1.REQUIRED_IND = 0
 
JOIN O
WHERE O.order_id = a1.parent_entity_id
  and o.active_ind = 1
DETAIL
  vOrdSize = vOrdSize + 1
  stat = alterlist(request->order_qual,vOrdSize)
  request->order_qual[vOrdSize].order_id = o.order_id
  request->order_qual[vOrdSize].encntr_id = o.encntr_id
  request->order_qual[vOrdSize].conversation_id = 0.00
WITH NOCOUNTER, SEPARATOR=" ", TIME=30, FORMAT
 
;=====================================================
; Process orders
;=====================================================
if (request->person_id > 0.00 )
  if (size(request->order_qual, 5) > 0 )  ; Must have at least one order passed from PC
    set orders_rec->spoolout_ind = 1
 
    ;============================================
    ; Initialize orders_rec structure
    ;============================================
    set orders_rec->order_id             = 0.00
    set orders_rec->encntr_id            = 0.00
    set orders_rec->encntr_num           = ""
    set orders_rec->site                 = ""
    set orders_rec->nurseunit            = ""
    set orders_rec->room                 = ""
    set orders_rec->bed                  = ""
    set orders_rec->ordering_md          = ""
    set orders_rec->ordering_md_msp      = ""
    set orders_rec->attending_md         = ""  ;011
    set orders_rec->attending_md_msp     = ""  ;011
    set orders_rec->order_by_name        = ""
    set orders_rec->order_by_name_msp    = ""
    set orders_rec->family_MD            = ""
    set orders_rec->family_MD_msp        = ""
    set orders_rec->copy_to_1            = ""
    set orders_rec->copy_to_1_msp        = ""
    set orders_rec->copy_to_2            = ""
    set orders_rec->copy_to_2_msp        = ""
    set orders_rec->copy_to_3            = ""
    set orders_rec->copy_to_3_msp        = ""
    ; Procedure order fields
    set orders_rec->order_mnemonic       = ""
    set orders_rec->order_dttm           = ""
    set orders_rec->scheduling_details   = ""
    set orders_rec->clinical_history     = ""
    set orders_rec->reason_for_testing   = ""
    set orders_rec->priority             = ""
    set orders_rec->special_instructions = ""
 
    ;=====================================================
    ; Allocate initial requested test record
    ;=====================================================
    set stat = alterlist(orders_rec->qual, 1 )
    set orders_rec->qual[1 ].order_id        = 0.00
    set orders_rec->qual[1 ].order_mnemonic  = ""
    set orders_rec->qual[1 ].additional_info = ""
    set order_num = 1
 
    ;=====================================================
    ; Get/load information from each order
    ;=====================================================
    for (order_idx = 1 to size(request->order_qual, 5) )
      ;=====================================================
      ; Process if order is not cancelled, completed or
      ; discontinued (1,1,1)
      ;=====================================================
      if (sREQ_BoneMarrow(request->order_qual[order_idx ].order_id, request->print_prsnl_id ) = 1 )
        ; Determine if the current order is the procedure order
        set current_catalog_cd = 0.00
        select into "nl:"
               o.order_id
          from orders o
        where o.order_id = request->order_qual[order_idx ].order_id
        detail
          current_catalog_cd = o.catalog_cd
          current_order_name = o.order_mnemonic
        with nocounter
 
        ; Initialize orders record
        if (current_catalog_cd = cv200_BMAspirateAndBiopsy )
          ; Assign originating encounter ID if required
          if (request->order_qual[order_idx ].encntr_id = 0.00 )
            set request->order_qual[order_idx ].encntr_id = sGET_ORIG_ENCNTR_ID(request->order_qual[order_idx ].order_id )
          endif
          ; Initialize procedure order fields
          set orders_rec->order_id       = request->order_qual[order_idx].order_id
          set orders_rec->encntr_id      = request->order_qual[order_idx].encntr_id
          set orders_rec->order_mnemonic = current_order_name
        else
          ; Initialize requested order fields
          set orders_rec->qual[order_num ].order_id        = request->order_qual[order_idx].order_id
          set orders_rec->qual[order_num ].order_mnemonic  = current_order_name
          set orders_rec->qual[order_num ].additional_info = ""
;006          set order_num = order_num + 1
;006          set stat = alterlist(orders_rec->qual, order_num )
 
          ; Get additional information for the requested order
          select into "nl:"
                 OEF_ID = od.oe_field_id,
                 OEF_Value = od.oe_field_display_value,
                 OEF_Field_Value = od.oe_field_value,
                 OEF_Date_Value = od.oe_field_dt_tm_value
            from order_detail od
 
          plan od
          where od.order_id = orders_rec->qual[order_num ].order_id
;003            and od.oe_field_id = cv16449_AdditionalInformation
            and od.oe_field_id = cv16449_LabRequisitionNote  ;003
 
          order by od.oe_field_id,
                   od.action_sequence desc
 
          head od.oe_field_id
            current_field_id = od.oe_field_id
            current_act_seq = od.action_sequence
 
          detail
            if (od.oe_field_id = current_field_id and od.action_sequence = current_act_seq )
              orders_rec->qual[order_num ].additional_info = trim(OEF_Value, 3 )
            endif
          with nocounter
 
          set order_num = order_num + 1 ;006
          set stat = alterlist(orders_rec->qual, order_num ) ;006
 
        endif
 
        ; Extract remaining fields from the procedure order
        if (current_catalog_cd = cv200_BMAspirateAndBiopsy )
          ;=====================================================
          ; Get information from the encounter
          ;=====================================================
          select into "nl:"
            from encounter e
               , encntr_alias ea
               , org_type_reltn otr
               , code_value cv
 
          plan e
          where e.encntr_id = orders_rec->encntr_id
            and e.active_ind = 1
          join ea
          where ea.encntr_id = e.encntr_id
            and ea.encntr_alias_type_cd = cv319_FinNbr
            and ea.active_ind = 1
          join otr
          where otr.organization_id = e.organization_id
            and otr.active_ind = 1
          join cv
          where cv.code_set = 278
            and cv.code_value = otr.org_type_cd
            and cv.display_key like "SITE*"
            and cv.active_ind = 1
 
          detail
            orders_rec->encntr_num = ea.alias
            orders_rec->site = cv.description
            orders_rec->nurseunit = uar_get_code_display(e.loc_nurse_unit_cd )
            orders_rec->room = uar_get_code_display(e.loc_room_cd )
            orders_rec->bed = uar_get_code_display(e.loc_bed_cd )
          with nocounter
 
          ;=====================================================
          ; Get Ordering Personnel names
          ;=====================================================
          select into "nl:"
            from order_action oa
               , prsnl p1
               , prsnl p2
               , prsnl_alias pa1
               , prsnl_alias pa2
 
            plan oa
            where oa.order_id = orders_rec->order_id
              and oa.action_type_cd = cv6003_Order
              and oa.action_sequence = (select max(oa1.action_sequence)
                                          from order_action oa1
                                         where oa1.order_id = oa.order_id
                                           and oa1.action_type_cd = oa.action_type_cd )
            join p1
            where p1.person_id = outerjoin(oa.order_provider_id )
            join p2
            where p2.person_id = outerjoin(oa.action_personnel_id )
            join pa1
            where pa1.person_id = outerjoin(p1.person_id )
              and pa1.prsnl_alias_type_cd = outerjoin(cv320_MSP )
              and pa1.active_ind = outerjoin(1 )
            join pa2
            where pa2.person_id = outerjoin(p2.person_id )
              and pa2.prsnl_alias_type_cd = outerjoin(cv320_MSP )
              and pa2.active_ind = outerjoin(1 )
 
            detail
              orders_rec->ordering_md = p1.name_full_formatted
              orders_rec->order_by_name = p2.name_full_formatted
              orders_rec->ordering_md_msp = pa1.alias
              orders_rec->order_by_name_msp = pa2.alias
            with nocounter
;011 Start
 
          ;=====================================================
          ; Get Attending Provider
          ;=====================================================
          select into "nl:"
            from encntr_prsnl_reltn epr
               , prsnl p1
               , prsnl_alias pa1
 
            plan epr
            where epr.encntr_id = orders_rec->encntr_id
              and epr.encntr_prsnl_r_cd = cvAttend_MD
              and epr.end_effective_dt_tm > sysdate
              and epr.active_ind = 1
 
          join p1
          where p1.person_id = outerjoin(epr.prsnl_person_id )
 
          join pa1
          where pa1.person_id = outerjoin(p1.person_id )
            and pa1.prsnl_alias_type_cd = outerjoin(cv320_MSP )
            and pa1.active_ind = outerjoin(1 )
 
          detail
            orders_rec->attending_md = p1.name_full_formatted
            orders_rec->attending_md_msp = pa1.alias
 
          with nocounter, time=10
;011 End
 
          ;=====================================================
          ; Get family physician
          ;=====================================================
          select into "nl:"
                 fam_phy_name = pr.name_full_formatted
            from person_prsnl_reltn ppr
               , prsnl pr
               , prsnl_alias pa
 
          plan ppr
          where ppr.person_id = outerjoin(request->person_id )
            and ppr.active_ind = outerjoin(1)
            and ppr.person_prsnl_r_cd = outerjoin(cv331_PCP )
            and ppr.end_effective_dt_tm > outerjoin(sysdate )
          join pr
          where pr.person_id = outerjoin(ppr.prsnl_person_id )
            and pr.active_ind = outerjoin(1)
            and pr.end_effective_dt_tm > outerjoin(sysdate )
            and pr.physician_ind = outerjoin(1)
          join pa
          where pa.person_id = outerjoin(pr.person_id )
            and pa.prsnl_alias_type_cd = outerjoin(cv320_MSP )
            and pa.active_ind = outerjoin(1 )
 
          detail
            orders_rec->family_MD = fam_phy_name
            orders_rec->family_MD_msp = pa.alias
          with nocounter
 
          ;=====================================================
          ; Get Order details
          ;=====================================================
          select into "nl:"
                 OEF_ID = od.oe_field_id
            from order_detail od
 
          plan od
          where od.order_id = orders_rec->order_id
            and od.oe_field_id in (cv16449_CCProvider,
                                   cv16449_CCProvider2,
                                   cv16449_CCProvider3,
                                   cv16449_ReqStartDttm,
;001                                   cv16449_ClinicalFeatures,
;001                                   cv16449_ReasonForTesting,
;002                                   cv16449_ReasonForExam,   ;001
                                   cv16449_Priority,
                                   cv16449_OtherClinicalInfo,   ;002
                                   cv16449_SpecialInstructionsWhenToProceed,  ;002
                                   ;005 cv16449_SpecialInstructions
                                   cv16449_ReasonForTesting ;005
                                  )
          order by od.oe_field_id,
                   od.action_sequence desc
 
          head od.oe_field_id
            current_field_id = od.oe_field_id
            current_act_seq = od.action_sequence
 
          detail
            if (od.oe_field_id = current_field_id and od.action_sequence = current_act_seq )
              case (od.oe_field_id )
                of cv16449_CCProvider          : orders_rec->copy_to_1 = trim(od.oe_field_display_value, 3 ),
                                                 ccProvider1_ID = od.oe_field_value
                of cv16449_CCProvider2         : orders_rec->copy_to_2 = trim(od.oe_field_display_value, 3 ),
                                                 ccProvider2_ID = od.oe_field_value
                of cv16449_CCProvider3         : orders_rec->copy_to_3 = trim(od.oe_field_display_value, 3 ),
                                                 ccProvider3_ID = od.oe_field_value
                of cv16449_ReqStartDttm        : orders_rec->order_dttm = od.oe_field_display_value
;001                of cv16449_ClinicalFeatures    : orders_rec->clinical_history = trim(od.oe_field_display_value, 3 )
;001                of cv16449_ReasonForTesting    : orders_rec->reason_for_testing = trim(od.oe_field_display_value, 3 )
                of cv16449_OtherClinicalInfo   : orders_rec->clinical_history = trim(od.oe_field_display_value, 3 )
;002                of cv16449_ReasonForExam       : orders_rec->reason_for_testing = trim(od.oe_field_display_value, 3 )  ;001
                ;005 of cv16449_SpecialInstructions : orders_rec->reason_for_testing = trim(od.oe_field_display_value, 3 )      ;002
                of cv16449_ReasonForTesting    : orders_rec->reason_for_testing = trim(od.oe_field_display_value, 3 )      ;005
                of cv16449_Priority            : orders_rec->priority = trim(od.oe_field_display_value, 3 )
;002                of cv16449_SpecialInstructions : orders_rec->special_instructions = trim(od.oe_field_display_value, 3 )
                of cv16449_SpecialInstructionsWhenToProceed : orders_rec->special_instructions = trim(od.oe_field_display_value, 3 ) ;002
              endcase
            endif
          with nocounter
 
          ;=====================================================
          ; Get Scheduling details
          ;=====================================================
          set sch_detail_strg = ""
          set sch_location_strg = ""
          set sch_priority_strg = ""
          set sch_notes_strg = ""
 
          select into "nl:"
                 label_text = off.label_text
          	   , detail_value = od.oe_field_display_value
 
          from orders   o
             , order_detail   od
             , oe_format_fields   off
 
 
            plan o
            ;008 where o.order_id = orders_rec->qual[order_num ].order_id
            where o.order_id = orders_rec->order_id ;008
 
            join od
            where od.order_id = o.order_id
              and od.oe_field_id in (cv16449_SchedulingLocationsNonRadiology,
                                     cv16449_SchPriority,
;009                                     cv16449_NotesToScheduler
                                     cv16449_SpecialInstructions  ;009
                                    )
 
            join off
            where off.oe_format_id = o.oe_format_id
              and off.oe_field_id = od.oe_field_id
              and off.updt_cnt = (select max(off1.updt_cnt)
                                    from oe_format_fields   off1
                                   where off1.oe_format_id = off.oe_format_id
                                     and off1.oe_field_id = off.oe_field_id )
 
          order by od.oe_field_id,
                   od.action_sequence desc
 
          head od.oe_field_id
            current_field_id = od.oe_field_id
            current_act_seq = od.action_sequence
 
          detail
            if (od.oe_field_id = current_field_id and od.action_sequence = current_act_seq )
              case (od.oe_field_id )
                of cv16449_SchedulingLocationsNonRadiology : sch_location_strg = concat(trim(label_text ), ": ", trim(detail_value ) )
                of cv16449_SchPriority                     : sch_priority_strg = concat(trim(label_text ), ": ", trim(detail_value ) )
;009                of cv16449_NotesToScheduler                : sch_notes_strg = concat(trim(label_text ), ": ", trim(detail_value ) )
                of cv16449_SpecialInstructions             : sch_notes_strg = concat(trim(label_text ), ": ", trim(detail_value ) )  ;009
              endcase
            endif
 
          with nocounter
 
          ;008
          set sch_detail_strg = trim(concat(nullval(concat(sch_location_strg,", "),""),nullval(concat(sch_priority_strg,", "),""),nullval(sch_notes_strg,"")),3)
          if (substring(textlen(sch_detail_strg),textlen(sch_detail_strg)-1,sch_detail_strg) = ",")
            set sch_detail_strg = substring(1,textlen(sch_detail_strg)-1,sch_detail_strg)
          endif
          set orders_rec->scheduling_details = sch_detail_strg
 
;008 Start
;          if (sch_location_strg not = null )
;            if (sch_detail_strg not = null )
;              set sch_detail_strg = sch_location_strg
;            else
;              set sch_detail_strg = concat(sch_detail_strg, ", ", sch_location_strg )
;            endif
;          endif
;          if (sch_priority_strg not = null )
;            if (sch_detail_strg not = null )
;              set sch_detail_strg = sch_priority_strg
;            else
;              set sch_detail_strg = concat(sch_detail_strg, ", ", sch_priority_strg )
;            endif
;          endif
;          if (sch_notes_strg not = null )
;            if (sch_detail_strg not = null )
;              set sch_detail_strg = sch_notes_strg
;            else
;              set sch_detail_strg = concat(sch_detail_strg, ", ", sch_notes_strg )
;            endif
;          endif
;          if (sch_detail_strg not = null )
;            set orders_rec->scheduling_details = sch_detail_strg
;          endif
;008 Finish
 
           ;=====================================================
          ; Get cc'ed provider MSP numbers
          ;=====================================================
          if (ccProvider1_ID > 0.00 )
            set orders_rec->copy_to_1_msp = sGET_PRSNL_ALIAS(ccProvider1_ID, cv320_MSP )
          endif
          if (ccProvider2_ID > 0.00 )
            set orders_rec->copy_to_2_msp = sGET_PRSNL_ALIAS(ccProvider2_ID, cv320_MSP )
          endif
          if (ccProvider3_ID > 0.00 )
            set orders_rec->copy_to_3_msp = sGET_PRSNL_ALIAS(ccProvider3_ID, cv320_MSP )
          endif
 
        endif ;Extract from procedure order
      endif
    endfor
 
    ;=====================================================
    ; Resize order record after unwanted orders are
    ; bypassed
    ;=====================================================
 
    if (order_num > 1 )
      set stat = alterlist(orders_rec->qual, (order_num - 1) )
    endif
 
  endif
endif
 
if (L12_trace_on = 1 )
  call ECHOJSON(orders_rec, "ECHOJSONL12C", 1 )
endif
 
;=====================================================
; Call the layout to display the requisition if
; requisition is associated with a patient
;=====================================================
if (orders_rec->spoolout_ind = 1 and order_num > 0 and L12_debug_on = 0 )
  if (L12_trace_on = 1 )
    call sWRITE_MESSAGE_NOFLAG("Before layout call...", log_file)
    call sWRITE_MESSAGE_NOFLAG(output_printer, log_file)
  endif
 
  execute bc_all_lab_bone_marrow_req_lyt value(output_printer )
  call write_reqn_info("L12", request, orders_rec, orders_rec, "" )        ;012
  set requisition_printed = 1                                              ;012
 
  if (L12_trace_on = 1 )
    call sWRITE_MESSAGE_NOFLAG("After layout call...", log_file)
  endif
endif
 
#exit_script
 
; Write an audit record if a requisition did not print
if (requisition_printed = 0 and L12_debug_on = 0 )  ;012
  call write_rqst_info("L12", request )             ;012
endif                                               ;012
 
set L12_trace_on = 0
 
end go
 

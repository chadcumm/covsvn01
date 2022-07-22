/************************************************************************************************************************
 
Source file name:  BC_ALL_AMB_REFERRAL_REQ.PRG
Object name:       AMBREFERREQ
 
Program purpose:   Ambulatory Referral Requisition Form
 
Executing from:    PowerChart
 
Special Notes:
 
*************************************************************************************************************************
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  03-Jun-2020  CST-8968   Barry Wong             New version.
001  14-Jun-2020  CST-74815  Barry Wong             Changed the order dttm from order_dt_tm to action_dt_tm
002  11-Aug-2020  CST-96763  Barry Wong             Added call to sCURPROG_TRACE
003  01-Sep-2020  CST-97756  Barry Wong             Added Requested Provider
004  03-Sep-2020  CST-96763  Barry Wong             Modify logic to bypass duplicate printing
005  21-Oct-2020  CST-103418 Barry Wong             Modified logic to print each order on a separate requisition
*************************************************************************************************************************/
 
drop program cmcreqtest2:dba go
create program cmcreqtest2:dba
 
;=====================================================
; DVDev DECLARED SUBROUTINES
;=====================================================
execute bc_all_all_std_routines
execute bc_all_all_date_routines
execute bc_all_all_req_prt_check
execute bc_all_all_req_audit_updt
 
declare log_file = vc with constant("cmcreqtest2.LOG")
set A1_debug_on = 0
set A1_trace_on = 1
 
;=====================================================
; DEBUG - Free REQUEST record
;=====================================================
if (A1_debug_on = 1 )
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
 
if (A1_trace_on = 1 )
  call sCURPROG_TRACE(null)  ;002
  call sWRITE_MESSAGE_NOFLAG("Entered program...", log_file)
endif
 
;=====================================================
; DEBUG - Setup REQUEST information for test order
;=====================================================
if (A1_debug_on = 1 )
  set request->person_id = 18604941.00
  set request->print_prsnl_id = 11852036.00
  set request->printer_name = "750_7thflr_l1"
  set stat = alterlist(request->order_qual, 1)
  ; Order 1
  set request->order_qual[1].order_id = 477583235.00
  set request->order_qual[1].encntr_id = 108255972.00
  set request->order_qual[1].conversation_id = 0.00
endif
 
if (A1_trace_on = 1 )
  call ECHOJSON(request, "ECHOJSONA1A", 1 )
endif
 
;go to exit_script
 
;=====================================================
; DVDev Record structure
;=====================================================
free set common_rec
record common_rec(
  1 pat_data
    2 home_phone        = vc
    2 mobile_phone      = vc
  1 address
    2 pat_addr_cnt      = i4
    2 pat_addr1         = vc
    2 pat_addr2         = vc
    2 pat_addr3         = vc
    2 pat_addr4         = vc
    2 pat_addr5         = vc
)
with persistscript
 
free set orders_rec
record orders_rec (
  1 spoolout_ind        = i2
  1 perform_location    = f8
  1 printer_reassigned  = i2
  1 qual[*]
    2 order_id          = f8
    2 encntr_id         = f8
    2 encntr_num        = vc
    ; Reported data
    2 site              = vc
    2 ordering_md       = vc
    2 ordering_md_msp   = vc
    2 attending_md      = vc
    2 attending_md_msp  = vc
    2 referring_md      = vc
    2 referring_md_msp  = vc
    2 referred_to_md    = vc   ;003
    2 order_mnemonic    = vc
    2 order_dt_tm       = vc
    2 order_priority    = vc
    2 referral_reason   = vc
    2 allergy           = vc
    2 medications       = vc
    2 spec_instruction  = vc
    2 comment           = vc
)
with persistscript
 
%i CUST_SCRIPT:bc_all_all_requisition_patrecd.inc
%i CUST_SCRIPT:bc_all_all_pack_address_recd.inc
 
;=====================================================
; Declarations
;=====================================================
declare cv43_Home                = f8 with protect, constant(uar_get_code_by("MEANING" ,43 ,"HOME" ) )
declare cv43_Mobile              = f8 with protect, constant(uar_get_code_by("MEANING" ,43 ,"MOBILE" ) )
declare cv212_Home               = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 212, "HOME"))
declare cv319_FinNbr             = f8 with protect, constant(uar_get_code_by("MEANING", 319, "FIN NBR"))
declare cv320_MSP                = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 320, "MSP"))
declare cv333_AttendDoc          = f8 with protect, constant(uar_get_code_by("MEANING" ,333 ,"ATTENDDOC" ) )
declare cv333_ReferDoc           = f8 with protect, constant(uar_get_code_by("MEANING" ,333 ,"REFERDOC" ) )
declare cv6003_Order             = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ORDER" ) )
declare cv6004_Ordered           = f8 with protect, constant(uar_get_code_by("MEANING", 6004, "ORDERED" ) )
declare cv16449_ReasonForExam    = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "REASONFOREXAM"))
declare cv16449_ReferredToProvider  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "REFERREDTOPROVIDER")) ;003
declare cv16449_SchPriority      = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHPRIORITY"))
declare cv16449_SpecialInstructions = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "SPECIALINSTRUCTIONS"))
 
declare pack_addr_entity_id   = f8 with protect, noconstant(0.00)
declare pack_addr_entity_type = f8 with protect, noconstant(0.00)
 
declare output_printer = C50
declare order_idx = i4
declare order_num = i4
declare order_details = vc
declare requisition_printed = i2
 
;005 set requisition_printed = 0
set output_printer = request->printer_name
set orders_rec->spoolout_ind = 0
 
;004 Start
;=====================================================
; Bypass duplicate record
;=====================================================
for (order_idx = 1 to size(request->order_qual, 5) )
  if (request->order_qual[order_idx ].encntr_id = 0.00 and request->print_prsnl_id > 5.00 )
    set request->order_qual[order_idx ].encntr_id = sGET_ORIG_ENCNTR_ID(request->order_qual[order_idx ].order_id )
  endif
endfor
;004 End
 
;=====================================================
; Get Patient information
;=====================================================
%i CUST_SCRIPT:bc_all_all_requisition_patinfo.inc
 
; Patient's home address
set pack_addr_entity_id = request->person_id
set pack_addr_entity_type = cv212_Home
call sPACK_ADDRESS(pack_addr_entity_id, pack_addr_entity_type )
 
set common_rec->address.pat_addr_cnt = pack_address->line_cnt
set common_rec->address.pat_addr1 = pack_address->line1
set common_rec->address.pat_addr2 = pack_address->line2
set common_rec->address.pat_addr3 = pack_address->line3
set common_rec->address.pat_addr4 = pack_address->line4
set common_rec->address.pat_addr5 = pack_address->line5
 
; Patient's phone numbers
select into "nl:"
       p.person_id
  from person p
      ,phone ph1
      ,phone ph2
 
plan p
where p.person_id = request->person_id
  and p.active_ind = 1
  and p.end_effective_dt_tm > sysdate
 
join ph1
where ph1.parent_entity_id = outerjoin(p.person_id )
  and ph1.parent_entity_name = outerjoin("PERSON")
  and ph1.active_ind = outerjoin(1)
  and ph1.end_effective_dt_tm > outerjoin(sysdate )
  and ph1.phone_type_cd = outerjoin(cv43_Home )
 
join ph2
where ph2.parent_entity_id = outerjoin(p.person_id )
  and ph2.parent_entity_name = outerjoin("PERSON")
  and ph2.active_ind = outerjoin(1)
  and ph2.end_effective_dt_tm > outerjoin(sysdate )
  and ph2.phone_type_cd = outerjoin(cv43_Mobile )
 
detail
  common_rec->pat_data.home_phone = sCNVTPHONE2(ph1.phone_num )
  common_rec->pat_data.mobile_phone = sCNVTPHONE2(ph2.phone_num )
 
with nocounter
;--------------------------------------------------------------------------
if (A1_trace_on = 1 )
  call ECHOJSON(common_rec, "CMCECHOJSONA1B", 1 )
endif
 
;=====================================================
; Process orders
;=====================================================
call sWRITE_MESSAGE_NOFLAG(build2("request->person_id=",request->person_id), log_file)
call sWRITE_MESSAGE_NOFLAG(build2("size(request->order_qual, 5)=",size(request->order_qual, 5)), log_file)
if (request->person_id > 0.00 )
  if (size(request->order_qual, 5) > 0 )  ; Must have at least one order passed from PC
    set orders_rec->spoolout_ind = 1
 
    ;=====================================================
    ; Allocate ORDERS_REC structure for # of orders
    ;=====================================================
;005    SET stat = alterlist(orders_rec->qual, size(request->order_qual, 5) )
    SET stat = alterlist(orders_rec->qual, 1 )  ;005
 
    ;=====================================================
    ; Get/load information from each order
    ;=====================================================
    for (order_idx = 1 to size(request->order_qual, 5) )
      ;=====================================================
      ; Assign originating encounter ID if required
      ;=====================================================
;004      if (request->order_qual[order_idx ].encntr_id = 0.00 )
;004        set request->order_qual[order_idx ].encntr_id = sGET_ORIG_ENCNTR_ID(request->order_qual[order_idx ].order_id )
;004      endif
 
;004      if (sREQ_AmbReferral(request->order_qual[order_idx ].order_id, request->print_prsnl_id ) = 1 )
 	  call sWRITE_MESSAGE_NOFLAG(build2("request->order_qual[order_idx ].order_id="
 	  	,request->order_qual[order_idx ].order_id), log_file)
 	  call sWRITE_MESSAGE_NOFLAG(build2("request->order_qual[order_idx ].encntr_id="
 	  	,request->order_qual[order_idx ].encntr_id), log_file)
 	   call sWRITE_MESSAGE_NOFLAG(build2("sREQ_AmbReferral()="
 	  	,sREQ_AmbReferral(request->order_qual[order_idx ].order_id, request->print_prsnl_id)), log_file)
      if ((sREQ_AmbReferral(request->order_qual[order_idx ].order_id, request->print_prsnl_id ) = 1 ) and  ;004
          (request->order_qual[order_idx ].encntr_id > 0.00 ))                                             ;004
 
;005        set order_num = order_num + 1
        set order_num = 1            ;005
        set requisition_printed = 0  ;005
 
        ;=====================================================
        ; Initialize order fields
        ;=====================================================
        select into "nl:"
          from orders o
        plan o
        where o.order_id = request->order_qual[order_idx].order_id
 
        detail
          ; Initialize record
          orders_rec->qual[order_num ].order_id          = request->order_qual[order_idx].order_id
          orders_rec->qual[order_num ].encntr_id         = request->order_qual[order_idx].encntr_id
          ; From ORDERS table
          orders_rec->qual[order_num ].order_mnemonic    = o.order_mnemonic
          ; From ENCNTR_ALIAS table
          orders_rec->qual[order_num ].encntr_num        = ""
          ; From ENCOUNTER table
          orders_rec->qual[order_num ].site              = ""
          ; From ORDER_ACTION table
          orders_rec->qual[order_num ].ordering_md       = ""
          orders_rec->qual[order_num ].ordering_md_msp   = ""
          ; From queries
          orders_rec->qual[order_num ].attending_md      = ""
          orders_rec->qual[order_num ].attending_md_msp  = ""
          orders_rec->qual[order_num ].referring_md      = ""
          orders_rec->qual[order_num ].referring_md_msp  = ""
          orders_rec->qual[order_num ].referred_to_md    = ""   ;003
          orders_rec->qual[order_num ].order_dt_tm       = ""
          orders_rec->qual[order_num ].order_priority    = ""
          orders_rec->qual[order_num ].referral_reason   = ""
          orders_rec->qual[order_num ].allergy           = ""
          orders_rec->qual[order_num ].medications       = ""
          orders_rec->qual[order_num ].spec_instruction  = ""
          orders_rec->qual[order_num ].comment           = ""
 
        with nocounter
 
        ;=====================================================
        ; Get information from encounter key
        ;=====================================================
        select into "nl:"
          from encounter e
             , encntr_alias ea
             , org_type_reltn otr
             , code_value cv
 
        plan e
        where e.encntr_id = orders_rec->qual[order_num ].encntr_id
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
          orders_rec->qual[order_num ].encntr_num = ea.alias
          orders_rec->qual[order_num ].site = cv.description
 
        with nocounter
 
        ;=====================================================
        ; Get Order By Provider
        ;=====================================================
        select into "nl:"
          from order_action oa
             , prsnl p
             , prsnl_alias pa
 
        plan oa
        where oa.order_id = orders_rec->qual[order_num ].order_id
          and oa.action_type_cd = cv6003_Order
          and oa.action_sequence = (select max(oa1.action_sequence)
                                      from order_action oa1
                                     where oa1.order_id = oa.order_id
                                       and oa1.action_type_cd = oa.action_type_cd )
 
        join p
        where p.person_id = outerjoin(oa.order_provider_id )
 
        join pa
        where pa.person_id = outerjoin(p.person_id )
          and pa.prsnl_alias_type_cd = outerjoin(cv320_MSP )
          and pa.active_ind = outerjoin(1 )
 
        detail
;001          orders_rec->qual[order_num ].order_dt_tm = sCST_DT_TM(oa.order_dt_tm )
          orders_rec->qual[order_num ].order_dt_tm = sCST_DT_TM(oa.action_dt_tm )  ;001
          orders_rec->qual[order_num ].ordering_md = p.name_full_formatted
          orders_rec->qual[order_num ].ordering_md_msp = pa.alias
 
        with nocounter
 
        ;=====================================================
        ; Get Attending and Referring Providers
        ;=====================================================
        select into "nl:"
          from encntr_prsnl_reltn epr
             , prsnl p
             , prsnl_alias pa
 
        plan epr
        where epr.encntr_id = orders_rec->qual[order_num ].encntr_id
          and epr.encntr_prsnl_r_cd in (cv333_AttendDoc, cv333_ReferDoc )
          and epr.end_effective_dt_tm >= sysdate
          and epr.active_ind = 1
 
        join p
        where p.person_id = epr.prsnl_person_id
          and p.active_ind = 1
 
        join pa
        where pa.person_id = outerjoin(p.person_id )
          and pa.prsnl_alias_type_cd = outerjoin(cv320_MSP )
          and pa.active_ind = outerjoin(1 )
 
        order by epr.encntr_prsnl_r_cd
               , epr.beg_effective_dt_tm desc
 
        head epr.encntr_prsnl_r_cd
          if (epr.encntr_prsnl_r_cd = cv333_AttendDoc )
            orders_rec->qual[order_num ].attending_md = p.name_full_formatted
            orders_rec->qual[order_num ].attending_md_msp = pa.alias
          else
            orders_rec->qual[order_num ].referring_md = p.name_full_formatted
            orders_rec->qual[order_num ].referring_md_msp = pa.alias
          endif
 
        with nocounter
 
        ;=====================================================
        ; Get remaining order details
        ;=====================================================
        select into "nl:"
          from order_detail od
        plan od
        where od.order_id = orders_rec->qual[order_num ].order_id
          and od.oe_field_id in (cv16449_ReasonForExam,
                                 cv16449_ReferredToProvider,  ;003
                                 cv16449_SchPriority,
                                 cv16449_SpecialInstructions )
        order by od.oe_field_id,
                 od.action_sequence desc
 
        head od.oe_field_id
          current_field_id = od.oe_field_id
          current_act_seq = od.action_sequence
 
        detail
          if (od.oe_field_id = current_field_id and od.action_sequence = current_act_seq )
            case (od.oe_field_id )
              of cv16449_ReasonForExam       : orders_rec->qual[order_num ].referral_reason = trim(od.oe_field_display_value, 3 )
              of cv16449_ReferredToProvider  : orders_rec->qual[order_num ].referred_to_md = trim(od.oe_field_display_value, 3 );003
              of cv16449_SchPriority         : orders_rec->qual[order_idx ].order_priority = trim(od.oe_field_display_value, 3 )
              of cv16449_SpecialInstructions : orders_rec->qual[order_num ].spec_instruction = trim(od.oe_field_display_value, 3 )
            endcase
          endif
 
        with nocounter
 
        ;=====================================================
        ; Get Order comment
        ;=====================================================
        select into "nl:"
          from order_comment   oc
             , long_text   lt
 
        plan oc
        where oc.order_id = orders_rec->qual[order_num ].order_id
 
        join lt
        where lt.long_text_id = oc.long_text_id
 
        detail
          if (order_details not = null )
            order_details = concat(order_details, char(13), char(10), char(13), char(10), trim(lt.long_text) )
          else
            order_details = trim(lt.long_text)
          endif
 
        with nocounter
 
        set orders_rec->qual[order_num ].comment = trim(order_details, 3)
 
        ;=====================================================
        ; Build concatenated strings
        ;=====================================================
        set orders_rec->qual[order_num ].allergy       = sDrugAllergyList(request->person_id )
        set orders_rec->qual[order_num ].medications   = sMedList(request->person_id )
 
;005 Start
        ;=====================================================
        ; Call the layout to display the requisition if
        ; requisition is associated with a patient
        ;=====================================================
        call sWRITE_MESSAGE_NOFLAG(build2("orders_rec->spoolout_ind=",orders_rec->spoolout_ind), log_file)
        call sWRITE_MESSAGE_NOFLAG(build2("order_num=",order_num), log_file)
        if (orders_rec->spoolout_ind = 1 and order_num > 0 and A1_debug_on = 0 )
          if (A1_trace_on = 1 )
            call sWRITE_MESSAGE_NOFLAG("Before layout call...", log_file)
          endif
 
          execute BC_ALL_AMB_REFERRAL_REQ_LYT value(output_printer )
          call write_reqn_info("A1", request, orders_rec, orders_rec, "" )
          set requisition_printed = 1
 
          if (A1_trace_on = 1 )
            call sWRITE_MESSAGE_NOFLAG("After layout call...", log_file)
          endif
        endif
 
        ; Write an audit record if a requisition did not print
        if (requisition_printed = 0 and A1_debug_on = 0 )
          call write_rqst_info("A1", request )
        endif
;005 End
 
      endif  ; Current order completed
    endfor
 
;005    ;=====================================================
;005    ; Resize order record after unwanted orders are
;005    ; bypassed
;005    ;=====================================================
;005    if (order_num > 0 )
;005      SET stat = alterlist(orders_rec->qual, order_num )
;005    endif
 
  endif
endif
 
if (A1_trace_on = 1 )
  call ECHOJSON(orders_rec, "cmcECHOJSONA1C", 1 )
endif
 
/* ;005 Start
;=====================================================
; Call the layout to display the requisition if
; requisition is associated with a patient
;=====================================================
if (orders_rec->spoolout_ind = 1 and order_num > 0 and A1_debug_on = 0 )
  if (A1_trace_on = 1 )
    call sWRITE_MESSAGE_NOFLAG("Before layout call...", log_file)
  endif
 
  execute BC_ALL_AMB_REFERRAL_REQ_LYT value(output_printer )
  call write_reqn_info("A1", request, orders_rec, orders_rec, "" )
  set requisition_printed = 1
 
  if (A1_trace_on = 1 )
    call sWRITE_MESSAGE_NOFLAG("After layout call...", log_file)
  endif
endif
 
; Write an audit record if a requisition did not print
if (requisition_printed = 0 and A1_debug_on = 0 )
  call write_rqst_info("A1", request )
endif
*/ ;005 End
 
if (A1_trace_on = 1 )
  call sWRITE_MESSAGE_NOFLAG("Exiting program...", log_file)
endif
 
set A1_trace_on = 0
 
;======================================================================
; Subroutines
;======================================================================
subroutine sDrugAllergyList(pPersonID)
  declare allergy_string = vc with protect
  declare cv12025_Active = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 12025, "ACTIVE"))
  declare cv12020_Drug   = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 12020, "DRUG"))
 
  set allergy_string = " "
 
  select into "nl:"
         aAllergy = a.substance_ftdesc
       , nAllergy = n.source_string
  from allergy   a
     , nomenclature   n
 
  plan a
  where a.person_id = pPersonID
    and a.beg_effective_dt_tm < sysdate
    and a.end_effective_dt_tm > sysdate
    and a.reaction_status_cd = cv12025_Active
;    and a.substance_type_cd = cv12020_Drug
    and a.active_ind = 1
 
  join n
  where n.nomenclature_id = outerjoin(a.substance_nom_id )
    and n.active_ind = outerjoin(1 )
 
  detail
    if (aAllergy != " " )
      allergy_string = CONCAT(allergy_string, ", ", trim(aAllergy, 3) )
    else
      allergy_string = CONCAT(allergy_string, ", ", trim(nAllergy, 3) )
    endif
  with nocounter
 
  ; Remove first comma and space
  set allergy_string = trim(replace(allergy_string, ", ", "", 1 ), 3 )
 
  return(allergy_string )
end ;Subroutine
 
;---------------------------------------------------
 
subroutine sMedList(pPersonID)
  declare med_list_string = vc with protect
  declare single_med = vc with protect
  declare cv6000_Pharmacy = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 6000, "PHARMACY"))
  declare cv18309_Med = f8 with public, constant(uar_get_code_by("DISPLAYKEY", 18309, "MED"))
 
  set med_list_string = " "
 
  select into "nl:"
         o.order_id
	     , med_name = o.order_mnemonic
	     , med_type = o.ordered_as_mnemonic
	     , med_detail = o.clinical_display_line
	     , med_comment = lt.long_text
 
    from orders   o
       , order_comment   oc
       , long_text   lt
 
  plan o
  where o.person_id = pPersonID
;    and o.med_order_type_cd = cv18309_Med
    and o.catalog_type_cd = cv6000_Pharmacy
    and o.order_status_cd = cv6004_Ordered
    and o.template_order_id = 0.00
    and o.active_ind = 1
 
  join oc
  where oc.order_id = outerjoin(o.order_id)
 
  join lt
  where lt.long_text_id = outerjoin (oc.long_text_id)
 
  order by cnvtupper(o.order_mnemonic)
 
  head o.order_id
    single_med = trim(med_name )
    if (med_type not = null and med_type not = med_name)
      single_med = concat(single_med, " (", trim(med_type), ")" )
    endif
    if (med_detail not = null )
      single_med = concat(single_med, " ", trim(med_detail) )
    endif
 
  detail
    if (med_comment not = null )
      single_med = concat(single_med, " ", trim(med_comment) )
    endif
 
  foot o.order_id
    ; Add med order to med list
    if (med_list_string not = null )
      med_list_string = concat(med_list_string, char(13), char(10), char(13), char(10), trim(single_med) )
    else
      med_list_string = trim(single_med)
    endif
 
  with nocounter
 
  return(med_list_string)
end ;Subroutine
 
#exit_script
 
end go

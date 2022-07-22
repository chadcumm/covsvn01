/***********************************************************************************************************************
Source Code File: BC_ALL_RPT_REQ_AUDIT.PRG
Original Author:  Barry Wong
Date Written:     June 2020
 
Comments: This program is executed from DA2 and is used to extract information from the requisition audit table.
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  30-Jun-2020  CST-37379  Barry Wong             Created
001  27-Jul-2020  CST-52530  Jeremy Gunn            Added L14 - Lab - Transfusion Medicine Neonatal to prompt
002  30-Jul-2020  CST-92435  Barry Wong             Added A3 - Acute - Oral Diet
                                                    Added A4 - Acute - Nutrition Supplement
                                                    Added A5 - Acute - Enteral Feeding
                                                    Added A6 - Acute - Diet Communication
                                                    Added A7 - Acute - Fluid Restriction
003  19-Aug-2020  CST-96777  Jeremy Gunn            Modified print_type field to remove M1 to display like other order types
***********************************************************************************************************************/
drop program bc_all_rpt_req_audit go
create program bc_all_rpt_req_audit
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "Requisition Type" = ""
	, "Start Date Time" = "SYSDATE"
	, "End Date Time" = "SYSDATE"
	, "Encounter     (optional)" = ""
	, "MRN     (optional)" = ""
	, "Order Number     (optional)" = ""
	, "in the field" = "  First Order field"
 
with OUTDEV, ReqType, StartDttm, EndDttm, Encounter, MRN, OrderNum, OrderSearchIn
 
declare audit_debug_ON = i2
set audit_debug_ON = 0
 
;=====================================================
; DVDev DECLARED SUBROUTINES
;=====================================================
execute bc_all_all_std_routines
 
;call sCURPROG_TRACE(null)
 
;-----------------------------------------
; Variables
;-----------------------------------------
declare req_string = vc
declare parse_req = vc
declare parse_enc = vc
declare parse_MRN = vc
declare parse_order = vc
declare parse_str_order = vc
declare parse_full = vc
 
declare encounterID = f8
declare MRN_ID = f8
declare MRN_Enc_Count = i4
declare encntr_list= vc
 
;-----------------------------------------
; Constants
;-----------------------------------------
declare cv263_Encounter = f8 with constant(uar_get_code_by("DISPLAY_KEY", 263, "ENCOUNTER" ) ) ,protect
declare cv263_MRN = f8 with constant(uar_get_code_by("DISPLAY_KEY", 263, "MRN" ) ) ,protect
 
;-----------------------------------------
; Set up filter criteria
;-----------------------------------------
; Requisition Type Filter
set req_string = sBUILD_LIST_STRING(2, "(" )
if (req_string = "(1=1)" )
  set parse_req = "(1=1)"
else
  set parse_req = concat("crr.reqn_trace_id in ", req_string )
endif
 
; Encounter Filter
set encounterID = 0.00
 
if ($Encounter = null)
  set parse_enc = "(1=0)"
else
  select into "nl:"
         ea.encntr_id
    from encntr_alias  ea
   where ea.alias = $Encounter
     and ea.alias_pool_cd = cv263_Encounter
  detail
    encounterID = ea.encntr_id
  with nocounter, time=10
 
  if (encounterID > 0.00 )
    set parse_enc = concat("crr.encntr_id = ", cnvtstring(encounterID ) )
  else
    set parse_enc = "(1=0)"  ;Stays at 1=0
  endif
endif
 
; MRN Filter
if ($MRN = null )
  set parse_MRN = "(1=0)"
else
  set MRN_Enc_Count = 0
  select into "nl:"
         encID = cnvtstring(ea.encntr_id )
    from encntr_alias  ea
   where ea.alias = $MRN
     and ea.alias_pool_cd = cv263_MRN
     and ea.active_ind = 1
  detail
    if (MRN_Enc_Count = 0 )
      encntr_list = concat("(", encID )
    else
      encntr_list = concat(encntr_list, ",", encID )
    endif
    MRN_Enc_Count = MRN_Enc_Count + 1
  foot report
    encntr_list = concat(encntr_list, ")" )
  with nocounter, time=10
 
  if (MRN_Enc_Count > 0 )
    set parse_MRN = concat("crr.encntr_id in ", encntr_list )
  else
    set parse_MRN = "(1=0)"
  endif
endif
 
; Order Filter
if ($OrderNum = null )
  set parse_order = "(1=0)"
else
  set parse_order = concat("crr.order_id = ", $OrderNum )
endif
 
set parse_str_order = "(1=0)"
if (($OrderNum not = null) and (datetimediff(cnvtdatetime($EndDttm), cnvtdatetime($StartDttm), 3) <= 24 ))
  set parse_order = "(1=0)"
  set parse_str_order = concat('crr.order_string = "*', trim($OrderNum, 3), '*"' )
endif
 
; If no optional filters are selected then set all optional filters to True
; so they don't affect the full search results
if (trim(parse_enc, 3 ) = "(1=0)" and
    trim(parse_MRN, 3 ) = "(1=0)" and
    trim(parse_order, 3 ) = "(1=0)" and
    trim(parse_str_order, 3 ) = "(1=0)" )
  set parse_str_order = "(1=1)"
  set parse_enc = "(1=1)"
  set parse_MRN = "(1=1)"
  set parse_order = "(1=1)"
endif
 
; Debug Filters/Parsers
if (audit_debug_ON )
  select into $OUTDEV
         parse_req
       , parse_enc
       , parse_MRN
       , parse_order
       , parse_str_order
    from dual
  with maxrec = 100, nocounter, separator=" ", format, time=10
 
  go to exit_script
endif
 
;-----------------------------------------
; Main Query
;-----------------------------------------
 
select into $OUTDEV
       Print_Dttm = format(crr.print_dt_tm, "DD-MMM-YYYY HH:MM:SS;;Q")
     , Printer = crr.printer_name
     , Encounter = ea.alias
     , Patient = p.name_full_formatted
;     , MRN = cnvtalias(ea2.alias ,ea2.alias_pool_cd )
     , MRN = pa.alias
     , Requisition = crr.reqn_name
     , Location = uar_get_code_display(crr.loc_facility_cd )
     , First_Order_ID = cnvtstring(o.order_id )
     , First_Order = o.order_mnemonic
     , Order_List = crr.order_string
/* 003
     , Print_Type = if (crr.reqn_trace_id = "M1" )
                      "Autoprint/Reprint"
                    elseif (crr.print_prsnl_id < 5.00)
                      "Autoprint"
                    else
                      "Reprint"
                    endif
*/
      ;003
     , Print_Type = if (crr.print_prsnl_id < 5.00)
                      "Autoprint"
                    else
                      "Reprint"
                    endif
     , Printed_By = if (crr.print_prsnl_id < 5.00)
                      ""
                    else
                      pr.name_full_formatted
                    endif
     , Note = crr.site
 
  from cust_rept_reqnstats   crr
     , encntr_alias   ea
;     , encntr_alias   ea2
     , person   p
     , person_alias   pa
     , orders   o
     , prsnl  pr
 
plan crr
where parser (parse_req)
  and ( parser (parse_enc) or
        parser (parse_MRN) or
        parser (parse_order) or
        parser (parse_str_order) )
  and crr.print_dt_tm between cnvtdatetime($StartDttm) and cnvtdatetime($EndDttm)
 
join ea
where ea.encntr_id = outerjoin(crr.encntr_id )
  and ea.alias_pool_cd = outerjoin(cv263_Encounter )
  and ea.active_ind = outerjoin(1 )
 
;join ea2
;where ea2.encntr_id = outerjoin(crr.encntr_id )
;  and ea2.end_effective_dt_tm > outerjoin(sysdate )
;  and ea2.alias_pool_cd = outerjoin(cv263_MRN )
;  and ea2.active_ind = outerjoin(1 )
 
join p
where p.person_id = outerjoin(crr.person_id )
  and p.active_ind = outerjoin(1 )
 
join pa
where pa.person_id = outerjoin(crr.person_id )
  and pa.end_effective_dt_tm > outerjoin(sysdate )
  and pa.alias_pool_cd = outerjoin(cv263_MRN )
  and pa.active_ind = outerjoin(1 )
 
join o
where o.order_id = outerjoin(crr.order_id )
 
join pr
where pr.person_id = outerjoin(crr.print_prsnl_id )
  and pr.active_ind = outerjoin(1)
 
order by crr.print_dt_tm
       , ea.alias
 
with nocounter, separator=" ", format, time=120
 
#exit_script
 
end
go
 

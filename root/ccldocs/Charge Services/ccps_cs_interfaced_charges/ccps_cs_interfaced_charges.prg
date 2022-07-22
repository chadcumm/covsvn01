/*****************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 2008 Cerner Corporation                      *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the expressed   *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
      ************************************************************************/
 
/*****************************************************************************
 
        Author                  Marcia Pugh
        Date Written:           March, 2010
        Source file name:       ccps_cs_interfaced_charges.prg
        Object name:            ccps_cs_interfaced_charges
        Request #:
 
        Product:                Centers
        Product Team:           CCL Discern
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Display interfaced charges based on various prompts.
                                Two prompts are required - Report Type (output format of Excel, Paper - Detail, Paper - Summary)
                                                           Date Range (posted/interfaced date)
                                The Excel output is based on Date Range prompt.
                                For the Paper - Summary output, the user has 1 prompt, from which to select what they want to
                                summary by, ie, organization, activity type, cost center, interface file, tier group, or
                                encounter type.
                                For the Paper - Detail, the user can select values from 6 prompts (organization, activity type,
                                cost center, interface file, tier group, or encounter type), which will be qualifiers for the
                                query as well as the order/sort by.
 
        Tables read:            interface_charge, interface_file, person, charge, organization, encntr_alias,
                                tier_matrix, bill_org_payor, prsnl_org_reltn, prsnl, code_value
                                ;some table are used in the prompts
 
        Tables updated:         None
        Executing from:         Explorer Menu or OPS
 
        Special Notes:          The following prompts contain code for org security:
                                   organization, cost_center, interf_file, tier_group
                                Using Java for prompt controls to enable/disable, show/hide,
                                   and set prompt values.
                                This program shares the layout with ccps_cs_posted_charges.prg.
 
******************************************************************************/
 
 
;******************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG                *
;    **************************************************************************
;    *                                                                        *
;    *Mod Date     Engineer             Comment                               *
;    *--- -------- -------------------- --------------------------------------*
;    *000 03/25/10 MP9098               Standard Custom CCL Program for Charge Services - Interfaced Charges
;    *    05/25/10 MP9098               Add summary to Paper - Detail
;    *001 11/08/10 MP9098               Add logic to accept a number for the Report Type and Summary By prompts
;                                       when executed via ops.
;                                       Add logic for reflect/parameter = "I4" for the last 6 prompts.
;     002 02/10/11 MP9098               Add logic for IsPromptEmpty in accordance with modifications to the
;                                       prompt list include file.
;     003 03/22/11 MP9098               SCINT 241 Use charge description rather than CDM description
;                                       SCINT-257: Enhanced prompt list include file used to set
;                                       multi_select and any_all_select variables.
;                                       SCINT-242:  Increase width of FIN in layout, which is actually associated to the
;                                       interfacec charge program.
;                                       SCINT-279:  Credits submitted via chargeviewer appear on the
;                                       charge table and interface_charge table with a minus sign in the price columns.
;                                       Pharmacy credits done via phachargecredit appear on these tables without a minus sign.
;     004 05/16/11 MP9098               SCINT-283: Create a csv file if the program is executed from ops.
;     005 06/23/11 MP9098               SCINT-230: Revise logic to accommodate program being executed via ops by SYSTEM user
;                                       in a multi-tenant domain.  Basically, in a multi-tenant domain, SYSTEM doesn't have
;                                       logical domain access/security to all organizations.  Therefore, when the program
;                                       is executed via ops, there will be no output.
;                                       These modifications have to account for non-multi-tenant domains, where SYSTEM basically
;                                       has logical domain access/security to all organizations.
;     006 10/21/11 MP9098               SCINT-331 Use interface_charge.beg_effective_dt_tm rather than
;                                       interface_charge.posted_dt_tm.
;                                       SCINT-324 Not all charges appear that are associated to combined encounters/persons.
;     007 10/24/12 MP9098               SCINT-367: use ccps_cs_security.inc to validate logical domain and org security
;******************************************************************************/
 
drop program ccps_cs_interfaced_charges:dba go
create program ccps_cs_interfaced_charges:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Begin Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Report Type" = 0
	, "Summary By" = 0
	, "Organization" = 0
	, "Activity Type" = 0
	, "Cost Center" = 0
	, "Interface File" = 0
	, "Tier Group" = 0
	, "Encounter Type" = 0
 
with OUTDEV, beg_date, end_date, rpt_type, summary_by, organization,
	activity_type, cost_center, interf_file, tier_group, encntr_type
 
;Include files
%i cclsource:sc_cps_parse_date_subs.inc

 
;Define/set variables equal to prompts.
declare BEG_DT_TM                 = dq8 with constant(ParseDatePrompt($BEG_DATE, CURDATE - 1, 000000)),protect
declare END_DT_TM                 = dq8 with constant(ParseDatePrompt($END_DATE, CURDATE - 1, 235959)),protect
 
declare EA_TYPE_FIN_CD            = f8 with Constant(uar_get_code_by("MEANING",    319, "FIN NBR")), protect
declare CREDIT_CHARGE_TYPE_CD     = f8 with Constant(uar_get_code_by("MEANING",  13028, "CR")), protect
 
declare prompt_dates              = vc with constant(concat("Begin Date:  ", format(BEG_DT_TM, "@SHORTDATE"),
                                                            "  End Date:  ", format(END_DT_TM, "@SHORTDATE")))
declare exec_date_str             = vc with constant(concat("Execution Date/Time:  ",
                                                            format(cnvtdatetime(curdate,curtime), "@SHORTDATETIME")))

declare detail_page_title         = vc with constant("Interfaced Charge Detail")
declare foot_detail_text          = vc with constant("Total Interfaced Charges with a Total Extended Price of")
declare foot_summary_text         = vc with constant("TOTAL Interfaced Charges")

declare prompt_organization       = vc with noconstant(" "), public
declare prompt_activity_type      = vc with noconstant(" "), public
declare prompt_cost_center        = vc with noconstant(" "), public
declare prompt_interf_file        = vc with noconstant(" "), public
declare prompt_tier_group         = vc with noconstant(" "), public
declare prompt_encntr_type        = vc with noconstant(" "), public
 
 
declare multi_select              = vc with constant("Multiple Selected")
declare any_all_select            = vc with constant("All Qualifying Records")
declare summary_by_prompt         = vc with noconstant("Interfaced Charge Summary")
 
declare RPT_OUTPUT_EXCEL          = i4 with constant(1), protect
declare RPT_OUTPUT_PAPER_DETAIL   = i4 with constant(2), protect
declare RPT_OUTPUT_PAPER_SUMMARY  = i4 with constant(3), protect
declare rpt_output_type           = i4 with noconstant(0), public
 
declare num                       = i4 with noconstant(0), public
declare pos                       = i4 with noconstant(0), public
declare file_name                 = vc with noconstant("cs_interfaced_charges.csv"), public
declare ACTIVITY_TYPE_PARSER      = vc with noconstant(" "), public
declare COST_CENTER_PARSER        = vc with noconstant(" "), public
declare INTERFACE_FILE_PARSER     = vc with noconstant(" "), public
declare TIER_GROUP_PARSER         = vc with noconstant(" "), public
declare ENCNTR_TYPE_PARSER        = vc with noconstant(" "), public


 
%i cclsource:ccps_cs_security.inc

call createLDOrgParsers(reqinfo->updt_id, "o.logical_domain_id", 6, "ic.organization_id")

if(ld_parser = "0=1" or ORGANIZATION_PARSER = "0=1")
    set ld_failure_flag = 1
    set display_message = "The logical domain and/or organization security validation failed."
    go to exit_prg
endif

if(validate(org_prompt_rec->cnt, 0) > 0) ;list or single
    set file_name = concat(file_name, "_", trim(cnvtstring(org_prompt_rec->list[1].number,0),3))
    if(org_prompt_rec->cnt > 1)
      set prompt_organization = multi_select
    else
      set prompt_organization = org_prompt_rec->list[1].string
    endif
elseif(validate(ccps_org_sec_rec->cnt, 0) > 0) ;any or empty
    set file_name = concat(file_name, "_", trim(cnvtstring(ccps_org_sec_rec->list[1].organization_id,0),3))
    
    set prompt_organization = any_all_select
endif
 
;numeric values for rpt_type prompt
;    1 Excel Format
;    2 Paper Format - Detail
;    3 Paper Format - Summary
if(reflect(parameter(4,0)) = "I4")
    case (cnvtint($rpt_type))
        of 1:
            set rpt_output_type = RPT_OUTPUT_EXCEL
        of 2:
            set rpt_output_type = RPT_OUTPUT_PAPER_DETAIL
        of 3:
            set rpt_output_type = RPT_OUTPUT_PAPER_SUMMARY
        else
            set rpt_output_type = RPT_OUTPUT_EXCEL
    endcase
  else
    ;Passivity for old prompt style
    case (cnvtstring($rpt_type))
        of "Excel Format":
            set rpt_output_type = RPT_OUTPUT_EXCEL
        of "Paper Format - Detail":
            set rpt_output_type = RPT_OUTPUT_PAPER_DETAIL
        of "Paper Format - Summary":
            set rpt_output_type = RPT_OUTPUT_PAPER_SUMMARY
        else
            set rpt_output_type = RPT_OUTPUT_EXCEL
    endcase
  endif
 
;numeric values for summary_by prompt
;    1 Activity Type
;    2 Cost Center
;    3 Encounter Type
;    4 Interface File
;    5 Organization
;    6 Tier Group
if($summary_by > 0 and $summary_by < 7)
  if($summary_by = 1)
    set summary_by_prompt = "Interfaced Charge Summary by Activity Type"
  elseif($summary_by = 2)
    set summary_by_prompt = "Interfaced Charge Summary by Cost Center"
  elseif($summary_by = 3)
    set summary_by_prompt = "Interfaced Charge Summary by Encounter Type"
  elseif($summary_by = 4)
    set summary_by_prompt = "Interfaced Charge Summary by Interface File"
  elseif($summary_by = 5)
    set summary_by_prompt = "Interfaced Charge Summary by Organization"
  elseif($summary_by = 6)
    set summary_by_prompt = "Interfaced Charge Summary by Tier Group"
  endif
endif
 
;For the Paper - Detail, display a summary indicating the user's selection for the last 6 prompts.
;If user selected ANY or made no selection, then display "all selected".
;If user selected a specific value, then display that specific name.
;If user selected multiple values, then display "multiple selected".
if(IsPromptEmpty(7)or IsPromptAny(7))
  set prompt_activity_type = any_all_select
elseif(IsPromptList(7))
  set prompt_activity_type = multi_select
else
  set prompt_activity_type = trim(uar_get_code_display(cnvtreal($activity_type)))
endif
 
if(IsPromptEmpty(8)or IsPromptAny(8))
  set prompt_cost_center = any_all_select
elseif(IsPromptList(8))
  set prompt_cost_center = multi_select
else
  set prompt_cost_center = trim(uar_get_code_display(cnvtreal($cost_center)))
endif
 
if(IsPromptEmpty(9)or IsPromptAny(9))
  set prompt_interf_file = any_all_select
elseif(IsPromptList(9))
  set prompt_interf_file = multi_select
else
  select into "nl:"
  from interface_file ifile
  plan ifile
  where ifile.interface_file_id = $interf_file
  and ifile.active_ind = 1
  detail
    prompt_interf_file = trim(ifile.description)
  with nocounter
endif
 
if(IsPromptEmpty(10)or IsPromptAny(10))
  set prompt_tier_group = any_all_select
elseif(IsPromptList(10))
  set prompt_tier_group = multi_select
else
  set prompt_tier_group = trim(uar_get_code_display(cnvtreal($tier_group)))
endif
 
if(IsPromptEmpty(11)or IsPromptAny(11))
  set prompt_encntr_type = any_all_select
elseif(IsPromptList(11))
  set prompt_encntr_type = multi_select
else
  set prompt_encntr_type = trim(uar_get_code_display(cnvtreal($encntr_type)))
endif
 
 
;For the Activity Type prompt, user can select a single activity type or ANY. Use the GETPROMPTLIST include file as a parser.
; Pass the subroutine two variables:  7 indicates that Activity Type  is the 7th prompt; ic.activity_type_cd is the database
; table and field that will be searched.
if(IsPromptEmpty(7))
  set ACTIVITY_TYPE_PARSER          = "1=1"
else
  set ACTIVITY_TYPE_PARSER          = GetPromptList(7,"ic.activity_type_cd")
endif
;Other prompts with multi-select
if(IsPromptEmpty(8))
  set COST_CENTER_PARSER            = "1=1"
else
  set COST_CENTER_PARSER            = GetPromptList(8,"ic.cost_center_cd")
endif
 
if(IsPromptEmpty(9))
  set INTERFACE_FILE_PARSER         = "1=1"
else
  set INTERFACE_FILE_PARSER         = GetPromptList(9,"ic.interface_file_id")
endif
 
if(IsPromptEmpty(10))
  set TIER_GROUP_PARSER             = "1=1"
else
  set TIER_GROUP_PARSER             = GetPromptList(10,"c.tier_group_cd")
endif
 
if(IsPromptEmpty(11))
  set ENCNTR_TYPE_PARSER            = "1=1"
else
  set ENCNTR_TYPE_PARSER            = GetPromptList(11,"ic.encntr_type_cd")
endif
 
 
 
;Create record structure
free record charges       ;_id and _cd fields are for trouble-shooting purposes
record charges
(
 1 c_cnt                        = i4
 1 c_total_extended_price       = f8
 1 c_detail [*]
   2 fin                        = vc
   2 patient_name               = vc
   2 service_date_time          = dq8
   2 cdm                        = vc
   2 cpt                        = vc
   2 description                = vc
   2 charge_type                = vc
   2 item_quantity              = f8
   2 qcf                        = f8
   2 extended_quantity          = f8
   2 item_price                 = f8
   2 extended_price             = f8
   2 encntr_id                  = f8
   2 person_id                  = f8
   2 charge_item_id             = f8
   2 organization_id            = f8
   2 organization_name          = vc
   2 activity_type_cd           = f8
   2 activity_type              = vc
   2 cost_center_cd             = f8
   2 cost_center                = vc
   2 interface_file_id          = f8
   2 interface_file_name        = vc
   2 tier_group_cd              = f8
   2 tier_group                 = vc
   2 encntr_type_cd             = f8
   2 encntr_type                = vc
   2 posted_date                = dq8
)
 
free record group_by_summary
record group_by_summary
(
 1 gbs_cnt                      = i4
 1 gbs_total_cnt                = i4  ;total of all charges
 1 gbs_total_extended_price     = f8
 1 gbs_detail [*]
   2 group_by_thing_text        = vc
   2 group_by_thing_cnt         = i4
   2 group_by_extended_price    = f8
)
 
 
;main select and output
select into "nl:"
 
from
  interface_charge ic,
  charge c,
  organization  o,
  interface_file ifile,
  person p,
  encntr_alias eafin,
  encntr_combine ec,
  encntr_alias eafin2
 
plan ic
  where ic.beg_effective_dt_tm between cnvtdatetime(BEG_DT_TM) and cnvtdatetime(END_DT_TM)
  and parser(ACTIVITY_TYPE_PARSER)
  and parser(COST_CENTER_PARSER)
  and parser(INTERFACE_FILE_PARSER)
  and parser(ENCNTR_TYPE_PARSER)
  and parser(ORGANIZATION_PARSER)
  and ic.process_flg = 999
  and ic.active_ind = 1
 
join c
  where c.charge_item_id = ic.charge_item_id
  and parser(TIER_GROUP_PARSER)
  and c.beg_effective_dt_tm+0 <= cnvtdatetime(curdate,curtime3)
  and c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 
join o
  where o.organization_id = ic.organization_id
  and o.active_ind = 1
  and o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
  and o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  and parser(ld_parser)
 
join ifile
  where ifile.interface_file_id = ic.interface_file_id
  and ifile.active_ind = 1
 
join p
  where p.person_id = c.person_id
 
;although FIN is on the interface_charge table, it is the alias only and not in cnvtalias format
join eafin
  where eafin.encntr_id = outerjoin(c.encntr_id)
  and eafin.encntr_alias_type_cd+0 = outerjoin(EA_TYPE_FIN_CD)
  and eafin.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
  and eafin.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
 
join ec
  where ec.from_encntr_id = outerjoin(ic.encntr_id)
  and ec.active_ind = outerjoin(1)
 
join eafin2
  where eafin2.encntr_id = outerjoin(ec.to_encntr_id)
  and eafin2.encntr_alias_type_cd+0 = outerjoin(EA_TYPE_FIN_CD)
  and eafin2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
  and eafin2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
 
order by c.charge_item_id, eafin.end_effective_dt_tm desc,eafin2.end_effective_dt_tm desc
 
head report
 
  c_cnt = 0
 
head c.charge_item_id
 
  c_cnt = c_cnt + 1
 
  if(mod(c_cnt, 100) = 1)
    stat = alterlist(charges->c_detail, c_cnt + 99)
  endif
 
  if(c.charge_type_cd = CREDIT_CHARGE_TYPE_CD and c.item_price > 0.00)
    charges->c_detail[c_cnt].item_price                                    = ic.price * (-1.00)
    charges->c_detail[c_cnt].extended_price                                = ic.net_ext_price * (-1.00)
    charges->c_total_extended_price                                        = charges->c_total_extended_price +
                                                                             (ic.net_ext_price * (-1.00))
  else
    charges->c_detail[c_cnt].item_price                                    = ic.price
    charges->c_detail[c_cnt].extended_price                                = ic.net_ext_price
    charges->c_total_extended_price                                        = charges->c_total_extended_price +
                                                                             ic.net_ext_price
  endif
 
  if(textlen(trim(eafin.alias,3)) > 0)
    charges->c_detail[c_cnt].fin                                           = cnvtalias(eafin.alias, eafin.alias_pool_cd)
  else
    charges->c_detail[c_cnt].fin                                           = cnvtalias(eafin2.alias, eafin2.alias_pool_cd)
  endif
  charges->c_detail[c_cnt].patient_name                                  = p.name_full_formatted
  charges->c_detail[c_cnt].service_date_time                             = ic.service_dt_tm
  charges->c_detail[c_cnt].cdm                                           = ic.prim_cdm
  charges->c_detail[c_cnt].cpt                                           = ic.prim_cpt
  charges->c_detail[c_cnt].description                                   = c.charge_description
  charges->c_detail[c_cnt].charge_type                                   = uar_get_code_display(ic.charge_type_cd)
  charges->c_detail[c_cnt].item_quantity                                 = ic.quantity
  charges->c_detail[c_cnt].qcf                                           = ic.qty_conv_factor
  charges->c_detail[c_cnt].extended_quantity                             = ic.ext_bill_qty
  charges->c_detail[c_cnt].encntr_id                                     = ic.encntr_id
  charges->c_detail[c_cnt].person_id                                     = ic.person_id
  charges->c_detail[c_cnt].charge_item_id                                = c.charge_item_id
  charges->c_detail[c_cnt].organization_id                               = ic.organization_id
  charges->c_detail[c_cnt].organization_name                             = o.org_name
  charges->c_detail[c_cnt].activity_type_cd                              = ic.activity_type_cd
  charges->c_detail[c_cnt].activity_type                                 = uar_get_code_display(ic.activity_type_cd)
  charges->c_detail[c_cnt].cost_center_cd                                = ic.cost_center_cd
  charges->c_detail[c_cnt].cost_center                                   = uar_get_code_display(ic.cost_center_cd)
  charges->c_detail[c_cnt].interface_file_id                             = ic.interface_file_id
  charges->c_detail[c_cnt].interface_file_name                           = ifile.description
  charges->c_detail[c_cnt].tier_group_cd                                 = c.tier_group_cd
  charges->c_detail[c_cnt].tier_group                                    = uar_get_code_display(c.tier_group_cd)
  charges->c_detail[c_cnt].encntr_type_cd                                = ic.encntr_type_cd
  charges->c_detail[c_cnt].encntr_type                                   = uar_get_code_display(ic.encntr_type_cd)
  charges->c_detail[c_cnt].posted_date                                   = ic.posted_dt_tm
 
foot report
 
  stat = alterlist(charges->c_detail, c_cnt)
  charges->c_cnt = c_cnt
 
with nocounter, expand = 1
 
 
 
;Begin output
if (charges->c_cnt > 0)                     ;if record structure is populated
 
if(rpt_output_type = RPT_OUTPUT_PAPER_DETAIL)     ;if report type
;"Paper Format - Detail"
execute reportrtl
%i cclsource:ccps_cs_interfaced_charges.dvl
set d0 = InitializeReport(0)                ;had to put this and the FinalizeReport inside the if($rpt_type . . ), which means
                                            ; 4 lines of code appear 3 times within the program, but it was the only way to
                                            ; get the correct Excel Format output
 
  select into $outdev
 
    first_sort    = trim(substring(1,40,charges->c_detail[d.seq].fin),3),
    second_sort   = trim(substring(1,200, charges->c_detail[d.seq].description),3)
 
  from
    (dummyt  d with seq = value(charges->c_cnt))
  plan d
 
  order by first_sort, second_sort
 
  head page
 
    d0 = HeadPageDetailSection(Rpt_Render)
 
  detail
 
    i = d.seq
 
    if(_YOffset + DetailDetailSection(Rpt_CalcHeight, 2.0, _bContDetailDetailSection) > 7.6)
      d0 = PageBreak(0)
      d0 = HeadPageDetailSection(Rpt_Render)
    endif
 
    d0 = DetailDetailSection(Rpt_Render, 2.0, _bContDetailDetailSection)
 
  foot report
 
    if(_YOffset + FootDetailSection(Rpt_CalcHeight) > 7.6)
      d0 = PageBreak(0)
      d0 = HeadPageDetailSection(Rpt_Render)
    endif
 
    d0 = FootDetailSection(Rpt_Render)
 
    if(_YOffset + FootReportSection0(Rpt_CalcHeight) > 7.6)
      d0 = PageBreak(0)
      d0 = HeadPageDetailSection(Rpt_Render)
    endif
 
    d0 = FootReportSection0(Rpt_Render)
 
  with nocounter
set d0 = FinalizeReport($OUTDEV)
 
elseif(rpt_output_type = RPT_OUTPUT_PAPER_SUMMARY)           ;elseif report type
;"Paper Format - Summary"
execute reportrtl
%i cclsource:ccps_cs_interfaced_charges.dvl
set d0 = InitializeReport(0)
 
;Begin Populate record structure for summary output
  select into "nl:"
 
    summary_sort = if($summary_by = 1)
                     trim(substring(1,40,charges->c_detail[d.seq].activity_type),3)
                   elseif($summary_by = 2)
                     trim(substring(1,40,charges->c_detail[d.seq].cost_center),3)
                   elseif($summary_by = 3)
                     trim(substring(1,40,charges->c_detail[d.seq].encntr_type),3)
                   elseif($summary_by = 4)
                     trim(substring(1,100,charges->c_detail[d.seq].interface_file_name),3)
                   elseif($summary_by = 5)
                     trim(substring(1,100,charges->c_detail[d.seq].organization_name),3)
                   elseif($summary_by = 6)
                     trim(substring(1,100,charges->c_detail[d.seq].tier_group),3)
                   endif
 
  from
 
   (dummyt d with seq = value(charges->c_cnt))
 
  plan d
 
  order by summary_sort
 
  head page
 
    gbs_cnt = 0
 
  head summary_sort
 
    gbs_cnt = gbs_cnt + 1
    stat  = alterlist(group_by_summary->gbs_detail, gbs_cnt)
 
    group_by_summary->gbs_detail[gbs_cnt].group_by_thing_text             = summary_sort
 
    group_by_summary_cnt = 0
 
  detail
 
    group_by_summary_cnt                                          = group_by_summary_cnt + 1
    group_by_summary->gbs_total_cnt                               = group_by_summary->gbs_total_cnt + 1
    group_by_summary->gbs_total_extended_price                    = group_by_summary->gbs_total_extended_price
                                                                    + charges->c_detail[d.seq].extended_price
    group_by_summary->gbs_detail[gbs_cnt].group_by_extended_price = group_by_summary->gbs_detail[gbs_cnt].group_by_extended_price
                                                                    + charges->c_detail [d.seq].extended_price
 
  foot summary_sort
 
    group_by_summary->gbs_detail[gbs_cnt].group_by_thing_cnt = group_by_summary_cnt
 
  foot report
 
    group_by_summary->gbs_cnt                                  = gbs_cnt
 
  with nocounter
;End Populate record structure for summary output
 
  select into $outdev
 
   from
    (dummyt  d with seq = value(group_by_summary->gbs_cnt))
  plan d
 
  head page
 
    d0 = HeadPageSummarySection(Rpt_Render)
 
  detail
 
    i = d.seq
 
    if(_YOffset + DetailSummarySection(Rpt_CalcHeight) > 7.6)
      d0 = PageBreak(0)
      d0 = HeadPageSummarySection(Rpt_Render)
    endif
 
    d0 = DetailSummarySection(Rpt_Render)
 
  foot report
 
     if(_YOffset + FootSummarySection(Rpt_CalcHeight) > 7.6)
      d0 = PageBreak(0)
      d0 = HeadPageSummarySection(Rpt_Render)
    endif
 
    do = FootSummarySection(Rpt_Render)
 
    if(_YOffset + FootReportSection0(Rpt_CalcHeight) > 7.6)
      d0 = PageBreak(0)
      d0 = HeadPageSummarySection(Rpt_Render)
    endif
 
    d0 = FootReportSection0(Rpt_Render)
 
  with nocounter
 
set d0 = FinalizeReport($OUTDEV)
 
else
;"Excel Format" or "CSV Format"
  select
     if(rpt_output_type = RPT_OUTPUT_EXCEL and reqinfo->updt_app in (4600, 4700, 4800))
        with nocounter, maxrow = 1, format=stream, pcformat('"', ',',1),
        format      ;ensure there's a column heading
     else
        with nocounter, separator=" ", format
     endif
  into
     if(rpt_output_type = RPT_OUTPUT_EXCEL and reqinfo->updt_app in (4600, 4700, 4800))
        value(file_name)
     else
        $outdev
     endif
 
    Interface_Filename                    = trim(substring(1,100,charges->c_detail[d.seq].interface_file_name),3),
    Tier_Group                            = trim(substring(1,100,charges->c_detail[d.seq].tier_group),3),
    Interfaced_Date                       = substring(1,17,format(charges->c_detail[d.seq].posted_date, "@SHORTDATETIME")),
    Organization_Name                     = trim(substring(1,100,charges->c_detail[d.seq].organization_name),3),
    Cost_Center                           = trim(substring(1,40,charges->c_detail[d.seq].cost_center),3),
    FIN                                   = trim(substring(1,40,charges->c_detail[d.seq].fin),3),
    Encounter_Type                        = trim(substring(1,40,charges->c_detail[d.seq].encntr_type),3),
    Patient_Name                          = trim(substring(1,100,charges->c_detail[d.seq].patient_name),3),
    Service_Date_Time                     = substring(1,17,format(charges->c_detail[d.seq].service_date_time, "@SHORTDATETIME")),
    CDM                                   = trim(substring(1,40,charges->c_detail[d.seq].cdm),3),
    CPT                                   = trim(substring(1,40,charges->c_detail[d.seq].cpt),3),
    Description                           = trim(substring(1,200,charges->c_detail[d.seq].description),3),
    Activity_Type                         = trim(substring(1,40,charges->c_detail[d.seq].activity_type),3),
    Charge_Type                           = trim(substring(1,40,charges->c_detail[d.seq].charge_type),3),
    Item_Quantity                         = charges->c_detail[d.seq].item_quantity,
    QCF                                   = charges->c_detail[d.seq].qcf,
    Extended_Quantity                     = charges->c_detail[d.seq].extended_quantity,
    Item_Price                            = charges->c_detail[d.seq].item_price,
    Extended_Price                        = charges->c_detail[d.seq].extended_price
 
  from
    (dummyt  d with seq = value(charges->c_cnt))
  plan d
 
  order by Organization_Name, FIN, Activity_Type, Description
 
  if(rpt_output_type = RPT_OUTPUT_EXCEL and reqinfo->updt_app in (4600, 4700, 4800))
    execute reportrtl
%i cclsource:ccps_cs_interfaced_charges.dvl
    set d0 = InitializeReport(0)
 
    select into $outdev from dummyt
    HEAD REPORT
    display_message = build2("A CSV file has been created and written to:  ", trim(file_name,3), ".",
                             "  The file should contain ", charges->c_cnt, " records.")
    d0 = DispMsgDataSection0(Rpt_Render)
    with nocounter
    set d0 = FinalizeReport($OUTDEV)
  endif
 
endif                                       ;end if report type
 
else                                        ;else if record structure is populated - ie, not populated display a custom message
  execute reportrtl
%i cclsource:ccps_cs_interfaced_charges.dvl
  set d0 = InitializeReport(0)
 
  select into $outdev from dummyt
  HEAD REPORT
  display_message = "There are no interfaced charges for the selected prompts."
  d0 = DispMsgDataSection0(Rpt_Render)
  with nocounter
  set d0 = FinalizeReport($OUTDEV)
endif                                       ;end if record structure is populated
 
#exit_prg
if(ld_failure_flag = 1)
  execute reportrtl
%i cclsource:ccps_cs_interfaced_charges.dvl
  set d0 = InitializeReport(0)
 
  select into $outdev from dummyt
  HEAD REPORT
  d0 = DispMsgDataSection0(Rpt_Render)
  with nocounter
  set d0 = FinalizeReport($OUTDEV)
endif


 
set last_mod = "10/24/2012 MP9098"
 
end go

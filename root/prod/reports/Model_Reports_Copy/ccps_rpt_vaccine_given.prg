drop program ccps_rpt_vaccine_given:dba go
create program ccps_rpt_vaccine_given:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"          ;* Enter or select the printer or file name to send this report to.
	, "Look Back Days" = "365"
	, "Vaccine Name (Full or Partial)" = ""
	, "Select Immunization" = 0
	, "Exclude Patients with # or more doses" = 2   ;* Number must be 2 or greater 

with OUTDEV, P_DAYS_BACK, P_VACCINE, P_IMMUNIZATIONS, P_EXCLUDE_NBR


/*~BB~***********************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
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
  ~BE~***********************************************************************/
/*****************************************************************************
 
   Source file name: ccps_rpt_covid_immun.prg
   Object name:      ccps_rpt_covid_immun
   Task #:
   Request #:
 
   Program purpose:  Report of covid immunizations
 
   Tables read:
 
   Tables updated:
 
   Executing from:
 
   Special Notes:
 
*********************************************************************************************************************************/
;~DB~*****************************************************************************************************************************
;*                      GENERATED MODIFICATION CONTROL LOG                                                                       *
;*********************************************************************************************************************************
;*                                                                                                                               *
;*Mod   Date   Engineer       Comment                                                                                            *
;*--- -------- -------------  -------------------------------------------------------------------------------------------------- *
; 000 09/21/20 SF3151         Initial Release                                                                                    *
;*********************************************************************************************************************************
 
;*** Init/Declare Block =======================================================
if (validate(FALSE,-1) = -1)
   set FALSE         = 0
endif
if (validate(TRUE,-1) = -1)
   set TRUE          = 1
endif
set SELECT_ERROR  = 7      ;*** error selecting item
set LOCK_ERROR    = 8
set INPUT_ERROR   = 9      ;*** error in request data
set EXE_ERROR     = 10     ;*** error in execution of embedded program
set failed        = FALSE  ;*** holds failure status of script
set table_name    = fillstring (50, " ")
set sErrMsg       = fillstring(132, " ")
set iErrCode      = error(sErrMsg,1)
set iErrCode      = 0
declare sScriptErrMsg = vc with protect,noconstant(" ")

free record rData
record rData
(
   1  qual_knt = i4
   1  qual[*]
      2  person_id = f8
      2  name = vc
      2  dob = vc
      2  age = vc
      2  sex = vc
      2  phone_num = vc
      2  encntr_id = f8
      2  mrn_ind = i2
      2  mrn = vc
      2  immun_knt = i4
      2  immun[*]
         3  event_id = f8
         3  order_id = f8
         3  encntr_id = f8
         3  event_class_disp = vc
         3  event_cd = f8
         3  event_disp = vc
         3  event_end_dt_tm = dq8
         3  status = vc
         3  source_disp = vc
         3  catalog_disp = vc
         3  mnemonic = vc
         3  admin_start_dt_tm = dq8
         3  admin_dose = f8
         3  exp_dt_tm = dq8
         3  lot_number = vc
         3  manufacturer = vc
         3  admin_site = vc
         3  admin_pat_loc = vc
)

free record rImmun
record rImmun
(
   1  qual_knt = i4
   1  qual[*]
      2  p_idx = i4
      2  v_idx = i4
      2  event_id = f8
)

declare iExpIdx = i4 with protect,noconstant(0)
declare iLocIdx = i4 with protect,noconstant(0)
declare iPos = i4 with protect,noconstant(0)
declare iEPos = i4 with protect,noconstant(0)
declare iBegPos = i4 with protect,noconstant(0)

declare bPatientsQualified = i2 with protect,noconstant(FALSE)


declare dEncntrAliasMRN = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
declare dPersonAliasMRN = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!2623"))
declare dEventClassImmunization = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!7991"))
declare dResultStatusAuth = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
declare dResultStatusMod = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
declare dResultStatusAlt = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
declare dRecordStatusDeleted = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!2673"))
declare dPhoneTypeHome = f8 with protect,constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))

declare sVaccine = vc with protect,constant(uar_get_code_display($P_IMMUNIZATIONS))
declare sTemp = vc with protect,noconstant(" ")

declare sUsername = vc with protect,noconstant(" ")
declare dLogicalDomainId = f8 with protect,noconstant(0.0)
declare sLogicalDomainName = vc with protect,noconstant(" ")
;==============================================================================

;*** Get User and Logical Domain ==============================================
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
select into "nl:"
from prsnl p
   ,logical_domain ld
plan p
   where p.person_id = reqinfo->updt_id
join ld
   where ld.logical_domain_id = p.logical_domain_id
detail
   sUsername = p.username
   dLogicalDomainId = p.logical_domain_id
   sLogicalDomainName = ld.mnemonic
with nocounter
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "USER LOGICAL DOMAIN"
   set sScriptErrMsg = "SELECT ERROR GETTING USER AND LOGICAL DOMAIN"
   go to GENERATE_REPORT
endif
;==============================================================================

;*** Get Persons of Interest ==================================================
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
select into "nl:"
   ce.person_id
   ,aknt = count(ce.event_id)
from clinical_event ce
   ,person p
plan ce
   where ce.performed_dt_tm between cnvtlookbehind(concat(trim($P_DAYS_BACK,3),",D"))
                                and cnvtdatetime(sysdate)
   and ce.event_cd = $P_IMMUNIZATIONS
   and ce.event_class_cd = dEventClassImmunization
   and ce.result_status_cd in (dResultStatusAuth,dResultStatusMod,dResultStatusAlt)
   and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
   and ce.event_title_text != "Date\Time Correction"
   and ce.view_level = 1
   and ce.record_status_cd != dRecordStatusDeleted
join p
   where p.person_id = ce.person_id
   and p.logical_domain_id = dLogicalDomainId
   and p.deceased_dt_tm = NULL
   and p.active_ind = 1
group by ce.person_id
having count(ce.event_id) > 0
head report
   knt = 0
   iCurSize = 0
head ce.person_id
   knt = knt + 1
   if (knt > iCurSize)
      iCurSize = knt + 9999
      stat = alterlist(rData->qual,iCurSize)
   endif
   rData->qual[knt].person_id = ce.person_id
detail
   null
foot report
   rData->qual_knt = knt
   stat = alterlist(rData->qual,knt)
with nocounter
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "PATIENT DATA"
   set sScriptErrMsg = "SELECT ERROR GETTING PATIENTS WITH AT LEASE 1 DOSE"
   go to GENERATE_REPORT
endif
if (rData->qual_knt < 1)
   set sScriptErrMsg = concat("No Patient Qualified with at least 1 dose of the ",trim(sVaccine,3)," given or documented")
   go to GENERATE_REPORT
endif
;==============================================================================

;*** Get Patients Data ========================================================
set iExpIdx = 0
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
select into "nl:"
   ce.person_id
   ,ce.event_end_dt_tm
   ,ce.event_id
from person p
   ,clinical_event ce
plan p
   where expand(iExpIdx,1,rData->qual_knt,p.person_id,rData->qual[iExpIdx].person_id)
   and p.logical_domain_id = dLogicalDomainId
join ce
   where ce.person_id = p.person_id
   and ce.event_cd = $P_IMMUNIZATIONS
   and ce.performed_dt_tm between cnvtlookbehind(concat(trim($P_DAYS_BACK,3),",D")) and cnvtdatetime(sysdate)
   and ce.event_class_cd = dEventClassImmunization
   and ce.result_status_cd in (dResultStatusAuth,dResultStatusMod,dResultStatusAlt)
   and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
   and ce.event_title_text != "Date\Time Correction"
   and ce.view_level = 1
   and ce.record_status_cd != dRecordStatusDeleted
order p.person_id
   ,ce.event_end_dt_tm desc
   ,ce.event_id
head report
   knt = 0
   iknt = 0
   iTempSize = 0
   iCurSize = 0
head p.person_id
   knt = knt + 1
   iLocIdx = 0
   iPos = locateval(iLocIdx,1,rData->qual_knt,p.person_id,rData->qual[iLocIdx].person_id)
   if (iPos > 0)
      rData->qual[iPos].name = p.name_full_formatted
      rData->qual[iPos].dob = datebirthformat(p.birth_dt_tm, p.birth_tz, 0, "@SHORTDATETIME")
      rData->qual[iPos].sex = uar_get_code_display(p.sex_cd)
      rData->qual[iPos].age = cnvtage(p.birth_dt_tm)
      vknt = 0
      iImmSize = 0
   endif
head ce.event_end_dt_tm
   null
head ce.event_id
   if (iPos > 0)
      vknt = vknt + 1
      if (vknt > iImmSize)
         iImmSize = vknt + 9
         stat = alterlist(rData->qual[iPos].immun,iImmSize)
      endif
      rData->qual[iPos].immun[vknt].event_id = ce.event_id
      rData->qual[iPos].immun[vknt].order_id = ce.order_id
      rData->qual[iPos].immun[vknt].encntr_id = ce.encntr_id
      
      if (vknt = 1)
         rData->qual[iPos].encntr_id = ce.encntr_id
      endif
      
      rData->qual[iPos].immun[vknt].event_class_disp = uar_get_code_display(ce.event_class_cd)
      rData->qual[iPos].immun[vknt].event_cd = ce.event_cd
      rData->qual[iPos].immun[vknt].event_disp = uar_get_code_display(ce.event_cd)
      rData->qual[iPos].immun[vknt].event_end_dt_tm = ce.event_end_dt_tm
      rData->qual[iPos].immun[vknt].status = uar_get_code_display(ce.record_status_cd)
      rData->qual[iPos].immun[vknt].source_disp = uar_get_code_display(ce.source_cd)
      rData->qual[iPos].immun[vknt].catalog_disp = uar_get_code_display(ce.catalog_cd)
      
      iknt = iknt + 1
      if (iknt > iTempSize)
         iTempSize = iknt + 9999
         stat = alterlist(rImmun->qual,iTempSize)
      endif
      rImmun->qual[iknt].event_id = ce.event_id
      rImmun->qual[iknt].p_idx = iPos
      rImmun->qual[iknt].v_idx = vknt
   endif ;*** (iPos > 0)
detail
   null
foot ce.event_id
   null
foot p.person_id
   if (iPos > 0)
      rData->qual[iPos].immun_knt = vknt
      stat = alterlist(rData->qual[iPos].immun,vknt)  

      if (vknt < $P_EXCLUDE_NBR)
         bPatientsQualified = TRUE
      endif
   endif
foot report
   rImmun->qual_knt = iknt
   stat = alterlist(rImmun->qual,iknt)
with nocounter,expand = 1,orahintcbo("index(e xie9clinical_event)")
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "PATIENT DATA"
   set sScriptErrMsg = "SELECT ERROR GETTING PATIENTS DEMOGRAPHIC DATA"
   go to GENERATE_REPORT
endif
if (bPatientsQualified = FALSE)
   set sScriptErrMsg = concat("No Patient Qualified for the ",trim(sVaccine,3),
                              " given or documented with less than ",trim(cnvtstring($P_EXCLUDE_NBR,17,0),3)," doses")
   go to GENERATE_REPORT   
endif
;==============================================================================

;*** Get CMR Data =============================================================
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
set iExpIdx = 0
select into "nl:"
from ce_med_result cmr
plan cmr
   where expand(iExpIdx,1,rImmun->qual_knt,cmr.event_id,rImmun->qual[iExpIdx].event_id)   
   and cmr.updt_dt_tm =
         (
            select max(cmr2.updt_dt_tm)
            from ce_med_result cmr2
            where cmr.event_id = cmr2.event_id
            and cmr2.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
         )
   and cmr.valid_until_dt_tm = cnvtdatetime("31-DEC-2100")
order cmr.event_id
head report
   pknt = 0
   vknt = 0
head cmr.event_id
   iLocIdx = 0
   iPos = locateval(iLocIdx,1,rImmun->qual_knt,cmr.event_id,rImmun->qual[iLocIdx].event_id)
   if (iPos > 0)
      pknt = rImmun->qual[iPos].p_idx
      vknt = rImmun->qual[iPos].v_idx

      rData->qual[pknt].immun[vknt].admin_start_dt_tm = cmr.admin_start_dt_tm
      rData->qual[pknt].immun[vknt].admin_dose = cmr.admin_dosage
      rData->qual[pknt].immun[vknt].exp_dt_tm = cmr.substance_exp_dt_tm
      rData->qual[pknt].immun[vknt].lot_number = cmr.substance_lot_number
      rData->qual[pknt].immun[vknt].manufacturer = uar_get_code_display(cmr.substance_manufacturer_cd)
      rData->qual[pknt].immun[vknt].admin_site = uar_get_code_display(cmr.admin_site_cd)
      rData->qual[pknt].immun[vknt].admin_pat_loc = uar_get_code_display(cmr.admin_pt_loc_cd)
   endif
detail
   null
foot cmr.event_id
   null
foot report
   null
with nocounter,expand = 1
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "PATIENT DATA"
   set sScriptErrMsg = "SELECT ERROR GETTING VACCINE DATA"
   go to GENERATE_REPORT
endif
;==============================================================================

;*** Get MRN ==================================================================
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
set iExpIdx = 0
select into "nl:"
from encntr_alias ea
plan ea
   where expand(iExpIdx,1,rData->qual_knt,ea.encntr_id,rData->qual[iExpIdx].encntr_id)
   and ea.encntr_id != 0.0
   and ea.encntr_alias_type_cd = dEncntrAliasMRN
   and ea.active_ind = 1
   and cnvtdatetime(sysdate) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
order ea.encntr_id
   ,ea.beg_effective_dt_tm desc
head ea.encntr_id
   iBegPos = 1
   while (iBegPos <= rData->qual_knt)
      iLocIdx = 0
      iPos = locateval(iLocIdx,iBegPos,rData->qual_knt,ea.encntr_id,rData->qual[iLocIdx].encntr_id)
      if (iPos > 0)
         rData->qual[iPos].mrn = ea.alias
         rData->qual[iPos].mrn_ind = 1
         iBegPos = iPos + 1
      else
         iBegPos = rData->qual_knt + 1
      endif
   endwhile
with nocounter,expand = 1
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "PATIENT DATA"
   set sScriptErrMsg = "SELECT ERROR GETTING ENCNTR MRN DATA"
   go to GENERATE_REPORT
endif

set iErrCode = error(sErrMsg,1)
set iErrCode = 0
set iExpIdx = 0
select into "nl:"
from person_alias pa
plan pa
   where expand(iExpIdx,1,rData->qual_knt,pa.person_id,rData->qual[iExpIdx].person_id,
                                          0,rData->qual[iExpIdx].mrn_ind)
   and pa.person_id != 0.0
   and pa.person_alias_type_cd = dPersonAliasMRN
   and pa.active_ind = 1
   and cnvtdatetime(sysdate) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
order pa.person_id
   ,pa.beg_effective_dt_tm desc
head pa.person_id
   iBegPos = 1
   while (iBegPos <= rData->qual_knt)
      iLocIdx = 0
      iPos = locateval(iLocIdx,iBegPos,rData->qual_knt,pa.person_id,rData->qual[iLocIdx].person_id,
                                                       0,rData->qual[iLocIdx].mrn_ind)
      if (iPos > 0)
         rData->qual[iPos].mrn = pa.alias
         rData->qual[iPos].mrn_ind = 1
         iBegPos = iPos + 1
      else
         iBegPos = rData->qual_knt + 1
      endif
   endwhile
with nocounter,expand = 1
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "PATIENT DATA"
   set sScriptErrMsg = "SELECT ERROR GETTING PERSON MRN DATA"
   go to GENERATE_REPORT
endif

;==============================================================================

;*** Get Phone Number =========================================================
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
set iExpIdx = 0
select into "nl:"
   p.person_id
   ,ph.phone_type_seq
   ,ph.beg_effective_dt_tm
from person p 
   ,phone ph
plan p
   where expand(iExpIdx,1,rData->qual_knt,p.person_id,rData->qual[iExpIdx].person_id)
   and p.logical_domain_id = dLogicalDomainId
join ph
   where ph.parent_entity_id = p.person_id
   and ph.parent_entity_name = "PERSON"
   and ph.phone_type_cd = dPhoneTypeHome
   and ph.active_ind = 1
   and cnvtdatetime(sysdate) between ph.beg_effective_dt_tm and ph.end_effective_dt_tm
order p.person_id
   ,ph.phone_type_seq
   ,ph.beg_effective_dt_tm desc
head p.person_id
   iLocIdx = 0
   iPos = locateval(iLocIdx,1,rData->qual_knt,p.person_id,rData->qual[iLocIdx].person_id)
   if (iPos > 0)
      if (ph.phone_format_cd > 0)
         rData->qual[iPos].phone_num = cnvtphone(ph.phone_num,ph.phone_format_cd,2)
      else
         rData->qual[iPos].phone_num = ph.phone_num
      endif
   endif
with nocounter,expand = 1
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
   set failed = SELECT_ERROR
   set table_name = "PATIENT DATA"
   set sScriptErrMsg = "SELECT ERROR GETTING PATIENT PHONE NUMBER DATA"
   go to GENERATE_REPORT
endif
;==============================================================================

;*** Generate Output ==========================================================
#GENERATE_REPORT

call echorecord(rData)

if (failed = SELECT_ERROR)
   select into value($OUTDEV)
   from dummyt d
   head report
      row+1
      col 5 sScriptErrMsg
      row+1
      col 5 sErrMsg
      row+2
      col 5 "Prompt Values"
      row+1
      sTemp = concat("Look Back Days = ",trim($P_DAYS_BACK,3))
      col 10 sTemp
      row+1
      stemp = concat("Vaccine Name (Full or Partial) = ",trim($P_VACCINE,3))
      col 10 sTemp
      row+1
      sTemp = concat("Select Immunization = ",trim(sVaccine,3))
      col 10 sTemp
      row+1
      sTemp = concat("Exclude Patients with # or more doses = ",trim(cnvtstring($P_EXCLUDE_NBR,17,0),3))
      col 10 sTemp
      row+1

      sTemp = concat("Username = ",trim(sUsername,3))
      col 10 sTemp
      row+1
      sTemp = concat("Logical Domain = ",trim(sLogicalDomainName,3))
      col 10 sTemp
      row+1
      sTemp = concat("Logical Domain Id = ",trim(cnvtstring(dLogicalDomainId,17,0),3))
      col 10 sTemp
      row+1
   with nocounter
   go to EXIT_SCRIPT
endif
if (rData->qual_knt < 1)
   select into value($OUTDEV)
   from dummyt d
   head report
      row+1
      col 5 sScriptErrMsg
      row+2
      col 5 "Prompt Values"
      row+1
      sTemp = concat("Look Back Days = ",trim($P_DAYS_BACK,3))
      col 10 sTemp
      row+1
      stemp = concat("Vaccine Name (Full or Partial) = ",trim($P_VACCINE,3))
      col 10 sTemp
      row+1
      sTemp = concat("Select Immunization = ",trim(sVaccine,3))
      col 10 sTemp
      row+1
      sTemp = concat("Exclude Patients with # or more doses = ",trim(cnvtstring($P_EXCLUDE_NBR,17,0),3))
      col 10 sTemp
      row+1

      sTemp = concat("Username = ",trim(sUsername,3))
      col 10 sTemp
      row+1
      sTemp = concat("Logical Domain = ",trim(sLogicalDomainName,3))
      col 10 sTemp
      row+1
      sTemp = concat("Logical Domain Id = ",trim(cnvtstring(dLogicalDomainId,17,0),3))
      col 10 sTemp
      row+1
   with nocounter
   go to EXIT_SCRIPT
endif
if (bPatientsQualified = FALSE)
   select into value($OUTDEV)
   from dummyt d
   head report
      row+1
      col 5 sScriptErrMsg
      row+2
      col 5 "Prompt Values"
      row+1
      sTemp = concat("Look Back Days = ",trim($P_DAYS_BACK,3))
      col 10 sTemp
      row+1
      stemp = concat("Vaccine Name (Full or Partial) = ",trim($P_VACCINE,3))
      col 10 sTemp
      row+1
      sTemp = concat("Select Immunization = ",trim(sVaccine,3))
      col 10 sTemp
      row+1
      sTemp = concat("Exclude Patients with # or more doses = ",trim(cnvtstring($P_EXCLUDE_NBR,17,0),3))
      col 10 sTemp
      row+1

      sTemp = concat("Username = ",trim(sUsername,3))
      col 10 sTemp
      row+1
      sTemp = concat("Logical Domain = ",trim(sLogicalDomainName,3))
      col 10 sTemp
      row+1
      sTemp = concat("Logical Domain Id = ",trim(cnvtstring(dLogicalDomainId,17,0),3))
      col 10 sTemp
      row+1
   with nocounter
   go to EXIT_SCRIPT
endif


select into value($OUTDEV)
   mrn = trim(substring(1,100,rData->qual[d.seq].mrn),3)
   ,name = trim(substring(1,100,rData->qual[d.seq].name),3)
   ,dob = trim(substring(1,20,rData->qual[d.seq].dob),3)
   ,age = trim(substring(1,100,rData->qual[d.seq].age),3)
   ,sex = trim(substring(1,20,rData->qual[d.seq].sex),3)
   ,home_phone = trim(substring(1,50,rData->qual[d.seq].phone_num),3)
   ,total_doses = rData->qual[d.seq].immun_knt
   ,event_disp = trim(substring(1,100,rData->qual[d.seq].immun[d2.seq].event_disp),3)
   ,event_end_dt_tm = format(rData->qual[d.seq].immun[d2.seq].event_end_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ,days_since_immun =
         if (rData->qual[d.seq].immun[d2.seq].admin_start_dt_tm = NULL)
            cnvtint(round(datetimediff(cnvtdatetime(sysdate),rData->qual[d.seq].immun[d2.seq].event_end_dt_tm),0))
         else
            cnvtint(round(datetimediff(cnvtdatetime(sysdate),rData->qual[d.seq].immun[d2.seq].admin_start_dt_tm),0))
         endif
   ,source_disp = trim(substring(1,100,rData->qual[d.seq].immun[d2.seq].source_disp),3)
   ,catalog_disp = trim(substring(1,100,rData->qual[d.seq].immun[d2.seq].catalog_disp),3)
   ,admin_dt_tm = format(rData->qual[d.seq].immun[d2.seq].admin_start_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ,admin_dose = rData->qual[d.seq].immun[d2.seq].admin_dose
   ,exp_dt_tm = format(rData->qual[d.seq].immun[d2.seq].exp_dt_tm,"mm/dd/yyyy hh:mm;;q")
   ,lot_nbr = trim(substring(1,100,rData->qual[d.seq].immun[d2.seq].lot_number),3)
   ,manufacturer = trim(substring(1,100,rData->qual[d.seq].immun[d2.seq].manufacturer),3)
   ,admin_site = trim(substring(1,100,rData->qual[d.seq].immun[d2.seq].admin_site),3)
from (dummyt d with seq = value(rData->qual_knt))
   ,(dummyt d2 with seq = 1)
plan d
   where rData->qual[d.seq].immun_knt < $P_EXCLUDE_NBR
   and maxrec(d2, size(rData->qual[d.seq].immun,5))
join d2
order name
   ,total_doses desc
with nocounter,format,separator = " "
;==============================================================================

;*** Exit Script ==============================================================
#EXIT_SCRIPT


end go

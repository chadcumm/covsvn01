;******************************************************************************
;*                                                                            *
;*  Copyright Notice:  (c) 1983 Laboratory Information Systems &              *
;*                              Technology, Inc.                              *
;*       Revision      (c) 1984-2008 Cerner Corporation                       *
;*                                                                            *
;*  Cerner (R) Proprietary Rights Notice:  All rights reserved.               *
;*  This material contains the valuable properties and trade secrets of       *
;*  Cerner Corporation of Kansas City, Missouri, United States of             *
;*  America (Cerner), embodying substantial creative efforts and              *
;*  confidential information, ideas and expressions, no part of which         *
;*  may be reproduced or transmitted in any form or by any means, or          *
;*  retained in any storage or retrieval system without the express           *
;*  written permission of Cerner.                                             *
;*                                                                            *
;*  Cerner is a registered mark of Cerner Corporation.                        *
;*                                                                            *
;*                                                                            *
;******************************************************************************
;
;
;     Source file name:       pmdbdocs_driver.prg
;
;     Product:                Revenue Cycle
;     Product Team:           Registration
;     HNA Version:
;     CCL Version:
;
;     Program purpose:        Create a subset of the pm_prt_documents request (114557)
;                             for use in layout programs
;
;     Tables read:            None
;
;     Tables updated:         None
;
;     Special Notes:          None
;
;******************************************************************************
;                      GENERATED MODIFICATION CONTROL LOG
;******************************************************************************
;
; Feature Date         Engineer   Comment (SR #)
; ------- -----------  ---------- ---------------------------------------------
; 518573  12/01/16     KE4137     Copied script from Solutions Center Custom Discern Team
;                      KE4137     Edited for testing driver    
; 585973  06/25/18     KE4137     Fixed organization values
;         02-NOV-2016  CC020064   Added Mobile and Business phone numbers
;                                 for Patient, Guarantor, EMC, and NOK
;         01-JAN-2017  CC020064   Added birth_tz lines for dates of birth
;         19-NOV-2018  AE044309   Added Birth Sex
;         02-JAN-2020  HL017324   Added birth_prec_flag
;         03-SEP-2020  JW017159   Corrected performance concerns with observation_dt_tm
; 716240  01-MAY-2020  KE4137     Added patient previous, temp, bill, business, mail, and email addresses
;                                 Added person business, email, temp, and mail addresses to related persons
;                                 Added temp phone for related persons
;                                 Added additional guarantor information
; 742465  01-OCT-2021  JW5489     Added new first class fields 
;                                 Added outpatient in bed dt/tm, clinical discharge dt/tm
;                                 Added person_udf and encntr_udf record structures
;                                 Get email address from PHONE for REVCYCLE if EMAIL SYNC is PHONE
;                                 Added formatted date of birth fields
;******************************************************************************
  drop program pmdbdocs_driver:dba go
create program pmdbdocs_driver:dba

call echo("*****pmdbdocs_driver.prg - 716240 01-MAY-2020 - 742465  01-OCT-2021 *****")

set trace = NOCOST
set message = NOINFORMATION

;**************************************************************
; DECLARED VARIABLES
;**************************************************************
if (validate(bDebugMe, -9) = -9)
   declare bDebugMe = i2 with noconstant(FALSE) ;enable to echo pm_parser
endif

declare s_PERSON_UDF = vc with constant("request->patient_data->person->user_defined->"), protect
declare s_ENCNTR_UDF = vc with constant("request->patient_data->person->encounter->user_defined->"), protect
declare s_FORMAT_STR = vc with constant(fillstring(110, "#")), protect
declare d_CS355_UDF_CD  = f8 with constant(uar_get_code_by("MEANING",355,"USERDEFINED")), protect
declare d_CS4002773_OBS_START_DT = f8 with constant(uar_get_code_by("MEANING",4002773, "STARTOBS")), protect
declare d_CS4002773_OUTPATINBED_CD = f8 with constant(uar_get_code_by("MEANING", 4002773, "OUTPATINBED")), protect
declare d_CS4002773_CLINDISCHRG_CD = f8 with constant(uar_get_code_by("MEANING", 4002773, "CLINDISCHRG")), protect
declare d_CS213_CURRENT_NAME_CD = f8 with constant(uar_get_code_by("MEANING",213,"CURRENT")), protect
declare d_CS213_ALTCHAR_NAME_CD = f8 with constant(uar_get_code_by("MEANING",213,"ALT_CHAR_CUR")), protect
declare d_CS213_PRSNL_NAME_TYPE = f8 with constant(uar_get_code_by("MEANING", 213, "PRSNL")), protect
declare d_CS212_BUSINESS_ADDR_CD = f8 with constant(uar_get_code_by("MEANING",212,"CURRENT")), protect
declare d_CS43_BUSINESS_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"BUSINESS")), protect
declare d_CS43_HOME_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"HOME")), protect
declare d_CS43_MOBILE_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"MOBILE")), protect
declare d_CS43_PRIM_HOME_CD= f8 with constant(uar_get_code_by("MEANING",43,"PHOME")), protect
declare d_CS43_AAM_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"AAM")), protect
declare d_CS43_PAGING_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"PAGING")), protect
declare d_CS43_EXTSECEMAIL_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"EXTSECEMAIL")), protect
declare d_CS43_VHOME_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"VHOME")), protect
declare d_CS43_EMC_PHONE_CD= f8 with constant(uar_get_code_by("MEANING",43,"EMC")), protect
declare l_DOB_CCL_VER8_MIN   = i4 with constant(800140001), protect
declare l_DOB_CCL_VER_CUT    = i4 with constant(900000000), protect
declare l_DOB_CCL_VER9_MIN   = i4 with constant(900020001), protect
declare l_BIRTH_PREC_EXISTS  = i4 with constant(CHECKDIC("PERSON.BIRTH_PREC_FLAG ", "A", 0)), protect
declare l_BIRTH_FXN_EXISTS   = i4 with constant(CHECKFUN("DATEBIRTHFORMAT"))
declare dt_BLANK_DATE        = dq8 with constant(cnvtdatetime("01-JAN-1800 00:00:00.00")), protect

declare lIdx = i4 with noconstant(0), protect
declare lCnt = i4 with noconstant(0), protect
declare lSortCnt = i4 with noconstant(0), protect
declare lStart = i4 with noconstant(1), protect
declare sChkField = vc with noconstant(""), protect
declare bUseNewDOBFxn = i2 with noconstant(FALSE), protect
declare lCCLVer = i4 with private, noconstant(cnvtint(build(currev,
                                format(currevminor,"####;P0"), format(currevminor2,"####;P0")))), protect
declare bIsRevCycle = i2 with noconstant(FALSE), protect
declare bIsPmOffice = i2 with noconstant(FALSE), protect
 
if (reqinfo->updt_task >= 100000 and reqinfo->updt_task < 200000)
   set bIsPmOffice = TRUE
else
   set bIsRevCycle = TRUE
endif

;set date of birth formatting function
if (l_BIRTH_PREC_EXISTS > 0 and l_BIRTH_FXN_EXISTS > 0)
   if (lCCLVer >= l_DOB_CCL_VER8_MIN and lCCLVer < l_DOB_CCL_VER_CUT)
      set bUseNewDOBFxn = TRUE
   elseif (lCCLVer >= l_DOB_CCL_VER9_MIN)
      set bUseNewDOBFxn = TRUE
   endif
endif

call DebugPrint("initializing")
call DebugPrint(build("bIsPmOffice::", bIsPmOffice))
call DebugPrint(build("bIsRevCycle::", bIsRevCycle))
call DebugPrint(build("using new DOB function::", bUseNewDOBFxn))

;Map User Defined Data to recordsets?
declare bMapUdf = i2 with noconstant(FALSE), protect
set bMapUdf = FALSE ;set value to TRUE to copy user_defined_fields into encntr_udf and person_udf record structures
call DebugPrint(build("bMapUdf::", bMapUdf))

;Get data from PERSON_DATA_NOT_COLL?
declare bGetPerColl = i2 with noconstant(FALSE), protect
set bGetPerColl = FALSE ;set value to TRUE to get PERSON_DATA_NOT_COLL data; validate all columns exist in detail on code level
call DebugPrint(build("bGetPerColl::", bGetPerColl))

;Get data from ENCNTR_DATA_NOT_COLL?
declare bGetEncColl = i2 with noconstant(FALSE), protect
set bGetEncColl = FALSE ;set value to TRUE to get ENCNTR_DATA_NOT_COLL data; validate all columns in detail exist on code level
call DebugPrint(build("bGetEncColl::", bGetEncColl))

;Check Where Email Addresses Are Stored
declare bEmailOnPhone = i2 with noconstant(FALSE), protect
select into "nl:"
 cv.code_value
from code_value cv, code_value_extension ce
plan cv
 where cv.code_set = 20790
   and cv.cdf_meaning = "EMAILSYNC"
   and cv.active_ind = 1
join ce
 where ce.code_value = cv.code_value
   and ce.field_name = "OPTION"
detail
 if (trim(cnvtupper(cnvtalphanum(ce.field_value)), 3) = "PHONE")
     bEmailOnPhone = TRUE
 endif
with nocounter
call DebugPrint(build("bEmailOnPhone::", bGetEncColl))

;**************************************************************
; DECLARED SUBROUTINES
;**************************************************************
declare DebugPrint(sEchoStr = vc) = null 
; Description: Writes a message to the screen
; sEchoStr: text to write to the screen
; Returns: null
subroutine DebugPrint(sEchoStr)
   call echo(concat(format(sEchoStr, s_FORMAT_STR), format(cnvtdatetime(sysdate), "MM/DD/YYYY HH:MM:SS;;D")))
end ;DebugPrint

;********************************************************************************
; Get Names For Record
;********************************************************************************
; Description: <todo>
;
; Inputs: rec [vc] - represents the position of the record to be updated
;         person_id [f8] - unique id of person who's names are to be loaded
;********************************************************************************
declare GetNamesForRecord(rec=vc, person_id=f8) = null with public
subroutine GetNamesForRecord(rec, person_id)

    if (person_id > 0.0)
       call parser(concat("set curalias _namerec ", rec, " go"))

       select into "nl:"
       from person p
       where p.person_id = person_id
       detail
           _namerec->name_full_formatted = trim(p.name_full_formatted, 3)
           _namerec->name_first = trim(p.name_first, 3)
           _namerec->name_first_key = trim(p.name_first_key, 3)
           _namerec->name_last = trim(p.name_last, 3)
           _namerec->name_last_key = trim(p.name_last_key, 3)
           _namerec->name_middle = trim(p.name_middle, 3)
       with nocounter

       set curalias _namerec off
   endif

end ;subroutine GetNamesForRecord
 
declare GetPrsnlName(rec=vc, person_id=f8) = null with public
subroutine GetPrsnlName(rec, person_id)

    if (person_id > 0.0)
       call parser(concat("set curalias _namerec ", rec, " go"))

       select into "nl:"
       from person_name p
       plan p
        where p.person_id = person_id
          and p.name_type_cd = d_CS213_PRSNL_NAME_TYPE
          and p.active_ind = 1
          and p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
          and p.end_effective_dt_tm > cnvtdatetime(sysdate)     
       order by p.name_type_seq, cnvtdatetime(p.beg_effective_dt_tm) desc
       detail
           _namerec->name_full_formatted = trim(p.name_full, 3)
           _namerec->name_first = trim(p.name_first, 3)
           _namerec->name_last = trim(p.name_last, 3)
           _namerec->name_middle = trim(p.name_middle, 3)
       with nocounter

       set curalias _namerec off
   endif

end ;subroutine GetPrsnlName

declare GetAltCharName(rec=vc, person_id=f8) = null with public
subroutine GetAltCharName(rec, person_id)

    if (person_id > 0.0)
       call parser(concat("set curalias _namerec ", rec, " go"))

       select into "nl:"
       from person_name pn
       where pn.person_id = person_id
         and pn.name_type_cd = d_CS213_ALTCHAR_NAME_CD
         and pn.active_ind  = 1
         and pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         and pn.end_effective_dt_tm > cnvtdatetime(sysdate)
       order by pn.beg_effective_dt_tm
       detail
           _namerec->name_full_formatted = trim(pn.name_full, 3)
           _namerec->name_first = trim(pn.name_first, 3)
           _namerec->name_last = trim(pn.name_last, 3)
           _namerec->name_middle = trim(pn.name_middle, 3)
       with nocounter

       set curalias _namerec off
   endif

end ;subroutine GetAltCharName
 
declare GetOrgName(org_id=f8) = vc with public
subroutine GetOrgName(org_id)
 
    declare orgname = vc with noconstant("")
 
    select into "nl:"
    from organization o
    plan o
     where o.organization_id = org_id
    detail
     orgname = trim(o.org_name, 3)
    with nocounter

   return (orgname)
end ;subroutine GetOrgName
 
declare GetNameFF(person_id=f8) = vc with public
subroutine GetNameFF(person_id)
 
    declare prsnlname = vc with noconstant("")
 
    select into "nl:"
    from prsnl p
    plan p
     where p.person_id = person_id
    detail
     prsnlname = trim(p.name_full_formatted, 3)
    with nocounter

   return (prsnlname) 
end ;subroutine GetNameFF

declare GetPatientEmail(rec=vc, person_id=f8) = null with public
subroutine GetPatientEmail(rec, person_id)
    
    if (person_id > 0.0)
       call parser(concat("set curalias _emailrec ", rec, " go"))

       select into "nl:"
       from phone p
       plan p
        where p.parent_entity_id = person_id
          and p.parent_entity_name = "PERSON_PATIENT"
          and p.phone_type_cd in (d_CS43_BUSINESS_PHONE_CD,
                                  d_CS43_HOME_PHONE_CD,
                                  d_CS43_MOBILE_PHONE_CD,
                                  d_CS43_PRIM_HOME_CD,
                                  d_CS43_AAM_PHONE_CD,
                                  d_CS43_PAGING_PHONE_CD,
                                  d_CS43_EXTSECEMAIL_PHONE_CD,
                                  d_CS43_VHOME_PHONE_CD,
                                  d_CS43_EMC_PHONE_CD)
          and p.active_ind = 1
          and p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
          and p.end_effective_dt_tm > cnvtdatetime(sysdate)     
       order by p.phone_type_cd, p.phone_type_seq, 
          cnvtdatetime(p.beg_effective_dt_tm) desc, cnvtdatetime(p.end_effective_dt_tm) desc
       detail
        if (p.phone_type_cd = d_CS43_BUSINESS_PHONE_CD)
           _emailrec->bus_email.phone_id = p.phone_id
           _emailrec->bus_email.email = trim(p.phone_num, 3)
           _emailrec->bus_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->bus_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_HOME_PHONE_CD)
           _emailrec->home_email.phone_id = p.phone_id
           _emailrec->home_email.email = trim(p.phone_num, 3)
           _emailrec->home_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->home_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_MOBILE_PHONE_CD)
           _emailrec->mobile_email.phone_id = p.phone_id
           _emailrec->mobile_email.email = trim(p.phone_num, 3)
           _emailrec->mobile_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->mobile_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_PRIM_HOME_CD)
           _emailrec->pri_home_email.phone_id = p.phone_id
           _emailrec->pri_home_email.email = trim(p.phone_num, 3)
           _emailrec->pri_home_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->pri_home_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_AAM_PHONE_CD)
           _emailrec->aam_email.phone_id = p.phone_id
           _emailrec->aam_email.email = trim(p.phone_num, 3)
           _emailrec->aam_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->aam_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_PAGING_PHONE_CD)
           _emailrec->paging_email.phone_id = p.phone_id
           _emailrec->paging_email.email = trim(p.phone_num, 3)
           _emailrec->paging_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->paging_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_EXTSECEMAIL_PHONE_CD)
           _emailrec->secure_email.phone_id = p.phone_id
           _emailrec->secure_email.email = trim(p.phone_num, 3)
           _emailrec->secure_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->secure_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_VHOME_PHONE_CD)
           _emailrec->vac_home_email.phone_id = p.phone_id
           _emailrec->vac_home_email.email = trim(p.phone_num, 3)
           _emailrec->vac_home_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->vac_home_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        elseif (p.phone_type_cd = d_CS43_EMC_PHONE_CD)
           _emailrec->emc_email.phone_id = p.phone_id
           _emailrec->emc_email.email = trim(p.phone_num, 3)
           _emailrec->emc_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
           _emailrec->emc_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm)
        endif     
       with nocounter

       set curalias _emailrec off
    endif
 
end ;subroutine GetPatientEmail

declare getFormattedDob(dBirthDtRaw=dq8, lBirthTz=i4, bBirthFlag=i2) = vc
/*************************************************************************************
* getFormattedDob
* This subrountine generates a formatted date of birth based
* parameters:
*  1.dBirthDtRaw : raw birth date
*  2.lBirthTz : birth date time zone context
*  3.bBirthFlag : birth date precision flag
*************************************************************************************/
SUBROUTINE getFormattedDob(dBirthDtRaw, lBirthTz, bBirthFlag)
  declare sBirthDtFormatted = vc with noconstant(""), protect
  
  if (dBirthDtRaw != null and dBirthDtRaw > 0.0 and dBirthDtRaw > cnvtdatetime(dt_BLANK_DATE))
     if (bUseNewDOBFxn = TRUE)
        set sBirthDtFormatted = datebirthformat(dBirthDtRaw, lBirthTz, bBirthFlag, "@SHORTDATE4YR")
     else
        set sBirthDtFormatted = datetimezoneformat(dBirthDtRaw, lBirthTz, "@SHORTDATE4YR")
     endif
  endif
  
  return(sBirthDtFormatted)
END ;getFormattedDob

declare GetReltnEmail(rec=vc, person_id=f8) = null with public
subroutine GetReltnEmail(rec, person_id)
    
    if (person_id > 0.0)
       call parser(concat("set curalias _emailrec ", rec, " go"))

       select into "nl:"
       from phone p
       plan p
        where p.parent_entity_id = person_id
          and p.parent_entity_name = "PERSON_PATIENT"
          and p.phone_type_cd = d_CS43_HOME_PHONE_CD
          and p.active_ind = 1
          and p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
          and p.end_effective_dt_tm > cnvtdatetime(sysdate)     
       order by p.phone_type_cd, p.phone_type_seq, 
          cnvtdatetime(p.beg_effective_dt_tm) desc, cnvtdatetime(p.end_effective_dt_tm) desc
       detail
        _emailrec->home_email.phone_id = p.phone_id
        _emailrec->home_email.email = trim(p.phone_num, 3)
        _emailrec->home_email.beg_effective_dt_tm = cnvtdatetime(p.beg_effective_dt_tm)
        _emailrec->home_email.end_effective_dt_tm = cnvtdatetime(p.end_effective_dt_tm) 
       with nocounter

       set curalias _emailrec off
   endif
   
end ;subroutine GetReltnEmail

declare add_udf_attribute(sAttrField = vc, sAttrType = vc, sAttrLevel = vc, dUdfCd = f8, sUdfCDF = vc) = null
; Description: adds attributes into the pm_udf record structure
; sAttrField: field name
; sAttrType: field type
; sAttrLevel: field level
; dUdfCd: udf code value (optional)
; sUdfCDF: udf cdf meaning (optional)
; Returns: null
subroutine add_udf_attribute(sAttrField, sAttrType, sAttrLevel, dUdfCd, sUdfCDF)
   set lStart = 1
   set lSortCnt = 0
   set lIdx = 0
   set sChkField = ""
   
   set sChkField = trim(strip_bad_chars(cnvtlower(sAttrField)), 3)
   
   if (trim(cnvtupper(sAttrLevel), 3) = "PERSON")
      if (textlen(sChkField) > 0 and pm_udf->p_cnt > 0)
        set lIdx = locateval(lSortCnt, lStart, pm_udf->p_cnt, sChkField, pm_udf->p_list[lSortCnt]->p_val)
      endif
   elseif (trim(cnvtupper(sAttrLevel), 3) = "ENCOUNTER")
      if (textlen(sChkField) > 0 and pm_udf->e_cnt > 0)
        set lIdx = locateval(lSortCnt, lStart, pm_udf->e_cnt, sChkField, pm_udf->e_list[lSortCnt]->e_val)
      endif
   endif      
    
   if (lIdx <= 0) 
      set pm_udf->ids_cnt += 1
   
      if (pm_udf->ids_cnt > size(pm_udf->ids,5))
         set stat = alterlist(pm_udf->ids, pm_udf->ids_cnt + 99)
      endif
 
      set pm_udf->ids[pm_udf->ids_cnt]->field = sChkField
      set pm_udf->ids[pm_udf->ids_cnt]->type = trim(cnvtupper(sAttrType), 3)
      set pm_udf->ids[pm_udf->ids_cnt]->level = trim(cnvtupper(sAttrLevel), 3)
      set pm_udf->ids[pm_udf->ids_cnt]->code_value = dUdfCd
      set pm_udf->ids[pm_udf->ids_cnt]->cdf_meaning = sUdfCDF

      if (pm_udf->ids[pm_udf->ids_cnt].type = "STRING")
         set pm_udf->ids[pm_udf->ids_cnt].rec_type = "vc"
      elseif (pm_udf->ids[pm_udf->ids_cnt].type = "CODE")
         set pm_udf->ids[pm_udf->ids_cnt].rec_type = "f8"
      elseif (pm_udf->ids[pm_udf->ids_cnt].type = "DATE")
         set pm_udf->ids[pm_udf->ids_cnt].rec_type = "dq8"
      elseif (pm_udf->ids[pm_udf->ids_cnt].type = "NUMERIC")
         set pm_udf->ids[pm_udf->ids_cnt].rec_type = "i4"
      endif

      set pm_udf->ids[pm_udf->ids_cnt].rec_str = concat(" 1 ", 
                                       pm_udf->ids[pm_udf->ids_cnt].field,
                                       " = ",
                                       pm_udf->ids[pm_udf->ids_cnt].rec_type)

      if (pm_udf->ids[pm_udf->ids_cnt].level = "PERSON")
         set pm_udf->ids[pm_udf->ids_cnt].person_ind = TRUE
         set pm_udf->ids[pm_udf->ids_cnt].copy_str_src = concat("set person_udf->", pm_udf->ids[pm_udf->ids_cnt]->field,
                                                            " =")
         set pm_udf->ids[pm_udf->ids_cnt].src_fld = concat(s_PERSON_UDF, pm_udf->ids[pm_udf->ids_cnt]->field)
         set pm_udf->ids[pm_udf->ids_cnt].copy_str_des1 = s_PERSON_UDF
         set pm_udf->ids[pm_udf->ids_cnt].copy_str_des2 = concat(pm_udf->ids[pm_udf->ids_cnt]->field,
                                                            " go")
         set pm_udf->p_cnt += 1
         set stat = alterlist(pm_udf->p_list, pm_udf->p_cnt)
         set pm_udf->p_list[pm_udf->p_cnt].p_val = pm_udf->ids[pm_udf->ids_cnt]->field
         set pm_udf->p_list[pm_udf->p_cnt].p_cv = dUdfCd
      elseif (pm_udf->ids[pm_udf->ids_cnt].level = "ENCOUNTER")
         set pm_udf->ids[pm_udf->ids_cnt].encntr_ind = TRUE
         set pm_udf->ids[pm_udf->ids_cnt].copy_str_src = concat("set encntr_udf->", pm_udf->ids[pm_udf->ids_cnt]->field,
                                                            " =")
         set pm_udf->ids[pm_udf->ids_cnt].src_fld = concat(s_ENCNTR_UDF, pm_udf->ids[pm_udf->ids_cnt]->field)
         set pm_udf->ids[pm_udf->ids_cnt].copy_str_des1 = s_ENCNTR_UDF
         set pm_udf->ids[pm_udf->ids_cnt].copy_str_des2 = concat(pm_udf->ids[pm_udf->ids_cnt]->field,
                                                            " go")
         set pm_udf->e_cnt += 1
         set stat = alterlist(pm_udf->e_list, pm_udf->e_cnt)
         set pm_udf->e_list[pm_udf->e_cnt].e_val = pm_udf->ids[pm_udf->ids_cnt]->field
         set pm_udf->e_list[pm_udf->e_cnt].e_cv = dUdfCd
      endif
   endif
end

declare strip_bad_chars(sTxtIn = vc) = vc
; Description: strips characters from field name that interfere with parser
; sTxtIn: field input
; Returns: field output
subroutine strip_bad_chars(sTxtIn)
 declare sTxtOut = vc with noconstant(""), protext
 set sTxtOut = trim(sTxtIn, 3)
 
 if (textlen(sTxtOut) > 0)
    set sTxtOut = replace(sTxtOut,char(13),"")
    set sTxtOut = replace(sTxtOut,char(10),"")
    set sTxtOut = replace(sTxtOut,"|","")
    set sTxtOut = replace(sTxtOut,"~","")
    set sTxtOut = replace(sTxtOut,"'","")
    set sTxtOut = replace(sTxtOut,"-","")
    set sTxtOut = replace(sTxtOut,"=","")
    set sTxtOut = replace(sTxtOut,"\","")
    set sTxtOut = replace(sTxtOut,"/","")
    set sTxtOut = replace(sTxtOut,"%","")
    set sTxtOut = replace(sTxtOut,"^","")
    set sTxtOut = replace(sTxtOut,"&","")
    set sTxtOut = replace(sTxtOut,"*","")
    set sTxtOut = replace(sTxtOut,"(","")
    set sTxtOut = replace(sTxtOut,")","")
    set sTxtOut = replace(sTxtOut," ","")
    set sTxtOut = replace(sTxtOut,'"','')
 endif
 return(trim(sTxtOut, 3))
end

declare pm_parser(sStatement = vc) = null
; Description: runs parser routine
; sStatement: string statement to run
; Returns: null
subroutine pm_parser(sStatement)
   call parser(sStatement)
   if (bDebugMe)
      call echo(sStatement)
   endif
end
 
;**************************************************************
; DECLARED RECORD STRUCTURE
;**************************************************************
call DebugPrint("defining record structures")

free record pm_udf
record pm_udf (
 1 p_cnt = i4
 1 p_list[*]
  2 p_val = vc
  2 p_cv = f8
 1 e_cnt = i4
 1 e_list[*]
  2 e_val = vc
  2 e_cv = f8
 1 ids_cnt = i4
 1 ids[*]
  2 code_value = f8 
  2 cdf_meaning = vc
  2 field = vc
  2 type = vc
  2 level = vc
  2 value_cd = f8
  2 value_dt_tm = dq8
  2 value_numeric = i4
  2 value_string = vc
  2 person_ind = i2
  2 encntr_ind = i2
  2 rec_type = vc
  2 rec_str = vc
  2 src_fld = vc
  2 copy_str_src = vc
  2 copy_str_des1 = vc
  2 copy_str_des2 = vc)
  
free record pmdbdoc
record pmdbdoc (
/*Printing Info*/
 1 output_dest_cd = f8
 1 output_dest_name = vc
 1 file_name = c32
 1 copies = i4
 1 destination[*]
  2 program_name = c32
  2 output_dest_cd = f8
  2 copies = i4
/*Transaction Info*/
 1 patient_data
  2 transaction_type = i2
  2 transaction_id = f8
  2 transaction_info
   3 prsnl_id = f8
   3 name_full_formatted = vc
   3 position_cd = f8
   3 trans_dt_tm = dq8
   3 transaction_txt = vc
   3 pc_identifier = vc
   3 conversation_task = i4
/*Patient Info*/
  2 person
   3 person_id = f8
   3 name_full_formatted = vc
   3 name_first = vc
   3 name_last = vc
   3 name_first_key = vc
   3 name_last_key = vc
   3 birth_dt_tm = dq8
   3 birth_tz = i4
   3 birth_prec_flag = i2
   3 birth_dt_formatted = vc
   3 age = vc
   3 language_cd = f8
   3 language_disp = vc
   3 marital_type_cd = f8
   3 marital_type_disp = vc
   3 race_cd = f8
   3 race_disp = vc
   3 ethnic_grp_cd = f8
   3 nationality_cd = f8
   3 nationality_disp = vc
   3 religion_cd = f8
   3 religion_disp = vc
   3 sex_cd = f8
   3 sex_disp = vc
   3 vip_cd = f8
   3 vip_disp = vc
   3 name_middle = vc
   3 alt_char_name
    4 name_first = vc
    4 name_last = vc
    4 name_middle = vc
    4 name_full_formatted = vc
   3 patient
    4 church_cd = f8
    4 church_disp = vc
    4 interp_required_cd = f8
    4 interp_required_disp = vc
    4 living_will_cd = f8
    4 living_will_disp = vc
    4 disease_alert_cd = f8
    4 process_alert_cd = f8
    4 process_alert_disp = vc
    4 disease_alert_cd = f8
    4 disease_alert_disp = vc
    4 birth_sex_cd = f8
    4 birth_sex_disp = vc
/*Patient Address Info*/
   3 home_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 prev_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 alt_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 temp_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 bill_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 birth_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 bus_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 mail_address
    4 address_id = f8
    4 street_addr = vc
    4 street_addr2 = vc
    4 street_addr3 = vc
    4 street_addr4 = vc
    4 city = vc
    4 state = vc
    4 state_cd = f8
    4 state_disp = vc
    4 zipcode = vc
    4 county = vc
    4 county_cd = f8
    4 country = vc
    4 country_cd = f8
   3 email_address
    4 address_id = f8
    4 street_addr = vc
/*Patient Phones Info*/
   3 home_phone
    4 phone_id = f8
    4 phone_formatted = vc
    4 phone_format_cd = f8
    4 phone_num = vc
    4 extension = vc
   3 home_pager
    4 phone_id = f8
    4 phone_formatted = vc
    4 phone_format_cd = f8
    4 phone_num = vc
    4 extension = vc
   3 alt_phone
    4 phone_id = f8
    4 phone_formatted = vc
    4 phone_format_cd = f8
    4 phone_num = vc
    4 extension = vc
   3 temp_phone
    4 phone_id = f8
    4 phone_formatted = vc
    4 phone_format_cd = f8
    4 phone_num = vc
    4 extension = vc
   3 bus_phone
    4 phone_id = f8
    4 phone_formatted = vc
    4 phone_format_cd = f8
    4 phone_num = vc
    4 extension = vc
   3 mobile_phone
    4 phone_id = f8
    4 phone_formatted = vc
    4 phone_format_cd = f8
    4 phone_num = vc
    4 extension = vc
/*Patient Aliases Info*/
   3 mrn
    4 mrn_formatted = vc
    4 alias_pool_cd = f8
    4 person_alias_type_cd = f8
    4 alias = vc
    4 person_alias_sub_type_cd = f8
   3 ssn
    4 ssn_formatted = vc
    4 alias_pool_cd = f8
    4 person_alias_type_cd = f8
    4 alias = vc
    4 person_alias_sub_type_cd = f8
   3 cmrn
    4 cmrn_formatted = vc
    4 alias_pool_cd = f8
    4 person_alias_type_cd = f8
    4 alias = vc
    4 person_alias_sub_type_cd = f8
/*Patient PCP Info*/
   3 pcp
    4 name_full_formatted = vc
    4 name_first = vc
    4 name_last = vc
    4 name_middle = vc
    4 person_prsnl_reltn_id = f8
    4 person_id = f8
    4 person_prsnl_r_cd = f8
    4 prsnl_person_id = f8
/*Person Comments*/
   3 comment_01
    4 long_text = vc
/*Patient Employer Info*/
   3 employer_01
    4 person_org_reltn_id = f8
    4 person_id = f8
    4 person_org_reltn_cd = f8
    4 organization_id = f8
    4 organization_name = vc
    4 person_org_nbr = vc
    4 person_org_alias = vc
    4 empl_retire_dt_tm = dq8
    4 empl_type_cd = f8
    4 empl_status_cd = f8
    4 empl_occupation_text = vc
    4 empl_occupation_cd = f8
    4 address
     5 address_id = f8
     5 street_addr = vc
     5 street_addr2 = vc
     5 street_addr3 = vc
     5 street_addr4 = vc
     5 city = vc
     5 state = vc
     5 state_cd = f8
     5 state_disp = vc
     5 zipcode = vc
     5 county = vc
     5 county_cd = f8
     5 country = vc
     5 country_cd = f8
    4 phone
     5 phone_formatted = vc
     5 phone_format_cd = f8
     5 phone_num = vc
     5 extension = vc
/*Person Data Not Collected*/
   3 person_data_not_coll
    4 ssn_cd = f8
    4 home_address_cd = f8
    4 phone_cd = f8
    4 home_email_cd = f8
    4 primary_care_physician_cd = f8
    4 national_health_nbr_cd = f8
    4 drivers_license_cd = f8
    4 biometric_ident_cd = f8
/*Person Email Phone Table*/
   3 home_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 pri_home_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 vac_home_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 bus_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 aam_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 emc_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 paging_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 mobile_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
   3 secure_email
    4 phone_id = f8
    4 email = vc
    4 beg_effective_dt_tm = dq8
    4 end_effective_dt_tm = dq8
/*Encounter Info*/
   3 encounter
    4 encntr_id = f8
    4 last_updt_prsnl_name = vc
    4 last_updt_dt_tm = dq8
    4 encntr_class_cd = f8
    4 encntr_type_cd = f8
    4 encntr_type_disp = vc
    4 encntr_type_class_cd = f8
    4 encntr_status_cd = f8
    4 pre_reg_dt_tm = dq8
    4 pre_reg_prsnl_id = f8
    4 reg_dt_tm = dq8
    4 reg_prsnl_id = f8
    4 reg_prsnl_name_full = vc
    4 est_arrive_dt_tm = dq8
    4 est_depart_dt_tm = dq8
    4 inpatient_admit_dt_tm = dq8
    4 observation_dt_tm = dq8
    4 clinical_discharge_dt_tm = dq8
    4 outpatient_in_bed_dt_tm = dq8
    4 service_dt_tm = dq8
    4 arrive_dt_tm = dq8
    4 depart_dt_tm = dq8
    4 admit_type_cd = f8
    4 admit_type_disp = vc
    4 admit_src_cd = f8
    4 admit_src_disp = vc
    4 admit_mode_cd = f8
    4 admit_mode_disp = vc
    4 disch_disposition_cd = f8
    4 disch_disposition_disp = vc
    4 disch_to_loctn_cd = f8
    4 disch_to_loctn_disp = vc
    4 accommodation_cd = f8
    4 accommodation_disp = vc
    4 accommodation_request_cd = f8
    4 ambulatory_cond_cd = f8
    4 ambulatory_cond_disp = vc
    4 courtesy_cd = f8
    4 isolation_cd = f8
    4 isolation_disp = vc
    4 med_service_cd = f8
    4 med_service_disp = vc
    4 vip_cd = f8
    4 vip_disp = vc
    4 location_cd = f8
    4 loc_facility_cd = f8
    4 loc_facility_disp = vc
    4 loc_building_cd = f8
    4 loc_nurse_unit_cd = f8
    4 loc_nurse_unit_disp = vc
    4 loc_room_cd = f8
    4 loc_room_disp = vc
    4 loc_bed_cd = f8
    4 loc_bed_disp = vc
    4 facilityorg
     5 organization_name = vc
     5 organization_id = f8
     5 bus_phone
      6 phone_formatted = vc
      6 phone_id = f8
      6 phone_nbr = vc
      6 phone_format_cd = f8
     5 bus_address
      6 street_addr = vc
      6 street_addr2 = vc
      6 city = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
    4 disch_dt_tm = dq8
    4 client_organization_id = f8
    4 client_name = vc
    4 reason_for_visit = vc
    4 financial_class_cd = f8
    4 visitor_status_cd = f8
    4 visitor_status_disp = vc
    4 valuables_cd = f8
    4 accommodation_reason_cd = f8
    4 transfer
     5 transfer_reason_cd = f8
     5 transfer_prsnl_id = f8
     5 location_cd = f8
     5 loc_facility_cd = f8
     5 loc_building_cd = f8
     5 loc_nurse_unit_cd = f8
     5 loc_nurse_unit_disp = vc
     5 loc_room_cd = f8
     5 loc_room_disp = vc
     5 loc_bed_cd = f8
     5 loc_bed_disp = vc
     5 req_med_service_cd = f8
     5 req_med_service_disp = vc
     5 req_accommodation_cd = f8
     5 req_accommodation_disp = vc
     5 req_isolation_cd = f8
     5 req_isolation_disp = vc
    4 discharge
     5 disch_prsnl_id = f8
     5 req_disch_disposition_cd = f8
     5 req_disch_to_loctn_cd = f8
     5 transaction_dt_tm = dq8
/*Encounter Aliases*/
    4 finnbr
     5 fin_formatted = vc
     5 alias_pool_cd = f8
     5 encntr_alias_type_cd = f8
     5 alias = vc
     5 encntr_alias_sub_type_cd = f8
/*Encounter Physicians*/
    4 admitdoc
     5 name_full_formatted = vc
     5 name_first = vc
     5 name_last = vc
     5 name_middle = vc
     5 encntr_prsnl_reltn_id = f8
     5 prsnl_person_id = f8
     5 encntr_prsnl_r_cd = f8
    4 attenddoc
     5 name_full_formatted = vc
     5 name_first = vc
     5 name_last = vc
     5 name_middle = vc
     5 encntr_prsnl_reltn_id = f8
     5 prsnl_person_id = f8
     5 encntr_prsnl_r_cd = f8
    4 referdoc
     5 name_full_formatted = vc
     5 name_first = vc
     5 name_last = vc
     5 name_middle = vc
     5 encntr_prsnl_reltn_id = f8
     5 prsnl_person_id = f8
     5 encntr_prsnl_r_cd = f8
/*Encounter Comments*/
    4 comment_01
     5 encntr_info_id = f8
     5 encntr_id = f8
     5 info_type_cd = f8
     5 info_sub_type_cd = f8
     5 long_text_id = f8
     5 long_text = vc
/*Encounter Data Not Collected*/
    4 encntr_data_not_coll
     5 referring_physician_cd = f8
     5 est_financial_resp_amt_cd = f8
/*Encounter Comments*/
    4 comment_01
     5 encntr_info_id = f8
/*Encounter Diagnosis*/
    4 diagnosis_01
     5 diagnosis_id = f8
     5 person_id = f8
     5 encntr_id = f8
     5 nomenclature_id = f8
     5 diag_dt_tm = dq8
     5 diag_type_cd = f8
     5 diagnostic_category_cd = f8
     5 diag_priority = f8
     5 diag_prsnl_id = f8
     5 diag_prsnl_name = vc
     5 diag_class_cd = f8
/*Subscriber 1 Info*/
   3 subscriber_01
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 person
     5 person_id = f8
     5 person_type_cd = f8
     5 name_full_formatted = vc
     5 name_first = vc
     5 name_last = vc
     5 name_middle = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 language_cd = f8
     5 marital_type_cd = f8
     5 race_cd = f8
     5 religion_cd = f8
     5 religion_disp = vc
     5 sex_cd = f8
     5 sex_disp = vc
     5 vip_cd = f8
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 ssn
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 employer_01
      6 person_org_reltn_id = f8
      6 person_id = f8
      6 person_org_reltn_cd = f8
      6 organization_id = f8
      6 organization_name = vc
      6 empl_retire_dt_tm = dq8
      6 empl_type_cd = f8
      6 empl_status_cd = f8
      6 empl_occupation_text = vc
      6 empl_occupation_cd = f8
      6 address
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_format_cd = f8
       7 phone_num = vc
     5 health_plan
      6 person_plan_reltn_id = f8
      6 encntr_plan_reltn_id = f8
      6 health_plan_id = f8
      6 person_id = f8
      6 person_plan_r_cd = f8
      6 person_org_reltn_id = f8
      6 subscriber_person_id = f8
      6 organization_id = f8
      6 member_nbr = vc
      6 signature_on_file_cd = f8
      6 balance_type_cd = f8
      6 deduct_amt = f8
      6 deduct_met_amt = f8
      6 deduct_met_dt_tm = dq8
      6 coverage_type_cd = f8
      6 max_out_pckt_amt = f8
      6 max_out_pckt_dt_tm = dq8
      6 fam_deduct_met_amt = f8
      6 fam_deduct_met_dt_tm = dq8
      6 verify_status_cd = f8
      6 verify_dt_tm = dq8
      6 verify_prsnl_id = f8
      6 insured_card_name = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
      6 data_status_cd = f8
      6 pat_member_nbr = vc
      6 plan_info
       7 health_plan_id = f8
       7 plan_type_cd = f8
       7 plan_name = vc
       7 plan_desc = vc
       7 financial_class_cd = f8
       7 financial_class_disp = vc
       7 plan_class_cd = f8
       7 beg_effective_dt_tm = dq8
       7 end_effective_dt_tm = dq8
      6 org_info
       7 organization_id = f8
       7 org_name = vc
      6 org_plan
       7 org_plan_reltn_id = f8
       7 health_plan_id = f8
       7 org_plan_reltn_cd = f8
       7 organization_id = f8
       7 group_nbr = vc
       7 group_name = vc
       7 policy_nbr = vc
      6 visit_info
       7 encntr_plan_reltn_id = f8
       7 encntr_id = f8
       7 person_id = f8
       7 person_plan_reltn_id = f8
       7 health_plan_id = f8
       7 organization_id = f8
       7 person_org_reltn_id = f8
       7 subscriber_type_cd = f8
       7 member_nbr = vc
       7 subs_member_nbr = vc
       7 insur_source_info_cd = f8
       7 balance_type_cd = f8
       7 deduct_amt = f8
       7 deduct_met_amt = f8
       7 deduct_met_dt_tm = dq8
       7 assign_benefits_cd = f8
       7 beg_effective_dt_tm = dq8
       7 end_effective_dt_tm = dq8
       7 insured_card_name = vc
       7 data_status_cd = f8
       7 auth_info_01
        8 authorization_id = f8
        8 auth_nbr = vc
        8 auth_type_cd = f8
        8 description = vc
        8 cert_status_cd = f8
        8 total_service_nbr = f8
        8 bnft_type_cd = f8
        8 beg_effective_dt_tm = dq8
        8 end_effective_dt_tm = dq8
        8 data_status_cd = f8
        8 auth_detail
         9 auth_detail_id = f8
         9 auth_company = vc
         9 auth_phone_num = vc
         9 auth_phone_frmt_cd = f8
         9 auth_phone_formatted = vc
         9 auth_contact = vc
         9 auth_dt_tm = dq8
         9 plan_contact_id = f8
         9 long_text_id = f8
      6 address
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_id = f8
       7 phone_format_cd = f8
       7 phone_num = vc
/*Subscriber 2 Info*/
   3 subscriber_02
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 person
     5 person_id = f8
     5 person_type_cd = f8
     5 name_full_formatted = vc
     5 name_first = vc
     5 name_last = vc
     5 name_middle = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 language_cd = f8
     5 marital_type_cd = f8
     5 race_cd = f8
     5 religion_cd = f8
     5 sex_cd = f8
     5 sex_disp = vc
     5 vip_cd = f8
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 ssn
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 employer_01
      6 person_org_reltn_id = f8
      6 person_id = f8
      6 person_org_reltn_cd = f8
      6 organization_id = f8
      6 organization_name = vc
      6 empl_retire_dt_tm = dq8
      6 empl_type_cd = f8
      6 empl_status_cd = f8
      6 empl_occupation_text = vc
      6 empl_occupation_cd = f8
      6 address
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_format_cd = f8
       7 phone_num = vc
     5 health_plan
      6 person_plan_reltn_id = f8
      6 encntr_plan_reltn_id = f8
      6 health_plan_id = f8
      6 person_id = f8
      6 person_plan_r_cd = f8
      6 person_org_reltn_id = f8
      6 subscriber_person_id = f8
      6 organization_id = f8
      6 member_nbr = vc
      6 signature_on_file_cd = f8
      6 balance_type_cd = f8
      6 deduct_amt = f8
      6 deduct_met_amt = f8
      6 deduct_met_dt_tm = dq8
      6 coverage_type_cd = f8
      6 max_out_pckt_amt = f8
      6 max_out_pckt_dt_tm = dq8
      6 fam_deduct_met_amt = f8
      6 fam_deduct_met_dt_tm = dq8
      6 verify_status_cd = f8
      6 verify_dt_tm = dq8
      6 verify_prsnl_id = f8
      6 insured_card_name = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
      6 data_status_cd = f8
      6 pat_member_nbr = vc
      6 plan_info
       7 health_plan_id = f8
       7 plan_type_cd = f8
       7 plan_name = vc
       7 plan_desc = vc
       7 financial_class_cd = f8
       7 financial_class_disp = vc
       7 plan_class_cd = f8
       7 beg_effective_dt_tm = dq8
       7 end_effective_dt_tm = dq8
      6 org_info
       7 organization_id = f8
       7 org_name = vc
      6 org_plan
       7 org_plan_reltn_id = f8
       7 health_plan_id = f8
       7 org_plan_reltn_cd = f8
       7 organization_id = f8
       7 group_nbr = vc
       7 group_name = vc
       7 policy_nbr = vc
      6 visit_info
       7 encntr_plan_reltn_id = f8
       7 encntr_id = f8
       7 person_id = f8
       7 person_plan_reltn_id = f8
       7 health_plan_id = f8
       7 organization_id = f8
       7 person_org_reltn_id = f8
       7 subscriber_type_cd = f8
       7 member_nbr = vc
       7 subs_member_nbr = vc
       7 insur_source_info_cd = f8
       7 balance_type_cd = f8
       7 deduct_amt = f8
       7 deduct_met_amt = f8
       7 deduct_met_dt_tm = dq8
       7 assign_benefits_cd = f8
       7 beg_effective_dt_tm = dq8
       7 end_effective_dt_tm = dq8
       7 insured_card_name = vc
       7 data_status_cd = f8
       7 auth_info_01
        8 authorization_id = f8
        8 auth_nbr = vc
        8 auth_type_cd = f8
        8 description = vc
        8 cert_status_cd = f8
        8 total_service_nbr = f8
        8 bnft_type_cd = f8
        8 beg_effective_dt_tm = dq8
        8 end_effective_dt_tm = dq8
        8 data_status_cd = f8
        8 auth_detail
         9 auth_detail_id = f8
         9 auth_company = vc
         9 auth_phone_num = vc
         9 auth_phone_frmt_cd = f8
         9 auth_phone_formatted = vc
         9 auth_contact = vc
         9 auth_dt_tm = dq8
         9 plan_contact_id = f8
         9 long_text_id = f8
      6 address
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_id = f8
       7 phone_format_cd = f8
       7 phone_num = vc
/*Subscriber 3 Info*/
   3 subscriber_03
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 person
     5 person_id = f8
     5 person_type_cd = f8
     5 name_full_formatted = vc
     5 name_first = vc
     5 name_last = vc
     5 name_middle = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 language_cd = f8
     5 marital_type_cd = f8
     5 race_cd = f8
     5 religion_cd = f8
     5 sex_cd = f8
     5 sex_disp = vc
     5 vip_cd = f8
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 ssn
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 employer_01
      6 person_org_reltn_id = f8
      6 person_id = f8
      6 person_org_reltn_cd = f8
      6 organization_id = f8
      6 organization_name = vc
      6 empl_retire_dt_tm = dq8
      6 empl_type_cd = f8
      6 empl_status_cd = f8
      6 empl_occupation_text = vc
      6 empl_occupation_cd = f8
      6 address
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_format_cd = f8
       7 phone_num = vc
     5 health_plan
      6 person_plan_reltn_id = f8
      6 encntr_plan_reltn_id = f8
      6 health_plan_id = f8
      6 person_id = f8
      6 person_plan_r_cd = f8
      6 person_org_reltn_id = f8
      6 subscriber_person_id = f8
      6 organization_id = f8
      6 member_nbr = vc
      6 signature_on_file_cd = f8
      6 balance_type_cd = f8
      6 deduct_amt = f8
      6 deduct_met_amt = f8
      6 deduct_met_dt_tm = dq8
      6 coverage_type_cd = f8
      6 max_out_pckt_amt = f8
      6 max_out_pckt_dt_tm = dq8
      6 fam_deduct_met_amt = f8
      6 fam_deduct_met_dt_tm = dq8
      6 verify_status_cd = f8
      6 verify_dt_tm = dq8
      6 verify_prsnl_id = f8
      6 insured_card_name = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
      6 data_status_cd = f8
      6 pat_member_nbr = vc
      6 plan_info
       7 health_plan_id = f8
       7 plan_type_cd = f8
       7 plan_name = vc
       7 plan_desc = vc
       7 financial_class_cd = f8
       7 financial_class_disp = vc
       7 plan_class_cd = f8
       7 beg_effective_dt_tm = dq8
       7 end_effective_dt_tm = dq8
      6 org_info
       7 organization_id = f8
       7 org_name = vc
      6 org_plan
       7 org_plan_reltn_id = f8
       7 health_plan_id = f8
       7 org_plan_reltn_cd = f8
       7 organization_id = f8
       7 group_nbr = vc
       7 group_name = vc
       7 policy_nbr = vc
      6 visit_info
       7 encntr_plan_reltn_id = f8
       7 encntr_id = f8
       7 person_id = f8
       7 person_plan_reltn_id = f8
       7 health_plan_id = f8
       7 organization_id = f8
       7 person_org_reltn_id = f8
       7 subscriber_type_cd = f8
       7 member_nbr = vc
       7 subs_member_nbr = vc
       7 insur_source_info_cd = f8
       7 balance_type_cd = f8
       7 deduct_amt = f8
       7 deduct_met_amt = f8
       7 deduct_met_dt_tm = dq8
       7 assign_benefits_cd = f8
       7 beg_effective_dt_tm = dq8
       7 end_effective_dt_tm = dq8
       7 insured_card_name = vc
       7 data_status_cd = f8
       7 auth_info_01
        8 authorization_id = f8
        8 auth_nbr = vc
        8 auth_type_cd = f8
        8 description = vc
        8 cert_status_cd = f8
        8 total_service_nbr = f8
        8 bnft_type_cd = f8
        8 beg_effective_dt_tm = dq8
        8 end_effective_dt_tm = dq8
        8 data_status_cd = f8
        8 auth_detail
         9 auth_detail_id = f8
         9 auth_company = vc
         9 auth_phone_num = vc
         9 auth_phone_frmt_cd = f8
         9 auth_phone_formatted = vc
         9 auth_contact = vc
         9 auth_dt_tm = dq8
         9 plan_contact_id = f8
         9 long_text_id = f8
      6 address
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_id = f8
       7 phone_format_cd = f8
       7 phone_num = vc
/*Guarantor 1 Info*/
   3 guarantor_01
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 guarantor_org_ind = i2
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 prior_person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 prior_related_person_reltn_cd = f8
    4 related_person_id = f8
    4 person
     5 person_id = f8
     5 name_full_formatted = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 ethnic_grp_cd = f8
     5 language_cd = f8
     5 marital_type_cd = f8
     5 marital_type_disp = vc
     5 race_cd = f8
     5 race_disp = vc
     5 religion_cd = f8
     5 religion_disp = vc
     5 sex_cd = f8
     5 sex_disp = vc
     5 name_last = vc
     5 name_first = vc
     5 vip_cd = f8
     5 name_middle = vc
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 mrn
      6 person_alias_id = f8
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 ssn
      6 ssn_formatted = vc
      6 person_alias_id = f8
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 cmrn
      6 person_alias_id = f8
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 employer_01
      6 person_org_reltn_id = f8
      6 person_org_reltn_cd = f8
      6 organization_id = f8
      6 organization_name = vc
      6 empl_retire_dt_tm = dq8
      6 empl_type_cd = f8
      6 empl_status_cd = f8
      6 empl_occupation_text = vc
      6 empl_occupation_cd = f8
      6 address
       7 address_id = f8
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_id = f8
       7 phone_format_cd = f8
       7 phone_num = vc
    4 organization
     5 organization_id = f8
     5 person_org_nbr = vc
     5 person_org_alias = vc
     5 free_text_ind = i2
     5 ft_org_name = vc
     5 data_status_cd = f8
/*Guarantor 2 Info*/
   3 guarantor_02
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 guarantor_org_ind = i2
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 prior_person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 prior_related_person_reltn_cd = f8
    4 related_person_id = f8
    4 person
     5 person_id = f8
     5 name_full_formatted = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 ethnic_grp_cd = f8
     5 language_cd = f8
     5 marital_type_cd = f8
     5 marital_type_disp = vc
     5 race_cd = f8
     5 race_disp = vc
     5 religion_cd = f8
     5 religion_disp = vc
     5 sex_cd = f8
     5 sex_disp = vc
     5 name_last = vc
     5 name_first = vc
     5 vip_cd = f8
     5 name_middle = vc
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 mrn
      6 person_alias_id = f8
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 ssn
      6 ssn_formatted = vc
      6 person_alias_id = f8
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 cmrn
      6 person_alias_id = f8
      6 alias_pool_cd = f8
      6 person_alias_type_cd = f8
      6 alias = vc
      6 person_alias_sub_type_cd = f8
     5 employer_01
      6 person_org_reltn_id = f8
      6 person_org_reltn_cd = f8
      6 organization_id = f8
      6 organization_name = vc
      6 empl_retire_dt_tm = dq8
      6 empl_type_cd = f8
      6 empl_status_cd = f8
      6 empl_occupation_text = vc
      6 empl_occupation_cd = f8
      6 address
       7 address_id = f8
       7 street_addr = vc
       7 street_addr2 = vc
       7 street_addr3 = vc
       7 street_addr4 = vc
       7 city = vc
       7 state = vc
       7 state_cd = f8
       7 state_disp = vc
       7 zipcode = vc
       7 county = vc
       7 county_cd = f8
       7 country = vc
       7 country_cd = f8
      6 phone
       7 phone_formatted = vc
       7 phone_id = f8
       7 phone_format_cd = f8
       7 phone_num = vc
    4 organization
     5 organization_id = f8
     5 person_org_nbr = vc
     5 person_org_alias = vc
     5 free_text_ind = i2
     5 ft_org_name = vc
     5 data_status_cd = f8
/*NOK Info*/
   3 nok
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 related_person_id = f8
    4 person
     5 person_id = f8
     5 name_full_formatted = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 sex_cd = f8
     5 sex_disp = vc
     5 name_last = vc
     5 name_first = vc
     5 name_middle = vc
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
/*EMC Info*/
   3 emc
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 related_person_id = f8
    4 person
     5 person_id = f8
     5 name_full_formatted = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 sex_cd = f8
     5 sex_disp = vc
     5 name_last = vc
     5 name_first = vc
     5 name_middle = vc
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
/*RELATION 01 Info*/
   3 relation_01
    4 person_person_reltn_id = f8
    4 encntr_person_reltn_id = f8
    4 person_reltn_type_cd = f8
    4 person_id = f8
    4 encntr_id = f8
    4 person_reltn_cd = f8
    4 related_person_reltn_cd = f8
    4 related_person_reltn_disp = vc
    4 related_person_id = f8
    4 person
     5 person_id = f8
     5 name_full_formatted = vc
     5 birth_dt_tm = dq8
     5 birth_tz = i4
     5 birth_prec_flag = i2
     5 birth_dt_formatted = vc
     5 sex_cd = f8
     5 sex_disp = vc
     5 name_last = vc
     5 name_first = vc
     5 name_middle = vc
     5 home_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 bus_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 alt_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 home_email
      6 phone_id = f8
      6 email = vc
      6 beg_effective_dt_tm = dq8
      6 end_effective_dt_tm = dq8
     5 email_address
      6 address_id = f8
      6 street_addr = vc
     5 temp_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mail_address
      6 address_id = f8
      6 street_addr = vc
      6 street_addr2 = vc
      6 street_addr3 = vc
      6 street_addr4 = vc
      6 city = vc
      6 state = vc
      6 state_cd = f8
      6 state_disp = vc
      6 zipcode = vc
      6 county = vc
      6 county_cd = f8
      6 country = vc
      6 country_cd = f8
     5 mobile_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 home_pager
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 bus_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 alt_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
     5 temp_phone
      6 phone_id = f8
      6 phone_formatted = vc
      6 phone_format_cd = f8
      6 phone_num = vc
      6 extension = vc
) with persist
 
;**************************************************************
; Load request data into our record
;**************************************************************
call DebugPrint("mapping request")
 
call DebugPrint("..... mapping patient")
/** Patient info **/
set pmdbdoc->patient_data->person.person_id = request->patient_data.person.person_id
call GetNamesForRecord("pmdbdoc->patient_data->person", pmdbdoc->patient_data.person.person_id)
call GetAltCharName("pmdbdoc->patient_data->person->alt_char_name", pmdbdoc->patient_data.person.person_id)
set pmdbdoc->patient_data->person.birth_dt_tm = request->patient_data.person.birth_dt_tm
set pmdbdoc->patient_data->person.birth_tz = request->patient_data.person.birth_tz
set pmdbdoc->patient_data->person.birth_prec_flag = request->patient_data.person.birth_prec_flag
set pmdbdoc->patient_data->person.language_cd = request->patient_data.person.language_cd
set pmdbdoc->patient_data->person.marital_type_cd = request->patient_data.person.marital_type_cd
set pmdbdoc->patient_data->person.race_cd = request->patient_data.person.race_cd
set pmdbdoc->patient_data->person.ethnic_grp_cd = request->patient_data.person.ethnic_grp_cd
set pmdbdoc->patient_data->person.religion_cd = request->patient_data.person.religion_cd
set pmdbdoc->patient_data->person.sex_cd = request->patient_data.person.sex_cd
set pmdbdoc->patient_data->person.vip_cd = request->patient_data.person.vip_cd
set pmdbdoc->patient_data->person.patient.church_cd = request->patient_data.person.patient.church_cd
set pmdbdoc->patient_data->person.patient.interp_required_cd = request->patient_data.person.patient.interp_required_cd
set pmdbdoc->patient_data->person.patient.living_will_cd = request->patient_data.person.patient.living_will_cd
set pmdbdoc->patient_data->person.patient.disease_alert_cd = request->patient_data.person.patient.disease_alert_cd
set pmdbdoc->patient_data->person.patient.process_alert_cd = request->patient_data.person.patient.process_alert_cd
set pmdbdoc->patient_data.person.nationality_cd = request->patient_data.person.nationality_cd
set pmdbdoc->patient_data->person.patient.birth_sex_cd = request->patient_data.person.patient.birth_sex_cd
 
/** Person Addresses **/
;Home Address
set pmdbdoc->patient_data->person.home_address.address_id = request->patient_data.person.home_address.address_id
set pmdbdoc->patient_data->person.home_address.street_addr = request->patient_data.person.home_address.street_addr
set pmdbdoc->patient_data->person.home_address.street_addr2 = request->patient_data.person.home_address.street_addr2
set pmdbdoc->patient_data->person.home_address.street_addr3 = request->patient_data.person.home_address.street_addr3
set pmdbdoc->patient_data->person.home_address.street_addr4 = request->patient_data.person.home_address.street_addr4
set pmdbdoc->patient_data->person.home_address.city = request->patient_data.person.home_address.city
set pmdbdoc->patient_data->person.home_address.state = request->patient_data.person.home_address.state
set pmdbdoc->patient_data->person.home_address.state_cd = request->patient_data.person.home_address.state_cd
set pmdbdoc->patient_data->person.home_address.zipcode = request->patient_data.person.home_address.zipcode
set pmdbdoc->patient_data->person.home_address.county = request->patient_data.person.home_address.county
set pmdbdoc->patient_data->person.home_address.county_cd = request->patient_data.person.home_address.county_cd
set pmdbdoc->patient_data->person.home_address.country = request->patient_data.person.home_address.country
set pmdbdoc->patient_data->person.home_address.country_cd = request->patient_data.person.home_address.country_cd
 
;Previous Address
set pmdbdoc->patient_data->person.prev_address.address_id = request->patient_data.person.prev_address.address_id
set pmdbdoc->patient_data->person.prev_address.street_addr = request->patient_data.person.prev_address.street_addr
set pmdbdoc->patient_data->person.prev_address.street_addr2 = request->patient_data.person.prev_address.street_addr2
set pmdbdoc->patient_data->person.prev_address.street_addr3 = request->patient_data.person.prev_address.street_addr3
set pmdbdoc->patient_data->person.prev_address.street_addr4 = request->patient_data.person.prev_address.street_addr4
set pmdbdoc->patient_data->person.prev_address.city = request->patient_data.person.prev_address.city
set pmdbdoc->patient_data->person.prev_address.state = request->patient_data.person.prev_address.state
set pmdbdoc->patient_data->person.prev_address.state_cd = request->patient_data.person.prev_address.state_cd
set pmdbdoc->patient_data->person.prev_address.zipcode = request->patient_data.person.prev_address.zipcode
set pmdbdoc->patient_data->person.prev_address.county = request->patient_data.person.prev_address.county
set pmdbdoc->patient_data->person.prev_address.county_cd = request->patient_data.person.prev_address.county_cd
set pmdbdoc->patient_data->person.prev_address.country = request->patient_data.person.prev_address.country
set pmdbdoc->patient_data->person.prev_address.country_cd = request->patient_data.person.prev_address.country_cd

;Alt Address
set pmdbdoc->patient_data.person.alt_address.address_id = request->patient_data.person.alt_address.address_id
set pmdbdoc->patient_data.person.alt_address.street_addr = request->patient_data.person.alt_address.street_addr
set pmdbdoc->patient_data.person.alt_address.street_addr2 = request->patient_data.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.alt_address.street_addr3 = request->patient_data.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.alt_address.street_addr4 = request->patient_data.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.alt_address.city = request->patient_data.person.alt_address.city
set pmdbdoc->patient_data.person.alt_address.state = request->patient_data.person.alt_address.state
set pmdbdoc->patient_data.person.alt_address.state_cd = request->patient_data.person.alt_address.state_cd
set pmdbdoc->patient_data.person.alt_address.zipcode = request->patient_data.person.alt_address.zipcode
set pmdbdoc->patient_data.person.alt_address.county = request->patient_data.person.alt_address.county
set pmdbdoc->patient_data.person.alt_address.county_cd = request->patient_data.person.alt_address.county_cd
set pmdbdoc->patient_data.person.alt_address.country = request->patient_data.person.alt_address.country
set pmdbdoc->patient_data.person.alt_address.country_cd = request->patient_data.person.alt_address.country_cd
 
;Temp Address
set pmdbdoc->patient_data.person.temp_address.address_id = request->patient_data.person.temp_address.address_id
set pmdbdoc->patient_data.person.temp_address.street_addr = request->patient_data.person.temp_address.street_addr
set pmdbdoc->patient_data.person.temp_address.street_addr2 = request->patient_data.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.temp_address.street_addr3 = request->patient_data.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.temp_address.street_addr4 = request->patient_data.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.temp_address.city = request->patient_data.person.temp_address.city
set pmdbdoc->patient_data.person.temp_address.state = request->patient_data.person.temp_address.state
set pmdbdoc->patient_data.person.temp_address.state_cd = request->patient_data.person.temp_address.state_cd
set pmdbdoc->patient_data.person.temp_address.zipcode = request->patient_data.person.temp_address.zipcode
set pmdbdoc->patient_data.person.temp_address.county = request->patient_data.person.temp_address.county
set pmdbdoc->patient_data.person.temp_address.county_cd = request->patient_data.person.temp_address.county_cd
set pmdbdoc->patient_data.person.temp_address.country = request->patient_data.person.temp_address.country
set pmdbdoc->patient_data.person.temp_address.country_cd = request->patient_data.person.temp_address.country_cd
 
;Bill Address
set pmdbdoc->patient_data.person.bill_address.address_id = request->patient_data.person.bill_address.address_id
set pmdbdoc->patient_data.person.bill_address.street_addr = request->patient_data.person.bill_address.street_addr
set pmdbdoc->patient_data.person.bill_address.street_addr2 = request->patient_data.person.bill_address.street_addr2
set pmdbdoc->patient_data.person.bill_address.street_addr3 = request->patient_data.person.bill_address.street_addr3
set pmdbdoc->patient_data.person.bill_address.street_addr4 = request->patient_data.person.bill_address.street_addr4
set pmdbdoc->patient_data.person.bill_address.city = request->patient_data.person.bill_address.city
set pmdbdoc->patient_data.person.bill_address.state = request->patient_data.person.bill_address.state
set pmdbdoc->patient_data.person.bill_address.state_cd = request->patient_data.person.bill_address.state_cd
set pmdbdoc->patient_data.person.bill_address.zipcode = request->patient_data.person.bill_address.zipcode
set pmdbdoc->patient_data.person.bill_address.county = request->patient_data.person.bill_address.county
set pmdbdoc->patient_data.person.bill_address.county_cd = request->patient_data.person.bill_address.county_cd
set pmdbdoc->patient_data.person.bill_address.country = request->patient_data.person.bill_address.country
set pmdbdoc->patient_data.person.bill_address.country_cd = request->patient_data.person.bill_address.country_cd

;Birth Address
set pmdbdoc->patient_data.person.birth_address.address_id = request->patient_data.person.birth_address.address_id
set pmdbdoc->patient_data.person.birth_address.street_addr = request->patient_data.person.birth_address.street_addr
set pmdbdoc->patient_data.person.birth_address.street_addr2 = request->patient_data.person.birth_address.street_addr2
set pmdbdoc->patient_data.person.birth_address.street_addr3 = request->patient_data.person.birth_address.street_addr3
set pmdbdoc->patient_data.person.birth_address.street_addr4 = request->patient_data.person.birth_address.street_addr4
set pmdbdoc->patient_data.person.birth_address.city = request->patient_data.person.birth_address.city
set pmdbdoc->patient_data.person.birth_address.state = request->patient_data.person.birth_address.state
set pmdbdoc->patient_data.person.birth_address.state_cd = request->patient_data.person.birth_address.state_cd
set pmdbdoc->patient_data.person.birth_address.zipcode = request->patient_data.person.birth_address.zipcode
set pmdbdoc->patient_data.person.birth_address.county = request->patient_data.person.birth_address.county
set pmdbdoc->patient_data.person.birth_address.county_cd = request->patient_data.person.birth_address.county_cd
set pmdbdoc->patient_data.person.birth_address.country = request->patient_data.person.birth_address.country
set pmdbdoc->patient_data.person.birth_address.country_cd = request->patient_data.person.birth_address.country_cd

;Business Address
set pmdbdoc->patient_data.person.bus_address.address_id = request->patient_data.person.bus_address.address_id
set pmdbdoc->patient_data.person.bus_address.street_addr = request->patient_data.person.bus_address.street_addr
set pmdbdoc->patient_data.person.bus_address.street_addr2 = request->patient_data.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.bus_address.street_addr3 = request->patient_data.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.bus_address.street_addr4 = request->patient_data.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.bus_address.city = request->patient_data.person.bus_address.city
set pmdbdoc->patient_data.person.bus_address.state = request->patient_data.person.bus_address.state
set pmdbdoc->patient_data.person.bus_address.state_cd = request->patient_data.person.bus_address.state_cd
set pmdbdoc->patient_data.person.bus_address.zipcode = request->patient_data.person.bus_address.zipcode
set pmdbdoc->patient_data.person.bus_address.county = request->patient_data.person.bus_address.county
set pmdbdoc->patient_data.person.bus_address.county_cd = request->patient_data.person.bus_address.county_cd
set pmdbdoc->patient_data.person.bus_address.country = request->patient_data.person.bus_address.country
set pmdbdoc->patient_data.person.bus_address.country_cd = request->patient_data.person.bus_address.country_cd
 
;Mail Address
set pmdbdoc->patient_data.person.mail_address.address_id = request->patient_data.person.mail_address.address_id
set pmdbdoc->patient_data.person.mail_address.street_addr = request->patient_data.person.mail_address.street_addr
set pmdbdoc->patient_data.person.mail_address.street_addr2 = request->patient_data.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.mail_address.street_addr3 = request->patient_data.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.mail_address.street_addr4 = request->patient_data.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.mail_address.city = request->patient_data.person.mail_address.city
set pmdbdoc->patient_data.person.mail_address.state = request->patient_data.person.mail_address.state
set pmdbdoc->patient_data.person.mail_address.state_cd = request->patient_data.person.mail_address.state_cd
set pmdbdoc->patient_data.person.mail_address.zipcode = request->patient_data.person.mail_address.zipcode
set pmdbdoc->patient_data.person.mail_address.county = request->patient_data.person.mail_address.county
set pmdbdoc->patient_data.person.mail_address.county_cd = request->patient_data.person.mail_address.county_cd
set pmdbdoc->patient_data.person.mail_address.country = request->patient_data.person.mail_address.country
set pmdbdoc->patient_data.person.mail_address.country_cd = request->patient_data.person.mail_address.country_cd

;Email Address
set pmdbdoc->patient_data.person.email_address.address_id = request->patient_data.person.email_address.address_id
set pmdbdoc->patient_data.person.email_address.street_addr = request->patient_data.person.email_address.street_addr

;Email Address Phone Table (Code Set 20790 (EMAILSYNC) PHONE)
set pmdbdoc->patient_data->person->home_email.phone_id = request->patient_data->person->home_email.phone_id
set pmdbdoc->patient_data->person->home_email.email = trim(request->patient_data->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->home_email.beg_effective_dt_tm = request->patient_data->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->home_email.end_effective_dt_tm = request->patient_data->person->home_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->pri_home_email.phone_id = request->patient_data->person->pri_home_email.phone_id
set pmdbdoc->patient_data->person->pri_home_email.email = trim(request->patient_data->person->pri_home_email.phone_num, 3)
set pmdbdoc->patient_data->person->pri_home_email.beg_effective_dt_tm = 
 request->patient_data->person->pri_home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->pri_home_email.end_effective_dt_tm = 
 request->patient_data->person->pri_home_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->vac_home_email.phone_id = request->patient_data->person->vac_home_email.phone_id
set pmdbdoc->patient_data->person->vac_home_email.email = trim(request->patient_data->person->vac_home_email.phone_num, 3)
set pmdbdoc->patient_data->person->vac_home_email.beg_effective_dt_tm = 
 request->patient_data->person->vac_home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->vac_home_email.end_effective_dt_tm = 
 request->patient_data->person->vac_home_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->bus_email.phone_id = request->patient_data->person->bus_email.phone_id
set pmdbdoc->patient_data->person->bus_email.email = trim(request->patient_data->person->bus_email.phone_num, 3)
set pmdbdoc->patient_data->person->bus_email.beg_effective_dt_tm = request->patient_data->person->bus_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->bus_email.end_effective_dt_tm = request->patient_data->person->bus_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->aam_email.phone_id = request->patient_data->person->aam_email.phone_id
set pmdbdoc->patient_data->person->aam_email.email = trim(request->patient_data->person->aam_email.phone_num, 3)
set pmdbdoc->patient_data->person->aam_email.beg_effective_dt_tm = request->patient_data->person->aam_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->aam_email.end_effective_dt_tm = request->patient_data->person->aam_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->emc_email.phone_id = request->patient_data->person->emc_email.phone_id
set pmdbdoc->patient_data->person->emc_email.email = trim(request->patient_data->person->emc_email.phone_num, 3)
set pmdbdoc->patient_data->person->emc_email.beg_effective_dt_tm = request->patient_data->person->emc_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->emc_email.end_effective_dt_tm = request->patient_data->person->emc_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->paging_email.phone_id = request->patient_data->person->paging_email.phone_id
set pmdbdoc->patient_data->person->paging_email.email = trim(request->patient_data->person->paging_email.phone_num, 3)
set pmdbdoc->patient_data->person->paging_email.beg_effective_dt_tm = 
 request->patient_data->person->paging_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->paging_email.end_effective_dt_tm = 
 request->patient_data->person->paging_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->mobile_email.phone_id = request->patient_data->person->mobile_email.phone_id
set pmdbdoc->patient_data->person->mobile_email.email = trim(request->patient_data->person->mobile_email.phone_num, 3)
set pmdbdoc->patient_data->person->mobile_email.beg_effective_dt_tm = 
 request->patient_data->person->mobile_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->mobile_email.end_effective_dt_tm = 
 request->patient_data->person->mobile_email.end_effective_dt_tm

set pmdbdoc->patient_data->person->secure_email.phone_id = request->patient_data->person->secure_email.phone_id
set pmdbdoc->patient_data->person->secure_email.email = trim(request->patient_data->person->secure_email.phone_num, 3)
set pmdbdoc->patient_data->person->secure_email.beg_effective_dt_tm = 
 request->patient_data->person->secure_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->secure_email.end_effective_dt_tm = 
 request->patient_data->person->secure_email.end_effective_dt_tm

/* Person Phone Numbers */
;Home Phone
set pmdbdoc->patient_data->person.home_phone.phone_id = request->patient_data.person.home_phone.phone_id
set pmdbdoc->patient_data->person.home_phone.phone_format_cd = request->patient_data.person.home_phone.phone_format_cd
set pmdbdoc->patient_data->person.home_phone.phone_num = request->patient_data.person.home_phone.phone_num
set pmdbdoc->patient_data->person.home_phone.extension = request->patient_data.person.home_phone.extension
 
;Home Pager
set pmdbdoc->patient_data.person.home_pager.phone_id = request->patient_data.person.home_pager.phone_id
set pmdbdoc->patient_data.person.home_pager.phone_format_cd = request->patient_data.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.home_pager.phone_num = request->patient_data.person.home_pager.phone_num
set pmdbdoc->patient_data.person.home_pager.extension = request->patient_data.person.home_pager.extension
 
;Alt Phone
set pmdbdoc->patient_data.person.alt_phone.phone_id = request->patient_data.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.alt_phone.phone_format_cd = request->patient_data.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.alt_phone.phone_num = request->patient_data.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.alt_phone.extension = request->patient_data.person.alt_phone.extension
 
;Temp Phone
set pmdbdoc->patient_data->person.temp_phone.phone_id = request->patient_data.person.temp_phone.phone_id
set pmdbdoc->patient_data->person.temp_phone.phone_format_cd = request->patient_data.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data->person.temp_phone.phone_num = request->patient_data.person.temp_phone.phone_num
set pmdbdoc->patient_data->person.temp_phone.extension = request->patient_data.person.temp_phone.extension
 
;Work Phone
set pmdbdoc->patient_data->person.bus_phone.phone_id = request->patient_data.person.bus_phone.phone_id
set pmdbdoc->patient_data->person.bus_phone.phone_format_cd = request->patient_data.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data->person.bus_phone.phone_num = request->patient_data.person.bus_phone.phone_num
set pmdbdoc->patient_data->person.bus_phone.extension = request->patient_data.person.bus_phone.extension

;Mobile Phone
set pmdbdoc->patient_data->person.mobile_phone.phone_id = request->patient_data.person.mobile_phone.phone_id
set pmdbdoc->patient_data->person.mobile_phone.phone_format_cd = request->patient_data.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data->person.mobile_phone.phone_num = request->patient_data.person.mobile_phone.phone_num
set pmdbdoc->patient_data->person.mobile_phone.extension = request->patient_data.person.mobile_phone.extension
 
/* Aliases & Identifiers */
;MRN
set pmdbdoc->patient_data->person.mrn.alias = request->patient_data.person.mrn.alias
set pmdbdoc->patient_data->person.mrn.alias_pool_cd = request->patient_data.person.mrn.alias_pool_cd
;SSN
set pmdbdoc->patient_data.person.ssn.alias = request->patient_data.person.ssn.alias
set pmdbdoc->patient_data.person.ssn.alias_pool_cd = request->patient_data.person.ssn.alias_pool_cd
;CMRN
set pmdbdoc->patient_data.person.cmrn.alias = request->patient_data.person.cmrn.alias
set pmdbdoc->patient_data.person.cmrn.alias_pool_cd = request->patient_data.person.cmrn.alias_pool_cd
;
 
/* Person Level Providers */
set pmdbdoc->patient_data->person.pcp.person_id = request->patient_data.person.pcp.prsnl_person_id
call GetPrsnlName("pmdbdoc->patient_data->person.pcp", request->patient_data.person.pcp.prsnl_person_id)
 
/* Person Comments */
set pmdbdoc->patient_data.person.comment_01.long_text =
trim(replace(request->patient_data.person.comment_01.long_text,"--------------------------------------", " "),3)
 
/* Employer */
set pmdbdoc->patient_data.person.employer_01.person_org_reltn_id =
request->patient_data.person.employer_01.person_org_reltn_id
set pmdbdoc->patient_data.person.employer_01.organization_id = request->patient_data.person.employer_01.organization_id
set pmdbdoc->patient_data.person.employer_01.empl_retire_dt_tm =
request->patient_data.person.employer_01.empl_retire_dt_tm
set pmdbdoc->patient_data.person.employer_01.empl_type_cd = request->patient_data.person.employer_01.empl_type_cd
set pmdbdoc->patient_data.person.employer_01.empl_status_cd = request->patient_data.person.employer_01.empl_status_cd
set pmdbdoc->patient_data.person.employer_01.empl_occupation_text =
request->patient_data.person.employer_01.empl_occupation_text
set pmdbdoc->patient_data.person.employer_01.empl_occupation_cd =
request->patient_data.person.employer_01.empl_occupation_cd
 
;Employer Address
set pmdbdoc->patient_data.person.employer_01.address.address_id =
request->patient_data.person.employer_01.address.address_id
set pmdbdoc->patient_data.person.employer_01.address.street_addr =
request->patient_data.person.employer_01.address.street_addr
set pmdbdoc->patient_data.person.employer_01.address.street_addr2 =
request->patient_data.person.employer_01.address.street_addr2
set pmdbdoc->patient_data.person.employer_01.address.street_addr3 =
request->patient_data.person.employer_01.address.street_addr3
set pmdbdoc->patient_data.person.employer_01.address.street_addr4 =
request->patient_data.person.employer_01.address.street_addr4
set pmdbdoc->patient_data.person.employer_01.address.city = request->patient_data.person.employer_01.address.city
set pmdbdoc->patient_data.person.employer_01.address.state = request->patient_data.person.employer_01.address.state
set pmdbdoc->patient_data.person.employer_01.address.state_cd =
request->patient_data.person.employer_01.address.state_cd
set pmdbdoc->patient_data.person.employer_01.address.zipcode = request->patient_data.person.employer_01.address.zipcode
set pmdbdoc->patient_data.person.employer_01.address.county = request->patient_data.person.employer_01.address.county
set pmdbdoc->patient_data.person.employer_01.address.county_cd =
request->patient_data.person.employer_01.address.county_cd
set pmdbdoc->patient_data.person.employer_01.address.country = request->patient_data.person.employer_01.address.country
set pmdbdoc->patient_data.person.employer_01.address.country_cd =
request->patient_data.person.employer_01.address.country_cd
 
;Employer Phone
set pmdbdoc->patient_data.person.employer_01.phone.phone_format_cd
    = request->patient_data.person.employer_01.phone.phone_format_cd
set pmdbdoc->patient_data.person.employer_01.phone.phone_num = request->patient_data.person.employer_01.phone.phone_num
set pmdbdoc->patient_data.person.employer_01.phone.extension = request->patient_data.person.employer_01.phone.extension
 
call DebugPrint("..... mapping encounter")
/* Encounter */
set pmdbdoc->patient_data->person.encounter.encntr_id = request->patient_data.person.encounter.encntr_id
set pmdbdoc->patient_data.person.encounter.encntr_class_cd = request->patient_data.person.encounter.encntr_class_cd
set pmdbdoc->patient_data.person.encounter.encntr_type_cd = request->patient_data.person.encounter.encntr_type_cd
set pmdbdoc->patient_data.person.encounter.encntr_type_class_cd =
request->patient_data.person.encounter.encntr_type_class_cd
set pmdbdoc->patient_data.person.encounter.encntr_status_cd = request->patient_data.person.encounter.encntr_status_cd
set pmdbdoc->patient_data.person.encounter.pre_reg_dt_tm = request->patient_data.person.encounter.pre_reg_dt_tm
set pmdbdoc->patient_data.person.encounter.pre_reg_prsnl_id = request->patient_data.person.encounter.pre_reg_prsnl_id
set pmdbdoc->patient_data.person.encounter.reg_dt_tm = request->patient_data.person.encounter.reg_dt_tm
set pmdbdoc->patient_data.person.encounter.reg_prsnl_id = request->patient_data.person.encounter.reg_prsnl_id
set pmdbdoc->patient_data.person.encounter.est_arrive_dt_tm = request->patient_data.person.encounter.est_arrive_dt_tm
set pmdbdoc->patient_data.person.encounter.est_depart_dt_tm = request->patient_data.person.encounter.est_depart_dt_tm
set pmdbdoc->patient_data.person.encounter.inpatient_admit_dt_tm =
request->patient_data.person.encounter.inpatient_admit_dt_tm
set pmdbdoc->patient_data.person.encounter.arrive_dt_tm = request->patient_data.person.encounter.arrive_dt_tm
set pmdbdoc->patient_data.person.encounter.depart_dt_tm = request->patient_data.person.encounter.depart_dt_tm
set pmdbdoc->patient_data.person.encounter.admit_type_cd = request->patient_data.person.encounter.admit_type_cd
set pmdbdoc->patient_data.person.encounter.admit_src_cd = request->patient_data.person.encounter.admit_src_cd
set pmdbdoc->patient_data.person.encounter.admit_mode_cd = request->patient_data.person.encounter.admit_mode_cd
set pmdbdoc->patient_data.person.encounter.disch_disposition_cd =
request->patient_data.person.encounter.disch_disposition_cd
set pmdbdoc->patient_data.person.encounter.disch_to_loctn_cd = request->patient_data.person.encounter.disch_to_loctn_cd
set pmdbdoc->patient_data.person.encounter.accommodation_cd = request->patient_data.person.encounter.accommodation_cd
set pmdbdoc->patient_data.person.encounter.accommodation_request_cd
    = request->patient_data.person.encounter.accommodation_request_cd
set pmdbdoc->patient_data.person.encounter.ambulatory_cond_cd =
request->patient_data.person.encounter.ambulatory_cond_cd
set pmdbdoc->patient_data.person.encounter.courtesy_cd = request->patient_data.person.encounter.courtesy_cd
set pmdbdoc->patient_data.person.encounter.isolation_cd = request->patient_data.person.encounter.isolation_cd
set pmdbdoc->patient_data->person.encounter.med_service_cd
    = request->patient_data.person.encounter.med_service_cd
set pmdbdoc->patient_data.person.encounter.vip_cd = request->patient_data.person.encounter.vip_cd
set pmdbdoc->patient_data.person.encounter.location_cd = request->patient_data.person.encounter.location_cd
set pmdbdoc->patient_data.person.encounter.loc_facility_cd = request->patient_data.person.encounter.loc_facility_cd
set pmdbdoc->patient_data.person.encounter.loc_building_cd = request->patient_data.person.encounter.loc_building_cd
set pmdbdoc->patient_data.person.encounter.loc_nurse_unit_cd = request->patient_data.person.encounter.loc_nurse_unit_cd
set pmdbdoc->patient_data.person.encounter.loc_room_cd = request->patient_data.person.encounter.loc_room_cd
set pmdbdoc->patient_data.person.encounter.loc_bed_cd = request->patient_data.person.encounter.loc_bed_cd
set pmdbdoc->patient_data.person.encounter.disch_dt_tm = request->patient_data.person.encounter.disch_dt_tm
set pmdbdoc->patient_data.person.encounter.client_organization_id = request->patient_data.person.encounter.organization_id
set pmdbdoc->patient_data.person.encounter.reason_for_visit = request->patient_data.person.encounter.reason_for_visit
set pmdbdoc->patient_data.person.encounter.financial_class_cd =
request->patient_data.person.encounter.financial_class_cd
set pmdbdoc->patient_data.person.encounter.visitor_status_cd = request->patient_data.person.encounter.visitor_status_cd
set pmdbdoc->patient_data.person.encounter.valuables_cd = request->patient_data.person.encounter.valuables_cd
set pmdbdoc->patient_data.person.encounter.accommodation_reason_cd
    = request->patient_data.person.encounter.accommodation_reason_cd
 
call DebugPrint("..... mapping transfer data")
;Transfer Data
set pmdbdoc->patient_data.person.encounter.transfer.transfer_reason_cd
    = request->patient_data.person.encounter.transfer.transfer_reason_cd
set pmdbdoc->patient_data.person.encounter.transfer.transfer_prsnl_id
    = request->patient_data.person.encounter.transfer.transfer_prsnl_id
set pmdbdoc->patient_data.person.encounter.transfer.location_cd
    = request->patient_data.person.encounter.transfer.location_cd
set pmdbdoc->patient_data.person.encounter.transfer.loc_facility_cd
    = request->patient_data.person.encounter.transfer.loc_facility_cd
set pmdbdoc->patient_data.person.encounter.transfer.loc_building_cd
    = request->patient_data.person.encounter.transfer.loc_building_cd
set pmdbdoc->patient_data.person.encounter.transfer.loc_nurse_unit_cd
    = request->patient_data.person.encounter.transfer.loc_nurse_unit_cd
set pmdbdoc->patient_data.person.encounter.transfer.loc_nurse_unit_disp
    = uar_get_code_display(request->patient_data.person.encounter.transfer.loc_nurse_unit_cd)
set pmdbdoc->patient_data.person.encounter.transfer.loc_room_cd
    = request->patient_data.person.encounter.transfer.loc_room_cd
set pmdbdoc->patient_data.person.encounter.transfer.loc_room_disp
    = uar_get_code_display(request->patient_data.person.encounter.transfer.loc_room_cd)
set pmdbdoc->patient_data.person.encounter.transfer.loc_bed_cd
    = request->patient_data.person.encounter.transfer.loc_bed_cd
set pmdbdoc->patient_data.person.encounter.transfer.loc_bed_disp
    = uar_get_code_display(request->patient_data.person.encounter.transfer.loc_bed_cd)
set pmdbdoc->patient_data.person.encounter.transfer.req_med_service_cd
    = request->patient_data.person.encounter.transfer.req_med_service_cd
set pmdbdoc->patient_data.person.encounter.transfer.req_med_service_disp
    = uar_get_code_display(request->patient_data.person.encounter.transfer.req_med_service_cd)
set pmdbdoc->patient_data.person.encounter.transfer.req_accommodation_cd
    = request->patient_data.person.encounter.transfer.req_accommodation_cd
set pmdbdoc->patient_data.person.encounter.transfer.req_accommodation_disp
    = uar_get_code_display(request->patient_data.person.encounter.transfer.req_accommodation_cd)
set pmdbdoc->patient_data.person.encounter.transfer.req_isolation_cd
    = request->patient_data.person.encounter.transfer.req_isolation_cd
set pmdbdoc->patient_data.person.encounter.transfer.req_isolation_disp
    = uar_get_code_display(request->patient_data.person.encounter.transfer.req_isolation_cd)
set PMDBDOC->PATIENT_DATA.TRANSACTION_INFO.TRANS_DT_TM
    = request->patient_data.transaction_info.trans_dt_tm
 
;Discharge Data
set pmdbdoc->patient_data.person.encounter.discharge.disch_prsnl_id
    = request->patient_data.person.encounter.discharge.disch_prsnl_id
set pmdbdoc->patient_data.person.encounter.discharge.req_disch_disposition_cd
    = request->patient_data.person.encounter.discharge.req_disch_disposition_cd
set pmdbdoc->patient_data.person.encounter.discharge.req_disch_to_loctn_cd
    = request->patient_data.person.encounter.discharge.req_disch_to_loctn_cd
set pmdbdoc->patient_data.person.encounter.discharge.transaction_dt_tm
    = request->patient_data.person.encounter.discharge.transaction_dt_tm
 
/* Encounter Aliases */
set pmdbdoc->patient_data->person.encounter.finnbr.alias = request->patient_data.person.encounter.finnbr.alias
set pmdbdoc->patient_data->person.encounter.finnbr.alias_pool_cd
    = request->patient_data.person.encounter.finnbr.alias_pool_cd
 
call DebugPrint("..... mapping Encounter Level Providers")
/* Encounter Level Providers */
;Admitting
set pmdbdoc->patient_data->person.encounter.admitdoc.prsnl_person_id
     = request->patient_data.person.encounter.admitdoc.prsnl_person_id
call GetPrsnlName("pmdbdoc->patient_data->person.encounter.admitdoc",
     pmdbdoc->person.encounter.admitdoc.prsnl_person_id)
;Attending
set pmdbdoc->patient_data.person.encounter.attenddoc.prsnl_person_id
     = request->patient_data.person.encounter.attenddoc.prsnl_person_id
call GetPrsnlName("pmdbdoc->patient_data->person.encounter.attenddoc",
     pmdbdoc->person.encounter.attenddoc.prsnl_person_id)
;Referring
set  pmdbdoc->patient_data.person.encounter.referdoc.prsnl_person_id
     = request->patient_data.person.encounter.referdoc.prsnl_person_id
call GetPrsnlName("pmdbdoc->patient_data->person.encounter.referdoc",
     pmdbdoc->person.encounter.referdoc.prsnl_person_id)
 
call DebugPrint("..... mapping Comment 01")
/* Comments */
set pmdbdoc->patient_data.person.encounter.comment_01.long_text_id
    = request->patient_data.person.encounter.comment_01.long_text_id
set pmdbdoc->patient_data.person.encounter.comment_01.long_text =
trim(replace(request->patient_data.person.encounter.comment_01.long_text,
"--------------------------------------", " "),3)
 
call DebugPrint("..... mapping Diagnosis 01")
/* Diagnosis */
set pmdbdoc->patient_data.person.encounter.diagnosis_01.diagnosis_id
    = request->patient_data.person.encounter.diagnosis_01.diagnosis_id
set pmdbdoc->patient_data.person.encounter.diagnosis_01.nomenclature_id
    = request->patient_data.person.encounter.diagnosis_01.nomenclature_id
 
call DebugPrint("..... mapping Subscriber 01")
/* Subscriber 01 */
set pmdbdoc->patient_data.person.subscriber_01.encntr_person_reltn_id
    = request->patient_data.person.subscriber_01.encntr_person_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person_reltn_type_cd
    = request->patient_data.person.subscriber_01.person_reltn_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person_reltn_cd
    = request->patient_data.person.subscriber_01.person_reltn_cd
set pmdbdoc->patient_data.person.subscriber_01.related_person_reltn_cd
    = request->patient_data.person.subscriber_01.related_person_reltn_cd
;subs1 person
set pmdbdoc->patient_data.person.subscriber_01.person.person_id
    = request->patient_data.person.subscriber_01.person.person_id
set pmdbdoc->patient_data.person.subscriber_01.person.person_type_cd
    = request->patient_data.person.subscriber_01.person.person_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.name_full_formatted
    = request->patient_data.person.subscriber_01.person.name_full_formatted
set pmdbdoc->patient_data.person.subscriber_01.person.birth_dt_tm =
request->patient_data.person.subscriber_01.person.birth_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.birth_tz =
    request->patient_data.person.subscriber_01.person.birth_tz
set pmdbdoc->patient_data.person.subscriber_01.person.birth_prec_flag =
    request->patient_data.person.subscriber_01.person.birth_prec_flag
set pmdbdoc->patient_data.person.subscriber_01.person.language_cd =
request->patient_data.person.subscriber_01.person.language_cd
set pmdbdoc->patient_data.person.subscriber_01.person.marital_type_cd
    = request->patient_data.person.subscriber_01.person.marital_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.race_cd =
request->patient_data.person.subscriber_01.person.race_cd
set pmdbdoc->patient_data.person.subscriber_01.person.religion_cd =
request->patient_data.person.subscriber_01.person.religion_cd
set pmdbdoc->patient_data.person.subscriber_01.person.sex_cd = request->patient_data.person.subscriber_01.person.sex_cd
set pmdbdoc->patient_data.person.subscriber_01.person.vip_cd = request->patient_data.person.subscriber_01.person.vip_cd
;subs1 home address
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.address_id
    = request->patient_data.person.subscriber_01.person.home_address.address_id
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.street_addr
    = request->patient_data.person.subscriber_01.person.home_address.street_addr
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.street_addr2
    = request->patient_data.person.subscriber_01.person.home_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.street_addr3
    = request->patient_data.person.subscriber_01.person.home_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.street_addr4
    = request->patient_data.person.subscriber_01.person.home_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.city
    = request->patient_data.person.subscriber_01.person.home_address.city
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.state
    = request->patient_data.person.subscriber_01.person.home_address.state
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.state_cd
    = request->patient_data.person.subscriber_01.person.home_address.state_cd
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.zipcode
    = request->patient_data.person.subscriber_01.person.home_address.zipcode
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.county
    = request->patient_data.person.subscriber_01.person.home_address.county
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.county_cd
    = request->patient_data.person.subscriber_01.person.home_address.county_cd
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.country
    = request->patient_data.person.subscriber_01.person.home_address.country
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.country_cd
    = request->patient_data.person.subscriber_01.person.home_address.country_cd
;subs1 bus address
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.address_id
    = request->patient_data.person.subscriber_01.person.bus_address.address_id
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.street_addr
    = request->patient_data.person.subscriber_01.person.bus_address.street_addr
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.street_addr2
    = request->patient_data.person.subscriber_01.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.street_addr3
    = request->patient_data.person.subscriber_01.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.street_addr4
    = request->patient_data.person.subscriber_01.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.city
    = request->patient_data.person.subscriber_01.person.bus_address.city
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.state
    = request->patient_data.person.subscriber_01.person.bus_address.state
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.state_cd
    = request->patient_data.person.subscriber_01.person.bus_address.state_cd
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.zipcode
    = request->patient_data.person.subscriber_01.person.bus_address.zipcode
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.county
    = request->patient_data.person.subscriber_01.person.bus_address.county
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.county_cd
    = request->patient_data.person.subscriber_01.person.bus_address.county_cd
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.country
    = request->patient_data.person.subscriber_01.person.bus_address.country
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.country_cd
    = request->patient_data.person.subscriber_01.person.bus_address.country_cd
;subs1 alt address
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.address_id
    = request->patient_data.person.subscriber_01.person.alt_address.address_id
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.street_addr
    = request->patient_data.person.subscriber_01.person.alt_address.street_addr
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.street_addr2
    = request->patient_data.person.subscriber_01.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.street_addr3
    = request->patient_data.person.subscriber_01.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.street_addr4
    = request->patient_data.person.subscriber_01.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.city
    = request->patient_data.person.subscriber_01.person.alt_address.city
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.state
    = request->patient_data.person.subscriber_01.person.alt_address.state
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.state_cd
    = request->patient_data.person.subscriber_01.person.alt_address.state_cd
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.zipcode
    = request->patient_data.person.subscriber_01.person.alt_address.zipcode
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.county
    = request->patient_data.person.subscriber_01.person.alt_address.county
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.county_cd
    = request->patient_data.person.subscriber_01.person.alt_address.county_cd
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.country
    = request->patient_data.person.subscriber_01.person.alt_address.country
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.country_cd
    = request->patient_data.person.subscriber_01.person.alt_address.country_cd
;subs1 email address
set pmdbdoc->patient_data.person.subscriber_01.person.email_address.address_id
    = request->patient_data.person.subscriber_01.person.email_address.address_id
set pmdbdoc->patient_data.person.subscriber_01.person.email_address.street_addr
    = request->patient_data.person.subscriber_01.person.email_address.street_addr
;subs1 email address phone table
set pmdbdoc->patient_data->person->subscriber_01->person->home_email.phone_id
    = request->patient_data->person->subscriber_01->person->home_email.phone_id
set pmdbdoc->patient_data->person->subscriber_01->person->home_email.email
    = trim(request->patient_data->person->subscriber_01->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->subscriber_01->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->subscriber_01->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->subscriber_01->person->home_email.end_effective_dt_tm
    = request->patient_data->person->subscriber_01->person->home_email.end_effective_dt_tm
;subs1 temp address
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.address_id
    = request->patient_data.person.subscriber_01.person.temp_address.address_id
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.street_addr
    = request->patient_data.person.subscriber_01.person.temp_address.street_addr
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.street_addr2
    = request->patient_data.person.subscriber_01.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.street_addr3
    = request->patient_data.person.subscriber_01.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.street_addr4
    = request->patient_data.person.subscriber_01.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.city
    = request->patient_data.person.subscriber_01.person.temp_address.city
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.state
    = request->patient_data.person.subscriber_01.person.temp_address.state
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.state_cd
    = request->patient_data.person.subscriber_01.person.temp_address.state_cd
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.zipcode
    = request->patient_data.person.subscriber_01.person.temp_address.zipcode
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.county
    = request->patient_data.person.subscriber_01.person.temp_address.county
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.county_cd
    = request->patient_data.person.subscriber_01.person.temp_address.county_cd
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.country
    = request->patient_data.person.subscriber_01.person.temp_address.country
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.country_cd
    = request->patient_data.person.subscriber_01.person.temp_address.country_cd
;subs1 mail address
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.address_id
    = request->patient_data.person.subscriber_01.person.mail_address.address_id
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.street_addr
    = request->patient_data.person.subscriber_01.person.mail_address.street_addr
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.street_addr2
    = request->patient_data.person.subscriber_01.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.street_addr3
    = request->patient_data.person.subscriber_01.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.street_addr4
    = request->patient_data.person.subscriber_01.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.city
    = request->patient_data.person.subscriber_01.person.mail_address.city
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.state
    = request->patient_data.person.subscriber_01.person.mail_address.state
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.state_cd
    = request->patient_data.person.subscriber_01.person.mail_address.state_cd
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.zipcode
    = request->patient_data.person.subscriber_01.person.mail_address.zipcode
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.county
    = request->patient_data.person.subscriber_01.person.mail_address.county
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.county_cd
    = request->patient_data.person.subscriber_01.person.mail_address.county_cd
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.country
    = request->patient_data.person.subscriber_01.person.mail_address.country
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.country_cd
    = request->patient_data.person.subscriber_01.person.mail_address.country_cd
;subs1 mobile phone
set pmdbdoc->patient_data.person.subscriber_01.person.mobile_phone.phone_id
    = request->patient_data.person.subscriber_01.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.mobile_phone.phone_format_cd
    = request->patient_data.person.subscriber_01.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.mobile_phone.phone_num
    = request->patient_data.person.subscriber_01.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.mobile_phone.extension
    = request->patient_data.person.subscriber_01.person.mobile_phone.extension
;subs1 home phone
set pmdbdoc->patient_data.person.subscriber_01.person.home_phone.phone_id
    = request->patient_data.person.subscriber_01.person.home_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.home_phone.phone_format_cd
    = request->patient_data.person.subscriber_01.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.home_phone.phone_num
    = request->patient_data.person.subscriber_01.person.home_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.home_phone.extension
    = request->patient_data.person.subscriber_01.person.home_phone.extension
;subs1 pager phone
set pmdbdoc->patient_data.person.subscriber_01.person.home_pager.phone_id
    = request->patient_data.person.subscriber_01.person.home_pager.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.home_pager.phone_format_cd
    = request->patient_data.person.subscriber_01.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.home_pager.phone_num
    = request->patient_data.person.subscriber_01.person.home_pager.phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.home_pager.extension
    = request->patient_data.person.subscriber_01.person.home_pager.extension
;subs1 bus phone
set pmdbdoc->patient_data.person.subscriber_01.person.bus_phone.phone_id
    = request->patient_data.person.subscriber_01.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.bus_phone.phone_format_cd
    = request->patient_data.person.subscriber_01.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.bus_phone.phone_num
    = request->patient_data.person.subscriber_01.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.bus_phone.extension
    = request->patient_data.person.subscriber_01.person.bus_phone.extension
;subs1 alt phone
set pmdbdoc->patient_data.person.subscriber_01.person.alt_phone.phone_id
    = request->patient_data.person.subscriber_01.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.alt_phone.phone_format_cd
    = request->patient_data.person.subscriber_01.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.alt_phone.phone_num
    = request->patient_data.person.subscriber_01.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.alt_phone.extension
    = request->patient_data.person.subscriber_01.person.alt_phone.extension
;subs1 temp phone
set pmdbdoc->patient_data.person.subscriber_01.person.temp_phone.phone_id
    = request->patient_data.person.subscriber_01.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.temp_phone.phone_format_cd
    = request->patient_data.person.subscriber_01.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.temp_phone.phone_num
    = request->patient_data.person.subscriber_01.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.temp_phone.extension
    = request->patient_data.person.subscriber_01.person.temp_phone.extension
;subs1 identifiers
set pmdbdoc->patient_data.person.subscriber_01.person.ssn.alias_pool_cd
    = request->patient_data.person.subscriber_01.person.ssn.alias_pool_cd
set pmdbdoc->patient_data.person.subscriber_01.person.ssn.person_alias_type_cd
    = request->patient_data.person.subscriber_01.person.ssn.person_alias_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.ssn.alias =
request->patient_data.person.subscriber_01.person.ssn.alias
set pmdbdoc->patient_data.person.subscriber_01.person.ssn.person_alias_sub_type_cd
    = request->patient_data.person.subscriber_01.person.ssn.person_alias_sub_type_cd
;subs1 employer
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.person_org_reltn_id
    = request->patient_data.person.subscriber_01.person.employer_01.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.person_id
    = request->patient_data.person.subscriber_01.person.employer_01.person_id
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.person_org_reltn_cd
    = request->patient_data.person.subscriber_01.person.employer_01.person_org_reltn_cd
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.organization_id
    = request->patient_data.person.subscriber_01.person.employer_01.organization_id
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.empl_retire_dt_tm
    = request->patient_data.person.subscriber_01.person.employer_01.empl_retire_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.empl_type_cd
    = request->patient_data.person.subscriber_01.person.employer_01.empl_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.empl_status_cd
    = request->patient_data.person.subscriber_01.person.employer_01.empl_status_cd
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.empl_occupation_text
    = request->patient_data.person.subscriber_01.person.employer_01.empl_occupation_text
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.empl_occupation_cd
    =  request->patient_data.person.subscriber_01.person.employer_01.empl_occupation_cd
;subs1 health plan info
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.person_plan_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.person_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.encntr_plan_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.encntr_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.health_plan_id
    = request->patient_data.person.subscriber_01.person.health_plan.health_plan_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.person_id
    = request->patient_data.person.subscriber_01.person.health_plan.person_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.person_plan_r_cd
    = request->patient_data.person.subscriber_01.person.health_plan.person_plan_r_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.person_org_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.subscriber_person_id
    = request->patient_data.person.subscriber_01.person.health_plan.subscriber_person_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.organization_id
    = request->patient_data.person.subscriber_01.person.health_plan.organization_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.member_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.member_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.signature_on_file_cd
    = request->patient_data.person.subscriber_01.person.health_plan.signature_on_file_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.balance_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.balance_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.deduct_amt
    = request->patient_data.person.subscriber_01.person.health_plan.deduct_amt
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.deduct_met_amt
    = request->patient_data.person.subscriber_01.person.health_plan.deduct_met_amt
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.deduct_met_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.deduct_met_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.coverage_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.coverage_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.max_out_pckt_amt
    = request->patient_data.person.subscriber_01.person.health_plan.max_out_pckt_amt
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.max_out_pckt_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.max_out_pckt_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.fam_deduct_met_amt
    = request->patient_data.person.subscriber_01.person.health_plan.fam_deduct_met_amt
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.fam_deduct_met_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.fam_deduct_met_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.verify_status_cd
    = request->patient_data.person.subscriber_01.person.health_plan.verify_status_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.verify_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.verify_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.verify_prsnl_id
    = request->patient_data.person.subscriber_01.person.health_plan.verify_prsnl_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.insured_card_name
    = request->patient_data.person.subscriber_01.person.health_plan.insured_card_name
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.beg_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.end_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.data_status_cd
    = request->patient_data.person.subscriber_01.person.health_plan.data_status_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.pat_member_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.pat_member_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.health_plan_id
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.health_plan_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_type_cd
 
if (cnvtupper(substring(1,4,request->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_name)) = "MISC")
   set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_name =
   request->patient_data.person.subscriber_01.person.health_plan.address.street_addr3
else
   set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_name
   = request->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_name
endif
 
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_desc
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_desc
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.financial_class_cd
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.financial_class_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_class_cd
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.plan_class_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.beg_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.end_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.plan_info.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_info.organization_id
    = request->patient_data.person.subscriber_01.person.health_plan.org_info.organization_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_info.org_name
    = request->patient_data.person.subscriber_01.person.health_plan.org_info.org_name
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.org_plan_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.org_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.health_plan_id
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.health_plan_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.org_plan_reltn_cd
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.org_plan_reltn_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.organization_id
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.organization_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.group_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.group_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.group_name
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.group_name
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.org_plan.policy_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.org_plan.policy_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.encntr_plan_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.encntr_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.encntr_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.encntr_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.person_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.person_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.person_plan_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.person_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.health_plan_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.health_plan_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.organization_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.organization_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.person_org_reltn_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.subscriber_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.subscriber_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.member_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.member_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.subs_member_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.subs_member_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.insur_source_info_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.insur_source_info_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.balance_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.balance_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.deduct_amt
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.deduct_amt
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.deduct_met_amt
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.deduct_met_amt
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.deduct_met_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.deduct_met_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.assign_benefits_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.assign_benefits_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.beg_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.end_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.insured_card_name
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.insured_card_name
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.data_status_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.data_status_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.authorization_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.authorization_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.description
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.description
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.cert_status_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.cert_status_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.total_service_nbr
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.total_service_nbr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.bnft_type_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.bnft_type_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.beg_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.end_effective_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.data_status_cd
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.data_status_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_detail_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_detail_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_company
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_company
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_contact
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_contact
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_dt_tm
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_dt_tm
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.plan_contact_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.plan_contact_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.long_text_id
    = request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.long_text_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.street_addr
    = request->patient_data.person.subscriber_01.person.health_plan.address.street_addr
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.street_addr2
    = request->patient_data.person.subscriber_01.person.health_plan.address.street_addr2
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.street_addr3
    = request->patient_data.person.subscriber_01.person.health_plan.address.street_addr3
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.street_addr4
    = request->patient_data.person.subscriber_01.person.health_plan.address.street_addr4
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.city
    = request->patient_data.person.subscriber_01.person.health_plan.address.city
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.state
    = request->patient_data.person.subscriber_01.person.health_plan.address.state
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.state_cd
    = request->patient_data.person.subscriber_01.person.health_plan.address.state_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.zipcode
    = request->patient_data.person.subscriber_01.person.health_plan.address.zipcode
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.county
    = request->patient_data.person.subscriber_01.person.health_plan.address.county
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.county_cd
    = request->patient_data.person.subscriber_01.person.health_plan.address.county_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.country
    = request->patient_data.person.subscriber_01.person.health_plan.address.country
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.country_cd
    = request->patient_data.person.subscriber_01.person.health_plan.address.country_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.phone.phone_id
    = request->patient_data.person.subscriber_01.person.health_plan.phone.phone_id
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.phone.phone_format_cd
    = request->patient_data.person.subscriber_01.person.health_plan.phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.phone.phone_num
    = request->patient_data.person.subscriber_01.person.health_plan.phone.phone_num
 
call DebugPrint("..... mapping Subscriber 02")
/*Subscriber 02 */
set pmdbdoc->patient_data.person.subscriber_02.person_person_reltn_id
    = request->patient_data.person.subscriber_02.person_person_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.encntr_person_reltn_id
    = request->patient_data.person.subscriber_02.encntr_person_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.person_reltn_type_cd
    = request->patient_data.person.subscriber_02.person_reltn_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person_id
    = request->patient_data.person.subscriber_02.person_id
set pmdbdoc->patient_data.person.subscriber_02.encntr_id
    = request->patient_data.person.subscriber_02.encntr_id
set pmdbdoc->patient_data.person.subscriber_02.person_reltn_cd
    = request->patient_data.person.subscriber_02.person_reltn_cd
set pmdbdoc->patient_data.person.subscriber_02.related_person_reltn_cd
    = request->patient_data.person.subscriber_02.related_person_reltn_cd
 
;subs2 person
set pmdbdoc->patient_data.person.subscriber_02.person.person_id
    = request->patient_data.person.subscriber_02.person.person_id
set pmdbdoc->patient_data.person.subscriber_02.person.person_type_cd
    = request->patient_data.person.subscriber_02.person.person_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.name_full_formatted
    = request->patient_data.person.subscriber_02.person.name_full_formatted
set pmdbdoc->patient_data.person.subscriber_02.person.birth_dt_tm
    = request->patient_data.person.subscriber_02.person.birth_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.birth_tz =
    request->patient_data.person.subscriber_02.person.birth_tz
set pmdbdoc->patient_data.person.subscriber_02.person.birth_prec_flag =
    request->patient_data.person.subscriber_02.person.birth_prec_flag
set pmdbdoc->patient_data.person.subscriber_02.person.language_cd
    = request->patient_data.person.subscriber_02.person.language_cd
set pmdbdoc->patient_data.person.subscriber_02.person.marital_type_cd
    = request->patient_data.person.subscriber_02.person.marital_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.race_cd
    = request->patient_data.person.subscriber_02.person.race_cd
set pmdbdoc->patient_data.person.subscriber_02.person.religion_cd
    = request->patient_data.person.subscriber_02.person.religion_cd
set pmdbdoc->patient_data.person.subscriber_02.person.sex_cd
    = request->patient_data.person.subscriber_02.person.sex_cd
set pmdbdoc->patient_data.person.subscriber_02.person.vip_cd
    = request->patient_data.person.subscriber_02.person.vip_cd
;subs2 home address
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.address_id
    = request->patient_data.person.subscriber_02.person.home_address.address_id
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.street_addr
    = request->patient_data.person.subscriber_02.person.home_address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.street_addr2
    = request->patient_data.person.subscriber_02.person.home_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.street_addr3
    = request->patient_data.person.subscriber_02.person.home_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.street_addr4
    = request->patient_data.person.subscriber_02.person.home_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.city
    = request->patient_data.person.subscriber_02.person.home_address.city
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.state
    = request->patient_data.person.subscriber_02.person.home_address.state
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.state_cd
    = request->patient_data.person.subscriber_02.person.home_address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.zipcode
    = request->patient_data.person.subscriber_02.person.home_address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.county
    =  request->patient_data.person.subscriber_02.person.home_address.county
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.county_cd
    = request->patient_data.person.subscriber_02.person.home_address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.country
    = request->patient_data.person.subscriber_02.person.home_address.country
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.country_cd
    = request->patient_data.person.subscriber_02.person.home_address.country_cd
;subs2 bus address
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.address_id
    = request->patient_data.person.subscriber_02.person.bus_address.address_id
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.street_addr
    = request->patient_data.person.subscriber_02.person.bus_address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.street_addr2
    = request->patient_data.person.subscriber_02.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.street_addr3
    = request->patient_data.person.subscriber_02.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.street_addr4
    = request->patient_data.person.subscriber_02.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.city
    = request->patient_data.person.subscriber_02.person.bus_address.city
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.state
    = request->patient_data.person.subscriber_02.person.bus_address.state
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.state_cd
    = request->patient_data.person.subscriber_02.person.bus_address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.zipcode
    = request->patient_data.person.subscriber_02.person.bus_address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.county
    = request->patient_data.person.subscriber_02.person.bus_address.county
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.county_cd
    = request->patient_data.person.subscriber_02.person.bus_address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.country
    = request->patient_data.person.subscriber_02.person.bus_address.country
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.country_cd
    = request->patient_data.person.subscriber_02.person.bus_address.country_cd
;subs2 alt address
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.address_id
    = request->patient_data.person.subscriber_02.person.alt_address.address_id
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.street_addr
    = request->patient_data.person.subscriber_02.person.alt_address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.street_addr2
    = request->patient_data.person.subscriber_02.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.street_addr3
    = request->patient_data.person.subscriber_02.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.street_addr4
    = request->patient_data.person.subscriber_02.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.city
    = request->patient_data.person.subscriber_02.person.alt_address.city
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.state
    = request->patient_data.person.subscriber_02.person.alt_address.state
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.state_cd
    = request->patient_data.person.subscriber_02.person.alt_address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.zipcode
    = request->patient_data.person.subscriber_02.person.alt_address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.county
    = request->patient_data.person.subscriber_02.person.alt_address.county
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.county_cd
    = request->patient_data.person.subscriber_02.person.alt_address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.country
    = request->patient_data.person.subscriber_02.person.alt_address.country
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.country_cd
    = request->patient_data.person.subscriber_02.person.alt_address.country_cd
;subs2 email address
set pmdbdoc->patient_data.person.subscriber_02.person.email_address.address_id
    = request->patient_data.person.subscriber_02.person.email_address.address_id
set pmdbdoc->patient_data.person.subscriber_02.person.email_address.street_addr
    = request->patient_data.person.subscriber_02.person.email_address.street_addr
;subs2 email address phone table
set pmdbdoc->patient_data->person->subscriber_02->person->home_email.phone_id
    = request->patient_data->person->subscriber_02->person->home_email.phone_id
set pmdbdoc->patient_data->person->subscriber_02->person->home_email.email
    = trim(request->patient_data->person->subscriber_02->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->subscriber_02->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->subscriber_02->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->subscriber_02->person->home_email.end_effective_dt_tm
    = request->patient_data->person->subscriber_02->person->home_email.end_effective_dt_tm
;subs2 temp address
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.address_id
    = request->patient_data.person.subscriber_02.person.temp_address.address_id
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.street_addr
    = request->patient_data.person.subscriber_02.person.temp_address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.street_addr2
    = request->patient_data.person.subscriber_02.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.street_addr3
    = request->patient_data.person.subscriber_02.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.street_addr4
    = request->patient_data.person.subscriber_02.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.city
    = request->patient_data.person.subscriber_02.person.temp_address.city
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.state
    = request->patient_data.person.subscriber_02.person.temp_address.state
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.state_cd
    = request->patient_data.person.subscriber_02.person.temp_address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.zipcode
    = request->patient_data.person.subscriber_02.person.temp_address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.county
    = request->patient_data.person.subscriber_02.person.temp_address.county
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.county_cd
    = request->patient_data.person.subscriber_02.person.temp_address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.country
    = request->patient_data.person.subscriber_02.person.temp_address.country
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.country_cd
    = request->patient_data.person.subscriber_02.person.temp_address.country_cd
;subs2 mail address
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.address_id
    = request->patient_data.person.subscriber_02.person.mail_address.address_id
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.street_addr
    = request->patient_data.person.subscriber_02.person.mail_address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.street_addr2
    = request->patient_data.person.subscriber_02.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.street_addr3
    = request->patient_data.person.subscriber_02.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.street_addr4
    = request->patient_data.person.subscriber_02.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.city
    = request->patient_data.person.subscriber_02.person.mail_address.city
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.state
    = request->patient_data.person.subscriber_02.person.mail_address.state
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.state_cd
    = request->patient_data.person.subscriber_02.person.mail_address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.zipcode
    = request->patient_data.person.subscriber_02.person.mail_address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.county
    = request->patient_data.person.subscriber_02.person.mail_address.county
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.county_cd
    = request->patient_data.person.subscriber_02.person.mail_address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.country
    = request->patient_data.person.subscriber_02.person.mail_address.country
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.country_cd
    = request->patient_data.person.subscriber_02.person.mail_address.country_cd
;subs2 mobile phone
set pmdbdoc->patient_data.person.subscriber_02.person.mobile_phone.phone_id
    = request->patient_data.person.subscriber_02.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.mobile_phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.mobile_phone.phone_num
    = request->patient_data.person.subscriber_02.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.mobile_phone.extension
    = request->patient_data.person.subscriber_02.person.mobile_phone.extension
;subs2 home phone
set pmdbdoc->patient_data.person.subscriber_02.person.home_phone.phone_id
    = request->patient_data.person.subscriber_02.person.home_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.home_phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.home_phone.phone_num
    = request->patient_data.person.subscriber_02.person.home_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.home_phone.extension
    = request->patient_data.person.subscriber_02.person.home_phone.extension
;subs2 home pager
set pmdbdoc->patient_data.person.subscriber_02.person.home_pager.phone_id
    = request->patient_data.person.subscriber_02.person.home_pager.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.home_pager.phone_format_cd
    = request->patient_data.person.subscriber_02.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.home_pager.phone_num
    = request->patient_data.person.subscriber_02.person.home_pager.phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.home_pager.extension
    = request->patient_data.person.subscriber_02.person.home_pager.extension
;subs2 bus phone
set pmdbdoc->patient_data.person.subscriber_02.person.bus_phone.phone_id
    = request->patient_data.person.subscriber_02.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.bus_phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.bus_phone.phone_num
    = request->patient_data.person.subscriber_02.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.bus_phone.extension
    = request->patient_data.person.subscriber_02.person.bus_phone.extension
;subs2 alt phone
set pmdbdoc->patient_data.person.subscriber_02.person.alt_phone.phone_id
    = request->patient_data.person.subscriber_02.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.alt_phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.alt_phone.phone_num
    = request->patient_data.person.subscriber_02.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.alt_phone.extension
    = request->patient_data.person.subscriber_02.person.alt_phone.extension
;subs2 temp phone
set pmdbdoc->patient_data.person.subscriber_02.person.temp_phone.phone_id
    = request->patient_data.person.subscriber_02.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.temp_phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.temp_phone.phone_num
    = request->patient_data.person.subscriber_02.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.temp_phone.extension
    = request->patient_data.person.subscriber_02.person.temp_phone.extension
;subs2 identifiers
set pmdbdoc->patient_data.person.subscriber_02.person.ssn.alias_pool_cd
    = request->patient_data.person.subscriber_02.person.ssn.alias_pool_cd
set pmdbdoc->patient_data.person.subscriber_02.person.ssn.person_alias_type_cd
    = request->patient_data.person.subscriber_02.person.ssn.person_alias_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.ssn.alias
    = request->patient_data.person.subscriber_02.person.ssn.alias
set pmdbdoc->patient_data.person.subscriber_02.person.ssn.person_alias_sub_type_cd
    = request->patient_data.person.subscriber_02.person.ssn.person_alias_sub_type_cd
;subs2 employer
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.person_org_reltn_id
    = request->patient_data.person.subscriber_02.person.employer_01.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.person_id
    = request->patient_data.person.subscriber_02.person.employer_01.person_id
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.person_org_reltn_cd
    = request->patient_data.person.subscriber_02.person.employer_01.person_org_reltn_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.organization_id
    = request->patient_data.person.subscriber_02.person.employer_01.organization_id
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.empl_retire_dt_tm
    = request->patient_data.person.subscriber_02.person.employer_01.empl_retire_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.empl_type_cd
    = request->patient_data.person.subscriber_02.person.employer_01.empl_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.empl_status_cd
    = request->patient_data.person.subscriber_02.person.employer_01.empl_status_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.empl_occupation_text
    = request->patient_data.person.subscriber_02.person.employer_01.empl_occupation_text
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.empl_occupation_cd
    = request->patient_data.person.subscriber_02.person.employer_01.empl_occupation_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.street_addr
    = request->patient_data.person.subscriber_02.person.employer_01.address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.street_addr2
    = request->patient_data.person.subscriber_02.person.employer_01.address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.street_addr3
    = request->patient_data.person.subscriber_02.person.employer_01.address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.street_addr4
    = request->patient_data.person.subscriber_02.person.employer_01.address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.city
    = request->patient_data.person.subscriber_02.person.employer_01.address.city
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.state
    = request->patient_data.person.subscriber_02.person.employer_01.address.state
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.state_cd
    = request->patient_data.person.subscriber_02.person.employer_01.address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.zipcode
    = request->patient_data.person.subscriber_02.person.employer_01.address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.county
    = request->patient_data.person.subscriber_02.person.employer_01.address.county
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.county_cd
    = request->patient_data.person.subscriber_02.person.employer_01.address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.country
    = request->patient_data.person.subscriber_02.person.employer_01.address.country
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.address.country_cd
    = request->patient_data.person.subscriber_02.person.employer_01.address.country_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.employer_01.phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.phone.phone_num
    = request->patient_data.person.subscriber_02.person.employer_01.phone.phone_num
;subs2 health plan info
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.health_plan_id
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.health_plan_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_type_cd
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_type_cd
 
if (cnvtupper(substring(1,4,request->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_name)) = "MISC")
   set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_name =
   request->patient_data.person.subscriber_02.person.health_plan.address.street_addr3
else
   set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_name
   = request->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_name
endif
 
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_desc
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_desc
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.financial_class_cd
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.financial_class_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_class_cd
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.plan_class_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.beg_effective_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.end_effective_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.plan_info.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_info.organization_id
    = request->patient_data.person.subscriber_02.person.health_plan.org_info.organization_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_info.org_name
    = request->patient_data.person.subscriber_02.person.health_plan.org_info.org_name
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.org_plan_reltn_id
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.org_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.health_plan_id
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.health_plan_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.org_plan_reltn_cd
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.org_plan_reltn_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.organization_id
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.organization_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.group_nbr
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.group_nbr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.group_name
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.group_name
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.org_plan.policy_nbr
    = request->patient_data.person.subscriber_02.person.health_plan.org_plan.policy_nbr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.encntr_plan_reltn_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.encntr_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.encntr_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.encntr_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.person_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.person_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.person_plan_reltn_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.person_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.health_plan_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.health_plan_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.organization_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.organization_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.person_org_reltn_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.subscriber_type_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.subscriber_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.member_nbr
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.member_nbr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.subs_member_nbr
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.subs_member_nbr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.insur_source_info_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.insur_source_info_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.balance_type_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.balance_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.deduct_amt
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.deduct_amt
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.deduct_met_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.deduct_met_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.assign_benefits_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.assign_benefits_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.beg_effective_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.end_effective_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.insured_card_name
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.insured_card_name
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.data_status_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.data_status_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.authorization_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.authorization_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_nbr
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_nbr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_type_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.description
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.description
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.cert_status_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.cert_status_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.total_service_nbr
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.total_service_nbr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.bnft_type_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.bnft_type_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.beg_effective_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.end_effective_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.data_status_cd
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.data_status_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_detail_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_detail_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_company
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_company
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_contact
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_contact
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_dt_tm
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_dt_tm
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.plan_contact_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.plan_contact_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.long_text_id
    = request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.long_text_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.street_addr
    = request->patient_data.person.subscriber_02.person.health_plan.address.street_addr
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.street_addr2
    = request->patient_data.person.subscriber_02.person.health_plan.address.street_addr2
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.street_addr3
    = request->patient_data.person.subscriber_02.person.health_plan.address.street_addr3
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.street_addr4
    = request->patient_data.person.subscriber_02.person.health_plan.address.street_addr4
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.city
    = request->patient_data.person.subscriber_02.person.health_plan.address.city
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.state
    = request->patient_data.person.subscriber_02.person.health_plan.address.state
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.state_cd
    = request->patient_data.person.subscriber_02.person.health_plan.address.state_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.zipcode
    = request->patient_data.person.subscriber_02.person.health_plan.address.zipcode
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.county
    = request->patient_data.person.subscriber_02.person.health_plan.address.county
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.county_cd
    = request->patient_data.person.subscriber_02.person.health_plan.address.county_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.country
    = request->patient_data.person.subscriber_02.person.health_plan.address.country
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.country_cd
    = request->patient_data.person.subscriber_02.person.health_plan.address.country_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.phone.phone_id
    = request->patient_data.person.subscriber_02.person.health_plan.phone.phone_id
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.phone.phone_format_cd
    = request->patient_data.person.subscriber_02.person.health_plan.phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.phone.phone_num
    = request->patient_data.person.subscriber_02.person.health_plan.phone.phone_num
 
call DebugPrint("..... mapping Subscriber 03")
 /*Subscriber 03 */
set pmdbdoc->patient_data.person.subscriber_03.person_person_reltn_id
    = request->patient_data.person.subscriber_03.person_person_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.encntr_person_reltn_id
    = request->patient_data.person.subscriber_03.encntr_person_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.person_reltn_type_cd
    = request->patient_data.person.subscriber_03.person_reltn_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person_id
    = request->patient_data.person.subscriber_03.person_id
set pmdbdoc->patient_data.person.subscriber_03.encntr_id
    = request->patient_data.person.subscriber_03.encntr_id
set pmdbdoc->patient_data.person.subscriber_03.person_reltn_cd
    = request->patient_data.person.subscriber_03.person_reltn_cd
set pmdbdoc->patient_data.person.subscriber_03.related_person_reltn_cd
    = request->patient_data.person.subscriber_03.related_person_reltn_cd
 
;subs3 person
set pmdbdoc->patient_data.person.subscriber_03.person.person_id
    = request->patient_data.person.subscriber_03.person.person_id
set pmdbdoc->patient_data.person.subscriber_03.person.person_type_cd
    = request->patient_data.person.subscriber_03.person.person_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.name_full_formatted
    = request->patient_data.person.subscriber_03.person.name_full_formatted
set pmdbdoc->patient_data.person.subscriber_03.person.birth_dt_tm
    = request->patient_data.person.subscriber_03.person.birth_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.birth_tz =
    request->patient_data.person.subscriber_03.person.birth_tz
set pmdbdoc->patient_data.person.subscriber_03.person.birth_prec_flag =
    request->patient_data.person.subscriber_03.person.birth_prec_flag
set pmdbdoc->patient_data.person.subscriber_03.person.language_cd
    = request->patient_data.person.subscriber_03.person.language_cd
set pmdbdoc->patient_data.person.subscriber_03.person.marital_type_cd
    = request->patient_data.person.subscriber_03.person.marital_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.race_cd
    = request->patient_data.person.subscriber_03.person.race_cd
set pmdbdoc->patient_data.person.subscriber_03.person.religion_cd
    = request->patient_data.person.subscriber_03.person.religion_cd
set pmdbdoc->patient_data.person.subscriber_03.person.sex_cd
    = request->patient_data.person.subscriber_03.person.sex_cd
set pmdbdoc->patient_data.person.subscriber_03.person.vip_cd
    = request->patient_data.person.subscriber_03.person.vip_cd
;subs3 home address
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.address_id
    = request->patient_data.person.subscriber_03.person.home_address.address_id
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.street_addr
    = request->patient_data.person.subscriber_03.person.home_address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.street_addr2
    = request->patient_data.person.subscriber_03.person.home_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.street_addr3
    = request->patient_data.person.subscriber_03.person.home_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.street_addr4
    = request->patient_data.person.subscriber_03.person.home_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.city
    = request->patient_data.person.subscriber_03.person.home_address.city
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.state
    = request->patient_data.person.subscriber_03.person.home_address.state
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.state_cd
    = request->patient_data.person.subscriber_03.person.home_address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.zipcode
    = request->patient_data.person.subscriber_03.person.home_address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.county
    =  request->patient_data.person.subscriber_03.person.home_address.county
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.county_cd
    = request->patient_data.person.subscriber_03.person.home_address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.country
    = request->patient_data.person.subscriber_03.person.home_address.country
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.country_cd
    = request->patient_data.person.subscriber_03.person.home_address.country_cd
;subs3 bus address
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.address_id
    = request->patient_data.person.subscriber_03.person.bus_address.address_id
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.street_addr
    = request->patient_data.person.subscriber_03.person.bus_address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.street_addr2
    = request->patient_data.person.subscriber_03.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.street_addr3
    = request->patient_data.person.subscriber_03.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.street_addr4
    = request->patient_data.person.subscriber_03.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.city
    = request->patient_data.person.subscriber_03.person.bus_address.city
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.state
    = request->patient_data.person.subscriber_03.person.bus_address.state
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.state_cd
    = request->patient_data.person.subscriber_03.person.bus_address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.zipcode
    = request->patient_data.person.subscriber_03.person.bus_address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.county
    = request->patient_data.person.subscriber_03.person.bus_address.county
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.county_cd
    = request->patient_data.person.subscriber_03.person.bus_address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.country
    = request->patient_data.person.subscriber_03.person.bus_address.country
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.country_cd
    = request->patient_data.person.subscriber_03.person.bus_address.country_cd
;subs3 alt address
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.address_id
    = request->patient_data.person.subscriber_03.person.alt_address.address_id
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.street_addr
    = request->patient_data.person.subscriber_03.person.alt_address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.street_addr2
    = request->patient_data.person.subscriber_03.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.street_addr3
    = request->patient_data.person.subscriber_03.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.street_addr4
    = request->patient_data.person.subscriber_03.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.city
    = request->patient_data.person.subscriber_03.person.alt_address.city
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.state
    = request->patient_data.person.subscriber_03.person.alt_address.state
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.state_cd
    = request->patient_data.person.subscriber_03.person.alt_address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.zipcode
    = request->patient_data.person.subscriber_03.person.alt_address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.county
    = request->patient_data.person.subscriber_03.person.alt_address.county
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.county_cd
    = request->patient_data.person.subscriber_03.person.alt_address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.country
    = request->patient_data.person.subscriber_03.person.alt_address.country
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.country_cd
    = request->patient_data.person.subscriber_03.person.alt_address.country_cd
;subs3 email address
set pmdbdoc->patient_data.person.subscriber_03.person.email_address.address_id
    = request->patient_data.person.subscriber_03.person.email_address.address_id
set pmdbdoc->patient_data.person.subscriber_03.person.email_address.street_addr
    = request->patient_data.person.subscriber_03.person.email_address.street_addr
;subs3 email address phone table
set pmdbdoc->patient_data->person->subscriber_03->person->home_email.phone_id
    = request->patient_data->person->subscriber_03->person->home_email.phone_id
set pmdbdoc->patient_data->person->subscriber_03->person->home_email.email
    = trim(request->patient_data->person->subscriber_03->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->subscriber_03->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->subscriber_03->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->subscriber_03->person->home_email.end_effective_dt_tm
    = request->patient_data->person->subscriber_03->person->home_email.end_effective_dt_tm
;subs3 temp address
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.address_id
    = request->patient_data.person.subscriber_03.person.temp_address.address_id
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.street_addr
    = request->patient_data.person.subscriber_03.person.temp_address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.street_addr2
    = request->patient_data.person.subscriber_03.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.street_addr3
    = request->patient_data.person.subscriber_03.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.street_addr4
    = request->patient_data.person.subscriber_03.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.city
    = request->patient_data.person.subscriber_03.person.temp_address.city
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.state
    = request->patient_data.person.subscriber_03.person.temp_address.state
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.state_cd
    = request->patient_data.person.subscriber_03.person.temp_address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.zipcode
    = request->patient_data.person.subscriber_03.person.temp_address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.county
    = request->patient_data.person.subscriber_03.person.temp_address.county
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.county_cd
    = request->patient_data.person.subscriber_03.person.temp_address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.country
    = request->patient_data.person.subscriber_03.person.temp_address.country
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.country_cd
    = request->patient_data.person.subscriber_03.person.temp_address.country_cd
;subs3 mail address
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.address_id
    = request->patient_data.person.subscriber_03.person.mail_address.address_id
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.street_addr
    = request->patient_data.person.subscriber_03.person.mail_address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.street_addr2
    = request->patient_data.person.subscriber_03.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.street_addr3
    = request->patient_data.person.subscriber_03.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.street_addr4
    = request->patient_data.person.subscriber_03.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.city
    = request->patient_data.person.subscriber_03.person.mail_address.city
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.state
    = request->patient_data.person.subscriber_03.person.mail_address.state
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.state_cd
    = request->patient_data.person.subscriber_03.person.mail_address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.zipcode
    = request->patient_data.person.subscriber_03.person.mail_address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.county
    = request->patient_data.person.subscriber_03.person.mail_address.county
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.county_cd
    = request->patient_data.person.subscriber_03.person.mail_address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.country
    = request->patient_data.person.subscriber_03.person.mail_address.country
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.country_cd
    = request->patient_data.person.subscriber_03.person.mail_address.country_cd
;subs3 mobile phone
set pmdbdoc->patient_data.person.subscriber_03.person.mobile_phone.phone_id
    = request->patient_data.person.subscriber_03.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.mobile_phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.mobile_phone.phone_num
    = request->patient_data.person.subscriber_03.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.mobile_phone.extension
    = request->patient_data.person.subscriber_03.person.mobile_phone.extension
;subs3 home phone
set pmdbdoc->patient_data.person.subscriber_03.person.home_phone.phone_id
    = request->patient_data.person.subscriber_03.person.home_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.home_phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.home_phone.phone_num
    = request->patient_data.person.subscriber_03.person.home_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.home_phone.extension
    = request->patient_data.person.subscriber_03.person.home_phone.extension
;subs3 home pager
set pmdbdoc->patient_data.person.subscriber_03.person.home_pager.phone_id
    = request->patient_data.person.subscriber_03.person.home_pager.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.home_pager.phone_format_cd
    = request->patient_data.person.subscriber_03.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.home_pager.phone_num
    = request->patient_data.person.subscriber_03.person.home_pager.phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.home_pager.extension
    = request->patient_data.person.subscriber_03.person.home_pager.extension
;subs3 bus phone
set pmdbdoc->patient_data.person.subscriber_03.person.bus_phone.phone_id
    = request->patient_data.person.subscriber_03.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.bus_phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.bus_phone.phone_num
    = request->patient_data.person.subscriber_03.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.bus_phone.extension
    = request->patient_data.person.subscriber_03.person.bus_phone.extension
;subs3 alt phone
set pmdbdoc->patient_data.person.subscriber_03.person.alt_phone.phone_id
    = request->patient_data.person.subscriber_03.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.alt_phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.alt_phone.phone_num
    = request->patient_data.person.subscriber_03.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.alt_phone.extension
    = request->patient_data.person.subscriber_03.person.alt_phone.extension
;subs3 temp phone
set pmdbdoc->patient_data.person.subscriber_03.person.temp_phone.phone_id
    = request->patient_data.person.subscriber_03.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.temp_phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.temp_phone.phone_num
    = request->patient_data.person.subscriber_03.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.temp_phone.extension
    = request->patient_data.person.subscriber_03.person.temp_phone.extension
;subs3 identifiers
set pmdbdoc->patient_data.person.subscriber_03.person.ssn.alias_pool_cd
    = request->patient_data.person.subscriber_03.person.ssn.alias_pool_cd
set pmdbdoc->patient_data.person.subscriber_03.person.ssn.person_alias_type_cd
    = request->patient_data.person.subscriber_03.person.ssn.person_alias_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.ssn.alias
    = request->patient_data.person.subscriber_03.person.ssn.alias
set pmdbdoc->patient_data.person.subscriber_03.person.ssn.person_alias_sub_type_cd
    = request->patient_data.person.subscriber_03.person.ssn.person_alias_sub_type_cd
;subs3 employer
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.person_org_reltn_id
    = request->patient_data.person.subscriber_03.person.employer_01.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.person_id
    = request->patient_data.person.subscriber_03.person.employer_01.person_id
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.person_org_reltn_cd
    = request->patient_data.person.subscriber_03.person.employer_01.person_org_reltn_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.organization_id
    = request->patient_data.person.subscriber_03.person.employer_01.organization_id
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.empl_retire_dt_tm
    = request->patient_data.person.subscriber_03.person.employer_01.empl_retire_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.empl_type_cd
    = request->patient_data.person.subscriber_03.person.employer_01.empl_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.empl_status_cd
    = request->patient_data.person.subscriber_03.person.employer_01.empl_status_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.empl_occupation_text
    = request->patient_data.person.subscriber_03.person.employer_01.empl_occupation_text
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.empl_occupation_cd
    = request->patient_data.person.subscriber_03.person.employer_01.empl_occupation_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.street_addr
    = request->patient_data.person.subscriber_03.person.employer_01.address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.street_addr2
    = request->patient_data.person.subscriber_03.person.employer_01.address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.street_addr3
    = request->patient_data.person.subscriber_03.person.employer_01.address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.street_addr4
    = request->patient_data.person.subscriber_03.person.employer_01.address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.city
    = request->patient_data.person.subscriber_03.person.employer_01.address.city
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.state
    = request->patient_data.person.subscriber_03.person.employer_01.address.state
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.state_cd
    = request->patient_data.person.subscriber_03.person.employer_01.address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.zipcode
    = request->patient_data.person.subscriber_03.person.employer_01.address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.county
    = request->patient_data.person.subscriber_03.person.employer_01.address.county
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.county_cd
    = request->patient_data.person.subscriber_03.person.employer_01.address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.country
    = request->patient_data.person.subscriber_03.person.employer_01.address.country
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.address.country_cd
    = request->patient_data.person.subscriber_03.person.employer_01.address.country_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.employer_01.phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.phone.phone_num
    = request->patient_data.person.subscriber_03.person.employer_01.phone.phone_num
;subs3 health plan info
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.health_plan_id
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.health_plan_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_type_cd
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_type_cd
 
;Flexes Health Plan Name or Other Health Plan Name based on Miscellaneous plan or not
if (cnvtupper(substring(1,4,request->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_name)) = "MISC")
   set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_name =
   request->patient_data.person.subscriber_03.person.health_plan.address.street_addr3
else
   set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_name
   = request->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_name
endif
 
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_desc
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_desc
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.financial_class_cd
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.financial_class_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_class_cd
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.plan_class_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.beg_effective_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.end_effective_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.plan_info.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_info.organization_id
    = request->patient_data.person.subscriber_03.person.health_plan.org_info.organization_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_info.org_name
    = request->patient_data.person.subscriber_03.person.health_plan.org_info.org_name
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.org_plan_reltn_id
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.org_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.health_plan_id
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.health_plan_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.org_plan_reltn_cd
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.org_plan_reltn_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.organization_id
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.organization_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.group_nbr
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.group_nbr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.group_name
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.group_name
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.org_plan.policy_nbr
    = request->patient_data.person.subscriber_03.person.health_plan.org_plan.policy_nbr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.encntr_plan_reltn_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.encntr_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.encntr_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.encntr_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.person_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.person_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.person_plan_reltn_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.person_plan_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.health_plan_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.health_plan_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.organization_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.organization_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.person_org_reltn_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.person_org_reltn_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.subscriber_type_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.subscriber_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.member_nbr
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.member_nbr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.subs_member_nbr
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.subs_member_nbr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.insur_source_info_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.insur_source_info_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.balance_type_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.balance_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.deduct_amt
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.deduct_amt
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.deduct_met_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.deduct_met_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.assign_benefits_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.assign_benefits_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.beg_effective_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.end_effective_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.insured_card_name
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.insured_card_name
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.data_status_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.data_status_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.authorization_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.authorization_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_nbr
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_nbr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_type_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.description
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.description
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.cert_status_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.cert_status_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.total_service_nbr
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.total_service_nbr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.bnft_type_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.bnft_type_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.beg_effective_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.beg_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.end_effective_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.end_effective_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.data_status_cd
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.data_status_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_detail_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_detail_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_company
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_company
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_contact
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_contact
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_dt_tm
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_dt_tm
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.plan_contact_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.plan_contact_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.long_text_id
    = request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.long_text_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.street_addr
    = request->patient_data.person.subscriber_03.person.health_plan.address.street_addr
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.street_addr2
    = request->patient_data.person.subscriber_03.person.health_plan.address.street_addr2
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.street_addr3
    = request->patient_data.person.subscriber_03.person.health_plan.address.street_addr3
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.street_addr4
    = request->patient_data.person.subscriber_03.person.health_plan.address.street_addr4
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.city
    = request->patient_data.person.subscriber_03.person.health_plan.address.city
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.state
    = request->patient_data.person.subscriber_03.person.health_plan.address.state
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.state_cd
    = request->patient_data.person.subscriber_03.person.health_plan.address.state_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.zipcode
    = request->patient_data.person.subscriber_03.person.health_plan.address.zipcode
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.county
    = request->patient_data.person.subscriber_03.person.health_plan.address.county
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.county_cd
    = request->patient_data.person.subscriber_03.person.health_plan.address.county_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.country
    = request->patient_data.person.subscriber_03.person.health_plan.address.country
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.country_cd
    = request->patient_data.person.subscriber_03.person.health_plan.address.country_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.phone.phone_id
    = request->patient_data.person.subscriber_03.person.health_plan.phone.phone_id
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.phone.phone_format_cd
    = request->patient_data.person.subscriber_03.person.health_plan.phone.phone_format_cd
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.phone.phone_num
    = request->patient_data.person.subscriber_03.person.health_plan.phone.phone_num
 
call DebugPrint("..... mapping Guarantor 01")
/*Guarantor 1*/
set pmdbdoc->patient_data.person.guarantor_01.person_person_reltn_id
    = request->patient_data.person.guarantor_01.person_person_reltn_id
set pmdbdoc->patient_data.person.guarantor_01.encntr_person_reltn_id
    = request->patient_data.person.guarantor_01.encntr_person_reltn_id
set pmdbdoc->patient_data.person.guarantor_01.guarantor_org_ind
    = request->patient_data.person.guarantor_01.guarantor_org_ind
set pmdbdoc->patient_data.person.guarantor_01.person_reltn_type_cd
    = request->patient_data.person.guarantor_01.person_reltn_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person_id
    = request->patient_data.person.guarantor_01.person_id
set pmdbdoc->patient_data.person.guarantor_01.encntr_id
    = request->patient_data.person.guarantor_01.encntr_id
set pmdbdoc->patient_data.person.guarantor_01.person_reltn_cd
    = request->patient_data.person.guarantor_01.person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_01.prior_person_reltn_cd
    = request->patient_data.person.guarantor_01.prior_person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_01.related_person_reltn_cd
    = request->patient_data.person.guarantor_01.related_person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_01.prior_related_person_reltn_cd
    = request->patient_data.person.guarantor_01.prior_related_person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_01.related_person_id
    = request->patient_data.person.guarantor_01.related_person_id
set pmdbdoc->patient_data.person.guarantor_01.person.person_id
    = request->patient_data.person.guarantor_01.person.person_id
set pmdbdoc->patient_data.person.guarantor_01.person.name_full_formatted
    = request->patient_data.person.guarantor_01.person.name_full_formatted
set pmdbdoc->patient_data.person.guarantor_01.person.birth_dt_tm
    = request->patient_data.person.guarantor_01.person.birth_dt_tm
set pmdbdoc->patient_data.person.guarantor_01.person.birth_tz
    = request->patient_data.person.guarantor_01.person.birth_tz
set pmdbdoc->patient_data.person.guarantor_01.person.birth_prec_flag
    = request->patient_data.person.guarantor_01.person.birth_prec_flag
set pmdbdoc->patient_data.person.guarantor_01.person.ethnic_grp_cd
    = request->patient_data.person.guarantor_01.person.ethnic_grp_cd
set pmdbdoc->patient_data.person.guarantor_01.person.language_cd
    = request->patient_data.person.guarantor_01.person.language_cd
set pmdbdoc->patient_data.person.guarantor_01.person.marital_type_cd
    = request->patient_data.person.guarantor_01.person.marital_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.race_cd
    = request->patient_data.person.guarantor_01.person.race_cd
set pmdbdoc->patient_data.person.guarantor_01.person.religion_cd
    = request->patient_data.person.guarantor_01.person.religion_cd
set pmdbdoc->patient_data.person.guarantor_01.person.sex_cd
    = request->patient_data.person.guarantor_01.person.sex_cd
set pmdbdoc->patient_data.person.guarantor_01.person.name_last
    = request->patient_data.person.guarantor_01.person.name_last
set pmdbdoc->patient_data.person.guarantor_01.person.name_first
    = request->patient_data.person.guarantor_01.person.name_first
set pmdbdoc->patient_data.person.guarantor_01.person.vip_cd
    =  request->patient_data.person.guarantor_01.person.vip_cd
set pmdbdoc->patient_data.person.guarantor_01.person.name_middle
    = request->patient_data.person.guarantor_01.person.name_middle
;Guarantor home address
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.address_id
    = request->patient_data.person.guarantor_01.person.home_address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.street_addr
    = request->patient_data.person.guarantor_01.person.home_address.street_addr
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.street_addr2
    =  request->patient_data.person.guarantor_01.person.home_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.street_addr3
    = request->patient_data.person.guarantor_01.person.home_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.street_addr4
    = request->patient_data.person.guarantor_01.person.home_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.city
    = request->patient_data.person.guarantor_01.person.home_address.city
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.state
    = request->patient_data.person.guarantor_01.person.home_address.state
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.state_cd
    = request->patient_data.person.guarantor_01.person.home_address.state_cd
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.zipcode
    = request->patient_data.person.guarantor_01.person.home_address.zipcode
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.county
    = request->patient_data.person.guarantor_01.person.home_address.county
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.county_cd
    = request->patient_data.person.guarantor_01.person.home_address.county_cd
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.country
    = request->patient_data.person.guarantor_01.person.home_address.country
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.country_cd
    = request->patient_data.person.guarantor_01.person.home_address.country_cd
;guarantor bus address
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.address_id
    = request->patient_data.person.guarantor_01.person.bus_address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.street_addr
    =  request->patient_data.person.guarantor_01.person.bus_address.street_addr
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.street_addr2
    = request->patient_data.person.guarantor_01.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.street_addr3
    = request->patient_data.person.guarantor_01.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.street_addr4
    = request->patient_data.person.guarantor_01.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.city
    = request->patient_data.person.guarantor_01.person.bus_address.city
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.state
    = request->patient_data.person.guarantor_01.person.bus_address.state
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.state_cd
    = request->patient_data.person.guarantor_01.person.bus_address.state_cd
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.zipcode
    = request->patient_data.person.guarantor_01.person.bus_address.zipcode
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.county
    = request->patient_data.person.guarantor_01.person.bus_address.county
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.county_cd
    = request->patient_data.person.guarantor_01.person.bus_address.county_cd
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.country
    = request->patient_data.person.guarantor_01.person.bus_address.country
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.country_cd
    = request->patient_data.person.guarantor_01.person.bus_address.country_cd
;guarantor alt address
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.address_id
    = request->patient_data.person.guarantor_01.person.alt_address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.street_addr
    =  request->patient_data.person.guarantor_01.person.alt_address.street_addr
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.street_addr2
    = request->patient_data.person.guarantor_01.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.street_addr3
    = request->patient_data.person.guarantor_01.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.street_addr4
    = request->patient_data.person.guarantor_01.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.city
    = request->patient_data.person.guarantor_01.person.alt_address.city
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.state
    = request->patient_data.person.guarantor_01.person.alt_address.state
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.state_cd
    = request->patient_data.person.guarantor_01.person.alt_address.state_cd
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.zipcode
    = request->patient_data.person.guarantor_01.person.alt_address.zipcode
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.county
    = request->patient_data.person.guarantor_01.person.alt_address.county
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.county_cd
    = request->patient_data.person.guarantor_01.person.alt_address.county_cd
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.country
    = request->patient_data.person.guarantor_01.person.alt_address.country
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.country_cd
    = request->patient_data.person.guarantor_01.person.alt_address.country_cd
;guarantor email address
set pmdbdoc->patient_data.person.guarantor_01.person.email_address.address_id
    = request->patient_data.person.guarantor_01.person.email_address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.email_address.street_addr
    =  request->patient_data.person.guarantor_01.person.email_address.street_addr
;guarantor email address phone table
set pmdbdoc->patient_data->person->guarantor_01->person->home_email.phone_id
    = request->patient_data->person->guarantor_01->person->home_email.phone_id
set pmdbdoc->patient_data->person->guarantor_01->person->home_email.email
    = trim(request->patient_data->person->guarantor_01->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->guarantor_01->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->guarantor_01->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->guarantor_01->person->home_email.end_effective_dt_tm
    = request->patient_data->person->guarantor_01->person->home_email.end_effective_dt_tm
;guarantor temp address
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.address_id
    = request->patient_data.person.guarantor_01.person.temp_address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.street_addr
    =  request->patient_data.person.guarantor_01.person.temp_address.street_addr
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.street_addr2
    = request->patient_data.person.guarantor_01.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.street_addr3
    = request->patient_data.person.guarantor_01.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.street_addr4
    = request->patient_data.person.guarantor_01.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.city
    = request->patient_data.person.guarantor_01.person.temp_address.city
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.state
    = request->patient_data.person.guarantor_01.person.temp_address.state
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.state_cd
    = request->patient_data.person.guarantor_01.person.temp_address.state_cd
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.zipcode
    = request->patient_data.person.guarantor_01.person.temp_address.zipcode
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.county
    = request->patient_data.person.guarantor_01.person.temp_address.county
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.county_cd
    = request->patient_data.person.guarantor_01.person.temp_address.county_cd
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.country
    = request->patient_data.person.guarantor_01.person.temp_address.country
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.country_cd
    = request->patient_data.person.guarantor_01.person.temp_address.country_cd
;guarantor mail address
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.address_id
    = request->patient_data.person.guarantor_01.person.mail_address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.street_addr
    =  request->patient_data.person.guarantor_01.person.mail_address.street_addr
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.street_addr2
    = request->patient_data.person.guarantor_01.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.street_addr3
    = request->patient_data.person.guarantor_01.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.street_addr4
    = request->patient_data.person.guarantor_01.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.city
    = request->patient_data.person.guarantor_01.person.mail_address.city
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.state
    = request->patient_data.person.guarantor_01.person.mail_address.state
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.state_cd
    = request->patient_data.person.guarantor_01.person.mail_address.state_cd
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.zipcode
    = request->patient_data.person.guarantor_01.person.mail_address.zipcode
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.county
    = request->patient_data.person.guarantor_01.person.mail_address.county
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.county_cd
    = request->patient_data.person.guarantor_01.person.mail_address.county_cd
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.country
    = request->patient_data.person.guarantor_01.person.mail_address.country
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.country_cd
    = request->patient_data.person.guarantor_01.person.mail_address.country_cd
;guarantor mobile phone
set pmdbdoc->patient_data.person.guarantor_01.person.mobile_phone.phone_id
    = request->patient_data.person.guarantor_01.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.mobile_phone.phone_format_cd
    = request->patient_data.person.guarantor_01.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.mobile_phone.phone_num
    = request->patient_data.person.guarantor_01.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_01.person.mobile_phone.extension
    = request->patient_data.person.guarantor_01.person.mobile_phone.extension
;guarantor home phone
set pmdbdoc->patient_data.person.guarantor_01.person.home_phone.phone_id
    = request->patient_data.person.guarantor_01.person.home_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.home_phone.phone_format_cd
    = request->patient_data.person.guarantor_01.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.home_phone.phone_num
    = request->patient_data.person.guarantor_01.person.home_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_01.person.home_phone.extension
    = request->patient_data.person.guarantor_01.person.home_phone.extension
;guarantor pager phone
set pmdbdoc->patient_data.person.guarantor_01.person.home_pager.phone_id
    = request->patient_data.person.guarantor_01.person.home_pager.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.home_pager.phone_format_cd
    = request->patient_data.person.guarantor_01.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.home_pager.phone_num
    = request->patient_data.person.guarantor_01.person.home_pager.phone_num
set pmdbdoc->patient_data.person.guarantor_01.person.home_pager.extension
    = request->patient_data.person.guarantor_01.person.home_pager.extension
;guarantor bus Phone
set pmdbdoc->patient_data.person.guarantor_01.person.bus_phone.phone_id
     = request->patient_data.person.guarantor_01.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.bus_phone.phone_format_cd
     = request->patient_data.person.guarantor_01.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.bus_phone.phone_num
     = request->patient_data.person.guarantor_01.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_01.person.bus_phone.extension
     = request->patient_data.person.guarantor_01.person.bus_phone.extension
;guarantor alt phone
set pmdbdoc->patient_data.person.guarantor_01.person.alt_phone.phone_id
    = request->patient_data.person.guarantor_01.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.alt_phone.phone_format_cd
    = request->patient_data.person.guarantor_01.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.alt_phone.phone_num
    = request->patient_data.person.guarantor_01.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_01.person.alt_phone.extension
    = request->patient_data.person.guarantor_01.person.alt_phone.extension
;guarantor temp phone
set pmdbdoc->patient_data.person.guarantor_01.person.temp_phone.phone_id
    = request->patient_data.person.guarantor_01.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.temp_phone.phone_format_cd
    = request->patient_data.person.guarantor_01.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.temp_phone.phone_num
    = request->patient_data.person.guarantor_01.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_01.person.temp_phone.extension
    = request->patient_data.person.guarantor_01.person.temp_phone.extension
;guarantor identifiers
set pmdbdoc->patient_data.person.guarantor_01.person.mrn.person_alias_id
    = request->patient_data.person.guarantor_01.person.mrn.person_alias_id
set pmdbdoc->patient_data.person.guarantor_01.person.mrn.alias_pool_cd
    = request->patient_data.person.guarantor_01.person.mrn.alias_pool_cd
set pmdbdoc->patient_data.person.guarantor_01.person.mrn.person_alias_type_cd
    = request->patient_data.person.guarantor_01.person.mrn.person_alias_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.mrn.alias
    = request->patient_data.person.guarantor_01.person.mrn.alias
set pmdbdoc->patient_data.person.guarantor_01.person.mrn.person_alias_sub_type_cd
    = request->patient_data.person.guarantor_01.person.mrn.person_alias_sub_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.ssn.person_alias_id
    = request->patient_data.person.guarantor_01.person.ssn.person_alias_id
set pmdbdoc->patient_data.person.guarantor_01.person.ssn.alias_pool_cd
    = request->patient_data.person.guarantor_01.person.ssn.alias_pool_cd
set pmdbdoc->patient_data.person.guarantor_01.person.ssn.person_alias_type_cd
    = request->patient_data.person.guarantor_01.person.ssn.person_alias_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.ssn.alias
    = request->patient_data.person.guarantor_01.person.ssn.alias
set pmdbdoc->patient_data.person.guarantor_01.person.ssn.person_alias_sub_type_cd
    = request->patient_data.person.guarantor_01.person.ssn.person_alias_sub_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.cmrn.person_alias_id
    = request->patient_data.person.guarantor_01.person.cmrn.person_alias_id
set pmdbdoc->patient_data.person.guarantor_01.person.cmrn.alias_pool_cd
    = request->patient_data.person.guarantor_01.person.cmrn.alias_pool_cd
set pmdbdoc->patient_data.person.guarantor_01.person.cmrn.person_alias_type_cd
    = request->patient_data.person.guarantor_01.person.cmrn.person_alias_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.cmrn.person_alias_sub_type_cd
    = request->patient_data.person.guarantor_01.person.cmrn.person_alias_sub_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.cmrn.alias
    = request->patient_data.person.guarantor_01.person.cmrn.alias
;guarantor employer
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.person_org_reltn_id
    = request->patient_data.person.guarantor_01.person.employer_01.person_org_reltn_id
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.person_org_reltn_cd
    = request->patient_data.person.guarantor_01.person.employer_01.person_org_reltn_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.organization_id
    = request->patient_data.person.guarantor_01.person.employer_01.organization_id
set  pmdbdoc->patient_data.person.guarantor_01.person.employer_01.empl_retire_dt_tm
    = request->patient_data.person.guarantor_01.person.employer_01.empl_retire_dt_tm
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.empl_type_cd
    = request->patient_data.person.guarantor_01.person.employer_01.empl_type_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.empl_status_cd
    = request->patient_data.person.guarantor_01.person.employer_01.empl_status_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.empl_occupation_text
    = request->patient_data.person.guarantor_01.person.employer_01.empl_occupation_text
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.empl_occupation_cd
    = request->patient_data.person.guarantor_01.person.employer_01.empl_occupation_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.address_id
    = request->patient_data.person.guarantor_01.person.employer_01.address.address_id
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.street_addr
    = request->patient_data.person.guarantor_01.person.employer_01.address.street_addr
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.street_addr2
    = request->patient_data.person.guarantor_01.person.employer_01.address.street_addr2
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.street_addr3
    = request->patient_data.person.guarantor_01.person.employer_01.address.street_addr3
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.street_addr4
    = request->patient_data.person.guarantor_01.person.employer_01.address.street_addr4
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.city
    = request->patient_data.person.guarantor_01.person.employer_01.address.city
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.state
    = request->patient_data.person.guarantor_01.person.employer_01.address.state
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.state_cd
    = request->patient_data.person.guarantor_01.person.employer_01.address.state_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.zipcode
    = request->patient_data.person.guarantor_01.person.employer_01.address.zipcode
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.county
    = request->patient_data.person.guarantor_01.person.employer_01.address.county
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.county_cd
    = request->patient_data.person.guarantor_01.person.employer_01.address.county_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.country
    = request->patient_data.person.guarantor_01.person.employer_01.address.country
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.country_cd
    = request->patient_data.person.guarantor_01.person.employer_01.address.country_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.phone.phone_id
    = request->patient_data.person.guarantor_01.person.employer_01.phone.phone_id
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.phone.phone_format_cd
    = request->patient_data.person.guarantor_01.person.employer_01.phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.phone.phone_num
    = request->patient_data.person.guarantor_01.person.employer_01.phone.phone_num
    
;guarantor organization
set pmdbdoc->patient_data.person.guarantor_01.organization.organization_id
    = request->patient_data.person.guarantor_01.guarantor_org.organization_id
set pmdbdoc->patient_data.person.guarantor_01.organization.person_org_nbr
    = request->patient_data.person.guarantor_01.guarantor_org.person_org_nbr
set pmdbdoc->patient_data.person.guarantor_01.organization.person_org_alias
    = request->patient_data.person.guarantor_01.guarantor_org.person_org_alias
set pmdbdoc->patient_data.person.guarantor_01.organization.free_text_ind
    = request->patient_data.person.guarantor_01.guarantor_org.free_text_ind
set pmdbdoc->patient_data.person.guarantor_01.organization.data_status_cd
    = request->patient_data.person.guarantor_01.guarantor_org.data_status_cd
 
call DebugPrint("..... mapping Guarantor 02")
/*Guarantor 2*/
set pmdbdoc->patient_data.person.guarantor_02.person_person_reltn_id
    = request->patient_data.person.guarantor_02.person_person_reltn_id
set pmdbdoc->patient_data.person.guarantor_02.encntr_person_reltn_id
    = request->patient_data.person.guarantor_02.encntr_person_reltn_id
set pmdbdoc->patient_data.person.guarantor_02.guarantor_org_ind
    = request->patient_data.person.guarantor_02.guarantor_org_ind
set pmdbdoc->patient_data.person.guarantor_02.person_reltn_type_cd
    = request->patient_data.person.guarantor_02.person_reltn_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person_id
    = request->patient_data.person.guarantor_02.person_id
set pmdbdoc->patient_data.person.guarantor_02.encntr_id
    = request->patient_data.person.guarantor_02.encntr_id
set pmdbdoc->patient_data.person.guarantor_02.person_reltn_cd
    = request->patient_data.person.guarantor_02.person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_02.prior_person_reltn_cd
    = request->patient_data.person.guarantor_02.prior_person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_02.related_person_reltn_cd
    = request->patient_data.person.guarantor_02.related_person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_02.prior_related_person_reltn_cd
    = request->patient_data.person.guarantor_02.prior_related_person_reltn_cd
set pmdbdoc->patient_data.person.guarantor_02.related_person_id
    = request->patient_data.person.guarantor_02.related_person_id
set pmdbdoc->patient_data.person.guarantor_02.person.person_id
    = request->patient_data.person.guarantor_02.person.person_id
set pmdbdoc->patient_data.person.guarantor_02.person.name_full_formatted
    = request->patient_data.person.guarantor_02.person.name_full_formatted
set pmdbdoc->patient_data.person.guarantor_02.person.birth_dt_tm
    = request->patient_data.person.guarantor_02.person.birth_dt_tm
set pmdbdoc->patient_data.person.guarantor_02.person.birth_tz
    = request->patient_data.person.guarantor_02.person.birth_tz
set pmdbdoc->patient_data.person.guarantor_02.person.birth_prec_flag
    = request->patient_data.person.guarantor_02.person.birth_prec_flag
set pmdbdoc->patient_data.person.guarantor_02.person.ethnic_grp_cd
    = request->patient_data.person.guarantor_02.person.ethnic_grp_cd
set pmdbdoc->patient_data.person.guarantor_02.person.language_cd
    = request->patient_data.person.guarantor_02.person.language_cd
set pmdbdoc->patient_data.person.guarantor_02.person.marital_type_cd
    = request->patient_data.person.guarantor_02.person.marital_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.race_cd
    = request->patient_data.person.guarantor_02.person.race_cd
set pmdbdoc->patient_data.person.guarantor_02.person.religion_cd
    = request->patient_data.person.guarantor_02.person.religion_cd
set pmdbdoc->patient_data.person.guarantor_02.person.sex_cd
    = request->patient_data.person.guarantor_02.person.sex_cd
set pmdbdoc->patient_data.person.guarantor_02.person.name_last
    = request->patient_data.person.guarantor_02.person.name_last
set pmdbdoc->patient_data.person.guarantor_02.person.name_first
    = request->patient_data.person.guarantor_02.person.name_first
set pmdbdoc->patient_data.person.guarantor_02.person.vip_cd
    =  request->patient_data.person.guarantor_02.person.vip_cd
set pmdbdoc->patient_data.person.guarantor_02.person.name_middle
    = request->patient_data.person.guarantor_02.person.name_middle
;Guarantor home address
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.address_id
    = request->patient_data.person.guarantor_02.person.home_address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.street_addr
    = request->patient_data.person.guarantor_02.person.home_address.street_addr
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.street_addr2
    =  request->patient_data.person.guarantor_02.person.home_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.street_addr3
    = request->patient_data.person.guarantor_02.person.home_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.street_addr4
    = request->patient_data.person.guarantor_02.person.home_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.city
    = request->patient_data.person.guarantor_02.person.home_address.city
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.state
    = request->patient_data.person.guarantor_02.person.home_address.state
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.state_cd
    = request->patient_data.person.guarantor_02.person.home_address.state_cd
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.zipcode
    = request->patient_data.person.guarantor_02.person.home_address.zipcode
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.county
    = request->patient_data.person.guarantor_02.person.home_address.county
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.county_cd
    = request->patient_data.person.guarantor_02.person.home_address.county_cd
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.country
    = request->patient_data.person.guarantor_02.person.home_address.country
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.country_cd
    = request->patient_data.person.guarantor_02.person.home_address.country_cd
;guarantor bus address
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.address_id
    = request->patient_data.person.guarantor_02.person.bus_address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.street_addr
    =  request->patient_data.person.guarantor_02.person.bus_address.street_addr
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.street_addr2
    = request->patient_data.person.guarantor_02.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.street_addr3
    = request->patient_data.person.guarantor_02.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.street_addr4
    = request->patient_data.person.guarantor_02.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.city
    = request->patient_data.person.guarantor_02.person.bus_address.city
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.state
    = request->patient_data.person.guarantor_02.person.bus_address.state
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.state_cd
    = request->patient_data.person.guarantor_02.person.bus_address.state_cd
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.zipcode
    = request->patient_data.person.guarantor_02.person.bus_address.zipcode
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.county
    = request->patient_data.person.guarantor_02.person.bus_address.county
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.county_cd
    = request->patient_data.person.guarantor_02.person.bus_address.county_cd
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.country
    = request->patient_data.person.guarantor_02.person.bus_address.country
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.country_cd
    = request->patient_data.person.guarantor_02.person.bus_address.country_cd
;guarantor alt address
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.address_id
    = request->patient_data.person.guarantor_02.person.alt_address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.street_addr
    =  request->patient_data.person.guarantor_02.person.alt_address.street_addr
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.street_addr2
    = request->patient_data.person.guarantor_02.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.street_addr3
    = request->patient_data.person.guarantor_02.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.street_addr4
    = request->patient_data.person.guarantor_02.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.city
    = request->patient_data.person.guarantor_02.person.alt_address.city
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.state
    = request->patient_data.person.guarantor_02.person.alt_address.state
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.state_cd
    = request->patient_data.person.guarantor_02.person.alt_address.state_cd
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.zipcode
    = request->patient_data.person.guarantor_02.person.alt_address.zipcode
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.county
    = request->patient_data.person.guarantor_02.person.alt_address.county
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.county_cd
    = request->patient_data.person.guarantor_02.person.alt_address.county_cd
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.country
    = request->patient_data.person.guarantor_02.person.alt_address.country
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.country_cd
    = request->patient_data.person.guarantor_02.person.alt_address.country_cd
;guarantor email address
set pmdbdoc->patient_data.person.guarantor_02.person.email_address.address_id
    = request->patient_data.person.guarantor_02.person.email_address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.email_address.street_addr
    =  request->patient_data.person.guarantor_02.person.email_address.street_addr
;guarantor email address phone table
set pmdbdoc->patient_data->person->guarantor_02->person->home_email.phone_id
    = request->patient_data->person->guarantor_02->person->home_email.phone_id
set pmdbdoc->patient_data->person->guarantor_02->person->home_email.email
    = trim(request->patient_data->person->guarantor_02->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->guarantor_02->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->guarantor_02->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->guarantor_02->person->home_email.end_effective_dt_tm
    = request->patient_data->person->guarantor_02->person->home_email.end_effective_dt_tm
;guarantor temp address
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.address_id
    = request->patient_data.person.guarantor_02.person.temp_address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.street_addr
    =  request->patient_data.person.guarantor_02.person.temp_address.street_addr
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.street_addr2
    = request->patient_data.person.guarantor_02.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.street_addr3
    = request->patient_data.person.guarantor_02.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.street_addr4
    = request->patient_data.person.guarantor_02.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.city
    = request->patient_data.person.guarantor_02.person.temp_address.city
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.state
    = request->patient_data.person.guarantor_02.person.temp_address.state
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.state_cd
    = request->patient_data.person.guarantor_02.person.temp_address.state_cd
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.zipcode
    = request->patient_data.person.guarantor_02.person.temp_address.zipcode
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.county
    = request->patient_data.person.guarantor_02.person.temp_address.county
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.county_cd
    = request->patient_data.person.guarantor_02.person.temp_address.county_cd
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.country
    = request->patient_data.person.guarantor_02.person.temp_address.country
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.country_cd
    = request->patient_data.person.guarantor_02.person.temp_address.country_cd
;guarantor mail address
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.address_id
    = request->patient_data.person.guarantor_02.person.mail_address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.street_addr
    =  request->patient_data.person.guarantor_02.person.mail_address.street_addr
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.street_addr2
    = request->patient_data.person.guarantor_02.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.street_addr3
    = request->patient_data.person.guarantor_02.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.street_addr4
    = request->patient_data.person.guarantor_02.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.city
    = request->patient_data.person.guarantor_02.person.mail_address.city
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.state
    = request->patient_data.person.guarantor_02.person.mail_address.state
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.state_cd
    = request->patient_data.person.guarantor_02.person.mail_address.state_cd
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.zipcode
    = request->patient_data.person.guarantor_02.person.mail_address.zipcode
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.county
    = request->patient_data.person.guarantor_02.person.mail_address.county
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.county_cd
    = request->patient_data.person.guarantor_02.person.mail_address.county_cd
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.country
    = request->patient_data.person.guarantor_02.person.mail_address.country
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.country_cd
    = request->patient_data.person.guarantor_02.person.mail_address.country_cd
;guarantor mobile phone
set pmdbdoc->patient_data.person.guarantor_02.person.mobile_phone.phone_id
    = request->patient_data.person.guarantor_02.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.mobile_phone.phone_format_cd
    = request->patient_data.person.guarantor_02.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.mobile_phone.phone_num
    = request->patient_data.person.guarantor_02.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_02.person.mobile_phone.extension
    = request->patient_data.person.guarantor_02.person.mobile_phone.extension
;guarantor home phone
set pmdbdoc->patient_data.person.guarantor_02.person.home_phone.phone_id
    = request->patient_data.person.guarantor_02.person.home_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.home_phone.phone_format_cd
    = request->patient_data.person.guarantor_02.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.home_phone.phone_num
    = request->patient_data.person.guarantor_02.person.home_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_02.person.home_phone.extension
    = request->patient_data.person.guarantor_02.person.home_phone.extension
;guarantor pager phone
set pmdbdoc->patient_data.person.guarantor_02.person.home_pager.phone_id
    = request->patient_data.person.guarantor_02.person.home_pager.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.home_pager.phone_format_cd
    = request->patient_data.person.guarantor_02.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.home_pager.phone_num
    = request->patient_data.person.guarantor_02.person.home_pager.phone_num
set pmdbdoc->patient_data.person.guarantor_02.person.home_pager.extension
    = request->patient_data.person.guarantor_02.person.home_pager.extension
;guarantor bus phone
set pmdbdoc->patient_data.person.guarantor_02.person.bus_phone.phone_id
    = request->patient_data.person.guarantor_02.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.bus_phone.phone_format_cd
    = request->patient_data.person.guarantor_02.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.bus_phone.phone_num
    = request->patient_data.person.guarantor_02.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_02.person.bus_phone.extension
    = request->patient_data.person.guarantor_02.person.bus_phone.extension
;guarantor alt phone
set pmdbdoc->patient_data.person.guarantor_02.person.alt_phone.phone_id
    = request->patient_data.person.guarantor_02.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.alt_phone.phone_format_cd
    = request->patient_data.person.guarantor_02.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.alt_phone.phone_num
    = request->patient_data.person.guarantor_02.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_02.person.alt_phone.extension
    = request->patient_data.person.guarantor_02.person.alt_phone.extension
;guarantor temp phone
set pmdbdoc->patient_data.person.guarantor_02.person.temp_phone.phone_id
    = request->patient_data.person.guarantor_02.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.temp_phone.phone_format_cd
    = request->patient_data.person.guarantor_02.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.temp_phone.phone_num
    = request->patient_data.person.guarantor_02.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.guarantor_02.person.temp_phone.extension
    = request->patient_data.person.guarantor_02.person.temp_phone.extension
;guarantor identifiers
set pmdbdoc->patient_data.person.guarantor_02.person.mrn.person_alias_id
    = request->patient_data.person.guarantor_02.person.mrn.person_alias_id
set pmdbdoc->patient_data.person.guarantor_02.person.mrn.alias_pool_cd
    = request->patient_data.person.guarantor_02.person.mrn.alias_pool_cd
set pmdbdoc->patient_data.person.guarantor_02.person.mrn.person_alias_type_cd
    = request->patient_data.person.guarantor_02.person.mrn.person_alias_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.mrn.alias
    = request->patient_data.person.guarantor_02.person.mrn.alias
set pmdbdoc->patient_data.person.guarantor_02.person.mrn.person_alias_sub_type_cd
    = request->patient_data.person.guarantor_02.person.mrn.person_alias_sub_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.ssn.person_alias_id
    = request->patient_data.person.guarantor_02.person.ssn.person_alias_id
set pmdbdoc->patient_data.person.guarantor_02.person.ssn.alias_pool_cd
    = request->patient_data.person.guarantor_02.person.ssn.alias_pool_cd
set pmdbdoc->patient_data.person.guarantor_02.person.ssn.person_alias_type_cd
    = request->patient_data.person.guarantor_02.person.ssn.person_alias_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.ssn.alias
    = request->patient_data.person.guarantor_02.person.ssn.alias
set pmdbdoc->patient_data.person.guarantor_02.person.ssn.person_alias_sub_type_cd
    = request->patient_data.person.guarantor_02.person.ssn.person_alias_sub_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.cmrn.person_alias_id
    = request->patient_data.person.guarantor_02.person.cmrn.person_alias_id
set pmdbdoc->patient_data.person.guarantor_02.person.cmrn.alias_pool_cd
    = request->patient_data.person.guarantor_02.person.cmrn.alias_pool_cd
set pmdbdoc->patient_data.person.guarantor_02.person.cmrn.person_alias_type_cd
    = request->patient_data.person.guarantor_02.person.cmrn.person_alias_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.cmrn.person_alias_sub_type_cd
    = request->patient_data.person.guarantor_02.person.cmrn.person_alias_sub_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.cmrn.alias
    = request->patient_data.person.guarantor_02.person.cmrn.alias
;guarantor employer
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.person_org_reltn_id
    = request->patient_data.person.guarantor_02.person.employer_01.person_org_reltn_id
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.person_org_reltn_cd
    = request->patient_data.person.guarantor_02.person.employer_01.person_org_reltn_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.organization_id
    = request->patient_data.person.guarantor_02.person.employer_01.organization_id
set  pmdbdoc->patient_data.person.guarantor_02.person.employer_01.empl_retire_dt_tm
    = request->patient_data.person.guarantor_02.person.employer_01.empl_retire_dt_tm
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.empl_type_cd
    = request->patient_data.person.guarantor_02.person.employer_01.empl_type_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.empl_status_cd
    = request->patient_data.person.guarantor_02.person.employer_01.empl_status_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.empl_occupation_text
    = request->patient_data.person.guarantor_02.person.employer_01.empl_occupation_text
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.empl_occupation_cd
    = request->patient_data.person.guarantor_02.person.employer_01.empl_occupation_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.address_id
    = request->patient_data.person.guarantor_02.person.employer_01.address.address_id
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.street_addr
    = request->patient_data.person.guarantor_02.person.employer_01.address.street_addr
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.street_addr2
    = request->patient_data.person.guarantor_02.person.employer_01.address.street_addr2
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.street_addr3
    = request->patient_data.person.guarantor_02.person.employer_01.address.street_addr3
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.street_addr4
    = request->patient_data.person.guarantor_02.person.employer_01.address.street_addr4
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.city
    = request->patient_data.person.guarantor_02.person.employer_01.address.city
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.state
    = request->patient_data.person.guarantor_02.person.employer_01.address.state
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.state_cd
    = request->patient_data.person.guarantor_02.person.employer_01.address.state_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.zipcode
    = request->patient_data.person.guarantor_02.person.employer_01.address.zipcode
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.county
    = request->patient_data.person.guarantor_02.person.employer_01.address.county
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.county_cd
    = request->patient_data.person.guarantor_02.person.employer_01.address.county_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.country
    = request->patient_data.person.guarantor_02.person.employer_01.address.country
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.country_cd
    = request->patient_data.person.guarantor_02.person.employer_01.address.country_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.phone.phone_id
    = request->patient_data.person.guarantor_02.person.employer_01.phone.phone_id
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.phone.phone_format_cd
    = request->patient_data.person.guarantor_02.person.employer_01.phone.phone_format_cd
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.phone.phone_num
    = request->patient_data.person.guarantor_02.person.employer_01.phone.phone_num
 
;guarantor organization
set pmdbdoc->patient_data.person.guarantor_02.organization.organization_id
    = request->patient_data.person.guarantor_02.guarantor_org.organization_id
set pmdbdoc->patient_data.person.guarantor_02.organization.person_org_nbr
    = request->patient_data.person.guarantor_02.guarantor_org.person_org_nbr
set pmdbdoc->patient_data.person.guarantor_02.organization.person_org_alias
    = request->patient_data.person.guarantor_02.guarantor_org.person_org_alias
set pmdbdoc->patient_data.person.guarantor_02.organization.free_text_ind
    = request->patient_data.person.guarantor_02.guarantor_org.free_text_ind
set pmdbdoc->patient_data.person.guarantor_02.organization.data_status_cd
    = request->patient_data.person.guarantor_02.guarantor_org.data_status_cd
    
call DebugPrint("..... mapping NOK")
/*nok*/
set pmdbdoc->patient_data.person.nok.person_person_reltn_id = request->patient_data.person.nok.person_person_reltn_id
set pmdbdoc->patient_data.person.nok.encntr_person_reltn_id = request->patient_data.person.nok.encntr_person_reltn_id
set pmdbdoc->patient_data.person.nok.person_reltn_type_cd = request->patient_data.person.nok.person_reltn_type_cd
set pmdbdoc->patient_data.person.nok.person_id = request->patient_data.person.nok.person_id
set pmdbdoc->patient_data.person.nok.encntr_id = request->patient_data.person.nok.encntr_id
set pmdbdoc->patient_data.person.nok.person_reltn_cd = request->patient_data.person.nok.person_reltn_cd
set pmdbdoc->patient_data.person.nok.related_person_reltn_cd = request->patient_data.person.nok.related_person_reltn_cd
set pmdbdoc->patient_data.person.nok.related_person_id = request->patient_data.person.nok.related_person_id
set pmdbdoc->patient_data.person.nok.person.person_id = request->patient_data.person.nok.person.person_id
set pmdbdoc->patient_data.person.nok.person.name_full_formatted =
request->patient_data.person.nok.person.name_full_formatted
set pmdbdoc->patient_data.person.nok.person.birth_dt_tm = request->patient_data.person.nok.person.birth_dt_tm
set pmdbdoc->patient_data.person.nok.person.birth_tz = request->patient_data.person.nok.person.birth_tz
set pmdbdoc->patient_data.person.nok.person.birth_prec_flag = request->patient_data.person.nok.person.birth_prec_flag
set pmdbdoc->patient_data.person.nok.person.sex_cd = request->patient_data.person.nok.person.sex_cd
set pmdbdoc->patient_data.person.nok.person.name_last = request->patient_data.person.nok.person.name_last
set pmdbdoc->patient_data.person.nok.person.name_first = request->patient_data.person.nok.person.name_first
set pmdbdoc->patient_data.person.nok.person.name_middle = request->patient_data.person.nok.person.name_middle
;nok home address
set pmdbdoc->patient_data.person.nok.person.home_address.address_id
    = request->patient_data.person.nok.person.home_address.address_id
set pmdbdoc->patient_data.person.nok.person.home_address.street_addr
    = request->patient_data.person.nok.person.home_address.street_addr
set pmdbdoc->patient_data.person.nok.person.home_address.street_addr2
    = request->patient_data.person.nok.person.home_address.street_addr2
set pmdbdoc->patient_data.person.nok.person.home_address.street_addr3
    = request->patient_data.person.nok.person.home_address.street_addr3
set pmdbdoc->patient_data.person.nok.person.home_address.street_addr4
    = request->patient_data.person.nok.person.home_address.street_addr4
set pmdbdoc->patient_data.person.nok.person.home_address.city
    = request->patient_data.person.nok.person.home_address.city
set pmdbdoc->patient_data.person.nok.person.home_address.state
    = request->patient_data.person.nok.person.home_address.state
set pmdbdoc->patient_data.person.nok.person.home_address.state_cd
    = request->patient_data.person.nok.person.home_address.state_cd
set pmdbdoc->patient_data.person.nok.person.home_address.zipcode
    = request->patient_data.person.nok.person.home_address.zipcode
set pmdbdoc->patient_data.person.nok.person.home_address.county
    = request->patient_data.person.nok.person.home_address.county
set pmdbdoc->patient_data.person.nok.person.home_address.county_cd
    = request->patient_data.person.nok.person.home_address.county_cd
set pmdbdoc->patient_data.person.nok.person.home_address.country
    = request->patient_data.person.nok.person.home_address.country
set pmdbdoc->patient_data.person.nok.person.home_address.country_cd
    = request->patient_data.person.nok.person.home_address.country_cd
;nok bus address
set pmdbdoc->patient_data.person.nok.person.bus_address.address_id
    = request->patient_data.person.nok.person.bus_address.address_id
set pmdbdoc->patient_data.person.nok.person.bus_address.street_addr
    = request->patient_data.person.nok.person.bus_address.street_addr
set pmdbdoc->patient_data.person.nok.person.bus_address.street_addr2
    = request->patient_data.person.nok.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.nok.person.bus_address.street_addr3
    = request->patient_data.person.nok.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.nok.person.bus_address.street_addr4
    = request->patient_data.person.nok.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.nok.person.bus_address.city
    = request->patient_data.person.nok.person.bus_address.city
set pmdbdoc->patient_data.person.nok.person.bus_address.state
    = request->patient_data.person.nok.person.bus_address.state
set pmdbdoc->patient_data.person.nok.person.bus_address.state_cd
    = request->patient_data.person.nok.person.bus_address.state_cd
set pmdbdoc->patient_data.person.nok.person.bus_address.zipcode
    = request->patient_data.person.nok.person.bus_address.zipcode
set pmdbdoc->patient_data.person.nok.person.bus_address.county
    = request->patient_data.person.nok.person.bus_address.county
set pmdbdoc->patient_data.person.nok.person.bus_address.county_cd
    = request->patient_data.person.nok.person.bus_address.county_cd
set pmdbdoc->patient_data.person.nok.person.bus_address.country
    = request->patient_data.person.nok.person.bus_address.country
set pmdbdoc->patient_data.person.nok.person.bus_address.country_cd
    = request->patient_data.person.nok.person.bus_address.country_cd
;nok alt address
set pmdbdoc->patient_data.person.nok.person.alt_address.address_id
    = request->patient_data.person.nok.person.alt_address.address_id
set pmdbdoc->patient_data.person.nok.person.alt_address.street_addr
    = request->patient_data.person.nok.person.alt_address.street_addr
set pmdbdoc->patient_data.person.nok.person.alt_address.street_addr2
    = request->patient_data.person.nok.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.nok.person.alt_address.street_addr3
    = request->patient_data.person.nok.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.nok.person.alt_address.street_addr4
    = request->patient_data.person.nok.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.nok.person.alt_address.city
    = request->patient_data.person.nok.person.alt_address.city
set pmdbdoc->patient_data.person.nok.person.alt_address.state
    = request->patient_data.person.nok.person.alt_address.state
set pmdbdoc->patient_data.person.nok.person.alt_address.state_cd
    = request->patient_data.person.nok.person.alt_address.state_cd
set pmdbdoc->patient_data.person.nok.person.alt_address.zipcode
    = request->patient_data.person.nok.person.alt_address.zipcode
set pmdbdoc->patient_data.person.nok.person.alt_address.county
    = request->patient_data.person.nok.person.alt_address.county
set pmdbdoc->patient_data.person.nok.person.alt_address.county_cd
    = request->patient_data.person.nok.person.alt_address.county_cd
set pmdbdoc->patient_data.person.nok.person.alt_address.country
    = request->patient_data.person.nok.person.alt_address.country
set pmdbdoc->patient_data.person.nok.person.alt_address.country_cd
    = request->patient_data.person.nok.person.alt_address.country_cd
;nok email address
set pmdbdoc->patient_data.person.nok.person.email_address.address_id
    = request->patient_data.person.nok.person.email_address.address_id
set pmdbdoc->patient_data.person.nok.person.email_address.street_addr
    = request->patient_data.person.nok.person.email_address.street_addr
;nok email address phone table
set pmdbdoc->patient_data->person->nok->person->home_email.phone_id
    = request->patient_data->person->nok->person->home_email.phone_id
set pmdbdoc->patient_data->person->nok->person->home_email.email
    = trim(request->patient_data->person->nok->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->nok->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->nok->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->nok->person->home_email.end_effective_dt_tm
    = request->patient_data->person->nok->person->home_email.end_effective_dt_tm
;nok temp address
set pmdbdoc->patient_data.person.nok.person.temp_address.address_id
    = request->patient_data.person.nok.person.temp_address.address_id
set pmdbdoc->patient_data.person.nok.person.temp_address.street_addr
    = request->patient_data.person.nok.person.temp_address.street_addr
set pmdbdoc->patient_data.person.nok.person.temp_address.street_addr2
    = request->patient_data.person.nok.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.nok.person.temp_address.street_addr3
    = request->patient_data.person.nok.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.nok.person.temp_address.street_addr4
    = request->patient_data.person.nok.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.nok.person.temp_address.city
    = request->patient_data.person.nok.person.temp_address.city
set pmdbdoc->patient_data.person.nok.person.temp_address.state
    = request->patient_data.person.nok.person.temp_address.state
set pmdbdoc->patient_data.person.nok.person.temp_address.state_cd
    = request->patient_data.person.nok.person.temp_address.state_cd
set pmdbdoc->patient_data.person.nok.person.temp_address.zipcode
    = request->patient_data.person.nok.person.temp_address.zipcode
set pmdbdoc->patient_data.person.nok.person.temp_address.county
    = request->patient_data.person.nok.person.temp_address.county
set pmdbdoc->patient_data.person.nok.person.temp_address.county_cd
    = request->patient_data.person.nok.person.temp_address.county_cd
set pmdbdoc->patient_data.person.nok.person.temp_address.country
    = request->patient_data.person.nok.person.temp_address.country
set pmdbdoc->patient_data.person.nok.person.temp_address.country_cd
    = request->patient_data.person.nok.person.temp_address.country_cd
;nok mail address
set pmdbdoc->patient_data.person.nok.person.mail_address.address_id
    = request->patient_data.person.nok.person.mail_address.address_id
set pmdbdoc->patient_data.person.nok.person.mail_address.street_addr
    = request->patient_data.person.nok.person.mail_address.street_addr
set pmdbdoc->patient_data.person.nok.person.mail_address.street_addr2
    = request->patient_data.person.nok.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.nok.person.mail_address.street_addr3
    = request->patient_data.person.nok.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.nok.person.mail_address.street_addr4
    = request->patient_data.person.nok.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.nok.person.mail_address.city
    = request->patient_data.person.nok.person.mail_address.city
set pmdbdoc->patient_data.person.nok.person.mail_address.state
    = request->patient_data.person.nok.person.mail_address.state
set pmdbdoc->patient_data.person.nok.person.mail_address.state_cd
    = request->patient_data.person.nok.person.mail_address.state_cd
set pmdbdoc->patient_data.person.nok.person.mail_address.zipcode
    = request->patient_data.person.nok.person.mail_address.zipcode
set pmdbdoc->patient_data.person.nok.person.mail_address.county
    = request->patient_data.person.nok.person.mail_address.county
set pmdbdoc->patient_data.person.nok.person.mail_address.county_cd
    = request->patient_data.person.nok.person.mail_address.county_cd
set pmdbdoc->patient_data.person.nok.person.mail_address.country
    = request->patient_data.person.nok.person.mail_address.country
set pmdbdoc->patient_data.person.nok.person.mail_address.country_cd
    = request->patient_data.person.nok.person.mail_address.country_cd
   
;nok mobile phone
set pmdbdoc->patient_data.person.nok.person.mobile_phone.phone_id
    = request->patient_data.person.nok.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.nok.person.mobile_phone.phone_format_cd
    = request->patient_data.person.nok.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.nok.person.mobile_phone.phone_num
    = request->patient_data.person.nok.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.nok.person.mobile_phone.extension
    = request->patient_data.person.nok.person.mobile_phone.extension
 
;nok home phone
set pmdbdoc->patient_data.person.nok.person.home_phone.phone_id
    = request->patient_data.person.nok.person.home_phone.phone_id
set pmdbdoc->patient_data.person.nok.person.home_phone.phone_format_cd
    = request->patient_data.person.nok.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.nok.person.home_phone.phone_num
    = request->patient_data.person.nok.person.home_phone.phone_num
set pmdbdoc->patient_data.person.nok.person.home_phone.extension
    = request->patient_data.person.nok.person.home_phone.extension
 
;nok home pager
set pmdbdoc->patient_data.person.nok.person.home_pager.phone_id
   = request->patient_data.person.nok.person.home_pager.phone_id
set pmdbdoc->patient_data.person.nok.person.home_pager.phone_format_cd
   = request->patient_data.person.nok.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.nok.person.home_pager.phone_num
   = request->patient_data.person.nok.person.home_pager.phone_num
set pmdbdoc->patient_data.person.nok.person.home_pager.extension
   = request->patient_data.person.nok.person.home_pager.extension
 
;nok bus phone
set pmdbdoc->patient_data.person.nok.person.bus_phone.phone_id
   = request->patient_data.person.nok.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.nok.person.bus_phone.phone_format_cd
   = request->patient_data.person.nok.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.nok.person.bus_phone.phone_num
   = request->patient_data.person.nok.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.nok.person.bus_phone.extension
        = request->patient_data.person.nok.person.bus_phone.extension
 
;nok alt phone
set pmdbdoc->patient_data.person.nok.person.alt_phone.phone_id
   = request->patient_data.person.nok.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.nok.person.alt_phone.phone_format_cd
   = request->patient_data.person.nok.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.nok.person.alt_phone.phone_num
   = request->patient_data.person.nok.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.nok.person.alt_phone.extension
   = request->patient_data.person.nok.person.alt_phone.extension
 
;nok temp phone
set pmdbdoc->patient_data.person.nok.person.temp_phone.phone_id
   = request->patient_data.person.nok.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.nok.person.temp_phone.phone_format_cd
   = request->patient_data.person.nok.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.nok.person.temp_phone.phone_num
   = request->patient_data.person.nok.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.nok.person.temp_phone.extension
   = request->patient_data.person.nok.person.temp_phone.extension
 
call DebugPrint("..... mapping EMC")
/*emc*/
set pmdbdoc->patient_data.person.emc.person_person_reltn_id
    = request->patient_data.person.emc.person_person_reltn_id
set pmdbdoc->patient_data.person.emc.encntr_person_reltn_id
    = request->patient_data.person.emc.encntr_person_reltn_id
set pmdbdoc->patient_data.person.emc.person_reltn_type_cd
    = request->patient_data.person.emc.person_reltn_type_cd
set pmdbdoc->patient_data.person.emc.person_id
    = request->patient_data.person.emc.person_id
set pmdbdoc->patient_data.person.emc.encntr_id
    = request->patient_data.person.emc.encntr_id
set pmdbdoc->patient_data.person.emc.person_reltn_cd
    = request->patient_data.person.emc.person_reltn_cd
set pmdbdoc->patient_data.person.emc.related_person_reltn_cd
    = request->patient_data.person.emc.related_person_reltn_cd
set pmdbdoc->patient_data.person.emc.related_person_id
    = request->patient_data.person.emc.related_person_id
set pmdbdoc->patient_data.person.emc.person.person_id
    = request->patient_data.person.emc.person.person_id
set pmdbdoc->patient_data.person.emc.person.name_full_formatted
    = request->patient_data.person.emc.person.name_full_formatted
set pmdbdoc->patient_data.person.emc.person.birth_dt_tm
    = request->patient_data.person.emc.person.birth_dt_tm
set pmdbdoc->patient_data.person.emc.person.birth_tz
    = request->patient_data.person.emc.person.birth_tz
set pmdbdoc->patient_data.person.emc.person.birth_prec_flag
    = request->patient_data.person.emc.person.birth_prec_flag
set pmdbdoc->patient_data.person.emc.person.sex_cd
    = request->patient_data.person.emc.person.sex_cd
set pmdbdoc->patient_data.person.emc.person.name_last
    = request->patient_data.person.emc.person.name_last
set pmdbdoc->patient_data.person.emc.person.name_first
    = request->patient_data.person.emc.person.name_first
set pmdbdoc->patient_data.person.emc.person.name_middle
    = request->patient_data.person.emc.person.name_middle
;emc home address
set pmdbdoc->patient_data.person.emc.person.home_address.address_id
    = request->patient_data.person.emc.person.home_address.address_id
set pmdbdoc->patient_data.person.emc.person.home_address.street_addr
    = request->patient_data.person.emc.person.home_address.street_addr
set pmdbdoc->patient_data.person.emc.person.home_address.street_addr2
    = request->patient_data.person.emc.person.home_address.street_addr2
set pmdbdoc->patient_data.person.emc.person.home_address.street_addr3
    = request->patient_data.person.emc.person.home_address.street_addr3
set pmdbdoc->patient_data.person.emc.person.home_address.street_addr4
    = request->patient_data.person.emc.person.home_address.street_addr4
set pmdbdoc->patient_data.person.emc.person.home_address.city
    = request->patient_data.person.emc.person.home_address.city
set pmdbdoc->patient_data.person.emc.person.home_address.state
    = request->patient_data.person.emc.person.home_address.state
set pmdbdoc->patient_data.person.emc.person.home_address.state_cd
    = request->patient_data.person.emc.person.home_address.state_cd
set pmdbdoc->patient_data.person.emc.person.home_address.zipcode
    = request->patient_data.person.emc.person.home_address.zipcode
set pmdbdoc->patient_data.person.emc.person.home_address.county
    = request->patient_data.person.emc.person.home_address.county
set pmdbdoc->patient_data.person.emc.person.home_address.county_cd
    = request->patient_data.person.emc.person.home_address.county_cd
set pmdbdoc->patient_data.person.emc.person.home_address.country
    = request->patient_data.person.emc.person.home_address.country
set pmdbdoc->patient_data.person.emc.person.home_address.country_cd
    = request->patient_data.person.emc.person.home_address.country_cd
;emc bus address
set pmdbdoc->patient_data.person.emc.person.bus_address.address_id
    = request->patient_data.person.emc.person.bus_address.address_id
set pmdbdoc->patient_data.person.emc.person.bus_address.street_addr
    = request->patient_data.person.emc.person.bus_address.street_addr
set pmdbdoc->patient_data.person.emc.person.bus_address.street_addr2
    = request->patient_data.person.emc.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.emc.person.bus_address.street_addr3
    = request->patient_data.person.emc.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.emc.person.bus_address.street_addr4
    = request->patient_data.person.emc.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.emc.person.bus_address.city
    = request->patient_data.person.emc.person.bus_address.city
set pmdbdoc->patient_data.person.emc.person.bus_address.state
    = request->patient_data.person.emc.person.bus_address.state
set pmdbdoc->patient_data.person.emc.person.bus_address.state_cd
    = request->patient_data.person.emc.person.bus_address.state_cd
set pmdbdoc->patient_data.person.emc.person.bus_address.zipcode
    = request->patient_data.person.emc.person.bus_address.zipcode
set pmdbdoc->patient_data.person.emc.person.bus_address.county
    = request->patient_data.person.emc.person.bus_address.county
set pmdbdoc->patient_data.person.emc.person.bus_address.county_cd
    = request->patient_data.person.emc.person.bus_address.county_cd
set pmdbdoc->patient_data.person.emc.person.bus_address.country
    = request->patient_data.person.emc.person.bus_address.country
set pmdbdoc->patient_data.person.emc.person.bus_address.country_cd
    = request->patient_data.person.emc.person.bus_address.country_cd
;emc alt address
set pmdbdoc->patient_data.person.emc.person.alt_address.address_id
    = request->patient_data.person.emc.person.alt_address.address_id
set pmdbdoc->patient_data.person.emc.person.alt_address.street_addr
    = request->patient_data.person.emc.person.alt_address.street_addr
set pmdbdoc->patient_data.person.emc.person.alt_address.street_addr2
    = request->patient_data.person.emc.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.emc.person.alt_address.street_addr3
    = request->patient_data.person.emc.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.emc.person.alt_address.street_addr4
    = request->patient_data.person.emc.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.emc.person.alt_address.city
    = request->patient_data.person.emc.person.alt_address.city
set pmdbdoc->patient_data.person.emc.person.alt_address.state
    = request->patient_data.person.emc.person.alt_address.state
set pmdbdoc->patient_data.person.emc.person.alt_address.state_cd
    = request->patient_data.person.emc.person.alt_address.state_cd
set pmdbdoc->patient_data.person.emc.person.alt_address.zipcode
    = request->patient_data.person.emc.person.alt_address.zipcode
set pmdbdoc->patient_data.person.emc.person.alt_address.county
    = request->patient_data.person.emc.person.alt_address.county
set pmdbdoc->patient_data.person.emc.person.alt_address.county_cd
    = request->patient_data.person.emc.person.alt_address.county_cd
set pmdbdoc->patient_data.person.emc.person.alt_address.country
    = request->patient_data.person.emc.person.alt_address.country
set pmdbdoc->patient_data.person.emc.person.alt_address.country_cd
    = request->patient_data.person.emc.person.alt_address.country_cd
;emc email address
set pmdbdoc->patient_data.person.emc.person.email_address.address_id
    = request->patient_data.person.emc.person.email_address.address_id
set pmdbdoc->patient_data.person.emc.person.email_address.street_addr
    = request->patient_data.person.emc.person.email_address.street_addr
;emc email address phone table
set pmdbdoc->patient_data->person->emc->person->home_email.phone_id
    = request->patient_data->person->emc->person->home_email.phone_id
set pmdbdoc->patient_data->person->emc->person->home_email.email
    = trim(request->patient_data->person->emc->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->emc->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->emc->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->emc->person->home_email.end_effective_dt_tm
    = request->patient_data->person->emc->person->home_email.end_effective_dt_tm
;emc temp address
set pmdbdoc->patient_data.person.emc.person.temp_address.address_id
    = request->patient_data.person.emc.person.temp_address.address_id
set pmdbdoc->patient_data.person.emc.person.temp_address.street_addr
    = request->patient_data.person.emc.person.temp_address.street_addr
set pmdbdoc->patient_data.person.emc.person.temp_address.street_addr2
    = request->patient_data.person.emc.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.emc.person.temp_address.street_addr3
    = request->patient_data.person.emc.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.emc.person.temp_address.street_addr4
    = request->patient_data.person.emc.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.emc.person.temp_address.city
    = request->patient_data.person.emc.person.temp_address.city
set pmdbdoc->patient_data.person.emc.person.temp_address.state
    = request->patient_data.person.emc.person.temp_address.state
set pmdbdoc->patient_data.person.emc.person.temp_address.state_cd
    = request->patient_data.person.emc.person.temp_address.state_cd
set pmdbdoc->patient_data.person.emc.person.temp_address.zipcode
    = request->patient_data.person.emc.person.temp_address.zipcode
set pmdbdoc->patient_data.person.emc.person.temp_address.county
    = request->patient_data.person.emc.person.temp_address.county
set pmdbdoc->patient_data.person.emc.person.temp_address.county_cd
    = request->patient_data.person.emc.person.temp_address.county_cd
set pmdbdoc->patient_data.person.emc.person.temp_address.country
    = request->patient_data.person.emc.person.temp_address.country
set pmdbdoc->patient_data.person.emc.person.temp_address.country_cd
    = request->patient_data.person.emc.person.temp_address.country_cd
;emc mail address
set pmdbdoc->patient_data.person.emc.person.mail_address.address_id
    = request->patient_data.person.emc.person.mail_address.address_id
set pmdbdoc->patient_data.person.emc.person.mail_address.street_addr
    = request->patient_data.person.emc.person.mail_address.street_addr
set pmdbdoc->patient_data.person.emc.person.mail_address.street_addr2
    = request->patient_data.person.emc.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.emc.person.mail_address.street_addr3
    = request->patient_data.person.emc.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.emc.person.mail_address.street_addr4
    = request->patient_data.person.emc.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.emc.person.mail_address.city
    = request->patient_data.person.emc.person.mail_address.city
set pmdbdoc->patient_data.person.emc.person.mail_address.state
    = request->patient_data.person.emc.person.mail_address.state
set pmdbdoc->patient_data.person.emc.person.mail_address.state_cd
    = request->patient_data.person.emc.person.mail_address.state_cd
set pmdbdoc->patient_data.person.emc.person.mail_address.zipcode
    = request->patient_data.person.emc.person.mail_address.zipcode
set pmdbdoc->patient_data.person.emc.person.mail_address.county
    = request->patient_data.person.emc.person.mail_address.county
set pmdbdoc->patient_data.person.emc.person.mail_address.county_cd
    = request->patient_data.person.emc.person.mail_address.county_cd
set pmdbdoc->patient_data.person.emc.person.mail_address.country
    = request->patient_data.person.emc.person.mail_address.country
set pmdbdoc->patient_data.person.emc.person.mail_address.country_cd
    = request->patient_data.person.emc.person.mail_address.country_cd
;emc mobile phone
set pmdbdoc->patient_data.person.emc.person.mobile_phone.phone_id
    = request->patient_data.person.emc.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.emc.person.mobile_phone.phone_format_cd
    = request->patient_data.person.emc.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.emc.person.mobile_phone.phone_num
    = request->patient_data.person.emc.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.emc.person.mobile_phone.extension
    = request->patient_data.person.emc.person.mobile_phone.extension
 
;emc home phone
set pmdbdoc->patient_data.person.emc.person.home_phone.phone_id
    = request->patient_data.person.emc.person.home_phone.phone_id
set pmdbdoc->patient_data.person.emc.person.home_phone.phone_format_cd
    = request->patient_data.person.emc.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.emc.person.home_phone.phone_num
    = request->patient_data.person.emc.person.home_phone.phone_num
set pmdbdoc->patient_data.person.emc.person.home_phone.extension
    = request->patient_data.person.emc.person.home_phone.extension
 
;emc home pager
set pmdbdoc->patient_data.person.emc.person.home_pager.phone_id
   = request->patient_data.person.emc.person.home_pager.phone_id
set pmdbdoc->patient_data.person.emc.person.home_pager.phone_format_cd
   = request->patient_data.person.emc.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.emc.person.home_pager.phone_num
   = request->patient_data.person.emc.person.home_pager.phone_num
set pmdbdoc->patient_data.person.emc.person.home_pager.extension
   = request->patient_data.person.emc.person.home_pager.extension
 
;emc bus phone
set pmdbdoc->patient_data.person.emc.person.bus_phone.phone_id
   = request->patient_data.person.emc.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.emc.person.bus_phone.phone_format_cd
   = request->patient_data.person.emc.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.emc.person.bus_phone.phone_num
   = request->patient_data.person.emc.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.emc.person.bus_phone.extension
        = request->patient_data.person.emc.person.bus_phone.extension
        
;emc alt phone
set pmdbdoc->patient_data.person.emc.person.alt_phone.phone_id
   = request->patient_data.person.emc.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.emc.person.alt_phone.phone_format_cd
   = request->patient_data.person.emc.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.emc.person.alt_phone.phone_num
   = request->patient_data.person.emc.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.emc.person.alt_phone.extension
   = request->patient_data.person.emc.person.alt_phone.extension
 
;emc temp phone
set pmdbdoc->patient_data.person.emc.person.temp_phone.phone_id
   = request->patient_data.person.emc.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.emc.person.temp_phone.phone_format_cd
   = request->patient_data.person.emc.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.emc.person.temp_phone.phone_num
   = request->patient_data.person.emc.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.emc.person.temp_phone.extension
   = request->patient_data.person.emc.person.temp_phone.extension
 
call DebugPrint("..... mapping Relation 01")
/*relation 01*/
set pmdbdoc->patient_data.person.relation_01.person_person_reltn_id
    = request->patient_data.person.relation_01.person_person_reltn_id
set pmdbdoc->patient_data.person.relation_01.encntr_person_reltn_id
    = request->patient_data.person.relation_01.encntr_person_reltn_id
set pmdbdoc->patient_data.person.relation_01.person_reltn_type_cd
    = request->patient_data.person.relation_01.person_reltn_type_cd
set pmdbdoc->patient_data.person.relation_01.person_id
    = request->patient_data.person.relation_01.person_id
set pmdbdoc->patient_data.person.relation_01.encntr_id
    = request->patient_data.person.relation_01.encntr_id
set pmdbdoc->patient_data.person.relation_01.person_reltn_cd
    = request->patient_data.person.relation_01.person_reltn_cd
set pmdbdoc->patient_data.person.relation_01.related_person_reltn_cd
    = request->patient_data.person.relation_01.related_person_reltn_cd
set pmdbdoc->patient_data.person.relation_01.related_person_id
    = request->patient_data.person.relation_01.related_person_id
set pmdbdoc->patient_data.person.relation_01.person.person_id
    = request->patient_data.person.relation_01.person.person_id
set pmdbdoc->patient_data.person.relation_01.person.name_full_formatted
    = request->patient_data.person.relation_01.person.name_full_formatted
set pmdbdoc->patient_data.person.relation_01.person.birth_dt_tm
    = request->patient_data.person.relation_01.person.birth_dt_tm
set pmdbdoc->patient_data.person.relation_01.person.birth_tz
    = request->patient_data.person.relation_01.person.birth_tz
set pmdbdoc->patient_data.person.relation_01.person.birth_prec_flag
    = request->patient_data.person.relation_01.person.birth_prec_flag
set pmdbdoc->patient_data.person.relation_01.person.sex_cd
    = request->patient_data.person.relation_01.person.sex_cd
set pmdbdoc->patient_data.person.relation_01.person.name_last
    = request->patient_data.person.relation_01.person.name_last
set pmdbdoc->patient_data.person.relation_01.person.name_first
    = request->patient_data.person.relation_01.person.name_first
set pmdbdoc->patient_data.person.relation_01.person.name_middle
    = request->patient_data.person.relation_01.person.name_middle
;relation 01 home address
set pmdbdoc->patient_data.person.relation_01.person.home_address.address_id
    = request->patient_data.person.relation_01.person.home_address.address_id
set pmdbdoc->patient_data.person.relation_01.person.home_address.street_addr
    = request->patient_data.person.relation_01.person.home_address.street_addr
set pmdbdoc->patient_data.person.relation_01.person.home_address.street_addr2
    = request->patient_data.person.relation_01.person.home_address.street_addr2
set pmdbdoc->patient_data.person.relation_01.person.home_address.street_addr3
    = request->patient_data.person.relation_01.person.home_address.street_addr3
set pmdbdoc->patient_data.person.relation_01.person.home_address.street_addr4
    = request->patient_data.person.relation_01.person.home_address.street_addr4
set pmdbdoc->patient_data.person.relation_01.person.home_address.city
    = request->patient_data.person.relation_01.person.home_address.city
set pmdbdoc->patient_data.person.relation_01.person.home_address.state
    = request->patient_data.person.relation_01.person.home_address.state
set pmdbdoc->patient_data.person.relation_01.person.home_address.state_cd
    = request->patient_data.person.relation_01.person.home_address.state_cd
set pmdbdoc->patient_data.person.relation_01.person.home_address.zipcode
    = request->patient_data.person.relation_01.person.home_address.zipcode
set pmdbdoc->patient_data.person.relation_01.person.home_address.county
    = request->patient_data.person.relation_01.person.home_address.county
set pmdbdoc->patient_data.person.relation_01.person.home_address.county_cd
    = request->patient_data.person.relation_01.person.home_address.county_cd
set pmdbdoc->patient_data.person.relation_01.person.home_address.country
    = request->patient_data.person.relation_01.person.home_address.country
set pmdbdoc->patient_data.person.relation_01.person.home_address.country_cd
    = request->patient_data.person.relation_01.person.home_address.country_cd
;relation 01 bus address
set pmdbdoc->patient_data.person.relation_01.person.bus_address.address_id
    = request->patient_data.person.relation_01.person.bus_address.address_id
set pmdbdoc->patient_data.person.relation_01.person.bus_address.street_addr
    = request->patient_data.person.relation_01.person.bus_address.street_addr
set pmdbdoc->patient_data.person.relation_01.person.bus_address.street_addr2
    = request->patient_data.person.relation_01.person.bus_address.street_addr2
set pmdbdoc->patient_data.person.relation_01.person.bus_address.street_addr3
    = request->patient_data.person.relation_01.person.bus_address.street_addr3
set pmdbdoc->patient_data.person.relation_01.person.bus_address.street_addr4
    = request->patient_data.person.relation_01.person.bus_address.street_addr4
set pmdbdoc->patient_data.person.relation_01.person.bus_address.city
    = request->patient_data.person.relation_01.person.bus_address.city
set pmdbdoc->patient_data.person.relation_01.person.bus_address.state
    = request->patient_data.person.relation_01.person.bus_address.state
set pmdbdoc->patient_data.person.relation_01.person.bus_address.state_cd
    = request->patient_data.person.relation_01.person.bus_address.state_cd
set pmdbdoc->patient_data.person.relation_01.person.bus_address.zipcode
    = request->patient_data.person.relation_01.person.bus_address.zipcode
set pmdbdoc->patient_data.person.relation_01.person.bus_address.county
    = request->patient_data.person.relation_01.person.bus_address.county
set pmdbdoc->patient_data.person.relation_01.person.bus_address.county_cd
    = request->patient_data.person.relation_01.person.bus_address.county_cd
set pmdbdoc->patient_data.person.relation_01.person.bus_address.country
    = request->patient_data.person.relation_01.person.bus_address.country
set pmdbdoc->patient_data.person.relation_01.person.bus_address.country_cd
    = request->patient_data.person.relation_01.person.bus_address.country_cd
;relation 01 alt address
set pmdbdoc->patient_data.person.relation_01.person.alt_address.address_id
    = request->patient_data.person.relation_01.person.alt_address.address_id
set pmdbdoc->patient_data.person.relation_01.person.alt_address.street_addr
    = request->patient_data.person.relation_01.person.alt_address.street_addr
set pmdbdoc->patient_data.person.relation_01.person.alt_address.street_addr2
    = request->patient_data.person.relation_01.person.alt_address.street_addr2
set pmdbdoc->patient_data.person.relation_01.person.alt_address.street_addr3
    = request->patient_data.person.relation_01.person.alt_address.street_addr3
set pmdbdoc->patient_data.person.relation_01.person.alt_address.street_addr4
    = request->patient_data.person.relation_01.person.alt_address.street_addr4
set pmdbdoc->patient_data.person.relation_01.person.alt_address.city
    = request->patient_data.person.relation_01.person.alt_address.city
set pmdbdoc->patient_data.person.relation_01.person.alt_address.state
    = request->patient_data.person.relation_01.person.alt_address.state
set pmdbdoc->patient_data.person.relation_01.person.alt_address.state_cd
    = request->patient_data.person.relation_01.person.alt_address.state_cd
set pmdbdoc->patient_data.person.relation_01.person.alt_address.zipcode
    = request->patient_data.person.relation_01.person.alt_address.zipcode
set pmdbdoc->patient_data.person.relation_01.person.alt_address.county
    = request->patient_data.person.relation_01.person.alt_address.county
set pmdbdoc->patient_data.person.relation_01.person.alt_address.county_cd
    = request->patient_data.person.relation_01.person.alt_address.county_cd
set pmdbdoc->patient_data.person.relation_01.person.alt_address.country
    = request->patient_data.person.relation_01.person.alt_address.country
set pmdbdoc->patient_data.person.relation_01.person.alt_address.country_cd
    = request->patient_data.person.relation_01.person.alt_address.country_cd
;relation 01 email address
set pmdbdoc->patient_data.person.relation_01.person.email_address.address_id
    = request->patient_data.person.relation_01.person.email_address.address_id
set pmdbdoc->patient_data.person.relation_01.person.email_address.street_addr
    = request->patient_data.person.relation_01.person.email_address.street_addr
;relation 01 email address phone table
set pmdbdoc->patient_data->person->relation_01->person->home_email.phone_id
    = request->patient_data->person->relation_01->person->home_email.phone_id
set pmdbdoc->patient_data->person->relation_01->person->home_email.email
    = trim(request->patient_data->person->relation_01->person->home_email.phone_num, 3)
set pmdbdoc->patient_data->person->relation_01->person->home_email.beg_effective_dt_tm
    = request->patient_data->person->relation_01->person->home_email.beg_effective_dt_tm
set pmdbdoc->patient_data->person->relation_01->person->home_email.end_effective_dt_tm
    = request->patient_data->person->relation_01->person->home_email.end_effective_dt_tm
;relation 01 temp address
set pmdbdoc->patient_data.person.relation_01.person.temp_address.address_id
    = request->patient_data.person.relation_01.person.temp_address.address_id
set pmdbdoc->patient_data.person.relation_01.person.temp_address.street_addr
    = request->patient_data.person.relation_01.person.temp_address.street_addr
set pmdbdoc->patient_data.person.relation_01.person.temp_address.street_addr2
    = request->patient_data.person.relation_01.person.temp_address.street_addr2
set pmdbdoc->patient_data.person.relation_01.person.temp_address.street_addr3
    = request->patient_data.person.relation_01.person.temp_address.street_addr3
set pmdbdoc->patient_data.person.relation_01.person.temp_address.street_addr4
    = request->patient_data.person.relation_01.person.temp_address.street_addr4
set pmdbdoc->patient_data.person.relation_01.person.temp_address.city
    = request->patient_data.person.relation_01.person.temp_address.city
set pmdbdoc->patient_data.person.relation_01.person.temp_address.state
    = request->patient_data.person.relation_01.person.temp_address.state
set pmdbdoc->patient_data.person.relation_01.person.temp_address.state_cd
    = request->patient_data.person.relation_01.person.temp_address.state_cd
set pmdbdoc->patient_data.person.relation_01.person.temp_address.zipcode
    = request->patient_data.person.relation_01.person.temp_address.zipcode
set pmdbdoc->patient_data.person.relation_01.person.temp_address.county
    = request->patient_data.person.relation_01.person.temp_address.county
set pmdbdoc->patient_data.person.relation_01.person.temp_address.county_cd
    = request->patient_data.person.relation_01.person.temp_address.county_cd
set pmdbdoc->patient_data.person.relation_01.person.temp_address.country
    = request->patient_data.person.relation_01.person.temp_address.country
set pmdbdoc->patient_data.person.relation_01.person.temp_address.country_cd
    = request->patient_data.person.relation_01.person.temp_address.country_cd
;relation 01 mail address
set pmdbdoc->patient_data.person.relation_01.person.mail_address.address_id
    = request->patient_data.person.relation_01.person.mail_address.address_id
set pmdbdoc->patient_data.person.relation_01.person.mail_address.street_addr
    = request->patient_data.person.relation_01.person.mail_address.street_addr
set pmdbdoc->patient_data.person.relation_01.person.mail_address.street_addr2
    = request->patient_data.person.relation_01.person.mail_address.street_addr2
set pmdbdoc->patient_data.person.relation_01.person.mail_address.street_addr3
    = request->patient_data.person.relation_01.person.mail_address.street_addr3
set pmdbdoc->patient_data.person.relation_01.person.mail_address.street_addr4
    = request->patient_data.person.relation_01.person.mail_address.street_addr4
set pmdbdoc->patient_data.person.relation_01.person.mail_address.city
    = request->patient_data.person.relation_01.person.mail_address.city
set pmdbdoc->patient_data.person.relation_01.person.mail_address.state
    = request->patient_data.person.relation_01.person.mail_address.state
set pmdbdoc->patient_data.person.relation_01.person.mail_address.state_cd
    = request->patient_data.person.relation_01.person.mail_address.state_cd
set pmdbdoc->patient_data.person.relation_01.person.mail_address.zipcode
    = request->patient_data.person.relation_01.person.mail_address.zipcode
set pmdbdoc->patient_data.person.relation_01.person.mail_address.county
    = request->patient_data.person.relation_01.person.mail_address.county
set pmdbdoc->patient_data.person.relation_01.person.mail_address.county_cd
    = request->patient_data.person.relation_01.person.mail_address.county_cd
set pmdbdoc->patient_data.person.relation_01.person.mail_address.country
    = request->patient_data.person.relation_01.person.mail_address.country
set pmdbdoc->patient_data.person.relation_01.person.mail_address.country_cd
    = request->patient_data.person.relation_01.person.mail_address.country_cd
;relation 01 mobile phone
set pmdbdoc->patient_data.person.relation_01.person.mobile_phone.phone_id
    = request->patient_data.person.relation_01.person.mobile_phone.phone_id
set pmdbdoc->patient_data.person.relation_01.person.mobile_phone.phone_format_cd
    = request->patient_data.person.relation_01.person.mobile_phone.phone_format_cd
set pmdbdoc->patient_data.person.relation_01.person.mobile_phone.phone_num
    = request->patient_data.person.relation_01.person.mobile_phone.phone_num
set pmdbdoc->patient_data.person.relation_01.person.mobile_phone.extension
    = request->patient_data.person.relation_01.person.mobile_phone.extension

;relation 01 home phone
set pmdbdoc->patient_data.person.relation_01.person.home_phone.phone_id
    = request->patient_data.person.relation_01.person.home_phone.phone_id
set pmdbdoc->patient_data.person.relation_01.person.home_phone.phone_format_cd
    = request->patient_data.person.relation_01.person.home_phone.phone_format_cd
set pmdbdoc->patient_data.person.relation_01.person.home_phone.phone_num
    = request->patient_data.person.relation_01.person.home_phone.phone_num
set pmdbdoc->patient_data.person.relation_01.person.home_phone.extension
    = request->patient_data.person.relation_01.person.home_phone.extension
 
;realtion 01 home pager
set pmdbdoc->patient_data.person.relation_01.person.home_pager.phone_id
   = request->patient_data.person.relation_01.person.home_pager.phone_id
set pmdbdoc->patient_data.person.relation_01.person.home_pager.phone_format_cd
   = request->patient_data.person.relation_01.person.home_pager.phone_format_cd
set pmdbdoc->patient_data.person.relation_01.person.home_pager.phone_num
   = request->patient_data.person.relation_01.person.home_pager.phone_num
set pmdbdoc->patient_data.person.relation_01.person.home_pager.extension
   = request->patient_data.person.relation_01.person.home_pager.extension
 
;realtion 01 bus phone
set pmdbdoc->patient_data.person.relation_01.person.bus_phone.phone_id
   = request->patient_data.person.relation_01.person.bus_phone.phone_id
set pmdbdoc->patient_data.person.relation_01.person.bus_phone.phone_format_cd
   = request->patient_data.person.relation_01.person.bus_phone.phone_format_cd
set pmdbdoc->patient_data.person.relation_01.person.bus_phone.phone_num
   = request->patient_data.person.relation_01.person.bus_phone.phone_num
set pmdbdoc->patient_data.person.relation_01.person.bus_phone.extension
   = request->patient_data.person.relation_01.person.bus_phone.extension

;realtion 01 alt phone
set pmdbdoc->patient_data.person.relation_01.person.alt_phone.phone_id
   = request->patient_data.person.relation_01.person.alt_phone.phone_id
set pmdbdoc->patient_data.person.relation_01.person.alt_phone.phone_format_cd
   = request->patient_data.person.relation_01.person.alt_phone.phone_format_cd
set pmdbdoc->patient_data.person.relation_01.person.alt_phone.phone_num
   = request->patient_data.person.relation_01.person.alt_phone.phone_num
set pmdbdoc->patient_data.person.relation_01.person.alt_phone.extension
   = request->patient_data.person.relation_01.person.alt_phone.extension

;realtion 01 temp phone
set pmdbdoc->patient_data.person.relation_01.person.temp_phone.phone_id
   = request->patient_data.person.relation_01.person.temp_phone.phone_id
set pmdbdoc->patient_data.person.relation_01.person.temp_phone.phone_format_cd
   = request->patient_data.person.relation_01.person.temp_phone.phone_format_cd
set pmdbdoc->patient_data.person.relation_01.person.temp_phone.phone_num
   = request->patient_data.person.relation_01.person.temp_phone.phone_num
set pmdbdoc->patient_data.person.relation_01.person.temp_phone.extension
   = request->patient_data.person.relation_01.person.temp_phone.extension
 
call DebugPrint("alias formatting")
;Create alias variables with alias pool format (masking)
set pmdbdoc->patient_data.person.mrn.mrn_formatted
   = cnvtalias(request->patient_data.person.mrn.alias, request->patient_data.person.mrn.alias_pool_cd)
set pmdbdoc->patient_data.person.ssn.ssn_formatted
   = cnvtalias(request->patient_data.person.ssn.alias, request->patient_data.person.ssn.alias_pool_cd)
set pmdbdoc->patient_data.person.cmrn.cmrn_formatted
   = cnvtalias(request->patient_data.person.cmrn.alias, request->patient_data.person.cmrn.alias_pool_cd)
set pmdbdoc->patient_data.person.encounter.finnbr.fin_formatted
   = cnvtalias(request->patient_data.person.encounter.finnbr.alias,
   request->patient_data.person.encounter.finnbr.alias_pool_cd)
 
 
call DebugPrint("UAR formatting patient")
;UAR calls for code values on facesheet - PATIENT
set pmdbdoc->patient_data.person.vip_disp
   = uar_get_code_display(request->patient_data.person.vip_cd)
set pmdbdoc->patient_data.person.sex_disp = uar_get_code_display(request->patient_data.person.sex_cd)
set pmdbdoc->patient_data.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.home_address.state_cd)
set pmdbdoc->patient_data.person.prev_address.state_disp
   = uar_get_code_display(request->patient_data.person.prev_address.state_cd)
set pmdbdoc->patient_data.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.bill_address.state_disp
   = uar_get_code_display(request->patient_data.person.bill_address.state_cd)
set pmdbdoc->patient_data.person.birth_address.state_disp
   = uar_get_code_display(request->patient_data.person.birth_address.state_cd)
set pmdbdoc->patient_data.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.religion_disp = uar_get_code_display(request->patient_data.person.religion_cd)
set pmdbdoc->patient_data.person.nationality_disp = uar_get_code_display(request->patient_data.person.nationality_cd)
set pmdbdoc->patient_data->person.marital_type_disp = uar_get_code_display(request->patient_data.person.marital_type_cd)
set pmdbdoc->patient_data->person.race_disp = uar_get_code_display(request->patient_data.person.race_cd)
set pmdbdoc->patient_data.person.language_disp = uar_get_code_display(request->patient_data.person.language_cd)
set pmdbdoc->patient_data.person.church_disp = uar_get_code_display(request->patient_data.person.patient.church_cd)
set pmdbdoc->patient_data.person.interp_required_disp
   = uar_get_code_display(request->patient_data.person.patient.interp_required_cd)
set pmdbdoc->patient_data.person.process_alert_disp = uar_get_code_display(request->patient_data.person.patient.process_alert_cd)
set pmdbdoc->patient_data.person.patient.birth_sex_disp = uar_get_code_display(request->patient_data.person.patient.birth_sex_cd)
set pmdbdoc->patient_data.person.employer_01.organization_name 
   = GetOrgName(request->patient_data.person.employer_01.organization_id)
set pmdbdoc->patient_data.person.employer_01.address.state_disp
   = uar_get_code_display(request->patient_data.person.employer_01.address.state_cd)
 
call DebugPrint("phone formatting patient")
;Format phone numbers on facesheet - PATIENT
set pmdbdoc->patient_data.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.home_phone.phone_num,
   request->patient_data.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.home_pager.phone_formatted
   = cnvtphone( request->patient_data.person.home_pager.phone_num,
   request->patient_data.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.alt_phone.phone_num,
   request->patient_data.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.temp_phone.phone_num,
   request->patient_data.person.temp_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.bus_phone.phone_num,
   request->patient_data.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.mobile_phone.phone_num,
   request->patient_data.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.employer_01.phone.phone_formatted
   = cnvtphone(request->patient_data.person.employer_01.phone.phone_num ,
   request->patient_data.person.employer_01.phone.phone_format_cd, 2)
 
call DebugPrint("get patient events")
;patient event query
if (pmdbdoc->patient_data->person.encounter.encntr_id > 0.0)
   select into "nl:"
   from patient_event pe
   where pe.encntr_id = pmdbdoc->patient_data->person.encounter.encntr_id
     and pe.event_type_cd in (d_CS4002773_OBS_START_DT, d_CS4002773_OUTPATINBED_CD, d_CS4002773_CLINDISCHRG_CD)
     and pe.active_ind = 1
   order by pe.event_dt_tm, pe.patient_event_id
   detail
    if (pe.event_type_cd = d_CS4002773_OBS_START_DT)
       pmdbdoc->patient_data.person.encounter.observation_dt_tm = pe.event_dt_tm
    elseif (pe.event_type_cd = d_CS4002773_CLINDISCHRG_CD)
       pmdbdoc->patient_data.person.encounter.clinical_discharge_dt_tm = pe.event_dt_tm
    elseif (pe.event_type_cd = d_CS4002773_OUTPATINBED_CD)
       pmdbdoc->patient_data.person.encounter.outpatient_in_bed_dt_tm = pe.event_dt_tm
    endif
   with nocounter
 endif

call DebugPrint("UAR formatting encounter")
;UAR calls for code values on facesheet - ENCOUNTER INFORMATION
set pmdbdoc->patient_data.person.encounter.encntr_type_disp
   = uar_get_code_display(request->patient_data.person.encounter.encntr_type_cd)
set pmdbdoc->patient_data.person.encounter.med_service_disp
   = uar_get_code_display(request->patient_data.person.encounter.med_service_cd)
set pmdbdoc->patient_data.person.encounter.loc_nurse_unit_disp
   = uar_get_code_display(request->patient_data.person.encounter.loc_nurse_unit_cd)
set pmdbdoc->patient_data.person.encounter.loc_room_disp
   = uar_get_code_display(request->patient_data.person.encounter.loc_room_cd)
set pmdbdoc->patient_data.person.encounter.loc_bed_disp
   = uar_get_code_display(request->patient_data.person.encounter.loc_bed_cd)
set pmdbdoc->patient_data.person.encounter.isolation_disp
   = uar_get_code_display(request->patient_data.person.encounter.isolation_cd)
set pmdbdoc->patient_data.person.encounter.admit_type_disp
   = uar_get_code_display(request->patient_data.person.encounter.admit_type_cd)
set pmdbdoc->patient_data.person.encounter.admit_src_disp
   = uar_get_code_display(request->patient_data.person.encounter.admit_src_cd)
set pmdbdoc->patient_data.person.patient.living_will_disp
   = uar_get_code_display(request->patient_data.person.patient.living_will_cd)
set pmdbdoc->patient_data.person.encounter.reg_prsnl_name_full
   = GetNameFF(request->patient_data.person.encounter.reg_prsnl_id)
;set pmdbdoc->patient_data.person.encounter.observation_dt_tm =
;request->patient_data.person.encounter.observation_dt_tm
set pmdbdoc->patient_data.person.patient.disease_alert_disp
   = uar_get_code_display(request->patient_data.person.patient.disease_alert_cd)
set pmdbdoc->patient_data.person.encounter.loc_facility_disp
   = uar_get_code_display(request->patient_data.person.encounter.loc_facility_cd)
set pmdbdoc->patient_data.person.age = cnvtage(request->patient_data.person.birth_dt_tm)
set  pmdbdoc->patient_data.person.encounter.disch_disposition_disp
    = uar_get_code_display(request->patient_data.person.encounter.disch_disposition_cd)
set pmdbdoc->patient_data.person.encounter.accommodation_disp
    = uar_get_code_display(request->patient_data.person.encounter.accommodation_cd)
set pmdbdoc->patient_data.person.encounter.admit_mode_disp
    = uar_get_code_display(request->patient_data.person.encounter.admit_mode_cd)
set pmdbdoc->patient_data.person.encounter.disch_to_loctn_disp
    = uar_get_code_display(request->patient_data.person.encounter.disch_to_loctn_cd)
set pmdbdoc->patient_data.person.encounter.ambulatory_cond_disp
    = uar_get_code_display(request->patient_data.person.encounter.ambulatory_cond_cd)
set pmdbdoc->patient_data.person.encounter.vip_disp
    = uar_get_code_display(request->patient_data.person.encounter.vip_cd)
set pmdbdoc->patient_data.person.encounter.visitor_status_disp
    = uar_get_code_display(request->patient_data.person.encounter.visitor_status_cd)
set pmdbdoc->patient_data.person.encounter.client_name 
    = GetOrgName(pmdbdoc->patient_data.person.encounter.client_organization_id)
 
call DebugPrint("UAR formatting Subscriber 01")
;UAR calls for code values on facesheet - PRIMARY SUBSCRIBER/INSURANCE
set pmdbdoc->patient_data.person.subscriber_01.related_person_reltn_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.related_person_reltn_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.sex_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.sex_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.home_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.plan_info.financial_class_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.health_plan.plan_info.financial_class_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.organization_name
   = GetOrgName(request->patient_data.person.subscriber_01.person.employer_01.organization_id)
set pmdbdoc->patient_data.person.subscriber_01.employer_01.address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.employer_01.address.state_cd)
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_01.person.health_plan.address.state_cd)
 
call DebugPrint("phone formatting Subscriber 01")
;Format phone numbers on facesheet - PRIMARY SUBSCRIBER/INSURANCE
set pmdbdoc->patient_data.person.subscriber_01.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.mobile_phone.phone_num,
   request->patient_data.person.subscriber_01.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.home_phone.phone_num,
   request->patient_data.person.subscriber_01.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.home_pager.phone_num,
   request->patient_data.person.subscriber_01.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.bus_phone.phone_num,
   request->patient_data.person.subscriber_01.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.alt_phone.phone_num,
   request->patient_data.person.subscriber_01.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.temp_phone.phone_num,
   request->patient_data.person.subscriber_01.person.temp_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.employer_01.phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.employer_01.phone.phone_num,
   request->patient_data.person.subscriber_01.person.employer_01.phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.health_plan.phone.phone_num,
   request->patient_data.person.subscriber_01.person.health_plan.phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num,
   request->patient_data.person.subscriber_01.person.health_plan.visit_info.auth_info_01.auth_detail.phone_format_cd, 2)
 
 
call DebugPrint("UAR formatting Subscriber 02")
;UAR calls for code values on facesheet - SECONDARY SUBSCRIBER/INSURANCE
set pmdbdoc->patient_data.person.subscriber_02.related_person_reltn_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.related_person_reltn_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.sex_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.sex_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.home_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.plan_info.financial_class_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.health_plan.plan_info.financial_class_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.organization_name
   = GetOrgName(request->patient_data.person.subscriber_02.person.employer_01.organization_id)
set pmdbdoc->patient_data.person.subscriber_02.employer_01.address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.employer_01.address.state_cd)
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_02.person.health_plan.address.state_cd)
 
call DebugPrint("phone formatting Subscriber 02")
;Format phone numbers on facesheet - SECONDARY SUBSCRIBER/INSURANCE
set pmdbdoc->patient_data.person.subscriber_02.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.mobile_phone.phone_num,
   request->patient_data.person.subscriber_02.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.home_phone.phone_num,
   request->patient_data.person.subscriber_02.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.home_pager.phone_num,
   request->patient_data.person.subscriber_02.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.bus_phone.phone_num,
   request->patient_data.person.subscriber_02.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.alt_phone.phone_num,
   request->patient_data.person.subscriber_02.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.temp_phone.phone_num,
   request->patient_data.person.subscriber_02.person.temp_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.employer_01.phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.employer_01.phone.phone_num,
   request->patient_data.person.subscriber_02.person.employer_01.phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.health_plan.phone.phone_num,
   request->patient_data.person.subscriber_02.person.health_plan.phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num,
   request->patient_data.person.subscriber_02.person.health_plan.visit_info.auth_info_01.auth_detail.phone_format_cd, 2)
 
 
call DebugPrint("UAR formatting Subscriber 03")
   ;UAR calls for code values on facesheet - TERTIARY SUBSCRIBER/INSURANCE
set pmdbdoc->patient_data.person.subscriber_03.related_person_reltn_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.related_person_reltn_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.sex_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.sex_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.home_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.plan_info.financial_class_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.health_plan.plan_info.financial_class_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.organization_name
   = GetOrgName(request->patient_data.person.subscriber_03.person.employer_01.organization_id)
set pmdbdoc->patient_data.person.subscriber_03.employer_01.address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.employer_01.address.state_cd)
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.address.state_disp
   = uar_get_code_display(request->patient_data.person.subscriber_03.person.health_plan.address.state_cd)
 
call DebugPrint("phone formatting Subscriber 03")
;Format phone numbers on facesheet - TERTIARY SUBSCRIBER/INSURANCE
set pmdbdoc->patient_data.person.subscriber_03.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.mobile_phone.phone_num,
   request->patient_data.person.subscriber_03.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.home_phone.phone_num,
   request->patient_data.person.subscriber_03.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.home_pager.phone_num,
   request->patient_data.person.subscriber_03.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.bus_phone.phone_num,
   request->patient_data.person.subscriber_03.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.alt_phone.phone_num,
   request->patient_data.person.subscriber_03.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.temp_phone.phone_num,
   request->patient_data.person.subscriber_03.person.temp_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.employer_01.phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.employer_01.phone.phone_num,
   request->patient_data.person.subscriber_03.person.employer_01.phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.phone.phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.health_plan.phone.phone_num,
   request->patient_data.person.subscriber_03.person.health_plan.phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_formatted
   = cnvtphone(request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.auth_phone_num,
   request->patient_data.person.subscriber_03.person.health_plan.visit_info.auth_info_01.auth_detail.phone_format_cd, 2)
 
call DebugPrint("UAR formatting Guarantor 01")
;UAR calls for code values on facesheet - GUARANTOR 01
set pmdbdoc->patient_data.person.guarantor_01.related_person_reltn_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.related_person_reltn_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.sex_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.sex_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.religion_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.religion_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.home_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.ssn.ssn_formatted
   = cnvtalias(request->patient_data.person.guarantor_01.person.ssn.alias,
   request->patient_data.person.guarantor_01.person.ssn.alias_pool_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.organization_name
   = GetOrgName(request->patient_data.person.guarantor_01.person.employer_01.organization_id)
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_01.person.employer_01.address.state_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.marital_type_disp
    = uar_get_code_display(request->patient_data.person.guarantor_01.person.marital_type_cd)
set pmdbdoc->patient_data.person.guarantor_01.person.race_disp
    = uar_get_code_display(request->patient_data.person.guarantor_01.person.race_cd)
 
call DebugPrint("phone formatting Guarantor 01")
;Format phone numbers on facesheet - GUARANTOR 01
set pmdbdoc->patient_data.person.guarantor_01.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.mobile_phone.phone_num,
   request->patient_data.person.guarantor_01.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_01.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.home_phone.phone_num,
   request->patient_data.person.guarantor_01.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_01.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.home_pager.phone_num,
   request->patient_data.person.guarantor_01.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_01.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.bus_phone.phone_num,
   request->patient_data.person.guarantor_01.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_01.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.alt_phone.phone_num,
   request->patient_data.person.guarantor_01.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_01.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.temp_phone.phone_num,
   request->patient_data.person.guarantor_01.person.temp_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_01.person.employer_01.phone.phone_formatted
   = cnvtphone(request->patient_data.person.guarantor_01.person.employer_01.phone.phone_num,
   request->patient_data.person.guarantor_01.person.employer_01.phone.phone_format_cd, 2)
 
call DebugPrint("UAR formatting Guarantor 02")
;UAR calls for code values on facesheet - GUARANTOR 02
set pmdbdoc->patient_data.person.guarantor_02.related_person_reltn_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.related_person_reltn_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.sex_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.sex_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.religion_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.religion_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.home_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.ssn.ssn_formatted
   = cnvtalias(request->patient_data.person.guarantor_02.person.ssn.alias,
   request->patient_data.person.guarantor_02.person.ssn.alias_pool_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.organization_name
   = GetOrgName(request->patient_data.person.guarantor_02.person.employer_01.organization_id)
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.address.state_disp
   = uar_get_code_display(request->patient_data.person.guarantor_02.person.employer_01.address.state_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.marital_type_disp
    = uar_get_code_display(request->patient_data.person.guarantor_02.person.marital_type_cd)
set pmdbdoc->patient_data.person.guarantor_02.person.race_disp
    = uar_get_code_display(request->patient_data.person.guarantor_02.person.race_cd)
 
call DebugPrint("phone formatting Guarantor 02")
;Format phone numbers on facesheet - GUARANTOR 02
set pmdbdoc->patient_data.person.guarantor_02.person.mobile_phone.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.mobile_phone.phone_num,
    request->patient_data.person.guarantor_02.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_02.person.home_phone.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.home_phone.phone_num,
    request->patient_data.person.guarantor_02.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_02.person.home_pager.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.home_pager.phone_num,
    request->patient_data.person.guarantor_02.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_02.person.bus_phone.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.bus_phone.phone_num,
    request->patient_data.person.guarantor_02.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_02.person.alt_phone.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.alt_phone.phone_num,
    request->patient_data.person.guarantor_02.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_02.person.temp_phone.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.temp_phone.phone_num,
    request->patient_data.person.guarantor_02.person.temp_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.guarantor_02.person.employer_01.phone_formatted
    = cnvtphone(request->patient_data.person.guarantor_02.person.employer_01.phone_num,
    request->patient_data.person.guarantor_02.person.employer_01.phone_format_cd, 2)
 
 
call DebugPrint("UAR formatting EMC")
;UAR calls for code values on facesheet - EMC
   ;Remove and trim (FT) from relation
set pmdbdoc->patient_data.person.emc.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.emc.person.home_address.state_cd)
set pmdbdoc->patient_data.person.emc.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.emc.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.emc.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.emc.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.emc.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.emc.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.emc.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.emc.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.emc.related_person_reltn_disp
   = TRIM(REPLACE(uar_get_code_display(request->patient_data.person.emc.related_person_reltn_cd),"(FT)",""))
set pmdbdoc->patient_data.person.emc.person.sex_disp
   = uar_get_code_display(request->patient_data.person.emc.person.sex_cd)
 
call DebugPrint("phone formatting EMC")
;Format phone numbers on facesheet - EMC
set pmdbdoc->patient_data.person.emc.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.emc.person.mobile_phone.phone_num,
   request->patient_data.person.emc.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.emc.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.emc.person.home_phone.phone_num,
   request->patient_data.person.emc.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.emc.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.emc.person.home_pager.phone_num,
   request->patient_data.person.emc.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.emc.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.emc.person.bus_phone.phone_num,
   request->patient_data.person.emc.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.emc.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.emc.person.alt_phone.phone_num,
   request->patient_data.person.emc.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.emc.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.emc.person.temp_phone.phone_num,
   request->patient_data.person.emc.person.temp_phone.phone_format_cd, 2)
 
 
call DebugPrint("UAR formatting NOK")
;UAR calls for code values on facesheet - NOK
   ;Remove and trim (FT) from relation
set pmdbdoc->patient_data.person.nok.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.nok.person.home_address.state_cd)
set pmdbdoc->patient_data.person.nok.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.nok.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.nok.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.nok.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.nok.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.nok.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.nok.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.nok.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.nok.related_person_reltn_disp
   = TRIM(REPLACE(uar_get_code_display(request->patient_data.person.nok.related_person_reltn_cd),"(FT)",""))
set pmdbdoc->patient_data.person.nok.person.sex_disp
   = uar_get_code_display(request->patient_data.person.nok.person.sex_cd)
 
call DebugPrint("phone formatting NOK")
;Format phone numbers on facesheet - NOK
set pmdbdoc->patient_data.person.nok.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.nok.person.mobile_phone.phone_num,
   request->patient_data.person.nok.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.nok.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.nok.person.home_phone.phone_num,
   request->patient_data.person.nok.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.nok.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.nok.person.home_pager.phone_num,
   request->patient_data.person.nok.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.nok.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.nok.person.bus_phone.phone_num,
   request->patient_data.person.nok.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.nok.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.nok.person.alt_phone.phone_num,
   request->patient_data.person.nok.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.nok.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.nok.person.temp_phone.phone_num,
   request->patient_data.person.nok.person.temp_phone.phone_format_cd, 2)
 
 
call DebugPrint("UAR formatting Relation 01")
;UAR calls for code values on facesheet - RELATION 01
   ;Remove and trim (FT) from relation
set pmdbdoc->patient_data.person.relation_01.person.home_address.state_disp
   = uar_get_code_display(request->patient_data.person.relation_01.person.home_address.state_cd)
set pmdbdoc->patient_data.person.relation_01.person.bus_address.state_disp
   = uar_get_code_display(request->patient_data.person.relation_01.person.bus_address.state_cd)
set pmdbdoc->patient_data.person.relation_01.person.alt_address.state_disp
   = uar_get_code_display(request->patient_data.person.relation_01.person.alt_address.state_cd)
set pmdbdoc->patient_data.person.relation_01.person.temp_address.state_disp
   = uar_get_code_display(request->patient_data.person.relation_01.person.temp_address.state_cd)
set pmdbdoc->patient_data.person.relation_01.person.mail_address.state_disp
   = uar_get_code_display(request->patient_data.person.relation_01.person.mail_address.state_cd)
set pmdbdoc->patient_data.person.relation_01.related_person_reltn_disp
   = TRIM(REPLACE(uar_get_code_display(request->patient_data.person.relation_01.related_person_reltn_cd),"(FT)",""))
set pmdbdoc->patient_data.person.relation_01.person.sex_disp
   = uar_get_code_display(request->patient_data.person.relation_01.person.sex_cd)
 
call DebugPrint("phone formatting Relation 01")
;Format phone numbers on facesheet - RELATION 01
set pmdbdoc->patient_data.person.relation_01.person.mobile_phone.phone_formatted
   = cnvtphone(request->patient_data.person.relation_01.person.mobile_phone.phone_num,
   request->patient_data.person.relation_01.person.mobile_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.relation_01.person.home_phone.phone_formatted
   = cnvtphone(request->patient_data.person.relation_01.person.home_phone.phone_num,
   request->patient_data.person.relation_01.person.home_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.relation_01.person.home_pager.phone_formatted
   = cnvtphone(request->patient_data.person.relation_01.person.home_pager.phone_num,
   request->patient_data.person.relation_01.person.home_pager.phone_format_cd, 2)
set pmdbdoc->patient_data.person.relation_01.person.bus_phone.phone_formatted
   = cnvtphone(request->patient_data.person.relation_01.person.bus_phone.phone_num,
   request->patient_data.person.relation_01.person.bus_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.relation_01.person.alt_phone.phone_formatted
   = cnvtphone(request->patient_data.person.relation_01.person.alt_phone.phone_num,
   request->patient_data.person.relation_01.person.alt_phone.phone_format_cd, 2)
set pmdbdoc->patient_data.person.relation_01.person.temp_phone.phone_formatted
   = cnvtphone(request->patient_data.person.relation_01.person.temp_phone.phone_num,
   request->patient_data.person.relation_01.person.temp_phone.phone_format_cd, 2)

call DebugPrint("get last update date information")
;GET LAST UPDATE INFORMATION
set pmdbdoc->patient_data.transaction_info.name_full_formatted = GetNameFF(reqinfo->updt_id)
 
select into "nl:"
from encounter e,
     (left join prsnl p
      on (p.person_id = e.updt_id)
     )
plan e
 where e.encntr_id = request->patient_data->person->encounter.encntr_id
join p
detail
 pmdbdoc->patient_data->person->encounter.last_updt_dt_tm = e.updt_dt_tm
 pmdbdoc->patient_data->person->encounter.last_updt_prsnl_name = trim(p.name_full_formatted, 3)
with nocounter
 
call DebugPrint("get facility information")
;GET FACILITY ORGANIZATION INFORMATION
select into "nl:"
from location l
 where l.location_cd =  request->patient_data->person->encounter.loc_facility_cd
detail
 pmdbdoc->patient_data->person->encounter.facilityorg.organization_id = l.organization_id
with nocounter
 
set pmdbdoc->patient_data->person->encounter.facilityorg.organization_name
   = GetOrgName(pmdbdoc->patient_data->person->encounter.facilityorg.organization_id)
 
select into "nl:"
from address a
 where a.parent_entity_id =  pmdbdoc->patient_data->person->encounter->facilityorg.organization_id
   and a.parent_entity_name = "ORGANIZATION"
   and a.address_type_cd = d_CS212_BUSINESS_ADDR_CD
   and a.active_ind = 1
detail
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_address.street_addr = a.street_addr,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_address.street_addr2 = a.street_addr2,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_address.city = a.city,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_address.state_cd = a.state_cd,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_address.state_disp = uar_get_code_display(a.state_cd),
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_address.zipcode = a.zipcode
with nocounter
 
select into "nl:"
from phone ph
where ph.parent_entity_id = pmdbdoc->patient_data->person->encounter->facilityorg.organization_id
  and ph.parent_entity_name = "ORGANIZATION"
  and ph.phone_type_cd = d_CS43_BUSINESS_PHONE_CD
  and ph.active_ind = 1
detail
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_phone.phone_id = ph.phone_id,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_phone.phone_nbr = ph.phone_num,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_phone.phone_format_cd = ph.phone_format_cd,
 pmdbdoc->patient_data->person->encounter.facilityorg.bus_phone.phone_formatted = cnvtphone(ph.phone_num,ph.phone_format_cd, 2)
with nocounter
 
call DebugPrint("set service date")
set eclass = cnvtupper(uar_get_code_display(pmdbdoc->patient_data->person->encounter.encntr_type_class_cd))
 
if (eclass = "OBSERVATION")
  set pmdbdoc->patient_data->person->encounter.service_dt_tm = pmdbdoc->patient_data->person->encounter.observation_dt_tm
elseif (eclass = "INPATIENT")
  set pmdbdoc->patient_data->person->encounter.service_dt_tm = pmdbdoc->patient_data->person->encounter.inpatient_admit_dt_tm
elseif (eclass = "EMERGENCY")
  set pmdbdoc->patient_data->person->encounter.service_dt_tm = pmdbdoc->patient_data->person->encounter.arrive_dt_tm
elseif (eclass = "PREADMIT")
  set pmdbdoc->patient_data->person->encounter.service_dt_tm = pmdbdoc->patient_data->person->encounter.est_arrive_dt_tm
else
  set pmdbdoc->patient_data->person->encounter.service_dt_tm = pmdbdoc->patient_data->person->encounter.reg_dt_tm
endif

if (bGetPerColl = TRUE)
   call DebugPrint("get person_data_not_coll information")
   select into "nl:"
    pdnc.seq
   from person_data_not_coll pdnc
   plan pdnc
    where pdnc.person_id = pmdbdoc->patient_data->person.person_id
      and pdnc.active_ind = 1
   order by pdnc.updt_dt_tm
   detail
    pmdbdoc->patient_data->person->person_data_not_coll.ssn_cd = pdnc.ssn_cd
    pmdbdoc->patient_data->person->person_data_not_coll.home_address_cd = pdnc.home_address_cd
    pmdbdoc->patient_data->person->person_data_not_coll.phone_cd = pdnc.phone_cd
    pmdbdoc->patient_data->person->person_data_not_coll.home_email_cd = pdnc.home_email_cd
    pmdbdoc->patient_data->person->person_data_not_coll.primary_care_physician_cd = pdnc.primary_care_physician_cd
    pmdbdoc->patient_data->person->person_data_not_coll.national_health_nbr_cd = pdnc.national_health_nbr_cd
    pmdbdoc->patient_data->person->person_data_not_coll.drivers_license_cd = pdnc.drivers_license_cd
    pmdbdoc->patient_data->person->person_data_not_coll.biometric_ident_cd = pdnc.biometric_ident_cd
   with nocounter   
endif

if (bGetEncColl = TRUE)
   call DebugPrint("get encntr_data_not_coll information")
   select into "nl:"
    ednc.seq
   from encntr_data_not_coll ednc
   plan ednc
    where ednc.encntr_id = request->patient_data->person->encounter.encntr_id
      and ednc.active_ind = 1
   order by ednc.updt_dt_tm
   detail
    pmdbdoc->patient_data->person->encounter->encntr_data_not_coll.referring_physician_cd = ednc.referring_physician_cd
    pmdbdoc->patient_data->person->encounter->encntr_data_not_coll.est_financial_resp_amt_cd = ednc.est_financial_resp_amt_cd
   with nocounter
endif

if (bMapUdf = TRUE)
   call DebugPrint("map udf fields")
   ;add the default person udfs
   call add_udf_attribute("STRING_01","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_02","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_03","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_04","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_05","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_06","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_07","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_08","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_09","STRING","PERSON",0.0,"")
   call add_udf_attribute("STRING_10","STRING","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_01","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_02","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_03","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_04","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_05","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_06","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_07","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_08","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_09","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_10","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_11","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_12","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_13","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_14","CODE","PERSON",0.0,"")
   call add_udf_attribute("NUMBER_15","CODE","PERSON",0.0,"")
   call add_udf_attribute("DATE_01","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_02","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_03","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_04","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_05","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_06","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_07","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_08","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_09","DATE","PERSON",0.0,"")
   call add_udf_attribute("DATE_10","DATE","PERSON",0.0,"")

   ;add the default encounter udfs
   call add_udf_attribute("STRING_01","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_02","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_03","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_04","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_05","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_06","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_07","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_08","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_09","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("STRING_10","STRING","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_01","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_02","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_03","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_04","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_05","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_06","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_07","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_08","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_09","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_10","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_11","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_12","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_13","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_14","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("NUMBER_15","CODE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_01","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_02","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_03","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_04","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_05","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_06","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_07","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_08","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_09","DATE","ENCOUNTER",0.0,"")
   call add_udf_attribute("DATE_10","DATE","ENCOUNTER",0.0,"")

   ;get the client udfs
   select into "nl:"
    c.seq
   from code_value c, 
        code_value_extension cve_f,
        code_value_extension cve_t,
        code_value_extension cve_l
   plan c
    where c.code_set = 356
      and c.active_ind = 1
   join cve_f
    where cve_f.code_value = c.code_value
      and cve_f.field_name = "FIELD"
      and cve_f.field_value > " "
   join cve_t
    where cve_t.code_value = c.code_value
      and cve_t.field_name = "TYPE"
      and cve_t.field_value in ("STRING","CODE","DATE","NUMERIC")
   join cve_l
    where cve_l.code_value = c.code_value
      and cve_l.field_name = "LEVEL"
      and cve_l.field_value in ("PERSON","ENCOUNTER")
   order by c.code_value
   head c.code_value
    call add_udf_attribute(cve_f.field_value,
                           cve_t.field_value,
                           cve_l.field_value,
                           c.code_value,
                           c.cdf_meaning)
   with nocounter

   if (pm_udf->ids_cnt > 0)
      set stat = alterlist(pm_udf->ids, pm_udf->ids_cnt)
   endif

   free record person_udf
   call pm_parser("record person_udf (")
   for (lIdx = 1 to pm_udf->ids_cnt)
      if (pm_udf->ids[lIdx].person_ind = TRUE)
         call pm_parser(pm_udf->ids[lIdx].rec_str)
      endif
   endfor
   call pm_parser(") with persistscript go")

   free record encntr_udf
   call pm_parser("record encntr_udf (")
   for (lIdx = 1 to pm_udf->ids_cnt)
      if (pm_udf->ids[lIdx].encntr_ind = TRUE)
         call pm_parser(pm_udf->ids[lIdx].rec_str)
      endif
   endfor
   call pm_parser(") with persistscript go")

   call DebugPrint("get udf field values")
   ;if pmOffice/pmLaunch/pmdbdocs, then copy the record structure over
   if (bIsPmOffice = TRUE)
      call DebugPrint("coping udf field values from request")
      for (lIdx = 1 to pm_udf->ids_cnt)
         if (validate(parser(pm_udf->ids[lIdx].src_fld)))
            call pm_parser(pm_udf->ids[lIdx].copy_str_src)
            call pm_parser(pm_udf->ids[lIdx].copy_str_des1)
            call pm_parser(pm_udf->ids[lIdx].copy_str_des2)
         endif
      endfor
   ;if RevCycle, then go get the UDFs from person_info/encntr_info tables
   elseif (bIsRevCycle = TRUE)
      call DebugPrint("selecting udf field values from person_info")
      set lIdx = 0
      set lSortCnt = 0
      set lCnt = 0
      set lStart = 1

      select into "nl:"
       pi.seq
      from person_info pi,
         (left join long_text lt
          on (lt.long_text_id = pi.long_text_id
          and lt.active_ind = 1)
         )
      plan pi
       where pi.person_id = pmdbdoc->patient_data->person.person_id
         and expand(lCnt, 1, pm_udf->p_cnt, pi.info_sub_type_cd, pm_udf->p_list[lCnt].p_cv)
         and pi.info_sub_type_cd != 0.0
         and pi.info_type_cd = d_CS355_UDF_CD
         and pi.active_ind = 1
         and pi.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         and pi.end_effective_dt_tm > cnvtdatetime(sysdate)
      join lt
      order by pi.info_sub_type_cd, pi.beg_effective_dt_tm
      head pi.info_sub_type_cd
         lIdx = locateval(lSortCnt, lStart, pm_udf->ids_cnt, pi.info_sub_type_cd, pm_udf->ids[lSortCnt]->code_value)
         if (lIdx > 0 and pm_udf->ids[lIdx]->code_value > 0.0)
            if  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "vc")
               pm_udf->ids[lIdx].value_string = lt.long_text
            elseif  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "f8")
               pm_udf->ids[lIdx].value_cd = pi.value_cd
            elseif  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "dq8")
               pm_udf->ids[lIdx].value_dt_tm = pi.value_dt_tm
            elseif  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "i4")
               pm_udf->ids[lIdx].value_numeric = pi.value_numeric
            endif
         endif
      with nocounter, expand = 2

      call DebugPrint("mapping table values to person_udf request values")
      set lIdx = 0
      for (lIdx = 1 to pm_udf->ids_cnt)
         if (pm_udf->ids[lIdx].person_ind = TRUE)
            if (pm_udf->ids[lIdx].rec_type = "vc")
               set parser(concat(" person_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_string
            elseif (pm_udf->ids[lIdx].rec_type = "f8")
               set parser(concat(" person_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_cd
            elseif (pm_udf->ids[lIdx].rec_type = "dq8")
               set parser(concat(" person_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_dt_tm
            elseif (pm_udf->ids[lIdx].rec_type = "i4")
               set parser(concat(" person_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_numeric
            endif
         endif
      endfor

      call DebugPrint("selecting udf field values from encntr_info")
      set lIdx = 0
      set lSortCnt = 0
      set lCnt = 0
      set lStart = 1

      select into "nl:"
       ei.seq
      from encntr_info ei,
         (left join long_text lt
          on (lt.long_text_id = ei.long_text_id
          and lt.active_ind = 1)
         )
      plan ei
       where ei.encntr_id = pmdbdoc->patient_data->person.encounter.encntr_id
         and expand(lCnt, 1, pm_udf->e_cnt, ei.info_sub_type_cd, pm_udf->e_list[lCnt].e_cv)
         and ei.info_sub_type_cd != 0.0
         and ei.info_type_cd = d_CS355_UDF_CD
         and ei.active_ind = 1
         and ei.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         and ei.end_effective_dt_tm > cnvtdatetime(sysdate)
      join lt
      order by ei.info_sub_type_cd, ei.beg_effective_dt_tm
      head ei.info_sub_type_cd
         lIdx = locateval(lSortCnt, lStart, pm_udf->ids_cnt, ei.info_sub_type_cd, pm_udf->ids[lSortCnt]->code_value)
         if (lIdx > 0 and pm_udf->ids[lIdx]->code_value > 0.0)
            if  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "vc")
               pm_udf->ids[lIdx].value_string = lt.long_text
            elseif  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "f8")
               pm_udf->ids[lIdx].value_cd = ei.value_cd
            elseif  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "dq8")
               pm_udf->ids[lIdx].value_dt_tm = ei.value_dt_tm
            elseif  (cnvtlower(pm_udf->ids[lIdx].rec_type) = "i4")
               pm_udf->ids[lIdx].value_numeric = ei.value_numeric
            endif
         endif
      with nocounter, expand = 2

      call DebugPrint("mapping table values to encntr_udf request values")
      set lIdx = 0
      for (lIdx = 1 to pm_udf->ids_cnt)
         if (pm_udf->ids[lIdx].encntr_ind = TRUE)
            if (pm_udf->ids[lIdx].rec_type = "vc")
               set parser(concat(" encntr_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_string
            elseif (pm_udf->ids[lIdx].rec_type = "f8")
               set parser(concat(" encntr_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_cd
            elseif (pm_udf->ids[lIdx].rec_type = "dq8")
               set parser(concat(" encntr_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_dt_tm
            elseif (pm_udf->ids[lIdx].rec_type = "i4")
               set parser(concat(" encntr_udf->", pm_udf->ids[lIdx]->field)) = pm_udf->ids[lIdx].value_numeric
            endif
         endif
      endfor
   endif
endif

if (bIsRevCycle = TRUE and bEmailOnPhone = TRUE)
   call DebugPrint("get email address off phone table")
   ;get email addresses from phone table
   call GetPatientEmail("pmdbdoc->patient_data->person", pmdbdoc->patient_data->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->subscriber_01->person", 
                       pmdbdoc->patient_data->person->subscriber_01->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->subscriber_02->person", 
                       pmdbdoc->patient_data->person->subscriber_02->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->subscriber_03->person", 
                       pmdbdoc->patient_data->person->subscriber_03->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->guarantor_01->person", 
                       pmdbdoc->patient_data->person->guarantor_01->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->guarantor_02->person", 
                       pmdbdoc->patient_data->person->guarantor_02->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->nok->person", 
                       pmdbdoc->patient_data->person->nok->person->person_id)
   call GetReltnEmail("pmdbdoc->patient_data->person->emc->person", 
                       pmdbdoc->patient_data->person->emc->person->person_id)
endif

call DebugPrint("formatting date of birth fields")
;patient
set pmdbdoc->patient_data->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->birth_tz,
                                 pmdbdoc->patient_data->person->birth_prec_flag)

;subscriber_01
set pmdbdoc->patient_data->person->subscriber_01->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->subscriber_01->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->subscriber_01->person->birth_tz,
                                 pmdbdoc->patient_data->person->subscriber_01->person->birth_prec_flag)

;subscriber_02
set pmdbdoc->patient_data->person->subscriber_02->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->subscriber_02->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->subscriber_02->person->birth_tz,
                                 pmdbdoc->patient_data->person->subscriber_02->person->birth_prec_flag)

;subscriber_03
set pmdbdoc->patient_data->person->subscriber_03->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->subscriber_03->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->subscriber_03->person->birth_tz,
                                 pmdbdoc->patient_data->person->subscriber_03->person->birth_prec_flag)

;guarantor_01
set pmdbdoc->patient_data->person->guarantor_01->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->guarantor_01->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->guarantor_01->person->birth_tz,
                                 pmdbdoc->patient_data->person->guarantor_01->person->birth_prec_flag)

;guarantor_02
set pmdbdoc->patient_data->person->guarantor_02->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->guarantor_02->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->guarantor_02->person->birth_tz,
                                 pmdbdoc->patient_data->person->guarantor_02->person->birth_prec_flag)

;nok
set pmdbdoc->patient_data->person->nok->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->nok->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->nok->person->birth_tz,
                                 pmdbdoc->patient_data->person->nok->person->birth_prec_flag)

;emc
set pmdbdoc->patient_data->person->emc->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->emc->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->emc->person->birth_tz,
                                 pmdbdoc->patient_data->person->emc->person->birth_prec_flag)

;relation_01
set pmdbdoc->patient_data->person->relation_01->person->birth_dt_formatted = 
                 getFormattedDob(pmdbdoc->patient_data->person->relation_01->person->birth_dt_tm,
                                 pmdbdoc->patient_data->person->relation_01->person->birth_tz,
                                 pmdbdoc->patient_data->person->relation_01->person->birth_prec_flag)

#exit_script
call DebugPrint("all done")

end
go

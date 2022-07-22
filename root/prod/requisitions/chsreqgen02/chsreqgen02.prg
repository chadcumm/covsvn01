drop program chsreqgen02:dba go
create program chsreqgen02:dba
 
/*~BB~************************************************************************
  *                                                                      *
  *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
  *                              Technology, Inc.                        *
  *       Revision      (c) 1984-2003 Cerner Corporation                 *
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
 
        Source file name:       chsreqgen02.PRG
        Object name:            chsreqgen02
        Task #:                 NA
        Request #:              NA
 
        Product:                EasyScript (Rx printing)
        Product Team:           PowerChart Office
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Print/Fax Rx requisitions
 
        Special Notes:          Generic script based off of TMMC_FL_PCORXRECGEN,
                                written by Steven Farmer.
 
******************************************************************************/
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG
;    ***********************************************************************************************
;    *
;    *Mod Date       CR       Engineer               Comment
;    *--- --------   -------- -------------------    -----------------------------------------------
;     000 02/11/2003          JF8275                 Initial Release
;     001 05/21/2003          SF3151                 Correct Drug Sorting
;     002 06/09/2003          SF3151                 Validate Don't Print detail is valued
;     003 06/10/2003          SF3151                 1) Print COMPLETE orders
;                                                    2) Print STREET_ADDR2 for patient
;                                                    3) Remove Re-print indicator
;     004 06/17/2003          SF3151                 Throw error if can't find CSA_SCHEDULE
;     005 06/23/2003          SF3151                 Correct Phone Format
;     006 07/02/2003          SF3151                 Correct Multum table check
;     007 12/10/2003          BP9613                 Replacing Dispense Duration to Dispense when
;						    	                     necessary.
;     008 12/29/2003          JF8275                 Fix defects CAPEP00113087 and CAPEP00112906
;     009 01/09/2004          JF8275                 Added fix for volume dose
;     010 01/14/2004          JF8275                 Group Misc. Meds individually by csa_group
;     011 04/02/2004          BP9613                 Ordering on the correct parameter
;     012 07/09/2004          IT010631               Refill and Mid-level enahncement changes
;     013 07/16/2004          PC3603                 Fix refill/renew issues
;     014 08/25/2004          PC3603                 Subtract one from additional refill field because
;                                                    it was incremented when it was refilled
;     015 01/07/2005          BP9613                 Front end printing enhancement change:
;                                                    Ordering the print jobs for one printer call
;                                                    while still grouping the fax jobs the same
;     016 04/04/2005          SF3151                 Access Righs
;     017 04/08/2005          SF3151                 Handle traversing prsnl_org org list correctly
;     018 04/11/2005          SF3151                 Handle getting prsnl_org org list correctly
;     019 10/20/2005          KS012546               Printing does not occur on the complete action
;                                                    for orders that are not one times.
;     020 02/02/2006          KS012546               Requisitions no longer print "PRN" on SIG line
;                                                    after PRN instructions removed.
;     021 02/13/2006          MJ6234                 Selecting from frequency schedule is done using
;                                                    dummyt table instead of expand function.
;     022 02/22/2007          AC013650               Time stamps added to determine if an order with
;                                                    a complete action should be printed
;     023 05/24/2007          RD012555               Changed naming convention of fax output to
;                                                    ensure uniqueness.
;     024 05/24/2007          RD012555               Prescriptions without a frequency will not print
;                                                    twice when taking a complete action.
;     025 08/07/2007          RD012555               Add ellipsis to mnemonics that are truncated.
;     026 05/06/2008          SA016585               Changed the ORDER and HEAD section of select for
;                                                    DEA number to print the DEA number of the
;                                                    prescribing physician when supervising physician
;                                                    is present.
;     027 07/18/2008          WC014474               Stop printing if order status is med student.
;     028 07/23/2008          WC014474               Print NPI number
;     029 08/07/2008          MK012585               Fix to print both DEA and NPI aliases correctly
;     030 10/30/2008          SJ016555               For Orders containing both strength and volume
;                                                    dose the requisitions will print both strength
;                                                    and volume doses for Primary, Brand and C type
;                                                    mnemonics
;     031 11/14/2008          SA016585               Introduced Order by Sup_phys_id to print
;                                                    multiple RX on different pages if they have
;                                                    diff sup_phys_id.  Removed order by d.seq since
;                                                    order by can be done at most on 10 items.
;     032 12/22/2008          SW015124               Added drug form detail.
;     033 01/20/2009          CG011817               Changes for stacked suspend on new order.
;     034 08/20/2009          AD010624               Replaced comparisons using > " " with size() > 0
;                                                    Trim both sides of order details
;     035 08/09/2009          SH018059               Remove Start Dt Tm, replace with "Date Written"
;     036 08/25/2009          JT018805               Replace time based logic around auto-complete
;			                                         and auto-suspend
;     037 10/12/2009          DP014848               For Orders containing both strength and volume
;                                                    dose the requisitions will print only strength
;                                                    dose for Primary, Brand and C type mnemonics
;     038 08/19/2010          MK012585	             Include order_id in the name of the report
;                                                    to ensure uniqueness
;     039 01/12/2012          KK023353	             Changes for Electronic Prescription of
;                                                    Controlled Substances (EPCS)
;     040 02/06/2012          PC3603                 Stop printing e-sig for controlled substances
;     041 06/27/2012          PC3603                 Sort the order_detail correctly so the routing
;                                                    pharmacy name is printed correctly
;     042 08/15/2012          BB024239               Medication is displayed and printed both
;                                                    numerically and alphabetically
;     043 04/04/2013          PB027274               Fixed incorrect conversion of DOB from UTC to
;                                                    local by adding birth timezone
;     044 10/01/2013          ST020427               Date/time format converted to support
;                                                    globalization format.
;     045 05/15/2018          RS049105               Adjusted to print one perscription per page
;                                                    Mirror RXREQGEN03 logic.
;     046 06/28/2018 CR 2445  Dawn Greer, DBA        Adding ICD 10 codes to prescriptions per TN
;                                                    State Requirement on 7/1/2018.
;                    CR 2463  Dawn Greer, DBA        Also changed the Frequency code to the Frequency
;                                                    text.
;     047 07/06/2018 CR 2526  Dawn Greer, DBA        Add Supervisor Provider to the
;                                                    prescription via the order entry fields.
;     048 07/10/2018 CR 2526  Dawn Greer, DBA        Pull Supervisor Provider from name_value_prefs
;                                                    and app_prefs and prsnl tables where providers
;                                                    are associated with a supervising provider using the
;                                                    DEFAULT_SUP_PHY_ORM preference setting.
;     049 07/17/2018 CR 2526  Dawn Greer, DBA        Remove the word Ambulatory from the
;                                                    Supervising Provider output.  If the OEF
;                                                    Supervising field is populated then display that
;                                                    otherwise display supervising provider from the
;                                                    Preferences and fix DOB issue.
;     050 07/20/2018 CR 2526  Dawn Greer, DBA        Remove code for the OEF and DEFAULT_SUP_PHY_ORM
;                                                    Preference setting.  They are going to use a setting
;                                                    to enable the original Supervising Provider field and that
;                                                    field will pull in the Preference Setting if
;                                                    there is one.  Thus changes 047, 048 and part
;                                                    of 049 are now removed.  The DOB piece is still
;                                                    implemented as of change 050.
;     051 12/18/2018 CR 2822  Dawn Greer, DBA        Add Finnbr, Future Fill Date and update documentation
;                                                    throughout the program. Also adjusted the location of
;                                                    the preferred Pharmacy to be just below the patient address
;     052 01/21/2019 CR 4241  Dawn Greer, DBA        Added the seq = 1 code to pulling the providers Phone Numbers
;     053 02/12/2019 CR 4309  Dawn Greer, DBA        A CCL package install (CCLREV 9.40 CCLVER 81401, CCLREVMAJOR 8,
;                                                    CCLREVMINOR 14, and CCLREVMINOR2 1) broke the order of operations
;                                                    for division in the subroutine get_number_spellout.  Had to add
;                                                    parenthesis around division operation.  Changed the Subroutine
;                                                    parameter from REF to VALUE
;     054 08/03/2020 CR 8272  Dawn Greer, DBA        Replace the Fill Date with the Earliest Fill Date.
;                                                    If the ‘Earliest Fill Date’ is blank, display the ‘Request Refill Date’
;                                                    otherwise display the ‘Earliest Fill Date’ for the ‘Fill Date’ Field
;                                                    on the requisition.  If both fields are populated the ‘Earliest Fill Date’
;                                                    will display.
;
;~DE~********************************************************************************************************************
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ****************************************************************
 
/****************************************************************************
*       Request record                                                      *
*****************************************************************************/
;*** requisitions should always have the request defined (not commented out)
;*** order of the request fields matter.
 
 
record request
(
  1 person_id         = f8
  1 print_prsnl_id    = f8
  1 order_qual[*]
    2 order_id        = f8
    2 encntr_id       = f8
    2 conversation_id = f8
  1 printer_name      = c50
)
 
call echorecord(request)
 
record request_in  ;Request: Pharmacy_RetrievePharmaciesByIds (3202501)
(
    1 active_status_flag = i2
    1 transmit_capability_flag = i2
    1 ids[*]
      2 id = vc
)
 
/****************************************************************************
*       Reply record                                                        *
*****************************************************************************/
free record reply
record reply
(
%i cclsource:status_block.inc
)
 
/****************************************************************************
*       Include files                                                       *
*****************************************************************************/
;%i cclsource:cps_header_declares.inc
 
if (validate(FALSE,-1) = -1)
   set FALSE         = 0
endif
if (validate(TRUE,-1) = -1)
   set TRUE          = 1
endif
set GEN_NBR_ERROR = 3      ;*** error generating a sequence number
set INSERT_ERROR  = 4      ;*** error inserting item
set UPDATE_ERROR  = 5      ;*** error updating item
set DELETE_ERROR  = 6      ;*** error deleteing item
set SELECT_ERROR  = 7      ;*** error selecting item
set LOCK_ERROR    = 8
set INPUT_ERROR   = 9      ;*** error in request data
set EXE_ERROR     = 10     ;*** error in execution of embedded program
set failed        = FALSE  ;*** holds failure status of script
set table_name    = fillstring (50, " ")
set sErrMsg       = fillstring(132, " ")
set iErrCode      = error(sErrMsg,1)
set iErrCode      = 0
 
/****************************************************************************
*       Declare variables                                                   *
*****************************************************************************/
declare dct = vc with protect
declare frm = vc with protect
declare pref_pharma = vc with protect
declare pharma_fax  = vc with protect
declare pharma_phone = vc with protect
set dct = "ccluserdir:CovenantHealthLogo_Official.dct"
set frm = "ccluserdir:CovenantHealthLogo_Official.frm"
declare PREFER_PHARM_CD = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!4102369925")),protect
declare loc_bus_cd = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!8009")),protect
declare sPharmacyName = vc with noconstant(" "),protect
declare bFoundPharmacy = i2 with protect,noconstant(FALSE)
declare work_fax_cd = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!9529")),protect
declare new_rx_text    = c22 with public, constant("Prescription Details:") ;012
declare refill_rx_text = c22 with public, constant("Prescription Details:") ;012
declare reprint_text   = c24 with public, constant("RE-PRINT Prescription(s)")
declare is_a_reprint   = i2 with public, noconstant(FALSE)
declare v500_ind       = i2 with public, noconstant(FALSE)
declare use_pco        = i2 with public, noconstant(FALSE)
declare mltm_loaded    = i2 with public, noconstant(FALSE)
declare non_blank_nbr  = i2 with public, noconstant(TRUE) ;008
declare found_npi	   = i2 with public, noconstant(FALSE);028
declare found_npi_sup  = i2 with public, noconstant(FALSE);028
 
declare username  = vc with public, noconstant(" ")
declare file_name = vc with public, noconstant(" ")
 
declare work_add_cd         = f8 with public, noconstant(0.0)
declare home_add_cd         = f8 with public, noconstant(0.0)
declare work_phone_cd       = f8 with public, noconstant(0.0)
declare home_phone_cd       = f8 with public, noconstant(0.0)
declare order_cd            = f8 with public, noconstant(0.0)
declare complete_cd         = f8 with public, noconstant(0.0)
declare modify_cd           = f8 with public, noconstant(0.0)
declare suspend_cd          = f8 with public, noconstant(0.0);033
declare studactivate_cd     = f8 with public, noconstant(0.0)
declare activate_cd			= f8 with public, noconstant(0.0) ;MOD 036
declare docdea_cd           = f8 with public, noconstant(0.0)
declare licensenbr_cd       = f8 with public, noconstant(0.0)
declare canceled_allergy_cd = f8 with public, noconstant(0.0)
declare emrn_cd             = f8 with public, noconstant(0.0)
declare finnbr_cd           = f8 with public, noconstant(0.0)	;051
declare pmrn_cd             = f8 with public, noconstant(0.0)
declare ord_comment_cd      = f8 with public, noconstant(0.0)
declare prsnl_type_cd       = f8 with public,noconstant(0.0)
declare medstudent_hold_cd	= f8 with public, noconstant(0.0);027
declare docnpi_cd			= f8 with public, noconstant(0.0);028
declare eprsnl_ind          = i2 with public,noconstant(FALSE)
declare code_set    = i4  with public, noconstant(0)
declare cdf_meaning = c12 with public, noconstant(fillstring(12," "))
declare csa_group_cnt       = i4 with public, noconstant(0)   ;010
declare temp_csa_group      = vc with public, noconstant(" ") ;010
declare pos                 = i4 with protect, noconstant(0)  ;019
declare j                   = i4 with protect, noconstant(0)  ;019
declare num                 = i4 with protect, noconstant(0)  ;ar051237
 
;*** MOD 016 BEG
declare bPersonOrgSecurityOn = i2 with public,noconstant(FALSE)
declare dminfo_ok = i2 with private,noconstant(FALSE)
declare algy_bit_pos = i2 with public,noconstant(0)
declare algy_access_priv = f8 with public,noconstant(0.0)
declare access_granted = i2 with public,noconstant(FALSE)
declare user_id = f8 with public,noconstant(0.0)
declare eidx = i4 with public,noconstant(0)
declare fidx = i4 with public,noconstant(0)
declare adr_exist = i2 with public,noconstant(FALSE)
;*** MOD 016 END
 
declare mnemonic_size = i4 with protect, noconstant(0)	;025
declare mnem_length = i4 with protect, noconstant(0)	;025
 
declare primary_mnemonic_type_cd = f8 with protect, noconstant(0.0)
declare brand_mnemonic_type_cd   = f8 with protect, noconstant(0.0)
declare c_mnemonic_type_cd       = f8 with protect, noconstant(0.0)
 
;032 Start
declare generic_top_type_cd = f8 with protect, noconstant(0.0)
declare trade_top_type_cd = f8 with protect, noconstant(0.0)
declare generic_prod_type_cd = f8 with protect, noconstant(0.0)
declare trade_prod_type_cd = f8 with protect, noconstant(0.0)
;032 End
declare erx_idx = i4 with protect, noconstant(0)
declare msg_audit_code = f8 with protect, noconstant(0.0)
 
;042 Start
declare number_spellout     = vc with protect, noconstant("")
declare dispense_number     = c255 with protect, noconstant("")
;042 End
 
 ;Setting up structure to hold numbers for spell out
 
record numbers
(
    1 ones[10]
      2 value  = vc
    1 teens[10]
      2 value  = vc
    1 tens[9]
      2 value  = vc
    1 hundred  = c7
    1 thousand = c8
 
)
 
;initializing the ones
set numbers->ones[1].value   = "zero"
set numbers->ones[2].value   = "one"
set numbers->ones[3].value   = "two"
set numbers->ones[4].value   = "three"
set numbers->ones[5].value   = "four"
set numbers->ones[6].value   = "five"
set numbers->ones[7].value   = "six"
set numbers->ones[8].value   = "seven"
set numbers->ones[9].value   = "eight"
set numbers->ones[10].value  = "nine"
 
;initializing the teens
set numbers->teens[1].value  = "ten"
set numbers->teens[2].value  = "eleven"
set numbers->teens[3].value  = "twelve"
set numbers->teens[4].value  = "thirteen"
set numbers->teens[5].value  = "fourteen"
set numbers->teens[6].value  = "fifteen"
set numbers->teens[7].value  = "sixteen"
set numbers->teens[8].value  = "seventeen"
set numbers->teens[9].value  = "eightteen"
set numbers->teens[10].value = "nineteen"
 
;initializing the tens
set numbers->tens[1].value   = "ten"
set numbers->tens[2].value   = "twenty"
set numbers->tens[3].value   = "thirty"
set numbers->tens[4].value   = "forty"
set numbers->tens[5].value   = "fifty"
set numbers->tens[6].value   = "sixty"
set numbers->tens[7].value   = "seventy"
set numbers->tens[8].value   = "eighty"
set numbers->tens[9].value   = "ninety"
 
;initializing hundred
set numbers->hundred = "hundred"
 
;initializing thousand
set numbers->thousand = "thousand"
 
 
 
/****************************************************************************
*       Initialize variables                                                *
*****************************************************************************/
set code_set = 212
set cdf_meaning = "HOME"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,home_add_cd)
 
if (home_add_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 212
set cdf_meaning = "BUSINESS"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,work_add_cd)
if (work_add_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 43
set cdf_meaning = "HOME"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,home_phone_cd)
if (home_phone_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 43
set cdf_meaning = "BUSINESS"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,work_phone_cd)
if (work_phone_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 6003
set cdf_meaning = "ORDER"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,order_cd)
if (order_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 6003
set cdf_meaning = "COMPLETE"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,complete_cd)
if (complete_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 6003
set cdf_meaning = "MODIFY"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,modify_cd)
if (modify_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 6003
set cdf_meaning = "STUDACTIVATE"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,studactivate_cd)
if (studactivate_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
;Begin Mod 033
set code_set = 6003
set cdf_meaning = "SUSPEND"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,suspend_cd)
if (suspend_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
;End Mod 033
 
;BEGIN MOD 036
set code_set = 6003
set cdf_meaning = "ACTIVATE"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,activate_cd)
if (activate_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
;END MOD 036
 
set code_set = 12025
set cdf_meaning = "CANCELED"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,canceled_allergy_cd)
if (canceled_allergy_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 320
set cdf_meaning = "LICENSENBR"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,licensenbr_cd)
if (licensenbr_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 320
set cdf_meaning = "DOCDEA"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,docdea_cd)
if (docdea_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
/*** start 027 ***/
set code_set = 6004
set cdf_meaning = "MEDSTUDENT"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,medstudent_hold_cd)
if (medstudent_hold_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
/*** end 027 ***/
 
/*** start 028 ***/
set code_set = 320
set cdf_meaning = "NPI"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,docnpi_cd)
if (docnpi_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
/*** end 028 ***/
 
set code_set = 319
set cdf_meaning = "MRN"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,emrn_cd)
if (emrn_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
;051 - FIN NBR
set code_set = 319
set cdf_meaning = "FIN NBR"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,finnbr_cd)
if (emrn_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
;051
 
set code_set = 4
set cdf_meaning = "MRN"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pmrn_cd)
if (pmrn_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Unable to find the Code Value for ",
                         trim(cdf_meaning),
                         " in Code Set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 14
set cdf_meaning = "ORD COMMENT"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ord_comment_cd)
if (ord_comment_cd < 1)
    set failed = SELECT_ERROR
    set table_name = "CODE_VALUE"
    set sErrMsg = concat("Failed to find the code_value for ",
                         trim(cdf_meaning),
                         " in code_set ",
                         trim(cnvtstring(code_set)))
    go to EXIT_SCRIPT
endif
 
set code_set = 213
set cdf_meaning = "PRSNL"
set stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,prsnl_type_cd)
if (prsnl_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
;030
set code_set = 6011
set cdf_meaning = "PRIMARY"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, primary_mnemonic_type_cd)
if (primary_mnemonic_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
set cdf_meaning = "BRANDNAME"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, brand_mnemonic_type_cd)
if (brand_mnemonic_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
set cdf_meaning = "DISPDRUG"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, c_mnemonic_type_cd)
 
if (c_mnemonic_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
;032 Start
set cdf_meaning = "GENERICTOP"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, generic_top_type_cd)
if (generic_top_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
set cdf_meaning = "TRADETOP"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, trade_top_type_cd)
if (trade_top_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
set cdf_meaning = "GENERICPROD"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, generic_prod_type_cd)
if (generic_prod_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
 
set cdf_meaning = "TRADEPROD"
set stat = uar_get_meaning_by_codeset(code_set, cdf_meaning, 1, trade_prod_type_cd)
if (trade_prod_type_cd < 1)
   set failed = SELECT_ERROR
   set table_name = "CODE_VALUE"
   set sErrMsg = concat("Failed to find the code_value for ",
                        trim(cdf_meaning),
                        " in code_set ",
                        trim(cnvtstring(code_set)))
   go to EXIT_SCRIPT
endif
;032 End
 
; determine if this is a reprint
if (request->print_prsnl_id > 0)
    set is_a_reprint = TRUE
endif
 
; find printer
if (is_a_reprint = FALSE)
    select into "nl:"
    from
        prsnl p
    plan p where
        p.person_id = reqinfo->updt_id
    head report
        username = trim(substring(1,12,p.username))
    with nocounter
endif
 
if (not(size(username,1) > 0))     ;034
   set username = "faxreq"
endif
 
call echo ("***")
call echo (build("*** username :",username))
call echo ("***")
 
 
/****************************************************************************
*       load patient demographics                                           *
*****************************************************************************/
call echo("*** load patient demographics ***")	;051
 
free record demo_info
record demo_info
(
  1 pat_id         = f8
  1 pat_name       = vc
  1 pat_sex        = vc
  1 pat_bday       = vc
  1 pat_age        = vc
  1 pat_addr       = vc
  1 pat_city       = vc
  1 pat_hphone     = vc
  1 pat_wphone     = vc
  1 allergy_line   = vc
  1 allergy_knt    = i4
  1 allergy[*]
    2 disp         = vc
)
 
;*** get name and address information
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    person p,
    address a
plan p where
    p.person_id = request->person_id
join a where
    a.parent_entity_id = outerjoin(p.person_id) and
    a.parent_entity_name = outerjoin("PERSON") and
    a.address_type_cd = outerjoin(home_add_cd) and
    (a.active_ind = outerjoin(1) and
     a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3)) and
     a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
order
    ;a.beg_effective_dt_tm desc
    a.address_id
 
head report
    demo_info->pat_id   = p.person_id
    demo_info->pat_name = trim(p.name_full_formatted)
    demo_info->pat_sex  = trim(uar_get_code_display(p.sex_cd))
    demo_info->pat_bday = format (cnvtdatetimeutc (p.birth_dt_tm, 1) ,"mm/dd/yyyy;;d" );049 - Fix DOB issue
    demo_info->pat_age  = cnvtage(p.birth_dt_tm)
    found_address = FALSE
 
head a.address_id
 
    if (a.address_id > 0 and found_address = FALSE)
        found_address = TRUE
        demo_info->pat_addr = trim(substring(1,33,a.street_addr))
        if (size(a.street_addr2,1) > 0)     ;034
            demo_info->pat_addr = trim(substring(1,33,trim(concat(trim(demo_info->pat_addr),", ",trim(a.street_addr2)))))
        endif
 
        demo_info->pat_city = trim(a.city)
 
        if (a.state_cd > 0)
            demo_info->pat_city = concat(trim(demo_info->pat_city),", ",trim(uar_get_code_display(a.state_cd)))
        elseif (size(a.state,1) > 0)     ;034
            demo_info->pat_city = concat(trim(demo_info->pat_city),", ",trim(a.state))
        endif
 
        if (size(a.zipcode,1) > 0)     ;034
            demo_info->pat_city = concat(trim(demo_info->pat_city)," ",trim(a.zipcode))
        endif
 
        demo_info->pat_city = trim(substring(1,33,demo_info->pat_city))
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "NAME_ADDRESS"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get patient phone numbers                                           *
*****************************************************************************/
call echo("*** get patient phone numbers ***") 	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    phone p
plan p where
    p.parent_entity_id = request->person_id and
    p.parent_entity_name = "PERSON" and
    p.phone_type_cd in (home_phone_cd,work_phone_cd) and
    (p.active_ind = 1 and
     p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
order
    p.beg_effective_dt_tm desc
 
head report
    found_home = FALSE
    found_work = FALSE
 
detail
    if (found_home = FALSE and p.phone_type_cd = home_phone_cd)
        found_home = TRUE
        demo_info->pat_hphone = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
    endif
 
    if (found_work = FALSE and p.phone_type_cd = work_phone_cd)
        found_work = TRUE
        demo_info->pat_wphone = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
   endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "PATIENT_PHONE"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get allergy info                                                    *
*****************************************************************************/
call echo("*** get allergy info ***")	;051
 
;*** get allergy info
;*** MOD 016 BEG
;*** Is Person/Org Security On ================================================
 
;*** Check to see if ADR table exist.  If it exist then Person/Org Security
;*** may be on
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    dba_tables d
plan d where
    d.table_name = "ACTIVITY_DATA_RELTN" and
    d.owner = "V500"
detail
    adr_exist = TRUE
with nocounter
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "DBA_TABLES"
    go to EXIT_SCRIPT
endif
 
if (adr_exist = TRUE)
;*** determine if Person/Org Security is on
   set dminfo_ok = validate( ccldminfo->mode, 0 )
   if(dminfo_ok = 1)
      if (ccldminfo->sec_org_reltn = 1 and ccldminfo->person_org_sec = 1)
         set bPersonOrgSecurityOn = TRUE
      endif
   else
      set iErrCode = error(sErrMsg,1)
      set iErrCode = 0
      select into "nl:"
      from dm_info di
      plan di
         where di.info_domain = "SECURITY"
         and di.info_name in ("SEC_ORG_RELTN", "PERSON_ORG_SEC")
         and di.info_number = 1
      head report
         encntr_org_sec_on = 0
         person_org_sec_on = 0
      detail
         if (di.info_name = "SEC_ORG_RELTN" and di.info_number = 1)
            encntr_org_sec_on = 1
         elseif (di.info_name = "PERSON_ORG_SEC")
            person_org_sec_on = 1
         endif
      foot report
         if (person_org_sec_on = 1 and encntr_org_sec_on = 1)
            bPersonOrgSecurityOn = TRUE
         endif
      with nocounter
      set iErrCode = error(sErrMsg,1)
      if (iErrCode > 0)
         set failed = SELECT_ERROR
         set table_name = "DM_INFO"
         go to EXIT_SCRIPT
      endif
   endif
endif
 
if (bPersonOrgSecurityOn = TRUE)
;*** If Person/Org Security is on check to see if the User has an "Override" Person/Prsnl
;*** relationship to the patient.  If and "Override" relationship exist then act as if
;*** Person/Org Security is off
 
   call echo("*** PersonOrgSecurityON = TRUE ***")	;051
 
   set iErrCode = error(sErrMsg,1)
   set iErrCode = 0
   select into "nl:"
   from orders o
      ,order_action oa
   plan o
      where o.order_id = request->order_qual[1].order_id
   join oa
      where oa.order_id = o.order_id
      and oa.action_sequence = o.last_action_sequence
   detail
      user_id = oa.order_provider_id
   with nocounter
   set iErrCode = error(sErrMsg,1)
   if (iErrCode > 0)
      set failed = SELECT_ERROR
      set table_name = "GET_USER_ID"
      go to EXIT_SCRIPT
   endif
 
   if (user_id < 1)
      set bPersonOrgSecurityOn = FALSE
   else
      set iErrCode = error(sErrMsg,1)
      set iErrCode = 0
      select into "nl:"
      from person_prsnl_reltn ppr
         ,code_value_extension cve
      plan ppr
         where ppr.prsnl_person_id = user_id
         and ppr.active_ind = 1
         and ppr.person_id+0 = request->person_id
         and ppr.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
         and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
      join cve
         where cve.code_value = ppr.person_prsnl_r_cd
         and cve.code_set = 331
         and (cve.field_value = "1" or cve.field_value = "2")
         and cve.field_name = "Override"
      head report
         bPersonOrgSecurityOn = FALSE
      with nocounter
      set iErrCode = error(sErrMsg,1)
      if (iErrCode > 0)
         set failed = SELECT_ERROR
         set table_name = "PRSNL_OVERRIDE"
         go to EXIT_SCRIPT
      endif
   endif
endif
if (bPersonOrgSecurityOn = TRUE)
;*** If Person/Org Security is on determine the Allergy Access Priv Code Value
;*** to be used later to determine the bit position of the access priv of the
;*** Org Set the user belongs to.
 
   set algy_access_priv = uar_get_code_by("DISPLAYKEY",413574,"ALLERGIES")
   if (algy_access_priv < 1)
      set failed = SELECT_ERROR
      set table_name = "CODE_VALUE"
      set sErrMsg = "Failed to find Code Value for Display Key ALLERGIES in Code Set 413574"
      go to EXIT_SCRIPT
   endif
endif
 
/****************************************************************************
*       Load Prsnl Orgs                                                     *
*****************************************************************************/
if (bPersonOrgSecurityOn = TRUE)
 
;*** Person/Org Security is on, load the organizations and org sets the user belongs to
 
call echo("*** load prsnl orgs ***")	;051
 
   declare network_var = f8 with Constant(uar_get_code_by("MEANING",28881,"NETWORK")),protect
 
   free record prsnl_orgs
   record prsnl_orgs
   (
      1  org_knt = i4
      1  org[*]
         2  organization_id = f8
      1  org_set_knt = i4
      1  org_set[*]
         2  org_set_id = f8
         2  access_privs = i4
         2  org_list_knt = i4
         2  org_list[*]
            3  organization_id = f8
   )
 
   set iErrCode = error(sErrMsg,1)
   set iErrCode = 0
 
   select into "nl:"
   from prsnl_org_reltn por
   plan por
      where por.person_id = user_id
      and por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      and por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      and por.active_ind = TRUE
   head report
      knt = 0
      stat = alterlist(prsnl_orgs->org,10)
   head por.organization_id
      knt = knt + 1
      if (mod(knt,10) = 1 and knt != 1)
         stat = alterlist(prsnl_orgs->org,knt + 9)
      endif
      prsnl_orgs->org[knt].organization_id = por.organization_id
   foot report
      prsnl_orgs->org_knt = knt
      stat = alterlist(prsnl_orgs->org,knt)
   with nocounter
   set iErrCode = error(sErrMsg,1)
   if (iErrCode > 0)
      set failed = SELECT_ERROR
      set table_name = "PRSNL_ORG_RELTN"
      go to EXIT_SCRIPT
   endif
 
   if (network_var < 1)
      set failed = SELECT_ERROR
      set table_name = "CODE_VALUE"
      set sErrMsg = "Failed to find Code Value for CDF_MEANING NETWORK from Code Set 28881"
      go to EXIT_SCRIPT
   endif
 
   ;*** MOD 018 :: Use ORG_SET_TYPE_R to determine if Network Org
   set iErrCode = error(sErrMsg,1)
   set iErrCode = 0
   select into "nl:"
   from org_set_prsnl_r ospr
      ,org_set_type_r ostr
      ,org_set os
      ,org_set_org_r osor
   plan ospr
      where ospr.prsnl_id = reqinfo->updt_id
      and ospr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      and ospr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      and ospr.active_ind = TRUE
   join ostr
      where ostr.org_set_id = ospr.org_set_id
      and ostr.org_set_type_cd = network_var
      and ostr.active_ind = 1
      and ostr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      and ostr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   join os
      where os.org_set_id = ospr.org_set_id
   join osor
      where osor.org_set_id = os.org_set_id
      and osor.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      and osor.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      and osor.active_ind = TRUE
   head report
      knt = 0
      stat = alterlist(prsnl_orgs->org_set,10)
   head ospr.org_set_id
      knt = knt + 1
      if (mod(knt,10) = 1 and knt != 1)
         stat = alterlist(prsnl_orgs->org_set,knt + 9)
      endif
      prsnl_orgs->org_set[knt].org_set_id = ospr.org_set_id
      prsnl_orgs->org_set[knt].access_privs = os.org_set_attr_bit
      oknt = 0
      stat = alterlist(prsnl_orgs->org_set[knt].org_list,10)
   detail
      oknt = oknt + 1
      if (mod(oknt,10) = 1 and oknt != 1)
         stat = alterlist(prsnl_orgs->org_set[knt].org_list,oknt + 9)
      endif
      prsnl_orgs->org_set[knt].org_list[oknt].organization_id = osor.organization_id
   foot ospr.org_set_id
      prsnl_orgs->org_set[knt].org_list_knt = oknt
      stat = alterlist(prsnl_orgs->org_set[knt].org_list,oknt)
   foot report
      prsnl_orgs->org_set_knt = knt
      stat = alterlist(prsnl_orgs->org_set,knt)
   with nocounter
   set iErrCode = error(sErrMsg,1)
   if (iErrCode > 0)
      set failed = SELECT_ERROR
      set table_name = "PRSNL_ORG_RELTN"
      go to EXIT_SCRIPT
   endif
endif
;==============================================================================
 
if (bPersonOrgSecurityOn = TRUE)
 
;*** Person Org Security is on, load all allergies that will be later filter based
;*** on viewablity
 
call echo("*** allergy person org security on = TRUE ***")	;051
 
   free record temp_alg
   record temp_alg
   (
      1  qual_knt = i4
      1  qual[*]
         2  allergy_id = f8
         2  subst_name = vc
         2  organization_id = f8
         2  viewable_ind = i2
         2  adr_knt = i4
         2  adr[*]
            3  reltn_entity_name = vc
            3  reltn_entity_id = f8
   )
 
   set iErrCode = error(sErrMsg,1)
   set iErrCode = 0
   select into "nl:"
   from
      allergy a
      ,nomenclature n
   plan a
      where a.person_id = request->person_id
      and a.reaction_status_cd != canceled_allergy_cd
      and (a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            and a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   join n
      where n.nomenclature_id = a.substance_nom_id
   head report
      knt = 0
      stat = alterlist(temp_alg->qual,10)
   detail
      knt = knt + 1
      if (mod(knt,10) = 1 and knt != 1)
         stat = alterlist(temp_alg->qual,knt + 9)
      endif
      temp_alg->qual[knt].allergy_id = a.allergy_id
      temp_alg->qual[knt].organization_id = a.organization_id
      if (n.nomenclature_id < 1)
         temp_alg->qual[knt].subst_name = a.substance_ftdesc
      else
         temp_alg->qual[knt].subst_name = n.source_string
      endif
      if (a.organization_id = 0.0)  ;*** if the allergy is associated to org_id 0.0 then everybody can see it.
         temp_alg->qual[knt].viewable_ind = 1
      endif
   foot report
      temp_alg->qual_knt = knt
      stat = alterlist(temp_alg->qual,knt)
   with nocounter
   set iErrCode = error(sErrMsg,1)
   if (iErrCode > 0)
      set failed = SELECT_ERROR
      set table_name = "ALLERGY"
      go to EXIT_SCRIPT
   endif
 
   if (temp_alg->qual_knt > 0)
 
      ;*** Allergies have been found, we need to load the ADR data for the allergies
 
      set iErrCode = error(sErrMsg,1)
      set iErrCode = 0
      select into "nl:"
      from activity_data_reltn adr
      plan adr
         where expand(eidx,1,temp_alg->qual_knt,adr.activity_entity_id,temp_alg->qual[eidx].allergy_id)
         and adr.activity_entity_name = "ALLERGY"
      head adr.activity_entity_id
         fidx = 0
         fidx = locateval(fidx,1,temp_alg->qual_knt,adr.activity_entity_id,temp_alg->qual[eidx].allergy_id)
         if (fidx > 0)
            stat = alterlist(temp_alg->qual[fidx].adr,10)
         endif
         knt = 0
      detail
         if (fidx > 0)
            knt = knt + 1
            if (mod(knt,10) = 1 and knt != 1)
               stat = alterlist(temp_alg->qual[fidx].adr,knt + 9)
            endif
            temp_alg->qual[fidx].adr[knt].reltn_entity_name = adr.reltn_entity_name
            temp_alg->qual[fidx].adr[knt].reltn_entity_id = adr.reltn_entity_id
         endif
      foot adr.activity_entity_id
         temp_alg->qual[fidx].adr_knt = knt
         stat = alterlist(temp_alg->qual[fidx].adr,knt)
      with nocounter
      set iErrCode = error(sErrMsg,1)
      if (iErrCode > 0)
         set failed = SELECT_ERROR
         set table_name = "ACTIVITY_DATA_RELTN"
         go to EXIT_SCRIPT
      endif
 
      set viewable_knt = 0
      for (vidx = 1 to temp_alg->qual_knt)
 
         ;*** Cycle through the allergy list and determine what's viewable
         set continue = TRUE
         set oknt = 1
         while (continue = TRUE and oknt <= prsnl_orgs->org_knt and temp_alg->qual[vidx].viewable_ind < 1)
            ;*** Check to see if "direct" organization between allergy and prsnl exist
            if (temp_alg->qual[vidx].organization_id = prsnl_orgs->org[oknt].organization_id)
               set temp_alg->qual[vidx].viewable_ind = 1
               set continue = FALSE
            endif
            set oknt = oknt + 1
         endwhile
         if (temp_alg->qual[vidx].viewable_ind < 1)
            set osknt = 1
            set continue = TRUE
            while (continue = TRUE and osknt <= prsnl_orgs->org_set_knt)
               ;*** Check to see if the allergy organization is in the Org Set org list of the user
               set oknt = 1
               set access_granted = FALSE
               set access_granted = btest(prsnl_orgs->org_set[osknt].access_priv,algy_bit_pos)
               while (continue = TRUE and oknt <= prsnl_orgs->org_set[osknt].org_list_knt and access_granted = TRUE)
                  if (temp_alg->qual[vidx].organization_id = prsnl_orgs->org_set[osknt].org_list[oknt].organization_id)
                     set temp_alg->qual[vidx].viewable_ind = 1
                     set continue = FALSE
                  endif
                  set oknt = oknt + 1
               endwhile
               set osknt = osknt + 1
            endwhile
         endif
         if (temp_alg->qual[vidx].adr_knt > 0 and temp_alg->qual[vidx].viewable_ind < 1)
            for (ridx = 1 to temp_alg->qual[vidx].adr_knt)
               ;*** detemine if ADR orgs are related to user orgs
 
               set continue = TRUE
               set oknt = 1
               while (continue = TRUE and oknt <= prsnl_orgs->org_knt and temp_alg->qual[vidx].viewable_ind < 1)
                  ;*** Check to see if "direct" organization between adr and prsnl exist
                  if (temp_alg->qual[vidx].adr[ridx].reltn_entity_name = "ORGANIZATION" and
                      temp_alg->qual[vidx].adr[ridx].reltn_entity_id = prsnl_orgs->org[oknt].organization_id)
                     set temp_alg->qual[vidx].viewable_ind = 1
                     set continue = FALSE
                  endif
                  set oknt = oknt + 1
               endwhile
               if (temp_alg->qual[vidx].viewable_ind < 1)
                  set osknt = 1
                  set continue = TRUE
                  while (continue = TRUE and osknt <= prsnl_orgs->org_set_knt)
                     ;*** Check to see if "in-direct" organization between adr and prsnl org set org exist
                     set oknt = 1
                     set access_granted = FALSE
                     set access_granted = btest(prsnl_orgs->org_set[osknt].access_priv,algy_bit_pos)
                     while (continue = TRUE and oknt <= prsnl_orgs->org_set[osknt].org_list_knt and access_granted = TRUE)
                        if (temp_alg->qual[vidx].adr[ridx].reltn_entity_name = "ORGANIZATION" and
                            temp_alg->qual[vidx].adr[ridx].reltn_entity_id =
                            prsnl_orgs->org_set[osknt].org_list[oknt].organization_id)
                           set temp_alg->qual[vidx].viewable_ind = 2
                           set continue = FALSE
                        endif
                        set oknt = oknt + 1
                     endwhile
                     set osknt = osknt + 1
                  endwhile
               endif
            endfor
         endif
 
         if (temp_alg->qual[vidx].viewable_ind > 0)
            set viewable_knt = viewable_knt + 1
            if (viewable_knt = 1)
               set demo_info->allergy_line = trim(temp_alg->qual[vidx].subst_name)
            else
               set demo_info->allergy_line = concat(trim(demo_info->allergy_line),", ",trim(temp_alg->qual[vidx].subst_name))
            endif
         endif
      endfor
   endif
else  ;*** MOD 016 END
 
	call echo("*** Allergy Person Org Security Org On = FALSE ***") ;051
 
 
   set iErrCode = error(sErrMsg,1)
   set iErrCode = 0
 
   select into "nl:"
   from
    allergy a,
    nomenclature n
plan a where
    a.person_id = request->person_id and
    a.reaction_status_cd != canceled_allergy_cd and
    (a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
join n where
    n.nomenclature_id = a.substance_nom_id
 
head report
    knt = 0
detail
    knt = knt + 1
 
    if (knt = 1)
        if (n.nomenclature_id > 0)
            demo_info->allergy_line = trim(n.source_string)
        else
            demo_info->allergy_line = trim(a.substance_ftdesc)
        endif
    else
        if (n.nomenclature_id > 0)
            demo_info->allergy_line = concat(trim(demo_info->allergy_line),", ",
                trim(n.source_string))
        else
            demo_info->allergy_line = concat(trim(demo_info->allergy_line),", ",
                trim(a.substance_ftdesc))
        endif
    endif
with nocounter
 
   set iErrCode = error(sErrMsg,1)
   if (iErrCode > 0)
      set failed = SELECT_ERROR
      set table_name = "ALLERGY"
      go to EXIT_SCRIPT
   endif
 
endif
 
/****************************************************************************
*       parse allergy line                                                  *
*****************************************************************************/
call echo("*** parse allergy line ***") 	;051
 
free record pt
record pt
(
  1 line_cnt = i2
  1 lns[*]
    2 line   = vc
)
 
if (not(size(demo_info->allergy_line,1) > 0))     ;034
    set demo_info->allergy_knt = 1
    set stat = alterlist(demo_info->allergy,demo_info->allergy_knt)
    set demo_info->allergy[1]->disp = "No Allergy Information Has Been Recorded"
else
    set pt->line_cnt = 0
    set max_length   = 90
    execute dcp_parse_text value(demo_info->allergy_line), value(max_length)
    set demo_info->allergy_knt = pt->line_cnt
    set stat = alterlist(demo_info->allergy,demo_info->allergy_knt)
 
    for (c = 1 to pt->line_cnt)
        set demo_info->allergy[c]->disp = trim(pt->lns[c]->line)
    endfor
endif
 
/****************************************************************************
*       Load Order and Encounter Information                                *
*****************************************************************************/
call echo("*** load order and encounter information ***")	;051
 
free record temp_req
record temp_req
(
  1 qual_knt              = i4
  1 qual[*]
    2 order_id            = f8
    2 encntr_id           = f8
    2 facility            = vc ; ar051237
    2 facility_cd         = f8 ; ar051237
    2 facility_addr1      = vc ; ar051237
    2 facility_addr2      = vc ; ar051237
    2 facility_addr3      = vc ; ar051237
    2 facility_addr4      = vc ; ar051237
    2 d_nbr               = vc
    2 csa_schedule        = c1
    2 csa_group           = vc  ;*** C = 0 | A = 1,2 | B = 3,4,5
    2 mrn                 = vc
    2 finnbr              = vc 	;051
    2 found_emrn          = i2
    2 found_fin           = i2  ;051
    2 hp_pri_found        = i2
    2 hp_pri_name         = vc
    2 hp_pri_polgrp       = vc
    2 hp_sec_found        = i2
    2 hp_sec_name         = vc
    2 hp_sec_polgrp       = vc
    2 oe_format_id        = f8
    2 phys_id             = f8
    2 phys_name           = vc
    2 phys_fname          = vc
    2 phys_mname          = vc
    2 phys_lname          = vc
    2 phys_title          = vc
    2 phys_bname          = vc
    2 found_phys_addr_ind = i2
    2 phys_addr_id        = f8
    2 phys_addr1          = vc
    2 phys_addr2          = vc
    2 phys_addr3          = vc
    2 phys_addr4          = vc
    2 phys_city           = vc
    2 phys_dea            = vc
    2 phys_npi			  = vc ;028
    2 sup_phys_npi		  = vc ;028
    2 phys_lnbr           = vc
    2 phys_phone          = vc
    2 phys_fax            = vc ;ar051237
    2 eprsnl_ind          = i2
    2 eprsnl_id           = f8
    2 eprsnl_name         = vc
    2 eprsnl_fname        = vc
    2 eprsnl_mname        = vc
    2 eprsnl_lname        = vc
    2 eprsnl_title        = vc
    2 eprsnl_bname        = vc
    2 order_dt            = dq8
    2 output_dest_cd      = f8
    2 free_text_nbr       = vc
    2 print_loc           = vc
    2 no_print            = i2
    2 print_dea           = i2
    2 daw                 = i2
    2 start_date          = dq8
    2 req_start_date      = dq8
    2 perform_loc         = vc
    2 order_mnemonic      = vc
    2 order_as_mnemonic   = vc
    2 free_txt_ord        = vc
    2 med_name            = vc
    2 med_knt             = i4
    2 med[*]
      3 disp              = vc
    2 strength_dose       = vc
    2 strength_dose_unit  = vc
    2 volume_dose         = vc
    2 volume_dose_unit    = vc
    2 freetext_dose       = vc
    2 rx_route            = vc
    2 frequency           = vc
    2 duration            = vc
    2 duration_unit       = vc
    2 sig_line            = vc
    2 sig_knt             = i4
    2 sig[*]
      3 disp              = vc
    2 dispense_qty        = vc
    2 dispense_qty_unit   = vc
    2 dispense_line       = vc
    2 dispense_knt        = i4
    2 dispense[*]
      3 disp              = vc
    2 dispense_duration   = vc			;*** MOD 007
    2 dispense_duration_unit = vc		;*** MOD 007
    2 dispense_duration_line = vc		;*** MOD 007
    2 dispense_duration_knt  = i4		;*** MOD 007
    2 dispense_duration_qual[*]			;*** MOD 007
      3 disp              = vc			;*** MOD 007
    2 req_refill_date     = dq8
    2 nbr_refills_txt     = vc
    2 nbr_refills         = f8
    2 total_refills       = f8
    2 add_refills_txt     = vc          ;008
    2 add_refills         = f8          ;008
    2 refill_ind          = i2
    2 refill_line         = vc
    2 refill_knt          = i4
    2 refill[*]
      3 disp              = vc
    2 special_inst        = vc
    2 special_knt         = i4
    2 special[*]
      3 disp              = vc
    2 ICD10_Codes         = vc			;046
    2 ICD10_knt           = i4			;046
    2 ICD10[*]							;046
      3 disp              = vc      	;046
    2 prn_ind             = i2
    2 prn_inst            = vc
    2 prn_knt             = i4
    2 prn[*]
      3 disp              = vc
    2 indications         = vc
    2 indic_knt           = i4
    2 indic[*]
      3 disp              = vc
    2 get_comment_ind     = i2
    2 comments            = vc
    2 comment_knt         = i4
    2 comment[*]
      3 disp              = vc
    2 sup_phys_bname      = vc           ;012
    2 sup_phys_dea        = vc           ;012
    2 sup_phys_id         = f8           ;012
    2 action_type_cd	  = f8		     ;019
    2 frequency_cd        = f8           ;019
    2 action_dt_tm        = dq8          ;022
    2 orig_order_dt_tm    = dq8          ;022
    2 mnemonic_type_cd    = f8           ;030
    2 drug_form           = vc           ;032
    2 second_attempt_note = vc           ; complete message for second attempt printing of EPCS
    2 sec_att_msg_line_count = i4
    2 sec_att_msg_row[*]
      3 disp              = vc          ; each line of second_attempt_note split into multiple output lines
    2 routing_pharmacy_name = vc        ; Name of Pharmacy to which EPCS routing failed
	2 routing_dt_tm			= dq8
)
 
/****************************************************************************
*       get order data                                                      *
*****************************************************************************/
call echo("*** get order data ***")	;051
 
set eprsnl_ind = FALSE
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
select into "nl:"
    encntr_id = request->order_qual[d.seq]->encntr_id,
    oa.order_provider_id,
    o.order_id,
    cki_len = textlen(o.cki)
from
    (dummyt d with seq = value(size(request->order_qual,5))),
    orders o,
    order_action oa,
    prsnl p
plan d where
    d.seq > 0
join o where
    o.order_id = request->order_qual[d.seq]->order_id and
    o.encntr_id = request->order_qual[d.seq]->encntr_id and
    o.order_status_cd != medstudent_hold_cd ;027
join oa where
    oa.order_id = o.order_id and
    oa.action_sequence = o.last_action_sequence and
    (((oa.action_type_cd = order_cd or
       oa.action_type_cd = modify_cd or
       oa.action_type_cd = studactivate_cd or ;033
       oa.action_type_cd = activate_cd or												;MOD 036
       ((oa.action_type_cd = complete_cd or oa.action_type_cd = suspend_cd)				;MOD 036
        and oa.order_conversation_id =													;MOD 036
        	(select oap.order_conversation_id											;MOD 036
        	 from order_action oap														;MOD 036
        	 where oap.order_id = o.order_id and										;MOD 036
        	 	   oap.action_sequence = o.last_action_sequence-1						;MOD 036
        	 	   and oap.action_type_cd in (order_cd, studactivate_cd, activate_cd))	;MOD 036
       )) and
      (o.orig_ord_as_flag = 1)) or
     (is_a_reprint = TRUE))
join p where
    p.person_id = oa.order_provider_id
order
    o.order_id  ;MOD 011
 
head report
    knt = 0
    stat = alterlist(temp_req->qual,10)
    mnemonic_size = size(o.hna_order_mnemonic,3) - 1	;025
 
head o.order_id
    knt = knt + 1
    if (mod(knt,10) = 1 and knt != 1)
        stat = alterlist(temp_req->qual, knt + 9)
    endif
 
    temp_req->qual[knt]->order_id          = o.order_id
    temp_req->qual[knt]->encntr_id         = o.encntr_id
    temp_req->qual[knt]->oe_format_id      = o.oe_format_id
    temp_req->qual[knt]->phys_id           = oa.order_provider_id
    temp_req->qual[knt]->sup_phys_id       = oa.supervising_provider_id ;012
    temp_req->qual[knt]->eprsnl_id         = oa.action_personnel_id
    if (oa.order_provider_id != oa.action_personnel_id)
      temp_req->qual[knt]->eprsnl_ind = TRUE
      eprsnl_ind = TRUE
    endif
    temp_req->qual[knt]->phys_name         = trim(p.name_full_formatted)
    temp_req->qual[knt]->order_dt          = cnvtdatetime(cnvtdate(oa.action_dt_tm),0)
    temp_req->qual[knt]->print_loc         = request->printer_name
 
	;BEGIN 025
	mnem_length = size(trim(o.hna_order_mnemonic),1)
    if (mnem_length >= mnemonic_size
    	and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
    	temp_req->qual[knt]->order_mnemonic = concat(trim(o.hna_order_mnemonic), "...")
    else
    	temp_req->qual[knt]->order_mnemonic = o.hna_order_mnemonic
    endif
 
 	mnem_length = size(trim(o.ordered_as_mnemonic),1)
    if (mnem_length >= mnemonic_size
    	and SUBSTRING(mnem_length - 3, mnem_length, o.hna_order_mnemonic) != "...")
    	temp_req->qual[knt]->order_as_mnemonic = concat(trim(o.ordered_as_mnemonic), "...")
    else
    	temp_req->qual[knt]->order_as_mnemonic = o.ordered_as_mnemonic
    endif
	;END 025
 
    temp_req->qual[knt]->action_type_cd    = oa.action_type_cd     ;019
    temp_req->qual[knt]->action_dt_tm      = oa.action_dt_tm       ;022
    temp_req->qual[knt]->orig_order_dt_tm  = o.orig_order_dt_tm    ;022
    if (band(o.comment_type_mask,1) = 1)
        temp_req->qual[knt]->get_comment_ind = TRUE
    endif
 
    d_pos = findstring("!d",o.cki)
    if (d_pos > 0)
        temp_req->qual[knt]->d_nbr = trim(substring(d_pos + 1, cki_len, o.cki))
    endif
 
foot report
    temp_req->qual_knt = knt
    stat = alterlist(temp_req->qual,knt)
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "ORDER_INFO"
    go to EXIT_SCRIPT
endif
 
if (temp_req->qual_knt < 1)
    call echo ("***")
    call echo ("***   No items found to print")
    call echo ("***")
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get ICD10 Data                                                      *
*****************************************************************************/
call echo("*** get ICD10 Data ***")	;051
;046
set eprsnl_ind = FALSE
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
select into "nl:"
    encntr_id = request->order_qual[d.seq]->encntr_id,
    o.order_id,
    diag.diagnosis_display,
    nom.source_string,
    nom.source_identifier
from
    (dummyt d with seq = value(size(request->order_qual,5))),
    orders o,
	diagnosis diag,
	nomenclature nom,
	nomen_entity_reltn ner
plan d where
    d.seq > 0
join o where
    o.order_id = request->order_qual[d.seq]->order_id and
    o.encntr_id = request->order_qual[d.seq]->encntr_id and
    o.order_status_cd != medstudent_hold_cd
join diag where
	o.encntr_id = diag.encntr_id and
	diag.active_ind = 1
join nom where
	diag.nomenclature_id = nom.nomenclature_id
join ner where
    nom.nomenclature_id = ner.nomenclature_id	and
    o.encntr_id = ner.encntr_id and
    ner.active_ind = 1 and
    ner.reltn_type_cd = 639177.00 and   ;Diagnosis to Order - Code Set 23549
    o.person_id = ner.person_id and
    o.order_id = ner.parent_entity_id
order
    o.order_id
 
head report
    knt = 0
 
detail
    knt = knt + 1
 
    if (knt = 1)
    	temp_req->qual[d.seq]->ICD10_Codes = concat(trim(nom.source_identifier),
    		" (", trim(diag.diagnosis_display),")")
    elseif (knt > 1)
    	temp_req->qual[d.seq]->ICD10_Codes = concat(temp_req->qual[d.seq]->ICD10_Codes,
    		", ", trim(nom.source_identifier), " (", trim(diag.diagnosis_display),")")
    endif
 
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "ICD10_INFO"
    go to EXIT_SCRIPT
endif
 
if (temp_req->qual_knt < 1)
    call echo ("***")
    call echo ("***   No items found to print")
    call echo ("***")
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get phys title                                                      *
*****************************************************************************/
call echo("*** get phys title ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
select into "nl:"
from (dummyt d with seq = value(temp_req->qual_knt))
   ,person_name p
plan d
   where d.seq > 0
join p
   where (p.person_id = temp_req->qual[d.seq].phys_id or
          p.person_id = temp_req->qual[d.seq].sup_phys_id) ;012
   and p.person_id > 0                                     ;012
   and p.name_type_cd = prsnl_type_cd
   and p.active_ind = TRUE
   and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
detail
    if (p.person_id = temp_req->qual[d.seq].phys_id)
	    temp_req->qual[d.seq]->phys_fname = trim(p.name_first)
	    temp_req->qual[d.seq]->phys_mname = trim(p.name_middle)
	    temp_req->qual[d.seq]->phys_lname = trim(p.name_last)
	    temp_req->qual[d.seq]->phys_title = trim(p.name_title)
	    if (size(p.name_first,1) > 0)     ;034
	        temp_req->qual[d.seq]->phys_bname = trim(p.name_first)
	        if (size(p.name_middle,1) > 0)     ;034
	            temp_req->qual[d.seq]->phys_bname = concat(trim(temp_req->qual[d.seq]->phys_bname)," ",trim(p.name_middle))
	            if (size(p.name_last,1) > 0)     ;034
	                temp_req->qual[d.seq]->phys_bname = concat(trim(temp_req->qual[d.seq]->phys_bname)," ",trim(p.name_last))
	            endif
	        elseif (size(p.name_last,1) > 0)     ;034
	            temp_req->qual[d.seq]->phys_bname = concat(trim(temp_req->qual[d.seq]->phys_bname)," ",trim(p.name_last))
	        endif
	    elseif (size(p.name_middle,1) > 0)     ;034
	        temp_req->qual[d.seq]->phys_bname = trim(p.name_middle)
	        if (size(p.name_last,1) > 0)     ;034
	            temp_req->qual[d.seq]->phys_bname = concat(trim(temp_req->qual[d.seq]->phys_bname)," ",trim(p.name_last))
	        endif
	    elseif (size(p.name_last,1) > 0)     ;034
	        temp_req->qual[d.seq]->phys_bname = concat(trim(temp_req->qual[d.seq]->phys_bname)," ",trim(p.name_last))
	    else
	        temp_req->qual[d.seq]->phys_bname = temp_req->qual[d.seq]->phys_name
	    endif
	    if (size(temp_req->qual[d.seq]->phys_bname,1) > 0 and size(p.name_title,1) > 0)     ;034
	        temp_req->qual[d.seq]->phys_bname = concat(trim(temp_req->qual[d.seq]->phys_bname),", ",trim(p.name_title))
	    endif
    ;Mod 012 Start- Added the if/else to write the supervising physician name
    else
	    if (size(p.name_first,1) > 0)     ;034
	        temp_req->qual[d.seq]->sup_phys_bname = trim(p.name_first)
	        if (size(p.name_middle,1) > 0)     ;034
	            temp_req->qual[d.seq]->sup_phys_bname = concat(trim(temp_req->qual[d.seq]->sup_phys_bname)," ",trim(p.name_middle))
	            if (size(p.name_last,1) > 0)     ;034
	                temp_req->qual[d.seq]->sup_phys_bname = concat(trim(temp_req->qual[d.seq]->sup_phys_bname)," ",trim(p.name_last))
	            endif
	        elseif (size(p.name_last,1) > 0)     ;034
	            temp_req->qual[d.seq]->sup_phys_bname = concat(trim(temp_req->qual[d.seq]->sup_phys_bname)," ",trim(p.name_last))
	        endif
	    elseif (size(p.name_middle,1) > 0)     ;034
	        temp_req->qual[d.seq]->sup_phys_bname = trim(p.name_middle)
	        if (size(p.name_last,1) > 0)     ;034
	            temp_req->qual[d.seq]->sup_phys_bname = concat(trim(temp_req->qual[d.seq]->sup_phys_bname)," ",trim(p.name_last))
	        endif
	    elseif (size(p.name_last,1) > 0)     ;034
	        temp_req->qual[d.seq]->sup_phys_bname = concat(trim(temp_req->qual[d.seq]->sup_phys_bname)," ",trim(p.name_last))
	    else
	        temp_req->qual[d.seq]->sup_phys_bname = temp_req->qual[d.seq]->phys_name
	    endif
	    if (size(temp_req->qual[d.seq]->sup_phys_bname,1) > 0 and size(p.name_title,1) > 0)     ;034
	        temp_req->qual[d.seq]->sup_phys_bname = concat(trim(temp_req->qual[d.seq]->sup_phys_bname),", ",trim(p.name_title))
	    endif
	endif
    ;Mod 012 End
with nocounter
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "PERSON_NAME"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get Eprsnl Title                                                    *
*****************************************************************************/
call echo("*** get Eprsnl Title ***")		;051
 
if (eprsnl_ind = TRUE)
   set iErrCode = error(sErrMsg,1)
   set iErrCode = 0
   select into "nl:"
   from (dummyt d with seq = value(temp_req->qual_knt))
      ,person_name p
   plan d
      where d.seq > 0
      and temp_req->qual[d.seq].eprsnl_ind = TRUE
   join p
      where p.person_id = temp_req->qual[d.seq].eprsnl_id
      and p.name_type_cd = prsnl_type_cd
      and p.active_ind = TRUE
      and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   detail
      temp_req->qual[d.seq]->eprsnl_name = trim(p.name_full)
      temp_req->qual[d.seq]->eprsnl_fname = trim(p.name_first)
      temp_req->qual[d.seq]->eprsnl_mname = trim(p.name_middle)
      temp_req->qual[d.seq]->eprsnl_lname = trim(p.name_last)
      temp_req->qual[d.seq]->eprsnl_title = trim(p.name_title)
      if (size(p.name_first,1) > 0)     ;034
         temp_req->qual[d.seq]->eprsnl_bname = trim(p.name_first)
         if (size(p.name_middle,1) > 0)     ;034
               temp_req->qual[d.seq]->eprsnl_bname = concat(trim(temp_req->qual[d.seq]->eprsnl_bname)," ",trim(p.name_middle))
               if (size(p.name_last,1) > 0)     ;034
                  temp_req->qual[d.seq]->eprsnl_bname = concat(trim(temp_req->qual[d.seq]->eprsnl_bname)," ",trim(p.name_last))
               endif
         elseif (size(p.name_last,1) > 0)     ;034
               temp_req->qual[d.seq]->eprsnl_bname = concat(trim(temp_req->qual[d.seq]->eprsnl_bname)," ",trim(p.name_last))
         endif
      elseif (size(p.name_middle,1) > 0)     ;034
         temp_req->qual[d.seq]->eprsnl_bname = trim(p.name_middle)
         if (size(p.name_last,1) > 0)     ;034
               temp_req->qual[d.seq]->eprsnl_bname = concat(trim(temp_req->qual[d.seq]->eprsnl_bname)," ",trim(p.name_last))
         endif
      elseif (size(p.name_last,1) > 0)     ;034
         temp_req->qual[d.seq]->eprsnl_bname = concat(trim(temp_req->qual[d.seq]->eprsnl_bname)," ",trim(p.name_last))
      else
         temp_req->qual[d.seq]->eprsnl_bname = temp_req->qual[d.seq]->eprsnl_name
      endif
      if (size(temp_req->qual[d.seq]->eprsnl_bname,1) > 0 and size(p.name_title,1) > 0)     ;034
         temp_req->qual[d.seq]->eprsnl_bname = concat(trim(temp_req->qual[d.seq]->eprsnl_bname),", ",trim(p.name_title))
      endif
   with nocounter
   set iErrCode = error(sErrMsg,1)
   if (iErrCode > 0)
      set failed = SELECT_ERROR
      set table_name = "EPRSNL_NAME"
      go to EXIT_SCRIPT
   endif
endif
 
/****************************************************************************
*        Find Multum Table                                                  *
*****************************************************************************/
call echo("*** Find Multum Table ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    dba_tables d
plan d where
    d.table_name = "MLTM_NDC_MAIN_DRUG_CODE" and
    d.owner = "V500"
detail
    use_pco = TRUE
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "DBA_TABLES"
    go to EXIT_SCRIPT
endif
 
if (use_pco = FALSE)
    set iErrCode = error(sErrMsg,1)
    set iErrCode = 0
 
    select into "nl:"
    from
        dba_tables d
    plan d where
        d.table_name = "NDC_MAIN_MULTUM_DRUG_CODE" and
        d.owner = "V500"
    detail
        v500_ind = TRUE
    with nocounter
    set iErrCode = error(sErrMsg,1)
    if (iErrCode > 0)
        set failed = SELECT_ERROR
        set table_name = "DBA_TABLES"
        go to EXIT_SCRIPT
    endif
endif
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
set non_blank_nbr = TRUE                                                    ;008
set mltm_loaded   = FALSE                                                   ;008
 
if (use_pco = TRUE)
    select into "nl:"
    from
        (dummyt d with seq = value(temp_req->qual_knt)),
        mltm_ndc_main_drug_code n
    plan d where
        d.seq > 0 ;and
        ;size(temp_req->qual[d.seq]->d_nbr,1) > 0     ;034          ;008
    join n where
        n.drug_identifier = temp_req->qual[d.seq]->d_nbr
    order
        d.seq,
        n.csa_schedule
 
    head d.seq
        if (size(temp_req->qual[d.seq]->d_nbr,1) > 0)     ;034      ;008
            mltm_loaded = TRUE                                              ;008
            non_blank_nbr = FALSE                                           ;008
        endif                                                               ;008
        temp_req->qual[d.seq]->csa_schedule = n.csa_schedule
        if (n.csa_schedule = "1" or n.csa_schedule = "2")
            temp_req->qual[d.seq]->csa_group = "A"
        elseif (temp_req->qual[d.seq]->d_nbr <= " ")                        ;010
            temp_req->qual[d.seq]->csa_schedule = "0"                       ;010
            csa_group_cnt = csa_group_cnt + 1                               ;010
            temp_req->qual[d.seq]->csa_group = concat("D",                  ;010
                trim(cnvtstring(csa_group_cnt)))                            ;010
        elseif (n.csa_schedule = "0")
        	temp_req->qual[d.seq]->csa_group = "C"
        else
            temp_req->qual[d.seq]->csa_group = "B"
        endif
    with outerjoin = d, nocounter                                           ;010
 
    set iErrCode = error(sErrMsg,1)
    if ((iErrCode > 0 or mltm_loaded = FALSE) and non_blank_nbr = FALSE)    ;008
        set failed = SELECT_ERROR
        set table_name = "MLTM_CSA_SCHEDULE"
        if (mltm_loaded = FALSE)
            set sErrMsg = "Table is Empty"
        endif
        go to EXIT_SCRIPT
    endif
elseif (v500_ind = TRUE)
    select into "nl:"
    from
        (dummyt d with seq = value(temp_req->qual_knt)),
        ndc_main_multum_drug_code n
    plan d where
        d.seq > 0 ;and
        ;size(temp_req->qual[d.seq]->d_nbr,1) > 0     ;034          ;008
    join n where
        n.drug_identifier = temp_req->qual[d.seq]->d_nbr
    order
        d.seq,
        n.csa_schedule
    head d.seq
        if (size(temp_req->qual[d.seq]->d_nbr,1) > 0)     ;034      ;008
            mltm_loaded = TRUE                                              ;008
            non_blank_nbr = FALSE                                           ;008
        endif                                                               ;008
        temp_req->qual[d.seq]->csa_schedule = n.csa_schedule
        if (n.csa_schedule = "1" or n.csa_schedule = "2")
            temp_req->qual[d.seq]->csa_group = "A"
        elseif (temp_req->qual[d.seq]->d_nbr <= " ")                        ;010
            temp_req->qual[d.seq]->csa_schedule = "0"                       ;010
            csa_group_cnt = csa_group_cnt + 1                               ;010
            temp_req->qual[d.seq]->csa_group = concat("D",                  ;010
                trim(cnvtstring(csa_group_cnt)))                            ;010
        elseif (n.csa_schedule = "0")
        	temp_req->qual[d.seq]->csa_group = "C"
        else
            temp_req->qual[d.seq]->csa_group = "B"
        endif
    with outerjoin = d, nocounter                                           ;010
 
    set iErrCode = error(sErrMsg,1)
    if ((iErrCode > 0 or mltm_loaded = FALSE) and non_blank_nbr = FALSE)    ;008
        set failed = SELECT_ERROR
        set table_name = "CSA_SCHEDULE"
        if (mltm_loaded = FALSE)
            set sErrMsg = "Table is Empty"
        endif
        go to EXIT_SCRIPT
    endif
else
    select into "nl:"
    from
        (dummyt d with seq = value(temp_req->qual_knt)),
        v500_ref.ndc_main_multum_drug_code n
    plan d where
        d.seq > 0 ;and
        ;size(temp_req->qual[d.seq]->d_nbr,1) > 0     ;034          ;008
    join n where
        n.drug_id = temp_req->qual[d.seq]->d_nbr
    order
        d.seq,
        n.csa_schedule
    head d.seq
        if (size(temp_req->qual[d.seq]->d_nbr,1) > 0)    ;034       ;008
            mltm_loaded = TRUE                                              ;008
            non_blank_nbr = FALSE                                           ;008
        endif                                                               ;008
        temp_req->qual[d.seq]->csa_schedule = n.csa_schedule
        if (n.csa_schedule = "1" or n.csa_schedule = "2")
            temp_req->qual[d.seq]->csa_group = "A"
        elseif (temp_req->qual[d.seq]->d_nbr <= " ")                        ;010
            temp_req->qual[d.seq]->csa_schedule = "0"                       ;010
            csa_group_cnt = csa_group_cnt + 1                               ;010
            temp_req->qual[d.seq]->csa_group = concat("D",                  ;010
                trim(cnvtstring(csa_group_cnt)))                            ;010
        elseif (n.csa_schedule = "0")
        	temp_req->qual[d.seq]->csa_group = "C"
        else
            temp_req->qual[d.seq]->csa_group = "B"
        endif
    with outerjoin = d, nocounter
 
    set iErrCode = error(sErrMsg,1)
    if ((iErrCode > 0 or mltm_loaded = FALSE) and non_blank_nbr = FALSE)    ;008
        set failed = SELECT_ERROR
        set table_name = "V500_CSA_SCHEDULE"
        if (mltm_loaded = FALSE)
            set sErrMsg = "Table is Empty"
        endif
        go to EXIT_SCRIPT
    endif
endif
 
/****************************************************************************
*       get order detail                                                    *
*****************************************************************************/
call echo("*** get order detail ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    order_detail od,
    oe_format_fields oef,
    (dummyt d1 with seq = value(temp_req->qual_knt))
plan d1 where
    d1.seq > 0
join od where
    od.order_id = temp_req->qual[d1.seq]->order_id
join oef where
    oef.oe_format_id = temp_req->qual[d1.seq]->oe_format_id and
    oef.oe_field_id = od.oe_field_id
order
    od.order_id,
    oef.group_seq,
    oef.field_seq,
    od.oe_field_id,
    od.action_sequence desc
 
head od.oe_field_id
    act_seq = od.action_sequence
    odflag = TRUE
 
head od.action_sequence
    if (act_seq != od.action_sequence)
        odflag = FALSE
    endif
 
detail
    if (odflag = TRUE)
        if (od.oe_field_meaning_id = 2107)
            temp_req->qual[d1.seq]->print_dea = od.oe_field_value
 
        elseif (od.oe_field_meaning_id = 2056)
            temp_req->qual[d1.seq]->strength_dose = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2057)
            temp_req->qual[d1.seq]->strength_dose_unit = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2058)
            temp_req->qual[d1.seq]->volume_dose = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2059)
            temp_req->qual[d1.seq]->volume_dose_unit = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2063)
            temp_req->qual[d1.seq]->freetext_dose = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2050)
            temp_req->qual[d1.seq]->rx_route = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2011)
            temp_req->qual[d1.seq]->frequency = trim(od.oe_field_display_value,3)     ;034
            temp_req->qual[d1.seq]->frequency_cd = od.oe_field_value	;019
 
        elseif (od.oe_field_meaning_id = 2061)
            temp_req->qual[d1.seq]->duration = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2062)
            temp_req->qual[d1.seq]->duration_unit = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2015)
            temp_req->qual[d1.seq]->dispense_qty = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2102)
            temp_req->qual[d1.seq]->dispense_qty_unit = trim(od.oe_field_display_value,3)     ;034
 
        ;BEGIN MOD 007
        elseif ((od.oe_field_meaning_id = 2290) and (od.oe_field_value > 0))
            temp_req->qual[d1.seq]->dispense_duration = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2291)
            temp_req->qual[d1.seq]->dispense_duration_unit = trim(od.oe_field_display_value,3)     ;034
        ;END MOD 007
 
        elseif (od.oe_field_meaning_id = 67)
            temp_req->qual[d1.seq]->nbr_refills_txt = trim(od.oe_field_display_value,3)     ;034
            temp_req->qual[d1.seq]->nbr_refills     = od.oe_field_value
 
        elseif (od.oe_field_meaning_id = 2101)
            temp_req->qual[d1.seq]->prn_inst = trim(od.oe_field_display_value,3)     ;034
            temp_req->qual[d1.seq]->prn_ind = 1
 
        elseif (od.oe_field_meaning_id = 1103)
            temp_req->qual[d1.seq]->special_inst = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 15)
            temp_req->qual[d1.seq]->indications = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2017)
            temp_req->qual[d1.seq]->daw = od.oe_field_value
 
        elseif (od.oe_field_meaning_id = 18)
            temp_req->qual[d1.seq]->perform_loc = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 2108)
            temp_req->qual[d1.seq]->phys_addr_id = od.oe_field_value
 
        elseif (od.oe_field_meaning_id = 1)
            temp_req->qual[d1.seq]->free_txt_ord = trim(od.oe_field_display_value,3)     ;034
 
        elseif (od.oe_field_meaning_id = 1560)
            temp_req->qual[d1.seq]->req_refill_date = od.oe_field_dt_tm_value
 
        elseif (od.oe_field_meaning_id IN (51,3551))  ;0054  ; 3551 = EARLIESTFILLDATE  ;51 = REQSTARTDTTM
            IF (od.oe_field_meaning_id = 3551) temp_req->qual[d1.seq]->req_start_date = od.oe_field_dt_tm_value
            ELSE temp_req->qual[d1.seq]->req_start_date = od.oe_field_dt_tm_value
            ENDIF
 
        elseif (od.oe_field_meaning_id = 1558)
            temp_req->qual[d1.seq]->total_refills = od.oe_field_value
 
        elseif (od.oe_field_meaning_id = 1557 and od.oe_field_value > 0)              ;008
            ;014 temp_req->qual[d1.seq]->add_refills_txt = trim(od.oe_field_display_value,3) ;008     ;034
            temp_req->qual[d1.seq]->add_refills_txt = trim(cnvtstring(od.oe_field_value-1),3) ;014     ;034
            ;014 temp_req->qual[d1.seq]->add_refills = od.oe_field_value                   ;008
            temp_req->qual[d1.seq]->add_refills = od.oe_field_value - 1               ;014
            temp_req->qual[d1.seq]->refill_ind = TRUE
 
        elseif (od.oe_field_meaning_id = 2105 and od.oe_field_value > 0 and not(is_a_reprint))  ;*** MOD 002
            temp_req->qual[d1.seq]->no_print = TRUE
 
        elseif (od.oe_field_meaning_id = 138 and
                is_a_reprint = FALSE and
                temp_req->qual[d1.seq]->csa_group != "A")  ;*** ORDEROUTPUTDEST
            temp_req->qual[d1.seq]->output_dest_cd = od.oe_field_value
 
        elseif (od.oe_field_meaning_id = 139 and
                is_a_reprint = FALSE and
                temp_req->qual[d1.seq]->csa_group != "A")  ;*** FREETEXTORDERFAXNUMBER
            temp_req->qual[d1.seq]->free_text_nbr = trim(od.oe_field_display_value,3)     ;034
 
        ;032 Start Drug Form detail
        elseif (od.oe_field_meaning_id = 2014)
            temp_req->qual[d1.seq]->drug_form = trim(od.oe_field_display_value,3)     ;034
        ;032 end
 
        endif
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "ORDER_DETAIL"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get order Frequency Description                                     *
*****************************************************************************/
call echo("*** get order Frequency Description ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    order_detail od,
    code_value cv1,
    (dummyt d1 with seq = value(temp_req->qual_knt))
plan d1 where
    d1.seq > 0
join od where
    od.order_id = temp_req->qual[d1.seq]->order_id
join cv1 where
	cv1.code_value = od.oe_field_value
order
    od.order_id,
    od.oe_field_id,
    od.action_sequence desc
 
head od.oe_field_id
    act_seq = od.action_sequence
    odflag = TRUE
 
head od.action_sequence
    if (act_seq != od.action_sequence)
        odflag = FALSE
    endif
 
detail
    if (odflag = TRUE)
        if (od.oe_field_meaning_id = 2011)
            ;temp_req->qual[d1.seq]->frequency = trim(od.oe_field_display_value,3)     ;034
            temp_req->qual[d1.seq]->frequency = trim(cv1.description,3)	;046
            temp_req->qual[d1.seq]->frequency_cd = od.oe_field_value	;019
        endif
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "ORDER_DETAIL_FREQUENCY"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       get order comments                                                  *
*****************************************************************************/
call echo("*** get order comments ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    order_comment oc,
    long_text lt
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->get_comment_ind = TRUE
join oc where
    oc.order_id = temp_req->qual[d.seq]->order_id and
    oc.comment_type_cd = ord_comment_cd
join lt where
    lt.long_text_id = oc.long_text_id
order
    oc.order_id,
    oc.action_sequence desc
 
head oc.order_id
    found_comment = FALSE
 
detail
    if (found_comment = FALSE)
        found_comment = TRUE
        temp_req->qual[d.seq]->comments = lt.long_text
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "ORDER_DETAIL"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       find mrn by encntr_id                                           *
*****************************************************************************/
call echo("*** find mrn by encntr_id ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    ea.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    encntr_alias ea
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->encntr_id > 0
join ea where
    ea.encntr_id = temp_req->qual[d.seq]->encntr_id and
    ea.encntr_alias_type_cd = emrn_cd and
    (ea.active_ind = TRUE and
     ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
order
    ;ea.beg_effective_dt_tm desc
    d.seq  ;MOD 008
 
head d.seq
    temp_req->qual[d.seq]->found_emrn = TRUE
    if (ea.alias_pool_cd > 0)
        temp_req->qual[d.seq]->mrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
    else
        temp_req->qual[d.seq]->mrn = trim(ea.alias)
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "LOAD_EMRN"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       find FIN NBR by encntr_id                                           *
*****************************************************************************/
call echo("*** find fin nbr by encntr_id ***")	;051
 
;051 start
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    ea.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    encntr_alias ea
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->encntr_id > 0
join ea where
    ea.encntr_id = temp_req->qual[d.seq]->encntr_id and
    ea.encntr_alias_type_cd = finnbr_cd and
    (ea.active_ind = TRUE and
     ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
order
    ;ea.beg_effective_dt_tm desc
    d.seq  ;MOD 008
 
head d.seq
    temp_req->qual[d.seq]->found_fin = TRUE
    if (ea.alias_pool_cd > 0)
        temp_req->qual[d.seq]->finnbr = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
    else
        temp_req->qual[d.seq]->finnbr = trim(ea.alias)
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "LOAD_FINNBR"
    go to EXIT_SCRIPT
endif
;051 end
 
/****************************************************************************
*       get MRN by person_id                                               *
*****************************************************************************/
call echo("*** get MRN by person_id ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    pa.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    person_alias pa
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->found_emrn = FALSE
join pa where
    pa.person_id = request->person_id and
    pa.person_alias_type_cd = pmrn_cd and
    (pa.active_ind = TRUE and
     pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
order
    ;pa.beg_effective_dt_tm desc
    d.seq   ;MOD 011
 
head d.seq
    temp_req->qual[d.seq]->found_emrn = TRUE
 
    if (pa.alias_pool_cd > 0)
        temp_req->qual[d.seq]->mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    else
        temp_req->qual[d.seq]->mrn = trim(pa.alias)
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "LOAD_PMRN"
    go to EXIT_SCRIPT
endif
 
 
/****************************************************************************
*       find physician address by addr_id                                   *
*****************************************************************************/
call echo("*** find physician address by addr_id ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    address a
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->no_print = FALSE and
    temp_req->qual[d.seq]->phys_addr_id > 0
join a where
    a.address_id = temp_req->qual[d.seq]->phys_addr_id
order
    d.seq   ;MOD 011
 
head d.seq
    temp_req->qual[d.seq]->found_phys_addr_ind = TRUE
    temp_req->qual[d.seq]->phys_addr1 = trim(a.street_addr)
 
    if (size(a.street_addr2,1) > 0)     ;034
        temp_req->qual[d.seq]->phys_addr2 = trim(a.street_addr2)
    endif
 
    if (size(a.street_addr3,1) > 0)     ;034
        temp_req->qual[d.seq]->phys_addr3 = trim(a.street_addr3)
    endif
 
    if (size(a.street_addr4,1) > 0)     ;034
        temp_req->qual[d.seq]->phys_addr4 = trim(a.street_addr4)
    endif
 
    if (size(a.city,1) > 0)     ;034
        temp_req->qual[d.seq]->phys_city = trim(a.city)
    endif
 
    if (size(a.state,1) > 0 or a.state_cd > 0)     ;034
        if (size(temp_req->qual[d.seq]->phys_city,1) > 0)     ;034
            if (a.state_cd > 0)
                temp_req->qual[d.seq]->phys_city = concat(trim(temp_req->qual[d.seq]->
                    phys_city),", ",trim(uar_get_code_display(a.state_cd)))
            else
                temp_req->qual[d.seq]->phys_city = concat(trim(temp_req->qual[d.seq]->
                    phys_city),", ",trim(a.state))
            endif
        else
            if (a.state_cd > 0)
                temp_req->qual[d.seq]->phys_city = trim(uar_get_code_display(a.state_cd))
            else
                temp_req->qual[d.seq]->phys_city = trim(a.state)
            endif
        endif
    endif
 
    if (size(a.zipcode,1) > 0)     ;034
        if (size(temp_req->qual[d.seq]->phys_city,1) > 0)     ;034
            temp_req->qual[d.seq]->phys_city = concat(trim(temp_req->qual[d.seq]->phys_city),
                " ",trim(a.zipcode))
        else
            temp_req->qual[d.seq]->phys_city = trim(a.zipcode)
        endif
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "PHYS_ADDR1"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       find dea and npi number                                             *
*****************************************************************************/
call echo("*** find dea and npi number ***")	;051
 
;*** find dea number
;*** find npi number ;028
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    pa.prsnl_alias_type_cd,
    pa.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    prsnl_alias pa
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->no_print = FALSE and
    temp_req->qual[d.seq]->phys_id > 0
join pa where
    pa.person_id > 0 and                                    ;012
    pa.person_id in (temp_req->qual[d.seq]->phys_id,temp_req->qual[d.seq]->sup_phys_id) and
    pa.prsnl_alias_type_cd in (docdea_cd,docnpi_cd) and		;028
    (pa.active_ind = TRUE and
     pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
order
    d.seq,
    pa.prsnl_alias_type_cd,
    pa.person_id,
    pa.beg_effective_dt_tm desc
 
;head report           ***MOD 012
;    found_dea = FALSE ***MOD 012
 
head d.seq
    found_dea = FALSE
    found_dea_sup = FALSE ;012
 
head pa.prsnl_alias_type_cd ;029
    found_npi = FALSE		;028
    found_npi_sup = FALSE 	;028
 
head pa.person_id
    if (found_dea = FALSE and pa.prsnl_alias_type_cd = docdea_cd and pa.person_id=temp_req->qual[d.seq]->phys_id)   ;012
        found_dea = TRUE
 
        if (pa.alias_pool_cd > 0)
            temp_req->qual[d.seq]->phys_dea = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
        else
            temp_req->qual[d.seq]->phys_dea = trim(pa.alias)
        endif
    endif
 
    ;MOD 012 Start - Added in order to get the dea for the supervising physician
 
    if (found_dea_sup = FALSE and pa.prsnl_alias_type_cd = docdea_cd and pa.person_id=temp_req->qual[d.seq]->sup_phys_id)
        found_dea_sup = TRUE
 
        if (pa.alias_pool_cd > 0)
            temp_req->qual[d.seq]->sup_phys_dea = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
        else
            temp_req->qual[d.seq]->sup_phys_dea = trim(pa.alias)
        endif
    endif
    ;MOD 012 Stop
 
    /*** start 028 ***/
    if (found_npi = FALSE and pa.prsnl_alias_type_cd = docnpi_cd and pa.person_id=temp_req->qual[d.seq]->phys_id)
        found_npi = TRUE
		if (pa.alias_pool_cd > 0)
			temp_req->qual[d.seq]->phys_npi = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
		else
			temp_req->qual[d.seq]->phys_npi = trim(pa.alias)
		endif
	endif
 
	if (found_npi_sup = FALSE and pa.prsnl_alias_type_cd = docnpi_cd and pa.person_id=temp_req->qual[d.seq]->sup_phys_id)
        found_npi_sup = TRUE
		if (pa.alias_pool_cd > 0)
			temp_req->qual[d.seq]->sup_phys_npi = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
		else
			temp_req->qual[d.seq]->sup_phys_npi = trim(pa.alias)
		endif
	endif
 	/*** end 028 ***/
 
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "PHYS_DEA"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       find physician address by phys_id                                   *
*****************************************************************************/
call echo("*** find physician address by phys_id ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    a.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    address a
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->no_print = FALSE and
    temp_req->qual[d.seq]->found_phys_addr_ind = FALSE and
    temp_req->qual[d.seq]->phys_id > 0
join a where
    a.parent_entity_id = temp_req->qual[d.seq]->phys_id and
    a.parent_entity_name in ("PERSON","PRSNL") and
    a.address_type_cd = work_add_cd and
    (a.active_ind = 1 and
     a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
order
    d.seq,
    a.beg_effective_dt_tm desc
 
head d.seq
    if (temp_req->qual[d.seq]->found_phys_addr_ind = FALSE)
 
        temp_req->qual[d.seq]->phys_addr_id        = a.address_id
        temp_req->qual[d.seq]->found_phys_addr_ind = TRUE
        temp_req->qual[d.seq]->phys_addr1          = trim(a.street_addr)
 
        if (size(a.street_addr2,1) > 0)     ;034
            temp_req->qual[d.seq]->phys_addr2 = trim(a.street_addr2)
        endif
 
        if (size(a.street_addr3,1) > 0)     ;034
            temp_req->qual[d.seq]->phys_addr3 = trim(a.street_addr3)
        endif
 
        if (size(a.street_addr4,1) > 0)     ;034
            temp_req->qual[d.seq]->phys_addr4 = trim(a.street_addr4)
        endif
 
        if (size(a.city,1) > 0)     ;034
            temp_req->qual[d.seq]->phys_city = trim(a.city)
        endif
 
        if (size(a.state,1) > 0 or a.state_cd > 0)     ;034
            if (size(temp_req->qual[d.seq]->phys_city,1) > 0)     ;034
                if (a.state_cd > 0)
                temp_req->qual[d.seq]->phys_city = concat(trim(temp_req->qual[d.seq]->
                    phys_city),", ",trim(uar_get_code_display(a.state_cd)))
                else
                    temp_req->qual[d.seq]->phys_city = concat(trim(temp_req->qual[d.seq]->
                        phys_city),", ",trim(a.state))
                endif
            else
                if (a.state_cd > 0)
                    temp_req->qual[d.seq]->phys_city = trim(uar_get_code_display(a.state_cd))
                else
                    temp_req->qual[d.seq]->phys_city = trim(a.state)
                endif
            endif
        endif
 
        if (size(a.zipcode,1) > 0)     ;034
            if (size(temp_req->qual[d.seq]->phys_city,1) > 0)     ;034
 
                temp_req->qual[d.seq]->phys_city = concat(trim(temp_req->qual[d.seq]->
                    phys_city)," ",trim(a.zipcode))
            else
                temp_req->qual[d.seq]->phys_city = trim(a.zipcode)
            endif
        endif
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "PHYS_ADDR2"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       Find doctor phone number                                            *
*****************************************************************************/
call echo("*** find doctor phone number ***")	;051
 
select into "nl:"
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    phone p
plan d where
    d.seq > 0
join p where
    p.parent_entity_id = temp_req->qual[d.seq]->phys_id and
    p.parent_entity_name in ("PERSON","PRSNL") and
    p.phone_type_cd in (work_phone_cd,work_fax_cd) and ; ar051237
    (p.active_ind = 1 and
     p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) and
     p.phone_type_seq = 1		;052 - Added additional criteria
order
    d.seq,
    p.beg_effective_dt_tm desc
 
detail ; ar051237
  if(p.PHONE_TYPE_CD = work_phone_cd)
    temp_req->qual[d.seq]->phys_phone = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
  elseif(p.PHONE_TYPE_CD = work_fax_cd)
    temp_req->qual[d.SEQ].phys_fax = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
  endif
with nocounter
 
 
/****************************************************************************
*       find health plans by encntr                                         *
*****************************************************************************/
call echo("*** find health plans by encntr ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    epr.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    encntr_plan_reltn epr,
    health_plan hp,
    organization o
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->encntr_id > 0
join epr where
    epr.encntr_id = temp_req->qual[d.seq]->encntr_id and
    epr.priority_seq in (1,2,99) and
    (epr.active_ind = TRUE and
     epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
join hp where
    hp.health_plan_id = epr.health_plan_id and
    hp.active_ind = TRUE
join o where
    o.organization_id= epr.organization_id
order
    d.seq,
    epr.beg_effective_dt_tm desc
 
head report
    hp_99_name   = fillstring(100," ")
    hp_99_polgrp = fillstring(200," ")
 
head d.seq
    found_pri_hp = FALSE
    found_sec_hp = FALSE
    found_99_hp  = FALSE
 
detail
 
    if (epr.priority_seq = 1 and found_pri_hp = FALSE)
        temp_req->qual[d.seq]->hp_pri_found  = TRUE
        temp_req->qual[d.seq]->hp_pri_name   = trim(o.org_name)
        temp_req->qual[d.seq]->hp_pri_polgrp = concat(trim(epr.member_nbr),"/",
            trim(hp.group_nbr))
        found_pri_hp = TRUE
    endif
 
    if (epr.priority_seq = 2 and found_sec_hp = FALSE)
        temp_req->qual[d.seq]->hp_sec_found  = TRUE
        temp_req->qual[d.seq]->hp_sec_name   = trim(o.org_name)
        temp_req->qual[d.seq]->hp_sec_polgrp = concat(trim(epr.member_nbr),"/",
            trim(hp.group_nbr))
        found_sec_hp = TRUE
    endif
 
    if (epr.priority_seq = 99 and found_99_hp = FALSE)
        hp_99_name   = trim(o.org_name)
        hp_99_polgrp = concat(trim(epr.member_nbr),"/",trim(hp.group_nbr))
        found_99_hp  = TRUE
    endif
 
foot d.seq
    if (found_pri_hp = FALSE and found_99_hp = TRUE)
        temp_req->qual[d.seq]->hp_pri_found  = TRUE
        temp_req->qual[d.seq]->hp_pri_name   = trim(hp_99_name)
        temp_req->qual[d.seq]->hp_pri_polgrp = trim(hp_99_polgrp)
        found_pri_hp = TRUE
    endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "ENCNTR_HEALTH"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       find health plans by person                                         *
*****************************************************************************/
call echo("*** find health plans by person ***")	;051
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    d.seq,
    ppr.beg_effective_dt_tm
from
    (dummyt d with seq = value(temp_req->qual_knt)),
    person_plan_reltn ppr,
    health_plan hp,
    organization o
plan d where
    d.seq > 0 and
    (temp_req->qual[d.seq]->hp_pri_found = FALSE or
     temp_req->qual[d.seq]->hp_sec_found = FALSE)
join ppr where
    ppr.person_id = request->person_id and
    ppr.priority_seq in (1,2,99) and
    (ppr.active_ind = TRUE and
     ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) and
     ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
join hp where
    hp.health_plan_id = ppr.health_plan_id and
    hp.active_ind = TRUE
join o where
    o.organization_id= ppr.organization_id
order
    d.seq,
    ppr.beg_effective_dt_tm desc
 
head report
    hp_99_name = fillstring(100," ")
    hp_99_polgrp = fillstring(200," ")
 
head d.seq
    found_pri_hp = FALSE
    found_sec_hp = FALSE
    found_99_hp = FALSE
 
detail
    if (ppr.priority_seq = 1 and found_pri_hp = FALSE and
        temp_req->qual[d.seq]->hp_pri_found = FALSE)
 
        temp_req->qual[d.seq]->hp_pri_found  = TRUE
        temp_req->qual[d.seq]->hp_pri_name   = trim(o.org_name)
        temp_req->qual[d.seq]->hp_pri_polgrp = concat(trim(ppr.member_nbr),"/",
            trim(hp.group_nbr))
        found_pri_hp = TRUE
    endif
 
    if (ppr.priority_seq = 2 and found_sec_hp = FALSE and
       temp_req->qual[d.seq]->hp_sec_found = FALSE)
 
        temp_req->qual[d.seq]->hp_sec_found  = TRUE
        temp_req->qual[d.seq]->hp_sec_name   = trim(o.org_name)
        temp_req->qual[d.seq]->hp_sec_polgrp = concat(trim(ppr.member_nbr),"/",
            trim(hp.group_nbr))
        found_sec_hp = TRUE
    endif
 
    if (ppr.priority_seq = 99 and found_99_hp = FALSE and
        temp_req->qual[d.seq]->hp_pri_found = FALSE)
 
        hp_99_name   = trim(o.org_name)
        hp_99_polgrp = concat(trim(ppr.member_nbr),"/",trim(hp.group_nbr))
        found_99_hp  = TRUE
   endif
 
foot d.seq
    if (found_pri_hp = FALSE and found_99_hp = TRUE)
        temp_req->qual[d.seq]->hp_pri_found  = TRUE
        temp_req->qual[d.seq]->hp_pri_name   = trim(hp_99_name)
        temp_req->qual[d.seq]->hp_pri_polgrp = trim(hp_99_polgrp)
        found_pri_hp = TRUE
   endif
with nocounter
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "PERSON_HEALTH"
    go to EXIT_SCRIPT
endif
 
/****************************************************************************
*       find Pharmacy Name                                                  *
*****************************************************************************/
call echo("*** find pharmacy name***")	;051
 
; EPCS - check if messaging_audit table has an entry for the order_ids in temp_req
; if so, then the orders were electronically routed, then check if each of the temp_req->qual[*] is a controlled substance
; if the order is a controlled substance (CS), check if electronic routing was successful or failed
; if the electronic routing was successful for the CS include a label stating "copy - not for dispensing"
; in the printed requisition
; if the electronic routing had failed for the CS, include a label in the printed requisition, stating that the electronic
; routing had failed, and also mention the pharmacy name to which routing had failed
; These labels are repated individually for each of the controlled substances in the requisition, since there could be a mix
; of orders whose electronic routing failed or successful
 
declare FIELD_MEANING_ROUTING_PHARMACY_NAME = i4 with constant(1565)
; define constants mapped to electornic routing success code values in code set 3401
declare MSG_AUDIT_STATUS_CD_COMPLETE   = f8 with constant(uar_get_code_by("MEANING",3401,"COMPLETE"))
declare MSG_AUDIT_STATUS_CD_DELIVERED  = f8 with constant(uar_get_code_by("MEANING",3401,"DELIVERED"))
declare MSG_AUDIT_STATUS_CD_INPROGRESS = f8 with constant(uar_get_code_by("MEANING",3401,"IN PROGRESS"))
 
select into "nl:"
       m_status_cd =  m.status_cd,
       m.order_id,
	   od_pharmacy_name = od.OE_FIELD_DISPLAY_VALUE,
	   m.audit_dt_tm
from  messaging_audit   m, order_detail od
where expand(erx_idx,1,size(temp_req->qual, 5),m.order_id,temp_req->qual[erx_idx].order_id) and
      ((m.publish_ind = 1) and (od.OE_FIELD_MEANING_ID=FIELD_MEANING_ROUTING_PHARMACY_NAME) and
       (m.order_id = od.order_id ))
order m.order_id, m.audit_dt_tm desc, od.action_sequence
head m.order_id
     locate_idx = 0
head m.audit_dt_tm
     newIndex = locateval(locate_idx, 1, size(temp_req->qual,5), m.order_id, temp_req->qual[locate_idx].order_id)
     ; if csa_schedule is "0" or "" , it is not a controlled substance
     if ((temp_req->qual[newIndex]->csa_schedule <= "0") or (temp_req->qual[newIndex]->csa_schedule <= ""))
             temp_req->qual[newIndex]->second_attempt_note = "" ; EPCS specific labeling : None
     else ; for controlled substances attempted EPCS
          if (m_status_cd in (MSG_AUDIT_STATUS_CD_COMPLETE, MSG_AUDIT_STATUS_CD_DELIVERED, MSG_AUDIT_STATUS_CD_INPROGRESS))
              ; EPCS specific labeling : Copy, not for dispensing
              temp_req->qual[newIndex]->second_attempt_note =
                         "***COPY - NOT FOR DISPENSING.FOR INFORMATIONAL PURPOSES ONLY. ***"
          else
              temp_req->qual[newIndex]->second_attempt_note =
                       "THE PRESCRIPTION WAS ORIGINALLY TRANSMITTED ELECTRONICALLY TO PHARMACY AND FAILED."
               temp_req->qual[newIndex]->routing_pharmacy_name = trim(od_pharmacy_name)
               temp_req->qual[newIndex]->routing_dt_tm = od.updt_dt_tm
          endif
      endif
 
with nocounter
;030
 
/****************************************************************************
*       find order synonym                                                  *
*****************************************************************************/
call echo("*** find order synonym ***")	;051
 
select into "nl:"
from  (dummyt d with seq = size(temp_req->qual, 5)),
      order_catalog_synonym ocs,
      orders o
 
plan  d
where d.seq > 0
 
join o
where o.order_id = temp_req->qual[d.seq]->order_id
 
join ocs
where ocs.synonym_id = o.synonym_id
 
detail
temp_req->qual[d.seq]->mnemonic_type_cd = ocs.mnemonic_type_cd
with nocounter
 
;*** parse details
for (a = 1 to temp_req->qual_knt)
 
    if (temp_req->qual[a]->no_print = FALSE)
 
        if (size(temp_req->qual[a]->free_txt_ord,1) > 0)     ;034
            set temp_req->qual[a]->med_name = trim(temp_req->qual[a]->free_txt_ord)
        else
            set temp_req->qual[a]->med_name = trim(temp_req->qual[a]->order_as_mnemonic)
        endif
 
        ;MOD 012 Start - Should look like a new prescription when having additional refill. ;ar051237
 
        if (size(temp_req->qual[a]->add_refills_txt,1) > 0 and temp_req->qual[a]->add_refills > 0)     ;034
            set temp_req->qual[a]->refill_line = trim(temp_req->qual[a]->add_refills_txt)
 
        ;MOD 012 End
 
        else
            ;008
            if (size(temp_req->qual[a]->nbr_refills_txt,1) > 0 and temp_req->qual[a]->nbr_refills > 0)     ;034
                if (temp_req->qual[a]->nbr_refills = temp_req->qual[a]->total_refills)
                    set temp_req->qual[a]->refill_line = trim(temp_req->qual[a]->nbr_refills_txt)
                endif
            endif
 
		endif	;Mod 13 PC3603
 
            if (size(temp_req->qual[a]->refill_line,1) > 0)     ;034
                set pt->line_cnt = 0
                set max_length = 60
                execute dcp_parse_text value(temp_req->qual[a]->refill_line), value(max_length)
 
                set temp_req->qual[a]->refill_knt = pt->line_cnt
                set stat = alterlist(temp_req->qual[a]->refill,temp_req->qual[a]->refill_knt)
;                for (c = 1 to pt->line_cnt)
;                    set temp_req->qual[a]->refill[c]->disp = concat("<",trim(pt->lns[c]->line),">")
;                endfor
            endif
 
 
;Mod 13 PC3603        endif
 
        if (temp_req->qual[a]->nbr_refills > 0)
 
            set number_spellout = get_number_spellout(cnvtstring(temp_req->qual[a]->nbr_refills))
 
            if (number_spellout > "")
               	set temp_req->qual[a]->refill_line = trim(concat(trim(cnvtstring(temp_req->qual[a]->nbr_refills),3),
               	                                       " (",number_spellout,")"))
            else
                set temp_req->qual[a]->refill_line = trim(temp_req->qual[a]->refill_knt)
            endif
 
             for (c = 1 to pt->line_cnt)
                   set temp_req->qual[a]->refill[c]->disp = temp_req->qual[a]->refill_line
             endfor
 
       endif
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        set pt->line_cnt = 0
        set max_length = 55
        execute dcp_parse_text value(temp_req->qual[a]->med_name), value(max_length)
 
        set temp_req->qual[a]->med_knt = pt->line_cnt
        set stat = alterlist(temp_req->qual[a]->med,temp_req->qual[a]->med_knt)
 
        for (c = 1 to pt->line_cnt)
            set temp_req->qual[a]->med[c]->disp = trim(pt->lns[c]->line)
        endfor
 
        if (temp_req->qual[a]->nbr_refills = temp_req->qual[a]->total_refills)
            set temp_req->qual[a]->start_date = cnvtdatetime(cnvtdate(temp_req->qual[a]->
                req_start_date),0)
        else
            set temp_req->qual[a]->start_date = cnvtdatetime(cnvtdate(temp_req->qual[a]->
                req_refill_date),0)
        endif
 
        if (size(temp_req->qual[a]->strength_dose,1) > 0 and size(temp_req->qual[a]->volume_dose,1) > 0)     ;034
 
          ; For Orders containing both strength and volume doses the requisitions will only
          ; print strength dose for Primary, Brand and C type mnemonics   037
 
           if (temp_req->qual[a]->mnemonic_type_cd = value(primary_mnemonic_type_cd) or
               temp_req->qual[a]->mnemonic_type_cd = value(brand_mnemonic_type_cd) or
               temp_req->qual[a]->mnemonic_type_cd = value(c_mnemonic_type_cd))
 
            	set temp_req->qual[a]->sig_line = trim(temp_req->qual[a]->strength_dose)
 
            	if (size(temp_req->qual[a]->strength_dose_unit,1) > 0)     ;034
                	set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    	" ",trim(temp_req->qual[a]->strength_dose_unit))
            	endif
 
           else   ;030
 
            	set temp_req->qual[a]->sig_line = trim(temp_req->qual[a]->volume_dose)
 
            	if (size(temp_req->qual[a]->volume_dose_unit,1) > 0)     ;034
               	 set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    	" ",trim(temp_req->qual[a]->volume_dose_unit))
            	endif
 
           endif  ;030
 
            ;032 Start Drug From
            if (size(temp_req->qual[a]->drug_form,1) > 0 and not     ;034
                   (temp_req->qual[a]->mnemonic_type_cd = value(generic_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(generic_prod_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_prod_type_cd)))
            	set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->drug_form))
            endif
            ;032 End
 
            if (size(temp_req->qual[a]->rx_route,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->rx_route))
            endif
 
            if (size(temp_req->qual[a]->frequency,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->frequency))
            endif
 
            if (size(temp_req->qual[a]->duration,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " for ",trim(temp_req->qual[a]->duration))
            endif
 
            if (size(temp_req->qual[a]->duration_unit,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->duration_unit))
            endif
 
        elseif (size(temp_req->qual[a]->strength_dose,1) > 0)     ;034
 
            set temp_req->qual[a]->sig_line = trim(temp_req->qual[a]->strength_dose)
            if (size(temp_req->qual[a]->strength_dose_unit,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->strength_dose_unit))
            endif
 
            ;032 Drug Form
            if (size(temp_req->qual[a]->drug_form,1) > 0 and not     ;034
                   (temp_req->qual[a]->mnemonic_type_cd = value(generic_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(generic_prod_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_prod_type_cd)))
            	set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->drug_form))
            endif
            ;032 End
 
            if (size(temp_req->qual[a]->rx_route,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->rx_route))
            endif
 
            if (size(temp_req->qual[a]->frequency,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->frequency))
            endif
 
            if (size(temp_req->qual[a]->duration,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " for ",trim(temp_req->qual[a]->duration))
            endif
 
            if (size(temp_req->qual[a]->duration_unit,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->duration_unit))
            endif
 
        elseif (size(temp_req->qual[a]->volume_dose,1) > 0)     ;034
 
            set temp_req->qual[a]->sig_line = trim(temp_req->qual[a]->volume_dose)
            if (size(temp_req->qual[a]->volume_dose_unit,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->volume_dose_unit))
            endif
 
            ;032 Drug Form
            if (size(temp_req->qual[a]->drug_form,1) > 0 and not     ;034
                   (temp_req->qual[a]->mnemonic_type_cd = value(generic_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(generic_prod_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_prod_type_cd)))
            	set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->drug_form))
            endif
            ;032 End
 
            if (size(temp_req->qual[a]->rx_route,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->rx_route))
            endif
 
            if (size(temp_req->qual[a]->frequency,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->frequency))
            endif
 
            if (size(temp_req->qual[a]->duration,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " for ",trim(temp_req->qual[a]->duration))
            endif
 
            if (size(temp_req->qual[a]->duration_unit,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->duration_unit))
            endif
        else
            set temp_req->qual[a]->sig_line = trim(temp_req->qual[a]->freetext_dose)
 
            ;032 Drug Form
            if (size(temp_req->qual[a]->drug_form,1) > 0 and not     ;034
                   (temp_req->qual[a]->mnemonic_type_cd = value(generic_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_top_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(generic_prod_type_cd)
                    or temp_req->qual[a]->mnemonic_type_cd = value(trade_prod_type_cd)))
            	set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->drug_form))
            endif
            ;032 End
 
            if (size(temp_req->qual[a]->rx_route,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->rx_route))
            endif
 
            if (size(temp_req->qual[a]->frequency,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->frequency))
            endif
 
            if (size(temp_req->qual[a]->duration,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " for ",trim(temp_req->qual[a]->duration))
            endif
 
            if (size(temp_req->qual[a]->duration_unit,1) > 0)     ;034
                set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line),
                    " ",trim(temp_req->qual[a]->duration_unit))
            endif
        endif
 
        if (temp_req->qual[a]->prn_ind = TRUE and size(temp_req->qual[a]->prn_inst,1) > 0)	; MOD 020     ;034
            set temp_req->qual[a]->sig_line = concat(trim(temp_req->qual[a]->sig_line)," PRN ",trim(temp_req->qual[a]->prn_inst))
        endif
 
        if (size(temp_req->qual[a]->sig_line,1) > 0)     ;034
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->sig_line), value(max_length)
 
            set temp_req->qual[a]->sig_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->sig,temp_req->qual[a]->sig_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->sig[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
 
        if (size(temp_req->qual[a]->dispense_qty,1) > 0)     ;034
 
            set dispense_number = temp_req->qual[a]->dispense_qty ;042
            set number_spellout = get_number_spellout(temp_req->qual[a]->dispense_qty) ;042
            if (number_spellout > "") ;042
               	set temp_req->qual[a]->dispense_line = trim(concat(temp_req->qual[a]->dispense_qty,
               	                                       " (",number_spellout,")")) ;042
            else ;042
                set temp_req->qual[a]->dispense_line = trim(temp_req->qual[a]->dispense_qty)
            endif ;042
 
            if (size(temp_req->qual[a]->dispense_qty_unit,1) > 0)     ;034
                set temp_req->qual[a]->dispense_line = trim(concat(temp_req->qual[a]->
                    dispense_line," ",trim(temp_req->qual[a]->dispense_qty_unit)))
            endif
 
        elseif (size(temp_req->qual[a]->dispense_qty_unit,1) > 0)     ;034
            set temp_req->qual[a]->dispense_line = trim(temp_req->qual[a]->dispense_qty_unit)
        endif
 
 	;BEGIN MOD 007
        if (size(temp_req->qual[a]->dispense_duration,1) > 0)     ;034
 
            set dispense_number = temp_req->qual[a]->dispense_duration ;042
            set number_spellout = get_number_spellout(temp_req->qual[a]->dispense_duration) ;042
            if (number_spellout > "") ;042
                set temp_req->qual[a]->dispense_duration_line = trim(concat(temp_req->qual[a]->dispense_duration,
                                                            " (",number_spellout,")")) ;042
            else ;042
                set temp_req->qual[a]->dispense_duration_line = trim(temp_req->qual[a]->dispense_duration)
            endif ;042
 
            if (size(temp_req->qual[a]->dispense_duration_unit,1) > 0)     ;034
                set temp_req->qual[a]->dispense_duration_line = trim(concat(temp_req->qual[a]->
                    dispense_duration_line," ",trim(temp_req->qual[a]->dispense_duration_unit)))
            endif
 
        elseif (size(temp_req->qual[a]->dispense_duration_unit,1) > 0)     ;034
            set temp_req->qual[a]->dispense_duration_line = trim(temp_req->qual[a]->dispense_duration_unit)
 
        endif
 
	if (size(temp_req->qual[a]->dispense_duration_line,1) > 0)     ;034
		set temp_req->qual[a]->dispense_duration_line = concat(temp_req->qual[a]->dispense_duration_line," supply")
		set temp_req->qual[a]->dispense_line = " "
	endif
	;END MOD 007
 
        if (size(temp_req->qual[a]->dispense_line,1) > 0)     ;034
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->dispense_line), value(max_length)
 
            set temp_req->qual[a]->dispense_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->dispense,temp_req->qual[a]->dispense_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->dispense[c]->disp = trim(pt->lns[c]->line,3)
            endfor
        endif
 
	;BEGIN MOD 007
        if (size(temp_req->qual[a]->dispense_duration_line,1) > 0)     ;034
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->dispense_duration_line), value(max_length)
 
            set temp_req->qual[a]->dispense_duration_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->dispense_duration_qual,temp_req->qual[a]->dispense_duration_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->dispense_duration_qual[c]->disp = trim(pt->lns[c]->line,3)
            endfor
        endif
        ;END MOD 007
 
/*
        if (not(size(temp_req->qual[a]->add_refills,1) > 0))     ;034
            if (size(temp_req->qual[a]->nbr_refills_txt,1) > 0)     ;034
                if (temp_req->qual[a]->nbr_refills = temp_req->qual[a]->total_refills)
                    set temp_req->qual[a]->refill_line = trim(temp_req->qual[a]->nbr_refills_txt)
                endif
            endif
 
            if (size(temp_req->qual[a]->refill_line,1) > 0)     ;034
                set pt->line_cnt = 0
                set max_length = 60
                execute dcp_parse_text value(temp_req->qual[a]->refill_line), value(max_length)
 
                set temp_req->qual[a]->refill_knt = pt->line_cnt
                set stat = alterlist(temp_req->qual[a]->refill,temp_req->qual[a]->refill_knt)
                for (c = 1 to pt->line_cnt)
                    set temp_req->qual[a]->refill[c]->disp = concat("<",trim(pt->lns[c]->line),">")
                endfor
            endif
        endif
*/
 
        if (size(temp_req->qual[a]->special_inst,1) > 0)     ;034
            set temp_req->qual[a]->special_inst = trim(temp_req->qual[a]->special_inst)
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->special_inst), value(max_length)
 
            set temp_req->qual[a]->special_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->special,temp_req->qual[a]->special_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->special[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
 
        if (size(temp_req->qual[a]->ICD10_Codes,1) > 0)     ;046
            set temp_req->qual[a]->ICD10_Codes = trim(temp_req->qual[a]->ICD10_Codes)
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->ICD10_Codes), value(max_length)
 
            set temp_req->qual[a]->ICD10_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->ICD10,temp_req->qual[a]->ICD10_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->ICD10[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
/**
        if (size(temp_req->qual[a]->prn_inst,1) > 0)     ;034
            set temp_req->qual[a]->prn_inst = trim(temp_req->qual[a]->prn_inst)
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->prn_inst), value(max_length)
 
            set temp_req->qual[a]->prn_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->prn,temp_req->qual[a]->prn_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->prn[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
**/
 
        if (size(temp_req->qual[a]->indications,1) > 0)     ;034
            set temp_req->qual[a]->indications = trim(temp_req->qual[a]->indications)
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->indications), value(max_length)
 
            set temp_req->qual[a]->indic_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->indic,temp_req->qual[a]->indic_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->indic[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
 
        if (size(temp_req->qual[a]->comments,1) > 0)     ;034
            set temp_req->qual[a]->comments = trim(temp_req->qual[a]->comments)
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->comments), value(max_length)
 
            set temp_req->qual[a]->comment_knt = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->comment,temp_req->qual[a]->comment_knt)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->comment[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
        ;EPCS labels - split the long text in second_attempt_note, into multiple lines of 60 chars
        ;by passing it to dcp_parse_text, which stores each of the lines in pt->lns and updates
        ; pt->line_cnt with the number of lines
        if (size(trim(temp_req->qual[a]->second_attempt_note),1) > 0)
            set temp_req->qual[a]->second_attempt_note = trim(temp_req->qual[a]->second_attempt_note)
            set pt->line_cnt = 0
            set max_length = 60
            execute dcp_parse_text value(temp_req->qual[a]->second_attempt_note), value(max_length)
 
            ; get the number of multiple lines, and store each line in  temp_req->qual[a]->sec_att_msg_row
            set temp_req->qual[a]->sec_att_msg_line_count = pt->line_cnt
            set stat = alterlist(temp_req->qual[a]->sec_att_msg_row,temp_req->qual[a]->sec_att_msg_line_count)
            for (c = 1 to pt->line_cnt)
                set temp_req->qual[a]->sec_att_msg_row[c]->disp = trim(pt->lns[c]->line)
            endfor
        endif
    endif
endfor
 
/****************************************************************************
*       ar051237    - Find Organization/Location information.               *
*****************************************************************************/
call echo("*** find org loc information ***")	;051
 
select into "nl:"
from orders o
     ,encounter e
     ,organization org
plan o
    where expand(num,1,size(temp_req->qual, 5),o.ORDER_ID,temp_req->qual[num].order_id)
    and o.ACTIVE_IND = 1
join e
     where e.ENCNTR_ID = o.ENCNTR_ID
     and e.ACTIVE_IND = 1
     and e.BEG_EFFECTIVE_DT_TM <= cnvtdatetime(curdate,curtime3)
     and e.END_EFFECTIVE_DT_TM > cnvtdatetime(curdate,curtime3)
join org
     where org.ORGANIZATION_ID = e.ORGANIZATION_ID
     and org.ACTIVE_IND = 1
     and org.BEG_EFFECTIVE_DT_TM <= cnvtdatetime(curdate,curtime3)
     and org.END_EFFECTIVE_DT_TM > cnvtdatetime(curdate,curtime3)
order by e.ENCNTR_ID
 
head o.ORDER_ID
    pos = locateval(num,1,size(temp_req->qual, 5),o.ORDER_ID,temp_req->qual[num].order_id)
    temp_req->qual[pos].facility = org.ORG_NAME
    temp_req->qual[pos].facility_cd = e.LOC_FACILITY_CD
 
foot o.ORDER_ID
    null
 
with nocounter,expand = 1
 
/****************************************************************************
*       Facility Address                                                    *
*****************************************************************************/
call echo("*** Facility Address ***")	;051
 
select into "nl:"
from address a
plan a
     where expand(num,1,size(temp_req->qual, 5),a.PARENT_ENTITY_ID,temp_req->qual[num].facility_cd)
     and a.PARENT_ENTITY_NAME = "LOCATION"
     and a.ADDRESS_TYPE_CD = loc_bus_cd
     and a.ACTIVE_IND = 1
     and a.BEG_EFFECTIVE_DT_TM <= cnvtdatetime(curdate,curtime3)
     and a.END_EFFECTIVE_DT_TM >= cnvtdatetime(curdate,curtime3)
order by a.PARENT_ENTITY_ID
 
head a.PARENT_ENTITY_ID
    pos = locateval(num,1,size(temp_req->qual, 5),a.PARENT_ENTITY_ID,temp_req->qual[num].facility_cd)
    while(pos>0)
        temp_req->qual[pos].facility_addr1 = a.STREET_ADDR
        temp_req->qual[pos].facility_addr2 = a.STREET_ADDR2
        temp_req->qual[pos].facility_addr3 = a.STREET_ADDR3
        temp_req->qual[pos].facility_addr4 = concat(trim(a.city,3),", ",trim(a.state,3)," ",trim(a.ZIPCODE,3))
 
        pos = locateval(num,pos+1,size(temp_req->qual, 5),a.PARENT_ENTITY_ID,temp_req->qual[num].facility_cd)
    endwhile
 
 
foot a.PARENT_ENTITY_ID
    null
 
with nocounter,expand=1
 
 
/****************************************************************************
*       find preferred Pharmacy                                             *
*****************************************************************************/
call echo("*** find preferred pharmacy ***")	;051
 
select into "nl:"
   from person_preferred_pharmacy ppp
   plan ppp
      where ppp.person_id = request->person_id
      and ppp.active_ind = 1
      and ppp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      and ppp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   order ppp.default_ind desc
      ,ppp.updt_dt_tm desc
   head report
      stat = alterlist(request_in->ids,1)
      request_in->ids[1].id = trim(ppp.preferred_pharmacy_uid,3)
      bFoundPharmacy = TRUE
   with nocounter
 
   if (bFoundPharmacy = FALSE)
      SELECT INTO "NL:"
      FROM person_info pi
         ,long_text  l
      PLAN pi
         where pi.person_id            = request->person_id
         and pi.info_type_cd         = PREFER_PHARM_CD
         and pi.active_ind           = 1
         and pi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         and pi.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
      JOIN l
         where l.long_text_id = pi.long_text_id
      ORDER BY pi.value_numeric desc
         ,pi.updt_dt_tm desc
         ,pi.beg_effective_dt_tm desc
      HEAD Report
         stat = alterlist(request_in->ids, 1)
         request_in->ids[1].id = trim(l.long_text)
      WITH nocounter
   endif
 
  ;>> Service Call to Pharmacy_RetrievePharmaciesByIds (3202501) <<
;  call echorecord(request_in)
 if(textlen(trim(request_in->ids[1].id,3))>0)
  set stat = TDBEXECUTE(600005,500195,3202501,"REC",request_in,"REC",reply_out)
  set pref_pharma = reply_out->PHARMACIES[1].PHARMACY_NAME
  set pharma_phone = reply_out->PHARMACIES[1]->PRIMARY_BUSINESS_TELEPHONE[1].VALUE
  set pharma_fax = reply_out->PHARMACIES[1]->PRIMARY_BUSINESS_FAX[1].VALUE
  ;call echo(build("***##  TDBEXECUTE() = ",stat))  ;0 = success
;  call echorecord(reply_out)
;  call echo(build("##**",pharma_fax))
  ;call echorecord(temp_req)
 endif
 
 /****************************************************************************
*       build print record                                                  *
*****************************************************************************/
call echo("*** build print record ***")	;051
 
free record tprint_req
record tprint_req
(
  1 job_knt = i4
  1 job[*]
    2 refill_ind     = i2
    2 fac_name       = vc ;ar051237
    2 fac_addr1      = vc ;ar051237
    2 fac_addr2      = vc ;ar051237
    2 fac_addr3      = vc ;ar051237
    2 fac_addr4      = vc ;ar051237
    2 prf_pharma     = vc ;sr051119
    2 pharma_ph      = vc
    2 pharma_fax     = vc
    2 phys_name      = vc
    2 phys_bname     = vc
    2 phys_fname     = vc
    2 phys_mname     = vc
    2 phys_lname     = vc
    2 eprsnl_id      = f8
    2 eprsnl_ind     = i2
    2 eprsnl_name    = vc
    2 eprsnl_bname   = vc
    2 eprsnl_fname   = vc
    2 eprsnl_mname   = vc
    2 eprsnl_lname   = vc
    2 phys_addr1     = vc
    2 phys_addr2     = vc
    2 phys_addr3     = vc
    2 phys_addr4     = vc
    2 phys_city      = vc
    2 phys_dea       = vc
    2 phys_npi		 = vc ;028
    2 sup_phys_npi   = vc ;028
    2 phys_lnbr      = vc
    2 phys_phone     = vc
    2 phys_fax       = vc ; ar051237
    2 csa_group      = vc
    2 phys_ord_dt    = vc
    2 output_dest_cd = f8
    2 free_text_nbr  = vc
    2 print_loc      = vc
    2 daw            = i2
    2 mrn            = vc
    2 finnbr         = vc	;051
    2 hp_found       = i2
    2 hp_pri_name    = vc
    2 hp_pri_polgrp  = vc
    2 hp_sec_name    = vc
    2 hp_sec_polgrp  = vc
    2 req_knt        = i4
    2 req[*]
      3 order_id     = f8
      3 print_dea    = i2
      3 csa_sched    = c1
      3 start_dt     = vc
      3 action_dt    = vc ;035
      3 med_knt      = i4
      3 med[*]
        4 disp       = vc
      3 sig_knt      = i4
      3 sig[*]
        4 disp       = vc
      3 dispense_knt = i4
      3 dispense[*]
        4 disp       = vc
      3 dispense_duration_knt = i4	;*** MOD 007
      3 dispense_duration[*]		;*** MOD 007
        4 disp       = vc		;*** MOD 007
      3 refill_knt   = i4
      3 refill[*]
        4 disp       = vc
      3 special_knt  = i4
      3 special[*]
        4 disp       = vc
      3 ICD10_knt  = i4			;046
      3 ICD10[*]				;046
        4 disp       = vc       ;046
      3 prn_knt      = i4
      3 prn[*]
        4 disp       = vc
      3 indic_knt    = i4
      3 indic[*]
        4 disp       = vc
      3 comment_knt  = i4
      3 comment[*]
        4 disp       = vc
      3 sec_att_knt  = i4
      3 sec_att[*]
        4 disp       = vc
      3 erx_pharmacy_name = vc
      3 erx_routing_dt_tm = vc
    2 sup_phys_bname = vc   ;013
    2 sup_phys_dea   = vc   ;013
    2 sup_phys_id    = f8   ;013
)
 
set iErrCode = error(sErrMsg,1)
set iErrCode = 0
 
select into "nl:"
    encntr_id = temp_req->qual[d.seq]->encntr_id,
    print_loc = temp_req->qual[d.seq]->print_loc,
    order_dt = format(cnvtdatetime(temp_req->qual[d.seq]->order_dt),"mm/dd/yyyy;;d"),
    print_dea = temp_req->qual[d.seq]->print_dea,
    csa_schedule = temp_req->qual[d.seq]->csa_schedule,
    csa_group = temp_req->qual[d.seq]->csa_group,
    daw = temp_req->qual[d.seq]->daw,
    output_dest_cd = temp_req->qual[d.seq]->output_dest_cd,
    free_text_nbr = temp_req->qual[d.seq]->free_text_nbr,
    fax_seq = build(temp_req->qual[d.seq]->output_dest_cd,temp_req->qual[d.seq]->free_text_nbr),
    phys_id = temp_req->qual[d.seq]->phys_id,
    phys_addr_id = temp_req->qual[d.seq]->phys_addr_id,
    phys_seq = build(temp_req->qual[d.seq]->phys_id,temp_req->qual[d.seq]->phys_addr_id),
    sup_phys_id = temp_req->qual[d.seq]->sup_phys_id,
    refill_ind = temp_req->qual[d.seq]->refill_ind,
    o_seq_1 = build(temp_req->qual[d.seq]->refill_ind,temp_req->qual[d.seq]->encntr_id),
    d.seq
from
    (dummyt d with seq = value(temp_req->qual_knt))
plan d where
    d.seq > 0 and
    temp_req->qual[d.seq]->no_print = FALSE
order
;**    refill_ind,
;**    encntr_id,
    o_seq_1,
    order_dt,
    daw,
    csa_group,
    csa_schedule,
    print_loc,
    fax_seq,
    phys_seq,
    sup_phys_id,
    print_dea
    ;d.seq
 
head report
 
    jknt = 0
    rknt = 0
    stat = alterlist(tprint_req->job,10)
 
    new_job             = FALSE
;    temp_refill_ind     = -1
;    temp_encntr_id      = 0.0
    temp_o_seq_1        = fillstring(255," ")
    temp_order_dt       = fillstring(12," ")
    temp_print_loc      = fillstring(255," ")
    temp_output_dest_cd = 0.0
    temp_free_text_nbr  = fillstring(255," ")
    temp_phys_id        = 0.0
    temp_phys_addr_id   = 0.0
    temp_sup_phys_id 	= 0.0
    temp_daw            = 0
    temp_csa_group      = ""
    temp_csa_schedule   = fillstring(1," ")
 
detail
 
/*
    if (temp_refill_ind != refill_ind)
        new_job = TRUE
    endif
 
    if (temp_encntr_id != encntr_id)
        new_job = TRUE
    endif
*/
 
; 045 - Mirror RXREQGEN03 logic
    if (temp_o_seq_1 != o_seq_1)
        new_job = TRUE
    endif
 
    if (temp_order_dt != order_dt)
        new_job = TRUE
    endif
 
    if (temp_print_loc != print_loc)
        new_job = TRUE
    endif
 
    if (temp_output_dest_cd != output_dest_cd)
        new_job = TRUE
    endif
 
    if (temp_free_text_nbr != free_text_nbr)
        new_job = TRUE
    endif
 
    if (temp_phys_id != phys_id)
        new_job = TRUE
    endif
 
    if (temp_phys_addr_id != phys_addr_id)
        new_job = TRUE
    endif
 
    if (temp_sup_phys_id != sup_phys_id)
        new_job = TRUE
    endif
 
    if (temp_daw != daw)
        new_job = TRUE
    endif
 
    if (temp_csa_group != csa_group)
        new_job = TRUE
    endif
 
    if (new_job = TRUE)
        new_job = FALSE
 
        if (jknt > 0)
            tprint_req->job[jknt]->req_knt = rknt
            stat = alterlist(tprint_req->job[jknt]->req,rknt)
        endif
 
        jknt = jknt + 1
        if (mod(jknt,10) = 1 and jknt != 1)
            stat = alterlist(tprint_req->job,jknt + 9)
        endif
 
 
        tprint_req->job[jknt]->csa_group   = csa_group
        tprint_req->job[jknt]->fac_name = temp_req->qual[d.seq]->facility ; ar051237
        tprint_req->job[jknt]->fac_addr1 = temp_req->qual[d.seq]->facility_addr1
        tprint_req->job[jknt]->fac_addr2 = temp_req->qual[d.seq]->facility_addr2
        tprint_req->job[jknt]->fac_addr3 = temp_req->qual[d.seq]->facility_addr3
        tprint_req->job[jknt]->fac_addr4 = temp_req->qual[d.seq]->facility_addr4
        tprint_req->job[jknt]->prf_pharma= pref_pharma
        tprint_req->job[jknt]->pharma_ph = pharma_phone
        tprint_req->job[jknt]->pharma_fax = pharma_fax
        tprint_req->job[jknt]->refill_ind = temp_req->qual[d.seq]->refill_ind
        tprint_req->job[jknt]->phys_name   = temp_req->qual[d.seq]->phys_name
        tprint_req->job[jknt]->phys_bname   = temp_req->qual[d.seq]->phys_bname
        tprint_req->job[jknt]->phys_fname  = temp_req->qual[d.seq]->phys_fname
        tprint_req->job[jknt]->phys_mname  = temp_req->qual[d.seq]->phys_mname
        tprint_req->job[jknt]->phys_lname  = temp_req->qual[d.seq]->phys_lname
        tprint_req->job[jknt]->eprsnl_ind = temp_req->qual[d.seq]->eprsnl_ind
        tprint_req->job[jknt]->eprsnl_bname = temp_req->qual[d.seq]->eprsnl_bname
        tprint_req->job[jknt]->eprsnl_id = temp_req->qual[d.seq]->eprsnl_id             ;022
        tprint_req->job[jknt]->phys_addr1  = temp_req->qual[d.seq]->phys_addr1
        tprint_req->job[jknt]->phys_addr2  = temp_req->qual[d.seq]->phys_addr2
        tprint_req->job[jknt]->phys_addr3  = temp_req->qual[d.seq]->phys_addr3
        tprint_req->job[jknt]->phys_addr4  = temp_req->qual[d.seq]->phys_addr4
        tprint_req->job[jknt]->phys_city   = temp_req->qual[d.seq]->phys_city
        tprint_req->job[jknt]->phys_dea    = temp_req->qual[d.seq]->phys_dea
        tprint_req->job[jknt]->phys_npi    = temp_req->qual[d.seq]->phys_npi ;028
        tprint_req->job[jknt]->sup_phys_npi = temp_req->qual[d.seq]->sup_phys_npi ;028
        tprint_req->job[jknt]->phys_lnbr   = temp_req->qual[d.seq]->phys_lnbr
        tprint_req->job[jknt]->phys_phone  = temp_req->qual[d.seq]->phys_phone
        tprint_req->job[jknt]->phys_fax    = temp_req->qual[d.seq]->phys_fax ; ar051237
        tprint_req->job[jknt]->phys_ord_dt = order_dt
        tprint_req->job[jknt]->sup_phys_bname   = temp_req->qual[d.seq]->sup_phys_bname ;012
        tprint_req->job[jknt]->sup_phys_dea    = temp_req->qual[d.seq]->sup_phys_dea    ;012
 
        if (tprint_req->job[jknt]->csa_group = "A")
            tprint_req->job[jknt]->output_dest_cd = -1
            tprint_req->job[jknt]->free_text_nbr = "1"
        else
            tprint_req->job[jknt]->output_dest_cd = temp_req->qual[d.seq]->output_dest_cd
            tprint_req->job[jknt]->free_text_nbr = trim(temp_req->qual[d.seq]->free_text_nbr)
        endif
 
        tprint_req->job[jknt]->print_loc     = trim(temp_req->qual[d.seq]->print_loc)
        tprint_req->job[jknt]->daw           = temp_req->qual[d.seq]->daw
        tprint_req->job[jknt]->mrn           = temp_req->qual[d.seq]->mrn
        tprint_req->job[jknt]->finnbr           = temp_req->qual[d.seq]->finnbr   ;051
 
call echo("***")
call echo(build("***   hp_pri_found :",temp_req->qual[d.seq]->hp_pri_found))
call echo(build("***   hp_sec_found :",temp_req->qual[d.seq]->hp_sec_found))
call echo("***")
        if (temp_req->qual[d.seq]->hp_pri_found = TRUE or temp_req->qual[d.seq]->hp_sec_found = TRUE)
            tprint_req->job[jknt]->hp_found = TRUE
        endif
        tprint_req->job[jknt]->hp_pri_name   = temp_req->qual[d.seq]->hp_pri_name
        tprint_req->job[jknt]->hp_pri_polgrp = temp_req->qual[d.seq]->hp_pri_polgrp
        tprint_req->job[jknt]->hp_sec_name   = temp_req->qual[d.seq]->hp_sec_name
        tprint_req->job[jknt]->hp_sec_polgrp = temp_req->qual[d.seq]->hp_sec_polgrp
 
;**     temp_refill_ind     = refill_ind
;**        temp_encntr_id      = encntr_id
        temp_o_seq_1        = o_seq_1
        temp_order_dt       = order_dt
        temp_print_loc      = print_loc
        temp_output_dest_cd = output_dest_cd
        temp_free_text_nbr  = free_text_nbr
        temp_phys_id        = phys_id
        temp_phys_addr_id   = phys_addr_id
        temp_sup_phys_id	= sup_phys_id
        temp_daw            = daw
        if(temp_req->qual[d.seq].csa_schedule != "2") ;Each class 2 controlled substance needs its own page 045
            temp_csa_group      = csa_group
        endif
        temp_csa_schedule   = csa_schedule
 
        rknt = 0
        stat = alterlist(tprint_req->job[jknt]->req,10)
    endif
 
    if (jknt > 0)
        rknt = rknt + 1
        if (mod(rknt,10) = 1 and rknt != 1)
            stat = alterlist(tprint_req->job[jknt]->req,rknt + 9)
        endif
 
        tprint_req->job[jknt]->req[rknt]->order_id = temp_req->qual[d.seq]->order_id
        tprint_req->job[jknt]->req[rknt]->print_dea   = temp_req->qual[d.seq]->print_dea
        tprint_req->job[jknt]->req[rknt]->csa_sched = csa_schedule
        tprint_req->job[jknt]->req[rknt]->start_dt = format(cnvtdatetime(temp_req->
            qual[d.seq]->start_date),"mm/dd/yyyy;;d")
        tprint_req->job[jknt]->req[rknt]->action_dt = format(cnvtdatetime(temp_req->
            qual[d.seq]->action_dt_tm),"mm/dd/yyyy;;d")
 
        tprint_req->job[jknt]->req[rknt]->med_knt = temp_req->qual[d.seq]->med_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->med,tprint_req->job[jknt]->
            req[rknt]->med_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->med_knt)
            tprint_req->job[jknt]->req[rknt]->med[z]->disp = temp_req->qual[d.seq]->med[z]->
                disp
        endfor
 
        ;; EPCS - copy the multi-line label text from temp_req->qual[d.seq]->sec_att_msg_row[] array
        ;  to tprint_req->job[jknt]->req[rknt]->sec_att[] using sec_att_msg_line_count for iterating through the array
        tprint_req->job[jknt]->req[rknt]->sec_att_knt = temp_req->qual[d.seq]->sec_att_msg_line_count
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->sec_att,tprint_req->job[jknt]->req[rknt]->sec_att_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->sec_att_knt)
            tprint_req->job[jknt]->req[rknt]->sec_att [z]->disp = temp_req->qual[d.seq]->sec_att_msg_row[z]->disp
        endfor
        ; EPCS - copy the routing pharmacy name, this will be empty text unless routing had failed
        ; in which case the pharmacy where routing failed has to be printed as a label too
        tprint_req->job[jknt]->req[rknt]->erx_pharmacy_name = temp_req->qual[d.seq]->routing_pharmacy_name
        tprint_req->job[jknt]->req[rknt]->erx_routing_dt_tm =
            format (cnvtdatetime (temp_req->qual[d.seq ].routing_dt_tm ) ,"mm/dd/yyyy hh:mm;;d" )
        tprint_req->job[jknt]->req[rknt]->sig_knt = temp_req->qual[d.seq]->sig_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->sig,tprint_req->job[jknt]->
            req[rknt]->sig_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->sig_knt)
            tprint_req->job[jknt]->req[rknt]->sig[z]->disp = temp_req->qual[d.seq]->sig[z]->
                disp
        endfor
 
	if (temp_req->qual[d.seq]->dispense_knt > 0)	;*** MOD 007
	    tprint_req->job[jknt]->req[rknt]->dispense_knt = temp_req->qual[d.seq]->dispense_knt
	    stat = alterlist(tprint_req->job[jknt]->req[rknt]->dispense,tprint_req->job[jknt]->
	        req[rknt]->dispense_knt)
	    for (z = 1 to tprint_req->job[jknt]->req[rknt]->dispense_knt)
	        tprint_req->job[jknt]->req[rknt]->dispense[z]->disp = temp_req->qual[d.seq]->
	            dispense[z]->disp
	    endfor
	;BEGIN MOD 007
	else
	    tprint_req->job[jknt]->req[rknt]->dispense_duration_knt = temp_req->qual[d.seq]->dispense_duration_knt
	    stat = alterlist(tprint_req->job[jknt]->req[rknt]->dispense_duration,tprint_req->job[jknt]->
	        req[rknt]->dispense_duration_knt)
	    for (z = 1 to tprint_req->job[jknt]->req[rknt]->dispense_duration_knt)
	       tprint_req->job[jknt]->req[rknt]->dispense_duration[z]->disp =
	         temp_req->qual[d.seq]->dispense_duration_qual[z]->disp
	    endfor
	endif
	;END MOD 007
 
        tprint_req->job[jknt]->req[rknt]->refill_knt = temp_req->qual[d.seq]->refill_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->refill,tprint_req->job[jknt]->
            req[rknt]->refill_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->refill_knt)
            tprint_req->job[jknt]->req[rknt]->refill[z]->disp = temp_req->qual[d.seq]->refill[z]->disp
        endfor
 
        tprint_req->job[jknt]->req[rknt]->special_knt = temp_req->qual[d.seq]->special_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->special,tprint_req->job[jknt]->
            req[rknt]->special_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->special_knt)
            tprint_req->job[jknt]->req[rknt]->special[z]->disp = temp_req->qual[d.seq]->
                special[z]->disp
        endfor
 
 
        ;046
        tprint_req->job[jknt]->req[rknt]->ICD10_knt = temp_req->qual[d.seq]->ICD10_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->ICD10,tprint_req->job[jknt]->
            req[rknt]->ICD10_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->ICD10_knt)
            tprint_req->job[jknt]->req[rknt]->ICD10[z]->disp = temp_req->qual[d.seq]->
                ICD10[z]->disp
        endfor
 
        tprint_req->job[jknt]->req[rknt]->prn_knt = temp_req->qual[d.seq]->prn_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->prn,tprint_req->job[jknt]->
            req[rknt]->prn_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->prn_knt)
            tprint_req->job[jknt]->req[rknt]->prn[z]->disp = temp_req->qual[d.seq]->prn[z]->
                disp
        endfor
 
        tprint_req->job[jknt]->req[rknt]->indic_knt = temp_req->qual[d.seq]->indic_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->indic,tprint_req->job[jknt]->
            req[rknt]->indic_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->indic_knt)
            tprint_req->job[jknt]->req[rknt]->indic[z]->disp = temp_req->qual[d.seq]->
                indic[z]->disp
        endfor
 
        tprint_req->job[jknt]->req[rknt]->comment_knt = temp_req->qual[d.seq]->comment_knt
        stat = alterlist(tprint_req->job[jknt]->req[rknt]->comment,tprint_req->job[jknt]->
            req[rknt]->comment_knt)
        for (z = 1 to tprint_req->job[jknt]->req[rknt]->comment_knt)
            tprint_req->job[jknt]->req[rknt]->comment[z]->disp = temp_req->qual[d.seq]->
                comment[z]->disp
        endfor
    endif
 
foot report
    tprint_req->job_knt = jknt
    stat = alterlist(tprint_req->job,jknt)
 
    tprint_req->job[jknt]->req_knt = rknt
    stat = alterlist(tprint_req->job[jknt]->req,rknt)
with nocounter
 
 
set iErrCode = error(sErrMsg,1)
if (iErrCode > 0)
    set failed = SELECT_ERROR
    set table_name = "BUILD_TPRINT"
    go to EXIT_SCRIPT
endif
 
call echorecord(demo_info)
call echorecord(temp_req)
free record temp_req
call echorecord(tprint_req)
 
if (tprint_req->job_knt = 0)			;019
	call echo("No print job found!",1)	;019
	go to EXIT_SCRIPT                       ;019
endif                                           ;019
 
;------------------------------------------------------------------------------
 
/****************************************************************************
*       Print Requisition                                                   *
*****************************************************************************/
if (size(request->printer_name,1) > 0)     ;034     ;*** MOD 015
   select into value(request->printer_name)                 ;*** MOD 015
   from
     (dummyt d with seq=value(tprint_req->job_knt))         ;*** MOD 015
   plan d where tprint_req->job[d.seq]->output_dest_cd < 1  ;*** MOD 015
   order d.seq                                              ;*** MOD 015
   head report
 
;%i cclsource:RXREQGEN_PRINT_MACROS.INC
 
;***
;***  Print Macros
;***
;***  Special Notes: Based off of original print macros include file
;***                 written by Steven Farmer
;***
;***  000   02/14/03 JF8275   Initial Release
;***  001   12/03/03 BP9613   Adding dispense_duration for EasyScript Supply
;***							calculation.
;***  002   01/15/04 JF8275   Shortened line for DEA #
;***  003   07/09/04 IT010631 Refill and Mid-level Enhancement
;***  004   01/07/05 BP9613   Replacing job[i] with job[d.seq]
 
/****************************************************************************
*       print page frame                                                    *
*****************************************************************************/
macro (print_page_frame)
; CALL PRINTIMAGE ( "sr_logo.frm" )
;	;CALL PRINT (CALCPOS(275,60))
;	;CALL PRINT (CALCPOS(x_pos+10,y_pos+20))
;	CALL PRINT (CALCPOS(170,49))
;	CALL PRINTIMAGE ( "sr_logo.dct" )
;	row+1
call printimage("cer_script:chstn_logo.frm")
 
      ;call print(calcpos(406,65))
      call print(calcpos(350,75))
   call echorecord(tprint_req)
     ; row +1
      call printimage("cer_script:chstn_logo.dct")
      row +2
    ;*** print header
    req_title = tprint_req->job[d.seq]->fac_name  ; ar051237
;
    "{f/4}{lpi/12}"
    y_pos = header_top_pos
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "{cpi/8}{b}",req_title,"{endb}{cpi/12}"
    row + 1
 
    if (size(tprint_req->job[d.seq]->fac_addr1 ,1) > 0)     ; ar051237
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->fac_addr1
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->fac_addr2 ,1) > 0)     ; ar051237
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->fac_addr2
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->fac_addr3 ,1) > 0)     ; ar051237
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->fac_addr3
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->fac_addr4 ,1) > 0)     ; ar051237
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->fac_addr4
        row + 1
    endif
 
 
 
 
    ;*** patient information
    y_pos = patient_top_pos
    x_pos = b_pos
 
    call print(calcpos(x_pos,y_pos))
    "{b}{lpi/10}{color/31}{box/82/1}{endb}" ;003
    row + 1
 
    call print(calcpos(x_pos,y_pos))
    "{b}{lpi/10}{color/31}{box/82/1}{endb}"
    row + 1
 
    y_pos = y_pos + 10
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}Patient Name:  ",demo_info->pat_name,"{endb}{cpi/12}"
    row + 1
 
    y_pos = y_pos + 4
    x_pos = b_pos
    call print(calcpos(x_pos,y_pos))
    "{b}{color/31}{cpi/12}{lpi/12}{box/82/1}{endb}"
    row + 1
 
    call print(calcpos(x_pos,y_pos))
    "{b}{color/31}{cpi/12}{lpi/12}{box/82/10}{endb}"
    row + 1
 
    "{cpi/12}{lpi/12}"
    y_pos = y_pos + 10
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Birthdate:  ",demo_info->pat_bday
    row + 1
 
    x_pos = g_pos
    call print(calcpos(x_pos,y_pos)) "Age:  ", demo_info->pat_age
    row + 1
 
    x_pos = h_pos
    call print(calcpos(x_pos,y_pos)) "Sex:  ", demo_info->pat_sex
    row + 1
 
    x_pos = i_pos
    call print(calcpos(x_pos-20,y_pos)) "MRN:  ", tprint_req->job[d.seq]->mrn
    row + 1
 
    x_pos = ii_pos	;051
    call print(calcpos(x_pos-20,y_pos)) "FIN:  ", tprint_req->job[d.seq]->finnbr	;051
    row + 1	;051
 
    y_pos = y_pos + 2_line
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Allergies:"
    row + 1
 
    if (demo_info->allergy_knt > 0)
        for (x = 1 to demo_info->allergy_knt)
            if (x < 4)  ;*** Max of 3 lines printed
                x_pos = c_pos + 45
                call print(calcpos(x_pos,y_pos)) "{b}",demo_info->allergy[x]->disp,"{endb}"
                y_pos = y_pos + 2_line
                row + 1
            endif
        endfor
    endif
 
    y_pos = pat_addr_top_pos - 18
    x_pos = f_pos + 30
    call print(calcpos(x_pos,y_pos)) "{cpi/12}Pharmacist please note--Allergy list may be incomplete.{cpi/12}"
    row + 1
 
    ;*** address
    y_pos = pat_addr_top_pos
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Patient Address:"
    row + 1
    x_pos = f_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_addr
    row + 1
 
    x_pos = j_pos
    call print(calcpos(x_pos,y_pos)) "Home Phone:"
    row + 1
    x_pos = n_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_hphone
    row + 1
 
    y_pos = y_pos + 2_line
    x_pos = f_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_city
    row + 1
 
    x_pos = j_pos
    call print(calcpos(x_pos,y_pos)) "Work Phone:"
    row + 1
    x_pos = n_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_wphone
    row + 1
 ;sr
 
    if(textlen(trim(pref_pharma,3))>0)
        x_pos = c_pos			;051
    	y_pos = pref_pharm_pos		;051
    	call print(calcpos(x_pos,y_pos)) "Preferred Pharmacy: "	;051
    	row + 1
 
        x_pos = f_pos			;051
        y_pos = pref_pharm_pos	;051
    	call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->prf_pharma	;051
    	row + 1
    endif
 
;    if(textlen(trim(pharma_phone,3))>0)
;
;        call print(calcpos(65,y_pos)) "Ph : "
;        call print(calcpos(148,y_pos)) tprint_req->job[d.seq]->pharma_ph
;        row + 1
;    endif
 
; 003 Requirements state that health plan information no longer needed
/*
    if (tprint_req->job[d.seq]->hp_found = TRUE)
        y_pos = y_pos + 2_line
        x_pos = c_pos
        call print(calcpos(x_pos,y_pos)) "Primary Health Plan:"
        row + 1
        x_pos = f_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->hp_pri_name
        row + 1
 
        x_pos = j_pos
        call print(calcpos(x_pos,y_pos)) "Policy/Group #:"
        row + 1
        x_pos = n_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->hp_pri_polgrp
        row + 1
 
        y_pos = y_pos + 2_line
        x_pos = c_pos
        call print(calcpos(x_pos,y_pos)) "Secondary Health Plan:"
        row + 1
        x_pos = f_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->hp_sec_name
        row + 1
 
        x_pos = j_pos
        call print(calcpos(x_pos,y_pos)) "Policy/Group #:"
        row + 1
        x_pos = n_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->hp_sec_polgrp
        row + 1
    endif
*/
    ;*** body
    y_pos = body_top_pos + hp_offset
    x_pos = b_pos
    call print(calcpos(x_pos,y_pos))
    "{color/31}{lpi/10}{cpi/12}{box/82/1}" ;003
    row + 1
 
    call print(calcpos(x_pos,y_pos))
    "{b}{color/31}{lpi/10}{cpi/12}{box/82/1}{endb}"
    row + 1
 
    y_pos = y_pos + 10
    x_pos = c_pos
    "{cpi/10}{lpi/12}"
    if (tprint_req->job[d.seq].refill_ind = TRUE)
        call print(calcpos(x_pos,y_pos)) "{b}",refill_rx_text,"{endb}"
    else
        call print(calcpos(x_pos,y_pos)) "{b}",new_rx_text,"{endb}"
    endif
 
    ;MOD 003 Start
 
    x_pos = k_pos - 20
    call print(calcpos(x_pos,y_pos)) "{cpi/10}{lpi/12}{b}Date Issued: ", tprint_req->job[d.seq]->phys_ord_dt ,"{endb}"
 
    ;MOD 003 End
 
    row + 1
 
    ; set starting position for large box for prescription details
    y_pos = y_pos + 4
    x_pos = b_pos
    call print(calcpos(x_pos,y_pos))
    if (hp_offset > 0)
        "{color/31}{cpi/12}{lpi/12}{b}{box/82/65}"
    else
        "{color/31}{cpi/12}{lpi/12}{b}{box/82/70}"
    endif
    row + 1
 
    y_pos = rx_top_pos + hp_offset
    clean_frame = TRUE
    current_row_knt = 0
    first_req = FALSE
 
    if (is_last_page = FALSE)
        stamp_dea = FALSE
        stamp_att = TRUE
    endif
 
endmacro ;*** print_page_frame
 
/****************************************************************************
*       does_req_fit                                                        *
*****************************************************************************/
macro (does_req_fit)
 
    req_fit = TRUE
    temp_row_knt = current_row_knt
    temp_row_knt = temp_row_knt +
                   (tprint_req->job[d.seq]->req[j]->med_knt +
                    tprint_req->job[d.seq]->req[j]->sig_knt +
                    tprint_req->job[d.seq]->req[j]->dispense_knt +
                    tprint_req->job[d.seq]->req[j]->dispense_duration_knt + ;*** MOD 001
                    tprint_req->job[d.seq]->req[j]->refill_knt +
                    tprint_req->job[d.seq]->req[j]->special_knt +
                    tprint_req->job[d.seq]->req[j]->ICD10_knt +    ;046
                    tprint_req->job[d.seq]->req[j]->prn_knt +
                    tprint_req->job[d.seq]->req[j]->indic_knt +
                    tprint_req->job[d.seq]->req[j]->comment_knt + 15)
    if (temp_row_knt > max_row_knt)
        req_fit = FALSE
    endif
 
endmacro ;*** does_req_fit
 
/****************************************************************************
*       print_rx                                                            *
*****************************************************************************/
macro (print_rx)
 
    "{f/4}{cpi/12}{lpi/12}"
    row + 1
 
    if (tprint_req->job[d.seq]->req[j]->med_knt > 0)
 
        if (is_last_page = FALSE)
            if (tprint_req->job[d.seq]->req[j].csa_sched != "0")
                stamp_att = FALSE
            endif
            if (tprint_req->job[d.seq]->req[j].print_dea = 1)
                stamp_dea = TRUE
            endif
        endif
 
        clean_frame = FALSE
 
        ;*** Do Rx
        if (req_fit = FALSE and break_field = "MED")
            x_pos = c_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb} page",
                " prescription ---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        for (x = 1 to tprint_req->job[d.seq]->req[j]->med_knt)
 
            if (x = 1)
                x_pos = c_pos
                call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}Rx:{endb}{cpi/12}"
                row + 1
 
                x_pos = c_pos + 25
                call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}",tprint_req->job[d.seq]->req[j]->med[x]->disp,"{endb}{cpi/12}"
                row + 1
 
                x_pos = k_pos
                call print(calcpos(x_pos,y_pos)) "Date Written:  {b}",tprint_req->job[d.seq]->req[j]->action_dt,"{endb}"
                row + 1
 
            else
                x_pos = c_pos + 25
                call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}", tprint_req->job[d.seq]->req[j]->med[x]->disp,"{endb}{cpi/12}"
                row + 1
            endif
            y_pos = y_pos + 2_line
            current_row_knt = current_row_knt + 1
        endfor
 
        ;call print(calcpos(x_pos,y_pos)),x_pos
 
/*sline = fillstring(25," ")
for (z = 2 to 29)
    sline = build("Line Number :",z)
    x_pos = rx_detail_pos
    call print(calcpos(x_pos,y_pos)) "{b}",sline,"{endb}"
    y_pos = y_pos + 2_line
    row+1
endfor
x_pos = b_pos + 5
call print(calcpos(x_pos,y_pos)) sep_line
row + 1
y_pos = y_pos + 2_line*/
;print_footer
 
 
           ; EPCS label for controlled substances
           if (tprint_req->job[d.seq]->req[j]->sec_att_knt > 0)
    	       for (x = 1 to tprint_req->job[d.seq]->req[j]->sec_att_knt)
                if (x = 1)
           x_pos = d_pos
           call print(calcpos(x_pos,y_pos)) "NOTE:"
           row + 1
           x_pos = rx_detail_pos
				    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->sec_att [x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
				    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->sec_att [x]->disp,"{endb}"
                endif
                row + 1
           y_pos = y_pos + 2_line
           current_row_knt = current_row_knt + 1
	           endfor
 
             if (tprint_req->job[d.seq]->req[j]->erx_pharmacy_name != "")
               x_pos = d_pos
               call print(calcpos(x_pos,y_pos)) "Pharmacy:"
               x_pos = rx_detail_pos
 
           call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->erx_pharmacy_name,
           		" (", tprint_req->job[d.seq]->req[j]->erx_routing_dt_tm, ")", "{endb}"
        	       row + 1
           y_pos = y_pos + 2_line
           current_row_knt = current_row_knt + 1
             endif
           endif
        ;*** do sig
        if (req_fit = FALSE and break_field = "SIG")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb} page ",
                "prescription ---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->sig_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->sig_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "SIG:"
                    row + 1
 
                    x_pos = k_pos	;051
					call print(calcpos(x_pos,y_pos)) "Fill Date:   {b}",tprint_req->job[d.seq]->req[j]->start_dt,"{endb}" ;051
                	row + 1   ;051
 
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->sig[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->sig[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do dispense
        if (req_fit = FALSE and break_field = "DISPENSE")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->dispense_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->dispense_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Dispense/Supply:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->dispense[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->dispense[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do dispense duration
        ;BEGIN MOD 001
        if (req_fit = FALSE and break_field = "DISPENSE_DURATION")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->dispense_duration_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->dispense_duration_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Dispense/Supply:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->dispense_duration[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->dispense_duration[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
        ;END MOD 001
 
        ;*** do refill
        if (req_fit = FALSE and break_field = "REFILL")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->refill_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->refill_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Refill:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->refill[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->refill[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        else
             x_pos = d_pos
             call print(calcpos(x_pos,y_pos)) "Refill:","{b}","    0 (zero)","{endb}"
             row + 1
             row + 1
             y_pos = y_pos + 2_line
             current_row_knt = current_row_knt + 1
        endif
 
        call echo(build("ar_refill:",tprint_req->job[d.seq]->req[j]->refill_knt))
 
        ;*** do special
        if (req_fit = FALSE and break_field = "SPECIAL")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->special_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->special_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Instructions:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->special[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->special[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
 		;*** do ICD10  ;046
        if (req_fit = FALSE and break_field = "ICD10")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->ICD10_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->ICD10_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Dx Code(s):"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->ICD10[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->ICD10[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do prn
        if (req_fit = FALSE and break_field = "PRN")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->prn_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->prn_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "PRN Instructions:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->prn[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->prn[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do indic
        if (req_fit = FALSE and break_field = "INDIC")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->indic_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->indic_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Indications:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->indic[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->indic[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do comment
        if (req_fit = FALSE and break_field = "COMMENT")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->comment_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->comment_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Comments:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->comment[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->comment[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        x_pos = b_pos + 5
        call print(calcpos(x_pos,y_pos)) sep_line
        row + 1
        y_pos = y_pos + 2_line
        current_row_knt = current_row_knt + 1
 
        if (is_last_page = TRUE)
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}LAST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            is_last_page = FALSE
        endif
    endif
 
endmacro ;*** print_rx
 
/****************************************************************************
*       find_break_field                                                    *
*****************************************************************************/
macro (find_break_field)
 
    found_it = FALSE
    temp_row_knt = 0
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->med_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "MED"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->sig_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "SIG"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->dispense_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "DISPENSE"
    endif
 
    ;BEGIN MOD 001
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->dispense_duration_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "DISPENSE_DURATION"
    endif
    ;END MOD 001
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->refill_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "REFILL"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->special_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "SPECIAL"
    endif
    ;046 - ICD10
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->ICD10_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "ICD10"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->prn_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "PRN"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->indic_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "INDIC"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[d.seq]->req[j]->comment_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "COMMENT"
    endif
 
endmacro ;*** find_break_field
 
/****************************************************************************
*       print_footer                                                        *
*****************************************************************************/
macro (print_footer)
 
    y_pos = y_pos + 2_5_line
    temp_y_pos = y_pos
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "{b}",signature_line,"{endb}"
    row + 1
    x_pos = j_pos - 20
    call print(calcpos(x_pos-20,y_pos)) "{b}",signature_line,"_______","{endb}"
    row + 1
 
    y_pos = y_pos + 2_line
    x_pos = c_pos + 38
    call print(calcpos(x_pos,y_pos)) "{b}DISPENSE AS WRITTEN{endb}"
    row + 1
    x_pos = j_pos
    call print(calcpos(x_pos-20,y_pos)) "{b}GENERIC SUBSTITUTION PERMITTED{endb}"
    row + 1
 
    y_pos = y_pos + 3_line
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Prescribed by: {b}",tprint_req->job[d.seq]->phys_bname,"{endb}"
    row+1
 
 
    if (size(tprint_req->job[d.seq]->phys_addr1,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->phys_addr1
        row + 1
    endif
 
 
    if (size(tprint_req->job[d.seq]->phys_addr2,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->phys_addr2
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->phys_addr3,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->phys_addr3
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->phys_city,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->phys_city
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->phys_addr4,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->phys_addr4
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->phys_phone,1) > 0)     ;ar051237
        row + 2
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) "Phone number : ", tprint_req->job[d.seq]->phys_phone
        row + 1
    endif
 
    if (size(tprint_req->job[d.seq]->phys_fax,1) > 0)     ;ar051237
        row + 2
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) "Fax : ", tprint_req->job[d.seq]->phys_fax
        row + 1
    endif
 
/*
    x_pos = g_pos + 30
    call print(calcpos(x_pos,y_pos)) "Date:"
    row + 1
    x_pos = x_pos + 26
    call print(calcpos(x_pos,y_pos)) tprint_req->job[d.seq]->phys_ord_dt
    row + 1
*/
 
    if (stamp_dea = TRUE)
        x_pos = j_pos + 8
        if (size(tprint_req->job[d.seq]->phys_dea,1) > 0)     ;034
            call print(calcpos(x_pos,y_pos))"DEA #:  ",tprint_req->job[d.seq]->phys_dea ;003
        else
            call print(calcpos(x_pos,y_pos))"DEA #:  _______________" ;002 and 003
        endif
        row + 1
    endif
 
 	/*** start 028 ***/
    if (size(tprint_req->job[d.seq]->phys_npi,1) > 0)     ;034
		y_pos = y_pos + 2_line
		x_pos = j_pos + 8
		call print(calcpos(x_pos,y_pos))"NPI #:  ",tprint_req->job[d.seq]->phys_npi
		row + 1
    endif
 	/*** end 028 ***/
 
    ;MOD 003 Start - Writes the Supervising Physician field if sup_phys_bname is populated
 
    if (size(tprint_req->job[d.seq]->sup_phys_bname,1) > 0)     ;034
        x_pos = c_pos
        y_pos = y_pos + 3_line
        call print(calcpos(x_pos,y_pos)) "Supervising Physician: {b}",tprint_req->job[d.seq]->sup_phys_bname,"{endb}"
        row+1
 
        ;003 See if DEA box is checked and put DEA if TRUE
 
        if (stamp_dea = TRUE)
            x_pos = j_pos + 8
            if (size(tprint_req->job[d.seq]->sup_phys_dea,1) > 0)     ;034
                 call print(calcpos(x_pos,y_pos))"DEA #:  ",tprint_req->job[d.seq]->sup_phys_dea
            else
                 call print(calcpos(x_pos,y_pos))"DEA #:  _______________" ;002
            endif
        row + 1
        endif
 
        /*** start 028 ***/
	   	if (size(tprint_req->job[d.seq]->sup_phys_npi,1) > 0)     ;034
			y_pos = y_pos + 2_line
			x_pos = j_pos + 8
			call print(calcpos(x_pos,y_pos))"NPI #:  ",tprint_req->job[d.seq]->sup_phys_npi
			row + 1
		endif
		/*** end 028 ***/
    endif
    ;MOD 003 Stop
 
    if (tprint_req->job[d.seq]->eprsnl_ind = TRUE)
        y_pos = y_pos + 2_line
        x_pos = c_pos
        call print(calcpos(x_pos,y_pos)) "Entered by: {b}",tprint_req->job[d.seq]->eprsnl_bname,"{endb}"
        row+1
    endif
 ;sr
  y_pos = y_pos + 2_line
  y_pos = y_pos + 2_line
  y_pos = y_pos + 2_line
;  call print(calcpos(65,y_pos)) "{b}",signature_line,"{endb}" ;045
;  y_pos = y_pos + 2_line                                      ;045
;  call print(calcpos(130,y_pos)) "{b}(Signature){endb}"       ;045
 
 
    if (stamp_att = TRUE)
        y_pos = y_pos + 2_line
        x_pos = f_pos + 20
        call print(calcpos(x_pos,y_pos)) "{cpi/16}{b}ATTENTION: THIS RX NOT VALID FOR CONTROLLED SUBSTANCES{endb}{cpi/12}"
        row + 1
    endif
 
    y_pos = temp_y_pos - 3
 
    if (tprint_req->job[d.seq]->daw > 0)
        x_pos = c_pos     ;*** Dispense As Written
    else
        x_pos = j_pos     ;*** Substitution Permitted
    endif
    row + 1
;    if (tprint_req->job[d.seq].csa_group >= "C")                                                        ;045
;        call print(calcpos(x_pos-40,y_pos)) "{b}",tprint_req->job[d.seq]->phys_bname," {endb} (E-Sig.)" ;045
;    else
        call print(calcpos(x_pos,y_pos)) "{b}X{endb}"
;    endif                                                                                               ;045
    row + 1
 
endmacro ;*** print_footer
 
 
       y_pos = 0
       x_pos = 0
 
       ; The following are used to position data in the proper x position, to allow
       ; for easy x_pos modification for similarly positioned data
 
       a_pos =  72      ; header
       b_pos =  57      ; left side of boxes
       c_pos =  65      ; patient name label, signature lines
       d_pos =  79      ; SIG label,other RX labels on left
       e_pos = 194      ; pharmacist note
       f_pos = 165      ; patient address data
       g_pos = 175      ; Age label		;051 changed from 234 to 175
       h_pos = 250      ; Sex label		;051 changed from 347 to 250
       i_pos = 350      ; MRN label		;051 changed from 459 to 350
       ii_pos = 475  	; FIN label		;051 added
       j_pos = 350      ; Home Phone, other similar labels
       k_pos = 450      ; Start Date label
       l_pos = 392      ; DAW label
       m_pos = 320      ; Provider signature line
       n_pos = 423      ; phone and policy data
 
       ; The following are used to position data in the proper y position, to allow
       ; for easy y_pos modification for similarly positioned data
 
       header_top_pos   = 36       ; starting y_pos for header info
       patient_top_pos  = 96
       body_top_pos     = 220
       rx_top_pos       = 250
       pat_addr_top_pos = 192
       pref_pharm_pos   = 215		;051 - Preferrered Pharmacy y_pos location
       body_bottom_pos  = 705
       rx_detail_pos    = 155
 
       call echo("***")
       call echo(build("***   hp_found :",tprint_req->job[d.seq]->hp_found))
       call echo("***")
       if (tprint_req->job[d.seq]->hp_found = TRUE)
          hp_offset        = 20
       else
          hp_offset        = 0
       endif
 
       ; The following are used to determine the amount of vertical line space
       half_line = 3
       1_line    = 6
       1_5_line  = 9
       2_line    = 12
       2_5_line  = 15
       3_line    = 18
       3_5_line  = 21
       4_line    = 24
       req_fit         = FALSE
       clean_frame     = FALSE
       break_field     = fillstring(12," ")
       signature_line  = fillstring(40,"_")
       sep_line        = fillstring(87,"-")
       name_line       = fillstring(50," ")
       if (tprint_req->job[d.seq]->hp_found = TRUE)
          max_row_knt     = 29
          current_row_knt = 29
       else
          max_row_knt     = 32
          current_row_knt = 32
       endif
       first_req       = TRUE
       is_last_page    = FALSE
       stamp_dea       = FALSE
       stamp_att       = TRUE
 
   head d.seq           ;*** MOD 015
       place_holder = 0 ;*** MOD 015
 
   detail
       for (j = 1 to tprint_req->job[d.seq]->req_knt)
           does_req_fit
           if (req_fit = TRUE)
              print_rx
              if (j = tprint_req->job[d.seq]->req_knt)
                 print_footer
              endif
           else
              if (clean_frame = FALSE)
                 if (j != 1)
                    print_footer
;                    break   ;045
                    row+1  ;045
                    "{np}" ;045
                    ;;page_num = page_num + 1
                 endif
                 print_page_frame
                 does_req_fit
                 if (req_fit = TRUE)
                    print_rx
                    if (j = tprint_req->job[d.seq]->req_knt)
                       print_footer
                    endif
                 else
                    find_break_field
                    print_rx
                    print_footer
                    if (j != tprint_req->job[d.seq]->req_knt)
;                       break   ;045
                       row+1  ;045
                       "{np}" ;045
                       print_page_frame
                    endif
                 endif
              else
                 find_break_field
                 print_rx
                 print_footer
                 if (j != tprint_req->job[d.seq]->req_knt)
;                    break   ;045
                    row+1  ;045
                    "{np}" ;045
                    print_page_frame
                 endif
              endif
           endif
       endfor
 
   foot d.seq                            ;*** MOD 015
       if (d.seq < tprint_req->job_knt)  ;*** MOD 015
          row+1
          "{np}"                   ;*** MOD 015
          print_page_frame               ;*** MOD 015
       endif                             ;*** MOD 015
 
   with
       nocounter,
 
       maxrow = 120,
       maxcol = 256,
       dio = 8
       ,noformfeed;sr
endif
 
 
/****************************************************************************
*       Fax Requisition                                                     *
*****************************************************************************/
;*** MOD 015 Keeping the the same grouping for fax jobs
for (i = 1 to tprint_req->job_knt)
   if (tprint_req->job[i]->output_dest_cd > 0)
 
   set toad = 1
   set file_name = concat("cer_print:",trim(cnvtlower(username)),"_",		;023
       trim(cnvtstring(tprint_req->job[i]->req[1]->order_id)),"_",          ;038
       trim(cnvtstring(curtime3,7,0,r)),"_",trim(cnvtstring(i)),".dat")
 
   call echo ("***")
   call echo (build("***   file_name :",file_name))
   call echo ("***")
 
   set tprint_req->job[i]->print_loc = trim(file_name)
   select into value(tprint_req->job[i]->print_loc)
   from
      (dummyt d with seq = 1)
 
   head report
 
;%i cclsource:RXREQGEN_RXFAX_MACROS.INC
 
;***
;***  RxFax Macros
;***
;***  Special Notes: Based off of original print macros include file
;***                 written by Steven Farmer
;***
;***  000   02/14/03 JF8275   Initial Release
;***  001   12/03/03 BP9613   Adding dispense_duration for EasyScript Supply
;***							calculation.
;***  002   01/15/04 JF8275   Shortened line for DEA #
;***  003   07/09/04 IT010631 Refill and Mid-level Enhancement
;***  004   02/22/07 AC013605 Added a meaningful report title
 
/****************************************************************************
*       print page frame                                                    *
*****************************************************************************/
macro (print_page_frame)
 
    ;*** print header
    req_title = tprint_req->job[i]->phys_addr1
 
    "{f/4}{lpi/12}"
    y_pos = header_top_pos
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "{cpi/8}{b}",req_title,"{endb}{cpi/12}"
    row + 1
 
    y_pos = y_pos + half_line
 
    if (size(tprint_req->job[i]->phys_addr2,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->phys_addr2
        row + 1
    endif
 
    if (size(tprint_req->job[i]->phys_addr3,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->phys_addr3
        row + 1
    endif
 
    if (size(tprint_req->job[i]->phys_city,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->phys_city
        row + 1
    endif
 
    if (size(tprint_req->job[i]->phys_addr4,1) > 0)     ;034
        y_pos = y_pos + 2_line
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->phys_addr4
        row + 1
    endif
 
    ;*** patient information
    y_pos = patient_top_pos + 10
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}/:  ",demo_info->pat_name,"{endb}{cpi/12}"
    row + 1
 
    y_pos = y_pos + 14
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Birthdate:  ",demo_info->pat_bday
    row + 1
 
    x_pos = g_pos
    call print(calcpos(x_pos,y_pos)) "Age:  ", demo_info->pat_age
    row + 1
 
    x_pos = h_pos
    call print(calcpos(x_pos,y_pos)) "Sex:  ", demo_info->pat_sex
    row + 1
 
    x_pos = i_pos
    call print(calcpos(x_pos,y_pos)) "MRN:  ", tprint_req->job[i]->mrn
    row + 1
 
    x_pos = ii_pos	;051
    call print(calcpos(x_pos,y_pos)) "FIN:  ", tprint_req->job[i]->finnbr	;051
    row + 1    	;051
 
    y_pos = y_pos + 2_line
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Allergies:"
    row + 1
 
    if (demo_info->allergy_knt > 0)
        for (x = 1 to demo_info->allergy_knt)
            if (x < 4)  ;*** Max of 3 lines printed
                x_pos = c_pos + 45
                call print(calcpos(x_pos,y_pos)) "{b}",demo_info->allergy[x]->disp,"{endb}"
                y_pos = y_pos + 2_line
                row + 1
            endif
        endfor
    endif
 
    y_pos = pat_addr_top_pos - 18
    x_pos = f_pos + 30
    call print(calcpos(x_pos,y_pos)) "{cpi/12}Pharmacist please note--Allergy list may be incomplete.{cpi/12}"
    row + 1
 
    ;*** address
    y_pos = pat_addr_top_pos
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Patient Address:"
    row + 1
    x_pos = f_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_addr
    row + 1
 
    x_pos = j_pos
    call print(calcpos(x_pos,y_pos)) "Home Phone:"
    row + 1
    x_pos = n_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_hphone
    row + 1
 
    y_pos = y_pos + 2_line
    x_pos = f_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_city
    row + 1
 
    x_pos = j_pos
    call print(calcpos(x_pos,y_pos)) "Work Phone:"
    row + 1
    x_pos = n_pos
    call print(calcpos(x_pos,y_pos)) demo_info->pat_wphone
    row + 1
 
; 003 Requirements state that health plan information no longer needed
/*
    if (tprint_req->job[i]->hp_found = TRUE)
        y_pos = y_pos + 2_line
        x_pos = c_pos
        call print(calcpos(x_pos,y_pos)) "Primary Health Plan:"
        row + 1
        x_pos = f_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->hp_pri_name
        row + 1
 
        x_pos = j_pos
        call print(calcpos(x_pos,y_pos)) "Policy/Group #:"
        row + 1
        x_pos = n_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->hp_pri_polgrp
        row + 1
 
        y_pos = y_pos + 2_line
        x_pos = c_pos
        call print(calcpos(x_pos,y_pos)) "Secondary Health Plan:"
        row + 1
        x_pos = f_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->hp_sec_name
        row + 1
 
        x_pos = j_pos
        call print(calcpos(x_pos,y_pos)) "Policy/Group #:"
        row + 1
        x_pos = n_pos
        call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->hp_sec_polgrp
        row + 1
    endif
*/
    "      "
    row + 1
 
    ;*** body
    y_pos = body_top_pos + hp_offset
    y_pos = y_pos + 10
    x_pos = c_pos
    if (tprint_req->job[i].refill_ind = TRUE)
        call print(calcpos(x_pos,y_pos)) "{b}",refill_rx_text,"{endb}"
    else
        call print(calcpos(x_pos,y_pos)) "{b}",new_rx_text,"{endb}"
    endif
 
    ;MOD 003 Start - Place Date on same line as rx_text
 
    x_pos = k_pos - 20
    call print(calcpos(x_pos,y_pos)) "{cpi/10}{lpi/12}{b}Date Issued: ", tprint_req->job[i]->phys_ord_dt ,"{endb}"
 
    ;MOD 003 Stop
 
    row + 1
 
    "        "
    row + 1
 
    y_pos = rx_top_pos + hp_offset
    clean_frame = TRUE
    current_row_knt = 0
    first_req = FALSE
 
    if (is_last_page = FALSE)
        stamp_dea = FALSE
        stamp_att = TRUE
    endif
 
endmacro ;*** print_page_frame
 
/****************************************************************************
*       does_req_fit                                                        *
*****************************************************************************/
macro (does_req_fit)
 
    req_fit = TRUE
    temp_row_knt= current_row_knt
    temp_row_knt = temp_row_knt +
                   (tprint_req->job[i]->req[j]->med_knt +
                    tprint_req->job[i]->req[j]->sig_knt +
                    tprint_req->job[i]->req[j]->dispense_knt +
                    tprint_req->job[i]->req[j]->dispense_duration_knt + ;*** MOD 001
                    tprint_req->job[i]->req[j]->refill_knt +
                    tprint_req->job[i]->req[j]->special_knt +
                    tprint_req->job[i]->req[j]->ICD10_knt +		;046
                    tprint_req->job[i]->req[j]->prn_knt +
                    tprint_req->job[i]->req[j]->indic_knt +
                    tprint_req->job[i]->req[j]->comment_knt + 1)
    if (temp_row_knt > max_row_knt)
        req_fit = FALSE
    endif
 
endmacro ;*** does_req_fit
 
/****************************************************************************
*       print_rx    (This macro is not being used                           *
*****************************************************************************/
macro (print_rx)
 
    "{f/4}{cpi/12}{lpi/12}"
    row + 1
 
    if (tprint_req->job[i]->req[j]->med_knt > 0)
 
        if (is_last_page = FALSE)
            if (tprint_req->job[i]->req[j].csa_sched != "0")
                stamp_att = FALSE
            endif
            if (tprint_req->job[i]->req[j].print_dea = 1)
                stamp_dea = TRUE
            endif
        endif
 
        clean_frame = FALSE
 
        ;*** Do Rx
        if (req_fit = FALSE and break_field = "MED")
            x_pos = c_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb} page",
                                             " prescription ---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        for (x = 1 to tprint_req->job[i]->req[j]->med_knt)
 
            if (x = 1)
                x_pos = c_pos
                call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}Rx:{endb}{cpi/12}"
                row + 1
 
                x_pos = c_pos + 25
                call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}",tprint_req->job[i]->req[j]->med[x]->disp,"{endb}{cpi/12}"
                row + 1
 
                x_pos = k_pos
                call print(calcpos(x_pos,y_pos)) "Date Written:  {b}",tprint_req->job[i]->req[j]->action_dt,"{endb}"
                row + 1
 
            else
                x_pos = c_pos + 25
                call print(calcpos(x_pos,y_pos)) "{cpi/10}{b}", tprint_req->job[i]->req[j]->med[x]->disp,"{endb}{cpi/12}"
                row + 1
            endif
 
            y_pos = y_pos + 2_line
            current_row_knt = current_row_knt + 1
        endfor
 
/*
sline = fillstring(25," ")
for (z = 2 to 30)
    sline = build("Line Number :",z)
    x_pos = rx_detail_pos
    call print(calcpos(x_pos,y_pos)) "{b}",sline,"{endb}"
    y_pos = y_pos + 2_line
    row+1
endfor
x_pos = b_pos + 5
call print(calcpos(x_pos,y_pos)) sep_line
row + 1
y_pos = y_pos + 2_line
print_footer
*/
 
        ;*** do sig
        if (req_fit = FALSE and break_field = "SIG")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb} page ",
                                             "prescription ---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->sig_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->sig_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "SIG:"
                    row + 1
 
                    x_pos = k_pos	;051
	                call print(calcpos(x_pos,y_pos)) "Fill Date:   {b}",tprint_req->job[d.seq]->req[j]->start_dt,"{endb}" ;051
                	row + 1   ;051
 
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->sig[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->sig[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do dispense
        if (req_fit = FALSE and break_field = "DISPENSE")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->dispense_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->dispense_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Dispense/Supply:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->dispense[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->dispense[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do dispense duration
        ;BEGIN MOD 001
        if (req_fit = FALSE and break_field = "DISPENSE_DURATION")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->dispense_duration_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->dispense_duration_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Dispense/Supply:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->dispense_duration[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->dispense_duration[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
        ;END MOD 001
 
        ;*** do refill
        if (req_fit = FALSE and break_field = "REFILL")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        call echo(build("ar1_refill:",tprint_req->job[d.seq]->req[j]->refill_knt))
        if (tprint_req->job[i]->req[j]->refill_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->refill_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Refill:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->refill[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->refill[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        else
            x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Refills: 0 (zero)"
                    row + 1
 
        endif
 
 
        ;*** do special
        if (req_fit = FALSE and break_field = "SPECIAL")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->special_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->special_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Instructions:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->special[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->special[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
  		;*** do ICD10  ;046
        if (req_fit = FALSE and break_field = "ICD10")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                          " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[d.seq]->req[j]->ICD10_knt > 0)
 
            for (x = 1 to tprint_req->job[d.seq]->req[j]->ICD10_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Dx Code(s):"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->ICD10[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[d.seq]->req[j]->ICD10[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do prn
        if (req_fit = FALSE and break_field = "PRN")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->prn_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->prn_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "PRN Instructions:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->prn[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->prn[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do indic
        if (req_fit = FALSE and break_field = "INDIC")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->indic_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->indic_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Indications:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->indic[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->indic[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        ;*** do comment
        if (req_fit = FALSE and break_field = "COMMENT")
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}FIRST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
            y_pos = y_pos + 2_line
            print_footer
            break
 
            is_last_page = TRUE
            print_page_frame
            clean_frame = FALSE
        endif
 
        if (tprint_req->job[i]->req[j]->comment_knt > 0)
 
            for (x = 1 to tprint_req->job[i]->req[j]->comment_knt)
 
                if (x = 1)
                    x_pos = d_pos
                    call print(calcpos(x_pos,y_pos)) "Comments:"
                    row + 1
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->comment[x]->disp,"{endb}"
                else
                    x_pos = rx_detail_pos
                    call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->req[j]->comment[x]->disp,"{endb}"
                endif
 
                row + 1
                y_pos = y_pos + 2_line
                current_row_knt = current_row_knt + 1
            endfor
        endif
 
        x_pos = b_pos + 5
        call print(calcpos(x_pos,y_pos)) sep_line
        row + 1
        y_pos = y_pos + 2_line
        current_row_knt = current_row_knt + 1
 
        "    "
        row + 1
 
        if (is_last_page = TRUE)
            x_pos = d_pos
            call print(calcpos(x_pos,y_pos)) "***--- Note: This is the {b}LAST{endb} page of a {b}2{endb}",
                                             " page prescription---***"
            row + 1
 
            "      "
            row + 1
 
            y_pos = y_pos + 2_line
            is_last_page = FALSE
        endif
    endif
 
endmacro ;*** print_rx
 
/****************************************************************************
*       find_break_field                                                    *
*****************************************************************************/
macro (find_break_field)
 
    found_it = FALSE
    temp_row_knt = 0
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->med_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "MED"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->sig_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "SIG"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->dispense_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "DISPENSE"
    endif
 
    ;BEGIN MOD 001
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->dispense_duration_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "DISPENSE_DURATION"
    endif
    ;END MOD 001
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->refill_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "REFILL"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->special_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "SPECIAL"
    endif
 	;046
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->ICD10_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "ICD10"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->prn_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "PRN"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->indic_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "INDIC"
    endif
 
    temp_row_knt = temp_row_knt + tprint_req->job[i]->req[j]->comment_knt
    if ((found_it = FALSE) and (temp_row_knt + 1 > max_row_knt))
        found_it = TRUE
        break_field = "COMMENT"
    endif
 
endmacro ;*** find_break_field
 
/****************************************************************************
*       print_footer                                                        *
*****************************************************************************/
macro (print_footer)
 
    "  "
    row + 1
 
    y_pos = y_pos + 2_5_line
    temp_y_pos = y_pos
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "{b}",signature_line,"{endb}"
    row + 1
    x_pos = j_pos
    call print(calcpos(x_pos,y_pos)) "{b}",signature_line,"{endb}"
    row + 1
 
    y_pos = y_pos + 2_line
    x_pos = c_pos + 38
    call print(calcpos(x_pos,y_pos)) "{b}DISPENSE AS WRITTEN{endb}"
    row + 1
    x_pos = j_pos + 30
    call print(calcpos(x_pos,y_pos)) "{b}SUBSTITUTION PERMITTED{endb}"
    row + 1
 
    y_pos = y_pos + 3_line
    x_pos = c_pos
    call print(calcpos(x_pos,y_pos)) "Prescribed by: {b}",tprint_req->job[i]->phys_bname,"{endb}"
    row+1
/*
    x_pos = g_pos + 30
    call print(calcpos(x_pos,y_pos)) "Date:"
    row + 1
    x_pos = x_pos + 26
    call print(calcpos(x_pos,y_pos)) tprint_req->job[i]->phys_ord_dt
    row + 1
*/
    if (stamp_dea = TRUE)
        x_pos = j_pos + 8
        if (size(tprint_req->job[i]->phys_dea,1) > 0)     ;034
            call print(calcpos(x_pos,y_pos))"DEA #:  ",tprint_req->job[i]->phys_dea ;003
        else
            call print(calcpos(x_pos,y_pos))"DEA #:  _______________" ;002 and 003
        endif
        row + 1
    endif
 
 	/*** start 028 ***/
	if (size(tprint_req->job[d.seq]->phys_npi,1) > 0)     ;034
		y_pos = y_pos + 2_line
		x_pos = j_pos + 8
		call print(calcpos(x_pos,y_pos))"NPI #:  ",tprint_req->job[d.seq]->phys_npi
		row + 1
    endif
 	/*** end 028 ***/
 
    ;MOD 003 Start - Writes the Supervising Physician field if sup_phys_bname is populated
 
    if (size(tprint_req->job[i]->sup_phys_bname,1) > 0)     ;034
        x_pos = c_pos
        y_pos = y_pos + 3_line
        call print(calcpos(x_pos,y_pos)) "Supervising Physician: {b}",tprint_req->job[i]->sup_phys_bname,"{endb}"
        row+1
 
        ;003 See if DEA box is checked and put DEA if TRUE
 
        if (stamp_dea = TRUE)
            x_pos = j_pos + 8
            if (size(tprint_req->job[i]->sup_phys_dea,1) > 0)     ;034
                 call print(calcpos(x_pos,y_pos))"DEA #:  ",tprint_req->job[i]->sup_phys_dea
            else
                 call print(calcpos(x_pos,y_pos))"DEA #:  _______________" ;002
            endif
        row + 1
        endif
 
         /*** start 028 ***/
	   	if (size(tprint_req->job[d.seq]->sup_phys_npi,1) > 0)     ;034
			y_pos = y_pos + 2_line
			x_pos = j_pos + 8
			call print(calcpos(x_pos,y_pos))"NPI #:  ",tprint_req->job[d.seq]->sup_phys_npi
			row + 1
		endif
		/*** end 028 ***/
    endif
 
    ;MOD 003 Stop
 
    if (tprint_req->job[i]->eprsnl_ind = TRUE)
        y_pos = y_pos + 2_line
        x_pos = c_pos
        call print(calcpos(x_pos,y_pos)) "Entered by: {b}",tprint_req->job[i]->eprsnl_bname,"{endb}"
        row+1
    endif
 
    if (stamp_att = TRUE)
        y_pos = y_pos + 2_line
        x_pos = f_pos + 20
        call print(calcpos(x_pos,y_pos)) "{cpi/16}{b}ATTENTION: THIS RX NOT VALID FOR CONTROLLED SUBSTANCES{endb}{cpi/12}"
        row + 1
    endif
 
    y_pos = temp_y_pos - 3
 
    if (tprint_req->job[i]->daw > 0)
        x_pos = c_pos     ;*** Dispense As Written
    else
        x_pos = j_pos     ;*** Substitution Permitted
    endif
 
    if (tprint_req->job[i].csa_group >= "C")
        call print(calcpos(x_pos,y_pos)) "{b}",tprint_req->job[i]->phys_bname," {endb} (E-Sig.)"
    else
        call print(calcpos(x_pos,y_pos)) "{b}X{endb}"
    endif
    row + 1
 
    "   "
    row + 1
 
endmacro ;*** print_footer
 
       y_pos = 0
       x_pos = 0
 
       ; The following are used to position data in the proper x position, to allow
       ; for easy x_pos modification for similarly positioned data
 
       a_pos =  72      ; header
       b_pos =  57      ; left side of boxes
       c_pos =  65      ; patient name label, signature lines
       d_pos =  79      ; SIG label,other RX labels on left
       e_pos = 194      ; pharmacist note
       f_pos = 165      ; patient address data
       g_pos = 175      ; Age label		;051 changed from 234 to 175
       h_pos = 250      ; Sex label		;051 changed from 347 to 250
       i_pos = 350      ; MRN label		;051 changed from 459 to 350
       ii_pos = 475  	; FIN label		;051 added
       j_pos = 350      ; Home Phone, other similar labels
       k_pos = 450      ; Start Date label
       l_pos = 392      ; DAW label
       m_pos = 320      ; Provider signature line
       n_pos = 423      ; phone and policy data
 
       ; The following are used to position data in the proper y position, to allow
       ; for easy y_pos modification for similarly positioned data
 
       header_top_pos   = 36       ; starting y_pos for header info
       patient_top_pos  = 96
       body_top_pos     = 220
       rx_top_pos       = 250
       pat_addr_top_pos = 192
       pref_pharm_pos   = 215		;051 - Preferrered Pharmacy y_pos location
       body_bottom_pos  = 705
       rx_detail_pos    = 155  ;*** y_pos
       if (tprint_req->job[i]->hp_found = TRUE)
          hp_offset        = 20
       else
          hp_offset        = 0
       endif
 
       ; The following are used to determine the amount of vertical line space
       half_line = 3
       1_line    = 6
       1_5_line  = 9
       2_line    = 12
       2_5_line  = 15
       3_line    = 18
       3_5_line  = 21
       4_line    = 24
       req_fit         = FALSE
       clean_frame     = FALSE
       break_field     = fillstring(12," ")
       signature_line  = fillstring(40,"_")
       sep_line        = fillstring(90,"-")
       name_line       = fillstring(50," ")
       if (tprint_req->job[i]->hp_found = TRUE)
          max_row_knt     = 29
          current_row_knt = 29
       else
          max_row_knt     = 32
          current_row_knt = 32
       endif
       first_req       = TRUE
       is_last_page    = FALSE
       stamp_dea       = FALSE
       stamp_att       = TRUE
 
   detail
       for (j = 1 to tprint_req->job[i]->req_knt)
           does_req_fit
           if (req_fit = TRUE)
              print_rx
              if (j = tprint_req->job[i]->req_knt)
                 print_footer
              endif
           else
              if (clean_frame = FALSE)
                 if (j != 1)
                    print_footer
                    break
                 endif
                 print_page_frame
                 does_req_fit
                 if (req_fit = TRUE)
                    print_rx
                    if (j = tprint_req->job[i]->req_knt)
                       print_footer
                    endif
                 else
                    find_break_field
                    print_rx
                    print_footer
                    if (j != tprint_req->job[i]->req_knt)
                       break
                       print_page_frame
                    endif
                 endif
              else
                 find_break_field
                 print_rx
                 print_footer
                 if (j != tprint_req->job[i]->req_knt)
                    break
                    print_page_frame
                 endif
              endif
           endif
       endfor
   with
       nocounter,
       maxrow = 120,
       maxcol = 255,
       dio = 36
 
       free record prequest
       record prequest
       (
         1 output_dest_cd   = f8
         1 file_name        = vc
         1 copies           = i4
         1 output_handle_id = f8  ; this field should never be passed in!
         1 number_of_pages  = i4
         1 transmit_dt_tm   = dq8
         1 priority_value   = i4
         1 report_title     = vc
         1 server           = vc
         1 country_code     = c3
         1 area_code        = c10
         1 exchange         = c10
         1 suffix           = c50
       )
 
       set prequest->output_dest_cd  = tprint_req->job[i]->output_dest_cd
       set prequest->file_name       = tprint_req->job[i]->print_loc
       set prequest->number_of_pages = 1
       set prequest->report_title = concat("RX","|",trim(cnvtstring(tprint_req->job[i]->req[1]->order_id)),"|",
       								trim(demo_info->pat_name),"|","0","|"," ","|"," ","|",trim(cnvtstring(demo_info->pat_id)),
       								"|",trim(cnvtstring(tprint_req->job[i]->eprsnl_id)),"|"," ","|","0")
 
       if (size(tprint_req->job[i]->free_text_nbr,1) > 0 and     ;034
           tprint_req->job[i]->free_text_nbr != "0")
           set prequest->suffix = tprint_req->job[i]->free_text_nbr
       endif
 
       free record preply
       record preply
       (
         1 sts = i4
         1 status_data
           2 status = c1
           2 subeventstatus[1]
             3 OperationName = c15
             3 OperationStatus = c1
             3 TargetOjbectName = c15
             3 TargetObjectValue = c100
       )
 
       call echo ("***")
       call echo ("***   Executing SYS_OUTPUTDEST_PRINT")
       call echo ("***")
       execute sys_outputdest_print with replace("REQUEST",prequest),replace("REPLY",preply)
       call echo ("***")
       call echo ("***   Finished executing SYS_OUTPUTDEST_PRINT")
       call echo ("***")
       call echorecord(preply)
   endif
endfor
 
;MOD 042 Begin - Subroutine which is used to spell out numbers
/****************************************************************************
*       SUBROUTINES                                                         *
*****************************************************************************/
DECLARE get_number_spellout(x=vc(VALUE)) = vc  ;053 - Changed from REF to VALUE
SUBROUTINE get_number_spellout(x)
 
	declare language_log = vc with private, noconstant("")
	set language_log = trim(cnvtupper(logical("CCL_LANG")),3)
 
	call echo("Lang *************************************")
	call echo(build("Lang:",language_log))
    call echo("******************************************")
 
    if (size(language_log) >= 2)
		if (substring(1,2,language_log) != "EN")
			return ("")
		endif
    endif
 
	declare index = i2 with private, noconstant(1)
 
	declare new_num = vc with private, noconstant("")
	set new_num = replace(x,",","")
 
	call echo("Comma Removal ****************************")
	call echo(build("new_num:",new_num))
    call echo("******************************************")
 
	declare int_x = i4 with private, constant(cnvtint(new_num))
    declare real_x = f8 with private, constant(cnvtreal(new_num))
	declare whole = vc with protect, noconstant("")
	declare below = vc with protect, noconstant("")
    declare over  = vc with protect, noconstant("")
    declare decimal_x = f8 with private, constant(round(real_x - cnvtreal(int_x),3))
 
    call echo("******************************************")
    call echo(build("decimal_x:",decimal_x))
	call echo(build("int_x:",int_x))
	call echo(build("real_x:",real_x))
    call echo("******************************************")
    if (decimal_x = 0)
    	call echo("in if")
		if (int_x < 0)
	    	return ("")
		endif
		if (int_x < 10)
			set index = (int_x + 1)
			return (trim(numbers->ones[index].value))
    	endif
    	if (int_x < 20)
        	set index = (int_x - 9)
        	return (trim(numbers->teens[index].value))
    	endif
    	if (int_x < 100)
 
        	set index = cnvtint(int_x / 10)
        	if (mod(int_x,10) = 0)
        	    return (trim(numbers->tens[index].value))
        	else
            	return (trim(concat(numbers->tens[index].value,"-", numbers->ones[mod(int_x,10)+1].value)))
        	endif
    	endif
    	if (int_x < 1000)
     	   	set index = cnvtint(int_x / 100 + 1)			;053 - Added Parenthesis around int_x/100
       	if (mod(int_x,100) = 0)
            	return (trim(concat(numbers->ones[index].value," ",numbers->hundred)))
         	else
            	set below = get_number_spellout(cnvtstring(mod(int_x,100)))
              	return (trim(concat(numbers->ones[index].value," ",numbers->hundred," ",below)))
         	endif
    	endif
    	if (int_x < 1000000)
        	if (mod(int_x,1000) = 0)
            	set over = get_number_spellout(cnvtstring(int_x / 1000))
            	return (trim(concat(over," ",numbers->thousand)))
         	else
              	set over = get_number_spellout(cnvtstring(int_x / 1000))
              	set below = get_number_spellout(cnvtstring(mod(int_x,1000)))
              	return (trim(concat(over," ",numbers->thousand," ",below)))
 
	     	endif
		else
			return ("")
		endif
	else
		call echo("in else")
		set whole = get_number_spellout(cnvtstring(int_x))
		if (decimal_x = 0.25)
		    return (trim(concat(whole," and one quarter")))
		elseif (decimal_x = 0.5)
		    return (trim(concat(whole," and one half")))
		elseif (decimal_x = 0.75)
		    return (trim(concat(whole," and three quarters")))
		elseif (decimal_x = 0.1)
		    return (trim(concat(whole," and one tenth")))
		elseif (decimal_x = 0.2)
		    return (trim(concat(whole," and one fifth")))
		elseif (decimal_x = 0.3)
		    return (trim(concat(whole," and three tenths")))
		elseif (decimal_x = 0.4)
		    return (trim(concat(whole," and two fifths")))
		elseif (decimal_x = 0.6)
		    return (trim(concat(whole," and three fifths")))
		elseif (decimal_x = 0.7)
		    return (trim(concat(whole," and seven tenths")))
		elseif (decimal_x = 0.8)
		    return (trim(concat(whole," and four fifths")))
		elseif (decimal_x = 0.9)
		    return (trim(concat(whole," and nine tenths")))
		else
			return (trim(concat(whole," and ",build(decimal_x))))
		endif
	endif
END
;MOD 42 END
 
/****************************************************************************
*       EXIT_SCRIPT                                                         *
*****************************************************************************/
#EXIT_SCRIPT
 
if (failed != FALSE)
    set reply->status_data->status = "F"
    set reply->status_data->subeventstatus[1]->OperationStatus = "F"
    set reply->status_data->subeventstatus[1]->TargetObjectValue = sErrMsg
 
    if (failed = SELECT_ERROR)
        set reply->status_data->subeventstatus[1]->OperationName = "SELECT"
        set reply->status_data->subeventstatus[1]->TargetObjectName = table_name
    elseif (failed = INSERT_ERROR)
        set reply->status_data->subeventstatus[1]->OperationName = "INSERT"
        set reply->status_data->subeventstatus[1]->TargetObjectName = table_name
    elseif (failed = INPUT_ERROR)
        set reply->status_data->subeventstatus[1]->OperationName = "VALIDATION"
        set reply->status_data->subeventstatus[1]->TargetObjectName = table_name
    else
        set reply->status_data->subeventstatus[1]->OperationName = "UNKNOWN"
        set reply->status_data->subeventstatus[1]->TargetObjectName = table_name
    endif
else
    set reply->status_data->status = "S"
endif
 
call echorecord(reply)
set script_version = "053 02/12/19 DG"
set rx_version = "02"
end go
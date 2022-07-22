/****************************************************************************
 *                                                                          *
 *  Copyright Noties:  (c) 1983 Laboratory Information Systems &            *
 *                              Technology, Inc.                            *
 *       Revision      (c) 1984-1997 Cerner Corporation                     *
 *                                                                          *
 *  Cerner (R) Proprietary Rights Noties:  All rights reserved.             *
 *  This material contains the valuable properties and trade secrets of     *
 *  Cerner Corporation of Kansas City, Missouri, United States of           *
 *  America (Cerner), embodying substantial creative efforts and            *
 *  confidential information, ideas and expressions, no part of which       *
 *  may be reproduesd or transmitted in any form or by any means, or        *
 *  retained in any storage or retrieval system without the express         *
 *  written permission of Cerner.                                           *
 *                                                                          *
 *  Cerner is a registered mark of Cerner Corporation.                      *
 *                                                                          *
 *                                                                          *
 ****************************************************************************
 
          Date Written:       03/20/2009
          Soures file name:   pm_format_subs.inc
          Object name:        pm_format_subs.inc
          Request #:
 
          Product:            PERSON MANAGEMENT
          Product Team:       PERSON MANAGEMENT
          HNA Version:        V500
          CCL Version:
 
          Program purpose:    Formats different string
 
          Tables read:
          Tables updated:
          Executing from:
 
          Special Notes:
 
 ***********************************************************************
 *                  GENERATED MODIFICATION CONTROL LOG                 *
 ***********************************************************************
 *                                                                     *
 *Feature  Date     Engineer             Comment                       *
 *-------  -------- -------------------- ------------------------------*
  204768   04/15/09 Chad Pugh            CR 1-2494420558 - Initial Release
 ***********************************************************************
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/
  if (validate(last_mod, "NOMOD2") = "NOMOD2")
     declare last_mod = c6 with private, noconstant("")
  endif
 
  set last_mod = "204768"
 
 
   if (validate(bValFormatSubsInc, -9) = -9)
      ;Declare variables
      declare bValFormatSubsInc = i2 with noconstant(TRUE)
      declare dValPhoneFTCd   = f8 with noconstant(0.0)
 
      set stat = uar_get_meaning_by_codeset(281, "FREETEXT", 1, dValPhoneFTCd)
 
 
      ;Declare subroutines
      declare formatPhoneNum(sPhoneNum = vc, dFormatCd = f8) = vc
      declare formatCurrency(sCurrString = vc, sPrefixString = vc) = vc
 
 
      subroutine formatPhoneNum(sPhoneNum, dFormatCd)
      /***********************************
      * Formats Phone Numbers            *
      *----------------------------------*
      * Inputs: sPhoneNum = vc           *
      *         dFormatCd = f8           *
      *                                  *
      * Output: Formatted Phone Num = vc *
      ************************************/
         declare sReturnPhoneNum = vc with noconstant("")
         declare sValPhoneNum    = vc with noconstant("")
         declare sCleanPhoneNum  = vc with noconstant("")
 
         set sValPhoneNum = trim(sPhoneNum,3)
 
         if (textlen(sValPhoneNum) = 0)
            return("")
         endif
 
         ;Check to see if there is a format code
         if (dFormatCd > 0)
            ;Check to see if the format code is Freetext
            if (dFormatCd = dValPhoneFTCd)
               set sReturnPhoneNum = sValPhoneNum
            else
               set sReturnPhoneNum = cnvtphone(sValPhoneNum, dFormatCd)
            endif
 
         else
 
            set sCleanPhoneNum = cnvtalphanum(sValPhoneNum)
 
            if (textlen(sValPhoneNum) = textlen(sCleanPhoneNum))
               set sReturnPhoneNum = cnvtphone(sValPhoneNum, 0.0)
            else
               set sReturnPhoneNum = sValPhoneNum
            endif
 
        endif  ;if (dFormatCd > 0)
 
        return(sReturnPhoneNum)
 
      end
 
 
 
 
      subroutine formatCurrency(sCurrString, sPrefixString)
      /***********************************
      * Formats Phone Numbers            *
      *----------------------------------*
      * Inputs: sPhoneNum = vc           *
      *         dFormatCd = f8           *
      *                                  *
      * Output: Formatted Phone Num = vc *
      ************************************/
         declare lDotPosition   = i4 with noconstant(0)
         declare sValCurrString = vc with noconstant("")
         declare sValPrefix     = vc with noconstant("")
 
         set sValCurrString = trim(sCurrString,3)
 
         if (textlen(sValCurrString) <= 0)
            return("")
         endif
 
         ;Find the "." in the string
         set lDotPosition = findstring(".", sValCurrString)
 
 
         if (lDotPosition = 0)
            ;If no "." in the string, add one to the end plus "00"
            set sValCurrString = build(sValCurrString, ".00")
 
         else
 
            ;If we found a "." then only leave 2 decimal points
            set sValCurrString = substring(1, lDotPosition + 2, sValCurrString)
         endif
 
         set sValPrefix = trim(sPrefixString,3)
 
 
         ;Add the Prefix if defined
         if (textlen(sValPrefix) > 0)
            set sValCurrString = build(sValPrefix, sValCurrString)
         endif
 
         return(sValCurrString)
 
      end
 
   endif  ;if (validate(bValFormatSubsInc, -9) = -9)
 
 
 
 


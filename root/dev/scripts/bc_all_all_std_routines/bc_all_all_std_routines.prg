/***********************************************************************************************************************
Source Code File: BC_ALL_ALL_STD_ROUTINES.PRG
Original Author:  Jeremy Gunn
Date Written:     Febuary 2015
 
 
 
Comments: Include File which holds frequently used Standard Sub-routines
 
 
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  05-Feb-2015             Jeremy Gunn            Added - sBUILD_LIST_STRING, sFORMAT_LIST_TITLE, sGET_USER_NAME
                                                            and sWRITE_DEBUG_MESSAGE
001  23-Feb-2015             Barry Wong             Added - sPARSE_STRING
002  26-Feb-2015             Jeremy Gunn            Added - sSTRIP_CHARS
002  13-Jul-2016  CST        Barry Wong             Added - sGET_HA_ID, sGET_SITE_ID
003  18-Aug-2016  CST        Barry Wong             Converted to an executable
004  29-Aug-2016  CST        Barry Wong             Added - sCST_DATE, sCST_DT_TM
005  15-Sep-2016  CST        Barry Wong             Added - sSET_LOGO_IND
006  20-Sep-2016  CST-6393   Barry Wong             Moved sCST_DATE and sCST_DT_TM to BC_ALL_ALL_DATE_ROUTINES.PRG so
                                                    that they are assessible in layouts.
                                                    Added - sBUILD_LIST_DISPLAY
007  30-Sep-2016  CST-6393   Barry Wong             Added - sGENERIC_HEADER
008  03-Oct-2016  CST-6393   Barry Wong             Added - sGENDER_CODE
009  12-Nov-2016  CST-6393   Barry Wong             Added - sBUILD_LIST_DESCRIPTION
010  02-Dec-2106  CST-5780   Jeremy Gunn            Added - sBUILD_PRSNL_LIST
011  24-Mar-2017             Barry Wong             Added - gbl_debug_on variable, updated sWRITE_DEBUG_MESSAGE to use
                                                    debug variable.
012  30-Mar-2017  CST-9064   Barry Wong             Added - sDISCLAIMER
013  24-Apr-2017  CST-6688   Jeremy Gunn            Added - sFTPFILE
014  27-Apr-2017  CST-8968   Barry Wong             Added - sSTATE_ABBREV, sPACK_ADDRESS
015  09-May-2017  CST-6751   Barry Wong             Modified - sBUILD_LIST_DISPLAY and sBUILD_LIST_DESCRIPTION updated
                                                               to handle Anyc = "*"
016  16-May-2017  CST-8968   Barry Wong             Added - sFORMAT_PHONE
017  27-May-2017  CST-8968   Barry Wong             Added - sWRITE_MESSAGE_NOFLAG
018  12-Jun-2017             Barry Wong             Added - sGET_PREFERRED_PHONE
019  14-Jun-2017             Barry Wong             Added - sCNVTPHONE2
020  17-Jun-2017             Barry Wong             Added - sGET_ORIG_ENCNTR_ID
021  20-Jul-2017  CST-6587   Barry Wong             Added - sLAB_PM_NAME_TRUNC
022  23-Aug-2017  CST-12054  Barry Wong             Added - sGET_PHONE, sGET_PRSNL_ALIAS
023  28-Sep-2017  CST-12054  Barry Wong             Added - sCNVT_SITE_ACRONYM
024  03-Oct-2017  CST-11184  Barry Wong             Added - sORDER_TYPE_EQUAL
025  31-Oct-2017  CST-multi  Barry Wong             Added - sPRINT_REQUISITION
026  21-Nov-2017  CST-multi  Barry Wong             Added - sBYPASS_PRINT_ON_STATUS
027  24-Nov-2017  CST-multi  Barry Wong             Added - sPARENT_ORDER
028  02-Dec-2017  CST-multi  Barry Wong             Added - sPROMPT_OPERATOR
029  11-Dec-2017             Travis Cazes           Added - sSFTPlogical, sSFTPfolder, sSFTPtmpExt,
                                                            sSFTP_FileNameTmp, sSFTP_RenameExt
030  18-Dec-2017  CST-10068  Jeremy Gunn            Fixed sBUILD_LIST_DESCRIPTION to include 'any' properly
031  20-Jan-2018  CST-multi  Barry Wong             Added - sCHILD_ORDER
032  19-Feb-2018  CST-8968   Barry Wong             Added - sENCNTR_SITE_MNEMONIC, sFETCH_PRINTER, sENCNTR_IN_ED
033  06-Mar-2018  CST-16139  Barry Wong             Added - sPOWERPLAN_ORDER
                                                    Deleted - sPRINT_REQUISITION
034  08-Mar-2018             Barry Wong             Modified - sPACK_ADDRESS to remove blank addr line deletion logic
                                                    Added - sREMOVE_BLANK_ADDR
035  14-Mar-2018  CST-16139  Barry Wong             Modified - sPOWERPLAN_ORDER to look for the pathway_catalog_id in
                                                    the ORDER record instead of an existing record in the ACT_PW_COMP
                                                    table
036  20-Mar-2018  CST-16139  Barry Wong             Added - sONCOLOGY_POWERPLAN_ORDER
037  22-Mar-2018             Barry Wong             Added - sDOMAIN_PROGRAM
038  26-Mar-2018             Peter Boronco          Modified Disclaimer to add domain name - except in P0783
039  09-Apr-2018  CST-13412  Barry Wong             Added - sBYPASS_PRINT_ON_STATUS2
040  23-Apr-2018  CST-13412  Barry Wong             Added - sREGIMEN_ORDER
041  29-Apr-2018  CST-18247  Barry Wong             Added - sBYPASS_PRINT_ON_INPROCESS
042  30-Apr-2018  CST-18394  Barry Wong             Added - sENCNTR_UNIT_IN
043  11-May-2018  CST-16642  Barry Wong             Added - sONCOLOGY_DOT_PP_ORDER
044  26-JUN-2018  CST-28837  Barry Wong             Added - sDIET_TEXTURE and sDIET_VISCOSITY
                  CST-28846
045  26-JUN-2018  CST-18657  Barry Wong             Added - sECG_MUSE_BYPASS
046  10-JUL-2018  CST-16642  Barry Wong             Added - sHAS_CHILD_ORDER
047  10-JUL-2018  CST-multi  Barry Wong             Added - sSCHEDULING_MI_ORDER
047  09-Aug-2018  CST-multi  Travis Cazes           Added - sCleanHTMLChars
048  14-Jan-2019  CST-36199  Barry Wong             Added - sAddress_String
049  21-Jan-2018  CST-multi  Barry Wong             Added - sHO_ORG_TYPE_RELTN, sSITE_ORG_TYPE_RELTN,
                                                            sFACILITY_PICK_LIST, sCLINIC_PICK_LIST, sUNIT_PICK_LIST,
                                                            sAMB_PICK_LIST, sSURG_PICK_LIST
050  07-Feb-2018  CST-35971  Barry Wong             Added - sRPT_SUBMITTED_BY, sGET_CODE_BY_DEFINITION
051  01-Apr-2019             Barry Wong             Deleted - Subroutines created in Rev# 049
052  02-Apr-2019             John Simpson           Added - HideTestPatients subroutine, cvMrn4 & includeTestPatients variables
053  02-Apr-2019             Barry Wong             Modified - Added PERSISTSCRIPT to cvMrn4 and includeTestPatients variables.
054  02-Apr-2019             Barry Wong             Added - sRptHeader_Site
055  16-Apr-2019  CST-44889  Dave Gill              Added - sIS_PROCEDURE_CODE
056  30-Apr-2019             Travis Cazes           Added - sSendFileToEmail
057  25-Sep-2019             Travis Cazes           Modified - sSendFileToEmail to allow for cc addresses (optional)
058  20-Mar-2018  CST-16139  Barry Wong             Added - sLAB_DOT_ORDER
059  05-Dec-2019  CST-64433  Barry Wong             Modified - sECG_MUSE_BYPASS to include "Status Change" action exclusion
                                                               and "In Progress" order status
060  05-May-2018  CST-80926  Barry Wong             Modified - sONCOLOGY_POWERPLAN_ORDER for new plan
061  09-Jul-2020  CST-86826  Travis Cazes           Added - sSendHtmlEmailwFile and sGetTimeStamp
062  29-Jul-2020  CST-85833  Barry Wong             Modified - sONCOLOGY_POWERPLAN_ORDER for new plan
063  06-Aug-2020  CST-6094   John Simpson           Fixed issue with file attachment losing first line
064  11-Aug-2020  CST-96763  Barry Wong             Added - sCURPROG_TRACE
065  25-SEP-2020  CST-101542 Barry Wong             Re-purposed sONCOLOGY_DOT_PP_ORDER
066  13-Oct-2020  CST-99242  Barry Wong             Added - sGet_Code_By_Desc
***********************************************************************************************************************/
DROP PROGRAM bc_all_all_std_routines GO
CREATE PROGRAM bc_all_all_std_routines
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare gbl_debug_on = i2 WITH NOCONSTANT(0), PERSISTSCRIPT
 
;SFTP global variables
DECLARE sSFTPlogical = VC WITH CONSTANT("sftp_xfer"), PERSISTSCRIPT
DECLARE sSFTPtmpExt = C4 WITH CONSTANT(".tmp"), PERSISTSCRIPT
 
; Variables needed for HideTestPatients subroutine
declare cvMrn4 = f8 with noconstant(uar_get_code_by("MEANING", 4, "MRN")), PERSISTSCRIPT
declare includeTestPatients = i4 with noconstant(0), PERSISTSCRIPT
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
DECLARE sBUILD_LIST_STRING(pPARAM_NUM = I4,
                           pPAD_STRING = VC) = VC WITH COPY, PERSIST
 
DECLARE sBUILD_LIST_DISPLAY(pPARAM_NUM = I4) = VC WITH COPY, PERSIST
 
DECLARE sBUILD_LIST_DESCRIPTION(pPARAM_NUM = I4) = VC WITH COPY, PERSIST
 
DECLARE sGENERIC_HEADER(pPARAM_NUM = I4,
                        pDispType = I2) = VC WITH COPY, PERSIST
 
DECLARE sFORMAT_LIST_TITLE(pLIST_STRING = VC ,
                           pDISPLAY = I4) = VC WITH COPY, PERSIST
 
DECLARE sGET_USER_NAME(pLIST_STRING = F8) = VC WITH COPY, PERSIST
 
DECLARE sBUILD_PRSNL_LIST(pPARAM_NUM = I4) = VC WITH COPY, PERSIST
 
DECLARE sSTRIP_CHARS(pINSTRING = VC,
                     pREPLIST = VC) = VC WITH COPY, PERSIST
 
DECLARE sWRITE_DEBUG_MESSAGE(DEBUG_MSG = VC,
                             DEBUG_FILENAME = VC) = NULL WITH COPY, PERSIST
 
DECLARE sGET_HA_ID(pLOCATION_ID = F8) = F8 WITH COPY, PERSIST
 
DECLARE sGET_SITE_ID(pLOCATION_ID = F8) = F8 WITH COPY, PERSIST
 
DECLARE sSET_LOGO_IND(pHA = F8) = I2 WITH COPY, PERSIST
 
DECLARE sGENDER_CODE(pGender = F8) = VC WITH COPY, PERSIST
 
DECLARE sDISCLAIMER(pStringID = I4) = VC WITH COPY, PERSIST
 
DECLARE sFTPFILE(pCMD = VC, pPATHFILENAME = VC, pFTPSTRING = VC) = NULL WITH COPY, PERSIST
 
DECLARE sSTATE_ABBREV(pSTATE_CD = F8) = C2 WITH COPY, PERSIST
 
DECLARE sREMOVE_BLANK_ADDR(NULL) = NULL WITH COPY, PERSIST
 
DECLARE sPACK_ADDRESS(pENTITY_ID = F8, pADDRESS_TYPE = F8) = NULL WITH COPY, PERSIST
 
DECLARE sFORMAT_PHONE(pNUMBER = VC, pFORMAT_CD = F8) = VC WITH COPY, PERSIST
 
DECLARE sWRITE_MESSAGE_NOFLAG(DEBUG_MSG = VC,
                              DEBUG_FILENAME = VC) = NULL WITH COPY, PERSIST
 
DECLARE sGET_PREFERRED_PHONE(pPERSON_ID = F8) = VC WITH COPY, PERSIST
 
DECLARE sCNVTPHONE2(pPHONENUM = VC) = VC WITH COPY, PERSIST
 
DECLARE sGET_ORIG_ENCNTR_ID(pORDER_ID = F8) = F8 WITH COPY, PERSIST
 
DECLARE sLAB_PM_NAME_TRUNC(pFIRSTNAME = VC,
                           pLASTNAME = VC,
                           pMIDDLENAME = VC) = C32 WITH COPY, PERSIST
 
DECLARE sGET_PHONE(pPERSON_ID = F8, pPHONE_TYPE = F8) = VC WITH COPY, PERSIST
 
DECLARE sGET_PRSNL_ALIAS(pPERSON_ID = F8, pALIAS_TYPE = F8) = VC WITH COPY, PERSIST
 
DECLARE sCNVT_SITE_ACRONYM(pLOCATION_NAME = VC) = VC WITH COPY, PERSIST
 
DECLARE sORDER_TYPE_EQUAL(pORDER_ID = F8, pORDER_TYPE = F8) = I2 WITH COPY, PERSIST
 
DECLARE sBYPASS_PRINT_ON_STATUS(pORDER_ID = F8,
                                pCANCELLED = I2,
                                pCOMPLETED = I2,
                                pDISCONTINUED = I2) = I2 WITH COPY, PERSIST
 
DECLARE sPARENT_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sPROMPT_OPERATOR(pPARM_NUM = I2) = C2 WITH COPY, PERSIST
 
DECLARE sSFTP_FileNameTmp(sFolder = VC, sFileNoExt = VC) = VC WITH COPY, PERSIST
 
DECLARE sSFTP_RenameExt(sFolder = VC, sFileNoExt = VC, sFileExt =VC) = NULL WITH COPY, PERSIST
 
DECLARE sSendFileToEmail(sFolder=VC,sFileName=VC,sBody=VC,sSubject=VC
						,sToAddrs=VC,bDelInd=I2,sCcAddrs=VC(VALUE," ")) = NULL WITH COPY, PERSIST
 
DECLARE sSendHtmlEmailwFile(sToAddrs=VC,sCcAddrs=VC,sSubject=VC
								,sBody=VC,sFolder=VC,sFileName=VC,bDelInd=I2) = NULL WITH COPY, PERSIST
 
DECLARE sGetTimeStamp(null) = VC WITH COPY, PERSIST
 
DECLARE sCHILD_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sENCNTR_SITE_MNEMONIC(pENCNTR_ID = F8) = C3 WITH COPY, PERSIST
 
DECLARE sFETCH_PRINTER(pSITE = C3, pROUTE = VC) = VC WITH COPY, PERSIST
 
DECLARE sENCNTR_IN_ED(pENCNTR_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sPOWERPLAN_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sONCOLOGY_POWERPLAN_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sDOMAIN_PROGRAM(NULL) = VC WITH COPY, PERSIST
 
DECLARE sBYPASS_PRINT_ON_STATUS2(pORDER_ID = F8,
                                 pMODIFY = I2) = I2 WITH COPY, PERSIST
 
DECLARE sREGIMEN_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sBYPASS_PRINT_ON_INPROCESS(pORDER_ID = F8,
                                   pINPROCESS = I2) = I2 WITH COPY, PERSIST
 
DECLARE sENCNTR_UNIT_IN(pUNIT_CD = F8,
                        pENCNTR_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sONCOLOGY_DOT_PP_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sDIET_TEXTURE(pORDER_ID = F8) = VC WITH COPY, PERSIST
 
DECLARE sDIET_VISCOSITY(pORDER_ID = F8 ) = VC WITH COPY, PERSIST
 
DECLARE sECG_MUSE_BYPASS(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sHAS_CHILD_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sSCHEDULING_MI_ORDER(pORDER_ID = F8) = I2 WITH COPY, PERSIST
 
DECLARE sCleanHTMLChars(sCleanTxt = VC) = VC WITH COPY, PERSIST
 
DECLARE sADDRESS_STRING(pAddrLine1 = C100,
                        pAddrLine2 = C100,
                        pAddrLine3 = C100,
                        pAddrLine4 = C100,
                        pCity = C100,
                        pProvCD = f8,
                        pPostalCd = C25,
                        pCountry = C100) = C300 WITH COPY, PERSIST
 
DECLARE sRPT_SUBMITTED_BY(pPERSON_ID = F8) = VC WITH COPY, PERSIST
 
DECLARE sGET_CODE_BY_DEFINITION(pCODESET = I4, pDEF_SSTRING = VC) = F8 WITH COPY, PERSIST
 
declare HideTestPatients(cCompareField) = vc with persist
 
declare sRptHeader_Site(null) = vc with copy, persist
 
DECLARE sIS_PROCEDURE_CODE(pMNEMONIC = VC) = VC WITH COPY, PERSIST
 
DECLARE sLAB_DOT_ORDER(pORDER_ID = F8) = I4 WITH COPY, PERSIST
 
DECLARE sCURPROG_TRACE(NULL) = NULL WITH COPY, PERSIST
 
declare sGet_Code_By_Desc(pDisplayKey=vc, pDescription=vc) = f8
 
;******************************************************************************************
;
; Section 1: Miscellaneous subroutines
;
;******************************************************************************************
 
;==========================================================================================
; Builds a WHERE clause from the selection made in a LIST prompt object
;==========================================================================================
SUBROUTINE sBUILD_LIST_STRING(pPARAM_NUM, pPAD_STRING )
  DECLARE vWHERE_STRING = VC WITH PROTECT
  DECLARE iLIST_SIZE = I4 WITH PROTECT
 
  IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "L")
    ;MULTIPLE VALUES SELECTED
    SET iLIST_SIZE = CNVTINT(CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),1))
    FOR (X = 1 TO iLIST_SIZE)
      IF (X=iLIST_SIZE)
        SET vWHERE_STRING = BUILD(vWHERE_STRING,PARAMETER(pPARAM_NUM,X))
      ELSE
        SET vWHERE_STRING = BUILD(vWHERE_STRING,PARAMETER(pPARAM_NUM,X),",")
      ENDIF
    ENDFOR
    SET vWHERE_STRING = BUILD(pPAD_STRING,vWHERE_STRING,")")
  ELSE
    IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),1) = "1")
      ;ALL SELECTED
      SET vWHERE_STRING = "(1=1)"
    ELSE
      ;SINGLE VALUE SELECTED
      SET vWHERE_STRING = BUILD(pPAD_STRING,PARAMETER(pPARAM_NUM,1),")")
    ENDIF
  ENDIF
  RETURN(vWHERE_STRING)
END ;SUBROUTINE
 
;==========================================================================================
; Builds a display list from the selection made in a LIST prompt object
; Note: The "@" is used as a placeholder for a space which would have been removed by the
;       VC string. Need to have a ", " following each list item.
;==========================================================================================
SUBROUTINE sBUILD_LIST_DISPLAY(pPARAM_NUM )
  DECLARE vWHERE_STRING = VC WITH PROTECT
  DECLARE iLIST_SIZE = I4 WITH PROTECT
 
  IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "L")
    ;Multiple values selected
    SET iLIST_SIZE = CNVTINT(CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),1))
    FOR (X = 1 TO iLIST_SIZE)
      IF (X = iLIST_SIZE)
        SET vWHERE_STRING = BUILD(vWHERE_STRING, "@", UAR_GET_CODE_DISPLAY(PARAMETER(pPARAM_NUM,X) ) )
      ELSE
        SET vWHERE_STRING = BUILD(vWHERE_STRING, "@", UAR_GET_CODE_DISPLAY(PARAMETER(pPARAM_NUM,X) ), "," )
      ENDIF
    ENDFOR
  ELSE
    IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "F")
      ;Single value selected
      SET vWHERE_STRING = BUILD(UAR_GET_CODE_DISPLAY(PARAMETER(pPARAM_NUM,1) ) )
    ELSE
      IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "C")
        ;Any seleced where Anyc is set to '*'
        SET vWHERE_STRING = "All"
      ELSE
        ;No values selected
        SET vWHERE_STRING = "None"
      ENDIF
    ENDIF
  ENDIF
  ;Change @ back to a space
  SET vWHERE_STRING = REPLACE(vWHERE_STRING, "@", " ")
 
  RETURN(TRIM(vWHERE_STRING, 3 ) )
END ;SUBROUTINE
 
;==========================================================================================
; Builds a description list from the selection made in a LIST prompt object
; Note: The "@" is used as a placeholder for a space which would have been removed by the
;       VC string. Need to have a ", " following each list item.
;==========================================================================================
SUBROUTINE sBUILD_LIST_DESCRIPTION(pPARAM_NUM )
  DECLARE vWHERE_STRING = VC WITH PROTECT
  DECLARE iLIST_SIZE = I4 WITH PROTECT
 
  IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "L")
    ;Multiple values selected
    SET iLIST_SIZE = CNVTINT(CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),1))
    FOR (X = 1 TO iLIST_SIZE)
      IF (X = iLIST_SIZE)
        SET vWHERE_STRING = BUILD(vWHERE_STRING, "@", UAR_GET_CODE_DESCRIPTION(PARAMETER(pPARAM_NUM,X) ) )
      ELSE
        SET vWHERE_STRING = BUILD(vWHERE_STRING, "@", UAR_GET_CODE_DESCRIPTION(PARAMETER(pPARAM_NUM,X) ), "," )
      ENDIF
    ENDFOR
  ELSE
    IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "F")
      ;Single value selected
      SET vWHERE_STRING = BUILD(UAR_GET_CODE_DESCRIPTION(PARAMETER(pPARAM_NUM,1) ) )
    ELSE
;030      IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "F")
      IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "C") ;030
        ;Any seleced where Anyc is set to '*'
        SET vWHERE_STRING = "All"
      ELSE
        ;No values selected
        SET vWHERE_STRING = "None"
      ENDIF
    ENDIF
  ENDIF
  ;Change @ back to a space
  SET vWHERE_STRING = REPLACE(vWHERE_STRING, "@", " ")
 
  RETURN(TRIM(vWHERE_STRING, 3) )
END ;SUBROUTINE
 
;==========================================================================================
; Builds a string to be used as a report filter in the header
; pDispType:  1-Display,  2-Description   (Default - Description)
;==========================================================================================
SUBROUTINE sGENERIC_HEADER(pPARAM_NUM, pDispType )
  DECLARE vHEADER = VC WITH PROTECT
 
  IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "L")
    ;MULTIPLE VALUES SELECTED
    SET vHEADER = "Multiple Selections"
  ELSE
    IF (REFLECT(PARAMETER(pPARAM_NUM,0)) = "C1" OR  ; Anyc == *
        REFLECT(PARAMETER(pPARAM_NUM,0)) = "I4" )   ; Anyc == 0
      ;ALL SELECTED
      SET vHEADER = "All"
    ELSE
      ;SINGLE VALUE SELECTED
      IF (pDispType = 1 )
        SET vHEADER = UAR_GET_CODE_DISPLAY(PARAMETER(pPARAM_NUM,1) )
      ELSE
        SET vHEADER = UAR_GET_CODE_DESCRIPTION(PARAMETER(pPARAM_NUM,1) )
      ENDIF
    ENDIF
  ENDIF
  RETURN(TRIM(vHEADER, 3 ) )
END ;SUBROUTINE
 
;==========================================================================================
; Returns the personnel name as a 30 character string
;==========================================================================================
SUBROUTINE sGET_USER_NAME(pUSER_CD)
  DECLARE vUSER_STRING = C30 WITH PROTECT
 
  SET vUSER_STRING = " "
 
  SELECT
  	PR.NAME_FULL_FORMATTED
  FROM
  	PRSNL   PR
  WHERE
    PR.PERSON_ID = pUSER_CD
  DETAIL
    vUSER_STRING  = SUBSTRING(1,30,PR.NAME_FULL_FORMATTED)
  WITH NOCOUNTER
 
  RETURN(vUSER_STRING)
END
 
;==========================================================================================
; Builds list of personnel names
;==========================================================================================
SUBROUTINE sBUILD_PRSNL_LIST(pPARAM_NUM )
  DECLARE vWHERE_STRING = VC WITH PROTECT
  DECLARE iLIST_SIZE = I4 WITH PROTECT
 
  IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "L")
    ;Multiple values selected
    SET iLIST_SIZE = CNVTINT(CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),1))
    FOR (X = 1 TO iLIST_SIZE)
      IF (X = iLIST_SIZE)
        SET vWHERE_STRING = BUILD(vWHERE_STRING, "@", sGET_USER_NAME(PARAMETER(pPARAM_NUM,X) ) )
      ELSE
        SET vWHERE_STRING = BUILD(vWHERE_STRING, "@", sGET_USER_NAME(PARAMETER(pPARAM_NUM,X) ), "," )
      ENDIF
    ENDFOR
  ELSE
    IF (CNVTALPHANUM(REFLECT(PARAMETER(pPARAM_NUM,0)),2) = "F")
      ;Single value selected
      SET vWHERE_STRING = BUILD(sGET_USER_NAME(PARAMETER(pPARAM_NUM,1) ) )
    ELSE
      ;No values selected
      SET vWHERE_STRING = "None"
    ENDIF
  ENDIF
  ;Change @ back to a space
  SET vWHERE_STRING = REPLACE(vWHERE_STRING, "@", " ")
 
  RETURN(TRIM(vWHERE_STRING, 3 ) )
END ;SUBROUTINE
 
;==========================================================================================
; Determines the title string to be printed based on the selection from a LIST prompt
;==========================================================================================
SUBROUTINE sFORMAT_LIST_TITLE(pLIST_STRING ,pDISPLAY)
  DECLARE vTITLE_STRING = VC WITH PROTECT
 
  IF (pLIST_STRING = "(1=1)")
    SET vTITLE_STRING  = "All"
  ELSEIF (FINDSTRING(",",pLIST_STRING) > 1)
    SET vTITLE_STRING  = "Multiple Selected"
  ELSE
    SET vTITLE_STRING = TRIM(pLIST_STRING,3)
    SET vTITLE_STRING = SUBSTRING(FINDSTRING("(",vTITLE_STRING)+1,TEXTLEN(vTITLE_STRING),vTITLE_STRING)
    SET vTITLE_STRING = SUBSTRING(1,FINDSTRING(")",vTITLE_STRING)-1,vTITLE_STRING)
    IF (pDISPLAY = 1 )
      SET vTITLE_STRING = UAR_GET_CODE_DISPLAY(CNVTREAL(TRIM(vTITLE_STRING,3)))
    ELSE
      SET vTITLE_STRING = UAR_GET_CODE_DESCRIPTION(CNVTREAL(TRIM(vTITLE_STRING,3)))
    ENDIF
  ENDIF
  RETURN(vTITLE_STRING)
END
 
;==========================================================================================
; Writes a message to a file for debugging
;==========================================================================================
SUBROUTINE sWRITE_DEBUG_MESSAGE(DEBUG_MSG, DEBUG_FILENAME)
  IF (gbl_debug_on = 1 )
    SELECT INTO concat("CCLUSERDIR/",DEBUG_FILENAME)
      FROM DUMMYT D
    DETAIL
      PRINT_MSG = CONCAT(DEBUG_MSG," > ",FORMAT(CNVTDATETIME(CURDATE, CURTIME), "DD-MMM-YYYY HH:MM;;Q"))
      COL 2, PRINT_MSG
    WITH NOCOUNTER, NOHEADING, NOFORMAT, APPEND
  ENDIF
END
 
;==========================================================================================
; Calculates the maximum length for the portion of the string, pLIST_STRING, that can fit
; within a width of pWIDTH.
;
; Used in X-Y reporting programs for Courier fonts only
;==========================================================================================
SUBROUTINE sPARSE_STRING(pLIST_STRING ,pWIDTH)
  DECLARE vPOSITION = I4 WITH PROTECT
  DECLARE vSUBSTRING = VC
  DECLARE vNEXT_CHAR = C1
  DECLARE vLAST_SPACE = I4
  DECLARE vMIN_WIDTH = I4
 
  IF (pWIDTH < 0 )
    SET vMIN_WIDTH = 1
  ELSE
    SET vMIN_WIDTH = pWIDTH
  ENDIF
 
  IF (TEXTLEN(pLIST_STRING ) <= vMIN_WIDTH )
    SET vPOSITION = 0
  ELSE
    SET vSUBSTRING = SUBSTRING(1 ,vMIN_WIDTH ,pLIST_STRING )
    SET vNEXT_CHAR = SUBSTRING(vMIN_WIDTH + 1 ,1 ,pLIST_STRING )
    SET vLAST_SPACE = FINDSTRING(" " ,vSUBSTRING ,1 ,1 )
    IF ((vLAST_SPACE = 0 ) OR (vNEXT_CHAR = " " ) )
      SET vPOSITION = vMIN_WIDTH
    ELSE
      SET vPOSITION = vLAST_SPACE
    ENDIF
  ENDIF
 
  RETURN(vPOSITION)
END
 
;==========================================================================================
; Returns a string with specific characters removed.
;   pINSTRING - Source string
;   pREPLIST  - List of comma separated characters/character strings to be removed from
;               the source string
;==========================================================================================
SUBROUTINE sSTRIP_CHARS(pINSTRING , pREPLIST)
 
  DECLARE vRETURN_STRING = VC
  DECLARE vREPLACE_LIST  = VC
  DECLARE vREPLACE_CHAR  = VC
 
  SET vRETURN_STRING = pINSTRING
  SET vREPLACE_LIST  = pREPLIST
 
  WHILE (PIECE(vREPLACE_LIST,",",1,"") > "")
    SET vREPLACE_CHAR = PIECE(vREPLACE_LIST,",",1,"")
    SET vREPLACE_LIST = SUBSTRING(3,TEXTLEN(vREPLACE_LIST),vREPLACE_LIST)
    SET vRETURN_STRING = REPLACE(vRETURN_STRING,vREPLACE_CHAR,"",0)
  ENDWHILE
 
  RETURN(TRIM(vRETURN_STRING,3))
END
 
;==========================================================================================
; Returns the Health Authority ID for a location
;==========================================================================================
SUBROUTINE sGET_HA_ID(pLOCATION_ID)
 
  DECLARE HA_KEY = F8
  SET HA_KEY = 0.00
 
  SELECT CV.CODE_VALUE
    FROM LOCATION L,
         ORG_TYPE_RELTN O,
         CODE_VALUE CV
   WHERE L.LOCATION_CD = pLOCATION_ID
     AND L.ACTIVE_IND = 1
     AND O.ORGANIZATION_ID = L.ORGANIZATION_ID
     AND O.ACTIVE_IND = 1
     AND CV.CODE_VALUE = O.ORG_TYPE_CD
     AND CV.CODE_SET = 278
     AND CV.ACTIVE_IND = 1
     AND CV.DISPLAY LIKE "HO_*"
 
  DETAIL
    HA_KEY = CV.CODE_VALUE
 
  WITH NOCOUNTER
 
  RETURN(HA_KEY)
END
 
;==========================================================================================
; Returns the Site (Facility) ID for a location
;==========================================================================================
SUBROUTINE sGET_SITE_ID(pLOCATION_ID)
 
  DECLARE SITE_KEY = F8
  SET SITE_KEY = 0.00
 
  SELECT CV.CODE_VALUE
    FROM LOCATION L,
         ORG_TYPE_RELTN O,
         CODE_VALUE CV
   WHERE L.LOCATION_CD = pLOCATION_ID
     AND L.ACTIVE_IND = 1
     AND O.ORGANIZATION_ID = L.ORGANIZATION_ID
     AND O.ACTIVE_IND = 1
     AND CV.CODE_VALUE = O.ORG_TYPE_CD
     AND CV.CODE_SET = 278
     AND CV.ACTIVE_IND = 1
     AND CV.DISPLAY_KEY LIKE "SITE*"
 
  DETAIL
    SITE_KEY = CV.CODE_VALUE
 
  WITH NOCOUNTER
 
  RETURN(SITE_KEY)
END
 
;==========================================================================================
; Returns the logo indicator of 0,1,2 or 3
;==========================================================================================
SUBROUTINE sSET_LOGO_IND(pHA)
 
  DECLARE cvVCH_HA = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 278, "HOVCHA"))
  DECLARE cvPHSA_HA = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 278, "HOPHSA"))
  DECLARE cvPHC_HA = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 278, "HOPHC"))
 
  DECLARE iLOGO_TYPE = I2
 
  IF (pHA = cvVCH_HA)
    SET iLOGO_TYPE = 1
  ELSEIF (pHA = cvPHSA_HA)
    SET iLOGO_TYPE = 2
  ELSEIF (pHA = cvPHC_HA)
    SET iLOGO_TYPE = 3
  ELSE
    SET iLOGO_TYPE = 0
  ENDIF
 
  RETURN(iLOGO_TYPE)
END
 
;==========================================================================================
; Returns the abbreviated string for a gender code
;==========================================================================================
SUBROUTINE sGENDER_CODE(pGENDER)
 
  DECLARE cvMale = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",57,"MALE"))
  DECLARE cvFemale = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",57,"FEMALE"))
  DECLARE cvUnknown = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",57,"UNKNOWN"))
  DECLARE cvUnDiff = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING",57,"UNSPECIFIED"))
 
  DECLARE sGENDER = VC
 
  IF (pGENDER = cvMale)
    SET sGENDER = "M"
  ELSEIF (pGENDER = cvFemale)
    SET sGENDER = "F"
  ELSEIF (pgender = cvUnknown)
    SET sGENDER = "Unkn"
  ELSEIF (pgender = cvUnDiff)
    SET sGENDER = "Undf"
  ELSE
    SET sGENDER = "?"
  ENDIF
 
  RETURN(sGENDER)
END
 
;==========================================================================================
; Returns the disclaimer line
;==========================================================================================
SUBROUTINE sDISCLAIMER(pStringID)
 
  DECLARE sDISCLAIMER_STRING = VC
;038 Start
  DECLARE sDOMAIN = VC
 
  IF (CURUSER LIKE "*P0783*")
    SET sDOMAIN = ""
  ELSE
    SET sDOMAIN = CURUSER
  ENDIF
;038 End
 
  IF (pStringID = 1 )
    SET sDISCLAIMER_STRING = CONCAT("This record contains confidential information which must be protected. ",
                                    "Any unauthorized use or disclosure is strictly prohibited. ", sDOMAIN )   ;038
  ELSE
    SET sDISCLAIMER_STRING = ""
  ENDIF
 
  RETURN(sDISCLAIMER_STRING )
END
 
;==========================================================================================
; Returns the abbreviation of a province or a state
;==========================================================================================
SUBROUTINE sSTATE_ABBREV(pSTATE_CD)
 
  DECLARE sABBREVIATION = C2
 
  SET state_name = trim(uar_get_code_display(pSTATE_CD ), 3 )
 
  CASE (state_name )
    ; Canada
    OF "British Columbia"          : SET sABBREVIATION = "BC"
    OF "Alberta"                   : SET sABBREVIATION = "AB"
    OF "Manitoba"                  : SET sABBREVIATION = "MB"
    OF "New Brunswick"             : SET sABBREVIATION = "NB"
    OF "Newfoundland"              : SET sABBREVIATION = "NL"
    OF "Newfoundland and Labrador" : SET sABBREVIATION = "NL"
    OF "Northwest Territories"     : SET sABBREVIATION = "NT"
    OF "Nova Scotia"               : SET sABBREVIATION = "NS"
    OF "Nunavut"                   : SET sABBREVIATION = "NU"
    OF "Ontario"                   : SET sABBREVIATION = "ON"
    OF "Prince Edward Island"      : SET sABBREVIATION = "PE"
    OF "Quebec"                    : SET sABBREVIATION = "QC"
    OF "Saskatchewan"              : SET sABBREVIATION = "SK"
    OF "Yukon Territory"           : SET sABBREVIATION = "YT"
    ; USA
    OF "Alabama"                   : SET sABBREVIATION = "AL"
    OF "Alaska"                    : SET sABBREVIATION = "AK"
    OF "Arizona"                   : SET sABBREVIATION = "AZ"
    OF "Arkansas"                  : SET sABBREVIATION = "AR"
    OF "California"                : SET sABBREVIATION = "CA"
    OF "Colorado"                  : SET sABBREVIATION = "CO"
    OF "Connecticut"               : SET sABBREVIATION = "CT"
    OF "Delaware"                  : SET sABBREVIATION = "DE"
    OF "District of Columbia"      : SET sABBREVIATION = "DC"
    OF "Florida"                   : SET sABBREVIATION = "FL"
    OF "Georgia"                   : SET sABBREVIATION = "GA"
    OF "Hawaii"                    : SET sABBREVIATION = "HI"
    OF "Idaho"                     : SET sABBREVIATION = "ID"
    OF "Illinois"                  : SET sABBREVIATION = "IL"
    OF "Indiana"                   : SET sABBREVIATION = "IN"
    OF "Iowa"                      : SET sABBREVIATION = "IA"
    OF "Kansas"                    : SET sABBREVIATION = "KS"
    OF "Kentucky"                  : SET sABBREVIATION = "KY"
    OF "Louisiana"                 : SET sABBREVIATION = "LA"
    OF "Maine"                     : SET sABBREVIATION = "ME"
    OF "Maryland"                  : SET sABBREVIATION = "MD"
    OF "Massachusetts"             : SET sABBREVIATION = "MA"
    OF "Michigan"                  : SET sABBREVIATION = "MI"
    OF "Minnesota"                 : SET sABBREVIATION = "MN"
    OF "Mississippi"               : SET sABBREVIATION = "MS"
    OF "Missouri"                  : SET sABBREVIATION = "MO"
    OF "Montana"                   : SET sABBREVIATION = "MT"
    OF "Nebraska"                  : SET sABBREVIATION = "NE"
    OF "Nevada"                    : SET sABBREVIATION = "NV"
    OF "New Hampshire"             : SET sABBREVIATION = "NH"
    OF "New Jersey"                : SET sABBREVIATION = "NJ"
    OF "New Mexico"                : SET sABBREVIATION = "NM"
    OF "New York"                  : SET sABBREVIATION = "NY"
    OF "North Carolina"            : SET sABBREVIATION = "NC"
    OF "North Dakota"              : SET sABBREVIATION = "ND"
    OF "Ohio"                      : SET sABBREVIATION = "OH"
    OF "Oklahoma"                  : SET sABBREVIATION = "OK"
    OF "Oregon"                    : SET sABBREVIATION = "OR"
    OF "Pennsylvania"              : SET sABBREVIATION = "PA"
    OF "Rhode Island"              : SET sABBREVIATION = "RI"
    OF "South Carolina"            : SET sABBREVIATION = "SC"
    OF "South Dakota"              : SET sABBREVIATION = "SD"
    OF "Tennessee"                 : SET sABBREVIATION = "TN"
    OF "Texas"                     : SET sABBREVIATION = "TX"
    OF "Utah"                      : SET sABBREVIATION = "UT"
    OF "Vermont"                   : SET sABBREVIATION = "VT"
    OF "Virginia"                  : SET sABBREVIATION = "VA"
    OF "Washington"                : SET sABBREVIATION = "WA"
    OF "West Virginia"             : SET sABBREVIATION = "WV"
    OF "Wisconsin"                 : SET sABBREVIATION = "WI"
    OF "Wyoming"                   : SET sABBREVIATION = "WY"
    ; Unknown/Out of Country
    ELSE SET sABBREVIATION = ""
  ENDCASE
 
  RETURN(sABBREVIATION )
END
 
;==========================================================================================
; Removes blank address lines
;==========================================================================================
SUBROUTINE sREMOVE_BLANK_ADDR(NULL )
 
  ; Set line5 to blank if no city, state and zipcode found
  IF (trim(pack_address->line5, 3 ) = "," )
    set pack_address->line5 = ""
  ENDIF
 
  ; Remove empty address lines
  IF (textlen(pack_address->line5 ) = 0 )
    set pack_address->line_cnt = pack_address->line_cnt - 1
  ENDIF
  IF (textlen(pack_address->line4 ) = 0 )
    set pack_address->line_cnt = pack_address->line_cnt - 1
    set pack_address->line4 = pack_address->line5
    set pack_address->line5 = ""
  ENDIF
  IF (textlen(pack_address->line3 ) = 0 )
    set pack_address->line_cnt = pack_address->line_cnt - 1
    set pack_address->line3 = pack_address->line4
    set pack_address->line4 = ""
    set pack_address->line5 = ""
  ENDIF
  IF (textlen(pack_address->line2 ) = 0 )
    set pack_address->line_cnt = pack_address->line_cnt - 1
    set pack_address->line2 = pack_address->line3
    set pack_address->line3 = ""
    set pack_address->line4 = ""
    set pack_address->line5 = ""
  ENDIF
  IF (textlen(pack_address->line1 ) = 0 )
    set pack_address->line_cnt = pack_address->line_cnt - 1
    set pack_address->line1 = pack_address->line2
    set pack_address->line2 = ""
    set pack_address->line3 = ""
    set pack_address->line4 = ""
    set pack_address->line5 = ""
  ENDIF
 
END
 
;==========================================================================================
; Assign the pack_address record with the blank address lines removed
;
; Important: To use this routine required that the file bc_all_all_pack_address_recd.inc
;            must be included in the CCL using this routine.
;            The program bc_all_all_std_routines should also be executed in this CCL as
;            the function sSTATE_ABBREV is used.
;
;==========================================================================================
SUBROUTINE sPACK_ADDRESS(pENTITY_ID, pADDRESS_TYPE )
 
  SET pack_address->line_cnt = 0
  SET pack_address->line1 = ""
  SET pack_address->line2 = ""
  SET pack_address->line3 = ""
  SET pack_address->line4 = ""
  SET pack_address->line5 = ""
 
  SELECT INTO "nl:"
	  a.street_addr
	, a.street_addr2
	, a.street_addr3
	, a.street_addr4
	, a.city
	, out_state = sSTATE_ABBREV(a.state_cd )
	, a.zipcode
 
    FROM address   a
 
   WHERE a.parent_entity_id = pENTITY_ID
     AND a.address_type_cd = pADDRESS_TYPE
     AND a.active_ind = 1
     AND a.address_type_seq = (SELECT max(a1.address_type_seq)
                                 FROM address   a1
                                WHERE a1.parent_entity_id = a.parent_entity_id
                                  AND a1.address_type_cd = a.address_type_cd
                                  AND a1.active_ind = a.active_ind )
 
  ; Only use the first address record returned
  HEAD a.parent_entity_id
    pack_address->line_cnt = 5
    pack_address->line1 = a.street_addr
    pack_address->line2 = a.street_addr2
    pack_address->line3 = a.street_addr3
    pack_address->line4 = a.street_addr4
    pack_address->line5 = concat(trim(a.city, 3 ), ", ", out_state, "   ", trim(a.zipcode, 3 ) )
 
  WITH nocounter, time=10
 
  CALL sREMOVE_BLANK_ADDR(NULL )
 
END
 
;==========================================================================================
; Returns the formatted phone number
;==========================================================================================
SUBROUTINE sFORMAT_PHONE(pNUMBER , pFORMAT_CD)
 
  DECLARE sPHONE_STRING = VC WITH PROTECT
  DECLARE cvFREETEXT = f8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 281, "FREETEXT" ) )
 
  IF (TEXTLEN(pNUMBER) > 0 )
    IF (pFORMAT_CD = cvFREETEXT )
      SET sPHONE_STRING = pNUMBER
    ELSE
      SET sPHONE_STRING = CNVTPHONE(pNUMBER , pFORMAT_CD)
    ENDIF
  ELSE
    SET sPHONE_STRING = ""
  ENDIF
 
  RETURN(sPHONE_STRING )
END
 
;==========================================================================================
; Writes a message to a file for debugging. This routine doesn't use the gbl_debug_on
; indicator. It is normally used to write messages from programs called from an application
; other than DVDev or ExplorerMenu
;==========================================================================================
SUBROUTINE sWRITE_MESSAGE_NOFLAG(DEBUG_MSG, DEBUG_FILENAME)
  SELECT INTO concat("CCLUSERDIR/",DEBUG_FILENAME)
    FROM DUMMYT D
  DETAIL
    PRINT_MSG = CONCAT(DEBUG_MSG," > ",FORMAT(CNVTDATETIME(CURDATE, CURTIME), "DD-MMM-YYYY HH:MM;;Q"))
    COL 2, PRINT_MSG
  WITH NOCOUNTER, NOHEADING, NOFORMAT, APPEND
END
 
;==========================================================================================
; Returns the preferred phone number
;==========================================================================================
SUBROUTINE sGET_PREFERRED_PHONE(pPERSON_ID)
 
  DECLARE cvsHome_Phone = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING" ,43 ,"HOME" ) )
  DECLARE cvsMobile_Phone = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING" ,43 ,"MOBILE" ) )
  DECLARE cvsWork_Phone = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING" ,43 ,"BUSINESS" ) )
  DECLARE cvsPersonal_Pgr = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING" ,43 ,"PAGER PERS" ) )
  DECLARE cvsAlternate_Phone = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING" ,43 ,"ALTERNATE" ) )
  DECLARE cvsPreferred_Phone = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 356, "PREFERREDPHONE"))
  DECLARE cvsPMHomePhone_CD = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 100008, "HOMEPHONENUMBER"))
  DECLARE cvsPMWorkPhone_CD = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 100008, "WORKPHONENUMBER"))
  DECLARE cvsPMMobilePhone_CD = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 100008, "MOBILEPHONENUMBER"))
  DECLARE cvsPMAltPhone_CD = F8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 100008, "ALTERNATEPHONENUMBER"))
  DECLARE cvsFREETEXT = f8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 281, "FREETEXT" ) )
  DECLARE sPHONE_STRING = VC WITH PROTECT
  DECLARE vPrefPhoneCd = F8
 
  ;****************************************
  ; GET PREFERRED PHONE
  ;****************************************
  SELECT PI.VALUE_CD
    FROM PERSON_INFO PI
   WHERE PI.PERSON_ID = pPERSON_ID
     AND PI.INFO_SUB_TYPE_CD = cvsPreferred_Phone
 
  DETAIL
    CASE (PI.VALUE_CD)
      OF cvsPMHomePhone_CD   : vPrefPhoneCd = cvsHome_Phone
      OF cvsPMWorkPhone_CD   : vPrefPhoneCd = cvsWork_Phone
      OF cvsPMMobilePhone_CD : vPrefPhoneCd = cvsMobile_Phone
      OF cvsPMAltPhone_CD    : vPrefPhoneCd = cvsAlternate_Phone
      ELSE vPrefPhoneCd = 0.00
    ENDCASE
 
  WITH NOCOUNTER
 
  IF (vPrefPhoneCd = 0.00)
    ; Preferred number set to No Phone
    SET sPHONE_STRING = " "
  ELSE
    ; Pull the phone number matching the phone type of the above SELECT
    SELECT INTO "nl:"
      FROM PHONE PH
     WHERE PH.PARENT_ENTITY_ID = pPERSON_ID
       AND PH.PARENT_ENTITY_NAME = "PERSON"
       AND PH.ACTIVE_IND = 1
       AND PH.PHONE_TYPE_CD = vPrefPhoneCd
       AND PH.END_EFFECTIVE_DT_TM > SYSDATE
       AND PH.PHONE_TYPE_SEQ = (SELECT MAX(PH1.PHONE_TYPE_SEQ)
                                  FROM PHONE PH1
                                 WHERE PH1.PARENT_ENTITY_ID = PH.PARENT_ENTITY_ID
                                   AND PH1.PARENT_ENTITY_NAME = PH.PARENT_ENTITY_NAME
                                   AND PH1.ACTIVE_IND = PH.ACTIVE_IND
                                   AND PH1.PHONE_TYPE_CD = PH.PHONE_TYPE_CD
                                   AND PH1.END_EFFECTIVE_DT_TM = PH.END_EFFECTIVE_DT_TM )
 
    DETAIL
;      sPHONE_STRING = CNVTPHONE(PH.PHONE_NUM, PH.PHONE_FORMAT_CD )
      sPHONE_STRING = sCNVTPHONE2(PH.PHONE_NUM )
 
    WITH NOCOUNTER
  ENDIF
 
  RETURN(sPHONE_STRING )
END
 
;==========================================================================================
; Returns the formatted phone number if number only consists of 10 numbers
;==========================================================================================
SUBROUTINE sCNVTPHONE2(pPHONENUM)
 
  DECLARE sPHONE_STRING = VC WITH PROTECT
  DECLARE cvUS = f8 WITH PUBLIC, CONSTANT(UAR_GET_CODE_BY("MEANING", 281, "US" ) )
 
  IF ((CNVTALPHANUM(pPHONENUM, 1 ) = pPHONENUM ) AND
      (TEXTLEN(TRIM(CNVTALPHANUM(pPHONENUM, 1 ), 3 ) ) = 10 ) )
    SET sPHONE_STRING = CNVTPHONE(pPHONENUM, cvUS )
  ELSE
    SET sPHONE_STRING = pPHONENUM
  ENDIF
 
  RETURN(sPHONE_STRING )
END
 
;==========================================================================================
; Returns the common truncated name for Lab labels and PM Armband label
;==========================================================================================
SUBROUTINE sLAB_PM_NAME_TRUNC(pFIRSTNAME, pLASTNAME, pMIDDLENAME)
 
  DECLARE LABEL_NAME = VC
  DECLARE MAXCHAR = I4
 
  SET MAXCHAR = 30
 
  IF (TEXTLEN(TRIM(pMIDDLENAME, 3) ) > 0 )
    ; Priority 1
    SET LABEL_NAME = TRIM(CONCAT(TRIM(pLASTNAME, 3), ", ", TRIM(pFIRSTNAME, 3), " ", TRIM(pMIDDLENAME, 3)))
 
    IF (TEXTLEN(LABEL_NAME ) <= MAXCHAR )
      RETURN(LABEL_NAME )
    ENDIF
 
    ;Priority 2
    SET LABEL_NAME = TRIM(CONCAT(TRIM(pLASTNAME, 3), ", ", TRIM(pFIRSTNAME, 3), " ", SUBSTRING(1, 1, TRIM(pMIDDLENAME, 3)), "*" ))
 
    IF (TEXTLEN(LABEL_NAME ) <= MAXCHAR )
      RETURN(LABEL_NAME )
    ENDIF
  ENDIF
 
  ;Priority 3
  SET LABEL_NAME = TRIM(CONCAT(TRIM(pLASTNAME, 3), ", ", TRIM(pFIRSTNAME, 3)))
 
  IF (TEXTLEN(LABEL_NAME ) <= MAXCHAR )
    RETURN(LABEL_NAME )
  ENDIF
 
  ;Priority 4 & 5 (catch all)
  ; If first name is longer than 8 characters then truncation is necessary
  IF (TEXTLEN(TRIM(pFIRSTNAME, 3) ) > 8 )
    IF (TEXTLEN(TRIM(pLASTNAME, 3) ) > 18 )
      SET LABEL_NAME = CONCAT(TRIM(SUBSTRING(1, 18, TRIM(pLASTNAME,3) ) ), "*, ", TRIM(SUBSTRING(1, 8, TRIM(pFIRSTNAME,3) ) ), "*" )
      RETURN(LABEL_NAME )
    ELSE
      SET LABEL_NAME = CONCAT(TRIM(pLASTNAME,3 ), ", ", TRIM(SUBSTRING(1, 8, TRIM(pFIRSTNAME,3) ) ), "*" )
      RETURN(LABEL_NAME )
    ENDIF
  ELSE
    IF (TEXTLEN(TRIM(pLASTNAME,3) ) > 18 )
      SET LABEL_NAME = CONCAT(TRIM(SUBSTRING(1, 18, TRIM(pLASTNAME,3) ) ), "*, ", TRIM(pFIRSTNAME,3 ) )
      RETURN(LABEL_NAME )
    ELSE
      SET LABEL_NAME = CONCAT(TRIM(pLASTNAME,3 ), ", ", TRIM(pFIRSTNAME,3 ) )
      RETURN(LABEL_NAME )
    ENDIF
  ENDIF
 
END
 
;==========================================================================================
; Returns a specific phone number
;==========================================================================================
SUBROUTINE sGET_PHONE(pPERSON_ID, pPHONE_TYPE)
 
  DECLARE sPHONE_STRING = VC WITH PROTECT
  SET sPHONE_STRING = ""
 
  SELECT INTO "nl:"
    FROM PHONE PH
  WHERE PH.PARENT_ENTITY_ID = pPERSON_ID
    AND PH.PARENT_ENTITY_NAME = "PERSON"
    AND PH.PHONE_TYPE_CD = pPHONE_TYPE
    AND PH.ACTIVE_IND = 1
    AND PH.PHONE_TYPE_SEQ = (SELECT MAX(PH1.PHONE_TYPE_SEQ)
                               FROM PHONE PH1
                              WHERE PH1.PARENT_ENTITY_ID = PH.PARENT_ENTITY_ID
                                AND PH1.PARENT_ENTITY_NAME = PH.PARENT_ENTITY_NAME
                                AND PH1.ACTIVE_IND = PH.ACTIVE_IND
                                AND PH1.PHONE_TYPE_CD = PH.PHONE_TYPE_CD
                                AND PH1.END_EFFECTIVE_DT_TM = PH.END_EFFECTIVE_DT_TM )
 
  DETAIL
    sPHONE_STRING = sCNVTPHONE2(PH.PHONE_NUM )
 
  WITH NOCOUNTER
 
  RETURN(sPHONE_STRING )
END
 
;==========================================================================================
; Returns a personnel alias
;==========================================================================================
SUBROUTINE sGET_PRSNL_ALIAS(pPERSON_ID, pALIAS_TYPE)
 
  DECLARE sALIAS_STRING = VC
  SET sALIAS_STRING = ""
 
  SELECT INTO "nl:"
    FROM PRSNL_ALIAS PA
 
   WHERE PA.PERSON_ID = pPERSON_ID
     AND PA.PRSNL_ALIAS_TYPE_CD = pALIAS_TYPE
     AND PA.ACTIVE_IND = 1
 
  DETAIL
    sALIAS_STRING = PA.ALIAS
 
  WITH NOCOUNTER
 
  RETURN(sALIAS_STRING )
END
 
;==========================================================================================
; Converts the three character site ID to the full name
;==========================================================================================
SUBROUTINE sCNVT_SITE_ACRONYM(pLOCATION_NAME)
 
  DECLARE sLOCN_STRING  = VC WITH PROTECT
  DECLARE sLOCN_ACRONYM = C3 WITH PROTECT
  DECLARE sCS278_KEY    = C7 WITH PROTECT
 
  SET sLOCN_STRING = pLOCATION_NAME
  SET sLOCN_ACRONYM = SUBSTRING(1, 3, sLOCN_STRING )
  SET sCS278_KEY = CONCAT("SITE", sLOCN_ACRONYM )
 
  SELECT INTO "NL:"
    FROM CODE_VALUE   CV
   WHERE CV.CODE_SET = 278
     AND CV.DISPLAY_KEY = sCS278_KEY
     AND CV.ACTIVE_IND = 1
 
  DETAIL
    sLOCN_STRING = CV.DESCRIPTION
    ; Remove 'Hospital'
    sLOCN_STRING = REPLACE(sLOCN_STRING, "Hospital", "", 2 )
    ; Remove 'General'
    sLOCN_STRING = REPLACE(sLOCN_STRING, "General", "", 2 )
    ; Remove 'Memorial'
    sLOCN_STRING = REPLACE(sLOCN_STRING, "Memorial", "", 2 )
     ; Remove 'Centre'
    sLOCN_STRING = REPLACE(sLOCN_STRING, "Centre", "", 2 )
    ; Remove 'Health'
    sLOCN_STRING = REPLACE(sLOCN_STRING, "Health", "", 2 )
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sLOCN_STRING )
END
 
;==========================================================================================
; Returns the domain name and program
;==========================================================================================
SUBROUTINE sDOMAIN_PROGRAM(NULL )
 
  DECLARE sDOMAIN = VC WITH PROTECT
 
  SET sDOMAIN = CONCAT(TRIM(SUBSTRING(3, 10, CURUSER ) ), ":", TRIM(CURPROG ) )
 
  RETURN(sDOMAIN)
 
END
 
;==========================================================================================
; Sets the prompt operator
;==========================================================================================
SUBROUTINE sPROMPT_OPERATOR(pPARM_NUM )
 
  DECLARE sOPERATOR = C2 WITH PROTECT
 
  IF (SUBSTRING(1, 1, REFLECT(PARAMETER(pPARM_NUM, 0) ) ) = "L" )
    ; Multiple selections
    SET sOPERATOR = "IN"
  ELSEIF (PARAMETER(pPARM_NUM, 1 ) = 0.0 )
    ; Any(*) was selected
    SET sOPERATOR = "!="
  ELSE
    ; A single value was selected
    SET sOPERATOR = "="
  ENDIF
 
  RETURN(sOPERATOR )
END
 
;==========================================================================================
; Function to merge all the address lines into one string
;==========================================================================================
SUBROUTINE sADDRESS_STRING(pAddrLine1, pAddrLine2, pAddrLine3, pAddrLine4,
                           pCity, pProvCD, pPostalCd, pCountry )
 
  DECLARE Work_String = C300
 
  SET Work_String = " "
 
  IF (TRIM(pAddrLine1, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pAddrLine1, 3 ), ",$" )
  ENDIF
  IF (TRIM(pAddrLine2, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pAddrLine2, 3 ), ",$" )
  ENDIF
  IF (TRIM(pAddrLine3, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pAddrLine3, 3 ), ",$" )
  ENDIF
  IF (TRIM(pAddrLine4, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pAddrLine4, 3 ), ",$" )
  ENDIF
  IF (TRIM(pCity, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pCity, 3 ), ",$" )
  ENDIF
  IF (pProvCD NOT = 0.00 )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(sSTATE_ABBREV(pProvCD ), 3 ), ",$" )
  ENDIF
  IF (TRIM(pPostalCd, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pPostalCd, 3 ), ",$" )
  ENDIF
  IF (TRIM(pCountry, 3 ) NOT = "" )
    SET Work_String = CONCAT(TRIM(Work_String ), TRIM(pCountry, 3 ), ",$" )
  ENDIF
 
  ;Remove last ",$" at the end of the line
  SET Work_String = REPLACE(Work_String, ",$", "  ", 2 )
 
  ;Replace "$" with a blank
  SET Work_String = REPLACE(Work_String, "$", " ", 0 )
 
  RETURN(Work_String )
END
 
;==========================================================================================
; Returns the name of the person submitting the report
;==========================================================================================
SUBROUTINE sRPT_SUBMITTED_BY(pPERSON_ID )
 
  DECLARE sUSER_NAME = VC WITH PROTECT
 
  IF (pPERSON_ID = 0)
    ; When executing from the backend the updt_id is 0
    SET sUSER_NAME = "System"
  ELSE
    ; When executing from frontend application the updt_id is
    ; the person_id of the user logged in to front end app
    SET sUSER_NAME = "Invalid persion ID"
    SELECT INTO "NL:"
           P.NAME_FULL_FORMATTED
      FROM PRSNL P
     WHERE P.PERSON_ID = pPERSON_ID
    DETAIL
      sUSER_NAME = SUBSTRING(1, 100, P.NAME_FULL_FORMATTED )
    WITH NOCOUNTER
  ENDIF
 
  RETURN(sUSER_NAME )
END
 
;==========================================================================================
; Returns the code value for a specific definition and codeset
;==========================================================================================
SUBROUTINE sGET_CODE_BY_DEFINITION(pCODESET, pDEF_STRING)
 
  DECLARE fCODE_VALUE = F8
  SET fCODE_VALUE = -2.00
 
  SELECT CV.CODE_VALUE
    FROM CODE_VALUE   CV
   WHERE CV.CODE_SET = pCODESET
     AND CV.DEFINITION = pDEF_STRING
     AND CV.ACTIVE_IND = 1
 
  DETAIL
    fCODE_VALUE = CV.CODE_VALUE
 
  WITH NOCOUNTER
 
  RETURN(fCODE_VALUE)
END
 
;==========================================================================================
; Creates a parser string to use in excluding test patients
; ---------------------------------------------------------
; Report Usage:
;
; and parser(HideTestPatients("person_id field"))
;
; e.g.
;
; 	select
;		e.encntr_id
;  	from encounter			e
;  	plan e
;		where e.disch_dt_tm>cnvtdatetime(curdate-30, 0)
;  		and parser(HideTestPatients("e.person_id"))
;
;
; To include test patients when testing report changes, simply add the following line after
; the call to bc_all_all_std_routines and before your parser statement above.
;
; set includeTestPatients = 1
;
;==========================================================================================
subroutine HideTestPatients(cCompareField)
	if (includeTestPatients = 0)
		return (concat(cCompareField,
				^ not in (select person_id from person_alias where alias=patstring("599*")^,
				^ and person_alias_type_cd = cvMrn4 and active_ind=1 and end_effective_dt_tm > sysdate)^))
	else
		return ("1=1")
	endif
end
 
;==========================================================================================
; Returns the HOSite, HOGrpSite or HOGrp selected from the location tree prompt
;
;==========================================================================================
subroutine sRptHeader_Site(null )
 
  declare BCC_HOGRP = f8 with constant(sGet_Code_By_Definition(103201, "HOGRP_BCC_SITES" ) )
  declare iPick_Size = i4
  declare Site_Cnt = i4 with protect, noconstant(0)
  declare sCount = i4 with protect, noconstant(0)
  declare Rpt_Site = vc
  declare HO_value = f8
  declare HOGroup_value = f8
  declare HOGroupSite_value = f8
 
  set iPick_Size = size(rFilteredLocations->data, 5 )
  if (iPick_Size > 0 )
    select distinct into "nl:"
           ho_site_cd = rAllLocations->data[d.seq].ho_site_cd,
           ho_site = uar_get_code_display(rAllLocations->data[d.seq].ho_site_cd),
           ho_grp_site_cd = rAllLocations->data[d.seq].ho_grp_site_cd,
           ho_grp_cd = rAllLocations->data[d.seq].ho_grp_cd,
           ho_cd = rAllLocations->data[d.seq].ho_cd
      from (dummyt d with seq=value(size(rAllLocations->data, 5))),
           (dummyt d2 with seq=value(size(rFilteredLocations->data, 5))),
           location l
    plan d
    join d2
    where rFilteredLocations->data[d2.seq].location_cd = rAllLocations->data[d.seq].unit_cd
    join l
    where l.location_cd = rFilteredLocations->data[d2.seq].location_cd
    order by ho_site_cd
 
    head report
      Site_Cnt = 0
    detail
      Site_Cnt = Site_Cnt + 1
      if (Site_Cnt = 1 )
        Rpt_Site = ho_site
        HOGroupSite_value = ho_grp_site_cd
        HOGroup_value = ho_grp_cd
        HO_value = ho_cd
      endif
    with nocounter, time=30
 
    ;Check if # of sites = # of children for HOGROUPSITE
    select into "nl:"
           cvg.child_code_value
      from code_value_group cvg
     where cvg.parent_code_value = HOGroupSite_value
       and cvg.code_set = 103201
 
    head report
      sCount = 0
    detail
      sCount = sCount + 1
    with nocounter
 
    if (Site_Cnt = sCount )
      set Rpt_Site = uar_get_code_display(HOGroupSite_value )
    endif
 
    ;Check if # of sites = # of children for HOGRP (BC Cancer only)
    if (HOGroup_value = BCC_HOGRP )
      select into "nl:"
             cvg.child_code_value,
             cvg1.child_code_value
        from code_value_group cvg,
             code_value_group cvg1
       where cvg.parent_code_value = HOGroup_value
         and cvg.code_set = 103201
         and cvg1.parent_code_value = cvg.child_code_value
         and cvg1.code_set = 103201
      head report
        sCount = 0
      detail
        sCount = sCount + 1
      with nocounter
 
      if (Site_Cnt = sCount )
        set Rpt_Site = uar_get_code_display(HOGroup_value )
      endif
    endif
  else
    set Rpt_Site = "Unknown"
  endif
 
  return(Rpt_Site )
end ;subroutine
 
;==========================================================================================
; Surgical Procedure Code Definition
; Returns Parser String to evaluate if the Mnemonic is a procedure code
;
; Report Usage:
;	AND PARSER(sIS_PROCEDURE_CODE("mnemonic field"))
;
;	e.g.
;		SELECT
;			OCS.MNEMONIC
;		FROM
;			ORDER_CATALOG_SYNONYM OCS
;		WHERE
;			PARSER(sIS_PROCEDURE_CODE("OCS.MNEMONIC"))
;
; Procedure codes will all be of the form AAA##### per decision from Surgery team
;
; Exceptions:
;	1) Procedure Not Available
;		Mnemonic = "XXXX"
;
;	2) Procedure Not Performed
;		Mnemonic = "0000"
;==========================================================================================
SUBROUTINE sIS_PROCEDURE_CODE(pMNEMONIC)
 	DECLARE vPROC_CODE_PARSER = VC
 
	SET vPROC_CODE_PARSER = CONCAT( ^( ^
		;primary def
		, ^( ISNUMERIC(SUBSTRING(1, 1, ^, pMNEMONIC, ^)) = OUTERJOIN(0)^
		, ^ AND ISNUMERIC(SUBSTRING(2, 1, ^, pMNEMONIC, ^)) = OUTERJOIN(0)^
		, ^ AND ISNUMERIC(SUBSTRING(3, 1, ^, pMNEMONIC, ^)) = OUTERJOIN(0)^
		, ^ AND ISNUMERIC(SUBSTRING(4, 5, ^, pMNEMONIC, ^)) = OUTERJOIN(1) )^
 
		, ^ OR ^, pMNEMONIC, ^ = OUTERJOIN("XXXX")^ ;exception 1
		, ^ OR ^, pMNEMONIC, ^ = OUTERJOIN("0000")^ ;exception 2
		, ")"
	)
 
	RETURN(vPROC_CODE_PARSER )
END ;sSURGERY_PROCEDURE_CODE
 
;==========================================================================================
; Dump a trace of the program name for each program level
;==========================================================================================
SUBROUTINE sCURPROG_TRACE(NULL )
  declare num = i4
  declare maxnum = i4 with protect, constant(10)
  declare progname = vc
 
  free set curprog_rec
  record curprog_rec(
    1 trace_dttm = vc
    1 pgm_level[*]
      2 level_nbr = i4
      2 level_pgm = vc
  )
  with persistscript
 
  set num = 1
  set curprog_rec->trace_dttm = format(sysdate, "DD-MMM-YYYY HH:MM:SS;;Q" )
 
  while (num > 0 and num < maxnum )
    set progname = curprog(num)
    if (progname not = " " )
      set stat = alterlist(curprog_rec->pgm_level, num )
      set curprog_rec->pgm_level[num].level_nbr = num
      set curprog_rec->pgm_level[num].level_pgm = progname
      set num = num + 1
    else
      set num = 0
    endif
  endwhile
 
  call ECHOJSON(curprog_rec, "ECHOJSON_CURPROG", 1)
end
 
;******************************************************************************************
;
; Section 2: Version 2 location prompt subroutines (Removed as per Rev# 051)
;
;******************************************************************************************
 
;******************************************************************************************
;
; Section 3: FTP, SFTP and HTML subroutines
;
;******************************************************************************************
 
;==========================================================================================
; FTP File - uses unix scp command to ftp a file
;==========================================================================================
SUBROUTINE sFTPFILE(pCMD, pPATHFILENAME, pFTPSTRING)
 
  DECLARE vDCLCOM = VC
  DECLARE vDCL_LEN = I4
  DECLARE vDCL_STATUS = I4
  DECLARE vPATHFILENAME = VC
 
  SET vPATHFILENAME = REPLACE(pPATHFILENAME,"ccluserdir:","$CCLUSERDIR/")
  SET vDCLCOM = CONCAT(pCMD,trim(vPATHFILENAME,3),'" ',pFTPSTRING)
  SET vDCL_LEN = SIZE(TRIM(vDCLCOM,3))
  SET vDCL_STATUS = 0
 
  CALL DCL(vDCLCOM, vDCL_LEN, vDCL_STATUS)
  CALL ECHO(vDCLCOM)
 
END
 
;==========================================================================================
; Builds a destination and filename with a temp extension that gets ignored by sftp
;==========================================================================================
SUBROUTINE sSFTP_FileNameTmp(sFolder,sFileNoExt) ;will create a path and filename with the supplied folder and the TMP extension
 
	DECLARE vSFTPPath = VC
	DECLARE vPathFileNameTmp = VC
 
	SET vSFTPPath = CONCAT(TRIM(LOGICAL(sSFTPlogical),3),"/",TRIM(sFolder,3))
	SET vPathFileNameTmp = CONCAT(vSFTPPath,CNVTLOWER(TRIM(sFileNoExt,3)),TRIM(sSFTPtmpExt,3))
 	CALL ECHO(CONCAT("SFTP File Path: ",vPathFileNameTmp))
	RETURN (vPathFileNameTmp)
END
 
;==========================================================================================
; Renames a temporary filename extension with the proper exstension so it gets picked up by sftp
;==========================================================================================
SUBROUTINE sSFTP_RenameExt(sFolder,sFileNoExt,sFileExt) ;renames filename from .tmp to supplied extension (sFileExt)
 
	DECLARE vSFTPPath = VC
	DECLARE vPathFileNameTmp = VC
	DECLARE vPathFileNameNew = VC
	DECLARE vMvCmd = VC
	DECLARE vDCLlen = I4
	DECLARE vDCLstatus = I4
 
	SET vSFTPPath = CONCAT(TRIM(LOGICAL(sSFTPlogical),3),"/",TRIM(sFolder,3)) ;sftp standard filepath
	SET vPathFileNameTmp = CONCAT(vSFTPPath,CNVTLOWER(TRIM(sFileNoExt,3)),TRIM(sSFTPtmpExt,3)) ;sFileNoExt.tmp
	SET vPathFileNameNew = CONCAT(vSFTPPath,CNVTLOWER(TRIM(sFileNoExt,3)),CNVTLOWER(TRIM(sFileExt,3))) ;sFileNoExt.ext
	SET vMvCmd = CONCAT("mv ",vPathFileNameTmp," ",vPathFileNameNew) ;renames file from sFileNoExt.tmp to sFileNoExt.sFileExt
	SET vDCLlen = SIZE(TRIM(vMvCmd,3))
	SET vDCLstatus = 0
 	CALL ECHO(CONCAT("Move Command: ", vMvCmd))
	CALL DCL(vMvCmd, vDCLlen, vDCLstatus) ;execute the move command to rename the file
 
END
 
;==========================================================================================
; Takes a file that has been created and sends it via email, deletes the file if indicated
;==========================================================================================
SUBROUTINE sSendFileToEmail(sFolder,sFileName,sBody,sSubject,sToAddresses,bDelInd,sCcAddresses) ;sends emails
 
	DECLARE sSFTPPath = VC
	DECLARE sEmailCmd = VC
	DECLARE sDelCmd = VC
	DECLARE nDCLlen = I4
	DECLARE nDCLstatus = I4
 
	SET sSFTPPath = CONCAT(TRIM(sSFTPlogical,3),"/",TRIM(sFolder,3)) ;sftp standard filepath
	if(textlen(trim(sCcAddresses,3)) > 0) ;ccs need to be included
		SET sEmailCmd = CONCAT(^echo "^,trim(sBody,3),^" | mailx -a $^,sSFTPlogical,"/",TRIM(sFolder,3),TRIM(sFileName,3)\
															  ,^ -s "^,trim(sSubject,3),^" ^\
															  ,^ -c "^,replace(sCcAddresses," ",""),^" ^\
															  ,replace(sToAddresses," ",""))
	else ;no cc address
		SET sEmailCmd = CONCAT(^echo "^,trim(sBody,3),^" | mailx -a $^,sSFTPlogical,"/",TRIM(sFolder,3),TRIM(sFileName,3)\
															  ,^ -s "^,trim(sSubject,3),^" ^\
															  ,replace(sToAddresses," ",""))
	endif
	SET nDCLlen = SIZE(TRIM(sEmailCmd,3))
	SET nDCLstatus = 0
 	CALL ECHO(CONCAT("Email Command: ", sEmailCmd))
	CALL DCL(sEmailCmd, nDCLlen, nDCLstatus) ;execute the email command to send the file
 
 	IF(bDelInd = TRUE) ;deletes the file after use
 		SET sDelCmd = CONCAT("rm $",TRIM(sSFTPPath,3),TRIM(sFileName,3))
 		SET nDCLlen = SIZE(TRIM(sDelCmd,3))
 		CALL ECHO(CONCAT("Delete Command: ", sDelCmd))
 		CALL DCL(sDelCmd, nDCLlen, nDCLstatus) ;execute the delete command to delete the file
 	ENDIF
END ;sSendFileToEmail
 
;==========================================================================================
; Sends HTML Email with attachment
;==========================================================================================
SUBROUTINE sSendHtmlEmailwFile(sToAddresses,sCcAddresses,sSubject,sBody,sFolder,sFileName,bDelInd) ;sends emails
 
 	FREE RECORD IO	;THE RECORD STRUCTURE THAT CCLIO() USES
	RECORD IO (
		1 FILE_DESC 	= I4
		1 FILE_OFFSET 	= I4
		1 FILE_DIR 		= I4
		1 FILE_NAME 	= VC
		1 FILE_BUF 		= VC
	)
 
 	declare sEmailCmd = VC with noconstant(""), protect
 	declare sSFTPPath = VC with constant(build(sSFTPlogical,"/",sFolder)), protect 	 ;sftp standard filepath for csv file to attach
	declare sEmlCmdFileName = VC with constant(build("email_tmp_cmd",sGetTimeStamp(null),".sh")), protect
 	declare sTmpFolder = VC with constant(LOGICAL("cer_temp")), protect
 	declare sEmailFolderFileCmd = VC with constant(build(sTmpFolder,"/",sEmlCmdFileName)), protect
	declare sExecuteCmd = VC with constant(concat("sh ",trim(sEmailFolderFileCmd,3),"; rm -f ",trim(sEmailFolderFileCmd,3))), protect
	declare sDelCmd = VC with noconstant(concat("rm $",trim(sSFTPPath,3),trim(sFileName,3))), protect
	declare nStatus = i1 with noconstant(0), protect
 
	set sEmailCmd = concat(^(echo "To:^,replace(sToAddresses," ",""),^"; ^)						;start building the email command
	if(textlen(trim(sCcAddresses,3)) > 0)	set sEmailCmd = concat(sEmailCmd,^echo "Cc: ^,trim(sCcAddresses,3),^"; ^)	endif
	set sEmailCmd = concat(sEmailCmd,^echo "Subject: ^,trim(sSubject,3),^"; ^					\
									,^echo "MIME-Version: 1.0"; ^								\
									,^echo "Content-Type:multipart/mixed; boundary=\"gc0p4Jq0M2Yt08jU534c0p\""; ^			\
									,^echo ""; ^												\
									,^echo "--gc0p4Jq0M2Yt08jU534c0p";^							\
									,^echo "Content-Type: text/html; charset=\"UTF-8\""; ^		\
									,^echo "Content-Transfer-Encoding: 7bit"; ^					\
									,^echo "Content-Disposition: inline"; ^						\
									,^echo ""; ^												\
									,^echo "^,trim(sBody,3),^"; ^								\
									,^echo "--gc0p4Jq0M2Yt08jU534c0p"; ^						\
									,^echo "Content-Type: text/csv"; ^							\
									,^echo "Content-Disposition: attachement; filename=\"^,trim(sFileName,3),^\""; ^		\
									,^echo ""; ^												\
									,^cat $^,trim(sSFTPPath,3),trim(sFileName,3),^; ^			\
									,^echo ""; ^												\
									,^) | sendmail -t ^) ;using sendmail for html and attachment
 
 	call ECHO(CONCAT("Email Command: ", sEmailCmd)) 					;debugging
 	set IO->FILE_NAME = build(sTmpFolder,"/",sEmlCmdFileName)			;create tmp email command filename, dcl has limited chars
	set IO->FILE_BUF = "w"   											;CASE SENSITIVE MUST BE LOWERCASE
 	set STAT = CCLIO("OPEN",IO) 										;open the file to be ready to write to
 	set IO->FILE_BUF = sEmailCmd										;load the email command
	set STAT = CCLIO("PUTS",IO)											;write out the command
	set nWRITE_STATUS = CCLIO("CLOSE",IO)								;close the file
	call dcl(sExecuteCmd, size(trim(sExecuteCmd,3)), nStatus)			;execute the file to email content and attachment, then delete tmp file
 	if(bDelInd = TRUE) 													;deletes the attachment file after use if indicated
 		call echo(concat("Delete Command: ", trim(sDelCmd,3)))			;debugging
 		call dcl(sDelCmd, size(trim(sDelCmd,3)), nStatus) 				;execute the delete command to delete the file
 	endif ;*/
END ;sSendHtmlEmailwFile
 
;==========================================================================================
; Returns very unique timestamp
;==========================================================================================
subroutine sGetTimeStamp(NULL) ;returns a unique timestamp signature
	declare sTimeStamp = C26 with protect
	declare dTimeStampDt = dm12 with constant(SYSTIMESTAMP), protect
	declare sTimeStampFormat = VC with CONSTANT("YYYY-MM-DD_HH-MM-SS_CCCCCC;;D"), PROTECT
	set sTimeStamp = FORMAT(dTimeStampDt,sTimeStampFormat)
	return(sTimeStamp)
end ;sGetTimeStamp
 
;==========================================================================================
; Cleans text from special html characters (eg "&gl;" to ">"
;==========================================================================================
SUBROUTINE sCleanHTMLChars(sCleanTxt)
	SET sCleanTxt = REPLACE(sCleanTxt,"&nbsp;"," ",0) ;replace all html spaces
	SET sCleanTxt = REPLACE(sCleanTxt,"&#xa0;"," ",0) ;replace all html spaces
	SET sCleanTxt = REPLACE(sCleanTxt,"&#33;","!",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#34;",'"',0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&quot",'"',0) ;friendly
	SET sCleanTxt = REPLACE(sCleanTxt,"&#35;","#",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#36;","$",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#37;","%",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#38;","&",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&amp;","&",0) ;friendly
	SET sCleanTxt = REPLACE(sCleanTxt,"&#39;","'",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#40;","(",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#41;",")",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#42;","*",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#43;","+",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#44;",",",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#45;","-",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#46;",".",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#47;","/",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&frasl;","/",0) ;friendly
	SET sCleanTxt = REPLACE(sCleanTxt,"&#58;",":",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#59;",";",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#60;","<",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&lt;","<",0) ;friendly
	SET sCleanTxt = REPLACE(sCleanTxt,"&#61;","=",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#62;",">",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&gt;",">",0) ;friendly
	SET sCleanTxt = REPLACE(sCleanTxt,"&#63;","?",0)
	SET sCleanTxt = REPLACE(sCleanTxt,"&#64;","@",0)
  RETURN(sCleanTxt)
END
 
;******************************************************************************************
;
; Section 4: Orders & Requisition subroutines
;
;******************************************************************************************
 
;==========================================================================================
; Returns the originating encounter ID for an order
;==========================================================================================
SUBROUTINE sGET_ORIG_ENCNTR_ID(pORDER_ID)
 
  DECLARE ORIG_ENCNTR_NUM = F8
  SET ORIG_ENCNTR_NUM = 0.00
 
  SELECT INTO "nl:"
    FROM ORDERS   O
   WHERE O.ORDER_ID = pORDER_ID
 
  DETAIL
    ORIG_ENCNTR_NUM = O.ORIGINATING_ENCNTR_ID
 
  WITH NOCOUNTER
 
  RETURN(ORIG_ENCNTR_NUM)
END
 
;==========================================================================================
; Checks if an order is of order type and return indicator flag
;==========================================================================================
SUBROUTINE sORDER_TYPE_EQUAL(pORDER_ID, pORDER_TYPE)
 
  DECLARE sORDER_MATCH_TYPE  = I2 WITH PROTECT
 
  SET sORDER_MATCH_TYPE = 0
 
  SELECT INTO "NL:"
    FROM ORDERS O
   WHERE O.ORDER_ID = pORDER_ID
 
  DETAIL
    IF (O.ORDER_STATUS_CD = pORDER_TYPE )
      sORDER_MATCH_TYPE = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sORDER_MATCH_TYPE )
END
 
;==========================================================================================
; Checks if a requisition should by printed based on the order status
; Statuses: Cancelled, Completed or Discontinued
;==========================================================================================
SUBROUTINE sBYPASS_PRINT_ON_STATUS(pORDER_ID, pCANCELLED, pCOMPLETED, pDISCONTINUED )
 
  DECLARE sNOPRINT_REQ = I2 WITH PROTECT
  ; Action types to be bypassed
  DECLARE cvACTION_CANCEL      = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6003, "CANCEL"))
  DECLARE cvACTION_COMPLETE    = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6003, "COMPLETE"))
  DECLARE cvACTION_DISCONTINUE = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6003, "DISCONTINUE"))
 
  ; Order statuses to be bypassed
  DECLARE cvSTATUS_CANCEL      = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6004, "CANCELED"))
  DECLARE cvSTATUS_COMPLETE    = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6004, "COMPLETED"))
  DECLARE cvSTATUS_DISCONTINUE = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6004, "DISCONTINUED"))
 
  ; Default to print
  SET sNOPRINT_REQ = 0
 
  SELECT INTO "NL:"
         O.ORDER_ID,
         O.ORDER_STATUS_CD,
         OA.ACTION_TYPE_CD
    FROM ORDERS O,
         ORDER_ACTION OA
   WHERE O.ORDER_ID = pORDER_ID
     AND OA.ORDER_ID = O.ORDER_ID
 
  ORDER BY OA.UPDT_DT_TM DESC
 
  ; The order by clause ensures that the latest order action is used
  HEAD O.ORDER_ID
    IF ((O.ORDER_STATUS_CD = cvSTATUS_CANCEL      AND pCANCELLED = 1 )    OR
        (O.ORDER_STATUS_CD = cvSTATUS_COMPLETE    AND pCOMPLETED = 1 )    OR
        (O.ORDER_STATUS_CD = cvSTATUS_DISCONTINUE AND pDISCONTINUED = 1 ) OR
        (OA.ACTION_TYPE_CD = cvACTION_CANCEL      AND pCANCELLED = 1 )    OR
        (OA.ACTION_TYPE_CD = cvACTION_COMPLETE    AND pCOMPLETED = 1 )    OR
        (OA.ACTION_TYPE_CD = cvACTION_DISCONTINUE AND pDISCONTINUED = 1 ) )
      sNOPRINT_REQ = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sNOPRINT_REQ )
END
 
;==========================================================================================
; Checks if a requisition should by printed based on the order status
; Status: Modify
;==========================================================================================
SUBROUTINE sBYPASS_PRINT_ON_STATUS2(pORDER_ID, pMODIFY )
 
  DECLARE sNOPRINT_REQ = I2 WITH PROTECT
  ; Action types to be bypassed
  DECLARE cvACTION_MODIFY = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6003, "MODIFY"))
 
  ; Default to print
  SET sNOPRINT_REQ = 0
 
  SELECT INTO "NL:"
         O.ORDER_ID,
         O.ORDER_STATUS_CD,
         OA.ACTION_TYPE_CD
    FROM ORDERS O,
         ORDER_ACTION OA
   WHERE O.ORDER_ID = pORDER_ID
     AND OA.ORDER_ID = O.ORDER_ID
 
  ORDER BY OA.UPDT_DT_TM DESC
 
  ; The order by clause ensures that the latest order action is used
  HEAD O.ORDER_ID
    IF (OA.ACTION_TYPE_CD = cvACTION_MODIFY AND pMODIFY = 1 )
      sNOPRINT_REQ = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sNOPRINT_REQ )
END
 
;==========================================================================================
; Checks if a requisition should by printed based on the order status
; Statuses: Cancelled, Completed or Discontinued
;==========================================================================================
SUBROUTINE sBYPASS_PRINT_ON_INPROCESS(pORDER_ID, pINPROCESS )
 
  DECLARE sNOPRINT_REQ = I2 WITH PROTECT
  ; Order statuses to be bypassed
  DECLARE cvSTATUS_INPROCESS   = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 6004, "INPROCESS"))
 
  ; Default to print
  SET sNOPRINT_REQ = 0
 
  SELECT INTO "NL:"
         O.ORDER_ID,
         O.ORDER_STATUS_CD,
         OA.ACTION_TYPE_CD
    FROM ORDERS O,
         ORDER_ACTION OA
   WHERE O.ORDER_ID = pORDER_ID
     AND OA.ORDER_ID = O.ORDER_ID
 
  ORDER BY OA.UPDT_DT_TM DESC
 
  ; The order by clause ensures that the latest order action is used
  HEAD O.ORDER_ID
    IF (O.ORDER_STATUS_CD = cvSTATUS_INPROCESS AND pINPROCESS = 1 )
      sNOPRINT_REQ = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sNOPRINT_REQ )
END
 
;==========================================================================================
; Checks if a encounter location is equal to the location passed.
;==========================================================================================
SUBROUTINE sENCNTR_UNIT_IN(pUNIT_CD, pENCNTR_ID )
 
  DECLARE sLOCN_MATCH = I2 WITH PROTECT
 
  ; Default to no match
  SET sLOCN_MATCH = 0
 
  SELECT INTO "NL:"
         E.LOC_NURSE_UNIT_CD
    FROM ENCOUNTER   E
   WHERE E.ENCNTR_ID = pENCNTR_ID
 
  DETAIL
    IF (E.LOC_NURSE_UNIT_CD = pUNIT_CD )
      sLOCN_MATCH = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sLOCN_MATCH )
END
 
;==========================================================================================
; Checks if an order is a parent order (has an frequency OEF with non "ONCE" value
;==========================================================================================
SUBROUTINE sPARENT_ORDER(pORDER_ID )
 
  DECLARE sPARENT_IND = I2 WITH PROTECT
  DECLARE OEF_FREQUENCY = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY", 16449, "FREQUENCY" ) )
 
  SET sPARENT_IND = 0
 
  SELECT INTO "NL:"
         O.ORDER_ID
    FROM ORDERS O,
         ORDER_DETAIL OD
   WHERE O.ORDER_ID = pORDER_ID
     AND OD.ORDER_ID = O.ORDER_ID
     AND OD.OE_FIELD_ID = OEF_FREQUENCY
 
  DETAIL
    IF (CNVTUPPER(TRIM(OD.OE_FIELD_DISPLAY_VALUE ) ) NOT = "ONCE" )
      sPARENT_IND = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sPARENT_IND )
END
 
;==========================================================================================
; Checks if an order is a child order (has an non-zero template_order_id)
;==========================================================================================
SUBROUTINE sCHILD_ORDER(pORDER_ID )
 
  DECLARE sCHILD_IND = I2 WITH PROTECT
 
  SET sCHILD_IND = 0
 
  SELECT INTO "NL:"
         O.ORDER_ID
    FROM ORDERS O
   WHERE O.ORDER_ID = pORDER_ID
 
  DETAIL
    IF (O.TEMPLATE_ORDER_ID NOT = 0.00 OR O.PROTOCOL_ORDER_ID NOT = 0.00 )
      sCHILD_IND = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sCHILD_IND )
END
 
;==========================================================================================
; Return the 3 character site mnemonic where the order originated from
;==========================================================================================
SUBROUTINE sENCNTR_SITE_MNEMONIC(pENCNTR_ID )
 
  DECLARE cSITE = C3 WITH PROTECT
 
  ; Default to no site
  SET cSITE = " "
 
  SELECT INTO "NL:"
	       SITE = SUBSTRING(1, 3, UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD) )
    FROM ENCOUNTER   E
   WHERE E.ENCNTR_ID = pENCNTR_ID
 
  DETAIL
    cSITE = SITE
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(cSITE )
END
 
;==========================================================================================
; Retrieve printer
;==========================================================================================
SUBROUTINE sFETCH_PRINTER(pSITE, pROUTE )
 
  DECLARE vRTN_PRINTER = VC WITH PROTECT
 
  ; Default to no printer
  SET vRTN_PRINTER = " "
 
  SELECT INTO "NL:"
         LABSITE = SUBSTRING(1, 3, UAR_GET_CODE_DISPLAY(DFR.VALUE1_CD) )
    FROM DCP_OUTPUT_ROUTE   DOR
       , DCP_FLEX_RTG   DFR
       , DCP_FLEX_PRINTER   DFP
   WHERE DOR.ROUTE_DESCRIPTION = pROUTE
     AND DFR.DCP_OUTPUT_ROUTE_ID = DOR.DCP_OUTPUT_ROUTE_ID
     AND DFP.DCP_OUTPUT_ROUTE_ID = DOR.DCP_OUTPUT_ROUTE_ID
     AND DFP.DCP_FLEX_RTG_ID = DFR.DCP_FLEX_RTG_ID
 
  DETAIL
    IF (LABSITE = pSITE)
      vRTN_PRINTER = DFP.PRINTER_NAME
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(vRTN_PRINTER )
END
 
;==========================================================================================
; Set flag is the encounter is in Emergency
;==========================================================================================
SUBROUTINE sENCNTR_IN_ED(pENCNTR_ID )
 
  DECLARE iED_LOCN_IND = I2 WITH PROTECT
 
  ; Default to not ED indication
  SET iED_LOCN_IND = 0
 
  SELECT INTO "NL:"
         ED_IND = IF (SUBSTRING(5, 20, UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD) ) = "ED"  OR
                      SUBSTRING(5, 20, UAR_GET_CODE_DISPLAY(E.LOC_NURSE_UNIT_CD) ) = "ED Hold" )
                    1
                  ELSE
                    0
                  ENDIF
    FROM ENCOUNTER   E
   WHERE E.ENCNTR_ID = pENCNTR_ID
     AND E.LOC_NURSE_UNIT_CD > 0
 
  DETAIL
    iED_LOCN_IND = ED_IND
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(iED_LOCN_IND )
END
 
;==========================================================================================
; Check if an order is part of a PowerPlan
;==========================================================================================
SUBROUTINE sPOWERPLAN_ORDER(pORDER_ID )
 
  DECLARE sPOWERPLAN_IND = I2 WITH PROTECT
 
  SET sPOWERPLAN_IND = 0
 
/* ;035 Start
  SELECT iNTO "NL:"
         A.PATHWAY_ID
  FROM ACT_PW_COMP   A
  WHERE A.PARENT_ENTITY_NAME = "ORDERS"
    AND A.PARENT_ENTITY_ID = pORDER_ID
 
  DETAIL
    sPOWERPLAN_IND = 1
*/ ;035 End
 
;035 Start
  SELECT INTO "NL:"
         O.PATHWAY_CATALOG_ID
  FROM ORDERS   O
  WHERE O.ORDER_ID = pORDER_ID
 
  DETAIL
    IF (O.PATHWAY_CATALOG_ID > 0.00 )
      sPOWERPLAN_IND = 1
    ENDIF
;035 End
 
  WITH NOCOUNTER, TIME=1
 
  RETURN(sPOWERPLAN_IND )
END
 
;==========================================================================================
; Checks if an order is in an Oncology PowerPlan
;==========================================================================================
SUBROUTINE sONCOLOGY_POWERPLAN_ORDER(pORDER_ID )
 
  DECLARE sPP_ORDER_IND = I2 WITH PROTECT
 
  ; Oncology PowerPlans
  DECLARE cvBMT = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30183, "BMT"))
  DECLARE cvCAP = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30183, "COMPASSIONATEACCESSPROGRAM"))
  DECLARE cvOMD = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30183, "ONCOLOGYMULTIDISCIPLINARY"))  ;060
  DECLARE cvONC = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30183, "ONCOLOGY"))
  DECLARE cvRAD = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30183, "RADIATIONTHERAPY"))  ;062
 
  SET sPP_ORDER_IND = 0
 
  SELECT INTO "NL:"
         P.PATHWAY_TYPE_CD
    FROM ORDERS   O
	     , PATHWAY_CATALOG   P
 
   WHERE O.ORDER_ID = pORDER_ID
     AND P.PATHWAY_CATALOG_ID = O.PATHWAY_CATALOG_ID
 
  DETAIL
    IF (P.PATHWAY_TYPE_CD = cvBMT OR
        P.PATHWAY_TYPE_CD = cvCAP OR
        P.PATHWAY_TYPE_CD = cvOMD OR   ;060
        P.PATHWAY_TYPE_CD = cvONC OR
        P.PATHWAY_TYPE_CD = cvRAD      ;062
       )
      sPP_ORDER_IND = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sPP_ORDER_IND )
END
 
;==========================================================================================
; Check if an order is part of a regimen
;==========================================================================================
SUBROUTINE sREGIMEN_ORDER(pORDER_ID )
 
  DECLARE sREGIMEN_IND = I2 WITH PROTECT
 
  SET sREGIMEN_IND = 0
 
  SELECT INTO "NL:"
	       RD.REGIMEN_ID
    FROM ACT_PW_COMP    APC
       , PATHWAY        PA
       , REGIMEN_DETAIL RD
 
  WHERE APC.PARENT_ENTITY_ID = pORDER_ID
    AND APC.PARENT_ENTITY_NAME = "ORDERS"
    AND PA.PATHWAY_ID = APC.PATHWAY_ID
    AND PA.PATHWAY_ID NOT = PA.PATHWAY_GROUP_ID
    AND RD.ACTIVITY_ENTITY_ID = PA.PW_GROUP_NBR
 
  DETAIL
    sREGIMEN_IND = 1
 
  WITH NOCOUNTER, TIME=5
 
  RETURN(sREGIMEN_IND )
END
 
;==========================================================================================
; Check if an order is part of a Oncology DOT PowerPlan
;==========================================================================================
SUBROUTINE sONCOLOGY_DOT_PP_ORDER(pORDER_ID )
 
  DECLARE sDOTPP_IND = I2 WITH PROTECT
 
  SET sDOTPP_IND = 0
 
/* ;065 Start
  SELECT INTO "NL:"
	       PC.DESCRIPTION
    FROM ORDERS          O
       , PATHWAY         P
       , PATHWAY_CATALOG PC
 
  WHERE O.ORDER_ID = pORDER_ID
    AND P.PATHWAY_CATALOG_ID = O.PATHWAY_CATALOG_ID
    AND PC.PATHWAY_CATALOG_ID = P.PW_CAT_GROUP_ID
    AND (PC.DESCRIPTION_KEY = "ONCP*" OR PC.DESCRIPTION_KEY = "RESEARCH-ONCP*" )
*/ ;065 End
 
;065 Start
  SELECT INTO "NL:"
    FROM ORDERS  O
   WHERE O.ORDER_ID = pORDER_ID
     AND (O.TEMPLATE_ORDER_FLAG = 7 OR O.PROTOCOL_ORDER_ID NOT = 0.00 )
;065 End
 
  DETAIL
    sDOTPP_IND = 1
 
  WITH NOCOUNTER, TIME=5
 
  RETURN(sDOTPP_IND )
END
 
;==========================================================================================
; Retrieve the diet texture order requirement
;==========================================================================================
SUBROUTINE sDIET_TEXTURE(pORDER_ID )
 
  DECLARE cvTEXTURE_MODIFIERS = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "TEXTUREMODIFIERS"))
  DECLARE sTEXTURE = VC WITH PROTECT
 
  SET sTEXTURE = ""
 
  SELECT INTO "NL:"
	       OEF_VALUE = OD.OE_FIELD_DISPLAY_VALUE
    FROM ORDER_DETAIL    OD
 
  WHERE OD.ORDER_ID = pORDER_ID
    AND OD.OE_FIELD_ID = cvTEXTURE_MODIFIERS
 
  ORDER BY OD.ACTION_SEQUENCE
 
  DETAIL
    sTEXTURE = TRIM(OEF_VALUE, 3 )
 
  WITH NOCOUNTER, TIME=5
 
  RETURN(sTEXTURE )
END
 
;==========================================================================================
; Retrieve the diet viscosity order requirement
;==========================================================================================
SUBROUTINE sDIET_VISCOSITY(pORDER_ID )
 
  DECLARE cvFLUID_VISCOSITY = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "FLUIDVISCOSITY"))
  DECLARE sVISCOSITY = VC WITH PROTECT
 
  SET sVISCOSITY = ""
 
  SELECT INTO "NL:"
	       OEF_VALUE = OD.OE_FIELD_DISPLAY_VALUE
    FROM ORDER_DETAIL    OD
 
  WHERE OD.ORDER_ID = pORDER_ID
    AND OD.OE_FIELD_ID = cvFLUID_VISCOSITY
 
  ORDER BY OD.ACTION_SEQUENCE
 
  DETAIL
    sVISCOSITY = TRIM(OEF_VALUE, 3 )
 
  WITH NOCOUNTER, TIME=5
 
  RETURN(sVISCOSITY )
END
 
;==========================================================================================
; Set requisition bypass indicator if MUSE sends back a Final action
;==========================================================================================
SUBROUTINE sECG_MUSE_BYPASS(pORDER_ID )
 
  DECLARE cvMODIFY = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("MEANING", 6003, "MODIFY"))
  DECLARE cvCOMPLETE = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("MEANING", 6003, "COMPLETE"))
  DECLARE cvSTATUSCHANGE = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("MEANING", 6003, "STATUSCHANGE"))
  DECLARE cvINPROCESS = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("MEANING", 6004, "INPROCESS"))
  DECLARE sMUSE_BYPASS = I2 WITH PROTECT
 
  SET sMUSE_BYPASS = 0
 
/* ;059 Start
  ;Retrieve the latest action
  SELECT INTO "NL:"
         OA.ACTION_TYPE_CD,
         OA.ORDER_STATUS_CD,
         OA.DEPT_STATUS_CD
    FROM ORDER_ACTION OA
 
  WHERE OA.ORDER_ID = pORDER_ID
    AND OA.ACTION_SEQUENCE = (SELECT MAX(OA1.ACTION_SEQUENCE)
                                FROM ORDER_ACTION OA1
                               WHERE OA1.ORDER_ID = OA.ORDER_ID )
 
  DETAIL
    IF (OA.ACTION_TYPE_CD = cvMODIFY OR
        OA.ACTION_TYPE_CD = cvCOMPLETE OR
        OA.ACTION_TYPE_CD = cvSTATUSCHANGE )
      sMUSE_BYPASS = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=5
*/ ;059 End
 
;059 Start
  ;Retrieve the latest action and order status
  SELECT INTO "NL:"
         O.ORDER_STATUS_CD,
         OA.ACTION_TYPE_CD,
         OA.ORDER_STATUS_CD,
         OA.DEPT_STATUS_CD
    FROM ORDERS O,
         ORDER_ACTION OA
 
  WHERE O.ORDER_ID = pORDER_ID
    AND OA.ORDER_ID = O.ORDER_ID
    AND OA.ACTION_SEQUENCE = (SELECT MAX(OA1.ACTION_SEQUENCE)
                                FROM ORDER_ACTION OA1
                               WHERE OA1.ORDER_ID = OA.ORDER_ID )
 
  DETAIL
    IF (OA.ACTION_TYPE_CD = cvMODIFY OR
        OA.ACTION_TYPE_CD = cvCOMPLETE OR
        OA.ACTION_TYPE_CD = cvSTATUSCHANGE OR
        O.ORDER_STATUS_CD = cvINPROCESS )
      sMUSE_BYPASS = 1
    ENDIF
 
  WITH NOCOUNTER, TIME=5
;059 End
 
  RETURN(sMUSE_BYPASS )
END
 
;==========================================================================================
; Check if an order has no children order
;==========================================================================================
SUBROUTINE sHAS_CHILD_ORDER(pORDER_ID )
 
  DECLARE sCHILD_FOUND = I2 WITH PROTECT
 
  SET sCHILD_FOUND = 0
 
  SELECT INTO "NL:"
         O.ORDER_ID
    FROM ORDERS O
   WHERE O.TEMPLATE_ORDER_ID = pORDER_ID
      OR O.PROTOCOL_ORDER_ID = pORDER_ID
 
  DETAIL
    sCHILD_FOUND = 1
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sCHILD_FOUND )
END
 
;==========================================================================================
; Check if a MI order was entered by Scheduling
;==========================================================================================
SUBROUTINE sSCHEDULING_MI_ORDER(pORDER_ID )
 
  DECLARE cvENTERBY = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 16449, "ORDERENTEREDBY"))
  DECLARE sSCH_MI_ORDER = I2 WITH PROTECT
 
  SET sSCH_MI_ORDER = 0
 
  SELECT INTO "NL:"
         OD.ORDER_ID
    FROM ORDER_DETAIL OD
   WHERE OD.ORDER_ID = pORDER_ID
     AND OD.OE_FIELD_ID = cvENTERBY
     AND OD.OE_FIELD_DISPLAY_VALUE = "Scheduling"
 
  ORDER BY OD.ACTION_SEQUENCE
 
  DETAIL
    sSCH_MI_ORDER = 1
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sSCH_MI_ORDER )
END
 
;==========================================================================================
; Checks if an order is in an Laboratory Powerplan order
;==========================================================================================
SUBROUTINE sLAB_DOT_ORDER(pORDER_ID )
 
  DECLARE cv30720_SEQUENCED = F8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30720, "SEQUENCED"))
  DECLARE sDOT_ORDER_IND = I4 WITH PROTECT
 
  ; Lab Day of Treatment
  DECLARE cv30183_Medical = f8 WITH PROTECT, CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 30183, "MEDICAL"))
 
  SET sDOT_ORDER_IND = 0
 
  SELECT INTO "NL:"
         P.PATHWAY_TYPE_CD
    FROM ORDERS   O
	     , PATHWAY_CATALOG   P
 
   WHERE O.ORDER_ID = pORDER_ID
     AND P.PATHWAY_CATALOG_ID = O.PATHWAY_CATALOG_ID
 
  DETAIL
    IF (P.PATHWAY_TYPE_CD = cv30183_Medical )
      ; Day of Treatment powerplan
      IF ((P.TYPE_MEAN = "PATHWAY" AND P.DISPLAY_METHOD_CD = cv30720_SEQUENCED ) OR P.TYPE_MEAN = "DOT" )
        sDOT_ORDER_IND = 1
      ENDIF
      ; Single and Multi Phase powerplan
      IF ((P.TYPE_MEAN = "CAREPLAN" ) OR (P.TYPE_MEAN = "PATHWAY" AND P.DISPLAY_METHOD_CD NOT = cv30720_SEQUENCED ))
        sDOT_ORDER_IND = 2
      ENDIF
    ENDIF
 
  WITH NOCOUNTER, TIME=10
 
  RETURN(sDOT_ORDER_IND )
END
 
;==========================================================================================
; Extract code value when the only difference between a number of related code values is
; the description.
;==========================================================================================
subroutine sGet_Code_By_Desc(pDisplayKey, pDescription )
  declare fCodeValue = f8
 
  set fCodeValue = -1.00
 
  select cv.code_value
    from code_value   cv
   where cv.display_key = pDisplayKey
     and cv.description = pDescription
     and cv.active_ind = 1
 
  detail
    fCodeValue = cv.code_value
  with nocounter
 
  return(fCodeValue)
end ;Subroutine
 
;******************************************************************************************
; Subroutines have been grouped into the original categories that they have been created
; for originally. When adding a new subroutine insert it into one of the following groups
; listed below. The groups are located above and can be found by searching to the string
; below.
;******************************************************************************************
; Section 1: Original & Miscellaneous subroutines
; Section 2: Version 2 location prompt subroutines
; Section 3: FTP, SFTP and HTML subroutines
; Section 4: Orders & Requisition subroutines
;******************************************************************************************
;
; Avoiding adding subroutines after this point.
;
;******************************************************************************************
 
END GO

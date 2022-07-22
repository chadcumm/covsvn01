/*~BB~************************************************************************
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

      Date Written      : 12/03/99
      Source file       : cov_eks_t_ce_surg_doc.prg
      Object name       : cov_eks_t_ce_surg_doc
      ---------------------------------------------------------------------
      Product           : Expert Knowledge Module
      Product Team      : Discern Expert
      HNA Version       : HNAM 500.007.008
      CCL Version       : 007.008
      ---------------------------------------------------------------------
      Template Type     : Logic
      Supported Events  : PATIENT_EVENT, ORDER_EVENT, AP_ORDER_EVENT,
                          CLINICAL_EVENT, RESULT_EVENT
      Tables read       : clinical_event, v500_event_event_set_explode,
                          v500_event_set_code
      Code Sets read    : 000008 - Result status codes
                          000052 - Normalcy codes
      Tables Updated    : None.
      Assumptions       :
	  ---------------------------------------------------------------------
      Description       : Checks the most recent result for any procedure
         defined in EVENT_SET_NAME to see if the result status is listed in
         STATUS and the normalcy code is listed in NORMALCY.  Additional
         parameters OPT_LINK, OPT_TIME_NUM, and OPT_TIME_UNITS may also be
         applied, but, are not required.

      External variables
             EVENT_SET_NAME   Required string list that names all possible
                              events sets.  The text must match the
                              V500_EVENT_SET_CODE->EVENT_SET_NAME field.
                              Optional entry "*Any Event Sets" may be
                              passed anywhere in the string with a code
                              value of "0.00" to select any event set with
                              out checking V500_EVENT_SET_CODE tables.

             NORMALCY         Required string list with all possible normalcy
                              codes.  An entry of "*Any normalcy" and a value
                              of "0.00" will select any result without
                              checking the normalcy code.

             OPT_LINK         Optional link value

             OPT_TIME_NUM     Optional integer index time interval from
                              current date and time.

             OPT_TIME_UNIT    Optional (required if OPT_TIME_NUM is filled out)
                              Unit of time to apply OPT_TIME_NUM.  May be
                              MINUTES, HOURS, or DAYS only.

             STATUS           Required string list that names all possible
                              result status by code_value.  The entry of
                              "*Any Status" and a code_value of "0.00"
                              will select a result without checking the
                              status code.
      Special Notes   	:
	  ---------------------------------------------------------------------
      Logic (PDL)       :
            1) Set ClinicalEvents empty
            2) For each event in clinical_event do
            3)	Get last result for event
            4)	If event->result_status is in STATUS list
            5)      If event->normalcy code is in NORMALCY list
            6)            If event->name is in EVENT_SET_NAME list
            7)                  If event->event_start_dt_tm >= date_time_cutoff
            8)                        Add event to ClinicalEvents
            9) If ClinicalEvents is not empty
            10)      Copy ClinicalEvents to eksdata->misc with formatting.

******************************************************************************/


;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;    *001 12/13/00 CERTQB               Removed TRUE/FALSE declaration      *
;    *002 01/02/01 CERTQB               Correction to GetParentLink         *
;    *003 07/25/02 VC4308               Added new select statement to get   *
;    *                                  event_set_codes from                *
;    *                                  v500_event_set_code table. Changed  *
;    *                                  old select statement to make it     *
;    *                                  work with event_set_cd.             *
;    *004 09/14/05 VC4308               Replaced event_start_dt_tm with     *
;    *                                  event_end_dt_tm. Added              *
;    *                                  tempStartTime.                      *
;    *005 07/06/06 ry4174               change "M" to "MIN"                 *
;    *006 04/29/09 ry4174               cnvtstring issue correction         *
;    *007 08/23/10 ry4174               performance modification            *
;    *008 08/23/14 ry4174               logic correction                    *
;    *009 03/31/16 ry4174               large sequence number fix           *
;    *010 10/10/16 vc4308               Performance improvement. Added      *
;    *                                  orahintcbo to choose XIE9 CE index. *
;    *011 06/10/19 ccummin4             Added logic to find primary surgeon *
;DE~*************************************************************************

;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

drop program cov_eks_t_ce_surg_doc:dba  go
create program cov_eks_t_ce_surg_doc:dba

;External Variables
;tname		= c20	; Contains parent template name
;retVal		= i4	; Final result (TRUE/FALSE/FAILED)
%i cclsource:eks_tell_ekscommon.inc

;MOD 001 TRUE/FALSE defined in ccl start as 1/0.
;set TRUE			= 100	; EKM Rule true status value
;set FALSE			= 0		; EKM Rule false status value
set FAILED			= -1	; EKM Rule failed with error status value
set NOP				= -2	; EKM No opperation status code.

set MAX_STR_LEN		= 132	; Maximum string length
set MAX_DATA_LEN	= 80	; Maxiumu eksdat->data length per line
set RTL_WRITE_FMT	= FALSE	; Write formatted log messages
set CE_VIEW_UNRESTRICTED= 1 ;Clinical event lowest view level
set CR_RESULT_DELTA	= 5		;ClinicalResults->Results growth size


declare gEkmMessage	= c132	; WriteMessage text
declare gEkmError	= i4	; TRUE if an error has occured
declare gEkmMsgNo	= i4	; WriteMessage count.
declare gEkmResult	= i4	; TRUE/FALSE/FAILED return result
;009 declare accessionID = i4
declare accessionID = f8 ;009
;009 declare	orderID		= i4
declare	orderID		= f8 ;009
;009 declare	encntrID 	= i4
declare	encntrID 	= f8 ;009
;009 declare	personID	= i4
declare	personID	= f8 ;009
;009 declare	eksTaskAssayCD=i4
declare	eksTaskAssayCD=f8 ;009

declare tempStartTime = f8		; 004
set tempStartTime = curtime3	; 004

declare timeUnit = vc	;005
declare interval = vc	;005

;* The subroutine GetLastResults will populate ClinicalResults
;* with the most recent results eliminating all duplicate results.
record ClinicalResults (
	1 cnt					= i4
	1 matches				= i4
	1 Results[*]
		2 clinical_event_id = f8	;008
		2 report_flag		= i4
		2 normalcy_cd		= f8
		2 result_status_cd	= f8
		2 event_cd			= f8
		2 event_set_cd		= f8
		2 collection_dt_tm	= dq8
		2 event_set_name	= vc
		2 result_val		= vc
)
set ClinicalResults->cnt = 0

;* Parsed EVENT_SET_NAME string
record EVENT_SET_NAMEList (
	1 cnt					= i4
	1 qual[*]
		2 value				= vc
		2 display			= vc
)
set EVENT_SET_NAMEList->cnt = 0
set bAnyEventSet = FALSE

;* Parsed STATUS string
record STATUSList (
	1 cnt					= i4
	1 qual[*]
		2 value				= vc
		2 display			= vc
)
set STATUSList->cnt = 0
set bAnyResultStatus		= FALSE		;* True if any status was passed

;* Parsed NORMALCY string
record NORMALCYList (
	1 cnt					= i4
	1 qual[*]
		2 value				= vc
		2 display			= vc
)
set NORMALCYList->cnt = 0
set	bAnyNormalcy			= FALSE		;* TRUE if any normal value will be
										;* selected

;* Optional parameters
declare	linkTo				= i4		;* Parent Template Link ID
set		collectionCutOff	= CnvtDateTime(CurDate,CurTime3);* D/T Oldest date to evaluate
;009 declare	gPersonID			= i4		;* Event person_id from eksdata
declare	gPersonID			= f8		;* Event person_id from eksdata ;009
;009 declare	gEncounterID		= i4		;* Event encounter_id from eksdata
declare	gEncounterID		= f8		;* Event encounter_id from eksdata ;009
declare gClinicalEventID = f8   ;* Incoming CLINICAL_EVENT id from linked template
declare gPrimarySurgID = f8     ;* prsnl_id of the discovered primary surgeon.

declare eksce_id = f8 with noconstant(0.00)	;008
;---------------------------------------------------------------------------
#begin_main
;---------------------------------------------------------------------------
	call EkmInitialize(0)

	call WriteMessage(NOP, ConCat("The most recent result of EVENT_SET_NAME has a result status STATUS"))
	call WriteMessage(NOP, ConCat("     and is NORMALCY on the same encounter as OPT_LINK"))
	call WriteMessage(NOP, ConCat("     within the last OPT_TIME_NUM OPT_TIME_UNITS"))


	;* Load external variables into lists
	call GetEventSetNames(TRUE)
	call GetResultStatus(TRUE)
	call GetNormalcyCodes(TRUE)
	call GetCollectionCutOff (0)
	set	linkTo = GetParentLink(FALSE)

	;* If variables loaded
	if (not gEkmError)

		;* Get person/encounter id's from link or even records
		call GetPersonID(linkTo)

		;* If person/encounter id's were obtained
		if ((gEkmResult) and (not gEkmError))
			;* Get persons last results into ClinicalResults
			if (GetLastResults(gPersonID, gEncounterID) = 0)
				;* If no results were found then the rule was false
				set gEkmResult = FALSE
				call WriteExitMessage(
					ConCat("No results were found matching EVENT_SET_NAME(s) ",
							"with STATUS and NORMALCY since ",
							Format(collectionCutOff, ";;q"),"on encounter=",cnvtstring(gEncounterID),
							" and person=",cnvtstring(gPersonID)))
			else
				;* Results were found, write to output area
				call FormatEksData(0)

				call WriteExitMessage(ConCat(Trim(Format(ClinicalResults->matches, "####;p ")),
					" results were found matching EVENT_SET_NAME(s) with STATUS ",
					"and NORMALCY since ", Format(collectionCutOff, ";;q")))
			endif
		endif
	else
		call WriteExitMessage("Invalid or missing parameters, check:EVENT_SET_NAME, STATUS, NORMALCY entries. See log file.")
	endif



#exit_main

	if (gEkmResult in (TRUE, FALSE))
		set retVal = gEkmResult * 100
	else
		set retVal = gEkmResult
	endif


;---------------------------------------------------------------------------
#end_main
;---------------------------------------------------------------------------


;---------------------------------------------------------------------------
; Input		cePersonID equal to the person.person_id to retrieve.
;			ceEncntrID equal to the persons encounter or zero(0) for all
; Output	ClinicalResults record.
; Returns	Total number of records, Zero(0) if none were found.
;---------------------------------------------------------------------------
subroutine	GetLastResults(cePersonID, ceEncntrID)

	if (ceEncntrID = 0.0)
		set ecmMsg = " for all encounters "
	else
		set ecmMsg = ConCat(" and an encntr_id of ", Format(ceEncntrID, "###########.##"))
	endif

	call WriteMessage(NOP, ConCat("Searching last results for person_id of ",
			Trim(Format(cePersonID, "#############.##;l")),
			" ", ecmMsg, "."))

	set ClinicalResults->cnt = 0

	;007 begin
	declare ptPlaceHolder = f8 with protect, noconstant(0.00)
	set stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1, ptPlaceHolder)
	call echo(concat("ptPlaceHolder: ", build(ptPlaceHolder)))

	;008 set i = 0
	;008 set j = 0
	;008 set k = 0
	declare i = i4 with protect, noconstant(0) ;008
	declare j = i4 with protect, noconstant(0) ;008
	declare k = i4 with protect, noconstant(0) ;008

 	;008 begin
	declare iCnt = i4 with protect, noconstant(0)
	declare tmpEventEndDtTm = dq8 with protect, noconstant(0)
	call echo(concat("---- bAnyEventSet: ", build(bAnyEventSet), "  linkTo: ", build(linkTo)))
	call echo(concat("---- bAnyResultStatus: ", build(bAnyResultStatus), "  bAnyNormalcy: ", build(bAnyNormalcy)))

	if (bAnyEventSet = False)
		select
			if (linkTo = 0)
				from v500_event_set_explode ex, clinical_event ce
				plan ex where expand(iCnt, 1, EVENT_SET_NAMElist->cnt, ex.event_set_cd, cnvtreal(EVENT_SET_NAMElist->qual[iCnt].value))
				join ce where ce.person_id = cePersonID
					and ce.event_cd = ex.event_cd
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
					and ce.view_level > 0
				   	and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
			else
				from v500_event_set_explode ex, clinical_event ce
				plan ex where expand(iCnt, 1, EVENT_SET_NAMElist->cnt, ex.event_set_cd, cnvtreal(EVENT_SET_NAMElist->qual[iCnt].value))
				join ce where ce.person_id = cePersonID
					and ce.event_cd = ex.event_cd
					and ce.encntr_id = ceEncntrID
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
			    	and ce.view_level > 0
				    and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
			endif
		distinct into "nl:"
			ce.event_tag,
			event_name = uar_get_code_display(ce.event_cd),
			res_stat = uar_get_code_display(ce.result_status_cd)
		;order ex.event_set_cd, ce.event_end_dt_tm desc
		order ce.event_cd, ce.event_end_dt_tm desc;, ce.clinical_event_id desc
		head ce.event_cd
			tmpEventEndDtTm = 0
		head ce.event_end_dt_tm
		    if (ce.event_end_dt_tm > tmpEventEndDtTm)
				tmpEventEndDtTm = ce.event_end_dt_tm
 			endif
 		;head ex.event_set_cd
 		;	tmpEventEndDtTm = 0
 		;head ce.event_cd
 		;	if (ce.event_end_dt_tm > tmpEventEndDtTm )
 		;		tmpEventEndDtTm = ce.event_end_dt_tm
 		;	endif
 		head report
			curRes = 0
			stat = AlterList(ClinicalResults->Results, 100)
		detail
			call echo(concat("bAnyEventSet = False --- ce.clinical_event_id: ", build(ce.clinical_event_id),
				" ce.result_status_cd: ", build(ce.result_status_cd),
				" ce.normalcy_cd: ", build(ce.normalcy_cd),
				" ex.event_set_cd: ", build(ex.event_set_cd)))

			if (tmpEventEndDtTm = ce.event_end_dt_tm)
				if (bAnyResultStatus = FALSE)
					if (bAnyNormalcy = FALSE)
						i=1
						while (i<=STATUSList->cnt)
							j=1
							while (j<=NORMALCYList->cnt)
								if (ce.normalcy_cd = cnvtreal(NORMALCYList->qual[j].value) and
									ce.result_status_cd = cnvtreal(STATUSList->qual[i].value) )

									curRes = curRes + 1
									if (mod(curRes,10) = 1 and curRes > 100)
										stat = AlterList(ClinicalResults->Results, curRes + 9)
									endif
									ClinicalResults->cnt = curRes
									ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
									ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
									ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
									ClinicalResults->Results[curRes].event_cd = ce.event_cd
									ClinicalResults->Results[curRes].event_set_cd = ex.event_set_cd
									ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
									ClinicalResults->Results[curRes].result_val = ce.result_val
									ClinicalResults->Results[curRes].report_flag = TRUE
									ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
								endif
								j=j+1
							endwhile
							i=i+1
						endwhile
					else ; bAnyNormalcy =TRUE
						i=1
						while (i<=STATUSList->cnt)
							if (ce.result_status_cd = cnvtreal(STATUSList->qual[i].value) )
								curRes = curRes + 1
								if (mod(curRes,10) = 1 and curRes > 100)
									stat = AlterList(ClinicalResults->Results, curRes + 9)
								endif
								ClinicalResults->cnt = curRes
								ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
								ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
								ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
								ClinicalResults->Results[curRes].event_cd = ce.event_cd
								ClinicalResults->Results[curRes].event_set_cd = ex.event_set_cd
								ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
								ClinicalResults->Results[curRes].result_val = ce.result_val
								ClinicalResults->Results[curRes].report_flag = TRUE
								ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
							endif
							i=i+1
						endwhile
					endif
				else ;bAnyResultStatus = TURE)
					if (bAnyNormalcy = FALSE)
						j=1
						while (j<=NORMALCYList->cnt)
							if (ce.normalcy_cd = cnvtreal(NORMALCYList->qual[j].value) )
								curRes = curRes + 1
								if (mod(curRes,10) = 1 and curRes > 100)
									stat = AlterList(ClinicalResults->Results, curRes + 9)
								endif
								ClinicalResults->cnt = curRes
								ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
								ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
								ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
								ClinicalResults->Results[curRes].event_cd = ce.event_cd
								ClinicalResults->Results[curRes].event_set_cd = ex.event_set_cd
								ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
								ClinicalResults->Results[curRes].result_val = ce.result_val
								ClinicalResults->Results[curRes].report_flag = TRUE
								ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
							endif
							j = j + 1
						endwhile
					else ; bAnyNormalcy = TURE
						curRes = curRes + 1
						if (mod(curRes,10) = 1 and curRes > 100)
							stat = AlterList(ClinicalResults->Results, curRes + 9)
						endif
						ClinicalResults->cnt = curRes
						ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
						ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
						ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
						ClinicalResults->Results[curRes].event_cd = ce.event_cd
						ClinicalResults->Results[curRes].event_set_cd = ex.event_set_cd
						ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
						ClinicalResults->Results[curRes].result_val = ce.result_val
						ClinicalResults->Results[curRes].report_flag = TRUE
						ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
					endif ; bAnyNormalcy
				endif
			endif ; tmpEventEndDtTm = ce.event_end_dt_tm
		foot report
			ClinicalResults->cnt = curRes
			stat = alterlist(ClinicalResults->Results,ClinicalResults->cnt)
			if (ClinicalResults->cnt=1)
				eksce_id = ClinicalResults->Results[1].clinical_event_id
			endif
		with NoCounter,
		orahintcbo("USE_NL(ex ce) index(ce XIE9CLINICAL_EVENT) index(ex XIE2V500_EVENT_SET_EXPLODE)")
	else ;if (bAnyEventSet = True)
		select
			if (linkTo = 0)
				from clinical_event ce
				plan ce where ce.person_id = cePersonID
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
					and ce.view_level > 0
				   	and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
			else
				from clinical_event ce
				plan ce where ce.person_id = cePersonID
					and ce.encntr_id = ceEncntrID
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
			    	and ce.view_level > 0
				    and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
			endif
		distinct into "nl:"
			ce.event_tag,
			event_name = uar_get_code_display(ce.event_cd),
			res_stat = uar_get_code_display(ce.result_status_cd)
		order ce.event_cd, ce.event_end_dt_tm desc, ce.clinical_event_id desc
		head ce.event_cd
			tmpEventEndDtTm = 0
		head ce.event_end_dt_tm
		    if (ce.event_end_dt_tm > tmpEventEndDtTm)
				tmpEventEndDtTm = ce.event_end_dt_tm
 			endif
 		head report
			curRes = 0
			stat = AlterList(ClinicalResults->Results, 100)
		detail
			call echo(concat("bAnyEventSet = TRUE --- ce.clinical_event_id: ", build(ce.clinical_event_id),
				" ce.result_status_cd: ", build(ce.result_status_cd),
				" ce.normalcy_cd: ", build(ce.normalcy_cd),
				" ex.event_cd: ", build(ce.event_cd)))
			if (tmpEventEndDtTm = ce.event_end_dt_tm)
				call echo(concat("****** ce.event_end_dt_tm: ", build(format(ce.event_end_dt_tm,";;q"))))
				if (bAnyResultStatus = FALSE)
					if (bAnyNormalcy = FALSE)
						i=1
						while (i <= STATUSList->cnt)
							j=1
							while (j <= NORMALCYList->cnt)
								if (ce.normalcy_cd = cnvtreal(NORMALCYList->qual[j].value) and
									ce.result_status_cd = cnvtreal(STATUSList->qual[i].value) )

									curRes = curRes + 1
									if (mod(curRes,10) = 1 and curRes > 100)
										stat = AlterList(ClinicalResults->Results, curRes + 9)
									endif
									ClinicalResults->cnt = curRes
									ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
									ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
									ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
									ClinicalResults->Results[curRes].event_cd = ce.event_cd
									ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
									ClinicalResults->Results[curRes].result_val = ce.result_val
									ClinicalResults->Results[curRes].report_flag = TRUE
									ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
								endif
								j = j + 1
							endwhile
							i = i + 1
						endwhile
					else ; bAnyNormalcy =TRUE
						i=1
						while (i <= STATUSList->cnt)
							if (ce.result_status_cd = cnvtreal(STATUSList->qual[i].value) )
								curRes = curRes + 1
								if (mod(curRes,10) = 1 and curRes > 100)
									stat = AlterList(ClinicalResults->Results, curRes + 9)
								endif
								ClinicalResults->cnt = curRes
								ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
								ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
								ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
								ClinicalResults->Results[curRes].event_cd = ce.event_cd
								ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
								ClinicalResults->Results[curRes].result_val = ce.result_val
								ClinicalResults->Results[curRes].report_flag = TRUE
								ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
							endif
							i = i + 1
						endwhile
					endif
				else ;bAnyResultStatus = TURE)
					if (bAnyNormalcy = FALSE)
						j=1
						while (j <= NORMALCYList->cnt)
							if (ce.normalcy_cd = cnvtreal(NORMALCYList->qual[j].value) )
								curRes = curRes + 1
								if (mod(curRes,10) = 1 and curRes > 100)
									stat = AlterList(ClinicalResults->Results, curRes + 9)
								endif
								ClinicalResults->cnt = curRes
								ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
								ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
								ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
								ClinicalResults->Results[curRes].event_cd = ce.event_cd
								ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
								ClinicalResults->Results[curRes].result_val = ce.result_val
								ClinicalResults->Results[curRes].report_flag = TRUE
								ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
							endif
							j = j + 1
						endwhile
					else ; bAnyNormalcy = TURE
						curRes = curRes + 1
						if (mod(curRes,10) = 1 and curRes > 100)
							stat = AlterList(ClinicalResults->Results, curRes + 9)
						endif
						ClinicalResults->cnt = curRes
						ClinicalResults->Results[curRes].clinical_event_id = ce.clinical_event_id
						ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
						ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
						ClinicalResults->Results[curRes].event_cd = ce.event_cd
						ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
						ClinicalResults->Results[curRes].result_val = ce.result_val
						ClinicalResults->Results[curRes].report_flag = TRUE
						ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
					endif ; bAnyNormalcy
				endif
			endif ; tmpEventEndDtTm = ce.event_end_dt_tm
		foot report
			ClinicalResults->cnt = curRes
			stat = alterlist(ClinicalResults->Results,ClinicalResults->cnt)
			if (ClinicalResults->cnt=1)
				eksce_id = ClinicalResults->Results[1].clinical_event_id
			endif
		with NoCounter
	endif ;end of if (bAnyEventSet = False)
  	;call echorecord(ClinicalResults)
  	;call echo(concat("******* eksce_id: ", build(eksce_id)))
 	;008 end

 	/* 008 begin
	if (bAnyEventSet = False)
		select
			if (linkTo = 0)
				from v500_event_set_explode ex, clinical_event ce
				plan ex where expand(i, 1, EVENT_SET_NAMElist->cnt, ex.event_set_cd, cnvtreal(EVENT_SET_NAMElist->qual[i].value))
				join ce where ce.person_id = cePersonID
					and ce.event_cd = ex.event_cd
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
					and ce.view_level > 0
				   	and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
					and (
						(expand(j, 1, STATUSList->cnt, ce.result_status_cd, CnvtReal(STATUSList->qual[j].value))
							and bAnyResultStatus = FALSE)
						or bAnyResultStatus = TRUE)
					and (
						(expand(k, 1, NORMALCYList->cnt, ce.normalcy_cd, CnvtReal(NORMALCYList->qual[k].value))
							and bAnyNormalcy = FALSE)
						or bAnyNormalcy = TRUE)
			else
				from v500_event_set_explode ex, clinical_event ce
				plan ex where expand(i, 1, EVENT_SET_NAMElist->cnt, ex.event_set_cd, cnvtreal(EVENT_SET_NAMElist->qual[i].value))
				join ce where ce.person_id = cePersonID
					and ce.event_cd = ex.event_cd
					and ce.encntr_id+0 = ceEncntrID
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
			    	and ce.view_level > 0
				    and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
					and (
						(expand(j, 1, STATUSList->cnt, ce.result_status_cd, CnvtReal(STATUSList->qual[j].value))
							and bAnyResultStatus = FALSE)
						or bAnyResultStatus = TRUE)
					and (
						(expand(k, 1, NORMALCYList->cnt, ce.normalcy_cd, CnvtReal(NORMALCYList->qual[k].value))
							and bAnyNormalcy = FALSE)
						or bAnyNormalcy = TRUE)
			endif
		distinct into "nl:"
			ce.event_tag,
			event_name = uar_get_code_display(ce.event_cd),
			res_stat = uar_get_code_display(ce.result_status_cd)
		order ce.event_cd, ce.event_end_dt_tm desc

		detail
			call echo(concat("ce.clinical_event_id: ", build(ce.clinical_event_id),
				"ce.result_status_cd: ", build(ce.result_status_cd)))

			sz = Size(ClinicalResults->Results,5) + 1
			stat = AlterList(ClinicalResults->Results, sz)
 			curRes = ClinicalResults->cnt + 1
			ClinicalResults->cnt = curRes
			ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
			ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
			ClinicalResults->Results[curRes].event_cd = ce.event_cd
			ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
			ClinicalResults->Results[curRes].result_val = ce.result_val
			ClinicalResults->Results[curRes].report_flag = TRUE
			ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
		with NoCounter

	else ;if (bAnyEventSet = True)

		select
			if (linkTo = 0)
				from clinical_event ce
				plan ce where ce.person_id = cePersonID
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
					and ce.view_level > 0
				   	and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
					and (
						(expand(j, 1, STATUSList->cnt, ce.result_status_cd, CnvtReal(STATUSList->qual[j].value))
							and bAnyResultStatus = FALSE)
						or bAnyResultStatus = TRUE)
					and (
						(expand(k, 1, NORMALCYList->cnt, ce.normalcy_cd, CnvtReal(NORMALCYList->qual[k].value))
							and bAnyNormalcy = FALSE)
						or bAnyNormalcy = TRUE)
			else
				from clinical_event ce
				plan ce where ce.person_id = cePersonID
					and ce.encntr_id+0 = ceEncntrID
					and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
					and ce.event_end_dt_tm between CnvtDateTime(collectionCutOff) and CnvtDateTime(CurDate, CurTime3)
			    	and ce.view_level > 0
				    and ce.publish_flag = 1
					and ce.event_class_cd != ptPlaceHolder
					and (
						(expand(j, 1, STATUSList->cnt, ce.result_status_cd, CnvtReal(STATUSList->qual[j].value))
							and bAnyResultStatus = FALSE)
						or bAnyResultStatus = TRUE)
					and (
						(expand(k, 1, NORMALCYList->cnt, ce.normalcy_cd, CnvtReal(NORMALCYList->qual[k].value))
							and bAnyNormalcy = FALSE)
						or bAnyNormalcy = TRUE)
			endif
		distinct into "nl:"
			ce.event_tag,
			event_name = uar_get_code_display(ce.event_cd),
			res_stat = uar_get_code_display(ce.result_status_cd)
		order ce.event_end_dt_tm desc, ce.updt_dt_tm desc, ce.clinical_event_id
		detail
			call echo(concat("ce.clinical_event_id: ", build(ce.clinical_event_id),
				"ce.result_status_cd: ", build(ce.result_status_cd)))

			sz = Size(ClinicalResults->Results,5) + 1
			stat = AlterList(ClinicalResults->Results, sz)

			curRes = ClinicalResults->cnt + 1
			ClinicalResults->cnt = curRes
			ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
			ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
			ClinicalResults->Results[curRes].event_cd = ce.event_cd
			ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
			ClinicalResults->Results[curRes].result_val = ce.result_val
 			ClinicalResults->Results[curRes].report_flag = TRUE
			ClinicalResults->Results[curRes].event_set_name = uar_get_code_display(ce.event_cd)
		with NoCounter
	endif ;end of if (bAnyEventSet = False)
	008 */
	;007 end
	/*007 begin
	;* For each event in clinical_event do
	select  into "NL:"
			ce.event_cd,
			ce.normalcy_cd,
			ce.result_status_cd,
			ce.event_end_dt_tm ";;q",
			ce.result_val

	from	clinical_event	ce

	;* Get patients results, eliminating corrected results.
	where	ce.person_id	= cePersonID
	and	(	ce.encntr_id	= ceEncntrID
	or		ceEncntrID		= 0.0)
	and		ce.view_level	= CE_VIEW_UNRESTRICTED
	and		ce.valid_until_dt_tm = CnvtDateTime("31-dec-2100 00:00:00")
	and		ce.event_end_dt_tm between CnvtDateTime(collectionCutOff)
								   and CnvtDateTime(CurDate, CurTime3)
	order by	ce.event_cd,
				ce.event_end_dt_tm desc

	head report
			capture = FALSE

	head	ce.event_cd

			capture = TRUE
	detail
			;* Set LastResult = most recent result collected.
			if (capture)
				sz = Size(ClinicalResults->Results,5) + 1
				stat = AlterList(ClinicalResults->Results, sz)

				;* Add LastResult to Output list
				curRes = ClinicalResults->cnt + 1
				ClinicalResults->cnt = curRes

				ClinicalResults->Results[curRes].report_flag = FALSE
				ClinicalResults->Results[curRes].normalcy_cd = ce.normalcy_cd
				ClinicalResults->Results[curRes].result_status_cd = ce.result_status_cd
				ClinicalResults->Results[curRes].event_cd = ce.event_cd
				ClinicalResults->Results[curRes].collection_dt_tm = ce.event_end_dt_tm
				ClinicalResults->Results[curRes].result_val = ce.result_val

				capture = FALSE

			endif

	with NoCounter

	call WriteMessage(NOP, "Checking last results with criteria.")

	;* For each result found in clinical_event do
	set 	ClinicalResults->matches = 0

	select  into "NL:"
			*
	from	(dummyt			d0 with seq = Value(ClinicalResults->cnt)),
			(dummyt			d1 with seq = Value (STATUSList->cnt)),
			(dummyt			d2 with seq = Value (NORMALCYList->cnt)),
			(dummyt			d3 with seq = Value (EVENT_SET_NAMElIST->cnt)),
			v500_event_set_explode	exp
	;		v500_event_set_code		esCD,
	;004	code_value				eventName

	plan	d0

	;* If result status is in RESULT_LIST
	join d1			where	ClinicalResults->Results[d0.seq].result_status_cd
								= CnvtReal(STATUSList->qual[d1.seq].value)
					or		bAnyResultStatus = TRUE

	;* If result normalcy code is in NORMALCYList
	join d2			where	ClinicalResults->Results[d0.seq].normalcy_cd
							= CnvtReal (NORMALCYList->qual[d2.seq].value)
					or		bAnyNormalcy	= TRUE

	;* If LastResult is in EVENT_SET_LIST
	join exp		where	ClinicalResults->Results[d0.seq].event_cd
								= exp.event_cd

	;join esCD		where	esCD.event_set_cd= exp.event_set_cd
	;

	;join d3			where	Trim(EVENT_SET_NAMEList->qual[d3.seq].display) = esCD.event_set_name
	;				or		bAnyEventSet = TRUE

	join d3			where	cnvtreal(EVENT_SET_NAMEList->qual[d3.seq].value) = exp.event_set_cd
					or		bAnyEventSet = TRUE

	;004 join eventName	where	eventName.code_value = ClinicalResults->Results[d0.seq].event_cd

	detail
		ClinicalResults->Results[d0.seq].report_flag = TRUE
		;004 ClinicalResults->Results[d0.seq].event_set_name = eventName.display
		ClinicalResults->Results[d0.seq].event_set_name =
				uar_get_code_display(ClinicalResults->Results[d0.seq].event_cd)

	with NoCounter
	;007 end */

	for (x = 1 to ClinicalResults->cnt)
		if (ClinicalResults->Results[x].report_flag = TRUE)
			set ClinicalResults->matches = 	ClinicalResults->matches + 1
		endif
	endfor

	call WriteMessage (NOP, ConCat("Clinical Event table had ",
		Format(ClinicalResults->matches, "######"), " matching records."))

	return (ClinicalResults->matches)
end /* GetResults */

;---------------------------------------------------------------------------
; Write results to eksdata->data field.  Final format of message is
;		mm/dd/yyyy event_set = result_val  {, event_set = result_val}
;---------------------------------------------------------------------------
subroutine	FormatEksData(_Arg1206990827) ;* Ignore argument

%i CCLSOURCE:eks_set_eksdata.inc

	record msgText ( 1 Text = vc )

	;* For each result in ClinicalResults do
	select into "nl:"
		result = res.seq,
		collected = ClinicalResults->Results[res.seq].collection_dt_tm

	from (dummyt	res with seq = value(ClinicalResults->cnt))

	where	ClinicalResults->Results[res.seq].report_flag = TRUE

	order by	collected desc

	head	report
		fmtColStr = FillString(50, "")
		fmtStr = FillString(100, "")
		NEWLINE = ConCat (Char(10), Char(13))
		curLen = 0

	head	collected
		fmtColStr = ConCat(
			Format(ClinicalResults->Results[result].collection_dt_tm,
			"mm/dd/yyyy hh:mm;;d"), " ")

		startOfLine = TRUE;
		curLen = 0
	detail
		fmtStr = ConCat(Trim(fmtColStr), " ",
			Trim(ClinicalResults->Results[result].event_set_name), " = ",
			Trim(ClinicalResults->Results[result].result_val))

		szData = Size(Trim(fmtStr))

		if (not startOfLine)
			msgText->Text = ConCat(msgText->Text, ", ")
			curLen = curLen + 2

			if ((curLen + szData) > MAX_DATA_LEN)
				msgText->Text = ConCat(msgText->Text, NEWLINE)
				curLen = 0
			endif
		endif

		curLen = curLen + szData
		msgText->Text = ConCat(msgText->Text, fmtStr)

		fmtColStr = ""
		startOfLine = FALSE

	foot collected
		msgText->Text = ConCat(msgText->Text, NEWLINE)
		curLen = 0

	with NoCounter;


	set eksdata->tqual[tCurIndex].qual[curIndex].cnt = 1
	set stat = AlterList(eksdata->tqual[tCurIndex].qual[curIndex].data, 1)
	set eksdata->tqual[tCurIndex].qual[curIndex].data[1].misc = msgText->Text

	call WriteMessage(NOP, ConCat("Results returned to EksData->data <",
			eksdata->tqual[tCurIndex].qual[curIndex].data[1].misc,">"))

end /* FormatMessage */
;----------------------------------------------------------------------------
; GetEventSetNames	- Validate & parse event set string into list.
; Input			string EVENT_SET_NAME
; Output			list	 EVENT_SET_NAMEList
; Returns			TRUE if EVENT_SET_NAME could be parse with 1 or
;				more items
; Assumes EVENT_SET_NAMEList is defined as a global list record type.
;----------------------------------------------------------------------------
subroutine GetEventSetNames(eventSetRequired)

	;* Check EVENT_SET_NAME was defined.
	if ((Validate(EVENT_SET_NAME, "Z") = "Z")
	and (Validate(EVENT_SET_NAME, "Y") = "Y"))
		;* EVENT_SET_NAME wasn't defined so fail the rule.
		call WriteMessage(FAILED,
			ConCat("External variable 'EVENT_SET_NAME' is not defined by template ",
				tname))
	else	;* EVENT_SET_NAME does exist so parse components into EVENT_SET_NAMEList.
		set orig_param = EVENT_SET_NAME
		execute eks_t_parse_list with replace (reply, EVENT_SET_NAMEList)
		free set orig_param

		;* If no event set were parsed then exit.
		if (EVENT_SET_NAMEList->cnt = 0)
			if (eventSetRequired)
				call WriteMessage(FAILED, "EVENT_SET_NAME had no values to parse.")
			else
				call WriteMessage(NOP, "EVENT_SET_NAME had no values to parse.")
			endif
			set gEkmResult = FALSE
		else
			; mod 003
			; look for event set code values if event set names are passed from the template

			select into "nl:"
				vesc.event_set_cd
			from v500_event_set_code vesc,
				(dummyt d1 with seq = value(EVENT_SET_NAMEList->cnt))
			plan d1 where trim(EVENT_SET_NAMElist->qual[d1.seq].value, 3) =
          		trim(EVENT_SET_NAMElist->qual[d1.seq].display, 3)
			join vesc where vesc.event_set_name = EVENT_SET_NAMElist->qual[d1.seq].display
			detail
				EVENT_SET_NAMElist->qual[d1.seq].value =
;006						trim(cnvtstring(vesc.event_set_cd))
						trim(cnvtstring(vesc.event_set_cd,25,1))	;006
			with nocounter

			; end of mod 003
		endif
	endif

	;* Scan for "Any Event Set" passed as a parameter
	for (curSet = 1 to EVENT_SET_NAMEList->cnt)
		if (CnvtUpper(EVENT_SET_NAMEList->qual[curSet].display) = "*ANY EVENT SET NAME" or
			CnvtUpper(EVENT_SET_NAMEList->qual[curSet].display) = "*ANY_EVENT_SET_NAME")
			set bAnyEventSet = TRUE
			call WriteMessage(NOP, "All Event Sets will be selected")
		endif
	endfor


	return (gEkmResult)
end /* GetEventSets */

;----------------------------------------------------------------------------
; GetResultStatus	- Validate & parse STATUS string into list.
; Input			string RESULT_STATUS
; Output			list	 RESULT_STATUSList
; Returns			TRUE if RESULT_STATUS could be parse with 1 or
;				more items
; Assumes RESULT_STATUSList is defined as a global list record type.
;----------------------------------------------------------------------------
subroutine GetResultStatus(resultStatusRequired)

	;* Check Result Status code was defined.
	if ((Validate(STATUS, "Z") = "Z")
	and (Validate(STATUS, "Y") = "Y"))
		;* STATUS wasn't defined so fail the rule.
		call WriteMessage(FAILED,
			ConCat("External variable 'STATUS' is not defined by template ",
				tname))
	else	;* STATUS does exist so parse components into STATUSList.
		set orig_param = STATUS
		execute eks_t_parse_list with replace (reply, STATUSList)
		free set orig_param

		;* If no status set were parsed then exit.
		if (STATUSList->cnt = 0)
			if (resultStatusRequired = TRUE)
				call WriteMessage(FAILED, "STATUS had no values to parse.")
			else
				call WriteMessage(NOP, "STATUS had no values to parse.")

			endif
			set gEkmResult = FALSE
		endif
	endif

	;* Scan for "Any Result Status" passed as a parameter
	for (curStatus = 1 to STATUSList->cnt)
		if (CnvtReal(STATUSList->qual[curStatus].value) = 0.00)
			set bAnyResultStatus = TRUE
			call WriteMessage(NOP, "All RESULT STATUS codes will be selected")
		endif
	endfor

	return (gEkmResult)
end /* GetResultStatus */

;----------------------------------------------------------------------------
; GetNormalcyCodes	- Validate & parse NORMALCY string into list.
; Input			string NORMALCY
; Output			list	 NORMALCYList
; Returns			TRUE if NORMALCY could be parse with 1 or
;				more items
; Assumes NORMALCYList is defined as a global list record type.
;----------------------------------------------------------------------------
subroutine GetNormalcyCodes(normalcyRequired)

	;* Check normalcy  was defined.
	if ((Validate(NORMALCY, "Z") = "Z")
	and (Validate(NORMALCY, "Y") = "Y"))
		;* NORMALCY wasn't defined so fail the rule.
		call WriteMessage(FAILED,
			ConCat("External variable 'NORMALCY' is not defined by template ",
				tname))
	else	;* NORMALCY does exist so parse components into NORMALCYList.
		set orig_param = NORMALCY
		execute eks_t_parse_list with replace (reply, NORMALCYList)
		free set orig_param

		;* If no normalcy codes were parse then exit.
		if (NORMALCYList->cnt = 0)
			if (normalcyRequired = TRUE)
				call WriteMessage(FAILED, "NORMALCY had no values to parse.")
			else
				call WriteMessage(NOP, "NORMALCY had no values to parse.")

			endif
			set gEkmResult = FALSE
		endif
	endif

	;* Scan for "Any Normalcy" passed as a parameter
	for (curNormal = 1 to NORMALCYList->cnt)
		if (CnvtReal (NORMALCYList->qual[curNormal].value) = 0.00)
			set bAnyNormalcy = TRUE
			call WriteMessage(NOP, "All NORMALCY codes will be selected. ")
		endif
	endfor

	return (gEkmResult)
end /* GetResultStatus */


;----------------------------------------------------------------------------
; Get the oldest collection date & time that will be evaluated.
; The collection date & time is optional.  If not provided then the default
; date of 01-JAN-1900 00:00:00 is set.
;
; Returns	Since date and time variable could not be passed via a return
; the global variable "collectionCutOff" is set directly.
;----------------------------------------------------------------------------
subroutine	GetCollectionCutOff (_Arg120599) ;*Ignor parameter

	set	timeInterval = 0
;005	set	timeUnit =""
	if ((Validate(OPT_TIME_NUM, "Z") = "Z") and (Validate(OPT_TIME_NUM, "N")="N"))
		call WriteMessage(NOP, "OPT_TIME_NUM not defined.  Using default.")
	else
		set timeInterval = CnvtInt(OPT_TIME_NUM)
	endif

	if ((Validate(OPT_TIME_UNIT, "Z") = "Z") and (Validate(OPT_TIME_UNIT, "N")="N"))
		call WriteMessage(NOP, "OPT_TIME_UNIT not defined.  Using default.")
	else
		case (CnvtUpper(OPT_TIME_UNIT))
		;005 of	"MINUTES"		: set timeUnit = "M"
		of 	"MINUTES"		: set timeUnit = "MIN"	;005
		of 	"HOURS"			: set timeUnit = "H"
		of 	"DAYS"			: set timeUnit = "D"
		endcase
	endif

	if ((timeInterval > 0) and (timeUnit > ""))
		set interval = Build (timeInterval, timeUnit)
		call WriteMessage (NOP, ConCat("Using time interval ", interval))

		set collectionCutOff = CnvtLookBehind(interval, CnvtDateTime(CurDate, CurTime3))
	else
		set collectionCutOff = CnvtDateTime("01-JAN-1900 00:00:00")
	endif

	call WriteMessage(NOP, ConCat("Only results collected since ",
					Format(CollectionCutOff, ";;q"),
					" will be selected."))


end /* GetCutOff */

;----------------------------------------------------------------------------
; Check the OPT_LINK.  If OPT_LINK has a valid link value of opt_link is
; returned.  If OPT_LINK is not valid a value of zero is returned.
;
; Mod 002	Correction to the linkTo variable, making it local to the subroutine
;           Correction to evaluate the OPT_LINK as an integer instead of linkTo.
;			Return the local linkTo value.
;----------------------------------------------------------------------------
subroutine GetParentLink (linkRequired)

	;Mod 002  set linkTo = 0
	declare linkTo = i2 with noConstant(0), protected

	if ((Validate(OPT_LINK, "Z") = "Z") and (Validate(OPT_LINK, "Y")="Y"))
		call WriteMessage (NOP, "OPT_LINK not defined.  Using default")
		;* Find person_id
		;mod 002 elseif (linkTo > 0)
	elseif (CnvtInt(OPT_LINK) > 0)
		;* Find person_id using link
		call WriteMessage(NOP, ConCat("OPT_LINK to eksdata[", OPT_LINK, "]"))
		set linkTo = CnvtInt(OPT_LINK)
	else
		;* Use person_id from event
		call WriteMessage(NOP, "No link specified.  Using event person id.")
	endif

	;Mod 002 return link value.
	return (linkTo)

end /* GetParentLink */

;----------------------------------------------------------------------------
; Get the person & encounter id's.
; If the link is specified the encounter_id is required.  If no link is
; specified the encounter_id is set to 0 (all encounters).
;----------------------------------------------------------------------------
subroutine	GetPersonID (optLinkTo)

	;009 set gPersonID = 0
	set gPersonID = 0.00 ;009
	;009 set gEncounterID = 0
	set gEncounterID = 0.00 ;009
  set gClinicalEventID = 0.00 ;011

	if (optLinkTo between 1 and Size(eksdata->tqual[tinx].qual,5))
		;* Link to parent event
		set gPersonID = eksdata->tqual[logic_inx]->qual[optLinkTo].person_id
		set	gEncounterID = eksdata->tqual[logic_inx]->qual[optLinkTo].encntr_id
    set gClinicalEventID  =cnvtreal(eksdata->tqual[logic_inx]->qual[optLinkTo]->data[2].misc) ;011

    ;start 011
    if (gClinicalEventID = 0)
      call WriteMessage(FALSE,
        ConCat("Linked Clinical Event Required.  Found person_id = ",
        ;009 Format(gPersonID, "########.##"), " and encntr_id = ",
        Format(gPersonID, "###########.##"), " and encntr_id = ", ;009
        ;009 Format(gEncounterID, "#########.##")))
        Format(gEncounterID, "###########.##"))) ;009
    endif
    ;end 011

		if ((gPersonID = 0) or (gEncounterID = 0))
			;* Attempt to find the person/encounter using order_id
			if (eksdata->tqual[logic_inx]->qual[optLinkTo].order_id != 0)
				set gPersonID = FindPerson(gPersonID,
								event->qual[eks_common->event_repeat_index].order_id,
								gEncounterID)

				if ((gPersonID = 0) or (gEncounterID = 0))
					call WriteMessage(FALSE,
						ConCat("Person id and encounter id is required.  Found person_id = ",
							;009 Format(gPersonID, "########.##"), " and encntr_id = ",
							Format(gPersonID, "###########.##"), " and encntr_id = ", ;009
							;009 Format(gEncounterID, "#########.##")))
							Format(gEncounterID, "###########.##"))) ;009
				endif
			endif
		endif

	else
		;* use current event search all encounters
		set gPersonID = event->qual[eks_common->event_repeat_index].person_id

		;* If no person was defined
		if (gPersonID = 0)
			;* Attempt to find person_id using order_id
			set gPersonID = FindPerson(gPersonID,
								event->qual[eks_common->event_repeat_index].order_id,
								gEncounterID)

			if (gPersonID = 0)
				call WriteMessage(FALSE, "Person id is required but not found in event.")
			endif
		endif
		;* Force search to use all encounters
		set gEncounterID = 0 ;event->qual[eks_common->event_repeat_index].encntr_id
	endif

  select into "nl:"
	from
		 clinical_event ce
		,perioperative_document pd
		,surg_case_procedure scp
		,prsnl p

	plan ce
		where ce.clinical_event_id =    gClinicalEventID
	join pd
		where pd.periop_doc_id = cnvtreal(substring(1,9,ce.reference_nbr))
	join scp
		where scp.surg_case_id  = pd.surg_case_id
		and   scp.proc_complete_qty > 0
		and   scp.primary_proc_ind = 1
	join p
		where p.person_id = scp.primary_surgeon_id
	detail
		gPrimarySurgID = scp.primary_surgeon_id
	with nocounter

  if (gPrimarySurgID = 0)
      call WriteMessage(FALSE, "The Primary Surgeon on the record could not be found")
  endif

	return (gPersonID)

end /* GetPersonID */

;----------------------------------------------------------------------------
; Check 'cpPersonIDArg) for a value other than zero(0) or undefined (NULL).
; If 'cpPersonIDArg' was not valued, then attempt to find the person id from
; the order or encounter records.   If neither are possible then return FALSE.
; If a person was found return TRUE.
;
; Requires FindPersonByOrderID and FindPersonIDFromEncntr subroutines.
;----------------------------------------------------------------------------
subroutine FindPerson (cpPersonIDArg, cpOrderIDArg, cpEncntrIDArg)
        ;* Check if personID was passed from EKM.

	set srcPersonID = cpPersonIDArg

      if (srcPersonID in (0, NULL))
         ;* No personID was passed. Does order or encounter exist?

         call WriteMessage(NOP, "Warning cpPersonIDArg was 0.  Attempting to use order or encounter id's")

         if (not (cpOrderIDArg in (0, NULL)))
            ;* Order exist, get person from the order
			call WriteMessage(NOP, "Using order id to locate person id")
            set srcPersonID = FindPersonIDFromOrder(cpOrderIDArg)
         elseif (not (cpEncntrIDArg in (0, NULL)))
            ;* Encounter exist, get person from encounter
			call WriteMessage(NOP, "Using encounter id to locate person id")
            set srcPersonID = FindPersonIDFromEncntr(cpEncntrIDArg)
         else
            ;* no personID, orderID, or encntrID exist.
            set gEkmMessage = ConCat("No value existed for personID, ",
                            "orderID, or encntrID.  ",
                            "Can not retrieve person record")
            call WriteMessage (FAILED, "")
         endif

	   ;* Last check to make sure a person_id was obtained
         if (srcPersonID in (0, NULL))
             set gEkmMessage = "Unable to locate person, person_id = 0"
             call WriteMessage (FAILED, "")
         else
             call WriteMessage (TRUE, ConCat("    person_id is :",
                        	Format(srcPersonID, "############.##'p0")))
         endif
  	endif

      return (retVal)
end /* CheckPerson */

;---------------------------------------------------------------------------
; Search for the 'personID' using the ORDERS person_id field.
; Returns the person_id if found, zero(0) if not.
; Sets 'gEncounterID' = to the order encounter.
;---------------------------------------------------------------------------
subroutine FindPersonIDFromOrder (orderIDArg)
        ;009 set prsnID = 0
        set prsnID = 0.00 ;009

        select into "NL:"
                ord.person_id,
				ord.encntr_id
        from    orders  ord
        where   ord.order_id = orderIDArg
        detail  prsnID = ord.person_id
				gEncounterID = ord.encntr_id
        with    NoCounter;

        return (prsnID)

end /* GetPersonFromOrder */

;----------------------------------------------------------------------------
; Search for the 'personID' using the ENCOUNTER person_id field.
; Returns the person_id if found, zero(0) if not.
;----------------------------------------------------------------------------
subroutine FindPersonIDFromEncntr (encntrArg)
        ;009 set prsnID = 0
        set prsnID = 0.00 ;009
        select into "NL:"
                e.person_id
        from    encounter       e
        where   e.encntr_id = encntrArg
        detail  prsnID = e.person_id
        with    NoCounter;

        return (prsnID)
end /* GetPersonFromEncntr */


;---------------------------------------------------------------------------
; Initialize internal variables.
;---------------------------------------------------------------------------
subroutine EkmInitialize (_EkmArg0)

	set gEkmMessage = FillString (132, " ")
	set gEkmError = FALSE
	set gEkmMsgNo = 1
	set gEkmResult = TRUE

	set accessionID = event->qual[eks_common->event_repeat_index].accession_id
	set orderID = event->qual[eks_common->event_repeat_index].order_id
	set encntrID = event->qual[eks_common->event_repeat_index].encntr_id
	set	personID = event->qual[eks_common->event_repeat_index].person_id

end /* EkmInitInternals */


;---------------------------------------------------------------------------
; Write message to RTL log file.
;	wmEkmStatus		= TRUE, FALSE, FAILED
;	wmEkmLogMessage	= text
;---------------------------------------------------------------------------
subroutine	WriteMessage (wmEkmStatus, wmEkmLogMessage)

	set rtlMsg = FillString(132, "")

	if (RTL_WRITE_FMT) /* Write full formatted log message */
		set rtlMsg = ConCat (TName,
			Format (CurTime, "HH:MM:SS ;;m"), " ",
			Format(gEkmMsgNo, "###;rp0"),") ")

		set gEkmMsgNo = gEkmMsgNo + 1
	endif


	if (wmEkmStatus = FAILED)
		set rtlMsg=ConCat(rtlMsg, "ERROR IN TEMPLATE: ")
		set gEkmError = TRUE
		set gEkmResult = FALSE
	elseif (wmEkmStatus = FALSE)
		set gEkmResult = FALSE
	endif


	if (gEkmMessage > "")
		call Echo(ConCat(Trim(rtlMsg), gEkmMessage))
	endif

	if (wmEkmLogMessage > "")
		call Echo(ConCat(Trim(rtlMsg), wmEkmLogMessage))
	endif

	set gEkmMessage = FillString (132, "")

end /* WriteMessage */

;---------------------------------------------------------------------------
subroutine	WriteExitMessage (wemEkmMessage)
	declare	rtlMsg = c132

	set eksdata->tqual[tcurindex].qual[curindex].logging = concat(wemEkmMessage,
		" (", trim(format((curtime3-tempStartTime)/100.0, "######.##"),3), "s)")

	call Echo(concat(wemEkmMessage,
		" (", trim(format((curtime3-tempStartTime)/100.0, "######.##"),3), "s)"))

	call Echo (ConCat("**** ",Format(CurDate, "MM/DD/YYYY;;d"), " ",
                Format(CurTime, "hh:mm:ss;;m")))

 	set eksdata->tqual[tcurindex].qual[curindex].clinical_event_id = eksce_id ;008
	call Echo (ConCat("******** END OF ", Trim(tname), " ***********"))

end /* WriteExitMessage */

;---------------------------------------------------------------------------

end go /* end create program */

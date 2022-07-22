/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			   	Perioperative
	Source file name:	 	cov_powerplan_usage.prg
	Object name:		   	cov_powerplan_usage
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_powerplan_usage:dba go
create program cov_powerplan_usage:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Beginning Date and Time" = "SYSDATE"
	, "Ending Date and Time" = "SYSDATE"
	, "Form Selection" = 0
	, "New Provider" = 0
	;<<hidden>>"Search" = "" 

with OUTDEV, BEG_DT_TM, END_DT_TM, DCP_FORM_ID, NEW_PROVIDER


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 plan_cnt      = i4
	1 plan_qual[*]
	 2 pathway_catalog_id = f8
	1 cnt			= i4
	1 qual[*]
	 2 pathway_id	= f8
)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


SELECT

                FIN = SUBSTRING(1, 30, EA.ALIAS)

                ;, PATIENT_NAME = PS.NAME_FULL_FORMATTED

                , POWERPLAN_NAME = SUBSTRING(1,50,P.PW_GROUP_DESC)

                , ORDER_DATE_TIME = FORMAT( P.ORDER_DT_TM, "MM/DD/YY HH:MM:SS;;D")

               , ACTION_TYPE = UAR_GET_CODE_DISPLAY(PA.ACTION_TYPE_CD)

                , POWERPLAN_UPDATE_DT_TM = FORMAT (PA.action_dt_tm, "MM/DD/YY HH:MM:SS;;D")

                , POWERPLAN_STATUS = UAR_GET_CODE_DISPLAY (PA.pw_status_cd)

                , PP_ACTION_SEQ = PA.pw_action_seq

                , PERSONNEL_NAME = PN.NAME_FULL_FORMATTED

                ;, PATIENT_NAME = PATN.NAME_FULL_FORMATTED

                ;, POSITION = UAR_GET_CODE_DISPLAY(PN.POSITION_CD)

                ,FACILITY = UAR_GET_CODE_DESCRIPTION(ELH.LOC_FACILITY_CD)

                ;, NURSE_UNIT = UAR_GET_CODE_DISPLAY(ELH.LOC_NURSE_UNIT_CD)



FROM

                PATHWAY   P

                , PATHWAY_ACTION   PA

                , PERSON   PS

                , ENCNTR_ALIAS   EA

                , ENCNTR_domain   ELH

                , PRSNL   PN

                , PERSON   PATN

                , PATHWAY_CATALOG   PC



;mod01

PLAN P

     WHERE P.ORDER_DT_TM between CNVTDATETIME(CNVTDATE(03192014), 0) AND CNVTDATETIME(CNVTDATE(03272014), 2359) ;Highlighted items are date ranges

       ;AND P.PW_STATUS_CD in  (674355, 674356) ;674356 ;INITIATED   674355.00 ;(PLANNED)

            

JOIN PA

     WHERE PA.PATHWAY_ID = P.PATHWAY_ID
       ;AND PA.ACTION_TYPE_CD IN (10752.00, 10751.00) ;ORDER, MODIFY
JOIN PC                                                                                                                 
     WHERE P.pathway_catalog_id = PC.pathway_catalog_id                                                            
       AND PC.description in ("Discharge*") ;specify powerplan that you are searching for
JOIN PS
     WHERE PS.PERSON_ID = P.PERSON_ID
JOIN EA
     WHERE EA.ENCNTR_ID = P.ENCNTR_I
       AND EA.ENCNTR_ALIAS_TYPE_CD = 1077.00 ;FIN NBR
JOIN ELH
     WHERE ELH.ENCNTR_ID = P.ENCNTR_ID
       AND P.ORDER_DT_TM BETWEEN ELH.BEG_EFFECTIVE_DT_TM AND ELH.END_EFFECTIVE_DT_TM
       ;and ELH.loc_building_cd = 4363058           
JOIN PN
     WHERE PN.PERSON_ID = PA.ACTION_PRSNL_ID
JOIN PATN
     WHERE PATN.PERSON_ID = ELH.PERSON_ID
     ;AND PATN.name_full_formatted = "*"
ORDER BY
                FIN
                , POWERPLAN_NAME
WITH TIME = 120

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go

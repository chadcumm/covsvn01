/****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
*****************************************************************************************
	Author:				Dan Herren
	Date Written:		September 2020
	Solution:			Periop
	Source file name:  	cov_peri_count_verification.prg
	Object name:		cov_peri_count_verification
	Layout file name:	cov_peri_count_verification_lb
	CR#:				6461
 
	Program purpose:
	Executing from:		CCL
  	Special Notes:
 
*****************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #  Mod Date    Developer           Comment
*  	----------- ----------  ------------------- -----------------------------------------
*
*****************************************************************************************/
 
drop   program cov_peri_count_verification:DBA go
create program cov_peri_count_verification:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 0
	, "Surgical Area" = 0
	, "Report or Grid" = 0
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	SURG_AREA_PMPT, RPT_GRID_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
record rec (
	1 rec_cnt					= i4
	1 username					= vc
	1 startdate					= vc
	1 enddate					= vc
	1 list[*]
		2 facility      		= vc
		2 nurse_unit    		= vc
		2 pat_name				= vc
		2 fin           		= vc
		2 surg_area				= vc
		2 surg_case_nbr			= vc
		2 surg_case_dt			= dq8
		2 physician				= vc
		2 event_name			= vc
		2 event_result			= vc
		2 count_type			= vc
		2 procedure				= vc
		2 items_in_count		= vc
		2 count_by				= vc
		2 method				= vc
		2 status				= vc
		2 surgeon_notified		= vc
		2 encntr_id				= f8
		2 event_id				= f8
		2 periop_doc_id			= f8
		2 parent_event_id		= f8
		2 collating_seq			= vc
	)
 
record output (
	1 rec_cnt				= i4
	1 username				= vc
	1 startdate				= vc
	1 enddate				= vc
	1 list[*]
		2 facility      	= vc
		2 nurse_unit    	= vc
		2 pat_name			= vc
		2 fin           	= vc
		2 surg_area			= vc
		2 surg_case_nbr		= vc
		2 surg_case_dt		= dq8
		2 physician			= vc
		2 periop_doc_id		= f8
		2 parent_event_id	= f8
		2 collating_seq		= vc
		2 encntr_id			= f8
		2 events[*]
			;2 event_name		= vc
			;2 event_result		= vc
			3 count_type		= vc
			3 procedure			= vc
			3 items_in_count	= vc
			3 count_by			= vc
			3 method			= vc
			3 status			= vc
			3 surgeon_notified	= vc
			;2 event_id			= f8
 
;		2 proc			= vc
;		2 proc_addtl	= vc
;		2 type_init		= vc
;		2 type_final	= vc
;		2 type_addtl	= vc
;		2 method_init	= vc
;		2 method_final	= vc
;		2 method_addtl	= vc
;		2 what_init		= vc
;		2 what_final	= vc
;		2 what_addtl	= vc
;		2 who_init		= vc
;		2 who_final		= vc
;		2 who_addtl		= vc
;		2 status_final	= vc
;		2 status_addtl	= vc
;		2 surg_notify_final	= vc
;		2 surg_notify_addtl	= vc
;		2 encntr_id			= f8
;		2 event_id			= f8
;		2 event_prsnl_id	= f8
;		2 action_prsnl_id	= f8
	)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare username           			= vc with protect
declare initcap()          			= c100
declare num				   			= i4 with noconstant(0)
;
declare ACTIVE_VAR 					= f8 with constant(uar_get_code_by("MEANING",8, "ACTIVE")),protect
declare AUTHVERIFIED_VAR 			= f8 with constant(uar_get_code_by("MEANING",8, "AUTH")),protect
declare ALTERED_VAR 				= f8 with constant(uar_get_code_by("MEANING",8, "ALTERED")),protect
declare MODIFIED_VAR	 			= f8 with constant(uar_get_code_by("MEANING",8, "MODIFIED")),protect
;
declare FIN_VAR            			= f8 with constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")),protect
declare ASSIST_PRSNL_VAR   			= f8 with constant(uar_get_code_by("DISPLAYKEY",21,"ASSIST")),protect
declare ADMIT_PHYS_VAR     			= f8 with constant(uar_get_code_by("DISPLAYKEY",333,"ADMITTINGPHYSICIAN")),protect
declare ORNURSE_VAR		 			= f8 with constant(uar_get_code_by("MEANING"   ,14258, "ORNURSE")),protect
;
declare ACTIVE_STATUS_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")),protect
;
declare PROC_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSPROCEDURE")),protect
declare PROC_ADDTL_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLPROCEDURE")),protect
declare TYPE_ADDTL_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLCOUNTTYPE")),protect
declare METHOD_INIT_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSINITIALCOUNTMETHOD")),protect
declare METHOD_FINAL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSFINALCOUNTMETHOD")),protect
declare METHOD_ADDTL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLCOUNTMETHOD")),protect
declare WHAT_INIT_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSITEMSINCOUNT")),protect
declare WHAT_FINAL_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSITEMSFINALCOUNT")),protect
declare WHAT_ADDTL_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLCOUNTITEMS")),protect
declare WHO_INIT_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSINITCOUNTBY")),protect
declare WHO_FINAL_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSFINALCOUNTSBY")),protect
declare WHO_ADDTL_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLCOUNTBY")),protect
declare STATUS_FINAL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSFINALSTATUS")),protect
declare STATUS_ADDTL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLCOUNTSTATUS")),protect
declare SURG_NOTIFY_FINAL_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSFINALSURGEONNOTIFIED")),protect
declare SURG_NOTIFY_ADDTL_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SNCOUNTSADDTNLSURGEONNOTIFIED")),protect
;
declare FLMC_INTRAOP_REC_OR_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"FLMCINTRAOPRECORDOR")),protect
declare FLMC_INTRAPROC_REC_EN_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"FLMCINTRAPROCRECORDEN")),protect
declare FSR_INTRAOP_REC_OR_VAR 	 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"FSRINTRAOPRECORDOR")),protect
declare FSR_INTRAPROC_REC_EN_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"FSRINTRAPROCRECORDEN")),protect
declare FSR_INTRAPROC_REC_LD_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"FSRINTRAPROCRECORDLD")),protect
declare LCMC_INTRAOP_REC_OR_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"LCMCINTRAOPRECORDOR")),protect
declare LCMC_INTRAPROC_REC_EN_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"LCMCINTRAPROCRECORDEN")),protect
declare LCMC_INTRAPROC_REC_LD_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"LCMCINTRAPROCRECORDLD")),protect
declare MHAS_INTRAOP_REC_OR_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MHASINTRAOPRECORDOR")),protect
declare MHAS_INTRAPROC_REC_EN_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MHASINTRAPROCRECORDEN")),protect
declare MHHS_INTRAOP_REC_OR_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MHHSINTRAOPRECORDOR")),protect
declare MHHS_INTRAPROC_REC_EN_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MHHSINTRAPROCRECORDEN")),protect
declare MHHS_INTRAPROC_REC_LD_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MHHSINTRAPROCRECORDLD")),protect
declare MMC_INTRAOP_REC_OR_VAR 	 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MMCINTRAOPRECORDOR")),protect
declare MMC_INTRAPROC_REC_EN_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MMCINTRAPROCRECORDEN")),protect
declare MMC_INTRAPROC_REC_LD_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"MMCINTRAPROCRECORDLD")),protect
declare PWMC_INTRAOP_REC_OR_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"PWMCINTRAOPRECORDOR")),protect
declare PWMC_INTRAPROC_REC_EN_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"PWMCINTRAPROCRECORDEN")),protect
declare PWMC_INTRAPROC_REC_LD_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"PWMCINTRAPROCRECORDLD")),protect
declare RMC_INTRAOP_REC_OR_VAR 	 	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"RMCINTRAOPRECORDOR")),protect
declare RMC_INTRAPROC_REC_EN_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14258,"RMCINTRAPROCRECORDEN")),protect
;
declare OPR_FAC_VAR		   			= vc with noconstant(fillstring(1000," "))
declare OPR_SA_VAR		   			= vc with noconstant(fillstring(1000," "))
 
declare PROCEDURE_VAR   			= vc with noconstant(" ")
;
;declare WHO_INIT_VAR     			= vc with protect
;declare WHO_ADDTL_VAR     			= vc with protect
;declare WHO_FINAL_VAR    			= vc with protect
;
declare	START_DATE					= f8
declare END_DATE					= f8
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
;SET DATE PROMPTS TO DATE VARIABLES
set START_DATE = cnvtdatetime($START_DATETIME_PMPT)
set END_DATE   = cnvtdatetime($END_DATETIME_PMPT)
 
 
;SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATE, "mm/dd/yyyy;;q") 	;substring(1,11,$START_DATETIME_PMPT)
set rec->enddate   = format(END_DATE, "mm/dd/yyyy;;q") 		;substring(1,11,$END_DATETIME_PMPT)
 
 
;SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 

;SET SURGICAL AREA PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($SURG_AREA_PMPT),0))) = "L")	;multiple values were selected
	set OPR_SA_VAR = "in"
elseif(parameter(parameter2($SURG_AREA_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_SA_VAR = "!="
else																		;a single value was selected
	set OPR_SA_VAR = "="
endif
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select distinct into value ($OUTDEV)
	 facility 			= uar_get_code_display(e.loc_facility_cd)
	,nurse_unit 		= uar_get_code_display(e.loc_nurse_unit_cd)
	,pat_name	 		= initcap(p.name_full_formatted)
	,fin 				= ea.alias
	,surg_area			= uar_get_code_display(sc.surg_case_nbr_locn_cd)
	,surg_case_nbr		= sc.surg_case_nbr_formatted
	,surg_case_dt		= sc.surg_start_dt_tm
	,physician			= initcap(pl.name_full_formatted)
	,event_name 		=
		if(ce.event_cd = PROC_VAR) 						"Procedure"  					;275169319
			elseif(ce.event_cd = WHAT_INIT_VAR) 		"Items In Count"    			;4190263
			elseif(ce.event_cd = WHO_INIT_VAR) 			"Initial Count By"  			;4190280
			elseif(ce.event_cd = METHOD_INIT_VAR) 		"Initial Count Method"   		;275169351
			elseif(ce.event_cd = TYPE_ADDTL_VAR) 		concat(substring(1,2,ce.collating_seq)," ","Additional Count Type")			;4190254
			elseif(ce.event_cd = PROC_ADDTL_VAR) 		concat(substring(1,2,ce.collating_seq)," ","Additional Procedure")			;275169421
			elseif(ce.event_cd = WHAT_ADDTL_VAR) 		concat(substring(1,2,ce.collating_seq)," ","Additional Count Items")		;4190248
			elseif(ce.event_cd = WHO_ADDTL_VAR)			concat(substring(1,2,ce.collating_seq)," ","Additional Counts By")			;4190245
			elseif(ce.event_cd = METHOD_ADDTL_VAR) 		concat(substring(1,2,ce.collating_seq)," ","Additional Count Method")		;275169459
			elseif(ce.event_cd = STATUS_ADDTL_VAR) 		concat(substring(1,2,ce.collating_seq)," ","Additional Count Status")		;4190251
			elseif(ce.event_cd = SURG_NOTIFY_ADDTL_VAR) concat(substring(1,2,ce.collating_seq)," ","Additional Surgeon Notified")	;275169481
			elseif(ce.event_cd = WHAT_FINAL_VAR) 		"Items Final Count"   			;4190260
			elseif(ce.event_cd = WHO_FINAL_VAR) 		"Final Counts By"				;4190282
			elseif(ce.event_cd = METHOD_FINAL_VAR) 		"Final Count Method" 			;275169371
			elseif(ce.event_cd = STATUS_FINAL_VAR) 		"Final Status"   				;4190257
			elseif(ce.event_cd = SURG_NOTIFY_FINAL_VAR) "Final Surgeon Notified" 		;275169403
		else ""
		endif
	,event_result 		=
		if(ce.event_cd = PROC_VAR) 						ce.result_val					;Procedure
			elseif(ce.event_cd = WHAT_INIT_VAR) 		ce.result_val					;Items In Count
			elseif(ce.event_cd = WHO_INIT_VAR) 			initcap(pl2.name_full_formatted);Initial Count By
			elseif(ce.event_cd = METHOD_INIT_VAR) 		ce.result_val					;Initial Count Method
			elseif(ce.event_cd = TYPE_ADDTL_VAR) 		ce.result_val					;Additional Count Type
			elseif(ce.event_cd = PROC_ADDTL_VAR) 		ce.result_val					;Additional Procedure
			elseif(ce.event_cd = WHAT_ADDTL_VAR) 		ce.result_val					;Additional Count Items
			elseif(ce.event_cd = WHO_ADDTL_VAR) 		initcap(pl2.name_full_formatted);Additional Counts By
			elseif(ce.event_cd = METHOD_ADDTL_VAR) 		ce.result_val					;Additional Count Method
			elseif(ce.event_cd = STATUS_ADDTL_VAR) 		ce.result_val					;Additional Count Status
			elseif(ce.event_cd = SURG_NOTIFY_ADDTL_VAR) ce.result_val					;Additional Surgeon Notified
			elseif(ce.event_cd = WHAT_FINAL_VAR) 		ce.result_val					;Items Final Count
			elseif(ce.event_cd = WHO_FINAL_VAR) 		initcap(pl2.name_full_formatted);Final Counts By
			elseif(ce.event_cd = METHOD_FINAL_VAR) 		ce.result_val					;Final Count Method
			elseif(ce.event_cd = STATUS_FINAL_VAR) 		ce.result_val					;Final Status
			elseif(ce.event_cd = SURG_NOTIFY_FINAL_VAR) ce.result_val					;Final Surgeon Notified
		else ""
		endif
	,count_type			= if(ce.event_cd = TYPE_ADDTL_VAR) ce.result_val endif
	,procedure			= if(ce.event_cd = PROC_VAR) ce.result_val endif
	,items_in_count		= if(ce.event_cd in (WHAT_INIT_VAR, WHAT_ADDTL_VAR, WHAT_FINAL_VAR)) ce.result_val endif
	,count_by			= if(ce.event_cd in (WHO_INIT_VAR, WHO_ADDTL_VAR, WHO_FINAL_VAR)) initcap(pl2.name_full_formatted) endif
	,method				= if(ce.event_cd in (METHOD_INIT_VAR, METHOD_ADDTL_VAR, METHOD_FINAL_VAR)) ce.result_val endif
	,status				= if(ce.event_cd in (STATUS_ADDTL_VAR, STATUS_FINAL_VAR)) ce.result_val endif
	,surgeon_notified	= if(ce.event_cd in (SURG_NOTIFY_ADDTL_VAR, SURG_NOTIFY_FINAL_VAR)) ce.result_val endif
	,event_end_dt		= ce.event_end_dt_tm
	,encntr_id			= e.encntr_id
	,event_id			= ce.event_id
	,periop_doc_id		= pd.periop_doc_id
	,parent_event_id	= ce.parent_event_id
	,collating_seq		= ce.collating_seq
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = 1077 ;fin
;		and ea.alias = "2128001113" ;"2127100065" ;"2126400333" ;"2124600238" ;"2124203775" ;"2125801128"
		and ea.active_ind = 1)
 
	,(inner join SURGICAL_CASE sc on sc.encntr_id = e.encntr_id
		and sc.surg_start_dt_tm between cnvtdatetime(START_DATE) and cnvtdatetime(END_DATE)
		and operator(sc.surg_case_nbr_locn_cd, OPR_SA_VAR, $SURG_AREA_PMPT)
		and sc.active_ind = 1)
 
	,(inner join PERIOPERATIVE_DOCUMENT pd on pd.surg_case_id = sc.surg_case_id
		and pd.doc_type_cd in (FLMC_INTRAOP_REC_OR_VAR, FLMC_INTRAPROC_REC_EN_VAR, FSR_INTRAOP_REC_OR_VAR,
			FSR_INTRAPROC_REC_EN_VAR, FSR_INTRAPROC_REC_LD_VAR, LCMC_INTRAOP_REC_OR_VAR, LCMC_INTRAPROC_REC_EN_VAR,
			LCMC_INTRAPROC_REC_LD_VAR, MHAS_INTRAOP_REC_OR_VAR, MHAS_INTRAPROC_REC_EN_VAR, MHHS_INTRAOP_REC_OR_VAR,
			MHHS_INTRAPROC_REC_EN_VAR, MHHS_INTRAPROC_REC_LD_VAR, MMC_INTRAOP_REC_OR_VAR, MMC_INTRAPROC_REC_EN_VAR,
			MMC_INTRAPROC_REC_LD_VAR, PWMC_INTRAOP_REC_OR_VAR, PWMC_INTRAPROC_REC_EN_VAR, PWMC_INTRAPROC_REC_LD_VAR,
			RMC_INTRAOP_REC_OR_VAR, RMC_INTRAPROC_REC_EN_VAR))
; 		and pd.doc_term_dt_tm = null)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id and ce.person_id = e.person_id
		and operator(ce.reference_nbr,'LIKE',concat(trim(cnvtstring(pd.periop_doc_id,3)),'SN%'))
		and ce.event_cd in (PROC_VAR, PROC_ADDTL_VAR, TYPE_ADDTL_VAR,
			METHOD_INIT_VAR, METHOD_FINAL_VAR, METHOD_ADDTL_VAR, WHAT_INIT_VAR, WHAT_FINAL_VAR, WHAT_ADDTL_VAR,
			WHO_INIT_VAR, WHO_FINAL_VAR, WHO_ADDTL_VAR, STATUS_FINAL_VAR, STATUS_ADDTL_VAR,
			SURG_NOTIFY_ADDTL_VAR, SURG_NOTIFY_FINAL_VAR)
		and ce.record_status_cd = ACTIVE_STATUS_VAR ;188
		and ce.result_status_cd in (ACTIVE_VAR, AUTHVERIFIED_VAR, MODIFIED_VAR, ALTERED_VAR)
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	,(left join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = ASSIST_PRSNL_VAR ;94
		and cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(left join PRSNL pl on pl.person_id = sc.surgeon_prsnl_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pl.active_ind = 1)
 
	,(left join PRSNL pl2 on pl2.person_id = cep.action_prsnl_id
		and pl2.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pl2.active_ind = 1)
 
where operator(e.organization_id, OPR_FAC_VAR, $FACILITY_PMPT)
;	and e.encntr_id =  126070150
	and e.active_ind = 1
 
order by facility, pat_name, surg_case_dt desc, ce.parent_event_id, ce.collating_seq,
		if(ce.event_cd = PROC_VAR) 						"A"		;Procedure
			elseif(ce.event_cd = WHAT_INIT_VAR) 		"B"		;Items In Count
			elseif(ce.event_cd = WHO_INIT_VAR) 			"C"		;Initial Count By
			elseif(ce.event_cd = METHOD_INIT_VAR) 		"D"		;Initial Count Method
			elseif(ce.event_cd = TYPE_ADDTL_VAR) 		"E"		;Additional Count Type
			elseif(ce.event_cd = PROC_ADDTL_VAR) 		"F"		;Additional Procedure
			elseif(ce.event_cd = WHAT_ADDTL_VAR) 		"G"		;Additional Count Items
			elseif(ce.event_cd = WHO_ADDTL_VAR) 		"H"		;Additional Counts By
			elseif(ce.event_cd = METHOD_ADDTL_VAR)		"I"		;Additional Count Method
			elseif(ce.event_cd = STATUS_ADDTL_VAR) 		"J"		;Additional Count Status
			elseif(ce.event_cd = SURG_NOTIFY_ADDTL_VAR) "K"		;Additional Surgeon Notified
			elseif(ce.event_cd = WHAT_FINAL_VAR) 		"L"		;Items Final Count
			elseif(ce.event_cd = WHO_FINAL_VAR) 		"M"		;Final Counts By
			elseif(ce.event_cd = METHOD_FINAL_VAR) 		"N"		;Final Count Method
			elseif(ce.event_cd = STATUS_FINAL_VAR) 		"O"		;Final Status
			elseif(ce.event_cd = SURG_NOTIFY_FINAL_VAR) "P"		;Final Surgeon Notified
		endif,
		e.encntr_id, ce.event_id, cep.action_prsnl_id, pd.periop_doc_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility			= facility
	rec->list[cnt].nurse_unit		= nurse_unit
	rec->list[cnt].pat_name      	= pat_name
	rec->list[cnt].fin				= fin
	rec->list[cnt].surg_area		= surg_area
	rec->list[cnt].surg_case_nbr	= surg_case_nbr
	rec->list[cnt].surg_case_dt		= surg_case_dt
	rec->list[cnt].physician		= physician
	rec->list[cnt].event_name		= event_name
	rec->list[cnt].event_result		= event_result
	rec->list[cnt].count_type		= count_type
	rec->list[cnt].procedure		= procedure
	rec->list[cnt].items_in_count	= items_in_count
	rec->list[cnt].count_by			= count_by
	rec->list[cnt].method			= method
	rec->list[cnt].status			= status
	rec->list[cnt].surgeon_notified	= surgeon_notified
	rec->list[cnt].encntr_id		= encntr_id
	rec->list[cnt].event_id			= event_id
	rec->list[cnt].periop_doc_id	= periop_doc_id
	rec->list[cnt].parent_event_id	= parent_event_id
	rec->list[cnt].collating_seq	= collating_seq
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;====================================================
; COPY RECORD STRUCTURE FOR OUTPUT
;====================================================
;CALL ECHO (BUILD2("COPY RECORD STRUCTURE FOR OUTPUT "))
select into 'nl:'
	 facility 		= rec->list[d.seq].facility
	,pat_name 		= rec->list[d.seq].pat_name
	,surg_case_nbr 	= rec->list[d.seq].surg_case_nbr
	,collating_seq	= rec->list[d.seq].collating_seq
	,sort_val 		= if (rec->list[d.seq].event_name = "Initial*")
					  	0
					  elseif (rec->list[d.seq].event_name = "Items In Count")
						0
					  elseif (rec->list[d.seq].event_name = "Procedure")
						0
				      elseif (rec->list[d.seq].event_name = "Items Final Count")
						9999
					  elseif (rec->list[d.seq].event_name = "Final*")
						9999
					  else
						cnvtint(rec->list[d.seq].collating_seq)
					  endif
 
from (DUMMYT d with seq = rec->rec_cnt)
 
plan d
 
order by
	 facility
	,pat_name
	,surg_case_nbr
	,sort_val
 
head report
	cnt = 0
 	i = 0
 
head facility
	call echo(build2("facility=",facility))
 
head pat_name
	call echo(build2("-------------------------------------------------------------"))
	call echo(build2("pat_name=",pat_name))
 
head surg_case_nbr
	call echo(build2("surg_case_nbr=",surg_case_nbr))
	i = (i + 1)
 
	stat = alterlist(output->list, i)
 
	output->list[i].facility			= rec->list[d.seq].facility
	output->list[i].nurse_unit			= rec->list[d.seq].nurse_unit
	output->list[i].pat_name 			= rec->list[d.seq].pat_name
	output->list[i].fin					= rec->list[d.seq].fin
	output->list[i].surg_area			= rec->list[d.seq].surg_area
	output->list[i].surg_case_nbr		= rec->list[d.seq].surg_case_nbr
	output->list[i].surg_case_dt		= rec->list[d.seq].surg_case_dt
	output->list[i].physician			= rec->list[d.seq].physician
	output->list[i].encntr_id			= rec->list[d.seq].encntr_id
 
	cnt = 0
 
head sort_val
	call echo(build2("sort_val=",sort_val))
	cnt = (cnt + 1)
 
	stat = alterlist(output->list[i].events,cnt)
 
	if (sort_val = 0)
		output->list[i].events[cnt].count_type = "Initial"
		if (rec->list[d.seq].event_name = "Procedure")
			PROCEDURE_VAR = rec->list[d.seq].procedure
		endif
	elseif (sort_val = 9999)
		output->list[i].events[cnt].count_type = "Final"
	else
		output->list[i].events[cnt].count_type = rec->list[d.seq].event_result
	endif
 
detail
	call echo(build2("items_in_count=",rec->list[d.seq].items_in_count))
	call echo(build2("procedure=",rec->list[d.seq].procedure))
	call echo(build2("method=",rec->list[d.seq].method))
	call echo(build2("event_name=",rec->list[d.seq].event_name))
	call echo(build2("event_result=",rec->list[d.seq].event_result))
	call echo(build2("collating_seq=",rec->list[d.seq].collating_seq))
	call echo(build2("sort_val=",sort_val))
 
	output->list[i].events[cnt].procedure = PROCEDURE_VAR
 
	case (rec->list[d.seq].event_name)
		;of "Procedure": 				output->list[i].events[cnt].procedure 			= rec->list[d.seq].procedure
		of "Initial Count Method": 		output->list[i].events[cnt].method 				= rec->list[d.seq].method
		of "Final Count Method":		output->list[i].events[cnt].method 				= rec->list[d.seq].method
		of "*Additional Count Method":	output->list[i].events[cnt].method 				= rec->list[d.seq].method
		of "Final Status":				output->list[i].events[cnt].status 				= rec->list[d.seq].status
		of "*Additional Count Status":	output->list[i].events[cnt].status 				= rec->list[d.seq].status
		of "Items In Count":			output->list[i].events[cnt].items_in_count 		= rec->list[d.seq].items_in_count
		of "Items Final Count":			output->list[i].events[cnt].items_in_count 		= rec->list[d.seq].items_in_count
		of "*Additional Count Items":	output->list[i].events[cnt].items_in_count 		= rec->list[d.seq].items_in_count
		of "Initial Count By":			output->list[i].events[cnt].count_by 			= concat(
																									 output->list[i].events[cnt].count_by
																									,rec->list[d.seq].count_by
																									,"; "
																								)
		of "Final Counts By":			output->list[i].events[cnt].count_by 			= concat(
																									 output->list[i].events[cnt].count_by
																									,rec->list[d.seq].count_by
																									,"; "
																								)
		of "*Additional Counts By":		output->list[i].events[cnt].count_by 			= concat(
																									 output->list[i].events[cnt].count_by
																									,rec->list[d.seq].count_by
																									,"; "
																								)
		of "Final Surgeon Notified":	output->list[i].events[cnt].surgeon_notified 		= rec->list[d.seq].surgeon_notified
		of "*Additional Surgeon Notified": output->list[i].events[cnt].surgeon_notified 	= rec->list[d.seq].surgeon_notified
	endcase
 
foot report
	stat = alterlist(output->list, i)
 
	output->rec_cnt		= rec->rec_cnt
	output->username	= rec->username
	output->startdate	= rec->startdate
	output->enddate		= rec->enddate
 
; 	output->rec_cnt = i
 
with nocounter
 
call echorecord(output)
;go to exitscript
 
/*
;============================
; REPORT OUTPUT
;============================
if (output->rec_cnt > 0)
 
	select into value ($OUTDEV)
		 facility      		= substring(1,50,output->list[d.seq].facility)
	;	,nurse_unit			= substring(1,50,output->list[d.seq].nurse_unit)
		,patient_name		= substring(1,50,output->list[d.seq].pat_name)
		,fin				= substring(1,50,output->list[d.seq].fin)
		,surg_area			= substring(1,50,output->list[d.seq].surg_area)
		,surg_case_nbr		= substring(1,50,output->list[d.seq].surg_case_nbr)
		,surg_case_dt		= format(output->list[d.seq].surg_case_dt, "mm/dd/yyyy hh:mm;;q")
		,physician			= substring(1,50,output->list[d.seq].physician)
;		,event_name			= substring(1,100,output->list[d.seq].event_name)
;		,event_result		= substring(1,200,output->list[d.seq].event_result)
		,count_type			= substring(1,50,output->list[d.seq].events[d2.seq].count_type)
		,procedure			= substring(1,50,output->list[d.seq].events[d2.seq].procedure)
		,items_in_count		= substring(1,50,output->list[d.seq].events[d2.seq].items_in_count)
		,count_by			= substring(1,50,output->list[d.seq].events[d2.seq].count_by)
		,method				= substring(1,50,output->list[d.seq].events[d2.seq].method)
		,status				= substring(1,50,output->list[d.seq].events[d2.seq].status)
		,surgeon_notified	= substring(1,50,output->list[d.seq].events[d2.seq].surgeon_notified)
;		,encntr_id     		= output->list[d.seq].encntr_id
;	;	,event_id			= output->list[d.seq].event_id
;	;	,periop_doc_id		= output->list[d.seq].periop_doc_id
;	;	,parent_event_id	= output->list[d.seq].parent_event_id
;;		,collating_seq		= output->list[d.seq].collating_seq
;;		,username      		= output->username
;;		,startdate_pmpt		= output->startdate
;;		,enddate_pmpt  		= output->enddate
;		,rec_cnt	   		= output->rec_cnt
 
	from
		(DUMMYT d  with seq = value(size(output->list,5)))
		,(DUMMYT d2 with seq = 1)

 
	plan d
		where maxrec(d2, size(output->list[d.seq].events,5))
 
	join d2 

 	;order by surg_case_dt
	with nocounter, format, check, separator = " "
 
;	select into value ($OUTDEV)
;		 facility      		= substring(1,50,rec->list[d.seq].facility)
;	;	,nurse_unit			= substring(1,50,rec->list[d.seq].nurse_unit)
;		,patient_name		= substring(1,50,rec->list[d.seq].pat_name)
;		,fin				= substring(1,50,rec->list[d.seq].fin)
;		,surg_case_nbr		= substring(1,50,rec->list[d.seq].surg_case_nbr)
;		,surg_case_dt		= format(rec->list[d.seq].surg_case_dt, "mm/dd/yyyy hh:mm;;q")
;		,physician			= substring(1,50,rec->list[d.seq].physician)
;;		,event_name			= substring(1,100,rec->list[d.seq].event_name)
;;		,event_result		= substring(1,200,rec->list[d.seq].event_result)
;		,count_type			= substring(1,50,rec->list[d.seq].count_type)
;		,procedure			= substring(1,50,rec->list[d.seq].procedure)
;		,items_in_count		= substring(1,50,rec->list[d.seq].items_in_count)
;		,count_by			= substring(1,50,rec->list[d.seq].count_by)
;		,method				= substring(1,50,rec->list[d.seq].method)
;		,status				= substring(1,50,rec->list[d.seq].status)
;		,surgeon_notified	= substring(1,50,rec->list[d.seq].surgeon_notified)
;		,encntr_id     		= rec->list[d.seq].encntr_id
;	;	,event_id			= rec->list[d.seq].event_id
;	;	,periop_doc_id		= rec->list[d.seq].periop_doc_id
;	;	,parent_event_id	= rec->list[d.seq].parent_event_id
;;		,collating_seq		= rec->list[d.seq].collating_seq
;;		,startdate_pmpt		= rec->startdate
;;		,enddate_pmpt  		= rec->enddate
;;		,username      		= rec->username
;;		,rec_cnt	   		= rec->rec_cnt
;
;	from
;		(dummyt d  with seq = value(size(rec->list,5)))
;
;	plan d
; 	;order by surg_case_dt
;	with nocounter, format, check, separator = " "
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
*/
 
#exitscript
 
;call echorecord(rec)
call echorecord(output)
end
go
 
/*
;		and ce.event_cd in (275169319,275169421,4190254,275169351,275169371,275169459,4190263,4190260,4190248,4190280,
;			4190282,4190245,4190257,4190251,4190257,275169403,275169481)
*/

/****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
*****************************************************************************************
	Author:				Dan Herren
	Date Written:		September 2020
	Solution:			Periop
	Source file name:  	cov_peri_TJCLog_NS.prg
	Object name:		cov_peri_TJCLog_NS
	Layout file name:
	CR#:
 
	Program purpose:	Usage report for TJC Log Non-Surgical.
	Executing from:		CCL
  	Special Notes:		djherren_dvd11:dba  test/dev version
 
*****************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #  Mod Date    Developer           Comment
*  	----------- ----------  ------------------- -----------------------------------------
*	001			10/02/20	Chad Cummings		Added field 'updt_applctx' for grouping
*	002			10/14/21	Marty B / Dan H		CR11128 / CR11131
*	003			11/05/21	Dan Herren			CR11528 - Add Nurse Unit Prompt
*
*****************************************************************************************/
 
drop program   cov_peri_TJCLog_NS:dba go
create program cov_peri_TJCLog_NS:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 0
 
with OUTDEV, START_DATE_PMPT, END_DATE_PMPT, FACILITY_PMPT, NURSEUNIT_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
record rec (
	1 rec_cnt					= i4
	1 ce_cnt					= i4
	1 username					= vc
	1 startdate					= vc
	1 enddate					= vc
	1 list[*]
		2 facility      		= vc
		2 nurse_unit    		= vc
		2 pat_name				= vc
		2 birth_date			= dq8
		2 gender				= vc
		2 fin           		= vc
		2 encntr_type			= vc
		2 admit_dt				= dq8
		2 encntr_id				= f8
		2 event_id				= f8
		2 event_cnt				= i4
		2 updt_applctx			= f8 ;001
		2 events[*]
			3 event_cd			= f8
			3 event				= vc
			3 first_anes		= vc
			3 second_anes		= vc
			3 anes_type			= vc
			3 bedside_proc_type	= vc
			3 first_nurse		= vc
			3 second_nurse		= vc
			3 pre_diag			= vc
			3 post_diag			= vc
			3 proc_done			= vc
			3 proc_loc			= vc
			3 proc_performed_by	= vc
			3 proc_start		= dq8
			3 proc_stop			= dq8
			3 provider			= vc
			3 first_tech		= vc
			3 second_tech		= vc
			3 proc_type			= vc
			3 bedside_procedure	= vc
			3 cardiac_dx		= vc
			3 ob_procedure		= vc
			3 correct_patient	= vc
			3 procedure_verify	= vc
			3 event_id			= f8
	)
 
record output (
	1 rec_cnt					= i4
	1 ce_cnt					= i4
	1 username					= vc
	1 startdate					= vc
	1 enddate					= vc
	1 list[*]
		2 facility      		= vc
		2 nurse_unit    		= vc
		2 pat_name				= vc
		2 birth_date			= dq8
		2 gender				= vc
		2 fin           		= vc
		2 encntr_type			= vc
		2 admit_dt				= dq8
		2 event					= vc
		2 first_anes			= vc
		2 second_anes			= vc
		2 anes_type				= vc
		2 bedside_proc_type		= vc
		2 first_nurse			= vc
		2 second_nurse			= vc
		2 pre_diag				= vc
		2 post_diag				= vc
		2 proc_done				= vc
		2 proc_loc				= vc
		2 proc_performed_by		= vc
		2 proc_start			= dq8
		2 proc_stop				= dq8
		2 provider				= vc
		2 first_tech			= vc
		2 second_tech			= vc
		2 proc_type				= vc
		2 bedside_procedure		= vc
		2 cardiac_dx			= vc
		2 ob_procedure			= vc
		2 correct_patient		= vc
		2 procedure_verify		= vc
		2 encntr_id				= f8
		2 event_id				= f8
		2 updt_applctx			= f8 ;001
	)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare username           		= vc with protect
declare initcap()          		= c100
declare num				   		= i4 with noconstant(0)
;
declare BEDSIDE_PROC_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"BEDSIDEPROCEDURETYPE")),protect  ;002 already exist
declare CARDIAC_DX_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDUREPERFORMEDCARDIACDXONLY")),protect ;002 added
declare OB_PROC_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"OBPROCEDURETYPE")),protect ;002 added
;
declare ANES_PRESENT_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"ANESTHESIAPRESENT")),protect
declare ANES_PRESENT2_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"ANESTHESIAPRESENT2")),protect
declare ANES_TYPE_PROC_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"ANESTHESIATYPEADULTPROCEDURE")),protect
declare BEDSIDE_PROC_TYPE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"BEDSIDEPROCEDURETYPE")),protect
declare FIRST_NURSE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"FIRSTNURSEPRESENT")),protect
declare SEC_NURSE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SECONDNURSEPRESENT")),protect
declare PRE_DIAG_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PREPROCEDUREDIAGNOSIS")),protect
declare POST_DIAG_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"POSTPROCEDUREDIAGNOSIS")),protect
declare PROC_DONE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDUREDONE")),protect
declare PROC_LOC_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDURELOCATION")),protect
declare PROC_PERFORM_BY_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDUREPERFORMEDBY")),protect
declare PROC_START_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDURESTARTTIME")),protect
declare PROC_STOP_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDURESTOPTIME")),protect
declare PROV_PRESENT_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROVIDERPRESENT")),protect
declare TECH_PRESENT_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"TECHPRESENT")),protect
declare TECH_PRESENT2_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"TECHPRESENT2")),protect
declare CORRECT_PATIENT_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"TIMEOUTCORRECTPATIENTNAME")),protect ;002
declare PROC_VERIFY_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"TIMEOUTPROCEDURE")),protect ;002
;
declare FIN_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")),protect
declare PLACE_HOLDER_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY", 53,"PLACEHOLDER")),protect
;
declare OPR_FAC_VAR		   		= vc with noconstant(fillstring(1000," "))
declare OPR_NRU_VAR		   		= vc with noconstant(fillstring(1000," ")) ;003
;
declare	START_DATE				= f8
declare END_DATE				= f8
 
 
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
 
 
; SET DATE PROMPTS TO DATE VARIABLES
set START_DATE = cnvtdatetime($START_DATE_PMPT)
set END_DATE   = cnvtdatetime($END_DATE_PMPT)
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
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
 
;SET NURSE UNIT PROMPT VARIABLE ;003
if(substring(1,1,reflect(parameter(parameter2($NURSEUNIT_PMPT),0))) = "L")	;multiple values were selected
	set OPR_NRU_VAR = "in"
elseif(parameter(parameter2($NURSEUNIT_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_NRU_VAR = "!="
else																		;a single value was selected
	set OPR_NRU_VAR = "="
endif
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select into "NL:"
	 facility  		= uar_get_code_display(e.loc_facility_cd)
	,nurse_unit		= uar_get_code_display(elh.loc_nurse_unit_cd)
	,pat_name	   	= p.name_full_formatted
	,birth_date		= p.birth_dt_tm
	,gender			= uar_get_code_display(p.sex_cd)
	,fin			= ea.alias
	,encntr_type	= uar_get_code_display(e.encntr_type_cd)
	,admit_dt		= e.reg_dt_tm
	,event_cd		= ce.event_cd
	,event			= uar_get_code_display(ce.event_cd)
	,event_id		= ce.event_id
	,encntr_id		= e.encntr_id
 
from ENCOUNTER e
 
 	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
;		and ea.alias in ("2031802721") ;2005001039
;		and ea.alias in ("2004802120", "2016401860", "2016401642", "2016400677", "2016401655", "2016402377")
		and ea.active_ind = 1)
 
	/* start 001 */
    ,(inner join CLINICAL_EVENT cemain on cemain.encntr_id = e.encntr_id
     	and cemain.event_cd in (BEDSIDE_PROC_TYPE_VAR, CARDIAC_DX_VAR, OB_PROC_VAR) ;002
     	and (cemain.event_end_dt_tm >= e.beg_effective_dt_tm and cemain.event_end_dt_tm < e.end_effective_dt_tm)
		and cemain.result_status_cd in (25,34,35,36)
		and cemain.event_class_cd != PLACE_HOLDER_VAR ;654645.00
		and cemain.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
	/* end 001 */
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
	    and ce.updt_applctx = cemain.updt_applctx ;001
		and ce.event_cd in (ANES_PRESENT_VAR, ANES_PRESENT2_VAR, ANES_TYPE_PROC_VAR, BEDSIDE_PROC_TYPE_VAR,
			FIRST_NURSE_VAR, SEC_NURSE_VAR, PRE_DIAG_VAR, POST_DIAG_VAR, PROC_DONE_VAR, PROC_LOC_VAR, PROC_PERFORM_BY_VAR,
			PROC_START_VAR, PROC_STOP_VAR, PROV_PRESENT_VAR, TECH_PRESENT_VAR, TECH_PRESENT2_VAR,
			BEDSIDE_PROC_VAR, CARDIAC_DX_VAR, OB_PROC_VAR, CORRECT_PATIENT_VAR, PROC_VERIFY_VAR)
;		and (ce.event_end_dt_tm >= elh.beg_effective_dt_tm and ce.event_end_dt_tm < elh.end_effective_dt_tm)
		and (ce.event_end_dt_tm >= e.beg_effective_dt_tm and ce.event_end_dt_tm < e.end_effective_dt_tm)
		and ce.result_status_cd in (25,34,35,36)
		and ce.event_class_cd != PLACE_HOLDER_VAR ;654645.00
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(left join CE_DATE_RESULT cdr on cdr.event_id = ce.event_id
		and cdr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(inner join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
		and operator(elh.loc_nurse_unit_cd, OPR_NRU_VAR, $NURSEUNIT_PMPT) ;003
		and ce.event_end_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
		and elh.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = ce.person_id
		and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and p.active_ind = 1)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and (e.reg_dt_tm between cnvtdatetime(START_DATE) and cnvtdatetime(END_DATE))
	and e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and e.active_ind = 1
 
order by e.encntr_id, cemain.updt_applctx, ce.event_id
 
head report
	cnt = 0
 
head e.encntr_id
	stat = 0 ;001
 
head cemain.updt_applctx ;001
 
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility     	= facility
	rec->list[cnt].nurse_unit   	= nurse_unit
	rec->list[cnt].pat_name			= pat_name
	rec->list[cnt].birth_date		= birth_date
	rec->list[cnt].gender			= gender
	rec->list[cnt].fin 				= fin
	rec->list[cnt].encntr_type		= encntr_type
	rec->list[cnt].admit_dt			= admit_dt
	rec->list[cnt].encntr_id		= encntr_id
	rec->list[cnt].event_id			= event_id
    rec->list[cnt].updt_applctx		= cemain.updt_applctx ;001
 
	cecnt = 0
 
head ce.event_id
	cecnt = cecnt + 1
 
 	if (mod(cecnt,10) = 1 or cecnt = 1)
 		stat = alterlist(rec->list[cnt].events, cecnt + 9)
 	endif
 
	rec->ce_cnt = cecnt
	rec->list[cnt].event_cnt = cecnt
 
	rec->list[cnt].events[cecnt].event_id	= event_id
	rec->list[cnt].events[cecnt].event_cd	= event_cd
	rec->list[cnt].events[cecnt].event		= event
 
	case (ce.event_cd)
		of ANES_PRESENT_VAR			: rec->list[cnt].events[cecnt].first_anes 			= ce.result_val
		of ANES_PRESENT2_VAR		: rec->list[cnt].events[cecnt].second_anes   		= ce.result_val
		of ANES_TYPE_PROC_VAR		: rec->list[cnt].events[cecnt].anes_type      		= ce.result_val
		of BEDSIDE_PROC_TYPE_VAR	: rec->list[cnt].events[cecnt].bedside_proc_type	= ce.result_val
		of FIRST_NURSE_VAR 			: rec->list[cnt].events[cecnt].first_nurse	 		= ce.result_val
		of SEC_NURSE_VAR			: rec->list[cnt].events[cecnt].second_nurse	 		= ce.result_val
		of PRE_DIAG_VAR				: rec->list[cnt].events[cecnt].pre_diag	 			= ce.result_val
		of POST_DIAG_VAR			: rec->list[cnt].events[cecnt].post_diag	 		= ce.result_val
		of PROC_DONE_VAR			: rec->list[cnt].events[cecnt].proc_done	 		= ce.result_val
		of PROC_LOC_VAR				: rec->list[cnt].events[cecnt].proc_loc	 			= ce.result_val
		of PROC_PERFORM_BY_VAR		: rec->list[cnt].events[cecnt].proc_performed_by	= ce.result_val
		of PROC_START_VAR			: rec->list[cnt].events[cecnt].proc_start	 		= cdr.result_dt_tm
		of PROC_STOP_VAR			: rec->list[cnt].events[cecnt].proc_stop	 		= cdr.result_dt_tm
		of PROV_PRESENT_VAR			: rec->list[cnt].events[cecnt].provider	 			= ce.result_val
		of TECH_PRESENT_VAR			: rec->list[cnt].events[cecnt].first_tech	 		= ce.result_val
		of TECH_PRESENT2_VAR		: rec->list[cnt].events[cecnt].second_tech	 		= ce.result_val
		of BEDSIDE_PROC_VAR			: rec->list[cnt].events[cecnt].bedside_procedure	= ce.result_val
		of CARDIAC_DX_VAR			: rec->list[cnt].events[cecnt].cardiac_dx	 		= ce.result_val ;002
		of OB_PROC_VAR				: rec->list[cnt].events[cecnt].ob_procedure 		= ce.result_val ;002
		of CORRECT_PATIENT_VAR		: rec->list[cnt].events[cecnt].correct_patient 		= ce.result_val
		of PROC_VERIFY_VAR			: rec->list[cnt].events[cecnt].procedure_verify		= ce.result_val
	endcase
 
foot cemain.updt_applctx
	stat = alterlist(rec->list[cnt].events, cecnt)
 
foot e.encntr_id
;	001 stat = alterlist(rec->list[cnt].events, cecnt) ;001
 	stat = 0 ;001
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
;
call echorecord(rec)
;go to exitscript
 
 
;====================================================
; COPY RECORD STRUCTURE FOR OUTPUT
;====================================================
;CALL ECHO (BUILD2("COPY RECORD STRUCTURE FOR OUTPUT "))
select into 'nl:'
 
from (DUMMYT d with seq = 1)
 
plan d
 
head report
	cnt = 0
 	i = 0
	curr_enc_id = 0
	prev_enc_id = 0
 
detail
	for (cnt = 1 to rec->rec_cnt)
 
;		curr_enc_id = rec->list[cnt].encntr_id ;001
 		curr_enc_id = rec->list[cnt].updt_applctx ;001
 
		if (curr_enc_id != prev_enc_id)
			i = i + 1
		endif
 
	 	if (mod(i,10) = 1 or i = 1)
	 		stat = alterlist(output->list, i + 9)
	 	endif
 
		output->list[i].facility	= rec->list[cnt].facility
		output->list[i].nurse_unit	= rec->list[cnt].nurse_unit
		output->list[i].pat_name 	= rec->list[cnt].pat_name
		output->list[i].birth_date	= rec->list[cnt].birth_date
		output->list[i].gender		= rec->list[cnt].gender
		output->list[i].fin			= rec->list[cnt].fin
		output->list[i].encntr_type	= rec->list[cnt].encntr_type
		output->list[i].admit_dt	= rec->list[cnt].admit_dt
 
		for (cecnt = 1 to rec->list[cnt].event_cnt)
 
		 	if (mod(cecnt,10) = 1 or cecnt = 1)
		 		stat = alterlist(rec->list[cnt].events, cecnt + 9)
		 	endif
 
			case (rec->list[cnt].events[cecnt].event_cd)
				of ANES_PRESENT_VAR			: output->list[i].first_anes 		= rec->list[cnt].events[cecnt].first_anes
				of ANES_PRESENT2_VAR		: output->list[i].second_anes 		= rec->list[cnt].events[cecnt].second_anes
				of ANES_TYPE_PROC_VAR		: output->list[i].anes_type 		= rec->list[cnt].events[cecnt].anes_type
				of BEDSIDE_PROC_TYPE_VAR	: output->list[i].bedside_proc_type = rec->list[cnt].events[cecnt].bedside_proc_type
				of FIRST_NURSE_VAR 			: output->list[i].first_nurse 		= rec->list[cnt].events[cecnt].first_nurse
				of SEC_NURSE_VAR			: output->list[i].second_nurse 		= rec->list[cnt].events[cecnt].second_nurse
				of PRE_DIAG_VAR				: output->list[i].pre_diag 			= rec->list[cnt].events[cecnt].pre_diag
				of POST_DIAG_VAR			: output->list[i].post_diag 		= rec->list[cnt].events[cecnt].post_diag
				of PROC_DONE_VAR			: output->list[i].proc_done 		= rec->list[cnt].events[cecnt].proc_done
				of PROC_LOC_VAR				: output->list[i].proc_loc 			= rec->list[cnt].events[cecnt].proc_loc
				of PROC_PERFORM_BY_VAR		: output->list[i].proc_performed_by	= rec->list[cnt].events[cecnt].proc_performed_by
				of PROC_START_VAR			: output->list[i].proc_start 		= rec->list[cnt].events[cecnt].proc_start
				of PROC_STOP_VAR			: output->list[i].proc_stop			= rec->list[cnt].events[cecnt].proc_stop
				of PROV_PRESENT_VAR			: output->list[i].provider			= rec->list[cnt].events[cecnt].provider
				of TECH_PRESENT_VAR			: output->list[i].first_tech		= rec->list[cnt].events[cecnt].first_tech
				of TECH_PRESENT2_VAR		: output->list[i].second_tech		= rec->list[cnt].events[cecnt].second_tech
				of BEDSIDE_PROC_VAR			: output->list[i].bedside_procedure	= rec->list[cnt].events[cecnt].bedside_procedure
				of CARDIAC_DX_VAR			: output->list[i].cardiac_dx		= rec->list[cnt].events[cecnt].cardiac_dx
				of OB_PROC_VAR				: output->list[i].ob_procedure		= rec->list[cnt].events[cecnt].ob_procedure
				of CORRECT_PATIENT_VAR		: output->list[i].correct_patient	= rec->list[cnt].events[cecnt].correct_patient
				of PROC_VERIFY_VAR			: output->list[i].procedure_verify	= rec->list[cnt].events[cecnt].procedure_verify
			endcase
 
			output->list[i].encntr_id	= rec->list[cnt].encntr_id
			output->list[i].event_id	= rec->list[cnt].event_id
			output->rec_cnt				= cnt
 
			prev_enc_id = rec->list[cnt].encntr_id
 		endfor
	endfor
 
foot report
	stat = alterlist(output->list, i)
 
with nocounter
 
call echorecord(output)
;go to exitscript
 
;CALL ECHO (BUILD2("END OF COPY RECORD STRUCTURE FOR OUTPUT "))
 
;====================================================
; REPORT OUTPUT
;====================================================
if (output->rec_cnt > 0)
 
	select into value ($OUTDEV)
		 facility     		= output->list[d.seq].facility
		,nurse_unit    		= substring(1,40,trim(output->list[d.seq].nurse_unit,3))
		,pat_name			= substring(1,40,trim(output->list[d.seq].pat_name,3))
		,birth_date			= format(output->list[d.seq].birth_date, "mm/dd/yyyy;;q")
		,gender				= output->list[d.seq].gender
		,fin				= output->list[d.seq].fin
		,encntr_type		= output->list[d.seq].encntr_type
		,admit_dt			= format(output->list[d.seq].admit_dt, "mm/dd/yyyy hh:mm;;q")
		,proc_type			= substring(1,100,trim(output->list[d.seq].bedside_proc_type,3))
		,bedside_procedure	= substring(1,40,trim(output->list[d.seq].bedside_procedure,3))
		,cardiac_dx	    	= substring(1,40,trim(output->list[d.seq].cardiac_dx,3))
		,ob_procedure   	= substring(1,40,trim(output->list[d.seq].ob_procedure,3))
		,proc_done			= substring(1,40,trim(output->list[d.seq].proc_done,3))
		,proc_start			= format(output->list[d.seq].proc_start, "mm/dd/yyyy hh:mm;;q")
		,proc_stop			= format(output->list[d.seq].proc_stop, "mm/dd/yyyy hh:mm;;q")
		,provider    		= substring(1,40,trim(output->list[d.seq].provider,3))
		,perform_by			= substring(1,40,trim(output->list[d.seq].proc_performed_by,3))
		,1st_anes    		= substring(1,40,trim(output->list[d.seq].first_anes,3))
		,2nd_anes    		= substring(1,40,trim(output->list[d.seq].second_anes,3))
		,proc_loc    		= substring(1,40,trim(output->list[d.seq].proc_loc,3))
		,1st_tech			= substring(1,40,trim(output->list[d.seq].first_tech,3))
		,2nd_tech			= substring(1,40,trim(output->list[d.seq].second_tech,3))
		,pre_diag			= substring(1,100,trim(output->list[d.seq].pre_diag,3))
		,post_diag			= substring(1,100,trim(output->list[d.seq].post_diag,3))
		,anes_type			= substring(1,40,trim(output->list[d.seq].anes_type,3))
		,1st_nurse    		= substring(1,40,trim(output->list[d.seq].first_nurse,3))
		,2nd_nurse    		= substring(1,40,trim(output->list[d.seq].second_nurse,3))
		,correct_patient   	= substring(1,40,trim(output->list[d.seq].correct_patient,3))
		,procedure_verify  	= substring(1,40,trim(output->list[d.seq].procedure_verify,3))
;		,encntr_id     		= output->list[d.seq].encntr_id
;		,event_id     		= output->list[d.seq].event_id
;		,username      		= output->username
;		,rec_cnt			= output->rec_cnt
;		,pmpt_date			= concat(rec->startdate," to ",rec->enddate)
 
	from (DUMMYT d with seq = value(size(output->list,5)))
 
	order by facility, nurse_unit, pat_name
 
	with nocounter, format, check, separator = " "
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
 
#exitscript
end
go
 

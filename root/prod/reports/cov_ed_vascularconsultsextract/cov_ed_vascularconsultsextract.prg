/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		October 2021
	Solution:			ED
	Source file name:  	cov_ed_vascularconsultsextract.prg
	Object name:		cov_ed_vascularconsultsextract
	CR#:				11392
 
	Program purpose:	Determine the number of consults that the ED calls to vascular.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_ed_vascularconsultsextract:DBA go
create program cov_ed_vascularconsultsextract:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Facility" = VALUE(0.00          )
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
record rec (
	1 rec_cnt								= i4
	1 username								= vc
	1 startdate								= vc
	1 enddate								= vc
	1 list[*]
		2 facility      					= vc
		2 nurse_unit    					= vc
		2 patient_name						= vc
		2 fin           					= vc
		2 encntr_id							= f8
		2 event_id							= f8
		2 event_cnt							= i4
		2 events[*]
			3 phone_call_1					= dq8
			3 phone_call_2					= dq8
			3 phone_call_3					= dq8
			3 reason_for_consult			= vc
			3 phy_requesting_consult		= vc
			3 phy_requested_consult			= vc
			3 phy_covering_for_consult		= vc
			3 date_time_call_returned		= dq8
			3 phy_returning_call			= vc
			3 consult_arrival_time			= dq8
			3 additional_info_call_consult	= vc
			3 poison_cntrl_contact_dt		= dq8
			3 consult_poison_cntrl			= vc
			3 encntr_id						= f8
			3 event_cd						= f8
			3 event_id						= f8
			3 dcp_forms_activity_id			= f8
			3 form_dt_tm					= dq8
	)
 
 
record output (
	1 rec_cnt								= i4
	1 username								= vc
	1 startdate								= vc
	1 enddate								= vc
	1 list[*]
		2 facility      					= vc
		2 nurse_unit    					= vc
		2 patient_name						= vc
		2 fin           					= vc
		2 phone_call_1						= dq8
		2 phone_call_2						= dq8
		2 phone_call_3						= dq8
		2 reason_for_consult				= vc
		2 phy_requesting_consult			= vc
		2 phy_requested_consult				= vc
		2 phy_covering_for_consult			= vc
		2 date_time_call_returned			= dq8
		2 phy_returning_call				= vc
		2 consult_arrival_time				= dq8
		2 additional_info_call_consult		= vc
		2 poison_cntrl_contact_dt			= dq8
		2 consult_poison_cntrl				= vc
		2 form_dt_tm						= dq8
		2 encntr_id							= f8
		2 event_id							= f8
		2 dcp_forms_activity_id				= f8
	)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare username           				= vc with protect
declare initcap()          				= c100
declare num				   				= i4 with noconstant(0)
;
declare ACTIVE_VAR 						= f8 with constant(uar_get_code_by("MEANING",8, "ACTIVE")),protect
declare AUTHVERIFIED_VAR 				= f8 with constant(uar_get_code_by("MEANING",8, "AUTH")),protect
declare ALTERED_VAR 					= f8 with constant(uar_get_code_by("MEANING",8, "ALTERED")),protect
declare MODIFIED_VAR	 				= f8 with constant(uar_get_code_by("MEANING",8, "MODIFIED")),protect
;
declare FIN_VAR            				= f8 with constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")),protect
declare ASSIST_PRSNL_VAR   				= f8 with constant(uar_get_code_by("DISPLAYKEY",21,"ASSIST")),protect
declare ADMIT_PHYS_VAR     				= f8 with constant(uar_get_code_by("DISPLAYKEY",333,"ADMITTINGPHYSICIAN")),protect
;
declare ACTIVE_STATUS_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")),protect
declare PLACEHOLDER_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY",53,"PLACEHOLDER")),protect
;
declare PHONE_CALL_ATTEMPT_1_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHONECALLATTEMPTONE")),protect
declare PHONE_CALL_ATTEMPT_2_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHONECALLATTEMPTTWO")),protect
declare PHONE_CALL_ATTEMPT_3_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHONECALLATTEMPTTHREE")),protect
declare REASON_FOR_CONSULT_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"REASONFORCONSULT")),protect
declare REQUESTING_CONSULT_FOR_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHYSICIANREQUESTINGCONSULT")),protect
declare PHY_REQUESTED_CONSULT_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHYSICIANREQUESTEDFORCONSULT")),protect
declare PHY_COVERING_FOR_CONSULT_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHYSICIANCOVERINGFORCONSULT")),protect
declare DATE_TIME_CALL_RETURNED_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"DATEANDTIMECALLRETURNED")),protect
declare PHY_RETURNING_CALL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHYSICIANRETURNINGCALL")),protect
declare CONSULT_ARRIVAL_TIME_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"EDCONSULTARRIVALTIME")),protect
declare ADDITIONAL_INFO_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"ADDITIONALINFORMATIONCALLFORCONSULT")),protect
declare POISON_CNTRL_CONTACT_DT_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"POISONCONTROLCONTACTDATEANDTIME")),protect
declare CONSULT_POISON_CNTRL_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"EDCONSULTWITHPOISONCONTROL")),protect
;
declare OPR_FAC_VAR		   				= vc with noconstant(fillstring(1000," "))
;
declare PROCEDURE_VAR   				= vc with noconstant(" ")
;
declare	START_DATE_VAR					= f8
declare END_DATE_VAR					= f8
 
declare prev_forms_id					= f8 with noconstant(0)
declare cur_forms_id					= f8 with noconstant(0)
 
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
set START_DATE_VAR = cnvtdatetime($START_DATETIME_PMPT)
set END_DATE_VAR   = cnvtdatetime($END_DATETIME_PMPT)
 
 
;SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATE_VAR, "mm/dd/yyyy;;q")
set rec->enddate   = format(END_DATE_VAR, "mm/dd/yyyy;;q")
 
 
;SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select into value ($OUTDEV)
	 facility 			= uar_get_code_display(e.loc_facility_cd)
	,nurse_unit 		= uar_get_code_display(e.loc_nurse_unit_cd)
	,patient_name	 	= initcap(p.name_full_formatted)
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = 1077 ;fin
;		and ea.alias = "5128800042"
		and ea.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id and ce.person_id = e.person_id
		and ce.event_end_dt_tm between cnvtdatetime(START_DATE_VAR) and cnvtdatetime(END_DATE_VAR)
		and ce.event_cd in (PHONE_CALL_ATTEMPT_1_VAR, PHONE_CALL_ATTEMPT_2_VAR,	PHONE_CALL_ATTEMPT_3_VAR,
			REASON_FOR_CONSULT_VAR, REQUESTING_CONSULT_FOR_VAR, PHY_REQUESTED_CONSULT_VAR,
			PHY_COVERING_FOR_CONSULT_VAR, DATE_TIME_CALL_RETURNED_VAR, PHY_RETURNING_CALL_VAR,
			CONSULT_ARRIVAL_TIME_VAR, ADDITIONAL_INFO_VAR,
			POISON_CNTRL_CONTACT_DT_VAR, CONSULT_POISON_CNTRL_VAR)
		and ce.record_status_cd = ACTIVE_STATUS_VAR ;188
		and ce.event_class_cd != PLACEHOLDER_VAR ;654645
		and ce.result_status_cd in (ACTIVE_VAR, AUTHVERIFIED_VAR, MODIFIED_VAR, ALTERED_VAR)
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(left join CE_DATE_RESULT cdr on cdr.event_id = ce.event_id
		and cdr.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 0"))
 
	,(inner join CLINICAL_EVENT ce2 on ce2.event_id = ce.parent_event_id)
 
	,(inner join DCP_FORMS_ACTIVITY_COMP dfac on dfac.parent_entity_id = ce2.parent_event_id)
 
	,(inner join DCP_FORMS_ACTIVITY dfa on dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id)
 
	,(inner join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
		and (dfa.form_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
		and elh.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
;	,(left join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
;		and cep.action_type_cd = ASSIST_PRSNL_VAR ;94
;		and cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(left join PRSNL pl on pl.person_id = ce.performed_prsnl_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pl.active_ind = 1)
 
;	,(left join PRSNL pl2 on pl2.person_id = cep.action_prsnl_id
;		and pl2.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
;		and pl2.active_ind = 1)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
;	and e.encntr_id =  126070150
	and e.active_ind = 1
 
order by facility, nurse_unit, patient_name, e.encntr_id, dfac.dcp_forms_activity_comp_id,
		if(ce.event_cd = PHONE_CALL_ATTEMPT_1_VAR) 				"A"
			elseif(ce.event_cd = PHONE_CALL_ATTEMPT_2_VAR) 		"B"
			elseif(ce.event_cd = PHONE_CALL_ATTEMPT_3_VAR) 		"C"
			elseif(ce.event_cd = REASON_FOR_CONSULT_VAR) 		"D"
			elseif(ce.event_cd = REQUESTING_CONSULT_FOR_VAR) 	"E"
			elseif(ce.event_cd = PHY_REQUESTED_CONSULT_VAR) 	"F"
			elseif(ce.event_cd = PHY_COVERING_FOR_CONSULT_VAR) 	"G"
			elseif(ce.event_cd = DATE_TIME_CALL_RETURNED_VAR) 	"H"
			elseif(ce.event_cd = PHY_RETURNING_CALL_VAR)		"I"
			elseif(ce.event_cd = CONSULT_ARRIVAL_TIME_VAR) 		"J"
			elseif(ce.event_cd = ADDITIONAL_INFO_VAR) 			"K"
			elseif(ce.event_cd = POISON_CNTRL_CONTACT_DT_VAR) 	"L"
			elseif(ce.event_cd = CONSULT_POISON_CNTRL_VAR)		"M"
		endif,
		ce.event_id
 
head report
	cnt = 0
 
head e.encntr_id
 
	cnt = cnt + 1
 
	;if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(rec->list, cnt)
	;endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility     = uar_get_code_display(elh.loc_facility_cd)
	rec->list[cnt].nurse_unit	= uar_get_code_display(elh.loc_nurse_unit_cd)
	rec->list[cnt].patient_name	= patient_name ;p.name_full_formatted
	rec->list[cnt].fin 			= ea.alias
	rec->list[cnt].encntr_id	= e.encntr_id
	rec->list[cnt].event_id		= ce.event_id
 
	cecnt = 0
 
head ce.event_id
 
	cecnt = cecnt + 1
 
 	;if (mod(cecnt,10) = 1 or cecnt = 1)
 		stat = alterlist(rec->list[cnt].events, cecnt)
 	;endif
 
	rec->list[cnt].event_cnt = cecnt
 
	case (ce.event_cd)
		of PHONE_CALL_ATTEMPT_1_VAR
				: rec->list[cnt].events[cecnt].phone_call_1 				= cdr.result_dt_tm
		of PHONE_CALL_ATTEMPT_2_VAR
				: rec->list[cnt].events[cecnt].phone_call_2 				= cdr.result_dt_tm
		of PHONE_CALL_ATTEMPT_3_VAR
				: rec->list[cnt].events[cecnt].phone_call_3					= cdr.result_dt_tm
		of REASON_FOR_CONSULT_VAR
				: rec->list[cnt].events[cecnt].reason_for_consult			= trim(replace(replace(ce.result_val, char(10), " "), char(13)," "))
		of REQUESTING_CONSULT_FOR_VAR
				: rec->list[cnt].events[cecnt].phy_requesting_consult 		= ce.result_val
		of PHY_REQUESTED_CONSULT_VAR
				: rec->list[cnt].events[cecnt].phy_requested_consult 		= ce.result_val
		of PHY_COVERING_FOR_CONSULT_VAR
				: rec->list[cnt].events[cecnt].phy_covering_for_consult 	= ce.result_val
		of DATE_TIME_CALL_RETURNED_VAR
				: rec->list[cnt].events[cecnt].date_time_call_returned		= cdr.result_dt_tm
		of PHY_RETURNING_CALL_VAR
				: rec->list[cnt].events[cecnt].phy_returning_call 			= ce.result_val
		of CONSULT_ARRIVAL_TIME_VAR
				: rec->list[cnt].events[cecnt].consult_arrival_time 		= cdr.result_dt_tm
		of ADDITIONAL_INFO_VAR
				: rec->list[cnt].events[cecnt].additional_info_call_consult	= trim(replace(replace(ce.result_val, char(10), " "), char(13)," "))
		of POISON_CNTRL_CONTACT_DT_VAR
				: rec->list[cnt].events[cecnt].poison_cntrl_contact_dt 		= cdr.result_dt_tm
		of CONSULT_POISON_CNTRL_VAR
				: rec->list[cnt].events[cecnt].consult_poison_cntrl			= ce.result_val
	endcase
 
	rec->list[cnt].events[cecnt].encntr_id				= ce.encntr_id
	rec->list[cnt].events[cecnt].event_cd				= ce.event_cd
	rec->list[cnt].events[cecnt].event_id				= ce.event_id
 	rec->list[cnt].events[cecnt].dcp_forms_activity_id 	= dfac.dcp_forms_activity_comp_id
 	rec->list[cnt].events[cecnt].form_dt_tm	 			= dfa.form_dt_tm
foot e.encntr_id
	stat = alterlist(rec->list[cnt].events, cecnt)
 
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
 
from (DUMMYT d with seq = 1)
 
plan d
 
head report
	cnt = 0
 	i = 0
	cecnt = 0
	cur_forms_id = 0
	prev_forms_id = 0
 
detail
	for (cnt = 1 to rec->rec_cnt)
		call echo(build2("cnt=",cnt))
 
 		for (cecnt = 1 to rec->list[cnt].event_cnt)
 			call echo(build2("cecnt=",cecnt))
 
			cur_forms_id = rec->list[cnt].events[cecnt].dcp_forms_activity_id
 
			call echo(build2("cur_forms_id=",cur_forms_id))
			call echo(build2("prev_forms_id=",prev_forms_id))
 
			if (cur_forms_id != prev_forms_id)
	 			i = i + 1
	 		endif
 
			call echo(build2("i=",i))
 
		 	stat = alterlist(output->list, i )
 
			output->list[i].facility		= rec->list[cnt].facility
			output->list[i].nurse_unit		= rec->list[cnt].nurse_unit
			output->list[i].patient_name	= rec->list[cnt].patient_name
			output->list[i].fin				= rec->list[cnt].fin
 
			case (rec->list[cnt].events[cecnt].event_cd)
				of PHONE_CALL_ATTEMPT_1_VAR
						: output->list[i].phone_call_1 					= rec->list[cnt].events[cecnt].phone_call_1
				of PHONE_CALL_ATTEMPT_2_VAR
						: output->list[i].phone_call_2 					= rec->list[cnt].events[cecnt].phone_call_2
				of PHONE_CALL_ATTEMPT_3_VAR
						: output->list[i].phone_call_3 					= rec->list[cnt].events[cecnt].phone_call_3
				of REASON_FOR_CONSULT_VAR
						: output->list[i].reason_for_consult 			= rec->list[cnt].events[cecnt].reason_for_consult
				of REQUESTING_CONSULT_FOR_VAR
						: output->list[i].phy_requesting_consult 		= rec->list[cnt].events[cecnt].phy_requesting_consult
				of PHY_REQUESTED_CONSULT_VAR
						: output->list[i].phy_requested_consult  		= rec->list[cnt].events[cecnt].phy_requested_consult
				of PHY_COVERING_FOR_CONSULT_VAR
						: output->list[i].phy_covering_for_consult  	= rec->list[cnt].events[cecnt].phy_covering_for_consult
				of DATE_TIME_CALL_RETURNED_VAR
						: output->list[i].date_time_call_returned  		= rec->list[cnt].events[cecnt].date_time_call_returned
				of PHY_RETURNING_CALL_VAR
						: output->list[i].phy_returning_call  			= rec->list[cnt].events[cecnt].phy_returning_call
				of CONSULT_ARRIVAL_TIME_VAR
						: output->list[i].consult_arrival_time  		= rec->list[cnt].events[cecnt].consult_arrival_time
				of ADDITIONAL_INFO_VAR
						: output->list[i].additional_info_call_consult	= rec->list[cnt].events[cecnt].additional_info_call_consult
				of POISON_CNTRL_CONTACT_DT_VAR
						: output->list[i].poison_cntrl_contact_dt		= rec->list[cnt].events[cecnt].poison_cntrl_contact_dt
				of CONSULT_POISON_CNTRL_VAR
						: output->list[i].consult_poison_cntrl 			= rec->list[cnt].events[cecnt].consult_poison_cntrl
			endcase
 
			output->list[i].encntr_id	= rec->list[cnt].encntr_id
			output->list[i].event_id	= rec->list[cnt].event_id
			output->list[i].dcp_forms_activity_id = rec->list[cnt].events[cecnt].dcp_forms_activity_id
			output->list[i].form_dt_tm = rec->list[cnt].events[cecnt].form_dt_tm
 
			output->rec_cnt				= cnt
 
 
			prev_forms_id = rec->list[cnt].events[cecnt].dcp_forms_activity_id
 		endfor
	endfor
 
foot report
	stat = alterlist(output->list, i)
 
;	output->rec_cnt		= rec->rec_cnt
	output->username	= rec->username
	output->startdate	= rec->startdate
	output->enddate		= rec->enddate
 
; 	output->rec_cnt = i
 
with nocounter
 
;call echorecord(output)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
if (output->rec_cnt > 0)
 
	select into value ($OUTDEV)
		 facility      								= substring(1,50,output->list[d.seq].facility)
		,nurse_unit									= substring(1,50,output->list[d.seq].nurse_unit)
		,patient_name								= substring(1,50,output->list[d.seq].patient_name)
		,fin										= substring(1,50,output->list[d.seq].fin)
		,form_dt_tm									= format(output->list[d.seq].form_dt_tm, "mm/dd/yyyy hh:mm;;q")
		,phone_call_attempt_one						= format(output->list[d.seq].phone_call_1, "mm/dd/yyyy hh:mm;;q")
		,phone_call_attempt_two						= format(output->list[d.seq].phone_call_2, "mm/dd/yyyy hh:mm;;q")
		,phone_call_attempt_three					= format(output->list[d.seq].phone_call_3, "mm/dd/yyyy hh:mm;;q")
		,reason_for_consult							= substring(1,50,output->list[d.seq].reason_for_consult)
		,physician_requesting_consult				= substring(1,50,output->list[d.seq].phy_requesting_consult)
		,physician_requested_for_consult			= substring(1,50,output->list[d.seq].phy_requested_consult)
		,physician_covering_for_consult				= substring(1,50,output->list[d.seq].phy_covering_for_consult)
		,date_and_time_call_returned				= format(output->list[d.seq].date_time_call_returned, "mm/dd/yyyy hh:mm;;q")
		,physician_returning_call					= substring(1,50,output->list[d.seq].phy_returning_call)
		,consult_arrival_time 						= format(output->list[d.seq].consult_arrival_time, "mm/dd/yyyy hh:mm;;q")
		,additional_information_call_for_consult	= substring(1,50,output->list[d.seq].additional_info_call_consult)
;		,poison_cntrl_contact_dt					= format(output->list[d.seq].poison_cntrl_contact_dt, "mm/dd/yyyy hh:mm;;q")
;		,consult_poison_cntrl						= substring(1,50,output->list[d.seq].consult_poison_cntrl)
;		,encntr_id     		= output->list[d.seq].encntr_id
;	;	,event_id			= output->list[d.seq].event_id
;;		,username      		= output->username
;;		,startdate_pmpt		= output->startdate
;;		,enddate_pmpt  		= output->enddate
;;		,rec_cnt	   		= output->rec_cnt
 
	from
		 (DUMMYT d  with seq = value(size(output->list,5)))
 
	plan d
 
 	;order by facility, patient_name
	with nocounter, format, check, separator = " "
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
 
 
#exitscript
 
call echorecord(rec)
call echorecord(output)
end
go
 
 

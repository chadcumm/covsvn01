/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		May 2022
	Solution:			Womens Health
	Source file name:  	cov_wh_ob_tipqc.prg
	Object name:		cov_wh_ob_tipqc
	CR#:				12724
 
	Program purpose:	TIPQC initiative to capture newborns who have had optimal
						cord clamping done at birth.
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
 
drop   program cov_wh_ob_tipqc:DBA go
create program cov_wh_ob_tipqc:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = VALUE(0.00          )
	, "" = 0
	, "" = 0
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	SUMMARY_DETAIL_PMPT, SUMMARY_OPT_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          			= vc
	1 startdate         			= vc
	1 enddate          	 			= vc
	1 monthyear						= vc
	1 encntr_cnt					= i4
	1 list[*]
		2 facility      			= c20
		2 nurse_unit				= vc
		2 pat_name      			= vc
		2 admit_dt					= dq8
		2 mrn           			= vc
		2 fin           			= vc
		2 age						= dq8
		2 dob						= dq8
		2 race						= vc
		2 ethnicity					= vc
		2 email						= vc
		2 address1					= vc
		2 address2					= vc
		2 city						= vc
		2 state						= vc
		2 zipcode					= vc
		2 birth_temp 				= vc
		2 apgar_score_5m 			= vc
		2 tm_umbilical_cc 			= vc
		2 apgar_missing_n_numr		= f8
		2 apgar_nonmissing_n_numr	= f8
		2 hypothermia_numr			= f8
		2 hypothermia_demr			= f8
		2 hypo_missing_n_numr		= f8
		2 hypo_nonmissing_n_numr	= f8
		2 gte_60sec_numr       		= f8
		2 gte_60sec_pct      		= f8
		2 lt_60sec_numr    			= f8
		2 lt_60sec_pct    			= f8
		2 null_60sec_numr			= f8
		2 null_60sec_pct			= f8
		2 eth_nonhispc_white_numr	= f8
		2 eth_nonhispc_white_demr	= f8
		2 eth_nonhispc_white_pct	= f8
		2 eth_nonhispc_black_numr	= f8
		2 eth_nonhispc_black_demr	= f8
		2 eth_nonhispc_black_pct	= f8
		2 eth_hispanic_numr			= f8
		2 eth_hispanic_demr			= f8
		2 eth_hispanic_pct			= f8
		2 eth_overall_numr			= f8
		2 eth_overall_demr			= f8
		2 eth_overall_pct			= f8
		2 eth_other_numr			= f8
		2 eth_other_demr			= f8
		2 neonate_outcome 			= vc
		2 delivery_type				= vc
		2 result_dt					= dq8
		2 preferred_lang 			= vc
		2 marital_status 			= vc
		2 arrival_mode	 			= vc
		2 visit_reason     			= vc
		2 primary_nurse				= vc
		2 attend_physician			= vc
		2 disposition				= vc
		2 encntr_type				= vc
		2 encntr_type_hist			= vc
		2 person_id					= f8
		2 encntr_id					= f8
		2 related_person_id			= f8
		2 pregnancy_id				= f8
		2 event_id					= f8
		2 baby_label				= vc
)
 
Record sum (
	1 username          			= vc
	1 startdate         			= vc
	1 enddate          	 			= vc
	1 monthyear						= vc
	1 encntr_cnt					= i4
	1 list[*]
		2 facility      			= vc
		2 apgar_missing_n_numr		= f8
		2 apgar_missing_n_pct		= f8
		2 apgar_nonmissing_n_numr	= f8
		2 apgar_nonmissing_n_pct	= f8
		2 apgar_score_demr			= f8
		2 hypothermia_numr			= f8
		2 hypothermia_demr			= f8
		2 hypothermia_pct			= f8
		2 hypo_missing_n_numr		= f8
		2 hypo_missing_n_pct		= f8
		2 hypo_nonmissing_n_numr	= f8
		2 hypo_nonmissing_n_pct		= f8
		2 gte_60sec_numr       		= f8
		2 gte_60sec_pct      		= f8
		2 lt_60sec_numr    			= f8
		2 lt_60sec_pct    			= f8
		2 null_60sec_numr			= f8
		2 null_60sec_pct			= f8
		2 60sec_demr       			= f8
		2 eth_nonhispc_white_numr	= f8
		2 eth_nonhispc_white_demr	= f8
		2 eth_nonhispc_white_pct	= f8
		2 eth_nonhispc_black_numr	= f8
		2 eth_nonhispc_black_demr	= f8
		2 eth_nonhispc_black_pct	= f8
		2 eth_hispanic_numr			= f8
		2 eth_hispanic_demr			= f8
		2 eth_hispanic_pct			= f8
		2 eth_overall_numr			= f8
		2 eth_overall_demr			= f8
		2 eth_overall_pct			= f8
		2 eth_other_numr			= f8
		2 eth_other_demr			= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR         	= f8 with constant(uar_get_code_by("DISPLAYKEY", 48, "ACTIVE")),protect
declare PLACE_HOLDER_VAR   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "PLACEHOLDER")),protect
declare FIN_TYPE_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY",319, "FINNBR")),protect
declare MRN_TYPE_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY",319, "MRN")),protect
declare CMRN_TYPE_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY",263, "CMRN")),protect
declare ATTEND_PHY_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",333, "ATTENDINGPHYSICIAN")),protect
declare PRIMARY_NURSE_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",333, "REGISTEREDNURSE")),protect
declare MOTHER_VAR       	= f8 with constant(uar_get_code_by("DISPLAYKEY", 40, "MOTHER")),protect
declare DISPOSITION_VAR		= F8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OBTRIAGEPATIENTDISPOSITION")),protect
declare ARRIVAL_MODE_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "MODEOFARRIVAL")),protect
declare BIRTH_TEMP_VAR		= F8 with constant(uar_get_code_by("DISPLAY"   , 72, "Birth Temperature:")),protect
declare APGAR_SCORE_5M_VAR	= f8 with constant(uar_get_code_by("DISPLAY"   , 72, "Apgar Score 5 Minute:")),protect
declare TM_UMBILICAL_CC_VAR = f8 with constant(uar_get_code_by("DISPLAY"   , 72, "Time Umbilical Cord Clamped:")),protect
declare NEONATE_OUTCOME_VAR	= f8 with constant(uar_get_code_by("DISPLAY"   , 72, "Neonate Outcome:")),protect
declare DELV_TYPE_VAR 		= f8 with constant(uar_get_code_by("DISPLAY"   , 72, "Delivery Type:")),protect
declare VISIT_REASON_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "REASONFORVISITOB")),protect
declare LIVE_BIRTH_VAR 		= f8 with constant(uar_get_code_by("DISPLAYKEY",4002121, "LIVEBIRTH")),protect
declare OP_MONITOR_VAR 	   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTMONITORING")),protect
declare INPATIENT_VAR 	   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT")),protect
declare OBSERVATION_VAR	   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION")),protect
declare ETH_WHITE_VAR	   	= f8 with constant(uar_get_code_by("DISPLAYKEY",282, "WHITE")),protect
declare ETH_BLACK_VAR	   	= f8 with constant(uar_get_code_by("DISPLAYKEY",282, "BLACKORAFRICANAMERICAN")),protect
declare NONHISPANIC_VAR	   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 27, "NOTHISPANICLATINOORSPANISHORIGIN")),protect
declare HISPANIC_VAR	   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 27, "HISPANICLATINOORSPANISHORIGIN")),protect
;
declare NU_FSR_6N_VAR  		= f8 with constant(uar_get_code_by("DESCRIPTION",220, "FSR 6N OB/GYN UNIT")),protect
declare NU_FSR_7N_VAR  		= f8 with constant(uar_get_code_by("DESCRIPTION",220, "FSR 7N PULMONARY UNIT")),protect
declare NU_FSR_LD_VAR  		= f8 with constant(uar_get_code_by("DESCRIPTION",220, "FSR LABOR & DELIVERY UNIT")),protect
declare NU_CMC_LD_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "CMCLD")),protect
declare NU_FSR_6W_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FSR6W")),protect
declare NU_FSR_6E_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FSR6E")),protect
declare NU_LCM_COB_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "LCMCOB")),protect
declare NU_MHHS_LD_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MHHSLD")),protect
declare NU_MMC_FBC_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MMCFBC")),protect
declare NU_PW_CB_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PWCB")),protect
;
declare AUTH_VAR   			= f8 with constant(uar_get_code_by("DESCRIPTION",  8, "Auth (Verified)")),protect
declare MODIFIED_VAR 		= f8 with constant(uar_get_code_by("DESCRIPTION",  8, "Modified/Amended/Corrected")),protect
declare ALTERED_VAR   		= f8 with constant(uar_get_code_by("DESCRIPTION",  8, "Modified/Amended/Cor")),protect
;
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
;
declare username           	= vc with protect
declare initcap()          	= c100
;
declare cnt  				= i4 with noconstant(0),protect
declare idx  				= i4 with noconstant(0),protect
declare num					= i4 with noconstant(0),protect
declare baby_label			= vc
 
;
declare	START_DATETIME		= f8
declare END_DATETIME		= f8
 
;go to exitscript
 
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
set START_DATETIME = cnvtdatetime($START_DATETIME_PMPT)
set END_DATETIME   = cnvtdatetime($END_DATETIME_PMPT)
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME = cnvtdatetime("01-JUN-2022 00:00:00")
;set END_DATETIME   = cnvtdatetime("30-JUN-2022 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME, "mm/dd/yyyy;;q") 	;substring(1,11,$START_DATETIME_PMPT)
set rec->enddate   = format(END_DATETIME, "mm/dd/yyyy;;q") 		;substring(1,11,$END_DATETIME_PMPT)
set rec->monthyear = format(END_DATETIME, "mm/yyyy;;q")
set sum->startdate = format(START_DATETIME, "mm/dd/yyyy;;q") 	;substring(1,11,$START_DATETIME_PMPT)
set sum->enddate   = format(END_DATETIME, "mm/dd/yyyy;;q") 		;substring(1,11,$END_DATETIME_PMPT)
set sum->monthyear = format(END_DATETIME, "mm/yyyy;;q")
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
call echo(build("*** MAIN DATA SELECT ***"))
select into "NL:"
 
from ENCOUNTER e
 
	,(inner join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
		and elh.active_ind = 1)
 
	,(inner join CLINICAL_EVENT cevent on cevent.encntr_id = e.encntr_id
		and cevent.event_cd = NEONATE_OUTCOME_VAR ;   17022168
		and cevent.result_val = "Live birth"
		and (cevent.event_end_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME))
		and cevent.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
		and cevent.event_tag != "Date\Time Correction"
;		and cevent.event_class_cd != PLACE_HOLDER_VAR ;654645.00
		and cevent.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(inner join CE_DYNAMIC_LABEL cdl on cdl.ce_dynamic_label_id = cevent.ce_dynamic_label_id
		and cdl.ce_dynamic_label_id > 0.0)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.ce_dynamic_label_id = cdl.ce_dynamic_label_id
		and ce.event_cd in (APGAR_SCORE_5M_VAR, BIRTH_TEMP_VAR, ARRIVAL_MODE_VAR,
			TM_UMBILICAL_CC_VAR, VISIT_REASON_VAR, DISPOSITION_VAR, DELV_TYPE_VAR)
			;16865976, 4214816981, 17022168, 712635, 4161291, 2907458607
		and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
		and ce.event_tag != "Date\Time Correction"
;		and ce.event_class_cd != PLACE_HOLDER_VAR ;654645.00
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(left join CE_DATE_RESULT cdr on cdr.event_id = ce.event_id
		and cdr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
;	,(left join ENCNTR_PRSNL_RELTN epr1 on epr1.encntr_id = e.encntr_id
;		and epr1.encntr_prsnl_r_cd = PRIMARY_NURSE_VAR ;1125
;		and epr1.active_ind = 1)
 
;	,(left join PRSNL pl1 on pl1.person_id = epr1.prsnl_person_id ;primary nurse
;		and pl1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
;		and pl1.active_ind = 1)
 
	,(left join ENCNTR_PRSNL_RELTN epr2 on epr2.encntr_id = e.encntr_id
		and epr2.encntr_prsnl_r_cd = ATTEND_PHY_VAR ;1119
		and epr2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and epr2.active_ind = 1)
 
	,(left join PRSNL pl2 on pl2.person_id = epr2.prsnl_person_id ;attending physician
		and pl2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl2.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = ce.person_id
		and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
;		and p.person_id =    16360207.00
		and p.active_ind = 1)
 
	,(inner join PERSON_PERSON_RELTN ppr on ppr.related_person_id = p.person_id
;		and ppr.person_reltn_cd = MOTHER_VAR ;156
		and ppr.active_ind = 1)
 
	,(inner join PREGNANCY_INSTANCE pi on pi.person_id = ppr.related_person_id
;		and ((cdr.result_dt_tm between pi.preg_start_dt_tm and pi.preg_end_dt_tm))
		and ((e.reg_dt_tm between pi.preg_start_dt_tm and pi.preg_end_dt_tm))
		and pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pi.active_ind = 1)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
;	and e.loc_nurse_unit_cd in (NU_CMC_LD_VAR, NU_FSR_6E_VAR, NU_FSR_6N_VAR, NU_FSR_6W_VAR,
;		NU_FSR_7N_VAR, NU_FSR_LD_VAR, NU_LCM_COB_VAR, NU_MHHS_LD_VAR, NU_MMC_FBC_VAR, NU_PW_CB_VAR)
	and e.reg_dt_tm is not null
	and e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and e.active_ind = 1
 
order by e.encntr_id, cdl.label_name, cevent.event_cd, cevent.event_end_dt_tm desc;, pi.pregnancy_id
 
head report
	cnt = 0
 
head e.encntr_id
	null
 
head cdl.label_name
	null
 
head cevent.event_cd
	cnt = cnt + 1
 
	stat = alterlist(rec->list,cnt)
 
detail
 	rec->encntr_cnt = cnt
 
	rec->list[cnt].facility				= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit			= uar_get_code_display(e.loc_nurse_unit_cd)
	rec->list[cnt].pat_name      		= p.name_full_formatted
;	rec->list[cnt].age					= p.birth_dt_tm
;	rec->list[cnt].dob					= p.birth_dt_tm
	rec->list[cnt].race					= uar_get_code_display(p.race_cd)
	rec->list[cnt].ethnicity			= uar_get_code_display(p.ethnic_grp_cd)
	rec->list[cnt].admit_dt				= e.reg_dt_tm
;	rec->list[cnt].primary_nurse		= pl1.name_full_formatted
	rec->list[cnt].attend_physician		= pl2.name_full_formatted
	rec->list[cnt].baby_label			= cdl.label_name
;	rec->list[cnt].encntr_type			= uar_get_code_display(e.encntr_type_cd)
;	rec->list[cnt].encntr_type_hist		= uar_get_code_display(elh.encntr_type_cd)
 	rec->list[cnt].person_id			= p.person_id
 	rec->list[cnt].encntr_id	 		= e.encntr_id
 	rec->list[cnt].event_id				= ce.event_id
 	rec->list[cnt].pregnancy_id			= pi.pregnancy_id
 	rec->list[cnt].related_person_id	= ppr.related_person_id
 
	case (ce.event_cd)
		of ARRIVAL_MODE_VAR		: rec->list[cnt].arrival_mode    = ce.result_val
		OF DELV_TYPE_VAR		: rec->list[cnt].delivery_type	 = ce.result_val
		of VISIT_REASON_VAR 	: rec->list[cnt].visit_reason	 = ce.result_val
		of DISPOSITION_VAR		: rec->list[cnt].disposition	 = ce.result_val
		of BIRTH_TEMP_VAR		: rec->list[cnt].birth_temp		 = ce.result_val
		of APGAR_SCORE_5M_VAR	: rec->list[cnt].apgar_score_5m	 = ce.result_val
		of TM_UMBILICAL_CC_VAR	: rec->list[cnt].tm_umbilical_cc = ce.result_val
;		of NEONATE_OUTCOME_VAR	: rec->list[cnt].neonate_outcome = ce.result_val
	endcase
 
	if (NEONATE_OUTCOME_VAR = 17022168.00) rec->list[cnt].neonate_outcome = cevent.result_val endif
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;------------------------------------------------
;GET DETAIL COUNTS
;------------------------------------------------
for (cnt = 1 to size(rec->list, 5))
	;APGAR_SCORE_5M
	if(rec->list[cnt].apgar_score_5m = "")
		set rec->list[cnt].apgar_missing_n_numr = 1
	elseif(rec->list[cnt].apgar_score_5m != "")
		if(cnvtint(rec->list[cnt].apgar_score_5m) <= 3)
			set rec->list[cnt].apgar_nonmissing_n_numr = 1
		endif
	endif
 
	;TM UMBILICAL CLAMPING COUNT/PERCENTAGE
	if(rec->list[cnt].tm_umbilical_cc = ">/= 60 seconds")
		set rec->list[cnt].gte_60sec_numr = 1
	elseif(rec->list[cnt].tm_umbilical_cc = "< 60 seconds")
		set rec->list[cnt].lt_60sec_numr = 1
	elseif(rec->list[cnt].tm_umbilical_cc = "")
		set rec->list[cnt].null_60sec_numr = 1
	endif
 
	;HYPOTHERMIA
	if(rec->list[cnt].birth_temp = "")
		set rec->list[cnt].hypo_missing_n_numr = 1
	elseif(rec->list[cnt].birth_temp != "" and rec->list[cnt].birth_temp < "36.5")
		set rec->list[cnt].hypo_nonmissing_n_numr = 1
	else
		set rec->list[cnt].hypo_missing_n_numr = 1
	endif
 
	;NON-HISPANIC WHITE
	if(rec->list[cnt].race = "White" and rec->list[cnt].ethnicity = "Not Hispanic, Latino, or Spanish Origin")
		if(rec->list[cnt].tm_umbilical_cc = ">/= 60 seconds")
			set rec->list[cnt].eth_nonhispc_white_numr = 1
		endif
	endif
 
	;NON-HISPANIC BLACK
	if(rec->list[cnt].race="Black or African American" and rec->list[cnt].ethnicity="Not Hispanic, Latino, or Spanish Origin")
		if(rec->list[cnt].tm_umbilical_cc = ">/= 60 seconds")
			set rec->list[cnt].eth_nonhispc_black_numr = 1
		endif
	endif
 
	;HISPANIC
	if(rec->list[cnt].ethnicity = "Hispanic, Latino, or Spanish Origin")
		if(rec->list[cnt].tm_umbilical_cc = ">/= 60 seconds")
			set rec->list[cnt].eth_hispanic_numr = 1
		endif
	endif
 
	;OTHER
	if(rec->list[cnt].race != "White" and rec->list[cnt].race != "Black or African American")
		if(rec->list[cnt].tm_umbilical_cc = ">/= 60 seconds")
			set rec->list[cnt].eth_other_numr = 1
		endif
	endif
 
	;OVERALL
	set rec->list[cnt].eth_overall_numr =
		(rec->list[cnt].eth_nonhispc_white_numr + rec->list[cnt].eth_nonhispc_black_numr
			+ rec->list[cnt].eth_hispanic_numr + rec->list[cnt].eth_other_numr)
endfor
 
 
;============================================================================
; GET PERSON & ENCOUNTER ALIAS'S: FIN, MRN, CMRN
;============================================================================
call echo(build("*** GET PERSON & ENCOUNTER ALIAS'S DATA ***"))
select into "NL:"
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_TYPE_VAR   ;1079
		and ea2.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea2.active_ind = 1)
 
	,(left join PERSON_ALIAS pa on pa.person_id = e.person_id
		and pa.person_alias_type_cd = CMRN_TYPE_VAR    ;263
		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and pa.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), e.encntr_id, rec->list[num].encntr_id)
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and e.active_ind = 1
 
detail
	cnt = 0
	idx = 0
 
	idx = locateval(cnt, 1, size(rec->list,5), e.encntr_id, rec->list[cnt].encntr_id)
 
	while (idx > 0)
		rec->list[idx].fin  = ea.alias	;fin
		rec->list[idx].mrn  = ea2.alias	;mrn
;		rec->list[idx].cmrn = pa.alias	;cmrn
 
		idx = locateval(cnt, idx+1, size(rec->list,5), e.encntr_id, rec->list[cnt].encntr_id)
	endwhile
 
with nocounter, expand = 2
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; SUMMARY - MISSING/NONMISSING N APGAR_SCORE_5M COUNT/PERCENTAGE
;==============================================================================
call echo(build("*** MISSING/NONMISSING N APGAR_SCORE_5M COUNT/PERCENTAGE ***"))
select into "NL:"
 	 facility = rec->list[d.seq].facility
 
from (DUMMYT d with seq = value(size(rec->list, 5)))
 
order by facility
 
head report
	cnt = 0
 
head facility
	cnt = cnt + 1
 
	stat = alterlist(sum->list,cnt)
 
	sum->list[cnt].apgar_score_demr = 0
	sum->list[cnt].facility = facility
 
detail
	if(rec->list[d.seq].apgar_score_5m = "")
		sum->list[cnt].apgar_missing_n_numr += 1
	elseif(rec->list[d.seq].apgar_score_5m != "" and cnvtint(rec->list[d.seq].apgar_score_5m) <= 3)
		sum->list[cnt].apgar_nonmissing_n_numr += 1
	endif
 
	if(rec->list[d.seq].neonate_outcome = "Live birth")
		sum->list[cnt].apgar_score_demr += 1
	endif
 
foot facility
	sum->list[cnt].apgar_missing_n_pct		= ((sum->list[cnt].apgar_missing_n_numr / sum->list[cnt].apgar_score_demr) * 100)
	sum->list[cnt].apgar_nonmissing_n_pct 	= ((sum->list[cnt].apgar_nonmissing_n_numr / sum->list[cnt].apgar_score_demr) * 100)
 
;	call echo(build2("facility                 = ", sum->list[cnt].facility))
;	call echo(build2("facility_demr            = ", format(sum->list[cnt].apgar_score_demr,";L")))
;	call echo(build2("apgar_missing_n_numr           = ", format(sum->list[cnt].apgar_missing_n_numr,";L")))
;	call echo(build2("apgar_missing_n_pct            = ", format(sum->list[cnt].apgar_missing_n_pct, "###.##%;L")))
;	call echo(build2("apgar_nonmissing_n_numr        = ", format(sum->list[cnt].apgar_nonmissing_n_numr,";L")))
;	call echo(build2("apgar_nonmissing_n_pct         = ", format(sum->list[cnt].apgar_nonmissing_n_pct, "###.##%;L")))
 
with nocounter
 
;call echorecord(rec)
;call echorecord(sum)
;go to exitscript
 
 
;==============================================================================
; SUMMARY - HYPOTHERMIA COUNT/PERCENTAGE
;==============================================================================
call echo(build("*** HYPOTHERMIA COUNT/PERCENTAGE ***"))
select into "NL:"
 	 facility = rec->list[d.seq].facility
 
from (DUMMYT d with seq = value(size(rec->list, 5)))
	,(DUMMYT d2 with seq = value(size(sum->list, 5)))
 
plan d
join d2 where rec->list[d.seq].facility = sum->list[d2.seq].facility
 
order by facility
 
head facility
	sum->list[d2.seq].hypothermia_demr = 0
	sum->list[d2.seq].facility = facility
 
detail
	if(rec->list[d.seq].birth_temp = "")
		sum->list[d2.seq].hypo_missing_n_numr += 1
	elseif(rec->list[d.seq].birth_temp != "" and rec->list[d.seq].birth_temp < "36.5")
		sum->list[d2.seq].hypo_nonmissing_n_numr += 1
	endif
 
	if(rec->list[d.seq].neonate_outcome = "Live birth")
		sum->list[d2.seq].hypothermia_demr += 1
	endif
 
foot facility
	sum->list[d2.seq].hypo_missing_n_pct	= ((sum->list[d2.seq].hypo_missing_n_numr / sum->list[d2.seq].hypothermia_demr) * 100)
	sum->list[d2.seq].hypo_nonmissing_n_pct = ((sum->list[d2.seq].hypo_nonmissing_n_numr / sum->list[d2.seq].hypothermia_demr) * 100)
	sum->list[d2.seq].hypothermia_pct 	 	= (((sum->list[d2.seq].hypo_missing_n_numr + sum->list[d2.seq].hypo_nonmissing_n_numr)
													/ sum->list[d2.seq].hypothermia_demr) * 100)
 
;	call echo(build2("facility                 = ", sum->list[d2.seq].facility))
;	call echo(build2("hypothermia_demr         = ", format(sum->list[d2.seq].hypothermia_demr,";L")))
;	call echo(build2("hypothermia_numr         = ", format(sum->list[d2.seq].hypothermia_numr,";L")))
;	call echo(build2("hypothermia_pct          = ", format(sum->list[d2.seq].hypothermia_pct, "###.##%;L")))
 
with nocounter
 
;call echorecord(rec)
;call echorecord(sum)
;go to exitscript
 
 
;==============================================================================
; SUMMARY - TM UMBILICAL CLAMPING COUNT/PERCENTAGE
;==============================================================================
call echo(build("*** GET TM UMBILICAL CLAMPING COUNT/PERCENTAGE ***"))
select into "NL:"
 	facility = rec->list[d.seq].facility
 
from (DUMMYT d  with seq = value(size(rec->list, 5)))
	,(DUMMYT d2 with seq = value(size(sum->list, 5)))
 
plan d
join d2 where rec->list[d.seq].facility = sum->list[d2.seq].facility
 
order by facility
 
head facility
	sum->list[d2.seq].60sec_demr = 0
	sum->list[d2.seq].facility = facility
 
detail
	if(rec->list[d.seq].tm_umbilical_cc = ">/= 60 seconds")
		sum->list[d2.seq].gte_60sec_numr += 1
	elseif(rec->list[d.seq].tm_umbilical_cc = "< 60 seconds")
		sum->list[d2.seq].lt_60sec_numr += 1
	elseif(rec->list[d.seq].tm_umbilical_cc = "")
		sum->list[d2.seq].null_60sec_numr += 1
	endif
 
	if(rec->list[d.seq].neonate_outcome = "Live birth")
		sum->list[d2.seq].60sec_demr += 1
	endif
 
foot facility
	sum->list[d2.seq].gte_60sec_pct  = ((sum->list[d2.seq].gte_60sec_numr / sum->list[d2.seq].60sec_demr) * 100)
	sum->list[d2.seq].lt_60sec_pct   = ((sum->list[d2.seq].lt_60sec_numr / sum->list[d2.seq].60sec_demr) * 100)
	sum->list[d2.seq].null_60sec_pct = ((sum->list[d2.seq].null_60sec_numr / sum->list[d2.seq].60sec_demr) * 100)
 
;	call echo(build2("facility                 = ", sum->list[d2.seq].facility))
;	call echo(build2("facility_demr            = ", format(sum->list[d2.seq].60sec_demr,";L")))
;	call echo(build2("gte_60sec_numr           = ", format(sum->list[d2.seq].gte_60sec_numr, ";L")))
;	call echo(build2("gte_60sec_pct            = ", format(sum->list[d2.seq].gte_60sec_pct, "###.##%;L")))
;	call echo(build2("lt_60sec_numr            = ", format(sum->list[d2.seq].lt_60sec_numr,";L")))
;	call echo(build2("lt_60sec_pct             = ", format(sum->list[d2.seq].lt_60sec_pct, "###.##%;L")))
;	call echo(build2("null_60sec_numr          = ", format(sum->list[d2.seq].null_60sec_numr,";L")))
;	call echo(build2("null_60sec_pct           = ", format(sum->list[d2.seq].null_60sec_pct, "###.##%;L")))
 
with nocounter
 
;call echorecord(rec)
;call echorecord(sum)
;go to exitscript
 
 
;==============================================================================
; SUMMARY - ETHNICITY COUNT/PERCENTAGE
;==============================================================================
call echo(build("*** GET ETHNICITY COUNT/PERCENTAGE ***"))
select into "NL:"
 	facility = rec->list[d.seq].facility
 
from (DUMMYT d  with seq = value(size(rec->list, 5)))
	,(DUMMYT d2 with seq = value(size(sum->list, 5)))
 
plan d
join d2 where rec->list[d.seq].facility = sum->list[d2.seq].facility
 
order by facility
 
head facility
	null
 
detail
	sum->list[d2.seq].facility = facility
 
	;NON-HISPANIC WHITE
	if(rec->list[d.seq].race = "White" and rec->list[d.seq].ethnicity = "Not Hispanic, Latino, or Spanish Origin")
		if(rec->list[d.seq].tm_umbilical_cc = ">/= 60 seconds")
			sum->list[d2.seq].eth_nonhispc_white_numr += 1
		endif
		if(rec->list[d.seq].neonate_outcome = "Live birth")
			sum->list[d2.seq].eth_nonhispc_white_demr += 1
		endif
 
	;NON-HISPANIC BLACK
	elseif(rec->list[d.seq].race="Black or African American" and rec->list[d.seq].ethnicity="Not Hispanic, Latino, or Spanish Origin")
		if(rec->list[d.seq].tm_umbilical_cc = ">/= 60 seconds")
			sum->list[d2.seq].eth_nonhispc_black_numr += 1
		endif
		if(rec->list[d.seq].neonate_outcome = "Live birth")
			sum->list[d2.seq].eth_nonhispc_black_demr += 1
		endif
 
	;HISPANIC
	elseif(rec->list[d.seq].ethnicity = "Hispanic, Latino, or Spanish Origin")
		if(rec->list[d.seq].tm_umbilical_cc = ">/= 60 seconds")
			sum->list[d2.seq].eth_hispanic_numr += 1
		endif
		if(rec->list[d.seq].neonate_outcome = "Live birth")
			sum->list[d2.seq].eth_hispanic_demr += 1
		endif
 
	;OTHER ;Not White or Black/African American Race
	elseif(rec->list[d.seq].race != "White" or rec->list[d.seq].race != "Black or African American")
		if(rec->list[d.seq].tm_umbilical_cc = ">/= 60 seconds")
			sum->list[d2.seq].eth_other_numr += 1
		endif
		if(rec->list[d.seq].neonate_outcome = "Live birth")
			sum->list[d2.seq].eth_other_demr += 1
		endif
	endif
 
	;OVERALL
	sum->list[d2.seq].eth_overall_numr =
		(sum->list[d2.seq].eth_nonhispc_white_numr + sum->list[d2.seq].eth_nonhispc_black_numr + sum->list[d2.seq].eth_hispanic_numr
			+ sum->list[d2.seq].eth_other_numr)
	sum->list[d2.seq].eth_overall_demr =
		(sum->list[d2.seq].eth_nonhispc_white_demr + sum->list[d2.seq].eth_nonhispc_black_demr + sum->list[d2.seq].eth_hispanic_demr
			+ sum->list[d2.seq].eth_other_demr)
 
foot facility
	if(sum->list[d2.seq].eth_nonhispc_white_demr > 0)
		sum->list[d2.seq].eth_nonhispc_white_pct =
			((sum->list[d2.seq].eth_nonhispc_white_numr / sum->list[d2.seq].eth_nonhispc_white_demr) * 100)
	endif
	if(sum->list[d2.seq].eth_nonhispc_black_demr > 0)
		sum->list[d2.seq].eth_nonhispc_black_pct =
			((sum->list[d2.seq].eth_nonhispc_black_numr / sum->list[d2.seq].eth_nonhispc_black_demr) * 100)
	endif
	if(sum->list[d2.seq].eth_hispanic_demr > 0)
		sum->list[d2.seq].eth_hispanic_pct
			= ((sum->list[d2.seq].eth_hispanic_numr / sum->list[d2.seq].eth_hispanic_demr) * 100)
	endif
	if(sum->list[d2.seq].eth_overall_demr > 0)
		sum->list[d2.seq].eth_overall_pct
			= ((sum->list[d2.seq].eth_overall_numr / sum->list[d2.seq].eth_overall_demr) * 100)
 	endif
 
;	call echo(build2("facility                 = ", sum->list[d2.seq].facility))
;	call echo(build2("eth_nonhispc_white_numr  = ", format(sum->list[d2.seq].eth_nonhispc_white_numr, ";L")))
;	call echo(build2("eth_nonhispc_white_demr  = ", format(sum->list[d2.seq].eth_nonhispc_white_demr, ";L")))
;	call echo(build2("eth_nonhispc_white_pct   = ", format(sum->list[d2.seq].eth_nonhispc_white_pct, "###.##%;L")))
;	call echo(build2("eth_nonhispc_black_numr  = ", format(sum->list[d2.seq].eth_nonhispc_black_numr,";L")))
;	call echo(build2("eth_nonhispc_black_demr  = ", format(sum->list[d2.seq].eth_nonhispc_black_demr,";L")))
;	call echo(build2("eth_nonhispc_black_pct   = ", format(sum->list[d2.seq].eth_nonhispc_black_pct, "###.##%;L")))
;	call echo(build2("eth_overall_numr         = ", format(sum->list[d2.seq].eth_overall_numr,";L")))
;	call echo(build2("eth_overall_demr         = ", format(sum->list[d2.seq].eth_overall_demr,";L")))
;	call echo(build2("eth_overall_pct          = ", format(sum->list[d2.seq].eth_overall_pct, "###.##%;L")))
 
with nocounter
 
call echorecord(rec)
call echorecord(sum)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
if($SUMMARY_DETAIL_PMPT = 0)
 
	;SUMMARY
	if($SUMMARY_OPT_PMPT = 0)
 
		;ETHNICITY
		select distinct into value ($OUTDEV)
			 facility					= substring(1,10,sum->list[d.seq].facility)
			,start_dt					= sum->startdate
			,end_dt						= sum->enddate
			,month_year					= sum->monthyear
			,eth_overall_numr			= substring(1,10,format(sum->list[d.seq].eth_overall_numr, ";L"))
			,eth_overall_demr			= substring(1,10,format(sum->list[d.seq].eth_overall_demr, ";L"))
			,eth_overall_pct			= substring(1,10,format(sum->list[d.seq].eth_overall_pct, "###.##%;L"))
			,eth_nonhispc_white_numr	= substring(1,10,format(sum->list[d.seq].eth_nonhispc_white_numr, ";L"))
			,eth_nonhispc_white_demr	= substring(1,10,format(sum->list[d.seq].eth_nonhispc_white_demr, ";L"))
			,eth_nonhispc_white_pct		= substring(1,10,format(sum->list[d.seq].eth_nonhispc_white_pct, "###.##%;L"))
			,eth_nonhispc_black_numr	= substring(1,10,format(sum->list[d.seq].eth_nonhispc_black_numr, ";L"))
			,eth_nonhispc_black_demr	= substring(1,10,format(sum->list[d.seq].eth_nonhispc_black_demr, ";L"))
			,eth_nonhispc_black_pct		= substring(1,10,format(sum->list[d.seq].eth_nonhispc_black_pct, "###.##%;L"))
			,eth_hispanic_numr			= substring(1,10,format(sum->list[d.seq].eth_hispanic_numr, ";L"))
			,eth_hispanic_demr			= substring(1,10,format(sum->list[d.seq].eth_hispanic_demr, ";L"))
			,eth_hispanic_pct			= substring(1,10,format(sum->list[d.seq].eth_hispanic_pct, "###.##%;L"))
 
		from
			 (DUMMYT d  with seq = value(size(sum->list,5)))
 
		plan d
 
		order by facility, start_dt
 
		with nocounter, format, check, separator = " "
 
 	elseif($SUMMARY_OPT_PMPT = 1)
 
 		;MISSING/NON-MISSING N (Apgar)
		select distinct into value ($OUTDEV)
			 facility				= substring(1,10,sum->list[d.seq].facility)
			,start_dt				= sum->startdate
			,end_dt					= sum->enddate
			,month_year				= sum->monthyear
			,apgar_missing_n		= substring(1,10,format(sum->list[d.seq].apgar_missing_n_numr,";L"))
			,apgar_non_missing_n	= substring(1,10,format(sum->list[d.seq].apgar_nonmissing_n_numr, ";L"))
			,denominator			= substring(1,10,format(sum->list[d.seq].apgar_score_demr, ";L"))
			,pct_missing			= substring(1,10,format(sum->list[d.seq].apgar_missing_n_pct, "###.##%;L"))
			,pct_5min_APGAR_lte3	= substring(1,10,format(sum->list[d.seq].apgar_nonmissing_n_pct, "###.##%;L"))
 
		from (DUMMYT d  with seq = value(size(sum->list,5)))
 
		plan d
 
		order by facility, start_dt
 
		with nocounter, format, check, separator = " "
 
 	elseif($SUMMARY_OPT_PMPT = 2)
 
 		;HYPOTHERMIA
		select distinct into value ($OUTDEV)
			 facility				= substring(1,10,sum->list[d.seq].facility)
			,start_dt				= sum->startdate
			,end_dt					= sum->enddate
			,month_year				= sum->monthyear
;			,hypothermia_numr		= substring(1,10,format(sum->list[d.seq].hypothermia_numr,";L"))
			,hypo_missing_n			= substring(1,10,format(sum->list[d.seq].hypo_missing_n_numr,";L"))
			,hypo_non_missing_n		= substring(1,10,format(sum->list[d.seq].hypo_nonmissing_n_numr, ";L"))
			,denominator			= substring(1,10,format(sum->list[d.seq].hypothermia_demr, ";L"))
			,pct_missing			= substring(1,10,format(sum->list[d.seq].hypo_missing_n_pct, "###.##%;L"))
;			,pct_nonmissing			= substring(1,10,format(sum->list[d.seq].hypo_nonmissing_n_pct, "###.##%;L"))
			,hypo_first_temp_pct	= substring(1,10,format(sum->list[d.seq].hypothermia_pct, "###.##%;L"))
 
		from (DUMMYT d  with seq = value(size(sum->list,5)))
 
		plan d
 
		order by facility, start_dt
 
		with nocounter, format, check, separator = " "
 
 
	else
 
 		;UMBILICAL CLAMPING
		select distinct into value ($OUTDEV)
			 facility				= substring(1,10,sum->list[d.seq].facility)
			,start_dt				= sum->startdate
			,end_dt					= sum->enddate
			,month_year				= sum->monthyear
			,denominator			= substring(1,10,format(sum->list[d.seq].60sec_demr, ";L"))
			,gte_60sec_numr			= substring(1,10,format(sum->list[d.seq].gte_60sec_numr,";L"))
			,gte_60sec_pct			= substring(1,10,format(sum->list[d.seq].gte_60sec_pct, "###.##%;L"))
			,lt_60sec_numr			= substring(1,10,format(sum->list[d.seq].lt_60sec_numr,";L"))
			,lt_60sec_pct			= substring(1,10,format(sum->list[d.seq].lt_60sec_pct, "###.##%;L"))
			,null_60sec_numr		= substring(1,10,format(sum->list[d.seq].null_60sec_numr,";L"))
			,null_60sec_pct			= substring(1,10,format(sum->list[d.seq].null_60sec_pct, "###.##%;L"))
 
		from (DUMMYT d  with seq = value(size(sum->list,5)))
 
		plan d
 
		order by facility, start_dt
 
		with nocounter, format, check, separator = " "
 
	endif
 
else
 
	;DETAIL
	select into value ($OUTDEV)
		 facility      						= substring(1,50,rec->list[d.seq].facility)
		,patient_name	   					= substring(1,50,rec->list[d.seq].pat_name)
		,admit_dt							= format(rec->list[d.seq].admit_dt, "mm/dd/yyyy hh:mm;;q")
		,fin		   						= substring(1,20,rec->list[d.seq].fin)
		,delivery_type						= substring(1,50,rec->list[d.seq].delivery_type)
		,baby_label							= substring(1,50,rec->list[d.seq].baby_label)
		,birth_temp							= substring(1,20,rec->list[d.seq].birth_temp)
		,apgar_score_5m						= substring(1,20,rec->list[d.seq].apgar_score_5m)
		,tm_umbilical_cc					= substring(1,50,rec->list[d.seq].tm_umbilical_cc)
		,race								= substring(1,50,rec->list[d.seq].race)
		,ethnicity							= substring(1,50,rec->list[d.seq].ethnicity)
		,neonate_outcome					= substring(1,20,rec->list[d.seq].neonate_outcome)
;		,visit_reason						= substring(1,50,rec->list[d.seq].visit_reason)
;		,primary_nurse						= substring(1,50,rec->list[d.seq].primary_nurse)
		,attend_physician					= substring(1,50,rec->list[d.seq].attend_physician)
;		,hypothermia_numr					= substring(1,10,format(rec->list[d.seq].hypothermia_numr,";L"))
		,hypo_missing_n_numr				= substring(1,10,format(rec->list[d.seq].hypo_missing_n_numr,";L"))
		,hypo_nonmissing_n_numr				= substring(1,10,format(rec->list[d.seq].hypo_nonmissing_n_numr,";L"))
		,apgar_missing_n_numr				= substring(1,10,format(rec->list[d.seq].apgar_missing_n_numr,";L"))
		,apgar_nonmissing_n_numr			= substring(1,10,format(rec->list[d.seq].apgar_nonmissing_n_numr,";L"))
		,gte_60sec_numr						= substring(1,10,format(rec->list[d.seq].gte_60sec_numr,";L"))
		,lt_60sec_numr						= substring(1,10,format(rec->list[d.seq].lt_60sec_numr,";L"))
		,null_60sec_numr					= substring(1,10,format(rec->list[d.seq].null_60sec_numr,";L"))
		,eth_nonhispc_white_gte_60sec_numr	= substring(1,10,format(rec->list[d.seq].eth_nonhispc_white_numr, ";L"))
		,eth_nonhispc_black_gte_60sec_numr	= substring(1,10,format(rec->list[d.seq].eth_nonhispc_black_numr, ";L"))
		,eth_hispanic_gte_60sec_numr		= substring(1,10,format(rec->list[d.seq].eth_hispanic_numr, ";L"))
		,eth_hispanic_gte_60sec_numr		= substring(1,10,format(rec->list[d.seq].eth_hispanic_numr, ";L"))
		,eth_other_numr						= substring(1,10,format(rec->list[d.seq].eth_other_numr, ";L"))
		,eth_overall_gte_60sec_numr			= substring(1,10,format(rec->list[d.seq].eth_overall_numr, ";L"))
		,startdate_pmpt						= rec->startdate
		,enddate_pmpt  						= rec->enddate
		,month_year							= rec->monthyear
 
;		,nurse_unit							= substring(1,50,rec->list[d.seq].nurse_unit)
;		,mrn		   						= substring(1,20,rec->list[d.seq].mrn)
;		,age								= cnvtage(rec->list[d.seq].age)
;		,dob								= format(rec->list[d.seq].dob, "mm/dd/yyyy;;q")
;		,rec_cnt							= rec->encntr_cnt
;		,result_dt							= format(rec->list[d.seq].result_dt, "mm/dd/yyyy hh:mm;;q")
;		,arrival_mode						= substring(1,50,rec->list[d.seq].arrival_mode)
;		,encntr_type						= rec->list[d.seq].encntr_type
;		,disposition						= substring(1,50,rec->list[d.seq].disposition)
;		,encntr_type_hist					= substring(1,50,rec->list[d.seq].encntr_type_hist)
;		,end_eff_dt							= format(rec->list[d.seq].end_eff_dt, "mm/dd/yyyy hh:mm;;q")
;		,encntr_id     						= rec->list[d.seq].encntr_id
;		,event_id							= rec->list[d.seq].event_id
;		,pregnancy_id     					= rec->list[d.seq].pregnancy_id
;		,username      						= rec->username
 
	from (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by facility, race, ethnicity, patient_name, baby_label;, admit_dt;, baby_label
 
	with nocounter, format, check, separator = " "
 
endif
 
#exitscript
end
go

/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		September 2021
	Solution:			Utilization Management
	Source file name:  	cov_him_stepdown_op.prg
	Object name:		cov_him_stepdown_op
	CR#:				12032
 
	Program purpose:	Stepdown to Outpatient (op)
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
 
drop   program cov_him_stepdown_op:DBA go
create program cov_him_stepdown_op:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = VALUE(0.00)
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          	= vc
	1 startdate         	= vc
	1 enddate          	 	= vc
	1 rec_cnt				= i4
	1 list[*]
		2 facility      	= vc
		2 nurse_unit		= vc
		2 nurse_unit_hist	= vc
		2 patient_name 		= vc
		2 fin           	= vc
		2 admit_dt			= dq8
		2 discharge_dt		= dq8
		2 end_eff_dt		= dq8
	    2 encntr_type_hist	= vc
		2 encntr_type		= vc
		2 encntr_id			= f8
		2 encntr_hist_id	= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare username           	= vc with protect
declare initcap()          	= c100
declare num					= i4 with noconstant(0)
declare idx					= i4 with noconstant(0)
;
declare FIN_TYPE_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare PACU_IN_VAR       	= f8 with constant(uar_get_code_by("DISPLAY_KEY", 72, "SNPACUICTMINPACUI")),protect
declare OBSERVATION_VAR		= f8 with constant(uar_get_code_by("DISPLAY_KEY", 69, "OBSERVATION")),protect
declare OUTP_INBED_VAR		= f8 with constant(uar_get_code_by("DISPLAY_KEY", 71, "OUTPATIENTINABED")),protect
declare OUTP_MONITOR_VAR	= f8 with constant(uar_get_code_by("DISPLAY_KEY", 71, "OUTPATIENTMONITORING")),protect
declare OUTP_VAR			= f8 with constant(uar_get_code_by("DISPLAY_KEY", 71, "OUTPATIENT")),protect
;
declare FLMC_DAYSURG_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FLMCTEMPORDAYSURG")),protect
declare FSR_DAYSURG_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FSRTEMPORDAYSURG")),protect
declare LCMC_DAYSURG_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "LCMCTEMPORDAYSURG")),protect
declare MHA_DAYSURG_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MHATEMPORDAYSUR")),protect
declare MHA_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MHATEMPINTR")),protect
declare MHHS_DAYSURG_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MHHSTEMPORDAYSUR")),protect
declare MMC_DAYSURG_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MMCTEMPORDAYSURG")),protect
declare PW_DAYSURG_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PWTEMPORSDS")),protect
declare RMC_DAYSURG_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "RMCTEMPORDAYSURG")),protect
;
declare FLMC_PACU_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FLMCTEMPPACU")),protect
declare FSR_PACU_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FSRTEMPORPACU")),protect
declare LCMC_PACU_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "LCMCTEMPPACU")),protect
declare MHHS_PACU_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MHHSTEMPORPACU")),protect
declare MMC_PACU_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MMCTEMPORPACU")),protect
declare PW_PACU_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PWTEMPPACU")),protect
declare RMC_PACU_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "RMCTEMPORPACU")),protect
;
declare FLMC_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FLMCTEMPINTRA")),protect
declare FSR_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "FSRTEMPORINTRA")),protect
declare LCMC_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "LCMCTEMPINTRA")),protect
declare MHHS_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MHHSTEMPORINTR")),protect
declare MMC_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "MMCTEMPORINTRA")),protect
declare PW_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PWTEMPINTRA")),protect
declare RMC_INTRA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "RMCTEMPORINTRA")),protect
;
;declare ACTIVE_VAR 		= f8 with constant(uar_get_code_by("MEANING",8, "ACTIVE")),protect
;declare AUTHVERIFIED_VAR 	= f8 with constant(uar_get_code_by("MEANING",8, "AUTH")),protect
;declare ALTERED_VAR 		= f8 with constant(uar_get_code_by("MEANING",8, "ALTERED")),protect
;declare MODIFIED_VAR	 	= f8 with constant(uar_get_code_by("MEANING",8, "MODIFIED")),protect
;
declare	START_DATETIME		= f8
declare END_DATETIME		= f8
;
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
 
 
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
;set START_DATETIME = cnvtdatetime("01-JUN-2020 00:00:00")
;set END_DATETIME   = cnvtdatetime("05-JUN-2020 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME, "mm/dd/yyyy;;q") 	;substring(1,11,$START_DATETIME_PMPT)
set rec->enddate   = format(END_DATETIME, "mm/dd/yyyy;;q") 		;substring(1,11,$END_DATETIME_PMPT)
 
 
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
		and elh.loc_nurse_unit_cd in (
			2552503829,2552507117,2552516661,2556758491,2564350799,2564350877,2564350949,32012115,38616903,2550798939,2552516975,2552517431,
			2552518355,2552518651,2552518871,2552518891,2552519167,2552519315,2552519611,2552520299,2552520343,2552520747,2552521079,
			2557548587,2561582141,3713231589,2570759989,2570760575,2570761687,2552503897,2552512729,2552512901,2552513125,2552513193,
			2552513613,2552513857,2557552253,2557553053,2564353235,2564353693,2564353711,2552503845,2552507525,2552507837,2552507961,
			2552508061,2552508305,2552508361,2552508441,2552508533,2552508637,2552516785,2557555119,2557555939,2570757685,2570757889,
			2570758511,2570759089,2570759713,2552503797,2552504293,2552504537,2552504909,2552505277,2552505625,2552505673,2552505741,
			2552505957,2552506009,2553913483,2555128693,2555130189,2556748159,2557661937,2557661961,2552508789,2552509009,2552509149,
			2552509417,2552509721,2552509989,2552510409,2552510813,2552511121,2552511237,2552511369,2552511877,2552512089,2556760437,
			2556762025,2556762153,3222927715,3222927743,2560500077,2560500565,2560501029,2552503877,2552512545,2553913493,2553913757,
			2559795279,2559795575,2559795703)
;		and elh.loc_nurse_unit_cd in (
;			FLMC_DAYSURG_VAR, FLMC_INTRA_VAR, FLMC_PACU_VAR,
;			FSR_DAYSURG_VAR, FSR_INTRA_VAR, FSR_PACU_VAR,
;			LCMC_DAYSURG_VAR, LCMC_INTRA_VAR, LCMC_PACU_VAR,
;			MHHS_DAYSURG_VAR, MHHS_INTRA_VAR, MHHS_PACU_VAR,
;			MHA_DAYSURG_VAR, MHA_INTRA_VAR,
;			MMC_DAYSURG_VAR, MMC_INTRA_VAR, MMC_PACU_VAR,
;			PW_DAYSURG_VAR, PW_INTRA_VAR, PW_PACU_VAR,
;			RMC_DAYSURG_VAR, RMC_INTRA_VAR, RMC_PACU_VAR)
;		and elh.encntr_type_cd = OBSERVATION_VAR ;309312 ;set-71
		and elh.encntr_type_class_cd = OBSERVATION_VAR ;392 ;set-69
		and elh.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR ;1077
		and ea.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
;		and ea.alias = "2124303329"
		and ea.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and (e.reg_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME))
	and e.encntr_type_cd in (OUTP_INBED_VAR, OUTP_MONITOR_VAR, OUTP_VAR) ;19962820, 2555137211, 309309
 
order by e.encntr_id;, elh.encntr_loc_hist_id
 
head report
	cnt = 0
 
head elh.encntr_loc_hist_id ;e.encntr_id
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility			= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit		= uar_get_code_display(e.loc_nurse_unit_cd)
	rec->list[cnt].nurse_unit_hist	= uar_get_code_display(elh.loc_nurse_unit_cd)
	rec->list[cnt].patient_name		= p.name_full_formatted
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].admit_dt			= e.reg_dt_tm
	rec->list[cnt].discharge_dt		= e.disch_dt_tm
	rec->list[cnt].end_eff_dt		= elh.end_effective_dt_tm
	rec->list[cnt].encntr_type_hist	= uar_get_code_display(elh.encntr_type_cd)
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
 	rec->list[cnt].encntr_id	 	= e.encntr_id
	rec->list[cnt].encntr_hist_id	= elh.encntr_loc_hist_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
if (rec->rec_cnt > 0)
 
	select distinct into value ($OUTDEV)
		 facility      			= substring(1,30,rec->list[d.seq].facility)
;		,nurse_unit				= substring(1,20,rec->list[d.seq].nurse_unit)
		,units					= substring(1,50,rec->list[d.seq].nurse_unit_hist)
		,patient_name  			= substring(1,50,rec->list[d.seq].patient_name)
		,fin					= substring(1,10,rec->list[d.seq].fin)
		,admit_dt				= format(rec->list[d.seq].admit_dt, "mm/dd/yyyy hh:mm;;q")
		,discharge_dt			= format(rec->list[d.seq].discharge_dt, "mm/dd/yyyy hh:mm;;q")
		,admit_encntr_type		= substring(1,50,rec->list[d.seq].encntr_type_hist)
		,stepdown_encntr_type	= substring(1,50,rec->list[d.seq].encntr_type)
;		,end_eff_dt				= format(rec->list[d.seq].end_eff_dt, "mm/dd/yyyy hh:mm;;q")
;		,encntr_id     			= rec->list[d.seq].encntr_id
;		,encntr_hist_id			= rec->list[d.seq].encntr_hist_id
;		,rec_cnt	   			= rec->rec_cnt
;		,username      			= rec->username
;		,startdate_pmpt			= rec->startdate
;		,enddate_pmpt  			= rec->enddate
 
	from
		(dummyt d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by facility, admit_dt, patient_name, units, rec->list[d.seq].encntr_id;, rec->list[d.seq].encntr_hist_id
 
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

drop program cov_ina_ModerateSedation:DBA go
create program cov_ina_ModerateSedation:DBA
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:				Dan Herren
	Date Written:		August 2018
	Solution:			Nursing/Nutrition
	Source file name:  	cov_ina_ModerateSedation.prg
	Object name:		cov_ina_ModerateSedation
	CR#:				2177
 
	Program purpose:	Report will show all patient's with moderate sedation.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  --------------------  ----------------------------
*
*
******************************************************************************/
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Nurse Unit" = 0
	, "Encounter Type" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "" = "SYSDATE"
 
with OUTDEV, FACILITY_PMPT, NURSE_UNIT_PMPT, ENCNTR_TYPE_PMPT,
	START_DATETIME_PMPT, END_DATETIME_PMPT, ORD_START_DATETIME_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record ord(
	1 username          = vc
	1 startdate         = c50
	1 enddate           = c50
	1 total_cnt			= i4
	1 list[*]
		2 facility      = c30
		2 nurse_unit    = c30
		2 room		    = c10
		2 bed           = vc
		2 pat_name      = c35
		2 fin           = vc
		2 mrn           = vc
		2 order_name    = c50
		2 order_date    = dq8
		2 event_date    = dq8
		2 perform_date  = dq8
		2 nurse         = c35
		2 encntr_type   = c30
;		2 encntr_id     = f8
)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY", 48,  "ACTIVE")),protect
declare MRN_VAR           = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN")),protect
declare FIN_VAR           = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare MOD_SEDATION_VAR  = f8 with constant(uar_get_code_by("DISPLAYKEY", 72,  "MODERATESEDATIONMEDICATION")),protect
declare MED_NOTDONE_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY", 8,   "NOTDONE")),protect
;
;Encounter Types
declare INPATIENT_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT")),protect
declare OUTPATIENTBED_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED")),protect
declare OBSERVATION_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION")),protect
declare DAYSURGERY_VAR    = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "DAYSURGERY")),protect
declare EMERGENCY_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "EMERGENCY")),protect
declare SELECTSPECIAL_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "SELECTSPECIALTY")),protect
;
declare OPR_FAC_VAR		  = vc with noconstant(fillstring(1000," "))
declare PROMPT1_VAR       = vc with noconstant(fillstring(1000," "))
declare ENCNTR_VAR        = vc with noconstant(fillstring(1000," "))
;
declare username          = vc with protect
declare initcap()         = c100
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	ord->username = p.username
with nocounter
 
;SET DATE PROMPTS
set ord->startdate = $START_DATETIME_PMPT ;substring(1,11,$START_DATETIME_PMPT)
set ord->enddate   = $END_DATETIME_PMPT ;substring(1,11,$END_DATETIME_PMPT)
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
;SET NURSE UNIT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($NURSE_UNIT_PMPT),0))) = "L")	;multiple values were selected
	set OPR_NU_VAR = "in"
elseif(parameter(parameter2($NURSE_UNIT_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_NU_VAR = "!="
else																		;a single value was selected
	set OPR_NU_VAR = "="
endif
 
;SET ENCOUNTER TYPE
case($ENCNTR_TYPE_PMPT)
	of 0 : set ENCNTR_VAR = "e.encntr_type_cd in (INPATIENT_VAR,OUTPATIENTBED_VAR,OBSERVATION_VAR)" ;inpatient
	of 1 : set ENCNTR_VAR = "e.encntr_type_cd in (DAYSURGERY_VAR,EMERGENCY_VAR, SELECTSPECIAL_VAR)" ;outpatient
	else   set ENCNTR_VAR = "e.encntr_type_cd in (INPATIENT_VAR, OUTPATIENTBED_VAR, OBSERVATION_VAR, DAYSURGERY_VAR, \
EMERGENCY_VAR, SELECTSPECIAL_VAR)" ;both
endcase
 
;call echorecord(ENCNTR_VAR)
;go to exitscript
 
;MAIN SELECT FOR DATA
select distinct into "NL:"
;select distinct into $OUTDEV
 	 facility      = uar_get_code_description(e.loc_facility_cd)
	,nurse_unit    = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
	,room		   = trim(uar_get_code_display(e.loc_room_cd),3)
	,bed           = trim(uar_get_code_display(e.loc_bed_cd),3)
	,pat_name      = trim(initcap(p.name_full_formatted),3)
	,fin           = ea.alias
	,mrn           = ea1.alias
	,order_name    = trim(ord.order_mnemonic,3)
	,order_date    = ord.orig_order_dt_tm
	,event_date    = ce.event_end_dt_tm
	,perform_date  = ce.performed_dt_tm
	,nurse   	   = trim(initcap(pr.name_full_formatted),3)
	,encntr_type   = uar_get_code_display(e.encntr_type_cd)
;	,encntr_id     = e.encntr_id
 
from
	 CLINICAL_EVENT  ce
  	,ORDERS          ord
	,ENCOUNTER       e
	,ENCNTR_ALIAS    ea
	,ENCNTR_ALIAS    ea1
	,PERSON          p
	,PRSNL           pr
 
plan ce where ce.order_id in
	(
	select o.order_id
	from orders o
	where o.pathway_catalog_id = 2555137529  ;RN ADMINISTERED MODERATE SEDATION
		and o.encntr_id = ce.encntr_id
		and o.order_id = ce.order_id
		and ord.orig_order_dt_tm between cnvtdatetime($ORD_START_DATETIME_PMPT) and cnvtdatetime($END_DATETIME_PMPT)
	)
	and ce.catalog_cd > 0
	and ce.result_status_cd != MED_NOTDONE_VAR ;36
	and ce.result_units_cd != 0.00
	and ce.result_val != ""
	and ce.performed_dt_tm between cnvtdatetime($START_DATETIME_PMPT) and cnvtdatetime($END_DATETIME_PMPT)
 	and ce.event_end_dt_tm < sysdate
	and ce.valid_until_dt_tm >= sysdate
 
join ord where ord.order_id = ce.order_id
	and ord.encntr_id = ce.encntr_id
	and ord.pathway_catalog_id = 2555137529  ;RN ADMINISTERED MODERATE SEDATION
	and ord.active_ind = 1
	and ord.orig_order_dt_tm between cnvtdatetime($ORD_START_DATETIME_PMPT) and cnvtdatetime($END_DATETIME_PMPT)
 
join e where e.encntr_id = ord.encntr_id
	and e.encntr_id = ce.encntr_id
	and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and operator(e.loc_nurse_unit_cd, OPR_NU_VAR, $NURSE_UNIT_PMPT)
	and parser(ENCNTR_VAR)
	and e.encntr_type_cd in (INPATIENT_VAR, OUTPATIENTBED_VAR, OBSERVATION_VAR, DAYSURGERY_VAR, EMERGENCY_VAR, SELECTSPECIAL_VAR)
	and e.active_ind = 1
	and e.end_effective_dt_tm > sysdate
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = FIN_VAR ;1077
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = outerjoin(e.encntr_id)
	and ea1.encntr_alias_type_cd = outerjoin(MRN_VAR) ;1079
	and ea1.active_ind = outerjoin(1)
 
join p where p.person_id = ce.person_id
	and p.person_id = e.person_id
;	and p.active_ind = 1
 
join pr where pr.person_id = ce.performed_prsnl_id
	and pr.active_ind = 1
	and pr.active_status_cd = ACTIVE_VAR  ;188
 
order by facility, nurse_unit, room, bed, pat_name, order_name, event_date, order_date;, encntr_id
 
head report
	cnt  = 0
 
detail
 	cnt = cnt + 1
	call alterlist(ord->list, cnt)
 
 	ord->total_cnt = cnt
 
	ord->list[cnt].facility      = facility
	ord->list[cnt].nurse_unit    = nurse_unit
	ord->list[cnt].room			 = room
	ord->list[cnt].bed           = bed
	ord->list[cnt].pat_name      = pat_name
	ord->list[cnt].fin 			 = fin
	ord->list[cnt].mrn           = mrn
	ord->list[cnt].order_name    = order_name
    ord->list[cnt].order_date	 = order_date
	ord->list[cnt].event_date    = event_date
	ord->list[cnt].perform_date  = perform_date
	ord->list[cnt].nurse         = nurse
	ord->list[cnt].encntr_type   = encntr_type
;	ord->list[cnt].encntr_id     = encntr_id
 
with nocounter
 
;============================
; REPORT OUTPUT
;============================
;select into "NL:"
select distinct into value ($OUTDEV)
	 facility      = ord->list[d.seq].facility
	,nurse_unit    = ord->list[d.seq].nurse_unit
	,room		   = ord->list[d.seq].room
 	,bed		   = ord->list[d.seq].bed
	,pat_name	   = ord->list[d.seq].pat_name
	,fin		   = ord->list[d.seq].fin
	,mrn		   = ord->list[d.seq].mrn
	,order_name    = ord->list[d.seq].order_name
	,order_date    = format(ord->list[d.seq].order_date,   "mm/dd/yyyy HH:mm;;d")
	,event_date    = format(ord->list[d.seq].event_date,   "mm/dd/yyyy HH:mm;;d")
	,perform_date  = format(ord->list[d.seq].perform_date, "mm/dd/yyyy HH:mm;;d")
	,nurse         = ord->list[d.seq].nurse
	,encntr_type   = ord->list[d.seq].encntr_type
	,startdate 	   = ord->startdate
	,enddate   	   = ord->enddate
;	,encntr_id     = ord->list[d.seq].encntr_id
;	,username      = ord->username
;	,total_cnt	   = ord->total_cnt
 
from
	(dummyt d  with seq = value(size(ord->list,5)))
 
plan d
 
order by facility, nurse_unit, room, bed, pat_name, order_name, event_date, order_date;, encntr_id
 
with nocounter, format, check, separator = " "
 
;#EXITSCRIPT
end
go

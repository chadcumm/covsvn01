/*****************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************
	Author:				Dan Herren
	Date Written:		February 2019
	Solution:			Infection Control
	Source file name:  	cov_ic_IsolActivityType.prg
	Object name:		cov_ic_IsolActivityType
	Layout file name:   cov_ic_IsolActivityType_lb
	CR#:				3411
 
	Program purpose:	Patient's documentation for Isolation Activity/Type.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------
*
*
******************************************************************************/
 
drop program cov_ic_IsolActivityType:DBA go
create program cov_ic_IsolActivityType:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report or Grid" = 0
	, "Facility" = 0
	, "Nurse Unit" = 0
 
with OUTDEV, RPT_GRID_PMPT, FACILITY_PMPT, NURSE_UNIT_PMPT
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record enc(
	1 total_cnt			   = i4
	1 list[*]
		2 facility         = vc
		2 nurse_unit       = vc
		2 room		       = vc
		2 bed              = vc
		2 room_bed		   = vc
		2 pat_name         = c50
		2 fin              = vc
		2 mrn              = vc
		2 isol_date        = dq8
		2 isol_activity    = c75
		2 isol_type        = c75
		2 encntr_id		   = f8
		2 event_cnt		   = i4
		2 events[*]
			3 event_id     = f8
			3 eventcd	   = f8
			3 eventname	   = vc
			3 result	   = vc
			3 isol_date    = dq8
)
 
RECORD output(
	1 username             = vc
	1 rec_cnt			   = i4
	1 qual[*]
		2 facility         = vc
		2 nurse_unit       = vc
		2 room		       = vc
		2 bed              = vc
		2 room_bed		   = vc
		2 pat_name         = c50
		2 fin              = vc
		2 mrn              = vc
		2 isol_date        = dq8
		2 isol_activity    = c75
		2 isol_type        = c75
		2 encntr_id		   = f8
 
)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR         = f8 with constant(uar_get_code_by("DISPLAYKEY", 48,  "ACTIVE")),protect
declare FIN_VAR            = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare MRN_VAR            = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN")),protect
declare ISOL_TYPE_VAR  	   = f8 with constant(uar_get_code_by("DISPLAYKEY", 72,  "ISOLATIONTYPE")),protect
declare ISOL_ACTIVITY_VAR  = f8 with constant(uar_get_code_by("DISPLAYKEY", 72,  "ISOLATIONACTIVITY")),protect
;declare ISOL_INTERVENT_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY", 72,  "ISOLATIONINTERVENTION")),protect
;
declare OPR_FAC_VAR		   = vc with noconstant(fillstring(1000," "))
declare OPR_NRU_VAR		   = vc with noconstant(fillstring(1000," "))
;
declare username           = vc with protect
declare initcap()          = c100
declare num				   = i4 with noconstant(0)
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	output->username = p.username
with nocounter
 
 
;SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;SET NURSE UNIT PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($NURSE_UNIT_PMPT),0))) = "L")	;multiple values were selected
	set OPR_NRU_VAR = "in"
elseif(parameter(parameter2($NURSE_UNIT_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_NRU_VAR = "!="
else																		;a single value was selected
	set OPR_NRU_VAR = "="
endif
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select distinct into "NL:"
	 facility      	= uar_get_code_description(e.loc_facility_cd)
	,nurse_unit    	= uar_get_code_display(elh.loc_nurse_unit_cd)
	,room			= trim(uar_get_code_display(e.loc_room_cd),3)
	,bed			= trim(uar_get_code_display(e.loc_bed_cd),3)
	,room_bed     	= build2(trim(uar_get_code_display(elh.loc_room_cd),3),"-",uar_get_code_display(elh.loc_bed_cd))
	,pat_name      	= initcap(p.name_full_formatted)
	,fin           	= ea.alias
	,mrn           	= ea2.alias
	,isol_date		= ce.event_end_dt_tm
	,encntr_id  	= e.encntr_id
	,event_id		= ce.event_id
 
from ENCOUNTER e
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.person_id = e.person_id
		and (ce.event_end_dt_tm between cnvtlookbehind("24,H") and cnvtdatetime(curdate, curtime))
;		and ce.event_end_dt_tm between cnvtdatetime("03-MAR-2019 00:00:00") and cnvtdatetime("03-MAR-2019 23:23:59")
		and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 0")
		and ce.event_cd in (ISOL_ACTIVITY_VAR, ISOL_TYPE_VAR) ;160807847, 160794427
	)
 
	,(inner join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
		and (ce.event_end_dt_tm >= elh.beg_effective_dt_tm and ce.event_end_dt_tm <= elh.end_effective_dt_tm)
		and elh.active_ind = 1
	)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
		and ea.end_effective_dt_tm > sysdate
		and ea.active_ind = 1
	)
 
	,(inner join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_VAR  ;1079
		and ea2.end_effective_dt_tm > sysdate
		and ea2.active_ind = 1
	)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1
	)
 
where e.active_ind = 1
	and operator(elh.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and operator(elh.loc_nurse_unit_cd, OPR_NRU_VAR, $NURSE_UNIT_PMPT)
	and e.end_effective_dt_tm > sysdate
	and e.active_ind = 1
;	and e.encntr_id =   113738718.00  ;for testing one patient
 
order by nurse_unit, room_bed, pat_name, isol_date desc, encntr_id, event_id
 
head report
	cnt  = 0
 
head encntr_id
 
 	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(enc->list,cnt + 9)
	endif
 
 	enc->total_cnt = cnt
 
	enc->list[cnt].facility      = facility
	enc->list[cnt].nurse_unit    = nurse_unit
	enc->list[cnt].room			 = room
	enc->list[cnt].bed           = bed
	enc->list[cnt].room_bed		 = room_bed
	enc->list[cnt].pat_name      = pat_name
	enc->list[cnt].fin 			 = fin
	enc->list[cnt].mrn           = mrn
 	enc->list[cnt].encntr_id	 = encntr_id
 
	rcnt = 0
 
detail
 	rcnt = rcnt + 1
 
 	if (mod(rcnt,10) = 1 or rcnt = 1)
 		stat = alterlist(enc->list[cnt].events, rcnt + 9)
 	endif
 
 	enc->list[cnt].events[rcnt].event_id	= ce.event_id
 	enc->list[cnt].events[rcnt].eventcd		= ce.event_cd
 	enc->list[cnt].events[rcnt].eventname	= uar_get_code_display(ce.event_cd)
 	enc->list[cnt].events[rcnt].isol_date	= ce.event_end_dt_tm
 	enc->list[cnt].events[rcnt].result		= trim(ce.result_val,3)
 	enc->list[cnt].event_cnt				= rcnt
 
foot encntr_id
	stat = alterlist(enc->list[cnt].events, rcnt)
 
foot report
	stat = alterlist(enc->list, cnt)
 
with nocounter
 
;call echorecord(enc)
;go to exitscript
 
;====================================================
; COPY RECORD STRUCTURE
;====================================================
select into 'nl:'
	encntrid = enc->list[d.seq].encntr_id
 
from (dummyt d with seq = enc->total_cnt)
 
plan d
 
head report
	cnt = 0
	isol_dt = 0.0
	old_isol_dt = 0.0
 
head encntrid
	for (rcnt = 1 to enc->list[d.seq].event_cnt)
		isol_dt = enc->list[d.seq].events[rcnt].isol_date
		if (isol_dt != old_isol_dt)
			cnt = cnt + 1
			;if (mod(cnt,10) = 1 or cnt = 1)
				stat = alterlist(output->qual, cnt )
			;endif
		endif
 
		output->qual[cnt].facility		= enc->list[d.seq].facility
		output->qual[cnt].nurse_unit	= enc->list[d.seq].nurse_unit
		output->qual[cnt].room			= enc->list[d.seq].room
		output->qual[cnt].bed			= enc->list[d.seq].bed
		output->qual[cnt].room_bed		= enc->list[d.seq].room_bed
		output->qual[cnt].pat_name 		= enc->list[d.seq].pat_name
		output->qual[cnt].fin			= enc->list[d.seq].fin
		output->qual[cnt].mrn			= enc->list[d.seq].mrn
		output->qual[cnt].isol_date		= enc->list[d.seq].events[rcnt].isol_date
 
		if (enc->list[d.seq].events[rcnt].eventcd = ISOL_ACTIVITY_VAR)
			output->qual[cnt].isol_activity = enc->list[d.seq].events[rcnt].result
		elseif (enc->list[d.seq].events[rcnt].eventcd = ISOL_TYPE_VAR)
			output->qual[cnt].isol_type		= enc->list[d.seq].events[rcnt].result
		endif
 
		output->qual[cnt].encntr_id		= enc->list[d.seq].encntr_id
		output->rec_cnt					= cnt
 
		old_isol_dt = enc->list[d.seq].events[rcnt].isol_date
	endfor
 
foot report
	stat = alterlist(output->qual, cnt)
 
with nocounter
 
;call echorecord(output)
;go to exitscript
 
;====================================================
; REPORT OUTPUT
;====================================================
select into value ($OUTDEV)
	 facility      = output->qual[d.seq].facility
	,nurse_unit    = output->qual[d.seq].nurse_unit
	,room		   = output->qual[d.seq].room
 	,bed		   = output->qual[d.seq].bed
	,room_bed	   = output->qual[d.seq].room_bed
	,pat_name	   = output->qual[d.seq].pat_name
	,fin		   = output->qual[d.seq].fin
	,mrn		   = output->qual[d.seq].mrn
	,isol_date     = format(output->qual[d.seq].isol_date, "mm/dd/yyyy hh:mm;;q")
	,isol_activity = output->qual[d.seq].isol_activity
	,isol_type     = output->qual[d.seq].isol_type
;	,encntr_id     = output->qual[d.seq].encntr_id
;	,event_id	   = output->qual[d.seq].event_id
	,username      = output->username
	,rec_cnt	   = output->rec_cnt
 
from
	(dummyt d with seq = value(size(output->qual,5)))
 
plan d
 
order by nurse_unit, room, bed, pat_name, isol_date desc  ;, event_id
 
with nocounter, format, check, separator = " "
 
#exitscript
end
go
 

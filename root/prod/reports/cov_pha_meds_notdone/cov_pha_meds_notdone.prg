/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		September 2021
	Solution:			Pharmacy
	Source file name:  	cov_pha_meds_notdone.prg
	Object name:		cov_pha_meds_notdone
	CR#:				11203
 
	Program purpose:
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
 
drop   program cov_pha_meds_notdone:DBA go
create program cov_pha_meds_notdone:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = VALUE(0.0           ) 

with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          	= vc
	1 startdate         	= vc
	1 enddate          	 	= vc
	1 encntr_cnt			= i4
	1 list[*]
		2 facility      	= vc
		2 nurse_unit		= vc
		2 room				= vc
		2 bed				= vc
		2 patient      		= vc
		2 fin           	= vc
		2 med_beg_dt		= dq8
		2 order_name		= vc
		2 provider		 	= vc
		2 prov_position 	= vc
		2 medication		= vc
		2 reason			= vc
		2 event_dt			= dq8
		2 scheduled_dt		= dq8
		2 encntr_id			= f8
		2 event_id			= f8
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
declare NOTDONE_VAR         = f8 with constant(uar_get_code_by("DISPLAYKEY", 4000040, "NOTDONE")),protect
declare NOTGIVEN_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY", 4000040, "NOTGIVEN")),protect
declare PHA_CAT_TYPE_VAR   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "PHARMACY")),protect
;
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
;
declare	START_DATETIME		= f8
declare END_DATETIME		= f8
 
 
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
	 patient	= initcap(p.name_full_formatted)
	,provider	= initcap(pl.name_full_formatted)
 
from MED_ADMIN_EVENT mae
 
	,(inner join ORDERS o on o.order_id = mae.order_id
		and o.catalog_type_cd = PHA_CAT_TYPE_VAR ;2516
		and o.active_ind = 1)
 
	,(inner join ORDER_DETAIL od on od.order_id = mae.order_id
		and od.oe_field_meaning IN ("RXROUTE"))
 
	,(inner join CLINICAL_EVENT ce on ce.event_id = mae.event_id
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
		and e.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and ea.active_ind = 1)
 
	,(inner join PRSNL pl on pl.person_id = mae.prsnl_id
;		and pl.position_cd in ( 681030.00,  181210115.00)
		and pl.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
;	,(left join TASK_ACTIVITY ta on ta.order_id = o.order_id
;		and ta.active_ind = 1)
 
where mae.beg_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME)
	and mae.event_type_cd in (NOTDONE_VAR, NOTGIVEN_VAR) ;4055414, 4055415
;	and mae.event_id = 3930468020
 
order by e.encntr_id, o.order_id, mae.event_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->encntr_cnt = cnt
 
	rec->list[cnt].facility			= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit		= uar_get_code_display(e.loc_nurse_unit_cd)
	rec->list[cnt].room				= uar_get_code_display(e.loc_room_cd)
	rec->list[cnt].bed				= uar_get_code_display(e.loc_bed_cd)
	rec->list[cnt].patient     		= patient
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].med_beg_dt		= mae.beg_dt_tm
	rec->list[cnt].order_name		= o.order_mnemonic
;	rec->list[cnt].medication		= uar_get_code_display(ce.catalog_cd)
 	rec->list[cnt].reason			= ce.event_tag
	rec->list[cnt].provider			= provider
	rec->list[cnt].prov_position	= uar_get_code_display(pl.position_cd)
; 	rec->list[cnt].event_dt			= ce.event_end_dt_tm
; 	rec->list[cnt].scheduled_dt		= ta.scheduled_dt_tm
 	rec->list[cnt].encntr_id	 	= e.encntr_id
 	rec->list[cnt].event_id			= mae.event_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
if (rec->encntr_cnt > 0)
 
	select into value ($OUTDEV)
		 facility      		= substring(1,30,rec->list[d.seq].facility)
		,nurse_unit			= substring(1,20,rec->list[d.seq].nurse_unit)
		,room				= substring(1,10,rec->list[d.seq].room)
		,bed				= substring(1,10,rec->list[d.seq].bed)
		,patient	   		= substring(1,50,rec->list[d.seq].patient)
		,fin				= substring(1,10,rec->list[d.seq].fin)
		,med_beg_dt			= format(rec->list[d.seq].med_beg_dt, "mm/dd/yyyy hh:mm;;q")
		,order_name			= substring(1,100,rec->list[d.seq].order_name)
;		,medication			= substring(1,100,rec->list[d.seq].medication)
		,reason				= substring(1,50,rec->list[d.seq].reason)
		,provider			= substring(1,50,rec->list[d.seq].provider)
		,position			= substring(1,50,rec->list[d.seq].prov_position)
;		,event_dt			= format(rec->list[d.seq].event_dt, "mm/dd/yyyy hh:mm;;q")
;		,scheduled_dt		= format(rec->list[d.seq].scheduled_dt, "mm/dd/yyyy hh:mm;;q")
;		,encntr_id     		= rec->list[d.seq].encntr_id
;		,event_id			= rec->list[d.seq].event_id
	;	,encntr_cnt	   		= rec->encntr_cnt
	;	,username      		= rec->username
	;	,startdate_pmpt		= rec->startdate
	;	,enddate_pmpt  		= rec->enddate
 
	from
		 (dummyt d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by facility, nurse_unit, room, bed, med_beg_dt desc, rec->list[d.seq].encntr_id, rec->list[d.seq].event_id
 
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

/*************************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
**************************************************************************************************
	Author:				Dan Herren
	Date Written:		January 2022
	Solution:
	Source file name:  	cov_pha_labordersbypharm.prg
	Object name:		cov_pha_labordersbypharm
	CR#:				11950
 
	Program purpose:
	Executing from:		CCL
  	Special Notes:
 
**************************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  -----------------------------------------------
*
*
**************************************************************************************************/
 
drop   program cov_pha_labordersbypharm:DBA go
create program cov_pha_labordersbypharm:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Begin Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Select Facility" = VALUE(0.00          )
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	OUTPUT_FILE_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          			= vc
	1 startdate         			= vc
	1 enddate          	 			= vc
	1 encntr_cnt					= i4
	1 list[*]
		2 facility      			= vc
		2 patient_name      		= vc
		2 fin           			= vc
		2 encntr_id					= f8
		2 person_id					= f8
		2 order_cnt					= i4
		2 orders[*]
			3 order_dt				= dq8
			3 order_desc			= vc
			3 pharmacist_name		= vc
			3 pharmacist_position	= vc
			3 physician				= vc
			3 communication_type	= vc
			3 catalog_type			= vc
			3 order_id  			= f8
	)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_TYPE_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY",  319, "FINNBR")),protect
declare LAB_CATALOG_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "LABORATORY")),protect
declare ORD_ACTION_TYPE_VAR    	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER")),protect
declare ACTIVE_STATUS_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",   48, "ACTIVE")),protect
declare PHANET_MGMT_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY",   88, "PHARMNETMANAGEMENT")),protect
declare PHANET_PHARM_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY",   88, "PHARMNETPHARMACIST")),protect
declare PHANET_TECH_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY",   88, "PHARMNETTECHNICIAN1")),protect
;
declare OPR_FAC_VAR		   		= vc with noconstant(fillstring(1000," "))
;
declare	START_DATETIME_VAR		= f8
declare END_DATETIME_VAR		= f8
;
declare username           		= vc with protect
declare initcap()          		= c100
declare num						= i4 with noconstant(0)
declare idx						= i4 with noconstant(0)
 
 
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
set START_DATETIME_VAR = cnvtdatetime($START_DATETIME_PMPT)
set END_DATETIME_VAR   = cnvtdatetime($END_DATETIME_PMPT)
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = cnvtdatetime("12-JAN-2022 00:00:00")
;set END_DATETIME_VAR   = cnvtdatetime("31-DEC-2022 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME_VAR, "mm/dd/yyyy;;q")
set rec->enddate   = format(END_DATETIME_VAR, "mm/dd/yyyy;;q")
 
 
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
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR ;1077   ;004
;		and ea.alias = "2124303329"
		and ea.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
		and ea.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	,(inner join ORDERS o on o.encntr_id = e.encntr_id
		and o.orig_order_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR)
		and o.catalog_type_cd = LAB_CATALOG_VAR ;2513.00 ;laboratory
    	and o.active_status_cd = ACTIVE_STATUS_VAR ;188 ;Active
		and o.template_order_id = 0.00
    	and o.active_ind = 1)
 
	,(inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = ORD_ACTION_TYPE_VAR ;2534.00 ;Order
		and oa.action_sequence > 0)
 
	,(inner join PRSNL pr1 on pr1.person_id = oa.action_personnel_id ; pharmacists order placed
		and pr1.position_cd in (PHANET_MGMT_VAR, PHANET_PHARM_VAR, PHANET_TECH_VAR) ;24379693,637053,637054
		and pr1.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pr1.active_ind = 1)
 
	,(left join PRSNL pr2 on pr2.person_id = oa.order_provider_id) ;physician
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
;	and e.loc_facility_cd = 2552503645
    and (e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
 
order e.encntr_id, o.order_id
 
	head report
		cnt  = 0
		ocnt = 0
 
	head e.encntr_id
 
		cnt = cnt + 1
 
		stat = alterlist(rec->list,cnt)
 
	 	rec->encntr_cnt = cnt
 
		rec->list[cnt].facility     = uar_get_code_display(e.loc_facility_cd)
		rec->list[cnt].patient_name	= p.name_full_formatted
		rec->list[cnt].fin			= ea.alias
	 	rec->list[cnt].encntr_id	= e.encntr_id
	 	rec->list[cnt].person_id	= p.person_id
 
		ocnt = 0
 
	head o.order_id
 
		ocnt = ocnt + 1
 
		stat = alterlist(rec->list[cnt].orders, ocnt)
 
		rec->list[cnt].orders[ocnt].order_dt			= o.orig_order_dt_tm
	 	rec->list[cnt].orders[ocnt].order_desc			= o.ordered_as_mnemonic
	 	rec->list[cnt].orders[ocnt].pharmacist_name		= pr1.name_full_formatted
	 	rec->list[cnt].orders[ocnt].pharmacist_position	= uar_get_code_display(pr1.position_cd)
	 	rec->list[cnt].orders[ocnt].physician			= pr2.name_full_formatted
	 	rec->list[cnt].orders[ocnt].communication_type	= uar_get_code_display(oa.communication_type_cd)
		rec->list[cnt].orders[ocnt].catalog_type		= uar_get_code_display(o.catalog_type_cd)
	 	rec->list[cnt].orders[ocnt].order_id			= o.order_id
 
	 	rec->list[cnt].order_cnt 						= ocnt
 
	foot e.encntr_id
		stat = alterlist(rec->list[cnt].orders, ocnt)
 
	foot report
		stat = alterlist(rec->list, cnt)
 
	with nocounter
 
;;call echorecord(rec)
;;go to exitscript
 
;============================
; REPORT OUTPUT
;============================
if (rec->encntr_cnt > 0)
 
  	select
 
		if ($OUTPUT_FILE_PMPT = 1)
			with outerjoin = d2, nocounter, pcformat (^"^, ^,^, 1,0), format, format=stream, formfeed=none  ;no padding
		else
			with outerjoin = d2, nocounter, separator = " ", format
		endif
 
	into $OUTDEV
 
		 facility      			= substring(1,50,rec->list[d.seq].facility)
		,patient_name  			= substring(1,50,rec->list[d.seq].patient_name)
		,fin		   			= substring(1,20,rec->list[d.seq].fin)
		,order_dt				= format(rec->list[d.seq].orders[d2.seq].order_dt, "mm/dd/yyyy hh:mm;;q")
		,order_desc				= substring(1,255,rec->list[d.seq].orders[d2.seq].order_desc)
		,pharmacist_name		= substring(1,50,rec->list[d.seq].orders[d2.seq].pharmacist_name)
		,pharmacist_position	= substring(1,100,rec->list[d.seq].orders[d2.seq].pharmacist_position)
		,physician				= substring(1,50,rec->list[d.seq].orders[d2.seq].physician)
		,communication_type		= substring(1,50,rec->list[d.seq].orders[d2.seq].communication_type)
		,catalog_type			= substring(1,50,rec->list[d.seq].orders[d2.seq].catalog_type)
;		,encntr_id				= rec->list[d.seq].encntr_id
		,order_id				= rec->list[d.seq].orders[d2.seq].order_id
;		,person_id				= rec->list[d.seq].person_id
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
		,(DUMMYT d2 with seq = 1)
 
	plan d
		where maxrec(d2, size(rec->list[d.seq].orders,5))
 
	join d2
 
	order by facility, patient_name, order_dt desc, rec->list[d.seq].encntr_id, rec->list[d.seq].orders[d2.seq].order_id
 
;;	with nocounter, format, check, separator = " ", outerjoin(d2)
 
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
 
 
 

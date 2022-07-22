/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		June 2022
	Solution:
	Source file name:	cov_ina_weight_frequency.prg
	Object name:		cov_ina_weight_frequency
	Layout file name:	cov_ina_weight_frequency_lb
	CR#:				12735
 
	Program purpose:
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
******************************************************************************************/
 
drop program cov_ina_weight_frequency:DBA go
create program cov_ina_weight_frequency:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Report or Grid" = 1
	, "Facility" = 0
	, "Nurse Unit" = VALUE(0.0           )
 
with OUTDEV, RPT_GRID_PMPT, FACILITY_PMPT, NURSE_UNIT_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
RECORD rec (
	1 rec_cnt 						= i4
	1 username						= vc
	1 list[*]
		2 facility_desc				= vc
		2 facility_abbr 			= vc
		2 nurse_unit 				= vc
		2 room						= vc
		2 bed						= vc
		2 fin 						= vc
		2 resident_name				= vc
		2 weight_dt		 			= dq8
		2 weight					= vc
		2 units						= vc
		2 order_dt					= dq8
		2 order_mnemonic			= vc
		2 frequency			 		= vc
		2 personid 					= f8
		2 encntrid 					= f8
		2 eventid					= f8
		2 orderid					= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
*************************************************************/
declare WEIGHT_MEASURED_VAR			= f8 with constant(uar_get_code_by("DISPLAY_KEY", 72, "WEIGHTMEASURED")), protect
declare WEIGHT_VAR					= f8 with constant(uar_get_code_by("DISPLAY_KEY",200, "WEIGHT")), protect
 
;SET FACILITY PROMPT VARIABLE
declare OPR_FAC_VAR		   			= vc with noconstant(fillstring(1000," "))
declare OPR_NU_VAR		   			= vc with noconstant(fillstring(1000," "))
 
declare cnt  						= i4 with noconstant(0),protect
declare idx  						= i4 with noconstant(0),protect
declare num							= i4 with noconstant(0),protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
; GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
;SET NURSE UNIT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($NURSE_UNIT_PMPT),0))) = "L")	;multiple values were selected
	set OPR_NU_VAR = "in"
elseif(parameter(parameter2($NURSE_UNIT_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_NU_VAR = "!="
else																		;a single value was selected
	set OPR_NU_VAR = "="
endif
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select distinct into "nl:"
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = 1077 ;FIN_TYPE_VAR
;		and ea.alias = "5214601957"
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and p.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.event_cd = WEIGHT_MEASURED_VAR ;4154120
		and ce.result_status_cd in (25,34,35,36)
;		and ce.event_class_cd != PLACE_HOLDER_VAR ;654645.00
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(inner join ORDERS o on o.encntr_id = e.encntr_id
;		and o.order_mnemonic = "Weight"
		and o.catalog_cd = WEIGHT_VAR ;2696754
		and o.active_ind = 1)
 
	,(inner join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "FREQ")
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and operator(e.loc_nurse_unit_cd, OPR_NU_VAR, $NURSE_UNIT_PMPT)
	and e.disch_dt_tm is null
	and e.active_ind = 1
 
order by ce.event_end_dt_tm desc, e.encntr_id, ce.event_id, o.order_id
 
head report
 	cnt = 0
 
	call alterlist(rec->list, 100)
 
head ce.event_id
 	cnt += 1
 	rec->rec_cnt = cnt
 
	call alterlist(rec->list, cnt)
 
detail
 	rec->list[cnt].facility_desc	= uar_get_code_description(e.loc_facility_cd)
 	rec->list[cnt].facility_abbr 	= uar_get_code_display(e.loc_facility_cd)
 	rec->list[cnt].nurse_unit 		= uar_get_code_display(e.loc_nurse_unit_cd)
 	rec->list[cnt].room		 		= uar_get_code_display(e.loc_room_cd)
 	rec->list[cnt].bed		 		= uar_get_code_display(e.loc_bed_cd)
 	rec->list[cnt].fin 				= ea.alias
 	rec->list[cnt].resident_name 	= p.name_full_formatted
 	rec->list[cnt].weight_dt		= ce.event_end_dt_tm
 	rec->list[cnt].weight			= ce.result_val
 	rec->list[cnt].units			= uar_get_code_display(ce.result_units_cd)
 	rec->list[cnt].order_dt 		= o.orig_order_dt_tm
 	rec->list[cnt].order_mnemonic	= o.order_mnemonic
 	rec->list[cnt].frequency		= od.oe_field_display_value
 	rec->list[cnt].personid 		= e.person_id
 	rec->list[cnt].encntrid 		= e.encntr_id
 	rec->list[cnt].orderid 			= o.order_id
 	rec->list[cnt].eventid			= ce.event_id
 
foot o.order_id
	call alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec->list)
;go to exitscript
 
 
;====================================================
; REPORT OUTPUT
;====================================================
if (rec->rec_cnt > 0)
 
	select distinct into value($OUTDEV)
		 facility_desc				= trim(substring(1,50, rec->list[d1.seq].facility_desc))
		,facility_abbr 				= trim(substring(1,50, rec->list[d1.seq].facility_abbr))
		,nurse_unit 				= trim(substring(1,50, rec->list[d1.seq].nurse_unit))
		,room						= trim(substring(1,50, rec->list[d1.seq].room))
		,bed						= trim(substring(1,50, rec->list[d1.seq].bed))
		,patient_name 				= trim(substring(1,50, rec->list[d1.seq].resident_name))
		,fin 						= trim(substring(1,50, rec->list[d1.seq].fin))
		,weight_dt					= format(rec->list[d1.seq].weight_dt, "mm/dd/yyyy hh:mm;;q")
		,weight						= trim(substring(1,50, build2(rec->list[d1.seq].weight, " ", rec->list[d1.seq].units)))
;		,units						= trim(substring(1,50, rec->list[d1.seq].units))
		,order_dt 					= format(rec->list[d1.seq].order_dt, "mm/dd/yyyy hh:mm;;q")
		,order_mnemonic				= trim(substring(1,50, rec->list[d1.seq].order_mnemonic))
		,frequency					= trim(substring(1,50, rec->list[d1.seq].frequency))
;		,personid 					= rec->list[d1.seq].personid
;		,encntrid 					= rec->list[d1.seq].encntrid
		,orderid 					= rec->list[d1.seq].orderid
;		,eventid					= rec->list[d1.seq].eventid
;		,rec_cnt					= rec->rec_cnt
 
	from
		(DUMMYT d1  with seq = size(rec->list, 5))
 
	plan d1
 
	order by facility_abbr, nurse_unit, room, bed, patient_name, weight_dt,
		rec->list[d1.seq].encntrid, rec->list[d1.seq].eventid, rec->list[d1.seq].orderid
 
	with nocounter, separator = " ", format
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
;call echorecord(a)
;go to exitscript
 
#exitscript
end
go
 

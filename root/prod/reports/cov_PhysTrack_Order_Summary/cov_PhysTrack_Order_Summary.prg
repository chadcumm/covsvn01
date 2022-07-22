/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		March 2021
	Solution:
	Source file name:	cov_PhysTrack_Order_Summary.prg
	Object name:		cov_PhysTrack_Order_Summary
	CR#:				6010
 
	Program purpose:
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_PhysTrack_Order_Summary:DBA go
create program cov_PhysTrack_Order_Summary:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 0
	, "Order Status" = 0.0
	, "Action Type" = 0.00
	, "Communication Type" = 0.00
	, "Patient Type" = 0.00
	, "FIN" = ""                             ;* Optional
	, "Orderable Name" = ""                  ;* ( Use * for wildcard )
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	ORDER_STATUS_PMPT, ACTION_TYPE_PMPT, COMMUNICATION_TYPE_PMPT, PATIENT_TYPE_PMPT, FIN_PMPT,
	ORDER_NAME_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 rec_cnt						= i4
	1 username						= vc
	1 startdate						= vc
	1 enddate						= vc
	1 fac_code	= f8
	1 list[*]
		2 facility      			= vc
		2 nurse_unit    			= vc
		2 patient_name				= vc
		2 patient_fin       		= vc
		2 admit_dt					= dq8
		2 discharge_dt				= dq8
		2 attend_phys				= vc
		2 admit_type				= vc
		2 encntr_type				= vc
		2 encntr_id					= f8
		2 person_id					= f8
		2 ord_cnt					= i4
		2 ord_qual[*]
			3 ord_primary_name		= vc
			3 order_status			= vc
			3 action_type			= vc
			3 communication_type	= vc
			3 ordering_phys			= vc
			3 ord_requested_dt		= dq8
			3 ord_entered_by		= vc
;;			3 ord_dischg_dt			= dq8
			3 order_dt				= dq8
			3 order_id				= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
; PROMPT VARIABLES
declare OPR_FIN_VAR		   			= vc with noconstant(fillstring(1000," "))
declare OPR_FAC_VAR		   			= vc with noconstant(fillstring(1000," "))
declare	OPR_ORDER_STATUS_VAR		= vc with noconstant(fillstring(1000," "))
declare	OPR_COMMUNICATION_TYPE_VAR	= vc with noconstant(fillstring(1000," "))
declare OPR_ACTION_TYPE_VAR			= vc with noconstant(fillstring(1000," "))
declare	OPR_PATIENT_TYPE_VAR		= vc with noconstant(fillstring(1000," "))
declare	OPR_ORDER_NAME_VAR			= vc with noconstant(fillstring(1000," "))
 
; DATA SELECTION VARIABLES
declare FIN_VAR            			= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare ORD_ACTIVE_STATUS_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",  48, "ACTIVE")),protect
declare ORDERING_PHYS_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",6003, "ORDER")),protect
declare ATTEND_PHYS_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN")),protect
 
; ACTION TYPE
declare CANCEL_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "CANCEL")),protect
declare CANCEL_DISCONT_VAR          = f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "CANCELDISCONTINUE")),protect
declare COMPLETE_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "COMPLETE")),protect
declare DISCONTINUE_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "DISCONTINUE")),protect
declare MODIFY_VAR 		          	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "MODIFY")),protect
declare ORDER_VAR  		          	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER")),protect
declare RENEW_VAR  		          	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "RENEW")),protect
declare VOID_VAR  		          	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "VOID")),protect
 
; COMMUNICATION TYPE
declare CONTINCYELECT_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "CONTINGENCYELECTRONICORDERNOCOSIGN")),protect
declare COSIGNREQUIRED_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "COSIGNREQUIRED_VAR")),protect
declare DIRECT_VAR  		        = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "DIRECT")),protect
declare DISCERNEXPERT_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "DISCERNEXPERT")),protect
declare DISCONTRANS_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "DISCONTTRANSITIONCAREORDERNOCOSIGN")),protect
declare ESIDEFAULT_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "ESIDEFAULT")),protect
declare ELECTRONICNOCOSIGN_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "ELECTRONICNOCOSIGN")),protect
declare INITPLANORDER_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "INITIATEPLANNEDORDERSNOCOSIGN")),protect
declare NOCOSIGNREQUIRED_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "NOCOSIGNREQUIRED")),protect
declare PERNUTRITIONPOLICY_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "PERNUTRITIONPOLICYNOCOSIGN")),protect
declare PERPTPOLICY_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "PERPTPOLICYNOCOSIGN")),protect
declare PERPROTOCOL_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "PERPROTOCOLNOCOSIGN")),protect
declare PROPOSED_VAR  		        = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "PROPOSED")),protect
declare STANDINGORDER_VAR  		    = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "STANDINGORDERCOSIGN")),protect
declare TELEPHONEREADBACK_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "TELEPHONEREADBACKVERIFIEDCOSIGN")),protect
declare VERBALREADBACKVERIFIED_VAR  = f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "VERBALREADBACKVERIFIEDCOSIGN")),protect
declare WRITTENPAPERORDER_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY", 6006, "WRITTENPAPERORDERFAXNOCOSIGN")),protect
 
; PATIENT ENCOUNTER TYPE
declare INPATIENT_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT")),protect
declare OUTPATIENT_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENT")),protect
declare OBSERVATION_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION")),protect
declare EMERGENCY_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "EMERGENCY")),protect
declare DAYSURGERY_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "DAYSURGERY")),protect
declare PREREG_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "PREREG")),protect
declare PREADMISSION_VAR            = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "PREADMISSION")),protect
declare HOSPICE_INP_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "HOSPICEINPATIENT")),protect
declare BEHAVIOURHLTH_VAR           = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "BEHAVIORALHEALTH")),protect
declare CARDIOPULMREHAB_VAR         = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CARDIOPULMONARYREHAB")),protect
declare NEWBORN_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NEWBORN")),protect
declare REHABINP_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "REHABINPATIENT")),protect
declare SNFINP_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "SNFINPATIENT")),protect
 
; MISC VARIABLES
declare username           			= vc with protect
declare initcap()          			= c100
declare num				   			= i4 with noconstant(0)
declare REQSTARTDTTM_VAR			= f8 with constant(51.00)
;
declare	START_DATETIME				= f8
declare END_DATETIME				= f8
 
 
/**************************************************************
; DVDev START CODING
**************************************************************/
; GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
; GET FACILITY CODE FROM FIN ENTRY (if entered)
select
from ENCOUNTER e
	,ENCNTR_ALIAS ea
plan e
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = FIN_VAR ;1077
	and ea.alias = $FIN_PMPT
detail
	rec->fac_code = e.loc_facility_cd
with nocounter
 
 
; SET FACILITY PROMPT VARIABLE
if ($FIN_PMPT = null)
	set OPR_FAC_VAR = build2("e.loc_facility_cd = ", $FACILITY_PMPT)
else
	set OPR_FAC_VAR = build2("e.loc_facility_cd = ", rec->fac_code)
endif
 
; SET ORDER STATUS PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($ORDER_STATUS_PMPT),0))) = "L")	;multiple values were selected
	set OPR_ORDER_STATUS_VAR = "in"
elseif(parameter(parameter2($ORDER_STATUS_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_ORDER_STATUS_VAR = "!="
else																			;a single value was selected
	set OPR_ORDER_STATUS_VAR = "="
endif
 
; SET ORDER ACTION TYPE PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($ACTION_TYPE_PMPT),0))) = "L")	;multiple values were selected
	set OPR_ACTION_TYPE_VAR = "in"
elseif(parameter(parameter2($ACTION_TYPE_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_ACTION_TYPE_VAR = "!="
else																			;a single value was selected
	set OPR_ACTION_TYPE_VAR = "="
endif
 
; SET COMMUNICATION TYPE PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($COMMUNICATION_TYPE_PMPT),0))) = "L")	;multiple values were selected
	set OPR_COMMUNICATION_TYPE_VAR = "in"
elseif(parameter(parameter2($COMMUNICATION_TYPE_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_COMMUNICATION_TYPE_VAR = ">="
else																				;a single value was selected
	set OPR_COMMUNICATION_TYPE_VAR = "="
endif
 
; SET PATIENT TYPE PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($PATIENT_TYPE_PMPT),0))) = "L")	;multiple values were selected
	set OPR_PATIENT_TYPE_VAR = "in"
elseif(parameter(parameter2($PATIENT_TYPE_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_PATIENT_TYPE_VAR = "!="
else																			;a single value was selected
	set OPR_PATIENT_TYPE_VAR = "="
endif
 
 
; SET FIN PROMPT VARIABLE
if ($FIN_PMPT = null)
	set OPR_FIN_VAR = ">="
else
	set OPR_FIN_VAR = "="
endif
 
 
; SET ORDER NAME PROMPT VARIABLE
if ($ORDER_NAME_PMPT = null)
	set OPR_ORDER_NAME_VAR = "cnvtupper(oc.primary_mnemonic) != null"
else
	set OPR_ORDER_NAME_VAR = build2('cnvtupper(oc.primary_mnemonic) = "', $ORDER_NAME_PMPT, '"')
	if ($FACILITY_PMPT = null)
		;select all facilities for order name
		set OPR_FAC_VAR = "e.loc_facility_cd > 0"
	else
		;select order name for selected facility
		set OPR_FAC_VAR = build2("e.loc_facility_cd = ", $FACILITY_PMPT)
	endif
endif
 
 
; SET DATE PROMPTS TO DATE VARIABLES
set START_DATETIME = cnvtdatetime($START_DATETIME_PMPT)
set END_DATETIME   = cnvtdatetime($END_DATETIME_PMPT)
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME = cnvtdatetime("01-MAY-2020 07:00:00")
;set END_DATETIME   = cnvtdatetime("02-MAY-2020 07:00:00")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME, "mm/dd/yyyy hh:mm;;q")
set rec->enddate   = format(END_DATETIME, "mm/dd/yyyy hh:mm;;q")
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select distinct into "NL:"
from ENCOUNTER e
 
	,(inner join ORDERS o on o.encntr_id = e.encntr_id
		and (o.orig_order_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME))
		and operator(o.order_status_cd, OPR_ORDER_STATUS_VAR, $ORDER_STATUS_PMPT)
		and operator(o.latest_communication_type_cd, OPR_COMMUNICATION_TYPE_VAR, $COMMUNICATION_TYPE_PMPT)
;		and o.order_status_cd in ()
		and o.latest_communication_type_cd in (CONTINCYELECT_VAR, COSIGNREQUIRED_VAR, DIRECT_VAR, DISCERNEXPERT_VAR, DISCONTRANS_VAR,
			ESIDEFAULT_VAR, ELECTRONICNOCOSIGN_VAR, INITPLANORDER_VAR, NOCOSIGNREQUIRED_VAR, PERNUTRITIONPOLICY_VAR, PERPTPOLICY_VAR,
			PERPROTOCOL_VAR, PROPOSED_VAR, STANDINGORDER_VAR, TELEPHONEREADBACK_VAR, VERBALREADBACKVERIFIED_VAR, WRITTENPAPERORDER_VAR)
		and o.active_status_cd = ORD_ACTIVE_STATUS_VAR ;188
		and o.active_ind = 1)
 
	,(inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_sequence = o.last_action_sequence
		and operator(oa.action_type_cd, OPR_ACTION_TYPE_VAR, $ACTION_TYPE_PMPT)
		and oa.action_type_cd in (CANCEL_VAR, CANCEL_DISCONT_VAR, COMPLETE_VAR, DISCONTINUE_VAR,
			MODIFY_VAR, ORDER_VAR, RENEW_VAR, VOID_VAR)
		and oa.action_sequence > 0)
 
	,(left join ORDER_ACTION oa2 on oa2.order_id = o.order_id
		and oa2.action_type_cd = ORDERING_PHYS_VAR ;2534
		and oa2.action_sequence > 0)
 
	,(left join ORDER_DETAIL od on od.order_id = o.order_id
;		and od.oe_field_meaning = "REQSTARTDTTM")
		and	od.oe_field_meaning_id = REQSTARTDTTM_VAR) ;51
 
	,(inner join ORDER_CATALOG oc on oc.catalog_cd = o.catalog_cd
		and PARSER(OPR_ORDER_NAME_VAR)
		and oc.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
;		and ea.alias = "2100400055"
		and operator(ea.alias, OPR_FIN_VAR, $FIN_PMPT)
		and ea.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
;		and p.person_id =    16396313.00
		and p.active_ind = 1)
 
	,(left join ENCNTR_PRSNL_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.encntr_prsnl_r_cd = ATTEND_PHYS_VAR ;1119
		and epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and epr.active_ind = 1)
 
	,(left join PRSNL pl1 on pl1.person_id = epr.prsnl_person_id
		and pl1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl1.active_ind = 1)
 
	,(left join PRSNL pl2 on pl2.person_id = oa2.order_provider_id ;oa2.action_personnel_id
		and pl2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl2.active_ind = 1)
 
	,(left join PRSNL pl3 on pl3.person_id = oa.action_personnel_id
		and pl3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl3.active_ind = 1)
 
where PARSER(OPR_FAC_VAR)
	and operator(e.encntr_type_cd, OPR_PATIENT_TYPE_VAR, $PATIENT_TYPE_PMPT)
    and e.encntr_type_cd in (INPATIENT_VAR, OUTPATIENT_VAR, OBSERVATION_VAR, EMERGENCY_VAR, DAYSURGERY_VAR, PREREG_VAR,
		PREADMISSION_VAR, HOSPICE_INP_VAR, BEHAVIOURHLTH_VAR, CARDIOPULMREHAB_VAR, NEWBORN_VAR, REHABINP_VAR, SNFINP_VAR)
	and e.encntr_id != 0.00
	and e.active_ind = 1
 
order by e.encntr_id, o.order_id
 
head report
	cnt  = 0
	ocnt = 0
 
	call alterlist(rec->list, 10)
 
head e.encntr_id
 
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 10)
		call alterlist(rec->list, cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit		= uar_get_code_display(e.loc_nurse_unit_cd)
	rec->list[cnt].patient_name		= p.name_full_formatted
	rec->list[cnt].patient_fin 		= ea.alias
	rec->list[cnt].admit_dt			= e.reg_dt_tm
	rec->list[cnt].discharge_dt		= e.disch_dt_tm
	rec->list[cnt].attend_phys		= pl1.name_full_formatted
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	rec->list[cnt].admit_type		= uar_get_code_display(e.admit_type_cd)
	rec->list[cnt].encntr_id		= e.encntr_id
	rec->list[cnt].person_id		= p.person_id
 
	ocnt = 0
 
head o.order_id
 
	ocnt = ocnt + 1
 
	call alterlist(rec->list[cnt].ord_qual, ocnt)
 
	rec->list[cnt].ord_cnt = ocnt
 
	rec->list[cnt].ord_qual[ocnt].ord_primary_name		= oc.primary_mnemonic ;o.order_mnemonic
	rec->list[cnt].ord_qual[ocnt].order_status			= uar_get_code_display(o.order_status_cd)
	rec->list[cnt].ord_qual[ocnt].action_type			= uar_get_code_display(oa.action_type_cd)
	rec->list[cnt].ord_qual[ocnt].communication_type	= uar_get_code_display(o.latest_communication_type_cd)
	rec->list[cnt].ord_qual[ocnt].ordering_phys			= pl2.name_full_formatted ;ordered by
	rec->list[cnt].ord_qual[ocnt].order_dt				= o.orig_order_dt_tm
;;	rec->list[cnt].ord_qual[ocnt].ord_dischg_dt			= o.orig_order_dt_tm
	rec->list[cnt].ord_qual[ocnt].ord_requested_dt		= od.oe_field_dt_tm_value
	rec->list[cnt].ord_qual[ocnt].ord_entered_by		= trim(pl3.name_full_formatted,3)
	rec->list[cnt].ord_qual[ocnt].order_id				= o.order_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter, time=300
;
call echorecord(rec)
;go to exitscript
 
 
;====================================================
; REPORT OUTPUT
;====================================================
if (rec->rec_cnt > 0)
 
	select into value ($OUTDEV)
		 facility      		= rec->list[d.seq].facility
		,nurse_unit    		= substring(1,40,trim(rec->list[d.seq].nurse_unit,3))
		,patient_fin		= rec->list[d.seq].patient_fin
		,patient_name		= substring(1,40,trim(rec->list[d.seq].patient_name,3))
		,requested_dt		= format(rec->list[d.seq].ord_qual[d2.seq].ord_requested_dt, "mm/dd/yyyy hh:mm;;q")
		,order_primary_name	= substring(1,90,rec->list[d.seq].ord_qual[d2.seq].ord_primary_name)
		,order_status		= substring(1,40,rec->list[d.seq].ord_qual[d2.seq].order_status)
		,action_type		= substring(1,30,rec->list[d.seq].ord_qual[d2.seq].action_type)
		,communication_type	= substring(1,40,rec->list[d.seq].ord_qual[d2.seq].communication_type)
		,ordered_by			= rec->list[d.seq].ord_qual[d2.seq].ordering_phys
		,entered_by			= substring(1,40,rec->list[d.seq].ord_qual[d2.seq].ord_entered_by)
		,admit_dt			= format(rec->list[d.seq].admit_dt, "mm/dd/yyyy hh:mm;;q")
;;		,dischg_dt 			= format(rec->list[d.seq].ord_dischg_dt, "mm/dd/yyyy hh:mm;;q")
		,discharge_dt		= format(rec->list[d.seq].discharge_dt, "mm/dd/yyyy hh:mm;;q")
		,patient_type		= substring(1,30,rec->list[d.seq].encntr_type)
		,attending_provider	= substring(1,30,rec->list[d.seq].attend_phys)
;
;		,order_dt			= format(rec->list[d.seq].ord_qual[d2.seq].order_dt, "mm/dd/yyyy hh:mm;;q")
;		,admit_type			= rec->list[d.seq].admit_type
;		,username      		= rec->username
;		,startdate			= rec->startdate
;		,enddate			= rec->enddate
;		,rec_cnt			= rec->rec_cnt
;		,encntr_id     		= rec->list[d.seq].encntr_id
;		,person_id			= rec->list[d.seq].person_id
;		,order_id	   		= rec->list[d.seq].ord_qual[d2.seq].order_id
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
		,(DUMMYT d2 with seq = 1)
 
	plan d where maxrec(d2, SIZE(rec->list[d.seq].ord_qual,5))
 
	join d2
 
	order by facility, nurse_unit, patient_name, order_primary_name,
		rec->list[d.seq].encntr_id, rec->list[d.seq].ord_qual[d2.seq].order_id
	;, rec->list[d.seq].encntr_id, rec->list[d.seq].ord_qual[d2.seq].order_id ;, order_dt desc;, encntr_id, order_id
 
	with nocounter, format, check, separator = " ", outerjoin=d2
 
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
 

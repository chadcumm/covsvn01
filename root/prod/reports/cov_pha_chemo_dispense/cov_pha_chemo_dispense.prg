/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		April 2022
	Solution:
	Source file name:	cov_pha_chemo_dispense.prg
	Object name:		cov_pha_chemo_dispense
	CR#:				12753
 
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
 
drop program cov_pha_chemo_dispense:DBA go
create program cov_pha_chemo_dispense:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Discharge Begin DT/TM" = "SYSDATE"
	, "Discharge End DT/TM" = "SYSDATE"
	, "Facility" = 0 

with OUTDEV, STARTDATE_PMPT, ENDDATE_PMPT, FACILITY_PMPT
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 rec_cnt				= i4
	1 username				= vc
	1 startdate				= vc
	1 enddate				= vc
	1 list[*]
		2 facility      	= vc
		2 fin		    	= vc
		2 units				= vc
		2 pname				= vc
		2 dml			    = vc
		2 etc				= vc
		2 ddt				= dq8
		2 disp_type			= vc
		2 dose_qty			= f8
		2 aname				= vc
		2 ploc				= vc
		2 ot				= vc
		2 cstat				= vc
		2 admin_dt			= dq8
		2 route				= vc
		2 init_dose_cnt		= i4
		2 extra_dose_cnt	= i4
		2 encntr_id			= f8
		2 person_id			= f8
		2 order_id			= f8
	)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
; PROMPT VARIABLES
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
 
; DATA SELECTION VARIABLES
declare FIN_VAR         	= f8 with constant(uar_get_code_by("DISPLAYKEY", 319,"FINNBR")),protect
declare ORD_SOURCE_VAR     	= f8 with constant(uar_get_code_by("DISPLAYKEY",6500, "RETAIL")),protect
declare INITIAL_DOSE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",4032, "INITIALDOSES")),protect
declare EXTRA_DOSE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",4032, "EXTRADOSE")),protect
declare CHEMOCONTCOA_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",4008, "CHEMOCONTCOA")),protect
declare CHEMOCONTCOD_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",4008, "CHEMOCONTCOD")),protect
declare CHEMOIVPBCOA_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",4008, "CHEMOIVPBCOA")),protect
declare CHEMOIVPBCOD_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",4008, "CHEMOIVPBCOD")),protect
declare CHEMOMEDCOA_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",4008, "CHEMOMEDCOA")),protect
declare CHEMOMEDCOD_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",4008, "CHEMOMEDCOD")),protect

; MISC VARIABLES
declare username           	= vc with protect
declare initcap()          	= c100
declare num				   	= i4 with noconstant(0)
;
declare	START_DATETIME		= f8
declare END_DATETIME		= f8
 
 
;SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
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
 
 
; SET DATE PROMPTS TO DATE VARIABLES
set START_DATETIME = cnvtdatetime($STARTDATE_PMPT)
set END_DATETIME   = cnvtdatetime($ENDDATE_PMPT)
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
set START_DATETIME = cnvtdatetime("01-MAR-2022 00:00:00")
set END_DATETIME   = cnvtdatetime("31-MAR-2022 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME, "mm/dd/yyyy hh:mm;;q")
set rec->enddate   = format(END_DATETIME, "mm/dd/yyyy hh:mm;;q")
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select into "NL:"
from DISPENSE_HX d
 
	,(inner join PROD_DISPENSE_HX p on p.dispense_hx_id = d.dispense_hx_id)
 
	,(inner join ORDERS o on o.order_id = d.order_id)
 
	,(inner join ORDER_DISPENSE od on od.order_id = d.order_id)
 
	,(inner join PERSON pe on pe.person_id = o.person_id
		and pe.name_last_key not in ("AAA*","FFF*","HHH*","OOO*","TTT*","XXX*","YYY*","ZZZ*"))
 
	,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
		and e.loc_facility_cd in (2552503635, 21250403, 2552503653, 2552503639, 2552503613, 2552503645, 2552503649))
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = o.encntr_id
;		and ea.alias = "1914902114"
   		and ea.encntr_alias_type_cd = FIN_VAR) ;1077.00
 
	,(left join CLINICAL_EVENT ce on ce.order_id = o.order_id
		and ce.event_class_cd = 232) ;MED
 
	,(left join CE_MED_RESULT cmr on cmr.event_id = ce.event_id)
 
	,(inner join PRSNL pl on pl.person_id = d.updt_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl.active_ind = 1)

where (d.dispense_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME))
	and d.disp_event_type_cd in (INITIAL_DOSE_VAR, EXTRA_DOSE_VAR) ;2346, 2344
	and d.dispense_category_cd in (CHEMOCONTCOA_VAR, CHEMOCONTCOD_VAR, CHEMOIVPBCOA_VAR,  
		CHEMOIVPBCOD_VAR, CHEMOMEDCOA_VAR, CHEMOMEDCOD_VAR) ;318427, 681407, 681408, 2558050629, 2558050675, 2558050717
	and d.charge_ind = 1
 
head report
	cnt  = 0
;	call alterlist(rec->list, 10)
 
detail
 
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].pname			= pe.name_full_formatted
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].units			= uar_get_code_display(ce.result_units_cd)
	rec->list[cnt].dml		 		= o.dept_misc_line
	rec->list[cnt].etc				= uar_get_code_display (d.disp_event_type_cd )
	rec->list[cnt].ddt				= d.dispense_dt_tm
	rec->list[cnt].disp_type		= uar_get_code_display(d.disp_event_type_cd)
	rec->list[cnt].dose_qty			= d.doses ;p.dose_qty
	rec->list[cnt].aname			= pl.name_full_formatted
	rec->list[cnt].ploc				= trim(uar_get_code_display(e.loc_nurse_unit_cd ),3)
	rec->list[cnt].ot				= if (o.source_cd = ORD_SOURCE_VAR) "Retail" else "Inpatient" endif ;4054155
	rec->list[cnt].cstat			= if (d.charge_ind = 1) "Charged" elseif (d.charge_ind = 0) "Not charged" endif
	rec->list[cnt].admin_dt	 		= ce.event_end_dt_tm
	rec->list[cnt].route			= uar_get_code_display(cmr.admin_route_cd)
	rec->list[cnt].encntr_id		= e.encntr_id
	rec->list[cnt].person_id		= pe.person_id
	rec->list[cnt].order_id			= o.order_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;====================================================
; REPORT OUTPUT
;====================================================
if (rec->rec_cnt > 0)
 
	select distinct into value ($OUTDEV)
		 facility      			= rec->list[d.seq].facility
		,patient_name    		= substring(1,40,trim(rec->list[d.seq].pname,3))
		,patient_location		= substring(1,60,rec->list[d.seq].ploc)
		,fin					= rec->list[d.seq].fin
;		,units					= substring(1,40,trim(rec->list[d.seq].units,3))
		,description			= substring(1,200,rec->list[d.seq].dml)
;		,etc					= substring(1,40,rec->list[d.seq].etc)
		,dispense_type			= substring(1,60,rec->list[d.seq].disp_type)
		,dispense_dt			= format(rec->list[d.seq].ddt, "mm/dd/yyyy hh:mm;;q")
		,dose_qty				= rec->list[d.seq].dose_qty
		,pharmacist				= substring(1,60,rec->list[d.seq].aname)
;		,ot						= substring(1,60,rec->list[d.seq].ot)
		,charged				= substring(1,60,rec->list[d.seq].cstat)
		,route					= substring(1,60,rec->list[d.seq].route)
		,admin_dt				= format(rec->list[d.seq].admin_dt, "mm/dd/yyyy hh:mm;;q")
;		,init_dose_cnt			= 0
;		,extra_dose_cnt			= 0
;		,username      			= rec->username
;		,startdate				= rec->startdate
;		,enddate				= rec->enddate
;		,rec_cnt				= rec->rec_cnt
;		,encntr_id     			= rec->list[d.seq].encntr_id
;		,person_id				= rec->list[d.seq].person_id
		,order_id	   			= rec->list[d.seq].order_id
;		,pmpt_startdate			= rec->startdate
;		,pmpt_enddate			= rec->enddate
 
	from (DUMMYT d  with seq = value(size(rec->list,5)))
 
	order by facility, patient_name, description, dispense_dt, pharmacist, order_id
 
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
 
/* 
;	,(inner join ORDER_ACTION oa on oa.order_id = d.order_id
;		and oa.action_type_cd = 2534) ;ORDER


select cv.code_value, cv.display
from code_value cv
where cv.cdf_meaning = "FACILITY"
    and cv.active_ind = 1
    and cv.code_value in (2552503635, 21250403, 2552503653, 2552503639, 2552503613, 2552503645, 2552503649) ;FACILITIES
order by cv.display
*/
 
/*
and (p.name_last_key in
        ( "AAA*"
         ,"FFF*"
         ,"HHH*"
        )
       or p.name_last_key in
        ( "OOO*"
From Jeffrey Bernstein to Everyone 10:42 AM
and (p.name_last_key in
        ( "AAA*"
         ,"FFF*"
         ,"HHH*"
        )
       or p.name_last_key in
        ( "OOO*"
         ,"TTT*"
         ,"XXX*"
        )
       or p.name_last_key in
        ( "YYY*"
         ,"ZZZ*"
        )
      ) ; end of the AND/OR
*/
 
/*
;	 pname 	= pe.name_full_formatted
;;	,units = uar_get_code_display(ce.result_units_cd)
;;	,ce_result = ce.result_val
;;	,ce_event_dt = format(ce.event_end_dt_tm, "mm/dd/yyyy hh:mm")
;;	,ce_event_type = uar_get_code_display(ce.event_class_cd)
;  	,fin 	= ea.alias ";l"
;  	,dml 	= o.dept_misc_line ";l"
;;  	,etc 	= uar_get_code_display (d.disp_event_type_cd )
;  	,ddt 	= format(d.dispense_dt_tm, "mm/dd/yyyy hh:mm:ss")
;	,disp_type = uar_get_code_display(d.disp_event_type_cd)
;	,init_cnt = count(ea.alias) over(partition by d.disp_event_type_cd)
;	,aname 	= pl.name_full_formatted
;;	,auname	= pl.username
;;	,apos	= uar_get_code_display(pl.position_cd)
;;	,adt	= format(oa.action_dt_tm, "mm/dd/yyyy hh:mm")
;;	,atype	= uar_get_code_display(oa.action_type_cd)
;  	,ploc 	= trim(uar_get_code_display(e.loc_nurse_unit_cd ),3) ;";l"
;;  	,dloc 	= uar_get_code_display (d.disp_loc_cd ) ";l"
;;  	,etc 	= uar_get_code_display (d.disp_event_type_cd ) ";l"
;  	,ot 	= if (o.source_cd = ORD_SOURCE_VAR) "Retail" else "Inpatient" endif ;4054155
;  	,cstat 	= if (d.charge_ind = 1) "Charged" elseif (d.charge_ind = 0) "Not charged" endif
;	,admin_dt = format(cmr.admin_dt_tm, "mm/dd/yyyy hh:mm")
;	,route = uar_get_code_display(cmr.admin_route_cd)
;;	,admin_dosage = cmr.admin_dosage
;;	,dosage_unit = uar_get_code_display(cmr.dosage_unit_cd)
;;	,infused_vol = cmr.infused_volume
;;	,infused_vol_unit = uar_get_code_display(cmr.infused_volume_unit_cd)
;;  	,dcrg 	= p.charge_qty ";l"
;;  	,dcrd 	= if (p.credit_qty = 0) p.credit_qty elseif (p.credit_qty > 0) - (p.credit_qty) endif
;;  	,prc 	= od.order_price_value
;;  	,cst 	= od.order_cost_value
;;  	,tcst 	= (od.order_cost_value * p.charge_qty)
;;  	,tprc 	= (od.order_price_value * p.charge_qty)
;;  	,tcrd 	= (if ((p.credit_qty = 0)) p.credit_qty elseif ((p.credit_qty > 0)) - (p.credit_qty) endif
;;  				* od.order_cost_value)
;;    ,cqty 	= p.credit_qty
;;  	,cvlu 	= od.order_cost_value
;  	,encntr_id 	= e.encntr_id
;	,person_id	= e.person_id
;	,order_id	= o.order_id
;;  	,oid 	= o.order_id ";l"
;;	,cmr.*
*/

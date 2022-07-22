/*******************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
********************************************************************************************
	Author:				Dan Herren
	Date Written:		May 2019
	Solution:			Pharmacy
	Source file name:  	cov_pha_DispenseCost.prg
	Object name:		cov_pha_DispenseCost
	Layout file name:   n/a
	CR#:				4952
 
	Program purpose:	Dispense info for Meds.
	Executing from:		CCL
  	Special Notes:		Translated from Cerner report "PHA_DISPENSE_COSTS"
	Menu Location:		Pharmacy > Pharmacy User Reports > Medication Dispenses
 
/*******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #  Mod Date    Developer             	Comment
*	----------	----------	--------------------	----------------------------------------
*	001			May 2019	Dan Herren				CR4952 - Added Order Actions Personnel,
*													Postion, Username, DT/TM, Type.
*													(aname,auname,apos,adt,atype)
*
********************************************************************************************/
drop program cov_pha_DispenseCost :dba go
create program cov_pha_DispenseCost :dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Select Start Dispense Date:" = "SYSDATE"
	, "End Dispense Date:" = "SYSDATE"
	, "* Facility:" = 0
 
with OUTDEV, BEGINDISPENSEDATE, ENDDISPENSEDATE, FAC
 
select distinct into $OUTDEV
	 pname 	= pe.name_full_formatted ";l"
  	,fin 	= ea.alias ";l"
  	,dml 	= o.dept_misc_line ";l"
  	,etc 	= uar_get_code_display (d.disp_event_type_cd ) ";l"
  	,ddt 	= format(d.dispense_dt_tm, "mm/dd/yyyy hh:mm")
	,aname 	= pl.name_full_formatted
	,auname	= pl.username
	,apos	= uar_get_code_display(pl.position_cd)
	,adt	= format(oa.action_dt_tm, "mm/dd/yyyy hh:mm")
	,atype	= uar_get_code_display(oa.action_type_cd)
  	,ploc 	= trim(uar_get_code_display (e.loc_nurse_unit_cd ),3) ";l"
  	,dloc 	= uar_get_code_display (d.disp_loc_cd ) ";l"
  	,etc 	= uar_get_code_display (d.disp_event_type_cd ) ";l"
  	,ot 	= if (o.source_cd = 4054155.00) "Retail" else "Inpatient" endif
  	,cstat 	= if (d.charge_ind = 1) "Charged" elseif (d.charge_ind = 0) "Not charged" endif
;  	,dcrg 	= p.charge_qty ";l"
;  	,dcrd 	= if (p.credit_qty = 0) p.credit_qty elseif (p.credit_qty > 0) - (p.credit_qty) endif
;  	,prc 	= od.order_price_value
;  	,cst 	= od.order_cost_value
;  	,tcst 	= (od.order_cost_value * p.charge_qty)
;  	,tprc 	= (od.order_price_value * p.charge_qty)
;  	,tcrd 	= (if ((p.credit_qty = 0)) p.credit_qty elseif ((p.credit_qty > 0)) - (p.credit_qty) endif
;  				* od.order_cost_value)
;    ,cqty 	= p.credit_qty
;  	,cvlu 	= od.order_cost_value
;  	,eid 	= e.encntr_id
;  	,oid 	= o.order_id ";l"
 
from DISPENSE_HX d
 
	,(inner join PROD_DISPENSE_HX p on p.dispense_hx_id = d.dispense_hx_id)
 
	,(inner join ORDERS o on o.order_id = d.order_id)
 
	,(inner join ORDER_DISPENSE od on od.order_id = d.order_id)
 
	,(inner join PERSON pe on pe.person_id = o.person_id)
 
	,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
   		and e.loc_facility_cd in ($FAC))
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = o.encntr_id
;			and ea.alias = "1914902114"
   		and ea.encntr_alias_type_cd = 1077.00) ;FIN
 
	,(inner join ORDER_ACTION oa on oa.order_id = d.order_id)
 
	,(inner join PRSNL pl on pl.person_id = d.updt_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl.active_ind = 1)
 
where (d.dispense_dt_tm between cnvtdatetime($BEGINDISPENSEDATE) and cnvtdatetime($ENDDISPENSEDATE))
	and d.charge_ind = 1
 
order by pe.name_full_formatted, d.dispense_dt_tm, d.rowid, oa.action_dt_tm, e.encntr_id, o.order_id
 
with nocounter ,separator = " " ,format
 
end go
 

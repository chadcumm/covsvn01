/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren / Chad Cummings
	Date Written:		May 2021
	Solution:
	Source file name:	cov_eicu_st_common.inc
	Object name:		cov_eicu_st_common.inc
	CR#:				9684
 
	Program purpose:	Smart Template - EICU Common Utilities
	Executing from:		cov_st_vent_days, cov_st_hosp_days, cov_st_icu_days
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
/*
record request
	(
	  1 output_device     = vc
	  1 script_name       = vc
	  1 person_cnt        = i4
	  1 person[*]
	      2 person_id     = f8
	  1 visit_cnt = i4
	  1 visit[*]
	      2 encntr_id     = f8
	  1 prsnl_cnt = i4
	  1 prsnl[*]
	      2 prsnl_id      = f8
	  1 nv_cnt = i4
	  1 nv[*]
	      2 pvc_name      = vc
	      2 pvc_value     = vc
	  1 batch_selection   = vc
	)
*/
 
if (not(validate(reply,0)))
record  reply (
	1 text 						= vc
	1 status_data
	 	2 status 				= c1
	 	2 subeventstatus[1]
	  		3 operationname 	= c15
	  		3 operationstatus 	= c1
	  		3 targetobjectname 	= c15
	  		3 targetobjectvalue = c100
	)
endif
 
record rec (
	1 rec_cnt					= i4
	1 username					= vc
	1 list[*]
		2 facility      		= vc
		2 unit    				= vc
		2 unit_hist				= vc
		2 pat_name				= vc
		2 fin					= vc
		2 reg_dt				= dq8
		2 inpat_admit_dt		= dq8
		2 discharge_dt			= dq8
		2 hospital_days			= f8
		2 loc_admit_transfer	= vc
		2 request_dt			= dq8
		2 stop_dt				= dq8
		2 icu_days				= f8
		2 vent_start_dt			= dq8
		2 vent_stop_dt			= dq8
		2 vent_days				= f8
		2 encntr_type			= vc
		2 encntr_id				= f8
		2 person_id				= f8
		2 event_id				= f8
		2 order_id				= f8
		2 order_mnem			= vc
	)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare PSO_ADMIT_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "PSOADMITTOINPATIENT")),protect
declare ORDERED_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",6004, "ORDERED")),protect
declare VENT_ACTIVITY_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",  72, "VENTILATORACTIVITY")),protect
;
declare username           	= vc with protect
declare initcap()          	= c100
declare num				   	= i4 with noconstant(0)
 
 
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
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select ;distinct
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
;		and ea.alias = "2107600004"
		and ea.active_ind = 1)
 
	,(left join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
;		and (e.reg_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
		and elh.active_ind = 1)
 
	,(inner join ORDERS o on o.encntr_id = e.encntr_id
		and o.catalog_cd = PSO_ADMIT_VAR ;4180632 ;PSO Admit to Inpatient
		and o.order_status_cd = ORDERED_VAR ;2550
		and o.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id and ce.person_id = e.person_id
		and ce.event_cd in (VENT_ACTIVITY_VAR) ;16806092 ;Ventilator Activity
		and ce.result_status_cd in (25,34,35) ;AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
		and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(inner join PERSON p on p.person_id = e.person_id
;		and p.person_id = 16396313.00
		and p.active_ind = 1)
 
where e.active_ind = 1
	;and (e.inpatient_admit_dt_tm between cnvtdatetime("13-APR-2021 0") and cnvtdatetime("13-APR-2021 23:59"))
	and e.encntr_id = request->visit[1].encntr_id
	;and e.encntr_id =   116741993.00
;	and e.loc_facility_cd =  21250403.00 ;FSR
 
order by e.inpatient_admit_dt_tm, e.encntr_id, ce.event_id
 
head report
	cnt  = 0
	tmp_eid = 0.0
 
	call alterlist(rec->list, 10)
 
detail
	if (tmp_eid != e.encntr_id) cnt = cnt + 1 endif
 
;	if(mod(cnt, 100) = 1 and cnt > 10)
;		call alterlist(rec->list, cnt + 9)
;	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].unit				= uar_get_code_display(elh.loc_nurse_unit_cd)
	rec->list[cnt].unit_hist		= uar_get_code_display(elh.loc_nurse_unit_cd)
	rec->list[cnt].pat_name			= p.name_full_formatted
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].reg_dt			= e.reg_dt_tm
	rec->list[cnt].inpat_admit_dt	= e.inpatient_admit_dt_tm
	rec->list[cnt].discharge_dt		= e.disch_dt_tm
	rec->list[cnt].hospital_days	=
		if (e.disch_dt_tm = null)
			round(datetimediff(cnvtdatetime(curdate,curtime3), e.inpatient_admit_dt_tm,1),0)
		else
			round(datetimediff(e.disch_dt_tm, e.inpatient_admit_dt_tm,1),0)
		endif
 	if (ce.result_val = "Ventilator initiate") 	  rec->list[cnt].vent_start_dt = ce.event_end_dt_tm endif
	if (ce.result_val = "Ventilator discontinue") rec->list[cnt].vent_stop_dt  = ce.event_end_dt_tm endif
	rec->list[cnt].vent_days		=
		if (rec->list[cnt].vent_stop_dt = null)
			round(datetimediff(cnvtdatetime(curdate,curtime3), rec->list[cnt].vent_start_dt,1),0)
		else
			round(datetimediff(rec->list[cnt].vent_stop_dt, rec->list[cnt].vent_start_dt,1),0)
		endif
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	rec->list[cnt].encntr_id		= e.encntr_id
	rec->list[cnt].person_id		= p.person_id
	rec->list[cnt].event_id			= ce.event_id
	rec->list[cnt].order_id			= o.order_id
	rec->list[cnt].order_mnem		= o.order_mnemonic
 
	tmp_eid = e.encntr_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; GET LOCATION ADMIT / TRANSFER
;============================================================================
call echo("*** GET LOCATION ADMIT / TRANSFER  ***")
 
select into "NL:"
from ORDER_DETAIL od
 
where expand(num, 1, size(rec->list, 5), od.order_id, rec->list[num].order_id)
	and od.oe_field_meaning = "ADMITTO"
 
order by od.order_id
 
detail
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), od.order_id, rec->list[numx].order_id)
 
    while(idx > 0)
		rec->list[idx].loc_admit_transfer = od.oe_field_display_value
 
 		idx = locateval(numx, idx+1, size(rec->list, 5), od.order_id, rec->list[numx].order_id)
	endwhile
 
with nocounter, expand = 1
 
 
;============================================================================
; GET REQUEST DATE
;============================================================================
call echo("*** GET REQUEST DATE  ***")
 
select into "NL:"
from ORDER_DETAIL od
 
where expand(num, 1, size(rec->list, 5), od.order_id, rec->list[num].order_id)
	and od.oe_field_meaning = "INPTADMDTETME"
 
order by od.order_id
 
detail
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), od.order_id, rec->list[numx].order_id)
 
    while(idx > 0)
		rec->list[idx].request_dt = od.oe_field_dt_tm_value
 
 		idx = locateval(numx, idx+1, size(rec->list, 5), od.order_id, rec->list[numx].order_id)
	endwhile
 
with nocounter, expand = 1
 
 
;============================================================================
; GET STOP DATE
;============================================================================
call echo("*** GET STOP DATE  ***")
 
select into "NL:"
from ORDER_DETAIL od
 
where expand(num, 1, size(rec->list, 5), od.order_id, rec->list[num].order_id)
	and od.oe_field_meaning = "STOPDTTM"
 
order by od.order_id
 
detail
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), od.order_id, rec->list[numx].order_id)
 
    while(idx > 0)
		rec->list[idx].stop_dt = od.oe_field_dt_tm_value
 
		;Calculate ICU days
		rec->list[idx].icu_days	=
			if (rec->list[idx].stop_dt = null)
				round(datetimediff(cnvtdatetime(curdate,curtime3), rec->list[idx].request_dt,1),0)
			else
				round(datetimediff(rec->list[idx].stop_dt, rec->list[idx].request_dt,1),0)
			endif
 
 		idx = locateval(numx, idx+1, size(rec->list, 5), od.order_id, rec->list[numx].order_id)
	endwhile
 
with nocounter, expand = 1
 
 
;====================================================
; REPORT OUTPUT
;====================================================
select distinct into value ($OUTDEV)
	facility      		= substring(1,50,trim(rec->list[d.seq].facility))
	,unit    			= substring(1,40,trim(rec->list[d.seq].unit))
;	,unit_hist 			= substring(1,40,trim(rec->list[d.seq].unit_hist))
;	,pat_name			= substring(1,40,trim(rec->list[d.seq].pat_name))
;	,fin				= substring(1,12,rec->list[d.seq].fin)
	,reg_dt				= format(rec->list[d.seq].reg_dt, "mm/dd/yyyy hh:mm;;q")
	,inpat_admit_dt		= format(rec->list[d.seq].inpat_admit_dt, "mm/dd/yyyy hh:mm;;q")
	,discharge_dt		= format(rec->list[d.seq].discharge_dt, "mm/dd/yyyy hh:mm;;q")
	,hospital_days		= rec->list[d.seq].hospital_days
	,loc_admit_transfer	= substring(1,100,rec->list[d.seq].loc_admit_transfer)
	,request_dt			= format(rec->list[d.seq].request_dt, "mm/dd/yyyy hh:mm;;q")
	,stop_dt			= format(rec->list[d.seq].stop_dt, "mm/dd/yyyy hh:mm;;q")
	,icu_days			= rec->list[d.seq].icu_days
;	,icu_days			=
;		if (rec->list[d.seq].stop_dt = null)
;			round(datetimediff(cnvtdatetime(curdate,curtime3), rec->list[d.seq].request_dt,1),0)
;		else
;			round(datetimediff(rec->list[d.seq].stop_dt, rec->list[d.seq].request_dt,1),0)
;		endif
	,vent_start_dt		= format(rec->list[d.seq].vent_start_dt, "mm/dd/yyyy hh:mm;;q")
	,vent_stop_dt		= format(rec->list[d.seq].vent_stop_dt, "mm/dd/yyyy hh:mm;;q")
	,vent_days			= rec->list[d.seq].vent_days
	,encntr_type		= substring(1,50,trim(rec->list[d.seq].encntr_type))
	,encntr_id     		= rec->list[d.seq].encntr_id
;	,person_id			= rec->list[d.seq].person_id
;	,event_id	   		= rec->list[d.seq].event_id
;	,order_id			= rec->list[d.seq].order_id
;	,order_mnem			= substring(1,100,rec->list[d.seq].order_mnem)
;	,username      		= rec->username
;	,rec_cnt			= rec->rec_cnt
 
from (DUMMYT d  with seq = value(size(rec->list,5)))
 
plan d
 
order by facility, unit, request_dt, encntr_id, rec->list[d.seq].event_id
 
with nocounter, format, check, separator = " "
 

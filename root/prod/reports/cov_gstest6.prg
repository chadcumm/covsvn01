/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Apr'2020
	Solution:			Surginet and Lab/COVID-19
	Source file name:	      cov_sn_surgery_covid_dashboard.prg
	Object name:		cov_sn_surgery_covid_dashboard
	Request#:			7550
	Program purpose:		Dashboard - Surgery anesthesia and Covid-19 summary
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_gstest6:dba go
create program cov_gstest6:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"               ;* Enter or select the printer or file name to send this report to.
	, "Start Surgery Scheduled  Date/Time" = "SYSDATE"
	, "End Surgery Scheduled  Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare covid_ref_lab_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 Reference Lab')), protect
declare covid_in_house_var    = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 In-House')), protect
declare op_facility_var = vc with noconstant("")
declare fcnt = i4 with noconstant(0)
 
set end_dt_tm = sysdate
;Last 24hrs
set start_dt_tm   = cnvtlookbehind("24, H", end_dt_tm,0)
;Last 7 days
set 7_start_dt_tm   = cnvtlookbehind("7, D", end_dt_tm,0)
 
call echo(build('start dt = ', format(start_dt_tm,";;q")))
call echo(build('7 start dt = ', format(7_start_dt_tm,";;q")))
 

;--------------------------------------------------------------------------------------------
 
; Define operator for $acute_facility_list
if (substring(1, 1, reflect(parameter(parameter2($acute_facility_list), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($acute_facility_list), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
;--------------------------------------------------------------------------------------------
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record dash(
	1 fac[*]
		2 facility_cd = f8
		2 list[*]
			3 anesthesia_cnt = i4
			3 covid_24hrs_cnt = i4
			3 covid_7day_cnt = i4
	)
 
;-------------------------------------------------------------------------------------------------
;Load all prompt facilities in the RC
select into 'nl:'
  facility_name = uar_get_displaykey(l.location_cd), l.location_cd
 
from location l
where l.location_type_cd = 783.00
and operator(l.location_cd, op_facility_var, $acute_facility_list) 
and l.active_ind = 1
and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00) 
 
order by l.location_cd

Head report
	cnt = 0
Head l.location_cd 
	cnt += 1
	call alterlist(dash->fac, cnt)
	dash->fac[cnt].facility_cd = l.location_cd 
with nocounter
 
;-------------------------------------------------------------------------------------------------
;General Anesthesia patients
 
select into 'nl:'
 
fac = uar_get_code_display(e.loc_facility_cd),sc.encntr_id, sc.sched_start_dt_tm, p.name_full_formatted
,sched_surg_area = uar_get_code_display(sc.sched_surg_area_cd), sea.order_id
,op_loc = uar_get_code_display(sc.sched_op_loc_cd), anes = uar_get_code_display(scp.sched_anesth_type_cd)
 
from surgical_case sc
   ,encounter e
   ,person p
   ,sch_event se
   ,sch_event_attach sea
   ,surg_case_procedure scp
   ,sch_event_patient sep
   ,order_catalog_synonym ocs
 
plan sc where sc.sched_start_dt_tm between cnvtdatetime ($start_datetime) and cnvtdatetime ($end_datetime)
	and sc.active_ind = 1
  	and sc.cancel_dt_tm = null
 
join p where p.person_id = sc.person_id
 
join e where e.encntr_id = sc.encntr_id
   	and e.active_ind = 1
   	and operator(e.loc_facility_cd, op_facility_var, $acute_facility_list) 
;   	and e.loc_facility_cd = $acute_facility_list
 
join sea where sea.sch_event_id = sc.sch_event_id
	and sea.state_meaning = "ACTIVE"
	and sea.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	and sea.active_ind = 1
	and sea.order_status_cd != 2542.00 ;Canceled
 
join se where se.sch_event_id = sc.sch_event_id
	and not se.sch_state_cd in(4535.00,4540.00,4548.00, 4544.00);Canceled, Deleted, Unschedulable, Pending
   	and se.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
   	and se.active_ind = 1
 
join scp where scp.order_id = sea.order_id
 
join sep where sep.sch_event_id = se.sch_event_id
	and sep.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	and sep.active_ind = 1
	and scp.sched_anesth_type_cd in(19971308.00, 2559790543.00) ;General, General w/Block
 
join ocs where ocs.catalog_cd = scp.sched_surg_proc_cd
	and ocs.mnemonic_type_cd = value(uar_get_code_by("MEANING" ,6011 ,"PRIMARY" ))
 
order by e.loc_facility_cd, e.encntr_id
 
Head e.loc_facility_cd
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(dash->fac,5) ,e.loc_facility_cd ,dash->fac[icnt].facility_cd)
	anes_cnt = 0
	cnt = 1
	call alterlist(dash->fac[idx].list, cnt)
Head e.encntr_id
	anes_cnt += 1
	call alterlist(dash->fac[idx]->list, cnt)
Foot e.loc_facility_cd
	dash->fac[idx]->list[cnt].anesthesia_cnt = anes_cnt
with nocounter
 
;--------------------------------------------------------------------------------------------------
;COVID_19 test for last 24hrs
select into 'nl:'
 
e.encntr_id, o.order_id, o.order_mnemonic, status = uar_get_code_display(o.order_status_cd)
, o.orig_order_dt_tm "@SHORTDATETIME", e.loc_facility_cd, e.location_cd, loc = uar_get_code_description(e.location_cd)
 
from  orders o
	,encounter e
 
plan o where o.orig_order_dt_tm between cnvtdatetime(start_dt_tm) and cnvtdatetime(end_dt_tm)
	and o.catalog_cd in(covid_ref_lab_var, covid_in_house_var)
	and o.order_status_cd in(2543.00, 2546.00, 2548.00, 2550.00)
			;Completed, Future, InProcess, Ordered
 
join e where e.encntr_id = o.encntr_id
	and e.person_id = o.person_id
	and operator(e.loc_facility_cd, op_facility_var, $acute_facility_list) 
	;and e.loc_facility_cd = $acute_facility_list
 
order by e.loc_facility_cd, e.encntr_id
 
Head e.loc_facility_cd
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(dash->fac,5) ,e.loc_facility_cd ,dash->fac[icnt].facility_cd)
	24cnt = 0
	cnt = 1
	call alterlist(dash->fac[idx].list, cnt)
Head e.encntr_id
	24cnt += 1
Foot e.loc_facility_cd
		dash->fac[idx].list[cnt].covid_24hrs_cnt = 24cnt
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
 
;COVID_19 test for last 7days
select into 'nl:'
 
e.encntr_id, o.order_id, o.order_mnemonic, status = uar_get_code_display(o.order_status_cd)
, o.orig_order_dt_tm "@SHORTDATETIME"
 
from  orders o
	,encounter e
 
plan o where o.orig_order_dt_tm between cnvtdatetime(7_start_dt_tm) and cnvtdatetime(end_dt_tm)
	and o.catalog_cd in(covid_ref_lab_var, covid_in_house_var)
	and o.order_status_cd in(2543.00, 2546.00, 2548.00, 2550.00)
			;Completed, Future, InProcess, Ordered
 
join e where e.encntr_id = o.encntr_id
	and e.person_id = o.person_id
	and operator(e.loc_facility_cd, op_facility_var, $acute_facility_list) 
	;and e.loc_facility_cd = $acute_facility_list
 
order by e.loc_facility_cd, e.encntr_id
 
Head e.loc_facility_cd
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(dash->fac,5) ,e.loc_facility_cd ,dash->fac[icnt].facility_cd)
	7cnt = 0
	cnt = 1
	call alterlist(dash->fac[idx].list, cnt)
Head e.encntr_id
	7cnt += 1
Foot e.loc_facility_cd
	dash->fac[idx].list[cnt].covid_7day_cnt = 7cnt
with nocounter
 
call echorecord(dash)
 
;---------------------------------------------------------------------------------------------------------
;*********************************************************************************************************
;Final otput
select into $outdev
	Facility = trim(uar_get_code_display(dash->fac[d1.seq].facility_cd))
	, Procedures_with_General_Anesthesia_Scheduled_Count = dash->fac[d1.seq].list[d2.seq].anesthesia_cnt
	, COVID_Test_Last_24_Hours_Count = dash->fac[d1.seq].list[d2.seq].covid_24hrs_cnt
	, COVID_Test_Last_7_Days_Count = dash->fac[d1.seq].list[d2.seq].covid_7day_cnt
 
from
	(dummyt   d1  with seq = size(dash->fac, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(dash->fac[d1.seq].list, 5))
join d2
 
with nocounter, separator=" ", format
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 
 

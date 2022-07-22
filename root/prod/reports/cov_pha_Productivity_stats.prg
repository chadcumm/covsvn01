/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:		 		Geetha Saravanan
	Date Written:		Feb'2018
	Solution:			Pharmacy
	Source file name:   cov_pha_Productivity_stats.prg
	Object name:		cov_pha_Productivity_stats
 
	Request#:			998
	Program purpose:    Daily Productivity report for each facility and each pharmacist to identify all order actions
						that have been completed over the course of the day.
 
	Executing from:		Reporting Portal
 
 	Special Notes:      Driver Program for stats report(portal) will pull order_sttaus_cd as completed and for all action types(action_type_cd)
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_pha_Productivity_stats:dba go
create program cov_pha_Productivity_stats:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 2552503613
 
with OUTDEV, start_datetime, end_datetime, facility
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
 
declare pharmacy_var = f8 with constant(uar_get_code_BY("DISPLAY", 106, "Pharmacy")), protect
declare ord_stat_var = f8 with constant(uar_get_code_BY("DISPLAY", 6004, "Completed")), protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD pharm(
	 1 ulist[*]
	 	2 facility_code = f8
	 	2 user_id       = vc
	 	2 user_count    = f8
	 	2 user_name     = vc
	 	2 percentage    = f8
)
 
 
SELECT DISTINCT INTO "NL:"
 
  i.username ;, Position = uar_get_code_display(i.position_cd)
, i.loc_facility_cd
, i.name_full_formatted
, usr_cnt = i.user_cnt
, percent = (i.user_cnt / i.loc_total_cnt)* 100.0 "####.##%"
 
from
(
	(select
	   p.username ;, p.position_cd
	 , e.loc_facility_cd
	 , p.name_full_formatted
	 , user_cnt   = count(p.username)over(partition by p.username)
	 , loc_total_cnt  = count(p.username)over()
 
	from orders o, order_action oa, prsnl p, encounter e, code_value cvpcd
		where oa.order_id = o.order_id
		and p.person_id = oa.action_personnel_id
		and e.encntr_id = o.encntr_id
		and (cvpcd.code_value = p.position_cd and cvpcd.code_set = 88 and cvpcd.cdf_meaning = "RPH");Pharmacist only
		and o.active_ind = 1
		and o.activity_type_cd = 705 ;pharmacy_var 
		;and oa.order_dt_tm between cnvtdatetime("01-JAN-2018 00:00:00") and cnvtdatetime("31-DEC-2018 23:59:00")
		and oa.action_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and oa.needs_verify_ind = 3
		and e.encntr_type_cd in(309308, 309309) ;Inpatient, Outpatient
		and e.loc_facility_cd = $facility
		and e.active_ind = 1
		and p.active_ind = 1
	with sqltype("vc","f8","vc","f8","f8"))i
)
 
order by i.loc_facility_cd, i.username
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT ;, MAXREC = 100
 
 
;Populate Users in the record structure
Head report
 
	ucnt = 0
	call alterlist(pharm->ulist, 10)
 
Detail
	ucnt = ucnt + 1
	call alterlist(pharm->ulist, ucnt)
 
 	pharm->ulist[ucnt].facility_code = i.loc_facility_cd
 	pharm->ulist[ucnt].user_id = i.username
 	pharm->ulist[ucnt].user_count = usr_cnt
 	pharm->ulist[ucnt].user_name = i.name_full_formatted
 	pharm->ulist[ucnt].percentage = percent
 
Foot report
 	call alterlist(pharm->ulist, ucnt)
 
with nocounter
 
 
;call echojson(pharm,"rec.out", 0)
;call echorecord(pharm)
 

 
end
go
 
 
 
 
 
 
 
/* CODE VALUES USED
 
309308.00	Inpatient
309309.00	Outpatient
 
 
*/
 
 
 

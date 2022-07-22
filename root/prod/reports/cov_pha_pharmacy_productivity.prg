/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Pharmacy
	Source file name:	      cov_pha_Productivity_Extract.prg
	Object name:		cov_pha_Productivity_Extract
 
	Request#:			998
	Program purpose:	      Daily Productivity data extract by facility for all facilities.
 
	Executing from:		DA2 or Operational schedular
 
 	Special Notes:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_pharmacy_productivity:dba go
create program cov_pha_pharmacy_productivity:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Action Date/Time" = "SYSDATE"
	, "End Action Date/Time" = "SYSDATE"
	, "Facility" = 2552503613
	, "Report Type" = "2" 

with OUTDEV, start_datetime, end_datetime, facility, repo_type
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare rcnt = i4 with noconstant(0), protect
declare pharmacy_var  = f8 with constant(uar_get_code_BY("DISPLAY", 106, "Pharmacy")), protect
declare ord_stat_var  = f8 with constant(uar_get_code_BY("DISPLAY", 6004, "Completed")), protect
declare faci          = vc
declare output_orders = vc
;declare filename_var  = vc with constant('cer_temp:covhlth_pr_rx_stats.txt'), protect
 
;To create file on all nodes
declare filename_var = vc with constant(build("/cerner/w_custom/p0665_cust/code/script/", "CovHlth_PR_Rx_Stats.txt")), protect
 
;To create file with current date
;declare filename_var  = vc with constant(build('cer_temp:CovHlth_PR_Rx_Stats_',FORMAT(CURDATE,'YYYYMMDD;;Q'),'.txt')), PROTECT
 
/*
;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("1,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)
*/
 
/**************************************************************
; DVDev Record Structure
**************************************************************/
 
record pha_ord(
	1 olist_cnt = i4
	1 olist[*]
		2 facility_cd = f8
		2 facility = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 order_mnemonic = vc
		2 order_dt = vc
		2 enc_type = vc
		2 pat_type = vc
		2 action_type = vc
		2 action_dt = dq8 ;vc
		2 order_status = vc
		2 verify_ind = vc
		2 user_name = vc
		2 position = vc
		2 order_detail_display = vc
)
 
record ord_rew(
	1 rew_cnt = i4
	1 rlist[*]
		2 facility_cd = f8
		2 facility = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 order_mnemonic = vc
		2 order_dt = vc
		2 enc_type = vc
		2 pat_type = vc
		2 action_type = vc
		2 action_dt = dq8 ;vc
		2 order_status = vc
		2 verify_ind = vc
		2 user_name = vc
		2 position = vc
		2 order_detail_display = vc
)
 

/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;********** Working copy as per Tommy's request ***************
 
;get order details
select into 'nl:';$outdev
 
fin = ea.alias
, location = uar_get_code_display(i.loc_facility_cd)
, i.order_id, i.order_mnemonic, i.order_action_id
, order_dt = format(i.order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, encounter_type = uar_get_code_display(i.encntr_type_class_cd)
, Pat_type = i.ipop
, action_type = uar_get_code_display(i.action_type_cd)
, action_dt = format(i.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, order_status = uar_get_code_display(i.order_status_cd)
, verify_indicator =
	if(i.needs_verify_ind = 0) 'no verify needed'
		elseif(i.needs_verify_ind = 1) 'verify needed'
		elseif(i.needs_verify_ind = 2) 'superseded'
	      elseif(i.needs_verify_ind = 3) 'verified'
		elseif(i.needs_verify_ind = 4) 'rejected'
		elseif(i.needs_verify_ind = 5) 'reviewed'
	endif
 
, i.username
, position = uar_get_code_display(i.position_cd)
, i.order_detail_display_line
 
from

order_action oa 
,encntr_alias ea
 
,(
 	(select distinct e.loc_facility_cd, e.encntr_type_class_cd, e.person_id,e.encntr_id, o.order_id, o.order_mnemonic
 		 , o.order_detail_display_line, oa.order_dt_tm, oa.action_type_cd, oa.order_status_cd, p.username, p.position_cd
 		 , oa.needs_verify_ind, oa.order_action_id, oa.action_dt_tm
    		 , ipop = evaluate2(if(e.encntr_type_class_cd = 391.00)'I' else 'O' endif)
 
 	from orders o, order_action oa, encounter e, prsnl p, code_value cvpcd
 
 	where o.activity_type_cd = 705 ;pharmacy_var
		and o.active_ind = 1
		and oa.order_id = o.order_id
		and oa.action_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		;and (oa.action_dt_tm between cnvtdatetime("01-OCT-2018 00:00:00") and cnvtdatetime("02-OCT-2018 23:59:00"))
		and e.encntr_id = o.encntr_id
		and e.encntr_type_class_cd in(391.00, 392.00, 393.00, 389.00)
		and e.loc_facility_cd = $facility
		and e.active_ind = 1
		and p.person_id = oa.action_personnel_id
		and oa.action_personnel_id != 1
		and (p.username != ' ' 	and cnvtupper(p.username) != 'NO ACCESS')
		and cvpcd.code_value = p.position_cd
		and cvpcd.code_set = 88
		and cvpcd.cdf_meaning = "RPH" ;Pharmnet - Pharmacist, Pharmnet - Managemant*/
 
	;group by e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_id, o.order_id, o.order_mnemonic, o.order_detail_display_line
    	;	 ,oa.order_dt_tm, oa.action_type_cd, oa.order_status_cd, p.username, p.position_cd
 
 		WITH SQLTYPE("f8","f8","f8","f8",'f8','vc','vc','dq8','f8','f8','vc','f8','i4',"f8",'dq8','vc') )i
)
 
plan i
 
join oa where oa.order_id = i.order_id
	and oa.action_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	 
join ea where ea.encntr_id = i.encntr_id
	and ea.encntr_alias_type_cd = 1077
 
order by fin,i.order_id, i.order_action_id, i.action_dt_tm
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT;, time = 90;, MAXREC = 10000
 
 
Head report
 	cnt = 0
	call alterlist(pha_ord->olist, 100)
 
Head i.order_action_id
 	cnt = cnt + 1
 	pha_ord->olist_cnt = cnt
	call alterlist(pha_ord->olist, cnt)
Detail
	pha_ord->olist[cnt].facility_cd = i.loc_facility_cd
	pha_ord->olist[cnt].facility = uar_get_code_display(i.loc_facility_cd)
 	pha_ord->olist[cnt].fin = fin
 	pha_ord->olist[cnt].personid = i.person_id
 	pha_ord->olist[cnt].encntrid = i.encntr_id
 	pha_ord->olist[cnt].orderid = i.order_id
 	pha_ord->olist[cnt].order_mnemonic = i.order_mnemonic
 	pha_ord->olist[cnt].order_dt = order_dt
 	pha_ord->olist[cnt].enc_type = encounter_type
 	pha_ord->olist[cnt].pat_type = pat_type
 	pha_ord->olist[cnt].action_type = action_type
 	pha_ord->olist[cnt].action_dt = i.action_dt_tm ;action_dt
 	pha_ord->olist[cnt].order_status = order_status
 	pha_ord->olist[cnt].verify_ind = verify_indicator
 	pha_ord->olist[cnt].user_name = i.username
 	pha_ord->olist[cnt].position = position
 	pha_ord->olist[cnt].order_detail_display = i.order_detail_display_line
 
Foot i.order_action_id
 
 	call alterlist(pha_ord->olist, cnt)
 
with nocounter
;call echorecord(pha_ord)
;--------------------------------------------------------------------------------------
 
IF (pha_ord->olist_cnt > 0)
;get order_review details
select into 'nl:'
 
orw.order_id, orw.action_sequence
, review_dt = format(orw.review_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, orw.review_personnel_id, orw.review_type_flag
, action_type = if(orw.review_type_flag = 3) 'Verify' endif
, username = p.username
, position = uar_get_code_display(p.position_cd)
 
from
 
 (dummyt d WITH seq = value(size(pha_ord->olist,5)))
 ;,encounter e
 ;,encntr_alias ea
 ,order_review orw
 , prsnl p
 , code_value cvpcd
 
plan d
 
join orw where orw.order_id = pha_ord->olist[d.seq].orderid
	and orw.review_type_flag = 3 ;Pharmacist Verify
 	and orw.review_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 	
join p where p.person_id = orw.review_personnel_id
 
join cvpcd where cvpcd.code_value = p.position_cd
	and cvpcd.code_set = 88
	and cvpcd.cdf_meaning = "RPH" ;Pharmnet - Pharmacist, Pharmnet - Managemant*/
 
order by orw.order_id, orw.review_personnel_id, orw.action_sequence
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT;, time = 90;, MAXREC = 10000
 
Head orw.review_personnel_id
	rcnt = rcnt + 1
	ord_rew->rew_cnt = rcnt
	call alterlist(ord_rew->rlist, rcnt)
Detail
	ord_rew->rlist[rcnt].facility_cd = pha_ord->olist[d.seq].facility_cd
	ord_rew->rlist[rcnt].facility = pha_ord->olist[d.seq].facility
 	ord_rew->rlist[rcnt].fin = pha_ord->olist[d.seq].fin
 	ord_rew->rlist[rcnt].personid = pha_ord->olist[d.seq].personid
 	;ord_rew->rlist[rcnt].enrcntrid = pha_ord->olist[d.seq].enrcntrid
 	ord_rew->rlist[rcnt].orderid = orw.order_id
 	ord_rew->rlist[rcnt].order_mnemonic = pha_ord->olist[d.seq].order_mnemonic
 	ord_rew->rlist[rcnt].order_dt = pha_ord->olist[d.seq].order_dt
 	ord_rew->rlist[rcnt].enc_type = pha_ord->olist[d.seq].enc_type
 	ord_rew->rlist[rcnt].pat_type = pha_ord->olist[d.seq].pat_type
 	ord_rew->rlist[rcnt].action_type = action_type
 	ord_rew->rlist[rcnt].action_dt = orw.review_dt_tm;review_dt
 	ord_rew->rlist[rcnt].order_status = pha_ord->olist[d.seq].order_status
 	ord_rew->rlist[rcnt].verify_ind = pha_ord->olist[d.seq].verify_ind
 	ord_rew->rlist[rcnt].user_name = username
 	ord_rew->rlist[rcnt].position = position
 	ord_rew->rlist[rcnt].order_detail_display = pha_ord->olist[d.seq].order_detail_display
 
Foot orw.review_personnel_id
 
 	call alterlist(ord_rew->rlist, rcnt)
 
with nocounter
 
SET stat = movereclist (ord_rew->rlist, pha_ord->olist  ,1 ,pha_ord->olist_cnt , ord_rew->rew_cnt ,true )
SET pha_ord->olist_cnt = size(pha_ord->olist ,5 )
 
endif
 
call echorecord(pha_ord)
 
;----------------------------------------------------------------------------------

;Detailed output 

If($repo_type = '1')

SELECT DISTINCT into VALUE($outdev)
 
	FACILITY = PHA_ORD->olist[D1.SEQ].facility
	, FIN = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].fin)
	, ORDERID = PHA_ORD->olist[D1.SEQ].orderid
	, ORDER_MNEMONIC = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_mnemonic)
	, ORDER_DT = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_dt)
	, ENC_TYPE = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].enc_type)
	, PAT_TYPE = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].pat_type)
	, ACTION_TYPE = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].action_type)
	, ACTION_DT = format(PHA_ORD->olist[D1.SEQ].action_dt, 'mm/dd/yyyy hh:mm;;q')
	, ORDER_STATUS = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_status)
	, VERIFY_IND = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].verify_ind)
	, USER_NAME = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].user_name)
	, POSITION = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].position)
	, ORDER_DETAIL_DISPLAY = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_detail_display)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(PHA_ORD->olist, 5)))
 
PLAN D1
 
ORDER BY FACILITY, FIN, orderid, ORDER_mnemonic, ACTION_DT, action_type, USER_NAME
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT 
 
Endif 

 
;-------------------------------------------------------------------------------------------
If($repo_type = '2')

; Summary format

/*SELECT DISTINCT into VALUE($outdev)
 
 	 month_numeric = month(PHA_ORD->olist[D1.SEQ].action_dt)
 	,month_name = format(PHA_ORD->olist[D1.SEQ].action_dt, "MMMMMMMMM;;d")
	,facility = uar_get_code_description(PHA_ORD->olist[D1.SEQ].facility_cd)
	,action_type = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].action_type)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(PHA_ORD->olist, 5)))
 
PLAN D1

ORDER BY month_numeric, facility, action_type ;, order_id, order_mnemonic, action_dt */

SELECT DISTINCT into VALUE($outdev)
 
 	 month_numeric = month(PHA_ORD->olist[D1.SEQ].action_dt)
 	,month_name = format(PHA_ORD->olist[D1.SEQ].action_dt, "MMMMMMMMM;;d")
	,facility = uar_get_code_description(PHA_ORD->olist[D1.SEQ].facility_cd)
	, FIN = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].fin)
	, ORDERID = PHA_ORD->olist[D1.SEQ].orderid
	, ORDER_MNEMONIC = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_mnemonic)
	, ORDER_DT = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_dt)
	, ENC_TYPE = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].enc_type)
	, PAT_TYPE = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].pat_type)
	, ACTION_TYPE = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].action_type)
	, ACTION_DT = format(PHA_ORD->olist[D1.SEQ].action_dt, 'mm/dd/yyyy hh:mm;;q')
	, ORDER_STATUS = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_status)
	, VERIFY_IND = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].verify_ind)
	, USER_NAME = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].user_name)
	, POSITION = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].position)
	, ORDER_DETAIL_DISPLAY = SUBSTRING(1, 30, PHA_ORD->olist[D1.SEQ].order_detail_display)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(PHA_ORD->olist, 5)))
 
PLAN D1

ORDER BY month_numeric, facility, action_type, FIN, orderid, ORDER_mnemonic, ACTION_DT, USER_NAME

Head page
    row +4
    col 35 "PHARMACY PRODUCTIVITY REPORT"
    row +1
    col 25 "Date Range : "
    col 40 $start_datetime
    col 63 ' TO '
    col 68 $end_datetime
    row +1
    col 0 "--------------------------------------------------------------------------------------------------------------"
    row +1	
Head month_numeric    
    col 5 "MONTH :"
    col 20 month_name 	
    row +1	
Head facility
    col 5 "FACILITY : "
    col 20 facility
    row +1
    col 0 "--------------------------------------------------------------------------------------------------------------"
    row +1
    col 2 "ACTION TYPE :"
Head action_type
    col 30 action_type
Foot action_type
    col 50 count(action_type)
    row +1
Foot facility
    col 0 "---------------------------------------------------------------------------------------------------------------"
    row+1
    col 30 "Grand Total"
    col 50 count(action_type)
    row +1
    col 0 "==============================================================================================================="
    row +1
	
	 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 180
 
Endif
 
End go
 
 
 
 
 

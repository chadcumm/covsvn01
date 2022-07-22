/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May 2021
	Solution:			Clinical
	Source file name:		cov_phq_comfort_meas_orders.prg
	Object name:		cov_phq_comfort_meas_orders
	Request#:			CR# 10294
	Program purpose:	      AdHoc for Decision Support
	Executing from:		DA2/CCL
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------	------------------------------------------
******************************************************************************/
 
 
drop program cov_phq_comfort_meas_orders:dba go
create program cov_phq_comfort_meas_orders:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE"
	, "Acute Facility List" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare idx = i4 with noconstant(0)
 
Record pat(
	1 rec_cnt = i4
	1 list[*]
		2 facility = vc
		2 fin = vc
		2 encntrid = f8
		2 pat_name = vc
		2 enc_type = vc
		2 disch_dt = dq8
		2 orderid = f8
		2 order_name = vc
		2 order_dt = vc
		2 order_status = vc
		2 discont_dt = vc
		2 temp = vc
	 )
 
 
 
;-------------------------------------------------------------------
 
select into $outdev
 
fin = trim(ea.alias), p.name_full_formatted, e.disch_dt_tm ';;q'
,o.order_mnemonic, o.orig_order_dt_tm ';;q', order_status = uar_get_code_display(o.order_status_cd), o.order_id
 
from encounter e
	,orders o
	,encntr_alias ea
	,person p
 
plan e where e.loc_facility_cd = $acute_facility_list ;21250403.00    ;FSR
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.catalog_cd = 3976784.00	;Comfort Measures
	and o.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id, o.order_id
 
 
Head report
	cnt = 0
Head o.order_id
	cnt += 1
	call alterlist(pat->list, cnt)
	pat->rec_cnt = cnt
Detail
	pat->list[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->list[cnt].fin = ea.alias
	pat->list[cnt].pat_name = p.name_full_formatted
	pat->list[cnt].enc_type = uar_get_code_display(e.encntr_type_cd)
	pat->list[cnt].disch_dt = e.disch_dt_tm
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].order_name = o.order_mnemonic
	pat->list[cnt].orderid = o.order_id
	pat->list[cnt].order_dt = format(o.orig_order_dt_tm, 'mm-dd-yyyy hh:ss;;d')
 
with nocounter
 
IF(pat->rec_cnt > 0) 
;------------------------------------------------------------------------
;Not discontinued before Discharge?
 
select into $outdev
enc = pat->list[d.seq].encntrid, ord = pat->list[d.seq].orderid
,action_type = uar_get_code_display(oa.action_type_cd), discontinue_dt = oa.action_dt_tm ';;q'
, order_stat = uar_get_code_display(oa.order_status_cd)
 
from (dummyt d with seq=(size(pat->list,5)))
	,order_action oa
 
plan d
 
join oa where oa.order_id = pat->list[d.seq].orderid
 
order by enc, ord
 
Head ord
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5), oa.order_id ,pat->list[icnt].orderid)
Detail
	pat->list[idx].discont_dt = format(oa.action_dt_tm, 'mm-dd-yyyy hh:ss;;d')
	pat->list[idx].order_status = order_stat
	pat->list[idx].temp =
	if(oa.action_type_cd = 2532.00 and (oa.action_dt_tm < cnvtdatetime(pat->list[d.seq].disch_dt)))'Yes' endif
 
with nocounter
 
;-------------------------------------------------------------------------------
;Final Report
 
SELECT INTO $outdev
	facility = substring(1, 30, pat->list[d1.seq].facility)
	, fin = substring(1, 30, pat->list[d1.seq].fin)
	, pat_name = substring(1, 50, pat->list[d1.seq].pat_name)
	, disch_dt = format(pat->list[d1.seq].disch_dt, 'mm-dd-yyyy hh:ss;;d')
	, order_name = substring(1, 30, pat->list[d1.seq].order_name)
	, order_dt = substring(1, 30, pat->list[d1.seq].order_dt)
	, order_status = substring(1, 30, pat->list[d1.seq].order_status)
	, discont_dt = substring(1, 30, pat->list[d1.seq].discont_dt)
	, discon_before_disch = substring(1, 30, pat->list[d1.seq].temp)
	, patient_type = substring(1, 50, pat->list[d1.seq].enc_type)
 
FROM
	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1
 
order by facility, disch_dt
 
WITH nocounter, separator=" ", format
 
ENDIF 
 
#exitscript
 
end
go
 
 
/*
select action_type = uar_get_code_display(oa.action_type_cd), stat = uar_get_code_display(oa.order_status_cd), oa.*
from order_action oa where oa.order_id =  4182491375.00
 
 
 
 
 
 
 
 
 
 
 
 
 
 

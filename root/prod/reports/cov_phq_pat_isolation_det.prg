/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb 2021
	Solution:			Behavior Health
	Source file name:	      cov_phq_pat_isolation_det.prg
	Object name:		cov_phq_pat_isolation_det
	Request#:			9664
	Program purpose:	      
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 

drop program cov_phq_pat_isolation_det:dba go
create program cov_phq_pat_isolation_det:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list



/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 fcility = vc
		2 pat_name = vc
		2 fin = vc
		2 age = vc
		2 encntrid = f8
		2 admit_dt = vc
		2 disch_dt = vc
		2 olist[*]
			3 orderid = f8
			3 order_loc = vc
			3 iso_order_dt = dq8
			3 iso_discontinue_dt = vc
	)


/**************************************************************
; DVDev Start Coding
**************************************************************/

select into $outdev

ea.alias , o.encntr_id, o.order_id, o.order_mnemonic, o.orig_order_dt_tm ';;q'
,orde_status = uar_get_code_display(o.order_status_cd)

from  encounter e
	,orders o
	,encntr_alias ea
	,person p
	
plan e where e.loc_facility_cd = $facility_list
	and e.active_ind = 1

join o where o.encntr_id = e.encntr_id
	and o.catalog_cd = 3976772.00 ;Patient Isolation
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.order_status_cd in(2550.00,2545.00,2548.00,2543.00)

join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
	
join p where p.person_id = e.person_id
	and p.active_ind = 1
		
order by p.person_id, o.encntr_id, o.order_id, o.orig_order_dt_tm
	
Head report
	cnt = 0
Head o.encntr_id
	cnt += 1
	call alterlist(pat->plist, cnt)
	pat->plist[cnt].fcility = uar_get_code_display(e.loc_facility_cd)		
	pat->plist[cnt].fin = trim(ea.alias)
	pat->plist[cnt].pat_name = trim(p.name_full_formatted)
	pat->plist[cnt].encntrid = o.encntr_id
	pat->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm ;;q')
	pat->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm ;;q')
	pat->plist[cnt].age = cnvtage(p.birth_dt_tm, e.reg_dt_tm,0)
	ocnt = 0
Head o.order_id
	ocnt += 1
	call alterlist(pat->plist[cnt].olist, ocnt)	
	pat->plist[cnt].olist[ocnt].orderid = o.order_id
	pat->plist[cnt].olist[ocnt].iso_order_dt = o.orig_order_dt_tm

with nocounter

;------------------------------------------------------------------------------------------
; Isolation discontinued?

select into $outdev
enc = pat->plist[d1.seq].encntrid
,oa.order_id ,action_type = uar_get_code_display(oa.action_type_cd), oa.action_dt_tm ';;q'
,oa_orde_status = uar_get_code_display(oa.order_status_cd)

from 	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)
	, order_action oa

plan d1 where maxrec(d2, size(pat->plist[d1.seq].olist, 5))

join d2

join oa where oa.order_id = pat->plist[d1.seq].olist[d2.seq].orderid
	and oa.action_type_cd = 2532.00 ;Discontinue

order by enc, oa.order_id

Head oa.order_id
 	icnt = 0
	idx = 0
	idx = locateval(icnt,1,size(pat->plist,5), oa.order_id, pat->plist[d1.seq].olist[icnt].orderid)
	if(idx > 0)
		pat->plist[d1.seq].olist[idx].iso_discontinue_dt = format(oa.action_dt_tm , 'mm/dd/yy hh:mm ;;q')
	endif
 
with nocounter

call echorecord(pat)	

;-------------------------------------------------------------------------------------------------
;Patient location at time of order

select into 'nl:'
 
elh.encntr_id, ord_id = pat->plist[d1.seq].olist[d2.seq].orderid
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
		,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from	 (dummyt   d1  with seq = size(pat->plist, 5))
	,(dummyt   d2  with seq = 1)
	, encntr_loc_hist elh
 
plan d1 where maxrec(d2, size(pat->plist[d1.seq].olist, 5))
join d2
 
join elh where elh.encntr_id = pat->plist[d1.seq].encntrid
	and pat->plist[d1.seq].olist[d2.seq].iso_order_dt != 0
	and (cnvtdatetime(pat->plist[d1.seq].olist[d2.seq].iso_order_dt) 
				between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 
	pat->plist[d1.seq].olist[d2.seq].order_loc = order_pat_loc
 
with nocounter
 

;-------------------------------------------------------------------------------------------------

select into $outdev
	fcility = trim(substring(1, 50, pat->plist[d1.seq].fcility))
	, patient_name = trim(substring(1, 50, pat->plist[d1.seq].pat_name))
	, fin = trim(substring(1, 10, pat->plist[d1.seq].fin))
	, age = trim(substring(1, 3, pat->plist[d1.seq].age))
	, admit_dt = trim(substring(1, 30, pat->plist[d1.seq].admit_dt))
	, disch_dt = trim(substring(1, 30, pat->plist[d1.seq].disch_dt))
	, Isolation_order_location = trim(substring(1, 50, pat->plist[d1.seq].olist[d2.seq].order_loc))
	, Isolation_order_dt = trim(format(pat->plist[d1.seq].olist[d2.seq].iso_order_dt,'mm/dd/yy hh:mm ;;q'))
	, Isolation_discontinue_dt = trim(substring(1, 30, pat->plist[d1.seq].olist[d2.seq].iso_discontinue_dt))
	;, orderid = pat->plist[d1.seq].olist[d2.seq].orderid
	;, encntrid = pat->plist[d1.seq].encntrid

from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)

plan d1 where maxrec(d2, size(pat->plist[d1.seq].olist, 5))
join d2

with nocounter, separator=" ", format


#exitscript

end go	
	


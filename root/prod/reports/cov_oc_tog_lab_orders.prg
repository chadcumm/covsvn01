/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Aug' 2019
	Solution:			Oncology
	Source file name:	      cov_oc_tog_lab_orders.prg
	Object name:		cov_oc_tog_lab_orders
	Request#:			5395
	Program purpose:	      Oncology - Lab orders
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
05/19/22	David Baumgardner		CR12850 adding in ordering provider to the output of the report
 
******************************************************************************/
 
drop program cov_oc_tog_lab_orders:dba go
create program cov_oc_tog_lab_orders:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "SELECT LOCATION" = 0
 
with OUTDEV, start_datetime, end_datetime, tog_location
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
Record lab(
	1 list[*]
		2 orderid = f8
		2 orig_order_dt = dq8
		2 name_full_formatted = vc
		2 order_mnemonic = vc
		2 order_detail_display_line = vc
		2 start_range_nbr = i4
		2 start_range_unit = vc
		2 begin_dt_tm = vc
		2 location = vc
; 05/19/22 Adding in ordering provider
		2 order_provider = vc
	)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;select distinct into $outdev
select into 'nl:'
 
 p.name_full_formatted, p.birth_dt_tm, o.order_mnemonic,O.order_id, o.orig_order_dt_tm
, o_order_status_disp = uar_get_code_display(o.order_status_cd)
, o.order_detail_display_line, oa.start_range_nbr
, beg_dt_tm = format(sa.beg_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, appt_type_disp = uar_get_code_display(sev.appt_type_cd)
, appt_location_disp = uar_get_code_display(sa.appt_location_cd), sa.appt_location_cd
, start_range_unit =
	if(oa.start_range_unit_flag = null)"None"
      elseif(oa.start_range_unit_flag = 1)"Days"
      elseif(oa.start_range_unit_flag = 2)"Weeks"
      elseif(oa.start_range_unit_flag = 3)"Months"
      endif
from
	 encounter e
     , orders o
     , person p
     , order_action oa
     , prsnl pr
     , encntr_alias ea1
     , encntr_alias ea2
     , sch_appt sa
     , sch_event sev
 
plan o where o.orig_order_dt_tm > cnvtdatetime(cnvtdate( 020119 ), 0)
      and o.order_status_cd in (2546); code value for order status complete,future,etc
	and o.catalog_type_cd = 2513 ; we are pulling all lab catalog types, we have to set a time range here because
             						;the original order may have been entered a few months in advance
join p where o.person_id = p.person_id
 
join e where e.person_id = p.person_id
 
join oa where oa.order_id = o.order_id
 
join pr where pr.person_id = outerjoin(oa.action_personnel_id)
 
join ea1 where ea1.encntr_id = outerjoin(o.encntr_id)
	and ea1.encntr_alias_type_cd = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!2930")))
 
join ea2 where ea2.encntr_id = outerjoin(o.encntr_id)
	and ea2.encntr_alias_type_cd = outerjoin(value(uar_get_code_by_cki("CKI.CODEVALUE!8021")))
 
join sa where sa.encntr_id = e.encntr_id
	and sa.appt_location_cd = $tog_location
	and sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      and sa.sch_role_cd = (4572.00) ; patient
      and sa.sch_state_cd = (4538.00) ; confirmed
      and sa.end_effective_dt_tm > (sysdate)
      and sa.active_ind = (1)
 
join sev where sev.sch_event_id = (sa.sch_event_id)
	and sev.sch_state_cd = (4538.00) ; confirmed
      and sev.appt_type_cd in (2592715649.00, 2592715719.00) ; onc lab, onc lab port
      and sev.end_effective_dt_tm > (sysdate)
      and sev.active_ind = (1)
 
order by o.order_id
 
;with nocounter, separator=" ", format
 
Head report
	cnt = 0
Head o.order_id
	cnt += 1
	call alterlist(lab->list, cnt)
Detail
	lab->list[cnt].orderid = o.order_id
	lab->list[cnt].orig_order_dt = o.orig_order_dt_tm
	lab->list[cnt].name_full_formatted = trim(p.name_full_formatted)
	lab->list[cnt].order_mnemonic = trim(o.order_mnemonic)
	lab->list[cnt].order_detail_display_line = trim(o.order_detail_display_line)
	lab->list[cnt].start_range_nbr = oa.start_range_nbr
	lab->list[cnt].start_range_unit = trim(start_range_unit)
	lab->list[cnt].begin_dt_tm = beg_dt_tm
	lab->list[cnt].location = trim(uar_get_code_display(sa.appt_location_cd))
; 05/19/22 Adding in ordering provider
	lab->list[cnt].order_provider = pr.name_full_formatted
 
with nocounter
 
call echorecord(lab)
 
;---------------------------------------------------------------------------------------------------------
 
SELECT INTO $OUTDEV
	 LOCATION = SUBSTRING(1, 30, LAB->list[D1.SEQ].location)
	, PATIENT_NAME = SUBSTRING(1, 30, LAB->list[D1.SEQ].name_full_formatted)
; 05/19/22 Adding in ordering provider
	, ORDERING_PROVIDER = LAB->list[d1.seq].order_provider
	, ORDER_NAME = SUBSTRING(1, 30, LAB->list[D1.SEQ].order_mnemonic)
	, ORDER_SENTENCE = SUBSTRING(1, 30, LAB->list[D1.SEQ].order_detail_display_line)
	, START_RANGE_NBR = LAB->list[D1.SEQ].start_range_nbr
	, START_RANGE_UNIT = SUBSTRING(1, 30, LAB->list[D1.SEQ].start_range_unit)
	, APPT_DATE_TIME = SUBSTRING(1, 30, LAB->list[D1.SEQ].begin_dt_tm)
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(LAB->list, 5))
 
PLAN D1
 
ORDER BY LOCATION, PATIENT_NAME, LAB->list[D1.SEQ].orig_order_dt
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 
/*
select cv1.code_value, cv1.display
from code_value cv1
where cv1.code_set =  220 and cv1.active_ind = 1
and cnvtlower(cv1.display) = '*tog*'
and cnvtlower(cv1.description) = '*thompson oncology*'
and cv1.cdf_meaning = 'FACILITY'
 
 
select cv1.* ; cv1.code_value, cv1.display
from code_value cv1
where cv1.code_set =  220 and cv1.active_ind = 1
and cnvtlower(cv1.display) = '*tog*'
;and cnvtlower(cv1.description) = '*thompson oncology*'
and cv1.cdf_meaning = 'AMBULATORY'
 
 
 
*/

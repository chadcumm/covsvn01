/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Nov'2020
	Solution:			Surgery
	Source file name:	      cov_sn_pathology_orders.prg
	Object name:		cov_sn_pathology_orders
	Request#:			8750
	Program purpose:	      Pathology/Cytology order detail analysis
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/


drop program cov_sn_pathology_orders:dba go
create program cov_sn_pathology_orders:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Reg Date/Time" = "SYSDATE"
	, "End Reg Date/Time" = "SYSDATE"
	, "Acute Facility List" = 0 

with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare spec_type_var = vc with constant('SPECIMEN TYPE')
declare spec_desc_var = vc with constant('SPECIMENDESC')
declare spec_labl_var = vc with constant('LBLCMNT')
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD ord(
	1 olist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 fin = vc
		2 encntrid = f8
		2 order_mnemonic = vc
		2 orderid = f8
		2 original_ord_dt = dq8
		2 order_loc = vc
		2 detail_date_tm = vc
		2 Specimen_type = vc
		2 Specimen_description = vc
		2 label_comment = vc
)
 
 
;-----------------------------------------------------------------------------------------
 
select into $outdev
 
fac = trim(uar_get_code_display(e.loc_facility_cd)), unit = trim(uar_get_code_description(e.loc_nurse_unit_cd))
,e.encntr_id, o.ordered_as_mnemonic, od.oe_field_display_value, od.oe_field_meaning
 
from encounter e
	;,code_value cv1
	,orders o
	,(left join order_detail od on od.order_id = o.order_id
		;and od.action_sequence = o.last_action_sequence
		and od.oe_field_id in(12584.00,12680.00,12647.00) );SPECIMEN TYPE,SPECIMENDESC, LBLCMNT
	,encntr_alias ea
	
 
/*plan cv1 where cv1.code_set = 220
	and cv1.active_ind = 1
	and (cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*ENDO*'
		or cnvtupper(cv1.display) = '*GILAB*' )
	and cv1.cdf_meaning in('NURSEUNIT', 'AMBULATORY')
	and cv1.code_value not in(2553456209,2564351079, 2552520243,2589596359,2552513073,2589739751
			,2664921681,2557662075,2557662051,2555024921,2560501341,2585644277,2559795895) */
 
plan e ;where e.loc_nurse_unit_cd = cv1.code_value
	;where e.encntr_id =   121620095.00
	where e.loc_facility_cd = $acute_facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.catalog_cd in(2553794147.00,313046.00)
 
join od
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by unit, e.encntr_id, o.order_id, od.oe_field_meaning
 
Head report
	cnt = 0
Head o.order_id
	cnt += 1
	call alterlist(ord->olist, cnt)
	ord->olist[cnt].facility = fac
	ord->olist[cnt].encntrid = e.encntr_id
	ord->olist[cnt].nurse_unit = unit
	ord->olist[cnt].fin = ea.alias
	ord->olist[cnt].order_mnemonic = o.ordered_as_mnemonic
	ord->olist[cnt].original_ord_dt = o.orig_order_dt_tm
	;ord->olist[cnt].order_loc = uar_get_code_description(oa.order_locn_cd)
	ord->olist[cnt].orderid = o.order_id
Detail
	case(od.oe_field_meaning)
		of spec_type_var:
			ord->olist[cnt].Specimen_type = od.oe_field_display_value
		of spec_desc_var:
			ord->olist[cnt].Specimen_description = od.oe_field_display_value
		of spec_labl_var:
			ord->olist[cnt].label_comment = od.oe_field_display_value
	endcase
 
with nocounter
 
;---------------------------------------------------------------------------------------------
;Get order location via location history

select into $outdev

elh.encntr_id, ordr = ord->olist[d.seq].orderid

from (dummyt d with seq = value(size(ord->olist, 5)))
	,encntr_loc_hist elh
	
plan d

join elh where elh.encntr_id = ord->olist[d.seq].encntrid
	and(cnvtdatetime(ord->olist[d.seq].original_ord_dt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1

order	by elh.encntr_id, ordr

Head ordr
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(ord->olist,5) ,ordr ,ord->olist[icnt].orderid)
	if(idx > 0)
		ord->olist[idx].order_loc = uar_get_code_description(elh.loc_nurse_unit_cd)
	endif	

with nocounter 
 
;---------------------------------------------------------------------------------------------
 
select into $outdev
	facility = trim(substring(1, 30, ord->olist[d1.seq].facility))
	,nurse_unit = trim(substring(1, 30, ord->olist[d1.seq].nurse_unit))
	,order_location = trim(substring(1, 100, ord->olist[d1.seq].order_loc))
	,fin = trim(substring(1, 10, ord->olist[d1.seq].fin))
	,order_id = ord->olist[d1.seq].orderid
	,order_name = trim(substring(1, 200, ord->olist[d1.seq].order_mnemonic))
	,specimen_type = trim(substring(1, 200, ord->olist[d1.seq].specimen_type))
	,specimen_description = trim(substring(1, 500, ord->olist[d1.seq].specimen_description))
	,label_comment = trim(substring(1, 500, ord->olist[d1.seq].label_comment))
 
from
	(dummyt   d1  with seq = size(ord->olist, 5))
 
plan d1
 
order by facility, nurse_unit, fin, ord->olist[d1.seq].orderid
 
with nocounter, separator=" ", format
 
end go

 
/*
 
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
select into $outdev
 
e.encntr_id, e.loc_nurse_unit_cd, e.reg_dt_tm, e.loc_facility_cd
,o.order_id, o.ordered_as_mnemonic, ce.event_cd, ce.result_val, ce.event_id, pt.comments
, cs.specimen_description, cs.specimen_cd, cs.spec_comments_long_text_id
, ode.oe_field_meaning
, off.label_text
, ode.oe_field_value
, ode.oe_field_display_value
 
from encounter e
	,code_value cv1
	,clinical_event ce
	,orders o
	,(left join processing_task pt on pt.order_id = o.order_id)
	,(left join case_specimen cs on cs.case_id = pt.case_id)
	, order_detail  ode
	, oe_format_fields  off
 
plan cv1 where cv1.code_set = 220
	and cv1.active_ind = 1
	and (cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*ENDO*'
		or cnvtupper(cv1.display) = '*GILAB*' )
	and cv1.cdf_meaning in('NURSEUNIT', 'AMBULATORY')
 
join e where e.loc_nurse_unit_cd = cv1.code_value
	and e.loc_facility_cd = $acute_facility_list
	;and e.encntr_id = 121122569.00
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.catalog_cd in(2553794147.00,313046.00)
 
join ce where ce.encntr_id = o.encntr_id
	and ce.event_cd in(272979611.00)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (34.00, 25.00, 35.00)
 
join pt ;where pt.order_id = o.order_id
 
join cs ;where cs.case_id = outerjoin(pt.case_id)
 
join ode where ode.order_id = o.order_id
	and ode.oe_field_meaning = 'LBLCMNT'
 
join off where off.oe_field_id = ode.oe_field_id
	and off.oe_format_id= o.oe_format_id
 
 
order by e.encntr_id
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
;select * from order_detail od where od.order_id =  3561363811.00
 
select *
from order_detail od, oe_format_fields  off
where od.order_id =  3561363811.00
 
 
;select * from long_text lt where lt.long_text_id =              1066279849.00
 
 /*
select cen.long_text_id, lt.long_text
from clinical_event ce, ce_event_note cen, long_text lt
where ce.encntr_id =  121122569.00
and cen.event_id = ce.event_id
and lt.long_text_id = cen.long_text_id
 
 
	/*and ce.event_cd in(SELECT CV2.CODE_VALUE FROM CODE_VALUE CV2
					WHERE CV2.CODE_SET =  72 AND CV2.ACTIVE_IND = 1
					and cnvtlower(cv2.display) = '*specimen*')*/
 
 
 
 
 
 
;----------------------------------------------------------------------------------------------
/*
select into $outdev
 
e.encntr_id, e.loc_nurse_unit_cd, e.reg_dt_tm, e.loc_facility_cd
, ce.event_cd, ce.result_val
 
from encounter e
	,code_value cv1
	, clinical_event ce
	;,code_value cv2
 
plan cv1 where cv1.code_set = 220
	and cv1.active_ind = 1
	and (cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*ENDO*'
		or cnvtupper(cv1.display) = '*GILAB*' )
	and cv1.cdf_meaning in('NURSEUNIT', 'AMBULATORY')
 
join e where e.loc_nurse_unit_cd = cv1.code_value
	and e.loc_facility_cd = $acute_facility_list
	;and e.encntr_id = 121122569.00
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	;;-- and ce.event_cd in(272979611.00
	;and ce.event_cd in(3017281.00, 2565188669.00, 2804452363.00, 2556644465.00,21828322.00,3230191097.00
	;				,272979611.00, 41424115.00,2558872497.00,23256991.00)
	and ce.event_cd in(SELECT CV2.CODE_VALUE FROM CODE_VALUE CV2
					WHERE CV2.CODE_SET =  72 AND CV2.ACTIVE_IND = 1
					and cnvtlower(cv2.display) = '*comment*')
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (34.00, 25.00, 35.00)
 
order by e.encntr_id, ce.event_cd
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
*/
 
 
 
/*
select distinct
cv1.code_value,cv1.display, cv1.description, cv1.cdf_meaning
from code_value cv1
where cv1.code_set = 220
and cv1.active_ind = 1
and (cnvtupper(cv1.description) = '*TEMP*' or cnvtupper(cv1.description) = '*ENDO*'
	or cnvtupper(cv1.display) = '*GILAB*' )
and cv1.cdf_meaning in('NURSEUNIT', 'AMBULATORY')
order by cv1.display
 
 
 
SELECT
	CV1.CODE_VALUE,
	CV1.DISPLAY,
	CV1.CDF_MEANING,
	CV1.DESCRIPTION,
	CV1.DISPLAY_KEY,
	CV1.CKI
FROM CODE_VALUE CV1
 
WHERE CV1.CODE_SET =  72 AND CV1.ACTIVE_IND = 1
and cnvtlower(cv1.display) = '*specimen*'
WITH  FORMAT, TIME = 60

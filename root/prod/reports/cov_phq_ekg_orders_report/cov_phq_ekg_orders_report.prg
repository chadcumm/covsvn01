/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb 2022
	Solution:			Quality
	Source file name:	      cov_phq_ekg_orders_report.prg
	Object name:		cov_phq_ekg_orders_report
	Request#:			12141
	Program purpose:	      EKG Orders
	Executing from:		DA2/Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------------------------------------------*/
 
drop program cov_phq_ekg_orders_report:dba go
create program cov_phq_ekg_orders_report:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ekg_elect_12_var  = f8 with constant(value(uar_get_code_by('DISPLAY',200, 'Electrocardiogram 12 Lead'))), protect
declare dnr_var           = f8 with constant(value(uar_get_code_by("DISPLAY",200, "Resuscitation Status/Medical Interventions"))),protect
declare comfort_meas_var  = f8 with constant(value(uar_get_code_by('DISPLAY',200, 'Comfort Measures'))), protect
declare ordered_var       = f8 with constant(value(uar_get_code_by('DISPLAY',6004, 'Ordered'))), protect
declare discon_var        = f8 with constant(value(uar_get_code_by('DISPLAY',6004, 'Discontinued'))), protect
declare ordr_priority_var = vc with constant('PRIORITY')
declare ordr_reason_var   = vc with constant('REASONFOREXAM')
 
declare opr_fac_var = vc with noconstant("")
 
;Facility variable Setup
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "l");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0)	;all[*] values were selected
	set opr_fac_var = "!="
else									;a single value was selected
	set opr_fac_var = "="
endif
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_type = vc
		2 pat_name = vc
		2 ekg_orderid = f8
		2 ekg_order_location = vc
		2 ekg_orderdt = dq8
		2 ekg_order_mnemonic = vc
		2 ekg_ordering_pr = vc
		2 ekg_order_priority = vc
		2 ekg_indication_reason = vc
		2 resu_med_intervention = vc
		2 comfort_meas_order = vc
		2 comfort_meas_order_dt = vc
		2 comfort_meas_order_tm = vc
	)

Record dnr(
	1 dnr_rec_cnt = i4
	1 list[*]
		2 dnr_encntrid = f8
		2 dnr_orderid = f8
		2 dnr_clin_display = vc
		2 dnr_ordered_status_dt = dq8
		2 dnr_discontinue_status_dt = dq8
	)

;======================================================================================================
;EKG Orders

select into $outdev
o.encntr_id, o.catalog_cd, o.order_mnemonic, o.ordered_as_mnemonic, o.orig_order_dt_tm, o.order_id, o.order_status_cd
 
from encounter e
	,orders o
 
plan e where operator(e.loc_facility_cd, opr_fac_var, $acute_facility_list)
	and e.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.catalog_cd = ekg_elect_12_var
	and o.active_ind = 1
	and o.order_status_cd not in(2542.00, 2544.00) ;Canceled, voided
	
order by e.encntr_id, o.order_id	

Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(pat->plist, cnt + 9)
	endif
	pat->rec_cnt = cnt
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].personid = e.person_id
	pat->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	pat->plist[cnt].ekg_orderid = o.order_id
	pat->plist[cnt].ekg_order_mnemonic = o.order_mnemonic
	pat->plist[cnt].ekg_orderdt = o.orig_order_dt_tm

Foot report
	stat = alterlist(pat->plist, cnt)
 
with nocounter 
 
if(pat->rec_cnt > 0)

;======================================================================================================
;Ordering PR

select into $outdev

from (dummyt d with seq = pat->rec_cnt)
	, order_action oa
	, prsnl pr
	
plan d

join oa where oa.order_id = pat->plist[d.seq].ekg_orderid

join pr where pr.person_id = oa.order_provider_id
	
order by oa.order_id

Head oa.order_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,oa.order_id ,pat->plist[icnt].ekg_orderid)
      while(idx > 0)
      	pat->plist[idx].ekg_ordering_pr = pr.name_full_formatted
      	idx = locateval(icnt ,(idx+1) ,pat->rec_cnt ,oa.order_id ,pat->plist[icnt].ekg_orderid)
      endwhile
	
with nocounter

;======================================================================================================
;EKG Priority
select into $outdev

from (dummyt d with seq = pat->rec_cnt)
	, order_detail od
	
plan d

join od where od.order_id = pat->plist[d.seq].ekg_orderid
	and od.oe_field_meaning in(ordr_priority_var, ordr_reason_var)

order by od.order_id, od.oe_field_id

Head od.order_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,od.order_id ,pat->plist[icnt].ekg_orderid)
Head od.oe_field_id	      
      	case(od.oe_field_meaning) 
      		of ordr_priority_var:
      			pat->plist[idx].ekg_order_priority = od.oe_field_display_value
      		of ordr_reason_var:	
      			pat->plist[idx].ekg_indication_reason = od.oe_field_display_value
      	endcase		
with nocounter 

;======================================================================================================

;Demographic
 
select into $outdev
 
from (dummyt d with seq = pat->rec_cnt)
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = pat->plist[d.seq].personid
	and p.active_ind = 1
 
join ea where ea.encntr_id = pat->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,ea.encntr_id ,pat->plist[icnt].encntrid)
	while(idx > 0)
		pat->plist[idx].pat_name = p.name_full_formatted
		pat->plist[idx].fin = trim(ea.alias)
		idx = locateval(icnt ,(idx+1) ,pat->rec_cnt ,ea.encntr_id ,pat->plist[icnt].encntrid)
	endwhile
 
with nocounter

;======================================================================================================
;EKG - Patient location at time of order

select into 'nl:'
 
elh.encntr_id, ord_id = pat->plist[d.seq].ekg_orderid
, order_pat_loc = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd)),' '
	,trim(uar_get_code_display(elh.loc_room_cd)),' ', trim(uar_get_code_display(elh.loc_bed_cd)))
 
from (dummyt d WITH seq = pat->rec_cnt)
	, encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = pat->plist[d.seq].encntrid
	and pat->plist[d.seq].ekg_orderdt != 0
	and (cnvtdatetime(pat->plist[d.seq].ekg_orderdt) between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	and elh.active_ind = 1
 
order by elh.encntr_id, ord_id
 
Head ord_id
 	icnt = 0
	idx = 0
	idx = locateval(icnt,1 ,pat->rec_cnt, ord_id, pat->plist[icnt].ekg_orderid)
	if(idx > 0)
		pat->plist[idx].ekg_order_location = order_pat_loc
	endif
 
with nocounter

;======================================================================================================
;Resucitation Status
 
select into $outdev
 o.encntr_id, o.orig_order_dt_tm, o.ordered_as_mnemonic, o.order_id, o.catalog_cd, o.order_status_cd
 ,od.oe_field_meaning, od.oe_field_display_value
 
from (dummyt d with seq = pat->rec_cnt)
	, orders o
	, order_detail od
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd = dnr_var
	and o.active_ind = 1
 
join od where od.order_id = o.order_id
	and od.oe_field_meaning = 'RESUSCITATIONSTATUS'
	;and od.oe_field_display_value = '*DNR*' 
 
order by o.encntr_id, o.order_id

Head report
	ecnt = 0
Head o.order_id
	ecnt += 1
	if(mod(ecnt,10) = 1 or ecnt = 1)
		stat = alterlist(dnr->list, ecnt+9)
	endif	
	dnr->dnr_rec_cnt = ecnt
	dnr->list[ecnt].dnr_encntrid = o.encntr_id		
	dnr->list[ecnt].dnr_orderid = o.order_id
	dnr->list[ecnt].dnr_clin_display = od.oe_field_display_value
Foot report
	stat = alterlist(dnr->list, ecnt)	
with nocounter

;======================================================================================================
;Resu Order Action

select into $outdev
oa.order_id, oa.order_status_cd, oa.action_dt_tm 

from (dummyt d with seq = dnr->dnr_rec_cnt)
	,order_action oa 
	
plan d

join oa where oa.order_id = dnr->list[d.seq].dnr_orderid
	and oa.order_status_cd in(ordered_var, discon_var)

order by oa.order_id, oa.order_status_cd

Head oa.order_id
 	icnt = 0
	idx = 0
	idx = locateval(icnt,1 ,dnr->dnr_rec_cnt, oa.order_id, dnr->list[icnt].dnr_orderid)
Head oa.order_status_cd
		case(oa.order_status_cd)
			of ordered_var:
				dnr->list[idx].dnr_ordered_status_dt = oa.action_dt_tm
			of discon_var:	
				dnr->list[idx].dnr_discontinue_status_dt = oa.action_dt_tm
		endcase		
with nocounter

call echorecord(dnr)

;======================================================================================================
;Resu order at the time of EKG?

select into $outdev

enc = pat->plist[d.seq].encntrid, dnr_ord = dnr->list[d1.seq].dnr_orderid
,resu_name = dnr->list[d1.seq].dnr_clin_display
, ekg_dt = format(pat->plist[d.seq].ekg_orderdt,"mm-dd-yyyy hh:mm;;d") 
, dnr_start_dt = format(dnr->list[d1.seq].dnr_ordered_status_dt,"mm-dd-yyyy hh:mm;;d") 
, dnr_end_dt = format(dnr->list[d1.seq].dnr_discontinue_status_dt,"mm-dd-yyyy hh:mm;;d") 

from (dummyt d with seq = pat->rec_cnt)
	,(dummyt d1 with seq = dnr->dnr_rec_cnt)

plan d

join d1 where pat->plist[d.seq].encntrid = dnr->list[d1.seq].dnr_encntrid
	and (format(pat->plist[d.seq].ekg_orderdt,"mm-dd-yyyy hh:mm;;d") between
		format(dnr->list[d1.seq].dnr_ordered_status_dt,"mm-dd-yyyy hh:mm;;d") 
		and format(dnr->list[d1.seq].dnr_discontinue_status_dt,"mm-dd-yyyy hh:mm;;d") )
	
	OR (format(pat->plist[d.seq].ekg_orderdt,"mm-dd-yyyy hh:mm;;d") >=
		format(dnr->list[d1.seq].dnr_ordered_status_dt,"mm-dd-yyyy hh:mm;;d") 
		and format(dnr->list[d1.seq].dnr_discontinue_status_dt,"mm-dd-yyyy hh:mm;;d") = ' ' )

order by enc, dnr_ord

Head enc
	dnr_list = fillstring(3000," ")
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,enc ,pat->plist[icnt].encntrid)
Head dnr_ord
	dnr_list = build2(trim(dnr_list),'[' ,trim(resu_name),'- (',dnr_start_dt,' TO ',dnr_end_dt,' ) ]',',')
Foot enc
	pat->plist[idx].resu_med_intervention = replace(trim(dnr_list),",","",2)
with nocounter 

;======================================================================================================
;Comfort measure

select into $outdev
 o.encntr_id, o.orig_order_dt_tm, o.ordered_as_mnemonic, o.order_id, o.catalog_cd, o.order_status_cd
 
from (dummyt d with seq = pat->rec_cnt)
	, orders o
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.order_id = (select min(o1.order_id) from orders o1
				where o1.encntr_id = o.encntr_id
				and o1.catalog_cd = comfort_meas_var
				and o1.active_ind = 1
				group by o1.encntr_id, o1.catalog_cd)

order by o.encntr_id, o.order_id

Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,o.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].comfort_meas_order = o.order_mnemonic
		pat->plist[idx].comfort_meas_order_dt = format(o.orig_order_dt_tm, 'mm/dd/yy;;q') 
		pat->plist[idx].comfort_meas_order_tm = format(o.orig_order_dt_tm, 'hh:mm:ss;;q') 
	endif		
with nocounter


;======================================================================================================

call echorecord(pat)

;======================================================================================================
 
 select into $outdev
	facility = trim(substring(1, 30, pat->plist[d1.seq].facility))
	, fin = trim(substring(1, 30, pat->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 60, pat->plist[d1.seq].pat_name))
	, patient_type = trim(substring(1, 100, pat->plist[d1.seq].pat_type))
	, ekg_order_dt = format(pat->plist[d1.seq].ekg_orderdt, 'mm/dd/yy hh:mm:ss;;q')
	, ekg_order_location = trim(substring(1, 500, pat->plist[d1.seq].ekg_order_location))
	, ekg_order = trim(substring(1, 500, pat->plist[d1.seq].ekg_order_mnemonic))
	, ordering_provider = trim(substring(1, 60, pat->plist[d1.seq].ekg_ordering_pr))
	, ekg_priority = trim(substring(1, 30, pat->plist[d1.seq].ekg_order_priority))
	, ekg_indication_reason = trim(substring(1, 30, pat->plist[d1.seq].ekg_indication_reason))
	, Resuscitation_Medical_Intervention = trim(substring(1, 500, pat->plist[d1.seq].resu_med_intervention))
	, comfort_order = trim(substring(1, 300, pat->plist[d1.seq].comfort_meas_order))
	, comfort_order_dt = trim(substring(1, 30, pat->plist[d1.seq].comfort_meas_order_dt))
	, comfort_order_tm = trim(substring(1, 30, pat->plist[d1.seq].comfort_meas_order_tm))

from
	(dummyt   d1  with seq = size(pat->plist, 5))

plan d1 where trim(substring(1, 60, pat->plist[d1.seq].ekg_ordering_pr))!= 'SYSTEM, SYSTEM*'

order by facility	, ekg_order_dt

with nocounter, separator=" ", format
 
 
 
endif ;rec_cnt
  
#exitscript
 

;with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
;go to exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

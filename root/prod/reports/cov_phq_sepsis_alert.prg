/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jul'2020
	Solution:			Quality
	Source file name:	      cov_phq_sepsis_alert.prg
	Object name:		cov_phq_sepsis_alert
	Request#:			8178
	Program purpose:	      Sepsis Alert Tracking analysis
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_sepsis_alert:dba go
create program cov_phq_sepsis_alert:dba
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Acute Facility List" = 0
 
with OUTDEV, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare sep_quality_meas_var  = f8 with constant(uar_get_code_by("DISPLAY", 200, "Sepsis Quality Measures")),protect
declare sep_ip_alert_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Severe Sepsis IP Alert")),protect
declare sep_ed_alert_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Severe Sepsis ED Alert")),protect
declare sep_ed_triage_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, "ED Triage Sepsis Alert")),protect
declare sep_advisor_var       = f8 with constant(uar_get_code_by("DISPLAY", 200, "Sepsis Advisor")),protect
declare septic_shock_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, "Septic Shock Alert")),protect
 
declare cnt = i4 with noconstant(0)
declare num = i4 with noconstant(0)
 
/**************************************************************
;               START CODING
**************************************************************/
 
Record sep_ord(
	1 olist[*]
		2 facility = vc
		2 fin = vc
		2 encntrid = f8
		2 orderid = f8
		2 order_comment = vc
		2 pat_name = vc
		2 admit_dt = vc
		2 sepsis_orders = vc
		2 sepsis_qm_order = vc
		2 provider_dignosis = vc
		2 diagnosis_dt = vc
)
 
;--------------------------  SEPSIS FIND VIA ORDERS/ALERTS -----------------------------------------------------------
 
;Get all sepsis orders fired
select into $outdev
o.encntr_id, o.catalog_cd, orderable = uar_get_code_display(o.catalog_cd), o.orig_order_dt_tm
from
	encounter e
	,orders o
	,encntr_alias ea
	,person p
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.disch_dt_tm is null
	and e.encntr_id != 0.0
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00, 19962820.00, 2555267433.00, 309311.00, 2555137051.00)
		;Inpatient, Observation, Outpatient in a Bed, Newborn, Day Surgery, Behavioral Health
 
join o where o.encntr_id = e.encntr_id
	and o.catalog_cd in(sep_ip_alert_var, sep_ed_alert_var, sep_ed_triage_var, sep_advisor_var
		, sep_quality_meas_var, septic_shock_var)
	and o.active_ind = 1
 
join ea where ea.encntr_id = o.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by o.encntr_id, o.order_id
 
Head report
	cnt = 0
Head o.encntr_id
	cnt += 1
	sepsis_orders_var = fillstring(3000," ")
	call alterlist(sep_ord->olist, cnt)
	sep_ord->olist[cnt].facility = uar_get_code_description(e.loc_facility_cd)
	sep_ord->olist[cnt].admit_dt = format(e.reg_dt_tm,"mm-dd-yy hh:mm;;d")
	sep_ord->olist[cnt].encntrid = e.encntr_id
	sep_ord->olist[cnt].fin = trim(ea.alias)
	sep_ord->olist[cnt].pat_name = trim(p.name_full_formatted)
 
Head o.order_id
	sep_ord->olist[cnt].orderid = o.order_id
	if(o.catalog_cd != sep_quality_meas_var)
		sepsis_orders_var = build2(trim(sepsis_orders_var),'[' ,trim(orderable)
				, ' - ', format(o.orig_order_dt_tm,"mm-dd-yy hh:mm;;d"),']',',')
 
	elseif(o.catalog_cd = sep_quality_meas_var)
		sep_ord->olist[cnt].sepsis_qm_order = build2(trim(orderable)
				, ' - ', format(o.orig_order_dt_tm,"mm-dd-yy hh:mm;;d"))
	endif
 
Foot o.encntr_id
	sep_ord->olist[cnt].sepsis_orders = replace(trim(sepsis_orders_var),",","",2)
	if(sep_ord->olist[cnt].sepsis_qm_order = ' ')
		sep_ord->olist[cnt].sepsis_qm_order = 'NONE'
	endif
 
with nocounter
 
;call echorecord(sep_ord)
 
;----------------------------------------------------------------------------------------------------------
;------------------------- SEPSIS FIND VIA DIAGNOSIS  -----------------------------------------------------
 
;Qualification - sepsis find via Provider Diagnosis - accounts not in orders
select into $outdev
 
dg.encntr_id, dg.diagnosis_display, n.source_identifier
 
from
	 encounter e
	, diagnosis dg
	, nomenclature n
 
plan e where  e.loc_facility_cd = $acute_facility_list
	and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00);ED, Inpatient, Observation, Outpatient in a Bed
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and e.disch_dt_tm is null
 
join dg where dg.encntr_id = e.encntr_id
	and dg.active_ind = 1
	and dg.active_status_cd = 188
	and dg.diagnosis_display != ''
 
join n where n.nomenclature_id = dg.nomenclature_id
	;and n.source_vocabulary_cd = 19350056.00 ;ICD-10-CM
	and n.active_ind = 1
	and n.end_effective_dt_tm > sysdate
	and n.active_status_cd = 188
	and n.source_identifier in ('A02.1', 'A22.7', 'A26.7', 'A32.7', 'A40.0', 'A40.1', 'A40.3', 'A40.8', 'A40.9', 'A41.01', 'A41.02',
					'A41.1', 'A41.2', 'A41.3', 'A41.4', 'A41.50', 'A41.51', 'A41.52', 'A41.53', 'A41.59', 'A41.8', 'A41.81',
					'A41.89', 'A41.9', 'A42.7', 'A54.86', 'B37.7', 'R65.20', 'R65.21')
 
order by e.person_id, e.encntr_id
 
;with nocounter, separator=" ", format
;GO TO exitscript
 
;append rows into the Sepsis record structure if it not in their already OR update Provider diagnosis if exists.
Head e.encntr_id
	icnt = 0
 	edx = 0
 	edx = locateval(icnt,1,size(sep_ord->olist,5), e.encntr_id, sep_ord->olist[icnt].encntrid)
Detail
	if(edx = 0) ;add new row
		cnt = cnt + 1
		call alterlist(sep_ord->olist, cnt)
		sep_ord->olist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		sep_ord->olist[cnt].encntrid = e.encntr_id
		;sep_ord->olist[cnt].personid = e.person_id
		sep_ord->olist[cnt].provider_dignosis = dg.diagnosis_display
		sep_ord->olist[cnt].diagnosis_dt = format(dg.diag_dt_tm, 'mm/dd/yy hh:mm;;d')
	else
	 	sep_ord->olist[edx].provider_dignosis = dg.diagnosis_display
	 	sep_ord->olist[edx].diagnosis_dt = format(dg.diag_dt_tm, 'mm/dd/yy hh:mm;;d')
	endif
 
Foot e.encntr_id
	if(edx = 0);update existing row
 		call alterlist(sep_ord->olist, cnt)
 	endif
 
with nocounter
 
call echorecord(sep_ord)
 
;------------------------------------------------------------------------------------------------------
;Get Order Comment for all encounters
/*
select into $outdev
 
enc = sep_ord->olist[num].encntrid, oc.order_id, lt.long_text, dt = format(lt.updt_dt_tm,';;q')
 
from   order_comment oc
	,long_text lt
 
plan oc where expand(num, 1, value(size(sep_ord->olist,5)), oc.order_id, sep_ord->olist[num].orderid)
	and oc.comment_type_cd = 66 ;Order Comment
 
join lt where lt.long_text_id = oc.long_text_id
	and lt.active_ind = 1
	and cnvtlower(lt.long_text) = '*sepsis*'; quality*'
 
order by enc, oc.order_id
 
;with nocounter, separator=" ", format, expand = 1
;go to exitscript
 
Head enc
	ord_comment_var = fillstring(3000," ")
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(sep_ord->olist,5), enc ,sep_ord->olist[cnt].encntrid)
 
Head oc.order_id
	ord_comment_var = build2(trim(ord_comment_var),'[' ,trim(lt.long_text)
				, ' - ', format(lt.updt_dt_tm,"mm-dd-yy hh:mm;;d"),']',',')
Foot enc
 	sep_ord->olist[idx].order_comment = replace(trim(ord_comment_var),",","",2)
 
with nocounter, expand = 1 */
 
 
;--------------------------------------------------------------------------------------------------------
;FINAL OUTPUT
select into $outdev
 
	facility = trim(substring(1, 30, sep_ord->olist[d1.seq].facility))
	, fin = trim(substring(1, 10, sep_ord->olist[d1.seq].fin))
	;, encntr_id = sep_ord->olist[d1.seq].encntrid
	, pat_name = trim(substring(1, 50, sep_ord->olist[d1.seq].pat_name))
	, admit_dt = trim(substring(1, 15, sep_ord->olist[d1.seq].admit_dt))
	, diagnosis =  trim(substring(1, 300, sep_ord->olist[d1.seq].provider_dignosis))
	, diagnosis_dt =  trim(substring(1, 20, sep_ord->olist[d1.seq].diagnosis_dt))
	, sepsis_alerts_fired = trim(substring(1, 1000, sep_ord->olist[d1.seq].sepsis_orders))
	, sepsis_qm_order_fired = trim(substring(1, 100, sep_ord->olist[d1.seq].sepsis_qm_order))
	;, rule_fired_alert = trim(substring(1, 2000, sep_ord->olist[d1.seq].order_comment))
 
from
	(dummyt   d1  with seq = size(sep_ord->olist, 5))
 
plan d1
 
order by facility, pat_name, fin
 
with nocounter, separator=" ", format
 
#exitscript
 
 
end go
 
 
 
 
 
 
 
 

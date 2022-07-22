 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Jun' 2020
	Solution:			Pharmacy
	Source file name:  	cov_phq_insulin_drip_result.prg
	Object name:		cov_phq_insulin_drip_result
	Request#:			8010
 
	Program purpose:	      Insulin drip rate and lab results
	Executing from:		DA2
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
------------------------------------------------------------------------------
08-20-20    Geetha Paramasivam  CR#8434 - Add Potassium level and Modify Rate change measure (units to ml)

******************************************************************************/
 
drop program cov_phq_insulin_drip_result:dba go
create program cov_phq_insulin_drip_result:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Acute Facility List" = 0
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, acute_facility_list, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var 	 = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare cmrn_var   = f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
declare mrn_var    = f8 with constant(uar_get_code_by("MEANING",319,"MRN")),protect
 
declare glucose_poc_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Glucose POC')), protect
declare glucose_art_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Glucose Art')), protect
declare blood_glucose_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Blood Glucose')), protect
 
declare start_rate_var = vc with noconstant("")
declare tmp_rate_var = vc with noconstant("")
declare rate_chg     = vc with noconstant("")
 
declare 12hr_time_var = f8 with noconstant(0.0)
declare num	= i4 with noconstant(0)
declare opr_facility_var = vc with noconstant("")
 
;Set Facility variable
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "L");multiple values were selected
	set opr_facility_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0) ;all[*] values were selected
	set opr_facility_var = "!="
else				  ;a single value was selected
	set opr_facility_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record drip(
	1 plist[*]
		2 facility_cd = f8
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_name = vc
		2 eventcd = f8
		2 event = vc
		2 orderid = f8
		2 original_order_dt = dq8
		2 order_dicontinue_dt = dq8
		2 order_prsnl = vc
		2 drip_stop_dt = dq8
		2 begin_bag_start_dt = dq8
		2 drip_infusion_start_rate = vc
		2 rate_change = vc
		2 glucose_poc_result = vc
		2 anion_gap_result = vc
		2 potasium_lvl = vc
		2 bags[*]
			3 encntrid = f8
			3 orderid = f8
			3 eventid = f8
			3 event_dt = dq8
			3 begin_bag_start_dt = dq8
			3 drip_infusion_start_rate = vc
		2 rates[*]
			3 encntrid = f8
			3 orderid = f8
			3 eventid = f8
			3 event_dt = dq8
			3 rate = vc
		2 gluco[*]
			3 encntrid = f8
			3 orderid = f8
			3 eventid = f8
			3 event_dt = dq8
			3 result = vc
 		2 anion[*]
 			3 encntrid = f8
			3 orderid = f8
			3 eventid = f8
			3 event_dt = dq8
			3 result = vc
		2 pota[*]
			3 encntrid = f8
			3 orderid = f8
			3 eventid = f8
			3 event_dt = dq8
			3 result = vc
 
)
 
;-------------------------------------------------------------------------------------------------------
;Get Patients currently in Insulin drip or last 12hr period
select into $outdev
 
fac = uar_get_code_display(e.loc_facility_cd);, fin = ea.alias
, e.reg_dt_tm, ce.encntr_id, ce.order_id
, 12hr_time_var = datetimediff(sysdate, ce.event_end_dt_tm, 3)
, days_time_var = datetimediff(sysdate, ce.event_end_dt_tm)
, ce.event_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_title_text, ce.event_tag
, ce.event_start_dt_tm, ce.event_end_dt_tm, ce.performed_dt_tm
, ce.verified_dt_tm, o.orig_order_dt_tm, o.catalog_cd, o.order_mnemonic
 
from location l
	,encounter e
	,clinical_event ce
	,orders o
	,order_detail od
	,order_detail od1
	,encntr_alias ea
 
plan l where l.facility_accn_prefix_cd in(2553225851.00,2553225859.00,2554055089.00,2554055109.00,2554055117.00
				,2554055131.00,2554055139.00)	;FSR,  LCMC,  MHHS,  PWMC,  MMC,  RMC,  FLMC
 
join e where e.loc_facility_cd = l.location_cd
	and operator(e.loc_facility_cd, opr_facility_var, $acute_facility_list)
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	/*;12hrs or lesser
	and (datetimediff(sysdate, ce.event_end_dt_tm) <= 0.50
		and datetimediff(sysdate, ce.event_end_dt_tm) > 0.00)*/
 	and ce.event_cd = 2798018.00 ;insulin regular
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
join o where o.encntr_id = ce.encntr_id
	and o.order_id = ce.order_id
	and o.active_ind = 1
 
join od where od.order_id = o.order_id
	and od.oe_field_id = 12693.00 ;DRUGFORM
	and od.oe_field_display_value = 'Soln-IV'
 
join od1 where od1.order_id = o.order_id
	and od1.oe_field_id = 12711.00	;RXROUTE
	and od1.oe_field_display_value = 'IV Continuous'
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by ce.encntr_id, ce.order_id
 
Head report
	cnt = 0
Head ce.order_id
	cnt += 1
	call alterlist(drip->plist, cnt)
Detail
	drip->plist[cnt].facility_cd = e.loc_facility_cd
	drip->plist[cnt].fin = trim(ea.alias)
	drip->plist[cnt].encntrid = e.encntr_id
	drip->plist[cnt].personid = e.person_id
	drip->plist[cnt].orderid = ce.order_id
	drip->plist[cnt].original_order_dt = o.orig_order_dt_tm
	drip->plist[cnt].eventcd = ce.event_cd
	drip->plist[cnt].event = uar_get_code_display(ce.event_cd)
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get order discontinue date
select into $outdev
 
 orderid = drip->plist[d.seq].orderid, oa.order_status_cd
 
from 	(dummyt d with seq = size(drip->plist, 5))
	,order_action oa
 
plan d
 
join oa where oa.order_id = drip->plist[d.seq].orderid
	and oa.action_type_cd = 2532.00 ;Discontinue
 
order by oa.order_id
 
Head oa.order_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), oa.order_id, drip->plist[icnt].orderid)
	if(idx > 0)
		drip->plist[idx].order_dicontinue_dt = oa.action_dt_tm
	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get order Provider info
select into $outdev
 
from 	(dummyt d1 with seq = size(drip->plist, 5))
	,order_action oa
	, prsnl pr
 
plan d1
 
join oa where oa.order_id = drip->plist[d1.seq].orderid
	and oa.action_type_cd = 2534.00 ;order
 
join pr where pr.person_id = oa.order_provider_id
	and pr.active_ind = 1
 
order by oa.order_id, oa.order_provider_id
 
Head oa.order_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), oa.order_id, drip->plist[icnt].orderid)
	if(idx > 0)
		drip->plist[idx].order_prsnl = trim(pr.name_full_formatted)
	endif
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get Begin infusion rate
select into $outdev
 
fin = drip->plist[d1.seq].fin,ce.encntr_id, ce.order_id, ce.event_tag, ce.event_end_dt_tm, ce.event_id
, event = uar_get_code_display(ce.event_cd)
,begin_infusion_rate = cmr.infusion_rate
 
from (dummyt d1 with seq = size(drip->plist, 5))
	,clinical_event ce
	,ce_med_result cmr
 
plan d1
 
join ce where ce.order_id = drip->plist[d1.seq].orderid
	and ce.event_cd = 679984.00 ;Administration Information
	and cnvtlower(ce.event_tag) = 'begin bag*'
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	;and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
join cmr where cmr.event_id = outerjoin(ce.event_id)
	and cmr.iv_event_cd = outerjoin(733.00) ;Begin Bag
 
order by ce.encntr_id, ce.order_id, ce.event_id
 
Head ce.order_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.order_id, drip->plist[icnt].orderid)
	bcnt = 0
	start_rate_var = ' '
Head ce.event_id
	bcnt += 1
	call alterlist(drip->plist[idx]->bags, bcnt)
	drip->plist[idx].bags[bcnt].encntrid = ce.encntr_id
	drip->plist[idx].bags[bcnt].orderid = ce.order_id
	drip->plist[idx].bags[bcnt].eventid = ce.event_id
	drip->plist[idx].bags[bcnt].begin_bag_start_dt = ce.event_end_dt_tm
	start_rate_var = trim(build2(trim(cnvtstring(cmr.infusion_rate, 15,2)),' '
			, trim(uar_get_code_display(cmr.infusion_unit_cd))))
	drip->plist[idx].bags[bcnt].drip_infusion_start_rate = start_rate_var
Foot ce.order_id
	drip->plist[idx].drip_infusion_start_rate = start_rate_var
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get Begin Bag details
select into $outdev
 
fin = drip->plist[d1.seq].fin,ce.encntr_id, ce.order_id, ce.event_tag, ce.event_end_dt_tm, ce.event_id
, event = uar_get_code_display(ce.event_cd)
,begin_infusion_rate = cmr.infusion_rate, cmr1.infusion_rate
 
from (dummyt d1 with seq = size(drip->plist, 5))
	,clinical_event ce
	,ce_med_result cmr
 
plan d1
 
join ce where ce.order_id = drip->plist[d1.seq].orderid
	and ce.event_cd = drip->plist[d1.seq].eventcd
		;679984.00 ;Administration Information
	and cnvtlower(ce.event_tag) = 'begin bag*'
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
join cmr where cmr.event_id = outerjoin(ce.event_id)
	and cmr.iv_event_cd = outerjoin(733.00) ;Begin Bag
 
 
order by ce.encntr_id, ce.order_id, ce.event_id
 
Head ce.order_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.order_id, drip->plist[icnt].orderid)
	bcnt = 0
 
Head ce.event_id
	bcnt += 1
	call alterlist(drip->plist[idx]->bags, bcnt)
	drip->plist[idx].bags[bcnt].encntrid = ce.encntr_id
	drip->plist[idx].bags[bcnt].orderid = ce.order_id
	drip->plist[idx].bags[bcnt].eventid = ce.event_id
	drip->plist[idx].bags[bcnt].begin_bag_start_dt = ce.event_end_dt_tm
 
Foot ce.order_id
	drip->plist[idx].begin_bag_start_dt = ce.event_end_dt_tm
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Get Drip stop time
select into $outdev
ce.encntr_id, ce.order_id, ce.event_tag, ce.event_end_dt_tm	, ce.event_id
, infusion_rate = cmr.infusion_rate
 
FROM 	 (dummyt d1 with seq = size(drip->plist, 5))
	, clinical_event ce
	, ce_med_result cmr
 
plan d1
 
join ce where ce.order_id = drip->plist[d1.seq].orderid
	and ce.event_cd = drip->plist[d1.seq].eventcd
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
join cmr where cmr.event_id = ce.event_id
	and cmr.iv_event_cd = 736.00 ;Rate Change
	and cmr.infusion_rate = 0
 
order by ce.encntr_id, ce.order_id, ce.event_id
 
Head ce.order_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.order_id, drip->plist[icnt].orderid)
	if(idx > 0)
		drip->plist[idx].drip_stop_dt = ce.event_end_dt_tm
 	endif
with nocounter
 
;-------------------------------------------------------------------------------------------------
;Get all the rate changes
select into $outdev
 
fin = drip->plist[d1.seq].fin, ce.encntr_id, ce.order_id, ce.event_tag, ce.event_end_dt_tm, ce.event_id
 
,infusion_rate = cmr.infusion_rate,cmr.iv_event_cd, iv_event = uar_get_code_display(cmr.iv_event_cd)
 
from (dummyt d1 with seq = size(drip->plist, 5))
	,clinical_event ce
	,ce_med_result cmr
 
plan d1
 
join ce where ce.order_id = drip->plist[d1.seq].orderid
	and ce.event_cd = drip->plist[d1.seq].eventcd
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
join cmr where cmr.event_id = ce.event_id
	and cmr.iv_event_cd = 736.00 ;Rate Change
	and cmr.infusion_rate != 0
 
order by ce.encntr_id, ce.order_id, ce.event_id
 
;with nocounter, separator=" ", format
;go to exitscript
 
Head ce.order_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.order_id, drip->plist[icnt].orderid)
	rate_chg = fillstring(3000," ")
	rcnt = 0
Head ce.event_id
	rcnt += 1
	call alterlist(drip->plist[idx]->rates, rcnt)
	drip->plist[idx].rates[rcnt].encntrid = ce.encntr_id
	drip->plist[idx].rates[rcnt].orderid = ce.order_id
	drip->plist[idx].rates[rcnt].eventid = ce.event_id
	drip->plist[idx].rates[rcnt].event_dt = ce.event_end_dt_tm
	drip->plist[idx].rates[rcnt].rate = build2(trim(cnvtstring(cmr.infusion_rate, 15,2)), ' '
		;,trim( uar_get_code_display(cmr.infusion_unit_cd)),' - '
		,trim( uar_get_code_display(cmr.infused_volume_unit_cd)),'/hr',' -'
		, trim(format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')))
 
Foot ce.event_id
	rate_chg = build2(trim(rate_chg),'[' ,trim(drip->plist[idx].rates[rcnt].rate),']',',')
 
Foot ce.order_id
	drip->plist[idx].rate_change = replace(trim(rate_chg),",","",2)
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get Glucose POC result - encounter level
select into $outdev
 
ce.encntr_id, ce.order_id, ce.result_val, event = uar_get_code_display(ce.event_cd)
,ce.event_tag, ce.event_end_dt_tm	, ce.event_id
 
from	 (dummyt d1 with seq = size(drip->plist, 5))
	, clinical_event ce
 
plan d1
 
join ce where ce.encntr_id = drip->plist[d1.seq].encntrid
	and ce.result_val != " "
	and ce.event_cd in(glucose_poc_var)
	and isnumeric(ce.result_val) > 0
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
order by ce.encntr_id, ce.order_id
 
Head ce.encntr_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.encntr_id, drip->plist[icnt].encntrid)
	gluco_poc = fillstring(3000," ")
	gcnt = 0
 
Head ce.order_id
	 gcnt += 1
	 call alterlist(drip->plist[idx]->gluco, gcnt)
Detail
	 drip->plist[idx].gluco[gcnt].encntrid = ce.encntr_id
	 drip->plist[idx].gluco[gcnt].orderid = ce.order_id
	 drip->plist[idx].gluco[gcnt].eventid = ce.event_id
	 drip->plist[idx].gluco[gcnt].event_dt = ce.event_end_dt_tm
	 drip->plist[idx].gluco[gcnt].result = build2(trim(ce.result_val),' -'
	 					, trim(format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')))
 
Foot ce.event_id
	gluco_poc = build2(trim(gluco_poc),'[' ,trim(drip->plist[idx].gluco[gcnt].result),']',',')
 
Foot ce.encntr_id
	while(idx > 0)
		drip->plist[idx].Glucose_poc_result = replace(trim(gluco_poc),",","",2)
		idx = locateval(icnt,(idx+1), size(drip->plist,5), ce.encntr_id, drip->plist[icnt].encntrid)
	endwhile
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get Anion Gap result
 
select into $outdev
 
ce.encntr_id, ce.order_id, ce.result_val, event = uar_get_code_display(ce.event_cd)
,ce.event_tag, ce.event_end_dt_tm	, ce.event_id
 
from	 (dummyt d1 with seq = size(drip->plist, 5))
	, clinical_event ce
 
plan d1
 
join ce where ce.encntr_id = drip->plist[d1.seq].encntrid
	and ce.result_val != " "
	and ce.event_cd = 41424295.00	;Anion Gap
	and isnumeric(ce.result_val) > 0
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
order by ce.encntr_id, ce.order_id
 
Head ce.encntr_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.encntr_id, drip->plist[icnt].encntrid)
	anion_rslt = fillstring(3000," ")
	acnt = 0
Head ce.order_id
	 acnt += 1
	 call alterlist(drip->plist[idx]->anion, acnt)
Detail
	 drip->plist[idx].anion[acnt].encntrid = ce.encntr_id
	 drip->plist[idx].anion[acnt].orderid = ce.order_id
	 drip->plist[idx].anion[acnt].eventid = ce.event_id
	 drip->plist[idx].anion[acnt].event_dt = ce.event_end_dt_tm
	 ;drip->plist[idx].anion[acnt].result = trim(ce.result_val)
	 drip->plist[idx].anion[acnt].result = build2(trim(ce.result_val),' -'
	 					, trim(format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')))
Foot ce.event_id
	anion_rslt = build2(trim(anion_rslt),'[' ,trim(drip->plist[idx].anion[acnt].result),']',',')
 
Foot ce.encntr_id
	while(idx > 0)
		drip->plist[idx].anion_gap_result = replace(trim(anion_rslt),",","",2)
		idx = locateval(icnt,(idx+1), size(drip->plist,5), ce.encntr_id, drip->plist[icnt].encntrid)
	endwhile
 
with nocounter
 
;------------------------------------------------------------------------------------------------------
;Pottasium Level
select into $outdev
 
ce.encntr_id, ce.order_id, ce.result_val, event = uar_get_code_display(ce.event_cd)
,ce.event_tag, ce.event_end_dt_tm	, ce.event_id
 
from	 (dummyt d1 with seq = size(drip->plist, 5))
	, clinical_event ce
 
plan d1
 
join ce where ce.encntr_id = drip->plist[d1.seq].encntrid
	and ce.result_val != " "
	and ce.event_cd = 2556649849.00 ;Potassium Levl
	and isnumeric(ce.result_val) > 0
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_title_text != 'IVPARENT'
	and ce.view_level = 1
	and ce.publish_flag = 1
 
order by ce.encntr_id, ce.order_id
 
Head ce.encntr_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), ce.encntr_id, drip->plist[icnt].encntrid)
	potas_rslt = fillstring(3000," ")
	pcnt = 0
Head ce.order_id
	 pcnt += 1
	 call alterlist(drip->plist[idx]->pota, pcnt)
Detail
	 drip->plist[idx].pota[pcnt].encntrid = ce.encntr_id
	 drip->plist[idx].pota[pcnt].orderid = ce.order_id
	 drip->plist[idx].pota[pcnt].eventid = ce.event_id
	 drip->plist[idx].pota[pcnt].event_dt = ce.event_end_dt_tm
	 drip->plist[idx].pota[pcnt].result = build2(trim(ce.result_val),' -'
	 					, trim(format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')))
Foot ce.event_id
	potas_rslt = build2(trim(potas_rslt),'[' ,trim(drip->plist[idx].pota[pcnt].result),']',',')
 
Foot ce.encntr_id
	while(idx > 0)
		drip->plist[idx].potasium_lvl = replace(trim(potas_rslt),",","",2)
		idx = locateval(icnt,(idx+1), size(drip->plist,5), ce.encntr_id, drip->plist[icnt].encntrid)
	endwhile
 
with nocounter
 
;------------------------------------------------------------------------------------------------------
;Patient Demographic
select into $outdev
 
from (dummyt d1 with seq = size(drip->plist, 5))
	,person p
 
plan d1
 
join p where p.person_id = drip->plist[d1.seq].personid
	and p.active_ind = 1
 
order by p.person_id
 
Head p.person_id
      icnt = 0
      idx = 0
	idx = locateval(icnt,1,size(drip->plist,5), p.person_id, drip->plist[icnt].personid)
	while(idx > 0)
		drip->plist[idx].pat_name = trim(p.name_full_formatted)
		idx = locateval(icnt,(idx+1),size(drip->plist,5), p.person_id, drip->plist[icnt].personid)
	endwhile
 
with nocounter
 
call echorecord(drip)
;------------------------------------------------------------------------------------------------------
 
select into $outdev
 
	facility = trim(uar_get_code_display(drip->plist[d1.seq].facility_cd))
	, fin = trim(substring(1, 10, drip->plist[d1.seq].fin))
	, pat_name = trim(substring(1, 50, drip->plist[d1.seq].pat_name))
	, order_id = drip->plist[d1.seq].orderid
	, Insulin_drip = trim(substring(1, 50, drip->plist[d1.seq].event))
	, ordering_provider = trim(substring(1, 50, drip->plist[d1.seq].order_prsnl))
	, begin_bag_start_dt = format(drip->plist[d1.seq].begin_bag_start_dt, 'mm/dd/yy hh:mm;;q')
	, drip_start_rate = drip->plist[d1.seq].drip_infusion_start_rate
	, rate_change = trim(substring(1, 3000, drip->plist[d1.seq].rate_change))
	, drip_stop_dt = format(drip->plist[d1.seq].drip_stop_dt, 'mm/dd/yy hh:mm;;q')
	, potassium_level = trim(substring(1, 3000, drip->plist[d1.seq].potasium_lvl))
	, glucose_poc_result = trim(substring(1, 3000, drip->plist[d1.seq].glucose_poc_result))
	, anion_gap_result = trim(substring(1, 3000, drip->plist[d1.seq].anion_gap_result))
 
from	(dummyt   d1  with seq = size(drip->plist, 5))
 
plan d1 where drip->plist[d1.seq].begin_bag_start_dt != null
 
order by facility, pat_name, order_id
 
with nocounter, separator=" ", format
 
 
#exitscript
 
end go
 
 

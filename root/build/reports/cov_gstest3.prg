 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Apr'2019
	Solution:			Quality
	Source file name:	      cov_phq_bcma_leapfrog_scorecard.prg
	Object name:		cov_phq_bcma_lfrog_scorecard
	Request#:			4549
	Program purpose:	      BCMA & Leapfrog scorecard
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-----------------------------------------------------------------
5/29/19     Geetha       CR#5017 - Include all depts/organizations (including Ambulatory locations)
06/04/19    Geetha       CR#4955 - Dispense category - "Dummy Item COA" excluded
09/10/19	Geetha	 CR#5389 - exclude Template-Non-Formulary intermitent and continuous from BCMA reports
12/13/19	Geetha	 CR#6816 - Addition to Leapfrog - New PW departments
05/27/20	Geetha	 CR#7825 - Add departments based on 2020 Leapfrog Guidelines
******************************************************************************/
 
drop program cov_gstest3:DBA go
create program cov_gstest3:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime
 
;-----------------------------------------------------------------------
;Prompt Validation
IF(month(cnvtdatetime($start_datetime)) != month(cnvtdatetime($end_datetime)) )
 
     select into $outdev
	     Error_message = "Date range should be in the same month, try again"
	     ,start_Date = $start_datetime, end_date = $end_datetime
      from dummyt
      with format, separator = " "
 
ELSE ;good with prompt - execute rest of the script
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
declare initcap() = c100
declare username = vc with protect
declare inpatient_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
declare getmonth(imonth = i4) = null
declare month_var = vc
declare sm = i2
declare em = i2
declare mcount = i2
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD bcma(
	1 report_ran_by = vc
	1 month[*]
		2 month_name = vc
		2 flist[*]
			3 month = i2
			3 month_name = vc
			3 facility = vc
			3 bc_neumarator = f8
			3 bc_denominator = f8
			3 bc_percent_compliance = f8
			3 lp_neumarator = f8
			3 lp_denominator = f8
			3 lp_percent_compliance = f8
)
 
;-------------------- HELPERS --------------------------------------------------------
 
Record month(
	1 list[*]
		2 imonth = i2
		2 month_name = vc
)
 
RECORD meds(
	1 list[*]
		2 facility_prefix_cd = f8
		2 encntrid = f8
		2 eventid = f8
		2 med_admin_eventid = f8
		2 nurse_unit_cd = f8
		2 event_cnt = i4
		2 positive_med_ident = i4
		2 positive_patient_ident = i4
		2 beg_dt_tm = dq8
		2 order_mnemonic = vc
		2 itemid = f8
		2 orderid = f8
		2 charge_number = vc
		2 met_comp = i4
		2 lp_event_cnt = i4
		2 lp_met_comp = i4
)
 
RECORD bc(
	1 list[*]
		2 month = i2
		2 month_name = vc
		2 facility = vc
		2 nurse_unit = vc
		2 leapfrog_unit = vc
		2 unit_tot_med_given = f8
		2 lp_unit_tot_med_given = f8
		2 unit_tot_compliance = f8
		2 lp_unit_tot_compliance = f8
)
 
 
;----------------------------------------------------------
;get list of months from the prompt
set sm = month(cnvtdatetime($start_datetime))
set em = month(cnvtdatetime($end_datetime))
set mcount = 0
 
while(sm <= em)
	select into 'nl:' from dummyt d
	detail
		mcount += 1
		call alterlist(month->list, mcount)
		case (sm)
			of 1  :  month_var = 'January'
			of 2  :  month_var = 'February'
			of 3  :  month_var = 'March'
			of 4  :  month_var = 'April'
			of 5  :  month_var = 'May'
			of 6  :  month_var = 'June'
		 	of 7  :  month_var = 'July'
			of 8  :  month_var = 'August'
			of 9  :  month_var = 'September'
			of 10 :  month_var = 'October'
			of 11 :  month_var = 'November'
			of 12 :  month_var = 'December'
		endcase
			month->list[mcount].month_name = trim(month_var)
			month->list[mcount].imonth = sm
	with nocounter
	set sm = sm + 1
endwhile
 
;--------------------------------------------------------
;Get user in action
select into "NL:"
from	prsnl p
where p.person_id = reqinfo->updt_id
 
detail
	bcma->report_ran_by = p.username
with nocounter
 
;--------------------------------------------------------
;Get BCMA numbers
select into 'nl:'
 
   l.facility_accn_prefix_cd, e.encntr_id, mae.event_id, mae.med_admin_event_id,  mae.nurse_unit_cd, mae.event_cnt
  , mae.positive_med_ident_ind, mae.positive_patient_ident_ind, mae.beg_dt_tm
  , met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif )
  , lp_event_cnt = evaluate2(if(e.encntr_type_cd = inpatient_var) 1 else 0 endif )
  , lp_met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1
  		and e.encntr_type_cd = inpatient_var)1 else 0 endif )
 
from  location l
  	, encounter e
  	, clinical_event ce
  	, med_admin_event mae
  	, orders o
  	, order_ingredient oi
  	, order_dispense od
 
plan l where l.facility_accn_prefix_cd in(2553225851.00,2553225859.00,2554055089.00,2554055109.00,2554055117.00,2554055131.00,2554055139.00)
	;FSR,  LCMC,  MHHS,  PWMC,  MMC,  RMC,  FLMC - all organizations/depts are included by using facility_accn_prefix_cd
 
join e where e.loc_facility_cd = l.location_cd
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.result_status_cd in(25, 34, 35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 
join mae where mae.event_id = ce.event_id
	and mae.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
  	and mae.nurse_unit_cd is not null
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
 
join oi where oi.order_id = mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join od where od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
 
order by mae.event_id
 
Head report
 	cnt = 0
Head mae.event_id
 	cnt += 1
	call alterlist(meds->list, cnt)
Detail
 	meds->list[cnt].facility_prefix_cd = l.facility_accn_prefix_cd
 	meds->list[cnt].nurse_unit_cd = mae.nurse_unit_cd
 	meds->list[cnt].encntrid = e.encntr_id
 	meds->list[cnt].eventid = mae.event_id
 	meds->list[cnt].orderid = o.order_id
 	meds->list[cnt].event_cnt = mae.event_cnt
 	meds->list[cnt].med_admin_eventid = mae.med_admin_event_id
 	meds->list[cnt].beg_dt_tm =  mae.beg_dt_tm
 	meds->list[cnt].order_mnemonic = cnvtlower(o.hna_order_mnemonic)
 	meds->list[cnt].positive_med_ident = mae.positive_med_ident_ind
 	meds->list[cnt].positive_patient_ident = mae.positive_patient_ident_ind
 	meds->list[cnt].met_comp = met_comp
 	meds->list[cnt].lp_event_cnt = lp_event_cnt
 	meds->list[cnt].lp_met_comp = lp_met_comp
 
with nocounter
 
/*Non_Formulary ************ START ****************************
;--------------------------------------------------------------------------------
;Get Item id
select into 'nl:'
 
from	(dummyt d with seq = value(size(meds->list, 5)))
	, order_product op
 
plan d
 
join op where op.order_id = outerjoin(meds->list[d.seq].orderid)
 
order by op.item_id
 
Head op.order_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(meds->list,5), op.order_id ,meds->list[icnt].orderid)
      if(idx > 0)
		meds->list[idx].itemid = op.item_id
	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Find missing Item_id's
select into 'nl:'
     mair.event_id, mai.item_id, mai.med_product_id
from
	(dummyt d WITH seq = value(size(meds->list,5)))
      , ce_med_admin_ident_reltn mair
	, ce_med_admin_ident mai
 
plan d where meds->list[d.seq].itemid = 0
 
join mair where mair.event_id = meds->list[d.seq].eventid
 
join mai where mai.ce_med_admin_ident_id = outerjoin(mair.ce_med_admin_ident_id)
 
order by mair.event_id
 
Head mair.event_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(meds->list,5), mair.event_id ,meds->list[icnt].eventid)
      if(idx > 0)
      	if(meds->list[idx].itemid = 0)
			meds->list[idx].itemid = mai.item_id
		endif
	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Get Charge numbers
select into 'nl:'
 
 mi.item_id, value = trim(mi.value ,3), mi.med_identifier_id
 
from	(dummyt d with seq = value(size(meds->list, 5)))
	, med_identifier mi
 
plan d
 
join mi where mi.item_id = meds->list[d.seq].itemid
	and mi.active_ind = 1
	and mi.med_identifier_type_cd = 3096.00 ;charge_num_var
 
order by mi.item_id
 
Head mi.item_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(meds->list,5), mi.item_id ,meds->list[cnt].itemid)
      while(idx > 0)
		meds->list[idx].charge_number = trim(mi.value, 3)
	      idx = locateval(cnt,(idx+1), size(meds->list,5), mi.item_id ,meds->list[cnt].itemid)
	endwhile
 
with nocounter
 
/*Non_Formulary ************ END ****************************/
 
;call echorecord(meds)
;----------------------------------------------------------------------------------------------------
;Get aggregated results
select into 'nl:'
	mon = month->list[d2.seq].imonth
	, mon_name = month->list[d2.seq].month_name
	, facility_prefix_cd = meds->list[d1.seq].facility_prefix_cd
	, nurse_unit_cd = meds->list[d1.seq].nurse_unit_cd
	, event_cnt = meds->list[d1.seq].event_cnt
	, beg_dt_tm = meds->list[d1.seq].beg_dt_tm
	, charge_number = substring(1, 30, meds->list[d1.seq].charge_number)
	, met_comp = meds->list[d1.seq].met_comp
	, lp_event_cnt = meds->list[d1.seq].lp_event_cnt
	, lp_met_comp = meds->list[d1.seq].lp_met_comp
 
from	(dummyt d1 with seq = size(meds->list, 5))
	,(dummyt d2 with seq = size(month->list, 5))
 
plan d1
/*Non Formulary filter
where substring(1,4, trim(substring(1, 30, meds->list[d1.seq].charge_number ))) != 'NCRX' ;Non Chargeable items
	and trim(substring(1, 300, meds->list[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
join d2 where month(meds->list[d1.seq].beg_dt_tm) = month->list[d2.seq].imonth
 
order by mon, facility_prefix_cd, nurse_unit_cd
 
Head report
      cnt = 0
Head nurse_unit_cd
 	cnt += 1
	call alterlist(bc->list, cnt)
	bc->list[cnt].month = mon
	bc->list[cnt].month_name = mon_name
 	bc->list[cnt].facility = trim(uar_get_code_description(facility_prefix_cd))
	bc->list[cnt].nurse_unit = uar_get_code_display(nurse_unit_cd)
Foot nurse_unit_cd
	bc->list[cnt].unit_tot_med_given = sum(event_cnt)
	bc->list[cnt].lp_unit_tot_med_given = sum(lp_event_cnt)
	bc->list[cnt].unit_tot_compliance = sum(met_comp)
	bc->list[cnt].lp_unit_tot_compliance = sum(lp_met_comp)
 
with nocounter
 
;call echorecord(bc)
 
;----------------------------------------------------------------------------------------------------------------------
;Flag LeapFrog departments
 
select into 'nl:'
 
 nunit = trim(substring(1,30, bc->list[d.seq].nurse_unit))
 
from	(dummyt d  with seq = size(bc->list, 5))
 
plan d where bc->list[d.seq].nurse_unit in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC',
	'FSR 2N',	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU',
	'FSR CV SD', 'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'FSR NEURO ICU',
	'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2', 'PW CB', 'PW 2D', 'PW 3D', 'PW 5R',
	'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'MHHS 3N',
	'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC', 'LCMC OB', 'FLMC CCU', 'FLMC MSU',
	'RMC 2N', 'RMC ICU' )
 
order by nunit
 
Head nunit
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(bc->list,5), nunit, bc->list[cnt].nurse_unit)
      while(idx > 0)
		bc->list[idx].nurse_unit = build2(bc->list[idx].nurse_unit, '*') ;leapfrog units
 		idx = locateval(cnt,(idx+1),size(bc->list,5), nunit, bc->list[cnt].nurse_unit)
 	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------
;Get final aggregated results
select into 'nl:'
 
  mon = bc->list[d.seq].month
, mon_name = bc->list[d.seq].month_name
, fac = trim(substring(1,30, bc->list[d.seq].facility))
, nu = trim(substring(1,30, bc->list[d.seq].nurse_unit))
, nu_tot_admin = bc->list[d.seq].unit_tot_med_given
, lp_nu_tot_admin = bc->list[d.seq].lp_unit_tot_med_given
, nu_tot_comp = bc->list[d.seq].unit_tot_compliance
, lp_nu_tot_comp = bc->list[d.seq].lp_unit_tot_compliance
 
from	(dummyt d  with seq = size(bc->list, 5))
 
plan d
 
order by mon, fac, nu
 
Head report
	mcnt = 0
Head mon
	mcnt += 1
	call alterlist(bcma->month, mcnt)
	bcma->month[mcnt].month_name = mon_name
	fcnt = 0
Head fac
	fcnt += 1
	call alterlist(bcma->month->flist, fcnt)
	fac_tot_admin = 0.0, fac_tot_comp_admin = 0.0, lp_fac_tot_admin = 0.0, lp_fac_tot_comp_admin = 0.0
	ncnt = 0
Detail
	pos = 0
	fac_tot_admin += nu_tot_admin
	fac_tot_comp_admin += nu_tot_comp
	pos = findstring("*" ,nu)
	if(pos != 0)
		lp_fac_tot_admin += lp_nu_tot_admin
		lp_fac_tot_comp_admin += lp_nu_tot_comp
	endif
 
Foot fac
	bcma->month[mcnt].flist[fcnt].month = mon
	bcma->month[mcnt].flist[fcnt].month_name = mon_name
	bcma->month[mcnt].flist[fcnt].facility = fac
	bcma->month[mcnt].flist[fcnt].bc_neumarator = fac_tot_comp_admin
	bcma->month[mcnt].flist[fcnt].bc_denominator = fac_tot_admin
	bcma->month[mcnt].flist[fcnt].bc_percent_compliance = ((fac_tot_comp_admin * 100) / fac_tot_admin)
	bcma->month[mcnt].flist[fcnt].lp_neumarator = lp_fac_tot_comp_admin
	bcma->month[mcnt].flist[fcnt].lp_denominator = lp_fac_tot_admin
	bcma->month[mcnt].flist[fcnt].lp_percent_compliance = ((lp_fac_tot_comp_admin * 100) / lp_fac_tot_admin)
	call alterlist(bcma->month->flist, fcnt)
 
with nocounter
 
call echorecord(bcma)
 
;-------------------------------------------------------------------------------------------------------
 
SELECT INTO $OUTDEV
 
	MONTH = SUBSTRING(1, 30, BCMA->month[D1.SEQ].month_name)
	, FACILITY = SUBSTRING(1, 30, BCMA->month[D1.SEQ].flist[D2.SEQ].facility)
	, BCMA_NUMERATOR = BCMA->month[D1.SEQ].flist[D2.SEQ].bc_neumarator
	, BCMA_DENOMINATOR = BCMA->month[D1.SEQ].flist[D2.SEQ].bc_denominator
	, BCMA_PERCENT_COMPLIANCE = build2(BCMA->month[D1.SEQ].flist[D2.SEQ].bc_percent_compliance, '%')
	, LEAPFROG_NUMERATOR = BCMA->month[D1.SEQ].flist[D2.SEQ].lp_neumarator
	, LEAPFROG_DENOMINATOR = BCMA->month[D1.SEQ].flist[D2.SEQ].lp_denominator
	, LEAPFROG_PERCENT_COMPLIANCE = build2(BCMA->month[D1.SEQ].flist[D2.SEQ].lp_percent_compliance, '%')
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA->month, 5))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1 WHERE MAXREC(D2, SIZE(BCMA->month[D1.SEQ].flist, 5))
JOIN D2
 
ORDER BY MONTH, FACILITY
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
;----------------------------------------------------------------------------------------------------------------
 
ENDIF ;Prompt validation
 
end go
 
 
/*
;Facility_accn_prefix_cd
 
select cv1.code_value, cv1.display, cv1.description
from code_value cv1
where cv1.code_set =  2062 and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
order by cv1.description
 
 
;Get Nurse unit description
select Leapfrog_unit = cv1.display, cv1.description
from code_value cv1 where cv1.code_set = 220
and cv1.cdf_meaning = 'NURSEUNIT'
and cv1.display in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'PW 2D', 'PW 3D', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S',
	'LCMC ICU', 'LCMC IMC',	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU' )
order by cv1.display
 
*/
 

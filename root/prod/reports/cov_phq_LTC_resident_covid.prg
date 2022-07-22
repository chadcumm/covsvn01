 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan'2021
	Solution:			Quality
	Source file name:		cov_phq_LTC_resident_covid.prg
	Object name:		cov_phq_LTC_resident_covid
 	Request#:			9181
	Program purpose:		COVID-19 data submission to NHSN/CDC
	Executing from:		DA2/AUTO RUN SCHEDULE
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
------------------------------------------------------------------------------
01/31/22    Geetha Paramasivam  CR#12100  Covid test name change update
 
******************************************************************************/
 
drop program cov_phq_LTC_resident_covid:dba go
create program cov_phq_LTC_resident_covid:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Specimen Collected Date/Time" = "SYSDATE"
	, "End Specimen Collected Date/Time" = "SYSDATE"
	, "Report Type" = 2
	, "Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, repo_type, ltc_facility
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;Orders
declare covid_ref_lab_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 Reference Lab')), protect
declare covid_mpl_ref_lab_var = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 PCR MPL Reference Lab')), protect ;'COVID19 MPL Reference Lab'
declare covid_respiratory_var = f8 with constant(uar_get_code_by("DISPLAY", 200, 'Respiratory Panel')), protect ;'Respiratory Panel (incl COVID19)'
declare covid_in_house_var    = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 In-House')), protect
declare covid_pcr_confirm_var = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 PCR Confirmation')), protect
declare covid_SARS_var        = f8 with constant(uar_get_code_by("DISPLAY", 200, 'SARS-CoV-2 RNA Qual RT-PCR')), protect
declare covid_CDC_var         = f8 with constant(uar_get_code_by("DISPLAY", 200, 'CDC COVID19 HR RT PCR')), protect
declare covid_ref_mayo_var    = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 Reference Lab Mayo')), protect
declare covid_repid_resp_var  = f8 with constant(uar_get_code_by("DISPLAY", 200, 'Rapid Resp (COVID19+Flu A/B) Panel+')), protect
declare covid_repid_anti_var  = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 Rapid Antigen')), protect
 
;Events
declare sars_rna_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS CoV2 RNA, RT PCR')), protect
declare covid_report_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 See Report')), protect
declare covid_result_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Result')), protect
declare sars_cov2_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2')), protect
declare sars_cov2_anti_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2 Antigen')), protect
declare pan_sars_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PAN-SARS RNA')), protect
declare covid_overall_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Overall Result')), protect
declare covid_reflab_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Reference Lab')), protect
declare sars_cov2_naa1_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2, NAA')), protect
declare sars_cov2_naa2_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2, NAA.')), protect

;Isolation 
declare cov2_past_rslt_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID-19 test past results')), protect
declare cov2_isolation_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Isolation Precautions')), protect
declare cov2_isolation_var1 = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Isolation Type')), protect

declare num  = i4 with noconstant(0)
declare cnt  = i4 with noconstant(0)
declare ocnt = i4 with noconstant(0)
declare ecnt = i4 with noconstant(0)
declare rcnt = i4 with noconstant(0)
 
declare lab_ord_cnt  = i4 with noconstant(0)
declare positive_cnt = i4 with noconstant(0)
declare died_pat_cnt = i4 with noconstant(0)
declare died_positive_c19_cnt = i4 with noconstant(0)
 
declare op_acute_facility_var = vc with noconstant("")
declare op_ltc_facility_var1 = vc with noconstant("")
 
declare fsr_tcu_var    = f8 with constant(2553765707.00)
declare lcmc_nsg_var   = f8 with constant(2553765371.00)
declare fsr_acute_var  = f8 with constant(21250403.00)
declare lcmc_acute_var = f8 with constant(2552503653.00)
declare posanti_negpcr = i4
declare other_pos = i4

declare start_date_var1 = vc
declare end_date_var1   = vc
declare start_date = f8
declare end_date   = f8
 
;---------------------------------------------------------------------------------------------------------
;Set default date for DA2 schedule
set start_date = cnvtlookbehind("7,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("7,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)
 
;call echo(build('start_date = ',format(cnvtdatetime(start_date), 'dd-mmm-yyyy hh:mm:ss;;d'), '-- end_date = ',
;		format(cnvtdatetime(end_date), 'dd-mmm-yyyy hh:mm:ss;;d')))

 
if($start_datetime = "THURSDAY")
	set start_date_var1 = format(cnvtdatetime(start_date), 'dd-mmm-yyyy hh:mm:ss;;d')
 	set end_date_var1 = format(cnvtdatetime(end_date), 'dd-mmm-yyyy hh:mm:ss;;d')
else
	set start_date_var1 = $start_datetime
 	set end_date_var1 = $end_datetime
endif
 
call echo(build('start_date_var = ', start_date_var1, '--- end_date_var = ',end_date_var1))
 
;---------------------------------------------------------------------------------------------------------
 
;Set LTC Facility variable Operator
if(substring(1,1,reflect(parameter(parameter2($ltc_facility),0))) = "l");multiple values were selected
	set op_ltc_facility_var1 = "in"
else								;a single value was selected
	set op_ltc_facility_var1 = "="
endif
 
;Set acute location based on LTC location
case ($ltc_facility)
	of  fsr_tcu_var  : set op_acute_facility_var = build2("e.loc_facility_cd = ", fsr_acute_var)
	of  lcmc_nsg_var : set op_acute_facility_var = build2("e.loc_facility_cd = ", lcmc_acute_var)
	else set op_acute_facility_var = build2("e.loc_facility_cd in (", fsr_acute_var,",", lcmc_acute_var ,")" )
endcase
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
Record ltc(
	1 fac_cnt = i4
	1 flist[*]
		2 staff_testing_facility_id = f8
		2 cdc_facility_name = vc
		2 list[*]
			3 cdc_facility_id = vc
			3 cdc_facility_ccn = vc
			3 cdc_facility_type = vc
			3 collection_date = vc
			3 numres_admc19 = i4 ;previously positive c19
			3 numres_died = i4
			3 numres_c19died = i4
			3 num_ltcf_beds = i4
			3 num_ltcf_beds_occ = i4
			3 numres_postest = i4
			3 numres_postestposag = i4 ;positive anti
			3 numres_postestposnaat = i4 ;positive pcr
			3 numres_postestposagnegnaat = i4 ;positive anti and negative pcr
			3 numres_postestother = i4 ;any one positive result
			3 numres_postestreinf = i4 ;reinfected
			3 numres_confflu = i4 ;confirmed Flu
			3 numres_conffluc19 = i4 ;Flu and c19
			3 res_c19poctestperf = i4 ;pcr only
			3 staff_c19poctestperf = i4
			3 res_c19nonpoctestperf = i4 ;antigen only
			3 c19_nonpoctestresults = i4;pull - days between sars to POC
	)
 
;------------- Helpers -----------------------------------------
 
Record pat(
	1 pat_rec_cnt = i4
	1 list[*]
		2 facility = f8
		2 reporting_facility_id = vc
		2 reporting_facility_ccn = vc
		2 reporting_facility_type = vc
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_name = vc
		2 disch_dt = dq8
		2 lab_order_dt = dq8
		2 lab_order_name = vc
		2 reporting_dt = dq8
		2 result_received_dt = dq8
		2 orderid = f8
		2 sars_cov_2_pcr_specimen_dt = dq8
		2 sars_cov_2_pcr_event = vc
		2 sars_cov_2_pcr_result = vc
		2 sars_cov_2_pcr_positive = vc
		2 sars_cov_2_pcr_result_dt = vc
		2 sars_cov_2_pcr_order_name = vc
		2 sars_cov_2_antigen_specimen_dt = dq8
		2 sars_cov_2_antigen_event = vc
		2 sars_cov_2_antigen_result = vc
		2 sars_cov_2_antigen_positive = vc
		2 sars_cov_2_antigen_result_dt = vc
		2 sars_cov_2_antigen_order_name = vc
		2 reinfected = vc
		2 reinfected_dt = vc
		2 influenza_positive = vc
		2 influenza_positive_dt = vc
		2 patient_status = vc
		2 deceased_dt = dq8
)
 
Record expired(
	1 expired_rec_cnt = i4
	1 list[*]
		2 encntrid = f8
		2 encntr_type = f8
		2 facility_cd = f8
		2 disch_dispo_cd = f8
		2 personid = f8
		2 decease_cd = f8
		2 decease_dt = dq8
		2 reg_dt = dq8
		2 disch_dt = dq8
)
 
Record flu(
	1 list[*]
		2 flu_code_value = f8
		2 flu_display = vc
	)
 
Record dispo(
	1 list[*]
		2 personid = f8
		2 encntrid = f8
		2 dispo_text = vc
	)
 
Record admitc19(
	1 admitc19_rec_cnt = i4
	1 list[*]
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 fin = vc
		2 pat_name = vc
		2 facility = vc
		2 reg_dt = vc
		2 isolation_type = vc
		2 isolation_reason = vc
		2 isolation_dt = vc
		2 covid_test = vc
		2 covid_result = vc
		2 covid_result_dt = vc
)
 
;======================================================================================================
;Assign staff testing location to RC



;------------------------------------------------------------------------------------------------------
;Previous encounter not in LTC
;Get all patients
 
; NOT USED AS IT'S NOT CONSISTENT AS OF 01/21/21
select into $outdev
 
e.person_id, e.encntr_id
 
from encounter e
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	and (e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime))
	and e.active_ind = 1
	and e.disch_dt_tm = null
 
order by e.person_id, e.encntr_id
 
 
Head report
	ppcnt = 0
Head e.person_id
	ppcnt += 1
	call alterlist(dispo->list, ppcnt)
	dispo->list[ppcnt].personid = e.person_id
	dispo->list[ppcnt].encntrid = e.encntr_id
 
with nocounter
 
;--------------------------------------------
;Flag previous disposition
select into $outdev
e.person_id, e.encntr_id, e.reg_dt_tm ';;q', etype = uar_get_code_display(e.encntr_type_cd)
, dispo = uar_get_code_display(e.disch_disposition_cd), disc_dt = datetimetrunc(e.disch_dt_tm, "dd") ';;q'
 
from (dummyt d with seq = size(dispo->list,5))
	,encounter e
 
plan d
 
join e where e.person_id = dispo->list[d.seq].personid
	and e.encntr_id != dispo->list[d.seq].encntrid
	and e.active_ind = 1
	and e.encntr_id = (select max(e1.encntr_id) from encounter e1
			 where e1.person_id = e.person_id and e.disch_dt_tm != null
			group by e1.person_id)
	;and e.disch_disposition_cd = 638675.00 ;Still a Patient 30
 
order by e.person_id, e.reg_dt_tm
 
;with nocounter, separator=" ", format
;go to exitscript
 
 
;======================================================================================================
;Influeze code values
select into $outdev
  cvg.parent_code_value, cv1.code_value, cv1.display
from
	code_value_group cvg
 	,code_value cv1
 	,code_value cv2
 
plan cv2 where cv2.code_set = 100496
	and cv2.active_ind = 1
 
join cvg where cvg.parent_code_value = cv2.code_value
	and cvg.parent_code_value = 3579001597.00 ;Flu
 
join cv1 where cv1.code_value = cvg.child_code_value
	 and cv1.code_set = 72
 
order by cv1.code_value
 
Head report
	infcnt = 0
Head cv1.code_value
	infcnt += 1
	call alterlist(flu->list, infcnt)
	flu->list[infcnt].flu_code_value = cv1.code_value
	flu->list[infcnt].flu_display = cv1.display
with nocounter
 
;-------------------------------------------------------------------------------------------------
;COVID-19 - Positive cases (Antigen or PCR)
 
select into $outdev
 
e.encntr_id, e.encntr_type_cd, e.loc_facility_cd, e.reg_dt_tm, ce.order_id, o.ordered_as_mnemonic
, c.container_id, event_dt = ce.event_end_dt_tm ';;q', c.drawn_dt_tm ';;q'
,event = uar_get_code_display(ce.event_cd), ce.result_val ,ce.event_title_text, ce.event_tag
,fac = if(e.loc_facility_cd = 2553765707.00)'FSR TCU' elseif(e.loc_facility_cd = 2553765371.00)'LCMC LTC' endif
 
from 	encounter e,
	orders o,
	order_container_r ocr,
	container c,
	clinical_event ce
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	;e.loc_facility_cd in(2553765707.00, 2553765371.00) ;FSR TCU, LCMC Nsg Home
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in(sars_rna_var, covid_report_var, covid_result_var, sars_cov2_var,sars_cov2_anti_var
				,pan_sars_var, covid_overall_var, covid_reflab_var)
				;,sars_cov2_naa1_var, sars_cov2_naa2 ; only for Ambulatory
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.order_id = ce.order_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.order_id, ce1.event_cd)
 
join o where o.encntr_id = ce.encntr_id
	and o.order_id = ce.order_id
	and o.active_ind = 1
 
join ocr where ocr.order_id = o.order_id
 
join c where c.container_id = ocr.container_id
	and (c.drawn_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1))
 
order by ce.encntr_id, ce.order_id, ce.event_end_dt_tm
 
Head report
	cnt = 0
Head ce.order_id
	cnt += 1
	call alterlist(pat->list, cnt)
	pat->pat_rec_cnt = cnt
	pat->list[cnt].facility = e.loc_facility_cd
	pat->list[cnt].reporting_facility_type = 'LTC-SKILLNURS'
	pat->list[cnt].reporting_facility_id =
		if(fac = 'FSR TCU') '68897'
		elseif(fac ='LCMC LTC') '60886'
		endif
	pat->list[cnt].reporting_facility_ccn =
		if(fac = 'FSR TCU') '445328'
		elseif(fac ='LCMC LTC') '445129'
		endif
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].personid = e.person_id
	pat->list[cnt].orderid = ce.order_id
	pat->list[cnt].reporting_dt = c.drawn_dt_tm
 
	case(ce.event_cd)
		of sars_cov2_var: ;PCR results
			pat->list[cnt].sars_cov_2_pcr_specimen_dt = c.drawn_dt_tm
			pat->list[cnt].sars_cov_2_pcr_event = uar_get_code_display(ce.event_cd)
			pat->list[cnt].sars_cov_2_pcr_result = trim(ce.result_val)
			pat->list[cnt].sars_cov_2_pcr_result_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
			pat->list[cnt].sars_cov_2_pcr_order_name = trim(o.ordered_as_mnemonic)
		      if(trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
				or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected')
				pat->list[cnt].sars_cov_2_pcr_positive = 'Yes'
		   	endif
		of sars_cov2_anti_var: ;Antigen results
			pat->list[cnt].sars_cov_2_antigen_specimen_dt = c.drawn_dt_tm
			pat->list[cnt].sars_cov_2_antigen_event = uar_get_code_display(ce.event_cd)
			pat->list[cnt].sars_cov_2_antigen_result = trim(ce.result_val)
			pat->list[cnt].sars_cov_2_antigen_result_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
			pat->list[cnt].sars_cov_2_antigen_order_name = trim(o.ordered_as_mnemonic)
		      if(trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
				or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected')
				pat->list[cnt].sars_cov_2_antigen_positive = 'Yes'
		   	endif
	endcase
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------
if(pat->pat_rec_cnt > 0)

;Positive COVID-19 - reinfected
select into $outdev
 
pat = pat->list[d.seq].pat_name, ce.person_id, ce.encntr_id, result = ce.result_val
,drawn_dt = format(c.drawn_dt_tm, 'mm-dd-yyyy ;;d')
,report_dt = format(pat->list[d.seq].reporting_dt, 'mm/dd/yy;;d')
,diff = datetimecmp(cnvtdatetime(pat->list[d.seq].reporting_dt), c.drawn_dt_tm)
 
from (dummyt d with seq = size(pat->list,5))
	,clinical_event ce
	,orders o
	,order_container_r ocr
	,container c
 
plan d
 
join ce where ce.person_id = pat->list[d.seq].personid
	and ce.event_cd in(sars_rna_var, covid_report_var, covid_result_var, sars_cov2_var,sars_cov2_anti_var
				,pan_sars_var, covid_overall_var, covid_reflab_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and(trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
		or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected')
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.person_id = ce.person_id
		and ce1.order_id = ce.order_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.order_id, ce1.event_cd)
 
join o where o.person_id = ce.person_id
	and o.order_id = ce.order_id
	and o.active_ind = 1
 
join ocr where ocr.order_id = o.order_id
 
join c where c.container_id = ocr.container_id
	and datetimecmp(cnvtdatetime(pat->list[d.seq].reporting_dt), c.drawn_dt_tm) >= 90 ;days
 
order by ce.person_id, ce.encntr_id
 
Head ce.person_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5) ,ce.person_id, pat->list[icnt].personid)
      if(idx > 0)
		pat->list[idx].reinfected = 'Yes'
		pat->list[idx].reinfected_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
	endif
 
with nocounter

endif 
;-------------------------------------------------------------------------------------------------------
;Influenza
 
select into $outdev
e.encntr_id, e.encntr_type_cd, e.loc_facility_cd, e.reg_dt_tm, event_dt = ce.event_end_dt_tm ';;q'
,event = uar_get_code_display(ce.event_cd), ce.result_val ,ce.event_title_text, ce.event_tag
,fac = if(e.loc_facility_cd = 2553765707.00)'FSR TCU' elseif(e.loc_facility_cd = 2553765371.00)'LCMC LTC' endif
 
from 	encounter e
	,clinical_event ce
	,(dummyt d5 with seq = size(flu->list,5))
 
plan  e where operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	;e.loc_facility_cd in(2553765707.00, 2553765371.00) ;FSR TCU, LCMC Nsg Home
	and e.active_ind = 1
 
join d5
 
join ce where ce.encntr_id = e.encntr_id
	and (ce.event_end_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1))
	and ce.event_cd = flu->list[d5.seq].flu_code_value
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_val = 'Positive'
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		and ce1.result_val = 'Positive'
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.person_id, ce.encntr_id
 
Head e.encntr_id
	flucnt = 0
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5) ,e.encntr_id, pat->list[icnt].encntrid)
      if(idx > 0)
      	pat->list[idx].influenza_positive = 'Yes'
		pat->list[idx].influenza_positive_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
	else
		cnt += 1
		pat->pat_rec_cnt = cnt
		call alterlist(pat->list, cnt)
		pat->list[cnt].facility = e.loc_facility_cd
		pat->list[cnt].encntrid = e.encntr_id
		pat->list[cnt].personid = e.person_id
		pat->list[cnt].influenza_positive = 'Yes'
		pat->list[idx].influenza_positive_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
	endif
 
with nocounter
 
 
;-------------------------------------------------------------------------------------------------------
;Get expired patients in acute location
select into $outdev
 
e.encntr_id, e.encntr_type_cd, e.loc_facility_cd, e.disch_disposition_cd
,p.person_id, p.deceased_cd, p.deceased_dt_tm, e.reg_dt_tm, e.disch_dt_tm
 
from encounter e
	, person p
 
plan e where parser(op_acute_facility_var)
	;where e.loc_facility_cd in(21250403.00, 2552503653.00) ;FSR, LCMC
	and e.disch_disposition_cd = 638666.00 ;*Expired 20
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
	and (p.deceased_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1)
		OR e.reg_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1)
		OR e.disch_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1))
	;and p.deceased_cd = 684729.00 ;Yes (comment out bcs sometimes patient level not flagged as deceased)
	and p.active_ind = 1
 
order by p.person_id
 
Head report
	pcnt = 0
Head p.person_id
	pcnt += 1
	expired->expired_rec_cnt = pcnt
	call alterlist(expired->list, pcnt)
	expired->list[pcnt].personid = p.person_id
	expired->list[pcnt].encntrid = e.encntr_id
	expired->list[pcnt].facility_cd = e.loc_facility_cd
	expired->list[pcnt].decease_cd = p.deceased_cd
	expired->list[pcnt].decease_dt = p.deceased_dt_tm
	expired->list[pcnt].disch_dispo_cd = e.disch_disposition_cd
	expired->list[pcnt].disch_dt = e.disch_dt_tm
	expired->list[pcnt].encntr_type = e.encntr_type_cd
	expired->list[pcnt].reg_dt = e.reg_dt_tm
 
with nocounter
 
;------------------------------------------
 
if(expired->expired_rec_cnt > 0)
 
select into $outdev
 e.encntr_id, e.person_id, reg_dt = expired->list[d.seq].reg_dt
 ,expired_dt = format(expired->list[d.seq].decease_dt, 'dd-mmm-yyyy hh:mm:ss;;d')
 
from (dummyt d with seq = value(size(expired->list, 5)))
	,encounter e
 
plan d
 
join e where e.person_id = expired->list[d.seq].personid
	and operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	and datetimecmp(e.disch_dt_tm, cnvtdatetime(expired->list[d.seq].reg_dt)) = 0
	;discharged from nursing home and admitted in acute shoud be the same day
 
order by e.person_id
 
Head e.person_id
	died_pat_cnt += 1
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5) ,e.person_id, pat->list[icnt].personid)
      if(idx > 0)
      	pat->list[idx].deceased_dt = expired->list[d.seq].decease_dt
      	pat->list[idx].disch_dt = expired->list[d.seq].disch_dt
		pat->list[idx].patient_status = trim(uar_get_code_display(expired->list[d.seq].disch_dispo_cd))
	else
		cnt += 1
		pat->pat_rec_cnt = cnt
		call alterlist(pat->list, cnt)
		pat->list[cnt].facility = e.loc_facility_cd
		pat->list[cnt].encntrid = e.encntr_id
		pat->list[cnt].personid = e.person_id
		pat->list[cnt].deceased_dt = expired->list[d.seq].decease_dt
		pat->list[cnt].disch_dt = expired->list[d.seq].disch_dt
		pat->list[cnt].patient_status = trim(uar_get_code_display(expired->list[d.seq].disch_dispo_cd))
	endif
 
with nocounter

endif 
;-------------------------------------------------------------------------------------------------------
;Get expired in Nursing home patients
select into $outdev
 
e.encntr_id, e.encntr_type_cd, e.loc_facility_cd, e.disch_disposition_cd
,p.person_id, p.deceased_cd, p.deceased_dt_tm, e.reg_dt_tm, e.disch_dt_tm
 
from encounter e
	, person p
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	;where e.loc_facility_cd in(2553765707.00, 2553765371.00) ;FSR TCU, LCMC Nsg Home
	and e.disch_disposition_cd = 638666.00 ;*Expired 20
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
	and (p.deceased_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1)
		OR e.reg_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1)
		OR e.disch_dt_tm between cnvtdatetime(start_date_var1) and cnvtdatetime(end_date_var1))
	;and p.deceased_cd = 684729.00 ;Yes (comment out bcs sometimes patient level not flagged as deceased)
	and p.active_ind = 1
 
order by p.person_id
 
Head p.person_id
	died_pat_cnt += 1
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5) ,p.person_id, pat->list[icnt].personid)
      if(idx > 0)
		pat->list[idx].deceased_dt = p.deceased_dt_tm
		pat->list[idx].disch_dt = e.disch_dt_tm
		pat->list[idx].patient_status = trim(uar_get_code_display(e.disch_disposition_cd))
	else
		cnt += 1
		pat->pat_rec_cnt = cnt
		call alterlist(pat->list, cnt)
		pat->list[cnt].facility = e.loc_facility_cd
		pat->list[cnt].encntrid = e.encntr_id
		pat->list[cnt].personid = p.person_id
		pat->list[cnt].deceased_dt = p.deceased_dt_tm
		pat->list[cnt].disch_dt = e.disch_dt_tm
		pat->list[cnt].patient_status = trim(uar_get_code_display(e.disch_disposition_cd))
	endif
 
with nocounter
 
if(pat->pat_rec_cnt > 0) 
;--------------------------------------------------------------------------------------------------
;Get demographic
select into 'nl:'
 
from encounter e
	,encntr_alias ea
	,person p
 
plan e where expand(num, 1, size(pat->list,5), e.encntr_id, pat->list[num].encntrid)
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head e.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5) ,e.encntr_id, pat->list[icnt].encntrid)
      while(idx > 0)
		pat->list[idx].fin = trim(ea.alias)
		pat->list[idx].pat_name = trim(p.name_full_formatted)
		idx = locateval(icnt ,idx+1 ,size(pat->list,5) ,e.encntr_id, pat->list[icnt].encntrid)
 	endwhile
with nocounter, expand = 1
 
;-------------------------------------------------------------------------------------------------------
;Set final totals
select into 'nl:'
 
fac = pat->list[d.seq].facility, ord = pat->list[d.seq].orderid
 
from (dummyt d with seq = size(pat->list,5))
 
plan d
 
order by fac, ord
 
Head report
	fcnt = 0
Head fac
	fcnt += 1
	ltc->fac_cnt = fcnt
	scnt = 1
	positive_cnt = 0, died_pat_cnt = 0, died_positive_c19_cnt = 0, num_pos_anti = 0, num_pos_pcr = 0,
	posanti_negpcr = 0, other_pos = 0, reinf_cnt = 0, flu_cnt = 0, flu_c19_cnt = 0, res_pcr_tst_cnt = 0,
	res_nonpcr_tst_cnt = 0
 
	call alterlist(ltc->flist, fcnt)
	ltc->flist[fcnt].cdc_facility_name = uar_get_code_display(fac)
	if(fac = 2553765707.00)
		ltc->flist[fcnt].staff_testing_facility_id = 21250403.00
	elseif(fac = 2553765371.00)		
		ltc->flist[fcnt].staff_testing_facility_id = 2552503653.00
	endif	
	call alterlist(ltc->flist[fcnt].list, scnt)
 
Head ord
 
	if(pat->list[d.seq].sars_cov_2_antigen_positive = 'Yes' OR pat->list[d.seq].sars_cov_2_pcr_positive = 'Yes')
		positive_cnt += 1
	endif
 
	if(pat->list[d.seq].patient_status != ' ' and (pat->list[d.seq].sars_cov_2_antigen_positive = 'Yes'
				OR pat->list[d.seq].sars_cov_2_pcr_positive = 'Yes'))
		died_positive_c19_cnt += 1
	endif
 
	if(pat->list[d.seq].patient_status != ' ')
		died_pat_cnt += 1
	endif
 
 	if(pat->list[d.seq].sars_cov_2_antigen_positive = 'Yes' and (pat->list[d.seq].sars_cov_2_pcr_positive = ' '
 			and pat->list[d.seq].sars_cov_2_pcr_result = ' '))
		num_pos_anti += 1
	endif
 
	if(pat->list[d.seq].sars_cov_2_pcr_positive = 'Yes' and (pat->list[d.seq].sars_cov_2_antigen_positive = ' '
			and pat->list[d.seq].sars_cov_2_antigen_result = ' '))
		num_pos_pcr += 1
	endif
 
 	if(pat->list[d.seq].sars_cov_2_antigen_positive = 'Yes' and (pat->list[d.seq].sars_cov_2_pcr_positive = ' '
	  and (pat->list[d.seq].sars_cov_2_pcr_result = 'Negative' OR pat->list[d.seq].sars_cov_2_pcr_result = 'Not Detected')))
 	  	if(pat->list[d.seq].sars_cov_2_pcr_specimen_dt != null)
	 		if(datetimediff(cnvtdatetime(pat->list[d.seq].sars_cov_2_pcr_specimen_dt),
		    		cnvtdatetime(pat->list[d.seq].sars_cov_2_antigen_specimen_dt),3) <= 48)
		    		posanti_negpcr += 1
			endif
	  	endif
	endif
 
 	if(pat->list[d.seq].sars_cov_2_antigen_positive = 'Yes' OR pat->list[d.seq].sars_cov_2_pcr_positive = 'Yes')
 		if(pat->list[d.seq].sars_cov_2_pcr_specimen_dt != null)
			if(datetimediff(cnvtdatetime(pat->list[d.seq].sars_cov_2_pcr_specimen_dt),
				cnvtdatetime(pat->list[d.seq].sars_cov_2_antigen_specimen_dt),3) <= 48)
	  			other_pos += 1
	  		endif
	  	endif
	endif
 
	if(pat->list[d.seq].reinfected = 'Yes')
		reinf_cnt += 1
	endif
 
 	if(pat->list[d.seq].influenza_positive = 'Yes')
		flu_cnt += 1
	endif
 
	if(pat->list[d.seq].sars_cov_2_antigen_positive = 'Yes' OR pat->list[d.seq].sars_cov_2_pcr_positive = 'Yes')
		if(pat->list[d.seq].influenza_positive = 'Yes')
			flu_c19_cnt += 1
		endif
	endif
 
	if(pat->list[d.seq].sars_cov_2_pcr_result != ' ')
		res_pcr_tst_cnt += 1
	endif
 
	if(pat->list[d.seq].sars_cov_2_antigen_result != ' ')
		res_nonpcr_tst_cnt += 1
	endif
 
Foot fac
 
	ltc->flist[fcnt].list[scnt].cdc_facility_id = substring(1,5, pat->list[d.seq].reporting_facility_id)
	ltc->flist[fcnt].list[scnt].cdc_facility_ccn = substring(1,5,pat->list[d.seq].reporting_facility_ccn)
	ltc->flist[fcnt].list[scnt].cdc_facility_type = substring(1,15,pat->list[d.seq].reporting_facility_type)
	ltc->flist[fcnt].list[scnt].collection_date = build2(start_date_var1,'- TO -', end_date_var1)
	ltc->flist[fcnt].list[scnt].numres_postest = positive_cnt
	ltc->flist[fcnt].list[scnt].numres_postestposag = num_pos_anti
	ltc->flist[fcnt].list[scnt].numres_postestposnaat = num_pos_pcr
	ltc->flist[fcnt].list[scnt].numres_postestposagnegnaat = posanti_negpcr
	ltc->flist[fcnt].list[scnt].numres_postestother = other_pos
	ltc->flist[fcnt].list[scnt].numres_postestreinf = reinf_cnt
	ltc->flist[fcnt].list[scnt].numres_confflu = flu_cnt
	ltc->flist[fcnt].list[scnt].numres_conffluc19 = flu_c19_cnt
	ltc->flist[fcnt].list[scnt].res_c19poctestperf = res_pcr_tst_cnt
	ltc->flist[fcnt].list[scnt].res_c19nonpoctestperf = res_nonpcr_tst_cnt
	ltc->flist[fcnt].list[scnt].numres_died = died_pat_cnt
	ltc->flist[fcnt].list[scnt].numres_c19died = died_positive_c19_cnt
 
with nocounter

endif 
;--------------- admitted / re-admitted ------------------------------------------------------------------

;Admitted/readmitted with c19 by disgnosis
 
select into $outdev
 
e.person_id, e.encntr_id, e.reg_dt_tm ';;q', location = uar_get_code_display(e.loc_facility_cd)
, e.encntr_type_cd, ce.order_id, event_dt = ce.event_end_dt_tm ';;q'
,event = uar_get_code_display(ce.event_cd), ce.result_val ,ce.event_title_text, ce.event_tag
,fac = if(e.loc_facility_cd = 2553765707.00)'FSR TCU' elseif(e.loc_facility_cd = 2553765371.00)'LCMC Nsg Home' endif
 
from
	encounter e
	,person p
	,clinical_event ce
	,encntr_alias ea
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	and (e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime))
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in(sars_rna_var, covid_report_var, covid_result_var, sars_cov2_var,sars_cov2_anti_var
			,pan_sars_var, covid_overall_var, covid_reflab_var, cov2_past_rslt_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and(trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
		or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected')
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.person_id = ce.person_id
		and ce1.order_id = ce.order_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.person_id, ce1.order_id, ce1.event_cd)
 
order by fac, e.person_id, ce.order_id
 
Head report
	ocnt = 0
Head ce.order_id
	if(datetimetrunc(e.reg_dt_tm, "dd") = datetimetrunc(ce.event_end_dt_tm, "dd"))
		ocnt += 1
		admitc19->admitc19_rec_cnt = ocnt
		call alterlist(admitc19->list, ocnt)
		call echo(build2('ocnt = ', ocnt, '--- ',ce.order_id,'--- ', fac))
		admitc19->list[ocnt].facility = fac
		admitc19->list[ocnt].fin = ea.alias
		admitc19->list[ocnt].encntrid = e.encntr_id
		admitc19->list[ocnt].personid = e.person_id
		admitc19->list[ocnt].orderid = ce.order_id
		admitc19->list[ocnt].pat_name = p.name_full_formatted
		admitc19->list[ocnt].reg_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
		admitc19->list[ocnt].covid_test = uar_get_code_display(ce.event_cd)
		admitc19->list[ocnt].covid_result = trim(ce.result_val)
		admitc19->list[ocnt].covid_result_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
	endif
with nocounter

;----------------------------------------------------------------------------------------------------
 
;Admitted/readmitted with previous diagnosis of c19 admission form response
 
select into $outdev
 
e.person_id, e.encntr_id, e.reg_dt_tm ';;q', location = uar_get_code_display(e.loc_facility_cd)
, e.encntr_type_cd, ce.order_id, event_dt = ce.event_end_dt_tm ';;q'
,event = uar_get_code_display(ce.event_cd), ce.result_val ,ce.event_title_text, ce.event_tag
,fac = if(e.loc_facility_cd = 2553765707.00)'FSR TCU' elseif(e.loc_facility_cd = 2553765371.00)'LCMC Nsg Home' endif
 
from
	encounter e
	,person p
	,clinical_event ce
	,encntr_alias ea
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var1, $ltc_facility)
	and (e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime))
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in(cov2_isolation_var, cov2_isolation_var1)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and (trim(ce.result_val) = 'Enhanced Droplet' OR trim(ce.result_val) = 'Enhanced Droplet Precautions')
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.person_id = ce.person_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.order_id, ce1.event_cd)
 
order by fac, e.encntr_id, ce.order_id
 
Head ce.order_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(admitc19->list,5) ,ce.order_id, admitc19->list[icnt].orderid)
Detail
	if(idx = 0)
	  if(datetimetrunc(e.reg_dt_tm, "dd") = datetimetrunc(ce.event_end_dt_tm, "dd"))
		ocnt += 1
		admitc19->admitc19_rec_cnt += ocnt
		call alterlist(admitc19->list, ocnt)
		call echo(build2('ocnt2  = ', ocnt, '--- ',ce.order_id,'--- ', fac))
		admitc19->list[ocnt].facility = fac
		admitc19->list[ocnt].fin = ea.alias
		admitc19->list[ocnt].encntrid = e.encntr_id
		admitc19->list[ocnt].personid = e.person_id
		admitc19->list[ocnt].orderid = ce.order_id
		admitc19->list[ocnt].pat_name = p.name_full_formatted
		admitc19->list[ocnt].reg_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
		admitc19->list[ocnt].isolation_type = event
		admitc19->list[ocnt].isolation_reason = ce.result_val
		admitc19->list[ocnt].isolation_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;d')
	  endif	
	endif
with nocounter
 
if(admitc19->admitc19_rec_cnt > 0) 
;----------------------------------------------------------------------------------------------------
;Update the admit count to LTC rs
 
select into $outdev
 
fac = trim(substring(1,30, admitc19->list[d.seq].facility)), per_id = admitc19->list[d.seq].personid
 
from (dummyt d with seq = size(admitc19->list,5))
 
plan d
 
order by fac, per_id
 
Head fac
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(ltc->flist,5) ,fac ,ltc->flist[icnt].cdc_facility_name)
	lcnt = 1
	pcnt = 0
Head per_id
	pcnt += 1
Foot fac
	call echo(build2('fac = ', fac, '---   pcnt = ', pcnt))
      if(idx > 0)
		ltc->flist[idx].list[lcnt].numres_admc19 = pcnt
 	endif
 
with nocounter

endif 

;*********************************************************************************************************
;Get Staff count
;Loop through all facilities.
 
For(fcnt = 1 to ltc->fac_cnt)
	execute cov_phq_ltc_staff_covid 'NL:', $start_datetime, $end_datetime, value(ltc->flist[fcnt].staff_testing_facility_id), 2
	set ltc->flist[fcnt].list[1].staff_c19poctestperf = tot->flist[1].num_staff_tested
endfor
 
;*********************************************************************************************************
  
call echorecord(ltc)
call echorecord(pat)
 
;------------------------------------------------------------------------------------------------
if(ltc->fac_cnt > 0)
 
;Final output
if($repo_type = 1);Summary
 
select into $outdev
	facility_name = substring(1, 50, ltc->flist[d1.seq].cdc_facility_name)
	,nhsn_facility_id = substring(1,5, ltc->flist[d1.seq].list[d2.seq].cdc_facility_id)
	,nhsn_ccn_number = substring(1,6, ltc->flist[d1.seq].list[d2.seq].cdc_facility_ccn)
	,facility_type = substring(1, 50,ltc->flist[d1.seq].list[d2.seq].cdc_facility_type)
	,collection_date = substring(1, 50, ltc->flist[d1.seq].list[d2.seq].collection_date)
	,numresadmc19 = ltc->flist[d1.seq].list[d2.seq].numres_admc19
	,numresdied = ltc->flist[d1.seq].list[d2.seq].numres_died
	,numresc19died = ltc->flist[d1.seq].list[d2.seq].numres_c19died
	,numltcfbeds = ' '
	,numltcfbedsocc = ' '
	,resc19testability = 'Yes'
	,staffc19testability = 'Yes'
	,staffc19poctestperf = ltc->flist[d1.seq].list[d2.seq].staff_c19poctestperf
	,numrespostest = ltc->flist[d1.seq].list[d2.seq].numres_postest
	,numrespostestposag = ltc->flist[d1.seq].list[d2.seq].numres_postestposag
	,numrespostestposnaat = ltc->flist[d1.seq].list[d2.seq].numres_postestposnaat
	,numrespostestposagnegnaat = ltc->flist[d1.seq].list[d2.seq].numres_postestposagnegnaat
	,numrespostestother = ltc->flist[d1.seq].list[d2.seq].numres_postestother
	,numrespostestreinf = ltc->flist[d1.seq].list[d2.seq].numres_postestreinf
	,numrespostestreinfsymp = ' '
	,numrespostestreinfasymp = ' '
	,numresconfflu = ltc->flist[d1.seq].list[d2.seq].numres_confflu
	,numresothresp = ' '
	,numresconffluc19 = ltc->flist[d1.seq].list[d2.seq].numres_conffluc19
	,perfc19test = 'Y'
	,resc19poctestperf = ltc->flist[d1.seq].list[d2.seq].res_c19poctestperf
	,resc19nonpoctestperf = ltc->flist[d1.seq].list[d2.seq].res_c19nonpoctestperf
	,staffc19nonpoctestperf = ' '
	,c19nonpoctestresults = '1 to 2 Days'
 
from
	(dummyt   d1  with seq = size(ltc->flist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(ltc->flist[d1.seq].list, 5))
join d2
 
order by facility_name
 
with nocounter, separator=" ", format
 
elseif($repo_type = 2) ;Detailed
 
select into $outdev
	facility = trim(uar_get_code_display(pat->list[d1.seq].facility))
	, fin = substring(1, 10, pat->list[d1.seq].fin)
	, patient_name = substring(1, 50, pat->list[d1.seq].pat_name)
	, lab_order_antigen = substring(1, 100, pat->list[d1.seq].sars_cov_2_antigen_order_name)
	, sars_cov2_antigen_result = substring(1, 50, pat->list[d1.seq].sars_cov_2_antigen_result)
	, sars_cov2_antigen_result_dt = substring(1, 20, pat->list[d1.seq].sars_cov_2_antigen_result_dt)
	, lab_order_pcr = substring(1, 100, pat->list[d1.seq].sars_cov_2_pcr_order_name)
	, sars_cov2_pcr_result = substring(1, 50, pat->list[d1.seq].sars_cov_2_pcr_result)
	, sars_cov2_pcr_result_dt = substring(1, 20, pat->list[d1.seq].sars_cov_2_pcr_result_dt)
	, c19_reinfected = substring(1, 10, pat->list[d1.seq].reinfected)
	, c19_reinfected_dt = substring(1, 30, pat->list[d1.seq].reinfected_dt)
	, Influenza = substring(1, 30, pat->list[d1.seq].influenza_positive)
	, Influenza_dt = substring(1, 30, pat->list[d1.seq].influenza_positive_dt)
	, patient_status = substring(1, 30, pat->list[d1.seq].patient_status)
	, deceased_dt = format(pat->list[d1.seq].deceased_dt, "mm-dd-yyyy hh:mm:ss;;d")
	, discharged_dt = format(pat->list[d1.seq].disch_dt, "mm-dd-yyyy hh:mm:ss;;d")
 
FROM
	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1
 
order by facility, fin
 
with nocounter, separator=" ", format
 
elseif($repo_type = 3) ;Detailed - Amitted/readmitted
 
select into $outdev
	facility = substring(1, 30, admitc19->list[d1.seq].facility)
	, fin = substring(1, 30, admitc19->list[d1.seq].fin)
	, pat_name = substring(1, 50, admitc19->list[d1.seq].pat_name)
	, reg_dt = substring(1, 30, admitc19->list[d1.seq].reg_dt)
	, covid19_test = substring(1, 30, admitc19->list[d1.seq].covid_test)
	, covid19_result = substring(1, 30, admitc19->list[d1.seq].covid_result)
	, covid19_result_dt = substring(1, 30, admitc19->list[d1.seq].covid_result_dt)
	, isolation = substring(1, 50, admitc19->list[d1.seq].isolation_type)
	, isolation_reason = substring(1, 50, admitc19->list[d1.seq].isolation_reason)
	, isolation_dt = substring(1, 30, admitc19->list[d1.seq].isolation_dt)
	, personid = admitc19->list[d1.seq].personid
	, encntrid = admitc19->list[d1.seq].encntrid
 
from
	(dummyt   d1  with seq = size(admitc19->list, 5))
 
plan d1
 
order by facility, pat_name, admitc19->list[d1.seq].orderid
 
with nocounter, separator=" ", format
 
 
endif ;repo_type

endif ;fac_cnt
 
#exitscript
 
end go
 
 
 

 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May'2020
	Solution:			Quality
	Source file name:		cov_phq_LTC_expired_covid19.prg
	Object name:		cov_phq_LTC_expired_covid19
 	Request#:			7745
	Program purpose:		COVID-19 data submission to NHSN/CMS
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  Mod Nbr	Mod Date	Developer			Comment
------------------------------------------------------------------------------
 
01/31/22    Geetha Paramasivam  CR#12100  Covid test name change update
 
 
******************************************************************************/
 
drop program cov_phq_ltc_expired_covid19:dba go
create program cov_phq_ltc_expired_covid19:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 2
	, "Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, repo_type, ltc_facility
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_date_var = vc
declare end_date_var   = vc
declare start_date = f8
declare end_date   = f8
 
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
declare sars_rna_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS CoV2 RNA, RT PCR')), protect
declare covid_report_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 See Report')), protect
declare covid_result_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Result')), protect
declare sars_cov2_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2')), protect
declare sars_cov2_anti_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2 Antigen')), protect
declare pan_sars_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PAN-SARS RNA')), protect
declare covid_overall_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Overall Result')), protect
declare covid_reflab_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Reference Lab')), protect
 
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
declare op_ltc_facility_var = vc with noconstant("")
 
declare fsr_tcu_var    = f8 with constant(2553765707.00)
declare lcmc_nsg_var   = f8 with constant(2553765371.00)
declare fsr_acute_var  = f8 with constant(21250403.00)
declare lcmc_acute_var = f8 with constant(2552503653.00)
 
;---------------------------------------------------------------------------------------------------------
;Set default date for DA2 schedule
set start_date = cnvtlookbehind("7,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("7,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)
 
;call echo(build('start_date = ',format(cnvtdatetime(start_date), 'dd-mmm-yyyy hh:mm:ss;;d'), '-- end_date = ',
;		format(cnvtdatetime(end_date), 'dd-mmm-yyyy hh:mm:ss;;d')))
 
if($start_datetime = "THURSDAY")
	set start_date_var = format(cnvtdatetime(start_date), 'dd-mmm-yyyy hh:mm:ss;;d')
 	set end_date_var = format(cnvtdatetime(end_date), 'dd-mmm-yyyy hh:mm:ss;;d')
else
	set start_date_var = $start_datetime
 	set end_date_var = $end_datetime
endif
 
call echo(build('start_date_var = ', start_date_var, '--- end_date_var = ',end_date_var))
 
;---------------------------------------------------------------------------------------------------------
 
;Set LTC Facility variable Operator
if(substring(1,1,reflect(parameter(parameter2($ltc_facility),0))) = "l");multiple values were selected
	set op_ltc_facility_var = "in"
else								;a single value was selected
	set op_ltc_facility_var = "="
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
	1 flist[*]
		2 facility = vc
		2 list[*]
			3 collection_date = vc
			3 numres_admc19 = i4
			3 numres_confc19 = i4
			3 numres_suspc19 = i4
			3 numres_died = i4
			3 numres_c19died = i4
			3 num_ltcf_beds = i4
			3 num_ltcf_beds_occ = i4
			3 c19testing = vc
			3 c19testing_state_hdlab = vc
			3 c19testing_private_lab = vc
			3 c19testing_other_lab = vc
	)
 
;------------- Helpers -----------------------------------------
 
Record c_sets(
	1 custom_code_set = f8
	1 order_codes[*]
		2 code_val = f8
		2 display = vc
	1 event_codes[*]
		2 code_val = f8
		2 display = vc
	1 positive_covid_codes[*]
		2 code_val = f8
		2 display = vc
)
 
Record pat(
	1 lab_ord_rec_cnt = i4
	1 list[*]
		2 facility = f8
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_name = vc
		2 disch_dt = dq8
		2 lab_order_dt = dq8
		2 lab_order_name = vc
		2 result_dt = dq8
		2 result_event = vc
		2 result_response = vc
		2 covid_positive = vc
		2 patient_status = vc
		2 deceased_dt = dq8
)
 
Record expired(
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
 
;----------------------------------------------------------------------------------------------------
;Assign code values
 
;Custom Code set
select into 'nl:'
from code_value_set cvs
plan cvs where cvs.definition = "COVCUSTOM"
order by cvs.display
 
Head report
	call echo(build2('Get custom code set....'))
Head cvs.display
	c_sets->custom_code_set = cvs.code_set
with nocounter
 
;----------------------------------------
;Orders
select into $outdev
 
cv1.description, cv2.code_value, catalog = uar_get_code_display(oc.catalog_cd)
 
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,order_catalog oc
 
plan cv1 where cv1.code_set = c_sets->custom_code_set
	and cv1.active_ind = 1
	and cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and cv1.cdf_meaning = "ORDERS"
	and cv1.description = 'COVID19'
 
join cvg where cvg.parent_code_value = cv1.code_value
	and cvg.code_set = 200
 
join cv2 where cv2.code_value = cvg.child_code_value
	and cv2.active_ind = 1
 
join oc where oc.catalog_cd = cv2.code_value
	and oc.active_ind	= 1
 
order by cv2.code_value
 
Head cv2.code_value
	ocnt += 1
	call alterlist(c_sets->order_codes, ocnt)
	c_sets->order_codes[ocnt].code_val = cv2.code_value
	c_sets->order_codes[ocnt].display = cv2.display
 
with nocounter
 
;----------------------------------------
;Event Codes
select into $outdev
 
cv1.description, cv2.code_value, cv2.display
 
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
 
plan cv1 where cv1.code_set = c_sets->custom_code_set
	and cv1.active_ind = 1
	and cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and cv1.cdf_meaning = "EVENT_CODE"
	and cv1.description = 'COVID19'
 
join cvg where cvg.parent_code_value = cv1.code_value
	and cvg.code_set = 72
 
join cv2 where cv2.code_value = cvg.child_code_value
	and cv2.active_ind = 1
 
order by cv2.code_value
 
Head cv2.code_value
	ecnt += 1
	call alterlist(c_sets->event_codes, ecnt)
	c_sets->event_codes[ecnt].code_val = cv2.code_value
	c_sets->event_codes[ecnt].display = cv2.display
 
with nocounter
 
;----------------------------------------
;Positive Response Qualifier
 
select into $outdev
from code_value cv1
 
plan cv1 where cv1.code_set = c_sets->custom_code_set
	and cv1.active_ind = 1
	and cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and cv1.cdf_meaning = "RESPONSE"
order by cv1.code_value
 
Head cv1.code_value
	rcnt += 1
	call alterlist(c_sets->positive_covid_codes, rcnt)
	c_sets->positive_covid_codes[rcnt].code_val = cv1.code_value
	c_sets->positive_covid_codes[rcnt].display = cv1.display
 
with nocounter
 
;call echorecord(c_sets)
 
;======================================================================================================
;Get patients population - Lab ordered
select into $outdev
 
 e.encntr_id, e.encntr_type_cd, e.loc_facility_cd, e.reg_dt_tm, o.order_mnemonic, o.order_id
 , o.orig_order_dt_tm, o.order_status_cd
 
from 	encounter e
	,orders o
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var, $ltc_facility)
	;e.loc_facility_cd in(2553765707.00, 2553765371.00) ;FSR TCU, LCMC Nsg Home
	and e.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.orig_order_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var)
	and o.catalog_cd in(covid_ref_lab_var, covid_mpl_ref_lab_var, covid_in_house_var, covid_pcr_confirm_var
		, covid_respiratory_var,covid_ref_mayo_var, covid_SARS_var, covid_CDC_var
		, covid_repid_resp_var, covid_repid_anti_var)
	and o.active_ind = 1
	and o.order_status_cd in(2543.00, 2546.00, 2548.00, 2550.00);Completed, Future, InProcess, Ordered
 
order by e.loc_facility_cd, e.encntr_id, o.orig_order_dt_tm
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	call alterlist(pat->list, cnt)
	pat->lab_ord_rec_cnt = cnt
	pat->list[cnt].facility = e.loc_facility_cd
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].personid = e.person_id
	pat->list[cnt].lab_order_dt = o.orig_order_dt_tm
	pat->list[cnt].lab_order_name = trim(o.order_mnemonic)
 
with nocounter
 
;------------------------------------------------------------------------------------------
;Get Confirmed COVID-19 - Positive cases
 
select into $outdev
ce.encntr_id, ce.event_cd, ce.result_val, ce.event_end_dt_tm ,ce.event_title_text, ce.event_tag
 
from clinical_event ce
 
plan ce where expand(num, 1, pat->lab_ord_rec_cnt, ce.encntr_id, pat->list[num].encntrid)
	and ce.event_cd in(sars_rna_var,covid_report_var,covid_result_var,sars_cov2_var, sars_cov2_anti_var
			,pan_sars_var, covid_overall_var,covid_reflab_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.order_id = ce.order_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.order_id, ce1.event_cd)
 
order by ce.encntr_id, ce.order_id, ce.event_end_dt_tm
 
Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->lab_ord_rec_cnt ,ce.encntr_id ,pat->list[icnt].encntrid)
	pat->list[idx].result_dt = ce.event_end_dt_tm
	pat->list[idx].result_event = trim(uar_get_code_display(ce.event_cd))
	pat->list[idx].result_response = trim(ce.result_val)
	if(trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
		or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected')
			pat->list[idx].covid_positive = 'Y'
	endif
 
with nocounter, expand = 1
 
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
	and (p.deceased_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var)
		OR e.reg_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var)
		OR e.disch_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var))
	;and p.deceased_cd = 684729.00 ;Yes (comment out bcs sometimes patient level not flagged as deceased)
	and p.active_ind = 1
 
order by p.person_id
 
Head report
	pcnt = 0
Head p.person_id
	pcnt += 1
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
 
call echorecord(expired)
 
;------------------------------------------
 
select into $outdev
 e.encntr_id, e.person_id, reg_dt = expired->list[d.seq].reg_dt
 ,expired_dt = format(expired->list[d.seq].decease_dt, 'dd-mmm-yyyy hh:mm:ss;;d')
 
from (dummyt d with seq = value(size(expired->list, 5)))
	,encounter e
 
plan d
 
join e where e.person_id = expired->list[d.seq].personid
	and operator(e.loc_facility_cd, op_ltc_facility_var, $ltc_facility)
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
		call alterlist(pat->list, cnt)
		pat->list[cnt].facility = e.loc_facility_cd
		pat->list[cnt].encntrid = e.encntr_id
		pat->list[cnt].personid = e.person_id
		pat->list[cnt].deceased_dt = expired->list[d.seq].decease_dt
		pat->list[cnt].disch_dt = expired->list[d.seq].disch_dt
		pat->list[cnt].patient_status = trim(uar_get_code_display(expired->list[d.seq].disch_dispo_cd))
	endif
 
with nocounter
 
call echorecord(pat)
 
;-------------------------------------------------------------------------------------------------------
;Get expired in Nursing home patients
select into $outdev
 
e.encntr_id, e.encntr_type_cd, e.loc_facility_cd, e.disch_disposition_cd
,p.person_id, p.deceased_cd, p.deceased_dt_tm, e.reg_dt_tm, e.disch_dt_tm
 
from encounter e
	, person p
 
plan e where operator(e.loc_facility_cd, op_ltc_facility_var, $ltc_facility)
	;where e.loc_facility_cd in(2553765707.00, 2553765371.00) ;FSR TCU, LCMC Nsg Home
	and e.disch_disposition_cd = 638666.00 ;*Expired 20
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
	and (p.deceased_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var)
		OR e.reg_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var)
		OR e.disch_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var))
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
		call alterlist(pat->list, cnt)
		pat->list[cnt].facility = e.loc_facility_cd
		pat->list[cnt].encntrid = e.encntr_id
		pat->list[cnt].personid = p.person_id
		pat->list[cnt].deceased_dt = p.deceased_dt_tm
		pat->list[cnt].disch_dt = e.disch_dt_tm
		pat->list[cnt].patient_status = trim(uar_get_code_display(e.disch_disposition_cd))
	endif
 
with nocounter
 
call echorecord(pat)
 
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
 
order by p.person_id
 
Head e.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(pat->list,5) ,e.encntr_id, pat->list[icnt].encntrid)
	pat->list[idx].fin = trim(ea.alias)
	pat->list[idx].pat_name = trim(p.name_full_formatted)
 
with nocounter, expand = 1
 
;-------------------------------------------------------------------------------------------------------
 
;set LTC record set
select into 'nl:'
 
fac = pat->list[d.seq].facility, fin = pat->list[d.seq].fin
 
from (dummyt d with seq = size(pat->list,5))
 
plan d
 
order by fac, fin
 
Head report
	fcnt = 0
Head fac
	fcnt += 1
	scnt = 1
	positive_cnt = 0, died_pat_cnt = 0, died_positive_c19_cnt = 0, lab_ord_cnt = 0
 
	call alterlist(ltc->flist, fcnt)
	ltc->flist[fcnt].facility = uar_get_code_display(fac)
	call alterlist(ltc->flist[fcnt].list, scnt)
 
Head fin
 
	if(pat->list[d.seq].covid_positive = 'Y')
		positive_cnt += 1
	endif
 
	if(pat->list[d.seq].patient_status != ' ' and pat->list[d.seq].covid_positive = 'Y')
		died_positive_c19_cnt += 1
	endif
 
	if(pat->list[d.seq].patient_status != ' ')
		died_pat_cnt += 1
	endif
 
	if(pat->list[d.seq].lab_order_name != ' ')
		lab_ord_cnt += 1
	endif
 
Foot fac
	ltc->flist[fcnt].list[scnt].collection_date = build2(start_date_var,'- TO -', end_date_var)
	;ltc->flist[fcnt].list[scnt].collection_date = build2(format(cnvtdatetime($start_datetime),'mm/dd/yy;;d')
	;		,'- TO -', format(cnvtdatetime($end_datetime),'mm/dd/yy;;d'))
	ltc->flist[fcnt].list[scnt].numres_suspc19 = lab_ord_cnt
	ltc->flist[fcnt].list[scnt].numres_confc19 = positive_cnt
	ltc->flist[fcnt].list[scnt].numres_died = died_pat_cnt
	ltc->flist[fcnt].list[scnt].numres_c19died = died_positive_c19_cnt
 
with nocounter
 
call echorecord(ltc)
call echorecord(pat)
 
;------------------------------------------------------------------------------------------------
 
;Final output
if($repo_type = 1);Summary
 
select into $outdev
	facility = substring(1, 50, ltc->flist[d1.seq].facility)
	,collection_date = substring(1, 50, ltc->flist[d1.seq].list[d2.seq].collection_date)
	,numresadmc19 = ltc->flist[d1.seq].list[d2.seq].numres_admc19
	,numresconfc19 = ltc->flist[d1.seq].list[d2.seq].numres_confc19
	,numressuspc19 = ltc->flist[d1.seq].list[d2.seq].numres_suspc19
	,numresdied = ltc->flist[d1.seq].list[d2.seq].numres_died
	,numresc19died = ltc->flist[d1.seq].list[d2.seq].numres_c19died
	,numltcfbeds = ltc->flist[d1.seq].list[d2.seq].num_ltcf_beds
	,numltcfbedsocc = ltc->flist[d1.seq].list[d2.seq].num_ltcf_beds_occ
	,c19testing = 'Yes' ;ltc->flist[d1.seq].list[d2.seq].c19testing
	,c19testingstatehdlab = 'Yes' ;ltc->flist[d1.seq].list[d2.seq].c19testing_state_hdlab
	,c19testingprivatelab = 'Yes' ;ltc->flist[d1.seq].list[d2.seq].c19testing_private_lab
	,c19testingotherlab = 'Hospital Lab' ;ltc->flist[d1.seq].list[d2.seq].c19testing_other_lab
 
from
	(dummyt   d1  with seq = size(ltc->flist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(ltc->flist[d1.seq].list, 5))
join d2
 
order by facility
 
with nocounter, separator=" ", format
 
 
elseif($repo_type = 2) ;Detailed
 
select into $outdev
	facility = trim(uar_get_code_display(pat->list[d1.seq].facility))
	, fin = substring(1, 10, pat->list[d1.seq].fin)
	, patient_name = substring(1, 50, pat->list[d1.seq].pat_name)
	, lab_order_dt = format(pat->list[d1.seq].lab_order_dt,"mm-dd-yyyy hh:mm:ss;;d")
	, lab_order_name = substring(1, 100, pat->list[d1.seq].lab_order_name)
	, result_dt = format(pat->list[d1.seq].result_dt, "mm-dd-yyyy hh:mm:ss;;d")
	, result_name = substring(1, 100, pat->list[d1.seq].result_event)
	, result_response = substring(1, 30, pat->list[d1.seq].result_response)
	, covid_positive = substring(1, 30, pat->list[d1.seq].covid_positive)
	, patient_status = substring(1, 30, pat->list[d1.seq].patient_status)
	, deceased_dt = format(pat->list[d1.seq].deceased_dt, "mm-dd-yyyy hh:mm:ss;;d")
	, discharged_dt = format(pat->list[d1.seq].disch_dt, "mm-dd-yyyy hh:mm:ss;;d")
 
FROM
	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1
 
order by facility,lab_order_dt, fin
 
with nocounter, separator=" ", format
 
endif
 
#exitscript
 
end go


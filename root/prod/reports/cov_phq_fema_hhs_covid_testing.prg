/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May'2020
	Solution:			Quality/COVID-19
	Source file name:	      cov_phq_fema_hhs_covid_testing.prg
	Object name:		cov_phq_fema_hhs_covid_testing
	Request#:			7554
	Program purpose:		FEMA and HHS COVID-19 Test Result Reporting Form
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/

*** As per meeting(5/5/20) with Lori: we may only need In-House Testing 



drop program cov_phq_fema_hhs_covid_testing:dba go
create program cov_phq_fema_hhs_covid_testing:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0 

with OUTDEV, acute_facility_list

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare covid_ref_lab_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 Reference Lab')), protect
declare covid_in_house_var    = f8 with constant(uar_get_code_by("DISPLAY", 200, 'COVID19 In-House')), protect
 
;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("1,D")
set start_date = datetimefind(start_date,"D","B","B")
set end_date   = cnvtlookahead("1,D",start_date)
set end_date   = cnvtlookbehind("1,SEC", end_date)

call echo(build('start dt = ', format(start_date,";;q")))
call echo(build('end dt = ', format(end_date,";;q")))

declare new_diagnostic_var = i4 with noconstant(0) 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

Record fema(
	1 list[*]
		2 facility = vc
		2 date_reporting = vc
		2 new_diagnostic = i4
		2 cumulat_diagnostic = i4
		2 new_test_resulted = i4
		2 cumulat_test_resulted = i4
		2 new_positive_covid = i4
		2 cumulat_positive_covid = i4
		2 new_negative_covid = i4
		2 cumulat_negative_covid = i4
)		

;------------------------ HELPER ----------------------------------------------------------------- 

Record resulted(
	1 resultd_upto_date = i8
	1 cumulative_positive = i8
	1 cumulative_negative = i8
	1 list[*]
		2 facility = vc
		2 encntrid = f8
		2 orderid = f8
		2 order_mnemonic = vc
		2 result_event = vc
		2 result_event_cd = f8
		2 ce_result_value = vc
		2 event_end_dt = dq8
		2 result_meaning = vc
)


;-------------------------------------------------------------------------------------------------- 
; 1) New Diagnostic tests ordered (midnight to midnight)
;COVID_19 - test ordered - Previous day

select into 'nl:'
 
e.encntr_id, o.order_id, o.order_mnemonic, status = uar_get_code_display(o.order_status_cd)
, o.orig_order_dt_tm "@SHORTDATETIME", e.loc_facility_cd, e.location_cd, loc = uar_get_code_description(e.location_cd)
 
from  orders o
	,encounter e
 
plan o where o.orig_order_dt_tm between cnvtdatetime(start_date) and cnvtdatetime(end_date)
	and o.catalog_cd in(covid_ref_lab_var, covid_in_house_var)
	and o.order_status_cd in(2543.00, 2546.00, 2548.00, 2550.00);Completed, Future, InProcess, Ordered			
	and o.active_ind = 1
 
join e where e.encntr_id = o.encntr_id
	and e.person_id = o.person_id
	and e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
 
with nocounter, separator=" ", format


;-------------------------------------------------------------------------------------------------- 
; 2) Cumulative Diagnostics Tests Ordered  (All tests ordered to date)
;COVID_19 - test ordered - upto date

select into 'nl:'
 
e.encntr_id, o.order_mnemonic, status = uar_get_code_display(o.order_status_cd)
, o.orig_order_dt_tm "@SHORTDATETIME", facility = uar_get_code_display(e.loc_facility_cd), o.order_id
 
from  orders o
	,encounter e
 
plan o where o.orig_order_dt_tm <= cnvtdatetime(end_date)
	and o.catalog_cd in(covid_ref_lab_var, covid_in_house_var)
	and o.order_status_cd in(2543.00, 2546.00, 2548.00, 2550.00);Completed, Future, InProcess, Ordered			
 	and o.active_ind = 1
 	
join e where e.encntr_id = o.encntr_id
	and e.person_id = o.person_id
	and e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
 
with nocounter, separator=" ", format

;---------------------------------------------------------------------------------------------------------------
;4)Cummulative Tests performed (All tests with results released to date)
;COVID_19 - test resulted - upto date

select into $outdev
 
facility = uar_get_code_display(e.loc_facility_cd),e.encntr_id, o.order_mnemonic
, status = uar_get_code_display(o.order_status_cd), o.orig_order_dt_tm "@SHORTDATETIME", o.order_id
, event = uar_get_code_display(ce.event_cd), ce.event_cd, ce.result_val, ce.event_end_dt_tm "@SHORTDATETIME"
,ce.event_title_text, ce.event_tag
 
from  orders o
	,encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1

join o where o.encntr_id = e.encntr_id
	and o.catalog_cd in(covid_ref_lab_var, covid_in_house_var)
	and o.active_ind = 1
	
join ce where ce.order_id = o.order_id
	and ce.encntr_id = o.encntr_id
	and ce.event_cd = 3358526621.00 ;SARS-CoV-2
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.order_id = ce.order_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.order_id, ce1.event_cd)

order by ce.encntr_id, ce.order_id, ce.event_end_dt_tm	

Head report
	cnt = 0
	cum_neg = 0
	cum_pos = 0
Head ce.order_id
	cnt += 1
	call alterlist(resulted->list, cnt)
	resulted->resultd_upto_date = cnt
Detail
	resulted->list[cnt].facility = facility
	resulted->list[cnt].encntrid = ce.encntr_id
	resulted->list[cnt].event_end_dt = ce.event_end_dt_tm
	resulted->list[cnt].order_mnemonic = trim(o.order_mnemonic)		
	resulted->list[cnt].orderid = o.order_id
	resulted->list[cnt].result_event = event
	resulted->list[cnt].result_event_cd = ce.event_cd		
	resulted->list[cnt].ce_result_value = trim(ce.result_val)
	resulted->list[cnt].result_meaning = 
		if(trim(ce.result_val) = 'Not Detected' or trim(ce.result_val) = 'Negative') 'N'
		elseif(trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
			or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected') 'P'
		endif

Foot ce.order_id	
	
	if(resulted->list[cnt].result_meaning = 'N')
		cum_neg += 1
	elseif(resulted->list[cnt].result_meaning = 'P')
		cum_pos += 1
	endif	

Foot report
	resulted->cumulative_positive = cum_pos
	resulted->cumulative_negative = cum_neg	

with nocounter

;call echorecord(resulted)

;------------------------------------------------------------------------------------------------------------
;3)New tests resulted  (midnight and midnight) also (5),(6),(7),(8)
;COVID_19 - test resulted - Previous day

select into $outdev

enc = resulted->list[d.seq].encntrid, result = resulted->list[d.seq].result_meaning
, event_dt = resulted->list[d.seq].event_end_dt "@SHORTDATE" , orderid = resulted->list[d.seq].orderid
 
from  (dummyt d with seq = value(size(resulted->list, 5)))

plan d where cnvtdatetime(resulted->list[d.seq].event_end_dt) between cnvtdatetime(start_date) and cnvtdatetime(end_date)

order by orderid

Head report 
	new_test_cnt = 0, new_test_pos_cnt = 0, new_test_neg_cnt = 0
	call alterlist(fema->list, 1)
	fema->list[1].facility = uar_get_code_display($acute_facility_list)
	fema->list[1].date_reporting = format(start_date,"dd-mmm-yyyy;;d")
	fema->list[1].cumulat_test_resulted = resulted->resultd_upto_date
	fema->list[1].cumulat_negative_covid = resulted->cumulative_negative
	fema->list[1].cumulat_positive_covid = resulted->cumulative_positive
Head orderid
	new_test_cnt += 1
	if(resulted->list[d.seq].result_meaning = 'P')
		new_test_pos_cnt += 1
	elseif(resulted->list[d.seq].result_meaning = 'N')
		new_test_neg_cnt += 1
	endif	
		
Foot report
	fema->list[1].new_test_resulted = new_test_cnt
	fema->list[1].new_positive_covid = new_test_pos_cnt
	fema->list[1].new_negative_covid = new_test_neg_cnt

with nocounter	

call echorecord(fema)

;------------------------------------------------------------------------------------------------------------
 
end
go
 

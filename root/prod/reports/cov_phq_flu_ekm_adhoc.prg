 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Sep'22
	Solution:			Quality/Pharmacy
	Source file name:		cov_phq_flu_ekm_adhoc.prg
	Object name:		cov_phq_flu_ekm_adhoc
	Request#:			Flu order cancel
	Program purpose:	      CCL will call a rule and cancel the Flu QM order for the existing patients in the units for the
					current flu season (Issue fix on Sep'22 : order placed before INA turn on thir build)
	Executing from:		Manual - as needed to fix the order error
 	Special Notes:		Rule name : COV_QM_FLU_IMM_ORDR_ADHOC
 
;********************************************************************************/
 
 
drop program cov_phq_flu_ekm_adhoc:dba go
create program cov_phq_flu_ekm_adhoc:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
; Include files used to call EXPERT_EVENT
; The first include file creates the EKSOPSRequest record structure which is used to pass patient info to the Discern Expert System
 
 
%i cclsource:eks_rprq3091001.inc
%i cclsource:eks_run3091001.inc
 
 
/**************************************************************
; VARIABLE DECLARATION
**************************************************************/
 
declare cnt = i4
declare opr_facility_var   = vc with noconstant("")
 
declare imm_qm_var    = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Immunizations Quality Measures'))), protect
declare flu_scren_var = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Influenza Screening Current Flu Season'))), protect
 
 
 
 
/**************************************************************
; CCL SCRIPT STARTS HERE
**************************************************************/
 
Record pat(
	1 rec_cnt = i4
	1 list[*]
		2 facility = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_type = vc
		2 fin = vc
		2 pat_name = vc
		2 regdt = vc
		2 dischdt = vc
		2 age_rs = vc
		2 order_name = vc
		2 orderdt = vc
		2 flu_flag = vc
		2 ce_doc = vc
)
 
 
 
/*
Record EKSOPSRequest (
   1 expert_trigger = vc
   1 qual[*]
	   2 person_id = f8
         2 sex_cd = f8
         2 birth_dt_tm = dq8
         2 encntr_id = f8
         2 accession_id = f8
         2 order_id = f8
         2 data[*]
      	   3 vc_var  = vc
               3 double_var = f8
               3 long_var  = i4
               3 short_var = i2
   )
 */
 
;-------------------------------------------------------------------------
 
 
 
select into $outdev
p.name_full_formatted, fin = trim(ea.alias), e.encntr_id, e.reg_dt_tm, o.order_status_cd, o.orig_order_dt_tm, sysdate
, o.order_id, o.order_mnemonic, o.catalog_cd;, lt.long_text
 
from encounter e
, person p, encntr_loc_hist elh, orders o, encntr_alias ea, order_comment oc, long_text lt
 
plan e where e.loc_facility_cd in(21250403.00, 2552503613.00, 2552503635.00, 2552503639.00, 2552503645.00, 2552503649.00, 2552503653.00)
	;e.loc_facility_cd = 2552503635.00 ;lcmc
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient,Observation,Behavioral Health
	and e.active_ind = 1
	and e.disch_dt_tm is null
	and e.encntr_status_cd = 854.00 ;Active
 
join p where p.person_id = e.person_id
	and p.birth_dt_tm < cnvtlookbehind("6,M")
	and p.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.catalog_cd in(imm_qm_var, flu_scren_var)
	and o.active_ind = 1
	and o.order_status_cd = 2550.00
	and o.orig_order_dt_tm between cnvtdatetime("15-SEP-2022 08:15:00") and cnvtdatetime("15-SEP-2022 08:33:00")
 
join oc where oc.order_id = o.order_id
 
join lt where lt.long_text_id = oc.long_text_id
	and lt.parent_entity_name = 'ORDER_COMMENT'
	and lt.long_text = 'Order created by COV_QM_FLU_IMM_ORDER Rule*'
 
order by e.encntr_id, o.order_id
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
;go to exitscript

 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->list, cnt)
	pat->list[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].personid = e.person_id
	pat->list[cnt].fin = trim(ea.alias)
	pat->list[cnt].pat_name = trim(p.name_full_formatted)
 
with nocounter
 
;-------------------------------------------------------------------------------
;CLinical
 
select into $outdev
fin = pat->list[d.seq].fin,ce.encntr_id, ce.event_cd, ce.result_val, ce.event_end_dt_tm
,doc = uar_get_code_display(ce.event_cd)
from (dummyt d with seq = pat->rec_cnt)
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->list[d.seq].encntrid
	and ce.event_cd in (4157736.00, 2658579259.00, 2555026041.00,2555026131.00)
	;Influenza Vaccine Status,Influenza Vaccine Given, Influenza Vaccine Indicated,Influenza Vaccine Not Indicated
 
order by ce.encntr_id, ce.event_cd
 
Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt, ce.encntr_id ,pat->list[icnt].encntrid)
      while(idx>0)
      	pat->list[idx].flu_flag = 'Y'
      	pat->list[idx].ce_doc = build2(doc, ' - ',ce.result_val)
      	idx = locateval(icnt ,(idx+1) ,pat->rec_cnt, ce.encntr_id ,pat->list[icnt].encntrid)
      endwhile
 
with nocounter
 
;call echorecord(pat)
;-----------------------------------------------------------------------
 
select into $outdev
	encntrid = pat->list[d1.seq].encntrid
	,personid = pat->list[d1.seq].personid
	, fin = substring(1, 30, pat->list[d1.seq].fin)
	, flu_flag = substring(1, 30, pat->list[d1.seq].flu_flag)
	, doc = substring(1, 300, pat->list[d1.seq].ce_doc)
 
from
	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1 where trim(substring(1, 1, pat->list[d1.seq].flu_flag)) = ' '

order by encntrid
 
with nocounter, separator=" ", format
 
/*
Head report
	cnt = 0
	EKSOPSRequest->expert_trigger = "CALL_FLU_IMM_EKM_ADHOC"
 
Detail
	cnt += 1
	if(mod(cnt,10) = 1)
		stat = alterlist(EKSOPSRequest->qual, cnt + 9)
	endif
	EKSOPSRequest->qual[cnt].person_id = personid
	EKSOPSRequest->qual[cnt].encntr_id = encntrid
 
Foot report
stat = alterlist(EKSOPSRequest->qual, cnt)
 
with nocounter
 
call echorecord(EKSOPSRequest)
 
#exitscript
 
;**********************************************
; Call EXPERT_EVENT
;**********************************************
 
if (cnt > 0)
	set dparam = 0
      call srvRequest(dparam)
endif
 */
 
end
go
 
 
 /*
-------------- Original EKM -----------------------------------------------------
 
;Patient pool
 
select distinct into $outdev
p.name_full_formatted, e.encntr_id, e.reg_dt_tm, age = cnvtage(p.birth_dt_tm);, o.order_mnemonic, o.catalog_cd
 
from encounter e, person p, encntr_loc_hist elh, orders o
 
plan e where e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient,Observation,Behavioral Health
	;and e.loc_facility_cd in(2552503635.00);lcmc
 	and e.loc_facility_cd in(21250403.00, 2552503613.00, 2552503635.00, 2552503639.00, 2552503645.00, 2552503649.00, 2552503653.00)
 	;and e.encntr_id in(125348735.00)
	and e.active_ind = 1
	and e.disch_dt_tm is null
	and e.encntr_status_cd = 854.00 ;Active
 
join p where p.person_id = e.person_id
	and p.birth_dt_tm < cnvtlookbehind("6,M")
	and p.active_ind = 1
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and not exists(select o2.encntr_id from orders o2
				where o2.encntr_id = o.encntr_id
				and o2.catalog_cd in(22337316.00, 3900687815.00)
				;Immunizations Quality Measures, Influenza Screening Current Flu Season
				and o2.active_ind = 1 )
 
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
*/
 

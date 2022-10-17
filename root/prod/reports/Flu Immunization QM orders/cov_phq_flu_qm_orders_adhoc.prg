/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Sep'2021
	Solution:			Quality
	Source file name:  	cov_phq_flu_qm_orders.prg
	Object name:		cov_phq_flu_qm_orders
	Request#:			11012
 	Program purpose:	      Flu task tracking and patients checklist
	Executing from:		DA2
  	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	-----------------------------------------------------------------
 
******************************************************************************/
 


drop program cov_phq_flu_qm_orders_adhoc:dba go
create program cov_phq_flu_qm_orders_adhoc:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV
 
 
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


;---------------------------------------------------------------------------------------------------------------------------
;Patient Pool

;IF($repo_type = "2")
 
select into $outdev
p.name_full_formatted, fin = trim(ea.alias), e.encntr_id, e.reg_dt_tm, o.order_status_cd, o.orig_order_dt_tm
, o.order_id, o.order_mnemonic, o.catalog_cd;, lt.long_text
;,ce.event_cd, ce.result_val, ce.event_end_dt_tm
;,     4157736.00	Influenza Vaccine Status
 
from encounter e
;, (left join clinical_event ce on e.encntr_id = ce.encntr_id and ce.event_cd = 4157736.00)	
, person p, encntr_loc_hist elh, orders o, encntr_alias ea, order_comment oc, long_text lt
 
plan e where e.loc_facility_cd = 2552503635.00 ;lcmc
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient,Observation,Behavioral Health
	and e.active_ind = 1
	and e.disch_dt_tm is null
	and e.encntr_status_cd = 854.00 ;Active

;join ce 
join p where p.person_id = e.person_id
	and p.birth_dt_tm < cnvtlookbehind("6,M")
	and p.active_ind = 1
	
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.catalog_cd in(imm_qm_var, flu_scren_var)	;in(22337316.00, 3900687815.00)
	and o.active_ind = 1 

join oc where oc.order_id = o.order_id

join lt where lt.long_text_id = oc.long_text_id
	and lt.parent_entity_name = 'ORDER_COMMENT'
	and lt.long_text = 'Order created by COV_QM_FLU_IMM_ORDER Rule*'	

order by e.encntr_id, o.order_id;, o.catalog_cd

Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->list, cnt)
	pat->list[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->list[cnt].encntrid = e.encntr_id
	;pat->list[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	pat->list[cnt].fin = trim(ea.alias)
	;pat->list[cnt].regdt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
	;pat->list[cnt].dischdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
	;pat->list[cnt].age_rs = age
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

call echorecord(pat)

;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120

END GO



;clinical_event ce on e.encntr_id = ce.encntr_id and ce.event_cd = 4157736.00)	
; 2658579259.00	        236.00	Influenza Vaccine Given

 ;2555026041.00	Influenza Vaccine Indicated
 ; 2555026131.00	Influenza Vaccine Not Indicated
 ;2587631663.00	QM Rea Influenza Vaccine NtGvn v5.4


;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120


;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120

;-----------------------------------------------------------------------
/*
ELSEIF($repo_type = "1")
 
select distinct into $outdev

p.name_full_formatted, fin = trim(ea.alias), e.reg_dt_tm, age = cnvtage(p.birth_dt_tm),
o.orig_order_dt_tm, trim(o.order_mnemonic)
 
from encounter e, person p, encntr_loc_hist elh, encntr_alias ea, orders o
 
plan e where operator(e.loc_facility_cd, opr_facility_var, $facility_list)
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
	and o.active_ind = 1
	and o.catalog_cd in(imm_qm_var, flu_scren_var)
				
order by e.encntr_id, o.catalog_cd				

Head report
	cnt = 0
Head o.catalog_cd
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->list, cnt)
	pat->list[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	pat->list[cnt].fin = trim(ea.alias)
	pat->list[cnt].regdt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
	pat->list[cnt].dischdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
	pat->list[cnt].age_rs = age
	pat->list[cnt].pat_name = trim(p.name_full_formatted)
	pat->list[cnt].order_name = trim(o.order_mnemonic)
	pat->list[cnt].orderdt = format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
			
with nocounter
				
ENDIF

;------------------------------------------------------------------------------------------------------
if(pat->rec_cnt > 0)

select into $outdev
	facility = substring(1, 30, pat->list[d1.seq].facility)
	, patient_name = substring(1, 50, pat->list[d1.seq].pat_name)
	, fin = substring(1, 30, pat->list[d1.seq].fin)
	, patient_type = substring(1, 50, pat->list[d1.seq].pat_type)
	, admit_dt = substring(1, 30, pat->list[d1.seq].regdt)
	, disch_dt = substring(1, 30, pat->list[d1.seq].dischdt)
	, age = substring(1, 30, pat->list[d1.seq].age_rs)
	, order_dt = substring(1, 30, pat->list[d1.seq].orderdt)
	, order_name = substring(1, 100, pat->list[d1.seq].order_name)

from
	(dummyt   d1  with seq = size(pat->list, 5))

plan d1

order by patient_name,order_name

with nocounter, separator=" ", format

endif

end
go
 
 /*
select o.catalog_cd,o.order_detail_display_line,o.inst_id, o.*
from orders o where o.order_id =  6583453671.00

select * from order_comment o where o.order_id =  6583453671.00

select * from long_text lt where lt.long_text_id =  1952887141.00

select * from order_catalog_synonym ocs where ocs.catalog_cd =  3979889941.00

select * from order_sentence o where o.txn_id_text = '213.9.89771325'


;Immunizations Quality Measures, Influenza Screening Current Flu Season


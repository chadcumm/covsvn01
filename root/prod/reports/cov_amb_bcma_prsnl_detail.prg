 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan'2021
	Solution:			Ambulatory/Pharmacy
	Source file name:	      cov_amb_bcma_pat_level.prg
	Object name:		cov_amb_bcma_pat_level
	Request#:			8380
	Program purpose:	      BCMA Compliance Detail - Patient level
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-----------------------------------------------------------------
 
******************************************************************************/
 
drop program cov_amb_bcma_prsnl_detail:DBA go
create program cov_amb_bcma_prsnl_detail:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Clinic" = 0
 
with OUTDEV, start_datetime, end_datetime, clinic
 
/**************************************************************
; Variable Declaration
**************************************************************/
declare initcap() = c100
declare username           = vc with protect
declare opr_clinic_var    = vc with noconstant("")
declare num  = i4 with noconstant(0)
 
;Set clinic variable
if(substring(1,1,reflect(parameter(parameter2($clinic),0))) = "L");multiple values were selected
	set opr_clinic_var = "in"
elseif(parameter(parameter2($clinic),1)= 0.0) ;all[*] values were selected
	set opr_clinic_var = "!="
else								  ;a single value was selected
	set opr_clinic_var = "="
endif
 
;**************************************************************
 
RECORD bcma_sum(
	1 report_ran_by = vc
	1 list[*]
		2 org_id = f8
		2 clinic = vc
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
		2 prsnl_name = vc
		2 prsnl_role = vc
		2 pr_tot_med_given = f8
		2 pr_tot_med_scan = f8
		2 pr_tot_wrist_scan = f8
		2 pr_tot_compliance = f8
)
 
;--------------- Helpers -------------------------------------------------------------
 
Record bcma(
	1 rec_cnt = i4
	1 plist[*]
		2 clinic = vc
		2 clinic_cd = f8
		2 orgid = f8
		2 prsnl_name = vc
		2 prsnl_position = vc
		2 encntrid = f8
		2 med_admin_eventid = f8
		2 event_cnt = i4
		2 eventid = f8
		2 orderid = f8
		2 catalogcd = f8
		2 positive_med_ind = i4
		2 positive_patient_ind = i4
		2 itemid = f8
		2 charge_number = vc
		2 non_bcma_med = vc
		2 order_mnemonic = vc
		2 met_compli = i2
)
 
Record fac(
	1 list[*]
		2 org_id = f8
		2 clinic = vc
		2 fac_tot_med_given = f8
		2 fac_tot_med_scan = f8
		2 fac_tot_wrist_scan = f8
		2 fac_tot_compliance = f8
	)
 
 
Record orga(
	1 olist[*]
		2 org_id = f8
		2 org_name = vc
)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get selected(prompt) locations
 
select distinct into $outdev
 
org.organization_id, org.org_name
 
from
    org_set o
    , org_set_org_r os
    , organization org
 
plan org where operator(org.organization_id, opr_clinic_var, $clinic)
    and org.active_ind = 1
 
join os where os.organization_id = org.organization_id
 
join o where o.org_set_id = os.org_set_id
    and o.name like '*CMG*'
 
Head report
	gcnt = 0
Detail
	gcnt += 1
	call alterlist(orga->olist, gcnt)
	orga->olist[gcnt].org_id = org.organization_id
	orga->olist[gcnt].org_name = org.org_name
 
with nocounter
 
;--------------------------------------------------------
;Get user in action

select into "NL:"
from	prsnl p
where p.person_id = reqinfo->updt_id
detail
	bcma_sum->report_ran_by = p.username
with nocounter
 
;----------------------------------------------------------------------------------------------------------
;Get Med admins

select into $outdev
loc = trim(substring(1,100,orga->olist[d.seq].org_name))
, e.encntr_id, prsnl_name = initcap(pr.name_full_formatted), role = uar_get_code_display(pr.position_cd)
, mae.event_id, mae.med_admin_event_id,  mae.nurse_unit_cd, mae.event_cnt, o.order_id
, mae.positive_med_ident_ind, mae.positive_patient_ident_ind, pr.name_full_formatted, o.hna_order_mnemonic
, met_comp = evaluate2( if(mae.positive_patient_ident_ind = 1 and mae.positive_med_ident_ind = 1 )1 else 0 endif )
 
from  (dummyt d with seq = size(orga->olist, 5))
	, encounter e
	, clinical_event ce
	, med_admin_event mae
	, order_ingredient oi
  	, prsnl pr
  	, order_dispense od
	, orders o
  	,(left join order_product op on op.order_id = o.order_id)
 	,(left join med_identifier mi on mi.item_id = op.item_id
		and mi.med_identifier_type_cd = 3096.00 ;Charge Number
		and mi.active_ind = 1)

plan d

join e where e.organization_id = orga->olist[d.seq].org_id 
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.result_status_cd in(25, 34, 35)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 
join mae where mae.event_id = ce.event_id
	and mae.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and mae.med_admin_event_id+0 > 0
	and mae.event_type_cd = 4055412.00	;Administered
 
join o where o.order_id = mae.template_order_id
	and o.active_ind = 1
 
join op
join mi
 
join oi where oi.order_id =  mae.template_order_id
	and oi.action_sequence = mae.documentation_action_sequence
	and oi.ingredient_type_flag != 5
 
join od where od.order_id = o.order_id
	and od.dispense_category_cd != 2561954483.00 ;Dummy Items COA
 
join pr where pr.person_id = mae.prsnl_id
	;and pr.active_ind = 1
 
order by mae.event_id
 
Head report
	cnt = 0
Head mae.event_id
	cnt += 1
	call alterlist(bcma->plist, cnt)
	bcma->plist[cnt].orgid = e.organization_id
	bcma->plist[cnt].clinic = loc
	bcma->plist[cnt].prsnl_name = prsnl_name
	bcma->plist[cnt].prsnl_position = role
	bcma->plist[cnt].encntrid = e.encntr_id
	bcma->plist[cnt].met_compli = met_comp
	bcma->plist[cnt].orderid = o.order_id
	bcma->plist[cnt].catalogcd = o.catalog_cd
	bcma->plist[cnt].itemid = op.item_id
	bcma->plist[cnt].charge_number = trim(mi.value, 3)
	bcma->plist[cnt].order_mnemonic = cnvtlower(o.order_mnemonic)
	bcma->plist[cnt].eventid = mae.event_id
	bcma->plist[cnt].event_cnt = mae.event_cnt
	bcma->plist[cnt].med_admin_eventid = mae.med_admin_event_id
	bcma->plist[cnt].positive_med_ind = mae.positive_med_ident_ind
	bcma->plist[cnt].positive_patient_ind = mae.positive_patient_ident_ind
 
with nocounter
 
 
;------------------------------------------------------------------------------------------------------------
;Get Organization
/*
select into 'nl'
from organization org
 
plan org where expand(num, 1, value(size(bcma->plist,5)), org.organization_id, bcma->plist[num].orgid)
	and org.active_ind = 1
 
order by org.organization_id
 
Head org.organization_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,size(bcma->plist,5) ,org.organization_id ,bcma->plist[cnt].orgid)
	while(idx > 0)
		bcma->plist[idx].clinic = org.org_name
		idx = locateval(cnt,(idx+1),size(bcma->plist,5) ,org.organization_id ,bcma->plist[cnt].orgid)
	endwhile
 
with nocounter, expand = 1
*/
 
;-------------------------------------------------------------------------------------------------------------
 
;Flag Non-BCMA meds as per pharmacy exclusion list
select into $outdev
 
charge_num = trim(cv1.display, 3) ;trim(bcma->plist[d.seq].charge_number, 3)
, cat = bcma->plist[d.seq].catalogcd, item = bcma->plist[d.seq].itemid
 
from	(dummyt d with seq = value(size(bcma->plist, 5)))
  	, code_value cv1
  	, code_value_extension cve
  	, code_value_extension cve1
 
plan cv1 where cv1.code_set = 100499
	and cv1.cdf_meaning = 'BCMA_RX'
	and cv1.active_ind = 1
 
join d where trim(bcma->plist[d.seq].charge_number, 3) = trim(cv1.display, 3)
 
join cve where cve.code_set = cv1.code_set
	and cv1.code_value = cv1.code_value
	and cve.field_name = 'Catalog_cd'
	and cnvtreal(cve.field_value) = bcma->plist[d.seq].catalogcd
 
join cve1 where cve1.code_set = cv1.code_set
	and cve1.code_value = cv1.code_value
	and cve1.field_name = 'Item_id'
	and cnvtreal(cve1.field_value) = bcma->plist[d.seq].itemid
 
order by charge_num
 
Head charge_num
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,size(bcma->plist,5) ,charge_num ,trim(bcma->plist[cnt].charge_number, 3))
      while(idx > 0)
		bcma->plist[idx].non_bcma_med = 'Yes'
	      idx = locateval(cnt ,(idx+1) ,size(bcma->plist,5) ,charge_num ,trim(bcma->plist[cnt].charge_number, 3))
	endwhile
 
With nocounter
 
;----------------------------------------------------------------------------------------------------
;----------- Aggregated Results
 
;Get aggregated results for PRSNL
select into 'nl:'
 orgnid = bcma->plist[d1.seq].orgid
, clinic_name = bcma->plist[d1.seq].clinic
, prsnl_name = bcma->plist[d1.seq].prsnl_name
, role = bcma->plist[d1.seq].prsnl_position
, event_cnt = bcma->plist[d1.seq].event_cnt
, event_id = bcma->plist[d1.seq].eventid
, positive_med_ind = bcma->plist[d1.seq].positive_med_ind
, positive_patient_ind = bcma->plist[d1.seq].positive_patient_ind
, met_compli = cnvtint(bcma->plist[d1.seq].met_compli)
 
from	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1 where bcma->plist[d1.seq].non_bcma_med != 'Yes'
 
/*Non-Formulary Items
where substring(1,4, trim(substring(1, 30, bcma->plist[d1.seq].charge_number ))) != 'NCRX' ;non chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by orgnid, prsnl_name, event_id
 
Head report
	cnt = 0
Head prsnl_name
	cnt += 1
	call alterlist(bcma_sum->list, cnt)
Foot prsnl_name
	bcma_sum->list[cnt].org_id = orgnid
	bcma_sum->list[cnt].clinic = clinic_name
	bcma_sum->list[cnt].prsnl_name = prsnl_name
	bcma_sum->list[cnt].prsnl_role = role
	bcma_sum->list[cnt].pr_tot_med_given = sum(event_cnt)
	bcma_sum->list[cnt].pr_tot_med_scan =sum(positive_med_ind)
	bcma_sum->list[cnt].pr_tot_wrist_scan = sum(positive_patient_ind)
	bcma_sum->list[cnt].pr_tot_compliance = sum(met_compli)
 
with nocounter
 
 
;--------------------------------------------------------------------------------------------
;Get aggregated results for Clinics
 
select into 'nl:'
 orgnid = bcma->plist[d1.seq].orgid
, clinic_name = bcma->plist[d1.seq].clinic
, prsnl_name = bcma->plist[d1.seq].prsnl_name
, event_cnt = bcma->plist[d1.seq].event_cnt
, event_id = bcma->plist[d1.seq].eventid
, positive_med_ind = bcma->plist[d1.seq].positive_med_ind
, positive_patient_ind = bcma->plist[d1.seq].positive_patient_ind
, met_compli = cnvtint(bcma->plist[d1.seq].met_compli)
 
from	(dummyt   d1  with seq = size(bcma->plist, 5))
 
plan d1 where bcma->plist[d1.seq].non_bcma_med != 'Yes'
 
/*Non-Formulary Items
where substring(1,4, trim(substring(1, 30, bcma->plist[d1.seq].charge_number ))) != 'NCRX' ;non chargeable items
	and trim(substring(1, 300, bcma->plist[d1.seq].order_mnemonic)) != '*non-formulary*'
*/
 
order by orgnid, prsnl_name, event_id
 
Head report
	fcnt = 0
Head orgnid
	fcnt += 1
	call alterlist(fac->list, fcnt)
Foot orgnid
	fac->list[fcnt].org_id = orgnid
	fac->list[fcnt].fac_tot_med_given = sum(event_cnt)
	fac->list[fcnt].fac_tot_med_scan = sum(positive_med_ind)
	fac->list[fcnt].fac_tot_wrist_scan = sum(positive_patient_ind)
	fac->list[fcnt].fac_tot_compliance = sum(met_compli)
with nocounter
 
;call echorecord(fac)
 
;--------------------------------------------------------
;Assign clinic results to bcma_sum
select into 'nl:'
 
orgnid = fac->list[d2.seq].org_id
 
from (dummyt   d1  with seq = size(bcma_sum->list, 5))
	,(dummyt   d2  with seq = size(fac->list, 5))
 
plan d1
 
join d2 where bcma_sum->list[d1.seq].org_id = fac->list[d2.seq].org_id
 
order by orgnid
 
Head orgnid
	lnum = 0
	idx = 0
      idx = locateval(lnum ,1 ,size(bcma_sum->list ,5), orgnid, bcma_sum->list[lnum].org_id)
      while(idx > 0)
		bcma_sum->list[idx].fac_tot_med_given = fac->list[d2.seq].fac_tot_med_given
		bcma_sum->list[idx].fac_tot_med_scan = fac->list[d2.seq].fac_tot_med_scan
		bcma_sum->list[idx].fac_tot_wrist_scan = fac->list[d2.seq].fac_tot_wrist_scan
		bcma_sum->list[idx].fac_tot_compliance = fac->list[d2.seq].fac_tot_compliance
	      idx = locateval(lnum,(idx+1),size(bcma_sum->list ,5), orgnid ,bcma_sum->list[lnum].org_id)
	endwhile
 
with nocounter
 
 
;-----------temp-----------------------------------------------------------
/* 
SELECT into $outdev
 
	clinic = SUBSTRING(1, 100, BCMA_SUM->list[D1.SEQ].clinic)
	, FAC_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].fac_tot_med_given
	, FAC_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_med_scan
	, FAC_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].fac_tot_wrist_scan
	, FAC_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].fac_tot_compliance
	, PRSNL_NAME = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_name)
	, PRSNL_ROLE = SUBSTRING(1, 30, BCMA_SUM->list[D1.SEQ].prsnl_role)
	, PR_TOT_MED_GIVEN = BCMA_SUM->list[D1.SEQ].pr_tot_med_given
	, PR_TOT_MED_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_med_scan
	, PR_TOT_WRIST_SCAN = BCMA_SUM->list[D1.SEQ].pr_tot_wrist_scan
	, PR_TOT_COMPLIANCE = BCMA_SUM->list[D1.SEQ].pr_tot_compliance
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(BCMA_SUM->list, 5))
 
PLAN D1
 
order by clinic
 
with nocounter, separator=" ", format
*/
 
#exitscript
 
end go
;----------------------------------------------------------------------------
 
 
 
 

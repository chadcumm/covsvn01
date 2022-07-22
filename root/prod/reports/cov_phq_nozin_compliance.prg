 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Feb'2020
	Solution:			Quality
	Source file name:  	cov_phq_nozin_compliance.prg
	Object name:		cov_phq_nozin_compliance
	Request#:			7061
 
	Program purpose:	      Report will show orders that are placed by nozin rules
	Executing from:		CCL/DA2
  	Special Notes:		Nozin compliance summary report
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_nozin_compliance:dba go
create program cov_phq_nozin_compliance:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = ""
	, "End Date/Time" = ""
	, "FacilityListBox" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
;Hip and Knee
declare art_art_knee_var         = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Arthroscopy Knee')),protect
declare art_hip_var              = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Hip')),protect
declare art_knee_var             = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Knee')),protect
declare art_nav_hip_var          = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Navigation Hip')),protect
declare art_part_hip_ant_var     = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Partial Hip Anterior')),protect
declare art_remov_hip_var        = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Removal Prosthesis and Insertion Spacer Hip')),protect
declare art_remov_knee_var   	   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Removal Prosthesis and Insertion Spacer Knee')),protect
declare art_rep_inv_hip_var      = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Minimally Invasive Total Hip')),protect
declare art_rep_inv_knee_var     = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Minimally Invasive Total Knee')),protect
declare art_rep_part_hip_var     = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Partial Hip')),protect
declare art_rep_tot_hip_var      = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Total Hip')),protect
declare art_rep_tot_hip_bi_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Total Hip Bilateral')),protect
declare art_rep_tot_knee_var     = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Total Knee')),protect
declare art_rep_tot_knee_bi_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Total Knee Bilateral')),protect
declare art_rep_tot_knee_nav_var = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Replacement Total Knee Navigation')),protect
declare art_resur_hip_var        = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Resurfacing Hip')),protect
declare art_rev_arth_knee_var    = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Revision Arthroscopy Total Knee')),protect
declare art_rev_hip_var          = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Revision Hip')),protect
declare art_rev_tot_knee_var     = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Revision Total Knee')),protect
declare art_robo_part_knee_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Robot Assisted Partial Knee')),protect
declare art_robo_tot_hip_var     = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Robot Assisted Total Hip')),protect
declare art_robo_tot_knee_var    = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Robot Assisted Total Knee')),protect
declare art_tot_hip_ant_var      = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Total Hip Anterior')),protect
declare art_uni_knee_var         = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Arthroplasty Unicompartmental Knee')),protect
 
;Brain
declare c1_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Biopsy Craniotomy Brain')),protect
declare c2_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Biopsy Craniotomy Image Guided')),protect
declare c3_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Closure Fistula Cerebrospinal Fluid')),protect
declare c4_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Cranioplasty')),protect
declare c5_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Cranioplasty Decompression Skull Fracture')),protect
declare c6_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy')),protect
declare c7_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Ablation Frontal Sinus')),protect
declare c8_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Abscess Drainage')),protect
declare c9_var   = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Anterior Fossa')),protect
declare c10_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Arterial Bypass')),protect
declare c11_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Arteriovenous Malformation')),protect
declare c12_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Burr Holes')),protect
declare c13_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Burr Holes Evacuation Hematoma')),protect
declare c14_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Cavernous Malformation')),protect
declare c15_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Cortical Neurostimulator Insertion or Replacement')),protect
declare c16_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Cortical Neurostimulator Removal')),protect
declare c17_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Decompression Arnold-Chiari Malformation')),protect
declare c18_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Decompression Optic Nerve')),protect
declare c19_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Decompression Repair')),protect
declare c20_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Electrography Monitor Lead Placement')),protect
declare c21_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Electrography Monitor Lead Removal')),protect
declare c22_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Elevation Bone Flap')),protect
declare c23_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Evacuation Hematoma')),protect
declare c24_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Excision Cyst')),protect
declare c25_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Flap Removal')),protect
declare c26_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Foreign Body Removal')),protect
declare c27_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Hypophysectomy')),protect
declare c28_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Image-Guided')),protect
declare c29_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Image-Guided Resection Tumor')),protect
declare c30_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Insertion Ventricular Catheter Reservoir')),protect
declare c31_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Lobectomy')),protect
declare c32_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Meningioma')),protect
declare c33_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Middle Fossa')),protect
declare c34_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Posterior Fossa')),protect
declare c35_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Removal Seizure Focus')),protect
declare c36_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Removal Ventricular Catheter Reservoir')),protect
declare c37_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Repair Craniosynostosis')),protect
declare c38_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Repair Encephalocele')),protect
declare c39_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Resection Tumor')),protect
declare c40_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Robotic-Assisted and Removal Seizure Focus')),protect
declare c41_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy Ventriculostomy')),protect
declare c42_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy with Brachytherapy Intracranial')),protect
declare c43_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy with Brachytherapy Seed Removal')),protect
declare c44_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Craniotomy with Duraplasty')),protect
declare c45_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Duraplasty')),protect
declare c46_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Excision Neuroblastoma')),protect
declare c47_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Fenestration Optic Nerve')),protect
declare c48_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Foraminotomy')),protect
declare c49_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Marsupialization Brain')),protect
declare c50_var  = f8 with constant(uar_get_code_by("DESCRIPTION", 200, 'Repair Aneurysm Craniotomy')),protect

declare preop_msg_var  = vc with constant('Order placed by NozinPreOp rule')
declare postop_msg_var = vc with constant('Order placed by NozinPostOp rule')
declare ccu_msg_var    = vc with constant('Order placed by NozinCCU rule')
 
declare order_note_var = vc with noconstant(' ') 
declare ocnt = i4 with noconstant(0)
declare chart_cnt = i4 with noconstant(0)
declare chlo_cnt = i4 with noconstant(0)
declare dg_list_var = vc with noconstant(' ')

/**************************************************************
; Start Coding
**************************************************************/

Record nozin(
	1 plist[*]
		2 facility = f8
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 patient_name = vc
		2 admit_dt = vc
		2 disch_dt = vc
		2 procedure = vc
		2 diagnosis = vc ;diagnosis + procedure
		2 los = i4
		2 chlohex_tot = i4
		2 tot_order_fired = i4
		2 tot_admin_charted = i4
		2 tot_application = i4
		2 olist[*]
			3 orderid = f8
			3 original_order_dt = dq8
			3 template_orderid = f8
)

;------------------------------------------------------------------------------------------------------------
;Get all orders placed by the Nozin rules
select into $outdev
 
 o.encntr_id, o.order_id, o.template_order_id,o.last_action_sequence, o.catalog_cd
,o.orig_order_dt_tm "@SHORTDATETIME"
, oa.order_dt_tm "@SHORTDATETIME" , order_note = trim(lt.long_text)
, oa.action_sequence, o.clinical_display_line
 
from
	encounter e
	, orders o
	, order_action oa
	, order_comment oc
	, long_text lt
	
plan e where e.loc_facility_cd = $facility_list
	and e.active_ind = 1	
 
join o where o.encntr_id = e.encntr_id
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.catalog_cd = 2757685.00 ;ethanol topical
	and o.active_ind = 1
 
join oa where oa.order_id = o.order_id
	and oa.order_provider_id = 1
	and oa.action_sequence = o.last_action_sequence
 
join oc where oc.order_id = o.template_order_id
	and oc.comment_type_cd = 67
 
join lt where lt.long_text_id = oc.long_text_id
	and lt.active_ind = 1
 
order by o.encntr_id, o.template_order_id, o.order_id, oa.order_dt_tm
 
Head report
	cnt = 0 
Head o.encntr_id
	cnt += 1
	call alterlist(nozin->plist, cnt)
	nozin->plist[cnt].facility = e.loc_facility_cd
	nozin->plist[cnt].encntrid = o.encntr_id
	nozin->plist[cnt].personid = e.person_id
	nozin->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	nozin->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	ocnt = 0
Head o.order_id
	ocnt += 1
	call alterlist(nozin->plist[cnt].olist, ocnt)
	nozin->plist[cnt].olist[ocnt].orderid = o.order_id
	nozin->plist[cnt].olist[ocnt].original_order_dt = o.orig_order_dt_tm
	nozin->plist[cnt].olist[ocnt].template_orderid = o.template_order_id
Foot o.encntr_id
	nozin->plist[cnt].tot_order_fired = ocnt

with nocounter

;-----------------------------------------------------------------------------------------
;Get clinical charting on med admin
select into $outdev

encntrid = nozin->plist[d1.seq].encntrid
,orderid = nozin->plist[d1.seq].olist[d2.seq].orderid
,template_orderid = nozin->plist[d1.seq].olist[d2.seq].template_orderid
, ce.event_cd, ce.result_val, ce.event_tag, ce.result_status_cd

from	(dummyt   d1  with seq = size(nozin->plist, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce

plan d1 where maxrec(d2, size(nozin->plist[d1.seq].olist, 5))

join d2

join ce where ce.encntr_id = nozin->plist[d1.seq].encntrid
	and ce.order_id = nozin->plist[d1.seq].olist[d2.seq].orderid
	and ce.event_cd = 2797733.00
	and ce.result_val = '1.000000'
	and ce.event_tag = '1 app'
	and ce.result_status_cd in(25,34,35)

order by ce.encntr_id, ce.order_id

Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(nozin->plist,5), ce.encntr_id ,nozin->plist[icnt].encntrid)
      chart_cnt = 0
Head ce.order_id
	chart_cnt += 1
Foot ce.encntr_id
	nozin->plist[idx].tot_admin_charted = chart_cnt	
	nozin->plist[idx].tot_application = chart_cnt ;(each 1 app)	
with nocounter	

;------------------------------------------------------------------------------------------------
;Get demographic
select into 'nl:'
 
from (dummyt d WITH seq = value(size(nozin->plist,5)))
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = nozin->plist[d.seq].personid
	and p.active_ind = 1
 
join ea where ea.encntr_id = nozin->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by p.person_id, ea.encntr_id
 
Head ea.encntr_id
	nozin->plist[d.seq].patient_name = p.name_full_formatted
	nozin->plist[d.seq].fin = ea.alias
 
with nocounter

;------------------------------------------------------------------------------------------------
;Get Procedure
select into $outdev

o.encntr_id, o.order_id, o.hna_order_mnemonic, o.orig_order_dt_tm "@SHORTDATETIME"
, order_status = uar_get_code_display(o.order_status_cd)

from (dummyt d WITH seq = value(size(nozin->plist,5)))
	, orders o
	, surgical_case sc
 
plan d
 
join o where o.encntr_id = nozin->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.catalog_cd in(art_art_knee_var,art_hip_var,art_knee_var,art_nav_hip_var,art_part_hip_ant_var,art_remov_hip_var
		,art_remov_knee_var,art_rep_inv_hip_var,art_rep_inv_knee_var,art_rep_part_hip_var,art_rep_tot_hip_var,art_rep_tot_hip_bi_var
		,art_rep_tot_knee_var,art_rep_tot_knee_bi_var,art_rep_tot_knee_nav_var,art_resur_hip_var,art_rev_arth_knee_var,art_rev_hip_var
		,art_rev_tot_knee_var,art_robo_part_knee_var,art_robo_tot_hip_var,art_robo_tot_knee_var,art_tot_hip_ant_var,art_uni_knee_var
		,c1_var,c2_var,c3_var,c4_var,c5_var,c6_var,c7_var,c8_var,c9_var,c10_var,c11_var,c12_var,c13_var,c14_var,c15_var,c16_var
		,c17_var,c18_var,c19_var,c20_var,c21_var,c22_var,c23_var,c24_var,c25_var,c26_var,c27_var,c28_var,c29_var,c30_var
		,c31_var,c32_var,c33_var,c34_var,c35_var,c36_var,c37_var,c38_var,c39_var,c40_var,c41_var,c42_var,c43_var,c44_var
		,c45_var,c46_var,c47_var,c48_var,c49_var,c50_var)
 
join sc where sc.encntr_id = o.encntr_id
	and sc.active_ind = 1
 
order by o.encntr_id, o.order_id
 
Head o.encntr_id
	nozin->plist[d.seq].procedure = trim(o.hna_order_mnemonic)
 
with nocounter

;------------------------------------------------------------------------------------------------
;Get Diagnosis

select into 'nl:'
 
fin = nozin->plist[d.seq].fin, dg.encntr_id, dg.diagnosis_display
, dg_dt1 = format(dg.diag_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')


from (dummyt d WITH seq = value(size(nozin->plist,5)))
	,diagnosis dg

plan d

join dg where dg.encntr_id = nozin->plist[d.seq].encntrid
	and dg.active_ind = 1
	and (dg.beg_effective_dt_tm <= sysdate and dg.end_effective_dt_tm >= sysdate)
	and dg.beg_effective_dt_tm = (select max(dg1.beg_effective_dt_tm) from diagnosis dg1 where dg1.encntr_id = dg.encntr_id
			and dg1.diagnosis_display = dg.diagnosis_display
			group by dg1.diagnosis_display)
 
order by dg.encntr_id, dg.diag_priority asc
 
Head dg.encntr_id
	cnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,size(nozin->plist,5) ,dg.encntr_id ,nozin->plist[cnt].encntrid)
      dg_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(dg.diagnosis_display),',')
	endif
Foot dg.encntr_id
	nozin->plist[idx].diagnosis = replace(trim(dg_list_var),",","",2)
 
with nocounter



/*
select into $outdev

fin = nozin->plist[d.seq].fin, dig.encntr_id, dig.diagnosis_display
, dig.clinical_diag_priority, dig.diag_priority

from (dummyt d WITH seq = value(size(nozin->plist,5)))
	,diagnosis dig

plan d

join dig where dig.encntr_id = nozin->plist[d.seq].encntrid
	and dig.active_ind = 1
	and dig.clinical_diag_priority = 1

order by dig.encntr_id

Head dig.encntr_id
	nozin->plist[d.seq].diagnosis = trim(dig.diagnosis_display)
 
with nocounter
*/
;------------------------------------------------------------------------------------------------
;Get clinical chartin -  Chlorohexidine treatment
select into $outdev

fin = nozin->plist[d.seq].fin, ce.encntr_id, ce.result_val

from (dummyt d WITH seq = value(size(nozin->plist,5)))
	,clinical_event ce

plan d

join ce where ce.encntr_id = nozin->plist[d.seq].encntrid
	and ce.event_cd =  3162698651.00 ;Chlorohexidine treatment
	and ce.result_val = 'Yes'
	and ce.result_status_cd in(25,34,35)

order by ce.encntr_id, ce.event_id

Head ce.encntr_id
	chlo_cnt = 0
Head ce.event_id
	chlo_cnt += 1
Foot ce.encntr_id
	nozin->plist[d.seq].chlohex_tot = chlo_cnt
 
with nocounter

call echorecord(nozin)

;-------------------------------------------------------------------------------------------
select into $outdev

	facility = trim(uar_get_code_display(nozin->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, nozin->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, nozin->plist[d1.seq].patient_name))
	, admit_dt = trim(substring(1, 15, nozin->plist[d1.seq].admit_dt))
	, disch_dt = trim(substring(1, 15, nozin->plist[d1.seq].disch_dt))
	, orders_fired = nozin->plist[d1.seq].tot_order_fired
	, med_admin_charted = nozin->plist[d1.seq].tot_admin_charted
	, dosage = build2(nozin->plist[d1.seq].tot_application, ' App')
	, Chlorohexidine = nozin->plist[d1.seq].chlohex_tot
	, diagnosis = build2('[',trim(substring(1, 300, nozin->plist[d1.seq].procedure)),']'
		,'[',trim(substring(1, 300, nozin->plist[d1.seq].diagnosis)),']')

from
	(dummyt   d1  with seq = size(nozin->plist, 5))

plan d1

with nocounter, separator=" ", format


end go	


 
/*

select * from encntr_alias ea where ea.alias = '1822100083'

select oa.order_dt_tm "@SHORTDATETIME", oa.order_provider_id, oa.* from order_action oa where oa.order_id = 2667229609
 
select o.template_order_id, o.orig_order_dt_tm "@SHORTDATETIME", o.* from orders o where o.order_id = 2667229609
 
select * from clinical_event ce where ce.order_id =   2667229609.00

select d.clinical_diag_priority, d.diagnosis_display, d.diag_priority from diagnosis d where d.encntr_id =   118480361.00
 
select o.template_order_id,o.* from orders o where o.template_order_id in(2662451491, 2660429517)

select ce.encntr_id, ce.order_id, ce.event_cd, ce.result_val, ce.event_tag, ce.result_status_cd
from clinical_event ce where ce.encntr_id = 118334274
	and ce.event_cd = 2797733.00
	and ce.result_val = '1.000000'
	and ce.event_tag = '1 app'
	and ce.result_status_cd in(25,34,35)


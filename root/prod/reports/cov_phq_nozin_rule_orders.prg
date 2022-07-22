 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		May'2018
	Solution:			population Health Quality
	Source file name:  	cov_phq_nozin_rule_orders.prg
	Object name:		cov_phq_nozin_rule_orders
	Request#:			7061
 
	Program purpose:	      Report will show orders that are placed by nozin rules
	Executing from:		CCL/DA2
  	Special Notes:          Excel file.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_nozin_rule_orders go
create program cov_phq_nozin_rule_orders
 
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
 
declare rule = vc with noconstant('')
declare rule_fail = vc with noconstant('')
declare cnt = i4 with noconstant(0)
;declare ocnt = i4 with noconstant(0)
 
/**************************************************************
; START CODING
**************************************************************/
 
Record nozin(
	1 plist[*]
		2 facility = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 patient_name = vc
		2 admit_dt = vc
		2 unit = vc
		2 patient_type = vc
		2 order_dt = vc
		2 order_status = vc
		2 procedure = vc
		2 preop_or_postop = vc
		2 p_type = vc
		2 ccu_or_icu = vc
		2 ccu_icu_unit = vc
		2 rule_fired = vc
		2 rule_not_fired = vc
)
 
;-----------------------------------------------------------------------------------------
;Get surgery patients population
 
select into 'nl:'
o.encntr_id, o.order_id, o.hna_order_mnemonic, o.orig_order_dt_tm "@SHORTDATETIME"
, order_status = uar_get_code_display(o.order_status_cd)
from
	orders o
	, encounter e
	, surgical_case sc
 
plan e where e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
join o where o.encntr_id = e.encntr_id
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.active_ind = 1
	and o.catalog_cd in(art_art_knee_var,art_hip_var,art_knee_var,art_nav_hip_var,art_part_hip_ant_var,art_remov_hip_var
		,art_remov_knee_var,art_rep_inv_hip_var,art_rep_inv_knee_var,art_rep_part_hip_var,art_rep_tot_hip_var,art_rep_tot_hip_bi_var
		,art_rep_tot_knee_var,art_rep_tot_knee_bi_var,art_rep_tot_knee_nav_var,art_resur_hip_var,art_rev_arth_knee_var,art_rev_hip_var
		,art_rev_tot_knee_var,art_robo_part_knee_var,art_robo_tot_hip_var,art_robo_tot_knee_var,art_tot_hip_ant_var,art_uni_knee_var
		,c1_var,c2_var,c3_var,c4_var,c5_var,c6_var,c7_var,c8_var,c9_var,c10_var,c11_var,c12_var,c13_var,c14_var,c15_var,c16_var
		,c17_var,c18_var,c19_var,c20_var,c21_var,c22_var,c23_var,c24_var,c25_var,c26_var,c27_var,c28_var,c29_var,c30_var
		,c31_var,c32_var,c33_var,c34_var,c35_var,c36_var,c37_var,c38_var,c39_var,c40_var,c41_var,c42_var,c43_var,c44_var
		,c45_var,c46_var,c47_var,c48_var,c49_var,c50_var)
 
join sc where sc.encntr_id = e.encntr_id
	and sc.active_ind = 1
 
order by o.order_id
 
Head report
	icnt = 0
Head o.order_id
	cnt += 1
	call alterlist(nozin->plist, cnt)
	nozin->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	nozin->plist[cnt].personid = e.person_id
	nozin->plist[cnt].encntrid = e.encntr_id
	nozin->plist[cnt].orderid = o.order_id
	nozin->plist[cnt].patient_type = uar_get_code_display(e.encntr_type_cd)
	nozin->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	nozin->plist[cnt].procedure = o.hna_order_mnemonic
	nozin->plist[cnt].order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	nozin->plist[cnt].order_status = uar_get_code_display(o.order_status_cd)
	nozin->plist[cnt].preop_or_postop = 'Yes'
	nozin->plist[cnt].p_type = 'PreOp OR PostOp'
 
with nocounter
 
;---------------------------------------------------------------------------------------------------------------------------
 
;Get CCU/ICU patients population
select into 'nl:'
 
e.encntr_id, elh.loc_nurse_unit_cd, cv.display
, loc = uar_get_code_display(elh.loc_nurse_unit_cd), elh.beg_effective_dt_tm "@SHORTDATETIME"
, elh.end_effective_dt_tm "@SHORTDATETIME"
 
from
	encounter e
	, encntr_loc_hist elh
	, code_value cv
 
plan e where e.loc_facility_cd = $facility_list
	and e.active_ind = 1
	and e.encntr_type_cd in(309311.00, 309308.00, 309312.00, 19962820.00) ;Day Surgery,Inpatient,Observation,Outpatient in a Bed
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
	and(elh.beg_effective_dt_tm >= cnvtdatetime($start_datetime) and elh.end_effective_dt_tm <= cnvtdatetime($end_datetime))
 
join cv where cv.code_value = elh.loc_nurse_unit_cd
	and cv.code_set = 220
	and cv.active_ind = 1
	and cv.display in('FLMC CCU' , 'FSR CV ICU', 'FSR ICU', 'FSR NEURO ICU', 'LCMC ICU'
				, 'MHHS CCU', 'MMC CCU', 'MMC CVU', 'MMC ICU', 'PW C1', 'PW C2', 'RMC ICU')
 
order by elh.encntr_id
 
;Append
Head elh.encntr_id
	cnt+= 1
	call alterlist(nozin->plist, cnt)
Detail
	nozin->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	nozin->plist[cnt].ccu_or_icu = 'Yes'
	nozin->plist[cnt].p_type = 'CCU'
	nozin->plist[cnt].encntrid = e.encntr_id
	nozin->plist[cnt].personid = e.person_id
	nozin->plist[cnt].patient_type = uar_get_code_display(e.encntr_type_cd)
	nozin->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	nozin->plist[cnt].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 
with nocounter
 
;---------------------------------------------------------------------------------------------------------------------------
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
 
;---------------------------------------------------------------------------------------------------------------------------
 
;Rule section - fired
select into 'nl:'
 
 ent = nozin->plist[d.seq].encntrid
 ,ema.module_name
 , mad.encntr_id, mad.order_id
 , date_fired = format(ema.end_dt_tm, 'mm/dd/yy hh:mm;;q')
 , mad.logging, mad.module_audit_id
 
from (dummyt d WITH seq = value(size(nozin->plist,5)))
	, eks_module_audit_det mad
	, eks_module_audit ema
 
plan d
 
join mad where mad.encntr_id = nozin->plist[d.seq].encntrid
	and mad.template_type = 'A'
	and mad.template_return = 100
	;and mad.logging = outerjoin('*Added 1 order(s) to the request: <ethanol topical>*')
 
join ema where ema.rec_id = mad.module_audit_id
	and (CNVTUPPER(ema.module_name) = 'COV_PREOP_NOZIN_MED'
		or CNVTUPPER(ema.module_name) = 'COV_POSTOP_NOZIN_MED'
		or CNVTUPPER(ema.module_name) = 'COV_CCU_NOZIN_MED'
	     )
 
order by ent, mad.module_audit_id
 
Head mad.encntr_id
	rule = fillstring(500," ")
	icnt = 0
	ocnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(nozin->plist,5), mad.encntr_id ,nozin->plist[icnt].encntrid)
 
Head mad.module_audit_id
	rule = build2(trim(rule),'[' ,trim(ema.module_name),'-',date_fired,']',',')
 
Foot mad.encntr_id
	nozin->plist[idx].rule_fired = replace(trim(rule),",","",2)
 
with nocounter
 
;---------------------------------------------------------------------------------------------------------------------------
;Rule section - not fired - CCU
select into 'nl:'
 
ema.module_name , mad.encntr_id, mad.order_id, mad.template_name, mad.template_number, mad.template_return, mad.template_type
, task = uar_get_code_display(mad.task_assay_cd)
, date_fired = format(ema.end_dt_tm, 'mm/dd/yy hh:mm;;q')
, mad.logging, mad.module_audit_id
 
from (dummyt d WITH seq = value(size(nozin->plist,5)))
	, eks_module_audit_det mad
	, eks_module_audit ema
 
plan d
 
join mad where mad.encntr_id = nozin->plist[d.seq].encntrid
	and mad.template_type = 'L'
	and mad.template_return = 100
	and mad.template_name in('EKS_ORDERS_FIND_L', 'EKS_ORDERS_DETAIL_L')
	and mad.template_number in(6,7,8,9,10,11) ;without debug template - existing Nozin or Bactroban
 
join ema where ema.rec_id = mad.module_audit_id
	and CNVTUPPER(ema.module_name) = 'COV_CCU_NOZIN_MED'
 
order by mad.encntr_id, mad.module_audit_id, mad.template_number
 
Head mad.encntr_id
	icnt = 0
	ocnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(nozin->plist,5), mad.encntr_id ,nozin->plist[icnt].encntrid)

Head mad.module_audit_id
		rule_fail = fillstring(500," ")
Head mad.template_number
	if(mad.template_number = 7)
		rule_fail = build2(trim(rule_fail),'[','CCU - Existing Nozin Order',']',',')
	endif
	if(mad.template_number = 10)
		rule_fail = build2(trim(rule_fail),'[','CCU - Existing Bactroban Order',']',',')
	endif
 
Foot mad.encntr_id
	nozin->plist[idx].rule_not_fired = replace(trim(rule_fail),",","",2)
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------------------

;Rule section - not fired - PostOp
select into 'nl:'
 
ema.module_name , mad.encntr_id, mad.order_id, mad.template_name, mad.template_number, mad.template_return, mad.template_type
, task = uar_get_code_display(mad.task_assay_cd)
, date_fired = format(ema.end_dt_tm, 'mm/dd/yy hh:mm;;q')
, mad.logging, mad.module_audit_id
 
from (dummyt d WITH seq = value(size(nozin->plist,5)))
	, eks_module_audit_det mad
	, eks_module_audit ema
 
plan d
 
join mad where mad.encntr_id = nozin->plist[d.seq].encntrid
	and mad.template_type = 'L'
	and mad.template_return = 100
	and mad.template_name in('EKS_ORDERS_FIND_L', 'EKS_ORDERS_DETAIL_L')
	and mad.template_number in(6,7,8) ;without debug template - existing Bactroban
 
join ema where ema.rec_id = mad.module_audit_id
	and CNVTUPPER(ema.module_name) = 'COV_POSTOP_NOZIN_MED'
 
order by mad.encntr_id, mad.module_audit_id, mad.template_number
 
Head mad.encntr_id
	icnt = 0
	ocnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(nozin->plist,5), mad.encntr_id ,nozin->plist[icnt].encntrid)

Head mad.module_audit_id
		;rule_fail = fillstring(500," ")
		tmp = 0
Head mad.template_number
	if(mad.template_number = 6)
		rule_fail = build2(trim(rule_fail),'[','PostOP - Existing Bactroban Order',']',',')
	endif
 
Foot mad.encntr_id
	nozin->plist[idx].rule_not_fired = replace(trim(rule_fail),",","",2)
 
with nocounter
 
call echorecord(nozin)

;----------------------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = trim(substring(1, 10, nozin->plist[d1.seq].facility))
	,fin = trim(substring(1, 10, nozin->plist[d1.seq].fin))
	,patient_name = trim(substring(1, 50, nozin->plist[d1.seq].patient_name))
	,admit_dt = trim(substring(1, 30, nozin->plist[d1.seq].admit_dt))
	,patient_type = trim(substring(1, 100, nozin->plist[d1.seq].patient_type))
	,order_dt = trim(substring(1, 30, nozin->plist[d1.seq].order_dt))
	,order_status = trim(substring(1, 30, nozin->plist[d1.seq].order_status))
	,procedure_name = trim(substring(1, 300, nozin->plist[d1.seq].procedure))
	,type = trim(substring(1, 30, nozin->plist[d1.seq].p_type))
	,unit = trim(substring(1, 15, nozin->plist[d1.seq].unit))
	,rule_fired = trim(substring(1, 500, nozin->plist[d1.seq].rule_fired))
	,rule_not_fired = trim(substring(1, 500, nozin->plist[d1.seq].rule_not_fired))
 
from
	(dummyt   d1  with seq = size(nozin->plist, 5))
 
plan d1
 
with nocounter, separator=" ", format
 
end go
 

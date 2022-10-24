/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Oct'2022
	Solution:			BH
	Source file name:	      cov_bh_antipsychomed_audit.prg
	Object name:		cov_bh_antipsychomed_audit
	Request#:			12959
	Program purpose:	      
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date		Developer			Comment
-------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------*/

drop program cov_bh_antipsychomed_audit:dba go
create program cov_bh_antipsychomed_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list


/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare arip_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'ARIPiprazole')),protect
declare asen_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'asenapine')),protect
declare chlor_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'chlorproMAZINE')),protect
declare cloz_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'cloZAPine')),protect
declare flup_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'fluPHENAZine')),protect
declare halo_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'haloperidol')),protect
declare ilop_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'iloperidone')),protect
declare loxa_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'loxapine')),protect
declare lura_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'lurasidone')),protect
declare moli_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'molindone')),protect
declare olan_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'OLANZapine')),protect
declare olanf_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'OLANZapine-FLUoxetine')),protect
declare pali_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'paliperidone')),protect
declare perp_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'perphenazine')),protect
declare perpa_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'perphenazine-amitriptyline')),protect
declare pimo_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'pimozide')),protect
declare proch_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'prochlorperazine')),protect
declare queti_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'QUEtiapine')),protect
declare rispe_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'risperiDONE')),protect
declare thiord_var    = f8 with constant(uar_get_code_by("DISPLAY", 200, 'THIORIDazine')),protect
declare thiorx_var    = f8 with constant(uar_get_code_by("DISPLAY", 200, 'thiothixene')),protect
declare trif_var      = f8 with constant(uar_get_code_by("DISPLAY", 200, 'trifluoperazine')),protect
declare zipra_var     = f8 with constant(uar_get_code_by("DISPLAY", 200, 'ziprasidone')),protect

/*
select into $outdev
oc.catalog_cd

from order_catalog oc

plan oc where oc.catalog_cd in(
		arip_var  ,asen_var  ,chlor_var ,cloz_var  ,flup_var  ,halo_var  ,ilop_var  ,loxa_var  
		,lura_var  ,moli_var  ,olan_var ,olanf_var ,pali_var  ,perp_var  ,perpa_var ,pimo_var  
		,proch_var ,queti_var ,rispe_var ,thiord_var ,thiorx_var ,trif_var  ,zipra_var) 
	and oc.active_ind = 1


with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180

go to exitscript
*/

/**************************************************************
; DVDev Start Coding
**************************************************************/

Record pat(
	1 reccnt = i4
	1 plist[*]
		2 facility = vc
		2 personid = f8
		2 encntrid = f8
		2 fin = vc
		2 pat_name = vc
		2 disch_dt = vc
		2 olist[*]
			3 ord_cnt = i4
			3 orderid = f8
			3 med_name = vc
			3 order_dt = vc
		2 doc[*]			
			3 dta_used = vc
			3 dta_response = vc
			3 dta_dt = vc
	)
 
;----------------------------------------------------------------------------------------------------------

;Encounters
select into $outdev
 
e.encntr_id, e.person_id, e.encntr_type_cd 
, e.loc_facility_cd, ea.alias, p.name_full_formatted, e.disch_dt_tm
 
from encounter e,
	encntr_alias ea,
	person p
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.disch_dt_tm is not null
	and e.encntr_id != 0.0
	and e.active_ind = 1
	;and e.encntr_type_cd = 2555137051.00 ;Behavioral Health
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head report
 	cnt = 0
Head e.encntr_id
 	cnt += 1
 	pat->reccnt = cnt
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(pat->plist, cnt + 9)
	endif
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->plist[cnt].personid = e.person_id
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm ;;q')
	pat->plist[cnt].fin = ea.alias
	pat->plist[cnt].pat_name = p.name_full_formatted
	
Foot report
	stat = alterlist(pat->plist, cnt)
with nocounter

;--------------------------------------------------------------------------------------------------
;Orders

select into $outdev	
o.order_id, oc.catalog_cd, o.order_status_cd, o.orig_ord_as_flag, o.*

from (dummyt d with seq = pat->reccnt)
	, orders o
	, order_catalog oc
	
plan d

join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.active_ind = 1
	and not(o.order_status_cd in(2543.00, 2545.00)) ;Completed, Discontinued	
	and o.orig_ord_as_flag in(1, 2) ;Prescription/Discharge Order, Recorded / Home Meds

join oc where oc.catalog_cd = o.catalog_cd
	and oc.catalog_cd in(arip_var  ,asen_var  ,chlor_var ,cloz_var  ,flup_var  ,halo_var  ,ilop_var
		  	,loxa_var	,lura_var  ,moli_var  ,olan_var ,olanf_var ,pali_var  ,perp_var  ,perpa_var
			 ,pimo_var, proch_var ,queti_var ,rispe_var ,thiord_var ,thiorx_var ,trif_var  ,zipra_var) 
	and oc.active_ind = 1


order by o.encntr_id
	
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180

call echorecord(pat)


#exitscript

end
go




















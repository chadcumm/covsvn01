 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		OCT'21
	Solution:			Quality/Pharmacy
	Source file name:		cov_phq_flu_ekm_ops.prg
	Object name:		cov_phq_flu_ekm_ops
	Request#:			Seasonal
	Program purpose:	      CCL will call a rule and fire the Flu QM order for the existing patients in the units for the
					current flu season
	Executing from:		Manual one time - Every year
 	Special Notes:		Rule name : COV_QM_FLU_IMM_ORDER
 
;********************************************************************************/
 
 
drop program cov_phq_flu_ekm_ops:dba go
create program cov_phq_flu_ekm_ops:dba
 
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
 
 
/**************************************************************
; CCL SCRIPT STARTS HERE
**************************************************************/
 
/*Record EKSOPSRequest (
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
   )*/
 
 
;-------------------------------------------------------------------------
;Patient pool
 
select distinct into $outdev
p.name_full_formatted, e.encntr_id, e.reg_dt_tm, age = cnvtage(p.birth_dt_tm);, o.order_mnemonic, o.catalog_cd
 
from encounter e, person p, encntr_loc_hist elh, orders o
 
plan e where e.encntr_type_cd in(309308.00, 309312.00);Inpatient,Observation
	and e.loc_facility_cd in(2552503635.00);lcmc
 	;and e.loc_facility_cd in(21250403.00, 2552503613.00, 2552503635.00, 2552503639.00, 2552503645.00, 2552503649.00, 2552503653.00)
 	;and e.encntr_id in(125348735.00)      ;(125348410.00,125359334.00)
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
 
/*
Head report
	cnt = 0
	EKSOPSRequest->expert_trigger = "CALL_FLU_IMM_EKM_FROM_OPS"
 
Detail
	cnt += 1
	if(mod(cnt,10) = 1)
		stat = alterlist(EKSOPSRequest->qual, cnt + 9)
	endif
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].encntr_id = e.encntr_id
 
Foot report
stat = alterlist(EKSOPSRequest->qual, cnt)
 
with nocounter
 
call echorecord(EKSOPSRequest)
 
 
 
;**********************************************
; Call EXPERT_EVENT
;**********************************************
 /*
if (cnt > 0)
	set dparam = 0
      call srvRequest(dparam)
endif
*/
 
end
go
 
 
 

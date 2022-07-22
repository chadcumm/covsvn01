 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		June 2018
	Solution:			Population Health Quality
	Source file name:  	cov_phq_substance_cosign.prg
	Object name:		cov_phq_substance_cosign
	Request#:			1190
 
	Program purpose:	      Controlled Substance Supevising providers sign off audit report
	Executing from:		CCL/DA2/Population Health
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_phq_substance_cosign:DBA go
create program cov_phq_substance_cosign:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"         ;* Enter or select the printer or file name to send this report to.
	, "Start Registration Date/Time" = "SYSDATE"
	, "End  Registration Date/Time" = "SYSDATE"
	, "Location" = 0 

with OUTDEV, start_datetime, end_datetime, location
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare initcap()            = c100
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, 'FIN NBR')),protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
select distinct into $outdev
 
Location = uar_get_code_display(e.location_cd)
;, e.encntr_id
;, e.person_id
, Fin = ea.alias
, Reg_Date = e.reg_dt_tm
, Patient_name = initcap(p.name_full_formatted)
, Insurance = initcap(hp.plan_name)
, Fin_created_by = initcap(pr.name_full_formatted)
, Signoff_Requested = if(o.need_doctor_cosign_ind = 1) 'Yes' else 'No' endif
, Physician_Signoff = if(orv.reviewed_status_flag = 1) 'Yes' else 'No' endif
, Medicare_Met = ''
, Medicare_Phys_Avail = ''
, Controlled_Substance = ''
, Date_Time_Requested = format(orv1.updt_dt_tm, "mm/dd/yyyy hh:mm;;d")
, Supervising_physician = initcap(pr1.name_full_formatted)

/*
, o.order_mnemonic
, last_seq = o.last_action_sequence
, order_date = format(oa.order_dt_tm, "mm/dd/yyyy hh:mm;;d")
, supervisor = pr2.name_full_formatted
, supervisor_pos = uar_get_code_display(pr2.position_cd)
, cosign_reason = uar_get_code_display(orv.proxy_reason_cd)
*/
 
from  encounter e
	, encntr_alias ea
	, prsnl pr
	, prsnl pr1
	, prsnl pr2
	, person p
	, encntr_plan_reltn ep
	, health_plan hp
	, orders o
	, order_review orv 
	, order_review orv1 
	, order_action oa
 
plan e where e.location_cd = $location ;2553455457.00 ;Clinton Family Phys
	and e.active_ind = 1
     ;and e.reg_dt_tm between cnvtdatetime("22-MAY-2018 00:00:00") and cnvtdatetime("30-JUN-2018 23:59:00")
     and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)

join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
	;and p.name_full_formatted != "ZZ*"
 
join pr where pr.person_id = outerjoin(e.reg_prsnl_id)
	and pr.active_ind = outerjoin(1)
 
join ep where ep.person_id = outerjoin(e.person_id)
	and ep.active_ind = outerjoin(1)
	and ep.beg_effective_dt_tm <= outerjoin(sysdate)
	and ep.end_effective_dt_tm > outerjoin(sysdate)
 
join hp where hp.health_plan_id = outerjoin(ep.health_plan_id)
	and hp.active_ind = outerjoin(1)
	and hp.beg_effective_dt_tm <= outerjoin(sysdate)
	and hp.end_effective_dt_tm > outerjoin(sysdate)
 
join o where o.encntr_id = e.encntr_id
	and o.person_id = e.person_id
	and o.active_ind = 1

join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence	
 	and oa.order_status_cd = 2543 ;completed
 
join orv where orv.order_id = outerjoin(o.order_id)
	and orv.action_sequence = outerjoin(o.last_action_sequence)
	;and orv.reviewed_status_flag = outerjoin(1) ;accepted

join orv1 where orv1.order_id = outerjoin(o.order_id)
	and orv1.proxy_reason_cd = outerjoin(10496.00)	;Document to Sign
	and orv1.action_sequence = outerjoin(1) ;date requested = updat_date

join pr1 where pr1.person_id = outerjoin(orv.provider_id)
	and pr1.active_ind = outerjoin(1)
 
join pr2 where pr2.person_id = oa.supervising_provider_id
	and pr2.position_cd in(637903, 644372)
	and pr2.active_ind = 1

 
order by e.encntr_id
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxtime = 60
 
 
end
go
 

 /*
 o.need_doctor_cosign_ind - indicator on whether a doctor needs to cosign this order. 
  0 -  does not need doctor cosign,  
  1 -  needs doctor cosign,   
  2 - cosign notification is refused by doctor 
  
prsnl - position_cd

     637903.00	Nurse Practitioner
     644372.00	Physician Assistant

     2553454721.00	Clinton Family	FACILITY	Clinton Family Physicians
     2553455457.00	Clinton Family	AMBULATORY	Clinton Family Physicians
  
  */


 
/*
 
select * from prsnl where person_id = 12406031.00 ;goforth 

select * from order_action where order_provider_id = 12406031.00 ;goforth 

select o.encntr_id, e.location_cd
from order_action oa, orders o, encounter e
where e.encntr_id = o.encntr_id
and oa.order_id = o.order_id
and oa.order_provider_id = 12406031.00 ;goforth 

select  
 
 
;       10496.00	Document to Sign	SIGNDOC ; order_review, proxy_reason_cd, -    10496.00	Document to Sign
 
;           2.00	Doctor Cosign - review_type_flag
 
 
select * from tracking_item tr where tr.tracking_id = 13165667.00
 
select * from prsnl where person_id =    14570472.00
 
select * from encntr_alias where encntr_id = 110505906.00


 
 
*/

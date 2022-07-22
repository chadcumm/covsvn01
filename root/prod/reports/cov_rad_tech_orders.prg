/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Oct'2019
	Solution:			Radiology
	Source file name:	      cov_rad_tech_orders.prg
	Object name:		cov_rad_tech_orders
	Request#:			6525
	Program purpose:	      Radiology orders
	Executing from:		AdHoc
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_rad_tech_orders:dba go
create program cov_rad_tech_orders:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Report Type" = 1
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list, report_type
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

;Radiology Position 
declare clerk_var          = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETCLERK')),protect
declare clerk_pract_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETCLERKPRACTICEMANAGEMENT')),protect
declare critical_care_var  = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETCRITICALCARETECH')),protect
declare flim_lib_var       = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETFILMLIBRARIAN')),protect
declare nurse_var          = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETNURSE')),protect
declare technologist_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETRADIOLOGYTECHNOLOGIST')),protect
declare resident_var       = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETRESIDENT')),protect
declare supervisor_var     = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETSUPERVISOR')),protect
declare transcript_var     = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETTRANSCRIPTION')),protect
declare transport_var      = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'RADNETTRANSPORTER')),protect
declare sleep_clerk_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'SLEEPRADNETCLERK')),protect
declare sleep_supervi_var  = f8 with constant(uar_get_code_by("DISPLAY_KEY", 88, 'SLEEPRADNETSUPERVISOR')),protect

;Communication Type
declare direct_var         = f8 with constant(uar_get_code_by("DISPLAY", 6006, 'Direct')),protect
declare protocol_var       = f8 with constant(uar_get_code_by("DISPLAY", 6006, 'Per Protocol No Cosign')),protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record tech(
	1 rec_cnt = i4
	1 list[*]
		2 facility = vc
		2 fin = vc
		2 patient_name = vc
	 	2 encntrid = f8
	 	2 orderid = f8
	 	2 order_dt = vc
	 	2 admit_dt = vc
	 	2 disch_dt = vc
	 	2 pat_type = vc
	 	2 catalog_type = vc
	 	2 action_type = vc
	 	2 comm_type = vc
	 	2 order_type = vc
	 	2 order_mnemonic = vc
	 	2 action_dt = vc
	 	2 position = vc
	 	2 pos_cd = f8
	 	2 pr_name = vc
)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;Get orders - RadNet - Radiology Technologist
 
select into 'nl:'
 
fin = ea.alias
,admit_dat = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,disch_dat = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,cat_type = uar_get_code_display(o.catalog_type_cd)
,ordr_type = uar_get_code_display(o.med_order_type_cd)
,act_type = uar_get_code_display(oa.action_type_cd)
,act_dt = format(oa.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,com_type = uar_get_code_display(oa.communication_type_cd)
,tech = uar_get_code_display(pr.position_cd), prsnl_name = pr.name_full_formatted
,ordr_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
;,ordr_mnemonic = trim(o.order_mnemonic)
;,order_status = trim(uar_get_code_display(oa.order_status_cd)), oa.action_sequence, o.order_id
 
from 
	encounter e
	, orders o
	, order_action oa
	, prsnl pr
	, encntr_alias ea
	, person p
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	and e.encntr_id != 0.00
 
join o where o.encntr_id = e.encntr_id
	and o.active_ind = 1
 
join oa where oa.order_id = o.order_id
	and oa.action_type_cd = 2534.00 ;Order
	and oa.communication_type_cd in(direct_var, protocol_var)
 
join pr where pr.person_id = oa.action_personnel_id
	and pr.position_cd in(clerk_var, clerk_pract_var, critical_care_var, flim_lib_var, nurse_var, technologist_var
	    ,resident_var, supervisor_var, transcript_var, transport_var, sleep_clerk_var, sleep_supervi_var)
	
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by fin, oa.order_dt_tm, oa.order_id
 
Head report
	cnt = 0
Head oa.order_id
	cnt += 1
	call alterlist(tech->list, cnt)
Detail
	tech->list[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	tech->list[cnt].fin = ea.alias
	tech->list[cnt].orderid = o.order_id
	tech->list[cnt].action_dt = act_dt
	tech->list[cnt].action_type = act_type
	tech->list[cnt].admit_dt = admit_dat
	tech->list[cnt].disch_dt = disch_dat
	tech->list[cnt].catalog_type = cat_type
	tech->list[cnt].comm_type = com_type
	tech->list[cnt].order_dt = ordr_dt
	tech->list[cnt].order_mnemonic = o.order_mnemonic
	tech->list[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	tech->list[cnt].order_type = ordr_type
	tech->list[cnt].patient_name = p.name_full_formatted
	tech->list[cnt].pos_cd = pr.position_cd
	tech->list[cnt].position = uar_get_code_display(pr.position_cd)
	tech->list[cnt].pr_name = pr.name_full_formatted
 
with nocounter, time = 300
 
call echorecord(tech)
 
;---------------------------------------------------------------------------------------------------

if($report_type = 1);Orders entered by Rad Techs. 

select into $outdev
 
	facility = substring(1, 30, tech->list[d1.seq].facility)
	,fin = substring(1, 30, tech->list[d1.seq].fin)
	,patient_name = substring(1, 50, tech->list[d1.seq].patient_name)
	,admit_dt = substring(1, 30, tech->list[d1.seq].admit_dt)
	,disch_dt = substring(1, 30, tech->list[d1.seq].disch_dt)
	,patient_type = substring(1, 50, tech->list[d1.seq].pat_type)
	,order_type = substring(1, 50, tech->list[d1.seq].order_type)
	,order_dt = substring(1, 30, tech->list[d1.seq].order_dt)
	,catalog_type = substring(1, 300, tech->list[d1.seq].catalog_type)
	,communication_type = substring(1, 300, tech->list[d1.seq].comm_type)
	,action_type = substring(1, 100, tech->list[d1.seq].action_type)
	,action_dt = substring(1, 30, tech->list[d1.seq].action_dt)
	,position = substring(1, 100, tech->list[d1.seq].position)
	,prsnl_name = substring(1, 50, tech->list[d1.seq].pr_name)
	,order_name = substring(1, 300, tech->list[d1.seq].order_mnemonic)
 
from	(dummyt   d1  with seq = size(tech->list, 5))
 
plan d1 where tech->list[d1.seq].pos_cd = technologist_var
 
order by facility, position, fin, order_dt
 
with nocounter, separator=" ", format

else ;Non-physician/NP/PA entered contrast orders

select into $outdev
 
	facility = substring(1, 30, tech->list[d1.seq].facility)
	,fin = substring(1, 30, tech->list[d1.seq].fin)
	,patient_name = substring(1, 50, tech->list[d1.seq].patient_name)
	,admit_dt = substring(1, 30, tech->list[d1.seq].admit_dt)
	,disch_dt = substring(1, 30, tech->list[d1.seq].disch_dt)
	,patient_type = substring(1, 50, tech->list[d1.seq].pat_type)
	,order_type = substring(1, 50, tech->list[d1.seq].order_type)
	,order_dt = substring(1, 30, tech->list[d1.seq].order_dt)
	,catalog_type = substring(1, 300, tech->list[d1.seq].catalog_type)
	,communication_type = substring(1, 300, tech->list[d1.seq].comm_type)
	,action_type = substring(1, 100, tech->list[d1.seq].action_type)
	,action_dt = substring(1, 30, tech->list[d1.seq].action_dt)
	,position = substring(1, 100, tech->list[d1.seq].position)
	,prsnl_name = substring(1, 50, tech->list[d1.seq].pr_name)
	,order_name = substring(1, 300, tech->list[d1.seq].order_mnemonic)
 
from	(dummyt   d1  with seq = size(tech->list, 5))
 
plan d1 where tech->list[d1.seq].pos_cd in(clerk_var, clerk_pract_var, critical_care_var, flim_lib_var, nurse_var
	    	,resident_var, supervisor_var, transcript_var, transport_var, sleep_clerk_var, sleep_supervi_var)
	  and (cnvtlower(tech->list[d1.seq].order_mnemonic) = '*w/ contrast*'
	  		OR cnvtlower(tech->list[d1.seq].order_mnemonic) = '*w/ + *contrast*')	
	  
order by facility, position, fin, order_dt
 
with nocounter, separator=" ", format

endif; report_type

end
go
 
 
 
 
 
 
 
 
 
 
 

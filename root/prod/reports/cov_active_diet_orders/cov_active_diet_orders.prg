 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		May'2019
	Solution:			Quality
	Source file name:	      cov_active_diet_orders.prg
	Object name:		cov_active_diet_orders
	Request#:			4711
	Program purpose:	      Adhoc for troubleshooting active diet orders
	Executing from:		DA2
 	Special Notes:          
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/

drop program cov_active_diet_orders:dba go
create program cov_active_diet_orders:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, fin

select distinct into $outdev

fin = trim(ea.alias)
, patient_name = trim(p.name_full_formatted)
, order_mnemonic = trim(o.order_mnemonic)
, order_detail = trim(o.order_detail_display_line)
, order_date = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, start_date = format(o.current_start_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, stop_date = format(o.projected_stop_dt_tm, 'mm/dd/yyyy hh:mm;;d')

from  encntr_alias ea, encounter e, orders o, person p

plan ea where ea.alias = $fin
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
	
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
	and e.encntr_status_cd = 854.00 ;Active

join o where o.encntr_id = e.encntr_id
	and o.person_id = e.person_id
	and o.active_ind = 1
	and o.activity_type_cd in(681598.00, 681643.00, 636696.00);diet,tube,supplement
	and o.active_status_cd = 188
	and o.active_ind = 1
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
	and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
	
join p where p.person_id = e.person_id
	and p.active_ind = 1	

order by e.encntr_id, order_date, o.order_id

with nocounter, separator=" ", format


end
go

/*

select distinct o.encntr_id, o.hna_order_mnemonic, o.orig_order_dt_tm, o.clinical_display_line, o.activity_type_cd
   	, o.current_start_dt_tm, o.projected_stop_dt_tm, o.order_id
   	,ordext = dense_rank() over (partition by o.encntr_id, o.order_id order by o.last_action_sequence desc)
	from orders o, encounter e
	where o.encntr_id = e.encntr_id
	and e.loc_facility_cd = 2552503645.00 ;pw
	and e.disch_dt_tm is null
	and e.loc_room_cd != 0.0
	and e.loc_bed_cd != 0.0
	and e.encntr_status_cd = 854.00 ;Active
	and e.active_ind = 1
	and o.activity_type_cd in(681598.00, 681643.00, 636696.00);diet,tube,supplement
	and o.active_status_cd = 188
	and o.active_ind = 1
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
	and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
	order by e.encntr_id, o.orig_order_dt_tm
	
 
*/
















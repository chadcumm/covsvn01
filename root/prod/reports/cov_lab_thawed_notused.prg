 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		June 2019
	Solution:			Lab/Quality
	Source file name:	      cov_lab_thawed_notused.prg
	Object name:		cov_lab_thawed_notused
	Request#:			1048
	Program purpose:
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_lab_thawed_notused :dba GO
CREATE PROGRAM cov_lab_thawed_notused :dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Owner Area Code" = 0
	, "Inventory Area Code" = 0
 
with OUTDEV, start_datetime, end_datetime, owner_area, inventory_area
 
;------------------------------------------------------
	;Modified new version - 2
;------------------------------------------------------
declare assigned_var   = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Assigned')),product
declare dispensed_var  = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Dispensed')),product
declare crossmatch_var = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Crossmatched')),product
declare transfused_var = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Transfused')),product
 
RECORD output(
   1 list[*]
     2 owner_area = vc ;prompt
     2 inventory_area = vc ;prompt
     2 personid = f8
     2 encntrid = f8
     2 patient_name = vc
     2 fin = vc
     2 olist[*]
	     3 productid = f8
	     3 product_eventid = f8
	     3 product_type = vc
	     3 product_category = vc
	     3 med_service = vc
	     3 order_provider_name = vc
	     3 bb_result_id = f8
	     3 crossmatch_cnt = i4
	     3 crossmatch_dt = vc
	     3 transfuse_cnt = i4
	     3 transfuse_dt = vc
	     3 assigned_cnt = i4
	     3 assigned_dt = vc
	     3 dispense_cnt = i4
	     3 dispense_dt = vc
 )
 
;------------------------------------------------------------------------------------------------------------------
 
select into 'nl:'
 
 e.encntr_id, pe.product_event_id, pe.product_id, pe.order_id, p.active_ind, pe_act = pe.active_ind
, event_type = uar_get_code_display(pe.event_type_cd)
, owner_area_disp = uar_get_code_display(p.cur_owner_area_cd)
, inventory_area_disp = uar_get_code_display(p.cur_inv_area_cd)
, product_disp = uar_get_code_display(p.product_cd)
, product_cat_disp = uar_get_code_display(p.product_cat_cd)
, medical_service = uar_get_code_display(e.med_service_cd)
, event_dt = format(pe.event_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from
product_event pe
,product p
,encounter e
,(
	(select distinct e.encntr_id, pe.product_id, pe.product_event_id
		from product_event pe, product p, encounter e
		where pe.product_id = p.product_id
		and e.encntr_id = pe.encntr_id
		and pe.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime);get actions in the date range
		and pe.event_type_cd in(1429,1436,1448)
		and p.cur_owner_area_cd = $owner_area ;2555140621.00 ;PWMC BB Owner Area
    		and p.cur_inv_area_cd = $inventory_area ;2555140629.00 ;PWMC BB Inv Area
		with sqltype('f8', 'f8', 'f8')
	)i
)
 
plan i
 
join pe where pe.encntr_id = i.encntr_id
	;and pe.product_id = i.product_id ;use product_id again to search thru the whole db to get missing actions based on dt range
	and pe.event_type_cd in(1429,1436,1448,1433)
 
join p where p.product_id = pe.product_id
 
join e where e.encntr_id = pe.encntr_id
 
order by pe.encntr_id, pe.product_id, pe.product_event_id
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	call alterlist(output->list, cnt)
	output->list[cnt].personid = e.person_id
	output->list[cnt].encntrid = e.encntr_id
	output->list[cnt].owner_area = trim(owner_area_disp)
	output->list[cnt].inventory_area = trim(inventory_area_disp)
	ocnt = 0
 
Head pe.product_id
	ocnt += 1
	call alterlist(output->list[cnt].olist, ocnt)
Detail
	output->list[cnt].olist[ocnt].productid = pe.product_id
	output->list[cnt].olist[ocnt].product_eventid = pe.product_event_id
	output->list[cnt].olist[ocnt].product_type = product_disp
	output->list[cnt].olist[ocnt].product_category = product_cat_disp
 	output->list[cnt].olist[ocnt].med_service = medical_service
	case(pe.event_type_cd)
		of crossmatch_var:
			output->list[cnt].olist[ocnt].crossmatch_cnt = 1
			output->list[cnt].olist[ocnt].crossmatch_dt = event_dt
		of assigned_var:
			output->list[cnt].olist[ocnt].assigned_cnt = 1
			output->list[cnt].olist[ocnt].assigned_dt = event_dt
		of dispensed_var:
			output->list[cnt].olist[ocnt].dispense_cnt = 1
			output->list[cnt].olist[ocnt].dispense_dt = event_dt
		of transfused_var:
			output->list[cnt].olist[ocnt].transfuse_cnt = 1
			output->list[cnt].olist[ocnt].transfuse_dt = event_dt
	endcase
 
Foot pe.product_id
	call alterlist(output->list[cnt].olist, ocnt)
 
Foot e.encntr_id
	call alterlist(output->list[cnt], cnt)
 
with nocounter
;---------------------------------------------------------------------------------------
;Get order provider info
select into 'nl:'
 
enc = output->list[d1.seq].encntrid
 
from (dummyt   d1  with seq = size(output->list, 5))
	, (dummyt   d2  with seq = 1)
	, product_event pe
	, orders o
	, prsnl pr
 
plan d1 where maxrec(d2, size(output->list[d1.seq].olist, 5))
join d2
 
 
join pe where pe.encntr_id = output->list[d1.seq].encntrid
	and pe.product_id = output->list[d1.seq].olist[d2.seq].productid
	and pe.order_id != 0.00
 
join o where o.order_id = pe.order_id
 
join pr where pr.person_id = o.last_update_provider_id
	and o.last_update_provider_id != 0.00
 
order by enc, pe.product_id
 
Detail
	output->list[d1.seq].olist[d2.seq].order_provider_name = pr.name_full_formatted
 
with nocounter
 
;----------------------------------------------------------------------------------------
;Get patient demographic
 
select distinct into 'nl:'
 
from (dummyt d WITH seq = size(output->list,5))
	, encntr_alias ea
	, person p
 
plan d
 
join ea where ea.encntr_id = output->list[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
 
join p where p.person_id = output->list[d.seq].personid
 
Detail
	output->list[d.seq].fin = ea.alias
	output->list[d.seq].patient_name = trim(p.name_full_formatted)
 
with nocounter
 
call echorecord(output)
 
;----------------------------------------------------------------------------------------
 
SELECT DISTINCT INTO $OUTDEV
 
	OWNER_AREA = trim(SUBSTRING(1, 50, OUTPUT->list[D1.SEQ].owner_area))
	, INVENTORY_AREA = trim(SUBSTRING(1, 50, OUTPUT->list[D1.SEQ].inventory_area))
	, PATIENT_NAME = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].patient_name)
	, FIN = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].fin)
	, PRODUCT_CATEGORY = SUBSTRING(1, 100, OUTPUT->list[D1.SEQ].olist[D2.SEQ].product_category)
	, PRODUCT_id = OUTPUT->list[D1.SEQ].olist[D2.SEQ].productid
	, PRODUCT_TYPE = SUBSTRING(1, 100, OUTPUT->list[D1.SEQ].olist[D2.SEQ].product_type)
	, CROSSMATCH_CNT = OUTPUT->list[D1.SEQ].olist[D2.SEQ].crossmatch_cnt
	, CROSSMATCH_DT = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].olist[D2.SEQ].crossmatch_dt)
	, ASSIGNED_CNT = OUTPUT->list[D1.SEQ].olist[D2.SEQ].assigned_cnt
	, ASSIGNED_DT = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].olist[D2.SEQ].assigned_dt)
	, DISPENSE_CNT = OUTPUT->list[D1.SEQ].olist[D2.SEQ].dispense_cnt
	, DISPENSE_DT = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].olist[D2.SEQ].dispense_dt)
	, TRANSFUSE_CNT = OUTPUT->list[D1.SEQ].olist[D2.SEQ].transfuse_cnt
	, TRANSFUSE_DT = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].olist[D2.SEQ].transfuse_dt)
	, ORDER_PROVIDER_NAME = SUBSTRING(1, 50, OUTPUT->list[D1.SEQ].olist[D2.SEQ].order_provider_name)
	, MED_SERVICE = SUBSTRING(1, 100, OUTPUT->list[D1.SEQ].olist[D2.SEQ].med_service)
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(OUTPUT->list, 5))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1 WHERE MAXREC(D2, SIZE(OUTPUT->list[D1.SEQ].olist, 5))
JOIN D2
 
ORDER BY
	FIN, PRODUCT_ID DESC
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
end go
 
/* 
; New version - ;disposed and destroyed included

select distinct into $outdev
 
pe.product_id, pe.product_event_id, pe.order_id
, event_type = trim(uar_get_code_display(pe.event_type_cd))
, owner_area_disp = trim(uar_get_code_display(p.cur_owner_area_cd))
, inventory_area_disp = trim(uar_get_code_display(p.cur_inv_area_cd))
, product_disp = trim(uar_get_code_display(p.product_cd))
, product_cat_disp = trim(uar_get_code_display(p.product_cat_cd))
, event_dt = format(pe.event_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from product_event pe, product p
 
plan pe where pe.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and pe.event_type_cd in(1429,1436,1448,1433,1434,1437);disposed and destroyed included
 
join p where p.product_id = pe.product_id
	and p.cur_owner_area_cd = $owner_area ;2555140621.00 ;PWMC BB Owner Area
    	and p.cur_inv_area_cd = $inventory_area ;2555140629.00 ;PWMC BB Inv Area
 
order by pe.product_id, pe.product_event_id
 
with nocounter, separator=" ", format, time = 120
 
end go
*/ 
 
 
 
 
 
 
 /***
 
       1429.00	Assigned
       1433.00	Crossmatched
       1436.00	Dispensed
       1447.00	Transferred
 
;------------------------------------------------------------------------------------------------------------------
;Qualification - Crossmatch
 
select into 'nl:'
 
p.product_id, pe.product_event_id, pe.bb_result_id
, owner_area_disp = uar_get_code_display(p.cur_owner_area_cd)
, inventory_area_disp = uar_get_code_display(p.cur_inv_area_cd)
, product_disp = uar_get_code_display(p.product_cd)
, product_cat_disp = uar_get_code_display(p.product_cat_cd)
, physician = trim(pr.name_full_formatted)
, medical_service = uar_get_code_display(e.med_service_cd)
 
from crossmatch cm
    ,product_event pe
    ,product p
    ,orders o
    ,prsnl pr
    ,encounter e
 
plan pe where pe.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and pe.event_type_cd = crossmatch_var
 
join cm where cm.product_id = pe.product_id
	and cm.product_event_id = pe.product_event_id
	;where cm.crossmatch_exp_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
join p where p.product_id = pe.product_id
    and p.cur_owner_area_cd = 2555140621.00 ;PWMC BB Owner Area
    and p.cur_inv_area_cd = 2555140629.00 ;PWMC BB Inv Area
 
join o where o.order_id = pe.order_id
 
join e where e.encntr_id = o.encntr_id
 
join pr where pr.person_id = o.last_update_provider_id
 
order by pe.product_id, pe.product_event_id
 
Head report
	cnt = 0
	cm_tot = 0
	call alterlist(output->list, 10)
 
Head pe.product_event_id
	cnt += 1
	call alterlist(output->list, cnt)
	output->list[cnt].productid = pe.product_id
	output->list[cnt].product_eventid = pe.product_event_id
	output->list[cnt].owner_area = owner_area_disp
	output->list[cnt].inventory_area = inventory_area_disp
	output->list[cnt].product_type = product_disp
	output->list[cnt].product_category = product_cat_disp
 	output->list[cnt].med_service = medical_service
 	output->list[cnt].crossmatch_cnt = 1
 	output->list[cnt].order_provider_name = trim(pr.name_full_formatted)
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
 
call echorecord(output)
 
 
;with nocounter, separator=" ", format
 
end go

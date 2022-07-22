 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Apr'2019
	Solution:			Quality
	Source file name:	      cov_phq_CPOE_validation.prg
	Object name:		cov_phq_CPOE_validation
	Request#:			4870
	Program purpose:	      CPOE communication type validation
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_CPOE_validation:dba go
create program cov_phq_CPOE_validation:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare action_seq_var = i4 with noconstant(0)
declare inpatient_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
 
Record orders(
	1 rec_cnt = i4
	1 olist[*]
		2 facility = vc
		2 fin = vc
		2 patient_name = vc
	 	2 encntrid = f8
	 	2 orderid = f8
	 	2 order_dt = vc
	 	2 admit_dt = vc
	 	2 disch_dt = vc
	 	2 comm_type_cd = f8
	 	2 comm_type = vc
	 	2 order_status = vc
	 	2 order_type = vc
	 	2 order_mnemonic = vc
	 	2 action_seq = i4
	 	2 action_dt = vc
	 	2 contributing_system = vc
)
 
Record tot(
	1 list[*]
		2 facility = vc
		2 comm_type = vc
		2 order_tot = i4
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;Get orders
 
select into $outdev
 
fin = i.alias, patient_name = trim(i.name_full_formatted)
,catalog_type = trim(uar_get_code_display(i.catalog_type_cd)) 
,order_type = trim(uar_get_code_display(i.med_order_type_cd))
,order_status = trim(uar_get_code_display(i.order_status_cd))
,i.action_sequence, action_type = trim(uar_get_code_display(i.action_type_cd))
,action_dt = format(i.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,communication_type = trim(uar_get_code_display(i.communication_type_cd))
,i.denominator, i.numerator
,order_dt = format(i.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,order_mnemonic = trim(i.order_mnemonic), i.order_id
,admit_dt = format(i.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,disch_dt = format(i.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,patient_type = trim(uar_get_code_display(i.encntr_type_cd))
 
from(
(select distinct
	ea.alias, p.name_full_formatted, e.reg_dt_tm, e.disch_dt_tm, e.encntr_type_cd, o.order_id,o.catalog_cd, o.catalog_type_cd
	;, e.encntr_id, e.person_id
	,o.med_order_type_cd, oa.order_status_cd, oa.action_sequence, oa.action_type_cd, oa.action_dt_tm, oa.communication_type_cd
	,o.orig_order_dt_tm, o.order_mnemonic
	, numerator = evaluate2(
		if(oa.communication_type_cd     = 2560) 1
		elseif(oa.communication_type_cd = 2561) 1
		elseif(oa.communication_type_cd = 2562) 1
		elseif(oa.communication_type_cd = 2576706321) 1
		elseif(oa.communication_type_cd = 2553560097) 1
		elseif(oa.communication_type_cd = 2553560089) 1
		elseif(oa.communication_type_cd = 20094437.00) 1
		else 0 endif)
 
	, denominator = evaluate2(
		if(oa.communication_type_cd     = 2560) 1
		elseif(oa.communication_type_cd = 2561) 1
		elseif(oa.communication_type_cd = 2562) 1
		elseif(oa.communication_type_cd = 2576706321) 1
		elseif(oa.communication_type_cd = 2553560097) 1
		elseif(oa.communication_type_cd = 2553560089) 1
		elseif(oa.communication_type_cd = 20094437.00) 1
		elseif(oa.communication_type_cd = 54416801.00) 1
		else 0 endif)
 
from encounter e, orders o, order_action oa, encntr_alias ea, person p
	where e.loc_facility_cd = $acute_facility_list
	;and e.encntr_type_cd = inpatient_var ;only for Leapfrog
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.template_order_flag != 4
	;and o.med_order_type_cd != 0.00
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.catalog_cd not in(
	2552703197, 47583263, 165382375, 2561119727, 165382565, 165382675, 165382689, 2553018573, 2553018583, 2553018603, 2553018323, 165382661,
	165382589, 2554793611, 165382707, 165382727, 21267059, 21267063, 21267067, 2549885359, 2575842575, 2575843071, 2575842529, 25469175,
	2557642447, 2561931299, 2575805731, 2561930481, 2557648183, 2561955475,	25471495, 25471519, 24591363, 2549886971, 2575841511, 2575960697,
	25473521, 2549888743, 2552610353, 2563538799, 25463731, 2563394971, 2575841071, 165375843, 165376027,21266999, 2579380153,
	165381811, 108665841, 108649991, 108635085, 34998213, 2578713535, 2557870887, 2557870909, 2575842903, 2557731363, 2560158023, 24300177,
	24300189, 24300186, 24300168,	24300192, 24300216, 24300198, 2549890863, 44933843, 24300195, 25474617, 2557727517, 2557648751, 161252229,
	2557666171, 24592231, 2554793823, 56622607, 2557728325, 257079695, 2557618729, 257618317, 165381905, 165381929, 165381947, 165381967)
 	and oa.order_id = o.order_id
	and oa.action_sequence = 1
	and oa.communication_type_cd in(19468404,20094437,681544,54416801,2576706321,2553560097,2560,2553560089,2561,2562)
 	and ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 	and p.person_id = e.person_id
	and p.active_ind = 1
	with sqltype('vc','vc','dq8','dq8','f8','f8','f8','f8','f8','f8','i2','f8','dq8','f8','dq8','vc','i2','i2')
	)i
)
 
order by patient_name, communication_type, order_mnemonic, i.order_id
 
with nocounter, separator=" ", format
 
end go
 
 
/***********************
select into $outdev
 
fin = ea.alias, patient_name = trim(p.name_full_formatted)
,admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,o.order_id, order_type = trim(uar_get_code_display(o.med_order_type_cd))
,order_status = trim(uar_get_code_display(oa.order_status_cd))
,oa.action_sequence, action_type = trim(uar_get_code_display(oa.action_type_cd))
,action_dt = format(oa.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,communication_type = trim(uar_get_code_display(oa.communication_type_cd))
,order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q') , order_mnemonic = trim(o.order_mnemonic)
 
from
	encounter e
	,orders o
	,order_action oa
	,encntr_alias ea
	,person p
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.loc_facility_cd = inpatient_var
	and e.active_ind = 1
	and e.encntr_id != 0.00
 
join o where o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;and o.med_order_type_cd = 10915.00 ;Med
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = 1
	;and oa.order_status_cd in(2543.00, 2550.00, 2545.00) ;Completed, Ordered, Discontinued
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by oa.order_id
 
Head report
	cnt = 0
Head oa.order_id
 	cnt = cnt + 1
 	orders->rec_cnt = cnt
	call alterlist(orders->olist, cnt)
Detail
	orders->olist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	orders->olist[cnt].fin = ea.alias
 	orders->olist[cnt].encntrid = e.encntr_id
	orders->olist[cnt].orderid = oa.order_id
	orders->olist[cnt].patient_name = trim(p.name_full_formatted)
	orders->olist[cnt].order_mnemonic = trim(o.order_mnemonic)
	orders->olist[cnt].order_status = uar_get_code_display(oa.order_status_cd)
 
with nocounter
 
 
fin = ea.alias, patient_name = trim(p.name_full_formatted)
,admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,o.order_id, order_type = trim(uar_get_code_display(o.med_order_type_cd))
,order_status = trim(uar_get_code_display(oa.order_status_cd))
,oa.action_sequence, action_type = trim(uar_get_code_display(oa.action_type_cd))
,action_dt = format(oa.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,communication_type = trim(uar_get_code_display(oa.communication_type_cd))
,order_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;q') , order_mnemonic = trim(o.order_mnemonic)
 
 
 
 
;---------------------------------------------------------------------------------------------------
;get action sequence
 
select into 'nl:'
 
oa.order_id, comm = uar_get_code_display(oa.communication_type_cd)
,oa.order_status_cd
 
from (dummyt d with seq = size(orders->olist, 5))
	,order_action oa
 
plan d
 
join oa where oa.order_id = orders->olist[d.seq].orderid
	and oa.action_sequence = 1
 
order by oa.order_id
 
;with nocounter, separator=" ", format
 
Head oa.order_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(orders->olist, 5) ,oa.order_id ,orders->olist[cnt].orderid)
Detail
	orders->olist[idx].communication_type = uar_get_code_display(oa.communication_type_cd)
	orders->olist[idx].action_seq = oa.action_sequence
	orders->olist[idx].action_dt = format(oa.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	orders->olist[idx].comm_type_cd = oa.communication_type_cd
	orders->olist[idx].contributing_system = uar_get_code_display(oa.contributor_system_cd)
 
with nocounter
 
;---------------------------------------------------------------------------------------------------
;Change action sequence
 
select into 'nl:'
 
from (dummyt d with seq = size(orders->olist, 5))
	,order_action oa
 
plan d
 
join oa where oa.order_id = orders->olist[d.seq].orderid
	and orders->olist[d.seq].comm_type_cd = 22543438.00 ;proposed
	and oa.action_sequence = 2
 
order by oa.order_id
 
Head oa.order_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(orders->olist, 5) ,oa.order_id ,orders->olist[cnt].orderid)
Detail
	orders->olist[idx].action_seq = oa.action_sequence
	orders->olist[idx].comm_type_cd = oa.communication_type_cd
	orders->olist[idx].comm_type = uar_get_code_display(oa.communication_type_cd)
 	orders->olist[idx].contributing_system = uar_get_code_display(oa.contributor_system_cd)
with nocounter
 
;-----------------------------------------------------------------------------------------
;Get totals
select into 'nl:' ;$outdev
 
ord = orders->olist[d.seq].orderid
,com_type = trim(substring(1, 100, orders->olist[d.seq].comm_type))
 
from (dummyt d with seq = size(orders->olist, 5))
 
plan d
 
order by com_type, ord
 
Head report
	cnt = 0
 
Head com_type
	cnt += 1
 	tcnt = 0
 	call alterlist(tot->list, cnt)
 	tot->list[cnt].facility = uar_get_code_display($acute_facility_list)
	tot->list[cnt].comm_type = com_type
 
Head ord
	tcnt += 1
 
Foot com_type
	tot->list[cnt].order_tot = tcnt
with nocounter
 
call echorecord(tot)
;-----------------------------------------------------------------------------------------
;Display results
 
If($repo_type = 1)
 
  select into $outdev
  	 facility = trim(substring(1, 30, orders->olist[d1.seq].facility))
	,fin = substring(1, 30, orders->olist[d1.seq].fin)
	,patient_name = trim(substring(1, 50, orders->olist[d1.seq].patient_name))
	,orderid = orders->olist[d1.seq].orderid
	,communication_type = trim(substring(1, 300, orders->olist[d1.seq].comm_type))
	,contributing_system = trim(substring(1, 100, orders->olist[d1.seq].contributing_system))
	,order_status = substring(1, 30, orders->olist[d1.seq].order_status)
	,action_seqqence = orders->olist[d1.seq].action_seq
	,action_date = substring(1, 30, orders->olist[d1.seq].action_dt)
	,order_mnemonic = trim(substring(1, 300, orders->olist[d1.seq].order_mnemonic))
from
	(dummyt   d1  with seq = size(orders->olist, 5))
 
plan d1
 
order by facility, patient_name
 
with nocounter, separator=" ", format
 
Else
 
select into $outdev
 
	facility = trim(substring(1, 30, tot->list[d1.seq].facility))
	,communication_type = trim(substring(1, 300, tot->list[d1.seq].comm_type))
	,total = tot->list[d1.seq].order_tot
from
	(dummyt d1 with seq = size(tot->list, 5))
 
plan d1
 
order by communication_type
 
with nocounter, separator=" ", format
 
Endif
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
/*Communication Types
 
 2553560081.00	Contingency Electronic Order No Cosign
   19468404.00	Cosign Required
     680281.00	Discern Expert
 2553560105.00	Discont Transition Care Order No Cosign
    4370401.00	Electronic
     637915.00	ESI Default
   20094437.00	Initiate Planned Orders No Cosign
     681544.00	No Cosign Required
   54416801.00	Written Paper Order/Fax No Cosign
 2576706321.00	Per Nutrition Policy No Cosign
 2553560097.00	Per Protocol No Cosign
 2560667137.00	Per P&T Policy No Cosign
       2560.00	Telephone Read Back/Verified Cosign
   22543438.00	Proposed
 2553560089.00	Standing Order Cosign
       2561.00	Verbal Read Back/Verified Cosign
       2562.00	Direct
*/
 
 
 
 
 

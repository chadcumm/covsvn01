 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Apr'2022
	Solution:			Quality
	Source file name:	      cov_phq_leapcpoe_scorecard_det.prg
	Object name:		cov_phq_leapcpoe_scorecard_det
	Request#:			12763
	Program purpose:	      CPOE Leapfrog Scorecard details
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
-------------------------------------------------------------------------------
 
04/27/22    Geetha    CR# 12763    Initial release
 
******************************************************************************/
 
drop program cov_phq_leapcpoe_scorecard_det:DBA go
create program cov_phq_leapcpoe_scorecard_det:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
;-----------------------------------------------------------------------
/**************************************************************
; Variable Declaration
**************************************************************/
 
declare action_seq_var = i4 with noconstant(0)
declare inpatient_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
 
declare initcap() = c100
declare username = vc with protect
declare getmonth(imonth = i4) = null
declare month_var = vc
declare sm = i2
declare em = i2
declare mcount = i2
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record olist(
	1 rec_cnt = i4
	1 list[*]
		2 facility = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_name = vc
		2 fin = vc
		2 pat_type = vc
		2 nunit = vc
		2 order_dt = vc
		2 comm_type = vc
		2 prsnlid = f8
		2 prsnl_name = vc
		2 orderid = f8
		2 ord_name = vc
		2 nume = i4
		2 denome = i4
)
 
;---------------------------------------------------------------------------------------
;Meds ordered
 
select into $outdev
fac = uar_get_code_display(e.loc_facility_cd), e.encntr_id, e.person_id
,unit = uar_get_code_display(elh.loc_nurse_unit_cd), ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm;;d')
, com_type = uar_get_code_display(oa.communication_type_cd), oa.order_provider_id, o.order_id
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
 
from encounter e
	,orders o
	,(left join encntr_loc_hist elh on elh.encntr_id = o.encntr_id
		and o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
	,order_action oa
 
plan e where e.loc_facility_cd = $facility_list
	and e.encntr_type_cd = inpatient_var
	and e.active_ind = 1
	and e.encntr_id != 0.00
 
join o where o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.med_order_type_cd != 0.00
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.catalog_cd not in(
	2552703197, 47583263, 165382375, 2561119727, 165382565, 165382675, 165382689, 2553018573, 2553018583, 2553018603, 2553018323, 165382661,
	165382589, 2554793611, 165382707, 165382727, 21267059, 21267063, 21267067, 2549885359, 2575842575, 2575843071, 2575842529, 25469175,
	2557642447, 2561931299, 2575805731, 2561930481, 2557648183, 2561955475,	25471495, 25471519, 24591363, 2549886971, 2575841511, 2575960697,
	25473521, 2549888743, 2552610353, 2563538799, 25463731, 2563394971, 2575841071, 165375843, 165376027,21266999, 2579380153,
	165381811, 108665841, 108649991, 108635085, 34998213, 2578713535, 2557870887, 2557870909, 2575842903, 2557731363, 2560158023, 24300177,
	24300189, 24300186, 24300168,	24300192, 24300216, 24300198, 2549890863, 44933843, 24300195, 25474617, 2557727517, 2557648751, 161252229,
	2557666171, 24592231, 2554793823, 56622607, 2557728325, 257079695, 2557618729, 257618317, 165381905, 165381929, 165381947, 165381967)
 
join elh
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = 1
	and oa.communication_type_cd in(19468404,20094437,681544,54416801,2576706321,2553560097,2560,2553560089,2561,2562)
 
/*join elh where elh.encntr_id = o.encntr_id
	and o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.active_ind = 1
	and elh.loc_nurse_unit_cd in(
		select cv.code_value from code_value cv
		where cv.code_set = 220
		and cv.cdf_meaning = 'NURSEUNIT'
		and cv.display in(
			'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
			'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
			'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
			'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
			'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU')
		)*/
 
order by fac, o.order_id
 
Head report
	cnt = 0
Head o.order_id
	cnt += 1
	olist->rec_cnt = cnt
	call alterlist(olist->list, cnt)
	olist->list[cnt].facility = fac
	olist->list[cnt].encntrid = e.encntr_id
	olist->list[cnt].personid = e.person_id
	olist->list[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	olist->list[cnt].prsnlid = oa.order_provider_id
	olist->list[cnt].comm_type = com_type
	olist->list[cnt].nunit = unit
	olist->list[cnt].order_dt = ord_dt
	olist->list[cnt].orderid = o.order_id
	olist->list[cnt].ord_name = trim(o.ordered_as_mnemonic)
	olist->list[cnt].nume = numerator
	olist->list[cnt].denome = denominator
with nocounter
 
;------------------------------------------------------------------------------------------------
 
;Demographic
 
select into 'nl:'
 
from  (dummyt d WITH seq = value(size(olist->list,5)))
	, encntr_alias ea
	, person p
 
plan d
 
join ea where ea.encntr_id = olist->list[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = olist->list[d.seq].personid
	and p.active_ind = 1
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,olist->rec_cnt ,ea.encntr_id ,olist->list[cnt].encntrid)
      while(idx > 0)
      	olist->list[idx].fin = ea.alias
		olist->list[idx].pat_name = p.name_full_formatted
		idx = locateval(cnt ,(idx+1) ,olist->rec_cnt ,ea.encntr_id ,olist->list[cnt].encntrid)
    	endwhile
 
With nocounter
 
;------------------------------------------------------------------------------------------------
 
;Provider
 
select into 'nl:'
 ord = olist->list[d.seq].orderid
 
from  (dummyt d WITH seq = value(size(olist->list,5)))
	, prsnl pr
 
plan d
 
join pr where pr.person_id = olist->list[d.seq].prsnlid
 
order by ord
 
Head ord
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,olist->rec_cnt ,ord ,olist->list[cnt].orderid)
      if(idx > 0)
      	olist->list[idx].prsnl_name = pr.name_full_formatted
	endif
with nocounter
 
;---------------------------------------------------------------------------------------------------------
 
call echorecord(olist)
 
;---------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = substring(1, 30, olist->list[d1.seq].facility)
	, fin = substring(1, 30, olist->list[d1.seq].fin)
	, patient_name = substring(1, 50, olist->list[d1.seq].pat_name)
	, encounter_type = substring(1, 50, olist->list[d1.seq].pat_type)
	, nurse_unit = substring(1, 30, olist->list[d1.seq].nunit)
	, order_dt = substring(1, 30, olist->list[d1.seq].order_dt)
	, med_name = substring(1, 300, olist->list[d1.seq].ord_name)
	, communication_type = substring(1, 30, olist->list[d1.seq].comm_type)
	, Provider_name = substring(1, 50, olist->list[d1.seq].prsnl_name)
	, numerator = olist->list[d1.seq].nume
	, denominator = olist->list[d1.seq].denome
	, orderid = olist->list[d1.seq].orderid
 
from
	(dummyt   d1  with seq = size(olist->list, 5))
 
plan d1
 
order by facility, nurse_unit
 
with nocounter, separator=" ", format
 
 
end go
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

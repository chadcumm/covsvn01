 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		May'2019
	Solution:			Quality
	Source file name:	      cov_phq_bcma_cpoe_scorecard.prg
	Object name:		cov_phq_bcma_cpoe_scorecard
	Request#:			4549
	Program purpose:	      BCMA & Leapfrog Scorecard for all facility
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_bcma_cpoe_scorecard:DBA go
create program cov_phq_bcma_cpoe_scorecard:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime
 
;-----------------------------------------------------------------------
;Prompt Validation
IF(month(cnvtdatetime($start_datetime)) != month(cnvtdatetime($end_datetime)) )
 
     select into $outdev
	     Error_message = "Date range should be in the same month, try again"
	     ,start_Date = $start_datetime, end_date = $end_datetime
      from dummyt
      with format, separator = " "
 
ELSE ;good with prompt - execute rest of the script
 
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
 
RECORD cpoe(
	1 report_ran_by = vc
	1 list[*]
		2 month = i2
		2 month_name = vc
		2 facility = vc
		2 lp_neumarator = f8
		2 lp_denominator = f8
		2 lp_percent_compliance = f8
)
 
Record month(
	1 list[*]
		2 imonth = i2
		2 month_name = vc
)
 
;----------------------------------------------------------
;get list of months from the prompt
set sm = month(cnvtdatetime($start_datetime))
set em = month(cnvtdatetime($end_datetime))
set mcount = 0
 
while(sm <= em)
	select into 'nl:' from dummyt d
	detail
		mcount += 1
		call alterlist(month->list, mcount)
		case (sm)
			of 1  :  month_var = 'January'
			of 2  :  month_var = 'February'
			of 3  :  month_var = 'March'
			of 4  :  month_var = 'April'
			of 5  :  month_var = 'May'
			of 6  :  month_var = 'June'
		 	of 7  :  month_var = 'July'
			of 8  :  month_var = 'August'
			of 9  :  month_var = 'September'
			of 10 :  month_var = 'October'
			of 11 :  month_var = 'November'
			of 12 :  month_var = 'December'
		endcase
			month->list[mcount].month_name = trim(month_var)
			month->list[mcount].imonth = sm
	with nocounter
	set sm = sm + 1
endwhile
 
;--------------------------------------------------------
;Get user in action
select into "NL:"
from	prsnl p
where p.person_id = reqinfo->updt_id
 
detail
	cpoe->report_ran_by = p.username
with nocounter
  
;--------------------------------------------------------
;Get Leapfrog only CPOE orders
select distinct into 'nl:'

  mon = month->list[d.seq].imonth, mon_name = month->list[d.seq].month_name
, fac = trim(uar_get_code_display(i.loc_facility_cd))
, lp_numa = sum(i.numerator) over(partition by month->list[d.seq].imonth, i.loc_facility_cd)
, lp_deno = sum(i.denominator) over(partition by month->list[d.seq].imonth, i.loc_facility_cd)
 
from (dummyt d  with seq = size(month->list, 5))
,(
(select distinct
	e.loc_facility_cd, e.encntr_id, e.person_id, o.order_id, elh.loc_nurse_unit_cd, o.orig_order_dt_tm 
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
		
from encounter e, orders o, order_action oa, encntr_loc_hist elh
  	where e.loc_facility_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2553765579.00,2552503645.00,2552503649.00)
	and e.encntr_type_cd = inpatient_var
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and o.encntr_id = e.encntr_id
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
 	and oa.order_id = o.order_id
	and oa.action_sequence = 1
	and oa.communication_type_cd in(19468404,20094437,681544,54416801,2576706321,2553560097,2560,2553560089,2561,2562)
	and elh.encntr_id = e.encntr_id
	and o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
	and elh.active_ind = 1
	and elh.loc_nurse_unit_cd in(
		select cv.code_value from code_value cv
		where cv.code_set = 220
		and cv.display in(
			'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
			'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
			'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
			'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
			'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU')
		)	
	with sqltype('f8','f8','f8','f8','f8','dq8','i2','i2') )i
)

plan d
 
join i where month(i.orig_order_dt_tm) = month->list[d.seq].imonth
 
order by mon, fac
 
Head report
      cnt = 0
Head i.loc_facility_cd
 	cnt += 1
	call alterlist(cpoe->list, cnt)
	cpoe->list[cnt].month = mon
	cpoe->list[cnt].month_name = mon_name
 	cpoe->list[cnt].facility = fac
	cpoe->list[cnt].lp_denominator = lp_deno
	cpoe->list[cnt].lp_neumarator = lp_numa
	cpoe->list[cnt].lp_percent_compliance = ((lp_numa * 100) / lp_deno)
 
Foot i.loc_facility_cd
 	call alterlist(cpoe->list, cnt)
 
with nocounter

call echorecord(cpoe)

;------------------------------------------------------------------------------------------------------

select distinct into value($outdev)

	month = substring(1, 30, cpoe->list[d1.seq].month_name)
	, facility = substring(1, 30, cpoe->list[d1.seq].facility)
	, numerator = cpoe->list[d1.seq].lp_neumarator
	, denominator = cpoe->list[d1.seq].lp_denominator
	, percent_compliance = build2(cpoe->list[d1.seq].lp_percent_compliance, ' %')

from
	(dummyt   d1  with seq = size(cpoe->list, 5))

plan d1

order by month, facility

with nocounter, separator=" ", format

endif ;Prompt validation

end go 


/*

select * from code_value cv
where cv.code_set = 220
and cv.display in(
'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU' )




*/




















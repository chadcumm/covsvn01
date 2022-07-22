 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jun'2021
	Solution:			Quality
	Source file name:	      cov_chg_preop_unit_rule.prg
	Object name:		cov_chg_preop_unit_rule
	Request#:			CHG rule
	Program purpose:	      Calling from Rule
	Executing from:		Rule
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------*/
 
drop program cov_chg_preop_unit_rule:dba go
create program cov_chg_preop_unit_rule:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV

set retval = 0
set log_message = "Day Surgery Patient In Nurse Unit Not Found"
 
;------------------------------------------------------------------------------------
 
/*Geetha, can we fire it if they stay in a day surgery pt type but hit a floor?
May just exclude The Periop areas? Just thinking? I worry about ortho pts.*/
 
 
select into 'nl:'

e.encntr_id, nu = uar_get_code_display(elh.loc_nurse_unit_cd)

from encounter e
	,encntr_loc_hist elh
	,code_value cv1

plan e where e.encntr_type_cd = 309311.00	;Day Surgery
	and e.encntr_id = 116744734 ;trigger_encntrid ;116744734
	and e.disch_dt_tm is null 

join elh where elh.encntr_id = e.encntr_id 
	and elh.end_effective_dt_tm = (select max(elh1.end_effective_dt_tm) from encntr_loc_hist elh1
						where elh1.encntr_id = elh.encntr_id
						and elh.active_ind = 1
						and elh1.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
						group by elh1.encntr_id)

join cv1 where cv1.code_value = elh.loc_nurse_unit_cd
	and cv1.code_set = 220
	and cv1.active_ind = 1
	and trim(cv1.cdf_meaning) = 'NURSEUNIT'
	and cv1.code_value not in(
  2556758459.00	;FLMC GILAB
 ,2556758491.00	;FLMC ODS
 ,2556758507.00	;FLMC SUR
 ,2564351245.00	;FLMC TEMP ENDO PREP
 ,2564350799.00	;FLMC TEMP OR DAY SURG
 ,2564350949.00	;FLMC TEMP PACU
 ,2557548493.00	;FSR GILAB
 ,2557548587.00	;FSR ODS
 ,2639580551.00	;FSR OUTPATIENT GI LAB (CAM)
 ,2557548627.00	;FSR SUR
 ,2616982307.00	;FSR TEMP ENDO CAM
 ,2570762139.00	;FSR TEMP ENDO INTRA
 ,2570762031.00	;FSR TEMP ENDO PREPO
 ,2570761209.00	;FSR TEMP HOLD
 ,2616985973.00	;FSR TEMP INTRA CAM
 ,2570759989.00	;FSR TEMP OR DAY SURG
 ,2570760575.00	;FSR TEMP OR INTRA
 ,2570761687.00	;FSR TEMP OR PACU
 ,2557553053.00	;LCMC ODS
 ,2557553085.00	;LCMC SUR
 ,2564353727.00	;LCMC TEMP ENDO
 ,2564353703.00	;LCMC TEMP HOLD
 ,2564353693.00	;LCMC TEMP INTRA
 ,2564353235.00	;LCMC TEMP OR DAY SURG
 ,2564353711.00	;LCMC TEMP PACU
 ,2570759089.00	;MHA TEMP OR DAY SUR
 ,2557555883.00	;MHHS GILAB
 ,2557555987.00	;MHHS ODS
 ,2557556051.00	;MHHS SUR
 ,2570757685.00	;MHHS TEMP OR DAY SUR
 ,2570757889.00	;MHHS TEMP OR INTR
 ,2570758511.00	;MHHS TEMP OR PACU
 ,2555127689.00	;MMC GILAB
 ,2555127777.00	;MMC ODS
 ,2555127857.00	;MMC SUR
 ,2557662009.00	;MMC TEMP ENDO INTRA
 ,2557661985.00	;MMC TEMP ENDO PREPOST
 ,2556748159.00	;MMC TEMP OR DAY SURG
 ,2557661913.00	;MMC TEMP OR HOLDING
 ,2557661937.00	;MMC TEMP OR INTRA
 ,2557661961.00	;MMC TEMP OR PACU
 ,2552510813.00	;PW ASP
 ,2812979649.00	;PW BSC
 ,2556762089.00	;PW GILAB
 ,2556762257.00	;PW SUR
 ,2764184533.00	;PW TEMP BSP INT
 ,2764189119.00	;PW TEMP BSP PAC
 ,2764192101.00	;PW TEMP BSP PRE
 ,2764195283.00	;PW TEMP BSP RCL
 ,2560501447.00	;PW TEMP END INT
 ,2560501581.00	;PW TEMP END PRE
 ,2560500909.00	;PW TEMP HOLDING
 ,2560500565.00	;PW TEMP INTRA
 ,2560500077.00	;PW TEMP OR SDS
 ,2560501029.00	;PW TEMP PACU
 ,2555146451.00	;RMC GILAB
 ,2555146555.00	;RMC ODS
 ,2555146635.00	;RMC SUR
 ,2559795935.00	;RMC TEMP ENDO INTRA
 ,2559795279.00	;RMC TEMP OR DAY SURG
 ,2559795647.00	;RMC TEMP OR HOLDING
 ,2559795575.00	;RMC TEMP OR INTRA
 ,2559795703.00)	;RMC TEMP OR PACU
	
Head report
	log_message = "Day Surgery Patient Not Found In Nurse Unit"
	retval = 0
Detail
	log_message = build2("Day Surgery Patient in ",nu)
	retval = 100
with nocounter
 
call echo(build2('log_message = ',log_message, ' retval = ',retval))
 

end go
 

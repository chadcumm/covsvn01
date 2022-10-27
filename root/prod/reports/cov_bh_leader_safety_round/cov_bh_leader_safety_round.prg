/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Oct'22
	Solution:			BH
	Source file name:	      cov_bh_leader_safety_round.prg
	Object name:		cov_bh_leader_safety_round
	Request#:			13870
	Program purpose:
	Executing from:		DA2 / Layout
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date   Developer			Comment
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------*/
 
 
drop program cov_bh_leader_safety_round:dba go
create program cov_bh_leader_safety_round:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Nurse Unit" = 0 

with OUTDEV, facility_list, nurse_unit
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
/*
Restraints - (caveat - we do not chart electronically yet but plan to transition after TJC survey - Feb/March 2023, 
	so we would like to keep it for future use) Pull from same dtas currently that are used by INA

*/

declare fall_score_var       = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Morse Fall Score'))), protect
declare broset_var           = f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'Broset Sum'))),protect 
declare weight_score_var     = f8 with constant(value(uar_get_code_by("DISPLAY", 72, 'Total Weighted Score'))),protect
declare isolation_var        = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Patient Isolation'))), protect
declare suicide_preca_var    = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Precaution Suicide'))), protect
declare clo_restraint_var    = f8 with constant(value(uar_get_code_by('DISPLAY', 200, 'Nursing CLO Non-Violent Restraint'))), protect
declare bh_co_obs_var        = f8 with constant(value(uar_get_code_by("DISPLAY", 200, 'BH Constant Observation'))),protect
declare one_to_one_obs_var   = f8 with constant(value(uar_get_code_by("DISPLAY", 200, 'One to One Observation'))),protect
declare elope_preca_var      = f8 with constant(value(uar_get_code_by("DISPLAY", 200, 'Precaution Elopement'))),protect
declare code_green_othr_var  = f8 with constant(value(uar_get_code_by("DISPLAY", 200, 'Code Green V - Other'))),protect
declare code_green_pat_var   = f8 with constant(value(uar_get_code_by("DISPLAY", 200, 'Code Green V - Patient'))),protect
declare dsch_order_var       = f8 with constant(value(uar_get_code_by("DISPLAY", 200, 'Discharge Patient'))),protect
 
declare alert_var      = vc with noconstant('')
declare ln_cnt = i4
declare rs_lcnt = i4 with noconstant(0), protect
declare rs_max_size = i4 with noconstant(0), protect
declare initcap()      = c100
declare opr_unit_var   = vc with noconstant("")
 
 
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_unit_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_unit_var = "!="
else								  ;a single value was selected
	set opr_unit_var = "="
endif
 
 
;----------------------------------------------------------------------------------------------
 

;*** Contains 2 layouts(LB) - Detailed output and Summary Output ***

RECORD pat(
	1 rec_cnt = i4
	1 report_ran_by = vc
	1 plist[*]
		2 facility_cd = f8
		2 fin = vc
		2 line_cnt = i4
		2 color_cd = i4
		2 personid = f8
 		2 encntrid = f8
		2 pat_name = vc
		2 nu_unit_cd = f8
		2 nu_unit = vc
		2 nu_count = i4
		2 room = vc
		2 bed_rs = vc
		2 restraint = vc
		2 broset_sm = vc
		2 iso_ordr = vc
		2 bh_co_obs = vc
		2 bh_1_to_1_obs = vc
		2 fall_scor = vc
		2 fall_risk_rs = vc
		2 fall_risk_status = vc
		2 suicid_ordr = vc
		2 elope_preca = vc
		2 code_green = vc
		2 admit_medrec = vc
		2 disch_order = vc
		2 weight_score = vc
	)
 

Record unit(
	1 ulist[*]
		2 unit_id = f8
		2 unit_name = vc
)

 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

;Get selected(prompt) locations
 
select distinct into $outdev
    nurse_unit = uar_get_code_display(nu.location_cd)
    ,desc = uar_get_code_description(nu.location_cd)
   ,nurse_unit_cd = nu.location_cd
  
from nurse_unit nu
 
plan nu where operator(nu.location_cd, opr_unit_var, $nurse_unit)
	and nu.loc_facility_cd = $facility_list 
	and nu.location_cd in(
		2555448351.00  ;PBH UNIT A
		,2556763627.00 ;PBH UNIT A
		,2556764139.00 ;PBH UNIT A
		,2556764387.00 ;PBH UNIT A
		,2556764619.00 ;PBH UNIT A
		,2591612085.00 ;PW 1G
		,2557556147.00 ;MHHS GEROPSYCH
		)
	and nu.active_status_cd = 188 ;Active
	and nu.active_ind = 1
	and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	
order by nu.loc_facility_cd, nu.location_cd
 
Head report
	ncnt = 0
Detail
	ncnt += 1
	call alterlist(unit->ulist, ncnt)
	unit->ulist[ncnt].unit_id = nu.location_cd
	unit->ulist[ncnt].unit_name = desc
 
with nocounter

;call echorecord(unit)
;go to exitscript

;--------------------------------------------------------

;Get user in action
select into "NL:"
 
usr_name = initcap(p.username)
 
from	prsnl p
where p.person_id = reqinfo->updt_id
 
detail
	pat->report_ran_by = usr_name
with nocounter
 
 
;------------------------------------------------------------------------------------------
;Active patients

select into $outdev

fin = ea.alias, e.encntr_id, pat_nam = initcap(p.name_full_formatted), e.encntr_type_cd
, e.loc_facility_cd, elh.loc_nurse_unit_cd
 
from (dummyt d with seq = size(unit->ulist, 5))
	, encounter e
	, encntr_loc_hist elh
	, encntr_alias ea
	, person p
	
plan d	
 
join elh where elh.loc_nurse_unit_cd = unit->ulist[d.seq].unit_id
	;operator(elh.loc_nurse_unit_cd, opr_unit_var, $nurse_unit)
	and elh.active_ind = 1
	and elh.active_status_cd = 188 ;active
	and (elh.beg_effective_dt_tm <= sysdate and elh.end_effective_dt_tm >= sysdate)
 
join e where e.encntr_id = elh.encntr_id
	and e.encntr_status_cd = 854.00 ;Active
	and e.disch_dt_tm is null
	and e.encntr_status_cd != 856.00 ;Discharged
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by elh.loc_nurse_unit_cd, elh.loc_room_cd, ea.alias

;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
;go to exitscript
 

Head report
	cnt = 0
Head elh.loc_nurse_unit_cd	
	ncnt = 0
Head ea.alias
	ncnt += 1
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->plist, cnt)
Detail
	pat->plist[cnt].line_cnt = cnt
	pat->plist[cnt].color_cd = cnt
	pat->plist[cnt].facility_cd = e.loc_facility_cd
	pat->plist[cnt].fin = ea.alias
	pat->plist[cnt].personid = e.person_id
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].pat_name = pat_nam
	pat->plist[cnt].nu_unit_cd = elh.loc_nurse_unit_cd
	pat->plist[cnt].nu_unit = uar_get_code_description(elh.loc_nurse_unit_cd)
	pat->plist[cnt].room = if(elh.loc_room_cd != 0) uar_get_code_display(elh.loc_room_cd) else ' ' endif
	pat->plist[cnt].bed_rs = if(elh.loc_bed_cd != 0) uar_get_code_display(elh.loc_bed_cd) else ' ' endif

Foot elh.loc_nurse_unit_cd		
	pat->plist[cnt].nu_count = ncnt

with nocounter
 
if(pat->rec_cnt > 0)

;----------------------------------------------------------------------------------------
;Assign unit total

select into $outdev

ncode = pat->plist[d.seq].nu_unit_cd, ncount =  pat->plist[d.seq].nu_count

from (dummyt d with seq = size(pat->plist, 5))

plan d where pat->plist[d.seq].nu_count > 0

order by ncode

Head ncode
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ncode ,pat->plist[icnt].nu_unit_cd)
	while(idx > 0) 	
		pat->plist[idx].nu_count = ncount
		idx = locateval(icnt ,(idx+1) ,size(pat->plist,5) ,ncode ,pat->plist[icnt].nu_unit_cd)
	endwhile
with nocounter

;----------------------------------------------------------------------------------------------------------------
;Isolation Order
 
select into $outdev
 o.encntr_id, o.order_id, od.oe_field_display_value
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
	, order_detail od
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd = isolation_var
	and o.order_status_cd = 2550
 
join od where od.order_id = o.order_id
	and od.oe_field_meaning = 'ISOLATIONCODE'
 
order by o.encntr_id, od.oe_field_display_value
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
      iso_oef_var = fillstring(1000," ")
Head od.oe_field_display_value
      iso_oef_var = build2(trim(iso_oef_var),trim(od.oe_field_display_value),',')
Foot od.oe_field_display_value
	pat->plist[idx].iso_ordr = replace(trim(iso_oef_var),",","",2)
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Fall, broset, weight score
 
select into $outdev
 
enc = pat->plist[d.seq].encntrid, ce.event_cd, ce.result_val, ce.event_end_dt_tm
 
from
	(dummyt d with seq = size(pat->plist, 5))
	, clinical_event ce
 
plan d
 
join ce where ce.person_id = pat->plist[d.seq].personid
	and ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(fall_score_var, broset_var, weight_score_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	      and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.event_cd
	
	case(ce.event_cd)
		of fall_score_var:
			pat->plist[idx].fall_scor = trim(ce.result_val)
		   	if(cnvtint(trim(ce.result_val)) > 40)
		   		pat->plist[idx].fall_risk_status = build2('Yes,', trim(ce.result_val))
		   	endif
		 of broset_var:
		 	pat->plist[idx].broset_sm = trim(ce.result_val)
		 of weight_score_var:
			if(cnvtint(trim(ce.result_val)) >= 4)
		   		pat->plist[idx].weight_score = trim(ce.result_val)
		   	endif
      endcase
      
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
;Suicide restraint, co, 1to1, broset

select into $outdev
 o.encntr_id, o.orig_order_dt_tm ';;q', o.order_mnemonic, o.ordered_as_mnemonic, o.hna_order_mnemonic
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, orders o
 
plan d
 
join o where o.encntr_id = pat->plist[d.seq].encntrid
	and o.catalog_cd in(suicide_preca_var, clo_restraint_var, bh_co_obs_var, one_to_one_obs_var
		, elope_preca_var, code_green_othr_var, code_green_pat_var, dsch_order_var)
	and o.order_status_cd = 2550
 
order by o.encntr_id, o.catalog_cd
 
Head o.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,o.encntr_id ,pat->plist[icnt].encntrid)
Head o.catalog_cd
      case(o.catalog_cd)
      of suicide_preca_var:
      	pat->plist[idx].suicid_ordr = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
      of clo_restraint_var:
		pat->plist[idx].restraint = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
      of bh_co_obs_var:
		pat->plist[idx].bh_co_obs = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
      of one_to_one_obs_var:
		pat->plist[idx].bh_1_to_1_obs = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
	of elope_preca_var:
		pat->plist[idx].elope_preca = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
	of code_green_othr_var:
		pat->plist[idx].code_green = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
	of code_green_pat_var:
		pat->plist[idx].code_green = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
	of dsch_order_var:	
		pat->plist[idx].disch_order = build2(trim(o.order_mnemonic),'-',format(o.orig_order_dt_tm, 'mm/dd/yy hh:mm ;;q'))
 	endcase
 	
with nocounter
 
;---------------------------------------------------------------------------------------------------------------- 
;Admission Medrec

select into $outdev
fin = pat->plist[d.seq].fin, ore.encntr_id, ore.recon_type_flag, ore.recon_status_cd

from (dummyt d with seq = value(size(pat->plist, 5)))
	,order_recon ore

plan d

join ore where ore.encntr_id = pat->plist[d.seq].encntrid
	and ore.recon_type_flag = 1	
	and ore.recon_status_cd = value(uar_get_code_by("DISPLAY", 4002695,"Complete"))
	and ore.order_recon_id = (select max(ore1.order_recon_id) from order_recon ore1
						where ore1.encntr_id = ore.encntr_id
						and ore1.recon_type_flag = ore.recon_type_flag
						and ore1.recon_status_cd = ore.recon_status_cd
						group by ore1.encntr_id )

order	by ore.encntr_id

Head ore.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ore.encntr_id ,pat->plist[icnt].encntrid)
Detail
	pat->plist[idx].admit_medrec = 'Completed'

with nocounter		
 
 
;----------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------

;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
call echorecord(pat)
 
;----------------------------------------------------------------------------------------------------------------

 
select into $outdev
	facility = trim(uar_get_code_display(pat->plist[d1.seq].facility_cd))
	, fin = trim(substring(1, 30, pat->plist[d1.seq].fin))
	;, color_no = pat->plist[d1.seq].color_cd
	;, personid = pat->plist[d1.seq].personid
	;, encntrid = pat->plist[d1.seq].encntrid
	, pat_name = trim(substring(1, 50, pat->plist[d1.seq].pat_name))
	, nurse_unit = trim(substring(1, 30, pat->plist[d1.seq].nu_unit))
	, room = trim(substring(1, 5, pat->plist[d1.seq].room))
	, bed = trim(substring(1, 5, pat->plist[d1.seq].bed_rs))
	, isolation = trim(substring(1, 300, pat->plist[d1.seq].iso_ordr))
	, restraint = trim(substring(1, 300, pat->plist[d1.seq].restraint))
	, suicide_precaution = trim(substring(1, 300, pat->plist[d1.seq].suicid_ordr))
	, broset_sm = trim(substring(1, 30, pat->plist[d1.seq].broset_sm))
	, constant_observation = trim(substring(1, 100, pat->plist[d1.seq].bh_co_obs))
	, one_to_one_observation = trim(substring(1, 100, pat->plist[d1.seq].bh_1_to_1_obs))
	, fall_risk_status = trim(substring(1, 30, pat->plist[d1.seq].fall_risk_status))
	, elopement_precaution = trim(substring(1, 100, pat->plist[d1.seq].elope_preca))
	, code_green_order = trim(substring(1, 100, pat->plist[d1.seq].code_green))
	, moas_weightd_score = trim(substring(1, 30, pat->plist[d1.seq].weight_score))
	, admission_medrec = trim(substring(1, 30, pat->plist[d1.seq].admit_medrec))
	, discharge_order = trim(substring(1, 100, pat->plist[d1.seq].disch_order))

FROM
	(dummyt   d1  with seq = size(pat->plist, 5))

plan d1 
 
ORDER BY
	nurse_unit
	;, color_no
	, room
	, fin
	;, ln_cnt

WITH nocounter, separator=" ", format


 
endif
 
#exitscript
 
end go
 
 
 
 
 
 
 
 
 

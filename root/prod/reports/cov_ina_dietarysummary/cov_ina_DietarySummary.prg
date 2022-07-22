drop program cov_ina_DietarySummary go
create program cov_ina_DietarySummary
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:				Dan Herren
	Date Written:		July 2018
	Solution:			Nursing/Nutrition
	Source file name:  	cov_ina_DietarySummary.prg
	Object name:		cov_ina_DietarySummary
	CR#:				2133
 
	Program purpose:	Report will show all patient's diet information.
	Executing from:		CCL/DA2/Nutrition
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
prompt
	"Output to File/Printer/MINE" = "MINE"
 
with OUTDEV, facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare mrn_var   = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var   = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare prsnl_var = f8 with constant(uar_get_code_by("DISPLAY", 333, 'Admitting Physician')),protect ;1116.00
declare username  = vc with protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
Record diet(
	1 username   = c15
	1 totdietcnt = i4
	1 list[*]
		2 facility      = vc
		2 nurse_unit    = c50
		2 diet          = c100
		2 diet_cnt      = i4
		2 unit_cnt      = i4
;		2 tot_diet_cnt  = i4
		2 total_cnt     = i4
		2 admit_date    = vc
		2 encntrid      = f8
)

select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	diet->username = p.username
with nocounter


select into "NL:"
;select into value ($OUTDEV)
 
  encntr_id   = e.encntr_id
, facility    = uar_get_code_display(e.loc_facility_cd)
, nurse_unit  = uar_get_code_display(e.loc_nurse_unit_cd)
, admit_dt    = format(e.reg_dt_tm,"MM/DD/YYYY;;D")
, diet        = i.hna_order_mnemonic
, diet_cnt    = count(*) over(partition by i.hna_order_mnemonic)
, unit_cnt    = count(*) over(partition by e.loc_nurse_unit_cd)
, total_cnt   = count(*) over()
 
from
  ENCOUNTER          e
, ENCNTR_ALIAS       ea
, ENCNTR_ALIAS       ea1
, PERSON             p
, ENCNTR_PRSNL_RELTN epr
, PRSNL              pr
;, PRSNL_ORG_RELTN    por
 
 ,(
   (select distinct o.encntr_id, o.hna_order_mnemonic, o.orig_order_dt_tm, o.clinical_display_line, o.activity_type_cd
   	, o.current_start_dt_tm, o.projected_stop_dt_tm, o.order_id
   	,ordext = dense_rank() over (partition by o.encntr_id, o.order_id order by o.last_action_sequence desc)
	from orders o, encounter e
	where o.encntr_id = e.encntr_id
		and e.loc_facility_cd = $facility_list
		and e.disch_dt_tm is null
		and e.loc_room_cd != 0.0
		and e.loc_bed_cd != 0.0
		and e.encntr_status_cd = 854.00 ;Active
		and e.active_ind = 1
		and o.activity_type_cd in(681598.00, 681643.00, 636696.00);diet,tube,supplement
		and o.active_status_cd = 188 ;Active
		and o.active_ind = 1
		and o.order_status_cd = 2550.00 ;Ordered
		and o.current_start_dt_tm <= sysdate
		and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
 
	with sqltype("f8","vc","dq8","vc","f8","dq8","dq8", "f8", "i4")
   )i
 )
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm is null
	and e.loc_room_cd != 0.0
	and e.loc_bed_cd != 0.0
	and e.encntr_status_cd = 854.00 ;Active
	and e.active_ind = 1
 
join i where i.encntr_id = outerjoin(e.encntr_id)
	;and i.ordext = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = mrn_var
	and ea1.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join epr where epr.encntr_id = outerjoin(e.encntr_id)
	and epr.encntr_prsnl_r_cd = outerjoin(prsnl_var) ;admitting md
	and epr.active_status_cd = outerjoin(188)
	and epr.active_ind = outerjoin(1)
	and epr.beg_effective_dt_tm <= outerjoin(sysdate)
	and epr.end_effective_dt_tm > outerjoin(sysdate)
 
join pr where pr.person_id = outerjoin(epr.prsnl_person_id) ;PCP
	and pr.active_ind = outerjoin(1)
	and pr.active_status_cd = outerjoin(188)
	and pr.physician_ind = outerjoin(1)

;join por
;    where por.person_id = reqinfo->updt_id
;	    and por.active_ind = 1
; 		and por.end_effective_dt_tm >= sysdate
 		 	
order by nurse_unit, diet, e.encntr_id
 
head report
	cnt  = 0
	tcnt = 0
 
detail
 	cnt = cnt + 1
	call alterlist(diet->list, cnt)
 
 	tcnt = evaluate2(if (i.hna_order_mnemonic != null) 1 else 0 endif)
 	diet->totdietcnt = diet->totdietcnt + tcnt
 
	diet->list[cnt].facility      = uar_get_code_display(e.loc_facility_cd)
	diet->list[cnt].nurse_unit    = uar_get_code_display(e.loc_nurse_unit_cd)
	diet->list[cnt].diet          = i.hna_order_mnemonic
	diet->list[cnt].diet_cnt      = diet_cnt
	diet->list[cnt].unit_cnt      = unit_cnt
	diet->list[cnt].total_cnt     = total_cnt
	diet->list[cnt].admit_date    = admit_dt
	diet->list[cnt].encntrid      = e.encntr_id
 
with nocounter
 
;if(diet->reccnt > 0)
;	call echorecord(diet)
;endif
 
;============================
; REPORT OUTPUT
;============================  evaluate2(if (i.hna_order_mnemonic = null) "No Diet" else i.hna_order_mnemonic endif)
;select into "NL:"
select into value ($OUTDEV)
	 facility      = diet->list[d.seq].facility
	,nurse_unit    = diet->list[d.seq].nurse_unit
	,diet          = evaluate2( if (diet->list[d.seq].diet = null)  "No Diet" else diet->list[d.seq].diet endif)
	,admit_date    = diet->list[d.seq].admit_date
	,encntrid      = diet->list[d.seq].encntrid
	,diet_cnt      = diet->list[d.seq].diet_cnt
	,unit_cnt      = diet->list[d.seq].unit_cnt
	,tot_diet_cnt  = diet->totdietcnt
	,tot_rec_cnt   = diet->list[d.seq].total_cnt
	,username      = diet->username
 
from
	(dummyt d  with seq = value(size(diet->list,5)))
 
plan d
 
order by
	 facility
	,nurse_unit
	,diet
	,encntrid
 
with nocounter, format, check, separator = " "
 
#EXITSCRIPT
end
go
 
 

 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		May'2018
	Solution:			Nursing/Nutrition
	Source file name:  	cov_ina_dietitian_worksheet.prg
	Object name:		cov_ina_dietitian_worksheet
	Request#:			343
 
	Program purpose:	      Report will show all patient's diet information.
	Executing from:		CCL/DA2/Nutrition
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Revision #	Mod Date	Developer				Comment
----------	----------	--------------------	------------------------------------------
001			04/04/2019	Paul Hester				CR3954.  Added BMI.  Lines affected end with
												001 to show which lines were added / touched.
002			04/09/2020	Paul Hester				CR7459.  Added Isolation Type
003         05/28/2020  Chad C/Dan H			CR7840. Updated isoloation section to add iso_ord to each record structure entry
004			06/23/2020	Paul Hester				CR7949  Added diet start date/time to output
005			07/31/2020	Paul Hester				CR8119	Added prompt for department filtering
006			03/02/2021	Paul Hester				CR9513	Added order.activity_type_cd = 681617 (Nutrition Asmt/Tx/Monitoring)
********************************************************************************************/
 
drop program cov_ina_dietitian_worksheet:DBA go
create program cov_ina_dietitian_worksheet:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FacilityList" = 0
	, "Nurse Unit" = VALUE(0.0)
 
with OUTDEV,
	facility_list,
		Nurse_Unit	;005
 
/**************************************************************
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()       = c100
declare mrn_var         = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var         = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare prsnl_var       = f8 with constant(uar_get_code_by("DISPLAY", 333, 'Admitting Physician')),protect ;1116.00
 
DECLARE route_var		= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"TUBEFEEDROUTE")),PROTECT
DECLARE start_rate_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"TUBEFEEDCONTSTARTRATE")),PROTECT
DECLARE bolus_amt_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"TUBEFEEDINGBOLUSAMOUNT")),PROTECT
DECLARE bolus_freq_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"TUBEFEEDBOLUSFREQUENCY")),PROTECT
DECLARE spec_inst_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"SPECIALINSTRUCTIONS")),PROTECT
DECLARE diet_mod_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"DIETMODIFIERS")),PROTECT
DECLARE bev_cons_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"BEVERAGECONSISTENCY")),PROTECT
DECLARE diet_cons_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"DIETCONSISTENCY")),PROTECT
DECLARE pat_req_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"PATIENTREQUEST")),PROTECT
DECLARE diet_res_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"DIETARYRESTRICTIONS")),PROTECT
DECLARE fl_perm_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"DIETARYFLUIDPERMITTED")),PROTECT
DECLARE supp_freq_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"SUPPLEMENTSCHEDULE")),PROTECT
 
DECLARE nutr_serv_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",6000,"NUTRITIONSERVICES")),PROTECT
 
DECLARE iso_type_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",16449,"ISOLATIONCODE")),PROTECT	;002
DECLARE iso_ord_var		= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",200,"PATIENTISOLATION")),PROTECT	;002
DECLARE ord_status_var	= F8 WITH CONSTANT(uar_get_code_by("DISPLAY_KEY",6004,"ORDERED")),PROTECT	;002
 
declare weight_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Weight Dosing")),protect
declare height_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Height/Length Measured")),protect
declare diet_var        = f8 with Constant(uar_get_code_by("DISPLAY", 106,"Diets")),protect
 
;Sort allergies
DECLARE severe_var      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12022,"SEVERE")),PROTECT
DECLARE food_var	      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12020,"FOOD")),PROTECT
DECLARE drug_var	      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12020,"DRUG")),PROTECT
DECLARE env_var	      = f8 with constant(uar_get_code_by("DISPLAY_KEY",12020,"ENVIRONMENT")),PROTECT
 
;BTG set up - Diet Worksheet
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
declare filename_var = vc WITH noconstant(CONCAT('cer_temp:',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_diet_worksheet.pdf')), PROTECT
declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_diet_worksheet.pdf')), PROTECT
declare astream_filepath_var = vc with noconstant("/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Dietary/")
 
;BTG set up - Diet Census
declare cmd_c  = vc with noconstant("")
declare len_c  = i4 with noconstant(0)
declare stat_c = i4 with noconstant(0)
declare filename_var_c = vc WITH noconstant(CONCAT('cer_temp:',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_diet_census.pdf')), PROTECT
declare ccl_filepath_var_c = vc WITH noconstant(CONCAT('$cer_temp/',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_diet_census.pdf')), PROTECT
 
declare opr_nu_var    = vc with noconstant("")	;005
 
;START 005
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif
;END 005
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record diet(
	1 reccnt = i4
	1 plist[*]
		2 facility = f8
		2 nurse_unit = f8
		2 room = f8
		2 bed = f8
		2 pat_name = vc
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 mrn = vc
		2 fin = vc
		2 admitting_md = vc
		2 dob = vc
		2 age = vc
		2 gender = vc
		2 height = f8
		2 height_cm = vc
		2 hight_date = vc
		2 weight = vc
		2 weight_date = vc
		2 bmi = f8			;001
		2 admit_date = vc
		2 los = i4
		2 dx = vc
		2 diet = vc
		2 days_on_diet = i4
		2 comments = vc
		2 allergies = vc
		2 iso_ord = vc	;002
)
 
 
SELECT DISTINCT INTO "NL:"
 
  e.loc_facility_cd
, e.person_id
, e.encntr_id
, e_type = uar_get_code_display(e.encntr_type_cd)
, e.loc_nurse_unit_cd
, room = e.loc_room_cd
, bed = e.loc_bed_cd
, pat_name = initcap(p.name_full_formatted)
, gender = uar_get_code_display(p.sex_cd)
, mrn =  ea1.alias
, fin = ea.alias
, dob = format(p.birth_dt_tm,"MM/DD/YYYY;;D")
, age = cnvtage(p.birth_dt_tm)
, admit_dt = format(e.reg_dt_tm,"MM/DD/YYYY;;D")
, los = DATETIMEcmputc(cnvtdatetime(curdate,curtime2),e.reg_dt_tm)
, admit_dx  = e.reason_for_visit ;trim(i.diagnosis_display)
, admit_md  = initcap(pr.name_full_formatted)
, diet_type = uar_get_code_display(i.activity_type_cd)
, diet = i.hna_order_mnemonic;build(i.hna_order_mnemonic," Start Dt: ",format(i.current_start_dt_tm,"MM/DD/YYYY HH:MM;;D"))
, days_diet =
	if (format(i.orig_order_dt_tm,"MM/DD/YYYY;;D") != " "  )
		DATETIMEcmputc(cnvtdatetime(curdate,curtime2),i.orig_order_dt_tm)
	endif
, diet_order_dt = format(i.orig_order_dt_tm,"MM/DD/YYYY HH:MM;;D")
, diet_start_dt = format(i.current_start_dt_tm,"MM/DD/YYYY HH:MM;;D")	;004
, diet_comment =  i.clinical_display_line
 
from
   encounter e
 , encntr_alias ea
 , encntr_alias ea1
 , person p
 , encntr_prsnl_reltn epr
 , prsnl pr
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
	and o.activity_type_cd in(681598, 681643, 636696, 681617);diet,tube,supplement	;006
	and o.active_status_cd = 188
	and o.active_ind = 1
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
	and (
		(o.activity_type_cd != 681617 AND (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null))	;006
		OR	;006
		(o.activity_type_cd = 681617)	;006
		)
 
	with sqltype("f8","vc","dq8","vc","f8","dq8","dq8", "f8", "i4")
 
   )i
 )
 
plan e where e.loc_facility_cd = $facility_list
	and operator(e.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)	;005
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
 
order by e.encntr_id
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
;Populate Patient and order info
Head report
 
cnt = 0
call alterlist(diet->plist, 10)
 
Detail
 	cnt = cnt + 1
 	diet->reccnt = cnt
	call alterlist(diet->plist, cnt)
 
	diet->plist[cnt].facility     = e.loc_facility_cd
	diet->plist[cnt].nurse_unit   = e.loc_nurse_unit_cd
	diet->plist[cnt].room         = e.loc_room_cd
	diet->plist[cnt].bed          = e.loc_bed_cd
	diet->plist[cnt].pat_name     = p.name_full_formatted
	diet->plist[cnt].personid     = e.person_id
	diet->plist[cnt].encntrid     = e.encntr_id
	diet->plist[cnt].orderid      = i.order_id
	diet->plist[cnt].mrn          = mrn
	diet->plist[cnt].fin          = fin
	diet->plist[cnt].admitting_md = admit_md
	diet->plist[cnt].dob          = dob
	diet->plist[cnt].age          = age
	diet->plist[cnt].gender       = gender
	diet->plist[cnt].admit_date   = admit_dt
	diet->plist[cnt].los          = los
	diet->plist[cnt].dx           = admit_dx
	diet->plist[cnt].diet         = build2(TRIM(i.hna_order_mnemonic),"   Start Date: ",TRIM(diet_start_dt))	;i.hna_order_mnemonic 	;004
	diet->plist[cnt].days_on_diet = days_diet
	;diet->plist[cnt].comments     = diet_comment
 
with nocounter
 
 
IF(diet->reccnt > 0)
 
 
;================================================================================================
;Get diet details
 
select distinct into "NL:"
	 od = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
			over (partition by diet->plist[d.seq].encntrid, oa.order_id, od.oe_field_id)
from
	(dummyt d WITH seq = value(size(diet->plist,5)))
	,order_action oa
	,order_detail od
	,order_entry_fields oef
 
plan d
 
join oa where diet->plist[d.seq].orderid = oa.order_id
 
join od where od.order_id = oa.order_id
	and od.oe_field_id in (route_var, start_rate_var, bolus_amt_var, bolus_freq_var, diet_mod_var, spec_inst_var,
		bev_cons_var, diet_cons_var, pat_req_var, diet_res_var, fl_perm_var, supp_freq_var)
 
join oef where od.oe_field_id = oef.oe_field_id
 
order by diet->plist[d.seq].encntrid, oa.order_id, od.oe_field_id
 
Head report
	cnt = 0
	idx = 0
 
head oa.order_id
 
	idx = locateval(cnt,1,size(diet->plist,5),oa.order_id, diet->plist[cnt].orderid)
	desc_var = fillstring(300," ")
	desc_out = fillstring(300," ")
 
Detail
 
	case (od.oe_field_id)
		OF route_var	: desc_out = build2("Route: ",TRIM(od))
		OF start_rate_var	: desc_out = build2("Start Rate: ",TRIM(od))
		OF bolus_amt_var	: desc_out = build2("Bolus Amt: ",TRIM(od))
		OF bolus_freq_var	: desc_out = build2("Bolus Frq: ",TRIM(od))
		OF diet_mod_var	: desc_out = build2("Diet Mod: ",TRIM(od))
		OF spec_inst_var	: desc_out = build2("Special Inst: ",TRIM(od))
		OF bev_cons_var	: desc_out = build2("Bev.Consis: ",TRIM(od))
		OF diet_cons_var	: desc_out = build2("Diet Consis: ",TRIM(od))
		OF pat_req_var	: desc_out = build2("Request: ",TRIM(od))
		OF diet_res_var	: desc_out = build2("Restrictions: ",TRIM(od))
		OF fl_perm_var	: desc_out = build2("Fluid Perm: ",TRIM(od))
		OF supp_freq_var	: desc_out = build2("Freq: ",TRIM(od))
	endcase
 
	desc_var = build2(TRIM(desc_var),TRIM(desc_out),",")
 
Foot oa.order_id
 
	diet->plist[idx].comments = REPLACE(TRIM(desc_var),",","",2)
 
With nocounter
 
;================================================================================================
;Get isolation details
;002 ==> ENTIRE QUERY IS NEW
;================================================================================================
 
select distinct into "NL:"
;	 oname = build(od.oe_field_display_value," (Ord ID: ",CNVTSTRING(o.order_id),")")
	 oname = od.oe_field_display_value
	,o.encntr_id
;	,o.order_id
from
	 (dummyt d WITH seq = value(size(diet->plist,5)))
	,orders o
	,order_action oa
	,order_detail od
 
plan d
 
join o where diet->plist[d.seq].encntrid = o.encntr_id
	and o.order_status_cd = ord_status_var	;2550.00
	and o.catalog_cd = iso_ord_var	;    3976772.00
 
join oa where oa.order_id = o.order_id
 
join od where od.order_id = oa.order_id
	and od.oe_field_id = iso_type_var	;      12588.00
 
order by o.encntr_id, od.oe_field_display_value
 
Head report
	cnt = 0
	idx = 0
 
head o.encntr_id
 
	idx = locateval(cnt,1,size(diet->plist,5),o.encntr_id, diet->plist[cnt].encntrid)
	desc_var = fillstring(300," ")
	desc_out = fillstring(300," ")
 
Detail
 
	desc_out = oname
 
	desc_var = build2(TRIM(desc_var),TRIM(desc_out),",")
 
Foot o.encntr_id
 
	;003 diet->plist[idx].iso_ord = REPLACE(TRIM(desc_var),",","",2)
	;start 003
	for (i=1 to size(diet->plist,5))
		if (diet->plist[i].encntrid = o.encntr_id)
			diet->plist[i].iso_ord = REPLACE(TRIM(desc_var),",","",2)
		endif
	endfor
	;end 003
 
With nocounter
 
;===============================+++++++++++++++++++++++++++++++++++++++++++++++++++++===================
 
;Get clinical events
Select into $outdev 

i5.encntr_id, i5.event_id, event = uar_get_code_display(i5.event_cd), i5.result_val
, unit = uar_get_code_display(i5.result_units_cd), i5.performed_dt_tm ';;q'
 
from
 
(  ( select distinct ce.encntr_id, ce.event_id,ce.event_cd, ce.result_val, ce.result_units_cd, ce.performed_dt_tm
	,ordext5 = dense_rank() over (partition by ce.encntr_id, ce.event_cd order by ce.performed_dt_tm desc)
 	from clinical_event ce, encounter e
 	where ce.encntr_id = e.encntr_id
 	and e.loc_facility_cd = $facility_list
	and e.disch_dt_tm is null
	and e.active_ind = 1
	and e.encntr_status_cd = 854.00 ;Active
 	and ce.result_status_cd in(25,34,35)
	and ce.publish_flag = 1
	and ce.record_status_cd = 188 ; active
	and ce.event_class_cd = 233 ;numeric
	and ce.event_cd in(Height_var, Weight_var)
	order by ce.encntr_id, ce.event_cd
	with sqltype("f8","f8", "f8", "VC", "f8", "dq8","i4")
 	)i5
  )
 
plan i5 where i5.ordext5 = 1
 
order by i5.encntr_id, i5.event_id
 

;WITH NOCOUNTER, SEPARATOR=" ", FORMAT


;******** NEW CODE - 03/26/2021  ************************ 

Head i5.encntr_id
	call echo(build2('enc = ',i5.encntr_id,'event = ', i5.event_cd,'--eventid = ',i5.event_id))

Head i5.event_id
	icnt = 0
	idx = 0
	idx = locateval(icnt, 1, size(diet->plist, 5), i5.encntr_id, diet->plist[icnt].encntrid)
Detail	
	while(idx > 0)
		case (i5.event_cd)
			OF height_var:
	 			diet->plist[idx].height_cm    =  i5.result_val ;cm
	 			diet->plist[idx].hight_date   = format(i5.performed_dt_tm, "MM/DD/YYYY;;D")
			OF weight_var:
				diet->plist[idx].weight       = i5.result_val
				diet->plist[idx].weight_date  = format(i5.performed_dt_tm, "MM/DD/YYYY;;D")
		endcase

		diet->plist[idx].bmi = ((cnvtint(diet->plist[idx].weight)) / 
			(CNVTREAL(diet->plist[idx].height_cm) * CNVTREAL(diet->plist[idx].height_cm))) * 10000	;001
		idx = locateval(icnt, (idx+1), size(diet->plist, 5), i5.encntr_id, diet->plist[icnt].encntrid)
	endwhile
 
with nocounter

 
;----------------------------------------------------------------------------------------------------------------

/***** Old CODE -************************ 

;Populate Clinical Events
Head report
	idx = 0
	cnt = 0
Head i5.encntr_id
	idx = locateval(cnt, 1, size(diet->plist, 5), i5.encntr_id, diet->plist[cnt].encntrid)
DETAIL
	IF (idx > 0)
	case (i5.event_cd)
		OF height_var:
 			diet->plist[idx].height_cm    =  i5.result_val ;cm
 			diet->plist[idx].hight_date   = format(i5.performed_dt_tm, "MM/DD/YYYY;;D")
		OF weight_var:
			diet->plist[idx].weight       = i5.result_val
			diet->plist[idx].weight_date  = format(i5.performed_dt_tm, "MM/DD/YYYY;;D")
	endcase
 
	diet->plist[idx].bmi = ((cnvtint(diet->plist[idx].weight)) / (CNVTREAL(diet->plist[idx].height_cm) * CNVTREAL(diet->plist[idx].height_cm))) * 10000	;001
 
	ENDIF
 
with nocounter
*/
;----------------------------------------------------------------------------------------------------------------
 
 
;**** Allergy ******
 
SELECT DISTINCT INTO "NL:"
 
;a.encntr_id, n.source_string, a.severity_cd, a.substance_type_cd, a.beg_effective_dt_tm, a.end_effective_dt_tm, a.active_status_cd
;, a.active_ind, n.active_status_cd, n.active_ind
 
sort_order =
 
if(a.severity_cd = severe_var) 1
	elseif (a.substance_type_cd = food_var) 2
	elseif (a.substance_type_cd = drug_var) 3
	elseif (a.substance_type_cd = env_var)  4
	else 5
endif
 
from
	(dummyt d WITH seq = value(size(diet->plist,5)))
	, allergy a
	, encounter e
	, nomenclature n
 
plan d
 
join e where outerjoin(e.person_id) = diet->plist[d.seq].personid
	and outerjoin(e.encntr_id) = diet->plist[d.seq].encntrid
 
join a where a.person_id = e.person_id
	and a.active_ind = 1
	and a.active_status_cd = 188
	and a.beg_effective_dt_tm <= sysdate
	and a.end_effective_dt_tm >= sysdate
	and (a.cancel_dt_tm is null or a.cancel_dt_tm > sysdate)
	;and a.data_status_cd in(25,34,35)
 
join n where n.nomenclature_id = outerjoin(a.substance_nom_id)
	and n.active_ind = outerjoin(1)
	;;and n.active_status_cd = 188
 
order by e.encntr_id, sort_order, n.source_string
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
HEAD REPORT
 	cnt = 0
	idx = 0
HEAD e.encntr_id
 	idx = locateval(cnt,1,size(diet->plist,5), e.encntr_id, diet->plist[cnt].encntrid)
 	allergy_string = fillstring(100," ")
 	free_text_allergy_string = fillstring(100," ")
DETAIL
	allergy_string = build(trim(allergy_string), trim(n.source_string),", ")
	if (a.substance_ftdesc != ' ' and a.substance_ftdesc != 'No Known Allergies' and a.substance_ftdesc != 'No Allergies' )
		free_text_allergy_string = build(trim(free_text_allergy_string), trim(a.substance_ftdesc),", ")
	endif
 
FOOT e.encntr_id
	if(free_text_allergy_string != ' ')
		allergy_string = build(allergy_string, free_text_allergy_string)
	endif
 
	for (i=1 to size(diet->plist,5))
		if(diet->plist[i].encntrid = diet->plist[idx].encntrid)
			diet->plist[i].allergies = replace(trim(allergy_string),",","",2)
		endif
	endfor
 
WITH nocounter
 
ENDIF ;reccnt
 
call echorecord(diet)
 
 
end
go
 
 
 
 
 

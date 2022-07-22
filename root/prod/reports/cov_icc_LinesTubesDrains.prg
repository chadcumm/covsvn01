drop program cov_icc_LinesTubesDrains:DBA go
create program cov_icc_LinesTubesDrains:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = ""
	, "End Date/Time" = ""
	, "Facility" = "" 

with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare facility_name_var    = vc with constant(uar_get_code_description($facility)),protect
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
 
;Lines, Tubes and Drains enevts
 
declare arterial_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Arterial Line Activity:        ")),protect
declare central1_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Activity.         ")),protect
declare central2_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central IV Activity            ")),protect
declare central3_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central IV Activity:           ")),protect
declare chest1_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Chest Tube Activity            ")),protect
declare chest2_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Chest Tube Activity:           ")),protect
declare enteral_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Enteral Tube Activity          ")),protect
declare endot1_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Endotracheal Tube Activity     ")),protect
declare endot12_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Endotracheal Tube Activity:    ")),protect
declare epidural_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Epidural Line Activity:        ")),protect
declare gi_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "GI Tube Activity:              ")),protect
declare gast1_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gastric Tube Activity          ")),protect
declare gast2_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gastrointestinal Tube Activity:")),protect
declare iabp_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "IABP Line Activity:            ")),protect
declare icp_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "ICP Line Activity:             ")),protect
declare intra_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Intraosseous Line Activity:    ")),protect
declare la1_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "LA Line Activity               ")),protect
declare la2_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "LA Line Activity:              ")),protect
declare nb_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "NB Feeding Tube Activity:      ")),protect
declare pa1_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "PA Line Activity               ")),protect
declare pa2_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "PA Line Activity:              ")),protect
declare pd_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "PD Line Activity:              ")),protect
declare peri1_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Peripheral IV Activity         ")),protect
declare peri2_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Peripheral IV Activity:        ")),protect
declare surgi_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Surgical Drain, Tube Activity: ")),protect
declare trac1_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Tracheostomy Tube Activity     ")),protect
declare trac2_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Tracheostomy Tube Activity:    ")),protect
declare urin_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Activity:     ")),protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
select distinct into $outdev
 
;Lines, Tubes and drains combined
 
   ea.alias
 , ce.event_cd
 , ce.result_val
 , ce.performed_dt_tm
 
 , Dept         	    = uar_get_code_display(max(e.loc_nurse_unit_cd))
 , Room         	    = uar_get_code_display(max(e.loc_room_cd))
 , Bed          	    = uar_get_code_display(max(e.loc_bed_cd))
 , Patient_id   	    = ea.alias ;max(evaluate(ea.encntr_alias_type_cd, fin_var,  ea.alias, 0, "")),
 , patient_name 	    = max(pe.name_full_formatted)
 , Line_Tube_Foley    = uar_get_code_display(ce.event_cd)
 ; tt1                = substring(1, (size(test_var,1)-9), test_var),
 , DTA_Documentation  = ce.result_val
 , Charting_Staff     = max(pr.name_full_formatted)
 , Insertion_DT       = format(max(ce.performed_dt_tm), "MM/DD/YYYY;;D")
 , Medical_necessity  = "not yet found"
 
 
from encounter e, encntr_alias ea, person pe, prsnl pr, clinical_event ce
 
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in (arterial_var , central1_var , central2_var , central3_var , chest1_var, chest2_var, enteral_var,
	endot1_var, endot12_var, epidural_var, gi_var, gast1_var, gast2_var, iabp_var, icp_var, intra_var, la1_var, la2_var,
	nb_var, pa1_var, pa2_var, pd_var, peri1_var, peri2_var, surgi_var, trac1_var, trac2_var, urin_var)
 
join pr where pr.person_id = ce.performed_prsnl_id
 
group by ea.alias, ce.event_cd, ce.result_val, ce.performed_dt_tm
 
order by ea.alias, ce.event_cd, ce.result_val, ce.performed_dt_tm
 


WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 





 
end
go





 
 
/*
;Lines
dept         = uar_get_code_display(e.loc_nurse_unit_cd),
room         = uar_get_code_display(e.loc_room_cd),
bed          = uar_get_code_display(e.loc_bed_cd),
patient_name = pe.name_full_formatted,
Patient_id   = "1727200017",
ce.event_cd,
Event_Name = uar_get_code_display(ce.event_cd),
Result = ce.result_val
 
from encntr_alias ea, encounter e, person pe, clinical_event ce, code_value cv1
 
plan ea where ea.alias = "1727200017"
 
join e where e.encntr_id = ea.encntr_id
 
join pe where pe.person_id = e.person_id
 
join ce where ce.encntr_id = ea.encntr_id
 
join cv1 where cv1.code_value = ce.event_cd
	and cv1.code_set =  72
	and cv1.active_ind = 1
	and cv1.display = "Central Line Activity."
	;and cv1.display like "*Central Line*"
	;and ce.encntr_id = 97764577.00 ; Fin - 1727200017
 */
 
;-------------------------------------------------------------------------------
 
/*
; Lines Test
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.result_val
from clinical_event ce, code_value cv
where ce.event_cd = cv.code_value
and cv.display_key = "*PERIPHERALIV*"
;and cv.display_key = "*LINE*"
 
;and ce.event_cd =    34439957.00 ; "Central Line Activity."
 
order by ce.encntr_id, ce.event_cd, ce.result_val
 
*/
 
 
;--------------------------------------------------------------------------------
 
/*
;Drains
 
Patient_Name = pe.name_full_formatted,
Patient_ID = "1727200016",
ce.event_cd,
Event_Name = uar_get_code_display(ce.event_cd),
Result = ce.result_val
 
from encntr_alias ea, encounter e, person pe, clinical_event ce ;, code_value cv1
 
plan ea where ea.alias = "1727200016"
 
join e where e.encntr_id = ea.encntr_id
 
join pe where pe.person_id = e.person_id
 
join ce where ce.encntr_id = ea.encntr_id
 
*/
;-------------------------------------------------------------------------------------
 
 

 
 
/*

  270303043.00	Gastrointestinal Tube Indication:


 
Lines, Tubes and Drains events used
 
CODE_VALUE	DISPLAY
 
2777044	Arterial Line Activity
17022196	Arterial Line Activity:
34439957	Central Line Activity.
2790519	Central IV Activity
17022216	Central IV Activity:
708751	Chest Tube Activity
17021982	Chest Tube Activity:
18710428	Enteral Tube Activity
2819441	Endotracheal Tube Activity
24599819	Endotracheal Tube Activity:
24602953	Epidural Line Activity:
24603834	GI Tube Activity:
712495	Gastric Tube Activity
270303167	Gastrointestinal Tube Activity:
24602533	IABP Line Activity:
24602276	ICP Line Activity:
24602786	Intraosseous Line Activity:
18757154	LA Line Activity
24600716	LA Line Activity:
22828705	NB Feeding Tube Activity:
2796864	PA Line Activity
24600397	PA Line Activity:
24603102	PD Line Activity:
703808	Peripheral IV Activity
17022182	Peripheral IV Activity:
18710410	Surgical Drain, Tube Activity:
2598509	Tracheostomy Tube Activity
24600022	Tracheostomy Tube Activity:
24604416	Urinary Catheter Activity:
 
 
 
 
select * from encntr_domain where encntr_id = 97764577
dept - nurse unit  2552512545.00	RMC ICU
RM   2552512549.00	ICU  ROOM
Bed  2552512561.00	3	BED
 
 
select event_cd, event_tag, result_val from clinical_event where encntr_id = 97764574.00 ;alias = "1727200016" 
 
select event_cd, event_tag, result_val from clinical_event where encntr_id = 97764577.00 ;"1727200017"
 
 
select * from encntr_alias where alias = "1727200017" ;encntr_id = 97764577.00
 
select * from clinical_event where encntr_id = 97764574.00 and event_cd = 38626709
 
   38626709.00	Medical Necessity for IRF Care
 
 
select ce.encntr_id, ce.event_cd, ce.event_tag, ce.result_val
from clinical_event ce, code_value cv
where ce.event_cd = cv.code_value
and cv.display_key = "*CENTRALLINE*"
 
 
 
/*
 
select * from encntr_alias where alias = "1727200017" ;encntr_id = 97764577.00
 
select * from encntr_alias where alias = "1727200016" ;encntr_id = 97764574.00
 
where alias in("1727200017", "1727200016")
 
select * from clinical_event where alias = encntr_id = 97764574.00
 
 
 
/*
code_value, display
 
FROM CODE_VALUE CV1
 
 
WHERE CV1.CODE_SET =  72
AND CV1.ACTIVE_IND = 1
and display like "Central Line*"
 
 
 
 
 
/*
SELECT into 'nl:'
 
FROM  v500_event_set_code vesc,
	  v500_event_set_explode vese,
	  v500_event_code vec
 
 
PLAN vesc
WHERE vesc.event_set_cd in (centlncd, periphivcd, artlinecd,artvenshthcd, pulmartlncd,IABPmgmtcd,
artvenacccd,leftatrlncd, rightatrlncd,ventassistdevcd)
JOIN vese
WHERE vesc.event_set_cd = vese.event_set_cd
JOIN vec
WHERE vese.event_cd = vec.event_cd
 
*/
 
 
 

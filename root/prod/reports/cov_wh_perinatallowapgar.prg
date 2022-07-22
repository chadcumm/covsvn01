/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Saravanan
	Date Written:		Sep'2017
	Solution:			Womens Health
	Source file name:	      cov_wh_perinatallowapgar.prg
	Object name:		cov_wh_perinatallowapgar
	Request #:			34
 
	Prompt Library :        cov_PromptLibrary.forms
	SubRoutine Library :    cov_CommonLibrary.inc
 	Program purpose:	      Perinatal Low Apgar information for delivery Providers
 	Executing from:		CCL
  	Special Notes:		Report on date range and Facility
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
 
drop program cov_wh_perinatallowapgar:DBA go
create program cov_wh_perinatallowapgar:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Facility" = 2552503613
 
with OUTDEV, start_date, end_date, facility
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
declare alias_poolcd_var     = f8 with constant(get_AliasPoolCode($facility)), protect
declare facility_name_var    = vc with constant(uar_get_code_description($facility)),protect
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare encounter_type_var   = f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NEWBORN")),protect
declare delivery_dt_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date, Time of Birth")),protect
declare delivery_phys_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Physician")),protect
declare other_provider_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Assistant Physician #1")),protect
declare delivery_method_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Delivery Type, Birth")),protect
declare oxytocin_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Induction Methods")),protect
declare maternal_comp_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Delivery Complications")),protect
declare vbac_var             = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "EDVBAC")),protect
declare ega_var              = f8 with constant(uar_get_code_by("DISPLAY", 72, "D-EGA at Documented Date, Time")),protect
declare gender_var           = f8 with constant(uar_get_code_by("DISPLAY", 72, "Gender")),protect
declare birth_weight_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Birth Weight")),protect
declare apgar_1min_var       = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR1MINUTEBYHISTORY")),protect
declare apgar_5min_var       = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR5MINUTEBYHISTORY")),protect
declare apgar_10min_var      = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "APGAR10MINUTEBYHISTORY")),protect
declare transfer_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Transferred To")),protect
declare infant_comp_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Neonate Complications")),protect
declare cord_ph_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Cord Blood Sent to Lab")),protect
declare shoulder_dys_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Nursing Shoulder Dystocia Interventions")),protect
declare delivery_ant_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Maternal Anesthesia Type")),protect
declare relation_var         = f8 with constant(uar_get_code_by("DISPLAYKEY", 351,  "DEFAULTGUARANTOR")),protect
declare delivery_vbac_var    = f8 with constant(uar_get_code_by("DISPLAYkEY", 4002119, "VBAC"))
declare num                  = i4 with constant(0),protect
declare initcap()            = c100
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;Create Record Structure
RECORD apgar_rec(
	1 plist[*]
		2 phys_name             = vc
		2 elist[*]
			3 facility_name   = vc
			3 mrn             = vc
			3 fin             = vc
			3 patient_name    = vc
			3 encounter_id    = f8
			3 delivery_date   = vc
			3 phys_name       = vc
			3 other_provider  = vc
			3 delivery_method = vc
			3 oxytocin        = vc
			3 maternal_comp   = vc
			3 vbac            = vc
			3 ega             = vc
			3 gender          = vc
			3 birth_weight    = vc;f8
			3 apgar_1min      = vc
			3 apgar_5min      = vc
			3 apgar_10min     = vc
			3 transfer        = vc
			3 infant_comp     = vc
			3 cord_ph         = vc
			3 shoulder_dys    = vc
			3 delivery_ant    = vc
)
 
;Select all delivery physicians
SELECT DISTINCT INTO "NL:"
	 ce.result_val	;delivery physician
from
	encounter e
	,clinical_event ce
 
plan e where e.reg_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
	and e.encntr_type_cd = encounter_type_var
	and e.loc_facility_cd = $facility
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd = delivery_phys_var
 
group by ce.result_val
 
order by ce.result_val
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
;populate Physicians in record structure
head report
 
cnt = 0
call alterlist(apgar_rec->plist, 100)
 
head ce.result_val
 	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(apgar_rec->plist, cnt+9)
	endif
 
	apgar_rec->plist[cnt].phys_name = ce.result_val
 
foot report
 
	call alterlist(apgar_rec->plist, cnt)
 
with nocounter
 
 
 
;Get delivery/encounter info and populate in record structure
 
SELECT DISTINCT INTO $outdev ;"NL:"
	ce1.result_val
	, e.encntr_id
	, ea1.alias
  	, fin              = max(evaluate(ea.encntr_alias_type_cd, fin_var,  ea.alias, 0, ""))
	, patient_name     = max(initcap(pe.name_full_formatted))
	, vbac             = uar_get_code_display(i.delivery_method_cd)
	, birth_weight     = max(evaluate(ce.event_cd, birth_weight_var,    ce.result_val, 0, "")) ;cnvtreal(ce.result_val)) * 1000)
					;NOTE : trying to covert birth weight into grams but sometimes data contains different characters
					;instead of decimal point and it throws "ORA - Invalid Number Error" so took of conversion
	, delivery_date    = max(evaluate(ce.event_cd, delivery_dt_var,     ce.result_val, 0, ""))
 	, phys_name        = max(evaluate(ce.event_cd, delivery_phys_var,   initcap(ce.result_val), 0, ""))
 	, other_provider   = max(evaluate(ce.event_cd, other_provider_var,  initcap(ce.result_val), 0, ""))
	, delivery_method  = max(evaluate(ce.event_cd, delivery_method_var, ce.result_val, 0, ""))
 	, oxytocin         = max(evaluate(ce.event_cd, oxytocin_var,        ce.result_val, 0, ""))
	, maternal_comp    = max(evaluate(ce.event_cd, maternal_comp_var,   ce.result_val, 0, ""))
	, ega              = max(evaluate(ce.event_cd, ega_var,             ce.result_val, 0, ""))
	, gender           = max(evaluate(ce.event_cd, gender_var,          ce.result_val, 0, ""))
	, apgar_1min       = max(evaluate(ce.event_cd, apgar_1min_var,      ce.result_val, 0, ""))
	, apgar_5min       = max(evaluate(ce.event_cd, apgar_5min_var,      ce.result_val, 0, ""))
	, apgar_10min      = max(evaluate(ce.event_cd, apgar_10min_var,     ce.result_val, 0, ""))
	, transfer         = max(evaluate(ce.event_cd, transfer_var,        ce.result_val, 0, ""))
	, infant_comp      = max(evaluate(ce.event_cd, infant_comp_var,     ce.result_val, 0, ""))
	, cord_ph          = max(evaluate(ce.event_cd, cord_ph_var,         ce.result_val, 0, ""))
	, shoulder_dys     = max(evaluate(ce.event_cd, shoulder_dys_var,    ce.result_val, 0, ""))
	, delivery_ant     = max(evaluate(ce.event_cd, delivery_ant_var,    ce.result_val, 0, ""))
 
FROM
	encounter   e
	, person   pe
	, encntr_alias   ea
	, encntr_alias ea1
	, clinical_event ce1
	, clinical_event ce
 
	,( ; Inline table to get VBAC
 		(select pc.person_id, pc.delivery_method_cd
 			from clinical_event ce, pregnancy_child pc, person_person_reltn pp, encounter e
 			where ce.person_id = pc.person_id
 				and e.person_id = ce.person_id
 				and e.encntr_id = ce.encntr_id
 				and e.reg_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
 				and e.encntr_type_cd = encounter_type_var ;2555267433.00
				and e.loc_facility_cd = $facility
				and e.active_ind = 1
 				and pp.person_id = ce.person_id
 				and pp.person_reltn_type_cd = relation_var ;1150.00
 				and pp.active_ind = 1
 				and pc.person_id = pp.related_person_id
 				and pc.delivery_method_cd = delivery_vbac_var ;4374260.00
 				and pc.active_ind = 1
  			WITH SQLTYPE("F8", "F8")
 		)i
 	 )
 
 plan i
 join e where outerjoin(e.person_id) = i.person_id
  	and e.reg_dt_tm between cnvtdatetime($start_date) and cnvtdatetime($end_date)
	and e.encntr_type_cd = encounter_type_var
	and e.loc_facility_cd = $facility
	and e.active_ind = 1
	;and e.encntr_id =  97733030.00
 
join pe where pe.person_id = e.person_id
	  and pe.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	  and ea.encntr_alias_type_cd = fin_var
	  and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	  and ea1.alias_pool_cd =  alias_poolcd_var
	  and ea1.encntr_alias_type_cd = mrn_var
	  and ea1.active_ind = 1
 
join ce1 where ce1.encntr_id = e.encntr_id
	and ce1.event_cd = delivery_phys_var
 
join ce where ce.encntr_id = e.encntr_id
	  and ce.event_cd in(delivery_phys_var, other_provider_var, birth_weight_var, delivery_method_var, oxytocin_var,
		maternal_comp_var, vbac_var, ega_var, gender_var, transfer_var, infant_comp_var, cord_ph_var, shoulder_dys_var,
		delivery_dt_var, delivery_ant_var, apgar_1min_var, apgar_5min_var, apgar_10min_var)
 
group by ea1.alias, e.encntr_id, ce1.result_val
 
order by ea1.alias, e.encntr_id, ce1.result_val
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
;Populate apgar_rec record structure with delivery info
head ce1.result_val
	numx = 0
	idx = 0
	ecnt = 0
 
	idx = locateval(numx, 1, size(apgar_rec->plist, 5), ce1.result_val, apgar_rec->plist[numx].phys_name)
	if(idx > 0)
		call alterlist(apgar_rec->plist[idx].elist, 10)
	endif
 
detail
	if (idx > 0)
		ecnt = ecnt + 1
		if (mod(ecnt, 10) = 1 and ecnt > 10)
			call alterlist(apgar_rec->plist[idx].elist, ecnt+9)
		endif
 		apgar_rec->plist[idx].elist[ecnt].facility_name   = facility_name_var
 		apgar_rec->plist[idx].elist[ecnt].mrn             = ea1.alias
		apgar_rec->plist[idx].elist[ecnt].fin             = fin
		apgar_rec->plist[idx].elist[ecnt].patient_name    = patient_name
		apgar_rec->plist[idx].elist[ecnt].encounter_id    = e.encntr_id
		apgar_rec->plist[idx].elist[ecnt].delivery_date   = delivery_date
		apgar_rec->plist[idx].elist[ecnt].phys_name       = phys_name
		apgar_rec->plist[idx].elist[ecnt].other_provider  = other_provider
		apgar_rec->plist[idx].elist[ecnt].delivery_method = delivery_method
		apgar_rec->plist[idx].elist[ecnt].oxytocin        = oxytocin
		apgar_rec->plist[idx].elist[ecnt].maternal_comp   = maternal_comp
		if(vbac = "VBAC")
			apgar_rec->plist[idx].elist[ecnt].vbac = "Yes"
		else
			apgar_rec->plist[idx].elist[ecnt].vbac = "No"
		endif
		apgar_rec->plist[idx].elist[ecnt].ega             = ega
		apgar_rec->plist[idx].elist[ecnt].gender          = gender
		apgar_rec->plist[idx].elist[ecnt].birth_weight    = birth_weight
		apgar_rec->plist[idx].elist[ecnt].apgar_1min      = apgar_1min
		apgar_rec->plist[idx].elist[ecnt].apgar_5min      = apgar_5min
		apgar_rec->plist[idx].elist[ecnt].apgar_10min     = apgar_10min
		apgar_rec->plist[idx].elist[ecnt].transfer        = transfer
		apgar_rec->plist[idx].elist[ecnt].infant_comp     = infant_comp
		apgar_rec->plist[idx].elist[ecnt].cord_ph         = cord_ph
		apgar_rec->plist[idx].elist[ecnt].shoulder_dys    = shoulder_dys
		apgar_rec->plist[idx].elist[ecnt].delivery_ant    = delivery_ant
	endif
 
 
foot ce1.result_val
 	call alterlist(apgar_rec->plist[idx].elist, ecnt)
 
 
with nocounter
 
 
 
;CALL ECHORECORD(apgar_rec)
 
;CALL ECHOJSON(apgar_rec, "rec.out", 0) ; To see values in RECORD STRUCTURE
 
 
 
 
/* not used ...... instead using Layout builder
 
; *** Display information from RECORD STRUCTURE by using REPORT WRITER ****
 
SELECT INTO $OUTDEV
 
	ELIST_PERSON_ID         = APGAR_REC->elist[D1.SEQ].person_id
	, ELIST_CORPORATE_NO    = APGAR_REC->elist[D1.SEQ].corporate_no
	, ELIST_ENCOUNTER_ID    = APGAR_REC->elist[D1.SEQ].encounter_id
	, ELIST_DELIVERY_DATE   = APGAR_REC->elist[D1.SEQ].delivery_date
	, ELIST_BIRTH_WEIGHT    = APGAR_REC->elist[D1.SEQ].birth_weight
	, ELIST_PATIENT_NAME    = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].patient_name)
	, ELIST_PHYS_NAME       = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].phys_name)
	, ELIST_OTHER_PROVIDER  = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].other_provider)
	, ELIST_DELIVERY_METHOD = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].delivery_method)
	, ELIST_OXYTOCIN        = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].oxytocin)
	, ELIST_MATERNAL_COMP   = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].maternal_comp)
	, ELIST_VBAC            = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].vbac)
	, ELIST_EGA             = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].ega)
	, ELIST_GENDER          = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].gender)
	, ELIST_APGAR_1MIN      = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].apgar_1min)
	, ELIST_APGAR_5MIN      = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].apgar_5min)
	, ELIST_APGAR_10MIN     = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].apgar_10min)
	, ELIST_TRANSFER        = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].transfer)
	, ELIST_INFANT_COMP     = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].infant_comp)
	, ELIST_CORD_PH         = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].cord_ph)
	, ELIST_SHOULDER_DYS    = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].shoulder_dys)
	, ELIST_DELIVERY_ANT    = SUBSTRING(1, 30, APGAR_REC->elist[D1.SEQ].delivery_ant)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(APGAR_REC->elist, 5)))
 
PLAN D1
 
ORDER BY ELIST_PHYS_NAME, ELIST_DELIVERY_DATE, ELIST_PERSON_ID
 
 
HEAD REPORT
	line_var      = FILLSTRING(210,"=")
	line_thin_var = FILLSTRING(210,"-")
	today_var     = FORMAT(CURDATE, "MM/DD/YYYY;;D")
	now_var       = FORMAT(CURTIME, "HH:MM:SS;;S")
 
	row 3
	col 80 "Perinatal Low Apgar Report by Delivery Provider"
	row +1
	col 90 "Report Date: "
	col +1 $start_date
	col +2 "To: "
	col +1 $end_date
	row +1
	col  0 line_var
	row +1
 
HEAD PAGE
	col 0  "Patient Name"
	col 50 "Delivery Doctor"
	row +1
	col 0  "Patient ID"
	col 50 "Other Provider"
	row +1
	col 0  "Apgars 1/5/10"
	row +1
	col  0 line_var
	row +1
 
HEAD ELIST_PHYS_NAME
	pcnt = 0 ; reset for every physician
	col 0 ELIST_PHYS_NAME
	row +1
	col 0 line_var
	row +1
 
DETAIL
	pcnt = pcnt + 1
 	col 1   elist_patient_name
	col 35  elist_phys_name
 
	row +1
	col 1   elist_person_id
	col 35  elist_other_provider
 
	row +1
      col 1   elist_apgar_1min
      col 3   "/"
      col 5   elist_apgar_5min
      col 7   "/"
      col 9   elist_apgar_10min
 
	row +1
	col 0 line_thin_var
	row +1
 
FOOT ELIST_PHYS_NAME
	col 1 "Total Infants :"
      col 17 pcnt
      row +1
     	col 0 line_var
     	row +1
 
 
 
WITH maxrec = 1000, maxcol = 300
*/
 
 
end
go
 
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
 
 
/*CODE VALUES USED
 
;Alias_pool_cd for MRN
 2554143663.00	STAR MRN - RMC
 2554143671.00	STAR MRN - MMC
 2554148457.00	STAR MRN - FSR
 2554148465.00	STAR MRN - CMC
 2554148473.00	STAR MRN - CLMC
 2554148483.00	STAR MRN - LCMC
 2554148493.00	STAR MRN - FLMC
 2554148501.00	STAR MRN - MHHS
 2554154983.00	STAR MRN - PW
 2554156611.00	STAR MRN - PBH
 2554158829.00	STAR MRN - TCSC
 
 
21102688.00	  Date, Time of Birth
21102625.00	  Maternal Delivery Physician
21102639.00	  Maternal Assistant Physician #1
21102674.00	  Delivery Type, Birth
21102562.00	  Maternal Induction Methods
--Oxytocin
27931307.00	  Maternal Delivery Complications
--;21102862	  EGA at Birth
273388755.00  D-EGA at Documented Date, Time
4169756.00	  Gender
712070.00	  Birth Weight
832675.00	  Apgar 5 Minute, by History
832678.00	  Apgar 1 Minute, by History
3338829.00	  Apgar 10 Minute, by History
21103070.00	  Neonate Transferred To
16728628.00	  Neonate Complications
4169630.00	  Cord Blood Sent to Lab
27931941.00	  Nursing Shoulder Dystocia
21812605.00	  Maternal Anesthesia Type
 
*/

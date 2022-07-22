 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			    Geetha Saravanan
	Date Written:		Apr'2018
	Solution:			OnCology
	Source file name:	cov_oc_clinical_trial.prg
	Object name:		cov_oc_clinical_trial
	Request#:			445
 
	Program purpose:	This report would help the clinical trial departments to data mine for patients
						based on diagnosis code group or specific code or range of codes
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_oc_clinical_trial:DBA go
create program cov_oc_clinical_trial:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "FacilityListBox" = 0
	, "Diagnosis Code" = ""
 
with OUTDEV, start_datetime, end_datetime, facility_list, icd_code
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()       = c100
declare icd_parser_var  = vc 
 
/**************************************************************
; RECORD STRUCTURE
**************************************************************/
RECORD trials(
	1 list[*]
		2 facility_code = f8
		2 facility_name = vc
 		2 plist[*]
			3 cmrn          = vc
			3 fin           = vc
			3 encounter_id  = f8
			3 pat_dob       = dq8
			3 pat_name      = vc
			3 phys_attend   = vc
			3 diagnosis     = vc
			3 icd_code      = vc
			3 stage         = vc
 			3 rlist[*]
 				4 regimen   = vc
 				4 last_dose = dq8
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 /*
IF ($icd_code != "");with icd code 
	set icd_parser_var =  "n.source_identifier = $icd_code"
elseif ($icd_code = "");without icd code 
	set icd_parser_var =  "n.source_identifier != ' ' " 
endif	
 */
 
 
SELECT IF ($icd_code != "");without icd code
 
	  facility = uar_get_code_display(e.loc_facility_cd)
	, CMRN = ea.alias
	, FIN = ea1.alias
	, e.encntr_id
	, DOB = p.birth_dt_tm
	, pt_name = initcap(p.name_full_formatted)
	, Attending = initcap(d.diag_prsnl_name)
	, diag = d.diagnosis_display
	, ICD = n.source_identifier
	, stage = ce.result_val
	, Regimn = pw.pw_group_desc
	, l_dose = pw.end_effective_dt_tm
 
	from
	  encounter e
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, diagnosis d
	, nomenclature n
	, clinical_event ce
	, pathway pw
 
	plan e where e.loc_facility_cd = $facility_list
		;and e.encntr_id = 104009006
		and e.active_ind = 1
 
	join ea where ea.encntr_id = e.encntr_id
		and ea.active_ind = 1
		and ea.alias_pool_cd in(
			 2554143671.00,	;STAR MRN - MMC
			 2554148457.00,	;STAR MRN - FSR
			 2554148493.00,	;STAR MRN - FLMC
			 2554154983.00,	;STAR MRN - PW
			 2554158829.00	;STAR MRN - TCSC
			 )
 
	join ea1 where ea1.encntr_id = e.encntr_id
		and ea1.alias_pool_cd = 2554138251.00 ;FIN
		and ea1.active_ind = 1
 
	join p where p.person_id = e.person_id
		and p.active_ind = 1
 
	join d where d.encntr_id = e.encntr_id
			;and sa.beg_dt_tm between cnvtdatetime("01-MAR-2018 00:00:00") and cnvtdatetime("31-DEC-2018 23:59:00")
		and d.diag_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and d.active_ind = 1
 
	join n where n.nomenclature_id = d.nomenclature_id
		and n.source_identifier = $icd_code
		;and parser(icd_parser_var)
		and n.active_ind = 1
 
	join ce where ce.encntr_id = outerjoin(e.encntr_id)
	    and ce.event_cd = 19980503.00 ;staging
 
	join pw where pw.encntr_id = outerjoin(e.encntr_id)
		and pw.active_ind = 1
		and pw.pathway_type_cd = 20584402.00  ;Oncology
 
ELSEIF ($icd_code = "");without icd code
 
	  facility = uar_get_code_display(e.loc_facility_cd)
	, CMRN = ea.alias
	, FIN = ea1.alias
	, e.encntr_id
	, DOB = p.birth_dt_tm
	, pt_name = initcap(p.name_full_formatted)
	, Attending = initcap(d.diag_prsnl_name)
	, diag = d.diagnosis_display
	, ICD = n.source_identifier
	, stage = ce.result_val
	, Regimn = pw.pw_group_desc
	, l_dose = pw.end_effective_dt_tm
 
	from
	  encounter e
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, diagnosis d
	, nomenclature n
	, clinical_event ce
	, pathway pw
 
	plan e where e.loc_facility_cd = $facility_list
		;and e.encntr_id = 104009006
		and e.active_ind = 1
 
	join ea where ea.encntr_id = e.encntr_id
		and ea.active_ind = 1
		and ea.alias_pool_cd in(
			 2554143671.00,	;STAR MRN - MMC
			 2554148457.00,	;STAR MRN - FSR
			 2554148493.00,	;STAR MRN - FLMC
			 2554154983.00,	;STAR MRN - PW
			 2554158829.00	;STAR MRN - TCSC
			 )
 
	join ea1 where ea1.encntr_id = e.encntr_id
		and ea1.alias_pool_cd = 2554138251.00 ;FIN
		and ea1.active_ind = 1
 
	join p where p.person_id = e.person_id
		and p.active_ind = 1
 
	join d where d.encntr_id = e.encntr_id
			;and sa.beg_dt_tm between cnvtdatetime("01-MAR-2018 00:00:00") and cnvtdatetime("31-DEC-2018 23:59:00")
		and d.diag_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and d.active_ind = 1
 
	join n where n.nomenclature_id = d.nomenclature_id
		and n.active_ind = 1
 
	join ce where ce.encntr_id = outerjoin(e.encntr_id)
	    and ce.event_cd = 19980503.00 ;staging
 
	join pw where pw.encntr_id = outerjoin(e.encntr_id)
		and pw.active_ind = 1
		and pw.pathway_type_cd = 20584402.00  ;Oncology
 
ENDIF
DISTINCT INTO "NL:" ;$OUTDEV
 
from dummyt
 
order by e.loc_facility_cd, p.name_full_formatted, pw.end_effective_dt_tm, d.diagnosis_display, ce.result_val
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT;, MAXREC = 1000
 
 
;Load into Record Structure
HEAD REPORT
 
	fcnt = 0
	call alterlist(trials->list, 10)
 
HEAD e.loc_facility_cd
 	fcnt = fcnt + 1
	if(mod(fcnt, 10) = 1 and fcnt > 100)
		call alterlist(trials->list, fcnt+9)
	endif
	trials->list[fcnt].facility_code = e.loc_facility_cd
	trials->list[fcnt].facility_name = uar_get_code_description(e.loc_facility_cd)
	pcnt = 0
 
HEAD e.encntr_id ; patients
	pcnt = pcnt + 1
	call alterlist(trials->list[fcnt].plist, pcnt)
 
	trials->list[fcnt].plist[pcnt].cmrn         = trim(ea.alias)
	trials->list[fcnt].plist[pcnt].diagnosis    = trim(d.diagnosis_display)
	trials->list[fcnt].plist[pcnt].encounter_id = e.encntr_id
	trials->list[fcnt].plist[pcnt].fin          = trim(ea1.alias)
	trials->list[fcnt].plist[pcnt].icd_code     = trim(n.source_identifier)
	trials->list[fcnt].plist[pcnt].pat_dob      = p.birth_dt_tm
	trials->list[fcnt].plist[pcnt].pat_name     = trim(pt_name)
	trials->list[fcnt].plist[pcnt].phys_attend  = trim(attending)
	trials->list[fcnt].plist[pcnt].stage        = trim(ce.result_val)
	rcnt = 0
DETAIL
	rcnt = rcnt + 1
	call alterlist(trials->list[fcnt].plist[pcnt].rlist, rcnt)
 
	trials->list[fcnt].plist[pcnt].rlist[rcnt].regimen   = trim(pw.pw_group_desc)
	trials->list[fcnt].plist[pcnt].rlist[rcnt].last_dose = pw.end_effective_dt_tm
 
FOOT ea.encntr_id
 	call alterlist(trials->list[fcnt].plist[pcnt].rlist, rcnt)
 
FOOT REPORT
 	call alterlist(trials->list, fcnt)
 
WITH nocounter
 
;call echojson(trials,"rec.out", 0)
;call echorecord(trials)
 
 
end
go
 
 
 
/*
 
select * from prsnl where name_first_key = "Gee
 
select * from prsnl where username = "GSARAVAN"
 
select * from encntr_alias where ea.alias = '1807800015' ;eid = 104009006.00
 
select * from encounter where encntr_id = 104009006 ; location-cd =  2553766379.00
 
select * from diagnosis where encntr_id = 104009006
 
select * from diagnosis_hist where encntr_id = 104009006
 
select * from clinical_event where encntr_id = 104009006
 
select * from clinical_event where encntr_id = 104009006
 
select * from orders where encntr_id = 104009006
 
select * from pathway where encntr_id = 104009006
 
select * from med_admin_event where order_id =   378584939.00
 
select distinct source_identifier from nomenclature
 
 
select ol.*
from order_alias ol, orders o
where ol.order_id = o.order_id
and o.encntr_id = 104009006.00
 
 
 
 
Alias_Pool_Cd
 
 2554138251.00 - FIN
 2554158829.00 - CMRN(powerchart)
 
 
 ;FACILITIES USED
 21250403.00	FSR	  			FACILITY	Fort Sanders Regional Medical Center	FSR
 2552503613.00	MMC	 			FACILITY	Methodist Medical Center	            MMC
 2552503645.00	PW	  			FACILITY	Parkwest Medical Center	                PW
 2552503635.00	FLMC  			FACILITY	Fort Loudoun Medical Center	            FLMC
 2553765659.00	TOG Downtown	FACILITY	Thompson Oncology Group - Downtown	    TOGDOWNTOWN
 2553765699.00	TOG West	    FACILITY	Thompson Oncology Group - West	        TOGWEST
 2555024817.00	TOG Oak Ridge	FACILITY	Thompson Oncology Group - Oak Ridge		TOGOAKRIDGE
 2553765667.00	TOG Lenoir City	FACILITY	Thompson Oncology Group - Lenoir City	TOGLENOIRCITY
 
 ;mrn
 2554143671.00	STAR MRN - MMC
 2554148457.00	STAR MRN - FSR
 2554148493.00	STAR MRN - FLMC
 2554154983.00	STAR MRN - PW
 2554158829.00	STAR MRN - TCSC
 
 
select * from code_value
where code_value in (2554143663.00, 2554143671.00, 2554148457.00, 2554148465.00, 2554148473.00,
 2554148483.00, 2554148493.00, 2554148501.00, 2554154983.00, 2554156611.00, 2554158829.00)
and code_set = 220
 
 
/**** To get Drug name and administered date
,(
	(select distinct o.encntr_id, o.order_mnemonic, format(max(o.valid_dose_dt_tm),"@SHORTDATETIME") ; mindt
	 from orders o
	 where o.encntr_id = 104009006.00
	 and o.valid_dose_dt_tm < CNVTDATETIME(CURDATE-1,CURTIME)
	 group by o.encntr_id, o.order_mnemonic
	 with sqltype("f8", "vc", "dq8")
	)i
 )
 
 
,(
	(select o.encntr_id, o.order_mnemonic, maxdt = format(max(o.valid_dose_dt_tm),"@SHORTDATETIME")
	 from orders o
	 where o.encntr_id = 104009006.00
	 and o.valid_dose_dt_tm > CNVTDATETIME(CURDATE-1,CURTIME)
	 and o.order_status_cd in(2546.00, 2550.00)
	 group by o.encntr_id, o.order_mnemonic
	 with sqltype("f8", "vc", "vc")
	)i2
 )
 */
 

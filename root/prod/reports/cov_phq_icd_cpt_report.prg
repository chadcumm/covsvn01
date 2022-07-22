/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Oct'2021
	Solution:			Quality
	Source file name:  	cov_phq_icd_cpt_report.prg
	Object name:		cov_phq_icd_cpt_report
	Request#:
 	Program purpose:
	Executing from:		DA2
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer	     Comment
------------------------------------------------------------------------------
Oct'2021 	Geetha    Initial Release
07/05/2022  Geetha    CR#13188 - Add MHA location  
******************************************************************************/
 
 
drop program cov_phq_icd_cpt_report:dba go
create program cov_phq_icd_cpt_report:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Select Nurse Unit" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list, nurse_unit
 
 
call echo(build2('$acute_facility_list = ', $acute_facility_list))
;go to exitscript
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare opr_nu_var = vc with noconstant(''), public
declare ncnt = i4 with noconstant(0)
 
;nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "l");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else									 ;a single value was selected
	set opr_nu_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 unit = vc
		2 fin = vc
		2 pat_name = vc
		2 encntrid = f8
		2 personid = f8
		2 regdt = vc
		2 dshdt = vc
		2 nomen_cnt = i4
		2 nlist[*]
			3 nomenid = f8
			3 contribute_sys = vc
			3 entity = vc
			3 source_voca_cd = vc
			3 diag_priority = f8
			3 diag_typ = vc
			;3 icd10 = vc
			;3 hcpscd = vc
			3 source = vc
			3 source_id = vc
			3 coding_source = vc
	)
 
;-----------------------------------------------------------------------------------------------------------
;Patient population via Diagnosis
 
select into $outdev
 
fin = ea.alias, e.encntr_id, n.nomenclature_id, n.source_vocabulary_cd, n.source_identifier, n.source_string
,d.diag_priority, d.diag_type_cd, d.contributor_system_cd, d.parent_entity_name, d.updt_dt_tm, e.loc_nurse_unit_cd
 
from encounter e
	,diagnosis d
	,nomenclature n
	,coding c
	,encntr_alias ea
 
plan e where e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $acute_facility_list
	and operator(e.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	and e.active_ind = 1
 
join c where c.encntr_id = e.encntr_id
	and c.active_ind = 1
 
join d where d.encntr_id = c.encntr_id
	and d.contributor_system_cd = c.contributor_system_cd
	and d.active_ind = 1
 
join n where n.nomenclature_id = d.nomenclature_id
	;and n.source_vocabulary_cd in(19350056.00,1222.00);ICD-10-CM, HCPCS
 	and n.active_ind = 1
 
join ea where ea.encntr_id = d.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by e.encntr_id, n.source_vocabulary_cd, d.diag_priority
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	call alterlist(pat->plist, cnt)
	pat->rec_cnt = cnt
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->plist[cnt].unit = uar_get_code_display(e.loc_nurse_unit_cd)
	pat->plist[cnt].regdt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm;;q')
	pat->plist[cnt].dshdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;q')
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].personid = e.person_id
	pat->plist[cnt].fin = ea.alias
	ncnt = 0
Head n.nomenclature_id
	ncnt += 1
	call alterlist(pat->plist[cnt].nlist, ncnt)
	pat->plist[cnt].nlist[ncnt].nomenid = n.nomenclature_id
	pat->plist[cnt].nlist[ncnt].source = n.source_string
	pat->plist[cnt].nlist[ncnt].source_id = n.source_identifier
	pat->plist[cnt].nlist[ncnt].contribute_sys = uar_get_code_display(d.contributor_system_cd)
	pat->plist[cnt].nlist[ncnt].entity = d.parent_entity_name
	pat->plist[cnt].nlist[ncnt].diag_priority = d.diag_priority
	pat->plist[cnt].nlist[ncnt].diag_typ = uar_get_code_display(d.diag_type_cd)
	pat->plist[cnt].nlist[ncnt].source_voca_cd = uar_get_code_display(n.source_vocabulary_cd)
	pat->plist[cnt].nlist[ncnt].coding_source = uar_get_code_display(n.principle_type_cd)
Foot e.encntr_id
	pat->plist[cnt].nomen_cnt = ncnt
 
with nocounter
 
;----------------------------------------------------------------------------------------------
;Demographic
 
select into 'nl:'
 
from  (dummyt d WITH seq = value(size(pat->plist,5)))
	, person p
 
plan d
 
join p where p.person_id = pat->plist[d.seq].personid
	and p.active_ind = 1
 
order by p.person_id
 
Head p.person_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,p.person_id ,pat->plist[icnt].personid)
       if(idx > 0)
		pat->plist[idx].pat_name = p.name_full_formatted
    	endif
 
With nocounter
 
;----------------------------------------------------------------------------------------------
;HCPCS/CPT
 
select into $outdev
 
fin = substring(1, 30, pat->plist[d.seq].fin), c.encntr_id
, source_vocabulary = uar_get_code_display(n.source_vocabulary_cd)
, n.source_string, n.source_identifier
 
from (dummyt d WITH seq = value(size(pat->plist,5)))
	,coding c
 	,procedure p
 	,nomenclature n
 
plan d
 
join c where c.encntr_id = pat->plist[d.seq].encntrid ; 124970785.00
	and c.active_ind = 1
 
join p where p.encntr_id = c.encntr_id
	and p.active_ind = 1
 
join n where n.nomenclature_id = P.nomenclature_id
	and n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"HCPCS"))
 
order by c.encntr_id, n.nomenclature_id
 
Head c.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,c.encntr_id ,pat->plist[icnt].encntrid)
      ncnt = pat->plist[idx].nomen_cnt
      ;call echo(build('nomen cnt = ', ncnt))
Head n.nomenclature_id
	ncnt += 1
	call alterlist(pat->plist[idx].nlist, ncnt)
	;call echo(build('nomen cnt inside = ', ncnt))
	pat->plist[idx].nlist[ncnt].source_id = n.source_identifier
	pat->plist[idx].nlist[ncnt].source = n.source_string
	pat->plist[idx].nlist[ncnt].source_voca_cd = uar_get_code_display(n.source_vocabulary_cd)
	pat->plist[idx].nlist[ncnt].coding_source = uar_get_code_display(n.principle_type_cd)
with nocounter
 
call echorecord(pat)
 
;-------------------------------------------------------------------------------------------------------------
 
select into $outdev
	facility = substring(1, 30, pat->plist[d1.seq].facility)
	, nurse_unit = substring(1, 30, pat->plist[d1.seq].unit)
	, fin = substring(1, 30, pat->plist[d1.seq].fin)
	, patient_name = substring(1, 50, pat->plist[d1.seq].pat_name)
	;, encntr_id = pat->plist[d1.seq].encntrid
	, discharge_dt = substring(1, 30, pat->plist[d1.seq].dshdt)
	, source = substring(1, 500, pat->plist[d1.seq].nlist[d2.seq].source)
	, coding_type = substring(1, 30, pat->plist[d1.seq].nlist[d2.seq].diag_typ)
	, icd_hcpcs = substring(1, 30, pat->plist[d1.seq].nlist[d2.seq].source_id)
	, coding_source = substring(1, 30, pat->plist[d1.seq].nlist[d2.seq].coding_source)
	;, diagnosis_priority = pat->plist[d1.seq].nlist[d2.seq].diag_priority
	, source_vocabulary = substring(1, 100, pat->plist[d1.seq].nlist[d2.seq].source_voca_cd)
 
from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(pat->plist[d1.seq].nlist, 5))
join d2
 
order by fin
 
with nocounter, separator=" ", format
 
 
 
#exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 
;with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
;go to exitscript


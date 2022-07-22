drop program cov_bh_PBHProviderPatients:DBA go
create program cov_bh_PBHProviderPatients:DBA
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:				Dan Herren
	Date Written:		September 2018
	Solution:			Behavorial Health
	Source file name:  	cov_bh_PBHProviderPatients.prg
	Object name:		cov_bh_PBHProviderPatients
	CR#:				2735
 
	Program purpose:	Report of PBH patients seen by provider.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  --------------------  ----------------------------
*
*
******************************************************************************/
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Clinic" = VALUE(0.0, 1                                       )
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, CLINIC, START_DATETIME, END_DATETIME
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare LOC_BLOUNT_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBBBCG")),protect
declare LOC_LOUDON_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBLLCG")),protect
declare LOC_KNOX_VAR         = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBLHKCG")),protect
declare LOC_LGTHOUSE_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBLHLTG")),protect
declare LOC_SMKYMTN_VAR      = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBSSHG")),protect
declare LOC_SEVIER_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBSSOG")),protect
declare LOC_PBHUNITA_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBHUA")),protect
declare LOC_PBHUNITB_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBHUB")),protect
declare LOC_PBHUNITD_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBHUD")),protect
declare LOC_PBHUNITE_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBHUE")),protect
declare LOC_PBHUNITF_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBHUF")),protect
;
declare POS_BHNURSEPRACT_VAR  = f8 with constant(uar_get_code_by("DISPLAYKEY", 88, "BHFAMILYNURSEPRACTITIONER")),protect
declare POS_BHFAMILYPRACT_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY", 88, "PHYSICIANBHFAMPRAC")),protect
declare POS_NURSEPRACT_VAR    = f8 with constant(uar_get_code_by("DISPLAYKEY", 88, "NURSEPRACTITIONER")),protect
declare POS_PSYCHIATRY_VAR    = f8 with constant(uar_get_code_by("DISPLAYKEY", 88, "PHYSICIANPSYCHIATRY")),protect
;
declare HPI_VAR              = f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "HISTORYOFPRESENTILLNESSDOCUMENTATION")),protect
declare MRN_VAR              = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN")),protect
declare FIN_VAR              = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare OPR_CLINIC_VAR       = vc with noconstant(fillstring(1000," "))
declare username             = vc with protect
;
; Set Facility Variable
if(substring(1,1,reflect(parameter(parameter2($CLINIC),0))) = "L") ;multiple facilities were selected
	set OPR_CLINIC_VAR = "in"
	elseif(parameter(parameter2($CLINIC),1) = 0.0) ;all (any) facility were selected
		set OPR_CLINIC_VAR = "!="
	else ;a single value was selected
		set OPR_CLINIC_VAR = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
Record ord(
	1 username          = vc
	1 startdate         = c50
	1 enddate           = c50
	1 list[*]
		2 facility      = c15
		2 clinic_abbr   = c15
		2 clinic_name   = c30
		2 dos           = dq8
		2 provider_name = c35
		2 prov_position = c50
		2 pat_name      = c35
		2 fin           = vc
		2 mrn           = vc
		2 pat_status	= c20
		2 encntr_id     = f8
		2 clinic_cnt    = i4
		2 provider_cnt  = i4
		2 total_cnt		= i4
)
 
;Set Username
select into "NL:"
from prsnl p
where p.person_id = reqinfo->updt_id
detail ord->username = p.username
with nocounter
 
;Set Date Prompts
set ord->startdate = $START_DATETIME ;substring(1,11,$START_DATETIME)
set ord->enddate   = $END_DATETIME   ;substring(1,11,$END_DATETIME)
 
select distinct into "NL:"
;select into $OUTDEV
 	 facility      = uar_get_code_display(e.loc_facility_cd)
 	,clinic_abbr   = uar_get_code_display(e.loc_nurse_unit_cd)
 	,clinic_name   = uar_get_code_description(e.loc_nurse_unit_cd)
 	,dos           = MIN(ce.performed_dt_tm) OVER(PARTITION BY ce.encntr_id)
 	,provider_name = MAX(pl.name_full_formatted) KEEP (DENSE_RANK FIRST ORDER BY ce.performed_dt_tm DESC) OVER (
 					PARTITION BY ce.encntr_id)
	,prov_position = MAX(pl.position_cd) KEEP (DENSE_RANK FIRST ORDER BY ce.performed_dt_tm DESC) OVER (
					PARTITION BY ce.encntr_id)
	,pat_name      = p.name_full_formatted
	,fin           = ea.alias
	,mrn           = ea2.alias
	,pat_status    = uar_get_code_description(e.encntr_status_cd)
	,encntr_id     = e.encntr_id
	,clinic_cnt    = count(distinct(ea.alias)) over(partition by e.loc_nurse_unit_cd)
	,provider_cnt  = count(distinct(ea.alias)) over(partition by ce.performed_prsnl_id, e.loc_nurse_unit_cd)
	,total_cnt     = count(distinct(ea.alias)) over()
 
from
	 CLINICAL_EVENT  ce
	,(inner join ENCOUNTER e on e.encntr_id = ce.encntr_id
		and e.person_id = ce.person_id
		and operator(e.loc_nurse_unit_cd, OPR_CLINIC_VAR, $CLINIC)
		and e.loc_nurse_unit_cd in (
			LOC_BLOUNT_VAR, LOC_LOUDON_VAR, LOC_KNOX_VAR, LOC_LGTHOUSE_VAR, LOC_SMKYMTN_VAR, LOC_SEVIER_VAR,
			LOC_PBHUNITA_VAR, LOC_PBHUNITB_VAR, LOC_PBHUNITD_VAR, LOC_PBHUNITE_VAR, LOC_PBHUNITF_VAR)
		and e.active_ind = 1
		and e.end_effective_dt_tm >= CNVTDATETIME("31-DEC-2100 0")
	 )
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
		and ea.end_effective_dt_tm > sysdate
		and ea.active_ind = 1
	 )
	,(left join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_VAR ;1079
		and ea2.end_effective_dt_tm > sysdate
		and ea2.active_ind = 1
	 )
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1
	 )
	,(inner join PRSNL pl on pl.person_id = ce.performed_prsnl_id
		and pl.position_cd in (POS_BHNURSEPRACT_VAR, POS_BHFAMILYPRACT_VAR, POS_NURSEPRACT_VAR, POS_PSYCHIATRY_VAR)
		and pl.active_ind = 1
	 )
 
where ce.event_cd = 22931573
	and CNVTUPPER(ce.event_tag) = "HISTORY OF PRESENT ILLNESS DOCUMENTATION"
;	and ce.encntr_id = 111654735
	and ce.performed_dt_tm between cnvtdatetime($START_DATETIME) and cnvtdatetime($END_DATETIME)
 
order by clinic_name, provider_name, pat_name, encntr_id
 
head report
	cnt  = 0
 
detail
 	cnt = cnt + 1
	call alterlist(ord->list, cnt)
 
	ord->list[cnt].facility       = facility
	ord->list[cnt].clinic_abbr    = clinic_abbr
	ord->list[cnt].clinic_name    = clinic_name
	ord->list[cnt].dos 		 	  = ce.performed_dt_tm
    ord->list[cnt].provider_name  = pl.name_full_formatted
    ord->list[cnt].prov_position  = uar_get_code_display(prov_position)
	ord->list[cnt].pat_name       = p.name_full_formatted
	ord->list[cnt].fin 		 	  = fin
	ord->list[cnt].mrn            = mrn
	ord->list[cnt].pat_status     = pat_status
	ord->list[cnt].encntr_id      = encntr_id
	ord->list[cnt].clinic_cnt	  = clinic_cnt
	ord->list[cnt].provider_cnt   = provider_cnt
	ord->list[cnt].total_cnt	  = total_cnt
 
with nocounter
 
;CALL ECHORECORD(ORD)
 
;go to EXITSCRIPT
 
;============================
; REPORT OUTPUT
;============================
;select into "NL:"
select distinct into value ($OUTDEV)
	 facility       = ord->list[d.seq].facility
	,clinic_abbr    = ord->list[d.seq].clinic_abbr
	,clinic_name    = ord->list[d.seq].clinic_name
    ,clinic_cnt     = ord->list[d.seq].clinic_cnt
    ,dos		    = ord->list[d.seq].dos
	,provider_name  = ord->list[d.seq].provider_name
    ,provider_cnt   = ord->list[d.seq].provider_cnt
 	,prov_position  = ord->list[d.seq].prov_position
	,pat_name	    = ord->list[d.seq].pat_name
	,fin		    = ord->list[d.seq].fin
	,mrn		    = ord->list[d.seq].mrn
	,pat_status     = ord->list[d.seq].pat_status
	,encntr_id      = ord->list[d.seq].encntr_id
	,total_cnt	    = ord->list[d.seq].total_cnt
	,startdate 	    = ord->startdate
	,enddate   	    = ord->enddate
 
from
	(dummyt d  with seq = value(size(ord->list,5)))
 
plan d
 
order by clinic_name, provider_name, pat_name, encntr_id
with nocounter, format, check, separator = " "
 
;#EXITSCRIPT
end
go

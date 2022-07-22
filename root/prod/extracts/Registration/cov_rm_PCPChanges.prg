/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/26/2019
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_PCPChanges.prg
	Object name:		cov_rm_PCPChanges
	Request #:			5429 (6016)
 
	Program purpose:	Lists patients and an audit trail of changes made to PCPs.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_rm_PCPChanges:dba go
create program cov_rm_PCPChanges:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0                   ;* Output to file
 
with OUTDEV, start_datetime, end_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare cmrn_var				= f8 with constant(uar_get_code_by("MEANING", 4, "CMRN"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare orgdoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "ORGANIZATIONDOCTOR"))
declare pcp_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 331, "PRIMARYCAREPHYSICIAN"))
 
 
declare file_var				= vc with constant("pcp_changes.csv")
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/Registration/", file_var))
 
declare output_var				= vc with noconstant("")
 
declare num						= i4 with noconstant(0)
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select patient pcp data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, format(date, "mm/dd/yyyy hh:mm;;q")
else
	with nocounter, separator = " ", format, format(date, "mm/dd/yyyy hh:mm;;q")
endif
 
distinct into value(output_var)
	patient_id = ppr.person_id
	, patient_name = p.name_full_formatted
	, cmrn = pa.alias
	, fin = max(ea.alias) over(partition by ppr.prsnl_person_id, ppr.beg_effective_dt_tm)
	, facility = max(cvo.alias) over(partition by ppr.prsnl_person_id, ppr.beg_effective_dt_tm)
	, encntr_id = max(pht.encntr_id) over(partition by ppr.prsnl_person_id, ppr.beg_effective_dt_tm)
 
	, pcp_id = ppr.prsnl_person_id
	, pcp_name = per.name_full_formatted
	, pcp_alias = pera.alias
 
	, ppr.beg_effective_dt_tm
	, ppr.end_effective_dt_tm
	, ppr.active_ind
 
	, ppr.updt_id
	, updt_name = per2.name_full_formatted
	, ppr.updt_dt_tm
 
from
	PERSON_PRSNL_RELTN ppr
 
	, (inner join PRSNL per on per.person_id = ppr.prsnl_person_id
		and per.physician_ind = 1)
 
	, (inner join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = orgdoc_var
		and pera.end_effective_dt_tm > sysdate
		and pera.active_ind = 1)
 
	, (inner join PRSNL per2 on per2.person_id = ppr.updt_id)
 
	, (inner join PERSON p on p.person_id = ppr.person_id)
 
	, (inner join PERSON_ALIAS pa on pa.person_id = p.person_id
		and pa.person_alias_type_cd = cmrn_var
		and pa.end_effective_dt_tm > sysdate
		and pa.active_ind = 1)
 
	, (left join PERSON_PRSNL_RELTN_HISTORY pprh on pprh.person_prsnl_reltn_id = ppr.person_prsnl_reltn_id
		and pprh.beg_effective_dt_tm = ppr.beg_effective_dt_tm)
 
	, (left join PM_HIST_TRACKING pht on pht.pm_hist_tracking_id = pprh.pm_hist_tracking_id
		and pht.encntr_id > 0.0)
 
	, (left join ENCOUNTER e on e.encntr_id = pht.encntr_id)
 
	, (left join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd)
 
	, (left join ENCNTR_ALIAS ea on ea.encntr_id = pht.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.end_effective_dt_tm > sysdate
		and ea.active_ind = 1)
 
where
	1 = 1
	and ppr.person_prsnl_r_cd = pcp_var
;	and ppr.person_id = 12404016.00
	and ppr.updt_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
order by
	ppr.person_id
	, ppr.beg_effective_dt_tm
	, ppr.end_effective_dt_tm
	, 0
 
 
/**************************************************************/
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

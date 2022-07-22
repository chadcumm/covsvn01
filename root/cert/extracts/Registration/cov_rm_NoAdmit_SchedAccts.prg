/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/27/2018
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_NoAdmit_SchedAccts.prg
	Object name:		cov_rm_NoAdmit_SchedAccts
	Request #:			3754
 
	Program purpose:	Select data for Cerner scheduled accounts that were not
						admitted to be extracted to files.
 
	Executing from:		CCL
 
 	Special Notes:		Output files:
 							noadmit_daily.csv
 							noadmit_monthly.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	11/28/2019	Todd A. Blanchard		Added encounter type.
 	11/29/2019	Todd A. Blanchard		Added datetime stamps to file names.
 	11/30/2019	Todd A. Blanchard		Adjusted logic for MRN.
 	12/04/2019	Todd A. Blanchard		Adjusted logic for FIN.
 	01/22/2019	Todd A. Blanchard		Removed datetime stamps from file names.
 										Added patient deceased flag to daily query.
 										Adjusted daily query criteria to provide facilities
 										"B", "F", "L", "M", "P", "R", "S" for outbound aliases.
 	01/23/2019	Todd A. Blanchard		Adjusted daily query criteria to provide facility
 										"A" for outbound aliases.
 										Added alias for encounter location facility.
 	01/24/2019	Todd A. Blanchard		Adjusted daily query criteria for code value aliases.
 	01/28/2019	Todd A. Blanchard		Adjusted monthly query to match adjustments made to daily query.
 	02/01/2019	Todd A. Blanchard		Added total charges for encounters.
 	02/06/2019	Todd A. Blanchard		Added documents, notes, and orders for encounters.
 
******************************************************************************/
 
drop program cov_rm_NoAdmit_SchedAccts:DBA go
create program cov_rm_NoAdmit_SchedAccts:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "File Type" = 0
 
with OUTDEV, file_type
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare emrn_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare pmrn_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "MRN"))
declare cmrn_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "COMMUNITYMEDICALRECORDNUMBER"))
declare cernermrn_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "CERNERMRN"))
declare covenant_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
declare patient_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 14250, "PATIENT"))
declare canceled_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CANCELED"))
 
;declare file_dt_tm			= vc with constant(format(sysdate, "yyyymmddhhmm;;d"))
 
;declare file_acute_var		= vc with constant(build("noadmit_sched_acute_", file_dt_tm, ".csv"))
;declare file_pbh_var		= vc with constant(build("noadmit_sched_pbh_", file_dt_tm, ".csv"))
declare file_acute_var		= vc with constant(build("noadmit_sched_acute", ".csv"))
declare file_pbh_var		= vc with constant(build("noadmit_sched_pbh", ".csv"))
 
declare temppath_var		= vc with constant("cer_temp:")
declare temppath_acute_var	= vc with constant(build(temppath_var, file_acute_var))
declare temppath_pbh_var	= vc with constant(build(temppath_var, file_pbh_var))
 
declare temppath2_var		= vc with constant("$cer_temp/")
declare temppath2_acute_var	= vc with constant(build(temppath2_var, file_acute_var))
declare temppath2_pbh_var	= vc with constant(build(temppath2_var, file_pbh_var))
 
declare filepath_var		= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													 "_cust/to_client_site/RevenueCycle/Registration/"))
 
declare filepath_acute_var	= vc with constant(build(filepath_var, file_acute_var))
declare filepath_pbh_var	= vc with constant(build(filepath_var, file_pbh_var))
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select daily data
if ($file_type = 0)
	set modify filestream
 
	select distinct into value(temppath_acute_var)
		e.encntr_id
		, facility = uar_get_code_display(e.loc_facility_cd)
		, facility_alias = cva.alias
		, org.org_name
 
		, encntr_type = build("CS", cvo.alias)
		, e.est_arrive_dt_tm "@SHORTDATETIME"
 
		, p.name_full_formatted
 
		, fin = ea.alias
		, mrn = eam.alias
		, cmrn = pa.alias
 
		, deceased = cnvtupper(uar_get_code_display(p.deceased_cd))
 
		, total_charges = count(distinct c.charge_item_id) over(partition by c.encntr_id)
	
		, has_docs_notes = evaluate2(
			if ((ce.event_id > 0.0) or (cebr.event_id > 0.0))
				"YES"
			else
				"NO"
			endif
			)
			
		, has_orders = evaluate2(
			if ((o.order_id > 0.0) or (o2.order_id > 0.0))
				"YES"
			else
				"NO"
			endif
			)
 
	from
		ENCOUNTER e
 
		, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
 
		, (inner join PERSON p on p.person_id = e.person_id
			and p.active_ind = 1)
 
		, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
			and ea.encntr_alias_type_cd = fin_var
			and ea.end_effective_dt_tm > sysdate
			and ea.active_ind = 1)
 
		, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
			and eam.encntr_alias_type_cd = emrn_var
			and eam.end_effective_dt_tm > sysdate
			and eam.active_ind = 1)
 
		, (left join PERSON_ALIAS pa on pa.person_id = e.person_id
			and pa.person_alias_type_cd = cmrn_var
			and pa.end_effective_dt_tm > sysdate
			and pa.active_ind = 1)
 
		, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd
			and cvo.alias in ("A", "B", "F", "L", "M", "P", "R", "S") ; acute non-pbh
			and cvo.contributor_source_cd = covenant_var)
 
		, (inner join CODE_VALUE_ALIAS cva on cva.code_value = e.loc_facility_cd
			and cva.alias_type_meaning = "FACILITY"
			and cva.contributor_source_cd = covenant_var)
 
		, (left join CHARGE c on c.encntr_id = e.encntr_id
			and c.active_ind = 1)
 
		, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
			and (ce.event_class_cd in (
				select
					cv.code_value
				from
					CODE_VALUE cv
				where
					cv.code_set = 53
					and cv.display_key like "*DOC*" ; all documents
			)
			or ce.event_cd in (
				select
					cv.code_value
				from
					CODE_VALUE cv
				where
					cv.code_set = 72
					and cv.display_key like "*NOTE*" ; all notes
					; exclusions
					and cv.display_key not like "*NOTEC*"
					and cv.display_key not like "*NOTED*"
					and cv.display_key not like "*NOTER*"
					and cv.display_key not like "*NOTET*"
			)
			))
 
		, (left join CE_BLOB_RESULT cebr on cebr.event_id = ce.event_id
			and cebr.storage_cd in (650264.00)) ; OTG)
	 
		, (left join ORDERS o on o.encntr_id = e.encntr_id
			and o.active_ind = 1)
	 
		; scheduled orders
		, (left join SCH_APPT sa on sa.encntr_id = e.encntr_id
			and sa.role_meaning = "PATIENT"
			and sa.active_ind = 1)
	 
		, (left join SCH_EVENT se on se.sch_event_id = sa.sch_event_id
			and se.active_ind = 1)
	 
		, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = se.sch_event_id
			and sea.active_ind = 1)
	 
		, (left join ORDERS o2 on o2.order_id = sea.order_id
			and o2.active_ind = 1)
 
	where
		e.est_arrive_dt_tm <= cnvtlookbehind("14,D") ; 14 days or older
		and e.admit_type_cd = 0.0
		and e.encntr_type_cd in (
			select cva.code_value
			from
				CODE_VALUE_ALIAS cva
			where
				cva.code_set = 71
				and cva.alias like "CS*"
				and cva.contributor_source_cd = covenant_var
		)
		and e.active_ind = 1
 
	order by
		org.org_name
		, p.name_last_key
		, p.name_first_key
		, e.encntr_id
		, 0
 
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
 
 
	; copy daily file to AStream
	set cmd = build2("cp ", temppath2_acute_var, " ", filepath_acute_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
/**************************************************************/
; select monthly data
if ($file_type = 1)
	set modify filestream
 
	select distinct into value(temppath_pbh_var)
		e.encntr_id
		, facility = uar_get_code_display(e.loc_facility_cd)
		, facility_alias = cva.alias
		, org.org_name
 
		, encntr_type = build("CS", cvo.alias)
		, e.est_arrive_dt_tm "@SHORTDATETIME"
 
		, p.name_full_formatted
 
		, fin = ea.alias
		, mrn = eam.alias
		, cmrn = pa.alias
 
		, deceased = cnvtupper(uar_get_code_display(p.deceased_cd))
 
		, total_charges = count(distinct c.charge_item_id) over(partition by c.encntr_id)
	
		, has_docs_notes = evaluate2(
			if ((ce.event_id > 0.0) or (cebr.event_id > 0.0))
				"YES"
			else
				"NO"
			endif
			)
			
		, has_orders = evaluate2(
			if ((o.order_id > 0.0) or (o2.order_id > 0.0))
				"YES"
			else
				"NO"
			endif
			)
 
	from
		ENCOUNTER e
 
		, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
 
		, (inner join PERSON p on p.person_id = e.person_id
			and p.active_ind = 1)
 
		, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
			and ea.encntr_alias_type_cd = fin_var
			and ea.end_effective_dt_tm > sysdate
			and ea.active_ind = 1)
 
		, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
			and eam.encntr_alias_type_cd = emrn_var
			and eam.end_effective_dt_tm > sysdate
			and eam.active_ind = 1)
 
		, (left join PERSON_ALIAS pa on pa.person_id = e.person_id
			and pa.person_alias_type_cd = cmrn_var
			and pa.end_effective_dt_tm > sysdate
			and pa.active_ind = 1)
 
		, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd
			and cvo.alias in ("G") ; pbh
			and cvo.contributor_source_cd = covenant_var)
 
		, (inner join CODE_VALUE_ALIAS cva on cva.code_value = e.loc_facility_cd
			and cva.alias_type_meaning = "FACILITY"
			and cva.contributor_source_cd = covenant_var)
 
		, (left join CHARGE c on c.encntr_id = e.encntr_id
			and c.active_ind = 1)
 
		, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
			and (ce.event_class_cd in (
				select
					cv.code_value
				from
					CODE_VALUE cv
				where
					cv.code_set = 53
					and cv.display_key like "*DOC*" ; all documents
			)
			or ce.event_cd in (
				select
					cv.code_value
				from
					CODE_VALUE cv
				where
					cv.code_set = 72
					and cv.display_key like "*NOTE*" ; all notes
					; exclusions
					and cv.display_key not like "*NOTEC*"
					and cv.display_key not like "*NOTED*"
					and cv.display_key not like "*NOTER*"
					and cv.display_key not like "*NOTET*"
			)
			))
 
		, (left join CE_BLOB_RESULT cebr on cebr.event_id = ce.event_id
			and cebr.storage_cd in (650264.00)) ; OTG)
	 
		, (left join ORDERS o on o.encntr_id = e.encntr_id
			and o.active_ind = 1)
	 
		; scheduled orders
		, (left join SCH_APPT sa on sa.encntr_id = e.encntr_id
			and sa.role_meaning = "PATIENT"
			and sa.active_ind = 1)
	 
		, (left join SCH_EVENT se on se.sch_event_id = sa.sch_event_id
			and se.active_ind = 1)
	 
		, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = se.sch_event_id
			and sea.active_ind = 1)
	 
		, (left join ORDERS o2 on o2.order_id = sea.order_id
			and o2.active_ind = 1)
 
	where
		e.est_arrive_dt_tm < cnvtdatetime(datetimefind(sysdate, "M", "B", "B")) ; prior to beginning of current month
		and e.admit_type_cd = 0.0
		and e.encntr_type_cd in (
			select cva.code_value
			from
				CODE_VALUE_ALIAS cva
			where
				cva.code_set = 71
				and cva.alias like "CS*"
				and cva.contributor_source_cd = covenant_var
		)
		and e.active_ind = 1
 
	order by
		org.org_name
		, p.name_last_key
		, p.name_first_key
		, e.encntr_id
		, 0
 
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
 
 
	; copy monthly file to AStream
	set cmd = build2("cp ", temppath2_pbh_var, " ", filepath_pbh_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 

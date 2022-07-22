/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/31/2019
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_Defic_Review.prg
	Object name:		cov_him_Defic_Review
	Request #:			5582 (6538)
 
	Program purpose:	Lists deficiencies assigned to physicians to identify
						possible assignment issues.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	11/01/2019	Todd A. Blanchard		Added discharge date range prompts to
										cov_mak_defic_by_phys_ccl. 
 
******************************************************************************/
 
drop program cov_him_Defic_Review:dba go
create program cov_him_Defic_Review:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = ""
	, "Discharge Start Date" = "SYSDATE"     ;* Enter the start date for the discharge date range.
	, "Discharge End Date" = "SYSDATE"       ;* Enter the end date for the discharge date range. 

with OUTDEV, ORGANIZATIONS, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare num						= i4 with noconstant(0)
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record phys_rec (
	1	cnt						= i4
	1	list[*]
		2	fin					= vc
		2	encntr_id			= f8
		2	physician_id		= f8
		2	physician_ind		= i2
		2	reltn_ind			= i2
)
 
 
/**************************************************************/
; select deficiency data 
execute cov_mak_defic_by_phys_ccl $OUTDEV, $ORGANIZATIONS, 0.0, $start_datetime, $end_datetime ;001
 
 
/**************************************************************/
; select encounter and physician data
select distinct into "NL:"
	fin				= t_rec->qual[d.seq].fin
	, physician_id	= t_rec->qual[d.seq].physician_id
	
from
	(dummyt d with seq = t_rec->cnt)
	, ENCNTR_ALIAS ea
	, PRSNL per	
	
plan d
where 
	t_rec->qual[d.seq].discharge_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)

join ea
where
	ea.alias = t_rec->qual[d.seq].fin
	and ea.encntr_alias_type_cd = fin_var
	
join per
where
	per.person_id = t_rec->qual[d.seq].physician_id

order by
	fin
	, physician_id


; populate record structure
head report
	cnt = 0

detail
	cnt = cnt + 1
	
	call alterlist(phys_rec->list, cnt)

	phys_rec->cnt						= cnt
	phys_rec->list[cnt].fin				= fin
	phys_rec->list[cnt].encntr_id		= ea.encntr_id
	phys_rec->list[cnt].physician_id	= physician_id
	phys_rec->list[cnt].physician_ind	= per.physician_ind
	
with nocounter
 
 
/**************************************************************/
; select encounter physician relationship data
select into "NL:"
from
	(dummyt d with seq = phys_rec->cnt)	
	, ENCNTR_PRSNL_RELTN epr
	
plan d
	
join epr
where
	epr.encntr_id = phys_rec->list[d.seq].encntr_id
	and epr.prsnl_person_id = phys_rec->list[d.seq].physician_id


; populate record structure
head report
	i = phys_rec->cnt

detail
	if (i > 0)
		phys_rec->list[d.seq].reltn_ind	= 1
	endif
	
with nocounter
 
 
/**************************************************************/
; select deficiency data 
select distinct into $OUTDEV
	location					= t_rec->qual[d.seq].location
	, physician_name			= t_rec->qual[d.seq].physician_name
	, physician_position		= t_rec->qual[d.seq].physician_position
	, physician_star_id			= t_rec->qual[d.seq].physician_star_id
	, physician_id				= t_rec->qual[d.seq].physician_id
	, physician_ind				= phys_rec->list[d2.seq].physician_ind
	, phys_encntr_reltn_ind		= phys_rec->list[d2.seq].reltn_ind
	, patient_name				= t_rec->qual[d.seq].patient_name
	, mrn						= t_rec->qual[d.seq].mrn
	, fin						= t_rec->qual[d.seq].fin
	, dicharge_date				= t_rec->qual[d.seq].dicharge_date
	, deficiency				= t_rec->qual[d.seq].deficiency
	, status					= t_rec->qual[d.seq].status
	, deficiency_age_days		= t_rec->qual[d.seq].deficiency_age_days
	, deficiency_age_hours		= t_rec->qual[d.seq].deficiency_age_hours
	, encounter_type			= t_rec->qual[d.seq].encounter_type
	, encntr_id					= phys_rec->list[d2.seq].encntr_id
	, order_notification_id		= t_rec->qual[d.seq].order_notification_id
	, scanned_image				= t_rec->qual[d.seq].scanned_image
	, scanning_prsnl			= t_rec->qual[d.seq].scanning_prsnl
	, event_id					= t_rec->qual[d.seq].event_id
	, order_id					= t_rec->qual[d.seq].order_id
	, communication_type		= t_rec->qual[d.seq].communication_type
	, latest_comm_type			= t_rec->qual[d.seq].latest_comm_type
	, ordering_prsnl_name		= t_rec->qual[d.seq].ordering_prsnl_name
	, ordering_prsnl_id			= t_rec->qual[d.seq].ordering_prsnl_id
	, ordering_prsnl_pos		= t_rec->qual[d.seq].ordering_prsnl_pos
	, refuse_provider_name		= t_rec->qual[d.seq].refuse_provider_name
	, refuse_provider_id		= t_rec->qual[d.seq].refuse_provider_id
	, refuse_reason				= t_rec->qual[d.seq].refuse_reason
	, powerplan_desc			= t_rec->qual[d.seq].powerplan_desc
 
from
	(dummyt d with seq = t_rec->cnt)
	, (dummyt d2 with seq = phys_rec->cnt)
 
plan d
join d2

where
	t_rec->qual[d.seq].fin = phys_rec->list[d2.seq].fin
	and t_rec->qual[d.seq].physician_id = phys_rec->list[d2.seq].physician_id
	and t_rec->qual[d.seq].discharge_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	
order by
	physician_name
	, fin
	
with nocounter, separator = " ", format


;call echorecord(phys_rec)
;call echorecord(t_rec) 
 
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 

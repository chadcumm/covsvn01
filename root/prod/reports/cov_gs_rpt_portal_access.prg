/*************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
*************************************************************************************/


drop program cov_gs_rpt_portal_access:dba go
create program cov_gs_rpt_portal_access:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "Select Report Type" = 0
	, "Select Position" = VALUE(0.0, 0.0           )
	, "Select Folder" = VALUE(0.0, 0.0           )
	;<<hidden>>"Clear List" = 0
 
with OUTDEV, RPT_TYPE_PMPT, POSITION_PMPT, FOLDER_PMPT
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
free record a
record a
(
1	rec_cnt 		=	i4
1	qual[*]
	2	position_id	= f8
	2	position	= vc
	2	folder_id	= f8
	2	folder		= vc
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare POSITION_VAR	= vc with noconstant(fillstring(2,' ')), protect
declare FOLDER_VAR		= vc with noconstant(fillstring(2,' ')), protect
 
 
;===================================================================
; USER PROMPT SETUP
;===================================================================
if (substring(1,1,reflect(parameter(parameter2($POSITION_PMPT),0)))="L")
	set POSITION_VAR = "IN"
elseif (parameter(parameter2($POSITION_PMPT),1) = 0.0)
	set POSITION_VAR = "!="
else
	set POSITION_VAR = "="
endif
 
 
if (substring(1,1,reflect(parameter(parameter2($FOLDER_PMPT),0)))="L")
	set FOLDER_VAR = "IN"
elseif (parameter(parameter2($FOLDER_PMPT),1) = 0.0)
	set FOLDER_VAR = "!="
else
	set FOLDER_VAR = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;===================================================================
; GET POSITIONS BY FOLDER
;===================================================================
if ($RPT_TYPE_PMPT = 0)
 
	call echo('Get Folders by Position')
 
	select distinct
		 position	= uar_get_code_display(gs.security_group_cd)
		,folder 	= cnvtupper(f.da_folder_name)
 
	from DA_GROUP_SECURITY gs
		,(inner join DA_FOLDER f on f.da_folder_id = gs.parent_entity_id)
	;	,(inner join DA_FOLDER f on f.parent_folder_id = gs.parent_entity_id)
 
	where 1=1 ;and gs.end_effective_dt_tm > sysdate
		and gs.parent_entity_name = "DA_FOLDER"
		and operator(gs.security_group_cd, POSITION_VAR, $POSITION_PMPT)
		and gs.active_ind = 1
		and f.public_ind = 1
	;	and f.parent_folder_id = 0.00
 
	order by position, folder, gs.security_group_cd
 
	head report
		cnt = 0
 
	detail
		cnt = cnt + 1
		if (mod (cnt,10) = 1 or cnt = 1)
			stat = alterlist(a->qual, cnt + 9)
		endif
 
		a->qual[cnt].position	= position
		a->qual[cnt].folder		= folder
		a->rec_cnt				= cnt
 
	foot report
		stat = alterlist(a->qual, cnt)
 
	with nocounter
 
else
 
	call echo('Get Positions By Folder')
 
	select into 'nl:'
	 	 folder 			= cnvtupper(f.da_folder_name)
	 	,position 			= uar_get_code_display(gs.security_group_cd)
	 	,security_group_cd	= gs.security_group_cd
 
	from DA_GROUP_SECURITY gs
		,(inner join DA_FOLDER f on f.da_folder_id = gs.parent_entity_id)
 
	where gs.end_effective_dt_tm > sysdate
		and gs.parent_entity_name = "DA_FOLDER"
		and operator(f.da_folder_id, FOLDER_VAR, $FOLDER_PMPT)
		and gs.active_ind = 1
		and f.public_ind = 1
	;	and f.parent_folder_id = 0.00
 
	order by folder, position, gs.security_group_cd
 
	head report
		cnt = 0
 
	detail
		cnt = cnt + 1
		if (mod (cnt,10) = 1 or cnt = 1)
			stat = alterlist(a->qual, cnt + 9)
		endif
 
		a->qual[cnt].folder		= folder
		a->qual[cnt].position	= position
		a->rec_cnt				= cnt
 
	foot report
		stat = alterlist(a->qual, cnt)
 
	with nocounter
 
endif
 
;call echorecord(a)
;go to exitscript
 
 
;===================================================================
; REPORT OUTPUT
;===================================================================
if ($RPT_TYPE_PMPT = 0) ;Folders by Position
 
 	if (a->rec_cnt > 0)
		select distinct into $outdev
			 position	= substring(1,100,trim(a->qual[d.seq].position))
			,folder		= substring(1,100,a->qual[d.seq].folder)
 
		from (DUMMYT d with seq = a->rec_cnt)
 
		order by position, folder
 
		with nocounter, format, separator = ' '
 	endif
 
else
 
 	if (a->rec_cnt > 0)
		select distinct into $outdev
			 folder		= substring(1,100,a->qual[d.seq].folder)
			,position	= substring(1,100,trim(a->qual[d.seq].position))
 
		from (DUMMYT d with seq = a->rec_cnt)
 
		order by folder, position
 
		with nocounter, format, separator = ' '
 	endif
 
endif
 
call echorecord(a)
go to exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript
 
end
go

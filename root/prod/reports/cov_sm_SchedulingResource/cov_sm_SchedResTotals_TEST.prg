/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		12/05/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_SchedulingResTotals.prg
	Object name:		cov_sm_SchedulingResTotals
	Request #:			3894, 8652, 11683
 
	Program purpose:	Lists totals for scheduled resources from 
						Report Request module.
 
	Executing from:		CCL
 
 	Special Notes:		This is a report/extract CCL.  Changes have to be
						coordinated with downstream processes.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	08/26/2020	Todd A. Blanchard		Adjusted order by clause.
002	09/11/2020	Todd A. Blanchard		Revised sort order for final query.
003	10/01/2020	Todd A. Blanchard		Added hidden prompt and functionality to export data to file.
004	12/07/2021	Todd A. Blanchard		Adjusted order by clause.
										Changed table join to allow queues without scheduled entries 
										to be displayed.
 
******************************************************************************/
 
drop program cov_sm_SchedResTotals_TEST:DBA go
create program cov_sm_SchedResTotals_TEST:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare pending_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 23018, "PENDING"))
declare request_list_queue_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16146, "REQUESTLISTQUEUE"))

declare file_var						= vc with constant(build(format(curdate, "mm-dd-yyyy;;d"), "_resourcetotals.csv")) ;003
 
declare temppath_var					= vc with constant(build("cer_temp:", file_var)) ;003
declare temppath2_var					= vc with constant(build("$cer_temp/", file_var)) ;003

;003
declare filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
															 
declare output_var						= vc with noconstant("") ;003
 
declare cmd								= vc with noconstant("") ;003
declare len								= i4 with noconstant(0) ;003
declare stat							= i4 with noconstant(0) ;003
	
 
; define output value ;003
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

record sched_obj (
	1	sched_cnt						= i4
	1	list[*]
		2	sch_obj_desc				= c100 
		2	sch_obj_total				= i4
	1	sch_obj_grand_total				= i4
)
 
 
/**************************************************************/
; select scheduled object data
select into "NL:"
	so.description
	, queue_total = cnvtint(count(distinct sen.sch_entry_id))
	
from
	SCH_OBJECT so
 
 	;004
	, (left join SCH_ENTRY sen on sen.queue_id = so.sch_object_id
		and sen.entry_state_cd = pending_var ; pending
		and sen.active_ind = 1)
 
where
	so.object_type_cd = request_list_queue_var
	and so.active_ind = 1
	
group by
	so.description
 
 
; populate sched_obj record structure
head report
	cnt = 0
	grand_total = 0
 
head so.description
	cnt = cnt + 1
	
	call alterlist(sched_obj->list, cnt)
 
	sched_obj->sched_cnt							= cnt
	sched_obj->list[cnt].sch_obj_desc				= so.description
 	sched_obj->list[cnt].sch_obj_total				= queue_total
 	
	grand_total = grand_total + queue_total
	
foot report
	sched_obj->sch_obj_grand_total = grand_total
 
WITH nocounter, time = 60


call echorecord(sched_obj)
 
 
/**************************************************************/
; select data

;003
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif

;003
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, separator = " ", format, time = 600
endif

into value(output_var)
	request_list_queue		= trim(sched_obj->list[d1.seq].sch_obj_desc, 3)
	, queue_total			= sched_obj->list[d1.seq].sch_obj_total
	, grand_total			= sched_obj->sch_obj_grand_total
 
from
	(dummyt d1 with seq = value(sched_obj->sched_cnt))
 
plan d1
 
order by
;	sched_obj->list[d1.seq].sch_obj_desc ;001
	;001 ;004
	if (cnvtupper(sched_obj->list[d1.seq].sch_obj_desc) in ("*UNKNOWN*"))
		build("0", sched_obj->list[d1.seq].sch_obj_desc)
	elseif (cnvtupper(sched_obj->list[d1.seq].sch_obj_desc) in ("*CENTRALIZED*", "FSR*WEST*DIAGNOSTIC*CENTER", "CHDC*WEST*LOCATION"))
		build("1", sched_obj->list[d1.seq].sch_obj_desc)
    elseif (cnvtupper(sched_obj->list[d1.seq].sch_obj_desc) in ("*HOLD*")) ;002
        build("2", sched_obj->list[d1.seq].sch_obj_desc) ;002
	else
		sched_obj->list[d1.seq].sch_obj_desc
	endif

with nocounter

 
; copy file to AStream ;013
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
 

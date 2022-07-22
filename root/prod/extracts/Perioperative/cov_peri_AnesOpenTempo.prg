/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/11/2018
	Solution:			Perioperative
	Source file name:	cov_peri_AnesOpenTempo.prg
	Object name:		cov_peri_AnesOpenTempo
	Request #:			317, 8842
 
	Program purpose:	Surgery scheduling information for OpenTempo scheduling system.
 
	Executing from:		CCL
 
 	Special Notes:		Currently for Mednax anesthesia group for Fort Sanders Regional and Parkwest.
 
 						Output files:
 							Cov_OpenTempo_Anes_Sched_FSR.csv
 							Cov_OpenTempo_Anes_Sched_PW.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	09/24/2018	Todd A. Blanchard		Changed logic to copy files directly to AStream.
002	11/12/2020	Todd A. Blanchard		Changed date parameter values.
003	02/19/2021	Todd A. Blanchard		Corrected issue with empty results not being exported.
 
******************************************************************************/
 
drop program cov_peri_AnesOpenTempo:DBA go
create program cov_peri_AnesOpenTempo:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0
	, "Test" = 1 

with OUTDEV, facility, start_datetime, end_datetime, output_file, test
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare wrap(data = vc) 	= vc
declare wrap2(data = vc) 	= vc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime		= dq8 with noconstant(cnvtlookahead("1, d", cnvtdatetime(curdate, 000000)))
declare end_datetime		= dq8 with noconstant(cnvtlookahead("1, d", cnvtdatetime(curdate, 235959))) ;002
declare privatecomment_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 16289, "RESTRICTEDSCHEDULINGCOMMENTS"))
declare crlf				= vc with constant(build(char(13), char(10)))
declare output_sched		= vc with noconstant("")

declare file_var			= vc with noconstant("Cov_OpenTempo_Anes_Sched_")
declare temppath_var		= vc with noconstant("cer_temp:")
declare temppath2_var		= vc with noconstant("$cer_temp/")
declare filepath_var		= vc with noconstant("")
declare output_var			= vc with noconstant("")

declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)

 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_fac (
	1 p_facility			= vc
	1 p_fac					= vc
	1 p_start_datetime		= vc
	1 p_end_datetime		= vc
 
	1 sched_cnt				= i4
	1 list[*]
		2	facility_cd		= f8	; facility cd
		2	facility		= vc	; facility
		2	case_nbr		= vc	; surgical case id
		2	date			= vc	; date of scheduled procedure
		2	room			= vc	; where procedure being performed
		2	sched_start		= vc	; time start on grid of scheduled procedure
		2	sched_stop		= vc	; time end on grid of scheduled procedure
		2	consultant		= vc	; primary surgeon
		2	proc_specialty	= vc	; procedure specialty
		2	notes			= vc	; procedure name, additional procedure details, modifiers 1, 2, and 3
		2	custom1			= vc	; private surgical comment
		2	custom2			= vc	; patient age
		2	custom3			= vc	; empty
)
 
 
/**************************************************************/
; populate sched_fac record structure with prompt data
set sched_fac->p_facility = uar_get_code_description($facility)
set sched_fac->p_fac = uar_get_code_display($facility)
 
if (validate(request->batch_selection) = 1)
	set sched_fac->p_start_datetime = format(start_datetime, "mm/dd/yyyy hh:mm;;q")
	set sched_fac->p_end_datetime = format(end_datetime, "mm/dd/yyyy hh:mm;;q")
else
	set sched_fac->p_start_datetime = format(cnvtdatetime($start_datetime), "mm/dd/yyyy hh:mm;;q")
	set sched_fac->p_end_datetime = format(cnvtdatetime($end_datetime), "mm/dd/yyyy hh:mm;;q")
 
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
endif


; determine astream path
if ($test = 1)
	set filepath_var = "/cerner/w_custom/b0665_cust/to_client_site/ClinicalNursing/Perioperative/OpenTempo/"
else
	set filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Perioperative/OpenTempo/"
endif
 
 
; build file name
set file_var = cnvtlower(build(file_var, sched_fac->p_fac, ".csv"))

set temppath_var = build(temppath_var, file_var)
set temppath2_var = build(temppath2_var, file_var)
set filepath_var = build(filepath_var, file_var)

if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************/
; select scheduled surgery/anesthesia data
select into "NL:"
from
	SCH_APPT sa
 
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
		and sar.role_meaning = "SURGOP"
		and sar.state_meaning in ("CONFIRMED", "CHECKED IN")
		and sar.active_ind = 1)
 
	, (inner join SURGICAL_CASE sc on sc.sch_event_id = sa.sch_event_id
		and sc.person_id = sa.person_id
		and sc.active_ind = 1)
 
	, (inner join ENCOUNTER e on e.encntr_id = sc.encntr_id
		and e.loc_facility_cd = $facility
		and e.active_ind = 1)
 
	, (inner join SURG_CASE_PROCEDURE scp on scp.surg_case_id = sc.surg_case_id
		and scp.active_ind = 1)
 
	, (inner join PRSNL scpper on scpper.person_id = scp.sched_primary_surgeon_id
		and scpper.active_ind = 1)
 
	, (left join PRSNL_GROUP scpperg on scpperg.prsnl_group_id = scp.sched_surg_specialty_id
		and scpperg.active_ind = 1)
 
	, (left join SN_COMMENT_TEXT sct on sct.root_id = sc.surg_case_id
		and sct.root_name = "SURGICAL_CASE"
		and sct.comment_type_cd = privatecomment_var
		and sct.active_ind = 1)
 
	, (left join LONG_TEXT lt on lt.long_text_id = sct.long_text_id
		and lt.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = sa.person_id
		and p.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = scp.order_id
		and o.active_ind = 1)
 
	, (inner join ORDER_DETAIL ods on ods.order_id = o.order_id
		and ods.oe_field_meaning = "SURGSETUPDUR")
 
	, (inner join ORDER_DETAIL odc on odc.order_id = o.order_id
		and odc.oe_field_meaning = "SURGCLEANUPDUR")
 
	, (left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "SURGPROCTEXT")
 
	, (left join ORDER_DETAIL od1 on od1.order_id = o.order_id
		and od1.oe_field_meaning = "SURGPROCMODIFIER1")
 
	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_meaning = "SURGPROCMODIFIER2")
 
	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_meaning = "SURGPROCMODIFIER3")
 
where
	sa.beg_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning in ("CONFIRMED", "CHECKED IN")
	and sa.active_ind = 1
 
order by
	sa.beg_dt_tm
	, sa.end_dt_tm
	, sc.surg_case_id
 
 
; populate sched_fac record structure
head report
	cnt = 0
 
	call alterlist(sched_fac->list, 100)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_fac->list, cnt + 9)
	endif
 
	sched_fac->list[cnt].facility_cd	= e.loc_facility_cd
	sched_fac->list[cnt].facility		= uar_get_code_description(e.loc_facility_cd)
	sched_fac->list[cnt].case_nbr		= sc.surg_case_nbr_formatted
	sched_fac->list[cnt].date			= format(sa.beg_dt_tm, "mm/dd/yy;;d")
	sched_fac->list[cnt].room			= uar_get_code_display(sar.resource_cd)
	sched_fac->list[cnt].sched_start	= format(sar.beg_dt_tm, "hh:mm;;q")
	sched_fac->list[cnt].sched_stop		= format(sar.end_dt_tm, "hh:mm;;q")
	sched_fac->list[cnt].consultant		= scpper.name_full_formatted
	sched_fac->list[cnt].proc_specialty	= uar_get_code_display(scpperg.prsnl_group_type_cd)
	sched_fac->list[cnt].notes			= build(
		trim(o.order_mnemonic, 3), "|",
		trim(od.oe_field_display_value, 3), "|",
		trim(od1.oe_field_display_value, 3), "|",
		trim(od2.oe_field_display_value, 3), "|",
		trim(od3.oe_field_display_value, 3)
		)
	sched_fac->list[cnt].custom1		= trim(replace(lt.long_text, crlf, ""), 3)
	sched_fac->list[cnt].custom2		= trim(cnvtage(p.birth_dt_tm), 3)
	sched_fac->list[cnt].custom3		= ""
 
foot report
	sched_fac->sched_cnt = cnt
 
	call alterlist(sched_fac->list, cnt)
 
with time = 30, nocounter
 
 
/**************************************************************/
; build output
if (sched_fac->sched_cnt > 0)
	; select main record structure data
	select into value(output_var)
	from
		(DUMMYT dt with seq = sched_fac->sched_cnt)
	order by
		dt.seq
 
	; build output
	head report
		output_sched = build(
			wrap2("Case ID")
			, wrap2("Date")
			, wrap2("Room")
			, wrap2("Scheduled Start")
			, wrap2("Scheduled Stop")
			, wrap2("Consultant")
			, wrap2("Procedure Type")
			, wrap2("Notes")
			, wrap2("Custom1")
			, wrap2("Custom2")
			, wrap("Custom3")
		)
 
		col 0 output_sched
		row + 1
 
	head dt.seq
		output_sched = ""
		output_sched = build(
			output_sched
			, wrap2(sched_fac->list[dt.seq].case_nbr)
			, wrap2(sched_fac->list[dt.seq].date)
			, wrap2(sched_fac->list[dt.seq].room)
			, wrap2(sched_fac->list[dt.seq].sched_start)
			, wrap2(sched_fac->list[dt.seq].sched_stop)
			, wrap2(sched_fac->list[dt.seq].consultant)
			, wrap2(sched_fac->list[dt.seq].proc_specialty)
			, wrap2(sched_fac->list[dt.seq].notes)
			, wrap2(sched_fac->list[dt.seq].custom1)
			, wrap2(sched_fac->list[dt.seq].custom2)
			, wrap(sched_fac->list[dt.seq].custom3)
		)
 
		output_sched = trim(output_sched, 3)
 
	foot dt.seq
		col 0 output_sched
		row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none

;003
else
	; select main record structure data
	select into value(output_var)
	from
		(DUMMYT dt with seq = sched_fac->sched_cnt)
	order by
		dt.seq
 
	; build output
	head report
		output_sched = build(
			wrap2("Case ID")
			, wrap2("Date")
			, wrap2("Room")
			, wrap2("Scheduled Start")
			, wrap2("Scheduled Stop")
			, wrap2("Consultant")
			, wrap2("Procedure Type")
			, wrap2("Notes")
			, wrap2("Custom1")
			, wrap2("Custom2")
			, wrap("Custom3")
		)
 
		col 0 output_sched
		row + 1
		
		with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
endif
 
 
; copy file to AStream ;001
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
	
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif
 
call echorecord(sched_fac)
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end
go
 

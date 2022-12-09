/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			David Baumgardner
	Date Written:		June 2022
	Solution:
	Source file name:  	cov_amb_diaagg_rpt_exprt.prg
	Object name:		cov_amb_diaagg_rpt_exprt
	Request#:
 
	Program purpose:	Report the COV Ambulatory Orders - Diagnostic Aggregate report
	Executing from:		CCL/DA2/Ambulatory Folder
  	Special Notes:
  		This is to export the cov_amb_diaagg_rpt to R2W and to SpotFire
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
10/10/2022	David Baumgardner		CR10287 - needed to rename the file to txt for the Spotfire export.
******************************************************************************/
 
DROP PROGRAM cov_amb_diaagg_rpt_exprt GO
CREATE PROGRAM cov_amb_diaagg_rpt_exprt
 
prompt
	"Output to File/Printer/MINE" = "MINE"
 
with OUTDEV
 
 
;declare export_file_var						= vc with constant("diaagg_rpt.xls") ;12/7/21 DWB
declare export_file_var						= vc with constant("diaagg_rpt.txt") ;10/10/22 DWB
declare export_temppath_var				= vc with constant(build("cer_temp:", export_file_var))
declare export_temppath2_var			= vc with constant(build("$cer_temp/", export_file_var))
declare export_filepath_var					= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/ClinicalAncillary/Ambulatory/\
AggregateReports/", export_file_var))
declare cmd								= vc with noconstant("")
declare len								= i4 with noconstant(0)
declare stat							= i4 with noconstant(0)
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare delimiter = char(124)
 
set export_output_var = value(export_temppath_var)
 
	SET begdate = CNVTDATETIME(CURDATE-7, 0)
	SET enddate = CNVTDATETIME(CURDATE,235959)
 
record orderencounter (
  1 olist[*]
    2 provider = c40
    2 facility = c40
    2 patient_name = c40
    2 patient_dob = dq8
    2 fin = c20
    2 encounter_id = f8
    2 order_id = f8
    2 order_date = dq8
    2 days_outstanding = i4
    2 time_frame = i4
    2 sched_appt = dq8
    2 status_date = dq8
    2 order_status = c15
    2 order_desc = c40
    2 future_loc = c40
    2 sched_loc = c40
    2 auth_num = c20
    2 comments = c100
    2 communication_type = f8
    2 sa_beg_dt_tm = dq8
    2 appt_tat_days = i4
    2 sch_tat_days = i4
    2 auth_tat_days = i4
    2 entered_by = c40
)
 
 
EXECUTE COV_AMB_DIAAGG_RPT "MINE", VALUE(0.0), VALUE(0.0), VALUE(0.0), begdate, enddate, "0"
SELECT into value(export_output_var)
	FACILITY = orderencounter->olist[D1.SEQ].facility
	,ORDERING_PROVIDER = orderencounter->olist[D1.SEQ].provider
	,PATIENT = orderencounter->olist[D1.SEQ].patient_name
	,DOB = FORMAT(orderencounter->olist[D1.SEQ].patient_dob,"mm/dd/yyyy;;d")
	,FIN = SUBSTRING(1, 30, ORDERENCOUNTER->olist[D1.SEQ].fin)
	,OrderID = orderencounter->olist[D1.SEQ].order_id
	,ORDER_DATE = FORMAT(orderencounter->olist[D1.SEQ].order_date,"mm/dd/yyyy;;d")
	,DAYS_OUTSTANDING =orderencounter->olist[D1.SEQ].days_outstanding
	,TIME_FRAME = orderencounter->olist[D1.SEQ].time_frame
	,SCHED_APPT = FORMAT(orderencounter->olist[D1.SEQ].sched_appt,"mm/dd/yyyy;;d")
	,STATUS_DATE = FORMAT(orderencounter->olist[D1.SEQ].status_date,"mm/dd/yyyy hh:mm:ss a")
	,ORDER_STATUS = orderencounter->olist[D1.SEQ].order_status
	,ORDER_DESC = orderencounter->olist[D1.SEQ].order_desc
	,FUTURE_LOCATION = orderencounter->olist[D1.SEQ].future_loc
	,AUTH_NUMBER = SUBSTRING(1, 30, ORDERENCOUNTER->olist[D1.SEQ].auth_num)
	,COMMUNICATION_TYPE = UAR_GET_CODE_DESCRIPTION(orderencounter->olist[D1.SEQ].communication_type)
	,COMMENTS = SUBSTRING(1, 100, ORDERENCOUNTER->olist[D1.SEQ].comments)
	,APPT_TAT_DAYS = orderencounter->olist[D1.SEQ].appt_tat_days
	,AUTH_TAT_DAYS = orderencounter->olist[D1.SEQ].auth_tat_days
	,SCH_TAT_DAYS = orderencounter->olist[D1.SEQ].sch_tat_days
from
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(orderencounter->olist, 5)))
plan d1
WITH NOCOUNTER, PCFORMAT(^"^,^,^,1,0),SEPARATOR="|", FORMAT = STREAM, formatfeed = none, format
 
	set cmd = build2("cp ", export_temppath2_var, " ", export_filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
#exitscript
 
END GO

/*************************************************************************************************************
Covenant Health Information Technology
Knoxville, Tennessee
**************************************************************************************************************
 
	Author:				William Hulse, SR Programmer
	Date Written:		01/24/2019
	Solution:			Ops Job Reporting
	Source file name:	cov_opsjob_report.prg
	Object name:		XXXX
	Request #:			CR4159
 
	Program purpose:	To allow Operations to monitor Opsjobs more efficiently.
 
	Executing from:		CCL
 
 	Special Notes:      This will be used as a report in the Reporting Portal.
 
**************************************************************************************************************
GENERATED MODIFICATION CONTROL LOG
**************************************************************************************************************
 
 	Mod        Date	         Developer				  Comment
 	------     ---------  	 --------------------	  --------------------------------------
    001        01/24/2019    William Hulse            Created Package.
 
**************************************************************************************************************/
 
/********************************************************************************
Drop and Create Program
*********************************************************************************/
DROP PROGRAM cov_opsjob_report:DBA GO
CREATE PROGRAM cov_opsjob_report:DBA
 
/********************************************************************************
Create Parameters
*********************************************************************************/
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "StartDate" = "SYSDATE"
	, "EndDate" = "SYSDATE"
	, "Status" = VALUE(1268.00, 1272.00, 614421.00, 1273.00, 1274.00)
	, "JobName" = VALUE("*                                       ")
 
with OUTDEV, StartDate, EndDate, Status, JobName
 
/********************************************************************************
	Get the Data
*********************************************************************************/
SELECT INTO ($OUTDEV)
	Node = O.HOST
	, ControlGroup = O.NAME
	, JobName = (IF(OT.JOB_GRP_NAME = " ") OJ.Name ELSE OT.JOB_GRP_NAME ENDIF)
	, ScheduleDate = FORMAT(OS.SCHEDULE_DT_TM, "MM/DD/YYYY")
	, ScheduleTime = SUBSTRING(1,15,FORMAT(OS.SCHEDULE_DT_TM, "HH:MM"))
	, JobStatus = UAR_GET_CODE_DISPLAY(OS.STATUS_CD)
	, TimeInterval = OT.TIME_INTERVAL
	, StepNumber = OJS.STEP_NUMBER
	, StepName = OJS.STEP_NAME
	, BatchName = OJS.BATCH_SELECTION
	, EventText = OSJ.OPS_EVENT
	, StepStatus = UAR_GET_CODE_DISPLAY(OS.STATUS_CD)
	, RunDateTime = FORMAT(OSJ.BEG_EFFECTIVE_DT_TM, "MM/DD/YYYY HH:MM:SS;;D")
	, RunEndDateTime = FORMAT(OSJ.END_EFFECTIVE_DT_TM, "MM/DD/YYYY HH:MM:SS;;D")
	, EffectiveDate = FORMAT(OT.BEG_EFFECTIVE_DT_TM, "MM/DD/YYYY")
	, JobModifiedPerson = P.NAME_FULL_FORMATTED
	, JobModifiedDate = FORMAT(OT.UPDT_DT_TM, "MM/DD/YYYY HH:MM:SS;;D")
	, StepModifiedPerson = PR.NAME_FULL_FORMATTED
	, StepModifiedDate = FORMAT(OSP.UPDT_DT_TM, "MM/DD/YYYY HH:MM:SS;;D")
 
FROM
	OPS_CONTROL_GROUP   O
	, (INNER JOIN OPS_TASK OT ON (O.ops_control_grp_id = OT.ops_control_grp_id))
	, (LEFT JOIN OPS_JOB OJ ON (OT.OPS_JOB_ID = OJ.OPS_JOB_ID))
	, (INNER JOIN OPS_SCHEDULE_TASK OS ON ((OT.OPS_TASK_ID = OS.OPS_TASK_ID) AND OS.ACTIVE_IND = 1))
	, (INNER JOIN PRSNL P ON (OT.UPDT_ID = P.PERSON_ID))
	, (LEFT JOIN OPS_SCHEDULE_PARAM OSP ON (ot.ops_task_id=osp.ops_task_id))
	, (LEFT JOIN PRSNL PR ON (OSP.UPDT_ID = PR.PERSON_ID))
	, (LEFT JOIN OPS_SCHEDULE_JOB_STEP OSJ ON (OSP.OPS_JOB_STEP_ID = OSJ.OPS_JOB_STEP_ID AND OS.OPS_SCHEDULE_TASK_ID = OSJ.OPS_SCHEDULE_TASK_ID))
	, (LEFT JOIN OPS_JOB_STEP OJS ON (OSJ.OPS_JOB_STEP_ID = OJS.OPS_JOB_STEP_ID AND OJS.ACTIVE_IND = 1))
 
WHERE
OS.STATUS_CD = $Status
AND OS.SCHEDULE_DT_TM BETWEEN CNVTDATETIME($StartDate) AND CNVTDATETIME($EndDate)
AND OT.JOB_GRP_NAME = $JobName
;OS.SCHEDULE_DT_TM > cnvtdatetime(curdate, 0)
;OT.BEG_EFFECTIVE_DT_TM > cnvtdatetime(curdate -7, 0)
;OT.BEG_EFFECTIVE_DT_TM BETWEEN CNVTDATETIME(CURDATE-7,0) AND CNVTDATETIME(CURDATE-1,235959)
 
ORDER BY
	;Node
	;, ControlGroup
	 ScheduleTime
	, StepNumber
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
END
GO
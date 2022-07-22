/*****************************************************
Author		 :  Michael Layman
Date Written :  4/26/18
Program Title:  Pending Tasks RT/PT/OT/SP
Source File	 :  cov_pend_tasks_rt_pt_ot_sp.prg
Object Name	 :	cov_pend_tasks_rt_pt_ot_sp
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program will produce a report
				that will display all pending tasks
				for several disciplines.
 
 
Tables Read  :  orders, person, encounter, encntr_alias, person_alias,
				task_activity
Tables
Updated      :	NA
Include Files:  NA
Executing
Application  :	Explorer Menu / Report Portal
Special Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mod #        By           Date           Purpose
0001   Dawn Greer, DBA    8/27/2019      CR 5509 - Added Nutrition Services Consult Task Type
0002   Dawn Greer, DBA    8/28/2019      CR 5509 - Added overdue and pending validation to the 
                                         the list of statuses to pull.  Added Task Status and 
                                         Fin field to the output.
****************************************************************************************************/
 
drop program cov_pend_tasks_rt_pt_ot_sp go
create program cov_pend_tasks_rt_pt_ot_sp
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Task Category" = 0
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date" = "SYSDATE"
 
with OUTDEV, facility, cattype, begdate, enddate
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
IF (VALIDATE(a) = 0)
FREE RECORD a
RECORD a
(
1	rec_cnt	=	i4
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	sex			=	vc
	2	age			=	vc
	2	taskcnt		=	i4
	2	taskqual[*]
		3	taskid		=	f8
		3	taskdesc	=	vc
		3	taskduedttm	=	vc
		3	tasktype	=	vc
		3	orddetail	=	vc
		3   taskstatus  =   vc		;0002 - Added field to record structure
 
)
ENDIF
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE ot = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'OCCUPATIONALTHERAPY')), PROTECT
DECLARE pt = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'PHYSICALTHERAPY')), PROTECT
DECLARE rt = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'RESPIRATORYTHERAPY')), PROTECT
DECLARE sp = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'SPEECHTHERAPY')), PROTECT
DECLARE rd = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'NUTRITIONSERVICES')), PROTECT
DECLARE pend = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',79,'PENDING')), PROTECT
DECLARE overdue = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',79,'OVERDUE')), PROTECT		;0002 - Added Task Status
DECLARE pendvalid = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',79,'PENDINGVALIDATION')), PROTECT  ; 0002 - Added Task Status
 
DECLARE ottskeval = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'OCCUPATIONALTHERAPYEVAL')), PROTECT
DECLARE ottsktrtm = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'OCCUPATIONALTHERAPYTREATMENTS')), PROTECT
DECLARE pttskeval = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'PHYSICALTHERAPYEVAL')), PROTECT
DECLARE pttsktrtm = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'PHYSICALTHERAPYTREATMENT')), PROTECT
DECLARE rttskeval = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'RESPIRATORYCARE')), PROTECT
DECLARE rttskmeds = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'RESPIRATORYMEDICATIONS')), PROTECT
DECLARE sptskeval = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'SLPEVALUATIONS')), PROTECT
DECLARE sptsktrtm = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'SLPTREATMENTS')), PROTECT
DECLARE diettsk	  = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'DIETARY')), PROTECT
DECLARE nsctsk	  = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6026,'NUTRITIONSERVICESCONSULTS')), PROTECT  ;0001 - Added Type
DECLARE mrn = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE filename = vc WITH NOCONSTANT(FILLSTRING(100,' ')), PROTECT
DECLARE output = vc WITH NOCONSTANT(FILLSTRING(100,' ')), PROTECT
 
DECLARE fachdr =  vc WITH NOCONSTANT(FILLSTRING(100,' ')), PROTECT
DECLARE daterng = vc WITH NOCONSTANT(FILLSTRING(100,' ')), PROTECT
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
CALL ECHO(BUILD('ot :', ot))
CALL ECHO(BUILD('pt :', pt))
CALL ECHO(BUILD('rt :', rt))
CALL ECHO(BUILD('rd :', rd))
CALL ECHO(BUILD('sp :', sp))
CALL ECHO(BUILD('ottskeval :', ottskeval))
CALL ECHO(BUILD('ottsktrtm :', ottsktrtm))
CALL ECHO(BUILD('pttskeval :', pttskeval))
CALL ECHO(BUILD('pttsktrtm :', pttsktrtm))
CALL ECHO(BUILD('rttskeval :', rttskeval))
CALL ECHO(BUILD('rttskmeds :', rttskmeds))
CALL ECHO(BUILD('sptskeval :', sptskeval))
CALL ECHO(BUILD('sptsktrtm :', sptsktrtm))
CALL ECHO(BUILD('diettsk :', diettsk))
CALL ECHO(BUILD('nsctsk :', nsctsk))	;0001 - Added
 
SET fachdr	 = UAR_GET_CODE_DISPLAY($facility)
SET daterng  = BUILD2(FORMAT(CNVTDATETIME($BEGDATE),"MM/DD/YYYY HH:MM;;Q"),' - ',
FORMAT(CNVTDATETIME($ENDDATE),"MM/DD/YYYY HH:MM;;Q"))
 
CASE ($cattype)
 
	OF (ot):
 
		SET filename = BUILD('cer_temp:',CNVTLOWER(fachdr),'_ot_','pnd_tsk','.pdf')
 
	OF (pt):
 
		SET filename = BUILD('cer_temp:',CNVTLOWER(fachdr),'_pt_','pnd_tsk','.pdf')
 
	OF (rd):
 
		SET filename = BUILD('cer_temp:',CNVTLOWER(fachdr),'_rd_','pnd_tsk','.pdf')
 
	OF (rt):
 
		SET filename = BUILD('cer_temp:',CNVTLOWER(fachdr),'_rt_','pnd_tsk','.pdf')
 
	OF (sp):
 
		SET filename = BUILD('cer_temp:',CNVTLOWER(fachdr),'_sp_','pnd_tsk','.pdf')
 
ENDCASE
 
CALL ECHO(BUILD('filename  :', filename))
CALL ECHO(BUILD('fachdr  :', fachdr))
CALL ECHO(BUILD('daterng  :', daterng))
 
if (validate(request->batch_selection) = 1)
	;ops
	SET output = value(filename)
 
else
	;manual run
	SET output = value($outdev)
 
endif
CALL ECHO(BUILD('output :', output))
 
 
 
SELECT into 'nl:'
 	unit	=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd),
 	room	=	UAR_GET_CODE_DISPLAY(e.loc_room_cd),
 	bed	=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
 
FROM task_activity ta,
	 encounter e,
	 person p,
	 ;person_alias pa,
	 encntr_alias ea,
	 orders o
 
 
PLAN ta
WHERE ta.task_type_cd in (ottskeval,ottsktrtm,
pttskeval, pttsktrtm, rttskeval, rttskmeds,
sptskeval, sptsktrtm, diettsk, nsctsk)	;0001 - Added nsctsk to list
AND ta.task_status_cd IN (pend, overdue, pendvalid)		;0002 - Added overude and pendvalid to the status
AND ta.catalog_type_cd = $cattype ;IN (ot, pt, rt, sp, rd)
JOIN o
WHERE ta.order_id = o.order_id
AND o.active_ind = 1
JOIN e
WHERE ta.encntr_id = e.encntr_id
AND e.loc_facility_cd = $facility
ANd e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
;JOIN pa
;WHERE  p.person_id = pa.person_id
;AND pa.person_alias_type_cd = mrn
;AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
;AND pa.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
AND ea.active_ind = 1
 
ORDER BY unit, room, bed, ta.task_dt_tm
HEAD REPORT
	cnt = 0
 
HEAD e.encntr_id
	cnt = cnt + 1
	if (mod(cnt,10 ) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].name	=	TRIM(p.name_full_formatted)
	;a->qual[cnt].mrn	=	TRIM(pa.alias)
	a->qual[cnt].fin	=	TRIM(ea.alias)
	a->qual[cnt].age	=	CNVTAGE(p.birth_dt_tm)
	a->qual[cnt].sex	=	UAR_GET_CODE_DISPLAY(p.sex_cd)
	a->qual[cnt].unit	=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room	=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed	=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->rec_cnt			=	cnt
	tcnt = 0
 
DETAIL
	tcnt = tcnt + 1
	if (mod(tcnt,10) = 1 or tcnt = 1)
 
		stat = alterlist(a->qual[cnt].taskqual, tcnt + 9)
 
	endif
	a->qual[cnt].taskqual[tcnt].taskid	=	ta.task_id
	a->qual[cnt].taskqual[tcnt].taskdesc = UAR_GET_CODE_DISPLAY(ta.catalog_cd)
	a->qual[cnt].taskqual[tcnt].taskduedttm = FORMAT(TA.task_dt_tm,"MM/DD/YYYY HH:MM;;Q")
	a->qual[cnt].taskqual[tcnt].tasktype	=	UAR_GET_CODE_DISPLAY(ta.task_type_cd)
	a->qual[cnt].taskqual[tcnt].orddetail	=	TRIM(o.order_detail_display_line)
	a->qual[cnt].taskqual[tcnt].taskstatus	=	UAR_GET_CODE_DISPLAY(ta.task_status_cd)	;0002 - Added 
	a->qual[cnt].taskcnt		=	tcnt
 
 
 
FOOT e.encntr_id
	stat = alterlist(a->qual[cnt].taskqual, tcnt)
 
FOOT REPORT
 
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
IF (a->rec_cnt > 0)
 
;Get MRN
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 person_alias pa
 
PLAN d
JOIN pa
WHERE a->qual[d.seq].personid = pa.person_id
AND pa.person_alias_type_cd = mrn
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
AND pa.active_ind = 1
 
DETAIL
	a->qual[d.seq].mrn = TRIM(pa.alias)
WITH nocounter
ENDIF
 
 
IF (VALIDATE(request->batch_selection) = 1)
 
 
EXECUTE cov_pend_task_ops_btg VALUE(output), VALUE($facility), VALUE($cattype),VALUE($begdate), VALUE($enddate)
 
;SELECT into VALUE(output)
;
;FROM (dummyt d with seq = a->rec_cnt),
;	 (dummyt d2 with seq = 1)
;
;PLAN d
;WHERE MAXREC(d2, a->qual[d.seq].taskcnt)
;JOIN d2
;
;
;HEAD REPORT
;	"Patient Name","|",
;	"Unit","|",
;	"Room","|",
;	"Bed","|",
;	"Task Type","|",
;	"Task","|",
;	"Order Detail"
;	ROW + 1
;
;DETAIL
;	a->qual[d.seq].name,"|",
;	a->qual[d.seq].unit,"|",
;	a->qual[d.seq].room,"|",
;	a->qual[d.seq].bed."|",
;	A->qual[d.seq].taskqual[d2.seq].tasktype,"|",
;	a->qual[d.seq].taskqual[d2.seq].taskdesc,"|"
;	a->qual[d.seq].taskqual[d2.seq].orddetail
;	ROW + 1
;
;
;
;WITH nocounter, FORMAT=stream, FORMFEED=none, MAXCOL = 500
 
ELSE
SELECT into VALUE(output)
	patientName = CONCAT(a->qual[d.seq].name,'                          '),
	fin = CONCAT(a->qual[d.seq].fin,'                          '),	;0002 - Added field
	unit = CONCAT(a->qual[d.seq].unit,'                '),
	room = CONCAT(a->qual[d.seq].room,'                   '),
	bed = CONCAT(a->qual[d.seq].bed,'                     '),
	taskstatus = CONCAT(a->qual[d.seq].taskqual[d2.seq].taskstatus,'                          '),	;0002 - Added field
	tasktype = CONCAT(a->qual[d.seq].taskqual[d2.seq].tasktype,'                      '),
	taskdesc = CONCAT(a->qual[d.seq].taskqual[d2.seq].taskdesc,'                        '),
	orddetail = CONCAT(a->qual[d.seq].taskqual[d2.seq].orddetail,'                          ')
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1)
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].taskcnt)
JOIN d2
ORDER BY unit, room, bed, patientName
WITH nocounter, FORMAT, SEPARATOR = ' ', nullreport
ENDIF
 
 
CALL ECHORECORD(a)
GO TO exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript
 
 
end
go
 
